--------------------------------------------------------
--  DDL for Package Body XTR_RATE_CONVERSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_RATE_CONVERSION" AS
/* $Header: xtrrtcvb.pls 120.1 2005/06/29 09:32:59 rjose ship $ */

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
                             	 p_yield_rate    IN OUT NOCOPY NUMBER) IS
  v_growth_fac NUMBER;

BEGIN

  xtr_mm_formulas.growth_factor(p_discount_rate, p_day_count,
				p_annual_basis, v_growth_fac);

  p_yield_rate := p_discount_rate * (1/(1 - (v_growth_fac - 1)));

END discount_to_yield_rate;



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
                             	 p_discount_rate IN OUT NOCOPY NUMBER) IS
  v_growth_fac NUMBER;

BEGIN

  xtr_mm_formulas.growth_factor(p_yield_rate, p_day_count,
				p_annual_basis, v_growth_fac);

  p_discount_rate := p_yield_rate/v_growth_fac;

END yield_to_discount_rate;


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
                       		p_rate_out         IN OUT NOCOPY NUMBER) IS

BEGIN

  IF (p_day_count_out <> 0) THEN
    p_rate_out := (p_day_count_in * p_annual_basis_out * p_rate_in)/
			(p_day_count_out * p_annual_basis_in);
  ELSE
    p_rate_out := p_rate_in;
  END IF;

END day_count_basis_conv;


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
                             	    p_continuous_rate IN OUT NOCOPY NUMBER) IS

BEGIN

  p_continuous_rate := (LN(1 +(p_simple_rate/100)*p_num_years)/p_num_years)*100;

END simple_to_continuous_rate;


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
                             	    p_simple_rate     IN OUT NOCOPY NUMBER) IS
BEGIN

  p_simple_rate := 100*(EXP((p_continuous_rate/100)*p_num_years)-1)/p_num_years;

END continuous_to_simple_rate;



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
                             	   p_compound_rate  IN OUT NOCOPY NUMBER) IS

BEGIN

  p_compound_rate := 100 * p_compound_times * (POWER((1 + (p_simple_rate/100) *
	p_num_years), 1/(p_compound_times * p_num_years)) - 1);

END simple_to_compound_rate;



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
            			   p_simple_rate    IN OUT NOCOPY NUMBER) IS
BEGIN

  p_simple_rate := 100 * (POWER((1 + (p_compound_rate/100)/p_compound_times),
		        (p_num_years * p_compound_times)) - 1) / p_num_years;

END compound_to_simple_rate;


--
-- Converts a continuously  compounded  rate to a discretely compounded rate
-- with the same day count basis.
--
-- * P_CONTINUOUS_RATE = compounded rate that has infinitesimal accrual time.
-- * P_COMPOUNDRATE = a discretely compounded rate.
-- * P_COMPOUNDTIMES = accrual frequency in a year for the P_COMPOUNDRATE.
--
PROCEDURE  continuous_to_compound_rate(
				p_continuous_rate IN NUMBER,
				p_compound_times  IN NUMBER,
                             	p_compound_rate   IN OUT NOCOPY NUMBER) IS
BEGIN

  p_compound_rate := 100 * p_compound_times * (EXP((p_continuous_rate/100)/
		p_compound_times) - 1);

END continuous_to_compound_rate;


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
            			      p_continuous_rate IN OUT NOCOPY NUMBER) IS
BEGIN

  p_continuous_rate := 100 * p_compound_times * LN(1 + (p_compound_rate/100)/
			p_compound_times);

END compound_to_continuous_rate;


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
PROCEDURE  compound_to_compound_rate(
			     p_compound_rate_in   IN NUMBER,
			     p_compound_times_in  IN NUMBER,
			     p_compound_times_out IN NUMBER,
			     p_compound_rate_out  IN OUT NOCOPY NUMBER) IS

BEGIN

  p_compound_rate_out := 100 * p_compound_times_out *
		(POWER((1 + (p_compound_rate_in/100)/p_compound_times_in),
			 (p_compound_times_in/p_compound_times_out)) - 1);

END compound_to_compound_rate;


