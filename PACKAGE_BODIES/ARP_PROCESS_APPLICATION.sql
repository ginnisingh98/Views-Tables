--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_APPLICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_APPLICATION" AS
/* $Header: ARCEAPPB.pls 120.86.12010000.46 2010/11/11 21:12:06 mraymond ship $ */

/* =======================================================================
 | Global Data Types
 * ======================================================================*/
SUBTYPE ae_doc_rec_type   IS arp_acct_main.ae_doc_rec_type;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
--
-- Private procedures used by the package
--

NULL_VAR ar_payment_schedules%ROWTYPE; /* Added for Bug 460959 for Oracle 8 */
--
FUNCTION check_reversable (
        p_ra_id  IN ar_receivable_applications.receivable_application_id%TYPE,
        p_module_name    IN VARCHAR2,
        p_module_version IN VARCHAR2 ) RETURN BOOLEAN;
--
PROCEDURE reverse_action(
        p_ra_id IN ar_receivable_applications.receivable_application_id%TYPE,
        p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE,
        p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_reversal_gl_date	IN DATE
	, p_reversal_date	IN DATE,
        P_SELECT_FLAG		IN BOOLEAN,
        P_MODULE_NAME		IN VARCHAR2,
        P_MODULE_VERSION	IN VARCHAR2 );
--
PROCEDURE VALIDATE_ARGS(
        P_RA_ID IN AR_RECEIVABLE_APPLICATIONS.RECEIVABLE_APPLICATION_ID%TYPE,
        P_REVERSAL_GL_DATE      IN DATE,
        P_REVERSAL_DATE         IN DATE,
        P_MODULE_NAME           IN VARCHAR2 );
--
PROCEDURE reversal_insert_oppos_ra_recs (
	  p_ra_rec		IN OUT NOCOPY ar_receivable_applications%ROWTYPE
        , p_app_rec_trx_type    IN VARCHAR
        , p_reversal_gl_date	IN DATE
	, p_reversal_date	IN DATE
	, p_module_name		IN VARCHAR2
 	, p_called_from         IN VARCHAR2 DEFAULT NULL
        , p_rec_app_id          OUT NOCOPY NUMBER);  /* jrautiai BR implementation */

PROCEDURE reversal_update_old_ra_rec(
	  p_reversal_gl_date	DATE
        , p_ra_rec		IN OUT NOCOPY ar_receivable_applications%ROWTYPE
	);

PROCEDURE reversal_update_ps_recs (
	  p_ra_rec		IN ar_receivable_applications%ROWTYPE
        , p_app_rec_trx_type    IN VARCHAR
	, p_reversal_gl_date	IN DATE
	, p_reversal_date	IN DATE);
--
PROCEDURE  validate_reverse_action_args(
        p_ra_id IN ar_receivable_applications.receivable_application_id%TYPE,
        p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE,
        p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_reversal_gl_date IN DATE, p_reversal_date IN DATE,
        p_select_flag IN BOOLEAN );
--
PROCEDURE validate_args_appdel(
        p_ra_id  IN ar_receivable_applications.receivable_application_id%TYPE );
--
PROCEDURE  validate_receipt_appln_args(
	p_receipt_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
	p_invoice_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_amount_applied IN ar_receivable_applications.amount_applied%TYPE,
        p_amount_applied_from IN ar_receivable_applications.amount_applied_from%TYPE,
        p_trans_to_receipt_rate IN ar_receivable_applications.trans_to_receipt_rate%TYPE,
        p_invoice_currency_code IN ar_payment_schedules.invoice_currency_code%TYPE,
        p_receipt_currency_code IN ar_cash_receipts.currency_code%TYPE,
        p_earned_discount_taken IN ar_receivable_applications.earned_discount_taken%TYPE,
        p_unearned_discount_taken IN ar_receivable_applications.unearned_discount_taken%TYPE,
        p_apply_date IN ar_receivable_applications.apply_date%TYPE,
	p_gl_date IN ar_receivable_applications.gl_date%TYPE );
--
PROCEDURE  validate_cm_appln_args(
        p_cm_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_invoice_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_amount_applied IN
                ar_receivable_applications.amount_applied%TYPE,
        p_apply_date IN ar_receivable_applications.apply_date%TYPE,
        p_gl_date IN ar_receivable_applications.gl_date%TYPE );
--
PROCEDURE  validate_on_account_args(
        p_ps_id   IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_amount_applied IN
                ar_receivable_applications.amount_applied%TYPE,
        p_apply_date IN ar_receivable_applications.apply_date%TYPE,
        p_gl_date IN ar_receivable_applications.gl_date%TYPE );

PROCEDURE validate_activity_args(
        p_ps_id                    IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_application_ps_id        IN ar_receivable_applications.applied_payment_schedule_id%TYPE,
        p_link_to_customer_trx_id  IN ar_receivable_applications.link_to_customer_trx_id%TYPE,
        p_amount_applied           IN ar_receivable_applications.amount_applied%TYPE,
        p_apply_date               IN ar_receivable_applications.apply_date%TYPE,
        p_gl_date                  IN ar_receivable_applications.gl_date%TYPE,
        p_receivables_trx_id       IN ar_receivable_applications.receivables_trx_id%TYPE);

PROCEDURE validate_activity(
        p_application_ps_id  IN ar_receivable_applications.applied_payment_schedule_id%TYPE,
        p_activity_type      IN ar_receivables_trx.type%TYPE);

PROCEDURE reverse_action_receipt_cb(
        p_chargeback_customer_trx_id  IN ar_receivable_applications.application_ref_id%TYPE,
        p_reversal_gl_date            IN DATE,
        p_reversal_date               IN DATE,
        p_module_name                 IN VARCHAR2,
        p_module_version              IN VARCHAR2);

PROCEDURE insert_trx_note(
              p_customer_trx_id             IN  NUMBER
            , p_receipt_number              IN  VARCHAR2
            , p_claim_number                IN  VARCHAR2
            , p_flag                        IN  VARCHAR2);


FUNCTION unapp_postable(p_applied_customer_trx_id  IN ar_receivable_applications.applied_customer_trx_id%TYPE,
                        p_applied_ps_id            IN ar_receivable_applications.applied_payment_schedule_id%TYPE) RETURN BOOLEAN;

PROCEDURE reverse_action_misc_receipt(
	p_cash_receipt_id IN ar_receivable_applications.application_ref_id%TYPE,
	p_reversal_gl_date IN DATE,
    p_reversal_date IN DATE,
	p_reversal_comments IN VARCHAR2 DEFAULT NULL,
	p_called_from IN VARCHAR2  DEFAULT NULL);
--
/*===========================================================================+
 | FUNCTION                                                                  |
 |    revision                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function returns the revision number of this package.             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | RETURNS    : Revision number of this package                              |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |	6/25/1996	Harri Kaukovuo	Created                              |
 +===========================================================================*/
FUNCTION revision RETURN VARCHAR2 IS
BEGIN
  RETURN '$Revision: 120.86.12010000.46 $';
END revision;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    reverse                                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Reverse a cash receipt application                                     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |     arp_app_pkg.fetch_p - Fetch a record from                             |
 |                                        AR_RECEIVABLE_APPLICATIONS table   |
 |     arp_app_pkg.lock_p  - lock  a record in                               |
 |                                        AR_RECEIVABLE_APPLICATIONS table   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_ra_id - Id of application to be reversed             |
 |                    p_reversal_gl_date - Reversal GL date                  |
 |                    p_reversal_date - Reversal Date                        |
 |                    p_module_name - Name of module that called this proc   |
 |                    p_module_version - Version of the module that called   |
 |                                       this procedure                      |
 |              OUT:    p_bal_due_remaining                                  |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |
 |  21-Jul-97   Karen Lawrance  Release 11.
 |                              Cleaned up code and included some more
 |                              comments.
 |  09-Jun-99   Debbie Jancis   added balance due remaining to return
 |                              balance due on invoice to update the
 |                              the field on the form.
 |  12-JUL-2000 Jani Rautiainen Added parameter p_called_from to procedure   |
 |                              reverse. This is needed in the logic to      |
 |                              be able to create the transaction history    |
 |                              record for an Bills Receivable transaction   |
 |                              when its payment schedule is opened / closed |
 | 06/12/2001  S.Nambiar        Bug 1830483 - Activity application should not
 |                              show error when there is no CB attached while
 |                              doing the unapplication
 +===========================================================================*/
PROCEDURE reverse (
	  p_ra_id		IN NUMBER
	, p_reversal_gl_date    IN DATE
	, p_reversal_date      	IN DATE
	, p_module_name		IN VARCHAR2
	, p_module_version	IN VARCHAR2
        , p_bal_due_remaining   OUT NOCOPY NUMBER
 	, p_called_from         IN VARCHAR2) IS /* jrautiai BR implementation */

l_ra_rec			ar_receivable_applications%ROWTYPE;
l_return_code			VARCHAR2(20);
l_ps_rec			ar_payment_schedules%ROWTYPE;
ln_batch_id			NUMBER;
l_payment_schedule_id    ar_payment_schedules.payment_schedule_id%TYPE;
l_bal_due_rem            NUMBER;

   l_old_ps_rec               ar_payment_schedules%ROWTYPE; /* jrautiai BR implementation */
l_rec_app_id                  NUMBER;
--apandit Bug : 2641517
l_status                      VARCHAR2(30);
l_called_from                 VARCHAR2(30);  --Bug7194951
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug('arp_process_application.reverse()+' );
    END IF;

    -- Validate input arguments
    validate_args( p_ra_id,
                   p_reversal_gl_date,
                   p_reversal_date, p_module_name );

     -- Populate the ar_receivable_applications record from
     -- ar_receivable_applications table.

     --Bug:4068781
     BEGIN
       arp_app_pkg.lock_p( p_ra_id );
     EXCEPTION
       WHEN OTHERS
         THEN
           FND_MESSAGE.SET_NAME( 'FND', 'FND_LOCK_RECORD_ERROR');
           FND_MSG_PUB.Add;
           APP_EXCEPTION.raise_exception;
     END;

     arp_app_pkg.fetch_p( p_ra_id, l_ra_rec );
    --apandit Bug : 2641517
     l_status := l_ra_rec.status;

     -- get the payment schedule id of the trx that receipt was
     -- applied to.
     l_payment_schedule_id := l_ra_rec.applied_payment_schedule_id;

    /* 12-JUL-2000 J Rautiainen BR Implementation
     * Storing the old image of the payment schedule
     * This is only done when application is done outside the BR remittance program */

    --Added ARXRWAPP also in the list for receipt write-off
    --No need to fetch PS record for receipt write-off


     IF NVL(p_called_from,'NONE') not in ('RISK_UNELIMINATED','BR_REMITTED',
         'BR_FACTORED_WITH_RECOURSE','BR_FACTORED_WITHOUT_RECOURSE','ARXRWAPP')
        AND l_ra_rec.status = 'APP' THEN

       arp_ps_pkg.fetch_p( l_payment_schedule_id, l_old_ps_rec );

     END IF;

     --
     -- If status is 'APP', check if application may be deleted
     --
     /* 06-JUL-2000 J Rautiainen BR Implementation
      * Activity application impacts the receipt payment schedule */
     IF ( l_ra_rec.status in ('APP','ACTIVITY') AND l_ra_rec.display = 'Y' ) THEN
         --
         -- Reverse chargebacks and adjustments associated with the
         -- application.
         --
        /* 06-JUL-2000 J Rautiainen BR Implementation
         * No chargebacks or adjustments exist on Activity application
         snambiar - except for receipt chargebacks                   */

         IF l_ra_rec.status = 'APP' THEN
           IF ( check_reversable( p_ra_id, NULL, NULL ) = TRUE ) THEN
	        reverse_action( p_ra_id, NULL, NULL,
                                p_reversal_gl_date, p_reversal_date,
                                TRUE, NULL, NULL );

           ELSE
               fnd_message.set_name( 'AR', 'AR_CBK_FAIL');
               APP_EXCEPTION.raise_exception;
           END IF;

       --snambiar for receipt chargeback,we need to reverse the chargeback also
       --associated with the activity application.
           ELSIF (l_ra_rec.status = 'ACTIVITY') THEN
            IF(l_ra_rec.applied_payment_schedule_id = -5) THEN
              IF (check_reversable( p_ra_id, NULL, NULL ) = TRUE ) THEN

                 reverse_action_receipt_cb(l_ra_rec.application_ref_id,
                                          p_reversal_gl_date,
                                          p_reversal_date,
                                          NULL,
                                          NULL );
              ELSE
                 fnd_message.set_name( 'AR', 'AR_CBK_FAIL');
                 APP_EXCEPTION.raise_exception;
              END IF;

            ELSIF (l_ra_rec.applied_payment_schedule_id in (-6 , -9 )) THEN --Bug 5532825 Added -9 for CCCB

			   IF (NVL(P_called_from,'NONE')
			        not in ('REVERSE_MISC','RATE_ADJUST_MISC')) THEN

			      IF (check_reversable( p_ra_id, NULL, NULL ) = TRUE) THEN
                     reverse_action_misc_receipt(
	                      p_cash_receipt_id=>l_ra_rec.application_ref_id,
	                      p_reversal_gl_date=>p_reversal_gl_date,
                          p_reversal_date=>p_reversal_gl_date,
	                      p_reversal_comments=>l_ra_rec.comments,
						  p_called_from=>p_called_from);
                  ELSE
                     fnd_message.set_name( 'AR', 'AR_RW_CCR_REMITTED');
                     APP_EXCEPTION.raise_exception;
			      END IF;
			   END IF;

            END IF; --l_ra_rec.applied_payment_schedule_id

         END IF; --l_ra_rec.status

         -----------------------------------------------------------
         -- If the status of the row is APP, we need to reverse the
         -- application by updating the corresponding rows in
         -- payment schedules.  This includes the payment schedule
         -- row for both the Cash Receipt and applied Transaction.
         --
         -----------------------------------------------------------
         -----------------------------------------------------------
         -- Bug 2004654
         -- If the status of the row is APP or ACIVITY, we need to reverse the
         -- application by updating the corresponding rows in
         -- payment schedules.  This includes the payment schedule
         -- row for both the Cash Receipt and applied Transaction.
         --
         -----------------------------------------------------------

        IF ( NVL( l_ra_rec.confirmed_flag, 'Y' ) = 'Y'
                AND l_ra_rec.status in ('APP', 'ACTIVITY')) THEN

	         reversal_update_ps_recs ( l_ra_rec,
                                           'AR_APP',
	       				   p_reversal_gl_date ,
					   p_reversal_date);
        END IF;

         -- bug 584303:  try to get the amount due remaining
         -- on the applied trx so it can be returned to the
         -- form.

        /* 06-JUL-2000 J Rautiainen BR Implementation
         * Transaction payment schedule was not updated for activity application  */

         IF (l_payment_schedule_id IS NOT NULL and l_ra_rec.status <> 'ACTIVITY') THEN
              SELECT amount_due_remaining
                   INTO l_bal_due_rem
                from ar_payment_schedules
              where payment_schedule_id = l_payment_schedule_id;
         END IF;

         if (l_bal_due_rem IS NOT NULL) THEN
             p_bal_due_remaining := l_bal_due_rem;
         end if;
     END IF;

     ----------------------------------------------------------
     -- Update the current ar_receivable_applications record.
     -- Set reversal_gl_date and display_flag to 'N'.
     --
     ----------------------------------------------------------
     reversal_update_old_ra_rec( p_reversal_gl_date, l_ra_rec );

     /* Bug fix 2877224
        Update the UNAPP record which is paired with the APP record being reversed.
        The reversal_gl_date needs to be populated */
       update ar_receivable_applications
       set  reversal_gl_date = p_reversal_gl_date,
            include_in_accumulation = 'N'   -- bug 6924942 --> setting accumulation flag to 'N'
       where receivable_application_id = (select source_id
                                           from ar_distributions
                                           where source_table = 'RA'
                                            and source_type = 'UNAPP'
                                            and source_id_secondary = l_ra_rec.receivable_application_id);

     /* Bug fix 3000242
        For upgraded data, source_id secondary will not be populated.
        So if the above update can not update the paired UNAPP record, the following update
        which uses the maximum matching criteria should be run to update the paired UNAPP record */
        IF SQL%NOTFOUND THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_debug.debug(   'trans_to_receipt_rate = '||to_char(l_ra_rec.trans_to_receipt_rate));
             arp_debug.debug(   'cash_receipt_id = '||to_char(l_ra_rec.cash_receipt_id));
             arp_debug.debug(   'posting_control_id = '||to_char(l_ra_rec.posting_control_id));
             arp_debug.debug(   'gl_posted_date = '||to_char(l_ra_rec.gl_posted_date,'DD-MON-YYYY'));
             arp_debug.debug(   'amount_applied = '||to_char(l_ra_rec.amount_applied));
             arp_debug.debug(   'amount_applied_from = '||to_char(l_ra_rec.amount_applied_from));
             arp_debug.debug(   'gl_date = '||to_char(l_ra_rec.gl_date,'DD-MON-YYYY'));
             arp_debug.debug(   'apply_date = '||to_char(l_ra_rec.apply_date,'DD-MON-YYYY'));
          END IF;
          IF l_ra_rec.trans_to_receipt_rate is NOT NULL THEN
            update ar_receivable_applications
               set reversal_gl_date = p_reversal_gl_date
             where receivable_application_id = (select /*+ INDEX (AR_RECEIVABLE_APPLICATIONS_ALL AR_RECEIVABLE_APPLICATIONS_N1) */
						       max(receivable_application_id)
                                                  from ar_receivable_applications
                                                 where cash_receipt_id = l_ra_rec.cash_receipt_id
                                                   and status ='UNAPP'
                                                   and posting_control_id = l_ra_rec.posting_control_id
                                                   and nvl(gl_posted_date,sysdate) = nvl(l_ra_rec.gl_posted_date, sysdate)
     -------  bug fix 3000242+  ----------
                                                   and cash_receipt_history_id = l_ra_rec.cash_receipt_history_id
                                                   and (request_id = l_ra_rec.request_id
                                                        or
                                                        (request_id IS NULL and l_ra_rec.request_id IS NULL))
   -------  bug fix 3000242-  ----------
                                                   and amount_applied_from = -l_ra_rec.amount_applied_from
                                                   and gl_date             = l_ra_rec.gl_date
                                                   and apply_date = l_ra_rec.apply_date
                                                   and reversal_gl_date is NULL);
          ELSE
            update ar_receivable_applications
               set reversal_gl_date = p_reversal_gl_date
             where receivable_application_id = (select /*+ INDEX (AR_RECEIVABLE_APPLICATIONS_ALL AR_RECEIVABLE_APPLICATIONS_N1) */
						       max(receivable_application_id)
                                                  from ar_receivable_applications
                                                 where cash_receipt_id = l_ra_rec.cash_receipt_id
                                                   and status ='UNAPP'
                                                   and posting_control_id = l_ra_rec.posting_control_id
                                                   and nvl(gl_posted_date,sysdate) = nvl(l_ra_rec.gl_posted_date, sysdate)
   -------  bug fix 3000242+  ----------
                                                   and cash_receipt_history_id = l_ra_rec.cash_receipt_history_id
                                                   and (request_id = l_ra_rec.request_id
                                                        or
                                                        (request_id IS NULL and l_ra_rec.request_id IS NULL))
  -------  bug fix 3000242-  ----------
                                                   and amount_applied = -l_ra_rec.amount_applied
                                                   and gl_date        = l_ra_rec.gl_date
                                                   and apply_date     = l_ra_rec.apply_date
                                                   and reversal_gl_date is NULL);
         END IF;
       END IF;

     ----------------------------------------------------
     -- Insert opposing rows in receivable applications.
     --
     ----------------------------------------------------

     --Bug7194951 Changes Start Here
     IF nvl(p_called_from,'NONE') = 'PREPAYMENT' THEN
        l_called_from := NULL;
     ELSE
        l_called_from := p_called_from;
     END IF;
     --Bug7194951 Changes End Here

     reversal_insert_oppos_ra_recs(
		  l_ra_rec
                , 'AR_APP'
		, p_reversal_gl_date
		, p_reversal_date
		, p_module_name
                , l_called_from		--Bug7194951
                , l_rec_app_id);


    -----------------------------------
    -- Update batch status if needed.
    -----------------------------------
    SELECT
      crh.batch_id
    INTO
      ln_batch_id
    FROM
	  ar_cash_receipt_history	crh
        , ar_receivable_applications	ra
    WHERE
	ra.receivable_application_id	= p_ra_id
    AND	ra.cash_receipt_id		= crh.cash_receipt_id
    AND crh.current_record_flag		= 'Y';

    /* 8974877 - Prevent call if this is coming from autoreceipts */
    IF (ln_batch_id IS NOT NULL AND nvl(p_called_from,'NONE')
         NOT IN ('AUTORECAPI','AUTORECAPI2'))
    THEN
      arp_rw_batches_check_pkg.update_batch_status(ln_batch_id,p_called_from);	--Bug7194951
    END IF;

   /*---------------------------------------------------------------------------------+
    |  12-JUL-2000 J Rautiainen BR Implementation                                     |
    |  If Bills receivable PS is closed or opened we need to create the corresponding |
    |  transaction history record. This logic is only for normal receipt applications |
    |  outside the BR remittance program, since for BR programs the record will be    |
    |  created by the BR API.                                                         |
    +---------------------------------------------------------------------------------*/

    IF NVL(l_old_ps_rec.class,'INV') = 'BR'
       AND NVL(p_called_from,'NONE') not in ('RISK_UNELIMINATED','BR_REMITTED','BR_FACTORED_WITH_RECOURSE','BR_FACTORED_WITHOUT_RECOURSE') THEN


     /*------------------------------------+
      |  Create transaction history record |
      +------------------------------------*/

      ARP_PROC_TRANSACTION_HISTORY.create_trh_for_receipt_act(l_old_ps_rec,
                                                              l_ra_rec,
                                                              'ARCEAPPB');


    END IF;

     --apandit
     --Bug : 2641517 raise UnApply business event.
     IF l_status in ('APP','ACTIVITY')  THEN
      AR_BUS_EVENT_COVER.Raise_CR_UnApply_Event(l_rec_app_id);
     END IF;

    -- RAM-C changes begin
    --
    -- call revenue management's receipt analyzer for revenue related
    -- impact of this reversal.

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'calling receipt_analyzer in reversal mode');
    END IF;

    ar_revenue_management_pvt.receipt_analyzer (
      p_mode => ar_revenue_management_pvt.c_receipt_reversal_mode,
      p_receivable_application_id => p_ra_id);

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug('returned from receipt_analyzer');
    END IF;

    -- RAM-C changes end

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug('arp_process_application.reverse()-' );
    END IF;
EXCEPTION
    WHEN OTHERS THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_debug.debug(
 	 'EXCEPTION: arp_process_application.reverse' );
         END IF;
         RAISE;
END reverse;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    reverse_cm_app                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Reverse a credit memo application.                                     |
 |	The algorithm for reversing an cm application is                     |
		1. Reverse existing application using opposite               |
		   amounts. This is done by creating a new row into          |
		   AR_RECEIVABLE_APPLICATIONS table.                         |
		2. Update applied transaction row in AR_PAYMENT_SCHEDULES    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |     arp_app_pkg.fetch_p - Fetch a record from
 |                           AR_RECEIVABLE_APPLICATIONS table
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              pn_ra_id		Id of application to be reversed
 |              pd_reversal_gl_date	Reversal GL date
 |              pd_reversal_date	Reversal Date
 |              pc_module_name		Name of module that called this proc.
 |              pc_module_version	Version of the module that called
 |                                      this procedure
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY
 | 5/30/1996	Harri Kaukovuo		Created
 |                                                                           |
 +===========================================================================*/
PROCEDURE reverse_cm_app(
          pn_ra_id               IN NUMBER
	, pn_applied_ps_id	 IN NUMBER
        , pd_reversal_gl_date    IN DATE
        , pd_reversal_date       IN DATE
        , pc_module_name         IN VARCHAR2
        , pc_module_version      IN VARCHAR2
        , p_called_from          IN VARCHAR2 ) IS

lr_ra_rec		ar_receivable_applications%ROWTYPE;
l_rec_app_id            NUMBER;
l_trx_type		VARCHAR2(20);

-- added for unapplication of regular CM
l_rule_id               NUMBER;
l_reg_cm                BOOLEAN;
l_rev_rec_run           VARCHAR2(1);
l_sum_dist              NUMBER;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug( 'arp_process_application.reverse_cm_app()+' );
  END IF;

  -- -------------------------------------------------------------------
  -- Get ready to insert application row into ar_receivable_applications.
  -- We use table handler to insert the record.
  -- -------------------------------------------------------------------

  --   Populate the ar_receivable_applications record from
  --   ar_receivable_applications table. Use ar_receivable_application_id
  --   for selection.

  --Bug:4068781
  BEGIN
    arp_app_pkg.lock_p( pn_ra_id );
  EXCEPTION
    WHEN OTHERS
      THEN
        FND_MESSAGE.SET_NAME( 'FND', 'FND_LOCK_RECORD_ERROR');
        FND_MSG_PUB.Add;
        APP_EXCEPTION.raise_exception;
  END;

  arp_app_pkg.fetch_p( pn_ra_id, lr_ra_rec );

  -- need some information to check if we have a regular cm or
  -- on acct credit memo also if we have invoice with rules.
  -- to do some processing before the application is reversed.
  l_reg_cm :=  arp_process_application.is_regular_cm(
                  p_customer_trx_id => lr_ra_rec.customer_trx_id,
                  p_invoicing_rule_id => l_rule_id);

  IF (l_reg_cm) THEN
    IF (l_rule_id <> -999) THEN
       -- make sure rev rec is run, if not, run rev rec
       IF (PG_DEBUG in ('Y', 'C'))  THEN
          arp_debug.debug('reverse_cm_app: we have a reg cm with rules');
       END IF;

       -- has rev rec been run for this CM?
       l_rev_rec_run := arpt_sql_func_util.get_revenue_recog_run_flag(
                             p_customer_Trx_id   => lr_ra_rec.customer_trx_id,
                             p_invoicing_rule_id => l_rule_id);

       IF (l_rev_rec_run = 'N') THEN
          -- we need to run rev rec - to be safe, we will run it for
          -- the invoice as well as the CM.
          l_sum_dist := ARP_AUTO_RULE.create_distributions
                       ( p_commit => 'N',
                         p_debug  => 'N',
                         p_trx_id => lr_ra_rec.applied_customer_trx_id);

          l_sum_dist := ARP_AUTO_RULE.create_distributions
                       ( p_commit => 'N',
                         p_debug  => 'N',
                         p_trx_id => lr_ra_rec.customer_trx_id);
       END IF;

    END IF;

    arp_process_application.Unassociate_Regular_CM(
                 p_cust_Trx_id      => lr_ra_rec.customer_trx_id,
                 p_app_cust_trx_id  => lr_ra_rec.applied_customer_trx_id);

  END IF;

  -- If status of ar_receivable_applications record is 'APP', then
  -- reverse the application by updating ar_payment_schedule of the
  -- invoice, also set actual date closed and gl_date_closed.

  IF ( NVL( lr_ra_rec.confirmed_flag, 'Y' ) = 'Y' ) THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_debug.debug(   'lr_ra_rec.confirmed_flag = Y' );
     END IF;

     /* Bug 4122494 CM refunds */
     IF pn_applied_ps_id = -8 THEN
        l_trx_type := 'AR_CM_REF';
     ELSE
        l_trx_type := 'AR_CM';
     END IF;

     reversal_update_ps_recs(
	  lr_ra_rec
        , l_trx_type
	, pd_reversal_gl_date
        , pd_reversal_date );
  END IF;

  -- Update the current ar_receivable_applications record and set
  -- reversal_gl_date and display_flag to 'N'.

  reversal_update_old_ra_rec( pd_reversal_gl_date, lr_ra_rec );

  -- Insert opposing application in ar_receivable_applications.
  -- NOTE: We are passing module name ARREREVB to simulate same effect
  -- as reversing the receipt would cause. We are not doing the same kind
  -- of reversing as normal application reverse is doing.

  -- Normal application:
  -- 	10 	APP	(this is the original applied record)
  --	-10 	APP	<--   this is created to reverse applied row
  --	10 	UNAPP	<--   this is created to mark reversed amount
  --			      to be unapplied.

  -- Using 'ARREREVB' (reversing credit memo application):
  --	10	APP	(this is the original applied record, against CM)
  --	-10 	APP	<--   this is created to reverse applied row

  reversal_insert_oppos_ra_recs(
                  lr_ra_rec
                , 'AR_CM'
                , pd_reversal_gl_date
                , pd_reversal_date
                , 'ARREREVB'
                , null
                , l_rec_app_id);

  --apandit
  --Bug : 2641517 raise the business event
  IF lr_ra_rec.status = 'APP' THEN
     AR_BUS_EVENT_COVER.Raise_CM_UnApply_Event(l_rec_app_id);
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug( 'arp_process_application.reverse_cm_app()-' );
  END IF;

END reverse_cm_app;
--
/*===========================================================================+
   PROCEDURE
     update_selected_transaction

   DESCRIPTION
 	This procedure is used to update the applied amount
 	of an application. Usually receivable_applications row
 	is not updated directly, but this is the case when
 	we handle confirmed receipt applications that are not
 	actually officially applied.

   SCOPE - PUBLIC

   EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE

   ARGUMENTS  : IN:
                pn_ra_id                Id of application to be reversed
                                       this procedure
		pn_amount_applied	Amount which is going to be
					updated on application row.
	        pc_invoice_currency_code Invoice currency code
       	 	pn_invoice_exchange_rate Invoice exchange rate
        	pc_receipt_currency_code Receipt currency code
        	pn_receipt_exchange_rate Receipt exchange rate
		pb_fetch_from_db_flag	Indicator which tells procedure
					to get invoice and receipt info
					from database instead of using
					passed parameters.
		pc_module_name		Name of the calling module
		pc_module_version	Version number of the module
		attribute_category
		attribute1
                attribute2
                attribute3
                attribute4
                attribute5
                attribute6
                attribute7
                attribute8
                attribute9
                attribute10
                attribute11
                attribute12
                attribute13
                attribute14
                attribute15
		global_attribute_category
		global_attribute1
		global_attribute2
                global_attribute3
                global_attribute4
                global_attribute5
                global_attribute6
                global_attribute7
                global_attribute8
                global_attribute9
                global_attribute10
                global_attribute11
                global_attribute12
                global_attribute13
                global_attribute14
                global_attribute15
                global_attribute16
                global_attribute17
                global_attribute18
                global_attribute19
                global_attribute20

                OUT:

  RETURNS    : NONE

  NOTES
 	I made this procedure to be ready for Rel 11 cross currency
 	feature (i.e included both invoice and receipt currency
 	information).

 	We don't use module and version information yet (not necessary
 	but might be used for customizations).

   MODIFICATION HISTORY
   6/18/1996    Harri Kaukovuo  Created
   9/02/1997    Tasman Tang	Added global_attribute_category and
 				global_attribute[1-20] for global
 				descriptive flexfield
 				Fixed bug 546626: check if functional
 				currency is the same as invoice and receipt
 				currency and do the corresponding parameter
				checking because rate can be null if receipt
 				currency equals to functional currency
   10/22/1997	Karen Murphy	Bug fix #567872.  Added code to update the
				UNAPP row when chaning the amount applied
				of one of the APP rows.
   12/04/1997   Karen Murphy    Bug fix #567872.  Added the setting of the
                                acctd_amount_applied_from for the UNAPP row.
   12/05/1997   Karen Murphy    Bug 546626.  Call to ARPCURR.functional_amount
                                needs to pass the functional currency not
                                the invoice and receipt currencies.  This
                                causes incorrect rounding.
   09/10/2002   Debbie Jancis   Modified for MRC trigger replacement.  Added
				call to ar_mrc_engine3 to process receivable
				applications.
 +===========================================================================*/
PROCEDURE update_selected_transaction(
        pn_ra_id                      IN NUMBER,
        pn_amount_applied             IN NUMBER,
        pc_invoice_currency_code      IN VARCHAR2,
        pn_invoice_exchange_rate      IN NUMBER,
        pc_receipt_currency_code      IN VARCHAR2,
        pn_receipt_exchange_rate      IN NUMBER,
        pc_module_name                IN VARCHAR2,
        pc_module_version             IN VARCHAR2,
        p_attribute_category    IN VARCHAR2,
        p_attribute1            IN VARCHAR2,
        p_attribute2            IN VARCHAR2,
        p_attribute3            IN VARCHAR2,
        p_attribute4            IN VARCHAR2,
        p_attribute5            IN VARCHAR2,
        p_attribute6            IN VARCHAR2,
        p_attribute7            IN VARCHAR2,
        p_attribute8            IN VARCHAR2,
        p_attribute9            IN VARCHAR2,
        p_attribute10           IN VARCHAR2,
        p_attribute11           IN VARCHAR2,
        p_attribute12           IN VARCHAR2,
        p_attribute13           IN VARCHAR2,
        p_attribute14           IN VARCHAR2,
        p_attribute15           IN VARCHAR2,
        p_global_attribute_category IN VARCHAR2,
        p_global_attribute1 IN VARCHAR2,
        p_global_attribute2 IN VARCHAR2,
        p_global_attribute3 IN VARCHAR2,
        p_global_attribute4 IN VARCHAR2,
        p_global_attribute5 IN VARCHAR2,
        p_global_attribute6 IN VARCHAR2,
        p_global_attribute7 IN VARCHAR2,
        p_global_attribute8 IN VARCHAR2,
        p_global_attribute9 IN VARCHAR2,
        p_global_attribute10 IN VARCHAR2,
        p_global_attribute11 IN VARCHAR2,
        p_global_attribute12 IN VARCHAR2,
        p_global_attribute13 IN VARCHAR2,
        p_global_attribute14 IN VARCHAR2,
        p_global_attribute15 IN VARCHAR2,
        p_global_attribute16 IN VARCHAR2,
        p_global_attribute17 IN VARCHAR2,
        p_global_attribute18 IN VARCHAR2,
        p_global_attribute19 IN VARCHAR2,
        p_global_attribute20 IN VARCHAR2 ) IS

lr_ra_rec               ar_receivable_applications%ROWTYPE;
functional_curr		VARCHAR2(100);

ln_amount_change	NUMBER;
ln_cash_receipt_id	NUMBER;
ln_unapp_ra_id		NUMBER;

l_app_ra_rec            ar_receivable_applications%ROWTYPE;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug( 'arp_process_application.update_selected_transaction()+');
  END IF;

  functional_curr := arp_global.functional_currency;

  -- First check that all required arguments have some value
  IF (pn_ra_id IS NULL)
  THEN
    APP_EXCEPTION.INVALID_ARGUMENT(
          'ARP_PROCESS_APPLICATION.UPDATE_SELECTED_TRANSACTION'
        , 'PN_RA_ID'
        , 'NULL');
  ELSIF (pn_amount_applied IS NULL)
  THEN
    APP_EXCEPTION.INVALID_ARGUMENT(
          'ARP_PROCESS_APPLICATION.UPDATE_SELECTED_TRANSACTION'
        , 'pn_amount_applied'
        , 'NULL');
  END IF;

  IF (pc_invoice_currency_code IS NULL) THEN
    APP_EXCEPTION.INVALID_ARGUMENT(
          'ARP_PROCESS_APPLICATION.UPDATE_SELECTED_TRANSACTION'
        , 'pc_invoice_currency_code'
        , 'NULL');
  ELSIF (pc_invoice_currency_code <> functional_curr) AND
        (pn_invoice_exchange_rate IS NULL) THEN
    APP_EXCEPTION.INVALID_ARGUMENT(
          'ARP_PROCESS_APPLICATION.UPDATE_SELECTED_TRANSACTION'
        , 'pn_invoice_exchange_rate'
        , 'NULL');
  END IF;

  IF (pc_receipt_currency_code IS NULL) THEN
    APP_EXCEPTION.INVALID_ARGUMENT(
          'ARP_PROCESS_APPLICATION.UPDATE_SELECTED_TRANSACTION'
        , 'pc_receipt_currency_code'
        , 'NULL');
  ELSIF (pc_receipt_currency_code <> functional_curr) AND
	(pn_receipt_exchange_rate IS NULL) THEN
    APP_EXCEPTION.INVALID_ARGUMENT(
          'ARP_PROCESS_APPLICATION.UPDATE_SELECTED_TRANSACTION'
        , 'pn_receipt_exchange_rate'
        , 'NULL');
  END IF;

  --   Populate the ar_receivable_applications record from
  --   ar_receivable_applications table. Use ar_receivable_application_id
  --   for selection.

  --Bug:4068781
  BEGIN
    arp_app_pkg.lock_p( pn_ra_id );
  EXCEPTION
    WHEN OTHERS
      THEN
        FND_MESSAGE.SET_NAME( 'FND', 'FND_LOCK_RECORD_ERROR');
        FND_MSG_PUB.Add;
        APP_EXCEPTION.raise_exception;
  END;
  arp_app_pkg.fetch_p( pn_ra_id, lr_ra_rec );

  -- Before we update the APP row, we need to calculate the change in amount
  -- so we can update the UNAPP row for the cash receipt.
  IF lr_ra_rec.amount_applied <> pn_amount_applied THEN
     ln_amount_change := lr_ra_rec.amount_applied - pn_amount_applied;
     ln_cash_receipt_id := lr_ra_rec.cash_receipt_id;
  END IF;

  -- Set the amount and calculate accounted amount (in base currency)
  lr_ra_rec.amount_applied 		:= pn_amount_applied;

  -- This is functional amount for the transaction (invoice)
  IF (pc_invoice_currency_code = functional_curr) THEN
    lr_ra_rec.acctd_amount_applied_to := pn_amount_applied;
  ELSE
    lr_ra_rec.acctd_amount_applied_to :=
  	ARPCURR.functional_amount(
		  amount	=> pn_amount_applied
                , currency_code	=> functional_curr
                , exchange_rate	=> pn_invoice_exchange_rate
                , precision	=> NULL
		, min_acc_unit	=> NULL );
  END IF;

  -- This is functional amount for the receipt
  IF (pc_receipt_currency_code = functional_curr) THEN
    lr_ra_rec.acctd_amount_applied_from   := pn_amount_applied;
  ELSE
    lr_ra_rec.acctd_amount_applied_from 	:=
  	ARPCURR.functional_amount(
                  amount        => pn_amount_applied
                , currency_code => functional_curr
                , exchange_rate => pn_receipt_exchange_rate
                , precision     => NULL
                , min_acc_unit  => NULL );
  END IF;

  lr_ra_rec.attribute_category := p_attribute_category;
  lr_ra_rec.attribute1   := p_attribute1;
  lr_ra_rec.attribute2   := p_attribute2;
  lr_ra_rec.attribute3   := p_attribute3;
  lr_ra_rec.attribute4   := p_attribute4;
  lr_ra_rec.attribute5   := p_attribute5;
  lr_ra_rec.attribute6   := p_attribute6;
  lr_ra_rec.attribute7   := p_attribute7;
  lr_ra_rec.attribute8   := p_attribute8;
  lr_ra_rec.attribute9   := p_attribute9;
  lr_ra_rec.attribute10  := p_attribute10;
  lr_ra_rec.attribute11  := p_attribute11;
  lr_ra_rec.attribute12  := p_attribute12;
  lr_ra_rec.attribute13  := p_attribute13;
  lr_ra_rec.attribute14  := p_attribute14;
  lr_ra_rec.attribute15  := p_attribute15;

  -- For global descriptive flexfield
  lr_ra_rec.global_attribute_category := p_global_attribute_category;
  lr_ra_rec.global_attribute1   := p_global_attribute1;
  lr_ra_rec.global_attribute2	:= p_global_attribute2;
  lr_ra_rec.global_attribute3   := p_global_attribute3;
  lr_ra_rec.global_attribute4   := p_global_attribute4;
  lr_ra_rec.global_attribute5   := p_global_attribute5;
  lr_ra_rec.global_attribute6   := p_global_attribute6;
  lr_ra_rec.global_attribute7   := p_global_attribute7;
  lr_ra_rec.global_attribute8   := p_global_attribute8;
  lr_ra_rec.global_attribute9   := p_global_attribute9;
  lr_ra_rec.global_attribute10   := p_global_attribute10;
  lr_ra_rec.global_attribute11   := p_global_attribute11;
  lr_ra_rec.global_attribute12   := p_global_attribute12;
  lr_ra_rec.global_attribute13   := p_global_attribute13;
  lr_ra_rec.global_attribute14   := p_global_attribute14;
  lr_ra_rec.global_attribute15   := p_global_attribute15;
  lr_ra_rec.global_attribute16   := p_global_attribute16;
  lr_ra_rec.global_attribute17   := p_global_attribute17;
  lr_ra_rec.global_attribute18   := p_global_attribute18;
  lr_ra_rec.global_attribute19   := p_global_attribute19;
  lr_ra_rec.global_attribute20   := p_global_attribute20;

  arp_app_pkg.update_p(lr_ra_rec);

  l_app_ra_rec := lr_ra_rec;
  --------------------------------------------------------------------
  -- Now that we have updated the APP row we need to update the UNAPP
  -- row for the cash receipt.
  --------------------------------------------------------------------
  IF ln_amount_change is not null THEN

     -- Get the receivable application id for the UNAPP row.
     select ra.receivable_application_id
     into   ln_unapp_ra_id
     from   ar_receivable_applications ra
     where  ra.cash_receipt_id = ln_cash_receipt_id
     and    ra.status = 'UNAPP';

     --Bug:4068781
     BEGIN
       arp_app_pkg.lock_p( ln_unapp_ra_id );
     EXCEPTION
       WHEN OTHERS
         THEN
           FND_MESSAGE.SET_NAME( 'FND', 'FND_LOCK_RECORD_ERROR');
           FND_MSG_PUB.Add;
           APP_EXCEPTION.raise_exception;
     END;

     -- Fetch the UNAPP row.
     arp_app_pkg.fetch_p( ln_unapp_ra_id, lr_ra_rec );

     -- Set the amount with the new value.
     lr_ra_rec.amount_applied := lr_ra_rec.amount_applied - ln_amount_change;

     -- Set the acctd amount with the new value.
     lr_ra_rec.acctd_amount_applied_from :=
     ARPCURR.functional_amount(
               amount        => lr_ra_rec.amount_applied
             , currency_code => functional_curr
             , exchange_rate => pn_receipt_exchange_rate
             , precision     => NULL
             , min_acc_unit  => NULL );

     -- Update the UNAPP row.
     arp_app_pkg.update_p(lr_ra_rec);

     -- Call MRC to replace receivable apps rows
--     ar_mrc_engine3.update_selected_transaction(
--                       pn_amount_applied,
--                       l_app_ra_rec,
--                       lr_ra_rec);
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug(   'arp_process_application.update_amount_applied()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(  '-- EXCEPTION:');
       arp_debug.debug(  'Printing procedure parameter values:');
       arp_debug.debug(  '-- pn_ra_id = '||TO_CHAR(pn_ra_id));
       arp_debug.debug(  '-- pn_amount_applied = '||TO_CHAR(pn_amount_applied));
       arp_debug.debug(  '-- pc_invoice_currency_code = '||
			pc_invoice_currency_code);
       arp_debug.debug(  '-- pn_invoice_exchange_rate = '||
			to_char(pn_invoice_exchange_rate));
       arp_debug.debug(  '-- pc_receipt_currency_code = '||
			pc_receipt_currency_code);
       arp_debug.debug(  '-- pn_receipt_exchange_rate = '||
			to_char(pn_receipt_exchange_rate));
       arp_debug.debug(  '-- pc_module_name = '||pc_module_name);
       arp_debug.debug(  '-- pc_module_version = '||pc_module_version);
    END IF;

    app_exception.raise_exception;
--    RAISE;
END update_selected_transaction;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure to validate arguments passed to reverse() procedure          |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                          |
 | ARGUMENTS  : IN:                                                          |
 |                    p_ra_id - Id of application to be reversed             |
 |                    p_reversal_gl_date - Reversal GL date                  |
 |                    p_reversal_date - Reversal Date                        |
 |                    p_module_name - Name of module that called this proc.  |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |  1/2/1995 Harri Kaukovuo	Added more messages to point out NOCOPY where
 |				the problems is (changed app_exception.raise
 |				to APP_EXCEPTION.INVALID_ARGUMENT).
 |  2/2/1996 Harri Kaukovuo	Fixed procedure to pass module name
 +===========================================================================*/
PROCEDURE validate_args(
	p_ra_id IN ar_receivable_applications.receivable_application_id%TYPE,
        p_reversal_gl_date      IN DATE,
        p_reversal_date		IN DATE,
	p_module_name		IN VARCHAR2 ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_process_application.validate_args()+' );
    END IF;

    IF (p_ra_id IS NULL)
    THEN
      APP_EXCEPTION.INVALID_ARGUMENT(
	  'ARP_PROCESS_APPLICATION'
	, 'P_RA_ID'
	, 'NULL');

    ELSIF (p_module_name IS NULL)
    THEN
      -- Let it be, let it be
      NULL;

    ELSIF (p_reversal_gl_date IS NULL)
    THEN
      APP_EXCEPTION.INVALID_ARGUMENT(
	  'ARP_PROCESS_APPLICATION'
	, 'P_REVERSAL_GL_DATE'
	, 'NULL');

    ELSIF (p_reversal_date IS NULL)
    THEN
      APP_EXCEPTION.INVALID_ARGUMENT(
	  'ARP_PROCESS_APPLICATION'
	, 'P_REVERSAL_DATE'
	, 'NULL');
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_process_application.validate_args()-' );
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
    	IF PG_DEBUG in ('Y', 'C') THEN
    	   arp_debug.debug('EXCEPTION: arp_process_application.validate_args');
    	END IF;
        RAISE;
END validate_args;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    reversal_update_ps_recs                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure is called from the standard (receipt) and credit memo   |
 |    reversal procedures.  It updates the payment schedule for both the     |
 |    source (cash receipt or on account credit) and the applied transaction.|
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 | 	ARCUPSS.pls                                                          |
 |	arp_ps_util.get_closed_dates	Calculate and get closed dates       |
 |                                 	update Payment Schedule table        |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_ra_rec - Receivables application record              |
 |                    p_reversal_gl_date - Reversal GL date                  |
 |                    p_reversal_date - Reversal Date                        |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY -                                                    |
 |  04/25/95	Ganesh Vaidee   Created
 |  1/3/1996 	Harri Kaukovuo	Added more code documentation
 |  1/4/1996	H.Kaukovuo	Added cash receipt payment schedule
 |				update.
 |  11-Mar-97   Karen Lawrance  Bug fix #464203.  Modified
 |                              modify_update_inv_ps_rec, added additional
 |                              parameter "p_app_rec_trx_type".  AR_APP is
 |                              passed into the procedure for the specific
 |                              (receipt) reversal case (called from
 |                              reverse()).  AR_CM is passed into the
 |                              procedure for the credit memo reversal
 |                              case (called from reverse_cm_app()).
 |                              modify_update_inv_ps_rec now sets
 |                              l_app_rec.trx_type to the parameter value
 |                              instead of "AR_APP" which is not correct
 |                              for the Credit Memo case.
 |                              The value of AR_APP was causing incorrect
 |                              processing in
 |                              arp_ps_util.update_reverse_actions
 |                              for the Credit Memo case.
 |  15-Mar-97   Karen Lawrance  Bug fix #493379.  Set values for lines, tax
 |                              freight and charges for the Credit Memo
 |                              case.  Should not be negative like the
 |                              applied transaction.
 |  21-Jul-97	Karen Lawrance  Release 11.
 |                              Renamed procedure from modify_update_inv_ps_rec
 |                              Cleaned up code and included some more
 |                              comments.
 |                              Included changes for cross currency,
 |                              using amount applied from for update of
 |                              receipt.
 |                              Bug fix #517496
 |                              The discount amounts apply to the transaction
 |                              not the source, changed code to null them
 |                              out NOCOPY so that they are not used in calculating
 |                              remaining amounts in the payment schedule
 |                              package.
 +===========================================================================*/
PROCEDURE reversal_update_ps_recs (
			p_ra_rec 		IN ar_receivable_applications%ROWTYPE,
                        -- Trx type is either
                        -- AR_APP meaning that it is a cash receipt reversal
                        -- AR_CM meaning that it is a credit memo reversal
                        p_app_rec_trx_type 	IN VARCHAR,
			p_reversal_gl_date 	IN DATE,
			p_reversal_date 	IN DATE) IS

l_gl_date_closed	DATE;
l_actual_date_closed	DATE;
l_app_rec 		arp_global.app_rec_type;

BEGIN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_debug.debug(   'arp_process_application.reversal_update_ps_recs()+');
     END IF;

     --------------------------------------------------------------------------
     -- Process the payment schedule row of the applied Transaction...
     --
     --------------------------------------------------------------------------

     -- Determine gl_date_closed and actual_date_closed for the transaction payment
     -- schedule.
     arp_ps_util.get_closed_dates( p_ra_rec.applied_payment_schedule_id,
                         p_reversal_gl_date,
                         p_reversal_date,
                         l_gl_date_closed,
                         l_actual_date_closed, 'INV' );

     l_app_rec.gl_date_closed     := l_gl_date_closed;
     l_app_rec.actual_date_closed := l_actual_date_closed;

     l_app_rec.trx_type 	:= p_app_rec_trx_type;

     l_app_rec.user_id 		:= FND_GLOBAL.user_id;
     l_app_rec.ps_id 		:= p_ra_rec.applied_payment_schedule_id;
     l_app_rec.user_id 		:= FND_GLOBAL.user_id;
     l_app_rec.amount_applied 	:= -p_ra_rec.amount_applied;
     l_app_rec.acctd_amount_applied := -p_ra_rec.acctd_amount_applied_to;
     l_app_rec.line_applied 	:= -p_ra_rec.line_applied;
     l_app_rec.tax_applied 	:= -p_ra_rec.tax_applied;
     l_app_rec.freight_applied 	:= -p_ra_rec.freight_applied;
     l_app_rec.receivables_charges_applied :=-p_ra_rec.receivables_charges_applied;
     --
     l_app_rec.line_ediscounted     := -p_ra_rec.line_ediscounted ;
     l_app_rec.line_uediscounted    := -p_ra_rec.line_uediscounted ;
     l_app_rec.tax_ediscounted      := -p_ra_rec.tax_ediscounted ;
     l_app_rec.tax_uediscounted     := -p_ra_rec.tax_uediscounted ;
     l_app_rec.freight_ediscounted  := -p_ra_rec.freight_ediscounted ;
     l_app_rec.freight_uediscounted := -p_ra_rec.freight_uediscounted ;
     l_app_rec.charges_ediscounted  := -p_ra_rec.charges_ediscounted ;
     l_app_rec.charges_uediscounted := -p_ra_rec.charges_uediscounted ;
     --
     l_app_rec.unearned_discount_taken :=-p_ra_rec.unearned_discount_taken;
     l_app_rec.earned_discount_taken :=-p_ra_rec.earned_discount_taken;
     l_app_rec.acctd_earned_discount_taken :=-p_ra_rec.acctd_earned_discount_taken;
     l_app_rec.acctd_unearned_discount_taken :=-p_ra_rec.acctd_unearned_discount_taken;

     --
     -- Call the payment schedule utility package to update the transaction.
     --

     /* 06-JUL-2000 J Rautiainen BR Implementation
      * Transaction payment schedule not updated for activity application  */
     IF p_ra_rec.status NOT IN ('OTHER ACC', 'ACTIVITY') THEN

       arp_ps_util.update_reverse_actions(l_app_rec, NULL, NULL);

     END IF;

     --------------------------------------------------------------------------
     -- Process the payment schedule row of the source, cash receipt or on
     -- account credit...
     --
     -- Note that amount applied from is used if not null as this indicates
     -- that it is a cross currency application.  For cross currency
     -- applications the amount applied from holds the amount allocated
     -- from the receipt.  For same currency applications, the amount applied
     -- holds both the receipt and invoice amount applied.
     --------------------------------------------------------------------------

     l_app_rec.ps_id 			:= p_ra_rec.payment_schedule_id;
     l_app_rec.amount_applied 		:= nvl(p_ra_rec.amount_applied_from, p_ra_rec.amount_applied);
     l_app_rec.acctd_amount_applied 	:= p_ra_rec.acctd_amount_applied_from;

     /*  KML 07/21/97
         Bug fix #517496
         These discount amounts apply to the transaction not the source, null them
         out NOCOPY so that they are not used in calculating remaining amounts in the
         payment schedules package.  */
     l_app_rec.unearned_discount_taken  := NULL;
     l_app_rec.earned_discount_taken    := NULL;
     l_app_rec.acctd_earned_discount_taken := NULL;
     l_app_rec.acctd_unearned_discount_taken := NULL;

     /*  KML 05/14/97
         For the Credit Memo case, the line, tax, freight and charges
         are updated for the CM payment schedule row. */
     if p_app_rec_trx_type IN ( 'AR_CM', 'AR_CM_REF') then
        l_app_rec.line_applied     := p_ra_rec.line_applied;
        l_app_rec.tax_applied      := p_ra_rec.tax_applied;
        l_app_rec.freight_applied  := p_ra_rec.freight_applied;
        l_app_rec.receivables_charges_applied :=
                                      p_ra_rec.receivables_charges_applied;

        arp_debug.debug('inv result dates (gl/act):' || l_gl_date_closed ||
                  ' / ' || l_actual_date_closed);

        arp_debug.debug('cm proposed dates (gl/act):' || p_reversal_gl_date ||
                  ' / ' || p_reversal_date);

        /* 9313440 - get actual_date_closed and gl_date_closed
           for the CM based on its own PS row */
        arp_ps_util.get_closed_dates( l_app_rec.ps_id,
                         p_reversal_gl_date,
                         p_reversal_date,
                         l_gl_date_closed,
                         l_actual_date_closed, 'CM' );

        arp_debug.debug('cm result dates (gl/act):' || l_gl_date_closed ||
                  ' / ' || l_actual_date_closed);

        l_app_rec.gl_date_closed     := l_gl_date_closed;
        l_app_rec.actual_date_closed := l_actual_date_closed;

     end if;

     /* 9475986 - If reversing a receipt, consider same logic as CM
        and only fetch dates that are actually associated with this PMT */
     if p_app_rec_trx_type = 'AR_APP'
     then
        arp_debug.debug('inv result dates (gl/act):' || l_gl_date_closed ||
                  ' / ' || l_actual_date_closed);

        arp_debug.debug('pmt proposed dates (gl/act):' || p_reversal_gl_date ||
                  ' / ' || p_reversal_date);

        arp_ps_util.get_closed_dates( l_app_rec.ps_id,
                         p_reversal_gl_date,
                         p_reversal_date,
                         l_gl_date_closed,
                         l_actual_date_closed, 'CASH' );

        arp_debug.debug('pmt result dates (gl/act):' || l_gl_date_closed ||
                  ' / ' || l_actual_date_closed);

        l_app_rec.gl_date_closed     := l_gl_date_closed;
        l_app_rec.actual_date_closed := l_actual_date_closed;
     end if;

     --
     -- Call the payment schedule utility package to update the source.
     --
     arp_ps_util.update_reverse_actions(l_app_rec, NULL, NULL);

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_debug.debug(   'arp_process_application.reversal_update_ps_recs()-');
     END IF;
EXCEPTION
     WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_debug.debug(
	'EXCEPTION: arp_process_application.reversal_update_ps_recs' );
        END IF;
        RAISE;
END reversal_update_ps_recs;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    reversal_insert_oppos_ra_recs                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure create opposing receivable application rows.            |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |	ARCIAPPS.pls                                                         |
 |      arp_app_pkg.insert_p	Table handler to insert into                 |
 |				ar_receivable_applications table.            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              p_ra_rec		Receivables application record       |
 |              p_reversal_gl_date	Reversal GL date                     |
 |              p_reversal_date		Reversal Date                        |
 |		p_module_name		Calling module name                  |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Created by Ganesh Vaidee - 04/25/95
 |  1/2/1996	Harri Kaukovuo	Commented out NOCOPY sequence fetch because
 |				table handler will take care of that.
 |				Added second ar_receivable_applications
 |				row insert to reverse UNAPP row.
 |  1/3/1996	Harri Kaukovuo	Removed WHO column update because
 |				table handler will fill those.
 |  3/13/1996	Harri Kaukovuo	BUG 344689. Reverse receipt does not
 |				work.
 |  6/21/1996	Harri Kaukovuo	Changed reverse receipt application
 |				rule from '96' to
 |				'REVERSE RECEIPT'.
 |				Bug 375636 fix.
 |  05/06/1997  Karen Lawrance  Bug fix #481761.  Fixed application
 |                              rule for Credit Memo case.  Needs to
 |                              be 75 for CM.  Added parameter
 |                              p_app_rec_trx_type so we know what
 |                              type of application it is.
 |  21-Jul-97	Karen Lawrance  Release 11.
 |                              Renamed procedure from modify_insert_ra_rec
 |                              Cleaned up code and included some more
 |                              comments.
 |                              Included changes for cross currency, setting
 |                              opposing value for amount applied from and
 |                              using amount applied from for opposing UNAPP
 |                              rows if populated.
 |  27-Oct-97	Karen Murphy	Bug #495321.  In the Receipt reversal and
 |				Credit Memo reversal code the reversal
 |				of the acctd_unearned_discount_taken was
 |				being done twice, as a result setting it back
 |				to its initial value.  Removed the second
 |				assignment.
 |  10-Aug-98   Sushama Borde   Bug# 700204. Added code to make the
 |                              gl_posted_date NULL for reversed rows.
 |                              Bug# 657464. Apply_date was being set to
 |                              reversal_date for rows created after reversal,deleted this assignment.
 | 13-Jun-00  Satheesh Nambiar  Bug 1329091 - Passing a new parameter
 |                              pay_sched_upd_yn to accounting engine
 |                              to acknowldge PS is updated.
 | 19-Dec-03 Jyoti Pandey       Bug 2729626 Unapplied Amount is zero, but the
 |                              status of receipt is 'UNAPP'.
 +===========================================================================*/
PROCEDURE reversal_insert_oppos_ra_recs (
	  p_ra_rec 		IN OUT NOCOPY AR_RECEIVABLE_APPLICATIONS%ROWTYPE
        , p_app_rec_trx_type    IN VARCHAR
	, p_reversal_gl_date 	DATE
	, p_reversal_date 	DATE
	, p_module_name		IN VARCHAR2
 	, p_called_from         IN VARCHAR2 DEFAULT NULL
        , p_rec_app_id          OUT NOCOPY NUMBER) IS  /* jrautiai BR implementation */

l_ra_id 		NUMBER;
l_ra_app_id 		NUMBER;

l_rma_unapplied_ccid	NUMBER;
l_rma_earned_ccid	NUMBER;
l_rma_unearned_ccid	NUMBER;
l_payment_schedule_id	NUMBER;

l_amount_due_remaining	NUMBER;
l_amount_due_original	NUMBER;
l_on_account_total      NUMBER;   /*Added for Bug 2729626 */

-- This is used to update cash receipt status after unapply.
l_cr_rec		AR_CASH_RECEIPTS%ROWTYPE;
l_ae_doc_rec            ae_doc_rec_type;


l_gt_id                 NUMBER := 0;
l_llca_flag             VARCHAR2(1) := 'N';
l_prorated_line         NUMBER;
l_prorated_tax          NUMBER;
l_called_from_api       VARCHAR2(1);

  --Bug#2750340
  l_xla_ev_rec      arp_xla_events.xla_events_type;
  l_xla_doc_table   VARCHAR2(20);

  -- Bug 7241111
  l_llca_exist_rev varchar(1) := 'N';
  l_llca_exist     varchar(1) := 'N';

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug(   'arp_process_application.reversal_insert_oppos_ra_recs()+');
  END IF;

  -----------------------------------------------------------------
  -- Handle the Receipt reversal and Credit Memo reversal cases.
  --
  -- This code is called from the reverse receipt procedure.
  -- The reversal of on account credit memos also calls this code.
  --
  -- Reason being ...
  -- For Cash Receipt reversals we go through and create opposing
  -- rows for each record in receivable applications.  The receipt
  -- reversal procedure has a cursor that selects all receivable
  -- application rows for the receipt, then calls the reverse
  -- procedure for each row.
  --
  -- For Credit Memo applications, we don't have UNAPP rows.  So
  -- all we need to do is create an opposing APP row.  As this
  -- piece of code creates an opposing row for the provided
  -- receivable applications record, this is why it is being used
  -- for Credit Memos as well.
  -----------------------------------------------------------------
  IF (UPPER(p_module_name) = 'ARREREVB')
  THEN
    -- Setup the record structure before creating the opposing record.
    --
    p_ra_rec.cash_receipt_history_id := NULL;
    p_ra_rec.amount_applied := -p_ra_rec.amount_applied;
    p_ra_rec.amount_applied_from := -p_ra_rec.amount_applied_from;
    p_ra_rec.acctd_amount_applied_to := -p_ra_rec.acctd_amount_applied_to;
    p_ra_rec.acctd_amount_applied_from := -p_ra_rec.acctd_amount_applied_from;

    p_ra_rec.display := 'N';
    p_ra_rec.line_applied := -p_ra_rec.line_applied;
    p_ra_rec.tax_applied := -p_ra_rec.tax_applied;
    p_ra_rec.freight_applied := -p_ra_rec.freight_applied;
    p_ra_rec.receivables_charges_applied :=-p_ra_rec.receivables_charges_applied;
    --
    p_ra_rec.line_ediscounted     := -p_ra_rec.line_ediscounted ;
    p_ra_rec.line_uediscounted    := -p_ra_rec.line_uediscounted ;
    p_ra_rec.tax_ediscounted      := -p_ra_rec.tax_ediscounted ;
    p_ra_rec.tax_uediscounted     := -p_ra_rec.tax_uediscounted ;
    p_ra_rec.freight_ediscounted  := -p_ra_rec.freight_ediscounted ;
    p_ra_rec.freight_uediscounted := -p_ra_rec.freight_uediscounted ;
    p_ra_rec.charges_ediscounted  := -p_ra_rec.charges_ediscounted ;
    p_ra_rec.charges_uediscounted := -p_ra_rec.charges_uediscounted ;
    --
    -- Application Rule needs to be 96 for standard Applications
    -- and 75 for Credit Memo Applications.
    -- Some reports rely on the application rule being set to
    -- certain values .. so be careful changing them!
    if p_app_rec_trx_type = 'AR_CM' then
       p_ra_rec.application_rule := '75';
    else
       p_ra_rec.application_rule := '96';
    end if;
    --
    -- This will be the ID of ARCEAPPB.pls and this part of program
    p_ra_rec.program_id		:= -100100;
    p_ra_rec.earned_discount_taken := -p_ra_rec.earned_discount_taken;
    p_ra_rec.unearned_discount_taken := -p_ra_rec.unearned_discount_taken;
    p_ra_rec.acctd_earned_discount_taken :=-p_ra_rec.acctd_earned_discount_taken;
    p_ra_rec.acctd_unearned_discount_taken :=-p_ra_rec.acctd_unearned_discount_taken;
    p_ra_rec.posting_control_id := -3;
    p_ra_rec.gl_posted_date := NULL;

/* Bugfix 2187105 */
    IF p_ra_rec.gl_date < p_reversal_gl_date THEN
        p_ra_rec.gl_date := p_reversal_gl_date;
    END IF;

    p_ra_rec.reversal_gl_date := p_ra_rec.gl_date;

    IF p_ra_rec.status = 'UNAPP' THEN
      p_ra_rec.receivables_trx_id      := NULL;
      p_ra_rec.link_to_customer_trx_id := NULL;
    END IF;

    ---------------------------------------------------
    -- Create the opposing receivable application row.
    --
    ---------------------------------------------------
    arp_app_pkg.insert_p( p_ra_rec, l_ra_id );

    -- Bug 7241111 Updating the ar_activity_details reversal record with RA IDs

    IF p_ra_rec.status = 'APP' or  p_ra_rec.application_type = 'CASH' THEN

     begin
       select 'Y' into l_llca_exist
       from ar_activity_details
       where cash_receipt_id = p_ra_rec.cash_receipt_id
	   and source_id = p_ra_rec.receivable_application_id
	   and source_table = 'RA'
	   and nvl(CURRENT_ACTIVITY_FLAG,'Y') = 'R';

     exception
       when too_many_rows then
          l_llca_exist := 'Y';
       when no_data_found then
          l_llca_exist := 'N';
       when others then
          l_llca_exist := 'N';
      end;

	     IF PG_DEBUG in ('Y', 'C') THEN
	       arp_debug.debug('Total rows selected under activity details: ' || SQL%ROWCOUNT);
	     END IF;

       IF NVL(l_llca_exist,'N') = 'Y' THEN


	       update ar_activity_details
		set source_table = 'RA',
		    source_id = l_ra_id,
		    CURRENT_ACTIVITY_FLAG = 'N',
		     CREATED_BY = NVL(FND_GLOBAL.user_id,-1),
		    CREATION_DATE = SYSDATE ,
		    LAST_UPDATE_LOGIN = NVL( arp_standard.profile.last_update_login,
			       p_ra_rec.last_update_login ),
		    LAST_UPDATE_DATE = SYSDATE ,
		    LAST_UPDATED_BY = NVL(FND_GLOBAL.user_id,-1)
		where cash_receipt_id = p_ra_rec.cash_receipt_id
		   and source_id = p_ra_rec.receivable_application_id
		   and source_table = 'RA'
		   and nvl(CURRENT_ACTIVITY_FLAG,'Y') = 'R';

	     IF PG_DEBUG in ('Y', 'C') THEN
	       arp_debug.debug('Total rows updated under activity details: ' || SQL%ROWCOUNT);
	     END IF;
      END IF;

   END IF;

    IF l_ra_id IS NOT NULL THEN
    l_xla_ev_rec.xla_from_doc_id := l_ra_id;
    l_xla_ev_rec.xla_to_doc_id   := l_ra_id;
    l_xla_ev_rec.xla_mode        := 'O';
    l_xla_ev_rec.xla_call        := 'B';
    l_xla_ev_rec.xla_doc_table := 'APP';
    ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(  'p_ra_rec.rec_app_id :'||p_ra_rec.receivable_application_id);
       arp_debug.debug(  'l_ra_id 1 :'||l_ra_id);
    END IF;
   --apandit
   --Bug : 2641517
   IF p_ra_rec.status in ('APP', 'ACTIVITY') THEN
    p_rec_app_id := l_ra_id;
   END IF;

   --
   --Release 11.5 VAT changes, reverse accounting associated with old
   --application and create new distributions with new application id
   --
    /* 14-APR-2000 jrautiai BR implementation
       If the row is not postable, accounting is not created */

    IF NVL(p_ra_rec.postable,'Y') = 'Y'
    THEN
      IF p_ra_rec.application_type = 'CASH'
      THEN
         l_ae_doc_rec.document_type             := 'RECEIPT';
         l_ae_doc_rec.document_id               := p_ra_rec.cash_receipt_id;

      /* 4566510 - Call etax to reverse discounts that
           have impacted recoverable tax

         NOTE:  We do not use the prorated amounts that are
         returned.  In theory, the reversal should be identical
         to the original application */
         IF nvl(p_ra_rec.earned_discount_taken, 0) <> 0
         THEN
            arp_etax_util.prorate_recoverable(
                      p_adj_id         => p_ra_rec.cash_receipt_id,
                      p_target_id      => p_ra_rec.applied_customer_trx_id,
                      p_target_line_id => null,
                      p_amount         => -1 *
                         (p_ra_rec.line_ediscounted +
                          p_ra_rec.tax_ediscounted),
                      p_apply_date     => p_ra_rec.gl_date,
                      p_mode           => 'UNAPP_ED',
                      p_upd_adj_and_ps => 'N',
                      p_gt_id          => l_gt_id,
                      p_prorated_line  => l_prorated_line,
                      p_prorated_tax   => l_prorated_tax,
                      p_ra_app_id      => l_ra_id);
         END IF;

         IF nvl(p_ra_rec.unearned_discount_taken, 0) <> 0
         THEN
           arp_etax_util.prorate_recoverable(
                      p_adj_id         => p_ra_rec.cash_receipt_id,
                      p_target_id      => p_ra_rec.applied_customer_trx_id,
                      p_target_line_id => null,
                      p_amount         => -1 *
                         (p_ra_rec.line_uediscounted +
                          p_ra_rec.tax_uediscounted),
                      p_apply_date     => p_ra_rec.gl_date,
                      p_mode           => 'UNAPP_UED',
                      p_upd_adj_and_ps => 'N',
                      p_gt_id          => l_gt_id,
                      p_prorated_line  => l_prorated_line,
                      p_prorated_tax   => l_prorated_tax,
                      p_ra_app_id      => l_ra_id);
         END IF;

      ELSE
         l_ae_doc_rec.document_type             := 'CREDIT_MEMO';
         l_ae_doc_rec.document_id               := p_ra_rec.customer_trx_id;
      END IF;

      l_ae_doc_rec.accounting_entity_level   := 'ONE';
      l_ae_doc_rec.source_table              := 'RA';
      l_ae_doc_rec.source_id                 := l_ra_id;                            --new id of reversal record
      l_ae_doc_rec.source_id_old             := p_ra_rec.receivable_application_id; --old record used for reversal
      l_ae_doc_rec.other_flag                := 'REVERSE';

    --Bug 1329091 - PS is updated before Accounting Engine Call
      l_ae_doc_rec.pay_sched_upd_yn := 'Y';

      IF l_gt_id <> 0
      THEN
        l_llca_flag := 'Y';

        /* 4607809 - distribute recoverable entries before acct_main call */
        arp_etax_util.distribute_recoverable(l_ra_id, l_gt_id);
      END IF;

      arp_acct_main.Create_Acct_Entry(l_ae_doc_rec,
                                      NULL,
                                      l_llca_flag,
                                      l_gt_id);

    END IF;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_debug.debug(   'arp_process_application.reversal_insert_oppos_ra_recs()-');
      END IF;
      return;

  END IF;

  --------------------------------------------------------------
  -- This code caters for the standard case, creating opposing
  -- UNAPP and APP rows.
  --
  -- For example:
  -- Receipt
  -- 	100.00	UNAPP
  -- Apply to transaction
  --   -60.00	UNAPP
  -- 	60.00	APP
  -- Create On Account
  --   -40.00	UNAPP
  -- 	40.00	ACC
  -- Reverse/unapply applications
  --   -60.00   APP
  --    60.00   UNAPP
  --   -40.00   ACC
  --    40.00   UNAPP
  --
  --------------------------------------------------------------

  ----------------------------------------------------------
  -- Reverse the corresponding application (APP or ACC) row
  --
  ----------------------------------------------------------

  -- Setup the record structure before creating the opposing record.
  --
  p_ra_rec.amount_applied 		:= -p_ra_rec.amount_applied;
  p_ra_rec.amount_applied_from 		:= -p_ra_rec.amount_applied_from;
  p_ra_rec.acctd_amount_applied_from 	:= -p_ra_rec.acctd_amount_applied_from;
  p_ra_rec.acctd_amount_applied_to 	:= -p_ra_rec.acctd_amount_applied_to;
  p_ra_rec.line_applied 		:= -p_ra_rec.line_applied;
  p_ra_rec.tax_applied 			:= -p_ra_rec.tax_applied;
  p_ra_rec.freight_applied 		:= -p_ra_rec.freight_applied;
  p_ra_rec.receivables_charges_applied  := -p_ra_rec.receivables_charges_applied;

  p_ra_rec.line_ediscounted     := -p_ra_rec.line_ediscounted ;
  p_ra_rec.line_uediscounted    := -p_ra_rec.line_uediscounted ;
  p_ra_rec.tax_ediscounted      := -p_ra_rec.tax_ediscounted ;
  p_ra_rec.tax_uediscounted     := -p_ra_rec.tax_uediscounted ;
  p_ra_rec.freight_ediscounted  := -p_ra_rec.freight_ediscounted ;
  p_ra_rec.freight_uediscounted := -p_ra_rec.freight_uediscounted ;
  p_ra_rec.charges_ediscounted  := -p_ra_rec.charges_ediscounted ;
  p_ra_rec.charges_uediscounted := -p_ra_rec.charges_uediscounted ;
  p_ra_rec.earned_discount_taken 	:= -NVL(p_ra_rec.earned_discount_taken,0);
  p_ra_rec.unearned_discount_taken 	:= -NVL(p_ra_rec.unearned_discount_taken,0);
  p_ra_rec.acctd_earned_discount_taken  := -NVL(p_ra_rec.acctd_earned_discount_taken,0);
  p_ra_rec.acctd_unearned_discount_taken := -NVL(p_ra_rec.acctd_unearned_discount_taken,0);

  p_ra_rec.gl_date 			:= p_reversal_gl_date;
  p_ra_rec.reversal_gl_date 		:= p_reversal_gl_date;

  p_ra_rec.application_rule		:= '90.3';
  p_ra_rec.program_id			:= -100101;

  p_ra_rec.cash_receipt_history_id 	:= NULL;
  p_ra_rec.display 			:= 'N';
  p_ra_rec.posting_control_id 		:= -3;
  p_ra_rec.gl_posted_date               := NULL;

  -- Call the table handler to insert the APP or ACC row.
  arp_app_pkg.insert_p(
	  p_ra_rec		-- IN
	, l_ra_id		-- OUT NOCOPY
  	);

  -- Bug 7241111 Updating the ar_activity_details reversal record with RA IDs

   IF p_ra_rec.status = 'APP' or  p_ra_rec.application_type = 'CASH' THEN

      begin
             select 'Y' into l_llca_exist
	       from ar_activity_details
	       where cash_receipt_id = p_ra_rec.cash_receipt_id
		   and source_id = p_ra_rec.receivable_application_id
		   and source_table = 'RA';
      exception
        when too_many_rows then
          l_llca_exist := 'Y';
        when no_data_found then
          l_llca_exist := 'N';
        when others then
          l_llca_exist := 'N';
      end;


      IF NVL(l_llca_exist,'N') = 'Y' THEN

         -- To handle offset rows

	     --{
	         AR_ACTIVITY_DETAILS_PKG.Chk_offset_Row(l_ra_id,p_ra_rec.receivable_application_id,p_ra_rec.cash_receipt_id);

             --}

      END IF;


       begin
	       select 'Y' into l_llca_exist_rev
	       from ar_activity_details
	       where cash_receipt_id = p_ra_rec.cash_receipt_id
		   and source_id = p_ra_rec.receivable_application_id
		   and source_table = 'RA'
		   and nvl(CURRENT_ACTIVITY_FLAG,'Y') = 'R';
      exception
        when too_many_rows then
          l_llca_exist_rev := 'Y';
        when no_data_found then
          l_llca_exist_rev := 'N';
        when others then
          l_llca_exist_rev := 'N';
      end;

	     IF PG_DEBUG in ('Y', 'C') THEN
	       arp_debug.debug('Total rows selected under activity details: ' || SQL%ROWCOUNT);
	     END IF;

       IF NVL(l_llca_exist_rev,'N') = 'Y' THEN

               update ar_activity_details
		set source_table = 'RA',
		    source_id = l_ra_id,
		    CURRENT_ACTIVITY_FLAG = 'N',
		    CREATED_BY = NVL(FND_GLOBAL.user_id,-1),
		    CREATION_DATE = SYSDATE ,
		    LAST_UPDATE_LOGIN = NVL( arp_standard.profile.last_update_login,
			       p_ra_rec.last_update_login ),
		    LAST_UPDATE_DATE = SYSDATE ,
		    LAST_UPDATED_BY = NVL(FND_GLOBAL.user_id,-1)
		where cash_receipt_id = p_ra_rec.cash_receipt_id
		   and source_id = p_ra_rec.receivable_application_id
		   and source_table = 'RA'
		   and nvl(CURRENT_ACTIVITY_FLAG,'Y') = 'R';

	     IF PG_DEBUG in ('Y', 'C') THEN
	       arp_debug.debug('Total rows updated under activity details: ' || SQL%ROWCOUNT);
	     END IF;

     END IF;
  END IF;
 --bug 6660834
 IF nvl(p_called_from,'NONE') NOT IN ('AUTORECAPI','AUTORECAPI2', 'CUSTRECAPIBULK') THEN
   IF l_ra_id IS NOT NULL THEN
     l_xla_ev_rec.xla_from_doc_id := l_ra_id;
     l_xla_ev_rec.xla_to_doc_id   := l_ra_id;
     l_xla_ev_rec.xla_mode        := 'O';
     l_xla_ev_rec.xla_call        := 'B';
     l_xla_ev_rec.xla_doc_table := 'APP';
     ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
   END IF;
 END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(  'p_ra_rec.rec_app_id :'||p_ra_rec.receivable_application_id);
       arp_debug.debug(  'l_ra_id 2 :'||l_ra_id);
    END IF;

   --apandit
   --Bug : 2641517
   IF p_ra_rec.status in ('APP', 'ACTIVITY') THEN
    p_rec_app_id := l_ra_id;
   END IF;

   --
   --Release 11.5 VAT changes, reverse accounting associated with old
   --application and create new distributions with new application id
   --

  /* 4566510 - Reverse discounts via etax */
  IF p_ra_rec.application_type = 'CASH' THEN

      /* NOTE:  We do not use the prorated amounts that are
         returned.  In theory, the reversal should be identical
         to the original application */
     IF nvl(p_ra_rec.earned_discount_taken, 0) <> 0
     THEN
            arp_etax_util.prorate_recoverable(
                      p_adj_id         => p_ra_rec.cash_receipt_id,
                      p_target_id      => p_ra_rec.applied_customer_trx_id,
                      p_target_line_id => null,
                      p_amount         => -1 *
                        (p_ra_rec.line_ediscounted +
                         p_ra_rec.tax_ediscounted),
                      p_apply_date     => p_ra_rec.gl_date,
                      p_mode           => 'UNAPP_ED',
                      p_upd_adj_and_ps => 'N',
                      p_gt_id          => l_gt_id,
                      p_prorated_line  => l_prorated_line,
                      p_prorated_tax   => l_prorated_tax,
                      p_ra_app_id      => l_ra_id);
     END IF;

     IF nvl(p_ra_rec.unearned_discount_taken, 0) <> 0
     THEN
           arp_etax_util.prorate_recoverable(
                      p_adj_id         => p_ra_rec.cash_receipt_id,
                      p_target_id      => p_ra_rec.applied_customer_trx_id,
                      p_target_line_id => null,
                      p_amount         => -1 *
                        (p_ra_rec.line_uediscounted +
                         p_ra_rec.tax_uediscounted),
                      p_apply_date     => p_ra_rec.gl_date,
                      p_mode           => 'UNAPP_UED',
                      p_upd_adj_and_ps => 'N',
                      p_gt_id          => l_gt_id,
                      p_prorated_line  => l_prorated_line,
                      p_prorated_tax   => l_prorated_tax,
                      p_ra_app_id      => l_ra_id);
     END IF;

  END IF;

  /* 14-APR-2000 jrautiai BR implementation
     If the row is not postable, accounting is not created */

  IF NVL(p_ra_rec.postable,'Y') = 'Y' THEN -- jrautiai postable

    l_ae_doc_rec.document_type             := 'RECEIPT';
    l_ae_doc_rec.document_id               := p_ra_rec.cash_receipt_id;
    l_ae_doc_rec.accounting_entity_level   := 'ONE';
    l_ae_doc_rec.source_table              := 'RA';
    l_ae_doc_rec.source_id                 := l_ra_id;                            --new id of reversal record
    l_ae_doc_rec.source_id_old             := p_ra_rec.receivable_application_id; --old record used for reversal
    l_ae_doc_rec.other_flag                := 'REVERSE';
    l_ae_doc_rec.event                     := p_called_from; /* 28-SEP-2000 J Rautiainen, BR Implementation */

  --Bug 1329091 - PS is updated before Accounting Engine Call
    l_ae_doc_rec.pay_sched_upd_yn := 'Y';

    /* 4566510 - set llca_flag correctly */
    IF l_gt_id <> 0
    THEN
      l_llca_flag := 'Y';

      /* 4607809 - distribute recoverable entries before acct_main call */
      arp_etax_util.distribute_recoverable(l_ra_id, l_gt_id);
    END IF;

    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec,
                                    NULL,
                                    l_llca_flag,
                                    l_gt_id);

    l_ra_app_id := l_ra_id; --store application id for pairing

  END IF;
  -----------------------------------------
  -- Reverse the corresponding UNAPP row
  --
  -----------------------------------------

  -- Setup the record structure before creating the opposing record.
  --

  -- First get cash receipt GL accounts and amount due information
  -- to update cash receipt status if needed.
    SELECT
	  rma.unapplied_ccid
        , ed.code_combination_id    /* earned_ccid */
        , uned.code_combination_id  /* unearned_ccid */
        , ps.payment_schedule_id
	, ps.amount_due_remaining
	, ps.amount_due_original
    INTO
	  l_rma_unapplied_ccid
        , l_rma_earned_ccid
        , l_rma_unearned_ccid
        , l_payment_schedule_id
	, l_amount_due_remaining
	, l_amount_due_original
    FROM
	  ar_receipt_method_accounts	rma
	, ar_payment_schedules		ps
	, ar_cash_receipts		cr
        , ar_receivables_trx            ed
        , ar_receivables_trx            uned
    WHERE
	cr.cash_receipt_id		= p_ra_rec.cash_receipt_id
	AND cr.cash_receipt_id 		= ps.cash_receipt_id
	AND rma.receipt_method_id 	= cr.receipt_method_id
	AND rma.remit_bank_acct_use_id  = cr.remit_bank_acct_use_id
        AND rma.edisc_receivables_trx_id   = ed.receivables_trx_id (+)
        AND rma.unedisc_receivables_trx_id   = uned.receivables_trx_id (+);

  -- Remember that record fields have values already.
  -- They were fetched from AR_RECEIVABLE_APPLICATIONS table
  -- earlier in fetch_p(), in reverse procedure.

  -- Note that amount applied from is used if not null as this indicates
  -- that it is a cross currency application.  For cross currency
  -- applications the amount applied from holds the amount allocated
  -- from the receipt.  For same currency applications, the amount applied
  -- holds both the receipt and invoice amount applied.
  --
  p_ra_rec.amount_applied 		:= nvl(-p_ra_rec.amount_applied_from, -p_ra_rec.amount_applied);
  p_ra_rec.amount_applied_from 		:= -p_ra_rec.amount_applied_from;
  p_ra_rec.acctd_amount_applied_from 	:= -p_ra_rec.acctd_amount_applied_from;
  p_ra_rec.trans_to_receipt_rate	:= NULL;
  p_ra_rec.acctd_amount_applied_to 	:= NULL;
  p_ra_rec.line_applied 		:= NULL;
  p_ra_rec.tax_applied 			:= NULL;
  p_ra_rec.freight_applied 		:= NULL;
  p_ra_rec.receivables_charges_applied 	:= NULL;
  p_ra_rec.earned_discount_taken 	:= NULL;
  p_ra_rec.unearned_discount_taken 	:= NULL;
  p_ra_rec.acctd_earned_discount_taken 	:= NULL;
  p_ra_rec.acctd_unearned_discount_taken := NULL;
  p_ra_rec.line_ediscounted     := NULL;
  p_ra_rec.line_uediscounted    := NULL;
  p_ra_rec.tax_ediscounted      := NULL;
  p_ra_rec.tax_uediscounted     := NULL;
  p_ra_rec.freight_ediscounted  := NULL;
  p_ra_rec.freight_uediscounted := NULL;
  p_ra_rec.charges_ediscounted  := NULL;
  p_ra_rec.charges_uediscounted := NULL;

  -- Dates

  p_ra_rec.gl_date 			:= p_reversal_gl_date;

 /* Bug fix 2877224
    The new UNAPP record created while reversal of the application should
    have a value for the reversal_gl_date
  p_ra_rec.reversal_gl_date             := NULL; */
  p_ra_rec.reversal_gl_date             := p_reversal_gl_date;

  -- GL accounts
  p_ra_rec.earned_discount_ccid		:= l_rma_earned_ccid;
  p_ra_rec.unearned_discount_ccid	:= l_rma_unearned_ccid;
  p_ra_rec.code_combination_id		:= l_rma_unapplied_ccid;

  -- Other misc stuff. Application rule is for debugging which select
  -- statement created that application row.
  -- p_ra_rec.application_rule 		:= 'REVERSE APPLICATION2';
  p_ra_rec.application_rule		:= '90.4';
  p_ra_rec.program_id			:= -100102;

  -- This means that row is not yet posted to GL
  p_ra_rec.posting_control_id 		:= -3;
  p_ra_rec.gl_posted_date               := NULL;

  /* 14-APR-2000 jrautiai BR implementation
   * The new UNAPP record is only postable if the unapplied record
   *  was postable. In case of Short Term debt application the UNAPP rows are not postable */

  IF NVL(p_ra_rec.applied_payment_schedule_id,0) <> -2 AND unapp_postable(p_ra_rec.applied_customer_trx_id,p_ra_rec.applied_payment_schedule_id) THEN
    p_ra_rec.postable			:= 'Y';
  ELSE
    p_ra_rec.postable			:= 'N';
  END IF;

  p_ra_rec.receivables_trx_id      := NULL;
  p_ra_rec.link_to_customer_trx_id := NULL;

  p_ra_rec.cash_receipt_history_id 	:= NULL;
  p_ra_rec.display 			:= 'N';
  p_ra_rec.status 			:= 'UNAPP';
  p_ra_rec.include_in_accumulation := 'N'; -- Bug 6924942
  p_ra_rec.application_type 		:= 'CASH';
  p_ra_rec.payment_schedule_id		:= l_payment_schedule_id;

  -- NULL out NOCOPY applied information, because this is an UNAPP row
  p_ra_rec.applied_payment_schedule_id	:= NULL;
  p_ra_rec.applied_customer_trx_id	:= NULL;
  p_ra_rec.applied_customer_trx_line_id	:= NULL;

/* DEBUG */
arp_debug.debug(' l_ra_id = ' || l_ra_id);
l_ra_id := NULL;

  -- Call the table handler to insert the UNAPP row.
        arp_app_pkg.insert_p(
	  p_ra_rec		-- IN
	, l_ra_id		-- OUT NOCOPY
	);
  --Bug 6660834
   IF nvl(p_called_from,'NONE') NOT IN ('AUTORECAPI','AUTORECAPI2','CUSTRECAPIBULK') THEN
      IF l_ra_id IS NOT NULL THEN
       l_xla_ev_rec.xla_from_doc_id := l_ra_id;
       l_xla_ev_rec.xla_to_doc_id   := l_ra_id;
       l_xla_ev_rec.xla_mode        := 'O';
       l_xla_ev_rec.xla_call        := 'B';
       l_xla_ev_rec.xla_doc_table := 'APP';
       ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
      END IF;
   END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(  'p_ra_rec.rec_app_id :'||p_ra_rec.receivable_application_id);
       arp_debug.debug(  'l_ra_id 3 :'||l_ra_id);
    END IF;

   --
   --Release 11.5 VAT changes, create UNAPP paired record
   --
  /* 14-APR-2000 jrautiai BR implementation
     If the row is not postable, accounting is not created */

  IF NVL(p_ra_rec.postable,'Y') = 'Y' THEN -- jrautiai postable

    l_ae_doc_rec.document_type             := 'RECEIPT';
    l_ae_doc_rec.document_id               := p_ra_rec.cash_receipt_id;
    l_ae_doc_rec.accounting_entity_level   := 'ONE';
    l_ae_doc_rec.source_table              := 'RA';
    l_ae_doc_rec.source_id                 := l_ra_id;     --new id of reversal record
    l_ae_doc_rec.source_id_old             := l_ra_app_id; --application id used for pairing UNAPP
    l_ae_doc_rec.other_flag                := 'PAIR';
    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

    /* Bug fix 4910860 */
    IF nvl(p_module_name,'RAPI') = 'RAPI' THEN
       l_called_from_api := 'Y';
    ELSE
      l_called_from_api := 'N';
    END IF;
    arp_balance_check.Check_Appln_Balance(l_ra_id,
                                          l_ra_app_id,
                                          NULL,
                                          l_called_from_api);

  END IF;
  -------------------------------------------------------------------------
  -- Update receipt status if necessary. This means that if receipt
  -- was earliers applied and after unapply does not have any applications
  -- the status must be changed to 'Unapplied'.
  --
  -------------------------------------------------------------------------

  -- First, set ar_cash_receipt record values to dummy
  -- This is to distinguish between updateable NULL and NULL value (dummy)
  -- which means that column is not to be updated.
  arp_cash_receipts_pkg.set_to_dummy(l_cr_rec);

  -- Cash receipt must be fully applied in order to set the status
  -- to 'Applied'.
  /*For bug2729626 on-account amount also should be
  considered of determining status */

  select nvl(sum(ra.amount_applied),0)
  into   l_on_account_total
  from   ar_receivable_applications ra
  where  ra.cash_receipt_id = p_ra_rec.cash_receipt_id
  and    ra.status IN ('ACC','OTHER ACC');

  IF (l_amount_due_remaining + l_on_account_total < 0)
  THEN
    l_cr_rec.cash_receipt_id	:= p_ra_rec.cash_receipt_id;
    l_cr_rec.status 		:= 'UNAPP';
  ELSE
    l_cr_rec.cash_receipt_id	:= p_ra_rec.cash_receipt_id;
    l_cr_rec.status 		:= 'APP';
  END IF;

  -- Update cash receipt status
  arp_cash_receipts_pkg.update_p(l_cr_rec, p_ra_rec.cash_receipt_id);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug(   'arp_process_application.reversal_insert_oppos_ra_recs()-');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(
    'EXCEPTION: arp_process_application.reversal_insert_oppos_ra_recs');
    END IF;
    RAISE;

END reversal_insert_oppos_ra_recs;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    reversal_update_old_ra_rec                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the receivable application row that is being    |
 |    reversed, by setting the reversal dates and setting display to 'N'.    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |      arp_app_pkg.update_p - table handler to update                       |
 |                                          ar_receivable_applications table |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_ra_rec - Receivables application record              |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |
 |  21-Jul-97	Karen Lawrance  Release 11.
 |                              Renamed procedure from modify_update_old_ra_rec
 +===========================================================================*/
PROCEDURE reversal_update_old_ra_rec( p_reversal_gl_date DATE,
                       p_ra_rec IN OUT NOCOPY ar_receivable_applications%ROWTYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'arp_process_application.reversal_update_old_ra_rec()+' );
    END IF;
    --
    p_ra_rec.display := 'N';

   IF p_reversal_gl_date > p_ra_rec.gl_date then
    p_ra_rec.reversal_gl_date := p_reversal_gl_date;
   ELSE
    p_ra_rec.reversal_gl_date := p_ra_rec.gl_date;
   END IF;
    --
    arp_app_pkg.update_p( p_ra_rec );
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'arp_process_application.reversal_update_old_ra_rec()-' );
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug(
		'EXCEPTION: arp_process_application.reversal_update_old_ra_rec' );
              END IF;
              RAISE;
END reversal_update_old_ra_rec;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    check_reversable                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function checks -                                                 |
 |        1. Checks if the application has no actions, If so returns         |
 |           TRUE                                                            |
 |        2. CB should have no activity, If so fetch all customer_trx_ids    |
 |           and call 'validate_cb_reversal'                                 |
 |        3  Check  to see deletion of application  actions will not make    |
 |           the amount due remaining of the debit item go negative.         |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED -                                 |
 |        arp_process_chargeback.validate_cb_reversal - Check if a charge    |
 |                       back has any activity associated with it            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_ra_id - Id of application to be reversed             |
 |                    p_module_name - Name of module that called this proc.  |
 |                    p_module_name - Version of the module that called this |
 |                                    function                               |
 |              OUT:                                                         |
 |                    p_adj_id - Adjustment Id of inserted ar_adjustments row|
 |                                                                           |
 | RETURNS    : FALSE or TRUE                                                |
 |                                                                           |
 | NOTES - This could be a public function later                             |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |   04-MAY-95  G Vaidees      Added A check in validate_cb_reversal to      |
 |                             check for remaining balance only if adjustment|
 |                             exists for the application                    |
 |   10-MAY-95  G Vaidees      Added Over application check                  |
 |   12-SEP-00  skoukunt       Fix 1387071, Added (( l_bal - l_adj_amount +  |
 |                             l_pmt + l_edisc + l_udisc ) <> 0)             |
 |
 |   02-Jun-01  S.Nambiar      Bug 1808020 -Modified the routine to handle   |
 |                             Activity and receipt chargeback                                                                             |
 +===========================================================================*/
FUNCTION check_reversable (
	p_ra_id  IN ar_receivable_applications.receivable_application_id%TYPE,
        p_module_name    IN VARCHAR2,
        p_module_version IN VARCHAR2 ) RETURN BOOLEAN IS
    l_ps_id		ar_payment_schedules.payment_schedule_id%TYPE;
    l_ass_cr_id	 	ar_adjustments.associated_cash_receipt_id%TYPE;
    l_ct_id             ra_customer_trx.customer_trx_id%TYPE;
    l_adj_amt		NUMBER;
    l_pend_amt		NUMBER;
    l_pmt		NUMBER;
    l_edisc		NUMBER;
    l_udisc		NUMBER;
    l_bal		NUMBER;
    l_bal_org           NUMBER;
    l_status		VARCHAR2(30);
    l_rec_app_id	NUMBER;
    l_remaining_sign    NUMBER;
    l_adj_amount	NUMBER;
    --
    l_cb_count		NUMBER  DEFAULT 0;
    l_over_appln_flag	CHAR(1);
    l_ra_rec            ar_receivable_applications%ROWTYPE;
    l_dummy		NUMBER;
BEGIN
--  validate_args_appdel( p_ra_id );
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'arp_process_application.check_reversable()+' );
    END IF;
    --
    arp_app_pkg.fetch_p(p_ra_id, l_ra_rec );

    IF (SIGN(l_ra_rec.applied_payment_schedule_id) <> -1) THEN

    BEGIN
        SELECT ra.cash_receipt_id,
	       ra.applied_payment_schedule_id,
   	       ra.amount_applied,
	       nvl( ra.earned_discount_taken, 0 ),
   	       nvl( ra.unearned_discount_taken, 0 ),
	       nvl( ps.amount_due_remaining, 0 ),
	       ra.status,
	       ctt.allow_overapplication_flag,
               nvl(ps.amount_due_original, 0)
        INTO   l_ass_cr_id,
	       l_ps_id,
	       l_pmt,
	       l_edisc,
	       l_udisc,
	       l_bal,
	       l_status,
	       l_over_appln_flag,
               l_bal_org
        FROM   ar_receivable_applications ra,
               ar_payment_schedules ps,
	       ra_cust_trx_types ctt
        WHERE  ra.receivable_application_id = p_ra_id
        AND    ps.payment_schedule_id(+) = ra.applied_payment_schedule_id
	AND    ctt.cust_trx_type_id = ps.cust_trx_type_id;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'arp_process_application.check_reversable()+' );
    END IF;
    EXCEPTION
	WHEN NO_DATA_FOUND THEN
    	     IF PG_DEBUG in ('Y', 'C') THEN
    	        arp_debug.debug(   'No data found in PS and RA table - check_reversable ' );
    	     END IF;
              RETURN FALSE;
     END;
    --
     ELSIF l_ra_rec.applied_payment_schedule_id = -5 THEN

        SELECT ra.cash_receipt_id,
               ra.application_ref_id,
               ra.amount_applied,
               nvl( ra.earned_discount_taken, 0 ),
               nvl( ra.unearned_discount_taken, 0 ),
               nvl( ps.amount_due_remaining, 0 ),
               ra.status,
               ctt.allow_overapplication_flag,
               nvl(ps.amount_due_original, 0)
        INTO   l_ass_cr_id,
               l_ct_id,
               l_pmt,
               l_edisc,
               l_udisc,
               l_bal,
               l_status,
               l_over_appln_flag,
               l_bal_org
        FROM   ar_receivable_applications ra,
               ar_payment_schedules ps,
               ra_cust_trx_types ctt
        WHERE  ra.receivable_application_id = p_ra_id
        AND    ps.customer_trx_id(+) = ra.application_ref_id
        AND    ctt.cust_trx_type_id = ps.cust_trx_type_id
        AND    ra.application_ref_type = 'CHARGEBACK';

        --This function will check whether any activity is against the
        --chargeback

        IF ( arp_process_chargeback.validate_cb_reversal( l_ct_id,
                                        p_module_name,
                                        p_module_version) <> TRUE ) THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug(   'validate_cb_reversal failed' );
              END IF;
              RETURN FALSE;
        END IF;

    RETURN TRUE;

    ELSIF l_ra_rec.applied_payment_schedule_id IN (-6, -8) THEN
	   BEGIN
	      /** If the -ve Miscellaneous receipt of CC Refund is already remitted or
		   ** cleared then do not allow the reversal or unapplication ***/
	      SELECT 1
	      INTO l_dummy
	      FROM dual
	      WHERE EXISTS
	      ( SELECT 1
	        FROM  AR_CASH_RECEIPT_HISTORY crh
		    WHERE crh.cash_receipt_id = l_ra_rec.application_ref_id
		    AND   crh.status IN ('REMITTED', 'CLEARED'));
       EXCEPTION
	      WHEN NO_DATA_FOUND THEN
		     l_dummy := 0;
		  WHEN OTHERS THEN
		     RAISE;
       END;

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_debug.debug(   'arp_process_application.check_reversable(-6)-' );
       END IF;

       IF l_dummy = 1 THEN
	      RETURN FALSE;
       ELSE
          RETURN TRUE;
       END IF;
    ELSE
      --for any other activity, then no need to check further
      RETURN TRUE;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'l_ps_id and l_ass_cr_id ARE' );
       arp_debug.debug(   to_char( l_ps_id ) );
       arp_debug.debug(   to_char( l_ass_cr_id ) );
    END IF;
    --
    -- If status = 'ACC', application is on account and no further
    -- validation is necessary. Return Status as 'NO_ACTION' since there will
    -- not be any actions associated with an on-account application.
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'l_status in app_delete IS' );
       arp_debug.debug(   l_status );
    END IF;
    IF ( l_status in ('ACC','OTHER ACC')) THEN
    	 IF PG_DEBUG in ('Y', 'C') THEN
    	    arp_debug.debug(   'No application action found - check_reversable ' );
    	 END IF;
         RETURN TRUE;
    END IF;
    --
    -- Check if deletion would result in negative amount_due
    --
    SELECT NVL( SUM( amount), 0 )
    INTO    l_adj_amount
    FROM   ar_adjustments
    WHERE  payment_schedule_id = l_ps_id
    AND    associated_cash_receipt_id = l_ass_cr_id
    AND    status = 'A';
    --
    -- arp_debug.debug( 'l_over_appln_flag in app_delete IS ' );
    -- arp_debug.debug( l_over_appln_flag );
    -- arp_debug.debug( ' l_adj_amount in app_delete IS' );
    -- arp_debug.debug( to_char( l_bal ) || ' ' );
    -- arp_debug.debug( to_char( l_adj_amount ) || ' ' );
    -- arp_debug.debug( to_char( l_pmt )  || ' ');
    -- arp_debug.debug( to_char( l_edisc )  || ' ');
    -- arp_debug.debug( to_char( l_udisc )  || ' ');
    -- arp_debug.debug( to_char( l_bal_org )  || ' ');
    --
    -- If overapplication is not allowed with the applications and
    -- if reversal would result in negative amount for the application
    -- the return false
    --
    -- IF ( l_over_appln_flag = 'N' AND
    --    ( l_bal - l_adj_amount + l_pmt + l_edisc + l_udisc ) < 0 ) THEN
    --
    /* Bug #373738: Changed the condition in IF clause. Now checking that sign should not be
       different from original amount's sign. The previous condition was failing,
       when applications included credit memoes with adjustments and over-application
       is No for that credit-memo. In case of credit-memo, original amount will be negative,
       so it was giving problems. */
    --
    -- Fix 1387071
    -- Added (( l_bal - l_adj_amount + l_pmt + l_edisc + l_udisc ) <> 0)
    IF ( l_over_appln_flag = 'N' AND
       (( l_bal - l_adj_amount + l_pmt + l_edisc + l_udisc ) <> 0) AND
       (sign( l_bal - l_adj_amount + l_pmt + l_edisc + l_udisc ) <> sign(l_bal_org))) THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_debug.debug(   'Reversal Application amount will have sign opposite to original amount' );
         END IF;

         RETURN FALSE;
    END IF;
    --
    SELECT count( distinct a.chargeback_customer_trx_id )
    INTO   l_cb_count
    FROM   ar_adjustments a,
           ar_adjustments b
    WHERE  a.receivables_trx_id = arp_global.G_CB_RT_ID
    AND    a.associated_cash_receipt_id = l_ass_cr_id
    AND    a.payment_schedule_id = l_ps_id
    AND    b.receivables_trx_id(+) = arp_global.G_CB_REV_RT_ID
    AND    b.customer_trx_id(+) = a.chargeback_customer_trx_id
    AND    b.customer_trx_id is NULL;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'lb_count IS ' );
       arp_debug.debug(   to_char( l_cb_count ) );
    END IF;
    --
    -- Validate chargebacks
    --
    -- Check to see if an application has any actions, if not ,
    -- returns AR_APP_NO_ACTION
    --
    SELECT NVL( SUM( DECODE( status,
                             'A', amount,
                             0
                           )
                   ), 0
               ),
           NVL( SUM( DECODE( status,
                             'A', 0,
                             'R', 0,
                             'U', 0,
                                 amount
                           )
                   ), 0
              )
    INTO   l_adj_amt,
           l_pend_amt
    FROM   ar_adjustments
    WHERE  payment_schedule_id = l_ps_id
    AND    associated_cash_receipt_id = l_ass_cr_id
    AND    chargeback_customer_trx_id iS NULL;
    --
    IF (  l_cb_count = 0 AND l_adj_amt = 0 AND l_pend_amt = 0 ) THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_debug.debug(   'No data found in ADJ table - check_reversable ' );
          END IF;
          RETURN TRUE;
    END IF;
    --
    IF ( l_cb_count <> 0 ) THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_debug.debug(   'Inside l_cb_count <> 0' );
         END IF;
         IF ( arp_process_chargeback.validate_cb_reversal( l_ps_id,
					l_ass_cr_id, l_cb_count, p_module_name,
					p_module_version ) <> TRUE ) THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug(   'validate_cb_reversal failed' );
              END IF;
              RETURN FALSE;
         END IF;
    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'after validate_cb_reversal in app_delete' );
    END IF;
    --
/****    FOR l_adj_rec IN ar_adjustments_C( l_ps_id, l_ass_cr_id )
    LOOP
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_debug.debug(   'inside for ar_adjustments_C in app_delete' );
        END IF;
        IF ( validate_cb_reversal(
			 l_adj_rec.chargeback_customer_trx_id, l_cb_count
			 p_module_name, p_module_version ) <> TRUE ) THEN
 	     RETURN FALSE;
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_debug.debug(   'after validate_cb_reversal in app_delete' );
             END IF;
        END IF;
    END LOOP;  ****/
   --
   -- At this point, validation is successful. Lock adj and  cb records
   -- However, this should be done at a different level.
   --
   /* SELECT adj.adjustment_id,
          ps.payment_schedule_id
   FROM   ar_adjustments adj,
          ar_payment_schedules ps
   WHERE  adj.associated_cash_receipt_id = l_ass_cr_id
   AND    adj.payment_schedule_id = l_ps_id
   AND    adj.chargeback_customer_trx_id = ps.customer_trx_id(+)
   FOR    UPDATE OF ps.last_updated_by,adj.last_updated_by NOWAIT; */
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'arp_process_application.check_reversable()-' );
    END IF;
    RETURN TRUE;
    --
    EXCEPTION
        WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_debug.debug(
		'EXCEPTION: arp_process_application.check_reversable - OTHER' );
             END IF;
             RAISE;
END check_reversable;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_appdel                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure validates the check_reversable procedure arguments      |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_ra_id - receivable applications Id                   |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_args_appdel(
     p_ra_id  IN ar_receivable_applications.receivable_application_id%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_process_application.validate_args_appdel()+' );
    END IF;
    --
    IF ( p_ra_id is NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_process_application.validate_args_appdel()-' );
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
    	      IF PG_DEBUG in ('Y', 'C') THEN
    	         arp_debug.debug(
		   'EXCEPTION: arp_process_application.validate_args_appdel' );
    	      END IF;
              RAISE;
END validate_args_appdel;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    reverse_action                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Reverses adjustments and chargebacks associated with an application.   |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED -                                 |
 |      arp_process_chargeback.reverse_chargeback - Procedure to reverse     |
 |                                                   a chargeback            |
 |      arp_process_adjustments.reverse_adjustments- Procedure to reverse    |
 |                                                   a adjustment            |
 |      arp_ps_util.get_closed_dates - Calculate and get closed dates        |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_ra_id -  receivable application id                      |
 |                 p_cr_id -  Cash receipt Id                                |
 |                 p_ps_id  - Payment Schedule Id                            |
 |                 p_reversal_gl_date - Reversal GL date                     |
 |                 p_select_flag - If this flag is TRUE, then select         |
 |				   Cash receipt Id and table, else use the   |
 |				   passed in values		             |
 |      	   p_module_name  - Name of the module that called this      |
 |				    procedure   			     |
 |      	   p_module_version  - Version of the module that called this|
 |			            procedure                                |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES  - This could be a public function later			     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE reverse_action(
	p_ra_id IN ar_receivable_applications.receivable_application_id%TYPE,
	p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE,
	p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
	p_reversal_gl_date IN DATE, p_reversal_date IN DATE,
	p_select_flag IN BOOLEAN,
	p_module_name IN VARCHAR2,
	p_module_version IN VARCHAR2 ) IS
l_adj_amount		NUMBER;
l_ps_id 		ar_payment_schedules.payment_schedule_id%TYPE;
l_ass_cr_id 		ar_cash_receipts.cash_receipt_id%TYPE;
l_app_rec		arp_global.app_rec_type;
l_ps_rec		ar_payment_schedules%ROWTYPE;

l_count			NUMBER DEFAULT 0;
--
CURSOR ar_adjustments_C( l_ps_id ar_payment_schedules.payment_schedule_id%TYPE,
			 l_ass_cr_id ar_cash_receipts.cash_receipt_id%TYPE ) IS
       SELECT a.chargeback_customer_trx_id,
	      a.adjustment_id,
	      a.status
       FROM   ar_adjustments a,
              ar_adjustments b
       WHERE  a.receivables_trx_id = arp_global.G_CB_RT_ID
       AND    a.associated_cash_receipt_id = l_ass_cr_id
       AND    a.payment_schedule_id = l_ps_id
       AND    b.receivables_trx_id(+) = arp_global.G_CB_REV_RT_ID
       AND    b.customer_trx_id(+) = a.chargeback_customer_trx_id
       AND    b.customer_trx_id is null;
--
CURSOR ar_adjustments_radj_C(
			l_ps_id ar_payment_schedules.payment_schedule_id%TYPE,
			l_ass_cr_id ar_cash_receipts.cash_receipt_id%TYPE ) IS
       SELECT adjustment_id,
	      status
       FROM   ar_adjustments
       WHERE  associated_cash_receipt_id = l_ass_cr_id
       AND    payment_schedule_id = l_ps_id
       AND  status <> 'R'
       AND  associated_application_id = p_ra_id    --Bug2144783
       AND  chargeback_customer_trx_id is null
       UNION
       SELECT adjustment_id,
	      status
       FROM   ar_adjustments
       WHERE  associated_cash_receipt_id = l_ass_cr_id
       AND    payment_schedule_id = l_ps_id
       AND  status <> 'R'
       AND  associated_application_id is null
       AND  chargeback_customer_trx_id is null;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_process_application.reverse_action()+' );
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(    to_char( p_ra_id ) );
       arp_debug.debug(    to_char( p_cr_id ) );
       arp_debug.debug(    to_char( p_ps_id ) );
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'inside BEGIN reverse_action in app_delete' );
    END IF;
/**    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
         validate_reverse_action_args( p_ra_id, p_cr_id, p_ps_id,
        			       p_reversal_gl_date, p_reversal_date,
        			       p_select_flag );
    END IF;  **/
    --
    IF ( p_select_flag = TRUE ) THEN
        BEGIN
    	    SELECT cash_receipt_id,
                   applied_payment_schedule_id
    	    INTO   l_ass_cr_id,
	           l_ps_id
    	    FROM   ar_receivable_applications
    	    WHERE  receivable_application_id = p_ra_id;
         EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	         IF PG_DEBUG in ('Y', 'C') THEN
	            arp_debug.debug(   'Select from ar_adjustments failed' );
	         END IF;
	         RETURN;
         END;
     ELSE
	 l_ass_cr_id := p_cr_id;
	 l_ps_id := p_ps_id;
     END IF;
     --
     -- Get the sum of approved and pending adjustments on the payment schedule
     -- This sum includes chargebacks amounts, too.
     --
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_debug.debug( 'before SELECT NVL reverse_action in app_delete' );
     END IF;
     SELECT NVL( SUM( DECODE( status,
		             'A', amount,
		             0
			    )
		    ), 0
	       ),
            NVL( SUM( DECODE( status,
			      'A', acctd_amount,
			      0
			    )
		    ), 0
	       ),
            NVL( SUM( DECODE( chargeback_customer_trx_id,
			      NULL, DECODE( status,
					    'A', amount,
					    0
					  ),
			      0
  			    )
		     ), 0
	        ),
             NVL( SUM( DECODE( status,
			       'A', 0,
			       'R', 0,
			       'U', 0,
			       amount
			     )
		     ), 0
	        ),
             NVL( SUM( DECODE( status,
			       'A', line_adjusted,
			       0
			     )
		     ), 0
	        ),
             NVL( SUM( DECODE( status,
			       'A', tax_adjusted,
			       0 )
			     ), 0
	        ),
             NVL( SUM( DECODE( status,
			       'A', freight_adjusted,
			       0
			     )
		     ), 0
	        ),
             NVL( SUM( DECODE( status,
			       'A', receivables_charges_adjusted,
			       0
			     )
		     ), 0
	        ),
             NVL( SUM( DECODE( status,
                               'A', DECODE( type ,
			         'CHARGES',amount,0),
                               0
                             )
                     ), 0
                )
       INTO  l_app_rec.amount_applied,
             l_app_rec.acctd_amount_applied,
             l_adj_amount,
             l_app_rec.amount_adjusted_pending,
             l_app_rec.line_applied,
             l_app_rec.tax_applied,
             l_app_rec.freight_applied,
             l_app_rec.receivables_charges_applied,
    	     l_app_rec.charges_type_adjusted
       FROM   ar_adjustments
       WHERE  payment_schedule_id = l_ps_id
       AND    associated_cash_receipt_id = l_ass_cr_id;
       --
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_debug.debug( 'before for reverse_action in app_delete' );
           arp_debug.debug(   to_char( l_ps_id ) );
           arp_debug.debug(   to_char( l_ass_cr_id ) );
        END IF;
        FOR l_adj_rec IN ar_adjustments_C( l_ps_id, l_ass_cr_id )
        LOOP
	    l_count := l_count + 1;
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_debug.debug(   'inside for ar_adjustments_C in app_delete' );
            END IF;
	     --
             -- reverse chargeback
	     --
             arp_process_chargeback.reverse_chargeback(
			             l_adj_rec.chargeback_customer_trx_id,
			             p_reversal_gl_date, p_reversal_date,
			             p_module_name, p_module_version );
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_debug.debug(   'after reverse_chargeback in app_delete' );
             END IF;
             --
             arp_process_adjustment.reverse_adjustment( l_adj_rec.adjustment_id,
			           p_reversal_gl_date, p_reversal_date,
			           p_module_name, p_module_version );
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_debug.debug(
		      'after ar_adjustment.reverse_adjustment in app_delete' );
            END IF;
            --
            UPDATE ra_customer_trx
            SET    status_trx = 'CL'
            WHERE  customer_trx_id = l_adj_rec.chargeback_customer_trx_id;
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_debug.debug(   'after UPDATE in app_delete ' );
            END IF;
    END LOOP;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'before if ar_adjustments_C%ROWCOUNT in app_delete ' );
    END IF;
    IF ( l_count = 0 AND l_adj_amount = 0 AND
	 l_app_rec.amount_adjusted_pending = 0 ) THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_debug.debug(
		      'AR-ARMDAPP:Theres no actions associated with the appln');
         END IF;
         RETURN;
    END IF;
    --
    -- Reverse adjustments , call armradj,
    -- select only adjustments that have not been rejected
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'before for ar_adjustments_radj_C in app_delete' );
    END IF;
    FOR l_adj_rec IN ar_adjustments_radj_C( l_ps_id, l_ass_cr_id )
    LOOP
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_debug.debug(   'inside for ar_adjustments_radj_C in app_delete' );
        END IF;
        arp_process_adjustment.reverse_adjustment( l_adj_rec.adjustment_id,
                             			   p_reversal_gl_date,
                             			   p_reversal_date,
			     			   p_module_name,
						   p_module_version );
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_debug.debug(
			'after AR_ADJUSTMENT.reverse_adjustmen in app_delete' );
        END IF;
    END LOOP;
    --
    -- Call armups to update the payment schedule with approved adj
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(
		   'before SELECT NVL( amount_adjusted_pending in app_delete' );
    END IF;
    SELECT NVL( amount_adjusted_pending, 0 ) -
           NVL( l_app_rec.amount_adjusted_pending, 0)
    INTO   l_app_rec.amount_adjusted_pending
    FROM   ar_payment_schedules
    WHERE  payment_schedule_id = l_ps_id;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'before get_closed_dates in app_delete' );
    END IF;
    --
    -- Get closed dates to update payment schedule table
    --
    arp_ps_util.get_closed_dates( l_ps_id,
                     p_reversal_gl_date, p_reversal_date,
                     l_app_rec.gl_date_closed,
		     l_app_rec.actual_date_closed, 'PMT' );
    --
    l_app_rec.ps_id := l_ps_id;
    l_app_rec.trx_type := 'AR_ADJ';
    l_app_rec.user_id := FND_GLOBAL.user_id;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'before update_reverse_actions in app_delete' );
    END IF;
    arp_ps_util.update_reverse_actions( l_app_rec, NULL, NULL );
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_process_application.reverse_action()-' );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug(
		         'EXCEPTION: arp_process_application.reverse_action' );
              END IF;
              RAISE;
END reverse_action;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_reverse_action_args                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to reverse_action procedure                  |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_ra_id -  receivable application id                      |
 |                 p_cr_id -  Cash receipt Id                                |
 |                 p_ps_id  - Payment Schedule Id                            |
 |                 p_reversal_gl_date - Reversal GL date                     |
 |                 p_select_flag - If this flag is TRUE, then select         |
 |                                 Cash receipt Id and table, else use the   |
 |                                 passed in values                          |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE  validate_reverse_action_args(
        p_ra_id IN ar_receivable_applications.receivable_application_id%TYPE,
        p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE,
        p_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_reversal_gl_date IN DATE, p_reversal_date IN DATE,
        p_select_flag IN BOOLEAN ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(
	      'arp_process_application.validate_reverse_action_args()+' );
    END IF;
    --
    IF ( p_ra_id IS NULL OR p_reversal_gl_date IS NULL OR
	 p_select_flag IS NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF ( p_select_flag <> TRUE ) THEN
         IF ( p_cr_id IS NULL OR p_ps_id IS NULL ) THEN
              FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
              APP_EXCEPTION.raise_exception;
         END IF;
    END IF;
--
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_process_application.validate_reverse_action_args()-' );
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug(
		'EXCEPTION: arp_process_application.validate_reverse_action_args' );
              END IF;
              RAISE;
END validate_reverse_action_args;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    receipt_application                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Do all actions neccessary to update PS rows and insert APP and UNAPP   |
 |    rows in RA table when a receipt is applied to a transaction.           |
 |    The PS table rows on the transaction and receipt side are updated      |
 |    and 2 RA rows are inserted with status 'APP' and 'UNAPP'.              |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED -                                  |
 |      arp_ps_util.update_invoice_related_columns                           |
 |      arp_ps_util.update_cm_related_columns                                |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_receipt_ps_id - PS Id of the receipt                    |
 |                 p_invoice_ps_id - PS Id of the transaction                |
 |                 p_amount_applied - TO amount                              |
 |                 p_amount_applied_from - FROM amount                       |
 | 		   p_trans_to_receipt_rate - Cross currency rate             |
 |                 p_receipt_currency_code - Currency of the receipt         |
 |                 p_invoice_currency_code - Currency of the transaction     |
 |                 p_earned_discount_taken - Earned Discount taken           |
 |                 p_unearned_discount_taken - UnEarned Discount taken       |
 |                 p_apply_date - Application date                           |
 |                 p_gl_date    - GL Date                                    |
 |                 p_ussgl_transaction_code - USSGL transaction code         |
 |                 p_customer_trx_line_id - Line of the transaction applied  |
 |                 p_comments    - comments                                  |
 |                                                                           |
 |                 OTHER DESCRIPTIVE FLEX columns                            |
 |      	   p_module_name  - Name of the module that called this      |
 |				    procedure   			     |
 |      	   p_module_version  - Version of the module that called this|
 |			               procedure                             |
 |              OUT:                                                         |
 |                 p_receivable_application_id - Identifier of RA            |
 |                 p_acctd_amount_applied_from - Rounded acctd FROM amount   |
 |                 p_acctd_amount_applied_to - Rounded acctd TO amount       |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES  -								     |
 |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 08/29/95
 |  4/19/1996	Harri Kaukovuo	Added new parameter p_customer_trx_line_id
 |  5/3/1996	Harri Kaukovuo	Added new parameter p_out_rec_application_id
 |  5/6/1996	Harri Kaukovuo	Bug 354045, modified to update the
 |				batch status.
 |  10/17/1996  Karen Lawrance  Added code to prevent the creation of more
 |                              than one application against the same receipt
 |                              and invoice.
 |  05/06/1997  Karen Lawrance  Bug fix #481761.  Fixed application rule.
 |  07/21/1997	Karen Lawrance	Release 11.
 |                		Added processing for cross currency
 |                              functionality.  Included new IN, OUT NOCOPY
 |                              parameters and use of amount applied from.
 |  08/21/197	Tasman Tang	Added global_attribute_category,
 |				global_attribute[1-20] for global descriptive
 |				flexfield
 |  07/16/1998  Karen Murphy    Bug fix 634464.  Modified the code that works
 |                              out NOCOPY the status for the Receipt (APP or UNAPP)
 |                              Now includes the total On Account amount as
 |                              this is not included in the Pay Sched, Amt
 |                              Due Rem total.
 |  05/06/1999  Debbie Jancis   Modified receipt_application to accept
 |                              comments for insert into receivable_applications
 |                              for Bug 741914.
 |                                                                           |
 |  14-APR-2000 Jani Rautiainen Added parameter p_called_from. This is needed|
 |                              in the logic to decide whether UNAPP row is  |
 |                              postable or not. In BR scenario when an      |
 |                              Activity Application of Short Term Debt is   |
 |                              unapplied and then normal application is     |
 |                              done against the BR the UNAPP row is not     |
 |                              postable. This is an user requirement for BR.|
 |                              The parameter is defaulted to NULL so no     |
 |                              impact for the existing functionality.       |
 |                              Also added logic to prevent accounting       |
 |                              creation if the row is not postable.         |
 |                              Also added parameter p_move_deferred_tax     |
 |                              which indicates whether the accounting engine|
 |                              should move deferred tax or not              |
 | 13-Jun-00  Satheesh Nambiar  Bug 1329091 - Passing a new parameter
 |                              pay_sched_upd_yn to accounting engine
 |                              to acknowldge PS is updated.
 | 27-APR-00  jbeckett          Calls iClaim API if CLAIM                    |
 |                                                                           |
 | 06/02/2001 S.Nambiar         Bug 1808020 - Activity application should
 |				not fetch
 |                              PS record when unapplying or modifying amount
 | 08/03/2001  jbeckett    	Bug 1905659 - Added parameter
 |                              p_amount_due_remaining to receipt_application
 | 09/05/2002  jbeckett         Bug 2361331 - passes primary_salesrep_id to
 |                              create_claim
 | 03-Sep-02   Debbie Jancis    modified for mrc trigger replacement.        |
 | 				added processing for receivable apps         |
 | 06-SEP-02   jbeckett         Bug 2751910 - Added p_customer_reason        |
 | 28-Apr-03   Rahna Kader      Bug 1659928: Now the program checks for      |
 | 				over application before the applications     |
 | 				are saved                                    |
 | 07-AUG-03   Jon Beckett      Bug 3087819 - Claim is not created/updated   |
 |                              if called from Trade Management              |
 | 10-AUG-04   Jon Beckett	Bug 3773036 - new exception trade_mgt_err    |
 | 				raised if claim create/update fails to       |
 |				ensure control is passed correctly back to   |
 |				calling program and TM error is displayed.   |
 | 26-AUG-05   MRaymond         4566510 - Prorate discounts over tax via
 |                                etax.
 | 14-OCT-2005  Jon Beckett    Bug 4565758 - Legal entity passed to TM
 | 19-DEC-2006  M Raymond      5677984 - Removed etax calls for rec app
 |                               and moved them inside
 |                               update_invoice_related_columns
 | 31-JUL-2009  M Raymond      8620127 - set maturity date correctly
 |                               based on receipt_method rule
 +===========================================================================*/
PROCEDURE receipt_application(
	p_receipt_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
	p_invoice_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_amount_applied IN ar_receivable_applications.amount_applied%TYPE,
        p_amount_applied_from IN
                   ar_receivable_applications.amount_applied_from%TYPE,
        p_trans_to_receipt_rate IN
                   ar_receivable_applications.trans_to_receipt_rate%TYPE,
        p_invoice_currency_code IN
                   ar_payment_schedules.invoice_currency_code%TYPE,
        p_receipt_currency_code IN ar_cash_receipts.currency_code%TYPE,
        p_earned_discount_taken IN
                   ar_receivable_applications.earned_discount_taken%TYPE,
        p_unearned_discount_taken IN
                   ar_receivable_applications.unearned_discount_taken%TYPE,
        p_apply_date IN ar_receivable_applications.apply_date%TYPE,
	p_gl_date IN ar_receivable_applications.gl_date%TYPE,
	p_ussgl_transaction_code IN
                   ar_receivable_applications.ussgl_transaction_code%TYPE,
	p_customer_trx_line_id	IN
                   ar_receivable_applications.applied_customer_trx_line_id%TYPE,
        p_application_ref_type IN
                ar_receivable_applications.application_ref_type%TYPE,
        p_application_ref_id IN
                ar_receivable_applications.application_ref_id%TYPE,
        p_application_ref_num IN
                ar_receivable_applications.application_ref_num%TYPE,
        p_secondary_application_ref_id IN
                ar_receivable_applications.secondary_application_ref_id%TYPE,
        p_attribute_category IN ar_receivable_applications.attribute_category%TYPE,
	p_attribute1 IN ar_receivable_applications.attribute1%TYPE,
	p_attribute2 IN ar_receivable_applications.attribute2%TYPE,
	p_attribute3 IN ar_receivable_applications.attribute3%TYPE,
	p_attribute4 IN ar_receivable_applications.attribute4%TYPE,
	p_attribute5 IN ar_receivable_applications.attribute5%TYPE,
	p_attribute6 IN ar_receivable_applications.attribute6%TYPE,
	p_attribute7 IN ar_receivable_applications.attribute7%TYPE,
	p_attribute8 IN ar_receivable_applications.attribute8%TYPE,
	p_attribute9 IN ar_receivable_applications.attribute9%TYPE,
  	p_attribute10 IN ar_receivable_applications.attribute10%TYPE,
	p_attribute11 IN ar_receivable_applications.attribute11%TYPE,
	p_attribute12 IN ar_receivable_applications.attribute12%TYPE,
	p_attribute13 IN ar_receivable_applications.attribute13%TYPE,
	p_attribute14 IN ar_receivable_applications.attribute14%TYPE,
	p_attribute15 IN ar_receivable_applications.attribute15%TYPE,
        p_global_attribute_category IN ar_receivable_applications.global_attribute_category%TYPE,
        p_global_attribute1 IN ar_receivable_applications.global_attribute1%TYPE,
        p_global_attribute2 IN ar_receivable_applications.global_attribute2%TYPE,
        p_global_attribute3 IN ar_receivable_applications.global_attribute3%TYPE,
        p_global_attribute4 IN ar_receivable_applications.global_attribute4%TYPE,
        p_global_attribute5 IN ar_receivable_applications.global_attribute5%TYPE,
        p_global_attribute6 IN ar_receivable_applications.global_attribute6%TYPE,
        p_global_attribute7 IN ar_receivable_applications.global_attribute7%TYPE,
        p_global_attribute8 IN ar_receivable_applications.global_attribute8%TYPE,
        p_global_attribute9 IN ar_receivable_applications.global_attribute9%TYPE,
        p_global_attribute10 IN ar_receivable_applications.global_attribute10%TYPE,
        p_global_attribute11 IN ar_receivable_applications.global_attribute11%TYPE,
        p_global_attribute12 IN ar_receivable_applications.global_attribute12%TYPE,
        p_global_attribute13 IN ar_receivable_applications.global_attribute13%TYPE,
        p_global_attribute14 IN ar_receivable_applications.global_attribute14%TYPE,
        p_global_attribute15 IN ar_receivable_applications.global_attribute15%TYPE,
        p_global_attribute16 IN ar_receivable_applications.global_attribute16%TYPE,
        p_global_attribute17 IN ar_receivable_applications.global_attribute17%TYPE,
        p_global_attribute18 IN ar_receivable_applications.global_attribute18%TYPE,
        p_global_attribute19 IN ar_receivable_applications.global_attribute19%TYPE,
        p_global_attribute20 IN ar_receivable_applications.global_attribute20%TYPE,
        p_comments IN ar_receivable_applications.comments%TYPE,
	p_module_name IN VARCHAR2,
	p_module_version IN VARCHAR2,
	-- OUT NOCOPY
        x_application_ref_id OUT NOCOPY
                ar_receivable_applications.application_ref_id%TYPE,
        x_application_ref_num OUT NOCOPY
                ar_receivable_applications.application_ref_num%TYPE,
        x_return_status               OUT NOCOPY VARCHAR2,
        x_msg_count                   OUT NOCOPY NUMBER,
        x_msg_data                    OUT NOCOPY VARCHAR2,
	p_out_rec_application_id OUT NOCOPY ar_receivable_applications.receivable_application_id%TYPE,
        p_acctd_amount_applied_from OUT NOCOPY ar_receivable_applications.acctd_amount_applied_from%TYPE,
        p_acctd_amount_applied_to OUT NOCOPY ar_receivable_applications.acctd_amount_applied_to%TYPE,
        x_claim_reason_name     OUT NOCOPY VARCHAR2,
	p_called_from           IN VARCHAR2, /* jrautiai BR implementation */
	p_move_deferred_tax     IN VARCHAR2,  /* jrautiai BR implementation */
        p_link_to_trx_hist_id   IN ar_receivable_applications.link_to_trx_hist_id%TYPE, /* jrautiai BR implementation */
        p_amount_due_remaining  IN
                ar_payment_schedules.amount_due_remaining%TYPE,
	p_payment_set_id        IN ar_receivable_applications.payment_set_id%TYPE,
        p_application_ref_reason IN ar_receivable_applications.application_ref_reason%TYPE,
        p_customer_reference     IN ar_receivable_applications.customer_reference%TYPE,
        p_customer_reason        IN ar_receivable_applications.customer_reason%TYPE,
        from_llca_call     IN VARCHAR2 DEFAULT 'N',
        p_gt_id            IN NUMBER   DEFAULT NULL
) IS

l_rec_ra_rec     		ar_receivable_applications%ROWTYPE;
l_inv_ra_rec     		ar_receivable_applications%ROWTYPE;

l_cr_rec			ar_cash_receipts%ROWTYPE;
l_amount_due_remaining		NUMBER;
ln_batch_id			NUMBER;
--
l_on_account_total              NUMBER;
l_ae_doc_rec                    ae_doc_rec_type;

  --Bug#2750340
  l_xla_ev_rec      arp_xla_events.xla_events_type;
  l_xla_doc_table   VARCHAR2(20);


  l_receipt_info_rec               AR_AUTOREC_API.receipt_info_rec;

   l_old_ps_rec                 ar_payment_schedules%ROWTYPE; /* jrautiai BR implementation */
   l_new_ps_rec                 ar_payment_schedules%ROWTYPE; /* jrautiai BR implementation */
   l_source_type                ar_distributions.source_type%TYPE; /* jrautiai BR implementation */
   l_exchange_rate_type         ra_customer_trx.exchange_rate_type%TYPE;
   l_exchange_rate_date         ra_customer_trx.exchange_date%TYPE;
   l_exchange_rate              ra_customer_trx.exchange_rate%TYPE;
   l_trx_number                 ra_customer_trx.trx_number%TYPE;
   l_cust_trx_type_id           ra_customer_trx.cust_trx_type_id%TYPE;
   l_customer_id                ra_customer_trx.bill_to_customer_id%TYPE;
   l_bill_to_site_use_id        ra_customer_trx.bill_to_site_use_id%TYPE;
   l_ship_to_site_use_id        ra_customer_trx.ship_to_site_use_id%TYPE;
   l_receipt_number             ar_cash_receipts.receipt_number%TYPE;
   l_trx_amount_due             NUMBER;
   l_claim_amount               NUMBER;
   l_salesrep_id                ra_customer_trx.primary_salesrep_id%TYPE;
   l_claim_trx_ps_id            NUMBER;
   l_claim_id                   NUMBER;
   l_claim_reason_code_id       NUMBER;
   l_claim_reason_name          VARCHAR2(80);
   l_request_id                 NUMBER;
   l_called_from_api            VARCHAR2(1);

   /* Bug fix 1659928 */
   l_inv_bal_amount             NUMBER;
   l_inv_orig_amount            NUMBER;
   l_allow_over_application     VARCHAR2(1);
   l_effective_amount_applied   NUMBER;

   /* 4566510 - etax */
   l_from_llca_call             VARCHAR2(1);
   l_gt_id                      NUMBER;
   l_legal_entity_id            NUMBER;
   l_ra_app_id                  NUMBER := NULL; -- holds APP ra_id

   CURSOR c_claim_trx_details (p_customer_trx_id NUMBER) IS
        SELECT t.exchange_rate_type
             , t.exchange_date
             , t.exchange_rate
             , t.trx_number
             , t.cust_trx_type_id
             , t.bill_to_customer_id
             , t.bill_to_site_use_id
             , t.ship_to_site_use_id
             , t.primary_salesrep_id
             , t.legal_entity_id
        FROM   ra_customer_trx t
        WHERE  t.customer_trx_id = p_customer_trx_id;

   CURSOR c_claim_rct_details (p_receipt_id NUMBER) IS
        SELECT receipt_number
        FROM   ar_cash_receipts
        WHERE  cash_receipt_id = p_receipt_id;

   CURSOR c_trx_amount_due (p_payment_schedule_id NUMBER) IS
        SELECT amount_due_remaining
        FROM   ar_payment_schedules
        WHERE  payment_schedule_id = p_payment_schedule_id;

   trade_mgt_err		EXCEPTION; -- Bug 3773036

   /* 8620127 */
   l_maturity_date  DATE;
   l_receipt_date   DATE;
   l_due_date       DATE;
   l_maturity_date_rule VARCHAR2(30);
   l_amount_applied     NUMBER;
   l_first_application  BOOLEAN;
   l_class_var			ar_payment_schedules.class%type;   -- Bug 6924942

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'arp_process_application.receipt_application()+' );
    END IF;

   /* Bug 3773036: Initializing return status ..*/
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   /* move parm gt_id into local var.  It may get set by prorate_recoverable
      if discounts are present */
   l_gt_id := p_gt_id;

   /* 12-JUL-2000 J Rautiainen BR Implementation
    * Storing the old image of the payment schedule
    * This is only done when application is done outside the BR remittance program */

    IF NVL(p_called_from,'NONE') not in ('BR_REMITTED','BR_FACTORED_WITH_RECOURSE','BR_FACTORED_WITHOUT_RECOURSE')
       AND p_invoice_ps_id IS NOT NULL AND (SIGN(p_invoice_ps_id) <> -1)  THEN

      arp_ps_pkg.fetch_p( p_invoice_ps_id, l_old_ps_rec );

    END IF;

    -- Output IN parameters
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'Receipt PS Id           : '||TO_CHAR( p_receipt_ps_id ) );
       arp_debug.debug(   'Invoice PS Id           : '||TO_CHAR( p_invoice_ps_id ) );
       arp_debug.debug(   'Amount Applied          : '||TO_CHAR( p_amount_applied ) );
       arp_debug.debug(   'Amount Applied From     : '||TO_CHAR( p_amount_applied_from ) );
       arp_debug.debug(   'Trans to Receipt Rate   : '||TO_CHAR( p_trans_to_receipt_rate ) );
       arp_debug.debug(   'Invoice Currency Code   : '||p_invoice_currency_code );
       arp_debug.debug(   'Receipt Currency Code   : '||p_receipt_currency_code );
       arp_debug.debug(   'Earned Discount         : '||TO_CHAR( p_earned_discount_taken ) );
       arp_debug.debug(   'Unearned Discount       : '||TO_CHAR( p_unearned_discount_taken ) );
       arp_debug.debug(   'GL Date                 : '||TO_CHAR( p_gl_date ) );
       arp_debug.debug(   'Apply Date              : '||TO_CHAR( p_apply_date ) );
       arp_debug.debug(   'Customer Trx Line Id    : '||TO_CHAR( p_customer_trx_line_id ) );
    END IF;

    -----------------------------------------------------
    --  KML 10/17/1996
    --  Prevent the creation of more than one application
    --  against the same receipt and invoice.
    --  Bug #505538
    --  Modified the condition to allow application for
    --  invoice applied to same receipt for different
    --  invoice lines.
    -----------------------------------------------------
    --if the call is from autoreceipts then we will not have
    --any applications for this receipt and invoice combination [BUG 6660834]
    IF nvl(p_called_from,'NONE') NOT IN ('AUTORECAPI','AUTORECAPI2') THEN
      DECLARE
	l_found   varchar2(1) := 'N';
      BEGIN
	IF p_customer_trx_line_id IS NULL THEN
	  select 'Y'
	  into   l_found
	  from   ar_receivable_applications rap
	  where  rap.payment_schedule_id = p_receipt_ps_id
	  and    rap.applied_payment_schedule_id = p_invoice_ps_id
	  and    rap.display = 'Y'
	  and    rap.status = 'APP';
	ELSE
	  select 'Y'
	  into   l_found
	  from   ar_receivable_applications rap
	  where  rap.payment_schedule_id = p_receipt_ps_id
	  and    rap.applied_payment_schedule_id = p_invoice_ps_id
	  and    rap.applied_customer_trx_line_id = p_customer_trx_line_id
	  and    rap.display = 'Y'
	  and    rap.status = 'APP';
	END IF;
	if l_found = 'Y' then
	  raise too_many_rows;
	end if;

      EXCEPTION
	when no_data_found then
	  null;
	when too_many_rows then
	  FND_MESSAGE.set_name ('AR', 'AR_RW_PAID_INVOICE_TWICE' );
	  APP_EXCEPTION.raise_exception;
      END;
    END IF;

    /* Bug fix 1659928
       Check if the payment schedule of this transaction is over applied and
       the transaction type does not allow overapplication */

    IF nvl(p_called_from,'NONE') IN ('AUTORECAPI','AUTORECAPI2') THEN
	ar_autorec_api.populate_cached_data( l_receipt_info_rec );
	l_inv_bal_amount          := l_receipt_info_rec.inv_bal_amount;
	l_inv_orig_amount         := l_receipt_info_rec.inv_orig_amount;
	l_allow_over_application  := l_receipt_info_rec.allow_overappln_flag;

    ELSE
       select   ps.amount_due_remaining,ps.amount_due_original,ctt.allow_overapplication_flag
       into     l_inv_bal_amount, l_inv_orig_amount, l_allow_over_application
       from     ra_cust_trx_types ctt, ar_payment_schedules ps
       where    ps.payment_schedule_id = p_invoice_ps_id
       and      ps.cust_trx_type_id = ctt.cust_trx_type_id;
    END IF;

       l_effective_amount_applied := NVL(p_amount_applied,0) +
                                     NVL(p_earned_discount_taken,0)+
                                     NVL(p_unearned_discount_taken,0);
       IF l_allow_over_application ='N'
        AND arp_deduction.overapplication_indicator(l_inv_orig_amount,
                                                    l_inv_bal_amount,
                                                    l_effective_amount_applied) ='Y' THEN
          FND_MESSAGE.set_name ('AR', 'AR_CKAP_OVERAPP' );
          APP_EXCEPTION.raise_exception;
       END IF;

    /* End bug fix 1659928 */

    -- Validate the parameters that have been passed to the procedure.
    --
    IF (p_module_name IS NOT NULL AND
        p_module_version IS NOT NULL ) THEN
       validate_receipt_appln_args
          ( p_receipt_ps_id,
            p_invoice_ps_id,
            p_amount_applied,
            p_amount_applied_from,
            p_trans_to_receipt_rate,
            p_invoice_currency_code,
            p_receipt_currency_code,
            p_earned_discount_taken,
            p_unearned_discount_taken,
            p_apply_date,
            p_gl_date );
    END IF;

    --------------------------------------------------------------------------
    -- Process the Cash Receipt ...
    --
    -- This involves updating the Cash Receipt row in Payment Schedules
    -- and creating the UNAPP row in receivable applications.
    --------------------------------------------------------------------------

    -- Populate CC ID columns by selecting from receipt method accounts and
    -- payment schedule tables.
    -- Release 11.5 VAT changes get discount accounts from activity
    /*  Reverted the fix introduced by 5571095 for bug 5638732 and replaced ce_bank_acct_uses by ce_bank_acct_uses_ou_v
        for performance issue */
    /*  Removing the ce_bank_acct_uses table from the select statement for bug 5571095 by gnramasa on 06/10/2006  */
    --BUG 6660834
    IF nvl(p_called_from,'NONE') IN ('AUTORECAPI','AUTORECAPI2') THEN
	ar_autorec_api.populate_cached_data( l_receipt_info_rec );

	ln_batch_id                           := l_receipt_info_rec.batch_id;
	l_rec_ra_rec.cash_receipt_id          := l_receipt_info_rec.cash_receipt_id;
	l_rec_ra_rec.code_combination_id      := l_receipt_info_rec.unapplied_ccid;
	l_inv_ra_rec.earned_discount_ccid     := l_receipt_info_rec.ed_disc_ccid;
	l_inv_ra_rec.unearned_discount_ccid   := l_receipt_info_rec.uned_disc_ccid;
	l_inv_ra_rec.applied_customer_trx_id  := l_receipt_info_rec.customer_trx_id;

        /* 8620127 - need to get following values:
            - l_maturity_date
            - l_due_date
            - l_receipt_date
            - l_maturity_date_rule
        */

        SELECT cr.deposit_date, rm.maturity_date_rule_code, ps.due_date,
               ps.amount_applied
        INTO   l_receipt_date, l_maturity_date_rule, l_maturity_date,
               l_amount_applied
        FROM   ar_cash_receipts cr,
               ar_receipt_methods rm,
               ar_payment_schedules ps
        WHERE  cr.cash_receipt_id = l_rec_ra_rec.cash_receipt_id
        AND    cr.receipt_method_id = rm.receipt_method_id
        AND    cr.cash_receipt_id = ps.cash_receipt_id;

	SELECT amount_due_remaining,
               due_date
	INTO  l_amount_due_remaining,
              l_due_date
	FROM ar_payment_schedules
	WHERE payment_schedule_id = p_invoice_ps_id;

    ELSE
      SELECT ps.cash_receipt_id
	   , ps.amount_due_remaining
	   , rma.unapplied_ccid
	   , ed.code_combination_id
	   , uned.code_combination_id
	   , crh.batch_id
           , rm.maturity_date_rule_code
           , cr.deposit_date
           , ps.due_date
           , ps.amount_applied
      INTO   l_rec_ra_rec.cash_receipt_id
	   , l_amount_due_remaining
	   , l_rec_ra_rec.code_combination_id
	   , l_inv_ra_rec.earned_discount_ccid
	   , l_inv_ra_rec.unearned_discount_ccid
	   , ln_batch_id
           , l_maturity_date_rule
           , l_receipt_date
           , l_maturity_date
           , l_amount_applied
      FROM   ar_cash_receipts 		cr
	   , ar_cash_receipt_history 	crh
	   , ar_receipt_methods 	rm
	   , ce_bank_acct_uses_ou    	ba
	   , ar_receipt_method_accounts	rma
	   , ar_payment_schedules 	ps
	   , ar_receivables_trx           ed
	   , ar_receivables_trx           uned
      WHERE  ps.payment_schedule_id	= p_receipt_ps_id
      AND    cr.cash_receipt_id		= ps.cash_receipt_id
      AND	   cr.cash_receipt_id		= crh.cash_receipt_id
      AND    crh.current_record_flag	= 'Y'
      AND    rm.receipt_method_id		= cr.receipt_method_id
      AND    ba.bank_acct_use_id		= cr.remit_bank_acct_use_id
      AND    rma.remit_bank_acct_use_id	= ba.bank_acct_use_id
      AND    rma.receipt_method_id	= rm.receipt_method_id
      AND    rma.edisc_receivables_trx_id = ed.receivables_trx_id (+)
      AND    rma.unedisc_receivables_trx_id = uned.receivables_trx_id (+);

      /* 4566510 - get invoice trx_id for use in prorate_recoverable */
      SELECT customer_trx_id, due_date
      INTO   l_inv_ra_rec.applied_customer_trx_id,
             l_due_date
      FROM   ar_payment_schedules
      WHERE  payment_schedule_id = p_invoice_ps_id;
    END IF;

arp_debug.debug('trx_id = ' || l_inv_ra_rec.applied_customer_trx_id);

 -----------------------------------------------------
    --  Bug 1814806
    --  Prevent the application of a receipt against a claim number
    --  more than once
  -----------------------------------------------------
/* Bug 2719456 : The following sql will be called only iclaim is installed */
/* Bug 3251839 - checks against cached arp_global value */
   IF arp_global.tm_installed_flag = 'Y' THEN

     DECLARE
       l_count   number;
       claim_multi_assign exception;

     BEGIN
       select count(*)
       into   l_count
       from   ar_receivable_applications rap
       where  rap.cash_receipt_id = l_rec_ra_rec.cash_receipt_id
       and    rap.secondary_application_ref_id =
                                p_secondary_application_ref_id
       and    rap.application_ref_type = 'CLAIM'
       and    rap.display = 'Y';

       if l_count > 0  then
          raise claim_multi_assign;
       end if;

     EXCEPTION
       when no_data_found then
         null;
       when claim_multi_assign then
         FND_MESSAGE.set_name ('AR', 'AR_RW_APP_CLAIM_MULTI_ASSIGN' );
         APP_EXCEPTION.raise_exception;
     END;

   END IF;

    /* 8620127 - calculate new maturity date using following:
        l_maturity_date_rule - from receipt method, EARLIEST or LATEST
        l_maturity_date      - from rec_ps.due_date
        l_due_date           - from inv_ps.due_date
        l_receipt_date       - from cr.deposit_date

       Logic is to only use due_date as receipt maturity date when it is greater
       than the receipt (deposit) date.  If due_date is greater than receipt date,
       then we check the rule and compare the due_date to the current
       receipt maturity date.  We'll only change the receipt maturity date
       if the current due date beats the existing maturity date (based on rule).

       It is also possible that a receipt (via autoreceipts or api) can be
       applied to multiple transactions.  If this is the first application,
       then we ignore the existing maturity_date (it is the receipt date).
       However, if this is 2nd or later application, then the maturity_date
       is the receipt or inv due_date and should be considered.
    */

    IF PG_DEBUG in ('Y', 'C')
    THEN
       arp_debug.debug('---maturity date---');
       arp_debug.debug('receipt_date  = ' || l_receipt_date);
       arp_debug.debug('maturity_date = ' || l_maturity_date);
       arp_debug.debug('inv due_date  = ' || l_due_date);
       arp_debug.debug('date rule     = ' || l_maturity_date_rule);
       arp_debug.debug('amount_applied= ' || l_amount_applied);
    END IF;

    IF nvl(l_amount_applied, 0) <> 0
    THEN
       l_first_application := FALSE;
    ELSE
       l_first_application := TRUE;
    END IF;

       If l_receipt_date > l_due_date
       THEN
          IF l_receipt_date > l_maturity_date
          THEN
             l_maturity_date := l_receipt_date;
          END IF;
       ELSE
          IF l_maturity_date_rule = 'EARLIEST'
          THEN
             IF l_due_date < l_maturity_date OR
                l_first_application = TRUE
             THEN
                l_maturity_date := l_due_date;
             END IF;
          ELSIF l_maturity_date_rule = 'LATEST'
          THEN
             IF l_due_date > l_maturity_date OR
                l_first_application = TRUE
             THEN
                l_maturity_date := l_due_date;
             END IF;
          ELSE
             /* Do nothing */
             NULL;
          END IF;
       END IF;

    IF PG_DEBUG in ('Y', 'C')
    THEN
       arp_debug.debug('new maturity_date  = ' || l_maturity_date);
    END IF;

    /* end 8620127 */

    -- Step 1, update the cash receipt in the payment schedule table.
    --
    -- Note that amount applied from is passed if not null as this indicates
    -- that it is a cross currency application.  For cross currency
    -- applications the amount applied from holds the amount allocated
    -- from the receipt.  For same currency applications, the amount applied
    -- holds both the receipt and invoice amount applied.
    --

    -- Bug 6924942 - Start
    SELECT ps.class
	INTO l_class_var
	FROM ar_payment_schedules ps
	WHERE ps.payment_schedule_id = p_invoice_ps_id;
	-- Bug 6924942 - End

    arp_ps_util.update_receipt_related_columns(
                p_receipt_ps_id,
                nvl(p_amount_applied_from, p_amount_applied),
                p_apply_date,
                p_gl_date,
                l_rec_ra_rec.acctd_amount_applied_from,
                NULL_VAR,     -- NULL modified to NULL_VAR for bug 460959 (Oracle 8)
                l_maturity_date,
                l_class_var); 	-- Bug 6924942

    -- This is passed back to the client as the true acctd amount (calculated
    -- in the payment schedule utility procedure).
    p_acctd_amount_applied_from := l_rec_ra_rec.acctd_amount_applied_from;

    -- Step 2, create UNAPP row in receivable applications.
    --
    -- First we need to populate the receivable applications record with the
    -- required values.  Note nvl for amount applied again (see note above).
    --
    l_rec_ra_rec.status := 'UNAPP';
    l_rec_ra_rec.amount_applied := nvl(-p_amount_applied_from, -p_amount_applied);
    l_rec_ra_rec.amount_applied_from := -p_amount_applied_from;
    l_rec_ra_rec.trans_to_receipt_rate := null;
    l_rec_ra_rec.payment_schedule_id := p_receipt_ps_id;
    l_rec_ra_rec.application_type := 'CASH';
    l_rec_ra_rec.application_rule := '60.7';
    l_rec_ra_rec.program_id	:= -100103;
    l_rec_ra_rec.apply_date := p_apply_date;
    l_rec_ra_rec.gl_date := p_gl_date;
    l_rec_ra_rec.posting_control_id := -3;

    /* 14-APR-2000 jrautiai BR implementation
     * In specific BR scenario the UNAPP pair of application is not postable
     * See procedure description for more information */

    IF nvl(p_called_from,'NONE') = 'BR_FACTORED_WITH_RECOURSE' THEN -- jrautiai BR project
      l_rec_ra_rec.postable := 'N';
    END IF;

    l_rec_ra_rec.display := 'N';
    l_rec_ra_rec.ussgl_transaction_code := p_ussgl_transaction_code;
    l_rec_ra_rec.attribute_category := p_attribute_category;
    l_rec_ra_rec.attribute1 := p_attribute1;
    l_rec_ra_rec.attribute2 := p_attribute2;
    l_rec_ra_rec.attribute3 := p_attribute3;
    l_rec_ra_rec.attribute4 := p_attribute4;
    l_rec_ra_rec.attribute5 := p_attribute5;
    l_rec_ra_rec.attribute6 := p_attribute6;
    l_rec_ra_rec.attribute7 := p_attribute7;
    l_rec_ra_rec.attribute8 := p_attribute8;
    l_rec_ra_rec.attribute9 := p_attribute9;
    l_rec_ra_rec.attribute10 := p_attribute10;
    l_rec_ra_rec.attribute11 := p_attribute11;
    l_rec_ra_rec.attribute12 := p_attribute12;
    l_rec_ra_rec.attribute13 := p_attribute13;
    l_rec_ra_rec.attribute14 := p_attribute14;
    l_rec_ra_rec.attribute15 := p_attribute15;
    l_rec_ra_rec.global_attribute_category := p_global_attribute_category;
    l_rec_ra_rec.global_attribute1 := p_global_attribute1;
    l_rec_ra_rec.global_attribute2 := p_global_attribute2;
    l_rec_ra_rec.global_attribute3 := p_global_attribute3;
    l_rec_ra_rec.global_attribute4 := p_global_attribute4;
    l_rec_ra_rec.global_attribute5 := p_global_attribute5;
    l_rec_ra_rec.global_attribute6 := p_global_attribute6;
    l_rec_ra_rec.global_attribute7 := p_global_attribute7;
    l_rec_ra_rec.global_attribute8 := p_global_attribute8;
    l_rec_ra_rec.global_attribute9 := p_global_attribute9;
    l_rec_ra_rec.global_attribute10 := p_global_attribute10;
    l_rec_ra_rec.global_attribute11 := p_global_attribute11;
    l_rec_ra_rec.global_attribute12 := p_global_attribute12;
    l_rec_ra_rec.global_attribute13 := p_global_attribute13;
    l_rec_ra_rec.global_attribute14 := p_global_attribute14;
    l_rec_ra_rec.global_attribute15 := p_global_attribute15;
    l_rec_ra_rec.global_attribute16 := p_global_attribute16;
    l_rec_ra_rec.global_attribute17 := p_global_attribute17;
    l_rec_ra_rec.global_attribute18 := p_global_attribute18;
    l_rec_ra_rec.global_attribute19 := p_global_attribute19;
    l_rec_ra_rec.global_attribute20 := p_global_attribute20;

    --
    --
IF nvl(p_called_from,'NONE') <> 'AUTORECAPI' THEN -- autorecapi bichatte project

    arp_app_pkg.insert_p( l_rec_ra_rec,
                          l_rec_ra_rec.receivable_application_id );

END IF;

    -- Bug 6924942 - Start
    IF l_class_var IN ('CM', 'PMT') THEN
      UPDATE ar_receivable_applications
      SET include_in_accumulation = 'N'
      WHERE cash_receipt_id = l_rec_ra_rec.cash_receipt_id
      AND status = 'UNAPP';
    END IF;
    -- Bug 6924942 - End

    --------------------------------------------------------------------------
    -- Process the Transaction ...
    --
    -- This involves updating the transaction row in Payment Schedules
    -- and creating the APP row in receivable applications.
    --------------------------------------------------------------------------

/* END OF IF CASE THAT NEEDS TO BE REMOVED ONCE LLCA IS COMPLETE */

    -- Populate CC ID columns by selecting from ra_cust_trx_line_gl_dist and
    -- and payment schedule tables.
    --

    /* 14-APR-2000 jrautiai BR implementation
     * Moved into a procedure for BR transactions has the accounting in ar_distributions table.
     * instead of ra_cust_trx_line_gl_dist */

  --for PS -2, it should go in side the if condition

    IF (p_invoice_ps_id not in (-4,-5)) THEN

        ARP_PROCESS_APPLICATION.fetch_app_ccid(p_invoice_ps_id,
                                           l_inv_ra_rec.applied_customer_trx_id,
                                           l_inv_ra_rec.code_combination_id,
                                           l_source_type);

      -- Step 1, update the transaction in the payment schedule table.
    l_from_llca_call := from_llca_call;
--{HYULLCA
-- Not LLCA current process
IF l_from_llca_call     = 'N' THEN
arp_debug.debug(' LLCA application commit by pass maintenance of the invoice ps done by LLCA back ground');

      -- 5569488, for receipt where confirmation is required, pass the cash_receipt_id
      IF NULL_VAR.cash_receipt_id IS NULL AND NVL(p_called_from,'NONE') = 'AUTORECAPI' THEN
         NULL_VAR.cash_receipt_id := l_rec_ra_rec.cash_receipt_id ;
      END IF ;

    arp_ps_util.update_invoice_related_columns(
                'CASH',
                p_invoice_ps_id,
                p_amount_applied,
                p_earned_discount_taken,
                p_unearned_discount_taken,
                p_apply_date,
                p_gl_date,
                l_inv_ra_rec.acctd_amount_applied_to,
                l_inv_ra_rec.acctd_earned_discount_taken,
                l_inv_ra_rec.acctd_unearned_discount_taken,
                l_inv_ra_rec.line_applied,
                l_inv_ra_rec.tax_applied,
                l_inv_ra_rec.freight_applied,
                l_inv_ra_rec.receivables_charges_applied,
                l_inv_ra_rec.line_ediscounted,
                l_inv_ra_rec.tax_ediscounted,
                l_inv_ra_rec.freight_ediscounted,
                l_inv_ra_rec.charges_ediscounted,
                l_inv_ra_rec.line_uediscounted,
                l_inv_ra_rec.tax_uediscounted,
                l_inv_ra_rec.freight_uediscounted,
                l_inv_ra_rec.charges_uediscounted,
                l_inv_ra_rec.rule_set_id,
                NULL_VAR,
                l_rec_ra_rec.cash_receipt_id,
                l_ra_app_id,
                l_gt_id );
    -- This is passed back to the client as the true acctd amount (calculated
    -- in the payment schedule utility procedure).
    p_acctd_amount_applied_to := l_inv_ra_rec.acctd_amount_applied_to;

ELSE -- LLCA = 'Y'

arp_debug.debug(' LLCA application commit');

   arp_process_det_pkg.get_app_ra_amounts
     (p_gt_id         => l_gt_id,
      x_ra_rec        => l_inv_ra_rec);

arp_debug.debug('  Ra_id in GT from LLCA l_inv_ra_rec.receivable_application_id :'||l_inv_ra_rec.receivable_application_id);

 p_acctd_amount_applied_to := l_inv_ra_rec.acctd_amount_applied_to; /* 5189370 */

END IF;
--}
   END IF;
    -- Step 2, create APP row in receivable applications.
    --
    -- First we need to populate the receivable applications record with the
    -- required values.
    --

    l_inv_ra_rec.status 		:= 'APP';
    l_inv_ra_rec.amount_applied 	:= p_amount_applied;
    l_inv_ra_rec.amount_applied_from    := p_amount_applied_from;
    l_inv_ra_rec.trans_to_receipt_rate  := p_trans_to_receipt_rate;
    l_inv_ra_rec.cash_receipt_id 	:= l_rec_ra_rec.cash_receipt_id;
    l_inv_ra_rec.acctd_amount_applied_from := -l_rec_ra_rec.acctd_amount_applied_from;
    l_inv_ra_rec.payment_schedule_id 	:= p_receipt_ps_id;
    l_inv_ra_rec.applied_payment_schedule_id := p_invoice_ps_id;
    l_inv_ra_rec.earned_discount_taken 	:= p_earned_discount_taken;
    l_inv_ra_rec.unearned_discount_taken:= p_unearned_discount_taken;
    l_inv_ra_rec.application_type 	:= 'CASH';
    l_inv_ra_rec.application_rule       := '60.0';
    l_inv_ra_rec.program_id             := -100104;
    l_inv_ra_rec.apply_date 		:= p_apply_date;
    l_inv_ra_rec.gl_date 		:= p_gl_date;
    l_inv_ra_rec.posting_control_id 	:= -3;
    l_inv_ra_rec.display 		:= 'Y';
    l_inv_ra_rec.ussgl_transaction_code := p_ussgl_transaction_code;
    l_inv_ra_rec.attribute_category 	:= p_attribute_category;
    l_inv_ra_rec.attribute1 		:= p_attribute1;
    l_inv_ra_rec.attribute2 		:= p_attribute2;
    l_inv_ra_rec.attribute3 		:= p_attribute3;
    l_inv_ra_rec.attribute4 		:= p_attribute4;
    l_inv_ra_rec.attribute5 		:= p_attribute5;
    l_inv_ra_rec.attribute6 		:= p_attribute6;
    l_inv_ra_rec.attribute7 		:= p_attribute7;
    l_inv_ra_rec.attribute8 		:= p_attribute8;
    l_inv_ra_rec.attribute9 		:= p_attribute9;
    l_inv_ra_rec.attribute10 		:= p_attribute10;
    l_inv_ra_rec.attribute11 		:= p_attribute11;
    l_inv_ra_rec.attribute12 		:= p_attribute12;
    l_inv_ra_rec.attribute13 		:= p_attribute13;
    l_inv_ra_rec.attribute14 		:= p_attribute14;
    l_inv_ra_rec.attribute15 		:= p_attribute15;
    l_inv_ra_rec.global_attribute_category := p_global_attribute_category;
    l_inv_ra_rec.global_attribute1 := p_global_attribute1;
    l_inv_ra_rec.global_attribute2 := p_global_attribute2;
    l_inv_ra_rec.global_attribute3 := p_global_attribute3;
    l_inv_ra_rec.global_attribute4 := p_global_attribute4;
    l_inv_ra_rec.global_attribute5 := p_global_attribute5;
    l_inv_ra_rec.global_attribute6 := p_global_attribute6;
    l_inv_ra_rec.global_attribute7 := p_global_attribute7;
    l_inv_ra_rec.global_attribute8 := p_global_attribute8;
    l_inv_ra_rec.global_attribute9 := p_global_attribute9;
    l_inv_ra_rec.global_attribute10 := p_global_attribute10;
    l_inv_ra_rec.global_attribute11 := p_global_attribute11;
    l_inv_ra_rec.global_attribute12 := p_global_attribute12;
    l_inv_ra_rec.global_attribute13 := p_global_attribute13;
    l_inv_ra_rec.global_attribute14 := p_global_attribute14;
    l_inv_ra_rec.global_attribute15 := p_global_attribute15;
    l_inv_ra_rec.global_attribute16 := p_global_attribute16;
    l_inv_ra_rec.global_attribute17 := p_global_attribute17;
    l_inv_ra_rec.global_attribute18 := p_global_attribute18;
    l_inv_ra_rec.global_attribute19 := p_global_attribute19;
    l_inv_ra_rec.global_attribute20 := p_global_attribute20;
    l_inv_ra_rec.comments := p_comments;
    l_inv_ra_rec.applied_customer_trx_line_id := p_customer_trx_line_id;
    l_inv_ra_rec.payment_set_id               := p_payment_set_id;
    /* 03-JUL-2000 jrautiai BR implementation
     * Populate the link_to_trx_hist_id column */
    l_inv_ra_rec.link_to_trx_hist_id := p_link_to_trx_hist_id;
    l_inv_ra_rec.application_ref_type := p_application_ref_type;
    l_inv_ra_rec.application_ref_id := p_application_ref_id;
    l_inv_ra_rec.application_ref_num := p_application_ref_num;
    l_inv_ra_rec.secondary_application_ref_id := p_secondary_application_ref_id;
    l_inv_ra_rec.application_ref_reason := p_application_ref_reason;
    l_inv_ra_rec.customer_reference := p_customer_reference;
    l_inv_ra_rec.customer_reason := p_customer_reason;

    /* bug 5569488, Set the confirmation flag to N for receipt where confirmation is required */
    IF NVL(p_called_from,'NONE') = 'AUTORECAPI' THEN
      l_inv_ra_rec.confirmed_flag := 'N' ;
    END IF ;

    --
    -- Bug 2751910 - check if any active claims for this invoice.  Only
    -- create a new claim if no active claims exist
    /* Bug 5203336 : The existence of the claim should be checked against
       the installment */
    --
    BEGIN
      SELECT payment_schedule_id
      INTO   l_claim_trx_ps_id
      FROM   ar_payment_schedules
      WHERE  customer_trx_id = l_inv_ra_rec.applied_customer_trx_id
      AND    payment_schedule_id = l_inv_ra_rec.applied_payment_schedule_id
/*      AND    NVL(active_claim_flag,'N') <> 'N' Bug 10178153, manishri */
      AND    NVL(active_claim_flag,'N') not in  ('N','C') /* Bug 10178153, manishri*/
      AND    ROWNUM = 1;
    EXCEPTION
      WHEN OTHERS THEN
        l_claim_trx_ps_id := NULL;
    END;

    IF ((l_inv_ra_rec.application_ref_type = 'CLAIM' OR
         l_claim_trx_ps_id IS NOT NULL) AND
        NVL(p_called_from,'RAPI') <> 'TRADE_MANAGEMENT') THEN
      OPEN c_claim_trx_details(l_inv_ra_rec.applied_customer_trx_id);
      FETCH c_claim_trx_details INTO l_exchange_rate_type
                                   , l_exchange_rate_date
                                   , l_exchange_rate
                                   , l_trx_number
                                   , l_cust_trx_type_id
                                   , l_customer_id
                                   , l_bill_to_site_use_id
                                   , l_ship_to_site_use_id
                                   , l_salesrep_id
                                   , l_legal_entity_id;
      CLOSE c_claim_trx_details;
      OPEN c_claim_rct_details(l_inv_ra_rec.cash_receipt_id);
      FETCH c_claim_rct_details INTO l_receipt_number;
      CLOSE c_claim_rct_details;
      IF p_amount_due_remaining IS NULL THEN
        OPEN c_trx_amount_due(p_invoice_ps_id);
        FETCH c_trx_amount_due INTO l_trx_amount_due;
        CLOSE c_trx_amount_due;
        l_claim_amount := l_trx_amount_due ;
      ELSE
        l_claim_amount := p_amount_due_remaining;
      END IF;

      IF (l_claim_trx_ps_id IS NOT NULL ) THEN
         l_claim_id := NULL;
         update_claim(
              p_claim_id             =>  l_claim_id
            , p_invoice_ps_id        =>  l_claim_trx_ps_id
            , p_customer_trx_id      =>  l_inv_ra_rec.applied_customer_trx_id
            , p_amount               =>  l_claim_amount
            , p_amount_applied       =>  p_amount_applied
            , p_apply_date           =>  p_apply_date
            , p_cash_receipt_id      =>  l_inv_ra_rec.cash_receipt_id
            , p_receipt_number       =>  l_receipt_number
            , p_action_type          =>  'A'
            , x_claim_reason_code_id =>  l_claim_reason_code_id
            , x_claim_reason_name    =>  l_claim_reason_name
            , x_claim_number         =>  l_inv_ra_rec.application_ref_num
            , x_return_status        =>  x_return_status
            , x_msg_count            =>  x_msg_count
            , x_msg_data             =>  x_msg_data
            , p_reason_id            =>  to_number(p_application_ref_reason)--Yao Zhang add for bug 10197191
            );
         -- Bug 3178008 - store the claim_id that is returned
         l_inv_ra_rec.secondary_application_ref_id := l_claim_id;


      ELSIF (l_inv_ra_rec.application_ref_type = 'CLAIM' AND
        l_inv_ra_rec.application_ref_num IS NULL)
      THEN
 --Bug 1812328 : added parameter p_invoice_ps_id to the create_claim() procedure.
 --Bug 1932026 : added dff parameters
 --Bug 2361331 : added p_salesrep_id
 --Bug 5495310 : added p_apply_date
        create_claim(
              p_amount               => l_claim_amount
            , p_amount_applied       => p_amount_applied
            , p_currency_code        => p_invoice_currency_code
            , p_exchange_rate_type   => l_exchange_rate_type
            , p_exchange_rate_date   => l_exchange_rate_date
            , p_exchange_rate        => l_exchange_rate
            , p_customer_trx_id      => l_inv_ra_rec.applied_customer_trx_id
            , p_invoice_ps_id        => p_invoice_ps_id
            , p_cust_trx_type_id     => l_cust_trx_type_id
            , p_trx_number           => l_trx_number
            , p_cust_account_id      => l_customer_id
            , p_bill_to_site_id      => l_bill_to_site_use_id
            , p_ship_to_site_id      => l_ship_to_site_use_id
            , p_salesrep_id          => l_salesrep_id
            , p_customer_ref_date    => NULL
            , p_customer_ref_number  => p_customer_reference
            , p_cash_receipt_id      => l_inv_ra_rec.cash_receipt_id
            , p_receipt_number       => l_receipt_number
            , p_comments             => p_comments
            , p_reason_id            => to_number(p_application_ref_reason)
            , p_customer_reason      => p_customer_reason
            , p_apply_date           => p_apply_date
            , p_attribute_category   => p_attribute_category
            , p_attribute1           => p_attribute1
            , p_attribute2           => p_attribute2
            , p_attribute3           => p_attribute3
            , p_attribute4           => p_attribute4
            , p_attribute5           => p_attribute5
            , p_attribute6           => p_attribute6
            , p_attribute7           => p_attribute7
            , p_attribute8           => p_attribute8
            , p_attribute9           => p_attribute9
            , p_attribute10          => p_attribute10
            , p_attribute11          => p_attribute11
            , p_attribute12          => p_attribute12
            , p_attribute13          => p_attribute13
            , p_attribute14          => p_attribute14
            , p_attribute15          => p_attribute15
            , x_return_status        => x_return_status
            , x_msg_count            => x_msg_count
            , x_msg_data             => x_msg_data
            , x_claim_id             => l_inv_ra_rec.secondary_application_ref_id
            , x_claim_number         => l_inv_ra_rec.application_ref_num
            , x_claim_reason_name    => x_claim_reason_name
	    , p_legal_entity_id      => l_legal_entity_id);
      END IF;

      /* Bug 3773036 - treat all non success errors the same and ensure
         errors returned from TM are displayed */
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        RAISE trade_mgt_err;
      END IF;

      IF l_inv_ra_rec.application_ref_type IS NULL THEN
        l_inv_ra_rec.application_ref_type := 'CLAIM';
      END IF;
    END IF;

    x_application_ref_id  := l_inv_ra_rec.secondary_application_ref_id;
    x_application_ref_num := l_inv_ra_rec.application_ref_num;

    -- Call the applications table handler to create the APP row.
    --
    arp_app_pkg.insert_p( l_inv_ra_rec,
                          l_ra_app_id );

    /* 5677984 - copy l_ra_app_id into l_inv_ra_rec to preserve it for
       later processing */
    l_inv_ra_rec.receivable_application_id := l_ra_app_id;

arp_debug.debug('Calling arp_app_pkg.insert_p and created l_inv_ra_rec.receivable_application_id :'||
l_inv_ra_rec.receivable_application_id);

     --apandit
     --Bug : 2641517 raise Apply business event.
       AR_BUS_EVENT_COVER.Raise_CR_Apply_Event
                       (l_inv_ra_rec.receivable_application_id);


   /* 14-APR-2000 jrautiai BR implementation
      If the row is not postable, accounting is not created */

    l_ae_doc_rec.document_type             := 'RECEIPT';
    l_ae_doc_rec.document_id               := l_rec_ra_rec.cash_receipt_id;
    l_ae_doc_rec.accounting_entity_level   := 'ONE';
    l_ae_doc_rec.source_table              := 'RA';
    l_ae_doc_rec.override_source_type      := l_source_type;

   IF nvl(l_rec_ra_rec.postable,'Y') = 'Y' THEN -- jrautiai BR project
     --
     --Release 11.5 VAT changes, create paired UNAPP record accounting
     --in ar_distributions
     --
      l_ae_doc_rec.source_id                 := l_rec_ra_rec.receivable_application_id;
      l_ae_doc_rec.source_id_old             := l_inv_ra_rec.receivable_application_id; --Paired application id
      l_ae_doc_rec.other_flag                := 'PAIR';


     /* A receipt application can be either line or trx level (LLCA=Y for line).
        However, if the discount is recoverable, we may need to override the
        LLCA flag to Y (when it was previously N)
     */
     IF NVL(l_from_llca_call,'N') = 'N' AND
        NVL(l_gt_id, 0) <> 0
     THEN
        /* overriding flag */
        l_from_llca_call := 'Y';
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_debug.debug('from_llca_call was N (not line level), overriding to Y');
           arp_debug.debug('  l_gt_id = ' || l_gt_id);
        END IF;

        /* 4607809 - distribute recoverable entries before acct_main call */
        arp_etax_util.distribute_recoverable(
               l_inv_ra_rec.receivable_application_id, l_gt_id);
-- was l_rec_ra_rec?
     END IF;

     IF nvl(p_called_from,'NONE') <> 'AUTORECAPI' THEN -- autorecapi bichatte project

      arp_acct_main.Create_Acct_Entry(
                p_ae_doc_rec    => l_ae_doc_rec,
                p_client_server => NULL,
                p_from_llca_call =>  l_from_llca_call,
                p_gt_id          =>  l_gt_id,
                p_called_from    =>  p_called_from);
     END IF;
   END IF;

   --
   --Release 11.5 VAT changes, create APP record accounting
   --in ar_distributions
   --
    l_ae_doc_rec.source_id                 := l_inv_ra_rec.receivable_application_id;
    l_ae_doc_rec.source_id_old             := '';
    l_ae_doc_rec.other_flag                := '';
    l_ae_doc_rec.deferred_tax              := p_move_deferred_tax; /* jrautiai BR implementation */

  --Bug 1329091 - PS is updated before Accounting Engine Call
    l_ae_doc_rec.pay_sched_upd_yn := 'Y';

--    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);
   IF nvl(p_called_from,'NONE') <> 'AUTORECAPI' THEN -- autorecapi bichatte project

      arp_acct_main.Create_Acct_Entry(
                p_ae_doc_rec    => l_ae_doc_rec,
                p_client_server => NULL,
                p_from_llca_call =>  l_from_llca_call,
                p_gt_id          =>  l_gt_id,
                p_called_from    =>  p_called_from );

     /* Bug 4910860
        Check if the accounting entries balance */
      IF nvl(p_module_name,'X') = 'RAPI' THEN
         l_called_from_api := 'Y';
      ELSE
         l_called_from_api := 'N';
      END IF;
/* Start FP Bug 5594328 - Base Bug 55878178 changed the call to check_appln_balance
	with check_recp_balance as there could be problem in call to appln_balance
	in case of fatcor with recourse case */

IF nvl(p_called_from,'NONE') NOT IN ('AUTORECAPI','AUTORECAPI2') THEN
    arp_balance_check.Check_Recp_Balance(l_rec_ra_rec.cash_receipt_id,
                                          l_request_id,l_called_from_api);
END IF;
/*
      arp_balance_check.Check_Appln_Balance(l_inv_ra_rec.receivable_application_id, -- APP rec_app_id
                                            l_rec_ra_rec.receivable_application_id,   -- UNAPP rec_app_id
                                            NULL,
                                            l_called_from_api);
*/ /* End FP Bug 5594328 SPDIXIT */

      END IF;

arp_debug.debug('l_rec_ra_rec.receivable_application_id:'||l_rec_ra_rec.receivable_application_id);
arp_debug.debug('l_inv_ra_rec.receivable_application_id:'||l_inv_ra_rec.receivable_application_id);
      ----Autoreceipis performance changes nproddut
      IF nvl(p_called_from,'NONE') NOT IN ('AUTORECAPI','AUTORECAPI2','CUSTRECAPIBULK') THEN
	IF l_rec_ra_rec.receivable_application_id IS NOT NULL THEN
	   l_xla_ev_rec.xla_from_doc_id := l_rec_ra_rec.receivable_application_id;
	   l_xla_ev_rec.xla_to_doc_id   := l_rec_ra_rec.receivable_application_id;
	   l_xla_ev_rec.xla_mode        := 'O';
	   l_xla_ev_rec.xla_call        := 'B';
	   l_xla_ev_rec.xla_doc_table := 'APP';
	   ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
	END IF;
	--BUG#5416481
	IF l_inv_ra_rec.receivable_application_id IS NOT NULL THEN
	   l_xla_ev_rec.xla_from_doc_id := l_inv_ra_rec.receivable_application_id;
	   l_xla_ev_rec.xla_to_doc_id   := l_inv_ra_rec.receivable_application_id;
	   l_xla_ev_rec.xla_mode        := 'O';
	   l_xla_ev_rec.xla_call        := 'B';
	   l_xla_ev_rec.xla_doc_table := 'APP';
	   ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
	END IF;
      END IF;

    -- Return the receivable_application_id for the APP row to the client.
    --
    p_out_rec_application_id := l_inv_ra_rec.receivable_application_id;


    ------------------------------------------------
    -- Finally update cash receipt status...
    --
    ------------------------------------------------

    -- First, set ar_cash_receipt record values to dummy.
    -- This is to distinguish between updateable NULL and NULL
    -- value (dummy) which means that column is not to be updated.
    --
    arp_cash_receipts_pkg.set_to_dummy(l_cr_rec);

    -- Get the current amount that is On Account for this receipt.
    -- This is used next to determine it the receipt has been
    -- fully applied.
    --
    --No need to execute the SQL if the call is from Autoreceipts [Bug 6660834]
    IF nvl(p_called_from,'NONE') NOT IN ('AUTORECAPI','AUTORECAPI2') THEN
      select nvl(sum(ra.amount_applied),0)
      into   l_on_account_total
      from   ar_receivable_applications ra
      where  ra.cash_receipt_id = l_rec_ra_rec.cash_receipt_id
      and    ra.status IN ('ACC','OTHER ACC');
    END IF;

    -- Cash receipt must be fully applied in order to set the status
    -- to 'APP'.
    --
    -- We include the total amount that is On Account as this is
    -- not included in the Payment Schedules, Amount Due Remaining
    -- total for the receipt.
    --
    -- Note that we use amount applied from first, as this is the applied
    -- receipt amount for cross currency applications.  It is null for
    -- same currency, so use amount applied instead as this is both the
    -- the receipt and invoice amount applied.
    --
    IF (l_amount_due_remaining + l_on_account_total + nvl(p_amount_applied_from, p_amount_applied) < 0)
    THEN
      l_cr_rec.status           := 'UNAPP';
    ELSE
      l_cr_rec.status           := 'APP';
    END IF;

    l_cr_rec.cash_receipt_id  := l_rec_ra_rec.cash_receipt_id;

    -- Update cash receipt status.
    --
    arp_cash_receipts_pkg.update_p(
          l_cr_rec
	, l_rec_ra_rec.cash_receipt_id);

    -- Update the batch status if receipt has a batch.
    -- Bug 8974877 : If the batch is an automatic receipt batch, we need not update the batch for each
    -- and every receipt. The batch status will be updated finally in the AR_AUTOREC_API.
    IF (ln_batch_id IS NOT NULL AND nvl(p_called_from,'NONE') NOT IN ('AUTORECAPI','AUTORECAPI2')) THEN
      arp_rw_batches_check_pkg.update_batch_status(ln_batch_id,p_called_from);	--Bug7194951
    END IF;

   /*---------------------------------------------------------------------------------+
    |  12-JUL-2000 J Rautiainen BR Implementation                                     |
    |  If Bills receivable PS is closed or opened we need to create the corresponding |
    |  transaction history record. This logic is only for normal receipt applications |
    |  outside the BR remittance program, since for BR programs the record will be    |
    |  created by the BR API.                                                         |
    +---------------------------------------------------------------------------------*/

    IF NVL(l_old_ps_rec.class,'INV') = 'BR'
       AND NVL(p_called_from,'NONE') not in ('BR_REMITTED','BR_FACTORED_WITH_RECOURSE','BR_FACTORED_WITHOUT_RECOURSE') THEN

     /*------------------------------------+
      |  Create transaction history record |
      +------------------------------------*/

      ARP_PROC_TRANSACTION_HISTORY.create_trh_for_receipt_act(l_old_ps_rec,
                                                              l_inv_ra_rec,
                                                              'ARCEAPPB');


    END IF;

    -- RAM-C changes begin
    -- call revenue management engine's receipt analyzer for revenue related
    -- impact of this application.

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'calling receipt_analyzer in application mode');
    END IF;

    ar_revenue_management_pvt.receipt_analyzer (
      p_mode => ar_revenue_management_pvt.c_receipt_application_mode,
      p_customer_trx_id       => l_inv_ra_rec.applied_customer_trx_id,
      p_acctd_amount_applied  => l_inv_ra_rec.acctd_amount_applied_to,
      p_exchange_rate 	      => l_exchange_rate,
      p_invoice_currency_code => p_invoice_currency_code,
      p_tax_applied 	      => l_inv_ra_rec.tax_applied,
      p_charges_applied       => l_inv_ra_rec.receivables_charges_applied,
      p_freight_applied       => l_inv_ra_rec.freight_applied,
      p_line_applied 	      => l_inv_ra_rec.line_applied,
      p_gl_date               => p_gl_date);

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'returned from receipt_analyzer');
    END IF;

    -- RAM-C changes end

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'arp_process_application.receipt_application()-' );
    END IF;

    EXCEPTION
        /* Bug 3773036 - Trade management errors treated separately to
           ensure calling program displays TM error */
        WHEN trade_mgt_err THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug('Error occured in Trade Management: ' ||
		    'EXCEPTION: arp_process_application.receipt_application' );
              END IF;
        WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug(
		    'EXCEPTION: arp_process_application.receipt_application' );
              END IF;
              RAISE;
END receipt_application;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_receipt_appln_args                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to receipt_application procedure.            |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_receipt_ps_id - PS Id of the receipt                    |
 |                 p_invoice_ps_id - PS Id of the transaction                |
 |                 p_amount_applied - TO amount                              |
 |                 p_amount_applied_from - FROM amount                       |
 | 		   p_trans_to_receipt_rate - Cross currency rate             |
 |                 p_receipt_currency_code - Currency of the receipt         |
 |                 p_invoice_currency_code - Currency of the transaction     |
 |                 p_earned_discount_taken - Earned Discount taken           |
 |                 p_unearned_discount_taken - UnEarned Discount taken       |
 |                 p_apply_date - Application date                           |
 |                 p_gl_date    - GL Date                                    |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |
 | 17-Jul-97	K.Lawrance	Release 11.
 |				Added parameters to check for cross currency
 |				applications and the population of the amount
 |				applied from and trans to receipt rate.
 |
 +===========================================================================*/
PROCEDURE  validate_receipt_appln_args(
	p_receipt_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
	p_invoice_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_amount_applied IN ar_receivable_applications.amount_applied%TYPE,
        p_amount_applied_from IN ar_receivable_applications.amount_applied_from%TYPE,
        p_trans_to_receipt_rate IN ar_receivable_applications.trans_to_receipt_rate%TYPE,
        p_invoice_currency_code IN ar_payment_schedules.invoice_currency_code%TYPE,
        p_receipt_currency_code IN ar_cash_receipts.currency_code%TYPE,
        p_earned_discount_taken IN ar_receivable_applications.earned_discount_taken%TYPE,
        p_unearned_discount_taken IN ar_receivable_applications.unearned_discount_taken%TYPE,
        p_apply_date IN ar_receivable_applications.apply_date%TYPE,
	p_gl_date IN ar_receivable_applications.gl_date%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'arp_process_application.validate_receipt_appln_args()+' );
    END IF;

    -- Check for mandatory parameters.
    IF ( p_receipt_ps_id IS NULL OR
         p_invoice_ps_id IS NULL OR
	 p_apply_date    IS NULL OR
         p_gl_date       IS NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF ( p_amount_applied IS NULL AND
         p_earned_discount_taken IS NULL AND
	 p_unearned_discount_taken IS NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;

    ------------------------------------------------------------------
    -- Check that if the currency code of the receipt is different to
    -- that of the invoice, i.e. cross currency application, that the
    -- amount_applied_from and trans_to_receipt_rate are both
    -- populated.
    ------------------------------------------------------------------
    IF ( p_receipt_currency_code <> p_invoice_currency_code
       AND (SIGN(p_invoice_ps_id) <> -1) AND
         ( p_amount_applied_from is NULL OR
           p_trans_to_receipt_rate is NULL ) ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;


    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'arp_process_application.validate_receipt_appln_args()-' );
    END IF;

    EXCEPTION
         WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_debug.debug(  'EXCEPTION: arp_process_application.validate_receipt_appln_args' );
           END IF;
           RAISE;
END validate_receipt_appln_args;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    cm_application                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Do all actions neccessary to update PS rows and insert APP             |
 |    row in RA table when a CM is applied to an invoice.                    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED -                                 |
 |      arp_ps_util.update_invoice_related_columns                           |
 |      arp_ps_util.update_cm_related_columns                                |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_cm_ps_id      - PS Id of the Credit Memo                |
 |                 p_invoice_ps_id - PS Id of the transaction                |
 |                 p_amount_applied - TO amount                              |
 |                 p_apply_date - Application date                           |
 |                 p_gl_date    - GL Date                                    |
 |                 p_ussgl_transaction_code - USSGL transaction code         |
 |                 p_customer_trx_line_id - Line of the transaction applied  |
 |                                                                           |
 |                 OTHER DESCRIPTIVE FLEX columns                            |
 |      	   p_module_name  - Name of the module that called this      |
 |				    procedure   			     |
 |      	   p_module_version  - Version of the module that called this|
 |			               procedure                             |
 |              OUT:                                                         |
 |                 p_receivable_application_id - Identifier of RA            |
 |                 p_acctd_amount_applied_from - Rounded acctd FROM amount   |
 |                 p_acctd_amount_applied_to - Rounded acctd TO amount       |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES  -                                        	                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 | 08/29/95	Ganesh Vaidee	Created                                      |
 | 02/06/1996	Harri Kaukovuo	Added new parameters                         |
 |					p_customer_trx_line_id               |
 |					p_out_rec_application_id             |
 |  10/17/1996  Karen Lawrance  Added code to prevent the creation of more   |
 |                              than one application against the same receipt|
 |                              and invoice.                                 |
 |  05/06/1997  Karen Lawrance  Bug fix #481761.  Fixed application rule.    |
 |  07/25/1997	Karen Lawrance	Release 11.                                  |
 |                              Added acctd amount from and to as OUT NOCOPY        |
 |				parameters to be consistent with receipt     |
 |				applications.                                |
 |				Also cleaned up code and added some more     |
 |				comments.                                    |
 |  08/21/1997	Tasman Tang	Added global_attribute_category,	     |
 |				global_attribute[1-20] for global            |
 |				descriptive flexfield			     |
 |  13-Jun-00  Satheesh Nambiar Bug 1329091 - Passing a new parameter
 |                              pay_sched_upd_yn to accounting engine
 |                              to acknowldge PS is updated.
 |  03-Sep-02  Debbie Jancis  	Added call to mrc_engine3 for processing
 |                              mrc data for ar_receivable_applications
 |  28-Apr-03   Rahna Kader     Bug 1659928: Now the program checks for      |
 | 				over application before the applications     |
 | 				are saved                                    |
 |  12-Mar-04   Bhushan Dhotkar Bug 2662270: Added a column p_comments
 +===========================================================================*/
PROCEDURE cm_application(
	p_cm_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
	p_invoice_ps_id	IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_amount_applied IN ar_receivable_applications.amount_applied%TYPE,
        p_apply_date IN ar_receivable_applications.apply_date%TYPE,
	p_gl_date IN ar_receivable_applications.gl_date%TYPE,
	p_ussgl_transaction_code IN ar_receivable_applications.ussgl_transaction_code%TYPE,
	p_attribute_category IN ar_receivable_applications.attribute_category%TYPE,
	p_attribute1 IN ar_receivable_applications.attribute1%TYPE,
	p_attribute2 IN ar_receivable_applications.attribute2%TYPE,
	p_attribute3 IN ar_receivable_applications.attribute3%TYPE,
	p_attribute4 IN ar_receivable_applications.attribute4%TYPE,
	p_attribute5 IN ar_receivable_applications.attribute5%TYPE,
	p_attribute6 IN ar_receivable_applications.attribute6%TYPE,
	p_attribute7 IN ar_receivable_applications.attribute7%TYPE,
	p_attribute8 IN ar_receivable_applications.attribute8%TYPE,
	p_attribute9 IN ar_receivable_applications.attribute9%TYPE,
	p_attribute10 IN ar_receivable_applications.attribute10%TYPE,
	p_attribute11 IN ar_receivable_applications.attribute11%TYPE,
	p_attribute12 IN ar_receivable_applications.attribute12%TYPE,
	p_attribute13 IN ar_receivable_applications.attribute13%TYPE,
	p_attribute14 IN ar_receivable_applications.attribute14%TYPE,
	p_attribute15 IN ar_receivable_applications.attribute15%TYPE,
        p_global_attribute_category IN ar_receivable_applications.global_attribute_category%TYPE,
        p_global_attribute1 IN ar_receivable_applications.global_attribute1%TYPE,
        p_global_attribute2 IN ar_receivable_applications.global_attribute2%TYPE,
        p_global_attribute3 IN ar_receivable_applications.global_attribute3%TYPE,
        p_global_attribute4 IN ar_receivable_applications.global_attribute4%TYPE,
        p_global_attribute5 IN ar_receivable_applications.global_attribute5%TYPE,
        p_global_attribute6 IN ar_receivable_applications.global_attribute6%TYPE,
        p_global_attribute7 IN ar_receivable_applications.global_attribute7%TYPE,
        p_global_attribute8 IN ar_receivable_applications.global_attribute8%TYPE,
        p_global_attribute9 IN ar_receivable_applications.global_attribute9%TYPE,
        p_global_attribute10 IN ar_receivable_applications.global_attribute10%TYPE,
        p_global_attribute11 IN ar_receivable_applications.global_attribute11%TYPE,
        p_global_attribute12 IN ar_receivable_applications.global_attribute12%TYPE,
        p_global_attribute13 IN ar_receivable_applications.global_attribute13%TYPE,
        p_global_attribute14 IN ar_receivable_applications.global_attribute14%TYPE,
        p_global_attribute15 IN ar_receivable_applications.global_attribute15%TYPE,
        p_global_attribute16 IN ar_receivable_applications.global_attribute16%TYPE,
        p_global_attribute17 IN ar_receivable_applications.global_attribute17%TYPE,
        p_global_attribute18 IN ar_receivable_applications.global_attribute18%TYPE,
        p_global_attribute19 IN ar_receivable_applications.global_attribute19%TYPE,
        p_global_attribute20 IN ar_receivable_applications.global_attribute20%TYPE,
        p_customer_trx_line_id IN NUMBER,
        p_comments IN ar_receivable_applications.comments%TYPE DEFAULT NULL,  --bug2662270
        p_module_name IN VARCHAR2,
        p_module_version IN VARCHAR2,
        -- OUT NOCOPY
        p_out_rec_application_id OUT NOCOPY NUMBER,
        p_acctd_amount_applied_from OUT NOCOPY ar_receivable_applications.acctd_amount_applied_from%TYPE,
        p_acctd_amount_applied_to OUT NOCOPY ar_receivable_applications.acctd_amount_applied_to%TYPE) IS

l_inv_ra_rec     ar_receivable_applications%ROWTYPE;
l_cm_ps_rec      ar_payment_schedules%ROWTYPE;
l_ae_doc_rec     ae_doc_rec_type;
   l_source_type                ar_distributions.source_type%TYPE; /* jrautiai BR implementation */
l_flag		 char; /* added for bug 2318048 */

   /* Bug fix 1659928 */
   l_inv_bal_amount             NUMBER;
   l_inv_orig_amount            NUMBER;
   l_allow_over_application     VARCHAR2(1);
   l_effective_amount_applied   NUMBER;

  --Bug#2750340
  l_xla_ev_rec      arp_xla_events.xla_events_type;
  l_xla_doc_table   VARCHAR2(20);

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'arp_process_application.cm_application()+' );
    END IF;

    -- Output IN parameters
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'CM PS Id.               : '||TO_CHAR( p_cm_ps_id ) );
       arp_debug.debug(   'Invoice PS Id.          : '||TO_CHAR( p_invoice_ps_id ) );
       arp_debug.debug(   'Amount Applied          : '||TO_CHAR( p_amount_applied ) );
       arp_debug.debug(   'Gl Date                 : '||TO_CHAR( p_gl_date ) );
       arp_debug.debug(   'Apply Date              : '||TO_CHAR( p_apply_date ) );
       arp_debug.debug(   'Customer_trx_line_id    : '||TO_CHAR(p_customer_trx_line_id));
    END IF;

    -----------------------------------------------------
    --  KML 10/17/1996
    --  Prevent the creation of more than one application
    --  against the same credit memo and invoice.
    --  Bug #505538
    --  Modified the condition to allow application for
    --  invoice applied to same Credit Memo for different
    --  invoice lines.
    -----------------------------------------------------
    DECLARE
      l_found   varchar2(1) := 'N';
    BEGIN
      IF p_customer_trx_line_id IS NULL THEN
        select 'Y'
        into   l_found
        from   ar_receivable_applications rap
        where  rap.payment_schedule_id = p_cm_ps_id
        and    rap.applied_payment_schedule_id = p_invoice_ps_id
        and    rap.display = 'Y'
        and    rap.status = 'APP';
      ELSE
        select 'Y'
        into   l_found
        from   ar_receivable_applications rap
        where  rap.payment_schedule_id = p_cm_ps_id
        and    rap.applied_payment_schedule_id = p_invoice_ps_id
        and    rap.applied_customer_trx_line_id = p_customer_trx_line_id
        and    rap.display = 'Y'
        and    rap.status = 'APP';
      END IF;

      if l_found = 'Y' then
        raise too_many_rows;
      end if;

    EXCEPTION
      when no_data_found then
        null;
      when too_many_rows then
        FND_MESSAGE.set_name ('AR', 'AR_RW_PAID_INVOICE_TWICE' );
        APP_EXCEPTION.raise_exception;
    END;

     /* Bug fix 1659928
       Check if the payment schedule of this transaction is over applied and
       the transaction type does not allow overapplication */

       select   ps.amount_due_remaining,ps.amount_due_original,ctt.allow_overapplication_flag
       into     l_inv_bal_amount, l_inv_orig_amount, l_allow_over_application
       from     ra_cust_trx_types ctt, ar_payment_schedules ps
       where    ps.payment_schedule_id = p_invoice_ps_id
       and      ps.cust_trx_type_id = ctt.cust_trx_type_id;

       l_effective_amount_applied := NVL(p_amount_applied,0) ;

       IF l_allow_over_application ='N'
        AND arp_deduction.overapplication_indicator(l_inv_orig_amount,
                                                    l_inv_bal_amount,
                                                    l_effective_amount_applied) ='Y' THEN
          FND_MESSAGE.set_name ('AR', 'AR_CKAP_OVERAPP' );
          APP_EXCEPTION.raise_exception;
       END IF;

    /* End bug fix 1659928 */

    -- Validate the parameters that have been passed to the procedure.
    --
    IF ( p_module_name IS NOT NULL AND
         p_module_version IS NOT NULL ) THEN
         validate_cm_appln_args( p_cm_ps_id,
                                 p_invoice_ps_id,
                                 p_amount_applied,
        			 p_apply_date,
                                 p_gl_date);
    END IF;

    --------------------------------------------------------------------------
    -- Process the Applied Transaction...
    --
    --------------------------------------------------------------------------

    -- Populate CC ID columns by selecting from ra_cust_trx_line_gl_dist table
    -- and Payment Schedule table.
    --

    /* 14-APR-2000 jrautiai BR implementation
     * Moved into a procedure for BR transactions has the accounting in ar_distributions table.
     * instead of ra_cust_trx_line_gl_dist */

    ARP_PROCESS_APPLICATION.fetch_app_ccid(p_invoice_ps_id,
                                           l_inv_ra_rec.applied_customer_trx_id,
                                           l_inv_ra_rec.code_combination_id,
                                           l_source_type);

    arp_ps_util.update_invoice_related_columns(
                'CM',
                p_invoice_ps_id,
                p_amount_applied,
                NULL,   /* Earned discount taken */
                NULL,   /* UnEarned discount taken */
                p_apply_date,
                p_gl_date,
                l_inv_ra_rec.acctd_amount_applied_to,
                l_inv_ra_rec.acctd_earned_discount_taken,
                l_inv_ra_rec.acctd_unearned_discount_taken,
                l_inv_ra_rec.line_applied,
                l_inv_ra_rec.tax_applied,
                l_inv_ra_rec.freight_applied,
                l_inv_ra_rec.receivables_charges_applied,
                l_inv_ra_rec.line_ediscounted,
                l_inv_ra_rec.tax_ediscounted,
                l_inv_ra_rec.freight_ediscounted,
                l_inv_ra_rec.charges_ediscounted,
                l_inv_ra_rec.line_uediscounted,
                l_inv_ra_rec.tax_uediscounted,
                l_inv_ra_rec.freight_uediscounted,
                l_inv_ra_rec.charges_uediscounted,
                l_inv_ra_rec.rule_set_id,
                NULL_VAR );     /* NULL modified to NULL_VAR  for bug 460959 - Oracle 8 */

    -- This is passed back to the client as the true acctd amount (calculated
    -- in the payment schedule utility procedure).
    p_acctd_amount_applied_to := l_inv_ra_rec.acctd_amount_applied_to;

    --------------------------------------------------------------------------
    -- Process the On-Account Credit...
    --
    --------------------------------------------------------------------------

    -- Get customer_trx_id of CM, from PS table. Pass the selected row
    -- to update_cm_related_columns procedure.
    --
    SELECT *
    INTO   l_cm_ps_rec
    FROM   ar_payment_schedules
    WHERE  payment_schedule_id = p_cm_ps_id;
    --
    arp_ps_util.update_cm_related_columns(
                p_cm_ps_id,
                p_amount_applied,
                l_inv_ra_rec.line_applied,
                l_inv_ra_rec.tax_applied,
                l_inv_ra_rec.freight_applied,
                l_inv_ra_rec.receivables_charges_applied,
                p_apply_date,
                p_gl_date,
                l_inv_ra_rec.acctd_amount_applied_from,
                l_cm_ps_rec );

/* Added the following code for bug 2318048. If CM is postable then only make
   the APP row postable */

    select NVL(ctt.post_to_gl,'N') into l_flag
    from   ra_cust_trx_types ctt,
    	   ar_payment_schedules ps
    where  ctt.cust_trx_type_id = ps.cust_trx_type_id
    and    ps.payment_schedule_id = p_cm_ps_id;

    If l_flag = 'Y' then
	l_inv_ra_rec.postable := 'Y';
    else
    	l_inv_ra_rec.postable := 'N';
    End if;

    -- This is passed back to the client as the true acctd amount (calculated
    -- in the payment schedule utility procedure).
    p_acctd_amount_applied_from := l_inv_ra_rec.acctd_amount_applied_from;

    l_inv_ra_rec.customer_trx_id := l_cm_ps_rec.customer_trx_id;
    l_inv_ra_rec.payment_schedule_id := p_cm_ps_id;
    l_inv_ra_rec.applied_payment_schedule_id := p_invoice_ps_id;
    l_inv_ra_rec.amount_applied := p_amount_applied;
    l_inv_ra_rec.status := 'APP';
    l_inv_ra_rec.application_type := 'CM';

    l_inv_ra_rec.application_rule := '75';
    l_inv_ra_rec.program_id     := -100105;

    l_inv_ra_rec.apply_date := p_apply_date;
    l_inv_ra_rec.gl_date := p_gl_date;
    l_inv_ra_rec.posting_control_id := -3;
    l_inv_ra_rec.display := 'Y';
    l_inv_ra_rec.ussgl_transaction_code := p_ussgl_transaction_code;
    l_inv_ra_rec.attribute_category := p_attribute_category;
    l_inv_ra_rec.attribute1 := p_attribute1;
    l_inv_ra_rec.attribute2 := p_attribute2;
    l_inv_ra_rec.attribute3 := p_attribute3;
    l_inv_ra_rec.attribute4 := p_attribute4;
    l_inv_ra_rec.attribute5 := p_attribute5;
    l_inv_ra_rec.attribute6 := p_attribute6;
    l_inv_ra_rec.attribute7 := p_attribute7;
    l_inv_ra_rec.attribute8 := p_attribute8;
    l_inv_ra_rec.attribute9 := p_attribute9;
    l_inv_ra_rec.attribute10 := p_attribute10;
    l_inv_ra_rec.attribute11 := p_attribute11;
    l_inv_ra_rec.attribute12 := p_attribute12;
    l_inv_ra_rec.attribute13 := p_attribute13;
    l_inv_ra_rec.attribute14 := p_attribute14;
    l_inv_ra_rec.attribute15 := p_attribute15;
    l_inv_ra_rec.global_attribute_category := p_global_attribute_category;
    l_inv_ra_rec.global_attribute1 := p_global_attribute1;
    l_inv_ra_rec.global_attribute2 := p_global_attribute2;
    l_inv_ra_rec.global_attribute3 := p_global_attribute3;
    l_inv_ra_rec.global_attribute4 := p_global_attribute4;
    l_inv_ra_rec.global_attribute5 := p_global_attribute5;
    l_inv_ra_rec.global_attribute6 := p_global_attribute6;
    l_inv_ra_rec.global_attribute7 := p_global_attribute7;
    l_inv_ra_rec.global_attribute8 := p_global_attribute8;
    l_inv_ra_rec.global_attribute9 := p_global_attribute9;
    l_inv_ra_rec.global_attribute10 := p_global_attribute10;
    l_inv_ra_rec.global_attribute11 := p_global_attribute11;
    l_inv_ra_rec.global_attribute12 := p_global_attribute12;
    l_inv_ra_rec.global_attribute13 := p_global_attribute13;
    l_inv_ra_rec.global_attribute14 := p_global_attribute14;
    l_inv_ra_rec.global_attribute15 := p_global_attribute15;
    l_inv_ra_rec.global_attribute16 := p_global_attribute16;
    l_inv_ra_rec.global_attribute17 := p_global_attribute17;
    l_inv_ra_rec.global_attribute18 := p_global_attribute18;
    l_inv_ra_rec.global_attribute19 := p_global_attribute19;
    l_inv_ra_rec.global_attribute20 := p_global_attribute20;
    l_inv_ra_rec.applied_customer_trx_line_id := p_customer_trx_line_id;
    l_inv_ra_rec.comments := p_comments; --Bug 2662270
    --------------------------------------------------------------------------
    -- Create the APP row in receivable applications.
    --
    --------------------------------------------------------------------------
    arp_app_pkg.insert_p( l_inv_ra_rec,
                          l_inv_ra_rec.receivable_application_id );

    IF l_inv_ra_rec.receivable_application_id IS NOT NULL THEN
      l_xla_ev_rec.xla_from_doc_id := l_inv_ra_rec.receivable_application_id;
      l_xla_ev_rec.xla_to_doc_id   := l_inv_ra_rec.receivable_application_id;
      l_xla_ev_rec.xla_mode        := 'O';
      l_xla_ev_rec.xla_call        := 'B';
      l_xla_ev_rec.xla_doc_table := 'CMAPP';
      ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
    END IF;
    -----------------------------------------------------------------------
    -- Process MRC data
    -----------------------------------------------------------------------

--    ar_mrc_engine3.cm_application(
--                     p_cm_ps_id      => p_cm_ps_id,
--                     p_invoice_ps_id => p_invoice_ps_id,
--                     p_inv_ra_rec    => l_inv_ra_rec,
--                     p_ra_id         => l_inv_ra_rec.receivable_application_id);

    --apandit
    --Bug : 2641517 raise business event.
    AR_BUS_EVENT_COVER.Raise_CM_Apply_Event(l_inv_ra_rec.receivable_application_id);

   --
   --Release 11.5 VAT changes, create APP record accounting
   --in ar_distributions
   --
    l_ae_doc_rec.document_type             := 'CREDIT_MEMO';
    l_ae_doc_rec.document_id               := l_inv_ra_rec.customer_trx_id;
    l_ae_doc_rec.accounting_entity_level   := 'ONE';
    l_ae_doc_rec.source_table              := 'RA';
    l_ae_doc_rec.source_id                 := l_inv_ra_rec.receivable_application_id;
    l_ae_doc_rec.source_id_old             := '';
    l_ae_doc_rec.other_flag                := '';
  --Bug 1329091 - PS is updated before Accounting Engine Call
    l_ae_doc_rec.pay_sched_upd_yn := 'Y';

    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

    /* Bug 4910860
       Check if the accounting entries balance */
    arp_balance_check.Check_Appln_Balance(l_inv_ra_rec.receivable_application_id, -- APP record
                                          NULL,
                                          'N' );  -- No API for CM application as of now

    -- Return the new receivable_application_id
    p_out_rec_application_id := l_inv_ra_rec.receivable_application_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'arp_process_application.cm_application()-' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug(
		    'EXCEPTION: arp_process_application.cm_application' );
              END IF;
              RAISE;
END cm_application;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_cm_appln_args                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to cm_application                            |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_cm_ps_id      - Receipt PS Id.                          |
 |                 p_invoice_ps_id - Invoice PS Id.                          |
 |                 p_amount_applied - Input amount applied                   |
 |                 p_gl_date         - Gl Date                               |
 |                 p_apply_date - Application date                           |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE  validate_cm_appln_args(
	p_cm_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
	p_invoice_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_amount_applied IN
                ar_receivable_applications.amount_applied%TYPE,
        p_apply_date IN ar_receivable_applications.apply_date%TYPE,
	p_gl_date IN ar_receivable_applications.gl_date%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(
	      'arp_process_application.validate_cm_appln_args()+' );
    END IF;
    --
    IF ( p_cm_ps_id IS NULL OR p_invoice_ps_id IS NULL OR
	 p_apply_date IS NULL OR p_gl_date IS NULL OR
         p_amount_applied IS NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(
	      'arp_process_application.validate_cm_appln_args()-' );
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_debug.debug(
                'EXCEPTION: arp_process_application.validate_cm_appln_args' );
           END IF;
              RAISE;
END validate_cm_appln_args;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    on_account_receipts                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Do all actions neccessary to insert rows into AR_RA table during       |
 |    ON-ACCOUNT receipt insertion. No PS table row is updated, However      |
 |    2 RA rows are inserted - One as an UNAPP row and another as 'ACC' row  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED -                                 |
 |         ARPCURR.functional_amount - Get the acctd amount of amount applied|
 |         arp_ps_pkg.fetch_p - Fetch a PS row                               |
 |         arp_app_pkg.insert_p - Insert a row into RA table                 |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_ps_id - PS id of the receipt                            |
 |                 p_amount_applied - Input amount applied                   |
 |                 p_apply_date - Application date                           |
 |                 p_gl_date    - Gl Date                                    |
 |                 p_ussgl_transaction_code - USSGL transaction code         |
 |                 OTHER DESCRIPTIVE FLEX columns                            |
 |                 p_module_name  - Name of the module that called this      |
 |                                  procedure                                |
 |                 p_module_version  - Version of the module that called this|
 |                                  procedure                                |
 |              OUT:                                                         |
 |		   p_out_rec_application_id                                  |
 |				Returned receivable application id           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES  -                                                                  |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 | 08/29/1995	Ganesh Vaidee	Created                                      |
 | 05/03/1996	Harri Kaukovuo	Added OUT NOCOPY parameter p_out_rec_application_id |
 | 05/06/1996	Harri Kaukovuo	Added logics to update batch status          |
 | 10/31/1996   Karen Lawrance  Bug fix #414626.  Added code to update       |
 |                              the receipt status if the on account         |
 |                              application fully applies the receipt.       |
 | 08/21/1997	Tasman Tang	Added global_attribute_category,	     |
 |				global_attribute[1-20] for global  	     |
 |				descriptive flexfield			     |
 | 03/05/1998   Guat Eng Tan    Bug fix #627262.  In the call to             |
 |                              ARPCURR.functional_amount, replace l_ps_rec. |
 |                              invoice_currency_code with functional_curr.  |
 | 07/16/1998   Karen Murphy    Bug fix 634464.  Modified the code that works|
 |                              out NOCOPY the status for the Receipt (APP or UNAPP)|
 |                              Now includes the total On Account amount as  |
 |                              this is not included in the Pay Sched, Amt   |
 |                              Due Rem total.                               |
 | 04-JAN-02    VERAO           Bug 2047229 : added p_comments               |
 | 16-JAN-02    V Crisostomo	Bug 2184812 : changes done in 2047229 added  |
 |				parameter p_comments, but did not provide    |
 |				default value, hence all code calling this   |
 |				procedure and not passing comment is failing |
 |				modify code to DEFAULT NULL	   	     |
 | 04-Sep-02    Debbie Jancis   Added calls to mrc engine 3 for processing   |
 |                              inserts to ar_receivable_applications        |
 | 28-JUL-2003  Jon Beckett     Bug 2821139 - added p_customer_reason.       |
 +===========================================================================*/
PROCEDURE on_account_receipts(
        p_receipt_ps_id   IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_amount_applied IN
                ar_receivable_applications.amount_applied%TYPE,
        p_apply_date IN ar_receivable_applications.apply_date%TYPE,
        p_gl_date IN ar_receivable_applications.gl_date%TYPE,
        p_ussgl_transaction_code IN
                ar_receivable_applications.ussgl_transaction_code%TYPE,
        p_attribute_category IN
                ar_receivable_applications.attribute_category%TYPE,
        p_attribute1 IN ar_receivable_applications.attribute1%TYPE,
        p_attribute2 IN ar_receivable_applications.attribute2%TYPE,
        p_attribute3 IN ar_receivable_applications.attribute3%TYPE,
        p_attribute4 IN ar_receivable_applications.attribute4%TYPE,
        p_attribute5 IN ar_receivable_applications.attribute5%TYPE,
        p_attribute6 IN ar_receivable_applications.attribute6%TYPE,
        p_attribute7 IN ar_receivable_applications.attribute7%TYPE,
        p_attribute8 IN ar_receivable_applications.attribute8%TYPE,
        p_attribute9 IN ar_receivable_applications.attribute9%TYPE,
        p_attribute10 IN ar_receivable_applications.attribute10%TYPE,
        p_attribute11 IN ar_receivable_applications.attribute11%TYPE,
        p_attribute12 IN ar_receivable_applications.attribute12%TYPE,
        p_attribute13 IN ar_receivable_applications.attribute13%TYPE,
        p_attribute14 IN ar_receivable_applications.attribute14%TYPE,
        p_attribute15 IN ar_receivable_applications.attribute15%TYPE,
        p_global_attribute_category IN ar_receivable_applications.global_attribute_category%TYPE,
        p_global_attribute1 IN ar_receivable_applications.global_attribute1%TYPE,
        p_global_attribute2 IN ar_receivable_applications.global_attribute2%TYPE,
        p_global_attribute3 IN ar_receivable_applications.global_attribute3%TYPE,
        p_global_attribute4 IN ar_receivable_applications.global_attribute4%TYPE,
        p_global_attribute5 IN ar_receivable_applications.global_attribute5%TYPE,
        p_global_attribute6 IN ar_receivable_applications.global_attribute6%TYPE,
        p_global_attribute7 IN ar_receivable_applications.global_attribute7%TYPE,
        p_global_attribute8 IN ar_receivable_applications.global_attribute8%TYPE,
        p_global_attribute9 IN ar_receivable_applications.global_attribute9%TYPE,
        p_global_attribute10 IN ar_receivable_applications.global_attribute10%TYPE,
        p_global_attribute11 IN ar_receivable_applications.global_attribute11%TYPE,
        p_global_attribute12 IN ar_receivable_applications.global_attribute12%TYPE,
        p_global_attribute13 IN ar_receivable_applications.global_attribute13%TYPE,
        p_global_attribute14 IN ar_receivable_applications.global_attribute14%TYPE,
        p_global_attribute15 IN ar_receivable_applications.global_attribute15%TYPE,
        p_global_attribute16 IN ar_receivable_applications.global_attribute16%TYPE,
        p_global_attribute17 IN ar_receivable_applications.global_attribute17%TYPE,
        p_global_attribute18 IN ar_receivable_applications.global_attribute18%TYPE,
        p_global_attribute19 IN ar_receivable_applications.global_attribute19%TYPE,
        p_global_attribute20 IN ar_receivable_applications.global_attribute20%TYPE,
        p_comments IN ar_receivable_applications.comments%TYPE,
        p_module_name IN VARCHAR2,
        p_module_version IN VARCHAR2,
	p_out_rec_application_id	OUT NOCOPY NUMBER
      , p_application_ref_num IN ar_receivable_applications.application_ref_num%TYPE
      , p_secondary_application_ref_id IN ar_receivable_applications.secondary_application_ref_id%TYPE
      , p_customer_reference IN ar_receivable_applications.customer_reference%TYPE
      , p_customer_reason IN ar_receivable_applications.customer_reason%TYPE
      , p_secondary_app_ref_type IN
        ar_receivable_applications.secondary_application_ref_type%TYPE := null
      , p_secondary_app_ref_num IN
        ar_receivable_applications.secondary_application_ref_num%TYPE := null
) IS

l_ra_rec   ar_receivable_applications%ROWTYPE;
l_ps_rec   ar_payment_schedules%ROWTYPE;

l_cr_rec                 ar_cash_receipts%ROWTYPE;
l_amount_due_remaining   NUMBER;
ln_batch_id	         NUMBER;
functional_curr          VARCHAR2(100);

l_onacc_cc_id  ar_receipt_method_accounts.on_account_ccid%TYPE;
l_unapp_cc_id  ar_receipt_method_accounts.unapplied_ccid%TYPE;

l_on_account_total      NUMBER;
l_ae_doc_rec            ae_doc_rec_type;
l_prev_unapp_id         NUMBER;
l_called_from_api       VARCHAR2(1);
  --Bug#2750340
  l_xla_ev_rec      arp_xla_events.xla_events_type;
  l_xla_doc_table   VARCHAR2(20);

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'arp_process_application.on_account_receipts()+' );
       arp_debug.debug(   '-- p_receipt_ps_id = '||TO_CHAR(p_receipt_ps_id));
       arp_debug.debug(   '-- p_amount_applied = '||
                        TO_CHAR( p_amount_applied ) );
       arp_debug.debug(   '-- p_gl_date = '|| TO_CHAR( p_gl_date ) );
       arp_debug.debug(   '-- p_apply_date = '|| TO_CHAR( p_apply_date ) );
    END IF;
    --
    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
         validate_on_account_args( p_receipt_ps_id, p_amount_applied,
                                   p_apply_date, p_gl_date );
    END IF;
    --
    arp_ps_pkg.fetch_p( p_receipt_ps_id, l_ps_rec );

    functional_curr := arp_global.functional_currency;

    -- ---------------------------------------------------------------------
    -- Get UNAPP and ON-ACC CC'Ids by selecting from receipt method accounts
    -- table
    -- 05/06/1996 H.Kaukovuo	Added batch_id
    -- 10/31/1996 K.Lawrance    Added amount_due_remaining
    -- ---------------------------------------------------------------------

    SELECT ps.cash_receipt_id,
           ps.amount_due_remaining,
           rma.on_account_ccid,
           rma.unapplied_ccid,
	   crh.batch_id
    INTO   l_ra_rec.cash_receipt_id,
           l_amount_due_remaining,
           l_onacc_cc_id,
           l_unapp_cc_id
	   , ln_batch_id
    FROM     ar_payment_schedules 	ps
           , ar_cash_receipts 		cr
	   , ar_cash_receipt_history	crh
           , ar_receipt_methods 	rm
           , ce_bank_acct_uses		ba
           , ar_receipt_method_accounts rma
    WHERE  ps.payment_schedule_id 	= p_receipt_ps_id
    AND    cr.cash_receipt_id 		= ps.cash_receipt_id
    AND	   crh.cash_receipt_id		= cr.cash_receipt_id
    AND	   crh.current_record_flag	= 'Y'
    AND    rm.receipt_method_id 	= cr.receipt_method_id
    AND    ba.bank_acct_use_id 	        = cr.remit_bank_acct_use_id
    AND    rma.remit_bank_acct_use_id 	= ba.bank_acct_use_id
    AND    rma.receipt_method_id 	= rm.receipt_method_id;

    -- Get the current amount that is On Account for this receipt.
    -- This is used later on to determine it the receipt has been
    -- fully applied.  We need to do the sum now so we don't include
    -- the On Account row that we are about to create.
    --
    select nvl(sum(ra.amount_applied),0)
    into   l_on_account_total
    from   ar_receivable_applications ra
    where  ra.cash_receipt_id = l_ra_rec.cash_receipt_id
    and    ra.status IN ('ACC','OTHER ACC');

    -- Prepare for 'UNAPP' record insertion with -ve amount applied
    -- applied_customer_trx_id is NULL and display = 'N'
    --
    l_ra_rec.payment_schedule_id := p_receipt_ps_id;
    l_ra_rec.amount_applied := -p_amount_applied;
    --
    -- Get the acctd_amount_applied_from value
    --
    l_ra_rec.acctd_amount_applied_from :=
                 ARPCURR.functional_amount( l_ra_rec.amount_applied,
                                            functional_curr,
                                            l_ps_rec.exchange_rate,
                                            NULL, NULL );
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'acctd_amount_applied_from = '||
                         TO_CHAR( l_ra_rec.acctd_amount_applied_from ) );
    END IF;
    --
    l_ra_rec.status := 'UNAPP';
    l_ra_rec.application_type := 'CASH';

    -- l_ra_rec.application_rule := 'ON ACCOUNT APPLICATION';
    l_ra_rec.application_rule := '60.7';
    l_ra_rec.program_id	:= -100106;

    l_ra_rec.code_combination_id := l_unapp_cc_id;
    l_ra_rec.apply_date := p_apply_date;
    l_ra_rec.gl_date := p_gl_date;
    l_ra_rec.posting_control_id := -3;
    l_ra_rec.display := 'N';
    l_ra_rec.ussgl_transaction_code := p_ussgl_transaction_code;
    l_ra_rec.attribute_category := p_attribute_category;
    l_ra_rec.attribute1 := p_attribute1;
    l_ra_rec.attribute2 := p_attribute2;
    l_ra_rec.attribute3 := p_attribute3;
    l_ra_rec.attribute4 := p_attribute4;
    l_ra_rec.attribute5 := p_attribute5;
    l_ra_rec.attribute6 := p_attribute6;
    l_ra_rec.attribute7 := p_attribute7;
    l_ra_rec.attribute8 := p_attribute8;
    l_ra_rec.attribute9 := p_attribute9;
    l_ra_rec.attribute10 := p_attribute10;
    l_ra_rec.attribute11 := p_attribute11;
    l_ra_rec.attribute12 := p_attribute12;
    l_ra_rec.attribute13 := p_attribute13;
    l_ra_rec.attribute14 := p_attribute14;
    l_ra_rec.attribute15 := p_attribute15;
    l_ra_rec.global_attribute_category := p_global_attribute_category;
    l_ra_rec.global_attribute1 := p_global_attribute1;
    l_ra_rec.global_attribute2 := p_global_attribute2;
    l_ra_rec.global_attribute3 := p_global_attribute3;
    l_ra_rec.global_attribute4 := p_global_attribute4;
    l_ra_rec.global_attribute5 := p_global_attribute5;
    l_ra_rec.global_attribute6 := p_global_attribute6;
    l_ra_rec.global_attribute7 := p_global_attribute7;
    l_ra_rec.global_attribute8 := p_global_attribute8;
    l_ra_rec.global_attribute9 := p_global_attribute9;
    l_ra_rec.global_attribute10 := p_global_attribute10;
    l_ra_rec.global_attribute11 := p_global_attribute11;
    l_ra_rec.global_attribute12 := p_global_attribute12;
    l_ra_rec.global_attribute13 := p_global_attribute13;
    l_ra_rec.global_attribute14 := p_global_attribute14;
    l_ra_rec.global_attribute15 := p_global_attribute15;
    l_ra_rec.global_attribute16 := p_global_attribute16;
    l_ra_rec.global_attribute17 := p_global_attribute17;
    l_ra_rec.global_attribute18 := p_global_attribute18;
    l_ra_rec.global_attribute19 := p_global_attribute19;
    l_ra_rec.global_attribute20 := p_global_attribute20;
    l_ra_rec.comments := p_comments; --Bug 2047229

    --
    -- Insert UNAPP record
    --
    arp_app_pkg.insert_p( l_ra_rec, l_ra_rec.receivable_application_id );

    IF l_ra_rec.receivable_application_id IS NOT NULL THEN
         l_xla_ev_rec.xla_from_doc_id := l_ra_rec.receivable_application_id;
         l_xla_ev_rec.xla_to_doc_id   := l_ra_rec.receivable_application_id;
         l_xla_ev_rec.xla_mode        := 'O';
         l_xla_ev_rec.xla_call        := 'B';
         l_xla_ev_rec.xla_doc_table := 'APP';
         ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
    END IF;


    --Set UNAPP id for PAIRING
    l_prev_unapp_id := l_ra_rec.receivable_application_id;

    -- ---------------------------------------------------------------------
    -- Prepare for 'ACC' record insertion with +ve amount applied
    -- applied_payment_schedule_id and applied_customer_trx_id are -1 and
    -- display = 'Y', Only the following details change for the 'ACC' record
    -- from the UNAPP record during ON-ACCOUNT receipt insertion.
    -- ---------------------------------------------------------------------

    l_ra_rec.receivable_application_id := NULL; /* filled during act. insert */
    l_ra_rec.applied_customer_trx_id := -1;
    l_ra_rec.applied_payment_schedule_id := -1;
    l_ra_rec.code_combination_id := l_onacc_cc_id;
    l_ra_rec.amount_applied := p_amount_applied;
    l_ra_rec.application_rule := '60.0';
    l_ra_rec.program_id := -100107;

    --
    -- acctd_amount_applied_from is -ve of already calculated
    -- acctd_amount_applied_from for 'UNAPP' record
    --
    l_ra_rec.acctd_amount_applied_from := -l_ra_rec.acctd_amount_applied_from;
    --
    l_ra_rec.status := 'ACC';
    l_ra_rec.display := 'Y';

    l_ra_rec.application_ref_num := p_application_ref_num;
    l_ra_rec.secondary_application_ref_id := p_secondary_application_ref_id;
    l_ra_rec.secondary_application_ref_type := p_secondary_app_ref_type;
    l_ra_rec.secondary_application_ref_num := p_secondary_app_ref_num;
    l_ra_rec.customer_reference := p_customer_reference;
    l_ra_rec.customer_reason := p_customer_reason;  -- 4145224

    -- Insert ACC record

    arp_app_pkg.insert_p( l_ra_rec, l_ra_rec.receivable_application_id );

    IF l_ra_rec.receivable_application_id IS NOT NULL THEN
         l_xla_ev_rec.xla_from_doc_id := l_ra_rec.receivable_application_id;
         l_xla_ev_rec.xla_to_doc_id   := l_ra_rec.receivable_application_id;
         l_xla_ev_rec.xla_mode        := 'O';
         l_xla_ev_rec.xla_call        := 'B';
         l_xla_ev_rec.xla_doc_table := 'APP';
         ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
    END IF;

   --
   --Release 11.5 VAT changes, create paired UNAPP record accounting
   --in ar_distributions
   --
    l_ae_doc_rec.document_type             := 'RECEIPT';
    l_ae_doc_rec.document_id               := l_ra_rec.cash_receipt_id;
    l_ae_doc_rec.accounting_entity_level   := 'ONE';
    l_ae_doc_rec.source_table              := 'RA';
    l_ae_doc_rec.source_id                 := l_prev_unapp_id;
    l_ae_doc_rec.source_id_old             := l_ra_rec.receivable_application_id;
    l_ae_doc_rec.other_flag                := 'PAIR';
    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

   --
   --Release 11.5 VAT changes, create ACC record accounting
   --in ar_distributions
   --
    l_ae_doc_rec.source_id                 := l_ra_rec.receivable_application_id;
    l_ae_doc_rec.source_id_old             := '';
    l_ae_doc_rec.other_flag                := '';
    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

   /* Bug 4910860
       Check if the accounting entries balance */
      IF nvl(p_module_name,'RAPI') = 'RAPI' THEN
         l_called_from_api := 'Y';
      ELSE
        l_called_from_api := 'N';
      END IF;
    arp_balance_check.Check_Appln_Balance(l_ra_rec.receivable_application_id, -- ACC rec_app_id
                                            l_prev_unapp_id,  -- UNAPP rec_app_id
                                            NULL,
                                            l_called_from_api);


    -- ----------------------------------------------------------------------
    -- 10/31/1996 K.Lawrance
    -- Finally update cash receipt status.
    -- ----------------------------------------------------------------------

    -- First, set ar_cash_receipt record values to dummy ...
    -- This is to distinguish between updateable NULL and NULL value (dummy)
    -- which means that column is not to be updated.

    arp_cash_receipts_pkg.set_to_dummy(l_cr_rec);

    -- ---------------------------------------------------------------------
    -- Cash receipt must be fully applied in order to set the status
    -- to 'Applied'.
    -- ---------------------------------------------------------------------
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug (  '-- Defining receipt status ...');
       arp_debug.debug (  '-- p_amount_applied = '||to_char(p_amount_applied));
       arp_debug.debug (  '-- l_amount_due_remaining = '||
		                            to_char(l_amount_due_remaining));
    END IF;

    -- Determine if the receipt has been fully applied.
    -- We include the total amount that is On Account as this is
    -- not included in the Payment Schedules, Amount Due Remaining
    -- total for the receipt.
    --
    IF (l_amount_due_remaining + l_on_account_total + p_amount_applied < 0)
    THEN
      l_cr_rec.status           := 'UNAPP';
    ELSE
      l_cr_rec.status           := 'APP';
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug (  '-- status = '|| l_cr_rec.status);
    END IF;

    l_cr_rec.cash_receipt_id  := l_ra_rec.cash_receipt_id;

    -- Update cash receipt status.
    arp_cash_receipts_pkg.update_p(
	  l_cr_rec
	, l_ra_rec.cash_receipt_id);

    -- ---------------------------------------------------------------------
    -- Update batch status if receipt has a batch
    -- ---------------------------------------------------------------------
    IF (ln_batch_id IS NOT NULL)
    THEN
      arp_rw_batches_check_pkg.update_batch_status(ln_batch_id);
    END IF;

    -- ---------------------------------------------------------------------
    -- Return the new receivable application id back to the form
    -- ---------------------------------------------------------------------
    p_out_rec_application_id := l_ra_rec.receivable_application_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(
              'arp_process_application.on_account_receipts()-' );
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_debug.debug(
                'EXCEPTION: arp_process_application.on_account_receipts' );
           END IF;
              RAISE;

END on_account_receipts;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_on_account_args                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate arguments passed to on_account_receipts procedure             |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_ps_id - Payment Schedule Id of the receipt              |
 |                 p_amount_applied - Input amount applied                   |
 |                 p_gl_date         - Gl Date                               |
 |                 p_apply_date - Application date                           |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE  validate_on_account_args(
        p_ps_id   IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_amount_applied IN
                ar_receivable_applications.amount_applied%TYPE,
        p_apply_date IN ar_receivable_applications.apply_date%TYPE,
        p_gl_date IN ar_receivable_applications.gl_date%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(
              'arp_process_application.validate_on_account_args()+' );
    END IF;
    --
    IF ( p_ps_id IS NULL OR p_apply_date IS NULL OR
         p_gl_date IS NULL OR p_amount_applied IS NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(
              'arp_process_application.validate_on_account_args()-' );
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_debug.debug(
                'EXCEPTION: arp_process_application.validate_on_account_args' );
           END IF;
              RAISE;
END validate_on_account_args;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    activity_application                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Create Activity applications. These applications are done against      |
 |    an seeded payment schedule (ie Short Term Debt activity application    |
 |    against ps of -2). The CCID for the application is retrieved from      |
 |    receivable activity. In STD case the receipt payment schedule is       |
 |    impacted by the application.                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED -                                 |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |               p_receipt_ps_id          - PS id of the receipt             |
 |               p_application_ps_id      - PS id of the application         |
 |               p_link_to_customer_trx_id- Link to customer_trx_id related  |
 |                                          to Short term debt applicatio    |
 |               p_amount_applied         - Input amount applied             |
 |               p_apply_date             - Application date                 |
 |               p_gl_date                - Gl Date                          |
 |               p_receivables_trx_id     - Receivable Activity ID           |
 |               p_ussgl_transaction_code - USSGL transaction code           |
 |               OTHER DESCRIPTIVE FLEX columns                              |
 |               p_module_name            - Name of the module that called   |
 |                                          this procedure                   |
 |               p_module_version         - Version of the module that       |
 |                                          called this procedure            |
 |              OUT:                                                         |
 |               p_out_rec_application_id Returned receivable application id |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 | 14-APR-2000 Jani Rautiain Created                                         |
 | 08-Feb-01   S. Nambiar    Bug 1634986 - Modified activity_application     |
 |                           to update receipt status properly               |
 | 25-FEB-2001 Manoj Gudivak Modified to handle Claim Application            |
 | 19-APR-2001 Jon Beckett   Claim Application now handled by new procedure  |
 |                           other_account_application                       |
 | 08-May-2001 S Nambiar     Now p_application_ref_id contains the chargeback|
 |                           customer_trx_id.And claim_id is stored in       |
 |                           chargeback_customer_trx_id field.               |
 |                           This is a temporary arrangement.                |
 |  14-May-01  S.Nambiar     Modified activity_application() routine to replace
 |                           the balance segment of activity application to that
 |                           of receipt UNAPP
 | 06/20/2001  S.Nambiar     Bug 1823299 - Activity application should not
 |                           leave rounding difference amount as unapplied
 |                           for forign currency receipts.
 | 08-NOV-01   S.Nambiar     Bug 2103345. calculate acctd_amount_applied_to
 |                           for cc refund activity application.
 | 09-Sep-02   Debbie Jancis Modified for mrc trigger replacement.  Added
 |                           calls to ar_mrc_engine3 for processing receivable
 |			     applications.
 | 06-FEB-03   Jon Beckett   Bug 2751910 - Added p_applied_rec_app_id for
 |                           netting.
 | 29-MAY-03   Jon Beckett   Bug 2821138 - Added p_netted_receipt_flag and
 |                           calculation of acctd_amount_applied_to for
 |                 	     main receipt in a netting pair.
 | 02-Feb-05   Debbie Jancis Enhancement 4145224: added customer_Reason
 | 04-Mar-05   Jyoti Pandey  Bug: 4166986 CC Chargeback logic
 +===========================================================================*/
PROCEDURE activity_application(
        p_receipt_ps_id             IN
                   ar_payment_schedules.payment_schedule_id%TYPE,
        p_application_ps_id         IN
                   ar_receivable_applications.applied_payment_schedule_id%TYPE,
        p_link_to_customer_trx_id   IN
                   ar_receivable_applications.link_to_customer_trx_id%TYPE,
        p_amount_applied            IN
                   ar_receivable_applications.amount_applied%TYPE,
        p_apply_date                IN
                   ar_receivable_applications.apply_date%TYPE,
        p_gl_date                   IN
                   ar_receivable_applications.gl_date%TYPE,
        p_receivables_trx_id        IN
                   ar_receivable_applications.receivables_trx_id%TYPE,
        p_ussgl_transaction_code    IN
                   ar_receivable_applications.ussgl_transaction_code%TYPE,
        p_attribute_category        IN
                   ar_receivable_applications.attribute_category%TYPE,
        p_attribute1                IN
                   ar_receivable_applications.attribute1%TYPE,
        p_attribute2                IN
                   ar_receivable_applications.attribute2%TYPE,
        p_attribute3                IN
                   ar_receivable_applications.attribute3%TYPE,
        p_attribute4                IN
                   ar_receivable_applications.attribute4%TYPE,
        p_attribute5                IN
                   ar_receivable_applications.attribute5%TYPE,
        p_attribute6                IN
                   ar_receivable_applications.attribute6%TYPE,
        p_attribute7                IN
                   ar_receivable_applications.attribute7%TYPE,
        p_attribute8                IN
                   ar_receivable_applications.attribute8%TYPE,
        p_attribute9                IN
                   ar_receivable_applications.attribute9%TYPE,
        p_attribute10               IN
                   ar_receivable_applications.attribute10%TYPE,
        p_attribute11               IN
                   ar_receivable_applications.attribute11%TYPE,
        p_attribute12               IN
                   ar_receivable_applications.attribute12%TYPE,
        p_attribute13               IN
                   ar_receivable_applications.attribute13%TYPE,
        p_attribute14               IN
                   ar_receivable_applications.attribute14%TYPE,
        p_attribute15               IN
                   ar_receivable_applications.attribute15%TYPE,
        p_global_attribute_category IN
                   ar_receivable_applications.global_attribute_category%TYPE,
        p_global_attribute1         IN
                   ar_receivable_applications.global_attribute1%TYPE,
        p_global_attribute2         IN
                   ar_receivable_applications.global_attribute2%TYPE,
        p_global_attribute3         IN
                   ar_receivable_applications.global_attribute3%TYPE,
        p_global_attribute4         IN
                   ar_receivable_applications.global_attribute4%TYPE,
        p_global_attribute5         IN
                   ar_receivable_applications.global_attribute5%TYPE,
        p_global_attribute6         IN
                   ar_receivable_applications.global_attribute6%TYPE,
        p_global_attribute7         IN
                   ar_receivable_applications.global_attribute7%TYPE,
        p_global_attribute8         IN
                   ar_receivable_applications.global_attribute8%TYPE,
        p_global_attribute9         IN
                   ar_receivable_applications.global_attribute9%TYPE,
        p_global_attribute10        IN
                   ar_receivable_applications.global_attribute10%TYPE,
        p_global_attribute11        IN
                   ar_receivable_applications.global_attribute11%TYPE,
        p_global_attribute12        IN
                   ar_receivable_applications.global_attribute12%TYPE,
        p_global_attribute13        IN
                   ar_receivable_applications.global_attribute13%TYPE,
        p_global_attribute14        IN
                   ar_receivable_applications.global_attribute14%TYPE,
        p_global_attribute15        IN
                   ar_receivable_applications.global_attribute15%TYPE,
        p_global_attribute16        IN
                   ar_receivable_applications.global_attribute16%TYPE,
        p_global_attribute17        IN
                   ar_receivable_applications.global_attribute17%TYPE,
        p_global_attribute18        IN
                   ar_receivable_applications.global_attribute18%TYPE,
        p_global_attribute19        IN
                   ar_receivable_applications.global_attribute19%TYPE,
        p_global_attribute20        IN
                   ar_receivable_applications.global_attribute20%TYPE,
        p_comments IN
                   ar_receivable_applications.comments%TYPE,
        p_module_name               IN VARCHAR2,
        p_module_version            IN VARCHAR2,
        p_application_ref_type IN OUT NOCOPY
                   ar_receivable_applications.application_ref_type%TYPE,
        p_application_ref_id IN OUT NOCOPY
                   ar_receivable_applications.application_ref_id%TYPE,
        p_application_ref_num IN OUT NOCOPY
                   ar_receivable_applications.application_ref_num%TYPE,
        p_secondary_application_ref_id IN OUT NOCOPY NUMBER,
        p_payment_set_id IN NUMBER,
	p_called_from 		    IN VARCHAR2,  /*5444407*/
        p_out_rec_application_id    OUT NOCOPY NUMBER,
        p_applied_rec_app_id IN NUMBER,
        p_customer_reference IN ar_receivable_applications.customer_reference%TYPE,
	p_netted_receipt_flag IN VARCHAR2,
	p_netted_cash_receipt_id IN ar_cash_receipts.cash_receipt_id%TYPE ,
    p_secondary_app_ref_type IN
       ar_receivable_applications.secondary_application_ref_type%TYPE := null,
    p_secondary_app_ref_num IN
       ar_receivable_applications.secondary_application_ref_num%TYPE := null,
    p_customer_reason IN
           ar_receivable_applications.customer_reason%TYPE DEFAULT NULL,
--Bug 5450371
    p_application_ref_reason IN ar_receivable_applications.application_ref_reason%TYPE Default NULL
	) IS

  /* Cursor to application information for activity application */
  CURSOR activity_c IS
    SELECT cr.currency_code,
           ps.cash_receipt_id,
           ps.amount_due_remaining,
           rma.unapplied_ccid,
	   crh.batch_id,
           rt.code_combination_id activity_ccid,
           rt.type activity_type
    FROM   ar_payment_schedules ps,
           ar_cash_receipts cr,
	   ar_cash_receipt_history crh,
           ar_receipt_methods rm,
           ce_bank_acct_uses ba,
           ar_receipt_method_accounts rma,
           ar_receivables_trx rt
    WHERE  ps.payment_schedule_id 	= p_receipt_ps_id
    AND    cr.cash_receipt_id 		= ps.cash_receipt_id
    AND	   crh.cash_receipt_id		= cr.cash_receipt_id
    AND	   crh.current_record_flag	= 'Y'
    AND    rm.receipt_method_id 	= cr.receipt_method_id
    AND    ba.bank_acct_use_id 		= cr.remit_bank_acct_use_id
    AND    rma.remit_bank_acct_use_id 	= ba.bank_acct_use_id
    AND    rma.receipt_method_id 	= rm.receipt_method_id
    AND    rt.receivables_trx_id        = p_receivables_trx_id;

  activity_rec activity_c%ROWTYPE;

  l_ra_rec   ar_receivable_applications%ROWTYPE;
  l_ps_rec   ar_payment_schedules%ROWTYPE;
  l_cr_rec   ar_cash_receipts%ROWTYPE;
  l_crcpt_rec   ar_cash_receipts%ROWTYPE;

  l_unapp_ra_rec ar_receivable_applications%ROWTYPE;   /* MRC */

  functional_curr             VARCHAR2(100);
  l_on_account_total          NUMBER;
  l_ae_doc_rec                ae_doc_rec_type;
  l_prev_unapp_id             NUMBER;
  l_acctd_amount_applied_from ar_receivable_applications.acctd_amount_applied_from%TYPE;
  l_acctd_amount_applied_to   ar_receivable_applications.acctd_amount_applied_to%TYPE;
  l_invoice_currency_code     ra_customer_trx.invoice_currency_code%TYPE;
  l_receipt_currency_code     ar_cash_receipts.currency_code%TYPE;
  l_exchange_rate             ra_customer_trx.exchange_rate%TYPE;
  l_chart_of_accounts_id      gl_sets_of_books.chart_of_accounts_id%TYPE;
  l_func_amount_due_remaining ar_payment_schedules.amount_due_remaining%TYPE;

  l_fnd_api_constants_rec     ar_bills_main.fnd_api_constants_type     := ar_bills_main.get_fnd_api_constants_rec;
  l_fnd_msg_pub_constants_rec ar_bills_main.fnd_msg_pub_constants_type := ar_bills_main.get_fnd_msg_pub_constants_rec;
  l_attribute_rec             AR_RECEIPT_API_PUB.attribute_rec_type;
  l_global_attribute_rec      AR_RECEIPT_API_PUB.global_attribute_rec_type;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_msg_index                 NUMBER;

  l_application_ref_type  ar_receivable_applications.application_ref_type%TYPE;
  l_application_ref_num   ar_receivable_applications.application_ref_num%TYPE;
  l_application_ref_id    ar_receivable_applications.application_ref_id%TYPE;
  l_secondary_application_ref_id ar_receivable_applications.secondary_application_ref_id%TYPE;
  l_secondary_app_ref_type  ar_receivable_applications.secondary_application_ref_type%TYPE;
  l_secondary_app_ref_num   ar_receivable_applications.secondary_application_ref_num%TYPE;
  l_netted_receipt_flag   VARCHAR2(1);
  l_mc_application_ref_id ar_receivable_applications.application_ref_id%TYPE;
  API_exception              EXCEPTION;

 --Bug 5450371
   l_application_ref_reason  ar_receivable_applications.application_ref_reason%TYPE;

  --For CC_Chargeback logic
  l_called_from   VARCHAR2(100) := null;
  l_called_from_api VARCHAR2(1);


  --Bug#2750340
  l_xla_ev_rec      arp_xla_events.xla_events_type;
  l_xla_doc_table   VARCHAR2(20);

  -- Bug 7317841
  l_pymnt_trxn_ext_id_temp  ar_cash_receipts.payment_trxn_extension_id%TYPE;

BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug(   'arp_process_application.activity_application()+' );
    arp_debug.debug(   '-- p_receipt_ps_id = '||TO_CHAR(p_receipt_ps_id));
    arp_debug.debug(   '-- p_application_ps_id = '||TO_CHAR(p_application_ps_id));
    arp_debug.debug(   '-- p_link_to_customer_trx_id = '||
                     TO_CHAR(p_link_to_customer_trx_id));
    arp_debug.debug(   '-- p_amount_applied = '||TO_CHAR( p_amount_applied ) );
    arp_debug.debug(   '-- p_gl_date = '|| TO_CHAR( p_gl_date ) );
    arp_debug.debug(   '-- p_receivables_trx_id = '||
                     TO_CHAR( p_receivables_trx_id ) );
    arp_debug.debug(   '-- p_apply_date = '|| TO_CHAR( p_apply_date ) );
 END IF;

 /* Validate parameters */

 validate_activity_args( p_receipt_ps_id, p_application_ps_id,
                         p_link_to_customer_trx_id,p_amount_applied,
                         p_apply_date, p_gl_date,p_receivables_trx_id );

    /* Fetch Receipt payment schedule */
    arp_ps_pkg.fetch_p( p_receipt_ps_id, l_ps_rec );

   --Store the details in local variable.
     l_application_ref_type := p_application_ref_type;
     l_application_ref_num := p_application_ref_num;
     l_application_ref_id  := p_application_ref_id;
     l_secondary_application_ref_id := p_secondary_application_ref_id;
     l_secondary_app_ref_type := p_secondary_app_ref_type;
     l_secondary_app_ref_num := p_secondary_app_ref_num;
     l_netted_receipt_flag := NVL(p_netted_receipt_flag,'N');


    functional_curr := arp_global.functional_currency;

    IF NVL(p_application_ps_id,0)    = -5 THEN
       l_application_ref_type := 'CHARGEBACK';
    ---CC_Chargeback
    ELSIF ( NVL(p_application_ps_id,0) = -6 ) OR
          ( NVL(p_application_ps_id,0) = -9 )   THEN

        l_application_ref_type := 'MISC_RECEIPT';

    ELSIF NVL(p_application_ps_id,0) = -8  THEN
        l_application_ref_type := 'AP_REFUND_REQUEST';
 	l_application_ref_reason := p_application_ref_reason; --Bug 5450371

    ELSE
          l_application_ref_type := NULL;
    END IF;

    -- Bug 1996893 if applied_ps_id is -6 (Credit card), then
    -- create Misc receipt also.

    --Activity application routine is called from rate_adjustment program also
    --But when rate adjusting,should not recreate the Misc.Receipt
    --CC_chargeback
    IF  ( (nvl(p_application_ps_id,0) = -6) OR
          (nvl(p_application_ps_id,0) = -9)
    AND nvl(p_module_name,'NONE') <> 'RATE_ADJUSTMENT_MAIN')  THEN
      --Fetch cash receipt details
         l_crcpt_rec.cash_receipt_id        :=      l_ps_rec.cash_receipt_id;
         arp_cash_receipts_pkg.fetch_p (l_crcpt_rec);
       DECLARE

	   l_ex_rate l_crcpt_rec.exchange_rate%type := null;
       BEGIN
/* BICHATTE CCREF*/

            IF (nvl(p_application_ps_id,0) = -6) THEN
                l_called_from := 'CC_REFUND';
            ELSIF   (nvl(p_application_ps_id,0) = -9) THEN
                l_called_from := 'CC_CHARGEBACK';
            END IF;


	         IF NVL(l_crcpt_rec.exchange_rate_type, 'x') = 'User' THEN
			    l_ex_rate := l_crcpt_rec.exchange_rate;
			 END IF;
                arp_debug.debug ( 'cr_rec_id ' || l_ps_rec.cash_receipt_id );
                arp_debug.debug ( 'rec_num '|| l_crcpt_rec.receipt_number );
                arp_debug.debug ( 'payment_trxn_extension_id '|| l_crcpt_rec.payment_trxn_extension_id );

	/* Start Bug 7317841 */
	BEGIN
		SELECT payment_trxn_extension_id
		INTO   l_pymnt_trxn_ext_id_temp
		FROM   ar_cash_receipts
		WHERE  cash_receipt_id 	IN (
				SELECT MAX(application_ref_id)
				FROM   ar_receivable_applications
				WHERE  cash_receipt_id = l_ps_rec.cash_receipt_id
				AND    application_type = 'CASH'
				AND    application_ref_type = 'MISC_RECEIPT');

	    l_crcpt_rec.payment_trxn_extension_id := l_pymnt_trxn_ext_id_temp;
            arp_debug.debug ( 'Latest payment_trxn_extension_id '|| l_crcpt_rec.payment_trxn_extension_id );
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		arp_debug.debug ( 'Handled Exception for getting max pymnt_trxn_id - First Refund Case' );

	    WHEN OTHERS THEN
		     arp_debug.debug(  'API EXCEPTION: Getting Max Pymnt_trxn_ext_id ' || SQLERRM);
		     RAISE;
	END;
	/* End Bug 7317841 */

        --Call Misc receipt creation routine.
             AR_RECEIPT_API_PUB.create_misc(
                -- IN parameters
                   p_api_version=>1.0,
                   p_init_msg_list=>l_fnd_api_constants_rec.G_FALSE,
                   p_commit=>l_fnd_api_constants_rec.G_FALSE,
                   p_validation_level=>l_fnd_api_constants_rec.G_VALID_LEVEL_FULL,
                   p_attribute_record=>l_attribute_rec,
                   p_global_attribute_record=>l_global_attribute_rec,
                   p_receipt_date=>p_apply_date,
                   p_amount=>(p_amount_applied * -1),
                   p_currency_code=>l_crcpt_rec.currency_code,
                   p_exchange_rate_type=>l_crcpt_rec.exchange_rate_type,
                   p_exchange_rate=>l_ex_rate,
                   p_exchange_rate_date=>l_crcpt_rec.exchange_date,
                   p_receipt_method_id=>l_crcpt_rec.receipt_method_id,
                   p_remittance_bank_account_id=>l_crcpt_rec.remit_bank_acct_use_id,
                   p_receivables_trx_id=>p_receivables_trx_id,
                   p_reference_type=>'RECEIPT',
                   p_reference_num=>l_crcpt_rec.receipt_number,
                   p_reference_id=>l_ps_rec.cash_receipt_id,
                   p_comments=>p_comments,
           -- OUT NOCOPY or IN/OUT parameters
                   x_return_status=>l_return_status,
                   x_msg_count=>l_msg_count,
                   x_msg_data=>l_msg_data,
                   p_receipt_number=>l_application_ref_num,
                   p_misc_receipt_id=>l_application_ref_id,
                   p_called_from => l_called_from, /* Bug fix 3619780 */
                   p_payment_trxn_extension_id => l_crcpt_rec.payment_trxn_extension_id
                   );

         /*------------------------------------------------+
          | Write API output to the concurrent program log |
          +------------------------------------------------*/
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_debug.debug(  'API error count '||to_char(NVL(l_msg_count,0)));
          END IF;

          IF NVL(l_msg_count,0)  > 0 Then

             IF l_msg_count  = 1 Then

                /*------------------------------------------------+
                 | There is one message returned by the API, so it|
                 | has been sent out NOCOPY in the parameter x_msg_data  |
                 +------------------------------------------------*/
                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_debug.debug(  l_msg_data);
                 END IF;

              ELSIF l_msg_count > 1 Then

                     /*-------------------------------------------------------+
                      | There are more than one messages returned by the API, |
                      | so call them in a loop and print the messages         |
                      +-------------------------------------------------------*/

                      FOR l_count IN 1..l_msg_count LOOP

                        l_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,
                                                                      FND_API.G_FALSE);
                        IF PG_DEBUG in ('Y', 'C') THEN
                           arp_debug.debug(  to_char(l_count)||' : '||l_msg_data);
                        END IF;

                      END LOOP;

               END IF; -- l_msg_count

           END IF; -- NVL(l_msg_count,0)

          /*-----------------------------------------------------+
           | If API return status is not SUCCESS raise exception |
           +-----------------------------------------------------*/
           IF l_return_status = FND_API.G_RET_STS_SUCCESS Then

             /*-----------------------------------------------------+
              | Success do nothing, else branch introduced to make  |
              | sure that NULL case will also raise exception       |
              +-----------------------------------------------------*/
              NULL;

           ELSE
              /*---------------------------+
               | Error, raise an exception |
               +---------------------------*/
               RAISE API_exception;

           END IF; -- l_return_status

          /*----------------------------------+
           | APIs propagate exception upwards |
           +----------------------------------*/
        EXCEPTION
              WHEN API_exception THEN
                   IF PG_DEBUG in ('Y', 'C') THEN
                      arp_debug.debug(  'API EXCEPTION: ' ||
                             'arp_process_application.activity_application(misc_receipt creation))'
                                         ||SQLERRM);
                   END IF;
                   FND_MSG_PUB.Get (FND_MSG_PUB.G_FIRST, FND_API.G_TRUE,
                                           l_msg_data, l_msg_index);
                   FND_MESSAGE.Set_Encoded (l_msg_data);
                   app_exception.raise_exception;

              WHEN OTHERS THEN
                   IF PG_DEBUG in ('Y', 'C') THEN
                      arp_debug.debug(  'API EXCEPTION: ' ||
                             'arp_process_application.activity_application(misc_receipt creation))'
                                         ||SQLERRM);
                   END IF;
                  RAISE;
         END; -- Misc receipt creation block
    END IF; --End of applied ps id -6 or -9

    --Bug 1634986 Fetch the PS before updating to reflect the changes before receipt.
    --The position of the actualy fetch has been changed to fetch it before.

    /* Get UNAPP and ACTIVITY CCIDs */

    OPEN activity_c;
    FETCH activity_c INTO activity_rec;

    IF activity_c%NOTFOUND THEN
      CLOSE activity_c;
      RAISE NO_DATA_FOUND;
    END IF;

    CLOSE activity_c;

    /* Update the cash receipt in the payment schedule table. */
    arp_ps_util.update_receipt_related_columns(
                  p_receipt_ps_id,
                  p_amount_applied,
                  p_apply_date,
                  p_gl_date,
                  l_acctd_amount_applied_from,
                  NULL_VAR,
                  NULL );

    /* Validate that the activity used matches the seeded row */
    validate_activity(p_application_ps_id,activity_rec.activity_type);

    l_ra_rec.cash_receipt_id        := activity_rec.cash_receipt_id;

    /* Prepare for 'UNAPP' record insertion with -ve amount applied */

    l_ra_rec.payment_schedule_id    := p_receipt_ps_id;
    l_ra_rec.amount_applied         := -p_amount_applied;


    /* Get the acctd_amount_applied_from value */
    /*-------------------------------------------------------------------------+
     |Bug 1823299 - accounted amount should be calculated as follows           |
     |acctd_amount_applied_from =  acconnted amount due reminaing -            |
     |                             ((amount_due_remaining before application   |
     |                               - amount_applied)/Exchange rate)          |
     |This calculation will avoid leaving small amounts as unapplied eventhough|
     |receipt is been fully applied.                                           |
     +-------------------------------------------------------------------------*/

    l_func_amount_due_remaining        :=
                 ARPCURR.functional_amount((l_ps_rec.amount_due_remaining - l_ra_rec.amount_applied),
                                            functional_curr,
                                            l_ps_rec.exchange_rate,
                                            NULL, NULL );

    l_ra_rec.acctd_amount_applied_from :=   l_ps_rec.acctd_amount_due_remaining - l_func_amount_due_remaining;

   /* Get the acctd_amount_applied_from value */

    IF (p_application_ps_id = -5 AND
       p_application_ref_id is not null) THEN

       SELECT invoice_currency_code,
              exchange_rate
       INTO   l_invoice_currency_code,
              l_exchange_rate
       FROM   ra_customer_trx
       WHERE  customer_trx_id = p_application_ref_id;

       l_ra_rec.acctd_amount_applied_to :=
  	ARPCURR.functional_amount(
		  amount	=> l_ra_rec.amount_applied
                , currency_code	=> functional_curr
                , exchange_rate	=> l_exchange_rate
                , precision	=> NULL
		, min_acc_unit	=> NULL );

    --CC Chargeback change
    ELSIF ( (p_application_ps_id = -6 OR p_application_ps_id = -9)
           AND l_application_ref_id is not null) THEN
    --Bug 2103345 - Calculate acctd_amount_applied_to for cc refund using exchange
    --rate of Misc.receipt associated.

       SELECT currency_code,
              exchange_rate
       INTO   l_receipt_currency_code,
              l_exchange_rate
       FROM   ar_cash_receipts
       WHERE  cash_receipt_id = l_application_ref_id;

        l_ra_rec.acctd_amount_applied_to :=
  	ARPCURR.functional_amount(
		  amount	=> l_ra_rec.amount_applied
                , currency_code	=> functional_curr
                , exchange_rate	=> l_exchange_rate
                , precision	=> NULL
		, min_acc_unit	=> NULL );
    ELSIF (p_receivables_trx_id = -16) THEN
      -- Bug 2821139 - Calculate acctd_amount_applied_to for payment netting
      -- using exchange rate of applied to receipt

        IF l_netted_receipt_flag = 'N' THEN
          SELECT invoice_currency_code,
                 exchange_rate
          INTO   l_receipt_currency_code,
                 l_exchange_rate
          FROM   ar_payment_schedules
          WHERE  payment_schedule_id = p_application_ps_id;
        ELSE
          l_exchange_rate := l_ps_rec.exchange_rate;
        END IF;

        l_ra_rec.acctd_amount_applied_to :=
  	ARPCURR.functional_amount(
		  amount	=> l_ra_rec.amount_applied
                , currency_code	=> functional_curr
                , exchange_rate	=> l_exchange_rate
                , precision	=> NULL
		, min_acc_unit	=> NULL );
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'acctd_amount_applied_from = '||TO_CHAR( l_ra_rec.acctd_amount_applied_from ) );
       arp_debug.debug(   'acctd_amount_applied_to = '||TO_CHAR( l_ra_rec.acctd_amount_applied_to ) );
    END IF;

    /* Fill in the UNAPP application information */

    l_ra_rec.status                 := 'UNAPP';
    l_ra_rec.application_type       := 'CASH';

    l_ra_rec.application_rule       := 'ACTIVITY APPLICATION';
    l_ra_rec.program_id	            := -100106;

    l_ra_rec.code_combination_id    := activity_rec.unapplied_ccid;
    l_ra_rec.apply_date             := p_apply_date;
    l_ra_rec.gl_date                := p_gl_date;
    l_ra_rec.posting_control_id     := -3;
    l_ra_rec.display                := 'N';
    l_ra_rec.application_ref_id     := p_application_ref_id;

    /* 14-APR-2000 jrautiai BR implementation
     * For Short Term Debt applications the UNAPP row is not postable */

    IF NVL(p_application_ps_id,0) = -2 THEN
      l_ra_rec.postable             := 'N';
    ELSE
      l_ra_rec.postable             := 'Y';
    END IF;

    l_ra_rec.ussgl_transaction_code    := p_ussgl_transaction_code;
    l_ra_rec.attribute_category        := p_attribute_category;
    l_ra_rec.attribute1                := p_attribute1;
    l_ra_rec.attribute2                := p_attribute2;
    l_ra_rec.attribute3                := p_attribute3;
    l_ra_rec.attribute4                := p_attribute4;
    l_ra_rec.attribute5                := p_attribute5;
    l_ra_rec.attribute6                := p_attribute6;
    l_ra_rec.attribute7                := p_attribute7;
    l_ra_rec.attribute8                := p_attribute8;
    l_ra_rec.attribute9                := p_attribute9;
    l_ra_rec.attribute10               := p_attribute10;
    l_ra_rec.attribute11               := p_attribute11;
    l_ra_rec.attribute12               := p_attribute12;
    l_ra_rec.attribute13               := p_attribute13;
    l_ra_rec.attribute14               := p_attribute14;
    l_ra_rec.attribute15               := p_attribute15;
    l_ra_rec.global_attribute_category := p_global_attribute_category;
    l_ra_rec.global_attribute1         := p_global_attribute1;
    l_ra_rec.global_attribute2         := p_global_attribute2;
    l_ra_rec.global_attribute3         := p_global_attribute3;
    l_ra_rec.global_attribute4         := p_global_attribute4;
    l_ra_rec.global_attribute5         := p_global_attribute5;
    l_ra_rec.global_attribute6         := p_global_attribute6;
    l_ra_rec.global_attribute7         := p_global_attribute7;
    l_ra_rec.global_attribute8         := p_global_attribute8;
    l_ra_rec.global_attribute9         := p_global_attribute9;
    l_ra_rec.global_attribute10        := p_global_attribute10;
    l_ra_rec.global_attribute11        := p_global_attribute11;
    l_ra_rec.global_attribute12        := p_global_attribute12;
    l_ra_rec.global_attribute13        := p_global_attribute13;
    l_ra_rec.global_attribute14        := p_global_attribute14;
    l_ra_rec.global_attribute15        := p_global_attribute15;
    l_ra_rec.global_attribute16        := p_global_attribute16;
    l_ra_rec.global_attribute17        := p_global_attribute17;
    l_ra_rec.global_attribute18        := p_global_attribute18;
    l_ra_rec.global_attribute19        := p_global_attribute19;
    l_ra_rec.global_attribute20        := p_global_attribute20;
    l_ra_rec.comments                  := p_comments;


    /* Insert UNAPP record */
    arp_app_pkg.insert_p( l_ra_rec, l_ra_rec.receivable_application_id );

    IF l_ra_rec.receivable_application_id IS NOT NULL THEN
         l_xla_ev_rec.xla_from_doc_id := l_ra_rec.receivable_application_id;
         l_xla_ev_rec.xla_to_doc_id   := l_ra_rec.receivable_application_id;
         l_xla_ev_rec.xla_mode        := 'O';
         l_xla_ev_rec.xla_call        := 'B';
         l_xla_ev_rec.xla_doc_table := 'APP';
         ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
    END IF;

    l_unapp_ra_rec := l_ra_rec;

    /* Set UNAPP id for PAIRING */
    l_prev_unapp_id := l_ra_rec.receivable_application_id;

    /* ---------------------------------------------------------------------
     * Prepare for 'ACTIVITY' record insertion with +ve amount applied.
     * Applied_payment_schedule_id and applied_customer_trx_id are negative
     * ie for short term debt -2 and display = 'Y', Only the following
     * details change for the 'ACTIVITY' record from the UNAPP record during
     * application insertion.
     * --------------------------------------------------------------------- */

   /* -------------------------------------------------------------------+
    | Balancing segment of ACTIVITY application should be replaced with  |
    | that of Receipt's UNAPP record                                     |
    +--------------------------------------------------------------------*/
    IF NVL(FND_PROFILE.value('AR_DISABLE_REC_ACTIVITY_BALSEG_SUBSTITUTION'),
           'N') = 'N' THEN
       arp_util.Substitute_Ccid(
                             p_coa_id        => arp_global.chart_of_accounts_id,
                             p_original_ccid => activity_rec.activity_ccid    ,
                             p_subs_ccid     => activity_rec.unapplied_ccid   ,
                             p_actual_ccid   => l_ra_rec.code_combination_id );
    ELSE
     l_ra_rec.code_combination_id := activity_rec.activity_ccid;
    END IF;

    l_ra_rec.receivable_application_id   := NULL; /* filled during act.insert */
--    l_ra_rec.applied_customer_trx_id     := p_application_ps_id;
    l_ra_rec.applied_payment_schedule_id := p_application_ps_id;
    l_ra_rec.receivables_trx_id          := p_receivables_trx_id;
    l_ra_rec.link_to_customer_trx_id     := p_link_to_customer_trx_id;
    l_ra_rec.amount_applied              := p_amount_applied;
    l_ra_rec.application_rule            := 'ACTIVITY APPLICATION';
    l_ra_rec.program_id                  := -100107;

    /* acctd_amount_applied_from is -ve of already calculated
     * acctd_amount_applied_from for 'UNAPP' record */

    l_ra_rec.acctd_amount_applied_from   := -l_ra_rec.acctd_amount_applied_from;
    l_ra_rec.acctd_amount_applied_to     := -l_ra_rec.acctd_amount_applied_to;

    l_ra_rec.status   := 'ACTIVITY';
    l_ra_rec.postable := 'Y';
    l_ra_rec.display  := 'Y';
    l_ra_rec.application_ref_type       := l_application_ref_type;
    l_ra_rec.application_ref_id         := l_application_ref_id;
    l_ra_rec.application_ref_num        := l_application_ref_num;
    l_ra_rec.secondary_application_ref_id  := l_secondary_application_ref_id;
    l_ra_rec.secondary_application_ref_type := l_secondary_app_ref_type;
    l_ra_rec.secondary_application_ref_num  := l_secondary_app_ref_num;
    l_ra_rec.payment_set_id             := p_payment_set_id;
    l_ra_rec.customer_reference         := p_customer_reference ;
    l_ra_rec.customer_reason            := p_customer_reason ;
    l_ra_rec.application_ref_reason     := l_application_ref_reason;--5450371

    --This is for temporary. When we change the column we will replace this
    --also
    l_ra_rec.secondary_application_ref_id := l_secondary_application_ref_id;

    l_ra_rec.amount_applied_from       := p_amount_applied;


    /* Insert ACTIVITY record */
    arp_app_pkg.insert_p( l_ra_rec, l_ra_rec.receivable_application_id );

    IF l_ra_rec.receivable_application_id IS NOT NULL THEN
         l_xla_ev_rec.xla_from_doc_id := l_ra_rec.receivable_application_id;
         l_xla_ev_rec.xla_to_doc_id   := l_ra_rec.receivable_application_id;
         l_xla_ev_rec.xla_mode        := 'O';
         l_xla_ev_rec.xla_call        := 'B';
         l_xla_ev_rec.xla_doc_table := 'APP';
         ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
    END IF;

   arp_debug.debug('netted cash receipt id = ' || to_char(p_netted_cash_receipt_id));
   IF (p_receivables_trx_id = -16) THEN
      l_mc_application_ref_id := p_netted_cash_receipt_id;
   ELSE
      l_mc_application_ref_id := l_application_ref_id;
   END IF;
   -- Process MRC data if needed before accounting engine is called.

   --apandit
   --Bug : 2641517 raise the business event
     AR_BUS_EVENT_COVER.Raise_CR_Apply_Event(l_ra_rec.receivable_application_id);

   IF NVL(p_application_ps_id,0) = -2 THEN

     /* In case of Short Term Debt application, the UNAPP record is NOT
      * postable so accounting only for activity (ACTIVITY application) */

      l_ae_doc_rec.document_type             := 'RECEIPT';
      l_ae_doc_rec.document_id               := l_ra_rec.cash_receipt_id;
      l_ae_doc_rec.accounting_entity_level   := 'ONE';
      l_ae_doc_rec.source_table              := 'RA';
      l_ae_doc_rec.source_id                 := l_ra_rec.receivable_application_id;
      l_ae_doc_rec.source_id_old             := '';
      l_ae_doc_rec.other_flag                := '';
      arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

     /* Bug fix 4910860 */
      IF nvl(p_module_name,'RAPI') = 'RAPI' THEN
         l_called_from_api := 'Y';
      ELSE
         l_called_from_api := 'N';
      END IF;
       arp_balance_check.CHECK_RECP_BALANCE(
                    l_ra_rec.cash_receipt_id,
                    NULL,
                    l_called_from_api);

   ELSE

     /* Otherwise the UNAPP record is postable so create paired accounting */

     /* Release 11.5 VAT changes, create paired UNAPP record accounting
      * in ar_distributions */

      l_ae_doc_rec.document_type             := 'RECEIPT';
      l_ae_doc_rec.document_id               := l_ra_rec.cash_receipt_id;
      l_ae_doc_rec.accounting_entity_level   := 'ONE';
      l_ae_doc_rec.source_table              := 'RA';
      l_ae_doc_rec.source_id                 := l_prev_unapp_id;
      l_ae_doc_rec.source_id_old             := l_ra_rec.receivable_application_id;
      l_ae_doc_rec.other_flag                := 'PAIR';
      arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);


      /* Release 11.5 VAT changes, create ACTIVITY record accounting
       * in ar_distributions */

      l_ae_doc_rec.source_id                 := l_ra_rec.receivable_application_id;
      l_ae_doc_rec.source_id_old             := '';
      l_ae_doc_rec.other_flag                := '';
      arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

     /* Bug fix 4910860 */
      IF nvl(p_module_name,'RAPI') = 'RAPI' THEN
         l_called_from_api := 'Y';
      ELSE
         l_called_from_api := 'N';
      END IF;
      arp_balance_check.CHECK_RECP_BALANCE(
                     l_ra_rec.cash_receipt_id,
                      NULL,
                      l_called_from_api);

   END IF;


    /* First, set ar_cash_receipt record values to dummy.
     * This is to distinguish between updateable NULL and NULL value (dummy)
     * which means that column is not to be updated. */

    arp_cash_receipts_pkg.set_to_dummy(l_cr_rec);

    /* ---------------------------------------------------------------------
     * Cash receipt must be fully applied in order to set the status
     * to 'Applied'.
     * --------------------------------------------------------------------- */
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug (  '-- Defining receipt status ...');
       arp_debug.debug (  '-- p_amount_applied = '||to_char(p_amount_applied));
       arp_debug.debug (  '-- activity_rec.amount_due_remaining = '||to_char(activity_rec.amount_due_remaining));
    END IF;


    /* Determine if the receipt has been fully applied.
     * We include the total amount that is On Account as this is
     * not included in the Payment Schedules, Amount Due Remaining
     * total for the receipt. */

    select nvl(sum(ra.amount_applied),0)
    into   l_on_account_total
    from   ar_receivable_applications ra
    where  ra.cash_receipt_id = l_ra_rec.cash_receipt_id
    and    ra.status IN ('ACC','OTHER ACC');

    IF (activity_rec.amount_due_remaining + l_on_account_total + p_amount_applied < 0)
    THEN
      l_cr_rec.status           := 'UNAPP';
    ELSE
      l_cr_rec.status           := 'APP';
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug (  '-- status = '|| l_cr_rec.status);
    END IF;

    l_cr_rec.cash_receipt_id  := l_ra_rec.cash_receipt_id;

    /* Update cash receipt status. */
    arp_cash_receipts_pkg.update_p(l_cr_rec,
                                   l_ra_rec.cash_receipt_id);

    /* ---------------------------------------------------------------------
     * Update batch status if receipt has a batch
     * For Bills Receivable Short Term Debt application this does not do
     * anything, since the batch id for the cash receipt history record is
     * always NULL. For other type activity applications the called procedure
     * needs to be changed to support the new activity application.
     * --------------------------------------------------------------------- */
    IF (activity_rec.batch_id IS NOT NULL AND Nvl(p_called_from,'*')<>'WRITEOFF')  /*5444407*/
    THEN
      arp_rw_batches_check_pkg.update_batch_status(activity_rec.batch_id);
    END IF;

    /* ---------------------------------------------------------------------
     * Return the new receivable application id back to the form
     * --------------------------------------------------------------------- */
    p_out_rec_application_id     := l_ra_rec.receivable_application_id;
    p_application_ref_type       := l_application_ref_type;
    p_application_ref_id         := l_application_ref_id;
    p_application_ref_num        := l_application_ref_num;
    p_secondary_application_ref_id  := l_secondary_application_ref_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(  'arp_process_application.activity_application()-' );
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_debug.debug(  'EXCEPTION: arp_process_application.activity_application' );
           END IF;
              RAISE;

END activity_application;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_activity_args                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure to validate arguments passed to activity_application()       |
 |    procedure.                                                             |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_ps_id              - Id of receipt ps                |
 |                    p_application_ps_id  - Id of application ps            |
 |                    p_amount_applied     - Amount Applied                  |
 |                    p_apply_date         - Application date                |
 |                    p_gl_date            - GL date of the application      |
 |                    p_receivables_trx_id - Receivable activity ID          |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Jani Rautiainen - 14-APR-2000           |
 |         Satheesh Nambiar 24-Aug-00 Modified to add a new applied payment  |
 |                                    schedule_id of -3 for receipt write-off|
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_activity_args(
        p_ps_id                    IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_application_ps_id        IN ar_receivable_applications.applied_payment_schedule_id%TYPE,
        p_link_to_customer_trx_id  IN ar_receivable_applications.link_to_customer_trx_id%TYPE,
        p_amount_applied           IN ar_receivable_applications.amount_applied%TYPE,
        p_apply_date               IN ar_receivable_applications.apply_date%TYPE,
        p_gl_date                  IN ar_receivable_applications.gl_date%TYPE,
        p_receivables_trx_id       IN ar_receivable_applications.receivables_trx_id%TYPE) IS

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(  'arp_process_application.validate_activity_args()+' );
    END IF;

    /* All the arguments must be defined */

    --SNAMBIAR Modified to add a new applied_ps_id -3 for receipt write-off
    -- Bug 2751910 - allow for +ve ps_id if netting activity -16

    IF ( p_ps_id IS NULL OR p_apply_date IS NULL OR p_gl_date IS NULL OR p_amount_applied IS NULL
         OR p_receivables_trx_id IS NULL OR p_application_ps_id IS NULL
         OR (p_receivables_trx_id <> -16 AND p_application_ps_id > -1) )  THEN
            FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
            APP_EXCEPTION.raise_exception;
    END IF;
    IF   p_application_ps_id IN (-2) AND p_link_to_customer_trx_id IS NULL THEN
            FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
            APP_EXCEPTION.raise_exception;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(  'arp_process_application.validate_activity_args()-' );
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_debug.debug(  'EXCEPTION: arp_process_application.validate_activity_args' );
           END IF;
           RAISE;
END validate_activity_args;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    fetch_app_ccid                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure fetches the CCID for the application. This changed for  |
 |    the BR project since the accounting for Bills Receivable document is   |
 |    stored in the ar_distributions table instead of the                    |
 |    ra_cust_trx_lines_gl_dist table (where the accounting is stored for    |
 |    other transactions). This was done to confirm with SLA standards       |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_invoice_ps_id           - Id of transaction ps       |
 |                                                                           |
 |              OUT:                                                         |
 |                    p_applied_customer_trx_id - Id of applied transaction  |
 |                    p_code_combination        - CCID for the application   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Jani Rautiainen - 14-APR-2000           |
 |                                                                           |
 +===========================================================================*/
PROCEDURE fetch_app_ccid(
        p_invoice_ps_id           IN  ar_payment_schedules.payment_schedule_id%TYPE,
        p_applied_customer_trx_id OUT NOCOPY ar_receivable_applications.applied_customer_trx_id%TYPE,
        p_code_combination_id     OUT NOCOPY ar_receivable_applications.code_combination_id%TYPE,
        p_source_type             OUT NOCOPY ar_distributions.source_type%TYPE) IS

  /* Cursor to fetch the given transaction information */
  CURSOR doc_cur IS
    SELECT ps.customer_trx_id,
           ps.class,
           ps.amount_due_original
    FROM ar_payment_schedules ps
    WHERE ps.payment_schedule_id = p_invoice_ps_id;

  /* Cursor to fetch normal transaction CCID, the old functionality */
  CURSOR trx_dist_cur(l_customer_trx_id ra_customer_trx.customer_trx_id%TYPE) IS
    SELECT dist.code_combination_id
    FROM ra_cust_trx_line_gl_dist dist
    WHERE dist.customer_trx_id = l_customer_trx_id
    AND dist.account_class = 'REC'
    AND dist.latest_rec_flag = 'Y';

  /* Cursor to fetch BR transaction CCID, new functionality */
  CURSOR br_dist_cur(p_transaction_history_id ar_transaction_history.transaction_history_id%TYPE, p_sign NUMBER) IS
    SELECT dist.code_combination_id, dist.source_type
    FROM ar_distributions dist
    WHERE dist.source_id = p_transaction_history_id
    AND dist.source_table = 'TH'
    AND dist.source_type in ('REC','REMITTANCE','FACTOR','UNPAIDREC')
    AND dist.source_id_secondary    IS null
    AND dist.source_table_secondary IS null
    AND dist.source_type_secondary  IS null
    and   (((sign(p_sign) > 0)
             and ((nvl(dist.AMOUNT_DR,0) <> 0) OR (nvl(dist.ACCTD_AMOUNT_DR,0) <> 0))
             and (nvl(dist.AMOUNT_CR,0) = 0) and (nvl(dist.ACCTD_AMOUNT_CR,0) = 0))
        OR ((sign(p_sign) < 0)
             and ((nvl(dist.AMOUNT_CR,0) <> 0) OR (nvl(dist.ACCTD_AMOUNT_CR,0) <> 0))
             and (nvl(dist.AMOUNT_DR,0) = 0) and (nvl(dist.ACCTD_AMOUNT_DR,0) = 0)))
    order by dist.line_id desc;

  /* Cursor to fetch current BR transaction history record */
  CURSOR br_current_trh_cur(p_customer_trx_id ra_customer_trx.customer_trx_id%TYPE) IS
    SELECT trh.transaction_history_id, trh.postable_flag, trh.event
    FROM ar_transaction_history trh
    WHERE trh.customer_trx_id = p_customer_trx_id
    AND trh.current_accounted_flag = 'Y';

  /* Cursor to fetch previous BR transaction postable transaction history record */
  CURSOR br_prev_postable_cur(p_transaction_history_id ar_transaction_history.transaction_history_id%TYPE) IS
   SELECT transaction_history_id
    FROM ar_transaction_history
    WHERE postable_flag = 'Y'
    AND event  <> 'MATURITY_DATE'
    CONNECT BY PRIOR prv_trx_history_id = transaction_history_id
    START WITH transaction_history_id = p_transaction_history_id
    ORDER BY transaction_history_id desc;


 doc_rec               doc_cur%ROWTYPE;
 trx_dist_rec          trx_dist_cur%ROWTYPE;
 br_dist_rec           br_dist_cur%ROWTYPE;
 br_current_trh_rec    br_current_trh_cur%ROWTYPE;
 br_prev_postable_rec  br_prev_postable_cur%ROWTYPE;
 l_postable_trh_id     ar_transaction_history.transaction_history_id%TYPE;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(  'arp_process_application.fetch_app_ccid()+' );
    END IF;

    /* Fetch transaction class to branch out NOCOPY the depending whether
     * we are dealing with Bills Receivable or not */
    OPEN doc_cur;
    FETCH doc_cur INTO doc_rec;
    CLOSE doc_cur;

    p_applied_customer_trx_id := doc_rec.customer_trx_id;

    IF NVL(doc_rec.class,'INV') = 'BR' THEN

      /* Fetch current transaction history record */
      OPEN br_current_trh_cur(doc_rec.customer_trx_id);
      FETCH br_current_trh_cur INTO br_current_trh_rec;

      IF br_current_trh_cur%NOTFOUND THEN
        CLOSE br_current_trh_cur;
        RAISE NO_DATA_FOUND;
      END IF;

      CLOSE br_current_trh_cur;

      IF NVL(br_current_trh_rec.postable_flag,'Y') = 'N' or NVL(br_current_trh_rec.event,'NONE') = 'MATURITY_DATE' THEN

        /* Fetch the previous posted history record */
        OPEN br_prev_postable_cur(br_current_trh_rec.transaction_history_id);
        FETCH br_prev_postable_cur INTO br_prev_postable_rec;

        IF br_prev_postable_cur%NOTFOUND THEN
          CLOSE br_prev_postable_cur;
          RAISE NO_DATA_FOUND;
        END IF;

        CLOSE br_prev_postable_cur;

        l_postable_trh_id := br_prev_postable_rec.transaction_history_id;

      ELSE

        l_postable_trh_id := br_current_trh_rec.transaction_history_id;

      END IF;

      /* Fetch current CCID */
      OPEN br_dist_cur(l_postable_trh_id,sign(doc_rec.amount_due_original));
      FETCH br_dist_cur INTO br_dist_rec;

      IF br_dist_cur%NOTFOUND THEN
        CLOSE br_dist_cur;
        RAISE NO_DATA_FOUND;
      END IF;

      CLOSE br_dist_cur;

      p_code_combination_id := br_dist_rec.code_combination_id;
      p_source_type         := br_dist_rec.source_type;

    ELSE

      /* Otherwise the accounting is stored in the ra_cust_trx_line_gl_dist table */
      OPEN trx_dist_cur(doc_rec.customer_trx_id);
      FETCH trx_dist_cur INTO trx_dist_rec;

      IF trx_dist_cur%NOTFOUND THEN
        CLOSE trx_dist_cur;
        RAISE NO_DATA_FOUND;
      END IF;

      CLOSE trx_dist_cur;

      p_code_combination_id := trx_dist_rec.code_combination_id;
      p_source_type         := NULL;

    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(  'arp_process_application.fetch_app_ccid()-' );
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
		   IF PG_DEBUG in ('Y', 'C') THEN
		      arp_debug.debug(  SQLERRM(SQLCODE));
              arp_debug.debug(  'EXCEPTION: arp_process_application.fetch_app_ccid' );
           END IF;
           RAISE;
END fetch_app_ccid;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_activity                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure to validate activity ID given matches the seeded data        |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_application_ps_id  - Id of application ps            |
 |                    p_activity_type      - Receivable activity type        |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Jani Rautiainen - 14-APR-2000           |
 |         Satheesh Nambiar 24-Aug-00 Modified to add a new applied payment  |
 |                                    schedule_id of -3 for receipt write-off|
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_activity(
        p_application_ps_id  IN ar_receivable_applications.applied_payment_schedule_id%TYPE,
        p_activity_type      IN ar_receivables_trx.type%TYPE) IS

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(  'arp_process_application.validate_activity()+' );
    END IF;

    /* Activity and seeded ps must match. */
  --SNAMBIAR Added a new validation for applied PS id -3
    IF    (p_application_ps_id = (-2) and p_activity_type <> 'SHORT_TERM_DEBT' )
       OR (p_application_ps_id = (-3) and p_activity_type <> 'WRITEOFF' )
       OR (p_application_ps_id = (-6) and p_activity_type <> 'CCREFUND' )
       OR (p_application_ps_id = (-5) and p_activity_type <> 'ADJUST' )
       OR (p_application_ps_id = (-8) and p_activity_type <> 'CM_REFUND' )
    THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;

    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(  'arp_process_application.validate_activity()-' );
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_debug.debug(  'EXCEPTION: arp_process_application.validate_activity' );
           END IF;
           RAISE;
END validate_activity;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    unapp_postable                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Function checking whether the UNAPP row is postable or not.            |
 |    The unapp record is not postable if the BR transaction was closed      |
 |    by a application through a risk_elimination event                      |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_applied_customer_trx_id  - Id of application trx     |
 |                    p_applied_ps_id            - Id of application ps      |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : TRUE  - If the UNAPP row is postable                         |
 |              FALSE - If the UNAPP row is not postable                     |
 | MODIFICATION HISTORY - Created by Jani Rautiainen - 09-OCT-2000           |
 |                                                                           |
 +===========================================================================*/
FUNCTION unapp_postable(p_applied_customer_trx_id  IN ar_receivable_applications.applied_customer_trx_id%TYPE,
                        p_applied_ps_id            IN ar_receivable_applications.applied_payment_schedule_id%TYPE) RETURN BOOLEAN IS

  CURSOR trx_class_cur IS
    SELECT ps.class
    FROM ar_payment_schedules ps
    WHERE ps.payment_schedule_id     = p_applied_ps_id;

  CURSOR current_BR_cur IS
    SELECT trh.status, trh.event
    FROM ar_transaction_history trh
    WHERE trh.customer_trx_id     = p_applied_customer_trx_id
    AND   trh.current_record_flag = 'Y';

  trx_class_rec  trx_class_cur%ROWTYPE;
  current_BR_rec current_BR_cur%ROWTYPE;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(  'arp_process_application.unapp_postable()+' );
    END IF;

    IF p_applied_customer_trx_id  IS NULL OR p_applied_ps_id IS NULL OR p_applied_ps_id = -1 THEN

      RETURN TRUE;

    END IF;

    OPEN trx_class_cur;
    FETCH trx_class_cur INTO trx_class_rec;
    CLOSE trx_class_cur;

    IF NVL(trx_class_rec.class,'INV') = 'BR' THEN

      OPEN current_BR_cur;
      FETCH current_BR_cur INTO current_BR_rec;
      CLOSE current_BR_cur;

      IF current_BR_rec.status = 'CLOSED' AND current_BR_rec.event = 'RISK_ELIMINATED' THEN
        RETURN FALSE;
      ELSE
        RETURN TRUE;
      END IF;

    ELSE

      RETURN TRUE;

    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(  'arp_process_application.unapp_postable()-' );
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_debug.debug(  'EXCEPTION: arp_process_application.unapp_postable' );
           END IF;
           RAISE;
END unapp_postable;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    other_account_application                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Do all actions neccessary to insert rows into AR_RA table during       |
 |    Other Application. No PS table row is updated, However                 |
 |    2 RA rows are inserted - One as an UNAPP row and another as 'OTHER ACC'|
 |    application status OTHER ACC bahaves the same way as on-account ACC    |
 |    This new procedure is introduced for creating special applications like|
 |    claim and prepayment.                                                  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED -                                 |
 |         ARPCURR.functional_amount - Get the acctd amount of amount applied|
 |         arp_ps_pkg.fetch_p - Fetch a PS row                               |
 |         arp_app_pkg.insert_p - Insert a row into RA table                 |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_ps_id - PS id of the receipt                            |
 |                 p_amount_applied - Input amount applied                   |
 |                 p_apply_date - Application date                           |
 |                 p_gl_date    - Gl Date                                    |
 |                 p_receivables_trx_id  -Activity id                        |
 |                 p_applied_ps_id       - Applied payment schedule id -4,-7 |
 |                 p_ussgl_transaction_code - USSGL transaction code         |
 |                 OTHER DESCRIPTIVE FLEX columns                            |
 |                 p_module_name  - Name of the module that called this      |
 |                                  procedure                                |
 |                 p_module_version  - Version of the module that called this|
 |                                  procedure                                |
 |              OUT:                                                         |
 |		   p_out_rec_application_id                                  |
 |				Returned receivable application id           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES  -                                                                  |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 | 17-APR-01	S Nambiar	Created                                      |
 | 01-Jun-01    S.Nambiar       Bug 1811261 - OTHER ACC should derive the ccid
 |                              from activity selected                       |
 | 7-Sep-01     S.Nambiar       Added applied_ps_id,payment_set_id parameter |
 |                              to support prepayment applications.          |
 | 03-Sep-02   	Debbie Jancis   Modified for mrc trigger replacement.        |
 | 				added processing for receivable apps         |
 | 07-AUG-2003  Jon Beckett     Bug 3087819 - added p_called_from parameter  |
 |			        Claim is not created/updated if called from  |
 |                              Trade Management.                            |
 | 30-JUN-2004  Jon Beckett     Removed RAISE from handling of trade_mgt_err |
 |				to ensure TM errors are displayed correctly  |
 | 06-AUG-2004  Jon Beckett     Bug 3643551 - index on applied_ps_id         |
 |				ignored to ensure index on cash_receipt_id is|
 |				used in query on ar_receivable_applications  |
 | 03-MAR-2005  JASSING 	Added the code to check for the profile	     |
 |				option 'AR:Disable Receivable Activity       |
 |				Balancing Segment Substitution' for Claims   |
 |				and Prepayments. Bug Fix 4025652.	     |
 | 14-OCT-2005  Jon Beckett     Bug 4565758 - legal entity passed to TM      |
 +===========================================================================*/
PROCEDURE other_account_application(
        p_receipt_ps_id   IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_amount_applied IN
                ar_receivable_applications.amount_applied%TYPE,
        p_apply_date IN ar_receivable_applications.apply_date%TYPE,
        p_gl_date IN ar_receivable_applications.gl_date%TYPE,
        p_receivables_trx_id ar_receivable_applications.receivables_trx_id%TYPE,
        p_applied_ps_id  IN ar_receivable_applications.applied_payment_schedule_id%TYPE,
        p_ussgl_transaction_code IN
                ar_receivable_applications.ussgl_transaction_code%TYPE,
        p_application_ref_type IN
                ar_receivable_applications.application_ref_type%TYPE,
        p_application_ref_id IN
                ar_receivable_applications.application_ref_id%TYPE,
        p_application_ref_num IN
                ar_receivable_applications.application_ref_num%TYPE,
        p_secondary_application_ref_id IN NUMBER,
        p_comments IN
                ar_receivable_applications.comments%TYPE,
        p_attribute_category IN
                ar_receivable_applications.attribute_category%TYPE,
        p_attribute1 IN ar_receivable_applications.attribute1%TYPE,
        p_attribute2 IN ar_receivable_applications.attribute2%TYPE,
        p_attribute3 IN ar_receivable_applications.attribute3%TYPE,
        p_attribute4 IN ar_receivable_applications.attribute4%TYPE,
        p_attribute5 IN ar_receivable_applications.attribute5%TYPE,
        p_attribute6 IN ar_receivable_applications.attribute6%TYPE,
        p_attribute7 IN ar_receivable_applications.attribute7%TYPE,
        p_attribute8 IN ar_receivable_applications.attribute8%TYPE,
        p_attribute9 IN ar_receivable_applications.attribute9%TYPE,
        p_attribute10 IN ar_receivable_applications.attribute10%TYPE,
        p_attribute11 IN ar_receivable_applications.attribute11%TYPE,
        p_attribute12 IN ar_receivable_applications.attribute12%TYPE,
        p_attribute13 IN ar_receivable_applications.attribute13%TYPE,
        p_attribute14 IN ar_receivable_applications.attribute14%TYPE,
        p_attribute15 IN ar_receivable_applications.attribute15%TYPE,
        p_global_attribute_category IN ar_receivable_applications.global_attribute_category%TYPE,
        p_global_attribute1 IN ar_receivable_applications.global_attribute1%TYPE,
        p_global_attribute2 IN ar_receivable_applications.global_attribute2%TYPE,
        p_global_attribute3 IN ar_receivable_applications.global_attribute3%TYPE,
        p_global_attribute4 IN ar_receivable_applications.global_attribute4%TYPE,
        p_global_attribute5 IN ar_receivable_applications.global_attribute5%TYPE,
        p_global_attribute6 IN ar_receivable_applications.global_attribute6%TYPE,
        p_global_attribute7 IN ar_receivable_applications.global_attribute7%TYPE,
        p_global_attribute8 IN ar_receivable_applications.global_attribute8%TYPE,
        p_global_attribute9 IN ar_receivable_applications.global_attribute9%TYPE,
        p_global_attribute10 IN ar_receivable_applications.global_attribute10%TYPE,
        p_global_attribute11 IN ar_receivable_applications.global_attribute11%TYPE,
        p_global_attribute12 IN ar_receivable_applications.global_attribute12%TYPE,
        p_global_attribute13 IN ar_receivable_applications.global_attribute13%TYPE,
        p_global_attribute14 IN ar_receivable_applications.global_attribute14%TYPE,
        p_global_attribute15 IN ar_receivable_applications.global_attribute15%TYPE,
        p_global_attribute16 IN ar_receivable_applications.global_attribute16%TYPE,
        p_global_attribute17 IN ar_receivable_applications.global_attribute17%TYPE,
        p_global_attribute18 IN ar_receivable_applications.global_attribute18%TYPE,
        p_global_attribute19 IN ar_receivable_applications.global_attribute19%TYPE,
        p_global_attribute20 IN ar_receivable_applications.global_attribute20%TYPE,
        p_module_name IN VARCHAR2,
        p_module_version IN VARCHAR2,
        p_payment_set_id   IN ar_receivable_applications.payment_set_id%TYPE,
        x_application_ref_id OUT NOCOPY
                ar_receivable_applications.application_ref_id%TYPE,
        x_application_ref_num OUT NOCOPY
                ar_receivable_applications.application_ref_num%TYPE
        , x_return_status               OUT NOCOPY VARCHAR2
        , x_msg_count                   OUT NOCOPY NUMBER
        , x_msg_data                    OUT NOCOPY VARCHAR2
	, p_out_rec_application_id	OUT NOCOPY NUMBER
        , p_application_ref_reason IN ar_receivable_applications.application_ref_reason%TYPE
        , p_customer_reference     IN ar_receivable_applications.customer_reference%TYPE
        , p_customer_reason        IN ar_receivable_applications.customer_reason%TYPE
        , x_claim_reason_name      OUT NOCOPY VARCHAR2
	, p_called_from		   IN  VARCHAR2) IS

l_ra_rec   ar_receivable_applications%ROWTYPE;
l_ps_rec   ar_payment_schedules%ROWTYPE;

l_cr_rec                 ar_cash_receipts%ROWTYPE;
l_amount_due_remaining   NUMBER;
ln_batch_id	         NUMBER;
functional_curr          VARCHAR2(100);

l_activity_cc_id  ar_receipt_method_accounts.on_account_ccid%TYPE;
l_unapp_cc_id  ar_receipt_method_accounts.unapplied_ccid%TYPE;

l_on_account_total      NUMBER;
l_ae_doc_rec            ae_doc_rec_type;
l_prev_unapp_id         NUMBER;
l_currency_code         ar_cash_receipts.currency_code%TYPE;
l_exchange_rate_type    ar_cash_receipts.exchange_rate_type%TYPE;
l_exchange_rate_date    ar_cash_receipts.exchange_date%TYPE;
l_exchange_rate         ar_cash_receipts.exchange_rate%TYPE;
l_customer_id           ar_cash_receipts.pay_from_customer%TYPE;
l_customer_site_use_id  ar_cash_receipts.customer_site_use_id%TYPE;
l_receipt_number        ar_cash_receipts.receipt_number%TYPE;
l_claim_reason_code_id  NUMBER;
l_claim_reason_name     VARCHAR2(80);
l_amount_applied        NUMBER;
l_legal_entity_id       NUMBER;
l_called_from_api       VARCHAR2(1);

trade_mgt_err           EXCEPTION;

  --Bug#2750340
  l_xla_ev_rec      arp_xla_events.xla_events_type;
  l_xla_doc_table   VARCHAR2(20);

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'arp_process_application.other_account_application()+' );
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   '-- p_receipt_ps_id = '||TO_CHAR(p_receipt_ps_id));
       arp_debug.debug(   '-- p_amount_applied = '||
                        TO_CHAR( p_amount_applied ) );
       arp_debug.debug(   '-- p_gl_date = '|| TO_CHAR( p_gl_date ) );
       arp_debug.debug(   '-- p_apply_date = '|| TO_CHAR( p_apply_date ) );
    END IF;
    --
    IF ( p_module_name IS NOT NULL AND p_module_version IS NOT NULL ) THEN
         validate_on_account_args( p_receipt_ps_id, p_amount_applied,
                                   p_apply_date, p_gl_date );
    END IF;
    --
    arp_ps_pkg.fetch_p( p_receipt_ps_id, l_ps_rec );

    functional_curr := arp_global.functional_currency;
    -- ---------------------------------------------------------------------
    -- Get UNAPP and OTHER ACC CC'Ids by selecting from receipt method accounts
    -- table
    -- ---------------------------------------------------------------------
    --Bug 1811261 - OTHER ACC should take the ccid from the activity
    SELECT ps.cash_receipt_id,
           ps.amount_due_remaining,
           rt.code_combination_id activity_ccid,
           rma.unapplied_ccid,
	   crh.batch_id,
           cr.currency_code
         , cr.exchange_rate_type
         , cr.exchange_date
         , cr.exchange_rate
         , cr.pay_from_customer
         , cr.customer_site_use_id
         , cr.receipt_number
         , cr.legal_entity_id
    INTO     l_ra_rec.cash_receipt_id
           , l_amount_due_remaining
           , l_activity_cc_id
           , l_unapp_cc_id
	   , ln_batch_id
           , l_currency_code
	   , l_exchange_rate_type
	   , l_exchange_rate_date
	   , l_exchange_rate
	   , l_customer_id
	   , l_customer_site_use_id
           , l_receipt_number
           , l_legal_entity_id
    FROM     ar_payment_schedules 	ps
           , ar_cash_receipts 		cr
	   , ar_cash_receipt_history	crh
           , ar_receipt_methods 	rm
           , ce_bank_acct_uses 		ba
           , ar_receipt_method_accounts rma
           , ar_receivables_trx         rt
    WHERE  ps.payment_schedule_id 	= p_receipt_ps_id
    AND    cr.cash_receipt_id 		= ps.cash_receipt_id
    AND	   crh.cash_receipt_id		= cr.cash_receipt_id
    AND	   crh.current_record_flag	= 'Y'
    AND    rm.receipt_method_id 	= cr.receipt_method_id
    AND    ba.bank_acct_use_id 		= cr.remit_bank_acct_use_id
    AND    rma.remit_bank_acct_use_id 	= ba.bank_acct_use_id
    AND    rma.receipt_method_id 	= rm.receipt_method_id
    AND    rt.receivables_trx_id        = p_receivables_trx_id;

    -----------------------------------------------------
    -- Bug 1775823 iClaim/deductions
    -- Check for receipt being applied to a claim investigation for a given
    -- claim number more than once
    -----------------------------------------------------
    IF NVL(p_applied_ps_id,0) = -4 THEN

       DECLARE
         l_found   varchar2(1) := 'N';
       BEGIN

       -- Bug 3643551: use of index on applied_ps_id prevented
        SELECT 'Y'
        INTO   l_found
        FROM   ar_receivable_applications rap
        WHERE  rap.cash_receipt_id = l_ra_rec.cash_receipt_id
        AND    rap.applied_payment_schedule_id + 0 = -4
        AND    rap.secondary_application_ref_id = p_secondary_application_ref_id
        AND    rap.display = 'Y'
        AND    rap.status = 'OTHER ACC';

       IF l_found = 'Y' THEN
        raise too_many_rows;
       END IF;

      EXCEPTION
      WHEN no_data_found THEN
        null;
      WHEN too_many_rows THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name ('AR', 'AR_RW_APP_CLAIM_MULTI_ASSIGN' );
        APP_EXCEPTION.raise_exception;
      END;
    END IF;

    -- Get the current amount that is 'on account' application for this receipt.
    -- This is used later on to determine it the receipt has been
    -- fully applied.  We need to do the sum now so we don't include
    -- the claim application row that we are about to create.
    --
    BEGIN
       select nvl(sum(ra.amount_applied),0)
       into   l_on_account_total
       from   ar_receivable_applications ra
       where  ra.cash_receipt_id = l_ra_rec.cash_receipt_id
       and    ra.status IN ('ACC','OTHER ACC');
    EXCEPTION
     WHEN NO_DATA_FOUND then
        l_on_account_total := 0;
    END;

    -- Prepare for 'UNAPP' record insertion with -ve amount applied
    -- applied_customer_trx_id is NULL and display = 'N'
    --
    l_ra_rec.payment_schedule_id := p_receipt_ps_id;
    l_ra_rec.amount_applied := -p_amount_applied;
    --
    -- Get the acctd_amount_applied_from value
    --
    l_ra_rec.acctd_amount_applied_from :=
                 ARPCURR.functional_amount( l_ra_rec.amount_applied,
                                            functional_curr,
                                            l_ps_rec.exchange_rate,
                                            NULL, NULL );
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'acctd_amount_applied_from = '||
                         TO_CHAR( l_ra_rec.acctd_amount_applied_from ) );
    END IF;
    --
    l_ra_rec.status := 'UNAPP';
    l_ra_rec.application_type := 'CASH';

    l_ra_rec.application_rule := '60.7';
    l_ra_rec.program_id	:= -100106;

    l_ra_rec.code_combination_id := l_unapp_cc_id;
    l_ra_rec.apply_date := p_apply_date;
    l_ra_rec.gl_date := p_gl_date;
    l_ra_rec.posting_control_id := -3;
    l_ra_rec.display := 'N';
    l_ra_rec.postable := 'Y';
    l_ra_rec.ussgl_transaction_code := p_ussgl_transaction_code;
    l_ra_rec.attribute_category := p_attribute_category;
    l_ra_rec.attribute1 := p_attribute1;
    l_ra_rec.attribute2 := p_attribute2;
    l_ra_rec.attribute3 := p_attribute3;
    l_ra_rec.attribute4 := p_attribute4;
    l_ra_rec.attribute5 := p_attribute5;
    l_ra_rec.attribute6 := p_attribute6;
    l_ra_rec.attribute7 := p_attribute7;
    l_ra_rec.attribute8 := p_attribute8;
    l_ra_rec.attribute9 := p_attribute9;
    l_ra_rec.attribute10 := p_attribute10;
    l_ra_rec.attribute11 := p_attribute11;
    l_ra_rec.attribute12 := p_attribute12;
    l_ra_rec.attribute13 := p_attribute13;
    l_ra_rec.attribute14 := p_attribute14;
    l_ra_rec.attribute15 := p_attribute15;
    l_ra_rec.global_attribute_category := p_global_attribute_category;
    l_ra_rec.global_attribute1 := p_global_attribute1;
    l_ra_rec.global_attribute2 := p_global_attribute2;
    l_ra_rec.global_attribute3 := p_global_attribute3;
    l_ra_rec.global_attribute4 := p_global_attribute4;
    l_ra_rec.global_attribute5 := p_global_attribute5;
    l_ra_rec.global_attribute6 := p_global_attribute6;
    l_ra_rec.global_attribute7 := p_global_attribute7;
    l_ra_rec.global_attribute8 := p_global_attribute8;
    l_ra_rec.global_attribute9 := p_global_attribute9;
    l_ra_rec.global_attribute10 := p_global_attribute10;
    l_ra_rec.global_attribute11 := p_global_attribute11;
    l_ra_rec.global_attribute12 := p_global_attribute12;
    l_ra_rec.global_attribute13 := p_global_attribute13;
    l_ra_rec.global_attribute14 := p_global_attribute14;
    l_ra_rec.global_attribute15 := p_global_attribute15;
    l_ra_rec.global_attribute16 := p_global_attribute16;
    l_ra_rec.global_attribute17 := p_global_attribute17;
    l_ra_rec.global_attribute18 := p_global_attribute18;
    l_ra_rec.global_attribute19 := p_global_attribute19;
    l_ra_rec.global_attribute20 := p_global_attribute20;
    --Bug 1814683.
    l_ra_rec.comments  := p_comments;
    --
    -- Insert UNAPP record
    --
    arp_app_pkg.insert_p( l_ra_rec, l_ra_rec.receivable_application_id );

    IF l_ra_rec.receivable_application_id IS NOT NULL THEN
         l_xla_ev_rec.xla_from_doc_id := l_ra_rec.receivable_application_id;
         l_xla_ev_rec.xla_to_doc_id   := l_ra_rec.receivable_application_id;
         l_xla_ev_rec.xla_mode        := 'O';
         l_xla_ev_rec.xla_call        := 'B';
         l_xla_ev_rec.xla_doc_table := 'APP';
         ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
    END IF;


    --Set UNAPP id for PAIRING
    l_prev_unapp_id := l_ra_rec.receivable_application_id;

    -- ---------------------------------------------------------------------
    -- Prepare for 'OTHER ACC' record insertion with +ve amount applied
    -- applied_payment_schedule_id and applied_customer_trx_id are -1 and
    -- display = 'Y', Only the following details change for the 'OTHER ACC' record
    -- from the UNAPP record during claim application.
    -- ---------------------------------------------------------------------

    l_ra_rec.receivable_application_id := NULL; /* filled during act. insert */
    l_ra_rec.applied_customer_trx_id := -1;
    l_ra_rec.applied_payment_schedule_id := p_applied_ps_id;
  /*  l_ra_rec.code_combination_id := l_activity_cc_id;  Bug 4025652 */
    l_ra_rec.amount_applied := p_amount_applied;
    l_ra_rec.application_rule := '60.0';
    l_ra_rec.program_id := -100107;

    --
    -- acctd_amount_applied_from is -ve of already calculated
    -- acctd_amount_applied_from for 'UNAPP' record
    --
    l_ra_rec.acctd_amount_applied_from := -l_ra_rec.acctd_amount_applied_from;
    --
    l_ra_rec.status := 'OTHER ACC';
    l_ra_rec.receivables_trx_id := p_receivables_trx_id;
    l_ra_rec.display := 'Y';
    l_ra_rec.application_ref_type := p_application_ref_type;
    l_ra_rec.application_ref_id := p_application_ref_id;
    l_ra_rec.application_ref_num := p_application_ref_num;
    l_ra_rec.secondary_application_ref_id := p_secondary_application_ref_id;
    l_ra_rec.payment_set_id               := p_payment_set_id;
    l_ra_rec.application_ref_reason := p_application_ref_reason;
    l_ra_rec.customer_reference := p_customer_reference;
    l_ra_rec.customer_reason := p_customer_reason;
    --

   /* bug fix 4025652 */

    IF NVL(FND_PROFILE.value('AR_DISABLE_REC_ACTIVITY_BALSEG_SUBSTITUTION'),'N') = 'N' THEN
        arp_util.Substitute_Ccid(
                             p_coa_id        => arp_global.chart_of_accounts_id,
                             p_original_ccid => l_activity_cc_id    ,
                             p_subs_ccid     => l_unapp_cc_id   ,
                             p_actual_ccid   => l_ra_rec.code_combination_id );
    ELSE
     l_ra_rec.code_combination_id := l_activity_cc_id;
    END IF;
   /* End of bug fix 4025652 */
    /*Bug 5495310. Added p_apply_date*/

    IF (l_ra_rec.application_ref_type = 'CLAIM' AND
        NVL(p_called_from,'RAPI') <> 'TRADE_MANAGEMENT') THEN
       IF (l_ra_rec.application_ref_num IS NULL) THEN
         create_claim(
              p_amount               => p_amount_applied
            , p_amount_applied       => p_amount_applied
            , p_currency_code        => l_currency_code
            , p_exchange_rate_type   => l_exchange_rate_type
            , p_exchange_rate_date   => l_exchange_rate_date
            , p_exchange_rate        => l_exchange_rate
            , p_customer_trx_id      => NULL
            , p_invoice_ps_id        => NULL
            , p_cust_trx_type_id     => NULL
            , p_trx_number           => NULL
            , p_cust_account_id      => l_customer_id
            , p_bill_to_site_id      => l_customer_site_use_id
            , p_ship_to_site_id      => NULL
            , p_salesrep_id          => NULL   -- Bug 2361331
            , p_customer_ref_date    => NULL
            , p_customer_ref_number  => p_customer_reference
            , p_cash_receipt_id      => l_ra_rec.cash_receipt_id
            , p_receipt_number       => l_receipt_number
            , p_comments             => p_comments
            , p_reason_id            => p_application_ref_reason
            , p_customer_reason      => p_customer_reason
            , p_apply_date           => p_apply_date
            , p_attribute_category   => p_attribute_category
            , p_attribute1           => p_attribute1
            , p_attribute2           => p_attribute2
            , p_attribute3           => p_attribute3
            , p_attribute4           => p_attribute4
            , p_attribute5           => p_attribute5
            , p_attribute6           => p_attribute6
            , p_attribute7           => p_attribute7
            , p_attribute8           => p_attribute8
            , p_attribute9           => p_attribute9
            , p_attribute10          => p_attribute10
            , p_attribute11          => p_attribute11
            , p_attribute12          => p_attribute12
            , p_attribute13          => p_attribute13
            , p_attribute14          => p_attribute14
            , p_attribute15          => p_attribute15
            , x_return_status        => x_return_status
            , x_msg_count            => x_msg_count
            , x_msg_data             => x_msg_data
            , x_claim_id             => l_ra_rec.secondary_application_ref_id
            , x_claim_number         => l_ra_rec.application_ref_num
            , x_claim_reason_name    => x_claim_reason_name
            , p_legal_entity_id      => l_legal_entity_id);
       ELSE
         /* Bug 4170060 - update TM amount_applied with outstanding claim
            amount */
         l_amount_applied := arpt_sql_func_util.get_claim_amount(l_ra_rec.secondary_application_ref_id) + p_amount_applied;

         update_claim(
              p_claim_id             =>  l_ra_rec.secondary_application_ref_id
            , p_invoice_ps_id        =>  NULL
            , p_customer_trx_id      =>  NULL
            , p_amount               =>  p_amount_applied * -1
            , p_amount_applied       =>  l_amount_applied
            , p_apply_date           =>  p_apply_date
            , p_cash_receipt_id      =>  l_ra_rec.cash_receipt_id
            , p_receipt_number       =>  l_receipt_number
            , p_action_type          =>  'A'
            , x_claim_reason_code_id =>  l_claim_reason_code_id
            , x_claim_reason_name    =>  l_claim_reason_name
            , x_claim_number         =>  l_ra_rec.application_ref_num
            , x_return_status        =>  x_return_status
            , x_msg_count            =>  x_msg_count
            , x_msg_data             =>  x_msg_data
            , p_reason_id            =>  to_number(p_application_ref_reason)--Yao Zhang add for bug 10197191
            );
       END IF;
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise trade_mgt_err;
       END IF;
    END IF;
    x_application_ref_id := l_ra_rec.secondary_application_ref_id;
    x_application_ref_num := l_ra_rec.application_ref_num;

    -- Insert OTHER ACC record

    arp_app_pkg.insert_p( l_ra_rec, l_ra_rec.receivable_application_id );

    IF l_ra_rec.receivable_application_id IS NOT NULL THEN
         l_xla_ev_rec.xla_from_doc_id := l_ra_rec.receivable_application_id;
         l_xla_ev_rec.xla_to_doc_id   := l_ra_rec.receivable_application_id;
         l_xla_ev_rec.xla_mode        := 'O';
         l_xla_ev_rec.xla_call        := 'B';
         l_xla_ev_rec.xla_doc_table := 'APP';
         ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
    END IF;

   --  Call mrc engine to process inserts in to receivable apps
   --
   --Release 11.5 VAT changes, create paired UNAPP record accounting
   --in ar_distributions
   --
    l_ae_doc_rec.document_type             := 'RECEIPT';
    l_ae_doc_rec.document_id               := l_ra_rec.cash_receipt_id;
    l_ae_doc_rec.accounting_entity_level   := 'ONE';
    l_ae_doc_rec.source_table              := 'RA';
    l_ae_doc_rec.source_id                 := l_prev_unapp_id;
    l_ae_doc_rec.source_id_old             := l_ra_rec.receivable_application_id;
    l_ae_doc_rec.other_flag                := 'PAIR';
    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

   --
   --Release 11.5 VAT changes, create OTHER ACC record accounting
   --in ar_distributions
   --

    l_ae_doc_rec.source_id                 := l_ra_rec.receivable_application_id;
    l_ae_doc_rec.source_id_old             := '';
    l_ae_doc_rec.other_flag                := '';
    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);


   /* Bug 4910860
       Check if the journals balance */
      IF nvl(p_module_name,'RAPI') = 'RAPI' THEN
         l_called_from_api := 'Y';
      ELSE
        l_called_from_api := 'N';
      END IF;
    arp_balance_check.Check_Appln_Balance(l_ra_rec.receivable_application_id,
                                            l_prev_unapp_id,
                                            NULL,
                                            l_called_from_api);

    -- ----------------------------------------------------------------------
    -- 10/31/1996 K.Lawrance
    -- Finally update cash receipt status.
    -- ----------------------------------------------------------------------

    -- First, set ar_cash_receipt record values to dummy ...
    -- This is to distinguish between updateable NULL and NULL value (dummy)
    -- which means that column is not to be updated.

    arp_cash_receipts_pkg.set_to_dummy(l_cr_rec);

    -- ---------------------------------------------------------------------
    -- Cash receipt must be fully applied in order to set the status
    -- to 'Applied'.
    -- ---------------------------------------------------------------------
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug (  '-- Defining receipt status ...');
       arp_debug.debug (  '-- p_amount_applied = '||to_char(p_amount_applied));
       arp_debug.debug (  '-- l_amount_due_remaining = '||
		                            to_char(l_amount_due_remaining));
    END IF;

    -- Determine if the receipt has been fully applied.
    -- We include the total amount that is on account or claim as this is
    -- not included in the Payment Schedules, Amount Due Remaining
    -- total for the receipt.
    --
    IF (l_amount_due_remaining + l_on_account_total + p_amount_applied < 0)
    THEN
      l_cr_rec.status           := 'UNAPP';
    ELSE
      l_cr_rec.status           := 'APP';
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug (  '-- status = '|| l_cr_rec.status);
    END IF;

    l_cr_rec.cash_receipt_id  := l_ra_rec.cash_receipt_id;

    -- Update cash receipt status.
    arp_cash_receipts_pkg.update_p(
	  l_cr_rec
	, l_ra_rec.cash_receipt_id);

    -- ---------------------------------------------------------------------
    -- Update batch status if receipt has a batch
    -- ---------------------------------------------------------------------
    IF (ln_batch_id IS NOT NULL)
    THEN
      arp_rw_batches_check_pkg.update_batch_status(ln_batch_id);
    END IF;

    -- ---------------------------------------------------------------------
    -- Return the new receivable application id back to the form
    -- ---------------------------------------------------------------------
    p_out_rec_application_id := l_ra_rec.receivable_application_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'arp_process_application.other_account_application()-' );
    END IF;
    EXCEPTION
         WHEN trade_mgt_err THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_debug.debug('Trade Management : ' ||
                'EXCEPTION: arp_process_application.other_account_application' );
           END IF;
         WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_debug.debug(
                'EXCEPTION: arp_process_application.other_account_application' );
           END IF;
              RAISE;

END other_account_application;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    create_claim                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Calls iClaim group API to create a deduction claim.                    |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED -                                 |
 |      OZF_Claim_GRP.Create_Deduction - Group API to create a claim from AR |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   jbeckett    27-APR-2001  Created                                        |
 |   apandit     04-JUN-2001  Adde parameter p_invoice_ps_id. Bug 1812328    |
 |   jbeckett    10-AUG-2001  Added parameter p_ship_to_site_id. Bug 1893980 |
 |   jbeckett    13-MAR-2001  Bug 2254777 - added parameter reason_id        |
 |   jbeckett    09-MAY-2002  Bug 2361331 - added parameter p_salesrep_id    |
 |   jbeckett    14-OCT-2005  Bug 4565758 - legal entity passed to TM        |
 |   balkumar    18-SEP-2006  Bug 5495310 - added parameter p_apply_date     |
 |                                                                           |
 +===========================================================================*/
PROCEDURE create_claim(
              p_amount               IN  NUMBER
            , p_amount_applied       IN  NUMBER
            , p_currency_code        IN  VARCHAR2
            , p_exchange_rate_type   IN  VARCHAR2
            , p_exchange_rate_date   IN  DATE
            , p_exchange_rate        IN  NUMBER
            , p_customer_trx_id      IN  NUMBER
            , p_invoice_ps_id        IN  NUMBER
            , p_cust_trx_type_id     IN  NUMBER
            , p_trx_number           IN  VARCHAR2
            , p_cust_account_id      IN  NUMBER
            , p_bill_to_site_id      IN  NUMBER
            , p_ship_to_site_id      IN  NUMBER
            , p_salesrep_id          IN  NUMBER
            , p_customer_ref_date    IN  DATE
            , p_customer_ref_number  IN  VARCHAR2
            , p_cash_receipt_id      IN  NUMBER
            , p_receipt_number       IN  VARCHAR2
            , p_reason_id            IN  NUMBER
            , p_customer_reason      IN  VARCHAR2
            , p_comments             IN  VARCHAR2
            , p_apply_date           IN  DATE
            , p_attribute_category   IN  VARCHAR2
            , p_attribute1           IN  VARCHAR2
            , p_attribute2           IN  VARCHAR2
            , p_attribute3           IN  VARCHAR2
            , p_attribute4           IN  VARCHAR2
            , p_attribute5           IN  VARCHAR2
            , p_attribute6           IN  VARCHAR2
            , p_attribute7           IN  VARCHAR2
            , p_attribute8           IN  VARCHAR2
            , p_attribute9           IN  VARCHAR2
            , p_attribute10          IN  VARCHAR2
            , p_attribute11          IN  VARCHAR2
            , p_attribute12          IN  VARCHAR2
            , p_attribute13          IN  VARCHAR2
            , p_attribute14          IN  VARCHAR2
            , p_attribute15          IN  VARCHAR2
            , x_return_status        OUT NOCOPY VARCHAR2
            , x_msg_count            OUT NOCOPY NUMBER
            , x_msg_data             OUT NOCOPY VARCHAR2
            , x_claim_id             OUT NOCOPY NUMBER
            , x_claim_number         OUT NOCOPY VARCHAR2
            , x_claim_reason_name    OUT NOCOPY VARCHAR2
            , p_legal_entity_id      IN  NUMBER)
IS

  l_claim_rec           OZF_Claim_GRP.Deduction_Rec_Type;
  l_return_status       VARCHAR2(1);
  l_claim_reason_code_id NUMBER;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug(   'arp_process_application.create_claim()+' );
  END IF;
  IF p_amount = 0
  THEN
    x_return_status := 'S';
    x_claim_id := NULL;
    x_claim_number := NULL;
    RETURN;
  END IF;
  l_claim_rec.claim_date := p_apply_date;  /* bug 5495310 */
  l_claim_rec.due_date := NULL;
  l_claim_rec.claim_type_id := NULL;
  l_claim_rec.amount := p_amount;
  l_claim_rec.currency_code := p_currency_code;
  l_claim_rec.exchange_rate_type := p_exchange_rate_type;
  l_claim_rec.exchange_rate_date := p_exchange_rate_date;
  l_claim_rec.exchange_rate := p_exchange_rate;
  l_claim_rec.set_of_books_id := arp_global.set_of_books_id;
  l_claim_rec.amount_applied := p_amount_applied;
  l_claim_rec.legal_entity_id := p_legal_entity_id;
  IF p_customer_trx_id IS NOT NULL
  THEN
    l_claim_rec.source_object_id := p_customer_trx_id;
    l_claim_rec.source_object_type_id := p_cust_trx_type_id;
    l_claim_rec.source_object_class := 'INVOICE';
    l_claim_rec.source_object_number := p_trx_number;
  ELSE
    l_claim_rec.source_object_id := NULL;
    l_claim_rec.source_object_type_id := NULL;
    l_claim_rec.source_object_class := NULL;
    l_claim_rec.source_object_number := NULL;
  END IF;
  l_claim_rec.cust_account_id := p_cust_account_id;
  l_claim_rec.cust_billto_acct_site_id := p_bill_to_site_id;
  l_claim_rec.cust_shipto_acct_site_id := p_ship_to_site_id;
  l_claim_rec.sales_rep_id := p_salesrep_id;
  l_claim_rec.reason_code_id := p_reason_id;
  l_claim_rec.customer_ref_date := p_customer_ref_date;
  l_claim_rec.customer_ref_number := p_customer_ref_number;
  l_claim_rec.receipt_id := p_cash_receipt_id;
  l_claim_rec.receipt_number := p_receipt_number;
  l_claim_rec.comments := p_comments;
  l_claim_rec.deduction_attribute_category := p_attribute_category;
  l_claim_rec.deduction_attribute1 := p_attribute1;
  l_claim_rec.deduction_attribute2 := p_attribute2;
  l_claim_rec.deduction_attribute3 := p_attribute3;
  l_claim_rec.deduction_attribute4 := p_attribute4;
  l_claim_rec.deduction_attribute5 := p_attribute5;
  l_claim_rec.deduction_attribute6 := p_attribute6;
  l_claim_rec.deduction_attribute7 := p_attribute7;
  l_claim_rec.deduction_attribute8 := p_attribute8;
  l_claim_rec.deduction_attribute9 := p_attribute9;
  l_claim_rec.deduction_attribute10 := p_attribute10;
  l_claim_rec.deduction_attribute11 := p_attribute11;
  l_claim_rec.deduction_attribute12 := p_attribute12;
  l_claim_rec.deduction_attribute13 := p_attribute13;
  l_claim_rec.deduction_attribute14 := p_attribute14;
  l_claim_rec.deduction_attribute15 := p_attribute15;
  l_claim_rec.customer_reason := p_customer_reason;

  -- Dumping all the values

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug('set_of_books id = '||arp_global.set_of_books_id);
     arp_debug.debug('p_amount = '||p_amount);
     arp_debug.debug('p_amount_applied = '||p_amount_applied);
     arp_debug.debug('p_currency_code = '||p_currency_code);
     arp_debug.debug('p_exchange_rate_type = '||p_exchange_rate_type);
     arp_debug.debug('p_exchange_rate_date = '||p_exchange_rate_date);
     arp_debug.debug('p_exchange_rate = '||p_exchange_rate);
     arp_debug.debug('p_customer_trx_id = '||p_customer_trx_id);
     arp_debug.debug('p_invoice_ps_id = '||p_invoice_ps_id);
     arp_debug.debug('p_cust_trx_type_id = '||p_cust_trx_type_id);
     arp_debug.debug('p_trx_number = '||p_trx_number);
     arp_debug.debug('p_cust_account_id = '||p_cust_account_id);
     arp_debug.debug('p_bill_to_site_id = '||p_bill_to_site_id);
     arp_debug.debug('p_ship_to_site_id = '||p_ship_to_site_id);
     arp_debug.debug('p_salesrep_id = '||p_salesrep_id);
     arp_debug.debug('p_customer_ref_date = '||p_customer_ref_date);
     arp_debug.debug('p_customer_ref_number = '||p_customer_ref_number);
     arp_debug.debug('p_cash_receipt_id = '||p_cash_receipt_id);
     arp_debug.debug('p_receipt_number = '||p_receipt_number);
     arp_debug.debug('p_reason_id = '||p_reason_id);
     arp_debug.debug('p_customer_reason = '||p_customer_reason);
  END IF;

  OZF_Claim_GRP.Create_Deduction
             (p_api_version_number   => 1.0
             ,p_init_msg_list        => FND_API.G_TRUE
             ,p_commit               => FND_API.G_FALSE
             ,x_return_status        => l_return_status
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data
             ,p_deduction            => l_claim_rec
             ,x_claim_id             => x_claim_id
             ,x_claim_number         => x_claim_number
             ,x_claim_reason_code_id => l_claim_reason_code_id
             ,x_claim_reason_name    => x_claim_reason_name );
  IF l_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    x_return_status := 'S';
    IF p_customer_trx_id IS NOT NULL and  p_customer_trx_id > 0
    THEN
      insert_trx_note(p_customer_trx_id
                     ,p_receipt_number
                     ,x_claim_number
                     ,'CREATE');
      put_trx_in_dispute(p_invoice_ps_id
                        ,p_amount
                        ,'Y');
    END IF;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR
  THEN
    x_return_status := 'E';
  ELSE
    x_return_status := 'U';
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug(   'arp_process_application.create_claim()-' );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_debug.debug(
       'EXCEPTION: arp_process_application.create_claim' );
      END IF;
      RAISE;
END create_claim;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_claim                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Calls iClaim group API to update a deduction claim.                    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED -                                 |
 |      OZF_Claim_GRP.Update_Deduction - Group API to update a claim from AR |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   jbeckett    02-MAY-2001  Created                                        |
 |   apandit     04-JUN-2001  added parameter p_invoice_ps_id. Bug 1812328   |
 |   apandit     05-JUN-2001  added parameters p_claim_number and            |
 |                            p_customer_trx_id. Bug 1812334                 |
 |   jbeckett    07-FEB-2003  Bug 2751910 - no longer do we actually cancel  |
 |                            the claim, we just set the amount to 0 and set |
 |                            active_claim flag to 'C' on payment schedule if|
 |                            invoice related.                               |
 |                            REnamed from cancel_claim to reflect change.   |
 |                                                                           |
 +===========================================================================*/
PROCEDURE update_claim(
              p_claim_id             IN  OUT NOCOPY NUMBER
            , p_invoice_ps_id        IN  NUMBER
            , p_customer_trx_id      IN  NUMBER
            , p_amount               IN  NUMBER
            , p_amount_applied       IN  NUMBER
            , p_apply_date           IN  DATE
            , p_cash_receipt_id      IN  NUMBER
            , p_receipt_number       IN  VARCHAR2
            , p_action_type          IN  VARCHAR2
            , x_claim_reason_code_id OUT NOCOPY NUMBER
            , x_claim_reason_name    OUT NOCOPY VARCHAR2
            , x_claim_number         OUT NOCOPY VARCHAR2
            , x_return_status        OUT NOCOPY VARCHAR2
            , x_msg_count            OUT NOCOPY NUMBER
            , x_msg_data             OUT NOCOPY VARCHAR2
            , p_reason_id            IN  NUMBER  DEFAULT NULL)--Yao Zhang add for bug 10197191
IS

  l_claim_rec                  OZF_Claim_GRP.Deduction_Rec_Type;
  l_receipt_number             ar_cash_receipts.receipt_number%TYPE;
  l_return_status              VARCHAR2(1);
  l_object_version_number      NUMBER;
  l_claim_number               VARCHAR2(30);
  l_amount_from_dispute        NUMBER;
  l_active_claim_flag          ar_payment_schedules.active_claim_flag%TYPE;
  l_amount_due_original        NUMBER;

/* Bug 10178153, manishri */
  l_nc_app_amt		          NUMBER := 0;
  l_c_app_amt		          NUMBER := 0;
  l_amt_in_dispute		  NUMBER := 0;
  l_claim_flag			  ar_payment_schedules.active_claim_flag%TYPE := 'I';
  l_amt_applied			  NUMBER;
	 cursor c_ra_app_id (p_cust_trx_id varchar2) is
	 select receivable_application_id ra_app_id,
			amount_applied ,
			application_ref_type app_ref_type
	 from   ar_receivable_applications
	 WHERE  applied_customer_trx_id =p_cust_trx_id
	 order by receivable_application_id;
/* End of change, Bug10178153, manishri */

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug(   'arp_process_application.update_claim()+' );
  END IF;

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_claim_id IS NOT NULL THEN
    l_claim_rec.claim_id := p_claim_id;
  ELSE
    l_claim_rec.claim_id := NULL;
  END IF;
  l_claim_rec.amount := p_amount;
  l_claim_rec.applied_date := p_apply_date;
  l_claim_rec.amount_applied := p_amount_applied;
  l_claim_rec.applied_action_type := p_action_type;
  l_claim_rec.receipt_id := p_cash_receipt_id;
  l_claim_rec.applied_receipt_id := p_cash_receipt_id;
  l_claim_rec.reason_code_id := p_reason_id;--Yao Zhang added for bug 10197191
  IF p_receipt_number IS NULL
  THEN
    SELECT receipt_number INTO l_receipt_number
    FROM   ar_cash_receipts
    WHERE  cash_receipt_id = p_cash_receipt_id;
  ELSE
    l_receipt_number := p_receipt_number;
  END IF;
  l_claim_rec.receipt_number := l_receipt_number;
  l_claim_rec.applied_receipt_number := l_receipt_number;

  IF (p_customer_trx_id IS NOT NULL and p_customer_trx_id > 0)
  THEN
    l_claim_rec.source_object_id := p_customer_trx_id;
    l_claim_rec.source_object_class := 'INVOICE';
    SELECT amount_due_original
    INTO   l_amount_due_original
    FROM   ar_payment_schedules
    WHERE  payment_schedule_id = p_invoice_ps_id;
  ELSE
    l_claim_rec.source_object_id := NULL;
    l_claim_rec.source_object_class := NULL;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
  --dump the in parameters
     arp_debug.debug('update_claim: p_claim_id = '||p_claim_id);
     arp_debug.debug('update_claim: p_amount = '||p_amount);
     arp_debug.debug('update_claim: p_apply_date = '||p_apply_date);
     arp_debug.debug('update_claim: p_amount_applied = '||p_amount_applied);
     arp_debug.debug('update_claim: p_action_type = '||p_action_type);
     arp_debug.debug('update_claim: p_cash_receipt_id = '||p_cash_receipt_id);
     arp_debug.debug('update_claim: p_customer_trx_id = '||p_customer_trx_id);
     arp_debug.debug('update_claim: l_receipt_number = '||l_receipt_number);
     arp_debug.debug('update_claim: l_reason_id = '||p_reason_id);
     arp_debug.debug('update_claim: l_reason_id in p_deduction= '||l_claim_rec.reason_code_id);
  END IF;

  OZF_Claim_GRP.Update_Deduction
             (p_api_version_number    => 1.0
             ,p_init_msg_list         => FND_API.G_TRUE
             ,p_commit                => FND_API.G_FALSE
             ,x_return_status         => l_return_status
             ,x_msg_count             => x_msg_count
             ,x_msg_data              => x_msg_data
             ,p_deduction             => l_claim_rec
             ,x_object_version_number => l_object_version_number
             ,x_claim_reason_code_id  => x_claim_reason_code_id
             ,x_claim_reason_name     => x_claim_reason_name
             ,x_claim_id              => p_claim_id
             ,x_claim_number          => x_claim_number );

  IF l_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    x_return_status := 'S';

    --Bug 1812328 : added the call to remove_dispute_on_trx().
  --Bug 1812334 : added the call to insert_trx_note().
    IF (p_invoice_ps_id IS NOT NULL and  p_customer_trx_id > 0)
    THEN

      insert_trx_note(p_customer_trx_id
                     ,NULL
                     ,x_claim_number
                     ,'CANCEL');
/* Bug 10178153, manishri */
/*
      IF p_action_type = 'A'
      THEN
        l_amount_from_dispute := p_amount_applied;
      ELSE
        l_amount_from_dispute := p_amount_applied * -1;
      END IF;

      IF (p_amount = 0 OR p_amount = l_amount_due_original)
      THEN
        l_active_claim_flag := 'C';
      ELSE
        l_active_claim_flag := 'Y';
      END IF;

      update_dispute_on_trx(p_invoice_ps_id
                          , l_active_claim_flag
                          , l_amount_from_dispute);
*/

	for i_ra_app_id in c_ra_app_id(p_customer_trx_id)
	loop
	   if (i_ra_app_id.app_ref_type ='CLAIM') then
		l_claim_flag :='A';  /* Active Claim */
	   end if;

	   if (l_claim_flag ='A')  then
		l_c_app_amt  := l_c_app_amt  + i_ra_app_id.amount_applied ; /* amount applied after any claim application */
	   else
		l_nc_app_amt := l_nc_app_amt + i_ra_app_id.amount_applied ; /* amount applied when there is no claim application */
	   end if;

	   if (l_c_app_amt <=0) then
	      l_claim_flag :='I'; /* InActive Claim */
	   end if;

           IF PG_DEBUG in ('Y', 'C') THEN
              arp_debug.debug('l_claim_flag    ='||l_claim_flag);
	      arp_debug.debug('i_ra_app_id.amount_applied   '||i_ra_app_id.amount_applied);
	   END IF;
	end loop;

	if (l_claim_flag ='A' or p_claim_id is not null) then

	   IF p_action_type = 'A'  THEN
	      l_amt_applied := p_amount_applied;
	   ELSE
	      l_amt_applied := p_amount_applied * -1;
	   END IF;

	   l_claim_flag :='A'; /* Make Claim active if claim id is not null */
	   l_amt_in_dispute := l_amount_due_original - l_c_app_amt - l_nc_app_amt -l_amt_applied;

	   if ( (l_amt_in_dispute = l_amount_due_original) OR (l_c_app_amt + l_amt_applied =0)  ) THEN
	     l_claim_flag :='I';
	     l_amt_in_dispute :=0;
	   end if;
	end if;

	IF PG_DEBUG in ('Y', 'C') THEN
	   arp_debug.debug('update_claim: l_amount_due_original = '||l_amount_due_original);
	   arp_debug.debug('update_claim: l_c_app_amt = '||l_c_app_amt);
	   arp_debug.debug('update_claim: l_nc_app_amt = '||l_nc_app_amt);
	END IF;

        update_dispute_on_trx(p_invoice_ps_id
	  		      , l_claim_flag
			      , l_amt_in_dispute);

/* End of change, Bug 10178153, manishri */

    END IF;

  ELSIF l_return_status = FND_API.G_RET_STS_ERROR
  THEN
    x_return_status := 'E';
  ELSE
    x_return_status := 'U';
  END IF;

  IF PG_DEBUG in ('Y', 'C') AND l_return_status <> FND_API.G_RET_STS_SUCCESS
   THEN
     arp_debug.debug(   'arp_process_application.update_claim: ERROR occurred calling update_deduction: '||SQLERRM );
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug(   'arp_process_application.update_claim()-' );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_debug.debug(
       'EXCEPTION: arp_process_application.update_claim' );
      END IF;
      RAISE;
END update_claim;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_trx_note                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Calls arp_notes_pkg to insert a note into AR_NOTES for a given         |
 |    transaction                                                            |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED -                                 |
 |      arp_notes_pkg.insert_cover                                           |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   jbeckett    03-MAY-2001  Created                                        |
 |   apandit     05-JUN-2001  added parameter p_flag. Bug 1812334            |
 |                                                                           |
 +===========================================================================*/
PROCEDURE insert_trx_note(
              p_customer_trx_id             IN  NUMBER
            , p_receipt_number              IN  VARCHAR2
            , p_claim_number                IN  VARCHAR2
            , p_flag                        IN  VARCHAR2)
IS
  l_text                    VARCHAR2(2000);
  l_user_id                 NUMBER;
  l_last_update_login       NUMBER;
  l_sysdate                 DATE;
  l_note_id                 NUMBER;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug(   'arp_process_application.insert_trx_note()+' );
  END IF;
 --Bug 1812334 : ar_notes entry needs to be created also when the claim is cancelled.

 IF p_flag = 'CREATE'  THEN
   fnd_message.set_name('AR', 'AR_RW_APP_TRX_CLAIM_NOTE');
   fnd_message.set_token('RECEIPT_NUM',p_receipt_number);
   fnd_message.set_token('CLAIM_NUM',p_claim_number);
 ELSIF p_flag = 'CANCEL' THEN
   fnd_message.set_name('AR', 'AR_RW_APP_TRX_CLAIM_CANCL_NOTE');
   fnd_message.set_token('CLAIM_NUM',p_claim_number);
 END IF;

  /* bug 3161148, need to pass only 240 characters as that is the
     limit on the column in the table.  */
  l_text := substrb(fnd_message.get,1,240);

  l_user_id := arp_standard.profile.user_id;
  l_last_update_login := arp_standard.profile.last_update_login;
  l_sysdate := SYSDATE;
  arp_notes_pkg.insert_cover(
        p_note_type              => 'MAINTAIN',
        p_text                   => l_text,
        p_customer_call_id       => NULL,
        p_customer_call_topic_id => NULL,
        p_call_action_id         => NULL,
        p_customer_trx_id        => p_customer_trx_id,
        p_note_id                => l_note_id,
        p_last_updated_by        => l_user_id,
        p_last_update_date       => l_sysdate,
        p_last_update_login      => l_last_update_login,
        p_created_by             => l_user_id,
        p_creation_date          => l_sysdate);
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug(   'arp_process_application.insert_trx_note()-' );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(  'EXCEPTION: arp_process_application.insert_trx_note' );
    END IF;
    RAISE;
END insert_trx_note;

--Bug 1812328 : modified the parameter p_customer_trx_id to p_invoice_ps_id.
PROCEDURE put_trx_in_dispute(
              p_invoice_ps_id               IN  NUMBER
            , p_dispute_amount              IN  NUMBER
            , p_active_claim                IN VARCHAR2)
IS
  l_last_update_login       NUMBER;
  l_user_id                 NUMBER;

  /*added for the bug 2641517 */
   l_term_changed_flag           VARCHAR2(1);
   l_trx_sum_hist_rec            AR_TRX_SUMMARY_HIST%rowtype;
   l_history_id                  NUMBER;
   l_trx_class                   varchar2(30);
   l_trx_dispute_date            DATE;
   l_new_dispute_amount          NUMBER;
   l_sysdate                     DATE;
   CURSOR get_existing_ps (p_ps_id IN NUMBER) IS
   SELECT payment_schedule_id,
          invoice_currency_code,
          due_date,
          amount_in_dispute,
          amount_due_original,
          amount_due_remaining,
          amount_adjusted,
          customer_trx_id,
          customer_id,
          customer_site_use_id,
          class,
          trx_date,
          dispute_date
   FROM   ar_payment_schedules
   WHERE  payment_schedule_id = p_ps_id;
BEGIN
IF PG_DEBUG in ('Y', 'C') THEN
   arp_debug.debug(   'arp_process_application.put_trx_in_dispute()+' );
END IF;
  l_user_id := arp_standard.profile.user_id;
  l_last_update_login := arp_standard.profile.last_update_login;
  l_sysdate := SYSDATE;

   /*bug 2641517 : creating history record for business event */
   OPEN get_existing_ps(p_invoice_ps_id);

       FETCH get_existing_ps INTO
             l_trx_sum_hist_rec.payment_schedule_id,
             l_trx_sum_hist_rec.currency_code,
             l_trx_sum_hist_rec.due_date,
             l_trx_sum_hist_rec.amount_in_dispute,
             l_trx_sum_hist_rec.amount_due_original,
             l_trx_sum_hist_rec.amount_due_remaining,
             l_trx_sum_hist_rec.amount_adjusted,
             l_trx_sum_hist_rec.customer_trx_id,
             l_trx_sum_hist_rec.customer_id,
             l_trx_sum_hist_rec.site_use_id,
             l_trx_class,
             l_trx_sum_hist_rec.trx_date,
             l_trx_dispute_date;


             AR_BUS_EVENT_COVER.p_insert_trx_sum_hist(l_trx_sum_hist_rec,
                                                      l_history_id,
                                                      l_trx_class,
                                                      'MODIFY_TRX');
            /* Bug 5129946*/
            IF get_existing_ps%ROWCOUNT>0 THEN
            l_new_dispute_amount := nvl(l_trx_sum_hist_rec.amount_in_dispute, 0) + p_dispute_amount;

            if(l_new_dispute_amount <> l_trx_sum_hist_rec.amount_in_dispute)
            OR (l_new_dispute_amount IS NULL and l_trx_sum_hist_rec.amount_in_dispute IS NOT NULL)
            OR (l_new_dispute_amount IS  NOT NULL and l_trx_sum_hist_rec.amount_in_dispute IS  NULL)
            THEN
            arp_dispute_history.DisputeHistory(  p_DisputeDate => l_sysdate,
                                                 p_OldDisputeDate => l_trx_dispute_date,
                                                 p_PaymentScheduleId => l_trx_sum_hist_rec.payment_schedule_id,
                                                 p_OldPaymentScheduleId =>l_trx_sum_hist_rec.payment_schedule_id,
                                                 p_AmountDueRemaining  => l_trx_sum_hist_rec.amount_due_remaining,
                                                 p_AmountInDispute => l_new_dispute_amount,
                                                 p_OldAmountInDispute => l_trx_sum_hist_rec.amount_in_dispute,
                                                 p_CreatedBy =>l_user_id,
                                                 p_CreationDate => l_sysdate,
                                                 p_LastUpdatedBy =>l_user_id,
                                                 p_LastUpdateDate => l_sysdate,
                                                 p_lastUpdateLogin => l_last_update_login);
           END IF;--if(l_new_dispute_amount <>....
           END IF;--IF get_existing_ps%ROWCOUNT>0 THEN
   CLOSE get_existing_ps;

  UPDATE ar_payment_schedules ps
  SET    ps.amount_in_dispute = nvl(ps.amount_in_dispute,0) + p_dispute_amount,
         ps.dispute_date      = SYSDATE,
         last_updated_by      = l_user_id,
         last_update_login    = l_last_update_login,
         active_claim_flag    = p_active_claim
  WHERE  ps.payment_schedule_id = p_invoice_ps_id;

     /*bug 2641517 - raise business event */
       AR_BUS_EVENT_COVER.Raise_Trx_Modify_Event
                                             (p_invoice_ps_id,
                                              l_trx_class,
                                              l_history_id);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug(   'arp_process_application.put_trx_in_dispute()-' );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(  'EXCEPTION: arp_process_application.put_trx_in_dispute');
    END IF;
    RAISE;
END put_trx_in_dispute;

--Bug 1812328 : added routine remove_dispute_on_trx
--Bug 2751910 : renamed to update_dispute_on_trx
PROCEDURE update_dispute_on_trx(
              p_invoice_ps_id               IN  NUMBER
             ,p_active_claim                IN  VARCHAR2
             ,p_amount                      IN  NUMBER )
IS
  l_last_update_login       NUMBER;
  l_user_id                 NUMBER;
  /* Added 6 variables and cursor get_existing_ps for bug 5129946*/
  l_old_dispute_date        DATE;
  l_old_dispute_amount      NUMBER;
  l_amount_due_remaining    NUMBER;
  l_ps_id                   NUMBER;
  l_new_dispute_amount      NUMBER;
  l_sysdate                 DATE;
  CURSOR get_existing_ps (p_ps_id IN NUMBER) IS
   SELECT payment_schedule_id,
          amount_in_dispute,
          amount_due_remaining,
          dispute_date
   FROM   ar_payment_schedules
   WHERE  payment_schedule_id = p_ps_id;
BEGIN
  l_user_id := arp_standard.profile.user_id;
  l_last_update_login := arp_standard.profile.last_update_login;
  l_sysdate := SYSDATE;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug(   'arp_process_application.update_dispute_on_trx()+' );
  END IF;
  /*Bug 5129946: Calling arp_dispute_history.DisputeHistory*/
  OPEN get_existing_ps(p_invoice_ps_id);
    FETCH get_existing_ps INTO
          l_ps_id,
          l_old_dispute_amount,
          l_amount_due_remaining,
          l_old_dispute_date;
    IF get_existing_ps%ROWCOUNT>0 THEN
    if(l_old_dispute_amount = p_amount) THEN
    l_new_dispute_amount := NULL;
    ELSE
    l_new_dispute_amount := (l_old_dispute_amount-p_amount);
    END IF;
    if(l_new_dispute_amount <> l_old_dispute_amount)
            OR (l_new_dispute_amount IS NULL and l_old_dispute_amount IS NOT NULL)
            OR (l_new_dispute_amount IS  NOT NULL and l_old_dispute_amount IS  NULL)
            THEN
            arp_dispute_history.DisputeHistory(p_DisputeDate => l_sysdate,
                                               p_OldDisputeDate => l_old_dispute_date,
                                               p_PaymentScheduleId => l_ps_id,
                                               p_OldPaymentScheduleId => l_ps_id,
                                               p_AmountDueRemaining => l_amount_due_remaining,
                                               p_AmountInDispute =>l_new_dispute_amount,
                                               p_OldAmountInDispute =>l_old_dispute_amount,
                                               p_CreatedBy => l_user_id,
                                               p_CreationDate => l_sysdate,
                                               p_LastUpdatedBy => l_user_id,
                                               p_LastUpdateDate => l_sysdate,
                                               p_lastUpdateLogin =>l_last_update_login);
           END IF;--if(l_new_dispute_amount <> l_old_dispute_amount)
      END IF;--IF get_existing_ps%ROWCOUNT>0 THEN
   CLOSE get_existing_ps;

/* Bug 10178153, manishri */
   IF (p_active_claim in ('A','I')) THEN
	  UPDATE ar_payment_schedules ps
	  SET    ps.amount_in_dispute = p_amount,
			 ps.dispute_date      = SYSDATE,
			 last_updated_by      = l_user_id,
			 last_update_login    = l_last_update_login,
			 active_claim_flag    = decode(p_active_claim,'A','Y','C')
	  WHERE  ps.payment_schedule_id  = p_invoice_ps_id;
   ELSE
	  UPDATE ar_payment_schedules ps
	  SET    ps.amount_in_dispute = DECODE(ps.amount_in_dispute, p_amount, NULL
								   , (ps.amount_in_dispute-p_amount)),
			 ps.dispute_date      = SYSDATE,
			 last_updated_by      = l_user_id,
			 last_update_login    = l_last_update_login,
			 active_claim_flag    = p_active_claim
	  WHERE  ps.payment_schedule_id  = p_invoice_ps_id;
   END IF;
/* End of change, Bug 10178153, manishri */

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug(   'arp_process_application.update_dispute_on_trx()-' );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(  'EXCEPTION: arp_process_application.update_dispute_on_trx');
    END IF;
    RAISE;
END update_dispute_on_trx;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    reverse_action_receipt_cb                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Reverses  chargebacks associated with an receipt CB application.       |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED -                                 |
 |      arp_process_chargeback.reverse_chargeback - Procedure to reverse     |
 |                                                   a chargeback            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_chargeback_customer_trx_id - chargeback customer trx id |
 |                 p_reversal_gl_date - Reversal GL date                     |
 |      	   p_module_name  - Name of the module that called this      |
 |				    procedure   			     |
 |      	   p_module_version  - Version of the module that called this|
 |			            procedure                                |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY - Created by S.Nambiar     26-APR-01                 |
 |                                                                           |
 +===========================================================================*/
PROCEDURE reverse_action_receipt_cb(
	p_chargeback_customer_trx_id
               IN ar_receivable_applications.application_ref_id%TYPE,
	p_reversal_gl_date IN DATE,
        p_reversal_date IN DATE,
	p_module_name IN VARCHAR2,
	p_module_version IN VARCHAR2 ) IS
--
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_process_application.reverse_action_receipt_cb()+' );
    END IF;
    --
    -- reverse chargeback
    -- For receipt chargeback,there is no adjustment associated with it
    arp_process_chargeback.reverse_chargeback(
		             p_chargeback_customer_trx_id,
		             p_reversal_gl_date,
                             p_reversal_date,
		             p_module_name,
                             p_module_version );

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_process_application.reverse_action_receipt_cb()-' );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug(
		         'EXCEPTION: arp_process_application.reverse_action_receipt_cb' );
              END IF;
              RAISE;
END reverse_action_receipt_cb;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    reverse_action_misc_receipt                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Reverses  Misc Receipt associated with an Credit Card refund app       |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED -                                 |
 |      arp_receipt_api_pub.reverse - Procedure to reverse                   |
 |                                                   a receipt               |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_cash_receipt_id - Misc receipt cash receipt id          |
 |                 p_reversal_gl_date - Reversal GL date                     |
 |      	   p_module_name  - Name of the module that called this          |
 |				    procedure   			                                 |
 |      	   p_module_version  - Version of the module that called this    |
 |			            procedure                                            |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ramakant Alat           18-JUN-01       |
 |                                                                           |
 +===========================================================================*/
PROCEDURE reverse_action_misc_receipt(
	p_cash_receipt_id IN ar_receivable_applications.application_ref_id%TYPE,
	p_reversal_gl_date IN DATE,
    p_reversal_date IN DATE,
	p_reversal_comments IN VARCHAR2 DEFAULT NULL,
	p_called_from IN VARCHAR2  DEFAULT NULL) IS
--
l_return_status            VARCHAR2(1);
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000);
l_msg_index                NUMBER;
API_exception              EXCEPTION;
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_debug.debug( 'arp_process_application.reverse_action_misc_receipt()+' );
   END IF;
   --
   -- reverse Misc Receipt

   AR_RECEIPT_API_PUB.Reverse(
				     p_api_version           => 1.0,
					 p_init_msg_list          => FND_API.G_TRUE,
					 x_return_status          => l_return_status,
					 x_msg_count              => l_msg_count,
					 x_msg_data               => l_msg_data,
					 p_cash_receipt_id        => p_cash_receipt_id,
                     p_reversal_reason_code   =>'CC REFUND CHANGE',
                     p_reversal_comments      => p_reversal_comments,
                     p_reversal_category_code =>'CCRR',
					 p_reversal_gl_date       => p_reversal_gl_date,
					 p_reversal_date          => p_reversal_date,
					 p_called_from            => 'UNAPPLY_CCR');

   /*------------------------------------------------+
    | Write API output to the concurrent program log |
	+------------------------------------------------*/
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_debug.debug(  'API error count '||to_char(NVL(l_msg_count,0)));
   END IF;

   IF NVL(l_msg_count,0)  > 0 Then

	  IF l_msg_count  = 1 Then

	     /*------------------------------------------------+
	      | There is one message returned by the API, so it|
	      | has been sent out NOCOPY in the parameter x_msg_data  |
	      +------------------------------------------------*/
		 IF PG_DEBUG in ('Y', 'C') THEN
		    arp_debug.debug(  l_msg_data);
		 END IF;

      ELSIF l_msg_count > 1 Then

		 /*-------------------------------------------------------+
		  | There are more than one messages returned by the API, |
		  | so call them in a loop and print the messages         |
		  +-------------------------------------------------------*/

	     FOR l_count IN 1..l_msg_count LOOP

			l_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,
							              FND_API.G_FALSE);
			IF PG_DEBUG in ('Y', 'C') THEN
			   arp_debug.debug(  to_char(l_count)||' : '||l_msg_data);
			END IF;

		 END LOOP;

	  END IF; -- l_msg_count

   END IF; -- NVL(l_msg_count,0)

   /*-----------------------------------------------------+
    | If API return status is not SUCCESS raise exception |
    +-----------------------------------------------------*/
   IF l_return_status = FND_API.G_RET_STS_SUCCESS Then

      /*-----------------------------------------------------+
	   | Success do nothing, else branch introduced to make  |
	   | sure that NULL case will also raise exception       |
	   +-----------------------------------------------------*/
	  NULL;

   ELSE
	  /*---------------------------+
	   | Error, raise an exception |
	   +---------------------------*/
      RAISE API_exception;

   END IF; -- l_return_status

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_debug.debug( 'arp_process_application.reverse_action_misc_receipt()-' );
   END IF;
   /*----------------------------------+
	| APIs propagate exception upwards |
	+----------------------------------*/
EXCEPTION
   WHEN API_exception THEN
	  IF PG_DEBUG in ('Y', 'C') THEN
	     arp_debug.debug(  'API EXCEPTION: ' ||
		             'arp_process_application.reverse_action_misc_receipt'
					 ||SQLERRM);
	  END IF;
	  FND_MSG_PUB.Get (FND_MSG_PUB.G_FIRST, FND_API.G_TRUE,
					   l_msg_data, l_msg_index);
	  FND_MESSAGE.Set_Encoded (l_msg_data);
	  app_exception.raise_exception;

   WHEN OTHERS THEN
	  IF PG_DEBUG in ('Y', 'C') THEN
	     arp_debug.debug('EXCEPTION: arp_process_application.reverse_action_misc_receipt'
					 ||SQLERRM);
	  END IF;
      RAISE;
   END reverse_action_misc_receipt;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_claim_status                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Retreives  claim status from Trade Management via dynamic sql          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED -                                 |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_claim_id - trade mgmt claim id                          |
 |              OUT:                                                         |
 |                 x_claim_status - trade mgmt claim status code             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 | jbeckett 25-MAR-02 Created - bug 2232366                                  |
 |                                                                           |
 +===========================================================================*/
PROCEDURE get_claim_status(
	p_claim_id IN     NUMBER,
        x_claim_status    OUT NOCOPY VARCHAR2)
IS
  l_query_string          VARCHAR2(2000);

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug( 'arp_process_application.get_claim_status()+' );
  END IF;
  l_query_string :=
   ' select status_code from ozf_ar_deductions_v where claim_id = :claim_id ';
  BEGIN
    EXECUTE IMMEDIATE l_query_string
    INTO    x_claim_status
    USING   p_claim_id;
  EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.set_name('AR','AR_RW_INVALID_CLAIM_ID');
        FND_MESSAGE.set_token('CLAIM_ID',p_claim_id);
        APP_EXCEPTION.raise_exception;
  END;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug( 'arp_process_application.get_claim_status()-' );
  END IF;
END get_claim_status;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    cm_activity_application                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Activity applications against a credit memo                            |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED -                                 |
 |                                                                           |
 |         ARPCURR.functional_amount - Get the acctd amount of amount applied|
 |         arp_ps_pkg.fetch_p - Fetch a PS row                               |
 |         arp_app_pkg.insert_p - Insert a row into RA table                 |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_cm_ps_id - PS id of the receipt                         |
 |                 p_application_ps_id - PS id of the special application    |
 |                 p_amount_applied - Input amount applied                   |
 |                 p_apply_date - Application date                           |
 |                 p_gl_date    - Gl Date                                    |
 |                 p_ussgl_transaction_code - USSGL transaction code         |
 |                 p_receivables_trx_id  -Activity id                        |
 |		   p_receipt_method_id - payment method for misc receipt     |
 |                 OTHER DESCRIPTIVE FLEX columns                            |
 |                 p_module_name  - Name of the module that called this      |
 |                                  procedure                                |
 |                 p_module_version  - Version of the module that called this|
 |                                  procedure                                |
 |              OUT:                                                         |
 |		   p_out_rec_application_id                                  |
 |				Returned receivable application id           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 | jbeckett 10-JAN-05   Created for credit memo refunds.                     |
 |           		                                                     |
 +===========================================================================*/
PROCEDURE cm_activity_application(
	p_cm_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
	p_application_ps_id	IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_amount_applied IN ar_receivable_applications.amount_applied%TYPE,
        p_apply_date IN ar_receivable_applications.apply_date%TYPE,
	p_gl_date IN ar_receivable_applications.gl_date%TYPE,
	p_ussgl_transaction_code IN ar_receivable_applications.ussgl_transaction_code%TYPE,
	p_attribute_category IN ar_receivable_applications.attribute_category%TYPE,
	p_attribute1 IN ar_receivable_applications.attribute1%TYPE,
	p_attribute2 IN ar_receivable_applications.attribute2%TYPE,
	p_attribute3 IN ar_receivable_applications.attribute3%TYPE,
	p_attribute4 IN ar_receivable_applications.attribute4%TYPE,
	p_attribute5 IN ar_receivable_applications.attribute5%TYPE,
	p_attribute6 IN ar_receivable_applications.attribute6%TYPE,
	p_attribute7 IN ar_receivable_applications.attribute7%TYPE,
	p_attribute8 IN ar_receivable_applications.attribute8%TYPE,
	p_attribute9 IN ar_receivable_applications.attribute9%TYPE,
	p_attribute10 IN ar_receivable_applications.attribute10%TYPE,
	p_attribute11 IN ar_receivable_applications.attribute11%TYPE,
	p_attribute12 IN ar_receivable_applications.attribute12%TYPE,
	p_attribute13 IN ar_receivable_applications.attribute13%TYPE,
	p_attribute14 IN ar_receivable_applications.attribute14%TYPE,
	p_attribute15 IN ar_receivable_applications.attribute15%TYPE,
        p_global_attribute_category IN ar_receivable_applications.global_attribute_category%TYPE,
        p_global_attribute1 IN ar_receivable_applications.global_attribute1%TYPE,
        p_global_attribute2 IN ar_receivable_applications.global_attribute2%TYPE,
        p_global_attribute3 IN ar_receivable_applications.global_attribute3%TYPE,
        p_global_attribute4 IN ar_receivable_applications.global_attribute4%TYPE,
        p_global_attribute5 IN ar_receivable_applications.global_attribute5%TYPE,
        p_global_attribute6 IN ar_receivable_applications.global_attribute6%TYPE,
        p_global_attribute7 IN ar_receivable_applications.global_attribute7%TYPE,
        p_global_attribute8 IN ar_receivable_applications.global_attribute8%TYPE,
        p_global_attribute9 IN ar_receivable_applications.global_attribute9%TYPE,
        p_global_attribute10 IN ar_receivable_applications.global_attribute10%TYPE,
        p_global_attribute11 IN ar_receivable_applications.global_attribute11%TYPE,
        p_global_attribute12 IN ar_receivable_applications.global_attribute12%TYPE,
        p_global_attribute13 IN ar_receivable_applications.global_attribute13%TYPE,
        p_global_attribute14 IN ar_receivable_applications.global_attribute14%TYPE,
        p_global_attribute15 IN ar_receivable_applications.global_attribute15%TYPE,
        p_global_attribute16 IN ar_receivable_applications.global_attribute16%TYPE,
        p_global_attribute17 IN ar_receivable_applications.global_attribute17%TYPE,
        p_global_attribute18 IN ar_receivable_applications.global_attribute18%TYPE,
        p_global_attribute19 IN ar_receivable_applications.global_attribute19%TYPE,
        p_global_attribute20 IN ar_receivable_applications.global_attribute20%TYPE,
	p_receivables_trx_id IN ar_receivable_applications.receivables_trx_id%TYPE,
	p_receipt_method_id IN ar_receipt_methods.receipt_method_id%TYPE,
        p_comments IN ar_receivable_applications.comments%TYPE ,
        p_module_name IN VARCHAR2,
        p_module_version IN VARCHAR2,
        p_application_ref_id IN OUT NOCOPY ar_receivable_applications.application_ref_id%TYPE,
        p_application_ref_num IN OUT NOCOPY ar_receivable_applications.application_ref_num%TYPE,
        -- OUT NOCOPY
        p_out_rec_application_id OUT NOCOPY NUMBER,
        p_acctd_amount_applied_from OUT NOCOPY ar_receivable_applications.acctd_amount_applied_from%TYPE,
        p_acctd_amount_applied_to OUT NOCOPY ar_receivable_applications.acctd_amount_applied_to%TYPE,
	x_return_status     OUT NOCOPY VARCHAR2,
	x_msg_count         OUT NOCOPY NUMBER,
	x_msg_data          OUT NOCOPY VARCHAR2) IS

l_inv_ra_rec     ar_receivable_applications%ROWTYPE;
l_cm_ps_rec      ar_payment_schedules%ROWTYPE;
l_ae_doc_rec     ae_doc_rec_type;
   l_source_type                ar_distributions.source_type%TYPE; /* jrautiai BR implementation */
l_flag		 char;
  l_fnd_api_constants_rec     ar_bills_main.fnd_api_constants_type     := ar_bills_main.get_fnd_api_constants_rec;

   l_inv_bal_amount             NUMBER;
   l_inv_orig_amount            NUMBER;
   l_allow_over_application     VARCHAR2(1);
   l_effective_amount_applied   NUMBER;
  l_application_ref_type  ar_receivable_applications.application_ref_type%TYPE;
  l_application_ref_num   ar_receivable_applications.application_ref_num%TYPE;
  l_application_ref_id    ar_receivable_applications.application_ref_id%TYPE;
  l_secondary_application_ref_id ar_receivable_applications.secondary_application_ref_id%TYPE;
  l_attribute_rec             AR_RECEIPT_API_PUB.attribute_rec_type;
  l_global_attribute_rec      AR_RECEIPT_API_PUB.global_attribute_rec_type;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_msg_index                 NUMBER;
  l_exchange_rate             ar_cash_receipts.exchange_rate%TYPE;
  functional_curr             VARCHAR2(100);

  l_line_remaining            ar_payment_schedules.tax_remaining%TYPE:=0;
  l_tax_remaining             ar_payment_schedules.tax_remaining%TYPE:=0;
  l_rec_charges_remaining     ar_payment_schedules.tax_remaining%TYPE:=0;
  l_freight_remaining         ar_payment_schedules.tax_remaining%TYPE:=0;
  l_tax_applied               ar_receivable_applications.tax_applied%TYPE:=0;
  l_freight_applied           ar_receivable_applications.freight_applied%TYPE:=0;
  l_line_applied              ar_receivable_applications.line_applied%TYPE:=0;
  l_charges_applied           ar_receivable_applications.receivables_charges_applied%TYPE:=0;
  l_rule_set_id               number;

  l_receivable_application_id   NUMBER;


  l_rec_ccid ra_cust_trx_line_gl_dist.code_combination_id%type;
  l_activity_ccid ra_cust_trx_line_gl_dist.code_combination_id%type;

  API_exception              EXCEPTION;
  --Bug#2750340
  l_xla_ev_rec      arp_xla_events.xla_events_type;
  l_xla_doc_table   VARCHAR2(20);

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug('arp_process_application.cm_activity_application()+' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Output IN parameters
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug('CM PS Id.               : '||TO_CHAR( p_cm_ps_id ) );
       arp_debug.debug('Amount Applied          : '||TO_CHAR( p_amount_applied ) );
       arp_debug.debug('Gl Date                 : '||TO_CHAR( p_gl_date ) );
       arp_debug.debug('Apply Date              : '||TO_CHAR( p_apply_date ) );
    END IF;

    -----------------------------------------------------

    /* Validate parameters */

    validate_activity_args( p_cm_ps_id, p_application_ps_id,
                            null,p_amount_applied,
                            p_apply_date, p_gl_date,p_receivables_trx_id );

    validate_activity(p_application_ps_id,'CM_REFUND');
    /* Fetch Receipt payment schedule */
    arp_ps_pkg.fetch_p( p_cm_ps_id, l_cm_ps_rec );

    l_inv_ra_rec.application_ref_type := 'AP_REFUND_REQUEST';
    l_inv_ra_rec.application_ref_num := p_application_ref_num;
    l_inv_ra_rec.application_ref_id := p_application_ref_id;
    --------------------------------------------------------------------------
    -- Process the On-Account Credit...
    --
    --------------------------------------------------------------------------
    IF nvl(p_amount_applied,0) <> 0 THEN
      l_rule_set_id := ARP_APP_CALC_PKG.GET_RULE_SET_ID(l_cm_ps_rec.cust_trx_type_id);

      /**always pass the charges as zero and add the corresponding amount to the
         line bucket for proration(if charges exist) */
      l_line_remaining         := l_cm_ps_rec.amount_line_items_remaining +
                                  l_cm_ps_rec.receivables_charges_remaining;
      l_tax_remaining          := l_cm_ps_rec.tax_remaining;
      l_freight_remaining      := l_cm_ps_rec.freight_remaining;
      l_rec_charges_remaining  := 0;

      ARP_APP_CALC_PKG.calc_applied_and_remaining(
	       p_amount_applied
	      ,l_rule_set_id
	      ,l_cm_ps_rec.invoice_currency_code
	      ,l_line_remaining
	      ,l_tax_remaining
	      ,l_freight_remaining
	      ,l_rec_charges_remaining
	      ,l_line_applied
	      ,l_tax_applied
	      ,l_freight_applied
	      ,l_charges_applied );

      l_inv_ra_rec.line_applied                := l_line_applied;
      l_inv_ra_rec.tax_applied                 := l_tax_applied;
      l_inv_ra_rec.freight_applied             := l_freight_applied;
      l_inv_ra_rec.receivables_charges_applied := l_charges_applied;
    END IF;


    -- Get customer_trx_id of CM, from PS table. Pass the selected row
    -- to update_cm_related_columns procedure.
    --
    --
    arp_ps_util.update_cm_related_columns(
                p_cm_ps_id,
                p_amount_applied,
                l_inv_ra_rec.line_applied,
                l_inv_ra_rec.tax_applied,
                l_inv_ra_rec.freight_applied,
                l_inv_ra_rec.receivables_charges_applied,
                p_apply_date,
                p_gl_date,
                l_inv_ra_rec.acctd_amount_applied_from,
                l_cm_ps_rec,
		'Y' );

    select NVL(ctt.post_to_gl,'N') into l_flag
    from   ra_cust_trx_types ctt,
    	   ar_payment_schedules ps
    where  ctt.cust_trx_type_id = ps.cust_trx_type_id
    and    ps.payment_schedule_id = p_cm_ps_id;

    If l_flag = 'Y' then
	l_inv_ra_rec.postable := 'Y';
    else
    	l_inv_ra_rec.postable := 'N';
    End if;

    select code_combination_id INTO l_inv_ra_rec.code_combination_id
    FROM   ar_receivables_trx
    WHERE  receivables_trx_id = p_receivables_trx_id;

     /*Bug 9488876 value for use in BS substitute*/
    l_activity_ccid := l_inv_ra_rec.code_combination_id;

    -- This is passed back to the client as the true acctd amount (calculated
    -- in the payment schedule utility procedure).
    p_acctd_amount_applied_from := l_inv_ra_rec.acctd_amount_applied_from;
    l_inv_ra_rec.acctd_amount_applied_to := l_inv_ra_rec.acctd_amount_applied_from;

    IF p_application_ref_id IS NOT NULL THEN
       BEGIN
          SELECT exchange_rate
          INTO   l_exchange_rate
          FROM   ap_invoices_v
          WHERE  invoice_id = p_application_ref_id;

          functional_curr := arp_global.functional_currency;

          l_inv_ra_rec.acctd_amount_applied_to :=
        	ARPCURR.functional_amount(
		  amount	=> p_amount_applied
                , currency_code	=> functional_curr
                , exchange_rate	=> l_exchange_rate
                , precision	=> NULL
		, min_acc_unit	=> NULL );
       EXCEPTION
           WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug(
		    'EXCEPTION: arp_process_application.cm_activity_application' );
              END IF;
              RAISE;
       END;
    END IF;

    l_inv_ra_rec.customer_trx_id := l_cm_ps_rec.customer_trx_id;
    l_inv_ra_rec.payment_schedule_id := p_cm_ps_id;
    l_inv_ra_rec.applied_payment_schedule_id := p_application_ps_id;
    l_inv_ra_rec.amount_applied := p_amount_applied;
    l_inv_ra_rec.amount_applied_from := p_amount_applied;

    l_inv_ra_rec.status := 'ACTIVITY';
    l_inv_ra_rec.application_type := 'CM';

    l_inv_ra_rec.application_rule := '75';
    l_inv_ra_rec.program_id     := -100105;

    l_inv_ra_rec.apply_date := p_apply_date;
    l_inv_ra_rec.gl_date := p_gl_date;
    l_inv_ra_rec.posting_control_id := -3;
    l_inv_ra_rec.display := 'Y';
    l_inv_ra_rec.ussgl_transaction_code := p_ussgl_transaction_code;
    l_inv_ra_rec.attribute_category := p_attribute_category;
    l_inv_ra_rec.attribute1 := p_attribute1;
    l_inv_ra_rec.attribute2 := p_attribute2;
    l_inv_ra_rec.attribute3 := p_attribute3;
    l_inv_ra_rec.attribute4 := p_attribute4;
    l_inv_ra_rec.attribute5 := p_attribute5;
    l_inv_ra_rec.attribute6 := p_attribute6;
    l_inv_ra_rec.attribute7 := p_attribute7;
    l_inv_ra_rec.attribute8 := p_attribute8;
    l_inv_ra_rec.attribute9 := p_attribute9;
    l_inv_ra_rec.attribute10 := p_attribute10;
    l_inv_ra_rec.attribute11 := p_attribute11;
    l_inv_ra_rec.attribute12 := p_attribute12;
    l_inv_ra_rec.attribute13 := p_attribute13;
    l_inv_ra_rec.attribute14 := p_attribute14;
    l_inv_ra_rec.attribute15 := p_attribute15;
    l_inv_ra_rec.global_attribute_category := p_global_attribute_category;
    l_inv_ra_rec.global_attribute1 := p_global_attribute1;
    l_inv_ra_rec.global_attribute2 := p_global_attribute2;
    l_inv_ra_rec.global_attribute3 := p_global_attribute3;
    l_inv_ra_rec.global_attribute4 := p_global_attribute4;
    l_inv_ra_rec.global_attribute5 := p_global_attribute5;
    l_inv_ra_rec.global_attribute6 := p_global_attribute6;
    l_inv_ra_rec.global_attribute7 := p_global_attribute7;
    l_inv_ra_rec.global_attribute8 := p_global_attribute8;
    l_inv_ra_rec.global_attribute9 := p_global_attribute9;
    l_inv_ra_rec.global_attribute10 := p_global_attribute10;
    l_inv_ra_rec.global_attribute11 := p_global_attribute11;
    l_inv_ra_rec.global_attribute12 := p_global_attribute12;
    l_inv_ra_rec.global_attribute13 := p_global_attribute13;
    l_inv_ra_rec.global_attribute14 := p_global_attribute14;
    l_inv_ra_rec.global_attribute15 := p_global_attribute15;
    l_inv_ra_rec.global_attribute16 := p_global_attribute16;
    l_inv_ra_rec.global_attribute17 := p_global_attribute17;
    l_inv_ra_rec.global_attribute18 := p_global_attribute18;
    l_inv_ra_rec.global_attribute19 := p_global_attribute19;
    l_inv_ra_rec.global_attribute20 := p_global_attribute20;
    l_inv_ra_rec.receivables_trx_id := p_receivables_trx_id;
    l_inv_ra_rec.comments := p_comments;

    /*bug 9488876 substitute BS for refund*/
    IF p_application_ps_id = -8 THEN
      select code_combination_id into l_rec_ccid from ra_Cust_trx_line_gl_dist
      where customer_trx_id=l_cm_ps_rec.customer_trx_id
      and   account_class='REC'
      and   latest_rec_flag='Y';

      IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug('Before BS Substitute:  arp_process_application.cm_activity_application' );
                 arp_debug.debug('Before BS Substitute:  arp_process_application.cm_activity_application CCID REC' || l_rec_ccid );
                 arp_debug.debug('Before BS Substitute:  arp_process_application.cm_activity_application CCID ACTIVITY' || l_activity_ccid );

      END IF;

      IF NVL(FND_PROFILE.value('AR_DISABLE_REC_ACTIVITY_BALSEG_SUBSTITUTION'),'N') = 'N' THEN
          arp_util.Substitute_Ccid(
                             p_coa_id        => arp_global.chart_of_accounts_id,
                             p_original_ccid => l_activity_ccid    ,
                             p_subs_ccid     => l_rec_ccid  ,
                             p_actual_ccid   => l_inv_ra_rec.code_combination_id );
      END IF;
    END IF;


    --------------------------------------------------------------------------
    -- Create the APP row in receivable applications.
    --
    --------------------------------------------------------------------------
    arp_app_pkg.insert_p( l_inv_ra_rec,
                          l_receivable_application_id );

    l_inv_ra_rec.receivable_application_id := l_receivable_application_id;

    IF l_inv_ra_rec.receivable_application_id IS NOT NULL THEN
         l_xla_ev_rec.xla_from_doc_id := l_inv_ra_rec.receivable_application_id;
         l_xla_ev_rec.xla_to_doc_id   := l_inv_ra_rec.receivable_application_id;
         l_xla_ev_rec.xla_mode        := 'O';
         l_xla_ev_rec.xla_call        := 'B';
         l_xla_ev_rec.xla_doc_table := 'CMAPP';
         ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
    END IF;
    -----------------------------------------------------------------------
    -- Process MRC data
    -----------------------------------------------------------------------

--    ar_mrc_engine3.cm_application(
--                     p_cm_ps_id      => p_cm_ps_id,
--                     p_invoice_ps_id => p_application_ps_id,
--                     p_inv_ra_rec    => l_inv_ra_rec,
--                     p_ra_id         => l_inv_ra_rec.receivable_application_id);

    --apandit
    --Bug : 2641517 raise business event.
    AR_BUS_EVENT_COVER.Raise_CM_Apply_Event(l_inv_ra_rec.receivable_application_id);

   --
   --
    l_ae_doc_rec.document_type             := 'CREDIT_MEMO';
    l_ae_doc_rec.document_id               := l_inv_ra_rec.customer_trx_id;
    l_ae_doc_rec.accounting_entity_level   := 'ONE';
    l_ae_doc_rec.source_table              := 'RA';
    l_ae_doc_rec.source_id                 := l_inv_ra_rec.receivable_application_id;
    l_ae_doc_rec.source_id_old             := '';
    l_ae_doc_rec.other_flag                := '';
    l_ae_doc_rec.pay_sched_upd_yn := 'Y';

    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

    -- Return the new receivable_application_id
    p_out_rec_application_id := l_inv_ra_rec.receivable_application_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug('arp_process_application.cm_activity_application()-' );
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug(
		    'EXCEPTION: arp_process_application.cm_activity_application' );
              END IF;
              RAISE;
END cm_activity_application;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Unassociate_Regular_CM                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This routine will take care of clean up associated with unapplying a   |
 |    regular CM (in effect turning it into an on-account CM)                |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED -                                 |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_cust_trx_id- Cust Trx ID of the CM                      |
 |                 p_app_cust_trx_id - cust trx ID of the original TRX       |
 |                              Returned receivable application id           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 | 12-Sep-05    Debbie Sue Jancis    Created                                 |
 |                                                                           |
 +===========================================================================*/
PROCEDURE Unassociate_Regular_CM ( p_cust_Trx_id IN NUMBER,
                               p_app_cust_trx_id IN NUMBER) IS

l_trx_number     ra_customer_trx.trx_number%TYPE;
l_message_text   VARCHAR2(2000);
l_cnt            NUMBER;

x_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
x_msg_count     NUMBER;
x_msg_data      VARCHAR2(2000);
l_count         NUMBER;
l_msg_data      VARCHAR2(1000);
API_EXCEPTION   EXCEPTION;

BEGIN
   arp_debug.debug('arp_process_application.Unapply_Regular_CM()+');

   For rec in (select receivable_application_id source_id from ar_receivable_applications ra
               where customer_trx_id = p_cust_Trx_id
               and applied_customer_trx_id = p_app_cust_trx_id
               and exists (select 'x' from ar_distributions
                           where source_id = ra.receivable_application_id
                           and source_table = 'RA'
                           and ref_customer_trx_line_id is not null
                           and ref_prev_cust_trx_line_id is null)) Loop
      arp_debug.debug('Updating CM ard to stamp ref_prev_cust_trx_line_id');

      update ar_distributions ard
      set ref_prev_cust_trx_line_id = (select previous_customer_trx_line_id
                                       from ra_customer_trx_lines
                                       where customer_trx_line_id = ard.ref_customer_trx_line_id)
      where source_id = rec.source_id
      and source_table = 'RA'
      and ref_customer_trx_line_id in (select customer_trx_line_id
                                       from ra_customer_trx_lines ctl_cm,
                                            ar_receivable_applications ra
                                       where ra.receivable_application_id = rec.source_id
                                       and ra.customer_trx_id = ctl_cm.customer_trx_id
                                       and ctl_cm.previous_customer_trx_line_id is not null);

      l_cnt := sql%rowcount;

      arp_debug.debug('CM ard rows updated : '||l_cnt);

      IF l_cnt > 0 THEN
       arp_debug.debug('Updating INV ard to stamp ref_prev_cust_trx_line_id');

       update ar_distributions ard
       set ref_prev_cust_trx_line_id = (select ref_customer_trx_line_id
                                        from ar_distributions
                                        where source_id = rec.source_id
                                        and ref_prev_cust_trx_line_id = ard.ref_customer_trx_line_id
                                        and rownum = 1)
       where source_id = rec.source_id
       and ref_customer_trx_line_id in (select customer_trx_line_id
                                        from ra_customer_trx_lines ctl_inv,
                                             ar_receivable_applications ra
                                        where ra.receivable_application_id = rec.source_id
                                        and ra.applied_customer_trx_id = ctl_inv.customer_trx_id);
       l_cnt := sql%rowcount;

       arp_debug.debug('INV ard rows updated : '||l_cnt);
      END IF;
   End Loop;


   -- since we are unapplying the regular cm, we need to null out the
   -- previous_customer_trx_id and previous_customer_trx_line_id

   Update ra_customer_Trx
   set previous_customer_Trx_id = NULL
   where customer_Trx_id = p_cust_trx_id
   and previous_customer_Trx_id = p_app_cust_trx_id;

   update ra_customer_Trx_lines
   set previous_customer_Trx_line_id = NULL,
       previous_customer_Trx_id = NULL -- Fix for Bug 6726394 (customer_trx_id
   where customer_Trx_id = p_cust_trx_id -- value has to be set to null in ra_customer_Trx_lines)
   and previous_customer_Trx_id = p_app_cust_trx_id;

   /* Bug 9928392 - Remove association to invoice tax in etax tables */
   BEGIN
      zx_api_pub.unapply_applied_cm(
        p_api_version   => '1.0',
        p_init_msg_list => FND_API.G_FALSE,
        p_commit        => FND_API.G_FALSE,
        p_validation_level => 1,
        p_trx_id        => p_cust_trx_id,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_SUCCESS
      THEN
        NULL;
      ELSE
        arp_debug.debug(x_msg_count || ':' ||
                   substr(x_msg_data,1,150));
        RAISE API_exception;
      END IF;

   EXCEPTION
      WHEN API_exception THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_debug.debug(  'API EXCEPTION: ' ||
                             'zx_api_pub.unapply_applied_cm()'
                                         ||SQLERRM);
         END IF;
         RAISE;

      WHEN OTHERS THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_debug.debug(  'API EXCEPTION (OTHERS): ' ||
                             'zx_api_pub.unapply_applied_cm()'
                                         ||SQLERRM);
         END IF;
         RAISE;
   END;
   /* end 9928392 */

   SELECT trx_number
     INTO l_trx_number
     FROM ra_customer_trx
    WHERE customer_Trx_id = p_app_cust_Trx_id;

    FND_MESSAGE.SET_NAME('AR', 'AR_REG_CM_UNAPP_COMMENTS');
    FND_MESSAGE.SET_TOKEN('INVOICE_NUMBER', l_trx_number);
    l_message_text := fnd_message.get;

    UPDATE ra_cust_trx_line_gl_dist
       SET comments = comments || l_message_text
     WHERE customer_trx_id = p_cust_trx_id
       AND account_set_flag = 'N';

   arp_debug.debug('arp_process_application.Unassociate_Regular_CM()+');

END Unassociate_Regular_CM;

FUNCTION is_regular_cm (p_customer_Trx_id IN NUMBER,
                        p_invoicing_rule_id OUT NOCOPY NUMBER) RETURN BOOLEAN IS

l_prev_cust_trx_id NUMBER;

BEGIN
   arp_debug.debug('arp_process_application.is_regular_cm()+');

   SELECT nvl(previous_customer_Trx_id, -999),
          nvl(invoicing_rule_id, -999)
   INTO l_prev_cust_trx_id,
        p_invoicing_rule_id
   FROM ra_customer_trx
   WHERE customer_trx_id = p_customer_trx_id;

   IF (l_prev_cust_trx_id = -999) THEN
     return FALSE;
   ELSE
     return TRUE;
   END IF;
END is_regular_cm;



END arp_process_application;

/
