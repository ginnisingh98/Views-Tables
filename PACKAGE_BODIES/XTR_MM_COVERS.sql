--------------------------------------------------------
--  DDL for Package Body XTR_MM_COVERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_MM_COVERS" AS
/* $Header: xtrmmcvb.pls 120.29.12010000.2 2008/08/06 10:43:40 srsampat ship $ */

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
                          fwd_adjust IN NUMBER,
			  day_count_type IN VARCHAR2,
			  first_trans_flag IN VARCHAR2) is
--
begin
   if method = 'ACT/ACT-BOND' then
      CALC_DAYS_RUN_B(start_date,end_date,method,frequency, num_days,
                      year_basis);
   else
      -- Added the day_count_type and first_trans_flag paramters
      -- for Interest override feature.

      CALC_DAYS_RUN(start_date,end_date,method, num_days,year_basis, fwd_adjust,
		    day_count_type, first_trans_flag);
   end if;
end CALC_DAYS_RUN_C;


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
                          year_basis IN OUT NOCOPY NUMBER) is
--
   l_start_date DATE := start_date;
   l_end_date   DATE := end_date;

   l_start_year NUMBER := to_number(to_char(start_date,'YYYY'));
   l_end_year NUMBER := to_number(to_char(end_date,'YYYY'));

--
begin
   if start_date is not null and end_date is not null and method is not null then
      if l_end_date <l_start_date then
         FND_MESSAGE.Set_Name('XTR', 'XTR_1059');
         APP_EXCEPTION.raise_exception;
      else
         num_days := l_end_date - l_start_date;
         if method = 'ACT/ACT-BOND' then
            year_basis:=(l_end_date-l_start_date) * frequency;
         else
            APP_EXCEPTION.raise_exception;
         end if;
      end if;
   end if;
end CALC_DAYS_RUN_B;


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
                        first_trans_flag IN VARCHAR2 DEFAULT NULL) is
-- Bug 3511403 start Used the same code of calc_days_run_ig in xtr_calc_p package to make it generic fix
--
   l_start_date DATE := start_date;
   l_end_date   DATE := end_date;
   l_start_year NUMBER := to_number(to_char(start_date,'YYYY'));
   l_end_year NUMBER := to_number(to_char(end_date,'YYYY'));
   start_year_basis     NUMBER;
   end_year_basis       NUMBER;
   l_total_days         NUMBER;
   l_total_year NUMBER:= l_end_year - l_start_year;
--
begin
   -- Bug 6743063 start commented below code
 /* if day_count_type = 'L' or day_count_type = 'B' then
     l_start_date :=l_start_date +1;
     l_end_date := l_end_date +1 ;
   end if; */
   -- Bug 6743063 end
   if start_date is not null and end_date is not null and method is not null then

      if l_end_date <l_start_date then
         FND_MESSAGE.Set_Name('XTR', 'XTR_1059');
         APP_EXCEPTION.raise_exception;

      else

         -------------------------------
         -- For all ACTUAL year basis --
         -------------------------------
         if substr(method,1,6) = 'ACTUAL' then
            num_days := l_end_date - l_start_date;
            year_basis := 365;

            if method = 'ACTUAL360' then
               year_basis := 360;
            elsif method = 'ACTUAL365' then
               year_basis := 365;
            elsif method = 'ACTUAL365L' then
               -- if the "to year" is a leap year use 366 day count basis. Otherwise, use 365
               if to_char(last_day(to_date('01/02'||to_char(l_end_date,'YYYY'),'DD/MM/YYYY')),'DD') = '29' then
                  year_basis:=366;
               else
                  year_basis:=365;
               end if;
            elsif method = 'ACTUAL/ACTUAL' then
              -- Bug 3511403 start
	      -- Bug 6880961 start added condition start year not equal to end year
               if (day_count_type = 'L' or day_count_type = 'B') and (l_end_year <> l_start_year ) then
                 l_start_date :=l_start_date +1;
                 l_end_date := l_end_date +1 ;
               end if;
             -- Bug 3511403 end
            /***************************************************************/
            /* Bug 3511403 Correct Actual/Actual calculation  */
            /***************************************************************/
               If l_end_year = l_start_year then -- same year. Determine whether it's leap year.
                  if to_char(last_day(to_date('01/02'||to_char(l_end_date,'YYYY'),
                     'DD/MM/YYYY')),'DD') = '29' then
                     year_basis := 366;
                  else
                     year_basis := 365;
                  end if;
               else
                  if to_char(last_day(to_date('01/02'||to_char(l_start_date,'YYYY'),
                     'DD/MM/YYYY')),'DD') = '29' then
                     IF day_count_type='B' AND first_trans_flag ='Y' THEN
                        start_year_basis := (to_date('1/1/'||to_char(l_start_year+1),'DD/MM/YYYY')                                - l_start_date + 1) /366;
                     else
                        start_year_basis := (to_date('1/1/'||to_char(l_start_year+1),'DD/MM/YYYY')
                                - l_start_date) /366;
                     end if;
                  else
                     IF day_count_type='B' AND first_trans_flag ='Y' THEN
                        start_year_basis := (to_date('1/1/'||to_char(l_start_year+1),'DD/MM/YYYY')                                    - l_start_date + 1) / 365;
                     else
                        start_year_basis := (to_date('1/1/'||to_char(l_start_year+1),'DD/MM/YYYY')                                    - l_start_date) / 365;
                     end if;
                  end if;

                  if to_char(last_day(to_date('01/02'||to_char(l_end_date,'YYYY'),
                     'DD/MM/YYYY')),'DD') = '29' then
                     end_year_basis := (l_end_date - to_date('1/1/'||to_char(l_end_year),
                                        'DD/MM/YYYY')) / 366;
                  else
                     end_year_basis := (l_end_date - to_date('1/1/'||to_char(l_end_year),
                                        'DD/MM/YYYY')) / 365;
                  end if;

                  IF day_count_type='B' AND first_trans_flag ='Y' THEN
                      l_total_days := num_days +1;
                  else
                      l_total_days := num_days;
                  END IF;

                   Year_basis := l_total_days / (start_year_basis + (l_total_year -1)
                                 + end_year_basis);
                End if;
	    End if;

            -------------------------------
            -- Interest Override feature --
            -- Adde Day count type logic --
            -------------------------------
            IF day_count_type='B' AND first_trans_flag ='Y' THEN
               num_days := num_days +1;
            END IF;
         ------------------------------
         -- For all other year basis --
         ------------------------------
         else

            /*-------------------------------------------------------------------------------------------*/
            /* AW 2113171       This date is adjusted when called in CALCULATE_ACCRUAL_AMORTISATION.     */
            /* Need to add one day back to it for FORWARD, and then adjust later in num_days
(see below).*/
            /* The 'fwd_adjust' parameter is used 30/360, 30E/360, 30E+/360 calculations.
            */
            /* If it is 1, then it is Forward, if it is 0, then it is Arrear.
            */
            /*-------------------------------------------------------------------------------------------*/
               l_start_date := start_date + nvl(fwd_adjust,0);
            /*-------------------------------------------------------------------------------------------*/

            -- Calculate over a 360 basis based on different calc methods
            year_basis :=360;

            if method = '30/' then
               if to_number(to_char(start_date + nvl(fwd_adjust,0),'DD')) = 31 then
-- AW 2113171
                  -- make start date = 30th ie add 1 day
                  l_start_date := start_date + nvl(fwd_adjust,0) - 1;
-- AW 2113171
               end if;
               if to_number(to_char(end_date,'DD')) = 31 then
                  if to_number(to_char(start_date + nvl(fwd_adjust,0),'DD')) in(30,31) then
-- AW 2113171
                     -- make end date = 30th if end date = 31st
                     -- only if start date is 30th or 31st ie minus 1 day from calc
                     l_end_date := end_date  - 1;
                  end if;
               end if;
            elsif method = '30E/' then
               if to_number(to_char(start_date + nvl(fwd_adjust,0),'DD')) = 31 then
-- AW 2113171
                  -- make start date = 30th ie add 1 day
                  l_start_date := start_date + nvl(fwd_adjust,0)  - 1;
-- AW 2113171
               end if;
               if to_number(to_char(end_date,'DD')) = 31 then
                  -- make end date = 30th ie minus 1 day
                  l_end_date := end_date - 1;
               end if;
            elsif method = '30E+/' then
               if to_number(to_char(start_date + nvl(fwd_adjust,0),'DD')) = 31 then
-- AW 2113171
                  -- make start date = 30th ie add 1 day
                  l_start_date := start_date + nvl(fwd_adjust,0)  - 1;
-- AW 2113171
               end if;
               if to_number(to_char(end_date,'DD')) = 31 then
                  -- make end date = 1st of the next month
                  l_end_date := end_date + 1;
               end if;
            end if;

            -- Calculate based on basic 30/360 method
            --with the above modifications
            num_days := to_number(to_char(l_end_date,'DD')) -
                        to_number(to_char(l_start_date,'DD')) +
                        (30 * (
                        to_number(to_char(l_end_date,'MM')) -
                        to_number(to_char(l_start_date,'MM')))) +
                        (360 * (
                        to_number(to_char(l_end_date,'YYYY')) -
                        to_number(to_char(l_start_date,'YYYY'))));

            /*-----------------------------------------------*/
            /* AW 2113171                                    */
            /*-----------------------------------------------*/
             num_days := num_days + nvl(fwd_adjust,0);
            /*-----------------------------------------------*/

         end if;

      end if;

   end if;
-- Bug 3511403 End
end CALC_DAYS_RUN;
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
PROCEDURE future_value(p_in_rec  IN futureValue_in_rec_type,
		       p_out_rec IN OUT NOCOPY futureValue_out_rec_type) IS

  v_in_rec xtr_rate_conversion.df_in_rec_type;
  v_out_rec xtr_rate_conversion.df_out_rec_type;
  v_rate NUMBER;
  v_cf_necessary BOOLEAN := FALSE;
  v_extensive BOOLEAN := FALSE;
  v_ann_basis NUMBER;
  v_day_count NUMBER;
BEGIN
--  xtr_risk_debug_pkg.dpush('XTR_MM_COVERS.FUTURE_VALUE');

  --Determine whether p_compounding_freq is necessary
  IF p_in_rec.p_rate_type='P' THEN
    v_cf_necessary := TRUE;
  END IF;

  --Determine whether we need to calc using p_RATE_TYPE,
  --p_COMPOUND_FREQ(if p_RATE_TYPE='P'), p_FUTURE_DATE,
  --p_SPOT_DATE, and p_DAY_COUNT_BASIS
  IF p_in_rec.p_fv_date IS NOT NULL AND p_in_rec.p_pv_date IS NOT NULL
  AND p_in_rec.p_day_count_basis IS NOT NULL AND p_in_rec.p_rate_type IS NOT
  NULL AND ((v_cf_necessary AND p_in_rec.p_compound_freq IS NOT NULL)
  OR NOT v_cf_necessary) THEN
    --Calculate the annual basis and day count based on ACT/ACT to get
    --fair comparison
    v_extensive := TRUE;
  END IF;

  IF (p_in_rec.p_indicator = 'Y') THEN
     IF v_extensive THEN
       --use discount factor method
       v_in_rec.p_indicator:='T';
       v_in_rec.p_spot_date:=p_in_rec.p_pv_date;
       v_in_rec.p_future_date:=p_in_rec.p_fv_date;
       v_in_rec.p_rate:=p_in_rec.p_rate;
       v_in_rec.p_rate_type:=p_in_rec.p_rate_type;
       v_in_rec.p_compound_freq:=p_in_rec.p_compound_freq;
       v_in_rec.p_day_count_basis:=p_in_rec.p_day_count_basis;
       xtr_rate_conversion.discount_factor_conv(v_in_rec,v_out_rec);
       v_rate:=v_out_rec.p_result;
       p_out_rec.p_future_val:=p_in_rec.p_present_val/v_rate;
     ELSIF (p_in_rec.p_day_count<=p_in_rec.p_annual_basis) THEN
       xtr_mm_formulas.future_value_yield_rate(p_in_rec.p_present_val,
					      p_in_rec.p_rate,
				 	      p_in_rec.p_day_count,
					      p_in_rec.p_annual_basis,
					      p_out_rec.p_future_val);
     ELSE
       --use discount factor method
       v_in_rec.p_indicator:='T';
       v_in_rec.p_day_count:=p_in_rec.p_day_count;
       v_in_rec.p_annual_basis:=p_in_rec.p_annual_basis;
       v_in_rec.p_rate:=p_in_rec.p_rate;
       xtr_rate_conversion.discount_factor_conv(v_in_rec,v_out_rec);
       v_rate:=v_out_rec.p_result;
       p_out_rec.p_future_val:=p_in_rec.p_present_val/v_rate;
     END IF;
  ELSIF (p_in_rec.p_indicator = 'DR') THEN
     IF v_extensive THEN
       -- use discount factor method, but first find the yield rate to be
       --able to convert to discount factor
       calc_days_run_c(p_in_rec.p_pv_date, p_in_rec.p_fv_date,
	p_in_rec.p_day_count_basis, null, v_day_count, v_ann_basis);

       xtr_rate_conversion.discount_to_yield_rate(p_in_rec.p_rate,
						v_day_count,
						v_ann_basis,
						v_rate);
       --use discount factor method
       v_in_rec.p_indicator:='T';
       v_in_rec.p_spot_date:=p_in_rec.p_pv_date;
       v_in_rec.p_future_date:=p_in_rec.p_fv_date;
       v_in_rec.p_rate:=v_rate;
       v_in_rec.p_rate_type:=p_in_rec.p_rate_type;
       v_in_rec.p_compound_freq:=p_in_rec.p_compound_freq;
       v_in_rec.p_day_count_basis:=p_in_rec.p_day_count_basis;
       xtr_rate_conversion.discount_factor_conv(v_in_rec,v_out_rec);
       v_rate:=v_out_rec.p_result;
       p_out_rec.p_future_val:=p_in_rec.p_present_val/v_rate;
     ELSIF (p_in_rec.p_day_count<=p_in_rec.p_annual_basis) THEN
        xtr_mm_formulas.future_value_discount_rate(p_in_rec.p_present_val,
						 p_in_rec.p_rate,
						 p_in_rec.p_day_count,
						 p_in_rec.p_annual_basis,
						 p_out_rec.p_future_val);
     ELSE
       -- use discount factor method, but first find the yield rate to be
       --able to convert to discount factor
       xtr_rate_conversion.discount_to_yield_rate(p_in_rec.p_rate,
						p_in_rec.p_day_count,
						p_in_rec.p_annual_basis,
						v_rate);
       --convert to disc. factor
       v_in_rec.p_indicator:='T';
       v_in_rec.p_day_count:=p_in_rec.p_day_count;
       v_in_rec.p_annual_basis:=p_in_rec.p_annual_basis;
       v_in_rec.p_rate:=v_rate;
       xtr_rate_conversion.discount_factor_conv(v_in_rec,v_out_rec);
       v_rate:=v_out_rec.p_result;

       --FV with disc. factor
       p_out_rec.p_future_val:=p_in_rec.p_present_val/v_rate;

     END IF;
  ELSE
     --
     -- error message!!!!!!!!!!!!!!!!!!!!!
     --
     RAISE_APPLICATION_ERROR(-20001, 'The indicator should be either ''Y'' '||
				'or ''D'' or ''DR''.');

  END IF;

