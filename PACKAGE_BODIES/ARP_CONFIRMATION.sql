--------------------------------------------------------
--  DDL for Package Body ARP_CONFIRMATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CONFIRMATION" AS
/* $Header: ARRECNFB.pls 120.15 2005/06/14 19:02:58 vcrisost ship $ */

/* =======================================================================
 | Global Data Types
 * ======================================================================*/
SUBTYPE ae_doc_rec_type   IS arp_acct_main.ae_doc_rec_type;

--
-- Private procedures/functions used by this package (Declarations):
--

--
-- Public procedures/functions provided by this package:
--

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    confirm                                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Entity handler interface function for Confirm operation in 10SC        |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |    p_cr_id 		- cash receipt to be confirmed 		             |
 |    p_confirm_gl_date - Confirm GL date                    		     |
 |    p_confirm_date    - Confirm Date                          	     |
 |    p_module_name     - Name of module that called this procedure          |
 |    p_module_version  - Version of the module that called this procedure   |
 |									     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    18-AUG-95	OSTEINME	created					     |
 |    04-DEC-97 KLAWRANC        Bug #590256.  Modified call to               |
 |                              calc_acctd_amount.  Now passes NULL for the  |
 |                              currency code parameter, therefore the acctd |
 |                              amount will be calculated based on the       |
 |                              functional currency.                         |
 |    21-MAY-98 KTANG           For all calls to calc_acctd_amount which     |
 |                              calculates header accounted amounts, if the  |
 |                              exchange_rate_type is not user, call         |
 |                              gl_currency_api.convert_amount instead. This |
 |                              is for triangulation.                        |
 |                                                                           |
 +===========================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE confirm(
	p_cr_id 		IN ar_cash_receipts.cash_receipt_id%TYPE,
	p_confirm_gl_date	IN DATE,
	p_confirm_date		IN DATE,
	p_module_name		IN VARCHAR2,
	p_module_version	IN VARCHAR2 ) IS

-- local variables:

l_acctd_amount			NUMBER;
l_receipt_clearing_ccid
			ar_receipt_method_accounts.receipt_clearing_ccid%TYPE;
l_dummy				NUMBER;
l_cr_rec			ar_cash_receipts%ROWTYPE;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_confirmation.confirm()+');
     arp_standard.debug('confirm: ' || '-- p_cr_id	  : ' || to_char(p_cr_id));
     arp_standard.debug('-- p_confirm_gl_date: ' || to_char(p_confirm_gl_date));
     arp_standard.debug('-- p_confirm_date   : ' || to_char(p_confirm_date));
  END IF;

  -- validate IN parameters:

  validate_in_parameters( p_cr_id,
			  p_confirm_gl_date,
			  p_confirm_date,
			  p_module_name);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('confirm: ' || '-- Parameters validated.');
  END IF;

  -- populate the ar_cash_receipts record from ar_cash_receipts table.
  -- use ar_cash_receipt_id for selection.

  l_cr_rec.cash_receipt_id := p_cr_id;
  arp_cash_receipts_pkg.fetch_p(l_cr_rec);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('confirm: ' || '-- Cash Receipt fetched');
  END IF;

  -- get receipt clearing code combination id from ar_receipt_method_accounts

  get_receipt_clearing_ccid(l_cr_rec, l_receipt_clearing_ccid);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('confirm: ' || '-- Receipt Clearing code combination fetched');
     arp_standard.debug('confirm: ' || '-- receipt_clearing_ccid = '|| l_receipt_clearing_ccid);
  END IF;

  -- calculate accounted cash receipt amount
  -- Changes for triangulation: If exchange rate type is not user, call
  -- GL API to calculate accounted amount
  IF (l_cr_rec.exchange_rate_type = 'User') THEN
    arp_util.calc_acctd_amount(	NULL,
				NULL,
			    	NULL,
			    	l_cr_rec.exchange_rate,
			    	'+',
			    	l_cr_rec.amount,
			    	l_acctd_amount,
			    	0,
			    	l_dummy,
			    	l_dummy,
			    	l_dummy);
  ELSE
    l_acctd_amount := gl_currency_api.convert_amount(
			arp_global.set_of_books_id,
			l_cr_rec.currency_code,
                        l_cr_rec.exchange_date,
                        l_cr_rec.exchange_rate_type,
			l_cr_rec.amount);
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('confirm: ' || '-- Accounted Amount calculated:');
     arp_standard.debug('confirm: ' || '-- Exchange Rate:  ' || to_char(l_cr_rec.exchange_rate));
     arp_standard.debug('confirm: ' || '-- Receipt Amount: ' || to_char(l_cr_rec.amount));
     arp_standard.debug('confirm: ' || '-- Acctd Amount:   ' || to_char(l_acctd_amount));
  END IF;

  -- update the ar_cash_receipt_history_table with a new record for
  -- this receipt.  This call will also create a new ar_distributions
  -- record.

  update_cr_history_confirm(	l_cr_rec,
				p_confirm_gl_date,
				p_confirm_date,
				l_acctd_amount,
				l_receipt_clearing_ccid);

  -- call do_confirm to process the individual applications and
  -- update the payment schedule of the receipt.
  -- Note:  This functionality was grouped together in one function,
  --        because it basically represents the functionality of the
  --        confirm user exit in Rel. 10. Do_confirm is called from
  --        the interface function execute_confirm.

  do_confirm(	l_cr_rec,
		p_confirm_gl_date,
		p_confirm_date,
		l_acctd_amount);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_confirmation.confirm()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION: arp_confirmation.confirm()');
    END IF;
    RAISE;

END; -- confirm()


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    unconfirm                                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Entity handler interface function for Unconfirm operation in 10SC      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |    p_cr_id 		- ID of cash receipt to be unconfirmed               |
 |    p_confirm_gl_date - Unconfirm GL date                    		     |
 |    p_confirm_date    - Unconfirm Date                          	     |
 |    p_module_name     - Name of module that called this procedure          |
 |    p_module_version  - Version of the module that called this procedure   |
 |									     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    28-AUG-95	OSTEINME	created					     |
 |    04-DEC-97 KLAWRANC        Bug #590256.  Modified call to               |
 |                              calc_acctd_amount.  Now passes NULL for the  |
 |                              currency code parameter, therefore the acctd |
 |                              amount will be calculated based on the       |
 |                              functional currency.                         |
 |                                                                           |
 +===========================================================================*/



PROCEDURE unconfirm(
	p_cr_id 		IN ar_cash_receipts.cash_receipt_id%TYPE,
	p_confirm_gl_date	IN DATE,
	p_confirm_date		IN DATE,
	p_module_name		IN VARCHAR2,
	p_module_version	IN VARCHAR2 ) IS

-- local variables:

l_cr_rec			ar_cash_receipts%ROWTYPE;
l_acctd_amount			NUMBER;
l_receipt_clearing_ccid
		ar_receipt_method_accounts.receipt_clearing_ccid%TYPE;
l_batch_id			ar_cash_receipt_history.batch_id%TYPE;
l_crh_id_rev
		ar_cash_receipt_history.cash_receipt_history_id%TYPE;
l_dummy				NUMBER;			-- dummy variable

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_confirmation.unconfirm()+');
     arp_standard.debug('confirm: ' || to_char(p_cr_id));
  END IF;

  -- validate IN parameters:

  validate_in_parameters( p_cr_id,
			  p_confirm_gl_date,
			  p_confirm_date,
			  p_module_name);

  -- populate the ar_cash_receipts record from ar_cash_receipts table.
  -- use ar_cash_receipt_id for selection.

  l_cr_rec.cash_receipt_id := p_cr_id;
  arp_cash_receipts_pkg.fetch_p(l_cr_rec);

  -- calculate accounted cash receipt amount
  -- Changes for triangulation: If exchange rate type is not user, call
  -- GL API to calculate accounted amount
  IF (l_cr_rec.exchange_rate_type = 'User') THEN
    arp_util.calc_acctd_amount(	NULL,
				NULL,
			    	NULL,
			    	l_cr_rec.exchange_rate,
			    	'+',
			    	l_cr_rec.amount,
			    	l_acctd_amount,
			    	0,
			    	l_dummy,
			    	l_dummy,
			    	l_dummy);
  ELSE
    l_acctd_amount := gl_currency_api.convert_amount(
			arp_global.set_of_books_id,
                        l_cr_rec.currency_code,
                        l_cr_rec.exchange_date,
                        l_cr_rec.exchange_rate_type,
			l_cr_rec.amount);
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('confirm: ' || '-- Accounted Amount calculated:');
     arp_standard.debug('confirm: ' || '-- Exchange Rate:  ' || to_char(l_cr_rec.exchange_rate));
     arp_standard.debug('confirm: ' || '-- Receipt Amount: ' || to_char(l_cr_rec.amount));
     arp_standard.debug('confirm: ' || '-- Acctd Amount:   ' || to_char(l_acctd_amount));
  END IF;

  -- update the ar_cash_receipt_history_table with a new record for
  -- this receipt.  This call will also create a new ar_distributions
  -- record to reverse the 'confirm' record.

  update_cr_history_unconfirm(	l_cr_rec,
				p_confirm_gl_date,
				p_confirm_date,
				l_acctd_amount,
				l_batch_id,
				l_crh_id_rev);

  -- call do_unconfirm to process the individual applications and
  -- update the payment schedule of the receipt.
  -- Note:  This functionality was grouped together in one function,
  --        because it basically represents the functionality of the
  --        confirm user exit in Rel. 10. Do_unconfirm is called from
  --        the interface function execute_unconfirm.

  do_unconfirm(	l_cr_rec,
		p_confirm_gl_date,
		p_confirm_date,
		l_acctd_amount,
		l_batch_id);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_confirmation.unconfirm()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION: arp_confirmation.unconfirm()');
    END IF;
    RAISE;

END;  -- unconfirm()


/* Bug fix 872506 */
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    confirm_batch                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Entity handler interface function for Confirm receipt in batch level   |
 |    operation                                                    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:                                                                    |
 |    p_batch_id          - batch receipt to be confirmed                    |
 |    p_confirm_gl_date   - Confirm GL date                                  |
 |    p_confirm_date      - Confirm Date                                     |
 |                                                                           |
 |    OUT:                                                                   |
 |    p_num_rec_confirmed - Number of receipts in the batch confirmed        |
 |    p_num_rec_error     - Number of receipts in the batch unconfirmed      |
 |                                                                           |
 | RETURNS                                                                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 |    10-APR-2002  R Kader        created                                    |
 |                                                                           |
 +===========================================================================*/

PROCEDURE confirm_batch(
        p_batch_id              IN NUMBER,
        p_confirm_gl_date       IN DATE,
        p_confirm_date          IN DATE,
        p_num_rec_confirmed     OUT NOCOPY NUMBER,
        p_num_rec_error         OUT NOCOPY NUMBER) IS

  l_num_rec_confirmed NUMBER := 0;
  l_num_rec_error NUMBER :=0;