/*----------------------------------------------------------------------------
addition by prafiuly 02/05/01

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

RATE_CONVERSION: converts between two rates that have different day count basis
 or compounding types.

Note: this procedure does not cover DISCOUNT_TO_YIELD_RATE and
YIELD_TO_DISCOUNT_RATE conversions.

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
output rate. This are only necessary if the rates day count basis are different.
p_RATE_TYPE_IN/OUT = the input/output rates type. 'S' for Simple Rate, 'C' for
Continuous Rate, and 'P' for Compounding Rate. This is only necessary if the
conversion involve different rate types.
p_COMPOUND_FREQ_IN/OUT = frequencies of discretely compounded input/output rate.
This is only necessary if either p_RATE_TYPE_IN or p_RATE_TYPE_OUT is 'P'.
p_RATE_IN/OUT = the input/output rates.
-----------------------------------------------------------------------------*/

PROCEDURE rate_conversion (p_in_rec  IN     rate_conv_in_rec_type,
			   p_out_rec IN OUT NOCOPY rate_conv_out_rec_type) is

  v_num_years NUMBER;
  v_dummy NUMBER;
  v_day_count_in NUMBER;
  v_ann_basis_in NUMBER;
  v_day_count_out NUMBER;
  v_ann_basis_out NUMBER;
  v_temp_rate NUMBER;
  v_rt_in CHAR;
  v_rt_out CHAR;
  e_invalid_rate_type EXCEPTION;
  e_invalid_dc_basis EXCEPTION;

BEGIN

  IF (p_in_rec.p_day_count_basis_out IS NOT NULL) THEN
    xtr_calc_p.calc_days_run_c(p_in_rec.p_start_date, p_in_rec.p_end_date,
				p_in_rec.p_day_count_basis_out, v_dummy,
				v_day_count_out, v_ann_basis_out);
    IF (p_in_rec.p_day_count_basis_in IS NOT NULL) and
    (p_in_rec.p_day_count_basis_in <> p_in_rec.p_day_count_basis_out) THEN
      xtr_calc_p.calc_days_run_c(p_in_rec.p_start_date, p_in_rec.p_end_date,
				p_in_rec.p_day_count_basis_in, v_dummy,
				v_day_count_in, v_ann_basis_in);
      day_count_basis_conv(v_day_count_in, v_day_count_out, v_ann_basis_in,
			 v_ann_basis_out, p_in_rec.p_rate_in, v_temp_rate);
    ELSE
      v_temp_rate := p_in_rec.p_rate_in;
    END IF;
  ELSE
    RAISE e_invalid_dc_basis;
  END IF;

  IF (p_in_rec.p_rate_type_in IS NOT NULL) and
   (p_in_rec.p_rate_type_out IS NOT NULL) and
  -- Avoid having the same in/out rate types except for compounding rates
   ((p_in_rec.p_rate_type_in <> p_in_rec.p_rate_type_out) or
    (upper(p_in_rec.p_rate_type_in)='P' and upper(p_in_rec.p_rate_type_out)='P'))
  THEN
     v_rt_in := upper(p_in_rec.p_rate_type_in);
     v_rt_out := upper(p_in_rec.p_rate_type_out);
     IF (v_rt_in IN ('C','S','P')) and (v_rt_out IN ('C','S','P')) THEN
       IF (v_rt_in = 'S') THEN
 	 IF (v_rt_out = 'C') THEN
           v_num_years := v_day_count_out/v_ann_basis_out;
           simple_to_continuous_rate(v_temp_rate,v_num_years,
 					p_out_rec.p_rate_out);
	 ELSIF (v_rt_out = 'P') THEN
           v_num_years := v_day_count_out/v_ann_basis_out;
	   simple_to_compound_rate(v_temp_rate,p_in_rec.p_compound_freq_out,
					v_num_years, p_out_rec.p_rate_out);
         END IF;
       ELSIF (v_rt_in = 'C') THEN
         IF (v_rt_out = 'S') THEN
           v_num_years := v_day_count_out/v_ann_basis_out;
           continuous_to_simple_rate(v_temp_rate,v_num_years,
 					p_out_rec.p_rate_out);
	 ELSIF (v_rt_out = 'P') THEN
           continuous_to_compound_rate(v_temp_rate,p_in_rec.p_compound_freq_out,
 					p_out_rec.p_rate_out);
         END IF;
       ELSIF (v_rt_in = 'P') THEN
         IF (v_rt_out = 'S') THEN
           v_num_years := v_day_count_out/v_ann_basis_out;
           compound_to_simple_rate(v_temp_rate,p_in_rec.p_compound_freq_in,
					v_num_years, p_out_rec.p_rate_out);
	 ELSIF (v_rt_out = 'C') THEN
           compound_to_continuous_rate(v_temp_rate,p_in_rec.p_compound_freq_in,
 					p_out_rec.p_rate_out);
	 ELSIF (v_rt_out = 'P') THEN
           compound_to_compound_rate(v_temp_rate,p_in_rec.p_compound_freq_in,
					p_in_rec.p_compound_freq_out,
 					p_out_rec.p_rate_out);
         END IF;
       END IF;
     ELSE
       RAISE e_invalid_rate_type;
     END IF;
  ELSE
     p_out_rec.p_rate_out := v_temp_rate;
  END IF;