--  xtr_risk_debug_pkg.dpop('XTR_MM_COVERS.FUTURE_VALUE');

END future_value;



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
PROCEDURE present_value(p_in_rec  IN presentValue_in_rec_type,
		        p_out_rec IN OUT NOCOPY presentValue_out_rec_type) IS
  v_rate NUMBER;
  v_in_rec xtr_rate_conversion.df_in_rec_type;
  v_out_rec xtr_rate_conversion.df_out_rec_type;
  v_cf_necessary BOOLEAN := FALSE;
  v_extensive BOOLEAN := FALSE;
  v_day_count NUMBER;
  v_ann_basis NUMBER;
BEGIN
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('XTR_MM_COVERS.PRESENT_VALUE');
  END IF;

  --Determine whether p_compounding_freq is necessary
  IF p_in_rec.p_rate_type='P' THEN
    v_cf_necessary := TRUE;
  END IF;

  --Determine whether we need to calc using p_RATE_TYPE,
  --p_COMPOUND_FREQ(if p_RATE_TYPE='P'), p_FUTURE_DATE,
  --p_SPOT_DATE, and p_DAY_COUNT_BASIS
  IF p_in_rec.p_fv_date IS NOT NULL AND p_in_rec.p_pv_date IS NOT NULL
  AND p_in_rec.p_day_count_basis IS NOT NULL AND p_in_rec.p_rate_type IS NOT
  NULL  AND ((v_cf_necessary AND p_in_rec.p_compound_freq IS NOT NULL)
  OR NOT v_cf_necessary) THEN
    --Calculate the annual basis and day count based on ACT/ACT to get
    --fair comparison
    v_extensive := TRUE;
  END IF;

  IF (p_in_rec.p_indicator = 'Y') THEN
     IF v_extensive THEN
       --use discount factor method
       v_in_rec.p_indicator:='T';
       v_in_rec.p_spot_date:=p_in_rec.p_pv_date;
       v_in_rec.p_future_date:=p_in_rec.p_fv_date;
       v_in_rec.p_rate:=p_in_rec.p_rate;
       v_in_rec.p_rate_type:=p_in_rec.p_rate_type;
       v_in_rec.p_compound_freq:=p_in_rec.p_compound_freq;
       v_in_rec.p_day_count_basis:=p_in_rec.p_day_count_basis;
       xtr_rate_conversion.discount_factor_conv(v_in_rec,v_out_rec);
       v_rate:=v_out_rec.p_result;
       xtr_mm_formulas.present_value_discount_factor(v_rate,
						   p_in_rec.p_future_val,
						   p_out_rec.p_present_val);
     ELSIF (p_in_rec.p_day_count<=p_in_rec.p_annual_basis) THEN
       xtr_mm_formulas.present_value_yield_rate(p_in_rec.p_future_val,
				 	      p_in_rec.p_rate,
				 	      p_in_rec.p_day_count,
				 	      p_in_rec.p_annual_basis,
				 	      p_out_rec.p_present_val);
     ELSE
       --use discount factor method
       v_in_rec.p_indicator:='T';
       v_in_rec.p_day_count:=p_in_rec.p_day_count;
       v_in_rec.p_annual_basis:=p_in_rec.p_annual_basis;
       v_in_rec.p_rate:=p_in_rec.p_rate;
       xtr_rate_conversion.discount_factor_conv(v_in_rec,v_out_rec);
       v_rate:=v_out_rec.p_result;

       xtr_mm_formulas.present_value_discount_factor(v_rate,
						   p_in_rec.p_future_val,
						   p_out_rec.p_present_val);
     END IF;
  ELSIF (p_in_rec.p_indicator = 'DR') THEN
     IF v_extensive THEN
       -- use discount factor method, but first find the yield rate to be
       --able to convert to discount factor
       calc_days_run_c(p_in_rec.p_pv_date, p_in_rec.p_fv_date,
	p_in_rec.p_day_count_basis, null, v_day_count, v_ann_basis);

       xtr_rate_conversion.discount_to_yield_rate(p_in_rec.p_rate,
						v_day_count,
						v_ann_basis,
						v_rate);
       --use discount factor method
       v_in_rec.p_indicator:='T';
       v_in_rec.p_spot_date:=p_in_rec.p_pv_date;
       v_in_rec.p_future_date:=p_in_rec.p_fv_date;
       v_in_rec.p_rate:=v_rate;
       v_in_rec.p_rate_type:=p_in_rec.p_rate_type;
       v_in_rec.p_compound_freq:=p_in_rec.p_compound_freq;
       v_in_rec.p_day_count_basis:=p_in_rec.p_day_count_basis;
       xtr_rate_conversion.discount_factor_conv(v_in_rec,v_out_rec);
       v_rate:=v_out_rec.p_result;
       xtr_mm_formulas.present_value_discount_factor(v_rate,
						   p_in_rec.p_future_val,
						   p_out_rec.p_present_val);
     ELSIF (p_in_rec.p_day_count<=p_in_rec.p_annual_basis) THEN
       xtr_mm_formulas.present_value_discount_rate(p_in_rec.p_future_val,
				    		 p_in_rec.p_rate,
						 p_in_rec.p_day_count,
				    		 p_in_rec.p_annual_basis,
				    		 p_out_rec.p_present_val);
     ELSE
       -- use discount factor method, but first find the yield rate to be
       --able to convert to discount factor
       xtr_rate_conversion.discount_to_yield_rate(p_in_rec.p_rate,
						p_in_rec.p_day_count,
						p_in_rec.p_annual_basis,
						v_rate);

       --convert to disc. factor
       v_in_rec.p_indicator:='T';
       v_in_rec.p_day_count:=p_in_rec.p_day_count;
       v_in_rec.p_annual_basis:=p_in_rec.p_annual_basis;
       v_in_rec.p_rate:=v_rate;
       xtr_rate_conversion.discount_factor_conv(v_in_rec,v_out_rec);
       v_rate:=v_out_rec.p_result;

       --PV with disc. factor
       xtr_mm_formulas.present_value_discount_factor(v_rate,
						   p_in_rec.p_future_val,
						   p_out_rec.p_present_val);

     END IF;

  ELSIF (p_in_rec.p_indicator = 'D') THEN
       xtr_mm_formulas.present_value_discount_factor(p_in_rec.p_rate,
						   p_in_rec.p_future_val,
						   p_out_rec.p_present_val);
  ELSE
     --
     -- error message!!!!!!!!!!!!!!!!!!!!
     --
     RAISE_APPLICATION_ERROR(-20001, 'The indicator should be either ''Y'' '||
				'or ''D'' or ''DR''.');
  END IF;

  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpop('XTR_MM_COVERS.PRESENT_VALUE');
  END IF;

END present_value;



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
PROCEDURE fra_settlement_amount(p_in_rec  IN fra_settlement_in_rec_type,
			       p_out_rec IN OUT NOCOPY fra_settlement_out_rec_type) IS

BEGIN

  IF (p_in_rec.p_indicator = 'Y') THEN
    xtr_mm_formulas.fra_settlement_amount_yield(p_in_rec.p_fra_price,
					   p_in_rec.p_settlement_rate,
					   p_in_rec.p_face_value,
					   p_in_rec.p_day_count,
					   p_in_rec.p_annual_basis,
					   p_out_rec.p_settlement_amount);

  ELSIF (p_in_rec.p_indicator = 'DR') THEN
    xtr_mm_formulas.fra_settlement_amount_discount(p_in_rec.p_fra_price,
				   	   p_in_rec.p_settlement_rate,
				   	   p_in_rec.p_face_value,
				   	   p_in_rec.p_day_count,
				   	   p_in_rec.p_annual_basis,
				   	   p_out_rec.p_settlement_amount);
  ELSE

     --
     -- error !!!!!!!!!!!!!!!!!!!!!!
     --
     RAISE_APPLICATION_ERROR(-20001, 'The indicator should be either ''Y'' '||
				'or ''D''.');
  END IF;

  --determine the sign of the settlement amount base on the deal subtype
  IF (p_in_rec.p_deal_subtype IS NOT NULL) THEN
    IF (UPPER(p_in_rec.p_deal_subtype) = 'FUND') THEN
      IF (p_in_rec.p_fra_price > p_in_rec.p_settlement_rate) THEN
        p_out_rec.p_settlement_amount := -p_out_rec.p_settlement_amount;
      END IF;
    ELSIF (UPPER(p_in_rec.p_deal_subtype) = 'INVEST') THEN
      IF (p_in_rec.p_fra_price < p_in_rec.p_settlement_rate) THEN
        p_out_rec.p_settlement_amount := -p_out_rec.p_settlement_amount;
      END IF;
    ELSE
      RAISE_APPLICATION_ERROR(-20001, 'The indicator should be either ''FUND'' '||
				'or ''INVEST''.');
    END IF;
  END IF;

END fra_settlement_amount;


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
PROCEDURE interest_forward_rate (p_in_rec IN int_forw_rate_in_rec_type,
				p_out_rec OUT NOCOPY int_forw_rate_out_rec_type) AS

  v_rate_short NUMBER;
  v_rate_long NUMBER;
  v_rc_in xtr_rate_conversion.rate_conv_in_rec_type;
  v_rc_out xtr_rate_conversion.rate_conv_out_rec_type;
  v_df_in xtr_rate_conversion.df_in_rec_type;
  v_df_out xtr_rate_conversion.df_out_rec_type;

BEGIN
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('XTR_MM_COVERS.INTEREST_FORWARD_RATE');
  END IF;

  IF (p_in_rec.p_indicator IN ('D','d')) THEN
    xtr_mm_formulas.fra_price_df(p_in_rec.p_t, p_in_rec.p_T1,
				p_in_rec.p_Rt, p_in_rec.p_Rt1,
				p_in_rec.p_year_basis, p_out_rec.p_fra_rate);
  ELSIF (p_in_rec.p_indicator IN ('Y','y')) THEN
  --also use FRA Price from DF formula
    v_df_in.p_indicator := 'T';
    --convert the first rate: spot to start date rate
    v_df_in.p_rate := p_in_rec.p_Rt;
    v_df_in.p_day_count := p_in_rec.p_t;
    v_df_in.p_annual_basis := p_in_rec.p_year_basis;
    xtr_rate_conversion.discount_factor_conv(v_df_in, v_df_out);
    v_rate_short := v_df_out.p_result;
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('interest_forward_rate: ' || 'v_rate_short',v_rate_short);
END IF;
    --convert the second rate: spot to maturity date rate
    v_df_in.p_rate := p_in_rec.p_RT1;
    v_df_in.p_day_count := p_in_rec.p_T1;
    v_df_in.p_annual_basis := p_in_rec.p_year_basis;
    xtr_rate_conversion.discount_factor_conv(v_df_in, v_df_out);
    v_rate_long := v_df_out.p_result;
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('interest_forward_rate: ' || 'v_rate_long',v_rate_long);
END IF;
    xtr_mm_formulas.fra_price_df(p_in_rec.p_t, p_in_rec.p_T1,
				v_rate_short, v_rate_long,
				p_in_rec.p_year_basis, p_out_rec.p_fra_rate);

  ELSE
    RAISE_APPLICATION_ERROR(-20001, 'The indicator should be either ''Y'' '||
				'or ''D''.');
  END IF;

  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpop('XTR_MM_COVERS.INTEREST_FORWARD_RATE');
  END IF;