BEGIN

   -- Verify that batch is really an automatic batch:
   -- 'type' must be CREATION

   -- ...


   DECLARE
     CURSOR confirmCursor (auto_batch_id IN NUMBER) IS
       SELECT cash_receipt_id
       FROM AR_CASH_RECEIPT_HISTORY
       WHERE current_record_flag = 'Y'
         AND status='APPROVED'
         AND batch_id = auto_batch_id;

     l_cash_receipt_rec confirmCursor%ROWTYPE;

   BEGIN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('arp_confirmation.confirm_batch()+');
     END IF;

     FOR l_cash_receipt_rec IN confirmCursor(p_batch_id) LOOP
       BEGIN

         SAVEPOINT ar_confirm_batch_sp;

         UPDATE AR_CASH_RECEIPTS
         SET    confirmed_flag = 'Y'
         WHERE  cash_receipt_id = l_cash_receipt_rec.cash_receipt_id;

         arp_confirmation.confirm(
                l_cash_receipt_rec.cash_receipt_id,
                p_confirm_gl_date,
                p_confirm_date,
                'ARXRWMAI',
                '1x');

         l_num_rec_confirmed := l_num_rec_confirmed + 1;

       EXCEPTION
         WHEN OTHERS THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('Exception in arp_confirmation.confirm_batch');
           END IF;
           ROLLBACK TO ar_confirm_batch_sp;
           l_num_rec_error := l_num_rec_error + 1;
       END;
     END LOOP;
   END;

   p_num_rec_confirmed := l_num_rec_confirmed;
   p_num_rec_error := l_num_rec_error;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('arp_confirmation.confirm_batch()-');
   END IF;

END confirm_batch;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    confirm_receipt                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    API for Confirm receipt operation in 10SC                              |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:                                                                    |
 |    p_cr_id           - cash receipt to be confirmed                       |
 |    p_confirm_gl_date - Confirm GL date                                    |
 |    p_confirm_date    - Confirm Date                                       |
 |                                                                           |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS                                                                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 |    12-APR-99 GJWANG          created                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE confirm_receipt(
        p_cr_id                 IN NUMBER,
        p_confirm_gl_date       IN DATE,
        p_confirm_date          IN DATE) IS

  l_status          VARCHAR2(30);
  l_confirmed_flag  VARCHAR2(2);
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_confirmation.confirm_receipt()+');
     arp_standard.debug('****** Begin Confirm Receipt ****** ');
     arp_standard.debug('confirm: ' || '-- p_cr_id          : ' || to_char(p_cr_id));
     arp_standard.debug('-- p_confirm_gl_date: ' || to_char(p_confirm_gl_date));
     arp_standard.debug('-- p_confirm_date   : ' || to_char(p_confirm_date));
  END IF;

  IF  arp_util.is_gl_date_valid(p_confirm_gl_date) THEN

        SELECT  crh.status, cr.confirmed_flag
        INTO    l_status, l_confirmed_flag
        FROM    AR_CASH_RECEIPTS cr,
                AR_CASH_RECEIPT_HISTORY crh
        WHERE   cr.cash_receipt_id = crh.cash_receipt_id
          AND   cr.cash_receipt_id = p_cr_id;

        IF (l_status = 'APPROVED') and (l_confirmed_flag = 'N') THEN
          UPDATE AR_CASH_RECEIPTS
          SET    confirmed_flag = 'Y'
          WHERE  cash_receipt_id = p_cr_id;

          arp_confirmation.confirm(
                p_cr_id,
                p_confirm_gl_date,
                p_confirm_date,
                'ARXRWMAI',
                '1x');
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('==> Receipt ' || to_char(p_cr_id) || ' confirmed');
          END IF;

        END IF;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('arp_confirmation.confirm_receipt: Invalid GL DATE ' || to_char(p_confirm_gl_date));
      END IF;
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_confirmation.confirm_receipt()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('EXCEPTION: arp_confirmation.confirm_receipt');
      END IF;
      RAISE;
END confirm_receipt; -- confirm_receipt()
/* End Bug fix 872506 */
--
-- Private procedures/functions used by this package (Code):
--



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    do_confirm                                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Performs most of the steps needed to confirm a cash receipt:           |
 |       for every application record of a given cash receipt                |
 |          update associated invoice's payment schedule                     |
 |          update receivable_application				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |    p_cr_rec 		- cash receipt to be confirmed               	     |
 |    p_confirm_gl_date - Unconfirm GL date                    		     |
 |    p_confirm_date    - Unconfirm Date                          	     |
 |    p_acctd_amount	- accounted receipt amount			     |
 |									     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    18-AUG-95	OSTEINME	created					     |
 |    04-DEC-97 KLAWRANC        Bug #590256.  Modified call to               |
 |                              calc_acctd_amount.  Now passes NULL for the  |
 |                              currency code parameter, therefore the acctd |
 |                              amount will be calculated based on the       |
 |                              functional currency.                         |
 |    11-JAN-98 JGDABIR         Bug 768935.  Initially set                   |
 |                              acctd_amount_applied_from to NULL.           |
 |                                                                           |
 +===========================================================================*/

PROCEDURE do_confirm(
	p_cr_rec			IN  ar_cash_receipts%ROWTYPE,
	p_confirm_gl_date		IN  DATE,
	p_confirm_date			IN  DATE,
	p_acctd_amount			IN  NUMBER
			) IS

-- Local variables:

l_dummy			NUMBER;

l_inv_ps_rec		ar_payment_schedules%ROWTYPE;
l_max_dates		MaxDatesType;			-- record type

l_line_applied		NUMBER;
l_tax_applied		NUMBER;
l_freight_applied	NUMBER;
l_charges_applied	NUMBER;
l_line_ediscounted	NUMBER;
l_tax_ediscounted	NUMBER;
l_freight_ediscounted	NUMBER;
l_charges_ediscounted	NUMBER;
l_line_uediscounted	NUMBER;
l_tax_uediscounted	NUMBER;
l_freight_uediscounted	NUMBER;
l_charges_uediscounted	NUMBER;
l_rule_set_id           NUMBER;

l_apply_date		DATE;
l_gl_date		DATE;
l_cnf_gl_date		DATE;
l_cnf_date		DATE;

l_ao_flag 		ra_cust_trx_types.allow_overapplication_flag%TYPE;
l_nao_flag		ra_cust_trx_types.natural_application_only_flag%TYPE;
l_creation_sign		ra_cust_trx_types.creation_sign%TYPE;

l_acctd_app_amount_to
		ar_receivable_applications.acctd_amount_applied_to%TYPE;
l_acctd_app_amount_from
		ar_receivable_applications.acctd_amount_applied_from%TYPE;

l_ae_doc_rec ae_doc_rec_type;

l_app_id        ar_receivable_applications.receivable_application_id%TYPE;


-- Following two parametes and the currency cursor is introduced By
-- RAM-C (ORASHID)

l_exchange_rate	         ra_customer_trx_all.exchange_rate%TYPE;
l_invoice_currency_code  ra_customer_trx_all.invoice_currency_code%TYPE;

CURSOR currency (p_trx_id IN NUMBER) IS
    SELECT invoice_currency_code,
           exchange_rate
    FROM   ra_customer_trx_all
    WHERE  customer_trx_id = p_trx_id;


-- Define cursor for applications:

CURSOR ar_receivable_applications_C (
  p_cr_id	ar_cash_receipts.cash_receipt_id%TYPE
				) IS
  SELECT	*
  FROM 		ar_receivable_applications
  WHERE		cash_receipt_id      = p_cr_id
    AND		status	  	     = 'APP'
    AND     	reversal_gl_date     IS NULL;

