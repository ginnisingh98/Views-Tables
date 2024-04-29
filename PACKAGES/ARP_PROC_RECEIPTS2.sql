--------------------------------------------------------
--  DDL for Package ARP_PROC_RECEIPTS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROC_RECEIPTS2" AUTHID CURRENT_USER AS
/* $Header: ARRERG2S.pls 120.3.12010000.2 2009/02/02 14:34:52 mpsingh ship $ */

FUNCTION revision RETURN VARCHAR2;

PROCEDURE insert_cash_receipt(
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
    -- ARTA Changes
        p_postmark_date               IN DATE,
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
--      ***  Notes Receivable Additional Information  ***
--
        p_issuer_name                   IN VARCHAR2,
        p_issue_date                    IN DATE,
        p_issuer_bank_branch_id         IN NUMBER,
--
--      *** enhancement 2074220 ***
        p_application_notes             IN VARCHAR2,
--
	p_cr_id			        OUT NOCOPY NUMBER,
	p_ps_id			        OUT NOCOPY NUMBER,
	p_row_id		        OUT NOCOPY VARCHAR2,
--
	p_form_name		        IN varchar2,
	p_form_version		        IN varchar2,
	p_called_from                   IN VARCHAR2 DEFAULT NULL,  /* BR  */
        p_le_id                         IN NUMBER DEFAULT NULL,
	p_payment_trxn_extension_id    IN NUMBER  DEFAULT NULL, /* bichatte payment uptake */
	p_automatch_set_id             IN NUMBER  DEFAULT NULL, /* ER Automatch Application */
	p_autoapply_flag               IN VARCHAR2  DEFAULT NULL
				);

PROCEDURE remit_cash_receipt(
        p_cash_receipt_id               IN NUMBER,
        x_return_status                 OUT NOCOPY VARCHAR2
        );

END ARP_PROC_RECEIPTS2;

/
