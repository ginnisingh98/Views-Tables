--------------------------------------------------------
--  DDL for Package Body ARP_ARXVASUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_ARXVASUM" AS
/* $Header: ARCESUMB.pls 120.5 2005/10/30 04:14:10 appldev ship $ */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

procedure get_amounts( p_customer_id              IN hz_cust_accounts.cust_account_id%TYPE,
                       p_site_use_id              IN hz_cust_site_uses.site_use_id%TYPE,
                       p_start_date               IN gl_period_statuses.start_date%TYPE,
                       p_end_date                 IN gl_period_statuses.end_date%TYPE,
                       p_currency_code            IN ar_payment_schedules.invoice_currency_code%TYPE,
                       p_inv_count                IN OUT NOCOPY NUMBER,
                       p_dm_count                 IN OUT NOCOPY NUMBER,
                       p_cb_count                 IN OUT NOCOPY NUMBER,
                       p_dep_count                IN OUT NOCOPY NUMBER,
                       p_guar_count               IN OUT NOCOPY NUMBER,
                       p_pmt_count                IN OUT NOCOPY NUMBER,
                       p_cm_count                 IN OUT NOCOPY NUMBER,
		       p_risk_count		  IN OUT NOCOPY NUMBER,
		       p_br_count                 IN OUT NOCOPY NUMBER, /* 18-MAY-2000 J Rautiainen BR Implementation */
                       p_sum_inv_ori_amt          IN OUT NOCOPY NUMBER,
                       p_sum_dm_ori_amt           IN OUT NOCOPY NUMBER,
                       p_sum_cb_ori_amt           IN OUT NOCOPY NUMBER,
                       p_sum_dep_ori_amt          IN OUT NOCOPY NUMBER,
                       p_sum_guar_ori_amt         IN OUT NOCOPY NUMBER,
                       p_sum_pmt_ori_amt          IN OUT NOCOPY NUMBER,
                       p_sum_cm_ori_amt           IN OUT NOCOPY NUMBER,
		       p_sum_risk_ori_amt	  IN OUT NOCOPY NUMBER,
		       p_sum_br_ori_amt           IN OUT NOCOPY NUMBER, /* 18-MAY-2000 J Rautiainen BR Implementation */
                       p_sum_inv_rem_amt          IN OUT NOCOPY NUMBER,
                       p_sum_dm_rem_amt           IN OUT NOCOPY NUMBER,
                       p_sum_cb_rem_amt           IN OUT NOCOPY NUMBER,
                       p_sum_dep_rem_amt          IN OUT NOCOPY NUMBER,
                       p_sum_guar_rem_amt         IN OUT NOCOPY NUMBER,
                       p_sum_pmt_rem_amt          IN OUT NOCOPY NUMBER,
                       p_sum_cm_rem_amt           IN OUT NOCOPY NUMBER,
		       p_sum_risk_rem_amt	  IN OUT NOCOPY NUMBER,
		       p_sum_br_rem_amt           IN OUT NOCOPY NUMBER, /* 18-MAY-2000 J Rautiainen BR Implementation */
                       p_sum_inv_func_ori_amt     IN OUT NOCOPY NUMBER,
                       p_sum_dm_func_ori_amt      IN OUT NOCOPY NUMBER,
                       p_sum_cb_func_ori_amt      IN OUT NOCOPY NUMBER,
                       p_sum_dep_func_ori_amt     IN OUT NOCOPY NUMBER,
                       p_sum_guar_func_ori_amt    IN OUT NOCOPY NUMBER,
                       p_sum_pmt_func_ori_amt     IN OUT NOCOPY NUMBER,
                       p_sum_cm_func_ori_amt      IN OUT NOCOPY NUMBER,
		       p_sum_risk_func_ori_amt    IN OUT NOCOPY NUMBER,
		       p_sum_br_func_ori_amt      IN OUT NOCOPY NUMBER, /* 18-MAY-2000 J Rautiainen BR Implementation */
                       p_sum_inv_func_rem_amt     IN OUT NOCOPY NUMBER,
                       p_sum_dm_func_rem_amt      IN OUT NOCOPY NUMBER,
                       p_sum_cb_func_rem_amt      IN OUT NOCOPY NUMBER,
                       p_sum_dep_func_rem_amt     IN OUT NOCOPY NUMBER,
                       p_sum_guar_func_rem_amt    IN OUT NOCOPY NUMBER,
                       p_sum_pmt_func_rem_amt     IN OUT NOCOPY NUMBER,
                       p_sum_cm_func_rem_amt      IN OUT NOCOPY NUMBER,
		       p_sum_risk_func_rem_amt	  IN OUT NOCOPY NUMBER,
                       p_sum_br_func_rem_amt      IN OUT NOCOPY NUMBER, /* 18-MAY-2000 J Rautiainen BR Implementation */
                       p_func_curr                IN VARCHAR2,
                       p_exc_rate                 IN NUMBER,
                       p_precision                IN NUMBER,
                       p_min_acc_unit             IN NUMBER,
                       p_status                   IN ar_payment_schedules.status%TYPE,
		       p_incl_rct_spmenu	  IN VARCHAR2
 ) IS
