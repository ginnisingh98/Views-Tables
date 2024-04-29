--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_MISC_RECEIPTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_MISC_RECEIPTS" AS
/* $Header: ARREMTRB.pls 120.20 2007/01/04 15:12:44 mraymond ship $ */
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/* declare subtype for VAT changes */
SUBTYPE l_ae_doc_rec_type IS arp_acct_main.ae_doc_rec_type ;
--

/* ---------------------- Public functions -------------------------------- */

FUNCTION revision RETURN VARCHAR2 IS
BEGIN

   RETURN '$Revision: 120.20 $';

END revision;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_misc_receipt                              			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Entity handler that updates miscelleanous transactions.		     |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    09-OCT-95	OSTEINME	created					     |
 |    13-NOV-96	 OSTEINME	added parameter anticipated_clearing_date    |
 |				for CE enhancement.			     |
 |				NOTE: This version of the file is not longer |
 |				compatible with 10.6 and prod15!	     |
 |    30-DEC-96 OSTEINME	added global descriptive flexfield parameters|
 |    04-DEC-97 KLAWRANC        Bug #590256.  Modified call to               |
 |                              calc_acctd_amount.  Now passes NULL for the  |
 |                              currency code parameter, therefore the acctd |
 |                              amount will be calculated based on the       |
 |                              functional currency.                         |
 |    04-FEB-98 KLAWRANC        Bug #546677.  Added check for amount change  |
 |                              before updating distributions table.         |
 |    21-MAY-98 KTANG           For all calls to calc_acctd_amount which     |
 |                              calculates header accounted amounts, if the  |
 |                              exchange_rate_type is not user, call         |
 |                              gl_currency_api.convert_amount instead. This |
 |                              is for triangulation.                        |
 |    26-JUL-99 GJWANG		Do not call accounting routine for update if |
 |                              misc rec has been posted		     |
 |    26-AUG-99 GJWANG		Bug 923425: check posting only on the current|
 |				cash receipt history  			     |
 |    09-MAY-02 RKADER          Bug #2322468. Rate adjustment fail when      |
 |                              rate type is changed from 'User' to another  |
 |                              rate type.                                   |
 |    26-SEP-02 RKADER          Bug #2561342: The GL date should not be      |
 |                              updated for the history record while a Misc  |
 |                              receipt is updated
 |    14-OCT-04 JBECKETT	Bug 3911642: Check for unposted entries      |
 |				is on ar_misc_cash_distributions not         |
 |				ar_cash_receipt_history as rows from the     |
 |				former are deleted/recreated.                |
 |    20-MAY-05 JBECKETT	Added p_legal_entity_id for R12 LE uptake    |
 +===========================================================================*/


