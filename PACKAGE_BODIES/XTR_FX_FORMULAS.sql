--------------------------------------------------------
--  DDL for Package Body XTR_FX_FORMULAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_FX_FORMULAS" AS
/* $Header: xtrfxflb.pls 120.5 2005/06/29 08:07:57 badiredd ship $ */

/*************************FX FORWARD************************************/

/*-----------------------------------------------------------------------
Calculates the FX Spot Rate for different currencies exchange.

Formula:
* If the BASIS_CONTRA/BASE is not 'C' (Commodity Unit Quote) then convert with FX FORWARD (HLD) Formula 1
* Check CURRENCY_CONTRA and CURRENCY_BASE if cross-currency pair is involved then  use FX FORWARD (HLD) Formula 2

Formula 1 is converting from Base Unit Quote to Commodity Unit Quote, and vice versa.
Formula 2 is to calculate the SPOT RATE(=Cross Rate)

Assumption: p_RATE_CONTRA and p_RATE_BASE have the same day count basis.

For IRS:  BASE = Receive Leg
          CONTRA = Pay Leg

Example for FX:CHFGBP -> CHF = Base Currency
                         GBP = Contra Currency

IF there is a notion of BID and ASK then:
To find p_SPOT_RATE (BID/ASK):
FOR CONTRA:
  IF p_BASIS_CONTRA = 'C' THEN
     p_RATE_CONTRA (BID/ASK) = BID/ASK Rate of
       Contra Currency
  ELSE
     p_RATE_CONTRA (BID/ASK) = ASK/BID Rate of
        Contra Currency
FOR BASE:
  IF p_BASIS_BASE = 'C' THEN
    p_RATE_BASE (BID/ASK) = ASK/BID Rate of Base
        Currency
  ELSE
    p_RATE_BASE (BID/ASK) = BID/ASK Rate of Base
        Currency

* p_RATE_CONTRA/BASE = FX rate of the contra/base side against USD
(p_RATE_CONTRA = Rate vs. USD Contra, p_RATE_ BASE = Rate vs. USD Base).
If the currency is USD then p_RATE = 1;
* p_CURRENCY_CONTRA/BASE = the currency for contra/base.
* p_BASIS_CONTRA/BASE indicates the quotation basis against USD for the CONTRA
BASE side, 'C' for Commodity Unit Quote (=USDGBP) and 'B' for Base Unit Quote=
GBPUSD) (Definitions are in FX Calculator HLD)
* p_SPOT_RATE = fair exchange rate of two different currencies.
-----------------------------------------------------------------------*/

PROCEDURE FX_SPOT_RATE (p_currency_contra IN VARCHAR2,
                        p_currency_base IN VARCHAR2,
                        p_rate_contra IN NUMBER,
                        p_rate_base IN NUMBER,
                        p_basis_contra IN CHAR,
                        p_basis_base IN CHAR,
                        p_spot_rate IN OUT NOCOPY NUMBER) is

  e_basis_code EXCEPTION;
  e_USD_rate EXCEPTION;
  v_rate_c NUMBER;
  v_rate_b NUMBER;

BEGIN

--CHeck whether the indicator is correct
  IF (p_basis_contra not IN ('C','B','c','b') or
      p_basis_base not IN ( 'C','B','c','b')) THEN

--    FND_MESSAGE.Set_Name('XTR', 'XTR_1059');
--    APP_EXCEPTION.raise_exception;

    RAISE e_basis_code;
  END IF;

--Check if currency USD then rate has to be 1
  IF (((UPPER(p_currency_contra)= 'USD') and (p_rate_contra <> 1)) or
      ((UPPER(p_currency_base)= 'USD') and (p_rate_base <> 1))) THEN
    RAISE e_USD_rate;
  END IF;

--Use Formula 1 to convert the rate to Commodity Unit Quote
--
  IF (p_basis_contra = 'B') THEN
    v_rate_c := 1/p_rate_contra;
   ELSE
    v_rate_c := p_rate_contra;
  END IF;

  IF (p_basis_base = 'B') THEN
    v_rate_b := 1/p_rate_base;
   ELSE
    v_rate_b := p_rate_base;
  END IF;

--Use Formula 2 in FX Forward HLD,
--if the exchange involves 2 non USD currencies.
--If it involves USD we can still use Formula 2 with the USD RATE = 1.
--
  p_spot_rate := v_rate_c/v_rate_b;

EXCEPTION
  WHEN e_basis_code THEN
--  dbms_output.put_line('The basis_contra/base values can only be ''C'' or ''B''.');
      RAISE_APPLICATION_ERROR
        (-20001,'The basis_contra/base values can only be ''C'' or ''B''.');
  WHEN e_USD_rate THEN
      RAISE_APPLICATION_ERROR
        (-20002,'If currency is USD then the rate = 1.');