EXCEPTION

  WHEN e_invalid_rate_type THEN
      RAISE_APPLICATION_ERROR
        (-20001, 'Rate Type code can only be ''C'',''S'',''P''.');
  WHEN e_invalid_dc_basis THEN
      RAISE_APPLICATION_ERROR
        (-20002, 'p_DAY_COUNT_BASIS_OUT cannot be null');

END rate_conversion;

--
--YIELD_TO_DISCOUNT_FACTOR_SHORT
--Converts an annualized yield rate to a discount factor, assuming the number
--of days between spot date and maturity date is less than or equal to a year.
--
-- * P_RATE = the annual rate.
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
                        	p_discount_factor IN OUT NOCOPY NUMBER) is
BEGIN

  p_discount_factor := 1/(1+((p_rate/100)*p_day_count/p_annual_basis));

END yield_to_discount_factor_short;


--
--YIELD_TO_DISCOUNT_FACTOR_LONG
--Converts an annualized yield rate to a discount factor, assuming the number
--of days between spot date and maturity date is less than or equal to a year.
--
-- * P_RATE = the annual rate.
-- * P_DAY_COUNT = the number of days for which the GROWTH_FACTOR
--   is calculated
-- * P_ANNUAL_BASIS = number of days in a year where the RATE and the
--   DAY_COUNT are based on
-- * P_DISCOUNT_FACTOR = the value of the consideration/present value
--   in order to have $1 in the maturity date (after DAY_COUNT period)
--
PROCEDURE yield_to_discount_factor_long(p_rate             IN NUMBER,
                        	p_day_count       IN NUMBER,
                        	p_annual_basis    IN NUMBER,
                        	p_discount_factor IN OUT NOCOPY NUMBER) is
BEGIN

  p_discount_factor := 1/power((1+(p_rate/100)),(p_day_count/p_annual_basis));

END yield_to_discount_factor_long;


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
                        	p_rate 		  IN OUT NOCOPY NUMBER) IS
BEGIN

  p_rate := (((1/p_discount_factor)-1)*p_annual_basis/p_day_count)*100;

END discount_factor_to_yield_short;


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
                        	p_rate 		  IN OUT NOCOPY NUMBER) IS
BEGIN

  p_rate := (power((1/p_discount_factor),(p_annual_basis/p_day_count))-1)*100;

END discount_factor_to_yield_long;


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
PROCEDURE discount_factor_conv(p_in_rec  IN df_in_rec_type,
			  p_out_rec IN OUT NOCOPY df_out_rec_type) IS

  v_day_count NUMBER;
  v_annual_basis NUMBER;
  v_day_count_act NUMBER;
  v_ann_basis_act NUMBER;
  v_rate NUMBER;
  v_cf_necessary BOOLEAN := FALSE;
  v_rc_in xtr_rate_conversion.rate_conv_in_rec_type;
  v_rc_out xtr_rate_conversion.rate_conv_out_rec_type;

