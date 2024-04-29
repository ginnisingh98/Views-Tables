--------------------------------------------------------
--  DDL for Package Body QRM_FX_FORMULAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QRM_FX_FORMULAS" AS
/* $Header: qrmfxflb.pls 115.19 2003/11/22 00:36:22 prafiuly ship $ */

/*-------------------------------------------------------------
FX_GK_OPTION_SENS_CV
Cover procedure to calculate the sensitivity of a currency option
using Garman-Kohlhagen formula, which is the extension of
Black-Scholes formula.

IMPORTANT: it is better to supply a Simple 30/360 (from GET_MD_FROM_SET)
interest rates for this procedure in order to avoid redundant conversions.

IMPORTANT: this procedure is only accurate up to six decimal places due
to CUMULATIVE_NORM_DISTRIBUTION procedure it calls.

GK_OPTION_SENS_IN_REC_TYPE:
			p_SPOT_DATE
			p_MATURITY_DATE
			p_CCY_FOR
			p_CCY_DOM
			p_RATE_DOM
			p_RATE_TYPE_DOM
			p_COMPOUND_FREQ_DOM
			p_DAY_COUNT_BASIS_DOM
			p_RATE_FOR
			p_RATE_TYPE_FOR
			p_COMPOUND_FREQ
			p_DAY_COUNT_BASIS_FOR
			p_SPOT_RATE
			p_STRIKE_RATE
			p_VOLATILITY

GK_OPTION_SENS_OUT_REC_TYPE:
			p_DELTA_CALL
			p_DELTA_PUT
			p_THETA_CALL
			p_THETA_PUT
			p_RHO_CALL
			p_RHO_PUT
			p_RHO_F_CALL
			p_RHO_F_PUT
			p_GAMMA
			p_VEGA


Formula:
Calls FX_GK_OPTION_SENS

p_SPOT_DATE = the spot date where the option value is evaluated
p_MATURITY_DATE = the maturity date where the option expires
p_CCY_DOM = domestic currency
p_CCY_FOR = foreign currency
p_RATE_DOM = domestic risk free interest rate.
p_RATE_TYPE_DOM/FOR = the p_RF_RATE_DOM/FOR rate's type. 'S' for Simple
 Rate. 'C' for Continuous Rate, and 'P' for Compounding Rate.
Default value = 'S' (Simple IR)
p_DAY_COUNT_BASIS_DOM/FOR = day count basis for p_RF_RATE_DOM/FOR.
p_RATE_FOR = foreign risk free interest rate.
p_SPOT_RATE = the current market exchange rate = the value of one unit
of the foreign currency measured in the domestic currency.
p_STRIKE_RATE = the strike price agreed in the option.
p_VOLATILITY = volatility
p_COMPOUND_FREQ_DOM/FOR = frequencies of discretely compounded input/output
rate. This is only necessary if p_RATE_TYPE_DOM/FOR is 'P'.
---------------------------------------------------------------*/
-- added fhu 3/26/02

PROCEDURE FX_GK_OPTION_SENS_CV(p_rec_in	IN 	GK_OPTION_SENS_IN_REC_TYPE,
			       p_rec_out OUT NOCOPY	GK_OPTION_SENS_OUT_REC_TYPE)
	IS

  	p_gk_in		XTR_FX_FORMULAS.gk_option_cv_in_rec_type;
	p_gk_out	XTR_FX_FORMULAS.gk_option_cv_out_rec_type;
	p_conv_in	XTR_RATE_CONVERSION.rate_conv_in_rec_type;
	p_conv_out	XTR_RATE_CONVERSION.rate_conv_out_rec_type;

	p_day_count	NUMBER;
	p_annual_basis 	NUMBER;

	p_base_int_rate		NUMBER;
	p_contra_int_rate	NUMBER;
	p_strike_rate		NUMBER := p_rec_in.p_strike_rate;

	p_delta_call	NUMBER;
	p_delta_put	NUMBER;
	p_theta_call	NUMBER;
	p_theta_put	NUMBER;
	p_rho_call	NUMBER;
	p_rho_put	NUMBER;
	p_rho_f_call	NUMBER;
	p_rho_f_put	NUMBER;
	p_gamma		NUMBER;
	p_vega		NUMBER;

	p_base_ccy	VARCHAR2(15);
	p_contra_ccy	VARCHAR2(15);
 	p_reverse	BOOLEAN;

