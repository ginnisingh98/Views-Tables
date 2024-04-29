--------------------------------------------------------
--  DDL for Package Body XTR_MARKET_DATA_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_MARKET_DATA_P" AS
/* $Header: xtrmdcsb.pls 120.6 2007/11/13 10:21:27 kbabu ship $ */

--PL/SQL wrapper for Cubic Spline Interpolation
FUNCTION cubic_spline_interpolation (v_X XTR_MD_NUM_TABLE, v_Y XTR_MD_NUM_TABLE,
	v_N NUMBER, p_x NUMBER, p_endCondInd1 NUMBER, p_endCondInd2 NUMBER,
	p_endValue1 NUMBER, p_endValue2 NUMBER)
  RETURN VARCHAR2
  AS LANGUAGE JAVA NAME 'oracle.apps.xtr.utilities.server.CubicSplineInterpolation.start (oracle.sql.ARRAY, oracle.sql.ARRAY,int,double,int,int,double,double) return String';


/*--------------------------------------------------------------------------
LINEAR_INTERPOLATION
Returns a linearly interpolated (Y element) value
given p_t (X element).

p_t = the X element whose Y element is p_rate (to
  be interpolated).
p_t1 = one of the data point that is used to calculate
  the interpolated point. p_t2 = one of the data point
  that is used to calculate the interpolated point
  (has to be different from p_t1).
p_rate1 = the Y element associated with p_t1.
p_rate2 = the Y element associated with p_t2.
p_slope = the slope of the line that passed through
  (p_t1, p_rate1) and (p_t, p_rate). If p_slope is not
  null, p_t2 and p_rate2 is not necessary.
p_rate = the Y element.that is associated with p_t.
--------------------------------------------------------------------------*/
PROCEDURE LINEAR_INTERPOLATION (p_t 	      IN NUMBER,
				p_t1 	      IN NUMBER,
				p_t2	      IN NUMBER,
				p_rate1       IN NUMBER,
				p_rate2       IN NUMBER,
				p_slope       IN NUMBER,
				p_rate        OUT NOCOPY NUMBER) is
BEGIN

  p_rate := p_rate1*((p_t2-p_t)/(p_t2-p_t1))+p_rate2*(1-((p_t2-p_t)/(p_t2-p_t1)));

END LINEAR_INTERPOLATION;


/*-------------------------------------------------------------------------
DF_EXPONENTIAL_INTERPOLATION
Returns an exponentially interpolated (Y element)
value given p_t (X element), assuming all the input
rates are discount factors.

p_t = the X element whose Y element is p_rate (to
  be interpolated).
p_t1 = one of the data point that is used to calculate
  the interpolated point. p_t2 = one of the data point
  that is used to calculate the interpolated point
  (has to be different from p_t1).
p_rate1 = the Y element associated with p_t1.
p_rate2 = the Y element associated with p_t2.
p_rate = the Y element.that is associated with p_t.
--------------------------------------------------------------------------*/
PROCEDURE DF_EXPONENTIAL_INTERPOLATION (p_indicator CHAR, --'I' or 'O'
					p_t	IN NUMBER,
					p_t1	IN NUMBER,
					p_t2	IN NUMBER,
					p_rate1	IN NUMBER,
					p_rate2	IN NUMBER,
					p_rate  OUT NOCOPY NUMBER) is

BEGIN

  IF (p_indicator IS NULL or p_indicator = 'I') THEN
    p_rate := power(p_rate1,(p_t*((p_t2-p_t)/(p_t2-p_t1))/p_t1))*power(p_rate2,(p_t*((p_t-p_t1)/(p_t2-p_t1))/p_t2));
  ELSE
    p_rate := power(p_rate1, p_t/p_t1);
  END IF;

END DF_EXPONENTIAL_INTERPOLATION;



--This private procedure converts the given rate to day_count_basis1 rate
PROCEDURE MD_RATE_CONVERSION (p_spot_date IN DATE,
				p_future_date IN DATE,
				p_no_days2 IN NUMBER,
				p_ann_basis2 IN NUMBER,
				p_day_count_basis1 IN VARCHAR2,
				p_rate1 IN NUMBER,
				p_rate2 IN OUT NOCOPY NUMBER) is

  v_ann_basis1 NUMBER;
  v_no_days1 NUMBER;

BEGIN

  IF (p_no_days2 = 0) THEN
    p_rate2 := p_rate1;
  ELSE
    xtr_calc_p.calc_days_run_c(p_spot_date, p_future_date, p_day_count_basis1,
			null, v_no_days1, v_ann_basis1);

    p_rate2 := (p_rate1*v_no_days1*p_ann_basis2)/(v_ann_basis1*p_no_days2);
  END IF;

END MD_RATE_CONVERSION;



PROCEDURE Modified_Following_Holiday(p_currency IN VARCHAR2,
				     p_date_in IN DATE,
				     p_date_out OUT NOCOPY DATE) is
  v_err_code        number(8);
  v_level           varchar2(2) := ' ';
  v_date            DATE;

BEGIN

  v_date:= p_date_in;
  LOOP
  -- keep on subtracting a day until it's not a holiday or weekend
    v_date:=v_date - 1;
    XTR_fps3_P.CHK_HOLIDAY (v_date,
                             p_currency,
                             v_err_code,
                             v_level);
    EXIT WHEN v_err_code is null;
  END LOOP;
  p_date_out := v_date;

END;



PROCEDURE Following_Holiday(p_in_rec IN following_holiday_in_rec_type,
			    p_out_rec OUT NOCOPY following_holiday_out_rec_type) IS

  v_err_code        number(8);
  v_level           varchar2(2) := ' ';
  v_date            DATE;
  v_no_days	    NUMBER;
  v_dummy           NUMBER;
  v_term_type       VARCHAR2(20);

BEGIN

  IF (p_in_rec.p_term_type IS NULL) THEN
    --need to find out the term type based on 30/360 day count basis
    --which is the standard for period_code in current system rates.
    xtr_calc_p.calc_days_run_c(p_in_rec.p_spot_date, p_in_rec.p_future_date,
  			     '30/', v_dummy, v_no_days, v_dummy);
    IF (v_no_days >= 30) THEN
      v_term_type := 'M';
    ELSE
      v_term_type := 'D';
    END IF;
  ELSE
    v_term_type := p_in_rec.p_term_type;
  END IF;
  v_date := p_in_rec.p_future_date;
  LOOP
  -- keep on adding a day until it's not a holiday or weekend
    v_date:=v_date + 1;
    XTR_fps3_P.CHK_HOLIDAY (v_date,
                             p_in_rec.p_currency,
                             v_err_code,
                             v_level);
    EXIT WHEN v_err_code is null;
  END LOOP;
  -- if term type is less than a month just do following rule,
  -- if term type is over a year, do modified following rule
  IF (v_term_type IN ('D','O','DAY','DAYS') or p_in_rec.p_period_code = 0) THEN
    p_out_rec.p_date_out := v_date;
  ELSE
  -- if the month changed during the loop, do modified following
    IF TO_CHAR(v_date,'MM') <> TO_CHAR(p_in_rec.p_future_date,'MM') THEN
      Modified_Following_Holiday(p_in_rec.p_currency, p_in_rec.p_future_date,
				p_out_rec.p_date_out);
    ELSE
      p_out_rec.p_date_out := v_date;
    END IF;
  END IF;

END;


