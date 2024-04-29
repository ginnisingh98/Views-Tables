--------------------------------------------------------
--  DDL for Package Body QRM_MM_FORMULAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QRM_MM_FORMULAS" AS
/* $Header: qrmmmflb.pls 120.14 2004/07/02 16:18:37 jhung ship $ */

/*--------------------------------------------------------------------------
  BLACK_OPTION_SENS Calculates sensitivities of the interest rate option price using Blacks Formula.(Hull's 4th Edition p.540)

black_opt_sens_in_rec_typ:
  IN:
	p_PRINCIPAL num
p_STRIKE_RATE num
p_IR_SHORT num
p_RATE_TYPE_SHORT varchar2 DEFAULT 'S'
p_COMPOUND_FREQ_SHORT num
p_DAY_COUNT_BASIS_SHORT varchar2
p_IR_LONG num
p_RATE_TYPE_LONG varchar2 DEFAULT 'S'
p_COMPOUND_FREQ_LONG num
p_DAY_COUNT_BASIS_LONG varchar2
p_SPOT_DATE date
p_START_DATE date
p_MATURITY_DATE date
p_VOLATILITY num

  IN:  P_PRINCIPAL num
       P_INT_RATE num
       P_FORWARD_RATE num
       P_SPOT_RATE num
       P_T1 num
       P_T2 num
       P_T2_INT_RATE num
       P_VOLATILITY num
black_opt_sens_out_rec_typ:
  OUT: P_DELTA_CALL num
       P_DELTA_PUT  num
       P_THETA_CALL num
       P_THETA_PUT num
       P_RHO_CALL num
       P_RHO_PUT  num
       P_GAMMA    num
       P_VEGA	  num

Assumption: Annual Basis = 360
            Continuous interest rate is required

Call XTR_RATE_CONVERSION.rate_conversion to convert day counts and/or between compounded and simple interest rates.

Calls XTR_MM_FORMULAS.black_option_price to get cumulative normal distribution
figures.

Note: All rates (not spot) are assumed to be in percentage form.  Eg: interest rate of 0.08 should be inputted as 8.

P_PRINCIPAL = the principal amount from which the interest rate is calculated
P_INT_RATE = strike price = simple interest rate for the deal
P_FORWARD_RATE = market forward rate for the period of the deal
P_SPOT_RATE = spote rate from revaluation date to start/reset date
P_T1 = number of days to the start date when the deal becomes effective.
P_T2 = number of days to the end date when the deal matures
p_T2_INT_RATE = current interest rate until the maturity date
P_VOLATILITY = volatility of interest rate per annum

P_DELTA_CALL = delta call
P_DELTA_PUT = delta put
P_THETA_CALL = theta call
P_THETA_PUT = theta put
P_RHO_CALL = rho call
P_RHO_PUT = rho put
P_GAMMA = gamma
P_VEGA = vega

--------------------------------------------------------------------------*/
--Addition by fhu 6/19/01

PROCEDURE black_option_sens(p_in_rec  IN  black_opt_sens_in_rec_type,
                             p_out_rec IN OUT NOCOPY black_opt_sens_out_rec_type) is
	v_n_d1 number;
	v_n_d2 number;
	v_n_d1_a number;
	v_n_d2_a number;

	-- spot rate from spot to start date
	v_spot 	    	NUMBER := p_in_rec.p_ir_short/100;
        v_day_count 	NUMBER;
        v_annual_basis	NUMBER;
	v_t1	    	NUMBER; -- no of days from spot to start date
        v_forward   	NUMBER;
	-- strike rate
	v_ir        	NUMBER := p_in_rec.p_strike_rate/100;
	v_vol       	NUMBER := p_in_rec.p_volatility/100;

	black_opt_price_in  XTR_MM_COVERS.black_opt_cv_in_rec_type;
	black_opt_price_out XTR_MM_COVERS.black_opt_cv_out_rec_type;
  	conv_in		    XTR_RATE_CONVERSION.rate_conv_in_rec_type;
	conv_out	    XTR_RATE_CONVERSION.rate_conv_out_rec_type;

BEGIN

  IF (g_proc_level>=g_debug_level) THEN --bug 3236479
     xtr_risk_debug_pkg.dpush(null,'QRM_MM_FORMULAS.BLACK_OPTION_SENS');
  END IF;

  IF (v_vol = 0) THEN
      raise e_option_vol_zero;
  END IF;

  black_opt_price_in.p_principal := p_in_rec.p_principal;
  black_opt_price_in.p_strike_rate := p_in_rec.p_strike_rate;
  black_opt_price_in.p_rate_type_strike := p_in_rec.p_rate_type_strike;
  black_opt_price_in.p_compound_freq_strike := p_in_rec.p_compound_freq_strike;
  black_opt_price_in.p_day_count_basis_strike := p_in_rec.p_day_count_basis_strike;
  black_opt_price_in.p_ir_short := p_in_rec.p_ir_short;
  black_opt_price_in.p_rate_type_short := p_in_rec.p_rate_type_short;
  black_opt_price_in.p_compound_freq_short := p_in_rec.p_compound_freq_short;
  black_opt_price_in.p_day_count_basis_short := p_in_rec.p_day_count_basis_short;
  black_opt_price_in.p_ir_long := p_in_rec.p_ir_long;
  black_opt_price_in.p_rate_type_long := p_in_rec.p_rate_type_long;
  black_opt_price_in.p_compound_freq_long := p_in_rec.p_compound_freq_long;
  black_opt_price_in.p_day_count_basis_long := p_in_rec.p_day_count_basis_long;
  black_opt_price_in.p_spot_date := p_in_rec.p_spot_date;
  black_opt_price_in.p_start_date := p_in_rec.p_start_date;
  black_opt_price_in.p_maturity_date := p_in_rec.p_maturity_date;
  black_opt_price_in.p_volatility := p_in_rec.p_volatility;

  -- Call XTR_MM_FORMULAS.black_option_price
  XTR_MM_COVERS.black_option_price_cv(black_opt_price_in,
					black_opt_price_out);
  v_n_d1 := black_opt_price_out.p_nd1;
  v_n_d2 := black_opt_price_out.p_nd2;
  v_n_d1_a := black_opt_price_out.p_nd1_a;
  v_n_d2_a := black_opt_price_out.p_nd2_a;
  v_forward := black_opt_price_out.p_forward_forward_rate/100;

  -- calculate t1: number of days from spot to start date
  -- day count basis is Actual/365   -- bug 3611158
  XTR_CALC_P.calc_days_run_c(p_in_rec.p_spot_date, p_in_rec.p_start_date, 'ACTUAL365', null, v_day_count, v_annual_basis);
  v_t1 := v_day_count/365;

  -- convert v_spot to continously compounded, Actual/365 day count basis
  IF NOT (p_in_rec.p_rate_type_short IN ('C','c') AND
        p_in_rec.p_day_count_basis_short = 'ACTUAL365') THEN
    conv_in.p_start_date := p_in_rec.p_spot_date;
    conv_in.p_end_date := p_in_rec.p_start_date;
     conv_in.p_day_count_basis_in := p_in_rec.p_day_count_basis_short;
    conv_in.p_day_count_basis_out := 'ACTUAL365';
    conv_in.p_rate_type_in := p_in_rec.p_rate_type_short;
    conv_in.p_rate_type_out := 'C';
    conv_in.p_compound_freq_in := p_in_rec.p_compound_freq_short;
    conv_in.p_rate_in := p_in_rec.p_ir_short;
    XTR_RATE_CONVERSION.rate_conversion(conv_in,conv_out);
    v_spot := conv_out.p_rate_out/100;
  END IF;

  -- convert strike rate to simple Actual/365 day count basis
  IF NOT (p_in_rec.p_rate_type_strike IN ('S','s') AND
        p_in_rec.p_day_count_basis_strike = 'ACTUAL365') THEN
    conv_in.p_start_date := p_in_rec.p_start_date;
    conv_in.p_end_date := p_in_rec.p_maturity_date;
    conv_in.p_day_count_basis_in := p_in_rec.p_day_count_basis_strike;
    conv_in.p_day_count_basis_out := 'ACTUAL365';
    conv_in.p_rate_type_in := p_in_rec.p_rate_type_strike;
    conv_in.p_rate_type_out := 'S';
    conv_in.p_compound_freq_in := p_in_rec.p_compound_freq_strike;
    conv_in.p_rate_in := p_in_rec.p_strike_rate;
    XTR_RATE_CONVERSION.rate_conversion(conv_in,conv_out);
    v_ir := conv_out.p_rate_out/100;
  END IF;

  IF (g_proc_level>=g_debug_level) THEN
     XTR_RISK_DEBUG_PKG.dlog('black_option_sens: ' || 'spot rate: '||v_spot);
     XTR_RISK_DEBUG_PKG.dlog('black_option_sens: ' || 't1: '||v_t1);
     XTR_RISK_DEBUG_PKG.dlog('black_option_sens: ' || 'N(d1): '||v_n_d1);
     XTR_RISK_DEBUG_PKG.dlog('black_option_sens: ' || 'forward: '||v_forward);
     XTR_RISK_DEBUG_PKG.dlog('black_option_sens: ' || 'N(d2): '||v_n_d2);
     XTR_RISK_DEBUG_PKG.dlog('black_option_sens: ' || 'N''(d1): '||v_n_d1_a);
     XTR_RISK_DEBUG_PKG.dlog('black_option_sens: ' || 'strike rate: '||v_ir);
  END IF;

  -- sensitivities calculation
  p_out_rec.p_delta_cap := EXP(-v_spot*v_t1)*v_n_d1;
  p_out_rec.p_delta_floor := EXP(-v_spot*v_t1)*(v_n_d1-1);

  p_out_rec.p_theta_cap := -(v_forward*v_n_d1_a*v_vol*EXP(-v_spot*v_t1))/
		(2*SQRT(v_t1)) + v_spot*v_forward*v_n_d1*EXP(-v_spot*v_t1) -
		v_spot*v_ir*EXP(-v_spot*v_t1)*v_n_d2;
  p_out_rec.p_theta_floor := -(v_forward*v_n_d1_a*v_vol*EXP(-v_spot*v_t1))/
		(2*SQRT(v_t1)) - v_spot*v_forward*(1-v_n_d1)*EXP(-v_spot*v_t1)
 		+ v_spot*v_ir*EXP(-v_spot*v_t1)*(1-v_n_d2);

  p_out_rec.p_rho_cap := v_ir*v_t1*EXP(-v_spot*v_t1)*v_n_d2;
  p_out_rec.p_rho_floor := -v_ir*v_t1*EXP(-v_spot*v_t1)*(1-v_n_d2);

  p_out_rec.p_gamma := (v_n_d1_a*EXP(-v_spot*v_t1))/(v_forward*v_vol*SQRT(v_t1));
  p_out_rec.p_vega := v_forward*SQRT(v_t1)*v_n_d1_a*EXP(-v_spot*v_t1);

  IF (g_proc_level>=g_debug_level) THEN --bug 3236479
     xtr_risk_debug_pkg.dpop(null,'QRM_MM_FORMULAS.BLACK_OPTION_SENS');
  END IF;

END black_option_sens;

--########################################################################
--#								         #
--#			Functions				         #
--#								         #
--########################################################################

-- addition by fhu 6/13/01
/*
Calculates DURATION of the following instruments:
	- bond
	- discounted securities
	- forward rate agreement
	- wholesale term money
	- interest rate swap
as specified in: Robert Steiner, Mastering Financial Calculations, p.108

The arguments are defined as follows:
	- p_pvc_array = contains present values stored in xtr_num_table;
			value at index k corresponds to present value of kth
			cashflow; = null for discounted securities and FRA;
			k = 1,2,3,...
	- p_days_array = number of days until kth cashflow; each kth element
			corresponds to kth present value; for discounted
			securities and FRA, array contains only one element
			representing days to maturity
	- p_days_in_year = number of days in a year
*/

FUNCTION duration(p_pvc_array IN XTR_MD_NUM_TABLE,
                  p_days_array IN XTR_MD_NUM_TABLE,
                  p_days_in_year IN NUMBER)
	RETURN NUMBER IS

	p_num_sum NUMBER := 0;
	p_denom_sum NUMBER := 0;

BEGIN

  IF (g_proc_level>=g_debug_level) THEN --bug 3236479
     xtr_risk_debug_pkg.dpush(null,'QRM_MM_FORMULAS.DURATION');
  END IF;

	-- fra or ni calculation if p_pvc_array is null
	if (p_pvc_array is null) then
		RETURN p_days_array(1)/p_days_in_year;
	-- otherwise, if arrays not the same size, arguments are incorrect
	elsif (p_pvc_array.count <> p_days_array.count
		and p_pvc_array is not null) then
		-- exception handling here
		RAISE_APPLICATION_ERROR
        		(-20001,'Arrays must be the same size.');
	elsif (p_days_in_year = 0)then
		RAISE_APPLICATION_ERROR
        	(-20001,'Cannot have 0 days in a year.');
	-- arrays are same size, p_days_in_year is positive
	else
		for i IN 1..p_pvc_array.count
		LOOP
			p_num_sum := p_num_sum
				+ p_pvc_array(i)*p_days_array(i)/p_days_in_year;
			p_denom_sum := p_denom_sum + p_pvc_array(i);
		END LOOP;
		-- now divide the numerator and denominator
		-- this is the value to return
		RETURN p_num_sum/p_denom_sum;
	end if;

  IF (g_proc_level>=g_debug_level) THEN --bug 3236479
     xtr_risk_debug_pkg.dpop(null,'QRM_MM_FORMULAS.DURATION');
  END IF;

