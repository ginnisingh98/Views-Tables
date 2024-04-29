--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_MISC_RECEIPTS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_MISC_RECEIPTS2" AS
/* $Header: ARREMT2B.pls 120.12.12010000.2 2008/11/11 10:22:58 rasarasw ship $ */
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/* Declare subtype for vat tax accounting usage */
   SUBTYPE l_ae_doc_rec_type    IS arp_acct_main.ae_doc_rec_type ;

/* ---------------------- Public functions -------------------------------- */


FUNCTION revision RETURN VARCHAR2 IS
BEGIN

   RETURN '$Revision: 120.12.12010000.2 $';

END revision;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_misc_receipt                          			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Locks a misc receipt for update.  Checks if values displayed in form   |
 |    are still the ones stored in the database.                             |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED 	                             |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    12-OCT-95	OSTEINME	created					     |
 |    05-FEB-2003  RVSHARMA     Added parameter receipt_status.Bug 2688648.  |   |                                                                           |
 +===========================================================================*/


PROCEDURE lock_misc_receipt(
	p_cash_receipt_id	IN NUMBER,
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
	p_anticipated_clearing_date	IN DATE,
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
----
	p_form_name		IN  varchar2,
	p_form_version		IN  varchar2,
        p_receipt_status        IN  VARCHAR2 ,
        p_cash_receipt_history_id IN NUMBER,
        p_state                   IN VARCHAR2,
        p_posting_control_id      IN NUMBER,     /* Bug fix 2742388 */
        p_rec_version_number      IN NUMBER      /* Bug fix 3032059 */
			) IS
  l_cr_rec	ar_cash_receipts%ROWTYPE;
  l_crh_rec	ar_cash_receipt_history%ROWTYPE;
  l_ps_rec	ar_payment_schedules%ROWTYPE;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_process_misc_receipts2.lock_misc_receipt()+');
  END IF;

  arp_cash_receipts_pkg.set_to_dummy(l_cr_rec);

  l_cr_rec.cash_receipt_id	:= p_cash_receipt_id;
  l_cr_rec.currency_code 	:= p_currency_code;
  l_cr_rec.amount 		:= p_amount;
  l_cr_rec.receivables_trx_id	:= p_receivables_trx_id;
  l_cr_rec.misc_payment_source  := p_misc_payment_source;
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
  l_cr_rec.remit_bank_acct_use_id	:= p_remittance_bank_account_id;
  l_cr_rec.deposit_date		:= p_deposit_date;
  l_cr_rec.receipt_method_id	:= p_receipt_method_id;
  l_cr_rec.doc_sequence_value	:= p_doc_sequence_value;
  l_cr_rec.doc_sequence_id	:= p_doc_sequence_id;
  l_cr_rec.distribution_set_id	:= p_distribution_set_id;
  l_cr_rec.reference_type	:= p_reference_type;
  l_cr_rec.vat_tax_id		:= p_vat_tax_id;
  l_cr_rec.ussgl_transaction_code := p_ussgl_transaction_code;

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
  l_cr_rec.status               := p_receipt_status;  /* Bug 2688648 */
  /* Bug fix 3032059 */
  l_cr_rec.rec_version_number   := p_rec_version_number;

  /* Bug fix 2742388 */
  arp_cr_history_pkg.set_to_dummy( l_crh_rec );
  l_crh_rec.cash_receipt_id := p_cash_receipt_id;
  l_crh_rec.cash_receipt_history_id := p_cash_receipt_history_id;
  l_crh_rec.status := p_state;
  l_crh_rec.amount := p_amount;
  l_crh_rec.posting_control_id := p_posting_control_id;
  arp_cr_history_pkg.lock_hist_compare_p(l_crh_rec);
  /* End bug fix 2742388 */

  arp_cash_receipts_pkg.lock_compare_p(l_cr_rec);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_process_misc_receipts2.lock_misc_receipt()-');
  END IF;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.Raise_Exception;
     WHEN  OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('EXCEPTION: arp_process_misc_receipts2.lock_misc_receipt()');
       END IF;
       RAISE;
