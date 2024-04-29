--------------------------------------------------------
--  DDL for Package XTR_RATE_CONVERSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_RATE_CONVERSION" AUTHID CURRENT_USER AS
/* $Header: xtrrtcvs.pls 120.1 2005/06/29 09:32:44 rjose ship $ */

/*----------------------------------------------------------------------------
addition by prafiuly 02/05/01

RATE_CONVERSION: converts between two rates that have different day count basis
 or compounding types.

Note: this procedure does not cover DISCOUNT_TO_YIELD_RATE and
YIELD_TO_DISCOUNT_RATE conversions.

******************************************************************************
IMPORTANT: the result of doing day count basis conversion first and then doing
rate type conversion second is different from the result of doing the rate
type conversion first and then doing the day count basis conversion second.
This causes some inconsistencies in the result. For example: the result of
converting from a simple rate to a compounded rate with different day count
basis and then converting it back to a simple rate type with its original
day count basis will not be the same as the original value of the simple rate.
The problem is not caused by the implementation/coding, but is caused by
methodologies used as described in the Rate Conversions HLD.
******************************************************************************

Assumption: the effective period for the rates is one year.

p_START_DATE = the start date when the rates becomes effective.
p_END_DATE = the end date of the rates.
p_DAY_COUNT_BASIS_IN/OUT = the day count basis for the input rate and the
output rate. This are only necessary if the rates day count basis are different.
p_RATE_TYPE_IN/OUT = the input/output rates type. 'S' for Simple Rate, 'C' for
Continuous Rate, and 'P' for Compounding Rate. This is only necessary if the
conversion involve different rate types.
p_COMPOUND_FREQ_IN/OUT = frequencies of discretely compounded input/output rate.
This is only necessary if either p_RATE_TYPE_IN or p_RATE_TYPE_OUT is 'P'.
p_RATE_IN/OUT = the input/output rates.
-----------------------------------------------------------------------------*/

TYPE rate_conv_in_rec_type is RECORD (p_START_DATE            DATE,
					p_END_DATE            DATE,
					p_DAY_COUNT_BASIS_IN  VARCHAR2(20),
					p_DAY_COUNT_BASIS_OUT VARCHAR2(20),
					p_RATE_TYPE_IN        CHAR,
					p_RATE_TYPE_OUT       CHAR,
					p_COMPOUND_FREQ_IN    NUMBER,
					p_COMPOUND_FREQ_OUT   NUMBER,
					p_RATE_IN             NUMBER);

TYPE rate_conv_out_rec_type is RECORD ( p_RATE_OUT	      NUMBER);


/*---------------------------------------------------------------------------
DISCOUNT_FACTOR_CONV
Converts an annualized yield rate to a discount factor and vice versa

Assumption:
If p_RATE_TYPE, p_COMPOUND_FREQ(if p_RATE_TYPE='P'), p_FUTURE_DATE,
p_SPOT_DATE, and p_DAY_COUNT_BASIS are not null then use them to calculate the
discount factor, else use p_DAY_COUNT and p_ANNUAL_BASIS, if they are not null.
If p_DAY_COUNT is null then p_FUTURE_DATE, p_SPOT_DATE, and p_DAY_COUNT_BASIS
are used to calculate the day count and the annual basis.
The first method should be used to avoid errors due to inconsistent rate type
and problem in determining a period less than or greater than a year
(please refer to Bug 2295869 and related Bug 2354567).

p_INDICATOR = an indicator that tells whether the conversion is from yield
  rate to discount factor ('T') or from discount factor to yield rate ('F').
p_RATE = the annualized yield rate or the discount factor depending on the
  value of the p_INDICATOR.
p_DAY_COUNT = the number of days for which the p_GROWTH_FACTOR is calculated
p_ANNUAL_BASIS = number of days in a year where the p_RATE and the p_DAY_COUNT
  are based on.
p_RESULT = the discount factor  or the annualized yield rate depending on the
  value of the p_INDICATOR.
p_SPOT_DATE = the start date of the p_RATE.
p_FUTURE_DATE = the end date of the p_RATE.
p_RATE_TYPE = the p_RATE rate's type. 'S' for Simple Rate. 'C' for
  Continuous Rate, and 'P' for Compounding Rate.
p_COMPOUND_FREQ = frequencies of discretely compounded input rate.
p_DAY_COUNT_BASIS = the day count basis of p_RATE.
---------------------------------------------------------------------------*/
TYPE df_in_rec_type IS RECORD  (p_indicator       VARCHAR2(1),
		--'T' to convert from yield rate to disc. factor
		--'F' to convert from disc. factor to yield rate
				p_rate            NUMBER,
                        	p_day_count       NUMBER DEFAULT NULL,
                        	p_annual_basis    NUMBER DEFAULT NULL,
				p_spot_date	  DATE,
				p_future_date	  DATE,
				p_day_count_basis VARCHAR2(20),
				p_rate_type       VARCHAR2(1),
				p_compound_freq   NUMBER);
