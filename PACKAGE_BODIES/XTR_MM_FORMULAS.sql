--------------------------------------------------------
--  DDL for Package Body XTR_MM_FORMULAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_MM_FORMULAS" AS
/* $Header: xtrmmflb.pls 120.2 2005/06/29 11:19:18 rjose ship $ */

--
-- Calculates the value of $1 after DAY_COUNT period given the
-- ANNUAL_BASIS and Annual Rate (RATE).
--
-- * P_RATE = the annual rate.
-- * P_DAY_COUNT = the number of days for which the GROWTH_FACTOR
--   is calculated
-- * P_ANNUAL_BASIS = number of days in a year where the RATE and the
--   DAY_COUNT are based on
-- * P_GROWTH_FAC = the value of $1 after DAY_COUNT period given the
--   ANNUAL_BASIS and Annual Rate (RATE).
--
PROCEDURE growth_factor(p_rate          IN NUMBER,
                        p_day_count     IN NUMBER,
                        p_annual_basis  IN NUMBER,
                        p_growth_fac    IN OUT NOCOPY NUMBER) is
BEGIN

  p_growth_fac := 1 + (p_rate * p_day_count) / (100 * p_annual_basis);

END growth_factor;



--
-- Calculates the PRESENT_VALUE given the discount rate as inputs.
--
-- * P_FUTURE_VALUE = the amount at maturity (i.e. Maturity Amount in
--   Discounted Securities Calculator HLD).
-- * P_DISCOUNT_RATE = the return in a discounted security as an
--   annualized percentage of the future amount.
-- * P_PRESENT_VALUE = the fair value of the discounted security.
-- * P_DAY_COUNT = number of days between the PRESENT_VALUE date and
--   FUTURE_VALUE date. (For example: DAY_COUNT = Maturity Date -
--   Settlement Date in Discounted Securities Calculator HLD).
-- * P_ANNUAL_BASIS = number of days in a year where the RATE and the
--   DAY_COUNT are based on.
--
-- ######################################################################
-- #									#
-- # WARNING!!!!! The procedure should never be called directly, please #
-- # 		  call xtr_mm_covers.present_value instead.		#
-- #									#
-- ######################################################################
--
PROCEDURE present_value_discount_rate(p_future_value  IN NUMBER,
				      p_discount_rate IN NUMBER,
				      p_day_count     IN NUMBER,
				      p_annual_basis  IN NUMBER,
				      p_present_value IN OUT NOCOPY NUMBER) is
  v_growth_fac NUMBER;

BEGIN

  growth_factor(p_discount_rate, p_day_count, p_annual_basis, v_growth_fac);

  p_present_value := p_future_value * (1 - (v_growth_fac -1));

END present_value_discount_rate;



--
-- Calculates the PRESENT_VALUE given the yield rate as inputs.
--
-- * P_FUTURE_VALUE = the amount at maturity
-- * P_YIELD_RATE = the return in a discounted security as an
--   annualized percentage of the current amount.
-- * P_PRESENT_VALUE = the fair value of the discounted security.
-- * P_DAY_COUNT = number of days between the PRESENT_VALUE date
--   and FUTURE_VALUE date.
-- * P_ANNUAL_BASIS = number of days in a year where the RATE and
--   the DAY_COUNT are based on.
--
-- ######################################################################
-- #									#
-- # WARNING!!!!! The procedure should never be called directly, please #
-- # 		  call xtr_mm_covers.present_value instead.		#
-- #									#
-- ######################################################################
--
PROCEDURE present_value_yield_rate(p_future_value  IN NUMBER,
				   p_yield_rate    IN NUMBER,
				   p_day_count     IN NUMBER,
				   p_annual_basis  IN NUMBER,
				   p_present_value IN OUT NOCOPY NUMBER) IS

  v_growth_fac NUMBER;

BEGIN

  growth_factor(p_yield_rate, p_day_count, p_annual_basis, v_growth_fac);

  p_present_value := p_future_value/v_growth_fac;

END present_value_yield_rate;