BEGIN

 arp_standard.debug('arp_confirmation.do_confirm()+');

  -- initialize l_max_dates:

  l_max_dates.max_trx_date 	:= p_confirm_date;
  l_max_dates.max_gl_date	:= p_confirm_gl_date;
  l_max_dates.cnf_date		:= p_confirm_date;
  l_max_dates.cnf_gl_date	:= p_confirm_gl_date;
  l_max_dates.max_ra_apply_date := p_confirm_date;
  l_max_dates.max_ra_gl_date	:= p_confirm_gl_date;

  -- process every application record for the given cash receipt:

  FOR l_ra_rec IN ar_receivable_applications_C(p_cr_rec.cash_receipt_id)
  LOOP

    -- Bug 768935: initially set l_acctd_app_amount_from to NULL,
    -- let calc_acctd_amount calculate.

    l_acctd_app_amount_from := NULL;

    arp_standard.debug('-- Fetched ra record -- ra_id = '||
		l_ra_rec.receivable_application_id);

    -- get payment schedule of invoice for this application.  This
    -- is required to update the 'selected_for_receipt_batch_id' column.

    arp_ps_pkg.fetch_p(l_ra_rec.applied_payment_schedule_id, l_inv_ps_rec);

    arp_standard.debug('-- Fetched invoice ps record.  ps_id = '||
		to_char(l_ra_rec.applied_payment_schedule_id));

    -- determine dates based on receivable_application and payment_schedule
    -- record:

    l_apply_date  := GREATEST(	p_confirm_date,
			  	l_ra_rec.apply_date,
			  	l_inv_ps_rec.trx_date);
    l_gl_date     := GREATEST(	p_confirm_gl_date,
				l_inv_ps_rec.gl_date);
    l_cnf_gl_date := GREATEST(	p_confirm_gl_date,
				l_inv_ps_rec.gl_date);
    l_cnf_date	  := GREATEST(  p_confirm_date,
				l_inv_ps_rec.trx_date);

    -- update max_dates data structure:

    handle_max_dates(	l_max_dates,
		 	l_gl_date,
			l_apply_date,
			p_confirm_date,
			p_confirm_gl_date);

    arp_standard.debug('-- determined max_dates');

    -- check for violation of application rules (over-application,
    -- creation sign, natural application).

    get_application_flags(	l_inv_ps_rec.cust_trx_type_id,
				l_ao_flag,
				l_nao_flag,
				l_creation_sign);

    arp_standard.debug('-- got application flags');

    /*@ check_application_rules(l_ra_rec); */ -- ?????????????????????????

    -- update invoice payment schedule to which this application record
    -- is applied:
    -- First set the 'selected_for_receipt_batch_id' to NULL as this
    -- invoice is no longer selected (and potentially available for
    -- another selection).  Then call update_invoice_related_columns
    -- to apply the application_amount to the invoice and update the
    -- payment schedule in the database.

    l_inv_ps_rec.selected_for_receipt_batch_id := NULL;


    arp_ps_util.update_invoice_related_columns(
			'CASH',
			NULL,			-- No ps_id
			l_ra_rec.amount_applied,
			0,			-- discounts taken
			0,			-- discounts earned
			l_cnf_date,
			l_cnf_gl_date,
			l_acctd_app_amount_to,
			l_dummy,
			l_dummy,
			l_line_applied,
			l_tax_applied,
			l_freight_applied,
			l_charges_applied,
                        l_line_ediscounted,
                        l_tax_ediscounted,
                        l_freight_ediscounted,
                        l_charges_ediscounted,
                        l_line_uediscounted,
                        l_tax_uediscounted,
                        l_freight_uediscounted,
                        l_charges_uediscounted,
                        l_rule_set_id,
			l_inv_ps_rec);

    arp_standard.debug('-- invoice ps updated.');
    arp_standard.debug('-- l_acctd_app_amount_to = ' ||
			to_char(l_acctd_app_amount_to));
    arp_standard.debug('-- l_line_applied    = ' || to_char(l_line_applied));
    arp_standard.debug('-- l_tax_applied    = ' || to_char(l_tax_applied));
    arp_standard.debug('-- l_freight_applied    = ' ||
			to_char(l_freight_applied));
    arp_standard.debug('-- l_charges_applied    = ' ||
                        to_char(l_charges_applied));


    -- calculate accounted amount for application (receipt side):

    arp_util.calc_acctd_amount( NULL,
				NULL,
				NULL,
				p_cr_rec.exchange_rate,
				'+',
				l_ra_rec.amount_applied,
				l_acctd_app_amount_from,
				0,
				l_dummy,
				l_dummy,
				l_dummy);

    arp_standard.debug('-- calculated acctd_app_amount_from = ' ||
			to_char(l_acctd_app_amount_from));
    arp_standard.debug('-- amount_applied for ra = '||
			to_char(l_ra_rec.amount_applied));

    -- Update receivable applications record.  Use the return values
    -- of the previous function call to fill the line, tax, freight,
    -- and charges applied columns.

    UPDATE ar_receivable_applications
    SET    confirmed_flag  		= 'Y',
           postable        		= 'Y',
           gl_date         		= l_max_dates.max_ra_gl_date,
           apply_date      		= l_max_dates.max_ra_apply_date,
           acctd_amount_applied_to 	= l_acctd_app_amount_to,
           acctd_amount_applied_from 	= l_acctd_app_amount_from,
           line_applied   		= l_line_applied,
           tax_applied     		= l_tax_applied,
           freight_applied 		= l_freight_applied,
           receivables_charges_applied 	= l_charges_applied,
           line_ediscounted             = l_line_ediscounted,
           tax_ediscounted              = l_tax_ediscounted,
           freight_ediscounted          = l_freight_ediscounted,
           charges_ediscounted          = l_charges_ediscounted,
           line_uediscounted            = l_line_uediscounted,
           tax_uediscounted             = l_tax_uediscounted,
           freight_uediscounted         = l_freight_uediscounted,
           charges_uediscounted         = l_charges_uediscounted,
           rule_set_id                  = l_rule_set_id,
           last_update_date 		= TRUNC(SYSDATE),
           last_updated_by 		= FND_GLOBAL.user_id
    WHERE
	   receivable_application_id	= l_ra_rec.receivable_application_id;

    arp_standard.debug('-- ra record updated.');

    --  call mrc to replicate the data
    ar_mrc_engine3.confirm_ra_rec_update(
                           l_ra_rec.receivable_application_id);

    arp_standard.debug('-- MRC ra record updated if necessary');

   --
   --Release 11.5 VAT changes, create the application accounting for
   --confirmed APP record in ar_distributions. In this case we create
   --the APP directly as only confirmed APP records have accounting created
   --basically we dont require the module below to be called in update mode
   --(delete + create)
   --
    l_ae_doc_rec.document_type             := 'RECEIPT';
    l_ae_doc_rec.document_id               := p_cr_rec.cash_receipt_id;
    l_ae_doc_rec.accounting_entity_level   := 'ONE';
    l_ae_doc_rec.source_table              := 'RA';
    l_ae_doc_rec.source_id                 := l_ra_rec.receivable_application_id;  --id of APP record
    l_ae_doc_rec.source_id_old             := '';
    l_ae_doc_rec.other_flag                := '';

  --Bug 1329091 - PS is updated before Accounting Engine Call
    l_ae_doc_rec.pay_sched_upd_yn := 'Y';
    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

    l_app_id := l_ra_rec.receivable_application_id;

    -- RAM-C changes begin from this point onward.
    --
    -- call revenue management engine's receipt analyzer for revenue related
    -- impact of this application.

    arp_standard.debug( 'calling receipt_analyzer in application mode');

    -- RAM-C changes begin.
    --
    -- get the invoice currency and the exchange rate
    -- from ra_customer_trx_all given the customer_trx_id

    OPEN currency(l_ra_rec.applied_customer_trx_id);
    FETCH currency INTO l_invoice_currency_code, l_exchange_rate;
    CLOSE currency;

    ar_revenue_management_pvt.receipt_analyzer
    (
      p_mode                  =>
        ar_revenue_management_pvt.c_receipt_application_mode,
      p_customer_trx_id       => l_ra_rec.applied_customer_trx_id,
      p_acctd_amount_applied  => l_acctd_app_amount_to,
      p_exchange_rate 	      => l_exchange_rate,
      p_invoice_currency_code => l_invoice_currency_code,
      p_tax_applied 	      => l_tax_applied,
      p_charges_applied       => l_charges_applied,
      p_freight_applied       => l_freight_applied,
      p_line_applied 	      => l_line_applied,
      p_gl_date               => l_max_dates.max_ra_gl_date
    );

    arp_standard.debug( 'returned from receipt_analyzer');

    -- RAM-C changes end at this point.

    --apandit
    --Bug 2641517 rase CR apply business event upon confirmation
    arp_standard.debug( 'before raising the business event : Raise_CR_Apply_Event');
     AR_BUS_EVENT_COVER.Raise_CR_Apply_Event(
                            l_ra_rec.receivable_application_id);
  END LOOP;


  -- update UNAPP record of the cash receipt in ar_receivable_applications:

  modify_update_ra_rec( p_cr_rec.cash_receipt_id,
			p_cr_rec.amount,
			p_acctd_amount,
			p_confirm_gl_date,
			p_confirm_date);

  -- update receipt payment schedule:
  -- ????? VERIFY that dates are correct ?????

  confirm_update_ps_rec( p_cr_rec,
			l_max_dates.max_trx_date,
			l_max_dates.max_gl_date);


  -- create matching UNAPP records for APP records in
  -- ar_receivable_applications (negative amounts).
  -- as part of 11.5 changes, the APP id also needs to be passed
  -- as UNAPP records are paired with their APP records

  create_matching_unapp_records(p_cr_rec.cash_receipt_id, l_app_id);

  arp_standard.debug('arp_confirmation.do_confirm()-');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    arp_util.debug('EXCEPTION: NO DATA FOUND, arp_confirmation.do_confirm()');
    RAISE;

  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION: arp_confirmation.do_confirm()');
    RAISE;

END; -- do_confirm()



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    do_unconfirm                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Performs most of the steps needed to unconfirm a cash receipt:         |
 |       for every application record of a given cash receipt                |
 |          update associated invoice's payment schedule                     |
 |          update receivable_application				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |    p_cr_rec 		- cash receipt to be confirmed               	     |
 |    p_confirm_gl_date - Unconfirm GL date                    		     |
 |    p_confirm_date    - Unconfirm Date                          	     |
 |    p_acctd_amount	- accounted receipt amount			     |
 |    p_batch_id	- batch id for receipt batch (needed to update inv.  |
 |			  payment schedule)				     |
 |									     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    28-AUG-95	OSTEINME	created					     |
 |                                                                           |
 +===========================================================================*/



PROCEDURE do_unconfirm(
	p_cr_rec			IN  ar_cash_receipts%ROWTYPE,
	p_confirm_gl_date		IN  DATE,
	p_confirm_date			IN  DATE,
	p_acctd_amount			IN  NUMBER,
	p_batch_id
		IN ar_payment_schedules.selected_for_receipt_batch_id%TYPE
			) IS

-- Define cursor for applications:

CURSOR ar_receivable_applications_C (
  p_cr_id	ar_cash_receipts.cash_receipt_id%TYPE
				) IS
  SELECT	*
  FROM 		ar_receivable_applications
  WHERE		cash_receipt_id      = p_cr_id
    AND		status	  	     = 'APP'
    AND     	reversal_gl_date     IS NULL;

BEGIN

  -- process every application record for the given cash receipt:

  FOR l_app_rec IN ar_receivable_applications_C(p_cr_rec.cash_receipt_id)
  LOOP

    -- Update invoice payment schedule to which this application record
    -- is applied.  This step basically reverses the application of the
    -- receipt to the invoice.


    reverse_application_to_ps(
			l_app_rec.receivable_application_id,
			p_confirm_gl_date,
			p_confirm_date,
			p_batch_id);

  END LOOP;


  -- create reversing records in ar_receivable_applications

  reverse_ra_recs(	p_cr_rec,
			p_confirm_gl_date,
			p_confirm_date);

  -- update receipt payment schedule:

  unconfirm_update_ps_rec(	p_cr_rec,
				p_confirm_gl_date,
				p_confirm_date);

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION: arp_confirmation.do_unconfirm()');
    RAISE;

END; -- do_unconfirm()



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_cr_history_conf 						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Creates a new entry for the cash_receipt_history table.      	     |
 |    It will have the updated receipt amount and the status                 |
 |    'CONFIRMED'.  Also creates an ar_distributions record for 	     |
 |    the new history record.						     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |    p_cr_rec 			- cash receipt for which the history entry   |
 |                        	  is to be created                           |
 |    p_confirm_gl_date 	- Unconfirm GL date            		     |
 |    p_confirm_date   	 	- Unconfirm Date                      	     |
 |    p_acctd_amount		- accounted cash receipt amount		     |
 |    p_receipt_clearing_ccid   - code combination id			     |
 |									     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    18-AUG-95	OSTEINME	created					     |
 |                                                                           |
 +===========================================================================*/


PROCEDURE update_cr_history_confirm(
	p_cr_rec		IN ar_cash_receipts%ROWTYPE,
	p_confirm_gl_date	IN DATE,
	p_confirm_date		IN DATE,
	p_acctd_amount		IN NUMBER,
	p_receipt_clearing_ccid IN
		ar_receipt_method_accounts.receipt_clearing_ccid%TYPE
			) IS
--
l_crh_rec_old			ar_cash_receipt_history%ROWTYPE;
l_crh_rec_new			ar_cash_receipt_history%ROWTYPE;
l_crh_id_new			ar_cash_receipts.cash_receipt_id%TYPE;
l_dist_rec			ar_distributions%ROWTYPE;
l_dist_line_id			ar_distributions.line_id%TYPE;

