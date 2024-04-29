--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_RCTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_RCTS" AS
/* $Header: ARRERGWB.pls 120.27.12010000.5 2009/04/29 15:01:15 mpsingh ship $ */

/* =======================================================================
 | Global Data Types
 * ======================================================================*/
SUBTYPE ae_doc_rec_type   IS arp_acct_main.ae_doc_rec_type;
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/* ---------------------- Public functions -------------------------------- */


FUNCTION revision RETURN VARCHAR2 IS
BEGIN

  RETURN '$Revision: 120.27.12010000.5 $';

END revision;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_cash_receipt                             			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Locks a cash receipt.						     |
 |									     |
 | SCOPE - PUBLIC                                                            |
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
 |    20-NOV-95	OSTEINME	created					     |
 |    01-NOV-96  OSTEINME	added parameter anticipated_clearing_date    |
 |				for CashBook enhancement (float support)     |
 |    01-NOV-96  OSTEINME	added parameters for Japan project:	     |
 |				  - customer_bank_branch_id		     |
 |    30-DEC-96	 OSTEINME	added global flexfield parameters            |
 |    05-FEB-03  RVSHARMA       added new parameter p_receipt_status for     |
 |                              Bug 2688648.                                 |   |                                                                           |
 +===========================================================================*/


PROCEDURE lock_cash_receipt(
  	p_cash_receipt_id	IN NUMBER,
	p_currency_code		IN VARCHAR2,
	p_amount		IN NUMBER,
	p_pay_from_customer	IN NUMBER,
	p_receipt_number	IN VARCHAR2,
	p_receipt_date		IN DATE,
	p_gl_date		IN DATE,
	p_maturity_date		IN DATE,
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
	p_override_remit_account_flag IN VARCHAR2,
	p_remittance_bank_account_id  IN NUMBER,
	p_customer_bank_account_id    IN NUMBER,
	p_customer_site_use_id	      IN NUMBER,
	p_customer_receipt_reference  IN VARCHAR2,
	p_factor_discount_amount      IN NUMBER,
	p_deposit_date		      IN DATE,
	p_receipt_method_id	      IN NUMBER,
	p_doc_sequence_value	      IN NUMBER,
	p_doc_sequence_id	      IN NUMBER,
	p_ussgl_transaction_code      IN VARCHAR2,
	p_vat_tax_id		      IN NUMBER,
	p_anticipated_clearing_date   IN DATE,
	p_customer_bank_branch_id     IN NUMBER,
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
--      Notes Receivable
--
        p_issuer_name			IN VARCHAR2,
	p_issue_date			IN DATE,
	p_issuer_bank_branch_id		IN NUMBER,
--
        p_application_notes             IN VARCHAR2,
--
--
	p_form_name		        IN VARCHAR2,
	p_form_version		        IN VARCHAR2,
        p_payment_server_order_num      IN VARCHAR2,
        p_approval_code                 IN VARCHAR2,
        p_receipt_status                IN VARCHAR2,   /* Bug 2688648 */
        p_rec_version_number            IN NUMBER,      /* Bug fix 3032059 */
        p_payment_trxn_extension_id     IN NUMBER,
	p_automatch_set_id              IN NUMBER, /* ER Automatch Application */
	p_autoapply_flag                IN VARCHAR2
				) IS
--
l_cr_rec	AR_CASH_RECEIPTS%ROWTYPE;
--
BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_process_receipts.lock_cash_receipt()+');
  END IF;

  arp_cash_receipts_pkg.set_to_dummy(l_cr_rec);

  l_cr_rec.cash_receipt_id	:= p_cash_receipt_id;
  l_cr_rec.currency_code 	:= p_currency_code;
  l_cr_rec.amount 		:= p_amount;
  l_cr_rec.receipt_number 	:= p_receipt_number;
  l_cr_rec.receipt_date 	:= p_receipt_date;
  l_cr_rec.comments 		:= p_comments;
  l_cr_rec.exchange_rate_type	:= p_exchange_rate_type;
  l_cr_rec.exchange_rate	:= p_exchange_rate;
  l_cr_rec.exchange_date 	:= p_exchange_date;
  l_cr_rec.attribute_category   := p_attribute_category;
  l_cr_rec.attribute1		:= p_attribute1;
  l_cr_rec.attribute2		:= p_attribute2;
  l_cr_rec.attribute3		:= p_attribute3;
  l_cr_rec.attribute4		:= p_attribute4;
  l_cr_rec.attribute5		:= p_attribute5;
  l_cr_rec.attribute6		:= p_attribute6;
  l_cr_rec.attribute7		:= p_attribute7;
  l_cr_rec.attribute8		:= p_attribute8;
  l_cr_rec.attribute9		:= p_attribute9;
  l_cr_rec.attribute10		:= p_attribute10;
  l_cr_rec.attribute11		:= p_attribute11;
  l_cr_rec.attribute12		:= p_attribute12;
  l_cr_rec.attribute13		:= p_attribute13;
  l_cr_rec.attribute14		:= p_attribute14;
  l_cr_rec.attribute15		:= p_attribute15;

  l_cr_rec.remittance_bank_account_id  := p_remittance_bank_account_id;
  l_cr_rec.override_remit_account_flag := p_override_remit_account_flag;
  l_cr_rec.deposit_date		       := p_deposit_date;
  l_cr_rec.receipt_method_id	       := p_receipt_method_id;

  l_cr_rec.doc_sequence_value	      := p_doc_sequence_value;
  l_cr_rec.doc_sequence_id	      := p_doc_sequence_id;
  l_cr_rec.pay_from_customer          := p_pay_from_customer;
  l_cr_rec.customer_site_use_id       := p_customer_site_use_id;
  l_cr_rec.customer_receipt_reference := p_customer_receipt_reference;
  l_cr_rec.customer_bank_account_id   := p_customer_bank_account_id;
  l_cr_rec.ussgl_transaction_code     := p_ussgl_transaction_code;
  l_cr_rec.vat_tax_id	              := p_vat_tax_id;
  l_cr_rec.anticipated_clearing_date  := p_anticipated_clearing_date;
  l_cr_rec.customer_bank_branch_id    := p_customer_bank_branch_id;

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

  l_cr_rec.issuer_name              := p_issuer_name;
  l_cr_rec.issue_date 		    := p_issue_date;
  l_cr_rec.issuer_bank_branch_id    := p_issuer_bank_branch_id;

