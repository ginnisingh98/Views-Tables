--------------------------------------------------------
--  DDL for Package ARP_RW_ICR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_RW_ICR_PKG" AUTHID CURRENT_USER AS
/* $Header: ARERICRS.pls 120.3.12010000.2 2009/02/02 16:47:22 mpsingh ship $ */
--
PROCEDURE get_applied_amount_total(
	    p_cr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
            p_applied_amount_total OUT NOCOPY ar_interim_cash_receipts.amount%TYPE,
            p_applied_count_total OUT NOCOPY NUMBER,
            p_module_name  IN VARCHAR2,
            p_module_version IN VARCHAR2 );
--
PROCEDURE insert_row(
         p_row_id   IN OUT NOCOPY VARCHAR2,
         p_cr_id   IN OUT NOCOPY ar_interim_cash_receipts.cash_receipt_id%TYPE,
         p_special_type IN ar_interim_cash_receipts.special_type%TYPE,
         p_receipt_number IN ar_interim_cash_receipts.receipt_number%TYPE,
         p_currency_code IN ar_interim_cash_receipts.currency_code%TYPE,
         p_receipt_amount IN ar_interim_cash_receipts.amount%TYPE,
         p_amount_applied IN
                    ar_interim_cash_receipts.amount_applied%TYPE,
         p_trans_to_receipt_rate IN
                    ar_interim_cash_receipts.trans_to_receipt_rate%TYPE,
	 p_factor_discount_amount IN
		   ar_interim_cash_receipts.factor_discount_amount%TYPE,
         p_receipt_method_id IN
                ar_interim_cash_receipts.receipt_method_id%TYPE,
         p_remittance_bank_account_id IN
                ar_interim_cash_receipts.remit_bank_acct_use_id%TYPE,
         p_batch_id IN ar_interim_cash_receipts.batch_id%TYPE,
         p_customer_trx_id IN ar_interim_cash_receipts.customer_trx_id%TYPE,
         p_payment_schedule_id IN
                     ar_payment_schedules.payment_schedule_id%TYPE,
         p_exchange_date IN ar_interim_cash_receipts.exchange_date%TYPE,
         p_exchange_rate IN ar_interim_cash_receipts.exchange_rate%TYPE,
         p_exchange_rate_type IN
                ar_interim_cash_receipts.exchange_rate_type%TYPE,
         p_gl_date IN ar_interim_cash_receipts.gl_date%TYPE,
         p_anticipated_clearing_date IN
	   ar_interim_cash_receipts.anticipated_clearing_date%TYPE,
         p_pay_from_customer IN
                ar_interim_cash_receipts.pay_from_customer%TYPE,
	 p_customer_bank_account_id IN
	   ar_interim_cash_receipts.customer_bank_account_id%TYPE,
	 p_customer_bank_branch_id  IN
	   ar_interim_cash_receipts.customer_bank_branch_id%TYPE,
         p_receipt_date IN ar_interim_cash_receipts.receipt_date%TYPE,
         p_site_use_id IN ar_interim_cash_receipts.site_use_id%TYPE,
         p_ussgl_transaction_code IN
                ar_interim_cash_receipts.ussgl_transaction_code%TYPE,
         p_doc_sequence_id IN ar_interim_cash_receipts.doc_sequence_id%TYPE,
         p_doc_sequence_value IN
                        ar_interim_cash_receipts.doc_sequence_value%TYPE,
         p_attribute_category IN
                        ar_interim_cash_receipts.attribute_category%TYPE,
         p_attribute1 IN ar_interim_cash_receipts.attribute1%TYPE,
         p_attribute2 IN ar_interim_cash_receipts.attribute2%TYPE,
         p_attribute3 IN ar_interim_cash_receipts.attribute3%TYPE,
         p_attribute4 IN ar_interim_cash_receipts.attribute4%TYPE,
         p_attribute5 IN ar_interim_cash_receipts.attribute5%TYPE,
         p_attribute6 IN ar_interim_cash_receipts.attribute6%TYPE,
         p_attribute7 IN ar_interim_cash_receipts.attribute7%TYPE,
         p_attribute8 IN ar_interim_cash_receipts.attribute8%TYPE,
         p_attribute9 IN ar_interim_cash_receipts.attribute9%TYPE,
         p_attribute10 IN ar_interim_cash_receipts.attribute10%TYPE,
         p_attribute11 IN ar_interim_cash_receipts.attribute11%TYPE,
         p_attribute12 IN ar_interim_cash_receipts.attribute12%TYPE,
         p_attribute13 IN ar_interim_cash_receipts.attribute13%TYPE,
         p_attribute14 IN ar_interim_cash_receipts.attribute14%TYPE,
         p_attribute15 IN ar_interim_cash_receipts.attribute15%TYPE,
         p_application_notes IN ar_interim_cash_receipts.application_notes%TYPE,
         p_application_ref_type IN ar_interim_cash_receipts.application_ref_type%TYPE,
         p_customer_reference IN ar_interim_cash_receipts.customer_reference%TYPE,
         p_customer_reason IN ar_interim_cash_receipts.customer_reason%TYPE,
	 p_automatch_set_id IN ar_interim_cash_receipts.automatch_set_id%TYPE,
         p_autoapply_flag IN ar_interim_cash_receipts.autoapply_flag%TYPE,
         p_module_name  IN VARCHAR2,
         p_module_version IN VARCHAR2 );
