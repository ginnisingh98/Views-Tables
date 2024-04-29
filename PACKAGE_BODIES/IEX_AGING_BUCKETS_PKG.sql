--------------------------------------------------------
--  DDL for Package Body IEX_AGING_BUCKETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_AGING_BUCKETS_PKG" AS
/* $Header: iexpagbb.pls 120.9.12010000.7 2009/09/10 07:27:24 gnramasa ship $ */
--
--
    G_PKG_NAME	  CONSTANT VARCHAR2(30) := 'IEX_AGING_BUCKETS_PKG';
    G_FILE_NAME    CONSTANT VARCHAR2(12) := 'iexpagbb.pls';
    l_line    varchar2(100);
    l_date    date ;

    -- Decimal Rounding in case of currency calculations.
    l_round_decimal Number := 8 ;


    -- Cursor to select all cust_account_ids in case user passes party_id
    CURSOR AR_AGING_PARTY_CUR(p_party  Number)
    IS
    SELECT cust_account_id
    FROM   HZ_CUST_ACCOUNTS
	WHERE  party_id = p_party ;

    -- Cursor to select all cust_account_ids in case user passes party_id for paying relationship
    CURSOR AR_AGING_PAYING_PARTY_CUR(p_party  Number)
    IS
    SELECT cust_account_id
    FROM   HZ_CUST_ACCOUNTS
	WHERE  party_id IN
            (SELECT p_party FROM dual
              UNION
             SELECT ar.related_party_id
               FROM ar_paying_relationships_v ar
              WHERE ar.party_id = p_party
                AND TRUNC(sysdate) BETWEEN
                    TRUNC(NVL(ar.effective_start_date,sysdate)) AND
                    TRUNC(NVL(ar.effective_end_date,sysdate)));


PG_DEBUG NUMBER;

PROCEDURE calc_aging_buckets (
        p_customer_id           IN NUMBER,
        p_customer_site_use_id  IN NUMBER,
        p_as_of_date            IN DATE,
        p_currency_code         IN VARCHAR2,
        p_credit_option         IN VARCHAR2,
        p_invoice_type_low      IN VARCHAR2,
        p_invoice_type_high     IN VARCHAR2,
        p_ps_max_id             IN NUMBER ,
        p_app_max_id            IN NUMBER ,
        p_bucket_id             IN Number,
	  p_outstanding_balance	IN OUT NOCOPY NUMBER,
        p_bucket_line_id_0      OUT NOCOPY NUMBER,
        p_bucket_seq_num_0	    OUT NOCOPY NUMBER,
        p_bucket_titletop_0     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_0  OUT NOCOPY VARCHAR2,
        p_bucket_amount_0       IN OUT NOCOPY NUMBER,
        p_bucket_line_id_1      OUT NOCOPY NUMBER,
        p_bucket_seq_num_1	    OUT NOCOPY NUMBER,
        p_bucket_titletop_1     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_1  OUT NOCOPY VARCHAR2,
        p_bucket_amount_1       IN OUT NOCOPY NUMBER,
        p_bucket_line_id_2      OUT NOCOPY NUMBER,
        p_bucket_seq_num_2	    OUT NOCOPY NUMBER,
        p_bucket_titletop_2     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_2  OUT NOCOPY VARCHAR2,
        p_bucket_amount_2       IN OUT NOCOPY NUMBER,
        p_bucket_line_id_3      OUT NOCOPY NUMBER,
        p_bucket_seq_num_3	    OUT NOCOPY NUMBER,
        p_bucket_titletop_3     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_3  OUT NOCOPY VARCHAR2,
        p_bucket_amount_3       IN OUT NOCOPY NUMBER,
        p_bucket_line_id_4      OUT NOCOPY NUMBER,
        p_bucket_seq_num_4	    OUT NOCOPY NUMBER,
        p_bucket_titletop_4     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_4  OUT NOCOPY VARCHAR2,
        p_bucket_amount_4       IN OUT NOCOPY NUMBER,
        p_bucket_line_id_5      OUT NOCOPY NUMBER,
        p_bucket_seq_num_5	    OUT NOCOPY NUMBER,
        p_bucket_titletop_5     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_5  OUT NOCOPY VARCHAR2,
        p_bucket_amount_5       IN OUT NOCOPY NUMBER,
        p_bucket_line_id_6      OUT NOCOPY NUMBER,
        p_bucket_seq_num_6	    OUT NOCOPY NUMBER,
        p_bucket_titletop_6     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_6  OUT NOCOPY VARCHAR2,
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
   v_bucket_line_id_0	NUMBER;
   v_bucket_seq_num_0	NUMBER ;

   v_bucket_line_type_1 ar_aging_bucket_lines.type%TYPE;
   v_bucket_days_from_1 NUMBER;
   v_bucket_days_to_1   NUMBER;
   v_bucket_line_id_1	NUMBER;
   v_bucket_seq_num_1	NUMBER ;

   v_bucket_line_type_2 ar_aging_bucket_lines.type%TYPE;
   v_bucket_days_from_2 NUMBER;
   v_bucket_days_to_2   NUMBER;
   v_bucket_line_id_2	NUMBER;
   v_bucket_seq_num_2	NUMBER ;

   v_bucket_line_type_3 ar_aging_bucket_lines.type%TYPE;
   v_bucket_days_from_3 NUMBER;
   v_bucket_days_to_3   NUMBER;
   v_bucket_line_id_3	NUMBER;
   v_bucket_seq_num_3	NUMBER ;

   v_bucket_line_type_4 ar_aging_bucket_lines.type%TYPE;
   v_bucket_days_from_4 NUMBER;
   v_bucket_days_to_4   NUMBER;
   v_bucket_line_id_4	NUMBER;
   v_bucket_seq_num_4	NUMBER ;

   v_bucket_line_type_5 ar_aging_bucket_lines.type%TYPE;
   v_bucket_days_from_5 NUMBER;
   v_bucket_days_to_5   NUMBER;
   v_bucket_line_id_5	NUMBER;
   v_bucket_seq_num_5	NUMBER ;

   v_bucket_line_type_6 ar_aging_bucket_lines.type%TYPE;
   v_bucket_days_from_6 NUMBER;
   v_bucket_days_to_6   NUMBER;
   v_bucket_line_id_6	NUMBER;
   v_bucket_seq_num_6	NUMBER ;

--
   CURSOR c_sel_bucket_data is
        select lines.days_start,
               lines.days_to,
               lines.report_heading1,
               lines.report_heading2,
               lines.type,
		       lines.aging_bucket_line_id,
		       lines.bucket_sequence_num
        from   ar_aging_bucket_lines    lines,
               ar_aging_buckets         buckets
        where  lines.aging_bucket_id      = buckets.aging_bucket_id
        and    buckets.aging_bucket_id = p_bucket_id
        and    buckets.status          = 'A'
        order  by lines.bucket_sequence_num       ;
--
   CURSOR c_buckets IS
  select /*+ index(ps AR_PAYMENT_SCHEDULES_ALL_CUS2) */ decode(p_currency_code, NULL, ps.acctd_amount_due_remaining,
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
                'AGE', 'dummy',
                'CM')                         <> ps.class
  and    decode(upper(p_credit_option),
                'AGE', 'dummy',
                'PMT')                        <> ps.class
  and    decode(p_invoice_type_low,
                NULL, ra_cust_trx_types.name,
                p_invoice_type_low)           <= ra_cust_trx_types.name
  and    decode(p_invoice_type_high,
                NULL, ra_cust_trx_types.name,
                p_invoice_type_high)          >= ra_cust_trx_types.name
UNION ALL
  select /*+ index(ps AR_PAYMENT_SCHEDULES_ALL_CUS2) */ -sum(decode(p_currency_code, NULL, app.acctd_amount_applied_from,
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
  and    decode(upper(p_credit_option),
                'AGE', 'dummy',
                'CM')                         <> ps.class
  and    decode(upper(p_credit_option),
                'AGE', 'dummy',
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
         decode( app.status, 'UNID', 'UNID', 'UNAPP');


         v_line          varchar2(100);
BEGIN
         v_line          := '-----------------------------------------' ;
--
-- Get the aging buckets definition.
--
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || v_line);
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage
            ('IEX_AGING_BUCKETS_PKG. CALC_AGING_BUCKETS --->>  Start <<--- ');
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || v_line);
    END IF;

   OPEN c_sel_bucket_data;
   FETCH c_sel_bucket_data
	INTO 	v_bucket_days_from_0,
		v_bucket_days_to_0,
            p_bucket_titletop_0,
		p_bucket_titlebottom_0,
            v_bucket_line_type_0,
   		p_bucket_line_id_0,
   		p_bucket_seq_num_0  ;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || ' Bucket Line Id 0 [' || to_char(p_bucket_line_id_0)
            || '] Bucket Seq Num [' || to_char(p_bucket_seq_num_0));
    END IF;


   IF c_sel_bucket_data%FOUND THEN
      p_bucket_amount_0 := 0;
      IF (v_bucket_line_type_0 = 'DISPUTE_ONLY') OR
         (v_bucket_line_type_0 =  'PENDADJ_ONLY') OR
         (v_bucket_line_type_0 =  'DISPUTE_PENDADJ') THEN
         v_bucket_category := v_bucket_line_type_0;
      END IF;
      FETCH c_sel_bucket_data INTO v_bucket_days_from_1, v_bucket_days_to_1,
                                   p_bucket_titletop_1, p_bucket_titlebottom_1,
                                   v_bucket_line_type_1,
   					p_bucket_line_id_1,
   					p_bucket_seq_num_1 ;

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || ' Bucket Line Id 1 [' || to_char(p_bucket_line_id_1)
            || '] Bucket Seq Num [' || to_char(p_bucket_seq_num_1));
    END IF;

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
                                   v_bucket_line_type_2,
   					p_bucket_line_id_2,
   					p_bucket_seq_num_2 ;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || ' Bucket Line Id 2 [' || to_char(p_bucket_line_id_2)
            || '] Bucket Seq Num [' || to_char(p_bucket_seq_num_2));
    END IF;

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
                                   v_bucket_line_type_3,
   					p_bucket_line_id_3,
   					p_bucket_seq_num_3 ;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || ' Bucket Line Id 3 [' || to_char(p_bucket_line_id_3)
            || '] Bucket Seq Num [' || to_char(p_bucket_seq_num_3));
    END IF;

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
                                   v_bucket_line_type_4,
   					p_bucket_line_id_4,
   					p_bucket_seq_num_4 ;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || ' Bucket Line Id 4 [' || to_char(p_bucket_line_id_4)
            || '] Bucket Seq Num [' || to_char(p_bucket_seq_num_4));
    END IF;

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
                                   v_bucket_line_type_5,
   					p_bucket_line_id_5,
   					p_bucket_seq_num_5 ;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || ' Bucket Line Id 5 [' || to_char(p_bucket_line_id_5)
            || '] Bucket Seq Num [' || to_char(p_bucket_seq_num_5));
    END IF;

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
                                   v_bucket_line_type_6,
   					p_bucket_line_id_6,
   					p_bucket_seq_num_6 ;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || ' Bucket Line Id 6 [' || to_char(p_bucket_line_id_6)
            || '] Bucket Seq Num [' || to_char(p_bucket_seq_num_6));
    END IF;

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
   OPEN c_buckets;
   LOOP
      FETCH c_buckets INTO v_amount_due_remaining,
                        v_bucket_0, v_bucket_1, v_bucket_2,
                        v_bucket_3, v_bucket_4, v_bucket_5, v_bucket_6;
      EXIT WHEN c_buckets%NOTFOUND;
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
   CLOSE c_buckets;

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || v_line);
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || ' 0 - id [' || to_char(p_bucket_line_id_0)
            || '] Seq [' || to_char(p_bucket_seq_num_0) || ' Desc [' ||
      p_bucket_titletop_0 || ' ' ||  p_bucket_titlebottom_0 || '] Amt [' ||
      to_char(p_bucket_amount_0));
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || v_line);
    END IF;

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || ' 1 - id [' || to_char(p_bucket_line_id_1)
            || '] Seq [' || to_char(p_bucket_seq_num_1) || ' Desc [' ||
      p_bucket_titletop_1 || ' ' ||  p_bucket_titlebottom_1 || '] Amt [' ||
      to_char(p_bucket_amount_1));
    END IF;


--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || v_line);
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || ' 2 - id [' || to_char(p_bucket_line_id_2)
            || '] Seq [' || to_char(p_bucket_seq_num_2) || ' Desc [' ||
      p_bucket_titletop_2 || ' ' ||  p_bucket_titlebottom_2 || '] Amt [' ||
      to_char(p_bucket_amount_2));
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || v_line);
    END IF;

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || ' 3 - id [' || to_char(p_bucket_line_id_3)
            || '] Seq [' || to_char(p_bucket_seq_num_3) || ' Desc [' ||
      p_bucket_titletop_3 || ' ' ||  p_bucket_titlebottom_3 || '] Amt [' ||
      to_char(p_bucket_amount_3));
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || v_line);
    END IF;

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || ' 4 - id [' || to_char(p_bucket_line_id_4)
            || '] Seq [' || to_char(p_bucket_seq_num_4) || ' Desc [' ||
      p_bucket_titletop_4 || ' ' ||  p_bucket_titlebottom_4 || '] Amt [' ||
      to_char(p_bucket_amount_4));
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || v_line);
    END IF;

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || ' 5 - id [' || to_char(p_bucket_line_id_5)
            || '] Seq [' || to_char(p_bucket_seq_num_5) || ' Desc [' ||
      p_bucket_titletop_5 || ' ' ||  p_bucket_titlebottom_5 || '] Amt [' ||
      to_char(p_bucket_amount_5));
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || v_line);
    END IF;

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || ' 6 - id [' || to_char(p_bucket_line_id_6)
            || '] Seq [' || to_char(p_bucket_seq_num_6) || ' Desc [' ||
      p_bucket_titletop_6 || ' ' ||  p_bucket_titlebottom_6 || '] Amt [' ||
      to_char(p_bucket_amount_6));
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || v_line);
    END IF;


--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || v_line);
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage
            ('IEX_AGING_BUCKETS_PKG. CALC_AGING_BUCKETS --->>  End <<--- ');
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_aging_buckets: ' || v_line);
    END IF;

   --
EXCEPTION
   WHEN OTHERS THEN
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logmessage('EXCEPTION: IEX_PROFILE_AGING_PKG.calc_aging_buckets');
        END IF;
END calc_aging_buckets;
--
--
--

/*---------------------------------------------------------------------------
                        Procedure Calc_Credits
---------------------------------------------------------------------------*/
PROCEDURE calc_credits (
        p_filter_mode           IN VARCHAR2,
        p_filter_id        	    IN NUMBER,
        p_customer_site_use_id 	IN NUMBER,
        p_as_of_date         	IN DATE,
        p_currency_code      	IN VARCHAR2,
	    p_ps_max_id		        IN NUMBER ,
        p_using_paying_rel      IN VARCHAR2,
	    p_credits	     	    OUT NOCOPY NUMBER
) IS


   CURSOR cust_credits IS
      SELECT NVL( SUM( DECODE(p_currency_code, NULL,
                              ps.acctd_amount_due_remaining,
                              ps.amount_due_remaining)), 0)
      FROM   ar_payment_schedules           ps,
             ra_cust_trx_line_gl_dist       gld
      WHERE  ps.customer_id                        = p_filter_id
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
      and    ps.status = 'OP'   -- fixed a bug 5569664
      AND    ps.gl_date                           <= p_as_of_date;

   CURSOR cust_site_credits IS
      SELECT NVL( SUM( DECODE(p_currency_code, NULL,
                              ps.acctd_amount_due_remaining,
                              ps.amount_due_remaining)), 0)
      FROM   ar_payment_schedules           ps,
             ra_cust_trx_line_gl_dist       gld
      WHERE  ps.customer_site_use_id     = p_filter_id
      AND    decode(upper(p_currency_code),
                    NULL, ps.invoice_currency_code,
                    upper(p_currency_code))        = ps.invoice_currency_code
      AND    ps.customer_trx_id                    = gld.customer_trx_id
      AND    gld.account_class                     = 'REC'
      AND    gld.latest_rec_flag                   = 'Y'
      AND    ps.class||''                          = 'CM'
      and    ps.status = 'OP'   -- fixed a bug 5569664
      AND    ps.gl_date                           <= p_as_of_date;


   CURSOR party_credits IS
      SELECT NVL( SUM( DECODE(p_currency_code, NULL,
                              ps.acctd_amount_due_remaining,
                              ps.amount_due_remaining)), 0)
      FROM   ar_payment_schedules           ps,
             ra_cust_trx_line_gl_dist       gld,
             hz_cust_accounts               hzca
      WHERE  ps.customer_id                        = hzca.cust_account_id
      AND    hzca.party_id                         = p_filter_id
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
      and    ps.status = 'OP'   -- fixed a bug 5569664
      AND    ps.gl_date                           <= p_as_of_date;

   CURSOR party_paying_credits IS
      SELECT NVL( SUM( DECODE(p_currency_code, NULL,
                              ps.acctd_amount_due_remaining,
                              ps.amount_due_remaining)), 0)
      FROM   ar_payment_schedules           ps,
             ra_cust_trx_line_gl_dist       gld,
             hz_cust_accounts               hzca
      WHERE  ps.customer_id                        = hzca.cust_account_id
      AND    hzca.party_id                         IN
                            (SELECT p_filter_id FROM dual
                              UNION
                             SELECT ar.related_party_id
                               FROM ar_paying_relationships_v ar
                              WHERE ar.party_id = p_filter_id
                                AND TRUNC(sysdate) BETWEEN
                                    TRUNC(NVL(ar.effective_start_date,sysdate)) AND
                                    TRUNC(NVL(ar.effective_end_date,sysdate))  )
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
      and    ps.status = 'OP'   -- fixed a bug 5569664
      AND    ps.gl_date                           <= p_as_of_date;



