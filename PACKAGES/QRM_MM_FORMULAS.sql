--------------------------------------------------------
--  DDL for Package QRM_MM_FORMULAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QRM_MM_FORMULAS" AUTHID CURRENT_USER AS
/* $Header: qrmmmfls.pls 115.28 2003/11/22 00:36:23 prafiuly ship $ */

e_exceed_vol_upper_bound EXCEPTION;
e_option_vol_zero  EXCEPTION;

--bug 3236479
g_debug_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_proc_level NUMBER := FND_LOG.LEVEL_PROCEDURE;

/*--------------------------------------------------------------------------
  BLACK_OPTION_SENS Calculates sensitivities of the interest rate option price using Blacks Formula.(Hull's 4th Edition p.540)

black_opt_sens_in_rec_typ:
  IN:
	p_PRINCIPAL num
	p_STRIKE_RATE num
	p_RATE_TYPE_STRIKE varchar2 DEFAULT 'S'
	p_COMPOUND_FREQ_STRIKE num
	p_DAY_COUNT_BASIS_STRIKE varchar2
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

Calls XTR_RATE_CONVERSION.rate_conversion to convert day counts and/or between compounded and simple interest rates.

Calls XTR_MM_FORMULAS.black_option_price to get cumulative normal distribution
figures.

Note: All rates (not spot) are assumed to be in percentage form.  Eg: interest rate of 0.08 should be inputted as 8.

p_PRINCIPAL = the principal amount from which the interest rate is calculated
p_STRIKE_RATE = Rx = simple interest rate for the deal
p_RATE_TYPE_STRIKE = rate type for p_STRIKE_RATE.  'S' for Simple Rate.
  'C' for Continuous Rate, and 'P' for Compounding Rate.
  Default value = 'S' (Simple IR).
p_DAY_COUNT_BASIS_STRIKE = day count basis for p_STRIKE_RATE
p_IR_SHORT = market simple interest rate for the period between the spot date
  and the start date
p_RATE_TYPE_SHORT = the p_IR_SHORT rate's type. 'S' for Simple Rate.
  'C' for Continuous Rate, and 'P' for Compounding Rate.
  Default value = 'S' (Simple IR).
p_DAY_COUNT_BASIS_SHORT = day count basis for p_IR_SHORT
p_IR_LONG = market simple interest rate for the period between the spot date and
  the maturity date
p_RATE_TYPE_LONG = the p_IR_LONG rate's type. 'S' for Simple Rate. 'C' for
  Continuous Rate, and 'P' for Compounding Rate. Default value = 'S' (Simple IR)
p_DAY_COUNT_BASIS_LONG = day count basis for p_IR_LONG
p_SPOT_DATE = the date when the evaluation/calculation is done
p_START_DATE = the date when the deal becomes effective.
p_END_DATE = the date when the deal matures.
p_VOLATILITY = volatility of interest rate per annum

P_DELTA_CALL = delta call
P_DELTA_PUT = delta put
P_THETA_CALL = theta call
P_THETA_PUT = theta put
P_RHO_CALL = rho call
P_RHO_PUT = rho put
P_GAMMA = gamma
P_VEGA = vega

--------------------------------------------------------------------------*/

-- added fhu 6/19/01
TYPE black_opt_sens_in_rec_type is RECORD(
				p_PRINCIPAL  NUMBER,
				p_STRIKE_RATE NUMBER,
				p_RATE_TYPE_STRIKE varchar2(1) DEFAULT  'S',
				p_COMPOUND_FREQ_STRIKE NUMBER,
				p_DAY_COUNT_BASIS_STRIKE varchar2(15),
				p_IR_SHORT NUMBER,
				p_RATE_TYPE_SHORT varchar2(1) DEFAULT  'S',
				p_COMPOUND_FREQ_SHORT NUMBER,
				p_DAY_COUNT_BASIS_SHORT varchar2(15),
				p_IR_LONG NUMBER,
				p_RATE_TYPE_LONG varchar2(1) DEFAULT  'S',
				p_COMPOUND_FREQ_LONG NUMBER,
				p_DAY_COUNT_BASIS_LONG varchar2(15),
				p_SPOT_DATE date,
				p_START_DATE date,
				p_MATURITY_DATE date,
				p_VOLATILITY NUMBER);