--
--
-- Bug fix: 597519  	12/17/97
-- Problem: rate information is not being passed to server on commit
-- Changes: passing parameters exchange date, exchange rate and
--
PROCEDURE update_row(
            p_row_id   IN VARCHAR2,
            p_cr_id   IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
            p_special_type IN ar_interim_cash_receipts.special_type%TYPE,
            p_receipt_number IN ar_interim_cash_receipts.receipt_number%TYPE,
            p_receipt_amount IN ar_interim_cash_receipts.amount%TYPE,
            p_amount_applied IN
                       ar_interim_cash_receipts.amount_applied%TYPE,
            p_trans_to_receipt_rate IN
                       ar_interim_cash_receipts.trans_to_receipt_rate%TYPE,
	    p_factor_discount_amount IN
			ar_interim_cash_receipts.factor_discount_amount%TYPE,
            p_receipt_method_id IN
                   ar_interim_cash_receipts.receipt_method_id%TYPE,
            p_remittance_bank_account_id IN
                   ar_interim_cash_receipts.remit_bank_acct_use_id%TYPE,
            p_batch_id IN ar_interim_cash_receipts.batch_id%TYPE,
            p_customer_trx_id IN ar_interim_cash_receipts.customer_trx_id%TYPE,
            p_payment_schedule_id IN
                        ar_payment_schedules.payment_schedule_id%TYPE,
            p_pay_from_customer IN
                   ar_interim_cash_receipts.pay_from_customer%TYPE,
	    p_customer_bank_account_id IN
		   ar_interim_cash_receipts.customer_bank_account_id%TYPE,
	    p_customer_bank_branch_id IN
		   ar_interim_cash_receipts.customer_bank_branch_id%TYPE,
            p_site_use_id IN ar_interim_cash_receipts.site_use_id%TYPE,
            p_ussgl_transaction_code IN
                   ar_interim_cash_receipts.ussgl_transaction_code%TYPE,
            p_doc_sequence_id IN ar_interim_cash_receipts.doc_sequence_id%TYPE,
            p_doc_sequence_value IN
                           ar_interim_cash_receipts.doc_sequence_value%TYPE,
	    p_anticipated_clearing_date IN
		   ar_interim_cash_receipts.anticipated_clearing_date%TYPE,
            p_attribute_category IN
                           ar_interim_cash_receipts.attribute_category%TYPE,
            p_attribute1 IN ar_interim_cash_receipts.attribute1%TYPE,
            p_attribute2 IN ar_interim_cash_receipts.attribute2%TYPE,
            p_attribute3 IN ar_interim_cash_receipts.attribute3%TYPE,
            p_attribute4 IN ar_interim_cash_receipts.attribute4%TYPE,
            p_attribute5 IN ar_interim_cash_receipts.attribute5%TYPE,
            p_attribute6 IN ar_interim_cash_receipts.attribute6%TYPE,
            p_attribute7 IN ar_interim_cash_receipts.attribute7%TYPE,
            p_attribute8 IN ar_interim_cash_receipts.attribute8%TYPE,
            p_attribute9 IN ar_interim_cash_receipts.attribute9%TYPE,
            p_attribute10 IN ar_interim_cash_receipts.attribute10%TYPE,
            p_attribute11 IN ar_interim_cash_receipts.attribute11%TYPE,
            p_attribute12 IN ar_interim_cash_receipts.attribute12%TYPE,
            p_attribute13 IN ar_interim_cash_receipts.attribute13%TYPE,
            p_attribute14 IN ar_interim_cash_receipts.attribute14%TYPE,
            p_attribute15 IN ar_interim_cash_receipts.attribute15%TYPE,
-- Bug fix: 597519 	12/17/97
            p_exchange_date IN ar_interim_cash_receipts.exchange_date%TYPE,
            p_exchange_rate IN ar_interim_cash_receipts.exchange_rate%TYPE,
            p_exchange_rate_type IN
                   ar_interim_cash_receipts.exchange_rate_type%TYPE,
-- Bug fix 750400       12/24/98
            p_gl_date IN ar_interim_cash_receipts.gl_date%TYPE,
-- enh 2074220
            p_application_notes IN ar_interim_cash_receipts.application_notes%TYPE,
-- Bug 2707190 additions
            p_application_ref_type IN ar_interim_cash_receipts.application_ref_type%TYPE,
            p_customer_reference IN ar_interim_cash_receipts.customer_reference%TYPE,
            p_customer_reason IN ar_interim_cash_receipts.customer_reason%TYPE,
	    p_automatch_set_id IN ar_interim_cash_receipts.automatch_set_id%TYPE,
            p_autoapply_flag IN ar_interim_cash_receipts.autoapply_flag%TYPE,
            p_module_name  IN VARCHAR2,
            p_module_version IN VARCHAR2 );
