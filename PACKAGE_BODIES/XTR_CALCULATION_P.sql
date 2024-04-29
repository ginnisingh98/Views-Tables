--------------------------------------------------------
--  DDL for Package Body XTR_CALCULATION_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_CALCULATION_P" AS
/* $Header: xtrprc2b.pls 120.6 2005/06/29 10:37:27 rjose ship $ */

-- Procedure to calculate and return all Option Price variables

PROCEDURE CALC_OPTION_PRICES(time_in_days IN NUMBER,
                             int_rate IN NUMBER,
                             market_price IN NUMBER,
                             strike_price IN NUMBER,
                             vol IN NUMBER,
                             l_delta_call IN OUT NOCOPY NUMBER,
                             l_delta_put IN OUT NOCOPY NUMBER,
                             l_theta_call IN OUT NOCOPY NUMBER,
                             l_theta_put IN OUT NOCOPY NUMBER,
                             l_rho_call IN OUT NOCOPY NUMBER,
                             l_rho_put IN OUT NOCOPY NUMBER,
                             l_gamma IN OUT NOCOPY NUMBER,
                             l_vega IN OUT NOCOPY NUMBER,
                             l_call_price IN OUT NOCOPY NUMBER,
                             l_put_price IN OUT NOCOPY NUMBER) is
--
-- Below are approximations of normal probability and PI (always fixed constant)
 a1 NUMBER :=  0.4361836;
 a2 NUMBER := -0.1201678;
 a3 NUMBER := 0.9372980;
 pi NUMBER  := 3.14159265358979;
--
 r NUMBER := int_rate / 100;
 t NUMBER := time_in_days / 360;
 v NUMBER := vol / 100;
 d1 NUMBER;
 d2 NUMBER;
 n_d1_a NUMBER;
 k1 NUMBER;
 n_d1_temp NUMBER;
 n_d1 NUMBER;
 n_d2_a NUMBER;
 k2 NUMBER;
 n_d2_temp NUMBER;
 n_d2 NUMBER;
--
begin
 d1 := (LN(market_price/strike_price) + (r + POWER(v,2)/2)*t)  / (v * SQRT(t));
 d2 := d1 - v*SQRT(t);
 n_d1_a := EXP(-(POWER(abs(d1),2)) / 2) / SQRT(2 * pi);
 k1 := 1 / (1 + 0.33267 * ABS(d1));
 n_d1_temp := 1 - n_d1_a*(a1*k1+a2*POWER(k1,2)+a3*POWER(k1,3));
 if d1 >= 0 then
  n_d1 := n_d1_temp;
 else
  n_d1 := 1 - n_d1_temp;
 end if;
 n_d2_a := EXP(-(POWER(abs(d2),2)) / 2) / SQRT(2*pi);
 k2 := 1/(1 + 0.33267 * ABS(d2));
 n_d2_temp := 1-n_d2_a*(a1*k2+a2*POWER(k2,2)+a3*POWER(k2,3));
 if d2 >= 0 then
  n_d2 := n_d2_temp;
 else
  n_d2 := 1 - n_d2_temp;
 end if;
---- See Currency Options on the Philadelphia Exchange p272
l_call_price := EXP(-r*t)*(market_price * n_d1-strike_price*n_d2);
l_put_price := EXP(-r*t)*(strike_price*(1-n_d2)-market_price*(1-n_d1));
/* Black-Scholes Formulas
l_call_price := (market_price * n_d1)-(strike_price*EXP(-r*t)*n_d2);
l_put_price := strike_price*EXP(-r*t)*(1-n_d2)-market_price*(1-n_d1);
*/

 l_delta_call := n_d1;
 l_delta_put := n_d1 - 1;
 l_gamma := n_d1_a/(market_price*v*SQRT(t));
 l_vega := market_price*SQRT(t)*n_d1_a;
 l_theta_call := -((market_price*n_d1_a*v)/2/SQRT(t))-(r*strike_price*EXP(-r*t)*n_d2);
 l_theta_put := -(market_price*n_d1_a*v/2/SQRT(t))+(r*strike_price*EXP(-r*t)*(1-n_d2));
 l_rho_call := strike_price*t*EXP(-r*t)*n_d2;
 l_rho_put := -strike_price*t*EXP(-r*t)*(1-n_d2);
end CALC_OPTION_PRICES;