--
-- Calculates the FUTURE_VALUE given the yield rate as inputs.
--
-- * P_FUTURE_VALUE = the amount at maturity (i.e. Maturity Amount in
--   Discounted Securities Calculator HLD).
-- * P_YIELD_RATE = the return in a discounted security as an annualized
--   percentage of the current amount.
-- * P_PRESENT_VALUE = the fair value of the discounted security.
-- * P_DAY_COUNT = number of days between the PRESENT_VALUE date and
--   FUTURE_VALUE date. (For example: DAY_COUNT = Maturity Date - Settlement
--   Date in Discounted Securities Calculator HLD).
-- * P_ANNUAL_BASIS = number of days in a year where the RATE and the
--   DAY_COUNT are based on.
--
-- ######################################################################
-- #									#
-- # WARNING!!!!! The procedure should never be called directly, please #
-- # 		  call xtr_mm_covers.future_value instead.		#
-- #									#
-- ######################################################################
--
PROCEDURE future_value_yield_rate(p_present_value IN NUMBER,
				  p_yield_rate    IN NUMBER,
				  p_day_count     IN NUMBER,
				  p_annual_basis  IN NUMBER,
				  p_future_value  IN OUT NOCOPY NUMBER) IS

  v_growth_fac NUMBER;

BEGIN

  growth_factor(p_yield_rate, p_day_count, p_annual_basis, v_growth_fac);

  p_future_value := p_present_value * v_growth_fac;

END future_value_yield_rate;



--
-- Calculates the FUTURE_VALUE given the discount rate as inputs.
--
-- * P_FUTURE_VALUE = the amount at maturity
-- * P_PRESENT_VALUE = the fair value of the discounted security.
-- * P_DISCOUNT_RATE = the return in a discounted security as an annualized
--   percentage of the future amount.
-- * P_DAY_COUNT = number of days between the PRESENT_VALUE date and
--   FUTURE_VALUE date.
-- * P_ANNUAL_BASIS = number of days in a year where the RATE and the
--   DAY_COUNT are based on.
--
-- ######################################################################
-- #									#
-- # WARNING!!!!! The procedure should never be called directly, please #
-- # 		  call xtr_mm_covers.present_value instead.		#
-- #									#
-- ######################################################################
--
PROCEDURE future_value_discount_rate(p_present_value IN NUMBER,
				     p_discount_rate IN NUMBER,
				     p_day_count     IN NUMBER,
				     p_annual_basis  IN NUMBER,
				     p_future_value  IN OUT NOCOPY NUMBER) IS
BEGIN

  p_future_value := p_present_value * (1 + p_discount_rate * p_day_count /
		(100 * p_annual_basis - p_discount_rate * p_day_count));

END future_value_discount_rate;



--
-- Calculates FRA Price (=Contract Rate) as defined in FRA Calculator HLD
--
--
-- * p_t = number of days from today to start date
-- * P_T1 = number of days from today to maturity date
-- * P_Rt = annual interest rate for maturity t days
-- * P_RT1 = annual interest rate for maturity T1 days
-- *** Assumed: Rt and RT1 have the same day count basis.
-- * p_year_basis = number of days in a year the interest rate is based on.
-- * p_fra_rate = fair contract rate of FRA (forward interest rate covering
--   from the Start Date to the Maturity Date).
--
PROCEDURE fra_price(p_t          IN NUMBER,
                    p_T1         IN NUMBER,
                    p_Rt         IN NUMBER,
                    p_Rt1        IN NUMBER,
                    p_year_basis IN NUMBER,
                    p_fra_rate   IN OUT NOCOPY NUMBER) AS

BEGIN

  IF (p_t is NOT NULL and p_T1 is NOT NULL and p_Rt is NOT NULL and
	p_Rt1 is NOT NULL and p_year_basis is NOT NULL) THEN
  -- Calc for Invest Rate
    p_fra_rate := ((1 + p_RT1 * p_T1 / (p_year_basis * 100)) /
                (1 + p_Rt * p_t / (p_year_basis * 100)) - 1) *
                (p_year_basis * 100 / (p_T1 - p_t));
  ELSE
    RAISE_APPLICATION_ERROR
        (-20001,'At least one of the required parameters is missing.');
  END IF;

