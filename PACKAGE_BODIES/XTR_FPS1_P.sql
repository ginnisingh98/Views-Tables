--------------------------------------------------------
--  DDL for Package Body XTR_FPS1_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_FPS1_P" as
/* $Header: xtrfps1b.pls 120.3 2005/06/29 07:26:44 badiredd ship $ */
----------------------------------------------------------------------------------------------------------------
PROCEDURE ADVICE_LETTERS (l_deal_type  IN VARCHAR2,
					    l_product    IN VARCHAR2,
					    l_cparty     IN VARCHAR2,
					    l_client     IN VARCHAR2,
					    l_cparty_adv IN OUT NOCOPY VARCHAR2,
					    l_client_adv IN OUT NOCOPY VARCHAR2) as
      --
       l_cparty_prod CHAR(1);
       l_client_prod CHAR(1);
      --
       cursor PROD_LEVEL_ADV is
	select nvl(a.CPARTY_ADVICE,'Y'),nvl(a.CLIENT_ADVICE,'Y')
	 from XTR_PRODUCT_TYPES a
	 where a.DEAL_TYPE = l_deal_type
	 and   a.PRODUCT_TYPE = l_product;
      --
       cursor CPARTY_LEVEL_ADV is
	select a.CLIENT_ADVICE
	 from XTR_PARTY_INFO_V a
	 where a.PARTY_CODE = l_cparty;
      --
       cursor CLIENT_LEVEL_ADV is
	select a.CLIENT_ADVICE
	 from XTR_PARTY_INFO_V a
	 where a.PARTY_CODE = l_client;
      --
      begin
       open PROD_LEVEL_ADV;
	fetch PROD_LEVEL_ADV INTO l_cparty_prod,l_client_prod;
       close PROD_LEVEL_ADV;
       --
       if l_cparty is NOT NULL then
	open CPARTY_LEVEL_ADV;
	 fetch CPARTY_LEVEL_ADV INTO l_cparty_adv;
	 if l_cparty_adv is NULL then
	  l_cparty_adv := l_cparty_prod;
	 end if;
	close CPARTY_LEVEL_ADV;
       else
	l_cparty_adv := 'N';
       end if;
       --
       if l_client is NOT NULL then
	open CLIENT_LEVEL_ADV;
	 fetch CLIENT_LEVEL_ADV INTO l_client_adv;
	 if l_client_adv is NULL then
	  l_client_adv := l_client_prod;
	 end if;
	close CLIENT_LEVEL_ADV;
       else
	l_client_adv := 'N';
       end if;
end ADVICE_LETTERS ;
----------------------------------------------------------------------------------------------------------------
PROCEDURE CAL_BOND_PRICE (num_full_cpn_remain      IN NUMBER,
				 annual_yield             IN NUMBER,
				 days_settle_to_nxt_cpn   IN NUMBER,
				 days_last_cpn_to_nxt_cpn IN NUMBER,
				 annual_cpn               IN NUMBER,
				 l_vol_chg_ann_yield      IN NUMBER,
				 cum_price                IN OUT NOCOPY NUMBER,
				 ex_price                 IN OUT NOCOPY NUMBER,
				 vol_price                IN OUT NOCOPY NUMBER) as
--
 controlnum NUMBER;
--
begin
	controlnum := 0;
	if num_full_cpn_remain > 0 then
	    ex_price :=
		    (((1 / (power(1 + annual_yield,num_full_cpn_remain))) +
		     (annual_cpn * ((1 - (1 / power(1 + annual_yield,num_full_cpn_remain))) / annual_yield))) /
		     power(1 + annual_yield,(days_settle_to_nxt_cpn / days_last_cpn_to_nxt_cpn)) * 100);
	else
	    ex_price :=
		    (100 / (1 + ((days_settle_to_nxt_cpn * annual_yield) /
					days_last_cpn_to_nxt_cpn)));
	end if;
	controlnum := 1;
	if num_full_cpn_remain > 0 then
	    cum_price :=
		    (((1 / power(1 + annual_yield,num_full_cpn_remain)) +
		     (annual_cpn * (controlnum + ((1 - (1/(power(1 +
		     annual_yield,num_full_cpn_remain)))) / annual_yield)))) /
		      power(1 + annual_yield,days_settle_to_nxt_cpn /
		      days_last_cpn_to_nxt_cpn)) * 100;
	else
	    cum_price :=
		    (100 + (100 * annual_cpn))/(1 + days_settle_to_nxt_cpn *
		     annual_yield / days_last_cpn_to_nxt_cpn);
	end if;
	if num_full_cpn_remain > 0 then
	    vol_price :=
		    (((1 / power(1 + l_vol_chg_ann_yield,num_full_cpn_remain))
		     + (annual_cpn * (controlnum + ((1 - (1 / (power(1 +
		     l_vol_chg_ann_yield,num_full_cpn_remain)))) /
		     l_vol_chg_ann_yield)))) / power(1 + l_vol_chg_ann_yield,
		     days_settle_to_nxt_cpn / days_last_cpn_to_nxt_cpn))* 100;
	else
	   vol_price :=
		    (100 + (100 * annual_cpn))/(1 + days_settle_to_nxt_cpn *
		     l_vol_chg_ann_yield / days_last_cpn_to_nxt_cpn);
	end if;