/*------------------------------------------------------------------------
GET_MD_FROM_CURVE
Returns a yield rate, discount factor, or volatility
from a given market data curve.

Record Type:
MD_FROM_CURVE_IN_REC_TYPE
MD_FROM_CURVE_OUT_REC_TYPE

Assumptions:
Only consider the passed parameter, p_side,
to determine the data side (bid, ask, mid),
and ignore the value of DATA_SIDE from XTR_RM_MD_CURVES
table.

The ordering priority of the interpolation method:
1.  Look at p_interpolation_method (passed parameter)
2.  If p_interpolation_method = 'D'/'DEFAULT' then look
    at DEFAULT_INTERPOLATION from XTR_RM_MD_CURVES

p_curve_code = name of curve from which to extract data.
p_source = table source for calculation.  'C' for Current
  System Rates table and 'R' for revaluation table.
p_indicator = data type of output.  'R' for yield rate,
  'D' for discount factor, 'V' for volatility.
p_spot_date = reference date.
p_future_date = future date.
p_day_count_basis_out = day count basis to use for output.
  Can set to null and disregard if p_curve_code is
  volatility curve.
p_interpolation_method = interpolation method to be used
  for curve. 'L'/'LINEAR' for linear, 'E'/'EXPON' for
  exponential, 'C'/'CUBIC' for cubic spline, or
  'D'/'DEFAULT' for the default value specified in the curve,
  otherwise it will be assumed to be 'L'.
p_side = data side of market to return. 'B'/'BID' for bid,
  'A'/'ASK' for ask, or 'M'/'MID' for mid.
  No 'BID/ASK' allowed.
p_batch_id = batch of revaluation table to be used. Can
  set to null and disregard if p_source <> 'R'.
p_md_out = output that is yield rate, discount factor, or
  volatility.
------------------------------------------------------------------------*/
PROCEDURE GET_MD_FROM_CURVE (p_in_rec  IN  md_from_curve_in_rec_type,
			     p_out_rec OUT NOCOPY md_from_curve_out_rec_type) is

  v_side VARCHAR2(20);

  CURSOR get_rate_value IS
     SELECT nvl(period_code,0) period_code,
		nvl(DECODE(v_side,'B',bid_rate,'BID',
			bid_rate, 'A', offer_rate, 'ASK', offer_rate,
			(bid_rate+offer_rate)/2),0) rate,
	nvl(day_count_basis,'ACTUAL/ACTUAL') day_count_basis,
	term_type, unique_period_id, currency
     FROM xtr_rm_md_show_curves_v outter
     WHERE curve_code = p_in_rec.p_curve_code
     AND outter.rate_date=
       (SELECT max(inner.rate_date)
        FROM   xtr_rm_md_show_curves_v inner
        WHERE  trunc(inner.rate_date) <= trunc(p_in_rec.p_spot_date)
        AND    curve_code = p_in_rec.p_curve_code
        AND    outter.unique_period_id=inner.unique_period_id)
     ORDER BY 1;

  CURSOR compare_dcb IS
     SELECT COUNT(*) FROM xtr_rm_md_show_curves_v t1,
	xtr_rm_md_show_curves_v t2
     WHERE t1.curve_code = p_in_rec.p_curve_code
     AND t2.curve_code = p_in_rec.p_curve_code
     AND (t1.rate_date, t1.unique_period_id) IN
             (SELECT MAX(rate_date), unique_period_id
		FROM xtr_rm_md_show_curves_v
		WHERE trunc(rate_date) <= trunc(p_in_rec.p_spot_date)
		AND curve_code = p_in_rec.p_curve_code
     		GROUP BY unique_period_id)
     AND (t2.rate_date, t2.unique_period_id) IN
             (SELECT MAX(rate_date), unique_period_id
		FROM xtr_rm_md_show_curves_v
		WHERE trunc(rate_date) <= trunc(p_in_rec.p_spot_date)
		AND curve_code = p_in_rec.p_curve_code
     		GROUP BY unique_period_id)
     AND nvl(t1.day_count_basis,'ACTUAL/ACTUAL')<>nvl(t2.day_count_basis,'ACTUAL/ACTUAL');

  CURSOR get_curve_interp_method IS
     SELECT default_interpolation FROM xtr_rm_md_curves
     WHERE curve_code = p_in_rec.p_curve_code;

  CURSOR get_rate_value_reval IS
     SELECT nvl(r.number_of_days,0) period_code,
	    nvl(DECODE(v_side, 'B', nvl(r.bid_overwrite, r.bid),
				'BID', nvl(r.bid_overwrite, r.bid),
				'A', nvl(r.ask_overwrite, r.ask),
				'ASK',nvl(r.ask_overwrite, r.ask),
	(nvl(r.bid,r.bid_overwrite)+nvl(r.ask,r.ask_overwrite))/2),0) rate,
	nvl(r.day_count_basis,'ACTUAL/ACTUAL') day_count_basis,
	r.day_mth term_type, r.reval_type unique_period_id,
	r.currencyA currency, r.volatility_or_rate rate_type
     FROM xtr_revaluation_rates r, xtr_rm_md_curve_rates c
     WHERE r.reval_type = c.rate_code
     AND c.curve_code = p_in_rec.p_curve_code
     AND r.batch_id = p_in_rec.p_batch_id
     ORDER BY 1;

  CURSOR compare_dcb_reval IS
     SELECT COUNT(*) FROM xtr_revaluation_rates r1,xtr_revaluation_rates r2,
	xtr_rm_md_curve_rates c1, xtr_rm_md_curve_rates c2
     WHERE r1.reval_type = c1.rate_code
     AND r2.reval_type = c2.rate_code
     AND c1.curve_code = p_in_rec.p_curve_code
     AND c2.curve_code = p_in_rec.p_curve_code
     AND r1.batch_id = p_in_rec.p_batch_id
     AND r2.batch_id = p_in_rec.p_batch_id
     AND nvl(r1.day_count_basis,'ACTUAL/ACTUAL')<>nvl(r2.day_count_basis,'ACTUAL/ACTUAL');

  --this SQL statement implements the logic to find data side explained in the
  --MD API doc.
  CURSOR get_curve_side IS
     SELECT DECODE(data_side, 'BID/ASK', p_in_rec.p_side, data_side) side
     FROM xtr_rm_md_curves
     WHERE curve_code = p_in_rec.p_curve_code;

  TYPE dcb_table IS TABLE OF VARCHAR2(15); -- day count basis table
  v_in_rec  xtr_rate_conversion.df_in_rec_type;
  v_out_rec xtr_rate_conversion.df_out_rec_type;
  v_hol_in_rec following_holiday_in_rec_type;
  v_hol_out_rec following_holiday_out_rec_type;
  v_X XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();--for day count
  v_Y XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();--for converted rate to ACT/ACT
  v_N XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();--for annual basis
  --for CS Intp original rate when v_uniform_day_count_basis IS FALSE
  v_YO XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
  v_dcb dcb_table := dcb_table();
  v_count BINARY_INTEGER;
  v_dummy NUMBER;
  v_found BOOLEAN := FALSE;
  v_final BOOLEAN := FALSE;
  v_xval NUMBER;--day count of the maturity date on ACT/ACT
  v_stop BOOLEAN;
  v_hi BINARY_INTEGER;
  v_lo BINARY_INTEGER;
  v_mid BINARY_INTEGER;
  v_err_code NUMBER(8);
  v_level VARCHAR2(2) :=  ' ';
  v_future_date DATE; --maturity date
  v_annual_basis NUMBER;
  v_day_count NUMBER;
  v_annual_basis_i NUMBER;--dummy variable for annual basis in
  v_day_count_i NUMBER;--dummy variable for day count in
  v_annual_basis_out NUMBER; --annual basis of the maturity date on ACT/ACT
  v_temp VARCHAR2(100);
  v_uniform_day_count_basis BOOLEAN := TRUE;
  v_day_count_basis_in VARCHAR2(15); --the MD dcb
  v_day_count_basis_out VARCHAR2(15); --the final answer dcb
  v_Yhi NUMBER;
  v_Ylo NUMBER;
  v_diff_dcb NUMBER;
  v_interpolation_method VARCHAR2(20);
  v_temp_rate NUMBER; --needed for conv. to disc.rate at the end


BEGIN
  --call the debug package
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('XTR_MARKET_DATA_P.GET_MD_FROM_CURVE');
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'p_curve_code',p_in_rec.p_curve_code);
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'p_source',p_in_rec.p_source);
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'p_indicator',p_in_rec.p_indicator);
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'p_spot_date',p_in_rec.p_spot_date);
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'p_future_date',p_in_rec.p_future_date);
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'p_interpolation_method',p_in_rec.p_interpolation_method);
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'p_day_count_basis_out',p_in_rec.p_day_count_basis_out);
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'p_side',p_in_rec.p_side);
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'p_batch_id',p_in_rec.p_batch_id);
  END IF;

  --check whether spot date and future date are valid
  IF (p_in_rec.p_future_date < p_in_rec.p_spot_date) THEN
    IF xtr_risk_debug_pkg.g_Debug THEN
       xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'p_future_date cannot be earlier than p_spot_date.');
       xtr_risk_debug_pkg.dpop('XTR_MARKET_DATA_P.GET_MD_FROM_CURVE');
    END IF;
    RAISE_APPLICATION_ERROR
      (-20001,'p_future_date cannot be earlier than p_spot_date.');
  END IF;

  --transfer day count basis out to v_day_count_basis_out
  IF (p_in_rec.p_day_count_basis_out IS NULL) THEN
    v_day_count_basis_out := 'ACTUAL/ACTUAL';
  ELSE
    v_day_count_basis_out := p_in_rec.p_day_count_basis_out;
  END IF;

  --find annual basis and day count based on the future and spot date
  xtr_calc_p.calc_days_run_c(p_in_rec.p_spot_date, p_in_rec.p_future_date,
    			     'ACTUAL/ACTUAL', null, v_xval,
				v_annual_basis_out);

  --find interpolation method, using the rule specified in MD API doc.
  IF (UPPER(p_in_rec.p_interpolation_method) IN ('D','DEFAULT')) THEN
    OPEN get_curve_interp_method;
    FETCH get_curve_interp_method INTO v_interpolation_method;
    CLOSE get_curve_interp_method;
  ELSE
    v_interpolation_method := p_in_rec.p_interpolation_method;
  END IF;

  --get the data side from the cursor using the logic describes in the MD API
  --doc
  OPEN get_curve_side;
  FETCH get_curve_side into v_side;
  CLOSE get_curve_side;

  v_count := 0;
  --if source from historical tables
  IF (UPPER(p_in_rec.p_source) = 'C') THEN
    --check whether the day count basis is uniform for CS Intp
    --this check does not apply if rate is volatility
    IF (v_interpolation_method IN ('C','c','CUBIC') and
	p_in_rec.p_indicator NOT IN ('V','v')) THEN
      OPEN compare_dcb;
      FETCH compare_dcb INTO v_diff_dcb;
      CLOSE compare_dcb;
      IF (v_diff_dcb > 0) THEN
        v_uniform_day_count_basis := FALSE;
        --if MD dcb is not uniform CS Intp will done on ACT/ACT dcb
      END IF;
    END IF;
    --loop to get all the rates from the curve
    FOR temprec IN get_rate_value LOOP
      v_count := v_count+1;
      --first get the X element
      v_X.EXTEND;
      --convert all period_code to the same day count basis: ACTUAL/ACTUAL
      --first, find future date
      IF (temprec.term_type IN ('M','V')) THEN
	--adding months without forcing End of Months
	v_future_date := least ((add_months(p_in_rec.p_spot_date-3,
				temprec.period_code/30)+3),
				last_day(add_months(p_in_rec.p_spot_date,
				temprec.period_code/30)));
      ELSIF (temprec.term_type IN ('Y')) THEN
	v_future_date := least ((add_months(p_in_rec.p_spot_date-3,
				temprec.period_code/30)+3),
				last_day(add_months(p_in_rec.p_spot_date,
				temprec.period_code/30)));
      ELSE
	v_future_date := p_in_rec.p_spot_date + temprec.period_code;
      END IF;
      --Need to adjust the grid with ISDA Mod. Following Bus.Day Convention
      --for Yield Curve and Volatility

      xtr_fps3_p.chk_holiday(v_future_date,
			temprec.currency, v_err_code, v_level);
      --check if v_future_date falls on holiday, if so call
      --following_holiday
      IF (v_err_code IS NOT NULL) THEN
        v_hol_in_rec.p_future_date := v_future_date;
        v_hol_in_rec.p_currency := temprec.currency;
        v_hol_in_rec.p_term_type := temprec.term_type;
        following_holiday(v_hol_in_rec, v_hol_out_rec);
        v_future_date := v_hol_out_rec.p_date_out;
      END IF;

      --from future date get the day_count and annual basis in ACTUAL/ACTUAL
      v_N.EXTEND;

      xtr_calc_p.calc_days_run_c(p_in_rec.p_spot_date, v_future_date,
    			     	'ACTUAL/ACTUAL', null, v_X(v_count),
				v_N(v_count));

      --second, get the Y element of the curve
      v_Y.EXTEND;
      --Also for yield curve, need to convert the rate to ACT/ACT
      --for volatility
      IF temprec.term_type NOT IN ('M','Y','D') THEN
        v_Y(v_count) := temprec.rate;
      --for MD rates with uniform dcb (also Lin and Exp)
      ELSIF (v_uniform_day_count_basis) THEN
        v_Y(v_count) := temprec.rate;
	--need to remember the day count basis lo and hi for later
        v_dcb.EXTEND;
 	v_dcb(v_count) := temprec.day_count_basis;
      --for CS and Exp Intp rate
      ELSE
 	--save day count basis to be needed later for conversion or when
	-- CS fails and need Lin Intp;
        --also necessary for Exp when they only have 1 data
        v_dcb.EXTEND;
 	v_dcb(v_count) := temprec.day_count_basis;
        v_YO.EXTEND;
        v_YO(v_count) := temprec.rate;
	--Since not uniform all rates must be converted to dcb_out for CS intp
---
	--first step is to find day count and ann basis based on dcb in
	IF (temprec.day_count_basis <> 'ACTUAL/ACTUAL') THEN
          xtr_calc_p.calc_days_run_c(p_in_rec.p_spot_date,
			v_future_date,
			temprec.day_count_basis, null, v_day_count_i,
			v_annual_basis_i);
	ELSE
	  v_day_count_i := v_X(v_count);
	  v_annual_basis_i := v_N(v_count);
	END IF;
        --find day count and ann basis of based on the dcb_out
	IF (v_day_count_basis_out <> 'ACTUAL/ACTUAL') THEN
          xtr_calc_p.calc_days_run_c(p_in_rec.p_spot_date,
			v_future_date,
			v_day_count_basis_out, null, v_day_count,
			v_annual_basis);
	ELSE
	  v_day_count := v_X(v_count);
	  v_annual_basis := v_N(v_count);
	END IF;
        --convert the v_YO (original) rate
        xtr_rate_conversion.day_count_basis_conv(v_day_count_i,v_day_count,
					v_annual_basis_i,
					v_annual_basis,v_YO(v_count),
					v_Y(v_count));
