--------------------------------------------------------
--  DDL for Package ARP_PROCESS_MISC_RECEIPTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_MISC_RECEIPTS" AUTHID CURRENT_USER AS
/* $Header: ARREMTRS.pls 120.5 2005/12/08 03:32:37 bichatte ship $ */

FUNCTION revision RETURN VARCHAR2;

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
--
	p_row_id		OUT NOCOPY VARCHAR2,
	p_form_name		IN  varchar2,
	p_form_version		IN  varchar2,
        p_tax_rate		IN  NUMBER,
        p_gl_tax_acct           IN  VARCHAR2,/* Bug fix 2300268 */
        p_crh_id                OUT NOCOPY NUMBER, /* Bug fix 2742388 */
	p_legal_entity_id	IN  NUMBER DEFAULT NULL, /* R12 LE uptake */
        p_payment_trxn_extension_id  IN ar_cash_receipts.payment_trxn_extension_id%TYPE DEFAULT NULL
);


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
-- ******* Receipt State/Status Return information ******
--
	p_new_state		OUT NOCOPY VARCHAR2,
	p_new_state_dsp		OUT NOCOPY VARCHAR2,
	p_new_status		OUT NOCOPY VARCHAR2,
	p_new_status_dsp	OUT NOCOPY VARCHAR2,
--
	p_form_name		IN  varchar2,
	p_form_version		IN  varchar2,
	p_tax_rate 		IN  NUMBER,
        p_gl_tax_acct           IN  VARCHAR2,  /* Bug fix 2300268 */
	p_legal_entity_id	IN  NUMBER DEFAULT NULL); /* R12 LE uptake */



----------------- Private functions/procedures ------------------


END ARP_PROCESS_MISC_RECEIPTS;

 

/