end CAL_BOND_PRICE;
----------------------------------------------------------------------------------------------------------------
PROCEDURE CALC_OPTION_PRICE (l_expiry      IN DATE,
			     l_volatility  IN NUMBER,
			     l_counter_ccy IN CHAR,
			     l_market_rate IN NUMBER,
			     l_strike_rate IN NUMBER,
			     l_spot_rate   IN NUMBER,
			     l_subtype     IN CHAR,
			     l_int_rate    IN NUMBER,
			     l_ref_amount  IN NUMBER,
			     l_put_call    IN CHAR,
			     l_reval_amt   IN OUT NOCOPY NUMBER,
			     l_end_date    IN DATE) is
--
--**************** Note this Procedureis NOW REDUNDANT REPLACED BY STANDALONE
-- PROCEDURE CALC_OPTION_PRICES *********************
 l_call_price   NUMBER;
 l_put_price    NUMBER;
 l_percent_put  NUMBER;
 l_prem_put     NUMBER;
 l_percent_call NUMBER;
 l_prem_call    NUMBER;
 exp1           NUMBER(13,8);
 exp2           NUMBER(13,8);
 exp3           NUMBER(13,8);
 lan1           NUMBER(13,9);
 lan2           NUMBER(13,9);
 lan3           NUMBER(13,9);
 r              NUMBER(13,9);
 t              NUMBER(13,9);
 fp             NUMBER(9,4);
 ep             NUMBER(9,4);
 vol            NUMBER(13,9);
 prob           NUMBER(13,9);
 lan            NUMBER(13,9);
 d1             NUMBER(9,5);
 d2             NUMBER(9,5);
 nd1_calc_diff  NUMBER(9,5);
 nd2_calc_diff  NUMBER(9,5);
 nd20           NUMBER(9,5);
 nd21           NUMBER(9,5);
 nd22           NUMBER(9,5);
 nd10           NUMBER(9,5);
 nd11           NUMBER(9,5);
 nd12           NUMBER(9,5);
 nd1            NUMBER(9,5);
 nd2            NUMBER(9,5);
 year_basis     NUMBER(3,0);
 expt           NUMBER(13,8);
 calc_diff      NUMBER(13,9);
 calc_diff1     NUMBER(13,9);
--
 cursor YRBASIS is
  select m.YEAR_BASIS
   from  XTR_MASTER_CURRENCIES m
   where CURRENCY = l_counter_ccy;
--
 cursor LAN_VALUE is
  select c.LAN, d.LAN, e.LAN
   from  XTR_CUM_DIST_CALCS c,
	 XTR_CUM_DIST_CALCS d,
	 XTR_CUM_DIST_CALCS e
   where c.MKT_EXP = round(fp/ep,2)
   and   d.MKT_EXP = (round((FP/EP),2) + .005)
   and   e.MKT_EXP = (round((FP/EP),2) - .005);
--
 cursor EXPT_VALUE is
  select c.EXPT,d.EXPT,e.EXPT
   from  XTR_CUM_DIST_CALCS c,
	 XTR_CUM_DIST_CALCS d,
	 XTR_CUM_DIST_CALCS e
   where c.INT_DAYS = round((-(1)*r*t),2)
   and   d.INT_DAYS = (round((-(1)*r*t),2) + .005)
   and   e.INT_DAYS = (round((-(1)*r*t),2) - .005);
--
 cursor PROB_VALUE_1 is
  select c.PROBABILITY, d.PROBABILITY, e.PROBABILITY
   from  XTR_CUM_DIST_CALCS c,
	 XTR_CUM_DIST_CALCS d,
	 XTR_CUM_DIST_CALCS e
   where c.DEVIATION = round(d1,2)
   and   d.DEVIATION = (round(d1,2) + .005)
   and   e.DEVIATION = (round(d1,2) - .005);
--
 cursor PROB_VALUE_2 is
  select c.PROBABILITY, d.PROBABILITY, e.PROBABILITY
   from  XTR_CUM_DIST_CALCS c,
	 XTR_CUM_DIST_CALCS d,
	 XTR_CUM_DIST_CALCS e
   where c.DEVIATION = round(d2,2)
   and   d.DEVIATION = (round(d2,2) + .005)
   and   e.DEVIATION = (round(d2,2) - .005);