PROCEDURE update_misc_receipt(
	p_cash_receipt_id	IN NUMBER,
	p_batch_id		IN NUMBER,
	p_currency_code		IN VARCHAR2,
	p_amount		IN NUMBER,
	p_receivables_trx_id	IN NUMBER,
	p_misc_payment_source	IN VARCHAR2,
	p_receipt_number	IN VARCHAR2,
	p_receipt_date		IN DATE,
	p_gl_date		IN DATE,
	p_comments		IN VARCHAR2,
	p_exchange_rate_type	IN VARCHAR2,
	p_exchange_rate		IN NUMBER,
	p_exchange_date		IN DATE,
	p_attribute_category	IN VARCHAR2,
	p_attribute1		IN VARCHAR2,
	p_attribute2		IN VARCHAR2,
	p_attribute3		IN VARCHAR2,
	p_attribute4		IN VARCHAR2,
	p_attribute5		IN VARCHAR2,
	p_attribute6		IN VARCHAR2,
	p_attribute7		IN VARCHAR2,
	p_attribute8		IN VARCHAR2,
	p_attribute9		IN VARCHAR2,
	p_attribute10		IN VARCHAR2,
	p_attribute11		IN VARCHAR2,
	p_attribute12		IN VARCHAR2,
	p_attribute13		IN VARCHAR2,
	p_attribute14		IN VARCHAR2,
	p_attribute15		IN VARCHAR2,
	p_remittance_bank_account_id  IN NUMBER,
	p_deposit_date		      IN DATE,
	p_receipt_method_id	      IN NUMBER,
	p_doc_sequence_value	      IN NUMBER,
	p_doc_sequence_id	      IN NUMBER,
	p_distribution_set_id	IN NUMBER,
	p_reference_type	IN VARCHAR2,
	p_reference_id		IN NUMBER,
	p_vat_tax_id		IN NUMBER,
        p_ussgl_transaction_code IN VARCHAR2,
-- ******* Rate Adjustment parameters: ********
	p_rate_adjust_gl_date	      IN DATE,
	p_new_exchange_date	      IN DATE,
	p_new_exchange_rate	      IN NUMBER,
	p_new_exchange_rate_type      IN VARCHAR2,
	p_gain_loss		      IN NUMBER,
	p_exchange_rate_attr_cat      IN VARCHAR2,
 	p_exchange_rate_attr1	      IN VARCHAR2,
 	p_exchange_rate_attr2	      IN VARCHAR2,
 	p_exchange_rate_attr3	      IN VARCHAR2,
 	p_exchange_rate_attr4	      IN VARCHAR2,
 	p_exchange_rate_attr5	      IN VARCHAR2,
 	p_exchange_rate_attr6	      IN VARCHAR2,
 	p_exchange_rate_attr7	      IN VARCHAR2,
 	p_exchange_rate_attr8	      IN VARCHAR2,
 	p_exchange_rate_attr9	      IN VARCHAR2,
 	p_exchange_rate_attr10	      IN VARCHAR2,
 	p_exchange_rate_attr11	      IN VARCHAR2,
 	p_exchange_rate_attr12	      IN VARCHAR2,
 	p_exchange_rate_attr13	      IN VARCHAR2,
 	p_exchange_rate_attr14	      IN VARCHAR2,
 	p_exchange_rate_attr15	      IN VARCHAR2,
--
-- ********* Reversal Info ***********
--
	p_reversal_date		IN DATE,
	p_reversal_gl_date	IN DATE,
	p_reversal_category	IN VARCHAR2,
	p_reversal_comments	IN VARCHAR2,
	p_reversal_reason_code  IN VARCHAR2,
--
-- ********* CashBook Expected Date (new in 10.7) ******
--
        p_anticipated_clearing_date IN DATE,
--
-- ******* Global Flexfield parameters *******
--
	p_global_attribute1		IN VARCHAR2,
	p_global_attribute2		IN VARCHAR2,
	p_global_attribute3		IN VARCHAR2,
	p_global_attribute4		IN VARCHAR2,
	p_global_attribute5		IN VARCHAR2,
	p_global_attribute6		IN VARCHAR2,
	p_global_attribute7		IN VARCHAR2,
	p_global_attribute8		IN VARCHAR2,
	p_global_attribute9		IN VARCHAR2,
	p_global_attribute10		IN VARCHAR2,
	p_global_attribute11		IN VARCHAR2,
	p_global_attribute12		IN VARCHAR2,
	p_global_attribute13		IN VARCHAR2,
	p_global_attribute14		IN VARCHAR2,
	p_global_attribute15		IN VARCHAR2,
	p_global_attribute16		IN VARCHAR2,
	p_global_attribute17		IN VARCHAR2,
	p_global_attribute18		IN VARCHAR2,
	p_global_attribute19		IN VARCHAR2,
	p_global_attribute20		IN VARCHAR2,
	p_global_attribute_category	IN VARCHAR2,
--
--
--
-- ******* Receipt State/Status Return information ******
--
	p_new_state		OUT NOCOPY VARCHAR2,
	p_new_state_dsp		OUT NOCOPY VARCHAR2,
	p_new_status		OUT NOCOPY VARCHAR2,
	p_new_status_dsp	OUT NOCOPY VARCHAR2,
--
	p_form_name		IN  varchar2,
	p_form_version		IN  varchar2,
        p_tax_rate		IN NUMBER,
        p_gl_tax_acct           IN  VARCHAR2, /* Bug fix 2300268 */
	p_legal_entity_id       IN  NUMBER ) IS

l_cr_rec		ar_cash_receipts%ROWTYPE;
l_crh_rec		ar_cash_receipt_history%ROWTYPE;
l_dist_rec		ar_distributions%ROWTYPE;
l_acctd_amount		ar_cash_receipt_history.acctd_amount%TYPE;
l_ccid			ar_cash_receipt_history.account_code_combination_id%TYPE;
l_override_dummy	ar_cash_receipts.override_remit_account_flag%TYPE;
l_dummy			NUMBER;
l_source_type		ar_distributions.source_type%TYPE;
l_creation_status	ar_cash_receipt_history.status%TYPE;
l_old_distribution_set_id  ar_cash_receipts.distribution_set_id%TYPE;
l_dist_set_changed_flag BOOLEAN;
l_amount_changed_flag   BOOLEAN;
l_gl_date_changed_flag  BOOLEAN;
l_receipt_date_changed_flag  BOOLEAN;
l_old_receivables_trx_id	ar_receivables_trx.receivables_trx_id%TYPE;
l_rev_crh_id		ar_cash_receipt_history.cash_receipt_history_id%TYPE;
l_ae_doc_rec            l_ae_doc_rec_type;
l_posted		ar_cash_receipt_history.posting_control_id%TYPE;
l_unposted_count	NUMBER;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug('arp_process_misc_receipts.update_misc_receipt()+');
     arp_debug.debug('update_misc_receipt: ' || '*****TAX RATE  ' || TO_CHAR(p_tax_rate));
  END IF;

  -- fetch and lock existing records from database for update

  l_cr_rec.cash_receipt_id 	:= p_cash_receipt_id;
  arp_cash_receipts_pkg.nowaitlock_fetch_p(l_cr_rec);

  -- store old distribution_set_id and receivables_trx_id to allow
  -- for creation of new distribution records if necessary

  l_old_distribution_set_id := l_cr_rec.distribution_set_id;
  l_old_receivables_trx_id  := l_cr_rec.receivables_trx_id;

  -- determine if amount or acctd amount have changed:

  IF (l_cr_rec.amount <> p_amount) THEN
      l_amount_changed_flag := TRUE;
  ELSE
      l_amount_changed_flag := FALSE;
  END IF;

  -- determine if receipt date has changed:

  IF (l_cr_rec.receipt_date     <> p_receipt_date) THEN
     l_receipt_date_changed_flag := TRUE;
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_debug.debug( 'Receipt Date has changed.  Old: ' || to_char(l_cr_rec.receipt_date, 'DD-MON-YYYY') || ' New: ' || to_char(p_receipt_date));
     END IF;
  ELSE
     l_receipt_date_changed_flag := FALSE;
  END IF;

  -- get history record:

  l_crh_rec.cash_receipt_id	:= p_cash_receipt_id;
  arp_cr_history_pkg.nowaitlock_fetch_f_cr_id(l_crh_rec);

  -- determine if gl date was changed:

  IF (l_crh_rec.gl_date		<> p_gl_date) THEN
     l_gl_date_changed_flag := TRUE;
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_debug.debug( 'GL Date has changed.  Old: ' || to_char(l_crh_rec.gl_date, 'DD-MON-YYYY') || ' New: ' || to_char(p_gl_date));
     END IF;

  ELSE
     l_gl_date_changed_flag := FALSE;
  END IF;

  -- get context info based on payment method and remittance bank id


  arp_cr_util.get_creation_info(p_receipt_method_id,
				p_remittance_bank_account_id,
	      			l_creation_status,
				l_source_type,
				l_ccid,
				l_override_dummy);

  -- calculate accounted amount
  -- Changes for triangulation: If exchange rate type is not user, call
  -- GL API to calculate accounted amount
  /* Bug 2322468 : Added the OR condition*/
  IF (p_exchange_rate_type = 'User') OR
      (l_cr_rec.exchange_rate_type = 'User') THEN
    arp_util.calc_acctd_amount(	NULL,
				NULL,
				NULL,
				l_cr_rec.exchange_rate,
				'+',
				p_amount,
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
			p_amount);
  END IF;

  -- update cash receipt record:
IF PG_DEBUG in ('Y', 'C') THEN
   arp_debug.debug('*****BEGIN UPDATE cash_receipt_record ');
END IF;

  l_cr_rec.amount 		:= p_amount;
  l_cr_rec.receivables_trx_id	:= p_receivables_trx_id;
  l_cr_rec.misc_payment_source  := p_misc_payment_source;
  l_cr_rec.receipt_number	:= p_receipt_number;
  l_cr_rec.receipt_date		:= p_receipt_date;
  l_cr_rec.comments 		:= p_comments;
  l_cr_rec.attribute_category	:= p_attribute_category;
  l_cr_rec.attribute1 		:= p_attribute1;
  l_cr_rec.attribute2 		:= p_attribute2;
  l_cr_rec.attribute3 		:= p_attribute3;
  l_cr_rec.attribute4 		:= p_attribute4;
  l_cr_rec.attribute5 		:= p_attribute5;
  l_cr_rec.attribute6 		:= p_attribute6;
  l_cr_rec.attribute7 		:= p_attribute7;
  l_cr_rec.attribute8 		:= p_attribute8;
  l_cr_rec.attribute9 		:= p_attribute9;
  l_cr_rec.attribute10 		:= p_attribute10;
  l_cr_rec.attribute11 		:= p_attribute11;
  l_cr_rec.attribute12 		:= p_attribute12;
  l_cr_rec.attribute13 		:= p_attribute13;
  l_cr_rec.attribute14 		:= p_attribute14;
  l_cr_rec.attribute15 		:= p_attribute15;
  l_cr_rec.remit_bank_acct_use_id := p_remittance_bank_account_id;
  l_cr_rec.deposit_date		:= p_deposit_date;
  l_cr_rec.distribution_set_id  := p_distribution_set_id;
  l_cr_rec.reference_id		:= p_reference_id;
  l_cr_rec.reference_type	:= p_reference_type;
  l_cr_rec.vat_tax_id		:= p_vat_tax_id;
  l_cr_rec.ussgl_transaction_code := p_ussgl_transaction_code;
--VAT change begin: update tax_rate when tax_treatment changed
  l_cr_rec.tax_rate             := p_tax_rate;