BEGIN
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_credits: ' || l_line);
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage
                    ('IEX_AGING_BUCKETS_PKG.CALC_CREDITS --->>  Start <<--- ');
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_credits: ' || l_line);
    END IF;

    p_credits := 0;

    If p_filter_mode = 'PARTY' then
      IF NVL(p_using_paying_rel, 'N') = 'Y' THEN
       OPEN party_paying_credits;
       FETCH party_paying_credits INTO p_credits;
       Close party_paying_credits ;
      ELSE
       OPEN party_credits;
       FETCH party_credits INTO p_credits;
       Close party_credits ;
      END IF;
   elsif p_filter_mode = 'CUST' then
       OPEN cust_credits;
       FETCH cust_credits INTO p_credits;
       Close cust_credits ;
   elsif p_filter_mode = 'BILLTO' then
       OPEN cust_site_credits;
       FETCH cust_site_credits INTO p_credits;
       Close cust_site_credits ;
   End If ;
   --
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_credits: ' || l_line);
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage
                    ('IEX_AGING_BUCKETS_PKG.CALC_CREDITS --->>  End <<--- ');
    END IF;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('calc_credits: ' || l_line);
    END IF;

EXCEPTION
   WHEN OTHERS THEN
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logmessage('EXCEPTION: Iex_Aging_Buckets_Pkg.calc_credits');
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logmessage('calc_credits: ' || SQLCODE || ' --->  ' || SQLERRM);
        END IF;
        if cust_credits%ISOPEN then
            CLOSE cust_credits ;
        End If ;
        if party_credits%ISOPEN then
            CLOSE party_credits ;
        End If ;

--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('calc_credits: ' || l_line);
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage
         ('IEX_AGING_BUCKETS_PKG.CALC_CREDITS --->> End with Exception <<--- ');
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('calc_credits: ' || l_line);
        END IF;

END calc_credits;
--
--
--
    /*---------------------------------------------------------------------------
                        Procedure Calc_receipts
    ---------------------------------------------------------------------------*/
    PROCEDURE calc_receipts (
        p_filter_mode           IN  VARCHAR2,
        p_filter_id        	    IN  NUMBER,
        p_customer_site_use_id  IN  NUMBER,
        p_as_of_date         	IN  DATE,
        p_currency_code      	IN  VARCHAR2,
	    p_app_max_id		    IN  NUMBER ,
        p_using_paying_rel      IN  VARCHAR2,
        p_unapplied_cash     	OUT NOCOPY NUMBER,
	    p_onacct_cash	     	OUT NOCOPY NUMBER,
	    p_cash_claims	     	OUT NOCOPY NUMBER,
	    p_prepayments	     	OUT NOCOPY NUMBER)
    IS

        CURSOR party_unapplied_cash
        IS
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
        FROM    ar_receivable_applications        app,
                ar_payment_schedules              ps,
                hz_cust_accounts                  hzca
        WHERE   ps.customer_id                    = hzca.cust_account_id
        AND     hzca.party_id                     = p_filter_id
        AND     decode(p_customer_site_use_id,
                    NULL, nvl(ps.customer_site_use_id,-10),
                    p_customer_site_use_id)       = nvl(ps.customer_site_use_id,-10)
        AND     ps.cash_receipt_id                = app.cash_receipt_id
        AND     nvl( app.confirmed_flag, 'Y' )    = 'Y'
        AND     app.status                    in ( 'UNAPP', 'ACC' ,'OTHER ACC')
        AND     decode(upper(p_currency_code),
                    NULL, ps.invoice_currency_code,
                    upper(p_currency_code))        = ps.invoice_currency_code
        AND     app.gl_date                       <= p_as_of_date;

        CURSOR party_paying_unapplied_cash
        IS
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
        FROM    ar_receivable_applications        app,
                ar_payment_schedules              ps,
                hz_cust_accounts                  hzca
        WHERE   ps.customer_id                    = hzca.cust_account_id
        AND     hzca.party_id IN
                            (SELECT p_filter_id FROM dual
                              UNION
                             SELECT ar.related_party_id
                               FROM ar_paying_relationships_v ar
                              WHERE ar.party_id = p_filter_id
                                AND TRUNC(sysdate) BETWEEN
                                    TRUNC(NVL(ar.effective_start_date,sysdate)) AND
                                    TRUNC(NVL(ar.effective_end_date,sysdate))  )
        AND     decode(p_customer_site_use_id,
                    NULL, nvl(ps.customer_site_use_id,-10),
                    p_customer_site_use_id)       = nvl(ps.customer_site_use_id,-10)
        AND     ps.cash_receipt_id                = app.cash_receipt_id
        AND     nvl( app.confirmed_flag, 'Y' )    = 'Y'
        AND     app.status                    in ( 'UNAPP', 'ACC' ,'OTHER ACC')
        AND     decode(upper(p_currency_code),
                    NULL, ps.invoice_currency_code,
                    upper(p_currency_code))        = ps.invoice_currency_code
        AND     app.gl_date                       <= p_as_of_date;






        CURSOR cust_unapplied_cash
        IS
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
        FROM    ar_receivable_applications        app,
                ar_payment_schedules              ps
        WHERE   ps.customer_id                        = p_filter_id
        AND     decode(p_customer_site_use_id,
                    NULL, nvl(ps.customer_site_use_id,-10),
                    p_customer_site_use_id)    = nvl(ps.customer_site_use_id,-10)
        AND     ps.cash_receipt_id             = app.cash_receipt_id
        AND     nvl( app.confirmed_flag, 'Y' ) = 'Y'
        AND     app.status                     in ( 'UNAPP', 'ACC' ,'OTHER ACC')
        AND     decode(upper(p_currency_code),
                    NULL, ps.invoice_currency_code,
                    upper(p_currency_code))    = ps.invoice_currency_code
        AND     app.gl_date                    <= p_as_of_date;



        CURSOR cust_site_unapplied_cash
        IS
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
        FROM    ar_receivable_applications        app,
                ar_payment_schedules              ps
        WHERE   ps.customer_site_use_id            = p_filter_id
        AND     ps.cash_receipt_id             = app.cash_receipt_id
        AND     nvl( app.confirmed_flag, 'Y' ) = 'Y'
        AND     app.status                     in ( 'UNAPP', 'ACC' ,'OTHER ACC')
        AND     decode(upper(p_currency_code),
                    NULL, ps.invoice_currency_code,
                    upper(p_currency_code))    = ps.invoice_currency_code
        AND     app.gl_date                    <= p_as_of_date;

        --Bug4388111. Fixed By LKKUMAR. Need to Pouplate values for BILLTO. Start.
        CURSOR billto_unapplied_cash
        IS
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
        FROM    ar_receivable_applications        app,
                ar_payment_schedules              ps,
                hz_cust_site_uses                 hzsu,
                hz_cust_acct_sites                hzas
        WHERE   ps.customer_id                    = hzas.cust_account_id
        and     hzsu.cust_acct_site_id            = hzas.cust_acct_site_id
        AND     hzsu.site_use_id                  = ps.customer_site_use_id
        AND     ps.cash_receipt_id                = app.cash_receipt_id
        AND     hzsu.site_use_id                  = p_filter_id
        AND     decode(p_customer_site_use_id,
                    NULL, nvl(ps.customer_site_use_id,-10),
                    p_customer_site_use_id)       = nvl(ps.customer_site_use_id,-10)
        AND     ps.cash_receipt_id                = app.cash_receipt_id
        AND     nvl( app.confirmed_flag, 'Y' )    = 'Y'
        AND     app.status                    in ( 'UNAPP', 'ACC' ,'OTHER ACC')
        AND     decode(upper(p_currency_code),
                    NULL, ps.invoice_currency_code,
                    upper(p_currency_code))        = ps.invoice_currency_code
        AND     app.gl_date                       <= p_as_of_date;
        --Bug4388111. Fixed By LKKUMAR. Need to Pouplate values for BILLTO. End.
    BEGIN
        p_unapplied_cash := 0;
        p_onacct_cash := 0;

        If p_filter_mode = 'PARTY' then
          IF NVL(p_using_paying_rel, 'N') = 'Y' THEN
            OPEN  party_paying_unapplied_cash;
            FETCH party_paying_unapplied_cash
               INTO p_unapplied_cash, p_onacct_cash,p_cash_claims,p_prepayments;
            Close party_paying_unapplied_cash ;
          ELSE
            OPEN  party_unapplied_cash;
            FETCH party_unapplied_cash
               INTO p_unapplied_cash, p_onacct_cash,p_cash_claims,p_prepayments;
            Close party_unapplied_cash ;
          END IF;
        elsif p_filter_mode = 'CUST' then
            OPEN  cust_unapplied_cash;
            FETCH cust_unapplied_cash
               INTO p_unapplied_cash, p_onacct_cash,p_cash_claims,p_prepayments;
            Close cust_unapplied_cash ;
        --Bug4388111. Fixed By LKKUMAR. Need to Pouplate values for BILLTO. Start.
        elsif p_filter_mode = 'BILLTO' then
            OPEN  billto_unapplied_cash;
            FETCH billto_unapplied_cash
               INTO p_unapplied_cash, p_onacct_cash,p_cash_claims,p_prepayments;
            Close billto_unapplied_cash ;
        --Bug4388111. Fixed By LKKUMAR. Need to Pouplate values for BILLTO. Start.
        End If ;

    EXCEPTION
        WHEN OTHERS THEN
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage
                            ('EXCEPTION: Iex_Aging_Buckets_Pkg.calc_receipts');
            END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logmessage('calc_receipts: ' || SQLCODE || ' --->  ' || SQLERRM);
        END IF;
        if cust_unapplied_cash%ISOPEN then
            CLOSE cust_unapplied_cash ;
        End If ;
        if party_unapplied_cash%ISOPEN then
            CLOSE party_unapplied_cash ;
        End If ;

--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('calc_receipts: ' || l_line);
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage
         ('IEX_AGING_BUCKETS_PKG.CALC_RECEIPTS --->> End with Exception <<---');
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('calc_receipts: ' || l_line);
        END IF;
    END calc_receipts;
--
--
--
    PROCEDURE calc_risk_receipts (
        p_filter_mode           IN Varchar2,
        p_filter_id        	IN NUMBER,
        p_customer_site_use_id 	IN NUMBER,
        p_as_of_date        IN DATE,
        p_currency_code     IN VARCHAR2,
        p_ps_max_id		    IN NUMBER,
        p_using_paying_rel  IN VARCHAR2,
	    p_risk_receipts	    OUT NOCOPY NUMBER
    ) IS
     CURSOR cust_risk_receipts IS
      SELECT NVL( SUM( DECODE(p_currency_code, NULL, crh.acctd_amount,
                              crh.amount)), 0)
      FROM   ar_cash_receipts             cr,
             ar_cash_receipt_history      crh
      WHERE  cr.pay_from_customer = p_filter_id
        /* bug no : 1274152. Aging form did not consider the receipts done
        without customer location for the calculation of receipt at risk.
        NVL is added for ps.customer_site_use_id in the procedure
        calc_risk_receipts to avoid null = null comparison fixed by rajsrini */
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

     CURSOR party_risk_receipts IS
      SELECT NVL( SUM( DECODE(p_currency_code, NULL, crh.acctd_amount,
                              crh.amount)), 0)
      FROM   ar_cash_receipts             cr,
             ar_cash_receipt_history      crh,
             hz_cust_accounts             hzca
      WHERE  cr.pay_from_customer = hzca.cust_account_id
      AND    hzca.party_id = p_filter_id
        /* bug no : 1274152. Aging form did not consider the receipts done
        without customer location for the calculation of receipt at risk.
        NVL is added for ps.customer_site_use_id in the procedure
        calc_risk_receipts to avoid null = null comparison fixed by rajsrini */
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

     CURSOR party_paying_risk_receipts IS
      SELECT NVL( SUM( DECODE(p_currency_code, NULL, crh.acctd_amount,
                              crh.amount)), 0)
      FROM   ar_cash_receipts             cr,
             ar_cash_receipt_history      crh,
             hz_cust_accounts             hzca
      WHERE  cr.pay_from_customer = hzca.cust_account_id
      AND    hzca.party_id IN
                            (SELECT p_filter_id FROM dual
                              UNION
                             SELECT ar.related_party_id
                               FROM ar_paying_relationships_v ar
                              WHERE ar.party_id = p_filter_id
                                AND TRUNC(sysdate) BETWEEN
                                    TRUNC(NVL(ar.effective_start_date,sysdate)) AND
                                    TRUNC(NVL(ar.effective_end_date,sysdate))  )
        /* bug no : 1274152. Aging form did not consider the receipts done
        without customer location for the calculation of receipt at risk.
        NVL is added for ps.customer_site_use_id in the procedure
        calc_risk_receipts to avoid null = null comparison fixed by rajsrini */
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

     CURSOR cust_site_risk_receipts IS
      SELECT NVL( SUM( DECODE(p_currency_code, NULL, crh.acctd_amount,
                              crh.amount)), 0)
      FROM   ar_cash_receipts             cr,
             ar_cash_receipt_history      crh,
     /* begin add for bug 4930373 to use AR_CASH_RECEIPTS_N2 */
             hz_cust_acct_sites_all acct_site,
                  hz_cust_site_uses_all site_uses,
                  hz_cust_accounts_all cust_acct
     /* end add for bug 4930373 to use AR_CASH_RECEIPTS_N2 */
      WHERE  cr.customer_site_use_id = p_filter_id
        /* bug no : 1274152. Aging form did not consider the receipts done
        without customer location for the calculation of receipt at risk.
        NVL is added for ps.customer_site_use_id in the procedure
        calc_risk_receipts to avoid null = null comparison fixed by rajsrini */
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
                         and   rap.display = 'Y')
     /* begin add for bug 4930373 to use AR_CASH_RECEIPTS_N2 */
     and site_uses.site_use_id = p_filter_id
     AND  acct_site.cust_acct_site_id = site_uses.cust_acct_site_id
     and cust_acct.cust_account_id  = acct_site.cust_account_id
     and  cust_acct.party_id = cr.pay_from_customer;
     /* end add for bug 4930373 to use AR_CASH_RECEIPTS_N2 */


BEGIN

--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('calc_risk_receipts: ' || l_line);
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage
                    ('IEX_AGING_BUCKETS_PKG.CALC_risk_receipts --->>  Start <<--- ');
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('calc_risk_receipts: ' || l_line);
        END IF;

        p_risk_receipts := 0;

        If p_filter_mode = 'PARTY' then
          IF NVL(p_using_paying_rel, 'N') = 'Y' THEN
            OPEN party_paying_risk_receipts;
            FETCH party_paying_risk_receipts INTO p_risk_receipts;
            Close party_paying_risk_receipts ;
          ELSE
            OPEN party_risk_receipts;
            FETCH party_risk_receipts INTO p_risk_receipts;
            Close party_risk_receipts ;
          END IF;
        elsif p_filter_mode = 'CUST' then
            OPEN cust_risk_receipts;
            FETCH cust_risk_receipts INTO p_risk_receipts;
            Close cust_risk_receipts ;
        elsif p_filter_mode = 'BILLTO' then
            OPEN cust_site_risk_receipts;
            FETCH cust_site_risk_receipts INTO p_risk_receipts;
            Close cust_site_risk_receipts ;
        End If ;
        --
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('calc_risk_receipts: ' || l_line);
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage
                    ('IEX_AGING_BUCKETS_PKG.CALC_risk_receipts --->>  End <<--- ');
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('calc_risk_receipts: ' || l_line);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage('EXCEPTION: Iex_Aging_Buckets_Pkg.calc_risk_receipts');
            END IF;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage('calc_risk_receipts: ' || SQLCODE || ' --->  ' || SQLERRM);
            END IF;
            if cust_risk_receipts%ISOPEN then
                CLOSE cust_risk_receipts ;
            End If ;
            if party_risk_receipts%ISOPEN then
                CLOSE party_risk_receipts ;
            End If ;