END fra_price;



--
-- Calculates the FRA Settlement Amount in FRA Calculator when the input
-- parameter is set to 'Yield'.
--
-- * P_FRA_PRICE = fra_rate = fair contract rate of FRA (forward interest
--   rate covering from the Start Date to the Maturity Date of the contract).
-- * P_SETTLEMENT_RATE = current market annual interest rate.
-- * P_FACE_VALUE  = notional principal amount of FRA.
-- * P_DAY_COUNT = number of days between the Settlement Date to Maturity Date.
-- * P_ANNUAL_BASIS = number of days in a year the SETTLEMENT_RATE and
--   DAY_COUNT are based on.
-- * P_SETTLEMENT_AMOUNT = absolute profit or loss amount
--
-- ######################################################################
-- #									#
-- # WARNING!!!!! The procedure should never be called directly, please #
-- # 		  call xtr_mm_covers.fra_settlement_amount instead.	#
-- #									#
-- ######################################################################
--
PROCEDURE fra_settlement_amount_yield(
				p_fra_price         IN NUMBER,
			        p_settlement_rate   IN NUMBER,
				p_face_value        IN NUMBER,
				p_day_count         IN NUMBER,
				p_annual_basis      IN NUMBER,
				p_settlement_amount IN OUT NOCOPY NUMBER) IS

BEGIN

  p_settlement_amount :=
	(abs(p_fra_price - p_settlement_rate) * p_face_value * p_day_count) /
		(100 * p_annual_basis + p_settlement_rate * p_day_count);

END fra_settlement_amount_yield;



--
-- Calculates the FRA Settlement Amount in FRA Calculator when the input
-- parameter is set to 'Discount'.
--
-- * P_FRA_PRICE = fra_rate = fair contract rate of FRA (forward interest
--   rate covering from the Start Date to the Maturity Date of the contract).
-- * P_SETTLEMENT_RATE = current market annual interest rate.
-- * P_FACE_VALUE  = notional principal amount of FRA.
-- * P_DAY_COUNT = number of days between the Settlement Date to Maturity Date.
-- * P_ANNUAL_BASIS = number of days in a year the SETTLEMENT_RATE and
--   DAY_COUNT are based on.
-- * P_SETTLEMENT_AMOUNT = absolute profit or loss amount
--
-- ######################################################################
-- #									#
-- # WARNING!!!!! The procedure should never be called directly, please #
-- # 		  call xtr_mm_covers.fra_settlement_amount instead.	#
-- #									#
-- ######################################################################
--
PROCEDURE fra_settlement_amount_discount(
				p_fra_price         IN NUMBER,
				p_settlement_rate   IN NUMBER,
				p_face_value        IN NUMBER,
				p_day_count         IN NUMBER,
				p_annual_basis      IN NUMBER,
				p_settlement_amount IN OUT NOCOPY NUMBER) IS

  v_growth_factor_contract   NUMBER;
  v_growth_factor_settlement NUMBER;

BEGIN

  growth_factor(p_fra_price, p_day_count, p_annual_basis,
		     v_growth_factor_contract);

  growth_factor(p_settlement_rate, p_day_count, p_annual_basis,
		     v_growth_factor_settlement);


  p_settlement_amount := (abs(p_face_value * (1/v_growth_factor_contract -
					  1/v_growth_factor_settlement)));

END fra_settlement_amount_discount;



