--------------------------------------------------------
--  DDL for Package ARP_PROC_RECEIPTS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROC_RECEIPTS1" AUTHID CURRENT_USER AS
/* $Header: ARRERG1S.pls 120.3.12010000.2 2009/02/02 14:29:02 mpsingh ship $ */


FUNCTION revision RETURN VARCHAR2;

PROCEDURE update_cash_receipt(
	p_cash_receipt_id	IN NUMBER,
	p_status		IN VARCHAR2,
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
--
	p_confirm_date		      IN  DATE,
	p_confirm_gl_date	      IN  DATE,
	p_unconfirm_gl_date	      IN DATE,
        p_postmark_date               IN DATE, -- ARTA Changes
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
	p_dm_reversal_flag  	IN varchar2,
	p_dm_cust_trx_type_id	IN NUMBER,
	p_dm_cust_trx_type	IN VARCHAR2,
	p_cc_id			IN NUMBER,
	p_dm_number		OUT NOCOPY VARCHAR2,
	p_dm_doc_sequence_value IN NUMBER,
	p_dm_doc_sequence_id	IN NUMBER,
	p_tw_status		IN OUT NOCOPY VARCHAR2,
--
	p_anticipated_clearing_date	IN DATE,
	p_customer_bank_branch_id	IN NUMBER,
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
-- ******* Notes Receivable Information *******
        p_issuer_name             	IN  VARCHAR2,
        p_issue_date              	IN  DATE,
        p_issuer_bank_branch_id   	IN  NUMBER,
--
--  ****** Enhancement 2074220 *************
        p_application_notes             IN  VARCHAR2,
--
-- ******* Receipt State/Status Return information ******
--
        p_new_state                     OUT NOCOPY VARCHAR2,
        p_new_state_dsp                 OUT NOCOPY VARCHAR2,
        p_new_status                    OUT NOCOPY VARCHAR2,
        p_new_status_dsp                OUT NOCOPY VARCHAR2,
--
-- ******* Form information ********
        p_form_name                     IN  VARCHAR2,
        p_form_version                  IN  VARCHAR2,
--
-- ******* Credit Card changes
        p_payment_server_order_num      IN  VARCHAR2,
        p_approval_code                 IN  VARCHAR2,
        p_legal_entity_id               IN  NUMBER DEFAULT NULL,
        p_payment_trxn_extension_id     IN  NUMBER DEFAULT NULL, /* PAYMENT_UPTAKE */
	p_automatch_set_id             IN NUMBER  DEFAULT NULL, /* ER Automatch Application */
	p_autoapply_flag               IN VARCHAR2  DEFAULT NULL
			);

END ARP_PROC_RECEIPTS1;

/