--
BEGIN

  arp_standard.debug('arp_confirmation.update_cr_history_confirm()+');

  -- fetch current record from ar_cash_receipt_history

  arp_cr_history_pkg.fetch_f_crid(p_cr_rec.cash_receipt_id, l_crh_rec_old);

  arp_standard.debug('-- current history record fetched.  crh_id = '||
		     to_char(l_crh_rec_old.cash_receipt_history_id));

  -- update columns in current record

  l_crh_rec_old.reversal_gl_date 		:= p_confirm_gl_date;
  l_crh_rec_old.reversal_posting_control_id 	:= -3;
  l_crh_rec_old.reversal_created_from		:= 'ARRECNF';
  l_crh_rec_old.current_record_flag		:= NULL;
  l_crh_rec_old.first_posted_record_flag	:= 'N';


  -- create new record:

  l_crh_rec_new.amount 				:= p_cr_rec.amount;
  l_crh_rec_new.acctd_amount			:= p_acctd_amount;
  l_crh_rec_new.cash_receipt_id			:= p_cr_rec.cash_receipt_id;
  l_crh_rec_new.factor_flag 			:= 'N';
  l_crh_rec_new.first_posted_record_flag	:= 'Y';
  l_crh_rec_new.gl_date				:= p_confirm_gl_date;
  l_crh_rec_new.postable_flag			:= 'Y';
  l_crh_rec_new.posting_control_id		:= -3;
  l_crh_rec_new.status				:= 'CONFIRMED';
  l_crh_rec_new.trx_date			:= p_confirm_date;
  l_crh_rec_new.acctd_factor_discount_amount	:= NULL;
  l_crh_rec_new.account_code_combination_id	:= p_receipt_clearing_ccid;
  l_crh_rec_new.bank_charge_account_ccid	:= NULL;
  l_crh_rec_new.batch_id			:= NULL;
  l_crh_rec_new.current_record_flag		:= 'Y';
  l_crh_rec_new.exchange_date			:= p_cr_rec.exchange_date;
  l_crh_rec_new.exchange_rate			:= p_cr_rec.exchange_rate;
  l_crh_rec_new.exchange_rate_type		:= p_cr_rec.exchange_rate_type;
  l_crh_rec_new.factor_discount_amount		:= NULL;
  l_crh_rec_new.gl_posted_date			:= NULL;
  l_crh_rec_new.request_id			:= NULL;
  l_crh_rec_new.created_from			:= 'ARRECNF';
  l_crh_rec_new.prv_stat_cash_receipt_hist_id   := l_crh_rec_old.cash_receipt_history_id;

  -- insert new current record into cash receipt history table

  arp_cr_history_pkg.insert_p(l_crh_rec_new, l_crh_id_new);

  arp_standard.debug('-- new crh record inserted. crh_id = ' ||
		     to_char(l_crh_id_new));

  -- link new current record to previous current record and update the latter:

  l_crh_rec_old.reversal_cash_receipt_hist_id := l_crh_id_new;
  arp_cr_history_pkg.update_p(l_crh_rec_old);

  arp_standard.debug('-- previous record updated');

  -- create ar_distributions record for new history record:

  arp_standard.debug('-- ccid = ' || p_receipt_clearing_ccid);
  l_dist_rec.source_id 			:= l_crh_id_new;
  l_dist_rec.source_table		:= 'CRH';
  l_dist_rec.source_type		:= 'CONFIRMATION';
  l_dist_rec.last_update_date		:= SYSDATE;
  l_dist_rec.last_updated_by		:= FND_GLOBAL.user_id;
  l_dist_rec.creation_date		:= SYSDATE;
  l_dist_rec.created_by			:= FND_GLOBAL.user_id;
  l_dist_rec.code_combination_id	:= p_receipt_clearing_ccid;

  --  Populate additional value for 11.5 VAT project
  --  populate the exchange rate info from the crh record.

  l_dist_rec.currency_code            := p_cr_rec.currency_code;
  l_dist_rec.currency_conversion_rate := l_crh_rec_new.exchange_rate;
  l_dist_rec.currency_conversion_type := l_crh_rec_new.exchange_rate_type;
  l_dist_rec.currency_conversion_date := l_crh_rec_new.exchange_date;
  l_dist_rec.third_party_id           := p_cr_rec.pay_from_customer;
  l_dist_rec.third_party_sub_id       := p_cr_rec.customer_site_use_id;

  IF  p_cr_rec.amount < 0 THEN
    l_dist_rec.amount_dr := NULL;
    l_dist_rec.amount_cr := - p_cr_rec.amount;
  ELSE
    l_dist_rec.amount_dr := p_cr_rec.amount;
    l_dist_rec.amount_cr := NULL;
  END IF;

  IF  p_acctd_amount < 0 THEN
    l_dist_rec.acctd_amount_dr := NULL;
    l_dist_rec.acctd_amount_cr := -p_acctd_amount;
  ELSE
    l_dist_rec.acctd_amount_dr := p_acctd_amount;
    l_dist_rec.acctd_amount_cr := NULL;
  END IF;

  arp_distributions_pkg.insert_p(l_dist_rec, l_dist_line_id);

        /* need to insert records into the MRC table.  Calling new
           mrc engine */

  ar_mrc_engine2.maintain_mrc_data2(
                              p_event_mode => 'INSERT',
                              p_table_name => 'AR_DISTRIBUTIONS',
                              p_mode       => 'SINGLE',
                              p_key_value  =>  l_dist_line_id,
                              p_row_info   =>  l_dist_rec);

  arp_standard.debug('-- distribution record inserted. dist_line_id = '||
		     to_char(l_dist_line_id));

  arp_standard.debug('update_cr_history_confirm()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION: update_cr_history_confirm()');
    RAISE;

END;  -- update_cr_history_confirm()



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    confirm_update_ps_rec						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function updates the payment schedule record for a cash receipt   |
 |    after all applications have been processed.  It basically sets the     |
 |    amount_due_remaining to zero, the amount_due_original to the receipt   |
 |    amount, and the receipt_confirmed_flag to 'Y'.  It also sets the       |
 |    closed flag and the closed date and gl date.                           |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |      p_cr_rec		receipt record				     |
 |      p_closed_date		closed date				     |
 |      p_closed_gl_date        closed gl date                               |
 |									     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    18-AUG-95	OSTEINME	created					     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE confirm_update_ps_rec(
		p_cr_rec		ar_cash_receipts%ROWTYPE,
		p_closed_date		DATE,
		p_closed_gl_date	DATE
			) IS

l_receipt_ps_rec		ar_payment_schedules%ROWTYPE;
l_dummy				NUMBER;

BEGIN

  arp_standard.debug('arp_confirmation.confirm_update_ps_rec()+');
  -- Fetch receipt's payment schedule record:

  SELECT 	*
  INTO 		l_receipt_ps_rec
  FROM		ar_payment_schedules
  WHERE 	cash_receipt_id = p_cr_rec.cash_receipt_id;


  -- set confirmed flag to 'Y' to mark receipt as confirmed:
  l_receipt_ps_rec.receipt_confirmed_flag := 'Y';

  -- Bug 1199703 : update ar_payment_schedules.gl_date when receipt is confirmed
  l_receipt_ps_rec.gl_date := p_closed_gl_date;

  -- call utility handler routine to update payment schedule record:


  arp_ps_util.update_receipt_related_columns(
			NULL,			-- no payment_schedule_id!
			p_cr_rec.amount,
			p_closed_date,
			p_closed_gl_date,
			l_dummy,
			l_receipt_ps_rec);

  arp_standard.debug('arp_confirmation.confirm_update_ps_rec()-');

  EXCEPTION
    WHEN OTHERS THEN
      arp_util.debug('EXCEPTION: arp_confirmation.confirm_update_ps_rec()');
      RAISE;

END; -- confirm_update_ps_rec()


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    modify_update_ra_rec						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function updates the original UNAPP record for the cash receipt   |
 |    in ar_receivable_applications.					     |
 |    It also determines the payment schedule id for the receipt, which is   |
 |    returned for future use.						     |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |      p_cr_id			- cash receipt id			     |
 |      p_amount_applied	- amount applied to invoices (= rec amount)  |
 |      p_acctd_amount_applied  - accounted amount applied to invoices       |
 |      p_confirm_gl_date						     |
 |      p_confirm_date							     |
 |									     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    18-AUG-95	OSTEINME	created					     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE modify_update_ra_rec(
	p_cr_id			 IN ar_cash_receipts.cash_receipt_id%TYPE,
	p_amount_applied	 IN NUMBER,
	p_acctd_amount_applied   IN NUMBER,
	p_confirm_gl_date	 IN DATE,
	p_confirm_date	         IN DATE
			) IS

l_receivable_application_id ar_receivable_applications.receivable_application_id%TYPE;
l_ae_doc_rec                ae_doc_rec_type;

BEGIN

--
--Release 11.5 VAT changes retrieve the unconfirmed UNAPP record as the application
--id is required to create the accounting in the AR_DISTRIBUTIONS table
--moved where clause from update to select

  SELECT app.receivable_application_id
  INTO   l_receivable_application_id
  FROM   ar_receivable_applications app
  WHERE  app.cash_receipt_id = p_cr_id
  AND    app.status = 'UNAPP'
  AND    app.confirmed_flag = 'N'
  AND    app.reversal_gl_date IS NULL
  AND	 app.application_rule IN ('97.0', '40.0');

  -- update record

  arp_standard.debug('arp_confirmation.modify_update_ra_rec()+');

  UPDATE	ar_receivable_applications
  SET	        gl_date				= p_confirm_gl_date,
		apply_date			= p_confirm_date,
                amount_applied  		= p_amount_applied,
                acctd_amount_applied_from 	= p_acctd_amount_applied,
                confirmed_flag  		= 'Y',
                postable        		= 'Y',
                last_update_date 		= TRUNC(SYSDATE),
                last_updated_by 		= FND_GLOBAL.user_id
  WHERE  receivable_application_id = l_receivable_application_id;

    --  call mrc to replicate the data
    ar_mrc_engine3.confirm_ra_rec_update(
                           l_receivable_application_id);

   --
   --Release 11.5 VAT changes, create the application accounting for
   --confirmed UNAPP record in ar_distributions. In this case we create
   --the UNAPP directly as only confirmed UNAPP records have accounting created
   --
    l_ae_doc_rec.document_type             := 'RECEIPT';
    l_ae_doc_rec.document_id               := p_cr_id;
    l_ae_doc_rec.accounting_entity_level   := 'ONE';
    l_ae_doc_rec.source_table              := 'RA';
    l_ae_doc_rec.source_id                 := l_receivable_application_id;  --id of UNAPP record
    l_ae_doc_rec.source_id_old             := '';
    l_ae_doc_rec.other_flag                := '';
    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);


  arp_standard.debug('arp_confirmation.modify_update_ra_rec()+');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      arp_util.debug('EXCEPTION: NO DATA FOUND, arp_confirmation.modify_update_ra_rec()');
      RAISE;

    WHEN OTHERS THEN
      arp_util.debug('EXCEPTION: arp_confirmation.modify_update_ra_rec()');
      RAISE;

END; -- modify_update_ra_rec()


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    create_matching_unapp_records					     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function creates a set of UNAPP records in ar_receivable_appl.    |
 |    to debit the unapplied account.                                        |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |      p_cr_id			- cash receipt id			     |
 |									     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    21-AUG-95	OSTEINME	created					     |
 |    04-DEC-97 KLAWRANC        Bug fix #567872.  The corresponding UNAPP row|
 |                              should not have the acct_amount_applied_to   |
 |                              populated.  This applies to the trx APP row  |
 |                              only.                                        |
 |    03/01/01  RYELURI		Bug Fix 1640890				     |
 |    03-Sep-02 Debbie Jancis   Modified for mrc trigger replacment.  Added  |
 |                              calls to ar_mrc_engine3 to  process          |
 |                              receivable apps data                         |
 +===========================================================================*/