---

      END IF;
/*
      --print fetched results for debugging
      IF xtr_risk_debug_pkg.g_Debug THEN
         xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'C->v_future_date', v_future_date);
         xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'C->v_count',v_count);
         xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'C->v_X',v_X(v_count));
         xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'C->v_Y',v_Y(v_count));
         xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'C->term_type',temprec.term_type);
         xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'C->rate_code',temprec.unique_period_id);
      END IF;
      IF (p_in_rec.p_indicator NOT IN ('V','v')) THEN
        IF xtr_risk_debug_pkg.g_Debug THEN
           xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'C->v_YO',v_YO(v_count));
           xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'C->day_count_basis',v_dcb(v_count));
        END IF;
      END IF;
*/
      --check if the rate that we're looking for is available without int.
      IF (v_xval = v_X(v_count)) THEN
        --if CS get the original rate from the v_YO array
        IF (v_uniform_day_count_basis) THEN
          v_dummy := v_Y(v_count);
        ELSE
          --this is for the case of CS Intp with ununiform dcb
          v_dummy := v_YO(v_count);
        END IF;
	v_found := TRUE;
	--for non volatility rate we need day count basis info
        IF (p_in_rec.p_indicator NOT IN ('V','v')) THEN
          v_day_count_basis_in := temprec.day_count_basis;
        END IF;
	EXIT;
      END IF;
      --for Exp. and Lin.: check if the the interpolated point is already
      --in the interval
      IF (v_X(v_count) > v_xval) and
      (v_interpolation_method NOT IN ('C','c','CUBIC')) THEN
        v_hi := v_count;
        EXIT;
      END IF;
    END LOOP;

  --if the source table is revaluation rates table
  ELSIF (UPPER(p_in_rec.p_source) = 'R') THEN
    --for CS intp check whether MD are uniform
    IF (v_interpolation_method IN ('C','c','CUBIC') and
	p_in_rec.p_indicator NOT IN ('V','v')) THEN
      OPEN compare_dcb_reval;
      FETCH compare_dcb_reval INTO v_diff_dcb;
      CLOSE compare_dcb_reval;
      IF (v_diff_dcb > 0) THEN
        v_uniform_day_count_basis := FALSE;
        --if MD dcb is not uniform CS Intp will done on ACT/ACT dcb
      END IF;
    END IF;
    --loop to get all the rates from the curve
    FOR temprec IN get_rate_value_reval LOOP
      v_count := v_count+1;
      --first get the X element of the curve
      v_X.EXTEND;
      IF (temprec.term_type IN ('MONTH','MONTHS')) THEN
	--adding months without forcing End of Months
	v_future_date := least ((add_months(p_in_rec.p_spot_date-3,
				temprec.period_code/30)+3),
				last_day(add_months(p_in_rec.p_spot_date,
				temprec.period_code/30)));
      ELSIF (temprec.term_type IN ('YEAR','YEARS')) THEN
	v_future_date := least ((add_months(p_in_rec.p_spot_date-3,
				temprec.period_code/30)+3),
				last_day(add_months(p_in_rec.p_spot_date,
				temprec.period_code/30)));
      ELSE
	v_future_date := p_in_rec.p_spot_date + temprec.period_code;
      END IF;
      --Need to adjust the grid with ISDA Mod. Following Bus.Day Convention
      --for Yield Curve and Volatility

      xtr_fps3_p.chk_holiday(v_future_date,
			temprec.currency, v_err_code, v_level);
      --check if v_future_date falls on holiday, if so call
      --following_holiday
      IF (v_err_code IS NOT NULL) THEN
        v_hol_in_rec.p_future_date := v_future_date;
        v_hol_in_rec.p_currency := temprec.currency;
        v_hol_in_rec.p_term_type := temprec.term_type;
    	v_hol_in_rec.p_period_code := temprec.period_code;
        following_holiday(v_hol_in_rec, v_hol_out_rec);
        v_future_date := v_hol_out_rec.p_date_out;
      END IF;

      --from future date get the day_count and annual basis in ACTUAL/ACTUAL
      v_N.EXTEND;

      xtr_calc_p.calc_days_run_c(p_in_rec.p_spot_date, v_future_date,
    			     	'ACTUAL/ACTUAL', null, v_X(v_count),
				v_N(v_count));

      --second, get the Y element of the curve
      v_Y.EXTEND;
        --Also for yield curve, need to convert the rate to ACT/ACT
      --for non-yield rate i.e. volatility
      IF (temprec.rate_type <> 'RATE') THEN
        v_Y(v_count) := temprec.rate;
      --for MD rates with uniform dcb (also Lin and Exp)
      ELSIF (v_uniform_day_count_basis) THEN
        v_Y(v_count) := temprec.rate;
	--need to remember the day count basis lo and hi for later
        v_dcb.EXTEND;
 	v_dcb(v_count) := temprec.day_count_basis;
      --for CS and Exp Intp rate
      ELSE
 	--save day count basis to be needed later for conversion or when
	-- CS fails and need Lin Intp;
        --also necessary for Exp when they only have 1 data
        v_dcb.EXTEND;
 	v_dcb(v_count) := temprec.day_count_basis;
        v_YO.EXTEND;
        v_YO(v_count) := temprec.rate;
	--Since not uniform all rates must be converted to ACT/ACT for CS intp
---
	--first step is to find day count and ann basis based on dcb in
	IF (temprec.day_count_basis <> 'ACTUAL/ACTUAL') THEN
          xtr_calc_p.calc_days_run_c(p_in_rec.p_spot_date,
			v_future_date,
			temprec.day_count_basis, null, v_day_count_i,
			v_annual_basis_i);
	ELSE
	  v_day_count_i := v_X(v_count);
	  v_annual_basis_i := v_N(v_count);
	END IF;
        --find day count and ann basis of based on the dcb_out
	IF (v_day_count_basis_out <> 'ACTUAL/ACTUAL') THEN
          xtr_calc_p.calc_days_run_c(p_in_rec.p_spot_date,
			v_future_date,
			v_day_count_basis_out, null, v_day_count,
			v_annual_basis);
	ELSE
	  v_day_count := v_X(v_count);
	  v_annual_basis := v_N(v_count);
	END IF;
        --convert the v_YO (original) rate
        xtr_rate_conversion.day_count_basis_conv(v_day_count_i,v_day_count,
					v_annual_basis_i,
					v_annual_basis,v_YO(v_count),
					v_Y(v_count));
---

      END IF;