--
begin
 open YRBASIS;
  fetch YRBASIS into year_basis;
 if YRBASIS%NOTFOUND then
   year_basis := 360;
 end if;
 close YRBASIS;
 r  := l_int_rate / 100;
 t  := (l_expiry - l_end_date) / year_basis;
 fp := l_market_rate;
 ep := l_strike_rate;
 calc_diff := (-(1)*r*t) - round((-(1)*r*t),2);
 calc_diff1 := (fp/ep) - round((fp/ep),2);
 if l_subtype = 'SELL' then
  -- Vol is brought in as a mid rate therefore assuming a 0.5 spread
  -- the Offer vol is 0.25 higher
  -- therefore if we previously sold the option Use Offer Vol for
  -- closeout of the option
  vol := (l_volatility + 0.25) / 100;
 else
  -- the Bid Vol is 0.25 lower
  -- therefore if we previously purchased the option Use Bid Vol for
  -- closeout of the option
  vol := (l_volatility - 0.25) / 100;
 end if;
 open LAN_VALUE;
  fetch LAN_VALUE into lan1,lan2,lan3;
 if LAN_VALUE%NOTFOUND then
  close LAN_VALUE;
  goto NULL_VAL_FOUND;
  --DISP_ERR(980);--Log value not found
 end if;
 close LAN_VALUE;
 open EXPT_VALUE;
  fetch EXPT_VALUE into exp1, exp2, exp3;
 if EXPT_VALUE%NOTFOUND then
  close EXPT_VALUE;
  goto NULL_VAL_FOUND;
  -- DISP_ERR(981);--Exponential value
 end if;
 close EXPT_VALUE;
 if round((-(1) * r * t),2) > (-(1) * r * t) then
  expt := exp1 - ((calc_diff / .005) * (exp3 - exp1));
 else expt := exp1 + ((calc_diff / .005) * (exp2 - exp1));
 end if;
 if round((FP/EP),2) < (FP/EP) then
  lan := lan1 + ((calc_diff1 /.005) * (lan2 - lan1));
 else lan := lan1 - ((calc_diff1 /.005) * (lan3 - lan1));
 end if;
 d1 := (lan + (vol * vol / 2 * t)) / (vol * sqrt(t));
 d2 := d1 - (vol * sqrt(t));
 nd1_calc_diff := d1 - round(d1,2);
 nd2_calc_diff := d2 - round(d2,2);
 open PROB_VALUE_1;
  fetch PROB_VALUE_1 into nd10,nd11,nd12;
 if PROB_VALUE_1%NOTFOUND then
  close PROB_VALUE_1;
  goto NULL_VAL_FOUND;
  --DISP_ERR(982);--Probabilty value not found for d1.
 end if;
 close PROB_VALUE_1;
 if round(d1,2) < d1 then
   ND1 := nd10 + ((nd1_calc_diff /.005) * (nd11 - nd10));
 else ND1 := nd10 - ((nd1_calc_diff /.005) * (nd12 - nd10));
 end if;
 open PROB_VALUE_2;
  fetch PROB_VALUE_2 into nd20,nd21,nd22;
 if PROB_VALUE_2%NOTFOUND then
  close PROB_VALUE_2;
  goto NULL_VAL_FOUND;
  --DISP_ERR(983);--Probabilty value not found for D2
 end if;
 close PROB_VALUE_2;
 if round(d2,2) < d2 then
   ND2 := nd20 + ((nd2_calc_diff /.005) * (nd21 - nd20));
 else ND2 := nd20 - ((nd2_calc_diff /.005) * (nd22 - nd20));
 end if;
 l_call_price    := expt * ((fp * nd1) - (ep * nd2));
 l_put_price     := l_call_price + (expt * (ep - fp));
 l_percent_put   := l_put_price / nvl(l_spot_rate,l_strike_rate);
 l_percent_put   := round(l_percent_put * 100,3);
 l_prem_put      := l_percent_put / 100 * l_ref_amount;
 l_percent_call  := l_call_price / nvl(l_spot_rate,l_strike_rate);
 l_percent_call  := round(l_percent_call * 100,3);
 l_prem_call     := l_percent_call / 100 * l_ref_amount;
 if l_put_call = 'P' then
  l_reval_amt := l_prem_put;
 else
  l_reval_amt := l_prem_call;
 end if;
 <<NULL_VAL_FOUND>>
  l_reval_amt := nvl(l_reval_amt,0);
end CALC_OPTION_PRICE ;
----------------------------------------------------------------------------------------------------------------
--   Procedure to calculate tax and brokerage amounts
PROCEDURE CALC_TAX_BROKERAGE(l_deal_type    IN VARCHAR2,
                             l_deal_date    IN DATE,
                             l_tax_ref      IN VARCHAR2,
			     l_bkge_ref     IN VARCHAR2,
			     l_ccy          IN VARCHAR2,
			     l_yr_basis     IN NUMBER,
			     l_num_days     IN NUMBER,
			     l_tax_amt_type IN VARCHAR2,
			     l_tax_amt      IN NUMBER,
			     l_tax_rate     IN OUT NOCOPY NUMBER,
			     l_bkr_amt_type IN VARCHAR2,
			     l_bkr_amt      IN NUMBER,
			     l_bkr_rate     IN OUT NOCOPY NUMBER,
			     l_tax_out      IN OUT NOCOPY NUMBER,
			     l_tax_out_hce  IN OUT NOCOPY NUMBER,
			     l_bkge_out     IN OUT NOCOPY NUMBER,
			     l_bkge_out_hce IN OUT NOCOPY NUMBER,
			     l_err_code        OUT NOCOPY NUMBER,
			     l_level           OUT NOCOPY VARCHAR2) is
