--------------------------------------------------------
--  DDL for Package Body XTR_ACCOUNT_BAL_MAINT_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_ACCOUNT_BAL_MAINT_P" as
/* $Header: xtracctb.pls 120.15 2006/07/18 08:18:57 csutaria ship $ */
-----------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE FIND_INT_RATE(l_acct     		IN VARCHAR2,
                        l_balance		IN NUMBER,
                        l_party_code	IN VARCHAR2,
                        l_bank_code 	IN VARCHAR2,
                        l_currency		IN VARCHAR2,
                        l_balance_date	IN DATE,
                        l_int_rate 		IN OUT NOCOPY NUMBER) is
--
 l_basis  VARCHAR2(4);
 l_setoff_bank   VARCHAR2(30);
 l_setoff_party  VARCHAR2(30);
 l_count  NUMBER;
 l_diff   NUMBER;
 l_amount NUMBER;
 l_min    NUMBER;
 l_max    NUMBER;
 l_rate   NUMBER;
 l_wavg   NUMBER;
 --
/*
-- AW 5/28/99  Extract the Bank Code of the Nominal Account Number (l_acct)
-- For example, if l_acct = 'CITI-AAA', then SETOFF_BANK_CODE will return 'AAA'.
--              if l_acct = 'CITI', then SETOFF_BANK_CODE will return 'CITI'.
 cursor SETOFF_BANK_CODE is
 select substr(L_ACCT,instr(L_ACCT,'-')+1)
 from   dual;
*/

 cursor RATE_BASIS is
  select nvl(INTEREST_CALCULATION_BASIS,'STEP')
  from   XTR_BANK_ACCOUNTS
  where  ACCOUNT_NUMBER = l_acct
  and    PARTY_CODE = L_PARTY_CODE
  and    CURRENCY = L_CURRENCY;
 --
 cursor FLAT_RATE is
  select INTEREST_RATE
   from XTR_INTEREST_RATE_RANGES
   where REF_CODE = l_acct
   and PARTY_CODE = l_bank_code
-- and PARTY_CODE = l_setoff_party
   and CURRENCY = L_CURRENCY
   and MIN_AMT < l_balance
   and MAX_AMT >= l_balance
   and EFFECTIVE_FROM_DATE =(select max(EFFECTIVE_FROM_DATE)
                             from XTR_INTEREST_RATE_RANGES
                             where REF_CODE = l_acct
                             and PARTY_CODE = l_bank_code
                           --and PARTY_CODE = l_setoff_party
                             and CURRENCY = L_CURRENCY
                             and MIN_AMT < l_balance
                             and MAX_AMT >= l_balance
                             and EFFECTIVE_FROM_DATE<= L_BALANCE_DATE);
 --
 cursor DR_RANGE is
  select MIN_AMT,MAX_AMT,nvl(INTEREST_RATE,0)
   from XTR_INTEREST_RATE_RANGES
   where REF_CODE = l_acct
   and PARTY_CODE = l_bank_code
-- and PARTY_CODE = l_setoff_party
   and CURRENCY = L_CURRENCY
   and MAX_AMT >= l_amount
   and MIN_AMT <0
   and EFFECTIVE_FROM_DATE =(select max(EFFECTIVE_FROM_DATE)
                              from XTR_INTEREST_RATE_RANGES
                              where REF_CODE = l_acct
                              and PARTY_CODE = l_bank_code
                            --and PARTY_CODE = l_setoff_party
                              and CURRENCY = L_CURRENCY
                              and MAX_AMT >= l_amount
                              and MIN_AMT <0
                              and EFFECTIVE_FROM_DATE<= L_BALANCE_DATE)
   order by MAX_AMT desc;
 --

 cursor CR_RANGE is
  select MIN_AMT,MAX_AMT,nvl(INTEREST_RATE,0)
   from XTR_INTEREST_RATE_RANGES
   where REF_CODE = l_acct
   and PARTY_CODE = l_bank_code
-- and PARTY_CODE = l_setoff_party
   and CURRENCY = L_CURRENCY
   and MIN_AMT <= l_amount
   and MAX_AMT >= 0
   and EFFECTIVE_FROM_DATE =(select max(EFFECTIVE_FROM_DATE)
                              from XTR_INTEREST_RATE_RANGES
                              where REF_CODE = l_acct
                              and PARTY_CODE = l_bank_code
                           -- and PARTY_CODE = l_setoff_party
                              and CURRENCY = L_CURRENCY
                              and MIN_AMT <= l_amount
                              and MAX_AMT >= 0
                              and EFFECTIVE_FROM_DATE<= L_BALANCE_DATE)
   order by MIN_AMT desc;

--
begin
 l_int_rate := 0;
 --
 open RATE_BASIS;
 fetch RATE_BASIS INTO l_basis;
 close RATE_BASIS;

 if nvl(l_basis,'FLAT') = 'STEP' then
   l_amount := l_balance;
   if l_amount <= 0 then
     open DR_RANGE;
     l_wavg := 0;
     l_count := 0;
     LOOP
       fetch DR_RANGE INTO l_min,l_max,l_rate;
       EXIT WHEN DR_RANGE%NOTFOUND;
       if l_max > 0 then
          l_max := 0;
       end if;
       if l_min < l_amount then
          l_min := l_amount;
       end if;
       l_diff := (l_amount - l_max) - (l_amount - l_min);

       l_wavg := l_wavg + (l_diff * l_rate);
       l_count := l_count + 1;
     END LOOP;
     close DR_RANGE;
     if nvl(l_balance,0) <>0 then
        l_int_rate := round(l_wavg /l_balance,5);
     end if;
   else
     open CR_RANGE;
     l_wavg := 0;
     l_count := 0;
     LOOP
       fetch CR_RANGE INTO l_min,l_max,l_rate;
       EXIT WHEN CR_RANGE%NOTFOUND;
       if l_min < 0 then
          l_min := 0;
       end if;
       if l_max > l_amount then
          l_max := l_amount;
       end if;
       l_diff := (l_amount - l_min) - (l_amount - l_max);

       l_wavg := l_wavg + (l_diff * l_rate);
       l_count := l_count + 1;
     END LOOP;
     close CR_RANGE;
     if nvl(l_balance,0) <>0 then
     l_int_rate := round(l_wavg /l_balance,5);
     end if;
   end if;
 else
   open FLAT_RATE;
   fetch FLAT_RATE INTO l_int_rate;
   if FLAT_RATE%NOTFOUND then
     l_int_rate := NULL;
     if l_amount <= 0 then
      open DR_RANGE;
       fetch DR_RANGE INTO l_min,l_max,l_int_rate;
      close DR_RANGE;
     else
      open CR_RANGE;
       fetch CR_RANGE INTO l_min,l_max,l_int_rate;
      close CR_RANGE;
     end if;
   end if;
   close FLAT_RATE;
 end if;
 -- Check that interest rate was found if not set to 0 and disp a warning
 if l_int_rate is NULL then
    l_int_rate := 0;
 end if;