--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LogMessage('calc_risk_receipts: ' || l_line);
            END IF;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LogMessage
                ('IEX_AGING_BUCKETS_PKG.CALC_risk_receipts --->> End with Exception <<--- ');
            END IF;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LogMessage('calc_risk_receipts: ' || l_line);
            END IF;

    END calc_risk_receipts;
--
--
--
    /*---------------------------------------------------------------------------
                        Procedure Calc_Dispute
    ---------------------------------------------------------------------------*/
    PROCEDURE calc_dispute
        (p_filter_mode       IN  VARCHAR2,
        p_filter_id             IN  NUMBER,
        p_customer_site_use_id  IN  NUMBER,
        p_as_of_date            IN  DATE,
        p_currency_code         IN  VARCHAR2,
        p_ps_max_id             IN  NUMBER,
        p_using_paying_rel      IN  VARCHAR2,
        p_dispute               OUT NOCOPY NUMBER)
    IS

        CURSOR cust_dispute IS
        SELECT NVL(SUM(decode(p_currency_code, NULL,
          ROUND(ps.amount_in_dispute * nvl(ps.exchange_rate,1),l_round_decimal),
                ps.amount_in_dispute)),0)
        FROM   ar_payment_schedules ps
        WHERE  ps.customer_id                        = p_filter_id
        AND    decode(p_customer_site_use_id,
                    NULL, ps.customer_site_use_id,
                    p_customer_site_use_id)        = ps.customer_site_use_id
        AND    decode(upper(p_currency_code),
                    NULL, ps.invoice_currency_code,
                    upper(p_currency_code))        = ps.invoice_currency_code
        --AND    ps.due_date                          <= p_as_of_date  --Commented for bug#7044352 on 23-May-2008 by SCHEKURI
        AND    nvl( ps.amount_in_dispute, 0 )       <> 0
        and    ps.amount_due_remaining > 0  -- fixed a bug 5473635
        and    ps.status = 'OP'   -- fixed a bug 5569664
        AND    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y' ;


        CURSOR cust_site_dispute IS
        SELECT NVL(SUM(decode(p_currency_code, NULL,
          ROUND(ps.amount_in_dispute * nvl(ps.exchange_rate,1),l_round_decimal),
                ps.amount_in_dispute)),0)
        FROM   ar_payment_schedules ps
        WHERE  ps.customer_site_use_id     = p_filter_id
        AND    decode(upper(p_currency_code),
                    NULL, ps.invoice_currency_code,
                    upper(p_currency_code))        = ps.invoice_currency_code
        --AND    ps.due_date                          <= p_as_of_date  --Commented for bug#7044352 on 23-May-2008 by SCHEKURI
        AND    nvl( ps.amount_in_dispute, 0 )       <> 0
	    --- Begin - Andre Araujo - 11/09/2004 - Performance fix we will select the aging separately
        AND    ps.status                             = 'OP'
	    --- End - Andre Araujo - 11/09/2004 - Performance fix we will select the aging separately
        and    ps.amount_due_remaining > 0  -- fixed a bug 5473635
        AND    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y' ;


        CURSOR party_dispute IS
        SELECT NVL(SUM(decode(p_currency_code, NULL,
          ROUND(ps.amount_in_dispute * nvl(ps.exchange_rate,1),l_round_decimal),
                ps.amount_in_dispute)),0)
        FROM   ar_payment_schedules ps,
             hz_cust_accounts   hzca
        WHERE  ps.customer_id                        = hzca.cust_Account_id
        AND    hzca.party_id                         = p_filter_id
        AND    decode(p_customer_site_use_id,
                    NULL, ps.customer_site_use_id,
                    p_customer_site_use_id)        = ps.customer_site_use_id
        AND    decode(upper(p_currency_code),
                    NULL, ps.invoice_currency_code,
                    upper(p_currency_code))        = ps.invoice_currency_code
        --AND    ps.due_date                          <= p_as_of_date   --Commented for bug#7044352 on 23-May-2008 by SCHEKURI
        AND    nvl( ps.amount_in_dispute, 0 )       <> 0
        and    ps.amount_due_remaining > 0  -- fixed a bug 5473635
        and    ps.status = 'OP'   -- fixed a bug 5569664
        AND    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y'  ;

        CURSOR party_paying_dispute IS
        SELECT NVL(SUM(decode(p_currency_code, NULL,
          ROUND(ps.amount_in_dispute * nvl(ps.exchange_rate,1),l_round_decimal),
                ps.amount_in_dispute)),0)
        FROM   ar_payment_schedules ps,
             hz_cust_accounts   hzca
        WHERE  ps.customer_id                        = hzca.cust_Account_id
        AND    hzca.party_id  IN
                            (SELECT p_filter_id FROM dual
                              UNION
                             SELECT ar.related_party_id
                               FROM ar_paying_relationships_v ar
                              WHERE ar.party_id = p_filter_id
                                AND TRUNC(sysdate) BETWEEN
                                    TRUNC(NVL(ar.effective_start_date,sysdate)) AND
                                    TRUNC(NVL(ar.effective_end_date,sysdate))  )
        AND    decode(p_customer_site_use_id,
                    NULL, ps.customer_site_use_id,
                    p_customer_site_use_id)        = ps.customer_site_use_id
        AND    decode(upper(p_currency_code),
                    NULL, ps.invoice_currency_code,
                    upper(p_currency_code))        = ps.invoice_currency_code
        --AND    ps.due_date                          <= p_as_of_date  --Commented for bug#7044352 on 23-May-2008 by SCHEKURI
        AND    nvl( ps.amount_in_dispute, 0 )       <> 0
        and    ps.amount_due_remaining > 0  -- fixed a bug 5473635
        and    ps.status = 'OP'   -- fixed a bug 5569664
        AND    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y'  ;




    BEGIN
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('calc_dispute: ' || l_line);
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage
                    ('IEX_AGING_BUCKETS_PKG.CALC_DISPUTE --->>  Start <<--- ');
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('calc_dispute: ' || l_line);
        END IF;

        p_dispute := 0;

        If p_filter_mode = 'PARTY' then
          IF NVL(p_using_paying_rel, 'N') = 'Y' THEN
            OPEN party_paying_dispute;
            FETCH party_paying_dispute INTO p_dispute;
            Close party_paying_dispute ;
          ELSE
            OPEN party_dispute;
            FETCH party_dispute INTO p_dispute;
            Close party_dispute ;
          END IF;
        elsif p_filter_mode = 'CUST' then
            OPEN cust_dispute;
            FETCH cust_dispute INTO p_dispute;
            Close cust_dispute ;
        elsif p_filter_mode = 'BILLTO' then
            OPEN cust_site_dispute;
            FETCH cust_site_dispute INTO p_dispute;
            Close cust_site_dispute ;
        End If ;
        --
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('calc_dispute: ' || l_line);
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage
                    ('IEX_AGING_BUCKETS_PKG.CALC_dispute --->>  End <<--- ');
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('calc_dispute: ' || l_line);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage('EXCEPTION: Iex_Aging_Buckets_Pkg.calc_dispute');
            END IF;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage('calc_dispute: ' || SQLCODE || ' --->  ' || SQLERRM);
            END IF;
            if cust_dispute%ISOPEN then
                CLOSE cust_dispute ;
            End If ;
            if party_dispute%ISOPEN then
                CLOSE party_dispute ;
            End If ;

--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LogMessage('calc_dispute: ' || l_line);
            END IF;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LogMessage
                ('IEX_AGING_BUCKETS_PKG.CALC_dispute --->> End with Exception <<--- ');
            END IF;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LogMessage('calc_dispute: ' || l_line);
            END IF;
    END calc_dispute;
--
--
--

    PROCEDURE calc_adj_fin_charges(
        p_filter_mode           IN Varchar2,
        p_filter_id             IN NUMBER,
        p_customer_site_use_id  IN NUMBER,
        p_as_of_date            IN DATE,
        p_currency_code         IN VARCHAR2,
        p_ps_max_id             IN NUMBER,
        p_using_paying_rel      IN VARCHAR2,
        p_adj                   OUT NOCOPY NUMBER,
        p_pending_adj           OUT NOCOPY NUMBER,
        p_fin_charges           OUT NOCOPY NUMBER
)
    IS

        CURSOR cust_adj IS
            SELECT
             ROUND(NVL(SUM(ps.amount_adjusted *
                               NVL(ps.exchange_rate, 1)),0), l_round_decimal),
             ROUND(NVL(SUM(ps.amount_adjusted_pending *
                               NVL(ps.exchange_rate, 1)),0), l_round_decimal)
            FROM   ar_payment_schedules ps
            WHERE  ps.customer_id                  = p_filter_id
            AND    decode(p_customer_site_use_id,
                    NULL, ps.customer_site_use_id,
                    p_customer_site_use_id)        = ps.customer_site_use_id
            AND    decode(upper(p_currency_code),
                    NULL, ps.invoice_currency_code,
                    upper(p_currency_code))        = ps.invoice_currency_code
        --    AND    ps.due_date                          <= p_as_of_date commented for bug#7418862 by PNAVEENK on 21-OCT-2008
            AND    (nvl( ps.amount_adjusted_pending, 0 ) <> 0
                    OR
                    nvl( ps.amount_adjusted, 0 ) <> 0)
            and    ps.status = 'OP'   -- fixed a bug 5569664
            AND    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y';

        CURSOR party_adj IS
            SELECT
             ROUND(NVL(SUM(ps.amount_adjusted *
                               NVL(ps.exchange_rate, 1)),0), l_round_decimal),
             ROUND(NVL(SUM(ps.amount_adjusted_pending *
                               NVL(ps.exchange_rate, 1)),0), l_round_decimal)
            FROM   ar_payment_schedules ps,
                   hz_cust_accounts hzca
            WHERE  ps.customer_id                  = hzca.cust_account_id
            AND    hzca.party_id                   = p_filter_id
            AND    decode(p_customer_site_use_id,
                    NULL, ps.customer_site_use_id,
                    p_customer_site_use_id)        = ps.customer_site_use_id
            AND    decode(upper(p_currency_code),
                    NULL, ps.invoice_currency_code,
                    upper(p_currency_code))        = ps.invoice_currency_code
     --       AND    ps.due_date                          <= p_as_of_date  commented for bug#7418862 by PNAVEENK on 21-OCT-2008
            AND    (nvl( ps.amount_adjusted_pending, 0 ) <> 0
                    OR
                    nvl( ps.amount_adjusted, 0 ) <> 0)
            and    ps.status = 'OP'   -- fixed a bug 5569664
            AND    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y';

        CURSOR party_paying_adj IS
            SELECT
             ROUND(NVL(SUM(ps.amount_adjusted *
                               NVL(ps.exchange_rate, 1)),0), l_round_decimal),
             ROUND(NVL(SUM(ps.amount_adjusted_pending *
                               NVL(ps.exchange_rate, 1)),0), l_round_decimal)
            FROM   ar_payment_schedules ps,
                   hz_cust_accounts hzca
            WHERE  ps.customer_id                  = hzca.cust_account_id
            AND    hzca.party_id  IN
                            (SELECT p_filter_id FROM dual
                              UNION
                             SELECT ar.related_party_id
                               FROM ar_paying_relationships_v ar
                              WHERE ar.party_id = p_filter_id
                                AND TRUNC(sysdate) BETWEEN
                                    TRUNC(NVL(ar.effective_start_date,sysdate)) AND
                                    TRUNC(NVL(ar.effective_end_date,sysdate))  )
            AND    decode(p_customer_site_use_id,
                    NULL, ps.customer_site_use_id,
                    p_customer_site_use_id)        = ps.customer_site_use_id
            AND    decode(upper(p_currency_code),
                    NULL, ps.invoice_currency_code,
                    upper(p_currency_code))        = ps.invoice_currency_code
    --        AND    ps.due_date                          <= p_as_of_date  commented for bug#7418862 by PNAVEENK on 21-OCT-2008
            AND    (nvl( ps.amount_adjusted_pending, 0 ) <> 0
                    OR
                    nvl( ps.amount_adjusted, 0 ) <> 0)
            and    ps.status = 'OP'   -- fixed a bug 5569664
            AND    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y';


        CURSOR cust_site_adj IS
            SELECT
             ROUND(NVL(SUM(ps.amount_adjusted *
                               NVL(ps.exchange_rate, 1)),0), l_round_decimal),
             ROUND(NVL(SUM(ps.amount_adjusted_pending *
                               NVL(ps.exchange_rate, 1)),0), l_round_decimal)
            FROM   ar_payment_schedules ps
            WHERE  ps.customer_site_use_id   = p_filter_id
	        --- Begin - Andre Araujo - 11/09/2004 - Performance fix
            AND    ps.status = 'OP'
	        --- End - Andre Araujo - 11/09/2004 - Performance fix
            AND    decode(upper(p_currency_code),
                    NULL, ps.invoice_currency_code,
                    upper(p_currency_code))        = ps.invoice_currency_code
       --     AND    ps.due_date                          <= p_as_of_date  commented for bug#7418862 by PNAVEENK on 21-OCT-2008
            AND    (nvl( ps.amount_adjusted_pending, 0 ) <> 0
                    OR
                    nvl( ps.amount_adjusted, 0 ) <> 0)
            and    ps.status = 'OP'   -- fixed a bug 5569664
            AND    nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y';


        CURSOR cust_fin_charges IS
            SELECT
             ROUND(NVL(SUM( ps.receivables_charges_charged
                                 * NVL(ps.exchange_rate,1)),0),l_round_decimal)
            FROM   ar_payment_schedules ps
            WHERE  ps.customer_id                  = p_filter_id
            AND    decode(p_customer_site_use_id,
                    NULL, ps.customer_site_use_id,
                    p_customer_site_use_id)        = ps.customer_site_use_id
            AND    decode(upper(p_currency_code),
                    NULL, ps.invoice_currency_code,
                    upper(p_currency_code))        = ps.invoice_currency_code
     --       AND    ps.due_date                          <= p_as_of_date  commented for bug#7418916 by PNAVEENK on 20-OCT-2008
	        --- Begin - Andre Araujo - 11/09/2004 - Performance fix
            AND    ps.status = 'OP'
	        --- End - Andre Araujo - 11/09/2004 - Performance fix
            AND    nvl(ps.receivables_charges_charged, 0 ) <> 0 ;

        CURSOR party_fin_charges IS
            SELECT
             ROUND(NVL(SUM( ps.receivables_charges_charged
                                 * NVL(ps.exchange_rate,1)),0),l_round_decimal)
            FROM   ar_payment_schedules ps,
                   hz_cust_accounts hzca
            WHERE  ps.customer_id                  = hzca.cust_account_id
	        --- Begin - Andre Araujo - 11/09/2004 - Performance fix
            AND    ps.status = 'OP'
	        --- End - Andre Araujo - 11/09/2004 - Performance fix
            AND    hzca.party_id                   = p_filter_id
            AND    decode(p_customer_site_use_id,
                    NULL, ps.customer_site_use_id,
                    p_customer_site_use_id)        = ps.customer_site_use_id
            AND    decode(upper(p_currency_code),
                    NULL, ps.invoice_currency_code,
                    upper(p_currency_code))        = ps.invoice_currency_code
         --   AND    ps.due_date                          <= p_as_of_date  commented for bug#7418916 by PNAVEENK on 20-OCT-2008
            AND    nvl(ps.receivables_charges_charged, 0 ) <> 0 ;

        CURSOR party_paying_fin_charges IS
            SELECT
             ROUND(NVL(SUM( ps.receivables_charges_charged
                                 * NVL(ps.exchange_rate,1)),0),l_round_decimal)
            FROM   ar_payment_schedules ps,
                   hz_cust_accounts hzca
            WHERE  ps.customer_id                  = hzca.cust_account_id
            AND    hzca.party_id IN
                            (SELECT p_filter_id FROM dual
                              UNION
                             SELECT ar.related_party_id
                               FROM ar_paying_relationships_v ar
                              WHERE ar.party_id = p_filter_id
                                AND TRUNC(sysdate) BETWEEN
                                    TRUNC(NVL(ar.effective_start_date,sysdate)) AND
                                    TRUNC(NVL(ar.effective_end_date,sysdate))  )
            AND    decode(p_customer_site_use_id,
                    NULL, ps.customer_site_use_id,
                    p_customer_site_use_id)        = ps.customer_site_use_id
            AND    decode(upper(p_currency_code),
                    NULL, ps.invoice_currency_code,
                    upper(p_currency_code))        = ps.invoice_currency_code
	        --- Begin - Andre Araujo - 11/09/2004 - Performance fix
            AND    ps.status = 'OP'
	        --- End - Andre Araujo - 11/09/2004 - Performance fix
          --  AND    ps.due_date                          <= p_as_of_date   commented for bug#7418916 by PNAVEENK on 20-OCT-2008
            AND    nvl(ps.receivables_charges_charged, 0 ) <> 0 ;

        CURSOR cust_site_fin_charges IS
            SELECT
             ROUND(NVL(SUM( ps.receivables_charges_charged
                                 * NVL(ps.exchange_rate,1)),0),l_round_decimal)
            FROM   ar_payment_schedules ps
            WHERE  ps.customer_site_use_id   = p_filter_id
            AND    decode(upper(p_currency_code),
                    NULL, ps.invoice_currency_code,
                    upper(p_currency_code))        = ps.invoice_currency_code
	        --- Begin - Andre Araujo - 11/09/2004 - Performance fix
            AND    ps.status = 'OP'
	        --- End - Andre Araujo - 11/09/2004 - Performance fix
        --    AND    ps.due_date                          <= p_as_of_date    commented for bug#7418916 by PNAVEENK on 20-OCT-2008
            AND    nvl(ps.receivables_charges_charged, 0 ) <> 0 ;

    BEGIN