END duration;


-- addition by fhu 6/13/01
/*
Calculates MODIFIED DURATION of the following instruments:
	- bond
	- discounted securities
	- interest rate swap

as specified in: Robert Steiner, Mastering Financial Calculations, p.110

The arguments are defined as follows:
	- p_duration = duration of instrument
	- p_yield = if bond, is yield per annum based on p_num_payments per
			year (YTM);  if discounted security, is yield rate;
			if interest rate swap, is internal rate of return (IRR)
	- p_num_payments = number of payments per year; if discounted security,
			value = 1

Note: yield rate is assumed to be in percentage form.
*/

FUNCTION mod_duration(p_duration IN NUMBER,
		      p_yield IN NUMBER,
		      p_num_payments IN NUMBER)
	RETURN NUMBER IS

	p_yld number := p_yield/100;

BEGIN

  IF (g_proc_level>=g_debug_level) THEN --bug 3236479
     xtr_risk_debug_pkg.dpush(null,'QRM_MM_FORMULAS.MOD_DURATION');
  END IF;

	if (p_num_payments = 0) then
		RAISE_APPLICATION_ERROR
        	(-20001,'Cannot have 0 payments per year.');
	else
		RETURN p_duration/(1 + p_yld/p_num_payments);
	end if;

  IF (g_proc_level>=g_debug_level) THEN --bug 3236479
     xtr_risk_debug_pkg.dpop(null,'QRM_MM_FORMULAS.MOD_DURATION');
  END IF;

END mod_duration;


-- addition by fhu 6/13/01
/*
Calculates BOND CONVEXITY as specified in: Robert Steiner, Mastering Financial Calculations, p.112

The arguments are defined as follows:
	- p_cf_array = cashflows stored in xtr_md_num_table; value at index k
		      	corresponds to kth cashflow; k = 1,2,3,...
	- p_days_array = number of days until kth cashflow, stored in
			xtr_md_num_table; each kth element correspons to kth
			cashflow; k = 1,2,3,...
	- p_num_payments = number of payments per year
	- p_yield = yield per annum based on p_num_payments per year (YTM)
	- p_days_in_year = number of days in year
	- p_dirty_price = dirty price of bond

Note: yield rate is assumed to be in percentage form.
*/

FUNCTION bond_convexity(p_cf_array IN XTR_MD_NUM_TABLE,
			p_days_array IN XTR_MD_NUM_TABLE,
			p_num_payments IN NUMBER,
			p_yield IN NUMBER,
			p_days_in_year IN NUMBER,
			p_dirty_price IN NUMBER)
	RETURN NUMBER IS

	p_num_sum NUMBER := 0;
	p_yld NUMBER := p_yield/100;

BEGIN
  IF (g_proc_level>=g_debug_level) THEN --bug 3236479
     xtr_risk_debug_pkg.dpush(null,'QRM_MM_FORMULAS.BOND_CONVEXITY');
  END IF;
	-- arrays should be the same size
	if (p_cf_array.count <> p_days_array.count) then
		-- do exception handling here
		RAISE_APPLICATION_ERROR
        	(-20001,'Arrays must be the same size.');
	elsif (p_dirty_price = 0) then
		RAISE_APPLICATION_ERROR
        	(-20001,'Dirty price cannot equal 0.');
	elsif (p_days_in_year = 0) then
		RAISE_APPLICATION_ERROR
        	(-20001,'Cannot have 0 days in a year.');
	else
		-- calculate numerator
		FOR i IN 1..p_cf_array.count
		  LOOP
			p_num_sum := p_num_sum +
				p_cf_array(i)/(1 + p_yld/p_num_payments)**(p_num_payments*p_days_array(i)/p_days_in_year + 2)*(p_days_array(i)/p_days_in_year)*(p_days_array(i)/p_days_in_year + 1/p_num_payments);
--modified from - to + above
		  END LOOP;
		--  now divide numerator and denominator
		XTR_RISK_DEBUG_PKG.dlog('convexity before 100: '||p_num_sum/p_dirty_price);
		IF (g_proc_level>=g_debug_level) THEN --bug 3236479
                   xtr_risk_debug_pkg.dpop(null,'QRM_MM_FORMULAS.BOND_CONVEXITY');
  		END IF;
		RETURN p_num_sum/p_dirty_price;
	end if;
END bond_convexity;


-- addition by fhu 6/13/01
/*
Calculates DELTA/DOLLAR DURATION,given modified duration, of the following
instruments:
	- bond
	- discounted security
as specified in: Robert Steiner, Mastering Financial Calculations, p.110

The arguments are defined as follows:
	- p_OUT = 'DELTA' if output is to be delta, 'DOLLAR' if value is to be
		  dollar duration
	- p_dirty_price = dirty price of bond
	- p_mod_duration = modified duration

Note: a delta yield of 1% (0.01) is assumed for sensitivities calculations
*/


FUNCTION delta_md(p_out IN VARCHAR2,
	          p_dirty_price IN NUMBER,
	          p_mod_duration IN NUMBER)
	RETURN NUMBER IS

	p_delta_yield NUMBER := 0.01;
BEGIN
  IF (g_proc_level>=g_debug_level) THEN --bug 3236479
     xtr_risk_debug_pkg.dpush(null,'QRM_MM_FORMULAS.DELTA_MD');
  END IF;
	if (p_out = 'DELTA') then
		RETURN -1 * p_dirty_price * p_delta_yield * p_mod_duration;
	elsif (p_out = 'DOLLAR') then
		RETURN p_dirty_price * p_delta_yield * p_mod_duration;
	else
		RAISE_APPLICATION_ERROR
        		(-20001,'p_OUT must be ''DELTA'' or ''DOLLAR''.');
	end if;
  IF (g_proc_level>=g_debug_level) THEN --bug 3236479
     xtr_risk_debug_pkg.dpop(null,'QRM_MM_FORMULAS.DELTA_MD');
  END IF;
END delta_md;

-- addition by fhu 6/13/01
/*
Calculates DELTA/DOLLAR DURATION of a bond, given bond convexity, as specified
in: Robert Steiner, Mastering Financial Calculations, p.112

The arguments are defined as follows:
	- p_out = 'DELTA' if p_VALUE is to be delta, 'DOLLAR' if is to be
		  dollar duration
	- p_dirty_price = dirty price of bond
	- p_mod_duration = modified duration of bond
	- p_convexity = convexity of bond

Note: a delta yield of 1% (0.01) is assumed for sensitivities calculations
*/

FUNCTION bond_delta_convexity(p_out IN VARCHAR2,
			      p_dirty_price IN NUMBER,
			      p_mod_duration IN NUMBER,
			      p_convexity IN NUMBER)
	RETURN NUMBER IS
	p_delta_yield NUMBER := 0.01;
BEGIN
	if (p_out = 'DELTA') then
		RETURN delta_md('DELTA', p_dirty_price, p_mod_duration) + (p_dirty_price/2)*p_convexity*(p_delta_yield)**2;
	elsif (p_out = 'DOLLAR') then
		RETURN -1 * (delta_md('DELTA', p_dirty_price, p_mod_duration) + (p_dirty_price/2)*p_convexity*(p_delta_yield)**2);
	else
		RAISE_APPLICATION_ERROR
        		(-20001,'p_OUT must be ''DELTA'' or ''DOLLAR''.');
	end if;
END bond_delta_convexity;


-- addition by fhu 6/13/01
/*
Calculates BPV(YR), or change in price due to a 1 basis point change in yield
rate, of discounted security or bond.  See Deal Calculations HLD.

The arguments are defined as follows:
	- p_dirty_price = dirty price of discounted security or bond
	- p_mod_duration = modified duration of discounted security or bond
*/

FUNCTION bpv_yr(p_dirty_price IN NUMBER,
		p_mod_duration IN NUMBER)
	RETURN NUMBER IS
BEGIN
	RETURN p_dirty_price*(0.0001)*p_mod_duration;

End bpv_yr;


-- addition by fhu 6/13/01
/*
Calculates BPV(DR), or change in price due to a 1 basis point change in
discount rate, of discounted security.  See Deal Calculations HLD.

The arguments are defined as follows:
	- p_principle = principle amount or face value
	- p_days_to_mat = days to maturity
	- p_days_in_year = days in year
*/

FUNCTION ni_bpv_dr(p_principle IN NUMBER,
		   p_days_to_mat IN NUMBER,
		   p_days_in_year IN NUMBER)
	RETURN NUMBER IS
BEGIN
	if (p_days_in_year = 0) then
		RAISE_APPLICATION_ERROR
        	(-20001,'Cannot have 0 days in a year.');
	else
		RETURN p_principle*(0.0001)*p_days_to_mat/p_days_in_year;
	end if;
END ni_bpv_dr;


-- addition by fhu 6/13/01
/*
Calculates DELTA/DOLLAR DURATION of discounted security, given BPV(YR) or
BPV(DR).  See Deal Calculations HLD.

The arguments are defined as follows:
	- p_out = 'DELTA' if output is to be delta, 'DOLLAR' if is to be
		  dollar duration
	- p_bpv = BPV(DR) or BPV(YR)
*/

FUNCTION ni_delta_bpv(p_out IN VARCHAR2,
		      p_bpv IN NUMBER)
	RETURN NUMBER IS
BEGIN
	if (p_out = 'DELTA') then
		RETURN -1*100*p_bpv;
	elsif (p_out = 'DOLLAR') then
		RETURN 100*p_bpv;
	else
		RAISE_APPLICATION_ERROR
        		(-20001,'p_OUT must be ''DELTA'' or ''DOLLAR''.');
	end if;
END ni_delta_bpv;
--added by sankim 8/8/01
/*
Calculates NI CONVEXITY or FRA CONVEXITY as specified in: Robert Steiner,
Mastering Financial
Calculations, p.112

The arguments are defined as follows:
	- p_num_days = number of days until cash flow occurs
                       i.e. number of days till maturity for NI or
                       number of days till settlement for FRA
	- p_rate = yield rate of discounted security or
                  settlement rate of FRA
	- p_days_in_year = number of days in year

Note:  rate is assumed to be in percentage form.
*/

FUNCTION ni_fra_convexity(	p_num_days IN NUMBER,
			p_rate IN NUMBER,
			p_days_in_year IN NUMBER)
	RETURN NUMBER IS

	v_n NUMBER;
        -- variable n as defined in the formula
	v_rate NUMBER := p_rate/100;
        v_result NUMBER;

BEGIN


  v_n:=  p_days_in_year/p_num_days;
  v_result:= (1/(1+v_rate/v_n)**2)*(p_num_days/p_days_in_year)*
             (p_num_days/p_days_in_year+1/v_n);
  RETURN v_result;

END ni_fra_convexity;

-- addition by fhu 6/13/01
/*
Calcuation of BPV for interest rate swaps (IRS), wholesale term money (TMM),
and forward rate agreement(FRA).
This call also be used to calculate the BPV of any instrument, given its fair
values.  See: Deal Calculations HLD, Deal Valuations HLD, FRA Calculator HLD.
Arguments defined as follows:
	- p_fair_value_base = fair value with regular yield curve/rate
	- p_fair_value_shifted = fair value with yield curve/rate shifted up
				one basis point
*/


-- addition by fhu 6/13/01
FUNCTION bpv(p_fair_value_base IN NUMBER,
		     p_fair_value_shifted IN NUMBER)
	RETURN NUMBER IS
BEGIN
	RETURN p_fair_value_shifted - p_fair_value_base;
         -- flipped shift and base by sankim 8/14/01
END bpv;


-- addition by jbrodsky 9/20/01
/*
Calculation of Implied Volatility using Bisection for Forward Exchange Options.

*/

FUNCTION calculate_implied_volatility(p_indicator IN VARCHAR2,
					p_spot_date IN DATE,
					p_expiration_date IN DATE,
					p_interest_rates IN XTR_MD_NUM_TABLE,
					p_day_count_basis IN SYSTEM.QRM_VARCHAR_TABLE,
					p_rate_type IN SYSTEM.QRM_VARCHAR_TABLE,
					p_compound_freq IN XTR_MD_NUM_TABLE,
					p_spot_rate IN NUMBER,
					p_strike_rate IN NUMBER,
					p_option_price IN NUMBER,
					p_option_type IN VARCHAR2,
					p_start_date IN DATE,
					p_principal IN NUMBER,
					p_error_tol IN NUMBER,
					p_max_iterations IN NUMBER,
					p_max_value IN NUMBER,
					p_vol_first_guess IN NUMBER)
	RETURN NUMBER IS



	v_vol_low NUMBER := 0.00001;
	v_vol_mid NUMBER;
	v_vol_high NUMBER := p_vol_first_guess;
	v_price NUMBER;
	v_count NUMBER;
	v_test NUMBER;
	fx_option_price_in  XTR_FX_FORMULAS.GK_OPTION_CV_IN_REC_TYPE;
	fx_option_price_out XTR_FX_FORMULAS.GK_OPTION_CV_OUT_REC_TYPE;
	iro_option_price_in  XTR_MM_COVERS.BLACK_OPT_CV_IN_REC_TYPE;
	iro_option_price_out XTR_MM_COVERS.BLACK_OPT_CV_OUT_REC_TYPE;

