--------------------------------------------------------
--  DDL for Package XTR_REVAL_PROCESS_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_REVAL_PROCESS_P" AUTHID CURRENT_USER as
/* $Header: xtrrevls.pls 120.7 2005/06/29 10:24:37 rjose ship $ */
-----------------------------------------------------------------------------------------------------------------
-- Global variable to hold status
G_STATUS NUMBER := null;

-- constant for PARAMETER_CODE in xtr_company_parameters
C_FRA_DISCOUNT_METHOD constant VARCHAR2(30) := 'REVAL_FRADM';
C_FX_DISCOUNT_METHOD constant VARCHAR2(30) := 'REVAL_FXDSM';
C_FUTURE_DATE_NI constant VARCHAR2(30) := 'REVAL_FDNDR';
C_INCOST constant VARCHAR2(20) := 'REVAL_INCTC';
C_EXCHANGE_RATE_TYPE constant VARCHAR2(30) := 'ACCNT_EXRTP';
C_DEAL_SETTLE_ACCOUNTING constant VARCHAR2(30) := 'ACCNT_TSDTM';
C_MARKET_DATA_SET constant VARCHAR2(30) := 'REVAL_DFMDS';
C_BEGIN_FV        constant VARCHAR2(30) := 'REVAL_FABEV';
C_BTEST		  constant VARCHAR2(30) := 'ACCNT_BTEST';

-- constant for xtr_deals.CALC_BASIS
C_CALC_BASIS_Y constant VARCHAR2(10) := 'YIELD';
C_CALC_BASIS_D constant VARCHAR2(10) := 'DISCOUNT';
C_CALC_BASIS_I constant VARCHAR2(10) := 'INT';

-- constant for market data set and etc.
C_SOURCE constant VARCHAR2(2) := 'R';
C_HIST_SOURCE constant VARCHAR2(2) := 'C';
C_INTERPOL_LINER constant VARCHAR2(2) := 'D';
C_YEAR_RATE constant VARCHAR2(1) := 'Y';

-- indicator for XTR_MARKET_DATA_P.get_md_from_set()
C_YIELD_IND constant VARCHAR2(1) := 'Y';
C_DISCOUNT_IND constant VARCHAR2(2) := 'DR';
C_DISCOUNT_FAC constant VARCHAR2(2) := 'D';
C_VOLATILITY_IND constant VARCHAR2(1) := 'V';
C_SPOT_RATE_IND constant VARCHAR2(1) := 'S';
--C_FORWARD_RATE_IND constant VARCHAR2(1) := 'F';
C_BOND_IND constant VARCHAR2(1) := 'B';
C_STOCK_IND constant VARCHAR2(1) := 'T';

-- pricing model, value from xtr_price_models
C_P_MODEL_DIS constant VARCHAR2(30) := 'DISC_METHOD';
C_P_MODEL_GARMAN constant VARCHAR2(30) := 'GARMAN_KOHL';
C_P_MODEL_FXO constant VARCHAR2(30) := 'FX_FORWARD';
C_P_MODEL_BLACK constant VARCHAR2(30) := 'BLACK';
C_P_MODEL_FRA_Y constant VARCHAR2(30) := 'FRA_YIELD';
C_P_MODEL_FRA_D constant VARCHAR2(30) := 'FRA_DISC';
C_P_MODEL_MARKET constant VARCHAR2(30) := 'MARKET';
C_P_MODEL_FACE constant VARCHAR2(30) := 'FACE_VALUE';
C_P_MODEL_TMM_DIS constant VARCHAR2(30) := 'DISC_CASHFLOW';

-- Bond amount type
C_REALMTM constant VARCHAR2(7) := 'REALMTM';
C_REALAMC constant VARCHAR2(7) := 'REALAMC';
C_UNREAL constant  VARCHAR2(7) := 'UNREAL';

-- define some exception
e_no_pre_batch	       EXCEPTION;
e_batch_been_run       EXCEPTION;
e_invalid_dealno       EXCEPTION;
e_invalid_dealtype     EXCEPTION;
e_invalid_transno      EXCEPTION;
e_invalid_price_model  EXCEPTION;
e_invalid_deal_subtype EXCEPTION;
e_invalid_code         EXCEPTION;
e_date_order_error     EXCEPTION;