BEGIN
  SELECT  decode(p_currency_code,
                 NULL , NULL ,
                 nvl(sum(decode(ps.class, 'INV' , ps.amount_due_original, 0)),0)
                ),
          decode(p_currency_code,
                 NULL , NULL ,
                 nvl(sum(decode(ps.class, 'DM' , ps.amount_due_original, 0)),0)
                ),
          decode(p_currency_code,
                 NULL , NULL ,
                 nvl(sum(decode(ps.class, 'CB' , ps.amount_due_original, 0)),0)
                ),
          decode(p_currency_code,
                 NULL , NULL ,
                 nvl(sum(decode(ps.class, 'DEP' , ps.amount_due_original, 0)),0)
                ),
          decode(p_currency_code,
                 NULL , NULL ,
                 nvl(sum(decode(ps.class, 'GUAR' , ps.amount_due_original, 0)),0)
                ),
          decode(p_currency_code,
                 NULL , NULL ,
                 nvl(sum(decode(ps.class, 'CM' , ps.amount_due_original, 0)),0)
                ),
          /* 18-MAY-2000 J Rautiainen BR Implementation */
          decode(p_currency_code,
                 NULL , NULL ,
                 nvl(sum(decode(ps.class, 'BR' , ps.amount_due_original, 0)),0)
                ),
          decode(p_currency_code,
                 NULL , NULL ,
                 nvl(sum(decode(ps.class, 'INV' , ps.amount_due_remaining, 0)),0)
                ),
          decode(p_currency_code,
                 NULL , NULL ,
                 nvl(sum(decode(ps.class, 'DM' , ps.amount_due_remaining, 0)),0)
                ),
          decode(p_currency_code,
                 NULL , NULL ,
                 nvl(sum(decode(ps.class, 'CB' , ps.amount_due_remaining, 0)),0)
                ),
          decode(p_currency_code,
                 NULL , NULL ,
                 nvl(sum(decode(ps.class, 'DEP' , ps.amount_due_remaining, 0)),0)
                ),
          decode(p_currency_code,
                 NULL , NULL ,
                 nvl(sum(decode(ps.class, 'GUAR' , ps.amount_due_remaining, 0)),0)
                ),
          decode(p_currency_code,
                 NULL , NULL ,
                 nvl(sum(decode(ps.class, 'CM' , ps.amount_due_remaining, 0)),0)
                ),
          /* 18-MAY-2000 J Rautiainen BR Implementation */
          decode(p_currency_code,
                 NULL , NULL ,
                 nvl(sum(decode(ps.class, 'BR' , ps.amount_due_remaining, 0)),0)
                ),
          nvl(sum(decode(ps.class,
                         'INV' , arpcurr.functional_amount( ps.amount_due_original,
                                                            p_func_curr,
                                                            nvl(p_exc_rate,ps.exchange_rate),
                                                            p_precision,
                                                            p_min_acc_unit
                                                           ),
                         0)
                 ), 0),
          nvl(sum(decode(ps.class,
                         'DM' , arpcurr.functional_amount( ps.amount_due_original,
                                                           p_func_curr,
                                                           nvl(p_exc_rate,ps.exchange_rate),
                                                           p_precision,
                                                           p_min_acc_unit
                                                         ),
                         0)
                  ), 0),
          nvl(sum(decode(ps.class,
          'CB' , arpcurr.functional_amount( ps.amount_due_original,
                    p_func_curr,
                    nvl(p_exc_rate, ps.exchange_rate),
                    p_precision,
                    p_min_acc_unit ), 0)), 0),
        nvl(sum(decode(ps.class,
          'DEP' , arpcurr.functional_amount( ps.amount_due_original,
                    p_func_curr,
                    nvl(p_exc_rate, ps.exchange_rate),
                    p_precision,
                    p_min_acc_unit ), 0)), 0),
        nvl(sum(decode(ps.class,
          'GUAR' , arpcurr.functional_amount( ps.amount_due_original,
                    p_func_curr,
                    nvl(p_exc_rate, ps.exchange_rate),
                    p_precision,
                    p_min_acc_unit ), 0)), 0),
        nvl(sum(decode(ps.class,
          'CM' , arpcurr.functional_amount( ps.amount_due_original,
                    p_func_curr,
                    nvl(p_exc_rate, ps.exchange_rate),
                    p_precision,
                    p_min_acc_unit ), 0)), 0),
        /* 18-MAY-2000 J Rautiainen BR Implementation */
        nvl(sum(decode(ps.class,
          'BR' , arpcurr.functional_amount( ps.amount_due_original,
                    p_func_curr,
                    nvl(p_exc_rate, ps.exchange_rate),
                    p_precision,
                    p_min_acc_unit ), 0)), 0),
        nvl(sum(decode(ps.class,
        'INV' , decode(p_exc_rate,
          NULL, ps.acctd_amount_due_remaining,
                arpcurr.functional_amount( ps.amount_due_remaining,
                    p_func_curr,
                    p_exc_rate,
                    p_precision,
                    p_min_acc_unit )) ,0)), 0),
        nvl(sum(decode(ps.class,
        'DM' , decode(p_exc_rate,
          NULL, ps.acctd_amount_due_remaining,
                arpcurr.functional_amount( ps.amount_due_remaining,
                    p_func_curr,
                    p_exc_rate,
                    p_precision,
                    p_min_acc_unit ) ), 0)), 0),
        nvl(sum(decode(ps.class,
        'CB' , decode(p_exc_rate,
          NULL, ps.acctd_amount_due_remaining,
                arpcurr.functional_amount( ps.amount_due_remaining,
                    p_func_curr,
                    p_exc_rate,
                    p_precision,
                    p_min_acc_unit )), 0)), 0),
        nvl(sum(decode(ps.class,
        'DEP' , decode(p_exc_rate,
          NULL, ps.acctd_amount_due_remaining,
                arpcurr.functional_amount( ps.amount_due_remaining,
                    p_func_curr,
                    p_exc_rate,
                    p_precision,
                    p_min_acc_unit )), 0)), 0),
        nvl(sum(decode(ps.class,
        'GUAR' , decode(p_exc_rate,
          NULL, ps.acctd_amount_due_remaining,
                arpcurr.functional_amount( ps.amount_due_remaining,
                    p_func_curr,
                    p_exc_rate,
                    p_precision,
                    p_min_acc_unit )), 0)), 0),
        nvl(sum(decode(ps.class,
        'CM' , decode(p_exc_rate,
          NULL, ps.acctd_amount_due_remaining,
                arpcurr.functional_amount( ps.amount_due_remaining,
                    p_func_curr,
                    p_exc_rate,
                    p_precision,
                    p_min_acc_unit )), 0)), 0),
        /* 18-MAY-2000 J Rautiainen BR Implementation */
        nvl(sum(decode(ps.class,
        'BR' , decode(p_exc_rate,
          NULL, ps.acctd_amount_due_remaining,
                arpcurr.functional_amount( ps.amount_due_remaining,
                    p_func_curr,
                    p_exc_rate,
                    p_precision,
                    p_min_acc_unit )), 0)), 0),
        nvl(sum(decode(ps.class,
        'INV' , 1, 0)),0),
        nvl(sum(decode(ps.class,
        'DM' , 1, 0)),0),
        nvl(sum(decode(ps.class,
        'CB' , 1, 0)),0),
        nvl(sum(decode(ps.class,
        'DEP' , 1, 0)),0),
        nvl(sum(decode(ps.class,
        'GUAR' , 1, 0)),0),
        nvl(sum(decode(ps.class,
        'CM' , 1, 0)),0),
        /* 18-MAY-2000 J Rautiainen BR Implementation */
        nvl(sum(decode(ps.class,
        'BR' , 1, 0)),0)
into      p_sum_inv_ori_amt,
          p_sum_dm_ori_amt,
          p_sum_cb_ori_amt,
          p_sum_dep_ori_amt,
          p_sum_guar_ori_amt,
          p_sum_cm_ori_amt,
          /* 18-MAY-2000 J Rautiainen BR Implementation */
          p_sum_br_ori_amt,
          p_sum_inv_rem_amt,
          p_sum_dm_rem_amt,
          p_sum_cb_rem_amt,
          p_sum_dep_rem_amt,
          p_sum_guar_rem_amt,
          p_sum_cm_rem_amt,
          /* 18-MAY-2000 J Rautiainen BR Implementation */
          p_sum_br_rem_amt,
          p_sum_inv_func_ori_amt,
          p_sum_dm_func_ori_amt,
          p_sum_cb_func_ori_amt,
          p_sum_dep_func_ori_amt,
          p_sum_guar_func_ori_amt,
          p_sum_cm_func_ori_amt,
          /* 18-MAY-2000 J Rautiainen BR Implementation */
          p_sum_br_func_ori_amt,
          p_sum_inv_func_rem_amt,
          p_sum_dm_func_rem_amt,
          p_sum_cb_func_rem_amt,
          p_sum_dep_func_rem_amt,
          p_sum_guar_func_rem_amt,
          p_sum_cm_func_rem_amt,
          /* 18-MAY-2000 J Rautiainen BR Implementation */
          p_sum_br_func_rem_amt,
          p_inv_count,
          p_dm_count,
          p_cb_count,
          p_dep_count,
          p_guar_count,
          p_cm_count,
          /* 18-MAY-2000 J Rautiainen BR Implementation */
          p_br_count
 from     ar_payment_schedules ps
 where    ps.customer_id                           = p_customer_id /* bug1963032 */
 and      nvl(ps.customer_site_use_id, -10)        = nvl(p_site_use_id, nvl(ps.customer_site_use_id, -10) )
 and      ps.gl_date                         between p_start_date and p_end_date
 and      ps.invoice_currency_code                 = nvl(p_currency_code,ps.invoice_currency_code)
 and      nvl(ps.receipt_confirmed_flag,'Y')       = 'Y'
 and      ps.cash_receipt_id                       is NULL
 and      ps.status                                = nvl(p_status, ps.status);