PROCEDURE check_unique_receipt(
            p_row_id IN VARCHAR2,
            p_cr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
            p_special_type IN ar_interim_cash_receipts.special_type%TYPE,
            p_receipt_number IN ar_interim_cash_receipts.receipt_number%TYPE,
            p_customer_id IN hz_cust_accounts.cust_account_id%TYPE,
            p_receipt_amount IN ar_interim_cash_receipts.amount%TYPE,
	    p_factor_discount_amount IN ar_interim_cash_receipts.factor_discount_amount%TYPE,
            p_module_name  IN VARCHAR2,
            p_module_version IN VARCHAR2 );
--
PROCEDURE check_no_lines_exists(
            p_cr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
            p_module_name  IN VARCHAR2,
            p_module_version IN VARCHAR2 );
--
FUNCTION  lines_exists(
            p_cr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
            p_module_name  IN VARCHAR2,
            p_module_version IN VARCHAR2 ) RETURN BOOLEAN;
--
PROCEDURE delete_row(
            p_row_id   IN VARCHAR2,
            p_cr_id IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
            p_module_name  IN VARCHAR2,
            p_module_version IN VARCHAR2 );
--
PROCEDURE lock_row(
           p_row_id   VARCHAR2,
           p_cr_id   ar_interim_cash_receipts.cash_receipt_id%TYPE,
           p_special_type ar_interim_cash_receipts.special_type%TYPE,
           p_receipt_number ar_interim_cash_receipts.receipt_number%TYPE,
           p_currency_code ar_interim_cash_receipts.currency_code%TYPE,
           p_receipt_amount ar_interim_cash_receipts.amount%TYPE,
	   p_factor_discount_amount IN
	         ar_interim_cash_receipts.factor_discount_amount%TYPE,
           p_receipt_method_id
                   ar_interim_cash_receipts.receipt_method_id%TYPE,
           p_remittance_bank_account_id
                  ar_interim_cash_receipts.remit_bank_acct_use_id%TYPE,
           p_batch_id ar_interim_cash_receipts.batch_id%TYPE,
           p_customer_trx_id ar_interim_cash_receipts.customer_trx_id%TYPE,
           p_payment_schedule_id
                       ar_payment_schedules.payment_schedule_id%TYPE,
           p_exchange_date ar_interim_cash_receipts.exchange_date%TYPE,
           p_exchange_rate ar_interim_cash_receipts.exchange_rate%TYPE,
           p_exchange_rate_type
                   ar_interim_cash_receipts.exchange_rate_type%TYPE,
           p_gl_date IN ar_interim_cash_receipts.gl_date%TYPE,
	   p_anticipated_clearing_date IN
		   ar_interim_cash_receipts.anticipated_clearing_date%TYPE,
           p_pay_from_customer
                  ar_interim_cash_receipts.pay_from_customer%TYPE,
	   p_customer_bank_account_id IN
	          ar_interim_cash_receipts.customer_bank_account_id%TYPE,
	   p_customer_bank_branch_id IN
		   ar_interim_cash_receipts.customer_bank_branch_id%TYPE,
           p_receipt_date ar_interim_cash_receipts.receipt_date%TYPE,
           p_site_use_id ar_interim_cash_receipts.site_use_id%TYPE,
           p_ussgl_transaction_code
                  ar_interim_cash_receipts.ussgl_transaction_code%TYPE,
           p_doc_sequence_id ar_interim_cash_receipts.doc_sequence_id%TYPE,
           p_doc_sequence_value
                           ar_interim_cash_receipts.doc_sequence_value%TYPE,
           p_attribute_category
                           ar_interim_cash_receipts.attribute_category%TYPE,
           p_attribute1 ar_interim_cash_receipts.attribute1%TYPE,
           p_attribute2 ar_interim_cash_receipts.attribute2%TYPE,
           p_attribute3 ar_interim_cash_receipts.attribute3%TYPE,
           p_attribute4 ar_interim_cash_receipts.attribute4%TYPE,
           p_attribute5 ar_interim_cash_receipts.attribute5%TYPE,
           p_attribute6 ar_interim_cash_receipts.attribute6%TYPE,
           p_attribute7 ar_interim_cash_receipts.attribute7%TYPE,
           p_attribute8 ar_interim_cash_receipts.attribute8%TYPE,
           p_attribute9 ar_interim_cash_receipts.attribute9%TYPE,
           p_attribute10 ar_interim_cash_receipts.attribute10%TYPE,
           p_attribute11 ar_interim_cash_receipts.attribute11%TYPE,
           p_attribute12 ar_interim_cash_receipts.attribute12%TYPE,
           p_attribute13 ar_interim_cash_receipts.attribute13%TYPE,
           p_attribute14 ar_interim_cash_receipts.attribute14%TYPE,
           p_attribute15 ar_interim_cash_receipts.attribute15%TYPE);
END ARP_RW_ICR_PKG;

/
