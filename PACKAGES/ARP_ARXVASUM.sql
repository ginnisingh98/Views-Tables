--------------------------------------------------------
--  DDL for Package ARP_ARXVASUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_ARXVASUM" AUTHID CURRENT_USER AS
/* $Header: ARCESUMS.pls 120.3 2005/10/30 04:14:12 appldev ship $ */

procedure get_amounts( p_customer_id IN hz_cust_accounts.cust_account_id%TYPE,
p_site_use_id IN hz_cust_site_uses.site_use_id%TYPE,
p_start_date IN gl_period_statuses.start_date%TYPE,
p_end_date IN gl_period_statuses.end_date%TYPE,
p_currency_code IN
ar_payment_schedules.invoice_currency_code%TYPE,
p_inv_count IN OUT NOCOPY NUMBER,
p_dm_count IN OUT NOCOPY NUMBER,
p_cb_count IN OUT NOCOPY NUMBER,
p_dep_count IN OUT NOCOPY NUMBER,
p_guar_count IN OUT NOCOPY NUMBER,
p_pmt_count IN OUT NOCOPY NUMBER,
p_cm_count IN OUT NOCOPY NUMBER,
p_risk_count IN OUT NOCOPY NUMBER,
p_br_count IN OUT NOCOPY NUMBER, /* 18-MAY-2000 J Rautiainen BR Implementation */
p_sum_inv_ori_amt IN OUT NOCOPY NUMBER,
p_sum_dm_ori_amt IN OUT NOCOPY NUMBER,
p_sum_cb_ori_amt IN OUT NOCOPY NUMBER,
p_sum_dep_ori_amt IN OUT NOCOPY NUMBER,
p_sum_guar_ori_amt IN OUT NOCOPY NUMBER,
p_sum_pmt_ori_amt IN OUT NOCOPY NUMBER,
p_sum_cm_ori_amt  IN OUT NOCOPY NUMBER,
p_sum_risk_ori_amt IN OUT NOCOPY NUMBER,
p_sum_br_ori_amt IN OUT NOCOPY NUMBER, /* 18-MAY-2000 J Rautiainen BR Implementation */
p_sum_inv_rem_amt IN OUT NOCOPY NUMBER,
p_sum_dm_rem_amt IN OUT NOCOPY NUMBER,
p_sum_cb_rem_amt IN OUT NOCOPY NUMBER,
p_sum_dep_rem_amt IN OUT NOCOPY NUMBER,
p_sum_guar_rem_amt IN OUT NOCOPY NUMBER,
p_sum_pmt_rem_amt IN OUT NOCOPY NUMBER,
p_sum_cm_rem_amt IN OUT NOCOPY NUMBER,
p_sum_risk_rem_amt IN OUT NOCOPY NUMBER,
p_sum_br_rem_amt IN OUT NOCOPY NUMBER, /* 18-MAY-2000 J Rautiainen BR Implementation */
p_sum_inv_func_ori_amt IN OUT NOCOPY NUMBER,
p_sum_dm_func_ori_amt IN OUT NOCOPY NUMBER,
p_sum_cb_func_ori_amt IN OUT NOCOPY NUMBER,
p_sum_dep_func_ori_amt IN OUT NOCOPY NUMBER,
p_sum_guar_func_ori_amt IN OUT NOCOPY NUMBER,
p_sum_pmt_func_ori_amt IN OUT NOCOPY NUMBER,
p_sum_cm_func_ori_amt IN OUT NOCOPY NUMBER,
p_sum_risk_func_ori_amt IN OUT NOCOPY NUMBER,
p_sum_br_func_ori_amt IN OUT NOCOPY NUMBER, /* 18-MAY-2000 J Rautiainen BR Implementation */
p_sum_inv_func_rem_amt IN OUT NOCOPY NUMBER,
p_sum_dm_func_rem_amt IN OUT NOCOPY NUMBER,
p_sum_cb_func_rem_amt IN OUT NOCOPY NUMBER,
p_sum_dep_func_rem_amt IN OUT NOCOPY NUMBER,
p_sum_guar_func_rem_amt IN OUT NOCOPY NUMBER,
p_sum_pmt_func_rem_amt IN OUT NOCOPY NUMBER,
p_sum_cm_func_rem_amt IN OUT NOCOPY NUMBER,
p_sum_risk_func_rem_amt IN OUT NOCOPY NUMBER,
p_sum_br_func_rem_amt IN OUT NOCOPY NUMBER, /* 18-MAY-2000 J Rautiainen BR Implementation */
p_func_curr IN VARCHAR2,
p_exc_rate IN NUMBER,
p_precision IN NUMBER,
p_min_acc_unit IN NUMBER,
p_status IN ar_payment_schedules.status%TYPE,
p_incl_rct_spmenu IN VARCHAR2
);