/*
			     l_amt_type1    IN VARCHAR2,
			     l_amt1         IN NUMBER,
			     l_amt_type2    IN VARCHAR2,
			     l_amt2         IN NUMBER,
			     l_amt_type3    IN VARCHAR2,
			     l_amt3         IN NUMBER,
*/
--
 tax_base_amt       NUMBER;
 bkge_base_amt      NUMBER;
 l_rounding_factor  NUMBER;
 l_tax_c_basis      VARCHAR(6);
 l_bkge_c_basis     VARCHAR(6);
 l_tax_amt_ty       VARCHAR(7);
 l_bkge_amt_ty      VARCHAR(7);
-- yr_basis        NUMBER;
 l_dummy_char       VARCHAR(7);
--
 -------------------
 -- AW Bug 1585466
 -------------------
 cursor  GET_ROUND_FACTOR is
  select nvl(rounding_factor,2)
   from  XTR_MASTER_CURRENCIES_V s
   where s.CURRENCY   = l_ccy;
--
 cursor BKGE_DETAILS is
  select b.CALC_BASIS,
         nvl(d.INTEREST_RATE,0)
   from  XTR_TAX_BROKERAGE_SETUP a,
	 XTR_DEDUCTION_CALCS b,
         XTR_TAX_BROKERAGE_RATES d
   where a.REFERENCE_CODE      = l_bkge_ref
   and   nvl(a.AUTHORISED,'N') = 'Y'
   and   b.DEAL_TYPE           = l_deal_type
   and   b.CALC_TYPE           = a.CALC_TYPE
   and   b.AMOUNT_TYPE         = l_bkr_amt_type
   and   d.RATE_GROUP          = a.RATE_GROUP
   and   d.REF_TYPE            = 'B'
   and   d.EFFECTIVE_FROM     <= l_deal_date
   and   nvl(d.MIN_AMT,0)     <= l_bkr_amt
   and   (d.MAX_AMT >= l_bkr_amt or d.MAX_AMT is NULL)
   order by d.EFFECTIVE_FROM desc;
--
 cursor TAX_DETAILS is
  select b.CALC_BASIS,
         nvl(d.INTEREST_RATE,0)
   from  XTR_TAX_BROKERAGE_SETUP a,
	 XTR_DEDUCTION_CALCS b,
         XTR_TAX_BROKERAGE_RATES d
   where a.REFERENCE_CODE      = l_tax_ref
   and   nvl(a.AUTHORISED,'N') = 'Y'
   and   b.DEAL_TYPE           = l_deal_type
   and   b.CALC_TYPE           = a.CALC_TYPE
   and   b.AMOUNT_TYPE         = l_tax_amt_type
   and   d.RATE_GROUP          = a.RATE_GROUP
   and   d.REF_TYPE            = 'T'
   and   d.EFFECTIVE_FROM     <= l_deal_date
   and   nvl(d.MIN_AMT,0)     <= l_tax_amt
   and   (d.MAX_AMT >= l_tax_amt or d.MAX_AMT is NULL)
   order by d.EFFECTIVE_FROM desc;

 -------------------
 -- AW Bug 1585466
 -------------------
 cursor CALC_HCE_AMTS is
  select round((l_tax_out / s.hce_rate),nvl(rounding_factor,2)),
	 round((l_bkge_out / s.hce_rate),nvl(rounding_factor,2))
   from  XTR_MASTER_CURRENCIES_V s
   where s.CURRENCY   = l_ccy;
--
/*
 cursor Y_BASE is
  select YEAR_BASIS
   from XTR_MASTER_CURRENCIES
   where CURRENCY = l_ccy;
*/
 v_tax_rate  NUMBER;
 v_bkr_rate  NUMBER;
--
begin
/*
 open Y_BASE;
  fetch Y_BASE INTO yr_basis;
 if Y_BASE%NOTFOUND then
  yr_basis := 365;
 end if;
 close Y_BASE;
*/

 -------------------
 -- AW Bug 1585466
 -------------------
 open GET_ROUND_FACTOR;
 fetch GET_ROUND_FACTOR into l_rounding_factor;
 close GET_ROUND_FACTOR;

 v_tax_rate := l_tax_rate;
 v_bkr_rate := l_bkr_rate;

 ----------------
 -- Tax Details
 ----------------
 if l_tax_ref is NOT NULL then
    open TAX_DETAILS;
    fetch TAX_DETAILS INTO l_tax_c_basis, v_tax_rate;
    close TAX_DETAILS;
/*
  if l_tax_amt_ty = l_amt_type1 then
   tax_base_amt := l_amt1;
  elsif l_tax_amt_ty = l_amt_type2 then
   tax_base_amt := l_amt2;
  elsif l_tax_amt_ty = l_amt_type3 then
   tax_base_amt := l_amt3;
  end if;
*/
    tax_base_amt := l_tax_amt;
    if l_tax_rate is null then
       l_tax_rate := v_tax_rate;
    end if;
    if l_tax_c_basis = 'FLAT' then
       l_tax_out := tax_base_amt * (l_tax_rate/100);
    elsif l_tax_c_basis = 'ANNUAL' then
       l_tax_out := (tax_base_amt * (l_tax_rate/100)/ l_yr_basis) * l_num_days;
    else
       l_tax_out := 0;
    end if;
 else
    l_tax_out := 0;
 end if;

 ----------------------
 -- Brokerage Details
 ----------------------
 if l_bkge_ref is NOT NULL then
    open BKGE_DETAILS;
    fetch BKGE_DETAILS INTO l_bkge_c_basis, v_bkr_rate;
    close BKGE_DETAILS;