end;
---
------------------------------------------------------------------------------------------------------------------
PROCEDURE UPLOAD_ACCTS is
/*
Procedure to upload bank balances from the BANK_BAL_INTERFACE table (called from form PRO1080)

Note this table needs to be populated by a script in PRO1080 that reads the balances from a flat file
(produced by the MTS system) and then populates the BANK_BAL_INTERFACE table).

It then calls a procedure MAINTAIN_SETOFFS to maintain setoff accounts
*/
--
l_dummy     VARCHAR2(1);
l_comp      VARCHAR2(7);
l_ccy       VARCHAR2(15);
acct_no     VARCHAR2(20);
new_company VARCHAR2(7);
new_date    DATE;
new_bal     NUMBER;
new_bal_hce NUMBER;
v_cross_ref XTR_PARTY_INFO.cross_ref_to_other_party%TYPE;
v_dummy_num NUMBER;
int_rate    NUMBER;
roundfac    NUMBER;
yr_basis    NUMBER;
l_amount_adj NUMBER;
l_amount_cflow NUMBER;
l_no_days   NUMBER;
l_setoff_recalc_date  DATE;
l_prv_date  DATE;
l_prv_rate  NUMBER;
l_prv_bal   NUMBER;
l_int_bf    NUMBER;
l_int_cf    NUMBER;
l_interest  NUMBER;
l_new_rate  NUMBER;
l_hc_rate   NUMBER;
l_yr_type   VARCHAR2(20);
--add
l_limit_code varchar2(7);
l_portfolio_code varchar2(7);
l_bank_code varchar2(7);
--
l_prv_accrual_int NUMBER;
l_accrual_int	  NUMBER;
-- Added for Interest Override
l_rounding_type   VARCHAR2(1);
l_day_count_type  VARCHAR2(1);
l_prv_rounding_type   VARCHAR2(1);
l_prv_day_count_type  VARCHAR2(1);
l_oldest_date     DATE;
l_first_trans_flag varchar2(1);
l_original_amount NUMBER;
l_prv_prv_day_count_type VARCHAR2(1);
l_one_day_float NUMBER;
l_two_day_float NUMBER;
--
cursor RNDING is
 select ROUNDING_FACTOR,YEAR_BASIS,HCE_RATE
  from  XTR_MASTER_CURRENCIES_V
  where CURRENCY = l_ccy;
--
cursor ACCT_DETAILS is
  select PARTY_CODE,CURRENCY,PORTFOLIO_CODE,BANK_CODE,nvl(YEAR_CALC_TYPE,'ACTUAL/ACTUAL') year_calc_type,
         rounding_type, day_count_type
  from XTR_BANK_ACCOUNTS
  where ACCOUNT_NUMBER = acct_no
  and   PARTY_CODE     = new_company;
--
cursor NEW_BALANCE is
 select rtrim(ACCOUNT_NO,' '),trunc(BALANCE_DATE), AMOUNT, AMOUNT_ADJ, AMOUNT_CFLOW, COMPANY_CODE, ONE_DAY_FLOAT, TWO_DAY_FLOAT
  from XTR_BANK_BAL_INTERFACE
  where TRANSFER_SUCCEEDED is null;
--
cursor PREV_DETAILS is
 select a.BALANCE_DATE,a.BALANCE_CFLOW,a.ACCUM_INT_CFWD,a.INTEREST_RATE,a.accrual_interest,
        a.rounding_type, day_count_type
  from XTR_BANK_BALANCES a
  where a.ACCOUNT_NUMBER = acct_no
  and   a.COMPANY_CODE = new_company
  and   a.BALANCE_DATE = (select max(b.BALANCE_DATE)
                           from XTR_BANK_BALANCES b
                           where b.ACCOUNT_NUMBER = acct_no
			   and   b.COMPANY_CODE   = new_company);
--
cursor CHK_EXISTING_DATE is
 select 'x'
  from XTR_BANK_BALANCES
  where ACCOUNT_NUMBER = acct_no
  and   COMPANY_CODE   = new_company
  and   BALANCE_DATE  = new_date;
--
cursor GET_LIM_CODE_BAL is
 select LIMIT_CODE
  from XTR_BANK_BALANCES
  where ACCOUNT_NUMBER = acct_no
  and   COMPANY_CODE   = new_company
  and   BALANCE_DATE   < new_date
  and ((new_bal >= 0 and BALANCE_CFLOW >= 0)
    or (new_bal <= 0 and BALANCE_CFLOW <= 0))
  order by BALANCE_DATE;
--
cursor GET_LIM_CODE_CPARTY is
 select cl.LIMIT_CODE
  from  XTR_COUNTERPARTY_LIMITS cl, XTR_LIMIT_TYPES lt
  where cl.COMPANY_CODE = new_company
  and   cl.CPARTY_CODE  = l_bank_code
  and   cl.LIMIT_TYPE   = lt.LIMIT_TYPE
  and   ((new_bal >= 0 and lt.FX_INVEST_FUND_TYPE = 'I')
      or (new_bal <= 0 and lt.FX_INVEST_FUND_TYPE = 'OD'));
--
cursor CROSS_REF is
   select CROSS_REF_TO_OTHER_PARTY
   from   XTR_PARTIES_V
   where  PARTY_CODE = l_comp;
-- Added for Interest Override
CURSOR oldest_date IS
   SELECT MIN(a.balance_date)
     FROM   xtr_bank_balances a
     WHERE a.account_number = acct_no
     AND a.COMPANY_CODE = new_company;

CURSOR PRV_PRV_DETAILS IS
   SELECT a.day_count_type
     FROM xtr_bank_balances a
     WHERE  a.account_number = acct_no
     AND a.COMPANY_CODE = new_company
     AND a.balance_date = (select max(b.BALANCE_DATE)
                           from XTR_BANK_BALANCES b
                           where b.ACCOUNT_NUMBER = acct_no
			   and   b.COMPANY_CODE   = new_company
			   AND   b.balance_date < l_prv_date);