END FX_SPOT_RATE;


/*-------------------------------------------------------------------------
Calculates the FX Forward Rate

Formula:
FX FORWARD (HLD) Formula 3

Example for FX: CHFGBP -> CHF = Base Currency
                          GBP = Contra Currency

IF there is a notion of BID and ASK then:
To find p_FORWARD_RATE (BID):
    p_SPOT_RATE = BID FX Spot Rate
    p_BASE_CURR_INT_RATE = ASK Base Currency risk free interest rate.
    p_CONTRA_CURR_INT_RATE = BID Contra Currency risk free interest rate.

To find p_FORWARD_RATE (ASK):
    p_SPOT_RATE = ASK FX Spot Rate
    p_BASE_CURR_INT_RATE = BID Base Currency risk free interest rate.
    p_CONTRA_CURR_INT_RATE = ASK Contra Currency risk free interest rate.


* p_SPOT_RATE = fair exchange rate of two different currencies.
* p_BASE/CONTRA_CURR_INT_RATE = risk free interest rate for the base/contra
currency.
* p_DAY_COUNT_BASE/CONTRA = number of days between the spot date and the
forward
date.
* p_ANNUAL_BASIS_BASE/CONTRA = number of days in a year of which the
* p_DAY_COUNT_BASE/CONTRA and the p_BASE/CONTRA_CURR_INT_RATE are based on.
-------------------------------------------------------------------------*/

PROCEDURE FX_FORWARD_RATE (p_spot_rate IN NUMBER,
                           p_base_curr_int_rate IN NUMBER,
                           p_contra_curr_int_rate IN NUMBER,
                           p_day_count_base IN NUMBER,
                           p_day_count_contra IN NUMBER,
                           p_annual_basis_base IN NUMBER,
                           p_annual_basis_contra IN NUMBER,
                           p_forward_rate IN OUT NOCOPY NUMBER) is

  v_rate_base NUMBER;
  v_rate_contra NUMBER;

BEGIN

  XTR_MM_FORMULAS.GROWTH_FACTOR(p_base_curr_int_rate,
                                           p_day_count_base,
                                           p_annual_basis_base,
                                           v_rate_base);
  XTR_MM_FORMULAS.GROWTH_FACTOR(p_contra_curr_int_rate,
                                              p_day_count_contra,
                                              p_annual_basis_contra,
                                              v_rate_contra);
  p_forward_rate := p_spot_rate*(v_rate_contra/v_rate_base);

END FX_FORWARD_RATE;


/***********************CALC_FX_OPTION_PRICES*******************************/

/*--------------------------------------------------------------------------
Calculates the price and sensitivity of a currency option and its associated greek ratio's using Garman-Kohlhagen formula, which is the extension of Black-Scholes formula.

Formula:
Taken from Currency Option Pricing Formula in Hull's Option, Future, and Other Derivatives, Third Edition p.272, p.317.
(Defined in xtrprc2b.pls)

IMPORTANT: due to the cumulative normal distribution function used, the
procedure is accurate up to 6 decimal places.

Currently used in xtrrevlb.pld

Call XTR_RATE_CONVERSION.rate_conversion to convert day counts and/or between compounded and simple interest rates.

* l_days = time left to maturity in days (assuming Actual/365 day count basis).
* l_base_int_rate = annual risk free interest rate for base currency.
* l_contra_int_rate = annual risk free interest rate for contra currency.
* l_spot_rate = the current market rate for the exchange.
* l_strike_price = the strike price agreed in the option.
* vol = volatility
* l_call_price = theoretical fair value of the call.
* l_put_price = theoretical fair value of the put
* l_fwd_price = the forward rate of the exchange calculated from the l_spot_rate
* l_delta_call/put = delta of the call/put
* l_theta_call/put = theta of the call/put
* l_rho_call/put = rho of the call/put (with respect to the change in base interest rate)
* l_rho_f_call/put = rho of call/put with respect to change in foreign interest rate
* l_gamma = gamma
* l_vega = vega
* l_nd1/2 = cumulative normal probability distribution value = N(x) in Black Formu
la
* l_nd1/2_a = N'(x) in Black Formula

gamma, theta, delta, vega are sensitivity measurements of the model relatives to its different variables and explained extensively in Hull's Option, Future, and Other Derivatives.
-----------------------------------------------------------------------*/
-- modified fhu 6/12/01:  added sensitivity calculations
PROCEDURE FX_GK_OPTION_PRICE(
                             l_days         IN NUMBER,
                             l_base_int_rate IN NUMBER,
                             l_contra_int_rate IN NUMBER,
                             l_spot_rate     IN NUMBER,
                             l_strike_rate   IN NUMBER,
                             vol IN NUMBER,
                             l_call_price IN OUT NOCOPY NUMBER,
                             l_put_price IN OUT NOCOPY NUMBER,
                             l_fwd_rate IN OUT NOCOPY NUMBER,
                             l_nd1 IN OUT NOCOPY NUMBER,
                             l_nd2 IN OUT NOCOPY NUMBER,
                             l_nd1_a IN OUT NOCOPY NUMBER,
                             l_nd2_a IN OUT NOCOPY NUMBER  ) IS

