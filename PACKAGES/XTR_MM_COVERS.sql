--------------------------------------------------------
--  DDL for Package XTR_MM_COVERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_MM_COVERS" AUTHID CURRENT_USER AS
/* $Header: xtrmmcvs.pls 120.8 2005/06/29 11:03:02 csutaria ship $ */


/*----------------------------------------------------------------------------
 Calculates the future value given either the yield or discount rate as
 the input.

 IMPORTANT: There are two ways to use this API, the first one is passing in
	the p_DAY_COUNT and p_ANNUAL_BASIS, the second one is passing in the
	Present Value date (p_PV_DATE), Future Value date (p_FV_DATE),
	p_DAY_COUNT_BASIS, p_RATE_TYPE, and p_COMPOUND_FREQ.
	The second method is the one that should be used due to some
	complications in determining whether a period is less or greater
	than a year (refer to Bug 2295869) and whether a rate should be a
	simple rate (period is less than a year) or annually compounding rate
	(period is greater than or equal to a year).

 RECORD Data Type:
   IN:    P_INDICATOR varchar2
          P_PRESENT_VALUE num
          P_RATE num
          P_DAY_COUNT num
          P_ANNUAL_BASIS num
          P_PV_DATE date
          P_FV_DATE date
          P_DAY_COUNT_BASIS varchar2
 	  P_RATE_TYPE varchar2
	  P_COMPOUND_FREQ number
   OUT:   P_FUTURE_VAL num

 * P_INDICATOR is to differentiate whether the rate is a discount rate or a
   yield rate.(Y=Yield Rate, DR=Discount Rate).
 * P_FUTURE_VAL = the amount at maturity .
 * P_PRESENT_VAL  = the fair value of the discounted security.
 * P_RATE = Yield Rate or Discount Rate (annualized)
 * P_DAY_COUNT = number of days between the PRESENT_VALUE date and
   FUTURE_VALUE date. This parameter must be NULL if want
   (For example: DAY_COUNT = Maturity Date -
   Settlement Date in Discounted Securities Calculator HLD).
 * P_ANNUAL_BASIS = number of days in a year where the RATE and the
   DAY_COUNT are based on.
 * P_PV_DATE = the PRESENT_VALUE date (For example: p_PV_DATE =  Settlement
	Date in Discounted Securities Calculator HLD).
 * P_FV_DATE = the FUTURE_VALUE date (For example: p_FV_DATE =  Maturity
	Date in Discounted Securities Calculator HLD).
 * P_DAY_COUNT_BASIS = the day count basis of p_RATE.
 * P_RATE_TYPE = the rate type of p_RATE. Possible values are: (S)imple,
	com(P)ounded, and (C)ontinuous.
 * P_COMPOUND_FREQ = the compounding frequency of P_RATE, only necessary if
	p_RATE_TYPE='P'.
----------------------------------------------------------------------------*/
TYPE futureValue_out_rec_type is record (p_future_val NUMBER);
TYPE futureValue_in_rec_type is record  (p_indicator    VARCHAR2(2),
				  	 p_present_val  NUMBER,
				  	 p_rate         NUMBER,
				  	 p_day_count    NUMBER,
				  	 p_annual_basis NUMBER,
					  p_pv_date 	 DATE,
					  p_fv_date	 DATE,
					  p_day_count_basis VARCHAR2(20),
					  p_rate_type 	 VARCHAR2(1),
					  p_compound_freq NUMBER);