-- Procedure to calculate and return all FX Option Price variables
PROCEDURE CALC_FX_OPTION_PRICES(
                             l_days         IN NUMBER,
                             l_base_int_rate IN NUMBER,
                             l_contra_int_rate IN NUMBER,
                             l_spot_rate     IN NUMBER,
                             l_strike_rate   IN NUMBER,
                             vol IN NUMBER,
                             l_delta_call IN OUT NOCOPY NUMBER,
                             l_delta_put IN OUT NOCOPY NUMBER,
                             l_theta_call IN OUT NOCOPY NUMBER,
                             l_theta_put IN OUT NOCOPY NUMBER,
                             l_rho_call IN OUT NOCOPY NUMBER,
                             l_rho_put IN OUT NOCOPY NUMBER,
                             l_gamma IN OUT NOCOPY NUMBER,
                             l_vega IN OUT NOCOPY NUMBER,
                             l_call_price IN OUT NOCOPY NUMBER,
                             l_put_price IN OUT NOCOPY NUMBER,
                             l_fwd_rate IN OUT NOCOPY NUMBER  ) is
--
-- Below are approximations of normal probability and PI (always fixed constant)
 a1 		NUMBER :=  0.4361836;
 a2 		NUMBER := -0.1201678;
 a3 		NUMBER := 0.9372980;
 pi 		NUMBER  := 3.14159265358979;
--
 r_f 		NUMBER := l_base_int_rate / 100;
 r 		NUMBER := l_contra_int_rate / 100;
 t 		NUMBER := l_days / 360;
 v 		NUMBER := vol / 100;
 d1 		NUMBER;
 d2 		NUMBER;
 n_d1_a		NUMBER;
 k1 		NUMBER;
 n_d1_temp 	NUMBER;
 n_d1 		NUMBER;
 n_d2_a 	NUMBER;
 k2 		NUMBER;
 n_d2_temp 	NUMBER;
 n_d2 		NUMBER;

begin

 d1 := (LN(l_spot_rate/l_strike_rate) + (r-r_f + POWER(v,2)/2)*t)  / (v * SQRT(t));
 d2 := d1 - v*SQRT(t);
 n_d1_a := EXP(-(POWER(abs(d1),2)) / 2) / SQRT(2 * pi);
 k1 := 1 / (1 + 0.33267 * ABS(d1));
 n_d1_temp := 1 - n_d1_a*(a1*k1+a2*POWER(k1,2)+a3*POWER(k1,3));
 if d1 >= 0 then
  n_d1 := n_d1_temp;
 else
  n_d1 := 1 - n_d1_temp;
 end if;
 n_d2_a := EXP(-(POWER(abs(d2),2)) / 2) / SQRT(2*pi);
 k2 := 1/(1 + 0.33267 * ABS(d2));
 n_d2_temp := 1-n_d2_a*(a1*k2+a2*POWER(k2,2)+a3*POWER(k2,3));
 if d2 >= 0 then
  n_d2 := n_d2_temp;
 else
  n_d2 := 1 - n_d2_temp;
 end if;
---- See Currency Options on the Philadelphia Exchange p272
l_fwd_rate :=round(l_spot_rate*EXP((r-r_f)*t),4);
l_call_price := EXP(-r*t)*(l_fwd_rate * n_d1-l_strike_rate*n_d2);
l_put_price := EXP(-r*t)*(l_strike_rate*(1-n_d2)-l_fwd_rate*(1-n_d1));

 l_delta_call := n_d1;
 l_delta_put := n_d1 - 1;
 l_gamma := n_d1_a/(l_spot_rate*v*SQRT(t));
 l_vega := l_spot_rate*SQRT(t)*n_d1_a;
 l_theta_call := -((l_spot_rate*n_d1_a*v)/2/SQRT(t))-(r*l_strike_rate*EXP(-r*t)*n_d2);
 l_theta_put := -(l_spot_rate*n_d1_a*v/2/SQRT(t))+(r*l_strike_rate*EXP(-r*t)*(1-n_d2));
 l_rho_call := l_strike_rate*t*EXP(-r*t)*n_d2;
 l_rho_put := -l_strike_rate*t*EXP(-r*t)*(1-n_d2);
end CALC_FX_OPTION_PRICES;