--
-- Below are approximations of normal probability and PI (always fixed constant)
 a1 		NUMBER :=  0.4361836;
 a2 		NUMBER := -0.1201678;
 a3 		NUMBER := 0.9372980;
 pi 		NUMBER  := 3.14159265358979;
--
 r_f 		NUMBER := l_base_int_rate / 100;
 r 		NUMBER := l_contra_int_rate / 100;
 t 		NUMBER := l_days / 365;  -- bug 3509267
 v 		NUMBER := vol / 100;
 d1 		NUMBER;
 d2 		NUMBER;
 n_d1 		NUMBER;
 n_d2 		NUMBER;
 n_d1_a         NUMBER;
 n_d2_a         NUMBER;

 v_cum_normdist_in_rec  xtr_mm_formulas.cum_normdist_in_rec_type;
 v_cum_normdist_out_rec xtr_mm_formulas.cum_normdist_out_rec_type;

BEGIN

 d1 := (LN(l_spot_rate/l_strike_rate) + (r-r_f + POWER(v,2)/2)*t)  / (v * SQRT(t));
 d2 := d1 - v*SQRT(t);

 v_cum_normdist_in_rec.p_d1 := d1;
 v_cum_normdist_in_rec.p_d2 := d2;
 xtr_mm_formulas.cumulative_norm_distribution
	(v_cum_normdist_in_rec, v_cum_normdist_out_rec);

 n_d1 := v_cum_normdist_out_rec.p_n_d1;
 n_d2 := v_cum_normdist_out_rec.p_n_d2;
 n_d1_a := v_cum_normdist_out_rec.p_n_d1_a;
 n_d2_a := v_cum_normdist_out_rec.p_n_d2_a;

---- See Currency Options on the Philadelphia Exchange p272
 l_fwd_rate :=l_spot_rate*EXP((r-r_f)*t);
 l_call_price := EXP(-r*t)*(l_fwd_rate * n_d1-l_strike_rate*n_d2);
 l_put_price := EXP(-r*t)*(l_strike_rate*(1-n_d2)-l_fwd_rate*(1-n_d1));

 l_nd1 := n_d1;
 l_nd2 := n_d2;
 l_nd1_a := n_d1_a;
 l_nd2_a := n_d2_a;

END FX_GK_OPTION_PRICE;

/*-----------------------------------------------------------------------
FX_GK_OPTION_PRICE_CV
Cover procedure to calculate the price of a currency option
using Garman-Kohlhagen formula, which is the extension of
Black-Scholes formula.

IMPORTANT: it is better to supply a Simple Actual/365 (from GET_MD_FROM_SET)
interest rates for this procedure in order to avoid redundant conversions.

IMPORTANT: this procedure is only accurate up to six decimal places due
to CUMULATIVE_NORM_DISTRIBUTION procedure it calls.

GK_OPTION_CV_IN_REC_TYPE:
p_SPOT_DATE date
p_MATURITY_DATE date
p_RATE_DOM num
p_RATE_TYPE_DOM varchar2(1) DEFAULT 'S'
p_COMPOUND_FREQ_DOM num
p_DAY_COUNT_BASIS_DOM varchar2(15)
p_RF_RATE_FOR num
p_RATE_TYPE_FOR varchar2(1) DEFAULT 'S'
p_COMPOUND_FREQ_FOR num
p_DAY_COUNT_BASIS_FOR varchar2(15)
p_SPOT_RATE num
p_STRIKE_RATE num
p_VOLATILITY num

GK_OPTION_CV_OUT_REC_TYPE:
p_CALL_PRICE num
p_PUT_PRICE num
p_FX_FWD_RATE num
p_Nd1 num
p_Nd2 num
p_Nd1_a num
p_Nd2_a num

Formula:
1. Converts interest rates to fit the FX_GK_OPTION_PRICE assumptions.
2. Calls FX_GK_OPTION_PRICE.

Example to calculate p_SPOT_RATE:
Given: CAD = foreign, USD = domestic
1 USD = 1.5 CADThen: p_SPOT_RATE = 0.666667

p_SPOT_DATE = the spot date where the option value is evaluated
p_MATURITY_DATE = the maturity date where the option expires
p_RF_RATE_DOM = domestic risk free interest rate.
p_RATE_TYPE_DOM/FOR = the p_RF_RATE_DOM/FOR rate's type. 'S' for Simple
 Rate. 'C' for Continuous Rate, and 'P' for Compounding Rate.
Default value = 'S' (Simple IR)
p_DAY_COUNT_BASIS_DOM/FOR = day count basis for p_RF_RATE_DOM/FOR.
p_RATE_FOR = foreign risk free interest rate.
p_SPOT_RATE = the current market exchange rate = the value of one unit
of the foreign currency measured in the domestic currency.
p_STRIKE_RATE = the strike price agreed in the option.
p_VOLATILITY = volatility
p_CALL_PRICE = theoretical fair value of the call.
p_PUT_PRICE = theoretical fair value of the put
p_FX_FWD_RATE = the forward rate of the exchange calculated from the
p_SPOT_RATE
p_Nd1/2 = cumulative distribution value given limit probability values
in Black's formula = N(x) (refer to Hull's Fourth Edition p.252)
p_Nd1/2_a = N'(x) in Black's formula (refer to Hull's Fourth Edition p.252)
p_COMPOUND_FREQ_DOM/FOR = frequencies of discretely compounded input/output
rate. This is only necessary if p_RATE_TYPE_DOM/FOR is 'P'.
-----------------------------------------------------------------------*/