/*----------------------------------------------------------------------------
 Calculates the present value given either the yield rate, discount rate,
 or discount factor as the input.

 IMPORTANT: There are two ways to use this API, the first one is passing in
	the p_DAY_COUNT and p_ANNUAL_BASIS, the second one is passing in the
	Present Value date (p_PV_DATE), Future Value date (p_FV_DATE),
	p_DAY_COUNT_BASIS, p_RATE_TYPE, and p_COMPOUND_FREQ.
	The second method is the one that should be used due to some
	complications in determining whether a period is less or greater
	than a year (refer to Bug 2295869) and whether a rate should be a
	simple rate (period is less than a year) or annually compounding rate
	(period is greater than or equal to a year).

 RECORD Data Type:
    IN:     P_INDICATOR char
            P_FUTURE_VALUE num
            P_RATE nu
            P_DAY_COUNT date default
            P_ANNUAL_BASIS num default
    OUT:    P_PRESENT_VALUE num

 * P_INDICATOR is to differentiate whether the rate is a discount rate,
   a yield rate, or a disocunt factor.(Y=Yield Rate, DR=Discount Rate,
   D=Disount Factor).
 * P_FUTURE_VAL = the amount at maturity .
 * P_PRESENT_VAL  = the fair value of the discounted security.
 * P_RATE = Yield Rate, Discount Rate, or Discount Factor (annualized)
 * P_DAY_COUNT = number of days between the PRESENT_VALUE date and
   FUTURE_VALUE date. (For example: DAY_COUNT = Maturity Date -
   Settlement Date in Discounted Securities Calculator HLD).
 * P_ANNUAL_BASIS = number of days in a year where the RATE and the
   DAY_COUNT are based on.
 * P_PV_DATE = the PRESENT_VALUE date (For example: p_PV_DATE =  Settlement
	Date in Discounted Securities Calculator HLD).
 * P_FV_DATE = the FUTURE_VALUE date (For example: p_FV_DATE =  Maturity
	Date in Discounted Securities Calculator HLD).
 * P_DAY_COUNT_BASIS = the day count basis of p_RATE.
 * P_RATE_TYPE = the rate type of p_RATE. Possible values are: (S)imple,
	com(P)ounded, and (C)ontinuous.
 * P_COMPOUND_FREQ = the compounding frequency of P_RATE, only necessary if
	p_RATE_TYPE='P'.
----------------------------------------------------------------------------*/
TYPE PresentValue_out_rec_type is record (p_present_val NUMBER);
TYPE PresentValue_in_rec_type is record  (p_indicator    VARCHAR2(2),
				  	  p_future_val   NUMBER,
				  	  p_rate         NUMBER,
				  	  p_day_count    NUMBER,
				  	  p_annual_basis NUMBER,
					  p_pv_date 	 DATE,
					  p_fv_date	 DATE,
					  p_day_count_basis VARCHAR2(20),
					  p_rate_type 	 VARCHAR2(1),
					  p_compound_freq NUMBER);



--
-- Calculates the FRA Settlement Amount in FRA Calculator when the input
-- parameter is set to 'Yield'.
--
-- RECORD Data Type:
--    IN:     P_INDICATOR char
--            P_FRA_PRICE num
--            P_SETTLEMENT_RATE num
--            P_FACE_VALUE num
--            P_DAY_COUNT num
--            P_ANNUAL_BASIS num
--    OUT:    P_SETTLEMENT_AMOUNT num
--
-- * P_INDICATOR is to differentiate whether the settlement rate parameter
--   is a discount rate or a yield rate.(Y=Yield Rate, DR=Discount Rate).
-- * P_A_PRICE = fra_rate = fair contract rate of FRA (forward interest
--   rate covering from the Start Date to the Maturity Date of the contract).
-- * P_SETTLEMENT_RATE = current market annual interest rate.
-- * P_FACE_VALUE  = notional principal amount of FRA.
-- * P_DAY_COUNT = number of days between the Settlement Date to Maturity Date.
-- * P_ANNUAL_BASIS = number of days in a year the SETTLEMENT_RATE and
--   DAY_COUNT are based on.
-- * P_SETTLEMENT_AMOUNT = absolute profit or loss amount
-- * p_DEAL_TYPE = an indicator whether the deal subtype is fund ('FUND') or
--   invest ('INVEST'). This affects whether one pay/loss (-) or receive/gain (+)
--   in the settlement.
--
TYPE fra_settlement_out_rec_type is record (p_settlement_amount NUMBER);
TYPE fra_settlement_in_rec_type is record  (p_indicator       VARCHAR2(2),
			    		    p_fra_price       NUMBER,
			    		    p_settlement_rate NUMBER,
			    		    p_face_value      NUMBER,
			    		    p_day_count       NUMBER,
			    		    p_annual_basis    NUMBER,
					    p_deal_subtype    VARCHAR2(7));