/*
  if l_bkge_amt_ty = l_amt_type1 then
   bkge_base_amt := l_amt1;
  elsif l_bkge_amt_ty = l_amt_type2 then
   bkge_base_amt := l_amt2;
  elsif l_bkge_amt_ty = l_amt_type3 then
   bkge_base_amt := l_amt3;
  end if;
*/
    bkge_base_amt := l_bkr_amt;
    if l_bkr_rate is null then
       l_bkr_rate := v_bkr_rate;
    end if;
    if l_bkge_c_basis = 'FLAT' then
       l_bkge_out := bkge_base_amt * (l_bkr_rate/100);
    elsif l_bkge_c_basis = 'ANNUAL' then
       l_bkge_out := (bkge_base_amt * (l_bkr_rate/100)/ l_yr_basis) * l_num_days;
    end if;
 end if;

 -------------------
 -- AW Bug 1585466
 -------------------
 l_tax_out  := round(l_tax_out,l_rounding_factor);
 l_bkge_out := round(l_bkge_out,l_rounding_factor);

 if nvl(l_tax_out,0) <> 0 or nvl(l_bkge_out,0) <> 0 then
    open CALC_HCE_AMTS;
    fetch CALC_HCE_AMTS INTO l_tax_out_hce,l_bkge_out_hce;
    if CALC_HCE_AMTS%NOTFOUND then
       l_err_code := 886; l_level := 'E'; -- Unable to find Spot Rate Data
    end if;
    close CALC_HCE_AMTS;
 end if;

end CALC_TAX_BROKERAGE;
----------------------------------------------------------------------------------------------------------------
/*****************************************************************************/
-- This procedure should be called to calculate tax amounts, whereas
-- the above procedure, calc_tax_brokerage, should only be used for calculating
-- brokerage amounts.
-- Parameters:
--   l_deal_type = deal type
--   l_deal_date = tax "as of" date
--   l_prin_tax_ref = principal tax schedule code, null only want income tax
--   l_income_tax_ref = income tax schedule code, null if only want principal
--								tax
--   l_ccy_buy = for FX deals, buy currency; else currency of deal
--   l_ccy_sell = for FX deals, sell currency; else null
--   l_year_basis = number of days in a year, null if calc_type like '%_A'
--   l_num_days = number of days for tax calculation, null if calc type like
--							'%_A'
--   l_prin_tax_amount = base amount for principal tax calculation, required if
--		l_prin_tax_ref is not null
--   l_prin_tax_rate = tax rate of l_prin_tax_ref; if null, and l_prin_tax_ref
--		is not null, will return tax rate as of l_deal_date; not
--		required if l_prin_tax_ref is null
--   l_income_tax_amount = base amount for income tax calculation, required if
--		l_income_tax_amount is not null
--   l_income_tax_rate = base amount for income tax calculation; if null, and
--		l_income_tax_ref is not null, will return tax rate as of
--		l_deal_date; not required if l_income_tax_ref is null
--   l_prin_tax_out = calculated principal tax, rounded according to setup
--   l_income_tax_out = calculated income tax, rounded according to setup


PROCEDURE CALC_TAX_AMOUNT (l_deal_type IN VARCHAR2,
			   l_deal_date IN DATE,
			   l_prin_tax_ref   IN VARCHAR2,
			   l_income_tax_ref IN VARCHAR2,
  			   l_ccy_buy   IN VARCHAR2, -- ccy for MM deals
			   l_ccy_sell  IN VARCHAR2,
			   l_year_basis  IN NUMBER,
			   l_num_days    IN NUMBER,
			   l_prin_tax_amount    IN      NUMBER,
			   l_prin_tax_rate      IN OUT NOCOPY  NUMBER,
			   l_income_tax_amount  IN      NUMBER,
			   l_income_tax_rate    IN OUT NOCOPY  NUMBER,
			   l_prin_tax_out	IN OUT NOCOPY  NUMBER,
			   l_income_tax_out     IN OUT NOCOPY NUMBER,
			   l_err_code		   OUT NOCOPY NUMBER,
			   l_level		   OUT NOCOPY  VARCHAR2) is

  v_calc_basis VARCHAR2(10);
  v_calc_type VARCHAR2(9);
  v_tax_rate NUMBER;
  l_rounding_factor NUMBER;
  l_ccy VARCHAR2(15);
  l_rounding_rule VARCHAR2(1);
  l_rounding_precision VARCHAR2(20);

 cursor TAX_DETAILS (l_tax_ref VARCHAR2) is
  select b.CALC_BASIS, b.CALC_TYPE, nvl(d.INTEREST_RATE,0)
   from  XTR_TAX_BROKERAGE_SETUP a,
	 XTR_TAX_DEDUCTION_CALCS b,
         XTR_TAX_BROKERAGE_RATES d
   where a.REFERENCE_CODE      = l_tax_ref
   and   nvl(a.AUTHORISED,'N') = 'Y'
   and   b.DEAL_TYPE           = l_deal_type
   and   b.CALC_TYPE           = a.CALC_TYPE
   and   d.RATE_GROUP          = a.RATE_GROUP
   and   d.REF_TYPE            = 'T'
   and   d.EFFECTIVE_FROM     <= l_deal_date
   order by d.EFFECTIVE_FROM desc;


 cursor GET_ROUNDING_RULES(l_ref VARCHAR2) is
   select tax_rounding_rule, tax_rounding_precision
   from XTR_TAX_BROKERAGE_SETUP
   where reference_code = l_ref;