/*
      --print result for debugging
      --print fetched results for debugging
      IF xtr_risk_debug_pkg.g_Debug THEN
         xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'R->v_future_date', v_future_date);
         xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'R->v_count',v_count);
         xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'R->v_X',v_X(v_count));
         xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'R->v_Y',v_Y(v_count));
         xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'R->term_type',temprec.term_type);
         xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'R->rate_code',temprec.unique_period_id);
      END IF;
      IF (p_in_rec.p_indicator NOT IN ('V','v')) THEN
--        xtr_risk_debug_pkg.dlog('R->v_YO',v_YO(v_count));
        IF xtr_risk_debug_pkg.g_Debug THEN
           xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'R->day_count_basis',v_dcb(v_count));
        END IF;
      END IF;
*/
      --check if the rate that we're looking for is available without int.
      IF (v_xval = v_X(v_count)) THEN
        --if CS get the original rate from the v_YO array
        IF (v_uniform_day_count_basis) THEN
          v_dummy := v_Y(v_count);
        ELSE
          --this is for the case of CS Intp with ununiform dcb
          v_dummy := v_YO(v_count);
        END IF;
	v_found := TRUE;
	--for non volatility rate we need day count basis info
        IF (p_in_rec.p_indicator NOT IN ('V','v')) THEN
          v_day_count_basis_in := temprec.day_count_basis;
	END IF;
	EXIT;
      END IF;
      --for Exp. and Lin.: check if the the interpolated point is already
      --in the interval
      IF (v_X(v_count) > v_xval) and
      (v_interpolation_method NOT IN ('C','c','CUBIC')) THEN
        v_hi := v_count;
        EXIT;
      END IF;
    END LOOP;

  ELSE
    IF xtr_risk_debug_pkg.g_Debug THEN
       xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'The p_source values can only be ''C'' or ''R''.');
       xtr_risk_debug_pkg.dpop('XTR_MARKET_DATA_P.GET_MD_FROM_CURVE');
    END IF;
    RAISE_APPLICATION_ERROR
        (-20001,'The p_source values can only be ''C'' or ''R''.');
  END IF;

  --if no data retrieved from the table raise exception
  IF (v_count = 0 and NOT v_found) THEN
    IF xtr_risk_debug_pkg.g_Debug THEN
       xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'v_count = 0 and v_found = false');
       xtr_risk_debug_pkg.dpop('XTR_MARKET_DATA_P.GET_MD_FROM_CURVE');
    END IF;
    RAISE e_mdcs_no_data_found;
  END IF;
  --if v_xval is outside the range, only linear int. is needed
  --and it's agreed that the extension slopes after both ends are 0
  --this is also applied if there is only 1 point in a curve
  IF (v_xval < v_X(1) or (v_count = 1 and NOT v_found)) THEN
    IF (v_uniform_day_count_basis) THEN
      v_dummy := v_Y(1);
    ELSE
      v_dummy := v_YO(1);
    END IF;
    v_found := TRUE;
    --v_day_count_basis for v_Y is ACT/ACT in the case of CS and Expon Intp
    --for volatility no day count basis notion
    IF (p_in_rec.p_indicator NOT IN ('V','v')) THEN
      v_day_count_basis_in := v_dcb(1);
    END IF;
  ELSIF (v_xval > v_X(v_count)) THEN
    IF (v_uniform_day_count_basis) THEN
      v_dummy := v_Y(v_count);
    ELSE
      v_dummy := v_YO(v_count);
    END IF;
    v_found := TRUE;
    --v_day_count_basis for v_Y is ACT/ACT in the case of CS and Expon Intp
    IF (p_in_rec.p_indicator NOT IN ('V','v')) THEN
      v_day_count_basis_in := v_dcb(v_count);
    END IF;
  END IF;

  --do cubic spline if interpolation method is 'C' and
  --at least there are 3 points in a curve
  IF (NOT v_found and
	v_interpolation_method IN ('C','CUBIC','c') and
	v_count >= 3) THEN
    --Either do CS Intp on v_day_count_basis_in or dcb out depending on
    --v_uniform_day_count_basis
    --however, no day count basis notion in volatility
    IF (p_in_rec.p_indicator NOT IN ('V','v')) THEN
      IF (v_uniform_day_count_basis) THEN
        v_day_count_basis_in := v_dcb(1);
      ELSE
        v_day_count_basis_in := v_day_count_basis_out;
      END IF;
    END IF;
    v_temp := cubic_spline_interpolation(v_X,v_Y,v_X.COUNT,v_xval,1,1,0,0);
    IF (SUBSTR(v_temp,1,1) = 'E') THEN
      --if an error occurred gives negative value so that linear int.
      --will be used
      v_dummy := -1;
    ELSE
      v_dummy := fnd_number.canonical_to_number(v_temp);  -- for bug 6408487
    END IF;
    IF (v_dummy >= 0) THEN
      v_found := TRUE;
    END IF;
  END IF;

  --result is still not found until this point use either Exponential or Linear
  IF (NOT v_found) THEN
    -- for CS Intp where rate is till not found we have to do binary search
    -- to get the interval and default to Linear Intp
    IF (v_interpolation_method IN ('C','c','CUBIC') and
	NOT v_found) THEN
      --do Binary Search
      v_lo := 1;
      v_hi := v_count;
      v_stop := FALSE;
      WHILE ((v_hi-v_lo > 1) and NOT v_stop) LOOP
        v_mid := (v_hi+v_lo)/2;
        IF (v_X(v_mid) = v_xval) THEN
          IF (v_uniform_day_count_basis) THEN
            v_dummy := v_Y(v_mid);
          ELSE
            v_dummy := v_YO(v_mid);
          END IF;
	  --in volatility day count basis is not used
          IF (p_in_rec.p_indicator NOT IN ('V','v')) THEN
            v_day_count_basis_in := v_dcb(v_mid);
	  END IF;
          v_stop := TRUE;
        ELSE
          IF (v_X(v_mid) > v_xval) THEN
            v_hi := v_mid;
          ELSE
            v_lo := v_mid;
          END IF;
        END IF;
      END LOOP;
    ELSE
      v_lo := v_hi-1;
    END IF;

    --if any of the day count (v_X) is 0 Exponential Int. will fail
    --thus, default to Linear Int.
    --volatility cannot be interpolated with the current Exp. Int. formula.
    IF(v_interpolation_method IN ('E','EXPON','e')
	and p_in_rec.p_indicator NOT IN ('V','v') and
	NOT (v_X(v_lo)=0 or v_X(v_hi)=0)) THEN
      --save the day count basis Exp Intp always uses ACT/ACT
      v_day_count_basis_in := 'ACTUAL/ACTUAL';
      --do day count basis conversion to ACTUAL/ACTUAL
      --first, dcb conv for v_lo
      IF (v_dcb(v_lo)<>'ACTUAL/ACTUAL') THEN
        --convert the v_lo
        --find day count and ann basis of v_lo based on the dcb_out
        --convert the v_lo rate
	v_Ylo := v_Y(v_lo);
 	md_rate_conversion(p_in_rec.p_spot_date,p_in_rec.p_spot_date+v_X(v_lo),
				v_X(v_lo), v_N(v_lo),
				v_dcb(v_lo), v_Ylo,
				v_Y(v_lo));
      END IF;
      --dcb conv for v_hi
      IF (v_dcb(v_hi)<>'ACTUAL/ACTUAL') THEN
        --convert the v_hi
        --find day count and ann basis of v_hi based on the dcb_out
        --convert the v_hi rate
	v_Yhi := v_Y(v_hi);
 	md_rate_conversion(p_in_rec.p_spot_date,p_in_rec.p_spot_date+v_X(v_hi),
				v_X(v_hi), v_N(v_hi),
				v_dcb(v_hi), v_Yhi,
				v_Y(v_hi));
      END IF;
      --do exponential int
      --first convert the two interval points to discount factors
      v_in_rec.p_indicator := 'T';
      v_in_rec.p_day_count := v_X(v_lo);
      v_in_rec.p_annual_basis := v_N(v_lo);
      v_in_rec.p_rate := v_Y(v_lo);
      xtr_rate_conversion.discount_factor_conv(v_in_rec,v_out_rec);
      v_Y(v_lo) := v_out_rec.p_result;
      v_in_rec.p_day_count := v_X(v_hi);
      v_in_rec.p_annual_basis := v_N(v_hi);
      v_in_rec.p_rate := v_Y(v_hi);
      xtr_rate_conversion.discount_factor_conv(v_in_rec,v_out_rec);
      v_Y(v_hi) := v_out_rec.p_result;
      df_exponential_interpolation('I',v_xval,v_X(v_lo),v_X(v_hi),v_Y(v_lo),
				v_Y(v_hi), v_dummy);

      --in case the final answer is not Discount Factor or in a case that
      --we need to convert day count basis
      --(day_count_basis_out <> v_day_count_basis_in),
      --we need to convert from discount factor back to yield rate
      IF (NOT (p_in_rec.p_indicator = 'D' and
	v_day_count_basis_out = 'ACTUAL/ACTUAL')) THEN
        --convert back to yield rate
        v_in_rec.p_indicator := 'F';
        v_in_rec.p_day_count := v_xval;
        v_in_rec.p_rate := v_dummy;
        xtr_rate_conversion.discount_factor_conv(v_in_rec,v_out_rec);
        v_dummy := v_out_rec.p_result;
      ELSE
        v_final := TRUE; --got the final answer, to be used later
      END IF;
    ELSE
      --do linear int
      --skip day count basis realted conversion for volatility
      IF (p_in_rec.p_indicator NOT IN ('V','v')) THEN
        --if data1 dcb = data2 dcb use that dcb
        --else if data1 dcv <> data dcv use day count basis out
        IF (v_dcb(v_lo) = v_dcb(v_hi)) THEN
     	  v_day_count_basis_in := v_dcb(v_lo);
        ELSE --do conversion to day count basis out
      	  v_day_count_basis_in := v_day_count_basis_out;

          --convert the v_lo to v_day_count_basis_out if not already
          IF (v_dcb(v_lo) <> v_day_count_basis_out) THEN
            --find day count and ann basis of v_hi based on the dcb_in
	    IF (v_dcb(v_lo) <> 'ACTUAL/ACTUAL') THEN
              xtr_calc_p.calc_days_run_c(p_in_rec.p_spot_date,
			p_in_rec.p_spot_date + v_X(v_lo),
			v_dcb(v_lo), null, v_day_count_i,
			v_annual_basis_i);
	    ELSE
	      v_day_count_i := v_X(v_lo);
	      v_annual_basis_i := v_N(v_lo);
	    END IF;
            --find day count and ann basis of v_hi based on the dcb_out
	    IF (v_day_count_basis_out <> 'ACTUAL/ACTUAL') THEN
              xtr_calc_p.calc_days_run_c(p_in_rec.p_spot_date,
			p_in_rec.p_spot_date + v_X(v_lo),
			v_day_count_basis_out, null, v_day_count,
			v_annual_basis);
	    ELSE
	      v_day_count := v_X(v_lo);
	      v_annual_basis := v_N(v_lo);
	    END IF;
            --convert the v_lo rate
	    --v_uniform_day_count_basis is FALSE only in the case of CS intp
            --with nonuniform MD rates
            IF v_uniform_day_count_basis THEN
              v_Ylo := v_Y(v_lo);
	    ELSE
              v_Ylo := v_YO(v_lo);
	    END IF;
            xtr_rate_conversion.day_count_basis_conv(v_day_count_i,v_day_count,
					v_annual_basis_i,
					v_annual_basis,v_Ylo,
					v_Y(v_lo));
          END IF;
          --convert the v_hi to v_day_count_basis_out if not already
          IF (v_dcb(v_hi) <> v_day_count_basis_out) THEN
            --find day count and ann basis of v_hi based on the dcb_in
	    IF (v_dcb(v_hi) <> 'ACTUAL/ACTUAL') THEN
              xtr_calc_p.calc_days_run_c(p_in_rec.p_spot_date,
			p_in_rec.p_spot_date + v_X(v_hi),
			v_dcb(v_hi), null, v_day_count_i,
			v_annual_basis_i);
	    ELSE
	      v_day_count_i := v_X(v_hi);
	      v_annual_basis_i := v_N(v_hi);
	    END IF;
            --find day count and ann basis of v_hi based on the dcb_out
	    IF (v_day_count_basis_out <> 'ACTUAL/ACTUAL') THEN
              xtr_calc_p.calc_days_run_c(p_in_rec.p_spot_date,
		 	p_in_rec.p_spot_date + v_X(v_hi),
			v_day_count_basis_out, null, v_day_count,
			v_annual_basis);
	    ELSE
	      v_day_count := v_X(v_hi);
	      v_annual_basis := v_N(v_hi);
	    END IF;
            --convert the v_hi rate
	    --v_uniform_day_count_basis is FALSE onlyin the case of CS intp
	    --with nonuniform MD rates
            IF v_uniform_day_count_basis THEN
              v_Yhi := v_Y(v_hi);
	    ELSE
              v_Yhi := v_YO(v_hi);
	    END IF;
            xtr_rate_conversion.day_count_basis_conv(v_day_count_i,v_day_count,
					v_annual_basis_i,
					v_annual_basis, v_Yhi,
					v_Y(v_hi));
	  END IF;
        END IF;
      END IF;
      linear_interpolation(v_xval,v_X(v_lo),v_X(v_hi),v_Y(v_lo),v_Y(v_hi),
				null, v_dummy);
    END IF;
  END IF;
IF xtr_risk_debug_pkg.g_Debug THEN
   xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'v_uniform_day_count_basis', v_uniform_day_count_basis);
   xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'v_dummy before DCB Conv', v_dummy);