END interest_forward_rate;


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
PROCEDURE black_option_price_cv (p_in_rec IN black_opt_cv_in_rec_type,
				p_out_rec OUT NOCOPY black_opt_cv_out_rec_type) IS

  v_rc_in xtr_rate_conversion.rate_conv_in_rec_type;
  v_rc_out xtr_rate_conversion.rate_conv_out_rec_type;
  v_fr_in int_forw_rate_in_rec_type;
  v_fr_out int_forw_rate_out_rec_type;
  v_bo_in xtr_mm_formulas.black_opt_in_rec_type;
  v_bo_out xtr_mm_formulas.black_opt_out_rec_type;
  v_temp NUMBER;
  v_dummy NUMBER;
  v_strike NUMBER;

BEGIN
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('XTR_MM_COVERS.BLACK_OPTION_PRICE_CV');
  END IF;

  --we want all rates to be Actual/365 output to find the forward rate
  v_rc_in.p_day_count_basis_out := 'ACTUAL365';  -- bug 3509267

  --first, convert short rate to Actual/365
  v_rc_in.p_rate_type_in := p_in_rec.p_rate_type_short;
  v_rc_in.p_day_count_basis_in := p_in_rec.p_day_count_basis_short;
  v_rc_in.p_rate_in := p_in_rec.p_ir_short;
  v_rc_in.p_start_date := p_in_rec.p_spot_date;
  v_rc_in.p_end_date := p_in_rec.p_start_date;
  v_rc_in.p_compound_freq_in := p_in_rec.p_compound_freq_short;

IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Short Start Date',v_rc_in.p_start_date);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Short End Date',v_rc_in.p_end_date);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Short DCB IN',v_rc_in.p_day_count_basis_in);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Short DCB OUT',v_rc_in.p_day_count_basis_out);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Short Rate Type IN',v_rc_in.p_rate_type_in);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Short Rate Type OUT',v_rc_in.p_rate_type_out);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Short Compound Freq IN',v_rc_in.p_compound_freq_in);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Short Compound Freq OUT',v_rc_in.p_compound_freq_out);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Short Rate IN',v_rc_in.p_rate_in);
END IF;

  xtr_rate_conversion.rate_conv_simple_annualized(v_rc_in, v_rc_out);
  v_fr_in.p_Rt := v_rc_out.p_rate_out;

  --second, convert long rate to Actual/365
  v_rc_in.p_rate_type_in := p_in_rec.p_rate_type_long;
  v_rc_in.p_day_count_basis_in := p_in_rec.p_day_count_basis_long;
  v_rc_in.p_rate_in := p_in_rec.p_ir_long;
  v_rc_in.p_start_date := p_in_rec.p_spot_date;
  v_rc_in.p_end_date := p_in_rec.p_maturity_date;
  v_rc_in.p_compound_freq_in := p_in_rec.p_compound_freq_long;

IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Long Start Date',v_rc_in.p_start_date);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Long End Date',v_rc_in.p_end_date);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Long DCB IN',v_rc_in.p_day_count_basis_in);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Long DCB OUT',v_rc_in.p_day_count_basis_out);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Long Rate Type IN',v_rc_in.p_rate_type_in);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Long Rate Type OUT',v_rc_in.p_rate_type_out);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Long Compound Freq IN',v_rc_in.p_compound_freq_in);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Long Compound Freq OUT',v_rc_in.p_compound_freq_out);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Long Rate IN',v_rc_in.p_rate_in);
END IF;

  xtr_rate_conversion.rate_conv_simple_annualized(v_rc_in, v_rc_out);
  v_fr_in.p_RT1 := v_rc_out.p_rate_out;

  --third, convert strike rate to Actual/365 (has to be the same basis as
  --the forward rate
  v_rc_in.p_day_count_basis_out := 'ACTUAL365';
  v_rc_in.p_rate_type_in := p_in_rec.p_rate_type_strike;
  v_rc_in.p_day_count_basis_in := p_in_rec.p_day_count_basis_strike;
  v_rc_in.p_rate_in := p_in_rec.p_strike_rate;
  v_rc_in.p_start_date := p_in_rec.p_start_date;
  v_rc_in.p_end_date := p_in_rec.p_maturity_date;
  v_rc_in.p_compound_freq_in := p_in_rec.p_compound_freq_strike;

IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Strike Start Date',v_rc_in.p_start_date);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Strike End Date',v_rc_in.p_end_date);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Strike DCB IN',v_rc_in.p_day_count_basis_in);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Strike DCB OUT',v_rc_in.p_day_count_basis_out);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Strike Rate Type IN',v_rc_in.p_rate_type_in);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Strike Rate Type OUT',v_rc_in.p_rate_type_out);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Strike Compound Freq IN',v_rc_in.p_compound_freq_in);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Strike Compound Freq OUT',v_rc_in.p_compound_freq_out);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Strike Rate IN',v_rc_in.p_rate_in);
END IF;

  xtr_rate_conversion.rate_conv_simple_annualized(v_rc_in, v_rc_out);
  v_strike := v_rc_out.p_rate_out;

  --get t
  calc_days_run_c(p_in_rec.p_spot_date, p_in_rec.p_start_date,
			'ACTUAL365', null, v_fr_in.p_t, v_dummy); -- bug 3509267
  --get T1
  calc_days_run_c(p_in_rec.p_spot_date, p_in_rec.p_maturity_date,
			'ACTUAL365', null, v_fr_in.p_T1, v_dummy); -- bug 3509267
  --get forward rate
  v_fr_in.p_indicator := 'Y'; --we're supplying yield rate
  v_fr_in.p_year_basis := 365;  -- bug 3509267

IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Forw Conv Short Rate',v_fr_in.p_Rt);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Forw Conv Long Rate',v_fr_in.p_RT1);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Forw Conv Time Short',v_fr_in.p_t);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'Forw Conv Time Long',v_fr_in.p_T1);
END IF;

  interest_forward_rate(v_fr_in,v_fr_out);
  v_bo_in.p_forward_rate := v_fr_out.p_fra_rate;

  --convert long rate to continuous Actual/365
  IF NOT (p_in_rec.p_rate_type_long IN ('C','c') AND
	p_in_rec.p_day_count_basis_long = 'ACTUAL365') THEN
    v_rc_in.p_rate_type_out := 'C';
    v_rc_in.p_day_count_basis_out := 'ACTUAL365';
    v_rc_in.p_rate_type_in := p_in_rec.p_rate_type_long;
    v_rc_in.p_day_count_basis_in := p_in_rec.p_day_count_basis_long;
    v_rc_in.p_rate_in := p_in_rec.p_ir_long;
    v_rc_in.p_start_date := p_in_rec.p_spot_date;
    v_rc_in.p_end_date := p_in_rec.p_maturity_date;
    v_rc_in.p_compound_freq_in := p_in_rec.p_compound_freq_long;
    xtr_rate_conversion.rate_conversion(v_rc_in, v_rc_out);
    v_bo_in.p_T2_INT_RATE := v_rc_out.p_rate_out;
  ELSE
    v_bo_in.p_T2_INT_RATE := p_in_rec.p_ir_long;
  END IF;

IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'BO v_strike',v_strike);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'BO p_forward_rate',v_fr_out.p_fra_rate);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'BO Conv. forward_rate',v_bo_in.p_forward_rate);
   xtr_risk_debug_pkg.dlog('black_option_price_cv: ' || 'BO Conv. Long Rate ',v_bo_in.p_t2_int_rate);
END IF;

  --call black option pricing engine
  v_bo_in.p_principal := p_in_rec.p_principal;
  v_bo_in.p_int_rate := v_strike;
  v_bo_in.p_T1 := v_fr_in.p_t;
  v_bo_in.p_T2 := v_fr_in.p_T1;
  v_bo_in.p_VOLATILITY := p_in_rec.p_VOLATILITY;
  xtr_mm_formulas.black_option_price(v_bo_in, v_bo_out);
  p_out_rec.p_CAPLET_PRICE := v_bo_out.p_CAPLET_PRICE;
  p_out_rec.p_FLOORLET_PRICE := v_bo_out.p_FLOORLET_PRICE;
  p_out_rec.p_FORWARD_FORWARD_RATE := v_bo_in.p_forward_rate;
  p_out_rec.p_Nd1 := v_bo_out.p_Nd1;
  p_out_rec.p_Nd2 := v_bo_out.p_Nd2;
  p_out_rec.p_Nd1_a := v_bo_out.p_Nd1_a;
  p_out_rec.p_Nd2_a := v_bo_out.p_Nd2_a;

  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpop('XTR_MM_COVERS.BLACK_OPTION_PRICE_CV');
  END IF;
END black_option_price_cv;


-------------------------------------------------------------------
-- COMPOUND COUPON
-- To find the first coupon's Start Date or Maturity Date based on
-- the bond's Frequency, Commence Date and Maturity Date, so that
-- Start Date and Maturity Date gives a full coupon.
--
-- If p_odd_date_ind = 'S', then return Start Date.
-- If p_odd_date_ind = 'M', then return Maturity Date.
-------------------------------------------------------------------
FUNCTION  ODD_COUPON_DATE  (p_commence_date IN  DATE,
                            p_maturity_date IN  DATE,
                            p_frequency     IN  NUMBER,
                            p_odd_date_ind  IN  VARCHAR2) return DATE is
   l_coupon_date      DATE;
   l_prev_coupon_date DATE;
   l_counter          NUMBER := 0;
--
BEGIN

   l_prev_coupon_date := p_maturity_date;

   if nvl(p_frequency,0) <> 0 then

      l_coupon_date := add_months(p_maturity_date,(-12 / p_frequency)-l_counter);
      l_counter     := l_counter + (12 / p_frequency);

      LOOP
         EXIT WHEN l_coupon_date <= p_commence_date;

         l_prev_coupon_date := l_coupon_date;
         l_coupon_date      := add_months(p_maturity_date,(-12 / p_frequency)-l_counter);
         l_counter          := l_counter + (12 / p_frequency);

      END LOOP;

      if p_odd_date_ind = 'S' then
         return(l_coupon_date);         -- Start Date
      else
         return(l_prev_coupon_date);    -- Maturity Date
      end if;

   else
      return(p_maturity_date);
   end if;

END;

-------------------------------------------------------------------
-- COMPOUND COUPON
-- To find the number of Full coupons
-------------------------------------------------------------------
FUNCTION  FULL_COUPONS(p_commence_date IN  DATE,
                       p_maturity_date IN  DATE,
                       p_frequency     IN  NUMBER) return NUMBER is

 l_coupon_date      DATE;
 l_counter          NUMBER := 0;
 l_num_full         NUMBER := 0;

--
begin

   if nvl(p_frequency,0) <> 0 then

      l_coupon_date := add_months(p_maturity_date,(-12 / p_frequency)-l_counter);
      l_counter     := l_counter + (12 / p_frequency);

      LOOP
         EXIT WHEN l_coupon_date <= p_commence_date;

         l_coupon_date := add_months(p_maturity_date,(-12 / p_frequency)-l_counter);
         l_counter     := l_counter + (12 / p_frequency);
         l_num_full    := l_num_full + 1;

      END LOOP;

   end if;

   return(l_num_full);

END;

-------------------------------------------------------------------
-- COMPOUND COUPON
-- To find the number of Previous Full coupons
-------------------------------------------------------------------
FUNCTION  PREVIOUS_FULL_COUPONS(p_commence_date   IN  DATE,
                                p_maturity_date   IN  DATE,
                                p_settlement_date IN  DATE,
                                p_frequency       IN  NUMBER) return NUMBER is

 l_coupon_date      DATE;
 l_prev_coupon_date DATE;
 l_counter          NUMBER := 0;
 l_num_full         NUMBER := 0;

--
begin

   l_prev_coupon_date := p_maturity_date;

   if nvl(p_frequency,0) <> 0 then

      l_coupon_date := add_months(p_maturity_date,(-12 / p_frequency)-l_counter);
      l_counter     := l_counter + (12 / p_frequency);

      LOOP
         EXIT WHEN l_coupon_date <= p_commence_date;

         l_prev_coupon_date := l_coupon_date;
         l_coupon_date      := add_months(p_maturity_date,(-12 / p_frequency)-l_counter);
         l_counter          := l_counter + (12 / p_frequency);

         if l_prev_coupon_date <= p_settlement_date and l_coupon_date > p_commence_date then
            l_num_full := l_num_full + 1;
         end if;

      END LOOP;

   end if;

   return(l_num_full);

END;

-------------------------------------------------------------------
-- COMPOUND COUPON
-- To calculate the coupon amount
-------------------------------------------------------------------
FUNCTION  CALC_COMPOUND_COUPON_AMT(p_compound_rec   IN  COMPOUND_CPN_REC_TYPE) return NUMBER is

   l_year_basis           NUMBER;
   l_nbr_days_in_period   NUMBER;
   l_total_coupon_days    NUMBER;
   l_full_quasi_coupon    NUMBER;
   l_amount               NUMBER;