begin
  -- inititate out variables
  l_prin_tax_out := 0;
  l_income_tax_out := 0;

  -- calculate principal tax amount
  open TAX_DETAILS(l_prin_tax_ref);
  fetch TAX_DETAILS into v_calc_basis, v_calc_type, v_tax_rate;
  close TAX_DETAILS;

  if (l_prin_tax_rate is null) then
     l_prin_tax_rate := v_tax_rate;
  end if;

  if (v_calc_type IN ('PRN_A', 'MAT_A', 'CON_A')) then
     l_prin_tax_out := l_prin_tax_out +
	((l_prin_tax_amount*l_prin_tax_rate*l_num_days)/(100*l_year_basis));
  else
     l_prin_tax_out := l_prin_tax_amount*(l_prin_tax_rate/100);
  end if;

  if (l_deal_type = 'FX') then
    if (v_calc_type = 'SELL_F') then
      l_ccy := l_ccy_sell;
    else
      l_ccy := l_ccy_buy;
    end if;
  else
    l_ccy := l_ccy_buy;
  end if;


  -- calculate income tax amount
  open TAX_DETAILS(l_income_tax_ref);
  fetch TAX_DETAILS into v_calc_basis, v_calc_type, v_tax_rate;
  close TAX_DETAILS;

  if (l_income_tax_rate is null) then
     l_income_tax_rate := v_tax_rate;
  end if;
  l_income_tax_out := l_income_tax_amount*(l_income_tax_rate/100);


  --bug 2727920 if CCY is null then do not do rounding
  if l_ccy_buy is not null then
     -- round principal tax
     open GET_ROUNDING_RULES(l_prin_tax_ref);
     fetch GET_ROUNDING_RULES into l_rounding_rule, l_rounding_precision;
     close GET_ROUNDING_RULES;
     l_rounding_factor := GET_TAX_ROUND_FACTOR(l_rounding_precision, l_ccy);
     l_prin_tax_out := XTR_FPS2_P.interest_round(l_prin_tax_out,
					      l_rounding_factor,
					      l_rounding_rule);

     -- round income tax
     open GET_ROUNDING_RULES(l_income_tax_ref);
     fetch GET_ROUNDING_RULES into l_rounding_rule, l_rounding_precision;
     close GET_ROUNDING_RULES;
     l_rounding_factor := GET_TAX_ROUND_FACTOR(l_rounding_precision, l_ccy);
     l_income_tax_out := XTR_FPS2_P.interest_round(l_income_tax_out,
					        l_rounding_factor,
					        l_rounding_rule);
  else
  --round enough (12 decimals) so that it does not cause FRM-40831 since
  --the form only has 38 digits
     if l_prin_tax_out is not null then
        l_prin_tax_out := ROUND(l_prin_tax_out,12);
     end if;
     if l_income_tax_out is not null then
        l_income_tax_out := ROUND(l_income_tax_out,12);
     end if;
  end if;

end CALC_TAX_AMOUNT;
-------------------------------------
FUNCTION GET_TAX_SETTLE_METHOD (l_tax_ref VARCHAR2)
	RETURN VARCHAR2 IS

   l_settle_method  VARCHAR2(15);

   CURSOR get_settle_method IS
	SELECT tax_settle_method
	FROM XTR_TAX_BROKERAGE_SETUP
	WHERE reference_code = l_tax_ref;
BEGIN
   OPEN get_settle_method;
   FETCH get_settle_method INTO l_settle_method;
   IF (get_settle_method%FOUND) THEN
      CLOSE get_settle_method;
      return l_settle_method;
   ELSE
      return null;
   END IF;
END;
-------------------------------------
FUNCTION GET_TAX_ROUND_FACTOR(l_rounding_precision VARCHAR2,
			      l_ccy VARCHAR2)
	RETURN NUMBER IS

   l_rounding_factor NUMBER;
   l_ccy_precision NUMBER;

   CURSOR get_ccy_precision IS
      SELECT precision
      FROM fnd_currencies
      WHERE currency_code = l_ccy;

BEGIN
   IF (l_rounding_precision = 'THOUSANDS') THEN
      l_rounding_factor := -3;
   ELSIF (l_rounding_precision = 'HUNDREDS') THEN
      l_rounding_factor := -2;
   ELSIF (l_rounding_precision = 'TENS') THEN
      l_rounding_factor := -1;
   ELSIF (l_rounding_precision = 'ONES') THEN
      l_rounding_factor := 0;
   ELSE
	OPEN get_ccy_precision;
	FETCH get_ccy_precision INTO l_ccy_precision;
	CLOSE get_ccy_precision;

        IF (l_rounding_precision = 'UNITS') THEN
	    l_rounding_factor := l_ccy_precision;
	ELSIF (l_rounding_precision IN ('TENTHS', 'HUNDREDTHS')) THEN
	    IF (l_rounding_precision = 'TENTHS') THEN
		l_rounding_factor := 1;
	    ELSE
		l_rounding_factor := 2;
	    END IF;
	    IF (l_ccy_precision <= l_rounding_factor) THEN
		l_rounding_factor := l_ccy_precision;
	    END IF;
	END IF;
   END IF;
   RETURN l_rounding_factor;