END IF;
  --for volatility we don't need to worry about DCB and DF conversion
  IF (p_in_rec.p_indicator NOT IN ('V','v')) THEN
    --Need to convert the rate to p_day_count_basis_out if not the same as
    --v_day_count_basis_out
    IF (v_day_count_basis_out <> v_day_count_basis_in) THEN
      IF (v_day_count_basis_in <> 'ACTUAL/ACTUAL') THEN
        --need to find the v_day_count_i and v_annual_basis_i based on the
        --dcb_out
        xtr_calc_p.calc_days_run_c(p_in_rec.p_spot_date,p_in_rec.p_future_date,
			v_day_count_basis_in, null, v_day_count_i,
			v_annual_basis_i);
      ELSE
        v_day_count_i := v_xval;
        v_annual_basis_i := v_annual_basis_out;
      END IF;
      IF (v_day_count_basis_out <> 'ACTUAL/ACTUAL') THEN
      xtr_calc_p.calc_days_run_c(p_in_rec.p_spot_date, p_in_rec.p_future_date,
			v_day_count_basis_out, null, v_day_count,
			v_annual_basis);
      ELSE
        v_day_count := v_xval;
        v_annual_basis := v_annual_basis_out;
      END IF;
      xtr_rate_conversion.day_count_basis_conv(v_day_count_i, v_day_count,
					v_annual_basis_i,
					v_annual_basis,v_dummy,
					p_out_rec.p_md_out);
      v_dummy := p_out_rec.p_md_out;
    ELSE
      IF (v_day_count_basis_out = 'ACTUAL/ACTUAL') THEN
        v_annual_basis := v_annual_basis_out;
        v_day_count := v_xval;
      ELSE
        xtr_calc_p.calc_days_run_c(p_in_rec.p_spot_date,p_in_rec.p_future_date,
			v_day_count_basis_out, null, v_day_count,
			v_annual_basis);
      END IF;
    END IF;

    --if looking for DF then convert to DF except if it's already in DF form
    --which is the special case for if interpolation_method = 'E' and does not
    --require day count basis translation (above)
    IF ((p_in_rec.p_indicator = 'D') and
	NOT (v_interpolation_method IN ('E','EXPON','e') and v_final))
    THEN
      v_in_rec.p_indicator := 'T';
      v_in_rec.p_day_count := v_day_count;
      v_in_rec.p_annual_basis := v_annual_basis;
      v_in_rec.p_rate := v_dummy;
      xtr_rate_conversion.discount_factor_conv(v_in_rec, v_out_rec);
      v_dummy := v_out_rec.p_result;
    --convert to discount rate if p_indicator = 'DR'
    ELSIF (UPPER(p_in_rec.p_indicator) = 'DR') THEN
      v_temp_rate := v_dummy;
      xtr_rate_conversion.yield_to_discount_rate(v_temp_rate,
			v_day_count, v_annual_basis, v_dummy);
    END IF;
  END IF;

  p_out_rec.p_md_out := v_dummy;

  --close debug and print the result
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_CURVE: ' || 'p_out_rec.p_md_out', p_out_rec.p_md_out);
     xtr_risk_debug_pkg.dpop('XTR_MARKET_DATA_P.GET_MD_FROM_CURVE');
  END IF;

END GET_MD_FROM_CURVE;



/*------------------------------------------------------------------------
GET_MD_FROM_SET
Returns a yield rate, discount factor, volatility,
FX spot rate, and bond price of a given market data set.

Record Type:
MD_FROM_SET_IN_REC_TYPE
MD_FROM_SET_OUT_REC_TYPE

For required parameters for each rate type look at MD API
Design Doc.

Assumptions:
To distinguish between IR (interest rate) and FX
(exchange rate) volatility:
If p_indicator = 'V'
  If p_contra_ccy is null then
    Assumed to look for IR volatility
  Else
    Assumed to for FX volatility

The ordering priority of the data side (bid, ask, mid):
1.  Look at DATA_SIDE from XTR_RM_MD_SET_CURVES
2.  Case 1: If DATA_SIDE from XTR_RM_MD_SET_CURVES =
  'DEFAULT' then look at DATA_SIDE from  XTR_RM_MD_CURVES
    Case 2 : If the DATA_SIDE from  XTR_RM_MD_SET_CURVES =
  'BID/ASK' then  look at p_side (passed parameter)
3.  If in Case 1 the DATA_SIDE from XTR_RM_MD_CURVES =
  'BID/ASK' then look at p_side (passed parameter).

p_ccy = currency.
p_contra_ccy = contra currency.  It is only required for
  volatility and FX spot rate.
p_md_set_code = name of market data set from which to
  extract data.
p_source = table source for calculation.  'C' for Current
  System Rates table and 'R' for revaluation table.
p_indicator = data type of output.  'R' for yield rate,
  'D' for discount factor, 'V' for volatility.
p_spot_date = reference date.
p_future_date = future date.
p_day_count_basis_out = day count basis to use for output.
  Can set to null and disregard if p_curve_code is
  volatility curve.
p_interpolation_method = interpolation method to be used
  for curve. 'L'/'LINEAR' for linear, 'E'/'EXPON' for
  exponential, 'C'/'CUBIC' for cubic spline, or
  'D'/'DEFAULT' for the default value specified in the curve,
  otherwise it will be assumed to be 'L'.
p_side = data side of market to return. 'B'/'BID' for bid,
  'A'/'ASK' for ask, or 'M'/'MID' for mid.
  No BID/ASK allowed.
p_batch_id = batch of revaluation table to be used. Can
  set to null and disregard if p_source <> 'R'.
p_bond_code = bond reference code.  It is only required for
  bond price. Set to null and disregard if p_indicator <> 'B'.
p_md_out = output that is yield rate, discount factor, or
  volatility.
--------------------------------------------------------------------------*/
PROCEDURE GET_MD_FROM_SET (p_in_rec  IN  md_from_set_in_rec_type,
			   p_out_rec OUT NOCOPY md_from_set_out_rec_type,
                       p_first_call IN NUMBER) is

  CURSOR get_fx_spot_rates IS
     SELECT usd_base_curr_bid_rate bid_rate,
	usd_base_curr_offer_rate ask_rate,
	1/usd_base_curr_offer_rate bid_rate_base,
	1/usd_base_curr_bid_rate ask_rate_base,
	currency
  	FROM xtr_spot_rates
	WHERE (rate_date, currency) IN (SELECT MAX(rate_date), currency
		FROM xtr_spot_rates
		WHERE currency IN (p_in_rec.p_ccy, p_in_rec.p_contra_ccy)
		AND currency <> 'USD'
		AND trunc(rate_date) <= trunc(p_in_rec.p_spot_date)
		GROUP BY currency);

  --The cursor get spot rate in Commodity unit quote (USD based): bid/ask_rate
  --and Base unit quote: bid/ask_rate_base
  CURSOR get_fx_spot_rates_reval IS
     SELECT DECODE(currencyA, 'USD', nvl(bid_overwrite,bid),
				1/nvl(ask_overwrite,ask)) bid_rate,
            DECODE(currencyA, 'USD', nvl(ask_overwrite,ask),
			 	1/nvl(bid_overwrite,bid)) ask_rate,
	    DECODE(currencyA, 'USD', 1/nvl(ask_overwrite,ask),
				nvl(bid_overwrite,bid)) bid_rate_base,
            DECODE(currencyA, 'USD', 1/nvl(bid_overwrite,bid),
			 	nvl(ask_overwrite,ask)) ask_rate_base,
	    DECODE(currencyA, 'USD', currencyB, currencyA) currency
	    --gives non-USD currency
     FROM xtr_revaluation_rates
     WHERE ((currencyA = 'USD' and currencyB
		IN (p_in_rec.p_ccy,p_in_rec.p_contra_ccy))
	or (currencyB = 'USD' and currencyA
		IN (p_in_rec.p_ccy,p_in_rec.p_contra_ccy)))
     AND volatility_or_rate = 'RATE'
     AND day_mth is NULL
     AND batch_id = p_in_rec.p_batch_id;

  --get curve info for non FXV
  --do the functional logic to determine the side, BID-ASK, as explained
  --in MD API doc.
  CURSOR get_curve_code IS
    SELECT c.curve_code, DECODE(sc.data_side, 'DEFAULT', p_in_rec.p_side, 'BID/ASK', p_in_rec.p_side, sc.data_side) side,
      DECODE(sc.interpolation, 'DEFAULT', c.default_interpolation,
					sc.interpolation) interpolation
      FROM xtr_rm_md_set_curves sc, xtr_rm_md_curves c
      WHERE sc.set_code = p_in_rec.p_md_set_code
      AND c.type = DECODE(p_in_rec.p_indicator,'V','IRVOL', 'YIELD')
      AND c.ccy = p_in_rec.p_ccy
      AND sc.curve_code = c.curve_code;

  --get curve info for FXV
  --do the functional logic to determine the side, BID-ASK, as explained
  --in MD API doc.
  CURSOR get_curve_code_v IS
    SELECT c.curve_code, DECODE(sc.data_side, 'DEFAULT', p_in_rec.p_side, 'BID/ASK', p_in_rec.p_side, sc.data_side) side,
      DECODE(sc.interpolation, 'DEFAULT', c.default_interpolation,
					sc.interpolation) interpolation
      FROM xtr_rm_md_set_curves sc, xtr_rm_md_curves c
      WHERE sc.set_code = p_in_rec.p_md_set_code
      AND c.type = 'FXVOL'
      AND ((c.ccy = p_in_rec.p_ccy AND c.contra_ccy = p_in_rec.p_contra_ccy)
	OR (c.ccy = p_in_rec.p_contra_ccy AND c.contra_ccy = p_in_rec.p_ccy))
      AND sc.curve_code = c.curve_code;

  TYPE rec_type IS RECORD (bid_rate NUMBER, ask_rate NUMBER,
			   bid_rate_base NUMBER, ask_rate_base NUMBER,
			   currency VARCHAR2(15));

  v_in_rec  md_from_curve_in_rec_type;
  v_out_rec md_from_curve_out_rec_type;
  v_count NUMBER;
  v_ccy NUMBER;
  v_contra_ccy NUMBER;
  v_int VARCHAR2(20);
  temprec rec_type;

