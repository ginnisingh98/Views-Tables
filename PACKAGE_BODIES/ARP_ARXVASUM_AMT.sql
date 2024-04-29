--------------------------------------------------------
--  DDL for Package Body ARP_ARXVASUM_AMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_ARXVASUM_AMT" AS
/* $Header: ARCEAMTB.pls 115.4 2002/11/18 21:34:10 anukumar ship $ */


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
 ) is
begin
select  decode(p_currency_code,
        NULL , NULL , nvl(sum(a.amount),0)),
        nvl(sum( decode(p_exc_rate,
                  NULL, a.acctd_amount,
                        arpcurr.functional_amount(a.amount,
                          p_func_curr,
                          p_exc_rate,
                          p_precision,
                          p_min_acc_unit ))),0),
        count(a.amount)
into    p_financecharg_amount,
        p_financecharg_func_amt,
        p_financecharg_count
from    ar_adjustments a,
        ar_payment_schedules ps,
        ar_receivables_trx rt
where
        a.gl_date between p_start_date
                       and p_end_date
and     nvl(a.postable,'Y')      = 'Y'
and     a.payment_schedule_id    = ps.payment_schedule_id
and     ps.customer_id           = p_customer_id
and     nvl(ps.customer_site_use_id, -10) = nvl(p_site_use_id, nvl(ps.customer_site_use_id, -10) )
and     a.receivables_trx_id     = rt.receivables_trx_id
and     nvl(rt.type,'X')         = 'FINCHRG'
AND     ps.invoice_currency_code = nvl(p_currency_code, ps.invoice_currency_code)
AND     nvl(ps.receipt_confirmed_flag,'Y') = 'Y';


--arp_standard.enable_debug;
EXCEPTION
        WHEN OTHERS THEN
             arp_standard.debug( 'Exception:');
end;



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
 ) is
begin
SELECT  decode(p_currency_code,
        NULL , NULL , nvl(sum(ra.earned_discount_taken),0)),
        decode(p_currency_code,
        NULL , NULL , nvl(sum(ra.unearned_discount_taken),0)),
        nvl(sum( decode(p_exc_rate,
                  NULL, ra.acctd_earned_discount_taken,
                        arpcurr.functional_amount( nvl(ra.earned_discount_taken,0),
                          p_func_curr,
                          p_exc_rate,
                          p_precision,
                          p_min_acc_unit ))),0),
        nvl(sum( decode(p_exc_rate,
                  NULL, ra.acctd_unearned_discount_taken,
                        arpcurr.functional_amount( nvl(ra.unearned_discount_taken,0),
                          p_func_curr,
                          p_exc_rate,
                          p_precision,
                          p_min_acc_unit ))),0),
        count(ra.earned_discount_taken),
        count(ra.unearned_discount_taken)
INTO    p_earned_discounts,
        p_unearned_discounts,
        p_earned_func_disc,
        p_unearned_func_disc,
        p_earned_disc_count,
        p_unearned_disc_count
FROM    ar_payment_schedules ps,
        ar_receivable_applications ra
where
        ra.gl_date between p_start_date
                       and p_end_date
AND     ps.payment_schedule_id   = ra.applied_payment_schedule_id
and     ps.customer_id           = p_customer_id
and     nvl(ps.customer_site_use_id, -10) = nvl(p_site_use_id, nvl(ps.customer_site_use_id, -10) )
AND     ps.invoice_currency_code = nvl(p_currency_code, ps.invoice_currency_code)
AND     nvl(ps.receipt_confirmed_flag,'Y') = 'Y';


--arp_standard.enable_debug;
EXCEPTION
        WHEN OTHERS THEN
             arp_standard.debug( 'Exception:');
end;



end;

/