--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('calc_adj_fin_charges: ' || l_line);
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage
                    ('calc_adj_fin_charges: ' || 'IEX_AGING_BUCKETS_PKG.CALC_PENDING_ADJ --->>  Start <<--- ');
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('calc_adj_fin_charges: ' || l_line);
        END IF;

        p_pending_adj := 0;

        If p_filter_mode = 'PARTY' then
          IF NVL(p_using_paying_rel, 'N') = 'Y' THEN
            OPEN party_paying_adj;
            FETCH party_paying_adj
            INTO   p_adj,
                   p_pending_adj ;
            Close party_paying_adj ;

            OPEN party_paying_fin_charges;
            FETCH party_paying_fin_charges
            INTO   p_fin_charges ;
            Close party_paying_fin_charges ;
          ELSE
            OPEN party_adj;
            FETCH party_adj
            INTO   p_adj,
                   p_pending_adj ;
            Close party_adj ;

            OPEN party_fin_charges;
            FETCH party_fin_charges
            INTO   p_fin_charges ;
            Close party_fin_charges ;
          END IF;

        elsif p_filter_mode = 'CUST' then
            OPEN cust_adj;
            FETCH cust_adj
            INTO   p_adj,
                   p_pending_adj ;
            Close cust_adj ;

            OPEN cust_fin_charges;
            FETCH cust_fin_charges
            INTO   p_fin_charges ;
            Close cust_fin_charges ;
        elsif p_filter_mode = 'BILLTO' then
            OPEN cust_site_adj;
            FETCH cust_site_adj
            INTO   p_adj,
                   p_pending_adj ;
            Close cust_site_adj ;

            OPEN cust_site_fin_charges;
            FETCH cust_site_fin_charges
            INTO   p_fin_charges ;
            Close cust_site_fin_charges ;

        End If ;
        --
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('calc_adj_fin_charges: ' || l_line);
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage
                    ('calc_adj_fin_charges: ' || 'IEX_AGING_BUCKETS_PKG.CALC_pending_adj --->>  End <<--- ');
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('calc_adj_fin_charges: ' || l_line);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage('calc_adj_fin_charges: ' || 'EXCEPTION: Iex_Aging_Buckets_Pkg.calc_pending_adj');
            END IF;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               iex_debug_pub.logmessage('calc_adj_fin_charges: ' || SQLCODE || ' --->  ' || SQLERRM);
            END IF;

            if cust_adj%ISOPEN then
                CLOSE cust_adj ;
            End If ;
            if party_adj%ISOPEN then
                CLOSE party_adj ;
            End If ;

            if cust_fin_charges%ISOPEN then
                CLOSE cust_fin_charges ;
            End If ;
            if party_fin_charges%ISOPEN then
                CLOSE party_fin_charges ;
            End If ;



--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LogMessage('calc_adj_fin_charges: ' || l_line);
            END IF;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LogMessage
                ('calc_adj_fin_charges: ' || 'IEX_AGING_BUCKETS_PKG.CALC_pending_adj --->> End with Exception <<--- ');
            END IF;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LogMessage('calc_adj_fin_charges: ' || l_line);
            END IF;

    END calc_adj_fin_charges;



    /*------------------------------------------------------------------------
                        PROCEDURE   QUERY_AGING_LINES
        Main Procedure to list Aging Bucket Lines. This Calls the Procedure
        CALC_AGING_BUCKETS to get the bucket level amounts. This Procedure
        is Called from the Aging Tab for IEXAGTAB to populate the aging grid
    ------------------------------------------------------------------------*/
	PROCEDURE QUERY_AGING_LINES
       	(p_api_version     IN  NUMBER := 1.0,
            p_init_msg_list    IN  VARCHAR2,
            p_commit           IN  VARCHAR2,
            p_validation_level IN  NUMBER,
            x_return_status    IN OUT NOCOPY VARCHAR2,
            x_msg_count        IN OUT NOCOPY NUMBER,
            x_msg_data         IN OUT NOCOPY VARCHAR2,
            p_filter_mode      IN Varchar2,
	      p_filter_id        IN Number,
            p_customer_site_use_id IN Number,
            p_bucket_id        IN Number    ,
            p_credit_option    IN Varchar2,
            p_using_paying_rel IN VARCHAR2,
            x_bucket_lines_tbl  IN OUT NOCOPY bucket_lines_tbl	)
    IS
        l_api_version CONSTANT  NUMBER :=  1.0;
        l_api_name    CONSTANT  VARCHAR2(30) :=  'Query_Aging_Lines';
        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(32767);
	    l_cnt 				    Number	:= 1			;
	    v_aging_summary_cur 	Profile_cur 			;
	    v_aging_summary_sql		Varchar2(5000)			;
	    v_aging_summary_select_rec 	Aging_Summary_Select_Rec 	;
	    v_aging_bucket_line_id	Number				;
	    v_dispute_count			Number				;

	    v_currency		        Varchar2(10)			;
	    v_msg_data		        Varchar2(100) 			;
	    v_return_status	        Varchar2(100)		;
	    v_msg_count		        Number				;

        -- Added by Surya on 7/30/03
        -- This cust account is derived only in case of filter mode bill to
        v_billto_cust_account_id    Number ;

        -- These contains either above found cust_account_id or the bill to id
        -- based on the filter_mode
        v_filter_id1                Number ;
        v_filter_id2                Number ;

        ------------------------------------------------------------------
        --                  API Main Parameter Variables
        ------------------------------------------------------------------
	    l_outstanding_balance	NUMBER 	:= 0    ;

        l_bucket_line_id_0       NUMBER   	    ;
        l_bucket_seq_num_0       NUMBER     	;
        l_bucket_titletop_0	    Varchar2(15)  	;
        l_bucket_titlebottom_0	Varchar2(15) 	;
        l_bucket_amount_0       NUMBER  := 0 	;

        l_bucket_line_id_1       NUMBER   	    ;
        l_bucket_seq_num_1       NUMBER     	;
        l_bucket_titletop_1	    Varchar2(15) 	;
        l_bucket_titlebottom_1	Varchar2(15) 	;
        l_bucket_amount_1       NUMBER  := 0    ;

        l_bucket_line_id_2       NUMBER   	    ;
        l_bucket_seq_num_2       NUMBER     	;
        l_bucket_titletop_2	    Varchar2(15) 	;
        l_bucket_titlebottom_2	Varchar2(15) 	;
        l_bucket_amount_2       NUMBER  := 0    ;

        l_bucket_line_id_3       NUMBER   	    ;
        l_bucket_seq_num_3       NUMBER     	;
        l_bucket_titletop_3	    Varchar2(15) 	;
        l_bucket_titlebottom_3	Varchar2(15) 	;
        l_bucket_amount_3       NUMBER  := 0    ;

        l_bucket_line_id_4       NUMBER   	    ;
        l_bucket_seq_num_4       NUMBER     	;
        l_bucket_titletop_4	    Varchar2(15) 	;
        l_bucket_titlebottom_4	Varchar2(15) 	;
        l_bucket_amount_4       NUMBER  := 0    ;

        l_bucket_line_id_5       NUMBER   	    ;
        l_bucket_seq_num_5       NUMBER     	;
        l_bucket_titletop_5	    Varchar2(15) 	;
        l_bucket_titlebottom_5	Varchar2(15) 	;
        l_bucket_amount_5       NUMBER  := 0    ;

        l_bucket_line_id_6       NUMBER   	    ;
        l_bucket_seq_num_6       NUMBER     	;
        l_bucket_titletop_6	    Varchar2(15) 	;
        l_bucket_titlebottom_6	Varchar2(15) 	;
        l_bucket_amount_6       NUMBER  := 0    ;



        -- Collectible Amount Variables
	    TYPE collectible_bkt_id_tbl  IS TABLE OF Number Index By Binary_Integer;
	    TYPE collectible_bkt_amt_tbl IS TABLE OF Number Index By Binary_Integer;
        Bkt_cnt                 Number := 0     ;

        l_collectible_bkt_id_tbl   collectible_bkt_id_tbl   ;
        l_collectible_bkt_amt_tbl  collectible_bkt_amt_tbl  ;

	l_collect_dispute_amt number; 	--Added for bug 6701396 gnramasa 4th Mar 08


        -- Grid Total Variables
        -- ====================
        l_total_rec             Number   := 0   ;
        l_total_amount          Number   := 0   ;
        l_total_invoices        Number   := 0   ;
        l_total_inv_amount      Number   := 0   ;
        l_total_coll_amount     Number   := 0   ;
        l_total_chargebacks     Number   := 0   ;
        l_total_cb_amount       Number   := 0   ;
        l_total_debit_memos     Number   := 0   ;
        l_total_dm_amount       Number   := 0   ;
        l_total_disputes        Number   := 0   ;
        l_total_cnsld_invoices  Number   := 0   ;
        l_total_disp_amount     Number   := 0   ;

        ------------------------------------------------------------------
        -- API Temporary Parameter Variables(Used only in  party mode)
        ------------------------------------------------------------------
	    lt_outstanding_balance	    NUMBER 	        ;

        lt_bucket_line_id_0       NUMBER   	    ;
        lt_bucket_seq_num_0       NUMBER     	;
        lt_bucket_titletop_0	  Varchar2(15) 	;
        lt_bucket_titlebottom_0	  Varchar2(15) 	;
        lt_bucket_amount_0        NUMBER          ;

        lt_bucket_line_id_1       NUMBER   	    ;
        lt_bucket_seq_num_1       NUMBER     	;
        lt_bucket_titletop_1	  Varchar2(15) 	;
        lt_bucket_titlebottom_1	  Varchar2(15) 	;
        lt_bucket_amount_1        NUMBER          ;

        lt_bucket_line_id_2       NUMBER   	    ;
        lt_bucket_seq_num_2       NUMBER     	;
        lt_bucket_titletop_2	  Varchar2(15) 	;
        lt_bucket_titlebottom_2	  Varchar2(15) 	;
        lt_bucket_amount_2        NUMBER          ;

        lt_bucket_line_id_3       NUMBER   	    ;
        lt_bucket_seq_num_3       NUMBER     	;
        lt_bucket_titletop_3	  Varchar2(15) 	;
        lt_bucket_titlebottom_3	  Varchar2(15) 	;
        lt_bucket_amount_3        NUMBER          ;

        lt_bucket_line_id_4       NUMBER   	    ;
        lt_bucket_seq_num_4       NUMBER     	;
        lt_bucket_titletop_4	  Varchar2(15) 	;
        lt_bucket_titlebottom_4	  Varchar2(15) 	;
        lt_bucket_amount_4        NUMBER          ;

        lt_bucket_line_id_5       NUMBER   	    ;
        lt_bucket_seq_num_5       NUMBER     	;
        lt_bucket_titletop_5	  Varchar2(15) 	;
        lt_bucket_titlebottom_5	  Varchar2(15) 	;
        lt_bucket_amount_5        NUMBER          ;

        lt_bucket_line_id_6       NUMBER   	    ;
        lt_bucket_seq_num_6       NUMBER     	;
        lt_bucket_titletop_6	  Varchar2(15) 	;
        lt_bucket_titlebottom_6	  Varchar2(15) 	;
        lt_bucket_amount_6        NUMBER          ;


        l_count                 Number :=  1 ;

        -- Used to store fetched cust_account_ids for the passed party_id
        l_customer_id           Number          ;

        -- Dummy declaration to get consolidated invoice amount. Amount not
        -- derived at this time. Will be implemented later, if required
        l_cons_amount   Number := 0 ;
    Begin
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES: ' || l_line);
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES --->>  Start <<--- ');
        END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES: ' || l_line);
        END IF;


        SAVEPOINT Query_Aging_lines;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Check p_init_msg_list
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;


        -- Sysdate-1 is passed to follow AR API aging calculation.
	-- Modified by Surya on 02/03/03. Bug # 2754557
        Select  TRUNC(sysdate)
        into    l_date
        from dual ;


--		IF PG_DEBUG < 10  THEN
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		   IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES: ' || 'Bucket Id >> ' || p_bucket_id );
		END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

	    IEX_CURRENCY_PVT.GET_FUNCT_CURR(
		         P_API_VERSION =>1.0,
                 p_init_msg_list => 'T',
                 p_commit  => 'F',
                 p_validation_level => 100,
                 X_Functional_currency => v_currency,
		         X_return_status => v_return_status,
                 X_MSG_COUNT => v_msg_count,
                 X_MSG_DATA => v_msg_data   );

--		IF PG_DEBUG < 10  THEN
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		   IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES: ' || 'Functional Currency >> '|| v_currency ||
                ' Filter Mode ' || p_filter_mode);
		END IF;



        if p_filter_mode IN ('CUST', 'BILLTO') then