BEGIN
  --start debug and print some initial variable values
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('XTR_MARKET_DATA_P.GET_MD_FROM_SET');
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_SET: ' || 'p_md_set_code',p_in_rec.p_md_set_code);
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_SET: ' || 'p_source',p_in_rec.p_source);
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_SET: ' || 'p_indicator',p_in_rec.p_indicator);
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_SET: ' || 'p_spot_date',p_in_rec.p_spot_date);
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_SET: ' || 'p_future_date',p_in_rec.p_future_date);
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_SET: ' || 'p_ccy',p_in_rec.p_ccy);
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_SET: ' || 'p_contra_ccy',p_in_rec.p_contra_ccy);
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_SET: ' || 'p_day_count_basis_out',p_in_rec.p_day_count_basis_out);
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_SET: ' || 'p_interpolation_method',p_in_rec.p_interpolation_method);
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_SET: ' || 'p_side',p_in_rec.p_side);
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_SET: ' || 'p_batch_id',p_in_rec.p_batch_id);
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_SET: ' || 'p_bond_code',p_in_rec.p_bond_code);
  END IF;

  --Fork the process based on the type of rate
  IF (UPPER(p_in_rec.p_indicator) IN ('D','R','DR','Y') or
     (UPPER(p_in_rec.p_indicator) IN ('V') and
	p_in_rec.p_contra_ccy IS NULL)) THEN
  --for discount factor, ir volatility,  and yield rate

    --fetch curve code and call get_md_from_curve
    --fetching necessary info from curve and set
    OPEN get_curve_code;
    FETCH get_curve_code into v_in_rec.p_curve_code, v_in_rec.p_side,
			v_in_rec.p_interpolation_method;
    CLOSE get_curve_code;

    --check if at least one curve code is retrieved
    IF (v_in_rec.p_curve_code IS NULL) THEN
      IF xtr_risk_debug_pkg.g_Debug THEN
         xtr_risk_debug_pkg.dlog('GET_MD_FROM_SET: ' || 'For Yield/Disc/IRVol: no curve found');
         xtr_risk_debug_pkg.dpop('XTR_MARKET_DATA_P.GET_MD_FROM_SET');
      END IF;
      RAISE e_mdcs_no_curve_found;
    END IF;

    --check p_side if it's a valid one: cannot be DEFAULT or BID/ASK
    --if the result from set and curve is BID/ASK use the passed in parameter
    IF (v_in_rec.p_side NOT IN ('MID','BID','ASK')) THEN
      v_in_rec.p_side := p_in_rec.p_side;
    END IF;

    --for interpolation method, the API parameter overwrite the one from the
    --table.
    IF (UPPER(p_in_rec.p_interpolation_method) NOT IN('D','DEFAULT')) THEN
      v_in_rec.p_interpolation_method := p_in_rec.p_interpolation_method;
    END IF;
    --if int. method is DEFAULT we took the one from above cursor

    --pass other parameters and call get_market_data_from_curve
    v_in_rec.p_source := p_in_rec.p_source;
    v_in_rec.p_indicator := p_in_rec.p_indicator;
    v_in_rec.p_spot_date := p_in_rec.p_spot_date;
    v_in_rec.p_future_date := p_in_rec.p_future_date;
    v_in_rec.p_day_count_basis_out := p_in_rec.p_day_count_basis_out;
    v_in_rec.p_batch_id := p_in_rec.p_batch_id;

    get_md_from_curve(v_in_rec, v_out_rec);
    p_out_rec.p_md_out := v_out_rec.p_md_out;

  ELSIF (UPPER(p_in_rec.p_indicator) = 'V') THEN
  --for fx volatility

    --fetch curve code and data side for fx volatility
    --fetching necessary info from curve and set
    OPEN get_curve_code_v;
    FETCH get_curve_code_v into v_in_rec.p_curve_code, v_in_rec.p_side,
			v_in_rec.p_interpolation_method;
    CLOSE get_curve_code_v;

    --check if at least one curve code is retrieved
    IF (v_in_rec.p_curve_code IS NULL) THEN
      IF xtr_risk_debug_pkg.g_Debug THEN
         xtr_risk_debug_pkg.dlog('GET_MD_FROM_SET: ' || 'For FXVol: no curve found');
         xtr_risk_debug_pkg.dpop('GET_MD_FROM_SET: ' || 'XTR_MARKET_DATA_P.GET_MD_FROM_CURVE');
      END IF;
      RAISE e_mdcs_no_curve_found;
    END IF;

    --check p_side if it's a valid one: cannot be DEFAULT or BID/ASK
    IF (v_in_rec.p_side NOT IN ('MID','BID','ASK')) THEN
      v_in_rec.p_side := p_in_rec.p_side;
    END IF;

    --for interpolation method, the API parameter overwrite the one from the
    --table.
    IF (UPPER(p_in_rec.p_interpolation_method) NOT IN('D','DEFAULT')) THEN
      v_in_rec.p_interpolation_method := p_in_rec.p_interpolation_method;
    END IF;
    --if int. method is DEFAULT we took the one from above cursor
/*
    IF (v_int <> 'D') THEN
      v_in_rec.p_interpolation_method := v_int;
    END IF;
*/
    --pass parameters and call get_market_data_from_curve
    --pass other parameters and call get_market_data_from_curve
    v_in_rec.p_source := p_in_rec.p_source;
    v_in_rec.p_indicator := p_in_rec.p_indicator;
    v_in_rec.p_spot_date := p_in_rec.p_spot_date;
    v_in_rec.p_future_date := p_in_rec.p_future_date;
    v_in_rec.p_day_count_basis_out := p_in_rec.p_day_count_basis_out;
--    v_in_rec.p_interpolation_method := p_in_rec.p_interpolation_method;
    v_in_rec.p_batch_id := p_in_rec.p_batch_id;
    get_md_from_curve(v_in_rec, v_out_rec);
    p_out_rec.p_md_out := v_out_rec.p_md_out;


  ELSIF (UPPER(p_in_rec.p_indicator) IN ('S')) THEN
  --for FX spot rate
    --check p_side
    SELECT DECODE(fx_spot_side, 'BID/ASK', p_in_rec.p_side, fx_spot_side)
	INTO v_in_rec.p_side
	FROM xtr_rm_md_sets
	WHERE set_code = p_in_rec.p_md_set_code;
    --fetch the spot rate from xtr_spot_rates
    --check if cross rates
    v_count := 0;
    IF (p_in_rec.p_ccy <> 'USD' and p_in_rec.p_contra_ccy <> 'USD') THEN
      IF (p_in_rec.p_source = 'C') THEN
	OPEN get_fx_spot_rates;
      ELSIF (p_in_rec.p_source = 'R') THEN
-- bug 4145664 issue 12
             IF nvl(p_first_call,0) = 1 then
                  open get_fx_spot_rates;
             ELSE
                  OPEN get_fx_spot_rates_reval;
             END IF;
      ELSE
        IF xtr_risk_debug_pkg.g_Debug THEN
           xtr_risk_debug_pkg.dlog('GET_MD_FROM_SET: ' || 'For FX Spot Rates non-USD: The p_source values can only be ''C'' or ''R''.');
           xtr_risk_debug_pkg.dpop('GET_MD_FROM_SET: ' || 'XTR_MARKET_DATA_P.GET_MD_FROM_CURVE');
        END IF;
    	RAISE_APPLICATION_ERROR
          (-20001,'The p_source values can only be ''C'' or ''R''.');
      END IF;
      LOOP
	IF (p_in_rec.p_source = 'C') THEN
	  FETCH get_fx_spot_rates INTO temprec.bid_rate, temprec.ask_rate,
			temprec.bid_rate_base, temprec.ask_rate_base,
			temprec.currency;
	ELSE
-- bug 4145664 issue 12 if the hedgde is revalued for the first time rates to be picked from
-- xtr_spot_rates table
              IF nvl(p_first_call,0) = 1 then
                     FETCH get_fx_spot_rates INTO temprec.bid_rate, temprec.ask_rate,
			temprec.bid_rate_base, temprec.ask_rate_base,
			temprec.currency;
              ELSE
	                FETCH get_fx_spot_rates_reval INTO temprec.bid_rate,
				temprec.ask_rate, temprec.bid_rate_base,
				temprec.ask_rate_base, temprec.currency;
              END IF;
	END IF;

        IF (temprec.currency = p_in_rec.p_ccy) THEN
          IF (v_in_rec.p_side IN ('BID','B')) THEN
	    v_ccy := temprec.ask_rate;
	  ELSIF (v_in_rec.p_side IN ('ASK','A')) THEN
	    v_ccy := temprec.bid_rate;
	  ELSE
	    v_ccy := (temprec.bid_rate+temprec.ask_rate)/2;
	  END IF;
        ELSE
          IF (v_in_rec.p_side IN ('BID','B')) THEN
	    v_contra_ccy := temprec.bid_rate;
	  ELSIF (v_in_rec.p_side IN ('ASK','A')) THEN
	    v_contra_ccy := temprec.ask_rate;
	  ELSE
	    v_contra_ccy := (temprec.bid_rate+temprec.ask_rate)/2;
	  END IF;
        END IF;
        v_count := v_count+1;
        IF (v_count >= 2) THEN EXIT;
	END IF;
      END LOOP;
      IF (p_in_rec.p_source = 'C') THEN
	CLOSE get_fx_spot_rates;
      ELSE
        if get_fx_spot_rates%ISOPEN  then
            CLOSE get_fx_spot_rates;
        end if;
        if get_fx_spot_rates_reval%ISOPEN  then
            CLOSE get_fx_spot_rates_reval;
        end if;
      END IF;
/*
      --check whether there is any spot rate retrieved
      IF (v_count = 0) THEN
	IF xtr_risk_debug_pkg.g_Debug THEN
	   xtr_risk_debug_pkg.dlog('GET_MD_FROM_SET: ' || 'For FX Spot Rates non-USD: no data found');
           xtr_risk_debug_pkg.dpop('XTR_MARKET_DATA_P.GET_MD_FROM_SET');
        END IF;
	RAISE e_mdcs_no_data_found;
      END IF;
*/
      --since cross rates, use fx_spot_rates formula
      xtr_fx_formulas.fx_spot_rate(p_in_rec.p_contra_ccy, p_in_rec.p_ccy,
				v_contra_ccy, v_ccy, 'C', 'C',
				p_out_rec.p_md_out);
    ELSE
      IF (p_in_rec.p_source = 'C') THEN
	OPEN get_fx_spot_rates;
      ELSIF (p_in_rec.p_source = 'R') THEN

-- bug 4145664 issue 12 when either base/contra currency is USD
          IF nvl(p_first_call,0) = 1 THEN
               OPEN get_fx_spot_rates;
          ELSE
               OPEN get_fx_spot_rates_reval;
          END IF;
      ELSE
	IF xtr_risk_debug_pkg.g_Debug THEN
	   xtr_risk_debug_pkg.dlog('GET_MD_FROM_SET: ' || 'For FX Spot Rates USD: the p_source values can only be ''C'' or ''R''.');
           xtr_risk_debug_pkg.dpop('XTR_MARKET_DATA_P.GET_MD_FROM_SET');
        END IF;
    	RAISE_APPLICATION_ERROR
          (-20001,'The p_source values can only be ''C'' or ''R''.');
      END IF;
      LOOP
	IF (p_in_rec.p_source = 'C') THEN
	  FETCH get_fx_spot_rates INTO temprec.bid_rate, temprec.ask_rate,
			temprec.bid_rate_base, temprec.ask_rate_base,
			temprec.currency;
	ELSE
-- bug 4145664 issue 12
             IF nvl(p_first_call,0) = 1 THEN
                  FETCH get_fx_spot_rates INTO temprec.bid_rate, temprec.ask_rate,
			temprec.bid_rate_base, temprec.ask_rate_base,
			temprec.currency;
              ELSE
	          FETCH get_fx_spot_rates_reval INTO temprec.bid_rate,
				temprec.ask_rate, temprec.bid_rate_base,
				temprec.ask_rate_base, temprec.currency;
              END IF;
	END IF;
        IF (p_in_rec.p_ccy <> 'USD') THEN
          IF (v_in_rec.p_side IN ('BID','B')) THEN
	    v_ccy := temprec.bid_rate_base;
	  ELSIF (v_in_rec.p_side IN ('ASK','A')) THEN
	    v_ccy := temprec.ask_rate_base;
  	  ELSE
	    v_ccy := (temprec.bid_rate_base+temprec.ask_rate_base)/2;
	  END IF;
          p_out_rec.p_md_out := v_ccy;
        ELSE
          IF (v_in_rec.p_side IN ('BID','B')) THEN
	    v_ccy := temprec.bid_rate;
	  ELSIF (v_in_rec.p_side IN ('ASK','A')) THEN
	    v_ccy := temprec.ask_rate;
	  ELSE
	    v_ccy := (temprec.bid_rate+temprec.ask_rate)/2;
	  END IF;
          p_out_rec.p_md_out := v_ccy;
        END IF;
        v_count := v_count+1;
        IF (v_count >= 1) THEN EXIT;
        END IF;
      END LOOP;
      IF (p_in_rec.p_source = 'C') THEN
	CLOSE get_fx_spot_rates;
      ELSE
         if get_fx_spot_rates%ISOPEN then
            CLOSE get_fx_spot_rates;
         end if;
        if get_fx_spot_rates_reval%ISOPEN then
            CLOSE get_fx_spot_rates_reval;
         end if;
      END IF;
