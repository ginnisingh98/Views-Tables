--------------------------------------------------------
--  DDL for Package ARP_CASHBOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CASHBOOK" AUTHID CURRENT_USER AS
/*$Header: ARRECBKS.pls 120.2 2003/10/23 23:12:48 orashid ship $*/
--
-- Public procedures/functions
--
/*----------------------------------
   Some notes to use this clear procedure:

   1. The p_amount_cleared and p_amount_factored to be passed in
      should be in the bank currency.

   2. If p_bank_currency <> the currency of the receipt, this
      means the p_bank_currency must be the functional currency,
      In this case, it assumes the following has been
      validated before calling this procedure:

        p_amount_cleared+p_amount_factored =
                          p_exchange_rate * ar_cash_receipts.amount

   3. If p_bank_currency = the currency of the receipt,
      In this case, it assumes the following has been validated
      before calling this procedure:

        p_amount_cleared+p_amount_factored =
                            ar_cash_receipts.amount

 ------------------------------------*/
PROCEDURE clear(
	p_cr_id       		IN ar_cash_receipts.cash_receipt_id%TYPE,
	p_trx_date		IN ar_cash_receipt_history.trx_date%TYPE,
	p_gl_date		IN ar_cash_receipt_history.gl_date%TYPE,
	p_actual_value_date	IN DATE,
    p_exchange_date        IN ar_cash_receipt_history.exchange_date%TYPE,
    p_exchange_rate_type   IN ar_cash_receipt_history.exchange_rate_type%TYPE,
    p_exchange_rate        IN ar_cash_receipt_history.exchange_rate%TYPE,
		p_bank_currency		IN ce_bank_accounts.currency_code%TYPE,
		p_amount_cleared	IN ar_cash_receipt_history.amount%TYPE,
		p_amount_factored	IN ar_cash_receipt_history.factor_discount_amount%TYPE,
		p_module_name   	IN VARCHAR2,
		p_module_version   	IN VARCHAR2,
		p_crh_id		OUT NOCOPY ar_cash_receipt_history.cash_receipt_history_id%TYPE );

PROCEDURE unclear(
		p_cr_id     	IN ar_cash_receipts.cash_receipt_id%TYPE,
		p_trx_date	IN ar_cash_receipt_history.trx_date%TYPE,
		p_gl_date		IN ar_cash_receipt_history.gl_date%TYPE,
		p_actual_value_date IN ar_cash_receipts.actual_value_date%TYPE,
		p_module_name   	IN VARCHAR2,
		p_module_version   	IN VARCHAR2,
	p_crh_id   OUT NOCOPY ar_cash_receipt_history.cash_receipt_history_id%TYPE );

PROCEDURE risk_eliminate(
		p_cr_id       		IN ar_cash_receipts.cash_receipt_id%TYPE,
		p_trx_date		IN ar_cash_receipt_history.trx_date%TYPE,
		p_gl_date		IN ar_cash_receipt_history.gl_date%TYPE,
		p_module_name   	IN VARCHAR2,
		p_module_version   	IN VARCHAR2,
		p_crh_id		OUT NOCOPY ar_cash_receipt_history.cash_receipt_history_id%TYPE );

PROCEDURE undo_risk_eliminate(
		p_cr_id       		IN ar_cash_receipts.cash_receipt_id%TYPE,
		p_trx_date		IN ar_cash_receipt_history.trx_date%TYPE,
		p_gl_date		IN ar_cash_receipt_history.gl_date%TYPE,
		p_module_name   	IN VARCHAR2,
		p_module_version   	IN VARCHAR2,
		p_crh_id		OUT NOCOPY ar_cash_receipt_history.cash_receipt_history_id%TYPE );