BEGIN

   ----------------------------------------------
   -- To return the total coupon amount
   ----------------------------------------------

   l_full_quasi_coupon := p_compound_rec.p_full_coupon;

   if p_compound_rec.p_odd_coupon_start = p_compound_rec.p_bond_start_date then
      l_full_quasi_coupon := l_full_quasi_coupon + 1;
   else
      XTR_CALC_P.Calc_Days_Run_C (p_compound_rec.p_bond_start_date,
                                  p_compound_rec.p_odd_coupon_maturity,
                                  p_compound_rec.p_year_calc_type,
                                  p_compound_rec.p_frequency,
                                  l_nbr_days_in_period,
                                  l_year_basis,
                                  NULL,
                                  p_compound_rec.p_day_count_type,
                                  'N');
      XTR_CALC_P.Calc_Days_Run_C (p_compound_rec.p_odd_coupon_start,
                                  p_compound_rec.p_odd_coupon_maturity,
                                  p_compound_rec.p_year_calc_type,
                                  p_compound_rec.p_frequency,
                                  l_total_coupon_days,
                                  l_year_basis,
                                  NULL,
                                  p_compound_rec.p_day_count_type,
                                  'N');
      if nvl(l_nbr_days_in_period,0) <> 0 and nvl(l_total_coupon_days,0) <> 0 then
         l_full_quasi_coupon := l_full_quasi_coupon + nvl(l_nbr_days_in_period,0)/nvl(l_total_coupon_days,1);
      end if;
   end if;

   l_amount := (power(1+(p_compound_rec.p_coupon_rate/100)/
                      nvl(p_compound_rec.p_frequency,2),l_full_quasi_coupon))*
                      p_compound_rec.p_maturity_amount - p_compound_rec.p_maturity_amount;

   ----------------------------------------------------------------------------
   -- Currency rounding needed for Coupon Amount, but not for Redemption Value.
   ----------------------------------------------------------------------------
   if nvl(p_compound_rec.p_amount_redemption_ind,'R') = 'A' then
      return( xtr_fps2_p.interest_round(l_amount,
                                        p_compound_rec.p_precision,p_compound_rec.p_rounding_type));
   else
      return( l_amount );
   end if;

END;


---------------------------------------------------------------------------
-- COMPOUND COUPON
-- To calculate the total number of previous quasi coupon
---------------------------------------------------------------------------
FUNCTION  CALC_TOTAL_PREVIOUS_COUPON(p_bond_rec     IN   BOND_INFO_REC_TYPE) return NUMBER is

   l_odd_coupon_days        NUMBER;
   l_odd_coupon_length      NUMBER;
   l_yr_basis               NUMBER;
   l_no_previous_coupon     NUMBER;
   l_no_current_coupon      NUMBER;

BEGIN

   l_no_current_coupon := p_bond_rec.p_curr_coupon;

   CALC_DAYS_RUN_C(p_bond_rec.p_odd_coupon_start,
                   p_bond_rec.p_odd_coupon_maturity,
                   p_bond_rec.p_yr_calc_type,
                   p_bond_rec.p_frequency,
                   l_odd_coupon_length,
                   l_yr_basis,
                   NULL,
                   p_bond_rec.p_day_count_type,     -- Added for Interest Override
                   'N');                            -- Added for Interest Override

   if p_bond_rec.p_calc_date < p_bond_rec.p_odd_coupon_maturity then
      ------------------------ Determine the number of previous coupon ----------------------------
      -------------( Settlement date is within first coupon, previous coupon is zero )-------------
      ---------------------------------------------------------------------------------------------
      l_no_previous_coupon := 0;

   else
      ------------------------ Determine the number of previous coupon ----------------------------
      CALC_DAYS_RUN_C(p_bond_rec.p_bond_commence,
                      p_bond_rec.p_odd_coupon_maturity,
                      p_bond_rec.p_yr_calc_type,
                      p_bond_rec.p_frequency,
                      l_odd_coupon_days,
                      l_yr_basis,
                      NULL,
                      p_bond_rec.p_day_count_type,     -- Added for Interest Override
                      'N');                            -- Added for Interest Override
      if nvl(l_odd_coupon_days,0) <> 0 and nvl(l_odd_coupon_length,0) <> 0 then
         l_no_previous_coupon := l_odd_coupon_days/l_odd_coupon_length + p_bond_rec.p_prv_full_coupon;
      else
         l_no_previous_coupon := p_bond_rec.p_prv_full_coupon;           -- AW: or zero
      end if;


      if p_bond_rec.p_calc_date = p_bond_rec.p_odd_coupon_maturity then
         l_no_current_coupon := 0;
      end if;

   end if;

   return( l_no_previous_coupon + l_no_current_coupon);

END;


-- added fhu 5/3/02
/* bug 2358592 merged various changes from xtr_calc_package
For Floating Rate Bond: p_yield becomes the Discount Margin.
	When it's passed in its unit is assumed to be in Percent, hence the
	caller need to make sure about the unit.
	When it's passed out its unit will be in Percent, hence the caller need to
	adjust the unit for display purposes. This is to avoid bug 31315424.
*/

PROCEDURE CALCULATE_BOND_PRICE_YIELD(
	p_py_in		IN		BOND_PRICE_YIELD_IN_REC_TYPE,
	p_py_out	IN OUT NOCOPY		BOND_PRICE_YIELD_OUT_REC_TYPE) IS

p_bond_issue_code    		VARCHAR2(7) := p_py_in.p_bond_issue_code;
p_settlement_date		DATE := p_py_in.p_settlement_date;
p_ex_cum_next_coupon		VARCHAR2(3) := p_py_in.p_ex_cum_next_coupon;
p_calculate_yield_or_price	VARCHAR2(1) := p_py_in.p_calculate_yield_or_price;
p_yield				NUMBER := p_py_in.p_yield;
p_yield_temp			NUMBER;--bug 3135424
p_accrued_interest		NUMBER := p_py_in.p_accrued_interest;
p_clean_price			NUMBER := p_py_in.p_clean_price;
p_dirty_price			NUMBER := p_py_in.p_dirty_price;
p_input_or_calculator		VARCHAR2(1) := p_py_in.p_input_or_calculator;
p_commence_date			DATE := p_py_in.p_commence_date;
p_maturity_date			DATE := p_py_in.p_maturity_date;
p_prev_coupon_date		DATE := p_py_in.p_prev_coupon_date;
p_next_coupon_date		DATE := p_py_in.p_next_coupon_date;
p_calc_type			VARCHAR2(15) := p_py_in.p_calc_type;
p_year_calc_type		VARCHAR2(15) := p_py_in.p_year_calc_type;
p_accrued_int_calc_basis	VARCHAR2(15) := p_py_in.p_accrued_int_calc_basis;
p_coupon_freq			NUMBER := p_py_in.p_coupon_freq;
p_calc_rounding			NUMBER := p_py_in.p_calc_rounding;
p_price_rounding		NUMBER := p_py_in.p_price_rounding;
p_price_round_type		VARCHAR2(2) := p_py_in.p_price_round_type;
p_yield_rounding		NUMBER := p_py_in.p_yield_rounding;
p_yield_round_type		VARCHAR2(2) := p_py_in.p_yield_round_type;
p_coupon_rate			NUMBER := p_py_in.p_coupon_rate;
p_num_coupons_remain		NUMBER := p_py_in.p_num_coupons_remain;
p_day_count_type                VARCHAR2(1) := p_py_in.p_day_count_type;
p_first_trans_flag              VARCHAR2(1) := p_py_in.p_first_trans_flag;
p_deal_subtype                  VARCHAR2(7) := p_py_in.p_deal_subtype;

-------------------------------------------------------------------------
-- Variables added for COMPOUND COUPON
-------------------------------------------------------------------------
-- need this from calculator
l_currency                      VARCHAR2(15):= p_py_in.p_currency;
l_face_value                    NUMBER      := p_py_in.p_face_value;
l_consideration                 NUMBER      := p_py_in.p_consideration;
l_full_quasi_coupon             NUMBER;

l_num_current_coupon      	NUMBER;
l_num_full_cpn_previous   	NUMBER;
l_prv_quasi_coupon        	NUMBER;
l_odd_coupon_start      	DATE;
l_odd_coupon_maturity   	DATE;
l_days_settle_to_next_cpn 	NUMBER;
l_days_in_current_cpn           NUMBER;
l_coupon_amount                 NUMBER;
l_redemption_value              NUMBER;
l_precision                     NUMBER;
l_ext_precision                 NUMBER;
l_min_acct_unit                 NUMBER;
l_rounding_type                 VARCHAR2(1) := 'R';
l_comp_coupon                   XTR_MM_COVERS.COMPOUND_CPN_REC_TYPE;
l_bond_rec                      XTR_MM_COVERS.BOND_INFO_REC_TYPE;
l_amt1                          number;
l_amt2                          number;
l_amt3                          number;
-------------------------------------------------------------------------


l_count				NUMBER;
l_num_full_cpn_remain   	NUMBER;
l_prev_coupon_date       	DATE;
l_next_coupon_date    		DATE;
l_days_settle_to_nxt_cpn	NUMBER;
l_days_last_cpn_to_nxt_cpn 	NUMBER;
l_days_last_cpn_to_settle 	NUMBER;
l_yr_calc_type   		VARCHAR2(15);
l_coupon_rate            	NUMBER;
l_calc_type			VARCHAR2(15);
l_bond_commence        		DATE;
l_accrued_int_calc_basis        VARCHAR2(15);
l_coupon_freq   		NUMBER;
l_calc_dirty_price    		NUMBER;
yr_basis			NUMBER;
l_dummy_num			NUMBER;
l_yield_inc			NUMBER :=0.5;
l_inc_flag			VARCHAR2(1) :='+';
l_maturity_date			DATE;
l_nbr_full_months_to_maturity	NUMBER;
l_nbr_months_bwt_cpn		NUMBER;
l_settle_to_nxt_cpn_ratio	NUMBER;
l_calc_precision                NUMBER;
l_price_precision		NUMBER;
l_price_round_type              VARCHAR2(1);
l_yield_precision		NUMBER;
l_yield_round_type              VARCHAR2(1);
-- bug2536590
l_days_settle_to_maturity       NUMBER;
l_settle_to_maturity_years      NUMBER;
l_fast_yield                    NUMBER;

l_dirty_px_1			number;
l_dirty_px_2			number;
l_dirty_px_3			number;
l_dirty_px_4			number;
l_dirty_px_5			number;
l_temp                          number;
l_temp2                         number;
l_temp3                         number;
l_acc_cum                       number;
l_dirty_price_cum		NUMBER;
-- Added for Interest Override feature
l_first_trans_flag              VARCHAR2(1);
--
v_benchmark_rate		NUMBER; --bug 2804548
v_float_margin			NUMBER; --bug 2804548
l_coupon_rate_fl		NUMBER; --bug 2804548
v_actual_ytm                    NUMBER; --bug 2804548 needed for QRM BPV

cursor ISSUE_DETAILS is
 select YEAR_CALC_TYPE,COUPON_RATE,CURRENCY,CALC_TYPE,
        COMMENCE_DATE,nvl(NO_OF_COUPONS_PER_YEAR,0),
        nvl(ACCRUED_INT_YEAR_CALC_BASIS,YEAR_CALC_TYPE),MATURITY_DATE,
        price_rounding,price_round_type,yield_rounding,yield_round_type,
        calc_rounding, rounding_type
  from XTR_BOND_ISSUES_V
  where BOND_ISSUE_CODE = p_bond_issue_code;
--
cursor PRV_COUPON_DATES is
 select max(COUPON_DATE),                        --------------------------------------------------------
        min(COUPON_DATE), greatest(count(*)-1,0) -- COMPOUND COUPON: first coupon date, prev full coupon
  from  XTR_BOND_COUPON_DATES                    --------------------------------------------------------
  where BOND_ISSUE_CODE = p_bond_issue_code
  and   COUPON_DATE    <= p_settlement_date;

cursor NXT_COUPON_DATES is
 select min(COUPON_DATE),nvl(count(COUPON_DATE),0)
  from XTR_BOND_COUPON_DATES
  where BOND_ISSUE_CODE = p_bond_issue_code
  and COUPON_DATE > p_settlement_date;

-----------------------------------------------------------------------------------------------------
cursor TOTAL_FULL_COUPONS (p_issue_code VARCHAR2) is -- COMPOUND COUPON: Count number of full coupons
select count(*)-1
from   xtr_bond_coupon_dates
where  bond_issue_code = p_issue_code;
-----------------------------------------------------------------------------------------------------
--bug 2804548
cursor get_benchmark_rate(p_settlement_date DATE,p_bond_issue_code VARCHAR2) is
select c.rate, i.float_margin
  from xtr_bond_coupon_dates c, xtr_bond_issues i
  where c.bond_issue_code=p_bond_issue_code
  and c.bond_issue_code=i.bond_issue_code
  and c.coupon_date=(select min(COUPON_DATE)
  	from XTR_BOND_COUPON_DATES
  	where BOND_ISSUE_CODE = p_bond_issue_code
  	and COUPON_DATE > p_settlement_date);

FUNCTION ROUND_P(p_num IN NUMBER) RETURN NUMBER IS
BEGIN
   IF CALCULATE_BOND_PRICE_YIELD.l_yield_round_type = 'T' then
     RETURN trunc(p_num,CALCULATE_BOND_PRICE_YIELD.l_calc_precision);
   ELSE
     RETURN round(p_num,CALCULATE_BOND_PRICE_YIELD.l_calc_precision);
   END IF;
END ROUND_P;

FUNCTION ROUND_Y(p_num IN NUMBER) RETURN NUMBER IS
BEGIN
  IF CALCULATE_BOND_PRICE_YIELD.l_price_round_type = 'T' then
    RETURN trunc(p_num,CALCULATE_BOND_PRICE_YIELD.l_calc_precision);
  ELSE
    RETURN round(p_num,CALCULATE_BOND_PRICE_YIELD.l_calc_precision);
  END IF;
