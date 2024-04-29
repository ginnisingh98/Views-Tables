--------------------------------------------------------
--  DDL for Package ARP_RW_BATCHES_CHECK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_RW_BATCHES_CHECK_PKG" AUTHID CURRENT_USER AS
/* $Header: ARERBA1S.pls 120.3.12010000.2 2009/03/17 12:19:52 npanchak ship $ */
PROCEDURE update_manual_batch(
        p_row_id IN VARCHAR2,
        p_batch_id IN ar_batches.batch_id%TYPE,
        p_batch_source_id IN ar_batches.batch_source_id%TYPE,
        p_batch_date IN ar_batches.batch_date%TYPE,
        p_gl_date IN ar_batches.gl_date%TYPE,
        p_deposit_date IN ar_batches.batch_date%TYPE,
        p_currency_code IN ar_batches.currency_code%TYPE,
        p_comments IN ar_batches.comments%TYPE,
        p_control_amount IN ar_batches.control_amount%TYPE,
        p_control_count IN ar_batches.control_count%TYPE,
        p_exchange_date IN ar_batches.exchange_date%TYPE,
        p_exchange_rate IN ar_batches.exchange_rate%TYPE,
        p_exchange_rate_type IN ar_batches.exchange_rate_type%TYPE,
        p_receipt_class_id IN ar_batches.receipt_class_id%TYPE,
        p_receipt_method_id IN ar_batches.receipt_method_id%TYPE,
        p_remittance_bank_account_id
                   IN ar_batches.remit_bank_acct_use_id%TYPE,
        p_remittance_bank_branch_id
                   IN ar_batches.remittance_bank_branch_id%TYPE,
        p_attribute_category IN ar_batches.attribute_category%TYPE,
        p_attribute1 IN ar_batches.attribute1%TYPE,
        p_attribute2 IN ar_batches.attribute2%TYPE,
        p_attribute3 IN ar_batches.attribute3%TYPE,
        p_attribute4 IN ar_batches.attribute4%TYPE,
        p_attribute5 IN ar_batches.attribute5%TYPE,
        p_attribute6 IN ar_batches.attribute6%TYPE,
        p_attribute7 IN ar_batches.attribute7%TYPE,
        p_attribute8 IN ar_batches.attribute8%TYPE,
        p_attribute9 IN ar_batches.attribute9%TYPE,
        p_attribute10 IN ar_batches.attribute10%TYPE,
        p_attribute11 IN ar_batches.attribute11%TYPE,
        p_attribute12 IN ar_batches.attribute12%TYPE,
        p_attribute13 IN ar_batches.attribute13%TYPE,
        p_attribute14 IN ar_batches.attribute14%TYPE,
        p_attribute15 IN ar_batches.attribute15%TYPE,
        p_module_name IN VARCHAR2,
        p_module_version IN VARCHAR2 );

PROCEDURE update_remit_batch(
        p_row_id IN VARCHAR2,
        p_batch_id IN ar_batches.batch_id%TYPE,
        p_batch_source_id IN ar_batches.batch_source_id%TYPE,
        p_batch_date IN ar_batches.batch_date%TYPE,
        p_gl_date IN ar_batches.gl_date%TYPE,
        p_deposit_date IN ar_batches.batch_date%TYPE,
        p_currency_code IN ar_batches.currency_code%TYPE,
        p_comments IN ar_batches.comments%TYPE,
        p_control_amount IN ar_batches.control_amount%TYPE,
        p_control_count IN ar_batches.control_count%TYPE,
        p_exchange_date IN ar_batches.exchange_date%TYPE,
        p_exchange_rate IN ar_batches.exchange_rate%TYPE,
        p_exchange_rate_type IN ar_batches.exchange_rate_type%TYPE,
        p_receipt_class_id IN ar_batches.receipt_class_id%TYPE,
        p_receipt_method_id IN ar_batches.receipt_method_id%TYPE,
        p_remittance_bank_account_id
                   IN ar_batches.remit_bank_acct_use_id%TYPE,
        p_remittance_bank_branch_id
                   IN ar_batches.remittance_bank_branch_id%TYPE,
        p_media_reference IN ar_batches.media_reference%TYPE,
        p_bank_deposit_number IN ar_batches.bank_deposit_number%TYPE,
        p_request_id IN ar_batches.request_id%TYPE,
        p_operation_request_id IN ar_batches.operation_request_id%TYPE,
        p_attribute_category IN ar_batches.attribute_category%TYPE,
        p_attribute1 IN ar_batches.attribute1%TYPE,
        p_attribute2 IN ar_batches.attribute2%TYPE,
        p_attribute3 IN ar_batches.attribute3%TYPE,
        p_attribute4 IN ar_batches.attribute4%TYPE,
        p_attribute5 IN ar_batches.attribute5%TYPE,
        p_attribute6 IN ar_batches.attribute6%TYPE,
        p_attribute7 IN ar_batches.attribute7%TYPE,
        p_attribute8 IN ar_batches.attribute8%TYPE,
        p_attribute9 IN ar_batches.attribute9%TYPE,
        p_attribute10 IN ar_batches.attribute10%TYPE,
        p_attribute11 IN ar_batches.attribute11%TYPE,
        p_attribute12 IN ar_batches.attribute12%TYPE,
        p_attribute13 IN ar_batches.attribute13%TYPE,
        p_attribute14 IN ar_batches.attribute14%TYPE,
        p_attribute15 IN ar_batches.attribute15%TYPE,
        p_module_name IN VARCHAR2,
        p_module_version IN VARCHAR2 );