--
begin
  open NEW_BALANCE;
  fetch NEW_BALANCE INTO acct_no, new_date, new_bal, l_amount_adj, l_amount_cflow, new_company, l_one_day_float, l_two_day_float;
  WHILE NEW_BALANCE%FOUND LOOP
    open PREV_DETAILS;
    fetch PREV_DETAILS INTO l_prv_date,l_prv_bal,l_int_bf,l_prv_rate,l_prv_accrual_int,
                            l_prv_rounding_type, l_prv_day_count_type; -- Added for Interest Override
    if PREV_DETAILS%NOTFOUND then
      l_prv_date := trunc(new_date);
      l_prv_bal  := 0;
      l_prv_rate := 0;
      l_int_bf   := 0;
      l_no_days  := 0;
      l_prv_accrual_int := 0;
      l_prv_rounding_type := NULL;
      l_prv_day_count_type := NULL;
    end if;
    close PREV_DETAILS;
    open ACCT_DETAILS;
    fetch ACCT_DETAILS INTO l_comp,l_ccy,l_portfolio_code,l_bank_code,l_yr_type,
                            l_rounding_type, l_day_count_type;  -- Added for Interest Override
    if ACCT_DETAILS%FOUND then -- Account is loaded in the system
      close ACCT_DETAILS;
      open RNDING;
      fetch RNDING INTO roundfac,yr_basis,l_hc_rate;
      close RNDING;
      open GET_LIM_CODE_BAL;
      fetch GET_LIM_CODE_BAL INTO l_limit_code;
      if GET_LIM_CODE_BAL%NOTFOUND or l_limit_code IS NULL then
        open GET_LIM_CODE_CPARTY;
        fetch GET_LIM_CODE_CPARTY INTO l_limit_code;
        if GET_LIM_CODE_CPARTY%NOTFOUND then
          l_limit_code := Null;
        end if;
	close GET_LIM_CODE_CPARTY;
      end if;
      close GET_LIM_CODE_BAL;
     ---- l_no_days  := (trunc(new_date) - trunc(l_prv_date));
      -- Added for Interest Override
      OPEN oldest_date;
      FETCH oldest_date INTO l_oldest_date;
      close oldest_date;
       --
      if trunc(l_prv_date) <  trunc(new_date) then
	 -- Added for Interest Override
	 OPEN prv_prv_details;
	 FETCH prv_prv_details INTO l_prv_prv_day_count_type;
	 CLOSE prv_prv_details;
	 IF (l_prv_day_count_type ='B' AND l_prv_date = l_oldest_date)
	    OR (l_prv_prv_day_count_type ='F' AND l_prv_day_count_type ='B' ) THEN
	    l_first_trans_flag :='Y';
	  ELSE
	    l_first_trans_flag :=NULL;
	 END IF;
	 --
	 XTR_CALC_P.CALC_DAYS_RUN(trunc(l_prv_date),
				 trunc(new_date),
				 l_yr_type,
				 l_no_days,
				 yr_basis,
				 NULL,
				 l_prv_day_count_type, -- Added for Interest Override
				 l_first_trans_flag);  -- Added for Interest Overrdie

	 -- Added for Interest Override
	 IF l_prv_date <> l_oldest_date AND
	   ((Nvl(l_prv_prv_day_count_type,l_prv_day_count_type) ='L' AND l_prv_day_count_type ='F')
	    OR (Nvl(l_prv_prv_day_count_type,l_prv_day_count_type) ='B' AND l_prv_day_count_type ='F'))
	 THEN
	    l_no_days := l_no_days -1;
	 END IF;
	 --
      else
         l_no_days :=0;
         yr_basis :=365;
      end if;

      -- Changed for Interest Override
--      l_interest := round(l_prv_bal * l_prv_rate / 100 * l_no_days
--                           / yr_basis,roundfac);
      l_interest := xtr_fps2_p.interest_round(l_prv_bal * l_prv_rate / 100 * l_no_days
						     / yr_basis,roundfac,l_prv_rounding_type);
--      l_int_cf := l_int_bf + l_interest;
      l_original_amount := l_int_bf + l_interest;
      l_int_cf := l_original_amount;
      --
      l_accrual_int :=nvl(l_prv_accrual_int,0) + nvl(l_interest,0);

      XTR_ACCOUNT_BAL_MAINT_P.FIND_INT_RATE(acct_no, new_bal,
                          new_company,l_bank_code,l_ccy,new_date,l_new_rate);
      if l_new_rate is null then
        l_new_rate := 0;
      end if;
      open CHK_EXISTING_DATE;
      fetch CHK_EXISTING_DATE INTO l_dummy;
      if CHK_EXISTING_DATE%NOTFOUND then
        close CHK_EXISTING_DATE;
        -- the uploaded date is the latest date then ok to insert
        insert into XTR_BANK_BALANCES
        (company_code,account_number,balance_date,no_of_days,
         statement_balance,balance_adjustment,balance_cflow,
         accum_int_bfwd,interest,interest_rate,interest_settled,
         interest_settled_hce,accum_int_cfwd,limit_code,
	 created_on,created_by,accrual_interest,
	 rounding_type, day_count_type, original_amount, one_day_float, two_day_float) -- Added for Interest Override
         values
        (l_comp,acct_no,new_date,l_no_days,new_bal, nvl(l_amount_adj, 0), nvl(l_amount_cflow, new_bal),
         l_int_bf,l_interest,l_new_rate,0,0,l_int_cf,l_limit_code,
	 sysdate, fnd_global.user_id,l_accrual_int,
	 l_rounding_type, l_day_count_type, l_original_amount, l_one_day_float, l_two_day_float); -- Added for Interest Override

         new_bal_hce := round(new_bal / l_hc_rate,roundfac);
	--
        update XTR_BANK_BAL_INTERFACE
        set   TRANSFER_SUCCEEDED = 'Y'
        where ACCOUNT_NO = acct_no
        and   COMPANY_CODE = new_company
        and   BALANCE_DATE = new_date;
        --
	open CROSS_REF;
        fetch CROSS_REF INTO v_cross_ref;
        close CROSS_REF;
        XTR_ACCOUNT_BAL_MAINT_P.UPDATE_BANK_ACCTS(acct_no,
			        l_ccy,
				l_bank_code,
				l_portfolio_code,
				v_cross_ref,
				l_comp,
				new_date,
				v_dummy_num
				);
      else
        close CHK_EXISTING_DATE;
	--
        update XTR_BANK_BAL_INTERFACE
        set   TRANSFER_SUCCEEDED = 'N'
        where ACCOUNT_NO = acct_no
        and   COMPANY_CODE = new_company
        and   BALANCE_DATE = new_date;
      end if;
    else
      update XTR_BANK_BAL_INTERFACE
      set   TRANSFER_SUCCEEDED = 'N'
      where ACCOUNT_NO = acct_no
      and   COMPANY_CODE = new_company
      and   BALANCE_DATE = new_date;

      close ACCT_DETAILS;
    end if;
    fetch NEW_BALANCE INTO acct_no,new_date,new_bal, l_amount_adj, l_amount_cflow, new_company, l_one_day_float, l_two_day_float;
  END LOOP;
  close NEW_BALANCE;
  commit;
  --
end UPLOAD_ACCTS;
------------------------------------------------------------------------------------------------------------------
PROCEDURE upload_accts_program(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY NUMBER) IS
BEGIN
  XTR_ACCOUNT_BAL_MAINT_P.upload_accts;
END upload_accts_program;
------------------------------------------------------------------------------------------------------------------
PROCEDURE MAINTAIN_SETOFFS(
		p_party_code IN VARCHAR2,
                p_cashpool_id IN CE_CASHPOOLS.CASHPOOL_ID%TYPE,
		p_conc_acct_id IN CE_BANK_ACCOUNTS.BANK_ACCOUNT_ID%TYPE,
                p_calc_date  IN DATE) is
--
-- This procedure calculates the setoff account balances
-- after the latest balances are uploaded from the bank_bal table
-- ie called from the bank_bal.sql script or a Bank Balance is updated in Maintain
-- bank balance form
--
 l_calc_date      DATE;
 roundfac         NUMBER;
 yr_basis         NUMBER;
 l_ccy            VARCHAR(15);
 l_setoff         VARCHAR(5);
 l_setoff_company VARCHAR(7);
 l_bank_code      VARCHAR(7);
 l_no_days        NUMBER;
 l_prv_date       DATE;
 l_this_rate      NUMBER;
 l_prv_rate       NUMBER;
 l_rate           NUMBER;
 l_prv_bal        NUMBER;
 l_prv_adj        NUMBER;
 l_prv_cflw       NUMBER;
 l_int_bf         NUMBER;
 l_int_cf         NUMBER;
 l_int_set        NUMBER;
 l_interest       NUMBER;
 l_this_bal       NUMBER;
 l_this_adj       NUMBER;
 l_this_cflw      NUMBER;
 l_this_accrual_int     NUMBER;
 l_prv_accrual_int	NUMBER;
 l_accrual_int		NUMBER;
 l_yr_type	  VARCHAR2(20);

 l_account_id		CE_BANK_ACCOUNTS.BANK_ACCOUNT_ID%TYPE;

 l_account_number	XTR_BANK_ACCOUNTS.ACCOUNT_NUMBER%TYPE;
 l_party_code		XTR_BANK_ACCOUNTS.PARTY_CODE%TYPE;
 l_notl_bank_code	XTR_BANK_ACCOUNTS.BANK_CODE%TYPE;
 l_notl_currency	XTR_BANK_ACCOUNTS.CURRENCY%TYPE;
 l_notl_year_calc_type	XTR_BANK_ACCOUNTS.YEAR_CALC_TYPE%TYPE;
 l_notl_rounding_type	XTR_BANK_ACCOUNTS.ROUNDING_TYPE%TYPE;
 l_notl_day_count_type	XTR_BANK_ACCOUNTS.DAY_COUNT_TYPE%TYPE;

