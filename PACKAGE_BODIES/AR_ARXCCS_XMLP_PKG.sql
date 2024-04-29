--------------------------------------------------------
--  DDL for Package Body AR_ARXCCS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXCCS_XMLP_PKG" AS
/* $Header: ARXCCSB.pls 120.0 2007/12/27 13:38:59 abraghun noship $ */

function BeforeReport return boolean is


l_ld_sp varchar2(1);
begin

/*SRW.USER_EXIT('FND SRWINIT');*/null;



rp_message:=null;
IF to_number(p_reporting_level) = 1000 THEN
l_ld_sp:= mo_utils.check_ledger_in_sp(TO_NUMBER(p_reporting_entity_id));

IF l_ld_sp = 'N' THEN
     FND_MESSAGE.SET_NAME('FND','FND_MO_RPT_PARTIAL_LEDGER');
     rp_message:= FND_MESSAGE.get;
END IF;
END IF;



     get_boiler_plates ;


     rp_unavailable:= ARP_STANDARD.FND_MESSAGE('AR_REPORTS_UNAVAILABLE');
     rp_years:= ARP_STANDARD.FND_MESSAGE('AR_REPORTS_YEARS');
     rp_none:= ARP_STANDARD.FND_MESSAGE('AR_REPORTS_NONE');
     rp_na_upper:= ARP_STANDARD.FND_MESSAGE('AR_REPORTS_NA_UPPER');
     rp_no_limit:= ARP_STANDARD.FND_MESSAGE('AR_REPORTS_NO_LIMIT');

  get_bucket_data;

  return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function report_nameformula(Company_Name in varchar2) return varchar2 is
     l_report_name        VARCHAR2(240);
BEGIN


     RP_Company_Name:= Company_Name;

     SELECT cp.user_concurrent_program_name
     INTO   l_report_name
     FROM   FND_CONCURRENT_PROGRAMS_VL cp,
            FND_CONCURRENT_REQUESTS cr
     WHERE  cr.request_id = P_CONC_REQUEST_ID
     AND    cp.application_id = cr.program_application_id
     AND    cp.concurrent_program_id = cr.concurrent_program_id;

    RP_Report_Name:= l_report_name;

    RETURN(l_report_name);

RETURN NULL; EXCEPTION
    WHEN NO_DATA_FOUND THEN
         RP_REPORT_NAME:= NULL;
         RETURN(NULL);
END;

function c_address_ageformula(address_age in number) return varchar2 is
begin

/*srw.reference (address_age);*/null;

if address_age is NULL then
  return (rp_unavailable);
else
  return ( to_char(address_age)|| ' ' || rp_years);
end if ;
RETURN NULL; end;

function c_customer_ageformula(customer_age in number) return varchar2 is
begin

/*srw.reference  (customer_age);*/null;

if customer_age is NULL then
  return (rp_unavailable);
else
  return ( to_char(customer_age)||' ' || rp_years);
end if ;
RETURN NULL; end;

function c_city_state_zipformula(city in varchar2, state in varchar2, postal_code in varchar2) return varchar2 is
begin

/*srw.reference (city);*/null;

/*srw.reference (state);*/null;

/*srw.reference  (postal_code);*/null;

return (city|| ' , '||state||'  '||postal_code);
end;

function C_CALC_PERCENTFormula(aging_balance_outstanding in number,total_cust_b0 in number,total_cust_b1 in number,total_cust_b2 in number,total_cust_b3 in number,total_cust_b4 in number,total_cust_b5 in number,total_cust_b6 in number) return Number is
begin

DECLARE
l_percent    VARCHAR2 (100);
BEGIN
/*srw.reference (aging_balance_outstanding);*/null;

/*srw.reference (total_cust_b0);*/null;

/*srw.reference (total_cust_b1);*/null;

/*srw.reference (total_cust_b2);*/null;

/*srw.reference (total_cust_b3);*/null;

/*srw.reference (total_cust_b4);*/null;

/*srw.reference (total_cust_b5);*/null;

/*srw.reference (total_cust_b6);*/null;


c_percent_b0:= '';
c_percent_b1:= '';
c_percent_b2:= '';
c_percent_b3:= '';
c_percent_b4:= '';
c_percent_b5:= '';
c_percent_b6:= '';


if nvl(aging_balance_outstanding,0) = 0
   then
        c_percent_b0:= '.00';
        c_percent_b1:= '.00';
        c_percent_b2:= '.00';
        c_percent_b3:= '.00';
        c_percent_b4:= '.00';
        c_percent_b5:= '.00';
        c_percent_b6:= '.00';
   else
        c_percent_b0 := to_char((total_cust_b0 * 100)/(aging_balance_outstanding),'990.00');
        c_percent_b1 := to_char((total_cust_b1 * 100)/(aging_balance_outstanding),'990.00');
        c_percent_b2 := to_char((total_cust_b2 * 100)/(aging_balance_outstanding),'990.00');
        c_percent_b3 := to_char((total_cust_b3 * 100)/(aging_balance_outstanding),'990.00');
        c_percent_b4 := to_char((total_cust_b4 * 100)/(aging_balance_outstanding),'990.00');
        c_percent_b5 := to_char((total_cust_b5 * 100)/(aging_balance_outstanding),'990.00');
        c_percent_b6 := to_char((total_cust_b6 * 100)/(aging_balance_outstanding),'990.00');
end if;

return (0);

END ;

RETURN NULL; end;

function c_compute_amtformula(functional_currency in varchar2, customer_id in number, site_use_id in number, Currency_Bucket in varchar2, aging_balance_outstanding in number) return number is
begin

DECLARE
l_aging_on_account      NUMBER ;
l_aging_unapplied       NUMBER ;
l_aging_convert_on_account VARCHAR2(1);
l_aging_convert_unapplied  VARCHAR2 (1);
l_aging_credit          NUMBER ;
l_aging_convert_credit  VARCHAR2 (1) ;
l_aging_in_collection   NUMBER ;
l_aging_convert_collection  VARCHAR2 (1);

BEGIN

/*srw.reference (customer_id);*/null;

/*srw.reference (site_use_id);*/null;

/*srw.reference (Currency_Bucket);*/null;

/*srw.reference (aging_balance_outstanding);*/null;

/*srw.reference (functional_currency);*/null;



c_adjusted_balance:= 0 ;
l_aging_on_account:= 0 ;
l_aging_unapplied := 0 ;
l_aging_convert_on_account:= '';
l_aging_convert_unapplied := '';
l_aging_credit:= 0 ;
l_aging_convert_credit:= '';
l_aging_in_collection:= 0 ;
l_aging_convert_collection:= '';

SELECT	NVL(SUM(DECODE(AR_RECEIVABLE_APPLICATIONS.STATUS, 'ACC',
						-AMOUNT_APPLIED, 0)),
						 0) on_account,
        nvl(max(decode(ar_receivable_applications.status, 'ACC',
		decode(ar_cash_receipts.currency_code, functional_currency, ' ',
		      decode(ar_cash_receipts.exchange_rate, NULL, '*', ' ')),
		' ')), ' ') account_convert,
	nvl(sum(decode(ar_receivable_applications.status, 'UNAPP',
		  				-amount_applied, 0)),
						 0) unapplied,
        nvl(max(decode(ar_receivable_applications.status, 'UNAPP',
		decode(ar_cash_receipts.currency_code, functional_currency, ' ',
		      decode(ar_cash_receipts.exchange_rate, NULL, '*', ' ')),
		' ')), ' ') unapp_convert
into	l_aging_on_account,
	l_aging_convert_on_account,
	l_aging_unapplied,
	l_aging_convert_unapplied
from	ar_receivable_applications,
	ar_cash_receipts
where	ar_receivable_applications.cash_receipt_id =
		ar_cash_receipts.cash_receipt_id
and	ar_cash_receipts.pay_from_customer = customer_id
and     ar_cash_receipts.CUSTOMER_SITE_USE_ID = site_use_id
and     ar_cash_receipts.currency_code = Currency_Bucket
and	ar_receivable_applications.gl_date <= sysdate
and	nvl(ar_receivable_applications.confirmed_flag,'Y') = 'Y'
;

c_aging_on_account:= l_aging_on_account ;
c_aging_unapplied:= l_aging_unapplied  ;
c_aging_convert_on_account:= l_aging_convert_on_account ;
c_aging_convert_unapplied:= l_aging_convert_unapplied ;

select  nvl(sum(amount_due_remaining ), 0),
 nvl(max(decode(invoice_currency_code,
                        functional_currency, ' ',
                decode(exchange_rate,
                        NULL, '*', ' '))), ' ')
into    l_aging_credit,
        l_aging_convert_credit
from    ar_payment_schedules
where   customer_id = customer_id
and     customer_site_use_id = site_use_id
and     invoice_currency_code = Currency_Bucket
and     class = 'CM'
and     gl_date <= sysdate
;

c_aging_credit:= l_aging_credit ;
c_aging_convert_credit:= l_aging_convert_credit;

c_adjusted_balance:=
  aging_balance_outstanding + c_aging_on_account  + c_aging_unapplied + c_aging_credit ;


SELECT	NVL(SUM(DECODE(IN_COLLECTION, 'Y',
			AMOUNT_DUE_REMAINING, 0)),0) COLLECT,
	NVL(MAX(DECODE(IN_COLLECTION, 'Y',
		DECODE(INVOICE_CURRENCY_CODE, functional_currency, ' ',
 		DECODE(EXCHANGE_RATE, NULL, '*', ' ')), ' ')), ' ') CCONV
INTO	l_aging_in_collection,
	l_aging_convert_collection
FROM	AR_PAYMENT_SCHEDULES
WHERE	CUSTOMER_ID = CUSTOMER_ID
AND 	CUSTOMER_SITE_USE_ID = site_use_id
AND 	INVOICE_CURRENCY_CODE = Currency_Bucket
AND	STATUS = 'OP'
;
c_aging_in_collection:= l_aging_in_collection ;
c_aging_convert_collection:= l_aging_convert_collection ;
return (0);

END ;

RETURN NULL; end;

function c_high_inv_formulaformula(functional_currency in varchar2, CUSTOMER_ID in number, SITE_USE_ID in number, Currency_Bucket in varchar2) return number is
begin

DECLARE
l_cust_hist_high_invoice_amt      NUMBER ;
l_cust_hist_conv_high_invoice     VARCHAR2   (1);
l_cust_hist_high_invoice_date     VARCHAR2   (11);


CURSOR C_HIGH_INV IS
SELECT 	NVL(AMOUNT_DUE_ORIGINAL, 0),
        DECODE(INVOICE_CURRENCY_CODE, functional_currency, ' ',
		DECODE(EXCHANGE_RATE, NULL, '*', ' ')),
	TRX_DATE
FROM	AR_PAYMENT_SCHEDULES
WHERE	CUSTOMER_ID = CUSTOMER_ID
AND 	CUSTOMER_SITE_USE_ID = SITE_USE_ID
AND 	INVOICE_CURRENCY_CODE = Currency_Bucket
AND	CLASS NOT IN ('CM', 'PMT')
ORDER BY AMOUNT_DUE_ORIGINAL DESC,
	TRX_DATE DESC
;
BEGIN

/*srw.reference (CUSTOMER_ID );*/null;

/*srw.reference (SITE_USE_ID );*/null;

/*srw.reference (Currency_Bucket );*/null;



l_cust_hist_high_invoice_amt:= 0 ;
l_cust_hist_conv_high_invoice:= '' ;
l_cust_hist_high_invoice_date:= '';

OPEN C_HIGH_INV ;
FETCH C_HIGH_INV
INTO 	l_cust_hist_high_invoice_amt,
	l_cust_hist_conv_high_invoice,
	l_cust_hist_high_invoice_date
;
c_cust_hist_high_invoice_amt:=l_cust_hist_high_invoice_amt;
c_cust_hist_conv_high_invoice:=l_cust_hist_conv_high_invoice;
c_cust_hist_high_invoice_date:=l_cust_hist_high_invoice_date;

CLOSE C_HIGH_INV ;



return (0);

EXCEPTION
WHEN NO_DATA_FOUND THEN
  l_cust_hist_high_invoice_amt:= 0;
  return (0);

WHEN OTHERS THEN
  /*SRW.MESSAGE (1000,'Error in executing formula column for HIGH INV');*/null;

return (0);

END ;

RETURN NULL; end;

function c_cust_hist_high_limit_amtform(CUSTOMER_ID_1 in number, site_use_id_1 in number) return number is
begin


DECLARE
l_cust_hist_high_limit_amt   NUMBER ;
l_cust_hist_high_limit_date  DATE;

CURSOR C_CREDIT_LIMIT IS
SELECT 	H.CREDIT_LIMIT,
        H.LAST_UPDATE_DATE
FROM	AR_CREDIT_HISTORIES H
WHERE	H.CUSTOMER_ID      = CUSTOMER_ID_1
AND	(H.SITE_USE_ID      = site_use_id_1
         OR
          to_char(site_use_id) is null
         OR
          ( H.SITE_USE_ID IS NULL
            AND NOT EXISTS (SELECT 1
                            FROM AR_CREDIT_HISTORIES H2
                            WHERE H2.SITE_USE_ID =
                                              site_use_id_1
                            AND   H2.CUSTOMER_ID =
                                              customer_id_1
                            )
          )
        )
AND     H.CREDIT_LIMIT     IS NOT NULL
ORDER BY H.CREDIT_LIMIT    DESC,
	H.LAST_UPDATE_DATE DESC
;

CURSOR C_CREDIT_LIMIT2 IS
select overall_credit_limit,
       last_update_date
from   hz_cust_profile_amts
where  cust_account_profile_id = c_customer_profile_id
and    currency_code = CP_limit_currency;


BEGIN
/*srw.reference (customer_id);*/null;

/*srw.reference (site_use_id);*/null;


OPEN C_CREDIT_LIMIT ;

FETCH C_CREDIT_LIMIT
INTO 	l_cust_hist_high_limit_amt,
	l_cust_hist_high_limit_date
;

if c_credit_limit%NOTFOUND then
   BEGIN
   open c_credit_limit2;

    fetch c_credit_limit2
    into l_cust_hist_high_limit_amt,
         l_cust_hist_high_limit_date;

    if c_credit_limit2%NOTFOUND then
       return(0);
    end if;

    close c_credit_limit2;

    c_cust_hist_high_limit_date:= l_cust_hist_high_limit_date;
    return(l_cust_hist_high_limit_amt);
END;

end if;
CLOSE C_CREDIT_LIMIT ;

c_cust_hist_high_limit_date:= l_cust_hist_high_limit_date ;
return (l_cust_hist_high_limit_amt) ;


EXCEPTION WHEN NO_DATA_FOUND THEN
  return (0);

WHEN OTHERS THEN
/*SRW.MESSAGE (1100, 'Error in Formula column for CREDIT LIMIT ');*/null;

RAISE;
return (0);
END ;

RETURN NULL; end;

--function c_rolling_summary_calcformula(functional_currency in varchar2, customer_id in number, site_use_id in --number, Currency_Bucket in varchar2) return number is
function c_rolling_summary_calcformula(functional_currency in varchar2, customer_id_1 in number, site_use_id in number, Currency_Bucket in varchar2) return number is
begin

DECLARE
l_ytd_sales_amount                    NUMBER ;
l_ytd_convert_sales                   VARCHAR2   (1);
l_ytd_sales_count                     NUMBER (20);
d_ytd_finance_charge_amount           NUMBER ;
d_ytd_finance_charge_convert          VARCHAR2 (1);
l_ytd_payment_amount                  NUMBER ;
l_ytd_convert_payment                 VARCHAR2   (1);
l_ytd_payment_count                   NUMBER (20);
l_ytd_credit_amount                   NUMBER ;
l_ytd_convert_credit                  VARCHAR2   (1);
l_ytd_credit_count                    NUMBER (20);
l_ytd_finance_charge_amount           NUMBER ;
l_ytd_convert_finance_charge          VARCHAR2   (1);
l_ytd_finance_charge_count            NUMBER (20);
l_ytd_writeoff_amount                 NUMBER ;
l_ytd_convert_writeoff                VARCHAR2   (1);
l_ytd_earned_discount_amount          NUMBER ;
l_ytd_convert_earned_discount         VARCHAR2   (1);
l_ytd_unearned_discount_amount        NUMBER ;
l_ytd_conv_unearned_discount       VARCHAR2   (1);
l_ytd_average_payment_days            NUMBER (20);
l_ytd_average_days_late               NUMBER (20);
l_ytd_late_payments_count             NUMBER (20);
l_ytd_on_time_payments_count          NUMBER (20);
l_ytd_nsf_amount                      NUMBER ;
l_ytd_convert_nsf                     VARCHAR2   (1);
l_ytd_nsf_count                       NUMBER (20);

BEGIN

/*srw.reference (Currency_Bucket);*/null;

/*srw.reference (customer_id);*/null;

/*srw.reference (site_use_id );*/null;


l_ytd_writeoff_amount:= 0 ;
l_ytd_convert_writeoff:= '';
l_ytd_sales_amount:= 0 ;
l_ytd_convert_sales:= '';
l_ytd_sales_count:= 0 ;
d_ytd_finance_charge_amount:= 0;
d_ytd_finance_charge_convert:= 0 ;
l_ytd_payment_amount:= 0 ;
l_ytd_convert_payment:= '';
l_ytd_payment_count:= 0 ;
l_ytd_credit_amount:= 0 ;
l_ytd_convert_credit:= '';
l_ytd_credit_count := 0 ;
l_ytd_finance_charge_amount:= 0 ;
l_ytd_convert_finance_charge:= '';
l_ytd_finance_charge_count         := 0 ;
l_ytd_average_payment_days         := 0 ;
l_ytd_average_days_late            := 0 ;
l_ytd_late_payments_count          := 0 ;
l_ytd_on_time_payments_count       := 0 ;
l_ytd_earned_discount_amount       := 0 ;
l_ytd_convert_earned_discount      := '';
l_ytd_unearned_discount_amount     := 0 ;
l_ytd_conv_unearned_discount    := '';
l_ytd_nsf_amount                   := 0 ;
l_ytd_convert_nsf                  := '';
l_ytd_nsf_count                    := 0 ;

select	nvl(sum(amount_due_original),0),
        max(decode(invoice_currency_code,functional_currency, ' ',
		decode(exchange_rate, NULL, '*', ' '))),
	count(amount_due_original),
	nvl(sum(receivables_charges_charged),0),
        max(decode(invoice_currency_code,functional_currency, ' ',
		decode(exchange_rate, NULL, '*', ' ')))
into	l_ytd_sales_amount,
	l_ytd_convert_sales,
	l_ytd_sales_count,
	d_ytd_finance_charge_amount,
	d_ytd_finance_charge_convert
from	ar_payment_schedules
--where	ar_payment_schedules.customer_id = customer_id
where	ar_payment_schedules.customer_id = customer_id_1
and 	customer_site_use_id = site_use_id
and 	invoice_currency_code = Currency_Bucket
and	ar_payment_schedules.trx_date between
	add_months(sysdate, -12) and sysdate
and	ar_payment_schedules.class not in ('CM', 'PMT')
;

select	nvl(sum(-amount), 0) payment_amount,
        nvl(max(decode(currency_code, functional_currency, ' ',
		decode(exchange_rate, NULL, '*', ' '))), ' '),
	nvl(count(amount),0) payment_count
into	l_ytd_payment_amount,
	l_ytd_convert_payment,
	l_ytd_payment_count
from	ar_cash_receipts
--where	ar_cash_receipts.pay_from_customer = customer_id
where	ar_cash_receipts.pay_from_customer = customer_id_1
and 	customer_site_use_id = site_use_id
and 	currency_code = Currency_Bucket
and	ar_cash_receipts.creation_date between
	add_months(sysdate, -12) and sysdate
and	ar_cash_receipts.status <> 'REV'
and	nvl(ar_cash_receipts.confirmed_flag,'Y') = 'Y'
;
select  nvl(sum(amount_due_original ), 0),
	       nvl(max(decode(ar_payment_schedules.invoice_currency_code,
			functional_currency, ' ',
		decode(ar_payment_schedules.exchange_rate,
			NULL, '*', ' '))), ' '),
		count(customer_trx_id)
into	l_ytd_credit_amount,
	l_ytd_convert_credit,
	l_ytd_credit_count
from	ar_payment_schedules
where 	ar_payment_schedules.trx_date between add_months(sysdate,-12) and
	sysdate
--and	ar_payment_schedules.customer_id = customer_id
and	ar_payment_schedules.customer_id = customer_id_1
and  	customer_site_use_id = site_use_id
and 	invoice_currency_code = Currency_Bucket
and	ar_payment_schedules.class = 'CM'
;

select 	nvl(sum(amount), 0),
        nvl(max(decode(ar_payment_schedules.invoice_currency_code,
			functional_currency, ' ',
		decode(ar_payment_schedules.exchange_rate,
			NULL, '*', ' '))), ' '),
	count(adjustment_id)
into	l_ytd_finance_charge_amount,
	l_ytd_convert_finance_charge,
	l_ytd_finance_charge_count
from 	ar_adjustments,
	ar_receivables_trx,
	ar_payment_schedules
where 	ar_adjustments.payment_schedule_id=
		ar_payment_schedules.payment_schedule_id
and 	ar_payment_schedules.customer_site_use_id = site_use_id
and 	ar_payment_schedules.invoice_currency_code = Currency_Bucket
and 	ar_adjustments.receivables_trx_id=ar_receivables_trx.receivables_trx_id
and 	ar_receivables_trx.type='FINCHRG'
and 	ar_adjustments.apply_date between add_months(sysdate,-12) and sysdate
and 	nvl(ar_adjustments.postable,'Y')='Y'
--and 	ar_payment_schedules.customer_id=customer_id
and 	ar_payment_schedules.customer_id=customer_id_1
;

select	nvl(sum(ar_adjustments.amount), 0),
        nvl(max(decode(ar_payment_schedules.invoice_currency_code,
			functional_currency, ' ',
		decode(ar_payment_schedules.exchange_rate,
			NULL, '*', ' '))), ' ')
into	l_ytd_writeoff_amount,
	l_ytd_convert_writeoff
from	ar_adjustments,
	ar_lookups lk,
	ar_payment_schedules
where	ar_adjustments.reason_code
		= lk.lookup_code(+)
and	lk.lookup_code(+) = 'WRITE OFF'
and 	lk.lookup_type(+) = 'ADJUST_REASON'
--and	ar_payment_schedules.customer_id = customer_id
and	ar_payment_schedules.customer_id = customer_id_1
and 	ar_payment_schedules.customer_site_use_id = site_use_id
and 	ar_payment_schedules.invoice_currency_code = Currency_Bucket
and	ar_adjustments.payment_schedule_id =
		ar_payment_schedules.payment_schedule_id