-- Enh. 2074220:
  l_cr_rec.application_notes := p_application_notes;

  l_cr_rec.payment_server_order_num := p_payment_server_order_num;
  l_cr_rec.approval_code            := p_approval_code;
  /* Bug fix 2963757 : Revert the fix for bug 2688648 */
/*  l_cr_rec.status                   := p_receipt_status;  */  /* bug 2688648 */

   /* Bug fix 3032059 */
   l_cr_rec.rec_version_number      := p_rec_version_number;

   /* PAYMENT_UPTAKE  */
   l_cr_rec.payment_trxn_extension_id := p_payment_trxn_extension_id;
   l_cr_rec.automatch_set_id            := p_automatch_set_id; /* ER Automatch Application */
   l_cr_rec.autoapply_flag              := p_autoapply_flag;


  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('lock_cash_receipt: ' || 'Exchange rate = ' || p_exchange_rate);
     arp_standard.debug('lock_cash_receipt: ' || 'Exchange rate date = ' || p_exchange_date);
     arp_standard.debug('lock_cash_receipt: ' || 'Exchange rate type = ' || p_exchange_rate_type);
     arp_standard.debug('lock_cash_receipt: ' || 'Currency code = ' || p_currency_code);
     arp_standard.debug('lock_cash_receipt: ' || 'Receipt Number = ' || p_receipt_number);
     arp_standard.debug('lock_cash_receipt: ' || 'Payment server ord num = ' || p_payment_server_order_num);
     arp_standard.debug('lock_cash_receipt: ' || 'Approval code = ' || p_approval_code);
  END IF;

  arp_cash_receipts_pkg.lock_compare_p(l_cr_rec);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_process_receipts.lock_cash_receipt()-');
  END IF;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.Raise_Exception;
     WHEN  OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('EXCEPTION: arp_process_receipts.lock_cash_receipt()');
       END IF;
       RAISE;

END lock_cash_receipt;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_cash_receipt                              			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Entity handler that delete cash receipts.				     |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    30-NOV-95	OSTEINME	created					     |
 |    28-Dec-98 DJANCIS         added call to set posted flag to deterime if |
 |                              receipt was posted before deleting it        |
 |    08-Nov-01 DJANCIS		Modified for mrc trigger elimination project |
 |				added call to ar_mrc_engine for deletes to   |
 |				ar_payment_schedules    		     |
 +===========================================================================*/

PROCEDURE delete_cash_receipt(
	p_cash_receipt_id	IN NUMBER,
	p_batch_id		IN NUMBER) IS

CURSOR get_app_C IS
       select app.receivable_application_id app_id
       from   ar_receivable_applications app
       where  app.cash_receipt_id = p_cash_receipt_id
       and    nvl(app.confirmed_flag,'Y') = 'Y'   --confirmed records have accounting only
       and exists (select 'x'
                   from  ar_distributions ard
                   where ard.source_table = 'RA'
                   and   ard.source_id    = app.receivable_application_id)
       order by decode(app.status,
                       'UNAPP',1,  --Delete UNAPP related accounting first as record may be paired
                       2);

/* Bug 4173339 */
l_trx_sum_hist_rec        AR_TRX_SUMMARY_HIST%rowtype;
l_event_source_info xla_events_pub_pkg.t_event_source_info;
l_security          xla_events_pub_pkg.t_security;
l_event_id          NUMBER;

CURSOR  get_app_ev is
        select distinct ra.event_id  event_id , ra.cash_receipt_id  cash_receipt_id from
        ar_receivable_applications ra where ra.cash_receipt_id = p_cash_receipt_id
        and ra.status not in ('UNAPP','UNID')
        and ra.event_id is not null
        and exists
            ( select 'x' from xla_events where event_id = ra.event_id
              and application_id = 222 ) ;


CURSOR get_existing_ps  IS
SELECT payment_schedule_id,
       invoice_currency_code,
       due_date,
       amount_in_dispute,
       amount_due_original,
       amount_due_remaining,
       amount_adjusted,
       cash_receipt_id,
       customer_id,
       customer_site_use_id,
       trx_date
FROM   ar_payment_schedules
WHERE  cash_receipt_id  = p_cash_receipt_id;

CURSOR cReceiptDtls IS
   SELECT receipt_number,
          receipt_date
   FROM   ar_cash_receipts
   WHERE  cash_receipt_id = p_cash_receipt_id;


l_history_id		  NUMBER;

p_posted_flag 		  BOOLEAN;
l_get_app_rec 		  get_app_C%ROWTYPE;
l_ae_doc_rec  		  ae_doc_rec_type;

l_ar_ps_key_value_list    gl_ca_utility_pkg.r_key_value_arr;
l_ar_dist_key_value_list  gl_ca_utility_pkg.r_key_value_arr;
l_rec_app_key_value_list  gl_ca_utility_pkg.r_key_value_arr;

l_receipt_number 	  ar_cash_receipts.receipt_number%type;
l_receipt_date 	  	  ar_cash_receipts.receipt_date%type;


BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_process_receipts.delete_cash_receipt()+');
  END IF;

  ARP_PROCESS_RCTS.set_posted_flag(p_cash_receipt_id,
                                    p_posted_flag);
  IF ( p_posted_flag = TRUE) THEN
     -- raise and error and exit
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('delete_cash_receipt: ' || 'posted flag = true ');
  END IF;
    fnd_message.set_name('AR','AR_RW_DEL_REC_POSTED');
    app_exception.raise_exception;

  END IF;

  -- lock receipt record to make sure no one else has it locked

  arp_cash_receipts_pkg.lock_p(p_cash_receipt_id);

  -- delete AR_CASH_RECEIPTS receipt record:

  -- Before Deletion get the recipt details for Summary Tables
  FOR ReceiptDtlsRec IN cReceiptDtls
  LOOP
	l_receipt_number := ReceiptDtlsRec.receipt_number;
	l_receipt_date := ReceiptDtlsRec.receipt_date;
  END LOOP;

  arp_cash_receipts_pkg.delete_p(p_cash_receipt_id);

  -- delete AR_DISTRIBUTIONS records created for each
  -- AR_CASH_RECEIPT_HISTORY record.

  DELETE AR_DISTRIBUTIONS
  WHERE source_table = 'CRH'
    AND	source_id IN (
    SELECT cash_receipt_history_id
    FROM ar_cash_receipt_history
    WHERE cash_receipt_id = p_cash_receipt_id)
  RETURNING line_id
  BULK COLLECT INTO l_ar_dist_key_value_list;

  /*---------------------------------+
   | Calling central MRC library     |
   | for MRC Integration             |
   +---------------------------------*/

   ar_mrc_engine.maintain_mrc_data(
             p_event_mode        => 'DELETE',
             p_table_name        => 'AR_DISTRIBUTIONS',
             p_mode              => 'BATCH',
             p_key_value_list    => l_ar_dist_key_value_list);


    --Bug # 6450286
    --------------------------------
    -- Delete the corresponding event in XLA schema
    --------------------------------
     ARP_XLA_EVENTS.delete_event( p_document_id  => p_cash_receipt_id,
                                  p_doc_table    => 'CRH');


  -- delete all AR_CASH_RECEIPT_HISTORY records created for this
  -- receipt:
  -- Bug 2021718:  Call entity handler for delete
  arp_cr_history_pkg.delete_p_cr(p_cash_receipt_id);

  -- DELETE AR_CASH_RECEIPT_HISTORY
  -- WHERE cash_receipt_id = p_cash_receipt_id;

  --Delete all associated accounting with the receivable applications
  --first.

  FOR l_get_app_rec IN get_app_C LOOP

      l_ae_doc_rec.document_type           := 'RECEIPT';
      l_ae_doc_rec.document_id             := p_cash_receipt_id;
      l_ae_doc_rec.accounting_entity_level := 'ONE';
      l_ae_doc_rec.source_table            := 'RA';
      l_ae_doc_rec.source_id               := l_get_app_rec.app_id;
      l_ae_doc_rec.source_id_old           := '';
      l_ae_doc_rec.other_flag              := '';

      arp_acct_main.Delete_Acct_Entry(l_ae_doc_rec);

  END LOOP;

  FOR l_get_ev IN get_app_ev LOOP

       l_event_id := l_get_ev.event_id ;

    IF l_event_id IS NOT NULL THEN

       l_event_source_info.entity_type_code:= 'RECEIPTS';
       l_security.security_id_int_1        := arp_global.sysparam.org_id;
       l_event_source_info.application_id  := 222;
       l_event_source_info.ledger_id       := arp_standard.sysparm.set_of_books_id; --to be set
       l_event_source_info.source_id_int_1 := l_get_ev.cash_receipt_id ;

        xla_events_pub_pkg.delete_event
        ( p_event_source_info => l_event_source_info,
          p_event_id          => l_event_id,
          p_valuation_method  => NULL,
          p_security_context  => l_security);

    END IF;

   END LOOP;


  -- delete all AR_RECEIVABLE_APPLICATIONS records created for this
  -- receipt:

  DELETE AR_RECEIVABLE_APPLICATIONS
  WHERE cash_receipt_id = p_cash_receipt_id
  RETURNING receivable_application_id
  BULK COLLECT INTO l_rec_app_key_value_list;

 /*---------------------------------+
   | Calling central MRC library     |
   | for MRC Integration             |
  +---------------------------------*/

  ar_mrc_engine.maintain_mrc_data(
             p_event_mode        => 'DELETE',
             p_table_name        => 'AR_RECEIVABLE_APPLICATIONS',
             p_mode              => 'BATCH',
             p_key_value_list    => l_rec_app_key_value_list);

  /* Bug 4173339
     Store the ps record values into history table before deleting.
  */
  OPEN get_existing_ps;

  FETCH get_existing_ps
  INTO  l_trx_sum_hist_rec.payment_schedule_id,
        l_trx_sum_hist_rec.currency_code,
        l_trx_sum_hist_rec.due_date,
        l_trx_sum_hist_rec.amount_in_dispute,
        l_trx_sum_hist_rec.amount_due_original,
        l_trx_sum_hist_rec.amount_due_remaining,
        l_trx_sum_hist_rec.amount_adjusted,
        l_trx_sum_hist_rec.customer_trx_id,
        l_trx_sum_hist_rec.customer_id,
        l_trx_sum_hist_rec.site_use_id,
        l_trx_sum_hist_rec.trx_date;

  AR_BUS_EVENT_COVER.p_insert_trx_sum_hist(l_trx_sum_hist_rec,
                                           l_history_id,
         				   'PMT',
                                           'DELETE_PMT');

  CLOSE get_existing_ps;

  -- delete AR_PAYMENT_SCHEDULE record created for this receipt:

  DELETE AR_PAYMENT_SCHEDULES
  WHERE cash_receipt_id = p_cash_receipt_id
  RETURNING payment_schedule_id
  BULK COLLECT INTO l_ar_ps_key_value_list;

  /*---------------------------------+
   | Calling central MRC library     |
   | for MRC Integration             |
   +---------------------------------*/

    ar_mrc_engine.maintain_mrc_data(
                p_event_mode        => 'DELETE',
                p_table_name        => 'AR_PAYMENT_SCHEDULES',
                p_mode              => 'BATCH',
                p_key_value_list    => l_ar_ps_key_value_list);