PROCEDURE FX_GK_OPTION_PRICE_CV(p_in_rec IN GK_OPTION_CV_IN_REC_TYPE,
				p_out_rec OUT NOCOPY GK_OPTION_CV_OUT_REC_TYPE) IS

  v_days         NUMBER;
  v_base_int_rate NUMBER;
  v_contra_int_rate NUMBER;
  v_rate_type_dom VARCHAR2(1):='S';
  v_rate_type_for VARCHAR2(1):='S';

  v_dummy NUMBER;
  v_rc_in xtr_rate_conversion.rate_conv_in_rec_type;
  v_rc_out xtr_rate_conversion.rate_conv_out_rec_type;

BEGIN
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('FX_SPOT_RATE: ' || 'XTR_MM_FORMULAS.FX_GK_OPTION_PRICE_CV');
  END IF;

  --get number of days in Actual/365  -- bug 3509267
  xtr_calc_p.calc_days_run_c(p_in_rec.p_spot_date, p_in_rec.p_maturity_date,
			'ACTUAL365', null, v_days, v_dummy);

  --need to converts all rates to Continuously compounded Actual/365  -- bug 3509267
  v_rc_in.p_rate_type_out := 'C';
  v_rc_in.p_day_count_basis_out := 'ACTUAL365';
/*
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('FX_SPOT_RATE: ' || 'Rate Type Dom',p_in_rec.p_rate_type_dom);
   xtr_risk_debug_pkg.dlog('FX_SPOT_RATE: ' || 'Rate Type For',p_in_rec.p_rate_type_for);
END IF;
*/
  --convert domestic rate to continuous ACTUAL/365  -- bug 3509267
  IF NOT (p_in_rec.p_rate_type_dom IN ('C','c') AND
	p_in_rec.p_day_count_basis_dom = 'ACTUAL365') THEN
    v_rc_in.p_rate_type_in := p_in_rec.p_rate_type_dom;
    v_rc_in.p_day_count_basis_in := p_in_rec.p_day_count_basis_dom;
    v_rc_in.p_rate_in := p_in_rec.p_rate_dom;
    v_rc_in.p_start_date := p_in_rec.p_spot_date;
    v_rc_in.p_end_date := p_in_rec.p_maturity_date;
    v_rc_in.p_compound_freq_in := p_in_rec.p_compound_freq_dom;
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('FX_SPOT_RATE: ' || 'Rate Type Dom',p_in_rec.p_rate_type_dom);
END IF;
    xtr_rate_conversion.rate_conversion(v_rc_in, v_rc_out);
    v_contra_int_rate := v_rc_out.p_rate_out;
  ELSE
    v_contra_int_rate := p_in_rec.p_rate_dom;
  END IF;

  --convert foreign rate to continuous Actual/365 -- bug 3509267
  IF NOT (p_in_rec.p_rate_type_for IN ('C','c') AND
	p_in_rec.p_day_count_basis_for = 'ACTUAL365') THEN
    v_rc_in.p_rate_type_in := p_in_rec.p_rate_type_for;
    v_rc_in.p_day_count_basis_in := p_in_rec.p_day_count_basis_for;
    v_rc_in.p_rate_in := p_in_rec.p_rate_for;
    v_rc_in.p_start_date := p_in_rec.p_spot_date;
    v_rc_in.p_end_date := p_in_rec.p_maturity_date;
    v_rc_in.p_compound_freq_in := p_in_rec.p_compound_freq_for;
    xtr_rate_conversion.rate_conversion(v_rc_in, v_rc_out);
    v_base_int_rate := v_rc_out.p_rate_out;
  ELSE
    v_base_int_rate := p_in_rec.p_rate_for;
  END IF;
