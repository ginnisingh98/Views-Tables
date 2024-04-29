--------------------------------------------------------
--  DDL for Package ARP_PROCESS_APPLICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_APPLICATION" AUTHID CURRENT_USER AS
/* $Header: ARCEAPPS.pls 120.17.12010000.9 2010/10/27 02:41:05 yaozhan ship $ */

FUNCTION revision RETURN VARCHAR2;

PROCEDURE reverse(
        p_ra_id				IN NUMBER
        , p_reversal_gl_date		IN DATE
        , p_reversal_date		IN DATE
        , p_module_name			IN VARCHAR2
        , p_module_version		IN VARCHAR2
        , p_bal_due_remaining           OUT NOCOPY NUMBER
 	, p_called_from                 IN VARCHAR2 DEFAULT NULL);  /* jrautiai BR implementation */

PROCEDURE reverse_cm_app(
          pn_ra_id               IN NUMBER
        , pn_applied_ps_id       IN NUMBER
        , pd_reversal_gl_date    IN DATE
        , pd_reversal_date       IN DATE
        , pc_module_name         IN VARCHAR2
        , pc_module_version      IN VARCHAR2
        , p_called_from          IN VARCHAR2 DEFAULT NULL );

PROCEDURE update_selected_transaction(
        pn_ra_id                      IN NUMBER,
        pn_amount_applied             IN NUMBER,
        pc_invoice_currency_code      IN VARCHAR2,
        pn_invoice_exchange_rate      IN NUMBER,
        pc_receipt_currency_code      IN VARCHAR2,
        pn_receipt_exchange_rate      IN NUMBER,
        pc_module_name                IN VARCHAR2,
        pc_module_version             IN VARCHAR2,
	p_attribute_category    IN VARCHAR2,
        p_attribute1            IN VARCHAR2,
        p_attribute2            IN VARCHAR2,
        p_attribute3            IN VARCHAR2,
        p_attribute4            IN VARCHAR2,
        p_attribute5            IN VARCHAR2,
        p_attribute6            IN VARCHAR2,
        p_attribute7            IN VARCHAR2,
        p_attribute8            IN VARCHAR2,
        p_attribute9            IN VARCHAR2,
        p_attribute10           IN VARCHAR2,
        p_attribute11           IN VARCHAR2,
        p_attribute12           IN VARCHAR2,
        p_attribute13           IN VARCHAR2,
        p_attribute14           IN VARCHAR2,
        p_attribute15           IN VARCHAR2,
        p_global_attribute_category IN VARCHAR2,
        p_global_attribute1 IN VARCHAR2,
        p_global_attribute2 IN VARCHAR2,
        p_global_attribute3 IN VARCHAR2,
        p_global_attribute4 IN VARCHAR2,
        p_global_attribute5 IN VARCHAR2,
        p_global_attribute6 IN VARCHAR2,
        p_global_attribute7 IN VARCHAR2,
        p_global_attribute8 IN VARCHAR2,
        p_global_attribute9 IN VARCHAR2,
        p_global_attribute10 IN VARCHAR2,
        p_global_attribute11 IN VARCHAR2,
        p_global_attribute12 IN VARCHAR2,
        p_global_attribute13 IN VARCHAR2,
        p_global_attribute14 IN VARCHAR2,
        p_global_attribute15 IN VARCHAR2,
        p_global_attribute16 IN VARCHAR2,
        p_global_attribute17 IN VARCHAR2,
        p_global_attribute18 IN VARCHAR2,
        p_global_attribute19 IN VARCHAR2,
        p_global_attribute20 IN VARCHAR2 );