--

  -- update batch status

  IF (p_batch_id IS NOT NULL) THEN
    arp_rw_batches_check_pkg.update_batch_status(
		p_batch_id);
  END IF;

  -- Raise the Deletion Business Event
  AR_BUS_EVENT_COVER.Raise_Rcpt_Deletion_Event(
				l_trx_sum_hist_rec.payment_schedule_id,
				l_receipt_number,
				l_receipt_date
					     ) ;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_process_receipts.delete_cash_receipt()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('EXCEPTION: arp_process_receipts.delete_cash_receipts');
       END IF;
       RAISE;

END delete_cash_receipt;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   post_query_logic              					     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Executes post-query logic for the ARXRWRCT.fmb form		     |
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
 |   21-FEB-95	OSTEINME	created					     |
 |   21-JUL-97  KLAWRANC	Release 11.				     |
 |				Added cross currency logic.  Should select   |
 |                              amount_applied_from when this is populated   |
 |                              otherwise use amount_applied.  See notes.    |
 |            			Added the calculation and return of the total|
 |				exchange gain/loss at the header level.      |
 |                              Added cross currency apps flag as out NOCOPY        |
 |                              parameter.                                   |
 |   22-OCT-97	KLAWRANC	Bug #550743.  Changed query of applications. |
 |				For APP rows, don't include where confirmed  |
 |				is 'N'.                                      |
 |   04-DEC-97  KLAWRANC        Bug #591462.  Removed distinct clause when   |
 |                              counting cash receipt history records.  This |
 |                              did not cater for the case where the cash    |
 |                              receipt record has been rate adjusted (the   |
 |                              receipt has not changed state but there is   |
 |                              more than one history record).               |
 |    10-MAR-98 KLAWRANC        Bug #584086.  Receipts Query Performance.    |
 |                              Added the selection and return of reversal   |
 |                              and confirmation details.  These were        |
 |                              removed from the view and added to post query|
 |                              for performance reasons.                     |
 |                              Bug #584086.  Added code to explicitly set   |
 |                              p_debit_memo to 'N' when no_data_found or    |
 |                              the receipt is not reversed.                 |
 |                                                                           |
 |    20-APR-2000 J Rautiainen  BR Implementation. Activity application of   |
 |                              type Short Term debt is considered as        |
 |                              applied amount.                              |
 |    09-Oct-2000 S Nambiar     Receipt write-off is considered as applied   |
 |                              But still we need to calculate write-off for |
 |                              validation purpose                           |
 |    22-DEC-2000 Yashaskar     Bug # 1431322 : A check is made to see if the|
 |                              Chargeback is posted .                       |
 |    28-Mar-2001 S Nambiar     Receipt chargeback is considered as applied  |
 |                              But still we need to calculate chargeback for |
 |                              validation purpose                           |
 |    02-DEC-2002 R Muthuraman  Bug 2421800 : Reverted the fix for	     |
 |                              bug 1431322. 				     |
 |    12-JUN-2003 J Beckett     Bug 2821139 ACTIVITY is considered as applied|
 |                              for exchange gain/loss calculation 	     |
 |    06-DEC-2003 P Pawar       Bug 3252322 : Performance Issue. In procedure|
 |                              post_query_logic, replaced                   |
 |                              "ra.applied_payment_schedule_id = -6 " with  |
 |                              "ra.applied_payment_schedule_id+0 = -6 "     |
 |    02-FEB-2005 J Beckett     Bug 4112494 CM refunds                       |
 |    02-FEB-2005 J Pandey      Bug 4166986 Credit Card Chargebacks added    |
 |                              p_cc_chargeback_amount in the parameter      |
 |    21-MAR-2005 J Pandey      Bug 4166986 Credit Card Chargebacks amt      |
 |                              to be added to the amount_applied and in     |
 |                              logic preventing unapp/reversal of misc rct  |
 +===========================================================================*/