PROCEDURE create_matching_unapp_records(
	p_cr_id		IN ar_cash_receipts.cash_receipt_id%TYPE,
        p_app_id        IN ar_receivable_applications.receivable_application_id%TYPE
			) IS

l_unapp_id   ar_receivable_applications.receivable_application_id%TYPE;
l_ae_doc_rec ae_doc_rec_type;

/* Bug Fix 1640890. Fix invloves creating the following cursor
and inserting the UNAPP record and calling the accounting package
for every record that the cursor fetches. This is necessary in the
cases where there are multiple APP records for a given cash receipt, and
in such cases the previous insert was failing with a Unique constraint
voilation on the receivable application id.
With this modification the p_app_id passed as a parameter is effectively
unncessary, and instead using the rec_app_id of the APP record from the
cursor to PAIR the UNAPP record in ar_distributions to the APP record correctly
*/

CURSOR get_rec_records IS
	SELECT	app.receivable_application_id 	app_id,
		-app.acctd_amount_applied_from	acctd_amt_app_from,
             	-app.amount_applied		amt_app,
		app.application_type		app_type,
             	app.apply_date			app_date,
             	unapp.code_combination_id	unapp_cc_id,
		app.gl_date			app_gl_date,
             	app.payment_schedule_id		app_ps_id,
             	app.set_of_books_id		app_sob,
             	app.cash_receipt_id		app_cr_id,
             	app.comments			app_comments,
             	app.days_late			app_days_late,
                app.org_id                      app_org_id
	FROM	ar_receivable_applications app,
          	ar_receivable_applications unapp
  	WHERE   app.cash_receipt_id           = p_cr_id
    	AND   	app.status||''                = 'APP'
    	AND   	app.reversal_gl_date          IS NULL
    	AND   	app.cash_receipt_id           = unapp.cash_receipt_id
    	AND   	unapp.application_rule        = '97.0'
    	AND   	unapp.status||''              = 'UNAPP';

BEGIN

  arp_standard.debug('arp_confirmation.create_matching_unapp_records()+');


  FOR 	l_unapp_rec in get_rec_records LOOP

 --Retrieve sequence id for receivable application id of UNAPP record
 --Note as this procedure creates a single UNAPP record hence this kind
 --of select from dual for sequence id is done

  SELECT ar_receivable_applications_s.nextval
  INTO   l_unapp_id
  FROM   dual;

 --Insert negative UNAPP record for confirmed APP record
  INSERT INTO ar_receivable_applications (
             receivable_application_id,
             acctd_amount_applied_from,
             amount_applied,
             application_rule,
             application_type,
             apply_date,
             code_combination_id,
             created_by,
             creation_date,
             display,
             gl_date,
             last_updated_by,
             last_update_date,
             payment_schedule_id,
             set_of_books_id,
             status,
             acctd_amount_applied_to,
             acctd_earned_discount_taken,
             acctd_unearned_discount_taken,
             applied_customer_trx_id,
             applied_customer_trx_line_id,
             applied_payment_schedule_id,
             cash_receipt_id,
             comments,
             confirmed_flag,
             customer_trx_id,
             days_late,
             earned_discount_taken,
             freight_applied,
             gl_posted_date,
             last_update_login,
             line_applied,
             on_account_customer,
             postable,
             posting_control_id,
             cash_receipt_history_id,
             program_application_id,
             program_id,
             program_update_date,
             receivables_charges_applied,
             receivables_trx_id,
             request_id,
             tax_applied,
             unearned_discount_taken,
             unearned_discount_ccid,
             earned_discount_ccid,
             ussgl_transaction_code,
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
             ussgl_transaction_code_context,
             reversal_gl_date,
             org_id
             )
  VALUES     (
	     l_unapp_id,
	     l_unapp_rec.acctd_amt_app_from,
	     l_unapp_rec.amt_app,
	     '40.4',
	     l_unapp_rec.app_type,
             l_unapp_rec.app_date,
	     l_unapp_rec.unapp_cc_id,
             FND_GLOBAL.user_id,
             TRUNC(sysdate),
	     'N',
             l_unapp_rec.app_gl_date,
             FND_GLOBAL.user_id,
             TRUNC(sysdate),
	     l_unapp_rec.app_ps_id,
	     l_unapp_rec.app_sob,
	     'UNAPP',
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     l_unapp_rec.app_cr_id,
	     l_unapp_rec.app_comments,
	     'Y',
	     NULL,
	     l_unapp_rec.app_days_late,
             NULL,
             NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     'Y',
	     -3,
             NULL,
             NULL,
             NULL,
             NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
	     NULL,
             l_unapp_rec.app_org_id );

   --  need to call mrc engine to process unapp records before calling
   --  the accting engine.

       ar_mrc_engine3.create_matching_unapp_records(
                              p_rec_app_id   => l_unapp_rec.app_id,
                              p_rec_unapp_id => l_unapp_id);
   --
   --Release 11.5 VAT changes, create the application accounting for
   --confirmed UNAPP record in ar_distributions. In this case we create
   --the UNAPP directly as only confirmed UNAPP records have accounting created
   --basically we dont require the module below to be called in update mode
   --(delete + create)

    l_ae_doc_rec.document_type             := 'RECEIPT';
    l_ae_doc_rec.document_id               := p_cr_id;
    l_ae_doc_rec.accounting_entity_level   := 'ONE';
    l_ae_doc_rec.source_table              := 'RA';
    l_ae_doc_rec.source_id                 := l_unapp_id;  --id of receivable UNAPP record
    l_ae_doc_rec.source_id_old             := l_unapp_rec.app_id; /* Bug Fix 1640890 */
    l_ae_doc_rec.other_flag                := 'PAIR';
    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

  END LOOP;

  arp_standard.debug('arp_confirmation.create_matching_unapp_records()-');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      arp_util.debug('EXCEPTION: NO DATA FOUND arp_confirmation.create_matching_unapp_records()');
      RAISE;

    WHEN OTHERS THEN
      arp_util.debug('EXCEPTION: arp_confirmation.create_matching_unapp_records()');
      RAISE;

END; -- create_matching_unapp_records()


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_receipt_clearing_ccid                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Determines the receipt clearing code combination id from the           |
 |    ar_receipt_method_accounts table.					     |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |	   p_cr_rec			- cash receipt record		     |
 |    OUT:                                                                   |
 |         p_receipt_clearing_ccid	- ccid				     |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    18-AUG-95	OSTEINME	created					     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE get_receipt_clearing_ccid(
	p_cr_rec			IN  ar_cash_receipts%ROWTYPE,
	p_receipt_clearing_ccid		OUT NOCOPY
		ar_receipt_method_accounts.receipt_clearing_ccid%TYPE
			) IS

BEGIN

  arp_standard.debug('arp_confirmation.get_receipt_clearing_ccid()+');

  SELECT rma.receipt_clearing_ccid
  INTO   p_receipt_clearing_ccid
  FROM   ar_receipt_method_accounts  rma
  WHERE  rma.remit_bank_acct_use_id = p_cr_rec.remit_bank_acct_use_id
    AND  rma.receipt_method_id  = p_cr_rec.receipt_method_id;

  arp_standard.debug('arp_confirmation.get_receipt_clearing_ccid()-');

  EXCEPTION
    WHEN OTHERS THEN
      arp_util.debug('EXCEPTION: arp_confirmation.get_receipt_clearing_ccid');
      RAISE;

END; -- get_receipt_clearing_ccid()


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_cr_history_unconfirm 					     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Creates a new entry for the cash_receipt_history table.      	     |
 |    It will have the updated receipt amount and the status                 |
 |    'APPROVED'.  Also creates an ar_distributions record for 	     	     |
 |    the new history record.						     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |									     |
 |    p_cr_rec 			- cash receipt for which the history entry   |
 |                        	  is to be created                           |
 |    p_confirm_gl_date 	- Unconfirm GL date            		     |
 |    p_confirm_date   	 	- Unconfirm Date                      	     |
 |    p_acctd_amount		- accounted cash receipt amount		     |
 |									     |
 |    OUT:                                                                   |
 |									     |
 |    p_batch_id		- batch id of cash receipt (from crh table)  |
 |    p_crh_id_rev		- crh_id of record to be reversed            |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    24-AUG-95	OSTEINME	created					     |
 |                                                                           |
 +===========================================================================*/


PROCEDURE update_cr_history_unconfirm(
	p_cr_rec		IN ar_cash_receipts%ROWTYPE,
	p_confirm_gl_date	IN DATE,
	p_confirm_date		IN DATE,
	p_acctd_amount		IN NUMBER,
	p_batch_id	       OUT NOCOPY ar_cash_receipt_history.batch_id%TYPE,
	p_crh_id_rev	       OUT NOCOPY
			ar_cash_receipt_history.cash_receipt_history_id%TYPE
			) IS

l_crh_rec_old			ar_cash_receipt_history%ROWTYPE;
l_crh_rec_prev_stat		ar_cash_receipt_history%ROWTYPE;
l_crh_rec_new			ar_cash_receipt_history%ROWTYPE;
l_dist_rec			ar_distributions%ROWTYPE;
l_dist_line_id			ar_distributions.line_id%TYPE;
l_batch_id			ar_cash_receipt_history.batch_id%TYPE;
l_crh_id_rev		ar_cash_receipt_history.cash_receipt_history_id%TYPE;
l_crh_id_new		ar_cash_receipt_history.cash_receipt_history_id%TYPE;