TYPE df_out_rec_type IS RECORD (p_result NUMBER);


--
-- Converts a discount rate to a yield rate.
--
-- * P_DISCOUNT_RATE = the return in discounted security as an annualized
--   percentage of the future amount.
-- * P_DAY_COUNT = number of days between the start deal date and maturity
--   deal date.
-- * P_ANNUAL_BASIS = number of days in a year where the RATE and the
--   P_DAY_COUNT are based on.
-- * P_YIELD_RATE = the return in discounted security as an annualized
--   percentage of the current amount.
--
-- The formula is
-- 			100 * annual basis * discount rate
--   p_discount_rate = ------------------------------------------------
--		      100 * annual basis - day count * discount rate
--
PROCEDURE discount_to_yield_rate(p_discount_rate IN NUMBER,
                             	 p_day_count     IN NUMBER,
                                 p_annual_basis  IN NUMBER,
                             	 p_yield_rate    IN OUT NOCOPY NUMBER);



--
-- Converts a discount rate to a yield rate.
--
-- * P_YIELD_RATE = the return in discounted security as an annualized
--   percentage of the current amount.
-- * P_DAY_COUNT = number of days between the deal start date and deal
--   maturity date.
-- * P_ANNUAL_BASIS = number of days in a year where the RATE and the
--   P_DAY_COUNT are based on.
-- * P_DISCOUNT_RATE = the return in discounted security as an annualized
--   percentage of the future amount.
--
-- The formula is
-- 			100 * annual basis * yield rate
--   p_discount_rate = ---------------------------------------------
--		      100 * annual basis + day count * yield rate
--
PROCEDURE yield_to_discount_rate(p_yield_rate    IN NUMBER,
                             	 p_day_count     IN NUMBER,
                                 p_annual_basis  IN NUMBER,
                             	 p_discount_rate IN OUT NOCOPY NUMBER);

--
-- Converts between rates of different day count basis.
--
-- * P_RATE_IN/OUT= annualized return/rate for the input/output rate.
-- * P_DAY_COUNT_IN/OUT = number of days between the deal start date and
--   deal maturity date for the input rate/output rate.
-- * P_ANNUAL_BASIS_IN/OUT = number of days in a year where the RATE and
--  the P_DAY_COUNT are based on.
--
PROCEDURE  day_count_basis_conv(p_day_count_in     IN NUMBER,
                               	p_day_count_out    IN NUMBER,
                               	p_annual_basis_in  IN NUMBER,
                               	p_annual_basis_out IN NUMBER,
				p_rate_in          IN NUMBER,
                       		p_rate_out         IN OUT NOCOPY NUMBER);


--
-- Converts a simple rate to a continuously compounded rate with
-- the same day count basis.
--
-- * P_SIMPLE_RATE = interest rate per annum that does not compound over time.
-- * P_NUM_YEARS = number of years in the period for which the rate is
--   effective.
-- * P_CONTINUOUS_RATE = compounded rate that has infinitesimal accrual time.
--
PROCEDURE simple_to_continuous_rate(p_simple_rate     IN NUMBER,
                             	    p_num_years       IN NUMBER,
                             	    p_continuous_rate IN OUT NOCOPY NUMBER);



--
-- Converts continuously compounded  rate to a simple rate with
-- the same day count basis.
--
-- * P_SIMPLE_RATE = interest rate per annum that does not compound over time.
-- * P_NUM_YEARS = number of years in the period for which the rate is
--   effective.
-- * P_CONTINUOUS_RATE = compounded rate that has infinitesimal accrual time.
--
PROCEDURE continuous_to_simple_rate(p_continuous_rate IN NUMBER,
                             	    p_num_years       IN NUMBER,
                             	    p_simple_rate     IN OUT NOCOPY NUMBER);