BEGIN
  IF (g_proc_level>=g_debug_level) THEN --bug 3236479
     xtr_risk_debug_pkg.dpush(null,'QRM_MM_FORMULAS.CALCULATE_IMPLIED_VOL');
  END IF;
	if (p_indicator='FXO') THEN
		fx_option_price_in.p_SPOT_DATE:= p_spot_date;
		fx_option_price_in.p_MATURITY_DATE := p_expiration_date;
		fx_option_price_in.p_RATE_DOM:=p_interest_rates(1);
		fx_option_price_in.p_RATE_TYPE_DOM:=p_rate_type(1);
		fx_option_price_in.p_COMPOUND_FREQ_DOM:= p_compound_freq(1);
		fx_option_price_in.p_DAY_COUNT_BASIS_DOM:=p_day_count_basis(1);
		fx_option_price_in.p_RATE_FOR:=p_interest_rates(2);
		fx_option_price_in.p_RATE_TYPE_FOR:=p_rate_type(2);
		fx_option_price_in.p_COMPOUND_FREQ_FOR:= p_compound_freq(2);
		fx_option_price_in.p_DAY_COUNT_BASIS_FOR:=p_day_count_basis(2);
		fx_option_price_in.p_SPOT_RATE:=p_spot_rate;
		fx_option_price_in.p_STRIKE_RATE:=p_strike_rate;
		fx_option_price_in.p_VOLATILITY:= v_vol_low;




		XTR_FX_FORMULAS.FX_GK_OPTION_PRICE_CV(fx_option_price_in, fx_option_price_out);

		if (p_option_type='C') THEN
			v_price:=fx_option_price_out.p_CALL_PRICE;
		elsif (p_option_type='P') THEN
			v_price:=fx_option_price_out.p_PUT_PRICE;
		end if;

	elsif (p_indicator='IRO') THEN
		iro_option_price_in.p_PRINCIPAL := p_principal;
		iro_option_price_in.p_STRIKE_RATE := p_interest_rates(1);
		iro_option_price_in.p_RATE_TYPE_STRIKE := p_rate_type(1);
		iro_option_price_in.p_COMPOUND_FREQ_STRIKE := p_compound_freq(1);
		iro_option_price_in.p_DAY_COUNT_BASIS_STRIKE := p_day_count_basis(1);
		iro_option_price_in.p_IR_SHORT:= p_interest_rates(2);
		iro_option_price_in.p_RATE_TYPE_SHORT := p_rate_type(2);
		iro_option_price_in.p_COMPOUND_FREQ_SHORT := p_compound_freq(2);
		iro_option_price_in.p_DAY_COUNT_BASIS_SHORT := p_day_count_basis(2);
		iro_option_price_in.p_IR_LONG:= p_interest_rates(3);
		iro_option_price_in.p_RATE_TYPE_LONG := p_rate_type(3);
		iro_option_price_in.p_COMPOUND_FREQ_LONG := p_compound_freq(3);
		iro_option_price_in.p_DAY_COUNT_BASIS_LONG := p_day_count_basis(3);
		iro_option_price_in.p_SPOT_DATE := p_spot_date;
		iro_option_price_in.p_START_DATE := p_start_date;
		iro_option_price_in.p_MATURITY_DATE := p_expiration_date;
		iro_option_price_in.p_VOLATILITY := v_vol_low;
		XTR_MM_COVERS.BLACK_OPTION_PRICE_CV(iro_option_price_in, iro_option_price_out);

		if (p_option_type='C') THEN
			v_price:=iro_option_price_out.p_CAPLET_PRICE;
		elsif (p_option_type='P') THEN
			v_price:=iro_option_price_out.p_FLOORLET_PRICE;
		end if;

	elsif (p_indicator='BS') THEN
	v_price:=-1;
	end if;


	if (v_price > p_option_price) THEN
		RETURN 0;
	end if;

	-- Binomial search
	if (p_indicator='FXO') THEN
		fx_option_price_in.p_VOLATILITY:= v_vol_high;

		XTR_FX_FORMULAS.FX_GK_OPTION_PRICE_CV(fx_option_price_in, fx_option_price_out);

		if (p_option_type='C') THEN
			v_price:=fx_option_price_out.p_CALL_PRICE;
		elsif (p_option_type='P') THEN
			v_price:=fx_option_price_out.p_PUT_PRICE;
		end if;

	elsif (p_indicator='IRO') THEN
		iro_option_price_in.p_VOLATILITY := v_vol_high;
		XTR_MM_COVERS.BLACK_OPTION_PRICE_CV(iro_option_price_in, iro_option_price_out);

		if (p_option_type='C') THEN
			v_price:=iro_option_price_out.p_CAPLET_PRICE;
		elsif (p_option_type='P') THEN
			v_price:=iro_option_price_out.p_FLOORLET_PRICE;
		end if;

	elsif (p_indicator='BS') THEN
	v_price:=-1;
	end if;

	WHILE (v_price < p_option_price) LOOP
		v_vol_high := 2 * v_vol_high;

		if (p_indicator='FXO') THEN
			fx_option_price_in.p_VOLATILITY:= v_vol_high;

			XTR_FX_FORMULAS.FX_GK_OPTION_PRICE_CV(fx_option_price_in, fx_option_price_out);

			if (p_option_type='C') THEN
				v_price:=fx_option_price_out.p_CALL_PRICE;
			elsif (p_option_type='P') THEN
				v_price:=fx_option_price_out.p_PUT_PRICE;
			end if;

		elsif (p_indicator='IRO') THEN
			iro_option_price_in.p_VOLATILITY := v_vol_high;
			XTR_MM_COVERS.BLACK_OPTION_PRICE_CV(iro_option_price_in, iro_option_price_out);

			if (p_option_type='C') THEN
				v_price:=iro_option_price_out.p_CAPLET_PRICE;
			elsif (p_option_type='P') THEN
				v_price:=iro_option_price_out.p_FLOORLET_PRICE;
			end if;

		elsif (p_indicator='BS') THEN
			v_price:=-1;
		end if;
		if (v_vol_high > p_max_value) THEN
			 FND_MESSAGE.SET_NAME('QRM','QRM_CALC_EXCEED_VOL_BOUND');
				raise e_exceed_vol_upper_bound;
		end if;
	END LOOP;
	FOR v_count in 0..p_max_iterations LOOP
		v_vol_mid := (v_vol_low + v_vol_high)/2;
		if (p_indicator='FXO') THEN
			fx_option_price_in.p_VOLATILITY:= v_vol_mid;

			XTR_FX_FORMULAS.FX_GK_OPTION_PRICE_CV(fx_option_price_in, fx_option_price_out);

			if (p_option_type='C') THEN
				v_price:=fx_option_price_out.p_CALL_PRICE;
			elsif (p_option_type='P') THEN
				v_price:=fx_option_price_out.p_PUT_PRICE;
			end if;

		elsif (p_indicator='IRO') THEN
			iro_option_price_in.p_VOLATILITY := v_vol_mid;
			XTR_MM_COVERS.BLACK_OPTION_PRICE_CV(iro_option_price_in, iro_option_price_out);

			if (p_option_type='C') THEN
				v_price:=iro_option_price_out.p_CAPLET_PRICE;
			elsif (p_option_type='P') THEN
				v_price:=iro_option_price_out.p_FLOORLET_PRICE;
			end if;

		elsif (p_indicator='BS') THEN
			v_price:=-1;
		end if;
		v_test := v_price - p_option_price;
		if (ABS(v_test) < p_error_tol) THEN
			RETURN v_vol_mid;
		end if;
		if (v_test<0) THEN
			v_vol_low:=v_vol_mid;
		else
			v_vol_high:= v_vol_mid;
		end if;
	END LOOP;
  IF (g_proc_level>=g_debug_level) THEN --bug 3236479
     xtr_risk_debug_pkg.dpop(null,'QRM_MM_FORMULAS.CALCULATE_IMPLIED_VOL');
  END IF;
END calculate_implied_volatility;


/*  Fair Value Calculations -- fhu 12/13/01 */


FUNCTION calculate_fwd_rate(	p_set_code		VARCHAR2,
				-- enter 'Y' add 1BP to underlying rates
				p_bpv			VARCHAR2, -- 'Y' or 'N'
				p_deal_subtype		VARCHAR2,
				p_day_count_basis	VARCHAR2,
				p_ccy			VARCHAR2,
				p_interpolation_method	VARCHAR2,
				p_spot_date		DATE,
				p_start_date		DATE,
				p_maturity_date		DATE)
	RETURN NUMBER IS

	p_side 		VARCHAR2(5);
	p_days1 	NUMBER;
	p_annual_basis  NUMBER;
	p_days2		NUMBER;
 	p_rate1		NUMBER;
	p_rate2		NUMBER;
	p_fwd_rate	NUMBER;
	p_md_in 	XTR_MARKET_DATA_P.md_from_set_in_rec_type;
	p_md_out 	XTR_MARKET_DATA_P.md_from_set_out_rec_type;
	p_mm_in		XTR_MM_COVERS.int_forw_rate_in_rec_type;
	p_mm_out	XTR_MM_COVERS.int_forw_rate_out_rec_type;


BEGIN
    IF (g_proc_level>=g_debug_level) THEN
       XTR_RISK_DEBUG_PKG.dpush(null,'QRM_MM_FORMULAS.calculate_fwd_rate');
    END IF;
    if p_deal_subtype in ('BUY', 'FUND', 'BCAP', 'SCAP') then
    	p_side := 'A';
    else
    	p_side := 'B';
    end if;


    -- get yield rate from spot to start date
    IF (g_proc_level>=g_debug_level) THEN
       XTR_RISK_DEBUG_PKG.dlog('calculate_fwd_rate: ' || 'spot date: '||p_spot_date);
       XTR_RISK_DEBUG_PKG.dlog('calculate_fwd_rate: ' || 'start date: '||p_start_date);
    END IF;
    XTR_CALC_P.calc_days_run_c(p_spot_date, p_start_date,
		p_day_count_basis, null, p_days1, p_annual_basis);
    p_md_in.p_md_set_code := p_set_code;
    p_md_in.p_source := 'C';
    p_md_in.p_indicator := 'Y';
    p_md_in.p_spot_date := p_spot_date;
    p_md_in.p_future_date := p_start_date;
    p_md_in.p_ccy := p_ccy;
    p_md_in.p_contra_ccy := NULL;
    p_md_in.p_day_count_basis_out := p_day_count_basis;
    p_md_in.p_interpolation_method := p_interpolation_method;
    p_md_in.p_side := p_side;
    p_md_in.p_batch_id := NULL;
    p_md_in.p_bond_code := NULL;
    IF (g_proc_level>=g_debug_level) THEN
       XTR_RISK_DEBUG_PKG.dlog('calculate_fwd_rate: ' || 'deal subtype: '||p_deal_subtype);
       XTR_RISK_DEBUG_PKG.dlog('calculate_fwd_rate: ' || 'set_code: '||p_set_code);
       XTR_RISK_DEBUG_PKG.dlog('calculate_fwd_rate: ' || 'spot date: '||p_spot_date);
       XTR_RISK_DEBUG_PKG.dlog('calculate_fwd_rate: ' || 'future date: '||p_start_date);
       XTR_RISK_DEBUG_PKG.dlog('calculate_fwd_rate: ' || 'ccy: '||p_ccy);
       XTR_RISK_DEBUG_PKG.dlog('calculate_fwd_rate: ' || 'day count basis: '||p_day_count_basis);
       XTR_RISK_DEBUG_PKG.dlog('calculate_fwd_rate: ' || 'interp method: '||p_interpolation_method);
       XTR_RISK_DEBUG_PKG.dlog('calculate_fwd_rate: ' || 'data side: '||p_side);
    END IF;

    XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
    p_rate1 := p_md_out.p_md_out;

    IF (p_bpv = 'Y') THEN  -- fwd rate used in bpv calculation, so add 1 BP
	p_rate1 := p_rate1 + 0.01;
    END IF;

    -- get yield rate from spot to maturity date
    IF (g_proc_level>=g_debug_level) THEN
       XTR_RISK_DEBUG_PKG.dlog('calculate_fwd_rate: ' || 'spot date: '||p_spot_date);
       XTR_RISK_DEBUG_PKG.dlog('calculate_fwd_rate: ' || 'maturity date: '||p_maturity_date);
    END IF;
    XTR_CALC_P.calc_days_run_c(p_spot_date, p_maturity_date,
		p_day_count_basis, null, p_days2, p_annual_basis);
    p_md_in.p_md_set_code := p_set_code;
    p_md_in.p_source := 'C';
    p_md_in.p_indicator := 'Y';
    p_md_in.p_spot_date := p_spot_date;
    p_md_in.p_future_date := p_maturity_date;
    p_md_in.p_ccy := p_ccy;
    p_md_in.p_contra_ccy := NULL;
    p_md_in.p_day_count_basis_out := p_day_count_basis;
    p_md_in.p_interpolation_method := p_interpolation_method;
    p_md_in.p_side := p_side;
    p_md_in.p_batch_id := NULL;
    p_md_in.p_bond_code := NULL;
    XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
    p_rate2 := p_md_out.p_md_out;

    IF (p_bpv = 'Y') THEN  -- fwd rate used in bpv calculation, so add 1 BP
	p_rate2 := p_rate2 + 0.01;
    END IF;

    -- calculate fwd rate
    IF p_days1 = p_days2 THEN
	p_fwd_rate := 0;
    ELSE
    IF (g_proc_level>=g_debug_level) THEN
       XTR_RISK_DEBUG_PKG.dlog('calculate_fwd_rate: ' || 'calc fwd rate days 1: '||p_days1);
       XTR_RISK_DEBUG_PKG.dlog('calculate_fwd_rate: ' || 'calc fwd rate days 2: '||p_days2);
       XTR_RISK_DEBUG_PKG.dlog('calculate_fwd_rate: ' || 'calc fwd rate rate 1: '||p_rate1);
       XTR_RISK_DEBUG_PKG.dlog('calculate_fwd_rate: ' || 'calc fwd rate rate 2: '||p_rate2);
       XTR_RISK_DEBUG_PKG.dlog('calculate_fwd_rate: ' || 'calc fwd rate annual basis: '||p_annual_basis);
    END IF;

       p_mm_in.p_indicator := 'Y';
       p_mm_in.p_t	   := p_days1;
       p_mm_in.p_T1	   := p_days2;
       p_mm_in.p_Rt	   := p_rate1;
       p_mm_in.p_Rt1       := p_rate2;
       p_mm_in.p_year_basis:= p_annual_basis;
       XTR_MM_COVERS.interest_forward_rate(p_mm_in, p_mm_out);
       p_fwd_rate := p_mm_out.p_fra_rate;
    END IF;

    IF (g_proc_level>=g_debug_level) THEN
       XTR_RISK_DEBUG_PKG.dpop(null,'QRM_MM_FORMULAS.calculate_fwd_rate');
    END IF;
    RETURN p_fwd_rate;


