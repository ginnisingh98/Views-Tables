--------------------------------------------------------
--  DDL for Package ARP_PROC_RCT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROC_RCT_UTIL" AUTHID CURRENT_USER AS
/* $Header: ARRURGWS.pls 120.9.12010000.2 2009/04/10 09:10:23 mpsingh ship $ */

/* ------------ Private procedures used by the package --------------------- */
/* ------------ ARP_PROCESS_RECEIPTS (ARRERGW?.pls)    --------------------- */

FUNCTION revision RETURN VARCHAR2;


PROCEDURE insert_ps_rec_cash(
	p_cr_rec	IN  ar_cash_receipts%ROWTYPE,
	p_gl_date	IN  DATE,
	p_maturity_date IN  DATE,
	p_acctd_amount	IN
		ar_payment_schedules.acctd_amount_due_remaining%TYPE,
        p_ps_id		OUT NOCOPY
		ar_payment_schedules.payment_schedule_id%TYPE
				);

PROCEDURE insert_crh_rec(
	p_cr_rec		IN  ar_cash_receipts%ROWTYPE,
	p_crh_amount		IN  ar_cash_receipt_history.amount%TYPE,
	p_acctd_amount		IN  ar_cash_receipt_history.acctd_amount%TYPE,
	p_factor_discount_amount IN
		ar_cash_receipt_history.factor_discount_amount%TYPE,
	p_acctd_factor_discount_amount IN
		ar_cash_receipt_history.acctd_factor_discount_amount%TYPE,
	p_gl_date		IN  DATE,
	p_creation_status 	IN  VARCHAR2,
	p_batch_id		IN  ar_cash_receipt_history.batch_id%TYPE,
	p_ccid			IN
		ar_cash_receipt_history.account_code_combination_id%TYPE,
	p_bank_charges_ccid	IN
		ar_cash_receipt_history.bank_charge_account_ccid%TYPE,
	p_crh_rec		OUT NOCOPY ar_cash_receipt_history%ROWTYPE,
        p_called_from      IN  VARCHAR2 DEFAULT NULL -- Bug 66608534
				);

PROCEDURE insert_ra_rec_cash(
	p_cash_receipt_id IN ar_cash_receipts.cash_receipt_id%TYPE,
	p_amount	IN ar_cash_receipts.amount%TYPE,
	p_apply_date	IN DATE,
	p_status	IN ar_cash_receipts.status%TYPE,
	p_acctd_amount	IN
		ar_receivable_applications.acctd_amount_applied_from%TYPE,
	p_gl_date  	IN  DATE,
	p_ccid		IN
		ar_receivable_applications.code_combination_id%TYPE,
	p_payment_schedule_id 	IN
		ar_payment_schedules.payment_schedule_id%TYPE,
	p_application_rule IN ar_receivable_applications.application_rule%TYPE,
        p_reversal_gl_date IN DATE default null,
        p_ra_id            OUT NOCOPY ar_receivable_applications.receivable_application_id%TYPE ,
        p_called_from      IN  VARCHAR2 DEFAULT NULL -- Bug 66608534
			);

PROCEDURE insert_dist_rec(
	p_amount		IN ar_cash_receipts.amount%TYPE,
        p_acctd_amount		IN ar_cash_receipt_history.acctd_amount%TYPE,
        p_crh_id		IN
			ar_cash_receipt_history.cash_receipt_history_id%TYPE,
	p_source_type		IN ar_distributions.source_type%TYPE,
	p_ccid			IN ar_distributions.code_combination_id%TYPE,
        p_called_from      IN  VARCHAR2 DEFAULT NULL -- jrautiai BR project
			);

PROCEDURE round_mcd_recs(
	p_cash_receipt_id	IN ar_cash_receipts.cash_receipt_id%TYPE
			);


PROCEDURE insert_misc_dist(
	p_cash_receipt_id	IN ar_cash_receipts.cash_receipt_id%TYPE,
	p_gl_date		IN ar_cash_receipt_history.gl_date%TYPE,
	p_amount		IN ar_cash_receipts.amount%TYPE,
	p_currency_code		IN ar_cash_receipts.currency_code%TYPE,
	p_exchange_rate		IN ar_cash_receipts.exchange_rate%TYPE,
	p_acctd_amount		IN ar_cash_receipt_history.acctd_amount%TYPE,
	p_receipt_date		IN ar_cash_receipts.receipt_date%TYPE,
	p_receivables_trx_id	IN ar_cash_receipts.receivables_trx_id%TYPE,
        p_distribution_set_id   IN ar_cash_receipts.distribution_set_id%TYPE default NULL,
        p_ussgl_trx_code        IN ar_cash_receipts.ussgl_transaction_code%TYPE default NULL,
        p_created_from          IN ar_misc_cash_distributions.created_from%TYPE default 'ARRERCT'
				);


PROCEDURE update_misc_dist(
	p_cash_receipt_id	IN ar_cash_receipts.cash_receipt_id%TYPE,
	p_amount		IN ar_cash_receipts.amount%TYPE,
	p_acctd_amount		IN ar_cash_receipt_history.acctd_amount%TYPE,
	p_amount_changed_flag	IN BOOLEAN,
	p_distribution_set_id	IN ar_cash_receipts.distribution_set_id%TYPE,
	p_receivables_trx_id	IN ar_cash_receipts.receivables_trx_id%TYPE,
	p_old_distribution_set_id IN ar_cash_receipts.distribution_set_id%TYPE,
	p_old_receivables_trx_id  IN ar_cash_receipts.receivables_trx_id%TYPE,
	p_gl_date		IN ar_cash_receipt_history.gl_date%TYPE,
	p_gl_date_changed_flag  IN BOOLEAN,
	p_currency_code		IN ar_cash_receipts.currency_code%TYPE,
	p_exchange_rate		IN ar_cash_receipts.exchange_rate%TYPE,
	p_receipt_date		IN ar_cash_receipts.receipt_date%TYPE,
	p_receipt_date_changed_flag IN BOOLEAN,
	p_gl_tax_acct IN ar_distributions.code_combination_id%TYPE
				);

