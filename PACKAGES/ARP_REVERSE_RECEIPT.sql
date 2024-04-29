--------------------------------------------------------
--  DDL for Package ARP_REVERSE_RECEIPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_REVERSE_RECEIPT" AUTHID CURRENT_USER AS
/* $Header: ARREREVS.pls 120.3.12010000.2 2009/01/22 11:12:44 spdixit ship $*/
--
PROCEDURE reverse (
        p_cr_id       IN ar_cash_receipts.cash_receipt_id%TYPE,
        p_reversal_category     IN ar_cash_receipts.reversal_category%TYPE,
        p_reversal_gl_date      IN ar_cash_receipt_history.reversal_gl_date%TYPE,
        p_reversal_date         IN ar_cash_receipts.reversal_date%TYPE,
        p_reversal_reason_code  IN ar_cash_receipts.reversal_reason_code%TYPE,
        p_reversal_comments     IN ar_cash_receipts.reversal_comments%TYPE,
        p_clear_batch_id        IN ar_cash_receipt_history.batch_id%TYPE,
        p_attribute_category    IN ar_cash_receipts.attribute_category%TYPE,
        p_attribute1            IN ar_cash_receipts.attribute1%TYPE,
        p_attribute2            IN ar_cash_receipts.attribute2%TYPE,
        p_attribute3            IN ar_cash_receipts.attribute3%TYPE,
        p_attribute4            IN ar_cash_receipts.attribute4%TYPE,
        p_attribute5            IN ar_cash_receipts.attribute5%TYPE,
        p_attribute6            IN ar_cash_receipts.attribute6%TYPE,
        p_attribute7            IN ar_cash_receipts.attribute7%TYPE,
        p_attribute8            IN ar_cash_receipts.attribute8%TYPE,
        p_attribute9            IN ar_cash_receipts.attribute9%TYPE,
        p_attribute10           IN ar_cash_receipts.attribute10%TYPE,
        p_attribute11           IN ar_cash_receipts.attribute11%TYPE,
        p_attribute12           IN ar_cash_receipts.attribute12%TYPE,
        p_attribute13           IN ar_cash_receipts.attribute13%TYPE,
        p_attribute14           IN ar_cash_receipts.attribute14%TYPE,
        p_attribute15           IN ar_cash_receipts.attribute15%TYPE,
        p_module_name           IN VARCHAR2,
        p_module_version        IN VARCHAR2,
        p_crh_id                OUT NOCOPY ar_cash_receipt_history.cash_receipt_history_id%TYPE,
 	p_called_from           IN VARCHAR2 DEFAULT NULL);  /* jrautiai BR implementation */
--
PROCEDURE debit_memo_reversal(
        p_cr_rec            IN OUT NOCOPY ar_cash_receipts%ROWTYPE,
        p_cc_id            IN ra_cust_trx_line_gl_dist.code_combination_id%TYPE,
        p_cust_trx_type_id IN ra_cust_trx_types.cust_trx_type_id%TYPE,
	p_cust_trx_type	   IN ra_cust_trx_types.name%TYPE,
        p_reversal_gl_date IN ar_cash_receipt_history.reversal_gl_date%TYPE,
        p_reversal_date    IN ar_cash_receipts.reversal_date%TYPE,
	p_reversal_category IN ar_cash_receipts.reversal_category%TYPE,
        p_reversal_reason_code  IN
                              ar_cash_receipts.reversal_reason_code%TYPE,
	p_reversal_comments     IN ar_cash_receipts.reversal_comments%TYPE,
	p_attribute_category	IN ar_cash_receipts.attribute_category%TYPE,
	p_attribute1    	IN ar_cash_receipts.attribute1%TYPE,
	p_attribute2    	IN ar_cash_receipts.attribute2%TYPE,
	p_attribute3    	IN ar_cash_receipts.attribute3%TYPE,
	p_attribute4    	IN ar_cash_receipts.attribute4%TYPE,
	p_attribute5    	IN ar_cash_receipts.attribute5%TYPE,
	p_attribute6    	IN ar_cash_receipts.attribute6%TYPE,
	p_attribute7    	IN ar_cash_receipts.attribute7%TYPE,
	p_attribute8    	IN ar_cash_receipts.attribute8%TYPE,
	p_attribute9    	IN ar_cash_receipts.attribute9%TYPE,
	p_attribute10   	IN ar_cash_receipts.attribute10%TYPE,
	p_attribute11   	IN ar_cash_receipts.attribute11%TYPE,
	p_attribute12   	IN ar_cash_receipts.attribute12%TYPE,
	p_attribute13   	IN ar_cash_receipts.attribute13%TYPE,
	p_attribute14   	IN ar_cash_receipts.attribute14%TYPE,
	p_attribute15   	IN ar_cash_receipts.attribute15%TYPE,
	p_dm_number		OUT NOCOPY ar_payment_schedules.trx_number%TYPE,
	p_dm_doc_sequence_value IN ra_customer_trx.doc_sequence_value%TYPE,
	p_dm_doc_sequence_id	IN ra_customer_trx.doc_sequence_id%TYPE,
	p_status		IN OUT NOCOPY VARCHAR2,
        p_module_name      IN VARCHAR2,
        p_module_version   IN VARCHAR2 );
--
FUNCTION receipt_has_non_cancel_claims(
         p_cr_id              IN  ar_cash_receipts.cash_receipt_id%TYPE,
         p_include_trx_claims IN  VARCHAR2 DEFAULT 'Y')
RETURN BOOLEAN;
--
PROCEDURE cancel_claims (p_cr_id IN NUMBER,
                         p_include_trx_claims IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data OUT NOCOPY VARCHAR2);
--
FUNCTION receipt_has_claims(
         p_cr_id              IN  ar_cash_receipts.cash_receipt_id%TYPE)
RETURN BOOLEAN;
--
PROCEDURE check_netted_receipts(
         p_cr_id              IN  ar_cash_receipts.cash_receipt_id%TYPE,
         x_return_status      OUT NOCOPY VARCHAR2);
--
FUNCTION receipt_has_processed_refunds(
         p_cr_id              IN  ar_cash_receipts.cash_receipt_id%TYPE)
RETURN BOOLEAN;
--

FUNCTION check_settlement_status(
         p_extension_id              IN  NUMBER)
RETURN BOOLEAN;


END ARP_REVERSE_RECEIPT;

/