END calculate_fwd_rate;


FUNCTION within_one_year(p_start_date DATE, p_end_date DATE)
   	RETURN BOOLEAN IS

BEGIN
  IF (ADD_MONTHS(p_start_date, 12) >= p_end_date) THEN
     RETURN true;
  ELSE
     RETURN false;
  END IF;
END within_one_year;


PROCEDURE fv_fra(p_price_model 		IN	VARCHAR2,
		p_set_code		IN	VARCHAR2,
		p_bpv			IN	VARCHAR2, -- 'Y' or 'N'
		p_deal_subtype		IN	VARCHAR2,
		p_ccy			IN	VARCHAR2,
		p_interpolation_method	IN	VARCHAR2,
		p_spot_date		IN	DATE,
		p_start_date		IN	DATE,
		p_maturity_date		IN	DATE,
		p_face_value		IN	NUMBER,
		p_contract_rate		IN	NUMBER,
		p_day_count_basis	IN	VARCHAR2, -- for contract rate
		p_side			IN	OUT NOCOPY	VARCHAR2,
		-- settle rate
		p_fwd_fwd_rate		IN	OUT NOCOPY	NUMBER,
		p_fair_value		IN	OUT NOCOPY	NUMBER) IS

	p_fra_dis_price_model 	VARCHAR2(30) := 'FRA_DISC';
	p_fra_yld_price_model	VARCHAR2(30) := 'FRA_YIELD';

	p_fwd_fwd_day_count_basis VARCHAR2(15) := 'ACTUAL365';

	p_days			NUMBER;
	p_annual_basis 		NUMBER;
	p_settle_amount		NUMBER;
	p_discount_rate		NUMBER;

	p_md_in       xtr_market_data_p.md_from_set_in_rec_type;
	p_md_out      xtr_market_data_p.md_from_set_out_rec_type;
	p_fra_in      XTR_MM_COVERS.fra_settlement_in_rec_type;
	p_fra_out     XTR_MM_COVERS.fra_settlement_out_rec_type;
	p_mm_in	      XTR_MM_COVERS.presentValue_in_rec_type;
	p_mm_out      XTR_MM_COVERS.presentValue_out_rec_type;
	p_conv_in     XTR_RATE_CONVERSION.rate_conv_in_rec_type;
	p_conv_out    XTR_RATE_CONVERSION.rate_conv_out_rec_type;

BEGIN
    IF (g_proc_level>=g_debug_level) THEN
       XTR_RISK_DEBUG_PKG.dpush(null,'QRM_MM_FORMULAS.fv_fra');
       XTR_RISK_DEBUG_PKG.dlog('fv_fra: ' || 'contract rate day count basis: '||p_day_count_basis);
    END IF;

    IF (p_price_model = p_fra_dis_price_model OR
	p_price_model = p_fra_yld_price_model) THEN
	-- fwd fwd rate is calculated fra price/settle rate
	-- for FRA calc of BPV, add 1 BP to resulting fwd fwd rate
	-- no need to add 1BP to underlying rates
	p_fwd_fwd_rate := calculate_fwd_rate(p_set_code, 'N', p_deal_subtype,
				p_day_count_basis, p_ccy,
				p_interpolation_method, p_spot_date,
				p_start_date, p_maturity_date);

	IF (p_bpv='Y') THEN
	    p_fwd_fwd_rate := p_fwd_fwd_rate + 0.01;
	END IF;

	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_fra: ' || 'settle/reval rate is: '||p_fwd_fwd_rate);
	END IF;

	IF (p_deal_subtype = 'FUND') THEN
            p_side := 'A';
     	ELSE
            p_side := 'B';
        END IF;

	XTR_CALC_P.calc_days_run_c(p_start_date, p_maturity_date,
		p_day_count_basis, null, p_days, p_annual_basis);

	-- get settlement amount
	IF(p_price_model = p_fra_dis_price_model) then -- 'FRA_DISC'
            p_fra_in.p_indicator := 'DR';
        ELSIF (p_price_model = p_fra_yld_price_model) then -- 'FRA_YIELD'
            p_fra_in.p_indicator := 'Y';
        ELSE
 	    p_fair_value := null;
     	END IF;


        IF (g_proc_level>=g_debug_level) THEN
           XTR_RISK_DEBUG_PKG.dlog('fv_fra: ' || 'contract rate: '||p_contract_rate);
	   XTR_RISK_DEBUG_PKG.dlog('fv_fra: ' || 'fwd fwd rate: '||p_fwd_fwd_rate);
	   XTR_RISK_DEBUG_PKG.dlog('fv_fra: ' || 'face value: '||p_face_value);
	   XTR_RISK_DEBUG_PKG.dlog('fv_fra: ' || 'days to mat: '||p_days);
	   XTR_RISK_DEBUG_PKG.dlog('fv_fra: ' || 'annual basis: '||p_annual_basis);
	   XTR_RISK_DEBUG_PKG.dlog('fv_fra: ' || 'deal subtype: '||p_deal_subtype);
	END IF;
	p_fra_in.p_fra_price := p_contract_rate;  -- contract rate
	p_fra_in.p_settlement_rate := p_fwd_fwd_rate;
	p_fra_in.p_face_value := p_face_value;
	p_fra_in.p_day_count := p_days;
	p_fra_in.p_annual_basis := p_annual_basis;
	p_fra_in.p_deal_subtype := p_deal_subtype;
	XTR_MM_COVERS.fra_settlement_amount(p_fra_in, p_fra_out);
	-- settlement amount is fair value
	p_settle_amount := p_fra_out.p_settlement_amount;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_fra: ' || 'settlement amount is: '||p_settle_amount);
	END IF;

	-- discount to spot date
	IF (p_deal_subtype = 'FUND') THEN
	    IF (p_settle_amount < 0) THEN
		p_side := 'A';
	    ELSE
		p_side := 'B';
	    END IF;
	ELSE   -- deal_subtype = 'INVEST'
	    IF (p_settle_amount >= 0) THEN
		p_side := 'A';
	    ELSE
		p_side := 'B';
	    END IF;
	END IF;

	XTR_CALC_P.calc_days_run_c(p_spot_date, p_start_date,
		p_day_count_basis, null, p_days, p_annual_basis);

	p_md_in.p_md_set_code := p_set_code;
	p_md_in.p_source := 'C';
	p_md_in.p_indicator := 'Y';
	p_md_in.p_spot_date := p_spot_date;
	p_md_in.p_future_date := p_start_date;
	p_md_in.p_ccy := p_ccy;
	p_md_in.p_day_count_basis_out := p_day_count_basis;
	p_md_in.p_interpolation_method := p_interpolation_method;
	p_md_in.p_side := p_side;
	XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
	p_discount_rate := p_md_out.p_md_out;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_fra: ' || 'discount rate: '||p_discount_rate);
	END IF;

	p_mm_in.p_indicator := 'Y';
	p_mm_in.p_future_val := p_settle_amount;
	p_mm_in.p_rate := p_discount_rate;
	p_mm_in.p_pv_date := p_spot_date;
	p_mm_in.p_fv_date := p_start_date;
	p_mm_in.p_day_count_basis := p_day_count_basis;
	IF within_one_year(p_spot_date, p_start_date) THEN
	   p_mm_in.p_rate_type := 'S';
	ELSE
	   p_mm_in.p_rate_type := 'P';
	   p_mm_in.p_compound_freq := 1;
	END  IF;

	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_fra: ' || 'fra fv before discounting: '||p_settle_amount);
	END IF;

	XTR_MM_COVERS.present_value(p_mm_in, p_mm_out);
	p_fair_value := p_mm_out.p_present_val;

	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_fra: ' || 'fra fv after discounting: '||p_fair_value);
	END IF;


	-- convert fwd fwd rate into ACTUAL365
	-- fwd fwd rate is interest rate
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_fra: ' || 'fwd fwd rate bf conv to actual365: '||p_fwd_fwd_rate);
	END IF;
	IF (p_day_count_basis <> p_fwd_fwd_day_count_basis) THEN
	    p_conv_in.p_start_date := p_start_date;
	    p_conv_in.p_end_date := p_maturity_date;
	    p_conv_in.p_day_count_basis_in := p_day_count_basis;
	    p_conv_in.p_day_count_basis_out := p_fwd_fwd_day_count_basis;
	    IF (within_one_year(p_start_date, p_maturity_date)) THEN
		p_conv_in.p_rate_type_in := 'S';
		p_conv_in.p_rate_type_out := 'S';
	    ELSE
	    	p_conv_in.p_rate_type_in := 'P';
	    	p_conv_in.p_rate_type_out := 'P';
		p_conv_in.p_compound_freq_in := 1;
		p_conv_in.p_compound_freq_out := 1;
	    END IF;
	    p_conv_in.p_rate_in := p_fwd_fwd_rate;
	    XTR_RATE_CONVERSION.rate_conversion(p_conv_in, p_conv_out);
	    p_fwd_fwd_rate := p_conv_out.p_rate_out;
	    IF (g_proc_level>=g_debug_level) THEN
	       XTR_RISK_DEBUG_PKG.dlog('fv_fra: ' || 'fwd fwd rate after conv to actual365: '||p_fwd_fwd_rate);
	    END IF;
	END IF;

    END IF;
    IF (g_proc_level>=g_debug_level) THEN
       XTR_RISK_DEBUG_PKG.dpop(null,'QRM_MM_FORMULAS.fv_fra');
    END IF;
END fv_fra;


PROCEDURE fv_iro(p_price_model		  IN	VARCHAR2,
		p_set_code		  IN	VARCHAR2,
		p_deal_subtype		  IN	VARCHAR2,
		p_ccy			  IN	VARCHAR2,
		p_interpolation_method	  IN	VARCHAR2,
		p_spot_date		  IN	DATE,
		p_start_date		  IN	DATE,
		p_maturity_date		  IN	DATE,
		p_strike		  IN	NUMBER,
		p_day_count_basis_strike  IN	VARCHAR2, -- for strike rate
		p_amount		  IN	NUMBER,
		p_side			  IN	OUT NOCOPY	VARCHAR2,
		p_fwd_fwd_rate		  IN	OUT NOCOPY	NUMBER,
		p_fair_value		  IN	OUT NOCOPY	NUMBER) IS

	p_strike_rate			NUMBER 	     := p_strike;
	p_fwd_fwd_day_count_basis 	VARCHAR2(15) := 'ACTUAL365';
	p_day_count_basis		VARCHAR2(15) := 'ACTUAL365';  -- bug 3611158

	p_md_in     xtr_market_data_p.md_from_set_in_rec_type;
	p_md_out    xtr_market_data_p.md_from_set_out_rec_type;

	p_black_in    XTR_MM_COVERS.black_opt_cv_in_rec_type;
	p_black_out   XTR_MM_COVERS.black_opt_cv_out_rec_type;
	p_conv_in     XTR_RATE_CONVERSION.rate_conv_in_rec_type;
	p_conv_out    XTR_RATE_CONVERSION.rate_conv_out_rec_type;

	p_days1		 	NUMBER;
	p_days2			NUMBER;
	p_annual_basis1		NUMBER;
	p_annual_basis2		NUMBER;
	p_volatility		NUMBER;
	p_short_rate		NUMBER;
	p_long_rate		NUMBER;