/*
      --check whether there is any spot rate retrieved
      IF (v_count = 0) THEN
	IF xtr_risk_debug_pkg.g_Debug THEN
	   xtr_risk_debug_pkg.dlog('GET_MD_FROM_SET: ' || 'For FX Spot Rates USD: no data found');
           xtr_risk_debug_pkg.dpop('XTR_MARKET_DATA_P.GET_MD_FROM_SET');
        END IF;
	RAISE e_mdcs_no_data_found;
      END IF;
*/
    END IF;

  ELSIF (UPPER(p_in_rec.p_indicator) = 'B') THEN
  --for bond price
    --check p_side
    SELECT DECODE(bond_price_side, 'BID/ASK', p_in_rec.p_side, bond_price_side)
	INTO v_in_rec.p_side
	FROM xtr_rm_md_sets
	WHERE set_code = p_in_rec.p_md_set_code;

    IF (p_in_rec.p_source = 'R') THEN
      SELECT DECODE(v_in_rec.p_side, 'BID', nvl(bid_overwrite,bid),
				'A', nvl(ask_overwrite,ask),
		              'ASK', nvl(ask_overwrite,ask),
			 	'B', nvl(bid_overwrite,bid),
		(nvl(ask_overwrite,ask)+nvl(bid_overwrite,bid))/2)
	INTO p_out_rec.p_md_out
        FROM xtr_revaluation_rates
        WHERE reval_type = p_in_rec.p_bond_code
        AND volatility_or_rate = 'PRIC'
        AND day_mth IS NULL
        AND batch_id = p_in_rec.p_batch_id;
    ELSE
    --fetch bond price from xtr_interest_period_rates
      SELECT DECODE(v_in_rec.p_side,
		'ASK', offer_rate,
		'A', offer_rate,
		'BID', bid_rate,
		'B', bid_rate,
		(bid_rate+offer_rate)/2)
     	INTO p_out_rec.p_md_out
     	FROM xtr_interest_period_rates
	WHERE (rate_date, unique_period_id) IN
             (SELECT MAX(rate_date), unique_period_id
		FROM xtr_interest_period_rates
		WHERE trunc(rate_date) <= trunc(p_in_rec.p_spot_date)
		AND unique_period_id = p_in_rec.p_bond_code
     		GROUP BY unique_period_id)
	AND term_type = 'B';

    END IF;
    --check whether there is any spot rate retrieved
    IF (p_out_rec.p_md_out IS NULL) THEN
      IF xtr_risk_debug_pkg.g_Debug THEN
         xtr_risk_debug_pkg.dlog('GET_MD_FROM_SET: ' || 'For Bond: no data found');
         xtr_risk_debug_pkg.dpop('XTR_MARKET_DATA_P.GET_MD_FROM_SET');
      END IF;
      RAISE e_mdcs_no_data_found;
    END IF;



  ELSIF (UPPER(p_in_rec.p_indicator) = 'T') THEN     -- jhung STOCK is added
  --for stock price
    --check p_side
    SELECT DECODE(stock_price_side, 'BID/ASK', p_in_rec.p_side, stock_price_side)
        INTO v_in_rec.p_side
        FROM xtr_rm_md_sets
        WHERE set_code = p_in_rec.p_md_set_code;

    IF (p_in_rec.p_source = 'R') THEN
      SELECT DECODE(v_in_rec.p_side, 'BID', nvl(bid_overwrite,bid),
                                'A', nvl(ask_overwrite,ask),
                              'ASK', nvl(ask_overwrite,ask),
                                'B', nvl(bid_overwrite,bid),
                (nvl(ask_overwrite,ask)+nvl(bid_overwrite,bid))/2)
        INTO p_out_rec.p_md_out
        FROM xtr_revaluation_rates
        WHERE reval_type = p_in_rec.p_bond_code
        AND volatility_or_rate = 'PRIC'
        AND day_mth IS NULL
        AND batch_id = p_in_rec.p_batch_id;
    ELSE
    --fetch stock price from xtr_interest_period_rates
      SELECT DECODE(v_in_rec.p_side,
                'ASK', offer_rate,
                'A', offer_rate,
                'BID', bid_rate,
                'B', bid_rate,
                (bid_rate+offer_rate)/2)
        INTO p_out_rec.p_md_out
        FROM xtr_interest_period_rates
        WHERE (rate_date, unique_period_id) IN
             (SELECT MAX(rate_date), unique_period_id
                FROM xtr_interest_period_rates
                WHERE trunc(rate_date) <= trunc(p_in_rec.p_spot_date)
                AND unique_period_id = p_in_rec.p_bond_code
                GROUP BY unique_period_id)
        AND term_type = 'T';

    END IF;
    --check whether there is any spot rate retrieved
    IF (p_out_rec.p_md_out IS NULL) THEN
      IF xtr_risk_debug_pkg.g_Debug THEN
         xtr_risk_debug_pkg.dlog('GET_MD_FROM_SET: ' || 'For Stock: no data found');
         xtr_risk_debug_pkg.dpop('XTR_MARKET_DATA_P.GET_MD_FROM_SET');
      END IF;
      RAISE e_mdcs_no_data_found;
    END IF;

  ELSE
    IF xtr_risk_debug_pkg.g_Debug THEN
       xtr_risk_debug_pkg.dlog('GET_MD_FROM_SET: ' || 'p_indicator is invalid');
       xtr_risk_debug_pkg.dpop('XTR_MARKET_DATA_P.GET_MD_FROM_SET');
    END IF;
    RAISE_APPLICATION_ERROR
        (-20001,'Unknown p_indicator values.');
  END IF;

  --stop debug and print the result
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dlog('GET_MD_FROM_SET: ' || 'p_out_rec.p_md_out', p_out_rec.p_md_out);
     xtr_risk_debug_pkg.dpop('XTR_MARKET_DATA_P.GET_MD_FROM_SET');
  END IF;
END GET_MD_FROM_SET;



/*-------------------------------------------------------------------------
GET_FX_FORWARD_FROM_SET
Returns an FX Forward rate of a given market
data set.

All parameters, record types, ordering priorities,
and their definitions are the same as those of
-------------------------------------------------------------------------*/
PROCEDURE GET_FX_FORWARD_FROM_SET (p_in_rec  IN  md_from_set_in_rec_type,
			   	p_out_rec OUT NOCOPY md_from_set_out_rec_type) is

  v_in_rec md_from_set_in_rec_type;
  v_out_rec md_from_set_out_rec_type;
  v_hol_in_rec following_holiday_in_rec_type;
  v_hol_out_rec following_holiday_out_rec_type;
  v_base_rate NUMBER;
  v_contra_rate NUMBER;
  v_spot_rate NUMBER;
  v_fx_forw_base NUMBER;
  v_fx_forw_contra NUMBER;
  v_day_count NUMBER;
  v_annual_basis NUMBER;
  v_future_date_usd DATE;
  v_future_date_base DATE;
  v_future_date_contra DATE;
  v_usd_ir NUMBER := NULL;
  v_level VARCHAR2(2) := ' ';
  v_err_code NUMBER(8);