/*
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('FX_SPOT_RATE: ' || 'No. of Days',v_days);
   xtr_risk_debug_pkg.dlog('FX_SPOT_RATE: ' || 'Foreign IR C Actual/365',v_base_int_rate);
   xtr_risk_debug_pkg.dlog('FX_SPOT_RATE: ' || 'Domestic IR C Actual365', v_contra_int_rate);
   xtr_risk_debug_pkg.dlog('FX_SPOT_RATE: ' || 'Strike Rate',p_in_rec.p_strike_rate);
   xtr_risk_debug_pkg.dlog('FX_SPOT_RATE: ' || 'Spot Rate',p_in_rec.p_spot_rate);
   xtr_risk_debug_pkg.dlog('FX_SPOT_RATE: ' || 'Vol',p_in_rec.p_volatility);
END IF;
*/
  --call fx_gk_option_price
  fx_gk_option_price(v_days, v_base_int_rate, v_contra_int_rate,
  		p_in_rec.p_spot_rate, p_in_rec.p_strike_rate,
		p_in_rec.p_volatility,
            	p_out_rec.p_call_price, p_out_rec.p_put_price,
		p_out_rec.p_fx_fwd_rate, p_out_rec.p_nd1, p_out_rec.p_nd2,
  		p_out_rec.p_nd1_a, p_out_rec.p_nd2_a);

  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpop('FX_SPOT_RATE: ' || 'XTR_MM_FORMULAS.FX_GK_OPTION_PRICE_CV');
  END IF;
END fx_gk_option_price_cv;

--added by sankim 9/12/01
/*
FX_SPOT_RATE_CV (FUNCTION)Cover routine that calculates the FX Spot Rate for
bid and ask side of different currencies exchange.In order to make the cover
routine easier to be called from Java (middle tier) directly, the record type
is not used to encapsulate the arguments. Moreover, function is used instead of
 procedure since function can be called from SQL.
Parameters
* p_RATE_CONTRA/BASE_BID/ASK = FX rate of the contra/base currency against USD
for bid/ask side (p_RATE_ CONTRA = Rate vs. USD Contra, p_RATE_ BASE = Rate vs.
 USD Base). If the currency is USD then use the default rate (=1).
* p_CURRENCY_CONTRA/BASE = the currency for contra/base.
 p_QUOTATION_BASIS_CONTRA/BASE indicates the quotation basis against USD for
the CONTRA /BASE side, 'C' for Commodity Unit Quote (=USDGBP) and 'B' for Base
Unit Quote (= GBPUSD) (Definitions are in FX Calculator HLD)
* Returned: p_SPOT_RATE (BID/ASK) = fair exchange rate of two different
currencies of side bid/ask.
*/
FUNCTION FX_SPOT_RATE_CV( p_currency_contra IN VARCHAR2,
			  p_currency_base IN VARCHAR2,
			  p_rate_contra_bid IN NUMBER,
			  p_rate_contra_ask IN NUMBER,
			  p_rate_base_bid IN NUMBER,
			  p_rate_base_ask IN NUMBER,
			  p_quotation_basis_contra IN VARCHAR2,
			  p_quotation_basis_base IN VARCHAR2)
			  RETURN XTR_MD_NUM_TABLE IS
  v_results_array XTR_MD_NUM_TABLE:=XTR_MD_NUM_TABLE();