PROCEDURE ins_misc_txn(
     p_receipt_number	     IN ar_cash_receipts.receipt_number%TYPE,
     p_document_number	     IN ar_cash_receipts.doc_sequence_value%TYPE,
     p_doc_sequence_id	     IN ar_cash_receipts.doc_sequence_id%TYPE,
     p_gl_date		     IN ar_cash_receipt_history.gl_date%TYPE,
     p_receipt_date	     IN ar_cash_receipts.receipt_date%TYPE,
     p_deposit_date	     IN ar_cash_receipts.deposit_date%TYPE,
     p_receipt_amount	     IN ar_cash_receipts.amount%TYPE,
     p_currency_code	     IN ar_cash_receipts.currency_code%TYPE,
     p_exchange_date	     IN ar_cash_receipt_history.exchange_date%TYPE,
     p_exchange_rate_type    IN ar_cash_receipt_history.exchange_rate_type%TYPE,
     p_exchange_rate	     IN ar_cash_receipt_history.exchange_rate%TYPE,
     p_receipt_method_id     IN ar_cash_receipts.receipt_method_id%TYPE,
     p_remit_bank_account_id IN  ar_cash_receipts.remit_bank_acct_use_id%TYPE,
     p_receivables_trx_id    IN ar_cash_receipts.receivables_trx_id%TYPE,
     p_comments		     IN ar_cash_receipts.comments%TYPE,
     p_vat_tax_id	     IN ar_cash_receipts.vat_tax_id%TYPE,
     p_reference_type	     IN ar_cash_receipts.reference_type%TYPE,
     p_reference_id          IN ar_cash_receipts.reference_id%TYPE,
     p_misc_payment_source   IN ar_cash_receipts.misc_payment_source%TYPE,
     p_anticipated_clearing_date  IN ar_cash_receipts.anticipated_clearing_date%TYPE,
     p_module_name           IN VARCHAR2,
     p_module_version        IN VARCHAR2,
     p_cr_id	             OUT NOCOPY ar_cash_receipts.cash_receipt_id%TYPE,
     p_tax_rate              IN NUMBER );

PROCEDURE reverse(
    p_cr_id       IN ar_cash_receipts.cash_receipt_id%TYPE,
    p_reversal_gl_date      IN ar_cash_receipt_history.reversal_gl_date%TYPE,
	p_reversal_date         IN ar_cash_receipts.reversal_date%TYPE,
	p_reversal_comments     IN ar_cash_receipts.reversal_comments%TYPE,
	p_reversal_reason_code	IN ar_cash_receipts.reversal_reason_code%TYPE,
	p_reversal_category	IN ar_cash_receipts.reversal_category%TYPE,
	p_module_name   	IN VARCHAR2,
	p_module_version   	IN VARCHAR2,
	p_crh_id  OUT NOCOPY ar_cash_receipt_history.cash_receipt_history_id%TYPE);

PROCEDURE debit_memo_reversal(
   p_cash_receipt_id       IN ar_cash_receipts.cash_receipt_id%TYPE,
   p_cc_id                 IN ra_cust_trx_line_gl_dist.code_combination_id%TYPE,
   p_dm_cust_trx_type_id   IN ra_cust_trx_types.cust_trx_type_id%TYPE,
   p_dm_cust_trx_type      IN ra_cust_trx_types.name%TYPE,
   p_reversal_gl_date      IN ar_cash_receipt_history.reversal_gl_date%TYPE,
   p_reversal_date         IN ar_cash_receipts.reversal_date%TYPE,
   p_reversal_category     IN ar_cash_receipts.reversal_category%TYPE,
   p_reversal_reason_code  IN ar_cash_receipts.reversal_reason_code%TYPE,
   p_reversal_comments     IN ar_cash_receipts.reversal_comments%TYPE,
   p_dm_number             OUT NOCOPY ar_payment_schedules.trx_number%TYPE,
   p_dm_doc_sequence_value IN ra_customer_trx.doc_sequence_value%TYPE,
   p_dm_doc_sequence_id    IN ra_customer_trx.doc_sequence_id%TYPE,
   p_tw_status             IN OUT NOCOPY VARCHAR2,
   p_module_name           IN VARCHAR2,
   p_module_version        IN VARCHAR2);