/*===================================================================================+
 | The above procedure is now split into two. The top SQL would fetch totals and     |
 | counts for transactions of type "INV", "GUAR", "CM", "DEP", "DM" and "CB". The    |
 | SQL below would fetch total and counts for transaction type of "PMT" and would    |
 | reject a "PMT" if it is REVERSED. Required as a Bug Fix : 486920                  |
 |                                                                                   |
 +===================================================================================*/

   select decode(p_currency_code,
                 NULL , NULL ,
                 nvl(sum(decode(ps.class, 'PMT' , ps.amount_due_original, 0)),0)
                ),                    /* Sum of Original Amount */
          decode(p_currency_code,
                 NULL , NULL ,
                 nvl(sum(decode(ps.class, 'PMT' , ps.amount_due_remaining, 0)),0)
                ),                    /* Sum of Amount Due Remaining */
          nvl(sum(decode(ps.class,
                         'PMT', arpcurr.functional_amount( ps.amount_due_original,
                                                            p_func_curr,
                                                            nvl(p_exc_rate, ps.exchange_rate),
                                                            p_precision,
                                                            p_min_acc_unit
                                                          ),
                         0)), 0),      /* Sum of Functional Original Amount */
          nvl(sum(decode(ps.class,
                         'PMT', decode(p_exc_rate,
                                       NULL, ps.acctd_amount_due_remaining,
                                       arpcurr.functional_amount( ps.amount_due_remaining,
                                                                  p_func_curr,
                                                                  p_exc_rate,
                                                                  p_precision,
                                                                  p_min_acc_unit
                                                                 )
                                      ), 0)
                  ), 0),                /* Sum of Functional Amount Due Remaining */
          nvl(sum(decode(ps.class,
                         'PMT' , 1, 0
                        )
                  ),0),                  /* Count of Receipts */
	  NULL,
	  NULL,
          0,
          0,
	  0
   into   p_sum_pmt_ori_amt,
	  p_sum_pmt_rem_amt,
	  p_sum_pmt_func_ori_amt,
          p_sum_pmt_func_rem_amt,
          p_pmt_count,
	  p_sum_risk_ori_amt,
	  p_sum_risk_rem_amt,
	  p_sum_risk_func_ori_amt,
	  p_sum_risk_func_rem_amt,
	  p_risk_count
   from	  ar_cash_receipts     cr,
	  ar_payment_schedules ps
   where  ps.customer_id                             = p_customer_id /* Bug 1963032 */
   and    ps.cash_receipt_id                         = cr.cash_receipt_id
   and    nvl(ps.customer_site_use_id, -10)          = nvl(p_site_use_id, nvl(ps.customer_site_use_id, -10) )
   and    ps.gl_date                           between p_start_date and p_end_date
   and    ps.invoice_currency_code                   = nvl(p_currency_code,ps.invoice_currency_code)
   and    (nvl(cr.reversal_category, cr.status||'X')  <> cr.status OR
           (nvl(cr.reversal_category, cr.status||'X') = cr.status AND
            'Y'                                       = (SELECT 'Y'
                                                           FROM ar_payment_schedules     PS_DM,
                                                                ra_cust_trx_types        CTT_DM,
                                                                ra_customer_trx          CT_DM,
                                                                ra_cust_trx_line_gl_dist DM_GLD
                                                          WHERE PS_DM.reversed_cash_receipt_id = cr.cash_receipt_id
                                                            AND PS_DM.class = 'DM'
                                                            AND PS_DM.cust_trx_type_id = CTT_DM.cust_trx_type_id
                                                            AND PS_DM.customer_trx_id  = CT_DM.customer_trx_id
                                                            AND DM_GLD.customer_trx_id = PS_DM.customer_trx_id
                                                            AND DM_GLD.account_class   = 'REC'
                                                            AND DM_GLD.latest_rec_flag = 'Y')))
   and    nvl(ps.receipt_confirmed_flag,'Y')         = 'Y'
   and    ps.status                                  = nvl(p_status, ps.status);

 /* If include receipts at risk special menu is Y, find out NOCOPY amounts
    for receipts at risk */
 IF p_incl_rct_spmenu = 'Y' THEN
      select decode(p_currency_code,
                 NULL , NULL ,
                 nvl(sum(decode(ps.class, 'PMT' , ps.amount_due_original, 0)),0)
                ),                    /* Sum of Original Amount */
          decode(p_currency_code,
                 NULL , NULL ,
                 nvl(sum(decode(ps.class, 'PMT' , ps.amount_due_remaining, 0)),0)
                ),                    /* Sum of Amount Due Remaining */
          nvl(sum(decode(ps.class,
                         'PMT', arpcurr.functional_amount( ps.amount_due_original,
                                                            p_func_curr,
                                                            nvl(p_exc_rate, ps.exchange_rate),
                                                            p_precision,
                                                            p_min_acc_unit
                                                          ),
                         0)), 0),      /* Sum of Functional Original Amount */
          nvl(sum(decode(ps.class,
                         'PMT', decode(p_exc_rate,
                                       NULL, ps.acctd_amount_due_remaining,
                                       arpcurr.functional_amount( ps.amount_due_remaining,
                                                                  p_func_curr,
                                                                  p_exc_rate,
                                                                  p_precision,
                                                                  p_min_acc_unit
                                                                 )
                                      ), 0)
                  ), 0),                /* Sum of Functional Amount Due Remaining */
          nvl(sum(decode(ps.class,
                         'PMT' , 1, 0
                        )
                  ),0)                  /* Count of Receipts */
   into   p_sum_risk_ori_amt,
          p_sum_risk_rem_amt,
          p_sum_risk_func_ori_amt,
          p_sum_risk_func_rem_amt,
          p_risk_count
   from   ar_cash_receipts     cr,
          ar_payment_schedules ps,
	  ar_cash_receipt_history crh
   where  ps.customer_id                             = p_customer_id /* Bug 1963032 */
   and    ps.cash_receipt_id                         = cr.cash_receipt_id
   and    nvl(ps.customer_site_use_id, -10)          = nvl(p_site_use_id, nvl(ps.customer_site_use_id, -10) )
   and    ps.gl_date                           between p_start_date and p_end_date
   and    ps.invoice_currency_code                   = nvl(p_currency_code,ps.invoice_currency_code)
   and    nvl(cr.reversal_category, cr.status||'X') <> cr.status
   and    nvl(ps.receipt_confirmed_flag,'Y')         = 'Y'
   and    ps.status                                  = nvl(p_status, ps.status)
   and 	  cr.cash_receipt_id 			     = crh.cash_receipt_id
   and	  crh.current_record_flag||''		     = 'Y'
   and    crh.status not in (decode (crh.factor_flag,
                                      'Y', 'RISK_ELIMINATED',
                                      'N', 'CLEARED'), 'REVERSED')
   /* 06-AUG-2000 J Rautiainen BR Implementation
    * Short term debt applications are not considered as receipts at risk */
   and    not exists (select 'X'
                      from ar_receivable_applications rap
                      where rap.cash_receipt_id = cr.cash_receipt_id
                      and   rap.applied_payment_schedule_id = -2
                      and   rap.display = 'Y');

 END IF;