BEGIN
  IF (g_proc_level>=g_debug_level) THEN --bug 3236479
     XTR_RISK_DEBUG_PKG.dpush(null,'QRM_FX_FORMULAS.FX_GK_OPTION_SENS_CV');
  END IF;

  IF (p_rec_in.p_volatility = 0) THEN
      raise QRM_MM_FORMULAS.e_option_vol_zero;
  END IF;


  -- find days to maturity
  XTR_CALC_P.calc_days_run_c(p_rec_in.p_spot_date, p_rec_in.p_maturity_date,
        '30/', null, p_day_count, p_annual_basis);
  IF (g_proc_level>=g_debug_level) THEN
     XTR_RISK_DEBUG_PKG.dlog('FX_GK_OPTION_SENS_CV: ' || 'day count: '||p_day_count);
  END IF;

  -- convert base int rate to continous compounded 30/360 day count basis
  IF NOT (p_rec_in.p_rate_type_for IN ('C','c') AND
        p_rec_in.p_day_count_basis_for = '30/') THEN
     p_conv_in.p_start_date := p_rec_in.p_spot_date;
     p_conv_in.p_end_date := p_rec_in.p_maturity_date;
     p_conv_in.p_day_count_basis_in := p_rec_in.p_day_count_basis_for;
     p_conv_in.p_day_count_basis_out := '30/';
     p_conv_in.p_rate_type_in := p_rec_in.p_rate_type_for;
     p_conv_in.p_rate_type_out := 'C';
     p_conv_in.p_compound_freq_in := p_rec_in.p_compound_freq_for;
     p_conv_in.p_rate_in := p_rec_in.p_rate_for;
     XTR_RATE_CONVERSION.rate_conversion(p_conv_in, p_conv_out);
     p_base_int_rate := p_conv_out.p_rate_out;
     IF (g_proc_level>=g_debug_level) THEN
        XTR_RISK_DEBUG_PKG.dlog('FX_GK_OPTION_SENS_CV: ' || 'CONVERTED continuous base int rate:'||p_base_int_rate);
     END IF;
  END IF;

  -- convert contra int rate to continuous compounded 30/360 day count basis
  IF NOT (p_rec_in.p_rate_type_dom IN ('C','c') AND
        p_rec_in.p_day_count_basis_dom = '30/') THEN
     p_conv_in.p_start_date := p_rec_in.p_spot_date;
     p_conv_in.p_end_date := p_rec_in.p_maturity_date;
     p_conv_in.p_day_count_basis_in := p_rec_in.p_day_count_basis_dom;
     p_conv_in.p_day_count_basis_out := '30/';
     p_conv_in.p_rate_type_in := p_rec_in.p_rate_type_dom;
     p_conv_in.p_rate_type_out := 'C';
     p_conv_in.p_compound_freq_in := p_rec_in.p_compound_freq_dom;
     p_conv_in.p_rate_in := p_rec_in.p_rate_dom;
     XTR_RATE_CONVERSION.rate_conversion(p_conv_in, p_conv_out);
     p_contra_int_rate := p_conv_out.p_rate_out;
     IF (g_proc_level>=g_debug_level) THEN
        XTR_RISK_DEBUG_PKG.dlog('FX_GK_OPTION_SENS_CV: ' || 'continuous contra int rate:'||p_contra_int_rate);
     END IF;
  END IF;

  -- determine whether to invert strike price
  -- invert when deal foreign ccy <> system base ccy
  p_base_ccy := p_rec_in.p_ccy_for;
  p_contra_ccy := p_rec_in.p_ccy_dom;
  get_base_contra(p_base_ccy, p_contra_ccy, p_reverse);
  IF (p_base_ccy <> p_rec_in.p_ccy_for) THEN
     p_strike_rate := 1/p_rec_in.p_strike_rate;
  END IF;
  IF (g_proc_level>=g_debug_level) THEN
     XTR_RISK_DEBUG_PKG.dlog('FX_GK_OPTION_SENS_CV: ' || 'strike rate is: '||p_strike_rate);
  END IF;

  fx_gk_option_sens(p_day_count, p_base_int_rate, p_contra_int_rate,
	p_rec_in.p_spot_rate, p_strike_rate, p_rec_in.p_volatility,
	p_delta_call, p_delta_put, p_theta_call, p_theta_put, p_rho_call,
	p_rho_put, p_rho_f_call, p_rho_f_put, p_gamma, p_vega);

  p_rec_out.p_delta_call := p_delta_call;
  p_rec_out.p_delta_put := p_delta_put;
  p_rec_out.p_theta_call := p_theta_call;
  p_rec_out.p_theta_put := p_theta_put;
  p_rec_out.p_rho_call := p_rho_call;
  p_rec_out.p_rho_put := p_rho_put;
  p_rec_out.p_rho_f_call := p_rho_f_call;
  p_rec_out.p_rho_f_put := p_rho_f_put;
  p_rec_out.p_gamma := p_gamma;
  p_rec_out.p_vega := p_vega;

  IF (g_proc_level>=g_debug_level) THEN --bug 3236479
     XTR_RISK_DEBUG_PKG.dpop(null,'QRM_FX_FORMULAS.FX_GK_OPTION_SENS_CV');
  END IF;
END FX_GK_OPTION_SENS_CV;


-- added fhu 6/19/01
-- modified fhu 3/27/02
PROCEDURE FX_GK_OPTION_SENS(
                             l_days         IN NUMBER,
                             l_for_int_rate IN NUMBER,
                             l_dom_int_rate IN NUMBER,
                             l_spot_rate     IN NUMBER,
                             l_strike_rate   IN NUMBER,
                             vol IN NUMBER,
                             l_delta_call IN OUT NOCOPY NUMBER,
                             l_delta_put IN OUT NOCOPY NUMBER,
                             l_theta_call IN OUT NOCOPY NUMBER,
                             l_theta_put IN OUT NOCOPY NUMBER,
                             l_rho_call IN OUT NOCOPY NUMBER,
                             l_rho_put IN OUT NOCOPY NUMBER,
			     l_rho_f_call IN OUT NOCOPY NUMBER,
			     l_rho_f_put IN OUT NOCOPY NUMBER,
                             l_gamma IN OUT NOCOPY NUMBER,
                             l_vega IN OUT NOCOPY NUMBER) is

	n_d1 number;
	n_d2 number;
	n_d1_a number;
	n_d2_a number;
	l_call number;
	l_put number;
	l_forward number;

	r_f NUMBER := l_for_int_rate / 100;
 	r NUMBER := l_dom_int_rate / 100;
	t NUMBER := l_days / 360;
	v 		NUMBER := vol / 100;

BEGIN
  IF (g_proc_level>=g_debug_level) THEN --bug 3236479
     XTR_RISK_DEBUG_PKG.dpush(null,'QRM_FX_FORMULAS.FX_GK_OPTION_SENS');
  END IF;
  IF (vol = 0) THEN
      raise QRM_MM_FORMULAS.e_option_vol_zero;
  END IF;

  -- call XTR_FX_FORMULAS.FX_GK_OPTION_PRICE
  XTR_FX_FORMULAS.FX_GK_OPTION_PRICE(l_days, l_for_int_rate, l_dom_int_rate,
	l_spot_rate, l_strike_rate, vol, l_call, l_put, l_forward, n_d1,
	n_d2, n_d1_a, n_d2_a);

  l_delta_call := EXP((-r_f)*t)*n_d1;
  l_delta_put := EXP((-r_f)*t)*(n_d1 - 1);
  l_gamma := (n_d1_a*EXP((-r_f)*t))/(l_spot_rate*v*SQRT(t));
  l_vega := l_spot_rate*SQRT(t)*n_d1_a*EXP(-r_f*t);
  l_theta_call := -((l_spot_rate*n_d1_a*v*EXP((-r_f)*t))/(2*SQRT(t)))+r_f*l_spot_rate*n_d1*EXP((-r_f)*t)-(r*l_strike_rate*EXP(-r*t)*n_d2);
  l_theta_put := -((l_spot_rate*n_d1_a*v*EXP((-r_f)*t))/(2*SQRT(t)))-r_f*l_spot_rate*(1-n_d1)*EXP((-r_f)*t)+(r*l_strike_rate*EXP(-r*t)*(1-n_d2));
  l_rho_call := l_strike_rate*t*EXP(-r*t)*n_d2;
  l_rho_put := -l_strike_rate*t*EXP(-r*t)*(1-n_d2);
  l_rho_f_call := -t*EXP((-r_f)*t)*l_spot_rate*n_d1;
  l_rho_f_put := t*EXP((-r_f)*t)*l_spot_rate*(1-n_d1);

  IF (g_proc_level>=g_debug_level) THEN --bug 3236479
     XTR_RISK_DEBUG_PKG.dpop(null,'QRM_FX_FORMULAS.FX_GK_OPTION_SENS');
  END IF;