BEGIN

  arp_standard.debug('arp_confirmation.update_cr_history_unconfirm()+');

  -- fetch current record from ar_cash_receipt_history

  arp_cr_history_pkg.fetch_f_crid(p_cr_rec.cash_receipt_id, l_crh_rec_old);

  -- update columns in existing record

  l_crh_rec_old.reversal_gl_date 		:= p_confirm_gl_date;
  l_crh_rec_old.reversal_posting_control_id 	:= -3;
  l_crh_rec_old.reversal_created_from		:= 'ARRECNF';
  l_crh_rec_old.current_record_flag		:= NULL;
  l_crh_rec_old.first_posted_record_flag	:= 'N';
  l_crh_rec_old.current_record_flag		:= NULL;

  -- Fetch previous state record from ar_cash_receipt_history:
  -- The current record is not necessarily the one created by
  -- the confirm operation, because rate adjustments could have
  -- occured between confirmation and unconfirmation.  In order
  -- to get the correct batch_id, we have to get it from the record
  -- that is pointed to by prv_stat_cash_receipt_hist_id in the current
  -- crh record.

  arp_cr_history_pkg.fetch_p(l_crh_rec_old.prv_stat_cash_receipt_hist_id,
			     l_crh_rec_prev_stat);

  l_batch_id    := l_crh_rec_prev_stat.batch_id;
  l_crh_id_rev  := l_crh_rec_prev_stat.reversal_cash_receipt_hist_id;

  -- create new record:

  l_crh_rec_new.amount 				:= p_cr_rec.amount;
  l_crh_rec_new.acctd_amount			:= p_acctd_amount;
  l_crh_rec_new.cash_receipt_id			:= p_cr_rec.cash_receipt_id;
  l_crh_rec_new.factor_flag 			:= 'N';
  l_crh_rec_new.first_posted_record_flag	:= 'N';
  l_crh_rec_new.gl_date				:= p_confirm_gl_date;
  l_crh_rec_new.postable_flag			:= 'Y';
  l_crh_rec_new.posting_control_id		:= -3;
  l_crh_rec_new.status				:= 'APPROVED';
  l_crh_rec_new.trx_date			:= p_confirm_gl_date;
  l_crh_rec_new.acctd_factor_discount_amount	:= NULL;
  l_crh_rec_new.account_code_combination_id	:= NULL;
  l_crh_rec_new.bank_charge_account_ccid	:= NULL;
  l_crh_rec_new.batch_id			:= l_batch_id;
  l_crh_rec_new.current_record_flag		:= 'Y';
  l_crh_rec_new.exchange_date			:= p_cr_rec.exchange_date;
  l_crh_rec_new.exchange_rate			:= p_cr_rec.exchange_rate;
  l_crh_rec_new.exchange_rate_type		:= p_cr_rec.exchange_rate_type;
  l_crh_rec_new.factor_discount_amount		:= NULL;
  l_crh_rec_new.gl_posted_date			:= NULL;
  l_crh_rec_new.request_id			:= NULL;
  l_crh_rec_new.created_from			:= 'ARRECNF';
  l_crh_rec_new.prv_stat_cash_receipt_hist_id   := l_crh_rec_old.cash_receipt_history_id;

  -- insert new current record into cash receipt history table

  arp_cr_history_pkg.insert_p(l_crh_rec_new, l_crh_id_new);

  -- link new current record to previous current record and update the latter:

  l_crh_rec_old.reversal_cash_receipt_hist_id := l_crh_id_new;
  arp_cr_history_pkg.update_p(l_crh_rec_old);


  -- create ar_distributions record for new history record.
  -- first fetch record that was created for the history table
  -- record to be reversed:

  arp_distributions_pkg.fetch_pk(l_crh_id_rev,
				 'CRH',
				 'CONFIRMATION',
				 l_dist_rec);

  -- now update relevant columns:

  l_dist_rec.source_id 			:= l_crh_id_new;
  l_dist_rec.source_table		:= 'CRH';
  l_dist_rec.source_type		:= 'CONFIRMATION';
  l_dist_rec.last_update_date		:= SYSDATE;
  l_dist_rec.last_updated_by		:= FND_GLOBAL.user_id;
  l_dist_rec.creation_date		:= SYSDATE;
  l_dist_rec.created_by			:= FND_GLOBAL.user_id;

  IF  p_cr_rec.amount < 0 THEN
    l_dist_rec.amount_dr := -p_cr_rec.amount;
    l_dist_rec.amount_cr := NULL;
  ELSE
    l_dist_rec.amount_dr := NULL;
    l_dist_rec.amount_cr := p_cr_rec.amount;
  END IF;

  IF  p_acctd_amount < 0 THEN
    l_dist_rec.acctd_amount_dr := -p_acctd_amount;
    l_dist_rec.acctd_amount_cr := NULL;
  ELSE
    l_dist_rec.acctd_amount_dr := NULL;
    l_dist_rec.acctd_amount_cr := p_acctd_amount;
  END IF;

  arp_distributions_pkg.insert_p(l_dist_rec, l_dist_line_id);

        /* need to insert records into the MRC table.  Calling new
           mrc engine */

        ar_mrc_engine2.maintain_mrc_data2(
                              p_event_mode => 'INSERT',
                              p_table_name => 'AR_DISTRIBUTIONS',
                              p_mode       => 'SINGLE',
                              p_key_value  =>  l_dist_line_id,
                              p_row_info   =>  l_dist_rec);

  -- prepare return variables:

  p_batch_id   := l_batch_id;
  p_crh_id_rev := l_crh_id_rev;

  arp_standard.debug('arp_confirmation.update_cr_history_unconfirm()-');


EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION: arp_confirmation.update_cr_history_unconfirm()');
    RAISE;

END;  -- update_cr_history_unconfirm()



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    reverse_application_to_ps                        			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    reverses the effect of an application to an invoice payment schedule.  |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    01-SEP-95	OSTEINME	created					     |
 |    08-NOV-01 Debbie Jancis	Modified for mrc trigger elimination project |
 |				added calls to ar_mrc_engine for updates to  |
 |				ar_payment_schedules.	                     |
 +===========================================================================*/


PROCEDURE reverse_application_to_ps(
	p_ra_id			IN
		ar_receivable_applications.receivable_application_id%TYPE,
	p_confirm_gl_date	IN	DATE,
	p_confirm_date		IN 	DATE,
	p_batch_id		IN
		ar_payment_schedules.selected_for_receipt_batch_id%TYPE
			) IS

   l_ar_ps_key_value_list gl_ca_utility_pkg.r_key_value_arr;

BEGIN

  arp_standard.debug('arp_confirmation.reverse_application_to_ps()+');

  UPDATE
	ar_payment_schedules ps
  SET (
	status,
	gl_date_closed,
	actual_date_closed,
	amount_applied,
	amount_due_remaining,
        acctd_amount_due_remaining,
	amount_line_items_remaining,
	tax_remaining,
	freight_remaining,
        receivables_charges_remaining,
	selected_for_receipt_batch_id,
	last_updated_by,
	last_update_date,
	last_update_login) = (
     SELECT
        decode(ps2.amount_due_remaining + ra.amount_applied,0,'CL','OP'),
        decode(ps2.amount_due_remaining + ra.amount_applied,
               0,
               fnd_date.canonical_to_date(greatest(max(ra2.gl_date),
                                nvl(max(decode(adj2.status,
                                               'A',adj2.gl_date,
                                               nvl(ps2.gl_date,
                                                   ps2.trx_date))),
                                    nvl(ps2.gl_date,ps2.trx_date)),
                                nvl(ps2.gl_date, ps2.trx_date))
                       ),
              ''),
        decode(ps2.amount_due_remaining + ra.amount_applied,
               0,
               fnd_date.canonical_to_date(greatest(max(ra2.apply_date),
                                nvl(max(decode(adj2.status,
                                               'A',adj2.apply_date,
                                               ps2.trx_date)),
                                    ps2.trx_date),
                                ps2.trx_date)
                       ),
               ''),
        nvl(ps2.amount_applied,0) - ra.amount_applied,
        ps2.amount_due_remaining + ra.amount_applied,
        ps2.acctd_amount_due_remaining + nvl(ra.acctd_amount_applied_to,0),
	nvl(ps2.amount_line_items_remaining,0) + nvl(ra.line_applied,0),
	nvl(ps2.tax_remaining,0) + nvl(ra.tax_applied,0),
	nvl(ps2.freight_remaining,0) + nvl(ra.freight_applied,0),
	nvl(ps2.receivables_charges_remaining,0) +
                              nvl(ra.receivables_charges_applied,0),
	p_batch_id,
	FND_GLOBAL.user_id,
	trunc(sysdate),
	FND_GLOBAL.user_id
     FROM
	ar_receivable_applications ra,
	ar_payment_schedules ps2,
	ar_adjustments adj2,
	ar_receivable_applications ra2
     WHERE
	    ra.receivable_application_id = p_ra_id
	AND ra.applied_payment_schedule_id = ps2.payment_schedule_id
	AND ps2.payment_schedule_id =ps.payment_schedule_id
        AND ps2.payment_schedule_id = adj2.payment_schedule_id(+)
	AND ps2.payment_schedule_id = ra2.applied_payment_schedule_id
	AND nvl(ra2.confirmed_flag,'Y')= 'Y'
     GROUP BY
	ps2.payment_schedule_id,
	ra2.applied_payment_schedule_id,
	adj2.payment_schedule_id,
	ps2.amount_due_remaining,
	ra.amount_applied,
	ps2.gl_date,
	ps2.trx_date,
	ps2.amount_applied,
	ps2.acctd_amount_due_remaining,
	ra.acctd_amount_applied_to,
	ps2.amount_line_items_remaining,
	ra.line_applied,
	ps2.tax_remaining,
	ra.tax_applied,
	ps2.freight_remaining,
	ra.freight_applied,
	ps2.receivables_charges_remaining,
	ra.receivables_charges_applied)
  WHERE ps.payment_schedule_id in ( SELECT
                                          ra3.applied_payment_schedule_id
                                    FROM
                                          ar_receivable_applications ra3
                                    WHERE
                                          ra3.receivable_application_id =
                                          p_ra_id)
  RETURNING ps.payment_schedule_id
  BULK COLLECT INTO l_ar_ps_key_value_list;

  /*---------------------------------+
   | Calling central MRC library     |
   | for MRC Integration             |
   +---------------------------------*/

   ar_mrc_engine.maintain_mrc_data(
                p_event_mode        => 'UPDATE',
                p_table_name        => 'AR_PAYMENT_SCHEDULES',
                p_mode              => 'BATCH',
                p_key_value_list    => l_ar_ps_key_value_list);

  arp_standard.debug('arp_confirmation.reverse_application_to_ps()-');

  EXCEPTION
    WHEN OTHERS THEN
      arp_util.debug('EXCEPTION: arp_confirmation.reverse_application_to_ps()');
      RAISE;

END; -- reverse_application_to_ps()



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    reverse_ra_recs                                  			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function reverses existing receivable application records for     |
 |    the do_unconfirm() function.					     |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    01-SEP-95	OSTEINME	created					     |
 |    03-SEP-02 Debbie Jancis   Modified for mrc trigger replacment.         |
 |				added calls to mrc engine3 for processing    |
 |				receivable applications.		     |
 +===========================================================================*/

PROCEDURE reverse_ra_recs(
	p_cr_rec		IN	ar_cash_receipts%ROWTYPE,
	p_confirm_gl_date	IN 	DATE,
	p_confirm_date		IN 	DATE
			) IS
CURSOR get_app IS
       SELECT app.receivable_application_id old_app_id
       FROM   ar_receivable_applications app
       WHERE  app.cash_receipt_id = p_cr_rec.cash_receipt_id
       AND    app.reversal_gl_date IS NULL
       ORDER BY decode(app.status,
                       'APP'  ,1,
                       'ACC'  ,2,
                       'UNID' ,3,
                       'UNAPP',4);  --This ordering is required for pairing UNAPP with APP record

l_app_rec    get_app%ROWTYPE;
l_new_app_id ar_receivable_applications.receivable_application_id%TYPE;
l_ae_doc_rec ae_doc_rec_type;

n_new_con_data  new_con_data;  /* to store values retrieved from bulk collect */