-- arp_standard.enable_debug;
EXCEPTION
  WHEN OTHERS THEN
    arp_standard.debug( 'Exception:');

end;


procedure get_payments_ontime(
                              p_payments_late_count      IN OUT NOCOPY NUMBER,
                              p_payments_ontime_count    IN OUT NOCOPY NUMBER,
                              p_payments_late_amount     IN OUT NOCOPY NUMBER,
                              p_payments_ontime_amount   IN OUT NOCOPY NUMBER,
                              p_payments_late_func_amt   IN OUT NOCOPY NUMBER,
                              p_payments_ontime_func_amt IN OUT NOCOPY NUMBER,
                              p_start_date               IN gl_period_statuses.start_date%TYPE,
                              p_end_date                 IN gl_period_statuses.end_date%TYPE,
                              p_customer_id              IN hz_cust_accounts.cust_account_id%TYPE,
                              p_site_use_id              IN hz_cust_site_uses.site_use_id%TYPE,
                              p_currency_code            IN ar_payment_schedules.invoice_currency_code%TYPE,
                              p_func_curr                IN VARCHAR2,
                              p_exc_rate                 IN NUMBER,
                              p_precision                IN NUMBER,
                              p_min_acc_unit             IN NUMBER,
                              p_status                   IN ar_payment_schedules.status%TYPE
                             ) is
begin

select  nvl(sum(decode(sign(ra.apply_date - ps.due_date),1, 1,0)),0),
        nvl(sum(decode(sign(ra.apply_date - ps.due_date),1, 0,1)),0),
        decode(p_currency_code,
               NULL , NULL ,
               nvl(sum(decode(sign(ra.apply_date - ps.due_date),1, ra.amount_applied,0)),0)),
               decode(p_currency_code,
                      NULL , NULL ,
                      nvl(sum(decode(sign(ra.apply_date - ps.due_date),1, 0,ra.amount_applied)),0)),
        nvl(sum(decode(sign(ra.apply_date - ps.due_date),1, decode(p_exc_rate,
                       NULL, ra.acctd_amount_applied_from,
                       arpcurr.functional_amount(ra.amount_applied,
                                                 p_func_curr,
                                                 p_exc_rate,
                                                 p_precision,
                                                 p_min_acc_unit
                                                )),0
                      )),0),
        nvl(sum(decode(sign(ra.apply_date - ps.due_date),1, 0, decode(p_exc_rate,
                       NULL, ra.acctd_amount_applied_from,
                       arpcurr.functional_amount(ra.amount_applied,
                                                 p_func_curr,
                                                 p_exc_rate,
                                                 p_precision,
                                                 p_min_acc_unit
                                                ))
                      )),0)
into    p_payments_late_count,
        p_payments_ontime_count,
        p_payments_late_amount,
        p_payments_ontime_amount,
        p_payments_late_func_amt,
        p_payments_ontime_func_amt
from    ar_receivable_applications  ra,
	ar_payment_schedules        ps
where   ra.applied_payment_schedule_id     = ps.payment_schedule_id
and     ps.customer_id                     = p_customer_id /* bug1963032 */
and nvl(ps.customer_site_use_id, -10)      = nvl(p_site_use_id, nvl(ps.customer_site_use_id, -10) )
AND     ra.apply_date                between p_start_date and p_end_date
and     ra.status                          = 'APP'
and     ra.display                         = 'Y'
AND     ps.invoice_currency_code           = nvl(p_currency_code, ps.invoice_currency_code)
AND     nvl(ps.receipt_confirmed_flag,'Y') = 'Y'
AND     ps.status                          = nvl(p_status, ps.status);

--arp_standard.enable_debug;
EXCEPTION
        WHEN OTHERS THEN
             arp_standard.debug( 'Exception:');
end;


procedure get_nsf_stop(
                       p_nsf_stop_amount   IN OUT NOCOPY NUMBER,
                       p_nsf_stop_func_amt IN OUT NOCOPY NUMBER,
                       p_nsf_stop_count    IN OUT NOCOPY NUMBER,
                       p_start_date        IN gl_period_statuses.start_date%TYPE,
                       p_end_date          IN gl_period_statuses.end_date%TYPE,
                       p_customer_id       IN hz_cust_accounts.cust_account_id%TYPE,
                       p_site_use_id       IN hz_cust_site_uses.site_use_id%TYPE,
                       p_currency_code     IN ar_payment_schedules.invoice_currency_code%TYPE,
                       p_func_curr         IN VARCHAR2,
                       p_exc_rate          IN NUMBER,
                       p_precision         IN NUMBER,
                       p_min_acc_unit         NUMBER,
                       p_status            IN ar_payment_schedules.status%TYPE
                      ) is
begin
SELECT  decode(p_currency_code,
               NULL , NULL ,
               nvl(sum(cr.amount),0)
              ),
        nvl(sum(arpcurr.functional_amount( cr.amount,
                                           p_func_curr,
                                           nvl(p_exc_rate,ps.exchange_rate),
                                           p_precision,
                                           p_min_acc_unit
                                         )
               ),0),
        count(cr.amount)
INTO    p_nsf_stop_amount,
        p_nsf_stop_func_amt,
        p_nsf_stop_count
FROM    ar_cash_receipts     cr,
        ar_payment_schedules ps
WHERE   ps.gl_date                   between p_start_date and p_end_date
AND     ps.cash_receipt_id                 = cr.cash_receipt_id
AND     cr.reversal_category              in ('NSF','STOP')
AND     cr.pay_from_customer               = p_customer_id /* bug1963032 */
and nvl(cr.customer_site_use_id, -10)      = nvl(p_site_use_id, nvl(cr.customer_site_use_id, -10) )
AND     ps.invoice_currency_code           = nvl(p_currency_code, ps.invoice_currency_code)
AND     nvl(ps.receipt_confirmed_flag,'Y') = 'Y'
AND     ps.status                          = nvl(p_status, ps.status);

--arp_standard.enable_debug;
EXCEPTION
  WHEN OTHERS THEN
    arp_standard.debug( 'Exception:');
end;


