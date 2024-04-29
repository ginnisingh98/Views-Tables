--------------------------------------------------------
--  DDL for Package ARP_ARXVASUM_AMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_ARXVASUM_AMT" AUTHID CURRENT_USER AS
/* $Header: ARCEAMTS.pls 115.3 2002/11/15 02:14:02 anukumar ship $ */


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
p_min_acc_unit IN  NUMBER
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
p_min_acc_unit IN  NUMBER
 );



End;

 

/