BEGIN

  arp_standard.debug('arp_confirmation.reverse_ra_recs()+');

  FOR l_app_rec IN get_app LOOP

     --retrieve sequence
      SELECT ar_receivable_applications_s.nextval
      INTO   l_new_app_id
      FROM   dual;

     --Create actual reversing apps
      INSERT INTO ar_receivable_applications
            (receivable_application_id,
             acctd_amount_applied_from,
             amount_applied,
             application_rule,
             application_type,
             apply_date,
             code_combination_id,
             created_by,
             creation_date,
             display,
             gl_date,
             last_updated_by,
             last_update_date,
             payment_schedule_id,
             set_of_books_id,
             status,
             acctd_amount_applied_to,
             acctd_earned_discount_taken,
             acctd_unearned_discount_taken,
             applied_customer_trx_id,
             applied_customer_trx_line_id,
             applied_payment_schedule_id,
             cash_receipt_id,
             comments,
             confirmed_flag,
             customer_trx_id,
             days_late,
             earned_discount_taken,
             freight_applied,
             gl_posted_date,
             last_update_login,
             line_applied,
             on_account_customer,
             postable,
             posting_control_id,
             cash_receipt_history_id,
             program_application_id,
             program_id,
             program_update_date,
             receivables_charges_applied,
             receivables_trx_id,
             request_id,
             tax_applied,
             unearned_discount_taken,
             unearned_discount_ccid,
             earned_discount_ccid,
             ussgl_transaction_code,
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
             ussgl_transaction_code_context,
             reversal_gl_date,
             org_id
             )
             SELECT l_new_app_id,
	     -acctd_amount_applied_from,
	     -amount_applied,
	     '40.2',
	     application_type,
	     p_confirm_gl_date,
	     code_combination_id,
	     FND_GLOBAL.user_id,
	     TRUNC(SYSDATE),
	     'N',
	     p_confirm_gl_date,
	     FND_GLOBAL.user_id,
	     TRUNC(SYSDATE),
	     payment_schedule_id,
	     set_of_books_id,
	     status,
	     -acctd_amount_applied_to,
	     -acctd_earned_discount_taken,
	     -acctd_unearned_discount_taken,
	     applied_customer_trx_id,
	     applied_customer_trx_line_id,
	     applied_payment_schedule_id,
	     cash_receipt_id,
	     comments,
	     confirmed_flag,
	     customer_trx_id,
	     days_late,
	     -earned_discount_taken,
	     -freight_applied,
	     NULL,
	     last_update_login,
	     -line_applied,
	     on_account_customer,
	     postable,
	     -3,
             NULL,
	     program_application_id,
	     program_id,
	     program_update_date,
	     -receivables_charges_applied,
	     receivables_trx_id,
	     request_id,
	     -tax_applied,
	     -unearned_discount_taken,
	     unearned_discount_ccid,
	     earned_discount_ccid,
	     ussgl_transaction_code,
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
	     ussgl_transaction_code_context,
	     p_confirm_gl_date,
             org_id
       FROM  ar_receivable_applications
       WHERE receivable_application_id = l_app_rec.old_app_id;

   -- Call mrc engine to create the data in mc tables
   ar_mrc_engine3.reverse_ra_recs(
                   p_orig_app_id => l_app_rec.old_app_id,
                   p_new_app_id  => l_new_app_id);

    --apandit
    --Bug 2641517 rase business event for unapplication, we do not raise the
    --seperate unconfirm event as the unapplication takes care
    --of updating the summary tables.
   arp_standard.debug( 'before raising the business event : Raise_CR_UnApply_Event');
     AR_BUS_EVENT_COVER.Raise_CR_UnApply_Event( l_new_app_id);


   --
   --Release 11.5 VAT changes, reverse the application accounting for
   --confirmed records in ar_distributions.
   --
    l_ae_doc_rec.document_type             := 'RECEIPT';
    l_ae_doc_rec.document_id               := p_cr_rec.cash_receipt_id;
    l_ae_doc_rec.accounting_entity_level   := 'ONE';
    l_ae_doc_rec.source_table              := 'RA';
    l_ae_doc_rec.source_id                 := l_new_app_id;         --new record
    l_ae_doc_rec.source_id_old             := l_app_rec.old_app_id; --old record for reversal
    l_ae_doc_rec.other_flag                := 'REVERSE';

  --Bug 1329091 - PS is updated before Accounting Engine Call
    l_ae_doc_rec.pay_sched_upd_yn := 'Y';
    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

   END LOOP;

  -- create new unconfirmed records from old confirmed records:

  SELECT
             receivable_application_id,
             ar_receivable_applications_s.nextval,
	     acctd_amount_applied_from,
	     amount_applied,
	     DECODE(status,
                    'UNAPP', '40.0',
                    '40.3'),
	     application_type,
	     p_confirm_gl_date,
	     code_combination_id,
	     FND_GLOBAL.user_id,
	     TRUNC(SYSDATE),
             display,
	     p_confirm_gl_date,
	     FND_GLOBAL.user_id,
	     TRUNC(SYSDATE),
	     payment_schedule_id,
	     set_of_books_id,
	     status,
	     acctd_amount_applied_to,
	     DECODE(status,
                    'UNAPP', NULL,
                    acctd_earned_discount_taken),
	     DECODE(status,
                    'UNAPP', NULL,
                    acctd_unearned_discount_taken),
	     DECODE(status,
                    'UNAPP', NULL,
                    applied_customer_trx_id),
	     DECODE(status,
                    'UNAPP', NULL,
                    applied_customer_trx_line_id),
	     DECODE(status,
                    'UNAPP', NULL,
                    applied_payment_schedule_id),
	     cash_receipt_id,
	     comments,
	     'N',
	     customer_trx_id,
	     days_late,
	     DECODE(status,
                    'UNAPP', NULL,
                    earned_discount_taken),
	     DECODE(status,
                    'UNAPP', NULL,
                    freight_applied),
	     NULL,
	     last_update_login,
	     DECODE(status,
                    'UNAPP', NULL,
                    line_applied),
	     on_account_customer,
	     'N',
	     -3,
	     NULL,
	     program_application_id,
	     program_id,
	     program_update_date,
	     DECODE(status,
                    'UNAPP', NULL,
                    receivables_charges_applied),
	     receivables_trx_id,
	     request_id,
	     DECODE(status,
                    'UNAPP', NULL,
                    tax_applied),
	     DECODE(status,
                    'UNAPP', NULL,
                    unearned_discount_taken),
	     unearned_discount_ccid,
	     earned_discount_ccid,
	     ussgl_transaction_code,
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
	     ussgl_transaction_code_context,
             NULL,
             org_id
       BULK COLLECT INTO
         n_new_con_data.l_old_rec_app_id,
         n_new_con_data.l_new_rec_app_id,
         n_new_con_data.l_acctd_amount_applied_from,
         n_new_con_data.l_amount_applied,
         n_new_con_data.l_application_rule,
         n_new_con_data.l_application_type,
         n_new_con_data.l_apply_date,
         n_new_con_data.l_code_combination_id,
         n_new_con_data.l_created_by,
         n_new_con_data.l_creation_date,
         n_new_con_data.l_display,
         n_new_con_data.l_gl_date,
         n_new_con_data.l_last_updated_by,
         n_new_con_data.l_last_update_date,
         n_new_con_data.l_payment_schedule_id,
         n_new_con_data.l_set_of_books_id,
         n_new_con_data.l_status,
         n_new_con_data.l_acctd_amount_applied_to,
         n_new_con_data.l_acctd_earned_discount_tkn,
         n_new_con_data.l_acctd_unearned_discount_tkn,
         n_new_con_data.l_applied_customer_trx_id,
         n_new_con_data.l_applied_customer_trx_line_id,
         n_new_con_data.l_applied_payment_schedule_id,
         n_new_con_data.l_cash_receipt_id,
         n_new_con_data.l_comments,
         n_new_con_data.l_confirmed_flag,
         n_new_con_data.l_customer_trx_id,
         n_new_con_data.l_days_late,
         n_new_con_data.l_earned_discount_taken,
         n_new_con_data.l_freight_applied,
         n_new_con_data.l_gl_posted_date,
         n_new_con_data.l_last_update_login,
         n_new_con_data.l_line_applied,
         n_new_con_data.l_on_account_customer,
         n_new_con_data.l_postable,
         n_new_con_data.l_posting_control_id,
         n_new_con_data.l_cash_receipt_history_id,
         n_new_con_data.l_program_application_id,
         n_new_con_data.l_program_id,
         n_new_con_data.l_program_update_date,
         n_new_con_data.l_receivables_charges_applied,
         n_new_con_data.l_receivables_trx_id,
         n_new_con_data.l_request_id,
         n_new_con_data.l_tax_applied,
         n_new_con_data.l_unearned_discount_taken,
         n_new_con_data.l_unearned_discount_ccid,
         n_new_con_data.l_earned_discount_ccid,
         n_new_con_data.l_ussgl_transaction_code,
         n_new_con_data.l_attribute_category,
         n_new_con_data.l_attribute1,
         n_new_con_data.l_attribute2,
         n_new_con_data.l_attribute3,
         n_new_con_data.l_attribute4,
         n_new_con_data.l_attribute5,
         n_new_con_data.l_attribute6,
         n_new_con_data.l_attribute7,
         n_new_con_data.l_attribute8,
         n_new_con_data.l_attribute9,
         n_new_con_data.l_attribute10,
         n_new_con_data.l_attribute11,
         n_new_con_data.l_attribute12,
         n_new_con_data.l_attribute13,
         n_new_con_data.l_attribute14,
         n_new_con_data.l_attribute15,
         n_new_con_data.l_ussgl_transaction_code_cntxt,
         n_new_con_data.l_reversal_gl_date,
         n_new_con_data.l_org_id
      FROM  ar_receivable_applications
       WHERE cash_receipt_id = p_cr_rec.cash_receipt_id
       AND   (   status = 'APP'
              OR
                (     status = 'UNAPP'
                  AND application_rule in ('97.0', '40.0')
                )
             )
       AND   reversal_gl_date IS NULL;


       -- MRC trigger replacement.. Do a bulk collect and pass

  FORALL i IN 1..n_new_con_data.l_reversal_gl_date.COUNT
  INSERT INTO 	ar_receivable_applications
            (receivable_application_id,
             acctd_amount_applied_from,
             amount_applied,
             application_rule,
             application_type,
             apply_date,
             code_combination_id,
             created_by,
             creation_date,
             display,
             gl_date,
             last_updated_by,
             last_update_date,
             payment_schedule_id,
             set_of_books_id,
             status,
             acctd_amount_applied_to,
             acctd_earned_discount_taken,
             acctd_unearned_discount_taken,
             applied_customer_trx_id,
             applied_customer_trx_line_id,
             applied_payment_schedule_id,
             cash_receipt_id,
             comments,
             confirmed_flag,
             customer_trx_id,
             days_late,
             earned_discount_taken,
             freight_applied,
             gl_posted_date,
             last_update_login,
             line_applied,
             on_account_customer,
             postable,
             posting_control_id,
             cash_receipt_history_id,
             program_application_id,
             program_id,
             program_update_date,
             receivables_charges_applied,
             receivables_trx_id,
             request_id,
             tax_applied,
             unearned_discount_taken,
             unearned_discount_ccid,
             earned_discount_ccid,
             ussgl_transaction_code,
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
             ussgl_transaction_code_context,
             reversal_gl_date,
             org_id
             )
        VALUES (
         n_new_con_data.l_new_rec_app_id(i),
         n_new_con_data.l_acctd_amount_applied_from(i),
         n_new_con_data.l_amount_applied(i),
         n_new_con_data.l_application_rule(i),
         n_new_con_data.l_application_type(i),
         n_new_con_data.l_apply_date(i),
         n_new_con_data.l_code_combination_id(i),
         n_new_con_data.l_created_by(i),
         n_new_con_data.l_creation_date(i),
         n_new_con_data.l_display(i),
         n_new_con_data.l_gl_date(i),
         n_new_con_data.l_last_updated_by(i),
         n_new_con_data.l_last_update_date(i),
         n_new_con_data.l_payment_schedule_id(i),
         n_new_con_data.l_set_of_books_id(i),
         n_new_con_data.l_status(i),
         n_new_con_data.l_acctd_amount_applied_to(i),
         n_new_con_data.l_acctd_earned_discount_tkn(i),
         n_new_con_data.l_acctd_unearned_discount_tkn(i),
         n_new_con_data.l_applied_customer_trx_id(i),
         n_new_con_data.l_applied_customer_trx_line_id(i),
         n_new_con_data.l_applied_payment_schedule_id(i),
         n_new_con_data.l_cash_receipt_id(i),
         n_new_con_data.l_comments(i),
         n_new_con_data.l_confirmed_flag(i),
         n_new_con_data.l_customer_trx_id(i),
         n_new_con_data.l_days_late(i),
         n_new_con_data.l_earned_discount_taken(i),
         n_new_con_data.l_freight_applied(i),
         n_new_con_data.l_gl_posted_date(i),
         n_new_con_data.l_last_update_login(i),
         n_new_con_data.l_line_applied(i),
         n_new_con_data.l_on_account_customer(i),
         n_new_con_data.l_postable(i),
         n_new_con_data.l_posting_control_id(i),
         n_new_con_data.l_cash_receipt_history_id(i),
         n_new_con_data.l_program_application_id(i),
         n_new_con_data.l_program_id(i),
         n_new_con_data.l_program_update_date(i),
         n_new_con_data.l_receivables_charges_applied(i),
         n_new_con_data.l_receivables_trx_id(i),
         n_new_con_data.l_request_id(i),
         n_new_con_data.l_tax_applied(i),
         n_new_con_data.l_unearned_discount_taken(i),
         n_new_con_data.l_unearned_discount_ccid(i),
         n_new_con_data.l_earned_discount_ccid(i),
         n_new_con_data.l_ussgl_transaction_code(i),
         n_new_con_data.l_attribute_category(i),
         n_new_con_data.l_attribute1(i),
         n_new_con_data.l_attribute2(i),
         n_new_con_data.l_attribute3(i),
         n_new_con_data.l_attribute4(i),
         n_new_con_data.l_attribute5(i),
         n_new_con_data.l_attribute6(i),
         n_new_con_data.l_attribute7(i),
         n_new_con_data.l_attribute8(i),
         n_new_con_data.l_attribute9(i),
         n_new_con_data.l_attribute10(i),
         n_new_con_data.l_attribute11(i),
         n_new_con_data.l_attribute12(i),
         n_new_con_data.l_attribute13(i),
         n_new_con_data.l_attribute14(i),
         n_new_con_data.l_attribute15(i),
         n_new_con_data.l_ussgl_transaction_code_cntxt(i),
         n_new_con_data.l_reversal_gl_date(i),
         n_new_con_data.l_org_id(i)
               );

       --  Call mrc routine..
       ar_mrc_engine3.confirm_ra_rec_create(n_new_con_data);


       --In this case the accounting routine Create_Acct_Entry is not
       --called because new
       --records are unconfirmed

       -- mark all old records as reversed

       UPDATE ar_receivable_applications
       SET   reversal_gl_date  = p_confirm_gl_date,
              display          = 'N',
              last_update_date = TRUNC(SYSDATE),
              last_updated_by  = FND_GLOBAL.user_id
       WHERE cash_receipt_id   = p_cr_rec.cash_receipt_id
       AND   nvl(confirmed_flag,'Y') = 'Y'
       AND   reversal_gl_date IS NULL;

  arp_standard.debug('arp_confirmation.reverse_ra_recs()-');

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    arp_util.debug('EXCEPTION: NO DATA FOUND, arp_confirmation.do_confirm()');
    RAISE;

    WHEN OTHERS THEN
      arp_util.debug('EXCEPTION: arp_confirmation.do_confirm()');
      RAISE;

