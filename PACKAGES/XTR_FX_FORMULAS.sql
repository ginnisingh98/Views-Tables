--------------------------------------------------------
--  DDL for Package XTR_FX_FORMULAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_FX_FORMULAS" AUTHID CURRENT_USER AS
/* $Header: xtrfxfls.pls 120.2 2005/06/29 08:06:01 badiredd ship $ */

--
/*-----------------------------------------------------------------------
FX_GK_OPTION_PRICE_CV
Cover procedure to calculate the price of a currency option
using Garman-Kohlhagen formula, which is the extension of
Black-Scholes formula.

IMPORTANT: it is better to supply a Simple 30/360 (from GET_MD_FROM_SET)
interest rates for this procedure in order to avoid redundant conversions.

IMPORTANT: this procedure is only accurate up to six decimal places due
to CUMULATIVE_NORM_DISTRIBUTION procedure it calls.

GK_OPTION_CV_IN_REC_TYPE:
p_SPOT_DATE date
p_MATURITY_DATE date
p_RATE_DOM num
p_RATE_TYPE_DOM varchar2(1) DEFAULT 'S'
p_COMPOUND_FREQ_DOM num
p_DAY_COUNT_BASIS_DOM varchar2(15)
p_RF_RATE_FOR num
p_RATE_TYPE_FOR varchar2(1) DEFAULT 'S'
p_COMPOUND_FREQ_FOR num
p_DAY_COUNT_BASIS_FOR varchar2(15)
p_SPOT_RATE num
p_STRIKE_RATE num
p_VOLATILITY num

GK_OPTION_CV_OUT_REC_TYPE:
p_CALL_PRICE num
p_PUT_PRICE num
p_FX_FWD_RATE num
p_Nd1 num
p_Nd2 num
p_Nd1_a num
p_Nd2_a num

Formula:
1. Converts interest rates to fit the FX_GK_OPTION_PRICE assumptions.
2. Calls FX_GK_OPTION_PRICE.

Example to calculate p_SPOT_RATE:
Given: CAD = foreign, USD = domestic
1 USD = 1.5 CADThen: p_SPOT_RATE = 0.666667

p_SPOT_DATE = the spot date where the option value is evaluated
p_MATURITY_DATE = the maturity date where the option expires
p_RF_RATE_DOM = domestic risk free interest rate.
p_RATE_TYPE_DOM/FOR = the p_RF_RATE_DOM/FOR rate's type. 'S' for Simple
 Rate. 'C' for Continuous Rate, and 'P' for Compounding Rate.
Default value = 'S' (Simple IR)
p_DAY_COUNT_BASIS_DOM/FOR = day count basis for p_RF_RATE_DOM/FOR.
p_RATE_FOR = foreign risk free interest rate.
p_SPOT_RATE = the current market exchange rate = the value of one unit
of the foreign currency measured in the domestic currency.
p_STRIKE_RATE = the strike price agreed in the option.
p_VOLATILITY = volatility
p_CALL_PRICE = theoretical fair value of the call.
p_PUT_PRICE = theoretical fair value of the put
p_FX_FWD_RATE = the forward rate of the exchange calculated from the
p_SPOT_RATE
p_Nd1/2 = cumulative distribution value given limit probability values
in Black's formula = N(x) (refer to Hull's Fourth Edition p.252)
p_Nd1/2_a = N'(x) in Black's formula (refer to Hull's Fourth Edition p.252)
p_COMPOUND_FREQ_DOM/FOR = frequencies of discretely compounded input/output
rate. This is only necessary if p_RATE_TYPE_DOM/FOR is 'P'.
-----------------------------------------------------------------------*/
TYPE GK_OPTION_CV_IN_REC_TYPE IS RECORD (p_SPOT_DATE date,
					p_MATURITY_DATE date,
					p_RATE_DOM NUMBER,
				p_RATE_TYPE_DOM varchar2(1) DEFAULT 'S',
					p_COMPOUND_FREQ_DOM NUMBER,
					p_DAY_COUNT_BASIS_DOM varchar2(15),
					p_RATE_FOR NUMBER,
				p_RATE_TYPE_FOR varchar2(1) DEFAULT 'S',
					p_COMPOUND_FREQ_FOR NUMBER,
					p_DAY_COUNT_BASIS_FOR varchar2(15),
					p_SPOT_RATE NUMBER,
					p_STRIKE_RATE NUMBER,
					p_VOLATILITY NUMBER);