--

 cursor SEL_SETOFF_ACCT is
	SELECT 	account_id	acct_id
	FROM 	ce_cashpool_sub_accts
	WHERE 	cashpool_id = p_cashpool_id
	AND 	type in ('CONC','ACCT')
	UNION
	SELECT 	nvl(conc_account_id, inv_conc_account_id)  acct_id
	FROM 	ce_cashpool_sub_accts
	WHERE 	cashpool_id = p_cashpool_id
	AND 	type = 'POOL'
	AND 	nvl(conc_account_id, inv_conc_account_id) is not null
	UNION
	SELECT 	fund_conc_account_id acct_id
	FROM	ce_cashpool_sub_accts
	WHERE	cashpool_id = p_cashpool_id
	AND 	type = 'POOL'
	AND 	fund_conc_account_id is not null;

 cursor NOTIONAL_ACCT_NO IS
	SELECT	account_number, party_code, bank_code,
		currency, nvl(year_calc_type, 'ACTUAL/ACTUAL'),
		rounding_type, day_count_type
	FROM	XTR_BANK_ACCOUNTS
	WHERE	cashpool_id = p_cashpool_id;

 cursor RNDING is
  select ROUNDING_FACTOR,YEAR_BASIS
   from XTR_MASTER_CURRENCIES_V
   where CURRENCY = l_notl_currency;
--
-- R12 modified the Cursor. Removed the reference to AP_BANK_ACCOUNT_ID and Dummy_bank_account_id
 cursor	SETOFF_CAL_DATE IS
	SELECT 	distinct balance_date
	FROM	ce_bank_acct_balances                            --4696629
	WHERE   balance_date >= p_calc_date
	AND	bank_account_id IN
		(SELECT account_id	acct_id
		FROM 	ce_cashpool_sub_accts
		WHERE 	cashpool_id = p_cashpool_id
		AND 	type in ('CONC','ACCT')
		UNION
		SELECT 	nvl(conc_account_id, inv_conc_account_id)  acct_id
		FROM 	ce_cashpool_sub_accts
		WHERE 	cashpool_id = p_cashpool_id
		AND 	type = 'POOL'
		AND 	nvl(conc_account_id, inv_conc_account_id) is not null
		UNION
		SELECT 	fund_conc_account_id acct_id
		FROM	ce_cashpool_sub_accts
		WHERE	cashpool_id = p_cashpool_id
		AND 	type = 'POOL'
		AND 	fund_conc_account_id is not null)
	order by balance_date asc;

--
 cursor SETOFF_PREV_DETAILS is
  select a.BALANCE_DATE,
         nvl(sum(a.STATEMENT_BALANCE),0),
         nvl(sum(a.BALANCE_ADJUSTMENT),0),
         nvl(sum(a.BALANCE_CFLOW),0),
         nvl(sum(a.ACCUM_INT_CFWD),0),
         nvl(sum(a.INTEREST_RATE),0),
         nvl(sum(a.ACCRUAL_INTEREST),0)
   from XTR_BANK_BALANCES a
   --where ACCOUNT_NUMBER = l_setoff||'-'||l_bank_code
   where a.ACCOUNT_NUMBER = l_account_number
   and	 a.company_code = l_party_code
   and   a.BALANCE_DATE = (select max(b.BALANCE_DATE)
                            from XTR_BANK_BALANCES b
                            where b.ACCOUNT_NUMBER = l_account_number
			    and	  b.company_code = l_party_code
                            and   b.BALANCE_DATE < l_calc_date)
   group by a.BALANCE_DATE,a.ACCOUNT_NUMBER;
--
 cursor SETOFF_THIS_DETAILS is
  	SELECT	nvl(sum(a.LEDGER_BALANCE),0),
         	nvl(sum(a.VALUE_DATED_BALANCE-a.LEDGER_BALANCE),0),
         	nvl(sum(a.AVAILABLE_BALANCE),0)
   	FROM 	CE_BANK_ACCT_BALANCES a                             --bug 4696629
   	WHERE 	a.bank_account_id IN
		(SELECT account_id	acct_id
		FROM 	ce_cashpool_sub_accts
		WHERE 	cashpool_id = p_cashpool_id
		AND 	type in ('CONC','ACCT')
		UNION
		SELECT 	nvl(conc_account_id, inv_conc_account_id)  acct_id
		FROM 	ce_cashpool_sub_accts
		WHERE 	cashpool_id = p_cashpool_id
		AND 	type = 'POOL'
		AND 	nvl(conc_account_id, inv_conc_account_id) is not null
		UNION
		SELECT 	fund_conc_account_id acct_id
		FROM	ce_cashpool_sub_accts
		WHERE	cashpool_id = p_cashpool_id
		AND 	type = 'POOL'
		AND 	fund_conc_account_id is not null)
   	AND   	a.BALANCE_DATE = (
				SELECT 	max(b.BALANCE_DATE)
                            	FROM  	CE_BANK_ACCT_BALANCES b
                            	WHERE 	b.BANK_ACCOUNT_ID = a.BANK_ACCOUNT_ID
                            	AND   	b.BALANCE_DATE <= l_calc_date);

-- Added for Interest Override
CURSOR oldest_date IS
   SELECT MIN(a.balance_date)
     FROM xtr_bank_balances a
     WHERE a.account_number = l_account_number
     AND   a.company_code = l_party_code;
     /*WHERE a.account_number = l_setoff||'-'||l_bank_code
     AND   a.company_code = l_setoff_company;*/

CURSOR PRV_DETAILS IS
   SELECT a.rounding_type, a.day_count_type
     FROM xtr_bank_balances a
     WHERE  a.account_number = l_account_number
     AND a.COMPANY_CODE = l_party_code
     /*WHERE  a.account_number = l_setoff||'-'||l_bank_code
     AND a.COMPANY_CODE = l_setoff_company*/
     AND a.balance_date = (select max(b.BALANCE_DATE)
                           from XTR_BANK_BALANCES b
                           where b.ACCOUNT_NUMBER = l_account_number
			   and   b.COMPANY_CODE   = l_party_code
                           /*where b.ACCOUNT_NUMBER = l_setoff||'-'||l_bank_code
			   and   b.COMPANY_CODE   = l_setoff_company*/
			   AND   b.balance_date < l_calc_date);

