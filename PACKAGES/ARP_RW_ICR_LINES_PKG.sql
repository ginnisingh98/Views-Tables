--------------------------------------------------------
--  DDL for Package ARP_RW_ICR_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_RW_ICR_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: ARERICLS.pls 115.5 2003/02/28 22:05:56 djancis ship $ */
--
PROCEDURE insert_row(
            p_row_id   IN OUT NOCOPY VARCHAR2,
            p_icr_line_id   IN OUT NOCOPY
                      ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE,
            p_cr_id    IN ar_interim_cash_receipt_lines.cash_receipt_id%TYPE,
            p_payment_amount IN
                       ar_interim_cash_receipt_lines.payment_amount%TYPE,
            p_amount_applied_from IN
                       ar_interim_cash_receipt_lines.amount_applied_from%TYPE,
            p_trans_to_receipt_rate IN
                       ar_interim_cash_receipt_lines.trans_to_receipt_rate%TYPE,
            p_payment_schedule_id IN
                        ar_payment_schedules.payment_schedule_id%TYPE,
            p_customer_trx_id IN
                   ar_interim_cash_receipt_lines.customer_trx_id%TYPE,
            p_batch_id IN ar_interim_cash_receipt_lines.batch_id%TYPE,
            p_sold_to_customer IN
                   ar_interim_cash_receipt_lines.sold_to_customer%TYPE,
            p_discount_taken IN
                   ar_interim_cash_receipt_lines.discount_taken%TYPE,
            p_due_date IN ar_interim_cash_receipt_lines.due_date%TYPE,
            p_ussgl_transaction_code IN
                   ar_interim_cash_receipt_lines.ussgl_transaction_code%TYPE,
            p_attribute_category IN
                      ar_interim_cash_receipt_lines.attribute_category%TYPE,
            p_attribute1 IN ar_interim_cash_receipt_lines.attribute1%TYPE,
            p_attribute2 IN ar_interim_cash_receipt_lines.attribute2%TYPE,
            p_attribute3 IN ar_interim_cash_receipt_lines.attribute3%TYPE,
            p_attribute4 IN ar_interim_cash_receipt_lines.attribute4%TYPE,
            p_attribute5 IN ar_interim_cash_receipt_lines.attribute5%TYPE,
            p_attribute6 IN ar_interim_cash_receipt_lines.attribute6%TYPE,
            p_attribute7 IN ar_interim_cash_receipt_lines.attribute7%TYPE,
            p_attribute8 IN ar_interim_cash_receipt_lines.attribute8%TYPE,
            p_attribute9 IN ar_interim_cash_receipt_lines.attribute9%TYPE,
            p_attribute10 IN ar_interim_cash_receipt_lines.attribute10%TYPE,
            p_attribute11 IN ar_interim_cash_receipt_lines.attribute11%TYPE,
            p_attribute12 IN ar_interim_cash_receipt_lines.attribute12%TYPE,
            p_attribute13 IN ar_interim_cash_receipt_lines.attribute13%TYPE,
            p_attribute14 IN ar_interim_cash_receipt_lines.attribute14%TYPE,
            p_attribute15 IN ar_interim_cash_receipt_lines.attribute15%TYPE,
	    p_global_attribute_category IN
  	        ar_interim_cash_receipt_lines.global_attribute_category%TYPE,
	    p_global_attribute1 IN
		ar_interim_cash_receipt_lines.global_attribute1%TYPE,
            p_global_attribute2 IN
                ar_interim_cash_receipt_lines.global_attribute2%TYPE,
            p_global_attribute3 IN
                ar_interim_cash_receipt_lines.global_attribute3%TYPE,
            p_global_attribute4 IN
                ar_interim_cash_receipt_lines.global_attribute4%TYPE,
            p_global_attribute5 IN
                ar_interim_cash_receipt_lines.global_attribute5%TYPE,
            p_global_attribute6 IN
                ar_interim_cash_receipt_lines.global_attribute6%TYPE,
            p_global_attribute7 IN
                ar_interim_cash_receipt_lines.global_attribute7%TYPE,
            p_global_attribute8 IN
                ar_interim_cash_receipt_lines.global_attribute8%TYPE,
            p_global_attribute9 IN
                ar_interim_cash_receipt_lines.global_attribute9%TYPE,
            p_global_attribute10 IN
                ar_interim_cash_receipt_lines.global_attribute10%TYPE,
            p_global_attribute11 IN
                ar_interim_cash_receipt_lines.global_attribute11%TYPE,
            p_global_attribute12 IN
                ar_interim_cash_receipt_lines.global_attribute12%TYPE,
            p_global_attribute13 IN
                ar_interim_cash_receipt_lines.global_attribute13%TYPE,
            p_global_attribute14 IN
                ar_interim_cash_receipt_lines.global_attribute14%TYPE,
            p_global_attribute15 IN
                ar_interim_cash_receipt_lines.global_attribute15%TYPE,
            p_global_attribute16 IN
                ar_interim_cash_receipt_lines.global_attribute16%TYPE,
            p_global_attribute17 IN
                ar_interim_cash_receipt_lines.global_attribute17%TYPE,
            p_global_attribute18 IN
                ar_interim_cash_receipt_lines.global_attribute18%TYPE,
            p_global_attribute19 IN
                ar_interim_cash_receipt_lines.global_attribute19%TYPE,
            p_global_attribute20 IN
                ar_interim_cash_receipt_lines.global_attribute20%TYPE,
            p_application_ref_type IN
                ar_interim_cash_receipt_lines.application_ref_type%TYPE,
            p_customer_reference IN
                ar_interim_cash_receipt_lines.customer_reference%TYPE,
            p_customer_reason IN
                ar_interim_cash_receipt_lines.customer_reason%TYPE,
            p_applied_rec_app_id IN
                ar_interim_cash_receipt_lines.applied_rec_app_id%TYPE,
            p_module_name  IN VARCHAR2,
            p_module_version IN VARCHAR2 );