--VAT change end:
  l_cr_rec.anticipated_clearing_date := p_anticipated_clearing_date;

  l_cr_rec.global_attribute1	:= p_global_attribute1;
  l_cr_rec.global_attribute2	:= p_global_attribute2;
  l_cr_rec.global_attribute3	:= p_global_attribute3;
  l_cr_rec.global_attribute4	:= p_global_attribute4;
  l_cr_rec.global_attribute5	:= p_global_attribute5;
  l_cr_rec.global_attribute6	:= p_global_attribute6;
  l_cr_rec.global_attribute7	:= p_global_attribute7;
  l_cr_rec.global_attribute8	:= p_global_attribute8;
  l_cr_rec.global_attribute9	:= p_global_attribute9;
  l_cr_rec.global_attribute10	:= p_global_attribute10;
  l_cr_rec.global_attribute11	:= p_global_attribute11;
  l_cr_rec.global_attribute12	:= p_global_attribute12;
  l_cr_rec.global_attribute13	:= p_global_attribute13;
  l_cr_rec.global_attribute14	:= p_global_attribute14;
  l_cr_rec.global_attribute15	:= p_global_attribute15;
  l_cr_rec.global_attribute16	:= p_global_attribute16;
  l_cr_rec.global_attribute17	:= p_global_attribute17;
  l_cr_rec.global_attribute18	:= p_global_attribute18;
  l_cr_rec.global_attribute19	:= p_global_attribute19;
  l_cr_rec.global_attribute20	:= p_global_attribute20;
  l_cr_rec.global_attribute_category	:= p_global_attribute_category;
  l_cr_rec.legal_entity_id      := p_legal_entity_id;
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_debug.debug(' *********AFTER UPDATE CR record: tax_rate' || TO_CHAR(l_cr_rec.tax_rate));
 END IF;
  arp_cash_receipts_pkg.update_p(l_cr_rec);


  -- update cash receipt history record:

  l_crh_rec.amount			:= p_amount;
  l_crh_rec.acctd_amount		:= l_acctd_amount;
  /* Bug fix 2561342
     The GL Date of the current record should not be updated in the
     CRH table. Commented out NOCOPY the following line.
  l_crh_rec.gl_date                     := p_gl_date; */
  l_crh_rec.trx_date			:= p_receipt_date;
  l_crh_rec.account_code_combination_id := l_ccid;

  arp_cr_history_pkg.update_p(l_crh_rec);


  -- update distributions table
  -- Will only want to do this if the amount of the receipt
  -- has changed.  Update of the amount is not permitted
  -- if the receipt has changed states, is posted etc.

  IF l_amount_changed_flag THEN

     /* Bug 1301583 : lock ar_distribution row only if an update
        needs to be done

        Bug 1494541 : lock the row before setting new values for
        l_dist_rec fields
     */

     arp_distributions_pkg.nowaitlock_fetch_pk(
                                l_crh_rec.cash_receipt_history_id,
                                'CRH',
                                l_source_type,
                                l_dist_rec);

     l_dist_rec.code_combination_id:= l_ccid;

     IF (p_amount < 0) THEN
       l_dist_rec.amount_dr := NULL;
       l_dist_rec.amount_cr := - p_amount;
     ELSE
       l_dist_rec.amount_dr := p_amount;
       l_dist_rec.amount_cr := NULL;
     END IF;

     IF (l_acctd_amount < 0) THEN
       l_dist_rec.acctd_amount_dr := NULL;
       l_dist_rec.acctd_amount_cr := - l_acctd_amount;
     ELSE
       l_dist_rec.acctd_amount_dr := l_acctd_amount;
       l_dist_rec.acctd_amount_cr := NULL;
     END IF;

     arp_distributions_pkg.update_p(l_dist_rec);

    /* need to insert records into the MRC table.  Calling new
       mrc engine */

      ar_mrc_engine2.maintain_mrc_data2(
                              p_event_mode => 'UPDATE',
                              p_table_name => 'AR_DISTRIBUTIONS',
                              p_mode       => 'SINGLE',
                              p_key_value  =>  l_dist_rec.line_id,
                              p_row_info   =>  l_dist_rec);

  END IF;

  -- update misc distribution records if necessary
  /* Bugfix 2753644. Passed p_gl_tax_acct as parameter to the
     procedure update_misc_dist */

  arp_proc_rct_util.update_misc_dist(
			p_cash_receipt_id,
			p_amount,
			l_acctd_amount,
			l_amount_changed_flag,
			p_distribution_set_id,
			p_receivables_trx_id,
			l_old_distribution_set_id,
			l_old_receivables_trx_id,
			p_gl_date,
			l_gl_date_changed_flag,
			p_currency_code,
			p_exchange_rate,
			p_receipt_date,
   			l_receipt_date_changed_flag,
			p_gl_tax_acct);

  -- Check if Misc Receipt has been posted before calling accounting entry library
  /* Bug 3911642 - check for unposted rows should be in
     ar_misc_cash_distributions as it is this accounting that is deleted/
     recreated. */
  SELECT count(*)
  INTO   l_unposted_count
  FROM   ar_misc_cash_distributions
  WHERE  cash_receipt_id = p_cash_receipt_id
  AND    posting_control_id = -3
  AND    reversal_gl_date IS NULL;

  -- 941243 Do not call accounting routine if receipt amount has changed (it
  -- has already done in update_misc_dist

  IF ( (l_unposted_count > 0) AND  (l_amount_changed_flag = FALSE) ) THEN

      -- Do not call accounting routine if receipt is 0 and needs to
      -- be reversed as there are no accouting entries when receipt is
      -- 0

      IF ((p_reversal_date IS NULL) AND (p_amount <> 0) )  THEN

      -- Call accounting entry library begins
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_debug.debug(  'Update Misc Cash Receipt start () +');
      END IF;

      l_ae_doc_rec.document_type           := 'RECEIPT';
      l_ae_doc_rec.document_id             := l_cr_rec.cash_receipt_id;
      l_ae_doc_rec.accounting_entity_level := 'ONE';
      l_ae_doc_rec.source_table            := 'MCD';
      l_ae_doc_rec.source_id               := '';
      l_ae_doc_rec.gl_tax_acct             := p_gl_tax_acct; /* Bug fix 2300268 */

      -- calling accounting entry library

      arp_acct_main.Delete_Acct_Entry(l_ae_doc_rec);
      arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_debug.debug(  'Update Misc Cash Receipt start () -');
      END IF;
      END IF;
  END IF;

  -- check if receipt needs to be rate-adjusted:

  IF (p_rate_adjust_gl_date IS NOT NULL) THEN
    arp_proc_rct_util.rate_adjust(
		p_cash_receipt_id,
		p_rate_adjust_gl_date,
		p_new_exchange_date,
		p_new_exchange_rate,
		p_new_exchange_rate_type,
		l_cr_rec.exchange_date,
		l_cr_rec.exchange_rate,
		l_cr_rec.exchange_rate_type,
		p_gain_loss,
		p_exchange_rate_attr_cat,
 		p_exchange_rate_attr1,
 		p_exchange_rate_attr2,
 		p_exchange_rate_attr3,
 		p_exchange_rate_attr4,
 		p_exchange_rate_attr5,
 		p_exchange_rate_attr6,
 		p_exchange_rate_attr7,
 		p_exchange_rate_attr8,
 		p_exchange_rate_attr9,
 		p_exchange_rate_attr10,
 		p_exchange_rate_attr11,
		p_exchange_rate_attr12,
 		p_exchange_rate_attr13,
 		p_exchange_rate_attr14,
 		p_exchange_rate_attr15);
  END IF;

  -- check if receipt needs to be reversed:

  IF (p_reversal_date IS NOT NULL AND
      l_cr_rec.reversal_date IS NULL) THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'Regular Reversal required.');
    END IF;

    arp_reverse_receipt.reverse(
		l_cr_rec.cash_receipt_id,
		p_reversal_category,
		p_reversal_gl_date,
		p_reversal_date,
		p_reversal_reason_code,
		p_reversal_comments,
		NULL,			-- clear_batch_id
		p_attribute_category,
		p_attribute1,
		p_attribute2,
		p_attribute3,
		p_attribute4,
		p_attribute5,
		p_attribute6,
		p_attribute7,
		p_attribute8,
		p_attribute9,
		p_attribute10,
		p_attribute11,
		p_attribute12,
		p_attribute13,
		p_attribute14,
		p_attribute15,
		p_form_name,
		p_form_version,
		l_rev_crh_id);