PROCEDURE receipt_application(
	p_receipt_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
	p_invoice_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_amount_applied IN ar_receivable_applications.amount_applied%TYPE,
        p_amount_applied_from IN ar_receivable_applications.amount_applied_from%TYPE,
        p_trans_to_receipt_rate IN ar_receivable_applications.trans_to_receipt_rate%TYPE,
        p_invoice_currency_code IN ar_payment_schedules.invoice_currency_code%TYPE,
        p_receipt_currency_code IN ar_cash_receipts.currency_code%TYPE,
        p_earned_discount_taken IN ar_receivable_applications.earned_discount_taken%TYPE,
        p_unearned_discount_taken IN ar_receivable_applications.unearned_discount_taken%TYPE,
        p_apply_date IN ar_receivable_applications.apply_date%TYPE,
	p_gl_date IN ar_receivable_applications.gl_date%TYPE,
	p_ussgl_transaction_code IN ar_receivable_applications.ussgl_transaction_code%TYPE,
	p_customer_trx_line_id	IN ar_receivable_applications.applied_customer_trx_line_id%TYPE,
        p_application_ref_type IN
                ar_receivable_applications.application_ref_type%TYPE,
        p_application_ref_id IN
                ar_receivable_applications.application_ref_id%TYPE,
        p_application_ref_num IN
                ar_receivable_applications.application_ref_num%TYPE,
        p_secondary_application_ref_id IN
                ar_receivable_applications.secondary_application_ref_id%TYPE DEFAULT NULL,
 	p_attribute_category IN ar_receivable_applications.attribute_category%TYPE,
	p_attribute1 IN ar_receivable_applications.attribute1%TYPE,
	p_attribute2 IN ar_receivable_applications.attribute2%TYPE,
	p_attribute3 IN ar_receivable_applications.attribute3%TYPE,
	p_attribute4 IN ar_receivable_applications.attribute4%TYPE,
	p_attribute5 IN ar_receivable_applications.attribute5%TYPE,
	p_attribute6 IN ar_receivable_applications.attribute6%TYPE,
	p_attribute7 IN ar_receivable_applications.attribute7%TYPE,
	p_attribute8 IN ar_receivable_applications.attribute8%TYPE,
	p_attribute9 IN ar_receivable_applications.attribute9%TYPE,
	p_attribute10 IN ar_receivable_applications.attribute10%TYPE,
	p_attribute11 IN ar_receivable_applications.attribute11%TYPE,
	p_attribute12 IN ar_receivable_applications.attribute12%TYPE,
	p_attribute13 IN ar_receivable_applications.attribute13%TYPE,
	p_attribute14 IN ar_receivable_applications.attribute14%TYPE,
	p_attribute15 IN ar_receivable_applications.attribute15%TYPE,
        p_global_attribute_category IN ar_receivable_applications.global_attribute_category%TYPE,
        p_global_attribute1 IN ar_receivable_applications.global_attribute1%TYPE,
        p_global_attribute2 IN ar_receivable_applications.global_attribute2%TYPE,
        p_global_attribute3 IN ar_receivable_applications.global_attribute3%TYPE,
        p_global_attribute4 IN ar_receivable_applications.global_attribute4%TYPE,
        p_global_attribute5 IN ar_receivable_applications.global_attribute5%TYPE,
        p_global_attribute6 IN ar_receivable_applications.global_attribute6%TYPE,
        p_global_attribute7 IN ar_receivable_applications.global_attribute7%TYPE,
        p_global_attribute8 IN ar_receivable_applications.global_attribute8%TYPE,
        p_global_attribute9 IN ar_receivable_applications.global_attribute9%TYPE,
        p_global_attribute10 IN ar_receivable_applications.global_attribute10%TYPE,
        p_global_attribute11 IN ar_receivable_applications.global_attribute11%TYPE,
        p_global_attribute12 IN ar_receivable_applications.global_attribute12%TYPE,
        p_global_attribute13 IN ar_receivable_applications.global_attribute13%TYPE,
        p_global_attribute14 IN ar_receivable_applications.global_attribute14%TYPE,
        p_global_attribute15 IN ar_receivable_applications.global_attribute15%TYPE,
        p_global_attribute16 IN ar_receivable_applications.global_attribute16%TYPE,
        p_global_attribute17 IN ar_receivable_applications.global_attribute17%TYPE,
        p_global_attribute18 IN ar_receivable_applications.global_attribute18%TYPE,
        p_global_attribute19 IN ar_receivable_applications.global_attribute19%TYPE,
        p_global_attribute20 IN ar_receivable_applications.global_attribute20%TYPE,
        p_comments IN ar_receivable_applications.comments%TYPE,
	p_module_name IN VARCHAR2,
	p_module_version IN VARCHAR2,
	-- OUT NOCOPY
        x_application_ref_id OUT NOCOPY
                ar_receivable_applications.application_ref_id%TYPE,
        x_application_ref_num OUT NOCOPY
                ar_receivable_applications.application_ref_num%TYPE,
        x_return_status               OUT NOCOPY VARCHAR2,
        x_msg_count                   OUT NOCOPY NUMBER,
        x_msg_data                    OUT NOCOPY VARCHAR2,
	p_out_rec_application_id OUT NOCOPY ar_receivable_applications.receivable_application_id%TYPE,
        p_acctd_amount_applied_from OUT NOCOPY ar_receivable_applications.acctd_amount_applied_from%TYPE,
        p_acctd_amount_applied_to OUT NOCOPY ar_receivable_applications.acctd_amount_applied_to%TYPE,
        x_claim_reason_name     OUT NOCOPY VARCHAR2,
	p_called_from           IN VARCHAR2 DEFAULT NULL, /* jrautiai BR implementation */
	p_move_deferred_tax     IN VARCHAR2 DEFAULT 'Y',  /* jrautiai BR implementation */
        p_link_to_trx_hist_id   IN ar_receivable_applications.link_to_trx_hist_id%TYPE DEFAULT NULL, /* jrautiai BR implementation */
        p_amount_due_remaining  IN
                ar_payment_schedules.amount_due_remaining%TYPE DEFAULT NULL,
        p_payment_set_id        IN ar_receivable_applications.payment_set_id%TYPE DEFAULT NULL,
        p_application_ref_reason IN ar_receivable_applications.application_ref_reason%TYPE DEFAULT NULL,
        p_customer_reference     IN ar_receivable_applications.customer_reference%TYPE DEFAULT NULL,
        p_customer_reason        IN ar_receivable_applications.customer_reason%TYPE DEFAULT NULL,
--{HYUDETUPT
        from_llca_call     IN VARCHAR2 DEFAULT 'N',
        p_gt_id            IN NUMBER   DEFAULT NULL
--}
	);