END; -- reverse_ra_recs()



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    unconfirm_update_ps_rec						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function updates the payment schedule record for a cash receipt   |
 |    after all applications have been processed.  It basically sets the     |
 |    amount_due_remaining, the amount_due_original, and the                 |
 |    receipt_confirmed_flag to 'N'.                                         |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |      p_cr_rec		receipt record				     |
 |      p_closed_date		closed date				     |
 |      p_closed_gl_date        closed gl date                               |
 |									     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    01-SEP-95	OSTEINME	created					     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE unconfirm_update_ps_rec(
		p_cr_rec		ar_cash_receipts%ROWTYPE,
		p_closed_date		DATE,
		p_closed_gl_date	DATE
			) IS

l_receipt_ps_rec		ar_payment_schedules%ROWTYPE;
l_dummy				NUMBER;

BEGIN

  arp_standard.debug('arp_confirmation.unconfirm_update_ps_rec()+');
  -- Fetch receipt's payment schedule record:

  SELECT 	*
  INTO 		l_receipt_ps_rec
  FROM		ar_payment_schedules
  WHERE 	cash_receipt_id = p_cr_rec.cash_receipt_id;


  -- set confirmed flag to 'N' to mark receipt as unconfirmed:

  l_receipt_ps_rec.receipt_confirmed_flag := 'N';


  -- call utility handler routine to update payment schedule record:

  arp_ps_util.update_receipt_related_columns(
			NULL,			-- no payment_schedule_id!
			-p_cr_rec.amount,
			p_closed_date,
			p_closed_gl_date,
			l_dummy,
			l_receipt_ps_rec);

  arp_standard.debug('arp_confirmation.unconfirm_update_ps_rec()-');

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    arp_util.debug('EXCEPTION: NO DATA FOUND, arp_confirmation.unconfirm_update_ps_rec()');
    RAISE;

  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION: arp_confirmation.unconfirm_update_ps_rec()');
    RAISE;

END; -- unconfirm_update_ps_rec()


/*===========================================================================+
 | PROCEDURE                                                                 |
 |     validate_in_parameters                          			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This function validates the correctness of the IN parameters for the  |
 |     confirm() and unconfirm() functions of the confirmation entity        |
 |     handler.                                                              |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |        p_cr_id			Cash receipt id			     |
 |        p_confirm_gl_date		Confirmation gl date                 |
 |        p_confirm_date                Confirmation date                    |
 |        p_module_name                 Module name                          |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS:								     |
 |    <none>								     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    28-AUG-95	OSTEINME	created					     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE validate_in_parameters(
		p_cr_id		    IN 	ar_cash_receipts.cash_receipt_id%TYPE,
		p_confirm_gl_date   IN	DATE,
		p_confirm_date	    IN  DATE,
		p_module_name	    IN  VARCHAR2
			) IS

BEGIN

  arp_standard.debug('arp_confirmation.validate_in_parameters()+');

  -- make sure none of the arguments is NULL:

  IF (p_cr_id IS NULL) THEN
    arp_standard.debug('p_cr_id is NULL');
    FND_MESSAGE.set_name('AR','AR_ARGUEMENTS_FAIL');
    APP_EXCEPTION.raise_exception;
  END IF;

  IF (p_confirm_gl_date IS NULL) THEN
    arp_standard.debug('p_confirm_gl_date is NULL');
    FND_MESSAGE.set_name('AR','AR_ARGUEMENTS_FAIL');
    APP_EXCEPTION.raise_exception;
  END IF;

  IF (p_confirm_date IS NULL) THEN
    arp_standard.debug('p_confirm_date is NULL');
    FND_MESSAGE.set_name('AR','AR_ARGUEMENTS_FAIL');
    APP_EXCEPTION.raise_exception;
  END IF;

  -- ???? validate dates any further ????

  arp_standard.debug('arp_confirmation.validate_in_parameters()-');

  EXCEPTION
    WHEN OTHERS THEN
      arp_standard.debug('EXCEPTION: arp_confirmation.validate_in_parameters');
      RAISE;

END; -- validate_in_parameters()


/*===========================================================================+
 | PROCEDURE                                                                 |
 |     get_application_flags                          			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This procedure determines the application flags needed to validate    |
 |     an application.							     |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |      p_cust_trx_type_id		cust_trx_type_id from 		     |
 |					ar_payment_schedule of invoice       |
 |    OUT:                                                                   |
 |      p_ao_flag			allow overapplication		     |
 |      p_nao_flag			natural application only	     |
 |      p_creation_sign							     |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    29-AUG-95	OSTEINME	created					     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE get_application_flags(
	p_cust_trx_type_id  IN  ra_cust_trx_types.cust_trx_type_id%TYPE,
	p_ao_flag    OUT NOCOPY ra_cust_trx_types.allow_overapplication_flag%TYPE,
	p_nao_flag   OUT NOCOPY ra_cust_trx_types.natural_application_only_flag%TYPE,
        p_creation_sign OUT NOCOPY ra_cust_trx_types.creation_sign%TYPE) IS

BEGIN

  SELECT	allow_overapplication_flag,
        	natural_application_only_flag,
		creation_sign
  INTO		p_ao_flag,
		p_nao_flag,
		p_creation_sign
  FROM 		ra_cust_trx_types
  WHERE		cust_trx_type_id = p_cust_trx_type_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    arp_util.debug('EXCEPTION: NO DATA FOUND, arp_confirmation.get_application_flags()');
    RAISE;

  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION: arp_confirmation.get_application_flags()');
    RAISE;

END; -- get_application_flags()


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    handle_max_dates                                			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function updates the MaxDatesType datastructure passed in.	     |
 |									     |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:								     |
 |      p_max_dates		MaxDatesType datastructure to be updated     |
 |      p_gl_date		GL date					     |
 |      p_apply_date		Apply date				     |
 |	p_confirm_date		Confirm Date				     |
 |      p_confirm_gl_date	Confirm GL Date				     |
 |									     |
 |    OUT:                                                                   |
 |                                                                           |
 | RETURNS    		                                                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    30-AUG-95	OSTEINME	created					     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE handle_max_dates(
	p_max_dates		IN OUT NOCOPY MaxDatesType,
	p_gl_date		IN DATE,
	p_apply_date		IN DATE,
	p_confirm_date		IN DATE,
	p_confirm_gl_date	IN DATE
			) IS

BEGIN

  p_max_dates.max_gl_date 		:= GREATEST(p_max_dates.max_gl_date,
				 		    p_gl_date);
  p_max_dates.max_ra_gl_date		:= GREATEST(p_confirm_gl_date,
						    p_gl_date);
  p_max_dates.max_ra_apply_date		:= GREATEST(p_confirm_date,
						    p_apply_date);
  p_max_dates.max_trx_date	  	:= GREATEST(p_max_dates.max_trx_date,
					 	    p_apply_date);
END; -- handle_max_dates()

END ARP_CONFIRMATION;

/