END lock_misc_receipt;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_misc_receipt                              			     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Entity handler that delete miscelleanous transactions.		     |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |									     |
 |    25-OCT-95	OSTEINME	created					     |
 |    18-Sep-01 Debbie Jancis	Modified for MRC trigger removal for         |
 |				ar_misc_cash_distributions. Called           |
 |                              ar mrc engine for processing.                |
 |    21-Jan-02  Rahna Kader    Modified delete_misc_receipt procedure       |
 |                              for deleting records in                      |
 |                              ar_misc_cash_distributions table in cash     |
 |                              basis accounting.Refer Bug2189383 for details|
 +===========================================================================*/

PROCEDURE delete_misc_receipt(
	p_cash_receipt_id	IN NUMBER,
	p_batch_id		IN NUMBER) IS

  l_ae_doc_rec l_ae_doc_rec_type;
  l_count  NUMBER;
  l_misc_cash_key_value_list      gl_ca_utility_pkg.r_key_value_arr; /* MRC */
  l_accounting_method       varchar2(30); -- Bug 2189383
  l_ar_dist_key_value_list          gl_ca_utility_pkg.r_key_value_arr; /* MRC */
  l_dist_cnt                NUMBER;  --bug5655154
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_process_misc_receipts2.delete_misc_receipt()+');
  END IF;

  -- lock receipt record to make sure no one else has it locked

  arp_cash_receipts_pkg.lock_p(p_cash_receipt_id);

  -- Bug 2189383
  -- Get the accounting method
   select arp_standard.sysparm.accounting_method into l_accounting_method from dual;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('delete_misc_receipt: ' || 'Acconting Method = '|| l_accounting_method);
   END IF;

  -- VAT: AR_DISTRIBUTION accounting entry records needs to be deleted
  --      before deleting AR_CASH_RECEIPTS row

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('delete_misc_receipt: ' || ' =====> BEGIN <=====');
  END IF;

/************* begin bug5655154, commented and replaced with below code
  -- Bug 2189383
  -- There will be no 'MCD' records in ar_distributions for cash basis accounting

  IF l_accounting_method ='CASH' THEN
     SELECT  count(mcd.misc_cash_distribution_id)
     INTO    l_count
     FROM    ar_misc_cash_distributions mcd
     WHERE   mcd.cash_receipt_id = p_cash_receipt_id
     AND     mcd.reversal_gl_date IS NULL  --For rate adjustments picks up records with new rate
     AND     mcd.posting_control_id = -3  ;  --Not posted
  ELSE
     SELECT  count(mcd.misc_cash_distribution_id)
     INTO    l_count
     FROM    ar_misc_cash_distributions mcd
     WHERE   mcd.cash_receipt_id = p_cash_receipt_id
     AND     mcd.reversal_gl_date IS NULL  --For rate adjustments picks up records with new rate
     AND     mcd.posting_control_id = -3   --Not posted
     AND EXISTS (SELECT 'x'
               FROM  ar_distributions ard
               WHERE ard.source_id = mcd.misc_cash_distribution_id
               AND   ard.source_table = 'MCD');
  END IF;
*********** end bug5655154  ******/

--begin bug5655154
   SELECT  count(mcd.misc_cash_distribution_id)
   INTO    l_dist_cnt
   FROM    ar_misc_cash_distributions mcd
   WHERE   mcd.cash_receipt_id = p_cash_receipt_id
   AND     mcd.reversal_gl_date IS NULL  --For rate adjustments picks up records with new rate
   AND     mcd.posting_control_id = -3   --Not posted
   AND EXISTS (SELECT 'x'
               FROM  ar_distributions ard
               WHERE ard.source_id = mcd.misc_cash_distribution_id
               AND   ard.source_table = 'MCD');

     IF l_dist_cnt = 0 and l_accounting_method = 'CASH' THEN
        SELECT  count(mcd.misc_cash_distribution_id)
        INTO    l_count
        FROM    ar_misc_cash_distributions mcd
        WHERE   mcd.cash_receipt_id = p_cash_receipt_id
        AND     mcd.reversal_gl_date IS NULL  --For rate adjustments picks up records with new rate
        AND     mcd.posting_control_id = -3  ;  --Not posted
     ELSE
       l_count := l_dist_cnt ;
     END IF ;