--
--Bug 3141263
--PROCEDURE to Calculate RTMM Rollover Transactions Details
--The calculations are based from CALC_DT_SETTLEMENTS program unit
--in XTRINRTL.fmb.
--The procedure is being called by CALC_RTM_ROLLOVER.
--
PROCEDURE CALC_RTMM_RT_DETAILS(p_pi_amount_due IN OUT NOCOPY NUMBER,
			p_interest_rate NUMBER,
			p_currency VARCHAR2,
			p_rounding_fac NUMBER,
			p_rounding_type VARCHAR2,
			p_hce_rate NUMBER,
			p_trans_start_date DATE,
			p_trans_maturity_date DATE,
			p_trans_settle_date DATE,
			p_day_count_type VARCHAR2,
			p_year_calc_type VARCHAR2,
			p_deal_maturity_date DATE,
			p_no_of_days IN OUT NOCOPY NUMBER,
			p_accum_interest IN OUT NOCOPY NUMBER,
			p_accum_interest_bf IN OUT NOCOPY NUMBER,
			p_accum_interest_hce IN OUT NOCOPY NUMBER,
			p_accum_interest_bf_hce IN OUT NOCOPY NUMBER,
			p_interest IN OUT NOCOPY NUMBER,
			p_interest_hce IN OUT NOCOPY NUMBER,
			p_adjusted_balance IN OUT NOCOPY NUMBER,
			p_principal_amount_type IN OUT NOCOPY VARCHAR2,
			p_principal_adjust IN OUT NOCOPY VARCHAR2,
			p_principal_adjust_hce IN OUT NOCOPY VARCHAR2,
			p_expected_balance_bf IN OUT NOCOPY NUMBER,
			p_expected_balance_out IN OUT NOCOPY NUMBER,
			p_balance_out IN OUT NOCOPY NUMBER,
			p_balance_out_hce IN OUT NOCOPY NUMBER,
			p_balance_out_bf IN OUT NOCOPY NUMBER,
			p_balance_out_bf_hce IN OUT NOCOPY NUMBER,
			p_accum_int_amount_type IN OUT NOCOPY VARCHAR2,
			p_principal_action IN OUT NOCOPY VARCHAR2) IS
--
 l_exp_int NUMBER;
 v_year_basis NUMBER;
 l_first_trans_flag VARCHAR2(1);
--
BEGIN
  p_PRINCIPAL_ADJUST:=0;
  p_PRINCIPAL_AMOUNT_TYPE:='PRINFLW';
  if nvl(p_PRINCIPAL_ADJUST,0) <> 0 then
    P_PRINCIPAL_ACTION := 'INCRSE';
  end if;
  P_ADJUSTED_BALANCE := nvl(P_BALANCE_OUT_BF,0) +
                          nvl(P_PRINCIPAL_ADJUST,0);
  p_accum_int_amount_type := '0';

  xtr_calc_p.CALC_DAYS_RUN(P_TRANS_START_DATE,
                nvl(P_TRANS_SETTLE_DATE,P_TRANS_MATURITY_DATE),
                p_YEAR_CALC_TYPE,
                P_NO_OF_DAYS,
                v_year_basis,
		null,
                p_DAY_COUNT_TYPE,    --Add Interest Override
                'N');  --Add Interest Override

  --Add Interest Override
  P_INTEREST := xtr_fps2_p.interest_round(nvl(P_ADJUSTED_BALANCE,0) * nvl(P_INTEREST_RATE,0) / 100 * nvl(P_NO_OF_DAYS,0) / v_year_basis,p_rounding_fac,p_ROUNDING_TYPE);
  P_ACCUM_INTEREST := xtr_fps2_p.interest_round(nvl(P_ACCUM_INTEREST_BF,0) +
                          nvl(P_INTEREST,0),p_rounding_fac,p_ROUNDING_TYPE);
  P_EXPECTED_BALANCE_OUT := nvl(P_EXPECTED_BALANCE_BF,0) + nvl(P_PRINCIPAL_ADJUST,0);

  --Add Interest Override
  l_exp_int := xtr_fps2_p.interest_round(nvl(P_EXPECTED_BALANCE_OUT,0) * nvl(P_INTEREST_RATE,0) / 100 * nvl(P_NO_OF_DAYS,0) / v_year_basis,p_rounding_fac,p_ROUNDING_TYPE);
  --
  if nvl(P_PI_AMOUNT_DUE,0) > nvl(l_exp_int,0) then
   P_EXPECTED_BALANCE_OUT :=
     nvl(P_EXPECTED_BALANCE_OUT,0) - nvl(P_PI_AMOUNT_DUE,0) + nvl(l_exp_int,0);
  end if;
  --
  if P_TRANS_MATURITY_DATE = p_deal_MATURITY_DATE then
   P_PI_AMOUNT_DUE := nvl(P_PI_AMOUNT_DUE,0) + nvl(P_EXPECTED_BALANCE_OUT,0);
   P_EXPECTED_BALANCE_OUT := 0;
  else
   if P_EXPECTED_BALANCE_OUT < 0 then
    P_PI_AMOUNT_DUE := nvl(P_PI_AMOUNT_DUE,0) + nvl(P_EXPECTED_BALANCE_OUT,0);
    P_EXPECTED_BALANCE_OUT := 0;
   end if;
  end if;
  P_BALANCE_OUT := nvl(P_ADJUSTED_BALANCE,0); -- nvl(P_PRINCIPAL_DECR,0);

  -- Calculate HCE amounts
  P_BALANCE_OUT_BF_HCE    := round(P_BALANCE_OUT_BF / p_hce_rate,p_rounding_fac);
  P_BALANCE_OUT_HCE       := round(P_BALANCE_OUT / p_hce_rate,p_rounding_fac);
  P_INTEREST_HCE          := round(P_INTEREST / p_hce_rate,p_rounding_fac);
  P_PRINCIPAL_ADJUST_HCE  := round(P_PRINCIPAL_ADJUST / p_hce_rate,p_rounding_fac);
  P_ACCUM_INTEREST_HCE    := round(P_ACCUM_INTEREST / p_hce_rate,p_rounding_fac);
  P_ACCUM_INTEREST_BF_HCE := round(P_ACCUM_INTEREST_BF / p_hce_rate,p_rounding_fac);