PROCEDURE cm_application(
	p_cm_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
	p_invoice_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_amount_applied IN ar_receivable_applications.amount_applied%TYPE,
        p_apply_date IN ar_receivable_applications.apply_date%TYPE,
	p_gl_date IN ar_receivable_applications.gl_date%TYPE,
	p_ussgl_transaction_code IN ar_receivable_applications.ussgl_transaction_code%TYPE,
	p_attribute_category IN ar_receivable_applications.attribute_category%TYPE,
	p_attribute1 IN ar_receivable_applications.attribute1%TYPE,
	p_attribute2 IN ar_receivable_applications.attribute2%TYPE,
	p_attribute3 IN ar_receivable_applications.attribute3%TYPE,
	p_attribute4 IN ar_receivable_applications.attribute4%TYPE,
	p_attribute5 IN ar_receivable_applications.attribute5%TYPE,
	p_attribute6 IN ar_receivable_applications.attribute6%TYPE,
	p_attribute7 IN ar_receivable_applications.attribute7%TYPE,
	p_attribute8 IN ar_receivable_applications.attribute8%TYPE,
	p_attribute9 IN ar_receivable_applications.attribute9%TYPE,
	p_attribute10 IN ar_receivable_applications.attribute10%TYPE,
	p_attribute11 IN ar_receivable_applications.attribute11%TYPE,
	p_attribute12 IN ar_receivable_applications.attribute12%TYPE,
	p_attribute13 IN ar_receivable_applications.attribute13%TYPE,
	p_attribute14 IN ar_receivable_applications.attribute14%TYPE,
	p_attribute15 IN ar_receivable_applications.attribute15%TYPE,
        p_global_attribute_category IN ar_receivable_applications.global_attribute_category%TYPE,
        p_global_attribute1 IN ar_receivable_applications.global_attribute1%TYPE,
        p_global_attribute2 IN ar_receivable_applications.global_attribute2%TYPE,
        p_global_attribute3 IN ar_receivable_applications.global_attribute3%TYPE,
        p_global_attribute4 IN ar_receivable_applications.global_attribute4%TYPE,
        p_global_attribute5 IN ar_receivable_applications.global_attribute5%TYPE,
        p_global_attribute6 IN ar_receivable_applications.global_attribute6%TYPE,
        p_global_attribute7 IN ar_receivable_applications.global_attribute7%TYPE,
        p_global_attribute8 IN ar_receivable_applications.global_attribute8%TYPE,
        p_global_attribute9 IN ar_receivable_applications.global_attribute9%TYPE,
        p_global_attribute10 IN ar_receivable_applications.global_attribute10%TYPE,
        p_global_attribute11 IN ar_receivable_applications.global_attribute11%TYPE,
        p_global_attribute12 IN ar_receivable_applications.global_attribute12%TYPE,
        p_global_attribute13 IN ar_receivable_applications.global_attribute13%TYPE,
        p_global_attribute14 IN ar_receivable_applications.global_attribute14%TYPE,
        p_global_attribute15 IN ar_receivable_applications.global_attribute15%TYPE,
        p_global_attribute16 IN ar_receivable_applications.global_attribute16%TYPE,
        p_global_attribute17 IN ar_receivable_applications.global_attribute17%TYPE,
        p_global_attribute18 IN ar_receivable_applications.global_attribute18%TYPE,
        p_global_attribute19 IN ar_receivable_applications.global_attribute19%TYPE,
        p_global_attribute20 IN ar_receivable_applications.global_attribute20%TYPE,
        p_customer_trx_line_id		IN NUMBER,
        p_comments IN ar_receivable_applications.comments%TYPE DEFAULT NULL, --Bug 2662270
	p_module_name 			IN VARCHAR2,
	p_module_version 		IN VARCHAR2,
        -- OUT NOCOPY
        p_out_rec_application_id      	OUT NOCOPY NUMBER,
        p_acctd_amount_applied_from OUT NOCOPY ar_receivable_applications.acctd_amount_applied_from%TYPE,
        p_acctd_amount_applied_to OUT NOCOPY ar_receivable_applications.acctd_amount_applied_to%TYPE
	);

