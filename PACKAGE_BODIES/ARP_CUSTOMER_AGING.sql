--------------------------------------------------------
--  DDL for Package Body ARP_CUSTOMER_AGING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CUSTOMER_AGING" AS
/* $Header: ARCWAGEB.pls 120.8 2006/08/17 14:14:56 naneja ship $ */

--
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE calc_aging_buckets (
        p_customer_id        	IN NUMBER,
        p_customer_site_use_id  IN NUMBER,
        p_as_of_date         	IN DATE,
        p_currency_code      	IN VARCHAR2,
        p_credit_option      	IN VARCHAR2,
        p_invoice_type_low   	IN VARCHAR2,
        p_invoice_type_high  	IN VARCHAR2,
        p_ps_max_id             IN NUMBER DEFAULT 0,
        p_app_max_id            IN NUMBER DEFAULT 0,
        p_bucket_name		IN VARCHAR2,
	p_outstanding_balance	IN OUT NOCOPY NUMBER,
        p_bucket_titletop_0	OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_0	OUT NOCOPY VARCHAR2,
        p_bucket_amount_0       IN OUT NOCOPY NUMBER,
        p_bucket_titletop_1	OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_1	OUT NOCOPY VARCHAR2,
        p_bucket_amount_1       IN OUT NOCOPY NUMBER,
        p_bucket_titletop_2	OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_2	OUT NOCOPY VARCHAR2,
        p_bucket_amount_2       IN OUT NOCOPY NUMBER,
        p_bucket_titletop_3	OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_3	OUT NOCOPY VARCHAR2,
        p_bucket_amount_3       IN OUT NOCOPY NUMBER,
        p_bucket_titletop_4	OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_4	OUT NOCOPY VARCHAR2,
        p_bucket_amount_4       IN OUT NOCOPY NUMBER,
        p_bucket_titletop_5	OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_5	OUT NOCOPY VARCHAR2,
        p_bucket_amount_5       IN OUT NOCOPY NUMBER,
        p_bucket_titletop_6	OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_6	OUT NOCOPY VARCHAR2,
        p_bucket_amount_6       IN OUT NOCOPY NUMBER
) IS
   v_amount_due_remaining NUMBER;
   v_bucket_0 NUMBER;
   v_bucket_1 NUMBER;
   v_bucket_2 NUMBER;
   v_bucket_3 NUMBER;
   v_bucket_4 NUMBER;
   v_bucket_5 NUMBER;
   v_bucket_6 NUMBER;
   v_bucket_category    ar_aging_bucket_lines.type%TYPE;
--
   v_bucket_line_type_0 ar_aging_bucket_lines.type%TYPE;
   v_bucket_days_from_0 NUMBER;
   v_bucket_days_to_0   NUMBER;
   v_bucket_line_type_1 ar_aging_bucket_lines.type%TYPE;
   v_bucket_days_from_1 NUMBER;
   v_bucket_days_to_1   NUMBER;
   v_bucket_line_type_2 ar_aging_bucket_lines.type%TYPE;
   v_bucket_days_from_2 NUMBER;
   v_bucket_days_to_2   NUMBER;
   v_bucket_line_type_3 ar_aging_bucket_lines.type%TYPE;
   v_bucket_days_from_3 NUMBER;
   v_bucket_days_to_3   NUMBER;
   v_bucket_line_type_4 ar_aging_bucket_lines.type%TYPE;
   v_bucket_days_from_4 NUMBER;
   v_bucket_days_to_4   NUMBER;
   v_bucket_line_type_5 ar_aging_bucket_lines.type%TYPE;
   v_bucket_days_from_5 NUMBER;
   v_bucket_days_to_5   NUMBER;
   v_bucket_line_type_6 ar_aging_bucket_lines.type%TYPE;
   v_bucket_days_from_6 NUMBER;
   v_bucket_days_to_6   NUMBER;
--
   CURSOR c_sel_bucket_data is
        select lines.days_start,
               lines.days_to,
               lines.report_heading1,
               lines.report_heading2,
               lines.type
        from   ar_aging_bucket_lines    lines,
               ar_aging_buckets         buckets
        where  lines.aging_bucket_id      = buckets.aging_bucket_id
        and    upper(buckets.bucket_name) = upper(p_bucket_name)
        and nvl(buckets.status,'A')       = 'A'
        order  by lines.bucket_sequence_num
        ;