and	ar_adjustments.apply_date between
	add_months(sysdate, -12) and sysdate
and	nvl(ar_adjustments.postable, 'Y') = 'Y'
;

select	nvl(sum(ar_receivable_applications.earned_discount_taken ), 0) earned,
	nvl(max(decode(nvl(ar_receivable_applications.earned_discount_taken, 0),
			0, ' ',
			decode(ar_payment_schedules.invoice_currency_code,
				functional_currency, ' ',
			decode(ar_payment_schedules.exchange_rate,
					NULL, '*', ' ')))), ' ') earned_cvt,
	nvl(sum(ar_receivable_applications.unearned_discount_taken), 0) unearned,
	nvl(max(decode(nvl(ar_receivable_applications.unearned_discount_taken, 0),
			0, ' ',
			decode(ar_payment_schedules.invoice_currency_code,
				functional_currency, ' ',
			decode(ar_payment_schedules.exchange_rate,
					NULL, '*', ' ')))), ' ') unearned_cvt,
	decode(count(ar_receivable_applications.apply_date), 0, 0,
		round(sum(ar_receivable_applications.apply_date -
		ar_payment_schedules.trx_date) /
		count(ar_receivable_applications.apply_date))) avgdays,
	decode(count(ar_receivable_applications.apply_date), 0, 0,
		round(sum(ar_receivable_applications.apply_date -
		ar_payment_schedules.due_date) /
		count(ar_receivable_applications.apply_date))) avgdayslate,
	nvl(sum(decode(sign(ar_receivable_applications.apply_date -
				ar_payment_schedules.due_date),
			1, 1, 0)), 0) newlate,
	nvl(sum( decode(sign(ar_receivable_applications.apply_date -
				ar_payment_schedules.due_date),
			1, 0, 1)), 0) newontime
into 	l_ytd_earned_discount_amount,
	l_ytd_convert_earned_discount,
	l_ytd_unearned_discount_amount,
	l_ytd_conv_unearned_discount,
	l_ytd_average_payment_days,
	l_ytd_average_days_late,
	l_ytd_late_payments_count,
	l_ytd_on_time_payments_count
from	ar_receivable_applications, ar_payment_schedules
where	ar_receivable_applications.applied_payment_schedule_id =
	ar_payment_schedules.payment_schedule_id
and	ar_payment_schedules.customer_id = customer_id
and 	ar_payment_schedules.customer_site_use_id = site_use_id
and 	ar_payment_schedules.invoice_currency_code = Currency_Bucket
and	ar_receivable_applications.apply_date between
	add_months(sysdate, -12) and sysdate
and	ar_receivable_applications.status = 'APP'
and	ar_receivable_applications.display = 'Y'
and	nvl(ar_payment_schedules.receipt_confirmed_flag,'Y') = 'Y'
;

select	nvl(sum(ROUND(decode(ar_cash_receipts.status,'NSF', acrh.acctd_amount, 'STOP', acrh.acctd_amount, 0)
		, 2)), 0) nsf_amount,
        nvl(max(decode(currency_code, functional_currency, ' ',
		decode(ar_cash_receipts.exchange_rate, NULL, '*', ' '))), ' '),
	nvl(sum(decode(ar_cash_receipts.status,'NSF', 1, 'STOP', 1, 0)), 0) nsf_count
into	l_ytd_nsf_amount,
	l_ytd_convert_nsf,
	l_ytd_nsf_count
from	ar_cash_receipts,
	ar_cash_receipt_history acrh
--where	ar_cash_receipts.pay_from_customer = customer_id
where	ar_cash_receipts.pay_from_customer = customer_id_1
and     ar_cash_receipts.cash_receipt_id = acrh.cash_receipt_id
and     acrh.first_posted_record_flag = 'Y'
and 	customer_site_use_id = site_use_id
and 	currency_code = Currency_Bucket
and	ar_cash_receipts.reversal_date between
	add_months(sysdate, -12) and sysdate

;

c_ytd_writeoff_amount:= l_ytd_writeoff_amount                ;
c_ytd_convert_writeoff:= l_ytd_convert_writeoff               ;
c_ytd_sales_amount:= l_ytd_sales_amount                   ;
c_ytd_convert_sales:= l_ytd_convert_sales                  ;
c_ytd_sales_count:= l_ytd_sales_count                    ;
c_ytd_payment_amount:= l_ytd_payment_amount                 ;
c_ytd_convert_payment:= l_ytd_convert_payment                ;
c_ytd_payment_count:= l_ytd_payment_count                  ;
c_ytd_credit_amount:= l_ytd_credit_amount                  ;
c_ytd_convert_credit:= l_ytd_convert_credit                 ;
c_ytd_credit_count:= l_ytd_credit_count                   ;
c_ytd_finance_charge_amount:= l_ytd_finance_charge_amount          ;
c_ytd_convert_finance_charge:= l_ytd_convert_finance_charge         ;
c_ytd_finance_charge_count:= l_ytd_finance_charge_count           ;
c_ytd_average_payment_days:= l_ytd_average_payment_days           ;
c_ytd_average_days_late:= l_ytd_average_days_late              ;
c_ytd_late_payments_count:= l_ytd_late_payments_count            ;
c_ytd_on_time_payments_count:= l_ytd_on_time_payments_count         ;
c_ytd_earned_discount_amount:= l_ytd_earned_discount_amount         ;
c_ytd_convert_earned_discount:= l_ytd_convert_earned_discount        ;
c_ytd_unearned_discount_amount:= l_ytd_unearned_discount_amount       ;
c_ytd_conv_unearned_discount:= l_ytd_conv_unearned_discount      ;
c_ytd_nsf_amount:= l_ytd_nsf_amount                     ;
c_ytd_convert_nsf:= l_ytd_convert_nsf                    ;
c_ytd_nsf_count:= l_ytd_nsf_count     ;

return (0);

EXCEPTION WHEN OTHERS THEN
  return (0);

END  ;


RETURN NULL; end;

function AfterPForm return boolean is
     L_Collector_Min       varchar2(30);
     L_Collector_Max       varchar2(30);

Begin

XLA_MO_REPORTING_API.Initialize(p_reporting_level, p_reporting_entity_id, 'AUTO');
/*srw.message(100, 'DEBUG: p_reporting_entity_id: '||p_reporting_entity_id);*/null;

/*srw.message(1, 'After Call XLA_MO_REPORTING_API.Initialize');*/null;


p_org_where_ps:= XLA_MO_REPORTING_API.Get_Predicate('ps', null);
/*srw.message(100, 'DEBUG: ps: '||p_org_where_ps);*/null;

p_org_where_param:= XLA_MO_REPORTING_API.Get_Predicate('PARAM',null);
/*srw.message(100, 'DEBUG: ps: '||p_org_where_param);*/null;

p_org_where_ad:= XLA_MO_REPORTING_API.Get_Predicate('acct_site', null);
/*srw.message(100, 'DEBUG: ad: '||p_org_where_ad);*/null;

p_org_where_su:= XLA_MO_REPORTING_API.Get_Predicate('site_uses', null);
/*srw.message(100, 'DEBUG: su: '||p_org_where_su);*/null;

p_reporting_entity_name := XLA_MO_REPORTING_API.get_reporting_entity_name ;
/*srw.message(100, 'DEBUG: Reporting Entity Name: '||p_reporting_entity_name);*/null;