procedure get_adjustments(
                          p_adjustment_amount   IN OUT NOCOPY NUMBER,
                          p_adjustment_func_amt IN OUT NOCOPY NUMBER,
                          p_adjustment_count    IN OUT NOCOPY NUMBER,
                          p_start_date          IN gl_period_statuses.start_date%TYPE,
                          p_end_date            IN gl_period_statuses.end_date%TYPE,
                          p_customer_id         IN hz_cust_accounts.cust_account_id%TYPE,
                          p_site_use_id         IN hz_cust_site_uses.site_use_id%TYPE,
                          p_currency_code       IN ar_payment_schedules.invoice_currency_code%TYPE,
                          p_func_curr           IN VARCHAR2,
                          p_exc_rate            IN NUMBER,
                          p_precision           IN NUMBER,
                          p_min_acc_unit        IN  NUMBER,
                          p_status              IN ar_payment_schedules.status%TYPE
                         ) is
begin
select  decode(p_currency_code,
               NULL , NULL , nvl(sum(a.amount),0)
              ),
        nvl(sum( decode(p_exc_rate,
                        NULL, a.acctd_amount,
                        arpcurr.functional_amount(a.amount,
                                                  p_func_curr,
                                                  p_exc_rate,
                                                  p_precision,
                                                  p_min_acc_unit
                                                 )
                       )),0),
        count(a.amount)
into    p_adjustment_amount,
        p_adjustment_func_amt,
        p_adjustment_count
from    ar_adjustments           a,
        ar_receivables_trx       rt,
        ar_payment_schedules     ps
where   a.gl_date                    between p_start_date and p_end_date
and     nvl(a.postable,'Y')                = 'Y'
and     a.payment_schedule_id              = ps.payment_schedule_id
and     ps.customer_id                     = p_customer_id /*  bug1963032 */
and nvl(ps.customer_site_use_id, -10)      = nvl(p_site_use_id, nvl(ps.customer_site_use_id, -10) )
and     a.receivables_trx_id               = rt.receivables_trx_id
and     nvl(rt.type,'X')                  <> 'FINCHRG'
AND     ps.invoice_currency_code           = nvl(p_currency_code, ps.invoice_currency_code)
AND     nvl(ps.receipt_confirmed_flag,'Y') = 'Y'
AND     ps.status                          = nvl(p_status, ps.status);

--arp_standard.enable_debug;
EXCEPTION
  WHEN OTHERS THEN
    arp_standard.debug( 'Exception:');
end;



procedure get_financecharg(
                           p_financecharg_amount   IN OUT NOCOPY NUMBER,
                           p_financecharg_func_amt IN OUT NOCOPY NUMBER,
                           p_financecharg_count    IN OUT NOCOPY NUMBER,
                           p_start_date            IN gl_period_statuses.start_date%TYPE,
                           p_end_date              IN gl_period_statuses.end_date%TYPE,
                           p_customer_id           IN hz_cust_accounts.cust_account_id%TYPE,
                           p_site_use_id           IN hz_cust_site_uses.site_use_id%TYPE,
                           p_currency_code         IN ar_payment_schedules.invoice_currency_code%TYPE,
                           p_func_curr             IN VARCHAR2,
                           p_exc_rate              IN NUMBER,
                           p_precision             IN NUMBER,
                           p_min_acc_unit          IN NUMBER,
                           p_status                IN ar_payment_schedules.status%TYPE
                          ) is
begin
select  decode(p_currency_code,
               NULL , NULL , nvl(sum(a.amount),0)
              ),
        nvl(sum( decode(p_exc_rate,
                        NULL, a.acctd_amount,
                        arpcurr.functional_amount(a.amount,
                                                  p_func_curr,
                                                  p_exc_rate,
                                                  p_precision,
                                                  p_min_acc_unit
                                                 )
                       )),0),
        count(a.amount)
into    p_financecharg_amount,
        p_financecharg_func_amt,
        p_financecharg_count
from    ar_adjustments          a,
        ar_receivables_trx      rt,
        ar_payment_schedules    ps
where   a.gl_date                between p_start_date and p_end_date
and nvl(a.postable,'Y')                = 'Y'
and     a.payment_schedule_id          = ps.payment_schedule_id
and     ps.customer_id                 = p_customer_id   /*  bug1963032 */
and nvl(ps.customer_site_use_id, -10)  = nvl(p_site_use_id, nvl(ps.customer_site_use_id, -10) )
and     a.receivables_trx_id           = rt.receivables_trx_id
and nvl(rt.type,'X')                   = 'FINCHRG'
AND     ps.invoice_currency_code       = nvl(p_currency_code, ps.invoice_currency_code)
AND nvl(ps.receipt_confirmed_flag,'Y') = 'Y'
AND ps.status                          = nvl(p_status, ps.status);

--arp_standard.enable_debug;
EXCEPTION
  WHEN OTHERS THEN
    arp_standard.debug( 'Exception:');
end;


procedure get_discounts(
                        p_earned_discounts    IN OUT NOCOPY NUMBER,
                        p_unearned_discounts  IN OUT NOCOPY NUMBER,
                        p_earned_func_disc    IN OUT NOCOPY NUMBER,
                        p_unearned_func_disc  IN OUT NOCOPY NUMBER,
                        p_earned_disc_count   IN OUT NOCOPY NUMBER,
                        p_unearned_disc_count IN OUT NOCOPY NUMBER,
                        p_start_date          IN gl_period_statuses.start_date%TYPE,
                        p_end_date            IN gl_period_statuses.end_date%TYPE,
                        p_customer_id         IN hz_cust_accounts.cust_account_id%TYPE,
                        p_site_use_id         IN hz_cust_site_uses.site_use_id%TYPE,
                        p_currency_code       IN ar_payment_schedules.invoice_currency_code%TYPE,
                        p_func_curr           IN VARCHAR2,
                        p_exc_rate            IN NUMBER,
                        p_precision           IN NUMBER,
                        p_min_acc_unit        IN  NUMBER,
                        p_status              IN ar_payment_schedules.status%TYPE
                       ) is
begin
SELECT  decode(p_currency_code,
               NULL , NULL ,
               nvl(sum(ra.earned_discount_taken),0)
              ),
        decode(p_currency_code,
               NULL , NULL ,
               nvl(sum(ra.unearned_discount_taken),0)
              ),
        nvl(sum( decode(p_exc_rate,
                        NULL, ra.acctd_earned_discount_taken,
                        arpcurr.functional_amount( nvl(ra.earned_discount_taken,0),
                                                       p_func_curr,
                                                       p_exc_rate, p_precision,
                                                       p_min_acc_unit
                                                  )
                       )
               ),0),
        nvl(sum( decode(p_exc_rate,
                        NULL, ra.acctd_unearned_discount_taken,
                        arpcurr.functional_amount( nvl(ra.unearned_discount_taken,0),
                                                       p_func_curr,
                                                       p_exc_rate,
                                                       p_precision,
                                                       p_min_acc_unit
                                                  )
                       )),0),
        count(decode(ra.earned_discount_taken,
                     0, NULL,
                     ra.earned_discount_taken
                    )
             ),
        count(decode(ra.unearned_discount_taken,
                     0, NULL,
                     ra.unearned_discount_taken
                    )
             )
INTO    p_earned_discounts,
        p_unearned_discounts,
        p_earned_func_disc,
        p_unearned_func_disc,
        p_earned_disc_count,
        p_unearned_disc_count
FROM    ar_receivable_applications  ra,
	ar_payment_schedules        ps