END FX_GK_OPTION_SENS;

-- modified by  sankim 9/14/01
/*
Calculates the DELTA SPOT of a FX forward.  The Delta spot measures the
rate of change of the FX Forward Rate with respect to the Spot Rate.
See Deal Calculations HLD.

The arguments are defined as follows:
* p_CONTRA/BASE_CUR = Contra/Bid currency
* p_DF_CONTRA_BID/ASK = discount factor for the contra currency(Bid and Ask
side)
* p_DF_BASE_BID/ASK = discount factor for the base currency(Bid and Ask side)
* p_DF_USD_BID/ASK = discount factor for the USD(Bid and Ask side) required
only if USD is not Base or Contra
Returned:
* p_DELTA = delta spot(bid and ask returned as xtr_md_num_table[2]
         (BID side = xtr_md_num_table[1],ASK side = xtr_md_num_table[2]))
All of USD discount factor parameters defaults to null because they are not
required if Base or Contra currency is USD. They are required if USD is not
Base or Contra However, if insufficient input is provided, error will be
raised. Because of the optional parameters, to use this function, the caller
can just pass in 6 parameters instead of 8, not passing in the last two USD
discount factors if they are not necessary.If it makes it easier, feel free to
pass values to all six discount factor parameters.  This procedure will only
use the relevant parameters and ignore the rest.
 */
FUNCTION FX_FORWARD_DELTA_SPOT(p_contra_cur IN VARCHAR2,
                               p_base_cur IN VARCHAR2,
                               p_df_contra_bid IN NUMBER,
                               p_df_contra_ask IN NUMBER,
			       p_df_base_bid IN NUMBER,
 			       p_df_base_ask IN NUMBER,
                               p_df_usd_bid IN NUMBER,
			       p_df_usd_ask IN NUMBER)
	RETURN XTR_MD_NUM_TABLE IS
v_results XTR_MD_NUM_TABLE:= XTR_MD_NUM_TABLE();

BEGIN
  IF (g_proc_level>=g_debug_level) THEN --bug 3236479
     XTR_RISK_DEBUG_PKG.dpush(null,'QRM_FX_FORMULAS.FX_FORWARD_DELTA_SPOT');
  END IF;

  v_results.extend;
  v_results.extend;
  -- calculate bid
  IF p_contra_cur <> 'USD' and p_base_cur <> 'USD' THEN
    IF (p_df_usd_bid is NULL) OR (p_df_usd_ask is NULL) THEN
      RAISE_APPLICATION_ERROR
      (-20001,'p_DF_USD_ASK or p_DF_USD_BID are missing.');
    ELSE
      v_results(1):= (p_df_usd_ask/p_df_base_bid)*
                     (p_df_contra_ask/p_df_usd_bid);
    END IF;
  ELSE
    v_results(1):= (p_df_contra_ask/p_df_base_bid);
  END IF;
  -- calculate ask
  IF p_contra_cur <> 'USD' and p_base_cur <> 'USD' THEN
    v_results(2):= (p_df_usd_bid/p_df_base_ask)*(p_df_contra_bid/p_df_usd_ask);
  ELSE
    v_results(2):= (p_df_contra_bid/p_df_base_ask);
  END IF;

  IF (g_proc_level>=g_debug_level) THEN --bug 3236479
     XTR_RISK_DEBUG_PKG.dpop(null,'QRM_FX_FORMULAS.FX_FORWARD_DELTA_SPOT');
  END IF;

  RETURN v_results;
END FX_FORWARD_DELTA_SPOT;