BEGIN
    IF (g_proc_level>=g_debug_level) THEN
       XTR_RISK_DEBUG_PKG.dpush(null,'QRM_MM_FORMULAS.fv_iro');
    END IF;
    IF (p_price_model = 'BLACK') THEN
	-- convert strike rate to Actual/365
	IF (p_day_count_basis_strike <> p_day_count_basis) THEN
	    p_conv_in.p_start_date := p_start_date;
	    p_conv_in.p_end_date := p_maturity_date;
	    p_conv_in.p_day_count_basis_in := p_day_count_basis_strike;
	    p_conv_in.p_day_count_basis_out := p_day_count_basis;
	    IF (within_one_year(p_start_date, p_maturity_date)) THEN
	        p_conv_in.p_rate_type_in := 'S';
		p_conv_in.p_rate_type_out := 'S';
	    ELSE
		p_conv_in.p_rate_type_in := 'P';
		p_conv_in.p_rate_type_out := 'P';
		p_conv_in.p_compound_freq_in := 1;
		p_conv_in.p_compound_freq_out := 1;
	    END IF;
	    p_conv_in.p_rate_in := p_strike_rate;
	    XTR_RATE_CONVERSION.rate_conversion(p_conv_in, p_conv_out);
	    p_strike_rate := p_conv_out.p_rate_out;
	END IF;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'final strike rate: '||p_strike_rate);
	END IF;

        XTR_CALC_P.calc_days_run_c(p_spot_date, p_start_date,
  	    p_day_count_basis, null, p_days1, p_annual_basis1);
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'spot to start date: '||p_days1);
	END IF;
        XTR_CALC_P.calc_days_run_c(p_spot_date, p_maturity_date,
   	    p_day_count_basis, null, p_days2, p_annual_basis2);
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'spot to maturity date: '||p_days2);
	END IF;

        -- get volatility from MDS
          -- set up data side
        IF p_deal_subtype in ('BCAP', 'BFLOOR') THEN
    	    p_side := 'A';
        ELSE
    	    p_side := 'B';
        END IF;
     	p_md_in.p_md_set_code := p_set_code;
     	p_md_in.p_source := 'C';
     	p_md_in.p_indicator := 'V';
     	p_md_in.p_spot_date := p_spot_date;
     	p_md_in.p_future_date := p_maturity_date;
     	p_md_in.p_ccy := p_ccy;
     	p_md_in.p_contra_ccy := null;
     	p_md_in.p_day_count_basis_out := p_day_count_basis;
     	p_md_in.p_interpolation_method := p_interpolation_method;
     	p_md_in.p_side := p_side;
     	p_md_in.p_batch_id := null;
     	p_md_in.p_bond_code := null;
     	XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
     	p_volatility := p_md_out.p_md_out;
	IF (p_volatility = 0) THEN
	    raise e_option_vol_zero;
	END IF;

	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'volatility is: '||p_volatility);
	END IF;

     	-- get int rates
	  -- set up data side
     	IF p_deal_subtype in ('BCAP', 'SCAP') THEN
    	    p_side := 'A';
     	ELSE
    	    p_side := 'B';
     	END IF;

	-- get int rate between spot date and maturity date
	p_md_in.p_indicator := 'Y';
	XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
	p_long_rate := p_md_out.p_md_out;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'rate between spot and maturity date: '||p_long_rate);
	END IF;

     	-- get int rate between spot date and start date
	p_md_in.p_future_date := p_start_date;
	XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
     	p_short_rate := p_md_out.p_md_out;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'rate between spot and start date: '||p_short_rate);
	END IF;

	-- calculate price using Black's formula
	p_black_in.p_principal := p_amount;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'p_principal: '||p_amount);
	END IF;
	p_black_in.p_strike_rate := p_strike_rate;
	IF (within_one_year(p_start_date, p_maturity_date)) THEN
	   IF (g_proc_level>=g_debug_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'strike rate within one year: ' ||p_strike_rate);
	   END IF;
	   p_black_in.p_rate_type_strike := 'S';
	ELSE
	   IF (g_proc_level>=g_debug_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'strike rate greater than one year: '||p_strike_rate);
	   END IF;
	   p_black_in.p_rate_type_strike := 'P';
	   p_black_in.p_compound_freq_strike := 1;
	END IF;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'p_rate_type_strike: '||p_black_in.p_rate_type_strike);
	   XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'p_compound_freq_strike: '||p_black_in.p_compound_freq_strike);
	END IF;

	p_black_in.p_day_count_basis_strike := p_day_count_basis;
	p_black_in.p_day_count_basis_short := p_day_count_basis;
	p_black_in.p_day_count_basis_long := p_day_count_basis;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'p_day_count_basis_strike: '||p_day_count_basis);
	   XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'p_day_count_basis_short: '||p_day_count_basis);
	   XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'p_day_count_basis_long: '||p_day_count_basis);
	END IF;
	p_black_in.p_ir_short := p_short_rate;
	IF (within_one_year(p_spot_date, p_start_date)) THEN
	   IF (g_proc_level>=g_debug_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'short rate within one year: '||p_short_rate);
	   END IF;
	   p_black_in.p_rate_type_short := 'S';
	ELSE
	   IF (g_proc_level>=g_debug_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'short rate greater than one year: '||p_short_rate);
	   END IF;
	   p_black_in.p_rate_type_short := 'P';
	   p_black_in.p_compound_freq_short := 1;
	END IF;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'p_rate_type_short: '||p_black_in.p_rate_type_short);
	   XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'p_compound_freq_short: '||p_black_in.p_compound_freq_short);
	END IF;
	p_black_in.p_ir_long := p_long_rate;
	IF (within_one_year(p_spot_date, p_maturity_date)) THEN
	   IF (g_proc_level>=g_debug_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'long rate within one year: '||p_long_rate);
	   END IF;
	   p_black_in.p_rate_type_long := 'S';
	ELSE
	   IF (g_proc_level>=g_debug_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'long rate greater than one year: '||p_long_rate);
	   END IF;
	   p_black_in.p_rate_type_long := 'P';
	   p_black_in.p_compound_freq_long := 1;
	END IF;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'p_rate_type_long: '||p_black_in.p_rate_type_long);
	   XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'p_compound_freq_long: '||p_black_in.p_compound_freq_long);
	END IF;
	p_black_in.p_spot_date := p_spot_date;
	p_black_in.p_start_date := p_start_date;
	p_black_in.p_maturity_date := p_maturity_date;
	p_black_in.p_volatility := p_volatility;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'spot date: '||p_spot_date);
	   XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'start date: '||p_start_date);
	   XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'maturity date: '||p_maturity_date);
	   XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'volatility: '||p_volatility);
	END IF;
	XTR_MM_COVERS.black_option_price_cv(p_black_in, p_black_out);

	-- forward forward rate
	p_fwd_fwd_rate := p_black_out.p_forward_forward_rate;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'fwd fwd rate is: '||p_fwd_fwd_rate);
	END IF;

	-- convert fwd fwd rate into ACTUAL365
	-- fwd fwd rate is interest rate
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'fwd fwd rate bf conv to actual365: '||p_fwd_fwd_rate);
	END IF;
	IF (p_day_count_basis <> p_fwd_fwd_day_count_basis) THEN
	    IF (g_proc_level>=g_debug_level) THEN
	       XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'in day count basis: '||p_day_count_basis);
	       XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'fwd fwd day count basis: '||p_fwd_fwd_day_count_basis);
	       XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'rate in: '||p_fwd_fwd_rate);
	    END IF;
	    p_conv_in.p_start_date := p_start_date;
	    p_conv_in.p_end_date := p_maturity_date;
	    p_conv_in.p_day_count_basis_in := p_day_count_basis;
	    p_conv_in.p_day_count_basis_out := p_fwd_fwd_day_count_basis;
	    IF (within_one_year(p_start_date, p_maturity_date)) THEN
		p_conv_in.p_rate_type_in := 'S';
		p_conv_in.p_rate_type_out := 'S';
	    ELSE
	    	p_conv_in.p_rate_type_in := 'P';
	    	p_conv_in.p_rate_type_out := 'P';
		p_conv_in.p_compound_freq_in := 1;
		p_conv_in.p_compound_freq_out := 1;
	    END IF;
	    p_conv_in.p_rate_in := p_fwd_fwd_rate;
	    XTR_RATE_CONVERSION.rate_conversion(p_conv_in, p_conv_out);
	    p_fwd_fwd_rate := p_conv_out.p_rate_out;
	    IF (g_proc_level>=g_debug_level) THEN
	       XTR_RISK_DEBUG_PKG.dlog('fv_iro: ' || 'fwd fwd rate after conv to actual365: '||p_fwd_fwd_rate);
	    END IF;
	END IF;

	-- fair value
	IF p_deal_subtype in ('BCAP', 'SCAP') THEN
	    p_fair_value := p_black_out.p_caplet_price;
	ELSE
	    p_fair_value := p_black_out.p_floorlet_price;
	END IF;

	IF p_deal_subtype in ('SCAP', 'SFLOOR') THEN
	    p_fair_value := p_fair_value * (-1);
	END IF;
    END IF;
    IF (g_proc_level>=g_debug_level) THEN
       XTR_RISK_DEBUG_PKG.dpop(null,'QRM_MM_FORMULAS.fv_iro');
    END IF;
END fv_iro;



PROCEDURE fv_ni(p_price_model		IN	VARCHAR2,
		p_set_code		IN	VARCHAR2,
		p_deal_subtype		IN	VARCHAR2,
		p_discount_basis	IN	VARCHAR2, --'Y' or 'N'
		p_ccy			IN	VARCHAR2,
		p_interpolation_method	IN	VARCHAR2,
		p_day_count_basis	IN	VARCHAR2, -- for reval rate
		p_spot_date		IN	DATE,
		p_start_date		IN	DATE,
		p_maturity_date		IN	DATE,
		p_face_value		IN	NUMBER,
		p_margin		IN	NUMBER,
		p_side			IN	OUT NOCOPY	VARCHAR2,
		p_reval_rate		IN	OUT NOCOPY	NUMBER,
		p_fair_value		IN	OUT NOCOPY	NUMBER) IS

	p_reval_day_count_basis 	VARCHAR2(15) := 'ACTUAL365';

	p_int_rate		NUMBER;
	p_days			NUMBER;
	p_annual_basis		NUMBER;

	-- for holding the later of spot date and start date
	p_date			DATE;
	p_days_start		NUMBER;
	p_days_mature		NUMBER;
	p_int_start		NUMBER;
	p_int_mature		NUMBER;
	p_rate_type		VARCHAR2(1);

	p_md_in       xtr_market_data_p.md_from_set_in_rec_type;
	p_md_out      xtr_market_data_p.md_from_set_out_rec_type;
	p_present_in  XTR_MM_COVERS.presentValue_in_rec_type;
	p_present_out XTR_MM_COVERS.presentValue_out_rec_type;
	p_conv_in     XTR_RATE_CONVERSION.rate_conv_in_rec_type;
	p_conv_out    XTR_RATE_CONVERSION.rate_conv_out_rec_type;
	p_if_in	      XTR_MM_COVERS.int_forw_rate_in_rec_type;
	p_if_out      XTR_MM_COVERS.int_forw_rate_out_rec_type;