TYPE black_opt_sens_out_rec_type is RECORD  (p_delta_cap	 NUMBER,
					p_delta_floor	 NUMBER,
					p_theta_cap	 NUMBER,
					p_theta_floor	 NUMBER,
					p_rho_cap	 NUMBER,
					p_rho_floor	 NUMBER,
					p_gamma		 NUMBER,
					p_vega		 NUMBER);


-- added by fhu 6/19/01
PROCEDURE black_option_sens(p_in_rec  IN  black_opt_sens_in_rec_type,
                             p_out_rec IN OUT NOCOPY black_opt_sens_out_rec_type);



--#########################################################################
--#									#
--#		FUNCTIONS						#
--#									#
--#########################################################################
--
-- added fhu 6/13/01
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
			representing days to maturity; k=1,2,3,...
	- p_days_in_year = number of days in a year
*/

FUNCTION duration(p_pvc_array IN XTR_MD_NUM_TABLE,
                  p_days_array IN XTR_MD_NUM_TABLE,
                  p_days_in_year NUMBER)
	RETURN NUMBER;


-- added fhu 6/13/01
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
*/

FUNCTION mod_duration(p_duration NUMBER,
		      p_yield NUMBER,
		      p_num_payments NUMBER)
	RETURN NUMBER;


-- added fhu 6/13/01
/*
Calculates BOND CONVEXITY as specified in: Robert Steiner, Mastering Financial Calculations, p.112

The arguments are defined as follows:
	- p_cf_array = cashflows stored in xtr_md_num_table; value at index k
		      	corresponds to kth cashflow; k=1,2,3,...
	- p_days_array = number of days until kth cashflow, stored in
			xtr_md_num_table; each kth element correspons to kth
			cashflow; k=1,2,3,...
	- p_num_payments = number of payments per year
	- p_yield = yield per annum based on p_num_payments per year (YTM)
	- p_days_in_year = number of days in year
	- p_dirty_price = dirty price of bond
*/

FUNCTION bond_convexity(p_cf_array XTR_MD_NUM_TABLE,
			p_days_array XTR_MD_NUM_TABLE,
			p_num_payments NUMBER,
			p_yield NUMBER,
			p_days_in_year NUMBER,
			p_dirty_price NUMBER)
	RETURN NUMBER;


-- added fhu 6/13/01
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


FUNCTION delta_md(p_out VARCHAR2,
	 	  p_dirty_price NUMBER,
		  p_mod_duration NUMBER)
	RETURN NUMBER;



-- added fhu 6/13/01
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

FUNCTION bond_delta_convexity(p_out VARCHAR2,
			      p_dirty_price NUMBER,
			      p_mod_duration NUMBER,
			      p_convexity NUMBER)
	RETURN NUMBER;



-- added fhu 6/13/01
/*
Calculates BPV(DR), or change in price due to a 1 basis point change in
discount rate, of discounted security.  See Deal Calculations HLD.

The arguments are defined as follows:
	- p_principle = principle amount or face value
	- p_days_to_mat = days to maturity
	- p_days_in_year = days in year
*/

FUNCTION ni_bpv_dr(p_principle NUMBER,
		   p_days_to_mat NUMBER,
		   p_days_in_year NUMBER)
	RETURN NUMBER;


-- added fhu 6/13/01
/*
Calculates BPV(YR), or change in price due to a 1 basis point change in yield
rate, of discounted security or bond.  See Deal Calculations HLD.

The arguments are defined as follows:
	- p_dirty_price = dirty price of discounted security or bond
	- p_mod_duration = modified duration of discounted security or bond
*/

FUNCTION bpv_yr(p_dirty_price NUMBER,
		p_mod_duration NUMBER)
	RETURN NUMBER;