--		    IF PG_DEBUG < 10  THEN
		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		       IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES: ' || 'Filter Mode >> '||
                                            p_filter_mode || ' Start');
		    END IF;

            if p_filter_mode = 'BILLTO' then
                Begin
                    select  DISTINCT aps.customer_id
                    into    v_billto_cust_account_id
                    from    ar_payment_schedules aps
                    where   aps.customer_site_use_id = p_filter_id ;

		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                        iex_debug_pub.logmessage('Cust Account id for bill to >> '
                        || v_billto_cust_account_id);
		    END IF;

                Exception
                   WHEN NO_DATA_FOUND THEN
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                            iex_debug_pub.logmessage('ERROR >> No Customer Account
                            for the Passed Bill to id >>' || p_filter_id);
			END IF;
                   WHEN OTHERS then
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                            iex_debug_pub.logmessage('ERROR >> When deriving customer
                            account for the Passed Bill to id >>' || p_filter_id ||
                            SQLCODE || SQLERRM);
			END IF;
                End ;
                v_filter_id1 := v_billto_cust_account_id  ;
                v_filter_id2 := p_filter_id ;
            else
                v_filter_id1 := p_filter_id ;
                v_filter_id2 := NULL ;
            End If ;


	        IEX_AGING_BUCKETS_PKG.calc_aging_buckets (
                p_customer_id           => v_filter_id1    ,
                p_customer_site_use_id  => v_filter_id2, -- NULL, changed by ehuh for 11591
                p_as_of_date         	=> l_date ,
                p_currency_code         => NULL,
                p_credit_option      	=> p_credit_option     ,
                p_invoice_type_low      => NULL,
                p_invoice_type_high     => NULL,
                p_ps_max_id             => NULL,
                p_app_max_id            => NULL,
                p_bucket_id   	        => p_bucket_id    ,
	            p_outstanding_balance => l_outstanding_balance,
                p_bucket_line_id_0      => l_bucket_line_id_0,
                p_bucket_seq_num_0      => l_bucket_seq_num_0,
                p_bucket_titletop_0	  => l_bucket_titletop_0      ,
                p_bucket_titlebottom_0 => l_bucket_titlebottom_0,
                p_bucket_amount_0      =>  l_bucket_amount_0      ,
                p_bucket_line_id_1      => l_bucket_line_id_1,
                p_bucket_seq_num_1      => l_bucket_seq_num_1,
                p_bucket_titletop_1	=> l_bucket_titletop_1      ,
                p_bucket_titlebottom_1	=> l_bucket_titlebottom_1,
                p_bucket_amount_1       => l_bucket_amount_1    ,
                p_bucket_line_id_2      => l_bucket_line_id_2,
                p_bucket_seq_num_2      => l_bucket_seq_num_2,
                p_bucket_titletop_2	=> l_bucket_titletop_2      ,
                p_bucket_titlebottom_2	=> l_bucket_titlebottom_2,
                p_bucket_amount_2       => l_bucket_amount_2    ,
                p_bucket_line_id_3      => l_bucket_line_id_3,
                p_bucket_seq_num_3      => l_bucket_seq_num_3,
                p_bucket_titletop_3	=> l_bucket_titletop_3      ,
                p_bucket_titlebottom_3 => l_bucket_titlebottom_3,
                p_bucket_amount_3       => l_bucket_amount_3    ,
                p_bucket_line_id_4      => l_bucket_line_id_4,
                p_bucket_seq_num_4      => l_bucket_seq_num_4,
                p_bucket_titletop_4	=> l_bucket_titletop_4      ,
                p_bucket_titlebottom_4 => l_bucket_titlebottom_4,
                p_bucket_amount_4       => l_bucket_amount_4    ,
                p_bucket_line_id_5      => l_bucket_line_id_5,
                p_bucket_seq_num_5      => l_bucket_seq_num_5,
                p_bucket_titletop_5	=> l_bucket_titletop_5      ,
                p_bucket_titlebottom_5 => l_bucket_titlebottom_5,
                p_bucket_amount_5       => l_bucket_amount_5    ,
                p_bucket_line_id_6      => l_bucket_line_id_6,
                p_bucket_seq_num_6      => l_bucket_seq_num_6,
                p_bucket_titletop_6	=> l_bucket_titletop_6      ,
                p_bucket_titlebottom_6 => l_bucket_titlebottom_6,
                p_bucket_amount_6       => l_bucket_amount_6 )  ;


        elsif p_filter_mode = 'PARTY' then
            Begin
            IF NVL(p_using_paying_rel, 'N') = 'Y' THEN
		      If AR_AGING_PAYING_PARTY_CUR%ISOPEN = false then
                	    OPEN  AR_AGING_PAYING_PARTY_CUR(p_filter_id) ;
		      End If ;
            ELSE
		      If AR_AGING_PARTY_CUR%ISOPEN = false then
                	    OPEN  AR_AGING_PARTY_CUR(p_filter_id) ;
		      End If ;
            END IF;

            	LOOP
                  IF NVL(p_using_paying_rel, 'N') = 'Y' THEN
                    FETCH   AR_AGING_PAYING_PARTY_CUR
                    INTO    l_customer_id   ;
                  ELSE
                    FETCH   AR_AGING_PARTY_CUR
                    INTO    l_customer_id   ;
                  END IF;
--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                       IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES: ' || 'Party Mode Fetch Iteration >> '
                            || to_char(l_count) || ' Filter Id '||
                                                to_char(p_filter_id));
                    END IF;
                    l_count :=  l_count + 1 ;

                  IF NVL(p_using_paying_rel, 'N') = 'Y' THEN
                    EXIT WHEN AR_AGING_PAYING_PARTY_CUR%NOTFOUND ;
                  ELSE
                    EXIT WHEN AR_AGING_PARTY_CUR%NOTFOUND ;
                  END IF;

--		            IF PG_DEBUG < 10  THEN
		            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		               IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES: ' || 'Mode Party >> Customer >> '
                                                        || l_customer_id );
		            END IF;

                    lt_outstanding_balance := 0 ;
                    -- Call the Aging Procedure for each fetched customer_id
--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                       IEX_DEBUG_PUB.LogMessage
                        ('QUERY_AGING_LINES: ' || 'Before Calling calc aging buckets >> Parameters >>');
                    END IF;
--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                       IEX_DEBUG_PUB.LogMessage
                            ('QUERY_AGING_LINES: ' || ' Bucket Id > '|| p_bucket_id
                            || 'Customer Id > ' || to_char(l_customer_id));
                    END IF;

	                IEX_AGING_BUCKETS_PKG.calc_aging_buckets (
                        p_customer_id           =>   l_customer_id  ,
                        p_customer_site_use_id  => p_customer_site_use_id, -- NULL, changed by ehuh for 11591
                        p_as_of_date            => l_date ,
                        p_currency_code         => NULL,
                        p_credit_option      	=> p_credit_option ,
                        p_invoice_type_low      => NULL,
                        p_invoice_type_high     => NULL,
                        p_ps_max_id             => NULL,
                        p_app_max_id            => NULL,
                        p_bucket_id   		=> p_bucket_id    ,
	                p_outstanding_balance => lt_outstanding_balance,
                        p_bucket_line_id_0      => lt_bucket_line_id_0,
                        p_bucket_seq_num_0      => lt_bucket_seq_num_0,
                        p_bucket_titletop_0     => lt_bucket_titletop_0      ,
                        p_bucket_titlebottom_0  => lt_bucket_titlebottom_0,
                        p_bucket_amount_0       =>  lt_bucket_amount_0      ,
                        p_bucket_line_id_1      => lt_bucket_line_id_1,
                        p_bucket_seq_num_1      => lt_bucket_seq_num_1,
                        p_bucket_titletop_1	=> lt_bucket_titletop_1      ,
                        p_bucket_titlebottom_1	=> lt_bucket_titlebottom_1,
                        p_bucket_amount_1       => lt_bucket_amount_1    ,
                        p_bucket_line_id_2      => lt_bucket_line_id_2,
                        p_bucket_seq_num_2      => lt_bucket_seq_num_2,
                        p_bucket_titletop_2	=> lt_bucket_titletop_2      ,
                        p_bucket_titlebottom_2	=> lt_bucket_titlebottom_2,
                        p_bucket_amount_2       => lt_bucket_amount_2    ,
                        p_bucket_line_id_3      => lt_bucket_line_id_3,
                        p_bucket_seq_num_3      => lt_bucket_seq_num_3,
                        p_bucket_titletop_3	=> lt_bucket_titletop_3      ,
                        p_bucket_titlebottom_3 => lt_bucket_titlebottom_3,
                        p_bucket_amount_3       => lt_bucket_amount_3    ,
                        p_bucket_line_id_4      => lt_bucket_line_id_4,
                        p_bucket_seq_num_4      => lt_bucket_seq_num_4,
                        p_bucket_titletop_4	=> lt_bucket_titletop_4      ,
                        p_bucket_titlebottom_4 => lt_bucket_titlebottom_4,
                        p_bucket_amount_4       => lt_bucket_amount_4    ,
                        p_bucket_line_id_5      => lt_bucket_line_id_5,
                        p_bucket_seq_num_5      => lt_bucket_seq_num_5,
                        p_bucket_titletop_5	=> lt_bucket_titletop_5      ,
                        p_bucket_titlebottom_5 => lt_bucket_titlebottom_5,
                        p_bucket_amount_5       => lt_bucket_amount_5    ,
                        p_bucket_line_id_6      => lt_bucket_line_id_6,
                        p_bucket_seq_num_6      => lt_bucket_seq_num_6,
                        p_bucket_titletop_6	=> lt_bucket_titletop_6      ,
                        p_bucket_titlebottom_6 => lt_bucket_titlebottom_6,
                        p_bucket_amount_6       => lt_bucket_amount_6 )  ;

                        -- Roll up all the derived Bucket Information for the
                        -- Customer into main parameter variables. These
                        -- act as common output for both party and cust modes
                        -- when loading the final output table.

--		                IF PG_DEBUG < 10  THEN
		                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		                   IEX_DEBUG_PUB.LogMessage
                            ('QUERY_AGING_LINES: ' || 'Acct Balance >> '|| to_char(lt_outstanding_balance));
		                END IF;

                        l_outstanding_balance :=
                            l_outstanding_balance + lt_outstanding_balance ;

--		                IF PG_DEBUG < 10  THEN
		                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		                   IEX_DEBUG_PUB.LogMessage
                            ('QUERY_AGING_LINES: ' || 'Total Balance >> '|| to_char(l_outstanding_balance));
		                END IF;

                        -- Rolling Bucket 0
                        l_bucket_amount_0 :=
                            l_bucket_amount_0 + lt_bucket_amount_0 ;
                        if (l_bucket_titletop_0) is NULL then
                            l_bucket_titletop_0 := lt_bucket_titletop_0 ;
                        End IF ;
                        if (l_bucket_titlebottom_0) is NULL then
                            l_bucket_titlebottom_0 := lt_bucket_titlebottom_0 ;
                        End IF ;

                        if (l_bucket_line_id_0) is NULL then
	                        l_bucket_line_id_0 :=   lt_bucket_line_id_0 ;
                        End If ;

                        if (l_bucket_seq_num_0) is NULL then
	                        l_bucket_seq_num_0  := lt_bucket_seq_num_0 ;
                        End If ;

--		                IF PG_DEBUG < 10  THEN
		                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		                   IEX_DEBUG_PUB.LogMessage
                                ('QUERY_AGING_LINES: ' || 'Bucket 0 >> '||lt_bucket_titletop_0 || ' '
                                                  || lt_bucket_titlebottom_0);
		                END IF;

                        /*-------------  Rolling Bucket 1  ------------*/
                        l_bucket_amount_1 :=
                            l_bucket_amount_1 + lt_bucket_amount_1 ;
                        if (l_bucket_titletop_1) is NULL then
                            l_bucket_titletop_1 := lt_bucket_titletop_1 ;
                        End IF ;
                        if (l_bucket_titlebottom_1) is NULL then
                            l_bucket_titlebottom_1 := lt_bucket_titlebottom_1 ;
                        End IF ;
                        if (l_bucket_line_id_1) is NULL then
	                        l_bucket_line_id_1 :=   lt_bucket_line_id_1 ;
                        End If ;

                        if (l_bucket_seq_num_1) is NULL then
	                        l_bucket_seq_num_1  := lt_bucket_seq_num_1 ;
                        End If ;
--		                IF PG_DEBUG < 10  THEN
		                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		                   IEX_DEBUG_PUB.LogMessage
                                ('QUERY_AGING_LINES: ' || 'Bucket 1 >> '||lt_bucket_titletop_1 || ' '
                                                  || lt_bucket_titlebottom_1);
		                END IF;

                        /*-------------  Rolling Bucket 2  ------------*/
                        l_bucket_amount_2 :=
                            l_bucket_amount_2 + lt_bucket_amount_2 ;
                        if (l_bucket_titletop_2) is NULL then
                            l_bucket_titletop_2 := lt_bucket_titletop_2 ;
                        End IF ;
                        if (l_bucket_titlebottom_2) is NULL then
                            l_bucket_titlebottom_2 := lt_bucket_titlebottom_2 ;
                        End IF ;

                        if (l_bucket_line_id_2) is NULL then
	                        l_bucket_line_id_2 :=   lt_bucket_line_id_2 ;
                        End If ;

                        if (l_bucket_seq_num_2) is NULL then
	                        l_bucket_seq_num_2  := lt_bucket_seq_num_2 ;
                        End If ;

                        /*-------------  Rolling Bucket 3  ------------*/
                        l_bucket_amount_3 :=
                            l_bucket_amount_3 + lt_bucket_amount_3 ;
                        if (l_bucket_titletop_3) is NULL then
                            l_bucket_titletop_3 := lt_bucket_titletop_3 ;
                        End IF ;
                        if (l_bucket_titlebottom_3) is NULL then
                            l_bucket_titlebottom_3 := lt_bucket_titlebottom_3 ;
                        End IF ;

                        if (l_bucket_line_id_3) is NULL then
	                        l_bucket_line_id_3 :=   lt_bucket_line_id_3 ;
                        End If ;

                        if (l_bucket_seq_num_3) is NULL then
	                        l_bucket_seq_num_3  := lt_bucket_seq_num_3 ;
                        End If ;
--		                IF PG_DEBUG < 10  THEN
		                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		                   IEX_DEBUG_PUB.LogMessage
                                ('QUERY_AGING_LINES: ' || 'Bucket 3 >> '||lt_bucket_titletop_3 || ' '
                                                  || lt_bucket_titlebottom_3);
		                END IF;

                        /*-------------  Rolling Bucket 4  ------------*/
                        l_bucket_amount_4 :=
                            l_bucket_amount_4 + lt_bucket_amount_4 ;
                        if (l_bucket_titletop_4) is NULL then
                            l_bucket_titletop_4 := lt_bucket_titletop_4 ;
                        End IF ;
                        if (l_bucket_titlebottom_4) is NULL then
                            l_bucket_titlebottom_4 := lt_bucket_titlebottom_4 ;
                        End IF ;

                        if (l_bucket_line_id_4) is NULL then
	                        l_bucket_line_id_4 :=   lt_bucket_line_id_4 ;
                        End If ;

                        if (l_bucket_seq_num_4) is NULL then
	                        l_bucket_seq_num_4  := lt_bucket_seq_num_4 ;
                        End If ;

                        /*-------------  Rolling Bucket 5  ------------*/
                        l_bucket_amount_5 :=
                            l_bucket_amount_5 + lt_bucket_amount_5 ;
                        if (l_bucket_titletop_5) is NULL then
                            l_bucket_titletop_5 := lt_bucket_titletop_5 ;
                        End IF ;
                        if (l_bucket_titlebottom_5) is NULL then
                            l_bucket_titlebottom_5 := lt_bucket_titlebottom_5 ;
                        End IF ;
                        if (l_bucket_line_id_5) is NULL then
	                        l_bucket_line_id_5 :=   lt_bucket_line_id_5 ;
                        End If ;

                        if (l_bucket_seq_num_5) is NULL then
	                        l_bucket_seq_num_5  := lt_bucket_seq_num_5 ;
                        End If ;

                        /*-------------  Rolling Bucket 6  ------------*/
                        l_bucket_amount_6 :=
                            l_bucket_amount_6 + lt_bucket_amount_6 ;
                        if (l_bucket_titletop_6) is NULL then
                            l_bucket_titletop_6 := lt_bucket_titletop_6 ;
                        End IF ;
                        if (l_bucket_titlebottom_6) is NULL then
                            l_bucket_titlebottom_6 := lt_bucket_titlebottom_6 ;
                        End IF ;

                        if (l_bucket_line_id_6) is NULL then
	                        l_bucket_line_id_6 :=   lt_bucket_line_id_6 ;
                        End If ;

                        if (l_bucket_seq_num_6) is NULL then
	                        l_bucket_seq_num_6  := lt_bucket_seq_num_6 ;
                        End If ;

                END LOOP ;
                IF NVL(p_using_paying_rel, 'N') = 'Y' THEN
                  If AR_AGING_PAYING_PARTY_CUR%ISOPEN then
                    CLOSE AR_AGING_PAYING_PARTY_CUR ;
                  End IF ;
                ELSE
                  If AR_AGING_PARTY_CUR%ISOPEN then
                    CLOSE AR_AGING_PARTY_CUR ;
                  End IF ;
                END IF;
            Exception
                WHEN OTHERS Then
--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                       IEX_DEBUG_PUB.LogMessage
                                ('QUERY_AGING_LINES: ' || 'When Others Party Mode >> '||SQLCODE
                                                        || ' ==> ' ||SQLERRM);
                    END IF;
                IF NVL(p_using_paying_rel, 'N') = 'Y' THEN
                  If AR_AGING_PAYING_PARTY_CUR%ISOPEN then
                    CLOSE AR_AGING_PAYING_PARTY_CUR ;
                  End IF ;
                ELSE
                  If AR_AGING_PARTY_CUR%ISOPEN then
                    CLOSE AR_AGING_PARTY_CUR ;
                  End IF ;
                END IF;
            End ;
        End If ;