TYPE GK_OPTION_CV_OUT_REC_TYPE IS RECORD (p_CALL_PRICE NUMBER,
					p_PUT_PRICE NUMBER,
					p_FX_FWD_RATE NUMBER,
					p_Nd1 NUMBER,
					p_Nd2 NUMBER,
					p_Nd1_a NUMBER,
					p_Nd2_a NUMBER);

PROCEDURE FX_GK_OPTION_PRICE_CV(p_in_rec IN GK_OPTION_CV_IN_REC_TYPE,
				p_out_rec OUT NOCOPY GK_OPTION_CV_OUT_REC_TYPE);

/*-----------------------------------------------------------------------
Calculates the FX Spot Rate for different currencies exchange.

Formula:
* If the BASIS_CONTRA/BASE is not 'C' (Commodity Unit Quote) then convert with FX FORWARD (HLD) Formula 1
* Check CURRENCY_CONTRA and CURRENCY_BASE if  cross-currency pair is involved then  use FX FORWARD (HLD) Formula 2

Formula 1 is converting from Base Unit Quote to Commodity Unit Quote, and vice versa.
Formula 2 is to calculate the SPOT RATE(=Cross Rate)

Assumption: p_RATE_ CONTRA and p_RATE_ BASE have the same day count basis.

For IRS:  BASE = Receive Leg
          CONTRA = Pay Leg
Example for FX:CHFGBP -> CHF = Base Currency
                         GBP = Contra Currency

IF there is a notion of BID and ASK then:
To find p_SPOT_RATE (BID/ASK):
FOR CONTRA:
  IF p_BASIS_CONTRA = 'C' THEN
     p_RATE_CONTRA (BID/ASK) = BID/ASK Rate of
       Contra Currency
  ELSE
     p_RATE_CONTRA (BID/ASK) = ASK/BID Rate of
        Contra Currency
FOR BASE:
  IF p_BASIS_BASE = 'C' THEN
    p_RATE_BASE (BID/ASK) = ASK/BID Rate of Base
        Currency
  ELSE
    p_RATE_BASE (BID/ASK) = BID/ASK Rate of Base
        Currency

* p_RATE_CONTRA/BASE = FX rate of the contra/base side against USD
(p_RATE_CONTRA = Rate vs. USD Contra, p_RATE_ BASE = Rate vs. USD Base).
If the currency is USD then p_RATE = 1;
* p_CURRENCY_CONTRA/BASE = the currency for contra/base.
* p_BASIS_CONTRA/BASE indicates the quotation basis against USD for the CONTRA
BASE side, 'C' for Commodity Unit Quote (=USDGBP) and 'B' for Base Unit Quote=
GBPUSD) (Definitions are in FX Calculator HLD)
* p_SPOT_RATE = fair exchange rate of two different currencies.
-----------------------------------------------------------------------*/

PROCEDURE FX_SPOT_RATE (p_currency_contra IN VARCHAR2,
                        p_currency_base IN VARCHAR2,
                        p_rate_contra IN NUMBER,
                        p_rate_base IN NUMBER,
                        p_basis_contra IN CHAR,
                        p_basis_base IN CHAR,
                        p_spot_rate IN OUT NOCOPY NUMBER);



/*-------------------------------------------------------------------------
Calculates the FX Forward Rate

Formula:
FX FORWARD (HLD) Formula 3

Example for FX: CHFGBP -> CHF = Base Currency
                          GBP = Contra Currency

IF there is a notion of BID and ASK then:
To find p_FORWARD_RATE (BID):
    p_SPOT_RATE = BID FX Spot Rate
    p_BASE_CURR_INT_RATE = ASK Base Currency risk free interest rate.
    p_CONTRA_CURR_INT_RATE = BID Contra Currency risk free interest rate.

To find p_FORWARD_RATE (ASK):
    p_SPOT_RATE = ASK FX Spot Rate
    p_BASE_CURR_INT_RATE = BID Base Currency risk free interest rate.
    p_CONTRA_CURR_INT_RATE = ASK Contra Currency risk free interest rate.


* p_SPOT_RATE = fair exchange rate of two different currencies.
* p_BASE/CONTRA_CURR_INT_RATE = risk free interest rate for the base/contra
currency.
* p_DAY_COUNT_BASE/CONTRA = number of days between the spot date and the
forward
date.
* p_ANNUAL_BASIS_BASE/CONTRA = number of days in a year of which the
* p_DAY_COUNT_BASE/CONTRA and the p_BASE/CONTRA_CURR_INT_RATE are based on.
-------------------------------------------------------------------------*/