-- added fhu 6/12/01
--modified sankim 9/18/01
/*
Calculates the RHO, DELTA CONTRA/BASE INTEREST RATE of a FX forward.
See Deal Calculations HLD.
Example for FX: CHFGBP -> CHF = Base Currency
               GBP = Contra Currency
parameters
* p_OUT = 'C' if want p_RHO to be rho contra, 'B' if want p_RHO to be rho base,
          or 'D' if want both
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
Returned:
* p_RHO (BID/ASK) indicates the bid/ask side of rho(bid and ask returned as
xtr_md_num_table[2](BID side = xtr_md_num_table[1],
                    ASK side = xtr_md_num_table[2]))
 if p_OUT ='D' then the returned value is as following:
p_RHO  xtr_md_num_table[4](Base BID side =  xtr_md_num_table[1],
                           Base ASK side =  xtr_md_num_table[2],
                           Contra BID side =  xtr_md_num_table[3],
                           Contra ASK side =  xtr_md_num_table[4])

Calls XTR_FX_FORMULAS.FX_FORWARD_RATE_CV  (see def of fx_forward_rate above)
*/
FUNCTION FX_FORWARD_RHO(p_out IN VARCHAR2,
                        p_spot_rate_base_bid IN NUMBER,
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


	v_forward_rate_base XTR_MD_NUM_TABLE:=XTR_MD_NUM_TABLE();
        v_forward_rate_shifted XTR_MD_NUM_TABLE:=XTR_MD_NUM_TABLE();
        v_rho XTR_MD_NUM_TABLE:=XTR_MD_NUM_TABLE();


BEGIN
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpush(null,'QRM_FX_FROMULAS.FX_FORWARD_RHO');
  END IF;
  v_forward_rate_base.extend;
  v_forward_rate_base.extend;
  v_forward_rate_shifted.extend;
  v_forward_rate_shifted.extend;
  v_rho.extend;
  v_rho.extend;
  IF p_out not in ('D','C','B') THEN
    RAISE_APPLICATION_ERROR(-20001,'p_OUT must be ''C'',''B'',or ''D''.');
  END IF;
  IF p_out = 'B' or p_out = 'D' THEN
    -- calculate base base forward rate
    v_forward_rate_base:=XTR_FX_FORMULAS.fx_forward_rate_cv(
    p_spot_rate_base_bid,p_spot_rate_base_ask, p_spot_rate_contra_bid,
    p_spot_rate_contra_ask,p_base_curr_int_rate_bid, p_base_curr_int_rate_ask,
    p_contra_curr_int_rate_bid, p_contra_curr_int_rate_ask,
    p_usd_curr_int_rate_bid, p_usd_curr_int_rate_ask, p_day_count_base,
    p_day_count_contra, p_day_count_usd, p_annual_basis_base,
    p_annual_basis_contra, p_annual_basis_usd, p_currency_base,
    p_currency_contra, p_quotation_basis_base, p_quotation_basis_contra);

  -- calculate shifted base forward rate
    IF p_currency_base = 'USD' THEN
      v_forward_rate_shifted:=XTR_FX_FORMULAS.fx_forward_rate_cv(
      p_spot_rate_base_bid,p_spot_rate_base_ask, p_spot_rate_contra_bid,
      p_spot_rate_contra_ask,p_base_curr_int_rate_bid,
      p_base_curr_int_rate_ask, p_contra_curr_int_rate_bid,
      p_contra_curr_int_rate_ask, p_usd_curr_int_rate_bid+0.01,
      p_usd_curr_int_rate_ask+0.01, p_day_count_base, p_day_count_contra,
      p_day_count_usd, p_annual_basis_base, p_annual_basis_contra,
      p_annual_basis_usd, p_currency_base, p_currency_contra,
      p_quotation_basis_base, p_quotation_basis_contra);
    ELSE
      v_forward_rate_shifted:=XTR_FX_FORMULAS.fx_forward_rate_cv(
      p_spot_rate_base_bid,p_spot_rate_base_ask, p_spot_rate_contra_bid,
      p_spot_rate_contra_ask,p_base_curr_int_rate_bid+0.01,
      p_base_curr_int_rate_ask+0.01, p_contra_curr_int_rate_bid,
      p_contra_curr_int_rate_ask, p_usd_curr_int_rate_bid,
      p_usd_curr_int_rate_ask, p_day_count_base, p_day_count_contra,
      p_day_count_usd, p_annual_basis_base, p_annual_basis_contra,
      p_annual_basis_usd, p_currency_base, p_currency_contra,
      p_quotation_basis_base, p_quotation_basis_contra);
    END IF;

    --bidfirst
    v_rho(1):=(v_forward_rate_shifted(1) - v_forward_rate_base(1))/.0001;
	    IF (g_proc_level>=g_debug_level) THEN
	       XTR_RISK_DEBUG_PKG.dlog('FX_FORWARD_RHO: ' || 'base bid forward rate: '||v_forward_rate_base(1));
           XTR_RISK_DEBUG_PKG.dlog('FX_FORWARD_RHO: ' || 'base bid forward rate shifted: '||v_forward_rate_shifted(1));
        END IF;
    --ask
    v_rho(2):=(v_forward_rate_shifted(2) - v_forward_rate_base(2))/.0001;
	    IF (g_proc_level>=g_debug_level) THEN
	       XTR_RISK_DEBUG_PKG.dlog('FX_FORWARD_RHO: ' || 'base ask forward rate: '||v_forward_rate_base(2));
           XTR_RISK_DEBUG_PKG.dlog('FX_FORWARD_RHO: ' || 'base ask forward rate shifted: '||v_forward_rate_shifted(2));
        END IF;
    IF p_out = 'B' THEN
      IF (g_proc_level>=g_debug_level) THEN
         xtr_risk_debug_pkg.dpop('FX_FORWARD_RHO: ' || 'Rho');
      END IF;
      return v_rho;
    END IF;
  END IF;
  IF p_out = 'C'OR p_out = 'D' THEN
  -- calculate base contra forward rate
    v_forward_rate_base:=XTR_FX_FORMULAS.fx_forward_rate_cv(
    p_spot_rate_base_bid,p_spot_rate_base_ask, p_spot_rate_contra_bid,
    p_spot_rate_contra_ask,p_base_curr_int_rate_bid, p_base_curr_int_rate_ask,
    p_contra_curr_int_rate_bid, p_contra_curr_int_rate_ask,
    p_usd_curr_int_rate_bid, p_usd_curr_int_rate_ask, p_day_count_base,
    p_day_count_contra, p_day_count_usd, p_annual_basis_base,
    p_annual_basis_contra, p_annual_basis_usd, p_currency_base,
    p_currency_contra, p_quotation_basis_base, p_quotation_basis_contra);

  -- calculate shifted contra forward rate
    IF p_currency_contra = 'USD' THEN
      v_forward_rate_shifted:=XTR_FX_FORMULAS.fx_forward_rate_cv(
      p_spot_rate_base_bid,p_spot_rate_base_ask, p_spot_rate_contra_bid,
      p_spot_rate_contra_ask,p_base_curr_int_rate_bid, p_base_curr_int_rate_ask
      , p_contra_curr_int_rate_bid, p_contra_curr_int_rate_ask,
      p_usd_curr_int_rate_bid+0.01, p_usd_curr_int_rate_ask+0.01,
      p_day_count_base, p_day_count_contra, p_day_count_usd,
      p_annual_basis_base, p_annual_basis_contra, p_annual_basis_usd,
      p_currency_base, p_currency_contra, p_quotation_basis_base,
      p_quotation_basis_contra);
    ELSE
      v_forward_rate_shifted:=XTR_FX_FORMULAS.fx_forward_rate_cv(
      p_spot_rate_base_bid,p_spot_rate_base_ask, p_spot_rate_contra_bid,
      p_spot_rate_contra_ask,p_base_curr_int_rate_bid, p_base_curr_int_rate_ask
      , p_contra_curr_int_rate_bid+0.01, p_contra_curr_int_rate_ask+0.01,
      p_usd_curr_int_rate_bid, p_usd_curr_int_rate_ask, p_day_count_base,
      p_day_count_contra, p_day_count_usd, p_annual_basis_base,
      p_annual_basis_contra, p_annual_basis_usd, p_currency_base,
      p_currency_contra, p_quotation_basis_base, p_quotation_basis_contra);
    END IF;

    --bid first
    IF (g_proc_level>=g_debug_level) THEN
       xtr_risk_debug_pkg.dlog('FX_FORWARD_RHO: ' || 'v_forward_rate_base bid',v_forward_rate_base(1));
       xtr_risk_debug_pkg.dlog('FX_FORWARD_RHO: ' || 'v_forward_rate_base ask',v_forward_rate_base(2));
       xtr_risk_debug_pkg.dlog('FX_FORWARD_RHO: ' || 'v_forward_rate_shifted bid',v_forward_rate_shifted(1));
       xtr_risk_debug_pkg.dlog('FX_FORWARD_RHO: ' || 'v_forward_rate_shifted ask',v_forward_rate_shifted(2));
    END IF;
    IF p_out = 'C' THEN
     --just calculating contra
      v_rho(1):=(v_forward_rate_shifted(1) - v_forward_rate_base(1))/.0001;
    --ask
       v_rho(2):=(v_forward_rate_shifted(2) - v_forward_rate_base(2))/.0001;
    ELSE
    -- calculating both base and contra
      v_rho.extend;
      v_rho.extend;
      --bid
      v_rho(3):=(v_forward_rate_shifted(1) - v_forward_rate_base(1))/.0001;
    --ask
      v_rho(4):=(v_forward_rate_shifted(2) - v_forward_rate_base(2))/.0001;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('FX_FORWARD_RHO: ' || 'contra bid forward rate: '||v_forward_rate_base(1));
           XTR_RISK_DEBUG_PKG.dlog('FX_FORWARD_RHO: ' || 'contra bid forward rate shifted: '||v_forward_rate_shifted(1));
	   XTR_RISK_DEBUG_PKG.dlog('FX_FORWARD_RHO: ' || 'contra ask forward rate: '||v_forward_rate_base(2));
           XTR_RISK_DEBUG_PKG.dlog('FX_FORWARD_RHO: ' || 'contra ask forward rate shifted: '||v_forward_rate_shifted(2));
        END IF;
    END IF;
    IF (g_proc_level>=g_debug_level) THEN
       xtr_risk_debug_pkg.dpop(null,'QRM_FX_FROMULAS.FX_FORWARD_RHO');
    END IF;
    return v_rho;
  END IF;
END FX_FORWARD_RHO;

/*  SENSITIVITIES of FX OPTION -- See FX_GK_OPTION_PRICE procedure */


/*************** Fair Value Calculations *******/

/*********************************************************/
/* This procedure returns base and contra currency info  */
/* from system rate setup.Also return TRUE               */
/* if we need to invert base and contra                  */
/*********************************************************/
PROCEDURE get_base_contra(
          p_base  IN OUT NOCOPY VARCHAR2,
          p_contra  IN OUT NOCOPY VARCHAR2,
          p_reverse  OUT NOCOPY BOOLEAN) IS

l_cur VARCHAR2(15) := NULL;
cursor c_cur is
select CURRENCY_FIRST
from XTR_BUY_SELL_COMBINATIONS
where (CURRENCY_BUY = p_base and CURRENCY_SELL = p_contra)
    or (CURRENCY_BUY = p_contra and CURRENCY_SELL = p_base);

begin
  for l_tmp in c_cur loop
    l_cur := l_tmp.CURRENCY_FIRST;
  end loop;

  if l_cur = p_base then
    p_reverse := false;
  else
    -- swap it
    p_reverse := true;
    p_contra := p_base;
    p_base := l_cur;
  end if;

end get_base_contra;


PROCEDURE fv_fxo(p_price_model 		IN 	VARCHAR2,
		p_deal_subtype 		IN 	VARCHAR2,
		p_option_type 		IN 	VARCHAR2,
		p_set_code   		IN 	VARCHAR2,
		p_for_ccy		IN	VARCHAR2,
		p_premium_ccy		IN	VARCHAR2,
		p_buy_ccy		IN	VARCHAR2,
		p_sell_ccy		IN	VARCHAR2,
		p_interpolation_method 	IN	VARCHAR2,
		p_spot_date		IN	DATE,
		p_future_date		IN	DATE,
		p_strike_price		IN	NUMBER,
		p_for_amount		IN	NUMBER,
		p_side			IN	OUT NOCOPY	VARCHAR2,
		p_forward_rate		IN	OUT NOCOPY 	NUMBER,
		p_fair_value		IN	OUT NOCOPY	NUMBER) IS

	p_base_ccy	VARCHAR2(15);
	p_contra_ccy	VARCHAR2(15);
	p_dom_ccy	VARCHAR2(15);
	p_ref_ccy	VARCHAR2(15);
	p_counter_ccy 	VARCHAR2(15);
	p_dummy 	BOOLEAN;
	p_cap_or_floor  VARCHAR2(5);
	p_day_count_basis VARCHAR2(15) := '30/';

	p_volatility 	NUMBER;
	p_buy_int_rate 	NUMBER;
	p_sell_int_rate NUMBER;
	p_base_rate	NUMBER;
	p_contra_rate	NUMBER;
	p_base_amount	NUMBER;
	p_contra_amount	NUMBER;
	p_spot_rate	NUMBER;
	p_strike	NUMBER;
	p_call_price	NUMBER;
	p_put_price	NUMBER;

	p_md_in    	xtr_market_data_p.md_from_set_in_rec_type;
	p_md_out   	xtr_market_data_p.md_from_set_out_rec_type;
	p_conv_in	XTR_RATE_CONVERSION.RATE_CONV_IN_REC_TYPE;
	p_conv_out	XTR_RATE_CONVERSION.RATE_CONV_OUT_REC_TYPE;
	p_fx_in	 	XTR_FX_FORMULAS.GK_OPTION_CV_IN_REC_TYPE;
	p_fx_out	XTR_FX_FORMULAS.GK_OPTION_CV_OUT_REC_TYPE;

BEGIN
IF (g_proc_level>=g_debug_level) THEN
   XTR_RISK_DEBUG_PKG.dpush(null,'QRM_FX_FROMULAS.FV_FXO');
END IF;
    IF (p_price_model = 'GARMAN_KOHL') THEN
        -- get base/contra currencies straight
        p_base_ccy := p_buy_ccy;
        p_contra_ccy := p_sell_ccy;
        get_base_contra(p_base_ccy, p_contra_ccy, p_dummy);
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_fxo: ' || 'base ccy: '||p_base_ccy);
	   XTR_RISK_DEBUG_PKG.dlog('fv_fxo: ' || 'contra ccy: '||p_contra_ccy);
	END IF;

	IF (p_deal_subtype = 'BUY') THEN
	    p_side := 'A';
	ELSIF (p_deal_subtype = 'SELL') THEN
	    p_side := 'B';
	ELSE
	    RAISE_APPLICATION_ERROR(-20001,'p_deal_subtype must be BUY or SELL');
	END IF;

	-- get volatility
	p_md_in.p_md_set_code := p_set_code;
	p_md_in.p_source := 'C';
	p_md_in.p_indicator := 'V';
	p_md_in.p_spot_date := p_spot_date;
	p_md_in.p_future_date := p_future_date;
	p_md_in.p_ccy := p_base_ccy;
	p_md_in.p_contra_ccy := p_contra_ccy;
	p_md_in.p_day_count_basis_out := p_day_count_basis;
	p_md_in.p_interpolation_method := p_interpolation_method;
	p_md_in.p_side := p_side;
	p_md_in.p_batch_id := null;
	p_md_in.p_bond_code := null;
	XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
	p_volatility := p_md_out.p_md_out;
	IF (p_volatility = 0) THEN
	    raise QRM_MM_FORMULAS.e_option_vol_zero;
	END IF;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_fxo: ' || 'volatility: '||p_volatility);
	END IF;

	-- get interest rate buy buy currency (ask side)
	p_md_in.p_side := 'A';
	p_md_in.p_indicator := 'Y';
	p_md_in.p_ccy := p_buy_ccy;
	XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
	p_buy_int_rate := p_md_out.p_md_out;
        IF (g_proc_level>=g_debug_level) THEN
           XTR_RISK_DEBUG_PKG.dlog('fv_fxo: ' || 'buy ccy interp int rate: '||p_buy_int_rate);
        END IF;

	-- get interest rate for sell currency (bid side);
	p_md_in.p_side := 'B';
	p_md_in.p_ccy := p_sell_ccy;
	XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
	p_sell_int_rate := p_md_out.p_md_out;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_fxo: ' || 'sell ccy interp int rate: '||p_sell_int_rate);
	END IF;

	-- convert buy/sell interest rate into base/contra
	IF (p_buy_ccy = p_base_ccy) THEN
	    p_base_rate := p_buy_int_rate;
	    p_contra_rate := p_sell_int_rate;
	ELSE
	    p_base_rate := p_sell_int_rate;
	    p_contra_rate := p_buy_int_rate;
	END IF;

        IF (g_proc_level>=g_debug_level) THEN
           XTR_RISK_DEBUG_PKG.dlog('fv_fxo: ' || 'base ccy int rate: '||p_base_rate);
           XTR_RISK_DEBUG_PKG.dlog('fv_fxo: ' || 'contra ccy int rate: '||p_contra_rate);
        END IF;

	-- convert to continuously compounded rates
	p_conv_in.p_start_date := p_spot_date;
	p_conv_in.p_end_date := p_future_date;
	p_conv_in.p_day_count_basis_out := p_day_count_basis;
	p_conv_in.p_rate_type_in := 'S';
	p_conv_in.p_rate_type_out := 'C';
	p_conv_in.p_rate_in := p_base_rate;
	XTR_RATE_CONVERSION.rate_conversion(p_conv_in, p_conv_out);
	p_base_rate := p_conv_out.p_rate_out;
	p_conv_in.p_rate_in := p_contra_rate;
	XTR_RATE_CONVERSION.rate_conversion(p_conv_in, p_conv_out);
	p_contra_rate := p_conv_out.p_rate_out;

        IF (g_proc_level>=g_debug_level) THEN
           XTR_RISK_DEBUG_PKG.dlog('fv_fxo: ' || 'base ccy compounded int rate: '||p_base_rate);
           XTR_RISK_DEBUG_PKG.dlog('fv_fxo: ' || 'contra ccy compounded int rate: '||p_contra_rate);
        END IF;

	-- get fx spot rate
	IF (p_sell_ccy = p_base_ccy) THEN
	    p_side := 'B';
	ELSE
	    p_side := 'A';
	END IF;
	p_md_in.p_indicator := 'S';
        -- want spot rate in for_ccy/dom_ccy form
	IF (p_for_ccy = p_base_ccy) THEN
	   p_md_in.p_ccy := p_base_ccy;
	   p_md_in.p_contra_ccy := p_contra_ccy;
	   p_dom_ccy := p_contra_ccy;
	   p_strike := p_strike_price;
	ELSE
	   p_md_in.p_ccy := p_contra_ccy;
	   p_md_in.p_contra_ccy := p_base_ccy;
	   p_dom_ccy := p_base_ccy;
	   p_strike := 1/p_strike_price;
	END IF;
	p_md_in.p_side := p_side;
	XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
	p_spot_rate := p_md_out.p_md_out;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_fxo: ' || 'strike price: '||p_strike);
	   XTR_RISK_DEBUG_PKG.dlog('fv_fxo: ' || 'fx spot rate: '||p_spot_rate);
	END IF;

	-- Garman Kohlhagen
	p_fx_in.p_spot_date := p_spot_date;
	p_fx_in.p_maturity_date := p_future_date;
	IF (p_for_ccy = p_base_ccy) THEN
	  p_fx_in.p_rate_for := p_base_rate;
	  p_fx_in.p_rate_dom := p_contra_rate;
	ELSE
	  p_fx_in.p_rate_for := p_contra_rate;
	  p_fx_in.p_rate_dom := p_base_rate;
	END IF;

	p_fx_in.p_day_count_basis_dom := p_day_count_basis;
	p_fx_in.p_rate_type_dom := 'C';
	p_fx_in.p_rate_type_for := 'C';
	--p_fx_in.p_rate_for := p_base_rate;
	p_fx_in.p_day_count_basis_for := p_day_count_basis;
	p_fx_in.p_spot_rate := p_spot_rate;
	p_fx_in.p_strike_rate := p_strike;
	p_fx_in.p_volatility := p_volatility;

	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_fxo: ' || 'GK rate foreign: '||p_fx_in.p_rate_for);
	   XTR_RISK_DEBUG_PKG.dlog('fv_fxo: ' || 'GK rate domestic: '||p_fx_in.p_rate_dom);
	   XTR_RISK_DEBUG_PKG.dlog('fv_fxo: ' || 'GK spot rate: '||p_fx_in.p_spot_rate);
	   XTR_RISK_DEBUG_PKG.dlog('fv_fxo: ' || 'GK strike rate: '||p_fx_in.p_strike_rate);
	   XTR_RISK_DEBUG_PKG.dlog('fv_fxo: ' || 'GK volatility: '||p_fx_in.p_volatility);
	END IF;

	XTR_FX_FORMULAS.fx_gk_option_price_cv(p_fx_in, p_fx_out);
  	p_call_price  := p_fx_out.p_CALL_PRICE;
  	p_put_price   := p_fx_out.p_PUT_PRICE;
        p_forward_rate := p_fx_out.p_fx_fwd_rate;
	IF (p_for_ccy <> p_base_ccy) THEN
	   p_forward_rate := 1/p_forward_rate;
	END IF;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_fxo: ' || 'garman kohlhagen fwd rate: '||p_forward_rate);
	   XTR_RISK_DEBUG_PKG.dlog('fv_fxo: ' || 'call price: '||p_call_price);
	   XTR_RISK_DEBUG_PKG.dlog('fv_fxo: ' || 'put price: '||p_put_price);
	END IF;

	-- calculate fair value, which is call/put_price * base amount
	-- in deal contra ccy (domestic ccy);
	IF (p_option_type = 'C') THEN
	    p_fair_value := p_call_price * ABS(p_for_amount);
	ELSIF (p_option_type = 'P') THEN
	    p_fair_value := p_put_price * ABS(p_for_amount);
	ELSE
		RAISE_APPLICATION_ERROR(-20001,'p_option_type must be CALL or PUT');
	END IF;

	-- convert to premium ccy
	IF (p_dom_ccy <> p_premium_ccy) THEN
	   -- then base currency is premium ccy
	   p_fair_value := p_fair_value / p_spot_rate;
	END IF;

	IF (p_deal_subtype = 'SELL') THEN
	    p_fair_value := p_fair_value * (-1);
	END IF;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_fxo: ' || 'FAIR VALUE: '||p_fair_value);
	END IF;
    END IF;
IF (g_proc_level>=g_debug_level) THEN
   XTR_RISK_DEBUG_PKG.dpop(null,'QRM_FX_FROMULAS.fv_fxo');
END IF;
END fv_fxo;


-- returns fair value in contra currency
PROCEDURE fv_fx (p_price_model		IN	VARCHAR2,
		p_set_code		IN	VARCHAR2,
		p_buy_ccy		IN	VARCHAR2,
		p_sell_ccy		IN	VARCHAR2,
		p_sob_ccy		IN	VARCHAR2,
		p_interpolation_method	IN	VARCHAR2,
		p_spot_date		IN	DATE,
		p_future_date		IN	DATE,
		p_buy_amount		IN	NUMBER,
		p_sell_amount		IN	NUMBER,
		p_side			IN	OUT NOCOPY	VARCHAR2,
		p_forward_rate		IN	OUT NOCOPY 	NUMBER,
		p_fair_value		IN	OUT NOCOPY	NUMBER)  IS

	p_base_ccy 	VARCHAR2(15);
	p_contra_ccy	VARCHAR2(15);
	p_base_side	VARCHAR2(5);
	p_contra_side	VARCHAR2(5);
	p_spot_side	VARCHAR2(5);
	p_dummy_varchar	VARCHAR2(15);
	p_day_count_basis VARCHAR2(15) := '30/';

	p_buf			NUMBER;
	p_base_amt		NUMBER;
	p_contra_amt		NUMBER;
	p_spot_rate		NUMBER;
	p_base_yield_rate	NUMBER;
	p_contra_yield_rate	NUMBER;
	p_num_days		NUMBER;
	p_year_basis		NUMBER;
	p_sob_spot_rate		NUMBER;
	p_sob_yield_rate	NUMBER;
	p_sob_forward_rate	NUMBER;

	p_reverse	BOOLEAN;

	p_md_in    XTR_MARKET_DATA_P.md_from_set_in_rec_type;
	p_md_out   XTR_MARKET_DATA_P.md_from_set_out_rec_type;
	p_mm_in    XTR_MM_COVERS.presentValue_in_rec_type;
	p_mm_out   XTR_MM_COVERS.presentValue_out_rec_type;

BEGIN
IF (g_proc_level>=g_debug_level) THEN
   XTR_RISK_DEBUG_PKG.dpush(null,'QRM_FX_FROMULAS.FV_FX');
END IF;
    IF (p_price_model = 'FX_FORWARD') THEN
	p_base_amt := ABS(p_buy_amount);
	p_contra_amt := ABS(p_sell_amount);
	p_base_ccy := p_buy_ccy;
	p_contra_ccy := p_sell_ccy;
	get_base_contra(p_base_ccy, p_contra_ccy, p_reverse);
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_fx: ' || 'base ccy: ' || p_base_ccy);
	   XTR_RISK_DEBUG_PKG.dlog('fv_fx: ' || 'contra ccy: ' || p_contra_ccy);
	END IF;
	-- set p_side depend on ask or bid
	-- also set amount to negative if appropriate
 	IF (p_reverse = TRUE) THEN
    	    p_buf := p_base_amt;
    	    p_base_amt := -p_contra_amt;
    	    p_contra_amt := p_buf;
    	    p_side := 'B';
  	ELSE
    	    p_side := 'A';
    	    p_contra_amt := -p_contra_amt;
  	END IF;

	/*  determine FX rates using 'FX Forward' price model  */
 	 XTR_CALC_P.calc_days_run_c(p_spot_date, p_future_date,
   	p_day_count_basis, null, p_num_days, p_year_basis);
  	IF (p_side = 'B') THEN
    	    p_spot_side := 'B';
    	    p_contra_side := 'B';
    	    p_base_side := 'A';
  	ELSIF (p_side = 'A') then
    	    p_spot_side := 'A';
    	    p_contra_side := 'A';
    	    p_base_side := 'B';
  	ELSE
    	    p_spot_side := 'M';
    	    p_contra_side := 'M';
    	    p_base_side := 'M';
  	END IF;

	-- get spot rate
	p_md_in.p_md_set_code := p_set_code;
	p_md_in.p_source := 'C';
	p_md_in.p_indicator := 'S';
	p_md_in.p_spot_date := p_spot_date;
	p_md_in.p_future_date := p_future_date;
	p_md_in.p_ccy := p_base_ccy;
	p_md_in.p_contra_ccy := p_contra_ccy;
	p_md_in.p_day_count_basis_out := p_day_count_basis;
	p_md_in.p_interpolation_method := p_interpolation_method;
	p_md_in.p_side := p_spot_side;
	p_md_in.p_batch_id := null;
	p_md_in.p_bond_code := null;
	XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
  	p_spot_rate := p_md_out.p_md_out;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_fx: ' || 'spot rate: ' || p_spot_rate);
	END IF;

	-- get base ccy interest rate
	p_md_in.p_indicator := 'Y';
	p_md_in.p_side := p_base_side;
	XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
  	p_base_yield_rate := p_md_out.p_md_out;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_fx: ' || 'base int rate: ' || p_base_yield_rate);
	END IF;

	-- get contra ccy interest rate
	p_md_in.p_ccy := p_contra_ccy;
	p_md_in.p_side := p_contra_side;
	XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
  	p_contra_yield_rate := p_md_out.p_md_out;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_fx: ' || 'contra int rate: ' || p_contra_yield_rate);
	END IF;

	-- get fx forward rate (immature deal)
	XTR_FX_FORMULAS.fx_forward_rate(p_spot_rate, p_base_yield_rate,
	    p_contra_yield_rate, p_num_days, p_num_days, p_year_basis,
            p_year_basis,p_forward_rate);
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_fx: ' || 'forward rate: ' || p_forward_rate);
	   XTR_RISK_DEBUG_PKG.dlog('fv_fx: ' || 'contra amt: '||p_contra_amt);
	   XTR_RISK_DEBUG_PKG.dlog('fv_fx: ' || 'base amt: '||p_base_amt);
	END IF;

	-- calculate undiscounted fair value in contra currency
	p_fair_value := p_base_amt * p_forward_rate + p_contra_amt;
 	IF (g_proc_level>=g_debug_level) THEN
 	   XTR_RISK_DEBUG_PKG.dlog('fv_fx: ' || 'undiscounted fair value in contra ccy: '||p_fair_value);
 	END IF;


	IF (p_contra_ccy <> p_sob_ccy) THEN
	   -- calculate sob yield rate
	   p_md_in.p_indicator := 'Y';
	   p_md_in.p_ccy := p_sob_ccy;
	   p_side := 'M';
	   XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
	   p_sob_yield_rate := p_md_out.p_md_out;
	   IF (g_proc_level>=g_debug_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('fv_fx: ' || 'sob yield rate: '||p_sob_yield_rate);
	   END IF;

           -- calculate fx spot rate from contra to sob ccy
           p_md_in.p_indicator := 'S';
           p_md_in.p_side := 'M';
           p_md_in.p_ccy := p_contra_ccy;
           p_md_in.p_contra_ccy := p_sob_ccy;
           XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
           p_sob_spot_rate := p_md_out.p_md_out;
           IF (g_proc_level>=g_debug_level) THEN
              XTR_RISK_DEBUG_PKG.dlog('fv_fx: ' || 'sob spot rate: '||p_sob_spot_rate);
           END IF;

	   -- calculate fx forward rate from contra to sob ccy
	   XTR_FX_FORMULAS.fx_forward_rate(p_sob_spot_rate,
		p_contra_yield_rate, p_sob_yield_rate, p_num_days,
		p_num_days, p_year_basis, p_year_basis, p_sob_forward_rate);
	   IF (g_proc_level>=g_debug_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('fv_fx: ' || 'sob forward rate: '||p_sob_forward_rate);
	   END IF;
	ELSE
	   p_sob_forward_rate := 1;
	   p_sob_yield_rate := p_contra_yield_rate;
	END IF;

	-- calculate fair value in sob ccy (undiscounted)
	p_fair_value := p_fair_value * p_sob_forward_rate;
	   IF (g_proc_level>=g_debug_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('fv_fx: ' || 'undiscounted fair value in sob ccy:' ||p_fair_value);
	   XTR_RISK_DEBUG_PKG.dlog('fv_fx: ' || 'sob discount rate: '||p_sob_yield_rate);
	END IF;
	-- discount fair value to spot date
	p_mm_in.p_indicator := 'Y';
	p_mm_in.p_future_val := p_fair_value;
	p_mm_in.p_rate := p_sob_yield_rate;
	p_mm_in.p_pv_date := p_spot_date;
	p_mm_in.p_fv_date := p_future_date;
	p_mm_in.p_day_count_basis := p_day_count_basis;
	IF (QRM_MM_FORMULAS.within_one_year(p_spot_date, p_future_date)) THEN
	   p_mm_in.p_rate_type := 'S';
	ELSE
	   p_mm_in.p_rate_type := 'P';
	   p_mm_in.p_compound_freq := 1;
	END IF;
	XTR_MM_COVERS.present_value(p_mm_in, p_mm_out);
     	p_fair_value := p_mm_out.P_PRESENT_VAL;
    END IF;
IF (g_proc_level>=g_debug_level) THEN
   XTR_RISK_DEBUG_PKG.dpop(null,'QRM_FX_FROMULAS.FV_FX');
END IF;
END fv_fx;


END QRM_FX_FORMULAS;

/