PROCEDURE create_mcd_recs(
	p_cash_receipt_id 	IN ar_cash_receipts.cash_receipt_id%TYPE,
	p_amount		IN ar_cash_receipts.amount%TYPE,
	p_acctd_amount		IN ar_cash_receipt_history.acctd_amount%TYPE,
	p_exchange_rate 	IN ar_cash_receipts.exchange_rate%TYPE,
	p_currency_code 	IN ar_cash_receipts.currency_code%TYPE,
	p_gl_date		IN ar_cash_receipt_history.gl_date%TYPE,
	p_receipt_date		IN ar_cash_receipts.receipt_date%TYPE,
	p_distribution_set_id	IN ar_cash_receipts.distribution_set_id%TYPE,
        p_ussgl_trx_code        IN ar_cash_receipts.ussgl_transaction_code%TYPE
			);


PROCEDURE update_manual_dist(
		p_cash_receipt_id  IN ar_cash_receipts.cash_receipt_id%TYPE,
		p_amount	   IN ar_cash_receipts.amount%TYPE,
		p_acctd_amount	   IN ar_cash_receipt_history.acctd_amount%TYPE,
		p_exchange_rate    IN ar_cash_receipts.exchange_rate%TYPE,
		p_currency_code    IN ar_cash_receipts.currency_code%TYPE,
		p_gl_date	   IN ar_cash_receipt_history.gl_date%TYPE,
		p_receipt_date	   IN ar_cash_receipts.receipt_date%TYPE
			);


PROCEDURE rate_adjust(
	p_cash_receipt_id	      IN ar_cash_receipts.cash_receipt_id%TYPE,
	p_rate_adjust_gl_date	      IN DATE,
	p_new_exchange_date	      IN DATE,
	p_new_exchange_rate	      IN ar_rate_adjustments.new_exchange_rate%TYPE,
	p_new_exchange_rate_type      IN ar_rate_adjustments.new_exchange_rate_type%TYPE,
	p_old_exchange_date	      IN DATE,
	p_old_exchange_rate	      IN ar_rate_adjustments.old_exchange_rate%TYPE,
	p_old_exchange_rate_type      IN ar_rate_adjustments.old_exchange_rate_type%TYPE,
	p_gain_loss		      IN ar_rate_adjustments.gain_loss%TYPE,
	p_exchange_rate_attr_cat      IN ar_rate_adjustments.attribute_category%TYPE,
 	p_exchange_rate_attr1	      IN ar_rate_adjustments.attribute1%TYPE,
 	p_exchange_rate_attr2	      IN ar_rate_adjustments.attribute2%TYPE,
 	p_exchange_rate_attr3	      IN ar_rate_adjustments.attribute3%TYPE,
 	p_exchange_rate_attr4	      IN ar_rate_adjustments.attribute4%TYPE,
 	p_exchange_rate_attr5	      IN ar_rate_adjustments.attribute5%TYPE,
 	p_exchange_rate_attr6	      IN ar_rate_adjustments.attribute6%TYPE,
 	p_exchange_rate_attr7	      IN ar_rate_adjustments.attribute7%TYPE,
 	p_exchange_rate_attr8	      IN ar_rate_adjustments.attribute8%TYPE,
 	p_exchange_rate_attr9	      IN ar_rate_adjustments.attribute9%TYPE,
 	p_exchange_rate_attr10	      IN ar_rate_adjustments.attribute10%TYPE,
 	p_exchange_rate_attr11	      IN ar_rate_adjustments.attribute11%TYPE,
 	p_exchange_rate_attr12	      IN ar_rate_adjustments.attribute12%TYPE,
 	p_exchange_rate_attr13	      IN ar_rate_adjustments.attribute13%TYPE,
 	p_exchange_rate_attr14	      IN ar_rate_adjustments.attribute14%TYPE,
 	p_exchange_rate_attr15	      IN ar_rate_adjustments.attribute15%TYPE);

PROCEDURE  get_ccids(
	p_receipt_method_id		IN 	NUMBER,
	p_remittance_bank_account_id	IN 	NUMBER,
	p_unidentified_ccid		OUT NOCOPY	NUMBER,
	p_unapplied_ccid		OUT NOCOPY	NUMBER,
	p_on_account_ccid		OUT NOCOPY	NUMBER,
	p_earned_ccid			OUT NOCOPY	NUMBER,
	p_unearned_ccid			OUT NOCOPY	NUMBER,
	p_bank_charges_ccid		OUT NOCOPY	NUMBER,
	p_factor_ccid			OUT NOCOPY	NUMBER,
	p_confirmation_ccid		OUT NOCOPY	NUMBER,
	p_remittance_ccid		OUT NOCOPY 	NUMBER,
	p_cash_ccid			OUT NOCOPY	NUMBER
	);

PROCEDURE get_ps_rec(	p_cash_receipt_id 	IN NUMBER,
			p_ps_rec		OUT NOCOPY ar_payment_schedules%ROWTYPE);

PROCEDURE update_dist_rec( p_crh_id		IN NUMBER,
			   p_source_type	IN ar_distributions.source_type%TYPE,
			   p_amount		IN NUMBER,
			   p_acctd_amount	IN NUMBER);

END ARP_PROC_RCT_UTIL;

/