--
-- VAT: reversal is done in ARREREVB.pls: arp_reverse_receipt.reverse

  END IF;


  -- update batch status

  IF (p_batch_id IS NOT NULL) THEN
    arp_rw_batches_check_pkg.update_batch_status(
		p_batch_id);
  END IF;

  -- determine receipt's new state and status and return it to form:
  -- Bug no 968903 SRAJASEK   Modified the sql statement to retrieve the data
  -- from the base tables rather than the ar_cash_receipt_v view for
  -- performance reasons

/*  SELECT receipt_status,
	 receipt_status_dsp,
	 state,
	 state_dsp
  INTO   p_new_status,
	 p_new_status_dsp,
	 p_new_state,
	 p_new_state_dsp
  FROM   AR_CASH_RECEIPTS_V
  WHERE  cash_receipt_id = p_cash_receipt_id;   */

  SELECT cr.status,
         l_cr_status.meaning,
         crh_current.status ,
         l_crh_status.meaning
  INTO   p_new_status,
         p_new_status_dsp,
         p_new_state,
         p_new_state_dsp
  FROM
        ar_cash_receipt_history crh_current,
        ar_cash_receipts        cr,
        ar_lookups              l_cr_status,
        ar_lookups              l_crh_status
  WHERE
        cr.cash_receipt_id = p_cash_receipt_id
  AND   l_cr_status.lookup_type = 'CHECK_STATUS'
  AND   l_cr_status.lookup_code = cr.status
  AND   l_crh_status.lookup_type = 'RECEIPT_CREATION_STATUS'
  AND   l_crh_status.lookup_code = crh_current.status
  AND   crh_current.cash_receipt_id     = cr.cash_receipt_id
  AND   crh_current.current_record_flag = 'Y';


  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_debug.debug('EXCEPTION: arp_process_misc_receipts.update_misc_receipt');
      END IF;
      RAISE;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug('arp_process_misc_receipts.update_misc_receipt()-');
  END IF;

END update_misc_receipt;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_misc_receipt                             			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Creates a new misc receipt					     |
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
 |    19-SEP-95	 OSTEINME	created					     |
 |    13-NOV-96	 OSTEINME	added parameter anticipated_clearing_date to |
 |				insert, update, and lock procedures for CE   |
 |				enhancement.				     |
 |				NOTE: This version of the file is not longer |
 |				compatible with 10.6 and prod15!	     |
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
 |    27-NOV-98 GJWANG		Added parameter tax_rate when insert         |
 |    20-MAY-05 J Beckett	Added p_legal_entity_id for R12 LE uptake    |
 |    04-JAN-07 M Raymond    5728628 - Added logic to default LE if
 |                              it is passed in as null
 +===========================================================================*/


