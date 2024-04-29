--------------------------------------------------------
--  DDL for Package Body QRM_PA_CALCULATION_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QRM_PA_CALCULATION_P" AS
/* $Header: qrmpacab.pls 120.39 2006/02/07 07:39:02 csutaria ship $ */


PROCEDURE run_analysis_cp (errbuf		OUT NOCOPY	VARCHAR2,
			   retcode		OUT NOCOPY	VARCHAR2,
			   p_source		IN	VARCHAR2,
			   p_analysis_name	IN	VARCHAR2,
			   p_date		IN	VARCHAR2)
IS

p_ref_datetime DATE := NVL(TO_DATE(p_date, 'YYYY/MM/DD HH24:MI:SS'), SYSDATE);

BEGIN
--   XTR_RISK_DEBUG_PKG.start_debug('/sqlcom/out/findv115', 'fhpatest.dbg');
--   XTR_RISK_DEBUG_PKG.start_debug;
   XTR_RISK_DEBUG_PKG.start_conc_prog;
   IF (g_proc_level>=g_debug_level) THEN
      XTR_RISK_DEBUG_PKG.dpush(null,'QRM_PA_CALCULATIONS_P.RUN_ANALYSIS_CP');
      XTR_RISK_DEBUG_PKG.dlog('run_analysis_cp: ' || 'source is', p_source);
      XTR_RISK_DEBUG_PKG.dlog('run_analysis_cp: ' || 'analysis name', p_analysis_name);
      XTR_RISK_DEBUG_PKG.dlog('run_analysis_cp: ' || 'ref date', p_ref_datetime);
   END IF;
   run_analysis(retcode, p_source, p_analysis_name, p_ref_datetime);
   IF (g_proc_level>=g_debug_level) THEN
      XTR_RISK_DEBUG_PKG.dpop(null,'QRM_PA_CALCULATIONS_P.RUN_ANALYSIS_CP');
   END IF;
   XTR_RISK_DEBUG_PKG.stop_conc_debug;
END run_analysis_cp;



PROCEDURE run_analysis_am (p_analysis_names IN	SYSTEM.QRM_VARCHAR_TABLE,
			   p_ref_datetime    IN	DATE)

IS

    CURSOR check_analysis (p_name VARCHAR2) IS
       SELECT analysis_name, status, process_id
       FROM qrm_analysis_settings
       WHERE analysis_name=p_name and history_flag='C';

    p_request_id	NUMBER;
    p_source		VARCHAR2(2) := 'AM';
    p_msg		VARCHAR2(50);
    p_settings		check_analysis%ROWTYPE;


    p_go_calculate	BOOLEAN := TRUE;
    -- for FND_CONCURRENT.get_request_status
    rphase  		VARCHAR2(80);
    rstatus		VARCHAR2(80);
    dphase		VARCHAR2(30);
    dstatus		VARCHAR2(30);
    message		VARCHAR2(240);
    call_status		BOOLEAN;

BEGIN

--    XTR_RISK_DEBUG_PKG.start_debug('/sqlcom/out/findv115','fhpatest.dbg');
--    XTR_RISK_DEBUG_PKG.start_debug;
    IF (g_proc_level>=g_debug_level) THEN --bug 3236479
      XTR_RISK_DEBUG_PKG.dpush(null,'QRM_PA_CALCULATIONS_P.RUN_ANALYSIS_AM');
    END IF;

    IF FND_MSG_PUB.count_msg > 0 THEN
       FND_MSG_PUB.initialize;
    END IF;

    FOR i IN 1..p_analysis_names.COUNT LOOP
	IF (g_proc_level>=g_debug_level) THEN
	   xtr_risk_debug_pkg.dlog('run_analysis_am: ' || 'analysis name: '||p_analysis_names(i));
	END IF;
	OPEN check_analysis(p_analysis_names(i));
	FETCH check_analysis INTO p_settings;
	IF (check_analysis%NOTFOUND) THEN
	     FND_MESSAGE.set_name('QRM', 'QRM_ANA_NO_SETTING');
	     FND_MESSAGE.set_token('ANALYSIS_NAME', p_settings.analysis_name);
	     FND_MSG_PUB.add;
	     IF (g_proc_level>=g_debug_level) THEN
	        xtr_risk_debug_pkg.dlog('run_analysis_am: ' || 'analysis not found');
	     END IF;
	ELSIF (p_settings.status = '3') THEN
	     call_status := FND_CONCURRENT.get_request_status(
		p_settings.process_id,'','', rphase, rstatus, dphase,
		dstatus, message);
	     IF (g_proc_level>=g_debug_level) THEN
	        XTR_RISK_DEBUG_PKG.dlog('run_analysis_am: ' || 'dphase is', dphase);
	     END IF;
	     IF (dphase IN ('PENDING', 'RUNNING', 'INACTIVE')) THEN
	        FND_MESSAGE.set_name('QRM', 'QRM_ANA_RUN_IN_PROGRESS');
	        FND_MESSAGE.set_token('ANALYSIS', p_settings.analysis_name);
	        FND_MSG_PUB.add;
	        IF (g_proc_level>=g_debug_level) THEN
	           xtr_risk_debug_pkg.dlog('run_analysis_am: ' || 'status is 3');
	        END IF;
		p_go_calculate := FALSE;
	     ELSE
		p_go_calculate := TRUE;
	     END IF;
	 ELSIF (p_go_calculate = TRUE) THEN
	        p_request_id := FND_REQUEST.submit_request('QRM', 'QRMPACAL',
		   NULL, NULL, FALSE,
		   -- concurrent program args
		   p_source,
		   p_analysis_names(i),
		   to_char(p_ref_datetime,'YYYY/MM/DD HH24:MI:SS'));
	        IF (g_proc_level>=g_debug_level) THEN
	           XTR_RISK_DEBUG_PKG.dlog('run_analysis_am: ' || 'request id: '||p_request_id);
	        END IF;
	        IF (p_request_id = 0) THEN
	           FND_MESSAGE.RETRIEVE(p_msg);
--	           FND_MESSAGE.ERROR;
	           IF (g_proc_level>=g_debug_level) THEN
	              XTR_RISK_DEBUG_PKG.dlog('run_analysis_am: ' || 'error msg: '||p_msg);
	           END IF;
                   FND_MESSAGE.set_name('QRM', 'QRM_ANA_SUBMIT_ERROR');
	           FND_MESSAGE.set_token('ANALYSIS', p_analysis_names(i));
	           FND_MSG_PUB.add;
	           IF (g_proc_level>=g_debug_level) THEN
	              xtr_risk_debug_pkg.dlog('run_analysis_am: ' || 'request not submitted');
	           END IF;
	        ELSE
		   IF (g_proc_level>=g_debug_level) THEN
		      xtr_risk_debug_pkg.dlog('run_analysis_am: ' || 'request submitted: '||p_request_id);
		   END IF;
		   -- this updates the history_flag='C' row only!
		   UPDATE qrm_analysis_settings
	     	   SET status='3',
		       process_id=p_request_id,
	               last_run_date=p_ref_datetime,
		       dirty = 'N'
	           WHERE analysis_name=p_analysis_names(i);
		   COMMIT;
	        END IF;
	END IF;
	CLOSE check_analysis;
    END LOOP;

    IF (g_proc_level>=g_debug_level) THEN --bug 3236479
      XTR_RISK_DEBUG_PKG.dpop(null,'QRM_PA_CALCULATIONS_P.RUN_ANALYSIS_AM');
    END IF;

    XTR_RISK_DEBUG_PKG.stop_debug;
END run_analysis_am;



PROCEDURE run_analysis (retcode		OUT NOCOPY	VARCHAR2,
			p_source	IN	VARCHAR2,
			p_analysis_name IN	VARCHAR2,
			p_ref_datetime	IN	DATE)
IS

   -- TRUNC p_ref_date b.c. in most cases will only need date
   p_ref_date DATE := TRUNC(p_ref_datetime);

   CURSOR get_settings(p_a_name VARCHAR2) IS
      SELECT *
      FROM qrm_analysis_settings
      WHERE analysis_name = p_a_name and history_flag='C';

   CURSOR get_attributes (p_a_name VARCHAR2) IS
      SELECT *
      FROM qrm_analysis_atts
      WHERE analysis_name= p_a_name and history_flag='C';

   CURSOR get_filter_where_clause(p_filter_name VARCHAR2) IS
      SELECT where_clause
      FROM qrm_filters
      WHERE filter_name = p_filter_name;

   -- BUG 2945198 - sql bind
   CURSOR get_filter_bindings(p_filter_name VARCHAR2) IS
      SELECT row_number,value
      FROM qrm_filter_conditions
      WHERE filter_name = p_filter_name;

   CURSOR get_company_mds (p_company_code VARCHAR2) IS
      SELECT parameter_value_code
      FROM xtr_company_parameters_v
      WHERE company_code=p_company_code AND parameter_code='REVAL_DFMDS';

   CURSOR get_sob_ccy (p_company_code VARCHAR2) IS
      SELECT  sob.currency_code
      FROM gl_sets_of_books sob, xtr_party_info pinfo
      WHERE pinfo.party_code = p_company_code AND
	 pinfo.set_of_books_id = sob.set_of_books_id;

   CURSOR get_ig_day_count_basis(p_ccy VARCHAR2) IS
      SELECT NVL(ig_year_basis, 'ACTUAL/ACTUAL')
      FROM xtr_master_currencies_v
      WHERE currency = p_ccy;

   CURSOR deal_threshold_ok(p_deal_no NUMBER,p_trans_no NUMBER,mds VARCHAR2,
			p_threshold_date DATE) IS
      SELECT deal_calc_id
      FROM qrm_deal_calculations
      WHERE deal_no = p_deal_no AND transaction_no = p_trans_no AND
		market_data_set = mds AND
		last_md_calc_date >= p_threshold_date;

   CURSOR deal_calculated(p_deal_no NUMBER, p_trans_no NUMBER,
			mds VARCHAR2) IS
      SELECT *
      FROM qrm_deal_calculations
      WHERE deal_no = p_deal_no AND transaction_no = p_trans_no AND
		market_data_set = mds;

   CURSOR get_sequence_no IS
      SELECT qrm_deals_s.NEXTVAL
      FROM dual;


   CURSOR get_bond_coupon_start_date(p_bond_issue_code VARCHAR2,
				     p_ref_date DATE) IS
      SELECT max(coupon_date)
      FROM xtr_bond_coupon_dates
      WHERE coupon_date <= p_ref_date AND bond_issue_code = p_bond_issue_code;

   /*---------------------------------------------------------------------
	Cursors that access xtr_rollover_transactions_v, xtr_deals_v
	access valid deals because those deals numbers are first derived
	from qrm_current_deals_v.
   ----------------------------------------------------------------------*/

   -- gets current transaction
   CURSOR get_tmm_irs_rtmm_curr_trans(p_deal_no NUMBER,
		p_deal_type VARCHAR2, p_ref_date DATE) IS
      SELECT *
      FROM xtr_rollover_transactions_v
      WHERE deal_number=p_deal_no AND deal_type=p_deal_type AND
	start_date<=p_ref_date AND p_ref_date<maturity_date AND
	status_code<>'CANCELLED' AND status_code<>'CLOSED'
      ORDER BY start_date, maturity_date;

   -- for all current/future transactions of TMM/IRS/RTMM
   CURSOR get_tmm_irs_rtmm_trans(p_deal_no NUMBER, p_ref_date DATE) IS
      SELECT *
      FROM xtr_rollover_transactions_v
      WHERE deal_number=p_deal_no
	AND ((p_ref_date<start_date) OR
	(p_ref_date>=start_date AND p_ref_date<maturity_date)) AND
	status_code<>'CANCELLED' AND status_code<>'CLOSED'
      ORDER BY start_date, maturity_date;
		-- only look at future adjustments

   CURSOR get_bond_code(p_bond_issue VARCHAR2) IS
      SELECT ric_code, calc_type, year_calc_type, commence_date
      FROM xtr_bond_issues
      WHERE bond_issue_code = p_bond_issue AND ric_code IS NOT NULL;


   -- all current and future cashflows
   CURSOR get_bond_cashflows(p_deal_no NUMBER, p_ref_date DATE) IS
      SELECT rt.interest, d.interest_rate, rt.start_date, rt.maturity_date
      FROM xtr_rollover_transactions_v rt, xtr_deals_v d
      WHERE rt.deal_number=d.deal_no AND rt.deal_number=p_deal_no AND
	((p_ref_date<=rt.start_date) OR (p_ref_date>=rt.start_date AND
	  p_ref_date<rt.maturity_date)) AND
	rt.status_code<>'CANCELLED' AND rt.status_code<>'CLOSED'
	 -- only look at future coupons
      ORDER BY rt.maturity_date; --bug 2804548

/*   CURSOR get_last_trans_no(p_deal_no NUMBER) IS
      SELECT max(transaction_number)
      FROM xtr_rollover_transactions_v
      GROUP BY deal_number
      HAVING deal_number=p_deal_no; Bug 4965436 */

   CURSOR get_last_trans_no(p_deal_no NUMBER) IS
      SELECT max(transaction_number)
      FROM xtr_rollover_transactions_v
      WHERE deal_number=p_deal_no;

   e_duplicate_tb_rows EXCEPTION; --bug 2875633

   p_select_clause	VARCHAR2(1000) := 'SELECT deal_no, transaction_no, market_data_set, company_code, call_or_put, pricing_model, deal_ccy, buy_ccy, sell_ccy, ';

   -- IG deals: deal numbers recycled, ie. reused by using new trans numbers
   -- max trans number is the current one
   -- max trans number has balance=0 and interest is settled, deal is closed
   -- ONC: if principal adjust (mapped to start date)=0, exclude trans
   p_from_where_clause	VARCHAR2(3000) := ' FROM qrm_current_deals_v'||' WHERE ((deal_type<>''IG'' and (deal_type<>''BOND'' or (deal_type=''BOND'' and face_value<>0)) and (end_date is null or end_date >= '''||p_ref_date||''')) ';

   --start bug 2804548
   p_next_coupon_reset DATE;
   p_discount_factors_add1bp XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_annual_basis_frb_dur NUMBER;
   p_days_frb_dur NUMBER;
   p_1bp NUMBER := 0.01; --in terms of percentage
   p_yield_rate_add1bp NUMBER;
   p_tot_cf_add1bp NUMBER;
   p_actual_ytm NUMBER;
   p_sign_temp NUMBER;
   --end bug 2804548

   p_select_stmt	VARCHAR2(4000);
   p_appended_where	VARCHAR2(300);
   p_where_measure	VARCHAR2(100);
   p_from_date		DATE;
   p_to_date		DATE;
   p_threshold_date	DATE;
   p_gap_req_ok		BOOLEAN := TRUE;
   p_gap_deal_exists	BOOLEAN := FALSE;
   p_ok_trans		BOOLEAN := FALSE;
   p_ccy_reversed	BOOLEAN;
   p_current_deal_no	NUMBER := -1;
   p_insert_or_update	VARCHAR2(1);
   p_dirty_price	NUMBER;

   -- BUG 2945198 - sql binding
   v_cursor             INTEGER;
   n_num_rows_fetched   INTEGER;
   p_batch_fetch_size   NUMBER;
   p_batch_start_index  NUMBER := 1;

   -- Bug 3236479
   v_log VARCHAR2(4096);

   -- boolean returned by aggregation function
   p_agg_ok		VARCHAR2(1) := 'T';

   -- determines whether to recalculate values for qrm_tb_calculations
   p_recalc_val_tb	BOOLEAN := TRUE;

   p_side			VARCHAR2(5);
   p_int_rate_a			NUMBER;
   p_int_rate_a_ask		NUMBER;
   p_int_rate_a_bid		NUMBER;
   p_int_rate_b			NUMBER;
   p_int_rate_b_ask		NUMBER;
   p_int_rate_b_bid		NUMBER;
   p_int_rate_c_bid		NUMBER;
   p_int_rate_c_ask		NUMBER;
   p_spot_rate_a_bid		NUMBER;
   p_spot_rate_a_ask		NUMBER;
   p_spot_rate_b_bid		NUMBER;
   p_spot_rate_b_ask		NUMBER;
   p_df_a_bid			NUMBER;
   p_df_a_ask			NUMBER;
   p_df_b_bid			NUMBER;
   p_df_b_ask			NUMBER;
   p_df_c_bid			NUMBER;
   p_df_c_ask			NUMBER;
   p_day_count			NUMBER;
   p_annual_basis		NUMBER;
   -- for use with interest rates
   p_mm_day_count_basis		VARCHAR2(15) := 'ACTUAL365';
   p_fxo_day_count_basis		VARCHAR2(15) := '30/';
   -- actual/actual for rho calculation consistency
   p_fx_day_count_basis		VARCHAR2(15) := 'ACTUAL/ACTUAL';
   p_interpolation_method	VARCHAR2(20) := 'DEFAULT';
   p_md_in		XTR_MARKET_DATA_P.md_from_set_in_rec_type;
   p_md_out		XTR_MARKET_DATA_P.md_from_set_out_rec_type;
   p_df_in 		XTR_RATE_CONVERSION.df_in_rec_type;
   p_df_out 		XTR_RATE_CONVERSION.df_out_rec_type;
   p_rc_in		XTR_RATE_CONVERSION.rate_conv_in_rec_type;
   p_rc_out   		XTR_RATE_CONVERSION.rate_conv_out_rec_type;
   p_pv_in		XTR_MM_COVERS.presentvalue_in_rec_type;
   p_pv_out		XTR_MM_COVERS.presentvalue_out_rec_type;
   p_gk_in		QRM_FX_FORMULAS.gk_option_sens_in_rec_type;
   p_gk_out		QRM_FX_FORMULAS.gk_option_sens_out_rec_type;
   p_bo_in		QRM_MM_FORMULAS.black_opt_sens_in_rec_type;
   p_bo_out		QRM_MM_FORMULAS.black_opt_sens_out_rec_type;


   p_settings	 		get_settings%ROWTYPE;
   p_deal_calculations		deal_calculated%ROWTYPE;
   -- for saving a copy of attributes
   p_att_counter	NUMBER := 0;
   p_att_name		SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_att_type		SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_att_order		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_att_average	SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_att_ind		SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_att_percentage	SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_att_created_by	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_att_creation_date	SYSTEM.QRM_DATE_TABLE := SYSTEM.QRM_DATE_TABLE();
   p_att_updated_by	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_att_update_date	SYSTEM.QRM_DATE_TABLE := SYSTEM.QRM_DATE_TABLE();
   p_att_update_login	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();

   p_filter_where_clause	VARCHAR2(3500);

   p_bpv		NUMBER;
   -- FXO --
   p_delta_call		NUMBER;
   p_delta_put		NUMBER;
   p_theta_call		NUMBER;
   p_theta_put		NUMBER;
   p_rho_dom_call	NUMBER;
   p_rho_dom_put	NUMBER;
   p_rho_for_call	NUMBER;
   p_rho_for_put	NUMBER;
   -- FX --
   p_deltas_rhos	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE(2);
   -- BOND --
   p_bond_code		VARCHAR2(20);
   p_bond_calc_type	VARCHAR2(15);
   p_bond_coupon_start  DATE;
   p_bond_coupon_end	DATE;
   p_bond_issue_start   DATE;
   p_bond_ai		NUMBER;
   p_bond_ytm		NUMBER;
   p_shares_remaining 	NUMBER;
   p_days		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_cashflows		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_discount_factors	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_cashflows_100	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_counter		NUMBER;
   p_total_deals_counter NUMBER := 0; -- BUG 2945198 - SQL BINDING
   p_temp_counter	NUMBER := 0;
   p_threshold_counter	NUMBER := 0;
   p_insert_counter	NUMBER := 0;
   p_update_counter	NUMBER := 0;
   p_yield_rate		NUMBER;
   p_signed_face_value  NUMBER;
   -- TMM/IRS --
   p_dummy_num1		NUMBER;
   p_dummy_num2		NUMBER;
   p_dummy_cf		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_dummy_days		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_trans_row          get_tmm_irs_rtmm_curr_trans%ROWTYPE;
   p_trans_start_date	DATE;
   p_trans_end_date	DATE;
   p_trans_day_count_basis VARCHAR2(15);
   p_last_trans_no	NUMBER;
   p_trans_trans_nos	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_trans_yield_rates	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_trans_disc_rates	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_trans_start_dates	SYSTEM.QRM_DATE_TABLE := SYSTEM.QRM_DATE_TABLE();
   p_trans_maturity_dates	SYSTEM.QRM_DATE_TABLE := SYSTEM.QRM_DATE_TABLE();
   p_trans_settle_dates	SYSTEM.QRM_DATE_TABLE := SYSTEM.QRM_DATE_TABLE();
   p_trans_due_on_dates	SYSTEM.QRM_DATE_TABLE := SYSTEM.QRM_DATE_TABLE();
   p_trans_interest_refunds	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_trans_prin_actions	SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_trans_interest_settled    XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_trans_prin_adjusts   XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_trans_accum_interests XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_trans_accum_interests_bf XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_trans_balance_outs	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_trans_settle_term_interest SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   -- IRO --
   p_spot_rate		NUMBER;
   p_days_start		NUMBER;
   p_days_mature	NUMBER;
   -- FRA--
   p_fair_value_bp	NUMBER;
   p_fra_price		NUMBER;

   p_num_of_cols	NUMBER	:= 51; -- number of columns in select clause


/*
   p_deal_nos		XTR_MD_NUM_TABLE;
   p_transaction_nos	XTR_MD_NUM_TABLE;
   p_market_data_sets	SYSTEM.QRM_VARCHAR_TABLE;
   p_company_codes	SYSTEM.QRM_VARCHAR_TABLE;
   p_calls_or_puts	SYSTEM.QRM_VARCHAR_TABLE;
   p_pricing_models	SYSTEM.QRM_VARCHAR_TABLE;
   p_deal_ccys		SYSTEM.QRM_VARCHAR_TABLE;
   p_buy_ccys		SYSTEM.QRM_VARCHAR_TABLE;
   p_sell_ccys		SYSTEM.QRM_VARCHAR_TABLE;
   p_foreign_ccys	SYSTEM.QRM_VARCHAR_TABLE;
   p_domestic_ccys	SYSTEM.QRM_VARCHAR_TABLE;
   p_base_ccys		SYSTEM.QRM_VARCHAR_TABLE;
   p_contra_ccys	SYSTEM.QRM_VARCHAR_TABLE;
   p_premium_ccys	SYSTEM.QRM_VARCHAR_TABLE;
   p_buy_amounts	XTR_MD_NUM_TABLE;
   p_sell_amounts	XTR_MD_NUM_TABLE;
   p_foreign_amounts	XTR_MD_NUM_TABLE;
   p_domestic_amounts	XTR_MD_NUM_TABLE;
   p_base_amounts	XTR_MD_NUM_TABLE;
   p_contra_amounts	XTR_MD_NUM_TABLE;
   p_start_amounts	XTR_MD_NUM_TABLE;
   p_face_values	XTR_MD_NUM_TABLE;
   p_interests		XTR_MD_NUM_TABLE;
   p_accum_int_bfs	XTR_MD_NUM_TABLE;
   p_accum_int_actions	SYSTEM.QRM_VARCHAR_TABLE;
   p_accrued_interests	XTR_MD_NUM_TABLE;
   p_interests_settled  XTR_MD_NUM_TABLE;
   p_deal_dates		SYSTEM.QRM_DATE_TABLE;
   p_end_dates		SYSTEM.QRM_DATE_TABLE;
   p_gap_dates		SYSTEM.QRM_DATE_TABLE;
   p_deal_subtypes	SYSTEM.QRM_VARCHAR_TABLE;
   p_deal_types		SYSTEM.QRM_VARCHAR_TABLE;
   p_discount_yields	SYSTEM.QRM_VARCHAR_TABLE;
   p_maturity_dates	SYSTEM.QRM_DATE_TABLE;
   p_no_of_days		XTR_MD_NUM_TABLE;
   p_settle_dates	SYSTEM.QRM_DATE_TABLE;
   p_premium_amounts	XTR_MD_NUM_TABLE;
   p_start_dates	SYSTEM.QRM_DATE_TABLE;
   p_initial_bases	SYSTEM.QRM_VARCHAR_TABLE;
   p_bond_issues	SYSTEM.QRM_VARCHAR_TABLE;
   p_coupon_actions	SYSTEM.QRM_VARCHAR_TABLE;
   p_coupon_rates	XTR_MD_NUM_TABLE;
   p_margins		XTR_MD_NUM_TABLE;
   p_transaction_rates	XTR_MD_NUM_TABLE;
   p_coupon_freqs    	XTR_MD_NUM_TABLE;
   p_next_coupon_dates	SYSTEM.QRM_DATE_TABLE;
   p_day_count_bases	SYSTEM.QRM_VARCHAR_TABLE;
   -- QUANTITY OUTSTANDING
   p_quantity_out	XTR_MD_NUM_TABLE;
   p_rounding_type	SYSTEM.QRM_VARCHAR_TABLE;
   p_day_count_type	SYSTEM.QRM_VARCHAR_TABLE;
   p_prepaid_interests  SYSTEM.QRM_VARCHAR_TABLE;
*/


   p_deal_nos		DBMS_SQL.NUMBER_TABLE;
   p_transaction_nos	DBMS_SQL.NUMBER_TABLE;
   p_market_data_sets	DBMS_SQL.VARCHAR2_TABLE;
   p_company_codes	DBMS_SQL.VARCHAR2_TABLE;
   p_calls_or_puts	DBMS_SQL.VARCHAR2_TABLE;
   p_pricing_models	DBMS_SQL.VARCHAR2_TABLE;
   p_deal_ccys		DBMS_SQL.VARCHAR2_TABLE;
   p_buy_ccys		DBMS_SQL.VARCHAR2_TABLE;
   p_sell_ccys		DBMS_SQL.VARCHAR2_TABLE;
   p_foreign_ccys	DBMS_SQL.VARCHAR2_TABLE;
   p_domestic_ccys	DBMS_SQL.VARCHAR2_TABLE;
   p_base_ccys		DBMS_SQL.VARCHAR2_TABLE;
   p_contra_ccys	DBMS_SQL.VARCHAR2_TABLE;
   p_premium_ccys	DBMS_SQL.VARCHAR2_TABLE;
   p_buy_amounts	DBMS_SQL.NUMBER_TABLE;
   p_sell_amounts	DBMS_SQL.NUMBER_TABLE;
   p_foreign_amounts	DBMS_SQL.NUMBER_TABLE;
   p_domestic_amounts	DBMS_SQL.NUMBER_TABLE;
   p_base_amounts	DBMS_SQL.NUMBER_TABLE;
   p_contra_amounts	DBMS_SQL.NUMBER_TABLE;
   p_start_amounts	DBMS_SQL.NUMBER_TABLE;
   p_face_values	DBMS_SQL.NUMBER_TABLE;
   p_interests		DBMS_SQL.NUMBER_TABLE;
   p_accum_int_bfs	DBMS_SQL.NUMBER_TABLE;
   p_accum_int_actions	DBMS_SQL.VARCHAR2_TABLE;
   p_accrued_interests	DBMS_SQL.NUMBER_TABLE;
   p_interests_settled  DBMS_SQL.NUMBER_TABLE;
   p_deal_dates		DBMS_SQL.DATE_TABLE;
   p_end_dates		DBMS_SQL.DATE_TABLE;
   p_gap_dates		DBMS_SQL.DATE_TABLE;
   p_deal_subtypes	DBMS_SQL.VARCHAR2_TABLE;
   p_deal_types		DBMS_SQL.VARCHAR2_TABLE;
   p_discount_yields	DBMS_SQL.VARCHAR2_TABLE;
   p_maturity_dates	DBMS_SQL.DATE_TABLE;
   p_no_of_days		DBMS_SQL.NUMBER_TABLE;
   p_settle_dates	DBMS_SQL.DATE_TABLE;
   p_premium_amounts	DBMS_SQL.NUMBER_TABLE;
   p_start_dates	DBMS_SQL.DATE_TABLE;
   p_initial_bases	DBMS_SQL.VARCHAR2_TABLE;
   p_bond_issues	DBMS_SQL.VARCHAR2_TABLE;
   p_coupon_actions	DBMS_SQL.VARCHAR2_TABLE;
   p_coupon_rates	DBMS_SQL.NUMBER_TABLE;
   p_margins		DBMS_SQL.NUMBER_TABLE;
   p_transaction_rates	DBMS_SQL.NUMBER_TABLE;
   p_coupon_freqs    	DBMS_SQL.NUMBER_TABLE;
   p_next_coupon_dates	DBMS_SQL.DATE_TABLE;
   p_day_count_bases	DBMS_SQL.VARCHAR2_TABLE;
   -- QUANTITY OUTSTANDING
   p_quantity_out	DBMS_SQL.NUMBER_TABLE;
   p_rounding_type	DBMS_SQL.VARCHAR2_TABLE;
   p_day_count_type	DBMS_SQL.VARCHAR2_TABLE;
   p_prepaid_interests  DBMS_SQL.VARCHAR2_TABLE;



   -- storage for later insert/update
   p_deal_calc_id			NUMBER;
   -- for updating the correct row
   p_deal_calc_id_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   -- for inserting with correct sequence no (deal calc id)
   p_seq_nos		        XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_deal_no_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_deal_no_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_deal_no_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_company_code_insert	SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_company_code_update	SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_company_code_temp		SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_transaction_no_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_transaction_no_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_transaction_no_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_market_data_set_insert	SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_market_data_set_update	SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_market_data_set_temp	SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_deal_ccy_insert		SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_deal_ccy_update		SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_deal_ccy_temp		SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_sob_ccy_insert		SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_sob_ccy_update		SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_sob_ccy_temp		SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_base_ccy_amount_usd_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_base_ccy_amount_usd_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_base_ccy_amount_usd_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_base_ccy_amount_sob_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_base_ccy_amount_sob_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_base_ccy_amount_sob_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_contra_ccy_amount_usd_insert XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_contra_ccy_amount_usd_update XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_contra_ccy_amount_usd_temp	  XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_contra_ccy_amount_sob_insert XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_contra_ccy_amount_sob_update XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_contra_ccy_amount_sob_temp	  XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_foreign_amount_usd_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_foreign_amount_usd_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_foreign_amount_usd_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_foreign_amount_sob_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_foreign_amount_sob_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_foreign_amount_sob_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_domestic_amount_usd_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_domestic_amount_usd_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_domestic_amount_usd_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_domestic_amount_sob_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_domestic_amount_sob_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_domestic_amount_sob_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_buy_amount_usd_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_buy_amount_usd_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_buy_amount_usd_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_buy_amount_sob_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_buy_amount_sob_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_buy_amount_sob_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_sell_amount_usd_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_sell_amount_usd_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_sell_amount_usd_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_sell_amount_sob_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_sell_amount_sob_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_sell_amount_sob_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_days_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_days_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_days_temp			XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_fx_reval_rate_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_fx_reval_rate_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_fx_reval_rate_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_mm_reval_rate_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_mm_reval_rate_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_mm_reval_rate_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_fx_trans_rate_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_fx_trans_rate_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_fx_trans_rate_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_trans_price_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_trans_price_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_trans_price_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_trans_price_sob_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_trans_price_sob_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_trans_price_sob_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_trans_price_usd_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_trans_price_usd_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_trans_price_usd_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_reval_price_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_reval_price_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_reval_price_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_reval_price_sob_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_reval_price_sob_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_reval_price_sob_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_reval_price_usd_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_reval_price_usd_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_reval_price_usd_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_mm_trans_rate_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_mm_trans_rate_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_mm_trans_rate_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_fair_value_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_fair_value_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_fair_value_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_fair_value_usd_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_fair_value_usd_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_fair_value_usd_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_fair_value_sob_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_fair_value_sob_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_fair_value_sob_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_gap_amount_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_gap_amount_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_gap_amount_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_gap_amount_usd_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_gap_amount_usd_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_gap_amount_usd_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_gap_amount_sob_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_gap_amount_sob_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_gap_amount_sob_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_maturity_amount_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_maturity_amount_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_maturity_amount_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_maturity_amount_usd_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_maturity_amount_usd_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_maturity_amount_usd_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_maturity_amount_sob_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_maturity_amount_sob_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_maturity_amount_sob_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_premium_amount_usd_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_premium_amount_usd_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_premium_amount_usd_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_premium_amount_sob_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_premium_amount_sob_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_premium_amount_sob_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_accrued_interest_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_accrued_interest_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_accrued_interest_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_accrued_interest_usd_insert XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_accrued_interest_usd_update XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_accrued_interest_usd_temp	 XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_accrued_interest_sob_insert XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_accrued_interest_sob_update XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_accrued_interest_sob_temp	 XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_duration_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_duration_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_duration_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_mod_duration_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_mod_duration_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_mod_duration_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_convexity_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_convexity_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_convexity_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_delta_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_delta_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_delta_temp			XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_gamma_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_gamma_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_gamma_temp			XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_theta_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_theta_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_theta_temp			XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_rho_insert			XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_rho_update			XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_rho_temp			XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_rho_base_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_rho_base_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_rho_base_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_rho_contra_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_rho_contra_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_rho_contra_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_rho_for_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_rho_for_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_rho_for_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_rho_dom_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_rho_dom_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_rho_dom_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_vega_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_vega_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_vega_temp			XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_bpv_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_bpv_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_bpv_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_bpv_usd_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_bpv_usd_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_bpv_usd_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_bpv_sob_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_bpv_sob_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_bpv_sob_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_delta_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_delta_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_delta_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_delta_usd_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_delta_usd_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_delta_usd_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_delta_sob_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_delta_sob_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_delta_sob_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_gamma_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_gamma_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_gamma_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_gamma_usd_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_gamma_usd_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_gamma_usd_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_gamma_sob_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_gamma_sob_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_gamma_sob_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_theta_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_theta_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_theta_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_theta_usd_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_theta_usd_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_theta_usd_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_theta_sob_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_theta_sob_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_theta_sob_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_usd_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_usd_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_usd_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_sob_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_sob_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_sob_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_base_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_base_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_base_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_base_usd_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_base_usd_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_base_usd_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_base_sob_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_base_sob_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_base_sob_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_contra_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_contra_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_contra_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_contra_usd_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_contra_usd_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_contra_usd_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_contra_sob_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_contra_sob_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_contra_sob_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_for_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_for_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_for_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_for_usd_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_for_usd_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_for_usd_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_for_sob_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_for_sob_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_for_sob_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_dom_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_dom_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_dom_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_dom_usd_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_dom_usd_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_dom_usd_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_dom_sob_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_dom_sob_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_rho_dom_sob_temp	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_vega_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_vega_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_vega_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_vega_usd_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_vega_usd_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_vega_usd_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_vega_sob_insert	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_vega_sob_update	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_pos_vega_sob_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_volatility_insert		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_volatility_update		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_volatility_temp		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_ytm_temp			XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_ytm_insert			XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_ytm_update			XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_gap_date_insert		SYSTEM.QRM_DATE_TABLE :=
					SYSTEM.QRM_DATE_TABLE();
   p_gap_date_update		SYSTEM.QRM_DATE_TABLE :=
					SYSTEM.QRM_DATE_TABLE();
   p_gap_date_temp		SYSTEM.QRM_DATE_TABLE :=
   					SYSTEM.QRM_DATE_TABLE();
   p_upd_md_calc_date_temp	SYSTEM.QRM_DATE_TABLE :=
   					SYSTEM.QRM_DATE_TABLE();
   p_upd_md_calc_date_update	SYSTEM.QRM_DATE_TABLE :=
   					SYSTEM.QRM_DATE_TABLE();

   -- tb calculations
   p_tb_counter			NUMBER := 0;
   p_tb_curr_deal_no		NUMBER := -4; -- dummy
   p_tb_deal_no			XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_tb_transaction_no		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_tb_market_data_set		SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_tb_pos_start_date		SYSTEM.QRM_DATE_TABLE := SYSTEM.QRM_DATE_TABLE();
   p_tb_pos_end_date		SYSTEM.QRM_DATE_TABLE := SYSTEM.QRM_DATE_TABLE();
   p_tb_start_date		SYSTEM.QRM_DATE_TABLE := SYSTEM.QRM_DATE_TABLE();
   p_tb_end_date		SYSTEM.QRM_DATE_TABLE := SYSTEM.QRM_DATE_TABLE();
   p_tb_interest_basis		SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_tb_outst_amount		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_tb_outst_amount_usd	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_tb_outst_amount_sob	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_tb_amt_qty_out		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_tb_amt_qty_out_usd		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_tb_amt_qty_out_sob		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_tb_coupon_rate		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_tb_next_coupon_date 	SYSTEM.QRM_DATE_TABLE := SYSTEM.QRM_DATE_TABLE();

   -- exceptions
   p_error_type			VARCHAR2(1) := 'W'; -- default to warning
   p_except_counter		NUMBER := 0;
   p_except_deal_no		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_except_transaction_no	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_except_market_data_set	SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_except_error_type		SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_except_error_code		SYSTEM.QRM_VARCHAR240_TABLE := SYSTEM.QRM_VARCHAR240_TABLE();
   p_except_token_name		SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   p_except_token_value		SYSTEM.QRM_VARCHAR240_TABLE := SYSTEM.QRM_VARCHAR240_TABLE();


    p_request_id	NUMBER;
    -- for FND_CONCURRENT.get_request_status
    rphase  		VARCHAR2(80);
    rstatus		VARCHAR2(80);
    dphase		VARCHAR2(30);
    dstatus		VARCHAR2(30);
    message		VARCHAR2(240);
    call_status		BOOLEAN;

   FUNCTION within_one_year(p_start_date DATE, p_end_date DATE)
   	RETURN BOOLEAN IS

   BEGIN
      IF (ADD_MONTHS(p_start_date, 12) >= p_end_date) THEN
         RETURN true;
      ELSE
	 RETURN false;
      END IF;
   END within_one_year;

/*
   bug 2560111 - fixes bad dates causing unhandled exception
   calc_days_run_c and rate_conversion are wrapper functions that
   check for bad dates before passing the buck.
*/
  PROCEDURE DAYS_RUN_HELPER(start_date IN DATE,
                            end_date   IN DATE,
                            method     IN VARCHAR2,
                            frequency  IN NUMBER,
                            num_days   IN OUT NOCOPY NUMBER,
                            year_basis IN OUT NOCOPY NUMBER) IS
  BEGIN
    IF start_date is not null and end_date is not null and method is not null THEN

      IF end_date < start_date THEN
         raise e_invalid_date;
      END IF;
    END IF;

    XTR_CALC_P.calc_days_run_c(start_date,
                               end_date,
                               method,
                               frequency,
                               num_days,
                               year_basis);

  END;


  PROCEDURE rate_conversion (p_in_rec  IN     XTR_RATE_CONVERSION.rate_conv_in_rec_type,
                             p_out_rec IN OUT NOCOPY XTR_RATE_CONVERSION.rate_conv_out_rec_type) is
  BEGIN
    IF p_in_rec.p_start_date IS NOT NULL AND p_in_rec.p_end_date IS NOT NULL AND p_in_rec.p_day_count_basis_in IS NOT NULL THEN
      IF p_in_rec.p_end_date < p_in_rec.p_start_date THEN
        raise e_invalid_date;
      END IF;
    END IF;

    XTR_RATE_CONVERSION.rate_conversion(p_in_rec,
                                        p_out_rec);
  END;


BEGIN

  IF (g_proc_level>=g_debug_level) THEN
     XTR_RISK_DEBUG_PKG.dpush(null,'QRM_CALCULATION_P.RUN_ANALYSIS'); --bug3236479
     XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'source is', p_source);
     XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'analysis name', p_analysis_name);
     XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'ref date', p_ref_datetime);
  END IF;

   p_select_clause := p_select_clause||'foreign_ccy, domestic_ccy, base_ccy, contra_ccy, premium_ccy, buy_amount, sell_amount, foreign_amount, domestic_amount, ';
   p_select_clause := p_select_clause||'base_ccy_amount, contra_ccy_amount, start_amount, face_value, interest, accum_interest_bf, accum_int_action, ';
   p_select_clause := p_select_clause||'accrued_interest, interest_settled, deal_date, end_date, gap_date, deal_subtype, deal_type, discount_yield, ';
   p_select_clause := p_select_clause||'maturity_date, no_of_days, settle_date, premium_amount, phy_start_date, initial_basis, bond_issue_code, ';
   p_select_clause := p_select_clause||'coupon_action, coupon_rate, margin, transaction_rate, coupon_frequency, next_coupon_date, day_count_basis, ';
-- BUG 2945198 - sql binding
-- p_select_clause := p_select_clause||'quantity_remaining, rounding_type, day_count_type, prepaid_interest BULK COLLECT INTO';
   p_select_clause := p_select_clause||'quantity_remaining, rounding_type, day_count_type, prepaid_interest ';

/* RVALLAMS Bug 3007749
   p_from_where_clause := p_from_where_clause||'OR (deal_type=''IG'' and (deal_no, transaction_no)
   IN (select deal_no, max(transaction_no) from qrm_current_deals_v where NOT(accrued_interest=interest_settled
   and face_value=0) group by deal_no)))';
*/

-- RVALLAMS Bug 3805685 added group by deal_no clause

   p_from_where_clause := p_from_where_clause||' OR (deal_type=''IG'' and (deal_no, transaction_no) IN (select deal_no, max(transaction_no) from qrm_current_deals_v b where ';
   p_from_where_clause := p_from_where_clause||' (deal_no,deal_date) = (select deal_no,max(deal_date)  from qrm_current_deals_v c where b.deal_no = c.deal_no group by deal_no) group by b.deal_no) ';
   p_from_where_clause := p_from_where_clause||' AND NOT(NVL(accrued_interest,0)=NVL(interest_settled,0) and face_value=0)))';

   -- '0' : completed successfully    --|
   -- '1' : completed with warnings     |--->corresponds to CM codes
   -- '2' : error		      --|
   -- '3' : in progress: saved in settings, never returned to CM
   -- '4' : never run  --- set by analysis settings
   -- '5' : no deals returned: updated to '1' for settings table and CM
   retcode := '0';  -- assume success, may turn out NOCOPY otherwise later

 BEGIN
   -- get analysis settings
   OPEN get_settings(p_analysis_name);
   FETCH get_settings INTO p_settings;
   -- if analysis settings does not exist, raise exception
   IF (get_settings%NOTFOUND) THEN
	raise e_no_setting_found;
   -- if called by Concurrent Manager and in progress, raise exception
   ELSIF (p_settings.status = '3' AND p_source <> 'AM') THEN
	p_request_id := FND_GLOBAL.conc_request_id;
        call_status := FND_CONCURRENT.get_request_status(
	   p_request_id,'','', rphase, rstatus,
	   dphase, dstatus, message);
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'dphase is', dphase);
	END IF;
	IF (dphase IN ('PENDING', 'RUNNING', 'INACTIVE')) THEN
	  raise e_analysis_in_progress;
	END IF;
   END IF;
   CLOSE get_settings;

   -- get the from and to dates
   IF (g_proc_level>=g_debug_level) THEN
      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'ref date: '||p_ref_date);
      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'date type: '||p_settings.date_type);
      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'start date: '||p_settings.start_date);
      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'end date: '||p_settings.end_date);
      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'start date ref: '||p_settings.start_date_ref);
      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'start date offset: '||p_settings.start_date_offset);
      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'start offset type: '||p_settings.start_offset_type);
      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'gl calendar id: '||p_settings.gl_calendar_id);
   END IF;


   -- get appropriate from/to dates
   IF (p_settings.date_type = 'F') THEN
	IF (p_settings.style = 'X') THEN
	    p_from_date := p_settings.start_date;
	    p_to_date := p_settings.end_date;
	    QRM_PA_AGGREGATION_P.calc_tb_start_end_dates (
		p_settings.analysis_name, p_ref_date, p_settings.tb_name,
                p_settings.tb_label, p_to_date,
                p_settings.end_date_ref, p_settings.end_date_offset,
                p_settings.end_offset_type, p_settings.date_type,
                p_settings.gl_calendar_id, p_settings.business_week,
   		p_from_date, p_settings.start_date_ref,
		p_settings.start_date_offset, p_settings.start_offset_type,
		p_settings.analysis_type);
	ELSE
		p_from_date := p_settings.start_date;
	   	p_to_date := p_settings.end_date;
	END IF;
   ELSIF (p_settings.date_type = 'R') THEN
	IF (p_settings.style = 'X') THEN
	    p_from_date := p_settings.start_date;
	    p_to_date := p_settings.end_date;
	    QRM_PA_AGGREGATION_P.calc_tb_start_end_dates (
		p_settings.analysis_name, p_ref_date, p_settings.tb_name,
                p_settings.tb_label, p_to_date,
                p_settings.end_date_ref, p_settings.end_date_offset,
                p_settings.end_offset_type, p_settings.date_type,
                p_settings.gl_calendar_id, p_settings.business_week,
   		p_from_date, p_settings.start_date_ref,
		p_settings.start_date_offset, p_settings.start_offset_type,
		p_settings.analysis_type);
	ELSE
            p_from_date :=QRM_PA_AGGREGATION_P.calculate_relative_date(
		p_ref_date, p_settings.date_type, p_settings.start_date,
		p_settings.start_date_ref, p_settings.start_date_offset,
		p_settings.start_offset_type, p_settings.gl_calendar_id,
		p_settings.business_week);

   	    p_to_date := QRM_PA_AGGREGATION_P.calculate_relative_date(
		p_ref_date, p_settings.date_type, p_settings.end_date,
		p_settings.end_date_ref, p_settings.end_date_offset,
		p_settings.end_offset_type, p_settings.gl_calendar_id,
		p_settings.business_week);
       END IF;
   END IF;

   IF (g_proc_level>=g_debug_level) THEN
      XTR_RISK_DEBUG_PKG.dlog('run_analysis: from date is:', p_from_date);
      XTR_RISK_DEBUG_PKG.dlog('run_analysis: to date is:', p_to_date);
   END IF;

   -- if not called by Analysis Manager

   -- delete analysis row with history_flag='S';
   DELETE
   FROM qrm_analysis_settings
   WHERE analysis_name = p_analysis_name and history_flag='S';

   IF (g_event_level>=g_debug_level) THEN --bug 3236479
      XTR_RISK_DEBUG_PKG.dlog('DML','Deleted analysis row with history_flag=S',
        'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_event_level);
   END IF;

   -- delete attributes rows with history_flag='S'
   DELETE
   FROM qrm_analysis_atts
   WHERE analysis_name = p_analysis_name and history_flag='S';

   IF (g_event_level>=g_debug_level) THEN --bug 3236479
      XTR_RISK_DEBUG_PKG.dlog('DML','Deleted attributes rows with history_flag=S',
        'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_event_level);
   END IF;

   IF (g_state_level>=g_debug_level) THEN --bug 3236479
      v_log := p_settings.analysis_name||','||p_settings.description||','||
	p_settings.analysis_type||','||p_settings.style||','||p_settings.filter_name
	||','||p_settings.md_set_code||','||p_settings.threshold_num||','||
	p_settings.threshold_type||','||p_settings.tb_label||','||p_settings.tb_name
	||','||p_settings.date_type||','||p_from_date||','||p_to_date||','||
	p_settings.start_date_ref||','||p_settings.end_date_ref||','||
	p_settings.start_date_offset||','||p_settings.end_date_offset||','||
	p_settings.start_offset_type||','||p_settings.end_offset_type||','||
	p_settings.show_totals||','||p_settings.currency_source||','||
	p_settings.curr_reporting||','||p_settings.currency_used||','||
	p_settings.units||','||p_settings.dec_places||','||'3'||','||
	p_settings.process_id||','||p_settings.last_run_date||','||
	p_settings.dirty||','||p_settings.business_week||','||
	p_settings.gl_calendar_id||','||'S'||','||
	p_settings.created_by||','||p_settings.creation_date||','||
	p_settings.last_updated_by||','||p_settings.last_update_date||','||
	p_settings.last_update_login;
      XTR_RISK_DEBUG_PKG.dlog('INSERT QRM_ANALYSIS_SETTINGS',v_log,
        'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_state_level);
   END IF;

   -- make copy of row and set history flag to 'S';
   INSERT
   INTO qrm_analysis_settings(analysis_name, description, analysis_type,
	style, filter_name, md_set_code, threshold_num, threshold_type,
	tb_label, tb_name, date_type, start_date, end_date,
	start_date_ref, end_date_ref, start_date_offset, end_date_offset,
	start_offset_type, end_offset_type, show_totals, currency_source,
	curr_reporting, currency_used, units, dec_places, status, process_id,
	last_run_date, dirty, business_week, gl_calendar_id, history_flag,
	created_by, creation_date, last_updated_by, last_update_date,
	last_update_login)
   VALUES (p_settings.analysis_name, p_settings.description,
	p_settings.analysis_type, p_settings.style, p_settings.filter_name,
	p_settings.md_set_code, p_settings.threshold_num,
	p_settings.threshold_type, p_settings.tb_label, p_settings.tb_name,
	p_settings.date_type, p_from_date, p_to_date,
	p_settings.start_date_ref, p_settings.end_date_ref,
	p_settings.start_date_offset, p_settings.end_date_offset,
	p_settings.start_offset_type, p_settings.end_offset_type,
	p_settings.show_totals, p_settings.currency_source,
	p_settings.curr_reporting, p_settings.currency_used, p_settings.units,
	p_settings.dec_places, '3', p_settings.process_id,
	p_settings.last_run_date, p_settings.dirty, p_settings.business_week,
	p_settings.gl_calendar_id, 'S',
	p_settings.created_by, p_settings.creation_date,
	p_settings.last_updated_by, p_settings.last_update_date,
	p_settings.last_update_login);

   IF (g_event_level>=g_debug_level) THEN --bug 3236479
      XTR_RISK_DEBUG_PKG.dlog('DML','Inserted into QRM_ANALYSIS_SETTINGS attributes with history_flag=S',
      	'QRM_CALCULATION_P.RUN_ANALYSIS',g_event_level);
   END IF;

   -- store attributes rows for bulk copy
   FOR atts_rec IN get_attributes(p_analysis_name) LOOP
     p_att_counter := p_att_counter + 1;
     p_att_name.EXTEND;
     p_att_name(p_att_counter) := atts_rec.attribute_name;
     p_att_type.EXTEND;
     p_att_type(p_att_counter) := atts_rec.type;
     p_att_order.EXTEND;
     p_att_order(p_att_counter) := atts_rec.att_order;
     p_att_average.EXTEND;
     p_att_average(p_att_counter) := atts_rec.total_average;
     p_att_ind.EXTEND;
     p_att_ind(p_att_counter) := atts_rec.total_ind;
     p_att_percentage.EXTEND;
     p_att_percentage(p_att_counter) := atts_rec.percentage;
     p_att_created_by.EXTEND;
     p_att_created_by(p_att_counter) := atts_rec.created_by;
     p_att_creation_date.EXTEND;
     p_att_creation_date(p_att_counter) := atts_rec.creation_date;
     p_att_updated_by.EXTEND;
     p_att_updated_by(p_att_counter) := atts_rec.last_updated_by;
     p_att_update_date.EXTEND;
     p_att_update_date(p_att_counter) := atts_rec.last_update_date;
     p_att_update_login.EXTEND;
     p_att_update_login(p_att_counter) := atts_rec.last_update_login;
   END LOOP;

   IF (g_state_level>=g_debug_level) THEN --bug 3236479
      for i in 1..p_att_counter loop
         v_log := p_att_name(i)||','||p_analysis_name||','||'S'||','||
	    p_att_type(i)||','||p_att_order(i)||','||p_att_average(i)||','||
	    p_att_ind(i)||','|| p_att_percentage(i);
         XTR_RISK_DEBUG_PKG.dlog('INSERT QRM_ANALYSIS_ATTS',v_log,
            'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_state_level);
      end loop;
   END IF;

   -- bulk copy of attributes with history_flag='S'
   FORALL i IN 1..p_att_counter
     INSERT
     INTO qrm_analysis_atts (attribute_name, analysis_name, history_flag,
	type, att_order, total_average, total_ind, percentage, created_by,
	creation_date, last_updated_by, last_update_date, last_update_login)
     VALUES (p_att_name(i), p_analysis_name, 'S', p_att_type(i),
	p_att_order(i), p_att_average(i), p_att_ind(i), p_att_percentage(i),
	p_att_created_by(i), p_att_creation_date(i), p_att_updated_by(i),
	p_att_update_date(i), p_att_update_login(i));

   IF (g_event_level>=g_debug_level) THEN --bug 3236479
      XTR_RISK_DEBUG_PKG.dlog('DML','Inserted into QRM_ANALYSIS_ATTS attributes with history_flag=S',
      	'QRM_CALCULATION_P.RUN_ANALYSIS',g_event_level);
   END IF;

   -- update status column to "In Progress"
   -- updates both history_flag='C' and 'S' rows in analysis settings
   UPDATE qrm_analysis_settings
   SET status = '3',
       process_id = FND_GLOBAL.conc_request_id,
       last_run_date = p_ref_datetime,
       dirty = 'N'
   WHERE analysis_name = p_analysis_name;

   IF (g_event_level>=g_debug_level) THEN --bug 3236479
      XTR_RISK_DEBUG_PKG.dlog('DML','Updated status column to 3 (In Progress)',
      	'QRM_CALCULATION_P.RUN_ANALYSIS',g_event_level);
   END IF;

   COMMIT;

   -- retrieved analysis settings, now get where clause from filters
   -- if no filter defined for analysis, leave filter where clause to null
   IF (p_settings.filter_name IS NOT NULL) THEN
      OPEN get_filter_where_clause(p_settings.filter_name);
      FETCH get_filter_where_clause INTO p_filter_where_clause;
      IF (get_filter_where_clause%NOTFOUND) THEN
         RAISE_APPLICATION_ERROR(-20001,'filter '||p_settings.filter_name||
					' does not exist');
      END IF;
      CLOSE get_filter_where_clause;
      p_filter_where_clause := ' AND '||p_filter_where_clause;
   END IF;

   IF (g_proc_level>=g_debug_level) THEN
      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'creating select stmt...');
   END IF;
   -- construct select statement to exclude closed deals

/* BUG 2945198 - sql binding
   FOR i IN 1..p_num_of_cols LOOP
       p_select_clause := p_select_clause||' :'||i;
       IF (i <> p_num_of_cols) THEN
           p_select_clause := p_select_clause||',';
       END IF;
   END LOOP;
*/

   p_select_stmt := p_select_clause || p_from_where_clause;

   -- filter out NOCOPY deals according to measure
   p_where_measure := filter_measure(p_settings.style, p_analysis_name, null);
   IF (p_where_measure IS NOT NULL) THEN
      p_appended_where := ' AND '||p_where_measure;
   End If;

   -- BUG 2945198 - sql bind
   BEGIN
      DELETE
      FROM qrm_deals_analyses
      WHERE analysis_name=p_analysis_name;

   IF (g_event_level>=g_debug_level) THEN --bug 3236479
      XTR_RISK_DEBUG_PKG.dlog('DML','DELETED QRM_DEALS_ANALYSES',
      	'QRM_CALCULATION_P.RUN_ANALYSIS',g_event_level);
   END IF;

   v_cursor := dbms_sql.open_cursor;

   p_batch_fetch_size := fnd_profile.value('QRM_ANA_CALC_BATCH_SIZE');

   if (p_batch_fetch_size is null or p_batch_fetch_size < 1) then
       p_batch_fetch_size := 1000;
   end if;

   IF (g_proc_level>=g_debug_level) THEN
      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'processing batch size: '||p_batch_fetch_size);
   END IF;

   -- filter out NOCOPY deals according to dates in settings
   -- Maturity: from_date <= end_date <= to_date
   -- Position: deal_date <= to_date <= end_date
   -- Gap: from_date <= gap_date <= to date  cannot filter: gap date not known yet
   IF (p_settings.analysis_type = 'M') THEN  -- maturity analysis
       IF (g_proc_level>=g_debug_level) THEN
          XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'Maturity Analysis');
       END IF;
       p_appended_where := p_appended_where ||' AND :from_date <= NVL(end_date, :p_ref_date+1) AND NVL(end_date, :p_ref_date+1) <= :to_date  AND DEAL_TYPE <> ''STOCK''';

       p_select_stmt := p_select_stmt||p_appended_where||p_filter_where_clause;

       -- BUG 2945198 - sql bind
       dbms_sql.parse(v_cursor,p_select_stmt,dbms_sql.native);
       dbms_sql.bind_variable(v_cursor,':from_date',p_from_date);
       dbms_sql.bind_variable(v_cursor,':p_ref_date',p_ref_date);
       dbms_sql.bind_variable(v_cursor,':to_date',p_to_date);
/*
       p_select_stmt := 'BEGIN '||p_select_stmt||';END;';

       IF (g_proc_level>=g_debug_level) THEN
          XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'select stmt: ', p_select_stmt);
       END IF;

       EXECUTE IMMEDIATE p_select_stmt USING OUT p_deal_nos,
	OUT p_transaction_nos, OUT p_market_data_sets, OUT p_company_codes,
	OUT p_calls_or_puts, OUT p_pricing_models, OUT p_deal_ccys,
	OUT p_buy_ccys, OUT p_sell_ccys, OUT p_foreign_ccys,
	OUT p_domestic_ccys, OUT p_base_ccys, OUT p_contra_ccys,
	OUT p_premium_ccys,
	OUT p_buy_amounts, OUT p_sell_amounts, OUT p_foreign_amounts,
	OUT p_domestic_amounts, OUT p_base_amounts,OUT p_contra_amounts,
	OUT p_start_amounts, OUT p_face_values, OUT p_interests,
	OUT p_accum_int_bfs, OUT p_accum_int_actions, OUT p_accrued_interests,
	OUT p_interests_settled, OUT p_deal_dates, OUT p_end_dates,
	OUT p_gap_dates, OUT p_deal_subtypes, OUT p_deal_types,
	OUT p_discount_yields, OUT p_maturity_dates, OUT p_no_of_days,
	OUT p_settle_dates, OUT p_premium_amounts, OUT p_start_dates,
	OUT p_initial_bases, OUT p_bond_issues,
	OUT p_coupon_actions, OUT p_coupon_rates, OUT p_margins,
	OUT p_transaction_rates, OUT p_coupon_freqs,
	OUT p_next_coupon_dates, OUT p_day_count_bases, OUT p_quantity_out,
	OUT p_rounding_type, OUT p_day_count_type, OUT p_prepaid_interests,
	IN p_from_date,
	IN p_ref_date, IN p_to_date;

       IF (g_proc_level>=g_debug_level) THEN
          XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'NO OF ROWS RETRIEVED: '||p_deal_nos.count);
       END IF;
       FOR i IN 1..p_deal_nos.count LOOP
          IF (g_proc_level>=g_debug_level) THEN
             XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'd_no: '||p_deal_nos(i)||'; t_no: '||p_transaction_nos(i)||'; type: '||p_deal_types(i)||'; end date: '||p_end_dates(i));
          END IF;
       END LOOP;
*/
   ELSIF (p_settings.analysis_type = 'P') THEN -- position analysis
       IF (g_proc_level>=g_debug_level) THEN
          XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'Position Analysis');
       END IF;
       p_appended_where := p_appended_where || ' AND ((deal_type<>''FXO'') OR (deal_type=''FXO'' AND (knock_type=''O'' OR knock_type IS NULL OR (knock_type=''I'' and knock_execute_date IS NOT NULL))))';

       IF (p_settings.style = 'X') THEN
	  p_appended_where := p_appended_where ||
			' AND deal_date <= :to_date AND (end_date >= :from_date
				OR end_date IS NULL)';
          p_select_stmt := p_select_stmt||p_appended_where
					||p_filter_where_clause;
          -- BUG 2945198 - sql bind
          dbms_sql.parse(v_cursor,p_select_stmt,dbms_sql.native);
          dbms_sql.bind_variable(v_cursor,':to_date',p_to_date);
          dbms_sql.bind_variable(v_cursor,':from_date',p_from_date);
/*
          p_select_stmt := 'BEGIN '||p_select_stmt||';END;';

          IF (g_proc_level>=g_debug_level) THEN
             XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'select stmt: ', p_select_stmt);
          END IF;

          EXECUTE IMMEDIATE p_select_stmt USING OUT p_deal_nos,
	    OUT p_transaction_nos, OUT p_market_data_sets,
	    OUT p_company_codes, OUT p_calls_or_puts, OUT p_pricing_models,
	    OUT p_deal_ccys, OUT p_buy_ccys, OUT p_sell_ccys,
	    OUT p_foreign_ccys, OUT p_domestic_ccys, OUT p_base_ccys,
	    OUT p_contra_ccys, OUT  p_premium_ccys, OUT  p_buy_amounts,
	    OUT  p_sell_amounts, OUT  p_foreign_amounts, OUT  p_domestic_amounts,
 	    OUT  p_base_amounts,OUT p_contra_amounts, OUT  p_start_amounts,
	    OUT  p_face_values, OUT  p_interests, OUT  p_accum_int_bfs,
	    OUT  p_accum_int_actions, OUT  p_accrued_interests,
	    OUT  p_interests_settled, OUT  p_deal_dates, OUT  p_end_dates,
	    OUT  p_gap_dates, OUT  p_deal_subtypes, OUT  p_deal_types,
	    OUT  p_discount_yields, OUT  p_maturity_dates, OUT  p_no_of_days,
	    OUT  p_settle_dates, OUT  p_premium_amounts, OUT  p_start_dates,
	    OUT  p_initial_bases, OUT  p_bond_issues, OUT  p_coupon_actions,
	    OUT  p_coupon_rates, OUT  p_margins, OUT  p_transaction_rates,
	    OUT  p_coupon_freqs, OUT  p_next_coupon_dates,
	    OUT  p_day_count_bases, OUT  p_quantity_out,
	    OUT  p_rounding_type, OUT p_day_count_type, OUT p_prepaid_interests,
	    IN p_to_date, IN p_from_date;
*/
       ELSE
	  p_appended_where := p_appended_where ||
			' AND deal_date <= :to_date AND (:to_date < end_date
				OR end_date IS NULL)';
          p_select_stmt := p_select_stmt||p_appended_where
					||p_filter_where_clause;
          -- BUG 2945198 - sql bind
          dbms_sql.parse(v_cursor,p_select_stmt,dbms_sql.native);
          dbms_sql.bind_variable(v_cursor,':to_date',p_to_date);
/*
          p_select_stmt := 'BEGIN '||p_select_stmt||';END;';

          IF (g_proc_level>=g_debug_level) THEN
             XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'select stmt: ', p_select_stmt);
          END IF;

          EXECUTE IMMEDIATE p_select_stmt USING OUT  p_deal_nos,
	    OUT  p_transaction_nos, OUT  p_market_data_sets,
	    OUT  p_company_codes, OUT  p_calls_or_puts, OUT  p_pricing_models,
	    OUT  p_deal_ccys, OUT  p_buy_ccys, OUT  p_sell_ccys,
	    OUT  p_foreign_ccys, OUT  p_domestic_ccys, OUT  p_base_ccys,
	    OUT  p_contra_ccys, OUT  p_premium_ccys, OUT  p_buy_amounts,
	    OUT  p_sell_amounts, OUT  p_foreign_amounts, OUT  p_domestic_amounts,
 	    OUT  p_base_amounts,OUT p_contra_amounts, OUT  p_start_amounts,
	    OUT  p_face_values, OUT  p_interests, OUT  p_accum_int_bfs,
	    OUT  p_accum_int_actions, OUT  p_accrued_interests,
	    OUT  p_interests_settled, OUT  p_deal_dates, OUT  p_end_dates,
	    OUT  p_gap_dates, OUT  p_deal_subtypes, OUT  p_deal_types,
	    OUT  p_discount_yields, OUT  p_maturity_dates, OUT  p_no_of_days,
	    OUT  p_settle_dates, OUT  p_premium_amounts, OUT  p_start_dates,
	    OUT  p_initial_bases, OUT  p_bond_issues, OUT  p_coupon_actions,
	    OUT  p_coupon_rates, OUT  p_margins, OUT  p_transaction_rates,
	    OUT  p_coupon_freqs, OUT  p_next_coupon_dates,
	    OUT  p_day_count_bases, OUT  p_quantity_out,
	    OUT  p_rounding_type, OUT p_day_count_type,
	    OUT  p_prepaid_interests, IN p_to_date;
*/

       END IF;
/*
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'NUMBER OF DEALS: ' || p_deal_nos.count);
	END IF;

       FOR i IN 1..p_deal_nos.count LOOP
          IF (g_proc_level>=g_debug_level) THEN
             XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'd_no: '||p_deal_nos(i)||'; t_no: '||p_transaction_nos(i)||'; type: '||p_deal_types(i)||'; end date: '||p_end_dates(i));
          END IF;
       END LOOP;
*/

   ELSIF (p_settings.analysis_type ='G') THEN -- gap analysis
      IF (g_proc_level>=g_debug_level) THEN
         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'Gap Analysis');
      END IF;
      -- cannot filter based on gap date, since haven't calculated yet
      p_appended_where := p_appended_where ||' AND DEAL_TYPE <> ''STOCK''';
      p_select_stmt := p_select_stmt||p_appended_where||p_filter_where_clause;
      -- BUG 2945198 - sql bind
      dbms_sql.parse(v_cursor,p_select_stmt,dbms_sql.native);
/*
      p_select_stmt := 'BEGIN '||p_select_stmt||';END;';

      IF (g_proc_level>=g_debug_level) THEN
         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'select stmt: ', p_select_stmt);
      END IF;

        EXECUTE IMMEDIATE p_select_stmt USING OUT  p_deal_nos,
	OUT  p_transaction_nos, OUT  p_market_data_sets,
	OUT  p_company_codes, OUT  p_calls_or_puts,
	OUT  p_pricing_models, OUT  p_deal_ccys, OUT  p_buy_ccys,
	OUT  p_sell_ccys, OUT  p_foreign_ccys, OUT  p_domestic_ccys,
	OUT  p_base_ccys, OUT  p_contra_ccys, OUT  p_premium_ccys,
	OUT  p_buy_amounts,
	OUT  p_sell_amounts, OUT  p_foreign_amounts, OUT  p_domestic_amounts,
	OUT  p_base_amounts, OUT  p_contra_amounts, OUT  p_start_amounts,
	OUT  p_face_values, OUT  p_interests, OUT  p_accum_int_bfs,
	OUT  p_accum_int_actions, OUT  p_accrued_interests,
	OUT  p_interests_settled, OUT  p_deal_dates, OUT  p_end_dates,
	OUT  p_gap_dates, OUT  p_deal_subtypes, OUT  p_deal_types,
	OUT  p_discount_yields, OUT  p_maturity_dates, OUT  p_no_of_days,
	OUT  p_settle_dates, OUT  p_premium_amounts, OUT  p_start_dates,
	OUT  p_initial_bases, OUT  p_bond_issues,
	OUT  p_coupon_actions, OUT  p_coupon_rates, OUT  p_margins,
	OUT  p_transaction_rates, OUT  p_coupon_freqs,
	OUT  p_next_coupon_dates, OUT  p_day_count_bases, OUT  p_quantity_out,
	OUT  p_rounding_type, OUT p_day_count_type, OUT p_prepaid_interests;

       FOR i IN 1..p_deal_nos.count LOOP
          IF (g_proc_level>=g_debug_level) THEN
             XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'd_no: '||p_deal_nos(i)||'; t_no: '||p_transaction_nos(i)||'; type: '||p_deal_types(i)||'; end date: '||p_end_dates(i));
          END IF;
       END LOOP;
*/
   END IF;


   -- BUG 2945198 - sql bind
   IF (g_proc_level>=g_debug_level) THEN
     XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'select stmt: ', p_select_stmt);
   END IF;

   for p_filter_bindings in get_filter_bindings(p_settings.filter_name) loop
      dbms_sql.bind_variable(v_cursor,':'||to_char(p_filter_bindings.row_number),p_filter_bindings.value);
   end loop;

   n_num_rows_fetched := dbms_sql.execute(v_cursor);

   loop

      dbms_sql.define_array(v_cursor,  1, p_deal_nos,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor,  2, p_transaction_nos,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor,  3, p_market_data_sets,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor,  4, p_company_codes,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor,  5, p_calls_or_puts,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor,  6, p_pricing_models,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor,  7, p_deal_ccys,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor,  8, p_buy_ccys,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor,  9, p_sell_ccys,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 10, p_foreign_ccys,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 11, p_domestic_ccys,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 12, p_base_ccys,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 13, p_contra_ccys,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 14, p_premium_ccys,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 15, p_buy_amounts,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 16, p_sell_amounts,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 17, p_foreign_amounts,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 18, p_domestic_amounts,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 19, p_base_amounts,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 20, p_contra_amounts,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 21, p_start_amounts,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 22, p_face_values,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 23, p_interests,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 24, p_accum_int_bfs,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 25, p_accum_int_actions,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 26, p_accrued_interests,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 27, p_interests_settled,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 28, p_deal_dates,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 29, p_end_dates,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 30, p_gap_dates,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 31, p_deal_subtypes,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 32, p_deal_types,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 33, p_discount_yields,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 34, p_maturity_dates,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 35, p_no_of_days,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 36, p_settle_dates,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 37, p_premium_amounts,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 38, p_start_dates,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 39, p_initial_bases,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 40, p_bond_issues,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 41, p_coupon_actions,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 42, p_coupon_rates,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 43, p_margins,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 44, p_transaction_rates,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 45, p_coupon_freqs,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 46, p_next_coupon_dates,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 47, p_day_count_bases,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 48, p_quantity_out,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 49, p_rounding_type,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 50, p_day_count_type,  p_batch_fetch_size, p_batch_start_index);
      dbms_sql.define_array(v_cursor, 51, p_prepaid_interests,  p_batch_fetch_size, p_batch_start_index);

      n_num_rows_fetched := dbms_sql.fetch_rows(v_cursor);

      dbms_sql.column_value(v_cursor,  1, p_deal_nos);
      dbms_sql.column_value(v_cursor,  2, p_transaction_nos);
      dbms_sql.column_value(v_cursor,  3, p_market_data_sets);
      dbms_sql.column_value(v_cursor,  4, p_company_codes);
      dbms_sql.column_value(v_cursor,  5, p_calls_or_puts);
      dbms_sql.column_value(v_cursor,  6, p_pricing_models);
      dbms_sql.column_value(v_cursor,  7, p_deal_ccys);
      dbms_sql.column_value(v_cursor,  8, p_buy_ccys);
      dbms_sql.column_value(v_cursor,  9, p_sell_ccys);
      dbms_sql.column_value(v_cursor, 10, p_foreign_ccys);
      dbms_sql.column_value(v_cursor, 11, p_domestic_ccys);
      dbms_sql.column_value(v_cursor, 12, p_base_ccys);
      dbms_sql.column_value(v_cursor, 13, p_contra_ccys);
      dbms_sql.column_value(v_cursor, 14, p_premium_ccys);
      dbms_sql.column_value(v_cursor, 15, p_buy_amounts);
      dbms_sql.column_value(v_cursor, 16, p_sell_amounts);
      dbms_sql.column_value(v_cursor, 17, p_foreign_amounts);
      dbms_sql.column_value(v_cursor, 18, p_domestic_amounts);
      dbms_sql.column_value(v_cursor, 19, p_base_amounts);
      dbms_sql.column_value(v_cursor, 20, p_contra_amounts);
      dbms_sql.column_value(v_cursor, 21, p_start_amounts);
      dbms_sql.column_value(v_cursor, 22, p_face_values);
      dbms_sql.column_value(v_cursor, 23, p_interests);
      dbms_sql.column_value(v_cursor, 24, p_accum_int_bfs);
      dbms_sql.column_value(v_cursor, 25, p_accum_int_actions);
      dbms_sql.column_value(v_cursor, 26, p_accrued_interests);
      dbms_sql.column_value(v_cursor, 27, p_interests_settled);
      dbms_sql.column_value(v_cursor, 28, p_deal_dates);
      dbms_sql.column_value(v_cursor, 29, p_end_dates);
      dbms_sql.column_value(v_cursor, 30, p_gap_dates);
      dbms_sql.column_value(v_cursor, 31, p_deal_subtypes);
      dbms_sql.column_value(v_cursor, 32, p_deal_types);
      dbms_sql.column_value(v_cursor, 33, p_discount_yields);
      dbms_sql.column_value(v_cursor, 34, p_maturity_dates);
      dbms_sql.column_value(v_cursor, 35, p_no_of_days);
      dbms_sql.column_value(v_cursor, 36, p_settle_dates);
      dbms_sql.column_value(v_cursor, 37, p_premium_amounts);
      dbms_sql.column_value(v_cursor, 38, p_start_dates);
      dbms_sql.column_value(v_cursor, 39, p_initial_bases);
      dbms_sql.column_value(v_cursor, 40, p_bond_issues);
      dbms_sql.column_value(v_cursor, 41, p_coupon_actions);
      dbms_sql.column_value(v_cursor, 42, p_coupon_rates);
      dbms_sql.column_value(v_cursor, 43, p_margins);
      dbms_sql.column_value(v_cursor, 44, p_transaction_rates);
      dbms_sql.column_value(v_cursor, 45, p_coupon_freqs);
      dbms_sql.column_value(v_cursor, 46, p_next_coupon_dates);
      dbms_sql.column_value(v_cursor, 47, p_day_count_bases);
      dbms_sql.column_value(v_cursor, 48, p_quantity_out);
      dbms_sql.column_value(v_cursor, 49, p_rounding_type);
      dbms_sql.column_value(v_cursor, 50, p_day_count_type);
      dbms_sql.column_value(v_cursor, 51, p_prepaid_interests);


/*
   IF (g_proc_level>=g_debug_level) THEN
      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'made it past select statement');
   END IF;
   IF (p_deal_nos.COUNT = 0) THEN
	retcode := '5';
   END IF;

   FOR i IN 1..p_deal_nos.count LOOP -- extend the temp tables
*/
   IF (g_proc_level>=g_debug_level) THEN
      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'NO OF ROWS RETRIEVED: '||p_deal_nos.count);
      FOR i IN 1..n_num_rows_fetched LOOP
         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'd_no: '||p_deal_nos(i)||'; t_no: '||p_transaction_nos(i)||'; type: '||p_deal_types(i)||'; end date: '||p_end_dates(i));
      END LOOP;
   END IF;


   p_total_deals_counter := p_total_deals_counter + n_num_rows_fetched;
   if (p_total_deals_counter = 0) then
      retcode := '5';
   end if;

   -- Reset counting variables
   p_insert_counter	:= 0;
   p_update_counter	:= 0;
   p_tb_counter         := 0;

   -- Reset holding tables
   p_seq_nos.DELETE;
   p_deal_no_insert.DELETE;
   p_company_code_insert.DELETE;
   p_transaction_no_insert.DELETE;
   p_market_data_set_insert.DELETE;
   p_deal_ccy_insert.DELETE;
   p_sob_ccy_insert.DELETE;
   p_base_ccy_amount_usd_insert.DELETE;
   p_base_ccy_amount_sob_insert.DELETE;
   p_contra_ccy_amount_usd_insert.DELETE;
   p_contra_ccy_amount_sob_insert.DELETE;
   p_foreign_amount_usd_insert.DELETE;
   p_foreign_amount_sob_insert.DELETE;
   p_domestic_amount_usd_insert.DELETE;
   p_domestic_amount_sob_insert.DELETE;
   p_buy_amount_usd_insert.DELETE;
   p_buy_amount_sob_insert.DELETE;
   p_sell_amount_usd_insert.DELETE;
   p_sell_amount_sob_insert.DELETE;
   p_days_insert.DELETE;
   p_fx_reval_rate_insert.DELETE;
   p_reval_price_insert.DELETE;
   p_reval_price_usd_insert.DELETE;
   p_reval_price_sob_insert.DELETE;
   p_mm_reval_rate_insert.DELETE;
   p_fx_trans_rate_insert.DELETE;
   p_trans_price_insert.DELETE;
   p_trans_price_usd_insert.DELETE;
   p_trans_price_sob_insert.DELETE;
   p_mm_trans_rate_insert.DELETE;
   p_fair_value_insert.DELETE;
   p_fair_value_usd_insert.DELETE;
   p_fair_value_sob_insert.DELETE;
   p_gap_amount_insert.DELETE;
   p_gap_amount_usd_insert.DELETE;
   p_gap_amount_sob_insert.DELETE;
   p_maturity_amount_insert.DELETE;
   p_maturity_amount_usd_insert.DELETE;
   p_maturity_amount_sob_insert.DELETE;
   p_premium_amount_usd_insert.DELETE;
   p_premium_amount_sob_insert.DELETE;
   p_accrued_interest_insert.DELETE;
   p_accrued_interest_usd_insert.DELETE;
   p_accrued_interest_sob_insert.DELETE;
   p_duration_insert.DELETE;
   p_mod_duration_insert.DELETE;
   p_convexity_insert.DELETE;
   p_delta_insert.DELETE;
   p_gamma_insert.DELETE;
   p_theta_insert.DELETE;
   p_rho_insert.DELETE;
   p_rho_base_insert.DELETE;
   p_rho_contra_insert.DELETE;
   p_rho_for_insert.DELETE;
   p_rho_dom_insert.DELETE;
   p_vega_insert.DELETE;
   p_pos_bpv_insert.DELETE;
   p_pos_bpv_usd_insert.DELETE;
   p_pos_bpv_sob_insert.DELETE;
   p_pos_delta_insert.DELETE;
   p_pos_delta_usd_insert.DELETE;
   p_pos_delta_sob_insert.DELETE;
   p_pos_gamma_insert.DELETE;
   p_pos_gamma_usd_insert.DELETE;
   p_pos_gamma_sob_insert.DELETE;
   p_pos_theta_insert.DELETE;
   p_pos_theta_usd_insert.DELETE;
   p_pos_theta_sob_insert.DELETE;
   p_pos_rho_insert.DELETE;
   p_pos_rho_usd_insert.DELETE;
   p_pos_rho_sob_insert.DELETE;
   p_pos_rho_base_insert.DELETE;
   p_pos_rho_base_usd_insert.DELETE;
   p_pos_rho_base_sob_insert.DELETE;
   p_pos_rho_contra_insert.DELETE;
   p_pos_rho_contra_usd_insert.DELETE;
   p_pos_rho_contra_sob_insert.DELETE;
   p_pos_rho_for_insert.DELETE;
   p_pos_rho_for_usd_insert.DELETE;
   p_pos_rho_for_sob_insert.DELETE;
   p_pos_rho_dom_insert.DELETE;
   p_pos_rho_dom_usd_insert.DELETE;
   p_pos_rho_dom_sob_insert.DELETE;
   p_pos_vega_insert.DELETE;
   p_pos_vega_usd_insert.DELETE;
   p_pos_vega_sob_insert.DELETE;
   p_volatility_insert.DELETE;
   p_ytm_insert.DELETE;
   p_gap_date_insert.DELETE;

   p_deal_calc_id_update.DELETE;
   p_deal_no_update.DELETE;
   p_company_code_update.DELETE;
   p_transaction_no_update.DELETE;
   p_market_data_set_update.DELETE;
   p_deal_ccy_update.DELETE;
   p_sob_ccy_update.DELETE;
   p_base_ccy_amount_usd_update.DELETE;
   p_base_ccy_amount_sob_update.DELETE;
   p_contra_ccy_amount_usd_update.DELETE;
   p_contra_ccy_amount_sob_update.DELETE;
   p_foreign_amount_usd_update.DELETE;
   p_foreign_amount_sob_update.DELETE;
   p_domestic_amount_usd_update.DELETE;
   p_domestic_amount_sob_update.DELETE;
   p_buy_amount_usd_update.DELETE;
   p_buy_amount_sob_update.DELETE;
   p_sell_amount_usd_update.DELETE;
   p_sell_amount_sob_update.DELETE;
   p_days_update.DELETE;
   p_fx_reval_rate_update.DELETE;
   p_reval_price_update.DELETE;
   p_reval_price_usd_update.DELETE;
   p_reval_price_sob_update.DELETE;
   p_mm_reval_rate_update.DELETE;
   p_fx_trans_rate_update.DELETE;
   p_trans_price_update.DELETE;
   p_trans_price_usd_update.DELETE;
   p_trans_price_sob_update.DELETE;
   p_mm_trans_rate_update.DELETE;
   p_fair_value_update.DELETE;
   p_fair_value_usd_update.DELETE;
   p_fair_value_sob_update.DELETE;
   p_gap_amount_update.DELETE;
   p_gap_amount_usd_update.DELETE;
   p_gap_amount_sob_update.DELETE;
   p_maturity_amount_update.DELETE;
   p_maturity_amount_usd_update.DELETE;
   p_maturity_amount_sob_update.DELETE;
   p_premium_amount_usd_update.DELETE;
   p_premium_amount_sob_update.DELETE;
   p_accrued_interest_update.DELETE;
   p_accrued_interest_usd_update.DELETE;
   p_accrued_interest_sob_update.DELETE;
   p_duration_update.DELETE;
   p_mod_duration_update.DELETE;
   p_convexity_update.DELETE;
   p_delta_update.DELETE;
   p_gamma_update.DELETE;
   p_theta_update.DELETE;
   p_rho_update.DELETE;
   p_rho_base_update.DELETE;
   p_rho_contra_update.DELETE;
   p_rho_for_update.DELETE;
   p_rho_dom_update.DELETE;
   p_vega_update.DELETE;
   p_pos_bpv_update.DELETE;
   p_pos_bpv_usd_update.DELETE;
   p_pos_bpv_sob_update.DELETE;
   p_pos_delta_update.DELETE;
   p_pos_delta_usd_update.DELETE;
   p_pos_delta_sob_update.DELETE;
   p_pos_gamma_update.DELETE;
   p_pos_gamma_usd_update.DELETE;
   p_pos_gamma_sob_update.DELETE;
   p_pos_theta_update.DELETE;
   p_pos_theta_usd_update.DELETE;
   p_pos_theta_sob_update.DELETE;
   p_pos_rho_update.DELETE;
   p_pos_rho_usd_update.DELETE;
   p_pos_rho_sob_update.DELETE;
   p_pos_rho_base_update.DELETE;
   p_pos_rho_base_usd_update.DELETE;
   p_pos_rho_base_sob_update.DELETE;
   p_pos_rho_contra_update.DELETE;
   p_pos_rho_contra_usd_update.DELETE;
   p_pos_rho_contra_sob_update.DELETE;
   p_pos_rho_for_update.DELETE;
   p_pos_rho_for_usd_update.DELETE;
   p_pos_rho_for_sob_update.DELETE;
   p_pos_rho_dom_update.DELETE;
   p_pos_rho_dom_usd_update.DELETE;
   p_pos_rho_dom_sob_update.DELETE;
   p_pos_vega_update.DELETE;
   p_pos_vega_usd_update.DELETE;
   p_pos_vega_sob_update.DELETE;
   p_volatility_update.DELETE;
   p_ytm_update.DELETE;
   p_gap_date_update.DELETE;
   p_upd_md_calc_date_update.DELETE;

   p_tb_deal_no.DELETE;
   p_tb_transaction_no.DELETE;
   p_tb_market_data_set.DELETE;
   p_tb_pos_start_date.DELETE;
   p_tb_pos_end_date.DELETE;
   p_tb_start_date.DELETE;
   p_tb_end_date.DELETE;
   p_tb_outst_amount.DELETE;
   p_tb_outst_amount_usd.DELETE;
   p_tb_outst_amount_sob.DELETE;
   p_tb_amt_qty_out.DELETE;
   p_tb_amt_qty_out_usd.DELETE;
   p_tb_amt_qty_out_sob.DELETE;
   p_tb_interest_basis.DELETE;
   p_tb_coupon_rate.DELETE;
   p_tb_next_coupon_date.DELETE;


   FOR i IN p_deal_no_temp.count ..n_num_rows_fetched LOOP -- extend the temp tables
   -- END BUG 2945198 - sql binding

      -- for qrm_deal_calculations table only
      p_deal_no_temp.EXTEND;
      p_company_code_temp.EXTEND;
      p_transaction_no_temp.EXTEND;
      p_market_data_set_temp.EXTEND;
      p_deal_ccy_temp.EXTEND;
      p_sob_ccy_temp.EXTEND;
      p_base_ccy_amount_usd_temp.EXTEND;
      p_base_ccy_amount_sob_temp.EXTEND;
      p_contra_ccy_amount_usd_temp.EXTEND;
      p_contra_ccy_amount_sob_temp.EXTEND;
      p_foreign_amount_usd_temp.EXTEND;
      p_foreign_amount_sob_temp.EXTEND;
      p_domestic_amount_usd_temp.EXTEND;
      p_domestic_amount_sob_temp.EXTEND;
      p_buy_amount_usd_temp.EXTEND;
      p_buy_amount_sob_temp.EXTEND;
      p_sell_amount_usd_temp.EXTEND;
      p_sell_amount_sob_temp.EXTEND;
      p_days_temp.EXTEND;
      p_fx_reval_rate_temp.EXTEND;
      p_mm_reval_rate_temp.EXTEND;
      p_fx_trans_rate_temp.EXTEND;
      p_mm_trans_rate_temp.EXTEND;
      p_trans_price_temp.EXTEND;
      p_trans_price_usd_temp.EXTEND;
      p_trans_price_sob_temp.EXTEND;
      p_reval_price_temp.EXTEND;
      p_reval_price_usd_temp.EXTEND;
      p_reval_price_sob_temp.EXTEND;
      p_fair_value_temp.EXTEND;
      p_fair_value_usd_temp.EXTEND;
      p_fair_value_sob_temp.EXTEND;
      p_gap_amount_temp.EXTEND;
      p_gap_amount_usd_temp.EXTEND;
      p_gap_amount_sob_temp.EXTEND;
      p_maturity_amount_temp.EXTEND;
      p_maturity_amount_usd_temp.EXTEND;
      p_maturity_amount_sob_temp.EXTEND;
      p_premium_amount_usd_temp.EXTEND;
      p_premium_amount_sob_temp.EXTEND;
      p_accrued_interest_temp.EXTEND;
      p_accrued_interest_usd_temp.EXTEND;
      p_accrued_interest_sob_temp.EXTEND;
      p_duration_temp.EXTEND;
      p_mod_duration_temp.EXTEND;
      p_convexity_temp.EXTEND;
      p_delta_temp.EXTEND;
      p_gamma_temp.EXTEND;
      p_theta_temp.EXTEND;
      p_rho_temp.EXTEND;
      p_rho_base_temp.EXTEND;
      p_rho_contra_temp.EXTEND;
      p_rho_for_temp.EXTEND;
      p_rho_dom_temp.EXTEND;
      p_vega_temp.EXTEND;
      p_pos_bpv_temp.EXTEND;
      p_pos_bpv_usd_temp.EXTEND;
      p_pos_bpv_sob_temp.EXTEND;
      p_pos_delta_temp.EXTEND;
      p_pos_delta_usd_temp.EXTEND;
      p_pos_delta_sob_temp.EXTEND;
      p_pos_gamma_temp.EXTEND;
      p_pos_gamma_usd_temp.EXTEND;
      p_pos_gamma_sob_temp.EXTEND;
      p_pos_theta_temp.EXTEND;
      p_pos_theta_usd_temp.EXTEND;
      p_pos_theta_sob_temp.EXTEND;
      p_pos_rho_temp.EXTEND;
      p_pos_rho_usd_temp.EXTEND;
      p_pos_rho_sob_temp.EXTEND;
      p_pos_rho_base_temp.EXTEND;
      p_pos_rho_base_usd_temp.EXTEND;
      p_pos_rho_base_sob_temp.EXTEND;
      p_pos_rho_contra_temp.EXTEND;
      p_pos_rho_contra_usd_temp.EXTEND;
      p_pos_rho_contra_sob_temp.EXTEND;
      p_pos_rho_for_temp.EXTEND;
      p_pos_rho_for_usd_temp.EXTEND;
      p_pos_rho_for_sob_temp.EXTEND;
      p_pos_rho_dom_temp.EXTEND;
      p_pos_rho_dom_usd_temp.EXTEND;
      p_pos_rho_dom_sob_temp.EXTEND;
      p_pos_vega_temp.EXTEND;
      p_pos_vega_usd_temp.EXTEND;
      p_pos_vega_sob_temp.EXTEND;
      p_ytm_temp.EXTEND;
      p_gap_date_temp.EXTEND;
      p_upd_md_calc_date_temp.EXTEND;
      p_volatility_temp.EXTEND;
   END LOOP;

-- FOR i IN 1..p_deal_nos.count LOOP -- loop through each selected deal
   FOR i IN 1..n_num_rows_fetched LOOP -- loop through each selected deal
     BEGIN
       -- logic for determing market data set:
       -- if mds specified in settings, use it for all deals
       -- else, if mds defined on deal level, use it
       -- else, use mds defined on company level (is always defined there)
       IF (p_settings.md_set_code IS NOT NULL) THEN
          p_market_data_set_temp(i) := p_settings.md_set_code;
       ELSIF (p_market_data_sets(i) IS NOT NULL) THEN
	  p_market_data_set_temp(i) := p_market_data_sets(i);
       ELSE
	  OPEN get_company_mds(p_company_codes(i));
	  FETCH get_company_mds INTO p_market_data_set_temp(i);
	  CLOSE get_company_mds;
       END IF;

       -- get threshold date for analysis
       -- threshold only affects recalculation of fair values,sensitivities,
       -- reval rate, and volatility
       p_threshold_date := get_threshold_date(p_ref_datetime,
		p_settings.threshold_num, p_settings.threshold_type);
       IF (g_proc_level>=g_debug_level) THEN
          XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'ref datetime', p_ref_datetime);
          XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'threshold date', p_threshold_date);
       END IF;
       -- check to see if deal has been calculated previously
       OPEN deal_calculated(p_deal_nos(i), p_transaction_nos(i),
		p_market_data_set_temp(i));
       FETCH deal_calculated INTO p_deal_calculations;
       IF (deal_calculated%FOUND) THEN -- deal previously calculated
	  IF (g_proc_level>=g_debug_level) THEN
	     XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'previously calculated: '||p_deal_nos(i));
	  END IF;
          OPEN deal_threshold_ok(p_deal_nos(i), p_transaction_nos(i),
		p_market_data_set_temp(i), p_threshold_date);
          FETCH deal_threshold_ok INTO p_deal_calc_id;
          IF (deal_threshold_ok%NOTFOUND) THEN -- but doesn't meet threshold
	     IF (g_proc_level>=g_debug_level) THEN
	        XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'doesnt meet threshold, need to update');
	     END IF;
	     p_insert_or_update := 'U';  -- update calculations
	  ELSE
	     IF (g_proc_level>=g_debug_level) THEN
	        XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'threshold met');
	     END IF;
             p_insert_or_update := 'N';  -- threshold met, do nothing
	     p_threshold_counter := p_threshold_counter + 1;
          END IF;
          CLOSE deal_threshold_ok;
       ELSE -- deal not previously calculated
	  IF (g_proc_level>=g_debug_level) THEN
	     XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'never calculated before: '||p_deal_nos(i));
	  END IF;
          p_insert_or_update := 'I';  -- insert deal calculations
       END IF;
       CLOSE deal_calculated;


     -- calculate Gap Date
     IF (p_deal_types(i) IN ('FX', 'FXO', 'STOCK')) THEN
	 null; -- do nothing, no gap dates for FX/FXO
     ELSE
	 IF (p_deal_types(i) IN ('TMM', 'IRS', 'RTMM')) THEN
	     p_gap_date_temp(i) := get_gap_date(p_deal_nos(i),
			p_deal_types(i), p_initial_bases(i), p_ref_date);
	 ELSIF (p_deal_types(i)='ONC') THEN
             --bug 2637950
             IF (p_start_dates(i)>p_ref_date) THEN
               p_gap_date_temp(i) := p_start_dates(i)+1;
             ELSE
	       p_gap_date_temp(i) := NVL(p_maturity_dates(i), p_ref_date+1);
             END IF;
	 ELSIF (p_deal_types(i)='IG') THEN
             p_gap_date_temp(i) := p_ref_date+1;
         ELSE -- other deals: gap date already mapped in qrm_current_deals_v
	     p_gap_date_temp(i) := p_gap_dates(i);
         END IF;
     END IF;
     IF (g_proc_level>=g_debug_level) THEN
        XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'deal no: '||p_deal_nos(i));
        XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'calculated Gap Date', p_gap_date_temp(i));
     END IF;

     p_gap_req_ok := TRUE;    -- assume deal passes gap analysis requirements
     -- If Gap Analysis, use calculated gap date to further filter
     -- If other analysis, then automatically passes gap analysis requirements
     IF (p_settings.analysis_type='G') THEN
        IF (NOT((p_from_date<=p_gap_date_temp(i)) AND
	        (p_gap_date_temp(i)<=p_to_date))) THEN
	   -- deal does not match Gap Analysis requirements
	   p_gap_req_ok := FALSE;
	END IF;
     ELSE
        p_gap_req_ok := TRUE;
     END IF;

     IF (p_gap_req_ok) THEN  -- passed gap date test
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'passed gap date test');
	END IF;

	p_gap_deal_exists := TRUE;
	p_temp_counter := p_temp_counter + 1;
	-- deal no
	p_deal_no_temp(i) := p_deal_nos(i);
	-- company code
	p_company_code_temp(i) := p_company_codes(i);
        -- trans no
	p_transaction_no_temp(i) := p_transaction_nos(i);

	-- deal currencies: ok for MM deals, null for FX/FXO
	p_deal_ccy_temp(i) := p_deal_ccys(i);

        -- get SOB ccy -- SOB ccy is *always* defined
	OPEN get_sob_ccy(p_company_codes(i));
        FETCH get_sob_ccy INTO p_sob_ccy_temp(i);
	CLOSE get_sob_ccy;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'sob ccy: ' || p_sob_ccy_temp(i));
	   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'STARTING CALCULATION FOR deal no: '||p_deal_nos(i)||', trans no: '||p_transaction_nos(i));
	END IF;
	-- get day count and annual basis set up first
 	days_run_helper(p_ref_date, p_end_dates(i),
		p_day_count_bases(i), NULL, p_day_count, p_annual_basis);

        -- calculate days from ref date to end date, days to maturity
        p_days_temp(i) := NVL(p_end_dates(i), p_ref_date+1) - p_ref_date;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'end date: '||p_end_dates(i)||',ref_date: '||p_ref_date||', days: '||p_days_temp(i));
	   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'market data set is: '||p_market_data_set_temp(i));
	   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'pricing model is: '||p_pricing_models(i));
           XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'deal type still: '||p_deal_types(i));
        END IF;

            IF (p_deal_types(i) IN ('FX', 'FXO')) THEN
	       -- transaction rates
	       p_fx_trans_rate_temp(i) := p_transaction_rates(i);

 	       -- convert currency amounts for buy/sell ccy
	       IF (p_buy_ccys(i)<>'USD') THEN
                  -- convert amount to USD
		  convert_amounts(p_market_data_set_temp(i), p_ref_date,
		      p_buy_ccys(i), 'USD', p_buy_amounts(i),
		      p_buy_amount_usd_temp(i));
	       ELSE
		  p_buy_amount_usd_temp(i) := p_buy_amounts(i);
               END IF;
               -- calculate buy amount in sob ccy
	       IF (p_sob_ccy_temp(i)=p_buy_ccys(i)) THEN
                  p_buy_amount_sob_temp(i) := p_buy_amounts(i);
               ELSIF (p_sob_ccy_temp(i)='USD') THEN
                  p_buy_amount_sob_temp(i) := p_buy_amount_usd_temp(i);
               ELSE
		 convert_amounts(p_market_data_set_temp(i), p_ref_date,
		     p_buy_ccys(i), p_sob_ccy_temp(i), p_buy_amounts(i),
		     p_buy_amount_sob_temp(i));
 	       END IF;
	       -- do SELL ccy now
	       IF (p_sell_ccys(i)<>'USD') THEN
                 convert_amounts(p_market_data_set_temp(i), p_ref_date,
		     p_sell_ccys(i), 'USD', p_sell_amounts(i),
		     p_sell_amount_usd_temp(i));
	       ELSE
		  p_sell_amount_usd_temp(i) := p_sell_amounts(i);
               END IF;
	       -- calculate sell amount in sob ccy
	       IF (p_sob_ccy_temp(i)=p_sell_ccys(i)) THEN
                  p_sell_amount_sob_temp(i) := p_sell_amounts(i);
               ELSIF (p_sob_ccy_temp(i)='USD') THEN
                  p_sell_amount_sob_temp(i) := p_sell_amount_usd_temp(i);
               ELSE
		 convert_amounts(p_market_data_set_temp(i), p_ref_date,
		   p_sell_ccys(i), p_sob_ccy_temp(i), p_sell_amounts(i),
	 	   p_sell_amount_sob_temp(i));
	       END IF;

	       -- convert base/contra amounts to other currencies
               IF (p_base_ccys(i)=p_sell_ccys(i)) THEN
		  p_base_ccy_amount_usd_temp(i) := p_sell_amount_usd_temp(i);
                  p_contra_ccy_amount_usd_temp(i) := p_buy_amount_usd_temp(i);
                  p_base_ccy_amount_sob_temp(i) := p_sell_amount_sob_temp(i);
                  p_contra_ccy_amount_sob_temp(i) := p_buy_amount_sob_temp(i);
               ELSE
		  p_base_ccy_amount_usd_temp(i) := p_buy_amount_usd_temp(i);
                  p_contra_ccy_amount_usd_temp(i) := p_sell_amount_usd_temp(i);
                  p_base_ccy_amount_sob_temp(i) := p_buy_amount_sob_temp(i);
                  p_contra_ccy_amount_sob_temp(i) := p_sell_amount_sob_temp(i);
               END IF;


	       -- FXO DEALS
	       IF (p_deal_types(i)='FXO') THEN
		   -- deal ccy is premium ccy
		   p_deal_ccy_temp(i) := p_premium_ccys(i);
                   IF (p_foreign_ccys(i)=p_buy_ccys(i)) THEN
		       p_foreign_amount_usd_temp(i) := p_buy_amount_usd_temp(i);
                       p_domestic_amount_usd_temp(i) := p_sell_amount_usd_temp(i);
                       p_foreign_amount_sob_temp(i) := p_buy_amount_sob_temp(i);
                       p_domestic_amount_sob_temp(i) := p_sell_amount_sob_temp(i);
                   ELSE
		       p_foreign_amount_usd_temp(i) := p_sell_amount_usd_temp(i);
                       p_domestic_amount_usd_temp(i) := p_buy_amount_usd_temp(i);
                       p_foreign_amount_sob_temp(i) := p_sell_amount_sob_temp(i);
                       p_domestic_amount_sob_temp(i) := p_buy_amount_sob_temp(i);
                   END IF;

		   -- fair value for FXO in premium ccy
		   -- deal ccy is premium ccy
		   IF (p_insert_or_update <> 'N') THEN
                      QRM_FX_FORMULAS.fv_fxo(p_pricing_models(i),
		         p_deal_subtypes(i), p_calls_or_puts(i),
		         p_market_data_set_temp(i), p_foreign_ccys(i),
		         p_premium_ccys(i), p_buy_ccys(i),
		         p_sell_ccys(i),p_interpolation_method,p_ref_date,
		         p_end_dates(i),p_transaction_rates(i),
		         p_foreign_amounts(i), p_side,
		         p_fx_reval_rate_temp(i), p_fair_value_temp(i));
		      -- fair value is in premium ccy
		      -- convert to other ccys
                      -- convert fair value into USD ccy
                      IF (p_premium_ccys(i)='USD') THEN
                         p_fair_value_usd_temp(i) := p_fair_value_temp(i);
                      ELSE
		         convert_amounts(p_market_data_set_temp(i),
				p_ref_date, p_premium_ccys(i), 'USD',
				p_fair_value_temp(i),p_fair_value_usd_temp(i));
		      END IF;
		      -- convert fair value into SOB ccy
		      IF (p_premium_ccys(i)=p_sob_ccy_temp(i)) THEN
		         p_fair_value_sob_temp(i) := p_fair_value_temp(i);
                      ELSIF ('USD'=p_sob_ccy_temp(i)) THEN
	                 p_fair_value_sob_temp(i) := p_fair_value_usd_temp(i);
	              ELSE
	                 convert_amounts(p_market_data_set_temp(i),
				p_ref_date, p_premium_ccys(i),
				p_sob_ccy_temp(i), p_fair_value_temp(i),
				p_fair_value_sob_temp(i));
	              END IF;

	              -- **** sensitivities for FXO **** ---
		      p_gk_in.p_spot_date := p_ref_date;
	              p_gk_in.p_maturity_date := p_end_dates(i);
 	              p_gk_in.p_ccy_for := p_foreign_ccys(i);
		      p_gk_in.p_ccy_dom := p_domestic_ccys(i);
		      -- get foreign ccy int rate
		      p_md_in.p_md_set_code := p_market_data_set_temp(i);
                      p_md_in.p_source := 'C';
                      p_md_in.p_indicator := 'Y';
                      p_md_in.p_spot_date := p_ref_date;
                      p_md_in.p_future_date := p_end_dates(i);
                      p_md_in.p_ccy := p_foreign_ccys(i);
	              p_md_in.p_day_count_basis_out := p_fxo_day_count_basis;
		      p_md_in.p_interpolation_method := p_interpolation_method;
                      p_md_in.p_side := p_side;
                      XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
                      p_gk_in.p_rate_for := p_md_out.p_md_out;
	              IF (within_one_year(p_ref_date, p_end_dates(i))) THEN
		         p_gk_in.p_rate_type_for := 'S';
		      ELSE
	  	         p_gk_in.p_rate_type_for := 'P';
		         p_gk_in.p_compound_freq_for := 1;
		      END IF;
		      p_gk_in.p_day_count_basis_for := p_fxo_day_count_basis;
		      IF (g_proc_level>=g_debug_level) THEN
		         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'base int rate is:' ||p_gk_in.p_rate_for);
		      END IF;
                      -- get domestic ccy int rate
--		      XTR_RISK_DEBUG_PKG.dlog('calculating fxo domestic int rate');
	              p_md_in.p_ccy := p_domestic_ccys(i);
		      XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
                      p_gk_in.p_rate_dom := p_md_out.p_md_out;
		      IF (within_one_year(p_ref_date, p_end_dates(i))) THEN
		         p_gk_in.p_rate_type_dom := 'S';
		      ELSE
		      	 p_gk_in.p_rate_type_dom := 'P';
		         p_gk_in.p_compound_freq_dom := 1;
		      END IF;
		      p_gk_in.p_day_count_basis_dom := p_fxo_day_count_basis;
		      IF (g_proc_level>=g_debug_level) THEN
		         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'contra int rate:' ||p_gk_in.p_rate_dom);
		      END IF;
	              -- get spot rate
--		      XTR_RISK_DEBUG_PKG.dlog('calculating fxo spot rate');
	              p_md_in.p_indicator := 'S';
		      p_md_in.p_ccy := p_foreign_ccys(i);
                      p_md_in.p_contra_ccy := p_domestic_ccys(i);
		      XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
 		      p_gk_in.p_spot_rate := p_md_out.p_md_out;
		      IF (g_proc_level>=g_debug_level) THEN
		         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'fxo spot rate:'||p_gk_in.p_spot_rate);
		      END IF;
		      -- get volatility
--		      XTR_RISK_DEBUG_PKG.dlog('calculating fxo volatility');
                      p_md_in.p_indicator := 'V';
 	              XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
 		      p_volatility_temp(i) := p_md_out.p_md_out;

		      p_gk_in.p_volatility := p_md_out.p_md_out;
		      p_gk_in.p_strike_rate := p_transaction_rates(i);
		      IF (g_proc_level>=g_debug_level) THEN
		         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'fxo volatility:'||p_gk_in.p_volatility);
		         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'fxo strike rate:'||p_gk_in.p_strike_rate);
		      END IF;
                      QRM_FX_FORMULAS.fx_gk_option_sens_cv(p_gk_in, p_gk_out);
		      IF (p_calls_or_puts(i)='C') THEN
		       	 p_delta_temp(i) := p_gk_out.p_delta_call;
                         p_theta_temp(i) := p_gk_out.p_theta_call;
                         p_rho_for_temp(i) := p_gk_out.p_rho_f_call;
                         p_rho_dom_temp(i) := p_gk_out.p_rho_call;
                      ELSE
		         p_delta_temp(i) := p_gk_out.p_delta_put;
                         p_theta_temp(i) := p_gk_out.p_theta_put;
                         p_rho_for_temp(i) := p_gk_out.p_rho_f_put;
                         p_rho_dom_temp(i) := p_gk_out.p_rho_put;
                      END IF;
		      p_gamma_temp(i) := p_gk_out.p_gamma;
		      p_vega_temp(i) := p_gk_out.p_vega;
		      IF (g_proc_level>=g_debug_level) THEN
		         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'deal no: '||p_deal_nos(i));
		         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'reval rate: '||p_fx_reval_rate_temp(i));
		         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'fxo fair value: '||p_fair_value_temp(i));
		         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'delta: '||p_delta_temp(i));
                         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'theta: '||p_theta_temp(i));
		         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'rho for: '||p_rho_for_temp(i));
                         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'rho dom: '||p_rho_dom_temp(i));
		         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'gamma: '||p_gamma_temp(i));
		         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'vega: '||p_vega_temp(i));
		      END IF;

	              -- position delta in domestic ccy (default)
		      p_pos_delta_temp(i) := p_delta_temp(i)*
					     ABS(p_foreign_amounts(i));
		      -- position delta in usd ccy
                      IF (p_domestic_ccys(i)='USD') THEN
                  	 p_pos_delta_usd_temp(i) := p_pos_delta_temp(i);
                      ELSE
		         convert_amounts(p_market_data_set_temp(i),
			 	p_ref_date, p_domestic_ccys(i), 'USD',
				p_pos_delta_temp(i), p_pos_delta_usd_temp(i));
		      END IF;
		      -- position delta in sob ccy
                      IF (p_domestic_ccys(i) = p_sob_ccy_temp(i)) THEN
                      	 p_pos_delta_sob_temp(i) := p_pos_delta_temp(i);
                      ELSE
		      	 convert_amounts(p_market_data_set_temp(i),
				p_ref_date, p_domestic_ccys(i),
				p_sob_ccy_temp(i), p_pos_delta_temp(i),
				p_pos_delta_sob_temp(i));
		      END IF;

		      -- position gamma in domestic ccy (default)
		      p_pos_gamma_temp(i) := p_gamma_temp(i)*
					     ABS(p_foreign_amounts(i));
		      -- position gamma in usd ccy
                      IF (p_domestic_ccys(i)='USD') THEN
                      	 p_pos_gamma_usd_temp(i) := p_pos_gamma_temp(i);
                      ELSE
		      	 convert_amounts(p_market_data_set_temp(i),
				p_ref_date, p_domestic_ccys(i), 'USD',
				p_pos_gamma_temp(i), p_pos_gamma_usd_temp(i));
		      END IF;
		      -- position gamma in sob ccy
                      IF (p_domestic_ccys(i) = p_sob_ccy_temp(i)) THEN
                      	 p_pos_gamma_sob_temp(i) := p_pos_gamma_temp(i);
                      ELSE
		      	 convert_amounts(p_market_data_set_temp(i),
				p_ref_date, p_domestic_ccys(i),
				p_sob_ccy_temp(i), p_pos_gamma_temp(i),
				p_pos_gamma_sob_temp(i));
		      END IF;

		      -- position theta in domestic ccy (default)
		      p_pos_theta_temp(i) := p_theta_temp(i)*
					     ABS(p_foreign_amounts(i));
		      -- position theta in usd ccy
                      IF (p_domestic_ccys(i)='USD') THEN
                      	 p_pos_theta_usd_temp(i) := p_pos_theta_temp(i);
                      ELSE
		      	 convert_amounts(p_market_data_set_temp(i),
				p_ref_date, p_domestic_ccys(i), 'USD',
				p_pos_theta_temp(i), p_pos_theta_usd_temp(i));
		      END IF;
		      -- position theta in sob ccy
                      IF (p_domestic_ccys(i) = p_sob_ccy_temp(i)) THEN
                      	    p_pos_theta_sob_temp(i) := p_pos_theta_temp(i);
                      ELSE
		      	    convert_amounts(p_market_data_set_temp(i),
				p_ref_date, p_domestic_ccys(i),
				p_sob_ccy_temp(i), p_pos_theta_temp(i),
				p_pos_theta_sob_temp(i));
		      END IF;

	              -- position Rho Foreign in domestic ccy (default)
		      p_pos_rho_for_temp(i) := p_rho_for_temp(i)*
					       ABS(p_foreign_amounts(i));
		      -- position rho foreign in usd ccy
                      IF (p_domestic_ccys(i)='USD') THEN
                      	 p_pos_rho_for_usd_temp(i) := p_pos_rho_for_temp(i);
                      ELSE
		      	 convert_amounts(p_market_data_set_temp(i),
				p_ref_date, p_domestic_ccys(i), 'USD',
				p_pos_rho_for_temp(i),
				p_pos_rho_for_usd_temp(i));
		      END IF;
		      -- position rho foreign in sob ccy
                      IF (p_domestic_ccys(i) = p_sob_ccy_temp(i)) THEN
                      	 p_pos_rho_for_sob_temp(i) := p_pos_rho_for_temp(i);
                      ELSE
		      	 convert_amounts(p_market_data_set_temp(i),
				p_ref_date, p_domestic_ccys(i),
				p_sob_ccy_temp(i), p_pos_rho_for_temp(i),
				p_pos_rho_for_sob_temp(i));
		      END IF;

		      -- position Rho Domestic in domestic ccy (default)
                      p_pos_rho_dom_temp(i) := p_rho_dom_temp(i)*
					       ABS(p_foreign_amounts(i));
		      -- position rho domestic in usd ccy
                      IF (p_domestic_ccys(i)='USD') THEN
                      	 p_pos_rho_dom_usd_temp(i) := p_pos_rho_dom_temp(i);
                      ELSE
		      	 convert_amounts(p_market_data_set_temp(i),
				p_ref_date, p_domestic_ccys(i), 'USD',
				p_pos_rho_dom_temp(i),
				p_pos_rho_dom_usd_temp(i));
		      END IF;
		      -- position rho domestic in sob ccy
                      IF (p_domestic_ccys(i) = p_sob_ccy_temp(i)) THEN
                      	 p_pos_rho_dom_sob_temp(i) := p_pos_rho_dom_temp(i);
                      ELSE
		      	 convert_amounts(p_market_data_set_temp(i),
				p_ref_date, p_domestic_ccys(i),
				p_sob_ccy_temp(i), p_pos_rho_dom_temp(i),
				p_pos_rho_dom_sob_temp(i));
		      END IF;

		      -- position Vega (in domestic ccy)
		      p_pos_vega_temp(i) := p_vega_temp(i)*
					    ABS(p_foreign_amounts(i));
		      -- position vega in usd ccy
                      IF (p_domestic_ccys(i)='USD') THEN
                      	 p_pos_vega_usd_temp(i) := p_pos_vega_temp(i);
                      ELSE
		      	 convert_amounts(p_market_data_set_temp(i),
				p_ref_date, p_domestic_ccys(i), 'USD',
				p_pos_vega_temp(i), p_pos_vega_usd_temp(i));
		      END IF;
		      -- position rho domestic in sob ccy
                      IF (p_domestic_ccys(i) = p_sob_ccy_temp(i)) THEN
                      	 p_pos_vega_sob_temp(i) := p_pos_vega_temp(i);
                      ELSE
		      	 convert_amounts(p_market_data_set_temp(i),
				p_ref_date, p_domestic_ccys(i),
				p_sob_ccy_temp(i), p_pos_vega_temp(i),
				p_pos_vega_sob_temp(i));
		      END IF;
		      p_upd_md_calc_date_temp(i) := p_ref_datetime;
		   ELSE
		      p_insert_or_update := 'U';
		      p_upd_md_calc_date_temp(i) := p_deal_calculations.last_md_calc_date;
		      p_fair_value_temp(i) := p_deal_calculations.fair_value;
		      p_fair_value_usd_temp(i) := p_deal_calculations.fair_value_usd;
		      p_fair_value_sob_temp(i) := p_deal_calculations.fair_value_sob;
		      p_fx_reval_rate_temp(i) := p_deal_calculations.fx_reval_rate;
		      p_volatility_temp(i) := p_deal_calculations.volatility;
		      p_delta_temp(i) := p_deal_calculations.delta;
		      p_theta_temp(i) := p_deal_calculations.theta;
		      p_rho_for_temp(i) := p_deal_calculations.rho_foreign;
		      p_rho_dom_temp(i) := p_deal_calculations.rho_domestic;
		      p_gamma_temp(i) := p_deal_calculations.gamma;
		      p_vega_temp(i) := p_deal_calculations.vega;
		      p_pos_delta_temp(i) := p_deal_calculations.pos_delta;
		      p_pos_delta_usd_temp(i) := p_deal_calculations.pos_delta_usd;
		      p_pos_delta_sob_temp(i) := p_deal_calculations.pos_delta_sob;
		      p_pos_theta_temp(i) := p_deal_calculations.pos_theta;
		      p_pos_theta_usd_temp(i) := p_deal_calculations.pos_theta_usd;
		      p_pos_theta_sob_temp(i) := p_deal_calculations.pos_theta_sob;
		      p_pos_rho_for_temp(i) := p_deal_calculations.pos_rho_foreign;
		      p_pos_rho_for_usd_temp(i) := p_deal_calculations.pos_rho_foreign_usd;
		      p_pos_rho_for_sob_temp(i) := p_deal_calculations.pos_rho_foreign_sob;
		      p_pos_rho_dom_temp(i) := p_deal_calculations.pos_rho_domestic;
		      p_pos_rho_dom_usd_temp(i) := p_deal_calculations.pos_rho_domestic_usd;
		      p_pos_rho_dom_sob_temp(i) := p_deal_calculations.pos_rho_domestic_sob;
		      p_pos_gamma_temp(i) := p_deal_calculations.pos_gamma;
		      p_pos_gamma_usd_temp(i) := p_deal_calculations.pos_gamma_usd;
		      p_pos_gamma_sob_temp(i) := p_deal_calculations.pos_gamma_sob;
		      p_pos_vega_temp(i) := p_deal_calculations.pos_vega;
		      p_pos_vega_usd_temp(i) := p_deal_calculations.pos_vega_usd;
		      p_pos_vega_sob_temp(i) := p_deal_calculations.pos_vega_sob;

		   END IF;  -- end threshold fv/sens calculations

		   -- convert premium amount to USD
                   IF (p_premium_ccys(i)='USD') THEN
                      p_premium_amount_usd_temp(i) := p_premium_amounts(i);
                   ELSE
		      convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_premium_ccys(i), 'USD', p_premium_amounts(i),
			p_premium_amount_usd_temp(i));
		   END IF;
		   -- convert premium amount into SOB ccy
		   IF (p_premium_ccys(i)=p_sob_ccy_temp(i)) THEN
		      p_premium_amount_sob_temp(i) := p_premium_amounts(i);
                   ELSIF ('USD'=p_sob_ccy_temp(i)) THEN
		      p_premium_amount_sob_temp(i) := p_premium_amount_usd_temp(i);
		   ELSE
		      convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_premium_ccys(i), p_sob_ccy_temp(i),
			p_premium_amounts(i), p_premium_amount_sob_temp(i));
		   END IF;


		ELSE -- FX DEALS
		   -- reset deal ccy to SOB currency
		   p_deal_ccy_temp(i) := p_sob_ccy_temp(i);

		   days_run_helper(p_ref_date, p_end_dates(i),
			p_fx_day_count_basis, null, p_day_count,
			p_annual_basis);

		   -- domestic ccy int rate bid
		   p_md_in.p_md_set_code := p_market_data_set_temp(i);
		   p_md_in.p_source := 'C';
		   p_md_in.p_indicator := 'Y';
		   p_md_in.p_spot_date := p_ref_date;
		   p_md_in.p_future_date := p_end_dates(i);
                   p_md_in.p_ccy := p_contra_ccys(i);
                   p_md_in.p_day_count_basis_out := p_fx_day_count_basis;
                   p_md_in.p_interpolation_method := p_interpolation_method;
                   p_md_in.p_side := 'B';
                   XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
		   p_int_rate_b_bid := p_md_out.p_md_out;
		   -- contra ccy int rate ask
		   p_md_in.p_side := 'A';
		   XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
		   p_int_rate_b_ask := p_md_out.p_md_out;
		   -- base ccy int rate bid
		   p_md_in.p_side := 'B';
		   p_md_in.p_ccy := p_base_ccys(i);
		   XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
		   p_int_rate_a_bid := p_md_out.p_md_out;
		   -- base ccy int rate ask
		   p_md_in.p_side := 'A';
		   p_md_in.p_ccy := p_base_ccys(i);
		   XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
		   p_int_rate_a_ask := p_md_out.p_md_out;
		   -- usd int rate bid
		   p_md_in.p_side := 'B';
		   p_md_in.p_ccy := p_base_ccys(i);
		   XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
		   p_int_rate_c_bid := p_md_out.p_md_out;
	 	   p_md_in.p_side := 'A';
		   p_md_in.p_ccy := p_base_ccys(i);
		   XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
		   p_int_rate_c_ask := p_md_out.p_md_out;

		   -- base ccy discount factor bid
		   p_df_in.p_indicator := 'T';
                   p_df_in.p_rate := p_int_rate_a_bid;
		   p_df_in.p_spot_date := p_ref_date;
		   p_df_in.p_future_date := p_end_dates(i);
		   p_df_in.p_day_count_basis := p_fx_day_count_basis;
		   XTR_RATE_CONVERSION.discount_factor_conv(p_df_in,p_df_out);
		   p_df_a_bid := p_df_out.p_result;
		   -- base ccy discount factor ask
		   p_df_in.p_indicator := 'T';
                   p_df_in.p_rate := p_int_rate_a_ask;
		   p_df_in.p_spot_date := p_ref_date;
		   p_df_in.p_future_date := p_end_dates(i);
		   p_df_in.p_day_count_basis := p_fx_day_count_basis;
		   XTR_RATE_CONVERSION.discount_factor_conv(p_df_in,p_df_out);
		   p_df_a_ask := p_df_out.p_result;
		   -- contra ccy discount factor bid
		   p_df_in.p_rate := p_int_rate_b_bid;
		   XTR_RATE_CONVERSION.discount_factor_conv(p_df_in,p_df_out);
		   p_df_b_bid := p_df_out.p_result;
		   -- base ccy discount factor ask
		   p_df_in.p_rate := p_int_rate_b_ask;
		   XTR_RATE_CONVERSION.discount_factor_conv(p_df_in,p_df_out);
		   p_df_b_ask := p_df_out.p_result;
 		   -- usd ccy discount factor bid
		   p_df_in.p_rate := p_int_rate_c_bid;
		   XTR_RATE_CONVERSION.discount_factor_conv(p_df_in,p_df_out);
		   p_df_c_bid := p_df_out.p_result;
		   -- usd ccy discount factor ask
		   p_df_in.p_rate := p_int_rate_c_ask;
		   XTR_RATE_CONVERSION.discount_factor_conv(p_df_in,p_df_out);
		   p_df_c_ask := p_df_out.p_result;

		   -- spot rate: base ccy vs. usd
		   IF (p_base_ccys(i) = 'USD') THEN
		      p_spot_rate_a_bid := 1;
		      p_spot_rate_a_ask := 1;
		   ELSE
		      p_md_in.p_md_set_code := p_market_data_set_temp(i);
		      p_md_in.p_source := 'C';
		      p_md_in.p_indicator := 'S';
		      p_md_in.p_spot_date := p_ref_date;
		      p_md_in.p_future_date := p_end_dates(i);
		      p_md_in.p_ccy := p_base_ccys(i);
		      p_md_in.p_contra_ccy := 'USD';
		      p_md_in.p_day_count_basis_out := p_fx_day_count_basis;
		      p_md_in.p_interpolation_method := p_interpolation_method;
		      p_md_in.p_side := 'B';
		      XTR_MARKET_DATA_P.get_md_from_set(p_md_in,p_md_out);
		      p_spot_rate_a_bid := p_md_out.p_md_out;
		      p_side := 'A';
		      XTR_MARKET_DATA_P.get_md_from_set(p_md_in,p_md_out);
		      p_spot_rate_a_ask := p_md_out.p_md_out;
		   END IF;

		   IF (g_proc_level>=g_debug_level) THEN
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'base spot rate bid: '||p_spot_rate_a_bid);
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'base spot rate ask: '||p_spot_rate_a_ask);
		   END IF;
		   -- spot rate: contra ccy vs.usd
		   IF (p_contra_ccys(i) = 'USD') THEN
		       p_spot_rate_b_bid := 1;
		       p_spot_rate_b_ask := 1;
		   ELSE
		       p_md_in.p_indicator := 'S';
		       p_md_in.p_ccy := p_contra_ccys(i);
		       p_md_in.p_contra_ccy := 'USD';
		       p_md_in.p_side := 'B';
		       XTR_MARKET_DATA_P.get_md_from_set(p_md_in,p_md_out);
		       p_spot_rate_b_bid := p_md_out.p_md_out;
		       p_md_in.p_side := 'A';
		       XTR_MARKET_DATA_P.get_md_from_set(p_md_in,p_md_out);
		       p_spot_rate_b_ask := p_md_out.p_md_out;
		   END IF;

		   IF (g_proc_level>=g_debug_level) THEN
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'contra spot rate bid: '||p_spot_rate_b_bid);
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'contra spot rate ask: '||p_spot_rate_b_ask);
		   END IF;

		IF (p_insert_or_update <> 'N') THEN
		   -- FAIR VALUE of FX deal
		   -- fair value of FX is always in SOB ccy
                   QRM_FX_FORMULAS.fv_fx(p_pricing_models(i),
			p_market_data_set_temp(i), p_buy_ccys(i),
			p_sell_ccys(i), p_sob_ccy_temp(i),
			p_interpolation_method,
			p_ref_date, p_end_dates(i), p_buy_amounts(i),
			p_sell_amounts(i), p_side, p_fx_reval_rate_temp(i),
			p_fair_value_temp(i));
	           -- convert fair value amounts
                   p_fair_value_sob_temp(i) := p_fair_value_temp(i);
		   -- convert to USD
		   IF (p_sob_ccy_temp(i)='USD') THEN
		      p_fair_value_usd_temp(i) := p_fair_value_sob_temp(i);
		   ELSE
		      convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_sob_ccy_temp(i), 'USD', p_fair_value_temp(i),
			p_fair_value_usd_temp(i));
		   END IF;
		   IF (g_proc_level>=g_debug_level) THEN
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'FX deal no: '||p_deal_nos(i));
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'FX reval rate: '||p_fx_reval_rate_temp(i));
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'FX fair value is: '||p_fair_value_temp(i));
		   END IF;

		   -- ** FX SENSITIVITIES ** --
		   -- delta spot
		   p_deltas_rhos := QRM_FX_FORMULAS.fx_forward_delta_spot(
			p_contra_ccys(i), p_base_ccys(i), p_df_b_bid,
			p_df_b_ask, p_df_a_bid, p_df_a_ask, p_df_c_bid,
			p_df_c_ask);
		   -- p_side determined by fair value calculation
		   IF (p_side = 'B') THEN -- bid side of delta spot
		      p_delta_temp(i) := p_deltas_rhos(1);
		   ELSE
		      p_delta_temp(i) := p_deltas_rhos(2);
		   END IF;
		   -- Rho Base/Contra
		   -- Rho Contra bid/ask
		   IF (g_proc_level>=g_debug_level) THEN
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'base int rate bid: '||p_int_rate_a_bid);
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'base int rate ask: '||p_int_rate_a_ask);
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'contra int rate bid: '||p_int_rate_b_bid);
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'contra int rate ask: '||p_int_rate_b_ask);
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'usd int rate bid: '||p_int_rate_c_bid);
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'usd int rate ask: '||p_int_rate_c_ask);
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'day count: '||p_day_count);
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'annual basis: '||p_annual_basis);
		   END IF;

		   p_deltas_rhos := QRM_FX_FORMULAS.fx_forward_rho('D',
			p_spot_rate_a_bid, p_spot_rate_a_ask,
			p_spot_rate_b_bid, p_spot_rate_b_ask,
			p_int_rate_a_bid, p_int_rate_a_ask,
			p_int_rate_b_bid, p_int_rate_b_ask,
			p_int_rate_c_bid, p_int_rate_c_ask,
			p_day_count, p_day_count, p_day_count,
			p_annual_basis, p_annual_basis, p_annual_basis,
			p_base_ccys(i), p_contra_ccys(i),'B','B');
		   IF (p_side = 'B') THEN -- bid side of rho contra
		      p_rho_base_temp(i) := p_deltas_rhos(1);
		      p_rho_contra_temp(i) := p_deltas_rhos(3);
		   ELSE -- ask side of rho contra
		      p_rho_base_temp(i) := p_deltas_rhos(2);
		      p_rho_contra_temp(i) := p_deltas_rhos(4);
		   END IF;

		   -- Position Delta in contra ccy
                   p_pos_delta_temp(i) := p_delta_temp(i)*
					  ABS(p_base_amounts(i));
		   -- convert Position Delta into USD ccy
		   IF (p_contra_ccys(i)='USD') THEN
			p_pos_delta_usd_temp(i) := p_pos_delta_temp(i);
		   ELSE
		      convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_contra_ccys(i), 'USD', p_pos_delta_temp(i),
			p_pos_delta_usd_temp(i));
		   END IF;
		   -- convert Position Delta into SOB ccy
		   IF (p_contra_ccys(i)=p_sob_ccy_temp(i)) THEN
			p_pos_delta_sob_temp(i) := p_pos_delta_temp(i);
		   ELSE
		      convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_contra_ccys(i), p_sob_ccy_temp(i),
			p_pos_delta_temp(i), p_pos_delta_sob_temp(i));
		   END IF;

		   -- Position Rho Base
		   p_pos_rho_base_temp(i) := p_rho_base_temp(i)*
					     ABS(p_base_amounts(i));
		   -- convert Rho Base into USD ccy
		   IF (p_contra_ccys(i)='USD') THEN
			p_pos_rho_base_usd_temp(i) := p_pos_rho_base_temp(i);
		   ELSE
		      convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_contra_ccys(i), 'USD', p_pos_rho_base_temp(i),
			p_pos_rho_base_usd_temp(i));
		   END IF;
		   -- convert Rho Base into SOB ccy
		   IF (p_contra_ccys(i)=p_sob_ccy_temp(i)) THEN
			p_pos_rho_base_sob_temp(i) := p_pos_rho_base_temp(i);
		   ELSE
		      convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_contra_ccys(i), p_sob_ccy_temp(i),
			p_pos_rho_base_temp(i), p_pos_rho_base_sob_temp(i));
		   END IF;

		   -- Position Rho Contra
		   p_pos_rho_contra_temp(i) := p_rho_contra_temp(i)*
					       ABS(p_base_amounts(i));

		   -- convert Rho Contra into USD ccy
		   IF (p_contra_ccys(i)='USD') THEN
			p_pos_rho_contra_usd_temp(i) := p_pos_rho_contra_temp(i);
		   ELSE
		      convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_contra_ccys(i), 'USD', p_pos_rho_contra_temp(i),
			p_pos_rho_contra_usd_temp(i));
		   END IF;
		   -- convert Rho Contra into SOB ccy
		   IF (p_contra_ccys(i)=p_sob_ccy_temp(i)) THEN
			p_pos_rho_contra_sob_temp(i) := p_pos_rho_contra_temp(i);
		   ELSE
		      convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_contra_ccys(i), p_sob_ccy_temp(i),
			p_pos_rho_contra_temp(i),p_pos_rho_contra_sob_temp(i));
		   END IF;
		   p_upd_md_calc_date_temp(i) := p_ref_datetime;
		ELSE
		   p_insert_or_update := 'U';
		   p_upd_md_calc_date_temp(i) := p_deal_calculations.last_md_calc_date;
		   p_fx_reval_rate_temp(i) := p_deal_calculations.fx_reval_rate;
		   p_fair_value_temp(i) := p_deal_calculations.fair_value;
		   p_fair_value_usd_temp(i) := p_deal_calculations.fair_value_usd;
		   p_fair_value_sob_temp(i) := p_deal_calculations.fair_value_sob;
		   p_delta_temp(i) := p_deal_calculations.delta;
		   p_rho_base_temp(i) := p_deal_calculations.rho_base;
		   p_rho_contra_temp(i) := p_deal_calculations.rho_contra;
		   p_pos_delta_temp(i) := p_deal_calculations.pos_delta;
		   p_pos_delta_usd_temp(i) := p_deal_calculations.pos_delta_usd;
		   p_pos_delta_sob_temp(i) := p_deal_calculations.pos_delta_sob;
		   p_pos_rho_base_temp(i) := p_deal_calculations.pos_rho_base;
		   p_pos_rho_base_usd_temp(i) := p_deal_calculations.pos_rho_base_usd;
		   p_pos_rho_base_sob_temp(i) := p_deal_calculations.pos_rho_base_sob;
		   p_pos_rho_contra_temp(i) := p_deal_calculations.pos_rho_contra;
		   p_pos_rho_contra_usd_temp(i) := p_deal_calculations.pos_rho_contra_usd;
		   p_pos_rho_contra_sob_temp(i) := p_deal_calculations.pos_rho_contra_sob;
		END IF;  -- end threshold check for fv/sens calculations

              END IF;  -- end if fxo

	     ELSIF (p_deal_types(i)='BOND') THEN -- BOND
		IF (g_proc_level>=g_debug_level) THEN
		   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'calculating bond!');
		END IF;
	        p_maturity_amount_temp(i):=get_signed_amount(p_face_values(i),
	 	   p_deal_types(i), p_deal_subtypes(i), null);
                p_gap_amount_temp(i) := p_maturity_amount_temp(i);

		-- convert amounts to USD
		IF (p_deal_ccys(i)='USD') THEN
		   p_maturity_amount_usd_temp(i) := p_maturity_amount_temp(i);
		   p_gap_amount_usd_temp(i) := p_gap_amount_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_maturity_amount_temp(i),
			p_maturity_amount_usd_temp(i));
  		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_gap_amount_temp(i),
			p_gap_amount_usd_temp(i));
		END IF;
		-- convert amounts to sob ccy
		IF (p_deal_ccys(i)=p_sob_ccy_temp(i)) THEN
		   p_maturity_amount_sob_temp(i) := p_maturity_amount_temp(i);
		   p_gap_amount_sob_temp(i) := p_gap_amount_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_maturity_amount_temp(i),
			p_maturity_amount_sob_temp(i));
  		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_gap_amount_temp(i), p_gap_amount_sob_temp(i));
		END IF;


		p_mm_trans_rate_temp(i) := NULL;

		-- trans price: clean price of original buy/sell deal
		p_trans_price_temp(i):= p_transaction_rates(i);

		-- figure out  start date of current coupon period

		/*WDK: don't need this code!
		OPEN get_bond_coupon_start_date(p_bond_issues(i), p_ref_date);
		FETCH get_bond_coupon_start_date INTO
						p_bond_coupon_start;
		CLOSE get_bond_coupon_start_date;
		*/

                --bug2408825
                --p_bond_coupon_start := NVL(p_bond_coupon_start,
		--			   p_start_dates(i));

		-- get bond code and day count basis
		OPEN get_bond_code(p_bond_issues(i));
	        FETCH get_bond_code INTO p_bond_code, p_bond_calc_type,
					 p_day_count_bases(i), p_bond_issue_start;
		IF (get_bond_code%NOTFOUND) THEN
		   -- settings bond code to null will cause
		   -- cause api's to throw no data found exception
		   IF (g_proc_level>=g_debug_level) THEN
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'ric code does not exist');
		   END IF;
		   p_bond_code := null;
		END IF;
	        CLOSE get_bond_code;

                --bug2408825
                /*WDK: don't need this code!
                p_bond_coupon_start := NVL(p_bond_coupon_start,
                                           NVL(p_bond_issue_start,
                                               p_start_dates(i)
                                              )
                                          );
                */

		-- avoids mistakes entered by user in bond issues form
		-- if select ZERO COUPON type, coupon rate must be 0
		IF (p_bond_calc_type = 'ZERO COUPON') THEN
		    p_coupon_rates(i) := 0;
		END IF;

	     IF (g_proc_level>=g_debug_level) THEN
	        xtr_risk_debug_pkg.dlog('run_analysis: ' || 'insert/update val: '||p_insert_or_update);
	     END IF;
	     IF (p_insert_or_update <> 'N') THEN
		p_mm_reval_rate_temp(i):= null;
		-- calculates fair value, data side, reval rate
	        QRM_MM_FORMULAS.fv_bond(p_pricing_models(i),
		   p_market_data_set_temp(i), p_deal_subtypes(i),
		   p_bond_code, p_bond_issues(i), p_deal_ccys(i),
		   p_interpolation_method, p_coupon_actions(i),
		   p_day_count_bases(i), p_ref_date,
		   /* WDK: don't need this!
		   p_bond_coupon_start,
		   */
 		   p_maturity_dates(i), p_coupon_rates(i), p_face_values(i),
		   p_margins(i), p_rounding_type(i),
		   p_day_count_type(i), p_side, p_reval_price_temp(i),
		   p_dirty_price, p_bond_ytm, p_accrued_interest_temp(i),
		   p_fair_value_temp(i),
                   p_actual_ytm); --bug 2804548

		-- get correct sign for accrued interests
		p_accrued_interest_temp(i) := get_signed_amount(
			p_accrued_interest_temp(i), p_deal_types(i),
			p_deal_subtypes(i), null);

		-- convert amounts to USD
		IF (p_deal_ccys(i)='USD') THEN
		   p_fair_value_usd_temp(i) := p_fair_value_temp(i);
		   p_accrued_interest_usd_temp(i) := p_accrued_interest_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_fair_value_temp(i),
			p_fair_value_usd_temp(i));
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_accrued_interest_temp(i),
			p_accrued_interest_usd_temp(i));

		END IF;

		-- convert amounts to sob ccy
		IF (p_deal_ccys(i)=p_sob_ccy_temp(i)) THEN
		   p_fair_value_sob_temp(i) := p_fair_value_temp(i);
		   p_accrued_interest_sob_temp(i) := p_accrued_interest_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_fair_value_temp(i), p_fair_value_sob_temp(i));
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_accrued_interest_temp(i),
			p_accrued_interest_sob_temp(i));
		END IF;

		-- clear tables of previous values before reuse
		p_cashflows.DELETE;
		p_days.DELETE;

		-- get cashflows for sensitivities
		p_counter := 1;
		FOR coupon_rec IN get_bond_cashflows(p_deal_nos(i),
						     p_ref_date) LOOP
		   p_cashflows.EXTEND;

                   --bug 2427997
                   p_cashflows(p_counter) := get_signed_amount(coupon_rec.interest,
	 	      p_deal_types(i), p_deal_subtypes(i), null);
                   /*
		   IF (p_deal_subtypes(i)='BUY') THEN
		      p_cashflows(p_counter) := coupon_rec.interest;
		   ELSIF (p_deal_subtypes(i)='ISSUE') THEN
		      p_cashflows(p_counter) := (-1)*coupon_rec.interest;
		   END IF;
                   */

		   IF (g_proc_level>=g_debug_level) THEN
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'start date: '||coupon_rec.start_date);
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'maturity date: '||coupon_rec.maturity_date);
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'coupon amt: '||p_cashflows(p_counter));
		   END IF;
                   p_days.EXTEND;
		   -- calculate number of days until next cashflow
		   days_run_helper(p_ref_date,
			coupon_rec.maturity_date, p_day_count_bases(i),
			null, p_days(p_counter), p_annual_basis);


		   IF (g_proc_level>=g_debug_level) THEN
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'day count basis: '||p_day_count_bases(i));
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'days to cashflow: '||p_days(p_counter));
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'annual basis: '||p_annual_basis);
		   END IF;
		   XTR_RISK_DEBUG_PKG.dlog('year fraction: '||p_days(p_counter)/p_annual_basis);
		   p_bond_coupon_start := coupon_rec.start_date;
		   p_bond_coupon_end := coupon_rec.maturity_date;

		   -- convert YTM to annual compounded formula
		   IF (g_proc_level>=g_debug_level) THEN
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'ytm: '||p_bond_ytm);
		   END IF;
		   IF (p_coupon_freqs(i) <> 1) THEN
		      p_rc_in.p_start_date := p_bond_coupon_start;
		      p_rc_in.p_end_date := p_bond_coupon_end;
		      p_rc_in.p_day_count_basis_in := p_day_count_bases(i);
		      p_rc_in.p_day_count_basis_out := p_day_count_bases(i);
		      p_rc_in.p_rate_type_in := 'P';
		      p_rc_in.p_rate_type_out := 'P';
		      p_rc_in.p_compound_freq_in := p_coupon_freqs(i);
		      p_rc_in.p_compound_freq_out := 1;
		      p_rc_in.p_rate_in := p_bond_ytm;
		      rate_conversion(p_rc_in, p_rc_out);
		      p_yield_rate := p_rc_out.p_rate_out;
		   ELSE
		      p_yield_rate := p_bond_ytm;
		   END IF;

		   IF (g_proc_level>=g_debug_level) THEN
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'effective yield rate: '||p_yield_rate);
		   END IF;
		   -- convert YTM to a long discount factor
		   p_discount_factors.EXTEND;
		   XTR_RATE_CONVERSION.yield_to_discount_factor_long(
			p_yield_rate, p_days(p_counter), p_annual_basis,
			p_discount_factors(p_counter));

		   IF (g_proc_level>=g_debug_level) THEN
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'discount factor: '||p_discount_factors(p_counter));
		   END IF;

                   --start bug 2804548
                   IF nvl(p_initial_bases(i),'FIXED')='FLOAT' THEN
		      -- convert YTM+1BP to annual compounded formula
		      IF (p_coupon_freqs(i) <> 1) THEN
		         p_rc_in.p_start_date := p_bond_coupon_start;
		         p_rc_in.p_end_date := p_bond_coupon_end;
		         p_rc_in.p_day_count_basis_in := p_day_count_bases(i);
		         p_rc_in.p_day_count_basis_out := p_day_count_bases(i);
		         p_rc_in.p_rate_type_in := 'P';
		         p_rc_in.p_rate_type_out := 'P';
		         p_rc_in.p_compound_freq_in := p_coupon_freqs(i);
		         p_rc_in.p_compound_freq_out := 1;
		         p_rc_in.p_rate_in := p_actual_ytm+p_1bp;
		         rate_conversion(p_rc_in, p_rc_out);
		         p_yield_rate_add1bp := p_rc_out.p_rate_out;
		      ELSE
		         p_yield_rate_add1bp := p_bond_ytm+p_1bp;
		      END IF;
		      -- convert YTM+1BP to a long discount factor
		      p_discount_factors_add1bp.EXTEND;
		      XTR_RATE_CONVERSION.yield_to_discount_factor_long(
			p_yield_rate_add1bp, p_days(p_counter), p_annual_basis,
			p_discount_factors_add1bp(p_counter));

                      --find Next Coupon Reset Date
                      IF p_counter=1 THEN
                         p_next_coupon_reset := coupon_rec.maturity_date;
                      END IF;
                   END IF;
                   --end bug 2804548

		   p_counter := p_counter + 1;
		END LOOP;

		-- yield to maturity
		p_ytm_temp(i) := p_bond_ytm;

		-- Add last cashflow, which is principal repayment
		   -- at deal maturity date
		p_cashflows.EXTEND;
		p_days.EXTEND;
		-- p_counter already incremented in previous loop


                --bug 2427997
                p_signed_face_value := get_signed_amount(p_face_values(i),
	 	   p_deal_types(i), p_deal_subtypes(i), null);
                p_cashflows(p_counter) := p_signed_face_value;
                /*
		IF (p_deal_subtypes(i)='BUY') THEN
		   p_cashflows(p_counter) := p_face_values(i);
		ELSIF (p_deal_subtypes(i)='ISSUE') THEN
		   p_cashflows(p_counter) := (-1)*p_face_values(i);
		END IF;
                */

		IF (g_proc_level>=g_debug_level) THEN
		   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'last cashflow: '||p_cashflows(p_counter));
		END IF;
		days_run_helper(p_ref_date, p_end_dates(i),
			p_day_count_bases(i), null, p_days(p_counter),
			p_annual_basis);
		IF (g_proc_level>=g_debug_level) THEN
		   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'last days: '||p_days(p_counter));
		END IF;

		p_discount_factors.EXTEND;
		XTR_RATE_CONVERSION.yield_to_discount_factor_long(
			p_yield_rate, p_days(p_counter), p_annual_basis,
			p_discount_factors(p_counter));

                --bug 2804548 calc discount factor for Prn Payment
                IF nvl(p_initial_bases(i),'FIXED')='FLOAT' THEN
                   p_discount_factors_add1bp.EXTEND;
	  	   XTR_RATE_CONVERSION.yield_to_discount_factor_long(
			p_yield_rate_add1bp, p_days(p_counter), p_annual_basis,
			p_discount_factors_add1bp(p_counter));
                END IF;

		IF (g_proc_level>=g_debug_level) THEN
		   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'discount factor: '||p_discount_factors(p_counter));
		END IF;


		IF (p_ref_date <> p_end_dates(i)) THEN

                   --bug 2427997
                   --use p_signed_face_value
                   /*
		   IF (p_deal_subtypes(i) = 'ISSUE') THEN
			p_face_values(i) := (-1)*p_face_values(i);
		   END IF;
                   */

                   --start bug 2804548
                   IF nvl(p_initial_bases(i),'FIXED')='FLOAT' THEN
                      --convexity
                      p_convexity_temp(i) := NULL;

                      --duration
                      days_run_helper(p_ref_date,p_next_coupon_reset,
			p_day_count_bases(i),null,p_days_frb_dur,
			p_annual_basis_frb_dur);
                      p_duration_temp(i) := p_days_frb_dur/p_annual_basis_frb_dur;

                      --Modified DUration
                      p_mod_duration_temp(i) := NULL;

                      --BPV
                      p_tot_cf_add1bp := 0;
  	 	      FOR j IN 1..p_cashflows.COUNT LOOP
		         p_pv_in.p_indicator := 'D';
		         p_pv_in.p_future_val := p_cashflows(j);
		         p_pv_in.p_rate := p_discount_factors_add1bp(j);
		         p_pv_in.p_pv_date := p_ref_date;
		         p_pv_in.p_fv_date := p_end_dates(i);
		         p_pv_in.p_day_count_basis := p_day_count_bases(i);
		         IF within_one_year(p_ref_date, p_end_dates(i)) THEN
		            p_pv_in.p_rate_type := 'S';
		         ELSE
			    p_pv_in.p_rate_type := 'P';
			    p_pv_in.p_compound_freq := 1;
		         END IF;
		         XTR_MM_COVERS.present_value(p_pv_in, p_pv_out);
                         p_cashflows(j) := p_pv_out.p_present_val;
                         p_tot_cf_add1bp := p_tot_cf_add1bp + p_cashflows(j);
		         IF (g_proc_level>=g_debug_level) THEN
		            XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'pv cashflow add1bp: '||p_cashflows(j));
		         END IF;
		      END LOOP;

                      p_bpv := (p_tot_cf_add1bp*100/p_face_values(i))-p_dirty_price;

		   ELSE
                   --end bug 2804548

 		      -- convexity
		      IF (g_proc_level>=g_debug_level) THEN
		         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'dirty price: '||p_dirty_price);
		      END IF;
		      p_convexity_temp(i) := QRM_MM_FORMULAS.bond_convexity(
			p_cashflows, p_days, p_coupon_freqs(i),
			p_bond_ytm, p_annual_basis, p_dirty_price);
		      -- convert convexity to per 100
		      p_convexity_temp(i) := p_convexity_temp(i)/
						p_signed_face_value*100;

		      IF (g_proc_level>=g_debug_level) THEN
		         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'total cashflows: '||p_cashflows.COUNT);
		      END IF;
		      -- convert cashflows to present values for duration
		      -- convert cashflows to per 100 for convexity

  	 	      FOR j IN 1..p_cashflows.COUNT LOOP
		         p_pv_in.p_indicator := 'D';
		         p_pv_in.p_future_val := p_cashflows(j);
		         p_pv_in.p_rate := p_discount_factors(j);
		         p_pv_in.p_pv_date := p_ref_date;
		         p_pv_in.p_fv_date := p_end_dates(i);
		         p_pv_in.p_day_count_basis := p_day_count_bases(i);
		         IF within_one_year(p_ref_date, p_end_dates(i)) THEN
		            p_pv_in.p_rate_type := 'S';
		         ELSE
			    p_pv_in.p_rate_type := 'P';
			    p_pv_in.p_compound_freq := 1;
		         END IF;
		         XTR_MM_COVERS.present_value(p_pv_in, p_pv_out);
                         p_cashflows(j) := p_pv_out.p_present_val;
		         IF (g_proc_level>=g_debug_level) THEN
		            XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'pv cashflow: '||p_cashflows(j));
		         END IF;
		      END LOOP;

		      -- duration
		      -- calculate number of days until maturity
		      p_duration_temp(i) := QRM_MM_FORMULAS.duration(p_cashflows,
 			p_days, p_annual_basis);

                      -- modified duration
 		      p_mod_duration_temp(i) := QRM_MM_FORMULAS.mod_duration(
			p_duration_temp(i), p_bond_ytm, p_coupon_freqs(i));

		      -- bpv
		      p_bpv := QRM_MM_FORMULAS.bpv_yr(p_dirty_price,
			p_mod_duration_temp(i));

                   END IF; --Sens for Floating vs Fixed

		   -- position bpv in deal ccy
		   -- + for ISSUE, - for BUY
		   -- p_signed_face_value is already signed
                   -- For Non Floating Rate Bond, multiply p_bpv by (-1)
                   -- since calculating from Modified Duration.
                   IF nvl(p_initial_bases(i),'FIXED')='FLOAT' THEN
                      p_sign_temp:=1;
                   ELSE
                      p_sign_temp:=-1;
                   END IF;
        	   p_pos_bpv_temp(i) := p_sign_temp * p_bpv * p_signed_face_value/100;

		   -- position bpv in usd ccy
		   IF (p_deal_ccys(i)= 'USD') THEN
		      p_pos_bpv_usd_temp(i) := p_pos_bpv_temp(i);
		   ELSE
		      convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_pos_bpv_temp(i),
			p_pos_bpv_usd_temp(i));
		   END IF;
		   -- position bpv in sob ccy
		   IF (p_deal_ccys(i)= p_sob_ccy_temp(i)) THEN
		      p_pos_bpv_sob_temp(i) := p_pos_bpv_temp(i);
		   ELSE
		      convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i), p_pos_bpv_temp(i),
			p_pos_bpv_sob_temp(i));
		   END IF;

		ELSE  -- if matures today, sensitivites are 0
		   p_convexity_temp(i) := 0;
		   p_duration_temp(i) := 0;
		   p_mod_duration_temp(i) := 0;
		   p_pos_bpv_temp(i) := 0;
		   p_pos_bpv_sob_temp(i) := 0;
		   p_pos_bpv_usd_temp(i) := 0;
		END IF;
		p_upd_md_calc_date_temp(i) := p_ref_datetime;
	     ELSE
	     	p_insert_or_update := 'U';
		p_upd_md_calc_date_temp(i) := p_deal_calculations.last_md_calc_date;
 		p_fair_value_temp(i) := p_deal_calculations.fair_value;
		p_fair_value_usd_temp(i) := p_deal_calculations.fair_value_usd;
		p_fair_value_sob_temp(i) := p_deal_calculations.fair_value_sob;
		p_accrued_interest_temp(i) := p_deal_calculations.accrued_interest;
		p_accrued_interest_usd_temp(i) := p_deal_calculations.accrued_interest_usd;
		p_accrued_interest_sob_temp(i) := p_deal_calculations.accrued_interest_sob;
		p_ytm_temp(i) := p_deal_calculations.yield_to_maturity;
		p_mm_reval_rate_temp(i) := p_deal_calculations.mm_reval_rate;
		p_reval_price_temp(i):= p_deal_calculations.revaluation_price;
		p_convexity_temp(i) := p_deal_calculations.convexity;
		p_duration_temp(i) := p_deal_calculations.duration;
		p_mod_duration_temp(i) := p_deal_calculations.modified_duration;
		p_pos_bpv_temp(i) := p_deal_calculations.pos_bpv;
		p_pos_bpv_usd_temp(i) := p_deal_calculations.pos_bpv_usd;
		p_pos_bpv_sob_temp(i) := p_deal_calculations.pos_bpv_sob;
	     END IF; -- end threshold check for fv/sens calculations
          -- convert prices to USD
	  IF (p_deal_ccys(i)='USD') THEN
            	p_reval_price_usd_temp(i) := p_reval_price_temp(i);
		p_trans_price_usd_temp(i) := p_trans_price_temp(i);
	  ELSE
		convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_reval_price_temp(i),
			p_reval_price_usd_temp(i));
		convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_trans_price_temp(i),
			p_trans_price_usd_temp(i));

	  END IF;
	  -- convert prices to sob ccy
	  IF (p_deal_ccys(i)=p_sob_ccy_temp(i)) THEN
	       	p_reval_price_sob_temp(i) := p_reval_price_temp(i);
		p_trans_price_sob_temp(i) := p_trans_price_temp(i);
	  ELSE
		convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_reval_price_temp(i), p_reval_price_sob_temp(i));
		convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_trans_price_temp(i),
			p_trans_price_sob_temp(i));
	  END IF;

	ELSIF (p_deal_types(i)='STOCK') THEN -- STOCK
		IF (g_proc_level>=g_debug_level) THEN
		   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'calculating stock');
		END IF;
		p_maturity_amount_temp(i):=TO_NUMBER(NULL);
                p_gap_amount_temp(i) := TO_NUMBER(NULL);

		-- set to 0
		   p_maturity_amount_usd_temp(i) := TO_NUMBER(NULL);
		   p_gap_amount_usd_temp(i) := TO_NUMBER(NULL);

		-- convert amounts to sob ccy
		   p_maturity_amount_sob_temp(i) := TO_NUMBER(NULL);
		   p_gap_amount_sob_temp(i) := TO_NUMBER(NULL);

		-- trans price: price per share from deal
		p_trans_price_temp(i) := p_transaction_rates(i);


	     IF (g_proc_level>=g_debug_level) THEN
	        xtr_risk_debug_pkg.dlog('run_analysis: ' || 'insert/update val: '||p_insert_or_update);
	     END IF;
	     IF (p_insert_or_update <> 'N') THEN
                QRM_EQ_FORMULAS.fv_stock(p_pricing_models(i), p_deal_ccys(i),
			p_bond_issues(i), p_market_data_set_temp(i),
			p_mm_trans_rate_temp(i), p_quantity_out(i),
			p_ref_date, p_fair_value_temp(i),
			p_reval_price_temp(i));

		-- convert amounts to USD
		IF (p_deal_ccys(i)='USD') THEN
		   p_fair_value_usd_temp(i) := p_fair_value_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_fair_value_temp(i),
			p_fair_value_usd_temp(i));
		END IF;
		-- convert amounts to sob ccy
		IF (p_deal_ccys(i)=p_sob_ccy_temp(i)) THEN
		   p_fair_value_sob_temp(i) := p_fair_value_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_fair_value_temp(i), p_fair_value_sob_temp(i));
		END IF;


		p_upd_md_calc_date_temp(i) := p_ref_datetime;
	     ELSE
	     	p_insert_or_update := 'U';
		p_upd_md_calc_date_temp(i) := p_deal_calculations.last_md_calc_date;
 		p_fair_value_temp(i) := p_deal_calculations.fair_value;
		p_fair_value_usd_temp(i) := p_deal_calculations.fair_value_usd;
		p_fair_value_sob_temp(i) := p_deal_calculations.fair_value_sob;

		p_reval_price_temp(i) := p_deal_calculations.revaluation_price;

	     END IF; -- end threshold check for fv/sens calculations
	          -- convert prices to USD
	     IF (p_deal_ccys(i)='USD') THEN
            	p_reval_price_usd_temp(i) := p_reval_price_temp(i);
		p_trans_price_usd_temp(i) := p_trans_price_temp(i);
	     ELSE
		convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_reval_price_temp(i),
			p_reval_price_usd_temp(i));
		convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_trans_price_temp(i),
			p_trans_price_usd_temp(i));

	     END IF;
	     -- convert prices to sob ccy
	     IF (p_deal_ccys(i)=p_sob_ccy_temp(i)) THEN
	       	p_reval_price_sob_temp(i) := p_reval_price_temp(i);
		p_trans_price_sob_temp(i) := p_trans_price_temp(i);
	     ELSE
		convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_reval_price_temp(i), p_reval_price_sob_temp(i));
		convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_trans_price_temp(i),
			p_trans_price_sob_temp(i));
	     END IF;




           ELSIF (p_deal_types(i)='NI') THEN -- NI
	        p_maturity_amount_temp(i) := get_signed_amount(p_face_values(i),p_deal_types(i), p_deal_subtypes(i), null);
                p_gap_amount_temp(i) := p_maturity_amount_temp(i);

		-- convert amounts to USD
		IF (p_deal_ccys(i)='USD') THEN
		   p_maturity_amount_usd_temp(i) := p_maturity_amount_temp(i);
		   p_gap_amount_usd_temp(i) := p_gap_amount_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_maturity_amount_temp(i),
			p_maturity_amount_usd_temp(i));
  		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_gap_amount_temp(i),
			p_gap_amount_usd_temp(i));
		END IF;
		-- convert amounts to sob ccy
		IF (p_deal_ccys(i)=p_sob_ccy_temp(i)) THEN
		   p_maturity_amount_sob_temp(i) := p_maturity_amount_temp(i);
		   p_gap_amount_sob_temp(i) := p_gap_amount_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_maturity_amount_temp(i),
			p_maturity_amount_sob_temp(i));
  		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_gap_amount_temp(i), p_gap_amount_sob_temp(i));
		END IF;

		-- if transaction rate is a discount rate, convert to yield
		IF (p_discount_yields(i) = 'Y') THEN -- discount basis
		  days_run_helper(p_start_dates(i),
			p_maturity_dates(i), p_day_count_bases(i), null,
			p_days_mature, p_annual_basis);
		  XTR_RATE_CONVERSION.discount_to_yield_rate(
			p_transaction_rates(i), p_days_mature,
			p_annual_basis, p_transaction_rates(i));
		END IF;
		-- transaction rate, converted to Act/365
		IF (p_day_count_bases(i) <> p_mm_day_count_basis) THEN
		  IF (g_proc_level>=g_debug_level) THEN
		     XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'NI deal no: '||p_deal_nos(i));
		     XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'NI start date: '||p_start_dates(i));
		     XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'NI mat date: '||p_maturity_dates(i));
		     XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'DCB in: '||p_day_count_bases(i));
		  END IF;
		  p_rc_in.p_start_date := p_start_dates(i);
		  p_rc_in.p_end_date := p_end_dates(i);
		  p_rc_in.p_day_count_basis_in := p_day_count_bases(i);
		  p_rc_in.p_day_count_basis_out := p_mm_day_count_basis;
		  IF (within_one_year(p_start_dates(i), p_end_dates(i))) THEN
		     p_rc_in.p_rate_type_in := 'S';
		     p_rc_in.p_rate_type_out := 'S';
		  ELSE
		     p_rc_in.p_rate_type_in := 'P';
		     p_rc_in.p_rate_type_out := 'P';
		     p_rc_in.p_compound_freq_in := 1;
		     p_rc_in.p_compound_freq_out := 1;
 		  END IF;
		  IF (g_proc_level>=g_debug_level) THEN
		     XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'trans rate in: '||p_transaction_rates(i));
		  END IF;
		  p_rc_in.p_rate_in := p_transaction_rates(i);
		  rate_conversion(p_rc_in, p_rc_out);
		  p_mm_trans_rate_temp(i) := p_rc_out.p_rate_out;
		ELSE
		  p_mm_trans_rate_temp(i) := p_transaction_rates(i);
		END IF;


	     IF (p_insert_or_update <> 'N') THEN
		-- fair value, data side, reval rate (in ACT/365)
		QRM_MM_FORMULAS.fv_ni(p_pricing_models(i),
		   p_market_data_set_temp(i), p_deal_subtypes(i),
		   p_discount_yields(i), p_deal_ccys(i),
		   p_interpolation_method, p_day_count_bases(i),
		   p_ref_date, p_start_dates(i), p_maturity_dates(i),
		   p_face_values(i), p_margins(i), p_side,
		   p_mm_reval_rate_temp(i), p_fair_value_temp(i));

		-- accrued interest (should be 0)
		p_accrued_interest_temp(i) := 0;
  		p_accrued_interest_usd_temp(i) := 0;
		p_accrued_interest_sob_temp(i) := 0;

		-- convert amounts to USD
		IF (p_deal_ccys(i)='USD') THEN
		   p_fair_value_usd_temp(i) := p_fair_value_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_fair_value_temp(i),
			p_fair_value_usd_temp(i));
		END IF;
		-- convert amounts to sob ccy
		IF (p_deal_ccys(i)=p_sob_ccy_temp(i)) THEN
		   p_fair_value_sob_temp(i) := p_fair_value_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_fair_value_temp(i), p_fair_value_sob_temp(i));
		END IF;

		-- sensitivities
		IF (p_ref_date <> p_end_dates(i)) THEN
		   -- duration
		   p_days.DELETE;
		   p_days.EXTEND;
		   -- calculate days to maturity
		   days_run_helper(p_ref_date, p_maturity_dates(i),
			p_day_count_bases(i), null, p_days(1), p_annual_basis);
		   IF (g_proc_level>=g_debug_level) THEN
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'days to maturity: '||p_days(1));
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'days in year: '||p_annual_basis);
		   END IF;
		   p_duration_temp(i) := QRM_MM_FORMULAS.duration(NULL,
						p_days, p_annual_basis);

		   -- yield rate is reval rate in deal day count basis
		   IF (p_day_count_bases(i) <> p_mm_day_count_basis) THEN
		      p_rc_in.p_start_date := p_ref_date;
		      p_rc_in.p_end_date := p_end_dates(i);
		      p_rc_in.p_day_count_basis_in := p_mm_day_count_basis;
		      p_rc_in.p_day_count_basis_out := p_day_count_bases(i);
		      IF (within_one_year(p_ref_date, p_end_dates(i))) THEN
		         p_rc_in.p_rate_type_in := 'S';
		         p_rc_in.p_rate_type_out := 'S';
		      ELSE
		         p_rc_in.p_rate_type_in := 'P';
		         p_rc_in.p_rate_type_out := 'P';
		         p_rc_in.p_compound_freq_in := 1;
		         p_rc_in.p_compound_freq_out := 1;
 		      END IF;
		      p_rc_in.p_rate_in := p_mm_reval_rate_temp(i);
		      rate_conversion(p_rc_in, p_rc_out);
		      p_yield_rate := p_rc_out.p_rate_out;
		   ELSE
		      p_yield_rate := p_mm_reval_rate_temp(i);
		   END IF;
		   IF (g_proc_level>=g_debug_level) THEN
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'ytm in DCB: '|| p_yield_rate);
		   END IF;

		   -- yield to maturity is reval rate in deal DCB
		   p_ytm_temp(i) := p_yield_rate;

		   -- modified duration
		   p_mod_duration_temp(i) := QRM_MM_FORMULAS.mod_duration(
			p_duration_temp(i), p_yield_rate, 1);

		   -- bpv
		   -- signed because fair value is signed
		   p_bpv := QRM_MM_FORMULAS.bpv_yr(p_fair_value_temp(i)/
			p_face_values(i), p_mod_duration_temp(i));

		   -- convexity
		   p_convexity_temp(i) := QRM_MM_FORMULAS.ni_fra_convexity(
			p_days(1), p_yield_rate, p_annual_basis);

 		   -- position bpv
		   -- + for ISSUE, - for BUY
		   -- p_face_values(i) not signed, but bpv is signed
		   p_pos_bpv_temp(i) := (-1)*p_bpv*p_face_values(i);

		   -- position bpv in usd ccy
		   IF (p_deal_ccys(i)= 'USD') THEN
		      p_pos_bpv_usd_temp(i) := p_pos_bpv_temp(i);
		   ELSE
		      convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_pos_bpv_temp(i),
			p_pos_bpv_usd_temp(i));
		   END IF;
		   -- position bpv in sob ccy
		   IF (p_deal_ccys(i)= p_sob_ccy_temp(i)) THEN
		      p_pos_bpv_sob_temp(i) := p_pos_bpv_temp(i);
		   ELSE
		      convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i), p_pos_bpv_temp(i),
			p_pos_bpv_sob_temp(i));
		   END IF;
		ELSE
		   p_duration_temp(i) := 0;
		   p_mod_duration_temp(i) := 0;
		   p_convexity_temp(i) := 0;
		   p_pos_bpv_temp(i) := 0;
		   p_pos_bpv_usd_temp(i) := 0;
		   p_pos_bpv_sob_temp(i) := 0;
		END IF;
		p_upd_md_calc_date_temp(i) := p_ref_datetime;
	     ELSE
		p_insert_or_update := 'U';
		p_upd_md_calc_date_temp(i) := p_deal_calculations.last_md_calc_date;
		p_fair_value_temp(i) := p_deal_calculations.fair_value;
		p_fair_value_usd_temp(i) := p_deal_calculations.fair_value_usd;
		p_fair_value_sob_temp(i) := p_deal_calculations.fair_value_sob;
		p_accrued_interest_temp(i) := p_deal_calculations.accrued_interest;
		p_accrued_interest_usd_temp(i) := p_deal_calculations.accrued_interest_usd;
		p_accrued_interest_sob_temp(i) := p_deal_calculations.accrued_interest_sob;
		p_ytm_temp(i) := p_deal_calculations.yield_to_maturity;
		p_mm_reval_rate_temp(i) := p_deal_calculations.mm_reval_rate;
		p_duration_temp(i) := p_deal_calculations.duration;
		p_mod_duration_temp(i) := p_deal_calculations.modified_duration;
		p_convexity_temp(i) := p_deal_calculations.convexity;
		p_pos_bpv_temp(i) := p_deal_calculations.pos_bpv;
		p_pos_bpv_usd_temp(i) := p_deal_calculations.pos_bpv_usd;
		p_pos_bpv_sob_temp(i) := p_deal_calculations.pos_bpv_sob;
	     END IF;  -- end threshold check for fv/sens calculations;

		IF (g_proc_level>=g_debug_level) THEN
		   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'NI deal no: '||p_deal_nos(i));
		   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'NI yield rate: '||p_yield_rate);
		   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'NI fair value: '||p_fair_value_temp(i));
		   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'NI duration: '||p_duration_temp(i));
		   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'NI mod duration: '||p_mod_duration_temp(i));
		   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'NI bpv: '||p_bpv);
		   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'NI convexity: '||p_convexity_temp(i));
		   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'NI reval rate: '||p_mm_reval_rate_temp(i));
		   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'NI trans rate: '||p_mm_trans_rate_temp(i));
		END IF;

	     ELSIF (p_deal_types(i) IN ('TMM', 'IRS', 'RTMM')) THEN

		-- clear all tables of previous values before reuse
		p_cashflows.DELETE;
		p_days.DELETE;
		p_trans_trans_nos.DELETE;
		p_trans_start_dates.DELETE;
		p_trans_maturity_dates.DELETE;
		p_trans_settle_dates.DELETE;
		p_trans_due_on_dates.DELETE; -- prepaid interest
		p_trans_interest_refunds.DELETE; -- prepaid interest
		p_trans_prin_actions.DELETE;
		p_trans_yield_rates.DELETE;
		p_trans_disc_rates.DELETE;
		p_trans_interest_settled.DELETE;
		p_trans_prin_adjusts.DELETE;
		p_trans_accum_interests.DELETE;
		p_trans_accum_interests_bf.DELETE;
		p_trans_balance_outs.DELETE;
		p_trans_settle_term_interest.DELETE;

		-- get cashflows and transactions
		p_counter := 0;
		-- just b/c deal level is current, doesn't mean transactions
		-- are still current: could be closed or expired
		-- want to get current and future transactions for deal
		p_ok_trans := FALSE;
		FOR cursor_rec IN get_tmm_irs_rtmm_trans(p_deal_nos(i),
							 p_ref_date)   LOOP
		   p_counter := p_counter+1;
		   p_ok_trans := TRUE;

		   -- calculate maturity amount, gap amount
		   IF ((p_end_dates(i) = cursor_rec.maturity_date) AND
			  (cursor_rec.start_date = cursor_rec.maturity_date) AND NVL(p_maturity_amount_temp(i),0)=0)
		   THEN
		       p_maturity_amount_temp(i) :=
					nvl(cursor_rec.principal_adjust, 0);
		   END IF;

		   -- if gap date = deal maturity date, gap amt = mat amt
		   IF (p_gap_date_temp(i) = p_end_dates(i)) THEN
			  p_gap_amount_temp(i) := p_maturity_amount_temp(i);
		   -- else
		   ELSIF (p_gap_date_temp(i)>=cursor_rec.start_date) THEN
		       IF (NOT (p_deal_types(i)='IRS' AND
				p_initial_bases(i)='FIXED')) THEN
			   IF (cursor_rec.principal_action='INCRSE') THEN
		                p_gap_amount_temp(i) :=
				    nvl(cursor_rec.balance_out_bf,0) +
				    nvl(cursor_rec.principal_adjust, 0);
			   ELSE
				p_gap_amount_temp(i) :=
				    nvl(cursor_rec.balance_out_bf,0) -
				    nvl(cursor_rec.principal_adjust, 0);
			   END IF;
		       END IF;
		   END IF;
	           -- end maturity/gap amount calculation

		   p_cashflows.EXTEND;
		   -- here cursor_rec.cf is sum of principal repayment and
		   -- interest settled
		   IF (p_deal_subtypes(i)='FUND') THEN
		      -- if RTMM, cashflows are principal and amount due
		      IF (p_deal_types(i)='RTMM') THEN
		         p_cashflows(p_counter) :=(-1) *
				(NVL(cursor_rec.principal_adjust, 0)+
				 NVL(cursor_rec.pi_amount_due, 0));
		      END IF;
		   ELSIF (p_deal_subtypes(i)='INVEST') THEN
		      --  if RTMM, cashflows are principal and amount due
		      IF (p_deal_types(i)='RTMM') THEN
		         p_cashflows(p_counter):=
				NVL(cursor_rec.principal_adjust,0) +
				NVL(cursor_rec.pi_amount_due, 0);
		     END IF;
		   END IF;
		   p_days.EXTEND;

		   -- get number of days until cashflow
		   days_run_helper(p_ref_date,
			cursor_rec.maturity_date, p_day_count_bases(i), NULL,
			p_days(p_counter), p_annual_basis);
		   IF (g_proc_level>=g_debug_level) THEN
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'days until cashflow: '||p_days(p_counter));
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'annual basis: '||p_annual_basis);
		   END IF;
		   p_trans_trans_nos.EXTEND;
		   p_trans_trans_nos(p_counter) := cursor_rec.transaction_number;
		   p_trans_start_dates.EXTEND;
		   p_trans_start_dates(p_counter) := cursor_rec.start_date;
                   p_trans_maturity_dates.EXTEND;
                   p_trans_maturity_dates(p_counter) := cursor_rec.maturity_date;
		   /* prepaid interest */
		   p_trans_due_on_dates.EXTEND;
                   p_trans_settle_dates.EXTEND;
                   p_trans_settle_dates(p_counter) := cursor_rec.settle_date;
		   if (nvl(cursor_rec.prepaid_interest,'N')='Y') then
		   	p_trans_due_on_dates(p_counter):=p_trans_start_dates(p_counter);
		   else
		   	p_trans_due_on_dates(p_counter):=p_trans_maturity_dates(p_counter);
		   end if;
		   p_trans_interest_refunds.EXTEND;
		   p_trans_interest_refunds(p_counter):=cursor_rec.interest_refund;
		   /* end prepaid interest */
		   p_trans_prin_actions.EXTEND;
                   p_trans_prin_actions(p_counter) := cursor_rec.principal_action;
		   p_trans_yield_rates.EXTEND;
		   p_trans_yield_rates(p_counter) := cursor_rec.interest_rate;
		   p_trans_disc_rates.EXTEND;
		   -- get interpolation rate for coupon period
		   p_md_in.p_md_set_code := p_market_data_set_temp(i);
		   p_md_in.p_source := 'C';
		   p_md_in.p_indicator := 'Y';
		   p_md_in.p_spot_date := p_ref_date;
		   p_md_in.p_future_date := cursor_rec.maturity_date;
		   p_md_in.p_ccy := p_deal_ccys(i);
		   p_md_in.p_day_count_basis_out := p_day_count_bases(i);
		   p_md_in.p_interpolation_method := p_interpolation_method;
		   p_md_in.p_side := 'M';
		   XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
		   p_trans_disc_rates(p_counter) := p_md_out.p_md_out;
		   p_trans_interest_settled.EXTEND;
		   -- if RTMM, get amount due instead of interest settled
		   IF (p_deal_types(i) = 'RTMM') THEN
		      p_trans_interest_settled(p_counter) := cursor_rec.pi_amount_due;
		   ELSE
                      p_trans_interest_settled(p_counter) := cursor_rec.interest_settled;
		   END IF;
		   p_trans_prin_adjusts.EXTEND;
		   p_trans_prin_adjusts(p_counter) := cursor_rec.principal_adjust;
		   p_trans_accum_interests.EXTEND;
		   p_trans_accum_interests(p_counter) := cursor_rec.accum_interest;
		   p_trans_accum_interests_bf.EXTEND;
		   p_trans_accum_interests_bf(p_counter) := cursor_rec.accum_interest_bf;
		   p_trans_balance_outs.EXTEND;
		   p_trans_balance_outs(p_counter) := cursor_rec.balance_out;
		   p_trans_settle_term_interest.EXTEND;
		   p_trans_settle_term_interest(p_counter) := cursor_rec.settle_term_interest;
		END LOOP;

		-- get correct signs for maturity, gap amounts
		p_maturity_amount_temp(i) := get_signed_amount(
			p_maturity_amount_temp(i), p_deal_types(i),
			p_deal_subtypes(i), null);
		p_gap_amount_temp(i) := get_signed_amount(
			p_gap_amount_temp(i), p_deal_types(i),
			p_deal_subtypes(i), null);

		-- convert maturity, gap amounts to USD
		IF (p_deal_ccys(i)='USD') THEN
		   p_maturity_amount_usd_temp(i) := p_maturity_amount_temp(i);
		   p_gap_amount_usd_temp(i) := p_gap_amount_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_maturity_amount_temp(i),
			p_maturity_amount_usd_temp(i));
  		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_gap_amount_temp(i),
			p_gap_amount_usd_temp(i));
		END IF;
		-- convert maturity, gap amounts to sob ccy
		IF (p_deal_ccys(i)=p_sob_ccy_temp(i)) THEN
		   p_maturity_amount_sob_temp(i) := p_maturity_amount_temp(i);
		   p_gap_amount_sob_temp(i) := p_gap_amount_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_maturity_amount_temp(i),
			p_maturity_amount_sob_temp(i));
  		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_gap_amount_temp(i), p_gap_amount_sob_temp(i));
		END IF;

		-- if deal is good, ie. transactions are not expired, usable
		-- calculate fv/sensitivities
	    IF (p_insert_or_update <> 'N') THEN
		IF (p_ok_trans) THEN

		   -- get last transaction number
		   OPEN get_last_trans_no(p_deal_nos(i));
		   FETCH get_last_trans_no INTO p_last_trans_no;
		   CLOSE get_last_trans_no;

		   -- fair values for TMM/IRS/RTMM
 		   QRM_MM_FORMULAS.fv_tmm_irs_rtmm(p_pricing_models(i),
			p_deal_types(i), p_market_data_set_temp(i), 'N',
			p_deal_subtypes(i), p_interpolation_method,
			p_deal_ccys(i), p_discount_yields(i),
			p_initial_bases(i), p_ref_date, p_settle_dates(i),
			p_margins(i), p_last_trans_no,
			p_day_count_bases(i), p_trans_trans_nos,
			p_trans_start_dates, p_trans_maturity_dates, p_trans_settle_dates,
			p_trans_due_on_dates, p_trans_interest_refunds,  -- prepaid interest
			p_trans_prin_actions, p_trans_yield_rates,
			p_trans_interest_settled, p_trans_prin_adjusts,
			p_trans_accum_interests, p_trans_accum_interests_bf,  -- bug 2807340
			p_trans_balance_outs,
			p_trans_settle_term_interest, p_side, p_cashflows,
			p_days, p_annual_basis,
			/* TMM,IRS,RTMM has no reval rate */
			p_mm_trans_rate_temp(i), p_accrued_interest_temp(i),
			p_fair_value_temp(i));
			IF (g_proc_level>=g_debug_level) THEN
			   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'TMM/IRS/RTMM fair value is: '||p_fair_value_temp(i));
			   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'TMM/IRS/RTMM accrued interest is: '||p_accrued_interest_temp(i));
			END IF;


		   -- convert fair value, accrued interest
		   -- convert fair value amounts to USD
		   IF (p_deal_ccys(i)='USD') THEN
		      p_fair_value_usd_temp(i) := p_fair_value_temp(i);
		      p_accrued_interest_usd_temp(i) := p_accrued_interest_temp(i);
		   ELSE
		      convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_fair_value_temp(i),
			p_fair_value_usd_temp(i));
		      convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_accrued_interest_temp(i),
			p_accrued_interest_usd_temp(i));
		   END IF;
		   -- convert fair value amounts to sob ccy
		   IF (p_deal_ccys(i)=p_sob_ccy_temp(i)) THEN
		      p_fair_value_sob_temp(i) := p_fair_value_temp(i);
		      p_accrued_interest_sob_temp(i) := p_accrued_interest_temp(i);
		   ELSE
		      convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_fair_value_temp(i), p_fair_value_sob_temp(i));
		      convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_accrued_interest_temp(i),
			p_accrued_interest_sob_temp(i));
		   END IF;

		   IF (g_proc_level>=g_debug_level) THEN
		      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'before ref date check');
		   END IF;
		   IF (p_ref_date <> p_end_dates(i)) THEN
		      -- duration
			 IF (g_proc_level>=g_debug_level) THEN
			    XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'inside ref date check');
			 END IF;
		      p_duration_temp(i) := QRM_MM_FORMULAS.duration(
				p_cashflows, p_days, p_annual_basis);
		      IF (g_proc_level>=g_debug_level) THEN
		         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'duration is: '|| p_duration_temp(i));
		      END IF;
		      -- Position BPV in deal ccy
		      -- calculate fair value with yield curve + 1bp
 		      QRM_MM_FORMULAS.fv_tmm_irs_rtmm(p_pricing_models(i),
		 	  p_deal_types(i), p_market_data_set_temp(i), 'Y',
			  p_deal_subtypes(i), p_interpolation_method,
			  p_deal_ccys(i), p_discount_yields(i),
			  p_initial_bases(i), p_ref_date, p_settle_dates(i),
			  p_margins(i), p_last_trans_no,
			  p_day_count_bases(i), p_trans_trans_nos,
			  p_trans_start_dates, p_trans_maturity_dates, p_trans_settle_dates,
			  p_trans_due_on_dates, p_trans_interest_refunds, -- prepaid interest
			  p_trans_prin_actions, p_trans_yield_rates,
			  p_trans_interest_settled, p_trans_prin_adjusts,
			  p_trans_accum_interests, p_trans_accum_interests_bf, -- bug 2807340
			  p_trans_balance_outs,
			  p_trans_settle_term_interest, p_side, p_dummy_cf,
			  p_dummy_days, p_dummy_num1,
			  p_dummy_num1, p_dummy_num2, p_fair_value_bp);

		      IF (g_proc_level>=g_debug_level) THEN
		         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'bp accrued int: '||p_dummy_num2);
		         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'fair value bp: '||p_fair_value_bp);
		         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'fair value: '||p_fair_value_temp(i));
		      END IF;

                      -- position bpv in deal ccy
		      p_pos_bpv_temp(i) := p_fair_value_bp -
					   p_fair_value_temp(i);

	              -- position bpv in usd ccy
	              IF (p_deal_ccys(i)= 'USD') THEN
		   	    p_pos_bpv_usd_temp(i) := p_pos_bpv_temp(i);
		      ELSE
		   	    convert_amounts(p_market_data_set_temp(i),
				p_ref_date, p_deal_ccys(i), 'USD',
				p_pos_bpv_temp(i), p_pos_bpv_usd_temp(i));
		      END IF;
		      -- position bpv in sob ccy
		      IF (p_deal_ccys(i)= p_sob_ccy_temp(i)) THEN
		   	    p_pos_bpv_sob_temp(i) := p_pos_bpv_temp(i);
		      ELSE
		   	    convert_amounts(p_market_data_set_temp(i),
				p_ref_date, p_deal_ccys(i), p_sob_ccy_temp(i),
				p_pos_bpv_temp(i), p_pos_bpv_sob_temp(i));
		      END IF;
		   ELSE
		      p_duration_temp(i) := 0;
		      p_pos_bpv_temp(i) := 0;
		      p_pos_bpv_usd_temp(i) := 0;
		      p_pos_bpv_sob_temp(i) := 0;
		   END IF;
	       END IF;  -- end ok trans
	       p_upd_md_calc_date_temp(i) := p_ref_datetime;
	    ELSE
	       p_insert_or_update := 'U';
	       p_upd_md_calc_date_temp(i) := p_deal_calculations.last_md_calc_date;
	       p_fair_value_temp(i) := p_deal_calculations.fair_value;
	       p_fair_value_usd_temp(i) := p_deal_calculations.fair_value_usd;
	       p_fair_value_sob_temp(i) := p_deal_calculations.fair_value_sob;
	       p_accrued_interest_temp(i) := p_deal_calculations.accrued_interest;
	       p_accrued_interest_usd_temp(i) := p_deal_calculations.accrued_interest_usd;
	       p_accrued_interest_sob_temp(i) := p_deal_calculations.accrued_interest_sob;
	       p_mm_trans_rate_temp(i)   := p_deal_calculations.mm_trans_rate;
	       p_duration_temp(i) := p_deal_calculations.duration;
	       p_pos_bpv_temp(i) := p_deal_calculations.pos_bpv;
	       p_pos_bpv_usd_temp(i) := p_deal_calculations.pos_bpv_usd;
	       p_pos_bpv_sob_temp(i) := p_deal_calculations.pos_bpv_sob;
	    END IF; -- end threshold check for fv/sens calculations

	 ELSIF (p_deal_types(i)='FRA') THEN
		p_maturity_amount_temp(i) := p_face_values(i);
		p_gap_amount_temp(i) := get_signed_amount(p_face_values(i),
			p_deal_types(i), p_deal_subtypes(i), null);

		-- convert amounts to USD
		IF (p_deal_ccys(i)='USD') THEN
		   p_maturity_amount_usd_temp(i) := p_maturity_amount_temp(i);
		   p_gap_amount_usd_temp(i) := p_gap_amount_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_maturity_amount_temp(i),
			p_maturity_amount_usd_temp(i));
  		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_gap_amount_temp(i),
			p_gap_amount_usd_temp(i));
		END IF;
		-- convert amounts to sob ccy
		IF (p_deal_ccys(i)=p_sob_ccy_temp(i)) THEN
		   p_maturity_amount_sob_temp(i) := p_maturity_amount_temp(i);
		   p_gap_amount_sob_temp(i) := p_gap_amount_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_maturity_amount_temp(i),
			p_maturity_amount_sob_temp(i));
  		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_gap_amount_temp(i), p_gap_amount_sob_temp(i));
		END IF;

	       -- transaction rate: int rate converted to Act/365
	       IF (p_day_count_bases(i) <> p_mm_day_count_basis) THEN
	         p_rc_in.p_start_date := p_start_dates(i);
	         p_rc_in.p_end_date := p_maturity_dates(i);
	         p_rc_in.p_day_count_basis_in := p_day_count_bases(i);
	         p_rc_in.p_day_count_basis_out := p_mm_day_count_basis;
	         IF (within_one_year(p_start_dates(i),
				   p_maturity_dates(i))) THEN
	            p_rc_in.p_rate_type_in := 'S';
		    p_rc_in.p_rate_type_out := 'S';
	         ELSE
		    p_rc_in.p_rate_type_in := 'P';
		    p_rc_in.p_rate_type_out := 'P';
		    p_rc_in.p_compound_freq_in := 1;
		    p_rc_in.p_compound_freq_out := 1;
	         END IF;
 	         p_rc_in.p_rate_in := p_transaction_rates(i);
	         rate_conversion(p_rc_in, p_rc_out);
	         p_mm_trans_rate_temp(i) := p_rc_out.p_rate_out;
	       ELSE
		 p_mm_trans_rate_temp(i) := p_transaction_rates(i);
	       END IF;

	   IF (p_insert_or_update <> 'N') THEN
		-- fair value (reval rate=fra price=contract rate, in Act/365)
		QRM_MM_FORMULAS.fv_fra(p_pricing_models(i),
			p_market_data_set_temp(i), 'N', p_deal_subtypes(i),
			p_deal_ccys(i), p_interpolation_method, p_ref_date,
			p_start_dates(i), p_maturity_dates(i),
			p_face_values(i), p_transaction_rates(i),
			p_day_count_bases(i), p_side,
			p_mm_reval_rate_temp(i), p_fair_value_temp(i));

		-- accrued interest
		p_accrued_interest_temp(i) := 0;
		p_accrued_interest_usd_temp(i) := 0;
		p_accrued_interest_sob_temp(i) := 0;

		-- convert amounts to USD
		IF (p_deal_ccys(i)='USD') THEN
		   p_fair_value_usd_temp(i) := p_fair_value_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_fair_value_temp(i),
			p_fair_value_usd_temp(i));
		END IF;
		-- convert amounts to sob ccy
		IF (p_deal_ccys(i)=p_sob_ccy_temp(i)) THEN
		   p_fair_value_sob_temp(i) := p_fair_value_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_fair_value_temp(i), p_fair_value_sob_temp(i));
		END IF;

		-- clear table of previous value before reuse
		p_days.DELETE;

		IF (p_ref_date <> p_end_dates(i)) THEN
		  -- duration
		  p_days.EXTEND;
		  -- days to settle (start date)
		  days_run_helper(p_ref_date, p_start_dates(i),
			p_day_count_bases(i), null, p_days(1), p_annual_basis);
		  IF (g_proc_level>=g_debug_level) THEN
		     XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'FRA days to start: '||p_days(1));
		     XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'FRA annual basis: '||p_annual_basis);
		  END IF;
		  p_duration_temp(i) := QRM_MM_FORMULAS.duration(null,
			p_days, p_annual_basis);

		  -- convexity
		  -- use fra price (reval rate) in deal day count basis
		  IF (p_day_count_bases(i) <> p_mm_day_count_basis) THEN
		    p_rc_in.p_start_date := p_start_dates(i);
		    p_rc_in.p_end_date := p_maturity_dates(i);
		    p_rc_in.p_day_count_basis_in := p_mm_day_count_basis;
		    p_rc_in.p_day_count_basis_out := p_day_count_bases(i);
		    IF (within_one_year(p_start_dates(i), p_maturity_dates(i))) 					THEN
		      p_rc_in.p_rate_type_in := 'S';
		      p_rc_in.p_rate_type_out := 'S';
		    ELSE
		      p_rc_in.p_rate_type_in := 'P';
		      p_rc_in.p_rate_type_out := 'P';
		      p_rc_in.p_compound_freq_in := 1;
		      p_rc_in.p_compound_freq_out := 1;
 		    END IF;
		    p_rc_in.p_rate_in := p_mm_reval_rate_temp(i);
		    rate_conversion(p_rc_in, p_rc_out);
		    p_fra_price := p_rc_out.p_rate_out;
		  ELSE
		    p_fra_price := p_mm_reval_rate_temp(i);
		  END IF;

		  IF (g_proc_level>=g_debug_level) THEN
		     XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'FRA price in deal DCB',p_fra_price);
		  END IF;
		  p_convexity_temp(i) := QRM_MM_FORMULAS.ni_fra_convexity(
			p_days(1), p_fra_price, p_annual_basis);

		  -- position bpv
		  -- calculate fair value with fwd-fwd rate + 1bp
		  QRM_MM_FORMULAS.fv_fra(p_pricing_models(i),
			p_market_data_set_temp(i), 'Y', p_deal_subtypes(i),
			p_deal_ccys(i), p_interpolation_method, p_ref_date,
			p_start_dates(i), p_maturity_dates(i),
			p_face_values(i), p_transaction_rates(i),
			p_day_count_bases(i), p_side, p_fra_price,
			p_fair_value_bp);
	         IF (g_proc_level>=g_debug_level) THEN
	            XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'FRA fv bpv: '||p_fair_value_bp);
	         END IF;
	         p_pos_bpv_temp(i) := p_fair_value_bp - p_fair_value_temp(i);

	         -- position bpv in usd ccy
	         IF (p_deal_ccys(i)= 'USD') THEN
		    p_pos_bpv_usd_temp(i) := p_pos_bpv_temp(i);
	         ELSE
		    convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_pos_bpv_temp(i),
			p_pos_bpv_usd_temp(i));
	         END IF;
	         -- position bpv in sob ccy
	         IF (p_deal_ccys(i)= p_sob_ccy_temp(i)) THEN
		    p_pos_bpv_sob_temp(i) := p_pos_bpv_temp(i);
	         ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i), p_pos_bpv_temp(i),
			p_pos_bpv_sob_temp(i));
	         END IF;
	       ELSE
		 p_duration_temp(i) := 0;
		 p_convexity_temp(i) := 0;
		 p_pos_bpv_temp(i) := 0;
		 p_pos_bpv_usd_temp(i) := 0;
		 p_pos_bpv_sob_temp(i) := 0;
	       END IF;
	       p_upd_md_calc_date_temp(i) := p_ref_datetime;
	   ELSE
	       p_insert_or_update := 'U';
	       p_upd_md_calc_date_temp(i) := p_deal_calculations.last_md_calc_date;
	       p_fair_value_temp(i) := p_deal_calculations.fair_value;
	       p_fair_value_usd_temp(i) := p_deal_calculations.fair_value_usd;
	       p_fair_value_sob_temp(i) := p_deal_calculations.fair_value_sob;
	       p_mm_reval_rate_temp(i) := p_deal_calculations.mm_reval_rate;
	       p_accrued_interest_temp(i) := p_deal_calculations.accrued_interest;
	       p_accrued_interest_usd_temp(i) := p_deal_calculations.accrued_interest_usd;
	       p_accrued_interest_sob_temp(i) := p_deal_calculations.accrued_interest_sob;
	       p_duration_temp(i) := p_deal_calculations.duration;
	       p_convexity_temp(i) := p_deal_calculations.convexity;
	       p_pos_bpv_temp(i) := p_deal_calculations.pos_bpv;
	       p_pos_bpv_usd_temp(i) := p_deal_calculations.pos_bpv_usd;
	       p_pos_bpv_sob_temp(i) := p_deal_calculations.pos_bpv_sob;
	   END IF;  -- end threshold check for fv/sens calculations

	   IF (g_proc_level>=g_debug_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'FRA deal no is: '||p_deal_nos(i));
	      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'FRA fair value is: '||p_fair_value_temp(i));
 	      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'FRA reval rate ACT365 is: '||p_mm_reval_rate_temp(i));
	      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'FRA trans rate ACT365 is: '||p_mm_trans_rate_temp(i));
	   END IF;

	ELSIF (p_deal_types(i)='IRO') THEN
	       p_maturity_amount_temp(i) := p_face_values(i);
	       p_gap_amount_temp(i) := get_signed_amount(p_face_values(i),
			p_deal_types(i), p_deal_subtypes(i), null);

	       -- convert amounts to USD
	       IF (p_deal_ccys(i)='USD') THEN
		   p_maturity_amount_usd_temp(i) := p_maturity_amount_temp(i);
		   p_gap_amount_usd_temp(i) := p_gap_amount_temp(i);
	       ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_maturity_amount_temp(i),
			p_maturity_amount_usd_temp(i));
  		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_gap_amount_temp(i),
			p_gap_amount_usd_temp(i));
	       END IF;
	       -- convert amounts to sob ccy
	       IF (p_deal_ccys(i)=p_sob_ccy_temp(i)) THEN
		   p_maturity_amount_sob_temp(i) := p_maturity_amount_temp(i);
		   p_gap_amount_sob_temp(i) := p_gap_amount_temp(i);
	       ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_maturity_amount_temp(i),
			p_maturity_amount_sob_temp(i));
  		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_gap_amount_temp(i), p_gap_amount_sob_temp(i));
	       END IF;

	       -- transaction rate, converted to ACTUAL365
	       IF (p_day_count_bases(i) <> p_mm_day_count_basis) THEN
		  p_rc_in.p_start_date := p_start_dates(i);
		  p_rc_in.p_end_date := p_maturity_dates(i);
		  p_rc_in.p_day_count_basis_in := p_day_count_bases(i);
		  p_rc_in.p_day_count_basis_out := p_mm_day_count_basis;
		  IF (within_one_year(p_start_dates(i), p_maturity_dates(i)))
								THEN
		     p_rc_in.p_rate_type_in := 'S';
		     p_rc_in.p_rate_type_out := 'S';
		  ELSE
		     p_rc_in.p_rate_type_in := 'P';
		     p_rc_in.p_rate_type_out := 'P';
		     p_rc_in.p_compound_freq_in := 1;
		     p_rc_in.p_compound_freq_out := 1;
		  END IF;
		  p_rc_in.p_rate_in := p_transaction_rates(i);
		  IF (g_proc_level>=g_debug_level) THEN
		     XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'IRO trans rate in: '||p_transaction_rates(i));
		  END IF;
		  rate_conversion(p_rc_in, p_rc_out);
		  p_mm_trans_rate_temp(i) := p_rc_out.p_rate_out;
	       ELSE
		  p_mm_trans_rate_temp(i) := p_transaction_rates(i);
	       END IF;

	       -- convert premium amount to USD
               IF (p_premium_ccys(i)='USD') THEN
                  p_premium_amount_usd_temp(i) := p_premium_amounts(i);
               ELSE
		  convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_premium_ccys(i), 'USD', p_premium_amounts(i),
			p_premium_amount_usd_temp(i));
	       END IF;
	       -- convert premium amount into SOB ccy
	       IF (p_premium_ccys(i)=p_sob_ccy_temp(i)) THEN
		  p_premium_amount_sob_temp(i) := p_premium_amounts(i);
               ELSIF ('USD'=p_sob_ccy_temp(i)) THEN
		  p_premium_amount_sob_temp(i) := p_premium_amount_usd_temp(i);
	       ELSE
		  convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_premium_ccys(i), p_sob_ccy_temp(i),
			p_premium_amounts(i), p_premium_amount_sob_temp(i));
	       END IF;

	   IF (p_insert_or_update <> 'N') THEN
	       -- fair value, reval rate (= fwd fwd rate in Act/365)
	       IF (g_proc_level>=g_debug_level) THEN
	          XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'IRO deal ccy is: '||p_deal_ccys(i));
	       END IF;
	       QRM_MM_FORMULAS.fv_iro(p_pricing_models(i),
		p_market_data_set_temp(i), p_deal_subtypes(i),
		p_deal_ccys(i), p_interpolation_method, p_ref_date,
		p_start_dates(i), p_maturity_dates(i),
		p_transaction_rates(i), p_day_count_bases(i),
		p_face_values(i), p_side, p_mm_reval_rate_temp(i),
		p_fair_value_temp(i));

	        -- accrued interest
	        p_accrued_interest_temp(i) := 0;
	        p_accrued_interest_usd_temp(i) := 0;
		p_accrued_interest_sob_temp(i) := 0;

		-- convert amounts to USD
		IF (p_deal_ccys(i)='USD') THEN
		   p_fair_value_usd_temp(i) := p_fair_value_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_fair_value_temp(i),
			p_fair_value_usd_temp(i));
		END IF;
		-- convert amounts to sob ccy
		IF (p_deal_ccys(i)=p_sob_ccy_temp(i)) THEN
		   p_fair_value_sob_temp(i) := p_fair_value_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_fair_value_temp(i), p_fair_value_sob_temp(i));
		END IF;

	       -- SENSITIVITIES CALCULATIONS
               p_bo_in.p_principal := p_face_values(i);
	       p_bo_in.p_strike_rate := p_transaction_rates(i);
	       IF (within_one_year(p_start_dates(i),
				   p_maturity_dates(i))) THEN
	          p_bo_in.p_rate_type_strike := 'S';
	       ELSE
		  p_bo_in.p_rate_type_strike := 'P';
		  p_bo_in.p_compound_freq_strike := 1;
	       END IF;
	       p_bo_in.p_day_count_basis_strike := p_day_count_bases(i);
	       -- get spot rate from ref date to phy start date
	       p_md_in.p_md_set_code := p_market_data_set_temp(i);
	       p_md_in.p_source := 'C';
	       p_md_in.p_indicator := 'Y';
	       p_md_in.p_spot_date := p_ref_date;
	       p_md_in.p_future_date := p_start_dates(i);
	       p_md_in.p_ccy := p_deal_ccys(i);
	       p_md_in.p_day_count_basis_out := p_day_count_bases(i);
	       p_md_in.p_interpolation_method := p_interpolation_method;
	       p_md_in.p_side := p_side;
	       XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
	       p_bo_in.p_ir_short := p_md_out.p_md_out;
	       IF (within_one_year(p_ref_date, p_start_dates(i))) THEN
	          p_bo_in.p_rate_type_short := 'S';
	       ELSE
		  p_bo_in.p_rate_type_short := 'P';
                  p_bo_in.p_compound_freq_short := 1;
               END IF;
	       p_bo_in.p_day_count_basis_short := p_day_count_bases(i);
	       -- get interest rate until maturity date
	       p_md_in.p_future_date := p_maturity_dates(i);
	       XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
	       p_bo_in.p_ir_long := p_md_out.p_md_out;
	       IF (within_one_year(p_ref_date, p_maturity_dates(i))) THEN
	          p_bo_in.p_rate_type_long := 'S';
	       ELSE
		  p_bo_in.p_rate_type_long := 'P';
		  p_bo_in.p_compound_freq_long := 1;
	       END IF;
	       p_bo_in.p_day_count_basis_long := p_day_count_bases(i);
	       p_bo_in.p_spot_date := p_ref_date;
	       p_bo_in.p_start_date := p_start_dates(i);
	       p_bo_in.p_maturity_date := p_maturity_dates(i);
	       -- get volatility
	       p_md_in.p_indicator := 'V';
	       XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
	       p_volatility_temp(i) := p_md_out.p_md_out;
	       IF (g_proc_level>=g_debug_level) THEN
	          XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'IRO volatility is: '||p_volatility_temp(i));
	       END IF;

	       p_bo_in.p_volatility := p_md_out.p_md_out;
	       QRM_MM_FORMULAS.black_option_sens(p_bo_in, p_bo_out);
	       IF (p_deal_subtypes(i) IN ('BCAP', 'SCAP')) THEN
	          p_delta_temp(i) := p_bo_out.p_delta_cap;
		  p_theta_temp(i) := p_bo_out.p_theta_cap;
		  p_rho_temp(i) := p_bo_out.p_rho_cap;
               ELSE
		  p_delta_temp(i) := p_bo_out.p_delta_floor;
		  p_theta_temp(i) := p_bo_out.p_theta_floor;
		  p_rho_temp(i) := p_bo_out.p_rho_floor;
	       END IF;
	       p_gamma_temp(i) := p_bo_out.p_gamma;
	       p_vega_temp(i) := p_bo_out.p_vega;

		-- position delta in deal ccy
	        p_pos_delta_temp(i) := p_delta_temp(i) * p_face_values(i);
		-- position delta in usd ccy
                IF (p_deal_ccys(i)='USD') THEN
                      p_pos_delta_usd_temp(i) := p_pos_delta_temp(i);
                ELSE
		   convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_deal_ccys(i), 'USD', p_pos_delta_temp(i),
			p_pos_delta_usd_temp(i));
		END IF;
		-- position delta in sob ccy
                IF (p_deal_ccys(i) = p_sob_ccy_temp(i)) THEN
                      p_pos_delta_sob_temp(i) := p_pos_delta_temp(i);
                ELSE
		   convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_pos_delta_temp(i), p_pos_delta_sob_temp(i));
		END IF;

		-- position rho in deal ccy
	        p_pos_rho_temp(i) := p_rho_temp(i) * p_face_values(i);
		-- position rho in usd ccy
                IF (p_deal_ccys(i)='USD') THEN
                      p_pos_rho_usd_temp(i) := p_pos_rho_temp(i);
                ELSE
		   convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_deal_ccys(i), 'USD', p_pos_rho_temp(i),
			p_pos_rho_usd_temp(i));
		END IF;
		-- position rho in sob ccy
                IF (p_deal_ccys(i) = p_sob_ccy_temp(i)) THEN
                      p_pos_rho_sob_temp(i) := p_pos_rho_temp(i);
                ELSE
		   convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_pos_rho_temp(i), p_pos_rho_sob_temp(i));
		END IF;

	       -- position gamma in deal ccy
	       p_pos_gamma_temp(i) := p_gamma_temp(i) * p_face_values(i);
	       -- position gamma in usd ccy
               IF (p_deal_ccys(i)='USD') THEN
                      p_pos_gamma_usd_temp(i) := p_pos_gamma_temp(i);
               ELSE
		  convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_deal_ccys(i), 'USD', p_pos_gamma_temp(i),
			p_pos_gamma_usd_temp(i));
	       END IF;
	       -- position gamma in sob ccy
               IF (p_deal_ccys(i) = p_sob_ccy_temp(i)) THEN
                      p_pos_gamma_sob_temp(i) := p_pos_gamma_temp(i);
               ELSE
		  convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_pos_gamma_temp(i), p_pos_gamma_sob_temp(i));
	       END IF;

	       -- position theta in deal ccy
	       p_pos_theta_temp(i) := p_theta_temp(i) * p_face_values(i);
	       -- position theta in usd ccy
               IF (p_deal_ccys(i)='USD') THEN
                      p_pos_theta_usd_temp(i) := p_pos_theta_temp(i);
               ELSE
		  convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_deal_ccys(i), 'USD', p_pos_theta_temp(i),
			p_pos_theta_usd_temp(i));
	       END IF;
	       -- position theta in sob ccy
               IF (p_deal_ccys(i) = p_sob_ccy_temp(i)) THEN
                      p_pos_theta_sob_temp(i) := p_pos_theta_temp(i);
               ELSE
		  convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_pos_theta_temp(i), p_pos_theta_sob_temp(i));
	       END IF;

	       -- position vega in deal ccy
	       p_pos_vega_temp(i) := p_vega_temp(i) * p_face_values(i);
	       -- position vega in usd ccy
               IF (p_deal_ccys(i)='USD') THEN
                      p_pos_vega_usd_temp(i) := p_pos_vega_temp(i);
               ELSE
		  convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_deal_ccys(i), 'USD', p_pos_vega_temp(i),
			p_pos_vega_usd_temp(i));
	       END IF;
	       -- position vega in sob ccy
               IF (p_deal_ccys(i) = p_sob_ccy_temp(i)) THEN
                      p_pos_vega_sob_temp(i) := p_pos_vega_temp(i);
               ELSE
		  convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_pos_vega_temp(i), p_pos_vega_sob_temp(i));
	       END IF;
	       p_upd_md_calc_date_temp(i) := p_ref_datetime;
	  ELSE
	       p_insert_or_update := 'U';
	       p_upd_md_calc_date_temp(i) := p_deal_calculations.last_md_calc_date;
	       p_mm_reval_rate_temp(i) := p_deal_calculations.mm_reval_rate;
	       p_fair_value_temp(i) := p_deal_calculations.fair_value;
	       p_fair_value_usd_temp(i) := p_deal_calculations.fair_value_usd;
	       p_fair_value_sob_temp(i) := p_deal_calculations.fair_value_sob;
	       p_accrued_interest_temp(i) := p_deal_calculations.accrued_interest;
	       p_accrued_interest_usd_temp(i) := p_deal_calculations.accrued_interest_usd;
	       p_accrued_interest_sob_temp(i) := p_deal_calculations.accrued_interest_sob;
	       p_volatility_temp(i) := p_deal_calculations.volatility;
	       p_delta_temp(i) := p_deal_calculations.delta;
	       p_theta_temp(i) := p_deal_calculations.theta;
	       p_rho_temp(i) := p_deal_calculations.rho;
	       p_gamma_temp(i) := p_deal_calculations.gamma;
	       p_vega_temp(i) := p_deal_calculations.vega;
	       p_pos_delta_temp(i) := p_deal_calculations.pos_delta;
	       p_pos_delta_usd_temp(i) := p_deal_calculations.pos_delta_usd;
	       p_pos_delta_sob_temp(i) := p_deal_calculations.pos_delta_sob;
	       p_pos_theta_temp(i) := p_deal_calculations.pos_theta;
	       p_pos_theta_usd_temp(i) := p_deal_calculations.pos_theta_usd;
	       p_pos_theta_sob_temp(i) := p_deal_calculations.pos_theta_sob;
	       p_pos_rho_temp(i) := p_deal_calculations.pos_rho;
	       p_pos_rho_usd_temp(i) := p_deal_calculations.pos_rho_usd;
	       p_pos_rho_sob_temp(i) := p_deal_calculations.pos_rho_sob;
	       p_pos_gamma_temp(i) := p_deal_calculations.pos_gamma;
	       p_pos_gamma_usd_temp(i) := p_deal_calculations.pos_gamma_usd;
	       p_pos_gamma_sob_temp(i) := p_deal_calculations.pos_gamma_sob;
	       p_pos_vega_temp(i) := p_deal_calculations.pos_vega;
	       p_pos_vega_usd_temp(i) := p_deal_calculations.pos_vega_usd;
	       p_pos_vega_sob_temp(i) := p_deal_calculations.pos_vega_sob;
	  END IF;  -- check threshold check for fv/sens calculations

	  IF (g_proc_level>=g_debug_level) THEN
	     XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'IRO deal no: '||p_deal_nos(i));
             XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'IRO mm reval rate: '||p_mm_reval_rate_temp(i));
	     XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'IRO fair value is: '||p_fair_value_temp(i));
	     XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'IRO delta is: '||p_delta_temp(i));
             XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'IRO theta is: '||p_theta_temp(i));
             XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'IRO rho is: '||p_rho_for_temp(i));
	     XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'IRO gamma is: '||p_gamma_temp(i));
	     XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'IRO vega is: '||p_vega_temp(i));
	  END IF;

       ELSIF (p_deal_types(i)='BDO') THEN
	       p_maturity_amount_temp(i) := p_face_values(i);
	       -- gap amount
	       p_gap_amount_temp(i) := p_face_values(i)*p_transaction_rates(i)/100;
	       p_gap_amount_temp(i) := get_signed_amount(p_gap_amount_temp(i),
 			p_deal_types(i), p_deal_subtypes(i), null);

		-- convert amounts to USD
		IF (p_deal_ccys(i)='USD') THEN
		   p_maturity_amount_usd_temp(i) := p_maturity_amount_temp(i);
		   p_gap_amount_usd_temp(i) := p_gap_amount_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_maturity_amount_temp(i),
			p_maturity_amount_usd_temp(i));
  		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_gap_amount_temp(i),
			p_gap_amount_usd_temp(i));
		END IF;
		-- convert amounts to sob ccy
		IF (p_deal_ccys(i)=p_sob_ccy_temp(i)) THEN
		   p_maturity_amount_sob_temp(i) := p_maturity_amount_temp(i);
		   p_gap_amount_sob_temp(i) := p_gap_amount_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_maturity_amount_temp(i),
			p_maturity_amount_sob_temp(i));
  		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_gap_amount_temp(i), p_gap_amount_sob_temp(i));
		END IF;

	       p_accrued_interest_temp(i) := 0;
	       p_accrued_interest_usd_temp(i) := 0;
	       p_accrued_interest_sob_temp(i) := 0;

	       -- convert premium amount to USD
               IF (p_premium_ccys(i)='USD') THEN
                   p_premium_amount_usd_temp(i) := p_premium_amounts(i);
               ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_premium_ccys(i), 'USD', p_premium_amounts(i),
			p_premium_amount_usd_temp(i));
	       END IF;
	       -- convert premium amount into SOB ccy
	       IF (p_premium_ccys(i)=p_sob_ccy_temp(i)) THEN
		   p_premium_amount_sob_temp(i) := p_premium_amounts(i);
               ELSIF ('USD'=p_sob_ccy_temp(i)) THEN
		   p_premium_amount_sob_temp(i) := p_premium_amount_usd_temp(i);
	       ELSE
		   convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_premium_ccys(i), p_sob_ccy_temp(i),
			p_premium_amounts(i), p_premium_amount_sob_temp(i));
	       END IF;


	       OPEN get_bond_code(p_bond_issues(i));
	       FETCH get_bond_code INTO p_bond_code, p_bond_calc_type,
					p_day_count_bases(i), p_bond_issue_start;
	       IF (get_bond_code%NOTFOUND) THEN
	          -- settings bond code to null will cause
		  -- cause api's to throw no data found exception
		  IF (g_proc_level>=g_debug_level) THEN
		     XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'ric code does not exist');
		  END IF;
		  p_bond_code := null;
	       END IF;
	       CLOSE get_bond_code;

	       -- reval rate: bond clean price on ref date(no margin for BDO)
	       p_md_in.p_md_set_code :=p_market_data_set_temp(i);
	       p_md_in.p_source := 'C';
               p_md_in.p_indicator := 'B';
               p_md_in.p_spot_date := p_ref_date;
               p_md_in.p_future_date := NULL;
    	       p_md_in.p_ccy := p_deal_ccys(i);
	       p_md_in.p_day_count_basis_out := p_mm_day_count_basis;
	       p_md_in.p_interpolation_method := 'DEFAULT';
	       IF (p_deal_subtypes(i) IN ('BCAP', 'BFLOOR')) THEN
	          p_md_in.p_side := 'B';
	       ELSE
	          p_md_in.p_side := 'A';
	       END IF;
	       p_md_in.p_batch_id := NULL;
	       p_md_in.p_bond_code := p_bond_code;
	       XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
	       p_mm_reval_rate_temp(i) := p_md_out.p_md_out;

	       -- transaction rate = strike price
	       -- not interest rate, no need to convert TO ACTUAL365
               p_mm_trans_rate_temp(i) := p_transaction_rates(i);

	    ELSIF (p_deal_types(i)='SWPTN') THEN
	        p_maturity_amount_temp(i) := p_face_values(i);

                -- gap amount
	        p_gap_amount_temp(i) := get_signed_amount(p_face_values(i),
		   p_deal_types(i), p_deal_subtypes(i), p_coupon_actions(i));

		-- convert amounts to USD
		IF (p_deal_ccys(i)='USD') THEN
		   p_maturity_amount_usd_temp(i) := p_maturity_amount_temp(i);
		   p_gap_amount_usd_temp(i) := p_gap_amount_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_maturity_amount_temp(i),
			p_maturity_amount_usd_temp(i));
  		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_gap_amount_temp(i),
			p_gap_amount_usd_temp(i));
		END IF;
		-- convert amounts to sob ccy
		IF (p_deal_ccys(i)=p_sob_ccy_temp(i)) THEN
		   p_maturity_amount_sob_temp(i) := p_maturity_amount_temp(i);
		   p_gap_amount_sob_temp(i) := p_gap_amount_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_maturity_amount_temp(i),
			p_maturity_amount_sob_temp(i));
  		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_gap_amount_temp(i), p_gap_amount_sob_temp(i));
		END IF;

		p_accrued_interest_temp(i) := 0;
		p_accrued_interest_usd_temp(i) := 0;
		p_accrued_interest_sob_temp(i) := 0;

		-- convert premium amount to USD
                IF (p_premium_ccys(i)='USD') THEN
                   p_premium_amount_usd_temp(i) := p_premium_amounts(i);
                ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_premium_ccys(i), 'USD', p_premium_amounts(i),
			p_premium_amount_usd_temp(i));
		END IF;
		-- convert premium amount into SOB ccy
		IF (p_premium_ccys(i)=p_sob_ccy_temp(i)) THEN
		   p_premium_amount_sob_temp(i) := p_premium_amounts(i);
                ELSIF ('USD'=p_sob_ccy_temp(i)) THEN
		   p_premium_amount_sob_temp(i) := p_premium_amount_usd_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_premium_ccys(i), p_sob_ccy_temp(i),
			p_premium_amounts(i), p_premium_amount_sob_temp(i));
		END IF;

		IF (p_day_count_bases(i) <> p_mm_day_count_basis) THEN
		  -- transaction rate, converted to Act/365
		  p_rc_in.p_start_date := p_start_dates(i);
		  p_rc_in.p_end_date := p_maturity_dates(i);
		  p_rc_in.p_day_count_basis_in := p_day_count_bases(i);
		  p_rc_in.p_day_count_basis_out := p_mm_day_count_basis;
		  IF (within_one_year(p_start_dates(i),
				    p_maturity_dates(i))) THEN
		     p_rc_in.p_rate_type_in := 'S';
		     p_rc_in.p_rate_type_out := 'S';
		  ELSE
		     p_rc_in.p_rate_type_in := 'P';
		     p_rc_in.p_rate_type_out := 'P';
		     p_rc_in.p_compound_freq_in := 1;
		     p_rc_in.p_compound_freq_out := 1;
		  END IF;
		  p_rc_in.p_rate_in := p_transaction_rates(i);
		  rate_conversion(p_rc_in, p_rc_out);
		  p_mm_trans_rate_temp(i) := p_rc_out.p_rate_out;
                ELSE
		  p_mm_trans_rate_temp(i) := p_transaction_rates(i);
		END IF;

	    ELSIF (p_deal_types(i)='ONC') THEN
		p_maturity_amount_temp(i) := get_signed_amount(
			p_start_amounts(i), p_deal_types(i),
			p_deal_subtypes(i), null);
		p_gap_amount_temp(i) := p_maturity_amount_temp(i);

		-- convert amounts to USD
		IF (p_deal_ccys(i)='USD') THEN
		   p_maturity_amount_usd_temp(i) := p_maturity_amount_temp(i);
		   p_gap_amount_usd_temp(i) := p_gap_amount_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_maturity_amount_temp(i),
			p_maturity_amount_usd_temp(i));
  		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_gap_amount_temp(i),
			p_gap_amount_usd_temp(i));
		END IF;
		-- convert amounts to sob ccy
		IF (p_deal_ccys(i)=p_sob_ccy_temp(i)) THEN
		   p_maturity_amount_sob_temp(i) := p_maturity_amount_temp(i);
		   p_gap_amount_sob_temp(i) := p_gap_amount_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_maturity_amount_temp(i),
			p_maturity_amount_sob_temp(i));
  		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_gap_amount_temp(i), p_gap_amount_sob_temp(i));
		END IF;

		-- get trans rate
		IF (p_day_count_bases(i) <> p_mm_day_count_basis) THEN
		  -- transaction rate, converted to Act/365
		  -- calculated from settlement date to today
		  p_rc_in.p_start_date := p_start_dates(i);
                  --bug 2385017
                  IF (p_start_dates(i)>p_ref_date) THEN
                    p_rc_in.p_end_date := p_start_dates(i)+1;
                  ELSE
  		    p_rc_in.p_end_date := p_ref_date;
                  END IF;
		  p_rc_in.p_day_count_basis_in := p_day_count_bases(i);
		  p_rc_in.p_day_count_basis_out := p_mm_day_count_basis;
		  IF (within_one_year(p_start_dates(i),
				    p_end_dates(i))) THEN
		     p_rc_in.p_rate_type_in := 'S';
		     p_rc_in.p_rate_type_out := 'S';
		  ELSE
		     p_rc_in.p_rate_type_in := 'P';
		     p_rc_in.p_rate_type_out := 'P';
		     p_rc_in.p_compound_freq_in := 1;
		     p_rc_in.p_compound_freq_out := 1;
		  END IF;
		  p_rc_in.p_rate_in := p_transaction_rates(i);
		  rate_conversion(p_rc_in, p_rc_out);
		  p_mm_trans_rate_temp(i) := p_rc_out.p_rate_out;
		ELSE
		  p_mm_trans_rate_temp(i) := p_transaction_rates(i);
		END IF;

	   IF (p_insert_or_update <> 'N') THEN
	        -- accrued interest
		p_accrued_interest_temp(i) :=
			QRM_MM_FORMULAS.calculate_accrued_interest('R',
				p_ref_date, p_start_dates(i),
				p_maturity_dates(i), p_transaction_rates(i),
				p_interests(i), p_accum_int_bfs(i),
				p_face_values(i), p_no_of_days(i),
				p_day_count_bases(i), p_accum_int_actions(i));
		IF (g_proc_level>=g_debug_level) THEN
		   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'onc accrued int: '||p_accrued_interest_temp(i));
		END IF;
		if (nvl(p_prepaid_interests(i),'N')='Y' and p_ref_date >= p_start_dates(i)) then
			p_accrued_interest_temp(i) := p_accrued_interest_temp(i) - nvl(p_interests(i),0);
		end if;
		p_accrued_interest_temp(i) := get_signed_amount(
			p_accrued_interest_temp(i), p_deal_types(i),
			p_deal_subtypes(i), null);

		-- bug 2914370: for prepaid ONC fair value = maturity amount only;
		if (nvl(p_prepaid_interests(i),'N')='Y') then
			p_fair_value_temp(i) := p_maturity_amount_temp(i);
		else
		-- fair value: principal amt + accrued interest
			p_fair_value_temp(i) := p_maturity_amount_temp(i) +
						p_accrued_interest_temp(i);
		end if;

		-- convert fair value amounts to USD
		IF (p_deal_ccys(i)='USD') THEN
		   p_fair_value_usd_temp(i) := p_fair_value_temp(i);
		   p_accrued_interest_usd_temp(i) := p_accrued_interest_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_fair_value_temp(i),
			p_fair_value_usd_temp(i));
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_accrued_interest_temp(i),
			p_accrued_interest_usd_temp(i));
		END IF;
		-- convert fair value amounts to sob ccy
		IF (p_deal_ccys(i)=p_sob_ccy_temp(i)) THEN
		   p_fair_value_sob_temp(i) := p_fair_value_temp(i);
		   p_accrued_interest_sob_temp(i) := p_accrued_interest_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_fair_value_temp(i), p_fair_value_sob_temp(i));
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_accrued_interest_temp(i),
			p_accrued_interest_sob_temp(i));
		END IF;
		p_upd_md_calc_date_temp(i) := p_ref_datetime;
	    ELSE
		p_insert_or_update := 'U';
		p_upd_md_calc_date_temp(i) := p_deal_calculations.last_md_calc_date;
		p_fair_value_temp(i) := p_deal_calculations.fair_value;
		p_fair_value_usd_temp(i) := p_deal_calculations.fair_value_usd;
		p_fair_value_sob_temp(i) := p_deal_calculations.fair_value_sob;
		p_accrued_interest_temp(i) := p_deal_calculations.accrued_interest;
		p_accrued_interest_usd_temp(i) := p_deal_calculations.accrued_interest_usd;
		p_accrued_interest_sob_temp(i) := p_deal_calculations.accrued_interest_sob;
	    END IF;  -- end threshold check for fv/sens calculations

	ELSIF (p_deal_types(i)='IG') THEN
		-- get day count basis
		OPEN get_ig_day_count_basis(p_deal_ccys(i));
		FETCH get_ig_day_count_basis INTO p_day_count_bases(i);
		CLOSE get_ig_day_count_basis;

		p_maturity_amount_temp(i) := p_face_values(i);
		p_gap_amount_temp(i) := p_face_values(i);

		-- convert amounts to USD
		IF (p_deal_ccys(i)='USD') THEN
		   p_maturity_amount_usd_temp(i) := p_maturity_amount_temp(i);
		   p_gap_amount_usd_temp(i) := p_gap_amount_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_maturity_amount_temp(i),
			p_maturity_amount_usd_temp(i));
  		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_gap_amount_temp(i),
			p_gap_amount_usd_temp(i));
		END IF;
		-- convert amounts to sob ccy
		IF (p_deal_ccys(i)=p_sob_ccy_temp(i)) THEN
		   p_maturity_amount_sob_temp(i) := p_maturity_amount_temp(i);
		   p_gap_amount_sob_temp(i) := p_gap_amount_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_maturity_amount_temp(i),
			p_maturity_amount_sob_temp(i));
  		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_gap_amount_temp(i), p_gap_amount_sob_temp(i));
		END IF;

		-- for IG, 'current' transaction is max(transaction_no)
		IF (p_day_count_bases(i) <> p_mm_day_count_basis) THEN
		  -- transaction rate, converted to Act/365
		  p_rc_in.p_start_date := p_start_dates(i);
		  p_rc_in.p_end_date := p_end_dates(i);
		  p_rc_in.p_day_count_basis_in := p_day_count_bases(i);
		  p_rc_in.p_day_count_basis_out := p_mm_day_count_basis;
		  IF (within_one_year(p_start_dates(i),
				    p_maturity_dates(i))) THEN
		     p_rc_in.p_rate_type_in := 'S';
		     p_rc_in.p_rate_type_out := 'S';
		  ELSE
		     p_rc_in.p_rate_type_in := 'P';
		     p_rc_in.p_rate_type_out := 'P';
		     p_rc_in.p_compound_freq_in := 1;
		     p_rc_in.p_compound_freq_out := 1;
		  END IF;
		  p_rc_in.p_rate_in := p_transaction_rates(i);
		  rate_conversion(p_rc_in, p_rc_out);
		  p_mm_trans_rate_temp(i) := p_rc_out.p_rate_out;
		ELSE
		  p_mm_trans_rate_temp(i) := p_transaction_rates(i);
		END IF;

	    IF (p_insert_or_update <> 'N') THEN
		-- accrued interest
		IF (g_proc_level>=g_debug_level) THEN
		   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'IG DCB: '||p_day_count_bases(i));
		END IF;
 	    	days_run_helper(p_start_dates(i), p_ref_date,
		   p_day_count_bases(i), NULL, p_day_count, p_annual_basis);

		-- sum of accrued interest from previous transaction
		-- and accrual of this transaction
		-- no need to modify sign of accrued int/ fair value
		-- because balance saved in db already carries sign
		IF (g_proc_level>=g_debug_level) THEN
		   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'prev accrued int: '||p_accrued_interests(i));
		   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'balance: '||p_face_values(i));
		   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'int rate: '||p_transaction_rates(i));
		   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'days accrued: '||p_day_count);
		   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'annual basis: '||p_annual_basis);
		END IF;
		p_accrued_interest_temp(i) := p_accrued_interests(i) +
		  	p_face_values(i)*p_transaction_rates(i)*p_day_count/
						(100*p_annual_basis);
		-- fair value
		p_fair_value_temp(i) := p_face_values(i) + p_accrued_interest_temp(i);
		-- convert amounts to USD
		IF (p_deal_ccys(i)='USD') THEN
		   p_fair_value_usd_temp(i) := p_fair_value_temp(i);
		   p_accrued_interest_usd_temp(i) := p_accrued_interest_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_fair_value_temp(i),
			p_fair_value_usd_temp(i));
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), 'USD', p_accrued_interest_temp(i),
			p_accrued_interest_usd_temp(i));
		END IF;
		-- convert amounts to sob ccy
		IF (p_deal_ccys(i)=p_sob_ccy_temp(i)) THEN
		   p_fair_value_sob_temp(i) := p_fair_value_temp(i);
		   p_accrued_interest_sob_temp(i) := p_accrued_interest_temp(i);
		ELSE
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_fair_value_temp(i), p_fair_value_sob_temp(i));
		   convert_amounts(p_market_data_set_temp(i),p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_accrued_interest_temp(i),
			p_accrued_interest_sob_temp(i));
		END IF;
		p_upd_md_calc_date_temp(i) := p_ref_datetime;
	     ELSE
		p_insert_or_update := 'U';
		p_upd_md_calc_date_temp(i) := p_deal_calculations.last_md_calc_date;
		p_fair_value_temp(i) := p_deal_calculations.fair_value;
		p_fair_value_usd_temp(i) := p_deal_calculations.fair_value_usd;
		p_fair_value_sob_temp(i) := p_deal_calculations.fair_value_sob;
		p_accrued_interest_temp(i) := p_deal_calculations.accrued_interest;
		p_accrued_interest_usd_temp(i) := p_deal_calculations.accrued_interest_usd;
		p_accrued_interest_sob_temp(i) := p_deal_calculations.accrued_interest_sob;
	     END IF; -- end threshold check for fv/sens calculations

	END IF;   -- end if fxo or fx
	 IF (g_proc_level>=g_debug_level) THEN
	    XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'PAST DEAL SWITCH LOOP');
	 END IF;



	----- Place attributes in insert/update array ----------------
	    IF(p_insert_or_update='I') THEN  -- insert deal
	       p_insert_counter := p_insert_counter + 1;
	       p_seq_nos.EXTEND;
	       OPEN get_sequence_no;
	       FETCH get_sequence_no INTO p_seq_nos(p_insert_counter);
	       CLOSE get_sequence_no;
	       p_deal_no_insert.EXTEND;
	       p_deal_no_insert(p_insert_counter):=p_deal_nos(i);
	       p_company_code_insert.EXTEND;
	       p_company_code_insert(p_insert_counter):=p_company_code_temp(i);
	       p_transaction_no_insert.EXTEND;
	       p_transaction_no_insert(p_insert_counter):=p_transaction_nos(i);
	       p_market_data_set_insert.EXTEND;
	       p_market_data_set_insert(p_insert_counter):=p_market_data_set_temp(i);
               p_deal_ccy_insert.EXTEND;
	       p_deal_ccy_insert(p_insert_counter):=p_deal_ccy_temp(i);
               p_sob_ccy_insert.EXTEND;
	       p_sob_ccy_insert(p_insert_counter):=p_sob_ccy_temp(i);
               p_base_ccy_amount_usd_insert.EXTEND;
	       p_base_ccy_amount_usd_insert(p_insert_counter):=p_base_ccy_amount_usd_temp(i);
               p_base_ccy_amount_sob_insert.EXTEND;
	       p_base_ccy_amount_sob_insert(p_insert_counter):=p_base_ccy_amount_sob_temp(i);
	       p_contra_ccy_amount_usd_insert.EXTEND;
	       p_contra_ccy_amount_usd_insert(p_insert_counter):=p_contra_ccy_amount_usd_temp(i);
	       p_contra_ccy_amount_sob_insert.EXTEND;
	       p_contra_ccy_amount_sob_insert(p_insert_counter):=p_contra_ccy_amount_sob_temp(i);
	       p_foreign_amount_usd_insert.EXTEND;
	       p_foreign_amount_usd_insert(p_insert_counter):=p_foreign_amount_usd_temp(i);
               p_foreign_amount_sob_insert.EXTEND;
	       p_foreign_amount_sob_insert(p_insert_counter):=p_foreign_amount_sob_temp(i);
	       p_domestic_amount_usd_insert.EXTEND;
 	       p_domestic_amount_usd_insert(p_insert_counter):=p_domestic_amount_usd_temp(i);
	       p_domestic_amount_sob_insert.EXTEND;
	       p_domestic_amount_sob_insert(p_insert_counter):=p_domestic_amount_sob_temp(i);
	       p_buy_amount_usd_insert.EXTEND;
	       p_buy_amount_usd_insert(p_insert_counter):=p_buy_amount_usd_temp(i);
	       p_buy_amount_sob_insert.EXTEND;
	       p_buy_amount_sob_insert(p_insert_counter):=p_buy_amount_sob_temp(i);
	       p_sell_amount_usd_insert.EXTEND;
	       p_sell_amount_usd_insert(p_insert_counter):=p_sell_amount_usd_temp(i);
	       p_sell_amount_sob_insert.EXTEND;
	       p_sell_amount_sob_insert(p_insert_counter):=p_sell_amount_sob_temp(i);
	       p_days_insert.EXTEND;
	       p_days_insert(p_insert_counter):=p_days_temp(i);
	       p_fx_reval_rate_insert.EXTEND;
	       p_fx_reval_rate_insert(p_insert_counter):=p_fx_reval_rate_temp(i);
	       p_reval_price_insert.EXTEND;
	       p_reval_price_insert(p_insert_counter):=p_reval_price_temp(i);

	       p_reval_price_usd_insert.EXTEND;
	       p_reval_price_usd_insert(p_insert_counter):=p_reval_price_usd_temp(i);

	       p_reval_price_sob_insert.EXTEND;
	       p_reval_price_sob_insert(p_insert_counter):=p_reval_price_sob_temp(i);

	       p_mm_reval_rate_insert.EXTEND;
	       p_mm_reval_rate_insert(p_insert_counter):=p_mm_reval_rate_temp(i);
	       p_fx_trans_rate_insert.EXTEND;
	       p_fx_trans_rate_insert(p_insert_counter):=p_fx_trans_rate_temp(i);
	       p_trans_price_insert.EXTEND;
	       p_trans_price_insert(p_insert_counter):=p_trans_price_temp(i);

	       p_trans_price_usd_insert.EXTEND;
	       p_trans_price_usd_insert(p_insert_counter):=p_trans_price_usd_temp(i);

	       p_trans_price_sob_insert.EXTEND;
	       p_trans_price_sob_insert(p_insert_counter):=p_trans_price_sob_temp(i);

	       p_mm_trans_rate_insert.EXTEND;
	       p_mm_trans_rate_insert(p_insert_counter):=p_mm_trans_rate_temp(i);
	       p_fair_value_insert.EXTEND;
 	       p_fair_value_insert(p_insert_counter):=p_fair_value_temp(i);
	       p_fair_value_usd_insert.EXTEND;
	       p_fair_value_usd_insert(p_insert_counter):=p_fair_value_usd_temp(i);
	       p_fair_value_sob_insert.EXTEND;
	       p_fair_value_sob_insert(p_insert_counter):=p_fair_value_sob_temp(i);
	       p_gap_amount_insert.EXTEND;
	       p_gap_amount_insert(p_insert_counter):=p_gap_amount_temp(i);
	       p_gap_amount_usd_insert.EXTEND;
	       p_gap_amount_usd_insert(p_insert_counter):=p_gap_amount_usd_temp(i);
	       p_gap_amount_sob_insert.EXTEND;
	       p_gap_amount_sob_insert(p_insert_counter):=p_gap_amount_sob_temp(i);
	       p_maturity_amount_insert.EXTEND;
	       p_maturity_amount_insert(p_insert_counter):=p_maturity_amount_temp(i);
	       p_maturity_amount_usd_insert.EXTEND;
	       p_maturity_amount_usd_insert(p_insert_counter):=p_maturity_amount_usd_temp(i);
	       p_maturity_amount_sob_insert.EXTEND;
	       p_maturity_amount_sob_insert(p_insert_counter):=p_maturity_amount_sob_temp(i);
	       p_premium_amount_usd_insert.EXTEND;
	       p_premium_amount_usd_insert(p_insert_counter):=p_premium_amount_usd_temp(i);
	       p_premium_amount_sob_insert.EXTEND;
	       p_premium_amount_sob_insert(p_insert_counter):=p_premium_amount_sob_temp(i);
	       p_accrued_interest_insert.EXTEND;
	       p_accrued_interest_insert(p_insert_counter):=p_accrued_interest_temp(i);
	       p_accrued_interest_usd_insert.EXTEND;
	       p_accrued_interest_usd_insert(p_insert_counter):=p_accrued_interest_usd_temp(i);
	       p_accrued_interest_sob_insert.EXTEND;
	       p_accrued_interest_sob_insert(p_insert_counter):=p_accrued_interest_sob_temp(i);
	       p_duration_insert.EXTEND;
	       p_duration_insert(p_insert_counter):=p_duration_temp(i);
	       p_mod_duration_insert.EXTEND;
	       p_mod_duration_insert(p_insert_counter):=p_mod_duration_temp(i);
	       p_convexity_insert.EXTEND;
	       p_convexity_insert(p_insert_counter):=p_convexity_temp(i);
	       p_delta_insert.EXTEND;
	       p_delta_insert(p_insert_counter):=p_delta_temp(i);
	       p_gamma_insert.EXTEND;
	       p_gamma_insert(p_insert_counter):=p_gamma_temp(i);
	       p_theta_insert.EXTEND;
	       p_theta_insert(p_insert_counter):=p_theta_temp(i);
	       p_rho_insert.EXTEND;
	       p_rho_insert(p_insert_counter) := p_rho_temp(i);
	       p_rho_base_insert.EXTEND;
	       p_rho_base_insert(p_insert_counter) := p_rho_base_temp(i);
	       p_rho_contra_insert.EXTEND;
	       p_rho_contra_insert(p_insert_counter) := p_rho_contra_temp(i);
	       p_rho_for_insert.EXTEND;
	       p_rho_for_insert(p_insert_counter):=p_rho_for_temp(i);
	       p_rho_dom_insert.EXTEND;
	       p_rho_dom_insert(p_insert_counter):=p_rho_dom_temp(i);
	       p_vega_insert.EXTEND;
	       p_vega_insert(p_insert_counter):=p_vega_temp(i);
	       p_pos_bpv_insert.EXTEND;
	       p_pos_bpv_insert(p_insert_counter):=p_pos_bpv_temp(i);
	       p_pos_bpv_usd_insert.EXTEND;
	       p_pos_bpv_usd_insert(p_insert_counter) := p_pos_bpv_usd_temp(i);
	       p_pos_bpv_sob_insert.EXTEND;
	       p_pos_bpv_sob_insert(p_insert_counter) := p_pos_bpv_sob_temp(i);
	       p_pos_delta_insert.EXTEND;
	       p_pos_delta_insert(p_insert_counter):=p_pos_delta_temp(i);
	       p_pos_delta_usd_insert.EXTEND;
	       p_pos_delta_usd_insert(p_insert_counter) := p_pos_delta_usd_temp(i);
	       p_pos_delta_sob_insert.EXTEND;
	       p_pos_delta_sob_insert(p_insert_counter) := p_pos_delta_sob_temp(i);
	       p_pos_gamma_insert.EXTEND;
	       p_pos_gamma_insert(p_insert_counter):=p_pos_gamma_temp(i);
	       p_pos_gamma_usd_insert.EXTEND;
	       p_pos_gamma_usd_insert(p_insert_counter) := p_pos_gamma_usd_temp(i);
	       p_pos_gamma_sob_insert.EXTEND;
	       p_pos_gamma_sob_insert(p_insert_counter) := p_pos_gamma_sob_temp(i);
	       p_pos_theta_insert.EXTEND;
	       p_pos_theta_insert(p_insert_counter):=p_pos_theta_temp(i);
	       p_pos_theta_usd_insert.EXTEND;
	       p_pos_theta_usd_insert(p_insert_counter) := p_pos_theta_usd_temp(i);
	       p_pos_theta_sob_insert.EXTEND;
	       p_pos_theta_sob_insert(p_insert_counter) := p_pos_theta_sob_temp(i);
	       p_pos_rho_insert.EXTEND;
	       p_pos_rho_insert(p_insert_counter) := p_pos_rho_temp(i);
	       p_pos_rho_usd_insert.EXTEND;
	       p_pos_rho_usd_insert(p_insert_counter) := p_pos_rho_usd_temp(i);
	       p_pos_rho_sob_insert.EXTEND;
	       p_pos_rho_sob_insert(p_insert_counter) := p_pos_rho_sob_temp(i);
	       p_pos_rho_base_insert.EXTEND;
	       p_pos_rho_base_insert(p_insert_counter) := p_pos_rho_base_temp(i);
	       p_pos_rho_base_usd_insert.EXTEND;
	       p_pos_rho_base_usd_insert(p_insert_counter) := p_pos_rho_base_usd_temp(i);
	       p_pos_rho_base_sob_insert.EXTEND;
	       p_pos_rho_base_sob_insert(p_insert_counter) := p_pos_rho_base_sob_temp(i);
	       p_pos_rho_contra_insert.EXTEND;
	       p_pos_rho_contra_insert(p_insert_counter) := p_pos_rho_contra_temp(i);
	       p_pos_rho_contra_usd_insert.EXTEND;
	       p_pos_rho_contra_usd_insert(p_insert_counter) := p_pos_rho_contra_usd_temp(i);
	       p_pos_rho_contra_sob_insert.EXTEND;
	       p_pos_rho_contra_sob_insert(p_insert_counter) := p_pos_rho_contra_sob_temp(i);
	       p_pos_rho_for_insert.EXTEND;
	       p_pos_rho_for_insert(p_insert_counter):=p_pos_rho_for_temp(i);
	       p_pos_rho_for_usd_insert.EXTEND;
	       p_pos_rho_for_usd_insert(p_insert_counter) := p_pos_rho_for_usd_temp(i);
	       p_pos_rho_for_sob_insert.EXTEND;
	       p_pos_rho_for_sob_insert(p_insert_counter) := p_pos_rho_for_sob_temp(i);
	       p_pos_rho_dom_insert.EXTEND;
	       p_pos_rho_dom_insert(p_insert_counter):=p_pos_rho_dom_temp(i);
	       p_pos_rho_dom_usd_insert.EXTEND;
	       p_pos_rho_dom_usd_insert(p_insert_counter) := p_pos_rho_dom_usd_temp(i);
	       p_pos_rho_dom_sob_insert.EXTEND;
               p_pos_rho_dom_sob_insert(p_insert_counter) := p_pos_rho_dom_sob_temp(i);
	       p_pos_vega_insert.EXTEND;
	       p_pos_vega_insert(p_insert_counter):=p_pos_vega_temp(i);
               p_pos_vega_usd_insert.EXTEND;
	       p_pos_vega_usd_insert(p_insert_counter) := p_pos_vega_usd_temp(i);
	       p_pos_vega_sob_insert.EXTEND;
	       p_pos_vega_sob_insert(p_insert_counter) := p_pos_vega_sob_temp(i);
	       p_volatility_insert.EXTEND;
	       p_volatility_insert(p_insert_counter):=p_volatility_temp(i);
	       p_ytm_insert.EXTEND;
	       p_ytm_insert(p_insert_counter):=p_ytm_temp(i);
	       p_gap_date_insert.EXTEND;
	       p_gap_date_insert(p_insert_counter):=p_gap_date_temp(i);
            ELSE -- update deal
	       p_update_counter := p_update_counter + 1;
	       p_deal_calc_id_update.EXTEND;
	       p_deal_calc_id_update(p_update_counter) := p_deal_calculations.deal_calc_id;
	       p_deal_no_update.EXTEND;
	       p_deal_no_update(p_update_counter):=p_deal_nos(i);
	       p_company_code_update.EXTEND;
	       p_company_code_update(p_update_counter):=p_company_code_temp(i);
	       p_transaction_no_update.EXTEND;
	       p_transaction_no_update(p_update_counter):=p_transaction_nos(i);
	       p_market_data_set_update.EXTEND;
	       p_market_data_set_update(p_update_counter):=p_market_data_set_temp(i);
               p_deal_ccy_update.EXTEND;
	       p_deal_ccy_update(p_update_counter):=p_deal_ccy_temp(i);
               p_sob_ccy_update.EXTEND;
	       p_sob_ccy_update(p_update_counter):=p_sob_ccy_temp(i);
               p_base_ccy_amount_usd_update.EXTEND;
	       p_base_ccy_amount_usd_update(p_update_counter):=p_base_ccy_amount_usd_temp(i);
               p_base_ccy_amount_sob_update.EXTEND;
	       p_base_ccy_amount_sob_update(p_update_counter):=p_base_ccy_amount_sob_temp(i);
	       p_contra_ccy_amount_usd_update.EXTEND;
	       p_contra_ccy_amount_usd_update(p_update_counter):=p_contra_ccy_amount_usd_temp(i);
	       p_contra_ccy_amount_sob_update.EXTEND;
	       p_contra_ccy_amount_sob_update(p_update_counter):=p_contra_ccy_amount_sob_temp(i);
	       p_foreign_amount_usd_update.EXTEND;
	       p_foreign_amount_usd_update(p_update_counter):=p_foreign_amount_usd_temp(i);
               p_foreign_amount_sob_update.EXTEND;
	       p_foreign_amount_sob_update(p_update_counter):=p_foreign_amount_sob_temp(i);
	       p_domestic_amount_usd_update.EXTEND;
 	       p_domestic_amount_usd_update(p_update_counter):=p_domestic_amount_usd_temp(i);
	       p_domestic_amount_sob_update.EXTEND;
	       p_domestic_amount_sob_update(p_update_counter):=p_domestic_amount_sob_temp(i);
	       p_buy_amount_usd_update.EXTEND;
	       p_buy_amount_usd_update(p_update_counter):=p_buy_amount_usd_temp(i);
	       p_buy_amount_sob_update.EXTEND;
	       p_buy_amount_sob_update(p_update_counter):=p_buy_amount_sob_temp(i);
	       p_sell_amount_usd_update.EXTEND;
	       p_sell_amount_usd_update(p_update_counter):=p_sell_amount_usd_temp(i);
	       p_sell_amount_sob_update.EXTEND;
	       p_sell_amount_sob_update(p_update_counter):=p_sell_amount_sob_temp(i);
	       p_days_update.EXTEND;
	       p_days_update(p_update_counter):=p_days_temp(i);
	       p_fx_reval_rate_update.EXTEND;
	       p_fx_reval_rate_update(p_update_counter):=p_fx_reval_rate_temp(i);
	       p_reval_price_update.EXTEND;
	       p_reval_price_update(p_update_counter):=p_reval_price_temp(i);

	       p_reval_price_usd_update.EXTEND;
	       p_reval_price_usd_update(p_update_counter):=p_reval_price_usd_temp(i);

	       p_reval_price_sob_update.EXTEND;
	       p_reval_price_sob_update(p_update_counter):=p_reval_price_sob_temp(i);

	       p_mm_reval_rate_update.EXTEND;
	       p_mm_reval_rate_update(p_update_counter):=p_mm_reval_rate_temp(i);
	       p_fx_trans_rate_update.EXTEND;
	       p_fx_trans_rate_update(p_update_counter):=p_fx_trans_rate_temp(i);
	       p_trans_price_update.EXTEND;
	       p_trans_price_update(p_update_counter):=p_trans_price_temp(i);

	       p_trans_price_usd_update.EXTEND;
	       p_trans_price_usd_update(p_update_counter):=p_trans_price_usd_temp(i);

	       p_trans_price_sob_update.EXTEND;
	       p_trans_price_sob_update(p_update_counter):=p_trans_price_sob_temp(i);

	       p_mm_trans_rate_update.EXTEND;
	       p_mm_trans_rate_update(p_update_counter):=p_mm_trans_rate_temp(i);
	       p_fair_value_update.EXTEND;
 	       p_fair_value_update(p_update_counter):=p_fair_value_temp(i);
	       p_fair_value_usd_update.EXTEND;
	       p_fair_value_usd_update(p_update_counter):=p_fair_value_usd_temp(i);
	       p_fair_value_sob_update.EXTEND;
	       p_fair_value_sob_update(p_update_counter):=p_fair_value_sob_temp(i);
	       p_gap_amount_update.EXTEND;
	       p_gap_amount_update(p_update_counter):=p_gap_amount_temp(i);
	       p_gap_amount_usd_update.EXTEND;
	       p_gap_amount_usd_update(p_update_counter):=p_gap_amount_usd_temp(i);
	       p_gap_amount_sob_update.EXTEND;
	       p_gap_amount_sob_update(p_update_counter):=p_gap_amount_sob_temp(i);
	       p_maturity_amount_update.EXTEND;
	       p_maturity_amount_update(p_update_counter):=p_maturity_amount_temp(i);
	       p_maturity_amount_usd_update.EXTEND;
	       p_maturity_amount_usd_update(p_update_counter):=p_maturity_amount_usd_temp(i);
	       p_maturity_amount_sob_update.EXTEND;
	       p_maturity_amount_sob_update(p_update_counter):=p_maturity_amount_sob_temp(i);
	       p_premium_amount_usd_update.EXTEND;
	       p_premium_amount_usd_update(p_update_counter):=p_premium_amount_usd_temp(i);
	       p_premium_amount_sob_update.EXTEND;
	       p_premium_amount_sob_update(p_update_counter):=p_premium_amount_sob_temp(i);
	       p_accrued_interest_update.EXTEND;
	       p_accrued_interest_update(p_update_counter):=p_accrued_interest_temp(i);
	       p_accrued_interest_usd_update.EXTEND;
	       p_accrued_interest_usd_update(p_update_counter):=p_accrued_interest_usd_temp(i);
	       p_accrued_interest_sob_update.EXTEND;
	       p_accrued_interest_sob_update(p_update_counter):=p_accrued_interest_sob_temp(i);
	       p_duration_update.EXTEND;
	       p_duration_update(p_update_counter):=p_duration_temp(i);
	       p_mod_duration_update.EXTEND;
	       p_mod_duration_update(p_update_counter):=p_mod_duration_temp(i);
	       p_convexity_update.EXTEND;
	       p_convexity_update(p_update_counter):=p_convexity_temp(i);
	       p_delta_update.EXTEND;
	       p_delta_update(p_update_counter):=p_delta_temp(i);
	       p_gamma_update.EXTEND;
	       p_gamma_update(p_update_counter):=p_gamma_temp(i);
	       p_theta_update.EXTEND;
	       p_theta_update(p_update_counter):=p_theta_temp(i);
	       p_rho_update.EXTEND;
	       p_rho_update(p_update_counter) := p_rho_temp(i);
	       p_rho_base_update.EXTEND;
	       p_rho_base_update(p_update_counter) := p_rho_base_temp(i);
	       p_rho_contra_update.EXTEND;
	       p_rho_contra_update(p_update_counter) := p_rho_contra_temp(i);
	       p_rho_for_update.EXTEND;
	       p_rho_for_update(p_update_counter):=p_rho_for_temp(i);
	       p_rho_dom_update.EXTEND;
	       p_rho_dom_update(p_update_counter):=p_rho_dom_temp(i);
	       p_vega_update.EXTEND;
	       p_vega_update(p_update_counter):=p_vega_temp(i);
	       p_pos_bpv_update.EXTEND;
	       p_pos_bpv_update(p_update_counter):=p_pos_bpv_temp(i);
	       p_pos_bpv_usd_update.EXTEND;
	       p_pos_bpv_usd_update(p_update_counter) := p_pos_bpv_usd_temp(i);
	       p_pos_bpv_sob_update.EXTEND;
	       p_pos_bpv_sob_update(p_update_counter) := p_pos_bpv_sob_temp(i);
	       p_pos_delta_update.EXTEND;
	       p_pos_delta_update(p_update_counter):=p_pos_delta_temp(i);
	       p_pos_delta_usd_update.EXTEND;
	       p_pos_delta_usd_update(p_update_counter) := p_pos_delta_usd_temp(i);
	       p_pos_delta_sob_update.EXTEND;
	       p_pos_delta_sob_update(p_update_counter) := p_pos_delta_sob_temp(i);
	       p_pos_gamma_update.EXTEND;
	       p_pos_gamma_update(p_update_counter):=p_pos_gamma_temp(i);
	       p_pos_gamma_usd_update.EXTEND;
	       p_pos_gamma_usd_update(p_update_counter) := p_pos_gamma_usd_temp(i);
	       p_pos_gamma_sob_update.EXTEND;
	       p_pos_gamma_sob_update(p_update_counter) := p_pos_gamma_sob_temp(i);
	       p_pos_theta_update.EXTEND;
	       p_pos_theta_update(p_update_counter):=p_pos_theta_temp(i);
	       p_pos_theta_usd_update.EXTEND;
	       p_pos_theta_usd_update(p_update_counter) := p_pos_theta_usd_temp(i);
	       p_pos_theta_sob_update.EXTEND;
	       p_pos_theta_sob_update(p_update_counter) := p_pos_theta_sob_temp(i);
	       p_pos_rho_update.EXTEND;
	       p_pos_rho_update(p_update_counter) := p_pos_rho_temp(i);
	       p_pos_rho_usd_update.EXTEND;
	       p_pos_rho_usd_update(p_update_counter) := p_pos_rho_usd_temp(i);
	       p_pos_rho_sob_update.EXTEND;
	       p_pos_rho_sob_update(p_update_counter) := p_pos_rho_sob_temp(i);
	       p_pos_rho_base_update.EXTEND;
	       p_pos_rho_base_update(p_update_counter) := p_pos_rho_base_temp(i);
	       p_pos_rho_base_usd_update.EXTEND;
	       p_pos_rho_base_usd_update(p_update_counter) := p_pos_rho_base_usd_temp(i);
	       p_pos_rho_base_sob_update.EXTEND;
	       p_pos_rho_base_sob_update(p_update_counter) := p_pos_rho_base_sob_temp(i);
	       p_pos_rho_contra_update.EXTEND;
	       p_pos_rho_contra_update(p_update_counter) := p_pos_rho_contra_temp(i);
	       p_pos_rho_contra_usd_update.EXTEND;
	       p_pos_rho_contra_usd_update(p_update_counter) := p_pos_rho_contra_usd_temp(i);
	       p_pos_rho_contra_sob_update.EXTEND;
	       p_pos_rho_contra_sob_update(p_update_counter) := p_pos_rho_contra_sob_temp(i);
	       p_pos_rho_for_update.EXTEND;
	       p_pos_rho_for_update(p_update_counter):=p_pos_rho_for_temp(i);
	       p_pos_rho_for_usd_update.EXTEND;
	       p_pos_rho_for_usd_update(p_update_counter) := p_pos_rho_for_usd_temp(i);
	       p_pos_rho_for_sob_update.EXTEND;
	       p_pos_rho_for_sob_update(p_update_counter) := p_pos_rho_for_sob_temp(i);
	       p_pos_rho_dom_update.EXTEND;
	       p_pos_rho_dom_update(p_update_counter):=p_pos_rho_dom_temp(i);
	       p_pos_rho_dom_usd_update.EXTEND;
	       p_pos_rho_dom_usd_update(p_update_counter) := p_pos_rho_dom_usd_temp(i);
	       p_pos_rho_dom_sob_update.EXTEND;
	       p_pos_rho_dom_sob_update(p_update_counter) := p_pos_rho_dom_sob_temp(i);
	       p_pos_vega_update.EXTEND;
	       p_pos_vega_update(p_update_counter):=p_pos_vega_temp(i);
	       p_pos_vega_usd_update.EXTEND;
	       p_pos_vega_usd_update(p_update_counter) := p_pos_vega_usd_temp(i);
	       p_pos_vega_sob_update.EXTEND;
	       p_pos_vega_sob_update(p_update_counter) := p_pos_vega_sob_temp(i);
	       p_volatility_update.EXTEND;
	       p_volatility_update(p_update_counter):=p_volatility_temp(i);
	       p_ytm_update.EXTEND;
	       p_ytm_update(p_update_counter) := p_ytm_temp(i);
	       p_gap_date_update.EXTEND;
	       p_gap_date_update(p_update_counter):=p_gap_date_temp(i);
	       p_upd_md_calc_date_update.EXTEND;
	       p_upd_md_calc_date_update(p_update_counter) := p_upd_md_calc_date_temp(i);
            END IF;
	----------- End: placing attributes into insert/update arrays -----


        ----- >>> ALWAYS RECALCULATE <<< -------
        -- for QRM_TB_CALCULATIONS: calculate everytime for MM deals
	-- for FX/FXO deals, simply save to table
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'deal type is: '||p_deal_types(i));
	   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'deal no is : '||p_deal_nos(i));
	   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'trans no is: '||p_transaction_nos(i));
	   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'mds is: '||p_market_data_set_temp(i));
           XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'tb counter is: '||p_tb_counter);
        END IF;

	IF (p_deal_types(i) NOT IN ('FX', 'FXO')) THEN
	 IF (g_proc_level>=g_debug_level) THEN
	    XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'TB not fx/fxo! deal no: '||p_deal_nos(i));
	 END IF;
         IF (p_deal_types(i)='BOND') THEN
	    p_tb_deal_no.EXTEND;
	    p_tb_transaction_no.EXTEND;
	    p_tb_market_data_set.EXTEND;
	    p_tb_pos_start_date.EXTEND;
	    p_tb_pos_end_date.EXTEND;
	    p_tb_start_date.EXTEND;
            p_tb_end_date.EXTEND;
            p_tb_outst_amount.EXTEND;
	    p_tb_outst_amount_usd.EXTEND;
	    p_tb_outst_amount_sob.EXTEND;
	    p_tb_amt_qty_out.EXTEND;
   	    p_tb_amt_qty_out_usd.EXTEND;
   	    p_tb_amt_qty_out_sob.EXTEND;
	    p_tb_interest_basis.EXTEND;
	    p_tb_coupon_rate.EXTEND;
	    p_tb_next_coupon_date.EXTEND;
            p_tb_counter := p_tb_counter + 1;

	    p_tb_deal_no(p_tb_counter) := p_deal_nos(i);
	    p_tb_transaction_no(p_tb_counter) := p_transaction_nos(i);
	    p_tb_market_data_set(p_tb_counter) := p_market_data_set_temp(i);
	    IF (p_tb_curr_deal_no <> p_deal_nos(i)) THEN
	        p_tb_pos_start_date(p_tb_counter) := p_deal_dates(i);
		p_tb_curr_deal_no := p_deal_nos(i);
	    ELSE
	        p_tb_pos_start_date(p_tb_counter) := p_start_dates(i);
	    END IF;
	    p_tb_pos_end_date(p_tb_counter) := p_maturity_dates(i);
	    p_tb_start_date(p_tb_counter) := p_start_dates(i);
            p_tb_end_date(p_tb_counter) := p_maturity_dates(i);
	    p_tb_outst_amount(p_tb_counter) := get_signed_amount(p_face_values(i), p_deal_types(i), p_deal_subtypes(i), null);
	    --bug 2804548: if Interest Basis is null then it's Fixed.
	    --bug 2918579: fix bug 2804584
	    IF (p_initial_bases(i) = 'FLOAT') THEN
	       p_tb_interest_basis(p_tb_counter) := 'L';
	    ELSE
	       p_tb_interest_basis(p_tb_counter) := 'F';
	    END IF;

	    p_tb_coupon_rate(p_tb_counter) := p_coupon_rates(i);
	    p_tb_next_coupon_date(p_tb_counter) := p_next_coupon_dates(i);
	    -- convert outstanding amounts
	    IF (p_deal_ccys(i) = 'USD') THEN
	       p_tb_outst_amount_usd(p_tb_counter) := p_tb_outst_amount(p_tb_counter);
	    ELSE
	       convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_deal_ccys(i), 'USD', p_tb_outst_amount(p_tb_counter), 		       p_tb_outst_amount_usd(p_tb_counter));
	    END IF;
	    IF (p_deal_ccys(i) = p_sob_ccy_temp(i)) THEN
	       p_tb_outst_amount_sob(p_tb_counter) := p_tb_outst_amount(p_tb_counter);
	    ELSE
	       convert_amounts(p_market_data_set_temp(i), p_ref_date,
		p_deal_ccys(i), p_sob_ccy_temp(i),
		p_tb_outst_amount(p_tb_counter),
		p_tb_outst_amount_sob(p_tb_counter));
	    END IF;
	    p_tb_amt_qty_out(p_tb_counter) := p_tb_outst_amount(p_tb_counter);
	    p_tb_amt_qty_out_sob(p_tb_counter) := p_tb_outst_amount_sob(p_tb_counter);
	    p_tb_amt_qty_out_usd(p_tb_counter) := p_tb_outst_amount_usd(p_tb_counter);
	  ELSIF (p_deal_types(i)='STOCK') THEN
	    p_tb_deal_no.EXTEND;
	    p_tb_transaction_no.EXTEND;
	    p_tb_market_data_set.EXTEND;
	    p_tb_pos_start_date.EXTEND;
	    p_tb_pos_end_date.EXTEND;
	    p_tb_start_date.EXTEND;
            p_tb_end_date.EXTEND;
            p_tb_outst_amount.EXTEND;
	    p_tb_outst_amount_usd.EXTEND;
	    p_tb_outst_amount_sob.EXTEND;
	    p_tb_amt_qty_out.EXTEND;
   	    p_tb_amt_qty_out_usd.EXTEND;
   	    p_tb_amt_qty_out_sob.EXTEND;
	    p_tb_interest_basis.EXTEND;
	    p_tb_coupon_rate.EXTEND;
	    p_tb_next_coupon_date.EXTEND;
            p_tb_counter := p_tb_counter + 1;

	    p_tb_deal_no(p_tb_counter) := p_deal_nos(i);
	    p_tb_transaction_no(p_tb_counter) := p_transaction_nos(i);
	    p_tb_market_data_set(p_tb_counter) := p_market_data_set_temp(i);


	    IF (p_tb_curr_deal_no <> p_deal_nos(i)) THEN
	        p_tb_pos_start_date(p_tb_counter) := p_deal_dates(i);
		p_tb_curr_deal_no := p_deal_nos(i);
	    ELSE
	       p_tb_pos_start_date(p_tb_counter) := p_deal_dates(i);
	    END IF;
	    p_tb_pos_end_date(p_tb_counter) := p_maturity_dates(i);
	    p_tb_start_date(p_tb_counter) := p_deal_dates(i);
            p_tb_end_date(p_tb_counter) := p_ref_date+1;
	    p_tb_outst_amount(p_tb_counter) := p_trans_price_temp(i)*
						p_quantity_out(i);
	    -- convert outstanding amounts
	    IF (p_deal_ccys(i) = 'USD') THEN
	       p_tb_outst_amount_usd(p_tb_counter) := p_tb_outst_amount(p_tb_counter);
	    ELSE
	       convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_deal_ccys(i), 'USD', p_tb_outst_amount(p_tb_counter), 		       p_tb_outst_amount_usd(p_tb_counter));
	    END IF;
	    IF (p_deal_ccys(i) = p_sob_ccy_temp(i)) THEN
	       p_tb_outst_amount_sob(p_tb_counter) := p_tb_outst_amount(p_tb_counter);
	    ELSE
	       convert_amounts(p_market_data_set_temp(i), p_ref_date,
		p_deal_ccys(i), p_sob_ccy_temp(i),
		p_tb_outst_amount(p_tb_counter),
		p_tb_outst_amount_sob(p_tb_counter));
	    END IF;

	    p_tb_interest_basis(p_tb_counter) := NULL;
	    p_tb_coupon_rate(p_tb_counter) := NULL;
	    p_tb_next_coupon_date(p_tb_counter) := NULL;

            p_tb_amt_qty_out(p_tb_counter) := p_quantity_out(i);
	    p_tb_amt_qty_out_sob(p_tb_counter) :=  p_quantity_out(i);
	    p_tb_amt_qty_out_usd(p_tb_counter) :=  p_quantity_out(i);
	    IF (g_proc_level>=g_debug_level) THEN
	       XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'Past stock tb calculations');
	    END IF;
         ELSIF (p_deal_types(i)='NI') THEN
	    p_tb_deal_no.EXTEND;
	    p_tb_transaction_no.EXTEND;
	    p_tb_market_data_set.EXTEND;
	    p_tb_pos_start_date.EXTEND;
	    p_tb_pos_end_date.EXTEND;
	    p_tb_start_date.EXTEND;
            p_tb_end_date.EXTEND;
            p_tb_outst_amount.EXTEND;
	    p_tb_outst_amount_usd.EXTEND;
	    p_tb_outst_amount_sob.EXTEND;
	    p_tb_amt_qty_out.EXTEND;
   	    p_tb_amt_qty_out_usd.EXTEND;
   	    p_tb_amt_qty_out_sob.EXTEND;
	    p_tb_interest_basis.EXTEND;
	    p_tb_coupon_rate.EXTEND;
	    p_tb_next_coupon_date.EXTEND;
            p_tb_counter := p_tb_counter + 1;

	    p_tb_deal_no(p_tb_counter) := p_deal_nos(i);
	    p_tb_transaction_no(p_tb_counter) := p_transaction_nos(i);
	    p_tb_market_data_set(p_tb_counter) := p_market_data_set_temp(i);
	    IF (p_tb_curr_deal_no <> p_deal_nos(i)) THEN
	        p_tb_pos_start_date(p_tb_counter) := p_deal_dates(i);
		p_tb_curr_deal_no := p_deal_nos(i);
	    ELSE
	        p_tb_pos_start_date(p_tb_counter) := p_start_dates(i);
	    END IF;
	    p_tb_pos_end_date(p_tb_counter) := p_maturity_dates(i);
	    p_tb_start_date(p_tb_counter) := p_start_dates(i);
	    p_tb_end_date(p_tb_counter) := p_maturity_dates(i);
	    p_tb_outst_amount(p_tb_counter) := get_signed_amount(p_face_values(i), p_deal_types(i), p_deal_subtypes(i), null);
	    p_tb_interest_basis(p_tb_counter) := 'F';
	    IF (g_proc_level>=g_debug_level) THEN
	       XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'NI deal no', p_deal_nos(i));
	       XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'NI trans rate', p_transaction_rates(i));
	       XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'NI coupon rate', p_coupon_rates(i));
	    END IF;
 	    p_tb_coupon_rate(p_tb_counter) := p_coupon_rates(i);
	    p_tb_next_coupon_date(p_tb_counter) := TO_DATE(NULL);
	    -- convert outstanding amounts
	    IF (p_deal_ccys(i) = 'USD') THEN
	       p_tb_outst_amount_usd(p_tb_counter) := p_tb_outst_amount(p_tb_counter);
	    ELSE
	       convert_amounts(p_market_data_set_temp(i), p_ref_date,
		p_deal_ccys(i), 'USD', p_tb_outst_amount(p_tb_counter),
		p_tb_outst_amount_usd(p_tb_counter));
	    END IF;
	    IF (p_deal_ccys(i) = p_sob_ccy_temp(i)) THEN
	       p_tb_outst_amount_sob(p_tb_counter) := p_tb_outst_amount(p_tb_counter);
	    ELSE
	       convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_tb_outst_amount(p_tb_counter),
			p_tb_outst_amount_sob(p_tb_counter));
	    END IF;
	    p_tb_amt_qty_out(p_tb_counter) := NULL;
	    p_tb_amt_qty_out_sob(p_tb_counter) :=  NULL;
	    p_tb_amt_qty_out_usd(p_tb_counter) :=  NULL;
	    IF (g_proc_level>=g_debug_level) THEN
	       XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'Past stock tb calculations');
	    END IF;

         ELSIF (p_deal_types(i) IN ('TMM', 'IRS', 'RTMM')) THEN
	    p_maturity_amount_temp(i) := 0;
	    p_gap_amount_temp(i) := 0;
	    -- get current/future transactions
            FOR cursor_rec IN get_tmm_irs_rtmm_trans(p_deal_nos(i),
						     p_ref_date) LOOP
	       p_tb_counter := p_tb_counter + 1;
	       p_tb_deal_no.EXTEND;
	       p_tb_deal_no(p_tb_counter) := p_deal_nos(i);
	       p_tb_transaction_no.EXTEND;
	       p_tb_transaction_no(p_tb_counter) := p_transaction_nos(i);
	       p_tb_market_data_set.EXTEND;
	       p_tb_market_data_set(p_tb_counter) := p_market_data_set_temp(i);
	       p_tb_pos_start_date.EXTEND;
	       IF (p_tb_curr_deal_no <> p_deal_nos(i)) THEN
	          p_tb_pos_start_date(p_tb_counter) := p_deal_dates(i);
		  p_tb_curr_deal_no := p_deal_nos(i);
	       ELSE
	          p_tb_pos_start_date(p_tb_counter) := cursor_rec.start_date;
	       END IF;
	       p_tb_pos_end_date.EXTEND;
	       p_tb_pos_end_date(p_tb_counter) := cursor_rec.maturity_date;
	       p_tb_start_date.EXTEND;
	       p_tb_start_date(p_tb_counter) := cursor_rec.start_date;
	       p_tb_end_date.EXTEND;
	       p_tb_end_date(p_tb_counter) := cursor_rec.maturity_date-1;--bug 2638277
	       p_tb_outst_amount.EXTEND;
	       p_tb_outst_amount_usd.EXTEND;
	       p_tb_outst_amount_sob.EXTEND;
	       p_tb_amt_qty_out.EXTEND;
   	       p_tb_amt_qty_out_usd.EXTEND;
   	       p_tb_amt_qty_out_sob.EXTEND;

	       p_tb_amt_qty_out(p_tb_counter) := NULL;
	       p_tb_amt_qty_out_sob(p_tb_counter) :=  NULL;
	       p_tb_amt_qty_out_usd(p_tb_counter) :=  NULL;
	       -- outstanding amount
	       IF (cursor_rec.principal_action='INCRSE') THEN
	          p_tb_outst_amount(p_tb_counter) :=
			NVL(cursor_rec.balance_out_bf, 0) +
			NVL(cursor_rec.principal_adjust, 0);
	       ELSE
	          p_tb_outst_amount(p_tb_counter) :=
			NVL(cursor_rec.balance_out_bf, 0) -
			NVL(cursor_rec.principal_adjust, 0);
	       END IF;

	       -- get correct signs
	       p_tb_outst_amount(p_tb_counter) := get_signed_amount(p_tb_outst_amount(p_tb_counter), p_deal_types(i), p_deal_subtypes(i), null);

	       -- convert outstanding amounts
	       IF (p_deal_ccys(i) = 'USD') THEN
	          p_tb_outst_amount_usd(p_tb_counter) := p_tb_outst_amount(p_tb_counter);
	       ELSE
	          convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_deal_ccys(i), 'USD', p_tb_outst_amount(p_tb_counter),	 		       p_tb_outst_amount_usd(p_tb_counter));
	       END IF;
	       IF (p_deal_ccys(i) = p_sob_ccy_temp(i)) THEN
	          p_tb_outst_amount_sob(p_tb_counter) := p_tb_outst_amount(p_tb_counter);
	       ELSE
	         convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_tb_outst_amount(p_tb_counter),
			p_tb_outst_amount_sob(p_tb_counter));
	       END IF;

	       -- interest basis
	       -- settle date is fixed until date
	       p_tb_interest_basis.EXTEND;
	       IF (p_initial_bases(i) = 'FLOAT') THEN
		  p_tb_interest_basis(p_tb_counter) := 'L';
	       ELSIF (p_settle_dates(i) IS NULL OR
		      p_settle_dates(i) = p_maturity_dates(i)) THEN
		  p_tb_interest_basis(p_tb_counter) := 'F';
	       -- if start date of transaction >= fixed until date
	       -- then interest basis is floating
	       ELSIF (cursor_rec.start_date >= p_settle_dates(i)) THEN
		  p_tb_interest_basis(p_tb_counter) := 'L';
	       ELSE
		  p_tb_interest_basis(p_tb_counter) := 'F';
	       END IF;

	       p_tb_coupon_rate.EXTEND;
	       p_tb_coupon_rate(p_tb_counter) := cursor_rec.interest_rate;
	       p_tb_next_coupon_date.EXTEND;
	       p_tb_next_coupon_date(p_tb_counter) := cursor_rec.maturity_date;
	    END LOOP;
	    p_tb_end_date(p_tb_counter):=p_tb_end_date(p_tb_counter)+1; --bug 2638277

         ELSIF (p_deal_types(i)='FRA') THEN
	    p_tb_deal_no.EXTEND;
	    p_tb_transaction_no.EXTEND;
	    p_tb_market_data_set.EXTEND;
	    p_tb_pos_start_date.EXTEND;
	    p_tb_pos_end_date.EXTEND;
	    p_tb_start_date.EXTEND;
            p_tb_end_date.EXTEND;
            p_tb_outst_amount.EXTEND;
	    p_tb_outst_amount_usd.EXTEND;
	    p_tb_outst_amount_sob.EXTEND;
	    p_tb_amt_qty_out.EXTEND;
   	    p_tb_amt_qty_out_usd.EXTEND;
   	    p_tb_amt_qty_out_sob.EXTEND;
	    p_tb_interest_basis.EXTEND;
	    p_tb_coupon_rate.EXTEND;
	    p_tb_next_coupon_date.EXTEND;
            p_tb_counter := p_tb_counter + 1;

	    p_tb_amt_qty_out(p_tb_counter) := NULL;
	    p_tb_amt_qty_out_sob(p_tb_counter) :=  NULL;
	    p_tb_amt_qty_out_usd(p_tb_counter) :=  NULL;

	    p_tb_deal_no(p_tb_counter) := p_deal_nos(i);
	    p_tb_transaction_no(p_tb_counter) := p_transaction_nos(i);
	    p_tb_market_data_set(p_tb_counter) := p_market_data_set_temp(i);
	    IF (p_tb_curr_deal_no <> p_deal_nos(i)) THEN
	        p_tb_pos_start_date(p_tb_counter) := p_deal_dates(i);
		p_tb_curr_deal_no := p_deal_nos(i);
	    ELSE
	        p_tb_pos_start_date(p_tb_counter) := p_start_dates(i);
	    END IF;
	    p_tb_pos_end_date(p_tb_counter) := p_maturity_dates(i);
	    p_tb_start_date(p_tb_counter) := p_start_dates(i);
	    p_tb_end_date(p_tb_counter) := p_maturity_dates(i);
	    p_tb_outst_amount(p_tb_counter) := p_face_values(i);
	    IF (p_deal_subtypes(i)='FUND') THEN
	       p_tb_interest_basis(p_tb_counter) := 'F';
	    ELSE
	       p_tb_interest_basis(p_tb_counter) := 'L';
	    END IF;
	    p_tb_coupon_rate(p_tb_counter) := p_transaction_rates(i);
	    p_tb_next_coupon_date(p_tb_counter) := TO_DATE(NULL);
	    -- convert outstanding amounts
	    IF (p_deal_ccys(i) = 'USD') THEN
	       p_tb_outst_amount_usd(p_tb_counter) := p_tb_outst_amount(p_tb_counter);
	    ELSE
	       convert_amounts(p_market_data_set_temp(i), p_ref_date,
		p_deal_ccys(i), 'USD', p_tb_outst_amount(p_tb_counter),
		p_tb_outst_amount_usd(p_tb_counter));
	    END IF;
	    IF (p_deal_ccys(i) = p_sob_ccy_temp(i)) THEN
	       p_tb_outst_amount_sob(p_tb_counter) := p_tb_outst_amount(p_tb_counter);
	    ELSE
	       convert_amounts(p_market_data_set_temp(i), p_ref_date,
		p_deal_ccys(i), p_sob_ccy_temp(i),
		p_tb_outst_amount(p_tb_counter),
		p_tb_outst_amount_sob(p_tb_counter));
	    END IF;

         ELSIF (p_deal_types(i) = 'IRO') THEN
	    p_tb_deal_no.EXTEND;
	    p_tb_transaction_no.EXTEND;
	    p_tb_market_data_set.EXTEND;
	    p_tb_pos_start_date.EXTEND;
	    p_tb_pos_end_date.EXTEND;
	    p_tb_start_date.EXTEND;
            p_tb_end_date.EXTEND;
            p_tb_outst_amount.EXTEND;
	    p_tb_outst_amount_usd.EXTEND;
	    p_tb_outst_amount_sob.EXTEND;
	    p_tb_amt_qty_out.EXTEND;
   	    p_tb_amt_qty_out_usd.EXTEND;
   	    p_tb_amt_qty_out_sob.EXTEND;
	    p_tb_interest_basis.EXTEND;
	    p_tb_coupon_rate.EXTEND;
	    p_tb_next_coupon_date.EXTEND;
            p_tb_counter := p_tb_counter + 1;

	    p_tb_amt_qty_out(p_tb_counter) := NULL;
	    p_tb_amt_qty_out_sob(p_tb_counter) :=  NULL;
	    p_tb_amt_qty_out_usd(p_tb_counter) :=  NULL;

	    p_tb_deal_no(p_tb_counter) := p_deal_nos(i);
	    p_tb_transaction_no(p_tb_counter) := p_transaction_nos(i);
	    p_tb_market_data_set(p_tb_counter) := p_market_data_set_temp(i);
	    IF (p_tb_curr_deal_no <> p_deal_nos(i)) THEN
	        p_tb_pos_start_date(p_tb_counter) := p_deal_dates(i);
		p_tb_curr_deal_no := p_deal_nos(i);
	    ELSE
	        p_tb_pos_start_date(p_tb_counter) := p_start_dates(i);
	    END IF;
	    p_tb_pos_end_date(p_tb_counter) := p_maturity_dates(i);
	    p_tb_start_date(p_tb_counter) := p_start_dates(i);
	    p_tb_end_date(p_tb_counter) := p_maturity_dates(i);
	    p_tb_outst_amount(p_tb_counter) := p_face_values(i);
	    IF (p_deal_subtypes(i) IN ('BCAP', 'SFLOOR')) THEN
	       p_tb_interest_basis(p_tb_counter) := 'F';
	    ELSE
	       p_tb_interest_basis(p_tb_counter) := 'L';
	    END IF;
	    p_tb_coupon_rate(p_tb_counter) := p_transaction_rates(i);
	    p_tb_next_coupon_date(p_tb_counter) := TO_DATE(NULL);
	    -- convert outstanding amounts
	    IF (p_deal_ccys(i) = 'USD') THEN
	       p_tb_outst_amount_usd(p_tb_counter) := p_tb_outst_amount(p_tb_counter);
	    ELSE
	       convert_amounts(p_market_data_set_temp(i), p_ref_date,
		p_deal_ccys(i), 'USD', p_tb_outst_amount(p_tb_counter),
		p_tb_outst_amount_usd(p_tb_counter));
	    END IF;
	    IF (p_deal_ccys(i) = p_sob_ccy_temp(i)) THEN
	       p_tb_outst_amount_sob(p_tb_counter) := p_tb_outst_amount(p_tb_counter);
	    ELSE
	       convert_amounts(p_market_data_set_temp(i), p_ref_date,
		p_deal_ccys(i), p_sob_ccy_temp(i),
		p_tb_outst_amount(p_tb_counter),
		p_tb_outst_amount_sob(p_tb_counter));
	    END IF;

         ELSIF (p_deal_types(i)='BDO') THEN
	    p_tb_deal_no.EXTEND;
	    p_tb_transaction_no.EXTEND;
	    p_tb_market_data_set.EXTEND;
	    p_tb_pos_start_date.EXTEND;
	    p_tb_pos_end_date.EXTEND;
	    p_tb_start_date.EXTEND;
            p_tb_end_date.EXTEND;
            p_tb_outst_amount.EXTEND;
	    p_tb_outst_amount_usd.EXTEND;
	    p_tb_outst_amount_sob.EXTEND;
	    p_tb_amt_qty_out.EXTEND;
   	    p_tb_amt_qty_out_usd.EXTEND;
   	    p_tb_amt_qty_out_sob.EXTEND;
	    p_tb_interest_basis.EXTEND;
	    p_tb_coupon_rate.EXTEND;
	    p_tb_next_coupon_date.EXTEND;
            p_tb_counter := p_tb_counter + 1;

	    p_tb_deal_no(p_tb_counter) := p_deal_nos(i);
	    p_tb_transaction_no(p_tb_counter) := p_transaction_nos(i);
	    p_tb_market_data_set(p_tb_counter) := p_market_data_set_temp(i);
	    IF (p_tb_curr_deal_no <> p_deal_nos(i)) THEN
	        p_tb_pos_start_date(p_tb_counter) := p_deal_dates(i);
		p_tb_curr_deal_no := p_deal_nos(i);
	    ELSE
	        p_tb_pos_start_date(p_tb_counter) := p_start_dates(i);
	    END IF;
	    p_tb_pos_end_date(p_tb_counter) := p_maturity_dates(i);
	    p_tb_start_date(p_tb_counter) := p_start_dates(i);
	    p_tb_end_date(p_tb_counter) := p_maturity_dates(i);
	    p_tb_outst_amount(p_tb_counter) := p_face_values(i)*p_transaction_rates(i)/100;
	    p_tb_interest_basis(p_tb_counter) := 'F';
	    p_tb_coupon_rate(p_tb_counter) := p_coupon_rates(i);
	    p_tb_next_coupon_date(p_tb_counter) := p_next_coupon_dates(i);
	    -- convert outstanding amounts
	    IF (p_deal_ccys(i) = 'USD') THEN
	       p_tb_outst_amount_usd(p_tb_counter) := p_tb_outst_amount(p_tb_counter);
	    ELSE
	       convert_amounts(p_market_data_set_temp(i), p_ref_date,
		p_deal_ccys(i), 'USD', p_tb_outst_amount(p_tb_counter),
		p_tb_outst_amount_usd(p_tb_counter));
	    END IF;
	    IF (p_deal_ccys(i) = p_sob_ccy_temp(i)) THEN
	       p_tb_outst_amount_sob(p_tb_counter) := p_tb_outst_amount(p_tb_counter);
	    ELSE
	       convert_amounts(p_market_data_set_temp(i), p_ref_date,
		p_deal_ccys(i), p_sob_ccy_temp(i),
		p_tb_outst_amount(p_tb_counter),
		p_tb_outst_amount_sob(p_tb_counter));
	    END IF;
	    p_tb_amt_qty_out(p_tb_counter) := p_tb_outst_amount(p_tb_counter);
	    p_tb_amt_qty_out_sob(p_tb_counter) := p_tb_outst_amount_sob(p_tb_counter);
	    p_tb_amt_qty_out_usd(p_tb_counter) := p_tb_outst_amount_usd(p_tb_counter);
         ELSIF (p_deal_types(i)='SWPTN') THEN
	    p_tb_deal_no.EXTEND;
	    p_tb_transaction_no.EXTEND;
	    p_tb_market_data_set.EXTEND;
	    p_tb_pos_start_date.EXTEND;
	    p_tb_pos_end_date.EXTEND;
	    p_tb_start_date.EXTEND;
            p_tb_end_date.EXTEND;
            p_tb_outst_amount.EXTEND;
	    p_tb_outst_amount_usd.EXTEND;
	    p_tb_outst_amount_sob.EXTEND;
	    p_tb_amt_qty_out.EXTEND;
   	    p_tb_amt_qty_out_usd.EXTEND;
   	    p_tb_amt_qty_out_sob.EXTEND;
	    p_tb_interest_basis.EXTEND;
	    p_tb_coupon_rate.EXTEND;
	    p_tb_next_coupon_date.EXTEND;
            p_tb_counter := p_tb_counter + 1;

	    p_tb_amt_qty_out(p_tb_counter) := NULL;
	    p_tb_amt_qty_out_sob(p_tb_counter) :=  NULL;
	    p_tb_amt_qty_out_usd(p_tb_counter) :=  NULL;

	    p_tb_deal_no(p_tb_counter) := p_deal_nos(i);
	    p_tb_transaction_no(p_tb_counter) := p_transaction_nos(i);
	    p_tb_market_data_set(p_tb_counter) := p_market_data_set_temp(i);
	    IF (p_tb_curr_deal_no <> p_deal_nos(i)) THEN
	        p_tb_pos_start_date(p_tb_counter) := p_deal_dates(i);
		p_tb_curr_deal_no := p_deal_nos(i);
	    ELSE
	        p_tb_pos_start_date(p_tb_counter) := p_start_dates(i);
	    END IF;
	    p_tb_pos_end_date(p_tb_counter) := p_maturity_dates(i);
	    p_tb_start_date(p_tb_counter) := p_start_dates(i);
	    p_tb_end_date(p_tb_counter) := p_maturity_dates(i);
	    p_tb_outst_amount(p_tb_counter) := p_face_values(i);
	    IF ((p_deal_subtypes(i)='BUY' and p_coupon_actions(i)='PAY') OR
	     (p_deal_subtypes(i)='SELL' and p_coupon_actions(i)='REC')) THEN
	       p_tb_interest_basis(p_tb_counter) := 'F';
	    ELSE
	       p_tb_interest_basis(p_tb_counter) := 'L';
	    END IF;
	    p_tb_coupon_rate(p_tb_counter) := p_transaction_rates(i);
	    -- coupon freq is no of coupons per year, so need to convert
	    -- to months to calculate next coupon date
	    p_tb_next_coupon_date(p_tb_counter) := ADD_MONTHS(p_start_dates(i),
							12/p_coupon_freqs(i));
	    -- convert outstanding amounts
	    IF (p_deal_ccys(i) = 'USD') THEN
	       p_tb_outst_amount_usd(p_tb_counter) := p_tb_outst_amount(p_tb_counter);
	    ELSE
	       convert_amounts(p_market_data_set_temp(i), p_ref_date,
		p_deal_ccys(i), 'USD', p_tb_outst_amount(p_tb_counter),
		p_tb_outst_amount_usd(p_tb_counter));
	    END IF;
	    IF (p_deal_ccys(i) = p_sob_ccy_temp(i)) THEN
	       p_tb_outst_amount_sob(p_tb_counter) := p_tb_outst_amount(p_tb_counter);
	    ELSE
	       convert_amounts(p_market_data_set_temp(i), p_ref_date,
		p_deal_ccys(i), p_sob_ccy_temp(i),
		p_tb_outst_amount(p_tb_counter),
		p_tb_outst_amount_sob(p_tb_counter));
	    END IF;

         ELSIF (p_deal_types(i)='ONC') THEN
	    p_tb_deal_no.EXTEND;
	    p_tb_transaction_no.EXTEND;
	    p_tb_market_data_set.EXTEND;
	    p_tb_pos_start_date.EXTEND;
	    p_tb_pos_end_date.EXTEND;
	    p_tb_start_date.EXTEND;
            p_tb_end_date.EXTEND;
            p_tb_outst_amount.EXTEND;
	    p_tb_outst_amount_usd.EXTEND;
	    p_tb_outst_amount_sob.EXTEND;
	    p_tb_amt_qty_out.EXTEND;
   	    p_tb_amt_qty_out_usd.EXTEND;
   	    p_tb_amt_qty_out_sob.EXTEND;
	    p_tb_interest_basis.EXTEND;
	    p_tb_coupon_rate.EXTEND;
	    p_tb_next_coupon_date.EXTEND;
            p_tb_counter := p_tb_counter + 1;

	    p_tb_amt_qty_out(p_tb_counter) := NULL;
	    p_tb_amt_qty_out_sob(p_tb_counter) :=  NULL;
	    p_tb_amt_qty_out_usd(p_tb_counter) :=  NULL;

	    p_tb_deal_no(p_tb_counter) := p_deal_nos(i);
	    p_tb_transaction_no(p_tb_counter) := p_transaction_nos(i);
	    p_tb_market_data_set(p_tb_counter) := p_market_data_set_temp(i);
	    IF (p_tb_curr_deal_no <> p_deal_nos(i)) THEN
	        p_tb_pos_start_date(p_tb_counter) := p_deal_dates(i);
		p_tb_curr_deal_no := p_deal_nos(i);
	    ELSE
	        p_tb_pos_start_date(p_tb_counter) := p_start_dates(i);
	    END IF;
	    -- leave end date null for position analysis
	    p_tb_pos_end_date(p_tb_counter) := p_end_dates(i);
	    p_tb_start_date(p_tb_counter) := p_start_dates(i);
            --BUG 2637950
            IF (p_start_dates(i)>p_ref_date) THEN
	      p_tb_end_date(p_tb_counter) := NVL(p_end_dates(i), p_start_dates(i)+1);
            ELSE
              p_tb_end_date(p_tb_counter) := NVL(p_end_dates(i), p_ref_date+1);
            END IF;
	    --principal adjust
	    p_tb_outst_amount(p_tb_counter) := get_signed_amount(p_start_amounts(i), p_deal_types(i), p_deal_subtypes(i), null);
	    p_tb_interest_basis(p_tb_counter) := 'F';
	    p_tb_coupon_rate(p_tb_counter) := p_coupon_rates(i);
	    p_tb_next_coupon_date(p_tb_counter) := TO_DATE(NULL);
	    -- convert outstanding amounts
	    IF (p_deal_ccys(i) = 'USD') THEN
	       p_tb_outst_amount_usd(p_tb_counter) := p_tb_outst_amount(p_tb_counter);
	    ELSE
	       convert_amounts(p_market_data_set_temp(i), p_ref_date,
		p_deal_ccys(i), 'USD', p_tb_outst_amount(p_tb_counter),
		p_tb_outst_amount_usd(p_tb_counter));
	    END IF;
	    IF (p_deal_ccys(i) = p_sob_ccy_temp(i)) THEN
	       p_tb_outst_amount_sob(p_tb_counter) := p_tb_outst_amount(p_tb_counter);
	    ELSE
	       convert_amounts(p_market_data_set_temp(i), p_ref_date,
		p_deal_ccys(i), p_sob_ccy_temp(i),
		p_tb_outst_amount(p_tb_counter),
		p_tb_outst_amount_sob(p_tb_counter));
	    END IF;

         ELSIF (p_deal_types(i)='IG') THEN
	    p_tb_deal_no.EXTEND;
	    p_tb_transaction_no.EXTEND;
	    p_tb_market_data_set.EXTEND;
	    p_tb_pos_start_date.EXTEND;
	    p_tb_pos_end_date.EXTEND;
	    p_tb_start_date.EXTEND;
            p_tb_end_date.EXTEND;
            p_tb_outst_amount.EXTEND;
	    p_tb_outst_amount_usd.EXTEND;
	    p_tb_outst_amount_sob.EXTEND;
	    p_tb_amt_qty_out.EXTEND;
   	    p_tb_amt_qty_out_usd.EXTEND;
   	    p_tb_amt_qty_out_sob.EXTEND;
	    p_tb_interest_basis.EXTEND;
	    p_tb_coupon_rate.EXTEND;
	    p_tb_next_coupon_date.EXTEND;
            p_tb_counter := p_tb_counter + 1;

	    p_tb_amt_qty_out(p_tb_counter) := NULL;
	    p_tb_amt_qty_out_sob(p_tb_counter) :=  NULL;
	    p_tb_amt_qty_out_usd(p_tb_counter) :=  NULL;

	    IF (g_proc_level>=g_debug_level) THEN
	       XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'IG 1');
	    END IF;
	    p_tb_deal_no(p_tb_counter) := p_deal_nos(i);
	    p_tb_transaction_no(p_tb_counter) := p_transaction_nos(i);
	    p_tb_market_data_set(p_tb_counter) := p_market_data_set_temp(i);
	    IF (p_tb_curr_deal_no <> p_deal_nos(i)) THEN
	        p_tb_pos_start_date(p_tb_counter) := p_deal_dates(i);
		p_tb_curr_deal_no := p_deal_nos(i);
	    ELSE
	        p_tb_pos_start_date(p_tb_counter) := p_start_dates(i);
	    END IF;
	    p_tb_pos_end_date(p_tb_counter) := p_end_dates(i);
	    p_tb_start_date(p_tb_counter) := p_start_dates(i);
	    p_tb_end_date(p_tb_counter) := NVL(p_end_dates(i), p_ref_date+1);
	    p_tb_outst_amount(p_tb_counter) := p_face_values(i); -- balance
	    p_tb_interest_basis(p_tb_counter) := 'F';
	    p_tb_coupon_rate(p_tb_counter) := p_coupon_rates(i);
	    p_tb_next_coupon_date(p_tb_counter) := TO_DATE(NULL);
	    IF (g_proc_level>=g_debug_level) THEN
	       XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'IG 2');
	    END IF;
	    -- convert outstanding amounts
	    IF (p_deal_ccys(i) = 'USD') THEN
	       p_tb_outst_amount_usd(p_tb_counter) := p_tb_outst_amount(p_tb_counter);
	    ELSE
	       convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_deal_ccys(i),'USD', p_tb_outst_amount(p_tb_counter),
 			p_tb_outst_amount_usd(p_tb_counter));
	    END IF;
	    IF (g_proc_level>=g_debug_level) THEN
	       XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'IG 3');
	    END IF;
	    IF (p_deal_ccys(i) = p_sob_ccy_temp(i)) THEN
	       p_tb_outst_amount_sob(p_tb_counter) := p_tb_outst_amount(p_tb_counter);
	    ELSE
	       convert_amounts(p_market_data_set_temp(i), p_ref_date,
			p_deal_ccys(i), p_sob_ccy_temp(i),
			p_tb_outst_amount(p_tb_counter),
			p_tb_outst_amount_sob(p_tb_counter));
	    END IF;
          END IF;

	ELSE -- 'FX' or 'FXO'
	    p_tb_deal_no.EXTEND;
	    p_tb_transaction_no.EXTEND;
	    p_tb_market_data_set.EXTEND;
	    p_tb_pos_start_date.EXTEND;
	    p_tb_pos_end_date.EXTEND;
	    p_tb_start_date.EXTEND;
            p_tb_end_date.EXTEND;
            p_tb_outst_amount.EXTEND;
	    p_tb_outst_amount_usd.EXTEND;
	    p_tb_outst_amount_sob.EXTEND;
	    p_tb_amt_qty_out.EXTEND;
   	    p_tb_amt_qty_out_usd.EXTEND;
   	    p_tb_amt_qty_out_sob.EXTEND;
	    p_tb_interest_basis.EXTEND;
	    p_tb_coupon_rate.EXTEND;
	    p_tb_next_coupon_date.EXTEND;
            p_tb_counter := p_tb_counter + 1;

	    p_tb_amt_qty_out(p_tb_counter) := NULL;
	    p_tb_amt_qty_out_sob(p_tb_counter) :=  NULL;
	    p_tb_amt_qty_out_usd(p_tb_counter) :=  NULL;

	    p_tb_deal_no(p_tb_counter) := p_deal_nos(i);
	    p_tb_transaction_no(p_tb_counter) := p_transaction_nos(i);
	    p_tb_market_data_set(p_tb_counter) := p_market_data_set_temp(i);
	    -- start dates are null for FX/FXO
	    -- so always map start date to deal date
	    p_tb_pos_start_date(p_tb_counter) := NVL(p_start_dates(i),
						 p_deal_dates(i));
	    p_tb_start_date(p_tb_counter) := NVL(p_start_dates(i),
						 p_deal_dates(i));
	    p_tb_pos_end_date(p_tb_counter) := p_end_dates(i);
	    p_tb_end_date(p_tb_counter) := p_end_dates(i);
	    p_tb_outst_amount(p_tb_counter) := NULL;
	    p_tb_outst_amount_usd(p_tb_counter) := NULL;
	    p_tb_outst_amount_sob(p_tb_counter) := NULL;
	    p_tb_interest_basis(p_tb_counter) := NULL;
	    p_tb_coupon_rate(p_tb_counter) := NULL;
	    p_tb_next_coupon_date(p_tb_counter) := NULL;

        END IF; -- end of tb calculations

        -- bug 2875633
        if (p_tb_counter>1) then
          if ((p_tb_end_date(p_tb_counter) = p_tb_end_date(p_tb_counter-1)) and
              (p_tb_start_date(p_tb_counter) = p_tb_start_date(p_tb_counter-1)) and
              (p_tb_market_data_set(p_tb_counter) = p_tb_market_data_set(p_tb_counter-1)) and
              (p_tb_transaction_no(p_tb_counter) = p_tb_transaction_no(p_tb_counter-1)) and
              (p_tb_deal_no(p_tb_counter) = p_tb_deal_no(p_tb_counter-1))) then
              if (nvl(p_tb_outst_amount(p_tb_counter-1),0)=0 and nvl(p_tb_outst_amount(p_tb_counter),0)<>0) then
                p_tb_deal_no(p_tb_counter-1) := p_tb_deal_no(p_tb_counter);
                p_tb_transaction_no(p_tb_counter-1) := p_tb_transaction_no(p_tb_counter);
                p_tb_market_data_set(p_tb_counter-1) := p_tb_market_data_set(p_tb_counter);
                p_tb_pos_start_date(p_tb_counter-1) := p_tb_pos_start_date(p_tb_counter);
                p_tb_pos_end_date(p_tb_counter-1) := p_tb_pos_end_date(p_tb_counter);
                p_tb_start_date(p_tb_counter-1) := p_tb_start_date(p_tb_counter);
                p_tb_end_date(p_tb_counter-1) := p_tb_end_date(p_tb_counter);
                p_tb_outst_amount(p_tb_counter-1) := p_tb_outst_amount(p_tb_counter);
                p_tb_outst_amount_usd(p_tb_counter-1) := p_tb_outst_amount_usd(p_tb_counter);
                p_tb_outst_amount_sob(p_tb_counter-1) := p_tb_outst_amount_sob(p_tb_counter);
                p_tb_amt_qty_out(p_tb_counter-1) := p_tb_amt_qty_out(p_tb_counter);
                p_tb_amt_qty_out_usd(p_tb_counter-1) := p_tb_amt_qty_out_usd(p_tb_counter);
                p_tb_amt_qty_out_sob(p_tb_counter-1) := p_tb_amt_qty_out_sob(p_tb_counter);
                p_tb_interest_basis(p_tb_counter-1) := p_tb_interest_basis(p_tb_counter);
                p_tb_coupon_rate(p_tb_counter-1) := p_tb_coupon_rate(p_tb_counter);
                p_tb_next_coupon_date(p_tb_counter-1) := p_tb_next_coupon_date(p_tb_counter);
              end if;
              p_tb_counter:=p_tb_counter-1;
              raise e_duplicate_tb_rows;
          end if;
        end if;

	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'end of tb calculations');
	END IF;
      END IF; -- end deal ok : passed gap date test


      EXCEPTION
	WHEN XTR_MARKET_DATA_P.e_mdcs_no_curve_found THEN
	   retcode := '1';  -- success with warnings
	   p_except_counter := p_except_counter + 1;
	   p_except_deal_no.EXTEND;
	   p_except_transaction_no.EXTEND;
	   p_except_market_data_set.EXTEND;
	   p_except_error_type.EXTEND;
	   p_except_error_code.EXTEND;
	   p_except_token_name.EXTEND;
	   p_except_token_value.EXTEND;
	   p_except_deal_no(p_except_counter):=p_deal_nos(i);
	   p_except_transaction_no(p_except_counter):=p_transaction_nos(i);
	   p_except_market_data_set(p_except_counter):=p_market_data_set_temp(i);
	   p_except_error_type(p_except_counter) := 'W';
	   p_except_error_code(p_except_counter):='QRM_ANA_NO_CURVE_FOUND';
           --bug 3236479
	   IF (g_proc_level>=g_ERROR_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('EXCEPTION','QRM_ANA_NO_CURVE_FOUND',
	         'QRM_PA_CALCULATIONS_P.RUN_ANALYSIS',
		 g_error_level);
	   END IF;
	WHEN XTR_MARKET_DATA_P.e_mdcs_no_data_found THEN
	   retcode := '1';  -- success with warnings
	   p_except_counter := p_except_counter + 1;
	   p_except_deal_no.EXTEND;
	   p_except_transaction_no.EXTEND;
	   p_except_market_data_set.EXTEND;
	   p_except_error_type.EXTEND;
	   p_except_error_code.EXTEND;
	   p_except_token_name.EXTEND;
	   p_except_token_value.EXTEND;
	   p_except_deal_no(p_except_counter):=p_deal_nos(i);
	   p_except_transaction_no(p_except_counter):=p_transaction_nos(i);
	   p_except_market_data_set(p_except_counter):=p_market_data_set_temp(i);
	   p_except_error_type(p_except_counter):='W';
	   p_except_error_code(p_except_counter):='QRM_ANA_NO_DATA_FOUND';
	   --bug 3236479
	   IF (g_proc_level>=g_ERROR_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('EXCEPTION','QRM_ANA_NO_DATA_FOUND',
	         'QRM_PA_CALCULATIONS_P.RUN_ANALYSIS',
		 g_error_level);
	   END IF;
	WHEN QRM_MM_FORMULAS.e_option_vol_zero THEN
	   retcode := '1';  -- success with warnings
	   p_except_counter := p_except_counter + 1;
	   p_except_deal_no.EXTEND;
	   p_except_transaction_no.EXTEND;
	   p_except_market_data_set.EXTEND;
	   p_except_error_type.EXTEND;
	   p_except_error_code.EXTEND;
	   p_except_token_name.EXTEND;
	   p_except_token_value.EXTEND;
	   p_except_deal_no(p_except_counter):=p_deal_nos(i);
	   p_except_transaction_no(p_except_counter):=p_transaction_nos(i);
	   p_except_market_data_set(p_except_counter):=p_market_data_set_temp(i);
	   p_except_error_type(p_except_counter):='W';
	   p_except_error_code(p_except_counter):='QRM_ANA_OPTION_VOL_ZERO';
	   --bug 3236479
	   IF (g_proc_level>=g_ERROR_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('EXCEPTION','QRM_ANA_OPTION_VOL_ZERO',
	         'QRM_PA_CALCULATIONS_P.RUN_ANALYSIS',
		 g_error_level);
	   END IF;
	WHEN no_data_found THEN -- market data set api returned no rows
	   retcode := '1';  -- success with warnings
	   p_except_counter := p_except_counter + 1;
	   p_except_deal_no.EXTEND;
	   p_except_transaction_no.EXTEND;
	   p_except_market_data_set.EXTEND;
	   p_except_error_type.EXTEND;
	   p_except_error_code.EXTEND;
	   p_except_token_name.EXTEND;
	   p_except_token_value.EXTEND;
	   p_except_deal_no(p_except_counter):=p_deal_nos(i);
	   p_except_transaction_no(p_except_counter):=p_transaction_nos(i);
	   p_except_market_data_set(p_except_counter):=p_market_data_set_temp(i);
	   p_except_error_type(p_except_counter):='W';
	   p_except_error_code(p_except_counter):='QRM_ANA_NO_DATA_FOUND';
           --bug 3236479
	   IF (g_proc_level>=g_ERROR_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('EXCEPTION','QRM_ANA_NO_DATA_FOUND',
	         'QRM_PA_CALCULATIONS_P.RUN_ANALYSIS',
		 g_error_level);
	   END IF;
           --bug 2560111
        WHEN e_invalid_date THEN -- invalid date on deal
           retcode := '1';  -- success with warnings
           p_except_counter := p_except_counter + 1;
           p_except_deal_no.EXTEND;
           p_except_transaction_no.EXTEND;
           p_except_market_data_set.EXTEND;
           p_except_error_type.EXTEND;
           p_except_error_code.EXTEND;
           p_except_token_name.EXTEND;
           p_except_token_value.EXTEND;
           p_except_deal_no(p_except_counter):=p_deal_nos(i);
           p_except_transaction_no(p_except_counter):=p_transaction_nos(i);
           p_except_market_data_set(p_except_counter):=p_market_data_set_temp(i);
           p_except_error_type(p_except_counter):='W';
           p_except_error_code(p_except_counter):='QRM_ANA_DATE_RANGE_ERR';
	   --bug 3236479
	   IF (g_proc_level>=g_ERROR_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('EXCEPTION','QRM_ANA_DATE_RANGE_ERR',
	         'QRM_PA_CALCULATIONS_P.RUN_ANALYSIS',
		 g_error_level);
	   END IF;
           --bug 2558279
        WHEN ZERO_DIVIDE THEN -- invalid deal information
           retcode := '1';  -- success with warnings
           p_except_counter := p_except_counter + 1;
           p_except_deal_no.EXTEND;
           p_except_transaction_no.EXTEND;
           p_except_market_data_set.EXTEND;
           p_except_error_type.EXTEND;
           p_except_error_code.EXTEND;
           p_except_token_name.EXTEND;
           p_except_token_value.EXTEND;
           p_except_deal_no(p_except_counter):=p_deal_nos(i);
           p_except_transaction_no(p_except_counter):=p_transaction_nos(i);
           p_except_market_data_set(p_except_counter):=p_market_data_set_temp(i);
           p_except_error_type(p_except_counter):='W';
           p_except_error_code(p_except_counter):='QRM_DIV_BY_ZERO_ERR';
	   --bug 3236479
	   IF (g_proc_level>=g_ERROR_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('EXCEPTION','QRM_DIV_BY_ZERO_ERR',
	         'QRM_PA_CALCULATIONS_P.RUN_ANALYSIS',
		 g_error_level);
	   END IF;
           --bug 2875633
        WHEN e_duplicate_tb_rows THEN -- invalid deal information
           IF xtr_risk_debug_pkg.g_Debug THEN
              XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'duplicate tb rows');
           END IF;
           retcode := '1';  -- success with warnings
           p_except_counter := p_except_counter + 1;
           p_except_deal_no.EXTEND;
           p_except_transaction_no.EXTEND;
           p_except_market_data_set.EXTEND;
           p_except_error_type.EXTEND;
           p_except_error_code.EXTEND;
           p_except_token_name.EXTEND;
           p_except_token_value.EXTEND;
           p_except_deal_no(p_except_counter):=p_deal_nos(i);
           p_except_transaction_no(p_except_counter):=p_transaction_nos(i);
           p_except_market_data_set(p_except_counter):=p_market_data_set_temp(i);
           p_except_error_type(p_except_counter):='W';
           p_except_error_code(p_except_counter):='QRM_ANA_UNEXPECTED_ERROR';
        -- bug 2602235, deal level errors
	WHEN OTHERS THEN
           retcode := '1';  -- success with warnings
           p_except_counter := p_except_counter + 1;
           p_except_deal_no.EXTEND;
           p_except_transaction_no.EXTEND;
           p_except_market_data_set.EXTEND;
           p_except_error_type.EXTEND;
           p_except_error_code.EXTEND;
           p_except_token_name.EXTEND;
           p_except_token_value.EXTEND;
           p_except_deal_no(p_except_counter):=p_deal_nos(i);
           p_except_transaction_no(p_except_counter):=p_transaction_nos(i);
           p_except_market_data_set(p_except_counter):=p_market_data_set_temp(i);
           p_except_error_type(p_except_counter):='W';
	   p_except_error_code(p_except_counter):='QRM_ANA_UNEXPECTED_ERROR';
	   --bug 3236479
	   IF (g_proc_level>=g_ERROR_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('EXCEPTION','QRM_ANA_UNEXPECTED_ERROR inner loop',
	         'QRM_PA_CALCULATIONS_P.RUN_ANALYSIS',
		 g_error_level);
	   END IF;
/* commented out  for bug 2602235
	WHEN OTHERS THEN
	   IF (g_proc_level>=g_debug_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'unhandled exp at deal level');
	   END IF;
	   -- unhandled exception, clear previous warnings
	   p_except_counter := 0;
	   p_except_deal_no.DELETE;
	   p_except_transaction_no.DELETE;
	   p_except_market_data_set.DELETE;
	   p_except_error_type.DELETE;
	   p_except_error_code.DELETE;
	   p_except_token_name.DELETE;
	   p_except_token_value.DELETE;
	   retcode := '2';  -- unhandled exception occurred, program fail
	   p_except_counter := p_except_counter + 1;
	   p_except_deal_no.EXTEND;
	   p_except_transaction_no.EXTEND;
	   p_except_market_data_set.EXTEND;
	   p_except_error_type.EXTEND;
	   p_except_error_code.EXTEND;
	   p_except_token_name.EXTEND;
	   p_except_token_value.EXTEND;
	   p_except_deal_no(p_except_counter):=p_deal_nos(i);
	   p_except_transaction_no(p_except_counter):=p_transaction_nos(i);
	   p_except_market_data_set(p_except_counter):=p_market_data_set_temp(i);
	   p_except_error_type(p_except_counter):='E';
	   p_except_error_code(p_except_counter):='QRM_ANA_UNEXPECTED_ERROR';

	   exit;  -- exit loop
*/
      END;
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'about to restart loop');
	END IF;
   END LOOP;


   -- hit db iff no unhandled exceptions
   IF (retcode <> '2') THEN
      -- perform database DML
      --- INSERT into QRM_DEAL_CALCULATIONS
      IF (g_state_level>=g_debug_level) THEN  --bug 3236479
         --XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'about to insert');
         for j in 1..p_insert_counter loop
 	  v_log := p_seq_nos(j)||';'||
	   p_deal_no_insert(j)||';'|| p_transaction_no_insert(j)||';'||
	   p_market_data_set_insert(j)||';'|| p_deal_ccy_insert(j)||';'||
	   p_sob_ccy_insert(j)||';'|| p_base_ccy_amount_usd_insert(j)||';'||
	   p_base_ccy_amount_sob_insert(j)||';'|| p_contra_ccy_amount_usd_insert(j)||';'||
 	   p_contra_ccy_amount_sob_insert(j)||';'|| p_foreign_amount_usd_insert(j)||';'||
	   p_foreign_amount_sob_insert(j)||';'|| p_domestic_amount_usd_insert(j)||';'||
	   p_domestic_amount_sob_insert(j)||';'|| p_buy_amount_usd_insert(j)||';'||
	   p_buy_amount_sob_insert(j)||';'|| p_sell_amount_usd_insert(j)||';'||
	   p_sell_amount_sob_insert(j)||';'|| p_days_insert(j);
          XTR_RISK_DEBUG_PKG.dlog('INSERT QRM_DEAL_CALCULATIONS Line 1',v_log,
            'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_state_level);
	  v_log := p_fx_reval_rate_insert(j)||';'||p_mm_reval_rate_insert(j)||';'||
	   p_fx_trans_rate_insert(j)||';'|| p_mm_trans_rate_insert(j)||';'||
	   p_fair_value_insert(j)||';'|| p_fair_value_usd_insert(j)||';'||
	   p_fair_value_sob_insert(j)||';'|| p_gap_amount_insert(j)||';'||
	   p_gap_amount_usd_insert(j)||';'|| p_gap_amount_sob_insert(j)||';'||
	   p_maturity_amount_insert(j)||';'|| p_maturity_amount_usd_insert(j)||';'||
	   p_maturity_amount_sob_insert(j)||';'|| p_premium_amount_usd_insert(j)||';'||
	   p_premium_amount_sob_insert(j)||';'|| p_accrued_interest_insert(j)||';'||
	   p_accrued_interest_usd_insert(j)||';'|| p_accrued_interest_sob_insert(j);
          XTR_RISK_DEBUG_PKG.dlog('INSERT QRM_DEAL_CALCULATIONS Line 2',v_log,
            'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_state_level);
	  v_log := p_duration_insert(j)||';'|| p_mod_duration_insert(j)||';'||
	   p_convexity_insert(j)||';'|| p_delta_insert(j)||';'|| p_gamma_insert(j)||';'||
	   p_theta_insert(j)||';'|| p_rho_insert(j)||';'|| p_rho_base_insert(j)||';'||
	   p_rho_contra_insert(j)||';'|| p_rho_for_insert(j)||';'|| p_rho_dom_insert(j)||';'||
	   p_vega_insert(j)||';'|| p_pos_bpv_insert(j)||';'|| p_pos_bpv_usd_insert(j)||';'||
	   p_pos_bpv_sob_insert(j)||';'|| p_pos_delta_insert(j)||';'||
	   p_pos_delta_usd_insert(j)||';'|| p_pos_delta_sob_insert(j)||';'||
	   p_pos_gamma_insert(j)||';'|| p_pos_gamma_usd_insert(j)||';'||
	   p_pos_gamma_sob_insert(j)||';'|| p_pos_theta_insert(j)||';'||
	   p_pos_theta_usd_insert(j)||';'|| p_pos_theta_sob_insert(j)||';'||
	   p_pos_rho_insert(j)||';'|| p_pos_rho_usd_insert(j)||';'||
	   p_pos_rho_sob_insert(j)||';'|| p_pos_rho_base_insert(j)||';'||
	   p_pos_rho_base_usd_insert(j)||';'|| p_pos_rho_base_sob_insert(j)||';'||
	   p_pos_rho_contra_insert(j)||';'|| p_pos_rho_contra_usd_insert(j);
          XTR_RISK_DEBUG_PKG.dlog('INSERT QRM_DEAL_CALCULATIONS Line 3',v_log,
            'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_state_level);
	  v_log := p_pos_rho_contra_sob_insert(j)||';'|| p_pos_rho_for_insert(j)||';'||
	   p_pos_rho_for_usd_insert(j)||';'|| p_pos_rho_for_sob_insert(j)||';'||
	   p_pos_rho_dom_insert(j)||';'|| p_pos_rho_dom_usd_insert(j)||';'||
	   p_pos_rho_dom_sob_insert(j)||';'|| p_pos_vega_insert(j)||';'||
	   p_pos_vega_usd_insert(j)||';'|| p_pos_vega_sob_insert(j)||';'||
	   p_volatility_insert(j)||';'|| p_ytm_insert(j)||';'||
	   p_gap_date_insert(j)||';'|| p_reval_price_insert(j)||';'||
	   p_reval_price_usd_insert(j)||';'|| p_reval_price_sob_insert(j)||';'||
	   p_trans_price_insert(j)||';'|| p_trans_price_usd_insert(j)||';'||
	   p_trans_price_sob_insert(j)||';'|| p_ref_datetime;
          XTR_RISK_DEBUG_PKG.dlog('INSERT QRM_DEAL_CALCULATIONS Line 4',v_log,
            'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_state_level);
         end loop;
      END IF;

      FORALL j IN 1..p_insert_counter
        INSERT INTO qrm_deal_calculations (deal_calc_id, deal_no,
	   transaction_no, market_data_set, deal_ccy, sob_ccy,
	   base_ccy_amount_usd, base_ccy_amount_sob, contra_ccy_amount_usd,
	   contra_ccy_amount_sob, foreign_amount_usd, foreign_amount_sob,
	   domestic_amount_usd, domestic_amount_sob, buy_amount_usd,
	   buy_amount_sob, sell_amount_usd, sell_amount_sob, days,
	   fx_reval_rate, mm_reval_rate, fx_trans_rate, mm_trans_rate,
	   fair_value, fair_value_usd, fair_value_sob, gap_amount,
	   gap_amount_usd, gap_amount_sob, maturity_amount,
	   maturity_amount_usd, maturity_amount_sob, premium_amount_usd,
	   premium_amount_sob, accrued_interest, accrued_interest_usd,
	   accrued_interest_sob, duration, modified_duration,
	   convexity, delta, gamma, theta, rho, rho_base, rho_contra,
	   rho_foreign, rho_domestic, vega, pos_bpv, pos_bpv_usd,
	   pos_bpv_sob, pos_delta, pos_delta_usd, pos_delta_sob,
	   pos_gamma, pos_gamma_usd, pos_gamma_sob,
	   pos_theta, pos_theta_usd, pos_theta_sob, pos_rho,
	   pos_rho_usd, pos_rho_sob, pos_rho_base, pos_rho_base_usd,
	   pos_rho_base_sob, pos_rho_contra, pos_rho_contra_usd,
	   pos_rho_contra_sob, pos_rho_foreign, pos_rho_foreign_usd,
	   pos_rho_foreign_sob, pos_rho_domestic, pos_rho_domestic_usd,
	   pos_rho_domestic_sob, pos_vega, pos_vega_usd, pos_vega_sob,
	   volatility, yield_to_maturity, gap_date, revaluation_price,
	   revaluation_price_usd, revaluation_price_sob,
	   transaction_price, transaction_price_usd,
	   transaction_price_sob, last_md_calc_date,
	   created_by, creation_date, last_updated_by,
	   last_update_date, last_update_login, request_id,
	   program_application_id, program_id, program_update_date)
	VALUES(p_seq_nos(j),-- stored earlier
	   p_deal_no_insert(j), p_transaction_no_insert(j),
	   p_market_data_set_insert(j), p_deal_ccy_insert(j),
	   p_sob_ccy_insert(j), p_base_ccy_amount_usd_insert(j),
	   p_base_ccy_amount_sob_insert(j), p_contra_ccy_amount_usd_insert(j),
 	   p_contra_ccy_amount_sob_insert(j), p_foreign_amount_usd_insert(j),
	   p_foreign_amount_sob_insert(j), p_domestic_amount_usd_insert(j),
	   p_domestic_amount_sob_insert(j), p_buy_amount_usd_insert(j),
	   p_buy_amount_sob_insert(j), p_sell_amount_usd_insert(j),
	   p_sell_amount_sob_insert(j), p_days_insert(j),
	   p_fx_reval_rate_insert(j),p_mm_reval_rate_insert(j),
	   p_fx_trans_rate_insert(j), p_mm_trans_rate_insert(j),
	   p_fair_value_insert(j), p_fair_value_usd_insert(j),
	   p_fair_value_sob_insert(j), p_gap_amount_insert(j),
	   p_gap_amount_usd_insert(j), p_gap_amount_sob_insert(j),
	   p_maturity_amount_insert(j), p_maturity_amount_usd_insert(j),
	   p_maturity_amount_sob_insert(j), p_premium_amount_usd_insert(j),
	   p_premium_amount_sob_insert(j), p_accrued_interest_insert(j),
	   p_accrued_interest_usd_insert(j), p_accrued_interest_sob_insert(j),
	   p_duration_insert(j), p_mod_duration_insert(j),
	   p_convexity_insert(j), p_delta_insert(j), p_gamma_insert(j),
	   p_theta_insert(j), p_rho_insert(j), p_rho_base_insert(j),
	   p_rho_contra_insert(j), p_rho_for_insert(j), p_rho_dom_insert(j),
	   p_vega_insert(j), p_pos_bpv_insert(j), p_pos_bpv_usd_insert(j),
	   p_pos_bpv_sob_insert(j), p_pos_delta_insert(j),
	   p_pos_delta_usd_insert(j), p_pos_delta_sob_insert(j),
	   p_pos_gamma_insert(j), p_pos_gamma_usd_insert(j),
	   p_pos_gamma_sob_insert(j), p_pos_theta_insert(j),
	   p_pos_theta_usd_insert(j), p_pos_theta_sob_insert(j),
	   p_pos_rho_insert(j), p_pos_rho_usd_insert(j),
	   p_pos_rho_sob_insert(j), p_pos_rho_base_insert(j),
	   p_pos_rho_base_usd_insert(j), p_pos_rho_base_sob_insert(j),
	   p_pos_rho_contra_insert(j), p_pos_rho_contra_usd_insert(j),
	   p_pos_rho_contra_sob_insert(j), p_pos_rho_for_insert(j),
	   p_pos_rho_for_usd_insert(j), p_pos_rho_for_sob_insert(j),
	   p_pos_rho_dom_insert(j), p_pos_rho_dom_usd_insert(j),
	   p_pos_rho_dom_sob_insert(j), p_pos_vega_insert(j),
	   p_pos_vega_usd_insert(j), p_pos_vega_sob_insert(j),
	   p_volatility_insert(j), p_ytm_insert(j),
	   p_gap_date_insert(j), p_reval_price_insert(j),
	   p_reval_price_usd_insert(j), p_reval_price_sob_insert(j),
	   p_trans_price_insert(j), p_trans_price_usd_insert(j),
	   p_trans_price_sob_insert(j), p_ref_datetime,
	   FND_GLOBAL.user_id, p_ref_datetime,
	   FND_GLOBAL.user_id, p_ref_datetime, FND_GLOBAL.login_id,
	   FND_GLOBAL.conc_request_id, FND_GLOBAL.prog_appl_id,
	   FND_GLOBAL.conc_program_id, p_ref_datetime);

      IF (g_event_level>=g_debug_level) THEN --bug 3236479
         XTR_RISK_DEBUG_PKG.dlog('DML','INSERTED QRM_DEAL_CALCULATIONS',
           'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_event_level);
      END IF;

      --- UPDATE  QRM_DEAL_CALCULATIONS
      IF (g_state_level>=g_debug_level) THEN --bug 3236479
         --XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'about to update');
         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'p_update_counter: '|| p_update_counter);
         for j in 1..p_update_counter loop
          v_log := p_deal_ccy_update(j)||';'||
	   p_sob_ccy_update(j)||';'|| p_base_ccy_amount_usd_update(j)||';'||
	   p_base_ccy_amount_sob_update(j)||';'|| p_contra_ccy_amount_usd_update(j)||';'||
 	   p_contra_ccy_amount_sob_update(j)||';'|| p_foreign_amount_usd_update(j)||';'||
	   p_foreign_amount_sob_update(j)||';'|| p_domestic_amount_usd_update(j)||';'||
	   p_domestic_amount_sob_update(j)||';'|| p_buy_amount_usd_update(j)||';'||
	   p_buy_amount_sob_update(j)||';'|| p_sell_amount_usd_update(j)||';'||
	   p_sell_amount_sob_update(j)||';'|| p_days_update(j);
	  XTR_RISK_DEBUG_PKG.dlog('update QRM_DEAL_CALCULATIONS Line 1',v_log,
            'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_state_level);
	  v_log := p_fx_reval_rate_update(j)||';'||p_mm_reval_rate_update(j)||';'||
	   p_fx_trans_rate_update(j)||';'|| p_mm_trans_rate_update(j)||';'||
	   p_fair_value_update(j)||';'|| p_fair_value_usd_update(j)||';'||
	   p_fair_value_sob_update(j)||';'|| p_gap_amount_update(j)||';'||
	   p_gap_amount_usd_update(j)||';'|| p_gap_amount_sob_update(j)||';'||
	   p_maturity_amount_update(j)||';'|| p_maturity_amount_usd_update(j)||';'||
	   p_maturity_amount_sob_update(j)||';'|| p_premium_amount_usd_update(j)||';'||
	   p_premium_amount_sob_update(j)||';'|| p_accrued_interest_update(j)||';'||
	   p_accrued_interest_usd_update(j)||';'|| p_accrued_interest_sob_update(j);
          XTR_RISK_DEBUG_PKG.dlog('update QRM_DEAL_CALCULATIONS Line 2',v_log,
            'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_state_level);
	  v_log := p_duration_update(j)||';'|| p_mod_duration_update(j)||';'||
	   p_convexity_update(j)||';'|| p_delta_update(j)||';'|| p_gamma_update(j)||';'||
	   p_theta_update(j)||';'|| p_rho_update(j)||';'|| p_rho_base_update(j)||';'||
	   p_rho_contra_update(j)||';'|| p_rho_for_update(j)||';'|| p_rho_dom_update(j)||';'||
	   p_vega_update(j)||';'|| p_pos_bpv_update(j)||';'|| p_pos_bpv_usd_update(j)||';'||
	   p_pos_bpv_sob_update(j)||';'|| p_pos_delta_update(j)||';'||
	   p_pos_delta_usd_update(j)||';'|| p_pos_delta_sob_update(j)||';'||
	   p_pos_gamma_update(j)||';'|| p_pos_gamma_usd_update(j)||';'||
	   p_pos_gamma_sob_update(j)||';'|| p_pos_theta_update(j)||';'||
	   p_pos_theta_usd_update(j)||';'|| p_pos_theta_sob_update(j)||';'||
	   p_pos_rho_update(j)||';'|| p_pos_rho_usd_update(j)||';'||
	   p_pos_rho_sob_update(j)||';'|| p_pos_rho_base_update(j)||';'||
	   p_pos_rho_base_usd_update(j)||';'|| p_pos_rho_base_sob_update(j)||';'||
	   p_pos_rho_contra_update(j)||';'|| p_pos_rho_contra_usd_update(j);
          XTR_RISK_DEBUG_PKG.dlog('update QRM_DEAL_CALCULATIONS Line 3',v_log,
            'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_state_level);
	  v_log := p_pos_rho_contra_sob_update(j)||';'|| p_pos_rho_for_update(j)||';'||
	   p_pos_rho_for_usd_update(j)||';'|| p_pos_rho_for_sob_update(j)||';'||
	   p_pos_rho_dom_update(j)||';'|| p_pos_rho_dom_usd_update(j)||';'||
	   p_pos_rho_dom_sob_update(j)||';'|| p_pos_vega_update(j)||';'||
	   p_pos_vega_usd_update(j)||';'|| p_pos_vega_sob_update(j)||';'||
	   p_volatility_update(j)||';'|| p_ytm_update(j)||';'||
	   p_gap_date_update(j)||';'|| p_reval_price_update(j)||';'||
	   p_reval_price_usd_update(j)||';'|| p_reval_price_sob_update(j)||';'||
	   p_trans_price_update(j)||';'|| p_trans_price_usd_update(j)||';'||
	   p_trans_price_sob_update(j)||';'|| p_ref_datetime;
          XTR_RISK_DEBUG_PKG.dlog('update QRM_DEAL_CALCULATIONS Line 4',v_log,
            'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_state_level);
         end loop;
      END IF;

      FORALL j IN 1..p_update_counter
         UPDATE qrm_deal_calculations
         SET
	   deal_ccy=p_deal_ccy_update(j), sob_ccy=p_sob_ccy_update(j),
	   base_ccy_amount_usd= p_base_ccy_amount_usd_update(j),
	   base_ccy_amount_sob=p_base_ccy_amount_sob_update(j),
	   contra_ccy_amount_usd=p_contra_ccy_amount_usd_update(j),
	   contra_ccy_amount_sob=p_contra_ccy_amount_sob_update(j),
	   foreign_amount_usd=p_foreign_amount_usd_update(j),
	   foreign_amount_sob=p_foreign_amount_sob_update(j),
	   domestic_amount_usd=p_domestic_amount_usd_update(j),
	   domestic_amount_sob=p_domestic_amount_sob_update(j),
	   buy_amount_usd=p_buy_amount_usd_update(j),
	   buy_amount_sob=p_buy_amount_sob_update(j),
	   sell_amount_usd=p_sell_amount_usd_update(j),
	   sell_amount_sob=p_sell_amount_sob_update(j),
	   days=p_days_update(j), fx_reval_rate=p_fx_reval_rate_update(j),
	   mm_reval_rate=p_mm_reval_rate_update(j),
	   fx_trans_rate=p_fx_trans_rate_update(j),
	   mm_trans_rate=p_mm_trans_rate_update(j),
	   revaluation_price = p_reval_price_update(j),
	   revaluation_price_sob = p_reval_price_sob_update(j),
	   revaluation_price_usd = p_reval_price_usd_update(j),
	   transaction_price = p_trans_price_update(j),
	   transaction_price_sob = p_trans_price_sob_update(j),
	   transaction_price_usd = p_trans_price_usd_update(j),
	   fair_value=p_fair_value_update(j),
	   fair_value_usd=p_fair_value_usd_update(j),
	   fair_value_sob=p_fair_value_sob_update(j),
	   gap_amount=p_gap_amount_update(j),
	   gap_amount_usd=p_gap_amount_usd_update(j),
	   gap_amount_sob=p_gap_amount_sob_update(j),
	   maturity_amount=p_maturity_amount_update(j),
	   maturity_amount_usd=p_maturity_amount_usd_update(j),
	   maturity_amount_sob=p_maturity_amount_sob_update(j),
	   premium_amount_usd=p_premium_amount_usd_update(j),
	   premium_amount_sob=p_premium_amount_sob_update(j),
	   accrued_interest=p_accrued_interest_update(j),
	   accrued_interest_usd=p_accrued_interest_usd_update(j),
	   accrued_interest_sob=p_accrued_interest_sob_update(j),
	   duration=p_duration_update(j),
	   modified_duration=p_mod_duration_update(j),
	   convexity=p_convexity_update(j), delta=p_delta_update(j),
	   gamma=p_gamma_update(j), theta=p_theta_update(j),
	   rho=p_rho_update(j), rho_base=p_rho_base_update(j),
	   rho_contra=p_rho_contra_update(j), rho_foreign=p_rho_for_update(j),
 	   rho_domestic=p_rho_dom_update(j), vega=p_vega_update(j),
	   pos_bpv=p_pos_bpv_update(j),
	   pos_bpv_usd=p_pos_bpv_usd_update(j),
	   pos_bpv_sob=p_pos_bpv_sob_update(j),
	   pos_delta=p_pos_delta_update(j),
	   pos_delta_usd=p_pos_delta_usd_update(j),
	   pos_delta_sob=p_pos_delta_sob_update(j),
	   pos_gamma=p_pos_gamma_update(j),
	   pos_gamma_usd=p_pos_gamma_usd_update(j),
	   pos_gamma_sob=p_pos_gamma_sob_update(j),
	   pos_theta=p_pos_theta_update(j),
	   pos_theta_usd=p_pos_theta_usd_update(j),
	   pos_theta_sob=p_pos_theta_sob_update(j),
	   pos_rho=p_pos_rho_update(j), pos_rho_usd=p_pos_rho_usd_update(j),
	   pos_rho_sob=p_pos_rho_sob_update(j),
	   pos_rho_base=p_pos_rho_base_update(j),
	   pos_rho_base_usd=p_pos_rho_base_usd_update(j),
	   pos_rho_base_sob=p_pos_rho_base_sob_update(j),
	   pos_rho_contra=p_pos_rho_contra_update(j),
	   pos_rho_contra_usd=p_pos_rho_contra_usd_update(j),
	   pos_rho_contra_sob=p_pos_rho_contra_sob_update(j),
	   pos_rho_foreign=p_pos_rho_for_update(j),
	   pos_rho_foreign_usd=p_pos_rho_for_usd_update(j),
	   pos_rho_foreign_sob=p_pos_rho_for_sob_update(j),
	   pos_rho_domestic=p_pos_rho_dom_update(j),
	   pos_rho_domestic_usd=p_pos_rho_dom_usd_update(j),
	   pos_rho_domestic_sob=p_pos_rho_dom_sob_update(j),
	   pos_vega=p_pos_vega_update(j),
	   pos_vega_usd=p_pos_vega_usd_update(j),
	   pos_vega_sob=p_pos_vega_sob_update(j),
	   volatility=p_volatility_update(j),
	   yield_to_maturity=p_ytm_update(j),
	   gap_date=p_gap_date_update(j),
	   last_md_calc_date=p_upd_md_calc_date_update(j),
	   created_by=FND_GLOBAL.user_id,
	   creation_date=p_ref_datetime, last_updated_by=FND_GLOBAL.user_id,
	   last_update_date=p_ref_datetime,
	   last_update_login=FND_GLOBAL.login_id,
	   request_id=FND_GLOBAL.conc_request_id,
	   program_application_id=FND_GLOBAL.prog_appl_id,
	   program_id=FND_GLOBAL.conc_program_id,
	   program_update_date=p_ref_datetime
         WHERE deal_calc_id = p_deal_calc_id_update(j);

      IF (g_event_level>=g_debug_level) THEN --bug 3236479
         XTR_RISK_DEBUG_PKG.dlog('DML','UPDATED QRM_DEAL_CALCULATIONS',
           'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_event_level);
      END IF;

      -- UPDATE  QRM_DEALS_ANALYSES
      -- first delete all old links
      IF (g_proc_level>=g_debug_level) THEN
         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'about to delete');
      END IF;
/* BUG 2945198 - SQL BINDING
      DELETE
      FROM qrm_deals_analyses
      WHERE analysis_name=p_analysis_name;
*/
      -- add links for inserted deals

      IF (g_state_level>=g_debug_level) THEN --bug 3236479
         for j in 1..p_insert_counter loop
           v_log := p_seq_nos(j)||','|| p_analysis_name||','|| p_company_code_insert(j)||','||
              FND_GLOBAL.user_id||','|| p_ref_datetime||','|| FND_GLOBAL.user_id||','||
	      p_ref_datetime||','|| FND_GLOBAL.login_id||','|| FND_GLOBAL.conc_request_id||','||
	      FND_GLOBAL.prog_appl_id||','|| FND_GLOBAL.conc_program_id||','||p_ref_datetime;
           XTR_RISK_DEBUG_PKG.dlog('INSERT QRM_DEALS_ANALYSES',v_log,
            'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_state_level);
         end loop;
         for j in 1..p_update_counter loop
           v_log :=  p_deal_calc_id_update(j)||','||p_analysis_name||','||p_company_code_update(j);
           XTR_RISK_DEBUG_PKG.dlog('INSERT QRM_DEALS_ANALYSES',v_log,
            'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_state_level);
         end loop;
      end if;

      FORALL j IN 1..p_insert_counter
         INSERT INTO qrm_deals_analyses (deal_calc_id, analysis_name,
	   company_code, created_by, creation_date, last_updated_by,
	   last_update_date, last_update_login, request_id,
	   program_application_id, program_id, program_update_date)
         VALUES (p_seq_nos(j), p_analysis_name, p_company_code_insert(j),
           FND_GLOBAL.user_id, p_ref_datetime, FND_GLOBAL.user_id,
	   p_ref_datetime, FND_GLOBAL.login_id, FND_GLOBAL.conc_request_id,
	   FND_GLOBAL.prog_appl_id, FND_GLOBAL.conc_program_id,p_ref_datetime);
      -- add links for updated deals
      FORALL j IN 1..p_update_counter
         INSERT INTO qrm_deals_analyses (deal_calc_id, analysis_name,
	   company_code, created_by, creation_date, last_updated_by,
	   last_update_date, last_update_login, request_id,
	   program_application_id, program_id, program_update_date)
         VALUES (p_deal_calc_id_update(j), p_analysis_name,
	   p_company_code_update(j), FND_GLOBAL.user_id, p_ref_datetime,
	   FND_GLOBAL.user_id, p_ref_datetime, FND_GLOBAL.login_id,
	   FND_GLOBAL.conc_request_id, FND_GLOBAL.prog_appl_id,
	   FND_GLOBAL.conc_program_id, p_ref_datetime);

      IF (g_event_level>=g_debug_level) THEN --bug 3236479
         XTR_RISK_DEBUG_PKG.dlog('DML','INSERTED QRM_DEAL_ANALYSES',
           'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_event_level);
      END IF;

      -- UPDATE QRM_TB_CALCULATIONS
      -- first delete old data for deal no/trans no
      FORALL j IN 1..p_tb_counter
         DELETE
         FROM qrm_tb_calculations
         WHERE deal_no=p_tb_deal_no(j)
          AND  transaction_no=p_tb_transaction_no(j)
          AND  market_data_set=p_tb_market_data_set(j);
      -- then insert new ones

      IF (g_event_level>=g_debug_level) THEN --bug 3236479
         XTR_RISK_DEBUG_PKG.dlog('DML','DELETED QRM_TB_CALCULATIONS',
           'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_event_level);
      END IF;

      IF (g_state_level>=g_debug_level) THEN --bug 3236479
         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'p_tb_counter: ' || p_tb_counter);
         for j in 1..p_tb_counter loop
           v_log := p_tb_deal_no(j)||','||
	      p_tb_transaction_no(j)||','|| p_tb_market_data_set(j)||','||
	      p_tb_pos_start_date(j)||','|| p_tb_pos_end_date(j)||','||
	      p_tb_start_date(j)||','|| p_tb_end_date(j)||','||
	      p_tb_interest_basis(j)||','|| p_tb_outst_amount(j)||','||
	      p_tb_outst_amount_usd(j)||','|| p_tb_outst_amount_sob(j)||','||
	      p_tb_coupon_rate(j)||','|| p_tb_next_coupon_date(j)||','|| p_tb_amt_qty_out(j)||','||
	      p_tb_amt_qty_out_usd(j)||','|| p_tb_amt_qty_out_sob(j);
           XTR_RISK_DEBUG_PKG.dlog('INSERT QRM_TB_CALCULATIONS',v_log,
            'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_state_level);
         end loop;
      end if;

	FORALL j IN 1..p_tb_counter
         INSERT INTO qrm_tb_calculations (deal_no, transaction_no,
	   market_data_set, pos_start_date, pos_end_date, start_date,
	   end_date, interest_basis, outstanding_amount,
	   outstanding_amount_usd, outstanding_amount_sob, coupon_rate,
	   next_coupon_date,amt_qty_out, amt_qty_out_usd, amt_qty_out_sob,
	   created_by, creation_date, last_updated_by,
	   last_update_date, last_update_login, request_id,
	   program_application_id, program_id,
	   program_update_date)
         VALUES (p_tb_deal_no(j),
	   p_tb_transaction_no(j), p_tb_market_data_set(j),
	   p_tb_pos_start_date(j), p_tb_pos_end_date(j),
	   p_tb_start_date(j), p_tb_end_date(j),
	   p_tb_interest_basis(j), p_tb_outst_amount(j),
	   p_tb_outst_amount_usd(j), p_tb_outst_amount_sob(j),
	   p_tb_coupon_rate(j), p_tb_next_coupon_date(j), p_tb_amt_qty_out(j),
	   p_tb_amt_qty_out_usd(j), p_tb_amt_qty_out_sob(j),
	   FND_GLOBAL.user_id, p_ref_datetime, FND_GLOBAL.user_id,
	   p_ref_datetime, FND_GLOBAL.login_id, FND_GLOBAL.conc_request_id,
	   FND_GLOBAL.prog_appl_id,FND_GLOBAL.conc_program_id,p_ref_datetime);

      IF (g_event_level>=g_debug_level) THEN --bug 3236479
         XTR_RISK_DEBUG_PKG.dlog('DML','INSERTED QRM_TB_CALCULATIONS',
           'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_event_level);
      END IF;

-- BUG 2945198 - SQL BINDING
   END IF;  -- end of if retcode<>'2'

      exit when n_num_rows_fetched <> p_batch_fetch_size;
   end loop;

   EXCEPTION
      WHEN OTHERS THEN
         if dbms_sql.is_open(v_cursor) then
            dbms_sql.close_cursor(v_cursor);
         end if;
	 IF (g_proc_level>=g_debug_level) THEN
	    XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'unhandled exp during deal retrieval after DML');
	 END IF;
	 -- unhandled exception, clear previous warnings
	 p_except_counter := 0;
	 p_except_deal_no.DELETE;
	 p_except_transaction_no.DELETE;
	 p_except_market_data_set.DELETE;
	 p_except_error_type.DELETE;
	 p_except_error_code.DELETE;
	 p_except_token_name.DELETE;
	 p_except_token_value.DELETE;
	 retcode := '2';  -- unhandled exception occurred, program fail
	 p_except_counter := p_except_counter + 1;
	 p_except_deal_no.EXTEND;
	 p_except_transaction_no.EXTEND;
	 p_except_market_data_set.EXTEND;
	 p_except_error_type.EXTEND;
	 p_except_error_code.EXTEND;
	 p_except_token_name.EXTEND;
	 p_except_token_value.EXTEND;
	 p_except_deal_no(p_except_counter):=NULL;
	 p_except_transaction_no(p_except_counter):=NULL;
	 p_except_market_data_set(p_except_counter):=NULL;
	 p_except_error_type(p_except_counter):='E';
	 p_except_error_code(p_except_counter):='QRM_ANA_UNEXPECTED_ERROR';
	 --exit;  -- exit loop
   END;


   IF (retcode <> '2') THEN

IF (g_proc_level>=g_debug_level) THEN
   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'NUMBER OF DEALS: ' || p_total_deals_counter);
END IF;

-- END BUG 2945198 - SQL BINDING

IF (g_proc_level>=g_debug_level) THEN
   XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'before commit');
END IF;

      COMMIT;

      -- no deal has passed gap analysis requirements
      -- thus, no rows returned
      IF (g_proc_level>=g_debug_level) THEN
         XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'past commit');
      END IF;
      IF (NOT (p_gap_deal_exists)) THEN
	retcode := '5';
      END IF;

      IF (retcode = '5') THEN
	 p_except_counter := p_except_counter + 1;
	 p_except_deal_no.EXTEND;
	 p_except_transaction_no.EXTEND;
	 p_except_market_data_set.EXTEND;
	 p_except_error_type.EXTEND;
	 p_except_error_code.EXTEND;
	 p_except_token_name.EXTEND;
	 p_except_token_value.EXTEND;
	 p_except_error_type(p_except_counter) := 'W';
	 p_except_error_code(p_except_counter) := 'QRM_ANA_NO_ROWS_RETURNED';
      END IF;

      -- CALL AGGREGATOR if analysis style is not 'T'
      IF (p_settings.style <> 'T' and retcode <> '5') THEN
         IF (g_proc_level>=g_debug_level) THEN
            XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'about to aggregate');
         END IF;
         p_agg_ok := QRM_PA_AGGREGATION_P.transform_and_save(p_analysis_name,
			p_ref_datetime, 'CONC');

         IF (p_agg_ok = 'F') THEN -- unhandled exception in aggregator
	   IF (g_proc_level>=g_debug_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'unhandled exception in aggregator!');
	   END IF;
	   -- clear previous warnings
	   p_except_counter := 0;
	   p_except_deal_no.DELETE;
	   p_except_transaction_no.DELETE;
	   p_except_market_data_set.DELETE;
	   p_except_error_type.DELETE;
	   p_except_error_code.DELETE;
	   p_except_token_name.DELETE;
	   p_except_token_value.DELETE;
	   -- set error message
	   retcode := '2';
	   p_except_counter := p_except_counter + 1;
	   p_except_deal_no.EXTEND;
	   p_except_transaction_no.EXTEND;
	   p_except_market_data_set.EXTEND;
	   p_except_error_type.EXTEND;
	   p_except_error_code.EXTEND;
	   p_except_token_name.EXTEND;
	   p_except_token_value.EXTEND;
	   p_except_error_type(p_except_counter) := 'E';
	   p_except_error_code(p_except_counter) := 'QRM_ANA_UNEXPECTED_ERROR';
         END IF;
      END IF;

      -- Remove expired deals with respect to reference date
      remove_expired_deals(p_ref_date);

   END IF;  -- end of if retcode<>'2'

   EXCEPTION
     WHEN e_no_setting_found THEN
        -- clear previous warnings
        p_except_counter := 0;
	p_except_deal_no.DELETE;
	p_except_transaction_no.DELETE;
	p_except_market_data_set.DELETE;
	p_except_error_type.DELETE;
	p_except_error_code.DELETE;
	p_except_token_name.DELETE;
	p_except_token_value.DELETE;
	-- set error message
	retcode := '2';
	p_except_counter := p_except_counter + 1;
	p_except_deal_no.EXTEND;
	p_except_transaction_no.EXTEND;
	p_except_market_data_set.EXTEND;
	p_except_error_type.EXTEND;
	p_except_error_code.EXTEND;
	p_except_token_name.EXTEND;
	p_except_token_value.EXTEND;
	p_except_error_type(p_except_counter) := 'E';
        p_except_error_code(p_except_counter) := 'QRM_ANA_NO_SETTING';
    	p_except_token_name(p_except_counter) := 'ANALYSIS_NAME';
	p_except_token_value(p_except_counter) := p_analysis_name;
	--bug 3236479
	   IF (g_proc_level>=g_ERROR_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('EXCEPTION','QRM_ANA_NO_SETTING',
	         'QRM_PA_CALCULATIONS_P.RUN_ANALYSIS',
		 g_error_level);
	   END IF;
    WHEN e_analysis_in_progress THEN
        -- clear previous warnings
        p_except_counter := 0;
	p_except_deal_no.DELETE;
	p_except_transaction_no.DELETE;
	p_except_market_data_set.DELETE;
	p_except_error_type.DELETE;
	p_except_error_code.DELETE;
	p_except_token_name.DELETE;
	p_except_token_value.DELETE;
	-- set error message
	retcode := '2';
	p_except_counter := p_except_counter + 1;
	p_except_deal_no.EXTEND;
	p_except_transaction_no.EXTEND;
	p_except_market_data_set.EXTEND;
	p_except_error_type.EXTEND;
	p_except_error_code.EXTEND;
	p_except_token_name.EXTEND;
	p_except_token_value.EXTEND;
	p_except_error_type(p_except_counter) := 'E';
        p_except_error_code(p_except_counter) := 'QRM_ANA_RUN_IN_PROGRESS';
	p_except_token_name(p_except_counter) := 'ANALYSIS';
	p_except_token_value(p_except_counter) := p_analysis_name;
	--bug 3236479
	   IF (g_proc_level>=g_ERROR_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('EXCEPTION','QRM_ANA_RUN_IN_PROGRESS',
	         'QRM_PA_CALCULATIONS_P.RUN_ANALYSIS',
		 g_error_level);
	   END IF;
     WHEN QRM_PA_AGGREGATION_P.e_pagg_no_fxrate_found THEN
        -- clear previous warnings
        p_except_counter := 0;
	p_except_deal_no.DELETE;
	p_except_transaction_no.DELETE;
	p_except_market_data_set.DELETE;
	p_except_error_type.DELETE;
	p_except_error_code.DELETE;
	p_except_token_name.DELETE;
	p_except_token_value.DELETE;
	-- set error message
	retcode := '2';
	p_except_counter := p_except_counter + 1;
	p_except_deal_no.EXTEND;
	p_except_transaction_no.EXTEND;
	p_except_market_data_set.EXTEND;
	p_except_error_type.EXTEND;
	p_except_error_code.EXTEND;
	p_except_token_name.EXTEND;
	p_except_token_value.EXTEND;
	p_except_error_type(p_except_counter) := 'E';
        p_except_error_code(p_except_counter) := 'QRM_CALC_NO_DEFAULT_SPOT_ERR';
	p_except_token_name(p_except_counter) := 'CCY';
	p_except_token_value(p_except_counter) := p_settings.curr_reporting;
	--bug 3236479
	   IF (g_proc_level>=g_ERROR_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('EXCEPTION','QRM_CALC_NO_DEFAULT_SPOT_ERR',
	         'QRM_PA_CALCULATIONS_P.RUN_ANALYSIS',
		 g_error_level);
	   END IF;
     WHEN QRM_PA_AGGREGATION_P.e_pagg_no_timebuckets_found THEN
        -- clear previous warnings
        p_except_counter := 0;
	p_except_deal_no.DELETE;
	p_except_transaction_no.DELETE;
	p_except_market_data_set.DELETE;
	p_except_error_type.DELETE;
	p_except_error_code.DELETE;
	p_except_token_name.DELETE;
	p_except_token_value.DELETE;
	-- set error message
	retcode := '2';
	p_except_counter := p_except_counter + 1;
	p_except_deal_no.EXTEND;
	p_except_transaction_no.EXTEND;
	p_except_market_data_set.EXTEND;
	p_except_error_type.EXTEND;
	p_except_error_code.EXTEND;
	p_except_token_name.EXTEND;
	p_except_token_value.EXTEND;
	p_except_error_type(p_except_counter) := 'E';
        p_except_error_code(p_except_counter) := 'QRM_ANA_NO_TIMEBUCKETS';
	p_except_token_name(p_except_counter) := 'TB_NAME';
	p_except_token_value(p_except_counter) := p_settings.tb_name;
	--bug 3236479
	   IF (g_proc_level>=g_ERROR_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('EXCEPTION','QRM_ANA_NO_TIMEBUCKETS',
	         'QRM_PA_CALCULATIONS_P.RUN_ANALYSIS',
		 g_error_level);
	   END IF;
     WHEN QRM_PA_AGGREGATION_P.e_pagg_no_setting_found THEN
        -- clear previous warnings
        p_except_counter := 0;
	p_except_deal_no.DELETE;
	p_except_transaction_no.DELETE;
	p_except_market_data_set.DELETE;
	p_except_error_type.DELETE;
	p_except_error_code.DELETE;
	p_except_token_name.DELETE;
	p_except_token_value.DELETE;
	-- set error message
	retcode := '2';
	p_except_counter := p_except_counter + 1;
	p_except_deal_no.EXTEND;
	p_except_transaction_no.EXTEND;
	p_except_market_data_set.EXTEND;
	p_except_error_type.EXTEND;
	p_except_error_code.EXTEND;
	p_except_token_name.EXTEND;
	p_except_token_value.EXTEND;
	p_except_error_type(p_except_counter) := 'E';
        p_except_error_code(p_except_counter) := 'QRM_ANA_NO_SETTING';
	p_except_token_name(p_except_counter) := 'ANALYSIS_NAME';
	p_except_token_value(p_except_counter) := p_analysis_name;
	--bug 3236479
	   IF (g_proc_level>=g_ERROR_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('EXCEPTION','QRM_PA_AGGREGATION_P.E_PAGG_NO_SETTING_FOUND',
	         'QRM_PA_CALCULATIONS_P.RUN_ANALYSIS',
		 g_error_level);
	   END IF;
     WHEN others THEN
        p_except_counter := 0;
	p_except_deal_no.DELETE;
	p_except_transaction_no.DELETE;
	p_except_market_data_set.DELETE;
	p_except_error_type.DELETE;
	p_except_error_code.DELETE;
	p_except_token_name.DELETE;
	p_except_token_value.DELETE;
	-- set error message
	retcode := '2';
	p_except_counter := p_except_counter + 1;
	p_except_deal_no.EXTEND;
	p_except_transaction_no.EXTEND;
	p_except_market_data_set.EXTEND;
	p_except_error_type.EXTEND;
	p_except_error_code.EXTEND;
	p_except_token_name.EXTEND;
	p_except_token_value.EXTEND;
	p_except_error_type(p_except_counter) := 'E';
	p_except_error_code(p_except_counter) := 'QRM_ANA_UNEXPECTED_ERROR';
	--bug 3236479
	   IF (g_proc_level>=g_ERROR_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('EXCEPTION','QRM_ANA_UNEXPECTED_ERROR outer',
	         'QRM_PA_CALCULATIONS_P.RUN_ANALYSIS',
		 g_error_level);
	   END IF;
   END;


   -- UPDATE LAST RUN DATE AND CALC STATUS IN SETTINGS TABLE
   UPDATE qrm_analysis_settings
   SET last_run_date = p_ref_datetime, status = retcode
   WHERE analysis_name = p_analysis_name;

   IF (g_event_level>=g_debug_level) THEN --bug 3236479
         XTR_RISK_DEBUG_PKG.dlog('DML','UPDATED LAST RUN DATE AND CALC STATUS IN SETTINGS TABLE',
           'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_event_level);
   END IF;

   -- UPDATE ERRORS TABLE
   -- first remove all errors associated with this analysis
   DELETE
   FROM qrm_deal_calc_errors
   WHERE analysis_name=p_analysis_name;

   IF (g_event_level>=g_debug_level) THEN --bug 3236479
         XTR_RISK_DEBUG_PKG.dlog('DML','Deleted qrm_deal_calc_errors',
           'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_event_level);
   END IF;

   -- now insert new errors into table
   FORALL j IN 1..p_except_counter
      INSERT INTO qrm_deal_calc_errors (analysis_name, deal_no,
	 transaction_no, market_data_set, error_type, error_code,
	 token_name, token_value, created_by, creation_date,
	 last_updated_by, last_update_date, last_update_login,
	 request_id, program_application_id, program_id, program_update_date)
      VALUES (p_analysis_name, p_except_deal_no(j), p_except_transaction_no(j),
	 p_except_market_data_set(j), p_except_error_type(j),
	 p_except_error_code(j), p_except_token_name(j),
	 p_except_token_value(j), FND_GLOBAL.user_id, p_ref_datetime,
	 FND_GLOBAL.user_id, p_ref_datetime, FND_GLOBAL.login_id,
	 FND_GLOBAL.conc_request_id, FND_GLOBAL.prog_appl_id,
	 FND_GLOBAL.conc_program_id, p_ref_datetime);

  COMMIT;

  IF (g_event_level>=g_debug_level) THEN --bug 3236479
         XTR_RISK_DEBUG_PKG.dlog('DML','Inserted new errors into table',
           'QRM_PA_CALCULATION_P.RUN_ANALYSIS',g_event_level);
  END IF;

  -- if no rows returned, reset retcode to '1'
  -- FOR concurrent manager
  IF (retcode = '5') THEN
     retcode := '1';
  END IF;

  IF (g_proc_level>=g_debug_level) THEN
     XTR_RISK_DEBUG_PKG.dlog('run_analysis: ' || 'retcode is: '||retcode);
     XTR_RISK_DEBUG_PKG.dpop(null,'QRM_CALCULATION_P.RUN_ANALYSIS'); --bug3236479;
  END IF;

END run_analysis;



FUNCTION get_signed_amount  (p_amount	NUMBER,
			     p_deal_type VARCHAR2,
			     p_deal_subtype VARCHAR2,
			     p_action VARCHAR2)
	RETURN NUMBER IS

   p_signed_amount NUMBER := p_amount;

BEGIN

   IF (g_proc_level>=g_debug_level) THEN
     XTR_RISK_DEBUG_PKG.dpush(null,'QRM_CALCULATION_P.GET_SIGNED_AMOUNT'); --bug3236479;
   END IF;

   -- BOND: sign amount outstanding,maturity amount,gap amount,accrued interest
   -- NI: sign all except accrued interest (accrued interest is 0)
   IF (p_deal_type IN ('BOND', 'NI')) THEN
	IF (p_deal_subtype NOT IN ('BUY')) THEN
	 	p_signed_amount := (-1) * p_amount;
	END IF;
   -- TMM, RTMM, IRS, ONC: sign amount outstanding, maturity amount,
   -- gap amount
   ELSIF (p_deal_type IN ('TMM', 'RTMM', 'IRS', 'ONC', 'IG')) THEN
	IF (p_deal_subtype NOT IN ('INVEST')) THEN
		p_signed_amount := (-1) * p_amount;
	END IF;
   ELSIF (p_deal_type IN ('FRA')) THEN  -- only gap amount is signed
	IF (p_deal_subtype NOT IN ('FUND')) THEN
		p_signed_amount := (-1) * p_amount;
	END IF;
   ELSIF (p_deal_type IN ('IRO')) THEN -- only gap amount is signed
	IF (p_deal_subtype NOT IN ('BCAP', 'SFLOOR')) THEN
		p_signed_amount := (-1) * p_amount;
	END IF;
   ELSIF (p_deal_type IN ('BDO')) THEN -- only gap amount is signed
	IF (p_deal_subtype IN ('BCAP', 'SFLOOR')) THEN
		p_signed_amount := (-1) * p_amount;
	END IF;
   ELSIF (p_deal_type IN ('SWPTN')) THEN -- only gap amount is signed
	IF (NOT ((p_deal_subtype='BUY' and p_action='PAY') OR
		 (p_deal_subtype='SELL' and p_action='REC'))) THEN
		p_signed_amount := (-1) * p_amount;
	END IF;
   END IF;

   IF (g_proc_level>=g_debug_level) THEN
     XTR_RISK_DEBUG_PKG.dpop(null,'QRM_CALCULATION_P.GET_SIGNED_AMOUNT'); --bug3236479;
   END IF;

   return p_signed_amount;
END get_signed_amount;



FUNCTION get_threshold_date (p_ref_datetime DATE,
		   	     p_threshold_num NUMBER,
		   	     p_threshold_type VARCHAR2)
	RETURN DATE IS

	p_threshold_date 	DATE;
BEGIN
     IF (p_threshold_type = 'M') THEN -- Minutes
	-- 1440 = number of minutes in a day
        p_threshold_date := p_ref_datetime - p_threshold_num/1440;
     ELSIF (p_threshold_type = 'H') THEN -- Hours
        p_threshold_date := p_ref_datetime - p_threshold_num/24;
     ELSIF (p_threshold_type = 'D') THEN -- Days
        p_threshold_date := p_ref_datetime - p_threshold_num;
     END IF;
     RETURN p_threshold_date;
END get_threshold_date;


FUNCTION get_gap_date 	(p_deal_no		IN	NUMBER,
			 p_deal_type		IN	VARCHAR2,
			 p_initial_basis	IN	VARCHAR2,
			 p_ref_date		IN	DATE)
	RETURN DATE IS

   CURSOR get_transaction_data IS
      SELECT rate_fixing_date, start_date, maturity_date
      FROM xtr_rollover_transactions_v
      WHERE deal_number=p_deal_no;

  /* CURSOR get_deal_data IS
      SELECT max(maturity_date), settle_date
      FROM qrm_current_deals_v
      GROUP BY deal_no, settle_date
      HAVING deal_no=p_deal_no;  Bug 4965436*/

     CURSOR get_deal_data IS
     SELECT max(maturity_date), settle_date
      FROM  qrm_current_deals_v
      WHERE deal_no=p_deal_no
      GROUP BY settle_date ;


   -- the first part of the where clause accounts for the case
   -- where ref_date <= fixed until date, so gap date is next start date
   -- that is >= fixed until date
   -- the second part is when the ref_date > fixed until date, so the
   -- next gap date is the next start date after ref date
   CURSOR get_others (p_date DATE) IS
      SELECT DISTINCT maturity_date
      FROM xtr_rollover_transactions_v
      WHERE deal_number=p_deal_no
	AND (  (p_ref_date<=p_date
		   and start_date<p_date
		   and p_date<=maturity_date
		   and maturity_date>=p_ref_date)
	     OR(
		p_ref_date>p_date
		   and start_date<p_ref_date
		   and p_ref_date<=maturity_date));

   p_fixed_until_date 		DATE;
   p_trans_start_date		DATE;
   p_trans_maturity_date	DATE;
   p_deal_maturity_date		DATE;
   p_gap_date			DATE;

BEGIN
  IF (g_proc_level>=g_debug_level) THEN
     XTR_RISK_DEBUG_PKG.dpush(null,'QRM_PA_CALCULATIONS_P.get_gap_date'); --bug 3236479
  END IF;

   OPEN get_deal_data;
   FETCH get_deal_data INTO p_deal_maturity_date, p_fixed_until_date;
   CLOSE get_deal_data;


   FOR trans_data IN get_transaction_data LOOP
      IF ((trans_data.start_date <= p_ref_date) AND
	  (p_ref_date < trans_data.maturity_date)) THEN
	-- get the maturity date of current transaction
	p_trans_maturity_date := trans_data.maturity_date;
      END IF;
   END LOOP;

   IF (g_proc_level>=g_debug_level) THEN
      XTR_RISK_DEBUG_PKG.dlog('get_gap_date: ' || 'deal no: '||p_deal_no);
   END IF;
   IF (p_initial_basis='FLOAT') THEN  -- floating
      p_gap_date := p_trans_maturity_date;
      IF (g_proc_level>=g_debug_level) THEN
         XTR_RISK_DEBUG_PKG.dlog('get_gap_date: ' || 'initial basis is float');
      END IF;
   ELSIF(p_deal_type='IRS' and p_initial_basis='FIXED') THEN
      p_gap_date := NULL;
      IF (g_proc_level>=g_debug_level) THEN
         XTR_RISK_DEBUG_PKG.dlog('get_gap_date: ' || 'IRS and initial basis is fixed');
      END IF;
   ELSIF ((p_fixed_until_date IS NULL) OR
	  (p_fixed_until_date=p_deal_maturity_date)) THEN  -- fixed
	IF (g_proc_level>=g_debug_level) THEN
	   XTR_RISK_DEBUG_PKG.dlog('get_gap_date: ' || 'fixed until date: '||p_fixed_until_date);
	END IF;
      p_gap_date := p_deal_maturity_date;
   ELSE
      IF (g_proc_level>=g_debug_level) THEN
         XTR_RISK_DEBUG_PKG.dlog('get_gap_date: ' || 'gap date else');
         XTR_RISK_DEBUG_PKG.dlog('get_gap_date: ' || 'fixed until date', p_fixed_until_date);
      END IF;
      OPEN get_others(p_fixed_until_date);
      FETCH get_others INTO p_trans_maturity_date;
	 IF (get_others%FOUND) THEN
            p_gap_date := p_trans_maturity_date;
	 ELSE
	    p_gap_date := p_deal_maturity_date;
	 END IF;
      CLOSE get_others;
   END IF;
   IF (g_proc_level>=g_debug_level) THEN
      XTR_RISK_DEBUG_PKG.dpop(null,'QRM_PA_CALCULATIONS_P.get_gap_date'); --bug 3236479;
   END IF;

   RETURN p_gap_date;
END get_gap_date;



PROCEDURE convert_amounts(p_mds		IN	VARCHAR2,
			  p_ref_date	IN	DATE,
			  p_from_ccy	IN	VARCHAR2,
			  p_to_ccy	IN	VARCHAR2,
			  p_from_amount	IN	NUMBER,
			  p_to_amount	OUT NOCOPY	NUMBER) IS

   p_md_in		XTR_MARKET_DATA_P.md_from_set_in_rec_type;
   p_md_out		XTR_MARKET_DATA_P.md_from_set_out_rec_type;

BEGIN
    IF (g_proc_level>=g_debug_level) THEN
       XTR_RISK_DEBUG_PKG.dpush(null,'QRM_PA_CALCULATIONS.convert_amounts');--bug3236479
    END IF;
    p_md_in.p_md_set_code := p_mds;
    p_md_in.p_source := 'C';
    p_md_in.p_indicator := 'S';
    p_md_in.p_spot_date := p_ref_date;
    p_md_in.p_ccy := p_from_ccy;
    p_md_in.p_contra_ccy := p_to_ccy;
    p_md_in.p_side := 'M';
    XTR_MARKET_DATA_P.get_md_from_set(p_md_in, p_md_out);
    IF (g_proc_level>=g_debug_level) THEN
       XTR_RISK_DEBUG_PKG.dlog('convert_amounts: ' || p_from_ccy||'/'||p_to_ccy||' spot rate:'||p_md_out.p_md_out);
    END IF;
    p_to_amount := p_from_amount*p_md_out.p_md_out;
    IF (g_proc_level>=g_debug_level) THEN
       XTR_RISK_DEBUG_PKG.dlog('convert_amounts: ' || p_from_ccy||' amount:'||p_from_amount);
       XTR_RISK_DEBUG_PKG.dlog('convert_amounts: ' || p_to_ccy||' amount:'||p_to_amount);
       XTR_RISK_DEBUG_PKG.dpop(null,'QRM_PA_CALCULATIONS.convert_amounts');--bug3236479
    END IF;
END convert_amounts;


PROCEDURE remove_expired_deals(p_ref_date DATE) IS

   p_deal_calc_ids	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_deal_nos		XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_transaction_nos	XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   p_counter		NUMBER := 0;


   -- get calculated deals that have matured
   CURSOR get_expired_ids IS
    SELECT deal_calc_id, deal_no, transaction_no
    FROM qrm_deal_calculations
    WHERE (deal_no, transaction_no) IN
	(SELECT deal_no, transaction_no
	 FROM qrm_current_deals_v
	 WHERE nvl(end_date, p_ref_date+1) < p_ref_date);

   -- get calculated deals are no longer open
  /* CURSOR get_old_deal_ids IS
    SELECT deal_calc_id, deal_no, transaction_no
    FROM qrm_deal_calculations
    WHERE (deal_no, transaction_no) NOT IN
	(SELECT deal_no, transaction_no
	 FROM qrm_current_deals_v); Bug 4965436 */

 -- get calculated deals are no longer open
CURSOR get_old_deal_ids IS
SELECT deal_calc_id, deal_no, transaction_no
                 FROM qrm_deal_calculations qdc
WHERE NOT EXISTS ( select 'x'
                   from qrm_current_deals_v qcdv
                   where qcdv.deal_no = qdc.deal_no
                   and qcdv.transaction_no = qdc.transaction_no ) ;


BEGIN
   IF (g_proc_level>=g_debug_level) THEN
      XTR_RISK_DEBUG_PKG.dpush(null,'QRM_PA_CALCULATIONS_P.remove_expired_deals');--bug 3236479
   END IF;
   -- collect calculated matured deals
   FOR cursor_rec IN get_expired_ids LOOP
      p_counter := p_counter + 1;
      p_deal_calc_ids.EXTEND;
      p_deal_calc_ids(p_counter) := cursor_rec.deal_calc_id;
      p_deal_nos.EXTEND;
      p_deal_nos(p_counter) := cursor_rec.deal_no;
      p_transaction_nos.EXTEND;
      p_transaction_nos(p_counter) := cursor_rec.transaction_no;
   END LOOP;

   -- collect calculated closed/cancelled/exercised/etc deals
   FOR cursor_rec IN get_old_deal_ids LOOP
      p_counter := p_counter + 1;
      p_deal_calc_ids.EXTEND;
      p_deal_calc_ids(p_counter) := cursor_rec.deal_calc_id;
      p_deal_nos.EXTEND;
      p_deal_nos(p_counter) := cursor_rec.deal_no;
      p_transaction_nos.EXTEND;
      p_transaction_nos(p_counter) := cursor_rec.transaction_no;
   END LOOP;

   FORALL i IN 1..p_deal_calc_ids.COUNT
      DELETE
      FROM qrm_deal_calculations
      WHERE deal_calc_id=p_deal_calc_ids(i);

   FORALL i IN 1..p_deal_nos.COUNT
      DELETE
      FROM qrm_tb_calculations
      WHERE deal_no=p_deal_nos(i) AND transaction_no=p_transaction_nos(i);

/* -- don't want to delete rows of this table if analysis still exists
   -- because need all instances of company code
   FORALL i IN 1..p_deal_calc_ids.COUNT
      DELETE
      FROM qrm_deals_analyses
      WHERE deal_calc_id=p_deal_calc_ids(i);
*/

   FORALL i IN 1..p_deal_nos.COUNT
      DELETE
      FROM qrm_deal_calc_errors
      WHERE deal_no=p_deal_nos(i) AND transaction_no=p_transaction_nos(i);

   COMMIT;
   IF (g_proc_level>=g_debug_level) THEN
      XTR_RISK_DEBUG_PKG.dpop(null,'QRM_PA_CALCULATIONS_P.remove_expired_deals');--bug3236479
   END IF;
END remove_expired_deals;


/*-------------------------------------------------------------------
FILTER_MEASURE determine whether a particular analysis needs to filter
deals based on its market type given the measure (refer to Bug 2356514 no 1).
If filtering is necessary, the function returns a conditional clause to
be appended in the dynamic SQL WHERE clause, otherwise it will return NULL.

For example:
If the measure is Amount Outstanding, since it's only applicable
to Money Market deals, the function will give a WHERE clause to exclude
Foreign Exchange deals.
Assuming p_market_type_table_alias='v':
The return value='v.market_type='M''.
-------------------------------------------------------------------*/
FUNCTION filter_measure(p_style VARCHAR2,
			p_analysis_name VARCHAR2,
			p_market_type_table_alias VARCHAR2)
	RETURN VARCHAR2 IS

  v_where VARCHAR2(240);
  v_mm_fx VARCHAR2(1);
  v_eq VARCHAR2(1);
  CURSOR get_mm_fx IS
     SELECT l.mm_fx FROM qrm_ana_atts_lookups l, qrm_analysis_atts a
	WHERE a.analysis_name=p_analysis_name
	AND a.history_flag='S'
	AND a.type='M'
	AND l.attribute_name=a.attribute_name;

  CURSOR get_eq IS
    SELECT l.applies_to_eqm FROM qrm_ana_atts_lookups l, qrm_analysis_atts a
       WHERE a.analysis_name = p_analysis_name
       AND a.history_flag= 'S'
       AND a.type='M'
       AND l.attribute_name = a.attribute_name;

BEGIN

   IF (g_proc_level>=g_debug_level) THEN
      XTR_RISK_DEBUG_PKG.dpush(null,'QRM_PA_CALCULATIONS_P.filter_measure');--bug3236479
   END IF;

  --only filter measure for Crosstab and Crosstab with Timebuckets
  IF p_style IN ('X','C') THEN
     OPEN get_mm_fx;
     FETCH get_mm_fx INTO v_mm_fx;
     CLOSE get_mm_fx;

     OPEN get_eq;
     FETCH get_eq INTO v_eq;
     CLOSE get_eq;

     IF v_mm_fx='F' THEN --FX
        IF p_market_type_table_alias IS NULL THEN
           v_where := 'market_type<>''M''';
        ELSE
           v_where := p_market_type_table_alias||'.market_type<>''M''';
        END IF;
     ELSIF v_mm_fx='M' THEN --MM
        IF p_market_type_table_alias IS NULL THEN
           v_where := 'market_type<>''F''';
        ELSE
           v_where := p_market_type_table_alias||'.market_type<>''F''';
        END IF;
     ELSIF v_mm_fx='B' THEN
	IF p_market_type_table_alias IS NULL THEN
	  v_where:= 'MARKET_TYPE<>''F'' AND DEAL_TYPE IN (''BOND'', ''BDO'', ''STOCK'')';
	ELSE
	  v_where:= p_market_type_table_alias||'.market_type<>''F'' AND'||
		    p_market_type_table_alias||'.DEAL_TYPE IN (''BOND'', ''BDO'', ''STOCK'')';
	END IF;
     ELSIF v_mm_fx='O' THEN
        IF p_market_type_table_alias IS NULL THEN
	  v_where:= 'MARKET_TYPE<>''F'' AND DEAL_TYPE NOT IN (''BOND'', ''BDO'')';
	ELSE
	  v_where:= p_market_type_table_alias||'.market_type<>''F'' AND'||
		    p_market_type_table_alias||'.DEAL_TYPE NOT IN (''BOND'', ''BDO'')';
	END IF;
      ELSIF v_mm_fx='N' THEN --Neither
        IF p_market_type_table_alias IS NULL THEN
           v_where := 'market_type<>''F'' AND market_type<>''M''';
        ELSE
           v_where := p_market_type_table_alias||'.market_type<>''F'' AND market_type <>''M''';
        END IF;
     ELSE
        v_where := NULL;
     END IF;
     IF v_eq = 'N' THEN --Does not apply to Stock
        IF v_where is not null then
	   v_where:= v_where || ' AND ';
	END IF;
        IF p_market_type_table_alias IS NULL THEN
           v_where := v_where || 'market_type<>''E''';
        ELSE
           v_where := v_where || p_market_type_table_alias||'.market_type<>''E''';
        END IF;
     END IF;
  ELSE
     v_where := NULL;
  END IF;

  IF (g_proc_level>=g_debug_level) THEN
      XTR_RISK_DEBUG_PKG.dpop(v_where,'QRM_PA_CALCULATIONS_P.filter_measure');--bug3236479
   END IF;

  RETURN v_where;
EXCEPTION
  WHEN OTHERS THEN
     --bug 3236479
     IF (g_proc_level>=g_ERROR_level) THEN
        XTR_RISK_DEBUG_PKG.dlog('EXCEPTION','UNEXPECTED',
	         'QRM_PA_CALCULATIONS_P.FILTER_MEASURE',
		 g_error_level);
     END IF;

     RETURN NULL;
END filter_measure;


END QRM_PA_CALCULATION_P;

/