PROCEDURE update_auto_batch(
        p_row_id IN VARCHAR2,
        p_batch_id IN ar_batches.batch_id%TYPE,
        p_batch_source_id IN ar_batches.batch_source_id%TYPE,
        p_batch_date IN ar_batches.batch_date%TYPE,
        p_gl_date IN ar_batches.gl_date%TYPE,
        p_deposit_date IN ar_batches.batch_date%TYPE,
        p_currency_code IN ar_batches.currency_code%TYPE,
        p_comments IN ar_batches.comments%TYPE,
        p_control_amount IN ar_batches.control_amount%TYPE,
        p_control_count IN ar_batches.control_count%TYPE,
        p_exchange_date IN ar_batches.exchange_date%TYPE,
        p_exchange_rate IN ar_batches.exchange_rate%TYPE,
        p_exchange_rate_type IN ar_batches.exchange_rate_type%TYPE,
        p_receipt_class_id IN ar_batches.receipt_class_id%TYPE,
        p_receipt_method_id IN ar_batches.receipt_method_id%TYPE,
        p_remittance_bank_account_id
                   IN ar_batches.remit_bank_acct_use_id%TYPE,
        p_remittance_bank_branch_id
                   IN ar_batches.remittance_bank_branch_id%TYPE,
        p_media_reference IN ar_batches.media_reference%TYPE,
        p_bank_deposit_number IN ar_batches.bank_deposit_number%TYPE,
        p_request_id IN ar_batches.request_id%TYPE,
        p_operation_request_id IN ar_batches.operation_request_id%TYPE,
        p_attribute_category IN ar_batches.attribute_category%TYPE,
        p_attribute1 IN ar_batches.attribute1%TYPE,
        p_attribute2 IN ar_batches.attribute2%TYPE,
        p_attribute3 IN ar_batches.attribute3%TYPE,
        p_attribute4 IN ar_batches.attribute4%TYPE,
        p_attribute5 IN ar_batches.attribute5%TYPE,
        p_attribute6 IN ar_batches.attribute6%TYPE,
        p_attribute7 IN ar_batches.attribute7%TYPE,
        p_attribute8 IN ar_batches.attribute8%TYPE,
        p_attribute9 IN ar_batches.attribute9%TYPE,
        p_attribute10 IN ar_batches.attribute10%TYPE,
        p_attribute11 IN ar_batches.attribute11%TYPE,
        p_attribute12 IN ar_batches.attribute12%TYPE,
        p_attribute13 IN ar_batches.attribute13%TYPE,
        p_attribute14 IN ar_batches.attribute14%TYPE,
        p_attribute15 IN ar_batches.attribute15%TYPE,
        p_module_name IN VARCHAR2,
        p_module_version IN VARCHAR2 );
--
--Bug7194951
PROCEDURE update_batch_status( p_batch_id IN ar_batches.batch_id%TYPE,
			       p_called_from IN VARCHAR2 DEFAULT NULL );

