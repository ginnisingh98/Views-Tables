--------------------------------------------------------
--  DDL for Package Body AR_CALC_LATE_CHARGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CALC_LATE_CHARGE" AS
/* $Header: ARCALATB.pls 120.12.12010000.12 2010/02/09 09:35:12 npanchak ship $           */

    l_debug_flag        	varchar2(1);
    pg_last_updated_by          number;
    pg_last_update_login        number;
    l_disputed_items		varchar2(1);
    l_request_id		number;

    TYPE CurrencyCodeType  IS TABLE OF VARCHAR2(15)  INDEX BY BINARY_INTEGER;
    TYPE PrecisionType     IS TABLE OF NUMBER(1)     INDEX BY BINARY_INTEGER;
    TYPE MauType           IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
    NextElement            BINARY_INTEGER := 0;
    CurrencyCode           CurrencyCodeType;
    Precision              PrecisionType;
    Mau                    MauType;


    CURSOR CurrencyCursor( cp_currency_code VARCHAR2 ) IS
    SELECT  precision,
            minimum_accountable_unit
    FROM    fnd_currencies
    WHERE   currency_code = cp_currency_code;

PROCEDURE GetCurrencyDetails( p_currency_code IN  VARCHAR2,
                              p_precision     OUT NOCOPY NUMBER,
                              p_mau           OUT NOCOPY NUMBER ) IS
    i BINARY_INTEGER := 0;
BEGIN
    WHILE i < NextElement
    LOOP
        EXIT WHEN CurrencyCode(i) = p_currency_code;
        i := i + 1;
    END LOOP;

    IF i = NextElement
    THEN
        OPEN CurrencyCursor( p_currency_code );
        DECLARE
            l_Precision NUMBER;
            l_Mau       NUMBER;
        BEGIN
            FETCH CurrencyCursor
            INTO    l_Precision,
                    l_Mau;
            IF CurrencyCursor%NOTFOUND THEN
                RAISE NO_DATA_FOUND;
            END IF;
            Precision(i)    := l_Precision;
            Mau(i)          := l_Mau;
        END;
        CLOSE CurrencyCursor;
        CurrencyCode(i) := p_currency_code;
        NextElement     := i + 1;
    END IF;
    p_precision := Precision(i);
    p_mau       := Mau(i);
EXCEPTION
    WHEN OTHERS THEN
        IF CurrencyCursor%ISOPEN THEN
           CLOSE CurrencyCursor;
        END IF;
    RAISE;
END;

FUNCTION Currency_Round(p_amount		IN	NUMBER,
		        p_currency_code		IN	VARCHAR2) RETURN NUMBER IS
    l_precision NUMBER(1);
    l_mau       NUMBER;
BEGIN
    GetCurrencyDetails( p_currency_code, l_precision, l_mau );
    IF l_mau IS NOT NULL
    THEN
        RETURN( ROUND( p_amount / l_mau) * l_mau );
    ELSE
        RETURN( ROUND( p_amount, l_precision ));
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END Currency_Round;


/*----------------------------------------------------|
| PROCEDURE debug                                     |
|-----------------------------------------------------|
|  Parameters                                         |
|                 mesg        in  varchar2            |
|-----------------------------------------------------|
|  Description                                        |
|           Takes message string as an argument and   |
|           outputs to request log depending on debug |
|           flag                                      |
|----------------------------------------------------*/


procedure debug (mesg in varchar2) is

begin
        FND_FILE.PUT_LINE( FND_FILE.LOG,mesg);
end debug;

/* Function which returns the next value for the interest_header_id
   This is required as the sequence value can not be derived in
   a subquery */
FUNCTION get_next_hdr_id RETURN NUMBER IS
  l_next_hdr_id	   NUMBER;
BEGIN

  select ar_interest_headers_s.nextval
  into   l_next_hdr_id
  from dual;

  return l_next_hdr_id;

END get_next_hdr_id;

Function first_day(p_calculation_date    IN     DATE ) RETURN DATE IS
  /* Function which returns the first day of the month corresponding to
     the input date */
begin

  return(to_date(('01/'||to_char(p_calculation_date,'MM/YYYY')),'DD/MM/YYYY'));
  --return(last_day(add_months(p_calculation_date,-1))+1);

end first_day;


Function Calculate_Interest (p_amount 	       		IN	NUMBER,
                             p_formula         		IN	VARCHAR2,
                             p_days_late     		IN	NUMBER,
                             p_interest_rate  		IN	NUMBER,
                             p_days_in_period		IN	NUMBER,
                             p_currency   	     	IN	VARCHAR2,
			     p_payment_schedule_id	IN	NUMBER DEFAULT NULL) return NUMBER IS
l_interest      	     number;
BEGIN

   IF l_debug_flag = 'Y' THEN
	debug('ar_calc_late_charge.Calculate_Interest()+ ');
	debug('Input Parameters.... ');
        debug('p_payment_schedule_id	:	'||p_payment_schedule_id);
	debug('p_amount			:	'|| p_amount);
	debug('p_formula		:	'||p_formula);
 	debug('p_days_late		:	'|| p_days_late);
	debug('p_interest_rate		:	'||p_interest_rate);
	debug('p_days_in_period		:	'||p_days_in_period);
	debug('p_currency		:	'||p_currency);
   END IF;

  /* The p_forumla can be N (Meaning SIMPLE), Y (COMPOUND) or F (FLAT_RATE). Based on this, the calculation of
     the interest will be different.
     SIMPLE:
     	(Interest Rate/Days in Period)/100 * Invoice Amount * Days Late
     COMPOUND:
	(Interest Rate/Days in Period)/100 * (Invoice Amount + Interest Already Charged) * Days Late
     AVERAGE_DAILY_BALANCE:
	Average Daily Balance * (Interest Rate) / 100
     FLAT_RATE:
	Overdue Amount * Interest Rate / 100
    */

   IF p_formula = 'N' THEN
	l_interest := (p_interest_rate/p_days_in_period)/100 * p_amount * p_days_late;
   ELSIF p_formula = 'Y' THEN
	/* In this case, the assumption is that the p_amount includes the Interest Already Charged also */
	l_interest := (p_interest_rate/p_days_in_period)/100 * p_amount * p_days_late;
   ELSIF p_formula = 'F' THEN
	l_interest := (p_amount) * (p_interest_rate) / 100;
   END IF;

   IF l_debug_flag = 'Y' THEN
	debug('l_interest before currency rounding : '||l_interest);
   END IF;

   IF l_interest <> 0 THEN
	l_interest := ar_calc_late_charge.currency_round(l_interest,p_currency);
   END IF;

   IF l_debug_flag = 'Y' THEN
	debug('l_interest after currency rounding : '||l_interest);
	debug('ar_calc_late_charge.Calculate_Interest()- ');
   END IF;

   return l_interest;

END Calculate_Interest;


/* Bug 8556955 Added procedure to calculate late charges for Invoices in
   case receipt is reversed.
*/
Procedure Insert_int_rev_rect_overdue( p_fin_charge_date        IN      DATE,
                                       p_worker_number          IN      NUMBER,
                                       p_total_workers          IN      NUMBER) IS

 l_fin_charge_date              DATE;
 l_worker_number                number;
 l_total_workers                number;

BEGIN

   IF l_debug_flag = 'Y' THEN
                debug('Interest_int_rec_rect_overdue+');
   END IF;

            l_fin_charge_date   :=      p_fin_charge_date;
            l_worker_number     :=      p_worker_number;
            l_total_workers     :=      p_total_workers;

Insert into ar_late_charge_trx_t
                (late_charge_trx_id,
                 customer_id,
                 customer_site_use_id,
                 currency_code,
                 customer_trx_id,
                 legal_entity_id,
                 payment_schedule_id,
                 class,
                 amount_due_original,
                 amount_due_remaining,
                 fin_charge_charged,
                 trx_date,
                 cust_trx_type_id,
                 last_charge_date,
                 exchange_rate_type,
                 min_interest_charge,
                 max_interest_charge,
                 overdue_late_pay_amount,
                 original_balance,
                 due_date,
                 receipt_date,
                 finance_charge_date,
                 charge_type,
                 actual_date_closed,
                 interest_rate,
                 interest_days,
                 rate_start_date,
                 rate_end_date,
                 schedule_days_start,
                 schedule_days_to,
                 late_charge_amount,
                 late_charge_type,
                 late_charge_term_id,
                 interest_period_days,
                 interest_calculation_period,
                 charge_on_finance_charge_flag,
                 message_text_id,
                 interest_type,
                 min_fc_invoice_overdue_type,
                 min_fc_invoice_amount,
                 min_fc_invoice_percent,
                 charge_line_type,
                 org_id,
                 request_id,
                 display_flag )
        SELECT   ar_late_charge_trx_s.nextval,
                 b.customer_id,
                 b.customer_site_use_id ,
                 b.invoice_currency_code,
                 b.customer_trx_id,
                 b.legal_entity_id,
                 b.payment_schedule_id,
                 b.class ,
                 b.amount_due_original,
                 b.amount_due_remaining ,
                 b.finance_charge_charged,
                 b.trx_date,
                 b.cust_trx_type_id,
                 NVL(b.last_charge_date, decode(b.finance_charge_charged,
                                                   0, NULL,
                                                   b.last_accrue_charge_date)) last_charge_date,
                 b.exchange_rate_type,
                 b.min_interest_charge,
                 b.max_interest_charge,
                 b.overdue_amt,
                 b.original_balance,
                 b.due_date,
                 NULL,
                 b.fin_charge_date,
                 b.charge_type,
                 b.actual_date_closed,
                 decode(b.interest_type,
                        'CHARGES_SCHEDULE',sched_lines.rate,
                        'FIXED_RATE',b.interest_rate, NULL) interest_rate,
                 least(decode(b.multiple_interest_rates_flag,
                                  'Y',decode(sched_hdrs.schedule_header_type,
                                             'RATE',
                                              nvl(sched_hdrs.end_date,b.eff_fin_charge_date),
                                              b.eff_fin_charge_date),
                                    b.eff_fin_charge_date)) -
                   greatest(decode(b.multiple_interest_rates_flag,
                                  'Y',decode(sched_hdrs.schedule_header_type,
                                             'RATE',sched_hdrs.start_date-1,b.eff_due_date),
                                       b.eff_due_date), b.eff_due_date,b.eff_last_charge_date) interest_days,
                 sched_hdrs.start_date rate_start_date,
                 sched_hdrs.end_date rate_end_date,
                 bucket_lines.days_start schedule_days_start,
                 bucket_lines.days_to  schedule_days_to,
                 decode(b.interest_type,
                        'FIXED_AMOUNT',0,
                        'CHARGE_PER_TIER',0 ,
                              decode(sched_hdrs.schedule_header_type,
                                       'AMOUNT',0,
                                        ar_calc_late_charge.calculate_interest(
                                                           decode(b.charge_on_finance_charge_flag,
							          'F',0,b.overdue_amt),
                                                           b.charge_on_finance_charge_flag,
                                                           least(decode(b.multiple_interest_rates_flag,
                                                                       'Y',decode(sched_hdrs.schedule_header_type,
                                                                                  'RATE',
                                                                                   nvl(sched_hdrs.end_date,
                                                                                         b.eff_fin_charge_date),
                                                                                   b.eff_fin_charge_date),
                                                                       b.eff_fin_charge_date)) -
                                                             greatest(decode(b.multiple_interest_rates_flag,
                                                                       'Y',decode(sched_hdrs.schedule_header_type,
                                                                                  'RATE',sched_hdrs.start_date-1,
                                                                                   b.eff_due_date),
                                                                        b.eff_due_date),b.eff_due_date,
                                                                        b.eff_last_charge_date),
                                                            decode(b.interest_type,
                                                                    'CHARGES_SCHEDULE',sched_lines.rate,
                                                                     'FIXED_RATE',b.interest_rate, NULL),
                                                            b.interest_period_days,
                                                            b.invoice_currency_code,
                                                            b.payment_schedule_id))) late_charge_amount,
                 b.late_charge_type,
                 b.late_charge_term_id,
                 b.interest_period_days,
                 b.interest_calculation_period,
                 b.charge_on_finance_charge_flag,
                 b.message_text_id,
                 b.interest_type,
                 b.min_fc_invoice_overdue_type,
                 b.min_fc_invoice_amount,
                 b.min_fc_invoice_percent,
                 'INTEREST',
                 b.org_id,
                 -1,
                 'Y'
     from (
                select
                      ps.customer_id,
                      decode(ps.class,
                             'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                              ps.customer_site_use_id,
                                                                              ps.org_id),
                             'PMT',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                               ps.customer_site_use_id,
                                                                               ps.org_id),
                              ps.customer_site_use_id) customer_site_use_id,
                      ps.invoice_currency_code,
                      ps.customer_trx_id,
		      int_headers.legal_entity_id,
                      ps.payment_schedule_id,
                      ps.class ,
                      ps.amount_due_original,
                      ps.amount_due_remaining,
                      int_lines.interest_charged finance_charge_charged,
                      ps.trx_date,
                      ps.cust_trx_type_id,
                      cr.receipt_date last_charge_date,
                      cust_site.last_accrue_charge_date ,
                      cust_site.exchange_rate,
                      cust_site.exchange_rate_type,
                      cust_site.min_interest_charge,
                      cust_site.max_interest_charge,
		      nvl(int_lines.outstanding_amount,0) overdue_amt,
		      nvl(int_lines.outstanding_amount,0) original_balance,
                      decode(ps.class,'PMT',ps.trx_date,ps.due_date) due_date,
		      l_fin_charge_date fin_charge_date,
                      ps.actual_date_closed,
                      cust_site.late_charge_type,
                      cust_site.late_charge_term_id    ,
                      cust_site.interest_period_days,
                      cust_site.interest_calculation_period,
                      cust_site.charge_on_finance_charge_flag,
                      cust_site.message_text_id,
                      cust_site.interest_type,
                      cust_site.interest_rate,
                      cust_site.interest_schedule_id,
                      cust_site.min_fc_invoice_overdue_type,
                      cust_site.min_fc_invoice_amount,
                      cust_site.min_fc_invoice_percent,
                      cust_site.multiple_interest_rates_flag,
                      cust_site.hold_charged_invoices_flag,
                      ps.org_id,
                      cust_site.interest_fixed_amount,
                      ps.cash_receipt_id,
                      'OVERDUE' charge_type,
                      decode(cust_site.interest_calculation_period,
                        'DAILY',ps.last_charge_date,
                        'MONTHLY',last_day(ps.last_charge_date)) eff_fin_charge_date,
                      decode(cust_site.interest_calculation_period,
                        'DAILY',nvl(int_lines.payment_date,
                                    decode(int_lines.finance_charge_charged,
                                           0,int_lines.due_date,
                                           int_lines.last_charge_date)),
                        'MONTHLY',first_day(nvl(int_lines.last_charge_date,
                                                decode(int_lines.finance_charge_charged,
                                                       0,int_lines.due_date,
                                                       int_lines.last_charge_date)))) eff_last_charge_date,
                      decode(cust_site.interest_calculation_period,
                             'DAILY',int_lines.due_date,
                             'MONTHLY',first_day(int_lines.due_date)) eff_due_date
                      from ar_interest_lines int_lines,
		      ar_interest_headers int_headers,
                      ar_cash_receipts cr,
                      ar_payment_schedules ps,
                      ar_lc_cust_sites_t cust_site,
                      ar_late_charge_cust_balance_gt bal
                      where ps.customer_id = cust_site.customer_id
                      and   cust_site.customer_site_use_id = decode(ps.class,
                                                       'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                                               ps.customer_site_use_id,
                                                                                               ps.org_id),
                                                       'PMT',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                                              ps.customer_site_use_id,
                                                                                              ps.org_id),
                                                         ps.customer_site_use_id)
                      and   ps.invoice_currency_code = cust_site.currency_code
                      and   mod(nvl(cust_site.customer_site_use_id,0),l_total_workers) =
                                          decode(l_total_workers,l_worker_number,0,l_worker_number)
		      and int_headers.customer_id=cust_site.customer_id
                      and cr.reversal_date is not null
                      and cr.cash_receipt_id=int_lines.cash_receipt_id
                      and ps.payment_schedule_id=int_lines.payment_schedule_id
                      and   ps.org_id = cust_site.org_id
                      and   cust_site.late_charge_calculation_trx in ('OVERDUE_LATE')
                      and int_lines.type='LATE'
		      and int_lines.interest_header_id=int_headers.interest_header_id
--                      and   cust_site.late_charge_type = 'INV'
                   /* Apply Customer Level tolerances */
                     and   cust_site.lc_cust_sites_id = bal.late_charge_cust_sites_id
                     and   cust_site.org_id = bal.org_id
                     and   decode(cust_site.min_fc_balance_overdue_type,
                         'PERCENT',(nvl(cust_site.min_fc_balance_percent,0)
                                    * nvl(bal.customer_open_balance,0)/100),
                         'AMOUNT',nvl(cust_site.min_fc_balance_amount,0),
                            0) <= nvl(bal.customer_overdue_balance,0)
                      and   decode(nvl(cust_site.disputed_transactions_flag,'N'),
                                'N',decode(nvl(ps.amount_in_dispute,0),
                                           0, 'Y','N'),
                                'Y' ) = 'Y'
                      and   decode(cust_site.credit_items_flag,'N',
                            decode (ps.class, 'PMT','N','CM','N','INV',decode(sign(ps.amount_due_original),-1,'N','Y'),'Y'),'Y') = 'Y'
                      and   nvl(ps.receipt_confirmed_flag, 'Y') = 'Y'
                      and ps.last_charge_date > cr.receipt_date
                      and cr.reversal_date < l_fin_charge_date
                      and cr.reversal_date > ps.last_charge_date
                group by ps.customer_id,
                      decode(ps.class,
                             'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                              ps.customer_site_use_id,
                                                                              ps.org_id),
                             'PMT',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                               ps.customer_site_use_id,
                                                                               ps.org_id),
                              ps.customer_site_use_id),
                      ps.invoice_currency_code,
                      ps.customer_trx_id,
                      int_headers.legal_entity_id,
                      ps.payment_schedule_id,
                      ps.class ,
                      ps.amount_due_original,
                      ps.amount_due_remaining,
                      int_lines.interest_charged,
                      ps.trx_date,
                      ps.cust_trx_type_id,
                      cr.receipt_date,
                      cust_site.last_accrue_charge_date,
                      cust_site.exchange_rate,
                      cust_site.exchange_rate_type,
                      cust_site.min_interest_charge,
                      cust_site.max_interest_charge,
                      nvl(int_lines.outstanding_amount,0),
		      nvl(int_lines.outstanding_amount,0),
                      decode(ps.class,'PMT',ps.trx_date,ps.due_date),
		      l_fin_charge_date ,
                      ps.actual_date_closed,
                      cust_site.late_charge_type,
                      cust_site.late_charge_term_id,
                      cust_site.interest_period_days,
                      cust_site.interest_calculation_period,
                      cust_site.charge_on_finance_charge_flag,
                      cust_site.message_text_id,
                      cust_site.interest_type,
                      cust_site.interest_rate,
                      cust_site.interest_schedule_id,
                      cust_site.min_fc_invoice_overdue_type,
                      cust_site.min_fc_invoice_amount,
                      cust_site.min_fc_invoice_percent,
                      cust_site.multiple_interest_rates_flag,
                      cust_site.hold_charged_invoices_flag,
                      ps.org_id,
                      cust_site.interest_fixed_amount,
                      ps.cash_receipt_id,
                      'OVERDUE',
                      decode(cust_site.interest_calculation_period,
                        'DAILY',ps.last_charge_date,
                        'MONTHLY',last_day(ps.last_charge_date)),
                      decode(cust_site.interest_calculation_period,
                        'DAILY',nvl(int_lines.payment_date,
                                    decode(int_lines.finance_charge_charged,
                                           0,int_lines.due_date,
                                           int_lines.last_charge_date)),
                        'MONTHLY',first_day(nvl(int_lines.last_charge_date,
                                                decode(int_lines.finance_charge_charged,
                                                       0,int_lines.due_date,
                                                       int_lines.last_charge_date)))),
                      decode(cust_site.interest_calculation_period,
                             'DAILY',int_lines.due_date,
                             'MONTHLY',first_day(int_lines.due_date))
                             ) b,
                         ar_charge_schedule_hdrs sched_hdrs,
                         ar_charge_schedule_lines  sched_lines,
                         ar_aging_bucket_lines bucket_lines
                where b.interest_schedule_id = sched_hdrs.schedule_id(+)
                and   sched_hdrs.schedule_header_id = sched_lines.schedule_header_id(+)
                and   sched_hdrs.schedule_id = sched_lines.schedule_id(+)
                and    nvl(sched_hdrs.status,'A') = 'A'
                and   sched_lines.aging_bucket_id = bucket_lines.aging_bucket_id(+)
                and   sched_lines.aging_bucket_line_id = bucket_lines.aging_bucket_line_id(+)
                /* Condition 1: days late should be between the bucket lines start and end days */
                and   (l_fin_charge_date- b.due_date) >= nvl(bucket_lines.days_start,(l_fin_charge_date- b.due_date))
                and   (l_fin_charge_date - b.due_date) <= nvl(bucket_lines.days_to,(l_fin_charge_date- b.due_date))
                /* Condition 2:
                   Start_date of the schedule should be less than or equal to the finance charge date */
                and   nvl(sched_hdrs.start_date,l_fin_charge_date) <= l_fin_charge_date
               /* condition 3:
                  If multiple interest rates have to be used, end date of the schedule should be greater than
                  or equal to the due date or the date from which we are calculating the charge
                  Otherwise, the end_date should either be null or it should be greater than the
                  due_date
                */
                and  (decode(b.multiple_interest_rates_flag,'Y',
                             decode(sched_hdrs.schedule_header_type,
                                    'RATE',greatest(b.due_date,nvl(b.last_charge_date,b.due_date)),
                                    b.due_date),
                             b.due_date) <= sched_hdrs.end_date
                       OR sched_hdrs.end_date IS NULL )
                /* Condition 4: If multiple rates need not be used, we should pick up the rate
                   that is effective on the due_date of the transaction.
                   Also note that the multiple interest rates are used only for Interest
                   Calculation and only when rates are used*/
                and decode(b.multiple_interest_rates_flag,'Y',
                       decode(sched_hdrs.schedule_header_type,
                               'RATE',sched_hdrs.start_date,
                               b.due_date),
                       b.due_date )>= nvl(sched_hdrs.start_date,b.due_date);


   IF l_debug_flag = 'Y' THEN
        debug('Interest_int_rec_rect_overdue-');
   END IF;




END;


/*========================================================================+
  Update the amount by distributing applicable interest amount evenly
  across the all late charge interest rows.
 ========================================================================*/


/*Late charge Case of charge per tier.*/
/*Enhancement 6469663*/
PROCEDURE update_interest_amt(p_line_type in VARCHAR2) IS

  CURSOR recordPerCust(l_line_type IN VARCHAR2) IS
  SELECT count(*) reccount,sum(amount_due_original) total_due_org,
         CUSTOMER_ID,CUSTOMER_SITE_USE_ID,SCHEDULE_DAYS_START,SCHEDULE_DAYS_TO,CURRENCY_CODE,
         LATE_CHARGE_AMOUNT,LATE_CHARGE_TYPE,ORG_ID
  FROM  AR_LATE_CHARGE_TRX_T
  WHERE INTEREST_TYPE = 'CHARGE_PER_TIER'
  /*and   LATE_CHARGE_TYPE = l_charge_type /*'INV'*/
  AND   CHARGE_LINE_TYPE = l_line_type   /*'INTEREST' /* l_line_type*/
  AND OVERDUE_LATE_PAY_AMOUNT > 0
  AND DECODE (MIN_FC_INVOICE_OVERDUE_TYPE,
                 'AMOUNT',MIN_FC_INVOICE_AMOUNT ,
                 'PERCENT',(nvl(MIN_FC_INVOICE_PERCENT,0) * AMOUNT_DUE_ORIGINAL/100),
                            nvl(ORIGINAL_BALANCE,0)) <= ORIGINAL_BALANCE
  GROUP BY
  CUSTOMER_ID,
  CUSTOMER_SITE_USE_ID,
  SCHEDULE_DAYS_START,
  SCHEDULE_DAYS_TO,
  CURRENCY_CODE,
  LATE_CHARGE_AMOUNT,
  LATE_CHARGE_TYPE,
  ORG_ID;

  CURSOR trx_t(l_line_type IN VARCHAR2) IS
  SELECT LATE_CHARGE_TRX_ID,CUSTOMER_ID,CUSTOMER_SITE_USE_ID,SCHEDULE_DAYS_START,SCHEDULE_DAYS_TO,CURRENCY_CODE,
         LATE_CHARGE_TYPE,ORG_ID,AMOUNT_DUE_ORIGINAL
  FROM AR_LATE_CHARGE_TRX_T
  WHERE INTEREST_TYPE = 'CHARGE_PER_TIER'
/*  and   LATE_CHARGE_TYPE =  l_charge_type /*'INV'*/
  AND   CHARGE_LINE_TYPE =  l_line_type /*'INTEREST';  /* l_line_type;*/
  AND OVERDUE_LATE_PAY_AMOUNT > 0
  AND DECODE (MIN_FC_INVOICE_OVERDUE_TYPE,
                 'AMOUNT',MIN_FC_INVOICE_AMOUNT ,
                 'PERCENT',(nvl(MIN_FC_INVOICE_PERCENT,0) * AMOUNT_DUE_ORIGINAL/100),
                            nvl(ORIGINAL_BALANCE,0)) <= ORIGINAL_BALANCE;


 TYPE rec_per_customer IS  RECORD
 (
   rec_per_tier         NUMBER,
   total_due_org        NUMBER,
   customer_id          NUMBER,
   customer_site_use_id NUMBER,
   schdl_start          NUMBER,
   schdl_to             NUMBER,
   currency_code        VARCHAR2(15),
   late_charge_type     VARCHAR2(5),
   curr_code		VARCHAR2(15),
   org_id               NUMBER,
   late_charge_amt      NUMBER,
   last_amt             NUMBER
 );
 TYPE rec_per_cust_tier is  table of rec_per_customer index by binary_integer;
 p_rec_cust_per_tier rec_per_cust_tier;

 TYPE cust_trx_id is table of ar_late_charge_trx_t.late_charge_trx_id%TYPE INDEX BY BINARY_INTEGER;
 p_cust_sites_id cust_trx_id;


 TYPE lc_per_trx is  table of ar_late_charge_trx_t.late_charge_amount%type INDEX BY BINARY_INTEGER;
 p_lc_per_trx lc_per_trx;

 i number;
 j number;
 l_temp_amt number;
BEGIN
 IF l_debug_flag = 'Y' THEN
   debug('update interest amount+');
 END IF;

/*Bug 8559863 Restrict to 0 out late charge for charge per tier case. It results in inaccurate late charges
  for other scenario. Fixed as part of this bug*/
 UPDATE ar_late_charge_trx_t SET late_charge_amount =  0 where amount_due_original < 0
 AND INTEREST_TYPE = 'CHARGE_PER_TIER';
 i := 0;
 FOR recpertier in recordPerCust(p_line_type)
 LOOP
    BEGIN
     i := i+1;
     p_rec_cust_per_tier(i).rec_per_tier          := recpertier.reccount;
     p_rec_cust_per_tier(i).customer_id           := recpertier.customer_id;
     p_rec_cust_per_tier(i).customer_site_use_id  := recpertier.customer_site_use_id;
     p_rec_cust_per_tier(i).schdl_start           := recpertier.schedule_days_start;
     p_rec_cust_per_tier(i).schdl_to              := recpertier.schedule_days_to;
     p_rec_cust_per_tier(i).currency_code         := recpertier.currency_code;
     p_rec_cust_per_tier(i).late_charge_type      := recpertier.late_charge_type;
     p_rec_cust_per_tier(i).curr_code             := recpertier.currency_code;
     p_rec_cust_per_tier(i).org_id		  := recpertier.org_id;
     p_rec_cust_per_tier(i).total_due_org         := recpertier.total_due_org;
     p_rec_cust_per_tier(i).late_charge_amt       := recpertier.late_charge_amount;
     p_rec_cust_per_tier(i).last_amt              := recpertier.late_charge_amount;
     EXCEPTION
     WHEN OTHERS THEN
     debug('Error ' ||substr( sqlerrm,1,50));
     END;
 END LOOP;

 j := 0;
 FOR lc_trx in trx_t(p_line_type)
 LOOP
   FOR trx_count in 1.. p_rec_cust_per_tier.count
   LOOP
     IF p_rec_cust_per_tier(trx_count).customer_id             = lc_trx.customer_id
       AND p_rec_cust_per_tier(trx_count).currency_code	       = lc_trx.currency_code
       AND p_rec_cust_per_tier(trx_count).schdl_start 	       = lc_trx.schedule_days_start
       AND p_rec_cust_per_tier(trx_count).schdl_to             = lc_trx.schedule_days_to
       AND p_rec_cust_per_tier(trx_count).late_charge_type     = lc_trx.late_charge_type
       AND p_rec_cust_per_tier(trx_count).customer_site_use_id = lc_trx.customer_site_use_id
       AND p_rec_cust_per_tier(trx_count).org_id               = lc_trx.org_id
     THEN
       j := j+1;
       IF p_rec_cust_per_tier(trx_count).rec_per_tier = 1 THEN
         p_lc_per_trx(j)      := p_rec_cust_per_tier(trx_count).last_amt;
         p_cust_sites_id(j)   := lc_trx.late_charge_trx_id;
       ELSE
         l_temp_amt	      := Currency_round((lc_trx.amount_due_original/p_rec_cust_per_tier(trx_count).total_due_org)*p_rec_cust_per_tier(trx_count).late_charge_amt,p_rec_cust_per_tier(trx_count).curr_code);

         IF p_rec_cust_per_tier(trx_count).last_amt <= l_temp_amt and p_rec_cust_per_tier(trx_count).last_amt >= 0 THEN
            l_temp_amt          :=p_rec_cust_per_tier(trx_count).last_amt ;
         END IF;

         p_lc_per_trx(j)      := l_temp_amt;
         p_cust_sites_id(j)   := lc_trx.late_charge_trx_id;
         p_rec_cust_per_tier(trx_count).rec_per_tier := p_rec_cust_per_tier(trx_count).rec_per_tier -1;
         p_rec_cust_per_tier(trx_count).last_amt := p_rec_cust_per_tier(trx_count).last_amt - l_temp_amt;
       END IF;
     END IF;
   END LOOP;
 END LOOP;
  IF l_debug_flag = 'Y' THEN
    debug('update interest amount : count  of record '  || p_lc_per_trx.count );
  END IF;
  IF p_lc_per_trx.count > 0 THEN
    IF l_debug_flag = 'Y' THEN
      FOR rec in p_cust_sites_id.FIRST..p_cust_sites_id.LAST
      LOOP
        debug('TRX id  ' || p_cust_sites_id(rec));
        debug('LC Amt  ' || p_lc_per_trx(rec));
      END LOOP;
    END IF;
    FORALL trxindex in p_lc_per_trx.FIRST..p_lc_per_trx.LAST
      UPDATE ar_late_charge_trx_t set late_charge_amount = p_lc_per_trx(trxindex)
      WHERE late_charge_trx_id = p_cust_sites_id(trxindex);
  END IF;
 IF l_debug_flag = 'Y' THEN
   debug('update interest amount-');
 END IF;
END update_interest_amt;


/*========================================================================+
   Returns the site_use_id of a Late Charge Site associated with the
   customers address if present else return NULL.
 ========================================================================*/

FUNCTION get_late_charge_site (
                      p_customer_id  IN		NUMBER,
		      p_org_id	     IN		NUMBER) RETURN NUMBER IS

  l_late_charge_site_use_id hz_cust_site_uses.site_use_id%type;

BEGIN

  select site_uses.site_use_id
  into   l_late_charge_site_use_id
  from   hz_cust_acct_sites acct_site,
         hz_cust_site_uses site_uses
  where  acct_site.cust_account_id    = p_customer_id
  and    site_uses.cust_acct_site_id    = acct_site.cust_acct_site_id
  and    site_uses.site_use_code = 'LATE_CHARGE'
  and    site_uses.org_id = p_org_id
  and    site_uses.status = 'A';

  return l_late_charge_site_use_id;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      return to_number(NULL);

    WHEN OTHERS THEN
      raise;

END get_late_charge_site;

/*=======================================================================+
  If a given site is defined as a Bill To and a Late Charges site, the
  site_use_id associated with the Bill To Site use will be stored in
  hz_customer_profiles. Otherwise, the site_use_id associated with the
  Late Charges site use will be stored in hz_customer_profiles. This
  function returns the appropriate site_use_id to be joined with the
  hz_customer_profiles to get the profile set up
 =======================================================================*/

Function get_profile_class_site_use_id(
				p_site_use_id	IN	NUMBER,
				p_org_id	IN	NUMBER) RETURN NUMBER IS
 l_profile_class_site_use_id	number;

BEGIN

    /* check if there is a row in customer profiles using this site_use_id
       if found, regardless of it's site_use_code, return that site_use_id */

     select site_use_id
     into l_profile_class_site_use_id
     from hz_customer_profiles
     where site_use_id = p_site_use_id;

     return l_profile_class_site_use_id;

EXCEPTION WHEN NO_DATA_FOUND THEN
  BEGIN
      select site_use_id
        into l_profile_class_site_use_id
        from hz_customer_profiles
       where site_use_id in ( select site_use_id
                              from hz_cust_site_uses
                              where cust_acct_site_id =
                                  ( SELECT cust_acct_site_id
                                    FROM hz_cust_site_uses
                                    WHERE site_use_id = p_site_use_id)
                                and status = 'A'
                                and site_use_code in ('BILL_TO','LATE_CHARGE'));
      return l_profile_class_site_use_id;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      return null;
   WHEN TOO_MANY_ROWS THEN
      BEGIN
       select site_use_id
        into l_profile_class_site_use_id
        from hz_customer_profiles
       where site_use_id in ( select site_use_id
                              from hz_cust_site_uses
                              where cust_acct_site_id =
                                  ( SELECT cust_acct_site_id
                                    FROM hz_cust_site_uses
                                    WHERE site_use_id = p_site_use_id)
                                and status = 'A'
                                and site_use_code = 'BILL_TO');

        return l_profile_class_site_use_id;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         return null;
      END;

   END;

END get_profile_class_site_use_id;

/*==============================================================
  Function which returns the valid bill to site associated with
  a given site
  =============================================================*/
FUNCTION get_bill_to_site_use_id(p_customer_id  IN NUMBER,
                                 p_site_use_id  IN NUMBER,
				 p_org_id	IN NUMBER)
                 RETURN NUMBER IS
  l_cust_acct_site_id      number;
  l_bill_to_site_use_id	   number;
  l_site_use_code          varchar2(30);
BEGIN
  /* Check if the passed site_use_id corresponds to a bill_to use */
  select cust_acct_site_id,
         site_use_code
   into  l_cust_acct_site_id,
         l_site_use_code
   from  hz_cust_site_uses
   where site_use_id = p_site_use_id
    and  org_id = p_org_id;

   IF l_site_use_code = 'BILL_TO' THEN
      return p_site_use_id;
   ELSE
     BEGIN
       /* Check if the passed site has a bill to usage */
       select site_use_id
       into   l_bill_to_site_use_id
       from   hz_cust_site_uses
       where cust_acct_site_id = l_cust_acct_site_id
        and  site_use_code = 'BILL_TO'
        and  org_id = p_org_id;

       return l_bill_to_site_use_id;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         BEGIN
            /* Get the primary bill to site */
            select site_use.site_use_id
              into l_bill_to_site_use_id
              from hz_cust_site_uses site_use,
                   hz_cust_acct_sites sites
             where sites.cust_account_id = p_customer_id
               and sites.bill_to_flag = 'P'
               and sites.status ='A'
               and sites.cust_acct_site_id = site_use.cust_acct_site_id
               and site_use.site_use_code = 'BILL_TO'
               and site_use.org_id = p_org_id;

            return l_bill_to_site_use_id;
         EXCEPTION WHEN OTHERS THEN
            return NULL;
         END;
      END;
    END IF;
END get_bill_to_site_use_id;

/*=======================================================================+
  Function which returns the next date on which a debit or a credit item
  is created for a customer, site, currency, org combination. This is with
  respect to the input as_of_date. If it doesn't find any, it returns the
  finance charge date. This is used in calculating the average daily balance
  =======================================================================*/
Function get_next_activity_date(p_customer_id           IN      NUMBER,
                                p_site_use_id           IN      NUMBER,
                                p_currency_code         IN      VARCHAR2,
                                p_org_id                IN      NUMBER,
                                p_post_bill_debit       IN      VARCHAR2,
                                p_as_of_date            IN      DATE,
                                p_fin_charge_date       IN      DATE) RETURN DATE IS
  l_next_date		date;
  l_next_bill_date	date;

BEGIN

     select min(billing_date)-1
     into   l_next_bill_date
     from   ar_cons_inv
     where  customer_id = p_customer_id
     and    site_use_id = p_site_use_id
     and    currency_code = p_currency_code
     and    org_id = p_org_id
     and    billing_date > p_as_of_date
     and    billing_date <= p_fin_charge_date
     and    status in ('IMPORTED','ACCEPTED','FINAL');

     IF l_next_bill_date IS NULL THEN
        l_next_bill_date := p_fin_charge_date;
     END IF;

  select min(trx_date) -1
    into l_next_date
    from ar_payment_schedules ps
    where customer_id = p_customer_id
    and   decode(ps.class,
          'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                           ps.customer_site_use_id,
                                                           ps.org_id),
          'PMT',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                            ps.customer_site_use_id,
                                                            ps.org_id),
           ps.customer_site_use_id) =  p_site_use_id
    and   ps.invoice_currency_code = p_currency_code
    and   ps.org_id = p_org_id
    and   decode(p_post_bill_debit,
                 'INCLUDE_DEBIT_ITEM','Y',
                 'EXCLUDE_DEBIT_ITEM',decode(ps.class,
					     'PMT','Y',
					     'CM','Y',
					     'N')) = 'Y'
    and   trx_date > p_as_of_date
    and   trx_date <= p_fin_charge_date;

    IF l_next_date IS NULL THEN
       l_next_date := p_fin_charge_date;
    END IF;

    IF l_next_bill_date < l_next_date THEN
      return l_next_bill_date;
    ELSE
      return l_next_date;
    END IF;

EXCEPTION WHEN NO_DATA_FOUND THEN

   return p_fin_charge_date;

END get_next_activity_date;

/*=======================================================================+
  This fuction retrieves the receivables_trx_id that should be used for
  creating adjustments for the Interest portion of the late charges. The
  heirarchy used is Ship To, Bill To and System Options.
 +=======================================================================*/
FUNCTION get_int_rec_trx_id(p_customer_trx_id	IN	NUMBER,
	    		    p_fin_charge_date	IN	DATE,
                            p_org_id		IN	NUMBER) RETURN NUMBER IS
  p_int_receivables_trx_id	number;
BEGIN
select  rt.receivables_trx_id
  into  p_int_receivables_trx_id
  from  ar_receivables_trx rt
 where  rt.receivables_trx_id =
                    ( select decode(rsu_st.finchrg_receivables_trx_id,
                             '',decode(rsu_bt.finchrg_receivables_trx_id,
                                     '',sp.finchrg_receivables_trx_id,
                                        rsu_bt.finchrg_receivables_trx_id),
                              rsu_st.finchrg_receivables_trx_id
                                    )
                        from  ra_customer_trx ctrx,
                              hz_cust_site_uses rsu_st,
                              hz_cust_site_uses rsu_bt,
                              ar_system_parameters sp
                        where ctrx.customer_trx_id = p_customer_trx_id
			 and  ctrx.org_id = p_org_id
			 and  sp.org_id = p_org_id
                         and  ctrx.bill_to_site_use_id = rsu_bt.site_use_id(+)
                         and  ctrx.ship_to_site_use_id = rsu_st.site_use_id(+))
 and  rt.type = 'FINCHRG'
 and  nvl(rt.status,'A') = 'A'
 and  rt.org_id = p_org_id
 and  p_fin_charge_date >= nvl(rt.start_date_active,
                                   p_fin_charge_date)
 and  p_fin_charge_date <= nvl(rt.end_date_active,
                                     p_fin_charge_date);
   return p_int_receivables_trx_id;
EXCEPTION
   WHEN OTHERS THEN
      return -1;
END get_int_rec_trx_id;

/*=======================================================================+
  This fuction retrieves the receivables_trx_id that should be used for
  creating adjustments for the Penalty portion of the late charges. This
  is fetched from System Options
 +=======================================================================*/
FUNCTION get_penalty_rec_trx_id(p_fin_charge_date   IN      DATE,
                                p_org_id            IN      NUMBER) RETURN NUMBER IS
  l_penalty_receivables_trx_id      number;
BEGIN

   select  rt.receivables_trx_id
   into  l_penalty_receivables_trx_id
   from  ar_receivables_trx rt
  where  rt.receivables_trx_id  = (select sp.penalty_rec_trx_id
                                    from  ar_system_parameters sp
                                    where sp.org_id = p_org_id)
    and  rt.type = 'FINCHRG'
    and  nvl(rt.status,'A') = 'A'
    and  rt.org_id = p_org_id
    and  p_fin_charge_date >= nvl(rt.start_date_active,
                                  p_fin_charge_date)
    and  p_fin_charge_date <= nvl(rt.end_date_active,
                                  p_fin_charge_date);

   return l_penalty_receivables_trx_id;
EXCEPTION
   WHEN OTHERS THEN
      return -1;
END get_penalty_rec_trx_id;

/*=======================================================================+
  Function which calculates the balance due of a transaction. If the formula
  is COMPOUND, it will consider the finance charge type adjustments that
  were already created against this transaction
 =======================================================================*/
Function get_balance_as_of(p_payment_schedule_id        IN      NUMBER,
                           p_as_of_date                 IN      DATE,
                           p_class			IN	VARCHAR2,
                           p_formula                    IN      VARCHAR2) RETURN NUMBER IS
l_balance_due  		NUMBER;
l_fin_chrg_adjustment 	NUMBER;
BEGIN
  IF p_payment_schedule_id IS NOT NULL THEN
    IF p_class <> 'PMT' THEN
      select sum(amount_due_original), sum(fin_charge_charged)
      into   l_balance_due,l_fin_chrg_adjustment
      from
	(select amount_due_original,0 fin_charge_charged
         from   ar_payment_schedules
         where  payment_schedule_id = p_payment_schedule_id
         union all
         select  nvl(-1 *(ra.amount_applied
                      + nvl(ra.earned_discount_taken,0)
                      + nvl(ra.unearned_discount_taken,0))
                                    ,0) amount_applied,
               0 fin_charge_charged
         from  ar_receivable_applications ra,
               ar_payment_schedules ps_cm_cr
         where applied_payment_schedule_id = p_payment_schedule_id
          and  ra.status = 'APP'
          and  nvl(ra.confirmed_flag,'Y') = 'Y'
          and  ps_cm_cr.payment_schedule_id = ra.payment_schedule_id
          and  ps_cm_cr.trx_date <= p_as_of_date
         union all
         select  nvl(ra.amount_applied_from, ra.amount_applied),
               0 fin_charge_charged
         from  ar_receivable_applications ra
         where payment_schedule_id = p_payment_schedule_id
          and  ra.apply_date <= p_as_of_date
          and  ra.status = 'APP'
          and  nvl(ra.confirmed_flag,'Y') = 'Y'
          and  p_class = 'CM'
          and  ra.application_type = 'CM'
         union all
         select adj.amount,
                CASE WHEN adj.type ='CHARGES'
                     THEN CASE WHEN  adj.adjustment_type = 'A'
                               THEN  adj.amount
                               ELSE  0 END
                     ELSE 0 END fin_charge_charged
         from  ar_adjustments adj
         where adj.payment_schedule_id = p_payment_schedule_id
         and   adj.apply_date <= p_as_of_date
         and   adj.status = 'A');
      IF p_formula <> 'Y' THEN
         IF (abs(l_balance_due) < abs(l_fin_chrg_adjustment) AND
            sign(l_balance_due) = sign(l_fin_chrg_adjustment)
            OR l_balance_due = 0 ) THEN
               l_balance_due := 0;
         ELSE
               l_balance_due := l_balance_due - l_fin_chrg_adjustment;
         END IF;
      END IF;

    ELSIF p_class ='PMT' THEN
      /* Compound and Simple Interest doesn't matter for Payments as there can not be any
         adjustments against receipts */
      /* For receipts the balance should be directly taken from ar_payment_schedules.
         amount_due_remaining. The receipt date is considered for calculating the balances
         of the transaction and not the application date */
      select  ps.amount_due_remaining
      into l_balance_due
      from ar_payment_schedules ps
      where ps.payment_schedule_id = p_payment_schedule_id
      and   ps.class ='PMT'
      and   nvl(ps.receipt_confirmed_flag,'Y') = 'Y';
    END IF;

    return nvl(l_balance_due,0);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
      return 0;
END get_balance_as_of;

/*=======================================================================+
  Function which returns the balance of the customer by adding or subtracting
  the debit or credit items from the balance forward bill
 =======================================================================*/
Function get_cust_balance(p_customer_id                 IN      NUMBER,
                          p_site_use_id                 IN      NUMBER,
                          p_currency_code               IN      VARCHAR2,
                          p_org_id                      IN      NUMBER,
                          p_post_billing_debit          IN      VARCHAR2,
                          p_as_of_date                  IN      DATE) return NUMBER IS
  l_cust_balance   number;

BEGIN
          select sum(bal_amount)
          into l_cust_balance
         from (
           select  sum(ending_balance) bal_amount
            from   ar_cons_inv cons_inv
            where  cons_inv.customer_id = p_customer_id
            and    cons_inv.site_use_id   = p_site_use_id
            and    cons_inv.currency_code = p_currency_code
	    and    cons_inv.org_id = p_org_id
            and    cons_inv.status       in('FINAL', 'ACCEPTED','IMPORTED')
            and    cons_inv.billing_date  =  (select max(ci2.billing_date)
		                                from   ar_cons_inv ci2
                		                where  ci2.customer_id = p_customer_id
                                		and    ci2.site_use_id   = p_site_use_id
		                                and    ci2.currency_code = p_currency_code
						and    ci2.org_id = p_org_id
                                		and    ci2.billing_date  <= p_as_of_date
		                                and    ci2.status  in ('FINAL', 'ACCEPTED','IMPORTED'))
           union all
           select sum(amount_due_original)
           from   ar_payment_schedules ps
           where  ps.customer_id = p_customer_id
           and    decode(ps.class,
                         'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                          ps.customer_site_use_id,
                                                                          ps.org_id),
                         'PMT',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                           ps.customer_site_use_id,
                                                                           ps.org_id),
                          ps.customer_site_use_id) = p_site_use_id
           and    ps.invoice_currency_code = p_currency_code
           and    ps.org_id  = p_org_id
           and    decode(p_post_billing_debit,
                         'INCLUDE_DEBIT_ITEM','Y',
                         'EXCLUDE_DEBIT_ITEM',decode(ps.class,
                                                     'PMT','Y',
                                                     'CM','Y',
                                                     'N'),
                         'N') = 'Y'
           and    (ps.trx_date >  (select max(ci2.billing_date)
                                from   ar_cons_inv ci2
                                where  ci2.customer_id = p_customer_id
                                and    ci2.site_use_id   = p_site_use_id
                                and    ci2.currency_code = p_currency_code
				and    ci2.org_id = p_org_id
                                AND    ci2.billing_date  <= p_as_of_date
                                AND    ci2.status in ('FINAL','ACCEPTED','IMPORTED'))
                  OR
                   /* No BFB exists for this customer.. for run date to run date option we
                      have to calculate the ADB even for the period before the first BFB is
                      created. i.e. There should not be any gaps in the ADB calculation */
                  (not exists (select cons_inv_id
                               from  ar_cons_inv ci2
                                where  ci2.customer_id = p_customer_id
                                and    ci2.site_use_id   = p_site_use_id
                                and    ci2.currency_code = p_currency_code
                                and    ci2.org_id = p_org_id
                                AND    ci2.billing_date  <= p_as_of_date
                                AND    ci2.status in ('FINAL','ACCEPTED','IMPORTED'))))
          and     ps.trx_date <= p_as_of_date);

          return l_cust_balance;

EXCEPTION WHEN OTHERS THEN
   return 0;
END get_cust_balance;

/*=======================================================================+
  Function which checks whethers a particular customer, site and currency
  combination is eligible for charge calculation. It returns 'Y' or 'N'. This
  is used for applying the customer level tolerances in Average Daily Balance
  scenario.
  Psedo Logic
  ===========
  For checking the eligibility, the balance of the last balance forward bill
  is taken. The debit items till the due_date of the bill are added to that
  and the credit items till the bill due_date + receipt grace days are
  subtracted from that. This is compared to the threshold of min_customer
  balance overdue
 =======================================================================*/

FUNCTION check_adb_eligibility(	p_customer_id			IN	NUMBER,
				p_site_use_id			IN	NUMBER,
			    	p_currency_code			IN	VARCHAR2,
			    	p_org_id			IN	VARCHAR2,
		    		p_receipt_grace_days		IN	NUMBER,
                            	p_min_fc_bal_overdue_type   	IN	VARCHAR2,
			    	p_min_fc_bal_amount		IN	NUMBER,
			    	p_min_fc_bal_percent		IN	NUMBER,
                            	p_fin_charge_date		IN	DATE) RETURN VARCHAR2 IS
l_cust_eligible_bal     NUMBER;
l_cust_threshold        NUMBER;

BEGIN
        IF l_debug_flag = 'Y' THEN
           debug('ar_calc_late_charge.check_adb_eligibility()+');
           debug('Customer_id 		:	'||p_customer_id);
           debug('Site Use ID		:	'||p_site_use_id);
           debug('Currency_code		:	'||p_currency_code);
           debug('Org ID			:	'||p_org_id);
	   debug('Receipt Grace Days	:	'||p_receipt_grace_days);
           debug('min_fc_bal_overdue_type:	'||p_min_fc_bal_overdue_type);
           debug('min_fc_bal_amount	:	'||p_min_fc_bal_amount);
           debug('min_fc_bal_percent	:	'||p_min_fc_bal_percent);
           debug('Finance Charge Date	:	'||p_fin_charge_date);
        END IF;

        IF p_min_fc_bal_overdue_type = 'AMOUNT' THEN
           l_cust_threshold := p_min_fc_bal_amount;
        END IF;

	select 	sum(a.balance)
         into   l_cust_eligible_bal
         from (
	         select sum(ci.ending_balance) balance
        	 from   ar_cons_inv ci
	         where  ci.customer_id = p_customer_id
        	 and    ci.site_use_id = p_site_use_id
	         and    ci.currency_code = p_currency_code
        	 and    ci.org_id = p_org_id
	         and    ci.billing_date = (select max(ci2.billing_date)
        	                          from   ar_cons_inv ci2
                	                  where  ci2.customer_id =  p_customer_id
                        	          and    ci2.site_use_id   =  p_site_use_id
                                	  and    ci2.currency_code = p_currency_code
	                                  and    ci2.org_id = p_org_id
        	                          and    ci2.billing_date  <= p_fin_charge_date
                	                  and    ci2.status  in ('FINAL', 'ACCEPTED','IMPORTED'))
	         and    ci.status  in ('FINAL', 'ACCEPTED','IMPORTED')
        	 union all
                 select sum(ps.amount_due_original)
	         from   ar_cons_inv ci,
	                ar_payment_schedules ps
	         where  ci.customer_id = p_customer_id
 		 and    ci.site_use_id = p_site_use_id
	 	 and    ci.currency_code = p_currency_code
        	 and    ci.org_id = p_org_id
	         and    ci.billing_date = (select max(ci2.billing_date)
        	                           from   ar_cons_inv ci2
	                                   where  ci2.customer_id =  p_customer_id
        	                           and    ci2.site_use_id   =  p_site_use_id
                	                   and    ci2.currency_code = p_currency_code
                         	           and    ci2.org_id = p_org_id
                                	   and    ci2.billing_date  <= p_fin_charge_date
	                                   and    ci2.status  in ('FINAL', 'ACCEPTED','IMPORTED'))
        	 and    ci.status  in ('FINAL', 'ACCEPTED','IMPORTED')
	         and    ps.customer_id = ci.customer_id
        	 and    decode(ps.class,
	        	      'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
             		  	                                               ps.customer_site_use_id,
                          			                               ps.org_id),
 			      'PMT',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
        	        		                                        ps.customer_site_use_id,
                	                		                        ps.org_id),
			       ps.customer_site_use_id) =  ci.site_use_id
        	 and    ps.invoice_currency_code = ci.currency_code
	         and    ps.org_id = ci.org_id
        	 and    ps.trx_date > ci.billing_date
                /* As of now, don't consider the debit items for checking the eligibility,
                   as documented in FDD. This will cause incorrect results for Run Date to
                   Run Date option as this function will return N when there are no bills for
                   the customer. Waiting for the PM feedback on this.*/
                 and    ps.class in ('PMT','CM')
	         and    decode(ps.class,
        	              'PMT',ci.due_date + nvl(p_receipt_grace_days,0),
                	      'CM', ci.due_date + nvl(p_receipt_grace_days,0),
	                      ci.due_date) >= ps.trx_date)a;

        IF l_debug_flag = 'Y' THEN
	     debug('l_cust_eligible_bal	:	'||l_cust_eligible_bal);
        END IF;

        IF nvl(l_cust_eligible_bal,0) >= nvl(l_cust_threshold,0) THEN
	    IF l_debug_flag = 'Y' THEN
               debug('Returning Y');
            END IF;
            return 'Y';
        ELSE
	    IF l_debug_flag = 'Y' THEN
               debug('Returning N');
            END IF;
            return 'N';
        END IF;
	IF l_debug_flag = 'Y' THEN
           debug('ar_calc_late_charge.check_adb_eligibility()-');
        END IF;
EXCEPTION WHEN OTHERS THEN
     --IF l_debug_flag = 'Y' THEN
        debug('EXCEPTION : ar_calc_late_charge.check_adb_eligibility()');
     --END IF;
     return 'N';

END check_adb_eligibility;

/*=======================================================================+
  Function which returns the first date on which the activity started for
  a customer. This is for calculating the average daily balance even before
  creating a Balance Forward Bill
 =======================================================================*/

FUNCTION get_first_activity_date(p_customer_id                IN      NUMBER,
                                 p_site_use_id                IN      NUMBER,
                                 p_currency_code              IN      VARCHAR2,
                                 p_org_id                     IN      NUMBER) return DATE IS
  l_first_activity_date	DATE;
BEGIN
   select min(trx_date)
   into   l_first_activity_date
   from   ar_payment_schedules ps
   where  ps.customer_id = p_customer_id
   and    decode(ps.class,
		'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                     		                                   ps.customer_site_use_id,
	                                   			   ps.org_id),
                'PMT',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                  	                                           ps.customer_site_use_id,
                                        		           ps.org_id),
    		ps.customer_site_use_id) = p_site_use_id
   and    ps.invoice_currency_code = p_currency_code
   and	  ps.org_id = p_org_id;

   return l_first_activity_date;

EXCEPTION WHEN OTHERS THEN
   return NULL;
END get_first_activity_date;


PROCEDURE get_cust_late_charge_policy(p_org_id		          IN      NUMBER,
                                      p_fin_charge_date           IN      DATE,
                                      p_customer_name_from        IN      VARCHAR2,
                                      p_customer_name_to          IN      VARCHAR2,
                                      p_customer_number_from      IN      VARCHAR2,
                                      p_customer_number_to        IN      VARCHAR2,
                                      p_currency_code             IN      VARCHAR2,
                                      p_cust_site_use_id          IN      NUMBER,
				      p_worker_number		  IN	  NUMBER,
				      p_total_workers		  IN	  NUMBER) IS
   /*Late charge changes for amount per tier Enhacement 6469663*/
   CURSOR wrong_setup(fin_charge_date in date ) is
   select substrb(party.party_name,1,50) name,lc_site.lc_cust_sites_id,lc_site.customer_id,lc_site.currency_code,lc_site.customer_site_use_id,
          'INTEREST' type
   FROM ar_lc_cust_sites_t lc_site,hz_cust_accounts cust_acct,hz_parties party,ar_charge_schedules c_schdl,ar_charge_schedule_headers_v h_schdl
   WHERE lc_site.interest_type = 'CHARGE_PER_TIER'
   AND   lc_site.interest_schedule_id = c_schdl.schedule_id
   AND   c_schdl.schedule_id   = h_schdl.schedule_id
   AND   fin_charge_date between h_schdl.start_date and nvl(h_schdl.end_date,to_date('31-12-4712','DD-MM-YYYY'))
   AND   h_schdl.SCHEDULE_HEADER_TYPE <> 'AMOUNT'
   AND   lc_site.customer_id   = cust_acct.cust_account_id
   AND   cust_acct.party_id = party.party_id
   UNION
   select substrb(party.party_name,1,50) name,lc_site.lc_cust_sites_id,lc_site.customer_id,lc_site.currency_code,lc_site.customer_site_use_id,
          'PENALTY' type
   FROM ar_lc_cust_sites_t lc_site,hz_cust_accounts cust_acct,hz_parties party,ar_charge_schedules c_schdl,ar_charge_schedule_headers_v h_schdl
   WHERE lc_site.penalty_type = 'CHARGE_PER_TIER'
   AND   lc_site.penalty_schedule_id = c_schdl.schedule_id
   AND   c_schdl.schedule_id   = h_schdl.schedule_id
   AND   fin_charge_date between h_schdl.start_date and nvl(h_schdl.end_date,to_date('31-12-4712','DD-MM-YYYY'))
   AND   h_schdl.SCHEDULE_HEADER_TYPE <> 'AMOUNT'
   AND   lc_site.customer_id   = cust_acct.cust_account_id
   AND   cust_acct.party_id = party.party_id
   ORDER BY name,currency_code,customer_site_use_id,type;



   l_org_id			         NUMBER;
   l_customer_name_from                  hz_parties.party_name%type;
   l_customer_name_to                    hz_parties.party_name%type;
   l_customer_number_from                hz_cust_accounts.account_number%type;
   l_customer_number_to                  hz_cust_accounts.account_number%type;
   l_cust_site_use_id                    number;
   l_fin_charge_date                     date;
   l_currency_code			 VARCHAR2(15);
   l_use_late_charge_site		 VARCHAR2(1);
   l_worker_number			 number;
   l_total_workers			 number;
   l_ins_statement			 VARCHAR2(32000);
   l_customer_name_where                 VARCHAR2(200);
   l_customer_number_where               VARCHAR2(200);
   l_currency_where                      VARCHAR2(100);
   l_cust_site_where                     VARCHAR2(100);
   l_org_where                           VARCHAR2(50);
   v_cursor                   		 NUMBER;
   l_ignore    		                 INTEGER;
   l_first_rec				 BOOLEAN;
BEGIN
   IF l_debug_flag = 'Y' THEN
      debug( 'ar_calc_late_charge.get_cust_late_charge_policy()+' );
   END IF;

   l_org_id			:=	p_org_id;
   l_customer_name_from		:=	p_customer_name_from;
   l_customer_name_to		:=	p_customer_name_to;
   l_customer_number_from	:=	p_customer_number_from;
   l_customer_number_to		:=	p_customer_number_to;
   l_cust_site_use_id		:=	p_cust_site_use_id;
   l_fin_charge_date		:=	p_fin_charge_date;
   l_currency_code		:=	p_currency_code;
   l_worker_number		:=	p_worker_number;
   l_total_workers		:=	p_total_workers;

   IF l_debug_flag = 'Y' THEN
     debug('l_customer_name_from	:	'||l_customer_name_from);
     debug('l_customer_name_to		:	'||l_customer_name_to);
     debug('l_customer_number_from	:	'||l_customer_number_from);
     debug('l_customer_number_to	:	'||l_customer_number_to);
     debug('l_org_id			:	'||l_org_id);
   END IF;

   /*  If the profile AR: Use Late Charges Profile is set to Yes, we will use the profiles
       and policies defined for the Late charges site. if no profile is defined at this site,
       we will use the customer level profile. If the AR: Use Late Charges Profile is set to
       No, we will use the individual profiles defined for the corresponding bill to sites.
       If no profiles exist, we will use the customer level profile. */

      l_use_late_charge_site :=  nvl(FND_PROFILE.value('AR_USE_STATEMENTS_AND_DUNNING_SITE_PROFILE'),'N');

      /* Bug fix 5384500 */
     IF l_customer_name_from IS NOT NULL AND l_customer_name_to IS NULL THEN
        l_customer_name_where := 'AND party.party_name >= :l_customer_name_from ';
     ELSIF l_customer_name_from IS NULL and l_customer_name_to IS NOT NULL THEN
        l_customer_name_where := 'AND party.party_name <= :l_customer_name_to ';
     ELSIF l_customer_name_from IS NOT NULL and l_customer_name_to IS NOT NULL THEN
        l_customer_name_where := 'AND party.party_name  >= :l_customer_name_from AND party.party_name  <= :l_customer_name_to ';
     ELSE
        l_customer_name_where := NULL;
     END IF;

     IF l_customer_number_from IS NOT NULL AND l_customer_number_to IS NULL THEN
        l_customer_number_where := 'AND cust_acct.account_number >= :l_customer_number_from ';
     ELSIF l_customer_number_from IS NULL AND l_customer_number_to IS NOT NULL THEN
        l_customer_number_where := 'AND cust_acct.account_number <= :l_customer_number_to ';
     ELSIF l_customer_number_from IS NOT NULL AND l_customer_number_to IS NOT NULL THEN
        l_customer_number_where := 'AND cust_acct.account_number  >= :l_customer_number_from AND cust_acct.account_number  <= :l_customer_number_to ';
     ELSE
        l_customer_number_where := NULL;
     END IF;

     IF l_currency_code IS NOT NULL THEN
        l_currency_where := ' AND  ps.invoice_currency_code = :l_currency_code ';
     ELSE
        l_currency_where := NULL;
     END IF;

     IF l_cust_site_use_id IS NOT NULL THEN
        l_cust_site_where := ' AND ps.customer_site_use_id = :l_cust_site_use_id ';
     ELSE
        l_cust_site_where := NULL;
     END IF;

     IF l_org_id IS NOT NULL THEN
        l_org_where := ' AND sysparam.org_id = :l_org_id ';
     ELSE
        l_org_where := NULL;
     END IF;

    l_ins_statement :=
      'insert into ar_lc_cust_sites_t
               (lc_cust_sites_id,
                customer_id,
                customer_site_use_id,
                currency_code,
                customer_profile_id,
                collector_id,
                late_charge_calculation_trx,
                credit_items_flag,
                disputed_transactions_flag,
                payment_grace_days,
                late_charge_type,
                late_charge_term_id ,
                interest_period_days,
                interest_calculation_period,
                charge_on_finance_charge_flag,
                hold_charged_invoices_flag,
                message_text_id,
                multiple_interest_rates_flag,
                charge_begin_date,
                cons_inv_flag,
                cons_bill_level,
                cust_acct_profile_amt_id,
                exchange_rate_type,
                exchange_rate,
                min_fc_invoice_overdue_type,
                min_fc_invoice_amount,
                min_fc_invoice_percent,
                min_fc_balance_overdue_type,
                min_fc_balance_amount,
                min_fc_balance_percent,
                min_interest_charge,
                max_interest_charge,
                interest_type,
                interest_Rate,
                interest_fixed_amount,
                interest_schedule_id,
                penalty_type,
                penalty_rate,
                penalty_fixed_amount,
                penalty_schedule_id,
                last_accrue_charge_date,
                org_id,
                request_id)
         (select ar_lc_cust_sites_s.nextval,
                customer_id,
                customer_site_use_id,
                currency_code,
                cust_account_profile_id,
                collector_id,
                late_charge_calculation_trx,
                credit_items_flag,
                disputed_transaction_flag,
                payment_grace_days,
                late_charge_type,
                late_charge_term_id,
                interest_period_days,
                interest_calculation_period,
                charge_on_finance_charge_flag,
                hold_charged_invoices_flag,
                message_text_id,
                multiple_interest_rates_flag,
                charge_begin_date,
                cons_inv_flag,
                cons_bill_level,
                cust_acct_profile_amt_id,
                exchange_rate_type,
                exchange_rate,
                min_fc_invoice_overdue_type,
                min_fc_invoice_amount,
                min_fc_invoice_percent,
                min_fc_balance_overdue_type,
                min_fc_balance_amount,
                min_fc_balance_percent,
                min_interest_charge,
                max_interest_charge,
                interest_type ,
                interest_rate,
                interest_fixed_amount,
                interest_schedule_id,
                penalty_type,
                penalty_rate,
                penalty_fixed_amount,
                penalty_schedule_id,
                last_accrue_charge_date,
                org_id,
                :l_request_id
         from
         (select distinct
                ps.customer_id,
                decode(ps.class,
                       ''PMT'',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                         ps.customer_site_use_id,
                                                                         ps.org_id),
                       ''BR'',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                        ps.customer_site_use_id,
                                                                        ps.org_id),
                        ps.customer_site_use_id) customer_site_use_id,
                ps.invoice_currency_code        currency_code,
                profiles.cust_account_profile_id,
                profiles.collector_id,
                profiles.late_charge_calculation_trx,
                profiles.credit_items_flag,
                profiles.disputed_transactions_flag disputed_transaction_flag,
                profiles.payment_grace_days,
                profiles.late_charge_type,
                profiles.late_charge_term_id,
                profiles.interest_period_days,
                profiles.interest_calculation_period,
                profiles.charge_on_finance_charge_flag,
                profiles.hold_charged_invoices_flag,
                profiles.message_text_id,
                profiles.multiple_interest_rates_flag,
                profiles.charge_begin_date,
                profiles.cons_inv_flag,
                profiles.cons_bill_level,
                prof_amts.cust_acct_profile_amt_id,
                decode(ps.exchange_rate_type,
                       NULL, NULL,
                       prof_amts.exchange_rate_type) exchange_rate_type,
                NULL exchange_rate,
                prof_amts.min_fc_invoice_overdue_type,
                prof_amts.min_fc_invoice_amount,
                prof_amts.min_fc_invoice_percent,
                prof_amts.min_fc_balance_overdue_type,
                prof_amts.min_fc_balance_amount,
                prof_amts.min_fc_balance_percent,
                prof_amts.min_interest_charge,
                prof_amts.max_interest_charge,
                prof_amts.interest_type ,
                prof_amts.interest_rate,
                prof_amts.interest_fixed_amount,
                prof_amts.interest_schedule_id,
                prof_amts.penalty_type ,
                prof_amts.penalty_rate,
                prof_amts.penalty_fixed_amount,
                prof_amts.penalty_schedule_id,
                site_use.last_accrue_charge_date,
                ps.org_id
          from  ar_payment_schedules ps,
                ar_transaction_history th,
                ra_customer_trx trx,
                hz_cust_accounts cust_acct,
                hz_parties party,
                hz_customer_profiles profiles,
                hz_cust_profile_amts prof_amts,
                hz_cust_site_uses site_use,
                ar_system_parameters sysparam
          WHERE cust_acct.party_id = party.party_id
         '|| l_customer_name_where ||'
         '|| l_customer_number_where || '
          AND   cust_acct.status = ''A''
          AND   ps.customer_id = cust_acct.cust_account_id
          AND   ps.customer_trx_id = th.customer_trx_id(+)
         '|| l_currency_where ||'
         '|| l_cust_site_where ||'
          AND   nvl(th.current_record_flag,''Y'') = ''Y''
          AND   nvl(th.status,''*'') not in (''PROTESTED'',''MATURED_PEND_RISK_ELIMINATION'',''CLOSED'', ''CANCELLED'')
	  AND   ps.org_id = sysparam.org_id
         '||l_org_where ||'
	  AND   nvl(sysparam.allow_late_charges,''N'') = ''Y''
          AND   ps.customer_trx_id      = trx.customer_trx_id(+)
          AND   nvl(ps.last_charge_date,ps.due_date) < :l_fin_charge_date
          AND   nvl(trx.finance_charges,decode(ps.class,''DEP'',''N'',''Y'')) = ''Y''
          AND   profiles.cust_account_id = cust_acct.cust_account_id
          AND   ((ar_calc_late_charge.get_profile_class_site_use_id
                                                  (decode(:l_use_late_charge_site ,
                                                          ''Y'',ar_calc_late_charge.get_late_charge_site(ps.customer_id,
                                                                                                       ps.org_id),
                                                          ''N'',ps.customer_site_use_id)
                                                      ,ps.org_id) IS NULL
                  and profiles.site_use_id is null)
                 OR profiles.site_use_id = ar_calc_late_charge.get_profile_class_site_use_id
                                                  (decode(:l_use_late_charge_site,
                                                          ''Y'',ar_calc_late_charge.get_late_charge_site(ps.customer_id,
                                                                                                       ps.org_id),
                                                          ''N'',ps.customer_site_use_id)
                                                       ,ps.org_id))
          AND   profiles.interest_charges = ''Y''
          AND   profiles.cust_account_profile_id =  prof_amts.cust_account_profile_id
          AND   prof_amts.currency_code = ps.invoice_currency_code
          AND   site_use.site_use_id (+) =  decode(ps.class,
                                                   ''PMT'',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                                                ps.customer_site_use_id,
	                                   							ps.org_id),
                                                   ''BR'',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                                                ps.customer_site_use_id,
                                                                                                ps.org_id),
                                                    ps.customer_site_use_id)
            AND   mod(nvl(ps.customer_site_use_id,0),:l_total_workers) =
                                          decode(:l_total_workers,:l_worker_number,0,:l_worker_number))a
            /* Make sure that this customer, site and currency combination is not
               part of a failed final batch */
            WHERE  not exists (select ''exists failed batch''
                      from   ar_interest_headers hdr,
                             ar_interest_batches bat
                      where  hdr.customer_id = a.customer_id
                      and    hdr.customer_site_use_id = a.customer_site_use_id
                      and    hdr.currency_code = a.currency_code
                      and    hdr.org_id = a.org_id
                      and    hdr.interest_batch_id = bat.interest_batch_id
                      and    hdr.process_status <> ''S''
                      and    bat.batch_status =''F''
                      and    bat.transferred_status <> ''S''))';

    IF l_debug_flag = 'Y' THEN
       debug(l_ins_statement);
    END IF;

     v_cursor := dbms_sql.open_cursor;

    dbms_sql.parse(v_cursor,l_ins_statement,DBMS_SQL.NATIVE);

    IF l_customer_name_from IS NOT NULL THEN                                                                                                       dbms_sql.bind_variable(v_cursor, ':l_customer_name_from', l_customer_name_from);
    END IF;

    IF l_customer_name_to IS NOT NULL THEN
       dbms_sql.bind_variable(v_cursor, ':l_customer_name_to', l_customer_name_to);
    END IF;

    IF l_customer_number_from IS NOT NULL THEN
       dbms_sql.bind_variable(v_cursor, ':l_customer_number_from', l_customer_number_from);
    END IF;

    IF l_customer_number_to IS NOT NULL THEN
       dbms_sql.bind_variable(v_cursor, ':l_customer_number_to', l_customer_number_to);
    END IF;

    dbms_sql.bind_variable(v_cursor, ':l_request_id', l_request_id);

    IF l_currency_code IS NOT NULL THEN
       dbms_sql.bind_variable(v_cursor, ':l_currency_code', l_currency_code);
    END IF;

    IF l_cust_site_use_id IS NOT NULL THEN
       dbms_sql.bind_variable(v_cursor, ':l_cust_site_use_id', l_cust_site_use_id);
    END IF;

    dbms_sql.bind_variable(v_cursor, ':l_fin_charge_date',l_fin_charge_date);

    IF l_org_id IS NOT NULL THEN
        dbms_sql.bind_variable(v_cursor, ':l_org_id', l_org_id);
    END IF;

    dbms_sql.bind_variable(v_cursor, ':l_use_late_charge_site',l_use_late_charge_site);
    dbms_sql.bind_variable(v_cursor, ':l_worker_number',l_worker_number);
    dbms_sql.bind_variable(v_cursor, ':l_total_workers', l_total_workers);

    l_ignore := dbms_sql.execute(v_cursor);

 /*Late Charge Changes for charge per tier Enhacement 6469663*/
   l_first_rec := TRUE;
   FOR setup in wrong_setup(p_fin_charge_date)
   LOOP
       IF l_first_rec THEN
         debug('Active interest tier has schedule type of percentage for Charge per Tier calculation method. Please define interest tier with amount schedule type.');
         debug('---------------------------------------------------------------------------------------------------------------------------------------------------');
         debug(rpad('CUSTOMER',50) ||' ' ||  rpad('CURRENCY',8) || ' ' || rpad('SITE_USE_ID',12) || ' ' ||  rpad('TYPE' , 8));
         debug(lpad(' ',51,'-') || lpad(' ', 9,'-' ) || lpad(' ',13,'-') || lpad(' ',9,'-'));
         l_first_rec := FALSE;
       END IF;
       debug(rpad(setup.name,50) || ' ' || rpad(setup.currency_code ,8) || ' ' || rpad(setup.customer_site_use_id,12) || ' ' || setup.type);
   END LOOP;

   /*Late Charge Changes for charge per tier Enhacement 6469663*/
   UPDATE ar_lc_cust_sites_t set penalty_type = NULL
   WHERE lc_cust_sites_id IN
   ( select lc_cust_sites_id
     FROM ar_lc_cust_sites_t lc_site,hz_cust_accounts cust_acct,hz_parties party,ar_charge_schedules c_schdl,ar_charge_schedule_headers_v h_schdl
     WHERE lc_site.penalty_type = 'CHARGE_PER_TIER'
     AND   lc_site.penalty_schedule_id = c_schdl.schedule_id
     AND   c_schdl.schedule_id   = h_schdl.schedule_id
     AND   p_fin_charge_date between h_schdl.start_date and nvl(h_schdl.end_date,to_date('31-12-4712','DD-MM-YYYY'))
     AND   h_schdl.SCHEDULE_HEADER_TYPE <> 'AMOUNT'
     AND   lc_site.customer_id   = cust_acct.cust_account_id
     AND   cust_acct.party_id = party.party_id
   );

   delete from ar_lc_cust_sites_t
   where lc_cust_sites_id IN
   (
     select lc_cust_sites_id
     FROM ar_lc_cust_sites_t lc_site,hz_cust_accounts cust_acct,hz_parties party,ar_charge_schedules c_schdl,ar_charge_schedule_headers_v h_schdl
     WHERE lc_site.interest_type = 'CHARGE_PER_TIER'
     AND   lc_site.interest_schedule_id = c_schdl.schedule_id
     AND   c_schdl.schedule_id   = h_schdl.schedule_id
     AND   p_fin_charge_date between h_schdl.start_date and nvl(h_schdl.end_date,to_date('31-12-4712','DD-MM-YYYY'))
     AND   h_schdl.SCHEDULE_HEADER_TYPE <> 'AMOUNT'
     AND   lc_site.customer_id   = cust_acct.cust_account_id
     AND   cust_acct.party_id = party.party_id
   );

   IF l_debug_flag = 'Y' THEN
      debug( 'ar_calc_late_charge.get_cust_late_charge_policy()-' );
   END IF;

   EXCEPTION
     WHEN  OTHERS THEN
        --IF l_debug_flag = 'Y' THEN
            debug('EXCEPTION : '||SQLCODE||' : '||SQLERRM);
            debug('EXCEPTION: ar_calc_late_charge.get_cust_late_charge_policy' );
        --END IF;
        RAISE;
END get_cust_late_charge_policy;

PROCEDURE insert_credit_amount(p_fin_charge_date	IN	DATE,
			       p_worker_number          IN      NUMBER,
                               p_total_workers          IN      NUMBER) IS
 l_fin_charge_date	DATE;
 l_worker_number        number;
 l_total_workers        number;
BEGIN
        IF l_debug_flag = 'Y' THEN
              debug( 'ar_calc_late_charge.insert_credit_amount()+' );
        END IF;

        l_fin_charge_date	:=	p_fin_charge_date;
	l_worker_number         :=      p_worker_number;
        l_total_workers         :=      p_total_workers;

        /* The sum of credit amount is inserted into ar_late_charge_credits_gt.
           a) All Unapplied or On Account Receipts and the Open On Account Credit Memos
              constitute the credit amount
           b) Credits are inserted as positive amounts, for easiness of handling the applications
           c) Credits are calculated for a customer_id, site_use_id, currency_code and legal_entity_id
              combination
        */

        insert into ar_late_charge_credits_gt
                (customer_id,
                 customer_site_use_id,
                 currency_code,
                 legal_entity_id,
                 org_id,
                 credit_amount)
          (
         select customer_id,
                customer_site_use_id,
                currency_code,
                legal_entity_id,
                org_id,
                sum(balance_due)
                /* The receipt balance is taken as -1*amount_due_remaining from ar_payment
                   schedules as receipt date is considered for calculating the balances of
                   the transaction and not the application date */
          from (select cr.pay_from_customer customer_id,
                       ar_calc_late_charge.get_bill_to_site_use_id(cr.pay_from_customer,
                                                                   cr.customer_site_use_id,
								   cr.org_id) customer_site_use_id,
                       cr.currency_code,
                       cr.legal_entity_id,
		       cr.org_id,
                       -1* ps.amount_due_remaining balance_due
                from  ar_cash_receipts cr,
                      ar_payment_schedules ps,
                      ar_lc_cust_sites_t cust_site,
                      ar_late_charge_cust_balance_gt bal
               where  ps.actual_date_closed > l_fin_charge_date
                and   ps.class ='PMT'
                and   ps.trx_date <= l_fin_charge_date
                and   nvl(ps.last_charge_date,l_fin_charge_date-1) < l_fin_charge_date
                and   ps.customer_id = cust_site.customer_id
                and   ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                  ps.customer_site_use_id,
                                                                  ps.org_id) = cust_site.customer_site_use_id
                and   ps.invoice_currency_code = cust_site.currency_code
                and   ps.org_id = cust_site.org_id
                and   cr.pay_from_customer = cust_site.customer_id
                and   cr.currency_code = cust_site.currency_code
                and   cr.org_id = cust_site.org_id
                and   NVL(cust_site.credit_items_flag,'N') = 'Y'
                and   cust_site.late_charge_type in ('ADJ','DM')
                /* Apply Customer Level tolerances */
                and   cust_site.lc_cust_sites_id = bal.late_charge_cust_sites_id
                and   cust_site.org_id = bal.org_id
                and   decode(cust_site.min_fc_balance_overdue_type,
                             'PERCENT',(nvl(cust_site.min_fc_balance_percent,0)
                                        * nvl(bal.customer_open_balance,0)/100),
                             'AMOUNT',nvl(cust_site.min_fc_balance_amount,0),
                             0) <= nvl(bal.customer_overdue_balance,0)
                and   cr.receipt_date < l_fin_charge_date
                and   cr.cash_receipt_id = ps.cash_receipt_id
                and   cr.org_id = ps.org_id
                and   cr.cash_receipt_id = ps.cash_receipt_id
                and   nvl(ps.receipt_confirmed_flag,'Y') ='Y'
                and   decode(cust_site.hold_charged_invoices_flag,
                              'Y', decode(ps.last_charge_date,
                                          NULL,'Y','N'),
                              'N') = 'N'
                UNION ALL
                select ps.customer_id,
                       ps.customer_site_use_id,
                       ps.invoice_currency_code,
                       trx.legal_entity_id,
                       ps.org_id,
                       /* Always get the true balance of the CM as of the finance charge date. For that,
                          p_charge_on_finance_charge_flag is passed as Y */
                       -1*ar_calc_late_charge.get_balance_as_of(ps.payment_schedule_id,
                                                                l_fin_charge_date,
                                                                'CM',
                                                                'Y') balance_due
                from   ar_payment_schedules ps,
                       ra_customer_trx trx,
                       ra_cust_trx_types types,
                       ar_lc_cust_sites_t cust_site,
                       ar_late_charge_cust_balance_gt bal
                where  ps.customer_id = cust_site.customer_id
                and    ps.customer_site_use_id = cust_site.customer_site_use_id
                and    ps.invoice_currency_code = cust_site.currency_code
                and    mod(nvl(cust_site.customer_site_use_id,0),l_total_workers) =
                                          decode(l_total_workers,l_worker_number,0,l_worker_number)
		and    ps.org_id = cust_site.org_id
                and    ps.actual_date_closed > l_fin_charge_date
                and    ps.class = 'CM'
                and    ps.trx_date <= l_fin_charge_date
                and    nvl(ps.last_charge_date,l_fin_charge_date-1) < l_fin_charge_date
                and    cust_site.late_charge_type in ('ADJ','DM')
                /* Apply Customer Level tolerances */
                and   cust_site.lc_cust_sites_id = bal.late_charge_cust_sites_id
		and   cust_site.org_id = bal.org_id
                and   decode(cust_site.min_fc_balance_overdue_type,
                             'PERCENT',(nvl(cust_site.min_fc_balance_percent,0)
                                        * nvl(bal.customer_open_balance,0)/100),
                             'AMOUNT',nvl(cust_site.min_fc_balance_amount,0),
                             0) <= nvl(bal.customer_overdue_balance,0)
                and    decode(cust_site.disputed_transactions_flag,'N',
                         decode(nvl(ps.amount_in_dispute,0), 0, 'Y','N'),'Y' ) = 'Y'
                and    NVL(cust_site.credit_items_flag,'N') = 'Y'
                and    decode(cust_site.hold_charged_invoices_flag,
                              'Y', decode(ps.last_charge_date,
                                          NULL,'Y','N'),
                              'N') = 'N'
                and    trx.customer_trx_id = ps.customer_trx_id
	        and    trx.org_id = ps.org_id
                and    nvl(trx.finance_charges,'Y') = 'Y'
                and    types.cust_trx_type_id = ps.cust_trx_type_id
		and    types.org_id = ps.org_id
                and    nvl(types.exclude_from_late_charges,'N') <> 'Y'
               )
          group by customer_id,
                   customer_site_use_id,
                   currency_code,
                   legal_entity_id,
		   org_id);
        IF l_debug_flag = 'Y' THEN
              debug( 'ar_calc_late_charge.insert_credit_amount()-' );
        END IF;
   EXCEPTION
     WHEN  OTHERS THEN
        --IF l_debug_flag = 'Y' THEN
            debug('EXCEPTION : '||SQLCODE||' : '||SQLERRM);
            debug('EXCEPTION: ar_calc_late_charge.insert_credit_amount' );
        --END IF;
        RAISE;

END insert_credit_amount;

/*=========================================================================================+
 | PROCEDURE insert_int_overdue_adj_dm                                                     |
 |                                                                                         |
 | DESCRIPTION                                                                             |
 |                                                                                         |
 |   This procedure calculates the overdue balance of the debit items and applies those    |
 |   against the credit items in the order of the due_date. The Interest Amount is  then   |
 |   calculated on the remaining amount of those debit items and inserted into             |
 |   ar_late_charge_trx_t                                                                  |
 |                                                                                         |
 | PSEUDO CODE/LOGIC                                                                       |
 |                                                                                         |
 |  a) Get the overdue balances of the debit items as sum of                               |
 |       i) amount_due_remaining from ar_payment_schedules                                 |
 |      ii) amount_applied + discount from ar_receivable_applications after the            |
 |          finance charge date. Note that the trx_date of the credit items is considered  |
 |          for determining this as compared to the application date                       |
 |     iii) amount_adjusted from ar_adjustments after the finance charge date              |
 |  b) If simple / flat interest has to be computed, the finance charge computed before    |
 |     finance charge date has to be deducted from the above amount.                       |
 |  c) From the above computed balance, the debit items are adjusted against the credit    |
 |     amount in the order of the due date. If two debit items have the same due date, the |
 |     debit items are ordered in the order of their payment schedule ids                  |
 |                                                                                         |
 | PARAMETERS                                                                              |
 |                                                                                         |
 |                                                                                         |
 | KNOWN ISSUES                                                                            |
 |                                                                                         |
 | NOTES                                                                                   |
 |                                                                                         |
 |   Original_balance        : This is the balance as of the finance charge date           |
 |   Overdue_late_pay_amount : This is the amount on which finance charge is computed.     |
 |                             This could be different from original balance as the credits|
 |                             could have been adjusted against this                       |
 |                                                                                         |
 | MODIFICATION HISTORY                                                                    |
 | Date                  Author            Description of Changes                          |
 | 15-FEB-2006           rkader            Created                                         |
 | 19-JUL-2006           rkader            Bug fix 5290709 : Credit items are also         |
 |                                         selected with display_flag N. So the ordering   |
 |                                         should be such that, the credit items will come |
 |                                         last. Debit items with positive sign should come|
 |                                         before the debit items with negative sign       |
 |                                                                                         |
 *=========================================================================================*/

PROCEDURE insert_int_overdue_adj_dm(p_fin_charge_date 	IN	DATE,
				    p_worker_number     IN      NUMBER,
                                    p_total_workers     IN      NUMBER) IS
 l_fin_charge_date	DATE;
 l_worker_number        number;
 l_total_workers        number;
BEGIN
        IF l_debug_flag = 'Y' THEN
              debug( 'ar_calc_late_charge.insert_int_overdue_adj_dm()+' );
        END IF;

        l_fin_charge_date	:=	p_fin_charge_date;
        l_worker_number         :=      p_worker_number;
        l_total_workers         :=      p_total_workers;

        insert into ar_late_charge_trx_t
                (late_charge_trx_id,
                 customer_id,
                 customer_site_use_id,
                 currency_code,
                 customer_trx_id,
                 legal_entity_id,
                 payment_schedule_id,
                 class,
                 amount_due_original,
                 amount_due_remaining,
                 fin_charge_charged,
                 trx_date,
                 cust_trx_type_id,
                 last_charge_date,
                 exchange_rate_type,
                 min_interest_charge,
                 max_interest_charge,
                 overdue_late_pay_amount,
                 original_balance,
                 due_date,
                 receipt_date,
                 finance_charge_date,
                 charge_type,
                 actual_date_closed,
                 interest_rate,
                 interest_days,
                 rate_start_date,
                 rate_end_date,
                 schedule_days_start,
                 schedule_days_to,
                 late_charge_amount,
                 late_charge_type,
                 late_charge_term_id,
                 interest_period_days,
                 interest_calculation_period,
                 charge_on_finance_charge_flag,
                 message_text_id,
                 interest_type,
                 min_fc_invoice_overdue_type,
                 min_fc_invoice_amount,
                 min_fc_invoice_percent,
                 charge_line_type,
		 org_id,
		 request_id,
                 display_flag)
      ( select
                 ar_late_charge_trx_s.nextval,
                 c.customer_id,
                 c.customer_site_use_id ,
                 c.invoice_currency_code,
                 c.customer_trx_id,
                 c.legal_entity_id,
                 c.payment_schedule_id,
                 c.class ,
                 c.amount_due_original,
                 c.amount_due_remaining ,
                 c.fin_charge_charged,
                 c.trx_date,
                 c.cust_trx_type_id,
                 c.last_charge_date,
                 c.exchange_rate_type,
                 c.min_interest_charge,
                 c.max_interest_charge,
                 decode(c.class,
                        'CM',0,
                        'PMT',0,
                        decode(dense_rank() over(partition by c.customer_id,
                                                  c.customer_site_use_id,
                                                  c.invoice_currency_code,
                                                  c.legal_entity_id,
                                                  c.org_id
                                         order by decode(c.class,
                                                               'PMT',99,
                                                               'CM',99,
                                                               decode(sign(c.overdue_amt),+1,-1,1)),
                                                  c.balance_rtotal), 1, c.balance_rtotal,
                                                                     2, decode(sign(c.balance_rtotal-c.overdue_amt),
                                                                                +1, c.overdue_amt, c.balance_rtotal),
                                                                     c.overdue_amt)) overdue_amount,
                 c.original_balance,
                 c.due_date,
                 NULL receipt_date,
                 c.fin_charge_date,
                 c.charge_type,
                 c.actual_date_closed,
                 decode(c.interest_type,
                        'CHARGES_SCHEDULE',sched_lines.rate,
                        'FIXED_RATE',c.interest_rate, NULL) interest_rate,
                 least(decode(c.multiple_interest_rates_flag,
                                 'Y',decode(sched_hdrs.schedule_header_type,
                                            'RATE',
                                             nvl(sched_hdrs.end_date,c.eff_fin_charge_date),
                                             c.eff_fin_charge_date),
                               c.eff_fin_charge_date)) -
                  greatest(decode(c.multiple_interest_rates_flag,
                                  'Y',decode(sched_hdrs.schedule_header_type,
                                            'RATE',sched_hdrs.start_date-1,c.eff_due_date),
                                  c.eff_due_date), c.eff_due_date,c.eff_last_charge_date) interest_days,
                 sched_hdrs.start_date rate_start_date,
                 sched_hdrs.end_date rate_end_date ,
                 bucket_lines.days_start schedule_days_start,
                 bucket_lines.days_to  schedule_days_to    ,
                 decode(c.class, 'PMT',0,'CM',0,
                        decode(decode(dense_rank()
                               over(partition by c.customer_id,
                                                 c.customer_site_use_id,
                                                 c.invoice_currency_code,
                                                 c.legal_entity_id,
						 c.org_id
                                    order by c.balance_rtotal),
                             1, c.balance_rtotal,
                             2, decode(sign(c.balance_rtotal-c.overdue_amt),
                                      +1, c.overdue_amt, c.balance_rtotal),
                             c.overdue_amt),
                       0,0,
                       decode(c.interest_type,'FIXED_AMOUNT',decode(c.class,'INV',decode(sign(c.original_balance),-1,0,c.interest_fixed_amount),c.interest_fixed_amount), /*Bug 8559863*/
                                              'CHARGE_PER_TIER', sched_lines.amount,  /*Late Charge Charge per tier Enhacement 6469663*/
                               decode(sched_hdrs.schedule_header_type,'AMOUNT', sched_lines.amount,
                                      ar_calc_late_charge.calculate_interest(
                                            decode(dense_rank()
                                                      over(partition by c.customer_id,
                                                                        c.customer_site_use_id,
                                                                        c.invoice_currency_code,
                                                                        c.legal_entity_id,
                                                                        c.org_id
                                                           order by decode(c.class,
                                                               'PMT',99,
                                                               'CM',99,
                                                               decode(sign(c.overdue_amt),+1,-1,1)),c.balance_rtotal),
                                                       1, c.balance_rtotal,
                                                       2, decode(sign(c.balance_rtotal-c.overdue_amt),
                                                                  +1, c.overdue_amt, c.balance_rtotal),
                                                       c.overdue_amt),
                                             c.charge_on_finance_charge_flag,
                                             least(decode(c.multiple_interest_rates_flag,
                                                          'Y',decode(sched_hdrs.schedule_header_type,
                                                                     'RATE',
                                                                      nvl(sched_hdrs.end_date,c.eff_fin_charge_date),
                                                                      c.eff_fin_charge_date),
                                                           c.eff_fin_charge_date)) -
                                                greatest(decode(c.multiple_interest_rates_flag,
                                                               'Y',decode(sched_hdrs.schedule_header_type,
                                                                          'RATE',sched_hdrs.start_date-1,
                                                                           c.eff_due_date),
                                                                c.eff_due_date), c.eff_due_date,c.eff_last_charge_date),
                                              decode(c.interest_type,
                                                     'CHARGES_SCHEDULE',sched_lines.rate,
                                                     'FIXED_RATE',c.interest_rate, NULL),
                                              c.interest_period_days,
                                              c.invoice_currency_code,
					      c.payment_schedule_id))))) late_charge_amount,
                 c.late_charge_type,
                 c.late_charge_term_id,
                 c.interest_period_days,
                 c.interest_calculation_period,
                 c.charge_on_finance_charge_flag,
                 c.message_text_id,
                 c.interest_type,
                 c.min_fc_invoice_overdue_type,
                 c.min_fc_invoice_amount,
                 c.min_fc_invoice_percent,
                 'INTEREST',
		 c.org_id,
		 l_request_id,
                 decode(c.class,
                        'PMT','N',
                        'CM','N',
                        decode(decode(dense_rank() over(partition by c.customer_id,
                                                  c.customer_site_use_id,
                                                  c.invoice_currency_code,
                                                  c.legal_entity_id,
                                                  c.org_id
                                         order by decode(c.class,
                                                         'PMT',99,
                                                         'CM',99,
                                                         decode(sign(c.overdue_amt),+1,-1,1)),
                                                  c.balance_rtotal), 1, c.balance_rtotal,
                                                                     2, decode(sign(c.balance_rtotal-c.overdue_amt),
                                                                                +1, c.overdue_amt, c.balance_rtotal),
                                                                     c.overdue_amt) ,
                                0,'N','Y')) display_flag
  from
      (select
                 b.customer_id,
                 b.customer_site_use_id ,
                 b.invoice_currency_code,
                 b.customer_trx_id,
                 b.legal_entity_id,
                 b.payment_schedule_id,
                 b.class ,
                 b.amount_due_original,
                 b.amount_due_remaining ,
                 b.fin_charge_charged,
                 b.trx_date,
                 b.cust_trx_type_id,
                 nvl(b.last_charge_date,
                     decode(b.fin_charge_charged,
                            0,NULL,
                            b.last_accrue_charge_date)) last_charge_date,
                 b.exchange_rate_type,
                 b.min_interest_charge,
                 b.max_interest_charge,
                 b.overdue_amt,
                 b.original_balance,
                 b.due_date,
                 b.fin_charge_date,
                 b.charge_type,
                 b.actual_date_closed,
                 b.late_charge_type,
                 b.late_charge_term_id,
                 b.interest_period_days,
                 b.interest_calculation_period,
                 b.charge_on_finance_charge_flag,
                 b.message_text_id,
                 nvl(credits.credit_amount,0) credit_amount,
                 b.interest_type,
                 b.min_fc_invoice_overdue_type,
                 b.min_fc_invoice_amount,
                 b.min_fc_invoice_percent,
                 b.interest_rate,
                 b.interest_schedule_id,
                 b.multiple_interest_rates_flag,
                 b.interest_fixed_amount,
                 b.org_id,
                 decode(b.interest_calculation_period,
                        'DAILY',l_fin_charge_date,
                        'MONTHLY',last_day(l_fin_charge_date)) eff_fin_charge_date,
                 decode(b.interest_calculation_period,
                        'DAILY',nvl(b.last_charge_date,
                                    decode(b.fin_charge_charged,
                                           0,b.due_date,
                                           b.last_accrue_charge_date)),
                        'MONTHLY',first_day(nvl(b.last_charge_date,
                                                decode(b.fin_charge_charged,
                                                       0,b.due_date,
                                                       b.last_accrue_charge_date)))) eff_last_charge_date,
                 decode(b.interest_calculation_period,
                        'DAILY',b.due_date,
                        'MONTHLY',first_day(b.due_date)) eff_due_date,
                 decode(sign(nvl(credits.credit_amount,0) - sum(b.overdue_amt)
                                                over(partition by b.customer_id,
                                                     b.customer_site_use_id,
                                                     b.invoice_currency_code,
                                                     b.legal_entity_id,
				                     b.org_id
                                                order by decode(b.class,
                                                               'PMT',99,
                                                               'CM',99,
                                                               decode(sign(b.overdue_amt),+1,-1,1)),
                                                         b.due_date, b.payment_schedule_id)),+1,0,0,0,
                   (sum(b.overdue_amt)
                        over(partition by b.customer_id,
                                          b.customer_site_use_id,
                                          b.invoice_currency_code,
                                          b.legal_entity_id,
                                          b.org_id
                           order by decode(b.class,
                                          'PMT',99,
                                          'CM',99,
                                          decode(sign(b.overdue_amt),+1,-1,1)),
                                    b.due_date, b.payment_schedule_id) - nvl(credits.credit_amount,0))) balance_rtotal
 from (
       select
                 a.customer_id,
                 a.customer_site_use_id ,
                 a.invoice_currency_code,
                 a.customer_trx_id,
                 nvl(trx.legal_entity_id,cr.legal_entity_id) legal_entity_id,
                 a.payment_schedule_id,
                 a.class ,
                 a.amount_due_original,
                 a.amount_due_remaining ,
                 sum(a.fin_charge_charged) fin_charge_charged,
                 a.trx_date,
                 a.cust_trx_type_id,
                 a.last_charge_date,
                 a.last_accrue_charge_date,
                 a.exchange_rate_type,
                 a.min_interest_charge,
                 a.max_interest_charge,
                 sum(decode(a.charge_on_finance_charge_flag,'Y', a.overdue_amt,
                            a.overdue_amt- a.fin_charge_charged)) overdue_amt,
                 sum(a.overdue_amt) original_balance,
                 a.due_date,
                 a.fin_charge_date,
                 a.charge_type,
                 a.actual_date_closed,
                 a.late_charge_type,
                 a.late_charge_term_id,
                 a.interest_period_days,
                 a.interest_calculation_period,
                 a.charge_on_finance_charge_flag,
                 a.message_text_id,
                 --credits.credit_amount,
                 a.interest_type,
                 a.min_fc_invoice_overdue_type,
                 a.min_fc_invoice_amount,
                 a.min_fc_invoice_percent,
                 a.interest_rate,
                 a.interest_schedule_id,
                 a.multiple_interest_rates_flag,
                 a.hold_charged_invoices_flag,
                 a.interest_fixed_amount,
                 a.org_id
           from (
           select
                 ps.customer_id,
                 decode(ps.class,
                        'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                         ps.customer_site_use_id,
									 ps.org_id),
                        ps.customer_site_use_id) customer_site_use_id ,
                 ps.invoice_currency_code,
                 ps.customer_trx_id,
                 ps.payment_schedule_id,
                 ps.class ,
                 ps.amount_due_original,
                 ps.amount_due_remaining,
                 sum(case when adj.apply_date > l_fin_charge_date
                      then adj.amount*-1 else 0 end )  overdue_amt,
                 sum(case when adj.apply_date <= l_fin_charge_date then
                          case when adj.type ='CHARGES' then
                             case when adj.adjustment_type = 'A'
                                 then adj.amount else 0 end
                          else 0 end
                      else 0 end)  fin_charge_charged,
                 ps.trx_date,
                 ps.cust_trx_type_id,
                 ps.last_charge_date,
                 cust_site.exchange_rate,
                 cust_site.exchange_rate_type,
                 cust_site.min_interest_charge,
                 cust_site.max_interest_charge,
                 ps.due_date,
                 l_fin_charge_date  fin_charge_date,
                 cust_site.late_charge_type,
                 cust_site.late_charge_term_id    ,
                 cust_site.interest_period_days,
                 cust_site.interest_calculation_period,
                 cust_site.charge_on_finance_charge_flag,
                 cust_site.message_text_id,
                 ps.actual_date_closed,
                 cust_site.last_accrue_charge_date,
                 cust_site.interest_type,
                 cust_site.interest_rate,
                 cust_site.interest_fixed_amount,
                 cust_site.min_fc_invoice_overdue_type,
                 cust_site.min_fc_invoice_amount,
                 cust_site.min_fc_invoice_percent,
                 cust_site.interest_schedule_id interest_schedule_id,
                 cust_site.multiple_interest_rates_flag,
                 cust_site.hold_charged_invoices_flag,
                 ps.org_id,
                 ps.cash_receipt_id,
                 'OVERDUE' charge_type
            from  ar_payment_schedules ps,
                  ar_adjustments adj,
                  ar_lc_cust_sites_t cust_site,
                  ar_late_charge_cust_balance_gt bal
            where ps.customer_id = cust_site.customer_id
            and   cust_site.customer_site_use_id = decode(ps.class,
                                                    'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                                             ps.customer_site_use_id,
											     ps.org_id),
                                                     ps.customer_site_use_id)
            and   ps.invoice_currency_code = cust_site.currency_code
            and   mod(nvl(cust_site.customer_site_use_id,0),l_total_workers) =
                                          decode(l_total_workers,l_worker_number,0,l_worker_number)
            and   ps.org_id = cust_site.org_id
            and   ps.actual_date_closed > l_fin_charge_date
            and   cust_site.late_charge_calculation_trx in ('OVERDUE_LATE','OVERDUE')
            and   cust_site.late_charge_type in ('ADJ','DM')
            /* Apply Customer Level tolerances */
            and   cust_site.lc_cust_sites_id = bal.late_charge_cust_sites_id
	    and	  cust_site.org_id  = bal.org_id
            and   decode(cust_site.min_fc_balance_overdue_type,
                         'PERCENT',(nvl(cust_site.min_fc_balance_percent,0)
                                    * nvl(bal.customer_open_balance,0)/100),
                         'AMOUNT',nvl(cust_site.min_fc_balance_amount,0),
                         0) <= nvl(bal.customer_overdue_balance,0)
            and   decode(nvl(cust_site.disputed_transactions_flag,'N'),
                         'N',decode(nvl(ps.amount_in_dispute,0),
                                       0, 'Y','N'),
                         'Y' ) = 'Y'
            and   decode(nvl(cust_site.credit_items_flag,'N'),
                         'N',decode(ps.class,'INV',decode(sign(ps.amount_due_original),-1,'N','Y'),'Y'),
                         'Y' ) = 'Y'                    /*Bug8559863*/
            --and   ps.class not in ('CM','PMT')
            and   ps.due_date < (l_fin_charge_date - nvl(cust_site.payment_grace_days,0))
            and   nvl(ps.last_charge_date,l_fin_charge_date-1) < l_fin_charge_date
            and   nvl(ps.receipt_confirmed_flag, 'Y') = 'Y'
            and   nvl(cust_site.charge_begin_date,ps.due_date) <= ps.due_date
            and   adj.payment_schedule_id = ps.payment_schedule_id
            and   adj.status = 'A'
            group by
                  ps.customer_id,
                  decode(ps.class,
                        'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                         ps.customer_site_use_id,
									 ps.org_id),
                        ps.customer_site_use_id),
                  ps.invoice_currency_code,
                  ps.customer_trx_id,
                  ps.payment_schedule_id,
                  ps.class ,
                  ps.amount_due_original,
                  ps.amount_due_remaining,
                  ps.trx_date,
                  ps.cust_trx_type_id,
                  ps.last_charge_date,
                  cust_site.exchange_rate,
                  cust_site.exchange_rate_type,
                  cust_site.min_interest_charge,
                  cust_site.max_interest_charge,
                  ps.due_date,
                  l_fin_charge_date ,
                  cust_site.late_charge_type,
                  cust_site.late_charge_term_id    ,
                  cust_site.interest_period_days,
                  cust_site.interest_calculation_period,
                  cust_site.charge_on_finance_charge_flag,
                  cust_site.message_text_id,
                  ps.actual_date_closed,
                  cust_site.interest_type,
                  cust_site.interest_rate,
                  cust_site.interest_fixed_amount,
                  cust_site.min_fc_invoice_overdue_type,
                  cust_site.min_fc_invoice_amount,
                  cust_site.min_fc_invoice_percent,
                  cust_site.interest_schedule_id,
                  cust_site.multiple_interest_rates_flag,
                  cust_site.hold_charged_invoices_flag,
		  ps.org_id,
                  ps.cash_receipt_id,
                  cust_site.last_accrue_charge_date
            union all
          select  ps.customer_id,
                  decode(ps.class,
                         'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                          ps.customer_site_use_id,
									  ps.org_id),
                         ps.customer_site_use_id) customer_site_use_id,
                  ps.invoice_currency_code,
                  ps.customer_trx_id,
                  ps.payment_schedule_id,
                  ps.class ,
                  ps.amount_due_original,
                  ps.amount_due_remaining,
                  sum(app.amount_applied + nvl(app.earned_discount_taken,0)
                                     + nvl(app.unearned_discount_taken,0)) overdue_amt,
                  0 fin_charge_charged,
                  ps.trx_date,
                  ps.cust_trx_type_id,
                  ps.last_charge_date,
                  cust_site.exchange_rate,
                  cust_site.exchange_rate_type,
                  cust_site.min_interest_charge,
                  cust_site.max_interest_charge,
                  ps.due_date,
                  l_fin_charge_date ,
                  cust_site.late_charge_type,
                  cust_site.late_charge_term_id    ,
                  cust_site.interest_period_days,
                  cust_site.interest_calculation_period,
                  cust_site.charge_on_finance_charge_flag,
                  cust_site.message_text_id,
                  ps.actual_date_closed,
                  cust_site.last_accrue_charge_date ,
                  cust_site.interest_type,
                  cust_site.interest_rate,
                  cust_site.interest_fixed_amount,
                  cust_site.min_fc_invoice_overdue_type,
                  cust_site.min_fc_invoice_amount,
                  cust_site.min_fc_invoice_percent,
                  cust_site.interest_schedule_id,
                  cust_site.multiple_interest_rates_flag,
                  cust_site.hold_charged_invoices_flag,
                  ps.org_id,
                  ps.cash_receipt_id,
                  'OVERDUE' charge_type
            from  ar_payment_schedules ps,
                  ar_receivable_applications app,
                  ar_payment_schedules ps_cm_cr,
                  ar_lc_cust_sites_t cust_site,
                  ar_late_charge_cust_balance_gt bal
           where  ps.customer_id = cust_site.customer_id
            and   cust_site.customer_site_use_id = decode(ps.class,
                                                   'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                                             ps.customer_site_use_id,
											     ps.org_id),
                                                    ps.customer_site_use_id)
            and   ps.invoice_currency_code = cust_site.currency_code
            and   mod(nvl(cust_site.customer_site_use_id,0),l_total_workers) =
                                          decode(l_total_workers,l_worker_number,0,l_worker_number)
            and   ps.org_id = cust_site.org_id
            and   ps.actual_date_closed > l_fin_charge_date
            and   cust_site.late_charge_calculation_trx in ('OVERDUE_LATE','OVERDUE')
            and   cust_site.late_charge_type in ('ADJ','DM')
            /* Apply Customer Level tolerances */
            and   cust_site.lc_cust_sites_id = bal.late_charge_cust_sites_id
	    and   cust_site.org_id = bal.org_id
            and   decode(cust_site.min_fc_balance_overdue_type,
                         'PERCENT',(nvl(cust_site.min_fc_balance_percent,0)
                                    * nvl(bal.customer_open_balance,0)/100),
                         'AMOUNT',nvl(cust_site.min_fc_balance_amount,0),
                          0) <= nvl(bal.customer_overdue_balance,0)
            and   decode(nvl(cust_site.disputed_transactions_flag,'N'),
                         'N',decode(nvl(ps.amount_in_dispute,0),
                                       0, 'Y','N'),
                         'Y' ) = 'Y'
            and   decode(nvl(cust_site.credit_items_flag,'N'),
                         'N',decode(ps.class,'INV',decode(sign(ps.amount_due_original),-1,'N','Y'),'Y'),
                         'Y' ) = 'Y'                    /*Bug8559863*/
            and   ps.due_date < (l_fin_charge_date - nvl(cust_site.payment_grace_days,0))
            and   nvl(ps.last_charge_date,l_fin_charge_date-1) < l_fin_charge_date
            and   nvl(ps.receipt_confirmed_flag, 'Y') = 'Y'
            and   app.applied_payment_schedule_id = ps.payment_schedule_id
            --and   ps.class not in ('CM','PMT')
            and   nvl(cust_site.charge_begin_date,ps.due_date) <= ps.due_date
            and   app.status = 'APP'
            and   nvl( app.confirmed_flag, 'Y' ) = 'Y'
            /* The receipt or Credit Memo date should be considered for applications */
            and   ps_cm_cr.payment_schedule_id = app.payment_schedule_id
            and   ps_cm_cr.trx_date > l_fin_charge_date
         group by ps.customer_id,
                  decode(ps.class,
                        'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                         ps.customer_site_use_id,
									 ps.org_id),
                        ps.customer_site_use_id),
                  ps.invoice_currency_code,
                  ps.customer_trx_id,
                  ps.payment_schedule_id,
                  ps.class ,
                  ps.amount_due_original,
                  ps.amount_due_remaining,
                  ps.trx_date,
                  ps.cust_trx_type_id,
                  ps.last_charge_date,
                  cust_site.exchange_rate,
                  cust_site.exchange_rate_type,
                  cust_site.min_interest_charge,
                  cust_site.max_interest_charge,
                  ps.due_date,
                  l_fin_charge_date ,
                  cust_site.late_charge_type,
                  cust_site.late_charge_term_id    ,
                  cust_site.interest_period_days,
                  cust_site.interest_calculation_period,
                  cust_site.charge_on_finance_charge_flag,
                  cust_site.message_text_id,
                  ps.actual_date_closed ,
                  cust_site.interest_type,
                  cust_site.interest_rate,
                  cust_site.interest_fixed_amount,
                  cust_site.min_fc_invoice_overdue_type,
                  cust_site.min_fc_invoice_amount,
                  cust_site.min_fc_invoice_percent,
                  cust_site.interest_schedule_id,
                  cust_site.multiple_interest_rates_flag,
                  cust_site.hold_charged_invoices_flag,
                  ps.org_id,
                  ps.cash_receipt_id,
                  cust_site.last_accrue_charge_date
           UNION ALL
           select ps.customer_id,
                  decode(ps.class,
                         'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                         ps.customer_site_use_id,
									 ps.org_id),
                          ps.customer_site_use_id) customer_site_use_id,
                  ps.invoice_currency_code,
                  ps.customer_trx_id,
                  ps.payment_schedule_id,
                  ps.class ,
                  ps.amount_due_original,
                  ps.amount_due_remaining,
                  ps.amount_due_remaining overdue_amt,
                  0 fin_charge_charged,
                  ps.trx_date,
                  ps.cust_trx_type_id,
                  ps.last_charge_date,
                  cust_site.exchange_rate,
                  cust_site.exchange_rate_type,
                  cust_site.min_interest_charge,
                  cust_site.max_interest_charge,
                  ps.due_date,
                  l_fin_charge_date ,
                  cust_site.late_charge_type,
                  cust_site.late_charge_term_id    ,
                  cust_site.interest_period_days,
                  cust_site.interest_calculation_period,
                  cust_site.charge_on_finance_charge_flag,
                  cust_site.message_text_id,
                  ps.actual_date_closed,
                  cust_site.last_accrue_charge_date ,
                  cust_site.interest_type,
                  cust_site.interest_rate,
                  cust_site.interest_fixed_amount,
                  cust_site.min_fc_invoice_overdue_type,
                  cust_site.min_fc_invoice_amount,
                  cust_site.min_fc_invoice_percent,
                  cust_site.interest_schedule_id,
                  cust_site.multiple_interest_rates_flag,
                  cust_site.hold_charged_invoices_flag,
     		  ps.org_id,
                  ps.cash_receipt_id,
                  'OVERDUE' charge_type
            from  ar_payment_schedules ps,
                  ar_lc_cust_sites_t cust_site,
                  ar_late_charge_cust_balance_gt bal
            where ps.customer_id = cust_site.customer_id
            and   cust_site.customer_site_use_id = decode(ps.class,
                                                     'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                                           ps.customer_site_use_id,
											   ps.org_id),
                                                     ps.customer_site_use_id)
            and   ps.invoice_currency_code = cust_site.currency_code
            and   mod(nvl(cust_site.customer_site_use_id,0),l_total_workers) =
                                          decode(l_total_workers,l_worker_number,0,l_worker_number)
 	    and   ps.org_id = cust_site.org_id
            and   ps.actual_date_closed > l_fin_charge_date
            and   cust_site.late_charge_calculation_trx in ('OVERDUE_LATE','OVERDUE')
            and   cust_site.late_charge_type in ('ADJ','DM')
            /* Apply Customer Level tolerances */
            and   cust_site.lc_cust_sites_id = bal.late_charge_cust_sites_id
	    and   cust_site.org_id = bal.org_id
            and   decode(cust_site.min_fc_balance_overdue_type,
                         'PERCENT',(nvl(cust_site.min_fc_balance_percent,0)
                                    * nvl(bal.customer_open_balance,0)/100),
                         'AMOUNT',nvl(cust_site.min_fc_balance_amount,0),
                           0) <= nvl(bal.customer_overdue_balance,0)
            and   decode(nvl(cust_site.disputed_transactions_flag,'N'),
                         'N',decode(nvl(ps.amount_in_dispute,0),
                                       0, 'Y','N'),
                         'Y' ) = 'Y'
            and   decode(nvl(cust_site.credit_items_flag,'N'),
                         'N',decode(ps.class,'INV',decode(sign(ps.amount_due_original),-1,'N','Y'),'Y'),
                         'Y' ) = 'Y'                    /*Bug8559863*/
            --and   ps.class not in ('PMT','CM')
            and   nvl(cust_site.charge_begin_date,ps.due_date) <= ps.due_date
            and   ps.due_date < (l_fin_charge_date - nvl(cust_site.payment_grace_days,0))
            and   nvl(ps.last_charge_date,l_fin_charge_date-1) < l_fin_charge_date
            and   nvl(ps.receipt_confirmed_flag, 'Y') = 'Y') a,
                  ra_customer_trx  trx,
                  ar_transaction_history th,
                  ra_cust_trx_types types,
                  ar_cash_receipts cr
        where  trx.customer_trx_id(+) = a.customer_trx_id
        and    nvl(trx.finance_charges,decode(a.class,'DEP','N','Y')) = 'Y'
        and    a.customer_trx_id = th.customer_trx_id(+)
        and    nvl(th.current_record_flag,'Y') = 'Y'
        and    nvl(th.status,'*') not in ('PROTESTED','MATURED_PEND_RISK_ELIMINATION','CLOSED', 'CANCELLED')
        and    types.cust_trx_type_id(+) = a.cust_trx_type_id
        and    types.org_id(+) = a.org_id
        and    nvl(types.exclude_from_late_charges,'N') <> 'Y'
        and    cr.cash_receipt_id(+) = a.cash_receipt_id
        group by
               a.customer_id,
               a.customer_site_use_id ,
               a.invoice_currency_code,
               a.customer_trx_id,
               nvl(trx.legal_entity_id,cr.legal_entity_id),
               a.payment_schedule_id,
               a.class,
               a.amount_due_original,
               a.amount_due_remaining ,
               a.trx_date,
               a.cust_trx_type_id,
               a.last_charge_date,
               a.last_accrue_charge_date,
               a.exchange_rate_type,
               a.min_interest_charge,
               a.max_interest_charge,
               a.due_date,
               a.fin_charge_date,
               a.charge_type,
               a.actual_date_closed,
               a.late_charge_type,
               a.late_charge_term_id,
               a.interest_period_days,
               a.interest_calculation_period,
               a.charge_on_finance_charge_flag,
               a.message_text_id,
               --credits.credit_amount,
               a.interest_type,
               a.min_fc_invoice_overdue_type,
               a.min_fc_invoice_amount,
               a.min_fc_invoice_percent,
               a.interest_rate,
               a.interest_schedule_id,
               a.multiple_interest_rates_flag,
               a.hold_charged_invoices_flag,
               a.org_id,
               a.interest_fixed_amount)b,
               ar_late_charge_credits_gt credits
            where decode(b.hold_charged_invoices_flag,
                        'Y',decode(b.last_charge_date,
                                   NULL,b.fin_charge_charged,1),
                         0) = 0
              and b.customer_id = credits.customer_id(+)
	      and b.customer_site_use_id = credits.customer_site_use_id (+)
	      and b.invoice_currency_code = credits.currency_code (+)
              and b.org_id = credits.org_id (+)
	      and b.legal_entity_id = credits.legal_entity_id(+))c,
                  ar_charge_schedule_hdrs sched_hdrs,
                  ar_charge_schedule_lines  sched_lines,
                  ar_aging_bucket_lines bucket_lines
         where   c.interest_schedule_id = sched_hdrs.schedule_id(+)
           and   sched_hdrs.schedule_header_id = sched_lines.schedule_header_id(+)
           and   sched_hdrs.schedule_id = sched_lines.schedule_id(+)
           and    nvl(sched_hdrs.status,'A') = 'A'
           and   sched_lines.aging_bucket_id = bucket_lines.aging_bucket_id(+)
           and   sched_lines.aging_bucket_line_id = bucket_lines.aging_bucket_line_id(+)
           /* Condition 1: days late should be between the bucket lines start and end days */
           and   (l_fin_charge_date- c.due_date) >= nvl(bucket_lines.days_start,(l_fin_charge_date- c.due_date))
           and   (l_fin_charge_date - c.due_date) <= nvl(bucket_lines.days_to,(l_fin_charge_date- c.due_date))
           /* Condition 2: Start_date of the schedule should be less than or equal to the
              finance charge date */
           and   nvl(sched_hdrs.start_date,l_fin_charge_date) <= l_fin_charge_date
          /* condition 3:
              If multiple interest rates have to be used, end date of the schedule should be greater than
              or equal to the due date or the date from which we are calculating the charge
              Otherwise, the end_date should either be null or it should be greater than the
              due_date
               */
           and  (decode(c.multiple_interest_rates_flag,'Y',
                        decode(sched_hdrs.schedule_header_type,
                               'RATE',greatest(c.due_date,nvl(c.last_charge_date,c.due_date)),
                               c.due_date),
                        c.due_date) <= sched_hdrs.end_date
                   OR sched_hdrs.end_date IS NULL )
           /* Condition 4: If multiple rates need not be used, we should pick up the rate
              that is effective on the due date.
              Also note that the multiple interest rates are used only for Interest
              Calculation and only when rates are used*/
           and decode(c.multiple_interest_rates_flag,'Y',
                       decode(sched_hdrs.schedule_header_type,
                               'RATE',sched_hdrs.start_date,
                               c.due_date),
                       c.due_date)>= nvl(sched_hdrs.start_date,c.due_date)
           /* Make sure that this payment schedule is not part of a failed final batch */
            and not exists (select payment_schedule_id
                             from   ar_interest_lines lines,
                                    ar_interest_headers hdrs,
                                    ar_interest_batches bat
                             where  lines.payment_schedule_id = c.payment_schedule_id
                             and    lines.interest_header_id = hdrs.interest_header_id
                             and    hdrs.interest_batch_id = bat.interest_batch_id
                             and    bat.batch_status ='F'
                             and    bat.transferred_status <> 'S'));


   IF l_debug_flag = 'Y' THEN
      debug( 'ar_calc_late_charge.insert_int_overdue_adj_dm()-' );
   END IF;
    --
   EXCEPTION
     WHEN  OTHERS THEN
        --IF l_debug_flag = 'Y' THEN
            debug('EXCEPTION : '||SQLCODE||' : '||SQLERRM);
            debug('EXCEPTION: ar_calc_late_charge.insert_int_overdue_adj_dm' );
        --END IF;
        RAISE;
END insert_int_overdue_adj_dm;
/*=========================================================================================+
 | PROCEDURE insert_int_overdue_inv                                                        |
 |                                                                                         |
 | DESCRIPTION                                                                             |
 |                                                                                         |
 |   This procedure calculates the overdue balance of the debit and credit items. The      |
 |   Interest Amount is  then calculated on the overdue balance and inserted into          |
 |   ar_late_charge_trx_t                                                                  |
 |                                                                                         |
 | PSEUDO CODE/LOGIC                                                                       |
 |                                                                                         |
 |  a) Get the overdue balances of the items as sum of                                     |
 |       i) amount_due_remaining from ar_payment_schedules                                 |
 |      ii) amount_applied + discount from ar_receivable_applications after the            |
 |          finance charge date. The data on which the credit item is created is used      |
 |          instead of the application date                                                |
 |     iii) amount_adjusted from ar_adjustments after the finance charge date              |
 |  b) If simple / flat interest has to be computed, the finance charge computed before    |
 |     finance charge date has to be deducted from the above amount                        |
 |  c) In this case, the Credit items are treated similar to Debit Items. Interest is      |
 |     calculated on the credit items as done for debit items.                             |
 |                                                                                         |
 | PARAMETERS                                                                              |
 |                                                                                         |
 |                                                                                         |
 | KNOWN ISSUES                                                                            |
 |                                                                                         |
 | NOTES                                                                                   |
 |                                                                                         |
 | MODIFICATION HISTORY                                                                    |
 | Date                  Author            Description of Changes                          |
 | 15-FEB-2006           rkader            Created                                         |
 |                                                                                         |
 *=========================================================================================*/
PROCEDURE insert_int_overdue_inv(p_fin_charge_date	IN	DATE,
                                 p_worker_number        IN      NUMBER,
                                 p_total_workers        IN      NUMBER) IS

 l_fin_charge_date		DATE;
 l_worker_number                number;
 l_total_workers                number;

BEGIN
            IF l_debug_flag = 'Y' THEN
                debug( 'ar_calc_late_charge.insert_int_overdue_inv()+' );
            END IF;

            l_fin_charge_date	:= 	p_fin_charge_date;
            l_worker_number     :=      p_worker_number;
            l_total_workers     :=      p_total_workers;

            insert into ar_late_charge_trx_t
                (late_charge_trx_id,
                 customer_id,
                 customer_site_use_id,
                 currency_code,
                 customer_trx_id,
                 legal_entity_id,
                 payment_schedule_id,
                 class,
                 amount_due_original,
                 amount_due_remaining,
                 fin_charge_charged,
                 trx_date,
                 cust_trx_type_id,
                 last_charge_date,
                 exchange_rate_type,
                 min_interest_charge,
                 max_interest_charge,
                 overdue_late_pay_amount,
                 original_balance,
                 due_date,
                 receipt_date,
                 finance_charge_date,
                 charge_type,
                 actual_date_closed,
                 interest_rate,
                 interest_days,
                 rate_start_date,
                 rate_end_date,
                 schedule_days_start,
                 schedule_days_to,
                 late_charge_amount,
                 late_charge_type,
                 late_charge_term_id,
                 interest_period_days,
                 interest_calculation_period,
                 charge_on_finance_charge_flag,
                 message_text_id,
                 interest_type,
                 min_fc_invoice_overdue_type,
                 min_fc_invoice_amount,
                 min_fc_invoice_percent,
                 charge_line_type,
		 org_id,
                 request_id,
                 display_flag )
          (
          select ar_late_charge_trx_s.nextval,
                 b.customer_id,
                 b.customer_site_use_id ,
                 b.invoice_currency_code,
                 b.customer_trx_id,
                 b.legal_entity_id,
                 b.payment_schedule_id,
                 b.class ,
                 b.amount_due_original,
                 b.amount_due_remaining ,
                 b.fin_charge_charged,
                 b.trx_date,
                 b.cust_trx_type_id,
                 NVL(b.last_charge_date, decode(b.fin_charge_charged,
                                                   0, NULL,
                                                   b.last_accrue_charge_date)) last_charge_date,
                 b.exchange_rate_type,
                 b.min_interest_charge,
                 b.max_interest_charge,
                 b.overdue_amt,
                 b.original_balance,
                 b.due_date,
                 NULL,
                 b.fin_charge_date,
                 b.charge_type,
                 b.actual_date_closed,
                 decode(b.interest_type,
                        'CHARGES_SCHEDULE',sched_lines.rate,
                        'FIXED_RATE',b.interest_rate, NULL) interest_rate,
                 least(decode(b.multiple_interest_rates_flag,
                                  'Y',decode(sched_hdrs.schedule_header_type,
                                             'RATE',
                                              nvl(sched_hdrs.end_date,b.eff_fin_charge_date),
                                              b.eff_fin_charge_date),
                                    b.eff_fin_charge_date)) -
                   greatest(decode(b.multiple_interest_rates_flag,
                                  'Y',decode(sched_hdrs.schedule_header_type,
                                             'RATE',sched_hdrs.start_date-1,b.eff_due_date),
                                       b.eff_due_date), b.eff_due_date,b.eff_last_charge_date) interest_days,
                 sched_hdrs.start_date rate_start_date,
                 sched_hdrs.end_date rate_end_date,
                 bucket_lines.days_start schedule_days_start,
                 bucket_lines.days_to  schedule_days_to,
                 decode(b.interest_type,
                        'FIXED_AMOUNT',decode(b.class,
                                              'PMT', 0, /* -1* b.interest_fixed_amount,*/
                                              'CM', 0,  /*  -1 * b.interest_fixed_amount,*/
					      'INV',decode(sign(b.original_balance),-1,0,b.interest_fixed_amount),  /*Bug 8559863 Take 0 late charge for -ve invoices fixed_amount scenario */
                                              b.interest_fixed_amount),
                        'CHARGE_PER_TIER', sched_lines.amount,  /*Late charge case of charge per tier Enhacement 6469663*/
                              decode(sched_hdrs.schedule_header_type,
                                       'AMOUNT',decode(b.class,
                                                       'PMT',-1* sched_lines.amount,
                                                       'CM', -1* sched_lines.amount,
                                                       sched_lines.amount),
                                        ar_calc_late_charge.calculate_interest(
                                                           b.overdue_amt,
                                                           b.charge_on_finance_charge_flag,
                                                           least(decode(b.multiple_interest_rates_flag,
                                                                       'Y',decode(sched_hdrs.schedule_header_type,
                                                                                  'RATE',
                                                                                   nvl(sched_hdrs.end_date,
                                                                                         b.eff_fin_charge_date),
                                                                                   b.eff_fin_charge_date),
                                                                       b.eff_fin_charge_date)) -
                                                             greatest(decode(b.multiple_interest_rates_flag,
                                                                       'Y',decode(sched_hdrs.schedule_header_type,
                                                                                  'RATE',sched_hdrs.start_date-1,
                                                                                   b.eff_due_date),
                                                                        b.eff_due_date),b.eff_due_date,
                                                                        b.eff_last_charge_date),
                                                            decode(b.interest_type,
                                                                    'CHARGES_SCHEDULE',sched_lines.rate,
                                                                     'FIXED_RATE',b.interest_rate, NULL),
                                                            b.interest_period_days,
                                                            b.invoice_currency_code,
							    b.payment_schedule_id))) late_charge_amount,
                 b.late_charge_type,
                 b.late_charge_term_id,
                 b.interest_period_days,
                 b.interest_calculation_period,
                 b.charge_on_finance_charge_flag,
                 b.message_text_id,
                 b.interest_type,
                 b.min_fc_invoice_overdue_type,
                 b.min_fc_invoice_amount,
                 b.min_fc_invoice_percent,
                 'INTEREST',
                 b.org_id,
                 l_request_id,
                 'Y'
     from (
          select a.customer_id,
                 a.customer_site_use_id ,
                 a.invoice_currency_code,
                 nvl(a.customer_trx_id, a.cash_receipt_id) customer_trx_id,
                 nvl(trx.legal_entity_id,cr.legal_entity_id) legal_entity_id,
                 a.payment_schedule_id,
                 a.class ,
                 a.amount_due_original,
                 a.amount_due_remaining ,
                 sum(a.fin_charge_charged) fin_charge_charged,
                 a.trx_date,
                 a.cust_trx_type_id,
                 a.last_charge_date,
                 a.last_accrue_charge_date,
                 a.exchange_rate_type,
                 a.min_interest_charge,
                 a.max_interest_charge,
                 sum(decode(a.charge_on_finance_charge_flag,'Y', a.overdue_amt,
                             a.overdue_amt- a.fin_charge_charged)) overdue_amt,
                 sum(a.overdue_amt) original_balance,
                 a.due_date,
                 a.fin_charge_date,
                 a.charge_type,
                 a.actual_date_closed,
                 a.late_charge_type,
                 a.late_charge_term_id,
                 a.interest_period_days,
                 a.interest_calculation_period,
                 a.charge_on_finance_charge_flag,
                 a.message_text_id,
                 a.interest_type,
                 a.interest_rate,
                 a.interest_schedule_id,
                 a.min_fc_invoice_overdue_type,
                 a.min_fc_invoice_amount,
                 a.min_fc_invoice_percent,
                 a.multiple_interest_rates_flag,
                 a.hold_charged_invoices_flag,
		 a.org_id,
                 a.interest_fixed_amount,
                 decode(a.interest_calculation_period,
                        'DAILY',l_fin_charge_date,
                        'MONTHLY',last_day(l_fin_charge_date)) eff_fin_charge_date,
                 decode(a.interest_calculation_period,
                        'DAILY',nvl(a.last_charge_date,
                                    decode(a.fin_charge_charged,
                                           0,a.due_date,
                                           a.last_accrue_charge_date)),
                        'MONTHLY',first_day(nvl(a.last_charge_date,
                                                decode(a.fin_charge_charged,
                                                       0,a.due_date,
                                                       a.last_accrue_charge_date)))) eff_last_charge_date,
                 decode(a.interest_calculation_period,
                             'DAILY',a.due_date,
                             'MONTHLY',first_day(a.due_date)) eff_due_date
           from (
                  select
                      ps.customer_id,
                      decode(ps.class,
                             'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                              ps.customer_site_use_id,
									      ps.org_id),
                             'PMT',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                               ps.customer_site_use_id,
                                                                               ps.org_id),
                              ps.customer_site_use_id) customer_site_use_id,
                      ps.invoice_currency_code,
                      ps.customer_trx_id,
                      ps.payment_schedule_id,
                      ps.class ,
                      ps.amount_due_original,
                      ps.amount_due_remaining,
                      sum(case when adj.apply_date > l_fin_charge_date
                           then adj.amount*-1 else 0 end )  overdue_amt,
                      sum(case when adj.apply_date <= l_fin_charge_date then
                             case when adj.type ='CHARGES' then
                                 case when adj.adjustment_type = 'A'
                                      then adj.amount else 0 end
                                 else 0 end
                             else 0 end)  fin_charge_charged,
                      ps.trx_date,
                      ps.cust_trx_type_id,
                      ps.last_charge_date,
                      cust_site.exchange_rate,
                      cust_site.exchange_rate_type,
                      cust_site.min_interest_charge,
                      cust_site.max_interest_charge,
                      decode(ps.class,'PMT',ps.trx_date,ps.due_date) due_date,
                      l_fin_charge_date  fin_charge_date,
                      cust_site.late_charge_type,
                      cust_site.late_charge_term_id,
                      cust_site.interest_period_days,
                      cust_site.interest_calculation_period,
                      cust_site.charge_on_finance_charge_flag,
                      cust_site.message_text_id,
                      ps.actual_date_closed,
                      cust_site.last_accrue_charge_date,
                      cust_site.interest_type,
                      cust_site.interest_rate,
                      cust_site.interest_fixed_amount,
                      cust_site.interest_schedule_id interest_schedule_id,
                      cust_site.min_fc_invoice_overdue_type,
                      cust_site.min_fc_invoice_amount,
                      cust_site.min_fc_invoice_percent,
                      cust_site.multiple_interest_rates_flag,
                      cust_site.hold_charged_invoices_flag,
		      ps.org_id,
		      ps.cash_receipt_id,
                      'OVERDUE' charge_type
                  from  ar_payment_schedules ps,
                        ar_adjustments adj,
                        ar_lc_cust_sites_t cust_site,
                        ar_late_charge_cust_balance_gt bal
                   where ps.customer_id = cust_site.customer_id
                   and   cust_site.customer_site_use_id = decode(ps.class,
                                                       'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                                               ps.customer_site_use_id,
                                                                                               ps.org_id),
                                                       'PMT',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                                              ps.customer_site_use_id,
                                                                                              ps.org_id),
                                                         ps.customer_site_use_id)
                   and   ps.invoice_currency_code = cust_site.currency_code
                   and   mod(nvl(cust_site.customer_site_use_id,0),l_total_workers) =
                                          decode(l_total_workers,l_worker_number,0,l_worker_number)
		   and   ps.org_id = cust_site.org_id
                   and   ps.actual_date_closed > l_fin_charge_date
                   and   cust_site.late_charge_calculation_trx in ('OVERDUE_LATE','OVERDUE')
                   and   cust_site.late_charge_type = 'INV'
                   /* Apply Customer Level tolerances */
                   and   cust_site.lc_cust_sites_id = bal.late_charge_cust_sites_id
		   and   cust_site.org_id = bal.org_id
                   and   decode(cust_site.min_fc_balance_overdue_type,
                         'PERCENT',(nvl(cust_site.min_fc_balance_percent,0)
                                    * nvl(bal.customer_open_balance,0)/100),
                         'AMOUNT',nvl(cust_site.min_fc_balance_amount,0),
                           0) <= nvl(bal.customer_overdue_balance,0)
                   and   decode(nvl(cust_site.disputed_transactions_flag,'N'),
                                'N',decode(nvl(ps.amount_in_dispute,0),
                                           0, 'Y','N'),
                                'Y' ) = 'Y'
                   and   decode(cust_site.credit_items_flag,'N',
                            decode (ps.class, 'PMT','N','CM','N','Y'),'Y') = 'Y'
                   and   decode(ps.class,
                                'PMT', ps.trx_date,
                                ps.due_date) < decode(ps.class,
                                               'PMT', l_fin_charge_date,
                                               'CM', l_fin_charge_date,
                                               (l_fin_charge_date  - nvl(cust_site.payment_grace_days,0)))
                   and   nvl(ps.last_charge_date,l_fin_charge_date-1) < l_fin_charge_date
                   and   nvl(cust_site.charge_begin_date,decode(ps.class,'PMT',ps.trx_date,ps.due_date))
                                             <= decode(ps.class,'PMT',ps.trx_date,ps.due_date)
                   and   nvl(ps.receipt_confirmed_flag, 'Y') = 'Y'
                   and   adj.payment_schedule_id = ps.payment_schedule_id
                   and   adj.status = 'A'
                   group by
                   ps.customer_id,
                      decode(ps.class,
                             'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                              ps.customer_site_use_id,
									      ps.org_id),
                             'PMT',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                               ps.customer_site_use_id,
									       ps.org_id),
                              ps.customer_site_use_id),
                      ps.invoice_currency_code,
                      ps.customer_trx_id,
                      ps.payment_schedule_id,
                      ps.class ,
                      ps.amount_due_original,
                      ps.amount_due_remaining,
                      ps.trx_date,
                      ps.cust_trx_type_id,
                      ps.last_charge_date,
                      cust_site.exchange_rate,
                      cust_site.exchange_rate_type,
                      cust_site.min_interest_charge,
                      cust_site.max_interest_charge,
                      decode(ps.class,'PMT',ps.trx_date,ps.due_date),
                      l_fin_charge_date ,
                      cust_site.late_charge_type,
                      cust_site.late_charge_term_id    ,
                      cust_site.interest_period_days,
                      cust_site.interest_calculation_period,
                      cust_site.charge_on_finance_charge_flag,
                      cust_site.message_text_id,
                      ps.actual_date_closed,
                      cust_site.interest_type,
                      cust_site.interest_rate,
                      cust_site.interest_fixed_amount,
                      cust_site.interest_schedule_id,
                      cust_site.min_fc_invoice_overdue_type,
                      cust_site.min_fc_invoice_amount,
                      cust_site.min_fc_invoice_percent,
                      cust_site.multiple_interest_rates_flag,
                      cust_site.hold_charged_invoices_flag,
		      ps.org_id,
                      ps.cash_receipt_id,
                      cust_site.last_accrue_charge_date
                UNION ALL
                   select  ps.customer_id,
                      decode(ps.class,
                             'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                              ps.customer_site_use_id,
                                                                              ps.org_id),
                             'PMT',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                               ps.customer_site_use_id,
                                                                               ps.org_id),
                              ps.customer_site_use_id) customer_site_use_id,
                      ps.invoice_currency_code,
                      ps.customer_trx_id,
                      ps.payment_schedule_id,
                      ps.class ,
                      ps.amount_due_original,
                      ps.amount_due_remaining,
                      nvl(sum(app.amount_applied
                              + nvl(app.earned_discount_taken,0)
                              + nvl(app.unearned_discount_taken,0)),0) overdue_amt,
                      0 fin_charge_charged,
                      ps.trx_date,
                      ps.cust_trx_type_id,
                      ps.last_charge_date,
                      cust_site.exchange_rate,
                      cust_site.exchange_rate_type,
                      cust_site.min_interest_charge,
                      cust_site.max_interest_charge,
                      decode(ps.class,'PMT',ps.trx_date,ps.due_date) due_date,
                      l_fin_charge_date ,
                      cust_site.late_charge_type,
                      cust_site.late_charge_term_id    ,
                      cust_site.interest_period_days,
                      cust_site.interest_calculation_period,
                      cust_site.charge_on_finance_charge_flag,
                      cust_site.message_text_id,
                      ps.actual_date_closed,
                      cust_site.last_accrue_charge_date ,
                      cust_site.interest_type,
                      cust_site.interest_rate,
                      cust_site.interest_fixed_amount,
                      cust_site.interest_schedule_id,
                      cust_site.min_fc_invoice_overdue_type,
                      cust_site.min_fc_invoice_amount,
                      cust_site.min_fc_invoice_percent,
                      cust_site.multiple_interest_rates_flag,
                      cust_site.hold_charged_invoices_flag,
                      ps.org_id,
                      ps.cash_receipt_id,
                      'OVERDUE' charge_type
                   from  ar_payment_schedules ps,
                         ar_receivable_applications app,
			 ar_payment_schedules ps_cm_cr,
                         ar_lc_cust_sites_t cust_site,
                         ar_late_charge_cust_balance_gt bal
                  where  ps.customer_id = cust_site.customer_id
                   and   cust_site.customer_site_use_id = decode(ps.class,
                                                       'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                                               ps.customer_site_use_id,
                                                                                               ps.org_id),
                                                       'PMT',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                                              ps.customer_site_use_id,
                                                                                              ps.org_id),
                                                         ps.customer_site_use_id)
                   and   ps.invoice_currency_code = cust_site.currency_code
                   and   mod(nvl(cust_site.customer_site_use_id,0),l_total_workers) =
                                           decode(l_total_workers,l_worker_number,0,l_worker_number)
                   and   ps.org_id = cust_site.org_id
                   and   ps.actual_date_closed > l_fin_charge_date
                   and   cust_site.late_charge_calculation_trx in ('OVERDUE_LATE','OVERDUE')
                   and   cust_site.late_charge_type = 'INV'
                   /* Apply Customer Level tolerances */
                   and   cust_site.lc_cust_sites_id = bal.late_charge_cust_sites_id
                   and   cust_site.org_id = bal.org_id
                   and   decode(cust_site.min_fc_balance_overdue_type,
                         'PERCENT',(nvl(cust_site.min_fc_balance_percent,0)
                                    * nvl(bal.customer_open_balance,0)/100),
                         'AMOUNT',nvl(cust_site.min_fc_balance_amount,0),
                            0) <= nvl(bal.customer_overdue_balance,0)
                   and   decode(nvl(cust_site.disputed_transactions_flag,'N'),
                                'N',decode(nvl(ps.amount_in_dispute,0),
                                           0, 'Y','N'),
                                'Y' ) = 'Y'
                   and   decode(cust_site.credit_items_flag,'N',
                            decode (ps.class, 'PMT','N','CM','N','INV',decode(sign(ps.amount_due_original),-1,'N','Y'),'Y'),'Y') = 'Y'
                   and   decode(ps.class,
                                'PMT', ps.trx_date,
                                ps.due_date) < decode(ps.class,
                                               'PMT', l_fin_charge_date,
                                               'CM', l_fin_charge_date,
                                               (l_fin_charge_date  - nvl(cust_site.payment_grace_days,0)))
                   and   nvl(ps.last_charge_date,l_fin_charge_date-1) < l_fin_charge_date
                   and   nvl(cust_site.charge_begin_date,decode(ps.class,'PMT',ps.trx_date,ps.due_date))
                                              <= decode(ps.class,'PMT',ps.trx_date,ps.due_date)
                   and   nvl(ps.receipt_confirmed_flag, 'Y') = 'Y'
                   and   app.applied_payment_schedule_id = ps.payment_schedule_id
                   and   app.status = 'APP'
                   and   nvl( app.confirmed_flag, 'Y' ) = 'Y'
                   /* The receipt or Credit Memo date has to be compared for application date */
                   and   ps_cm_cr.payment_schedule_id = app.payment_schedule_id
                   and   ps_cm_cr.trx_date > l_fin_charge_date
                group by ps.customer_id,
                      decode(ps.class,
                             'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                              ps.customer_site_use_id,
                                                                              ps.org_id),
                             'PMT',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                               ps.customer_site_use_id,
                                                                               ps.org_id),
                              ps.customer_site_use_id),
                      ps.invoice_currency_code,
                      ps.customer_trx_id,
                      ps.payment_schedule_id,
                      ps.class ,
                      ps.amount_due_original,
                      ps.amount_due_remaining,
                      ps.trx_date,
                      ps.cust_trx_type_id,
                      ps.last_charge_date,
                      cust_site.exchange_rate,
                      cust_site.exchange_rate_type,
                      cust_site.min_interest_charge,
                      cust_site.max_interest_charge,
                      decode(ps.class,'PMT',ps.trx_date,ps.due_date),
                      l_fin_charge_date ,
                      cust_site.late_charge_type,
                      cust_site.late_charge_term_id,
                      cust_site.interest_period_days,
                      cust_site.interest_calculation_period,
                      cust_site.charge_on_finance_charge_flag,
                      cust_site.message_text_id,
                      ps.actual_date_closed ,
                      cust_site.interest_type,
                      cust_site.interest_rate,
                      cust_site.interest_fixed_amount,
                      cust_site.interest_schedule_id,
                      cust_site.min_fc_invoice_overdue_type,
                      cust_site.min_fc_invoice_amount,
                      cust_site.min_fc_invoice_percent,
                      cust_site.multiple_interest_rates_flag,
                      cust_site.hold_charged_invoices_flag,
                      ps.org_id,
                      ps.cash_receipt_id,
                      cust_site.last_accrue_charge_date
               UNION ALL
                   select  ps.customer_id,
                      ps.customer_site_use_id,
		      ps.invoice_currency_code,
                      ps.customer_trx_id,
                      ps.payment_schedule_id,
                      ps.class ,
                      ps.amount_due_original,
                      ps.amount_due_remaining,
                      nvl(sum( nvl(-1*app.amount_applied_from, -1*app.amount_applied)),0) overdue_amt,
                      0 fin_charge_charged,
                      ps.trx_date,
                      ps.cust_trx_type_id,
                      ps.last_charge_date,
                      cust_site.exchange_rate,
                      cust_site.exchange_rate_type,
                      cust_site.min_interest_charge,
                      cust_site.max_interest_charge,
                      ps.due_date  due_date,
                      l_fin_charge_date ,
                      cust_site.late_charge_type,
                      cust_site.late_charge_term_id    ,
                      cust_site.interest_period_days,
                      cust_site.interest_calculation_period,
                      cust_site.charge_on_finance_charge_flag,
                      cust_site.message_text_id,
                      ps.actual_date_closed,
                      cust_site.last_accrue_charge_date ,
                      cust_site.interest_type,
                      cust_site.interest_rate,
                      cust_site.interest_fixed_amount,
                      cust_site.interest_schedule_id,
                      cust_site.min_fc_invoice_overdue_type,
                      cust_site.min_fc_invoice_amount,
                      cust_site.min_fc_invoice_percent,
                      cust_site.multiple_interest_rates_flag,
                      cust_site.hold_charged_invoices_flag,
                      ps.org_id,
                      ps.cash_receipt_id,
                      'OVERDUE' charge_type
                   from  ar_payment_schedules ps,
                         ar_receivable_applications app,
                         ar_lc_cust_sites_t cust_site,
                         ar_late_charge_cust_balance_gt bal
                  where  ps.customer_id = cust_site.customer_id
                   and   cust_site.customer_site_use_id =  ps.customer_site_use_id
                   and   ps.invoice_currency_code = cust_site.currency_code
                   and   mod(nvl(cust_site.customer_site_use_id,0),l_total_workers) =
                                           decode(l_total_workers,l_worker_number,0,l_worker_number)
                   and   ps.org_id = cust_site.org_id
                   and   ps.actual_date_closed > l_fin_charge_date
		   and   ps.class = 'CM'
                   and   cust_site.late_charge_calculation_trx in ('OVERDUE_LATE','OVERDUE')
                   and   cust_site.late_charge_type = 'INV'
                   /* Apply Customer Level tolerances */
                   and   cust_site.lc_cust_sites_id = bal.late_charge_cust_sites_id
                   and   cust_site.org_id = bal.org_id
                   and   decode(cust_site.min_fc_balance_overdue_type,
                         'PERCENT',(nvl(cust_site.min_fc_balance_percent,0)
                                    * nvl(bal.customer_open_balance,0)/100),
                         'AMOUNT',nvl(cust_site.min_fc_balance_amount,0),
                            0) <= nvl(bal.customer_overdue_balance,0)
                   and   decode(nvl(cust_site.disputed_transactions_flag,'N'),
                                'N',decode(nvl(ps.amount_in_dispute,0),
                                           0, 'Y','N'),
                                'Y' ) = 'Y'
                   and   decode(cust_site.credit_items_flag,'N',
                            decode (ps.class, 'PMT','N','CM','N','INV',decode(sign(ps.amount_due_original),-1,'N','Y'),'Y'),'Y') = 'Y'
                   and    ps.due_date < decode(ps.class,
                                               'PMT', l_fin_charge_date,
                                               'CM', l_fin_charge_date,
                                               (l_fin_charge_date  - nvl(cust_site.payment_grace_days,0)))
                   and   nvl(ps.last_charge_date,l_fin_charge_date-1) < l_fin_charge_date
                   and   nvl(cust_site.charge_begin_date,decode(ps.class,'PMT',ps.trx_date,ps.due_date))
                                              <= decode(ps.class,'PMT',ps.trx_date,ps.due_date)
                   and   nvl(ps.receipt_confirmed_flag, 'Y') = 'Y'
                   and   app.payment_schedule_id = ps.payment_schedule_id
                   and   app.status = 'APP'
                   and   app.application_type = 'CM'
                   and   nvl( app.confirmed_flag, 'Y' ) = 'Y'
                   and   app.apply_date > l_fin_charge_date
                group by ps.customer_id,
                      ps.customer_site_use_id,
                      ps.invoice_currency_code,
                      ps.customer_trx_id,
                      ps.payment_schedule_id,
                      ps.class ,
                      ps.amount_due_original,
                      ps.amount_due_remaining,
                      ps.trx_date,
                      ps.cust_trx_type_id,
                      ps.last_charge_date,
                      cust_site.exchange_rate,
                      cust_site.exchange_rate_type,
                      cust_site.min_interest_charge,
                      cust_site.max_interest_charge,
                      ps.due_date,
                      l_fin_charge_date ,
                      cust_site.late_charge_type,
                      cust_site.late_charge_term_id,
                      cust_site.interest_period_days,
                      cust_site.interest_calculation_period,
                      cust_site.charge_on_finance_charge_flag,
                      cust_site.message_text_id,
                      ps.actual_date_closed ,
                      cust_site.interest_type,
                      cust_site.interest_rate,
                      cust_site.interest_fixed_amount,
                      cust_site.interest_schedule_id,
                      cust_site.min_fc_invoice_overdue_type,
                      cust_site.min_fc_invoice_amount,
                      cust_site.min_fc_invoice_percent,
                      cust_site.multiple_interest_rates_flag,
                      cust_site.hold_charged_invoices_flag,
                      ps.org_id,
                      ps.cash_receipt_id,
                      cust_site.last_accrue_charge_date
                UNION ALL
                   select ps.customer_id,
                      decode(ps.class,
                             'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                              ps.customer_site_use_id,
									      ps.org_id),
                             'PMT',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                               ps.customer_site_use_id,
									       ps.org_id),
                              ps.customer_site_use_id) customer_site_use_id,
                      ps.invoice_currency_code,
                      ps.customer_trx_id,
                      ps.payment_schedule_id,
                      ps.class ,
                      ps.amount_due_original,
                      ps.amount_due_remaining,
                      ps.amount_due_remaining overdue_amt,
                      0 fin_charge_charged,
                      ps.trx_date,
                      ps.cust_trx_type_id,
                      ps.last_charge_date,
                      cust_site.exchange_rate,
                      cust_site.exchange_rate_type,
                      cust_site.min_interest_charge,
                      cust_site.max_interest_charge,
                      decode(ps.class,'PMT',ps.trx_date,ps.due_date)due_date,
                      l_fin_charge_date ,
                      cust_site.late_charge_type,
                      cust_site.late_charge_term_id    ,
                      cust_site.interest_period_days,
                      cust_site.interest_calculation_period,
                      cust_site.charge_on_finance_charge_flag,
                      cust_site.message_text_id,
                      ps.actual_date_closed,
                      cust_site.last_accrue_charge_date ,
                      cust_site.interest_type,
                      cust_site.interest_rate,
                      cust_site.interest_fixed_amount,
                      cust_site.interest_schedule_id,
                      cust_site.min_fc_invoice_overdue_type,
                      cust_site.min_fc_invoice_amount,
                      cust_site.min_fc_invoice_percent,
                      cust_site.multiple_interest_rates_flag,
                      cust_site.hold_charged_invoices_flag,
                      ps.org_id,
		      ps.cash_receipt_id,
                      'OVERDUE' charge_type
                   from  ar_payment_schedules ps,
                         ar_lc_cust_sites_t cust_site,
                         ar_late_charge_cust_balance_gt bal
                   where ps.customer_id = cust_site.customer_id
                   and   cust_site.customer_site_use_id = decode(ps.class,
                                                      'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                                             ps.customer_site_use_id,
											     ps.org_id),
                                                      'PMT',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                                             ps.customer_site_use_id,
											     ps.org_id),
                                                         ps.customer_site_use_id)
                   and   ps.invoice_currency_code = cust_site.currency_code
                   and   mod(nvl(cust_site.customer_site_use_id,0),l_total_workers) =
                                          decode(l_total_workers,l_worker_number,0,l_worker_number)
		   and   ps.org_id = cust_site.org_id
                   and   ps.actual_date_closed > l_fin_charge_date
                   and   cust_site.late_charge_calculation_trx in ('OVERDUE_LATE','OVERDUE')
                   and   cust_site.late_charge_type = 'INV'
                   /* Apply Customer Level tolerances */
                   and   cust_site.lc_cust_sites_id = bal.late_charge_cust_sites_id
		   and   cust_site.org_id = bal.org_id
                   and   decode(cust_site.min_fc_balance_overdue_type,
                         'PERCENT',(nvl(cust_site.min_fc_balance_percent,0)
                                    * nvl(bal.customer_open_balance,0)/100),
                         'AMOUNT',nvl(cust_site.min_fc_balance_amount,0),
                            0) <= nvl(bal.customer_overdue_balance,0)
                   and   decode(nvl(cust_site.disputed_transactions_flag,'N'),
                                'N',decode(nvl(ps.amount_in_dispute,0),
                                           0, 'Y','N'),
                                'Y' ) = 'Y'
                   and   decode(cust_site.credit_items_flag,'N',
                            decode (ps.class, 'PMT','N','CM','N','INV',decode(sign(ps.amount_due_original),-1,'N','Y'),'Y'),'Y') = 'Y'  /*8559863*/
                   and   decode(ps.class,
                                'PMT', ps.trx_date,
                                ps.due_date) < decode(ps.class,
                                               'PMT', l_fin_charge_date,
                                               'CM', l_fin_charge_date,
                                               (l_fin_charge_date  - nvl(cust_site.payment_grace_days,0)))
                   and   nvl(ps.last_charge_date,l_fin_charge_date-1) < l_fin_charge_date
                   and   nvl(cust_site.charge_begin_date,decode(ps.class,'PMT',ps.trx_date,ps.due_date))
						 <= decode(ps.class,'PMT',ps.trx_date,ps.due_date)
                   and   decode(ps.class,
                                'PMT',ps.trx_date,
                                'CM',ps.trx_date,ps.due_date) <= l_fin_charge_date
                   and   nvl(ps.receipt_confirmed_flag, 'Y') = 'Y') a,
                         ra_customer_trx  trx,
                         ra_cust_trx_types types,
                         ar_transaction_history th,
			 ar_cash_receipts cr
                   where trx.customer_trx_id(+) = a.customer_trx_id
                   and   nvl(trx.finance_charges,decode(a.class,'DEP','N','Y')) = 'Y'
                   and   a.customer_trx_id = th.customer_trx_id(+)
                   and   nvl(th.current_record_flag,'Y') = 'Y'
                   and   nvl(th.status,'*') not in ('PROTESTED','MATURED_PEND_RISK_ELIMINATION','CLOSED', 'CANCELLED')
                   and   types.cust_trx_type_id(+) = a.cust_trx_type_id
		   and	 types.org_id(+) = a.org_id
                   and   nvl(types.exclude_from_late_charges,'N') <> 'Y'
                   and   cr.cash_receipt_id(+) = a.cash_receipt_id
                   and   decode(a.hold_charged_invoices_flag,
                               'Y',decode(a.last_charge_date,
                                          NULL,a.fin_charge_charged,1),
                                0) = 0
                  group by a.customer_id,
                           a.customer_site_use_id ,
                           a.invoice_currency_code,
                           nvl(a.customer_trx_id,a.cash_receipt_id),
                           nvl(trx.legal_entity_id,cr.legal_entity_id),
                           a.payment_schedule_id,
                           a.class ,
                           a.amount_due_original,
                           a.amount_due_remaining ,
                           a.trx_date,
                           a.cust_trx_type_id,
                           a.last_charge_date,
                           a.last_accrue_charge_date,
                           a.exchange_rate_type,
                           a.min_interest_charge,
                           a.max_interest_charge,
                           a.due_date,
                           a.fin_charge_date,
                           a.charge_type,
                           a.actual_date_closed,
                           a.late_charge_type,
                           a.late_charge_term_id,
                           a.interest_period_days,
                           a.interest_calculation_period,
                           a.charge_on_finance_charge_flag,
                           a.message_text_id,
                           a.interest_type,
                           a.interest_rate,
                           a.interest_schedule_id,
                           a.min_fc_invoice_overdue_type,
                           a.min_fc_invoice_amount,
                           a.min_fc_invoice_percent,
                           a.multiple_interest_rates_flag,
                           a.hold_charged_invoices_flag,
			   a.org_id,
                           a.interest_fixed_amount,
                           decode(a.interest_calculation_period,
                                  'DAILY',l_fin_charge_date,
                                  'MONTHLY',last_day(l_fin_charge_date)),
                           decode(a.interest_calculation_period,
                                  'DAILY',nvl(a.last_charge_date,
                                              decode(a.fin_charge_charged,
                                                     0,a.due_date,
                                                     a.last_accrue_charge_date)),
                                  'MONTHLY',first_day(nvl(a.last_charge_date,
                                                          decode(a.fin_charge_charged,
                                                                 0,a.due_date,
                                                                 a.last_accrue_charge_date)))),
                           decode(a.interest_calculation_period,
                                  'DAILY',a.due_date,
                                  'MONTHLY',first_day(a.due_date)))b,
                         ar_charge_schedule_hdrs sched_hdrs,
                         ar_charge_schedule_lines  sched_lines,
                         ar_aging_bucket_lines bucket_lines
                where b.interest_schedule_id = sched_hdrs.schedule_id(+)
                and   sched_hdrs.schedule_header_id = sched_lines.schedule_header_id(+)
                and   sched_hdrs.schedule_id = sched_lines.schedule_id(+)
                and    nvl(sched_hdrs.status,'A') = 'A'
                and   sched_lines.aging_bucket_id = bucket_lines.aging_bucket_id(+)
                and   sched_lines.aging_bucket_line_id = bucket_lines.aging_bucket_line_id(+)
                /* Condition 1: days late should be between the bucket lines start and end days */
                and   (l_fin_charge_date- b.due_date) >= nvl(bucket_lines.days_start,(l_fin_charge_date- b.due_date))
                and   (l_fin_charge_date - b.due_date) <= nvl(bucket_lines.days_to,(l_fin_charge_date- b.due_date))
                /* Condition 2:
                   Start_date of the schedule should be less than or equal to the finance charge date */
                and   nvl(sched_hdrs.start_date,l_fin_charge_date) <= l_fin_charge_date
               /* condition 3:
                  If multiple interest rates have to be used, end date of the schedule should be greater than
                  or equal to the due date or the date from which we are calculating the charge
                  Otherwise, the end_date should either be null or it should be greater than the
                  due_date
                */
                and  (decode(b.multiple_interest_rates_flag,'Y',
                             decode(sched_hdrs.schedule_header_type,
                                    'RATE',greatest(b.due_date,nvl(b.last_charge_date,b.due_date)),
                                    b.due_date),
                             b.due_date) <= sched_hdrs.end_date
                       OR sched_hdrs.end_date IS NULL )
                /* Condition 4: If multiple rates need not be used, we should pick up the rate
                   that is effective on the due_date of the transaction.
                   Also note that the multiple interest rates are used only for Interest
                   Calculation and only when rates are used*/
                and decode(b.multiple_interest_rates_flag,'Y',
                       decode(sched_hdrs.schedule_header_type,
                               'RATE',sched_hdrs.start_date,
                               b.due_date),
                       b.due_date )>= nvl(sched_hdrs.start_date,b.due_date)
                /* Make sure that this payment schedule is not part of a failed final batch */
                and not exists (select payment_schedule_id
                                from   ar_interest_lines lines,
                                       ar_interest_headers hdrs,
				       ar_interest_batches bat
				where  lines.payment_schedule_id = b.payment_schedule_id
				and    lines.interest_header_id = hdrs.interest_header_id
                                and    hdrs.interest_batch_id = bat.interest_batch_id
                                and    bat.batch_status ='F'
                                and    bat.transferred_status <> 'S'));



       IF l_debug_flag = 'Y' THEN
             debug( 'ar_calc_late_charge.insert_int_overdue_inv()-' );
       END IF;
    --
 EXCEPTION
        WHEN  OTHERS THEN
             --IF l_debug_flag = 'Y' THEN
                  debug('EXCEPTION : '||SQLCODE||' : '||SQLERRM);
                  debug('EXCEPTION: ar_calc_late_charge.insert_int_overdue_inv' );
             --END IF;
             RAISE;

END insert_int_overdue_inv;
/*=========================================================================================+
 | PROCEDURE insert_int_late_pay                                                           |
 |                                                                                         |
 | DESCRIPTION                                                                             |
 |                                                                                         |
 |   This procedure finds out the late payments on any debit item. By late payment, we     |
 |   mean the applications done on it after the due_date / last finance charge date .      |
 |   Interest Amount is  then calculated on the overdue balance and inserted into          |
 |   ar_late_charge_trx_t                                                                  |
 |                                                                                         |
 | PSEUDO CODE/LOGIC                                                                       |
 |                                                                                         |
 | a) The Receipt Date is used for finding out the late applications on a debit item. So,  |
 |    if an application is Reversed, that need not be considered as the application and    |
 |    it's reversal  will cancel out each other on that receipt date.                      |
 | b) The finance charge that is already charged on this invoice is fetched from           |
 |    ar_adjustments                                                                       |
 | c) Open Credit Items are not considered as we are tracking only the late applications   |
 |                                                                                         |
 | PARAMETERS                                                                              |
 |                                                                                         |
 |                                                                                         |
 | KNOWN ISSUES                                                                            |
 |                                                                                         |
 | NOTES                                                                                   |
 |                                                                                         |
 | MODIFICATION HISTORY                                                                    |
 | Date                  Author            Description of Changes                          |
 | 16-FEB-2006           rkader            Created                                         |
 | 11-JUL-2006           rkader            Bug 5290709 : Last charge date should not be    |
 |                                         considered for the calculation of the interest. |
 |                                         The late payment is always from the due date    |
 |                                         to the receipt date                             |
 |24-JUN-2008            naneja            Bug 7162382 : In above fix for bug 5290709      |
 |                                         Late charge was calculated in duplicate for     |
 |                                         late payment and overdue invoice case.          |
 |                                         Last run must have calculated interest for      |
 |                                         amount of                                       |
 |                                         late payment. Thus merge 5290709 fix of         |
 |                                         late payment only fix with this fix.            |
 |22-JUN-2009            naneja            Inserted data for new column cash_receipt_id    |
 |                                         Bug 8556955                                     |
 *=========================================================================================*/

PROCEDURE insert_int_late_pay(p_fin_charge_date		IN	DATE,
                              p_worker_number           IN      NUMBER,
                              p_total_workers           IN      NUMBER) IS

  l_fin_charge_date	DATE;
  l_worker_number       number;
  l_total_workers       number;

BEGIN
       IF l_debug_flag = 'Y' THEN
             debug( 'ar_calc_late_charge.insert_int_late_pay()+' );
       END IF;

       l_fin_charge_date 	    :=	    p_fin_charge_date;
       l_worker_number              :=      p_worker_number;
       l_total_workers              :=      p_total_workers;

/*=========================================================================================*
 | Sample Cases:                                                                           |
 | Case1:                                                                                  |
 |    Suppose that there is an invoice for 1000 USD, due on 01-JAN-2006.                   |
 |    1) There is a receipt application on this invoice on 20-Jan-2006, for 500 USD.       |
 |    2) Late Charge is computed on this Late Payment as on 31-Jan-2006, and let's say that|
 |       the calculated amount is 50 USD (500 USD paid late by 20 days) and we are creating|
 |       adjustments. So the balance of this invoice is 550 USD as on 31-Jan-2006.         |
 |    3) Consider the following cases of another application on this invoice and we have to|
 |       compute the finance charge as of 28-Feb-2006.                                     |
 |       Case  a) A receipt application for 550 USD on 10-Feb-2006                         |
 |       Case  b) A receipt application for 500 USD on 10-Feb-2006                         |
 |       Case  c) A receipt application for 600 USD on 10-Feb-2006                         |
 |                                                                                         |
 |     If we have to calculate Compound Interest, we will have the late paid amount (amount|
 |     on which interest is computed) as                                                   |
 |     Case  a) 550 USD Case  b) 500 USD  Case  c) 550 USD                                 |
 |                                                                                         |
 |     If Simple or Flat Rate has to be used, we should not charge interest on interest. So|
 |     the late paid amount should be computed subtracting upto the finance charge already |
 |     charged on this invoice. So the late paid amount will be                            |
 |     Case a) 500 USD Case  b) 500 USD  Case  c) 500 USD                                  |
 |                                                                                         |
 |     Note that the interest will NOT be calculated on the over applied amount.           |
 *=========================================================================================*/
/*Bug 8277068 Corrected interest days calclulation to pick least from eff_apply_date and charge schedule end date*/
       insert into ar_late_charge_trx_t
           (late_charge_trx_id,
            customer_id,
            customer_site_use_id,
            currency_code,
            customer_trx_id,
            legal_entity_id,
            payment_schedule_id,
            class,
            amount_due_original,
            amount_due_remaining,
            fin_charge_charged,
            trx_date,
            cust_trx_type_id,
            last_charge_date,
            --exchange_rate,
            exchange_rate_type,
            min_interest_charge,
            max_interest_charge,
            overdue_late_pay_amount,
            original_balance,
            due_date,
            receipt_date,
            finance_charge_date,
            charge_type,
            actual_date_closed,
            interest_rate,
            interest_days,
            rate_start_date,
            rate_end_date,
            schedule_days_start,
            schedule_days_to,
            late_charge_amount,
            late_charge_type,
            late_charge_term_id,
            interest_period_days,
            interest_calculation_period,
            charge_on_finance_charge_flag,
            message_text_id,
            interest_type,
            min_fc_invoice_overdue_type,
            min_fc_invoice_amount,
            min_fc_invoice_percent,
            charge_line_type,
	    org_id,
	    request_id,
            display_flag,
	    cash_receipt_id)
       (select ar_late_charge_trx_s.nextval,
               a.customer_id,
               a.customer_site_use_id ,
               a.invoice_currency_code,
               a.customer_trx_id,
               a.legal_entity_id,
               a.payment_schedule_id,
               a.class ,
               a.amount_due_original,
               a.amount_due_remaining,
               a.fin_charge_charged,
               a.trx_date,
               a.cust_trx_type_id,
               a.last_charge_date ,
               --exchange_rate,
               a.exchange_rate_type,
               a.min_interest_charge,
               a.max_interest_charge,
               decode(sign(a.late_pay_amount - a.original_balance),
                          -1, a.late_pay_amount,
                           0, a.late_pay_amount,
                           a.original_balance) overdue_late_pay_amount,
               a.original_balance,
               a.due_date,
               a.receipt_date,
               a.finance_charge_date,
               a.charge_type,
               a.actual_date_closed,
               decode(a.interest_type,
                         'CHARGES_SCHEDULE',sched_lines.rate,
                         'FIXED_RATE',a.interest_rate, NULL) interest_rate,
               least(decode(a.multiple_interest_rates_flag,
                           'Y',decode(sched_hdrs.schedule_header_type,
                                      'RATE', nvl(sched_hdrs.end_date,a.eff_apply_date),
                                       a.eff_apply_date),
                              a.eff_apply_date),a.eff_apply_date) -
                  greatest(decode(a.multiple_interest_rates_flag,
                                  'Y',decode(sched_hdrs.schedule_header_type,
                                            'RATE',sched_hdrs.start_date-1,a.eff_due_date),
                     a.eff_due_date), a.eff_due_date,decode(a.eff_charge_type,'OVERDUE_LATE',a.eff_last_charge_date,a.eff_due_date)) interest_days, /*Merge-Bug fix 5290709 for overdue and late case*/
              sched_hdrs.start_date rate_start_date,
              sched_hdrs.end_date rate_end_date ,
              bucket_lines.days_start schedule_days_start,
              bucket_lines.days_to  schedule_days_to,
              decode(a.interest_type,
                     'FIXED_AMOUNT',a.interest_fixed_amount,
                        decode(sched_hdrs.schedule_header_type,
                               'AMOUNT',sched_lines.amount,
                               ar_calc_late_charge.calculate_interest(
                                                      decode(sign(a.late_pay_amount - a.original_balance),
                                                             -1,a.late_pay_amount,
                                                              0,a.late_pay_amount,
                                                              a.original_balance),
                                                      a.charge_on_finance_charge_flag,
                                                      least(decode(a.multiple_interest_rates_flag,
                                                                  'Y',decode(sched_hdrs.schedule_header_type,
                                                                     'RATE', nvl(sched_hdrs.end_date,a.eff_apply_date),
                                                                                a.eff_apply_date),
                                                                   a.eff_apply_date),a.eff_apply_date) -
                                                          greatest(decode(a.multiple_interest_rates_flag,
                                                                     'Y',decode(sched_hdrs.schedule_header_type,
                                                                       'RATE',sched_hdrs.start_date-1,a.eff_due_date),
                     a.eff_due_date), a.eff_due_date,decode(a.eff_charge_type,'OVERDUE_LATE',a.eff_last_charge_date,a.eff_due_date)),/* Merge fix  7162382 for overdue and late case -Bug fix 5290709 */
                                                      decode(a.interest_type,
                                                            'CHARGES_SCHEDULE',sched_lines.rate,
                                                            'FIXED_RATE',a.interest_rate, NULL),
                                                             a.interest_period_days,
                                                      a.invoice_currency_code,
						      a.payment_schedule_id))) late_charge_amount,
              a.late_charge_type,
              a.late_charge_term_id,
              a.interest_period_days,
              a.interest_calculation_period,
              a.charge_on_finance_charge_flag,
              a.message_text_id,
              a.interest_type,
              a.min_fc_invoice_overdue_type,
              a.min_fc_invoice_amount,
              a.min_fc_invoice_percent,
              'INTEREST',
	      a.org_id,
	      l_request_id,
              'Y',
	      a.cash_receipt_id
     from
     (
      select  ps.customer_id,
              decode(ps.class,
                     'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                      ps.customer_site_use_id,
								      ps.org_id),
                      ps.customer_site_use_id) customer_site_use_id ,
              ps.invoice_currency_code,
              ps.customer_trx_id,
              cr.legal_entity_id,
              ps.payment_schedule_id,
              ps.class ,
              ps.amount_due_original,
              ps.amount_due_remaining,
              nvl(adj.fin_charge_charged,0) fin_charge_charged,
              ps.trx_date,
              ps.cust_trx_type_id,
              nvl(ps.last_charge_date,
                       decode(nvl(adj.fin_charge_charged,0),0,NULL,
                                   cust_site.last_accrue_charge_date)) last_charge_date ,
              cust_site.exchange_rate_type,
              cust_site.min_interest_charge,
              cust_site.max_interest_charge,
              sum(app.amount_applied + nvl(app.earned_discount_taken,0) +
                                   nvl(app.unearned_discount_taken,0)) late_pay_amount,
              ar_calc_late_charge.get_balance_as_of(ps.payment_schedule_id,
                                                    cr.receipt_date-1,
                                                    ps.class,
                                                    cust_site.charge_on_finance_charge_flag) original_balance,
              ps.due_date,
              cr.receipt_date,
              l_fin_charge_date finance_charge_date,
              cust_site.late_charge_type,
              ps.actual_date_closed,
              cust_site.late_charge_term_id,
              cust_site.interest_period_days,
              cust_site.interest_calculation_period,
              cust_site.charge_on_finance_charge_flag,
              cust_site.message_text_id,
              cust_site.last_accrue_charge_date,
              cust_site.interest_type,
              cust_site.interest_rate,
              cust_site.interest_fixed_amount,
              cust_site.interest_schedule_id interest_schedule_id,
              cust_site.min_fc_invoice_overdue_type,
              cust_site.min_fc_invoice_amount,
              cust_site.min_fc_invoice_percent,
              cust_site.multiple_interest_rates_flag,
              cust_site.hold_charged_invoices_flag,
	      ps.org_id,
              decode(cust_site.interest_calculation_period,
                     'DAILY',cr.receipt_date,
                     'MONTHLY',last_day(cr.receipt_date)) eff_apply_date,
              decode(cust_site.interest_calculation_period,
                     'DAILY',nvl(ps.last_charge_date,
                                     decode(nvl(adj.fin_charge_charged,0),0,ps.due_date,
                                           nvl(cust_site.last_accrue_charge_date,ps.due_date))),
                     'MONTHLY',first_day(nvl(ps.last_charge_date,
                       decode(nvl(adj.fin_charge_charged,0),0,ps.due_date,
                                   nvl(cust_site.last_accrue_charge_date,ps.due_date))))) eff_last_charge_date,
              decode(cust_site.interest_calculation_period,
                     'DAILY',ps.due_date,
                     'MONTHLY',first_day(ps.due_date)) eff_due_date,
              'LATE' charge_type,
	      cust_site.late_charge_calculation_trx eff_charge_type,
	      cr.cash_receipt_id
         from  ar_payment_schedules ps,
               ar_lc_cust_sites_t cust_site,
               ar_late_charge_cust_balance_gt bal,
               ar_receivable_applications app,
               ar_cash_receipts cr,
               ra_cust_trx_types types,
               ra_customer_trx trx,
               ar_transaction_history th,
               (select ps.payment_schedule_id ,sum(adj.amount) fin_charge_charged
                 from ar_payment_schedules ps,
                      ar_adjustments adj,
                      ar_lc_cust_sites_t cust_site
                where ps.customer_id = cust_site.customer_id
                and   decode(cust_site.customer_site_use_id,'','X', ps.customer_site_use_id)
                        = decode(cust_site.customer_site_use_id,'','X', cust_site.customer_site_use_id)
                and   ps.invoice_currency_code = cust_site.currency_code
                and   mod(nvl(cust_site.customer_site_use_id,0),l_total_workers) =
                                          decode(l_total_workers,l_worker_number,0,l_worker_number)
                and   ps.org_id = cust_site.org_id
                and   cust_site.late_charge_calculation_trx in ('OVERDUE_LATE','LATE')
                and   decode(cust_site.disputed_transactions_flag,'N',
                         decode(nvl(ps.amount_in_dispute,0), 0, 'Y','N'),'Y' ) = 'Y'
                and   ps.class not in ('CM','PMT')
                and   adj.payment_schedule_id = ps.payment_schedule_id
                and   adj.status = 'A'
                and   adj.apply_date <= l_fin_charge_date
                and   adj.type ='CHARGES'
                and   adj.adjustment_type = 'A'
                group by ps.payment_schedule_id) adj
        where  ps.customer_id = cust_site.customer_id
         and   cust_site.customer_site_use_id = decode(ps.class,
                                                       'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                                              ps.customer_site_use_id,
											      ps.org_id),
                                                       ps.customer_site_use_id)
         and   ps.invoice_currency_code = cust_site.currency_code
         and   mod(nvl(cust_site.customer_site_use_id,0),l_total_workers) =
                                          decode(l_total_workers,l_worker_number,0,l_worker_number)
	 and   ps.org_id = cust_site.org_id
         and   cust_site.late_charge_calculation_trx in ('OVERDUE_LATE','LATE')
         and   decode(nvl(cust_site.disputed_transactions_flag,'N'),
                          'N',decode(nvl(ps.amount_in_dispute,0),
                                      0, 'Y','N'),
                          'Y' ) = 'Y'
         /* Apply Customer Level tolerances */
         and   cust_site.lc_cust_sites_id = bal.late_charge_cust_sites_id
	 and   cust_site.org_id = bal.org_id
         and   decode(cust_site.min_fc_balance_overdue_type,
                      'PERCENT',(nvl(cust_site.min_fc_balance_percent,0)
                                * nvl(bal.customer_open_balance,0)/100),
                      'AMOUNT',nvl(cust_site.min_fc_balance_amount,0),
                            nvl(bal.customer_overdue_balance,0)) <= nvl(bal.customer_overdue_balance,0) /*Bug8464171*/
         and   app.applied_payment_schedule_id = ps.payment_schedule_id
         and   app.application_type = 'CASH'
         and   app.status = 'APP'
         and   app.reversal_gl_date IS NULL
         and   nvl(app.confirmed_flag, 'Y' ) = 'Y'
         and   cr.cash_receipt_id = app.cash_receipt_id
         and   ps.class not in ('CM','PMT')
         and   ps.due_date < (cr.receipt_date - nvl(cust_site.payment_grace_days,0))
         and   cr.receipt_date <= l_fin_charge_date
         and   cr.receipt_date > nvl(ps.last_charge_date,cr.receipt_date-1)
         and   adj.payment_schedule_id(+) = ps.payment_schedule_id
         and   decode(cust_site.hold_charged_invoices_flag,
                         'Y',decode(ps.last_charge_date,
                                    NULL,nvl(adj.fin_charge_charged,0),
                                    1),
                         0) = 0
         /* The Payments are not fetched. So there can be a hard join with cust_trx_types */
         and  types.cust_trx_type_id = ps.cust_trx_type_id
	 and  types.org_id = ps.org_id
         and  nvl(types.exclude_from_late_charges,'N') <> 'Y'
         and  trx.customer_trx_id(+) = ps.customer_trx_id
         and  nvl(trx.finance_charges,decode(ps.class,'DEP','N','Y')) = 'Y'
         and  th.customer_trx_id(+) = ps.customer_trx_id
	 and  nvl(th.current_record_flag,'Y') = 'Y'
         and  nvl(th.status,'*') not in ('PROTESTED','MATURED_PEND_RISK_ELIMINATION','CLOSED', 'CANCELLED')
  group by    ps.customer_id,
              decode(ps.class,
                     'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                      ps.customer_site_use_id,
								      ps.org_id),
                      ps.customer_site_use_id),
              ps.invoice_currency_code,
              ps.customer_trx_id,
              cr.legal_entity_id,
              ps.payment_schedule_id,
              ps.class ,
              ps.amount_due_original,
              ps.amount_due_remaining,
              nvl(adj.fin_charge_charged,0),
              ps.trx_date,
              ps.cust_trx_type_id,
              nvl(ps.last_charge_date,
                       decode(nvl(adj.fin_charge_charged,0),0,NULL,
                                   cust_site.last_accrue_charge_date)),
              cust_site.exchange_rate_type,
              cust_site.min_interest_charge,
              cust_site.max_interest_charge,
              ar_calc_late_charge.get_balance_as_of(ps.payment_schedule_id,
                                                    cr.receipt_date-1,
                                                    ps.class,
                                                    cust_site.charge_on_finance_charge_flag),
              ps.due_date,
              cr.receipt_date,
              l_fin_charge_date,
              cust_site.late_charge_type,
              ps.actual_date_closed,
              cust_site.late_charge_term_id,
              cust_site.interest_period_days,
              cust_site.interest_calculation_period,
              cust_site.charge_on_finance_charge_flag,
              cust_site.message_text_id,
              cust_site.last_accrue_charge_date,
              cust_site.interest_type,
              cust_site.interest_rate,
              cust_site.interest_fixed_amount,
              cust_site.interest_schedule_id,
              cust_site.min_fc_invoice_overdue_type,
              cust_site.min_fc_invoice_amount,
              cust_site.min_fc_invoice_percent,
              cust_site.multiple_interest_rates_flag,
              cust_site.hold_charged_invoices_flag,
	      ps.org_id,
              decode(cust_site.interest_calculation_period,
                     'DAILY',cr.receipt_date,
                     'MONTHLY',last_day(cr.receipt_date)),
              decode(cust_site.interest_calculation_period,
                     'DAILY',nvl(ps.last_charge_date,
                                     decode(nvl(adj.fin_charge_charged,0),0,ps.due_date,
                                           nvl(cust_site.last_accrue_charge_date,ps.due_date))),
                     'MONTHLY',first_day(nvl(ps.last_charge_date,
                       decode(nvl(adj.fin_charge_charged,0),0,ps.due_date,
                                   nvl(cust_site.last_accrue_charge_date,ps.due_date))))),
              decode(cust_site.interest_calculation_period,
                     'DAILY',ps.due_date,
                     'MONTHLY',first_day(ps.due_date)),
	      cust_site.late_charge_calculation_trx,
	      cr.cash_receipt_id) a,
                   ar_charge_schedule_hdrs sched_hdrs,
                   ar_charge_schedule_lines  sched_lines,
                   ar_aging_bucket_lines bucket_lines
          where   a.interest_schedule_id = sched_hdrs.schedule_id(+)
          and   sched_hdrs.schedule_header_id = sched_lines.schedule_header_id(+)
          and   sched_hdrs.schedule_id = sched_lines.schedule_id(+)
          and    nvl(sched_hdrs.status,'A') = 'A'
          and   sched_lines.aging_bucket_id = bucket_lines.aging_bucket_id(+)
          and   sched_lines.aging_bucket_line_id = bucket_lines.aging_bucket_line_id(+)
          /* Condition 1: days late should be between the bucket lines start and end days */
          and   (a.receipt_date- a.due_date) >= nvl(bucket_lines.days_start,(a.receipt_date- a.due_date))
          and   (a.receipt_date - a.due_date) <= nvl(bucket_lines.days_to,(a.receipt_date- a.due_date))
          /* Condition 2: Start_date of the schedule should be less than or equal to the
             finance charge date */
          and   nvl(sched_hdrs.start_date,a.receipt_date) <= a.receipt_date
          /* condition 3:
              If multiple interest rates have to be used, end date of the schedule should be greater than
              or equal to the due date or the date from which we are calculating the charge
              Otherwise, the end_date should either be null or it should be greater than the
              due_date to pick up the rate effective as of the due_date
              Bug 8343193 For multiple interest rate for late payment we need to consider schedules from due date
               */
           and  (decode(a.multiple_interest_rates_flag,'Y',
                        decode(sched_hdrs.schedule_header_type,
                               'RATE',greatest(a.due_date,decode(a.eff_charge_type,'LATE',a.due_date,nvl(a.last_charge_date,a.due_date))),
                                a.due_date),
                        a.due_date) <= sched_hdrs.end_date
                   OR sched_hdrs.end_date IS NULL )
          /* Condition 4: If multiple rates need not be used, we should pick up the rate
             that is effective on the due date.
             Also note that the multiple interest rates are used only for Interest
             Calculation and only when rates are used*/
           and decode(a.multiple_interest_rates_flag,'Y',
                       decode(sched_hdrs.schedule_header_type,
                               'RATE',sched_hdrs.start_date,
                               a.due_date),
                       a.due_date)>= nvl(sched_hdrs.start_date,a.due_date)
            /* Make sure that this payment schedule is not part of a failed final batch */
             and not exists (select payment_schedule_id
                             from   ar_interest_lines lines,
                                    ar_interest_headers hdrs,
                                    ar_interest_batches bat
                             where  lines.payment_schedule_id = a.payment_schedule_id
                             and    lines.interest_header_id = hdrs.interest_header_id
                             and    hdrs.interest_batch_id = bat.interest_batch_id
                             and    bat.batch_status ='F'
                             and    bat.transferred_status <> 'S'));

        IF l_debug_flag = 'Y' THEN
            debug( 'ar_calc_late_charge.insert_int_late_pay()-' );
        END IF;

    --
   EXCEPTION
     WHEN  OTHERS THEN
        --IF l_debug_flag = 'Y' THEN
            debug('EXCEPTION : '||SQLCODE||' : '||SQLERRM);
            debug('EXCEPTION: ar_calc_late_charge.insert_int_late_pay' );
        --END IF;
        RAISE;

END insert_int_late_pay;
/*=========================================================================================+
 | PROCEDURE insert_int_avg_daily_bal                                                      |
 |                                                                                         |
 | DESCRIPTION                                                                             |
 |                                                                                         |
 |   This procedure computes the average daily balance of the debit items and calculates   |
 |   Interest on this average daily balance and inserts the records into                   |
 |   ar_late_charge_trx_t                                                                  |
 |                                                                                         |
 | PSEUDO CODE/LOGIC                                                                       |
 |                                                                                         |
 |                                                                                         |
 | PARAMETERS                                                                              |
 |                                                                                         |
 |                                                                                         |
 | KNOWN ISSUES                                                                            |
 |                                                                                         |
 | NOTES                                                                                   |
 |                                                                                         |
 | 1. Average Daily Balance method involves three steps                                    |
 |    a) Determinition                                                                     |
 |       For determining if a customer, site and currency combination is to be charged, the|
 |       balance of the last bill is taken and the credit items upto the due_date plus     |
 |       receipt grace days is subtracted from this. If this balance is atleast the min    |
 |       customer balance threshold, charge will be calculated.                            |
 |    b) Charge computation                                                                |
 |       Based on the set up in post_billing_debit_items and late_charge_billing_calc_mode,|
 |       (in ar_system_parameters), different items and date range will be used to         |
 |       calculate the average daily balance                                               |
 |    c) Generation of the document in AR.                                                 |
 | 2. The following fields are not used for Average Daily Balance                          |
 |    a) credit_items_flag                                                                 |
 |    b) disputed_transaction_flag                                                         |
 |    c) multiple_interest_rates_flag                                                      |
 |    d) interest days per period                                                          |
 |    e) interest calculation period                                                       |
 |    f) hold_charged_invoices_flag                                                        |
 |    g) minimum invoice overdue + value                                                   |
 | 3. The following fields have different validation for Average Daily Balance             |
 |    a) Late charge type - Interest Invoices only                                         |
 |    b) Interest Calculation Formula - Flat only                                          |
 |    c) Interest Charge and Penalty Charge - can not be Charges Schedule                  |
 |                                                                                         |
 | MODIFICATION HISTORY                                                                    |
 | Date                  Author            Description of Changes                          |
 |                                                                                         |
 | 05-APR-2006           rkader            Created                                         |
 |                                                                                         |
 *=========================================================================================*/
PROCEDURE insert_int_avg_daily_bal(p_fin_charge_date	IN	DATE,
                                   p_worker_number      IN      NUMBER,
                                   p_total_workers      IN      NUMBER) IS

   l_fin_charge_date	         DATE;
   l_worker_number               number;
   l_total_workers               number;

BEGIN

    IF l_debug_flag = 'Y' THEN
         debug( 'ar_calc_late_charge. insert_int_avg_daily_bal()+' );
    END IF;

    l_fin_charge_date   := 	p_fin_charge_date;
    l_worker_number     :=      p_worker_number;
    l_total_workers     :=      p_total_workers;

   /* Insert records for the system option set up RUN DATE TO RUN DATE */

   insert into ar_late_charge_trx_t
      (late_charge_trx_id,
       customer_id,
       customer_site_use_id,
       currency_code,
       customer_trx_id,
       legal_entity_id,
       payment_schedule_id,
       class,
       amount_due_original,
       amount_due_remaining,
       fin_charge_charged,
       trx_date,
       cust_trx_type_id,
       last_charge_date,
       exchange_rate_type,
       min_interest_charge,
       max_interest_charge,
       overdue_late_pay_amount,
       original_balance,
       due_date,
       receipt_date,
       finance_charge_date,
       charge_type,
       actual_date_closed,
       interest_rate,
       interest_days,
       rate_start_date,
       rate_end_date,
       schedule_days_start,
       schedule_days_to,
       late_charge_amount,
       late_charge_type,
       late_charge_term_id,
       interest_period_days,
       interest_calculation_period,
       charge_on_finance_charge_flag,
       message_text_id,
       interest_type,
       min_fc_invoice_overdue_type,
       min_fc_invoice_amount,
       min_fc_invoice_percent,
       charge_line_type,
       org_id,
       request_id,
       display_flag )
   ( select ar_late_charge_trx_s.nextval,
          b.customer_id,
          b.site_use_id,
          b.currency_code,
          NULL, -- customer_trx_id
          NULL, -- How to determine this?
          -99, -- payment_schedule_id
          NULL, -- class, search for some look up for cons_inv
          NULL, -- amount_due_original
          NULL, -- amount_due_remaining
          NULL, -- fin_charge_already_charged
          NULL, -- trx_date
          NULL, --cust_trx_type is not applicable
          b.last_accrue_charge_date,
          b.exchange_rate_type,
          b.min_interest_charge,
          b.max_interest_charge,
          b.overdue_late_pay_amount,
          b.overdue_late_pay_amount, -- original balance
          NULL, --Due date not applicable
          NULL, --receipt_date
          l_fin_charge_date,
          'AVERAGE_DAILY_BALANCE',
          NULL,
          b.interest_rate,
          b.interest_days,
          NULL, -- rate start_date,
          NULL, -- rate end date
          NULL, -- bucket days start
          NULL, -- bucket days end
          b.late_charge_amount,
          'INV',
          b.late_charge_term_id,
          NULL, -- interest_period_days not applicable
          NULL, -- interest_calculation_period not applicable
          'F' , -- only flat rate is applicable
          b.message_text_id,
          b.interest_type,
          NULL, -- invoice level tolerances are not applicable (min_fc_invoice_overdue_type)
          NULL, -- min_fc_invoice_amount
          NULL, -- min_fc_invoice_percent
          'INTEREST',
          b.org_id,
          l_request_id,
          'Y'
  from
    (
    select
           a.customer_id,
           a.site_use_id,
           a.currency_code,
           a.last_accrue_charge_date,
           a.exchange_rate_type,
           a.min_interest_charge,
           a.max_interest_charge,
           ar_calc_late_charge.currency_round(sum(a.balance * (a.date_to - a.date_from+1))
                                               / sum(a.date_to - a.date_from+1),
                                                   a.currency_code) overdue_late_pay_amount,
           decode(a.interest_type,
                  'FIXED_RATE',a.interest_rate, NULL) interest_rate,
           sum(a.date_to - a.date_from+1) interest_days,
           decode(a.interest_type,
                  'FIXED_AMOUNT', a.interest_fixed_amount,
                  'FIXED_RATE',
                    ar_calc_late_charge.currency_round(nvl(
                                                           ((sum(a.balance * (a.date_to - a.date_from+1))/
                                                             sum(a.date_to - a.date_from+1))/100
                                                                *a.interest_rate
                                                           ),
                                                          0), a.currency_code)) late_charge_amount,
           a.late_charge_term_id,
           a.message_text_id,
           a.interest_type,
           a.org_id,
           a.payment_grace_days,
           a.min_fc_balance_overdue_type,
           a.min_fc_balance_amount,
           a.min_fc_balance_percent
  from
  (
    select cons_inv.customer_id,
           cons_inv.site_use_id,
           cons_inv.currency_code,
           cons_inv.org_id,
           cons_inv.billing_date date_from,
           decode(sign(l_fin_charge_date -
               	   ar_calc_late_charge.get_next_activity_date(cons_inv.customer_id,
       					       	      cons_inv.site_use_id,
       						      cons_inv.currency_code,
       						      cons_inv.org_id,
						      sysparam.post_billing_item_inclusion,
						      cons_inv.billing_date,
        	                                      l_fin_charge_date)),
                  -1,l_fin_charge_date,
                   ar_calc_late_charge.get_next_activity_date(cons_inv.customer_id,
                                                      cons_inv.site_use_id,
                                                      cons_inv.currency_code,
                                                      cons_inv.org_id,
                                                      sysparam.post_billing_item_inclusion,
                                                      cons_inv.billing_date,
                                                      l_fin_charge_date)) date_to,
          cons_inv.ending_balance balance,
          cust_sites.last_accrue_charge_date,
          cust_sites.exchange_rate_type,
          cust_sites.min_interest_charge,
          cust_sites.max_interest_charge,
	  cust_sites.interest_type,
	  cust_sites.interest_rate,
	  cust_sites.interest_fixed_amount,
          cust_sites.interest_schedule_id,
	  cust_sites.late_charge_term_id,
	  cust_sites.message_text_id,
          cust_sites.payment_grace_days,
          cust_sites.min_fc_balance_overdue_type,
          cust_sites.min_fc_balance_amount,
          cust_sites.min_fc_balance_percent
    from  ar_cons_inv cons_inv,
          ar_lc_cust_sites_t cust_sites,
	  ar_system_parameters sysparam
   where cons_inv.customer_id = cust_sites.customer_id
   and   cons_inv.site_use_id = cust_sites.customer_site_use_id
   and   cons_inv.currency_code = cust_sites.currency_code
   and   mod(nvl(cust_sites.customer_site_use_id,0),l_total_workers) =
                     decode(l_total_workers,l_worker_number,0,l_worker_number)
   and   cons_inv.org_id = cust_sites.org_id
   and   cons_inv.billing_date = (select max(ci2.billing_date)
   	                          from   ar_cons_inv ci2
                	          where  ci2.customer_id = cust_sites.customer_id
                        	  and    ci2.site_use_id   = cust_sites.customer_site_use_id
                                  and    ci2.currency_code = cust_sites.currency_code
                                  and    ci2.org_id = cust_sites.org_id
	                          and    ci2.billing_date  <= l_fin_charge_date
        	                  and    ci2.status  in ('FINAL', 'ACCEPTED','IMPORTED'))
   and   cust_sites.late_charge_calculation_trx = 'AVG_DAILY_BALANCE'
   and   sysparam.org_id = cons_inv.org_id
   and    sysparam.late_charge_billing_calc_mode = 'RUN_TO_RUN_DATE'
   union
  select  cust_site.customer_id,
          cust_site.customer_site_use_id,
          cust_site.currency_code,
          cust_site.org_id,
          decode(cust_site.last_accrue_charge_date,
    	         NULL, ar_calc_late_charge.get_first_activity_date(cust_site.customer_id,
      		  						   cust_site.customer_site_use_id,
								   cust_site.currency_code,
								   cust_site.org_id),
                 cust_site.last_accrue_charge_date+1) date_from,
          decode(sign(l_fin_charge_date -
             	  ar_calc_late_charge.get_next_activity_date(cust_site.customer_id,
      						     cust_site.customer_site_use_id,
						     cust_site.currency_code,
						     cust_site.org_id,
						     sysparam.post_billing_item_inclusion,
						     decode(cust_site.last_accrue_charge_date,
               	                                            NULL,get_first_activity_date(cust_site.customer_id,
      								                         cust_site.customer_site_use_id,
								 			 cust_site.currency_code,
								 			 cust_site.org_id),
                                                            cust_site.last_accrue_charge_date+1),
	                                              l_fin_charge_date)),
                 -1, l_fin_charge_date,
                  ar_calc_late_charge.get_next_activity_date(cust_site.customer_id,
                                                     cust_site.customer_site_use_id,
                                                     cust_site.currency_code,
                                                     cust_site.org_id,
                                                     sysparam.post_billing_item_inclusion,
                                                     decode(cust_site.last_accrue_charge_date,
                                                            NULL,get_first_activity_date(cust_site.customer_id,
                                                                                         cust_site.customer_site_use_id,                                                                                         cust_site.currency_code,
                                                                                         cust_site.org_id),
                                                            cust_site.last_accrue_charge_date+1),
                                                      l_fin_charge_date)) date_to,
     	 ar_calc_late_charge.get_cust_balance(cust_site.customer_id,
      		                              cust_site.customer_site_use_id,
					      cust_site.currency_code,
					      cust_site.org_id,
					      sysparam.post_billing_item_inclusion,
					      decode(cust_site.last_accrue_charge_date,
               				 	     NULL,get_first_activity_date(cust_site.customer_id,
      						 		 	 	  cust_site.customer_site_use_id,
									 	  cust_site.currency_code,
									 	  cust_site.org_id),
                                              cust_site.last_accrue_charge_date+1)) balance,
         cust_site.last_accrue_charge_date,
         cust_site.exchange_rate_type,
         cust_site.min_interest_charge,
         cust_site.max_interest_charge,
         cust_site.interest_type,
	 cust_site.interest_rate,
	 cust_site.interest_fixed_amount,
         cust_site.interest_schedule_id,
	 cust_site.late_charge_term_id,
	 cust_site.message_text_id,
         cust_site.payment_grace_days,
         cust_site.min_fc_balance_overdue_type,
         cust_site.min_fc_balance_amount,
         cust_site.min_fc_balance_percent
   from  ar_lc_cust_sites_t cust_site,
         ar_system_parameters sysparam
   where sysparam.org_id = cust_site.org_id
   and   sysparam.late_charge_billing_calc_mode = 'RUN_TO_RUN_DATE'
   and   cust_site.late_charge_calculation_trx = 'AVG_DAILY_BALANCE'
   and   mod(nvl(cust_site.customer_site_use_id,0),l_total_workers) =
       	              decode(l_total_workers,l_worker_number,0,l_worker_number)
  union
  /* select distinct : even if more than one item exists with the same trx_date,
      consider this date only once */
  select cust_sites.customer_id,
         cust_sites.customer_site_use_id,
         cust_sites.currency_code,
         cust_sites.org_id,
         ps.trx_date,
         decode(sign(l_fin_charge_date -
        	      ar_calc_late_charge.get_next_activity_date(ps.customer_id,
        					    ps.customer_site_use_id,
       						    ps.invoice_currency_code,
       						    ps.org_id,
						    sysparam.post_billing_item_inclusion,
						    ps.trx_date,
	                                            l_fin_charge_date)),
                 -1, l_fin_charge_date,
                 ar_calc_late_charge.get_next_activity_date(ps.customer_id,
                                                    ps.customer_site_use_id,
                                                    ps.invoice_currency_code,
                                                    ps.org_id,
                                                    sysparam.post_billing_item_inclusion,
                                                    ps.trx_date,
                                                    l_fin_charge_date)) date_to,
      	ar_calc_late_charge.get_cust_balance(ps.customer_id,
       			    		     ps.customer_site_use_id,
        				     ps.invoice_currency_code,
        				     ps.org_id,
					     sysparam.post_billing_item_inclusion,
					     ps.trx_date) balance,
        cust_sites.last_accrue_charge_date,
        cust_sites.exchange_rate_type,
        cust_sites.min_interest_charge,
        cust_sites.max_interest_charge,
        cust_sites.interest_type,
	cust_sites.interest_rate,
	cust_sites.interest_fixed_amount,
        cust_sites.interest_schedule_id,
        cust_sites.late_charge_term_id,
        cust_sites.message_text_id,
        cust_sites.payment_grace_days,
        cust_sites.min_fc_balance_overdue_type,
        cust_sites.min_fc_balance_amount,
        cust_sites.min_fc_balance_percent
    from  ar_payment_schedules ps,
          ar_lc_cust_sites_t cust_sites,
          ar_system_parameters sysparam
   where  ps.customer_id = cust_sites.customer_id
   and    decode(ps.class,
	        'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
	                                                         ps.customer_site_use_id,
	       	                                                 ps.org_id),
	        'PMT',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
	                                                          ps.customer_site_use_id,
	                                                          ps.org_id),
        	ps.customer_site_use_id) = cust_sites.customer_site_use_id
   and    ps.invoice_currency_code = cust_sites.currency_code
   and    ps.org_id = cust_sites.org_id
   and    cust_sites.late_charge_calculation_trx = 'AVG_DAILY_BALANCE'
   and   mod(nvl(cust_sites.customer_site_use_id,0),l_total_workers) =
                       decode(l_total_workers,l_worker_number,0,l_worker_number)
   and    sysparam.org_id = cust_sites.org_id
   and    sysparam.late_charge_billing_calc_mode = 'RUN_TO_RUN_DATE'
   and    decode(sysparam.post_billing_item_inclusion,
                'INCLUDE_DEBIT_ITEM','Y',
                'EXCLUDE_DEBIT_ITEM',decode(ps.class,
                                           'PMT','Y',
                                           'CM','Y',
                                           'N'),
	               'N')  = 'Y'
   and   ps.trx_date <= l_fin_charge_date
   and   ( ps.trx_date > (select max(ci2.billing_date)
                          from   ar_cons_inv ci2
                          where  ci2.customer_id = cust_sites.customer_id
                          and    ci2.site_use_id   = cust_sites.customer_site_use_id
                          and    ci2.currency_code = cust_sites.currency_code
                          and    ci2.org_id = cust_sites.org_id
                          and    ci2.billing_date  < l_fin_charge_date
                          and    ci2.status  in ('FINAL', 'ACCEPTED','IMPORTED'))
       	OR       (
        not exists (select ci2.billing_date
    	            from   ar_cons_inv ci2
	            where  ci2.customer_id = cust_sites.customer_id
	            and    ci2.site_use_id   = cust_sites.customer_site_use_id
		    and    ci2.currency_code = cust_sites.currency_code
		    and    ci2.org_id = cust_sites.org_id
		    and    ci2.billing_date  < ps.trx_date
		    and    ci2.status  in ('FINAL', 'ACCEPTED','IMPORTED'))
        and ps.trx_date >= decode(cust_sites.last_accrue_charge_date,
                                  NULL,get_first_activity_date(cust_sites.customer_id,
        	 	   	                               cust_sites.customer_site_use_id,
							       cust_sites.currency_code,
							       cust_sites.org_id),
                                              cust_sites.last_accrue_charge_date+1)))) a
   where nvl(a.balance,0) <> 0
  group by a.customer_id,
           a.site_use_id,
           a.currency_code,
           a.org_id,
           a.last_accrue_charge_date,
           a.exchange_rate_type,
           a.min_interest_charge,
           a.max_interest_charge,
	   a.interest_type,
	   a.interest_rate,
	   a.interest_fixed_amount,
           a.interest_schedule_id,
	   a.late_charge_term_id,
	   a.message_text_id,
           a.payment_grace_days,
           a.min_fc_balance_overdue_type,
           a.min_fc_balance_amount,
           a.min_fc_balance_percent)b
    /* Apply the customer level tolerance - check for eligibility */
    where ar_calc_late_charge.check_adb_eligibility(b.customer_id,
                                                b.site_use_id,
                                                b.currency_code,
                                                b.org_id,
                                                b.payment_grace_days,
                                                b.min_fc_balance_overdue_type,
                                                b.min_fc_balance_amount,
                                                b.min_fc_balance_percent,
                                                l_fin_charge_date) = 'Y');

   /* Insert records for the system option set up DUE DATE TO RUN DATE */

   insert into ar_late_charge_trx_t
      (late_charge_trx_id,
       customer_id,
       customer_site_use_id,
       currency_code,
       customer_trx_id,
       legal_entity_id,
       payment_schedule_id,
       class,
       amount_due_original,
       amount_due_remaining,
       fin_charge_charged,
       trx_date,
       cust_trx_type_id,
       last_charge_date,
       exchange_rate_type,
       min_interest_charge,
       max_interest_charge,
       overdue_late_pay_amount,
       original_balance,
       due_date,
       receipt_date,
       finance_charge_date,
       charge_type,
       actual_date_closed,
       interest_rate,
       interest_days,
       rate_start_date,
       rate_end_date,
       schedule_days_start,
       schedule_days_to,
       late_charge_amount,
       late_charge_type,
       late_charge_term_id,
       interest_period_days,
       interest_calculation_period,
       charge_on_finance_charge_flag,
       message_text_id,
       interest_type,
       min_fc_invoice_overdue_type,
       min_fc_invoice_amount,
       min_fc_invoice_percent,
       charge_line_type,
       org_id,
       request_id,
       display_flag)
    (
    select ar_late_charge_trx_s.nextval,
           b.customer_id,
           b.site_use_id,
           b.currency_code,
           NULL, -- customer_trx_id
           NULL, -- How to determine this?
           -99, -- payment_schedule_id
           NULL, -- class, search for some look up for cons_inv
           NULL, -- amount_due_original
           NULL, -- amount_due_remaining
           NULL, -- fin_charge_already_charged
           NULL, -- trx_date
           NULL, --cust_trx_type is not applicable
           b.last_accrue_charge_date,
           b.exchange_rate_type,
           b.min_interest_charge,
           b.max_interest_charge,
           b.overdue_late_pay_amount,
           b.overdue_late_pay_amount original_balance,
           NULL, --Due date not applicable
           NULL, --receipt_date
           l_fin_charge_date,
           'AVERAGE_DAILY_BALANCE',
           NULL,
           decode(b.interest_type,
                  'FIXED_RATE',b.interest_rate, NULL) interest_rate,
           b.tot_days interest_days,
           NULL, -- rate start date
           NULL, -- rate end date
           NULL, -- bucket days start
           NULL, -- bucket days to
           decode(b.interest_type,
                  'FIXED_AMOUNT', b.interest_fixed_amount,
                  'FIXED_RATE',
                         ar_calc_late_charge.currency_round(nvl(b.overdue_late_pay_amt_org /100* b.interest_rate,0),
                                                            b.currency_code)) late_charge_amount,
           'INV'  ,
           b.late_charge_term_id,
           NULL, -- interest_period_days not applicable
           NULL, -- interest_calculation_period not applicable
           'F' , -- only flat rate is applicable
           b.message_text_id,
           b.interest_type,
           NULL, -- invoice level tolerances are not applicable (min_fc_invoice_overdue_type)
           NULL, -- min_fc_invoice_amount
           NULL, -- min_fc_invoice_percent
           'INTEREST',
           b.org_id,
           l_request_id,
           'Y'
  from (
   select a.customer_id,
          a.site_use_id,
          a.currency_code,
          a.org_id,
          a.last_accrue_charge_date,
          a.exchange_rate_type,
          a.min_interest_charge,
          a.max_interest_charge,
          a.interest_type,
          a.interest_rate,
          a.interest_fixed_amount,
          a.interest_schedule_id,
          a.late_charge_term_id,
          a.message_text_id,
          a.payment_grace_days,
          a.min_fc_balance_overdue_type,
          a.min_fc_balance_amount,
          a.min_fc_balance_percent,
          ar_calc_late_charge.currency_round(sum(a.balance * (a.date_to - a.date_from+1)) /
                                             sum(a.date_to - a.date_from+1),
                                             a.currency_code) overdue_late_pay_amount,
          sum(a.balance * (a.date_to - a.date_from+1)) /
                                             sum(a.date_to - a.date_from+1) overdue_late_pay_amt_org,
          sum(a.balance * (a.date_to - a.date_from+1)) tot_amt,
          sum(a.date_to - a.date_from+1) tot_days
  from
  (
    select cons_inv.customer_id,
           cons_inv.site_use_id,
           cons_inv.currency_code,
           cons_inv.org_id,
           cons_inv.due_date+1 date_from,
           decode(sign(l_fin_charge_date-
                               ar_calc_late_charge.get_next_activity_date(cons_inv.customer_id,
                                                      cons_inv.site_use_id,
                                                      cons_inv.currency_code,
                                                      cons_inv.org_id,
                                                      sysparam.post_billing_item_inclusion,
                                                      cons_inv.due_date+1,
                                                      l_fin_charge_date)),
                   -1,l_fin_charge_date,
                   ar_calc_late_charge.get_next_activity_date(cons_inv.customer_id,
                                                      cons_inv.site_use_id,
                                                      cons_inv.currency_code,
                                                      cons_inv.org_id,
                                                      sysparam.post_billing_item_inclusion,
                                                      cons_inv.due_date+1,
                                                      l_fin_charge_date)) date_to,
          ar_calc_late_charge.get_cust_balance(cons_inv.customer_id,
       					    cons_inv.site_use_id,
       					    cons_inv.currency_code,
       					    cons_inv.org_id,
					    sysparam.post_billing_item_inclusion,
					    cons_inv.due_date) balance,
          cust_sites.last_accrue_charge_date,
          cust_sites.exchange_rate_type,
          cust_sites.min_interest_charge,
          cust_sites.max_interest_charge,
          cust_sites.interest_type,
          cust_sites.interest_rate,
          cust_sites.interest_fixed_amount,
          cust_sites.interest_schedule_id,
          cust_sites.late_charge_term_id,
          cust_sites.message_text_id,
          cust_sites.payment_grace_days,
          cust_sites.min_fc_balance_overdue_type,
          cust_sites.min_fc_balance_amount,
          cust_sites.min_fc_balance_percent
    from  ar_cons_inv cons_inv,
          ar_lc_cust_sites_t cust_sites,
          ar_system_parameters sysparam
   where cons_inv.customer_id = cust_sites.customer_id
   and   cons_inv.site_use_id = cust_sites.customer_site_use_id
   and   cons_inv.currency_code = cust_sites.currency_code
   and   mod(nvl(cust_sites.customer_site_use_id,0),l_total_workers) =
                     decode(l_total_workers,l_worker_number,0,l_worker_number)
   and   cons_inv.org_id = cust_sites.org_id
   and   cons_inv.billing_date = (select max(ci2.billing_date)
                                  from   ar_cons_inv ci2
                                  where  ci2.customer_id = cust_sites.customer_id
                                  and    ci2.site_use_id   = cust_sites.customer_site_use_id
                                  and    ci2.currency_code = cust_sites.currency_code
                                  and    ci2.org_id = cust_sites.org_id
                                  and    ci2.billing_date  <= l_fin_charge_date
                                  and    ci2.status  in ('FINAL', 'ACCEPTED','IMPORTED'))
   and   cust_sites.late_charge_calculation_trx = 'AVG_DAILY_BALANCE'
   and   sysparam.org_id = cons_inv.org_id
   and    sysparam.late_charge_billing_calc_mode = 'DUE_TO_RUN_DATE'
  union
  /* select distinct : even if more than one item exists with the same trx_date,
      consider this date only once */
  select cust_sites.customer_id,
         cust_sites.customer_site_use_id,
         cust_sites.currency_code,
         cust_sites.org_id,
         ps.trx_date,
         decode(sign(l_fin_charge_date -
                        ar_calc_late_charge.get_next_activity_date(ps.customer_id,
                                                    ps.customer_site_use_id,
                                                    ps.invoice_currency_code,
                                                    ps.org_id,
                                                    sysparam.post_billing_item_inclusion,
                                                    ps.trx_date,
                                                    l_fin_charge_date)),
                  -1, l_fin_charge_date,
                  ar_calc_late_charge.get_next_activity_date(ps.customer_id,
                                                    ps.customer_site_use_id,
                                                    ps.invoice_currency_code,
                                                    ps.org_id,
                                                    sysparam.post_billing_item_inclusion,
                                                    ps.trx_date,
                                                    l_fin_charge_date)) date_to,
        ar_calc_late_charge.get_cust_balance(ps.customer_id,
                                             ps.customer_site_use_id,
                                             ps.invoice_currency_code,
                                             ps.org_id,
                                             sysparam.post_billing_item_inclusion,
                                             ps.trx_date) balance,
        cust_sites.last_accrue_charge_date,
        cust_sites.exchange_rate_type,
        cust_sites.min_interest_charge,
        cust_sites.max_interest_charge,
        cust_sites.interest_type,
        cust_sites.interest_rate,
        cust_sites.interest_fixed_amount,
        cust_sites.interest_schedule_id,
        cust_sites.late_charge_term_id,
        cust_sites.message_text_id,
        cust_sites.payment_grace_days,
        cust_sites.min_fc_balance_overdue_type,
        cust_sites.min_fc_balance_amount,
        cust_sites.min_fc_balance_percent
    from  ar_payment_schedules ps,
          ar_lc_cust_sites_t cust_sites,
          ar_system_parameters sysparam
   where  ps.customer_id = cust_sites.customer_id
   and    decode(ps.class,
                'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                 ps.customer_site_use_id,
                                                                 ps.org_id),
                'PMT',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                  ps.customer_site_use_id,
                                                                  ps.org_id),
                ps.customer_site_use_id) = cust_sites.customer_site_use_id
   and    ps.invoice_currency_code = cust_sites.currency_code
   and    ps.org_id = cust_sites.org_id
   and    cust_sites.late_charge_calculation_trx = 'AVG_DAILY_BALANCE'
   and   mod(nvl(cust_sites.customer_site_use_id,0),l_total_workers) =
                       decode(l_total_workers,l_worker_number,0,l_worker_number)
   and    sysparam.org_id = cust_sites.org_id
   and    sysparam.late_charge_billing_calc_mode = 'DUE_TO_RUN_DATE'
   and    decode(sysparam.post_billing_item_inclusion,
                'INCLUDE_DEBIT_ITEM','Y',
                'EXCLUDE_DEBIT_ITEM',decode(ps.class,
                                           'PMT','Y',
                                           'CM','Y',
                                           'N'),
                       'N')  = 'Y'
   and   ps.trx_date <= l_fin_charge_date
   and   ps.trx_date > (select max(ci2.due_date)
                          from   ar_cons_inv ci2
                          where  ci2.customer_id = cust_sites.customer_id
                          and    ci2.site_use_id   = cust_sites.customer_site_use_id
                          and    ci2.currency_code = cust_sites.currency_code
                          and    ci2.org_id = cust_sites.org_id
                          and    ci2.billing_date  < l_fin_charge_date
                          and    ci2.status  in ('FINAL', 'ACCEPTED','IMPORTED')))a
   where nvl(a.balance,0) <> 0
  /* Apply the customer level tolerance - check for eligibility */
  and ar_calc_late_charge.check_adb_eligibility(a.customer_id,
                                                a.site_use_id,
                                                a.currency_code,
                                                a.org_id,
                                                a.payment_grace_days,
                                                a.min_fc_balance_overdue_type,
                                                a.min_fc_balance_amount,
                                                a.min_fc_balance_percent,
                                                l_fin_charge_date) = 'Y'
  group by a.customer_id,
           a.site_use_id,
           a.currency_code,
           a.org_id,
           a.last_accrue_charge_date,
           a.exchange_rate_type,
           a.min_interest_charge,
           a.max_interest_charge,
           a.interest_type,
           a.interest_rate,
           a.interest_fixed_amount,
           a.interest_schedule_id,
           a.late_charge_term_id,
           a.message_text_id,
           a.payment_grace_days,
           a.min_fc_balance_overdue_type,
           a.min_fc_balance_amount,
           a.min_fc_balance_percent) b
      /* Make sure that this customer, site and currency combination is not
         part of a failed final batch */
      where not exists (select 'exists failed batch'
                      from   ar_interest_headers hdr,
                             ar_interest_batches bat
                      where  hdr.customer_id = b.customer_id
                      and    hdr.customer_site_use_id = b.site_use_id
                      and    hdr.currency_code = b.currency_code
                      and    hdr.interest_batch_id = bat.interest_batch_id
                      and    bat.batch_status ='F'
                      and    bat.transferred_status <> 'S'));

      IF l_debug_flag = 'Y' THEN
          debug( 'ar_calc_late_charge. insert_int_avg_daily_bal()-' );
      END IF;
    --
   EXCEPTION
      WHEN  OTHERS THEN
          --IF l_debug_flag = 'Y' THEN
              debug('EXCEPTION : '||SQLCODE||' : '||SQLERRM);
              debug('EXCEPTION: ar_calc_late_charge. insert_int_avg_daily_bal' );
          --END IF;
          RAISE;

END insert_int_avg_daily_bal;

PROCEDURE insert_cust_balances(p_as_of_date	IN 	DATE,
			       p_worker_number  IN      NUMBER,
                               p_total_workers  IN      NUMBER) IS
BEGIN
      IF l_debug_flag = 'Y' THEN
          debug( 'ar_calc_late_charge.insert_cust_balances()+');
      END IF;
          INSERT INTO ar_late_charge_cust_balance_gt
                (late_charge_cust_sites_id,
                 customer_id,
                 customer_site_use_id,
                 currency_code,
                 customer_open_balance,
                 customer_overdue_balance,
                 org_id)
          (SELECT a.lc_cust_sites_id,
                 a.customer_id,
                 a.customer_site_use_id,
                 a.currency_code,
                 sum(open_bal) open_balance,
                 sum(overdue_bal) overdue_balance,
                 org_id
          FROM
             (SELECT cust_site.lc_cust_sites_id,
                     ps.customer_id,
                     cust_site.customer_site_use_id,
                     ps.invoice_currency_code currency_code,
                     sum(ps.amount_due_remaining) open_bal,
                     sum((case when ps.due_date < p_as_of_date then 1 else 0 end)
                          * ps.amount_due_remaining) overdue_bal,
                     ps.org_id
               FROM  ar_payment_schedules ps,
                     ar_lc_cust_sites_t cust_site
               WHERE ps.customer_id = cust_site.customer_id
               AND   cust_site.customer_site_use_id = decode(ps.class,
                                                       'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                                              ps.customer_site_use_id,
											      ps.org_id),
                                                       ps.customer_site_use_id)
               AND   ps.invoice_currency_code = cust_site.currency_code
               AND   mod(nvl(cust_site.customer_site_use_id,0),p_total_workers) =
                                          decode(p_total_workers,p_worker_number,0,p_worker_number)
               AND   ps.org_id = cust_site.org_id
               AND   ps.payment_schedule_id+0 > 0
               AND   ps.actual_date_closed  >= p_as_of_date
               AND   ps.class IN ('CB', 'CM','DEP','DM','GUAR','INV','BR')
               AND   ps.trx_date  <= p_as_of_date
               GROUP BY cust_site.lc_cust_sites_id,
                      ps.customer_id,
                      cust_site.customer_site_use_id,
                      ps.invoice_currency_code,
                      ps.org_id
               UNION ALL
               SELECT cust_site.lc_cust_sites_id,
                      ps.customer_id,
                      cust_site.customer_site_use_id,
                      ps.invoice_currency_code currency_code,
                     sum(ra.amount_applied  + NVL(ra.earned_discount_taken,0)
                              + NVL(ra.unearned_discount_taken,0))open_bal,
                     sum((case when ps.due_date < p_as_of_date then 1 else 0 end)
                            * (ra.amount_applied  + NVL(ra.earned_discount_taken,0)
                              + NVL(ra.unearned_discount_taken,0))) overdue_bal,
                     ps.org_id
               FROM  ar_payment_schedules ps,
                     ar_receivable_applications ra,
                     ar_payment_schedules ps_cm_cr,
                     ar_lc_cust_sites_t cust_site
               WHERE ps.customer_id = cust_site.customer_id
               AND   cust_site.customer_site_use_id = decode(ps.class,
                                                       'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                                              ps.customer_site_use_id,
											      ps.org_id),
                                                         ps.customer_site_use_id)
               AND   ps.invoice_currency_code = cust_site.currency_code
               AND   mod(nvl(cust_site.customer_site_use_id,0),p_total_workers) =
                                          decode(p_total_workers,p_worker_number,0,p_worker_number)
               AND   ps.org_id = cust_site.org_id
               AND   ra.applied_payment_schedule_id = ps.payment_schedule_id
               AND   ps.actual_date_closed  >= p_as_of_date
               AND   ps.class IN ('CB', 'CM','DEP','DM','GUAR','INV','BR')
               AND   ra.status = 'APP'
               AND   ps.trx_date <= p_as_of_date
               AND   NVL(ra.confirmed_flag,'Y') = 'Y'
               AND   ps_cm_cr.payment_schedule_id = ra.payment_schedule_id
               AND   ps_cm_cr.trx_date > p_as_of_date
               GROUP BY cust_site.lc_cust_sites_id,
                      ps.customer_id,
                      cust_site.customer_site_use_id,
                      ps.invoice_currency_code,
                      ps.org_id
               UNION ALL
               SELECT cust_site.lc_cust_sites_id,
                      ps.customer_id,
                      cust_site.customer_site_use_id,
                      ps.invoice_currency_code currency_code,
                     sum(-1*(ra.amount_applied  + NVL(ra.earned_discount_taken,0)
                              + NVL(ra.unearned_discount_taken,0))) open_bal,
                     sum (-1*(case when ps.due_date < p_as_of_date then 1 else 0 end)
                           *(ra.amount_applied  + NVL(ra.earned_discount_taken,0)
                              + NVL(ra.unearned_discount_taken,0))) overdue_bal,
                     ps.org_id
               FROM  ar_payment_schedules ps,
                     ar_receivable_applications ra,
                     ar_lc_cust_sites_t cust_site
               WHERE ps.customer_id = cust_site.customer_id
               AND   cust_site.customer_site_use_id = decode(ps.class,
                                                        'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                                              ps.customer_site_use_id,
											      ps.org_id),
                                                         ps.customer_site_use_id)
               AND   ps.invoice_currency_code = cust_site.currency_code
               AND   mod(nvl(cust_site.customer_site_use_id,0),p_total_workers) =
                                          decode(p_total_workers,p_worker_number,0,p_worker_number)
               AND   ps.org_id = cust_site.org_id
               AND   ra.payment_schedule_id = ps.payment_schedule_id
               AND   ps.payment_schedule_id+0 > 0
               AND   ps.actual_date_closed  >= p_as_of_date
               AND   ps.class  = 'CM'
               AND   ra.apply_date > p_as_of_date
               AND   ra.status = 'APP'
               AND   ra.application_type = 'CM'
               AND   ps.trx_date <= p_as_of_date
               AND   NVL(ra.confirmed_flag,'Y') = 'Y'
               GROUP BY cust_site.lc_cust_sites_id,
                      ps.customer_id,
                      cust_site.customer_site_use_id,
                      ps.invoice_currency_code,
	 	      ps.org_id
               UNION ALL
               SELECT cust_site.lc_cust_sites_id,
                      ps.customer_id,
                      cust_site.customer_site_use_id,
                      ps.invoice_currency_code currency_code,
                      sum(-1 *adj.amount) open_bal,
                      sum(-1*(case when ps.due_date < p_as_of_date then 1 else 0 end)
                           *(adj.amount)) overdue_bal,
                      ps.org_id
               FROM  ar_adjustments adj ,
                     ar_payment_schedules ps,
                     ar_lc_cust_sites_t cust_site
               WHERE ps.customer_id = cust_site.customer_id
               AND   cust_site.customer_site_use_id = decode(ps.class,
                                                        'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                                              ps.customer_site_use_id,
											      ps.org_id),
                                                         ps.customer_site_use_id)
               AND   mod(nvl(cust_site.customer_site_use_id,0),p_total_workers) =
                                          decode(p_total_workers,p_worker_number,0,p_worker_number)
               AND   ps.org_id = cust_site.org_id
               AND   ps.payment_schedule_id + 0 > 0
               AND   ps.actual_date_closed  >= p_as_of_date
               AND   ps.class IN ('CB', 'CM','DEP','DM','GUAR','INV','BR')
               AND   ps.trx_date  <= p_as_of_date
               AND   adj.payment_schedule_id = ps.payment_schedule_id
               AND   adj.apply_date > p_as_of_date
               AND   adj.status = 'A'
               GROUP BY cust_site.lc_cust_sites_id,
                      ps.customer_id,
                      cust_site.customer_site_use_id,
                      ps.invoice_currency_code,
		      ps.org_id
               UNION ALL
               /* Unapplied Receipts
                  For receipts, consider the trx_date instead of the due_date*/
               SELECT cust_site.lc_cust_sites_id,
                      ps.customer_id,
                      cust_site.customer_site_use_id,
                      ps.invoice_currency_code currency_code,
                      sum(ps.amount_due_remaining) open_bal,
                      sum(ps.amount_due_remaining) overdue_bal,
                      ps.org_id
               FROM  ar_payment_schedules ps,
                     ar_lc_cust_sites_t cust_site
               WHERE ps.customer_id = cust_site.customer_id
               AND   cust_site.customer_site_use_id = ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                                                ps.customer_site_use_id,
												ps.org_id)
               AND   ps.invoice_currency_code = cust_site.currency_code
               AND   mod(nvl(cust_site.customer_site_use_id,0),p_total_workers) =
                                          decode(p_total_workers,p_worker_number,0,p_worker_number)
	       AND   ps.org_id = cust_site.org_id
               AND   ps.class = 'PMT'
               AND   ps.actual_date_closed >= p_as_of_date
               AND   nvl( ps.receipt_confirmed_flag, 'Y' ) = 'Y'
               AND   ps.trx_date  <= p_as_of_date
               GROUP BY cust_site.lc_cust_sites_id,
                      ps.customer_id,
                      cust_site.customer_site_use_id,
                      ps.invoice_currency_code,
                      ps.org_id
               UNION ALL
               /* Cancelled BR */
               SELECT cust_site.lc_cust_sites_id,
                      ps.customer_id,
                      cust_site.customer_site_use_id,
                      ps.invoice_currency_code currency_code,
                      sum(decode(nvl(ard.amount_cr,0), 0, nvl(ard.amount_dr,0),
                                           (ard.amount_cr * -1)))open_bal,
                      sum((case when ps.trx_date < p_as_of_date then 1 else 0 end)
                                 *(decode(nvl(ard.amount_cr,0), 0, nvl(ard.amount_dr,0),
                                     (ard.amount_cr * -1)))) overdue_bal,
                      ps.org_id
                 FROM ar_payment_schedules ps,
                      ar_distributions ard,
                      ar_transaction_history ath,
                      ra_customer_trx_lines lines,
                     ar_lc_cust_sites_t cust_site
               WHERE ps.customer_id = cust_site.customer_id
               AND   cust_site.customer_site_use_id = decode(ps.class,
                                                         'BR',ar_calc_late_charge.get_bill_to_site_use_id(ps.customer_id,
                                                                                              ps.customer_site_use_id,
											      ps.org_id),
                                                         ps.customer_site_use_id)
               AND   ps.invoice_currency_code = cust_site.currency_code
               AND   mod(nvl(cust_site.customer_site_use_id,0),p_total_workers) =
                                          decode(p_total_workers,p_worker_number,0,p_worker_number)
               AND   ps.org_id = cust_site.org_id
               AND   ps.payment_schedule_id+0 > 0
               AND   ps.actual_date_closed  >= p_as_of_date
               AND   ps.class IN ( 'BR','CB', 'CM','DEP','DM','GUAR','INV')
               AND   ath.trx_date > p_as_of_date
               AND   ath.event = 'CANCELLED'
               AND   ps.trx_date <= p_as_of_date
               AND   ps.customer_trx_id = ath.customer_trx_id
               AND   ard.source_table = 'TH'
               AND   ard.source_id = ath.transaction_history_id
               AND   ps.customer_trx_id = lines.customer_trx_id
               AND   ard.source_id_secondary = lines.customer_trx_line_id
               GROUP BY cust_site.lc_cust_sites_id,
                      ps.customer_id,
                      cust_site.customer_site_use_id,
                      ps.invoice_currency_code,
                      ps.org_id) a
        GROUP BY a.lc_cust_sites_id,
                 a.customer_id,
                 a.customer_site_use_id,
                 a.currency_code,
                 a.org_id);

      IF l_debug_flag = 'Y' THEN
          debug( 'ar_calc_late_charge.insert_cust_balances()-');
      END IF;
   EXCEPTION
      WHEN  OTHERS THEN
          --IF l_debug_flag = 'Y' THEN
              debug('EXCEPTION : '||SQLCODE||' : '||SQLERRM);
              debug('EXCEPTION: ar_calc_late_charge.insert_cust_balances' );
          --END IF;
          RAISE;

END insert_cust_balances;


/*=========================================================================================+
 | PROCEDURE insert_penalty_lines                                                          |
 |                                                                                         |
 | DESCRIPTION                                                                             |
 |                                                                                         |
 |   This procedure calculates the penalty against a payment schedule by adding the        |
 |   all the interest charged against it. The penalty is either a fixed amount or a        |
 |   percentage of the interest charge. The calculated Penalty is inserted back into       |
 |   ar_late_charge_trx_t                                                                  |
 |                                                                                         |
 | PSEUDO CODE/LOGIC                                                                       |
 |                                                                                         |
 |                                                                                         |
 | PARAMETERS                                                                              |
 |                                                                                         |
 |                                                                                         |
 | KNOWN ISSUES                                                                            |
 |                                                                                         |
 | NOTES                                                                                   |
 |                                                                                         |
 |  Since we are storing the balance as of the receipt date in the Original balance column |
 |  in ar_late_charge_trx_t (in the case of LATE payments) , this column is not inserted   |
 |  for  PENALTY lines. The receipt_date is also inserted as NULL as there can be multiple |
 |  receipts against one payment schedule, but only one penalty line                       |
 |                                                                                         |
 | MODIFICATION HISTORY                                                                    |
 | Date                  Author            Description of Changes                          |
 |                                                                                         |
 | 20-FEB-2006           rkader            Created                                         |
 |                                                                                         |
 *=========================================================================================*/
PROCEDURE insert_penalty_lines(p_worker_number             IN      NUMBER,
                               p_total_workers             IN      NUMBER) IS

BEGIN

      IF l_debug_flag = 'Y' THEN
         debug( 'ar_calc_late_charge.insert_penalty_lines()+' );
      END IF;

      insert into ar_late_charge_trx_t
           ( late_charge_trx_id,
             customer_id,
             customer_site_use_id,
             currency_code,
             customer_trx_id,
             legal_entity_id,
             payment_schedule_id,
             class,
             amount_due_original,
             amount_due_remaining,
             fin_charge_charged,
             trx_date,
             cust_trx_type_id,
             last_charge_date,
             exchange_rate_type,
             min_interest_charge,
             max_interest_charge,
             overdue_late_pay_amount,
             original_balance,
             due_date,
             receipt_date,
             finance_charge_date,
             charge_type,
             actual_date_closed,
             interest_rate,
             interest_days,
             rate_start_date,
             rate_end_date,
             schedule_days_start,
             schedule_days_to,
             late_charge_amount,
             late_charge_type,
             late_charge_term_id,
             interest_period_days,
             interest_calculation_period,
             charge_on_finance_charge_flag,
             message_text_id,
             interest_type,
             charge_line_type,
	     org_id,
	     request_id,
             display_flag)
     (select ar_late_charge_trx_s.nextval,
             a.customer_id,
             a.customer_site_use_id,
             a.currency_code,
             a.customer_trx_id,
             a.legal_entity_id,
             a.payment_schedule_id,
             a.class,
             a.amount_due_original,
             a.amount_due_remaining,
             a.fin_charge_charged,
             a.trx_date,
             a.cust_trx_type_id,
             a.last_charge_date,
             a.exchange_rate_type,
             a.min_interest_charge,
             a.max_interest_charge,
             a.interest,
             a.original_balance,
             a.due_date,
             a.receipt_date,
             a.finance_charge_date,
             decode(a.charge_type,
                    'AVERAGE_DAILY_BALANCE', a.charge_type,
                    'PENALTY') charge_type,
             a.actual_date_closed,
             a.penalty_rate,
             decode(a.charge_type,
                    'AVERAGE_DAILY_BALANCE',a.interest_days,
                    (a.finance_charge_date - nvl(a.last_charge_date, a.due_date))) interest_days,
             a.rate_start_date,
             a.rate_end_date,
             a.schedule_days_start,
             a.schedule_days_to,
             NVL(a.penalty_amount,ar_calc_late_charge.currency_round(nvl(a.penalty_rate,0) * a.interest/100,
                                                                    a.currency_code)),
             a.late_charge_type,
             a.late_charge_term_id,
             a.interest_period_days,
             a.interest_calculation_period,
             a.charge_on_finance_charge_flag,
             a.message_text_id,
             a.penalty_type,
             'PENALTY',
	     a.org_id,
	     l_request_id,
             'Y'
  from
     (select trx.customer_id,
             trx.customer_site_use_id,
             trx.currency_code,
             trx.customer_trx_id,
             trx.legal_entity_id,
             trx.payment_schedule_id,
             trx.class,
             trx.amount_due_original,
             trx.amount_due_remaining,
             trx.fin_charge_charged,
             trx.trx_date,
             trx.cust_trx_type_id,
             trx.last_charge_date,
             trx.exchange_rate_type,
             trx.min_interest_charge,
             trx.max_interest_charge,
             sum(trx.late_charge_amount) interest,
             NULL original_balance,
             trx.due_date,
             NULL receipt_date,
             trx.finance_charge_date,
             trx.actual_date_closed,
             decode(cust_site.penalty_type, 'CHARGES_SCHEDULE', sched_lines.rate,
                                             'FIXED_RATE', cust_site.penalty_rate,
                                              NULL) penalty_rate,
             sched_hdrs.start_date rate_start_date,
             sched_hdrs.end_date rate_end_date ,
             bucket_lines.days_start schedule_days_start,
             bucket_lines.days_to  schedule_days_to,
             decode(cust_site.penalty_type,
                      'FIXED_AMOUNT',decode(trx.class,
                                            'CM',-1 * cust_site.penalty_fixed_amount,
                                            'PMT', -1*cust_site.penalty_fixed_amount,
                                            cust_site.penalty_fixed_amount),
                      'CHARGES_SCHEDULE',decode(sched_hdrs.schedule_header_type,
                                                'AMOUNT',decode(trx.class,
                                                               'CM', -1*sched_lines.amount,
                                                               'PMT',-1*sched_lines.amount,
                                                               sched_lines.amount),
                                                NULL),
                      'CHARGE_PER_TIER',decode(sched_hdrs.schedule_header_type,
                                                'AMOUNT',decode(trx.class,
                                                               'CM', -1*sched_lines.amount,
                                                               'PMT',-1*sched_lines.amount,
                                                               sched_lines.amount),
                                                NULL),  /*Enhacement 6469663*/
                      NULL) penalty_amount,
             trx.late_charge_type,
             trx.late_charge_term_id,
             trx.interest_period_days,
             trx.interest_calculation_period,
             trx.charge_on_finance_charge_flag,
             trx.message_text_id,
	     trx.org_id,
             decode(trx.charge_type,'AVERAGE_DAILY_BALANCE',trx.interest_days,1) interest_days,
             decode(trx.charge_type,'AVERAGE_DAILY_BALANCE',trx.charge_type, NULL) charge_type,
             cust_site.penalty_type
     from    ar_lc_cust_sites_t cust_site,
             ar_late_charge_trx_t trx,
             ar_charge_schedule_hdrs sched_hdrs,
             ar_charge_schedule_lines sched_lines,
             ar_aging_bucket_lines bucket_lines
     where   cust_site.customer_id = trx.customer_id
      and    cust_site.customer_site_use_id = trx.customer_site_use_id
      and    cust_site.currency_code = trx.currency_code
      and    mod(nvl(cust_site.customer_site_use_id,0),p_total_workers) =
                                          decode(p_total_workers,p_worker_number,0,p_worker_number)
      and    cust_site.org_id = trx.org_id
      and    cust_site.penalty_schedule_id = sched_hdrs.schedule_id(+)
      and    sched_hdrs.schedule_header_id = sched_lines.schedule_header_id(+)
      and    sched_hdrs.schedule_id = sched_lines.schedule_id(+)
      and    nvl(sched_hdrs.status,'A') = 'A'
      and    sched_lines.aging_bucket_id = bucket_lines.aging_bucket_id(+)
      and    sched_lines.aging_bucket_line_id = bucket_lines.aging_bucket_line_id(+)
      /* Calculate the penalty only if the penalty type is defined for the customer */
      and    cust_site.penalty_type IS NOT NULL
      /* Condition 1: days late should be between the bucket lines start and end days
         For ADB, the interest_days should be used. */
      and    (( trx.charge_type = 'AVERAGE_DAILY_BALANCE'
               and trx.interest_days >= nvl(bucket_lines.days_start,trx.interest_days)
               and trx.interest_days <= nvl(bucket_lines.days_to,trx.interest_days))
             OR
              (trx.charge_type <> 'AVERAGE_DAILY_BALANCE'
               and (trx.finance_charge_date- trx.due_date) >=nvl(bucket_lines.days_start,
                                                          (trx.finance_charge_date- trx.due_date))
              and   (trx.finance_charge_date- trx.due_date) <= nvl(bucket_lines.days_to,
                                                          (trx.finance_charge_date- trx.due_date))))
      /* The rate effective on the due date should be picked up. So, the due
         date should fall between the start date and end date of the charge schedule
         Condition 2: Start_date of the schedule should be less than or equal to the
         due date
         Condition 3: End date of the schedule should be greater than or equal to the
         due date or it should be NULL
         For Average Daily Balance, the rate effective on the charge calculation should be
         picked up */
       and ((trx.charge_type = 'AVERAGE_DAILY_BALANCE'
             and trx.finance_charge_date >= nvl(sched_hdrs.start_date,trx.finance_charge_date)
             and (trx.finance_charge_date <= sched_hdrs.end_date
                   OR sched_hdrs.end_date IS NULL))
            OR
           (trx.charge_type <> 'AVERAGE_DAILY_BALANCE'
    	     and   nvl(sched_hdrs.start_date,trx.due_date) <= trx.due_date
            and  ( sched_hdrs.end_date >= trx.due_date
                        OR sched_hdrs.end_date IS NULL)))
     /* Create the panalty lines only if the late charge documents will be created out
        of this record */
       and  trx.display_flag = 'Y'
     /* Do not populate the Penalty lines if the invoice level tolerances are not met
         For Average Daily Balance, there is no invoice level tolerances*/
      and decode(trx.charge_type,
                 'AVERAGE_DAILY_BALANCE',  nvl(trx.original_balance,0),
                 decode(trx.class,
                	'CM', nvl(trx.original_balance,0),
	                'PMT',nvl(trx.original_balance,0),
                        decode(trx.min_fc_invoice_overdue_type,
                              'AMOUNT',nvl(trx.min_fc_invoice_amount,0),
                              'PERCENT',(nvl(trx.min_fc_invoice_percent,0)
                                      * trx.amount_due_original/100),
                               nvl(trx.original_balance,0)))) <= nvl(trx.original_balance,0)
    group by trx.customer_id,
             trx.customer_site_use_id,
             trx.currency_code,
             trx.customer_trx_id,
             trx.legal_entity_id,
             trx.payment_schedule_id,
             trx.class,
             trx.amount_due_original,
             trx.amount_due_remaining,
             trx.fin_charge_charged,
             trx.trx_date,
             trx.cust_trx_type_id,
             trx.last_charge_date,
             trx.exchange_rate_type,
             trx.min_interest_charge,
             trx.max_interest_charge,
             trx.due_date,
             trx.finance_charge_date,
             decode(trx.charge_type,'AVERAGE_DAILY_BALANCE',trx.charge_type, NULL),
             trx.actual_date_closed,
             decode(cust_site.penalty_type, 'CHARGES_SCHEDULE', sched_lines.rate,
                                             'FIXED_RATE', cust_site.penalty_rate,
                                              NULL),
             sched_hdrs.start_date,
             sched_hdrs.end_date,
             bucket_lines.days_start,
             bucket_lines.days_to,
             decode(cust_site.penalty_type,
                      'FIXED_AMOUNT',decode(trx.class,
                                            'CM',-1 * cust_site.penalty_fixed_amount,
                                            'PMT', -1*cust_site.penalty_fixed_amount,
                                            cust_site.penalty_fixed_amount),
                      'CHARGES_SCHEDULE',decode(sched_hdrs.schedule_header_type,
                                                'AMOUNT',decode(trx.class,
                                                               'CM', -1*sched_lines.amount,
                                                               'PMT',-1*sched_lines.amount,
                                                               sched_lines.amount),
                                                NULL),
                      'CHARGE_PER_TIER',decode(sched_hdrs.schedule_header_type,
                                                'AMOUNT',decode(trx.class,
                                                               'CM', -1*sched_lines.amount,
                                                               'PMT',-1*sched_lines.amount,
                                                               sched_lines.amount),
                                                NULL), /*Enhacement 6469663*/
                      NULL),
             trx.late_charge_type,
	     trx.org_id,
             decode(trx.charge_type,'AVERAGE_DAILY_BALANCE',trx.interest_days,1),
             trx.late_charge_term_id,
             trx.interest_period_days,
             trx.interest_calculation_period,
             trx.charge_on_finance_charge_flag,
             trx.message_text_id,
             cust_site.penalty_type) a);

      IF l_debug_flag = 'Y' THEN
         debug( 'ar_calc_late_charge.insert_penalty_lines()-' );
      END IF;
    --
   EXCEPTION
      WHEN  OTHERS THEN
           --IF l_debug_flag = 'Y' THEN
               debug('EXCEPTION : '||SQLCODE||' : '||SQLERRM);
               debug('EXCEPTION: ar_calc_late_charge.insert_penalty_lines' );
           --END IF;
           RAISE;
END insert_penalty_lines;

PROCEDURE  delete_draft_batches(p_worker_number		IN	NUMBER,
                                p_total_workers         IN	NUMBER) IS

BEGIN

     IF l_debug_flag = 'Y' THEN
         debug('ar_calc_late_charge.delete_draft_batches()+');
         debug('p_worker_number :	'||p_worker_number);
         debug('p_total_workers :	'||p_total_workers);
     END IF;
    /* delete lines first */

     delete from ar_interest_lines
     where interest_header_id in (select hdr.interest_header_id
                                   from ar_interest_batches batch,
					ar_interest_headers hdr
  				  where batch.batch_status = 'D'
				    and batch.interest_batch_id = hdr.interest_batch_id
                                    and mod(nvl(hdr.customer_site_use_id,0),p_total_workers) =
                                          decode(p_total_workers,p_worker_number,0,p_worker_number)
                                    and batch.request_id <> l_request_id
				    and exists (select late_charge_trx_id
						from   ar_late_charge_trx_t trx
						where	trx.customer_id = hdr.customer_id
						and	trx.customer_site_use_id = hdr.customer_site_use_id
                                                and     trx.currency_code = hdr.currency_code
						and	nvl(trx.legal_entity_id,-99)  =  nvl(hdr.legal_entity_id,-99)
						and	trx.org_id = hdr.org_id));
    /* delete headers */

    delete from ar_interest_headers hdr
    where not exists (select interest_line_id
                        from ar_interest_lines lines
                       where hdr.interest_header_id = lines.interest_header_id)
     and  hdr.request_id <> l_request_id;

    /* Deleting the empty batches are done later in delete_empty_batches */


    IF l_debug_flag = 'Y' THEN
      debug('ar_calc_late_charge.delete_draft_batches()-');
    END IF;

EXCEPTION WHEN OTHERS THEN
       --IF l_debug_flag = 'Y' THEN
         debug('EXCEPTION : '||SQLCODE||' : '||SQLERRM);
         debug('EXCEPTION : ar_calc_late_charge.delete_draft_batches()');
       --END IF;
       RAISE;
END delete_draft_batches;



PROCEDURE insert_int_batches(p_operating_unit_id	IN	NUMBER,
			     p_batch_name		IN	VARCHAR2,
                 	     p_fin_charge_date		IN	DATE,
		             p_batch_status		IN	VARCHAR2,
	                     p_gl_date			IN	DATE,
                             p_request_id		IN	NUMBER) IS

 l_operating_unit_id    number;
 l_batch_name		ar_interest_batches.batch_name%type;
 l_fin_charge_date	date;
 l_batch_status		varchar2(1);
 l_gl_date		date;
 l_srs_request_id	number;

BEGIN

  IF l_debug_flag = 'Y' THEN
     debug( 'ar_calc_late_charge.insert_int_batches()+' );
  END IF;

  l_operating_unit_id	:=	p_operating_unit_id;
  l_batch_name		:=	p_batch_name;
  l_fin_charge_date	:=	p_fin_charge_date;
  l_batch_status	:=	p_batch_status;
  l_gl_date		:=	p_gl_date;
  l_srs_request_id	:=	p_request_id;

  IF l_batch_name IS NULL THEN
     select meaning
     into   l_batch_name
     from   ar_lookups
     where  lookup_type = 'AR_LATE_CHARGE_LABELS'
     and   lookup_code = 'LATE_CHARGE_BATCH';
     IF l_debug_flag = 'Y' THEN
         debug( 'Batch Name Derived : '||l_batch_name);
     END IF;
  END IF;

     insert into ar_interest_batches
        ( interest_batch_id,
          batch_name,
          calculate_interest_to_date,
          batch_status,
          gl_date,
          last_update_date,
          last_updated_by,
          last_update_login,
          created_by,
          creation_date,
          transferred_status,
	  request_id,
          org_id,
          object_version_number)
  (select ar_interest_batches_s.nextval,
          l_batch_name||' '||ar_interest_batches_s2.nextval
             ||' '||to_char(l_fin_charge_date,'DD-Mon-YYYY'),
          l_fin_charge_date,
          l_batch_status,
          l_gl_date,
          sysdate,
          pg_last_updated_by,
          pg_last_update_login,
          pg_last_updated_by,
          sysdate,
          'N',
          l_srs_request_id,
          sysparam.org_id,
          1
    from ar_system_parameters sysparam
    where nvl(l_operating_unit_id,sysparam.org_id) = sysparam.org_id);

  IF l_debug_flag = 'Y' THEN
     debug( 'ar_calc_late_charge.insert_int_batches()-' );
  END IF;
    --
  EXCEPTION
     WHEN  OTHERS THEN
        --IF l_debug_flag = 'Y' THEN
            debug('EXCEPTION : '||SQLCODE||' : '||SQLERRM);
            debug('EXCEPTION: ar_calc_late_charge.insert_int_batches' );
        --END IF;
        RAISE;
END insert_int_batches;


PROCEDURE insert_int_headers(p_fin_charge_date	IN	DATE,
			     p_worker_number	IN	NUMBER,
			     p_total_workers    IN	NUMBER) IS
BEGIN

   IF l_debug_flag = 'Y' THEN
      debug( 'ar_calc_late_charge.insert_int_headers()+' );
   END IF;

   insert into ar_interest_headers
       (interest_header_id,
        interest_batch_id,
        customer_id,
        customer_site_use_id,
        header_type,
        currency_code,
        cust_trx_type_id,
        late_charge_calculation_trx,
        credit_items_flag,
        disputed_transactions_flag,
        payment_grace_days,
        late_charge_term_id,
        interest_period_days,
        interest_calculation_period,
        charge_on_finance_charge_flag,
        hold_charged_invoices_flag,
        message_text_id,
        multiple_interest_rates_flag,
        charge_begin_date,
        cust_acct_profile_amt_id,
        exchange_rate,
        exchange_rate_type,
        min_fc_invoice_overdue_type,
        min_fc_invoice_amount,
        min_fc_invoice_percent,
        min_fc_balance_overdue_type,
        min_fc_balance_amount,
        min_fc_balance_percent,
        min_interest_charge,
        max_interest_charge,
        interest_type,
        interest_rate,
        interest_fixed_amount,
        interest_schedule_id,
        penalty_type,
        penalty_rate,
        penalty_fixed_amount,
        penalty_schedule_id,
        last_accrue_charge_date,
        finance_charge_date,
        customer_profile_id,
        collector_id,
        legal_entity_id,
        last_update_date,
        last_updated_by,
        last_update_login,
        created_by,
        creation_date,
        process_status,
        process_message,
        request_id,
        worker_num,
        object_version_number,
        org_id,
        display_flag)
   (select hdr.interest_header_id,
           bat.interest_batch_id,
           hdr.customer_id,
           hdr.customer_site_use_id,
           cust_site.late_charge_type header_type,
           hdr.currency_code,
           decode(cust_site.late_charge_type,
                  'INV', sysparam.late_charge_inv_type_id,
		  'DM',sysparam.late_charge_dm_type_id) cust_trx_type_id,
           cust_site.late_charge_calculation_trx,
           cust_site.credit_items_flag,
           cust_site.disputed_transactions_flag,
           cust_site.payment_grace_days,
           cust_site.late_charge_term_id,
           cust_site.interest_period_days,
           cust_site.interest_calculation_period,
           cust_site.charge_on_finance_charge_flag,
           cust_site.hold_charged_invoices_flag,
           cust_site.message_text_id,
           cust_site.multiple_interest_rates_flag,
           cust_site.charge_begin_date,
           cust_site.cust_acct_profile_amt_id,
           cust_site.exchange_rate,
           cust_site.exchange_rate_type,
           cust_site.min_fc_invoice_overdue_type,
           cust_site.min_fc_invoice_amount,
           cust_site.min_fc_invoice_percent,
           cust_site.min_fc_balance_overdue_type,
           cust_site.min_fc_balance_amount,
           cust_site.min_fc_balance_percent,
           cust_site.min_interest_charge,
           cust_site.max_interest_charge,
           cust_site.interest_type,
           cust_site.interest_rate,
           cust_site.interest_fixed_amount,
           cust_site.interest_schedule_id,
           cust_site.penalty_type,
           cust_site.penalty_rate,
           cust_site.penalty_fixed_amount,
           cust_site.penalty_schedule_id,
           cust_site.last_accrue_charge_date,
           p_fin_charge_date,
           cust_site.customer_profile_id,
           cust_site.collector_id,
           hdr.legal_entity_id,
           sysdate,
           pg_last_updated_by,
           pg_last_update_login,
           pg_last_updated_by,
           sysdate,
           'N',
           NULL,
           l_request_id,
           p_worker_number,
           1,
           cust_site.org_id,
           hdr.display_flag
    from   (select lines.interest_header_id,
                   trx.customer_id,
                   trx.customer_site_use_id,
                   trx.legal_entity_id,
                   trx.currency_code,
                   trx.late_charge_type,
		   trx.org_id,
                   trx.display_flag
            from   ar_interest_lines lines,
                   ar_late_charge_trx_t trx
            where  lines.payment_schedule_id = trx.payment_schedule_id
	    and    lines.org_id = trx.org_id
	    and    lines.type=trx.charge_type
	    and    not exists (select interest_header_id
                                from ar_interest_headers headers
                                where headers.interest_header_id = lines.interest_header_id)
            and    mod(nvl(trx.customer_site_use_id,0),p_total_workers) =
                                          decode(p_total_workers,p_worker_number,0,p_worker_number)
            /*Bug fix 5290709: If display flag is No, we should not consider this record if there is another record
              existing with display flag Yes */
            and ((trx.display_flag = 'Y' and sign(trx.late_charge_amount) <> 0)
             OR (trx.display_flag = 'N' and not exists (select 1
                                                        from ar_late_charge_trx_t trx1
                                                        where trx1.payment_schedule_id = trx.payment_schedule_id
                                                        and trx1.display_flag = 'Y')))
            group  by lines.interest_header_id,
                      trx.customer_id,
                      trx.customer_site_use_id,
                      trx.legal_entity_id,
                      trx.currency_code,
                      trx.late_charge_type,
		      trx.org_id,
                      trx.display_flag) hdr,
           ar_lc_cust_sites_t cust_site,
	   ar_interest_batches bat,
           ar_system_parameters sysparam
    where  hdr.customer_id = cust_site.customer_id
      and  hdr.customer_site_use_id = cust_site.customer_site_use_id
      and  hdr.currency_code = cust_site.currency_code
      and  mod(nvl(cust_site.customer_site_use_id,0),p_total_workers) =
                                          decode(p_total_workers,p_worker_number,0,p_worker_number)
      and  hdr.late_charge_type = cust_site.late_charge_type
      and  hdr.org_id = cust_site.org_id
      and  bat.org_id = cust_site.org_id
      and  sysparam.org_id = cust_site.org_id
      and  bat.request_id = l_request_id);

   IF l_debug_flag = 'Y' THEN
      debug( 'ar_calc_late_charge.insert_int_headers()-' );
   END IF;
    --
   EXCEPTION
     WHEN  OTHERS THEN
        --IF l_debug_flag = 'Y' THEN
            debug('EXCEPTION : '||SQLCODE||' : '||SQLERRM);
            debug('EXCEPTION: ar_calc_late_charge.insert_int_headers' );
        --END IF;
        RAISE;
END insert_int_headers;

/*=========================================================================================+
 | PROCEDURE INSERT_INT_LINES                                                              |
 |                                                                                         |
 | DESCRIPTION                                                                             |
 |                                                                                         |
 |   This procedure is used to insert interest and penalty lines to ar_interest_lines      |
 |   table.                                                                                |
 |                                                                                         |
 | PSEUDO CODE/LOGIC                                                                       |
 |                                                                                         |
 |                                                                                         |
 | The tolerances should be applied on the interest lines before inserting into            |
 | ar_interest_lines, mainly max_interest_charge.                                          |
 | The logic:                                                                              |
 |                                                                                         |
 |  1. Sort the interest lines in the order of charge_line_type, rate_start_date,          |
 |      charge_type,receipt_date and fin_charge_charged                                    |
 |  2. Calculate the running total of the calculated interest charge in that order         |
 |     (in the select statement, it is denoted as late_charge_rtot)                        |
 |  3. Tolerances are applicable only on charge_line_type = INTEREST                       |
 |  4. At any point in this order of calculation ,                                         |
 |     a)  if the running total is less than or equal to the maximum allowed interest      |
 |         charge, we should take the charge as  the calculated charge itself.             |
 |     b)  if the running total is greater than the maximum allowed interest charge        |
 |         i) if the maximum allowed interest charge is less than the running total till   |
 |            the previous line, that means the maximum interest is already covered by     |
 |            the previous line atleast. So, that charge should be 0 for the current line  |
 |        ii) otherwise, it should be the least of (the difference between the maximum     |
 |            interest charge and the running total till the previous line) and the max    |
 |            interest charge                                                              |
 |                                                                                         |
 | PARAMETERS                                                                              |
 |                                                                                         |
 |                                                                                         |
 | KNOWN ISSUES                                                                            |
 |                                                                                         |
 | NOTES                                                                                   |
 |                                                                                         |
 | MODIFICATION HISTORY                                                                    |
 | Date                  Author            Description of Changes                          |
 | 22-DEC-2005           rkader            Created                                         |
 | 21-SEP-2006           rkader            Bug 5556598. Modified the logic as explained    |
 |                                         above                                           |
 |                                         Bug8556955                                      |
 |22-JUN-2009            naneja            Inserted data for new column cash_receipt_id    |
 *=========================================================================================*/
PROCEDURE insert_int_lines(p_worker_number	IN	NUMBER,
			   p_total_workers	IN	NUMBER) IS
BEGIN
   IF l_debug_flag = 'Y' THEN
      debug( 'ar_calc_late_charge.insert_int_lines()+' );
   END IF;

   insert into ar_interest_lines
       (interest_line_id,
        interest_header_id,
        payment_schedule_id,
        type,
        original_trx_class,
        daily_interest_charge,
        outstanding_amount,
        days_overdue_late,
        days_of_interest,
        interest_charged,
        payment_date,
        finance_charge_charged,
        amount_due_original,
        amount_due_remaining,
        original_trx_id,
        receivables_trx_id,
        last_charge_date,
        due_date,
        actual_date_closed,
        interest_rate,
        rate_start_date,
        rate_end_date,
        schedule_days_from,
        schedule_days_to,
        last_update_date,
        last_updated_by,
        last_update_login,
        created_by,
        creation_date,
        process_status,
        process_message,
        org_id,
        object_version_number,
        cash_receipt_id)
 (select ar_interest_lines_s.nextval interest_line_id,
         b.interest_header_id,
         b.payment_schedule_id,
         b.charge_type,
         b.class,
         decode(b.class,
                'PMT',b.late_charge_amount,
                'CM', b.late_charge_amount,
                decode(b.charge_line_type,
                       'INTEREST',
                         decode(sign(b.late_charge_rtot - b.max_interest_charge),
                                  -1, b.late_charge_amount,
                                   0 ,b.late_charge_amount,
                                  +1,decode(sign(b.max_interest_charge -
                                              (b.late_charge_rtot - b.late_charge_amount)),
                                            -1,0,
                                            least((b.max_interest_charge -
                                                  (b.late_charge_rtot - b.late_charge_amount)),
                                                   b.max_interest_charge))),
                      'PENALTY', b.late_charge_amount))
                              /decode(b.days_of_interest,0,1,b.days_of_interest) daily_interest_charge,
         b.outstanding_amount,
         b.days_overdue_late,
         b.days_of_interest,
         decode(b.class,
                'PMT',b.late_charge_amount,
                'CM', b.late_charge_amount,
                decode(b.charge_line_type,
                       'INTEREST',
                         decode(sign(b.late_charge_rtot - b.max_interest_charge),
                                  -1, b.late_charge_amount,
                                   0 ,b.late_charge_amount,
                                  +1,decode(sign(b.max_interest_charge -
                                              (b.late_charge_rtot - b.late_charge_amount)),
                                            -1,0,
                                            least((b.max_interest_charge -
                                                  (b.late_charge_rtot - b.late_charge_amount)),
                                                   b.max_interest_charge))),
                      'PENALTY', b.late_charge_amount)) interest_charged,
         b.payment_date,
         b.fin_charge_charged,
         b.amount_due_original,
         b.amount_due_remaining,
         b.original_trx_id,
         b.receivables_trx_id,
         b.last_charge_date,
         b.due_date,
         b.actual_date_closed,
         b.interest_rate,
         b.rate_start_date,
         b.rate_end_date,
         b.schedule_days_start,
         b.schedule_days_to,
         sysdate,
         pg_last_updated_by,
         pg_last_update_login,
         pg_last_updated_by,
         sysdate,
         'N',
         NULL,
         b.org_id,
         1,
	 b.cash_receipt_id
      from
      (select
              a.interest_header_id,
              a.payment_schedule_id,
              a.charge_type,
              a.class,
              a.outstanding_amount,
              a.days_overdue_late,
              a.days_of_interest,
              a.late_charge_amount,
              a.charge_line_type,
              a.late_charge_rtot,
              a.max_interest_charge,
              a.payment_date,
              a.fin_charge_charged,
              a.amount_due_original,
              a.amount_due_remaining,
              a.original_trx_id,
              a.receivables_trx_id,
              a.last_charge_date,
              a.due_date,
              a.actual_date_closed,
              a.interest_rate,
              a.rate_start_date,
              a.rate_end_date,
              a.schedule_days_start,
              a.schedule_days_to,
              a.org_id,
	      a.cash_receipt_id
       from
        (select
                hdr.interest_header_id,
                trx.payment_schedule_id,
                trx.charge_type,
                trx.class,
                trx.overdue_late_pay_amount outstanding_amount,
                /*bug 7431976 for invoice picked under late payment used receipt date*/
                (decode(trx.charge_type,'LATE',(nvl(trx.receipt_date,trx.finance_charge_date) - trx.due_date) ,(trx.finance_charge_date - nvl(trx.last_charge_date,trx.due_date)))) days_overdue_late,
                trx.interest_days days_of_interest,
                trx.late_charge_amount,
                trx.charge_line_type,
                decode(trx.charge_line_type,
                       'INTEREST',  sum(trx.late_charge_amount)
                                            over (partition by trx.payment_schedule_id
                                                  order by trx.payment_schedule_id,
                                                           trx.charge_line_type,
                                                           trx.rate_start_date,
                                                           trx.charge_type,
                                                           trx.receipt_date,
                                                           trx.fin_charge_charged),
                       'PENALTY', NULL) late_charge_rtot,
                trx.receipt_date payment_date,
                nvl(trx.max_interest_charge,9999999999999999) max_interest_charge,
                trx.fin_charge_charged,
                trx.amount_due_original,
                trx.amount_due_remaining,
                trx.customer_trx_id original_trx_id,
                decode(hdr.late_charge_type,
                        'ADJ',decode(trx.charge_line_type,
                                      'PENALTY',ar_calc_late_charge.get_penalty_rec_trx_id(trx.finance_charge_date,
                                                                                           trx.org_id),
                                      'INTEREST',ar_calc_late_charge.get_int_rec_trx_id(trx.customer_trx_id,
                                                                              trx.finance_charge_date,
									      trx.org_id),
                                       NULL),
                       NULL) receivables_trx_id,
                trx.last_charge_date,
                trx.due_date,
                trx.actual_date_closed,
                trx.interest_rate,
                trx.rate_start_date,
                trx.rate_end_date,
                trx.schedule_days_start,
                trx.schedule_days_to,
       		trx.org_id,
		trx.cash_receipt_id
          from
           (select
                ar_calc_late_charge.get_next_hdr_id interest_header_id,
                a.customer_id,
                a.customer_site_use_id,
                a.currency_code,
                a.legal_entity_id,
                a.late_charge_type,
                a.payment_schedule_id,
		a.org_id,
                a.display_flag
            from
                 (select trx.customer_id,
                         trx.customer_site_use_id,
                         trx.currency_code,
                         trx.legal_entity_id,
                         trx.late_charge_type,
			 trx.org_id,
                         trx.display_flag,
                         decode(trx.late_charge_type,'INV',-99,trx.payment_schedule_id) payment_schedule_id
                  from   ar_late_charge_trx_t trx
                  where  mod(nvl(trx.customer_site_use_id,0),p_total_workers) =
                                          decode(p_total_workers,p_worker_number,0,p_worker_number)
                 /*Bug fix 5290709: If display flag is No, we should not consider this record if there is another record
                   existing with display flag Yes */
                 and ((trx.display_flag = 'Y' and sign(trx.late_charge_amount) <> 0)
                 OR (trx.display_flag = 'N' and not exists (select 1
                                                            from ar_late_charge_trx_t trx1
                                                            where trx1.payment_schedule_id = trx.payment_schedule_id
                                                            and trx1.display_flag = 'Y')))
                group by trx.customer_id,
                         trx.customer_site_use_id,
                         trx.currency_code,
                         trx.legal_entity_id,
                         trx.late_charge_type,
			 trx.org_id,
                         trx.display_flag,
                         decode(trx.late_charge_type,'INV',-99,trx.payment_schedule_id))a)hdr,
                 (select trx.payment_schedule_id,
                         sum(trx.late_charge_amount) total_interest
                    from ar_late_charge_trx_t trx
                  where  trx.charge_line_type = 'INTEREST'
                    and  mod(nvl(trx.customer_site_use_id,0),p_total_workers) =
                                          decode(p_total_workers,p_worker_number,0,p_worker_number)
                  group  by trx.payment_schedule_id) int_tab,
                  ar_late_charge_trx_t trx
           /* Apply the invoice level tolerances */
           where decode(trx.class,
                       'CM', nvl(trx.original_balance,0),
                       'PMT',nvl(trx.original_balance,0),
                       decode(trx.display_flag,
                              'N', nvl(trx.original_balance,0),
                              decode(trx.min_fc_invoice_overdue_type,
                                     'AMOUNT',nvl(trx.min_fc_invoice_amount,0),
                                      'PERCENT',(nvl(trx.min_fc_invoice_percent,0) * trx.amount_due_original/100),
                                      nvl(trx.original_balance,0)))) <= nvl(trx.original_balance,0)
             and trx.payment_schedule_id = int_tab.payment_schedule_id
          /* Apply Min Interest charge tolerance  Bug 8559863 Restrict tolerance application on negatvie invoice as well
             Similar to CM case */
             and decode(trx.class,
                        'CM',int_tab.total_interest,
                        'PMT',int_tab.total_interest,
			'INV', decode(sign(trx.original_balance),-1,int_tab.total_interest,
				                        decode(trx.display_flag,
                               					'N', int_tab.total_interest,
			                                        nvl(trx.min_interest_charge,0))),
                        decode(trx.display_flag,
                               'N', int_tab.total_interest,
				nvl(trx.min_interest_charge,0))) <= int_tab.total_interest
             and mod(nvl(trx.customer_site_use_id,0),p_total_workers) =
                                          decode(p_total_workers,p_worker_number,0,p_worker_number)
             and hdr.customer_id = trx.customer_id
             and hdr.customer_site_use_id = trx.customer_site_use_id
             and hdr.currency_code = trx.currency_code
             and hdr.legal_entity_id = trx.legal_entity_id
             and hdr.late_charge_type = trx.late_charge_type
	     and hdr.org_id = trx.org_id
             /*Bug fix 5290709: If display flag is No, we should not consider this record if there is another record
                   existing with display flag Yes */
              and ((trx.display_flag = 'Y' and sign(trx.late_charge_amount) <> 0)
                 OR (trx.display_flag = 'N' and not exists (select 1
                                                            from ar_late_charge_trx_t trx1
                                                            where trx1.payment_schedule_id = trx.payment_schedule_id
                                                            and trx1.display_flag = 'Y')))
             and hdr.payment_schedule_id = decode(trx.late_charge_type,'INV',-99,trx.payment_schedule_id)) a ) b);

   IF l_debug_flag = 'Y' THEN
      debug( 'ar_calc_late_charge.insert_int_lines()-' );
   END IF;
    --
   EXCEPTION
     WHEN  OTHERS THEN
        --IF l_debug_flag = 'Y' THEN
            debug('EXCEPTION : '||SQLCODE||' : '||SQLERRM);
            debug('EXCEPTION: ar_calc_late_charge.insert_int_lines');
        --END IF;
        RAISE;
END insert_int_lines;

/* This procedure is used to insert records in ar_interest lines
   when the calculation method is average daily balance */

PROCEDURE insert_int_lines_adb(p_worker_number      IN      NUMBER,
                               p_total_workers      IN      NUMBER) IS
BEGIN
   IF l_debug_flag = 'Y' THEN
      debug( 'ar_calc_late_charge.insert_int_lines_adb()+' );
   END IF;

 insert into ar_interest_lines
       (interest_line_id,
        interest_header_id,
        payment_schedule_id,
        type,
        original_trx_class,
        daily_interest_charge,
        outstanding_amount,
        days_overdue_late,
        days_of_interest,
        interest_charged,
        payment_date,
        finance_charge_charged,
        amount_due_original,
        amount_due_remaining,
        original_trx_id,
        receivables_trx_id,
        last_charge_date,
        due_date,
        actual_date_closed,
        interest_rate,
        rate_start_date,
        rate_end_date,
        schedule_days_from,
        schedule_days_to,
        last_update_date,
        last_updated_by,
        last_update_login,
        created_by,
        creation_date,
        process_status,
        process_message,
        org_id,
        object_version_number)
 (select ar_interest_lines_s.nextval interest_line_id,
         b.interest_header_id,
         -99, --payment_schedule_id
         decode(b.charge_line_type, 'PENALTY', b.charge_line_type,b.charge_type) charge_type,
         b.class,
         b.late_charge_amount/decode(b.days_of_interest,0,1,b.days_of_interest) daily_interest_charge,
         b.outstanding_amount,
         b.days_overdue_late,
         b.days_of_interest,
         b.late_charge_amount interest_charged,
         b.payment_date,
         b.fin_charge_charged,
         b.amount_due_original,
         b.amount_due_remaining,
         b.original_trx_id,
         b.receivables_trx_id,
         b.last_charge_date,
         b.due_date,
         b.actual_date_closed,
         b.interest_rate,
         b.rate_start_date,
         b.rate_end_date,
         b.schedule_days_start,
         b.schedule_days_to,
         sysdate,
         pg_last_updated_by,
         pg_last_update_login,
         pg_last_updated_by,
         sysdate,
         'N',
         NULL,
         b.org_id,
         1
    from
      (select
              a.interest_header_id,
              a.payment_schedule_id,
              a.charge_type,
              a.class,
              a.outstanding_amount,
              a.days_overdue_late,
              a.days_of_interest,
              a.late_charge_amount,
              a.charge_line_type,
              a.payment_date,
              a.fin_charge_charged,
              a.amount_due_original,
              a.amount_due_remaining,
              a.original_trx_id,
              a.receivables_trx_id,
              a.last_charge_date,
              a.due_date,
              a.actual_date_closed,
              a.interest_rate,
              a.rate_start_date,
              a.rate_end_date,
              a.schedule_days_start,
              a.schedule_days_to,
              a.org_id
       from
        (
	  select
                hdr.interest_header_id,
                trx.payment_schedule_id,
                trx.charge_type,
                trx.class,
                trx.overdue_late_pay_amount outstanding_amount,
                trx.interest_days days_overdue_late,
                trx.interest_days days_of_interest,
                decode(trx.charge_line_type,
                       'INTEREST',decode(sign(nvl(trx.max_interest_charge,9999999999999999) -
                                         trx.late_charge_amount),
                                         +1,trx.late_charge_amount,
                                         0, trx.late_charge_amount,
                                         -1, nvl(trx.max_interest_charge,9999999999999999)),
                       'PENALTY',trx.late_charge_amount ) late_charge_amount,
                trx.charge_line_type,
                trx.receipt_date payment_date,
                trx.fin_charge_charged,
                trx.amount_due_original,
                trx.amount_due_remaining,
                trx.customer_trx_id original_trx_id,
                NULL receivables_trx_id,
                trx.last_charge_date,
                trx.due_date,
                trx.actual_date_closed,
                trx.interest_rate,
                trx.rate_start_date,
                trx.rate_end_date,
                trx.schedule_days_start,
                trx.schedule_days_to,
                trx.org_id
          from
           (select
                ar_calc_late_charge.get_next_hdr_id interest_header_id,
                a.customer_id,
                a.customer_site_use_id,
                a.currency_code,
                a.legal_entity_id,
                a.late_charge_type,
                a.payment_schedule_id,
                a.org_id
            from
                 (select trx.customer_id,
                         trx.customer_site_use_id,
                         trx.currency_code,
                         trx.legal_entity_id,
                         trx.late_charge_type,
                         trx.org_id,
                         decode(trx.late_charge_type,'INV',-99,trx.payment_schedule_id) payment_schedule_id
                  from   ar_late_charge_trx_t trx
                  where  mod(nvl(trx.customer_site_use_id,0),p_total_workers) =
                                          decode(p_total_workers,p_worker_number,0,p_worker_number)
                group by trx.customer_id,
                         trx.customer_site_use_id,
                         trx.currency_code,
                         trx.legal_entity_id,
                         trx.late_charge_type,
                         trx.org_id,
                         decode(trx.late_charge_type,'INV',-99,trx.payment_schedule_id))a)hdr,
                  (select trx.payment_schedule_id,
                         sum(trx.late_charge_amount) total_interest
                    from ar_late_charge_trx_t trx
                  where  trx.charge_line_type = 'INTEREST'
                    and  mod(nvl(trx.customer_site_use_id,0),1) =
                                          decode(1,1,0,1)
                  group  by trx.payment_schedule_id) int_tab,
                  ar_late_charge_trx_t trx
          /* Apply Min Interest charge tolerance */
            where decode(trx.charge_line_type,
                         'INTEREST', nvl(trx.min_interest_charge,0),
                         'PENALTY',nvl(trx.late_charge_amount,0)) <= nvl(trx.late_charge_amount,0)
             and mod(nvl(trx.customer_site_use_id,0),p_total_workers) =
                                          decode(p_total_workers,p_worker_number,0,p_worker_number)
             and trx.payment_schedule_id = int_tab.payment_schedule_id
             and hdr.customer_id = trx.customer_id
             and hdr.customer_site_use_id = trx.customer_site_use_id
             and hdr.currency_code = trx.currency_code
             and nvl(hdr.legal_entity_id,-99) = nvl(trx.legal_entity_id,-99)
             and hdr.late_charge_type = trx.late_charge_type
             and hdr.org_id = trx.org_id
             and trx.charge_type = 'AVERAGE_DAILY_BALANCE'
             and hdr.payment_schedule_id = decode(trx.late_charge_type,'INV',-99,trx.payment_schedule_id)) a )b);

   IF l_debug_flag = 'Y' THEN
      debug( 'ar_calc_late_charge.insert_int_lines_adb()-' );
   END IF;
    --
   EXCEPTION
     WHEN  OTHERS THEN
        --IF l_debug_flag = 'Y' THEN
            debug('EXCEPTION : '||SQLCODE||' : '||SQLERRM);
            debug('EXCEPTION: ar_calc_late_charge.insert_int_lines_adb');
        --END IF;
        RAISE;
END insert_int_lines_adb;

PROCEDURE delete_empty_batches IS
BEGIN
    IF l_debug_flag = 'Y' THEN
      debug('ar_calc_late_charge.delete_empty_batches()+');
    END IF;

    delete from ar_interest_batches bat
    where not exists (select interest_header_id
                       from  ar_interest_headers hdr
                       where bat.interest_batch_id = hdr.interest_batch_id)
    and ( request_id = l_request_id
         OR batch_status = 'D') ;

    IF l_debug_flag = 'Y' THEN
      debug('ar_calc_late_charge.delete_empty_batches()-');
    END IF;
EXCEPTION WHEN OTHERS THEN
    --IF l_debug_flag = 'Y' THEN
       debug('EXCEPTION : '||SQLCODE||' : '||SQLERRM);
       debug('EXCEPTION:  ar_calc_late_charge.delete_empty_batches()');
    --END IF;
END delete_empty_batches;

PROCEDURE lock_batches IS

  CURSOR c_lock IS
    select interest_batch_id, batch_name, transferred_status
      from ar_interest_batches
     where request_id = l_request_id
     for update of transferred_status nowait;

  TYPE l_int_batch_rec_type IS RECORD(
                interest_batch_id       DBMS_SQL.NUMBER_TABLE,
                batch_name              DBMS_SQL.VARCHAR2_TABLE,
                transferred_status      DBMS_SQL.VARCHAR2_TABLE);

  l_int_batch_tbl                         l_int_batch_rec_type;
  l_bulk_fetch_rows                       number := 1000;
  l_last_fetch_rows                       boolean := FALSE;

BEGIN
    debug('ar_calc_late_charge.lock_batches ()+');

    OPEN c_lock;

    LOOP
        FETCH c_lock BULK COLLECT INTO
            l_int_batch_tbl
        LIMIT l_bulk_fetch_rows;

        IF c_lock%NOTFOUND  THEN
           EXIT;
        END IF;
    END LOOP;
    CLOSE c_lock;

    debug('ar_calc_late_charge.lock_batches ()-');
EXCEPTION
   WHEN OTHERS THEN
     debug('EXCEPTION : ar_calc_late_charge.lock_batches ()');
     debug('EXCEPTION : '||SQLCODE ||' : '||SQLERRM);
   RAISE;
END lock_batches;


PROCEDURE debug_cust_sites IS
 CURSOR customer_sites_cur IS
       SELECT   org_id,
		lc_cust_sites_id,
                customer_id,
                customer_site_use_id,
                currency_code,
                late_charge_calculation_trx,
                credit_items_flag,
                disputed_transactions_flag,
                payment_grace_days,
                late_charge_type,
                late_charge_term_id ,
                interest_period_days,
                interest_calculation_period,
                charge_on_finance_charge_flag,
                hold_charged_invoices_flag,
                message_text_id,
                multiple_interest_rates_flag,
                charge_begin_date,
                cust_acct_profile_amt_id,
                exchange_rate_type,
                min_fc_invoice_overdue_type,
                min_fc_invoice_amount,
                min_fc_invoice_percent,
                min_fc_balance_overdue_type,
                min_fc_balance_amount,
                min_fc_balance_percent,
                min_interest_charge,
                max_interest_charge,
                interest_type,
                interest_Rate,
                interest_fixed_amount,
                interest_schedule_id,
                penalty_type,
                penalty_rate,
                penalty_fixed_amount,
                penalty_schedule_id,
                last_accrue_charge_date
       FROM  ar_lc_cust_sites_t
       ORDER BY org_id,
		customer_id,
                customer_site_use_id,
                currency_code;

TYPE l_customer_sites_rec_type IS RECORD(
          org_id			DBMS_SQL.NUMBER_TABLE,
          lc_cust_sites_id	DBMS_SQL.NUMBER_TABLE,
          customer_id			DBMS_SQL.NUMBER_TABLE,
          customer_site_use_id		DBMS_SQL.NUMBER_TABLE,
          currency_code			DBMS_SQL.VARCHAR2_TABLE,
          late_charge_calculation_trx	DBMS_SQL.VARCHAR2_TABLE,
          credit_items_flag		DBMS_SQL.VARCHAR2_TABLE,
          disputed_transactions_flag	DBMS_SQL.VARCHAR2_TABLE,
          payment_grace_days		DBMS_SQL.NUMBER_TABLE,
          late_charge_type		DBMS_SQL.VARCHAR2_TABLE,
          late_charge_term_id		DBMS_SQL.NUMBER_TABLE,
          interest_period_days		DBMS_SQL.NUMBER_TABLE,
          interest_calculation_period	DBMS_SQL.VARCHAR2_TABLE,
          charge_on_finance_charge_flag	DBMS_SQL.VARCHAR2_TABLE,
          hold_charged_invoices_flag	DBMS_SQL.VARCHAR2_TABLE,
          message_text_id		DBMS_SQL.NUMBER_TABLE,
          multiple_interest_rates_flag	DBMS_SQL.VARCHAR2_TABLE,
          charge_begin_date		DBMS_SQL.DATE_TABLE,
          cust_acct_profile_amt_id	DBMS_SQL.NUMBER_TABLE,
          exchange_rate_type		DBMS_SQL.VARCHAR2_TABLE,
          min_fc_invoice_overdue_type	DBMS_SQL.VARCHAR2_TABLE,
          min_fc_invoice_amount		DBMS_SQL.NUMBER_TABLE,
          min_fc_invoice_percent	DBMS_SQL.NUMBER_TABLE,
          min_fc_balance_overdue_type	DBMS_SQL.VARCHAR2_TABLE,
          min_fc_balance_amount		DBMS_SQL.NUMBER_TABLE,
          min_fc_balance_percent	DBMS_SQL.NUMBER_TABLE,
          min_interest_charge		DBMS_SQL.NUMBER_TABLE,
          max_interest_charge		DBMS_SQL.NUMBER_TABLE,
          interest_type			DBMS_SQL.VARCHAR2_TABLE,
          interest_Rate			DBMS_SQL.NUMBER_TABLE,
          interest_fixed_amount		DBMS_SQL.NUMBER_TABLE,
          interest_schedule_id		DBMS_SQL.NUMBER_TABLE,
          penalty_type			DBMS_SQL.VARCHAR2_TABLE,
          penalty_rate			DBMS_SQL.NUMBER_TABLE,
          penalty_fixed_amount		DBMS_SQL.NUMBER_TABLE,
          penalty_schedule_id		DBMS_SQL.NUMBER_TABLE,
          last_accrue_charge_date	DBMS_SQL.DATE_TABLE);

l_lc_cust_sites_tbl             	l_customer_sites_rec_type;
l_bulk_fetch_rows			number := 1000;
l_last_fetch_rows			boolean := FALSE;

BEGIN
   OPEN customer_sites_cur;
   LOOP
        FETCH customer_sites_cur BULK COLLECT INTO
            l_lc_cust_sites_tbl
        LIMIT l_bulk_fetch_rows;

        IF customer_sites_cur%NOTFOUND THEN
            l_last_fetch_rows := TRUE;
        END IF;

        IF (l_lc_cust_sites_tbl.lc_cust_sites_id.COUNT = 0) AND (l_last_fetch_rows) THEN
          debug('Customer Sites Cursor: ' || 'COUNT = 0 and LAST FETCH ');
          EXIT;
        END IF;

        IF l_lc_cust_sites_tbl.lc_cust_sites_id.COUNT > 0 THEN
          debug('Set Up Information of the Selected Customers');
          FOR i IN 1 .. l_lc_cust_sites_tbl.lc_cust_sites_id.LAST LOOP
            debug('======================================================');
	    debug('Org_ID			:	'||l_lc_cust_sites_tbl.org_id(i));
            debug('Customer_ID 			:	'||l_lc_cust_sites_tbl.customer_id(i));
            debug('customer_site_use_id		:	'||l_lc_cust_sites_tbl.customer_site_use_id(i));
            debug('currency_code		:	'||l_lc_cust_sites_tbl.currency_code(i));
            debug('late_charge_calculation_trx	:	'||l_lc_cust_sites_tbl.late_charge_calculation_trx(i));
            debug('credit_items_flag		:	'||l_lc_cust_sites_tbl.credit_items_flag(i));
            debug('disputed_transactions_flag	:	'||l_lc_cust_sites_tbl.disputed_transactions_flag(i));
            debug('payment_grace_days		:	'||l_lc_cust_sites_tbl.payment_grace_days(i));
            debug('late_charge_type		:	'||l_lc_cust_sites_tbl.late_charge_type(i));
            debug('late_charge_term_id 		:	'||l_lc_cust_sites_tbl.late_charge_term_id(i));
            debug('interest_period_days		:	'||l_lc_cust_sites_tbl.interest_period_days(i));
            debug('interest_calculation_period	:	'||l_lc_cust_sites_tbl.interest_calculation_period(i));
            debug('charge_on_finance_charge_flag:	'||l_lc_cust_sites_tbl.charge_on_finance_charge_flag(i));
            debug('hold_charged_invoices_flag	:	'||l_lc_cust_sites_tbl.hold_charged_invoices_flag(i));
            debug('message_text_id		:	'||l_lc_cust_sites_tbl.message_text_id(i));
            debug('multiple_interest_rates_flag	:	'||l_lc_cust_sites_tbl.multiple_interest_rates_flag(i));
            debug('charge_begin_date		:	'||l_lc_cust_sites_tbl.charge_begin_date(i));
            debug('cust_acct_profile_amt_id	:	'||l_lc_cust_sites_tbl.cust_acct_profile_amt_id(i));
            debug('exchange_rate_type		:	'||l_lc_cust_sites_tbl.exchange_rate_type(i));
            debug('min_fc_invoice_overdue_type	:	'||l_lc_cust_sites_tbl.min_fc_invoice_overdue_type(i));
            debug('min_fc_invoice_amount	:	'||l_lc_cust_sites_tbl.min_fc_invoice_amount(i));
            debug('min_fc_invoice_percent	:	'||l_lc_cust_sites_tbl.min_fc_invoice_percent(i));
            debug('min_fc_balance_overdue_type	:	'||l_lc_cust_sites_tbl.min_fc_balance_overdue_type(i));
            debug('min_fc_balance_amount	:	'||l_lc_cust_sites_tbl.min_fc_balance_amount(i));
            debug('min_fc_balance_percent	:	'||l_lc_cust_sites_tbl.min_fc_balance_percent(i));
            debug('min_interest_charge		:	'||l_lc_cust_sites_tbl.min_interest_charge(i));
            debug('max_interest_charge		:	'||l_lc_cust_sites_tbl.max_interest_charge(i));
            debug('interest_type		:	'||l_lc_cust_sites_tbl.interest_type(i));
            debug('interest_Rate		:	'||l_lc_cust_sites_tbl.interest_Rate(i));
            debug('interest_fixed_amount	:	'||l_lc_cust_sites_tbl.interest_fixed_amount(i));
            debug('interest_schedule_id		:	'||l_lc_cust_sites_tbl.interest_schedule_id(i));
            debug('penalty_type			:	'||l_lc_cust_sites_tbl.penalty_type(i));
            debug('penalty_rate			:	'||l_lc_cust_sites_tbl.penalty_rate(i));
            debug('penalty_fixed_amount		:	'||l_lc_cust_sites_tbl.penalty_fixed_amount(i));
            debug('penalty_schedule_id		:	'||l_lc_cust_sites_tbl.penalty_schedule_id(i));
            debug('last_accrue_charge_date	:	'||l_lc_cust_sites_tbl.last_accrue_charge_date(i));
          END LOOP;
        END IF;
        IF l_last_fetch_rows THEN
           EXIT;
        END IF;
   END LOOP;
   CLOSE customer_sites_cur;
END debug_cust_sites;

PROCEDURE debug_customer_balances IS
CURSOR cust_balance_cur IS
       select   org_id,
		customer_id,
                customer_site_use_id,
                currency_code,
                customer_open_balance,
                customer_overdue_balance
       from  ar_late_charge_cust_balance_gt
       order by org_id,
		customer_id,
                customer_site_use_id,
                currency_code;

TYPE l_cust_balance_type IS RECORD(
		org_id				DBMS_SQL.NUMBER_TABLE,
		customer_id			DBMS_SQL.NUMBER_TABLE,
                customer_site_use_id		DBMS_SQL.NUMBER_TABLE,
                currency_code			DBMS_SQL.VARCHAR2_TABLE,
                customer_open_balance		DBMS_SQL.NUMBER_TABLE,
                customer_overdue_balance	DBMS_SQL.NUMBER_TABLE);

l_cust_balance_tbl                 	l_cust_balance_type;
l_bulk_fetch_rows			number := 1000;
l_last_fetch_rows			boolean := FALSE;

BEGIN
   OPEN cust_balance_cur;
   LOOP
        FETCH cust_balance_cur BULK COLLECT INTO
            l_cust_balance_tbl
        LIMIT l_bulk_fetch_rows;

        IF cust_balance_cur%NOTFOUND THEN
            l_last_fetch_rows := TRUE;
        END IF;

        IF (l_cust_balance_tbl.customer_id.COUNT = 0) AND (l_last_fetch_rows) THEN
          debug('Customer Balances Cursor: ' || 'COUNT = 0 and LAST FETCH ');
          EXIT;
        END IF;

        IF l_cust_balance_tbl.customer_id.COUNT > 0 THEN
          debug('Balance Information of the selected customers');

          FOR i IN 1 .. l_cust_balance_tbl.customer_id.COUNT LOOP
            debug('==================================================');
            debug('org_id			:	'||l_cust_balance_tbl.org_id(i));
            debug('customer_id 			:	'||l_cust_balance_tbl.customer_id(i));
            debug('customer_site_use_id 	:	'||l_cust_balance_tbl.customer_site_use_id(i));
            debug('currency_code 		:	'||l_cust_balance_tbl.currency_code(i));
            debug('customer_open_balance	:	'||l_cust_balance_tbl.customer_open_balance(i));
            debug('customer_overdue_balance	:	'||l_cust_balance_tbl.customer_overdue_balance(i));
          END LOOP;
        END IF;
        IF l_last_fetch_rows THEN
           EXIT;
        END IF;
   END LOOP;
   CLOSE cust_balance_cur;

END debug_customer_balances;

PROCEDURE debug_credit_amts IS
CURSOR cust_credits_cur IS
       select   customer_id,
                customer_site_use_id,
                currency_code,
                legal_entity_id,
                credit_amount
       from ar_late_charge_credits_gt
       order by customer_id,
                customer_site_use_id,
                currency_code,
                legal_entity_id;

TYPE l_cust_credits_rec_type IS RECORD(
		customer_id		DBMS_SQL.NUMBER_TABLE,
                customer_site_use_id	DBMS_SQL.NUMBER_TABLE,
                currency_code		DBMS_SQL.VARCHAR2_TABLE,
                legal_entity_id		DBMS_SQL.NUMBER_TABLE,
                credit_amount		DBMS_SQL.NUMBER_TABLE);

l_cust_credits_tbl                 	l_cust_credits_rec_type;
l_bulk_fetch_rows			number := 1000;
l_last_fetch_rows			boolean := FALSE;

BEGIN
   OPEN cust_credits_cur;
   LOOP
        FETCH cust_credits_cur BULK COLLECT INTO
            l_cust_credits_tbl
        LIMIT l_bulk_fetch_rows;

        IF cust_credits_cur%NOTFOUND THEN
            l_last_fetch_rows := TRUE;
        END IF;

        IF (l_cust_credits_tbl.customer_id.COUNT = 0) AND (l_last_fetch_rows) THEN
          debug('Credits Cursor: ' || 'COUNT = 0 and LAST FETCH ');
          EXIT;
        END IF;

        IF l_cust_credits_tbl.customer_id.COUNT > 0 THEN
          debug('Credit Information of the selected customers');

          FOR i IN 1 .. l_cust_credits_tbl.customer_id.COUNT LOOP
            debug('==================================================');
            debug('customer_id 			:	'||l_cust_credits_tbl.customer_id(i));
            debug('customer_site_use_id 	:	'||l_cust_credits_tbl.customer_site_use_id(i));
            debug('currency_code 		:	'||l_cust_credits_tbl.currency_code(i));
            debug('legal_entity_id 		:	'||l_cust_credits_tbl.legal_entity_id(i));
            debug('credit amount 		:	'||l_cust_credits_tbl.credit_amount(i));
          END LOOP;
        END IF;
        IF l_last_fetch_rows THEN
           EXIT;
        END IF;
   END LOOP;
   CLOSE cust_credits_cur;
END debug_credit_amts;

PROCEDURE debug_payment_schedules IS
CURSOR payment_schedules_cur IS
        select   late_charge_trx_id,
                 customer_id,
                 customer_site_use_id,
                 currency_code,
                 customer_trx_id,
                 legal_entity_id,
                 payment_schedule_id,
                 class,
                 amount_due_original,
                 amount_due_remaining,
                 fin_charge_charged,
                 trx_date,
                 cust_trx_type_id,
                 last_charge_date,
                 exchange_rate_type,
                 min_interest_charge,
                 max_interest_charge,
                 overdue_late_pay_amount,
                 original_balance,
                 due_date,
                 receipt_date,
                 finance_charge_date,
                 charge_type,
                 actual_date_closed,
                 interest_rate,
                 interest_days,
                 rate_start_date,
                 rate_end_date,
                 schedule_days_start,
                 schedule_days_to,
                 late_charge_amount,
                 late_charge_type,
                 late_charge_term_id,
                 interest_period_days,
                 interest_calculation_period,
                 charge_on_finance_charge_flag,
                 message_text_id,
                 interest_type,
                 min_fc_invoice_overdue_type,
                 min_fc_invoice_amount,
                 min_fc_invoice_percent,
                 charge_line_type
       from ar_late_charge_trx_t
       order by customer_id,
                customer_site_use_id,
                currency_code,
                legal_entity_id,
                due_date,
                payment_schedule_id,
                rate_start_date,
                charge_line_type;

TYPE l_payment_schedules_rec_type IS RECORD(
		late_charge_trx_id		DBMS_SQL.NUMBER_TABLE,
		customer_id			DBMS_SQL.NUMBER_TABLE,
                customer_site_use_id		DBMS_SQL.NUMBER_TABLE,
                currency_code			DBMS_SQL.VARCHAR2_TABLE,
                customer_trx_id			DBMS_SQL.NUMBER_TABLE,
                legal_entity_id			DBMS_SQL.NUMBER_TABLE,
                payment_schedule_id		DBMS_SQL.NUMBER_TABLE,
                class				DBMS_SQL.VARCHAR2_TABLE,
                amount_due_original		DBMS_SQL.NUMBER_TABLE,
                amount_due_remaining		DBMS_SQL.NUMBER_TABLE,
                fin_charge_charged		DBMS_SQL.NUMBER_TABLE,
                trx_date			DBMS_SQL.DATE_TABLE,
                cust_trx_type_id		DBMS_SQL.NUMBER_TABLE,
                last_charge_date		DBMS_SQL.DATE_TABLE,
                exchange_rate_type		DBMS_SQL.VARCHAR2_TABLE,
                min_interest_charge		DBMS_SQL.NUMBER_TABLE,
                max_interest_charge		DBMS_SQL.NUMBER_TABLE,
                overdue_late_pay_amount		DBMS_SQL.NUMBER_TABLE,
                original_balance		DBMS_SQL.NUMBER_TABLE,
                due_date			DBMS_SQL.DATE_TABLE,
                receipt_date			DBMS_SQL.DATE_TABLE,
                finance_charge_date		DBMS_SQL.DATE_TABLE,
                charge_type			DBMS_SQL.VARCHAR2_TABLE,
                actual_date_closed		DBMS_SQL.DATE_TABLE,
                interest_rate			DBMS_SQL.NUMBER_TABLE,
                interest_days			DBMS_SQL.NUMBER_TABLE,
                rate_start_date			DBMS_SQL.DATE_TABLE,
                rate_end_date			DBMS_SQL.DATE_TABLE,
                schedule_days_start		DBMS_SQL.NUMBER_TABLE,
                schedule_days_to		DBMS_SQL.NUMBER_TABLE,
                late_charge_amount		DBMS_SQL.NUMBER_TABLE,
                late_charge_type		DBMS_SQL.VARCHAR2_TABLE,
                late_charge_term_id		DBMS_SQL.NUMBER_TABLE,
                interest_period_days		DBMS_SQL.NUMBER_TABLE,
                interest_calculation_period	DBMS_SQL.VARCHAR2_TABLE,
                charge_on_finance_charge_flag	DBMS_SQL.VARCHAR2_TABLE,
                message_text_id			DBMS_SQL.NUMBER_TABLE,
                interest_type			DBMS_SQL.VARCHAR2_TABLE,
                min_fc_invoice_overdue_type	DBMS_SQL.VARCHAR2_TABLE,
                min_fc_invoice_amount		DBMS_SQL.NUMBER_TABLE,
                min_fc_invoice_percent		DBMS_SQL.VARCHAR2_TABLE,
                charge_line_type		DBMS_SQL.VARCHAR2_TABLE);

l_payment_schedules_tbl                 l_payment_schedules_rec_type;
l_bulk_fetch_rows			number := 1000;
l_last_fetch_rows			boolean := FALSE;

BEGIN
   OPEN payment_schedules_cur;
   LOOP
        FETCH payment_schedules_cur BULK COLLECT INTO
            l_payment_schedules_tbl
        LIMIT l_bulk_fetch_rows;

        IF payment_schedules_cur%NOTFOUND THEN
            l_last_fetch_rows := TRUE;
        END IF;

        IF (l_payment_schedules_tbl.late_charge_trx_id.COUNT = 0) AND (l_last_fetch_rows) THEN
          debug('Payment Schedules Cursor: ' || 'COUNT = 0 and LAST FETCH ');
          EXIT;
        END IF;

        IF l_payment_schedules_tbl.late_charge_trx_id.COUNT > 0 THEN
          debug('Selected Payment schedule IDs and the details');

          FOR i IN 1 .. l_payment_schedules_tbl.late_charge_trx_id.COUNT LOOP
            debug('==================================================');
            debug('customer_id 			:	'||l_payment_schedules_tbl.customer_id(i));
            debug('customer_site_use_id 	:	'||l_payment_schedules_tbl.customer_site_use_id(i));
            debug('currency_code 		:	'||l_payment_schedules_tbl.currency_code(i));
            debug('customer_trx_id 		:	'||l_payment_schedules_tbl.customer_trx_id(i));
            debug('legal_entity_id 		:	'||l_payment_schedules_tbl.legal_entity_id(i));
            debug('payment_schedule_id 		:	'||l_payment_schedules_tbl.payment_schedule_id(i));
            debug('class 			:	'||l_payment_schedules_tbl.class(i));
            debug('amount_due_original 		:	'||l_payment_schedules_tbl.amount_due_original(i));
            debug('amount_due_remaining 	:	'||l_payment_schedules_tbl.amount_due_remaining(i));
            debug('fin_charge_charged 		:	'||l_payment_schedules_tbl.fin_charge_charged(i));
            debug('trx_date 			:	'||l_payment_schedules_tbl.trx_date(i));
            debug('cust_trx_type_id 		:	'||l_payment_schedules_tbl.cust_trx_type_id(i));
            debug('last_charge_date 		:	'||l_payment_schedules_tbl.last_charge_date(i));
            debug('exchange_rate_type 		:	'||l_payment_schedules_tbl.exchange_rate_type(i));
            debug('min_interest_charge 		:	'||l_payment_schedules_tbl.min_interest_charge(i));
            debug('max_interest_charge 		:	'||l_payment_schedules_tbl.max_interest_charge(i));
            debug('overdue_late_pay_amount 	:	'||l_payment_schedules_tbl.overdue_late_pay_amount(i));
            debug('original_balance 		:	'||l_payment_schedules_tbl.original_balance(i));
            debug('due_date 			:	'||l_payment_schedules_tbl.due_date(i));
            debug('receipt_date 		:	'||l_payment_schedules_tbl.receipt_date(i));
            debug('finance_charge_date 		:	'||l_payment_schedules_tbl.finance_charge_date(i));
            debug('charge_type 			:	'||l_payment_schedules_tbl.charge_type(i));
            debug('actual_date_closed 		:	'||l_payment_schedules_tbl.actual_date_closed(i));
            debug('interest_rate 		:	'||l_payment_schedules_tbl.interest_rate(i));
            debug('interest_days 		:	'||l_payment_schedules_tbl.interest_days(i));
            debug('rate_start_date 		:	'||l_payment_schedules_tbl.rate_start_date(i));
            debug('rate_end_date 		:	'||l_payment_schedules_tbl.rate_end_date(i));
            debug('schedule_days_start 		:	'||l_payment_schedules_tbl.schedule_days_start(i));
            debug('schedule_days_to 		:	'||l_payment_schedules_tbl.schedule_days_to(i));
            debug('late_charge_amount 		:	'||l_payment_schedules_tbl.late_charge_amount(i));
            debug('late_charge_type 		:	'||l_payment_schedules_tbl.late_charge_type(i));
            debug('late_charge_term_id 		:	'||l_payment_schedules_tbl.late_charge_term_id(i));
            debug('interest_period_days 	:	'||l_payment_schedules_tbl.interest_period_days(i));
            debug('interest_calculation_period 	:	'||l_payment_schedules_tbl.interest_calculation_period(i));
            debug('charge_on_finance_charge_flag:	'||l_payment_schedules_tbl.charge_on_finance_charge_flag(i));
            debug('message_text_id 		:	'||l_payment_schedules_tbl.message_text_id(i));
            debug('interest_type 		:	'||l_payment_schedules_tbl.interest_type(i));
            debug('min_fc_invoice_overdue_type 	:	'||l_payment_schedules_tbl.min_fc_invoice_overdue_type(i));
            debug('min_fc_invoice_amount 	:	'||l_payment_schedules_tbl.min_fc_invoice_amount(i));
            debug('min_fc_invoice_percent 	:	'||l_payment_schedules_tbl.min_fc_invoice_percent(i));
            debug('charge_line_type 		:	'||l_payment_schedules_tbl.charge_line_type(i));
          END LOOP;
        END IF;
        IF l_last_fetch_rows THEN
           EXIT;
        END IF;
   END LOOP;
   CLOSE payment_schedules_cur;

END debug_payment_schedules;
/*=========================================================================================+
 | PUBLIC PROCEDURE CREATE_LATE_CHARGE_DOCUMENT                                            |
 |                                                                                         |
 | DESCRIPTION                                                                             |
 |                                                                                         |
 |   This procedure is called from the concurrent program to generate late charges         |
 |   associated with overdue invoices or late payments                                     |
 |                                                                                         |
 | PSEUDO CODE/LOGIC                                                                       |
 |                                                                                         |
 | The whole logic can be split in the following way                                       |
 |   1)  Create Adjustments / Debit Memo                                                   |
 |       a) For Overdue and Average Daily Balance, the open credit items should be         |
 |          applied to the oldest invoice first                                            |
 |       b) For Late Payments, credit items need not be considered as we are tracking      |
 |          only the late applications                                                     |
 |   2)  Create Interest Invoices                                                          |
 |       Credit items should be treated as any other debit item. Interest and Penalty      |
 |       should be computed on these, but no tolerance applied                             |
 |                                                                                         |
 | General Notes:                                                                          |
 |                                                                                         |
 | 1. Hold Charged Invoices : Interest should be calculated only once on any item.         |
 |    How to determine this? 11i Interest Invoice feature uses ps.last_charge_date to      |
 |    store the last date on which interest is calculated on a payment_schedule. So if this|
 |    is populated, we can assume that Interest Invoice was created on this payment        |
 |    schedule. 11i AR Finance Charge functionality uses the field last_accrue_charge_date |
 |    in hz_cust_site_uses to store the last date on which Finance Charge was computed on  |
 |    the invoices of a given customer site use. Such finance charges will be created as   |
 |    Adjustments and can be derived from ar_adjustments. If any of these two conditions   |
 |    are satisfied, the payment_schedule is treated as if Interest was computed on it.    |
 |    If hold_charged_invoices_flag = 'Y' then                                             |
 |       ps.last_charge_date should be NULL                                                |
 |       AND fin_charge_charged should be Zero                                             |
 |    for a payment schedule to become eligibale for finance charge computation            |
 |                                                                                         |
 | 2. Calculation of days late: While fetching the eligible items, the payment_grace_days  |
 |    should be added to the due_date. But if the item has crossed the due_date +          |
 |    payment_grace_days, the days_late should be computed from the original due_date      |
 |    without considering the payment_grace_days                                           |
 |                                                                                         |
 | 3. Use Multiple Interest Rates : If this option is selected, and there are multiple     |
 |    interest rates applicable during the period from the due_date to the finance charge  |
 |    date, the interest will be calculated using all the applicable rates considering the |
 |    corresponding days. This option is used only if the Interest is defined as a         |
 |    percentage rate. If fixed amounts are applicable during this period, only the rate   |
 |    applicable as of the finance charge date is considered. If this option is unchecked, |
 |    the rate / amount applicable as of the finance charge date is considered.            |
 |    It is also to be noted that the multiple interest rates are used only for the        |
 |    interest computation and not for the penalty computation                             |
 |                                                                                         |
 | 4. For Receipts, the maturity_date is stored in the column due_date in payment schedules|
 |    So, the receipt date should be considered instead of the due_date for receipts       |
 |                                                                                         |
 | 5. If the interest definition is to use amount and not rate (either as fixed amount or  |
 |    as a schedule), and we are computing interest on a credit item, the interest amount  |
 |    should be multiplied by -1.                                                          |
 |                                                                                         |
 | 6. Simple Vs. Compound Interest : If Compound Interest has to be computed, the balance  |
 |    can be computed based on the amount_due_remaining in payment schedules. Otherwise,the|
 |    previously charged finance charge has to be deducted from amount_due_remaining. This |
 |    is the case the finance charges were created as Adjustments.                         |
 |    If we are creating interest invoices or Debit memos, then we have separate documents |
 |    having their own due dates. So these will always have interest on them - and this is |
 |    compound interest. We wouldn't compound the amount onto the original transaction     |
 |    because we have created a new transaction and we are charging the additional interest|
 |    on that.So to have simple interest, you would have to ensure that the interest       |
 |    invoice transaction type was excluded from finance charges - so that interest is not |
 |    calculated on the interest.                                                          |
 |                                                                                         |
 | 7. Penalty is computed on the computed Interest                                         |
 |                                                                                         |
 | 8. Tolerances are applied only on the Interest and not on the Penalty. i.e.Penalty is   |
 |    is levied regardless of the maximum tolerances. Only the interest charge is validated|
 |    against the maximum charge tolerances                                                |
 |                                                                                         |
 | 9. Interest Calculation Period : Daily Vs Monthly                                       |
 |    While using Daily method, the interest will be calculated exactly on the number of   |
 |    days between the due date and the finance charge date. On the other hand, if Monthly |
 |    method is used, interest will be calculated for the number of days between the first |
 |    day of the month corresponding to due_date to the last day of the month corresponding|
 |    to the finance_charge_date                                                           |
 |                                                                                         |
 |10. Application of Tolerances                                                            |
 |    1. Customer Level Tolerances : This could be a fixed amount or a Percentage          |
 |       Since this set up is done at profile amount level, this is applicable for a       |
 |       customer, site and currency combination.                                          |
 |       a) Fixed Amount :  If the set up is Amount, it means that the customer should be  |
 |          charged an interest only if the total overdue balance for this customer, site  |
 |          and currency combination is greater than or equal to the amount mentioned in   |
 |          the set up.                                                                    |
 |       b) Percentage : This means that, the customer should be changed an interest only  |
 |          if the total overdue balance for this customer , site and currency combination |
 |          is greater than or equal to the given percentage of the total open balance for |
 |          this customer, site and currency combination.                                  |
 |       Overdue Balance : Is the sum of balances of the debit and credit items which are  |
 |       past due as of the finance charge date. These balances will be computed as of the |
 |       finance charge date                                                               |
 |       Open Balance : Is the sum of balances of the debit and credit items which are open|
 |       as of the finance charge date. These balances will be computed as of the finance  |
 |       charge date                                                                       |
 |       These computations are similar for Overdue Invoices and Late Payments. But for    |
 |       Average Daily Balance, the application of tolerances are completely differemt.    |
 |       For Overdue Invoices and Late Payments, consider the following example:           |
 |       Customer xyz has the following invoices                                           |
 |                                                                                         |
 |         a) invoice 101 for 1000 USD with trx_date of 01-Dec-2005 and due_date of        |
 |            01-Jan-2006.  There are  receipt applications on this invoice on 15-Jan-2006 |
 |            for 400 USD and  10-Feb-2006 for 600 USD                                     |
 |         b) Invoice 102 for 2000 USD with a trx_date of 01-Jan-2006 and due_date of      |
 |            01-Feb-2006. There are no applications on this invoice.                      |
 |                                                                                         |
 |       We are calculating the finance charge as of  31-Jan-2006. As of this date, the    |
 |       invoice 101 is overdue by 600 USD, where as the invoice 102 is open (but not      |
 |       overdue) by 2000 USD. So the overdue balance will be 600 USD and the open balance |
 |       will be 2600 USD.                                                                 |
 |                                                                                         |
 |    2. Invoice Level Tolerances :  Similar to the case above. Instead of the overdue     |
 |       customer balance, the overdue invoice amount will be used. Instead of the Open    |
 |       customer balance, the original invoice amount will be used (amount_due_original   |
 |       from ar_payment_schedules).                                                       |
 |                                                                                         |
 |       In my example above, as of 31-Jan-2006,  the invoice 101 is overdue by 600 USD and|
 |       the original invoice amount is 1000 USD . So 60% of this invoice is overdue as of |
 |       this date. Invoice 102 will not be considered as it is not overdue.               |
 |                                                                                         |
 |    3. Min and Max Interest Charges: These tolerances will be applied after the interest |
 |       is calculated. These will be applied only on the interest charged and not on the  |
 |       penalty. If the interest is less than the Min Interest Charge, no Interest or     |
 |       Penalty Records will be created for this Payment schedule. On the other hand, if  |
 |       the interest is more than the Max Interest Charge, the Interest portion will be   |
 |       limited to the maximum amount, but the Penalty will be computed on the actual     |
 |       Interest Charge.                                                                  |
 |       For example, the maximum interest is defined as 1000. The following interest      |
 |       charges and penalty cahrges are computed on a single payment schedule             |
 |       interest        interest_days    rate_start_date      rate_end_date    type       |
 |       --------        -------------    --------------      --------------   ------      |
 |        40.00             4             7-JUN-2005           10-JUN-2005      INTEREST   |
 |        60.00             5            11-JUN-2005           15-JUN-2005      INTEREST   |
 |        1320.00          240           16-JUN-2005                            INTEREST   |
 |        106.00           249           07-JUN-2005           10-JUN-2005      PENALTY    |
 |                                                                                         |
 |        After the application of the maximum interest tolerances, the following Interest |
 |        and penalty lines will be created                                                |
 |       interest        interest_days    rate_start_date      rate_end_date    type       |
 |       --------        -------------    --------------      --------------   ------      |
 |        40.00             4             7-JUN-2005           10-JUN-2005      INTEREST   |
 |        60.00             5            11-JUN-2005           15-JUN-2005      INTEREST   |
 |        900.00           240           16-JUN-2005                            INTEREST   |
 |        106.00           249           07-JUN-2005           10-JUN-2005      PENALTY    |
 |                                                                                         |
 | PARAMETERS                                                                              |
 |                                                                                         |
 |                                                                                         |
 | KNOWN ISSUES                                                                            |
 |                                                                                         |
 | NOTES                                                                                   |
 |                                                                                         |
 | MODIFICATION HISTORY                                                                    |
 | Date                  Author            Description of Changes                          |
 | 22-DEC-2005           rkader            Created                                         |
 |                                                                                         |
 *=========================================================================================*/

PROCEDURE create_late_charge_document
			(errbuf                 OUT NOCOPY VARCHAR2,
			 retcode                OUT NOCOPY NUMBER,
                         p_operating_unit_id	IN	VARCHAR2,
                         p_customer_name_from   IN      VARCHAR2,
                         p_customer_name_to     IN      VARCHAR2,
                         p_customer_num_from    IN 	VARCHAR2,
                         p_customer_num_to      IN	VARCHAR2,
                         p_cust_site_use_id     IN      VARCHAR2,
                         p_gl_date              IN      VARCHAR2,
                         p_fin_charge_date      IN      VARCHAR2,
                         p_currency_code        IN      VARCHAR2,
                         p_mode			IN	VARCHAR2,
			 p_disputed_items	IN	VARCHAR2,
                         p_called_from          IN      VARCHAR2,
                         p_enable_debug         IN      VARCHAR2,
                         p_worker_number        IN      VARCHAR2,
                         p_total_workers        IN      VARCHAR2,
			 p_master_request_id	IN	VARCHAR2) IS

   l_org_id				 number(15);
   l_mode				 varchar2(1);
   l_customer_name_from  		 hz_parties.party_name%type;
   l_customer_name_to   		 hz_parties.party_name%type;
   l_customer_number_from                hz_cust_accounts.account_number%type;
   l_customer_number_to			 hz_cust_accounts.account_number%type;
   l_cust_site_use_id                    number;
   l_fin_charge_date                     date;
   l_gl_date                             date;
   l_compute_late_charge		 varchar2(1);
   l_currency_code			 varchar2(15);
   l_customer_id			 number;
   l_site_use_id			 number;
   l_set_of_books_id                     number;
   l_count_int_lines			 number;
   l_worker_number			 number;
   l_total_workers			 number;
   l_num_batches			 number;
   l_err_flag				 boolean := FALSE;
BEGIN

   l_debug_flag 	:=	p_enable_debug;

   IF l_debug_flag = 'Y' THEN
        debug('ar_calc_late_charge.create_late_charge_document()+ ');
        debug('Global package variables');
        debug('pg_last_updated_by	: '||pg_last_updated_by);
	debug('pg_last_update_login	: '||pg_last_update_login);
   END IF;

   IF l_debug_flag = 'Y' THEN
        debug('Input Parameters: ');
        debug('p_operating_unit_id   : '||p_operating_unit_id);
        debug('p_customer_name_from  : '||p_customer_name_from);
        debug('p_customer_name_to    : '||p_customer_name_to);
        debug('p_customer_number_from: '||p_customer_num_from);
        debug('p_customer_number_to  : '||p_customer_num_to);
        debug('p_site_use_id         : '||p_cust_site_use_id);
        debug('p_gl_date             : '||p_gl_date);
        debug('p_fin_charge_date     : '||p_fin_charge_date);
        debug('p_mode                : '||p_mode);
        debug('p_disputed_items      : '||p_disputed_items);
        debug('p_called_from         : '||p_called_from);
        debug('p_enable_debug        : '||p_enable_debug);
        debug('p_worker_number	     : '||p_worker_number);
        debug('p_total_workers       : '||p_total_workers);
 	debug('p_master_request_id   : '||p_master_request_id);
   END IF;

   l_org_id		      :=   p_operating_unit_id;
   l_customer_name_from       :=   p_customer_name_from;
   l_customer_name_to         :=   p_customer_name_to;
   l_customer_number_from     :=   p_customer_num_from;
   l_customer_number_to       :=   p_customer_num_to;
   l_cust_site_use_id         :=   p_cust_site_use_id;
   l_currency_code	      :=   p_currency_code;
   l_fin_charge_date          :=   fnd_date.canonical_to_date(p_fin_charge_date);
   l_gl_date                  :=   fnd_date.canonical_to_date(p_gl_date);
   l_mode		      :=   p_mode;
   l_disputed_items	      :=   p_disputed_items;
   l_worker_number	      :=   p_worker_number;
   l_total_workers            :=   p_total_workers;
   l_request_id		      :=   p_master_request_id; /* The master_request_id should be used for further processing */

   IF l_debug_flag  ='Y' THEN
      debug('Request ID 	:  '||l_request_id);
   END IF;

/*
     select count(*)
     into l_num_batches
     from ar_interest_batches
     where request_id = l_request_id;
     debug('Number of batches found in ar_interest_batches for this request :  '||l_num_batches);
*/

   /* Check if late_charge calculation is enabled in system options */
   IF l_org_id IS NOT NULL THEN
      select allow_late_charges, set_of_books_id
      into   l_compute_late_charge, l_set_of_books_id
      from   ar_system_parameters
      where  org_id = l_org_id ;
      IF l_debug_flag = 'Y' THEN
         debug('Running the Program for a single Operating Unit');
         debug('Late Charge option in System Options 	: '||l_compute_late_charge);
    	 debug('Set of Books ID				: '||l_set_of_books_id);
      END IF;
   ELSE
      l_compute_late_charge := 'Y';
      IF l_debug_flag = 'Y' THEN
         debug('Running the program for multiple Operating Units, setting l_compute_late_charge to Y');
      END IF;
   END IF;

    /* Calculate interest only if the compute_late_charge is enabled in system
       options and there are no other batch with this name */
   IF l_compute_late_charge = 'Y'  THEN

        /* Identify the eligible customers, sites and the corresponding late charge policy
           set up */

         get_cust_late_charge_policy(p_org_id			=>	l_org_id,
     				     p_fin_charge_date		=>	l_fin_charge_date,
				     p_customer_name_from	=>	l_customer_name_from,
				     p_customer_name_to		=>	l_customer_name_to,
				     p_customer_number_from	=>	l_customer_number_from,
				     p_customer_number_to	=>	l_customer_number_to,
				     p_currency_code		=>	l_currency_code,
				     p_cust_site_use_id		=>	l_cust_site_use_id,
				     p_worker_number		=>	l_worker_number,
				     p_total_workers		=>	l_total_workers);

        /* Populate the table ar_late_charge_cust_balance_gt with the customer open balance
           and customer overdue balance for all the selected customer, site ,currency_code
           and org combination */

          insert_cust_balances(p_as_of_date         =>      l_fin_charge_date,
                               p_worker_number      =>      l_worker_number,
                               p_total_workers      =>      l_total_workers);

        /* If the late charge document is Adjustment or Debit Memo, the credit amount is summed
           up and inserted into ar_late_charge_credits_gt . These amounts should later be adjusted
           against the open debit items in the order of oldest invoice first.*/

         insert_credit_amount(p_fin_charge_date		=> 	l_fin_charge_date,
 			      p_worker_number           =>      l_worker_number,
                              p_total_workers           =>      l_total_workers);

        /* Overdue Invoices if Adjustment and Debit Memo have to be created.
           In this case, the overdue invoices are first applied against the credit amounts
           with the oldest invoice first. Oldest here means, the debit item having the oldest
           due date. The Interest is then calculated on the remaining balances  */

         insert_int_overdue_adj_dm(p_fin_charge_date	=>	l_fin_charge_date,
				   p_worker_number      =>      l_worker_number,
				   p_total_workers      =>      l_total_workers);

        /* Overdue Invoices if Interest Invoices  have to be created.
           In this case, the Credit items are treated similar to Debit Items.
           Interest is calculated on the credit items as done for debit items. */

         insert_int_overdue_inv(p_fin_charge_date	=> 	l_fin_charge_date,
			        p_worker_number         =>      l_worker_number,
                                p_total_workers         =>      l_total_workers);

	/*Bug 8556955 call to insert reversed receipt late charges*/
         Insert_int_rev_rect_overdue(p_fin_charge_date       =>     l_fin_charge_date,
                                     p_worker_number         =>     l_worker_number,
                                     p_total_workers         =>     l_total_workers);

        /* Late Payments : If the charge calculation is based on Late Payments, the processing is the
           same irrespective of the document to be created, as credit items are not considered */

         insert_int_late_pay(p_fin_charge_date		=>	l_fin_charge_date,
                             p_worker_number            =>      l_worker_number,
                             p_total_workers            =>      l_total_workers);

        /* Average Daily Balance */

         insert_int_avg_daily_bal(p_fin_charge_date     =>	l_fin_charge_date,
                                  p_worker_number    	=>	l_worker_number,
				  p_total_workers	=>	l_total_workers);

         /* Enhacement 6469663*/
         update_interest_amt('INTEREST');
        /* Calculate Penalty : There will be only one Penalty per payment schedule. It is either
           a fixed amount or a rate multiplied by the Interest */

         insert_penalty_lines(p_worker_number       =>      l_worker_number,
                              p_total_workers       =>      l_total_workers);
         /* Enhacement 6469663*/
         update_interest_amt('PENALTY');
        /* If there are records in  ar_late_charge_trx_t, insert data into the preview tables
           ar_interest_batches, ar_interest_headers and ar_interest_lines */

        select count(*)
        into   l_count_int_lines
        from   ar_late_charge_trx_t;

        debug('Number of records in the interim transactions table : '|| l_count_int_lines);

        IF l_count_int_lines > 0 THEN

           /* If debug flag is set, dump the data from the interim tables to the log file */
           IF l_debug_flag = 'Y' THEN
               debug_cust_sites;
               debug_customer_balances;
               debug_credit_amts;
               debug_payment_schedules;
           END IF;

           /* Before inserting data into the preview tables, we will delete all the existing
              Draft batches for this customer,site, currency, legal entity and org combination */

              delete_draft_batches(p_worker_number       =>      l_worker_number,
	                           p_total_workers       =>      l_total_workers);

           /* Batch can not be created here. We need one batch per OU. So the workers which are
            processing the sites can not handle it */

          /*  insert_int_batches(p_batch_name		=>	l_batch_name,
    	            	     p_fin_charge_date		=>	l_fin_charge_date,
        	             p_batch_status		=>	l_mode,
                	     p_gl_date			=>	l_gl_date); */

	    BEGIN
		    insert_int_lines(p_worker_number      	 =>      l_worker_number,
				     p_total_workers       	 =>      l_total_workers);

		    insert_int_lines_adb(p_worker_number         =>      l_worker_number,
					 p_total_workers         =>      l_total_workers);

		    insert_int_headers(p_fin_charge_date	 =>      l_fin_charge_date,
				       p_worker_number       	 =>      l_worker_number,
				       p_total_workers       	 =>      l_total_workers);
	    EXCEPTION
	    WHEN OTHERS THEN
	    	ROLLBACK;
	    	l_err_flag := TRUE;
	    END;

            /* delete the data in the interim tables before commit */
            delete from ar_lc_cust_sites_t;

            delete from ar_late_charge_trx_t;

            COMMIT;

           /* If the program is run in Final Mode, invoke the api call so that the final
              documents are created in AR */
           IF l_mode = 'F' AND l_err_flag = FALSE THEN
              ar_late_charge_pkg.ordonancer_per_worker
					( p_worker_num	=>	l_worker_number,
					  p_request_id	=>	l_request_id);
              COMMIT;
           END IF;

        ELSE
           /* If debug flag is set, dump the data from the interim tables to the log file */
           IF l_debug_flag = 'Y' THEN
               debug_cust_sites;
               debug_customer_balances;
               debug_credit_amts;
               debug_payment_schedules;
           END IF;
            /* delete the data in the interim tables before commit */
            delete from ar_lc_cust_sites_t;

            delete from ar_late_charge_trx_t;
        END IF;


   END IF;

   retcode := 0;

   IF l_debug_flag = 'Y' THEN
        debug('ar_calc_late_charge.create_late_charge_document()- ');
   END IF;
EXCEPTION WHEN OTHERS THEN
 /* delete the data in the interim tables before commit */
    delete from ar_lc_cust_sites_t;

    delete from ar_late_charge_trx_t;

END create_late_charge_document;

/*========================================================================+
  The wraper to parallelize the late charge document generation
 ========================================================================*/
PROCEDURE generate_late_charge
                        (errbuf                 OUT NOCOPY VARCHAR2,
                         retcode                OUT NOCOPY NUMBER,
                         p_operating_unit_id    IN      VARCHAR2,
                         p_customer_id_from     IN      VARCHAR2,
                         p_customer_id_to       IN      VARCHAR2,
                         p_customer_num_from    IN      VARCHAR2,
                         p_customer_num_to      IN      VARCHAR2,
                         p_cust_site_use_id     IN      VARCHAR2,
                         p_gl_date              IN      VARCHAR2,
                         p_fin_charge_date      IN      VARCHAR2,
                         p_currency_code        IN      VARCHAR2,
                         p_mode                 IN      VARCHAR2,
                         p_disputed_items       IN      VARCHAR2,
                         p_called_from          IN      VARCHAR2,
                         p_enable_debug         IN      VARCHAR2,
                         p_total_workers        IN      VARCHAR2) IS
   l_worker_number		NUMBER ;
   l_req_id			NUMBER;
   l_rep_req_id		        NUMBER := 0;
   l_batch_name			ar_interest_batches.batch_name%type;
   l_customer_name_from         hz_parties.party_name%TYPE;
   l_customer_name_to           hz_parties.party_name%TYPE;
   l_late_charge_batch		VARCHAR2(100);
   l_fin_charge_date		DATE;
   l_gl_date			DATE;
   l_req_data			VARCHAR2(2000);
   l_num_batches	 	NUMBER;
   l_complete			BOOLEAN := FALSE;
   l_min_workers		CONSTANT NUMBER := 1;
   l_max_workers		CONSTANT NUMBER := 15;
   l_total_workers		NUMBER;
   l_xml_output                 BOOLEAN;
   l_iso_language               FND_LANGUAGES.iso_language%TYPE;
   l_iso_territory              FND_LANGUAGES.iso_territory%TYPE;


   TYPE req_status_typ  IS RECORD (
         request_id       NUMBER(15),
         dev_phase        VARCHAR2(255),
         dev_status       VARCHAR2(255),
         message          VARCHAR2(2000),
         phase            VARCHAR2(255),
         status           VARCHAR2(255));

   TYPE req_status_tab_typ   IS TABLE OF req_status_typ INDEX BY BINARY_INTEGER;

   l_req_status_tab   req_status_tab_typ;

   PROCEDURE submit_subrequest (p_worker_number IN NUMBER) IS
   BEGIN
      --
       debug('submit_subrequest()+');
       debug('l_customer_name_from	:	'|| l_customer_name_from);
       debug('l_customer_name_to	:	'|| l_customer_name_to);
       l_req_id := FND_REQUEST.submit_request('AR','ARCALATE',
                                 '',
                                 SYSDATE,
                                 FALSE,
                                 p_operating_unit_id,
                                 l_customer_name_from,
                                 l_customer_name_to,
                                 p_customer_num_from,
                                 p_customer_num_to,
                                 p_cust_site_use_id,
                                 p_gl_date,
                                 p_fin_charge_date,
                                 p_currency_code,
                                 p_mode,
                                 p_disputed_items,
                                 p_called_from,
                                 p_enable_debug,
                                 p_worker_number,
                                 l_total_workers,
                                 l_request_id
                                  );
        IF (l_req_id = 0) THEN
            debug('can not start for worker_id: ' ||p_worker_number );
            errbuf := fnd_Message.get;
            retcode := 2;
            return;
        ELSE
            commit;
            l_req_data := l_req_data ||l_req_id;
            debug('child request id: ' ||l_req_id || ' started for worker_id: ' ||p_worker_number );
        END IF;

         IF p_worker_number < p_total_workers THEN
            l_req_data := l_req_data || ',';
         END IF;

         l_req_status_tab(p_worker_number).request_id := l_req_id;

         debug('submit_subrequest()-');

      END submit_subrequest;

BEGIN
   l_debug_flag       :=      p_enable_debug;

   l_req_data   :=   fnd_conc_global.request_data;

   l_req_status_tab.DELETE;

   IF (l_req_data is null) THEN -- first run
       debug('generate_late_charge()+');
       debug('total workers : ' || p_total_workers );
       BEGIN
          IF p_customer_id_from IS NOT NULL THEN
             select  hp.party_name
             into    l_customer_name_from
             from    hz_parties hp,
		     hz_cust_accounts cust_acct
            where    hp.party_id = cust_acct.party_id
              and    cust_acct.cust_account_id = p_customer_id_from;
          ELSE
             l_customer_name_from := Null;
          END IF;
       EXCEPTION WHEN NO_DATA_FOUND THEN
             l_customer_name_from := NULL;
       END;

       debug('p_customer_id_from  : ' ||p_customer_id_from ||',	l_customer_name_from  : '|| l_customer_name_from);

       BEGIN
          IF p_customer_id_to IS NOT NULL THEN
             select  hp.party_name
             into    l_customer_name_to
             from    hz_parties hp,
   		     hz_cust_accounts cust_acct
             where   hp.party_id = cust_acct.party_id
              and    cust_acct.cust_account_id = p_customer_id_to;
          ELSE
             l_customer_name_to := Null;
          END IF;
       EXCEPTION WHEN NO_DATA_FOUND THEN
             l_customer_name_from := NULL;
       END;

       debug('p_customer_id_to  : ' ||p_customer_id_to ||',	l_customer_name_to  : '|| l_customer_name_to);

       l_request_id	          :=   fnd_global.conc_request_id;
       l_fin_charge_date          :=   fnd_date.canonical_to_date(p_fin_charge_date);
       l_gl_date                  :=   fnd_date.canonical_to_date(p_gl_date);

       IF l_batch_name IS NULL THEN
          select meaning
          into   l_late_charge_batch
          from   ar_lookups
          where  lookup_type = 'AR_LATE_CHARGE_LABELS'
          and   lookup_code = 'LATE_CHARGE_BATCH';

          l_batch_name := l_late_charge_batch;

          IF l_debug_flag  ='Y' THEN
              debug('l_batch_name derived           : '||l_batch_name);
          END IF;
       END IF;

       /* Insert one batch per OU. Since the processing is done by multiple workers,
          the batch is created first */
       insert_int_batches(p_operating_unit_id	     =>	     p_operating_unit_id,
 		   	  p_batch_name               =>      l_batch_name,
                          p_fin_charge_date          =>      l_fin_charge_date,
                          p_batch_status             =>      p_mode,
                          p_gl_date                  =>      l_gl_date,
                          p_request_id		     =>      l_request_id);
       COMMIT;

       /* Lock all the batches created now */
       lock_batches;

       select count(*)
       into l_num_batches
       from ar_interest_batches
       where request_id = l_request_id;

       debug('Number of batches created = '||l_num_batches);

       IF nvl(p_total_workers,0) < l_min_workers THEN
          l_total_workers	:=  l_min_workers;
       ELSIF p_total_workers > l_max_workers THEN
          l_total_workers	:=  l_max_workers;
       ELSE
          l_total_workers	:=  p_total_workers;
       END IF;

       FOR l_worker_number in 1..l_total_workers LOOP

           debug('worker # : ' || l_worker_number );

           submit_subrequest (l_worker_number);

       END LOOP;

       --fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
         --                              request_data => to_char(l_req_id));

       debug('The Master program waits for child processes');

       -- Wait for the completion of the submitted requests

       FOR i in 1..l_total_workers LOOP
           l_complete := FND_CONCURRENT.WAIT_FOR_REQUEST(
                       request_id=>l_req_status_tab(i).request_id,
                       interval=>30,
                       max_wait=>144000,
                       phase=>l_req_status_tab(i).phase,
                       status=>l_req_status_tab(i).status,
                       dev_phase=>l_req_status_tab(i).dev_phase,
                       dev_status=>l_req_status_tab(i).dev_status,
                       message=>l_req_status_tab(i).message);

          IF l_req_status_tab(i).dev_phase <> 'COMPLETE' THEN
               retcode := 2;
               debug('Worker # '|| i||' has a phase '||l_req_status_tab(i).dev_phase);
          ELSIF l_req_status_tab(i).dev_phase = 'COMPLETE'
                   AND l_req_status_tab(i).dev_status <> 'NORMAL' THEN
               retcode := 2;
               debug('Worker # '|| i||' completed with status '||l_req_status_tab(i).dev_status);
          ELSE
               debug('Worker # '|| i||' completed successfully');
          END IF;

       END LOOP;

   END IF;

     /* We have one interest batch per OU. Delete all empty batches */

     delete_empty_batches;

     /* If the mode is Final, update the column transferred_status in ar_interest_bacthes
           a) Update the transferred_status to S if  the process_status of all the header
              records corresponding to a given batch is S
           b) Else the transferred_status should be E */

     IF p_mode = 'F' THEN
         update ar_interest_batches bat
         set    bat.transferred_status = 'S'
         where  not exists (select hdr.interest_header_id
                            from ar_interest_headers hdr
                            where bat.interest_batch_id = hdr.interest_batch_id
                            and hdr.process_status <> 'S')
         and bat.request_id = l_request_id;

         update ar_interest_batches bat
         set    bat.transferred_status = 'E'
         where exists (select hdr.interest_header_id
                       from ar_interest_headers hdr
                       where bat.interest_batch_id = hdr.interest_batch_id
                       and hdr.process_status <> 'S')
         and bat.request_id = l_request_id;
     END IF;

     l_req_data := fnd_conc_global.request_data;

     IF l_req_data IS NULL THEN
        /* Call the late charges report */
        SELECT lower(iso_language),iso_territory
        INTO l_iso_language,l_iso_territory
        FROM FND_LANGUAGES
        WHERE language_code = USERENV('LANG');

        l_xml_output:=  fnd_request.add_layout(
      			      template_appl_name  => 'AR',
		              template_code       => 'ARLCRPT',
	  	              template_language   => l_iso_language,
		              template_territory  => l_iso_territory,
		              output_format       => 'PDF'
		            );

        l_rep_req_id :=  FND_REQUEST.SUBMIT_REQUEST (
                                application=>'AR',
                                program=>'ARLCRPT',
                                sub_request=>TRUE,
                                argument1=>l_request_id,
                                argument2=>NULL
                            ) ;
        IF l_debug_flag ='Y'  THEN
           debug('Submitted Late Charge Report, Request Id :' || l_rep_req_id);
        END IF;

        fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                        request_data => to_char(l_rep_req_id));

     END IF;

     commit;

     retcode := 0 ;
     debug('generate_late_charge()-');

EXCEPTION
  WHEN OTHERS THEN
    RAISE ;

END generate_late_charge;


BEGIN
  /* Variables Intialization section */
  /* WHO columns */
  pg_last_updated_by        :=  arp_global.last_updated_by;
  pg_last_update_login      :=  arp_global.last_update_login;
--  l_debug_flag	 	    := 	'Y'; /* Enable Debug now */

END AR_CALC_LATE_CHARGE;

/