PROCEDURE Lock_Row(
	P_BATCH_ID			IN ar_batches.batch_id%TYPE,
	P_AMOUNT			IN ar_cash_receipt_history.amount%TYPE,
	P_ACCTD_AMOUNT  		IN ar_cash_receipt_history.acctd_amount%TYPE,
	P_NAME				IN ar_batches.name%TYPE,
	P_BATCH_DATE  			IN ar_batches.batch_date%TYPE,
	P_GL_DATE			IN ar_batches.gl_date%TYPE,
	P_STATUS			IN ar_batches.status%TYPE,
	P_DEPOSIT_DATE  		IN ar_batches.deposit_date%TYPE,
	P_CLOSED_DATE   		IN ar_batches.closed_date%TYPE,
	P_TYPE				IN ar_batches.type%TYPE,
	P_BATCH_SOURCE_ID		IN ar_batches.batch_source_id%TYPE,
	P_CONTROL_COUNT			IN ar_batches.control_count%TYPE,
	P_CONTROL_AMOUNT		IN ar_batches.control_amount%TYPE,
	P_BATCH_APPLIED_STATUS		IN ar_batches.batch_applied_status%TYPE,
	P_CURRENCY_CODE			IN ar_batches.currency_code%TYPE,
	P_EXCHANGE_RATE_TYPE		IN ar_batches.exchange_rate_type%TYPE,
	P_EXCHANGE_DATE			IN ar_batches.exchange_date%TYPE,
	P_EXCHANGE_RATE			IN ar_batches.exchange_rate%TYPE,
	P_TRANSMISSION_REQUEST_ID	IN ar_batches.transmission_request_id%TYPE,
	P_LOCKBOX_ID			IN ar_batches.lockbox_id%TYPE,
	P_LOCKBOX_BATCH_NAME		IN ar_batches.lockbox_batch_name%TYPE,
	P_COMMENTS			IN ar_batches.comments%TYPE,
	P_ATTRIBUTE_CATEGORY		IN ar_batches.attribute_category%TYPE,
	P_ATTRIBUTE1			IN ar_batches.attribute1%TYPE,
	P_ATTRIBUTE2			IN ar_batches.attribute2%TYPE,
	P_ATTRIBUTE3			IN ar_batches.attribute3%TYPE,
	P_ATTRIBUTE4			IN ar_batches.attribute4%TYPE,
	P_ATTRIBUTE5			IN ar_batches.attribute5%TYPE,
	P_ATTRIBUTE6			IN ar_batches.attribute6%TYPE,
	P_ATTRIBUTE7			IN ar_batches.attribute7%TYPE,
	P_ATTRIBUTE8			IN ar_batches.attribute8%TYPE,
	P_ATTRIBUTE9			IN ar_batches.attribute9%TYPE,
	P_ATTRIBUTE10			IN ar_batches.attribute10%TYPE,
	P_MEDIA_REFERENCE		IN ar_batches.media_reference%TYPE,
	P_OPERATION_REQUEST_ID		IN ar_batches.operation_request_id%TYPE,
	P_RECEIPT_METHOD_ID		IN ar_batches.receipt_method_id%TYPE,
	P_REMITTANCE_BANK_ACCOUNT_ID	IN ar_batches.remit_bank_acct_use_id%TYPE,
	P_RECEIPT_CLASS_ID		IN ar_batches.receipt_class_id%TYPE,
	P_ATTRIBUTE11			IN ar_batches.attribute11%TYPE,
	P_ATTRIBUTE12			IN ar_batches.attribute12%TYPE,
	P_ATTRIBUTE13			IN ar_batches.attribute13%TYPE,
	P_ATTRIBUTE14			IN ar_batches.attribute14%TYPE,
	P_ATTRIBUTE15			IN ar_batches.attribute15%TYPE,
	P_PROGRAM_APPLICATION_ID	IN ar_batches.program_application_id%TYPE,
	P_PROGRAM_ID			IN ar_batches.program_id%TYPE,
	P_PROGRAM_UPDATE_DATE		IN ar_batches.program_update_date%TYPE,
	P_REMITTANCE_BANK_BRANCH_ID	IN ar_batches.remittance_bank_branch_id%TYPE,
	P_REMIT_METHOD_CODE		IN ar_batches.remit_method_code%TYPE,
	P_REQUEST_ID			IN ar_batches.request_id%TYPE,
	P_SET_OF_BOOKS_ID		IN ar_batches.set_of_books_id%TYPE,
	P_TRANSMISSION_ID		IN ar_batches.transmission_id%TYPE,
	P_BANK_DEPOSIT_NUMBER		IN ar_batches.bank_deposit_number%TYPE
       );

FUNCTION receipt_debit_memo_reversed( p_cash_receipt_id IN NUMBER)
                           RETURN VARCHAR2;



PROCEDURE update_actual_value_date(p_cash_receipt_id IN NUMBER,
				p_actual_value_date IN DATE);

FUNCTION revision RETURN VARCHAR2;

--
END ARP_CASHBOOK;

 

/