CURSOR PRV_PRV_DETAILS IS
   SELECT a.day_count_type
     FROM xtr_bank_balances a
     WHERE  a.account_number = l_account_number
     AND a.COMPANY_CODE = l_party_code
     /*WHERE  a.account_number = l_setoff||'-'||l_bank_code
     AND a.COMPANY_CODE = l_setoff_company*/
     AND a.balance_date = (select max(b.BALANCE_DATE)
                           from XTR_BANK_BALANCES b
                           where b.ACCOUNT_NUMBER = l_account_number
			   and   b.COMPANY_CODE   = l_party_code
                           /*where b.ACCOUNT_NUMBER = l_setoff||'-'||l_bank_code
			   and   b.COMPANY_CODE   = l_setoff_company*/
			   AND   b.balance_date < l_prv_date);

CURSOR	DEALER_DETAILS IS
	SELECT	dealer_code
	FROM	xtr_dealer_codes
	WHERE	user_id = FND_GLOBAL.USER_ID;


 l_rounding_type VARCHAR2(1);
 l_day_count_type VARCHAR2(1);
 l_prv_rounding_type VARCHAR2(1);
 l_prv_day_count_type VARCHAR2(1);
 l_first_trans_flag VARCHAR2(1);
 l_oldest_date DATE;
 l_original_amount NUMBER;
 l_prv_prv_day_count_type VARCHAR2(1);

 l_created_by	XTR_DEALER_CODES.DEALER_CODE%TYPE;
 l_updated_by	XTR_DEALER_CODES.DEALER_CODE%TYPE;
--
begin
 -- Calculate Setoff details
  OPEN	NOTIONAL_ACCT_NO;
  FETCH	NOTIONAL_ACCT_NO
  INTO	l_account_number, l_party_code, l_notl_bank_code,
	l_notl_currency, l_notl_year_calc_type,
	l_notl_rounding_type, l_notl_day_count_type;
  CLOSE	NOTIONAL_ACCT_NO;

  OPEN	DEALER_DETAILS;
  FETCH	DEALER_DETAILS
  INTO 	l_created_by;
  CLOSE	DEALER_DETAILS;

  IF (l_created_by IS NOT NULL) THEN
	l_updated_by := l_created_by;
  ELSE
	l_updated_by := FND_GLOBAL.USER_ID;
	l_created_by := FND_GLOBAL.USER_ID;
  END IF;


  OPEN SEL_SETOFF_ACCT;
    LOOP
      	FETCH 	SEL_SETOFF_ACCT
	INTO	l_account_id;
       	EXIT WHEN SEL_SETOFF_ACCT%NOTFOUND;

       	delete 	XTR_BANK_BALANCES
       	--where  ACCOUNT_NUMBER = l_setoff||'-'||l_bank_code
       	where  	ACCOUNT_NUMBER = l_account_number
     	and	company_code = l_party_code
       	and    BALANCE_DATE >= p_calc_date
       	and    INTEREST_SETTLED = 0; -- AW 6/15 Bug 906228
                                    -- Do not delete row with Interest Settled.
       open SETOFF_CAL_DATE;
       LOOP
       fetch SETOFF_CAL_DATE INTO l_calc_date;
       EXIT WHEN SETOFF_CAL_DATE%NOTFOUND;
         open SETOFF_PREV_DETAILS;
         fetch SETOFF_PREV_DETAILS INTO l_prv_date,l_prv_bal,l_prv_adj,l_prv_cflw,l_int_bf,l_prv_rate,l_prv_accrual_int;
         if SETOFF_PREV_DETAILS%NOTFOUND then
            l_prv_date := l_calc_date;
            l_prv_bal  := 0;
            l_prv_adj  := 0;
            l_prv_cflw := 0;
            l_prv_rate := 0;
            l_int_bf   := 0;
            l_no_days  := 0;
            l_prv_accrual_int := 0;
         end if;
         open SETOFF_THIS_DETAILS;
         fetch SETOFF_THIS_DETAILS INTO l_this_bal,l_this_adj,l_this_cflw;
         close SETOFF_THIS_DETAILS;

         /* XTR_ACCOUNT_BAL_MAINT_P.FIND_INT_RATE(l_account_number,
                        l_this_bal + l_this_adj,
                          l_party_code,l_notl_bank_code,
			l_notl_currency,l_calc_date,l_rate);  */

          l_rate := CE_INTEREST_CALC.GET_INTEREST_RATE(l_account_id,l_calc_date
                                ,l_this_bal+l_this_adj,l_rate);

         if l_rate is null then
            l_rate := 0;
         end if;
         close SETOFF_PREV_DETAILS;
         open RNDING;
         fetch RNDING INTO roundfac,yr_basis;
         close RNDING;
         if l_prv_rate is null then
            l_prv_rate := 0;
         end if;
         ---- l_no_days  := (trunc(l_calc_date) - trunc(l_prv_date));

	 -- Added for Interest Override
	 OPEN oldest_date;
	 FETCH oldest_date INTO l_oldest_date;
	 CLOSE oldest_date;

	 OPEN prv_details;
	 FETCH prv_details INTO l_prv_rounding_type, l_prv_day_count_type;
	 CLOSE prv_details;
	 --
	 if trunc(l_calc_date) > trunc(l_prv_date) then
	    -- Added for Interest Override
	    OPEN prv_prv_details;
	    FETCH prv_prv_details INTO l_prv_prv_day_count_type;
	    CLOSE prv_prv_details;
	    IF (l_prv_day_count_type ='B' AND l_prv_date = l_oldest_date)
	      OR (l_prv_prv_day_count_type ='F' AND l_prv_day_count_type ='B' ) THEN
	       l_first_trans_flag :='Y';
	     ELSE
	       l_first_trans_flag :=NULL;
	    END IF;
	    --
	    XTR_CALC_P.CALC_DAYS_RUN(trunc(l_prv_date),
                trunc(l_calc_date),
                --l_yr_type,
		l_notl_year_calc_type,
                l_no_days,
                yr_basis,
		NULL,
		nvl(l_prv_day_count_type, -- Added for Interest Override
			l_notl_day_count_type),
		l_first_trans_flag);  -- Added for Interest Overrdie

	    -- Added for Interest Override
	    IF l_prv_date <> l_oldest_date AND
	      ((Nvl(l_prv_prv_day_count_type,l_prv_day_count_type) ='L' AND l_prv_day_count_type ='F')
	       OR (Nvl(l_prv_prv_day_count_type,l_prv_day_count_type) ='B' AND l_prv_day_count_type ='F'))
	      THEN
	       l_no_days := l_no_days -1;
	    END IF;
	    --
         else
            l_no_days :=0;
            yr_basis :=365;
         end if;

	 -- Changed for Interest Override
--         l_interest := round((l_prv_bal+l_prv_adj) * l_prv_rate / 100 * l_no_days
--                           / yr_basis,roundfac);
         l_interest := xtr_fps2_p.interest_round((l_prv_bal+l_prv_adj) * l_prv_rate / 100 * l_no_days
                           / yr_basis,roundfac,l_notl_rounding_type);
                           --/ yr_basis,roundfac,l_prv_rounding_type);