procedure get_payments_ontime(
p_payments_late_count IN OUT NOCOPY NUMBER,
p_payments_ontime_count IN OUT NOCOPY NUMBER,
p_payments_late_amount IN OUT NOCOPY NUMBER,
p_payments_ontime_amount IN OUT NOCOPY NUMBER,
p_payments_late_func_amt IN OUT NOCOPY NUMBER,
p_payments_ontime_func_amt IN OUT NOCOPY NUMBER,
p_start_date IN gl_period_statuses.start_date%TYPE,
p_end_date IN gl_period_statuses.end_date%TYPE,
p_customer_id IN hz_cust_accounts.cust_account_id%TYPE,
p_site_use_id IN hz_cust_site_uses.site_use_id%TYPE,
p_currency_code IN ar_payment_schedules.invoice_currency_code%TYPE,
p_func_curr IN VARCHAR2,
p_exc_rate IN NUMBER,
p_precision IN NUMBER,
p_min_acc_unit IN NUMBER,
p_status IN ar_payment_schedules.status%TYPE
);





procedure get_nsf_stop(
p_nsf_stop_amount IN OUT NOCOPY NUMBER,
p_nsf_stop_func_amt IN OUT NOCOPY NUMBER,
p_nsf_stop_count IN OUT NOCOPY NUMBER,
p_start_date IN gl_period_statuses.start_date%TYPE,
p_end_date IN gl_period_statuses.end_date%TYPE,
p_customer_id IN hz_cust_accounts.cust_account_id%TYPE,
p_site_use_id IN hz_cust_site_uses.site_use_id%TYPE,
p_currency_code IN ar_payment_schedules.invoice_currency_code%TYPE,
p_func_curr IN VARCHAR2,
p_exc_rate IN NUMBER,
p_precision IN NUMBER,
p_min_acc_unit NUMBER,
p_status IN  ar_payment_schedules.status%TYPE
 ) ;



procedure get_adjustments(
p_adjustment_amount IN OUT NOCOPY NUMBER,
p_adjustment_func_amt IN OUT NOCOPY NUMBER,
p_adjustment_count IN OUT NOCOPY NUMBER,
p_start_date IN gl_period_statuses.start_date%TYPE,
p_end_date IN gl_period_statuses.end_date%TYPE,
p_customer_id IN hz_cust_accounts.cust_account_id%TYPE,
p_site_use_id IN hz_cust_site_uses.site_use_id%TYPE,
p_currency_code IN ar_payment_schedules.invoice_currency_code%TYPE,
p_func_curr IN VARCHAR2,
p_exc_rate IN NUMBER,
p_precision IN NUMBER,
p_min_acc_unit IN  NUMBER,
p_status IN  ar_payment_schedules.status%TYPE
 );


procedure get_financecharg(
p_financecharg_amount IN OUT NOCOPY NUMBER,
p_financecharg_func_amt IN OUT NOCOPY NUMBER,
p_financecharg_count IN OUT NOCOPY NUMBER,
p_start_date IN gl_period_statuses.start_date%TYPE,
p_end_date IN gl_period_statuses.end_date%TYPE,
p_customer_id IN hz_cust_accounts.cust_account_id%TYPE,
p_site_use_id IN hz_cust_site_uses.site_use_id%TYPE,
p_currency_code IN ar_payment_schedules.invoice_currency_code%TYPE,
p_func_curr IN VARCHAR2,
p_exc_rate IN NUMBER,
p_precision IN NUMBER,
p_min_acc_unit IN  NUMBER,
p_status IN ar_payment_schedules.status%TYPE
 ) ;


procedure get_discounts(
p_earned_discounts IN OUT NOCOPY NUMBER,
p_unearned_discounts IN OUT NOCOPY NUMBER,
p_earned_func_disc IN OUT NOCOPY NUMBER,
p_unearned_func_disc IN OUT NOCOPY NUMBER,
p_earned_disc_count IN OUT NOCOPY NUMBER,
p_unearned_disc_count IN OUT NOCOPY NUMBER,
p_start_date IN gl_period_statuses.start_date%TYPE,
p_end_date IN gl_period_statuses.end_date%TYPE,
p_customer_id IN hz_cust_accounts.cust_account_id%TYPE,
p_site_use_id IN hz_cust_site_uses.site_use_id%TYPE,
p_currency_code IN ar_payment_schedules.invoice_currency_code%TYPE,
p_func_curr IN VARCHAR2,
p_exc_rate IN NUMBER,
p_precision IN NUMBER,
p_min_acc_unit IN  NUMBER,
p_status IN ar_payment_schedules.status%TYPE
 );


procedure get_pending_confirmation(
p_pend_confirm_amt IN OUT NOCOPY NUMBER,
p_pend_confirm_func_amt IN OUT NOCOPY NUMBER,
p_pend_confirm_count IN OUT NOCOPY NUMBER,
p_start_date IN gl_period_statuses.start_date%TYPE,
p_end_date IN gl_period_statuses.end_date%TYPE,
p_customer_id IN hz_cust_accounts.cust_account_id%TYPE,
p_site_use_id IN hz_cust_site_uses.site_use_id%TYPE,
p_currency_code IN ar_payment_schedules.invoice_currency_code%TYPE,
p_func_curr IN VARCHAR2,
p_exc_rate IN NUMBER,
p_precision IN NUMBER,
p_min_acc_unit IN  NUMBER,
p_status IN ar_payment_schedules.status%TYPE
);