END GET_TAX_ROUND_FACTOR;


----------------------------------------------------------------------
--   Procedure to check currency code is valid.
PROCEDURE CHK_CCY_CODE (l_currency    IN VARCHAR2,
			l_ccy_name    IN OUT NOCOPY VARCHAR2,
			l_yr_basis    IN OUT NOCOPY NUMBER,
			l_round       IN OUT NOCOPY NUMBER,
			l_err_code         OUT NOCOPY NUMBER,
			l_level                OUT NOCOPY VARCHAR2) is
--
 cursor CCY is
  select NAME, YEAR_BASIS, ROUNDING_FACTOR
   from  XTR_MASTER_CURRENCIES_V
   where CURRENCY   = l_currency;
--   and   AUTHORISED = 'Y';
--
begin
 if (l_currency is NOT NULL) then
  open CCY;
   fetch CCY INTO l_ccy_name, l_yr_basis, l_round;
  if CCY%NOTFOUND then
    l_err_code := 418; l_level := 'E';--This Currency does not exist or is not authorised
  end if;
  close CCY;
 end if;
end CHK_CCY_CODE;
----------------------------------------------------------------------------------------------------------------
--   Procedure to validate Client Code.
PROCEDURE CHK_CLIENT_CODE (l_client_code IN VARCHAR2,
			   l_client_name IN OUT NOCOPY VARCHAR2,
			   l_query       IN VARCHAR2,
			   l_err_code         OUT NOCOPY NUMBER,
			   l_level                OUT NOCOPY VARCHAR2) is
--
 cursor PTY_NAME is
  select SHORT_NAME
   from  XTR_PARTIES_V
   where PARTY_CODE = l_client_code
   and   PARTY_TYPE = 'CP'
   and   PARTY_CATEGORY = 'CL'
   and   AUTHORISED = 'Y';
--
 cursor QRY_NAME is
  select SHORT_NAME
   from  XTR_PARTY_INFO_V
   where PARTY_CODE = l_client_code;
--
begin
 if nvl(l_query,'N') = 'Y' then
  open QRY_NAME;
   fetch QRY_NAME INTO l_client_name;
  close QRY_NAME;
 else
  open PTY_NAME;
   fetch PTY_NAME INTO l_client_name;
  if PTY_NAME%NOTFOUND then
    l_err_code := 701; l_level := 'E';--The Client does not exist
  end if;
  close PTY_NAME;
 end if;
end CHK_CLIENT_CODE;
----------------------------------------------------------------------------------------------------------------
--   Procedure to validate company code.
PROCEDURE CHK_COMPANY_CODE (l_company_code IN VARCHAR2,
			    l_company_name IN OUT NOCOPY VARCHAR2,
                            l_query        IN  VARCHAR2,
			    l_err_code     OUT NOCOPY NUMBER,
			    l_level        OUT NOCOPY VARCHAR2) is
 l_user		VARCHAR2(10);
 fnd_user	NUMBER;
--
 cursor USER (fnd_user in number) is
  select dealer_code
  from xtr_dealer_codes_v
  where user_id = fnd_user;

 cursor COMP_NAME(l_user VARCHAR2) is
  select p.SHORT_NAME
   from XTR_PARTIES_V p
   where p.PARTY_CODE = l_company_code
   and p.PARTY_TYPE = 'C'
   and p.AUTHORISED = 'Y'
   and p.party_code in(select c.party_code
                        from XTR_COMPANY_AUTHORITIES c
                        where c.dealer_code = l_user
                        and c.company_authorised_for_input='Y');
--
 cursor QRY_NAME is
  select p.SHORT_NAME
   from XTR_PARTY_INFO_V p
   where p.PARTY_CODE = l_company_code;
--
begin
fnd_user := fnd_global.user_id;
open USER(fnd_user);
 fetch USER into l_user;
close USER;

if nvl(l_query,'N') = 'Y' then
  open QRY_NAME;
   fetch QRY_NAME INTO l_company_name;
  close QRY_NAME;
else
 open COMP_NAME(l_user);
  fetch COMP_NAME INTO l_company_name;
 if COMP_NAME%NOTFOUND then
   l_err_code := 701; l_level := 'E';--This Company does not exist
 end if;
 close COMP_NAME;
end if;
end CHK_COMPANY_CODE;
----------------------------------------------------------------------------------------------------------------
--   Procedure to check counterparty account number is valid
PROCEDURE CHK_CPARTY_ACCOUNT (l_cparty_code    IN VARCHAR2,
			      l_cparty_ref     IN VARCHAR2,
			      l_currency       IN VARCHAR2,
			      l_cparty_account IN OUT NOCOPY VARCHAR2,
			      l_err_code         OUT NOCOPY NUMBER,
			      l_level                OUT NOCOPY VARCHAR2) is