p_reporting_level_name :=  XLA_MO_REPORTING_API.get_reporting_level_name;
/*srw.message(100, 'DEBUG: Reporting Level Name : '||p_reporting_level_name);*/null;




     /*srw.message (100, 'DEBUG:  Customer Name (Low):    ' || p_customer_name_low);*/null;

     /*srw.message (100, 'DEBUG:  Customer Name (High):   ' || p_customer_name_high);*/null;


     if P_Customer_Name_Low is NOT NULL then



          lp_customer_name_low:= ' and party.party_name >= :p_customer_Name_Low';
	  else
	   lp_customer_name_low:=' ';
     end if ;

     if p_customer_name_high is NOT NULL then


          lp_customer_name_high:= ' and party.party_name <= :p_customer_name_high';
	  else
	   lp_customer_name_high:=' ';
     end if ;

     /*srw.message (100, 'DEBUG:  Q - Customer Name (Low):    ' || lp_customer_name_low);*/null;

     /*srw.message (100, 'DEBUG:  Q - Customer Name (High):   ' || lp_customer_name_high);*/null;



     /*srw.message (100, 'DEBUG:  Customer Number (Low):    ' || p_customer_number_low);*/null;

     /*srw.message (100, 'DEBUG:  Customer Number (High):   ' || p_customer_number_high);*/null;


     if p_customer_number_low is NOT NULL then
          lp_customer_number_low:= 'and cust_acct.account_number >= ''' || p_customer_number_low || '''';
	  else
	   lp_customer_number_low:=' ';
     end if ;

     if p_customer_number_high is NOT NULL then
          lp_customer_number_high:= 'and cust_acct.account_number <= ''' || p_customer_number_high || '''';
	 else
	  lp_customer_number_high:=' ';
     end if ;

     /*srw.message (100, 'DEBUG:  Q - Customer Number (Low):    ' || lp_customer_number_low);*/null;

     /*srw.message (100, 'DEBUG:  Q - Customer Number (High):   ' || lp_customer_number_high);*/null;



     /*srw.message (100, 'DEBUG:  Collector Name (Low):    ' || p_collector_low);*/null;

     /*srw.message (100, 'DEBUG:  Collector Name (High):   ' || p_collector_high);*/null;


     if p_collector_low is  NULL then
          SELECT min(name)
          INTO   l_collector_min
          FROM   ar_collectors;

          p_collector_min:= l_collector_min  ;

          /*srw.message (100, 'DEBUG:  Collector Name (MIN):    ' || p_collector_min);*/null;

     end if ;

     if p_collector_high is NULL then
          SELECT max(name)
          into l_collector_max
          from ar_collectors;

          p_collector_max := l_collector_max  ;

          /*srw.message (100, 'DEBUG:  Collector Name (MAX):   ' || p_collector_max);*/null;

     end if ;

     if p_collector_low is NOT NULL then
          lp_coll_name_low := 'and coll.name >= ''' || p_collector_low || '''';
	  else
	  lp_coll_name_low:=' ';
     end if;
     /*srw.message (100, 'DEBUG:  coll_name_low:   ' || lp_coll_name_low);*/null;

     if p_collector_high is NOT NULL then
          lp_coll_name_high := 'and coll.name <= ''' || p_collector_high || '''';
	  else
          lp_coll_name_high:=' ';
     end if;
     /*srw.message (100, 'DEBUG:  coll_name_high:   ' || lp_coll_name_high);*/null;


     return (TRUE);
end;

function c_credit_summaryformula(customer_id in number, site_use_id_1 in number) return number is
begin

DECLARE

l_cred_summ_limit_tolerance       VARCHAR2(30);
l_cred_summ_credit_rating         VARCHAR2(30);
l_cred_summ_risk_code             VARCHAR2(30);
l_cred_summ_credit_hold           ar_lookups.meaning%type;
l_cred_summ_account_status        VARCHAR2(30);
l_cred_summ_terms                 VARCHAR2(20);
l_cred_summ_exempt_dun            ar_lookups.meaning%type;
l_cred_summ_collector             VARCHAR2(30);
l_customer_profile_id             NUMBER(30);
l_profile_site_use_id  		  NUMBER(30);
ct_prof                		  NUMBER(2);
yes				  ar_lookups.meaning%type;
no				  ar_lookups.meaning%type;

BEGIN

/*srw.reference (customer_id);*/null;

/*srw.message(999,'Credit Summary Cust Ref : '||customer_id);*/null;


/*srw.reference (site_use_id);*/null;

/*srw.message(999,'Credit Summary Site Ref : '||site_use_id);*/null;



     select count(*)
     into ct_prof
     from hz_cust_profile_amts cpa,
          hz_customer_profiles cp
     where cp.cust_account_id = customer_id
    -- and   cp.site_use_id = site_use_id
    and   cp.site_use_id = site_use_id_1
     and   cp.cust_account_profile_id = cpa.cust_account_profile_id;

     if ct_prof > 0 then
                --c_profile_site_use_id := site_use_id;
		c_profile_site_use_id := site_use_id_1;
     else
        c_profile_site_use_id := null;
     end if;





  SELECT  INITCAP(YES.MEANING) yes,
          INITCAP(NO.MEANING)  no
  INTO    yes,
          no
  FROM    AR_LOOKUPS                      YES,
          AR_LOOKUPS                      NO
  WHERE   YES.LOOKUP_TYPE = 'YES/NO'      AND
          YES.LOOKUP_CODE = 'Y'           AND
          NO.LOOKUP_TYPE = 'YES/NO'       AND
          NO.LOOKUP_CODE = 'N';

if c_profile_site_use_id is NULL then

    Select
 	  to_char(nvl(cp.tolerance, 0), '990') || '%',
	  substr(nvl(cp.credit_rating, rp_na_upper),1,30),
	  cp.risk_code,
	  lk.meaning,
	  cp.account_status,
	  substr(nvl(term.name, rp_none),1,20),
	  decode(cp.dunning_letters, 'Y', no, yes),
	  coll.name,
	  cp.cust_account_profile_id
  into
	  l_cred_summ_limit_tolerance,
	  l_cred_summ_credit_rating,
	  l_cred_summ_risk_code,
	  l_cred_summ_credit_hold,
	  l_cred_summ_account_status,
	  l_cred_summ_terms,
	  l_cred_summ_exempt_dun,
	  l_cred_summ_collector,
	  l_customer_profile_id
  from 	  hz_customer_profiles cp,
	  ar_collectors coll,
	  ar_lookups lk,
	  ra_terms term
  where	cp.collector_id = coll.collector_id
  and	cp.standard_terms = term.term_id (+)
  and	cp.cust_account_id = customer_id
  and 	cp.site_use_id is null
  and   coll.name between nvl(p_collector_low,p_collector_min)
  and  nvl(p_collector_high,p_collector_max)
  and	nvl(cp.credit_hold,'N') = lk.lookup_code
  and	lk.lookup_type = 'YES/NO' ;


else

Select
	to_char(nvl(cp.tolerance, 0), '990') || '%',
	substr(nvl(cp.credit_rating,rp_na_upper),1,30),
	cp.risk_code,
        lk.meaning,
	cp.account_status,
	substr(nvl(term.name, rp_none),1,20),
	decode(cp.dunning_letters, 'Y', no, yes),
	coll.name,
	cp.cust_account_profile_id
into
	l_cred_summ_limit_tolerance,
	l_cred_summ_credit_rating,
	l_cred_summ_risk_code,
	l_cred_summ_credit_hold,
	l_cred_summ_account_status,
	l_cred_summ_terms,
	l_cred_summ_exempt_dun,
	l_cred_summ_collector,
	l_customer_profile_id

from 	hz_customer_profiles cp,
	ar_collectors coll,
        ar_lookups lk,
	ra_terms term

where	cp.collector_id = coll.collector_id
and	cp.standard_terms = term.term_id (+)
and	cp.cust_account_id = customer_id
--and 	cp.site_use_id = site_use_id
and 	cp.site_use_id = site_use_id_1
and     coll.name between nvl(p_collector_low,p_collector_min)
                 and     nvl(p_collector_high,p_collector_max)
and	nvl(cp.credit_hold,'N') = lk.lookup_code
and	lk.lookup_type = 'YES/NO'
;

end if ;


c_cred_summ_limit_tolerance    := l_cred_summ_limit_tolerance  ;
c_cred_summ_credit_rating      := l_cred_summ_credit_rating  ;
c_cred_summ_risk_code          := nvl(l_cred_summ_risk_code,rp_na_upper)  ;
c_cred_summ_credit_hold        := l_cred_summ_credit_hold  ;
c_cred_summ_account_status     := nvl(l_cred_summ_account_status,rp_na_upper);
c_cred_summ_terms              := l_cred_summ_terms  ;
c_cred_summ_exempt_dun         := l_cred_summ_exempt_dun  ;
c_cred_summ_collector          := l_cred_summ_collector  ;
c_customer_profile_id          := l_customer_profile_id  ;


return (0);

EXCEPTION WHEN NO_DATA_FOUND THEN
  return (0);

END ;

RETURN (0);
end;

--function c_credit_amounts_calcformula(qc_customer in number, qc_site in number) return number is
function c_credit_amounts_calcformula(qc_customer in number,qc_site in number,functional_currency varchar2,currency_credit in varchar2,credit_limit in number) return number is
l_aging_balance_os_profile         NUMBER ;
  adjusted_balance                   NUMBER;
  l_aging_convert_os_profile         VARCHAR2(1);
  l_aging_on_account_profile         NUMBER ;
  l_aging_conv_on_ac_profile         VARCHAR2(1);
  l_aging_unapplied_profile          NUMBER ;
  l_aging_conv_unap_prof             VARCHAR2(1);
  l_cred_summ_avail_credit           NUMBER ;
  l_dummy                            NUMBER(1);
  trx_curr                           VARCHAR2(15);
  trx_amount                         NUMBER;
  base_amount                        NUMBER;
  curr_exists                        NUMBER;
  CURSOR ps_trx IS
  SELECT invoice_currency_code, NVL(SUM(AMOUNT_DUE_REMAINING), 0) ammount_due,exchange_rate_type
  from   ar_payment_schedules ps
  where  ps.customer_id = qc_customer
  and    ps.customer_site_use_id = NVL(qc_site,ps.customer_site_use_id)
  and	 ps.status = 'OP'
  and    ps.class not in ('CM', 'PMT')
  group  by ps.invoice_currency_code,exchange_rate_type;

  l_loop  			     VARCHAR2(1);
BEGIN

  /*srw.message (593, 'related curr '||cp_related_currencies);*/null;

  /*srw.message (593, 'site is '||qc_site);*/null;


  l_cred_summ_avail_credit       :=  0;
  l_aging_balance_os_profile     :=  0;
  adjusted_balance               :=  0;
  c_cred_summ_convert_limit     := '' ;
  c_cred_summ_available         := l_dummy;
  c_cred_summ_exceeded          := l_dummy ;
  /*srw.reference (customer_id);*/null;

  /*srw.reference (Currency_Credit);*/null;

  /*srw.reference (site_use_id);*/null;

  /*srw.reference (credit_limit);*/null;




  l_aging_on_account_profile:=0;
  l_aging_unapplied_profile:=0;
  l_loop:='N';

  SELECT
        NVL(SUM(DECODE(AR_RECEIVABLE_APPLICATIONS.STATUS, 'ACC',
        AMOUNT_APPLIED, 0)),
  	0) on_account,
      nvl(max(decode(ar_receivable_applications.status, 'ACC',
      decode(ar_cash_receipts.currency_code,functional_currency, ' ',
      decode(ar_cash_receipts.exchange_rate, NULL, '*', ' ')),
      ' ')), ' ') account_convert,
      nvl(sum(decode(ar_receivable_applications.status, 'UNAPP',
      amount_applied, 0)),
      0) unapplied,
      nvl(max(decode(ar_receivable_applications.status, 'UNAPP',
      decode(ar_cash_receipts.currency_code,functional_currency, ' ',
      decode(ar_cash_receipts.exchange_rate, NULL, '*', ' ')),
      ' ')), ' ') unapp_convert
  into
      l_aging_on_account_profile,
      l_aging_conv_on_ac_profile,
      l_aging_unapplied_profile,
      l_aging_conv_unap_prof
  from
      ar_receivable_applications,
      ar_cash_receipts
  where
      ar_receivable_applications.cash_receipt_id =
      ar_cash_receipts.cash_receipt_id
      and ar_cash_receipts.pay_from_customer = qc_customer
      and ar_cash_receipts.CUSTOMER_SITE_USE_ID =
      NVL(qc_site, ar_cash_receipts.customer_site_use_id)
      and ar_cash_receipts.currency_code = currency_credit
      and ar_receivable_applications.gl_date <= sysdate;

  for trx_rec in ps_trx loop
    curr_exists := instr(CP_related_currencies,trx_rec.invoice_currency_code);
    /*srw.message(593,'in loop - curr_exists = '||curr_exists);*/null;

    if curr_exists <> 0 then

      l_aging_on_account_profile:=0;
      l_aging_unapplied_profile:=0;
      l_loop:='Y';

      trx_curr := trx_rec.invoice_currency_code;


      SELECT
          NVL(SUM(DECODE(AR_RECEIVABLE_APPLICATIONS.STATUS, 'ACC',
	    AMOUNT_APPLIED, 0)), 0) on_account,
                        	  nvl(sum(decode(ar_receivable_applications.status, 'UNAPP',
            amount_applied, 0)), 0) unapplied
                             into
          l_aging_on_account_profile,
                l_aging_unapplied_profile
           from
          ar_receivable_applications,
          ar_cash_receipts
     where
          ar_receivable_applications.cash_receipt_id =
          ar_cash_receipts.cash_receipt_id
          and ar_cash_receipts.pay_from_customer = qc_customer
          and ar_cash_receipts.CUSTOMER_SITE_USE_ID =
          NVL(qc_site, ar_cash_receipts.customer_site_use_id)
          and ar_cash_receipts.currency_code = trx_rec.invoice_currency_code
          and ar_receivable_applications.gl_date <= sysdate;

      trx_amount := trx_rec.ammount_due -
                    l_aging_unapplied_profile -
                    l_aging_on_account_profile;

      base_amount :=
         gl_currency_api.convert_amount_sql
         ( trx_curr,
           CP_limit_currency,
           SYSDATE,
           'Corporate',
           trx_amount
         );
      if base_amount = -1 then
         base_amount:=0;
         FND_MESSAGE.SET_NAME('AR','AR_CC_INVALID_EXCHANGE_RATE');
         FND_MESSAGE.SET_TOKEN('CC',trx_curr,FALSE);
         /*SRW.MESSAGE(201,FND_MESSAGE.GET);*/null;


            elsif base_amount = -2 then
           FND_MESSAGE.SET_NAME('AR','AR_CC_INVALID_CURRENCY');
           /*SRW.MESSAGE(200,FND_MESSAGE.GET);*/null;

           raise_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

      end if;
/*srw.message (200, 'DEBUG:  base_amount:    ' || to_char(base_amount));*/null;



      adjusted_balance := Adjusted_balance + base_amount;
    end if;
  end loop;

  if (credit_limit is NOT NULL ) then

    If l_loop = 'Y' then
       l_cred_summ_avail_credit  :=  credit_limit - Adjusted_balance;
    Else
       l_cred_summ_avail_credit  :=  credit_limit + (l_aging_unapplied_profile+l_aging_on_account_profile);
    End if;

    if (( l_aging_conv_on_ac_profile    = '*' ) or
        (l_aging_conv_unap_prof      = '*')) then
      c_cred_summ_convert_limit := '*';
    end if ;
    if l_cred_summ_avail_credit < 0 then
      c_cred_summ_available := 0 ;
      c_cred_summ_exceeded     := l_cred_summ_avail_credit ;
    else
      c_cred_summ_exceeded   := 0 ;
      c_cred_summ_available := l_cred_summ_avail_credit ;
    end if ;

  end if ;

/*srw.message (777, 'available credit= '||TO_CHAR(l_cred_summ_avail_credit));*/null;

  return (0);
end;

function c_last_invoice_formulaformula(functional_currency in varchar2, CUSTOMER_ID in number, site_use_id in number) return number is
begin

DECLARE
l_last_invoice_number     VARCHAR2 (100);
l_last_invoice_type       VARCHAR2 (100);
l_last_invoice_currency   VARCHAR2 (15);
l_last_invoice_amount     NUMBER;
l_last_invoice_converted  VARCHAR2 (1);
l_last_invoice_date       VARCHAR2 (11);
l_last_invoice_days_since VARCHAR2 (100);
l_dummy                   NUMBER (1);

CURSOR C_LAST_INVOICE IS
SELECT	RA_CUSTOMER_TRX.TRX_NUMBER,
	RA_CUST_TRX_TYPES.NAME,
	AR_PAYMENT_SCHEDULES.INVOICE_CURRENCY_CODE,
	AR_PAYMENT_SCHEDULES.AMOUNT_DUE_ORIGINAL,
        DECODE(AR_PAYMENT_SCHEDULES.INVOICE_CURRENCY_CODE,functional_currency, ' ',
		DECODE(AR_PAYMENT_SCHEDULES.EXCHANGE_RATE, NULL, '*', ' ')),
	RA_CUSTOMER_TRX.TRX_DATE,
	TO_CHAR(ROUND(TRUNC(SYSDATE) - RA_CUSTOMER_TRX.TRX_DATE))
FROM	RA_CUST_TRX_TYPES,
	AR_PAYMENT_SCHEDULES,
	RA_CUSTOMER_TRX
WHERE	AR_PAYMENT_SCHEDULES.CUSTOMER_TRX_ID = RA_CUSTOMER_TRX.CUSTOMER_TRX_ID
AND	RA_CUSTOMER_TRX.CUST_TRX_TYPE_ID = RA_CUST_TRX_TYPES.CUST_TRX_TYPE_ID
AND	RA_CUSTOMER_TRX.BILL_TO_CUSTOMER_ID = CUSTOMER_ID
AND	AR_PAYMENT_SCHEDULES.Customer_site_use_id = site_use_id
AND	AR_PAYMENT_SCHEDULES.CLASS || '' = 'INV'
ORDER BY RA_CUSTOMER_TRX.TRX_DATE DESC,
	 RA_CUSTOMER_TRX.CUSTOMER_TRX_ID DESC
;


BEGIN
/*srw.reference (customer_id);*/null;

/*srw.reference (site_use_id);*/null;



  c_last_invoice_number     := ''  ;
  c_last_invoice_type       := ''  ;
  c_last_invoice_currency   := '' ;
  c_last_invoice_amount     := l_dummy  ;
  c_last_invoice_converted  := ''	  ;
  c_last_invoice_date       := ''  ;
  c_last_invoice_days_since := ''  ;


OPEN C_LAST_INVOICE ;

FETCH C_LAST_INVOICE
INTO
	l_last_invoice_number,
	l_last_invoice_type,
	l_last_invoice_currency,
	l_last_invoice_amount,
	l_last_invoice_converted,
	l_last_invoice_date,
	l_last_invoice_days_since
	;


if l_last_invoice_number is NOT NULL then

  c_last_invoice_number     := l_last_invoice_number   ;
  c_last_invoice_type       := l_last_invoice_type   ;
  c_last_invoice_currency   := l_last_invoice_currency  ;
  c_last_invoice_amount     := l_last_invoice_amount  ;
  c_last_invoice_converted  := l_last_invoice_converted	  ;
  c_last_invoice_date       := l_last_invoice_date   ;
  c_last_invoice_days_since := l_last_invoice_days_since   ;
else
c_last_invoice_number     := rp_none  ;

end if ;


CLOSE C_LAST_INVOICE ;
return (0);

EXCEPTION  WHEN NO_DATA_FOUND THEN

c_last_invoice_number     := rp_none   ;
c_last_invoice_type       := l_last_invoice_type   ;
c_last_invoice_currency   := l_last_invoice_currency  ;
c_last_invoice_amount     := l_last_invoice_amount  ;
c_last_invoice_converted  := l_last_invoice_converted	  ;
c_last_invoice_date       := l_last_invoice_date   ;
c_last_invoice_days_since := l_last_invoice_days_since   ;

WHEN OTHERS THEN
  /*SRW.MESSAGE (1000,to_char(SQLCODE)||' Error in Last Invoice Formula column');*/null;


return (0);

END ;

RETURN NULL; end;

--function c_last_credit_memo_formulaform(CUSTOMER_ID in number, site_use_id in number) return number is
function c_last_credit_memo_formulaform(functional_currency varchar2,CUSTOMER_ID_1 in number, site_use_id_1 in number) return number is
begin

DECLARE
l_last_cm_number   VARCHAR2 (100);
l_last_cm_type     VARCHAR2 (100);
l_last_cm_currency VARCHAR2 (20);
l_last_cm_date     VARCHAR2 (10);
l_last_cm_days_since VARCHAR2 (20);
l_last_cm_prev_trx   NUMBER (20);
l_last_cm_id         NUMBER (20);
l_dummy              NUMBER (1);

CURSOR C_CREDIT_MEMO IS
      SELECT  TRX1.TRX_NUMBER,
	TYPES.NAME,
	PS.INVOICE_CURRENCY_CODE,
	TRX1.TRX_DATE,
	ROUND(TRUNC(SYSDATE) - TRX1.TRX_DATE),
	TRX2.CUSTOMER_TRX_ID,
	TRX1.CUSTOMER_TRX_ID
FROM	RA_CUST_TRX_TYPES TYPES, RA_CUSTOMER_TRX TRX1, AR_PAYMENT_SCHEDULES PS,
	RA_CUSTOMER_TRX TRX2, AR_RECEIVABLE_APPLICATIONS APP
WHERE	TRX1.CUST_TRX_TYPE_ID = TYPES.CUST_TRX_TYPE_ID
AND	TRX1.BILL_TO_CUSTOMER_ID = CUSTOMER_ID_1
AND	APP.APPLIED_CUSTOMER_TRX_ID = TRX2.CUSTOMER_TRX_ID (+)
AND	APP.CUSTOMER_TRX_ID (+) = TRX1.CUSTOMER_TRX_ID
AND	PS.CUSTOMER_TRX_ID = TRX1.CUSTOMER_TRX_ID
AND	PS.CUSTOMER_SITE_USE_ID = site_use_id_1
AND	PS.CLASS = 'CM'
ORDER BY TRX1.TRX_DATE DESC,
	 TRX1.CUSTOMER_TRX_ID DESC
;

BEGIN
  /*srw.reference (customer_id);*/null;

  /*srw.reference (site_use_id);*/null;


  c_last_cm_number    := ''  ;
  c_last_cm_type      := ''  ;
  c_last_cm_currency  := ''   ;
  c_last_cm_date      := ''   ;
  c_last_cm_days_since := ''   ;
  c_last_cm_prev_trx   := l_dummy  ;
  c_last_cm_id        := l_dummy   ;
  c_last_cm_rel_invoice :='' ;
  c_last_cm_amount := l_dummy ;
  c_last_cm_converted := '' ;
OPEN C_CREDIT_MEMO ;

FETCH C_CREDIT_MEMO
INTO	l_last_cm_number ,
	l_last_cm_type,
	l_last_cm_currency,
	l_last_cm_date,
	l_last_cm_days_since,
	l_last_cm_prev_trx,
	l_last_cm_id
	;


if l_last_cm_number is NOT NULL then
  c_last_cm_number    := l_last_cm_number   ;
  c_last_cm_type      := l_last_cm_type  ;
  c_last_cm_currency  := l_last_cm_currency   ;
  c_last_cm_date      := l_last_cm_date   ;
  c_last_cm_days_since := l_last_cm_days_since   ;
  c_last_cm_prev_trx   := l_last_cm_prev_trx  ;
  c_last_cm_id        := l_last_cm_id   ;

  DECLARE
  l_last_cm_rel_invoice  VARCHAR2 (20);
  BEGIN
  /*SRW.REFERENCE (CUSTOMER_ID);*/null;

  /*SRW.REFERENCE (site_use_id);*/null;


    SELECT TRX_NUMBER
    INTO	l_last_cm_rel_invoice
    FROM	RA_CUSTOMER_TRX
    WHERE	CUSTOMER_TRX_ID = c_last_cm_prev_trx
    AND 	BILL_TO_SITE_USE_ID = SITE_USE_ID_1
    ;

    c_last_cm_rel_invoice := l_last_cm_rel_invoice ;

  EXCEPTION WHEN NO_DATA_FOUND THEN
    c_last_cm_rel_invoice := l_last_cm_rel_invoice ;
  END ;

  DECLARE
  l_last_cm_amount        NUMBER ;
  l_last_cm_converted     VARCHAR2 (1);
  BEGIN


    SELECT  NVL( SUM( P.AMOUNT_DUE_ORIGINAL) , 0),
	    MAX(DECODE(P.INVOICE_CURRENCY_CODE,functional_currency, ' ',
		DECODE(P.EXCHANGE_RATE,NULL, '*', ' ')))
    INTO	l_last_cm_amount,
	        l_last_cm_converted
    FROM	AR_PAYMENT_SCHEDULES P
    WHERE	P.CUSTOMER_TRX_ID = c_last_cm_id
    AND 	P.CUSTOMER_SITE_USE_ID = SITE_USE_ID_1
    ;
    c_last_cm_amount := l_last_cm_amount ;
    c_last_cm_converted := l_last_cm_converted ;

  EXCEPTION WHEN NO_DATA_FOUND THEN
  c_last_cm_amount := l_last_cm_amount ;
  c_last_cm_converted := l_last_cm_converted ;

  END ;


else
  c_last_cm_number    := rp_none;
end if ;

CLOSE C_CREDIT_MEMO ;
return (0);

EXCEPTION WHEN NO_DATA_FOUND THEN
  c_last_cm_number    := rp_none   ;
  c_last_cm_type      := l_last_cm_type  ;
  c_last_cm_currency  := l_last_cm_currency   ;
  c_last_cm_date      := l_last_cm_date   ;
  c_last_cm_days_since := l_last_cm_days_since   ;
  c_last_cm_prev_trx   := l_last_cm_prev_trx  ;
  c_last_cm_id        := l_last_cm_id   ;

WHEN OTHERS THEN
  /*srw.message (1006 , 'Error in LAST_CREDIT_MEMO_FORMULA');*/null;

return (0);
END ;

RETURN NULL; end;

function c_guarantee_formulaformula(functional_currency in varchar2, CUSTOMER_ID in number, site_use_id in number) return number is
begin

DECLARE
l_last_guar_number        VARCHAR2 (100);
l_last_guar_type          VARCHAR2 (100);
l_last_guar_currency      VARCHAR2 (20);
l_last_guar_amount        NUMBER ;
l_last_guar_converted     VARCHAR2 (1);
l_last_guar_date          VARCHAR2 (11);
l_last_guar_days_since    VARCHAR2 (11);
l_dummy                   NUMBER (1);

CURSOR C_guar IS
SELECT	RA_CUSTOMER_TRX.TRX_NUMBER,
	RA_CUST_TRX_TYPES.NAME,
	AR_PAYMENT_SCHEDULES.INVOICE_CURRENCY_CODE,
	AR_PAYMENT_SCHEDULES.AMOUNT_DUE_ORIGINAL,
        DECODE(AR_PAYMENT_SCHEDULES.INVOICE_CURRENCY_CODE,functional_currency, ' ',
		DECODE(AR_PAYMENT_SCHEDULES.EXCHANGE_RATE, NULL, '*', ' ')),
	RA_CUSTOMER_TRX.TRX_DATE,
	ROUND(TRUNC(SYSDATE) - RA_CUSTOMER_TRX.TRX_DATE)
FROM	RA_CUST_TRX_TYPES,
	RA_CUSTOMER_TRX,
	AR_PAYMENT_SCHEDULES
WHERE	AR_PAYMENT_SCHEDULES.CUSTOMER_TRX_ID = RA_CUSTOMER_TRX.CUSTOMER_TRX_ID
AND	RA_CUSTOMER_TRX.CUST_TRX_TYPE_ID = RA_CUST_TRX_TYPES.CUST_TRX_TYPE_ID
AND	RA_CUSTOMER_TRX.BILL_TO_CUSTOMER_ID = CUSTOMER_ID
AND	AR_PAYMENT_SCHEDULES.Customer_site_use_id = site_use_id
AND	AR_PAYMENT_SCHEDULES.CLASS = 'GUAR'
ORDER BY RA_CUSTOMER_TRX.TRX_DATE DESC,
	 RA_CUSTOMER_TRX.CUSTOMER_TRX_ID DESC
;

BEGIN
  c_last_guar_number         := '' ;
  c_last_guar_type           := ''   ;
  c_last_guar_currency       := ''  ;
  c_last_guar_amount         := l_dummy ;
  c_last_guar_converted      := ''	  ;
  c_last_guar_date           := ''   ;
  c_last_guar_days_since     := ''  ;

/*srw.reference (customer_id);*/null;

/*srw.reference (site_use_id);*/null;


OPEN C_guar ;

FETCH C_guar
INTO
    l_last_guar_number ,
    l_last_guar_type ,
    l_last_guar_currency,
    l_last_guar_amount,
    l_last_guar_converted	,
    l_last_guar_date ,
    l_last_guar_days_since
    ;

if l_last_guar_number is NOT NULL then
  c_last_guar_number         := l_last_guar_number   ;
  c_last_guar_type           := l_last_guar_type   ;
  c_last_guar_currency       := l_last_guar_currency  ;
  c_last_guar_amount         := l_last_guar_amount  ;
  c_last_guar_converted      := l_last_guar_converted	  ;
  c_last_guar_date           := l_last_guar_date   ;
  c_last_guar_days_since     := l_last_guar_days_since  ;
else
  c_last_guar_number         := rp_none   ;
end if ;

CLOSE C_guar ;


return (0);

EXCEPTION WHEN NO_DATA_FOUND THEN
  c_last_guar_number         := rp_none;
  c_last_guar_type           := l_last_guar_type   ;
  c_last_guar_currency       := l_last_guar_currency  ;
  c_last_guar_amount         := l_last_guar_amount  ;
  c_last_guar_converted      := l_last_guar_converted	  ;
  c_last_guar_date           := l_last_guar_date   ;
  c_last_guar_days_since     := l_last_guar_days_since  ;

WHEN OTHERS THEN
  /*SRW.MESSAGE (1010,'Error in C_GUAR FORMULA');*/null;

  return (0);
END ;

RETURN NULL; end;

function c_last_deposit_formulaformula(functional_currency in varchar2, CUSTOMER_ID in number, site_use_id in number) return number is
begin

DECLARE
l_last_dep_number        VARCHAR2 (100);
l_last_dep_type          VARCHAR2 (100);
l_last_dep_currency      VARCHAR2 (20);
l_last_dep_amount        NUMBER ;
l_last_dep_converted     VARCHAR2 (1);
l_last_dep_date          VARCHAR2 (11);
l_last_dep_days_since    VARCHAR2 (11);
l_dummy                  NUMBER (1);

CURSOR C_DEP IS
SELECT	RA_CUSTOMER_TRX.TRX_NUMBER,
	RA_CUST_TRX_TYPES.NAME,
	AR_PAYMENT_SCHEDULES.INVOICE_CURRENCY_CODE,
	AR_PAYMENT_SCHEDULES.AMOUNT_DUE_ORIGINAL,
        DECODE(AR_PAYMENT_SCHEDULES.INVOICE_CURRENCY_CODE,functional_currency, ' ',
		DECODE(AR_PAYMENT_SCHEDULES.EXCHANGE_RATE, NULL, '*', ' ')),
	RA_CUSTOMER_TRX.TRX_DATE,
	ROUND(TRUNC(SYSDATE) - RA_CUSTOMER_TRX.TRX_DATE)
FROM	RA_CUST_TRX_TYPES,
	RA_CUSTOMER_TRX,
	AR_PAYMENT_SCHEDULES
WHERE	AR_PAYMENT_SCHEDULES.CUSTOMER_TRX_ID = RA_CUSTOMER_TRX.CUSTOMER_TRX_ID
AND	RA_CUSTOMER_TRX.CUST_TRX_TYPE_ID = RA_CUST_TRX_TYPES.CUST_TRX_TYPE_ID
AND	RA_CUSTOMER_TRX.BILL_TO_CUSTOMER_ID = CUSTOMER_ID
AND	AR_PAYMENT_SCHEDULES.Customer_site_use_id = site_use_id
AND	AR_PAYMENT_SCHEDULES.CLASS = 'DEP'
ORDER BY RA_CUSTOMER_TRX.TRX_DATE DESC,
	 RA_CUSTOMER_TRX.CUSTOMER_TRX_ID DESC
;

BEGIN

/*srw.reference (customer_id);*/null;

/*srw.reference (site_use_id);*/null;

  c_last_dep_number         := ''   ;
  c_last_dep_type           := ''  ;
  c_last_dep_currency       := ''  ;
  c_last_dep_amount         := l_dummy  ;
  c_last_dep_converted      := ''	  ;
  c_last_dep_date           := ''   ;
  c_last_dep_days_since     := '' ;

OPEN C_DEP ;

FETCH C_DEP
INTO
    l_last_dep_number ,
    l_last_dep_type ,
    l_last_dep_currency,
    l_last_dep_amount,
    l_last_dep_converted	,
    l_last_dep_date ,
    l_last_dep_days_since
    ;
CLOSE C_DEP ;

if l_last_dep_number is NOT NULL then
  c_last_dep_number         := l_last_dep_number   ;
  c_last_dep_type           := l_last_dep_type   ;
  c_last_dep_currency       := l_last_dep_currency  ;
  c_last_dep_amount         := l_last_dep_amount  ;
  c_last_dep_converted      := l_last_dep_converted	  ;
  c_last_dep_date           := l_last_dep_date   ;
  c_last_dep_days_since     := l_last_dep_days_since  ;
else
  c_last_dep_number         := rp_none   ;
end if ;
return (0);

EXCEPTION WHEN NO_DATA_FOUND THEN
  c_last_dep_number         := rp_none;
  c_last_dep_type           := l_last_dep_type   ;
  c_last_dep_currency       := l_last_dep_currency  ;
  c_last_dep_amount         := l_last_dep_amount  ;
  c_last_dep_converted      := l_last_dep_converted	  ;
  c_last_dep_date           := l_last_dep_date   ;
  c_last_dep_days_since     := l_last_dep_days_since  ;

WHEN OTHERS THEN
  /*SRW.MESSAGE (1010,'Error in C_DEP FORMULA');*/null;

  return (0);
END ;

RETURN NULL; end;

function c_last_dm_formulaformula(functional_currency in varchar2, CUSTOMER_ID in number, site_use_id in number) return number is
begin

DECLARE
l_last_dm_number        VARCHAR2 (100);
l_last_dm_type          VARCHAR2 (100);
l_last_dm_currency      VARCHAR2 (20);
l_last_dm_amount        NUMBER ;
l_last_dm_converted     VARCHAR2 (1);
l_last_dm_date          VARCHAR2 (11);
l_last_dm_days_since    VARCHAR2 (11);
l_dummy                 NUMBER (1);

CURSOR C_DM IS
SELECT	RA_CUSTOMER_TRX.TRX_NUMBER,
	RA_CUST_TRX_TYPES.NAME,
	AR_PAYMENT_SCHEDULES.INVOICE_CURRENCY_CODE,
	AR_PAYMENT_SCHEDULES.AMOUNT_DUE_ORIGINAL,
        DECODE(AR_PAYMENT_SCHEDULES.INVOICE_CURRENCY_CODE,functional_currency, ' ',
		DECODE(AR_PAYMENT_SCHEDULES.EXCHANGE_RATE, NULL, '*', ' ')),
	RA_CUSTOMER_TRX.TRX_DATE,
	ROUND(TRUNC(SYSDATE) - RA_CUSTOMER_TRX.TRX_DATE)
FROM	RA_CUST_TRX_TYPES,
	RA_CUSTOMER_TRX,
	AR_PAYMENT_SCHEDULES
WHERE	AR_PAYMENT_SCHEDULES.CUSTOMER_TRX_ID = RA_CUSTOMER_TRX.CUSTOMER_TRX_ID
AND	RA_CUSTOMER_TRX.CUST_TRX_TYPE_ID = RA_CUST_TRX_TYPES.CUST_TRX_TYPE_ID
AND	RA_CUSTOMER_TRX.BILL_TO_CUSTOMER_ID = CUSTOMER_ID
AND	AR_PAYMENT_SCHEDULES.Customer_site_use_id = site_use_id
AND	AR_PAYMENT_SCHEDULES.CLASS = 'DM'
ORDER BY RA_CUSTOMER_TRX.TRX_DATE DESC,
	 RA_CUSTOMER_TRX.CUSTOMER_TRX_ID DESC
;

BEGIN


  c_last_dm_number         := ''   ;
  c_last_dm_type           := ''   ;
  c_last_dm_currency       := '' ;
  c_last_dm_amount         := l_dummy  ;
  c_last_dm_converted      := 	''  ;
  c_last_dm_date           := '' ;
  c_last_dm_days_since     := ''  ;
/*srw.reference (site_use_id);*/null;

/*srw.reference (customer_id);*/null;

OPEN C_DM ;

FETCH C_DM
INTO
    l_last_dm_number ,
    l_last_dm_type ,
    l_last_dm_currency,
    l_last_dm_amount,
    l_last_dm_converted	,
    l_last_dm_date ,
    l_last_dm_days_since
    ;


CLOSE C_DM ;

if l_last_dm_number is NOT NULL then
  c_last_dm_number         := l_last_dm_number   ;
  c_last_dm_type           := l_last_dm_type   ;
  c_last_dm_currency       := l_last_dm_currency  ;
  c_last_dm_amount         := l_last_dm_amount  ;
  c_last_dm_converted      := l_last_dm_converted	  ;
  c_last_dm_date           := l_last_dm_date   ;
  c_last_dm_days_since     := l_last_dm_days_since  ;
else
  c_last_dm_number         := rp_none   ;
end if ;

  return (0);
EXCEPTION WHEN NO_DATA_FOUND THEN
  c_last_dm_number         := rp_none;
  c_last_dm_type           := l_last_dm_type   ;
  c_last_dm_currency       := l_last_dm_currency  ;
  c_last_dm_amount         := l_last_dm_amount  ;
  c_last_dm_converted      := l_last_dm_converted	  ;
  c_last_dm_date           := l_last_dm_date   ;
  c_last_dm_days_since     := l_last_dm_days_since  ;

WHEN OTHERS THEN
  /*SRW.MESSAGE (1010,'Error in C_DM FORMULA');*/null;

  return (0);
END ;

RETURN NULL; end;

function c_last_cb_formulaformula(functional_currency in varchar2, CUSTOMER_ID in number, site_use_id in number) return number is
begin

DECLARE
l_last_cb_number        VARCHAR2 (100);
l_last_cb_type          VARCHAR2 (100);
l_last_cb_currency      VARCHAR2 (20);
l_last_cb_amount        NUMBER ;
l_last_cb_converted     VARCHAR2 (1);
l_last_cb_date          VARCHAR2 (11);
l_last_cb_days_since    VARCHAR2 (11);
l_dummy                 NUMBER (1);

CURSOR C_CB IS
SELECT	RA_CUSTOMER_TRX.TRX_NUMBER,
	RA_CUST_TRX_TYPES.NAME,
	AR_PAYMENT_SCHEDULES.INVOICE_CURRENCY_CODE,
	AR_PAYMENT_SCHEDULES.AMOUNT_DUE_ORIGINAL,
        DECODE(AR_PAYMENT_SCHEDULES.INVOICE_CURRENCY_CODE, functional_currency, ' ',
		DECODE(AR_PAYMENT_SCHEDULES.EXCHANGE_RATE, NULL, '*', ' ')),
	RA_CUSTOMER_TRX.TRX_DATE,
	ROUND(TRUNC(SYSDATE) - RA_CUSTOMER_TRX.TRX_DATE)
FROM	RA_CUST_TRX_TYPES,
	RA_CUSTOMER_TRX,
	AR_PAYMENT_SCHEDULES
WHERE	AR_PAYMENT_SCHEDULES.CUSTOMER_TRX_ID = RA_CUSTOMER_TRX.CUSTOMER_TRX_ID
AND	RA_CUSTOMER_TRX.CUST_TRX_TYPE_ID = RA_CUST_TRX_TYPES.CUST_TRX_TYPE_ID
AND	RA_CUSTOMER_TRX.BILL_TO_CUSTOMER_ID = CUSTOMER_ID
AND	AR_PAYMENT_SCHEDULES.Customer_site_use_id = site_use_id
AND	AR_PAYMENT_SCHEDULES.CLASS = 'CB'
ORDER BY RA_CUSTOMER_TRX.TRX_DATE DESC,
	 RA_CUSTOMER_TRX.CUSTOMER_TRX_ID DESC
;

BEGIN

/*srw.reference (customer_id);*/null;

/*srw.reference (site_use_id);*/null;

  c_last_cb_number         := ''   ;
  c_last_cb_type           := ''  ;
  c_last_cb_currency       := '' ;
  c_last_cb_amount         :=  l_dummy ;
  c_last_cb_converted      := 	 '' ;
  c_last_cb_date           := '' ;
  c_last_cb_days_since     := '' ;

OPEN C_CB ;

FETCH C_CB
INTO
    l_last_cb_number ,
    l_last_cb_type ,
    l_last_cb_currency,
    l_last_cb_amount,
    l_last_cb_converted	,
    l_last_cb_date ,
    l_last_cb_days_since
    ;
CLOSE   C_CB ;
if l_last_cb_number is NOT NULL then
  c_last_cb_number         := l_last_cb_number   ;
  c_last_cb_type           := l_last_cb_type   ;
  c_last_cb_currency       := l_last_cb_currency  ;
  c_last_cb_amount         := l_last_cb_amount  ;
  c_last_cb_converted      := l_last_cb_converted	  ;
  c_last_cb_date           := l_last_cb_date   ;
  c_last_cb_days_since     := l_last_cb_days_since  ;
else
  c_last_cb_number         := rp_none   ;
end if ;

  return (0);
EXCEPTION WHEN NO_DATA_FOUND THEN
  c_last_cb_number         := rp_none;
  c_last_cb_type           := l_last_cb_type   ;
  c_last_cb_currency       := l_last_cb_currency  ;
  c_last_cb_amount         := l_last_cb_amount  ;
  c_last_cb_converted      := l_last_cb_converted	  ;
  c_last_cb_date           := l_last_cb_date   ;
  c_last_cb_days_since     := l_last_cb_days_since  ;

WHEN OTHERS THEN
  /*SRW.MESSAGE (1010,'Error in C_CB FORMULA');*/null;

  return (0);
END ;

RETURN NULL; end;

function c_last_payment_formulaformula(functional_currency in varchar2, CUSTOMER_ID in number, site_use_id in number) return number is
begin

DECLARE

l_last_payment_number            VARCHAR2 (100);
l_last_payment_type              VARCHAR2 (100);
l_last_payment_currency          VARCHAR2 (20);
l_last_payment_amount            NUMBER ;
l_last_payment_converted         VARCHAR2 (1);
l_last_payment_date              VARCHAR2 (11);
l_last_payment_days_since        VARCHAR2 (11);
l_last_payment_rel_invoice       VARCHAR2 (100);
l_dummy                          NUMBER (1);

CURSOR C_PAYMENT IS
SELECT	AR_CASH_RECEIPTS.RECEIPT_NUMBER,
	AR_LOOKUPS.MEANING,
	AR_CASH_RECEIPTS.CURRENCY_CODE,
	AR_CASH_RECEIPTS.AMOUNT,
        DECODE(AR_CASH_RECEIPTS.CURRENCY_CODE, functional_currency, ' ',
		DECODE(AR_CASH_RECEIPTS.EXCHANGE_RATE, NULL, '*', ' ')),
	CRH.GL_DATE,
	ROUND(TRUNC(SYSDATE) - CRH.GL_DATE),
	RA_CUSTOMER_TRX.TRX_NUMBER
FROM	AR_LOOKUPS,
	AR_CASH_RECEIPTS,
	AR_CASH_RECEIPT_HISTORY CRH,
	AR_RECEIVABLE_APPLICATIONS,
     	RA_CUSTOMER_TRX
WHERE	NVL(AR_CASH_RECEIPTS.TYPE, 'CASH') = AR_LOOKUPS.LOOKUP_CODE
AND	AR_LOOKUPS.LOOKUP_TYPE = 'PAYMENT_CATEGORY_TYPE'
AND	AR_CASH_RECEIPTS.PAY_FROM_CUSTOMER = CUSTOMER_ID
AND 	AR_CASH_RECEIPTS.CUSTOMER_SITE_USE_ID = site_use_id
AND	AR_CASH_RECEIPTS.CASH_RECEIPT_ID =
		AR_RECEIVABLE_APPLICATIONS.CASH_RECEIPT_ID
AND 	AR_CASH_RECEIPTS.CASH_RECEIPT_ID = CRH.CASH_RECEIPT_ID
AND     CRH.FIRST_POSTED_RECORD_FLAG = 'Y'
AND	AR_RECEIVABLE_APPLICATIONS.APPLIED_CUSTOMER_TRX_ID =
			RA_CUSTOMER_TRX.CUSTOMER_TRX_ID (+)
ORDER BY AR_CASH_RECEIPTS.CREATION_DATE DESC,
	AR_CASH_RECEIPTS.CASH_RECEIPT_ID DESC,
	AR_RECEIVABLE_APPLICATIONS.CREATION_DATE DESC
	;

BEGIN

/*srw.reference (customer_id);*/null;

/*srw.reference (site_use_id);*/null;

  c_last_payment_number       :=  '' ;
  c_last_payment_type         := '' ;
  c_last_payment_currency     := ''  ;
  c_last_payment_amount       := l_dummy ;
  c_last_payment_converted    := '' ;
  c_last_payment_date         := ''   ;
  c_last_payment_days_since   := '' ;
  c_last_payment_rel_invoice  :=  '' ;

OPEN C_PAYMENT ;

FETCH C_PAYMENT INTO
	l_last_payment_number ,
	l_last_payment_type,
	l_last_payment_currency ,
	l_last_payment_amount,
	l_last_payment_converted,
	l_last_payment_date ,
	l_last_payment_days_since ,
	l_last_payment_rel_invoice
        ;
CLOSE C_PAYMENT ;

if  l_last_payment_number is NOT NULL then

  c_last_payment_number       := l_last_payment_number   ;
  c_last_payment_type         := l_last_payment_type  ;
  c_last_payment_currency     := l_last_payment_currency   ;
  c_last_payment_amount       := l_last_payment_amount  ;
  c_last_payment_converted    := l_last_payment_converted  ;
  c_last_payment_date         := l_last_payment_date   ;
  c_last_payment_days_since   := l_last_payment_days_since   ;
  c_last_payment_rel_invoice  := l_last_payment_rel_invoice  ;

else

  c_last_payment_number       := rp_none   ;
end if ;

return (0);

EXCEPTION WHEN NO_DATA_FOUND THEN
  c_last_payment_number       := rp_none   ;
  c_last_payment_type         := l_last_payment_type  ;
  c_last_payment_currency     := l_last_payment_currency   ;
  c_last_payment_amount       := l_last_payment_amount  ;
  c_last_payment_converted    := l_last_payment_converted  ;
  c_last_payment_date         := l_last_payment_date   ;
  c_last_payment_days_since   := l_last_payment_days_since   ;
  c_last_payment_rel_invoice  := l_last_payment_rel_invoice  ;

return (0);

END ;

RETURN NULL; end;

function c_last_adj_formulaformula(functional_currency in varchar2, CUSTOMER_ID in number, site_use_id in number) return number is
begin

DECLARE
l_last_adj_type                VARCHAR2 (100);
l_last_adj_rel_invoice         VARCHAR2 (100);
l_last_adj_currency            VARCHAR2 (20);
l_last_adj_amount              NUMBER ;
l_last_adj_converted           VARCHAR2 (1);
l_last_adj_date                VARCHAR2 (11);
l_last_adj_days_since          VARCHAR2 (11);
l_dummy                        NUMBER (1);

CURSOR C_ADJUSTMENT IS
SELECT	LK.MEANING,
	AR_PAYMENT_SCHEDULES.TRX_NUMBER,
	ar_payment_schedules.invoice_currency_code,
	AR_ADJUSTMENTS.AMOUNT,
        DECODE(AR_PAYMENT_SCHEDULES.INVOICE_CURRENCY_CODE, functional_currency, ' ',
		DECODE(AR_PAYMENT_SCHEDULES.EXCHANGE_RATE, NULL, '*', ' ')),
	AR_ADJUSTMENTS.APPLY_DATE,
	ROUND(TRUNC(SYSDATE) - AR_ADJUSTMENTS.APPLY_DATE)
FROM	AR_ADJUSTMENTS,
	AR_LOOKUPS LK,
	AR_PAYMENT_SCHEDULES
WHERE	AR_ADJUSTMENTS.REASON_CODE = LK.LOOKUP_CODE (+)
AND 	LK.LOOKUP_TYPE = 'ADJUST_REASON'
AND	AR_ADJUSTMENTS.PAYMENT_SCHEDULE_ID =
		AR_PAYMENT_SCHEDULES.PAYMENT_SCHEDULE_ID
AND	NVL(AR_ADJUSTMENTS.POSTABLE, 'Y') = 'Y'
AND	AR_PAYMENT_SCHEDULES.CUSTOMER_ID = CUSTOMER_ID
AND	AR_PAYMENT_SCHEDULES.CUSTOMER_SITE_USE_ID = site_use_id
ORDER BY AR_ADJUSTMENTS.CREATION_DATE DESC,
	AR_ADJUSTMENTS.ADJUSTMENT_ID DESC
	;


BEGIN

/*srw.reference (customer_id);*/null;

/*srw.reference (site_use_id);*/null;

  c_last_adj_number            := '' ;
  c_last_adj_type              := ''                  ;
  c_last_adj_rel_invoice       := ''   ;
  c_last_adj_currency          := ''  ;
  c_last_adj_amount            := l_dummy  ;
  c_last_adj_converted         := '' ;
  c_last_adj_date              := ''  ;
  c_last_adj_days_since        := ''  ;

OPEN C_ADJUSTMENT ;

FETCH C_ADJUSTMENT  INTO
  l_last_adj_type     ,
  l_last_adj_rel_invoice  ,
  l_last_adj_currency ,
  l_last_adj_amount  ,
  l_last_adj_converted ,
  l_last_adj_date  ,
  l_last_adj_days_since
  ;

if l_last_adj_amount is NOT NULL then

  c_last_adj_number := rp_na_upper ;
  c_last_adj_type              := l_last_adj_type                  ;
  c_last_adj_rel_invoice       := l_last_adj_rel_invoice   ;
  c_last_adj_currency          := l_last_adj_currency  ;
  c_last_adj_amount            := l_last_adj_amount   ;
  c_last_adj_converted         := l_last_adj_converted   ;
  c_last_adj_date              := l_last_adj_date   ;
  c_last_adj_days_since        := l_last_adj_days_since  ;
else
  c_last_adj_number := rp_none ;
end if ;

return (0);

EXCEPTION WHEN NO_DATA_FOUND THEN
  c_last_adj_number := rp_none ;
  c_last_adj_type              := l_last_adj_type                  ;
  c_last_adj_rel_invoice       := l_last_adj_rel_invoice   ;
  c_last_adj_currency          := l_last_adj_currency  ;
  c_last_adj_amount            := l_last_adj_amount   ;
  c_last_adj_converted         := l_last_adj_converted   ;
  c_last_adj_date              := l_last_adj_date   ;
  c_last_adj_days_since        := l_last_adj_days_since  ;

return (0);

END ;


RETURN NULL; end;

function c_last_writeoff_formulaformula(functional_currency in varchar2, CUSTOMER_ID in number, site_use_id in number) return number is
begin

DECLARE
l_last_wo_type          VARCHAR2 (100);
l_last_wo_rel_invoice   VARCHAR2 (100);
l_last_wo_currency      VARCHAR2 (100);
l_last_wo_amount        NUMBER ;
l_last_wo_converted     VARCHAR2 (1);
l_last_wo_date          VARCHAR2 (11);
l_last_wo_days_since    VARCHAR2 (11);
l_dummy                 NUMBER (1);

CURSOR C_WRITEOFF  IS
SELECT	LK.LOOKUP_CODE,
        AR_PAYMENT_SCHEDULES.TRX_NUMBER,
	AR_PAYMENT_SCHEDULES.INVOICE_CURRENCY_CODE,
	AR_ADJUSTMENTS.AMOUNT,
        DECODE(AR_PAYMENT_SCHEDULES.INVOICE_CURRENCY_CODE, functional_currency, ' ',
		DECODE(AR_PAYMENT_SCHEDULES.EXCHANGE_RATE, NULL, '*', ' ')),
	AR_ADJUSTMENTS.APPLY_DATE,
	ROUND(TRUNC(SYSDATE) - AR_ADJUSTMENTS.APPLY_DATE)
FROM	AR_ADJUSTMENTS,
	AR_LOOKUPS LK,
	AR_PAYMENT_SCHEDULES
WHERE	AR_ADJUSTMENTS.REASON_CODE
		= LK.LOOKUP_CODE(+)
AND	AR_ADJUSTMENTS.CUSTOMER_TRX_ID = AR_PAYMENT_SCHEDULES.CUSTOMER_TRX_ID
AND	NVL(AR_ADJUSTMENTS.POSTABLE, 'Y') = 'Y'
AND	LK.LOOKUP_CODE(+) = 'WRITE OFF'
AND 	LK.LOOKUP_TYPE(+) = 'ADJUST_REASON'
AND	AR_PAYMENT_SCHEDULES.CUSTOMER_ID = CUSTOMER_ID
AND	AR_PAYMENT_SCHEDULES.CUSTOMER_SITE_USE_ID = site_use_id
ORDER BY AR_ADJUSTMENTS.CREATION_DATE DESC,
	AR_ADJUSTMENTS.ADJUSTMENT_ID DESC
;

BEGIN


/*srw.reference (customer_id);*/null;

/*srw.reference (site_use_id);*/null;

  c_last_wo_number          := ''   ;
  c_last_wo_type            := ''  ;
  c_last_wo_rel_invoice     := ''   ;
  c_last_wo_currency        := ''  ;
  c_last_wo_amount          := l_dummy   ;
  c_last_wo_converted       := ''   ;
  c_last_wo_date            := ''  ;
  c_last_wo_days_since      := '' ;

OPEN C_WRITEOFF ;


FETCH C_WRITEOFF INTO
	l_last_wo_type  ,
	l_last_wo_rel_invoice ,
	l_last_wo_currency,
	l_last_wo_amount ,
	l_last_wo_converted ,
	l_last_wo_date ,
	l_last_wo_days_since
	;

if l_last_wo_amount is NOT NULL THEN
  c_last_wo_number          := rp_na_upper   ;
  c_last_wo_type            := l_last_wo_type   ;
  c_last_wo_rel_invoice     := l_last_wo_rel_invoice   ;
  c_last_wo_currency        := l_last_wo_currency  ;
  c_last_wo_amount          := l_last_wo_amount   ;
  c_last_wo_converted       := l_last_wo_converted   ;
  c_last_wo_date            := l_last_wo_date   ;
  c_last_wo_days_since      := l_last_wo_days_since  ;
else
  c_last_wo_number          := rp_none   ;
end if ;

CLOSE C_WRITEOFF ;
return (0);

EXCEPTION  WHEN NO_DATA_FOUND THEN
  c_last_wo_number          := rp_none   ;
  c_last_wo_type            := l_last_wo_type   ;
  c_last_wo_rel_invoice     := l_last_wo_rel_invoice   ;
  c_last_wo_currency        := l_last_wo_currency  ;
  c_last_wo_amount          := l_last_wo_amount   ;
  c_last_wo_converted       := l_last_wo_converted   ;
  c_last_wo_date            := l_last_wo_date   ;
  c_last_wo_days_since      := l_last_wo_days_since  ;
  return (0);
WHEN OTHERS THEN
/*srw.message (1020,' Error in Write off Formula ');*/null;

return (0);

END ;




RETURN NULL; end;

function c_last_statement_formulaformul(CUSTOMER_ID in number, site_use_id in number) return number is
begin

DECLARE

l_last_st_type      VARCHAR2 (100);
l_last_st_date      VARCHAR2 (11);
l_last_st_days_since VARCHAR2 (100);

CURSOR C_STATEMENT IS
SELECT	AR_STATEMENT_CYCLES.NAME,
	AR_STATEMENT_CYCLE_DATES.STATEMENT_DATE,
	TRUNC(TRUNC(SYSDATE) - AR_STATEMENT_CYCLE_DATES.STATEMENT_DATE)
FROM	HZ_CUSTOMER_PROFILES, AR_STATEMENT_CYCLES,
	AR_STATEMENT_CYCLE_DATES
WHERE	HZ_CUSTOMER_PROFILES.STATEMENT_CYCLE_ID =
		AR_STATEMENT_CYCLES.STATEMENT_CYCLE_ID
AND	AR_STATEMENT_CYCLES.STATEMENT_CYCLE_ID =
		AR_STATEMENT_CYCLE_DATES.STATEMENT_CYCLE_ID
AND	AR_STATEMENT_CYCLE_DATES.PRINTED = 'Y'
AND	HZ_CUSTOMER_PROFILES.CUST_ACCOUNT_ID = CUSTOMER_ID
AND	HZ_CUSTOMER_PROFILES.site_use_id = site_use_id
ORDER BY AR_STATEMENT_CYCLE_DATES.STATEMENT_DATE DESC,
	AR_STATEMENT_CYCLE_DATES.STATEMENT_CYCLE_DATE_ID DESC ;

CURSOR C_STATEMENT_DEFAULT IS
SELECT	AR_STATEMENT_CYCLES.NAME,
	AR_STATEMENT_CYCLE_DATES.STATEMENT_DATE,
	TRUNC(TRUNC(SYSDATE) - AR_STATEMENT_CYCLE_DATES.STATEMENT_DATE)
FROM	HZ_CUSTOMER_PROFILES, AR_STATEMENT_CYCLES,
	AR_STATEMENT_CYCLE_DATES
WHERE	HZ_CUSTOMER_PROFILES.STATEMENT_CYCLE_ID =
		AR_STATEMENT_CYCLES.STATEMENT_CYCLE_ID
AND	AR_STATEMENT_CYCLES.STATEMENT_CYCLE_ID =
		AR_STATEMENT_CYCLE_DATES.STATEMENT_CYCLE_ID
AND	AR_STATEMENT_CYCLE_DATES.PRINTED = 'Y'
AND	HZ_CUSTOMER_PROFILES.CUST_ACCOUNT_ID = CUSTOMER_ID
AND	HZ_CUSTOMER_PROFILES.site_use_id is null
ORDER BY AR_STATEMENT_CYCLE_DATES.STATEMENT_DATE DESC,
	AR_STATEMENT_CYCLE_DATES.STATEMENT_CYCLE_DATE_ID DESC
;

BEGIN

/*srw.reference (customer_id );*/null;

/*srw.reference (site_use_id);*/null;

  c_last_st_number         := '' ;
  c_last_st_type           := '';
  c_last_st_date           := '';
  c_last_st_days_since     := '' ;
  c_last_stmnt_next_trx_date := '';
if c_profile_site_use_id is NOT NULL then

  OPEN C_STATEMENT ;

  FETCH C_STATEMENT
  INTO
  l_last_st_type      ,
  l_last_st_date      ,
  l_last_st_days_since
  ;
  CLOSE C_STATEMENT ;
else
  OPEN C_STATEMENT_DEFAULT ;

  FETCH C_STATEMENT_DEFAULT
  INTO
  l_last_st_type      ,
  l_last_st_date      ,
  l_last_st_days_since
  ;
  CLOSE C_STATEMENT_DEFAULT ;
end if ;

if l_last_st_date  is NOT NULL then
  c_last_st_number         := rp_na_upper ;
  c_last_st_type           := l_last_st_type ;
  c_last_st_date           := l_last_st_date;
  c_last_st_days_since     := l_last_st_days_since ;

    DECLARE
      l_last_stmnt_next_trx_date   VARCHAR2 (11);

      BEGIN
      SELECT	MIN(AR_STATEMENT_CYCLE_DATES.STATEMENT_DATE)
      INTO	l_last_stmnt_next_trx_date
      FROM	HZ_CUSTOMER_PROFILES,
	      AR_STATEMENT_CYCLE_DATES
      WHERE	HZ_CUSTOMER_PROFILES.STATEMENT_CYCLE_ID =
		      AR_STATEMENT_CYCLE_DATES.STATEMENT_CYCLE_ID
      AND	AR_STATEMENT_CYCLE_DATES.PRINTED = 'N'
      AND	AR_STATEMENT_CYCLE_DATES.STATEMENT_DATE > to_date(c_last_st_date,'DD-MM-YYYY')
      AND	HZ_CUSTOMER_PROFILES.CUST_ACCOUNT_ID = CUSTOMER_ID
      AND	HZ_CUSTOMER_PROFILES.SITE_USE_ID IS NULL
      ORDER BY AR_STATEMENT_CYCLE_DATES.STATEMENT_DATE,
	      AR_STATEMENT_CYCLE_DATES.STATEMENT_CYCLE_DATE_ID
	      ;

      c_last_stmnt_next_trx_date  := nvl(l_last_stmnt_next_trx_date,rp_none) ;
      EXCEPTION WHEN NO_DATA_FOUND THEN
      c_last_stmnt_next_trx_date  := rp_none;
    END ;
else
  c_last_st_number         := rp_none ;
end if ;

return (0);

EXCEPTION WHEN NO_DATA_FOUND THEN

  c_last_st_number         := rp_none ;
  c_last_st_type           := l_last_st_type ;
  c_last_st_date           := l_last_st_date;
  c_last_st_days_since     := l_last_st_days_since ;

  return (0);
WHEN OTHERS THEN
/*SRW.MESSAGE (10023,' Error in STATEMENT Formula');*/null;

raise;
END ;


RETURN NULL; end;

--function c_last_dn_formulaformula(CUSTOMER_ID in number, site_use_id_1 in number) return number is
function c_last_dn_formulaformula(CUSTOMER_ID_1 in number, site_use_id_1 in number) return number is
begin

DECLARE
l_last_dn_amount     NUMBER ;
l_last_dn_type       VARCHAR2 (100);
l_last_dn_currency   VARCHAR2 (20);
l_last_dn_date       VARCHAR2 (11);
l_last_dn_days_since VARCHAR2 (11);
l_dummy              NUMBER (1);
l_iex_creation_date  VARCHAR2 (11);
l_iex_last_dn_days_since VARCHAR2 (11);

CURSOR IEX_DUNNING IS
SELECT MAX(creation_date),
       TRUNC(SYSDATE) - MAX(creation_date)
FROM iex_dunnings
--WHERE (dunning_level = 'ACCOUNT' AND dunning_object_id = CUSTOMER_ID)
WHERE (dunning_level = 'ACCOUNT' AND dunning_object_id = CUSTOMER_ID_1)
--OR (dunning_level = 'BILL_TO' AND dunning_object_id = site_use_id);
OR (dunning_level = 'BILL_TO' AND dunning_object_id = site_use_id_1);


CURSOR C_DUNNING IS
SELECT ROUND(SUM(CPS.AMOUNT_DUE_REMAINING + CPS.AMOUNT_ACCRUE +
CPS.AMOUNT_UNACCRUE), 2),
CORR.CORRESPONDENCE_TYPE,
ps.invoice_currency_code,
MAX(CORR.CORRESPONDENCE_DATE),
TRUNC(SYSDATE) - MAX(CORR.CORRESPONDENCE_DATE)
FROM ar_payment_schedules ps,
ar_correspondence_pay_sched cps,
AR_DUNNING_LETTERS DUNN,
        AR_CORRESPONDENCES CORR
WHERE CORR.REFERENCE1 = DUNN.DUNNING_LETTER_ID
AND CORR.CORRESPONDENCE_ID = CPS.CORRESPONDENCE_ID
--and CORR.site_use_id = site_use_id
and CORR.site_use_id = site_use_id_1
and cps.payment_schedule_id = ps.payment_schedule_id
AND CORR.CORRESPONDENCE_TYPE = 'DUNNING'
--AND CORR.CUSTOMER_ID = CUSTOMER_ID
AND CORR.CUSTOMER_ID = CUSTOMER_ID_1
GROUP BY ps.invoice_currency_code, CORR.CORRESPONDENCE_TYPE,
CPS.AMOUNT_DUE_REMAINING,
CPS.AMOUNT_ACCRUE, DUNN.LETTER_NAME, CORR.CORRESPONDENCE_DATE
ORDER BY CORR.CORRESPONDENCE_DATE DESC ;

BEGIN

/*srw.reference (customer_id);*/null;

/*srw.reference (site_use_id);*/null;


  c_last_dn_number       := ''   ;
  c_last_dn_amount       := l_dummy  ;
  c_last_dn_type         := ''   ;
  c_last_dn_currency     := ''  ;
  c_last_dn_date         := ''   ;
  c_last_dn_days_since   := ''   ;

OPEN IEX_DUNNING;

FETCH IEX_DUNNING INTO
l_iex_creation_date,
l_iex_last_dn_days_since;
CLOSE IEX_DUNNING;

IF l_iex_creation_date IS NOT NULL then
   c_last_dn_number       := rp_na_upper;
   c_last_dn_amount       := null;
   c_last_dn_type         := 'DUNNING';
   c_last_dn_currency     := null;
   c_last_dn_date         := l_iex_creation_date;
   c_last_dn_days_since   := l_iex_last_dn_days_since;

ELSE

OPEN C_DUNNING ;

FETCH C_DUNNING INTO
l_last_dn_amount ,
l_last_dn_type,
l_last_dn_currency ,
l_last_dn_date ,
l_last_dn_days_since ;
CLOSE C_DUNNING ;

if l_last_dn_type is NOT NULL then

   c_last_dn_number       := rp_na_upper   ;
   c_last_dn_amount       := l_last_dn_amount    ;
   c_last_dn_type         := l_last_dn_type   ;
   c_last_dn_currency     := l_last_dn_currency    ;
   c_last_dn_date         := l_last_dn_date    ;
   c_last_dn_days_since   := l_last_dn_days_since    ;
 else

   c_last_dn_number       := rp_none   ;
 end if ;
END IF;
 return (0);

 EXCEPTION WHEN NO_DATA_FOUND THEN

   c_last_dn_number       := rp_none   ;
   c_last_dn_amount       := l_last_dn_amount    ;
   c_last_dn_type         := l_last_dn_type   ;
   c_last_dn_currency     := l_last_dn_currency    ;
   c_last_dn_date         := l_last_dn_date    ;
   c_last_dn_days_since   := l_last_dn_days_since    ;
   return (0);

 WHEN OTHERS THEN
   /*srw.message (10000,'Error in Dunning formula column');*/null;

   return (0);

 END ;

 RETURN NULL; end;

function c_last_nsf_formulaformula(functional_currency in varchar2, CUSTOMER_ID in number, site_use_id in number) return number is
begin

DECLARE
l_last_nsf_number        VARCHAR2 (100);
l_last_nsf_type          VARCHAR2 (100);
l_last_nsf_currency      VARCHAR2 (20);
l_last_nsf_amount        NUMBER ;
l_last_nsf_converted     VARCHAR2 (1);
l_last_nsf_date          VARCHAR2 (11);
l_last_nsf_days_since    VARCHAR2 (11);
l_dummy                 NUMBER (1);

CURSOR C_NSF IS
SELECT	AR_CASH_RECEIPTS.RECEIPT_NUMBER,
	AR_CASH_RECEIPTS.STATUS,
	currency_code,
	AR_CASH_RECEIPTS.AMOUNT,
        DECODE(AR_CASH_RECEIPTS.CURRENCY_CODE,functional_currency, ' ',
		DECODE(AR_CASH_RECEIPTS.EXCHANGE_RATE, NULL, '*', ' ')),
	AR_CASH_RECEIPTS.REVERSAL_DATE,
	ROUND(TRUNC(SYSDATE) - AR_CASH_RECEIPTS.REVERSAL_DATE)
FROM	AR_CASH_RECEIPTS
WHERE	AR_CASH_RECEIPTS.STATUS IN ('NSF','STOP')
AND	AR_CASH_RECEIPTS.PAY_FROM_CUSTOMER = CUSTOMER_ID
AND	AR_CASH_RECEIPTS.CUSTOMER_SITE_USE_ID = site_use_id
ORDER BY AR_CASH_RECEIPTS.REVERSAL_DATE DESC,
	AR_CASH_RECEIPTS.CASH_RECEIPT_ID DESC
;

BEGIN


  c_last_nsf_number         := ''   ;
  c_last_nsf_type           := ''   ;
  c_last_nsf_currency       := '' ;
  c_last_nsf_amount         := l_dummy  ;
  c_last_nsf_converted      := 	''  ;
  c_last_nsf_date           := '' ;
  c_last_nsf_days_since     := ''  ;
/*srw.reference (site_use_id);*/null;

/*srw.reference (customer_id);*/null;

/*srw.message (500, 'DEBUG:  Customer id:    ' || to_char(customer_id));*/null;

/*srw.message (500, 'DEBUG:  Site Use id:    ' || to_char(site_use_id));*/null;

OPEN C_NSF ;

FETCH C_NSF
INTO
    l_last_nsf_number ,
    l_last_nsf_type ,
    l_last_nsf_currency,
    l_last_nsf_amount,
    l_last_nsf_converted	,
    l_last_nsf_date ,
    l_last_nsf_days_since
    ;


CLOSE C_NSF ;

if l_last_nsf_number is NOT NULL then
  c_last_nsf_number         := l_last_nsf_number   ;
  c_last_nsf_type           := l_last_nsf_type   ;
  c_last_nsf_currency       := l_last_nsf_currency  ;
  c_last_nsf_amount         := l_last_nsf_amount  ;
  c_last_nsf_converted      := l_last_nsf_converted	  ;
  c_last_nsf_date           := l_last_nsf_date   ;
  c_last_nsf_days_since     := l_last_nsf_days_since  ;
else
  c_last_nsf_number         := rp_none   ;
end if ;

  return (0);
EXCEPTION WHEN NO_DATA_FOUND THEN
  c_last_nsf_number         := rp_none;
  c_last_nsf_type           := l_last_nsf_type   ;
  c_last_nsf_currency       := l_last_nsf_currency  ;
  c_last_nsf_amount         := l_last_nsf_amount  ;
  c_last_nsf_converted      := l_last_nsf_converted	  ;
  c_last_nsf_date           := l_last_nsf_date   ;
  c_last_nsf_days_since     := l_last_nsf_days_since  ;

WHEN OTHERS THEN
  /*SRW.MESSAGE (1010,'Error in C_NSF FORMULA');*/null;

  return (0);
END ;

RETURN NULL; end;

--function c_last_contact_formulaformula(functional_currency in varchar2, CUSTOMER_ID in number, site_use_id in --number) return number is
function c_last_contact_formulaformula(functional_currency in varchar2, CUSTOMER_ID_1 in number, site_use_id_1 in number) return number is
begin

DECLARE
l_last_contact_number        VARCHAR2 (100);
l_last_contact_rel_invoice   VARCHAR2 (100);
l_last_contact_currency      VARCHAR2 (20);
l_last_contact_amount        NUMBER ;
l_last_contact_converted     VARCHAR2 (1);
l_last_contact_date          VARCHAR2 (11);
l_last_contact_days_since    VARCHAR2 (11);
l_dummy                 NUMBER (1);

CURSOR C_CONTACT IS

SELECT  cont_point.phone_area_code||'-' ||
              RTRIM(RPAD(decode(cont_point.contact_point_type,
                                'TLX', cont_point.telex_number,
                                cont_point.phone_number),15)),
	AR_PAYMENT_SCHEDULES.TRX_NUMBER,
	AR_PAYMENT_SCHEDULES.invoice_currency_code,
	AR_CALL_ACTIONS.ACTION_AMOUNT,
	DECODE(AR_CALL_ACTIONS.ACTION_AMOUNT, NULL, NULL,
        DECODE(AR_PAYMENT_SCHEDULES.INVOICE_CURRENCY_CODE, functional_currency, ' ',
		DECODE(AR_PAYMENT_SCHEDULES.EXCHANGE_RATE, NULL, '*', ' '))),
	AR_CUSTOMER_CALL_TOPICS.CALL_DATE,
	ROUND(TRUNC(SYSDATE) - AR_CUSTOMER_CALL_TOPICS.CALL_DATE)
FROM	hz_contact_points cont_point,
        hz_cust_account_roles car, AR_LOOKUPS LKUPS,
	AR_PAYMENT_SCHEDULES, AR_CUSTOMER_CALL_TOPICS, AR_CALL_ACTIONS
--WHERE	AR_CUSTOMER_CALL_TOPICS.CUSTOMER_ID = CUSTOMER_ID
WHERE	AR_CUSTOMER_CALL_TOPICS.CUSTOMER_ID = CUSTOMER_ID_1
--and 	AR_CUSTOMER_CALL_TOPICS.site_use_id(+) = site_use_id
and 	AR_CUSTOMER_CALL_TOPICS.site_use_id(+) = site_use_id_1
AND	AR_CUSTOMER_CALL_TOPICS.PHONE_ID = cont_point.contact_point_id
AND     AR_CUSTOMER_CALL_TOPICS.CONTACT_ID = car.cust_account_role_id
AND     car.party_id = cont_point.owner_table_id
AND     cont_point.owner_table_name = 'HZ_PARTIES'
AND     cont_point.contact_point_type not in ('EDI','EMAIL','WEB')
AND	AR_CUSTOMER_CALL_TOPICS.CUSTOMER_TRX_ID =
		AR_PAYMENT_SCHEDULES.CUSTOMER_TRX_ID (+)
AND	AR_CUSTOMER_CALL_TOPICS.CUSTOMER_CALL_TOPIC_ID =
		AR_CALL_ACTIONS.CUSTOMER_CALL_TOPIC_ID (+)
AND	AR_CUSTOMER_CALL_TOPICS.FOLLOW_UP_ACTION =
		LKUPS.LOOKUP_CODE (+)
ORDER BY AR_CUSTOMER_CALL_TOPICS.CALL_DATE DESC,
	AR_CUSTOMER_CALL_TOPICS.CUSTOMER_CALL_ID DESC
;

BEGIN


  c_last_contact_number         := ''   ;
  c_last_contact_rel_invoice           := ''   ;
  c_last_contact_currency       := '' ;
  c_last_contact_amount         := l_dummy  ;
  c_last_contact_converted      := 	''  ;
  c_last_contact_date           := '' ;
  c_last_contact_days_since     := ''  ;
/*srw.reference (site_use_id);*/null;

/*srw.reference (customer_id);*/null;

OPEN C_CONTACT ;

FETCH C_CONTACT
INTO
    l_last_contact_number ,
    l_last_contact_rel_invoice ,
    l_last_contact_currency,
    l_last_contact_amount,
    l_last_contact_converted	,
    l_last_contact_date ,
    l_last_contact_days_since
    ;


CLOSE C_CONTACT ;

if l_last_contact_date is NOT NULL then
  c_last_contact_number         := l_last_contact_number   ;
  c_last_contact_rel_invoice    := l_last_contact_rel_invoice   ;
  if l_last_contact_amount is not null and l_last_contact_currency is null then
     c_last_contact_currency    := functional_currency;
  else
     c_last_contact_currency       := l_last_contact_currency  ;
  end if;
  c_last_contact_amount         := l_last_contact_amount  ;
  c_last_contact_converted      := l_last_contact_converted	  ;
  c_last_contact_date           := l_last_contact_date   ;
  c_last_contact_days_since     := l_last_contact_days_since  ;
else
  c_last_contact_number         := rp_none   ;
end if ;

  return (0);
EXCEPTION WHEN NO_DATA_FOUND THEN
  c_last_contact_number         := rp_none;
  c_last_contact_rel_invoice    := l_last_contact_rel_invoice   ;
  c_last_contact_currency       := l_last_contact_currency  ;
  c_last_contact_amount         := l_last_contact_amount  ;
  c_last_contact_converted      := l_last_contact_converted	  ;
  c_last_contact_date           := l_last_contact_date   ;
  c_last_contact_days_since     := l_last_contact_days_since  ;

WHEN OTHERS THEN
  /*SRW.MESSAGE (1010,'Error in C_CONTACT FORMULA');*/null;

  return (0);
END ;

RETURN NULL; end;

--function c_last_hold_formulaformula(CUSTOMER_ID in number, site_use_id in number) return number is
function c_last_hold_formulaformula(CUSTOMER_ID_1 in number, site_use_id_1 in number) return number is
begin

DECLARE
l_last_hold_number        VARCHAR2 (100);
l_last_hold_amount        NUMBER ;
l_last_hold_date          VARCHAR2 (11);
l_last_hold_days_since    VARCHAR2 (11);
l_dummy                 NUMBER (1);

CURSOR C_HOLD IS

SELECT	AR_CREDIT_HISTORIES.CREDIT_LIMIT,
	AR_CREDIT_HISTORIES.HOLD_DATE,
	ROUND(TRUNC(SYSDATE) - AR_CREDIT_HISTORIES.HOLD_DATE)

FROM	AR_CREDIT_HISTORIES
--WHERE	AR_CREDIT_HISTORIES.CUSTOMER_ID = CUSTOMER_ID
--and	(ar_credit_histories.site_use_id = site_use_id
WHERE	AR_CREDIT_HISTORIES.CUSTOMER_ID = CUSTOMER_ID_1
and	(ar_credit_histories.site_use_id = site_use_id_1
          or
          site_use_id_1 is null
           or
            ( ar_credit_histories.site_use_id is null
              and not exists  (select 1
                               from ar_credit_histories h2
                              -- where h2.site_use_id =                                               site_use_id
			        where h2.site_use_id =                                               site_use_id_1
                             --   and h2.customer_id =
                               --         customer_id
			            and h2.customer_id =
                                        customer_id_1
                               )
             )
        )
AND	AR_CREDIT_HISTORIES.ON_HOLD = 'Y'
ORDER BY AR_CREDIT_HISTORIES.HOLD_DATE DESC,
	AR_CREDIT_HISTORIES.CREDIT_HISTORY_ID DESC
;

BEGIN


  c_last_hold_number         := ''   ;
  c_last_hold_amount         := l_dummy  ;
  c_last_hold_date           := '' ;
  c_last_hold_days_since     := ''  ;
/*srw.reference (site_use_id);*/null;

/*srw.reference (customer_id);*/null;

OPEN C_HOLD ;

FETCH C_HOLD
INTO
    l_last_hold_amount	,
    l_last_hold_date ,
    l_last_hold_days_since
    ;


CLOSE C_HOLD ;

if l_last_hold_date is NOT NULL then
  c_last_hold_number         := rp_na_upper   ;
  c_last_hold_amount         := l_last_hold_amount  ;
  c_last_hold_date           := l_last_hold_date   ;
  c_last_hold_days_since     := l_last_hold_days_since  ;
else
  c_last_hold_number         := rp_none   ;
end if ;

  return (0);
EXCEPTION WHEN NO_DATA_FOUND THEN
  c_last_hold_number         := rp_none;
  c_last_hold_amount         := l_last_hold_amount  ;
  c_last_hold_date           := l_last_hold_date   ;
  c_last_hold_days_since     := l_last_hold_days_since  ;

WHEN OTHERS THEN
  /*SRW.MESSAGE (1010,'Error in C_HOLD FORMULA');*/null;

  return (0);
END ;

RETURN NULL; end;

function c_data_not_foundformula(customer_name in varchar2) return number is
begin

rp_data_found := customer_name ;
return (0);

end;

procedure get_boiler_plates is

w_industry_code varchar2(20);
w_industry_stat varchar2(20);

begin

if fnd_installation.get(0, 0,
                        w_industry_stat,
	    	        w_industry_code) then
   if w_industry_code = 'C' then
      c_sales_title := null ;
   else
      get_lookup_meaning('IND_SALES',
                       	 w_industry_code,
			 c_sales_title);
   end if;
end if;

c_industry_code :=   w_Industry_code ;

end ;

procedure get_lookup_meaning(p_lookup_type	in varchar2,
			     p_lookup_code	in varchar2,
			     p_lookup_meaning  	in out NOCOPY varchar2)
			    is

w_meaning varchar2(80);

begin

select meaning
  into w_meaning
  from fnd_lookups
 where lookup_type = p_lookup_type
   and lookup_code = p_lookup_code ;

p_lookup_meaning := w_meaning ;

exception
   when no_data_found then
        		p_lookup_meaning := null ;

end ;

function set_display_for_core return boolean is

begin

if c_industry_code = 'C' then
   return(TRUE);
else
   if c_sales_title is not null then
      return(FALSE);
   else
      return(TRUE);
   end if;
end if;

RETURN NULL; end;

function set_display_for_gov return boolean is

begin


if c_industry_code = 'C' then
   return(FALSE);
else
   if c_sales_title is not null then
      return(TRUE);
   else
      return(FALSE);
   end if;
end if;

RETURN NULL; end ;

function sel_contactformula(Address_id in number) return varchar2 is
begin

declare
	contact			VARCHAR2(81);
	phone_number		VARCHAR2(73);


cursor c1 is
select decode( party.person_pre_name_adjunct , null,
               substrb(party.person_first_name,1,40) || ' ' ||
                  substrb(party.person_last_name,1,50),
               ARPT_SQL_FUNC_UTIL.GET_LOOKUP_MEANING('CONTACT_TITLE',ORG_CONT.TITLE)
               || ' ' || substrb(party.person_first_name,1,40) || ' '||
               substrb(party.person_last_name,1,50)),
        cont_point.phone_area_code  || ' ' ||
        RTRIM(RPAD(decode(cont_point.contact_point_type,'TLX',
                          cont_point.telex_number,
                          cont_point.phone_number), 15))
  from   hz_cust_account_roles acct_role,
         hz_parties party,
         hz_relationships rel,
         hz_org_contacts org_cont,
         hz_contact_points cont_point,
         hz_cust_account_roles car
where   acct_role.cust_acct_site_id = Address_id
  and   acct_role.party_id = rel.party_id
  and   acct_role.role_type = 'CONTACT'
  and   org_cont.party_relationship_id = rel.relationship_id
  and   rel.subject_id = party.party_id
  and   rel.subject_table_name = 'HZ_PARTIES'
  and   rel.object_table_name = 'HZ_PARTIES'
  and   rel.directional_flag = 'F'
  and   acct_role.cust_account_role_id = car.cust_account_role_id(+)
  and   car.party_id = cont_point.owner_table_id(+)
  and   cont_point.owner_table_name(+) = 'HZ_PARTIES'
  and    cont_point.contact_point_type(+) NOT IN ('EDI','EMAIL','WEB')
  and   nvl(nvl(cont_point.phone_line_type,
                cont_point.contact_point_type), 'GEN') = 'GEN'
  and   nvl( acct_role.status,'A') = 'A'
order by cont_point.primary_flag desc;
begin
/*srw.reference(Address_id);*/null;


	c_contact		:= NULL;
	c_phone_number		:= NULL;
	contact			:= NULL;
	phone_number		:= NULL;

OPEN c1;

FETCH c1 INTO contact, phone_number;

c_contact		:=  contact;
c_phone_number		:=  phone_number;

CLOSE c1;

return(' ');

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	c_contact		:= contact;
	c_phone_number		:= phone_number;
	return(' ');

	WHEN OTHERS THEN
	c_contact		:= contact;
	c_phone_number		:= phone_number;
	return(' ');
end;

RETURN NULL; end;

PROCEDURE Get_Bucket_Data IS
   l_bucket_line_type      VARCHAR2 (30);
   l_bucket_days_from      NUMBER (16);
   l_bucket_days_to        NUMBER (16);
   l_bucket_category       VARCHAR2 (30);
   l_bucket_title          VARCHAR2 (31);

   CURSOR C_Sel_Bucket_Data is
  	  select lines.days_start,
	         lines.days_to,
	         report_heading1 || ' ' || report_heading2 ,
	         lines.type
	  from   ar_aging_bucket_lines lines,
	         ar_aging_buckets buckets
          where  lines.aging_bucket_id = buckets.aging_bucket_id
 	  and    upper(buckets.bucket_name) = upper(p_bucket_name_low)
	  order by lines.bucket_sequence_num;

BEGIN

     OPEN  C_Sel_Bucket_Data ;


     LOOP

          FETCH C_Sel_Bucket_Data
           INTO l_bucket_days_from ,
                l_bucket_days_to   ,
     	        l_bucket_title     ,
                l_bucket_line_type;

          EXIT WHEN C_Sel_Bucket_Data%NOTFOUND  ;

          if  rp_bucket_line_type_0 is NULL then
              rp_bucket_days_from_0 := l_bucket_days_from ;
              rp_bucket_days_to_0   := l_bucket_days_to    ;
              rp_bucket_line_type_0 := l_bucket_line_type  ;
              rp_bucket_title0 :=     l_bucket_title  ;
          elsif  rp_bucket_line_type_1 is NULL then
              rp_bucket_days_from_1 := l_bucket_days_from ;
              rp_bucket_days_to_1   := l_bucket_days_to    ;
              rp_bucket_line_type_1 := l_bucket_line_type  ;
              rp_bucket_title1 :=     l_bucket_title  ;
          elsif  rp_bucket_line_type_2 is NULL then
              rp_bucket_days_from_2 := l_bucket_days_from ;
              rp_bucket_days_to_2   := l_bucket_days_to    ;
              rp_bucket_line_type_2 := l_bucket_line_type  ;
              rp_bucket_title2 :=     l_bucket_title  ;
          elsif  rp_bucket_line_type_3 is NULL then
              rp_bucket_days_from_3 := l_bucket_days_from ;
              rp_bucket_days_to_3   := l_bucket_days_to    ;
              rp_bucket_line_type_3 := l_bucket_line_type  ;
              rp_bucket_title3 :=     l_bucket_title  ;
          elsif  rp_bucket_line_type_4 is NULL then
              rp_bucket_days_from_4 := l_bucket_days_from ;
              rp_bucket_days_to_4   := l_bucket_days_to    ;
              rp_bucket_line_type_4 := l_bucket_line_type  ;
              rp_bucket_title4 :=     l_bucket_title  ;
          elsif  rp_bucket_line_type_5 is NULL then
              rp_bucket_days_from_5 := l_bucket_days_from ;
              rp_bucket_days_to_5   := l_bucket_days_to    ;
              rp_bucket_line_type_5 := l_bucket_line_type  ;
              rp_bucket_title5 :=     l_bucket_title  ;
          elsif  rp_bucket_line_type_6 is NULL then
              rp_bucket_days_from_6 := l_bucket_days_from ;
              rp_bucket_days_to_6   := l_bucket_days_to    ;
              rp_bucket_line_type_6 := l_bucket_line_type  ;
              rp_bucket_title6 :=     l_bucket_title  ;
          end if ;

          if (l_bucket_line_type =  'DISPUTE_ONLY') OR
             (l_bucket_line_type =  'PENDADJ_ONLY') OR
             (l_bucket_line_type =  'DISPUTE_PENDADJ')   then

             rp_bucket_category :=  l_bucket_line_type ;
          end if ;

          l_bucket_days_from := 0 ;
          l_bucket_days_to   := 0 ;
          l_bucket_line_type := '';

     END LOOP ;

     CLOSE C_Sel_Bucket_Data ;

/*srw.message (593, 'rp_bucket_line_type_0 = '||rp_bucket_line_type_0);*/null;

/*srw.message (593, 'rp_bucket_line_type_1 = '||rp_bucket_line_type_1);*/null;

/*srw.message (593, 'rp_bucket_line_type_2 = '||rp_bucket_line_type_2);*/null;

/*srw.message (593, 'rp_bucket_line_type_3 = '||rp_bucket_line_type_3);*/null;

/*srw.message (593, 'rp_bucket_line_type_4 = '||rp_bucket_line_type_4);*/null;

/*srw.message (593, 'rp_bucket_line_type_5 = '||rp_bucket_line_type_5);*/null;

/*srw.message (593, 'rp_bucket_line_type_6 = '||rp_bucket_line_type_6);*/null;


/*srw.message (593, 'rp_bucket_days_from_0 = '||rp_bucket_days_from_0);*/null;

/*srw.message (593, 'rp_bucket_days_to_0 = '||rp_bucket_days_to_0);*/null;

/*srw.message (593, 'rp_bucket_days_from_1 = '||rp_bucket_days_from_1);*/null;

/*srw.message (593, 'rp_bucket_days_to_1 = '||rp_bucket_days_to_1);*/null;

/*srw.message (593, 'rp_bucket_days_from_5 = '||rp_bucket_days_from_5);*/null;

/*srw.message (593, 'rp_bucket_days_to_5 = '||rp_bucket_days_to_5);*/null;

/*srw.message (593, 'rp_bucket_days_from_6 = '||rp_bucket_days_from_6);*/null;

/*srw.message (593, 'rp_bucket_days_to_6 = '||rp_bucket_days_to_6);*/null;



END;

function c_currency_lookupformula(site_use_id in number, currency_bucket in varchar2) return number is
  return_Curr_list        VARCHAR2(100);
  l_entity_type           VARCHAR2(20) := 'SITE';
  l_entity_id             NUMBER       := site_use_id;
  l_trx_curr_code         VARCHAR2(15) := currency_bucket;
  l_default_flag          VARCHAR2(1)  := 'Y' ;
  l_limit_curr_code       VARCHAR2(15);
  l_customer_id           number;
  l_site_use_id           number;
begin
  select decode (site_use_id, null, 'CUSTOMER', 'SITE'),
         decode (site_use_id, null, cust_account_id, site_use_id),
         cust_account_id,
         site_use_id
  into   l_entity_type,
         l_entity_id,
         l_customer_id
         ,l_site_use_id
  from hz_customer_profiles
  where cust_account_profile_id = c_customer_profile_id;
  /*srw.message(592, 'calling gli for '||l_entity_type||' '||l_entity_id||' '||l_trx_curr_code);*/null;

  oe_credit_check_pvt.currency_list
      (l_entity_type
      ,l_entity_id
      ,l_trx_curr_code
      ,l_limit_curr_code
      ,l_default_flag
      ,return_curr_list);
  cp_related_currencies := return_Curr_list;

  IF cp_related_currencies is NULL THEN
     cp_related_currencies:=CP_CF_RELATED_CURRENCY(l_customer_id,l_site_use_id);
     /*srw.message(500,' cp_related_currency ' || cp_related_currencies);*/null;

  END IF;
  cp_limit_currency := l_limit_curr_code;
  cp_default_flag := l_default_flag;

  /*srw.message(592, 'after gli limit curr is '||l_limit_curr_code||' and def flg is '||l_default_flag);*/null;



  if l_entity_type = 'SITE' and l_limit_curr_code is null then
    /*srw.message(592, 'calling gli-II for '||l_entity_type||' '||l_entity_id||' '||l_trx_curr_code);*/null;

    oe_credit_check_pvt.currency_list
      ('CUSTOMER'
      ,l_customer_id
      ,l_trx_curr_code
      ,l_limit_curr_code
      ,l_default_flag
      ,return_curr_list);
    cp_related_currencies := return_Curr_list;

  IF cp_related_currencies is NULL THEN
     cp_related_currencies:=CP_CF_RELATED_CURRENCY(l_customer_id,l_site_use_id);
     /*srw.message(500,' II - cp_related_currency ' || cp_related_currencies);*/null;

  END IF;
    cp_limit_currency := l_limit_curr_code;
    cp_default_flag := l_default_flag;
    /*srw.message(592, 'after gli limit curr is '||l_limit_curr_code||' and def flg is '||l_default_flag);*/null;

  end if;
  if cp_limit_currency is not null then
    cp_txn_cur := cp_limit_currency||',';
       -- if instr(currency_list.txn_currency, cp_limit_currency) = 0 then
       --currency_list.txn_currency := currency_list.txn_currency||cp_txn_cur;
        if instr(txn_currency, cp_limit_currency) = 0 then
       txn_currency := txn_currency||cp_txn_cur;
    end if;
  end if;
  return(0);
end;

function cf_calc_rate_amountformula(trx_cur in varchar2, customer_id in number, site_use_id in number, trx_amount_due in number) return number is
begin
declare
   present                            number;
   xchg_rate                          number;
   l_aging_on_account_profile         NUMBER ;
   l_aging_unapplied_profile          NUMBER ;


begin

  /*srw.message(300,'DEBUG: related currencies :'||CP_related_currencies);*/null;

       Select instr( CP_related_currencies, trx_cur)
  INTO present
  from dual;
    if present <> 0 then
  /*srw.message(300,'DEBUG: trx_curr :'||trx_cur);*/null;

  /*srw.message(300,'DEBUG: cp_limit_currency :'||CP_limit_currency);*/null;

    Xchg_rate := gl_currency_api.get_rate_sql
                (trx_cur,CP_limit_currency,SYSDATE,'Corporate');

    if Xchg_rate = -1 then

         FND_MESSAGE.SET_NAME('AR','AR_CC_INVALID_EXCHANGE_RATE');
         FND_MESSAGE.SET_TOKEN('CC',trx_cur,FALSE);
         /*SRW.MESSAGE(301,FND_MESSAGE.GET);*/null;



     elsif xchg_rate = -2 then
         FND_MESSAGE.SET_NAME('AR','AR_CC_INVALID_CURRENCY');
         /*SRW.MESSAGE(300,FND_MESSAGE.GET);*/null;

         raise_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

     end if;


 SELECT	NVL(SUM(DECODE(AR_RECEIVABLE_APPLICATIONS.STATUS, 'ACC',
						AMOUNT_APPLIED, 0)),
						 0) on_account,
	nvl(sum(decode(ar_receivable_applications.status, 'UNAPP',
		  				amount_applied, 0)),
						 0) unapplied
  into	l_aging_on_account_profile,
	l_aging_unapplied_profile
  from	ar_receivable_applications,
	ar_cash_receipts
  where	ar_receivable_applications.cash_receipt_id =
		ar_cash_receipts.cash_receipt_id
  and	ar_cash_receipts.pay_from_customer = customer_id
  and   ar_cash_receipts.CUSTOMER_SITE_USE_ID = site_use_id
  and   ar_cash_receipts.currency_code = trx_cur
  and	ar_receivable_applications.gl_date <= sysdate;


 cp_adjusted_amount := trx_amount_due - l_aging_unapplied_profile - l_aging_on_account_profile;

    CP_limit_curr_amt := gl_currency_api.convert_amount_sql(trx_cur,CP_limit_currency,SYSDATE,'Corporate',CP_adjusted_amount);

    if CP_limit_curr_amt = -1 then
       CP_limit_curr_amt:=TO_NUMBER(null);

         FND_MESSAGE.SET_NAME('AR','AR_CC_INVALID_EXCHANGE_RATE');
         FND_MESSAGE.SET_TOKEN('CC',trx_cur,FALSE);
         /*SRW.MESSAGE(301,FND_MESSAGE.GET);*/null;

          elsif Cp_limit_curr_amt = -2 then
         FND_MESSAGE.SET_NAME('AR','AR_CC_INVALID_CURRENCY');
         /*SRW.MESSAGE(300,FND_MESSAGE.GET);*/null;

         raise_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

    end if;
      IF xchg_rate=-1
   THEN
     CP_rate:=TO_NUMBER(null);
   ELSE
     CP_rate := xchg_rate;
   END IF;
  end if;
end;
RETURN NULL; end;

function cf_calc_rate_amount_formula1fo(trx_cur2 in varchar2, customer_id in number, site_use_id in number, trx_amount_due1 in number) return number is
begin
declare
   present                            number;
   xchg_rate                          number;
   l_aging_on_account_profile         NUMBER ;
   l_aging_unapplied_profile          NUMBER ;


begin

  /*srw.reference(trx_cur2);*/null;

  /*srw.reference(customer_id);*/null;

  /*srw.reference(site_use_id);*/null;


IF limit_currency is not null and related_currencies is not null then


  /*srw.message(300,' CALC RATE Customer ID :'||to_char(customer_id));*/null;

  /*srw.message(300,' CALC RATE Site Id :'||to_char(site_use_id));*/null;

  /*srw.message(300,' CALC RATE Transaction Currency :'||trx_cur2);*/null;

  /*srw.message(300,' CALC RATE related currencies :'||related_currencies);*/null;

  /*srw.message(300,' CALC RATE Limit Currency : '||limit_currency);*/null;


  Select instr( related_currencies, trx_cur2)
  INTO present
  from dual;
  /*srw.message(300, 'DEBUG: present : '|| to_char(present));*/null;


  if present <> 0 then
    Xchg_rate := gl_currency_api.get_rate_sql
                (trx_cur2,limit_currency,SYSDATE,'Corporate');
    if Xchg_rate = -1 then

         FND_MESSAGE.SET_NAME('AR','AR_CC_INVALID_EXCHANGE_RATE');
         FND_MESSAGE.SET_TOKEN('CC',trx_cur2,FALSE);
         /*SRW.MESSAGE(300,FND_MESSAGE.GET);*/null;

           elsif xchg_rate = -2 then
         FND_MESSAGE.SET_NAME('AR','AR_CC_INVALID_CURRENCY');
         /*SRW.MESSAGE(300,FND_MESSAGE.GET);*/null;

         raise_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

     end if;


 SELECT	NVL(SUM(DECODE(AR_RECEIVABLE_APPLICATIONS.STATUS, 'ACC',
						AMOUNT_APPLIED, 0)),
						 0) on_account,
	nvl(sum(decode(ar_receivable_applications.status, 'UNAPP',
		  				amount_applied, 0)),
						 0) unapplied
  into	l_aging_on_account_profile,
	l_aging_unapplied_profile
  from	ar_receivable_applications,
	ar_cash_receipts
  where	ar_receivable_applications.cash_receipt_id =
		ar_cash_receipts.cash_receipt_id
  and	ar_cash_receipts.pay_from_customer = customer_id
  and   ar_cash_receipts.CUSTOMER_SITE_USE_ID = site_use_id
  and   ar_cash_receipts.currency_code = trx_cur2
  and	ar_receivable_applications.gl_date <= sysdate;

/*srw.message(300, 'DEBUG: adjusted amount : '|| to_char(cp_adjusted_amount1));*/null;

/*srw.message(300, 'DEBUG: unapplied profile : '|| to_char(l_aging_unapplied_profile));*/null;

/*srw.message(300, 'DEBUG: on account profile : '|| to_char(l_aging_on_account_profile));*/null;


 cp_adjusted_amount1 := trx_amount_due1 - l_aging_unapplied_profile - l_aging_on_account_profile;

    Cp_limit_curr_amt1 := gl_currency_api.convert_amount_sql(trx_cur2,limit_currency,SYSDATE,NULL,CP_adjusted_amount1);

    if Cp_limit_curr_amt1 = -1 then
       Cp_limit_curr_amt1:=TO_NUMBER(null);
         FND_MESSAGE.SET_NAME('AR','AR_CC_INVALID_EXCHANGE_RATE');
         FND_MESSAGE.SET_TOKEN('CC',trx_cur2,FALSE);
         /*SRW.MESSAGE(300,FND_MESSAGE.GET);*/null;

            elsif Cp_limit_curr_amt1 = -2 then
         FND_MESSAGE.SET_NAME('AR','AR_CC_INVALID_CURRENCY');
         /*SRW.MESSAGE(300,FND_MESSAGE.GET);*/null;

         raise_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

    end if;

  if xchg_rate=-1
  then
    CP_rate1:=TO_NUMBER(null);
  else
    CP_rate1 := xchg_rate;
  end if;
      else
  /*srw.message(300, trx_cur2 ||' does not have usage for limit currency - '||limit_currency);*/null;


end if;
END IF;
end;

RETURN NULL; end;
--function c_org_credit_calcformula(customer_id in number, site_use_id in number) return number is
function c_org_credit_calcformula(customer_id in number, site_use_id in number,functional_currency varchar2,Org_Currency_Code varchar2,org_overall_limit number) return number is
begin

DECLARE

l_aging_balance_os_profile         NUMBER ;
Adjusted_balance                   NUMBER;
l_aging_convert_os_profile         VARCHAR2   (1);
l_aging_on_account_profile         NUMBER ;
l_aging_conv_on_ac_profile         VARCHAR2 (1);
l_aging_unapplied_profile          NUMBER ;
l_aging_conv_unap_prof             VARCHAR2 (1);
l_cred_summ_avail_credit           NUMBER ;
l_dummy                            NUMBER (1);
trx_curr                           VARCHAR2(15);
trx_amount                         NUMBER;
base_amount                        NUMBER;
curr_exists                        NUMBER;

CURSOR ps_trx IS
SELECT invoice_currency_code, NVL(SUM(AMOUNT_DUE_REMAINING), 0) ammount_due
 from   ar_payment_schedules ps
where   ps.customer_id = customer_id
  and   ps.customer_site_use_id = site_use_id
   and	ps.status = 'OP'
  and   ps.class not in ('CM', 'PMT')
group by ps.invoice_currency_code;


l_loop				  VARCHAR2(1);

BEGIN

/*srw.message (200, 'DEBUG:  credit_calc:    ' || to_char(customer_id) ||' : '||to_char(site_use_id));*/null;


l_cred_summ_avail_credit       := 0;
l_aging_balance_os_profile     := 0;
Adjusted_balance               := 0;
c_cred_convert_limit2         := '' ;
c_cred_summ_available2        := l_dummy;
c_cred_summ_exceeded2         := l_dummy ;

/*srw.reference (customer_id);*/null;

/*srw.reference (Org_Currency_Code);*/null;

/*srw.reference (site_use_id);*/null;

/*srw.reference (org_overall_limit);*/null;




  l_aging_on_account_profile:=0;
  l_aging_unapplied_profile:=0;
  l_loop:='N';


SELECT
        NVL(SUM(DECODE(AR_RECEIVABLE_APPLICATIONS.STATUS, 'ACC',
  	 				AMOUNT_APPLIED, 0)),
						 0) on_account,
        nvl(max(decode(ar_receivable_applications.status, 'ACC',
		decode(ar_cash_receipts.currency_code,functional_currency, ' ',
		      decode(ar_cash_receipts.exchange_rate, NULL, '*', ' ')),
		' ')), ' ') account_convert,
	nvl(sum(decode(ar_receivable_applications.status, 'UNAPP',
		  				amount_applied, 0)),
						 0) unapplied,
        nvl(max(decode(ar_receivable_applications.status, 'UNAPP',
		decode(ar_cash_receipts.currency_code,functional_currency, ' ',
		      decode(ar_cash_receipts.exchange_rate, NULL, '*', ' ')),
		' ')), ' ') unapp_convert
into
        l_aging_on_account_profile,
	l_aging_conv_on_ac_profile,
	l_aging_unapplied_profile,
	l_aging_conv_unap_prof
from	ar_receivable_applications,
	ar_cash_receipts
where	ar_receivable_applications.cash_receipt_id =
		ar_cash_receipts.cash_receipt_id


and	ar_cash_receipts.pay_from_customer = customer_id
and     ar_cash_receipts.CUSTOMER_SITE_USE_ID = site_use_id
and     ar_cash_receipts.currency_code = org_currency_code
and	ar_receivable_applications.gl_date <= sysdate;


FOR trx_rec IN ps_trx
LOOP
    SELECT instr(related_currencies,trx_rec.invoice_currency_code)
    INTO   curr_exists
    FROM   DUAL;
    IF curr_exists <> 0 THEN
      trx_curr := trx_rec.invoice_currency_code;


      l_aging_on_account_profile:=0;
      l_aging_unapplied_profile:=0;
      l_loop:='Y';

 SELECT	NVL(SUM(DECODE(AR_RECEIVABLE_APPLICATIONS.STATUS, 'ACC',
						AMOUNT_APPLIED, 0)),
						 0) on_account,
	nvl(sum(decode(ar_receivable_applications.status, 'UNAPP',
		  				amount_applied, 0)),
						 0) unapplied
  into	l_aging_on_account_profile,
	l_aging_unapplied_profile
  from	ar_receivable_applications,
	ar_cash_receipts
  where	ar_receivable_applications.cash_receipt_id =
		ar_cash_receipts.cash_receipt_id
  and	ar_cash_receipts.pay_from_customer = customer_id
  and   ar_cash_receipts.CUSTOMER_SITE_USE_ID = site_use_id
  and   ar_cash_receipts.currency_code = trx_rec.invoice_currency_code
  and	ar_receivable_applications.gl_date <= sysdate;

      trx_amount := trx_rec.ammount_due - l_aging_unapplied_profile - l_aging_on_account_profile;

      base_amount := gl_currency_api.convert_amount_sql(trx_curr,limit_currency,SYSDATE,'Corporate',trx_amount);
      IF base_amount = -1 THEN
         FND_MESSAGE.SET_NAME('AR','AR_CC_INVALID_EXCHANGE_RATE');
         FND_MESSAGE.SET_TOKEN('CC',trx_curr,FALSE);
         /*SRW.MESSAGE(200,FND_MESSAGE.GET);*/null;

         raise_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;


      END IF;
      IF base_amount = -2 THEN
           FND_MESSAGE.SET_NAME('AR','AR_CC_INVALID_CURRENCY');
           /*SRW.MESSAGE(200,FND_MESSAGE.GET);*/null;

           raise_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

      END IF;

            Adjusted_balance := Adjusted_balance + base_amount;
     END IF;
END LOOP;



if (org_overall_limit is NOT NULL ) then

If l_loop = 'Y' then
   l_cred_summ_avail_credit  :=  org_overall_limit - Adjusted_balance;
Else
   l_cred_summ_avail_credit  :=  org_overall_limit + (l_aging_unapplied_profile + l_aging_on_account_profile);
End If;

if (( l_aging_conv_on_ac_profile    = '*' )  OR
    (l_aging_conv_unap_prof      = '*'))    then
   c_cred_convert_limit2 := '*';
end if ;

if l_cred_summ_avail_credit < 0 then
  c_cred_summ_available2 := 0 ;
  c_cred_summ_exceeded2     := l_cred_summ_avail_credit ;
else
  c_cred_summ_exceeded2  := 0 ;
  c_cred_summ_available2 := l_cred_summ_avail_credit ;
end if ;

end if ;

return (0);
END ;

end;

--function cf_org_calc_amountformula(org_trx_cur in varchar2, customer_id in number, site_use_id in number, --trx_amount_due2 in number) return number is
function cf_org_calc_amountformula(org_trx_cur in varchar2, customer_id in number, site_use_id in number, trx_amount_due2 in number) return number is
begin
declare
   present                            number;
   xchg_rate                          number;
   l_aging_on_account_profile         NUMBER ;
   l_aging_unapplied_profile          NUMBER ;


begin

  /*srw.reference(org_trx_cur);*/null;

  /*srw.reference(customer_id);*/null;

  /*srw.reference(site_use_id);*/null;

  /*srw.reference(default_flag);*/null;


IF limit_currency is not null and related_currencies is not null
   and default_flag = 'Y' then


  /*srw.message(900,' CALC RATE Customer ID :'||to_char(customer_id));*/null;

  /*srw.message(900,' CALC RATE Site Id :'||to_char(site_use_id));*/null;

  /*srw.message(900,' CALC RATE Transaction Currency :'||org_trx_cur);*/null;

  /*srw.message(900,' CALC RATE related currencies :'||related_currencies);*/null;

  /*srw.message(900,' CALC RATE Limit Currency : '||limit_currency);*/null;


  Select instr( related_currencies, org_trx_cur)
  INTO present
  from dual;
  /*srw.message(300, 'DEBUG: present : '|| to_char(present));*/null;


  if present <> 0 then
    Xchg_rate := gl_currency_api.get_rate_sql(org_trx_cur,limit_currency,SYSDATE,NULL);
    if Xchg_rate = -1 then
         FND_MESSAGE.SET_NAME('AR','AR_CC_INVALID_EXCHANGE_RATE');
         FND_MESSAGE.SET_TOKEN('CC',org_trx_cur,FALSE);
         /*SRW.MESSAGE(300,FND_MESSAGE.GET);*/null;

            elsif xchg_rate = -2 then
         FND_MESSAGE.SET_NAME('AR','AR_CC_INVALID_CURRENCY');
         /*SRW.MESSAGE(300,FND_MESSAGE.GET);*/null;

         raise_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

     end if;


 SELECT	NVL(SUM(DECODE(AR_RECEIVABLE_APPLICATIONS.STATUS, 'ACC',
						AMOUNT_APPLIED, 0)),
						 0) on_account,
	nvl(sum(decode(ar_receivable_applications.status, 'UNAPP',
		  				amount_applied, 0)),
						 0) unapplied
  into	l_aging_on_account_profile,
	l_aging_unapplied_profile
  from	ar_receivable_applications,
	ar_cash_receipts
  where	ar_receivable_applications.cash_receipt_id =
		ar_cash_receipts.cash_receipt_id
  and	ar_cash_receipts.pay_from_customer = customer_id
  and   ar_cash_receipts.CUSTOMER_SITE_USE_ID = site_use_id
  and   ar_cash_receipts.currency_code = org_trx_cur
  and	ar_receivable_applications.gl_date <= sysdate;

/*srw.message(300, 'DEBUG: adjusted amount : '|| to_char(cp_adjusted_amount2));*/null;

/*srw.message(300, 'DEBUG: unapplied profile : '|| to_char(l_aging_unapplied_profile));*/null;

/*srw.message(300, 'DEBUG: on account profile : '|| to_char(l_aging_on_account_profile));*/null;


 cp_adjusted_amount2 := trx_amount_due2 - l_aging_unapplied_profile - l_aging_on_account_profile;

    Cp_limit_curr_amt2 := gl_currency_api.convert_amount_sql(org_trx_cur,limit_currency,SYSDATE,NULL,CP_adjusted_amount2);

    if Cp_limit_curr_amt2 = -1 then
      Cp_limit_curr_amt2:=TO_NUMBER(null);
         FND_MESSAGE.SET_NAME('AR','AR_CC_INVALID_EXCHANGE_RATE');
         FND_MESSAGE.SET_TOKEN('CC',org_trx_cur,FALSE);
         /*SRW.MESSAGE(300,FND_MESSAGE.GET);*/null;

          elsif Cp_limit_curr_amt2 = -2 then
         FND_MESSAGE.SET_NAME('AR','AR_CC_INVALID_CURRENCY');
         /*SRW.MESSAGE(300,FND_MESSAGE.GET);*/null;

         raise_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

    end if;

   IF xchg_rate=-1
   THEN
     CP_rate2 :=TO_NUMBER(null);
   ELSE
    CP_rate2 := xchg_rate;
   END IF;
      else
  /*srw.message(300, org_trx_cur ||' does not have usage for limit currency - '||limit_currency);*/null;


end if;
END IF;
return(0);
end;

end;

--function C_org_profileFormula return Number is
function C_org_profileFormula return Number is
begin
DECLARE

  l_cred_summ_limit_tolerance       VARCHAR2(100);
  l_cred_summ_credit_rating         VARCHAR2(100);
  l_cred_summ_credit_hold           VARCHAR2(100);
  l_credit_profile_id               NUMBER(20);
  l_profile_site_use_id  		  NUMBER(20);
  ct_prof                		  NUMBER(2);
  yes				  VARCHAR2(3);
  no				  VARCHAR2(3);
BEGIN
  /*srw.reference (p_reporting_entity_id);*/null;

  /*srw.message(999,'Credit Summary Cust Ref : '||customer_id);*/null;

  /*srw.reference (site_use_id);*/null;

  /*srw.message(999,'Credit Summary Site Ref : '||site_use_id);*/null;


     select count(*)
     into ct_prof
     from hz_credit_profile_amts cpa
     where credit_profile_id IN (Select credit_profile_id
                                   From HZ_Credit_Profiles
                                   Where organization_id = p_reporting_entity_id
                                     and effective_date_from <= SYSDATE
                                     and effective_date_to   >= SYSDATE);


  SELECT  substr(INITCAP(YES.MEANING),1,3) yes,
          substr(INITCAP(NO.MEANING),1,3) no
  INTO    yes,
          no
  FROM    AR_LOOKUPS                      YES,
          AR_LOOKUPS                      NO
  WHERE   YES.LOOKUP_TYPE = 'YES/NO'      AND
          YES.LOOKUP_CODE = 'Y'           AND
          NO.LOOKUP_TYPE = 'YES/NO'       AND
          NO.LOOKUP_CODE = 'N';

    Select
 	  to_char(nvl(cp.tolerance, 0), '990') || '%',
	  substr(nvl(cp.credit_rating, rp_na_upper),1,30),
	  lk.meaning,
	  cp.credit_profile_id
  into
	  l_cred_summ_limit_tolerance,
	  l_cred_summ_credit_rating,
	  l_cred_summ_credit_hold,
	  l_credit_profile_id
  from 	HZ_credit_profiles cp,
	  ar_lookups lk
  where
        nvl(cp.credit_hold,'N') = lk.lookup_code
    and	lk.lookup_type = 'YES/NO'
    and cp.organization_id = p_reporting_entity_id
    and NVL(cp.effective_date_from, sysdate-1) > sysdate
    and NVL(cp.effective_date_to, sysdate+1) < sysdate
    and NVL(cp.enable_flag, 'N') = 'Y';


c_org_limit_tolerance    := l_cred_summ_limit_tolerance  ;
c_org_credit_rating      := l_cred_summ_credit_rating  ;
c_org_credit_hold        := substr(l_cred_summ_credit_hold,1,4)  ;
c_credit_profile_id      := l_credit_profile_id  ;

--currency_list.txn_currency := NULL;
txn_currency := NULL;


EXCEPTION WHEN NO_DATA_FOUND THEN
  return (0);


 end;


end;

function G_CREDIT_AMOUNTSGroupFilter return boolean is
begin
  /*srw.message(592, 'in fmt trg of g_credit_amounts');*/null;

  return (TRUE);
end;

function G_customer_limitGroupFilter return boolean is
begin
  return (TRUE);
end;

function cf_currency_lookupformula(qc_customer1 in number, currency_credit1 in varchar2, qc_site1 in number, Site_use_id in number) return number is
begin

  declare
  return_Curr_list        VARCHAR2(100);
  l_entity_type           VARCHAR2(20) := 'CUSTOMER';
  l_entity_id             NUMBER       := qc_customer1;
  l_trx_curr_code         VARCHAR2(15) := currency_credit1;
  l_limit_curr_code       VARCHAR2(15);
  l_default_limit_flag    VARCHAR2(1);
begin

  /*srw.reference(qc_customer1);*/null;

  /*srw.reference(qc_site1);*/null;

  /*srw.reference(currency_credit1);*/null;


if qc_site1 is NULL then
  oe_credit_check_pvt.currency_list
      (l_entity_type
      ,l_entity_id
      ,l_trx_curr_code
      ,l_limit_curr_code
      ,l_default_limit_flag
      ,return_curr_list);

  if l_limit_curr_code is NULL then
    limit_currency := l_trx_curr_code;
  else
    limit_currency := l_limit_curr_code;
  end if;
  related_currencies := return_Curr_list;

  IF related_currencies IS NULL THEN
     related_currencies:=Currency_credit1;
  END IF;
  default_flag:= l_default_limit_flag;



else

  l_entity_type:='SITE';
  l_entity_id:=Site_use_id;
  oe_credit_check_pvt.currency_list
      (l_entity_type
      ,l_entity_id
      ,l_trx_curr_code
      ,l_limit_curr_code
      ,l_default_limit_flag
      ,return_curr_list);

  if l_limit_curr_code is NULL then
    limit_currency := l_trx_curr_code;
  else
    limit_currency := l_limit_curr_code;
  end if;
  IF return_curr_list is null THEN
     related_currencies:=currency_credit1;
  ELSE
     related_currencies := return_curr_list;
  END IF;
end if;
/*srw.message(513,'related_currency ' || related_currencies || ' Customer ' || to_char(qc_customer1) ||
                        to_Char(site_use_id));*/null;

end;
return(0);
end;

--function c_credit_amounts_calcformu0114(customer_id in number, site_use_id in number) return number is
function c_credit_amounts_calcformu0114(customer_id in number,site_use_id in number,functional_currency varchar2,Currency_Credit1 varchar2,credit_limit1 number) return number is

begin


DECLARE

l_aging_balance_os_profile         NUMBER ;
Adjusted_balance                   NUMBER;
l_aging_convert_os_profile         VARCHAR2   (1);
l_aging_on_account_profile         NUMBER ;
l_aging_conv_on_ac_profile         VARCHAR2 (1);
l_aging_unapplied_profile          NUMBER ;
l_aging_conv_unap_prof             VARCHAR2 (1);
l_cred_summ_avail_credit           NUMBER ;
l_dummy                            NUMBER (1);
trx_curr                           VARCHAR2(15);
trx_amount                         NUMBER;
base_amount                        NUMBER;
curr_exists                        NUMBER;

CURSOR ps_trx IS
SELECT invoice_currency_code, NVL(SUM(AMOUNT_DUE_REMAINING), 0) ammount_due,exchange_rate_type
 from   ar_payment_schedules ps
where   ps.customer_id = customer_id
  and   ps.customer_site_use_id = site_use_id
   and	ps.status = 'OP'
  and   ps.class not in ('CM', 'PMT')
group by ps.invoice_currency_code,exchange_rate_type;


l_loop				   VARCHAR2(1);

BEGIN

/*srw.message (200, 'DEBUG:  credit_calc:    ' || to_char(customer_id) ||' : '||to_char(site_use_id));*/null;


l_cred_summ_avail_credit       :=  0 ;
l_aging_balance_os_profile     :=  0;
Adjusted_balance               := 0;
c_cred_convert_limit1      := '' ;
c_cred_summ_available1         := l_dummy;
c_cred_summ_exceeded1            := l_dummy ;

/*srw.reference (customer_id);*/null;

/*srw.reference (Currency_Credit1);*/null;

/*srw.reference (site_use_id);*/null;

/*srw.reference (credit_limit1);*/null;




   l_loop:='N';
   l_aging_on_account_profile:=0;
   l_aging_unapplied_profile:=0;


SELECT
      NVL(SUM(DECODE(AR_RECEIVABLE_APPLICATIONS.STATUS, 'ACC',
						AMOUNT_APPLIED, 0)),
						 0) on_account,
      nvl(max(decode(ar_receivable_applications.status, 'ACC',
		decode(ar_cash_receipts.currency_code, functional_currency, ' ',
		      decode(ar_cash_receipts.exchange_rate, NULL, '*', ' ')),
		' ')), ' ') account_convert,
      nvl(sum(decode(ar_receivable_applications.status, 'UNAPP',
		  				amount_applied, 0)),
						 0) unapplied,
      nvl(max(decode(ar_receivable_applications.status, 'UNAPP',
		decode(ar_cash_receipts.currency_code, functional_currency, ' ',
		      decode(ar_cash_receipts.exchange_rate, NULL, '*', ' ')),
		' ')), ' ') unapp_convert
into
        l_aging_on_account_profile,
	l_aging_conv_on_ac_profile,
        l_aging_unapplied_profile,
	l_aging_conv_unap_prof
from	ar_receivable_applications,
	ar_cash_receipts
where	ar_receivable_applications.cash_receipt_id =
		ar_cash_receipts.cash_receipt_id

and     ar_cash_receipts.pay_from_customer = customer_id
and     ar_cash_receipts.CUSTOMER_SITE_USE_ID = site_use_id
and     ar_cash_receipts.currency_code = currency_credit1
and	ar_receivable_applications.gl_date <= sysdate;


FOR trx_rec IN ps_trx
LOOP
    SELECT instr(related_currencies,trx_rec.invoice_currency_code)
    INTO   curr_exists
    FROM   DUAL;
    IF curr_exists <> 0 THEN
      trx_curr := trx_rec.invoice_currency_code;

   l_loop:='Y';
   l_aging_on_account_profile:=0;
   l_aging_unapplied_profile:=0;

 SELECT	NVL(SUM(DECODE(AR_RECEIVABLE_APPLICATIONS.STATUS, 'ACC',
						AMOUNT_APPLIED, 0)),
						 0) on_account,
	nvl(sum(decode(ar_receivable_applications.status, 'UNAPP',
		  				amount_applied, 0)),
						 0) unapplied
  into	l_aging_on_account_profile,
	l_aging_unapplied_profile
  from	ar_receivable_applications,
	ar_cash_receipts
  where	ar_receivable_applications.cash_receipt_id =
		ar_cash_receipts.cash_receipt_id
  and	ar_cash_receipts.pay_from_customer = customer_id
  and   ar_cash_receipts.CUSTOMER_SITE_USE_ID = site_use_id
  and   ar_cash_receipts.currency_code = trx_rec.invoice_currency_code
  and	ar_receivable_applications.gl_date <= sysdate;

      trx_amount := trx_rec.ammount_due - l_aging_unapplied_profile - l_aging_on_account_profile;

      base_amount := gl_currency_api.convert_amount_sql
                    (trx_curr,limit_currency,SYSDATE,'Corporate',trx_amount);
      IF base_amount = -1 THEN
         base_amount := 0;
         FND_MESSAGE.SET_NAME('AR','AR_CC_INVALID_EXCHANGE_RATE');
         FND_MESSAGE.SET_TOKEN('CC',trx_curr,FALSE);
         /*SRW.MESSAGE(201,FND_MESSAGE.GET);*/null;

         raise_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;


      END IF;
      IF base_amount = -2 THEN
           FND_MESSAGE.SET_NAME('AR','AR_CC_INVALID_CURRENCY');
           /*SRW.MESSAGE(200,FND_MESSAGE.GET);*/null;

           raise_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

      END IF;

/*srw.message (200, 'DEBUG:  base_amount:    ' || to_char(base_amount));*/null;

      Adjusted_balance := Adjusted_balance + base_amount;
     END IF;
END LOOP;



if (credit_limit1 is NOT NULL ) then

If l_loop = 'Y' then
   l_cred_summ_avail_credit  :=  credit_limit1 - Adjusted_balance;
Else
   l_cred_summ_avail_credit  :=  credit_limit1 + (l_aging_unapplied_profile + l_aging_on_account_profile);
End if;

if (( l_aging_conv_on_ac_profile    = '*' )  OR
    (l_aging_conv_unap_prof      = '*'))    then
   c_cred_convert_limit1 := '*';
end if ;

if l_cred_summ_avail_credit < 0 then
  c_cred_summ_available1 := 0 ;
  c_cred_summ_exceeded1     := l_cred_summ_avail_credit ;
else
  c_cred_summ_exceeded1  := 0 ;
  c_cred_summ_available1 := l_cred_summ_avail_credit ;
end if ;

end if ;

return (0);
END ;



RETURN NULL; end;

--function cp_cf_related_currency(p_cust_acct_id number,p_site_use_id number)(p_site_use_id  number' p_cust_acct_id  number) return varchar2 is
FUNCTION cp_cf_related_currency(p_cust_acct_id number,p_site_use_id number) RETURN VARCHAR2 IS
l_ret_string varchar2(2000);
l_cnt  integer;
BEGIN
  l_ret_string:=NULL;
  l_cnt:=0;
for i in (select distinct currency_code from
      hz_cust_profile_amts where cust_account_id=p_cust_acct_id
      and NVL(site_use_id,-9) = NVL(p_site_use_id,NVL(site_use_id,-9)))
Loop
   l_cnt:=l_cnt+1;
   IF l_cnt=1 THEN NULL;
   ELSE
      l_ret_string:=concat(l_ret_string,',');
   END IF;
   l_ret_string:=concat(l_ret_string,i.currency_code);
END LOOP;
    /*srw.message(513,' Return String ' || l_ret_string);*/null;

    return (l_ret_string);
END;

--Functions to refer Oracle report placeholders--

 Function C_Contact_p return varchar2 is
	Begin
	 return C_Contact;
	 END;
 Function C_Phone_Number_p return varchar2 is
	Begin
	 return C_Phone_Number;
	 END;
 Function c_profile_site_use_id_p return number is
	Begin
	 return c_profile_site_use_id;
	 END;
 Function c_customer_profile_id_p return number is
	Begin
	 return c_customer_profile_id;
	 END;
 Function c_cred_summ_collector_p return varchar2 is
	Begin
	 return c_cred_summ_collector;
	 END;
 Function c_cred_summ_exempt_dun_p return varchar2 is
	Begin
	 return c_cred_summ_exempt_dun;
	 END;
 Function c_cred_summ_terms_p return varchar2 is
	Begin
	 return c_cred_summ_terms;
	 END;
 Function c_cred_summ_account_status_p return varchar2 is
	Begin
	 return c_cred_summ_account_status;
	 END;
 Function c_cred_summ_credit_hold_p return varchar2 is
	Begin
	 return c_cred_summ_credit_hold;
	 END;
 Function c_cred_summ_risk_code_p return varchar2 is
	Begin
	 return c_cred_summ_risk_code;
	 END;
 Function c_cred_summ_credit_rating_p return varchar2 is
	Begin
	 return c_cred_summ_credit_rating;
	 END;
 Function c_cred_summ_limit_tolerance_p return varchar2 is
	Begin
	 return c_cred_summ_limit_tolerance;
	 END;
-- Function c_cred_summ_limit_expire_date return varchar2 is
Function c_cred_summ_lt_exp_date_p return varchar2 is
	Begin
	 return c_cred_summ_limit_expire_date;
	 END;
 Function c_last_invoice_days_since_p return varchar2 is
	Begin
	 return c_last_invoice_days_since;
	 END;
 Function c_last_invoice_date_p return varchar2 is
	Begin
	 return c_last_invoice_date;
	 END;
 Function c_last_invoice_converted_p return varchar2 is
	Begin
	 return c_last_invoice_converted;
	 END;
 Function c_last_invoice_amount_p return number is
	Begin
	 return c_last_invoice_amount;
	 END;
 Function c_last_invoice_currency_p return varchar2 is
	Begin
	 return c_last_invoice_currency;
	 END;
 Function c_last_invoice_type_p return varchar2 is
	Begin
	 return c_last_invoice_type;
	 END;
 Function c_last_invoice_number_p return varchar2 is
	Begin
	 return c_last_invoice_number;
	 END;
 Function c_last_cm_rel_invoice_p return varchar2 is
	Begin
	 return c_last_cm_rel_invoice;
	 END;
 Function c_last_cm_converted_p return varchar2 is
	Begin
	 return c_last_cm_converted;
	 END;
 Function c_last_cm_amount_p return number is
	Begin
	 return c_last_cm_amount;
	 END;
 Function c_last_cm_id_p return number is
	Begin
	 return c_last_cm_id;
	 END;
 Function c_last_cm_prev_trx_p return number is
	Begin
	 return c_last_cm_prev_trx;
	 END;
 Function c_last_cm_days_since_p return varchar2 is
	Begin
	 return c_last_cm_days_since;
	 END;
 Function c_last_cm_date_p return varchar2 is
	Begin
	 return c_last_cm_date;
	 END;
 Function c_last_cm_currency_p return varchar2 is
	Begin
	 return c_last_cm_currency;
	 END;
 Function c_last_cm_type_p return varchar2 is
	Begin
	 return c_last_cm_type;
	 END;
 Function c_last_cm_number_p return varchar2 is
	Begin
	 return c_last_cm_number;
	 END;
 Function c_last_guar_days_since_p return varchar2 is
	Begin
	 return c_last_guar_days_since;
	 END;
 Function c_last_guar_date_p return varchar2 is
	Begin
	 return c_last_guar_date;
	 END;
 Function c_last_guar_converted_p return varchar2 is
	Begin
	 return c_last_guar_converted;
	 END;
 Function c_last_guar_amount_p return number is
	Begin
	 return c_last_guar_amount;
	 END;
 Function c_last_guar_currency_p return varchar2 is
	Begin
	 return c_last_guar_currency;
	 END;
 Function c_last_guar_type_p return varchar2 is
	Begin
	 return c_last_guar_type;
	 END;
 Function c_last_guar_number_p return varchar2 is
	Begin
	 return c_last_guar_number;
	 END;
 Function c_last_dep_days_since_p return varchar2 is
	Begin
	 return c_last_dep_days_since;
	 END;
 Function c_last_dep_date_p return varchar2 is
	Begin
	 return c_last_dep_date;
	 END;
 Function c_last_dep_converted_p return varchar2 is
	Begin
	 return c_last_dep_converted;
	 END;
 Function c_last_dep_amount_p return number is
	Begin
	 return c_last_dep_amount;
	 END;
 Function c_last_dep_currency_p return varchar2 is
	Begin
	 return c_last_dep_currency;
	 END;
 Function c_last_dep_type_p return varchar2 is
	Begin
	 return c_last_dep_type;
	 END;
 Function c_last_dep_number_p return varchar2 is
	Begin
	 return c_last_dep_number;
	 END;
 Function c_last_dm_days_since_p return varchar2 is
	Begin
	 return c_last_dm_days_since;
	 END;
 Function c_last_dm_date_p return varchar2 is
	Begin
	 return c_last_dm_date;
	 END;
 Function c_last_dm_converted_p return varchar2 is
	Begin
	 return c_last_dm_converted;
	 END;
 Function c_last_dm_amount_p return number is
	Begin
	 return c_last_dm_amount;
	 END;
 Function c_last_dm_currency_p return varchar2 is
	Begin
	 return c_last_dm_currency;
	 END;
 Function c_last_dm_type_p return varchar2 is
	Begin
	 return c_last_dm_type;
	 END;
 Function c_last_dm_number_p return varchar2 is
	Begin
	 return c_last_dm_number;
	 END;
 Function c_last_cb_days_since_p return number is
	Begin
	 return c_last_cb_days_since;
	 END;
 Function c_last_cb_date_p return varchar2 is
	Begin
	 return c_last_cb_date;
	 END;
 Function c_last_cb_converted_p return varchar2 is
	Begin
	 return c_last_cb_converted;
	 END;
 Function c_last_cb_amount_p return number is
	Begin
	 return c_last_cb_amount;
	 END;
 Function c_last_cb_currency_p return varchar2 is
	Begin
	 return c_last_cb_currency;
	 END;
 Function c_last_cb_type_p return varchar2 is
	Begin
	 return c_last_cb_type;
	 END;
 Function c_last_cb_number_p return varchar2 is
	Begin
	 return c_last_cb_number;
	 END;
 Function c_last_payment_rel_invoice_p return varchar2 is
	Begin
	 return c_last_payment_rel_invoice;
	 END;
 Function c_last_payment_days_since_p return varchar2 is
	Begin
	 return c_last_payment_days_since;
	 END;
 Function c_last_payment_date_p return varchar2 is
	Begin
	 return c_last_payment_date;
	 END;
 Function c_last_payment_converted_p return varchar2 is
	Begin
	 return c_last_payment_converted;
	 END;
 Function c_last_payment_amount_p return number is
	Begin
	 return c_last_payment_amount;
	 END;
 Function c_last_payment_currency_p return varchar2 is
	Begin
	 return c_last_payment_currency;
	 END;
 Function c_last_payment_type_p return varchar2 is
	Begin
	 return c_last_payment_type;
	 END;
 Function c_last_payment_number_p return varchar2 is
	Begin
	 return c_last_payment_number;
	 END;
 Function c_last_adj_days_since_p return varchar2 is
	Begin
	 return c_last_adj_days_since;
	 END;
 Function c_last_adj_date_p return varchar2 is
	Begin
	 return c_last_adj_date;
	 END;
 Function c_last_adj_converted_p return varchar2 is
	Begin
	 return c_last_adj_converted;
	 END;
 Function c_last_adj_amount_p return number is
	Begin
	 return c_last_adj_amount;
	 END;
 Function c_last_adj_currency_p return varchar2 is
	Begin
	 return c_last_adj_currency;
	 END;
 Function c_last_adj_rel_invoice_p return varchar2 is
	Begin
	 return c_last_adj_rel_invoice;
	 END;
 Function c_last_adj_type_p return varchar2 is
	Begin
	 return c_last_adj_type;
	 END;
 Function c_last_adj_number_p return varchar2 is
	Begin
	 return c_last_adj_number;
	 END;
 Function c_last_wo_days_since_p return varchar2 is
	Begin
	 return c_last_wo_days_since;
	 END;
 Function c_last_wo_date_p return varchar2 is
	Begin
	 return c_last_wo_date;
	 END;
 Function c_last_wo_converted_p return varchar2 is
	Begin
	 return c_last_wo_converted;
	 END;
 Function c_last_wo_amount_p return number is
	Begin
	 return c_last_wo_amount;
	 END;
 Function c_last_wo_currency_p return varchar2 is
	Begin
	 return c_last_wo_currency;
	 END;
 Function c_last_wo_rel_invoice_p return varchar2 is
	Begin
	 return c_last_wo_rel_invoice;
	 END;
 Function c_last_wo_type_p return varchar2 is
	Begin
	 return c_last_wo_type;
	 END;
 Function c_last_wo_number_p return varchar2 is
	Begin
	 return c_last_wo_number;
	 END;
 Function c_last_stmnt_next_trx_date_p return varchar2 is
	Begin
	 return c_last_stmnt_next_trx_date;
	 END;
 Function c_last_st_date_p return varchar2 is
	Begin
	 return c_last_st_date;
	 END;
 Function c_last_st_type_p return varchar2 is
	Begin
	 return c_last_st_type;
	 END;
 Function c_last_st_number_p return varchar2 is
	Begin
	 return c_last_st_number;
	 END;
 Function c_last_st_days_since_p return varchar2 is
	Begin
	 return c_last_st_days_since;
	 END;
 Function c_last_dn_days_since_p return varchar2 is
	Begin
	 return c_last_dn_days_since;
	 END;
 Function c_last_dn_date_p return varchar2 is
	Begin
	 return c_last_dn_date;
	 END;
 Function c_last_dn_currency_p return varchar2 is
	Begin
	 return c_last_dn_currency;
	 END;
 Function c_last_dn_amount_p return number is
	Begin
	 return c_last_dn_amount;
	 END;
 Function c_last_dn_type_p return varchar2 is
	Begin
	 return c_last_dn_type;
	 END;
 Function c_last_dn_number_p return varchar2 is
	Begin
	 return c_last_dn_number;
	 END;
 Function c_last_nsf_currency_p return varchar2 is
	Begin
	 return c_last_nsf_currency;
	 END;
 Function c_last_nsf_days_since_p return varchar2 is
	Begin
	 return c_last_nsf_days_since;
	 END;
 Function c_last_nsf_date_p return varchar2 is
	Begin
	 return c_last_nsf_date;
	 END;
 Function c_last_nsf_converted_p return varchar2 is
	Begin
	 return c_last_nsf_converted;
	 END;
 Function c_last_nsf_amount_p return number is
	Begin
	 return c_last_nsf_amount;
	 END;
 Function c_last_nsf_type_p return varchar2 is
	Begin
	 return c_last_nsf_type;
	 END;
 Function c_last_nsf_number_p return varchar2 is
	Begin
	 return c_last_nsf_number;
	 END;
 Function c_last_contact_days_since_p return varchar2 is
	Begin
	 return c_last_contact_days_since;
	 END;
 Function c_last_contact_date_p return varchar2 is
	Begin
	 return c_last_contact_date;
	 END;
 Function c_last_contact_amount_p return number is
	Begin
	 return c_last_contact_amount;
	 END;
 Function c_last_contact_converted_p return varchar2 is
	Begin
	 return c_last_contact_converted;
	 END;
 Function c_last_contact_currency_p return varchar2 is
	Begin
	 return c_last_contact_currency;
	 END;
 Function c_last_contact_rel_invoice_p return varchar2 is
	Begin
	 return c_last_contact_rel_invoice;
	 END;
 Function c_last_contact_number_p return varchar2 is
	Begin
	 return c_last_contact_number;
	 END;
 Function c_last_hold_days_since_p return varchar2 is
	Begin
	 return c_last_hold_days_since;
	 END;
 Function c_last_hold_date_p return varchar2 is
	Begin
	 return c_last_hold_date;
	 END;
 Function c_last_hold_amount_p return number is
	Begin
	 return c_last_hold_amount;
	 END;
 Function c_last_hold_number_p return varchar2 is
	Begin
	 return c_last_hold_number;
	 END;
 Function CP_DEFAULT_FLAG_p return varchar2 is
	Begin
	 return CP_DEFAULT_FLAG;
	 END;
 Function c_percent_b0_p return varchar2 is
	Begin
	 return c_percent_b0;
	 END;
 Function c_percent_b1_p return varchar2 is
	Begin
	 return c_percent_b1;
	 END;
 Function c_percent_b2_p return varchar2 is
	Begin
	 return c_percent_b2;
	 END;
 Function c_percent_b3_p return varchar2 is
	Begin
	 return c_percent_b3;
	 END;
 Function c_percent_b4_p return varchar2 is
	Begin
	 return c_percent_b4;
	 END;
 Function c_percent_b5_p return varchar2 is
	Begin
	 return c_percent_b5;
	 END;
 Function c_percent_b6_p return varchar2 is
	Begin
	 return c_percent_b6;
	 END;
 Function c_aging_on_account_p return number is
	Begin
	 return c_aging_on_account;
	 END;
 Function c_aging_unapplied_p return number is
	Begin
	 return c_aging_unapplied;
	 END;
 Function c_aging_convert_on_account_p return varchar2 is
	Begin
	 return c_aging_convert_on_account;
	 END;
 Function c_aging_convert_unapplied_p return varchar2 is
	Begin
	 return c_aging_convert_unapplied;
	 END;
 Function c_aging_credit_p return number is
	Begin
	 return c_aging_credit;
	 END;
 Function c_aging_convert_credit_p return varchar2 is
	Begin
	 return c_aging_convert_credit;
	 END;
 Function c_adjusted_balance_p return number is
	Begin
	 return c_adjusted_balance;
	 END;
 Function c_aging_convert_collection_p return varchar2 is
	Begin
	 return c_aging_convert_collection;
	 END;
 Function c_aging_in_collection_p return number is
	Begin
	 return c_aging_in_collection;
	 END;
 Function c_cust_hist_high_invoice_amt_p return number is
	Begin
	 return c_cust_hist_high_invoice_amt;
	 END;
 --Function c_cust_hist_conv_high_invoice return varchar2 is
 Function c_cust_hist_conv_high_inv_p return varchar2 is
	Begin
	 return c_cust_hist_conv_high_invoice;
	 END;
-- Function c_cust_hist_high_invoice_date return varchar2 is
 Function c_cust_hist_high_inv_date_p return varchar2 is

	Begin
	 return c_cust_hist_high_invoice_date;
	 END;
 Function c_cust_hist_high_limit_date_p return date is
	Begin
	 return c_cust_hist_high_limit_date;
	 END;
 Function c_ytd_nsf_count_p return number is
	Begin
	 return c_ytd_nsf_count;
	 END;
 Function c_ytd_convert_nsf_p return varchar2 is
	Begin
	 return c_ytd_convert_nsf;
	 END;
 Function c_ytd_nsf_amount_p return number is
	Begin
	 return c_ytd_nsf_amount;
	 END;
 Function c_ytd_conv_unearned_discount_p return varchar2 is
	Begin
	 return c_ytd_conv_unearned_discount;
	 END;
 Function c_ytd_unearned_discount_amoun return number is
	Begin
	 return c_ytd_unearned_discount_amount;
	 END;
 --Function c_ytd_convert_earned_discount return varchar2 is
 Function c_ytd_convert_earned_dis_p return varchar2 is
	Begin
	 return c_ytd_convert_earned_discount;
	 END;
 Function c_ytd_earned_discount_amount_p return number is
	Begin
	 return c_ytd_earned_discount_amount;
	 END;
 Function c_ytd_on_time_payments_count_p return number is
	Begin
	 return c_ytd_on_time_payments_count;
	 END;
 Function c_ytd_late_payments_count_p return number is
	Begin
	 return c_ytd_late_payments_count;
	 END;
 Function c_ytd_average_days_late_p return number is
	Begin
	 return c_ytd_average_days_late;
	 END;
 Function c_ytd_average_payment_days_p return number is
	Begin
	 return c_ytd_average_payment_days;
	 END;
 Function c_ytd_finance_charge_count_p return number is
	Begin
	 return c_ytd_finance_charge_count;
	 END;
 Function c_ytd_convert_finance_charge_p return varchar2 is
	Begin
	 return c_ytd_convert_finance_charge;
	 END;
 Function c_ytd_finance_charge_amount_p return number is
	Begin
	 return c_ytd_finance_charge_amount;
	 END;
 Function c_ytd_credit_count_p return number is
	Begin
	 return c_ytd_credit_count;
	 END;
 Function c_ytd_convert_credit_p return varchar2 is
	Begin
	 return c_ytd_convert_credit;
	 END;
 Function c_ytd_credit_amount_p return number is
	Begin
	 return c_ytd_credit_amount;
	 END;
 Function c_ytd_payment_count_p return number is
	Begin
	 return c_ytd_payment_count;
	 END;
 Function c_ytd_convert_payment_p return varchar2 is
	Begin
	 return c_ytd_convert_payment;
	 END;
 Function c_ytd_payment_amount_p return number is
	Begin
	 return c_ytd_payment_amount;
	 END;
 Function c_ytd_sales_count_p return number is
	Begin
	 return c_ytd_sales_count;
	 END;
 Function c_ytd_convert_sales_p return varchar2 is
	Begin
	 return c_ytd_convert_sales;
	 END;
 Function c_ytd_sales_amount_p return number is
	Begin
	 return c_ytd_sales_amount;
	 END;
 Function c_ytd_convert_writeoff_p return varchar2 is
	Begin
	 return c_ytd_convert_writeoff;
	 END;
 Function c_ytd_writeoff_amount_p return number is
	Begin
	 return c_ytd_writeoff_amount;
	 END;
 Function CP_limit_currency_p return varchar2 is
	Begin
	 return CP_limit_currency;
	 END;
 Function CP_related_currencies_p return varchar2 is
	Begin
	 return CP_related_currencies;
	 END;
 Function CP_txn_cur_p return varchar2 is
	Begin
	 return CP_txn_cur;
	 END;
 Function c_cred_summ_convert_limit_p return varchar2 is
	Begin
	 return c_cred_summ_convert_limit;
	 END;
 Function c_cred_summ_exceeded_p return number is
	Begin
	 return c_cred_summ_exceeded;
	 END;
 Function c_cred_summ_available_p return number is
	Begin
	 return c_cred_summ_available;
	 END;
 Function CP_trx_amount_p return number is
	Begin
	 return CP_trx_amount;
	 END;
 Function CP_trx_curr_p return number is
	Begin
	 return CP_trx_curr;
	 END;
 Function CP_limit_curr_amt_p return number is
	Begin
	 return CP_limit_curr_amt;
	 END;
 Function CP_rate_p return number is
	Begin
	 return CP_rate;
	 END;
 Function CP_adjusted_amount_p return number is
	Begin
	 return CP_adjusted_amount;
	 END;
 Function CP_limit_curr_amt1_p return number is
	Begin
	 return CP_limit_curr_amt1;
	 END;
 Function CP_rate1_p return number is
	Begin
	 return CP_rate1;
	 END;
 Function CP_adjusted_amount1_p return number is
	Begin
	 return CP_adjusted_amount1;
	 END;
 Function C_cred_summ_exceeded2_p return number is
	Begin
	 return C_cred_summ_exceeded2;
	 END;
 Function C_cred_summ_available2_p return number is
	Begin
	 return C_cred_summ_available2;
	 END;
 Function C_cred_convert_limit2_p return varchar2 is
	Begin
	 return C_cred_convert_limit2;
	 END;
 Function CP_trx_amount2_p return number is
	Begin
	 return CP_trx_amount2;
	 END;
 Function CP_trx_cur2_p return varchar2 is
	Begin
	 return CP_trx_cur2;
	 END;
 Function C_org_credit_hold_p return varchar2 is
	Begin
	 return C_org_credit_hold;
	 END;
 Function C_org_credit_rating_p return varchar2 is
	Begin
	 return C_org_credit_rating;
	 END;
 Function C_Org_limit_tolerance_p return varchar2 is
	Begin
	 return C_Org_limit_tolerance;
	 END;
 Function C_credit_profile_id_p return number is
	Begin
	 return C_credit_profile_id;
	 END;
 Function CP_limit_curr_amt2_p return number is
	Begin
	 return CP_limit_curr_amt2;
	 END;
 Function CP_Rate2_p return number is
	Begin
	 return CP_Rate2;
	 END;
 Function CP_adjusted_amount2_p return number is
	Begin
	 return CP_adjusted_amount2;
	 END;
 Function CP_TRX_AMOUNT1_p return number is
	Begin
	 return CP_TRX_AMOUNT1;
	 END;
 Function C_CRED_SUMM_AVAILABLE1_p return number is
	Begin
	 return C_CRED_SUMM_AVAILABLE1;
	 END;
 Function C_CRED_CONVERT_LIMIT1_p return varchar2 is
	Begin
	 return C_CRED_CONVERT_LIMIT1;
	 END;
 Function C_CRED_SUMM_EXCEEDED1_p return number is
	Begin
	 return C_CRED_SUMM_EXCEEDED1;
	 END;
 Function CP_TRX_CUR1_p return varchar2 is
	Begin
	 return CP_TRX_CUR1;
	 END;
 Function DEFAULT_FLAG_p return varchar2 is
	Begin
	 return DEFAULT_FLAG;
	 END;
 Function LIMIT_CURRENCY_p return varchar2 is
	Begin
	 return LIMIT_CURRENCY;
	 END;
 Function RELATED_CURRENCIES_p return varchar2 is
	Begin
	 return RELATED_CURRENCIES;
	 END;
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
 Function RP_DATA_FOUND_p return varchar2 is
	Begin
	 return RP_DATA_FOUND;
	 END;
 Function RP_DATE_RANGE_p return varchar2 is
	Begin
	 return RP_DATE_RANGE;
	 END;
 Function RP_BUCKET_DAYS_FROM_0_p return number is
	Begin
	 return RP_BUCKET_DAYS_FROM_0;
	 END;
 Function RP_BUCKET_DAYS_FROM_1_p return number is
	Begin
	 return RP_BUCKET_DAYS_FROM_1;
	 END;
 Function RP_BUCKET_DAYS_FROM_2_p return number is
	Begin
	 return RP_BUCKET_DAYS_FROM_2;
	 END;
 Function RP_BUCKET_DAYS_FROM_3_p return number is
	Begin
	 return RP_BUCKET_DAYS_FROM_3;
	 END;
 Function RP_BUCKET_DAYS_FROM_4_p return number is
	Begin
	 return RP_BUCKET_DAYS_FROM_4;
	 END;
 Function RP_BUCKET_DAYS_FROM_5_p return number is
	Begin
	 return RP_BUCKET_DAYS_FROM_5;
	 END;
 Function RP_BUCKET_DAYS_TO_0_p return number is
	Begin
	 return RP_BUCKET_DAYS_TO_0;
	 END;
 Function RP_BUCKET_DAYS_TO_1_p return number is
	Begin
	 return RP_BUCKET_DAYS_TO_1;
	 END;
 Function RP_BUCKET_DAYS_TO_2_p return number is
	Begin
	 return RP_BUCKET_DAYS_TO_2;
	 END;
 Function RP_BUCKET_DAYS_TO_3_p return number is
	Begin
	 return RP_BUCKET_DAYS_TO_3;
	 END;
 Function RP_BUCKET_DAYS_TO_4_p return number is
	Begin
	 return RP_BUCKET_DAYS_TO_4;
	 END;
 Function RP_BUCKET_DAYS_TO_5_p return number is
	Begin
	 return RP_BUCKET_DAYS_TO_5;
	 END;
 Function RP_BUCKET_LINE_TYPE_0_p return varchar2 is
	Begin
	 return RP_BUCKET_LINE_TYPE_0;
	 END;
 Function RP_BUCKET_LINE_TYPE_1_p return varchar2 is
	Begin
	 return RP_BUCKET_LINE_TYPE_1;
	 END;
 Function RP_BUCKET_LINE_TYPE_2_p return varchar2 is
	Begin
	 return RP_BUCKET_LINE_TYPE_2;
	 END;
 Function RP_BUCKET_LINE_TYPE_3_p return varchar2 is
	Begin
	 return RP_BUCKET_LINE_TYPE_3;
	 END;
 Function RP_BUCKET_LINE_TYPE_4_p return varchar2 is
	Begin
	 return RP_BUCKET_LINE_TYPE_4;
	 END;
 Function RP_BUCKET_LINE_TYPE_5_p return varchar2 is
	Begin
	 return RP_BUCKET_LINE_TYPE_5;
	 END;
 Function RP_BUCKET_TITLE0_p return varchar2 is
	Begin
	 return RP_BUCKET_TITLE0;
	 END;
 Function RP_BUCKET_TITLE1_p return varchar2 is
	Begin
	 return RP_BUCKET_TITLE1;
	 END;
 Function RP_BUCKET_TITLE2_p return varchar2 is
	Begin
	 return RP_BUCKET_TITLE2;
	 END;
 Function RP_BUCKET_TITLE3_p return varchar2 is
	Begin
	 return RP_BUCKET_TITLE3;
	 END;
 Function RP_BUCKET_TITLE4_p return varchar2 is
	Begin
	 return RP_BUCKET_TITLE4;
	 END;
 Function RP_BUCKET_TITLE5_p return varchar2 is
	Begin
	 return RP_BUCKET_TITLE5;
	 END;
 Function RP_BUCKET_CATEGORY_p return varchar2 is
	Begin
	 return RP_BUCKET_CATEGORY;
	 END;
 Function RP_BUCKET_DAYS_FROM_6_p return number is
	Begin
	 return RP_BUCKET_DAYS_FROM_6;
	 END;
 Function RP_BUCKET_DAYS_TO_6_p return number is
	Begin
	 return RP_BUCKET_DAYS_TO_6;
	 END;
 Function RP_BUCKET_LINE_TYPE_6_p return varchar2 is
	Begin
	 return RP_BUCKET_LINE_TYPE_6;
	 END;
 Function RP_BUCKET_TITLE6_p return varchar2 is
	Begin
	 return RP_BUCKET_TITLE6;
	 END;
 Function C_industry_code_p return varchar2 is
	Begin
	 return C_industry_code;
	 END;
 Function C_sales_title_p return varchar2 is
	Begin
	 return C_sales_title;
	 END;
 Function RP_UNAVAILABLE_p return varchar2 is
	Begin
	 return RP_UNAVAILABLE;
	 END;
 Function RP_YEARS_p return varchar2 is
	Begin
	 return RP_YEARS;
	 END;
 Function RP_NONE_p return varchar2 is
	Begin
	 return RP_NONE;
	 END;
 Function RP_NA_UPPER_p return varchar2 is
	Begin
	 return RP_NA_UPPER;
	 END;
 Function RP_NO_LIMIT_p return varchar2 is
	Begin
	 return RP_NO_LIMIT;
	 END;
 Function RP_MESSAGE_p return varchar2 is
	Begin
	 return RP_MESSAGE;
	 END;
END AR_ARXCCS_XMLP_PKG ;



/
