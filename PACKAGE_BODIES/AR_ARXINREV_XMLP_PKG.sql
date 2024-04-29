--------------------------------------------------------
--  DDL for Package Body AR_ARXINREV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXINREV_XMLP_PKG" AS
/* $Header: ARXINREVB.pls 120.1 2008/01/07 14:52:23 abraghun noship $ */
function BeforeReport return boolean is
begin
declare
due_date	date;
errorbuf	varchar2(1000); x char(1);
acc_start_date   date;
acc_org_id      number(15);
l_msg           varchar2(2000);
begin
  /*SRW.USER_EXIt('FND SRWINIT');*/null;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('1','After SRWINIT');*/null;
  END IF;
       /*srw.message('1000','start');*/null;
       	select max(due_date)
	into due_date
	from ar_payment_schedules;
	IF (p_debug_switch = 'Y') THEN
     	/*SRW.MESSAGE('2','After Selecting Due Date');*/null;
  	END IF;
	/*srw.reference(p_test_layout);*/null;
	if p_test_layout = 'Y'
	then
   		raise no_data_found;
	end if;
	if P_CHART_OF_ACCOUNTS_ID  is null
 	then
   	select to_char(gl.chart_of_accounts_id)
   	into P_CHART_OF_ACCOUNTS_ID
   	from   gl_sets_of_books gl, ar_system_parameters p
   	where  gl.set_of_books_id = p.set_of_books_id;
 	end if;
  	IF (p_debug_switch = 'Y') THEN
     	   /*SRW.MESSAGE('3','After Selecting Chart of Accounts Id');*/null;
  	END IF;
	select currency_code
		into P_CURRENCY
	from gl_sets_of_books gl, ar_system_parameters ar
	where ar.set_of_books_id = gl.set_of_books_id;
  	IF (p_debug_switch = 'Y') THEN
     	   /*SRW.MESSAGE('4','After Selecting Currency Code');*/null;
  	END IF;
	select precision
		into P_PRECISION
	from fnd_currencies
	where currency_code = P_CURRENCY;
  	IF (p_debug_switch = 'Y') THEN
     	  /*SRW.MESSAGE('5','After Selecting Precision');*/null;
  	END IF;
	select minimum_accountable_unit
		into P_MIN_ACCOUNTABLE_UNIT
	from fnd_currencies
	where currency_code = P_CURRENCY;
  	IF (p_debug_switch = 'Y') THEN
     	/*SRW.MESSAGE('6','After Selecting Minimum Accountable Unit');*/null;
  	END IF;
	select gl.name, gl.set_of_books_id, ar.org_id
	into P_NAME, P_SET_OF_BOOKS_ID,acc_org_id
	from gl_sets_of_books gl, ar_system_parameters ar
	where gl.set_of_books_id = ar.set_of_books_id;
  	IF (p_debug_switch = 'Y') THEN
     	   /*SRW.MESSAGE('7','After Selecting Set Of Books Id, Company Name');*/null;
  	END IF;
	select end_date
	into P_END_DATE
	from gl_period_statuses gl
	where gl.set_of_books_id = P_SET_OF_BOOKS_ID            and gl.application_id  = 222
          and gl.period_name     = P_REVALUATION_PERIOD;
       LP_END_DATE:=P_END_DATE;
        select min(start_date)
        into acc_start_date
        from gl_period_statuses gl
        where gl.set_of_books_id = P_SET_OF_BOOKS_ID
        and gl.application_id=222;
        IF arp_util.open_period_exists('3000',acc_org_id,acc_start_date,p_end_date) THEN
           FND_MESSAGE.SET_NAME('AR','AR_REPORT_ACC_NOT_GEN');
           l_msg := FND_MESSAGE.get;
           CP_ACC_MESSAGE := l_msg;
        ELSE
           CP_ACC_MESSAGE := NULL;
        END IF;
  	IF (p_debug_switch = 'Y') THEN
     	/*SRW.MESSAGE('8','P End Date ' || P_END_DATE || ' ' || P_UP_TO_DUE_DATE );*/null;
  	END IF;
        P_REVALUATION_DATE := P_END_DATE;
	if P_UP_TO_DUE_DATE is null
	then
	  P_DUE_DATE_DISP  := P_UP_TO_DUE_DATE;
	  LP_UP_TO_DUE_DATE := due_date;
	else
	  P_DUE_DATE_DISP  := P_UP_TO_DUE_DATE;
	end if;
	IF P_RATE_TYPE_LOOKUP = 'DAILY' THEN
		IF P_DAILY_RATE_TYPE IS NULL OR P_RATE_DATE IS NULL THEN
			C_DAILY_RATE_LOOKUP_ERROR := 'Y';
		ELSE
			C_DAILY_RATE_LOOKUP_ERROR := 'N';
		END IF;
	END IF;
       IF (p_debug_switch = 'Y') THEN
     	/*SRW.MESSAGE('9','Before USER EXIT FND FLEX Balancing Segment Low');*/null;
  	END IF;
	if p_bal_segment_low is NOT NULL  then
 null;
	IF (p_debug_switch = 'Y') THEN
     	/*SRW.MESSAGE('100','After USER EXIT FND FLEX Balancing Segment Low');*/null;
  	END IF;
	lp_bal_segment_low := ' and '|| lp_bal_segment_low || '||'''' >= ''' || p_bal_segment_low || ''' ';
	end if ;
	if p_bal_segment_high is NOT NULL then
 null;
	lp_bal_segment_high := ' and '|| lp_bal_segment_high || '||'''' <= ''' || p_bal_segment_high || ''' ';
	end if ;
	IF (p_debug_switch = 'Y') THEN
     	/*SRW.MESSAGE('10','After USER EXIT FND FLEX Balancing Segment High');*/null;
  	END IF;
 null;
  	IF (p_debug_switch = 'Y') THEN
     	/*SRW.MESSAGE('11','After USER EXIT FND FLEX ALL');*/null;
  	END IF;
        exception
	WHEN others THEN
	errorbuf := SQLERRM(SQLCODE);
	/*srw.message('12',errorbuf);*/null;
	raise_application_error(-20101,null);/*srw.PROGRAM_ABORT;*/null;
end;
  return (TRUE);
end;
function AfterReport return boolean is
begin
BEGIN
   /*SRW.USER_EXIT('FND SRWEXIT');*/null;
   IF (P_DEBUG_SWITCH = 'Y') THEN
      /*SRW.MESSAGE('12','After SRWEXIT');*/null;
   END IF;
EXCEPTION
WHEN OTHERS THEN
   RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;
END;  return (TRUE);
end;
function aol_round( n in number, precision in number, mac in number) return number is
begin
   if precision is null
   then
      /*srw.message( '100', 'Precision is null in call to aol_round');*/null;
   end if;
   if mac is null
   then
      return(round(n, precision));
   else
      return( round( n / mac ) * mac );
   end if;
RETURN NULL; end;
function c_eop_rateformula(C_CURR in varchar2, C_TYPE in varchar2, C_EXCHANGE_RATE in number) return number is
begin
declare
eop_rate	number;
begin
	/*srw.reference(C_CURR);*/null;
	/*srw.reference(C_TYPE);*/null;
	/*srw.reference(C_EXCHANGE_RATE);*/null;
	if C_CURR = P_CURRENCY then return(1.00);
	else
		IF P_RATE_TYPE_LOOKUP = 'PERIOD' THEN
	select decode(tr.EOP_RATE, 0,0, 1/tr.EOP_RATE) 	into eop_rate
	from gl_translation_rates tr
	where tr.set_of_books_id    = P_SET_OF_BOOKS_ID
	  and tr.to_currency_code   = C_CURR
	  and upper(tr.period_name) = upper(P_REVALUATION_PERIOD)
	  and tr.actual_flag        = 'A';
		ELSE
			eop_rate := gl_currency_api.get_rate_sql
			(c_curr,P_currency,
			 P_RATE_DATE,
			 P_DAILY_RATE_TYPE);
                   if eop_rate < 0 then
			raise NO_DATA_FOUND ;
		   end if;
		END IF;
	end if;
	if C_TYPE = 'DEP'
	then
	eop_rate := C_EXCHANGE_RATE;
	end if;
        return(eop_rate * 1.00);
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
        	/*srw.message(1000, 'No End of Period Rate found for ' || C_CURR );*/null;
end;
RETURN NULL; end;
function c_open_funcformula(C_OPEN_ORIG in number, C_EXCHANGE_RATE in number) return number is
begin
 /*srw.reference(CF_EOP_EXCH_RATE);*/null;
 /*srw.reference(C_EXCHANGE_RATE);*/null;
 /*srw.reference(c_open_orig);*/null;
 return (nvl(C_OPEN_ORIG,0) * nvl(C_EXCHANGE_RATE,1));
 end;
function c_open_revformula(C_EOP_RATE in number, C_EXCHANGE_RATE in number, C_OPEN_ORIG in number, C_OPEN_FUNC in number) return number is
begin
declare
revaluated	number;
  begin
   /*srw.reference(C_EOP_RATE);*/null;
   /*srw.reference(C_EXCHANGE_RATE);*/null;
   /*srw.reference(C_OPEN_ORIG);*/null;
   /*srw.reference(C_OPEN_FUNC);*/null;
   if nvl(C_EOP_RATE,0) < C_EXCHANGE_RATE
     then
      revaluated := nvl(C_OPEN_ORIG,0) * nvl(C_EOP_RATE,0);
     else
      revaluated := nvl(C_OPEN_FUNC,0);
   end if;
   if  C_EOP_RATE is NULL then
	revaluated := NULL;
   end if;
return(revaluated);
end;
RETURN NULL; end;
function c_diffformula(C_OPEN_REV in number, C_OPEN_FUNC in number) return number is
begin
 return (nvl(C_OPEN_REV,0) - nvl(C_OPEN_FUNC,0));
end;
function c_receiptsformula(C_PAY_ID in number) return number is
begin
declare
	receipt	number;
begin
/*srw.reference(C_PAY_ID);*/null;
if p_cleared = 'N'
then
   select sum(nvl(app.amount_applied,0) + nvl(app.earned_discount_taken,0) + nvl(app.unearned_discount_taken,0))
     into receipt
     from ar_receivable_applications app
    where app.applied_payment_schedule_id = C_PAY_ID
      and app.status = 'APP'
      and app.gl_date <= P_END_DATE
      and app.application_type='CASH'
      and not exists (
		select 'reversed'
		   from ar_cash_receipt_history crh
		  where app.cash_receipt_id = crh.cash_receipt_id
		    and crh.status = 'REVERSED'
		    and crh.gl_date <= P_END_DATE);
else
   select sum(nvl(app.amount_applied,0) + nvl(app.earned_discount_taken,0) + nvl(app.unearned_discount_taken,0))
     into receipt
     from ar_receivable_applications app
    where app.applied_payment_schedule_id = C_PAY_ID
      and app.status = 'APP'
      and app.gl_date <= P_END_DATE
      and app.application_type='CASH'
      and exists
       ( select 'Cleared Receipt'
           from ar_cash_receipt_history_all crh
          where crh.cash_receipt_id = app.cash_receipt_id
            and crh.status = 'CLEARED'
            and crh.gl_date <= P_END_DATE
            and nvl(crh.reversal_gl_date,P_END_DATE+1) > P_END_DATE) ;
end if;
return(receipt);
EXCEPTION
when NO_DATA_FOUND then
  return(0);
end;
RETURN NULL; end;
function c_open_origformula(C_PAY_AMOUNT in number, C_RECEIPTS in number, C_ADJUST in number, C_CM in number, C_CM1 in number) return number is
STATED_REPORTING_PERIOD_RCPTS number;
begin
/*srw.reference(C_REVALUATE_YES_NO);*/null;
/*srw.reference(C_PAY_AMOUNT);*/null;
/*srw.reference(C_RECEIPTS);*/null;
/*srw.reference(C_ADJUST);*/null;
/*srw.reference(C_CM);*/null;
/*srw.reference(C_CM1);*/null;
   return(nvl(C_PAY_AMOUNT,0) - nvl(C_RECEIPTS,0)  + nvl(C_ADJUST,0) - nvl(C_CM,0) + nvl(C_CM1,0));
End;
function calc_open_funcformula(C_OPEN_FUNC in number) return number is
begin
declare
calc_amount number;
begin
/*SRW.REFERENCE(C_OPEN_FUNC);*/null;
calc_amount := aol_round(C_OPEN_FUNC,
				P_PRECISION, P_MIN_ACCOUNTABLE_UNIT);
/*srw.reference (c_trx_number);*/null;
/*srw.reference(C_PREVIOUS_CUST_TRX_ID);*/null;
/*srw.reference(C_TYPE);*/null;
return(nvl(calc_amount,0));
end;
RETURN NULL;
end;
function calc_open_revformula(C_OPEN_REV in number) return number is
begin
declare
calc_amount number;
begin
/*SRW.REFERENCE(C_OPEN_REV);*/null;
calc_amount := aol_round(C_OPEN_REV,
				P_PRECISION, P_MIN_ACCOUNTABLE_UNIT);
return(calc_amount);
end;
RETURN NULL; end;
function calc_eop_amountformula(C_EOP_AMOUNT in number) return number is
begin
declare
calc_amount number;
begin
/*SRW.REFERENCE(C_EOP_AMOUNT);*/null;
calc_amount := aol_round(C_EOP_AMOUNT,
				P_PRECISION, P_MIN_ACCOUNTABLE_UNIT);
return(calc_amount);
end;
RETURN NULL; end;
function c_adjustformula(C_PAY_ID in number) return number is
begin
declare
	adjust	number;
begin
/*srw.reference(C_PAY_ID);*/null;
select sum(amount)
	into adjust
from  ar_adjustments adj
where  adj.payment_schedule_id = C_PAY_ID
  and  adj.gl_date <= P_END_DATE
  and  adj.status = 'A';
return(adjust);
EXCEPTION
when NO_DATA_FOUND then
  return(0);
end;
RETURN NULL; end;
function c_eop_amountformula(C_EOP_RATE in number, C_OPEN_ORIG in number) return number is
begin
/*srw.reference(C_EOP_RATE);*/null;
/*srw.reference(C_OPEN_FUNC);*/null;
/*srw.reference(C_OPEN_ORIG);*/null;
/*srw.reference(CF_EOP_EXCH_RATE);*/null;
/*srw.reference(C_EXCHANGE_RATE);*/null;
if C_EOP_RATE is not NULL then
 return(nvl(C_OPEN_ORIG,0) * nvl(C_EOP_RATE,0));
else
 return(NULL);
end if;
RETURN NULL; end;
function c_eop_diffformula(C_SUM_EOP_AMOUNT in number, C_SUM_OPEN_FUNC in number) return number is
begin
 return (nvl(C_SUM_EOP_AMOUNT,0) - nvl(C_SUM_OPEN_FUNC,0));
end;
function c_rev_diffformula(C_SUM_OPEN_REV in number, C_SUM_OPEN_FUNC in number) return number is
begin
 return (nvl(C_SUM_OPEN_REV,0) -  nvl(C_SUM_OPEN_FUNC,0));
end;
function c_sum_eop_diffformula(C_SUM_EOP_AMOUNT in number, C_SUM_OPEN_FUNC in number) return number is
begin
 return (nvl(C_SUM_EOP_AMOUNT,0) - nvl(C_SUM_OPEN_FUNC,0));
end;
function c_sum_rev_diffformula(C_SUM_OPEN_REV in number, C_SUM_OPEN_FUNC in number) return number is
begin
 return (nvl(C_SUM_OPEN_REV,0) - nvl(C_SUM_OPEN_FUNC,0));
end;
function c_flagformula(C_EOP_RATE in number, C_OPEN_ORIG in number) return number is
begin
/*srw.reference(C_EOP_RATE);*/null;
/*srw.reference(C_OPEN_ORIG);*/null;
if C_EOP_RATE is NULL and C_OPEN_ORIG <> 0
then return(1);
else return(0);
end if;
RETURN NULL; end;
function c_cmformula(C_PAY_ID in number) return number is
begin
declare
cm	number;
begin
/*srw.reference(C_PAY_ID);*/null;
select 	sum(nvl(app.amount_applied,0))
	into cm
from 	ar_receivable_applications app
where 	app.gl_date <= P_END_DATE
   and	app.status ='APP'
   and  app.application_type = 'CM'
   and  app.applied_payment_schedule_id = C_PAY_ID ;
return(cm);
EXCEPTION
when NO_DATA_FOUND then
return(0);
end;
RETURN NULL; end;
function c_tot_eop_diffformula(C_TOT_EOP_AMOUNT in number, C_TOT_OPEN_FUNC in number) return number is
begin
/*srw.reference(C_TOT_OPEN_FUNC);*/null;
/*srw.reference(C_TOT_EOP_AMOUNT);*/null;
return(nvl(C_TOT_EOP_AMOUNT,0) - nvl(C_TOT_OPEN_FUNC,0));
end;
function c_tot_rev_diffformula(C_TOT_OPEN_REV in number, C_TOT_OPEN_FUNC in number) return number is
begin
/*srw.reference(C_TOT_OPEN_REV);*/null;
/*srw.reference(C_TOT_OPEN_FUNC);*/null;
return(nvl(C_TOT_OPEN_REV,0) - nvl(C_TOT_OPEN_FUNC,0));
end;
function cf_eop_reval_amountformula(Cf_EOP_EXCH_RATE in number, C_TYPE in varchar2, c_exchange_rate in number, C_REVALUATE_YES_NO in varchar2, C_OPEN_ORIG in number, c_previous_cust_trx_id in number) return number is
begin
if Cf_EOP_EXCH_RATE is not null and C_TYPE <> 'CM' then
   if (Cf_EOP_EXCH_RATE < c_exchange_rate and C_REVALUATE_YES_NO = 'Y') then
      return(nvl(C_OPEN_ORIG,0) * nvl(Cf_EOP_EXCH_RATE,0));
   else
      return(nvl(C_OPEN_ORIG,0) * nvl(C_EXCHANGE_RATE,0));
   END IF;
elsif
   Cf_EOP_EXCH_RATE is not null and C_TYPE = 'CM' then
   if (Cf_EOP_EXCH_RATE > c_exchange_rate and C_REVALUATE_YES_NO = 'Y') then
       if c_previous_cust_trx_id <> 0 then
          return 0;
       else
          return(nvl(C_OPEN_ORIG,0) * nvl(Cf_EOP_EXCH_RATE,0));
       end if;
   else
      if c_previous_cust_trx_id <> 0 then
          return 0;
      else
          return(nvl(C_OPEN_ORIG,0) * nvl(C_EXCHANGE_RATE,0));
      end if;
   END IF;
return(NULL);
end if;
return(NULL);
end;
function cf_total_adjustmentsformula(C_PAY_ID in number, C_OPEN_ORIG in number) return number is
BEGIN
declare
	adjust	number;
	ratio   number;
begin
/*srw.reference(C_PAY_ID);*/null;
/*srw.reference(C_OPEN_ORIG);*/null;
select sum(amount)
	into adjust
from  ar_adjustments adj
where  adj.payment_schedule_id = C_PAY_ID
  and  adj.gl_date > P_REVALUATION_DATE
  and  adj.status = 'APP';
ratio := C_OPEN_ORIG/(C_OPEN_ORIG + ADJUST);
return(RATIO);
EXCEPTION
when NO_DATA_FOUND then
  return(1);
end;
END;
function AfterPForm return boolean is
begin
LP_END_DATE:= P_END_DATE;
P_RATE_DATE1 := to_char(P_RATE_DATE,'dd-MON-yy');
LP_UP_TO_DUE_DATE:=P_UP_TO_DUE_DATE;
	  		     --(orig st)lp_dates := ' Pay.DUE_DATE <= :P_UP_TO_DUE_DATE and pay.gl_date <= :P_end_date and ';
	  		   lp_dates := ' Pay.DUE_DATE <= :LP_UP_TO_DUE_DATE and pay.gl_date <= :LP_END_DATE and ';
					IF P_POSTED = 'Y' THEN
              lp_posted := ' dist.gl_posted_date is not null and ';
        ELSE
           lp_posted := ' ';
        END IF;
		  			IF P_POSTED = 'Y' THEN
	   lp_posted_RECEIPTS := ' AND crh.gl_posted_date is not null ';
        ELSE
           lp_posted_receipts := ' ';
	END IF;
 	IF P_CLEARED = 'Y'  THEN
	    lp_cleared := ' and crh.status =' || '''CLEARED''' ;
     --(orig st)lp_cleared_new := 'and ((pay.gl_date_closed > :P_END_DATE) ' ||
                lp_cleared_new := 'and ((pay.gl_date_closed > :LP_END_DATE) ' ||
		' or exists ' ||
       		' ( select ''receipt clear after p_end_date''  ' ||
		'	  from ar_receivable_applications_all app ' ||
		'               ,ar_cash_receipt_history_all crh ' ||
		'	where trx.customer_trx_id = app.applied_customer_Trx_id ' ||
		'  	and   app.cash_receipt_id = crh.cash_receipt_id' ||
                '       and   crh.status <> ''CLEARED'' ' ||
		--(orig st)'       and   crh.gl_date <= :P_END_DATE' ||
		'       and   crh.gl_date <= :LP_END_DATE' ||
             --(orig st) '        and   nvl(crh.reversal_gl_date, :P_END_DATE +1 ) > :P_END_DATE ) ) ' ;
            '        and   nvl(crh.reversal_gl_date, TO_DATE(:LP_END_DATE,''DD-MON-YYYY'') +1 ) > :LP_END_DATE ) ) ';
	ELSE
         --(orig st)lp_cleared_new := ' and pay.gl_date_closed > :P_END_DATE ' ;
           lp_cleared_new := ' and pay.gl_date_closed > :LP_END_DATE ' ;
	END IF;
  return (TRUE);
end;
function cf_curr_to_func_exch_rateformu(C_EXCHANGE_RATE in number) return number is
RATE NUMBER;
begin
  /*SRW.REFERENCE(C_EXCHANGE_RATE);*/null;
RATE := C_EXCHANGE_RATE;
  return round(rate,p_precision);
 end;
function cf_eop_exch_rateformula(c_revaluate_yes_no in varchar2, c_exchange_rate in number, c_curr in varchar2) return number is
  rate number;
 begin
  /*srw.reference(c_exchange_rate);*/null;
  /*srw.reference(c_revaluate_yes_no);*/null;
  If nvl(c_revaluate_yes_no, 'N') <> 'Y' then
     return round(c_exchange_rate,p_precision);
  end if;
  /*srw.reference(c_curr);*/null;
  If P_currency = c_curr   then
     return 1;
  else
     /*srw.reference(c_inv_date);*/null;
     /*srw.reference(P_RATE_TYPE);*/null;
     /*srw.reference(P_REVALUATION_DATE);*/null;
     rate := gl_currency_api.get_rate_sql(P_CURRENCY,c_curr,P_REVALUATION_DATE,P_RATE_TYPE);
     return round(rate,p_precision);
  End if;
end;
FUNCTION total (a number, b number) RETURN number is
BEGIN
  return nvl(a,0) + nvl(b,0);
END;
function CF_todayFormula return char is
begin
  return(fnd_date.date_to_chardate(sysdate));
end;
function CF_Revaluation_dateFormula return char is
begin
   return(fnd_date.date_to_chardate(p_revaluation_date));
end;
function CF_due_date_dispFormula return Char is
begin
   return(fnd_date.date_to_chardate(p_due_date_disp));
end;
function c_2(cs_2 in number) return boolean is
BEGIN
   /*srw.reference(cp_1);*/null;
 /*srw.reference(cs_2);*/null;
   if cp_1 = cs_2 then  /*srw.message('1003', 'last');*/null;
 return true; else return false; end if;
END;
procedure set_last_cust(c_balancing IN VARCHAR2 , cs_2 IN NUMBER)is
BEGIN
  /*srw.reference(cs_2);*/null;
  /*srw.reference(c_balancing);*/null;
  /*srw.message ('1007', c_balancing || '   ' || cs_2);*/null;
  If c_balancing = cs_2 then
     /*srw.message ('1002', cs_2);*/null;
     cp_1 := Cs_2;
  end if;
END;
function c_cm1formula(C_PAY_ID in number) return number is
begin
declare
cm	number;
begin
/*srw.reference(C_PAY_ID);*/null;
select 	sum(nvl(app.amount_applied,0))
	into cm
from 	ar_receivable_applications app
where 	app.gl_date <= P_END_DATE
   and	app.status ='APP'
   and  app.application_type = 'CM'
   and  app.payment_schedule_id = C_PAY_ID ;
return(cm);
EXCEPTION
when NO_DATA_FOUND then
return(0);
end;
RETURN NULL; end;
function CF_RATE_TYPE_LOOKUPFormula return Char is
	l_return_var VARCHAR2(80);
begin
	SELECT displayed_field
	INTO   l_return_var
	FROM   ap_lookup_codes
	WHERE  lookup_type = 'APXINREV_RATE_TYPE'
	AND    lookup_code = P_RATE_TYPE_LOOKUP;
	return l_return_var;
exception
	WHEN OTHERS THEN
		return P_RATE_TYPE_LOOKUP;
end;
function CF_USER_DAILY_RATE_TYPEFormula return Char is
l_return_var VARCHAR2(80);
begin
	SELECT user_conversion_type
	INTO   l_return_var
	FROM   gl_daily_conversion_types
	WHERE  conversion_type = p_daily_rate_type;
	return l_return_var;
exception
	WHEN OTHERS THEN
		return P_daily_rate_type;
end;
function CF_TRANS_TO_GLFormula return Char is
return_value  varchar2(240);
begin
	select meaning
	into return_value
	from fnd_lookups
	where lookup_type = 'YES_NO'
	and lookup_code = P_POSTED;
return(return_value);
end;
function CF_CLEARED_ONLYFormula return Char is
 return_value  varchar2(240);
begin
	select meaning
	into return_value
	from fnd_lookups
	where lookup_type = 'YES_NO'
	and lookup_code = P_CLEARED;
	return(return_value);
end;
function P_NAMEValidTrigger return boolean is
begin
  return (TRUE);
end;
--Functions to refer Oracle report placeholders--
 Function CP_TOT_TMP_p return number is
	Begin
	 return CP_TOT_TMP;
	 END;
 Function CP_TMP_p return number is
	Begin
	 return CP_TMP;
	 END;
 Function RP_DATA_FOUND_p return varchar2 is
	Begin
	 return RP_DATA_FOUND;
	 END;
 Function RP_SUB_TITLE_p return varchar2 is
	Begin
	 return RP_SUB_TITLE;
	 END;
 Function REVALUATION_DATE_p return number is
	Begin
	 return REVALUATION_DATE;
	 END;
 Function CP_TEMP_p return number is
	Begin
	 return CP_TEMP;
	 END;
 Function CP_1_p return varchar2 is
	Begin
	 return CP_1;
	 END;
 Function C_DAILY_RATE_LOOKUP_ERROR_p return varchar2 is
	Begin
	 return C_DAILY_RATE_LOOKUP_ERROR;
	 END;
 Function CP_ACC_MESSAGE_p return varchar2 is
	Begin
	 return CP_ACC_MESSAGE;
	 END;
END AR_ARXINREV_XMLP_PKG ;



/