-- end bug5655154

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('delete_misc_receipt: ' || ' l_count ' || TO_CHAR(l_count));
     arp_standard.debug('delete_misc_receipt: ' ||  'Delete Misc Cash Receipt start () +');
  END IF;
  --
  IF (l_dist_cnt > 0) THEN                        -- bug5655154, replaced l_count with l_dist_cnt
      l_ae_doc_rec.document_type           := 'RECEIPT';
      l_ae_doc_rec.document_id             := p_cash_receipt_id;
      l_ae_doc_rec.accounting_entity_level := 'ONE';
      l_ae_doc_rec.source_table            := 'MCD';
      l_ae_doc_rec.source_id               := '';

        -- Call the delete routine
        arp_acct_main.Delete_Acct_Entry(l_ae_doc_rec);
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('delete_misc_receipt: ' ||  'Delete Misc Cash Receipt start () -');
      END IF;
  END IF;

  -- delete AR_CASH_RECEIPTS receipt record:

  arp_cash_receipts_pkg.delete_p(p_cash_receipt_id);

  -- delete AR_DISTRIBUTIONS records created for each
  -- AR_CASH_RECEIPT_HISTORY record.

  -- only delete when there is a AR_MIS_CASH_DISTRIBUTION
  -- and AR_DISTRIBUTION record.
  -- ie. when receipt amount is 0, no records for MCD
  -- and ARD, hence no deletion is required

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('delete_misc_receipt: ' || ' l_count ' || TO_CHAR(l_count));
  END IF;

  IF (l_count > 0) THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('delete_misc_receipt: ' || ' Delete AR_DISTRIBUTION');
      END IF;

         DELETE AR_DISTRIBUTIONS
         WHERE source_table = 'CRH'
         AND source_id IN (
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

  -- delete all AR_MISC_CASH distributions records created for
  -- this receipt:
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('delete_misc_receipt: ' || ' Delete MISC_CASH_DISTRIBUTION');
      END IF;

      /*--------------------------------+
       | Added Bulk collect of the the  |
       | misc cash distribution id for  |
       | for use in the MRC engine      |
       +--------------------------------*/

      DELETE AR_MISC_CASH_DISTRIBUTIONS
      WHERE cash_receipt_id = p_cash_receipt_id
      RETURNING misc_cash_distribution_id
      BULK COLLECT INTO l_misc_cash_key_value_list;

     /*---------------------------------+
      | Calling central MRC library     |
      | for MRC Integration             |
      +---------------------------------*/

      ar_mrc_engine.maintain_mrc_data(
             p_event_mode        => 'DELETE',
             p_table_name        => 'AR_MISC_CASH_DISTRIBUTIONS',
             p_mode              => 'BATCH',
             p_key_value_list    => l_misc_cash_key_value_list);


  END IF;

  -- delete all AR_CASH_RECEIPT_HISTORY records created for this
  -- receipt:

  -- Bug 2021718: call the entity handler for ar_cash_receipt_history rather
  -- then doing the delete in this package.
  /*6879698*/
    ARP_XLA_EVENTS.delete_event
     ( p_document_id  => p_cash_receipt_id,
        p_doc_table    => 'CRH');

  arp_cr_history_pkg.delete_p_cr(p_cash_receipt_id);
  --  DELETE AR_CASH_RECEIPT_HISTORY
  --  WHERE cash_receipt_id = p_cash_receipt_id;
  -- update batch status

  IF (p_batch_id IS NOT NULL) THEN
    arp_rw_batches_check_pkg.update_batch_status(
		p_batch_id);
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_process_receipts.delete_misc_receipt()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('EXCEPTION: arp_process_misc_receipts2.delete_misc_receipts');
       END IF;
       RAISE;

END delete_misc_receipt;


END ARP_PROCESS_MISC_RECEIPTS2;

/
