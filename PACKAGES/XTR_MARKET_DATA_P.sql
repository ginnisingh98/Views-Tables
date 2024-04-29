--------------------------------------------------------
--  DDL for Package XTR_MARKET_DATA_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_MARKET_DATA_P" AUTHID CURRENT_USER AS
/* $Header: xtrmdcss.pls 120.3 2005/06/29 10:32:42 badiredd ship $ */

e_mdcs_no_data_found EXCEPTION;
e_mdcs_no_curve_found EXCEPTION;

--Create PL/SQL wrapper for Cubic Spline Interpolation
FUNCTION cubic_spline_interpolation (v_X XTR_MD_NUM_TABLE, v_Y XTR_MD_NUM_TABLE,
	v_N NUMBER, p_x NUMBER, p_endCondInd1 NUMBER, p_endCondInd2 NUMBER,
	p_endValue1 NUMBER, p_endValue2 NUMBER) RETURN VARCHAR2;


/*----------------------------------------------------------------------
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
TYPE md_from_curve_in_rec_type is RECORD (p_curve_code         VARCHAR2(20),
					p_source               VARCHAR2(1),
					p_indicator            VARCHAR2(2),
					p_spot_date            DATE,
					p_future_date          DATE,
					p_day_count_basis_out  VARCHAR2(20),
			p_interpolation_method VARCHAR2(20) DEFAULT 'DEFAULT',
					p_side                 VARCHAR2(20),
					p_batch_id             NUMBER);


TYPE md_from_curve_out_rec_type is RECORD ( p_md_out	      NUMBER);


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
TYPE md_from_set_in_rec_type is RECORD (p_md_set_code          VARCHAR2(20),
					p_source               VARCHAR2(1),
					p_indicator            VARCHAR2(2),
					p_spot_date            DATE,
					p_future_date          DATE,
					p_ccy		       VARCHAR2(15),
					p_contra_ccy	       VARCHAR2(15),
					p_day_count_basis_out  VARCHAR2(20),
			p_interpolation_method VARCHAR2(20) DEFAULT 'DEFAULT',
					p_side                 VARCHAR2(20),
					p_batch_id             NUMBER,
					p_bond_code	       VARCHAR2(20));


TYPE md_from_set_out_rec_type is RECORD (p_md_out	      NUMBER);


TYPE following_holiday_in_rec_type IS RECORD (p_term_type VARCHAR2(13),
						p_spot_date DATE DEFAULT NULL,
						p_currency VARCHAR2(15),
						p_future_date DATE,
						p_period_code NUMBER);
TYPE following_holiday_out_rec_type IS RECORD (p_date_out DATE);


PROCEDURE GET_MD_FROM_CURVE (p_in_rec  IN  md_from_curve_in_rec_type,
			     p_out_rec OUT NOCOPY md_from_curve_out_rec_type);

PROCEDURE GET_MD_FROM_SET (p_in_rec  IN  md_from_set_in_rec_type,
			   p_out_rec OUT NOCOPY md_from_set_out_rec_type,
                       p_first_call IN NUMBER DEFAULT NULL);


/*-------------------------------------------------------------------------
GET_FX_FORWARD_FROM_SET
Returns an FX Forward rate of a given market
data set.

All parameters, record types, ordering priorities,
and their definitions are the same as those of
-------------------------------------------------------------------------*/
PROCEDURE GET_FX_FORWARD_FROM_SET (p_in_rec  IN  md_from_set_in_rec_type,
 			   	   p_out_rec OUT NOCOPY md_from_set_out_rec_type);


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
				p_slope       IN NUMBER DEFAULT NULL,
				p_rate        OUT NOCOPY NUMBER);


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
					p_rate  OUT NOCOPY NUMBER);

PROCEDURE Following_Holiday(p_in_rec IN following_holiday_in_rec_type,
			    p_out_rec OUT NOCOPY following_holiday_out_rec_type);

--Bug 2804548
--This actually calculates PREVIOUS BUSINESS DAY rule.
PROCEDURE Modified_Following_Holiday(p_currency IN VARCHAR2,
				     p_date_in IN DATE,
				     p_date_out OUT NOCOPY DATE);

END;
 

/