END calc_rtmm_rt_details;


-- PROCEDURE to Calculate Retail Term Maturity Date Extensions for a
-- specific Schedule Code
PROCEDURE CALC_RTM_ROLLOVER(
			errbuf                  OUT NOCOPY VARCHAR2,
			retcode                 OUT NOCOPY NUMBER,
    			P_DEAL_SUBTYPE          IN VARCHAR2,
         		P_PRODUCT_TYPE          IN VARCHAR2,
                  	P_PAYMENT_SCHEDULE_CODE IN VARCHAR2)
IS

l_jan VARCHAR2(1);l_feb VARCHAR2(1);l_mar VARCHAR2(1);l_apr VARCHAR2(1);
l_may VARCHAR2(1);l_jun VARCHAR2(1);l_jul VARCHAR2(1);l_aug VARCHAR2(1);
l_sep VARCHAR2(1);l_oct VARCHAR2(1);l_nov VARCHAR2(1);l_dec VARCHAR2(1);
 g_expected_balance_bf	NUMBER	:= 0;
 g_balance_out_bf	NUMBER 	:= 0;
 g_accum_interest_bf	NUMBER	:= 0;
 g_principal_adjust	NUMBER	:= 0;

l_count                 NUMBER;
l_curr_mth              VARCHAR2(3);
l_continue              VARCHAR2(3);
l_new_float_rate        NUMBER;
l_fixed_until           DATE;
l_maturity_date         DATE;
year_basis              NUMBER;
rounding_fac            NUMBER;
l_hce_rate              NUMBER;
l_mths_fwd              NUMBER;
l_calc_type             VARCHAR2(12);
l_int_act               VARCHAR2(7);
F_START_DATE            DATE;
F_EXPECTED_BALANCE_BF   NUMBER;
F_BALANCE_OUT_BF        NUMBER;
F_PRINCIPAL_ADJUST      NUMBER;
F_NO_OF_DAYS            NUMBER;
F_MATURITY_DATE         DATE;
F_EXPECTED_BALANCE_OUT  NUMBER;
F_ADJUSTED_BALANCE      NUMBER;
F_INTEREST_RATE         NUMBER;
F_BALANCE_OUT           number;
F_INTEREST_SETTLED      number;
F_PRINCIPAL_DECR        number;
F_INTEREST              NUMBER;
F_ACCUM_INTEREST        NUMBER;
F_PI_AMOUNT_DUE         NUMBER;
F_BALANCE_OUT_BF_HCE    NUMBER;
F_BALANCE_OUT_HCE       NUMBER;
F_INTEREST_HCE          NUMBER;
F_PRINCIPAL_ADJUST_HCE  NUMBER;
F_ACCUM_INTEREST_HCE    NUMBER;
F_ACCUM_INTEREST_BF_HCE NUMBER;
F_PRINCIPAL_DECR_HCE    NUMBER;
F_ACCUM_INTEREST_BF     number;
--
l_start_date       DATE;
l_cparty         VARCHAR2(7);
l_client         VARCHAR2(7);
l_company        VARCHAR2(7);
l_cparty_acct    VARCHAR2(7);
l_dealer         VARCHAR2(10);
l_product        VARCHAR2(10);
l_portfolio      VARCHAR2(7);
l_settle_acct    VARCHAR2(20);
l_maturity       DATE;
l_start		 DATE;
l_deal_date      DATE;
l_mth            VARCHAR2(10);
--
cursor CHK_CODE is
  select to_number(POST_MONTHS_FORWARD),INTEREST_ACTION,
        JAN_YN,FEB_YN,MAR_YN,APR_YN,MAY_YN,JUN_YN,JUL_YN,AUG_YN,
        SEP_YN,OCT_YN,NOV_YN,DEC_YN,PAYMENT_SCHEDULE_CODE,
	PAYMENT_FREQUENCY,MIN_POSTINGS,POSTING_FREQ,
        NEXT_POSTING_DUE
  from  XTR_PAYMENT_SCHEDULE
  where PAYMENT_SCHEDULE_CODE = P_PAYMENT_SCHEDULE_CODE
  and DEAL_TYPE = 'RTMM'
  and DEAL_SUBTYPE = P_DEAL_SUBTYPE
  and PRODUCT_TYPE = P_PRODUCT_TYPE
  and nvl(NEXT_POSTING_DUE, l_start_date) <= l_start_date;