--         l_int_cf := l_int_bf + l_interest;
         l_original_amount := l_int_bf + l_interest;
	 l_int_cf := l_original_amount;

         l_accrual_int :=nvl(l_prv_accrual_int,0)+nvl(l_interest,0);

         l_rate := nvl(l_rate,0);

         -- AW 6/15 Bug 906228
         -- Update row with interest settled, if not found then insert a new row.
         update XTR_BANK_BALANCES
         set    NO_OF_DAYS         = l_no_days,
                STATEMENT_BALANCE  = l_this_bal,
                BALANCE_ADJUSTMENT = l_this_adj,
                BALANCE_CFLOW      = l_this_cflw,
                ACCUM_INT_BFWD     = l_int_bf,
                INTEREST           = l_interest,
                INTEREST_RATE      = l_rate,
                ACCUM_INT_CFWD     = l_int_cf - INTEREST_SETTLED,
	        ACCRUAL_INTEREST   = l_accrual_int,
	        original_amount    = l_original_amount, -- Added for Interest Override
	        rounding_type      = l_notl_rounding_type,
                day_count_type     = l_notl_day_count_type  -- Bug 5393539
         where  COMPANY_CODE       = l_party_code
         and    ACCOUNT_NUMBER     = l_account_number
         /*where  COMPANY_CODE       = l_setoff_company
         and    ACCOUNT_NUMBER     = l_setoff||'-'||l_bank_code*/
         and    BALANCE_DATE       = l_calc_date;
         if SQL%NOTFOUND then
           -- Existing code
           insert into XTR_BANK_BALANCES
              (COMPANY_CODE,ACCOUNT_NUMBER,BALANCE_DATE,NO_OF_DAYS,
               STATEMENT_BALANCE,BALANCE_ADJUSTMENT,BALANCE_CFLOW,
               ACCUM_INT_BFWD,INTEREST,INTEREST_RATE,INTEREST_SETTLED,
               INTEREST_SETTLED_HCE,ACCUM_INT_CFWD,created_on, created_by,accrual_interest,
	       original_amount, rounding_type, day_count_type)  -- Added for Interest Override
           values
              	(l_party_code,l_account_number,
               	l_calc_date,l_no_days,l_this_bal,l_this_adj,
               	l_this_cflw,l_int_bf,
               	l_interest,l_rate,0,0,l_int_cf, sysdate,
		l_created_by,l_accrual_int,
	       	l_original_amount, l_notl_rounding_type,l_notl_day_count_type); -- Bug 5393539

         end if;
       END LOOP;
       -- AW  6/1/99
       update XTR_BANK_ACCOUNTS
       set    INTEREST_RATE = l_rate,
              UPDATED_ON = sysdate,
              UPDATED_BY = l_updated_by
       --where  ACCOUNT_NUMBER = l_setoff||'-'||l_bank_code
       where  ACCOUNT_NUMBER = l_account_number
       and    party_code = l_party_code
       and    CURRENCY = l_notl_currency;
       --
       close SETOFF_CAL_DATE;
   END LOOP;
   close SEL_SETOFF_ACCT;
   commit;
end MAINTAIN_SETOFFS;
------------------------------------------------------------------------------------------------------------------
PROCEDURE UPDATE_BANK_ACCTS(p_account_number IN VARCHAR2,
                            p_currency       IN VARCHAR2,
                            p_bank_code      IN VARCHAR2,
                            p_portfolio      IN VARCHAR2,
                            p_pty_cross_ref  IN VARCHAR2,
                            p_party_code     IN VARCHAR2,
                            p_recalc_date    IN DATE,
                            p_accum_int_cfwd IN OUT NOCOPY NUMBER,
                            p_overwrite      IN VARCHAR2 DEFAULT NULL
			    ) is
--
-- Procedure to Update the Bank Balance in the Bank Account
-- and DDA tables with the latest balances. This is called from 1080
-- after

--
l_calc_date   DATE;
roundfac      NUMBER;
yr_basis      NUMBER;
l_no_days     NUMBER;
l_prv_date    DATE;
l_this_rate   NUMBER;
l_prv_rate    NUMBER;
l_rate        NUMBER;
l_prv_bal     NUMBER;
l_prv_adj     NUMBER;
l_prv_cflw    NUMBER;
l_int_bf      NUMBER;
l_int_cf      NUMBER;
l_int_set     NUMBER;
l_interest    NUMBER;
l_this_bal    NUMBER;
l_stmt_bal    NUMBER;
l_bal_adj     NUMBER;
l_bal_cflw    NUMBER;
l_hce_rate    NUMBER;
l_open_bal    NUMBER;
l_limit_code  VARCHAR2(7);
l_yr_type     VARCHAR2(15);
l_accrual_int		NUMBER;
l_prv_accrual_int 	NUMBER;
--
cursor DEAL_NUM is
  select DEAL_NUMBER
    from XTR_DEAL_DATE_AMOUNTS_V
   where DEAL_TYPE    = 'CA'
     and AMOUNT_TYPE  = 'BAL'
     and ACCOUNT_NO   = p_account_number
     and CURRENCY     = p_currency
     and COMPANY_CODE = nvl(p_pty_cross_ref,p_party_code);
--
 cursor EXP_NUM is
  select XTR_DEALS_S.NEXTVAL
   from DUAL;
--
 l_deal_nos  NUMBER;

cursor RNDING is
 select HCE_RATE,ROUNDING_FACTOR
  from  XTR_MASTER_CURRENCIES_V
  where CURRENCY = P_CURRENCY;
--
cursor CAL_DATE is
 select BALANCE_DATE,
        INTEREST_RATE,
        NVL(STATEMENT_BALANCE,0)+NVL(BALANCE_ADJUSTMENT,0) BAL,
        INTEREST_SETTLED,
       nvl( BALANCE_CFLOW,0), -- Added nvl for R12 project Bug 4546183
        LIMIT_CODE
  from  XTR_BANK_BALANCES
  where BALANCE_DATE >= P_RECALC_DATE
  and   ACCOUNT_NUMBER = P_ACCOUNT_NUMBER
  and   COMPANY_CODE = P_PARTY_CODE
 order by BALANCE_DATE asc;

cursor get_yr_type is
  select nvl(YEAR_CALC_TYPE,'ACTUAL/ACTUAL'),
         Nvl(rounding_type,'R'),Nvl(day_count_type,'L'), ce_bank_account_id  -- Added for Interest Override
    from XTR_bank_accounts
   where ACCOUNT_NUMBER = P_ACCOUNT_NUMBER
     and PARTY_CODE = P_PARTY_CODE;
-- Modified the cursor R12 Removed the reference to ap_bank_account_id, dummy_bank_account_id
cursor chk_setoff is
  select SETOFF_ACCOUNT_YN, ce_bank_account_id
    from XTR_bank_accounts
   where ACCOUNT_NUMBER = P_ACCOUNT_NUMBER
     and PARTY_CODE = P_PARTY_CODE;
 l_setoff_acct_yn varchar2(1);
 l_bank_account_id	CE_BANK_ACCOUNTS.BANK_ACCOUNT_ID%TYPE;
--
cursor PREV_DETAILS is
   select a.BALANCE_DATE,NVL(a.STATEMENT_BALANCE,0)+NVL(a.BALANCE_ADJUSTMENT,0) INT_BAL,a.ACCUM_INT_CFWD,a.INTEREST_RATE,A.ACCRUAL_INTEREST,
          a.rounding_type, a.day_count_type -- Added for Interest Override
  from  XTR_BANK_BALANCES a
  where a.ACCOUNT_NUMBER = P_ACCOUNT_NUMBER
  and   COMPANY_CODE = P_PARTY_CODE
  and   a.BALANCE_DATE = (select max(b.BALANCE_DATE)
                           from XTR_BANK_BALANCES b
                           where b.ACCOUNT_NUMBER = P_ACCOUNT_NUMBER
                           and   b.COMPANY_CODE = P_PARTY_CODE
                           and   b.BALANCE_DATE < l_calc_date);
