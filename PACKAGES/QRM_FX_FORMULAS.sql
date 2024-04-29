--------------------------------------------------------
--  DDL for Package QRM_FX_FORMULAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QRM_FX_FORMULAS" AUTHID CURRENT_USER AS
/* $Header: qrmfxfls.pls 115.15 2003/11/22 00:36:21 prafiuly ship $ */

--bug 3236479
g_debug_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_proc_level NUMBER := FND_LOG.LEVEL_PROCEDURE;

-- added fhu 3/36/02
TYPE GK_OPTION_SENS_IN_REC_TYPE IS RECORD (
			p_SPOT_DATE date,
			p_MATURITY_DATE date,
			p_CCY_FOR VARCHAR2(15),
			p_CCY_DOM VARCHAR2(15),
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

TYPE GK_OPTION_SENS_OUT_REC_TYPE IS RECORD (
			p_DELTA_CALL	NUMBER,
			p_DELTA_PUT	NUMBER,
			p_THETA_CALL	NUMBER,
			p_THETA_PUT	NUMBER,
			p_RHO_CALL	NUMBER,
			p_RHO_PUT	NUMBER,
			p_RHO_F_CALL	NUMBER,
			p_RHO_F_PUT	NUMBER,
			p_GAMMA		NUMBER,
			p_VEGA		NUMBER);


/*-------------------------------------------------------------
FX_GK_OPTION_SENS_CV
Cover procedure to calculate the sensitivity of a currency option
using Garman-Kohlhagen formula, which is the extension of
Black-Scholes formula.

IMPORTANT: it is better to supply a Simple 30/360 (from GET_MD_FROM_SET)
interest rates for this procedure in order to avoid redundant conversions.

IMPORTANT: this procedure is only accurate up to six decimal places due
to CUMULATIVE_NORM_DISTRIBUTION procedure it calls.

GK_OPTION_SENS_IN_REC_TYPE:
			p_SPOT_DATE
			p_MATURITY_DATE
			p_CCY_FOR
			p_CCY_DOM
			p_RATE_DOM
			p_RATE_TYPE_DOM
			p_COMPOUND_FREQ_DOM
			p_DAY_COUNT_BASIS_DOM
			p_RATE_FOR
			p_RATE_TYPE_FOR
			p_COMPOUND_FREQ
			p_DAY_COUNT_BASIS_FOR
			p_SPOT_RATE
			p_STRIKE_RATE
			p_VOLATILITY

GK_OPTION_SENS_OUT_REC_TYPE:
			p_DELTA_CALL
			p_DELTA_PUT
			p_THETA_CALL
			p_THETA_PUT
			p_RHO_CALL
			p_RHO_PUT
			p_RHO_F_CALL
			p_RHO_F_PUT
			p_GAMMA
			p_VEGA


Formula:
Calls FX_GK_OPTION_SENS

p_SPOT_DATE = the spot date where the option value is evaluated
p_MATURITY_DATE = the maturity date where the option expires
p_CCY_DOM = domestic currency
p_CCY_FOR = foreign currency
p_RATE_DOM = domestic risk free interest rate.
p_RATE_TYPE_DOM/FOR = the p_RF_RATE_DOM/FOR rate's type. 'S' for Simple
 Rate. 'C' for Continuous Rate, and 'P' for Compounding Rate.
Default value = 'S' (Simple IR)
p_DAY_COUNT_BASIS_DOM/FOR = day count basis for p_RF_RATE_DOM/FOR.
p_RATE_FOR = foreign risk free interest rate.
p_SPOT_RATE = the current market exchange rate = the value of one unit
of the foreign currency measured in the domestic currency.
p_STRIKE_RATE = the strike price agreed in the option.
p_VOLATILITY = volatility
p_COMPOUND_FREQ_DOM/FOR = frequencies of discretely compounded input/output
rate. This is only necessary if p_RATE_TYPE_DOM/FOR is 'P'.
---------------------------------------------------------------*/


PROCEDURE FX_GK_OPTION_SENS_CV(p_rec_in	IN 	GK_OPTION_SENS_IN_REC_TYPE,
			       p_rec_out OUT NOCOPY	GK_OPTION_SENS_OUT_REC_TYPE);


-- added fhu 6/19/01
PROCEDURE FX_GK_OPTION_SENS(
                             l_days         IN NUMBER,
                             l_for_int_rate IN NUMBER,
                             l_dom_int_rate IN NUMBER,
                             l_spot_rate     IN NUMBER,
                             l_strike_rate   IN NUMBER,
                             vol IN NUMBER,
                             l_delta_call IN OUT NOCOPY NUMBER,
                             l_delta_put IN OUT NOCOPY NUMBER,
                             l_theta_call IN OUT NOCOPY NUMBER,
                             l_theta_put IN OUT NOCOPY NUMBER,
                             l_rho_call IN OUT NOCOPY NUMBER,
                             l_rho_put IN OUT NOCOPY NUMBER,
			     l_rho_f_call IN OUT NOCOPY NUMBER,
			     l_rho_f_put IN OUT NOCOPY NUMBER,
                             l_gamma IN OUT NOCOPY NUMBER,
                             l_vega IN OUT NOCOPY NUMBER);


--###############################################################
--#							      #
--#			Functions			      #
--#							      #
--###############################################################



-- mofified by  sankim 9/14/01
/*
Calculates the DELTA SPOT of a FX forward.  The Delta spot measures the
rate of change of the FX Forward Rate with respect to the Spot Rate.
See Deal Calculations HLD.

The arguments are defined as follows:
* p_CONTRA/BASE_CUR = Contra/Bid currency
* p_DF_CONTRA_BID/ASK = discount factor for the contra currency(Bid and Ask
side)
* p_DF_BASE_BID/ASK = discount factor for the base currency(Bid and Ask side)
* p_DF_USD_BID/ASK = discount factor for the USD(Bid and Ask side) required
only if USD is not Base or Contra
Returned:
* p_DELTA = delta spot(bid and ask returned as xtr_md_num_table[2]
         (BID side = xtr_md_num_table[1],ASK side = xtr_md_num_table[2]))
All of USD discount factor parameters defaults to null because they are not
required if Base or Contra currency is USD. They are required if USD is not
Base or Contra However, if insufficient input is provided, error will be
raised. Because of the optional parameters, to use this function, the caller
can just pass in 6 parameters instead of 8, not passing in the last two USD
discount factors if they are not necessary.If it makes it easier, feel free to
pass values to all six discount factor parameters.  This procedure will only
use the relevant parameters and ignore the rest.
 */
FUNCTION FX_FORWARD_DELTA_SPOT(p_contra_cur IN VARCHAR2,
                               p_base_cur IN VARCHAR2,
                               p_df_contra_bid IN NUMBER,
                               p_df_contra_ask IN NUMBER,
			       p_df_base_bid IN NUMBER,
 			       p_df_base_ask IN NUMBER,
                               p_df_usd_bid IN NUMBER DEFAULT NULL,
			       p_df_usd_ask IN NUMBER DEFAULT NULL)
	RETURN XTR_MD_NUM_TABLE;


--modified sankim 9/18/01
/*
Calculates the RHO, DELTA CONTRA/BASE INTEREST RATE of a FX forward.
See Deal Calculations HLD.
Example for FX: CHFGBP -> CHF = Base Currency
               GBP = Contra Currency
parameters
* p_OUT = 'C' if want p_RHO to be rho contra, 'B' if want p_RHO to be rho base,
          or 'D' if want both
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
Returned:
* p_RHO (BID/ASK) indicates the bid/ask side of rho(bid and ask returned as
xtr_md_num_table[2](BID side = xtr_md_num_table[1],
                    ASK side = xtr_md_num_table[2]))
 if p_OUT ='D' then the returned value is as following:
p_RHO  xtr_md_num_table[4](Base BID side =  xtr_md_num_table[1],
                           Base ASK side =  xtr_md_num_table[2],
                           Contra BID side =  xtr_md_num_table[3],
                           Contra ASK side =  xtr_md_num_table[4])

Calls XTR_FX_FORMULAS.FX_FORWARD_RATE_CV  (see def of fx_forward_rate above)
*/


FUNCTION FX_FORWARD_RHO(p_out IN VARCHAR2,
                        p_spot_rate_base_bid IN NUMBER DEFAULT 1,
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



/*  SENSITIVITIES of FX OPTION -- See FX_GK_OPTION_PRICE procedure */

/*************** Fair Value Calculations *******/


PROCEDURE get_base_contra(
          p_base  IN OUT NOCOPY VARCHAR2,
          p_contra  IN OUT NOCOPY VARCHAR2,
          p_reverse  OUT NOCOPY BOOLEAN);


PROCEDURE fv_fxo(p_price_model 		IN 	VARCHAR2,
		p_deal_subtype 		IN 	VARCHAR2,
		p_option_type 		IN 	VARCHAR2,
		p_set_code   		IN 	VARCHAR2,
		p_for_ccy		IN	VARCHAR2,
		p_premium_ccy		IN	VARCHAR2,
		p_buy_ccy    		IN 	VARCHAR2,
		p_sell_ccy   		IN 	VARCHAR2,
		p_interpolation_method 	IN	VARCHAR2,
		p_spot_date		IN	DATE,
		p_future_date		IN	DATE,
		p_strike_price		IN	NUMBER,
		p_for_amount		IN	NUMBER,
		p_side			IN	OUT NOCOPY 	VARCHAR2,
		p_forward_rate		IN	OUT NOCOPY 	NUMBER,
		p_fair_value		IN	OUT NOCOPY	NUMBER);


PROCEDURE fv_fx (p_price_model		IN	VARCHAR2,
		p_set_code		IN	VARCHAR2,
		p_buy_ccy		IN	VARCHAR2,
		p_sell_ccy		IN	VARCHAR2,
		p_sob_ccy		IN	VARCHAR2,
		p_interpolation_method	IN	VARCHAR2,
		p_spot_date		IN	DATE,
		p_future_date		IN	DATE,
		p_buy_amount		IN	NUMBER,
		p_sell_amount		IN	NUMBER,
		p_side			IN	OUT NOCOPY	VARCHAR2,
		p_forward_rate		IN	OUT NOCOPY	NUMBER,
		p_fair_value		IN	OUT NOCOPY	NUMBER);



END QRM_FX_FORMULAS;

 

/