--
cursor ACCT_NOS is
 select ACCOUNT_NUMBER
  from  XTR_BANK_ACCOUNTS
  where PARTY_CODE = l_cparty_code
  and   BANK_SHORT_CODE = l_cparty_ref
  and   CURRENCY = l_currency;
--
begin
 if l_cparty_ref is NOT NULL then
  open ACCT_NOS;
   fetch ACCT_NOS INTO l_cparty_account;
/*
  if ACCT_NOS%NOTFOUND then
    l_err_code := 701; l_level := 'E';--This Cparty A/C Reference does not exist
  end if;
*/
  close ACCT_NOS;
 end if;
end CHK_CPARTY_ACCOUNT;
----------------------------------------------------------------------------------------------------------------
--   Procedure to validate the Counterparty Code.
PROCEDURE CHK_CPARTY_CODE (l_cparty_code IN VARCHAR2,
			   l_cparty_name IN OUT NOCOPY VARCHAR2,
			   l_query       IN VARCHAR2,
			   l_err_code    OUT NOCOPY NUMBER,
			   l_level       OUT NOCOPY VARCHAR2) is
--
 cursor PTY_NAME is
  select SHORT_NAME
   from  XTR_PARTIES_V
   where PARTY_CODE = l_cparty_code
   and   PARTY_TYPE in('CP','C')
   and   AUTHORISED = 'Y';
--
 cursor QRY_NAME is
  select SHORT_NAME
   from  XTR_PARTY_INFO_V
   where PARTY_CODE = l_cparty_code;
--
begin
 if nvl(l_query,'N') = 'Y' then
  open QRY_NAME;
   fetch QRY_NAME INTO l_cparty_name;
  close QRY_NAME;
 else
  open PTY_NAME;
   fetch PTY_NAME INTO l_cparty_name;
  if PTY_NAME%NOTFOUND then
    l_err_code := 701; l_level := 'E';--The Counterparty does not exist
  end if;
  close PTY_NAME;
 end if;
end CHK_CPARTY_CODE;
----------------------------------------------------------------------------------------------------------------
--   Procedure to validate counterparty limit type entered.
PROCEDURE CHK_CPARTY_LIMIT (l_cparty_code  IN VARCHAR2,
			    l_company_code IN VARCHAR2,
			    l_limit_code   IN VARCHAR2,
			    l_err_code         OUT NOCOPY NUMBER,
			    l_level                OUT NOCOPY VARCHAR2) is
--
 cursor LIMIT_TYPE is
  select 1
   from  XTR_COUNTERPARTY_LIMITS cpl
   where cpl.CPARTY_CODE  = l_cparty_code
   and   cpl.COMPANY_CODE = l_company_code
   and   cpl.LIMIT_CODE   = l_limit_code
   and   (cpl.EXPIRY_DATE >= trunc(sysdate) or
            cpl.EXPIRY_DATE is NULL);
--
 v_dummy                number(1);
begin
 if (l_company_code is NOT NULL and l_cparty_code is NOT NULL and
     l_limit_code is NOT NULL) then
   open LIMIT_TYPE;
   fetch LIMIT_TYPE INTO v_dummy;
   if LIMIT_TYPE%NOTFOUND then
     close limit_type;
     l_err_code := 701; l_level := 'E';--This Limit Type does not exist
   else
     close limit_type;
   end if;
 end if;
end CHK_CPARTY_LIMIT;
----------------------------------------------------------------------------------------------------------------
--   Procedure to check the entered Dealer Code
PROCEDURE CHK_DEALER_CODE (l_dealer_code IN VARCHAR2,
							l_err_code         OUT NOCOPY NUMBER,
							l_level                OUT NOCOPY  VARCHAR2) is
--
cursor CHK_CODE is
 select 1
  from  XTR_DEALER_CODES
  where DEALER_CODE = l_dealer_code;
--
v_dummy          number(1);
begin
 if l_dealer_code is NOT NULL then
  open CHK_CODE;
   fetch CHK_CODE INTO v_dummy;
   if CHK_CODE%NOTFOUND then
    close CHK_CODE;
    l_err_code := 701; l_level := 'E';--Invalid Code. Refer <LIST>.
   else
    close CHK_CODE;
   end if;
 end if;
end CHK_DEALER_CODE;
----------------------------------------------------------------------------------------------------------------
--   Procedure to check deal status to make sure that only
--  CURRENT deals are updated.
PROCEDURE CHK_DEAL_STATUS (l_deal_number IN NUMBER,
						       l_err_code         OUT NOCOPY NUMBER,
						       l_level                OUT NOCOPY VARCHAR2) is
--
 cursor D_STATUS is
  select   1
   from    XTR_DEALS_V
   where   deal_no     = l_deal_number
   and     status_code = 'CURRENT';
--
 v_dummy        number(1);
begin
 open D_STATUS;
 fetch D_STATUS INTO v_dummy;
 if D_STATUS%NOTFOUND then
   close D_STATUS;
   l_err_code := 58; l_level := 'E';--This deal is not CURRENT and cannot be updated
 else
   close D_STATUS;
 end if;
end CHK_DEAL_STATUS;
end XTR_FPS1_P;

/