PROCEDURE insert_misc_receipt(
	p_currency_code		IN VARCHAR2,
	p_amount		IN NUMBER,
	p_receivables_trx_id	IN NUMBER,
	p_misc_payment_source	IN VARCHAR2,
	p_receipt_number	IN VARCHAR2,
	p_receipt_date		IN DATE,
	p_gl_date		IN DATE,
	p_comments		IN VARCHAR2,
	p_exchange_rate_type	IN VARCHAR2,
	p_exchange_rate		IN NUMBER,
	p_exchange_date		IN DATE,
	p_batch_id		IN NUMBER,
	p_attribute_category	IN VARCHAR2,
	p_attribute1		IN VARCHAR2,
	p_attribute2		IN VARCHAR2,
	p_attribute3		IN VARCHAR2,
	p_attribute4		IN VARCHAR2,
	p_attribute5		IN VARCHAR2,
	p_attribute6		IN VARCHAR2,
	p_attribute7		IN VARCHAR2,
	p_attribute8		IN VARCHAR2,
	p_attribute9		IN VARCHAR2,
	p_attribute10		IN VARCHAR2,
	p_attribute11		IN VARCHAR2,
	p_attribute12		IN VARCHAR2,
	p_attribute13		IN VARCHAR2,
	p_attribute14		IN VARCHAR2,
	p_attribute15		IN VARCHAR2,
	p_remittance_bank_account_id  IN NUMBER,
	p_deposit_date		      IN DATE,
	p_receipt_method_id	      IN NUMBER,
	p_doc_sequence_value	      IN NUMBER,
	p_doc_sequence_id	      IN NUMBER,
	p_distribution_set_id	IN NUMBER,
	p_reference_type	IN VARCHAR2,
	p_reference_id		IN NUMBER,
	p_vat_tax_id		IN NUMBER,
        p_ussgl_transaction_code IN VARCHAR2,
	p_anticipated_clearing_date IN DATE,
--
-- ******* Global Flexfield parameters *******
--
	p_global_attribute1		IN VARCHAR2,
	p_global_attribute2		IN VARCHAR2,
	p_global_attribute3		IN VARCHAR2,
	p_global_attribute4		IN VARCHAR2,
	p_global_attribute5		IN VARCHAR2,
	p_global_attribute6		IN VARCHAR2,
	p_global_attribute7		IN VARCHAR2,
	p_global_attribute8		IN VARCHAR2,
	p_global_attribute9		IN VARCHAR2,
	p_global_attribute10		IN VARCHAR2,
	p_global_attribute11		IN VARCHAR2,
	p_global_attribute12		IN VARCHAR2,
	p_global_attribute13		IN VARCHAR2,
	p_global_attribute14		IN VARCHAR2,
	p_global_attribute15		IN VARCHAR2,
	p_global_attribute16		IN VARCHAR2,
	p_global_attribute17		IN VARCHAR2,
	p_global_attribute18		IN VARCHAR2,
	p_global_attribute19		IN VARCHAR2,
	p_global_attribute20		IN VARCHAR2,
	p_global_attribute_category	IN VARCHAR2,
 	p_cr_id			OUT NOCOPY NUMBER,
	p_row_id		OUT NOCOPY VARCHAR2,
--
	p_form_name		IN  varchar2,
	p_form_version		IN  varchar2,
        p_tax_rate		IN  NUMBER,
        p_gl_tax_acct           IN  VARCHAR2 , /* Bug fix 2300268 */
        p_crh_id                OUT NOCOPY NUMBER,  /* Bug fix 2742388 */
	p_legal_entity_id       IN  NUMBER,
        p_payment_trxn_extension_id  IN ar_cash_receipts.payment_trxn_extension_id%TYPE ) IS
l_creation_status	ar_cash_receipt_history.status%TYPE;
l_cr_rec		ar_cash_receipts%ROWTYPE;
l_crh_rec		ar_cash_receipt_history%ROWTYPE;
l_ccid			ar_cash_receipt_history.account_code_combination_id%TYPE;
l_source_type		ar_distributions.source_type%TYPE;
l_override_remit_account_flag
		ar_receipt_method_accounts.override_remit_account_flag%TYPE;