END ROUND_Y;
--
begin
/*
XTR_RISK_DEBUG_PKG.start_debug('/sqlcom/out/findv115', 'fhpatest.dbg');
IF xtr_risk_debug_pkg.g_Debug THEN
   XTR_RISK_DEBUG_PKG.dpush('calculate_bond_price_yield');
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_bond_issue_code',p_bond_issue_code);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_settlement_date',p_settlement_date);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_ex_cum_next_coupon',p_ex_cum_next_coupon);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_calculate_yield_or_price',p_calculate_yield_or_price);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_yield',p_yield);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_accrued_interest',p_accrued_interest);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_clean_price',p_clean_price);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_dirty_price',p_dirty_price);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_input_or_calculator',p_input_or_calculator);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_commence_date',p_commence_date);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_maturity_date',p_maturity_date);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_prev_coupon_date',p_prev_coupon_date);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_next_coupon_date',p_next_coupon_date);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_calc_type',p_calc_type);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_year_calc_type',p_year_calc_type);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_accrued_int_calc_basis',p_accrued_int_calc_basis);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_coupon_freq',p_coupon_freq);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_calc_rounding',p_calc_rounding);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_price_rounding',p_price_rounding);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_price_round_type',p_price_round_type);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_yield_rounding',p_yield_rounding);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_yield_round_type',p_yield_round_type);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_coupon_rate',p_coupon_rate);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_num_coupons_remain',p_num_coupons_remain);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_day_count_type',p_day_count_type);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_first_trans_flag',p_first_trans_flag);
   XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'p_deal_subtype',p_deal_subtype);
   XTR_RISK_DEBUG_PKG.dpop('calculate_bond_price_yield');
END IF;
XTR_RISK_DEBUG_PKG.stop_debug;
*/

   -- Added for Interest Override
   l_first_trans_flag := p_first_trans_flag;
   --

   IF (nvl(p_input_or_calculator,'I') = 'I') THEN
    open   ISSUE_DETAILS;
    fetch  ISSUE_DETAILS INTO l_yr_calc_type,l_coupon_rate,l_currency,
                           l_calc_type,l_bond_commence,l_coupon_freq,
                           l_accrued_int_calc_basis,l_maturity_date,
                           l_price_precision,l_price_round_type,
                           l_yield_precision,l_yield_round_type,
                           l_calc_precision, l_rounding_type;
    close ISSUE_DETAILS;
  ELSE
    l_yr_calc_type	:= p_year_calc_type;
    l_coupon_rate	:= p_coupon_rate;
    l_calc_type		:= p_calc_type;
    l_bond_commence	:= p_commence_date;
    l_maturity_date	:= p_maturity_date;
    l_coupon_freq	:= p_coupon_freq;
    l_accrued_int_calc_basis := p_accrued_int_calc_basis;
    l_yield_precision	:= p_yield_rounding;
    l_yield_round_type  := p_yield_round_type;
    l_price_precision	:= p_price_rounding;
    l_price_round_type  := p_price_round_type;
    l_calc_precision    := p_calc_rounding;
    l_rounding_type     := p_py_in.p_rounding_type;  -- 2737823
  END IF;

  --start bug 2804548
  IF (l_calc_type in ('FL IRREGULAR','FL REGULAR')) then
     open get_benchmark_rate(p_settlement_date,p_bond_issue_code);
     fetch get_benchmark_rate into l_coupon_rate,v_float_margin;
     close get_benchmark_rate;
     v_float_margin := nvl(v_float_margin,0);
  END IF;
  --end bug 2804548

  --
  IF ((nvl(p_input_or_calculator,'I') = 'I') or
      (nvl(p_input_or_calculator,'I') = 'C' and p_bond_issue_code is not null and
       p_ex_cum_next_coupon = 'CUM' and l_calc_type = 'COMPOUND COUPON')) then
     -- Calculate for Coupon Bonds (non-zero coupon bond)

     ----------------------------------------------------------------------------------
     -- COMPOUND COUPON: also fetch the first coupon date, and previous full coupons
     ----------------------------------------------------------------------------------
     open  PRV_COUPON_DATES;
     fetch PRV_COUPON_DATES INTO l_prev_coupon_date, l_odd_coupon_maturity, l_num_full_cpn_previous;
     close PRV_COUPON_DATES;

     --------------------------------------
     -- COMPOUND COUPON
     --------------------------------------
     if l_odd_coupon_maturity is null and l_calc_type = 'COMPOUND COUPON' then
        select min(COUPON_DATE)
        into   l_odd_coupon_maturity
        from   xtr_bond_coupon_dates
        where  bond_issue_code = p_bond_issue_code;
     end if;

     ----------------------------------------------------------------------------------
     -- Note.  COMPOUND COUPON : If Settlement Date falls in the first coupon,
     --                          l_next_coupon_date is the first coupon's maturity date
     ----------------------------------------------------------------------------------
     open  NXT_COUPON_DATES;
     fetch NXT_COUPON_DATES INTO l_next_coupon_date, l_num_full_cpn_remain;
     close NXT_COUPON_DATES;

  ELSE  -- from calculator without issue code

     l_prev_coupon_date := p_prev_coupon_date;
     l_next_coupon_date := p_next_coupon_date;

     IF p_ex_cum_next_coupon = 'EX' then
        -- correct the next coupon date when called from calculator form for the
        -- calculation
        IF p_bond_issue_code is null then
           l_next_coupon_date:=add_months(l_prev_coupon_date,12/l_coupon_freq);
        ELSE
           open  NXT_COUPON_DATES;
           fetch NXT_COUPON_DATES INTO l_next_coupon_date,l_dummy_num;
           close NXT_COUPON_DATES;
        END IF;

     ------------------------------------------------------------------------------------
     -- COMPOUND COUPON
     ------------------------------------------------------------------------------------
     ELSIF p_ex_cum_next_coupon = 'CUM' and l_calc_type = 'COMPOUND COUPON' then

        IF p_bond_issue_code is null then

           --------------------------------------------------------------------------------------
           -- COMPOUND COUPON: l_num_full_cpn_remain := p_num_coupons_remain;  -- from calculator
           --------------------------------------------------------------------------------------
           l_odd_coupon_maturity    := ODD_COUPON_DATE(l_bond_commence,l_maturity_date,l_coupon_freq,'M');
           l_num_full_cpn_previous  := PREVIOUS_FULL_COUPONS(l_bond_commence,  l_maturity_date,
                                                             p_settlement_date,l_coupon_freq);
           ----------------------------------------------------------------------------------

        END IF;
     END IF;
     l_num_full_cpn_remain := p_num_coupons_remain;

  END IF;

  ---------------------------------------------------------------------------------------
  IF l_prev_coupon_date is null or
    (l_prev_coupon_date is not null and l_prev_coupon_date < l_odd_coupon_maturity and
     l_calc_type = 'COMPOUND COUPON') THEN
     l_prev_coupon_date := l_bond_commence;
  END IF;

  if l_next_coupon_date is null and l_calc_type = 'COMPOUND COUPON' then
     l_next_coupon_date := p_settlement_date;
  end if;
  ---------------------------------------------------------------------------------------

  IF (l_calc_type <> 'ZERO COUPON') then
    -- calculate days run within coupon preiod
    -- note that CALC_DAYS_RUN_C is used insatead of CALC_DAYS_RUN because the day
    -- count basis could be ACT/ACT-BOND

    --  Bug 2358500.
    --  Re-arranged the order of the calls to the "calc_days_run_c" procedure
    --  so that the year basis is based on the entire related coupon period
    --  instead of for a subperiod from/to the settlement date.
    --  The year basis will be needed to calculate the purchase accrued
    --  interest for a variable bond.

    --====================================================================================
    --  Added for Interest Override feature
    -- (The following result is not used by COMPOUND COUPON.)
    --====================================================================================
    IF p_day_count_type='B' AND p_ex_cum_next_coupon='EX' THEN
       l_first_trans_flag := NULL;
    ELSE
       l_first_trans_flag := p_first_trans_flag;
    END IF;

    CALC_DAYS_RUN_C(p_settlement_date,
                    l_next_coupon_date,
                    l_accrued_int_calc_basis,
                    l_coupon_freq,
                    l_days_settle_to_nxt_cpn,
                    yr_basis,
                    NULL,
                    p_day_count_type,      -- Added for Interest Override
                    l_first_trans_flag);   -- Added for Interest Override

    --====================================================================================
    -- Added for Interest Override feature
    -- Added 'SHORT' for COMPOUND COUPON - need to consider "Both" for SELL and SHORT only
    --====================================================================================
    IF p_day_count_type='B' and nvl(p_deal_subtype,'BUY') not in ('SELL','SHORT') THEN
       l_first_trans_flag := NULL;
    ELSE
       l_first_trans_flag := p_first_trans_flag;
    END IF;

    -------------------------------------------------------------------------------------------
    -- If Settlement Date is within first coupon, then l_prev_coupon_date = Bond Start
    -- If Settlement Date is after first coupon,  then l_prev_coupon_date = Previous Coupon Date
    -- If Settlement Date is on a Coupon Date,    then l_prev_coupon_date = Settlement Date
    --                      (from PRV_COUPON_DATE cursor, and l_days_last_cpn_to_settle = 0)
    -------------------------------------------------------------------------------------------

    CALC_DAYS_RUN_C(l_prev_coupon_date,
                    p_settlement_date,
                    l_accrued_int_calc_basis,
                    l_coupon_freq,
                    l_days_last_cpn_to_settle,
                    yr_basis,
                    NULL,
                    p_day_count_type,
                    l_first_trans_flag);


    --====================================================================================
    -- For Compound Coupon, find odd coupon date for subsequent calculations.
    --====================================================================================
    if l_calc_type = 'COMPOUND COUPON' then
       l_odd_coupon_start := ODD_COUPON_DATE(l_bond_commence, l_maturity_date, l_coupon_freq,'S');
    end if;

    --====================================================================================
    -- Number of days in Current coupon - need to consider "Both" for all subtypes
    --====================================================================================
    l_first_trans_flag := p_first_trans_flag;

    if l_calc_type = 'COMPOUND COUPON' and p_settlement_date < l_odd_coupon_maturity then
       --------------------------------------------------
       -- Settlement date is in the first coupon
       --------------------------------------------------
       CALC_DAYS_RUN_C(l_odd_coupon_start,
                       l_odd_coupon_maturity,
                       l_accrued_int_calc_basis,
                       l_coupon_freq,
                       l_days_last_cpn_to_nxt_cpn,
                       yr_basis,
                       NULL,
                       p_day_count_type,    -- Added for Interest Override
                       l_first_trans_flag); -- Added for Interest Override
    else
       --------------------------------------------------
       -- Settlement date is on or after the first coupon
       --------------------------------------------------
       CALC_DAYS_RUN_C(l_prev_coupon_date,
                       l_next_coupon_date,
                       l_accrued_int_calc_basis,
                       l_coupon_freq,
                       l_days_last_cpn_to_nxt_cpn,
                       yr_basis,
                       NULL,
                       p_day_count_type,    -- Added for Interest Override
                       l_first_trans_flag); -- Added for Interest Override

    end if;

    --=================================================================================================
    -- COMPOUND COUPON - Find Number of Previous Quasi Coupon
    --=================================================================================================
    if l_calc_type = 'COMPOUND COUPON' then

       if nvl(l_days_last_cpn_to_settle,0) <> 0 and nvl(l_days_last_cpn_to_nxt_cpn,0) <> 0 then
          l_num_current_coupon := l_days_last_cpn_to_settle/l_days_last_cpn_to_nxt_cpn;
       else
          ---------------------------------------------------------------------------
          -- If Settlement Date is on Coupon Date, then l_days_last_cpn_to_settle = 0
          ---------------------------------------------------------------------------
          l_num_current_coupon := 0;
       end if;

       l_bond_rec.p_bond_commence         := l_bond_commence;
       l_bond_rec.p_odd_coupon_start      := l_odd_coupon_start;
       l_bond_rec.p_odd_coupon_maturity   := l_odd_coupon_maturity;
       l_bond_rec.p_calc_date             := p_settlement_date;
       l_bond_rec.p_yr_calc_type          := l_accrued_int_calc_basis;
       l_bond_rec.p_frequency             := l_coupon_freq;
       l_bond_rec.p_curr_coupon           := l_num_current_coupon;
       l_bond_rec.p_prv_full_coupon       := l_num_full_cpn_previous;
       l_bond_rec.p_day_count_type        := p_day_count_type;
       l_prv_quasi_coupon                 := 0;

       l_prv_quasi_coupon := CALC_TOTAL_PREVIOUS_COUPON(l_bond_rec);

    end if;
    --=================================================================================================


    --  Bug 2358500.
    --  Re-worked previous code for purchase accrued interest calculations.
    --  Added back purchase accrued interest formula for variable bonds
    --  removed for patchset C enhancements where the new day count basis
    --  'Actual/Actual-Bond' was introduced.

    --  The formula for fixed coupon deals is:
    --  (nbr of interest days * cpn rate) / (cpn frequency * nbr of days in coupon period)
    --
    --  The formula for variable coupon deals is:
    --  (nbr of interest days * cpn rate) / year basis
    --
    --  where, the nbr of interest days is dependent on the coupon status of the deal.
    --  CUM vs EX.
    --  CUM - number of days between last cpn or deal start and deal settlement.
    --  EX  - number of days between deal settlement and cpn maturity.

    --  NOTE: This newly added formula for variable coupon deals will not work properly
    --        for "odd" coupon periods (ie.  frequency setup as 4, but only 1st coupon
    --        is due 3 months after bond issue start, the remaining coupons are semi-annual)
    --        However, none of the current logic will work for these "odd" coupon periods,
    --        regardless of day count basis or coupon type (flat vs. variable).
    --        This issue has been logged and a decision will have to be made to address it or not.

    l_coupon_rate := ROUND_P(l_coupon_rate);

    --====================================================================================
    if l_calc_type = 'COMPOUND COUPON' then
    --====================================================================================

       if l_coupon_freq = 0 then
          l_temp := 0;
       else
          l_temp  := ROUND_P( ROUND_P(l_coupon_rate / 100) / nvl(l_coupon_freq,2));
       end if;

       p_accrued_interest := ROUND_P( 100 * POWER ( 1 + l_temp, l_prv_quasi_coupon) - 100);

    --====================================================================================
    else  -- FLAT or VARIABLE
    --====================================================================================
       -- Always calculate accrued price for cum to get correct price later.

       l_temp := ROUND_P(l_days_last_cpn_to_settle * l_coupon_rate);

       If (l_calc_type in ('FLAT COUPON','FL REGULAR')) then --bug 2804548
          l_temp2 := ROUND_P(l_coupon_freq * l_days_last_cpn_to_nxt_cpn);
       Else
          l_temp2 := yr_basis;
       End If;

       l_acc_cum := ROUND_P(l_temp / l_temp2);

       -- If EX coupon, then calculate true accrued price.

       If (p_ex_cum_next_coupon = 'CUM') then
          p_accrued_interest := l_acc_cum;
       Else
          l_temp := ROUND_P(-(l_days_settle_to_nxt_cpn) * l_coupon_rate);
          p_accrued_interest :=  ROUND_P(l_temp / l_temp2);
       End If;

    end if;

  END IF;