Procedure post_query_logic(
   p_cr_id			IN	ar_cash_receipts.cash_receipt_id%TYPE,
   p_receipt_type		IN	VARCHAR2,
   p_reference_type		IN 	VARCHAR2,
   p_reference_id		IN	NUMBER,
   p_std_reversal_possible 	OUT NOCOPY  	VARCHAR2,
   p_apps_exist_flag		OUT NOCOPY 	VARCHAR2,
   p_rec_moved_state_flag 	OUT NOCOPY	VARCHAR2,
   p_amount_applied		OUT NOCOPY	NUMBER,
   p_amount_unapplied   	OUT NOCOPY     NUMBER,
   p_write_off_amount   	OUT NOCOPY     NUMBER,
   p_cc_refund_amount   	OUT NOCOPY     NUMBER,
   p_cc_chargeback_amount   	OUT NOCOPY     NUMBER,
   p_chargeback_amount   	OUT NOCOPY     NUMBER,
   p_amount_on_account  	OUT NOCOPY     NUMBER,
   p_amount_in_claim	  	OUT NOCOPY     NUMBER,
   p_prepayment_amount	  	OUT NOCOPY     NUMBER,
   p_amount_unidentified 	OUT NOCOPY    	NUMBER,
   p_discounts_earned    	OUT NOCOPY    	NUMBER,
   p_discounts_unearned  	OUT NOCOPY    	NUMBER,
   p_tot_exchange_gain_loss 	OUT NOCOPY 	NUMBER,
   p_statement_number    	OUT NOCOPY    	VARCHAR2,
   p_line_number	 	OUT NOCOPY	VARCHAR2,
   p_statement_date	 	OUT NOCOPY    	DATE,
   p_reference_id_dsp	 	OUT NOCOPY	VARCHAR2,
   p_cross_curr_apps_flag 	OUT NOCOPY	VARCHAR2,
   p_reversal_date              IN      DATE,
   p_reversal_gl_date       	OUT NOCOPY 	DATE,
   p_debit_memo             	OUT NOCOPY 	VARCHAR2,
   p_debit_memo_ccid        	OUT NOCOPY 	NUMBER,
   p_debit_memo_type        	OUT NOCOPY 	VARCHAR2,
   p_debit_memo_number      	OUT NOCOPY 	VARCHAR2,
   p_debit_memo_doc_number  	OUT NOCOPY 	NUMBER,
   p_confirm_date           	OUT NOCOPY 	DATE,
   p_confirm_gl_date        	OUT NOCOPY 	DATE

) IS

   l_apps_exist			VARCHAR2(1);
   l_rec_moved_state		NUMBER;
   l_amount_on_account		NUMBER;
   l_amount_in_claim		NUMBER;
   l_prepayment_amount		NUMBER;
   l_amount_applied		NUMBER;
   l_tot_exchange_gain_loss	NUMBER;
   l_dummy			NUMBER;
   l_cr_currency_code		ar_cash_receipts.currency_code%TYPE;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('ARP_PROCESS_RCT_UTIL.post_query_logic()+');
      arp_standard.debug('post_query_logic: ' || '   p_cr_id = ' || p_cr_id);
      arp_standard.debug('post_query_logic: ' || '   p_type  = ' || p_receipt_type);
   END IF;

   -- check if receipt has moved from creation state to a later state
   /* Bug 2211303 Modified to SELECT count(distinct status) so that
         the FLAG for Checking Receipt with changed states is SET
         Properly . */

   SELECT	count(distinct status)
   INTO		l_rec_moved_state
   FROM 	AR_CASH_RECEIPT_HISTORY
   WHERE	cash_receipt_id = p_cr_id;

   IF (l_rec_moved_state > 1) THEN
     p_rec_moved_state_flag := 'Y';
   ELSE
     p_rec_moved_state_flag := 'N';
   END IF;


   -- get the cash management items