--
PROCEDURE update_row(
            p_row_id   IN VARCHAR2,
            p_icr_line_id   IN
                    ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE,
            p_cr_id   IN
                    ar_interim_cash_receipt_lines.cash_receipt_id%TYPE,
            p_payment_amount IN
                       ar_interim_cash_receipt_lines.payment_amount%TYPE,
            p_amount_applied_from IN
                       ar_interim_cash_receipt_lines.amount_applied_from%TYPE,
            p_trans_to_receipt_rate IN
                       ar_interim_cash_receipt_lines.trans_to_receipt_rate%TYPE,
            p_payment_schedule_id IN
                        ar_payment_schedules.payment_schedule_id%TYPE,
            p_customer_trx_id IN
                   ar_interim_cash_receipt_lines.customer_trx_id%TYPE,
            p_batch_id IN ar_interim_cash_receipt_lines.batch_id%TYPE,
            p_sold_to_customer IN
                   ar_interim_cash_receipt_lines.sold_to_customer%TYPE,
            p_discount_taken IN
                   ar_interim_cash_receipt_lines.discount_taken%TYPE,
            p_due_date IN ar_interim_cash_receipt_lines.due_date%TYPE,
            p_ussgl_transaction_code IN
                   ar_interim_cash_receipt_lines.ussgl_transaction_code%TYPE,
            p_attribute_category IN
                        ar_interim_cash_receipt_lines.attribute_category%TYPE,
            p_attribute1 IN ar_interim_cash_receipt_lines.attribute1%TYPE,
            p_attribute2 IN ar_interim_cash_receipt_lines.attribute2%TYPE,
            p_attribute3 IN ar_interim_cash_receipt_lines.attribute3%TYPE,
            p_attribute4 IN ar_interim_cash_receipt_lines.attribute4%TYPE,
            p_attribute5 IN ar_interim_cash_receipt_lines.attribute5%TYPE,
            p_attribute6 IN ar_interim_cash_receipt_lines.attribute6%TYPE,
            p_attribute7 IN ar_interim_cash_receipt_lines.attribute7%TYPE,
            p_attribute8 IN ar_interim_cash_receipt_lines.attribute8%TYPE,
            p_attribute9 IN ar_interim_cash_receipt_lines.attribute9%TYPE,
            p_attribute10 IN ar_interim_cash_receipt_lines.attribute10%TYPE,
            p_attribute11 IN ar_interim_cash_receipt_lines.attribute11%TYPE,
            p_attribute12 IN ar_interim_cash_receipt_lines.attribute12%TYPE,
            p_attribute13 IN ar_interim_cash_receipt_lines.attribute13%TYPE,
            p_attribute14 IN ar_interim_cash_receipt_lines.attribute14%TYPE,
            p_attribute15 IN ar_interim_cash_receipt_lines.attribute15%TYPE,
            p_global_attribute_category IN
                ar_interim_cash_receipt_lines.global_attribute_category%TYPE,
            p_global_attribute1 IN
                ar_interim_cash_receipt_lines.global_attribute1%TYPE,
            p_global_attribute2 IN
                ar_interim_cash_receipt_lines.global_attribute2%TYPE,
            p_global_attribute3 IN
                ar_interim_cash_receipt_lines.global_attribute3%TYPE,
            p_global_attribute4 IN
                ar_interim_cash_receipt_lines.global_attribute4%TYPE,
            p_global_attribute5 IN
                ar_interim_cash_receipt_lines.global_attribute5%TYPE,
            p_global_attribute6 IN
                ar_interim_cash_receipt_lines.global_attribute6%TYPE,
            p_global_attribute7 IN
                ar_interim_cash_receipt_lines.global_attribute7%TYPE,
            p_global_attribute8 IN
                ar_interim_cash_receipt_lines.global_attribute8%TYPE,
            p_global_attribute9 IN
                ar_interim_cash_receipt_lines.global_attribute9%TYPE,
            p_global_attribute10 IN
                ar_interim_cash_receipt_lines.global_attribute10%TYPE,
            p_global_attribute11 IN
                ar_interim_cash_receipt_lines.global_attribute11%TYPE,
            p_global_attribute12 IN
                ar_interim_cash_receipt_lines.global_attribute12%TYPE,
            p_global_attribute13 IN
                ar_interim_cash_receipt_lines.global_attribute13%TYPE,
            p_global_attribute14 IN
                ar_interim_cash_receipt_lines.global_attribute14%TYPE,
            p_global_attribute15 IN
                ar_interim_cash_receipt_lines.global_attribute15%TYPE,
            p_global_attribute16 IN
                ar_interim_cash_receipt_lines.global_attribute16%TYPE,
            p_global_attribute17 IN
                ar_interim_cash_receipt_lines.global_attribute17%TYPE,
            p_global_attribute18 IN
                ar_interim_cash_receipt_lines.global_attribute18%TYPE,
            p_global_attribute19 IN
                ar_interim_cash_receipt_lines.global_attribute19%TYPE,
            p_global_attribute20 IN
                ar_interim_cash_receipt_lines.global_attribute20%TYPE,
            p_application_ref_type IN
                ar_interim_cash_receipt_lines.application_ref_type%TYPE,
            p_customer_reference IN
                ar_interim_cash_receipt_lines.customer_reference%TYPE,
            p_customer_reason IN
                ar_interim_cash_receipt_lines.customer_reason%TYPE,
            p_applied_rec_app_id IN
                ar_interim_cash_receipt_lines.applied_rec_app_id%TYPE,
            p_module_name  IN VARCHAR2,
            p_module_version IN VARCHAR2 );
