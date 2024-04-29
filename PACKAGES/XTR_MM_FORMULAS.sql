--------------------------------------------------------
--  DDL for Package XTR_MM_FORMULAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_MM_FORMULAS" AUTHID CURRENT_USER AS
/* $Header: xtrmmfls.pls 120.1 2005/06/29 11:18:53 rjose ship $ */

/*--------------------------------------------------------------------------
  BLACK_OPTION_PRICE Calculates the price/sensitivities of the interest rate option price using Blacks Formula.(Hull's 4th Edition p.540, p.317)

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
       P_ND1  num
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
-- modified fhu 6/20/01
TYPE black_opt_in_rec_type is RECORD   (p_principal    NUMBER,
                                      	p_int_rate     NUMBER,
                               		p_forward_rate NUMBER,
                                	p_t1           NUMBER,
                                	p_t2 	       NUMBER,
                                	p_t2_int_rate  NUMBER,
                                	p_volatility   NUMBER);

TYPE black_opt_out_rec_type is RECORD  (p_caplet_price   NUMBER,
                                 	p_floorlet_price NUMBER,
					p_nd1 NUMBER,
      					p_nd2 NUMBER,
					p_nd1_a NUMBER,
					p_nd2_a NUMBER);


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
        p_n_d1_a
 	p_n_d2_a
----------------------------------------------------------------------------*/
TYPE cum_normdist_in_rec_type is RECORD (p_d1 NUMBER,
					 p_d2 NUMBER);

TYPE cum_normdist_out_rec_type is RECORD (p_n_d1 NUMBER,
					  p_n_d2 NUMBER,
					  p_n_d1_a NUMBER,
					  p_n_d2_a NUMBER);



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
                        p_growth_fac    IN OUT NOCOPY NUMBER);



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
				      p_present_value IN OUT NOCOPY NUMBER);




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
				   p_present_value IN OUT NOCOPY NUMBER);



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
				  p_future_value  IN OUT NOCOPY NUMBER);



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
				     p_future_value  IN OUT NOCOPY NUMBER);


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
                    p_fra_rate   IN OUT NOCOPY NUMBER);


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
				p_settlement_amount IN OUT NOCOPY NUMBER);



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
PROCEDURE fra_settlement_amount_yield(p_fra_price         IN NUMBER,
				      p_settlement_rate   IN NUMBER,
				      p_face_value        IN NUMBER,
				      p_day_count         IN NUMBER,
				      p_annual_basis      IN NUMBER,
				      p_settlement_amount IN OUT NOCOPY NUMBER);



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
                           l_put_price  IN OUT NOCOPY NUMBER);



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
			  p_cashflow_value   IN OUT NOCOPY NUMBER);



--
-- Calculates the present value given the discount factor.
--
-- * P_DISCOUNT_FACTOR = a number between 0 and 1 that is use to calculate
--   the present value as a function of interest rate.
-- * P_FUTURE_VALUE = the amount at maturity.
-- * P_PRESENT_VALUE = the fair value of the discounted security.
--
PROCEDURE present_value_discount_factor(p_discount_factor IN NUMBER,
					p_future_value    IN NUMBER,
					p_present_value   IN OUT NOCOPY NUMBER);


--
-- addition by prafiuly 12/18/2000
-- BLACK_OPTION_PRICE Calculates the price of the interest rate option
-- price using Blacks Formula.(Hull's 4th Edition p.540)


-- modified by fhu 6/12/01
PROCEDURE black_option_price(p_in_rec  IN  black_opt_in_rec_type,
                             p_out_rec IN OUT NOCOPY black_opt_out_rec_type);

--addition by prafiuly 02/01/01
--Find Cumulative Normal Distribution,precision up to 6 decimal places
--from Hull's Fourth Edition p.252
--
PROCEDURE cumulative_norm_distribution (
			p_in_rec IN cum_normdist_in_rec_type,
			p_out_rec IN OUT NOCOPY cum_normdist_out_rec_type);


--
-- Calculates FRA Price (=Contract Rate) for compounded interest where
-- t2-t1 >= N
-- as defined in Market Data Curves HLD
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
PROCEDURE fra_price_long(p_t          IN NUMBER,
                    p_T1         IN NUMBER,
                    p_Rt         IN NUMBER,
                    p_Rt1        IN NUMBER,
                    p_year_basis IN NUMBER,
                    p_fra_rate   IN OUT NOCOPY NUMBER);


--
-- Calculates FRA Price (=Contract Rate) using discount factor as input rates
-- as defined in Market Data Curves HLD
--
--
-- * p_t = number of days from today to start date
-- * P_T1 = number of days from today to maturity date
-- * P_Rt = discount factor for maturity t days
-- * P_RT1 = discount factor for maturity T1 days
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
                    p_fra_rate   IN OUT NOCOPY NUMBER);



END;





 

/