--
-- Calculates the price of a generic option.
--
-- * time_in_days = time left to maturity in days
-- * int_rate = annual risk free interest rate.
-- * market_price = the current market price of the commodity
-- * strike_price = the strike price agreed in the option.
-- * vol = volatility
-- * l_call_price = theoretical fair value of the call.
-- * L_put_price = theoretical fair value of the put
-- * l_delta_call/put = delta of the call/put
-- * l_theta_call/put = theta of the call/put
-- * l_rho_call/put = rho of the call/put
-- * l_gamma = gamma
-- * l_vega = vega
--
-- gamma, theta, delta, vega are sensitivity measurements of the model
-- relatives to its different variables and explained extensively in Hull's
-- Option, Future, and Other Derivatives.
--
PROCEDURE bs_option_price(time_in_days IN NUMBER,
       			   int_rate     IN NUMBER,
                           market_price IN NUMBER,
                           strike_price IN NUMBER,
                           vol          IN NUMBER,
                           l_delta_call IN OUT NOCOPY NUMBER,
                           l_delta_put  IN OUT NOCOPY NUMBER,
                           l_theta_call IN OUT NOCOPY NUMBER,
                           l_theta_put  IN OUT NOCOPY NUMBER,
                           l_rho_call   IN OUT NOCOPY NUMBER,
                           l_rho_put    IN OUT NOCOPY NUMBER,
                           l_gamma      IN OUT NOCOPY NUMBER,
                           l_vega 	IN OUT NOCOPY NUMBER,
                           l_call_price IN OUT NOCOPY NUMBER,
                           l_put_price  IN OUT NOCOPY NUMBER) IS

--
-- Below are approximations of normal probability and PI(always fixed constant)
--
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
BEGIN

  d1 := (LN(market_price/strike_price) + (r + POWER(v, 2)/2)*t)/(v * SQRT(t));
  d2 := d1 - v*SQRT(t);
  n_d1_a := EXP(-(POWER(abs(d1), 2)) / 2) / SQRT(2 * pi);
  k1 := 1 / (1 + 0.33267 * ABS(d1));
  n_d1_temp := 1 - n_d1_a*(a1*k1+a2*POWER(k1,2)+a3*POWER(k1,3));

  IF d1 >= 0 THEN
    n_d1 := n_d1_temp;
  ELSE
    n_d1 := 1 - n_d1_temp;
  END IF;

  n_d2_a := EXP(-(POWER(abs(d2),2)) / 2) / SQRT(2*pi);
  k2 := 1/(1 + 0.33267 * ABS(d2));
  n_d2_temp := 1-n_d2_a*(a1*k2+a2*POWER(k2,2)+a3*POWER(k2,3));

  IF d2 >= 0 THEN
   n_d2 := n_d2_temp;
  ELSE
   n_d2 := 1 - n_d2_temp;
  END IF;

--
-- See Currency Options on the Philadelphia Exchange p272
--
  l_call_price := EXP(-r*t)*(market_price * n_d1-strike_price*n_d2);
  l_put_price := EXP(-r*t)*(strike_price*(1-n_d2)-market_price*(1-n_d1));

--
-- Black-Scholes Formulas
--
-- l_call_price := (market_price * n_d1)-(strike_price*EXP(-r*t)*n_d2);
-- l_put_price := strike_price*EXP(-r*t)*(1-n_d2)-market_price*(1-n_d1);
--

  l_delta_call := n_d1;
  l_delta_put := n_d1 - 1;
  l_gamma := n_d1_a/(market_price*v*SQRT(t));
  l_vega := market_price*SQRT(t)*n_d1_a;
  l_theta_call := -((market_price*n_d1_a*v)/2/SQRT(t))-(r*strike_price*EXP(-r*t)*n_d2);
  l_theta_put := -(market_price*n_d1_a*v/2/SQRT(t))+(r*strike_price*EXP(-r*t)*(1-n_d2));
  l_rho_call := strike_price*t*EXP(-r*t)*n_d2;
  l_rho_put := -strike_price*t*EXP(-r*t)*(1-n_d2);

END bs_option_price;