PROCEDURE cm_activity_application(
	p_cm_ps_id IN ar_payment_schedules.payment_schedule_id%TYPE,
	p_application_ps_id	IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_amount_applied IN ar_receivable_applications.amount_applied%TYPE,
        p_apply_date IN ar_receivable_applications.apply_date%TYPE,
	p_gl_date IN ar_receivable_applications.gl_date%TYPE,
	p_ussgl_transaction_code IN ar_receivable_applications.ussgl_transaction_code%TYPE,
	p_attribute_category IN ar_receivable_applications.attribute_category%TYPE,
	p_attribute1 IN ar_receivable_applications.attribute1%TYPE,
	p_attribute2 IN ar_receivable_applications.attribute2%TYPE,
	p_attribute3 IN ar_receivable_applications.attribute3%TYPE,
	p_attribute4 IN ar_receivable_applications.attribute4%TYPE,
	p_attribute5 IN ar_receivable_applications.attribute5%TYPE,
	p_attribute6 IN ar_receivable_applications.attribute6%TYPE,
	p_attribute7 IN ar_receivable_applications.attribute7%TYPE,
	p_attribute8 IN ar_receivable_applications.attribute8%TYPE,
	p_attribute9 IN ar_receivable_applications.attribute9%TYPE,
	p_attribute10 IN ar_receivable_applications.attribute10%TYPE,
	p_attribute11 IN ar_receivable_applications.attribute11%TYPE,
	p_attribute12 IN ar_receivable_applications.attribute12%TYPE,
	p_attribute13 IN ar_receivable_applications.attribute13%TYPE,
	p_attribute14 IN ar_receivable_applications.attribute14%TYPE,
	p_attribute15 IN ar_receivable_applications.attribute15%TYPE,
        p_global_attribute_category IN ar_receivable_applications.global_attribute_category%TYPE,
        p_global_attribute1 IN ar_receivable_applications.global_attribute1%TYPE,
        p_global_attribute2 IN ar_receivable_applications.global_attribute2%TYPE,
        p_global_attribute3 IN ar_receivable_applications.global_attribute3%TYPE,
        p_global_attribute4 IN ar_receivable_applications.global_attribute4%TYPE,
        p_global_attribute5 IN ar_receivable_applications.global_attribute5%TYPE,
        p_global_attribute6 IN ar_receivable_applications.global_attribute6%TYPE,
        p_global_attribute7 IN ar_receivable_applications.global_attribute7%TYPE,
        p_global_attribute8 IN ar_receivable_applications.global_attribute8%TYPE,
        p_global_attribute9 IN ar_receivable_applications.global_attribute9%TYPE,
        p_global_attribute10 IN ar_receivable_applications.global_attribute10%TYPE,
        p_global_attribute11 IN ar_receivable_applications.global_attribute11%TYPE,
        p_global_attribute12 IN ar_receivable_applications.global_attribute12%TYPE,
        p_global_attribute13 IN ar_receivable_applications.global_attribute13%TYPE,
        p_global_attribute14 IN ar_receivable_applications.global_attribute14%TYPE,
        p_global_attribute15 IN ar_receivable_applications.global_attribute15%TYPE,
        p_global_attribute16 IN ar_receivable_applications.global_attribute16%TYPE,
        p_global_attribute17 IN ar_receivable_applications.global_attribute17%TYPE,
        p_global_attribute18 IN ar_receivable_applications.global_attribute18%TYPE,
        p_global_attribute19 IN ar_receivable_applications.global_attribute19%TYPE,
        p_global_attribute20 IN ar_receivable_applications.global_attribute20%TYPE,
	p_receivables_trx_id IN ar_receivable_applications.receivables_trx_id%TYPE,
	p_receipt_method_id IN ar_receipt_methods.receipt_method_id%TYPE,
        p_comments IN ar_receivable_applications.comments%TYPE DEFAULT NULL,
        p_module_name IN VARCHAR2,
        p_module_version IN VARCHAR2,
        -- OUT NOCOPY
        p_application_ref_id IN OUT NOCOPY ar_receivable_applications.application_ref_id%TYPE,
        p_application_ref_num IN OUT NOCOPY ar_receivable_applications.application_ref_num%TYPE,
        p_out_rec_application_id OUT NOCOPY NUMBER,
        p_acctd_amount_applied_from OUT NOCOPY ar_receivable_applications.acctd_amount_applied_from%TYPE,
        p_acctd_amount_applied_to OUT NOCOPY ar_receivable_applications.acctd_amount_applied_to%TYPE,
        x_return_status               OUT NOCOPY VARCHAR2,
        x_msg_count                   OUT NOCOPY NUMBER,
        x_msg_data                    OUT NOCOPY VARCHAR2);