/* bug4751467 -- added the call to cep_standard.init and replaced CE_STATEMENT_RECONCILIATIONS with
   ce_statement_recon_gt_v  */

   cep_standard.init_security;

   SELECT
	MAX(cb_sh.statement_number)			statement_number,
	MAX(cb_sl.line_number)		  		line_number,
	MAX(cb_sh.statement_date)			statement_date
   INTO
	p_statement_number,
	p_line_number,
	p_statement_date
   FROM
	ce_statement_headers		cb_sh,
	ce_statement_lines		cb_sl,
	ce_statement_recon_gt_v 	cb_sr,
	ar_cash_receipt_history 	crh_cb
   WHERE
	 crh_cb.cash_receipt_id = p_cr_id
     AND crh_cb.cash_receipt_history_id = cb_sr.reference_id (+)
     AND cb_sr.reference_type (+) = 'RECEIPT'
     AND cb_sr.current_record_flag (+) = 'Y'
     AND cb_sr.status_flag (+) = 'M'
     AND cb_sr.statement_line_id = cb_sl.statement_line_id (+)
     AND cb_sl.statement_header_id = cb_sh.statement_header_id (+);


   -- for cash receipts, get the application amounts from
   -- ar_receivable_applications

   IF (p_receipt_type = 'MISC') THEN

     p_apps_exist_flag := 'N';
     p_std_reversal_possible := 'Y';

     -- get reference number if necessary

    IF (p_reference_type IS NOT NULL) THEN

      IF (p_reference_type = 'REMITTANCE') THEN

	SELECT name
        INTO   p_reference_id_dsp
        FROM   AR_BATCHES
        WHERE  BATCH_ID = p_reference_id;

      ELSIF (p_reference_type = 'RECEIPT') THEN

	SELECT receipt_number
	INTO   p_reference_id_dsp
        FROM   AR_CASH_RECEIPTS
        WHERE  cash_receipt_id = p_reference_id;

      ELSIF (p_reference_type = 'PAYMENT_BATCH') THEN

        SELECT checkrun_name
	INTO   p_reference_id_dsp
        FROM   AP_INVOICE_SELECTION_CRITERIA
        WHERE  CHECKRUN_ID = p_reference_id;

      ELSIF (p_reference_type = 'PAYMENT') THEN

	SELECT check_number
	INTO   p_reference_id_dsp
        FROM   AP_CHECKS
        WHERE  CHECK_ID = p_reference_id;

      /* Bug 4122494 CM refunds */
      ELSIF (p_reference_type = 'CREDIT_MEMO') THEN

	SELECT trx_number
	INTO   p_reference_id_dsp
	FROM   RA_CUSTOMER_TRX
	WHERE customer_trx_id = p_reference_id;

      END IF;

    END IF;

   ELSE

     -----------------------------------------------------------------------
     -- For APP rows in receivable applications ...
     --
     -- Amount_applied stores the total amount of the application in the
     -- currency of the transaction, i.e. the amount allocated to the
     -- transaction.  Also represents the receipt allocation for same
     -- currency applications.
     --
     -- Amount_applied_from stores the total amount of the application in
     -- the currency of the receipt, i.e. that portion of the receipt
     -- allocated to the transaction.  This is only populated for cross
     -- currency applications.
     --
     -- As we are calculating the total amount applied in the context of
     -- the receipt, we need to firstly select amount_applied_from (as if
     -- populated, the application is cross currency and the receipt amount
     -- is stored in this column), otherwise select amount_applied (as
     -- the amount_applied_from must be null and the receipt amount is
     -- stored in amount_applied).
     -----------------------------------------------------------------------
     /* 20-APR-2000 J Rautiainen BR Implementation
      * Short Term Debt Activity application is considered as applied amount */

     /* snambiar write-off amount is considered as applied. But for maximum
        write-off amount on a receipts needs to be validated. So we are doing
        a sum for the write-off amount with PS id -3                          */

    /* snambiar chargeback amount is considered as applied.                   */
    /* Bug 2751910 Netting amount is considered as applied.                   */
    /* Bug 2821139 Netting amount is considered as applied.                   */
    /* Bug 2821139 ACTIVITY amount is considered as applied for exchange gain
       loss calculation.     					              */
    /* jypandey cc_chargeback amount is considered as applied.                */
    /* Bug 4948423 Refund amount is considered as applied  (-8)               */

     SELECT
	SUM(DECODE(ra.status,
                   'APP',DECODE(ra.confirmed_flag,
                               'N', 0,
                                NVL(nvl(ra.amount_applied_from, ra.amount_applied),0)),
                   'ACTIVITY',DECODE(ra.applied_payment_schedule_id,
                                     -2,NVL(nvl(ra.amount_applied_from, ra.amount_applied),0),
                                     -3,NVL(nvl(ra.amount_applied_from, ra.amount_applied),0),
                                     -5,NVL(nvl(ra.amount_applied_from, ra.amount_applied),0),
                                     -6,NVL(nvl(ra.amount_applied_from, ra.amount_applied),0),
                                     -8,NVL(nvl(ra.amount_applied_from, ra.amount_applied),0),
                                     -9,NVL(nvl(ra.amount_applied_from, ra.amount_applied),0),
                                     DECODE(ra.receivables_trx_id,-16,NVL(nvl(ra.amount_applied_from, ra.amount_applied),0)))
                   ,0)) applied_amount,
        SUM(DECODE(ra.status,'ACTIVITY',DECODE(applied_payment_schedule_id,
                -3,NVL(nvl(ra.amount_applied_from, ra.amount_applied),0),0),0)) write_off_amount,
        SUM(DECODE(ra.status,'ACTIVITY',DECODE(applied_payment_schedule_id,
                -5,NVL(nvl(ra.amount_applied_from, ra.amount_applied),0),0),0)) chargeback_amount,
        SUM(DECODE(ra.status,'ACTIVITY',DECODE(applied_payment_schedule_id,
                -6,NVL(nvl(ra.amount_applied_from, ra.amount_applied),0),0),0)) cc_refund_amount,
        /* Bug 4166986 CC Chargeback */
        SUM(DECODE(ra.status,'ACTIVITY',DECODE(applied_payment_schedule_id,
                -9,NVL(nvl(ra.amount_applied_from, ra.amount_applied),0),0),0)) cc_chargeback_amount,
        SUM(DECODE(ra.status,'UNAPP',
	NVL(ra.amount_applied,0),0))	unapplied_amount,
        SUM(DECODE(ra.status,'ACC',
        NVL(ra.amount_applied, 0),0))    on_account_amount,
        SUM(DECODE(ra.status,'OTHER ACC',DECODE(applied_payment_schedule_id,
                -4,NVL(nvl(ra.amount_applied_from, ra.amount_applied),0),0),0)) claim_amount,
        SUM(DECODE(ra.status,'OTHER ACC',DECODE(applied_payment_schedule_id,
                -7,NVL(nvl(ra.amount_applied_from, ra.amount_applied),0),0),0)) prepayment_amount,
        SUM(DECODE(ra.status,'UNID',
        NVL(ra.amount_applied, 0),0))    unidentified_amount,
        SUM(DECODE(ra.status,'APP',
        NVL(ra.earned_discount_taken, 0),0))     discounts_earned,
        SUM(DECODE(ra.status,'APP',
        NVL(ra.unearned_discount_taken, 0),0))   discounts_unearned,
        SUM(DECODE(ra.status,'APP',
        NVL(ra.acctd_amount_applied_from - ra.acctd_amount_applied_to, 0),'ACTIVITY',
	NVL(ra.acctd_amount_applied_from - ra.acctd_amount_applied_to, 0),0)) tot_exchange_gain_loss
     INTO
	l_amount_applied,
        p_write_off_amount,
        p_chargeback_amount,
        p_cc_refund_amount,
        p_cc_chargeback_amount,
	p_amount_unapplied,
	l_amount_on_account,
        l_amount_in_claim,
        l_prepayment_amount,
	p_amount_unidentified,
	p_discounts_earned,
	p_discounts_unearned,
        l_tot_exchange_gain_loss
     FROM
	ar_receivable_applications ra
     WHERE
	ra.cash_receipt_id = p_cr_id;

     p_amount_on_account := l_amount_on_account;
     p_amount_in_claim   := l_amount_in_claim;
     p_prepayment_amount := l_prepayment_amount;
     p_amount_applied    := l_amount_applied;
     p_tot_exchange_gain_loss := l_tot_exchange_gain_loss;

     /* 20-APR-2000 J Rautiainen BR Implementation
      * Short Term Debt Activity application is considered as application */

     -- Determine if the receipt has applications.
     SELECT max(decode(ra.status, 'APP', 'Y',
                                  'ACC', 'Y',
                                  'OTHER ACC', 'Y',
                                  'ACTIVITY', 'Y', 'N'))
     INTO   l_apps_exist
     FROM   ar_receivable_applications ra
     WHERE  ra.cash_receipt_id = p_cr_id
     AND    ra.reversal_gl_date is NULL;

     p_apps_exist_flag := l_apps_exist;

     -- Determine if the receipt currently has a cross currency
     -- application(s).  No point doint the select if it doesn't
     -- have applications in the first place.
     BEGIN
       IF l_apps_exist = 'Y' THEN

          SELECT cr.currency_code
          INTO   l_cr_currency_code
          FROM   ar_cash_receipts cr
          WHERE  cr.cash_receipt_id = p_cr_id
          AND    exists
                 (select 1
                  from   ar_receivable_applications ra,
                         ar_payment_schedules ps
                  where  ra.cash_receipt_id = cr.cash_receipt_id
                  and    ra.applied_payment_schedule_id = ps.payment_schedule_id
                  and    ps.invoice_currency_code <> cr.currency_code
                  and    ra.reversal_gl_date is NULL
                  and    ra.applied_payment_schedule_id <> -1);

       END IF;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_cr_currency_code := NULL;
     END;

     IF l_cr_currency_code is not NULL THEN
        p_cross_curr_apps_flag := 'Y';
     ELSE
        p_cross_curr_apps_flag := 'N';
     END IF;

   /* --------------------------------------------------------------------
    *   Check if a 'CB' was created against this PMT to be reversed.
    *   Check if there are any PMT, ADJ, or CM or CB against this 'CB' records
    *   in AR_PAYMENT_SCHEDULES table.  Also check to see if the CB has
    *   already been posted.  If any of these 2 conditions is TRUE, then
    *   PMT can only be reversed using DM Reversal.
    *
    *   Make sure that the adj which is automatically created against the CB
    *   associated with the receipt being reversed does not get caught in
    *   the SQL.  For such an adj, the adj.receivables_trx_id = -12
    * -------------------------------------------------------------------- */


     SELECT COUNT(payment_schedule_id)
     INTO l_dummy
     FROM    ar_payment_schedules    ps,
             ra_cust_trx_line_gl_dist rctlg
     WHERE   ps.associated_cash_receipt_id = p_cr_id
     AND     ps.class = 'CB'
     AND     ps.customer_trx_id = rctlg.customer_trx_id
     AND (       nvl(ps.amount_applied, 0) <> 0
            OR  nvl(ps.amount_credited, 0) <> 0
            OR 0 <> ( SELECT sum(adj.amount)
                      FROM ar_adjustments adj
                      WHERE adj.payment_schedule_id =
                             ps.payment_schedule_id
                        AND adj.receivables_trx_id <> -12
                     )
          );

     IF (l_dummy > 0) THEN
       p_std_reversal_possible := 'N';
     ELSE
       p_std_reversal_possible := 'Y';
     END IF;

	 IF p_std_reversal_possible = 'Y' THEN
	    BEGIN
	      /** If the -ve Miscellaneous receipt of CC Refund is already remitted or
		   ** cleared then do not allow the reversal or unapplication ***/

              /*  Added CC chargeback -ve misc receipt too for this condition */

	      SELECT 1
	      INTO l_dummy
	      FROM dual
	      WHERE
		  EXISTS
	      ( SELECT 1
	        FROM  AR_CASH_RECEIPT_HISTORY crh, ar_receivable_applications ra
		    WHERE crh.cash_receipt_id = ra.application_ref_id
			AND   ra.cash_receipt_id = p_cr_id
			AND   ra.applied_payment_schedule_id+0 in (-6 , -9)
			AND   ra.application_ref_type = 'MISC_RECEIPT'
		    AND   crh.status IN ('REMITTED', 'CLEARED'));
          --
          p_std_reversal_possible := 'N';
        EXCEPTION
	      WHEN NO_DATA_FOUND THEN
		     NULL;
		  WHEN OTHERS THEN
		     RAISE;
        END;

	 END IF;

     -- Get Confirmation Details.
     -- This query was removed from the view to speed up
     -- performance.

     BEGIN
       select crh_conf.trx_date,
              crh_conf.gl_date
       into   p_confirm_date,
              p_confirm_gl_date
       from   ar_cash_receipt_history crh_conf
       where  crh_conf.cash_receipt_id = p_cr_id
       and    crh_conf.status = 'CONFIRMED'
       and    not exists (
                           select cash_receipt_history_id
                           from ar_cash_receipt_history crh2
                           where crh2.status = 'CONFIRMED'
                           and crh2.cash_receipt_id = p_cr_id
                           and crh2.cash_receipt_history_id > crh_conf.cash_receipt_history_id);
     EXCEPTION

     WHEN no_data_found THEN

       p_confirm_date := NULL;
       p_confirm_gl_date := NULL;
     END;

   END IF;

   ---------------------------------------------------------
   -- If the Receipt has been Reversed then get DM Reversal
   -- details.
   -- This query was removed from the view to speed up
   -- performance.
   ---------------------------------------------------------

   IF p_reversal_date is not null THEN

     BEGIN

      /*Bug3185358 Changed the ps_dm.gl_date to NVL(dm_gld.gl_Date,ct.gl_Date)
        and removed reference to ar_payment_schedultes as the record may not be
        there while the dm is incompleted */

       select NVL(dm_gld.gl_date,ct_dm.trx_date),
              'Y',
              dm_gld.code_combination_id,
              ctt_dm.name,
              ct_dm.trx_number,
              ct_dm.doc_sequence_value
       into   p_reversal_gl_date,
              p_debit_memo,
              p_debit_memo_ccid,
              p_debit_memo_type,
              p_debit_memo_number,
              p_debit_memo_doc_number
       from   ra_cust_trx_types ctt_dm,
              ra_customer_trx ct_dm,
              ra_cust_trx_line_gl_dist dm_gld
       where  ct_dm.reversed_cash_receipt_id = p_cr_id
       and    ct_dm.cust_trx_type_id = ctt_dm.cust_trx_type_id
       and    ct_dm.customer_trx_id = dm_gld.customer_trx_id
       and    dm_gld.account_class = 'REC'
       and    dm_gld.latest_rec_flag = 'Y';

     EXCEPTION

     WHEN no_data_found THEN

       select crh_current.gl_date
       into   p_reversal_gl_date
       from   ar_cash_receipt_history crh_current
       where  crh_current.cash_receipt_id = p_cr_id
       and    crh_current.current_record_flag = 'Y';

       p_debit_memo := 'N';
       p_debit_memo_ccid := NULL;
       p_debit_memo_type := NULL;
       p_debit_memo_number := NULL;
       p_debit_memo_doc_number := NULL;

     END;

   ELSE

     p_debit_memo := 'N';

   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('ARP_PROCESS_RCT_UTIL.post_query_logic()+');
   END IF;