-- reset the g_call_by_form variable, must call before
-- running the concurrent program
g_call_by_form    BOOLEAN := TRUE;
PROCEDURE set_call_by_curr;
PROCEDURE set_call_by_form;

TYPE xtr_revl_rec is record
                 (company_code VARCHAR2(7),
                  deal_no      NUMBER,
                  deal_type    VARCHAR2(7),
                  deal_subtype VARCHAR2(30),
                  product_type VARCHAR2(10),
                  batch_id     NUMBER,
		  period_start DATE,
		  period_end   DATE,
		  batch_start  DATE,
                  revldate     DATE, -- Batch end date
                  fair_value   NUMBER,
		  init_fv      NUMBER,
		  reval_rate   NUMBER,
		  deal_ex_rate_one NUMBER,
		  deal_ex_rate_two NUMBER,
		  reval_ex_rate_one NUMBER,
	          reval_ex_rate_two NUMBER,
		  reval_fx_fwd_rate NUMBER,
                  trans_no     NUMBER,
                  ow_type      VARCHAR2(15),
                  ow_value     NUMBER,
		  year_calc_type VARCHAR2(15),
		  year_basis    NUMBER,
		  discount_yield VARCHAR2(1),
		  deal_date	DATE,
		  start_date	DATE,
		  maturity_date DATE,
		  expiry_date	DATE,
		  settle_action VARCHAR2(7),
		  settle_date	DATE,
		  settle_amount NUMBER,
		  premium_action	VARCHAR2(7),
	  	  premium_amount	NUMBER,
		  market_data_set	VARCHAR2(30),
		  pricing_model		VARCHAR2(30),
		  brokerage_amount	NUMBER,
		  portfolio_code	VARCHAR2(30),
		  transaction_rate	NUMBER,
		  currencya		VARCHAR2(15),
		  currencyb		VARCHAR2(15),
		  effective_date	DATE,
		  contract_code		VARCHAR2(30),
		  face_value		NUMBER,
		  fxo_sell_ref_amount	NUMBER,
		  reval_ccy		VARCHAR2(15),
		  cap_or_floor		VARCHAR2(7),
		  account_no		VARCHAR2(20),
		  swap_ref		VARCHAR2(10),
		  sob_ccy      		VARCHAR2(15),
		  ex_rate_type		VARCHAR2(30),
		  eligible_date 	DATE,
		  ni_disc_amount	NUMBER,
		  status_code           VARCHAR2(30),
		  quantity		NUMBER,
		  remaining_quantity    NUMBER
		  );

TYPE xtr_eligible_rec is record(
        ACCOUNT_NO		VARCHAR2(20),
	BROKERAGE_AMOUNT	NUMBER,
	CAP_OR_FLOOR		VARCHAR2(7),
	COMPANY_CODE		VARCHAR2(7),
	CONTRACT_CODE		VARCHAR2(30),
	CURRENCYA		VARCHAR2(15),
	CURRENCYB 		VARCHAR2(15),
	DEAL_DATE		DATE,
	DEAL_NO			NUMBER,
	DEAL_SUBTYPE		VARCHAR2(30),
	DEAL_TYPE		VARCHAR2(7),
	DISCOUNT_YIELD		VARCHAR2(1),
	EFFECTIVE_DATE		DATE,
	ELIGIBLE_DATE		DATE,
	EXPIRY_DATE		DATE,
	FACE_VALUE		NUMBER,
	FX_REVAL_PRINCIPAL_BAL	NUMBER,
	FXO_SELL_REF_AMOUNT	NUMBER,
	MARKET_DATA_SET		VARCHAR2(30),
	MATURITY_DATE		DATE,
	PORTFOLIO_CODE		VARCHAR2(30),
	PREMIUM_ACTION		VARCHAR2(7),
	PREMIUM_AMOUNT		NUMBER,
	PREMIUM_CCY		VARCHAR2(15),
	PRICING_MODEL		VARCHAR2(30),
	PRODUCT_TYPE		VARCHAR2(10),
	SETTLE_ACTIOn		VARCHAR2(7),
	SETTLE_AMOUNT		NUMBER,
	SETTLE_DATE		DATE,
	START_DATE		DATE,
        STATUS_CODE		VARCHAR2(30),
	SWAP_REF		VARCHAR2(10),
	TRANSACTION_NO		NUMBER,
	TRANSACTION_RATE	NUMBER,
	YEAR_BASIS		NUMBER,
	YEAR_CALC_TYPE		VARCHAR2(15));