--
-- Converts a simple rate to a discretely compounded rate with the same
-- day count basis.
--
-- * P_SIMPLE_RATE = interest rate per annum that does not compound overtime.
-- * P_NUM_YEARS = number of years in the period for which the rate is
--   effective.
-- * P_COMPOUNDTIMES = accrual frequency in a year for the P_COMPOUNDRATE.
-- * P_COMPOUNDRATE = a discretely compounded rate.
--
PROCEDURE  simple_to_compound_rate(p_simple_rate    IN NUMBER,
				   p_compound_times IN NUMBER,
                             	   p_num_years      IN NUMBER,
                             	   p_compound_rate  IN OUT NOCOPY NUMBER);



--
-- Converts a discretely compounded  rate to a simple rate with the same
-- day count basis.
--
-- * P_SIMPLE_RATE = interest rate per annum that does not compound overtime.
-- * P_NUM_YEARS = number of years in the period for which the rate is
--   effective.
-- * P_COMPOUNDTIMES = accrual frequency in a year for the P_COMPOUNDRATE.
-- * P_COMPOUNDRATE = a discretely compounded rate.
--
PROCEDURE  compound_to_simple_rate(p_compound_rate  IN NUMBER,
				   p_compound_times IN NUMBER,
                             	   p_num_years      IN NUMBER,
            			   p_simple_rate    IN OUT NOCOPY NUMBER);



--
-- Converts a continuously  compounded  rate to a discretely compounded rate
-- with the same day count basis.
--
-- * P_CONTINUOUS_RATE = compounded rate that has infinitesimal accrual time.
-- * P_COMPOUNDRATE = a discretely compounded rate.
-- * P_COMPOUNDTIMES = accrual frequency in a year for the P_COMPOUNDRATE.
--
PROCEDURE  continuous_to_compound_rate(p_continuous_rate IN NUMBER,
				       p_compound_times  IN NUMBER,
                             	       p_compound_rate   IN OUT NOCOPY NUMBER);



--
-- Converts a discretely compounded  rate to a continuously compounded
-- rate with the same day count basis.
--
-- * P_CONTINUOUS_RATE = compounded rate that has infinitesimal accrual time.
-- * P_COMPOUNDRATE = a discretely compounded rate.
-- * P_COMPOUNDTIMES = accrual frequency in a year for the P_COMPOUNDRATE.
--
PROCEDURE compound_to_continuous_rate(p_compound_rate   IN NUMBER,
				      p_compound_times  IN NUMBER,
            			      p_continuous_rate IN OUT NOCOPY NUMBER);



--
-- Converts between two different discretely compounded interest rates with
-- different compounding frequency (with the same day count basis).
--
-- * P_COMPOUNDRATE_IN= a discretely compounded rate that is to be converted.
-- * P_COMPOUNDTIMES_IN/OUT = accrual frequency in a year for the
--   P_COMPOUNDRATE_IN/OUT.
-- * P_COMPOUNDRATE_OUT = a discretely compounded rate that is to be
--   calculated.
--
PROCEDURE  compound_to_compound_rate(p_compound_rate_in   IN NUMBER,
				     p_compound_times_in  IN NUMBER,
				     p_compound_times_out IN NUMBER,
				     p_compound_rate_out  IN OUT NOCOPY NUMBER);



/*----------------------------------------------------------------------------
addition by prafiuly 02/05/01

RATE_CONVERSION: converts between two rates that have different day count basis
 or compounding types.

Note: this procedure does not cover DISCOUNT_TO_YIELD_RATE and
YIELD_TO_DISCOUNT_RATE conversions.

******************************************************************************
IMPORTANT: the result of doing day count basis conversion first and then doing
rate type conversion second is different from the result of doing the rate
type conversion first and then doing the day count basis conversion second.
This causes some inconsistencies in the result. For example: the result of
converting from a simple rate to a compounded rate with different day count
basis and then converting it back to a simple rate type with its original
day count basis will not be the same as the original value of the simple rate.
The problem is not caused by the implementation/coding, but is caused by
methodologies used as described in the Rate Conversions HLD.
******************************************************************************

RATE_CONV_IN_REC_TYPE:
  	p_START_DATE date
	p_END_DATE date
	p_DAY_COUNT_BASIS_IN varchar2
	p_DAY_COUNT_BASIS_OUT varchar2
	p_RATE_TYPE_IN char
	p_RATE_TYPE _OUT char
	p_COMPOUND_FREQ_IN num
	p_COMPOUND_FREQ_OUT num
	p_RATE_IN num
RATE_CONV_OUT_REC_TYPE:
	p_ RATE_OUT num

Formula:
Call XTR_CALC_P.DAYS_CALC_RUN_C(...);
IF p_DAY_COUNT_BASIS_IN?OUT is NOT NULL THEN
  Call DAY_COUNT_BASIS_CONV(...)
IF p_RATE_TYPE_IN/OUT is NOT NULL THEN
  Calculate v_Num_Years
  Depending on p_RATE_TYPE_IN/OUT, call the appropriate Rate Types Conversion
    procedure (from above).

Assumption: the effective period for the rates is one year.

p_START_DATE = the start date when the rates becomes effective.
p_END_DATE = the end date of the rates.
p_DAY_COUNT_BASIS_IN/OUT = the day count basis for the input rate and the
  output rate. This are only necessary if the rates day count basis are
  different.
p_RATE_TYPE_IN/OUT = the input/output rates type. 'S' for Simple Rate, 'C' for
  Continuous Rate, and 'P' for Compounding Rate. This is only necessary if the
  conversion involve different rate types.
p_COMPOUND_FREQ_IN/OUT = frequencies of discretely compounded input/output
  rate.
  This is only necessary if either p_RATE_TYPE_IN or p_RATE_TYPE_OUT is 'P'.
p_RATE_IN/OUT = the input/output rates.
-----------------------------------------------------------------------------*/
PROCEDURE rate_conversion (p_in_rec  IN     rate_conv_in_rec_type,
			   p_out_rec IN OUT NOCOPY rate_conv_out_rec_type);