where   ra.gl_date                   between p_start_date and p_end_date
and     ps.payment_schedule_id             = ra.applied_payment_schedule_id
and     ps.customer_id                     = p_customer_id     /*  bug1963032 */
and     nvl(ps.customer_site_use_id, -10)  = nvl(p_site_use_id, nvl(ps.customer_site_use_id, -10) )
and     ps.invoice_currency_code           = nvl(p_currency_code, ps.invoice_currency_code)
and     nvl(ps.receipt_confirmed_flag,'Y') = 'Y'
and     ps.status                          = nvl(p_status, ps.status);

--arp_standard.enable_debug;
EXCEPTION
  WHEN OTHERS THEN
    arp_standard.debug( 'Exception:');
end;


/* BOE: get information about receipts that are waiting to be confirmed */
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
			) is
begin
 select   decode(p_currency_code,
               NULL , NULL ,
               nvl(sum(cr.amount),0)
              ),
          nvl(sum(arpcurr.functional_amount( cr.amount,
                                           p_func_curr,
                                           nvl(p_exc_rate,ps.exchange_rate),
                                           p_precision,
                                           p_min_acc_unit
                                         )
               ),0),
          count(cr.amount)
 into	  p_pend_confirm_amt,
	  p_pend_confirm_func_amt,
	  p_pend_confirm_count
 from     ar_payment_schedules ps,
	  ar_cash_receipts     cr,
	  ar_cash_receipt_history crh
 where    ps.customer_id                           = p_customer_id  /*  bug1963032 */
 and      ps.cash_receipt_id                       = cr.cash_receipt_id
 and      nvl(ps.customer_site_use_id, -10)        = nvl(p_site_use_id, nvl(ps.customer_site_use_id,
-10) )
 and      ps.gl_date                         between p_start_date and p_end_date
 and      ps.invoice_currency_code                 = nvl(p_currency_code,ps.invoice_currency_code)
 and      ps.status                                = nvl(p_status, ps.status)
 and      cr.cash_receipt_id                         = crh.cash_receipt_id
 and      crh.current_record_flag||''              = 'Y'
 and 	  crh.status				   = 'APPROVED';

EXCEPTION
  WHEN OTHERS THEN
    arp_standard.debug( 'Exception:');
end;


/* BOE: get information about receipts that are waiting to be remitted,
   separate receipts into BOE, notes receivable and others */
procedure get_pending_remit(
			p_boe_ori_amt 		IN OUT NOCOPY NUMBER,
			p_boe_func_ori_amt 	IN OUT NOCOPY NUMBER,
                        p_boe_rem_amt 		IN OUT NOCOPY NUMBER,
                        p_boe_func_rem_amt 	IN OUT NOCOPY NUMBER,
			p_boe_count 		IN OUT NOCOPY NUMBER,
			p_note_ori_amt 		IN OUT NOCOPY NUMBER,
			p_note_func_ori_amt 	IN OUT NOCOPY NUMBER,
                        p_note_rem_amt 		IN OUT NOCOPY NUMBER,
                        p_note_func_rem_amt 	IN OUT NOCOPY NUMBER,
			p_note_count 		IN OUT NOCOPY NUMBER,
			p_other_ori_amt 	IN OUT NOCOPY NUMBER,
			p_other_func_ori_amt 	IN OUT NOCOPY NUMBER,
                        p_other_rem_amt 	IN OUT NOCOPY NUMBER,
                        p_other_func_rem_amt 	IN OUT NOCOPY NUMBER,
			p_other_count 		IN OUT NOCOPY NUMBER,
			p_start_date 		IN gl_period_statuses.start_date%TYPE,
			p_end_date 		IN gl_period_statuses.end_date%TYPE,
			p_customer_id 		IN hz_cust_accounts.cust_account_id%TYPE,
			p_site_use_id 		IN hz_cust_site_uses.site_use_id%TYPE,
			p_currency_code 	IN ar_payment_schedules.invoice_currency_code%TYPE,
			p_func_curr 		IN VARCHAR2,
			p_exc_rate 		IN NUMBER,
			p_precision 		IN NUMBER,
			p_min_acc_unit 		IN  NUMBER,
			p_status 		IN ar_payment_schedules.status%TYPE,
			p_incl_rct_spmenu       IN VARCHAR2
			) is
l_ori_amount	number;
l_func_ori_amt	number;
l_rem_amount    number;
l_func_rem_amt  number;
l_count		number;
l_counter	number := 0;
l_type		varchar2(8);
begin
  IF p_incl_rct_spmenu = 'Y' THEN /* Calculate different pending remittance amounts
    				     only if include receipts at risk special menu
				     is checked. */
   WHILE l_counter < 3 LOOP
    IF l_counter = 0 THEN
      l_type := 'BOE';
    ELSIF l_counter = 1 THEN
      l_type := 'NOTES';
    ELSE
      l_type := 'OTHER';
    END IF;

    select decode(p_currency_code,
                  NULL , NULL ,
                  nvl(sum(decode(ps.class, 'PMT' , ps.amount_due_original, 0)),0)
                 ),                    /* Sum of Original Amount */
           decode(p_currency_code,
                  NULL , NULL ,
                  nvl(sum(decode(ps.class, 'PMT' , ps.amount_due_remaining, 0)),0)
                 ),                    /* Sum of Amount Due Remaining */
           nvl(sum(decode(ps.class,
                          'PMT', arpcurr.functional_amount( ps.amount_due_original,
                                                            p_func_curr,
                                                            nvl(p_exc_rate, ps.exchange_rate),
                                                            p_precision,
                                                            p_min_acc_unit
                                                           ),
                         0)), 0),      /* Sum of Functional Original Amount */
           nvl(sum(decode(ps.class,
                          'PMT', decode(p_exc_rate,
                                        NULL, ps.acctd_amount_due_remaining,
                                        arpcurr.functional_amount( ps.amount_due_remaining,
                                                                   p_func_curr,
                                                                   p_exc_rate,
                                                                   p_precision,
                                                                   p_min_acc_unit
                                                                  )
                                       ), 0)
                   ), 0),                /* Sum of Functional Amount Due Remaining */
           nvl(sum(decode(ps.class,
                          'PMT' , 1, 0
                         )
                   ),0)                  /* Count of Receipts */
    into   l_ori_amount,
	   l_rem_amount,
	   l_func_ori_amt,
	   l_func_rem_amt,
	   l_count
    from   ar_cash_receipts     cr,
           ar_payment_schedules ps,
           ar_cash_receipt_history crh,
	   ar_receipt_methods   rm,
	   ar_receipt_classes   rc
    where  ps.customer_id                             = p_customer_id   /*  bug1963032 */
    and    ps.cash_receipt_id                         = cr.cash_receipt_id
    and    nvl(ps.customer_site_use_id, -10)          = nvl(p_site_use_id, nvl(ps.customer_site_use_id, -10) )
    and    ps.gl_date                           between p_start_date and p_end_date
    and    ps.invoice_currency_code                   = nvl(p_currency_code,ps.invoice_currency_code)
    and    nvl(cr.reversal_category, cr.status||'X') <> cr.status
    and    nvl(ps.receipt_confirmed_flag,'Y')         = 'Y'
    and    ps.status                                  = nvl(p_status, ps.status)
    and    cr.cash_receipt_id                         = crh.cash_receipt_id
    and    crh.current_record_flag||''                = 'Y'
    and    crh.status 				     = 'CONFIRMED'
    and 	  cr.receipt_method_id			     = rm.receipt_method_id
    and	  rm.receipt_class_id			     = rc.receipt_class_id
    and    nvl(rc.bill_of_exchange_flag, 'N')	     = decode(l_type, 'BOE', 'Y', 'N')
    and    nvl(rc.notes_receivable, 'N')		     = decode(l_type, 'NOTES', 'Y', 'N');

    IF l_type = 'BOE' THEN
	p_boe_ori_amt := l_ori_amount * -1;
        p_boe_rem_amt := l_rem_amount * -1;
        p_boe_func_ori_amt := l_func_ori_amt * -1;
        p_boe_func_rem_amt := l_func_rem_amt * -1;
        p_boe_count := l_count;
    ELSIF l_type = 'NOTES' THEN
        p_note_ori_amt := l_ori_amount * -1;
        p_note_rem_amt := l_rem_amount * -1;
        p_note_func_ori_amt := l_func_ori_amt * -1;
        p_note_func_rem_amt := l_func_rem_amt * -1;
        p_note_count := l_count;
    ELSE
        p_other_ori_amt := l_ori_amount * -1;
        p_other_rem_amt := l_rem_amount * -1;
        p_other_func_ori_amt := l_func_ori_amt * -1;
        p_other_func_rem_amt := l_func_rem_amt * -1;
        p_other_count := l_count;
    END IF;

    l_counter := l_counter + 1;
   END LOOP;
  ELSE
	p_boe_ori_amt		:= NULL;
	p_boe_rem_amt		:= NULL;
	p_boe_func_ori_amt	:= 0;
	p_boe_func_rem_amt	:= 0;
	p_boe_count		:= 0;
	p_note_ori_amt		:= NULL;
	p_note_rem_amt		:= NULL;
	p_note_func_ori_amt	:= 0;
	p_note_func_rem_amt	:= 0;
	p_note_count		:= 0;
	p_other_ori_amt		:= NULL;
	p_other_rem_amt		:= NULL;
	p_other_func_ori_amt	:= 0;
	p_other_func_rem_amt	:= 0;
	p_other_count		:= 0;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    arp_standard.debug( 'Exception:');