BEGIN
  --Determine whether p_compounding_freq is necessary
  IF p_in_rec.p_rate_type='P' THEN
    v_cf_necessary := TRUE;
  END IF;

  --Determine whether we need to calc using p_RATE_TYPE,
  --p_COMPOUND_FREQ(if p_RATE_TYPE='P'), p_FUTURE_DATE,
  --p_SPOT_DATE, and p_DAY_COUNT_BASIS
  IF p_in_rec.p_future_date IS NOT NULL AND p_in_rec.p_spot_date IS NOT NULL
  AND p_in_rec.p_day_count_basis IS NOT NULL AND p_in_rec.p_rate_type IS NOT
  NULL AND p_in_rec.p_indicator = 'T' AND v_cf_necessary THEN
    --Calculate the annual basis and day count based on ACT/ACT to get
    --fair comparison
    xtr_calc_p.calc_days_run_c(p_in_rec.p_spot_date, p_in_rec.p_future_date,
			'ACTUAL/ACTUAL', null, v_day_count_act,
			v_ann_basis_act);
    --Made sure the rate is Simple for < 1 Year and annualized for >= 1 Year.
    v_rc_in.p_rate_type_in := p_in_rec.p_rate_type;
    v_rc_in.p_day_count_basis_in := p_in_rec.p_day_count_basis;
    v_rc_in.p_rate_in := p_in_rec.p_rate;
    v_rc_in.p_start_date := p_in_rec.p_spot_date;
    v_rc_in.p_end_date := p_in_rec.p_future_date;
    v_rc_in.p_compound_freq_in := p_in_rec.p_compound_freq;
    xtr_rate_conversion.rate_conv_simple_annualized(v_rc_in, v_rc_out);
    v_rate := v_rc_out.p_rate_out;
    --get annual basis and day count based on the given day count basis
    xtr_calc_p.calc_days_run_c(p_in_rec.p_spot_date,
			p_in_rec.p_future_date,
			p_in_rec.p_day_count_basis, null, v_day_count,
			v_annual_basis);
  ELSIF p_in_rec.p_annual_basis IS NOT NULL AND p_in_rec.p_day_count IS NOT
  NULL THEN
    v_day_count_act := p_in_rec.p_day_count;
    v_ann_basis_act := p_in_rec.p_annual_basis;
    v_rate := p_in_rec.p_rate;
    v_day_count := p_in_rec.p_day_count;
    v_annual_basis := p_in_rec.p_annual_basis;
  ELSE
    --Calculate the annual basis and day count based on ACT/ACT to get
    --fair comparison
    xtr_calc_p.calc_days_run_c(p_in_rec.p_spot_date, p_in_rec.p_future_date,
			'ACTUAL/ACTUAL', null, v_day_count_act,
			v_ann_basis_act);
    v_rate := p_in_rec.p_rate;
    xtr_calc_p.calc_days_run_c(p_in_rec.p_spot_date,
			p_in_rec.p_future_date,
			p_in_rec.p_day_count_basis, null, v_day_count,
			v_annual_basis);
  END IF;

  --start the logic to determine which discount factor conversion should be
  --called
  IF (p_in_rec.p_indicator = 'F') THEN
    IF (v_ann_basis_act >= v_day_count_act) THEN
      --do the less than a year discount factor
      discount_factor_to_yield_short(v_rate,
					v_day_count,
					v_annual_basis,
					p_out_rec.p_result);
    ELSE
      --do the more than a year discount factor
      discount_factor_to_yield_long(v_rate,
					v_day_count,
					v_annual_basis,
					p_out_rec.p_result);
    END IF;
  ELSE --(p_in_rec.p_indicator = 'T')
    IF (v_ann_basis_act >= v_day_count_act) THEN
      --do the less than a year discount factor
      yield_to_discount_factor_short(v_rate,
					v_day_count,
					v_annual_basis,
					p_out_rec.p_result);
    ELSE
      --do the more than a year discount factor
      yield_to_discount_factor_long(v_rate,
					v_day_count,
					v_annual_basis,
					p_out_rec.p_result);
    END IF;
  END IF;

END discount_factor_conv;


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
p_RATE = the annualized yield rate or the discount factor depending on the
  value of the p_INDICATOR.