/*----------------------------------------------------------------------------
INTEREST_FORWARD_RATE

Calculates the FRA Price (Interest Forward Rate) given either yield rates or
discount factors as input.

INT_FORW_RATE_IN_REC_TYPE
IN:     p_indicator
	p_t num
	p_T1 num
	p_Rt num
	p_RT1 num
	p_year_basis num
INT_FORW_RATE_OUT_REC_TYPE
OUT: 	p_fra_rate num

Assumption:  all interest rates (p_Rt and p_Rt1)  have the same day count
basis.
p_t = number of days from today to start date
p_T1 = number of days from today to maturity date
p_Rt = if p_indicator = 'Y' : annualized interest rate for maturity in
  p_t days, if p_indicator = 'D': discount factor for maturity in p_t days.
p_RT1 = if p_indicator = 'Y' : annualized interest rate for maturity in p_T1
  days, if p_indicator = 'D': discount factor for maturity in p_T1 days.
p_year_basis = number of days in a year the interest rate is based on.
p_fra_rate = fair contract rate of FRA (forward interest rate covering from
  the Start Date to the Maturity Date).
p_indicator = an indicator whether the input rates are yield rates ('Y') or
  discount factors ('D').
----------------------------------------------------------------------------*/
TYPE int_forw_rate_out_rec_type is record (p_fra_rate 	NUMBER);
TYPE int_forw_rate_in_rec_type is record  (p_indicator	VARCHAR2(1),
			    		   p_t       	NUMBER,
			    		   p_T1 	NUMBER,
			    		   p_Rt      	NUMBER,
			    		   p_RT1       	NUMBER,
			    		   p_year_basis	NUMBER);