--		IF PG_DEBUG < 10  THEN
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		   IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES: ' || ' Loading Buckets into Table of Records');
		END IF;

        -- Load the Derived values into PL/SQL table
        /* ---------------------------------------------------------
                                Bucket 0
        ---------------------------------------------------------*/
        if  l_bucket_amount_0 IS NOT NULL then
            --if l_bucket_amount_0 <> 0 then
	            x_bucket_lines_tbl(l_cnt).bucket_line
		                    := l_bucket_titletop_0 || l_bucket_titlebottom_0 ;
                x_bucket_lines_tbl(l_cnt).amount := l_bucket_amount_0 ;

	            x_bucket_lines_tbl(l_cnt).bucket_line_id
		                    := l_bucket_line_id_0 ;
	            x_bucket_lines_tbl(l_cnt).bucket_seq_num
		                    := l_bucket_seq_num_0 ;

--                IF PG_DEBUG < 10  THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                   IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES: ' || l_line);
                END IF;
--		        IF PG_DEBUG < 10  THEN
		        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		           IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES: ' || ' Row 1 Bucket Name ' ||
                    x_bucket_lines_tbl(l_cnt).bucket_line  ||
                    ' Amount = ' || to_char(l_bucket_amount_0) ||
                    '] Line Id = ['|| to_char(l_bucket_line_id_0) ||
                    '] Seq Num = ['|| to_char(l_bucket_seq_num_0));
		        END IF;

                    l_cnt := l_cnt + 1 ;
--            End If ;
        End If ;

        /*---------------------------------------------------------
                                Bucket 1
        ---------------------------------------------------------*/
        if  l_bucket_amount_1 IS NOT NULL then
--            if l_bucket_amount_1 <> 0 then
	            x_bucket_lines_tbl(l_cnt).bucket_line
		                    := l_bucket_titletop_1 || l_bucket_titlebottom_1 ;
	            x_bucket_lines_tbl(l_cnt).amount := l_bucket_amount_1 ;

	            x_bucket_lines_tbl(l_cnt).bucket_line_id
		                    := l_bucket_line_id_1 ;
	            x_bucket_lines_tbl(l_cnt).bucket_seq_num
		                    := l_bucket_seq_num_1 ;

--		        IF PG_DEBUG < 10  THEN
		        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		           IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES: ' || ' Row 2 Bucket Name [' ||
                    x_bucket_lines_tbl(l_cnt).bucket_line  ||
                    '] Amount = [' || to_char(l_bucket_amount_1) ||
                    '] Line Id = ['|| to_char(l_bucket_line_id_1) ||
                    '] Seq Num = ['|| to_char(l_bucket_seq_num_1));
		        END IF;
                l_cnt := l_cnt + 1 ;
--            End If ;
        End If ;

        /*---------------------------------------------------------
                                Bucket 2
        ---------------------------------------------------------*/
        if  l_bucket_amount_2 IS NOT NULL then
 --           if l_bucket_amount_2 <> 0 then
	            x_bucket_lines_tbl(l_cnt).bucket_line
		                    := l_bucket_titletop_2 || l_bucket_titlebottom_2 ;
	            x_bucket_lines_tbl(l_cnt).amount := l_bucket_amount_2 ;

	            x_bucket_lines_tbl(l_cnt).bucket_line_id
		                    := l_bucket_line_id_2 ;
	            x_bucket_lines_tbl(l_cnt).bucket_seq_num
		                    := l_bucket_seq_num_2 ;

--		        IF PG_DEBUG < 10  THEN
		        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		           IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES: ' || ' Row 3 Bucket Name ' ||
                    x_bucket_lines_tbl(l_cnt).bucket_line  ||
                    ' Amount = ' || to_char(l_bucket_amount_2) ||
                    '] Line Id = ['|| to_char(l_bucket_line_id_2) ||
                    '] Seq Num = ['|| to_char(l_bucket_seq_num_2));
		        END IF;
                l_cnt := l_cnt + 1 ;
--            End If ;
        End If ;

        /*---------------------------------------------------------
                                Bucket 3
        ---------------------------------------------------------*/
        if  l_bucket_amount_3 IS NOT NULL then
 --           If l_bucket_amount_3 <> 0 then
	            x_bucket_lines_tbl(l_cnt).bucket_line
		                    := l_bucket_titletop_3 || l_bucket_titlebottom_3 ;
	            x_bucket_lines_tbl(l_cnt).amount := l_bucket_amount_3 ;

	            x_bucket_lines_tbl(l_cnt).bucket_line_id
		                    := l_bucket_line_id_3 ;
	            x_bucket_lines_tbl(l_cnt).bucket_seq_num
		                    := l_bucket_seq_num_3 ;

--		        IF PG_DEBUG < 10  THEN
		        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		           IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES: ' || ' Row 4 Bucket Name ' ||
                    x_bucket_lines_tbl(l_cnt).bucket_line  ||
                    ' Amount = ' || to_char(l_bucket_amount_3)  ||
                    '] Line Id = ['|| to_char(l_bucket_line_id_3) ||
                    '] Seq Num = ['|| to_char(l_bucket_seq_num_3));
		        END IF;

                l_cnt := l_cnt + 1 ;
  --          End If ;
        End If ;

        /*---------------------------------------------------------
                                Bucket 4
        ---------------------------------------------------------*/
        if  l_bucket_amount_4 IS NOT NULL then
--            If l_bucket_amount_4 <> 0 then
	            x_bucket_lines_tbl(l_cnt).bucket_line
		                    := l_bucket_titletop_4 || l_bucket_titlebottom_4 ;
	            x_bucket_lines_tbl(l_cnt).amount := l_bucket_amount_4 ;

	            x_bucket_lines_tbl(l_cnt).bucket_line_id
		                    := l_bucket_line_id_4 ;
	            x_bucket_lines_tbl(l_cnt).bucket_seq_num
		                    := l_bucket_seq_num_4 ;

--		        IF PG_DEBUG < 10  THEN
		        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		           IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES: ' || ' Row 5 Bucket Name ' ||
                    x_bucket_lines_tbl(l_cnt).bucket_line  ||
                    ' Amount = ' || to_char(l_bucket_amount_4)  ||
                    '] Line Id = ['|| to_char(l_bucket_line_id_4) ||
                    '] Seq Num = ['|| to_char(l_bucket_seq_num_4));
		        END IF;
                l_cnt := l_cnt + 1 ;
 --           End If ;
        End If ;

        /*---------------------------------------------------------
                                Bucket 5
        ---------------------------------------------------------*/
        if  l_bucket_amount_5 IS NOT NULL then
  --          If l_bucket_amount_5 <> 0 then
	            x_bucket_lines_tbl(l_cnt).bucket_line
		                    := l_bucket_titletop_5 || l_bucket_titlebottom_5 ;
	            x_bucket_lines_tbl(l_cnt).amount := l_bucket_amount_5 ;

	            x_bucket_lines_tbl(l_cnt).bucket_line_id
		                    := l_bucket_line_id_5 ;
	            x_bucket_lines_tbl(l_cnt).bucket_seq_num
		                    := l_bucket_seq_num_5 ;

--		        IF PG_DEBUG < 10  THEN
		        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		           IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES: ' || ' Row 6 Bucket Name ' ||
                    x_bucket_lines_tbl(l_cnt).bucket_line  ||
                    ' Amount = ' || to_char(l_bucket_amount_5) ||
                    '] Line Id = ['|| to_char(l_bucket_line_id_5) ||
                    '] Seq Num = ['|| to_char(l_bucket_seq_num_5));
		        END IF;
                l_cnt := l_cnt + 1 ;
 --           End If ;
        End If ;

        /*---------------------------------------------------------
                                Bucket 6
        ---------------------------------------------------------*/
        if  l_bucket_amount_6 IS NOT NULL then
 --           If l_bucket_amount_6 <> 0 then
	            x_bucket_lines_tbl(l_cnt).bucket_line
		                    := l_bucket_titletop_6 || l_bucket_titlebottom_6 ;
	            x_bucket_lines_tbl(l_cnt).amount := l_bucket_amount_6 ;

	            x_bucket_lines_tbl(l_cnt).bucket_line_id
		                    := l_bucket_line_id_6 ;
	            x_bucket_lines_tbl(l_cnt).bucket_seq_num
		                    := l_bucket_seq_num_6 ;

--		        IF PG_DEBUG < 10  THEN
		        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		           IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES: ' || ' Row 7 Bucket Name ' ||
                    x_bucket_lines_tbl(l_cnt).bucket_line  ||
                    ' Amount = ' || to_char(l_bucket_amount_6) ||
                    '] Line Id = ['|| to_char(l_bucket_line_id_6) ||
                    '] Seq Num = ['|| to_char(l_bucket_seq_num_6));
		        END IF;
                l_cnt := l_cnt + 1 ;
  --          End If ;
        End If ;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES: ' || l_line);
        END IF;



IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.logmessage('Filter Mode Before Collectible Amt ' || p_filter_mode || ' [ '||p_filter_id || ' ]') ;
END IF;

        -- Derive Collectible Amounts
        if p_filter_mode = 'CUST' then
            select  aabl.aging_bucket_line_id, sum(acctd_amount_due_remaining)
            BULK COLLECT INTO
                    l_collectible_bkt_id_tbl,
                    l_collectible_bkt_amt_tbl
            from    ar_aging_bucket_lines aabl,
                    ar_payment_schedules aps,
                    iex_delinquencies id
            where   id.payment_schedule_id = aps.payment_schedule_id
--BEGIN-FIX BUG#4356388-05/24/2005-JYPARK-amount overdue should inculde Pre-Delinquent transactions which are not past due
--            and     id.status IN ('DELINQUENT', 'PRE-DELINQUENT')
            and     id.status IN ('DELINQUENT', 'PREDELINQUENT')
--END-FIX BUG#4356388-05/24/2005-JYPARK-amount overdue should inculde Pre-Delinquent transactions which are not past due
            and     trunc(sysdate)-aps.due_date >= aabl.days_start
            and     trunc(sysdate)-aps.due_date <= aabl.days_to
            and     id.cust_account_id = p_filter_id
            and     aabl.aging_bucket_id = p_bucket_id
	        --- Begin - Andre Araujo - 11/09/2004 - Performance fix
            AND    aps.status = 'OP'
	        --- End - Andre Araujo - 11/09/2004 - Performance fix
            group by aabl.aging_bucket_line_id ;

	    --Start bug 6701396 gnramasa 4th Mar 08
	    if (NVL(FND_PROFILE.VALUE('IEX_EXCLUDE_DISPUTE_AMT_FROM_REMAINING_AMT'), 'N') = 'Y') then
		    if l_collectible_bkt_id_tbl.COUNT > 0 then
			For coll_bkt_cnt IN 1..l_collectible_bkt_id_tbl.COUNT
			LOOP
			    SELECT nvl(SUM(total_amount),   0)
				INTO l_collect_dispute_amt
				FROM ra_cm_requests
				WHERE customer_trx_id IN
				  (SELECT DISTINCT id.transaction_id
				   FROM ar_aging_bucket_lines aabl,
				     ar_payment_schedules aps,
				     iex_delinquencies id
				   WHERE id.payment_schedule_id = aps.payment_schedule_id
				   AND id.status IN('DELINQUENT',    'PREDELINQUENT')
				   AND TRUNC(sysdate) -aps.due_date >= aabl.days_start
				   AND TRUNC(sysdate) -aps.due_date <= aabl.days_to
				   AND id.cust_account_id = p_filter_id
				   AND aabl.aging_bucket_id = p_bucket_id
				   AND aps.status = 'OP'
				   AND aabl.aging_bucket_line_id = l_collectible_bkt_id_tbl(coll_bkt_cnt))
				AND status = 'PENDING_APPROVAL';

			    l_collectible_bkt_amt_tbl(coll_bkt_cnt) :=  l_collectible_bkt_amt_tbl(coll_bkt_cnt) + l_collect_dispute_amt;
			End Loop ;
		    End If ;
	     end if;  --profile value 'IEX_EXCLUDE_DISPUTE_AMT_FROM_REMAINING_AMT'

        ElsIf p_filter_mode = 'PARTY' then
            IF NVL(p_using_paying_rel, 'N') = 'Y' THEN
              select  aabl.aging_bucket_line_id, sum(acctd_amount_due_remaining)
                BULK COLLECT INTO
                    l_collectible_bkt_id_tbl,
                    l_collectible_bkt_amt_tbl
              from  ar_aging_bucket_lines aabl,
                    ar_payment_schedules aps,
                    iex_delinquencies id,
                    hz_cust_accounts hzca
              where   id.payment_schedule_id = aps.payment_schedule_id
--BEGIN-FIX BUG#4356388-05/24/2005-JYPARK-amount overdue should inculde Pre-Delinquent transactions which are not past due
--                and     id.status IN ('DELINQUENT', 'PRE-DELINQUENT')
                and     id.status IN ('DELINQUENT', 'PREDELINQUENT')
--END-FIX BUG#4356388-05/24/2005-JYPARK-amount overdue should inculde Pre-Delinquent transactions which are not past due
                and     trunc(sysdate)-aps.due_date >= aabl.days_start
                and     trunc(sysdate)-aps.due_date <= aabl.days_to
                and     id.cust_account_id = hzca.cust_account_id
                and     hzca.party_id IN
                            (SELECT p_filter_id FROM dual
                              UNION
                             SELECT ar.related_party_id
                               FROM ar_paying_relationships_v ar
                              WHERE ar.party_id = p_filter_id
                                AND TRUNC(sysdate) BETWEEN
                                    TRUNC(NVL(ar.effective_start_date,sysdate)) AND
                                    TRUNC(NVL(ar.effective_end_date,sysdate))  )
                and     aabl.aging_bucket_id = p_bucket_id
                --- Begin - Andre Araujo - 11/09/2004 - Performance fix
                AND    aps.status = 'OP'
	            --- End - Andre Araujo - 11/09/2004 - Performance fix
                group by aabl.aging_bucket_line_id ;

		if (NVL(FND_PROFILE.VALUE('IEX_EXCLUDE_DISPUTE_AMT_FROM_REMAINING_AMT'), 'N') = 'Y') then
			if l_collectible_bkt_id_tbl.COUNT > 0 then
			For coll_bkt_cnt IN 1..l_collectible_bkt_id_tbl.COUNT
			LOOP
			    SELECT nvl(SUM(total_amount),   0)
				INTO l_collect_dispute_amt
				FROM ra_cm_requests
				WHERE customer_trx_id IN
				  (SELECT DISTINCT id.transaction_id
				   FROM ar_aging_bucket_lines aabl,
				     ar_payment_schedules aps,
				     iex_delinquencies id,
				     hz_cust_accounts hzca
				   WHERE id.payment_schedule_id = aps.payment_schedule_id
				   AND id.status IN('DELINQUENT',    'PREDELINQUENT')
				   AND TRUNC(sysdate) -aps.due_date >= aabl.days_start
				   AND TRUNC(sysdate) -aps.due_date <= aabl.days_to
				   AND id.cust_account_id = hzca.cust_account_id
				   AND hzca.party_id IN
				    (SELECT p_filter_id
				     FROM dual
				     UNION
				     SELECT ar.related_party_id
				     FROM ar_paying_relationships_v ar
				     WHERE ar.party_id = p_filter_id
				     AND TRUNC(sysdate) BETWEEN TRUNC(nvl(ar.effective_start_date,    sysdate))
				     AND TRUNC(nvl(ar.effective_end_date,    sysdate)))
				  AND aabl.aging_bucket_id = p_bucket_id
				   AND aps.status = 'OP'
				   AND aabl.aging_bucket_line_id = l_collectible_bkt_id_tbl(coll_bkt_cnt))
				AND status = 'PENDING_APPROVAL';

			    l_collectible_bkt_amt_tbl(coll_bkt_cnt) :=  l_collectible_bkt_amt_tbl(coll_bkt_cnt) + l_collect_dispute_amt;
			End Loop ;
			End If ;
		end if;  --profile value 'IEX_EXCLUDE_DISPUTE_AMT_FROM_REMAINING_AMT'

            ELSE
              select  aabl.aging_bucket_line_id, sum(acctd_amount_due_remaining)
                BULK COLLECT INTO
                    l_collectible_bkt_id_tbl,
                    l_collectible_bkt_amt_tbl
              from  ar_aging_bucket_lines aabl,
                    ar_payment_schedules aps,
                    iex_delinquencies id,
                    hz_cust_accounts hzca
              where   id.payment_schedule_id = aps.payment_schedule_id
--BEGIN-FIX BUG#4356388-05/24/2005-JYPARK-amount overdue should inculde Pre-Delinquent transactions which are not past due
--                and     id.status IN ('DELINQUENT', 'PRE-DELINQUENT')
                and     id.status IN ('DELINQUENT', 'PREDELINQUENT')