--
-- Calculates the cashflow given the coupon rate.
--
-- * PRINCIPAL_AMOUNT = the face value from which the cash flows are generated.
-- * P_RATE is the annual coupon rate.
-- * P_DAY_COUNT = number of days from the spot date/current date to the cash
--   flow payment date.  (For example: DAY_COUNT = Maturity Date - Spot Date,
--   in IRS HLD).
-- * P_ANNUAL_BASIS = number of days in a year from which the DAY_COUNT and
--   RATE are based on.
--
PROCEDURE coupon_cashflow(p_principal_amount IN NUMBER,
			  p_rate             IN NUMBER,
			  p_day_count        IN NUMBER,
			  p_annual_basis     IN NUMBER,
			  p_cashflow_value   IN OUT NOCOPY NUMBER) IS

  v_growth_fac NUMBER;

BEGIN

  growth_factor(p_rate, p_day_count, p_annual_basis, v_growth_fac);

  p_cashflow_value := p_principal_amount * (v_growth_fac - 1);

END coupon_cashflow;


--
-- Calculates the present value given the discount factor.
--
-- * P_DISCOUNT_FACTOR = a number between 0 and 1 that is use to calculate
--   the present value as a function of interest rate.
-- * P_FUTURE_VALUE = the amount at maturity.
-- * P_PRESENT_VALUE = the fair value of the discounted security.
--
PROCEDURE present_value_discount_factor(
				p_discount_factor IN NUMBER,
				p_future_value    IN NUMBER,
				p_present_value   IN OUT NOCOPY NUMBER) IS

BEGIN

  p_present_value := p_future_value * p_discount_factor;

END present_value_discount_factor;




/*--------------------------------------------------------------------------
  BLACK_OPTION_PRICE Calculates the price and sensitivities of the interest rate option price using Blacks Formula.(Hull's 4th Edition p.540)

black_opt_in_rec_typ:
  IN:  P_PRINCIPAL num
       P_INT_RATE num
       P_FORWARD_RATE num
       P_T1 num
       P_T2 num
       P_T2_INT_RATE num
       P_VOLATILITY num
black_opt_out_rec_typ:
  OUT: P_CAPLET_PRICE num
       P_FLOORLET_PRICE num
       P_ND1 num
       P_ND2  num
       P_ND1_A num
       P_ND2_A num

Assumption: Annual Basis = 360
            Continuous interest rate is required

Call XTR_RATE_CONVERSION.rate_conversion to convert day counts and/or between compounded and simple interest rates.

P_PRINCIPAL = the principal amount from which the interest rate is calculated
P_INT_RATE = strike price = interest rate for the deal
P_FORWARD_RATE = market forward rate for the period of the deal
P_T1 = number of days to the start date when the deal becomes effective.
P_T2 = number of days to the end date when the deal matures
p_T2_INT_RATE = current interest rate until the maturity date
P_VOLATILITY = volatility of interest rate per annum
P_CAPLET_PRICE = interest rate collars
P_FLOORLET_PRICE = interest rate floors(CAPLET_PRICE = FLOORLET_PRICE + SWAP_VALUE)
P_ND1/2 = cumulative normal probability distribution value = N(x) in Black Formula
P_ND1/2_A = N'(x) in Black Formula

--------------------------------------------------------------------------*/
--Addition by prafiuly 12/18/2000
--Modified: fhu 6/20/01

PROCEDURE black_option_price(p_in_rec  IN  black_opt_in_rec_type,
                             p_out_rec IN OUT NOCOPY black_opt_out_rec_type) is

--
--  a1 NUMBER :=  0.4361836;
--  a2 NUMBER := -0.1201678;
--  a3 NUMBER := 0.9372980;

--
  v_time_span NUMBER := p_in_rec.p_t2 - p_in_rec.p_t1;
  v_t         NUMBER := v_time_span/365;  -- bug 3509267
  v_t1        NUMBER := p_in_rec.p_t1/365;
  v_t2        NUMBER := p_in_rec.p_t2/365;
  v_forward   NUMBER := p_in_rec.p_forward_rate/100;
  v_vol       NUMBER := p_in_rec.p_volatility/100;
  v_ir        NUMBER := p_in_rec.p_int_rate/100;
  v_ir2       NUMBER := p_in_rec.p_t2_int_rate/100;
  v_d1        NUMBER;
  v_d2        NUMBER;
  v_n_d1      NUMBER;
  v_n_d2      NUMBER;
  v_n_d1_a    NUMBER;
  v_n_d2_a    NUMBER;
  v_cum_normdist_in_rec  cum_normdist_in_rec_type;
  v_cum_normdist_out_rec cum_normdist_out_rec_type;