BEGIN
  v_results_array.extend;
  v_results_array.extend;
  if p_quotation_basis_contra = 'C' then
    if p_quotation_basis_base = 'C' then
      --base in commodity quotation basis, contra in commodity quotation basis
      --bid
      fx_spot_rate(p_currency_contra,p_currency_base,p_rate_contra_bid,p_rate_base_ask,p_quotation_basis_contra,p_quotation_basis_base,v_results_array(1));
      --ask
      fx_spot_rate(p_currency_contra,p_currency_base,p_rate_contra_ask,p_rate_base_bid,p_quotation_basis_contra,p_quotation_basis_base,v_results_array(2));
    elsif p_quotation_basis_base = 'B' then
    --base in commodity quotation basis, contra in base quotation basis
      --bid
      fx_spot_rate(p_currency_contra,p_currency_base,p_rate_contra_bid,p_rate_base_bid,p_quotation_basis_contra,p_quotation_basis_base,v_results_array(1));
      --ask
      fx_spot_rate(p_currency_contra,p_currency_base,p_rate_contra_ask,p_rate_base_ask,p_quotation_basis_contra,p_quotation_basis_base,v_results_array(2));
    else
      RAISE_APPLICATION_ERROR
	(-20001,'p_quotation_basis_base must be ''C'' or ''B''.');
    end if;
  elsif p_quotation_basis_contra = 'B' then
    if p_quotation_basis_base = 'C' then
    --base in base quotation basis, contra in commodity quotation basis
      --bid
      fx_spot_rate(p_currency_contra,p_currency_base,p_rate_contra_ask,p_rate_base_ask,p_quotation_basis_contra,p_quotation_basis_base,v_results_array(1));
      --ask
      fx_spot_rate(p_currency_contra,p_currency_base,p_rate_contra_bid,p_rate_base_bid,p_quotation_basis_contra,p_quotation_basis_base,v_results_array(2));
    elsif p_quotation_basis_base = 'B' then
    --base in base quotation basis, contra in base quotation basis
      --bid
      fx_spot_rate(p_currency_contra,p_currency_base,p_rate_contra_ask,p_rate_base_bid,p_quotation_basis_contra,p_quotation_basis_base,v_results_array(1));
      --ask
      fx_spot_rate(p_currency_contra,p_currency_base,p_rate_contra_bid,p_rate_base_ask,p_quotation_basis_contra,p_quotation_basis_base,v_results_array(2));
    else
      RAISE_APPLICATION_ERROR
	(-20001,'p_quotation_basis_base must be ''C'' or ''B''.');
    end if;
  else
    RAISE_APPLICATION_ERROR
	(-20001,'p_quotation_basis_contra must be ''C'' or ''B''.');
  end if;
  RETURN v_results_array;
END FX_SPOT_RATE_CV;

--added by sankim 9/12/01
/*
FX_FORWARD_RATE_CV (FUNCTION)A cover routine that calculates the FX Forward
Rate for  exchange that has USD as the base.In order to make the cover routine
easier to be called from Java (middle tier) directly, the record type is not
used to encapsulate the arguments. Moreover, function is used instead of
procedure since function can be called from SQL.
Parameters
* p_SPOT_RATE_BASE_BID/ASK = fair exchange rate of between the base currency
against USD. If the base currency is USD, then the default value of 1 should be
 used.
* p_SPOT_RATE_CONTRA_BID/ASK = fair exchange rate of between the contra
currency against USD. If the contra currency is USD, then the default value of
 1 should be used.
* p_BASE_CURR_INT_RATE_BID/ASK = bid/ask risk free interest rate for the base
currency.  This parameter should be null if the base currency is USD.
* p_CONTRA_CURR_INT_RATE_BID/ASK = bid/ask risk free interest rate for the
contra currency.  This parameter should be null if the contra currency is USD.
* p_USD _CURR_INT_RATE = risk free interest rate for the USD.
* p_DAY_COUNT_BASE/CONTRA = number of days between the spot date and the
forward date. If the contra currency is USD, then p_DAY_COUNT_CONTRA should be
null, and vice versa in the case of base is USD.
* p_ANNUAL_BASIS_BASE/CONTRA = number of days in a year of which the
p_DAY_COUNT_BASE/CONTRA and the p_BASE/CONTRA_CURR_INT_RATE are based on. If
the contra currency is USD, then p_ANNUAL_BASIS_CONTRA should be null, and vice
 versa in the case of base is USD.
* p_DAY_COUNT_USD = number of days between the spot date and the forward date.
= number of days in a year of which the p_DAY_COUNT_USD and the
p_USD _CURR_INT_RATE are based on.
* p_ANNUAL_BASIS_USD = number of days in a year of which the p_DAY_COUNT_USD
and the p_USD _CURR_INT_RATE are based on.
* p_CURRENCY_CONTRA/BASE = the currency for contra/base.
* p_QUOTATION_BASIS_CONTRA/BASE indicates the quotation basis against USD for
the CONTRA /BASE side, 'C' for Commodity Unit Quote (=USDGBP) and 'B' for Base
Unit Quote (= GBPUSD) (Definitions are in FX Calculator HLD). This parameter is
 required if base/contra is non-USD accordingly.
* Returned: p_FORWARD_RATE (BID/ASK) indicates the bid/ask side of forward rate
 results.
*/
FUNCTION FX_FORWARD_RATE_CV( p_spot_rate_base_bid IN NUMBER,
			     p_spot_rate_base_ask IN NUMBER,
			     p_spot_rate_contra_bid IN NUMBER,
			     p_spot_rate_contra_ask IN NUMBER,
      			     p_base_curr_int_rate_bid IN NUMBER,
			     p_base_curr_int_rate_ask IN NUMBER,
			     p_contra_curr_int_rate_bid IN NUMBER,
			     p_contra_curr_int_rate_ask IN NUMBER,
 			     p_usd_curr_int_rate_bid IN NUMBER,
			     p_usd_curr_int_rate_ask IN NUMBER,
 			     p_day_count_base IN NUMBER,
			     p_day_count_contra IN NUMBER,
			     p_day_count_usd IN NUMBER,
			     p_annual_basis_base IN NUMBER,
			     p_annual_basis_contra IN NUMBER,
			     p_annual_basis_usd IN NUMBER,
			     p_currency_base IN VARCHAR2,
			     p_currency_contra IN VARCHAR2,
			     p_quotation_basis_base IN VARCHAR2,
			     p_quotation_basis_contra IN VARCHAR2)
			     RETURN XTR_MD_NUM_TABLE IS
  v_results_array XTR_MD_NUM_TABLE:=XTR_MD_NUM_TABLE();
  v_forward_rate_base_bid NUMBER;
  v_forward_rate_base_ask NUMBER;
  v_forward_rate_contra_bid NUMBER;
  v_forward_rate_contra_ask NUMBER;