--
-- note that CALC_DAYS_RUN_C is used insatead of CALC_DAYS_RUN because the day
--count basis could be ACT/ACT-BOND
  CALC_DAYS_RUN_C(l_prev_coupon_date,
                            l_next_coupon_date,
                            l_yr_calc_type,
                            l_coupon_freq,
                            l_days_last_cpn_to_nxt_cpn,
                            yr_basis,
                            NULL,
                            p_day_count_type,
                            l_first_trans_flag);

  -- Added for Interest Override feature
  IF p_day_count_type='B' AND p_ex_cum_next_coupon='EX' THEN
       l_first_trans_flag := NULL;
   ELSE
       l_first_trans_flag := p_first_trans_flag;
  END IF;

  CALC_DAYS_RUN_C(p_settlement_date,
                            l_next_coupon_date,
                            l_yr_calc_type,
                            l_coupon_freq,
                            l_days_settle_to_nxt_cpn,
                            yr_basis,
                            NULL,
                            p_day_count_type,
                            l_first_trans_flag);

  -- Added for Interest Override feature
  IF p_day_count_type='B' and nvl(p_deal_subtype,'BUY') <> 'SELL' THEN
       l_first_trans_flag := NULL;
   ELSE
       l_first_trans_flag := p_first_trans_flag;
  END IF;

  CALC_DAYS_RUN_C(l_prev_coupon_date,
                            p_settlement_date,
                            l_yr_calc_type,
                            l_coupon_freq,
                            l_days_last_cpn_to_settle,
                            yr_basis,
                            NULL,
                            p_day_count_type,
                            l_first_trans_flag);
  l_days_last_cpn_to_nxt_cpn := nvl(l_days_last_cpn_to_nxt_cpn,0);
   --
--
  IF (l_calc_type in ('FLAT COUPON','VARIABLE COUPON','FL REGULAR','FL IRREGULAR')) then
    IF p_calculate_yield_or_price = 'P' then
    -- Calculate Price (already have yield passed in as p_yield)
      --start bug 2804548
      IF (l_calc_type in ('FLAT COUPON','VARIABLE COUPON')) then
         l_coupon_rate_fl := l_coupon_rate;
         p_yield := ROUND_P(p_yield);
      ELSE --FLOATING BOND
         l_coupon_rate_fl := l_coupon_rate;
	 p_yield_temp:=p_yield;--bug 3135424
         --p_yield := ROUND_P(l_coupon_rate_fl-(v_float_margin/100)+(p_yield/100));
	 p_yield := ROUND_P(l_coupon_rate_fl-(v_float_margin/100)+(p_yield));
      END IF;
      --end bug 2804548
      If (l_days_last_cpn_to_nxt_cpn <> 0 and l_coupon_freq <> 0) then
        l_temp := ROUND_P(p_yield / 100);
        l_temp := ROUND_P(l_temp/l_coupon_freq);
        l_temp2:= ROUND_P(l_days_settle_to_nxt_cpn /
                          l_days_last_cpn_to_nxt_cpn);
        l_temp:= ROUND_P(power((1+l_temp),l_temp2));
        l_dirty_px_1 := ROUND_P(100/l_temp);
      ELSE
        l_dirty_px_1 := 0;
      End If;
      If (l_coupon_freq <> 0) then
        l_coupon_rate_fl:= ROUND_P(l_coupon_rate_fl);
        l_temp := ROUND_P(l_coupon_rate_fl/100);
        l_dirty_px_2 := ROUND_P(l_temp / l_coupon_freq);
        l_temp := ROUND_P(p_yield / 100);
        l_temp := ROUND_P(l_temp/l_coupon_freq);
        l_temp := ROUND_P(power((l_temp+1),l_num_full_cpn_remain));
        l_temp:= ROUND_P(1/l_temp);
        l_dirty_px_3 := 1 - l_temp;
        l_temp := ROUND_P(p_yield / 100);
        l_temp := ROUND_P(l_temp/l_coupon_freq);
        l_temp:= ROUND_P(1/(1+l_temp));
        l_dirty_px_4 := 1 - l_temp;
        l_temp := ROUND_P(p_yield / 100);
        l_temp := ROUND_P(l_temp/l_coupon_freq);
        l_temp := ROUND_P(power((1+l_temp),l_num_full_cpn_remain - 1));
        l_dirty_px_5 := ROUND_P(1 /l_temp);
      Else
        l_dirty_px_2 := 0;
        l_dirty_px_3 := 0;
        l_dirty_px_4 := 0;
        l_dirty_px_5 := 0;
      End If;
      If (l_dirty_px_4 <> 0) then
        l_temp:= ROUND_P(l_dirty_px_3 / l_dirty_px_4);
        l_temp:= ROUND_P(l_dirty_px_2 * l_temp);
        p_dirty_price := ROUND_P(l_dirty_px_1 *(l_temp+l_dirty_px_5));
        -- if coupon status is EX, then adjust dirty price to be correct
        -- dirty_ex = acc_ex +dirty_cum - acc_cum
        IF p_ex_cum_next_coupon = 'EX' then
          IF (l_price_round_type = 'T') THEN
            l_temp:=  trunc(p_dirty_price, l_price_precision);
            l_temp2 := trunc(nvl(p_accrued_interest,0), l_price_precision);
            l_temp3 := trunc(l_acc_cum, l_price_precision);
          ELSE
            l_temp := round(p_dirty_price, l_price_precision);
            l_temp2 := round(nvl(p_accrued_interest,0), l_price_precision);
            l_temp3 := round(l_acc_cum,l_price_precision);
          END IF;
          p_dirty_price:= l_temp2+l_temp-l_temp3;
        END IF;
      Else
        p_dirty_price := null;
      End If;
   --
      If (p_dirty_price is not NULL) then
        IF (l_price_round_type = 'T') THEN
          l_temp:=  trunc(p_dirty_price, l_price_precision);
          l_temp2 := trunc(nvl(p_accrued_interest,0), l_price_precision);
        ELSE
          l_temp := round(p_dirty_price, l_price_precision);
          l_temp2 := round(nvl(p_accrued_interest,0), l_price_precision);
        END IF;
        p_clean_price := l_temp-l_temp2;
      Else
        p_clean_price := null;
      End If;
    --
      --bug 3135424 return the Discount Margin in percent point
      if l_calc_type in ('FL REGULAR','FL IRREGULAR') then
         p_yield:=p_yield_temp;
      END IF;
    --
    ELSE   -- Calculate Yield (already have dirty price passed in
           -- as p_dirty_price)
      --
      -- Calculate the missing price info
      IF (p_clean_price IS NULL) THEN
	-- Need to calculate "CUM" dirty price to find yield
        IF p_ex_cum_next_coupon = 'EX' THEN
          l_dirty_price_cum := p_dirty_price - p_accrued_interest + l_acc_cum;
        ELSE
    	  l_dirty_price_cum := p_dirty_price;
        END IF;
	--
        IF (l_price_round_type = 'T') THEN
          l_temp:=  trunc(p_dirty_price, l_price_precision);
          l_temp2 := trunc(nvl(p_accrued_interest,0), l_price_precision);
        ELSE
          l_temp := round(p_dirty_price, l_price_precision);
          l_temp2 := round(nvl(p_accrued_interest,0), l_price_precision);
        END IF;
        p_clean_price:= l_temp - l_temp2;
      ELSE
	-- Need to calculate "CUM" dirty price to find yield
        IF p_ex_cum_next_coupon = 'EX' THEN
          l_dirty_price_cum := p_clean_price + l_acc_cum;
        ELSE
          l_dirty_price_cum := p_clean_price + p_accrued_interest;
        END IF;
	--
        IF (l_price_round_type = 'T') THEN
          l_temp:=  trunc(p_clean_price, l_price_precision);
          l_temp2 := trunc(nvl(p_accrued_interest,0), l_price_precision);
        ELSE
          l_temp := round(p_clean_price, l_price_precision);
          l_temp2 := round(nvl(p_accrued_interest,0), l_price_precision);
        END IF;
        p_dirty_price := l_temp + l_temp2;
      END IF;
      If (p_dirty_price is NULL) then
        p_yield := null;
      Else
      -- initially set yield to Coupon Rate
        --start bug 2804548
        IF (l_calc_type in ('FLAT COUPON','VARIABLE COUPON')) then
           l_coupon_rate_fl:= ROUND_Y(l_coupon_rate);
           p_yield := l_coupon_rate_fl;
        ELSE --FLOATING BOND
           l_coupon_rate_fl := ROUND_Y(l_coupon_rate);
           --bug 3145424 p_yield := l_coupon_rate_fl-(v_float_margin/100);
	   p_yield := l_coupon_rate_fl-(v_float_margin);
        END IF;
        --end bug 2804548
        l_count := 0;
        l_days_last_cpn_to_nxt_cpn := nvl(l_days_last_cpn_to_nxt_cpn,0);
        LOOP
          l_count := l_count + 1;
          If (l_days_last_cpn_to_nxt_cpn <> 0 and l_coupon_freq <> 0) then
            l_dirty_px_1 := 100 / power((1 + (p_yield / 100 / l_coupon_freq)),
               (l_days_settle_to_nxt_cpn / l_days_last_cpn_to_nxt_cpn));
          Else
            l_dirty_px_1 := 0;
          End If;
          If (l_coupon_freq <> 0) then
            l_dirty_px_2 := ((l_coupon_rate_fl / 100) / l_coupon_freq);
            l_dirty_px_3 := 1 - (1 / power((1 + ((p_yield / 100) /
              l_coupon_freq)), l_num_full_cpn_remain));
            l_dirty_px_4 := 1 - (1 / (1 + ((p_yield / 100) / l_coupon_freq)));
            l_dirty_px_5 := 1 / power((1 + ((p_yield / 100) / l_coupon_freq)),
            (l_num_full_cpn_remain - 1));
          Else
            l_dirty_px_2 := 0;
            l_dirty_px_3 := 0;
            l_dirty_px_4 := 0;
            l_dirty_px_5 := 0;
          End If;
          If (l_dirty_px_4 <> 0) then
            l_calc_dirty_price := l_dirty_px_1 * (l_dirty_px_2 * (l_dirty_px_3
              /l_dirty_px_4) + l_dirty_px_5);
          Else
            l_calc_dirty_price := 0;
          End If;
          EXIT WHEN ((abs(l_calc_dirty_price - nvl(l_dirty_price_cum,0)) <=
            0.0000002) or (l_count >= 15000));
          IF l_calc_dirty_price > nvl(l_dirty_price_cum,0) then
            IF l_inc_flag='-' then
              l_inc_flag :='+';
              l_yield_inc:=ROUND_Y(l_yield_inc/2);
            END IF;
            p_yield :=p_yield + l_yield_inc;
          ELSE
            IF l_inc_flag='+' then
              l_inc_flag :='-';
              l_yield_inc:=ROUND_Y(l_yield_inc/2);
            END IF;
            p_yield :=p_yield - l_yield_inc;
          END IF;
        END LOOP;
        --start bug 2804548
        if l_calc_type in ('FL REGULAR','FL IRREGULAR') then
          v_actual_ytm := p_yield; --for QRM BPV
          --bug 3135424 p_yield := (p_yield-ROUND_Y(l_coupon_rate-(v_float_margin/100)))*100;
          p_yield := (p_yield-ROUND_Y(l_coupon_rate-(v_float_margin/100)));
        end if;
        --end bug 2804548
      End If;
    END IF;

  ELSIF l_calc_type = 'COMPOUND COUPON' then

     --=================================================================================================
     --  Calculate Number of Remaining Quasi Coupon
     --=================================================================================================
     l_num_full_cpn_remain := nvl(l_num_full_cpn_remain, 0);

     CALC_DAYS_RUN_C(p_settlement_date,
                     l_next_coupon_date,
                     l_yr_calc_type,
                     l_coupon_freq,
                     l_days_settle_to_nxt_cpn,
                     yr_basis,
                     NULL,
                     p_day_count_type,
                     'N');

     if p_settlement_date < l_odd_coupon_maturity then
        CALC_DAYS_RUN_C(l_odd_coupon_start,
                        l_odd_coupon_maturity,
                        l_yr_calc_type,
                        l_coupon_freq,
                        l_days_in_current_cpn,
                        yr_basis,
                        NULL,
                        p_day_count_type,    -- Added for Interest Override
                        'N');                -- Added for Interest Override
     else
        CALC_DAYS_RUN_C(l_prev_coupon_date,
                        l_next_coupon_date,
                        l_yr_calc_type,
                        l_coupon_freq,
                        l_days_in_current_cpn,
                        yr_basis,
                        NULL,
                        p_day_count_type,
                        'N');
     end if;

     IF (nvl(l_num_full_cpn_remain, 0) <= 0) THEN
        if nvl(l_days_settle_to_nxt_cpn,0) <> 0 and nvl(l_days_in_current_cpn,0) <> 0 then
           l_num_full_cpn_remain := l_days_settle_to_nxt_cpn/l_days_in_current_cpn;
        else
           l_num_full_cpn_remain := 0;
        end if;
     ELSE
        if nvl(l_days_settle_to_nxt_cpn,0) <> 0 and nvl(l_days_in_current_cpn,0) <> 0 then
           l_num_full_cpn_remain := (l_num_full_cpn_remain - 1) + l_days_settle_to_nxt_cpn/l_days_in_current_cpn;
        else
           l_num_full_cpn_remain := (l_num_full_cpn_remain - 1);
        end if;
     END IF;

     --=================================================================================================

     FND_CURRENCY.Get_Info ( l_currency,
                             l_precision,
                             l_ext_precision,
                             l_min_acct_unit);

     l_full_quasi_coupon := 0;

     if p_bond_issue_code is not null then
        open  TOTAL_FULL_COUPONS (p_bond_issue_code);
        fetch TOTAL_FULL_COUPONS into l_full_quasi_coupon;
        close TOTAL_FULL_COUPONS;
     else
        ------------------------------------
        -- COMPOUND COUPON - for calculator
        ------------------------------------
        l_full_quasi_coupon := FULL_COUPONS(l_bond_commence, l_maturity_date, l_coupon_freq);
     end if;

     --------------------------------------------------------------------------------------------
     -- Calculate Price
     --------------------------------------------------------------------------------------------
     IF p_calculate_yield_or_price = 'P' then

        if p_yield is null then
           if p_dirty_price is not null then
              p_clean_price := p_dirty_price - p_accrued_interest;
           else
              p_clean_price := null;
           end if;
        else
           l_temp := ROUND_P(p_yield);
           l_temp := ROUND_P(p_yield / 100);

           ----------------------------------------------------------------------
           -- Calculate Redemption Value
           ----------------------------------------------------------------------
           l_comp_coupon.p_bond_start_date       := l_bond_commence;
           l_comp_coupon.p_odd_coupon_start      := l_odd_coupon_start;
           l_comp_coupon.p_odd_coupon_maturity   := l_odd_coupon_maturity;
           l_comp_coupon.p_full_coupon           := l_full_quasi_coupon;
           l_comp_coupon.p_coupon_rate           := l_coupon_rate;
           l_comp_coupon.p_maturity_amount       := 100;
           l_comp_coupon.p_precision             := l_precision;
           l_comp_coupon.p_rounding_type         := l_rounding_type;
           l_comp_coupon.p_year_calc_type        := l_yr_calc_type;
           l_comp_coupon.p_frequency             := l_coupon_freq;
           l_comp_coupon.p_day_count_type        := p_day_count_type;
           l_comp_coupon.p_amount_redemption_ind := 'R';

           l_redemption_value := CALC_COMPOUND_COUPON_AMT(l_comp_coupon);
           --------------------------------------------------------------------------

           if POWER(1+l_temp,l_num_full_cpn_remain) <> 0 then
              p_clean_price := ((100+l_redemption_value)/POWER(1+(l_temp/l_coupon_freq),l_num_full_cpn_remain))
                               - p_accrued_interest;
           else
              p_clean_price := 0;
           end if;

           ------------------------------------------------------
           -- should this be reset everytime  ????????????????
           ------------------------------------------------------
           p_dirty_price := p_clean_price + p_accrued_interest;
           ------------------------------------------------------

        end if;

     --------------------------------------------------------------------------------------------
     -- Calculate Yield
     --------------------------------------------------------------------------------------------
     ELSE

        if p_clean_price is null then
           if p_dirty_price is not null then
              p_clean_price := p_dirty_price - p_accrued_interest;
           end if;
        else
           if p_dirty_price is null then
              p_dirty_price := p_clean_price + p_accrued_interest;
           end if;
        end if;

        if p_clean_price is not null then

           ----------------------------------------------------------------------
           -- Calculate Coupon Amount
           ----------------------------------------------------------------------
           l_comp_coupon.p_bond_start_date       := l_bond_commence;
           l_comp_coupon.p_odd_coupon_start      := l_odd_coupon_start;
           l_comp_coupon.p_odd_coupon_maturity   := l_odd_coupon_maturity;
           l_comp_coupon.p_full_coupon           := l_full_quasi_coupon;
           l_comp_coupon.p_coupon_rate           := l_coupon_rate;
           l_comp_coupon.p_maturity_amount       := l_face_value;
           l_comp_coupon.p_precision             := l_precision;
           l_comp_coupon.p_rounding_type         := l_rounding_type;
           l_comp_coupon.p_year_calc_type        := l_yr_calc_type;
           l_comp_coupon.p_frequency             := l_coupon_freq;
           l_comp_coupon.p_day_count_type        := p_day_count_type;
           l_comp_coupon.p_amount_redemption_ind := 'A';

           l_coupon_amount := CALC_COMPOUND_COUPON_AMT(l_comp_coupon);
           --------------------------------------------------------------------------
           l_dummy_num := l_face_value + l_coupon_amount;

           if p_dirty_price is not null and (nvl(p_input_or_calculator,'I') = 'C' or l_consideration is null) then
               -- bug 2617512: change way consideration is calculated
               l_amt1 := round(l_face_value, nvl(l_precision,2));
               l_amt2 := round(p_clean_price, nvl(p_price_rounding,4)) / 100;
               l_amt3 := round(p_accrued_interest, nvl(p_price_rounding, 4)) / 100;
               l_consideration := round(l_amt1 * l_amt2 + xtr_fps2_p.interest_round(l_amt1 * l_amt3, nvl(l_precision,2), l_rounding_type));
           end if;

           if nvl(l_num_full_cpn_remain,0) <> 0 and l_consideration <> 0 then
              p_yield:= (POWER(l_dummy_num/l_consideration,1/l_num_full_cpn_remain)-1)*l_coupon_freq*100;
           else
              p_yield:= 0;
           end if;

        else
           p_yield := null;
        end if;

     END IF;


  ELSE
  -- Calculate for Zero Coupon Bonds
    --bug2536590
    l_num_full_cpn_remain := nvl(l_num_full_cpn_remain, 0);
    CALC_DAYS_RUN_C(p_settlement_date,
                              l_maturity_date,
                              l_yr_calc_type,
                              l_coupon_freq,
                              l_days_settle_to_maturity,
                              yr_basis,
                              NULL,
                              p_day_count_type,
                              l_first_trans_flag);
    l_settle_to_maturity_years := ROUND_P(l_days_settle_to_maturity/yr_basis);

    IF (nvl(l_num_full_cpn_remain, 0) <= 0) THEN
      l_num_full_cpn_remain := 0;
    ELSE
      l_num_full_cpn_remain := l_num_full_cpn_remain - 1;
    END IF;
    /* commented out for bug2536590
    If (l_days_last_cpn_to_nxt_cpn <> 0) then
      IF xtr_risk_debug_pkg.g_Debug THEN
         XTR_RISK_DEBUG_PKG.dlog('CALCULATE_BOND_PRICE_YIELD: ' || 'BOND year basis', yr_basis);
      END IF;
      l_settle_to_nxt_cpn_ratio := ROUND_P(l_days_settle_to_nxt_cpn/yr_basis);
    Else
      l_settle_to_nxt_cpn_ratio := 0;
    End If;
    */

    IF p_calculate_yield_or_price = 'P' then
   -- Calculate Price
   -- Zero Coupon Bonds
      If (l_coupon_freq <> 0) then