--
PROCEDURE check_unique_batch_name(
		p_row_id IN VARCHAR2,
		p_batch_source_id IN ar_batch_sources.batch_source_id%TYPE,
		p_batch_name IN ar_batches.name%TYPE,
                p_module_name IN VARCHAR2,
                p_module_version IN VARCHAR2 );
--
PROCEDURE check_unique_batch_name(
		p_row_id IN VARCHAR2,
		p_batch_source_name IN ar_batch_sources.name%TYPE,
		p_batch_name IN ar_batches.name%TYPE,
                p_module_name IN VARCHAR2,
                p_module_version IN VARCHAR2 );
--
PROCEDURE check_unique_media_ref(
		p_row_id IN VARCHAR2,
		p_media_ref IN ar_batches.media_reference%TYPE,
                p_module_name IN VARCHAR2,
                p_module_version IN VARCHAR2 );
--
PROCEDURE post_batch_conc_req( p_batch_id IN ar_batches.batch_id%TYPE,
                               p_set_of_books_id IN
                                        ar_batches.set_of_books_id%TYPE,
                               p_transmission_id IN
                                        ar_batches.transmission_id%TYPE,
                               p_batch_applied_status  OUT NOCOPY
                                        ar_batches.batch_applied_status%TYPE,
                               p_request_id  OUT NOCOPY ar_batches.request_id%TYPE,
			       p_module_name IN VARCHAR2,
                               p_module_version IN VARCHAR2 );
--
PROCEDURE get_quick_amount_totals( p_batch_id IN ar_batches.batch_id%TYPE,
                             p_actual_amount_total OUT NOCOPY NUMBER,
                             p_actual_count_total OUT NOCOPY NUMBER,
                             p_unidentified_amount_total OUT NOCOPY NUMBER,
                             p_unidentified_count_total OUT NOCOPY NUMBER,
                             p_on_account_amount_total OUT NOCOPY NUMBER,
                             p_on_account_count_total OUT NOCOPY NUMBER,
                             p_unapplied_amount_total OUT NOCOPY NUMBER,
                             p_unapplied_count_total OUT NOCOPY NUMBER,
                             p_applied_amount_total OUT NOCOPY NUMBER,
                             p_applied_count_total OUT NOCOPY NUMBER,
                             p_claim_amount_total OUT NOCOPY NUMBER,
                             p_claim_count_total OUT NOCOPY NUMBER,
                             p_module_name IN VARCHAR2,
                             p_module_version IN VARCHAR2 );
--
PROCEDURE get_reg_amount_totals( p_batch_id IN ar_batches.batch_id%TYPE,
                             p_actual_amount_total OUT NOCOPY NUMBER,
                             p_actual_count_total OUT NOCOPY NUMBER,
                             p_unidentified_amount_total OUT NOCOPY NUMBER,
                             p_unidentified_count_total OUT NOCOPY NUMBER,
                             p_on_account_amount_total OUT NOCOPY NUMBER,
                             p_on_account_count_total OUT NOCOPY NUMBER,
                             p_returned_amount_total OUT NOCOPY NUMBER,
                             p_returned_count_total OUT NOCOPY NUMBER,
                             p_reversed_amount_total OUT NOCOPY NUMBER,
                             p_reversed_count_total OUT NOCOPY NUMBER,
                             p_unapplied_amount_total OUT NOCOPY NUMBER,
                             p_unapplied_count_total OUT NOCOPY NUMBER,
                             p_applied_amount_total OUT NOCOPY NUMBER,
                             p_applied_count_total OUT NOCOPY NUMBER,
                             p_claim_amount_total OUT NOCOPY NUMBER,
                             p_claim_count_total OUT NOCOPY NUMBER,
                             p_prepayment_amount_total OUT NOCOPY NUMBER,
                             p_prepayment_count_total OUT NOCOPY NUMBER,
                             p_misc_amount_total OUT NOCOPY NUMBER,
                             p_misc_count_total OUT NOCOPY NUMBER,
                             p_module_name IN VARCHAR2,
                             p_module_version IN VARCHAR2 );

END ARP_RW_BATCHES_CHECK_PKG;

/