PROCEDURE FX_FORWARD_RATE (p_spot_rate IN NUMBER,
                           p_base_curr_int_rate IN NUMBER,
                           p_contra_curr_int_rate IN NUMBER,
                           p_day_count_base IN NUMBER,
                           p_day_count_contra IN NUMBER,
                           p_annual_basis_base IN NUMBER,
                           p_annual_basis_contra IN NUMBER,
                           p_forward_rate IN OUT NOCOPY NUMBER);


/*---------------------------------------------------------------------------
FX Option Pricing (Garman Kohlagen's Method)
Calculates the price and sensitivity of a currency option and its associated greek ratio's using Garman-Kohlhagen formula, which is the extension of Black-Scholes formula.

Formula:
Taken from Currency Option Pricing Formula in Hull's Option, Future, and Other Derivatives, Third Edition p.272, p. 317.
(Defined in xtrprc2b.pls)

Currently used in xtrrevlb.pld

Call XTR_RATE_CONVERSION.rate_conversion to convert day counts and/or between compounded and simple interest rates.

* l_days = time left to maturity in days(assuming 30/360 day count basis).
* l_base_int_rate = annual risk free interest rate for base currency.
* l_contra_int_rate = annual risk free interest rate for contra currency.
* l_spot_rate = the current market rate for the exchange.
* l_strike_price = the strike price agreed in the option.
* vol = volatility
* l_call_price = theoretical fair value of the call.
* l_put_price = theoretical fair value of the put
* l_fwd_price = the forward rate of the exchange calculated from the l_spot_rate
* l_delta_call/put = delta of the call/put
* l_theta_call/put = theta of the call/put
* l_rho_call/put = rho of the call/put (with respect to the change in base interest rate)
* l_gamma = gamma
* l_vega = vega
* l_nd1/2 = cumulative normal probability distribution value = N(x) in Black Formu
la
* l_nd1/2_a = N'(x) in Black Formula


gamma, theta, delta, vega are sensitivity measurements of the model relatives to its different variables and explained extensively in Hull's Option, Future, and Other Derivatives.
----------------------------------------------------------------------------*/
-- modified fhu 6/13/01
PROCEDURE FX_GK_OPTION_PRICE(
                             l_days         IN NUMBER,
                             l_base_int_rate IN NUMBER,
                             l_contra_int_rate IN NUMBER,
                             l_spot_rate     IN NUMBER,
                             l_strike_rate   IN NUMBER,
                             vol IN NUMBER,
                             l_call_price IN OUT NOCOPY NUMBER,
                             l_put_price IN OUT NOCOPY NUMBER,
                             l_fwd_rate IN OUT NOCOPY NUMBER,
			     l_nd1 IN OUT NOCOPY NUMBER,
			     l_nd2 IN OUT NOCOPY NUMBER,
			     l_nd1_a IN OUT NOCOPY NUMBER,
			     l_nd2_a IN OUT NOCOPY NUMBER  );
--added by sankim 9/10/01
/*
FX_SPOT_RATE_CV (FUNCTION)Cover routine that calculates the FX Spot Rate for
bid and ask side of different currencies exchange.In order to make the cover
routine easier to be called from Java (middle tier) directly, the record type
is not used to encapsulate the arguments. Moreover, function is used instead of
 procedure since function can be called from SQL.
Parameters
* p_RATE_CONTRA/BASE_BID/ASK = FX rate of the contra/base currency against USD
for bid/ask side (p_RATE_ CONTRA = Rate vs. USD Contra, p_RATE_ BASE = Rate vs.
 USD Base). If the currency is USD then use the default rate (=1).
* p_CURRENCY_CONTRA/BASE = the currency for contra/base.
 p_QUOTATION_BASIS_CONTRA/BASE indicates the quotation basis against USD for
the CONTRA /BASE side, 'C' for Commodity Unit Quote (=USDGBP) and 'B' for Base
Unit Quote (= GBPUSD) (Definitions are in FX Calculator HLD)
* Returned: p_SPOT_RATE (BID/ASK) = fair exchange rate of two different
currencies of side bid/ask.
*/
FUNCTION FX_SPOT_RATE_CV( p_currency_contra IN VARCHAR2,
			  p_currency_base IN VARCHAR2,
			  p_rate_contra_bid IN NUMBER DEFAULT 1,
			  p_rate_contra_ask IN NUMBER DEFAULT 1,
			  p_rate_base_bid IN NUMBER DEFAULT 1,
			  p_rate_base_ask IN NUMBER DEFAULT 1,
			  p_quotation_basis_contra IN VARCHAR2 DEFAULT 'C',
			  p_quotation_basis_base IN VARCHAR2 DEFAULT 'C')
	RETURN XTR_MD_NUM_TABLE;