p_RATE_TYPE_IN = the input rates type. 'S' for Simple Rate, 'C' for
  Continuous Rate, and 'P' for Compounding Rate. This is only necessary if the
  conversion involve different rate types.
p_COMPOUND_FREQ_IN = frequencies of discretely compounded input
  rate.
  This is only necessary if either p_RATE_TYPE_IN or p_RATE_TYPE_OUT is 'P'.
p_RATE_IN/OUT = the input/output rates.
-----------------------------------------------------------------------------*/
PROCEDURE rate_conv_simple_annualized (p_in_rec IN rate_conv_in_rec_type,
			   p_out_rec IN OUT NOCOPY rate_conv_out_rec_type) IS
  v_day_count NUMBER;
  v_ann_basis NUMBER;
  v_rc_in rate_conv_in_rec_type;
  v_rc_out rate_conv_out_rec_type;
BEGIN
  --find out whether the rate less than a year or not
  xtr_calc_p.calc_days_run_c(p_in_rec.p_start_date, p_in_rec.p_end_date,
				'ACTUAL/ACTUAL', null,
				v_day_count, v_ann_basis);
  IF v_day_count<=v_ann_basis THEN --convert to simple rate
     --only converts if not Simple rate already
     IF p_in_rec.p_rate_type_out='S' AND
     (p_in_rec.p_day_count_basis_out IS NULL OR
      p_in_rec.p_day_count_basis_in=p_in_rec.p_day_count_basis_out) THEN
        p_out_rec.p_rate_out := p_in_rec.p_rate_in;
     ELSE
        v_rc_in.p_rate_type_out := 'S';
        IF p_in_rec.p_day_count_basis_out IS NULL THEN
           v_rc_in.p_day_count_basis_out := p_in_rec.p_day_count_basis_in;
        ELSE
           v_rc_in.p_day_count_basis_out := p_in_rec.p_day_count_basis_out;
        END IF;
        v_rc_in.p_rate_type_in := p_in_rec.p_rate_type_in;
        v_rc_in.p_day_count_basis_in := p_in_rec.p_day_count_basis_in;
        v_rc_in.p_rate_in := p_in_rec.p_rate_in;
        v_rc_in.p_start_date := p_in_rec.p_start_date;
        v_rc_in.p_end_date := p_in_rec.p_end_date;
        v_rc_in.p_compound_freq_in := p_in_rec.p_compound_freq_in;
        xtr_rate_conversion.rate_conversion(v_rc_in, v_rc_out);
        p_out_rec.p_rate_out := v_rc_out.p_rate_out;
     END IF;
  ELSE --convert to annually compounding
     --only converts if not Annually compounding rate already
     IF (p_in_rec.p_rate_type_out='P' AND p_in_rec.p_compound_freq_in=1)
     AND (p_in_rec.p_day_count_basis_out IS NULL OR
     p_in_rec.p_day_count_basis_in=p_in_rec.p_day_count_basis_out) THEN
        p_out_rec.p_rate_out := p_in_rec.p_rate_in;
     ELSE
        v_rc_in.p_rate_type_out := 'P';
        IF p_in_rec.p_day_count_basis_out IS NULL THEN
           v_rc_in.p_day_count_basis_out := p_in_rec.p_day_count_basis_in;
        ELSE
           v_rc_in.p_day_count_basis_out := p_in_rec.p_day_count_basis_out;
        END IF;
        v_rc_in.p_rate_type_in := p_in_rec.p_rate_type_in;
        v_rc_in.p_day_count_basis_in := p_in_rec.p_day_count_basis_in;
        v_rc_in.p_rate_in := p_in_rec.p_rate_in;
        v_rc_in.p_start_date := p_in_rec.p_start_date;
        v_rc_in.p_end_date := p_in_rec.p_end_date;
        v_rc_in.p_compound_freq_in := p_in_rec.p_compound_freq_in;
        v_rc_in.p_compound_freq_out := 1;
        xtr_rate_conversion.rate_conversion(v_rc_in, v_rc_out);
        p_out_rec.p_rate_out := v_rc_out.p_rate_out;
     END IF;
  END IF;
END rate_conv_simple_annualized;

END;


/