end;


/* BOE: get information about remitted receipts that are not cleared */
procedure get_remitted(
			p_standard_ori_amt	IN OUT NOCOPY NUMBER,
			p_standard_func_ori_amt IN OUT NOCOPY NUMBER,
			p_standard_rem_amt	IN OUT NOCOPY NUMBER,
			p_standard_func_rem_amt	IN OUT NOCOPY NUMBER,
			p_standard_count	IN OUT NOCOPY NUMBER,
			p_factored_ori_amt	IN OUT NOCOPY NUMBER,
                        p_factored_func_ori_amt	IN OUT NOCOPY NUMBER,
                        p_factored_rem_amt	IN OUT NOCOPY NUMBER,
                        p_factored_func_rem_amt	IN OUT NOCOPY NUMBER,
			p_factored_count	IN OUT NOCOPY NUMBER,
                        p_start_date            IN gl_period_statuses.start_date%TYPE,
                        p_end_date              IN gl_period_statuses.end_date%TYPE,
                        p_customer_id           IN hz_cust_accounts.cust_account_id%TYPE,
                        p_site_use_id           IN hz_cust_site_uses.site_use_id%TYPE,
                        p_currency_code         IN ar_payment_schedules.invoice_currency_code%TYPE,
                        p_func_curr             IN VARCHAR2,
                        p_exc_rate              IN NUMBER,
                        p_precision             IN NUMBER,
                        p_min_acc_unit          IN  NUMBER,
                        p_status                IN ar_payment_schedules.status%TYPE,
                        p_incl_rct_spmenu       IN VARCHAR2
) is
l_ori_amount    number;
l_func_ori_amt  number;
l_rem_amount    number;
l_func_rem_amt  number;
l_count         number;
l_counter       number := 0;
l_type          varchar2(10);
begin
 IF p_incl_rct_spmenu = 'Y' THEN /* Calculate different pending remittance amounts
                                    only if include receipts at risk special menu
                                    is checked. */
  WHILE l_counter < 2 LOOP
    IF l_counter = 0 THEN
      l_type := 'STANDARD';
    ELSIF l_counter = 1 THEN
      l_type := 'FACTORED';
    END IF;

    select decode(p_currency_code,
                  NULL , NULL ,
                  nvl(sum(decode(ps.class, 'PMT' , ps.amount_due_original, 0)),0)
                 ),                    /* Sum of Original Amount */
           decode(p_currency_code,
                  NULL , NULL ,
                  nvl(sum(decode(ps.class, 'PMT' , ps.amount_due_remaining, 0)),0)
                 ),                    /* Sum of Amount Due Remaining */
           nvl(sum(decode(ps.class,
                          'PMT', arpcurr.functional_amount( ps.amount_due_original,
                                                            p_func_curr,
                                                            nvl(p_exc_rate, ps.exchange_rate),
                                                            p_precision,
                                                            p_min_acc_unit
                                                           ),
                          0)), 0),      /* Sum of Functional Original Amount */
           nvl(sum(decode(ps.class,
                          'PMT', decode(p_exc_rate,
                                        NULL, ps.acctd_amount_due_remaining,
                                        arpcurr.functional_amount( ps.amount_due_remaining,
                                                                   p_func_curr,
                                                                   p_exc_rate,
                                                                   p_precision,
                                                                   p_min_acc_unit
                                                                  )
                                       ), 0)
                   ), 0),                /* Sum of Functional Amount Due Remaining */
           nvl(sum(decode(ps.class,
                          'PMT' , 1, 0
                         )
                   ),0)                  /* Count of Receipts */
    into   l_ori_amount,
           l_rem_amount,
           l_func_ori_amt,
           l_func_rem_amt,
           l_count
    from   ar_cash_receipts     cr,
           ar_payment_schedules ps,
           ar_cash_receipt_history crh
    where  ps.customer_id                             = p_customer_id /*  bug1963032 */
    and    ps.cash_receipt_id                         = cr.cash_receipt_id
    and    nvl(ps.customer_site_use_id, -10)          = nvl(p_site_use_id, nvl(ps.customer_site_use_id, -10) )
    and    ps.gl_date                           between p_start_date and p_end_date
    and    ps.invoice_currency_code                   = nvl(p_currency_code,ps.invoice_currency_code)
    and    nvl(cr.reversal_category, cr.status||'X') <> cr.status
    and    nvl(ps.receipt_confirmed_flag,'Y')         = 'Y'
    and    ps.status                                  = nvl(p_status, ps.status)
    and    cr.cash_receipt_id                         = crh.cash_receipt_id
    and    crh.current_record_flag||''                = 'Y'
    and    crh.status 				     = 'REMITTED'
    and    crh.factor_flag			     = decode(l_type, 'STANDARD',
							'N', 'Y');

    IF l_type = 'STANDARD' THEN
        p_standard_ori_amt := l_ori_amount * -1;
        p_standard_rem_amt := l_rem_amount * -1;
        p_standard_func_ori_amt := l_func_ori_amt * -1;
        p_standard_func_rem_amt := l_func_rem_amt * -1;
        p_standard_count := l_count;
    ELSE
        p_factored_ori_amt := l_ori_amount * -1;
        p_factored_rem_amt := l_rem_amount * -1;
        p_factored_func_ori_amt := l_func_ori_amt * -1;
        p_factored_func_rem_amt := l_func_rem_amt * -1;
        p_factored_count := l_count;
    END IF;

   l_counter := l_counter + 1;
   END LOOP;
  ELSE
	p_standard_ori_amt	:= NULL;
	p_standard_rem_amt	:= NULL;
	p_standard_func_ori_amt	:= 0;
	p_standard_func_rem_amt	:= 0;
	p_standard_count	:= 0;
	p_factored_ori_amt	:= NULL;
	p_factored_rem_amt	:= NULL;
	p_factored_func_ori_amt	:= 0;
	p_factored_func_rem_amt	:= 0;
	p_factored_count	:= 0;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    arp_standard.debug( 'Exception:');