L_PAYMENT_SCHEDULE_CODE  XTR_PAYMENT_SCHEDULE_V.PAYMENT_SCHEDULE_CODE%TYPE;
L_PAYMENT_FREQUENCY      XTR_PAYMENT_SCHEDULE_V.PAYMENT_FREQUENCY%TYPE;
L_MIN_POSTINGS           XTR_PAYMENT_SCHEDULE_V.MIN_POSTINGS%TYPE;
L_POSTING_FREQ           XTR_PAYMENT_SCHEDULE_V.POSTING_FREQ%TYPE;
L_NEXT_POSTING_DUE       XTR_PAYMENT_SCHEDULE_V.NEXT_POSTING_DUE%TYPE;

cursor DEAL is
  select a.DEAL_NO,a.DEAL_DATE,a.START_DATE,a.MATURITY_DATE,
	a.CPARTY_CODE,a.CLIENT_CODE,a.PRODUCT_TYPE,
        a.PORTFOLIO_CODE,a.MATURITY_ACCOUNT_NO,a.CPARTY_REF,
        a.COMPANY_CODE,a.DEALER_CODE,a.TERM_MY,a.CURRENCY,
        a.FACE_VALUE_AMOUNT,a.PAYMENT_FREQ,a.SETTLE_DATE,SETTLE_ACCOUNT_NO,
        a.LIMIT_CODE,a.PAYMENT_SCHEDULE_CODE ,a.DEAL_TYPE,a.DEAL_SUBTYPE,
	--31441263
        a.rounding_type,a.year_calc_type,a.day_count_type
  from XTR_DEALS_V a
  where  a.deal_type = 'RTMM'
  and a.maturity_date > l_start_date
  and a.PAYMENT_SCHEDULE_CODE = L_PAYMENT_SCHEDULE_CODE
  and a.status_code = 'CURRENT'
  and a.deal_subtype = P_DEAL_SUBTYPE
  and a.product_type = P_PRODUCT_TYPE
  and a.maturity_date > (select max(b.maturity_date)
                           from XTR_ROLLOVER_TRANSACTIONS_V b
                           where b.deal_number = a.deal_no);
l_deal_no  NUMBER;
c_deal DEAL%ROWTYPE;

cursor LAST_TRANS is
  select start_date,maturity_date,expected_balance_out,balance_out,
        accum_interest,interest_rate,pi_amount_due
  from XTR_ROLLOVER_TRANSACTIONS_V
  where deal_number = l_deal_no
  -- and maturity_date >= l_start_date
  order by start_date desc,maturity_date desc,transaction_number desc;

RT LAST_TRANS%ROWTYPE;

cursor RND_YR(p_ccy VARCHAR2) is
  select ROUNDING_FACTOR,YEAR_BASIS,nvl(HCE_RATE,1) HCE_RATE
  from XTR_MASTER_CURRENCIES_V
  where CURRENCY = p_ccy;

l_cparty_account_no varchar2(20);

cursor T_NOS is
  select nvl(max(TRANSACTION_NUMBER), 0) + 1
  from XTR_ROLLOVER_TRANSACTIONS_V
  where DEAL_NUMBER = l_deal_no;

TRANS_NO  number;

--bug 3141263
v_principal_action xtr_rollover_transactions.principal_action%type;
v_ACCUM_INTEREST xtr_rollover_transactions.accum_interest%type;
v_ACCUM_INTEREST_HCE xtr_rollover_transactions.accum_interest_hce%type;
v_ADJUSTED_BALANCE xtr_rollover_transactions.adjusted_balance%type;
v_PRINCIPAL_ADJUST xtr_rollover_transactions.principal_adjust%type;
v_PRINCIPAL_ADJUST_HCE xtr_rollover_transactions.principal_adjust_hce%type;
v_PRINCIPAL_AMOUNT_TYPE xtr_rollover_transactions.principal_amount_type%type;
v_accum_int_amount_type xtr_rollover_transactions.accum_int_amount_type%type;
v_no_of_days NUMBER;