BEGIN

  v_d1 := (LN(v_forward / v_ir) + 0.5 * POWER(v_vol, 2) * v_t1) /
		(v_vol * SQRT(v_t1));

  v_d2 := v_d1 - (v_vol * SQRT(v_t1));

  v_cum_normdist_in_rec.p_d1 := v_d1;
  v_cum_normdist_in_rec.p_d2 := v_d2;
  cumulative_norm_distribution (v_cum_normdist_in_rec, v_cum_normdist_out_rec);

  v_n_d1 := v_cum_normdist_out_rec.p_n_d1;
  v_n_d2 := v_cum_normdist_out_rec.p_n_d2;

  v_n_d1_a := v_cum_normdist_out_rec.p_n_d1_a;
  v_n_d2_a := v_cum_normdist_out_rec.p_n_d2_a;

  p_out_rec.p_caplet_price := p_in_rec.p_principal * v_t *
	EXP(-v_ir2 * v_t2) * (v_forward * v_n_d1 - v_ir * v_n_d2);

  p_out_rec.p_floorlet_price := p_in_rec.p_principal * v_t *
	EXP(-v_ir2 * v_t2) * (v_ir * (1 - v_n_d2) - v_forward * (1 - v_n_d1));

  p_out_rec.p_nd1 := v_n_d1;
  p_out_rec.p_nd2 := v_n_d2;
  p_out_rec.p_nd1_a := v_n_d1_a;
  p_out_rec.p_nd2_a := v_n_d2_a;

END black_option_price;



/*---------------------------------------------------------------------------
--addition by prafiuly 02/01/01
--Find Cumulative Normal Distribution,precision up to 6 decimal places
--from Hull's Fourth Edition p.252
cum_normdist_in_rec_type:
	p_d1 = the value of d1 from Black's formula
	p_d2 = the value of d2 from Black's formula
cum_normdist_out_rec_type:
	p_n_d1 = the cumulative normal distribution given p_d1
	p_n_d2 = the cumulative normal distribution given p_d2

----------------------------------------------------------------------------*/
PROCEDURE cumulative_norm_distribution (
			p_in_rec IN cum_normdist_in_rec_type,
			p_out_rec IN OUT NOCOPY cum_normdist_out_rec_type) is


  c_a1 NUMBER := 0.319381530;
  c_a2 NUMBER := -0.356563782;
  c_a3 NUMBER := 1.781477937;
  c_a4 NUMBER := -1.821255978;
  c_a5 NUMBER := 1.330274429;
  c_pi NUMBER  := 3.14159265358979;
  v_d1 	      NUMBER := p_in_rec.p_d1;
  v_d2	      NUMBER := p_in_rec.p_d2;
  v_n_d1_a    NUMBER;
  v_k1        NUMBER;
  v_n_d1_temp NUMBER;
  v_n_d1      NUMBER;
  v_n_d2_a    NUMBER;
  v_k2        NUMBER;
  v_n_d2_temp NUMBER;
  v_n_d2      NUMBER;