-- added fhu 6/13/01
/*
Calculates DELTA/DOLLAR DURATION of discounted security, given BPV(YR) or
BPV(DR). See Deal Calculations HLD.

The arguments are defined as follows:
	- p_out = 'DELTA' if output is to be delta, 'DOLLAR' if is to be
		  dollar duration
	- p_bpv = BPV(DR) or BPV(YR)
*/

FUNCTION ni_delta_bpv(p_out VARCHAR2,
		      p_bpv NUMBER)
	RETURN NUMBER;



-- added fhu 6/13/01
/*
Calcuation of BPV for interest rate swaps (IRS) and wholesale term money (TMM).
This call also be used to calculate the BPV of any instrument, given its fair
values.  See: Deal Calculations HLD, Deal Valuations HLD, FRA Calculator HLD.

Arguments defined as follows:
	- p_fair_value_base = fair value with regular yield curve/rate
	- p_fair_value_shifted = fair value with yield curve/rate shifted up
				one basis point
*/

FUNCTION bpv(p_fair_value_base NUMBER,
             p_fair_value_shifted NUMBER)
	RETURN NUMBER;


--added by sankim 8/8/01
/*
Calculates NI CONVEXITY and FRA COVEXITY as specified in: Robert Steiner,
Mastering Financial
Calculations, p.112

The arguments are defined as follows:
	- p_num_days = number of days until cash flow occurs
                       i.e. number of days till maturity for NI or
                       number of days till settlement for FRA
	- p_rate = yield rate of discounted security, or settlement rate of fra
	- p_days_in_year = number of days in year

Note:  rate is assumed to be in percentage form.
*/

FUNCTION ni_fra_convexity(	p_num_days IN NUMBER,
			p_rate IN NUMBER,
			p_days_in_year IN NUMBER)
	RETURN NUMBER;


--added by jbrodsky 9/21/01
/*
Calculates implied volatility for options, specifically FXO, IRO, and BS

The arguments are defined as follows:
	- p_inidactor = type of option ('FXO', 'IRO', or 'BS')
	- p_spot_date = spot date where the option value is evaluated
	- p_expiration_date = the date of the option expiring
	- p_interest_rates = table contains different interest rates needed as follows by index

				INDEX		VALUE
		FXO		1		Domestic
		FXO		2		Foreign
		IRO		1		Strike
		IRO		2		Short
		IRO		3		Long

	- p_day_count_basis = day count basis table for different rates.  Corresponds to index listed above.
	- p_rate_type = rate type table for different rates.  'S' for simple, 'C' for continuous, 'P'
			for compounding.  Corresponds to index listed above.
	- p_compound_freq = table of frequencies of discretely compounded rate.  Only necessary if rate type
				is 'P'.  Corresponds to index listed above.
	- p_spot_rate = current underlying rate or price.
	- p_strike_rate = strike rate or price agreed upon for option.
	- p_option_price = price of option in currency.
	- p_option_type = type of the option 'C' = call, 'P' = put
	- p_start_date = date when deal becomes effective (only for IRO)
	- p_principal num = principal amount for the interest rate (only for IRO)
	- p_error_tol = error tolerance.  Defaulted to .00001 .
	- p_max_iteration = max iterations in bisection calculation.  Defaulted to 100.
	- p_max_value = maximum value limitation.  Defaulted to 1,000,000,000.
	- p_vol_first_guess = first guess of implied volatility from which the real implied vol is calculated
				Defaulted to 30 (percent)

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
					p_error_tol IN NUMBER DEFAULT 0.00001,
					p_max_iterations IN NUMBER DEFAULT 100,
					p_max_value IN NUMBER DEFAULT 1000000000,
					p_vol_first_guess IN NUMBER DEFAULT 30)
	RETURN NUMBER;


/*  Fair Value Calculations -- fhu 12/13/01   */


FUNCTION calculate_fwd_rate(	p_set_code		VARCHAR2,
				p_bpv			VARCHAR2, -- 'Y' or 'N'
				p_deal_subtype		VARCHAR2,
				p_day_count_basis	VARCHAR2,
				p_ccy			VARCHAR2,
				p_interpolation_method	VARCHAR2,
				p_spot_date		DATE,
				p_start_date		DATE,
				p_maturity_date		DATE)
	RETURN NUMBER;