BEGIN

  l_start_date := trunc(sysdate);

  open CHK_CODE;
  fetch CHK_CODE INTO l_mths_fwd,l_int_act,
                      l_jan,l_feb,l_mar,l_apr,l_may,l_jun,l_jul,l_aug,
                      l_sep,l_oct,l_nov,l_dec,L_PAYMENT_SCHEDULE_CODE,
                      L_PAYMENT_FREQUENCY,L_MIN_POSTINGS,
                      L_POSTING_FREQ,L_NEXT_POSTING_DUE;

  WHILE CHK_CODE%FOUND LOOP

    FOR c_deal in DEAL LOOP
      l_deal_no := c_deal.DEAL_NO;

      open LAST_TRANS;
      fetch LAST_TRANS into RT;

      IF LAST_TRANS%FOUND and
	round(months_between(RT.maturity_date, l_start_date),0)
			< nvl(L_MIN_POSTINGS,1) 	THEN
        close LAST_TRANS;

 	if nvl(l_mths_fwd,0) = 0 then
  	  l_mths_fwd := months_between(c_deal.MATURITY_DATE, RT.START_DATE);
 	end if;

 	open RND_YR(c_deal.CURRENCY);
  	fetch RND_YR INTO rounding_fac,year_basis,l_hce_rate;
 	close RND_YR;

   	  --
  	open T_NOS;
   	fetch T_NOS INTO TRANS_NO;
   	close T_NOS;

 	-- Initialise for first row
 	F_START_DATE       := rt.maturity_date;
	l_start		   := rt.maturity_date;
 	F_EXPECTED_BALANCE_BF := rt.expected_balance_out;
 	F_BALANCE_OUT_BF   := rt.balance_out;
 	F_ACCUM_INTEREST_BF :=rt.accum_interest;
 	F_PI_AMOUNT_DUE     :=rt.pi_amount_due;
 	l_continue           := 'YES';
 	-- Calculate each row
 	WHILE (rt.MATURITY_DATE <= c_deal.MATURITY_DATE and
        	months_between(F_START_DATE, l_start_date) <= l_mths_fwd and
		l_continue='YES')
 	LOOP

  	  if c_deal.PAYMENT_FREQ = 'WEEKLY' then
   	    F_MATURITY_DATE := F_START_DATE + 7;
  	  elsif c_deal.PAYMENT_FREQ = 'FORTNIGHTLY' then
   	    F_MATURITY_DATE := F_START_DATE + 14;
   	  elsif c_deal.PAYMENT_FREQ = 'FOUR WEEKLY' then
   	    F_MATURITY_DATE := F_START_DATE + 28;
  	  elsif c_deal.PAYMENT_FREQ = 'MONTHLY' then
   	    F_MATURITY_DATE := ADD_MONTHS(F_START_DATE,1);
  	  elsif c_deal.PAYMENT_FREQ = 'BI MONTHLY' then
   	    F_MATURITY_DATE := ADD_MONTHS(F_START_DATE,2);
  	  elsif c_deal.PAYMENT_FREQ = 'QUARTERLY' then
   	    F_MATURITY_DATE := ADD_MONTHS(F_START_DATE,3);
  	  elsif c_deal.PAYMENT_FREQ = 'SEMI ANNUAL' then
   	    F_MATURITY_DATE := ADD_MONTHS(F_START_DATE,6);
  	  elsif c_deal.PAYMENT_FREQ = 'ANNUAL' then
   	    F_MATURITY_DATE := ADD_MONTHS(F_START_DATE,12);
  	  elsif c_deal.PAYMENT_FREQ = 'AD HOC' then
   	    l_curr_mth := to_char(F_START_DATE,'MM');
   	    l_count := 0;
   	    LOOP
    		EXIT WHEN l_count = 13;
    		l_count := l_count + 1;
    		l_mth := to_char(ADD_MONTHS(F_START_DATE,l_count),'MM');
    		F_MATURITY_DATE := ADD_MONTHS(F_START_DATE,l_count);
    		--
    		if l_jan = 'Y' and l_mth = '01' then
     		EXIT;
    		elsif l_feb = 'Y' and l_mth = '02' then
     		EXIT;
    		elsif l_mar = 'Y' and l_mth = '03' then
     		EXIT;
    		elsif l_apr = 'Y' and l_mth = '04' then
     		EXIT;
    		elsif l_may = 'Y' and l_mth = '05' then
     		EXIT;
    		elsif l_jun = 'Y' and l_mth = '06' then
     		EXIT;
    		elsif l_jul = 'Y' and l_mth = '07' then
     		EXIT;
    		elsif l_aug = 'Y' and l_mth = '08' then
     		EXIT;
    		elsif l_sep = 'Y' and l_mth = '09' then
     		EXIT;
    		elsif l_oct = 'Y' and l_mth = '10' then
     		EXIT;
    		elsif l_nov = 'Y' and l_mth = '11' then
     		EXIT;
    		elsif l_dec = 'Y' and l_mth = '12' then
     		EXIT;
    	  	end if;
   	    END LOOP;
   	    if l_count >= 13 then
    	      null;--- No Months were found for AD HOC repayments
   	    end if;
  	  else
   	    -- No frequency found therfore defualt monthly date
   	    F_MATURITY_DATE := ADD_MONTHS(F_START_DATE,1);
  	  end if;


  	  F_INTEREST_RATE := rt.INTEREST_RATE;

	  l_maturity := F_MATURITY_DATE;
	  -- Adjust for weekends
	  if to_char(l_maturity, 'DY') = to_char(to_date('12/02/2000',
	     'DD/MM/YYYY'), 'DY') then
	    F_MATURITY_DATE := l_maturity + 2;
	  elsif to_char(F_MATURITY_DATE, 'DY') = to_char(to_date('13/02/2000',
	     'DD/MM/YYYY'), 'DY') then
	    F_MATURITY_DATE := l_maturity + 1;
	  end if;

  	  if F_MATURITY_DATE >= c_deal.MATURITY_DATE then
   	    l_continue := 'NO';
   	    F_MATURITY_DATE := c_deal.MATURITY_DATE;
  	  end if;
  	  --

          CALC_RTMM_RT_DETAILS(f_pi_amount_due,
			f_interest_rate,
			c_deal.currency,
			rounding_fac,
			c_deal.rounding_type,
			l_hce_rate,
			f_start_date,
			f_maturity_date,
			null,
			c_deal.day_count_type,
			c_deal.year_calc_type,
			c_deal.maturity_date,
			v_no_of_days,
			v_accum_interest,
			f_accum_interest_bf,
			v_accum_interest_hce,
			f_accum_interest_bf_hce,
			f_interest,
			f_interest_hce,
			v_adjusted_balance,
			v_principal_amount_type,
			v_principal_adjust,
			v_principal_adjust_hce,
			f_expected_balance_bf,
			f_expected_balance_out,
			f_balance_out,
			f_balance_out_hce,
			f_balance_out_bf,
			f_balance_out_bf_hce,
			v_accum_int_amount_type,
			v_principal_action);

          --
   	  insert into XTR_ROLLOVER_TRANSACTIONS
               (DEAL_NUMBER,
		TRANSACTION_NUMBER,
		DEAL_TYPE,
		START_DATE,
		MATURITY_DATE,
         	INTEREST_RATE,
		NO_OF_DAYS,
		PI_AMOUNT_DUE,
		BALANCE_OUT_BF,
		BALANCE_OUT_BF_HCE,
         	BALANCE_OUT,
		BALANCE_OUT_HCE,
		ACCUM_INTEREST_BF,
		ACCUM_INTEREST_BF_HCE,
         	INTEREST,
		INTEREST_HCE,
		EXPECTED_BALANCE_BF,
		EXPECTED_BALANCE_OUT,
         	CREATED_BY,
		CREATED_ON,
		PRINCIPAL_ADJUST,
		STATUS_CODE,
		COMPANY_CODE,
		BAL_OS_ACCOUNT_NO,
		CURRENCY,
		CLIENT_CODE,
		DEAL_SUBTYPE,
		PRODUCT_TYPE,
		CPARTY_CODE,
		DEAL_DATE,
		PORTFOLIO_CODE,
		LIMIT_CODE,
		INTEREST_SETTLED,
		PRINCIPAL_ACTION,
                --bug 3141263
		ACCUM_INT_AMOUNT_TYPE,
		ACCUM_INTEREST,
		ACCUM_INTEREST_HCE,
		ADJUSTED_BALANCE,
		PRINCIPAL_ADJUST_HCE,
		PRINCIPAL_AMOUNT_TYPE,
		RATE_FIXING_DATE)
  	  values(c_deal.DEAL_NO,
		TRANS_NO,
		'RTMM',
		l_start,
        	F_MATURITY_DATE,
		F_INTEREST_RATE,
		v_no_of_days, --bug 3141263 F_MATURITY_DATE - F_START_DATE,
		F_PI_AMOUNT_DUE,
		F_BALANCE_OUT_BF,
		F_BALANCE_OUT_BF_HCE,
        	F_BALANCE_OUT,
		F_BALANCE_OUT_HCE,
		F_ACCUM_INTEREST_BF,
		F_ACCUM_INTEREST_BF_HCE,
        	F_INTEREST,
		F_INTEREST_HCE,
		F_EXPECTED_BALANCE_BF,
		F_EXPECTED_BALANCE_OUT,
		fnd_global.user_id,
        	l_start_date,
		v_principal_adjust,
		'CURRENT',
		c_deal.COMPANY_CODE,
		c_deal.SETTLE_ACCOUNT_NO,
		c_deal.CURRENCY,
		c_deal.CLIENT_CODE,
		c_deal.DEAL_SUBTYPE,
		c_deal.PRODUCT_TYPE,
		c_deal.CPARTY_CODE,
		c_deal.DEAL_DATE,
		c_deal.PORTFOLIO_CODE,
		c_deal.LIMIT_CODE,
		0,
		v_principal_action, --bug 3141263 'INCRSE');
                v_accum_int_amount_type,
		v_ACCUM_INTEREST,
		v_ACCUM_INTEREST_HCE,
		v_ADJUSTED_BALANCE,
		v_PRINCIPAL_ADJUST_HCE,
		v_PRINCIPAL_AMOUNT_TYPE,
		l_Start);

	  -- set F_START_DATE to when the next start date should be w/out
	  --   weekend adjustments
	  F_START_DATE := l_maturity;
	  -- make sure l_start is the actual start date for next rollover trans
	  l_start      := F_MATURITY_DATE;

	  TRANS_NO := TRANS_NO + 1;
          --3141263
          f_accum_interest_bf := v_accum_interest;
          f_expected_balance_bf := f_expected_balance_out;
	END LOOP;

      ELSE
 	close LAST_TRANS;
      END IF;

      --Most of the calculations in RECALC_DT_DETAILS are done in
      --CALC_RTMM_RT_DETAILS. However, RECALC_DT_DETAILS still need to be
      --called since it has the DML's to DDA and RT tables.
      XTR_CALC_P.RECALC_DT_DETAILS(
                     c_deal.DEAL_NO,
                     'N',
                     l_start_date,
                     null,
                     'N',
                     'N',
                     g_expected_balance_bf,
                     g_balance_out_bf,
                     g_accum_interest_bf,
                     g_principal_adjust,
                     null,
                     null,
                     null,
                     null,
                     null );
      commit;

    END LOOP; -- Deal loop

    UPDATE xtr_payment_schedule
    SET next_posting_due	= add_months(l_start_date,nvl(L_POSTING_FREQ,1))
    WHERE deal_type = 'RTMM'
    AND deal_subtype = P_DEAL_SUBTYPE
    AND product_type = P_PRODUCT_TYPE
    AND payment_schedule_code = P_PAYMENT_SCHEDULE_CODE;


    fetch CHK_CODE INTO l_mths_fwd,l_int_act,
                       l_jan,l_feb,l_mar,l_apr,l_may,l_jun,l_jul,l_aug,
                       l_sep,l_oct,l_nov,l_dec,L_PAYMENT_SCHEDULE_CODE,
                       L_PAYMENT_FREQUENCY,L_MIN_POSTINGS,
                       L_POSTING_FREQ,L_NEXT_POSTING_DUE;
  END LOOP; -- Schedule code loop
  close CHK_CODE;