l_acctd_amount		ar_cash_receipt_history.acctd_amount%TYPE;
l_dummy			NUMBER;
l_ae_doc_rec            l_ae_doc_rec_type;
l_called_from_api       varchar2(1);
l_legal_entity_id       NUMBER;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug('arp_process_misc_receipts.insert_misc_receipt()+');
  END IF;

  -- check if calling form is compatible with entity handler

  -- ??????

  -- receipt record needs to be validated:

  -- val_insert_cr_rec(p_cr_rec);  ????

  -- lock related records:

  -- ??????

  -- determine creation state (approved, confirmed, remitted, cleared)
  -- of receipt based on payment method, as well as code combination
  -- id's.  Also get set of books id.

  arp_cr_util.get_creation_info(p_receipt_method_id,
				p_remittance_bank_account_id,
	      			l_creation_status,
				l_source_type,
				l_ccid,
				l_override_remit_account_flag);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug( 'Creation status 			= ' || l_creation_status);
     arp_debug.debug( 'Source Type     			= ' || l_source_type);
     arp_debug.debug( 'ccid            			= ' || l_ccid);
  END IF;

  -- create ar_cash_receipt record:

    --APANDIT:get the addln information if the reference is a RECEIPT
    --this is added for the credit card refund functionality.

    IF p_reference_type = 'RECEIPT'  AND
       p_reference_id IS NOT NULL
     THEN
      BEGIN
       select pay_from_customer,
              customer_bank_account_id,
              customer_site_use_id,
              payment_server_order_num,
              approval_code
       into   l_cr_rec.pay_from_customer,
              l_cr_rec.customer_bank_account_id,
              l_cr_rec.customer_site_use_id,
              l_cr_rec.payment_server_order_num,
              l_cr_rec.approval_code
       from   ar_cash_receipts
       where  cash_receipt_id = p_reference_id;


      EXCEPTION
       WHEN no_data_found THEN
        FND_MESSAGE.Set_Name('AR', 'AR_RAPI_REFERENCE_ID_INVALID');
        APP_EXCEPTION.Raise_Exception;
      END;

    END IF;

    /* Bug 4112494 - Get customer details for CM refund */
    IF p_reference_type = 'CREDIT_MEMO'  AND
       p_reference_id IS NOT NULL
     THEN
      BEGIN
       select bill_to_customer_id,
              customer_bank_account_id,
              bill_to_site_use_id
       into   l_cr_rec.pay_from_customer,
              l_cr_rec.customer_bank_account_id,
              l_cr_rec.customer_site_use_id
       from   ra_customer_trx
       where  customer_trx_id = p_reference_id;


      EXCEPTION
       WHEN no_data_found THEN
        FND_MESSAGE.Set_Name('AR', 'AR_RAPI_REFERENCE_ID_INVALID');
        APP_EXCEPTION.Raise_Exception;
      END;

    END IF;

    /* 5728628 - default LE if parameter is passed as null */
    IF p_legal_entity_id IS NULL
    THEN
       l_legal_entity_id := ar_receipt_lib_pvt.get_legal_entity(
                      p_remittance_bank_account_id);
       IF PG_DEBUG in ('Y', 'C') THEN
         arp_debug.debug('p_legal_entity_id is NULL, defaulting from ar_receipt_lib_pvt');
         arp_debug.debug('l_legal_entity_id = ' || l_legal_entity_id);
       END IF;
    ELSE
       l_legal_entity_id := p_legal_entity_id;
       IF PG_DEBUG in ('Y', 'C') THEN
         arp_debug.debug('l_legal_entity_id = ' || l_legal_entity_id);
       END IF;
    END IF;

  l_cr_rec.amount 		:= p_amount;
  l_cr_rec.currency_code	:= p_currency_code;
  l_cr_rec.receivables_trx_id	:= p_receivables_trx_id;
  l_cr_rec.misc_payment_source  := p_misc_payment_source;
  l_cr_rec.status 		:= 'APP';
  l_cr_rec.type 		:= 'MISC';
  l_cr_rec.receipt_number	:= p_receipt_number;
  l_cr_rec.receipt_date		:= p_receipt_date;
  l_cr_rec.comments 		:= p_comments;
  l_cr_rec.exchange_rate_type	:= p_exchange_rate_type;
  l_cr_rec.exchange_rate	:= p_exchange_rate;
  l_cr_rec.exchange_date	:= p_exchange_date;
  l_cr_rec.attribute_category	:= p_attribute_category;
  l_cr_rec.attribute1 		:= p_attribute1;
  l_cr_rec.attribute2 		:= p_attribute2;
  l_cr_rec.attribute3 		:= p_attribute3;
  l_cr_rec.attribute4 		:= p_attribute4;
  l_cr_rec.attribute5 		:= p_attribute5;
  l_cr_rec.attribute6 		:= p_attribute6;
  l_cr_rec.attribute7 		:= p_attribute7;
  l_cr_rec.attribute8 		:= p_attribute8;
  l_cr_rec.attribute9 		:= p_attribute9;
  l_cr_rec.attribute10 		:= p_attribute10;
  l_cr_rec.attribute11 		:= p_attribute11;
  l_cr_rec.attribute12 		:= p_attribute12;
  l_cr_rec.attribute13 		:= p_attribute13;
  l_cr_rec.attribute14 		:= p_attribute14;
  l_cr_rec.attribute15 		:= p_attribute15;
  l_cr_rec.remit_bank_acct_use_id := p_remittance_bank_account_id;
  l_cr_rec.confirmed_flag	:= 'Y';
  l_cr_rec.deposit_date		:= p_deposit_date;
  l_cr_rec.receipt_method_id	:= p_receipt_method_id;
  l_cr_rec.doc_sequence_value	:= p_doc_sequence_value;
  l_cr_rec.doc_sequence_id	:= p_doc_sequence_id;
  l_cr_rec.distribution_set_id  := p_distribution_set_id;
  l_cr_rec.override_remit_account_flag := l_override_remit_account_flag;
  l_cr_rec.reference_id		:= p_reference_id;
  l_cr_rec.reference_type	:= p_reference_type;
  l_cr_rec.vat_tax_id		:= p_vat_tax_id;
  l_cr_rec.ussgl_transaction_code := p_ussgl_transaction_code;
--VAT change
  l_cr_rec.tax_rate             := p_tax_rate;