--
--YIELD_TO_DISCOUNT_FACTOR_SHORT
--Converts an annualized yield rate to a discount factor, assuming the number
--of days between spot date and maturity date is less than or equal to a year.
--
-- * P_RATE = the annualized yield rate.
-- * P_DAY_COUNT = the number of days for which the GROWTH_FACTOR
--   is calculated
-- * P_ANNUAL_BASIS = number of days in a year where the RATE and the
--   DAY_COUNT are based on
-- * P_DISCOUNT_FACTOR = the value of the consideration/present value
--   in order to have $1 in the maturity date (after DAY_COUNT period)
--
PROCEDURE yield_to_discount_factor_short(p_rate   IN NUMBER,
                        	p_day_count       IN NUMBER,
                        	p_annual_basis    IN NUMBER,
                        	p_discount_factor IN OUT NOCOPY NUMBER);


--
--YIELD_TO_DISCOUNT_FACTOR_LONG
--Converts an annualized yield rate to a discount factor, assuming the number
--of days between spot date and maturity date is less than or equal to a year.
--
-- Calculates the value of the consideration/present value
-- in order to have $1 in the maturity date (after DAY_COUNT period),
-- assuming more than a year DAY_COUNT period.
--
-- * P_RATE = the annualized yield rate.
-- * P_DAY_COUNT = the number of days for which the GROWTH_FACTOR
--   is calculated
-- * P_ANNUAL_BASIS = number of days in a year where the RATE and the
--   DAY_COUNT are based on
-- * P_DISCOUNT_FACTOR = the value of the consideration/present value
--   in order to have $1 in the maturity date (after DAY_COUNT period)
--
PROCEDURE yield_to_discount_factor_long(p_rate    IN NUMBER,
                        	p_day_count       IN NUMBER,
                        	p_annual_basis    IN NUMBER,
                        	p_discount_factor IN OUT NOCOPY NUMBER);

--
--DISCOUNT_FACTOR_TO_YIELD_SHORT
--Converts a discount factor to an annualized yield rate, assuming the number
--of days between spot date and maturity date is less than or equal to a year.
--
-- * P_RATE = the annualized yield rate.
-- * P_DAY_COUNT = the number of days for which the GROWTH_FACTOR
--   is calculated
-- * P_ANNUAL_BASIS = number of days in a year where the RATE and the
--   DAY_COUNT are based on
-- * P_DISCOUNT_FACTOR = the value of the consideration/present value
--   in order to have $1 in the maturity date (after DAY_COUNT period)
--
PROCEDURE discount_factor_to_yield_short(p_discount_factor IN NUMBER,
                        	p_day_count       IN NUMBER,
                        	p_annual_basis    IN NUMBER,
                        	p_rate 		  IN OUT NOCOPY NUMBER);


--
--DISCOUNT_FACTOR_TO_YIELD_LONG
--Converts an annualized yield rate to a discount factor, assuming the number
--of days between spot date and maturity date is more than a year.
--
-- * P_RATE = the annualized yield rate.
-- * P_DAY_COUNT = the number of days for which the GROWTH_FACTOR
--   is calculated
-- * P_ANNUAL_BASIS = number of days in a year where the RATE and the
--   DAY_COUNT are based on
-- * P_DISCOUNT_FACTOR = the value of the consideration/present value
--   in order to have $1 in the maturity date (after DAY_COUNT period)
--
PROCEDURE discount_factor_to_yield_long(p_discount_factor IN NUMBER,
                        	p_day_count       IN NUMBER,
                        	p_annual_basis    IN NUMBER,
                        	p_rate 		  IN OUT NOCOPY NUMBER);