PROCEDURE on_account_receipts(
        p_receipt_ps_id   IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_amount_applied IN
                ar_receivable_applications.amount_applied%TYPE,
        p_apply_date IN ar_receivable_applications.apply_date%TYPE,
        p_gl_date IN ar_receivable_applications.gl_date%TYPE,
        p_ussgl_transaction_code IN
                ar_receivable_applications.ussgl_transaction_code%TYPE,
        p_attribute_category IN
                ar_receivable_applications.attribute_category%TYPE,
        p_attribute1 IN ar_receivable_applications.attribute1%TYPE,
        p_attribute2 IN ar_receivable_applications.attribute2%TYPE,
        p_attribute3 IN ar_receivable_applications.attribute3%TYPE,
        p_attribute4 IN ar_receivable_applications.attribute4%TYPE,
        p_attribute5 IN ar_receivable_applications.attribute5%TYPE,
        p_attribute6 IN ar_receivable_applications.attribute6%TYPE,
        p_attribute7 IN ar_receivable_applications.attribute7%TYPE,
        p_attribute8 IN ar_receivable_applications.attribute8%TYPE,
        p_attribute9 IN ar_receivable_applications.attribute9%TYPE,
        p_attribute10 IN ar_receivable_applications.attribute10%TYPE,
        p_attribute11 IN ar_receivable_applications.attribute11%TYPE,
        p_attribute12 IN ar_receivable_applications.attribute12%TYPE,
        p_attribute13 IN ar_receivable_applications.attribute13%TYPE,
        p_attribute14 IN ar_receivable_applications.attribute14%TYPE,
        p_attribute15 IN ar_receivable_applications.attribute15%TYPE,
        p_global_attribute_category IN ar_receivable_applications.global_attribute_category%TYPE,
        p_global_attribute1 IN ar_receivable_applications.global_attribute1%TYPE,
        p_global_attribute2 IN ar_receivable_applications.global_attribute2%TYPE,
        p_global_attribute3 IN ar_receivable_applications.global_attribute3%TYPE,
        p_global_attribute4 IN ar_receivable_applications.global_attribute4%TYPE,
        p_global_attribute5 IN ar_receivable_applications.global_attribute5%TYPE,
        p_global_attribute6 IN ar_receivable_applications.global_attribute6%TYPE,
        p_global_attribute7 IN ar_receivable_applications.global_attribute7%TYPE,
        p_global_attribute8 IN ar_receivable_applications.global_attribute8%TYPE,
        p_global_attribute9 IN ar_receivable_applications.global_attribute9%TYPE,
        p_global_attribute10 IN ar_receivable_applications.global_attribute10%TYPE,
        p_global_attribute11 IN ar_receivable_applications.global_attribute11%TYPE,
        p_global_attribute12 IN ar_receivable_applications.global_attribute12%TYPE,
        p_global_attribute13 IN ar_receivable_applications.global_attribute13%TYPE,
        p_global_attribute14 IN ar_receivable_applications.global_attribute14%TYPE,
        p_global_attribute15 IN ar_receivable_applications.global_attribute15%TYPE,
        p_global_attribute16 IN ar_receivable_applications.global_attribute16%TYPE,
        p_global_attribute17 IN ar_receivable_applications.global_attribute17%TYPE,
        p_global_attribute18 IN ar_receivable_applications.global_attribute18%TYPE,
        p_global_attribute19 IN ar_receivable_applications.global_attribute19%TYPE,
        p_global_attribute20 IN ar_receivable_applications.global_attribute20%TYPE,
        p_comments IN ar_receivable_applications.comments%TYPE DEFAULT NULL, --Bug 2047229
        p_module_name IN VARCHAR2,
        p_module_version IN VARCHAR2
	, p_out_rec_application_id      OUT NOCOPY NUMBER
      , p_application_ref_num IN ar_receivable_applications.application_ref_num%TYPE DEFAULT NULL
      , p_secondary_application_ref_id IN ar_receivable_applications.secondary_application_ref_id%TYPE DEFAULT NULL
      , p_customer_reference IN ar_receivable_applications.customer_reference%TYPE DEFAULT NULL
      , p_customer_reason IN ar_receivable_applications.customer_reason%TYPE DEFAULT NULL
      , p_secondary_app_ref_type IN
        ar_receivable_applications.secondary_application_ref_type%TYPE := null
      , p_secondary_app_ref_num IN
        ar_receivable_applications.secondary_application_ref_num%TYPE := null
 );