--END-FIX BUG#4356388-05/24/2005-JYPARK-amount overdue should inculde Pre-Delinquent transactions which are not past due
                and     trunc(sysdate)-aps.due_date >= aabl.days_start
                and     trunc(sysdate)-aps.due_date <= aabl.days_to
                and     id.cust_account_id = hzca.cust_account_id
                and     hzca.party_id = p_filter_id
                and     aabl.aging_bucket_id = p_bucket_id
                --- Begin - Andre Araujo - 11/09/2004 - Performance fix
                AND    aps.status = 'OP'
	            --- End - Andre Araujo - 11/09/2004 - Performance fix
               group by aabl.aging_bucket_line_id ;

	       if (NVL(FND_PROFILE.VALUE('IEX_EXCLUDE_DISPUTE_AMT_FROM_REMAINING_AMT'), 'N') = 'Y') then
		       if l_collectible_bkt_id_tbl.COUNT > 0 then
			For coll_bkt_cnt IN 1..l_collectible_bkt_id_tbl.COUNT
			LOOP
			    SELECT nvl(SUM(total_amount),   0)
				INTO l_collect_dispute_amt
				FROM ra_cm_requests
				WHERE customer_trx_id IN
				  (SELECT DISTINCT id.transaction_id
				   FROM ar_aging_bucket_lines aabl,
				     ar_payment_schedules aps,
				     iex_delinquencies id,
				     hz_cust_accounts hzca
				   WHERE id.payment_schedule_id = aps.payment_schedule_id
				   AND id.status IN('DELINQUENT',    'PREDELINQUENT')
				   AND TRUNC(sysdate) -aps.due_date >= aabl.days_start
				   AND TRUNC(sysdate) -aps.due_date <= aabl.days_to
				   AND id.cust_account_id = hzca.cust_account_id
				   AND hzca.party_id = p_filter_id
				   AND aabl.aging_bucket_id = p_bucket_id
				   AND aps.status = 'OP'
				   AND aabl.aging_bucket_line_id = l_collectible_bkt_id_tbl(coll_bkt_cnt))
				AND status = 'PENDING_APPROVAL';

			    l_collectible_bkt_amt_tbl(coll_bkt_cnt) :=  l_collectible_bkt_amt_tbl(coll_bkt_cnt) + l_collect_dispute_amt;
			End Loop ;
		      End If ;
		end if;  --profile value 'IEX_EXCLUDE_DISPUTE_AMT_FROM_REMAINING_AMT'

            END IF;
        Else
              select  aabl.aging_bucket_line_id, sum(acctd_amount_due_remaining)    -- added by ehuh for bill-to
                BULK COLLECT INTO                                                   -- added by ehuh for bill-to
                    l_collectible_bkt_id_tbl,                                       -- added by ehuh for bill-to
                    l_collectible_bkt_amt_tbl                                       -- added by ehuh for bill-to
              from  ar_aging_bucket_lines aabl,                                     -- added by ehuh for bill-to
                    ar_payment_schedules aps,                                       -- added by ehuh for bill-to
                    iex_delinquencies id
              where   id.payment_schedule_id = aps.payment_schedule_id              -- added by ehuh for bill-to
--BEGIN-FIX BUG#4356388-05/24/2005-JYPARK-amount overdue should inculde Pre-Delinquent transactions which are not past due
--                and     id.status IN ('DELINQUENT', 'PRE-DELINQUENT')
                and     id.status IN ('DELINQUENT', 'PREDELINQUENT')
--END-FIX BUG#4356388-05/24/2005-JYPARK-amount overdue should inculde Pre-Delinquent transactions which are not past due
                and   trunc(sysdate)-aps.due_date >= aabl.days_start              -- added by ehuh for bill-to
                and   trunc(sysdate)-aps.due_date <= aabl.days_to                 -- added by ehuh for bill-to
                and   aabl.aging_bucket_id = p_bucket_id                          -- added by ehuh for bill-to
                and   aps.customer_site_use_id = p_filter_id           -- added by ehuh for bill-to
                --- Begin - Andre Araujo - 11/09/2004 - Performance fix
                AND    aps.status = 'OP'
	            --- End - Andre Araujo - 11/09/2004 - Performance fix
              group by aabl.aging_bucket_line_id ;                                -- added by ehuh for bill-to

	      if (NVL(FND_PROFILE.VALUE('IEX_EXCLUDE_DISPUTE_AMT_FROM_REMAINING_AMT'), 'N') = 'Y') then
		      if l_collectible_bkt_id_tbl.COUNT > 0 then
			For coll_bkt_cnt IN 1..l_collectible_bkt_id_tbl.COUNT
			LOOP
			    SELECT nvl(SUM(total_amount),   0)
				INTO l_collect_dispute_amt
				FROM ra_cm_requests
				WHERE customer_trx_id IN
				  (SELECT DISTINCT id.transaction_id
				   FROM ar_aging_bucket_lines aabl,
				     ar_payment_schedules aps,
				     iex_delinquencies id
				   WHERE id.payment_schedule_id = aps.payment_schedule_id
				   AND id.status IN('DELINQUENT',    'PREDELINQUENT')
				   AND TRUNC(sysdate) -aps.due_date >= aabl.days_start
				   AND TRUNC(sysdate) -aps.due_date <= aabl.days_to
				   AND aabl.aging_bucket_id = p_bucket_id
				   AND aps.customer_site_use_id = p_filter_id
				   AND aps.status = 'OP'
				   AND aabl.aging_bucket_line_id = l_collectible_bkt_id_tbl(coll_bkt_cnt))
				AND status = 'PENDING_APPROVAL';

			    l_collectible_bkt_amt_tbl(coll_bkt_cnt) :=  l_collectible_bkt_amt_tbl(coll_bkt_cnt) + l_collect_dispute_amt;
			End Loop ;
		      End If ;
		end if; --profile value 'IEX_EXCLUDE_DISPUTE_AMT_FROM_REMAINING_AMT'
	    --End bug 6701396 gnramasa 4th Mar 08
        End If ;

        /*---------------------------------------------------------
                        Loading all the one time results
        ---------------------------------------------------------*/
--		IF PG_DEBUG < 10  THEN
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		   IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES: ' || ' Loading one time results ' );
		END IF;
        FOR cnt in 1..x_bucket_lines_tbl.COUNT
        LOOP
            x_bucket_lines_tbl(cnt).outstanding_balance
		                    := l_outstanding_balance ;
	        x_bucket_lines_tbl(cnt).currency := v_currency ;
            x_bucket_lines_tbl(cnt).collectible_amount := 0 ;

            -- Merge the Collectible Amount with the AR Amount
            if l_collectible_bkt_id_tbl.COUNT > 0 then
                For bkt_cnt IN 1..l_collectible_bkt_id_tbl.COUNT
                LOOP
                    if l_collectible_bkt_id_tbl(bkt_cnt) =
                            x_bucket_lines_tbl(cnt).bucket_line_id then
                        x_bucket_lines_tbl(cnt).collectible_amount :=
                                            l_collectible_bkt_amt_tbl(bkt_cnt) ;
                    End If ;
                End Loop ;
            End If ;


--		    IF PG_DEBUG < 10  THEN
		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		       IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES: ' || ' Row >> ' || to_char(cnt) || ' Bal [' ||
                to_char(x_bucket_lines_tbl(cnt).outstanding_balance) ||
                'Currency [' || x_bucket_lines_tbl(cnt).currency);
		    END IF;

            l_total_amount   := l_total_amount + x_bucket_lines_tbl(cnt).amount;
            l_total_coll_amount    := l_total_coll_amount +
                                    x_bucket_lines_tbl(cnt).collectible_amount;


            GET_CNSLD_INVOICE_COUNT(
                p_api_version      =>   p_api_version,
                p_init_msg_list    =>   p_init_msg_list,
                p_commit           =>   p_commit,
                p_validation_level =>   p_validation_level,
                x_return_status    =>   x_return_status,
                x_msg_count        =>   x_msg_count,
                x_msg_data         =>   x_msg_data,
                p_filter_mode	   =>   p_filter_mode,
	            p_bucket_line_id   =>   x_bucket_lines_tbl(cnt).bucket_line_id,
	            p_filter_id 	   =>   p_filter_id,
                p_customer_site_use_id =>  p_customer_site_use_id,
                p_using_paying_rel => p_using_paying_rel,
                x_count      =>   x_bucket_lines_tbl(cnt).consolidated_invoices,
	            x_amount     =>   l_cons_amount) ;

                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                IEX_DEBUG_PUB.LogMessage('After Call CONS : ' || x_bucket_lines_tbl(cnt).consolidated_invoices) ;
                END IF;

                l_total_cnsld_invoices := l_total_cnsld_invoices +
                                 x_bucket_lines_tbl(cnt).consolidated_invoices ;


            -- Load all the Values from the Collections
            -- Load Invoice Count/Amount
            GET_BKT_INVOICE_CLASS_INFO
                (p_api_version     =>   p_api_version,
                p_init_msg_list    =>   p_init_msg_list,
                p_commit           =>   p_commit,
                p_validation_level =>   p_validation_level,
                x_return_status    =>   x_return_status,
                x_msg_count        =>   x_msg_count,
                x_msg_data         =>   x_msg_data,
                p_filter_mode	   =>   p_filter_mode,
	            p_bucket_line_id   =>   x_bucket_lines_tbl(cnt).bucket_line_id,
	            p_filter_id 	   =>   p_filter_id,
                p_customer_site_use_id =>  p_customer_site_use_id,     -- added by ehuh for bill-to
                p_using_paying_rel => p_using_paying_rel,
                p_class            =>   'INV',
                x_class_count      =>   x_bucket_lines_tbl(cnt).Invoice_count,
	            x_class_amount     =>   x_bucket_lines_tbl(cnt).Invoice_amount);


                l_total_invoices   := l_total_invoices +
                                        x_bucket_lines_tbl(cnt).Invoice_count ;
                l_total_inv_amount := l_total_inv_amount +
                                        x_bucket_lines_tbl(cnt).Invoice_amount ;


            -- Load DM Count/Amount
            GET_BKT_INVOICE_CLASS_INFO
                (p_api_version     =>   p_api_version,
                p_init_msg_list    =>   p_init_msg_list,
                p_commit           =>   p_commit,
                p_validation_level =>   p_validation_level,
                x_return_status    =>   x_return_status,
                x_msg_count        =>   x_msg_count,
                x_msg_data         =>   x_msg_data,
                p_filter_mode	   =>   p_filter_mode,
	        p_bucket_line_id   =>   x_bucket_lines_tbl(cnt).bucket_line_id,
	        p_filter_id 	   =>   p_filter_id,
                p_customer_site_use_id =>  p_customer_site_use_id,    -- added by ehuh for bill-to
                p_using_paying_rel => p_using_paying_rel,
                p_class            =>   'DM',
                x_class_count      =>   x_bucket_lines_tbl(cnt).Dm_count,
	        x_class_amount     =>   x_bucket_lines_tbl(cnt).Dm_amount);
                l_total_debit_memos  := l_total_debit_memos +
                                        x_bucket_lines_tbl(cnt).dm_count ;
                l_total_dm_amount    := l_total_dm_amount +
                                        x_bucket_lines_tbl(cnt).dm_amount ;

            -- Load Chargeback Count/Amount
            GET_BKT_INVOICE_CLASS_INFO
                (p_api_version     =>   p_api_version,
                p_init_msg_list    =>   p_init_msg_list,
                p_commit           =>   p_commit,
                p_validation_level =>   p_validation_level,
                x_return_status    =>   x_return_status,
                x_msg_count        =>   x_msg_count,
                x_msg_data         =>   x_msg_data,
                p_filter_mode	   =>   p_filter_mode,
	        p_bucket_line_id   =>   x_bucket_lines_tbl(cnt).bucket_line_id,
	        p_filter_id 	   =>   p_filter_id,
                p_customer_site_use_id =>  p_customer_site_use_id,    -- added by ehuh for bill-to
                p_class            =>   'CB',
                p_using_paying_rel => p_using_paying_rel,
                x_class_count      =>   x_bucket_lines_tbl(cnt).cb_count,
	        x_class_amount     =>   x_bucket_lines_tbl(cnt).cb_amount);
                l_total_chargebacks  := l_total_chargebacks +
                                        x_bucket_lines_tbl(cnt).cb_count ;
                l_total_cb_amount    := l_total_cb_amount +
                                        x_bucket_lines_tbl(cnt).cb_amount ;
        END LOOP ;

        -- Adding Total Row to the Table
        /* TRANSLATE THIS */
        l_total_rec := x_bucket_lines_tbl.COUNT + 1 ;
        x_bucket_lines_tbl(l_total_rec).Bucket_line:= 'Totals';
        x_bucket_lines_tbl(l_total_rec).Amount := l_total_amount;
        x_bucket_lines_tbl(l_total_rec).Currency :=
                                x_bucket_lines_tbl(l_total_rec-1).Currency;
        x_bucket_lines_tbl(l_total_rec).collectible_amount :=
                                                        l_total_coll_amount ;
        x_bucket_lines_tbl(l_total_rec).invoice_count := l_total_invoices ;
        x_bucket_lines_tbl(l_total_rec).invoice_amount := l_total_inv_amount ;

        x_bucket_lines_tbl(l_total_rec).consolidated_invoices :=
                                                    l_total_cnsld_invoices ;

        x_bucket_lines_tbl(l_total_rec).dm_count := l_total_debit_memos ;
        x_bucket_lines_tbl(l_total_rec).dm_amount := l_total_dm_amount ;

        x_bucket_lines_tbl(l_total_rec).cb_count := l_total_chargebacks ;
        x_bucket_lines_tbl(l_total_rec).cb_amount := l_total_cb_amount ;

        x_bucket_lines_tbl(l_total_rec).disputed_tran_count:= l_total_disputes ;
        x_bucket_lines_tbl(l_total_rec).disputed_tran_amount :=
                                                           l_total_disp_amount ;

    	-- Standard check of p_commit
    	IF FND_API.To_Boolean(p_commit) THEN
    		COMMIT WORK;
    	END IF;

    	-- Standard call to get message count and if count is 1, get message info
    	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES: ' || '-----------------------------------------');
        END IF;
--		IF PG_DEBUG < 10  THEN
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		   IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES --->>  End <<--- ');
		END IF;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('QUERY_AGING_LINES: ' || '-----------------------------------------');
        END IF;

    EXCEPTION
    	WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Query_Aging_lines;
    		x_return_status := FND_API.G_RET_STS_ERROR;
    		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Query_Aging_lines;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    	WHEN OTHERS THEN
            ROLLBACK TO Query_Aging_lines;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    		END IF;
    		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    End QUERY_AGING_LINES ;



    PROCEDURE GET_BKT_INVOICE_CLASS_INFO
       (p_api_version      IN   NUMBER := 1.0,
        p_init_msg_list    IN   VARCHAR2,
        p_commit           IN   VARCHAR2,
        p_validation_level IN   NUMBER,
        x_return_status    OUT NOCOPY  VARCHAR2,
        x_msg_count        OUT NOCOPY  NUMBER,
        x_msg_data         OUT NOCOPY  VARCHAR2,
        p_filter_mode	   IN   Varchar2,
	p_bucket_line_id   IN   AR_AGING_BUCKET_LINES_B.Aging_Bucket_Line_Id%TYPE,
	p_filter_id 	   IN   Number,
        p_customer_site_use_id IN Number,   -- added by ehuh for bill-to
        p_class            IN   varchar2,
        p_using_paying_rel IN VARCHAR2,
        x_class_count      OUT NOCOPY  Number,
	x_class_amount     OUT NOCOPY  NUMBER )
    IS
        v_tran_sql          varchar2(1000) ;
        v_party_tran_sql    varchar2(1000) ;
        v_paying_party_tran_sql    varchar2(1000) ;
        v_party_billto_tran_sql
                            varchar2(2000) ;   -- added by ehuh for bill-to
        v_sql               varchar2(1000) ;
	    --- Begin - Andre Araujo - 11/09/2004 - Performance fix we will select the aging separately
	    v_days_start        NUMBER;
	    v_days_to           NUMBER;
	    --- End - Andre Araujo - 11/09/2004 - Performance fix we will select the aging separately

    BEGIN

        x_class_count  := 0;     -- added by ehuh for bill-to
        x_class_amount := 0;     -- added by ehuh for bill-to

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage(l_line) ;
        IEX_DEBUG_PUB.LogMessage('GET_BKT_INVOICE_CLASS_INFO --->>  Start <<--- ') ;
        IEX_DEBUG_PUB.LogMessage(l_line) ;
        END IF;


	    --- Begin - Andre Araujo - 11/09/2004 - Performance fix we will select the aging separately
	    select days_start, days_to
	    into v_days_start, v_days_to
	    from ar_aging_bucket_lines
	    where aging_bucket_line_id = p_bucket_line_id;

        v_tran_sql :=