end;


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
                           p_status                         IN ar_payment_schedules.status%TYPE) IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_ARXVASUM.get_protested_BR()+ ');
  END IF;

  select  decode(p_currency_code,
                 NULL , NULL , nvl(sum(ps.amount_due_remaining),0)
                ),
          nvl(sum( decode(p_exc_rate,
                          NULL, ps.acctd_amount_due_remaining,
                          arpcurr.functional_amount(ps.amount_due_remaining,
                                                    p_func_curr,
                                                    p_exc_rate,
                                                    p_precision,
                                                    p_min_acc_unit
                                                   )
                         )),0),
          count(ps.amount_due_remaining)
  into    p_BR_protested_amt,
          p_BR_protested_func_amt,
          p_BR_protested_count
  from    ar_transaction_history   trh,
          ar_payment_schedules     ps
  where   trh.gl_date                        between p_start_date and p_end_date
  and     trh.status                         = 'PROTESTED'
  and     nvl(trh.current_record_flag,'Y')   = 'Y'
  and     ps.customer_trx_id                 = trh.customer_trx_id
  and     ps.customer_id                     = p_customer_id  /*  bug1963032 */
  and     nvl(ps.customer_site_use_id, -10)  = nvl(p_site_use_id, nvl(ps.customer_site_use_id, -10) )
  AND     ps.invoice_currency_code           = nvl(p_currency_code, ps.invoice_currency_code)
  AND     ps.status                          = nvl(p_status, ps.status);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_ARXVASUM.get_protested_BR()- ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'Exception: ARP_ARXVASUM.get_protested_BR ');
    END IF;
    RAISE;

END get_protested_BR;

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
                        p_status                         IN ar_payment_schedules.status%TYPE) IS
BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_ARXVASUM.get_unpaid_BR()+ ');
  END IF;

  select  decode(p_currency_code,
                 NULL , NULL , nvl(sum(ps.amount_due_remaining),0)
                ),
          nvl(sum( decode(p_exc_rate,
                          NULL, ps.acctd_amount_due_remaining,
                          arpcurr.functional_amount(ps.amount_due_remaining,
                                                    p_func_curr,
                                                    p_exc_rate,
                                                    p_precision,
                                                    p_min_acc_unit
                                                   )
                         )),0),
          count(ps.amount_due_remaining)
  into    p_BR_unpaid_amt,
          p_BR_unpaid_func_amt,
          p_BR_unpaid_count
  from    ar_transaction_history   trh,
          ar_payment_schedules     ps
  where   trh.gl_date                        between p_start_date and p_end_date
  and     trh.status                         = 'UNPAID'
  and     nvl(trh.current_record_flag,'Y')   = 'Y'
  and     ps.customer_trx_id                 = trh.customer_trx_id
  and     ps.customer_id                     = p_customer_id  /*  bug1963032 */
  and     nvl(ps.customer_site_use_id, -10)  = nvl(p_site_use_id, nvl(ps.customer_site_use_id, -10) )
  AND     ps.invoice_currency_code           = nvl(p_currency_code, ps.invoice_currency_code)
  AND     ps.status                          = nvl(p_status, ps.status);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_ARXVASUM.get_unpaid_BR()- ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'Exception: ARP_ARXVASUM.get_unpaid_BR');
    END IF;
    RAISE;

END get_unpaid_BR;

procedure get_pend_acceptance_BR(p_BR_pend_acceptance_amt         IN OUT NOCOPY NUMBER,
                                 p_BR_pend_acceptance_func_amt    IN OUT NOCOPY NUMBER,
                                 p_BR_pend_acceptance_count       IN OUT NOCOPY NUMBER,
                                 p_start_date                     IN gl_period_statuses.start_date%TYPE,
                                 p_end_date                       IN gl_period_statuses.end_date%TYPE,
                                 p_customer_id                    IN hz_cust_accounts.cust_account_id%TYPE,
                                 p_site_use_id                    IN hz_cust_site_uses.site_use_id%TYPE,
                                 p_currency_code                  IN ar_payment_schedules.invoice_currency_code%TYPE,
                                 p_func_curr                      IN VARCHAR2,
                                 p_exc_rate                       IN NUMBER,
                                 p_precision                      IN NUMBER,
                                 p_min_acc_unit                   IN NUMBER) IS
BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_ARXVASUM.get_pend_acceptance_BR()+ ');
  END IF;

  select  decode(p_currency_code,
                 NULL , NULL , nvl(sum(ctl.extended_amount),0)
                ),
          nvl(sum( decode(p_exc_rate,
                          NULL, ctl.extended_acctd_amount,
                          arpcurr.functional_amount(ctl.extended_amount,
                                                    p_func_curr,
                                                    p_exc_rate,
                                                    p_precision,
                                                    p_min_acc_unit
                                                   )
                         )),0),
          count(distinct ctl.customer_trx_id)
  into    p_BR_pend_acceptance_amt,
          p_BR_pend_acceptance_func_amt,
          p_BR_pend_acceptance_count
  from    ar_transaction_history   trh,
          ra_customer_trx          ct,
          ra_customer_trx_lines    ctl
  where   trh.gl_date                        between p_start_date and p_end_date
  and     trh.status                         = 'PENDING_ACCEPTANCE'
  and     nvl(trh.current_record_flag,'Y')   = 'Y'
  and     ct.customer_trx_id                 = trh.customer_trx_id
  and     ct.drawee_id                       = p_customer_id  /*  bug1963032 */
  AND     ct.invoice_currency_code           = nvl(p_currency_code, ct.invoice_currency_code)
  and     nvl(ct.drawee_site_use_id, -10)    = nvl(p_site_use_id, nvl(ct.drawee_site_use_id, -10) )
  and     ctl.customer_trx_id                = ct.customer_trx_id;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_ARXVASUM.get_pend_acceptance_BR()- ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'Exception: ARP_ARXVASUM.get_pend_acceptance_BR ');
    END IF;
    RAISE;

END get_pend_acceptance_BR;

end;

/