-- Added for Interest Override
CURSOR oldest_date IS
   SELECT MIN(a.balance_date)
     FROM xtr_bank_balances a
     WHERE a.account_number = p_account_number
     AND   a.company_code = p_party_code;

CURSOR PRV_PRV_DETAILS IS
   SELECT a.day_count_type
     FROM xtr_bank_balances a
     WHERE  a.account_number = p_account_number
     AND a.COMPANY_CODE = p_party_code
     AND a.balance_date = (select max(b.BALANCE_DATE)
                           from XTR_BANK_BALANCES b
                           where b.ACCOUNT_NUMBER = p_account_number
			   and   b.COMPANY_CODE   = p_party_code
			   AND   b.balance_date < l_prv_date);
CURSOR  CASHPOOL_DETAILS IS
	SELECT	pool.cashpool_id, pool.conc_account_id
	FROM 	ce_cashpools pool, ce_cashpool_sub_accts subs
	WHERE	pool.type = 'NOTIONAL'
	AND 	pool.cashpool_id = subs.cashpool_id
	AND	subs.type in ('CONC','ACCT')
	AND	subs.account_id = l_bank_account_id
	UNION
	SELECT	pool.cashpool_id, pool.conc_account_id
	FROM 	ce_cashpools pool, ce_cashpool_sub_accts subs
	WHERE 	pool.type = 'NOTIONAL'
	AND 	subs.type = 'POOL'
	AND	pool.cashpool_id = subs.cashpool_id
	AND 	(subs.conc_account_id = l_bank_account_id OR
     		subs.inv_conc_account_id = l_bank_account_id OR
     		subs.fund_conc_account_id = l_bank_account_id);

CURSOR	DEALER_DETAILS IS
	SELECT	dealer_code
	FROM	xtr_dealer_codes
	WHERE	user_id = FND_GLOBAL.USER_ID;

 l_rounding_type VARCHAR2(1);
 l_day_count_type VARCHAR2(1);
 l_ce_bank_account_id XTR_BANK_ACCOUNTS.CE_BANK_ACCOUNT_ID%TYPE;
 l_prv_rounding_type VARCHAR2(1);
 l_prv_day_count_type VARCHAR2(1);
 l_first_trans_flag VARCHAR2(1);
 l_oldest_date DATE;
 l_original_amount NUMBER;
 l_prv_prv_day_count_type VARCHAR2(1);
 l_cashpool_id	CE_CASHPOOLS.CASHPOOL_ID%TYPE;
 l_conc_acct_id	CE_BANK_ACCOUNTS.BANK_ACCOUNT_ID%TYPE;
 l_created_by	XTR_DEALER_CODES.DEALER_CODE%TYPE;
 l_updated_by	XTR_DEALER_CODES.DEALER_CODE%TYPE;
--
begin

  OPEN	DEALER_DETAILS;
  FETCH	DEALER_DETAILS
  INTO 	l_created_by;
  CLOSE	DEALER_DETAILS;

  IF (l_created_by IS NOT NULL) THEN
	l_updated_by := l_created_by;
  ELSE
	l_updated_by := FND_GLOBAL.USER_ID;
	l_created_by := FND_GLOBAL.USER_ID;
  END IF;

 l_calc_date :=null;
 --
 open get_yr_type;
 fetch get_yr_type into l_yr_type,
                        l_rounding_type, l_day_count_type,l_ce_bank_account_id;  -- Added for Interest Override Modified for R12 4425540
 close get_yr_type;
 --
 open CAL_DATE;
 fetch CAL_DATE INTO l_calc_date,l_this_rate,l_this_bal,l_int_set,l_open_bal,l_limit_code;
 WHILE CAL_DATE%FOUND LOOP
   open PREV_DETAILS;
   fetch PREV_DETAILS INTO l_prv_date,l_prv_bal,l_int_bf,l_prv_rate,l_prv_accrual_int,
                           l_prv_rounding_type, l_prv_day_count_type;
   if PREV_DETAILS%NOTFOUND then
      l_prv_date := l_calc_date;
      l_prv_bal  := 0;
      l_prv_rate := 0;
      l_int_bf   := 0;
      l_no_days  := 0;
      l_prv_accrual_int :=0;
      l_prv_rounding_type := NULL;
      l_prv_day_count_type := NULL;
   end if;
   close PREV_DETAILS;
   if nvl(l_this_rate,0) = 0 then
      l_this_rate := 0;
/* Modified for R12 No uptake of Bank Balances Bug 4425540
      XTR_ACCOUNT_BAL_MAINT_P.FIND_INT_RATE(P_ACCOUNT_NUMBER,
                                         l_this_bal,
                                         p_party_code,
                                         p_bank_code,
                                         p_currency,
                                         l_calc_date,
                                         l_this_rate);
*/

      l_this_rate := CE_INTEREST_CALC.GET_INTEREST_RATE(l_ce_bank_account_id,l_calc_date
                                ,l_this_bal,l_this_rate);
      l_this_rate := nvl(l_this_rate,0);
   end if;
   open RNDING;
   fetch RNDING INTO l_hce_rate,roundfac;
   close RNDING;
   roundfac :=nvl(roundfac,2);
   -- l_no_days  := (trunc(l_calc_date) - trunc(l_prv_date));
   -- Added for Interest Override
   OPEN oldest_date;
   FETCH oldest_date INTO l_oldest_date;
   CLOSE oldest_date;
   --
   if trunc(l_calc_date) > trunc(l_prv_date) THEN
      -- Added for Interest Override
      OPEN prv_prv_details;
      FETCH prv_prv_details INTO l_prv_prv_day_count_type;
      CLOSE prv_prv_details;
      IF (l_prv_day_count_type ='B' AND l_prv_date = l_oldest_date)
	OR (l_prv_prv_day_count_type ='F' AND l_prv_day_count_type ='B' ) THEN
	 l_first_trans_flag :='Y';
       ELSE
	 l_first_trans_flag :=NULL;
      END IF;
      --
      XTR_CALC_P.CALC_DAYS_RUN(trunc(l_prv_date),
			       trunc(l_calc_date),
			       l_yr_type,
			       l_no_days,
			       yr_basis,
			       NULL,
			       l_prv_day_count_type,  -- Added for Interest Override
			       l_first_trans_flag -- Added for Interest Override
			       );
      -- Added for Interest Override
      IF l_prv_date <> l_oldest_date AND
	((Nvl(l_prv_prv_day_count_type,l_prv_day_count_type) ='L' AND l_prv_day_count_type ='F')
	 OR (Nvl(l_prv_prv_day_count_type,l_prv_day_count_type) ='B' AND l_prv_day_count_type ='F'))
      THEN
	 l_no_days := l_no_days -1;
      END IF;
      --
   else
     l_no_days :=0;
     yr_basis :=365;
   end if;
   -- Changed for Interest Override