BEGIN
    IF (g_proc_level>=g_debug_level) THEN
       XTR_RISK_DEBUG_PKG.dpush(null,'QRM_MM_FORMULAS.fv_ni');
    END IF;
    IF (p_price_model = 'DISC_METHOD') THEN
	-- get market data side
	-- only calculate BUY, SHORT, and ISSUE b/c COVER/SELL updates original
		-- transaction
	IF (p_deal_subtype = 'BUY') THEN
	     p_side := 'B';
	ELSIF (p_deal_subtype IN ('SHORT', 'ISSUE')) THEN
	     p_side := 'A';
	END IF;


	IF (p_spot_date >= p_start_date) THEN
	     p_date := p_spot_date;
	     p_rate_type := 'Y';
	ELSE
	     p_date := p_start_date;
	     p_rate_type := 'F';
	END IF;

	-- get interest yield rate from market data set
	p_md_in.p_md_set_code := p_set_code;
	p_md_in.p_source := 'C';
	p_md_in.p_indicator := 'Y';
	p_md_in.p_ccy := p_ccy;
	p_md_in.p_contra_ccy := NULL;
	p_md_in.p_day_count_basis_out := p_day_count_basis;
	p_md_in.p_interpolation_method := p_interpolation_method;
	p_md_in.p_side := p_side;
	p_md_in.p_batch_id := NULL;
	p_md_in.p_bond_code := NULL;

	IF (p_rate_type = 'Y') THEN
	    p_md_in.p_spot_date := p_date;
	    p_md_in.p_future_date := p_maturity_date;
	    XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
	    p_int_rate := p_md_out.p_md_out;
	ELSIF (p_rate_type = 'F') THEN
	    -- get days to start, and int rate from spot to start
	    p_md_in.p_spot_date := p_spot_date;
	    p_md_in.p_future_date := p_start_date;
	    XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
	    p_int_start := p_md_out.p_md_out;
	    IF (g_proc_level>=g_debug_level) THEN
	       XTR_RISK_DEBUG_PKG.dlog('fv_ni: ' || 'int rate to start: '||p_int_start);
	    END IF;
	    XTR_CALC_P.calc_days_run_c(p_spot_date, p_start_date,
		p_day_count_basis, null, p_days_start, p_annual_basis);
	    IF (g_proc_level>=g_debug_level) THEN
	       XTR_RISK_DEBUG_PKG.dlog('fv_ni: ' || 'days to start: '||p_days_start);
	    END IF;
	    -- get days to maturity, and int rate from spot to maturity
	    p_md_in.p_future_date := p_maturity_date;
	    XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
	    p_int_mature := p_md_out.p_md_out;
	    IF (g_proc_level>=g_debug_level) THEN
	       XTR_RISK_DEBUG_PKG.dlog('fv_ni: ' || 'int rate to maturity: '||p_int_mature);
	    END IF;
	    XTR_CALC_P.calc_days_run_c(p_spot_date, p_maturity_date,
		p_day_count_basis, null, p_days_mature, p_annual_basis);
	    IF (g_proc_level>=g_debug_level) THEN
	       XTR_RISK_DEBUG_PKG.dlog('fv_ni: ' || 'days to maturity: '||p_days_mature);
	    END IF;
	    -- get interest forward rate
	    p_if_in.p_indicator := 'Y';
	    p_if_in.p_t := p_days_start;
	    p_if_in.p_t1 := p_days_mature;
	    p_if_in.p_rt := p_int_start;
	    p_if_in.p_rt1 := p_int_mature;
	    p_if_in.p_year_basis := p_annual_basis;
	    XTR_MM_COVERS.interest_forward_rate(p_if_in, p_if_out);
	    p_int_rate := p_if_out.p_fra_rate;
	END IF;

	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_ni: ' || '(forward) int rate: '||p_int_rate);
	END IF;

	-- if basis is DISCOUNT, convert yield rate to discount rate
	XTR_CALC_P.calc_days_run_c(p_date, p_maturity_date,
		p_day_count_basis, null, p_days, p_annual_basis);
	IF (p_discount_basis = 'Y') THEN
		XTR_RATE_CONVERSION.yield_to_discount_rate(p_int_rate,
			p_days, p_annual_basis, p_int_rate);
		IF (g_proc_level>=g_debug_level) THEN
		   XTR_RISK_DEBUG_PKG.dlog('fv_ni: ' || 'int rate w/o margin: '||p_int_rate);
		END IF;
	END IF;

	-- add margin on top of yield/discount rate
	p_reval_rate := p_int_rate + NVL(p_margin, 0)/100;

	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_ni: ' || 'reval rate with margin: '||p_reval_rate);
	END IF;
	-- if basis is DISCOUNT, convert back to yield rate
	IF (p_discount_basis = 'Y') THEN -- 'Y' for yes
		-- reval rate now is yield rate
		XTR_RATE_CONVERSION.discount_to_yield_rate(p_reval_rate,
			p_days, p_annual_basis, p_reval_rate);
	END IF;

	-- calculate present value using yield reval rate
	p_present_in.p_indicator := 'Y';
	--bug 3058003
	if nvl(p_deal_subtype,'BUY')='ISSUE' then
	   p_present_in.p_future_val := -p_face_value;
	else
	   p_present_in.p_future_val := p_face_value;
	end if;
	p_present_in.p_rate := p_reval_rate;
	p_present_in.p_pv_date := p_date;
	p_present_in.p_fv_date := p_maturity_date;
	p_present_in.p_day_count_basis := p_day_count_basis;
	IF (within_one_year(p_date, p_maturity_date)) THEN
	   p_present_in.p_rate_type := 'S';
	ELSE
	   p_present_in.p_rate_type := 'P';
	   p_present_in.p_compound_freq := 1;
	END IF;

	XTR_MM_COVERS.present_value(p_present_in, p_present_out);
	p_fair_value := p_present_out.p_present_val;

	-- now present value to spot date
	-- this is only necessary if spot date < start date
	-- and so the previously calculate fair value is discounted to
	-- start date only
	IF (p_spot_date < p_start_date) THEN
	     p_md_in.p_indicator := 'Y';
	     p_md_in.p_spot_date := p_spot_date;
	     p_md_in.p_future_date := p_start_date;
	     XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
	     p_int_rate := p_md_out.p_md_out;

	     XTR_CALC_P.calc_days_run_c(p_spot_date, p_start_date,
		p_day_count_basis, null, p_days, p_annual_basis);
	     p_present_in.p_indicator := 'Y';
	     p_present_in.p_future_val := p_fair_value;
	     p_present_in.p_rate := p_int_rate;
	     p_present_in.p_pv_date := p_spot_date;
	     p_present_in.p_fv_date := p_start_date;
	     p_present_in.p_day_count_basis := p_day_count_basis;
	     IF (within_one_year(p_spot_date, p_start_date)) THEN
		p_present_in.p_rate_type := 'S';
	     ELSE
		p_present_in.p_rate_type := 'P';
		p_present_in.p_compound_freq := 1;
	     END IF;
	     XTR_MM_COVERS.present_value(p_present_in, p_present_out);
	     p_fair_value := p_present_out.p_present_val;

	     -- account for buy/sell sign
             IF (p_deal_subtype in ('SHORT', 'ISSUE')) THEN
		p_fair_value := p_fair_value * (-1);
	     END IF;
	END IF;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_ni: ' || 'conversion of ACTUAL365');
	END IF;
	-- convert reval rate into ACTUAL365
	IF (p_day_count_basis <> p_reval_day_count_basis) THEN
	    IF (p_rate_type = 'Y') THEN
	        p_conv_in.p_start_date := p_date;
	    ELSE
		p_conv_in.p_start_date := p_spot_date;
	    END IF;
	    p_conv_in.p_end_date := p_maturity_date;
	    p_conv_in.p_day_count_basis_in := p_day_count_basis;
	    p_conv_in.p_day_count_basis_out := p_reval_day_count_basis;
	    IF (within_one_year(p_date, p_maturity_date)) THEN
	    	p_conv_in.p_rate_type_in := 'S';
	   	p_conv_in.p_rate_type_out := 'S';
	    ELSE
		p_conv_in.p_rate_type_in := 'P';
		p_conv_in.p_rate_type_out := 'P';
		p_conv_in.p_compound_freq_in := 1;
		p_conv_in.p_compound_freq_out := 1;
	    END IF;
	    p_conv_in.p_rate_in := p_reval_rate;
	    XTR_RATE_CONVERSION.rate_conversion(p_conv_in, p_conv_out);
	    p_reval_rate := p_conv_out.p_rate_out;
	END IF;
    END IF;
    IF (g_proc_level>=g_debug_level) THEN
       XTR_RISK_DEBUG_PKG.dpop(null,'QRM_MM_FORMULAS.fv_ni');
    END IF;
END fv_ni;



PROCEDURE fv_bond(	p_price_model		IN 	VARCHAR2,
			p_set_code		IN	VARCHAR2,
			p_deal_subtype		IN	VARCHAR2,
			/* xtr_bond_issues.ric_code */
			p_bond_code		IN	VARCHAR2,
			p_bond_issue_code	IN	VARCHAR2,
			p_ccy			IN	VARCHAR2,
			p_interpolation_method	IN	VARCHAR2,
			p_coupon_action		IN	VARCHAR2,
			/* for coupon rate */
			p_day_count_basis	IN	VARCHAR2,
			p_spot_date		IN	DATE,
			/* WDK: don't need this
			p_start_date		IN	DATE,
			*/
			p_maturity_date		IN	DATE,
			p_coupon_rate		IN 	NUMBER,
			p_face_value		IN	NUMBER,
			p_margin		IN	NUMBER,
			p_rounding_type	IN	VARCHAR2,
			p_day_count_type	IN	VARCHAR2,
			p_side			IN	OUT NOCOPY VARCHAR2,
			p_clean_price_reval	IN 	OUT NOCOPY NUMBER,
			p_dirty_price		IN	OUT NOCOPY NUMBER,
			p_ytm			IN	OUT NOCOPY NUMBER,
			p_accrued_interest	IN	OUT NOCOPY NUMBER,
			p_fair_value		IN	OUT NOCOPY NUMBER,
                        --bug 2804548
                        p_actual_ytm            OUT     NOCOPY NUMBER) IS

	p_yield				NUMBER := NULL;
	p_bond_yield_with_margin 	NUMBER;
	p_dummy1			NUMBER;
	p_dummy2			NUMBER;
	p_days_start			NUMBER;
	p_annual_basis			NUMBER;

	p_settle_date			DATE;

	p_md_in       XTR_MARKET_DATA_P.md_from_set_in_rec_type;
	p_md_out      XTR_MARKET_DATA_P.md_from_set_out_rec_type;
	p_py_in	      XTR_MM_COVERS.bond_price_yield_in_rec_type;
	p_py_out      XTR_MM_COVERS.bond_price_yield_out_rec_type;

BEGIN
    IF (g_proc_level>=g_debug_level) THEN
       XTR_RISK_DEBUG_PKG.dpush(null,'QRM_MM_FORMULAS.fv_bond');
    END IF;
    IF (p_price_model = 'MARKET') THEN
	IF (p_deal_subtype = 'BUY') THEN
	     p_side := 'B';
	ELSIF (p_deal_subtype = 'ISSUE') THEN
	     p_side := 'A';
	END IF;

	p_md_in.p_md_set_code := p_set_code;
	p_md_in.p_source := 'C';
	p_md_in.p_indicator := 'B';
	p_md_in.p_spot_date := p_spot_date;
	p_md_in.p_future_date := NULL;
	p_md_in.p_ccy := p_ccy;
	p_md_in.p_day_count_basis_out := p_day_count_basis;
	p_md_in.p_interpolation_method := p_interpolation_method;
	p_md_in.p_side := p_side;
	p_md_in.p_batch_id := NULL;
	p_md_in.p_bond_code := p_bond_code;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_bond: ' || 'calling market data api');
	END IF;
	XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_bond: ' || 'returned from market data api');
	END IF;
	p_clean_price_reval := p_md_out.p_md_out;-- clean price as of ref date
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_bond: ' || 'bond clean price reval: '||p_clean_price_reval);
	END IF;

	-- get accrued int per 100
	-- accrued interest exists only if coupon already started

	/* WDK: this code is no longer needed!
	XTR_CALC_P.calc_days_run_c(p_start_date, p_spot_date,
		p_day_count_basis, null, p_days_start, p_annual_basis);
	*/
        /* bug 2426008
	p_accrued_interest := (100*p_coupon_rate*p_days_start)/
				(100*p_annual_basis);
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_bond: ' || 'accrued int per 100: '||p_accrued_interest);
	END IF;
        */


	-- p_yield gives us the bond price converted to YTM
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_bond: ' || 'bond issue code: '||p_bond_issue_code);
	END IF;
	  p_py_in.p_bond_issue_code := p_bond_issue_code;
	  p_py_in.p_settlement_date := p_spot_date;
	  p_py_in.p_ex_cum_next_coupon := p_coupon_action;
	  p_py_in.p_calculate_yield_or_price := 'Y';
	  p_py_in.p_clean_price := p_clean_price_reval;
	  p_py_in.p_input_or_calculator := 'I';

	  p_py_in.p_currency                := p_ccy;                  -- COMPOUND COUPON
	  p_py_in.p_face_value              := p_face_value;           -- COMPOUND COUPON
	  p_py_in.p_rounding_type           := p_rounding_type;        -- COMPOUND COUPON
	  p_py_in.p_day_count_type          := p_day_count_type;
	  p_py_in.p_first_trans_flag        := 'Y';
	  p_py_in.p_deal_subtype            := p_deal_subtype;

        XTR_MM_COVERS.calculate_bond_price_yield(p_py_in, p_py_out);
	p_ytm := p_py_out.p_yield;
        p_actual_ytm := p_py_out.p_actual_ytm; --bug 2804548 QRM BPV
        -- bug 2426008
        p_accrued_interest := p_py_out.p_accrued_interest;

	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_bond: ' || 'bond price converted to YTM: '||p_ytm);
	END IF;
	-- if margin exists, convert bond price to YTM, add margin,
 	-- then convert sum back to bond price
	IF (p_margin IS NOT NULL) THEN
	     IF (g_proc_level>=g_debug_level) THEN
	        XTR_RISK_DEBUG_PKG.dlog('fv_bond: ' || 'bond margin: '||p_margin);
	     END IF;
	     p_ytm := p_ytm + p_margin/100;
	     IF (g_proc_level>=g_debug_level) THEN
	        XTR_RISK_DEBUG_PKG.dlog('fv_bond: ' || 'bond YTM with margin: '||p_ytm);
	     END IF;

	     -- convert everything back to bond price
	     IF (p_spot_date < p_maturity_date) THEN
		p_settle_date := p_spot_date;
	     ELSE
		p_settle_date := p_maturity_date;
	     END IF;

	     -- clean price now includes margin
	     p_py_in.p_bond_issue_code := p_bond_issue_code;
	     p_py_in.p_settlement_date := p_settle_date;
 	     p_py_in.p_ex_cum_next_coupon := p_coupon_action;
	     p_py_in.p_calculate_yield_or_price := 'P';
	     p_py_in.p_yield := p_ytm;
	     p_py_in.p_input_or_calculator := 'I';

	     p_py_in.p_currency                := p_ccy;                  -- COMPOUND COUPON
	     p_py_in.p_face_value              := p_face_value;           -- COMPOUND COUPON
	     p_py_in.p_rounding_type           := p_rounding_type;        -- COMPOUND COUPON
	     p_py_in.p_day_count_type          := p_day_count_type;
	     p_py_in.p_first_trans_flag        := 'Y';
	     p_py_in.p_deal_subtype            := p_deal_subtype;


     	     XTR_MM_COVERS.calculate_bond_price_yield(p_py_in, p_py_out);
	     p_clean_price_reval := p_py_out.p_clean_price;

	     IF (g_proc_level>=g_debug_level) THEN
	        XTR_RISK_DEBUG_PKG.dlog('fv_bond: ' || 'clean price with margin: '||
						p_clean_price_reval);
	     END IF;
	END IF;

	p_dirty_price := p_clean_price_reval + p_accrued_interest;

	-- convert accrued interest into actual amount
	p_accrued_interest := (NVL(p_accrued_interest, 0)/100)*
					p_face_value;
	p_fair_value := (p_dirty_price/100) * p_face_value;

	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_bond: ' || 'final dirty price: '||p_dirty_price);
	   XTR_RISK_DEBUG_PKG.dlog('fv_bond: ' || 'accrued int: '||p_accrued_interest);
	END IF;

	IF (p_deal_subtype = 'ISSUE') THEN
	   p_fair_value := (-1)*p_fair_value;
	END IF;

	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('fv_bond: ' || 'bond fair value: '||p_fair_value);
	END IF;
    END IF;
    IF (g_proc_level>=g_debug_level) THEN
       XTR_RISK_DEBUG_PKG.dpop(null,'QRM_MM_FORMULAS.fv_bond');
    END IF;
END fv_bond;