BEGIN
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dpush('FX_FORWARD_RATE_CV: ' || 'XTR_FORWARD_RATE_CV');
END IF;
if (p_currency_base <> 'USD') AND (p_currency_contra <> 'USD') THEN
 --if cross currency is involved
 -- calculate forward rates for base currency first
  if p_quotation_basis_base = 'C' then
    IF xtr_risk_debug_pkg.g_Debug THEN
       xtr_risk_debug_pkg.dlog('FX_FORWARD_RATE_CV: ' || 'right base bid');
    END IF;
    --bid
    XTR_FX_FORMULAS.fx_forward_rate(p_spot_rate_base_bid, p_usd_curr_int_rate_ask, p_base_curr_int_rate_bid, p_day_count_usd, p_day_count_base, p_annual_basis_usd, p_annual_basis_base, v_forward_rate_base_bid);
    --ask
    XTR_FX_FORMULAS.fx_forward_rate(p_spot_rate_base_ask, p_usd_curr_int_rate_bid, p_base_curr_int_rate_ask, p_day_count_usd, p_day_count_base, p_annual_basis_usd, p_annual_basis_base, v_forward_rate_base_ask);
  elsif p_quotation_basis_base = 'B' then
    --bid
    XTR_FX_FORMULAS.fx_forward_rate(p_spot_rate_base_bid, p_base_curr_int_rate_ask, p_usd_curr_int_rate_bid, p_day_count_base, p_day_count_usd, p_annual_basis_base, p_annual_basis_usd, v_forward_rate_base_bid);
    --ask
    XTR_FX_FORMULAS.fx_forward_rate(p_spot_rate_base_ask, p_base_curr_int_rate_bid, p_usd_curr_int_rate_ask, p_day_count_base, p_day_count_usd, p_annual_basis_base, p_annual_basis_usd, v_forward_rate_base_ask);
  else
    RAISE_APPLICATION_ERROR
	(-20001,'p_quotation_basis_base must be ''C'' or ''B''.');
  end if;
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dlog('FX_FORWARD_RATE_CV: ' || 'contra quotation basis',p_quotation_basis_contra);
  END IF;
  --now calculate forward rates for contra currency
  if p_quotation_basis_contra = 'C' then
    IF xtr_risk_debug_pkg.g_Debug THEN
       xtr_risk_debug_pkg.dlog('FX_FORWARD_RATE_CV: ' || 'wrong contra bid');
    END IF;
    --bid
    XTR_FX_FORMULAS.fx_forward_rate(p_spot_rate_contra_bid, p_usd_curr_int_rate_ask, p_contra_curr_int_rate_bid, p_day_count_usd, p_day_count_contra, p_annual_basis_usd, p_annual_basis_contra, v_forward_rate_contra_bid);
    --ask
    XTR_FX_FORMULAS.fx_forward_rate(p_spot_rate_contra_ask, p_usd_curr_int_rate_bid, p_contra_curr_int_rate_ask, p_day_count_usd, p_day_count_contra, p_annual_basis_usd, p_annual_basis_contra, v_forward_rate_contra_ask);
  elsif p_quotation_basis_contra = 'B' then
    IF xtr_risk_debug_pkg.g_Debug THEN
       xtr_risk_debug_pkg.dlog('FX_FORWARD_RATE_CV: ' || 'right contra bid');
    END IF;
    --bid
    XTR_FX_FORMULAS.fx_forward_rate(p_spot_rate_contra_bid, p_contra_curr_int_rate_ask, p_usd_curr_int_rate_bid, p_day_count_contra, p_day_count_usd, p_annual_basis_contra, p_annual_basis_usd, v_forward_rate_contra_bid);
    --ask
    XTR_FX_FORMULAS.fx_forward_rate(p_spot_rate_contra_ask, p_contra_curr_int_rate_bid, p_usd_curr_int_rate_ask, p_day_count_contra, p_day_count_usd, p_annual_basis_contra, p_annual_basis_usd, v_forward_rate_contra_ask);
  else
    RAISE_APPLICATION_ERROR
	(-20001,'p_quotation_basis_base must be ''C'' or ''B''.');
  end if;
  -- calculate cross rate
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dlog('FX_FORWARD_RATE_CV: ' || 'base fwd bid',v_forward_rate_base_bid);
     xtr_risk_debug_pkg.dlog('FX_FORWARD_RATE_CV: ' || 'base fwd ask',v_forward_rate_base_ask);
     xtr_risk_debug_pkg.dlog('FX_FORWARD_RATE_CV: ' || 'contra fwd bid',v_forward_rate_contra_bid);
     xtr_risk_debug_pkg.dlog('FX_FORWARD_RATE_CV: ' || 'contra fwd ask',v_forward_rate_contra_ask);
  END IF;
  return XTR_FX_FORMULAS.fx_spot_rate_cv(p_currency_contra,p_currency_base,v_forward_rate_contra_bid,v_forward_rate_contra_ask,v_forward_rate_base_bid,v_forward_rate_base_ask,p_quotation_basis_contra,p_quotation_basis_base);