--   l_interest := round(l_prv_bal * l_prv_rate / 100 * l_no_days
--                     / yr_basis,roundfac);
/* Commented the below line in R12 Bug 4593594
   l_interest := xtr_fps2_p.interest_round(l_prv_bal * l_prv_rate / 100 * l_no_days
                     / yr_basis,roundfac,l_prv_rounding_type);
*/
-- Added the Below line Bug 4593594 Calling Ce's API to calculate the Interest
  CE_INTEREST_CALC.int_cal_xtr( trunc(l_prv_date),
            trunc(l_calc_date),
            l_ce_bank_account_id,
            l_prv_rate,
            'TREASURY',
            l_interest );

--   l_int_cf := l_int_bf + l_interest - l_int_set;
   l_original_amount := nvl(l_int_bf,0) + nvl(l_interest,0) - nvl(l_int_set,0);
   l_int_cf := l_original_amount;
   --
   l_accrual_int :=nvl(l_prv_accrual_int,0) + nvl(l_interest,0);

   update XTR_BANK_BALANCES
      set NO_OF_DAYS           = l_no_days
        ,ACCUM_INT_BFWD       = l_int_bf
        ,INTEREST             = nvl(l_interest,0)
        ,ACCUM_INT_CFWD       = l_int_cf
        ,INTEREST_RATE        = l_this_rate
        ,ACCRUAL_INTEREST     = l_accrual_int
        ,original_amount      = decode(nvl(p_overwrite, 'N'), 'Y',
			        original_amount, l_original_amount)
        ,rounding_type        = l_rounding_type
        ,day_count_type       = l_day_count_type
   where ACCOUNT_NUMBER = P_ACCOUNT_NUMBER
   and   COMPANY_CODE = P_PARTY_CODE
   and   BALANCE_DATE = l_calc_date;

   fetch CAL_DATE INTO l_calc_date,l_this_rate,l_this_bal,l_int_set,l_open_bal,l_limit_code;
 END LOOP;
 close CAL_DATE;
--
 l_setoff_acct_yn :=null;
 open  chk_setoff ;
 fetch  chk_setoff into l_setoff_acct_yn, l_bank_account_id;
 close  chk_setoff;
 if l_calc_date is not null and nvl(l_setoff_acct_yn,'N')<>'Y' then
    update XTR_BANK_ACCOUNTS
     set OPENING_BALANCE = l_open_bal,
         OPENING_BAL_HCE = round(l_open_bal/l_hce_rate,roundfac),
         STATEMENT_DATE  = l_calc_date,
         INTEREST_RATE = l_this_rate,
         UPDATED_ON = sysdate,
         UPDATED_BY = l_updated_by
     where ACCOUNT_NUMBER = p_account_Number
     and CURRENCY = p_currency
     and PARTY_CODE = p_party_code;
    --
    --p_statement_date := l_calc_date;
    p_accum_int_cfwd := l_int_cf;
    --
    open DEAL_NUM;
    fetch DEAL_NUM into l_deal_nos;
    if DEAL_NUM%FOUND then
       update XTR_DEAL_DATE_AMOUNTS
       set AMOUNT =abs(l_open_bal),
           CASHFLOW_AMOUNT  = 0,
           HCE_AMOUNT  = abs(nvl(round(l_open_bal/l_hce_rate,roundfac),0)),
           AMOUNT_DATE = l_calc_date,
           CPARTY_CODE = p_bank_code,
           LIMIT_CODE  = nvl(l_limit_code,'NILL'), -- AW Bug 968983 8/25/99
           PORTFOLIO_CODE = p_portfolio,
           DEAL_SUBTYPE = decode(sign(nvl(l_open_bal,0)),-1,'FUND','INVEST'),
           TRANSACTION_RATE=l_this_rate
        where DEAL_TYPE  = 'CA'
        and DEAL_NUMBER  = l_deal_nos
        and AMOUNT_TYPE  = 'BAL'
        and ACCOUNT_NO   = p_account_number
        and CURRENCY     = p_currency
        and COMPANY_CODE = nvl(p_pty_cross_ref,p_party_code) ;
     --
    else
       open EXP_NUM;
       fetch EXP_NUM into l_deal_nos;
       close EXP_NUM;
       --
       insert into XTR_DEAL_DATE_AMOUNTS
         (DEAL_TYPE,AMOUNT_TYPE,DATE_TYPE,DEAL_NUMBER,TRANSACTION_NUMBER,
          TRANSACTION_DATE,CURRENCY,AMOUNT,HCE_AMOUNT,AMOUNT_DATE,
          COMPANY_CODE,ACCOUNT_NO,ACTION_CODE,CASHFLOW_AMOUNT,
          DEAL_SUBTYPE,PRODUCT_TYPE,LIMIT_CODE,PORTFOLIO_CODE,STATUS_CODE,
          CPARTY_CODE,TRANSACTION_RATE)
       values
         ('CA','BAL','BALANCE',l_deal_nos,1,l_calc_date,p_currency,
          abs(l_open_bal),abs(nvl(round(l_open_bal/l_hce_rate,roundfac),0)),l_calc_date,nvl(p_pty_cross_ref,p_party_code),
          p_account_number,NULL,0,
          decode(sign(nvl(l_open_bal,0)),-1,'FUND','INVEST'),'NOT APPLIC',
          nvl(l_limit_code,'NILL'), -- AW Bug 968983 8/25/99
          p_portfolio,'CURRENT',p_bank_code,l_this_rate);
    end if;
    close DEAL_NUM;
 elsif l_calc_date is null and nvl(l_setoff_acct_yn,'N')<>'Y' then
    -- AW 6/16 Update bank accounts if all balances rows are deleted.
    update XTR_BANK_ACCOUNTS
       set OPENING_BALANCE = 0,
           OPENING_BAL_HCE = 0,
           STATEMENT_DATE  = null,
           INTEREST_RATE = null,
           UPDATED_ON = sysdate,
           UPDATED_BY = l_updated_by
     where ACCOUNT_NUMBER = p_account_Number
       and CURRENCY = p_currency
       and PARTY_CODE = p_party_code;
     --
     --p_statement_date := l_calc_date;
     p_accum_int_cfwd := 0;
     --
     open DEAL_NUM;
     fetch DEAL_NUM into l_deal_nos;
     if DEAL_NUM%FOUND then
      update XTR_DEAL_DATE_AMOUNTS
       set AMOUNT = 0,
           CASHFLOW_AMOUNT  = 0,
           HCE_AMOUNT  = 0
        where DEAL_TYPE  = 'CA'
        and DEAL_NUMBER  = l_deal_nos
        and AMOUNT_TYPE  = 'BAL'
        and ACCOUNT_NO   = p_account_number
        and CURRENCY     = p_currency
        and COMPANY_CODE = nvl(p_pty_cross_ref,p_party_code) ;
     end if;
     close DEAL_NUM;
  --
 end if;
 --
    OPEN	CASHPOOL_DETAILS;
    FETCH	CASHPOOL_DETAILS
    INTO	l_cashpool_id, l_conc_acct_id;
    CLOSE	CASHPOOL_DETAILS;

    IF (l_cashpool_id IS NOT NULL) THEN
    	XTR_ACCOUNT_BAL_MAINT_P.MAINTAIN_SETOFFS(
			p_party_code,l_cashpool_id,
			l_conc_acct_id,p_recalc_date);
    END IF;
--
end UPDATE_BANK_ACCTS;


end XTR_ACCOUNT_BAL_MAINT_P;

/