/*---------------------------------------------------------------------------
DISCOUNT_FACTOR_CONV
Converts an annualized yield rate to a discount factor and vice versa

Assumption:
If p_RATE_TYPE, p_COMPOUND_FREQ(if p_RATE_TYPE='P'), p_FUTURE_DATE,
p_SPOT_DATE, and p_DAY_COUNT_BASIS are not null then use them to calculate the
discount factor, else use p_DAY_COUNT and p_ANNUAL_BASIS, if they are not null.
If p_DAY_COUNT is null then p_FUTURE_DATE, p_SPOT_DATE, and p_DAY_COUNT_BASIS
are used to calculate the day count and the annual basis.
The first method should be used to avoid errors due to inconsistent rate type
and problem in determining a period less than or greater than a year
(please refer to Bug 2295869 and related Bug 2354567).

p_INDICATOR = an indicator that tells whether the conversion is from yield
  rate to discount factor ('T') or from discount factor to yield rate ('F').
p_RATE = the annualized yield rate or the discount factor depending on the
  value of the p_INDICATOR.
p_DAY_COUNT = the number of days for which the p_GROWTH_FACTOR is calculated
p_ANNUAL_BASIS = number of days in a year where the p_RATE and the p_DAY_COUNT
  are based on.
p_RESULT = the discount factor  or the annualized yield rate depending on the
  value of the p_INDICATOR.
p_SPOT_DATE = the start date of the p_RATE.
p_FUTURE_DATE = the end date of the p_RATE.
p_RATE_TYPE = the p_RATE rate's type. 'S' for Simple Rate. 'C' for
  Continuous Rate, and 'P' for Compounding Rate.
p_COMPOUND_FREQ = frequencies of discretely compounded input rate.
---------------------------------------------------------------------------*/
PROCEDURE discount_factor_conv(p_in_rec  IN df_in_rec_type,
			  p_out_rec IN OUT NOCOPY df_out_rec_type);


/*----------------------------------------------------------------------------
RATE_CONV_SIMPLE_ANNUALIZED: converts the given rate to a simple rate
if the period between p_START_DATE and p_END_DATE is less than or equal
to a year or
to an annually compounded rate if the period between p_START_DATE and
p_END_DATE is greater than a year.

******************************************************************************
IMPORTANT: The above is currently the assumption for the System Rates, and
what is expected for some of the cover routine API.
******************************************************************************

Moreover, if p_DAY_COUNT_BASIS_OUT is NULL, this procedure will keep the
day count basis of p_RATE_IN, otherwise it will convert to whatever defined
in p_DAY_COUNT_BASIS_OUT.

Note: this procedure does not cover DISCOUNT_TO_YIELD_RATE and
YIELD_TO_DISCOUNT_RATE conversions.

RATE_CONV_IN_REC_TYPE:
  	p_START_DATE date
	p_END_DATE date
	p_DAY_COUNT_BASIS_IN varchar2
	p_DAY_COUNT_BASIS_OUT varchar2
	p_RATE_TYPE_IN char
	p_COMPOUND_FREQ_IN num
	p_RATE_IN num
RATE_CONV_OUT_REC_TYPE:
	p_RATE_OUT num

Assumption: the effective period for the rates is one year.

p_START_DATE = the start date when the rates becomes effective.
p_END_DATE = the end date of the rates.
p_DAY_COUNT_BASIS_IN/OUT = the day count basis for the input rate and the
  output rate. This are only necessary if the rates day count basis are
  different.
p_RATE_TYPE_IN = the input rates type. 'S' for Simple Rate, 'C' for
  Continuous Rate, and 'P' for Compounding Rate. This is only necessary if the
  conversion involve different rate types.
p_COMPOUND_FREQ_IN = frequencies of discretely compounded input
  rate.
  This is only necessary if either p_RATE_TYPE_IN or p_RATE_TYPE_OUT is 'P'.
p_RATE_IN/OUT = the input/output rates.
-----------------------------------------------------------------------------*/
PROCEDURE rate_conv_simple_annualized (p_in_rec IN rate_conv_in_rec_type,
			   p_out_rec IN OUT NOCOPY rate_conv_out_rec_type);


END;


 

/