BEGIN
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dpush('GET_FX_FORWARD_FROM_SET');
     xtr_risk_debug_pkg.dlog('GET_FX_FORWARD_FROM_SET: ' || 'p_md_set_code',p_in_rec.p_md_set_code);
     xtr_risk_debug_pkg.dlog('GET_FX_FORWARD_FROM_SET: ' || 'p_source',p_in_rec.p_source);
     xtr_risk_debug_pkg.dlog('GET_FX_FORWARD_FROM_SET: ' || 'p_spot_date',p_in_rec.p_spot_date);
     xtr_risk_debug_pkg.dlog('GET_FX_FORWARD_FROM_SET: ' || 'p_future_date',p_in_rec.p_future_date);
     xtr_risk_debug_pkg.dlog('GET_FX_FORWARD_FROM_SET: ' || 'p_ccy',p_in_rec.p_ccy);
     xtr_risk_debug_pkg.dlog('GET_FX_FORWARD_FROM_SET: ' || 'p_contra_ccy',p_in_rec.p_contra_ccy);
     xtr_risk_debug_pkg.dlog('GET_FX_FORWARD_FROM_SET: ' || 'p_day_count_basis_out',p_in_rec.p_day_count_basis_out);
     xtr_risk_debug_pkg.dlog('GET_FX_FORWARD_FROM_SET: ' || 'p_interpolation_method',p_in_rec.p_interpolation_method);
     xtr_risk_debug_pkg.dlog('GET_FX_FORWARD_FROM_SET: ' || 'p_side',p_in_rec.p_side);
  END IF;

  --calc v_day_count and v_annual_basis
  xtr_calc_p.calc_days_run_c(p_in_rec.p_spot_date, p_in_rec.p_future_date,
			p_in_rec.p_day_count_basis_out, null, v_day_count,
			v_annual_basis);

  --transfer all the common parameters to the new record
  v_in_rec.p_source := p_in_rec.p_source;
  v_in_rec.p_spot_date := p_in_rec.p_spot_date;
  v_in_rec.p_batch_id := p_in_rec.p_batch_id;
  v_in_rec.p_interpolation_method := p_in_rec.p_interpolation_method;
  v_in_rec.p_day_count_basis_out := p_in_rec.p_day_count_basis_out;
  v_in_rec.p_md_set_code := p_in_rec.p_md_set_code;

  --find USD1Y ISDA Modified Follwing Bus Day Conv future date
  xtr_fps3_p.chk_holiday(p_in_rec.p_future_date,
			'USD', v_err_code, v_level);
  --check if v_future_date falls on holiday, if so call
  --following_holiday
  IF (v_err_code IS NOT NULL) THEN
    v_hol_in_rec.p_future_date := p_in_rec.p_future_date;
    v_hol_in_rec.p_currency := 'USD';
    v_hol_in_rec.p_term_type := 'Y';
    following_holiday(v_hol_in_rec, v_hol_out_rec);
    v_future_date_usd := v_hol_out_rec.p_date_out;
  ELSE
    v_future_date_usd := p_in_rec.p_future_date;
  END IF;

  --find ISDA Modified Follwing Bus Day Conv future date for non USD BASE CCY
  IF (p_in_rec.p_ccy <> 'USD') THEN
    --find base_ccy1Y ISDA Modified Following Bus Day Conv future date
    xtr_fps3_p.chk_holiday(p_in_rec.p_future_date,
			p_in_rec.p_ccy, v_err_code, v_level);
    --check if v_future_date falls on holiday, if so call
    --following_holiday
    IF (v_err_code IS NOT NULL) THEN
      v_hol_in_rec.p_future_date := p_in_rec.p_future_date;
      v_hol_in_rec.p_currency := p_in_rec.p_ccy;
      v_hol_in_rec.p_term_type := 'Y';
      following_holiday(v_hol_in_rec, v_hol_out_rec);
      v_future_date_base := v_hol_out_rec.p_date_out;
    END IF;
  ELSE
    v_future_date_base := v_future_date_usd;
  END IF;
  --find ISDA Modified Follwing Bus Day Conv future date for non USD CONTRA CCY
  IF (p_in_rec.p_contra_ccy <> 'USD') THEN
    --find contra_ccy1Y ISDA Modified Follwing Bus Day Conv future date
    xtr_fps3_p.chk_holiday(p_in_rec.p_future_date,
			p_in_rec.p_contra_ccy, v_err_code, v_level);
    --check if v_future_date falls on holiday, if so call
    --following_holiday
    IF (v_err_code IS NOT NULL) THEN
      v_hol_in_rec.p_future_date := p_in_rec.p_future_date;
      v_hol_in_rec.p_currency := p_in_rec.p_contra_ccy;
      v_hol_in_rec.p_term_type := 'Y';
      following_holiday(v_hol_in_rec, v_hol_out_rec);
      v_future_date_contra := v_hol_out_rec.p_date_out;
    END IF;
  ELSE
    v_future_date_contra := v_future_date_usd;
  END IF;

  --For FX Forward BID
  IF (UPPER(p_in_rec.p_side) IN ('B','BID')) THEN
    --find the base FX Forward BID ask
    IF (p_in_rec.p_ccy <> 'USD') THEN
      --find the interest rate for the base currency
      v_in_rec.p_side := 'B';
      v_in_rec.p_indicator := 'R';
      v_in_rec.p_ccy := 'USD';
      v_in_rec.p_future_date := v_future_date_usd;
      get_md_from_set(v_in_rec, v_out_rec);
      v_base_rate := v_out_rec.p_md_out;
      --find the interest rate for the contra currency
      v_in_rec.p_future_date := v_future_date_base;
      v_in_rec.p_side := 'A';
      v_in_rec.p_indicator := 'R';
      v_in_rec.p_ccy := p_in_rec.p_ccy;
      get_md_from_set(v_in_rec, v_out_rec);
      v_contra_rate := v_out_rec.p_md_out;
      --find the spot rate
      v_in_rec.p_side := 'A';
      v_in_rec.p_indicator := 'S';
      v_in_rec.p_ccy := 'USD';
      v_in_rec.p_contra_ccy := p_in_rec.p_ccy;
      get_md_from_set(v_in_rec, v_out_rec);
      v_spot_rate := v_out_rec.p_md_out;
      xtr_fx_formulas.fx_forward_rate(v_spot_rate, v_base_rate, v_contra_rate,
				v_day_count, v_day_count, v_annual_basis,
				v_annual_basis, v_fx_forw_base);

    ELSE
      v_fx_forw_base := 1;
    END IF;
    --find the FX Forward Contra BID bid
    IF (p_in_rec.p_contra_ccy <> 'USD') THEN
      --First find the interest rate for the base currency
      v_in_rec.p_side := 'A';
      v_in_rec.p_indicator := 'R';
      v_in_rec.p_ccy := 'USD';
      v_in_rec.p_future_date := v_future_date_usd;
      get_md_from_set(v_in_rec, v_out_rec);
      v_base_rate := v_out_rec.p_md_out;
      --find the interest rate for the contra currency
      v_in_rec.p_future_date := v_future_date_contra;
      v_in_rec.p_side := 'B';
      v_in_rec.p_indicator := 'R';
      v_in_rec.p_ccy := p_in_rec.p_contra_ccy;
      get_md_from_set(v_in_rec, v_out_rec);
      v_contra_rate := v_out_rec.p_md_out;
      --find the spot rate
      v_in_rec.p_side := 'B';
      v_in_rec.p_indicator := 'S';
      v_in_rec.p_ccy := 'USD';
      v_in_rec.p_contra_ccy := p_in_rec.p_contra_ccy;
      get_md_from_set(v_in_rec, v_out_rec);
      v_spot_rate := v_out_rec.p_md_out;
      xtr_fx_formulas.fx_forward_rate(v_spot_rate, v_base_rate, v_contra_rate,
				v_day_count, v_day_count, v_annual_basis,
				v_annual_basis, v_fx_forw_contra);
    ELSE
      v_fx_forw_contra := 1;
    END IF;
    p_out_rec.p_md_out := v_fx_forw_contra/v_fx_forw_base;
  ELSIF (UPPER(p_in_rec.p_side) IN ('A','ASK')) THEN
  --for FX Forward ASK
    --find the base FX Forward ASK bid
    IF (p_in_rec.p_ccy <> 'USD') THEN
      --First find the interest rate for the base currency
      v_in_rec.p_side := 'A';
      v_in_rec.p_indicator := 'R';
      v_in_rec.p_ccy := 'USD';
      v_in_rec.p_future_date := v_future_date_usd;
      get_md_from_set(v_in_rec, v_out_rec);
      v_base_rate := v_out_rec.p_md_out;
      --find the interest rate for the contra currency
      v_in_rec.p_future_date := v_future_date_base;
      v_in_rec.p_side := 'B';
      v_in_rec.p_indicator := 'R';
      v_in_rec.p_ccy := p_in_rec.p_ccy;
      get_md_from_set(v_in_rec, v_out_rec);
      v_contra_rate := v_out_rec.p_md_out;
      --find the interest rate for the spot rate
      v_in_rec.p_side := 'B';
      v_in_rec.p_indicator := 'S';
      v_in_rec.p_ccy := 'USD';
      v_in_rec.p_contra_ccy := p_in_rec.p_ccy;
      get_md_from_set(v_in_rec, v_out_rec);
      v_spot_rate := v_out_rec.p_md_out;
      xtr_fx_formulas.fx_forward_rate(v_spot_rate, v_base_rate, v_contra_rate,
				v_day_count, v_day_count, v_annual_basis,
				v_annual_basis, v_fx_forw_base);
    ELSE
      v_fx_forw_base := 1;
    END IF;
    --find the FX Forward Contra ASK ask
    IF (p_in_rec.p_contra_ccy <> 'USD') THEN
      --find the interest rate for the base currency
      v_in_rec.p_side := 'B';
      v_in_rec.p_indicator := 'R';
      v_in_rec.p_ccy := 'USD';
      v_in_rec.p_future_date := v_future_date_usd;
      get_md_from_set(v_in_rec, v_out_rec);
      v_base_rate := v_out_rec.p_md_out;
      --find the interest rate for the contra currency
      v_in_rec.p_future_date := v_future_date_contra;
      v_in_rec.p_side := 'A';
      v_in_rec.p_indicator := 'R';
      v_in_rec.p_ccy := p_in_rec.p_contra_ccy;
      get_md_from_set(v_in_rec, v_out_rec);
      v_contra_rate := v_out_rec.p_md_out;
      --find the spot rate
      v_in_rec.p_side := 'A';
      v_in_rec.p_indicator := 'S';
      v_in_rec.p_ccy := 'USD';
      v_in_rec.p_contra_ccy := p_in_rec.p_contra_ccy;
      get_md_from_set(v_in_rec, v_out_rec);
      v_spot_rate := v_out_rec.p_md_out;
      xtr_fx_formulas.fx_forward_rate(v_spot_rate, v_base_rate, v_contra_rate,
				v_day_count, v_day_count, v_annual_basis,
				v_annual_basis, v_fx_forw_contra);
    ELSE
      v_fx_forw_contra := 1;
    END IF;
    p_out_rec.p_md_out := v_fx_forw_contra/v_fx_forw_base;
  ELSE
  --for FX Forward MID
    --find the base FX Forward MID mid
    IF (p_in_rec.p_ccy <> 'USD') THEN
      --find the interest rate for the base currency
      v_in_rec.p_side := 'M';
      v_in_rec.p_indicator := 'R';
      v_in_rec.p_ccy := 'USD';
      v_in_rec.p_future_date := v_future_date_usd;
      get_md_from_set(v_in_rec, v_out_rec);
      v_base_rate := v_out_rec.p_md_out;
      v_usd_ir := v_out_rec.p_md_out;
      --find the interest rate for the contra currency
      v_in_rec.p_future_date := v_future_date_base;
      v_in_rec.p_side := 'M';
      v_in_rec.p_indicator := 'R';
      v_in_rec.p_ccy := p_in_rec.p_ccy;
      get_md_from_set(v_in_rec, v_out_rec);
      v_contra_rate := v_out_rec.p_md_out;
      --find the spot rate
      v_in_rec.p_side := 'M';
      v_in_rec.p_indicator := 'S';
      v_in_rec.p_ccy := 'USD';
      v_in_rec.p_contra_ccy := p_in_rec.p_ccy;
      get_md_from_set(v_in_rec, v_out_rec);
      v_spot_rate := v_out_rec.p_md_out;
      xtr_fx_formulas.fx_forward_rate(v_spot_rate, v_base_rate, v_contra_rate,
				v_day_count, v_day_count, v_annual_basis,
				v_annual_basis, v_fx_forw_base);
    ELSE
      v_fx_forw_base := 1;
    END IF;
    --find the FX Forward Contra MID mid
    IF (p_in_rec.p_contra_ccy <> 'USD') THEN
      --find the interest rate for the base currency
      IF (v_usd_ir IS NULL) THEN
        v_in_rec.p_side := 'M';
        v_in_rec.p_indicator := 'R';
        v_in_rec.p_ccy := 'USD';
        v_in_rec.p_future_date := v_future_date_usd;
        get_md_from_set(v_in_rec, v_out_rec);
        v_base_rate := v_out_rec.p_md_out;
      ELSE
        v_base_rate := v_usd_ir;
      END IF;
      --find the interest rate for the contra currency
      v_in_rec.p_side := 'M';
      v_in_rec.p_indicator := 'R';
      v_in_rec.p_ccy := p_in_rec.p_contra_ccy;
      v_in_rec.p_future_date := v_future_date_contra;
      get_md_from_set(v_in_rec, v_out_rec);
      v_contra_rate := v_out_rec.p_md_out;
      --find the interest rate for the spot rate
      v_in_rec.p_side := 'M';
      v_in_rec.p_indicator := 'S';
      v_in_rec.p_ccy := 'USD';
      v_in_rec.p_contra_ccy := p_in_rec.p_contra_ccy;
      get_md_from_set(v_in_rec, v_out_rec);
      v_spot_rate := v_out_rec.p_md_out;
      xtr_fx_formulas.fx_forward_rate(v_spot_rate, v_base_rate, v_contra_rate,
				v_day_count, v_day_count, v_annual_basis,
				v_annual_basis, v_fx_forw_contra);
    ELSE
      v_fx_forw_contra := 1;
    END IF;
    p_out_rec.p_md_out := v_fx_forw_contra/v_fx_forw_base;
  END IF;

  --stop debug and print result
  IF xtr_risk_debug_pkg.g_Debug THEN
     xtr_risk_debug_pkg.dlog('GET_FX_FORWARD_FROM_SET: ' || 'p_out_rec.p_md_out', p_out_rec.p_md_out);
     xtr_risk_debug_pkg.dpop('GET_FX_FORWARD_FROM_SET');
  END IF;

END GET_FX_FORWARD_FROM_SET;



END;

/