--        p_yield:= ROUND_P(p_yield);
--        l_temp:= ROUND_P(p_yield/100);
--        l_temp:= ROUND_P(l_temp/l_coupon_freq);
--        p_dirty_price:=ROUND_P(100/(power(1+l_temp,
--				l_settle_to_nxt_cpn_ratio*l_coupon_freq)));
--
--        p_dirty_price:=ROUND_P(100/(power(1+l_temp,
--				l_settle_to_maturity_years*l_coupon_freq)));

          p_dirty_price:=ROUND_P(100 / power((1 + ((p_yield / 100) /
            l_coupon_freq)),( l_num_full_cpn_remain + (l_days_settle_to_nxt_cpn / l_days_last_cpn_to_nxt_cpn) )));
--
      Else
        p_dirty_price := null;
      End If;
      p_clean_price := p_dirty_price;
    ELSE
   -- Calculate Yield (already have dirty price passed in as p_dirty_price)
   --
      -- Calculate the missing price info
      IF (p_dirty_price is NULL) THEN
        p_dirty_price := p_clean_price;
      ELSE
        p_clean_price:= p_dirty_price;
      END IF;
      --
      If (p_dirty_price is NULL) then
        p_yield := null;
      Else
   -- approximate yield.
        If ((l_maturity_date - p_settlement_date)/365 <> 0) then
          l_coupon_rate:=ROUND_Y(l_coupon_rate);
          p_yield := l_coupon_rate;
         -- (100 - nvl(p_dirty_price,0)) / ((l_maturity_date - p_settlement_date)/365) / 100;
        Else
          p_yield := 0;
        End If;
        -- Performance BUG - inordinately SLOW
/*
        l_count := 0;
        LOOP
          l_count := l_count + 1;
----          l_calc_dirty_price := 100 / power((1 + ((p_yield / 100) /
----            l_coupon_freq)),(l_settle_to_nxt_cpn_ratio*l_coupon_freq));

--          l_calc_dirty_price := 100 / power((1 + ((p_yield / 100) /
--            l_coupon_freq)),(l_settle_to_maturity_years*l_coupon_freq));

          l_calc_dirty_price := 100 / power((1 + ((p_yield / 100) /
            l_coupon_freq)),( l_num_full_cpn_remain + (l_days_settle_to_nxt_cpn / l_days_last_cpn_to_nxt_cpn) ));
          EXIT WHEN ((abs(l_calc_dirty_price - nvl(p_dirty_price,0)) <=
          0.00002) or (l_count >= 15000));
          If (l_calc_dirty_price > nvl(p_dirty_price,0)) then
            If (l_inc_flag='-') then
              l_inc_flag :='+';
              l_yield_inc:=ROUND_Y(l_yield_inc/2);
            End If;
            p_yield:=p_yield + l_yield_inc;
          Else
            If (l_inc_flag='+') then
              l_inc_flag :='-';
              l_yield_inc:=ROUND_Y(l_yield_inc/2);
            End If;
            p_yield:=p_yield - l_yield_inc;
          End If;
        END LOOP;
*/
        -- Fast closed form solution
        --p_yield:=(power((100/p_dirty_price),(1/(l_settle_to_maturity_years*l_coupon_freq)))-1)*l_coupon_freq*100;
        p_yield:=(power((100/p_dirty_price),(1/( l_num_full_cpn_remain + (l_days_settle_to_nxt_cpn / l_days_last_cpn_to_nxt_cpn) )))-1)*l_coupon_freq*100;

      END IF;
    END IF;
  END IF;
  IF (l_yield_round_type = 'T') THEN
    p_yield :=trunc(p_yield,l_yield_precision);
  ELSE
    p_yield :=round(p_yield,l_yield_precision);
  END IF;
  IF (l_price_round_type = 'T') THEN
    p_accrued_interest := trunc(p_accrued_interest, l_price_precision);
    p_dirty_price := trunc(p_dirty_price, l_price_precision);
    p_clean_price := trunc(p_clean_price,l_price_precision);
  ELSE
    p_dirty_price := round(p_dirty_price, l_price_precision);
    p_accrued_interest := round(p_accrued_interest, l_price_precision);
    p_clean_price := round(p_clean_price,l_price_precision);
  END IF;
  p_py_out.p_yield := p_yield;
  p_py_out.p_accrued_interest := p_accrued_interest;
  p_py_out.p_clean_price := p_clean_price;
  p_py_out.p_dirty_price := p_dirty_price;
  p_py_out.p_actual_ytm := v_actual_ytm;

END CALCULATE_BOND_PRICE_YIELD;



--Bug 2804548
--This procedure calculates the Bond Rate Fixing date
--
PROCEDURE bond_rate_fixing_date_calc(p_in_rec IN BndRateFixDate_in_rec,
				 p_out_rec IN OUT NOCOPY BndRateFixDate_out_rec) IS
   v_date DATE;
   v_err_code        number(8);
   v_level           varchar2(2) := ' ';