FUNCTION within_one_year(p_start_date DATE, p_end_date DATE)
   	RETURN BOOLEAN;

-- day count basis is for contract rate
-- forward rate (theoretical fra price) is expressed in ACTUAL/365
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
		p_contract_rate		IN 	NUMBER,
		p_day_count_basis	IN	VARCHAR2,-- for contract rate
		p_side			IN	OUT NOCOPY	VARCHAR2,
		p_fwd_fwd_rate		IN	OUT NOCOPY	NUMBER,
		p_fair_value		IN	OUT NOCOPY	NUMBER);


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
		p_fair_value		  IN	OUT NOCOPY	NUMBER);


PROCEDURE fv_ni(p_price_model		IN	VARCHAR2,
		p_set_code		IN	VARCHAR2,
		p_deal_subtype		IN	VARCHAR2,
		p_discount_basis	IN	VARCHAR2, -- 'Y' or 'N'
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
		p_fair_value		IN	OUT NOCOPY	NUMBER);


PROCEDURE fv_bond(	p_price_model		IN	VARCHAR2,
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
			/* WDK: don't need this value!
			p_start_date		IN	DATE,
			*/
			p_maturity_date		IN	DATE,
			p_coupon_rate		IN 	NUMBER,
			p_face_value		IN	NUMBER,
			p_margin		IN	NUMBER,
			p_rounding_type	IN	VARCHAR2,
			p_day_count_type	IN	VARCHAR2,
			p_side			IN	OUT NOCOPY	VARCHAR2,
			p_clean_price_reval	IN	OUT NOCOPY	NUMBER,
			p_dirty_price		IN	OUT NOCOPY 	NUMBER,
			p_ytm			IN	OUT NOCOPY	NUMBER,
			p_accrued_interest	IN	OUT NOCOPY	NUMBER,
			p_fair_value		IN	OUT NOCOPY	NUMBER,
			p_actual_ytm            OUT NOCOPY NUMBER);



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
			p_settle_dates	        IN	SYSTEM.QRM_DATE_TABLE,
			p_coupon_due_on_dates	IN	SYSTEM.QRM_DATE_TABLE, -- prepaid interest
			p_interest_refunds	IN	XTR_MD_NUM_TABLE, -- prepaid interest
			p_principal_actions	IN	SYSTEM.QRM_VARCHAR_TABLE,
			p_interest_rates	IN	XTR_MD_NUM_TABLE,
			-- interest settled for IRS/TMM
			-- amount due for RTMM
			p_interest_settled	IN	XTR_MD_NUM_TABLE,
			-- nvl(p_principal_adjusts, 0) before calling
			p_principal_adjusts	IN	XTR_MD_NUM_TABLE,
			p_accum_interests	IN	XTR_MD_NUM_TABLE,
			p_accum_interests_bf	IN	XTR_MD_NUM_TABLE,-- bug 2807340
			p_balance_outs		IN	XTR_MD_NUM_TABLE,
			p_settle_term_interests	IN	SYSTEM.QRM_VARCHAR_TABLE,--TMM
			p_side			IN	OUT NOCOPY	VARCHAR2,
			p_pv_cashflows		IN	OUT NOCOPY	XTR_MD_NUM_TABLE,
			p_cf_days		IN	OUT NOCOPY	XTR_MD_NUM_TABLE,
			p_annual_basis		IN	OUT NOCOPY	NUMBER,
			p_trans_rate		IN	OUT NOCOPY	NUMBER,
			p_accrued_int		IN	OUT NOCOPY	NUMBER,
			p_fair_value		IN	OUT NOCOPY	NUMBER);



FUNCTION qrm_calc_interest(
          p_principle  IN NUMBER,
          p_start_date IN DATE,
          p_end_date IN DATE,
          p_rate IN NUMBER,
          p_day_count_basis IN VARCHAR2)
	RETURN NUMBER;


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
   RETURN NUMBER;

END;

 

/