TYPE xtr_bond_rec is record
                 (batch_id	NUMBER,
		  deal_no       NUMBER,
		  cross_ref_no	NUMBER,
		  face_value	NUMBER,
		  init_fv	NUMBER,
		  amc_real	NUMBER,
		  mtm_real	NUMBER,
		  resale_rec_date	DATE,
		  clean_px	NUMBER,
		  maturity_face_value   NUMBER,
		  start_face_value NUMBER,
		  start_fair_value NUMBER,
		  cum_unrel_gl  NUMBER,
		  cum_unrel_gl_bal NUMBER,
		  pre_gl_rate   NUMBER);

TYPE xtr_stock_rec is record
		(batch_id 	NUMBER,
		 deal_no	NUMBER,
		 cross_ref_no	NUMBER,
		 fair_value	NUMBER,
		 init_cons	NUMBER,
		 quantity	NUMBER,
		 init_quantity  NUMBER,
		 remaining_quantity	NUMBER,
		 price_per_share	NUMBER,
		 prev_price	NUMBER,
		 real_gl	NUMBER,
		 resale_rec_date       DATE,
		 cum_unrel_gl	NUMBER,
		 pre_gl_rate	NUMBER);

TYPE xtr_revl_fx_rate is record(
     num_days          NUMBER,
     year_basis        NUMBER,
     spot_rate         NUMBER,
     base_yield_rate   NUMBER,
     contra_yield_rate NUMBER,
     fx_forward_rate   NUMBER);

TYPE xtr_prev_hedge is record(
     fair_value	NUMBER,
     rate	NUMBER,
     sob_rate	NUMBER,
     cum_pl     NUMBER);


TYPE err_log is record(
    line_num  NUMBER,
    deal_id   NUMBER,
    trans_no  NUMBER,
    deal_type VARCHAR2(7),
    err_warn  NUMBER,  -- new column to specify whether it's an error (1) or warning (0)
    log VARCHAR2(200));

TYPE t_errlog is table of err_log index by binary_integer;

/* the t_log is a global array to hold error and exception
information, the t_log.line_num should start with 1 and
increment by 1 as array grows, the whole array should
dump to output log when concurrent program exit
*/
t_log  t_errlog;

-- insert to array
/* t_log_insert commented by Ilavenil for 2566462*/
--PROCEDURE t_log_insert(rlog IN err_log);
-- write to output file
PROCEDURE t_log_dump;
-- array initialization
PROCEDURE t_log_init;
-- return the size of t_log
FUNCTION t_log_count return NUMBER;

PROCEDURE GET_ALL_REVAL_RATES (l_company         IN VARCHAR2,
			       l_start_date      IN DATE,
                               l_end_date        IN DATE,
                               l_upgrade_batch   IN VARCHAR2,
			       l_batch_id        IN OUT NOCOPY NUMBER);

PROCEDURE CALC_REVALS(
		      errbuf OUT NOCOPY VARCHAR2,
     	              retcode OUT NOCOPY NUMBER,
            	      p_company IN VARCHAR2,
	              p_batch_id IN NUMBER);

PROCEDURE xtr_revl_main(
		        p_batch_id IN NUMBER,
		        rec IN OUT NOCOPY xtr_revl_rec,
		        r_rd IN OUT NOCOPY XTR_REVALUATION_DETAILS%rowtype,
		        retcode  OUT NOCOPY NUMBER);