/* jrautiai BR implementation */
PROCEDURE activity_application(
        p_receipt_ps_id   IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_application_ps_id IN ar_receivable_applications.applied_payment_schedule_id%TYPE,
        p_link_to_customer_trx_id IN ar_receivable_applications.link_to_customer_trx_id%TYPE,
        p_amount_applied  IN ar_receivable_applications.amount_applied%TYPE,
        p_apply_date      IN ar_receivable_applications.apply_date%TYPE,
        p_gl_date         IN ar_receivable_applications.gl_date%TYPE,
        p_receivables_trx_id IN ar_receivable_applications.receivables_trx_id%TYPE,
        p_ussgl_transaction_code IN ar_receivable_applications.ussgl_transaction_code%TYPE,
        p_attribute_category     IN ar_receivable_applications.attribute_category%TYPE,
        p_attribute1 IN ar_receivable_applications.attribute1%TYPE,
        p_attribute2 IN ar_receivable_applications.attribute2%TYPE,
        p_attribute3 IN ar_receivable_applications.attribute3%TYPE,
        p_attribute4 IN ar_receivable_applications.attribute4%TYPE,
        p_attribute5 IN ar_receivable_applications.attribute5%TYPE,
        p_attribute6 IN ar_receivable_applications.attribute6%TYPE,
        p_attribute7 IN ar_receivable_applications.attribute7%TYPE,
        p_attribute8 IN ar_receivable_applications.attribute8%TYPE,
        p_attribute9 IN ar_receivable_applications.attribute9%TYPE,
        p_attribute10 IN ar_receivable_applications.attribute10%TYPE,
        p_attribute11 IN ar_receivable_applications.attribute11%TYPE,
        p_attribute12 IN ar_receivable_applications.attribute12%TYPE,
        p_attribute13 IN ar_receivable_applications.attribute13%TYPE,
        p_attribute14 IN ar_receivable_applications.attribute14%TYPE,
        p_attribute15 IN ar_receivable_applications.attribute15%TYPE,
        p_global_attribute_category IN ar_receivable_applications.global_attribute_category%TYPE,
        p_global_attribute1 IN ar_receivable_applications.global_attribute1%TYPE,
        p_global_attribute2 IN ar_receivable_applications.global_attribute2%TYPE,
        p_global_attribute3 IN ar_receivable_applications.global_attribute3%TYPE,
        p_global_attribute4 IN ar_receivable_applications.global_attribute4%TYPE,
        p_global_attribute5 IN ar_receivable_applications.global_attribute5%TYPE,
        p_global_attribute6 IN ar_receivable_applications.global_attribute6%TYPE,
        p_global_attribute7 IN ar_receivable_applications.global_attribute7%TYPE,
        p_global_attribute8 IN ar_receivable_applications.global_attribute8%TYPE,
        p_global_attribute9 IN ar_receivable_applications.global_attribute9%TYPE,
        p_global_attribute10 IN ar_receivable_applications.global_attribute10%TYPE,
        p_global_attribute11 IN ar_receivable_applications.global_attribute11%TYPE,
        p_global_attribute12 IN ar_receivable_applications.global_attribute12%TYPE,
        p_global_attribute13 IN ar_receivable_applications.global_attribute13%TYPE,
        p_global_attribute14 IN ar_receivable_applications.global_attribute14%TYPE,
        p_global_attribute15 IN ar_receivable_applications.global_attribute15%TYPE,
        p_global_attribute16 IN ar_receivable_applications.global_attribute16%TYPE,
        p_global_attribute17 IN ar_receivable_applications.global_attribute17%TYPE,
        p_global_attribute18 IN ar_receivable_applications.global_attribute18%TYPE,
        p_global_attribute19 IN ar_receivable_applications.global_attribute19%TYPE,
        p_global_attribute20 IN ar_receivable_applications.global_attribute20%TYPE,
        p_comments IN
                ar_receivable_applications.comments%TYPE DEFAULT NULL,
        p_module_name IN VARCHAR2,
        p_module_version IN VARCHAR2,
        p_application_ref_type IN OUT NOCOPY
                ar_receivable_applications.application_ref_type%TYPE,
        p_application_ref_id IN OUT NOCOPY
                ar_receivable_applications.application_ref_id%TYPE,
        p_application_ref_num IN OUT NOCOPY
                ar_receivable_applications.application_ref_num%TYPE,
        p_secondary_application_ref_id IN OUT NOCOPY NUMBER,
        p_payment_set_id IN NUMBER DEFAULT NULL,
	p_called_from IN VARCHAR2 DEFAULT NULL , /*5444407*/
        p_out_rec_application_id OUT NOCOPY NUMBER,
        p_applied_rec_app_id IN NUMBER DEFAULT NULL,
        p_customer_reference IN ar_receivable_applications.customer_reference%TYPE DEFAULT NULL,
        p_netted_receipt_flag IN VARCHAR2 DEFAULT NULL,
        p_netted_cash_receipt_id IN
           ar_cash_receipts.cash_receipt_id%TYPE DEFAULT NULL ,
        p_secondary_app_ref_type IN
        ar_receivable_applications.secondary_application_ref_type%TYPE := null,
        p_secondary_app_ref_num IN
        ar_receivable_applications.secondary_application_ref_num%TYPE := null,
        p_customer_reason IN ar_receivable_applications.customer_reason%TYPE DEFAULT NULL,
        p_application_ref_reason IN ar_receivable_applications.application_ref_reason%TYPE Default NULL --Bug5450371

        );

