--------------------------------------------------------
--  DDL for Package ARP_PROCESS_MISC_RECEIPTS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_MISC_RECEIPTS2" AUTHID CURRENT_USER AS
/* $Header: ARREMT2S.pls 120.5.12010000.1 2008/07/24 16:51:49 appldev ship $ */

FUNCTION revision RETURN VARCHAR2;

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
        p_receipt_status        IN  VARCHAR2,    /* bug 2688648 */
        p_cash_receipt_history_id       IN NUMBER,
        p_state                         IN VARCHAR2,
        p_posting_control_id            IN NUMBER,     /* Bug fix 2742388 */
        p_rec_version_number            IN NUMBER /* Bug fix 3032059 */
			);

PROCEDURE delete_misc_receipt(
	p_cash_receipt_id	IN NUMBER,
	p_batch_id		IN NUMBER);




----------------- Private functions/procedures ------------------


END ARP_PROCESS_MISC_RECEIPTS2;

/