END CALC_RTM_ROLLOVER;


-- PROCEDURE to Calculate Retail Term Maturity Date Extensions
-- All parameters can be null
PROCEDURE EXTEND_RTM_ROLLOVER(
			errbuf                  OUT NOCOPY VARCHAR2,
			retcode                 OUT NOCOPY NUMBER,
    			P_DEAL_SUBTYPE          IN VARCHAR2,
         		P_PRODUCT_TYPE          IN VARCHAR2,
                  	P_PAYMENT_SCHEDULE_CODE IN VARCHAR2)
IS

cursor SCH_CODE is
  select DEAL_SUBTYPE, PRODUCT_TYPE,PAYMENT_SCHEDULE_CODE
  from   XTR_PAYMENT_SCHEDULE
  where  PAYMENT_SCHEDULE_CODE = nvl(P_PAYMENT_SCHEDULE_CODE,PAYMENT_SCHEDULE_CODE)
  and    DEAL_TYPE = 'RTMM'
  and    DEAL_SUBTYPE = nvl(P_DEAL_SUBTYPE,DEAL_SUBTYPE)
  and    PRODUCT_TYPE = nvl(P_PRODUCT_TYPE,PRODUCT_TYPE)
  order by  DEAL_SUBTYPE, PRODUCT_TYPE,PAYMENT_SCHEDULE_CODE;

BEGIN

FOR scode IN  SCH_CODE LOOP

	XTR_CALCULATION_P.CALC_RTM_ROLLOVER(
			errbuf,
			retcode,
    			scode.DEAL_SUBTYPE,
         		scode.PRODUCT_TYPE,
                  	scode.PAYMENT_SCHEDULE_CODE);

END LOOP;
END EXTEND_RTM_ROLLOVER;


END XTR_CALCULATION_P;

/
