--------------------------------------------------------
--  DDL for Package ARP_RW_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_RW_BATCHES_PKG" AUTHID CURRENT_USER AS
/* $Header: ARERBATS.pls 120.3.12010000.2 2009/08/25 05:53:17 nproddut ship $ */
--
PROCEDURE insert_manual_batch(
        p_row_id IN OUT NOCOPY VARCHAR2,
        p_batch_type IN VARCHAR2,
        p_batch_id IN OUT NOCOPY ar_batches.batch_id%TYPE,
        p_batch_source_id IN ar_batches.batch_source_id%TYPE,
        p_batch_date IN ar_batches.batch_date%TYPE,
        p_currency_code IN ar_batches.currency_code%TYPE,
        p_name IN OUT NOCOPY ar_batches.name%TYPE,
        p_comments IN ar_batches.comments%TYPE,
        p_control_amount IN ar_batches.control_amount%TYPE,
        p_control_count IN ar_batches.control_count%TYPE,
        p_deposit_date IN ar_batches.deposit_date%TYPE,
        p_exchange_date IN ar_batches.exchange_date%TYPE,
        p_exchange_rate IN ar_batches.exchange_rate%TYPE,
        p_exchange_rate_type IN ar_batches.exchange_rate_type%TYPE,
        p_gl_date IN ar_batches.gl_date%TYPE,
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
        p_batch_applied_status OUT NOCOPY ar_batches.batch_applied_status%TYPE,
        p_module_name IN VARCHAR2,
        p_module_version IN VARCHAR2 );
--
PROCEDURE insert_auto_batch(
        p_row_id IN OUT NOCOPY VARCHAR2,
        p_batch_id IN OUT NOCOPY ar_batches.batch_id%TYPE,
        p_batch_date IN ar_batches.batch_date%TYPE,
        p_currency_code IN ar_batches.currency_code%TYPE,
        p_name IN OUT NOCOPY ar_batches.name%TYPE,
        p_comments IN ar_batches.comments%TYPE,
        p_exchange_date IN ar_batches.exchange_date%TYPE,
        p_exchange_rate IN ar_batches.exchange_rate%TYPE,
        p_exchange_rate_type IN ar_batches.exchange_rate_type%TYPE,
        p_gl_date IN ar_batches.gl_date%TYPE,
        p_media_reference IN ar_batches.media_reference%TYPE,
        p_receipt_class_id IN ar_batches.receipt_class_id%TYPE,
        p_receipt_method_id IN ar_batches.receipt_method_id%TYPE,
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
        p_call_conc_req IN VARCHAR2,
        p_batch_applied_status OUT NOCOPY ar_batches.batch_applied_status%TYPE,
        p_request_id OUT NOCOPY ar_batches.request_id%TYPE,
        p_module_name IN VARCHAR2,
        p_module_version IN VARCHAR2,
	p_bank_account_low IN VARCHAR2,
	p_bank_account_high IN VARCHAR2 );
--
PROCEDURE insert_remit_batch(
        p_row_id IN OUT NOCOPY VARCHAR2,
        p_batch_id IN OUT NOCOPY ar_batches.batch_id%TYPE,
        p_batch_date IN ar_batches.batch_date%TYPE,
        p_currency_code IN ar_batches.currency_code%TYPE,
        p_name IN OUT NOCOPY ar_batches.name%TYPE,
        p_comments IN ar_batches.comments%TYPE,
        p_exchange_date IN ar_batches.exchange_date%TYPE,
        p_exchange_rate IN ar_batches.exchange_rate%TYPE,
        p_exchange_rate_type IN ar_batches.exchange_rate_type%TYPE,
        p_gl_date IN ar_batches.gl_date%TYPE,
        p_media_reference IN ar_batches.media_reference%TYPE,
        p_remit_method_code IN ar_batches.remit_method_code%TYPE,
	p_receipt_class_id IN ar_batches.receipt_class_id%TYPE,
        p_receipt_method_id IN ar_batches.receipt_method_id%TYPE,
        p_remittance_bank_account_id
                   IN ar_batches.remit_bank_acct_use_id%TYPE,
        p_remittance_bank_branch_id
                   IN ar_batches.remittance_bank_branch_id%TYPE,
        p_bank_deposit_number IN ar_batches.bank_deposit_number%TYPE,
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
	p_auto_creation IN VARCHAR2,
        p_batch_applied_status OUT NOCOPY ar_batches.batch_applied_status%TYPE,
        p_module_name IN VARCHAR2,
        p_module_version IN VARCHAR2 );
--
PROCEDURE delete_batch(
        p_batch_id IN ar_batches.batch_id%TYPE );
--

/*Bug3030995*/



PROCEDURE default_batch_source_pay_mthds(p_batch_source_name IN OUT NOCOPY ar_batch_sources.name%TYPE,
                        p_batch_date         IN ar_batch_sources.start_date_active%TYPE,
                        p_batch_source_id IN OUT NOCOPY ar_batch_sources.batch_source_id%TYPE,
                        p_batch_number OUT NOCOPY ar_batch_sources.auto_batch_numbering%TYPE,
                        p_rec_class_id OUT NOCOPY ar_receipt_classes.receipt_class_id%TYPE,
                        p_rec_class_name OUT NOCOPY ar_receipt_classes.name%TYPE,
                        p_pay_method_id OUT NOCOPY ar_receipt_methods.receipt_method_id%TYPE,
                        p_pay_method_name OUT NOCOPY ar_receipt_methods.name%TYPE,
                        p_bank_name OUT NOCOPY ce_bank_branches_v.bank_name%TYPE,
                        p_bank_account_num OUT NOCOPY ce_bank_accounts.bank_account_num%TYPE,
                        p_bank_account_id OUT NOCOPY ce_bank_accounts.bank_account_id%TYPE,
                        p_currency_code IN OUT NOCOPY ce_bank_accounts.currency_code%TYPE,
                        p_bank_branch_name OUT NOCOPY ce_bank_branches_v.bank_branch_name%TYPE,
                        p_bank_branch_id   OUT NOCOPY ce_bank_accounts.bank_branch_id%TYPE,
                        p_override_remit_flag OUT NOCOPY ar_receipt_method_accounts.override_remit_account_flag%TYPE,
                        p_remit_flag OUT NOCOPY ar_receipt_classes.remit_flag%TYPE,
                        p_creation_status  OUT NOCOPY ar_receipt_classes.creation_status%TYPE,
                        p_meaning OUT NOCOPY ar_lookups.meaning%TYPE);



FUNCTION release_lock(p_batch_id  NUMBER,
                      x_message   OUT NOCOPY VARCHAR2 ) RETURN BOOLEAN ;


FUNCTION request_lock(p_batch_id  NUMBER,
                      x_message   OUT NOCOPY VARCHAR2 ) RETURN BOOLEAN;


END ARP_RW_BATCHES_PKG;

/