END post_query_logic;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_posted_flag                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Deterimines if a cash receipt has been posted                          |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |      arp_util.debug                                                       |
 |                                                                           |
 | ARGUMENTS                                                                 |
 |    IN:                                                                    |
 |          p_cash_receipt_id                                                |
 |    OUT:                                                                   |
 |          p_posted_flag                                                    |
 |                                                                           |
 | RETURNS : NONE                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 |    28-NOV-98  Debbie Sue Jancis        created                            |
 |    03-FEB-99  Debbie Sue Jancis        modified declaration of            |
 | 					  l_posted_flag from varchar to      |
 |                                        varchar2.                          |
 +===========================================================================*/

PROCEDURE set_posted_flag( p_cash_receipt_id  IN number,
                           p_posted_flag   OUT NOCOPY BOOLEAN) IS
l_posted_flag varchar2(2);

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('ARP_PROC_RCT_UTIL.set_posted_flag()+');
    END IF;

    SELECT decode ( max(dummy), NULL, 'N','Y')
     INTO l_posted_flag
    FROM   dual
    WHERE EXISTS
            (SELECT 'posted distribution exists'
             FROM  ar_cash_receipt_history
             WHERE cash_receipt_id = p_cash_receipt_id
             AND  gl_posted_date IS NOT NULL);

  IF (l_posted_flag ='Y')
  THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('set_posted_flag: ' || 'flag = true +');
    END IF;
      p_posted_flag := TRUE;
  ELSE
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('set_posted_flag: ' || 'flag = false +');
    END IF;
      p_posted_flag := FALSE;

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ARP_PROC_RCT_UTIL.set_posted_flag()-');
  END IF;