--Other_account_application procedure is introduced for Claim application
PROCEDURE other_account_application(
        p_receipt_ps_id   IN ar_payment_schedules.payment_schedule_id%TYPE,
        p_amount_applied IN
                ar_receivable_applications.amount_applied%TYPE,
        p_apply_date IN ar_receivable_applications.apply_date%TYPE,
        p_gl_date IN ar_receivable_applications.gl_date%TYPE,
        p_receivables_trx_id ar_receivable_applications.receivables_trx_id%TYPE,
        p_applied_ps_id  IN ar_receivable_applications.applied_payment_schedule_id%TYPE,
        p_ussgl_transaction_code IN
                ar_receivable_applications.ussgl_transaction_code%TYPE,
        p_application_ref_type IN
                ar_receivable_applications.application_ref_type%TYPE,
        p_application_ref_id IN
                ar_receivable_applications.application_ref_id%TYPE,
        p_application_ref_num IN
                ar_receivable_applications.application_ref_num%TYPE,
        p_secondary_application_ref_id IN  NUMBER DEFAULT NULL,
        p_comments IN
                ar_receivable_applications.comments%TYPE,
        p_attribute_category IN
                ar_receivable_applications.attribute_category%TYPE,
        p_attribute1 IN ar_receivable_applications.attribute1%TYPE,
        p_attribute2 IN ar_receivable_applications.attribute2%TYPE,
        p_attribute3 IN ar_receivable_applications.attribute3%TYPE,
        p_attribute4 IN ar_receivable_applications.attribute4%TYPE,
        p_attribute5 IN ar_receivable_applications.attribute5%TYPE,
        p_attribute6 IN ar_receivable_applications.attribute6%TYPE,
        p_attribute7 IN ar_receivable_applications.attribute7%TYPE,
        p_attribute8 IN ar_receivable_applications.attribute8%TYPE,
        p_attribute9 IN ar_receivable_applications.attribute9%TYPE,
        p_attribute10 IN ar_receivable_applications.attribute10%TYPE,
        p_attribute11 IN ar_receivable_applications.attribute11%TYPE,
        p_attribute12 IN ar_receivable_applications.attribute12%TYPE,
        p_attribute13 IN ar_receivable_applications.attribute13%TYPE,
        p_attribute14 IN ar_receivable_applications.attribute14%TYPE,
        p_attribute15 IN ar_receivable_applications.attribute15%TYPE,
        p_global_attribute_category IN ar_receivable_applications.global_attribute_category%TYPE,
        p_global_attribute1 IN ar_receivable_applications.global_attribute1%TYPE,
        p_global_attribute2 IN ar_receivable_applications.global_attribute2%TYPE,
        p_global_attribute3 IN ar_receivable_applications.global_attribute3%TYPE,
        p_global_attribute4 IN ar_receivable_applications.global_attribute4%TYPE,
        p_global_attribute5 IN ar_receivable_applications.global_attribute5%TYPE,
        p_global_attribute6 IN ar_receivable_applications.global_attribute6%TYPE,
        p_global_attribute7 IN ar_receivable_applications.global_attribute7%TYPE,
        p_global_attribute8 IN ar_receivable_applications.global_attribute8%TYPE,
        p_global_attribute9 IN ar_receivable_applications.global_attribute9%TYPE,
        p_global_attribute10 IN ar_receivable_applications.global_attribute10%TYPE,
        p_global_attribute11 IN ar_receivable_applications.global_attribute11%TYPE,
        p_global_attribute12 IN ar_receivable_applications.global_attribute12%TYPE,
        p_global_attribute13 IN ar_receivable_applications.global_attribute13%TYPE,
        p_global_attribute14 IN ar_receivable_applications.global_attribute14%TYPE,
        p_global_attribute15 IN ar_receivable_applications.global_attribute15%TYPE,
        p_global_attribute16 IN ar_receivable_applications.global_attribute16%TYPE,
        p_global_attribute17 IN ar_receivable_applications.global_attribute17%TYPE,
        p_global_attribute18 IN ar_receivable_applications.global_attribute18%TYPE,
        p_global_attribute19 IN ar_receivable_applications.global_attribute19%TYPE,
        p_global_attribute20 IN ar_receivable_applications.global_attribute20%TYPE,
        p_module_name IN VARCHAR2,
        p_module_version IN VARCHAR2,
        p_payment_set_id IN ar_receivable_applications.payment_set_id%TYPE,
        x_application_ref_id OUT NOCOPY
                ar_receivable_applications.application_ref_id%TYPE,
        x_application_ref_num OUT NOCOPY
                ar_receivable_applications.application_ref_num%TYPE
        , x_return_status               OUT NOCOPY VARCHAR2
        , x_msg_count                   OUT NOCOPY NUMBER
        , x_msg_data                    OUT NOCOPY VARCHAR2
	, p_out_rec_application_id      OUT NOCOPY NUMBER
        , p_application_ref_reason IN ar_receivable_applications.application_ref_reason%TYPE DEFAULT NULL
        , p_customer_reference     IN ar_receivable_applications.customer_reference%TYPE DEFAULT NULL
        , p_customer_reason        IN ar_receivable_applications.customer_reason%TYPE DEFAULT NULL
        , x_claim_reason_name      OUT NOCOPY VARCHAR2
	, p_called_from		   IN  VARCHAR2 DEFAULT NULL
);
PROCEDURE create_claim(
              p_amount               IN  NUMBER
            , p_amount_applied       IN  NUMBER
            , p_currency_code        IN  VARCHAR2
            , p_exchange_rate_type   IN  VARCHAR2
            , p_exchange_rate_date   IN  DATE
            , p_exchange_rate        IN  NUMBER
            , p_customer_trx_id      IN  NUMBER
            , p_invoice_ps_id        IN  NUMBER
            , p_cust_trx_type_id     IN  NUMBER
            , p_trx_number           IN  VARCHAR2
            , p_cust_account_id      IN  NUMBER
            , p_bill_to_site_id      IN  NUMBER
            , p_ship_to_site_id      IN  NUMBER
            , p_salesrep_id          IN  NUMBER
            , p_customer_ref_date    IN  DATE
            , p_customer_ref_number  IN  VARCHAR2
            , p_cash_receipt_id      IN  NUMBER
            , p_receipt_number       IN  VARCHAR2
            , p_reason_id            IN  NUMBER
            , p_customer_reason      IN  VARCHAR2
            , p_comments             IN  VARCHAR2
            , p_apply_date           IN  DATE DEFAULT NULL
            , p_attribute_category   IN  VARCHAR2
            , p_attribute1           IN  VARCHAR2
            , p_attribute2           IN  VARCHAR2
            , p_attribute3           IN  VARCHAR2
            , p_attribute4           IN  VARCHAR2
            , p_attribute5           IN  VARCHAR2
            , p_attribute6           IN  VARCHAR2
            , p_attribute7           IN  VARCHAR2
            , p_attribute8           IN  VARCHAR2
            , p_attribute9           IN  VARCHAR2
            , p_attribute10          IN  VARCHAR2
            , p_attribute11          IN  VARCHAR2
            , p_attribute12          IN  VARCHAR2
            , p_attribute13          IN  VARCHAR2
            , p_attribute14          IN  VARCHAR2
            , p_attribute15          IN  VARCHAR2
            , x_return_status        OUT NOCOPY VARCHAR2
            , x_msg_count            OUT NOCOPY NUMBER
            , x_msg_data             OUT NOCOPY VARCHAR2
            , x_claim_id             OUT NOCOPY NUMBER
            , x_claim_number         OUT NOCOPY VARCHAR2
            , x_claim_reason_name    OUT NOCOPY VARCHAR2
            , p_legal_entity_id      IN  NUMBER);