else
--simpler case where there is no cross currency involved
  if (p_currency_base = 'USD') THEN --USD is base
    v_results_array.extend;
    v_results_array.extend;
    if p_quotation_basis_contra = 'C' then
    -- calculate bid forward rate
      XTR_FX_FORMULAS.fx_forward_rate(p_spot_rate_contra_bid, p_usd_curr_int_rate_ask, p_contra_curr_int_rate_bid, p_day_count_usd, p_day_count_contra, p_annual_basis_usd, p_annual_basis_contra, v_results_array(1));
    --now ask
      XTR_FX_FORMULAS.fx_forward_rate(p_spot_rate_contra_ask, p_usd_curr_int_rate_bid, p_contra_curr_int_rate_ask, p_day_count_usd, p_day_count_contra, p_annual_basis_usd, p_annual_basis_contra, v_results_array(2));
      RETURN v_results_array;
    elsif  p_quotation_basis_contra = 'B' then
    -- calculate bid forward rate
      XTR_FX_FORMULAS.fx_forward_rate(1/p_spot_rate_contra_ask, p_usd_curr_int_rate_ask, p_contra_curr_int_rate_bid, p_day_count_usd, p_day_count_contra, p_annual_basis_usd, p_annual_basis_contra, v_results_array(1));
    --now ask
      XTR_FX_FORMULAS.fx_forward_rate(1/p_spot_rate_contra_bid, p_usd_curr_int_rate_bid, p_contra_curr_int_rate_ask, p_day_count_usd, p_day_count_contra, p_annual_basis_usd, p_annual_basis_contra, v_results_array(2));
      RETURN v_results_array;
    else
      RAISE_APPLICATION_ERROR
	(-20001,'p_quotation_basis_contra must be ''C'' or ''B''.');
  end if;
  else  --USD is contra
    v_results_array.extend;
    v_results_array.extend;
    if p_quotation_basis_base = 'B' then
      -- calculate bid forward rate
      XTR_FX_FORMULAS.fx_forward_rate(p_spot_rate_base_bid, p_base_curr_int_rate_ask, p_usd_curr_int_rate_bid, p_day_count_base, p_day_count_usd, p_annual_basis_base, p_annual_basis_usd, v_results_array(1));
      -- calculate ask forward rate
      XTR_FX_FORMULAS.fx_forward_rate(p_spot_rate_base_ask, p_base_curr_int_rate_bid, p_usd_curr_int_rate_ask, p_day_count_base, p_day_count_usd, p_annual_basis_base, p_annual_basis_usd, v_results_array(2));
      RETURN v_results_array;
    elsif  p_quotation_basis_base = 'C' then
      -- calculate bid forward rate
      XTR_FX_FORMULAS.fx_forward_rate(1/p_spot_rate_base_ask, p_base_curr_int_rate_ask, p_usd_curr_int_rate_bid, p_day_count_base, p_day_count_usd, p_annual_basis_base, p_annual_basis_usd, v_results_array(1));
      -- calculate ask forward rate
      XTR_FX_FORMULAS.fx_forward_rate(1/p_spot_rate_base_bid, p_base_curr_int_rate_bid, p_usd_curr_int_rate_ask, p_day_count_base, p_day_count_usd, p_annual_basis_base, p_annual_basis_usd, v_results_array(2));
      RETURN v_results_array;
    else
      RAISE_APPLICATION_ERROR
	(-20001,'p_quotation_basis_base must be ''C'' or ''B''.');
    end if;

  end if;
end if;
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dpop('FX_FORWARD_RATE_CV: ' || 'XTR_FORWARD_RATE_CV');
END IF;
END FX_FORWARD_RATE_CV;

END XTR_FX_FORMULAS;

/