EXCEPTION
     WHEN OTHERS THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('EXCEPTION:  ARP_PROC_RCT_UTIL.set_posted_flag()');
         END IF;
         RAISE;

END set_posted_flag;


--Bug 5033971
PROCEDURE Delete_Transaction_Extension(

           --   *****  Standard API parameters *****
                p_api_version                   IN  NUMBER                      ,
                p_init_msg_list                 IN  VARCHAR2 := FND_API.G_TRUE  ,
                p_commit                        IN  VARCHAR2 := FND_API.G_FALSE ,
                x_return_status                 OUT NOCOPY VARCHAR2             ,
                x_msg_count                     OUT NOCOPY NUMBER               ,
                x_msg_data                      OUT NOCOPY VARCHAR2             ,

           --   *****  Receipt  Header information parameters *****
                p_org_id                        IN  NUMBER      DEFAULT NULL    ,
                p_cust_Account_id               IN  NUMBER      DEFAULT NULL    ,
                p_account_site_use_id           IN  NUMBER      DEFAULT NULL    ,
                p_payment_trxn_extn_id          IN  IBY_TRXN_EXTENSIONS_V.TRXN_EXTENSION_ID%TYPE    )
IS
    l_payer_rec            IBY_FNDCPT_COMMON_PUB.payercontext_rec_type;
    l_trxn_attribs_rec     IBY_FNDCPT_TRXN_PUB.trxnextension_rec_type;
    l_response             IBY_FNDCPT_COMMON_PUB.result_rec_type;
Begin
        arp_standard.debug('ARP_PROCESS_RCTS.Delete_Transaction_Extension()+ ');
        x_msg_count          := NULL;
        x_msg_data           := NULL;
        x_return_status      := FND_API.G_RET_STS_SUCCESS;
        l_payer_rec.party_id :=  arp_trx_defaults_3.get_party_Id(p_cust_Account_id);
        l_payer_rec.payment_function                  := 'CUSTOMER_PAYMENT';
        l_payer_rec.org_type                          := 'OPERATING_UNIT';
        l_payer_rec.cust_account_id                   :=  p_cust_Account_id;
        l_payer_rec.org_id                            :=  P_ORG_ID;
        l_payer_rec.account_site_id                   :=  p_account_site_use_id;

           /*-------------------------+
            |   Call the IBY API      |
            +-------------------------*/
            arp_standard.debug('Call TO IBY API ()+ ');

            IBY_FNDCPT_TRXN_PUB.delete_transaction_extension(
               p_api_version           => 1.0,
               p_init_msg_list         => p_init_msg_list,
               p_commit                => p_commit,
               x_return_status         => x_return_status,
               x_msg_count             => x_msg_count,
               x_msg_data              => x_msg_data,
               p_payer                 => l_payer_rec,
               p_payer_equivalency     => 'UPWARD',
               p_entity_id             => p_payment_trxn_extn_id,
               x_response              => l_response);

    IF x_return_status  = fnd_api.g_ret_sts_success
    THEN
       arp_standard.debug('Payment_Trxn_Extension_Id : ' || p_payment_trxn_extn_id);
    ElSIF  l_response.result_code= 'EXTENSION_NOT_UPDATEABLE'  and
           l_response.result_Category = 'INCORRECT_FLOW'
    THEN
      fnd_message.set_name('AR','AR_AUTH_RCT_NO_DELETE');
      app_exception.raise_exception;
    Else
       arp_standard.debug('Errors Reported by IBY API in ARP_PROCESS_RCTS.Delete Transaction Extension ');
       raise fnd_api.g_exc_unexpected_error;
    END IF;
EXCEPTION
     WHEN OTHERS THEN
       arp_standard.debug('exception in ARP_PROCESS_RCTS.Delete_Transaction_Extension');
       RAISE;
END Delete_Transaction_Extension;





END ARP_PROCESS_RCTS;

/