--
/* bug4047166 : The cursosr c_buckets is now 5 different cursors and
  one of them will get executed depending upon the site and trx type
  parameter values.  The cursor c_buckets_1 will be used as default one
 This is done to improve performance */

   CURSOR c_buckets_1 IS
  select decode(p_currency_code, NULL, ps.acctd_amount_due_remaining,
                ps.amount_due_remaining),
         decode(v_bucket_line_type_0,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_0,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_0,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b0,
	decode(v_bucket_line_type_1,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_1,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_1,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b1,
	decode(v_bucket_line_type_2,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_2,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_2,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b2,
	decode(v_bucket_line_type_3,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_3,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_3,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b3,
	decode(v_bucket_line_type_4,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_4,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_4,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b4,
	decode(v_bucket_line_type_5,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_5,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_5,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b5,
	decode(v_bucket_line_type_6,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_6,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_6,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b6
  from   ra_cust_trx_types,
         ar_payment_schedules        ps
  where  ps.gl_date                           <= p_as_of_date
  and    ps.cust_trx_type_id                   = ra_cust_trx_types.cust_trx_type_id
  and    ps.gl_date_closed                     > p_as_of_date
  and    ps.customer_id                        = p_customer_id
  and    decode(p_customer_site_use_id,
                NULL, ps.customer_site_use_id,
                p_customer_site_use_id)        = ps.customer_site_use_id
  and    decode(upper(p_currency_code),
                NULL, ps.invoice_currency_code,
                upper(p_currency_code))        = ps.invoice_currency_code
  and    decode(upper(p_credit_option),
                'AGE', 'dummy','SUMMARY','dummy',
                'CM')                         <> ps.class
  and    decode(upper(p_credit_option),
                'AGE', 'dummy','SUMMARY','dummy',
                'PMT')                        <> ps.class
  and    decode(p_invoice_type_low,
                NULL, ra_cust_trx_types.name,
                p_invoice_type_low)           <= ra_cust_trx_types.name
  and    decode(p_invoice_type_high,
                NULL, ra_cust_trx_types.name,
                p_invoice_type_high)          >= ra_cust_trx_types.name
UNION ALL
  select -sum(decode(p_currency_code, NULL, app.acctd_amount_applied_from,
                     app.amount_applied)),
	decode(v_bucket_line_type_0,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_0,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_0,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b0,
	decode(v_bucket_line_type_1,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_1,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_1,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1)))b1,
	decode(v_bucket_line_type_2,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_2,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_2,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b2,
	decode(v_bucket_line_type_3,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_3,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_3,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b3,
	decode(v_bucket_line_type_4,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_4,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_4,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b4,
	decode(v_bucket_line_type_5,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_5,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_5,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b5,
	decode(v_bucket_line_type_6,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_6,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_6,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b6
  from   ar_payment_schedules           ps,
	 ar_receivable_applications     app
 where   app.gl_date+0                        <= p_as_of_date
  and    ps.cash_receipt_id+0                  = app.cash_receipt_id
  and    app.status                           in ( 'ACC', 'UNAPP', 'UNID','OTHER ACC')
  and    nvl(app.confirmed_flag, 'Y')          = 'Y'
  and    ps.gl_date_closed                     > p_as_of_date
  and    (app.reversal_gl_date                 > p_as_of_date OR
          app.reversal_gl_date                is null )
  and    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y'
  and    ps.customer_id                        = p_customer_id
  and    decode(p_customer_site_use_id,
                NULL, nvl(ps.customer_site_use_id,-10),
                p_customer_site_use_id)        = nvl(ps.customer_site_use_id,-10)
  and    decode(upper(p_currency_code),
                NULL, ps.invoice_currency_code,
                upper(p_currency_code))        = ps.invoice_currency_code
  and    decode(p_credit_option,'AGE','AGE','dummy') = 'AGE' /*4436914*/
  and    decode(upper(p_credit_option),
                'AGE', 'dummy','SUMMARY','dummy',
                'CM')                         <> ps.class
  and    decode(upper(p_credit_option),
                'AGE', 'dummy','SUMMARY','dummy',
                'PMT')                        <> ps.class
group by ps.due_date,
         ps.amount_due_original,
         ps.amount_adjusted,
         ps.amount_applied,
         ps.amount_credited,
         ps.gl_date,
         ps.amount_in_dispute,
         ps.amount_adjusted_pending,
         ps.invoice_currency_code,
         ps.exchange_rate,
         ps.class,
         decode( app.status, 'UNID', 'UNID', 'UNAPP')
UNION ALL /*Bug 4436914 excluded APP and adjustments after as of date*/
  select nvl(sum(decode(p_currency_code, NULL, app.amount_applied,
                  app.acctd_amount_applied_from)),0) amount_due_remaining,
        decode(v_bucket_line_type_0,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_0,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_0,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b0,
        decode(v_bucket_line_type_1,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_1,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_1,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1)))b1,
        decode(v_bucket_line_type_2,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_2,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_2,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b2,
        decode(v_bucket_line_type_3,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_3,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_3,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b3,
        decode(v_bucket_line_type_4,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_4,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_4,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b4,
        decode(v_bucket_line_type_5,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_5,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_5,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b5,
        decode(v_bucket_line_type_6,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_6,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_6,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b6
  from   ar_payment_schedules           ps,
         ar_receivable_applications     app
 where   app.gl_date+0                        > p_as_of_date
  and    ps.cash_receipt_id                   = app.cash_receipt_id /*4436914*/
  and    (ps.payment_schedule_id                = app.applied_payment_schedule_id
         OR
         ps.payment_schedule_id                = app.payment_schedule_id)
  and    app.status                           in ( 'APP')
  and    nvl(app.confirmed_flag, 'Y')          = 'Y'
  and    ps.gl_date_closed                     > p_as_of_date
  and    (app.reversal_gl_date                 > p_as_of_date OR
          app.reversal_gl_date                is null )
  and    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y'
  and    ps.customer_id                        = p_customer_id
  and    decode(p_customer_site_use_id,
                NULL, nvl(ps.customer_site_use_id,-10),
                p_customer_site_use_id)        = nvl(ps.customer_site_use_id,-10)
  and    decode(upper(p_currency_code),
                NULL, ps.invoice_currency_code,
                upper(p_currency_code))        = ps.invoice_currency_code
  and    decode(upper(p_credit_option),
                'AGE', 'dummy','SUMMARY','dummy',
                'CM')                         <> ps.class
  and    decode(upper(p_credit_option),
                'AGE', 'dummy','SUMMARY','dummy',
                'PMT')                        <> ps.class
group by ps.due_date,
         ps.amount_due_original,
         ps.amount_adjusted,
         ps.amount_applied,
         ps.amount_credited,
         ps.gl_date,
         ps.amount_in_dispute,
         ps.amount_adjusted_pending,
         ps.invoice_currency_code,
         ps.exchange_rate,
         ps.class,
         ps.payment_schedule_id
UNION ALL
SELECT -sum(nvl(adj.amount,0)) amount_due_remaining,1,0,0,0,0,0,0
FROM   ar_adjustments adj,
       ar_payment_schedules_all ps
WHERE         adj.GL_date                           > p_as_of_date
       AND    ps.payment_schedule_id                = adj.payment_schedule_id
       AND    adj.status                            = 'A'
       AND    ps.gl_date_closed                     > p_as_of_date
       AND    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y'
       AND    ps.customer_id                        = p_customer_id
       AND    decode(p_customer_site_use_id,
                NULL, nvl(ps.customer_site_use_id,-10),
                p_customer_site_use_id)        = nvl(ps.customer_site_use_id,-10)
       AND    decode(upper(p_currency_code),NULL, ps.invoice_currency_code,upper(p_currency_code))= ps.invoice_currency_code
       AND    decode(upper(p_credit_option),'AGE', 'dummy','SUMMARY','dummy','CM')                         <> ps.class
       AND    decode(upper(p_credit_option),'AGE', 'dummy','SUMMARY','dummy','PMT')                        <> ps.class
group by ps.due_date,
         ps.amount_due_original,
         ps.amount_adjusted,
         ps.amount_applied,
         ps.amount_credited,
         ps.gl_date,
         ps.amount_in_dispute,
         ps.amount_adjusted_pending,
         ps.invoice_currency_code,
         ps.exchange_rate,
         ps.class;


/* bug4047166 : the cursor c_buckets_2 will be used as if site use id is not null
                and trx types are null */

   CURSOR c_buckets_2 IS
  select decode(p_currency_code, NULL, ps.acctd_amount_due_remaining,
                ps.amount_due_remaining),
         decode(v_bucket_line_type_0,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_0,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_0,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b0,
	decode(v_bucket_line_type_1,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_1,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_1,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b1,
	decode(v_bucket_line_type_2,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_2,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_2,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b2,
	decode(v_bucket_line_type_3,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_3,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_3,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b3,
	decode(v_bucket_line_type_4,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_4,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_4,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b4,
	decode(v_bucket_line_type_5,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_5,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_5,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b5,
	decode(v_bucket_line_type_6,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_6,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_6,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b6
  from  ar_payment_schedules        ps,
        ra_cust_trx_types           rctt
  where  ps.gl_date                           <= p_as_of_date
  and    ps.gl_date_closed                     > p_as_of_date
  and    ps.cust_trx_type_id                   = rctt.cust_trx_type_id
  and    ps.customer_id                        = p_customer_id
  and    ps.customer_site_use_id               = p_customer_site_use_id
  and    decode(upper(p_currency_code),
                NULL, ps.invoice_currency_code,
                upper(p_currency_code))        = ps.invoice_currency_code
  and    decode(upper(p_credit_option),
                'AGE', 'dummy','SUMMARY','dummy',
                'CM')                         <> ps.class
  and    decode(upper(p_credit_option),
                'AGE', 'dummy', 'SUMMARY','dummy',
                'PMT')                        <> ps.class
UNION ALL
  select -sum(decode(p_currency_code, NULL, app.acctd_amount_applied_from,
                     app.amount_applied)),
	decode(v_bucket_line_type_0,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_0,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_0,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b0,
	decode(v_bucket_line_type_1,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_1,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_1,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1)))b1,
	decode(v_bucket_line_type_2,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_2,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_2,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b2,
	decode(v_bucket_line_type_3,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_3,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_3,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b3,
	decode(v_bucket_line_type_4,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_4,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_4,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b4,
	decode(v_bucket_line_type_5,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_5,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_5,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b5,
	decode(v_bucket_line_type_6,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_6,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_6,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b6
  from   ar_payment_schedules           ps,
	 ar_receivable_applications     app
 where   app.gl_date+0                        <= p_as_of_date
  and    ps.cash_receipt_id+0                  = app.cash_receipt_id
  and    app.status                           in ( 'ACC', 'UNAPP', 'UNID','OTHER ACC')
  and    nvl(app.confirmed_flag, 'Y')          = 'Y'
  and    ps.gl_date_closed                     > p_as_of_date
  and    (app.reversal_gl_date                 > p_as_of_date OR
          app.reversal_gl_date                is null )
  and    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y'
  and    ps.customer_id                        = p_customer_id
  and    ps.customer_site_use_id               = p_customer_site_use_id
  and    decode(upper(p_currency_code),
                NULL, ps.invoice_currency_code,
                upper(p_currency_code))        = ps.invoice_currency_code
  and    decode(p_credit_option,'AGE','AGE','dummy') = 'AGE' /*4436914*/
  and    decode(upper(p_credit_option),
                'AGE', 'dummy','SUMMARY','dummy',
                'CM')                         <> ps.class
  and    decode(upper(p_credit_option),
                'AGE', 'dummy','SUMMARY','dummy',
                'PMT')                        <> ps.class
group by ps.due_date,
         ps.amount_due_original,
         ps.amount_adjusted,
         ps.amount_applied,
         ps.amount_credited,
         ps.gl_date,
         ps.amount_in_dispute,
         ps.amount_adjusted_pending,
         ps.invoice_currency_code,
         ps.exchange_rate,
         ps.class,
         decode( app.status, 'UNID', 'UNID', 'UNAPP')
UNION ALL /*Bug 4436914 excluded APP and adjustments after as of date*/
  select nvl(sum(decode(p_currency_code, NULL, app.amount_applied,
                  app.acctd_amount_applied_from)),0) amount_due_remaining,
        decode(v_bucket_line_type_0,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_0,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_0,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b0,
        decode(v_bucket_line_type_1,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_1,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_1,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1)))b1,
        decode(v_bucket_line_type_2,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_2,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_2,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b2,
        decode(v_bucket_line_type_3,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_3,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_3,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b3,
        decode(v_bucket_line_type_4,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_4,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_4,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b4,
        decode(v_bucket_line_type_5,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_5,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_5,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b5,
        decode(v_bucket_line_type_6,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_6,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_6,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b6
  from   ar_payment_schedules           ps,
         ar_receivable_applications     app
 where   app.gl_date+0                        > p_as_of_date
  and    ps.cash_receipt_id                   = app.cash_receipt_id  /*4436914*/
  and    (ps.payment_schedule_id                = app.applied_payment_schedule_id
         OR
         ps.payment_schedule_id                = app.payment_schedule_id)
  and    app.status                           in ( 'APP')
  and    nvl(app.confirmed_flag, 'Y')          = 'Y'
  and    ps.gl_date_closed                     > p_as_of_date
  and    (app.reversal_gl_date                 > p_as_of_date OR
          app.reversal_gl_date                is null )
  and    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y'
  and    ps.customer_id                        = p_customer_id
  and    ps.customer_site_use_id               = p_customer_site_use_id
  and    decode(upper(p_currency_code),
                NULL, ps.invoice_currency_code,
                upper(p_currency_code))        = ps.invoice_currency_code
  and    decode(upper(p_credit_option),
                'AGE', 'dummy','SUMMARY','dummy',
                'CM')                         <> ps.class
  and    decode(upper(p_credit_option),
                'AGE', 'dummy','SUMMARY','dummy',
                'PMT')                        <> ps.class
group by ps.due_date,
         ps.amount_due_original,
         ps.amount_adjusted,
         ps.amount_applied,
         ps.amount_credited,
         ps.gl_date,
         ps.amount_in_dispute,
         ps.amount_adjusted_pending,
         ps.invoice_currency_code,
         ps.exchange_rate,
         ps.class,
         ps.payment_schedule_id
UNION ALL
SELECT -sum(nvl(adj.amount,0)) amount_due_remaining,1,0,0,0,0,0,0
FROM   ar_adjustments adj,
       ar_payment_schedules_all ps
WHERE         adj.GL_date                           > p_as_of_date
       AND    ps.payment_schedule_id                = adj.payment_schedule_id
       AND    adj.status                            = 'A'
       AND    ps.gl_date_closed                     > p_as_of_date
       AND    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y'
       AND    ps.customer_id                        = p_customer_id
       AND    ps.customer_site_use_id               = p_customer_site_use_id
       AND    decode(upper(p_currency_code),NULL, ps.invoice_currency_code,upper(p_currency_code))= ps.invoice_currency_code
       AND    decode(upper(p_credit_option),'AGE', 'dummy','SUMMARY','dummy','CM')                         <> ps.class
       AND    decode(upper(p_credit_option),'AGE', 'dummy','SUMMARY','dummy','PMT')                        <> ps.class
group by ps.due_date,
         ps.amount_due_original,
         ps.amount_adjusted,
         ps.amount_applied,
         ps.amount_credited,
         ps.gl_date,
         ps.amount_in_dispute,
         ps.amount_adjusted_pending,
         ps.invoice_currency_code,
         ps.exchange_rate,
         ps.class;

/* bug4047166 : the cursor c_buckets_3 will be used as if site use id is not null
                and trx types are not null */

   CURSOR c_buckets_3 IS
  select decode(p_currency_code, NULL, ps.acctd_amount_due_remaining,
                ps.amount_due_remaining),
         decode(v_bucket_line_type_0,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_0,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_0,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b0,
	decode(v_bucket_line_type_1,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_1,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_1,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b1,
	decode(v_bucket_line_type_2,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_2,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_2,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b2,
	decode(v_bucket_line_type_3,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_3,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_3,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b3,
	decode(v_bucket_line_type_4,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_4,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_4,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b4,
	decode(v_bucket_line_type_5,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_5,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_5,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b5,
	decode(v_bucket_line_type_6,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_6,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_6,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b6
  from   ra_cust_trx_types,
         ar_payment_schedules        ps
  where  ps.gl_date                           <= p_as_of_date
  and    ps.cust_trx_type_id                   = ra_cust_trx_types.cust_trx_type_id
  and    ps.gl_date_closed                     > p_as_of_date
  and    ps.customer_id                        = p_customer_id
  and    ps.customer_site_use_id               = p_customer_site_use_id
  and    decode(upper(p_currency_code),
                NULL, ps.invoice_currency_code,
                upper(p_currency_code))        = ps.invoice_currency_code
  and    decode(upper(p_credit_option),
                'AGE', 'dummy', 'SUMMARY','dummy',
                'CM')                         <> ps.class
  and    decode(upper(p_credit_option),
                'AGE', 'dummy', 'SUMMARY','dummy',
                'PMT')                        <> ps.class
  and    decode(p_invoice_type_low,
                NULL, ra_cust_trx_types.name,
                p_invoice_type_low)           <= ra_cust_trx_types.name
  and    decode(p_invoice_type_high,
                NULL, ra_cust_trx_types.name,
                p_invoice_type_high)          >= ra_cust_trx_types.name
UNION ALL
  select -sum(decode(p_currency_code, NULL, app.acctd_amount_applied_from,
                     app.amount_applied)),
	decode(v_bucket_line_type_0,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_0,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_0,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b0,
	decode(v_bucket_line_type_1,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_1,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_1,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1)))b1,
	decode(v_bucket_line_type_2,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_2,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_2,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b2,
	decode(v_bucket_line_type_3,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_3,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_3,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b3,
	decode(v_bucket_line_type_4,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_4,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_4,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b4,
	decode(v_bucket_line_type_5,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_5,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_5,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b5,
	decode(v_bucket_line_type_6,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_6,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_6,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b6
  from   ar_payment_schedules           ps,
	 ar_receivable_applications     app
 where   app.gl_date+0                        <= p_as_of_date
  and    ps.cash_receipt_id+0                  = app.cash_receipt_id
  and    app.status                           in ( 'ACC', 'UNAPP', 'UNID','OTHER ACC')
  and    nvl(app.confirmed_flag, 'Y')          = 'Y'
  and    ps.gl_date_closed                     > p_as_of_date
  and    (app.reversal_gl_date                 > p_as_of_date OR
          app.reversal_gl_date                is null )
  and    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y'
  and    ps.customer_id                        = p_customer_id
  and    ps.customer_site_use_id               = p_customer_site_use_id
  and    decode(upper(p_currency_code),
                NULL, ps.invoice_currency_code,
                upper(p_currency_code))        = ps.invoice_currency_code
  and    decode(p_credit_option,'AGE','AGE','dummy') = 'AGE'  /*4436914*/
  and    decode(upper(p_credit_option),
                'AGE', 'dummy', 'SUMMARY','dummy',
                'CM')                         <> ps.class
  and    decode(upper(p_credit_option),
                'AGE', 'dummy', 'SUMMARY','dummy',
                'PMT')                        <> ps.class
group by ps.due_date,
         ps.amount_due_original,
         ps.amount_adjusted,
         ps.amount_applied,
         ps.amount_credited,
         ps.gl_date,
         ps.amount_in_dispute,
         ps.amount_adjusted_pending,
         ps.invoice_currency_code,
         ps.exchange_rate,
         ps.class,
         decode( app.status, 'UNID', 'UNID', 'UNAPP')
UNION ALL /*Bug 4436914 excluded APP and adjustments after as of date*/
  select nvl(sum(decode(p_currency_code, NULL, app.amount_applied,
                  app.acctd_amount_applied_from)),0) amount_due_remaining,
        decode(v_bucket_line_type_0,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_0,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_0,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b0,
        decode(v_bucket_line_type_1,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_1,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_1,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1)))b1,
        decode(v_bucket_line_type_2,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_2,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_2,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b2,
        decode(v_bucket_line_type_3,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_3,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_3,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b3,
        decode(v_bucket_line_type_4,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_4,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_4,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b4,
        decode(v_bucket_line_type_5,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_5,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_5,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b5,
        decode(v_bucket_line_type_6,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_6,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_6,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b6
  from   ar_payment_schedules           ps,
         ar_receivable_applications     app
 where   app.gl_date+0                        > p_as_of_date
  and    ps.cash_receipt_id                   = app.cash_receipt_id  /*4436914*/
  and    (ps.payment_schedule_id                = app.applied_payment_schedule_id
         OR
         ps.payment_schedule_id                = app.payment_schedule_id)
  and    app.status                           in ( 'APP')
  and    nvl(app.confirmed_flag, 'Y')          = 'Y'
  and    ps.gl_date_closed                     > p_as_of_date
  and    (app.reversal_gl_date                 > p_as_of_date OR
          app.reversal_gl_date                is null )
  and    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y'
  and    ps.customer_id                        = p_customer_id
  and    ps.customer_site_use_id               = p_customer_site_use_id
  and    decode(upper(p_currency_code),
                NULL, ps.invoice_currency_code,
                upper(p_currency_code))        = ps.invoice_currency_code
  and    decode(upper(p_credit_option),
                'AGE', 'dummy','SUMMARY','dummy',
                'CM')                         <> ps.class
  and    decode(upper(p_credit_option),
                'AGE', 'dummy','SUMMARY','dummy',
                'PMT')                        <> ps.class
group by ps.due_date,
         ps.amount_due_original,
         ps.amount_adjusted,
         ps.amount_applied,
         ps.amount_credited,
         ps.gl_date,
         ps.amount_in_dispute,
         ps.amount_adjusted_pending,
         ps.invoice_currency_code,
         ps.exchange_rate,
         ps.class,
         ps.payment_schedule_id
UNION ALL
SELECT -sum(nvl(adj.amount,0)) amount_due_remaining,1,0,0,0,0,0,0
FROM   ar_adjustments adj,
       ar_payment_schedules_all ps
WHERE         adj.GL_date                           > p_as_of_date
       AND    ps.payment_schedule_id                = adj.payment_schedule_id
       AND    adj.status                            = 'A'
       AND    ps.gl_date_closed                     > p_as_of_date
       AND    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y'
       AND    ps.customer_id                        = p_customer_id
       AND    ps.customer_site_use_id               = p_customer_site_use_id
       AND    decode(upper(p_currency_code),NULL, ps.invoice_currency_code,upper(p_currency_code))= ps.invoice_currency_code
       AND    decode(upper(p_credit_option),'AGE', 'dummy','SUMMARY','dummy','CM')                         <> ps.class
       AND    decode(upper(p_credit_option),'AGE', 'dummy','SUMMARY','dummy','PMT')                        <> ps.class
group by ps.due_date,
         ps.amount_due_original,
         ps.amount_adjusted,
         ps.amount_applied,
         ps.amount_credited,
         ps.gl_date,
         ps.amount_in_dispute,
         ps.amount_adjusted_pending,
         ps.invoice_currency_code,
         ps.exchange_rate,
         ps.class;

/* bug4047166 : the cursor c_buckets_4 will be used as if site use id is null
                and trx types are null */

   CURSOR c_buckets_4 IS
  select decode(p_currency_code, NULL, ps.acctd_amount_due_remaining,
                ps.amount_due_remaining),
         decode(v_bucket_line_type_0,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_0,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_0,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b0,
	decode(v_bucket_line_type_1,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_1,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_1,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b1,
	decode(v_bucket_line_type_2,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_2,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_2,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b2,
	decode(v_bucket_line_type_3,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_3,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_3,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b3,
	decode(v_bucket_line_type_4,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_4,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_4,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b4,
	decode(v_bucket_line_type_5,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_5,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_5,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b5,
	decode(v_bucket_line_type_6,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_6,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_6,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b6
  from   ar_payment_schedules        ps,
         ra_cust_trx_types           rctt
  where  ps.gl_date                           <= p_as_of_date
  and    ps.gl_date_closed                     > p_as_of_date
  and    ps.cust_trx_type_id                   = rctt.cust_trx_type_id
  and    ps.customer_id                        = p_customer_id
  and    decode(upper(p_currency_code),
                NULL, ps.invoice_currency_code,
                upper(p_currency_code))        = ps.invoice_currency_code
  and    decode(upper(p_credit_option),
                'AGE', 'dummy', 'SUMMARY','dummy',
                'CM')                         <> ps.class
  and    decode(upper(p_credit_option),
                'AGE', 'dummy', 'SUMMARY','dummy',
                'PMT')                        <> ps.class
UNION ALL
  select -sum(decode(p_currency_code, NULL, app.acctd_amount_applied_from,
                     app.amount_applied)),
	decode(v_bucket_line_type_0,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_0,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_0,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b0,
	decode(v_bucket_line_type_1,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_1,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_1,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1)))b1,
	decode(v_bucket_line_type_2,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_2,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_2,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b2,
	decode(v_bucket_line_type_3,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_3,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_3,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b3,
	decode(v_bucket_line_type_4,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_4,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_4,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b4,
	decode(v_bucket_line_type_5,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_5,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_5,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b5,
	decode(v_bucket_line_type_6,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_6,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_6,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b6
  from   ar_payment_schedules           ps,
	 ar_receivable_applications     app
 where   app.gl_date+0                        <= p_as_of_date
  and    ps.cash_receipt_id+0                  = app.cash_receipt_id
  and    app.status                           in ( 'ACC', 'UNAPP', 'UNID','OTHER ACC')
  and    nvl(app.confirmed_flag, 'Y')          = 'Y'
  and    ps.gl_date_closed                     > p_as_of_date
  and    (app.reversal_gl_date                 > p_as_of_date OR
          app.reversal_gl_date                is null )
  and    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y'
  and    ps.customer_id                        = p_customer_id
  and    decode(upper(p_currency_code),
                NULL, ps.invoice_currency_code,
                upper(p_currency_code))        = ps.invoice_currency_code
  and    decode(p_credit_option,'AGE','AGE','dummy') = 'AGE'  /*4436914*/
  and    decode(upper(p_credit_option),
                'AGE', 'dummy', 'SUMMARY','dummy',
                'CM')                         <> ps.class
  and    decode(upper(p_credit_option),
                'AGE', 'dummy', 'SUMMARY','dummy',
                'PMT')                        <> ps.class
group by ps.due_date,
         ps.amount_due_original,
         ps.amount_adjusted,
         ps.amount_applied,
         ps.amount_credited,
         ps.gl_date,
         ps.amount_in_dispute,
         ps.amount_adjusted_pending,
         ps.invoice_currency_code,
         ps.exchange_rate,
         ps.class,
         decode( app.status, 'UNID', 'UNID', 'UNAPP')
UNION ALL /*Bug 4436914 excluded APP and adjustments after as of date*/
  select nvl(sum(decode(p_currency_code, NULL, app.amount_applied,
                  app.acctd_amount_applied_from)),0) amount_due_remaining,
        decode(v_bucket_line_type_0,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_0,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_0,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b0,
        decode(v_bucket_line_type_1,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_1,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_1,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1)))b1,
        decode(v_bucket_line_type_2,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_2,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_2,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b2,
        decode(v_bucket_line_type_3,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_3,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_3,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b3,
        decode(v_bucket_line_type_4,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_4,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_4,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b4,
        decode(v_bucket_line_type_5,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_5,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_5,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b5,
        decode(v_bucket_line_type_6,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_6,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_6,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b6
  from   ar_payment_schedules           ps,
         ar_receivable_applications     app
 where   app.gl_date+0                        > p_as_of_date
  and    ps.cash_receipt_id                   = app.cash_receipt_id  /*4436914*/
  and    (ps.payment_schedule_id                = app.applied_payment_schedule_id
         OR
         ps.payment_schedule_id                = app.payment_schedule_id)
  and    app.status                           in ( 'APP')
  and    nvl(app.confirmed_flag, 'Y')          = 'Y'
  and    ps.gl_date_closed                     > p_as_of_date
  and    (app.reversal_gl_date                 > p_as_of_date OR
          app.reversal_gl_date                is null )
  and    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y'
  and    ps.customer_id                        = p_customer_id
  and    decode(upper(p_currency_code),
                NULL, ps.invoice_currency_code,
                upper(p_currency_code))        = ps.invoice_currency_code
  and    decode(upper(p_credit_option),
                'AGE', 'dummy','SUMMARY','dummy',
                'CM')                         <> ps.class
  and    decode(upper(p_credit_option),
                'AGE', 'dummy','SUMMARY','dummy',
                'PMT')                        <> ps.class
group by ps.due_date,
         ps.amount_due_original,
         ps.amount_adjusted,
         ps.amount_applied,
         ps.amount_credited,
         ps.gl_date,
         ps.amount_in_dispute,
         ps.amount_adjusted_pending,
         ps.invoice_currency_code,
         ps.exchange_rate,
         ps.class,
         ps.payment_schedule_id
UNION ALL
SELECT -sum(nvl(adj.amount,0)) amount_due_remaining,1,0,0,0,0,0,0
FROM   ar_adjustments adj,
       ar_payment_schedules_all ps
WHERE         adj.GL_date                           > p_as_of_date
       AND    ps.payment_schedule_id                = adj.payment_schedule_id
       AND    adj.status                            = 'A'
       AND    ps.gl_date_closed                     > p_as_of_date
       AND    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y'
       AND    ps.customer_id                        = p_customer_id
       AND    decode(upper(p_currency_code),NULL, ps.invoice_currency_code,upper(p_currency_code))= ps.invoice_currency_code
       AND    decode(upper(p_credit_option),'AGE', 'dummy','SUMMARY','dummy','CM')                         <> ps.class
       AND    decode(upper(p_credit_option),'AGE', 'dummy','SUMMARY','dummy','PMT')                        <> ps.class
group by ps.due_date,
         ps.amount_due_original,
         ps.amount_adjusted,
         ps.amount_applied,
         ps.amount_credited,
         ps.gl_date,
         ps.amount_in_dispute,
         ps.amount_adjusted_pending,
         ps.invoice_currency_code,
         ps.exchange_rate,
         ps.class;

/* bug4047166 : the cursor c_buckets_5 will be used as if site use id is null
                and trx types are not null */

   CURSOR c_buckets_5 IS
  select decode(p_currency_code, NULL, ps.acctd_amount_due_remaining,
                ps.amount_due_remaining) amount_due_remaining,
         decode(v_bucket_line_type_0,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_0,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_0,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b0,
	decode(v_bucket_line_type_1,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_1,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_1,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b1,
	decode(v_bucket_line_type_2,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_2,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_2,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b2,
	decode(v_bucket_line_type_3,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_3,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_3,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b3,
	decode(v_bucket_line_type_4,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_4,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_4,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b4,
	decode(v_bucket_line_type_5,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_5,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_5,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b5,
	decode(v_bucket_line_type_6,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_6,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_6,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b6
  from   ra_cust_trx_types,
         ar_payment_schedules        ps
  where  ps.gl_date                           <= p_as_of_date
  and    ps.cust_trx_type_id                   = ra_cust_trx_types.cust_trx_type_id
  and    ps.gl_date_closed                     > p_as_of_date
  and    ps.customer_id                        = p_customer_id
  and    decode(upper(p_currency_code),
                NULL, ps.invoice_currency_code,
                upper(p_currency_code))        = ps.invoice_currency_code
  and    decode(upper(p_credit_option),
                'AGE', 'dummy', 'SUMMARY','dummy',
                'CM')                         <> ps.class
  and    decode(upper(p_credit_option),
                'AGE', 'dummy', 'SUMMARY','dummy',
                'PMT')                        <> ps.class
  and    decode(p_invoice_type_low,
                NULL, ra_cust_trx_types.name,
                p_invoice_type_low)           <= ra_cust_trx_types.name
  and    decode(p_invoice_type_high,
                NULL, ra_cust_trx_types.name,
                p_invoice_type_high)          >= ra_cust_trx_types.name
UNION ALL
  select nvl(-sum(decode(p_currency_code, NULL, app.amount_applied,
                  app.acctd_amount_applied_from)),0) amount_due_remaining,
	decode(v_bucket_line_type_0,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_0,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_0,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b0,
	decode(v_bucket_line_type_1,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_1,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_1,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1)))b1,
	decode(v_bucket_line_type_2,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_2,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_2,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b2,
	decode(v_bucket_line_type_3,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_3,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_3,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b3,
	decode(v_bucket_line_type_4,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_4,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_4,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b4,
	decode(v_bucket_line_type_5,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_5,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_5,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b5,
	decode(v_bucket_line_type_6,
		'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
		'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
		'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
			0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
			1),
		decode(	greatest(v_bucket_days_from_6,
				ceil(p_as_of_date-ps.due_date)),
			least(v_bucket_days_to_6,
				ceil(p_as_of_date-ps.due_date)),1,
			0)
		* decode(nvl(ps.amount_in_dispute,0), 0, 1,
			decode(v_bucket_category,
				'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))
		* decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
			decode(v_bucket_category,
				'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
				1))) b6
  from   ar_payment_schedules           ps,
	 ar_receivable_applications     app
 where   app.gl_date+0                        <= p_as_of_date
  and    ps.cash_receipt_id+0                  = app.cash_receipt_id
  and    app.status                           in ( 'ACC', 'UNAPP', 'UNID','OTHER ACC')
  and    nvl(app.confirmed_flag, 'Y')          = 'Y'
  and    ps.gl_date_closed                     > p_as_of_date
  and    (app.reversal_gl_date                 > p_as_of_date OR
          app.reversal_gl_date                is null )
  and    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y'
  and    ps.customer_id                        = p_customer_id
  and    decode(upper(p_currency_code),
                NULL, ps.invoice_currency_code,
                upper(p_currency_code))        = ps.invoice_currency_code
  and    decode(p_credit_option,'AGE','AGE','dummy') = 'AGE' /*4436914*/
  and    decode(upper(p_credit_option),
                'AGE', 'dummy', 'SUMMARY','dummy',
                'CM')                         <> ps.class
  and    decode(upper(p_credit_option),
                'AGE', 'dummy', 'SUMMARY','dummy',
                'PMT')                        <> ps.class
group by ps.due_date,
         ps.amount_due_original,
         ps.amount_adjusted,
         ps.amount_applied,
         ps.amount_credited,
         ps.gl_date,
         ps.amount_in_dispute,
         ps.amount_adjusted_pending,
         ps.invoice_currency_code,
         ps.exchange_rate,
         ps.class,
         decode( app.status, 'UNID', 'UNID', 'UNAPP')
UNION ALL /*Bug 4436914 included APP*/
  select nvl(sum(decode(p_currency_code, NULL, app.amount_applied,
                  app.acctd_amount_applied_from)),0) amount_due_remaining,
        decode(v_bucket_line_type_0,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_0,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_0,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b0,
        decode(v_bucket_line_type_1,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_1,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_1,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1)))b1,
        decode(v_bucket_line_type_2,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_2,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_2,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b2,
        decode(v_bucket_line_type_3,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_3,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_3,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b3,
        decode(v_bucket_line_type_4,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_4,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_4,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b4,
        decode(v_bucket_line_type_5,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_5,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_5,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b5,
        decode(v_bucket_line_type_6,
                'DISPUTE_ONLY',decode(nvl(ps.amount_in_dispute,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(ps.amount_in_dispute,0),
                        0,decode(nvl(ps.amount_adjusted_pending,0),0,0,1),
                        1),
                decode( greatest(v_bucket_days_from_6,
                                ceil(p_as_of_date-ps.due_date)),
                        least(v_bucket_days_to_6,
                                ceil(p_as_of_date-ps.due_date)),1,
                        0)
                * decode(nvl(ps.amount_in_dispute,0), 0, 1,
                        decode(v_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(ps.amount_adjusted_pending,0), 0, 1,
                        decode(v_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))) b6
  from   ar_payment_schedules           ps,
         ar_receivable_applications     app
 where   app.gl_date+0                        > p_as_of_date
  and    ps.cash_receipt_id                   = app.cash_receipt_id  /*4436914*/
  and    (ps.payment_schedule_id                = app.applied_payment_schedule_id
         OR
         ps.payment_schedule_id                = app.payment_schedule_id)
  and    app.status                           in ( 'APP')
  and    nvl(app.confirmed_flag, 'Y')          = 'Y'
  and    ps.gl_date_closed                     > p_as_of_date
  and    (app.reversal_gl_date                 > p_as_of_date OR
          app.reversal_gl_date                is null )
  and    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y'
  and    ps.customer_id                        = p_customer_id
  and    decode(upper(p_currency_code),
                NULL, ps.invoice_currency_code,
                upper(p_currency_code))        = ps.invoice_currency_code
  and    decode(upper(p_credit_option),
                'AGE', 'dummy','SUMMARY','dummy',
                'CM')                         <> ps.class
  and    decode(upper(p_credit_option),
                'AGE', 'dummy','SUMMARY','dummy',
                'PMT')                        <> ps.class
group by ps.due_date,
         ps.amount_due_original,
         ps.amount_adjusted,
         ps.amount_applied,
         ps.amount_credited,
         ps.gl_date,
         ps.amount_in_dispute,
         ps.amount_adjusted_pending,
         ps.invoice_currency_code,
         ps.exchange_rate,
         ps.class,
         ps.payment_schedule_id
UNION ALL
SELECT -sum(nvl(adj.amount,0)) amount_due_remaining,1,0,0,0,0,0,0
FROM   ar_adjustments adj,
       ar_payment_schedules_all ps
WHERE         adj.GL_date                           > p_as_of_date
       AND    ps.payment_schedule_id                = adj.payment_schedule_id
       AND    adj.status                            = 'A'
       AND    ps.gl_date_closed                     > p_as_of_date
       AND    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y'
       AND    ps.customer_id                        = p_customer_id
       AND    decode(upper(p_currency_code),NULL, ps.invoice_currency_code,upper(p_currency_code))= ps.invoice_currency_code
       AND    decode(upper(p_credit_option),'AGE', 'dummy','SUMMARY','dummy','CM')                         <> ps.class
       AND    decode(upper(p_credit_option),'AGE', 'dummy','SUMMARY','dummy','PMT')                        <> ps.class
group by ps.due_date,
         ps.amount_due_original,
         ps.amount_adjusted,
         ps.amount_applied,
         ps.amount_credited,
         ps.gl_date,
         ps.amount_in_dispute,
         ps.amount_adjusted_pending,
         ps.invoice_currency_code,
         ps.exchange_rate,
         ps.class;
BEGIN
--
-- Get the aging buckets definition.
--
   OPEN c_sel_bucket_data;
   FETCH c_sel_bucket_data INTO v_bucket_days_from_0, v_bucket_days_to_0,
                                   p_bucket_titletop_0, p_bucket_titlebottom_0,
                                   v_bucket_line_type_0;
   IF c_sel_bucket_data%FOUND THEN
      p_bucket_amount_0 := 0;
      IF (v_bucket_line_type_0 = 'DISPUTE_ONLY') OR
         (v_bucket_line_type_0 =  'PENDADJ_ONLY') OR
         (v_bucket_line_type_0 =  'DISPUTE_PENDADJ') THEN
         v_bucket_category := v_bucket_line_type_0;
      END IF;
      FETCH c_sel_bucket_data INTO v_bucket_days_from_1, v_bucket_days_to_1,
                                   p_bucket_titletop_1, p_bucket_titlebottom_1,
                                   v_bucket_line_type_1;
   ELSE
      p_bucket_titletop_0    := NULL;
      p_bucket_titlebottom_0 := NULL;
      p_bucket_amount_0      := NULL;
   END IF;
   IF c_sel_bucket_data%FOUND THEN
      p_bucket_amount_1 := 0;
      IF (v_bucket_line_type_1 = 'DISPUTE_ONLY') OR
         (v_bucket_line_type_1 =  'PENDADJ_ONLY') OR
         (v_bucket_line_type_1 =  'DISPUTE_PENDADJ') THEN
         v_bucket_category := v_bucket_line_type_1;
      END IF;
      FETCH c_sel_bucket_data INTO v_bucket_days_from_2, v_bucket_days_to_2,
                                   p_bucket_titletop_2, p_bucket_titlebottom_2,
                                   v_bucket_line_type_2;
   ELSE
      p_bucket_titletop_1    := NULL;
      p_bucket_titlebottom_1 := NULL;
      p_bucket_amount_1      := NULL;
   END IF;
   IF c_sel_bucket_data%FOUND THEN
      p_bucket_amount_2 := 0;
      IF (v_bucket_line_type_2 = 'DISPUTE_ONLY') OR
         (v_bucket_line_type_2 =  'PENDADJ_ONLY') OR
         (v_bucket_line_type_2 =  'DISPUTE_PENDADJ') THEN
         v_bucket_category := v_bucket_line_type_2;
      END IF;
      FETCH c_sel_bucket_data INTO v_bucket_days_from_3, v_bucket_days_to_3,
                                   p_bucket_titletop_3, p_bucket_titlebottom_3,
                                   v_bucket_line_type_3;
   ELSE
      p_bucket_titletop_2    := NULL;
      p_bucket_titlebottom_2 := NULL;
      p_bucket_amount_2      := NULL;
   END IF;
   IF c_sel_bucket_data%FOUND THEN
      p_bucket_amount_3 := 0;
      IF (v_bucket_line_type_3 = 'DISPUTE_ONLY') OR
         (v_bucket_line_type_3 =  'PENDADJ_ONLY') OR
         (v_bucket_line_type_3 =  'DISPUTE_PENDADJ') THEN
         v_bucket_category := v_bucket_line_type_3;
      END IF;
      FETCH c_sel_bucket_data INTO v_bucket_days_from_4, v_bucket_days_to_4,
                                   p_bucket_titletop_4, p_bucket_titlebottom_4,
                                   v_bucket_line_type_4;
   ELSE
      p_bucket_titletop_3    := NULL;
      p_bucket_titlebottom_3 := NULL;
      p_bucket_amount_3      := NULL;
   END IF;
   IF c_sel_bucket_data%FOUND THEN
      p_bucket_amount_4 := 0;
      IF (v_bucket_line_type_4 = 'DISPUTE_ONLY') OR
         (v_bucket_line_type_4 =  'PENDADJ_ONLY') OR
         (v_bucket_line_type_4 =  'DISPUTE_PENDADJ') THEN
         v_bucket_category := v_bucket_line_type_4;
      END IF;
      FETCH c_sel_bucket_data INTO v_bucket_days_from_5, v_bucket_days_to_5,
                                   p_bucket_titletop_5, p_bucket_titlebottom_5,
                                   v_bucket_line_type_5;
   ELSE
      p_bucket_titletop_4    := NULL;
      p_bucket_titlebottom_4 := NULL;
      p_bucket_amount_4      := NULL;
   END IF;
   IF c_sel_bucket_data%FOUND THEN
      p_bucket_amount_5 := 0;
      IF (v_bucket_line_type_5 = 'DISPUTE_ONLY') OR
         (v_bucket_line_type_5 =  'PENDADJ_ONLY') OR
         (v_bucket_line_type_5 =  'DISPUTE_PENDADJ') THEN
         v_bucket_category := v_bucket_line_type_5;
      END IF;
      FETCH c_sel_bucket_data INTO v_bucket_days_from_6, v_bucket_days_to_6,
                                   p_bucket_titletop_6, p_bucket_titlebottom_6,
                                   v_bucket_line_type_6;
   ELSE
      p_bucket_titletop_5    := NULL;
      p_bucket_titlebottom_5 := NULL;
      p_bucket_amount_5      := NULL;
   END IF;
   IF c_sel_bucket_data%FOUND THEN
      p_bucket_amount_6 := 0;
      IF (v_bucket_line_type_6 = 'DISPUTE_ONLY') OR
         (v_bucket_line_type_6 =  'PENDADJ_ONLY') OR
         (v_bucket_line_type_6 =  'DISPUTE_PENDADJ') THEN
         v_bucket_category := v_bucket_line_type_6;
      END IF;
   ELSE
      p_bucket_titletop_6    := NULL;
      p_bucket_titlebottom_6 := NULL;
      p_bucket_amount_6      := NULL;
   END IF;
   CLOSE c_sel_bucket_data;
   --
   -- get the aging bucket balance.  The v_bucket_ is either 1 or 0.
   --
   p_outstanding_balance := 0;
/* bug4047166: Added code to handle different cursosrs */
   IF p_customer_site_use_id IS NOT NULL AND (p_invoice_type_low IS NULL AND p_invoice_type_high IS NULL) THEN
   OPEN c_buckets_2;
   LOOP
      FETCH c_buckets_2 INTO v_amount_due_remaining,
                        v_bucket_0, v_bucket_1, v_bucket_2,
                        v_bucket_3, v_bucket_4, v_bucket_5, v_bucket_6;
      EXIT WHEN c_buckets_2%NOTFOUND;
     p_outstanding_balance := p_outstanding_balance + v_amount_due_remaining;
      IF p_bucket_amount_0 IS NOT NULL THEN
         p_bucket_amount_0 := p_bucket_amount_0 +
                              (v_bucket_0 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_1 IS NOT NULL THEN
         p_bucket_amount_1 := p_bucket_amount_1 +
                              (v_bucket_1 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_2 IS NOT NULL THEN
         p_bucket_amount_2 := p_bucket_amount_2 +
                              (v_bucket_2 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_3 IS NOT NULL THEN
         p_bucket_amount_3 := p_bucket_amount_3 +
                              (v_bucket_3 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_4 IS NOT NULL THEN
         p_bucket_amount_4 := p_bucket_amount_4 +
                              (v_bucket_4 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_5 IS NOT NULL THEN
         p_bucket_amount_5 := p_bucket_amount_5 +
                              (v_bucket_5 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_6 IS NOT NULL THEN
         p_bucket_amount_6 := p_bucket_amount_6 +
                              (v_bucket_6 * v_amount_due_remaining);
      END IF;
   END LOOP;
   CLOSE c_buckets_2;
   ELSIF p_customer_site_use_id IS NOT NULL AND (p_invoice_type_low IS NOT NULL OR p_invoice_type_high IS NOT  NULL) THEN
   OPEN c_buckets_3;
   LOOP
      FETCH c_buckets_3 INTO v_amount_due_remaining,
                        v_bucket_0, v_bucket_1, v_bucket_2,
                        v_bucket_3, v_bucket_4, v_bucket_5, v_bucket_6;
      EXIT WHEN c_buckets_3%NOTFOUND;
     p_outstanding_balance := p_outstanding_balance + v_amount_due_remaining;
      IF p_bucket_amount_0 IS NOT NULL THEN
         p_bucket_amount_0 := p_bucket_amount_0 +
                              (v_bucket_0 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_1 IS NOT NULL THEN
         p_bucket_amount_1 := p_bucket_amount_1 +
                              (v_bucket_1 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_2 IS NOT NULL THEN
         p_bucket_amount_2 := p_bucket_amount_2 +
                              (v_bucket_2 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_3 IS NOT NULL THEN
         p_bucket_amount_3 := p_bucket_amount_3 +
                              (v_bucket_3 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_4 IS NOT NULL THEN
         p_bucket_amount_4 := p_bucket_amount_4 +
                              (v_bucket_4 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_5 IS NOT NULL THEN
         p_bucket_amount_5 := p_bucket_amount_5 +
                              (v_bucket_5 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_6 IS NOT NULL THEN
         p_bucket_amount_6 := p_bucket_amount_6 +
                              (v_bucket_6 * v_amount_due_remaining);
      END IF;
   END LOOP;
   CLOSE c_buckets_3;
   ELSIF p_customer_site_use_id IS NULL AND (p_invoice_type_low IS NULL AND p_invoice_type_high IS  NULL) THEN
   OPEN c_buckets_4;
   LOOP
      FETCH c_buckets_4 INTO v_amount_due_remaining,
                        v_bucket_0, v_bucket_1, v_bucket_2,
                        v_bucket_3, v_bucket_4, v_bucket_5, v_bucket_6;
      EXIT WHEN c_buckets_4%NOTFOUND;
     p_outstanding_balance := p_outstanding_balance + v_amount_due_remaining;
      IF p_bucket_amount_0 IS NOT NULL THEN
         p_bucket_amount_0 := p_bucket_amount_0 +
                              (v_bucket_0 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_1 IS NOT NULL THEN
         p_bucket_amount_1 := p_bucket_amount_1 +
                              (v_bucket_1 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_2 IS NOT NULL THEN
         p_bucket_amount_2 := p_bucket_amount_2 +
                              (v_bucket_2 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_3 IS NOT NULL THEN
         p_bucket_amount_3 := p_bucket_amount_3 +
                              (v_bucket_3 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_4 IS NOT NULL THEN
         p_bucket_amount_4 := p_bucket_amount_4 +
                              (v_bucket_4 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_5 IS NOT NULL THEN
         p_bucket_amount_5 := p_bucket_amount_5 +
                              (v_bucket_5 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_6 IS NOT NULL THEN
         p_bucket_amount_6 := p_bucket_amount_6 +
                              (v_bucket_6 * v_amount_due_remaining);
      END IF;
   END LOOP;
   CLOSE c_buckets_4;
   ELSIF p_customer_site_use_id IS NULL AND (p_invoice_type_low IS NOT NULL OR p_invoice_type_high IS NOT NULL) THEN
   OPEN c_buckets_5;
   LOOP
      FETCH c_buckets_5 INTO v_amount_due_remaining,
                        v_bucket_0, v_bucket_1, v_bucket_2,
                        v_bucket_3, v_bucket_4, v_bucket_5, v_bucket_6;
      EXIT WHEN c_buckets_5%NOTFOUND;
     p_outstanding_balance := p_outstanding_balance + nvl(v_amount_due_remaining,0);
      IF p_bucket_amount_0 IS NOT NULL THEN
         p_bucket_amount_0 := p_bucket_amount_0 +
                              (v_bucket_0 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_1 IS NOT NULL THEN
         p_bucket_amount_1 := p_bucket_amount_1 +
                              (v_bucket_1 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_2 IS NOT NULL THEN
         p_bucket_amount_2 := p_bucket_amount_2 +
                              (v_bucket_2 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_3 IS NOT NULL THEN
         p_bucket_amount_3 := p_bucket_amount_3 +
                              (v_bucket_3 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_4 IS NOT NULL THEN
         p_bucket_amount_4 := p_bucket_amount_4 +
                              (v_bucket_4 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_5 IS NOT NULL THEN
         p_bucket_amount_5 := p_bucket_amount_5 +
                              (v_bucket_5 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_6 IS NOT NULL THEN
         p_bucket_amount_6 := p_bucket_amount_6 +
                              (v_bucket_6 * v_amount_due_remaining);
      END IF;
   END LOOP;
   CLOSE c_buckets_5;
   ELSE
   OPEN c_buckets_1;
   LOOP
      FETCH c_buckets_1 INTO v_amount_due_remaining,
                        v_bucket_0, v_bucket_1, v_bucket_2,
                        v_bucket_3, v_bucket_4, v_bucket_5, v_bucket_6;
      EXIT WHEN c_buckets_1%NOTFOUND;
     p_outstanding_balance := p_outstanding_balance + v_amount_due_remaining;
      IF p_bucket_amount_0 IS NOT NULL THEN
         p_bucket_amount_0 := p_bucket_amount_0 +
                              (v_bucket_0 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_1 IS NOT NULL THEN
         p_bucket_amount_1 := p_bucket_amount_1 +
                              (v_bucket_1 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_2 IS NOT NULL THEN
         p_bucket_amount_2 := p_bucket_amount_2 +
                              (v_bucket_2 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_3 IS NOT NULL THEN
         p_bucket_amount_3 := p_bucket_amount_3 +
                              (v_bucket_3 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_4 IS NOT NULL THEN
         p_bucket_amount_4 := p_bucket_amount_4 +
                              (v_bucket_4 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_5 IS NOT NULL THEN
         p_bucket_amount_5 := p_bucket_amount_5 +
                              (v_bucket_5 * v_amount_due_remaining);
      END IF;
      IF p_bucket_amount_6 IS NOT NULL THEN
         p_bucket_amount_6 := p_bucket_amount_6 +
                              (v_bucket_6 * v_amount_due_remaining);
      END IF;
   END LOOP;
   CLOSE c_buckets_1;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('EXCEPTION: arp_customer_aging.calc_aging_buckets');
        END IF;
END calc_aging_buckets;
--
--
--
PROCEDURE calc_credits (
        p_customer_id        	IN NUMBER,
        p_customer_site_use_id 	IN NUMBER,
        p_as_of_date         	IN DATE,
        p_currency_code      	IN VARCHAR2,
	p_ps_max_id		IN NUMBER DEFAULT 0,
	p_credits	     	OUT NOCOPY NUMBER
) IS
   CURSOR c_credits IS
      SELECT NVL( SUM( DECODE(p_currency_code, NULL,
                              ps.acctd_amount_due_remaining,
                              ps.amount_due_remaining)), 0)
      FROM   ar_payment_schedules           ps,
             ra_cust_trx_line_gl_dist       gld
      WHERE  ps.customer_id                        = p_customer_id
      AND    decode(p_customer_site_use_id,
                    NULL, ps.customer_site_use_id,
                    p_customer_site_use_id)        = ps.customer_site_use_id
      AND    decode(upper(p_currency_code),
                    NULL, ps.invoice_currency_code,
                    upper(p_currency_code))        = ps.invoice_currency_code
      AND    ps.customer_trx_id                    = gld.customer_trx_id
      AND    gld.account_class                     = 'REC'
      AND    gld.latest_rec_flag                   = 'Y'
      AND    ps.class||''                          = 'CM'
      AND    ps.gl_date                           <= p_as_of_date;
BEGIN
   p_credits := 0;
   OPEN c_credits;
   FETCH c_credits INTO p_credits;
   CLOSE c_credits;
   --
EXCEPTION
   WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('EXCEPTION: arp_customer_aging.calc_credits');
        END IF;
END calc_credits;
--
--
--
PROCEDURE calc_receipts (
                         p_customer_id        	   IN  NUMBER,
                         p_customer_site_use_id    IN  NUMBER,
                         p_as_of_date         	   IN  DATE,
                         p_currency_code      	   IN  VARCHAR2,
	                 p_app_max_id		   IN  NUMBER DEFAULT 0,
                         p_unapplied_cash     	   OUT NOCOPY NUMBER,
	                 p_onacct_cash	     	   OUT NOCOPY NUMBER,
	                 p_cash_claims	     	   OUT NOCOPY NUMBER,
	                 p_prepayments	     	   OUT NOCOPY NUMBER
                        ) IS
/* bug4047166: The cursor c_unapplied_cash is now 4 different cursors.
   Any one of them will get executed depening upon the site and currency
   value provided. This is done to improve performance */

   CURSOR c_unapplied_cash_1 IS
      SELECT NVL(SUM( DECODE(app.status,'UNAPP',
                             DECODE(p_currency_code, NULL,
                                    -app.acctd_amount_applied_from,
                                    -app.amount_applied), 0) ), 0),
             NVL(SUM( DECODE(app.status,'ACC',
                             DECODE(p_currency_code, NULL,
                                    -app.acctd_amount_applied_from,
                                    -app.amount_applied), 0) ), 0),
             NVL(SUM( DECODE(app.status,'OTHER ACC',
                         DECODE(app.applied_payment_schedule_id, -4,
                             DECODE(p_currency_code, NULL,
                                    -app.acctd_amount_applied_from,
                                    -app.amount_applied),0), 0) ), 0),
             NVL(SUM( DECODE(app.status,'OTHER ACC',
                         DECODE(app.applied_payment_schedule_id, -7,
                             DECODE(p_currency_code, NULL,
                                    -app.acctd_amount_applied_from,
                                    -app.amount_applied),0), 0) ), 0)
      FROM   ar_receivable_applications        app,
             ar_payment_schedules              ps
      WHERE  ps.customer_id                        = p_customer_id
      AND    ps.cash_receipt_id                    = app.cash_receipt_id
      AND    nvl( app.confirmed_flag, 'Y' )        = 'Y'
      AND    app.status                           in ( 'UNAPP', 'ACC' ,'OTHER ACC')
      AND    app.gl_date                          <= p_as_of_date;

   CURSOR c_unapplied_cash_2 IS
      SELECT NVL(SUM( DECODE(app.status,'UNAPP',
                             DECODE(p_currency_code, NULL,
                                    -app.acctd_amount_applied_from,
                                    -app.amount_applied), 0) ), 0),
             NVL(SUM( DECODE(app.status,'ACC',
                             DECODE(p_currency_code, NULL,
                                    -app.acctd_amount_applied_from,
                                    -app.amount_applied), 0) ), 0),
             NVL(SUM( DECODE(app.status,'OTHER ACC',
                         DECODE(app.applied_payment_schedule_id, -4,
                             DECODE(p_currency_code, NULL,
                                    -app.acctd_amount_applied_from,
                                    -app.amount_applied),0), 0) ), 0),
             NVL(SUM( DECODE(app.status,'OTHER ACC',
                         DECODE(app.applied_payment_schedule_id, -7,
                             DECODE(p_currency_code, NULL,
                                    -app.acctd_amount_applied_from,
                                    -app.amount_applied),0), 0) ), 0)
      FROM   ar_receivable_applications        app,
             ar_payment_schedules              ps
      WHERE  ps.customer_id                        = p_customer_id
      AND    ps.customer_site_use_id               = p_customer_site_use_id
      AND    ps.cash_receipt_id                    = app.cash_receipt_id
      AND    nvl( app.confirmed_flag, 'Y' )        = 'Y'
      AND    app.status                           in ( 'UNAPP', 'ACC' ,'OTHER ACC')
      AND    app.gl_date                          <= p_as_of_date;

   CURSOR c_unapplied_cash_3 IS
      SELECT NVL(SUM( DECODE(app.status,'UNAPP',
                             DECODE(p_currency_code, NULL,
                                    -app.acctd_amount_applied_from,
                                    -app.amount_applied), 0) ), 0),
             NVL(SUM( DECODE(app.status,'ACC',
                             DECODE(p_currency_code, NULL,
                                    -app.acctd_amount_applied_from,
                                    -app.amount_applied), 0) ), 0),
             NVL(SUM( DECODE(app.status,'OTHER ACC',
                         DECODE(app.applied_payment_schedule_id, -4,
                             DECODE(p_currency_code, NULL,
                                    -app.acctd_amount_applied_from,
                                    -app.amount_applied),0), 0) ), 0),
             NVL(SUM( DECODE(app.status,'OTHER ACC',
                         DECODE(app.applied_payment_schedule_id, -7,
                             DECODE(p_currency_code, NULL,
                                    -app.acctd_amount_applied_from,
                                    -app.amount_applied),0), 0) ), 0)
      FROM   ar_receivable_applications        app,
             ar_payment_schedules              ps
      WHERE  ps.customer_id                        = p_customer_id
      AND    ps.cash_receipt_id                    = app.cash_receipt_id
      AND    nvl( app.confirmed_flag, 'Y' )        = 'Y'
      AND    app.status                           in ( 'UNAPP', 'ACC' ,'OTHER ACC')
      AND    ps.invoice_currency_code            = p_currency_code
      AND    app.gl_date                          <= p_as_of_date;

   CURSOR c_unapplied_cash_4 IS
      SELECT NVL(SUM( DECODE(app.status,'UNAPP',
                             DECODE(p_currency_code, NULL,
                                    -app.acctd_amount_applied_from,
                                    -app.amount_applied), 0) ), 0),
             NVL(SUM( DECODE(app.status,'ACC',
                             DECODE(p_currency_code, NULL,
                                    -app.acctd_amount_applied_from,
                                    -app.amount_applied), 0) ), 0),
             NVL(SUM( DECODE(app.status,'OTHER ACC',
                         DECODE(app.applied_payment_schedule_id, -4,
                             DECODE(p_currency_code, NULL,
                                    -app.acctd_amount_applied_from,
                                    -app.amount_applied),0), 0) ), 0),
             NVL(SUM( DECODE(app.status,'OTHER ACC',
                         DECODE(app.applied_payment_schedule_id, -7,
                             DECODE(p_currency_code, NULL,
                                    -app.acctd_amount_applied_from,
                                    -app.amount_applied),0), 0) ), 0)
      FROM   ar_receivable_applications        app,
             ar_payment_schedules              ps
      WHERE  ps.customer_id                        = p_customer_id
      AND    ps.customer_site_use_id              = p_customer_site_use_id
      AND    ps.cash_receipt_id                    = app.cash_receipt_id
      AND    nvl( app.confirmed_flag, 'Y' )        = 'Y'
      AND    app.status                           in ( 'UNAPP', 'ACC' ,'OTHER ACC')
      AND     ps.invoice_currency_code            = p_currency_code
      AND    app.gl_date                          <= p_as_of_date;
BEGIN
   p_unapplied_cash := 0;
   p_onacct_cash := 0;
/* bug4047166: Added following code to handle different cursosrs */

   IF p_customer_site_use_id IS NOT NULL AND p_currency_code IS NOT NULL THEN
   OPEN c_unapplied_cash_4;
   FETCH c_unapplied_cash_4 INTO p_unapplied_cash, p_onacct_cash,p_cash_claims,p_prepayments;
   CLOSE c_unapplied_cash_4;
   ELSIF p_customer_site_use_id IS NOT NULL AND p_currency_code IS NULL THEN
   OPEN c_unapplied_cash_2;
   FETCH c_unapplied_cash_2 INTO p_unapplied_cash, p_onacct_cash,p_cash_claims,p_prepayments;
   CLOSE c_unapplied_cash_2;
   ELSIF p_customer_site_use_id IS NULL AND p_currency_code IS NOT NULL THEN
   OPEN c_unapplied_cash_3;
   FETCH c_unapplied_cash_3 INTO p_unapplied_cash, p_onacct_cash,p_cash_claims,p_prepayments;
   CLOSE c_unapplied_cash_3;
   ELSE
   OPEN c_unapplied_cash_1;
   FETCH c_unapplied_cash_1 INTO p_unapplied_cash, p_onacct_cash,p_cash_claims,p_prepayments;
   CLOSE c_unapplied_cash_1;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('EXCEPTION: arp_customer_aging.calc_receipts');
        END IF;
END calc_receipts;
--
--
--
PROCEDURE calc_risk_receipts (
        p_customer_id        	IN NUMBER,
        p_customer_site_use_id 	IN NUMBER,
        p_as_of_date         	IN DATE,
        p_currency_code      	IN VARCHAR2,
        p_ps_max_id		IN NUMBER DEFAULT 0,
	p_risk_receipts	     	OUT NOCOPY NUMBER
) IS
   CURSOR c_risk IS
-- bug 1865105 starts
      SELECT NVL( SUM( DECODE(p_currency_code, NULL, crh.acctd_amount,
                              crh.amount)), 0)
      FROM   ar_cash_receipts             cr,
             ar_cash_receipt_history      crh
      WHERE  cr.pay_from_customer = p_customer_id
/* bug no : 1274152. Aging form did not consider the receipts done without custo
mer location for the calculation of receipt at risk. NVL is added for ps.custome
r_site_use_id in the procedure calc_risk_receipts to avoid null = null compariso
n
fixed by rajsrini */
      AND    decode(p_customer_site_use_id,
                    NULL, nvl(cr.customer_site_use_id,0),
                    p_customer_site_use_id)  = nvl(cr.customer_site_use_id,0)
      AND    cr.currency_code= nvl(p_currency_code,cr.currency_code)
      AND    cr.reversal_date is null
      AND    nvl(cr.confirmed_flag,'Y') = 'Y'
      AND    cr.cash_receipt_id = crh.cash_receipt_id
      AND    crh.current_record_flag||'' = 'Y'
      AND    crh.gl_date <= p_as_of_date
      AND    crh.status  NOT IN ( DECODE ( crh.factor_flag,'Y',
               'RISK_ELIMINATED','N', 'CLEARED'), 'REVERSED' )
     /* 06-AUG-2000 J Rautiainen BR Implementation
      * Short term debt applications are not considered as receipts at risk */
      and    not exists (select 'X'
                         from ar_receivable_applications rap
                         where rap.cash_receipt_id = cr.cash_receipt_id
                         and   rap.applied_payment_schedule_id = -2
                         and   rap.display = 'Y');
-- bug 1865105 ends
BEGIN
   OPEN c_risk;
   FETCH c_risk INTO p_risk_receipts;
   CLOSE c_risk;
   --
EXCEPTION
   WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('EXCEPTION: arp_customer_aging.calc_risk_receipts');
        END IF;
END calc_risk_receipts;
--
--
--
PROCEDURE calc_dispute (
                        p_customer_id           IN  NUMBER,
                        p_customer_site_use_id  IN  NUMBER,
                        p_as_of_date            IN  DATE,
                        p_currency_code         IN  VARCHAR2,
                        p_ps_max_id             IN  NUMBER DEFAULT 0,
                        p_dispute               OUT NOCOPY NUMBER
) IS
   CURSOR c_dispute IS
      SELECT NVL(SUM(decode(p_currency_code,NULL,ps.amount_in_dispute * nvl(ps.exchange_rate,1), ps.amount_in_dispute)),0)
      FROM   ar_payment_schedules ps
      WHERE  ps.customer_id                        = p_customer_id
      AND    decode(p_customer_site_use_id,
                    NULL, ps.customer_site_use_id,
                    p_customer_site_use_id)        = ps.customer_site_use_id
      AND    decode(upper(p_currency_code),
                    NULL, ps.invoice_currency_code,
                    upper(p_currency_code))        = ps.invoice_currency_code
--Bug-1304510:Changed ps.due_date to ps.dispute_date.
      AND    ps.dispute_date                          <= p_as_of_date
      AND    nvl( ps.amount_in_dispute, 0 )       <> 0
      AND    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y';
BEGIN
   OPEN c_dispute;
   FETCH c_dispute INTO p_dispute;
   CLOSE c_dispute;
   --
EXCEPTION
   WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('EXCEPTION: arp_customer_aging.calc_dispute');
        END IF;
END calc_dispute;
--
--
--
PROCEDURE calc_pending_adj (
                            p_customer_id           IN  NUMBER,
                            p_customer_site_use_id  IN  NUMBER,
                            p_as_of_date            IN  DATE,
                            p_currency_code         IN  VARCHAR2,
                            p_ps_max_id             IN  NUMBER DEFAULT 0,
                            p_pending_adj           OUT NOCOPY NUMBER
) IS
   CURSOR c_pending_adj IS
      SELECT NVL( SUM( ps.amount_adjusted_pending ), 0)
      FROM   ar_payment_schedules ps
      WHERE  ps.customer_id                        = p_customer_id
      AND    decode(p_customer_site_use_id,
                    NULL, ps.customer_site_use_id,
                    p_customer_site_use_id)        = ps.customer_site_use_id
      AND    decode(upper(p_currency_code),
                    NULL, ps.invoice_currency_code,
                    upper(p_currency_code))        = ps.invoice_currency_code
      AND    ps.due_date                          <= p_as_of_date
      AND    nvl( ps.amount_adjusted_pending, 0 ) <> 0
      AND    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y';
BEGIN
   OPEN c_pending_adj;
   FETCH c_pending_adj INTO p_pending_adj;
   CLOSE c_pending_adj;
   --
EXCEPTION
   WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('EXCEPTION: arp_customer_aging.calc_pending_adj');
        END IF;
END calc_pending_adj;
--
END arp_customer_aging;

/