PROCEDURE fv_tmm_irs_rtmm(
			p_price_model		IN 	VARCHAR2,
			p_deal_type		IN	VARCHAR2,
			p_set_code		IN	VARCHAR2,
			p_bpv			IN	VARCHAR2,--'Y' or 'N'
			p_deal_subtype		IN	VARCHAR2,
			p_interpolation_method	IN	VARCHAR2,
			p_ccy			IN	VARCHAR2,
			p_discount_basis	IN  VARCHAR2, -- for IRS
			p_initial_basis		IN  VARCHAR2, -- for IRS
			p_spot_date		IN	DATE,
			p_settle_date		IN	DATE,  -- for TMM/RTMM
			p_margin		IN	NUMBER,
			p_last_rec_trans_no	IN	NUMBER,
			p_day_count_basis	IN	VARCHAR2,-- int rates
			p_transaction_nos	IN XTR_MD_NUM_TABLE,--inc order
			p_start_dates		IN	SYSTEM.QRM_DATE_TABLE,
			p_maturity_dates	IN	SYSTEM.QRM_DATE_TABLE,
			p_settle_dates		IN	SYSTEM.QRM_DATE_TABLE,
			p_coupon_due_on_dates	IN	SYSTEM.QRM_DATE_TABLE, -- prepaid interest
			p_interest_refunds	IN	XTR_MD_NUM_TABLE, -- prepaid interest
			p_principal_actions	IN	SYSTEM.QRM_VARCHAR_TABLE,
			p_interest_rates	IN	XTR_MD_NUM_TABLE,
			-- interest settled for TMM/IRS
			-- amount due for RTMM
			p_interest_settled	IN	XTR_MD_NUM_TABLE,
			-- nvl(p_principal_adjusts, 0) before calling
			p_principal_adjusts	IN	XTR_MD_NUM_TABLE,
			p_accum_interests	IN	XTR_MD_NUM_TABLE,
			p_accum_interests_bf	IN	XTR_MD_NUM_TABLE, -- bug 2807340
			p_balance_outs		IN	XTR_MD_NUM_TABLE,
			p_settle_term_interests	IN	SYSTEM.QRM_VARCHAR_TABLE,--TMM
			p_side			IN	OUT NOCOPY	VARCHAR2,
			p_pv_cashflows		IN	OUT NOCOPY	XTR_MD_NUM_TABLE,
			p_cf_days		IN	OUT NOCOPY	XTR_MD_NUM_TABLE,
			p_annual_basis		IN	OUT NOCOPY	NUMBER,
			p_trans_rate		IN	OUT NOCOPY	NUMBER,
			p_accrued_int		IN	OUT NOCOPY	NUMBER,
			p_fair_value		IN	OUT NOCOPY	NUMBER) IS

	p_length 		NUMBER 	:= p_start_dates.count;
	p_days1			NUMBER;
	p_days2			NUMBER;
	p_accum_int_sum		NUMBER := 0;
	p_coupon_rate		NUMBER;
	p_rate1			NUMBER;
	p_rate2			NUMBER;
	p_coupon_int		NUMBER;
	p_future_val		NUMBER;

	p_principal 		NUMBER	:= 0;
	p_coupon_cf		NUMBER	:= 0;
	p_accrued_interest 	NUMBER	:= 0;
	p_cf_counter		NUMBER  := 0;

	p_mm_day_count_basis	VARCHAR2(15) := 'ACTUAL365';

	p_md_in       xtr_market_data_p.md_from_set_in_rec_type;
	p_md_out      xtr_market_data_p.md_from_set_out_rec_type;
	p_mm_in       XTR_MM_COVERS.int_forw_rate_in_rec_type;
	p_mm_out      XTR_MM_COVERS.int_forw_rate_out_rec_type;
   	p_rc_in	      XTR_RATE_CONVERSION.rate_conv_in_rec_type;
   	p_rc_out      XTR_RATE_CONVERSION.rate_conv_out_rec_type;
	p_df_in	      XTR_RATE_CONVERSION.df_in_rec_type;
	p_df_out      XTR_RATE_CONVERSION.df_out_rec_type;


	FUNCTION present_val_tmm(p_set_code 	VARCHAR2,
				 p_bpv		VARCHAR2,
				 p_spot_date	DATE,
				 p_start_date	DATE,
				 p_ccy		VARCHAR2,
				 p_day_count_basis VARCHAR2,
				 p_interpolation_method VARCHAR2,
				 p_side VARCHAR2,
				 p_future_val	NUMBER)
		RETURN NUMBER IS

		p_md_in       xtr_market_data_p.md_from_set_in_rec_type;
		p_md_out      xtr_market_data_p.md_from_set_out_rec_type;
		p_present_in  XTR_MM_COVERS.presentValue_in_rec_type;
		p_present_out XTR_MM_COVERS.presentValue_out_rec_type;

	BEGIN
	   IF (g_proc_level>=g_debug_level) THEN
	      XTR_RISK_DEBUG_PKG.dpush(null,'QRM_MM_FORMULAS.fv_tmm_irs_rtmm.present_value_tmm');
	      XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'spot date', p_spot_date);
	      XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'start date', p_start_date);
	   END IF;
	   XTR_CALC_P.calc_days_run_c(p_spot_date, p_start_date,
		p_day_count_basis, null, p_days1, p_annual_basis);
	   p_md_in.p_md_set_code := p_set_code;
     	   p_md_in.p_source := 'C';    -- for xtr_market_prices table
	   p_md_in.p_indicator := 'Y'; -- yield rate
	   p_md_in.p_spot_date := p_spot_date;
      	   p_md_in.p_future_date := p_start_date;
	   p_md_in.p_ccy := p_ccy;
	   p_md_in.p_contra_ccy := NULL;
	   p_md_in.p_day_count_basis_out := p_day_count_basis;
	   p_md_in.p_interpolation_method := p_interpolation_method;
	   p_md_in.p_side := p_side;
	   p_md_in.p_batch_id := NULL;
	   p_md_in.p_bond_code := NULL;
	   XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
	   p_present_in.p_indicator := 'Y'; -- yield rate
	   p_present_in.p_future_val := p_future_val;
	   IF (g_proc_level>=g_debug_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'future val: '||p_future_val);
	   END IF;
	   IF (p_bpv = 'Y') THEN
	       p_present_in.p_rate := p_md_out.p_md_out + 0.01;
	   ELSE
	       p_present_in.p_rate := p_md_out.p_md_out;
 	   END IF;
	   IF (g_proc_level>=g_debug_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'yield rate', p_present_in.p_rate);
	   END IF;
	   p_present_in.p_pv_date := p_spot_date;
	   p_present_in.p_fv_date := p_start_date;
	   p_present_in.p_day_count_basis := p_day_count_basis;
	   IF (g_proc_level>=g_debug_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'day count basis', p_day_count_basis);
	   END IF;
	   IF within_one_year(p_spot_date, p_start_date) THEN
	      IF (g_proc_level>=g_debug_level) THEN
	         XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'within one year');
	      END IF;
	      p_present_in.p_rate_type := 'S';
	   ELSE
	      IF (g_proc_level>=g_debug_level) THEN
	         XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'greater than one year');
	      END IF;
	      p_present_in.p_rate_type := 'P';
	      p_present_in.p_compound_freq := 1;
	   END IF;
	   XTR_MM_COVERS.present_value(p_present_in, p_present_out);
	   IF (g_proc_level>=g_debug_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'present val', p_present_out.p_present_val);
	      XTR_RISK_DEBUG_PKG.dpop(null,'QRM_MM_FORMULAS.fv_tmm_irs_rtmm.present_val_tmm');
	   END IF;
	   return p_present_out.p_present_val;
	END present_val_tmm;
BEGIN
    IF (g_proc_level>=g_debug_level) THEN
       XTR_RISK_DEBUG_PKG.dpush(null,'QRM_MM_FORMULAS.fv_tmm_irs_rtmm');
    END IF;
    IF ((p_maturity_dates.count <> p_length) OR
	(p_settle_dates.count <> p_length) OR
	(p_principal_actions.count <> p_length) OR
	(p_interest_rates.count <> p_length) OR
	(p_interest_settled.count <> p_length) OR
	(p_principal_adjusts.count <> p_length) OR
	(p_accum_interests.count <> p_length) OR
	(p_coupon_due_on_dates.count <> p_length) OR -- prepaid interest
	(p_interest_refunds.count <> p_length) OR -- prepaid interest
	(p_balance_outs.count <> p_length)) THEN

	-- do exception handling here
	RAISE_APPLICATION_ERROR
         (-20001,'Arrays must be the same size.');

    ELSIF (p_price_model = 'DISC_CASHFLOW') THEN
	p_fair_value := 0;
	p_accrued_int := 0;
	p_pv_cashflows.DELETE;
	p_cf_days.DELETE;

	FOR i IN 1..p_length LOOP

 	 IF (p_spot_date < p_maturity_dates(i)) THEN
           --******* Calculate Principal ********-----
	   IF (p_deal_type = 'IRS' and p_discount_basis = 'N') THEN
	      p_principal := 0;
	   ELSE
	    IF (p_spot_date < p_start_dates(i)) THEN
	      IF (p_principal_actions(i) = 'INCRSE') THEN
		p_future_val := nvl(p_principal_adjusts(i),0);
		IF (p_deal_subtype = 'FUND') THEN
		   p_side := 'B';
		   p_future_val := nvl((-1)*p_principal_adjusts(i),0);
		ELSE
		   p_side := 'A';
	      	END IF;
	      ELSIF (p_principal_actions(i) = 'DECRSE') THEN
		p_future_val := nvl(p_principal_adjusts(i),0);
		IF (p_deal_subtype = 'FUND') THEN
		   p_side := 'A';
		ELSE
		   p_side := 'B';
		END IF;
	      ELSE
		-- if no principal adjustment, principal is zero
		p_future_val := 0;
	      END IF;