--
PROCEDURE delete_row(
            p_row_id   IN VARCHAR2,
            p_icr_id   IN ar_interim_cash_receipts.cash_receipt_id%TYPE,
            p_icr_line_id   IN
                    ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE,
            p_module_name  IN VARCHAR2,
            p_module_version IN VARCHAR2 );
--
PROCEDURE lock_row(
            p_row_id   VARCHAR2,
            p_icr_id
              ar_interim_cash_receipt_lines.cash_receipt_id%TYPE,
            p_icr_line_id
              ar_interim_cash_receipt_lines.cash_receipt_line_id%TYPE,
            p_payment_amount
              ar_interim_cash_receipt_lines.payment_amount%TYPE,
            p_payment_schedule_id
              ar_payment_schedules.payment_schedule_id%TYPE,
            p_customer_trx_id
              ar_interim_cash_receipt_lines.customer_trx_id%TYPE,
            p_batch_id ar_interim_cash_receipt_lines.batch_id%TYPE,
            p_sold_to_customer
              ar_interim_cash_receipt_lines.sold_to_customer%TYPE,
            p_discount_taken
              ar_interim_cash_receipt_lines.discount_taken%TYPE,
            p_due_date ar_interim_cash_receipt_lines.due_date%TYPE,
            p_ussgl_transaction_code
              ar_interim_cash_receipt_lines.ussgl_transaction_code%TYPE,
            p_attribute_category
              ar_interim_cash_receipt_lines.attribute_category%TYPE,
            p_attribute1 ar_interim_cash_receipt_lines.attribute1%TYPE,
            p_attribute2 ar_interim_cash_receipt_lines.attribute2%TYPE,
            p_attribute3 ar_interim_cash_receipt_lines.attribute3%TYPE,
            p_attribute4 ar_interim_cash_receipt_lines.attribute4%TYPE,
            p_attribute5 ar_interim_cash_receipt_lines.attribute5%TYPE,
            p_attribute6 ar_interim_cash_receipt_lines.attribute6%TYPE,
            p_attribute7 ar_interim_cash_receipt_lines.attribute7%TYPE,
            p_attribute8 ar_interim_cash_receipt_lines.attribute8%TYPE,
            p_attribute9 ar_interim_cash_receipt_lines.attribute9%TYPE,
            p_attribute10 ar_interim_cash_receipt_lines.attribute10%TYPE,
            p_attribute11 ar_interim_cash_receipt_lines.attribute11%TYPE,
            p_attribute12 ar_interim_cash_receipt_lines.attribute12%TYPE,
            p_attribute13 ar_interim_cash_receipt_lines.attribute13%TYPE,
            p_attribute14 ar_interim_cash_receipt_lines.attribute14%TYPE,
            p_attribute15 ar_interim_cash_receipt_lines.attribute15%TYPE,
            p_global_attribute_category IN
                ar_interim_cash_receipt_lines.global_attribute_category%TYPE,
            p_global_attribute1 IN
                ar_interim_cash_receipt_lines.global_attribute1%TYPE,
            p_global_attribute2 IN
                ar_interim_cash_receipt_lines.global_attribute2%TYPE,
            p_global_attribute3 IN
                ar_interim_cash_receipt_lines.global_attribute3%TYPE,
            p_global_attribute4 IN
                ar_interim_cash_receipt_lines.global_attribute4%TYPE,
            p_global_attribute5 IN
                ar_interim_cash_receipt_lines.global_attribute5%TYPE,
            p_global_attribute6 IN
                ar_interim_cash_receipt_lines.global_attribute6%TYPE,
            p_global_attribute7 IN
                ar_interim_cash_receipt_lines.global_attribute7%TYPE,
            p_global_attribute8 IN
                ar_interim_cash_receipt_lines.global_attribute8%TYPE,
            p_global_attribute9 IN
                ar_interim_cash_receipt_lines.global_attribute9%TYPE,
            p_global_attribute10 IN
                ar_interim_cash_receipt_lines.global_attribute10%TYPE,
            p_global_attribute11 IN
                ar_interim_cash_receipt_lines.global_attribute11%TYPE,
            p_global_attribute12 IN
                ar_interim_cash_receipt_lines.global_attribute12%TYPE,
            p_global_attribute13 IN
                ar_interim_cash_receipt_lines.global_attribute13%TYPE,
            p_global_attribute14 IN
                ar_interim_cash_receipt_lines.global_attribute14%TYPE,
            p_global_attribute15 IN
                ar_interim_cash_receipt_lines.global_attribute15%TYPE,
            p_global_attribute16 IN
                ar_interim_cash_receipt_lines.global_attribute16%TYPE,
            p_global_attribute17 IN
                ar_interim_cash_receipt_lines.global_attribute17%TYPE,
            p_global_attribute18 IN
                ar_interim_cash_receipt_lines.global_attribute18%TYPE,
            p_global_attribute19 IN
                ar_interim_cash_receipt_lines.global_attribute19%TYPE,
            p_global_attribute20 IN
                ar_interim_cash_receipt_lines.global_attribute20%TYPE
);
--
END ARP_RW_ICR_LINES_PKG;

 

/