--added by sankim 9/10/01
/*
FX_FORWARD_RATE_CV (FUNCTION)A cover routine that calculates the FX Forward
Rate for  exchange that has USD as the base.In order to make the cover routine
easier to be called from Java (middle tier) directly, the record type is not
used to encapsulate the arguments. Moreover, function is used instead of
procedure since function can be called from SQL.
Parameters
* p_SPOT_RATE_BASE_BID/ASK = fair exchange rate of between the base currency
against USD. If the base currency is USD, then the default value of 1 should be
 used.
* p_SPOT_RATE_CONTRA_BID/ASK = fair exchange rate of between the contra
currency against USD. If the contra currency is USD, then the default value of
 1 should be used.
* p_BASE_CURR_INT_RATE_BID/ASK = bid/ask risk free interest rate for the base
currency.  This parameter should be null if the base currency is USD.
* p_CONTRA_CURR_INT_RATE_BID/ASK = bid/ask risk free interest rate for the
contra currency.  This parameter should be null if the contra currency is USD.
* p_USD _CURR_INT_RATE = risk free interest rate for the USD.
* p_DAY_COUNT_BASE/CONTRA = number of days between the spot date and the
forward date. If the contra currency is USD, then p_DAY_COUNT_CONTRA should be
null, and vice versa in the case of base is USD.
* p_ANNUAL_BASIS_BASE/CONTRA = number of days in a year of which the
p_DAY_COUNT_BASE/CONTRA and the p_BASE/CONTRA_CURR_INT_RATE are based on. If
the contra currency is USD, then p_ANNUAL_BASIS_CONTRA should be null, and vice
 versa in the case of base is USD.
* p_DAY_COUNT_USD = number of days between the spot date and the forward date.
= number of days in a year of which the p_DAY_COUNT_USD and the
p_USD _CURR_INT_RATE are based on.
* p_ANNUAL_BASIS_USD = number of days in a year of which the p_DAY_COUNT_USD
and the p_USD _CURR_INT_RATE are based on.
* p_CURRENCY_CONTRA/BASE = the currency for contra/base.
* p_QUOTATION_BASIS_CONTRA/BASE indicates the quotation basis against USD for
the CONTRA /BASE side, 'C' for Commodity Unit Quote (=USDGBP) and 'B' for Base
Unit Quote (= GBPUSD) (Definitions are in FX Calculator HLD). This parameter is
 required if base/contra is non-USD accordingly.
* Returned: p_FORWARD_RATE (BID/ASK) indicates the bid/ask side of forward rate
 results.
*/
FUNCTION FX_FORWARD_RATE_CV( p_spot_rate_base_bid IN NUMBER DEFAULT 1,
			     p_spot_rate_base_ask IN NUMBER DEFAULT 1,
			     p_spot_rate_contra_bid IN NUMBER DEFAULT 1,
			     p_spot_rate_contra_ask IN NUMBER DEFAULT 1,
      			     p_base_curr_int_rate_bid IN NUMBER,
			     p_base_curr_int_rate_ask IN NUMBER,
			     p_contra_curr_int_rate_bid IN NUMBER,
			     p_contra_curr_int_rate_ask IN NUMBER,
 			     p_usd_curr_int_rate_bid IN NUMBER,
			     p_usd_curr_int_rate_ask IN NUMBER,
 			     p_day_count_base IN NUMBER,
			     p_day_count_contra IN NUMBER,
			     p_day_count_usd IN NUMBER,
			     p_annual_basis_base IN NUMBER,
			     p_annual_basis_contra IN NUMBER,
			     p_annual_basis_usd IN NUMBER,
			     p_currency_base IN VARCHAR2,
			     p_currency_contra IN VARCHAR2,
			     p_quotation_basis_base IN VARCHAR2 DEFAULT 'C',
			     p_quotation_basis_contra IN VARCHAR2 DEFAULT 'C')
	RETURN XTR_MD_NUM_TABLE;

END XTR_FX_FORMULAS;

 

/