--        'SELECT NVL(count(1), 0), NVL(SUM(ACCTD_AMOUNT_DUE_REMAINING), 0)
--		FROM    ar_payment_schedules 	arp,
--                ar_aging_bucket_lines aabl
--		WHERE   sysdate-arp.due_date >= aabl.days_start
--        and     sysdate-arp.due_date <= aabl.days_to
--        and     arp.class = :class
--        and     arp.status = ''OP''
--        and     aabl.aging_bucket_line_id = :bucket_line_id
--        AND     arp.customer_id = :cust_account_id ' ;
        --Bug5170294. Fix by LKKUMAR. Use Trunc on Dates. Start.
        'SELECT NVL(count(1), 0), NVL(SUM(ACCTD_AMOUNT_DUE_REMAINING), 0)
         FROM    ar_payment_schedules 	arp
         WHERE  (arp.customer_id = :cust_account_id
           and     arp.status = ''OP'')
           and
           (
             trunc(sysdate)-trunc(arp.due_date) >= :days_start
             and trunc(sysdate)-trunc(arp.due_date) <= :days_to
             and     arp.class = :class
           )' ;


      IF NVL(p_using_paying_rel, 'N') = 'Y' THEN
        v_paying_party_tran_sql :=
        'SELECT NVL(count(1), 0), NVL(SUM(ACCTD_AMOUNT_DUE_REMAINING), 0)
		FROM    ar_payment_schedules 	arp,
                ar_aging_bucket_lines   aabl,
                hz_cust_accounts        hzca
		WHERE   trunc(sysdate)-trunc(arp.due_date) >= aabl.days_start
        and     trunc(sysdate)-trunc(arp.due_date) <= aabl.days_to
        and     arp.class = :class
        and     arp.status = ''OP''
        and     arp.customer_id = hzca.cust_account_id
        and     aabl.aging_bucket_line_id = :bucket_line_id
        and     hzca.party_id IN
                            (SELECT :party_id FROM dual
                              UNION
                             SELECT ar.related_party_id
                               FROM ar_paying_relationships_v ar
                              WHERE ar.party_id = :party_id
                                AND TRUNC(sysdate) BETWEEN
                                    TRUNC(NVL(ar.effective_start_date,sysdate)) AND
                                    TRUNC(NVL(ar.effective_end_date,sysdate))  ) ' ;
        --Bug5170294. Fix by LKKUMAR. Use Trunc on Dates. End.
      ELSE
        v_party_tran_sql :=
--        'SELECT NVL(count(1), 0), NVL(SUM(ACCTD_AMOUNT_DUE_REMAINING), 0)
--		FROM    ar_payment_schedules 	arp,
--                ar_aging_bucket_lines   aabl,
--                hz_cust_accounts        hzca
--		WHERE   sysdate-arp.due_date >= aabl.days_start
--        and     sysdate-arp.due_date <= aabl.days_to
--        and     arp.class = :class
--        and     arp.status = ''OP''
--        and     arp.customer_id = hzca.cust_account_id
--        and     aabl.aging_bucket_line_id = :bucket_line_id
--        and     hzca.party_id = :party_id   ' ;
        --Bug5170294. Fix by LKKUMAR. Use Trunc on Dates. Start.
        'SELECT NVL(count(1), 0), NVL(SUM(ACCTD_AMOUNT_DUE_REMAINING), 0)
         FROM    ar_payment_schedules 	arp
         WHERE  (arp.customer_id in (select cust_account_id from hz_cust_accounts where party_id = :party_id)
           and     arp.status = ''OP'')
           and
           (
             trunc(sysdate)-trunc(arp.due_date) >= :days_start
             and trunc(sysdate)-trunc(arp.due_date) <= :days_to
             and     arp.class = :class
           )' ;
           --Bug5170294. Fix by LKKUMAR. Use Trunc on Dates. End.

      END IF;

/* Start added by ehuh for bill_to  */
        v_party_billto_tran_sql :=
--        'SELECT NVL(count(1), 0), NVL(SUM(ACCTD_AMOUNT_DUE_REMAINING), 0)
--		FROM    ar_payment_schedules 	arp,
--                ar_aging_bucket_lines   aabl,
--                hz_cust_accounts        hzca
--		WHERE   sysdate-arp.due_date >= aabl.days_start
--        and     sysdate-arp.due_date <= aabl.days_to
--        and     arp.class = :class
--        and     arp.status = ''OP''
--        and     arp.customer_id = hzca.cust_account_id
--        and     aabl.aging_bucket_line_id = :bucket_line_id
--        and     arp.customer_site_use_id = :customer_site_use_id ' ;
        --Bug5170294. Fix by LKKUMAR. Use Trunc on Dates. Start.
        'SELECT NVL(count(1), 0), NVL(SUM(ACCTD_AMOUNT_DUE_REMAINING), 0)
         FROM    ar_payment_schedules 	arp
         WHERE  (arp.customer_site_use_id = :customer_site_use_id
           and     arp.status = ''OP'')
           and
           (
             trunc(sysdate)-trunc(arp.due_date) >= :days_start
             and trunc(sysdate)-trunc(arp.due_date) <= :days_to
             and     arp.class = :class
           )' ;
        --Bug5170294. Fix by LKKUMAR. Use Trunc on Dates. End.

/* End added by ehuh for bill-to */

        if p_filter_mode = 'PARTY' then
                v_sql := v_party_tran_sql ;
        elsif p_filter_mode = 'BILLTO' then
            v_sql := v_party_billto_tran_sql ;
        else
            v_sql := v_tran_sql  ;
        End If ;

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage('SQL Executed --> ' || v_sql) ;
        END IF;

        Begin

          if p_filter_mode = 'PARTY' and NVL(p_using_paying_rel, 'N') = 'Y' then
               EXECUTE IMMEDIATE v_sql
                   INTO   x_class_count,
                          x_class_amount
                   USING  p_class,
                          p_bucket_line_id,
                          p_filter_id, p_filter_id ;
          else
               EXECUTE IMMEDIATE v_sql
                   INTO   x_class_count,
                          x_class_amount
                   USING  p_filter_id,
				          v_days_start,
						  v_days_to,
						  p_class;
          				 -- fix bug #4110299 p_class,
                         -- fix bug #4110299 p_bucket_line_id,
                         -- fix bug #4110299 p_filter_id ;
          end if;
        Exception
            WHEN  NO_DATA_FOUND THEN
                  x_class_count := 0; x_class_amount := 0;
            WHEN   OTHERS THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                IEX_DEBUG_PUB.LogMessage(SQLCODE || '  ' ||  SQLERRM) ;
                END IF;
        End ;

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage(l_line) ;
        IEX_DEBUG_PUB.LogMessage('GET_BKT_INVOICE_CLASS_INFO --->>  End <<--- ') ;
        IEX_DEBUG_PUB.LogMessage(l_line) ;
        END IF;

    END ;

    -- Added as a part of OKL changes
    PROCEDURE GET_CNSLD_INVOICE_COUNT
       (p_api_version      IN   NUMBER := 1.0,
        p_init_msg_list    IN   VARCHAR2,
        p_commit           IN   VARCHAR2,
        p_validation_level IN   NUMBER,
        x_return_status    OUT NOCOPY  VARCHAR2,
        x_msg_count        OUT NOCOPY  NUMBER,
        x_msg_data         OUT NOCOPY  VARCHAR2,
        p_filter_mode	   IN   Varchar2,
	    p_bucket_line_id   IN   AR_AGING_BUCKET_LINES_B.Aging_Bucket_Line_Id%TYPE,
	    p_filter_id 	   IN   Number,
        p_customer_site_use_id IN Number,
        p_using_paying_rel IN VARCHAR2,
        x_count           OUT NOCOPY  Number,
	    x_amount          OUT NOCOPY  NUMBER)
    IS
        v_cust_cnsld_sql     varchar2(2000) ;
        v_party_cnsld_sql    varchar2(2000) ;
        v_party_billto_cnsld_sql
                            varchar2(2000) ;
        v_sql               varchar2(3000) ;


        -- Bind Variables
        b_class             AR_PAYMENT_SCHEDULES.CLASS%TYPE;
        b_status            AR_PAYMENT_SCHEDULES.STATUS%TYPE;
        b_interface_attr    RA_CUSTOMER_TRX.INTERFACE_HEADER_ATTRIBUTE9%TYPE;
        b_interface_context RA_CUSTOMER_TRX.INTERFACE_HEADER_CONTEXT%TYPE;

    BEGIN

        b_interface_attr    := 'CURE' ;
        b_interface_context := 'OKL_CONTRACTS' ;

        x_count  := 0;
        x_amount := 0;

        b_class          := 'INV' ;
        b_status         := 'OP'  ;

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage(l_line) ;
        IEX_DEBUG_PUB.LogMessage('GET_CNSLD_INVOICE_COUNT --->>  Start <<--- ') ;
        IEX_DEBUG_PUB.LogMessage(l_line) ;
        IEX_DEBUG_PUB.LogMessage('Hello') ;
        END IF;

        v_cust_cnsld_sql :=
        'SELECT count(distinct ocahb.id)
		FROM    ar_payment_schedules  arp,
                ar_aging_bucket_lines aabl,
                ra_customer_trx       rct,
                okl_cnsld_ar_strms_b  ocasb,
                OKL_CNSLD_AR_LINES_B ocalb,
                OKL_CNSLD_AR_HDRS_B ocahb
		WHERE   (:l_date - arp.due_date)  >= aabl.days_start
        and     (:l_date - arp.due_date)  <= aabl.days_to
        and     arp.class = :l_class
        and    rct.customer_trx_id = arp.customer_trx_id
        and     ocasb.receivables_invoice_id = rct.customer_trx_id
        and     ocalb.id = ocasb.lln_id
        and     ocahb.id = ocalb.cnr_id
        and     rct.interface_header_attribute9 <> :l_interface_attr
        and     rct.interface_header_context = :l_interface_context
        and     arp.status = :l_status
        and     aabl.aging_bucket_line_id = :bucket_line_id
        AND     arp.customer_id = :cust_account_id' ;


      IF NVL(p_using_paying_rel, 'N') = 'Y' THEN
        v_party_cnsld_sql :=
        'SELECT count(distinct ocahb.id)
		FROM    ar_payment_schedules  arp,
                ar_aging_bucket_lines aabl,
                ra_customer_trx       rct,
                okl_cnsld_ar_strms_b  ocasb,
                OKL_CNSLD_AR_LINES_B ocalb,
                OKL_CNSLD_AR_HDRS_B ocahb,
                HZ_CUST_ACCOUNTS    hzca
		WHERE   (:l_date - arp.due_date)  >= aabl.days_start
        and     (:l_date - arp.due_date)  <= aabl.days_to
        and     arp.class = :l_class
        and     rct.customer_trx_id = arp.customer_trx_id
        and     ocasb.receivables_invoice_id = rct.customer_trx_id
        and     ocalb.id = ocasb.lln_id
        and     ocahb.id = ocalb.cnr_id
        and     rct.interface_header_attribute9 <> :l_interface_attr
        and     rct.interface_header_context = :l_interface_context
        and     arp.status = :l_status
        and     aabl.aging_bucket_line_id = :bucket_line_id
        AND     arp.customer_id = hzca.cust_account_id
        AND     hzca.party_id IN
                            (SELECT :party_id FROM dual
                              UNION
                             SELECT ar.related_party_id
                               FROM ar_paying_relationships_v ar
                              WHERE ar.party_id = :party_id
                                AND TRUNC(sysdate) BETWEEN
                                    TRUNC(NVL(ar.effective_start_date,sysdate)) AND
                                    TRUNC(NVL(ar.effective_end_date,sysdate))  ) ' ;

      ELSE
        v_party_cnsld_sql :=
        'SELECT count(distinct ocahb.id)
		FROM    ar_payment_schedules  arp,
                ar_aging_bucket_lines aabl,
                ra_customer_trx       rct,
                okl_cnsld_ar_strms_b  ocasb,
                OKL_CNSLD_AR_LINES_B ocalb,
                OKL_CNSLD_AR_HDRS_B ocahb,
                HZ_CUST_ACCOUNTS    hzca
		WHERE   (:l_date - arp.due_date)  >= aabl.days_start
        and     (:l_date - arp.due_date)  <= aabl.days_to
        and     arp.class = :l_class
        and     rct.customer_trx_id = arp.customer_trx_id
        and     ocasb.receivables_invoice_id = rct.customer_trx_id
        and     ocalb.id = ocasb.lln_id
        and     ocahb.id = ocalb.cnr_id
        and     rct.interface_header_attribute9 <> :l_interface_attr
        and     rct.interface_header_context = :l_interface_context
        and     arp.status = :l_status
        and     aabl.aging_bucket_line_id = :bucket_line_id
        AND     arp.customer_id = hzca.cust_account_id
        AND     hzca.party_id = :party_id ' ;

      END IF;

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage('') ;
        IEX_DEBUG_PUB.LogMessage(v_party_cnsld_sql) ;
        END IF;



        v_party_billto_cnsld_sql :=
        'SELECT count(distinct ocahb.id)
		FROM    ar_payment_schedules  arp,
                ar_aging_bucket_lines aabl,
                ra_customer_trx       rct,
                okl_cnsld_ar_strms_b  ocasb,
                OKL_CNSLD_AR_LINES_B ocalb,
                OKL_CNSLD_AR_HDRS_B ocahb,
                HZ_CUST_ACCOUNTS    hzca
		WHERE   (:l_date - arp.due_date)  >= aabl.days_start
        and     (:l_date - arp.due_date)  <= aabl.days_to
        and     arp.class = :l_class
        and     rct.customer_trx_id = arp.customer_trx_id
        and     ocasb.receivables_invoice_id = rct.customer_trx_id
        and     ocalb.id = ocasb.lln_id
        and     ocahb.id = ocalb.cnr_id
        and     rct.interface_header_attribute9 <> :l_interface_attr
        and     rct.interface_header_context = :l_interface_context
        and     arp.status = :l_status
        and     aabl.aging_bucket_line_id = :bucket_line_id
        AND     arp.customer_id = hzca.cust_account_id
        AND     arp.customer_site_use_id = :customer_site_use_id' ;


        if p_filter_mode = 'PARTY' then
           v_sql := v_party_cnsld_sql ;
        elsif p_filter_mode = 'CUST' then
            v_sql := v_cust_cnsld_sql  ;
        else
            v_sql := v_party_billto_cnsld_sql ;
        End If ;

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage('SQL Executed --> ' || v_sql) ;
        END IF;

        Begin

            IF NVL(p_using_paying_rel, 'N') = 'Y' THEN
               EXECUTE IMMEDIATE v_sql
                  INTO    x_count
                   USING  l_date,
                          l_date,
                          b_class,
                          b_interface_attr,
                          b_interface_context,
                          b_status,
                          p_bucket_line_id,
                          p_filter_id, p_filter_id;

            ELSE
               EXECUTE IMMEDIATE v_sql
                  INTO    x_count
                   USING  l_date,
                          l_date,
                          b_class,
                          b_interface_attr,
                          b_interface_context,
                          b_status,
                          p_bucket_line_id,
                          p_filter_id ;

            END IF;
        Exception
            WHEN  NO_DATA_FOUND THEN
                  x_count := 0; x_amount := 0;
            WHEN   OTHERS THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                IEX_DEBUG_PUB.LogMessage(SQLCODE || '  ' ||  SQLERRM) ;
                END IF;
        End ;

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage(l_line) ;
        IEX_DEBUG_PUB.LogMessage('GET_CNSLD_INVOICE_COUNT --->>  End <<--- ') ;
        IEX_DEBUG_PUB.LogMessage(l_line) ;
        END IF;
    EXCEPTION
        WHEN OTHERS then
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            	IEX_DEBUG_PUB.LogMessage(' GET_CNSLD_INVOICE_COUNT - MAIN ' ||
                         SQLCODE || '  ' ||  SQLERRM) ;
            END IF;

    END GET_CNSLD_INVOICE_COUNT ;

BEGIN
    l_line    :=  '-----------------------------------------' ;
    PG_DEBUG := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
END iex_aging_buckets_pkg ;
--
--
--
--

/