--	      p_future_val := nvl(p_principal_adjusts(i),0);
	      p_principal := present_val_tmm(p_set_code, p_bpv, p_spot_date,
			p_start_dates(i), p_ccy, p_day_count_basis,
			p_interpolation_method, p_side, p_future_val);

	    ELSE -- spot date is past start date
	       -- present value of principal is zero
	       p_principal := 0;
	   END IF;
	  END IF;

	   IF (p_deal_subtype = 'FUND') THEN
	      p_side := 'A';
	   ELSE
	      p_side := 'B';
	   END IF;

	   ----******** Calculate Coupon CF *********-----
		   IF (p_deal_type = 'TMM' AND
				p_last_rec_trans_no = p_transaction_nos(i)) THEN
			-- !!! - interest settled here
		      p_future_val := p_interest_settled(i) - p_accum_int_sum + nvl(p_interest_refunds(i),0);  -- prepaid interest
		      p_coupon_cf := present_val_tmm(p_set_code, p_bpv, p_spot_date,
				p_settle_dates(i), p_ccy, p_day_count_basis, -- prepaid interest
				p_interpolation_method, p_side, p_future_val);
		   -- settle_date = null means transaction is floating
		   -- else it is fixed
		   ELSIF (p_deal_type = 'RTMM' AND
                                p_last_rec_trans_no = p_transaction_nos(i)) THEN   -- bug 3436334
             	      p_future_val := p_interest_settled(i) - p_accum_int_sum;
                      p_coupon_cf := present_val_tmm(p_set_code, p_bpv, p_spot_date,
                                     p_maturity_dates(i), p_ccy, p_day_count_basis,
                                     p_interpolation_method, p_side, p_future_val);
		   ELSIF (    (p_deal_type IN ('TMM', 'RTMM') AND
			       p_spot_date <= p_settle_date AND
			       p_settle_date IS NOT NULL AND
			       p_start_dates(i) <= p_settle_date)
			   OR (p_deal_type = 'IRS' AND p_initial_basis = 'FIXED')) THEN
		      -- fixed rate
		      IF (g_proc_level>=g_debug_level) THEN
			 XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'FIXED LEG');
			 XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'settle date: '||p_settle_date);
		      END IF;
		      p_side := 'A';
		      p_future_val := p_interest_settled(i) + nvl(p_interest_refunds(i),0); -- prepaid interest
		      p_coupon_rate := p_interest_rates(i);
		      IF (g_proc_level>=g_debug_level) THEN
			 XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'pv future val: '||p_future_val);
		      END IF;

		      if p_deal_type = 'RTMM' then  -- bug 3436334
                         p_coupon_cf := present_val_tmm(p_set_code, p_bpv, p_spot_date,
                                p_maturity_dates(i), p_ccy, p_day_count_basis,
                                p_interpolation_method, p_side, p_future_val);
	              else
		         p_coupon_cf := present_val_tmm(p_set_code, p_bpv, p_spot_date,
				p_settle_dates(i), p_ccy, p_day_count_basis,  -- prepaid interest
				p_interpolation_method, p_side, p_future_val);
	              end if;

		   ELSE
		      IF (g_proc_level>=g_debug_level) THEN
			 XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'FLOATING LEG');
		      END IF;
		      -- floating rate
		      IF (g_proc_level>=g_debug_level) THEN
			 XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'spot date: '||p_spot_date);
			 XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'start date: '||p_start_dates(i));
		      END IF;
		      IF (p_spot_date >= p_start_dates(i)) THEN
			 p_coupon_rate := p_interest_rates(i);
		      ELSE
			-- get forward rate
			IF (g_proc_level>=g_debug_level) THEN
			   XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'transaction no: '||p_transaction_nos(i));
			   XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'deal_type: '||p_deal_type);
			   XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'calling calculate fwd rate');
			   XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'maturity date is: '||p_maturity_dates(i));
			END IF;
			-- FOR TMM/IRS calc of bpv, need to add 1 BPV to underlying rates
			p_coupon_rate := calculate_fwd_rate(p_set_code, p_bpv,
					p_deal_subtype, p_day_count_basis, p_ccy,
					p_interpolation_method, p_spot_date,
					p_start_dates(i), p_maturity_dates(i));
			IF (g_proc_level>=g_debug_level) THEN
			   XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'fwd coupon rate w/o margin: '||p_coupon_rate);
			END IF;

			p_coupon_rate := p_coupon_rate + NVL(p_margin/100, 0);
		      END IF;

		      IF (g_proc_level>=g_debug_level) THEN
			 XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'coupon rate w/margin: '||p_coupon_rate);
		      END IF;

		      p_coupon_int := qrm_calc_interest(p_balance_outs(i),
			 p_start_dates(i), p_maturity_dates(i), p_coupon_rate,
			 p_day_count_basis);
		      IF (g_proc_level>=g_debug_level) THEN
			 XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'coupon amt: '||p_coupon_int);
		      END IF;

		      IF ((p_deal_type IN ('TMM', 'RTMM') and p_settle_term_interests(i) = 'Y')
			  OR (p_deal_type = 'IRS')) THEN
			 IF (p_deal_subtype = 'FUND') THEN
			    p_side := 'A';
			 ELSE
			    p_side := 'B';
			 END IF;

			 p_future_val := p_coupon_int;

			 p_coupon_cf := present_val_tmm(p_set_code, p_bpv,
				p_spot_date, p_settle_dates(i), p_ccy, -- prepaid interest
				p_day_count_basis, p_interpolation_method,
				p_side, p_future_val);
			 -- interest settled, so no accrued interest
		      ELSE
			 p_accum_int_sum := p_accum_int_sum + p_coupon_int
						+ p_accum_interests(i);
			 IF (g_proc_level>=g_debug_level) THEN
			    XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'accrued int now: '||p_accrued_interest);
			 END IF;
		      END IF;
		   END IF;    -- ends floating part
	   END IF;  -- end spot date < coupon due on date for prepaid interest

         IF (g_proc_level>=g_debug_level) THEN
            XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'pv coupon cf: '||p_coupon_cf);
         END IF;

	 p_accrued_interest := 0;
	 -- calculate interest rate, accrued interest for current transaction
	 IF ((p_spot_date >= p_start_dates(i)) AND
	     (p_spot_date < p_maturity_dates(i))) THEN
	    p_coupon_rate := p_interest_rates(i);
	    IF (g_proc_level>=g_debug_level) THEN
	       XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'accrued int balance out: '||p_balance_outs(i));
	       XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'accrued int start date: '||p_start_dates(i));
	       XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'accrued int spot date: '||p_spot_date);
	       XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'accrued int coupon rate: '||p_coupon_rate);
	       XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'accrued int DCB: '||p_day_count_basis);
	    END IF;
	    -- accrued interest for TMM/IRS is simple interest
	    -- for RTMM is it fraction of amount due
	    IF (p_deal_type = 'RTMM') THEN
	       XTR_CALC_P.calc_days_run_c(p_start_dates(i), p_spot_date,
		   p_day_count_basis, null, p_days1, p_annual_basis);
	       XTR_CALC_P.calc_days_run_c(p_start_dates(i),
		   p_maturity_dates(i), p_day_count_basis, null, p_days2,
		   p_annual_basis);
	       p_accrued_interest := p_interest_settled(i)*(p_days1/p_days2);
	    ELSE
	       if (p_coupon_due_on_dates(i)<p_maturity_dates(i) and (nvl(p_settle_term_interests(i),'Y')='Y')) then -- prepaid interest
	           p_accrued_interest := qrm_calc_interest(p_balance_outs(i),
			    p_start_dates(i), p_spot_date, p_coupon_rate,
			    p_day_count_basis)
			    - qrm_calc_interest(p_balance_outs(i),
			    p_start_dates(i), p_maturity_dates(i), p_coupon_rate,
			    p_day_count_basis);
	       else -- if not prepaid interest
	           p_accrued_interest := qrm_calc_interest(p_balance_outs(i),
			    p_start_dates(i), p_spot_date, p_coupon_rate,
			    p_day_count_basis);
	       end if; -- prepaid interest
	       p_accrued_interest := p_accrued_interest + nvl(p_accum_interests_bf(i),0); -- bug 2807340
	    END IF;
	    -- transaction rate: int rate converted to Act/365
	    IF (g_proc_level>=g_debug_level) THEN
	       XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'dcb in : '||p_day_count_basis);
	       XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'start date: '||p_start_dates(i));
	       XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'int rate in: '||p_interest_rates(i));
	       XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'coupon rate in: '||p_coupon_rate);
	    END IF;
	    p_rc_in.p_start_date := p_start_dates(i);
	    p_rc_in.p_end_date := p_maturity_dates(i);
	    p_rc_in.p_day_count_basis_in := p_day_count_basis;
	    p_rc_in.p_day_count_basis_out := p_mm_day_count_basis;
	    IF (within_one_year(p_start_dates(i), p_maturity_dates(i))) THEN
		p_rc_in.p_rate_type_in := 'S';
		p_rc_in.p_rate_type_out := 'S';
	    ELSE
		p_rc_in.p_rate_type_in := 'P';
		p_rc_in.p_rate_type_out := 'P';
		p_rc_in.p_compound_freq_in := 1;
		p_rc_in.p_compound_freq_out := 1;
	    END IF;
 	    p_rc_in.p_rate_in := p_interest_rates(i);
	    XTR_RATE_CONVERSION.rate_conversion(p_rc_in, p_rc_out);
	    p_trans_rate := p_rc_out.p_rate_out;
	    IF (g_proc_level>=g_debug_level) THEN
	       XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'trans rate: '||p_trans_rate);
	    END IF;
	 END IF;

	 IF (g_proc_level>=g_debug_level) THEN
	    XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'entering pv cashflow');
	 END IF;
	 -- output present value of cashflow
	 IF (g_proc_level>=g_debug_level) THEN
	    XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'principal is: '||p_principal);
	 END IF;
	 IF (p_principal <> 0) THEN
	     p_cf_counter := p_cf_counter + 1;
	     p_pv_cashflows.EXTEND;
	     p_pv_cashflows(p_cf_counter) := p_principal;
	     p_cf_days.EXTEND;
		IF (g_proc_level>=g_debug_level) THEN
		   XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'spot date: '||p_spot_date);
		   XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'start date: '||p_start_dates(i));
		END IF;
	     XTR_CALC_P.calc_days_run_c(p_spot_date, p_start_dates(i),
		p_day_count_basis, NULL, p_cf_days(p_cf_counter),
		p_annual_basis);
	     IF (p_deal_subtype = 'FUND') THEN
	     	p_pv_cashflows(p_cf_counter) := (-1)*p_pv_cashflows(p_cf_counter);
	     END IF;
	 IF (g_proc_level>=g_debug_level) THEN
	    XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'pv cashflow: '||p_pv_cashflows(p_cf_counter));
	 END IF;
	 XTR_RISK_DEBUG_PKG.dlog('day/year ratio: '||p_cf_days(p_cf_counter)/p_annual_basis);
	 END IF;
	 IF (p_coupon_cf <> 0) THEN
	     p_cf_counter := p_cf_counter + 1;
	     p_pv_cashflows.EXTEND;
	     p_pv_cashflows(p_cf_counter) := p_coupon_cf;
	     p_cf_days.EXTEND;
	     XTR_CALC_P.calc_days_run_c(p_spot_date,
		p_settle_dates(i), p_day_count_basis, NULL, -- prepaid interest
		p_cf_days(p_cf_counter), p_annual_basis);
	     IF (p_deal_subtype = 'FUND') THEN
	     	p_pv_cashflows(p_cf_counter) := (-1)*p_pv_cashflows(p_cf_counter);
	     END IF;
	 IF (g_proc_level>=g_debug_level) THEN
	    XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'pv cashflow: '||p_pv_cashflows(p_cf_counter));
	 END IF;
	 XTR_RISK_DEBUG_PKG.dlog('day/year ratio: '||p_cf_days(p_cf_counter)/p_annual_basis);
	 END IF;

	 -- QRM does not exclude accrued interest from FV calculation
	 p_fair_value := p_fair_value + nvl(p_principal,0) + p_coupon_cf;
	 IF (g_proc_level>=g_debug_level) THEN
	    XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'accrued int before adding: '||p_accrued_interest);
	 END IF;
	 p_accrued_int := p_accrued_int + p_accrued_interest;
	 IF (g_proc_level>=g_debug_level) THEN
	    XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'interation is: '||i);
	    XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'temp principal: '||p_principal);
	    XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'temp accrued int: '||p_accrued_interest);
	    XTR_RISK_DEBUG_PKG.dlog('fv_tmm_irs_rtmm: ' || 'temp fair value is: '||p_fair_value);
	 END IF;
	END LOOP;


	IF (p_deal_subtype = 'FUND') THEN
		  p_fair_value := (-1) * p_fair_value;
		  p_accrued_int := (-1) * p_accrued_int;

	END IF;
    END IF;
    IF (g_proc_level>=g_debug_level) THEN
       XTR_RISK_DEBUG_PKG.dpop(null,'QRM_MM_FORMULAS.fv_tmm_irs_rtmm');
    END IF;
END fv_tmm_irs_rtmm;



/*******************************************************/
/* This function return interest base on principle,    */
/* rate and number of days                             */
/*******************************************************/
FUNCTION qrm_calc_interest(
          p_principle  IN NUMBER,
          p_start_date IN DATE,
          p_end_date IN DATE,
          p_rate IN NUMBER,
          p_day_count_basis IN VARCHAR2) return NUMBER IS

p_day  NUMBER;
p_year NUMBER;
begin
  XTR_CALC_P.calc_days_run_c(p_start_date, p_end_date,
    p_day_count_basis, NULL, p_day, p_year);
  return (p_principle * p_rate * p_day) / (p_year * 100);
END qrm_calc_interest;


-- p_indicator = 'R': calculate accrued interest to ref date
--               'M': calculate accrued interest to maturity date
FUNCTION calculate_accrued_interest(p_indicator		VARCHAR2,
				    p_ref_date		DATE,
				    p_start_date	DATE,
			  	    p_maturity_date	DATE,
				    p_interest_rate	NUMBER,
				    p_interest		NUMBER,
				    p_accum_interest_bf	NUMBER,
				    p_balance_out	NUMBER,
				    p_no_of_days	NUMBER,
				    p_day_count_basis	VARCHAR2,
				    p_accum_int_action	VARCHAR2)
   RETURN NUMBER IS

   p_day_count 		NUMBER;
   p_annual_basis	NUMBER;
   p_accrued_interest	NUMBER;
BEGIN
   IF (g_proc_level>=g_debug_level) THEN
      XTR_RISK_DEBUG_PKG.dpush(null,'QRM_MM_FORMULAS.calculate_accrued_interest');
   END IF;
   IF (p_start_date <= p_ref_date) THEN
      IF (p_indicator='M') THEN
         IF (p_maturity_date >= p_ref_date) THEN
	    IF (g_proc_level>=g_debug_level) THEN
	       XTR_RISK_DEBUG_PKG.dlog('calculate_accrued_interest: ' || 'mat date >= ref date');
	    END IF;
            XTR_CALC_P.calc_days_run_c(trunc(p_start_date),
		trunc(p_ref_date), p_day_count_basis, null,
		p_day_count,p_annual_basis);
   	    p_accrued_interest := p_interest * (p_day_count / p_no_of_days) +
			      nvl(p_accum_interest_bf,0);
         ELSIF (p_maturity_date <= p_ref_date) THEN
	    IF (g_proc_level>=g_debug_level) THEN
	       XTR_RISK_DEBUG_PKG.dlog('calculate_accrued_interest: ' || 'mat date <= ref date');
	    END IF;
   	    p_accrued_interest := 0;
         ELSE
	    IF (g_proc_level>=g_debug_level) THEN
	       XTR_RISK_DEBUG_PKG.dlog('calculate_accrued_interest: ' || 'mat date else');
	    END IF;
   	    XTR_CALC_P.calc_days_run_c(trunc(p_start_date),
		trunc(p_ref_date), p_day_count_basis, null,
		p_day_count,p_annual_basis);
            p_accrued_interest := (p_balance_out * (p_interest_rate /
     		(p_annual_basis * 100)) * p_day_count) +
		nvl(p_accum_interest_bf,0);
         END IF;
      ELSIF (p_indicator='R') THEN
	 IF (g_proc_level>=g_debug_level) THEN
	    XTR_RISK_DEBUG_PKG.dlog('calculate_accrued_interest: ' || 'to ref date');
	 END IF;
         XTR_CALC_P.calc_days_run_c(trunc(p_start_date),
		trunc(p_ref_date), p_day_count_basis, null,
		p_day_count,p_annual_basis);
         p_accrued_interest := (p_balance_out * (p_interest_rate /
     		(p_annual_basis * 100)) * p_day_count) +
		nvl(p_accum_interest_bf,0);
      END IF;
   ELSIF (p_accum_int_action IS NULL) THEN
      p_accrued_interest := nvl(p_accum_interest_bf,0);
   ELSE
      p_accrued_interest := 0;
   END IF;
   IF (g_proc_level>=g_debug_level) THEN
      XTR_RISK_DEBUG_PKG.dpop(null,'QRM_MM_FORMULAS.calculate_accrued_interest');
   END IF;
   RETURN p_accrued_interest;

END calculate_accrued_interest;

END;

/