PROCEDURE xtr_get_deal_value(
          l_tmp  IN xtr_eligible_rec,
          rec    IN OUT NOCOPY xtr_revl_rec,
	  r_rd   OUT NOCOPY XTR_REVALUATION_DETAILS%rowtype);

PROCEDURE xtr_revl_get_fairvalue(
		           rec IN OUT NOCOPY xtr_revl_rec,
			   fair_value OUT NOCOPY NUMBER,
		           retcode  OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_get_unrel_pl(
		         rec IN OUT NOCOPY xtr_revl_rec,
		         unrel_pl_value OUT NOCOPY NUMBER,
			 cum_pl_value OUT NOCOPY NUMBER,
		         retcode  OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_exchange_rate(
			rec IN OUT NOCOPY xtr_revl_rec,
			retcode OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_get_curr_gl(
			rec IN OUT NOCOPY xtr_revl_rec,
                        unrel_pl_value IN NUMBER,
                        rel_pl_value IN NUMBER,
                        fv_sob_amt OUT NOCOPY NUMBER,
                        rel_sob_gl OUT NOCOPY NUMBER,
                        unrel_sob_gl OUT NOCOPY NUMBER,
			currency_gl OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_tmm_curr_gl(
		        rec IN OUT NOCOPY xtr_revl_rec,
		        rel_currency_gl OUT NOCOPY NUMBER,
			unrel_currency_gl OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_ca_curr_gl(
			rec IN OUT NOCOPY xtr_revl_rec,
			retcode OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_ig_curr_gl(
                        rec IN OUT NOCOPY xtr_revl_rec,
                        retcode OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_onc_curr_gl(
                        rec IN OUT NOCOPY xtr_revl_rec,
                        retcode OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_unreal_log(
		     rec IN xtr_revl_rec,
		     unrel_pl_value IN NUMBER,
		     cum_pl_value IN NUMBER,
                     fv_sob_amt IN NUMBER,
		     unrel_sob_gl IN NUMBER,
		     currency_gl IN NUMBER,
		     r in XTR_REVALUATION_DETAILS%rowtype,
		     retcode  OUT NOCOPY NUMBER,
                     p_hedge_flag IN VARCHAR2 DEFAULT NULL);

PROCEDURE xtr_revl_real_log (
                     rec IN xtr_revl_rec,
                     rel_pl_value IN NUMBER,
		     fv_sob_amt IN NUMBER,
                     rel_sob_gl IN NUMBER,
                     currency_gl IN NUMBER,
                     r in XTR_REVALUATION_DETAILS%rowtype,
                     retcode  OUT NOCOPY NUMBER);

PROCEDURE xtr_insert_event(
		     p_batch_id  IN NUMBER);

PROCEDURE xtr_get_fv_from_batch(
		     rec IN xtr_revl_rec,
		     p_fair_value OUT NOCOPY NUMBER,
		     p_ni_disc_amt OUT NOCOPY NUMBER,
		     p_cumm_unrel_gl OUT NOCOPY NUMBER,
		     p_reval_rate  OUT NOCOPY NUMBER);

FUNCTION xtr_get_pre_batchid(
          rec IN xtr_revl_rec) return NUMBER;

FUNCTION xtr_calc_interest(
          p_principle  IN NUMBER,
          p_start_date IN DATE,
          p_end_date IN DATE,
          p_rate IN NUMBER,
          p_day_count_basis IN VARCHAR2,
	  p_day_count_type IN VARCHAR2 DEFAULT NULL,
          p_first_trans_flag IN VARCHAR2 DEFAULT NULL) return NUMBER;

PROCEDURE xtr_revl_getrate_fx(
            rec IN xtr_revl_rec,
	    p_hedge_flag IN varchar2,
            r_fx_rate OUT NOCOPY xtr_revl_fx_rate);

PROCEDURE xtr_revl_fv_fx(
            rec IN xtr_revl_rec,
            r_fx_rate IN xtr_revl_fx_rate,
	    p_hedge_flag IN varchar2,
            fair_value OUT NOCOPY NUMBER,
            p_sob_curr_rate OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_fx_curr_gl(
            rec IN OUT NOCOPY xtr_revl_rec,
	    p_hedge_flag IN VARCHAR2,
	    p_realized  IN BOOLEAN,
            currency_gl OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_fv_fxh (rec IN OUT NOCOPY xtr_revl_rec,
			   r_rd IN OUT NOCOPY XTR_REVALUATION_DETAILS%rowtype);

PROCEDURE xtr_revl_fv_hedge (rec IN OUT NOCOPY xtr_revl_rec);

PROCEDURE xtr_hedge_gl_rate (rec IN OUT NOCOPY xtr_revl_rec,
                             p_start_date IN DATE,
                             p_end_date IN DATE,
                             p_complete_flag IN VARCHAR2);

PROCEDURE xtr_hedge_fwd_rate(rec IN OUT NOCOPY xtr_revl_rec,
                             p_start_date IN DATE,
                             p_end_date IN DATE,
                             p_complete_flag IN VARCHAR2);

PROCEDURE xtr_get_prev_fv_rate(rec IN OUT NOCOPY xtr_revl_rec,
	                       r_prev_hedge OUT NOCOPY xtr_prev_hedge);

PROCEDURE xtr_revl_getprice_fxo(
            rec IN OUT NOCOPY xtr_revl_rec,
	    p_spot_rate IN OUT NOCOPY NUMBER,
            p_put_price IN OUT NOCOPY NUMBER,
            p_call_price IN OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_fv_fxo(
            rec IN xtr_revl_rec,
	    p_spot_rate IN NUMBER,
            p_put_price IN NUMBER,
            p_call_price IN NUMBER,
            fair_value OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_getprice_fwd(
            rec IN xtr_revl_rec, has_transno IN BOOLEAN,
            fwd_rate OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_fv_fra(
            rec IN OUT NOCOPY xtr_revl_rec,
            p_fra_price IN NUMBER,
            fair_value OUT NOCOPY NUMBER);

PROCEDURE xtr_get_base_contra(
          p_base  IN OUT NOCOPY VARCHAR2,
          p_contra  IN OUT NOCOPY VARCHAR2,
          p_reverse  OUT NOCOPY BOOLEAN);

PROCEDURE xtr_ni_eff_interest(
	  rec IN xtr_revl_rec,
	  pre_disc_amt IN NUMBER,
	  disc_amount  OUT NOCOPY NUMBER,
	  eff_interest OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_mds_init(
   rec       OUT NOCOPY XTR_MARKET_DATA_P.md_from_set_in_rec_type,
   p_md_set_code          VARCHAR2,
   p_source               VARCHAR2,
   p_indicator            VARCHAR2,
   p_spot_date            DATE,
   p_future_date          DATE,
   p_ccy                  VARCHAR2,
   p_contra_ccy           VARCHAR2,
   p_day_count_basis_out  VARCHAR2,
   p_interpolation_method VARCHAR2,
   p_side                 VARCHAR2,
   p_batch_id             NUMBER,
   p_bond_code            VARCHAR2);

PROCEDURE set_err_log(retcode OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_fv_ni(
            rec IN xtr_revl_rec,
            fair_value IN OUT NOCOPY NUMBER,
            p_revl_rate IN OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_getrate_ni(
	    rec IN xtr_revl_rec,
            p_rate_type IN VARCHAR2,
            p_market_set IN VARCHAR2,
            p_batch_id IN NUMBER,
            p_ccy IN VARCHAR2,
            p_spot_date IN DATE,
            p_start_date IN DATE,
            p_end_date IN DATE,
            p_day_count IN VARCHAR2,
            p_side IN VARCHAR2,
            p_deal_basis IN VARCHAR2,
            p_int_rate OUT NOCOPY NUMBER,
            p_day OUT NOCOPY NUMBER,
            p_year OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_getprice_bond(
	   rec IN xtr_revl_rec,
           p_bond_clean_price OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_fv_bond(
	   rec IN OUT NOCOPY xtr_revl_rec,
	   p_clean_price IN NUMBER,
	   fair_value OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_bond_realamc(rec IN OUT NOCOPY xtr_revl_rec,
				bo_rec IN xtr_bond_rec);

PROCEDURE xtr_revl_bond_realmtm(rec IN OUT NOCOPY xtr_revl_rec,
                                bo_rec IN xtr_bond_rec,
				p_resale IN BOOLEAN);

PROCEDURE xtr_revl_bond_unreal(rec IN OUT NOCOPY xtr_revl_rec,
                               bo_rec IN OUT NOCOPY xtr_bond_rec,
                               p_resale IN BOOLEAN,
			       p_overwrite IN BOOLEAN);

PROCEDURE xtr_revl_fv_iro(
            rec IN OUT NOCOPY xtr_revl_rec,
            fair_value IN OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_fv_tmm(
            rec IN OUT NOCOPY xtr_revl_rec,
            fair_value IN OUT NOCOPY NUMBER,
            p_accum_int_sum IN OUT NOCOPY NUMBER,
            p_fwd_rate IN NUMBER);

PROCEDURE xtr_revl_present_value_tmm(
            rec IN xtr_revl_rec,
            p_batch_id IN NUMBER,
            p_day_count IN VARCHAR2,
            p_revl_date IN DATE,
            p_start_date IN DATE,
            p_future_val IN NUMBER,
            p_ccy IN VARCHAR2,
            p_market_set IN VARCHAR2,
            p_side IN VARCHAR2,
            p_present_value OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_fv_stock(rec in OUT NOCOPY xtr_revl_rec,
			    p_price IN NUMBER,
			    fair_value OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_stock_real(rec IN OUT NOCOPY xtr_revl_rec,
			      st_rec IN xtr_stock_rec);

PROCEDURE xtr_revl_stock_unreal(rec IN OUT NOCOPY xtr_revl_rec,
			        st_rec IN xtr_stock_rec,
				p_resale IN BOOLEAN,
				p_overwrite IN BOOLEAN,
				unrel_pl_value IN OUT NOCOPY NUMBER,
			        cum_pl_value IN OUT NOCOPY NUMBER,
				currency_gl IN OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_getprice_stock(
           rec IN xtr_revl_rec,
           p_stock_price OUT NOCOPY NUMBER);


/* for debug */
PROCEDURE dump_xtr_revl_rec(
            p_name IN VARCHAR2,
            rec IN xtr_revl_rec);

PROCEDURE dump_xtr_mds_rec(
   p_name IN VARCHAR2,
   rec in XTR_MARKET_DATA_P.md_from_set_in_rec_type);

FUNCTION xtr_init_fv(
          rec IN xtr_revl_rec
) return NUMBER;

Procedure      xtr_ins_init_fv
(p_company_code in XTR_PARTY_INFO.PARTY_CODE%TYPE,
 p_deal_no in XTR_DEALS.DEAL_NO%TYPE,
 p_deal_type in XTR_DEALS.DEAL_TYPE%TYPE,
 p_transaction_no in XTR_DEALS.TRANSACTION_NO%TYPE,
 p_day_count_type in XTR_DEALS.DAY_COUNT_TYPE%TYPE DEFAULT NULL
);

PROCEDURE xtr_end_fv(
          rec IN OUT NOCOPY xtr_revl_rec,
	  end_fv  OUT NOCOPY  NUMBER);

PROCEDURE xtr_revl_fv_irs(
            rec IN OUT NOCOPY xtr_revl_rec,
            fair_value IN OUT NOCOPY NUMBER);

PROCEDURE xtr_revl_get_mds(
    p_mds IN OUT NOCOPY VARCHAR2,
    rec   IN xtr_revl_rec);

PROCEDURE xtr_first_reval(
    rec   IN xtr_revl_rec,
    p_out OUT NOCOPY BOOLEAN);


PROCEDURE LOG_MSG
          (P_TEXT IN VARCHAR2 DEFAULT NULL,
           P_VALUE IN VARCHAR2 DEFAULT NULL);
------------------------------------------------------------------------------

PROCEDURE UPDATE_FX_REVALS (l_deal_no        IN NUMBER,
                            l_transaction_no IN NUMBER,
                            l_deal_type      IN VARCHAR2);
end XTR_REVAL_PROCESS_P;

 

/