/*----------------------------------------------------------------------------
BLACK_OPTION_PRICE_CV

Calculates the price of the interest rate option price using Black's Formula.
Record Data Type
BLACK_OPT_CV_IN_REC_TYPE
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

BLACK_OPT_CV_OUT_REC_TYPE
OUT:
p_CAPLET_PRICE num
p_FLOORLET_PRICE num
p_Nd1 num
p_Nd2 num
p_Nd1_A num
p_Nd2_A num

p_PRINCIPAL = the principal amount from which the interest rate is calculated
p_STRIKE_RATE = Rx = simple interest rate for the deal
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
p_CAPLET_PRICE = interest rate collars
p_FLOORLET_PRICE = interest rate floors (CAPLET_PRICE = FLOORLET_PRICE + SWAP_VALUE)
p_Nd1/2 = cumulative distribution value given limit probability values in
  Black's formula = N(x) (refer to Hull's Fourth Edition p.252)
p_Nd1/2_A = N'(x) in Black's formula (refer to Hull's Fourth Edition p.252)
p_COMPOUND_FREQ_SHORT/LONG = frequencies of discretely compounded input/output rate.
This is only necessary if either p_RATE_TYPE_SHORT or p_RATE_TYPE_LONG is 'P'.
p_FORWARD_RATE = forward rate from start date to maturity date with compound frequency equivalent to the time span between start date and maturity date (=simple rate).
----------------------------------------------------------------------------*/
TYPE black_opt_cv_in_rec_type IS RECORD (p_PRINCIPAL  NUMBER,
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

TYPE black_opt_cv_out_rec_type IS RECORD (p_CAPLET_PRICE NUMBER,
				p_FLOORLET_PRICE NUMBER,
				p_FORWARD_FORWARD_RATE NUMBER,
				p_Nd1 NUMBER,
				p_Nd2 NUMBER,
				p_Nd1_A NUMBER,
				p_Nd2_A NUMBER);

----------------------------------------------------------------------------------------------------------------
-- This is just a cover function that determines whether CALC_DAYS_RUN or
-- CALC_DAYS_RUN_B should be called
-- use this procedure instead of CALC_DAYS_RUN if ACT/ACT-BOND day count basis
-- is used
-- When this procedure is called, and if the method is ACT/ACT-BOND,be aware of
-- the fact that year_basis will be
-- calculated incorrectly if start_date and end_date combined do not form a
-- coupon period. So, if year_basis are needed, make sure that, coupon periods
-- are sent in as parameters. num_days are calculated correctly all the time
PROCEDURE CALC_DAYS_RUN_C(start_date IN DATE,
                          end_date   IN DATE,
                          method     IN VARCHAR2,
                          frequency  IN NUMBER,
                          num_days   IN OUT NOCOPY NUMBER,
                          year_basis IN OUT NOCOPY NUMBER,
                          fwd_adjust IN NUMBER DEFAULT NULL,
			  day_count_type IN VARCHAR2 DEFAULT NULL,
			  first_trans_flag IN VARCHAR2 DEFAULT NULL);

-- This calculates the number of days and year basis for bond only day count
-- basis(ACT/ACT-BOND)
-- For ACT/ACT-BOND day count basis, this procedure must be used or preferably
-- through CALC_DAYS_RUN_C. CALC_DAYS_RUN must not be used for the day count
-- basis
-- When this procedure is called, be aware of the fact that year_basis will be
-- calculated incorrectly if start_date and end_date combined do not form a
-- coupon period. So, if year_basis are needed, make sure that, coupon periods
-- are sent in as parameters. num_days are calculated correctly all the time
PROCEDURE CALC_DAYS_RUN_B(start_date IN DATE,
                          end_date   IN DATE,
                          method     IN VARCHAR2,
                          frequency  IN NUMBER,
                          num_days   IN OUT NOCOPY NUMBER,
                          year_basis IN OUT NOCOPY NUMBER);

-- Calculate over a Year Basis and Number of Days ased on different calc
-- methods.  Note that this procedure now supports ACTUAL/365L day count basis,
-- but it does not support ACT/ACT-BOND day count basis. In order to use the day
-- count basis, CALC_DAYS_RUN_C must be used
PROCEDURE CALC_DAYS_RUN(start_date IN DATE,
                        end_date   IN DATE,
                        method     IN VARCHAR2,
                        num_days   IN OUT NOCOPY NUMBER,
                        year_basis IN OUT NOCOPY NUMBER,
                        fwd_adjust IN NUMBER DEFAULT NULL,
			day_count_type IN VARCHAR2 DEFAULT NULL,
			first_trans_flag IN VARCHAR2 DEFAULT NULL);


PROCEDURE future_value(p_in_rec  IN futureValue_in_rec_type,
		       p_out_rec IN OUT NOCOPY futureValue_out_rec_type);

PROCEDURE present_value(p_in_rec  IN presentValue_in_rec_type,
		        p_out_rec IN OUT NOCOPY presentValue_out_rec_type);

PROCEDURE fra_settlement_amount(p_in_rec  IN fra_settlement_in_rec_type,
			    	p_out_rec IN OUT NOCOPY fra_settlement_out_rec_type);

PROCEDURE interest_forward_rate (p_in_rec IN int_forw_rate_in_rec_type,
				p_out_rec OUT NOCOPY int_forw_rate_out_rec_type);

PROCEDURE black_option_price_cv (p_in_rec IN black_opt_cv_in_rec_type,
				p_out_rec OUT NOCOPY black_opt_cv_out_rec_type);


-- added fhu 5/3/02
-- bug 2358592 needed new fields when merged from xtr_calc_p
-- bug 2804548: p_yield can be used for discount margin for FLOATING BOND
TYPE bond_price_yield_in_rec_type is RECORD (
	p_bond_issue_code        	VARCHAR2(7),
	p_settlement_date        	DATE,
	p_ex_cum_next_coupon    	VARCHAR2(3),-- EX,CUM
	p_calculate_yield_or_price	VARCHAR2(1),-- Y,P
	p_yield                  	NUMBER,
	p_accrued_interest    		NUMBER,
	p_clean_price            	NUMBER,
	p_dirty_price           	NUMBER,
	p_input_or_calculator		VARCHAR2(1), -- C,I
	p_commence_date			DATE,
	p_maturity_date			DATE,
	p_prev_coupon_date        	DATE,
	p_next_coupon_date        	DATE,
	p_calc_type			VARCHAR2(15),
	p_year_calc_type		VARCHAR2(15),
	p_accrued_int_calc_basis	VARCHAR2(15),
	p_coupon_freq			NUMBER,
        p_calc_rounding            	NUMBER,
	p_price_rounding           	NUMBER,
        p_price_round_type         	VARCHAR2(2),
	p_yield_rounding		NUMBER,
	p_yield_round_type         	VARCHAR2(2),
	p_coupon_rate			NUMBER,
	p_num_coupons_remain		NUMBER,
        p_day_count_type                VARCHAR2(1),
        p_first_trans_flag              VARCHAR2(1),
        p_currency                      VARCHAR2(15),  -- COMPOUND COUPON
        p_face_value                    NUMBER,        -- COMPOUND COUPON
        p_consideration                 NUMBER,        -- COMPOUND COUPON
        p_rounding_type                 VARCHAR2(1),   -- COMPOUND COUPON
        p_deal_subtype                  VARCHAR2(7));

TYPE bond_price_yield_out_rec_type is RECORD (
	p_yield                  	NUMBER,
	p_accrued_interest    		NUMBER,
	p_clean_price            	NUMBER,
	p_dirty_price           	NUMBER,
	p_actual_ytm                    NUMBER); --bug 2804548

-----------------------------------------------------------------------------
-- COMPOUND COUPON: to return start date or maturity date of the first coupon
-----------------------------------------------------------------------------
FUNCTION  ODD_COUPON_DATE  (p_commence_date IN  DATE,
                            p_maturity_date IN  DATE,
                            p_frequency     IN  NUMBER,
                            p_odd_date_ind  IN  VARCHAR2) return DATE;

-----------------------------------------------------------------------------
-- COMPOUND COUPON: to return total full coupons
-----------------------------------------------------------------------------
FUNCTION  FULL_COUPONS (p_commence_date IN  DATE,
                        p_maturity_date IN  DATE,
                        p_frequency     IN  NUMBER) return NUMBER;

-----------------------------------------------------------------------------
-- COMPOUND COUPON: to return total full coupons
-----------------------------------------------------------------------------
FUNCTION  PREVIOUS_FULL_COUPONS (p_commence_date   IN  DATE,
                                 p_maturity_date   IN  DATE,
                                 p_settlement_date IN  DATE,
                                 p_frequency       IN  NUMBER) return NUMBER;

----------------------------------------------------------------
-- COMPOUND COUPON: to return coupon amount or redemption value
----------------------------------------------------------------
TYPE COMPOUND_CPN_REC_TYPE is RECORD (
        p_bond_start_date       DATE,
        p_odd_coupon_start      DATE,
        p_odd_coupon_maturity   DATE,
        p_full_coupon           NUMBER,
        p_coupon_rate           NUMBER,
        p_maturity_amount       NUMBER,
        p_precision             NUMBER,
        p_rounding_type         VARCHAR2(1),
        p_year_calc_type        VARCHAR2(15),
        p_frequency             NUMBER,
        p_day_count_type        VARCHAR2(10),
        p_amount_redemption_ind VARCHAR2(1));

FUNCTION  CALC_COMPOUND_COUPON_AMT(p_compound_rec    IN  COMPOUND_CPN_REC_TYPE) return NUMBER;

----------------------------------------------------------------
-- COMPOUND COUPON: to return total previous quasi coupon
----------------------------------------------------------------
TYPE BOND_INFO_REC_TYPE is RECORD (
        p_bond_commence         DATE,
        p_odd_coupon_start      DATE,
        p_odd_coupon_maturity   DATE,
        p_calc_date             DATE,        -- either Settlement Date or Accrual Date
        p_yr_calc_type          VARCHAR2(15),
        p_frequency             NUMBER,
        p_curr_coupon           NUMBER,      -- ratio of <Prv_Cpn to p_calc_date> to <Prv_Cpn to Nxt_Cpn>
        p_prv_full_coupon       NUMBER,      -- number of FULL Coupons before p_calc_date
        p_day_count_type        VARCHAR2(10));
FUNCTION  CALC_TOTAL_PREVIOUS_COUPON(p_bond_rec     IN   BOND_INFO_REC_TYPE) return number;


PROCEDURE CALCULATE_BOND_PRICE_YIELD ( p_py_in	IN	BOND_PRICE_YIELD_IN_REC_TYPE,
	                               p_py_out	IN OUT NOCOPY	BOND_PRICE_YIELD_OUT_REC_TYPE);

--Start Bug 2804548
TYPE BndRateFixDate_out_rec is record (rate_fixing_date DATE);
TYPE BndRateFixDate_in_rec is record  (date_in DATE,
		rate_fixing_day NUMBER,
		ccy xtr_bond_issues.currency%TYPE);
PROCEDURE bond_rate_fixing_date_calc(p_in_rec IN BndRateFixDate_in_rec,
				 p_out_rec IN OUT NOCOPY BndRateFixDate_out_rec);

TYPE CalcBondCpnAmt_out_rec is record (coupon_amt NUMBER,
					coupon_tax_amt NUMBER);
TYPE CalcBondCpnAmt_in_rec is record  (deal_no NUMBER,
		transaction_no NUMBER);
PROCEDURE calc_bond_coupon_amt(p_in_rec IN CalcBondCpnAmt_in_rec,
				 p_out_rec IN OUT NOCOPY CalcBondCpnAmt_out_rec);

TYPE ChkCpnRateReset_out_rec is record (yes BOOLEAN,
		deal_no NUMBER);
TYPE ChkCpnRateReset_in_rec is record (deal_type xtr_deal_types.deal_type%TYPE,
		deal_no NUMBER,
		transaction_no NUMBER);
PROCEDURE check_coupon_rate_reset(p_in_rec IN ChkCpnRateReset_in_rec,
				 p_out_rec IN OUT NOCOPY ChkCpnRateReset_out_rec);
--End Bug 2804548

END;


 

/