BEGIN
   if p_in_rec.date_in is not null and p_in_rec.rate_fixing_day is not null
   and p_in_rec.ccy is not null then
      v_date := p_in_rec.date_in;
      FOR i in 1..p_in_rec.rate_fixing_day LOOP
         v_date := v_date-1;
         XTR_fps3_P.CHK_HOLIDAY (v_date,
                             p_in_rec.ccy,
                             v_err_code,
                             v_level);
         if v_err_code is not null then --is holiday
            v_date := xtr_fps3_p.PREVIOUS_BUS_DAY(v_date,
			p_in_rec.ccy);
         end if;
      end loop;
      p_out_rec.rate_fixing_date := v_date;
   else
     RAISE_APPLICATION_ERROR(-20001, 'One or more of the required parameters are missing.');
   end if;
END bond_rate_fixing_date_calc;



--Bug 2804548
--This procedure calculates Bond Coupon Amount.
--Copied some of the logic from xtr_calc_p.calc_bond_coupon_amounts
--
PROCEDURE calc_bond_coupon_amt(p_in_rec IN CalcBondCpnAmt_in_rec,
				 p_out_rec IN OUT NOCOPY CalcBondCpnAmt_out_rec) IS

   p_maturity_amount NUMBER;
   p_day_count_type xtr_deals.day_count_type%TYPE;
   p_settlement_date DATE;
   p_rounding_type xtr_deals.rounding_type%TYPE;
   p_deal_date DATE;
   p_income_tax_ref NUMBER;
   p_income_tax_rate NUMBER;
   p_coupon_tax_code xtr_rollover_transactions.tax_code%TYPE;
   p_bond_issue_code xtr_deals.bond_issue%TYPE;
	l_last_coupon_date	date;
        l_coupon_date 		date;
	l_bond_start_date	date;
	l_bond_maturity_date	date;
	l_precision		number;
	l_ext_precision		number;
	l_min_acct_unit		number;
	l_coupon_amt		number;
	l_currency		varchar2(15);
	l_coupon_rate		number;
	l_frequency		number;
	l_year_calc_type	varchar2(15);
	l_year_basis		number;
	l_nbr_days_in_period	number;
	l_calc_type		varchar2(15);
	-- Added for Interest Override
	l_original_amount       NUMBER;
	l_first_trans_flag      VARCHAR2(1);
	--
	l_income_tax_out	NUMBER;
	l_dummy_num		NUMBER;
	l_dummy_char		VARCHAR2(20);
--
      --The rate for FLoating BOND will be different for each COUPON,
      --while it's the same for non-FLoating BOND.
   cursor BOND_DETAILS(p_bond_issue_code VARCHAR2,
			p_coupon_date DATE) is
	select i.currency,
	       c.rate,
	       i.no_of_coupons_per_year,
	       i.maturity_date,
	       i.year_calc_type,
	       i.commence_date,
	       i.calc_type
	from xtr_bond_issues i, xtr_bond_coupon_dates c
	where i.bond_issue_code = p_bond_issue_code
        and c.bond_issue_code=i.bond_issue_code
        and c.coupon_date=p_coupon_date;
--
   cursor GET_LAST_COUPON_DATE(p_bond_issue_code VARCHAR2,
				p_next_coupon_date DATE) is
	select max(coupon_date)
	from xtr_bond_coupon_dates
	where bond_issue_code = p_bond_issue_code
	and coupon_date < p_next_coupon_date;
--
   cursor get_deal_info(p_deal_no NUMBER,p_trans_no NUMBER) is
        select d.start_date,d.maturity_balance_amount,d.day_count_type,
        d.rounding_type,
	d.deal_date,rt.tax_settled_reference,rt.tax_rate,d.bond_issue,
	rt.tax_code,rt.maturity_date
        from xtr_deals d, xtr_rollover_transactions rt
        where d.deal_no=p_deal_no
        and rt.deal_number=d.deal_no
        and rt.transaction_number=p_trans_no;
--
   cursor GET_SETTLE_METHOD(p_tax_code VARCHAR2) is
	select TAX_SETTLE_METHOD
  	from   XTR_TAX_BROKERAGE_SETUP
  	where  REFERENCE_CODE = p_tax_code;
--
   v_tax_settle_method xtr_tax_brokerage_setup.tax_settle_method%TYPE;
--

-- Added for Bug 4731954
Cursor C_ADD_RESALE_AMOUNT (p_deal_no NUMBER,l_curr_cpn_date date) is
   Select sum(face_value)
     from xtr_bond_alloc_details
    where deal_no = p_deal_no
      and cross_ref_start_date >= l_curr_cpn_date;

      p_resold_amount NUMBER; -- Added for Bug 4731954


BEGIN

   if p_in_rec.transaction_no is not null and p_in_rec.deal_no is not null then

      open get_deal_info(p_in_rec.deal_no,p_in_rec.transaction_no);
      fetch get_deal_info into p_settlement_date,p_maturity_amount,
		p_day_count_type,p_rounding_type,p_deal_date,p_income_tax_ref,
		p_income_tax_rate,p_bond_issue_code,p_coupon_tax_code,
		l_coupon_date;
      close get_deal_info;

      /* Obtain pertinent info on bond. */
      Open  BOND_DETAILS(p_bond_issue_code,
			l_coupon_date);
      Fetch BOND_DETAILS into l_currency, l_coupon_rate, l_frequency, l_bond_maturity_date,
                           l_year_calc_type, l_bond_start_date, l_calc_type;
      If (BOND_DETAILS%NOTFOUND) then
         Close BOND_DETAILS;
         FND_MESSAGE.Set_Name('XTR','XTR_2171');
         APP_EXCEPTION.Raise_Exception;
      End If;
      Close BOND_DETAILS;

      /* Obtain currency precision for bond. */

      FND_CURRENCY.Get_Info (
   			l_currency,
   			l_precision,
   			l_ext_precision,
   			l_min_acct_unit);

      /* Obtain last coupon date before the next coupon date.
      In the case of an 'EX' status bond, this last coupon date is > the settlement date.
      In the case of an 'CUM' status bond, this last coupon date is <= the settlement date.
      We need to determine this date in order to compute the 'nbr of days' between the coupon
      period, with consideration given for the days calc method. */

      Open  GET_LAST_COUPON_DATE(p_bond_issue_code,
				l_coupon_date);
      Fetch GET_LAST_COUPON_DATE into l_last_coupon_date;
      If (l_last_coupon_date is NULL) then

      -- NOTE:  Can't check for cursor %NOTFOUND since the 'max' will return a NULL row,
      --        which is considered a 'found' case.

         Close GET_LAST_COUPON_DATE;
         l_last_coupon_date := nvl(l_bond_start_date,p_settlement_date);
      Else
         Close GET_LAST_COUPON_DATE;
      End If;

      -- Added for Interest Override
      IF p_in_rec.transaction_no = 2 and l_calc_type <> 'COMPOUND COUPON' THEN
	 l_first_trans_flag :='Y';
      ELSE
	 l_first_trans_flag := NULL;
      END IF;

     -- Calculate the correct maturity amount by adding the balance amount with the amount
      -- sold after the maturity date of the transaction
      --  Added for Bug 4731954
      OPEN C_ADD_RESALE_AMOUNT(p_in_rec.deal_no,l_coupon_date);
      FETCH C_ADD_RESALE_AMOUNT INTO p_resold_amount;
      CLOSE C_ADD_RESALE_AMOUNT;

      p_maturity_amount := p_maturity_amount + nvl(p_resold_amount,0);

      --Calculate coupon amount
      If l_calc_type in ('VARIABLE COUPON','FL IRREGULAR') then

         /* Need to compute # of days between the coupon period and determine # of days in the year
            (l_year_basis) based on the year_calc_type. */

         -- Bug 2358549.
         -- Changed call to Calc_Days_Run_C from Calc_Days_Run in order
         -- to properly handle the year calc type of 'Actual/Actual-Bond'
         -- which was introduced in patchset C.

         XTR_CALC_P.Calc_Days_Run_C (
   			l_last_coupon_date,
	   		l_coupon_date,
   			l_year_calc_type,
   			l_frequency,
   			l_nbr_days_in_period,
			l_year_basis,
			NULL,
		        p_day_count_type,  -- Added for Override feature
			l_first_trans_flag --  Added for Override feature
				   );

	 -- Changed for Interest Override
         -- l_coupon_amt := round((p_maturity_amount * (l_coupon_rate / 100) * (l_nbr_days_in_period / l_year_basis)), l_precision);
         l_original_amount := xtr_fps2_p.interest_round((p_maturity_amount * (l_coupon_rate / 100) * (l_nbr_days_in_period / l_year_basis)), l_precision,p_rounding_type);
	  l_coupon_amt := l_original_amount;
      Elsif l_calc_type in ('FLAT COUPON','FL REGULAR') then
         --Flat coupons do not need to take day count basis into consideration.
         --We need to call this to calculate NO_OF_DAYS even though we are not using
         -- in coupon calculation.

         -- Bug 2358549.
         -- Changed call from Calc_Days_Run to Calc_Days_Run_C in order
         -- to properly handle the year calc type of 'Actual/Actual-Bond'
         -- which was introduced in patchset C.

         XTR_CALC_P.Calc_Days_Run_C (
   			l_last_coupon_date,
	   		l_coupon_date,
   			l_year_calc_type,
   			l_frequency,
   			l_nbr_days_in_period,
			l_year_basis,
			NULL,
		        p_day_count_type,  -- Added for Override feature
			l_first_trans_flag --  Added for Override feature
			);
	 -- Changed for Interest Override
         -- l_coupon_amt := round((p_maturity_amount * (l_coupon_rate / 100) / nvl(l_frequency,2)), l_precision);
	 l_original_amount := xtr_fps2_p.interest_round((p_maturity_amount * (l_coupon_rate / 100) / nvl(l_frequency,2)),
					     l_precision,p_rounding_type);
	 l_coupon_amt := l_original_amount;
      End If;

      -- calculate taxes
      IF (p_coupon_tax_code IS NOT NULL) THEN
           XTR_FPS1_P.calc_tax_amount('BOND',
				 p_deal_date,
				 null,
				 p_coupon_tax_code,
				 l_currency,
				 null,
				 0,
				 0,
				 null,
				 l_dummy_num,
				 l_coupon_amt,
				 p_income_tax_rate,
				 l_dummy_num,
				 l_income_tax_out,
				 l_dummy_num,
				 l_dummy_char);
         --bug 2919154 round 3 issue 1
         --OPEN get_settle_method(p_coupon_tax_code);
         --FETCH get_settle_method INTO v_tax_settle_method;
         --CLOSE get_settle_method;
      END IF;
   else
      RAISE_APPLICATION_ERROR(-20001, 'One or more of the required parameters are missing.');
   end if;
   p_out_rec.coupon_amt:=l_coupon_amt;
   p_out_rec.coupon_tax_amt:=l_income_tax_out;
END calc_bond_coupon_amt;



--Bug 2804548
--This procedure check whether the coupon or its tax has been reset.
--This is called during settlement authorization, coupon amount override
--Can be passed in with or w/o bond_issue_code and coupon_date.
--If the coupon has been reset the value OUT will be TRUE, else FALSE.
--
PROCEDURE check_coupon_rate_reset(p_in_rec IN ChkCpnRateReset_in_rec,
				 p_out_rec IN OUT NOCOPY ChkCpnRateReset_out_rec) IS

   cursor check_coupon_rate_reset(p_deal_no NUMBER,
				p_trans_no NUMBER) is
      select count(*)
      from xtr_bond_coupon_dates bc, xtr_deals d, xtr_rollover_transactions rt
      where rt.deal_number=p_deal_no
      and rt.transaction_number=p_trans_no
      and d.deal_no=rt.deal_number
      and bc.bond_issue_code=d.bond_issue
      and bc.coupon_date=rt.maturity_date
      and bc.rate_update_on<bc.rate_fixing_date;

   cursor check_coupon_rate_reset_all(p_deal_no NUMBER) is
      select count(*)
      from xtr_bond_coupon_dates bc, xtr_deals d, xtr_rollover_transactions rt
      where d.deal_no=p_deal_no
      and d.deal_no=rt.deal_number
      and bc.bond_issue_code=d.bond_issue
      and bc.coupon_date=rt.maturity_date
      and bc.rate_update_on<bc.rate_fixing_date;

   cursor get_coupon_info(p_settled_ref NUMBER) is
      select deal_number,transaction_number
      from xtr_rollover_transactions
      where tax_settled_reference=p_settled_ref;

   v_deal_no NUMBER;
   v_transaction_no NUMBER;
   v_dummy NUMBER;
BEGIN
   p_out_rec.yes := TRUE;
   if p_in_rec.deal_type is not null or p_in_rec.transaction_no is not null then
      if p_in_rec.deal_type='EXP' then
         open get_coupon_info(p_in_rec.transaction_no);
         fetch get_coupon_info into v_deal_no,v_transaction_no;
         close get_coupon_info;
      else
         v_deal_no := p_in_rec.deal_no;
         v_transaction_no := p_in_rec.transaction_no;
      end if;
      if v_transaction_no is null then
         open check_coupon_rate_reset_all(v_deal_no);
         fetch check_coupon_rate_reset_all into v_dummy;
         close check_coupon_rate_reset_all;
      else
         open check_coupon_rate_reset(v_deal_no,v_transaction_no);
         fetch check_coupon_rate_reset into v_dummy;
         close check_coupon_rate_reset;
      end if;
      if v_dummy>0 then
          p_out_rec.yes := FALSE;
      else
          p_out_rec.yes := TRUE;
      end if;
   else
      RAISE_APPLICATION_ERROR(-20001, 'One or more of the required parameters are missing.');
   end if;
   p_out_rec.deal_no:=v_deal_no;
END check_coupon_rate_reset;

END;


/