PROCEDURE update_claim(
              p_claim_id             IN OUT NOCOPY NUMBER
            , p_invoice_ps_id        IN  NUMBER
            , p_customer_trx_id      IN  NUMBER
            , p_amount               IN  NUMBER
            , p_amount_applied       IN  NUMBER
            , p_apply_date           IN  DATE
            , p_cash_receipt_id      IN  NUMBER
            , p_receipt_number       IN  VARCHAR2
            , p_action_type          IN  VARCHAR2
            , x_claim_reason_code_id OUT NOCOPY NUMBER
            , x_claim_reason_name    OUT NOCOPY VARCHAR2
            , x_claim_number         OUT NOCOPY VARCHAR2
            , x_return_status        OUT NOCOPY VARCHAR2
            , x_msg_count            OUT NOCOPY NUMBER
            , x_msg_data             OUT NOCOPY VARCHAR2
            , p_reason_id            IN  NUMBER  DEFAULT NULL--Yao Zhang add for bug 10197191
            );
PROCEDURE get_claim_status(
	p_claim_id IN     NUMBER,
        x_claim_status    OUT NOCOPY VARCHAR2);

PROCEDURE put_trx_in_dispute(
              p_invoice_ps_id               IN  NUMBER
            , p_dispute_amount              IN  NUMBER
            , p_active_claim                IN  VARCHAR2 DEFAULT NULL);

PROCEDURE update_dispute_on_trx(
              p_invoice_ps_id               IN  NUMBER
            , p_active_claim                IN  VARCHAR2 DEFAULT NULL
            , p_amount                      IN  NUMBER);

PROCEDURE fetch_app_ccid(
              p_invoice_ps_id           IN
                        ar_payment_schedules.payment_schedule_id%TYPE,
              p_applied_customer_trx_id OUT NOCOPY
                        ar_receivable_applications.applied_customer_trx_id%TYPE,              p_code_combination_id     OUT NOCOPY
                        ar_receivable_applications.code_combination_id%TYPE,
              p_source_type             OUT NOCOPY
                        ar_distributions.source_type%TYPE);

PROCEDURE Unassociate_Regular_CM ( p_cust_Trx_id IN NUMBER,
                               p_app_cust_trx_id IN NUMBER);

FUNCTION is_regular_cm (p_customer_Trx_id IN NUMBER,
                        p_invoicing_rule_id OUT NOCOPY NUMBER) return BOOLEAN;

END arp_process_application;

/