BEGIN

  v_n_d1_a := EXP(-(POWER(ABS(v_d1), 2)) / 2) / SQRT(2 * c_pi);

  v_k1 := 1 / (1 + 0.2316419 * ABS(v_d1));

  v_n_d1_temp := 1 - v_n_d1_a*(c_a1 * v_k1 + c_a2 * POWER(v_k1, 2) +
      	c_a3 * POWER(v_k1, 3) + c_a4 * POWER(v_k1, 4) + c_a5 * POWER(v_k1, 5));

  IF v_d1 >= 0 THEN
     v_n_d1 := v_n_d1_temp;
  ELSE
     v_n_d1 := 1 - v_n_d1_temp;
  END IF;

  v_n_d2_a := EXP(-(POWER(abs(v_d2), 2)) / 2) / SQRT(2 * c_pi);

  v_k2 := 1/(1 + 0.2316419 * ABS(v_d2));

  v_n_d2_temp := 1 - v_n_d2_a * (c_a1 * v_k2 + c_a2 * POWER(v_k2, 2) +
	c_a3 * POWER(v_k2, 3) + c_a4 * POWER(v_k2, 4) + c_a5 * POWER(v_k2, 5));

  IF v_d2 >= 0 THEN
    v_n_d2 := v_n_d2_temp;
  ELSE
    v_n_d2 := 1 - v_n_d2_temp;
  END IF;

  p_out_rec.p_n_d1 := v_n_d1;
  p_out_rec.p_n_d2 := v_n_d2;
  p_out_rec.p_n_d1_a := v_n_d1_a;
  p_out_rec.p_n_d2_a := v_n_d2_a;
--
END cumulative_norm_distribution;


--
-- Calculates FRA Price (=Contract Rate) for compounded interest where
-- t2-t1 >= N
-- as defined in Market Data Curves HLD
--
--
-- * p_t = number of days from today to start date
-- * p_T1 = number of days from today to maturity date
-- * p_Rt = annual interest rate for maturity p_t days
-- * p_RT1 = annual interest rate for maturity p_T1 days
-- *** Assumed: Rt and RT1 have the same day count basis.
-- * p_year_basis = number of days in a year the interest rate is based on.
-- * p_fra_rate = fair contract rate of FRA (forward interest rate covering
--   from the Start Date to the Maturity Date).
--
PROCEDURE fra_price_long(p_t          IN NUMBER,
                    p_T1         IN NUMBER,
                    p_Rt         IN NUMBER,
                    p_Rt1        IN NUMBER,
                    p_year_basis IN NUMBER,
                    p_fra_rate   IN OUT NOCOPY NUMBER) AS
BEGIN

  IF (p_t is NOT NULL and p_T1 is NOT NULL and p_Rt is NOT NULL and
	p_Rt1 is NOT NULL and p_year_basis is NOT NULL) THEN
  -- Calc for Invest Rate
    p_fra_rate := (power((power(1+(p_Rt1/100),p_T1/p_year_basis)/power(1+(p_Rt/100),p_t/p_year_basis)),p_year_basis/(p_T1-p_t))-1)*100;
  ELSE
    RAISE_APPLICATION_ERROR
        (-20001,'At least one of the required parameters is missing.');
  END IF;

END fra_price_long;


--
-- Calculates FRA Price (=Contract Rate) using discount factor as input rates
-- as defined in Market Data Curves HLD
--
--
-- * p_t = number of days from today to start date
-- * p_T1 = number of days from today to maturity date
-- * p_Rt = discount factor for maturity p_t days
-- * p_RT1 = discount factor for maturity p_T1 days
-- *** Assumed: Rt and RT1 have the same day count basis.
-- * p_year_basis = number of days in a year the interest rate is based on.
-- * p_fra_rate = fair contract rate of FRA (forward interest rate covering
--   from the Start Date to the Maturity Date).
--
PROCEDURE fra_price_df(p_t          IN NUMBER,
                    p_T1         IN NUMBER,
                    p_Rt         IN NUMBER,
                    p_Rt1        IN NUMBER,
                    p_year_basis IN NUMBER,
                    p_fra_rate   IN OUT NOCOPY NUMBER) AS

BEGIN

  IF (p_t is NOT NULL and p_T1 is NOT NULL and p_Rt is NOT NULL and
	p_Rt1 is NOT NULL and p_year_basis is NOT NULL) THEN
  -- Calc for Invest Rate
    p_fra_rate := ((p_Rt/p_Rt1)-1)*(p_year_basis/(p_T1-p_t))*100;
  ELSE
    RAISE_APPLICATION_ERROR
        (-20001,'At least one of the required parameters is missing.');
  END IF;

END fra_price_df;


END;

/