--
  l_cr_rec.anticipated_clearing_date := p_anticipated_clearing_date;


  l_cr_rec.global_attribute1	:= p_global_attribute1;
  l_cr_rec.global_attribute2	:= p_global_attribute2;
  l_cr_rec.global_attribute3	:= p_global_attribute3;
  l_cr_rec.global_attribute4	:= p_global_attribute4;
  l_cr_rec.global_attribute5	:= p_global_attribute5;
  l_cr_rec.global_attribute6	:= p_global_attribute6;
  l_cr_rec.global_attribute7	:= p_global_attribute7;
  l_cr_rec.global_attribute8	:= p_global_attribute8;
  l_cr_rec.global_attribute9	:= p_global_attribute9;
  l_cr_rec.global_attribute10	:= p_global_attribute10;
  l_cr_rec.global_attribute11	:= p_global_attribute11;
  l_cr_rec.global_attribute12	:= p_global_attribute12;
  l_cr_rec.global_attribute13	:= p_global_attribute13;
  l_cr_rec.global_attribute14	:= p_global_attribute14;
  l_cr_rec.global_attribute15	:= p_global_attribute15;
  l_cr_rec.global_attribute16	:= p_global_attribute16;
  l_cr_rec.global_attribute17	:= p_global_attribute17;
  l_cr_rec.global_attribute18	:= p_global_attribute18;
  l_cr_rec.global_attribute19	:= p_global_attribute19;
  l_cr_rec.global_attribute20	:= p_global_attribute20;
  l_cr_rec.global_attribute_category	:= p_global_attribute_category;
  l_cr_rec.legal_entity_id      := l_legal_entity_id;  /* R12 LE uptake */
  l_cr_rec.payment_trxn_extension_id := p_payment_trxn_extension_id ; /* BICHATTE PAYMENT UPTAKE */


  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug( 'Anticipated_clearing_date = ' || p_anticipated_clearing_date);
  END IF;

  arp_cash_receipts_pkg.insert_p(l_cr_rec);
  p_cr_id := l_cr_rec.cash_receipt_id; 		-- return cash receipt id

  -- get the ROWID out NOCOPY parameter:

  SELECT rowid
  INTO   p_row_id
  FROM   ar_cash_receipts
  WHERE  cash_receipt_id = l_cr_rec.cash_receipt_id;

  -- determine accounted amount
  -- Changes for triangulation: If exchange rate type is not user, call
  -- GL API to calculate accounted amount
  IF (p_exchange_rate_type = 'User')  THEN
    arp_util.calc_acctd_amount( NULL,
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

  -- create related misc receipt history record


  arp_proc_rct_util.insert_crh_rec(
			l_cr_rec,
			l_cr_rec.amount,
			l_acctd_amount,
			NULL,
			NULL,
			p_gl_date,
			l_creation_status,
			p_batch_id,
			l_ccid,
			NULL,
			l_crh_rec);

  /* Bug fix 2742388 */
  p_crh_id := l_crh_rec.cash_receipt_history_id;

  arp_proc_rct_util.insert_dist_rec(
			l_cr_rec.amount,
			l_acctd_amount,
			l_crh_rec.cash_receipt_history_id,
			l_source_type,
			l_ccid );

  -- create misc distribution records if necessary:

  arp_proc_rct_util.insert_misc_dist(
			l_cr_rec.cash_receipt_id,
		      	p_gl_date,
			p_amount,
			p_currency_code,
			p_exchange_rate,
			l_acctd_amount,
			p_receipt_date,
			p_receivables_trx_id,
			p_distribution_set_id,
                        p_ussgl_transaction_code);

  -- Call accounting entry library begins
  -- added code to check whether amount is 0

  /* Bug 2272461
     The MISCCASH record is not created in ar_distributions table
     if the receipt amount is zero. Commented out NOCOPY the IF condition.
    If (p_amount <> 0) THEN */

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_debug.debug(  'Create Misc Cash Receipt start () +');
      END IF;

      l_ae_doc_rec.document_type           := 'RECEIPT';
      l_ae_doc_rec.document_id             := l_cr_rec.cash_receipt_id;
      l_ae_doc_rec.accounting_entity_level := 'ONE';
      l_ae_doc_rec.source_table            := 'MCD';
      l_ae_doc_rec.source_id               := '';
      l_ae_doc_rec.gl_tax_acct             := p_gl_tax_acct; /* Bug fix 2300268 */

      arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_debug.debug(  'Create Misc Cash Receipt start () -');
      END IF;
  /*END IF; */

    /* Bug fix 4910860 */
    IF nvl(p_form_name,'RAPI') = 'RAPI' THEN
       l_called_from_api := 'Y';
    ELSE
      l_called_from_api := 'N';
    END IF;
    arp_balance_check.Check_Recp_Balance(l_cr_rec.cash_receipt_id,NULL,l_called_from_api);

  -- update batch status

  IF (p_batch_id IS NOT NULL) THEN
    arp_rw_batches_check_pkg.update_batch_status(
		p_batch_id);
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug('arp_process_misc_receipts.insert_misc_receipt()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_debug.debug('Exception in insert_misc_receipt');
      END IF;
      RAISE;

END insert_misc_receipt;



END ARP_PROCESS_MISC_RECEIPTS;

/