procedure get_pending_remit(
p_boe_ori_amt IN OUT NOCOPY NUMBER,
p_boe_func_ori_amt IN OUT NOCOPY NUMBER,
p_boe_rem_amt IN OUT NOCOPY NUMBER,
p_boe_func_rem_amt IN OUT NOCOPY NUMBER,
p_boe_count IN OUT NOCOPY NUMBER,
p_note_ori_amt IN OUT NOCOPY NUMBER,
p_note_func_ori_amt IN OUT NOCOPY NUMBER,
p_note_rem_amt IN OUT NOCOPY NUMBER,
p_note_func_rem_amt IN OUT NOCOPY NUMBER,
p_note_count IN OUT NOCOPY NUMBER,
p_other_ori_amt IN OUT NOCOPY NUMBER,
p_other_func_ori_amt IN OUT NOCOPY NUMBER,
p_other_rem_amt IN OUT NOCOPY NUMBER,
p_other_func_rem_amt IN OUT NOCOPY NUMBER,
p_other_count IN OUT NOCOPY NUMBER,
p_start_date IN gl_period_statuses.start_date%TYPE,p_end_date IN gl_period_statuses.end_date%TYPE,
p_customer_id IN hz_cust_accounts.cust_account_id%TYPE,
p_site_use_id IN hz_cust_site_uses.site_use_id%TYPE,
p_currency_code IN ar_payment_schedules.invoice_currency_code%TYPE,
p_func_curr IN VARCHAR2,
p_exc_rate IN NUMBER,
p_precision IN NUMBER,
p_min_acc_unit IN  NUMBER,
p_status IN ar_payment_schedules.status%TYPE,
p_incl_rct_spmenu IN VARCHAR2
);


procedure get_remitted(
p_standard_ori_amt      IN OUT NOCOPY NUMBER,
p_standard_func_ori_amt IN OUT NOCOPY NUMBER,
p_standard_rem_amt      IN OUT NOCOPY NUMBER,
p_standard_func_rem_amt IN OUT NOCOPY NUMBER,
p_standard_count        IN OUT NOCOPY NUMBER,
p_factored_ori_amt      IN OUT NOCOPY NUMBER,
p_factored_func_ori_amt IN OUT NOCOPY NUMBER,
p_factored_rem_amt      IN OUT NOCOPY NUMBER,
p_factored_func_rem_amt IN OUT NOCOPY NUMBER,
p_factored_count        IN OUT NOCOPY NUMBER,
p_start_date IN gl_period_statuses.start_date%TYPE,
p_end_date IN gl_period_statuses.end_date%TYPE,
p_customer_id IN hz_cust_accounts.cust_account_id%TYPE,
p_site_use_id IN hz_cust_site_uses.site_use_id%TYPE,
p_currency_code IN ar_payment_schedules.invoice_currency_code%TYPE,
p_func_curr IN VARCHAR2,
p_exc_rate IN NUMBER,
p_precision IN NUMBER,
p_min_acc_unit IN  NUMBER,
p_status IN ar_payment_schedules.status%TYPE,
p_incl_rct_spmenu IN VARCHAR2
);

procedure get_protested_BR(p_BR_protested_amt               IN OUT NOCOPY NUMBER,
                           p_BR_protested_func_amt          IN OUT NOCOPY NUMBER,
                           p_BR_protested_count             IN OUT NOCOPY NUMBER,
                           p_start_date                     IN gl_period_statuses.start_date%TYPE,
                           p_end_date                       IN gl_period_statuses.end_date%TYPE,
                           p_customer_id                    IN hz_cust_accounts.cust_account_id%TYPE,
                           p_site_use_id                    IN hz_cust_site_uses.site_use_id%TYPE,
                           p_currency_code                  IN ar_payment_schedules.invoice_currency_code%TYPE,
                           p_func_curr                      IN VARCHAR2,
                           p_exc_rate                       IN NUMBER,
                           p_precision                      IN NUMBER,
                           p_min_acc_unit                   IN NUMBER,
                           p_status                         IN ar_payment_schedules.status%TYPE);

procedure get_unpaid_BR(p_BR_unpaid_amt                  IN OUT NOCOPY NUMBER,
                        p_BR_unpaid_func_amt             IN OUT NOCOPY NUMBER,
                        p_BR_unpaid_count                IN OUT NOCOPY NUMBER,
                        p_start_date                     IN gl_period_statuses.start_date%TYPE,
                        p_end_date                       IN gl_period_statuses.end_date%TYPE,
                        p_customer_id                    IN hz_cust_accounts.cust_account_id%TYPE,
                        p_site_use_id                    IN hz_cust_site_uses.site_use_id%TYPE,
                        p_currency_code                  IN ar_payment_schedules.invoice_currency_code%TYPE,
                        p_func_curr                      IN VARCHAR2,
                        p_exc_rate                       IN NUMBER,
                        p_precision                      IN NUMBER,
                        p_min_acc_unit                   IN NUMBER,
                        p_status                         IN ar_payment_schedules.status%TYPE);

End;

 

/
