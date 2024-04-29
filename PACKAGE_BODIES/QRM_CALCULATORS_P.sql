--------------------------------------------------------
--  DDL for Package Body QRM_CALCULATORS_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QRM_CALCULATORS_P" AS
/* $Header: qrmcalcb.pls 120.5 2004/07/02 16:19:21 jhung ship $ */

PROCEDURE ni_calculator (p_settlement_date DATE,
			 p_maturity_date DATE,
			 p_day_count_basis VARCHAR2,
		--'C'=to calculate considertion,'M'=to calculate maturity
			 p_indicator VARCHAR2,
			 p_ref_amt NUMBER,
			 p_rate_type VARCHAR2,
		--'DR'=discount rate,'Y'=yield rate
			 p_rate NUMBER,
			 p_consideration OUT NOCOPY NUMBER,
			 p_int_amt OUT NOCOPY NUMBER,
			 p_mat_amt OUT NOCOPY NUMBER,
			 p_price OUT NOCOPY NUMBER,
			 p_hold_prd OUT NOCOPY NUMBER,
			 p_adj_hold_prd OUT NOCOPY NUMBER,
			 p_conv_rate OUT NOCOPY NUMBER,
			 p_duration OUT NOCOPY NUMBER,
			 p_mod_dur OUT NOCOPY NUMBER,
			 p_bpv_y OUT NOCOPY NUMBER,
			 p_bpv_d OUT NOCOPY NUMBER,
			 p_dol_dur_y OUT NOCOPY NUMBER,
			 p_dol_dur_d OUT NOCOPY NUMBER,
			 p_convexity OUT NOCOPY NUMBER,
			 p_ccy IN OUT NOCOPY VARCHAR2) IS

  v_yield NUMBER;
  v_day_count NUMBER;
  v_ann_basis NUMBER;
  v_in_pv xtr_mm_covers.presentvalue_in_rec_type;
  v_out_pv xtr_mm_covers.presentvalue_out_rec_type;
  v_in_fv xtr_mm_covers.futurevalue_in_rec_type;
  v_out_fv xtr_mm_covers.futurevalue_out_rec_type;
  v_pvc xtr_md_num_table := xtr_md_num_table();
  v_days xtr_md_num_table := xtr_md_num_table();

BEGIN
  --call the debug package
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpush(null,'QRM_CALCULATORS_P.NI_CALCULATOR');
     xtr_risk_debug_pkg.dlog('ni_calculator: ' || 'p_settlement_date',p_settlement_date);
     xtr_risk_debug_pkg.dlog('ni_calculator: ' || 'p_maturity_date',p_maturity_date);
     xtr_risk_debug_pkg.dlog('ni_calculator: ' || 'p_day_count_basis',p_day_count_basis);
     xtr_risk_debug_pkg.dlog('ni_calculator: ' || 'p_indicator',p_indicator);
     xtr_risk_debug_pkg.dlog('ni_calculator: ' || 'p_ref_amt',p_ref_amt);
     xtr_risk_debug_pkg.dlog('ni_calculator: ' || 'p_rate_type',p_rate_type);
     xtr_risk_debug_pkg.dlog('ni_calculator: ' || 'p_rate',p_rate);
  END IF;

  --need to find day count and ann basis first
  xtr_calc_p.calc_days_run_c(p_settlement_date, p_maturity_date,
			p_day_count_basis, null, v_day_count, v_ann_basis);
  p_hold_prd := p_maturity_date - p_settlement_date;
  p_adj_hold_prd := v_day_count;
  --calc the mat. or cons depending on the indicator
  IF (p_indicator = 'C') THEN
    p_mat_amt := p_ref_amt;
    v_in_pv.p_indicator := p_rate_type;
    v_in_pv.p_future_val := p_ref_amt;
    v_in_pv.p_rate := p_rate;
    v_in_pv.p_day_count := v_day_count;
    v_in_pv.p_annual_basis := v_ann_basis;
    xtr_mm_covers.present_value(v_in_pv, v_out_pv);
    p_consideration := v_out_pv.p_present_val;
  ELSE
    p_consideration := p_ref_amt;
    v_in_fv.p_indicator := p_rate_type;
    v_in_fv.p_present_val := p_ref_amt;
    v_in_fv.p_rate := p_rate;
    v_in_fv.p_day_count := v_day_count;
    v_in_fv.p_annual_basis := v_ann_basis;
    xtr_mm_covers.future_value(v_in_fv, v_out_fv);
    p_mat_amt := v_out_fv.p_future_val;
  END IF;
  p_int_amt := p_mat_amt - p_consideration;
  p_price := (p_consideration/p_mat_amt)*100;

  --calculate Converted Rate
  IF (p_rate_type <> 'Y') THEN
    xtr_rate_conversion.discount_to_yield_rate(p_rate,v_day_count,v_ann_basis,
						p_conv_rate);
  ELSE
    xtr_rate_conversion.yield_to_discount_rate(p_rate,v_day_count,v_ann_basis,
						p_conv_rate);
  END IF;

  --calculate sensitivities, first Duration
  v_pvc.EXTEND;
  v_days.EXTEND;
  v_pvc(1) := 1;
  v_days(1) := v_day_count;
  p_duration := qrm_mm_formulas.duration(v_pvc,v_days,v_ann_basis);
  --calc Mod Dur, first we need yield rate
  IF (p_rate_type <> 'Y') THEN
    v_yield := p_conv_rate;
  ELSE
    v_yield := p_rate;
  END IF;
--xtr_risk_debug_pkg.dlog('p_rate_type',p_rate_type);
  p_mod_dur := qrm_mm_formulas.mod_duration(p_duration,v_yield,1);
  --calc BPV Yield and Discount
  p_bpv_y := qrm_mm_formulas.bpv_yr(p_consideration,p_mod_dur);
  p_bpv_d := qrm_mm_formulas.ni_bpv_dr(p_mat_amt,v_day_count,v_ann_basis);
  --calc Dollar Duration for Yield and Discount
  p_dol_dur_y := qrm_mm_formulas.ni_delta_bpv('DOLLAR',p_bpv_y);
  p_dol_dur_d := qrm_mm_formulas.ni_delta_bpv('DOLLAR',p_bpv_d);
  --calc convexity
  p_convexity := qrm_mm_formulas.ni_fra_convexity(v_day_count,v_yield,v_ann_basis);

  --if currency is null defaults value to XTR Reporting Curr.
  IF (p_ccy IS NULL) THEN
    SELECT param_value INTO p_ccy
	FROM xtr_pro_param WHERE param_name = 'SYSTEM_FUNCTIONAL_CCY';
  END IF;

  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop(null,'QRM_CALCULATORS_P.NI_CALCULATOR');
  END IF;

END ni_calculator;



PROCEDURE fx_calculator(p_date_args    IN     SYSTEM.QRM_DATE_TABLE,
			p_varchar_args IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
			p_num_args     IN OUT NOCOPY xtr_md_num_table) IS

   p_spot_date date := p_date_args(1);
   p_forward_date date := p_date_args(2);

   p_indicator varchar2(1) := p_varchar_args(1);
   p_base_ccy varchar2(15) := p_varchar_args(2);
   p_contra_ccy varchar2(15) := p_varchar_args(3);
   p_currency_quote varchar2(20) := p_varchar_args(4);
   p_interest_quote varchar2(20) := p_varchar_args(5);
   p_base_curve varchar2(20) := p_varchar_args(6);
   p_contra_curve varchar2(20) := p_varchar_args(7);
   p_usd_curve varchar2(20) := p_varchar_args(8);
   p_base_interpolation varchar2(20) := p_varchar_args(9);
   p_contra_interpolation varchar2(20) := p_varchar_args(10);
   p_usd_interpolation varchar2(20) := p_varchar_args(11);
   p_base_quote_usd varchar2(1) := p_varchar_args(12);
   p_contra_quote_usd varchar2(1) := p_varchar_args(13);
   p_base_day_count varchar2(15) := p_varchar_args(14);
   p_contra_day_count varchar2(15) := p_varchar_args(15);
   p_usd_day_count varchar2(15) := p_varchar_args(16);
   p_res_first_base_ccy varchar2(15) := p_varchar_args(17);
   p_res_first_contra_ccy varchar2(15) := p_varchar_args(18);
   p_res_sec_base_ccy varchar2(15) := p_varchar_args(19);
   p_res_sec_contra_ccy varchar2(15) := p_varchar_args(20);

   p_base_ccy_amt number := p_num_args(1);
   p_base_spot_bid number := p_num_args(2);
   p_base_spot_ask number := p_num_args(3);
   p_contra_spot_bid number := p_num_args(4);
   p_contra_spot_ask number := p_num_args(5);
   p_base_int_rate_bid number := p_num_args(6);
   p_base_int_rate_ask number := p_num_args(7);
   p_contra_int_rate_bid number := p_num_args(8);
   p_contra_int_rate_ask number := p_num_args(9);
   p_usd_int_rate_bid number := p_num_args(10);
   p_usd_int_rate_ask number := p_num_args(11);
   p_res_spot_bid number := p_num_args(12);
   p_res_spot_ask number := p_num_args(13);
   p_res_first_rate_bid number := p_num_args(14);
   p_res_first_rate_ask number := p_num_args(15);
   p_res_first_points_bid number := p_num_args(16);
   p_res_first_points_ask number := p_num_args(17);
   p_res_sec_rate_bid number := p_num_args(18);
   p_res_sec_rate_ask number := p_num_args(19);
   p_res_sec_points_bid number := p_num_args(20);
   p_res_sec_points_ask number := p_num_args(21);
   p_res_fwd_rate_bid number := p_num_args(22);
   p_res_fwd_rate_ask number := p_num_args(23);
   p_res_fwd_points_bid number := p_num_args(24);
   p_res_fwd_points_ask number := p_num_args(25);
   p_delta_spot_bid number := p_num_args(26);
   p_delta_spot_ask number := p_num_args(27);
   p_rho_base_bid number := p_num_args(28);
   p_rho_base_ask number := p_num_args(29);
   p_rho_contra_bid number := p_num_args(30);
   p_rho_contra_ask number := p_num_args(31);

    p_curve_types SYSTEM.QRM_VARCHAR_TABLE;
    p_curve_codes SYSTEM.QRM_VARCHAR_TABLE;
    p_rate_types SYSTEM.QRM_VARCHAR_TABLE;
    p_base_currencies SYSTEM.QRM_VARCHAR_TABLE;
    p_contra_currencies SYSTEM.QRM_VARCHAR_TABLE;
    p_quote_bases SYSTEM.QRM_VARCHAR_TABLE;
    p_interp_methods SYSTEM.QRM_VARCHAR_TABLE;
    p_data_sides SYSTEM.QRM_VARCHAR_TABLE;
    p_day_count_bases SYSTEM.QRM_VARCHAR_TABLE;
    p_spot_quote_bases SYSTEM.QRM_VARCHAR_TABLE;

    p_rates_table xtr_md_num_table;

    p_day_count_base number;
    p_day_count_contra number;
    p_day_count_usd number;
    p_year_basis_base number;
    p_year_basis_contra number;
    p_year_basis_usd number;

    p_bid_rate_comm number;
    p_ask_rate_comm number;
    p_bid_rate_base number;
    p_ask_rate_base number;
    p_ccy varchar2(15);


    -- boolean for checking whether usd row is required
    -- true if neither currency is USD
    p_neither_usd boolean := (p_base_ccy<>'USD' AND p_contra_ccy<>'USD');

    -- overwrite system quotation basis against usd when one currency is 'USD'
    -- want to overwrite for FX Forward
    p_ow_spot_rates boolean := true;

    md_in_rec XTR_MARKET_DATA_P.md_from_curve_in_rec_type;
    md_out_rec XTR_MARKET_DATA_P.md_from_curve_out_rec_type;

    p_spot_rates xtr_md_num_table := xtr_md_num_table();
    p_forward_rates xtr_md_num_table := xtr_md_num_table();

    df_in_rec XTR_RATE_CONVERSION.df_in_rec_type;
    df_out_rec XTR_RATE_CONVERSION.df_out_rec_type;
    p_int_rates xtr_md_num_table;
    p_day_counts SYSTEM.QRM_VARCHAR_TABLE;
    p_dis_factors xtr_md_num_table := xtr_md_num_table();

    p_delta xtr_md_num_table;
    p_rho xtr_md_num_table;

BEGIN
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dpush(null,'QRM_CALCULATORS_P.fx_calculator');
END IF;

 IF fnd_msg_pub.count_msg > 0 THEN
    fnd_msg_pub.Initialize;
 END IF;

-- Use Default Curves
-- Do preparation work
 IF (p_indicator = 'D') THEN
    IF (g_proc_level>=g_debug_level) THEN
       xtr_risk_debug_pkg.dpush('fx_calculator: ' || 'Calculation Based On Defaults');
    END IF;

    -- ** Default fields ** --
    p_base_interpolation := 'DEFAULT';
    p_contra_interpolation := 'DEFAULT';
    p_usd_interpolation := 'DEFAULT';
    p_interest_quote := 'BID/ASK';
    p_base_day_count := 'ACTUAL/ACTUAL';
    p_contra_day_count := 'ACTUAL/ACTUAL';
    p_usd_day_count := 'ACTUAL/ACTUAL';
    --  ****************** --

    p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD','YIELD','YIELD');
    p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_base_ccy,p_contra_ccy,'USD');

    p_curve_codes := get_curves_from_base(p_curve_types,p_base_currencies,
						p_contra_currencies);
    p_base_curve := p_curve_codes(1);
    p_contra_curve := p_curve_codes(2);
    p_usd_curve := null;
    p_usd_interpolation := null;

    IF (g_proc_level>=g_debug_level) THEN
       xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'base curve', p_base_curve);
       xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'contra curve', p_contra_curve);
    END IF;
    -- if neither currency is USD, then a USD curve is needed
    if (p_neither_usd) then
	p_usd_curve := p_curve_codes(3);
	p_usd_interpolation := 'DEFAULT';
	IF (g_proc_level>=g_debug_level) THEN
	   xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'usd required', p_neither_usd);
	   xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'usd curve', p_usd_curve);
	END IF;
    end if;

    -- calculate Rates
	-- this follows the calculator table across each row
        -- first do Spot Rates
    -- get quotation basis against usd defined in Current System Rates
    p_spot_quote_bases := get_spot_quotation_basis(p_base_ccy, p_contra_ccy,
						   p_ow_spot_rates);
    p_base_quote_usd := p_spot_quote_bases(1);
    p_contra_quote_usd := p_spot_quote_bases(2);
    if (p_base_ccy = 'USD' AND p_contra_ccy <> 'USD') then
	p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT','SPOT');
	p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_contra_ccy, p_contra_ccy);
	p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_contra_quote_usd,
					   p_contra_quote_usd);
	p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK');
    elsif (p_contra_ccy = 'USD' AND p_base_ccy <> 'USD') then
	p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT','SPOT');
	p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_base_ccy, p_base_ccy);
	p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_base_quote_usd,p_base_quote_usd);
	p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK');
    elsif (p_base_ccy <> 'USD' AND p_contra_ccy <> 'USD') then
    	p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT','SPOT','SPOT','SPOT');
    	p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_base_ccy,p_base_ccy,
					   p_contra_ccy, p_contra_ccy);
    	p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_base_quote_usd, p_base_quote_usd,
				       p_contra_quote_usd,p_contra_quote_usd);
    	p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK','BID','ASK');
    end if;

    p_rates_table := get_rates_from_base(p_rate_types, p_base_currencies,
					 p_contra_currencies, p_quote_bases,
					 p_interp_methods, p_data_sides,
					 p_day_count_bases,p_interest_quote,
					 p_currency_quote,p_spot_date,
					 p_forward_date);

    if (p_base_ccy = 'USD' AND p_contra_ccy <> 'USD') then
	p_base_spot_bid := 1;
	p_base_spot_ask := 1;
    	p_contra_spot_bid := p_rates_table(1);
    	p_contra_spot_ask := p_rates_table(2);
    elsif (p_contra_ccy = 'USD' AND p_base_ccy <> 'USD') then
	p_base_spot_bid := p_rates_table(1);
	p_base_spot_ask := p_rates_table(2);
	p_contra_spot_bid := 1;
	p_contra_spot_ask := 1;
    elsif (p_neither_usd) then
	p_base_spot_bid := p_rates_table(1);
	p_base_spot_ask := p_rates_table(2);
    	p_contra_spot_bid := p_rates_table(3);
    	p_contra_spot_ask := p_rates_table(4);
    end if;

    -- now do Interest Rates
    p_rate_types.delete;
    p_base_currencies.delete;
    p_data_sides.delete;
    p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE('DEFAULT','DEFAULT',
					  'DEFAULT','DEFAULT');
    p_quote_bases := null;
    p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD','YIELD','YIELD','YIELD');
    p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_base_ccy, p_base_ccy,
					   p_contra_ccy, p_contra_ccy);
    p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK','BID','ASK');
    p_day_count_bases := SYSTEM.QRM_VARCHAR_TABLE(p_base_day_count, p_base_day_count,
					   p_contra_day_count,
					   p_contra_day_count);
    if (p_neither_usd) then
	p_rate_types.extend(2);
        p_rate_types(5) := 'YIELD';
        p_rate_types(6) := 'YIELD';
	p_interp_methods.extend(2);
	p_interp_methods(5) := 'DEFAULT';
	p_interp_methods(6) := 'DEFAULT';
	p_base_currencies.extend(2);
        p_base_currencies(5) := 'USD';
        p_base_currencies(6) := 'USD';
	p_data_sides.extend(2);
	p_data_sides(5) := 'BID';
	p_data_sides(6) := 'ASK';
	p_day_count_bases.extend(2);
        p_day_count_bases(5) := p_usd_day_count;
        p_day_count_bases(6) := p_usd_day_count;
    end if;


    p_rates_table := get_rates_from_base(p_rate_types, p_base_currencies,
					 p_contra_currencies, p_quote_bases,
					 p_interp_methods, p_data_sides,
					 p_day_count_bases,p_interest_quote,
					 p_currency_quote,p_spot_date,
					 p_forward_date);
    p_base_int_rate_bid := p_rates_table(1);
    p_base_int_rate_ask := p_rates_table(2);
    p_contra_int_rate_bid := p_rates_table(3);
    p_contra_int_rate_ask := p_rates_table(4);

    if (p_neither_usd) then
	p_usd_int_rate_bid := p_rates_table(5);
        p_usd_int_rate_ask := p_rates_table(6);
    else
	p_usd_day_count := null;
    	p_usd_int_rate_bid := null;
    	p_usd_int_rate_ask := null;
    end if;

    for i IN 1..p_rates_table.count LOOP
       IF (g_proc_level>=g_debug_level) THEN
          xtr_risk_debug_pkg.dlog('fx_calculator: ' || p_rate_types(i),p_rates_table(i));
       END IF;
    END LOOP;
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop('fx_calculator: ' || 'Calculation Based On Defaults');
  END IF;

  ELSIF (p_indicator = 'C') then
     IF (g_proc_level>=g_debug_level) THEN
        xtr_risk_debug_pkg.dpush('fx_calculator: ' || 'Calculation Based On Curves');
     END IF;

    -- ** Default fields ** --
    p_base_day_count := 'ACTUAL/ACTUAL';
    p_contra_day_count := 'ACTUAL/ACTUAL';
    p_usd_day_count := 'ACTUAL/ACTUAL';
    --  ****************** --

     -- GET DEFAULT CURVES
     if (p_base_curve IS null) then
	p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
	p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_base_ccy);
        p_curve_codes := get_curves_from_base(p_curve_types,
					      p_base_currencies,
					      p_contra_currencies);
	p_base_curve := p_curve_codes(1);
     end if;
     if (p_contra_curve IS null) then
	p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
	p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_contra_ccy);
        p_curve_codes := get_curves_from_base(p_curve_types,
					      p_base_currencies,
					      p_contra_currencies);
	p_contra_curve := p_curve_codes(1);
    end if;

    -- USD curve is required, but it is null
    -- get default USD curve
    if (p_neither_usd) then
	if (p_usd_curve IS null) then
	    p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
	    p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE('USD');
	    p_curve_codes := get_curves_from_base(p_curve_types,
					      p_base_currencies,
					      p_contra_currencies);
	    p_usd_curve := p_curve_codes(1);
	end if;
    -- if one ccy is USD, set usd row curve/interp to null
    else
	p_usd_curve := null;
	p_usd_interpolation := null;
    end if;

  -- GET DEFAULT RATES based on CURVES
    -- first do SPOT RATES
    p_curve_codes := null;
    p_base_currencies := null;
    -- get quotation basis against usd defined in Current System Rates
    p_spot_quote_bases := get_spot_quotation_basis(p_base_ccy, p_contra_ccy,
						   p_ow_spot_rates);
    p_base_quote_usd := p_spot_quote_bases(1);
    p_contra_quote_usd := p_spot_quote_bases(2);
    if (p_base_ccy = 'USD' AND p_contra_ccy <> 'USD') then
    	p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT','SPOT');
	p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_contra_ccy, p_contra_ccy);
	p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_contra_quote_usd,
					   p_contra_quote_usd);
  	p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK');
    elsif (p_base_ccy <> 'USD' AND p_contra_ccy = 'USD') then
	p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT','SPOT');
	p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_base_ccy, p_base_ccy);
	p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_base_quote_usd, p_base_quote_usd);
	p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK');
    elsif (p_neither_usd) then
	p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT','SPOT','SPOT','SPOT');
    	p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_base_ccy,p_base_ccy,
					   p_contra_ccy,p_contra_ccy);
    	p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_base_quote_usd, p_base_quote_usd,
				      p_contra_quote_usd,p_contra_quote_usd);
	p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK','BID','ASK');
    end if;

    p_rates_table := get_rates_from_curves(p_rate_types,p_curve_codes,
				           p_base_currencies,
					   p_contra_currencies,
					   p_quote_bases,
					   p_interp_methods,
					   p_data_sides,
					   p_day_count_bases,
					   p_interest_quote,
					   p_currency_quote,
					   p_spot_date, p_forward_date);
    if (p_contra_ccy = 'USD') then
        p_base_spot_bid := p_rates_table(1);
        p_base_spot_ask := p_rates_table(2);
	p_contra_spot_bid := 1;
	p_contra_spot_ask := 1;
    elsif (p_base_ccy = 'USD') then
	p_base_spot_bid := 1;
	p_base_spot_ask := 1;
	p_contra_spot_bid := p_rates_table(1);
	p_contra_spot_ask := p_rates_table(2);
    elsif (p_neither_usd) then
        p_base_spot_bid := p_rates_table(1);
        p_base_spot_ask := p_rates_table(2);
	p_contra_spot_bid := p_rates_table(3);
	p_contra_spot_ask := p_rates_table(4);
    end if;

    -- now get INTEREST RATES
    p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD','YIELD','YIELD','YIELD');
    p_curve_codes := SYSTEM.QRM_VARCHAR_TABLE(p_base_curve,p_base_curve,
				       p_contra_curve,p_contra_curve);
    p_base_currencies.delete;
    p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_base_ccy,p_base_ccy,
					   p_contra_ccy,p_contra_ccy);
    p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE(p_base_interpolation,
	p_base_interpolation, p_contra_interpolation, p_contra_interpolation);

    p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK','BID','ASK');
    p_day_count_bases := SYSTEM.QRM_VARCHAR_TABLE(p_base_day_count,p_base_day_count,
				p_contra_day_count,p_contra_day_count);
    p_quote_bases := null;
    if (p_neither_usd) then
	p_rate_types.extend(2);
	p_rate_types(5) := 'YIELD';
        p_rate_types(6) := 'YIELD';
	p_curve_codes.extend(2);
        p_curve_codes(5) := p_usd_curve;
     	p_curve_codes(6) := p_usd_curve;
	p_base_currencies.extend(2);
	p_base_currencies(5) := 'USD';
	p_base_currencies(6) := 'USD';
	p_interp_methods.extend(2);
        p_interp_methods(5) := p_usd_interpolation;
        p_interp_methods(6) := p_usd_interpolation;
	p_data_sides.extend(2);
        p_data_sides(5) := 'BID';
        p_data_sides(6) := 'ASK';
	p_day_count_bases.extend(2);
        p_day_count_bases(5) := p_usd_day_count;
    	p_day_count_bases(6) := p_usd_day_count;
    end if;

    p_rates_table := get_rates_from_curves(p_rate_types,p_curve_codes,
					   p_base_currencies,
					   p_contra_currencies,
					   p_quote_bases,p_interp_methods,
					   p_data_sides,p_day_count_bases,
					   p_interest_quote,p_currency_quote,
					   p_spot_date,
					   p_forward_date);
    p_base_int_rate_bid := p_rates_table(1);
    p_base_int_rate_ask := p_rates_table(2);
    p_contra_int_rate_bid := p_rates_table(3);
    p_contra_int_rate_ask := p_rates_table(4);
    if (p_neither_usd) then
	p_usd_int_rate_bid := p_rates_table(5);
        p_usd_int_rate_ask := p_rates_table(6);
    else
	p_usd_day_count := null;
    	p_usd_int_rate_bid := null;
    	p_usd_int_rate_ask := null;
    end if;
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop('fx_calculator: ' || 'Calculation Based On Curves');
  END IF;

  -- 'Calculate Based On Rates' button pressed
  ELSIF (p_indicator = 'R') then
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpush('fx_calculator: ' || 'Calculation Based On Rates');
  END IF;
     -- if a spot rate is missing, go to base(defaults) section
     if (p_base_spot_bid IS null) then
	if (p_base_ccy <> 'USD') then
	    p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT');
	    p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_base_ccy);
	    p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_base_quote_usd);
	    p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID');
    	    p_rates_table := get_rates_from_curves(p_rate_types,
						p_curve_codes,
						p_base_currencies,
					   	p_contra_currencies,
						p_quote_bases,
						p_interp_methods,
					   	p_data_sides,
						p_day_count_bases,
						p_interest_quote,
					   	p_currency_quote,
					   	p_spot_date, p_forward_date);
    	    p_base_spot_bid := p_rates_table(1);
	else
	    p_base_spot_bid := 1;
	end if;
	-- get corresponding base ccy curve

     end if;
     if (p_base_spot_ask IS null) then
	if (p_base_ccy <> 'USD') then
	    p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT');
	    p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_base_ccy);
	    p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_base_quote_usd);
	    p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('ASK');
    	    p_rates_table := get_rates_from_curves(p_rate_types,
						p_curve_codes,
						p_base_currencies,
					   	p_contra_currencies,
						p_quote_bases,
						p_interp_methods,
					   	p_data_sides,
						p_day_count_bases,
						p_interest_quote,
					   	p_currency_quote,
					   	p_spot_date, p_forward_date);
    	    p_base_spot_ask := p_rates_table(1);
	else
	    p_base_spot_ask := 1;
	end if;
     end if;
     if (p_contra_spot_bid IS null) then
	if (p_contra_ccy <> 'USD') then
	    p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT');
	    p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_contra_ccy);
	    p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_contra_quote_usd);
	    p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID');
    	    p_rates_table := get_rates_from_curves(p_rate_types,
						p_curve_codes,
						p_base_currencies,
					   	p_contra_currencies,
						p_quote_bases,
						p_interp_methods,
					   	p_data_sides,
						p_day_count_bases,
						p_interest_quote,
					   	p_currency_quote,
					   	p_spot_date, p_forward_date);
    	    p_contra_spot_bid := p_rates_table(1);
	else
	    p_contra_spot_bid := 1;
	end if;
     end if;
     if (p_contra_spot_ask IS null) then
	if (p_contra_ccy <> 'USD') then
	    p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT');
	    p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_contra_ccy);
	    p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_contra_quote_usd);
	    p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('ASK');
    	    p_rates_table := get_rates_from_curves(p_rate_types,
						p_curve_codes,
						p_base_currencies,
					   	p_contra_currencies,
						p_quote_bases,
						p_interp_methods,
					   	p_data_sides,
						p_day_count_bases,
						p_interest_quote,
					   	p_currency_quote,
					   	p_spot_date, p_forward_date);
    	    p_contra_spot_ask := p_rates_table(1);
	else
	    p_contra_spot_ask := 1;
	end if;
     end if;

     -- if INTEREST RATES are missing, first check if curve section is filled
     -- if so, use curve;
     -- else, go to base(defaults) section and default curve in curves section
     if (p_base_int_rate_bid IS null) then
	p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
	p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_base_ccy);
 	p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID');
	p_day_count_bases := SYSTEM.QRM_VARCHAR_TABLE(p_base_day_count);
	-- if curve section is null, go to defaults
	if (p_base_curve IS null) then
	    p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
	    p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE('DEFAULT');
	    p_curve_codes := get_curves_from_base(p_curve_types,
					      p_base_currencies,
					      p_contra_currencies);
	    -- calculate rate
	    p_rates_table := get_rates_from_curves(p_rate_types,
		p_curve_codes,p_base_currencies,p_contra_currencies,
		p_quote_bases,p_interp_methods,p_data_sides,
		p_day_count_bases,p_interest_quote,p_currency_quote,
		p_spot_date,p_forward_date);
	   -- default curves section
	   p_base_curve := p_curve_codes(1);
	   IF (g_proc_level>=g_debug_level) THEN
	      xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'defaulted base curve', p_base_curve);
	   END IF;
	   p_base_interpolation := p_interp_methods(1);
	else
	-- curve section not null, use curve
	    p_curve_codes := SYSTEM.QRM_VARCHAR_TABLE(p_base_curve);
	    p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE(p_base_interpolation);
	    -- calculate rate
	    p_rates_table := get_rates_from_curves(p_rate_types,
		p_curve_codes,p_base_currencies,p_contra_currencies,
		p_quote_bases,p_interp_methods,p_data_sides,
		p_day_count_bases,p_interest_quote,p_currency_quote,
		p_spot_date,p_forward_date);
	end if;
	p_base_int_rate_bid := p_rates_table(1);
	IF (g_proc_level>=g_debug_level) THEN
	   xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'defaulted base bid rate',p_base_int_rate_bid);
	END IF;
     end if;
     if (p_base_int_rate_ask IS null) then
	p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
	p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_base_ccy);
 	p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('ASK');
	p_day_count_bases := SYSTEM.QRM_VARCHAR_TABLE(p_base_day_count);
	-- if curve section is null, go to defaults
	if (p_base_curve IS null) then
	    p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
	    p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE('DEFAULT');
	    p_curve_codes := get_curves_from_base(p_curve_types,
					      p_base_currencies,
					      p_contra_currencies);
	    -- calculate rate
	    p_rates_table := get_rates_from_curves(p_rate_types,
		p_curve_codes,p_base_currencies,p_contra_currencies,
		p_quote_bases,p_interp_methods,p_data_sides,
		p_day_count_bases,p_interest_quote,p_currency_quote,
		p_spot_date,p_forward_date);
	   -- default curves section
	   p_base_curve := p_curve_codes(1);
	   IF (g_proc_level>=g_debug_level) THEN
	      xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'defaulted base curve', p_base_curve);
	   END IF;
	   p_base_interpolation := p_interp_methods(1);
	else
	-- curve section not null, use curve
	    p_curve_codes := SYSTEM.QRM_VARCHAR_TABLE(p_base_curve);
	    p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE(p_base_interpolation);
	    p_rates_table := get_rates_from_curves(p_rate_types,
		p_curve_codes,p_base_currencies,p_contra_currencies,
		p_quote_bases,p_interp_methods,p_data_sides,
		p_day_count_bases,p_interest_quote,p_currency_quote,
		p_spot_date,p_forward_date);
	end if;
	p_base_int_rate_ask := p_rates_table(1);
	IF (g_proc_level>=g_debug_level) THEN
	   xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'defaulted base ask rate',p_base_int_rate_ask);
	END IF;
     end if;
     if (p_contra_int_rate_bid IS null) then
	p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
	p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_contra_ccy);
 	p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID');
	p_day_count_bases := SYSTEM.QRM_VARCHAR_TABLE(p_contra_day_count);
	-- if curve section is null, go to defaults
	if (p_contra_curve IS null) then
	    p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
	    p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE('DEFAULT');
	    p_curve_codes := get_curves_from_base(p_curve_types,
					      p_base_currencies,
					      p_contra_currencies);
	    -- calculate rate
	    p_rates_table := get_rates_from_curves(p_rate_types,
		p_curve_codes,p_base_currencies,p_contra_currencies,
		p_quote_bases,p_interp_methods,p_data_sides,
		p_day_count_bases,p_interest_quote,p_currency_quote,
		p_spot_date,p_forward_date);
	   -- default curves section
	   p_contra_curve := p_curve_codes(1);
	   IF (g_proc_level>=g_debug_level) THEN
	      xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'defaulted contra curve', p_contra_curve);
	   END IF;
	   p_contra_interpolation := p_interp_methods(1);
	else
	-- curve section not null, use curve
	    p_curve_codes := SYSTEM.QRM_VARCHAR_TABLE(p_contra_curve);
	    p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE(p_contra_interpolation);
	    p_rates_table := get_rates_from_curves(p_rate_types,
		p_curve_codes,p_base_currencies,p_contra_currencies,
		p_quote_bases,p_interp_methods,p_data_sides,
		p_day_count_bases,p_interest_quote,p_currency_quote,
		p_spot_date,p_forward_date);
	end if;
	p_contra_int_rate_bid := p_rates_table(1);
	IF (g_proc_level>=g_debug_level) THEN
	   xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'defaulted contra bid rate',p_contra_int_rate_bid);
	END IF;
     end if;
     if (p_contra_int_rate_ask IS null) then
	p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
	p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_contra_ccy);
 	p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('ASK');
	p_day_count_bases := SYSTEM.QRM_VARCHAR_TABLE(p_contra_day_count);
	-- if curve section is null, go to defaults
	if (p_contra_curve IS null) then
	    p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
	    p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE('DEFAULT');
	    p_curve_codes := get_curves_from_base(p_curve_types,
					      p_base_currencies,
					      p_contra_currencies);
	    -- calculate rate
	    p_rates_table := get_rates_from_curves(p_rate_types,
		p_curve_codes,p_base_currencies,p_contra_currencies,
		p_quote_bases,p_interp_methods,p_data_sides,
		p_day_count_bases,p_interest_quote,p_currency_quote,
		p_spot_date,p_forward_date);
	   -- default curves section
	   p_contra_curve := p_curve_codes(1);
	   IF (g_proc_level>=g_debug_level) THEN
	      xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'defaulted contra curve', p_contra_curve);
	   END IF;
	   p_contra_interpolation := p_interp_methods(1);
	else
	-- curve section not null, use curve
	    p_curve_codes := SYSTEM.QRM_VARCHAR_TABLE(p_contra_curve);
	    p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE(p_contra_interpolation);
	    p_rates_table := get_rates_from_curves(p_rate_types,
		p_curve_codes,p_base_currencies,p_contra_currencies,
		p_quote_bases,p_interp_methods,p_data_sides,
		p_day_count_bases,p_interest_quote,p_currency_quote,
		p_spot_date,p_forward_date);
	end if;
	p_contra_int_rate_ask := p_rates_table(1);
	IF (g_proc_level>=g_debug_level) THEN
	   xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'defaulted contra ask rate',p_contra_int_rate_ask);
	END IF;
     end if;
     if (p_neither_usd) then
	 if (p_usd_int_rate_bid IS null) then
		p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
		p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE('USD');
 		p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID');
		p_day_count_bases := SYSTEM.QRM_VARCHAR_TABLE(p_usd_day_count);
		-- if curve section is null, go to defaults
		if (p_usd_curve IS null) then
	    	   p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
	    	   p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE('DEFAULT');
	    	   p_curve_codes := get_curves_from_base(p_curve_types,
					      p_base_currencies,
					      p_contra_currencies);
	    	   -- calculate rate
	    	   p_rates_table := get_rates_from_curves(p_rate_types,
			p_curve_codes,p_base_currencies,p_contra_currencies,
			p_quote_bases,p_interp_methods,p_data_sides,
			p_day_count_bases,p_interest_quote,p_currency_quote,
			p_spot_date,p_forward_date);
	   	   -- default curves section
	   	   p_usd_curve := p_curve_codes(1);
	   	   IF (g_proc_level>=g_debug_level) THEN
	   	      xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'defaulted usd curve', p_usd_curve);
	   	   END IF;
	   	   p_usd_interpolation := p_interp_methods(1);
		else
		-- curve section not null, use curve
	    	   p_curve_codes := SYSTEM.QRM_VARCHAR_TABLE(p_usd_curve);
	    	   p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE(p_usd_interpolation);
	    	   p_rates_table := get_rates_from_curves(p_rate_types,
		   	p_curve_codes,p_base_currencies,p_contra_currencies,
		   	p_quote_bases,p_interp_methods,p_data_sides,
			p_day_count_bases,p_interest_quote,p_currency_quote,
			p_spot_date,p_forward_date);
		end if;
		p_usd_int_rate_bid := p_rates_table(1);
		IF (g_proc_level>=g_debug_level) THEN
		   xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'defaulted usd bid rate',p_usd_int_rate_bid);
		END IF;
     	 end if;
         if (p_usd_int_rate_ask IS null) then
		p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
		p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE('USD');
 		p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('ASK');
		p_day_count_bases := SYSTEM.QRM_VARCHAR_TABLE(p_usd_day_count);
		-- if curve section is null, go to defaults
		if (p_usd_curve IS null) then
	    	   p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
	    	   p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE('DEFAULT');
	    	   p_curve_codes := get_curves_from_base(p_curve_types,
					      p_base_currencies,
					      p_contra_currencies);
	    	   -- calculate rate
	    	   p_rates_table := get_rates_from_curves(p_rate_types,
			p_curve_codes,p_base_currencies,p_contra_currencies,
			p_quote_bases,p_interp_methods,p_data_sides,
			p_day_count_bases,p_interest_quote,p_currency_quote,
			p_spot_date,p_forward_date);
	   	   -- default curves section
	   	   p_usd_curve := p_curve_codes(1);
	   	   IF (g_proc_level>=g_debug_level) THEN
	   	      xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'defaulted usd curve',p_usd_curve);
	   	   END IF;
   		p_usd_interpolation := p_interp_methods(1);
		else
		-- curve section not null, use curve
	    	   p_curve_codes := SYSTEM.QRM_VARCHAR_TABLE(p_usd_curve);
	    	   p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE(p_usd_interpolation);
	    	   p_rates_table := get_rates_from_curves(p_rate_types,
		   	p_curve_codes,p_base_currencies,p_contra_currencies,
		   	p_quote_bases,p_interp_methods,p_data_sides,
			p_day_count_bases,p_interest_quote,p_currency_quote,
			p_spot_date,p_forward_date);
		end if;
		p_usd_int_rate_ask := p_rates_table(1);
		IF (g_proc_level>=g_debug_level) THEN
		   xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'defaulted USD ask rate',p_usd_int_rate_ask);
		END IF;
     	end if;
     else
	p_usd_int_rate_bid := null;
	p_usd_int_rate_ask := null;
	p_usd_day_count := null;
     end if;
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop('fx_calculator: ' || 'Calculation Based On Rates');
  END IF;
  END IF;

 -- ***END OF DEFAULTING SECTION ***--
 -- ***RESULTS ***--
 -- now on to calculating results
   	XTR_CALC_P.calc_days_run_c(p_spot_date, p_forward_date,
		p_usd_day_count, null, p_day_count_usd, p_year_basis_usd);
    	XTR_CALC_P.calc_days_run_c(p_spot_date, p_forward_date,
		p_base_day_count, null, p_day_count_base, p_year_basis_base);
     	XTR_CALC_P.calc_days_run_c(p_spot_date, p_forward_date,
		p_contra_day_count, null, p_day_count_contra,
		p_year_basis_contra);

	if (NOT p_neither_usd) then
		if (p_base_ccy = 'USD') then
			p_base_spot_bid := 1;
			p_base_spot_ask := 1;
			p_usd_int_rate_bid := p_base_int_rate_bid;
			p_usd_int_rate_ask := p_base_int_rate_ask;
			p_day_count_usd := p_day_count_base;
			p_year_basis_usd := p_year_basis_base;
		elsif (p_contra_ccy = 'USD') then
			p_contra_spot_bid := 1;
			p_contra_spot_ask := 1;
			p_usd_int_rate_bid := p_contra_int_rate_bid;
			p_usd_int_rate_ask := p_contra_int_rate_ask;
			p_day_count_usd := p_day_count_contra;
			p_year_basis_usd := p_year_basis_contra;
		end if;
	end if;

   	--cross spot rate
   	p_spot_rates.extend;
   	p_spot_rates.extend;
   	p_spot_rates := xtr_fx_formulas.fx_spot_rate_cv(
		p_CURRENCY_CONTRA	  => p_contra_ccy,
		p_CURRENCY_BASE		  => p_base_ccy,
		p_RATE_CONTRA_BID	  => p_contra_spot_bid,
		p_RATE_CONTRA_ASK	  => p_contra_spot_ask,
		p_RATE_BASE_BID		  => p_base_spot_bid,
		p_RATE_BASE_ASK		  => p_base_spot_ask,
		p_QUOTATION_BASIS_CONTRA  => p_contra_quote_usd,
		p_QUOTATION_BASIS_BASE	  => p_base_quote_usd);
   	p_res_spot_bid := p_spot_rates(1);
   	p_res_spot_ask := p_spot_rates(2);


     if (p_neither_usd) then
   	-- forward rates
   	p_forward_rates.extend;
   	p_forward_rates.extend;
     	-- USD/Base Ccy or Base Ccy/USD
     	if (p_base_quote_usd = 'C') then
	   -- USD/Base Ccy
           p_forward_rates := xtr_fx_formulas.fx_forward_rate_cv(
		p_SPOT_RATE_BASE_BID   => null,
		p_SPOT_RATE_BASE_ASK   => null,
		p_SPOT_RATE_CONTRA_BID => p_base_spot_bid,
		p_SPOT_RATE_CONTRA_ASK => p_base_spot_ask,
		p_BASE_CURR_INT_RATE_BID   => null,
		p_BASE_CURR_INT_RATE_ASK   => null,
		p_CONTRA_CURR_INT_RATE_BID => p_base_int_rate_bid,
		p_CONTRA_CURR_INT_RATE_ASK => p_base_int_rate_ask,
		p_USD_CURR_INT_RATE_BID    => p_usd_int_rate_bid,
		p_USD_CURR_INT_RATE_ASK    => p_usd_int_rate_ask,
		p_DAY_COUNT_BASE	   => null,
		p_DAY_COUNT_CONTRA	   => p_day_count_base,
		p_DAY_COUNT_USD		   => p_day_count_usd,
		p_ANNUAL_BASIS_BASE	   => null,
		p_ANNUAL_BASIS_CONTRA	   => p_year_basis_base,
		p_ANNUAL_BASIS_USD	   => p_year_basis_usd,
		p_CURRENCY_BASE		   => 'USD',
		p_CURRENCY_CONTRA	   => p_base_ccy,
		p_QUOTATION_BASIS_BASE	   => null,
		p_QUOTATION_BASIS_CONTRA   => p_base_quote_usd);
	   p_res_first_base_ccy := 'USD';
	   p_res_first_contra_ccy := p_base_ccy;
     	else
	  -- Base Ccy/USD
          p_forward_rates := xtr_fx_formulas.fx_forward_rate_cv(
		p_SPOT_RATE_BASE_BID	   => p_base_spot_bid,
		p_SPOT_RATE_BASE_ASK	   => p_base_spot_ask,
		p_SPOT_RATE_CONTRA_BID 	   => null,
		p_SPOT_RATE_CONTRA_ASK 	   => null,
		p_BASE_CURR_INT_RATE_BID   => p_base_int_rate_bid,
		p_BASE_CURR_INT_RATE_ASK   => p_base_int_rate_ask,
		p_CONTRA_CURR_INT_RATE_BID => null,
		p_CONTRA_CURR_INT_RATE_ASK => null,
		p_USD_CURR_INT_RATE_BID    => p_usd_int_rate_bid,
		p_USD_CURR_INT_RATE_ASK    => p_usd_int_rate_ask,
		p_DAY_COUNT_BASE	   => p_day_count_base,
		p_DAY_COUNT_CONTRA	   => null,
		p_DAY_COUNT_USD		   => p_day_count_usd,
		p_ANNUAL_BASIS_BASE	   => p_year_basis_base,
		p_ANNUAL_BASIS_CONTRA	   => null,
		p_ANNUAL_BASIS_USD	   => p_year_basis_usd,
		p_CURRENCY_BASE	   	   => p_base_ccy,
		p_CURRENCY_CONTRA	   => 'USD',
		p_QUOTATION_BASIS_BASE     => p_base_quote_usd,
		p_QUOTATION_BASIS_CONTRA   => null);
	   p_res_first_base_ccy := p_base_ccy;
	   p_res_first_contra_ccy := 'USD';
        end if;
     	p_res_first_rate_bid := p_forward_rates(1);
     	p_res_first_rate_ask := p_forward_rates(2);
     	p_res_first_points_bid := p_res_first_rate_bid - p_base_spot_bid;
     	p_res_first_points_ask := p_res_first_rate_ask - p_base_spot_ask;

    	-- Contra Ccy/USD or USD/Contra Ccy

     	if (p_contra_quote_usd = 'B') then
	    -- Contra Ccy/USD
     	    p_forward_rates := xtr_fx_formulas.fx_forward_rate_cv(
		p_SPOT_RATE_BASE_BID	   => p_contra_spot_bid,
		p_SPOT_RATE_BASE_ASK	   => p_contra_spot_ask,
		p_SPOT_RATE_CONTRA_BID 	   => null,
		p_SPOT_RATE_CONTRA_ASK 	   => null,
		p_BASE_CURR_INT_RATE_BID   => p_contra_int_rate_bid,
		p_BASE_CURR_INT_RATE_ASK   => p_contra_int_rate_ask,
		p_CONTRA_CURR_INT_RATE_BID => null,
		p_CONTRA_CURR_INT_RATE_ASK => null,
		p_USD_CURR_INT_RATE_BID    => p_usd_int_rate_bid,
		p_USD_CURR_INT_RATE_ASK    => p_usd_int_rate_ask,
		p_DAY_COUNT_BASE	   => p_day_count_contra,
		p_DAY_COUNT_CONTRA	   => null,
		p_DAY_COUNT_USD		   => p_day_count_usd,
		p_ANNUAL_BASIS_BASE	   => p_year_basis_contra,
		p_ANNUAL_BASIS_CONTRA	   => null,
		p_ANNUAL_BASIS_USD	   => p_year_basis_usd,
		p_CURRENCY_BASE	   	   => p_contra_ccy,
		p_CURRENCY_CONTRA	   => 'USD',
		p_QUOTATION_BASIS_BASE     => p_contra_quote_usd,
		p_QUOTATION_BASIS_CONTRA   => null);
	   p_res_sec_base_ccy := p_contra_ccy;
	   p_res_sec_contra_ccy := 'USD';
       else
	   -- USD/Contra Ccy
           p_forward_rates := xtr_fx_formulas.fx_forward_rate_cv(
		p_SPOT_RATE_BASE_BID   => null,
		p_SPOT_RATE_BASE_ASK   => null,
		p_SPOT_RATE_CONTRA_BID => p_contra_spot_bid,
		p_SPOT_RATE_CONTRA_ASK => p_contra_spot_ask,
		p_BASE_CURR_INT_RATE_BID   => null,
		p_BASE_CURR_INT_RATE_ASK   => null,
		p_CONTRA_CURR_INT_RATE_BID => p_contra_int_rate_bid,
		p_CONTRA_CURR_INT_RATE_ASK => p_contra_int_rate_ask,
		p_USD_CURR_INT_RATE_BID    => p_usd_int_rate_bid,
		p_USD_CURR_INT_RATE_ASK    => p_usd_int_rate_ask,
		p_DAY_COUNT_BASE	   => null,
		p_DAY_COUNT_CONTRA	   => p_day_count_contra,
		p_DAY_COUNT_USD		   => p_day_count_usd,
		p_ANNUAL_BASIS_BASE	   => null,
		p_ANNUAL_BASIS_CONTRA	   => p_year_basis_contra,
		p_ANNUAL_BASIS_USD	   => p_year_basis_usd,
		p_CURRENCY_BASE		   => 'USD',
		p_CURRENCY_CONTRA	   => p_contra_ccy,
		p_QUOTATION_BASIS_BASE	   => null,
		p_QUOTATION_BASIS_CONTRA   => p_contra_quote_usd);
	  p_res_sec_base_ccy := 'USD';
	  p_res_sec_contra_ccy := p_contra_ccy;
       end if;
       p_res_sec_rate_bid := p_forward_rates(1);
       p_res_sec_rate_ask := p_forward_rates(2);
       p_res_sec_points_bid := p_res_sec_rate_bid - p_contra_spot_bid;
       p_res_sec_points_ask := p_res_sec_rate_ask - p_contra_spot_ask;

       -- Base Ccy/Contra Ccy forward rate
       p_forward_rates := xtr_fx_formulas.fx_spot_rate_cv(
		p_CURRENCY_CONTRA	   => p_contra_ccy,
		p_CURRENCY_BASE		   => p_base_ccy,
		p_RATE_CONTRA_BID	   => p_res_sec_rate_bid,
		p_RATE_CONTRA_ASK 	   => p_res_sec_rate_ask,
		p_RATE_BASE_BID		   => p_res_first_rate_bid,
		p_RATE_BASE_ASK		   => p_res_first_rate_ask,
		p_QUOTATION_BASIS_CONTRA   => p_contra_quote_usd,
		p_QUOTATION_BASIS_BASE     => p_base_quote_usd);
       p_res_fwd_rate_bid := p_forward_rates(1);
       p_res_fwd_rate_ask := p_forward_rates(2);
       p_res_fwd_points_bid := p_res_fwd_rate_bid - p_res_spot_bid;
       p_res_fwd_points_ask := p_res_fwd_rate_ask - p_res_spot_ask;
   else
	-- one currency is USD
	p_forward_rates.extend;
	p_forward_rates.extend;

	p_forward_rates := xtr_fx_formulas.fx_forward_rate_cv(
		p_SPOT_RATE_BASE_BID	   => p_base_spot_bid,
		p_SPOT_RATE_BASE_ASK	   => p_base_spot_ask,
		p_SPOT_RATE_CONTRA_BID 	   => p_contra_spot_bid,
		p_SPOT_RATE_CONTRA_ASK 	   => p_contra_spot_ask,
		p_BASE_CURR_INT_RATE_BID   => p_base_int_rate_bid,
		p_BASE_CURR_INT_RATE_ASK   => p_base_int_rate_ask,
		p_CONTRA_CURR_INT_RATE_BID => p_contra_int_rate_bid,
		p_CONTRA_CURR_INT_RATE_ASK => p_contra_int_rate_ask,
		p_USD_CURR_INT_RATE_BID    => p_usd_int_rate_bid,
		p_USD_CURR_INT_RATE_ASK    => p_usd_int_rate_ask,
		p_DAY_COUNT_BASE	   => p_day_count_base,
		p_DAY_COUNT_CONTRA	   => p_day_count_contra,
		p_DAY_COUNT_USD		   => p_day_count_usd,
		p_ANNUAL_BASIS_BASE	   => p_year_basis_base,
		p_ANNUAL_BASIS_CONTRA	   => p_year_basis_contra,
		p_ANNUAL_BASIS_USD	   => p_year_basis_usd,
		p_CURRENCY_BASE	   	   => p_base_ccy,
		p_CURRENCY_CONTRA	   => p_contra_ccy,
		p_QUOTATION_BASIS_BASE     => p_base_quote_usd,
		p_QUOTATION_BASIS_CONTRA   => p_contra_quote_usd);
	p_res_fwd_rate_bid := p_forward_rates(1);
	p_res_fwd_rate_ask := p_forward_rates(2);
	p_res_fwd_points_bid := p_res_fwd_rate_bid - p_res_spot_bid;
	p_res_fwd_points_ask := p_res_fwd_rate_ask - p_res_spot_ask;
   end if;


 --- Sensitivities
   -- delta spot
   p_int_rates := xtr_md_num_table(p_contra_int_rate_bid,p_contra_int_rate_ask,
				   p_base_int_rate_bid, p_base_int_rate_ask,
				   p_usd_int_rate_bid, p_usd_int_rate_ask);
   p_day_counts := SYSTEM.QRM_VARCHAR_TABLE(p_contra_day_count, p_contra_day_count,
				    p_base_day_count, p_base_day_count,
				    p_usd_day_count, p_usd_day_count);
   IF (g_proc_level>=g_debug_level) THEN
      xtr_risk_debug_pkg.dpush('fx_calculator: ' || 'Calculating Delta Spot');
   END IF;
   for i IN 1..p_int_rates.count LOOP
        df_in_rec.p_indicator := 'T';
 	df_in_rec.p_rate := p_int_rates(i);
	df_in_rec.p_spot_date := p_spot_date;
	df_in_rec.p_future_date := p_forward_date;
	df_in_rec.p_day_count_basis := p_day_counts(i);
	xtr_rate_conversion.discount_factor_conv(df_in_rec, df_out_rec);
	p_dis_factors.extend;
	p_dis_factors(i) := df_out_rec.p_result;
	IF (g_proc_level>=g_debug_level) THEN
	   xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'int rate', p_int_rates(i));
	   xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'day count', p_day_counts(i));
	   xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'disc factor', p_dis_factors(i));
	END IF;
   end LOOP;
   IF (g_proc_level>=g_debug_level) THEN
      xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'contra curr', p_contra_ccy);
      xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'base curr', p_base_ccy);
   END IF;
   p_delta := qrm_fx_formulas.fx_forward_delta_spot(p_contra_ccy, p_base_ccy,
					p_dis_factors(1), p_dis_factors(2),
					p_dis_factors(3), p_dis_factors(4),
					p_dis_factors(5), p_dis_factors(6));
   p_delta_spot_bid := p_delta(1);
   p_delta_spot_ask := p_delta(2);
   IF (g_proc_level>=g_debug_level) THEN
      xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'delta spot bid', p_delta_spot_bid);
      xtr_risk_debug_pkg.dlog('fx_calculator: ' || 'delta spot ask', p_delta_spot_ask);
      xtr_risk_debug_pkg.dpop('fx_calculator: ' || 'Calculating Delta Spot');
   END IF;

   -- fx forward rho
   IF (g_proc_level>=g_debug_level) THEN
      xtr_risk_debug_pkg.dpush('fx_calculator: ' || 'Calculating FX Rho');
   END IF;
   p_rho := qrm_fx_formulas.fx_forward_rho(p_OUT => 'D',
     	p_SPOT_RATE_BASE_BID 		=> p_base_spot_bid,
 	p_SPOT_RATE_BASE_ASK 		=> p_base_spot_ask,
	p_SPOT_RATE_CONTRA_BID		=> p_contra_spot_bid,
	p_SPOT_RATE_CONTRA_ASK		=> p_contra_spot_ask,
	p_BASE_CURR_INT_RATE_BID	=> p_base_int_rate_bid,
	p_BASE_CURR_INT_RATE_ASK	=> p_base_int_rate_ask,
	p_CONTRA_CURR_INT_RATE_BID	=> p_contra_int_rate_bid,
	p_CONTRA_CURR_INT_RATE_ASK	=> p_contra_int_rate_ask,
	p_USD_CURR_INT_RATE_BID		=> p_usd_int_rate_bid,
	p_USD_CURR_INT_RATE_ASK		=> p_usd_int_rate_ask,
	p_DAY_COUNT_BASE		=> p_day_count_base,
	p_DAY_COUNT_CONTRA		=> p_day_count_contra,
	p_DAY_COUNT_USD			=> p_day_count_usd,
	p_ANNUAL_BASIS_BASE		=> p_year_basis_base,
	p_ANNUAL_BASIS_CONTRA		=> p_year_basis_contra,
	p_ANNUAL_BASIS_USD		=> p_year_basis_usd,
	p_CURRENCY_BASE			=> p_base_ccy,
	p_CURRENCY_CONTRA		=> p_contra_ccy,
	p_QUOTATION_BASIS_BASE		=> p_base_quote_usd,
	p_QUOTATION_BASIS_CONTRA	=> p_contra_quote_usd);
   p_rho_base_bid := p_rho(1);
   p_rho_base_ask := p_rho(2);
   p_rho_contra_bid := p_rho(3);
   p_rho_contra_ask := p_rho(4);
   IF (g_proc_level>=g_debug_level) THEN
      xtr_risk_debug_pkg.dpop('fx_calculator: ' || 'Calculating FX Rho');
   END IF;


   p_varchar_args(1) := p_indicator;
   p_varchar_args(2) := p_base_ccy;
   p_varchar_args(3) := p_contra_ccy;
   p_varchar_args(4) := p_currency_quote;
   p_varchar_args(5) := p_interest_quote;
   p_varchar_args(6) := p_base_curve;
   p_varchar_args(7) := p_contra_curve;
   p_varchar_args(8) := p_usd_curve;
   p_varchar_args(9) := p_base_interpolation;
   p_varchar_args(10) := p_contra_interpolation;
   p_varchar_args(11) := p_usd_interpolation;
   p_varchar_args(12) := p_base_quote_usd;
   p_varchar_args(13) := p_contra_quote_usd;
   p_varchar_args(14) := p_base_day_count;
   p_varchar_args(15) := p_contra_day_count;
   p_varchar_args(16) := p_usd_day_count;
   p_varchar_args(17) := p_res_first_base_ccy;
   p_varchar_args(18) := p_res_first_contra_ccy;
   p_varchar_args(19) := p_res_sec_base_ccy;
   p_varchar_args(20) := p_res_sec_contra_ccy;

   p_num_args(1) := p_base_ccy_amt;
   p_num_args(2) := p_base_spot_bid;
   p_num_args(3) := p_base_spot_ask;
   p_num_args(4) := p_contra_spot_bid;
   p_num_args(5) := p_contra_spot_ask;
   p_num_args(6) := p_base_int_rate_bid;
   p_num_args(7) := p_base_int_rate_ask;
   p_num_args(8) := p_contra_int_rate_bid;
   p_num_args(9) := p_contra_int_rate_ask;
   p_num_args(10) := p_usd_int_rate_bid;
   p_num_args(11) := p_usd_int_rate_ask;
   p_num_args(12) := p_res_spot_bid;
   p_num_args(13) := p_res_spot_ask;
   p_num_args(14) := p_res_first_rate_bid;
   p_num_args(15) := p_res_first_rate_ask;
   p_num_args(16) := p_res_first_points_bid;
   p_num_args(17) := p_res_first_points_ask;
   p_num_args(18) := p_res_sec_rate_bid;
   p_num_args(19) := p_res_sec_rate_ask;
   p_num_args(20) := p_res_sec_points_bid;
   p_num_args(21) := p_res_sec_points_ask;
   p_num_args(22) := p_res_fwd_rate_bid;
   p_num_args(23) := p_res_fwd_rate_ask;
   p_num_args(24) := p_res_fwd_points_bid;
   p_num_args(25) := p_res_fwd_points_ask;
   p_num_args(26) := p_delta_spot_bid;
   p_num_args(27) := p_delta_spot_ask;
   p_num_args(28) := p_rho_base_bid;
   p_num_args(29) := p_rho_base_ask;
   p_num_args(30) := p_rho_contra_bid;
   p_num_args(31) := p_rho_contra_ask;


   IF (g_proc_level>=g_debug_level) THEN--bug3236479
      xtr_risk_debug_pkg.dpop(null,'QRM_CALCULATORS_P.fx_calculator');
   END IF;
EXCEPTION
  WHEN  e_no_int_rates THEN
    fnd_msg_pub.add;
    IF (g_ERROR_level>=g_debug_level) THEN --BUG 3236479
        	   xtr_risk_debug_pkg.dlog('EXCEPTION','E_NO_INT_RATES',
		      'QRM_CALCULATORS_P.FX_CALCULATOR',G_ERROR_LEVEL);
    END IF;
  WHEN e_no_rate_curve THEN
    fnd_msg_pub.add;
    IF (g_ERROR_level>=g_debug_level) THEN --BUG 3236479
        	   xtr_risk_debug_pkg.dlog('EXCEPTION','E_NO_RATE_CURVE',
		      'QRM_CALCULATORS_P.FX_CALCULATOR',G_ERROR_LEVEL);
    END IF;
  WHEN e_no_spot_rates THEN
    fnd_msg_pub.add;
    IF (g_ERROR_level>=g_debug_level) THEN --BUG 3236479
        	   xtr_risk_debug_pkg.dlog('EXCEPTION','E_NO_SPOT_RATES',
		      'QRM_CALCULATORS_P.FX_CALCULATOR',G_ERROR_LEVEL);
    END IF;

END fx_calculator;



FUNCTION get_curves_from_base (p_curve_types SYSTEM.QRM_VARCHAR_TABLE,
			       p_base_currencies SYSTEM.QRM_VARCHAR_TABLE,
			       p_contra_currencies SYSTEM.QRM_VARCHAR_TABLE)
	RETURN SYSTEM.QRM_VARCHAR_TABLE IS


	-- ** main cursors for defaulting ** --

	-- for YIELD and IRVOL curves
	CURSOR get_default_curve(p_type VARCHAR2,p_base_ccy VARCHAR2) IS
	  SELECT curve_code
	  FROM xtr_rm_md_curves
	  WHERE type=p_type and authorized_yn='Y' and ccy=p_base_ccy
	  ORDER BY creation_date;

	-- for FXVOL curves
	CURSOR get_default_curve_fx(p_type VARCHAR2,p_base_ccy VARCHAR2,
				     p_contra_ccy VARCHAR2) IS
	SELECT curve_code
	FROM xtr_rm_md_curves
	WHERE type=p_type and authorized_yn='Y' and
		(ccy=p_base_ccy and contra_ccy=p_contra_ccy) or
		(ccy=p_contra_ccy and contra_ccy=p_base_ccy)
	ORDER BY creation_date;

	v_curve_code varchar2(20);
	v_curve_codes_table SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();


BEGIN
    IF (g_proc_level>=g_debug_level) THEN
       xtr_risk_debug_pkg.dpush(null,'QRM_CALCULATORS_P.get_curves_from_base');
    END IF;
    if ((p_curve_types.count <> p_base_currencies.count) OR
	((p_contra_currencies IS NOT null) AND
 	 ((p_base_currencies.count <> p_contra_currencies.count) OR
	  (p_curve_types.count <> p_contra_currencies.count)))) then
	RAISE_APPLICATION_ERROR
                       (-20001,'input tables must be the same size.');
    else
	v_curve_codes_table.extend(p_curve_types.count);
        FOR i IN 1..p_curve_types.count LOOP
	    IF (g_proc_level>=g_debug_level) THEN
	       xtr_risk_debug_pkg.dlog('get_curves_from_base: ' || 'currency is', p_base_currencies(i));
	    END IF;
            if (p_curve_types(i) = 'FXVOL') then
	        OPEN get_default_curve_fx(p_curve_types(i),
					   p_base_currencies(i),
					   p_contra_currencies(i));
	        FETCH get_default_curve_fx INTO v_curve_code;
	        if (get_default_curve_fx%notfound) then
    		  FND_MESSAGE.SET_NAME('QRM','QRM_CALC_NO_DEFAULT_CURVE_ERR');
    		  FND_MESSAGE.SET_TOKEN('CCY',p_base_currencies(i)||'/'||
					      p_contra_currencies(i));
			raise e_no_rate_curve;
	      	else
			v_curve_codes_table(i) := v_curve_code;
		end if;
		IF (g_proc_level>=g_debug_level) THEN
		   xtr_risk_debug_pkg.dlog('get_curves_from_base: ' || 'found fxvol curve', v_curve_code);
		END IF;
	        CLOSE get_default_curve_fx;
            elsif ((p_curve_types(i) = 'YIELD') OR
	           (p_curve_types(i) = 'IRVOL')) then
	        OPEN get_default_curve(p_curve_types(i),p_base_currencies(i));
	        FETCH get_default_curve INTO v_curve_code;
	        if (get_default_curve%notfound) then
    		  FND_MESSAGE.SET_NAME('QRM','QRM_CALC_NO_DEFAULT_CURVE_ERR');
    		  FND_MESSAGE.SET_TOKEN('CCY',p_base_currencies(i));
			raise e_no_rate_curve;
		else
			v_curve_codes_table(i) := v_curve_code;
	        end if;
		IF (g_proc_level>=g_debug_level) THEN
		   xtr_risk_debug_pkg.dlog('get_curves_from_base: ' || 'found yield/irvol curve', v_curve_code);
		END IF;
	        CLOSE get_default_curve;
            end if;
  	END LOOP;
	IF (g_proc_level>=g_debug_level) THEN
	   xtr_risk_debug_pkg.dpop(null,'QRM_CALCULATORS_P.get_curves_from_base');
	END IF;
        return v_curve_codes_table;
    end if;
END get_curves_from_base;



-- also extracts spot rates
FUNCTION get_rates_from_curves 	(p_rate_types SYSTEM.QRM_VARCHAR_TABLE,
				 p_curve_codes SYSTEM.QRM_VARCHAR_TABLE,
				 p_base_currencies SYSTEM.QRM_VARCHAR_TABLE,
				 p_contra_currencies SYSTEM.QRM_VARCHAR_TABLE,
				 p_quote_bases SYSTEM.QRM_VARCHAR_TABLE,
				 p_interp_methods SYSTEM.QRM_VARCHAR_TABLE,
				 p_data_sides SYSTEM.QRM_VARCHAR_TABLE,
				 p_day_count_bases SYSTEM.QRM_VARCHAR_TABLE,
				 p_interest_quote_basis VARCHAR2,
				 p_currency_quote_basis VARCHAR2,
				 p_spot_date DATE,
				 p_future_date DATE)
	RETURN xtr_md_num_table IS

	v_rounding_factor number := 6;
	v_table_size number := p_rate_types.count;
	v_rate_type varchar2(1);

	v_rates_table xtr_md_num_table := xtr_md_num_table();
	v_sides_table SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();

	v_in_rec_type XTR_MARKET_DATA_P.md_from_curve_in_rec_type;
	v_out_rec_type XTR_MARKET_DATA_P.md_from_curve_out_rec_type;

	v_bid_rate_comm number;
	v_ask_rate_comm number;
	v_bid_rate_base number;
	v_ask_rate_base number;
	v_ccy varchar2(15);
	v_curve varchar2(20);

	-- Cursor for obtaining spot rates in base/commodity unit quotes
	-- for non-USD currencies against USD
	CURSOR get_fx_spot_rates(p_base_ccy VARCHAR2) IS
     	    SELECT usd_base_curr_bid_rate bid_rate_comm,
		   usd_base_curr_offer_rate ask_rate_comm,
		   1/usd_base_curr_offer_rate bid_rate_base,
		   1/usd_base_curr_bid_rate ask_rate_base,
		   currency
  	    FROM xtr_spot_rates
	    WHERE (rate_date, currency) IN
		(SELECT MAX(rate_date), currency
		 FROM xtr_spot_rates
		 WHERE currency IN (p_base_ccy)
			AND currency <> 'USD'
			AND trunc(rate_date) <= trunc(p_spot_date)
		 GROUP BY currency);

BEGIN
   IF (g_proc_level>=g_debug_level) THEN
      xtr_risk_debug_pkg.dpush(null,'QRM_CALCULATORS_P.get_rates_from_curves');
   END IF;
   IF  (((p_curve_codes IS NOT null) AND
         (p_curve_codes.count <> v_table_size)) OR
	(p_rate_types.count <> v_table_size) OR
	((p_base_currencies IS NOT null) AND
	 (p_base_currencies.count <> v_table_size)) OR
	((p_contra_currencies IS NOT null) AND
	 (p_contra_currencies.count <> v_table_size)) OR
	((p_quote_bases IS NOT null) AND
	 (p_quote_bases.count <> v_table_size)) OR
	((p_day_count_bases IS NOT null) AND
	 (p_day_count_bases.count <> v_table_size)) OR
	((p_interp_methods IS NOT null) AND
	 (p_interp_methods.count <> v_table_size)) OR
	((p_data_sides IS NOT null) AND
	 (p_data_sides.count <> v_table_size))) THEN
	RAISE_APPLICATION_ERROR
                       (-20001,'input tables must be the same size.');
    ELSE
    -- now fill up interest rates/volatilities according to curves
    -- and spot rates from database
	v_rates_table.extend(p_rate_types.count);
        v_sides_table.extend(p_rate_types.count);
        FOR i IN 1..p_rate_types.count LOOP
	    if (p_rate_types(i)='SPOT') then
		IF (g_proc_level>=g_debug_level) THEN
		   xtr_risk_debug_pkg.dpush('get_rates_from_curves: ' || 'calculating spot rate');
		END IF;
		-- it is spot taken by spot rate
		-- then do spot rate extraction
		IF (g_proc_level>=g_debug_level) THEN
		   xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'base currency',p_base_currencies(i));
		   xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'currency quote basis', p_currency_quote_basis);
		   xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'quote basis against usd',p_quote_bases(i));
		   xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'data side', p_data_sides(i));
		END IF;
		OPEN get_fx_spot_rates(p_base_currencies(i));
		FETCH get_fx_spot_rates INTO v_bid_rate_comm, v_ask_rate_comm,
					     v_bid_rate_base, v_ask_rate_base,
					     v_ccy;
		if (get_fx_spot_rates%found) then
		---logic for interpreting market data side of Spot Rates---
		    IF (g_proc_level>=g_debug_level) THEN
		       xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'spot rates found',' ');
		    END IF;
		    if (p_currency_quote_basis = 'BID') then
			if (p_quote_bases(i) = 'C') then
			   v_rates_table(i) := round(v_bid_rate_comm,v_rounding_factor);
			   IF (g_proc_level>=g_debug_level) THEN
			      xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'commodity unit quote bid',v_bid_rate_comm);
			   END IF;
			elsif (p_quote_bases(i) = 'B') then
			   v_rates_table(i) := round(v_bid_rate_base, v_rounding_factor);
			   IF (g_proc_level>=g_debug_level) THEN
			      xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'base unit quote bid',v_bid_rate_base);
			   END IF;
			end if;
		    elsif (p_currency_quote_basis = 'ASK') then
			if (p_quote_bases(i) = 'C') then
			   v_rates_table(i) := round(v_ask_rate_comm, v_rounding_factor);
			   IF (g_proc_level>=g_debug_level) THEN
			      xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'commodity unit quote ask',v_ask_rate_comm);
			   END IF;
			elsif (p_quote_bases(i) = 'B') then
			   v_rates_table(i) := round(v_ask_rate_base, v_rounding_factor);
			   IF (g_proc_level>=g_debug_level) THEN
			      xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'base unit quote ask',v_ask_rate_base);
			   END IF;
			end if;
		    elsif (p_currency_quote_basis = 'MID') then
			if (p_quote_bases(i) = 'C') then
			   v_rates_table(i) := round((v_bid_rate_comm+v_ask_rate_comm)/2, v_rounding_factor);
			elsif (p_quote_bases(i) = 'B') then
			   v_rates_table(i) := round((v_bid_rate_base+v_ask_rate_base)/2, v_rounding_factor);
		        end if;
		    elsif (p_currency_quote_basis = 'BID/ASK') then
			IF (g_proc_level>=g_debug_level) THEN
			   xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'currency quote is bid/ask');
			END IF;
			if (p_quote_bases(i) = 'C') then
			IF (g_proc_level>=g_debug_level) THEN
			   xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'quote against usd is C');
			END IF;
			   if (p_data_sides(i) = 'BID') then
			       v_rates_table(i) := round(v_bid_rate_comm, v_rounding_factor);
			       IF (g_proc_level>=g_debug_level) THEN
			          xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'BID/ASK: commodity unit quote bid', v_bid_rate_comm);
			       END IF;
			   elsif (p_data_sides(i) = 'ASK') then
			       v_rates_table(i) := round(v_ask_rate_comm, v_rounding_factor);
			       IF (g_proc_level>=g_debug_level) THEN
			          xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'BID/ASK: commodity unit quote ask', v_ask_rate_comm);
			       END IF;
			   end if;
			elsif (p_quote_bases(i) = 'B') then
			IF (g_proc_level>=g_debug_level) THEN
			   xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'quote against usd is B');
			END IF;
			   if (p_data_sides(i) = 'BID') then
			       v_rates_table(i) := round(v_bid_rate_base, v_rounding_factor);
			       IF (g_proc_level>=g_debug_level) THEN
			          xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'BID/ASK: base unit quote bid', v_bid_rate_base);
			       END IF;
			   elsif (p_data_sides(i) = 'ASK') then
			       v_rates_table(i) := round(v_ask_rate_base, v_rounding_factor);
			       IF (g_proc_level>=g_debug_level) THEN
			          xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'BID/ASK: base unit quote ask', v_bid_rate_base);
			       END IF;
			   end if;
			end if;
		    end if;
		----------------------------------------------------------
		else
	    	    FND_MESSAGE.SET_NAME('QRM','QRM_CALC_NO_DEFAULT_SPOT_ERR');
    	    	    FND_MESSAGE.SET_TOKEN('CCY',p_base_currencies(1));
		    raise e_no_spot_rates;
		end if;
		CLOSE get_fx_spot_rates;
		IF (g_proc_level>=g_debug_level) THEN
		   xtr_risk_debug_pkg.dpop('get_rates_from_curves: ' || 'calculating spot rates');
		END IF;
		-- not spot rate, then extract rate/vol from curve
		-- get interest rates/ volatilities for each curve
	   elsif ((p_rate_types(i)='YIELD') OR
		  (p_rate_types(i)='IRVOL') OR
		  (p_rate_types(i)='FXVOL')) then
		IF (g_proc_level>=g_debug_level) THEN
		   xtr_risk_debug_pkg.dpush('get_rates_from_curves: ' || 'calculating curve rates');
		END IF;
		-----logic for interpreting market data side of Int Rates----
		if (p_interest_quote_basis = 'BID') then
		   v_sides_table(i) := 'B';
	  	elsif (p_interest_quote_basis = 'ASK') then
		   v_sides_table(i) := 'A';
		elsif (p_interest_quote_basis = 'MID') then
		   v_sides_table(i) := 'M';
		elsif (p_interest_quote_basis = 'BID/ASK') then
		   if (p_data_sides(i) = 'BID') then
			v_sides_table(i) := 'B';
		   elsif (p_data_sides(i) = 'ASK') then
			v_sides_table(i) := 'A';
		   end if;
		end if;
		------------------------------------------------
		IF (g_proc_level>=g_debug_level) THEN
		   xtr_risk_debug_pkg.dpop('get_rates_from_curves: ' || 'calculating curve rates');
		END IF;
		v_in_rec_type.p_curve_code := p_curve_codes(i);
		v_curve := p_curve_codes(i);
		IF (g_proc_level>=g_debug_level) THEN
		   xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'curve code',p_curve_codes(i));
		END IF;
		v_in_rec_type.p_source := 'C';
		if (p_rate_types(i) = 'YIELD') then
		   v_rate_type := 'Y';
		elsif ((p_rate_types(i) = 'IRVOL')  OR
		       (p_rate_types(i) = 'FXVOL')) then
		   v_rate_type := 'V';
		end if;
		v_in_rec_type.p_indicator := v_rate_type;
		IF (g_proc_level>=g_debug_level) THEN
		   xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'indicator', v_rate_type);
		END IF;
		v_in_rec_type.p_spot_date := p_spot_date;
		IF (g_proc_level>=g_debug_level) THEN
		   xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'spot date', p_spot_date);
		END IF;
		v_in_rec_type.p_future_date := p_future_date;
		IF (g_proc_level>=g_debug_level) THEN
		   xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'future date', p_future_date);
		END IF;
		v_in_rec_type.p_day_count_basis_out := p_day_count_bases(i);
		IF (g_proc_level>=g_debug_level) THEN
		   xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'day count basis', p_day_count_bases(i));
		   xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'interest quote basis', p_interest_quote_basis);
		   xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'data side here',v_sides_table(i));
		END IF;
		v_in_rec_type.p_interpolation_method := p_interp_methods(i);
		IF (g_proc_level>=g_debug_level) THEN
		   xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'interpolation method',p_interp_methods(i));
		END IF;
		v_in_rec_type.p_side := v_sides_table(i);
		v_in_rec_type.p_batch_id := null;
		IF (g_proc_level>=g_debug_level) THEN
		   xtr_risk_debug_pkg.dpush('get_rates_from_curves: ' || 'get md from curve');
		END IF;
		XTR_MARKET_DATA_P.get_md_from_curve(v_in_rec_type,
						    v_out_rec_type);
		v_rates_table(i) := round(v_out_rec_type.p_md_out, v_rounding_factor);
		IF (g_proc_level>=g_debug_level) THEN
		   xtr_risk_debug_pkg.dlog('get_rates_from_curves: ' || 'got rate', v_rates_table(i));
		END IF;
	   end if;
	END LOOP;
        IF (g_proc_level>=g_debug_level) THEN
	   xtr_risk_debug_pkg.dpop(null,'QRM_CALCULATORS_P.get_rates_from_curves');
        END IF;
	return v_rates_table;
    END IF;

    EXCEPTION
  	WHEN  xtr_market_data_p.e_mdcs_no_data_found THEN
	  if (v_rate_type = 'Y') then
    	    FND_MESSAGE.SET_NAME('QRM','QRM_CALC_NO_DEFAULT_INT_ERR');
    	    FND_MESSAGE.SET_TOKEN('CURVE',v_curve);
	    IF (g_ERROR_level>=g_debug_level) THEN --BUG 3236479
        	   xtr_risk_debug_pkg.dlog('EXCEPTION','QRM-CALC_NO_DEFAULT_INT_ERR',
		      'QRM_CALCULATORS_P.GET_RATES_FROM_CURVE',G_ERROR_LEVEL);
            END IF;
	    raise e_no_int_rates;
	  else
    	    FND_MESSAGE.SET_NAME('QRM','QRM_CALC_NO_DEFAULT_VOL_ERR');
    	    FND_MESSAGE.SET_TOKEN('CURVE',v_curve);
	    IF (g_ERROR_level>=g_debug_level) THEN --BUG 3236479
        	   xtr_risk_debug_pkg.dlog('EXCEPTION','E_NO_VOL_RATES',
		      'QRM_CALCULATORS_P.GET_RATES_FROM_CURVES',G_ERROR_LEVEL);
            END IF;
	    raise e_no_vol_rates;
	  end if;
END get_rates_from_curves;


FUNCTION get_rates_from_base      (p_rate_types SYSTEM.QRM_VARCHAR_TABLE,
				   p_base_currencies SYSTEM.QRM_VARCHAR_TABLE,
				   p_contra_currencies SYSTEM.QRM_VARCHAR_TABLE,
				   p_quote_bases  SYSTEM.QRM_VARCHAR_TABLE,
				   p_interp_methods SYSTEM.QRM_VARCHAR_TABLE,
				   p_data_sides SYSTEM.QRM_VARCHAR_TABLE,
				   p_day_count_bases SYSTEM.QRM_VARCHAR_TABLE,
				   p_interest_quote_basis VARCHAR2,
				   p_currency_quote_basis VARCHAR2,
			    	   p_spot_date DATE,
				   p_future_date DATE)
	RETURN xtr_md_num_table IS

	v_curves_table SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
	--v_sides_table SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
	v_rates_table xtr_md_num_table := xtr_md_num_table();

	v_rate_type SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
	v_base_ccy SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
	v_contra_ccy SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
	v_curve SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();

	v_in_rec_type XTR_MARKET_DATA_P.md_from_curve_in_rec_type;
	v_out_rec_type XTR_MARKET_DATA_P.md_from_curve_out_rec_type;

	v_table_size number := p_rate_types.count;
BEGIN
    IF (g_proc_level>=g_debug_level) THEN
       xtr_risk_debug_pkg.dpush(null,'QRM_CALCULATORS_P.get_rates_from_base');
    END IF;
    if ((p_base_currencies.count <> v_table_size) OR
	((p_contra_currencies IS NOT null) AND
	 (p_contra_currencies.count <> v_table_size)) OR
	((p_quote_bases IS NOT null) AND
	 (p_quote_bases.count <> v_table_size)) OR
	((p_interp_methods IS NOT null) AND
	 (p_interp_methods.count <> v_table_size)) OR
	((p_data_sides IS NOT null) AND
	 (p_data_sides.count <> v_table_size)) OR
	((p_day_count_bases IS NOT null) AND
	 (p_day_count_bases.count <> v_table_size))) then
	 RAISE_APPLICATION_ERROR
                       (-20001,'input tables must be the same size.');
      else
	-- first get the corresponding default curve for each rate/rate type
	-- to be extracted
	v_rate_type.extend(1);
	v_base_ccy.extend(1);
	v_contra_ccy.extend(1);
	v_curve.extend(1);
	v_curves_table.extend(v_table_size);
	--v_sides_table.extend(v_table_size);
	v_rates_table.extend(v_table_size);
	FOR i IN 1..v_table_size LOOP
	   if  ((p_rate_types(i) = 'YIELD') OR
	  	(p_rate_types(i) = 'FXVOL') OR
		(p_rate_types(i) = 'IRVOL')) then
		v_rate_type(1) := p_rate_types(i);
		v_base_ccy(1) := p_base_currencies(i);
		if (p_contra_currencies IS NOT null) then
			v_contra_ccy(1) := p_contra_currencies(i);
		end if;
		v_curve := get_curves_from_base(v_rate_type,
						v_base_ccy,
						v_contra_ccy);
		v_curves_table(i) := v_curve(1);
                IF (g_proc_level>=g_debug_level) THEN
                   xtr_risk_debug_pkg.dlog('get_rates_from_base: ' || 'curve code', v_curve(1));
                END IF;

	   elsif (p_rate_types(i) = 'SPOT') then
		-- do spot rate extraction here
		-- but need to fill up space in corresponding tables
		v_curves_table(i) := ' ';
	   end if;
	END LOOP;
    end if;

    --- FILL UP RATES table
    -- first make sure all tables are same length
    if (v_curves_table.count <> v_table_size) then
 	 RAISE_APPLICATION_ERROR
                       (-20001,'input tables must be the same size.');
    else
	-- call get_rates_from_curves
 	v_rates_table := get_rates_from_curves(p_rate_types,
					       v_curves_table,
					       p_base_currencies,
					       p_contra_currencies,
					       p_quote_bases,
					       p_interp_methods,
					       p_data_sides,
					       p_day_count_bases,
				 	       p_interest_quote_basis,
					       p_currency_quote_basis,
					       p_spot_date,
					       p_future_date);

    IF (g_proc_level>=g_debug_level) THEN
       xtr_risk_debug_pkg.dpop(null,'QRM_CALCULATORS_P.get_rates_from_base');
    END IF;
    return v_rates_table;
    end if;
END get_rates_from_base;



FUNCTION get_spot_quotation_basis(p_base_currency IN VARCHAR2,
				  p_contra_currency IN VARCHAR2,
				  p_overwrite_sys IN BOOLEAN)

	RETURN SYSTEM.QRM_VARCHAR_TABLE IS

	p_ccy_a varchar2(15);
	p_ccy_b varchar2(15);
	p_quote_bases SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();

        p_no_usd boolean := (p_base_currency <> 'USD' AND
			     p_contra_currency <> 'USD');

	CURSOR get_quote_basis(p_ccy varchar2) IS
	    SELECT currency_a, currency_b
  	    FROM xtr_market_prices
	    WHERE p_ccy IN (currency_a, currency_b) AND term_type='S';

BEGIN
    p_quote_bases.extend;
    p_quote_bases.extend;

    if (p_overwrite_sys) then
        if (p_base_currency = 'USD') then
	    p_quote_bases(1) := 'C';
	    p_quote_bases(2) := 'C';
        elsif (p_contra_currency = 'USD') then
	    p_quote_bases(1) := 'B';
	    p_quote_bases(2) := 'C';
	end if;
    end if;
    if ((p_no_usd AND p_overwrite_sys) OR (NOT p_overwrite_sys)) then
	OPEN get_quote_basis(p_base_currency);
	FETCH get_quote_basis INTO p_ccy_a, p_ccy_b;
	if (get_quote_basis%found) then
	    if (p_ccy_a = 'USD') then
		p_quote_bases(1) := 'C';
	    elsif (p_ccy_b = 'USD') then
		p_quote_bases(1) := 'B';
	    end if;
	else
	   FND_MESSAGE.SET_NAME('QRM','QRM_CALC_NO_DEFAULT_SPOT_ERR');
    	   FND_MESSAGE.SET_TOKEN('CCY',p_base_currency);
	   raise e_no_spot_rates;
	end if;
	CLOSE get_quote_basis;
	OPEN get_quote_basis(p_contra_currency);
	FETCH get_quote_basis INTO p_ccy_a, p_ccy_b;
	if (get_quote_basis%found) then
	    if (p_ccy_a = 'USD') then
		p_quote_bases(2) := 'C';
	    elsif (p_ccy_b = 'USD') then
		p_quote_bases(2) := 'B';
	    end if;
	else
	    FND_MESSAGE.SET_NAME('QRM','QRM_CALC_NO_DEFAULT_SPOT_ERR');
    	    FND_MESSAGE.SET_TOKEN('CCY',p_contra_currency);
	    raise e_no_spot_rates;
	end if;
	CLOSE get_quote_basis;
     end if;
     return p_quote_bases;
END get_spot_quotation_basis;


--added by sankim 10/2/01
/*a note about p_indicator
CC:calculate using curves. override any previous rates existing.
CR: calculate using rates with some rates missing, but curve code specified.
   default only the missing rates from the specified curve.
R:calculate using rates. all rates are provided so there's no need to default
any rates.
NR: curve and some rates are missing when calculating using rates. a curve
needs to be defaulted and fill in any missing rates.
NC: no curve specified when calculating using curves. a curve needs to be
defaulted and fill in all the rates
*/
PROCEDURE fra_pricing(p_indicator IN VARCHAR2,
		      p_settlement_date IN DATE ,
                      p_maturity_date IN DATE,
                      p_day_count_basis IN VARCHAR2,
                      p_spot_date IN DATE,
                      p_rate_curve IN OUT NOCOPY VARCHAR2,
                      p_quote_basis IN VARCHAR2,
                      p_interpolation IN VARCHAR2,
                      p_ss_bid IN OUT NOCOPY NUMBER,
                      p_ss_ask IN OUT NOCOPY NUMBER,
                      p_sm_bid IN OUT NOCOPY NUMBER,
                      p_sm_ask IN OUT NOCOPY NUMBER,
                      p_holding_period OUT NOCOPY NUMBER,
                      p_adjusted_holding_period OUT NOCOPY NUMBER,
		      p_contract_rate_bid OUT NOCOPY NUMBER,
		      p_contract_rate_ask OUT NOCOPY NUMBER) is
v_quote_basis VARCHAR2(20) := p_quote_basis;
v_settlement_date DATE;
v_maturity_date DATE;
v_spot_date DATE;
v_spot_settlement NUMBER;
--number of days from spot to settlement
v_spot_maturity NUMBER;
--number of days from spot to maturity
v_year_count NUMBER;
--variable for year basis
v_ss_bid NUMBER :=p_ss_bid;
v_ss_ask NUMBER :=p_ss_ask;
v_sm_bid NUMBER :=p_sm_bid;
v_sm_ask NUMBER :=p_sm_ask;
v_fra_rec_in XTR_MM_COVERS.INT_FORW_RATE_IN_REC_TYPE;
v_fra_rec_out XTR_MM_COVERS.INT_FORW_RATE_OUT_REC_TYPE;
CURSOR default_currency_cursor is
  select param_value from xtr_pro_param
      where param_name = 'SYSTEM_FUNCTIONAL_CCY';
v_curve_type SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
v_curve_code SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE(p_rate_curve,p_rate_curve);
v_base_currency SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
v_interpolation SYSTEM.QRM_VARCHAR_TABLE :=
          SYSTEM.QRM_VARCHAR_TABLE(p_interpolation,p_interpolation);
v_data_side SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK');
v_day_count_basis SYSTEM.QRM_VARCHAR_TABLE :=
          SYSTEM.QRM_VARCHAR_TABLE(p_day_count_basis,p_day_count_basis);
v_rates XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
v_default_curve SYSTEM.QRM_VARCHAR_TABLE;
BEGIN
  --xtr_risk_debug_pkg.start_debug('/sqlcom/out/findv11i','sktest.dbg');
  --xtr_risk_debug_pkg.start_debug;
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpush(null,'QRM_CALCULATORS_P.fra_pricing');
  END IF;
 --if any errors were added before, remove it
  IF fnd_msg_pub.count_msg > 0 THEN
    fnd_msg_pub.Initialize;
  END IF;
  v_base_currency.extend;
  v_settlement_date:= p_settlement_date;
  v_maturity_date:= p_maturity_date;
  v_spot_date:= p_spot_date;
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'p_indicator',p_indicator);
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'v_settlement_date',v_settlement_date);
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'v_maturity_date',v_maturity_date);
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'p_day_count_basis',p_day_count_basis);
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'spot_date',v_spot_date);
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'rate curve',p_rate_curve);
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'quote basis',p_quote_basis);
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'interpolation',p_interpolation);
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'ss bid',p_ss_bid);
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'ss ask',p_ss_ask);
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'sm bid',p_sm_bid);
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'sm ask',p_sm_ask);
  END IF;
  IF p_indicator = 'NR' or p_indicator = 'NC' THEN
  --default a curve
  --get the treasury reporting currency
    open default_currency_cursor;
    fetch default_currency_cursor into v_base_currency(1);
    --xtr_risk_debug_pkg.dlog('default curve',p_rate_curve);
    close default_currency_cursor;
  --get the default curve that belong to the treasury reporting currency
    v_default_curve:=get_curves_from_base(v_curve_type,v_base_currency,null);
    p_rate_curve:=v_default_curve(1);
    v_base_currency.extend;
    v_base_currency(2):=v_base_currency(1);
    v_curve_type.extend;
    v_curve_type(2):='YIELD';
    IF v_quote_basis = 'DEFAULT' THEN
    --for curve default quote basis, get the actual value
      select data_side into v_quote_basis from xtr_rm_md_curves where
      curve_code = p_rate_curve;
    END IF;
    --get spot to settlement rates
    IF v_ss_bid is null or v_ss_ask is null or p_indicator = 'NC' THEN
      v_rates:=get_rates_from_base(v_curve_type,
      v_base_currency, null,null,v_interpolation,v_data_side,v_day_count_basis,
      v_quote_basis,null, p_spot_date,p_settlement_date);
      IF (g_proc_level>=g_debug_level) THEN
         xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'ss bid',v_rates(1));
         xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'ss ask',v_rates(2));
      END IF;
      IF v_ss_bid is null or p_indicator = 'NC' THEN
        p_ss_bid := v_rates(1);
      END IF;
      IF v_ss_ask is null or p_indicator = 'NC' THEN
        p_ss_ask := v_rates(2);
      END IF;
    END IF;
    --get spot to maturity rates
    IF v_sm_bid is null or v_sm_ask is null or p_indicator = 'NC' THEN
      v_rates:=get_rates_from_base(v_curve_type,
      v_base_currency, null,null,v_interpolation,v_data_side,v_day_count_basis,
      v_quote_basis,null, p_spot_date,p_maturity_date);
      IF (g_proc_level>=g_debug_level) THEN
         xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'sm bid',v_rates(1));
         xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'sm ask',v_rates(2));
      END IF;
      IF v_sm_bid is null or p_indicator = 'NC' THEN
        p_sm_bid := v_rates(1);
      END IF;
      IF v_sm_ask is null or p_indicator = 'NC' THEN
        p_sm_ask := v_rates(2);
      END IF;
    END IF;
  ELSIF p_indicator = 'CC' or p_indicator = 'CR' THEN
  -- get rates from curve
    IF v_quote_basis = 'DEFAULT' THEN
    --for curve default quote basis, get the actual value
      select data_side into v_quote_basis from xtr_rm_md_curves where
      curve_code = p_rate_curve;
    END IF;
    v_base_currency.extend;
    v_base_currency(2):=v_base_currency(1);
    v_curve_type.extend;
    v_curve_type(2):='YIELD';
    v_rates:=get_rates_from_curves(v_curve_type,v_curve_code,v_base_currency,
                null,null,v_interpolation,v_data_side,v_day_count_basis,
                v_quote_basis,null, p_spot_date,p_settlement_date);
    IF v_ss_bid is null or p_indicator = 'CC' THEN
      p_ss_bid:=v_rates(1);
    END IF;
    IF v_ss_ask is null or p_indicator = 'CC' THEN
      p_ss_ask:=v_rates(2);
    END IF;
    v_rates:=get_rates_from_curves(v_curve_type,v_curve_code,v_base_currency,
                null,null,v_interpolation,v_data_side,v_day_count_basis,
                v_quote_basis,null, p_spot_date,p_maturity_date);
    IF v_sm_bid is null or p_indicator = 'CC' THEN
      p_sm_bid:=v_rates(1);
    END IF;
    IF v_sm_ask is null or p_indicator = 'CC' THEN
      p_sm_ask:=v_rates(2);
    END IF;
  END IF;
  --calculate holding period
  XTR_CALC_P.calc_days_run_c(v_settlement_date,v_maturity_date,'ACTUAL/ACTUAL',null,
  p_holding_period,v_year_count);
  --calculate adjusted holding period
  XTR_CALC_P.calc_days_run_c(v_settlement_date,v_maturity_date,p_day_count_basis,
  null,p_adjusted_holding_period,v_year_count);
  --calculate contract rates
  XTR_CALC_P.calc_days_run_c(v_spot_date,v_settlement_date,p_day_count_basis,null,
  v_spot_settlement,v_year_count);
  XTR_CALC_P.calc_days_run_c(v_spot_date,v_maturity_date,p_day_count_basis,null
  ,v_spot_maturity,v_year_count);
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'ss bid',p_ss_bid);
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'ss ask',p_ss_ask);
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'sm bid',p_sm_bid);
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'sm ask',p_sm_ask);
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'spot maturity',v_spot_maturity);
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'spot settlement',v_spot_settlement);
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'year count',v_year_count);
  END IF;

  v_fra_rec_in.p_indicator:= 'Y';
  v_fra_rec_in.p_t:=v_spot_settlement;
  v_fra_rec_in.p_T1:= v_spot_maturity;
  v_fra_rec_in.p_Rt:= p_ss_ask;
  v_fra_rec_in.p_RT1:= p_sm_bid;
  v_fra_rec_in.p_year_basis:= v_year_count;


  XTR_MM_COVERS.interest_forward_rate(v_fra_rec_in,v_fra_rec_out);
  p_contract_rate_bid:=v_fra_rec_out.p_fra_rate;

  v_fra_rec_in.p_indicator:= 'Y';
  v_fra_rec_in.p_t:=v_spot_settlement;
  v_fra_rec_in.p_T1:= v_spot_maturity;
  v_fra_rec_in.p_Rt:= p_ss_bid;
  v_fra_rec_in.p_RT1:= p_sm_ask;
  v_fra_rec_in.p_year_basis:= v_year_count;



  XTR_MM_COVERS.interest_forward_rate(v_fra_rec_in,v_fra_rec_out);
  p_contract_rate_ask:=v_fra_rec_out.p_fra_rate;
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'ss bid',p_ss_bid);
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'ss ask',p_ss_ask);
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'sm bid',p_sm_bid);
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'sm ask',p_sm_ask);
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'contract bid',p_contract_rate_bid);
     xtr_risk_debug_pkg.dlog('fra_pricing: ' || 'contract ask',p_contract_rate_ask);
     xtr_risk_debug_pkg.dpop('fra_pricing: ' || 'pricing cover');
  END IF;
  --xtr_risk_debug_pkg.stop_debug;
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop(null,'QRM_CALCULATORS_P.fra_pricing');
  END IF;
EXCEPTION
  WHEN e_no_rate_curve THEN
    IF (g_ERROR_level>=g_debug_level) THEN --BUG 3236479
        	   xtr_risk_debug_pkg.dlog('EXCEPTION','E_NO_RATE_CURVE',
		      'QRM_CALCULATORS_P.FRA_PRICING',G_ERROR_LEVEL);
    END IF;
    fnd_msg_pub.add;
  WHEN e_no_int_rates THEN
    IF (g_ERROR_level>=g_debug_level) THEN --BUG 3236479
        	   xtr_risk_debug_pkg.dlog('EXCEPTION','E_NO_INT_RATES',
		      'QRM_CALCULATORS_P.FRA_PRICING',G_ERROR_LEVEL);
    END IF;
    fnd_msg_pub.add;
END fra_pricing;

--added by sankim 10/16/01
/*a note about p_indicator
CC:calculate using curves. override any previous rates existing.
CR: calculate using rates with some rates missing, but curve code specified.
   default only the missing rates from the specified curve.
R:calculate using rates. all rates are provided so there's no need to default
any rates.
NR: curve and some rates are missing when calculating using rates. a curve
needs to be defaulted and fill in any missing rates.
NC: no curve specified when calculating using curves. a curve needs to be
defaulted and fill in all the rates
*/
PROCEDURE fra_settlement(p_indicator IN VARCHAR2,
			 p_settlement_date IN DATE,
                         p_maturity_date IN DATE,
                         p_face_value IN NUMBER,
			 p_currency IN OUT NOCOPY VARCHAR2,
			 p_contract_rate IN OUT NOCOPY NUMBER,
			 p_day_count_basis IN VARCHAR2,
			 p_deal_subtype IN VARCHAR2,
			 p_calculation_method IN VARCHAR2,
                         p_rate_curve IN OUT NOCOPY VARCHAR2,
                         p_quote_basis IN VARCHAR2,
                         p_interpolation IN VARCHAR2,
                         p_settlement_rate IN OUT NOCOPY NUMBER,
                         p_holding_period OUT NOCOPY NUMBER,
                         p_adjusted_holding_period OUT NOCOPY NUMBER,
			 p_action OUT NOCOPY VARCHAR2,
			 p_settlement_amount OUT NOCOPY NUMBER,
			 p_duration OUT NOCOPY NUMBER,
			 p_convexity OUT NOCOPY NUMBER,
			 p_basis_point_value OUT NOCOPY NUMBER) is
v_quote_basis VARCHAR2(20) := p_quote_basis;
v_settlement_date DATE;
v_maturity_date DATE;
v_spot_date DATE;
v_spot_settlement NUMBER;
--number of days from spot to settlement
v_settlement_maturity NUMBER;
--number of days from settlement to maturity
v_year_count NUMBER;
--variable for year basis
v_settlement_rate NUMBER :=p_settlement_rate;
v_fra_rec_in XTR_MM_COVERS.FRA_SETTLEMENT_IN_REC_TYPE;
v_fra_rec_out XTR_MM_COVERS.FRA_SETTLEMENT_OUT_REC_TYPE;
CURSOR default_currency_cursor is
  select param_value from xtr_pro_param
      where param_name = 'SYSTEM_FUNCTIONAL_CCY';
v_curve_type SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
v_curve_code SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE(p_rate_curve);
v_base_currency SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
v_interpolation SYSTEM.QRM_VARCHAR_TABLE :=
          SYSTEM.QRM_VARCHAR_TABLE(p_interpolation);
v_data_side SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE(p_quote_basis);
v_day_count_basis SYSTEM.QRM_VARCHAR_TABLE :=
          SYSTEM.QRM_VARCHAR_TABLE(p_day_count_basis);
v_rates XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
v_days_array XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
v_pvc_array XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
v_default_curve SYSTEM.QRM_VARCHAR_TABLE;
v_ss_bid NUMBER;
v_ss_ask NUMBER;
v_sm_bid NUMBER;
v_sm_ask NUMBER;
v_holding_period NUMBER;
v_adjusted_holding_period NUMBER;
v_contract_rate_bid NUMBER;
v_contract_rate_ask NUMBER;
v_rounding_factor NUMBER := 6;
BEGIN
  --xtr_risk_debug_pkg.start_debug('/sqlcom/out/findv11i','sktest.dbg');
  --xtr_risk_debug_pkg.start_debug;
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpush(null,'QRM_CALCULATORS_P.fra_settlement');
  END IF;
  --if any errors were added before, remove it
  IF fnd_msg_pub.count_msg > 0 THEN
    fnd_msg_pub.Initialize;
  END IF;
  v_base_currency.extend;
  v_settlement_date:= p_settlement_date;
  v_maturity_date:= p_maturity_date;

  v_spot_date := trunc(sysdate);


  /*xtr_risk_debug_pkg.dlog('p_indicator',p_indicator);
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'v_maturity_date',v_maturity_date);
     xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'p_day_count_basis',p_day_count_basis);
     xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'spot_date',v_spot_date);
     xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'rate curve',p_rate_curve);
     xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'quote basis',p_quote_basis);
     xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'interpolation',p_interpolation);
     xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'ss bid',p_ss_bid);
     xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'ss ask',p_ss_ask);
     xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'sm bid',p_sm_bid);
     xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'sm ask',p_sm_ask);
  END IF;*/
  IF p_currency is NULL THEN
  --get the treasury reporting currency if no currency is specified
    open default_currency_cursor;
    fetch default_currency_cursor into v_base_currency(1);
    --xtr_risk_debug_pkg.dlog('default curve',p_rate_curve);
    close default_currency_cursor;
  ELSE
    v_base_currency(1):=p_currency;
  END IF;
  IF p_indicator = 'NC'or p_indicator = 'NR' THEN
  --default a curve
  --get the default curve that belong to the currency specified or the treasury
  -- reporting currency
    v_default_curve:=get_curves_from_base(v_curve_type, v_base_currency,null);
    p_rate_curve:=v_default_curve(1);
    --get settlement rate
    IF v_settlement_rate is null or p_indicator = 'NC' THEN
      IF v_spot_date >= v_settlement_date THEN
        v_rates:=get_rates_from_base(v_curve_type,
        v_base_currency, null,null,v_interpolation,v_data_side,
        v_day_count_basis,v_quote_basis,null, v_settlement_date,
        p_maturity_date);
        --xtr_risk_debug_pkg.dlog('ss bid',v_rates(1));
        --xtr_risk_debug_pkg.dlog('ss ask',v_rates(2));
        p_settlement_rate:=v_rates(1);
      ELSE --calculate forward-forward rate
        IF (g_proc_level>=g_debug_level) THEN
           xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'settle date',p_settlement_date);
           xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'maturity date',p_maturity_date);
           xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'day count',p_day_count_basis);
           xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'spot date',v_spot_date);
           xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'curve',p_rate_curve);
           xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'quote basis',p_quote_basis);
           xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'interp',p_interpolation);
           xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'ss bid',v_ss_bid);
           xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'ss ask',v_ss_ask);
           xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'sm bid',v_sm_bid);
           xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'sm ask',v_sm_ask);
        END IF;
        fra_pricing('CC',p_settlement_date,p_maturity_date,p_day_count_basis,
        v_spot_date,p_rate_curve,p_quote_basis,p_interpolation,v_ss_bid,
        v_ss_ask,v_sm_bid,v_sm_ask,v_holding_period,v_adjusted_holding_period,
        v_contract_rate_bid,v_contract_rate_ask);
        IF p_quote_basis = 'BID' THEN
          p_settlement_rate:= v_contract_rate_bid;
        ELSIF p_quote_basis = 'ASK' THEN
          p_settlement_rate:= v_contract_rate_ask;
        ELSE --mid
          p_settlement_rate:= (v_contract_rate_bid+v_contract_rate_ask)/2;
        END IF;
        p_settlement_rate:= round(p_settlement_rate,v_rounding_factor);
      END IF;
    END IF;
  ELSIF p_indicator = 'CC' or p_indicator = 'CR' THEN
  -- get rates from curve
    IF v_settlement_rate is null or p_indicator = 'CC'  THEN
      IF v_spot_date >= v_settlement_date THEN
        v_rates:=get_rates_from_curves(v_curve_type,v_curve_code,
                 v_base_currency,null,null,v_interpolation,v_data_side,
                 v_day_count_basis,v_quote_basis,null, v_settlement_date,
                 p_maturity_date);
        /*v_rates:=get_rates_from_curves(v_curve_type,v_curve_code,
                 v_base_currency,null,null,v_interpolation,v_data_side,
                 v_day_count_basis,v_quote_basis,null, v_spot_date,
                 p_maturity_date);*/
        p_settlement_rate:=v_rates(1);
      ELSE --calculate forward-forward rate
        IF (g_proc_level>=g_debug_level) THEN
           xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'settle date',p_settlement_date);
           xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'maturity date',p_maturity_date);
           xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'day count',p_day_count_basis);
           xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'spot date',v_spot_date);
           xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'curve',p_rate_curve);
           xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'quote basis',p_quote_basis);
           xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'interp',p_interpolation);
           xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'ss bid',v_ss_bid);
           xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'ss ask',v_ss_ask);
           xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'sm bid',v_sm_bid);
           xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'sm ask',v_sm_ask);
        END IF;
        fra_pricing('CC',p_settlement_date,p_maturity_date,p_day_count_basis,
        v_spot_date,p_rate_curve,p_quote_basis,p_interpolation,v_ss_bid,
        v_ss_ask,v_sm_bid,v_sm_ask,v_holding_period,v_adjusted_holding_period,
        v_contract_rate_bid,v_contract_rate_ask);
        IF p_quote_basis = 'BID' THEN
          p_settlement_rate:= v_contract_rate_bid;
        ELSIF p_quote_basis = 'ASK' THEN
          p_settlement_rate:= v_contract_rate_ask;
        ELSE --mid
          p_settlement_rate:= (v_contract_rate_bid+v_contract_rate_ask)/2;
        END IF;
        p_settlement_rate:= round(p_settlement_rate,v_rounding_factor);
      END IF;
    END IF;
  END IF;
  --calculate holding period
  XTR_CALC_P.calc_days_run_c(v_settlement_date,v_maturity_date,'ACTUAL/ACTUAL',
     null,p_holding_period,v_year_count);
  --calculate adjusted holding period
  XTR_CALC_P.calc_days_run_c(v_settlement_date,v_maturity_date,
          p_day_count_basis,null,p_adjusted_holding_period,v_year_count);
  --calculate settlement amount
  v_settlement_maturity:= p_adjusted_holding_period;
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'calc method',p_calculation_method);
     xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'settle rate',p_settlement_rate);
     xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'contract rate',p_contract_rate);
     xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'face value',p_face_value);
     xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'settlement maturity',v_settlement_maturity);
     xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'year count',v_year_count);
  END IF;

  v_fra_rec_in.p_indicator:= p_calculation_method;
  v_fra_rec_in.p_fra_price:= p_contract_rate;
  v_fra_rec_in.p_settlement_rate:= p_settlement_rate;
  v_fra_rec_in.p_face_value:= p_face_value;
  v_fra_rec_in.p_day_count:= v_settlement_maturity;
  v_fra_rec_in.p_annual_basis:= v_year_count;
  v_fra_rec_in.p_deal_subtype:= null;



  XTR_MM_COVERS.fra_settlement_amount(v_fra_rec_in,v_fra_rec_out);
  p_settlement_amount:=v_fra_rec_out.p_settlement_amount;
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'settle amount',p_settlement_amount);
  END IF;
  --calculate sensitivities of fra
  IF v_spot_date< v_settlement_date THEN
     -- first, calculate duration
    XTR_CALC_P.calc_days_run_c(v_spot_date,v_settlement_date,p_day_count_basis,
null,v_spot_settlement,v_year_count);
    IF (g_proc_level>=g_debug_level) THEN
       xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'spot_date',v_spot_date);
       xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'settlement_date',v_settlement_date);
       xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'spot_settlement',v_spot_settlement);
    END IF;
    v_days_array.extend;
    v_days_array(1):=v_spot_settlement;
    v_pvc_array.extend;
    v_pvc_array(1):=1;
    p_duration:=QRM_MM_FORMULAS.duration(v_pvc_array,v_days_array,v_year_count);
    IF (g_proc_level>=g_debug_level) THEN
       xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'year count',v_year_count);
       xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'duration',p_duration);
    END IF;
    --secondly, calculate convexity
    p_convexity:=QRM_MM_FORMULAS.ni_fra_convexity(v_spot_settlement,
					p_settlement_rate,v_year_count);
    IF (g_proc_level>=g_debug_level) THEN
       xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'settlement rate',p_settlement_rate);
       xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'convexity',p_convexity);
    END IF;
    -- lastly, calculate bpv
    --calculate shifted settlement
    v_fra_rec_in.p_settlement_rate:=p_settlement_rate+0.01;
    XTR_MM_COVERS.fra_settlement_amount(v_fra_rec_in,v_fra_rec_out);
    p_basis_point_value:=QRM_MM_FORMULAS.bpv(p_settlement_amount,
					v_fra_rec_out.p_settlement_amount);
    IF (g_proc_level>=g_debug_level) THEN
       xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'shifted',v_fra_rec_out.p_settlement_amount);
       xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'base',p_settlement_amount);
       xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'bpv',p_basis_point_value);
    END IF;
  END IF;
  --determine pay or receive
  IF p_deal_subtype = 'FUND' THEN
    IF p_contract_rate > p_settlement_rate THEN
      SELECT description INTO p_action FROM xtr_amount_actions_v WHERE deal_type ='FRA' AND amount_type = 'SETTLE' AND action_code = 'PAY';
    ELSIF p_contract_rate < p_settlement_rate THEN
      SELECT description INTO p_action FROM xtr_amount_actions_v WHERE deal_type ='FRA' AND amount_type = 'SETTLE' AND action_code = 'REC';
    ELSE
      p_action:=null;
    END IF;
  ELSE
    IF p_contract_rate > p_settlement_rate THEN
      SELECT description INTO p_action FROM xtr_amount_actions_v WHERE deal_type ='FRA' AND amount_type = 'SETTLE' AND action_code = 'REC';
    ELSIF p_contract_rate < p_settlement_rate THEN
      SELECT description INTO p_action FROM xtr_amount_actions_v WHERE deal_type ='FRA' AND amount_type = 'SETTLE' AND action_code = 'PAY';
    ELSE
      p_action:=null;
    END IF;
  END IF;
  /*xtr_risk_debug_pkg.dlog('ss bid',p_ss_bid);
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'ss ask',p_ss_ask);
     xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'sm bid',p_sm_bid);
     xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'sm ask',p_sm_ask);
     xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'contract bid',p_contract_rate_bid);
     xtr_risk_debug_pkg.dlog('fra_settlement: ' || 'contract ask',p_contract_rate_ask);
  END IF;*/
  --xtr_risk_debug_pkg.stop_debug;
  --return currency if it wasn't provided
  IF p_currency is NULL THEN
    p_currency:= v_base_currency(1);
  END IF;
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop(null,'QRM_CALCULATORS_P.fra_settlement');
  END IF;
EXCEPTION
  WHEN e_no_rate_curve THEN
    IF (g_ERROR_level>=g_debug_level) THEN --BUG 3236479
        	   xtr_risk_debug_pkg.dlog('EXCEPTION','E_NO_RATE_CURVE',
		      'QRM_CALCULATORS_P.FRA_SETTLEMENT',G_ERROR_LEVEL);
    END IF;
    fnd_msg_pub.add;
  WHEN e_no_int_rates THEN
    IF (g_ERROR_level>=g_debug_level) THEN --BUG 3236479
        	   xtr_risk_debug_pkg.dlog('EXCEPTION','E_NO_INT_RATES',
		      'QRM_CALCULATORS_P.FRA_SETTLEMENT',G_ERROR_LEVEL);
    END IF;
    fnd_msg_pub.add;
END fra_settlement;



--added by jbrodsky 11/02/01

PROCEDURE fxo_calculator(p_date_args    IN     SYSTEM.QRM_DATE_TABLE,
			p_varchar_args IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
			p_num_args     IN OUT NOCOPY xtr_md_num_table) IS

	p_spot_date date := p_date_args(1);
	p_exp_date date := p_date_args(2);
	p_indicator varchar2(1) := p_varchar_args(1);
	p_foreign_ccy varchar2(15) := p_varchar_args(2);
	p_domestic_ccy varchar2(15) := p_varchar_args(3);
	p_currency_quote varchar2(20) := p_varchar_args(4);
	p_interest_quote varchar2(20) := p_varchar_args(5);
	p_foreign_curve varchar2(20) := p_varchar_args(6);
	p_domestic_curve varchar2(20) := p_varchar_args(7);
	p_volatility_curve varchar2(20) := p_varchar_args(8);
	p_foreign_interpolation varchar2(20) := p_varchar_args(9);
	p_domestic_interpolation varchar2(20) := p_varchar_args(10);
	p_volatility_interpolation varchar2(20) := p_varchar_args(11);
	p_foreign_quote_usd varchar2(1) := p_varchar_args(12);
	p_domestic_quote_usd varchar2(1) := p_varchar_args(13);
	p_foreign_day_count varchar2(15) := p_varchar_args(14);
	p_domestic_day_count varchar2(15) := p_varchar_args(15);
	p_implied_vol_call_put varchar2(20):= p_varchar_args(16);
	p_calc_type_indicator varchar2(1):= p_varchar_args(17);
   	p_implied_vol_price number := p_num_args(1);
	p_foreign_ccy_amt number := p_num_args(2);
   	p_strike_price number:= p_num_args(3);
   	p_volatility number:= p_num_args(4);
   	p_for_spot_rate_bid number := p_num_args(5);
	p_for_spot_rate_ask number := p_num_args(6);
   	p_dom_spot_rate_bid number := p_num_args(7);
   	p_dom_spot_rate_ask number := p_num_args(8);
   	p_for_int_rate_bid number := p_num_args(9);
   	p_for_int_rate_ask number := p_num_args(10);
   	p_dom_int_rate_bid number := p_num_args(11);
   	p_dom_int_rate_ask number := p_num_args(12);
   	p_vol_bid number := p_num_args(13);
   	p_vol_ask number := p_num_args(14);


	p_res_impl_vol number;


	p_res_call_bid number;
	p_res_call_ask number;
	p_res_put_bid number;
	p_res_put_ask number;
	p_res_fxforward_bid number;
	p_res_fxforward_ask number;
	p_res_call_fair_value_bid number;
	p_res_call_fair_value_ask number;
	p_res_put_fair_value_bid number;
	p_res_put_fair_value_ask number;

	p_res_delta_call_bid number;
	p_res_delta_call_ask number;
	p_res_delta_put_bid number;
	p_res_delta_put_ask number;
	p_res_gamma_bid number;
	p_res_gamma_ask number;
	p_res_theta_call_bid number;
	p_res_theta_call_ask number;
	p_res_theta_put_bid number;
	p_res_theta_put_ask number;
	p_res_vega_bid number;
	p_res_vega_ask number;
	p_res_rho_dom_call_bid number;
	p_res_rho_dom_call_ask number;
	p_res_rho_dom_put_bid number;
	p_res_rho_dom_put_ask number;
	p_res_rho_for_call_bid number;
	p_res_rho_for_call_ask number;
	p_res_rho_for_put_bid number;
	p_res_rho_for_put_ask number;

	--Inputs for implied volatility calculation
	p_rates_table XTR_MD_NUM_TABLE;
	p_interest_rates XTR_MD_NUM_TABLE;
	p_day_count_bases SYSTEM.QRM_VARCHAR_TABLE;
	p_rate_types SYSTEM.QRM_VARCHAR_TABLE;
	p_compound_freq XTR_MD_NUM_TABLE;
	p_spot_rates XTR_MD_NUM_TABLE;
	p_curve_types SYSTEM.QRM_VARCHAR_TABLE;
    	p_curve_codes SYSTEM.QRM_VARCHAR_TABLE;
    	p_base_currencies SYSTEM.QRM_VARCHAR_TABLE;
    	p_contra_currencies SYSTEM.QRM_VARCHAR_TABLE;
    	p_quote_bases SYSTEM.QRM_VARCHAR_TABLE;
    	p_interp_methods SYSTEM.QRM_VARCHAR_TABLE;
    	p_data_sides SYSTEM.QRM_VARCHAR_TABLE;

	--indicator of whether either currency is USD
	p_neither_usd boolean := (p_foreign_ccy<>'USD' AND p_domestic_ccy<>'USD');
	-- indicator of whether to overwrite quotation basis against usd
   	-- if one currency is USD
        p_ow_spot_rates boolean := false;

	p_unit_price number;
	p_days number;
	p_years number;
	p_option_indicator varchar2(1);
	p_spot_rate number;

	p_rate_type varchar2(1);


	--Continuous version of rates
	p_for_cint_rate_bid number;
   	p_for_cint_rate_ask number;
   	p_dom_cint_rate_bid number;
   	p_dom_cint_rate_ask number;

	fx_option_price_in  XTR_FX_FORMULAS.GK_OPTION_CV_IN_REC_TYPE;
	fx_option_price_out XTR_FX_FORMULAS.GK_OPTION_CV_OUT_REC_TYPE;

BEGIN



IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dpush(null,'QRM_CALCULATORS_P.fxo_calculator');
END IF;



        IF fnd_msg_pub.count_msg > 0 THEN
             fnd_msg_pub.Initialize;
        END IF;


	if (p_exp_date-p_spot_date > 365) THEN
		p_rate_type := 'P';
	ELSE
		p_rate_type := 'S';
	END IF;




	IF (p_calc_type_indicator = 'V') THEN

		--Default Curve Data
		IF (p_indicator = 'D') THEN


			IF (g_proc_level>=g_debug_level) THEN
			   xtr_risk_debug_pkg.dpush('fxo_calculator: ' || 'Calculation Based On Defaults');
			END IF;

			p_volatility_curve:='';
			p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD','YIELD');
    			p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy,p_domestic_ccy);
    			p_curve_codes := get_curves_from_base(p_curve_types,p_base_currencies,
						p_contra_currencies);

			p_foreign_curve := p_curve_codes(1);
    			p_domestic_curve := p_curve_codes(2);

			IF (g_proc_level>=g_debug_level) THEN
			   xtr_risk_debug_pkg.dlog('fxo_calculator: ' || 'foreign curve', p_foreign_curve);
    			   xtr_risk_debug_pkg.dlog('fxo_calculator: ' || 'domestic curve', p_domestic_curve);
    			END IF;


			  -- since 'Calculate Using Defaults' was pressed, use default interpol.
    			p_foreign_interpolation := 'DEFAULT';
    			p_domestic_interpolation := 'DEFAULT';

    			-- assume interest rate quote to be bid/ask;
    			p_interest_quote := 'BID/ASK';

		    	-- calculate Rates
			-- this follows the calculator table across each row
        		-- first do Spot Rates

			-- get quotation basis versus usd for our currencies

			p_quote_bases:=GET_SPOT_QUOTATION_BASIS(p_foreign_ccy, p_domestic_ccy, p_ow_spot_rates);
			p_foreign_quote_usd:= p_quote_bases(1);
			p_domestic_quote_usd:= p_quote_bases(2);

    			if (p_foreign_ccy = 'USD' AND p_domestic_ccy <> 'USD') then
				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT','SPOT');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_ccy, p_domestic_ccy);
				p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_quote_usd,
					   p_domestic_quote_usd);
				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK');
    			elsif (p_domestic_ccy = 'USD' AND p_foreign_ccy <> 'USD') then
				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT','SPOT');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy, p_foreign_ccy);
				p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_quote_usd,p_foreign_quote_usd);
				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK');
    			elsif (p_foreign_ccy <> 'USD' AND p_domestic_ccy <> 'USD') then
    				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT','SPOT','SPOT','SPOT');
    				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy,p_foreign_ccy,
					p_domestic_ccy, p_domestic_ccy);
    				p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_quote_usd, p_foreign_quote_usd,
				       	p_domestic_quote_usd,p_domestic_quote_usd);
    				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK','BID','ASK');
    			end if;

			p_rates_table := get_rates_from_base(p_rate_types, p_base_currencies,
					 p_contra_currencies, p_quote_bases,
					 p_interp_methods, p_data_sides,
					 p_day_count_bases,p_interest_quote,
					 p_currency_quote,p_spot_date,
					 p_exp_date);

			if (p_foreign_ccy = 'USD' AND p_domestic_ccy <> 'USD') then
				p_for_spot_rate_bid := 1;
				p_for_spot_rate_ask := 1;
    				p_dom_spot_rate_bid := p_rates_table(1);
    				p_dom_spot_rate_ask := p_rates_table(2);
    			elsif (p_domestic_ccy = 'USD' AND p_foreign_ccy <> 'USD') then
				p_for_spot_rate_bid := p_rates_table(1);
				p_for_spot_rate_ask := p_rates_table(2);
				p_dom_spot_rate_bid := 1;
				p_dom_spot_rate_ask := 1;
    			elsif (p_neither_usd) then
				p_for_spot_rate_bid := p_rates_table(1);
				p_for_spot_rate_ask := p_rates_table(2);
    				p_dom_spot_rate_bid := p_rates_table(3);
    				p_dom_spot_rate_ask := p_rates_table(4);
    			end if;




			  -- now do Interest Rates
    			p_rate_types.delete;
    			p_base_currencies.delete;
    			p_data_sides.delete;
    			p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE('DEFAULT','DEFAULT',
					  'DEFAULT','DEFAULT');
    			p_quote_bases := null;
    			p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD','YIELD','YIELD','YIELD');
    			p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy, p_foreign_ccy,
					   p_domestic_ccy, p_domestic_ccy);
    			p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK','BID','ASK');
    			p_day_count_bases := SYSTEM.QRM_VARCHAR_TABLE('ACTUAL365', 'ACTUAL365',
					   'ACTUAL365',
					   'ACTUAL365');  -- bug 3611158



			--Call to get interest rates
    			p_rates_table := get_rates_from_base(p_rate_types, p_base_currencies,
					 p_contra_currencies, p_quote_bases,
					 p_interp_methods, p_data_sides,
					 p_day_count_bases,p_interest_quote,
					 p_currency_quote,p_spot_date,
					 p_exp_date);
    			p_for_int_rate_bid := p_rates_table(1);
    			p_for_int_rate_ask := p_rates_table(2);
    			p_dom_int_rate_bid := p_rates_table(3);
			p_dom_int_rate_ask := p_rates_table(4);


			--Values set to be passed back as default used
			p_domestic_day_count:='ACTUAL365';
			p_foreign_day_count:='ACTUAL365';



  			IF (g_proc_level>=g_debug_level) THEN
  			   xtr_risk_debug_pkg.dpop('fxo_calculator: ' || 'Calculation Based On Defaults');
  			END IF;



		--Optional Curve Data
		ELSIF (p_indicator = 'C') THEN
			IF (g_proc_level>=g_debug_level) THEN
			   xtr_risk_debug_pkg.dpush('fxo_calculator: ' || 'Calculation Based On Curves');
			END IF;
		    	-- GET DEFAULT CURVES


			--If all curves are not input, defaults are gotten
			if (p_foreign_curve IS null) then
				p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy);
        			p_curve_codes := get_curves_from_base(p_curve_types,
					      p_base_currencies,
					      p_contra_currencies);
				p_foreign_curve := p_curve_codes(1);
     			end if;
     			if (p_domestic_curve IS null) then
				p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_ccy);
        			p_curve_codes := get_curves_from_base(p_curve_types,
					      p_base_currencies,
					      p_contra_currencies);
				p_domestic_curve := p_curve_codes(1);
    			end if;

  			-- GET DEFAULT RATES based on CURVES
    			-- first do SPOT RATES


			--curve codes are null on spot rates
 			p_curve_codes := null;
    			p_base_currencies := null;
		    	-- calculate Rates
			-- this follows the calculator table across each row
        		-- first do Spot Rates
			p_quote_bases:=GET_SPOT_QUOTATION_BASIS(p_foreign_ccy, p_domestic_ccy, p_ow_spot_rates);
			p_foreign_quote_usd:= p_quote_bases(1);
			p_domestic_quote_usd:= p_quote_bases(2);

    			if (p_foreign_ccy = 'USD' AND p_domestic_ccy <> 'USD') then
				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT','SPOT');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_ccy, p_domestic_ccy);
				p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_quote_usd,
					   p_domestic_quote_usd);
				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK');
    			elsif (p_domestic_ccy = 'USD' AND p_foreign_ccy <> 'USD') then
				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT','SPOT');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy, p_foreign_ccy);
				p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_quote_usd,p_foreign_quote_usd);
				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK');
    			elsif (p_foreign_ccy <> 'USD' AND p_domestic_ccy <> 'USD') then
    				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT','SPOT','SPOT','SPOT');
    				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy,p_foreign_ccy,
					p_domestic_ccy, p_domestic_ccy);
    				p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_quote_usd, p_foreign_quote_usd,
				       	p_domestic_quote_usd,p_domestic_quote_usd);
    				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK','BID','ASK');
    			end if;


			--Gets spot rates
			p_rates_table := get_rates_from_curves(p_rate_types, p_curve_codes, p_base_currencies,
					 p_contra_currencies, p_quote_bases,
					 p_interp_methods, p_data_sides,
					 p_day_count_bases,p_interest_quote,
					 p_currency_quote,p_spot_date,
					 p_exp_date);

			if (p_foreign_ccy = 'USD' AND p_domestic_ccy <> 'USD') then
				p_for_spot_rate_bid := 1;
				p_for_spot_rate_ask := 1;
    				p_dom_spot_rate_bid := p_rates_table(1);
    				p_dom_spot_rate_ask := p_rates_table(2);
    			elsif (p_domestic_ccy = 'USD' AND p_foreign_ccy <> 'USD') then
				p_for_spot_rate_bid := p_rates_table(1);
				p_for_spot_rate_ask := p_rates_table(2);
				p_dom_spot_rate_bid := 1;
				p_dom_spot_rate_ask := 1;
    			elsif (p_neither_usd) then
				p_for_spot_rate_bid := p_rates_table(1);
				p_for_spot_rate_ask := p_rates_table(2);
    				p_dom_spot_rate_bid := p_rates_table(3);
    				p_dom_spot_rate_ask := p_rates_table(4);
    			end if;




			  -- now get INTEREST RATES
    			p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD','YIELD','YIELD','YIELD');
    			p_curve_codes := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_curve,p_foreign_curve,
				       p_domestic_curve,p_domestic_curve);
    			p_base_currencies.delete;
    			p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy,p_foreign_ccy,
					   p_domestic_ccy,p_domestic_ccy);
    			p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_interpolation,
				p_foreign_interpolation, p_domestic_interpolation, p_domestic_interpolation);

    			p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK','BID','ASK');
    			p_day_count_bases := SYSTEM.QRM_VARCHAR_TABLE('ACTUAL365',
			    'ACTUAL365','ACTUAL365','ACTUAL365');
    			p_quote_bases := null;

    			p_rates_table := get_rates_from_curves(p_rate_types,p_curve_codes,
					   p_base_currencies,
					   p_contra_currencies,
					   p_quote_bases,p_interp_methods,
					   p_data_sides,p_day_count_bases,
					   p_interest_quote,p_currency_quote,
					   p_spot_date,
					   p_exp_date);
    			p_for_int_rate_bid := p_rates_table(1);
    			p_for_int_rate_ask := p_rates_table(2);
    			p_dom_int_rate_bid := p_rates_table(3);
    			p_dom_int_rate_ask := p_rates_table(4);


			--Values set to be passed back as default used
			p_domestic_day_count:='ACTUAL365';  -- bug 3611158
			p_foreign_day_count:='ACTUAL365';

  			IF (g_proc_level>=g_debug_level) THEN
  			   xtr_risk_debug_pkg.dpop('fxo_calculator: ' || 'Calculation Based On Curves');
  			END IF;






		--Optional Rates Data
		ELSIF (p_indicator = 'R') THEN
			IF (g_proc_level>=g_debug_level) THEN
			   xtr_risk_debug_pkg.dpush('fxo_calculator: ' || 'Calculation Based On Rates');
			END IF;
     			-- if a spot rate is missing, go to base(defaults) section
     			if (p_for_spot_rate_bid IS null) then
				if (p_foreign_ccy <> 'USD') then
	    				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT');
	    				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy);
	    				p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_quote_usd);
	    				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID');
    	    				p_rates_table := get_rates_from_curves(p_rate_types,
						p_curve_codes,
						p_base_currencies,
					   	p_contra_currencies,
						p_quote_bases,
						p_interp_methods,
					   	p_data_sides,
						p_day_count_bases,
						p_interest_quote,
					   	p_currency_quote,
					   	p_spot_date, p_exp_date);
    	    				p_for_spot_rate_bid := p_rates_table(1);
				else
	    				p_for_spot_rate_bid := 1;
				end if;
			-- get corresponding base ccy curve
     			end if;
     			if (p_for_spot_rate_ask IS null) then
				if (p_foreign_ccy <> 'USD') then
	    				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT');
	    				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy);
	    				p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_quote_usd);
	    				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('ASK');
    	    				p_rates_table := get_rates_from_curves(p_rate_types,
						p_curve_codes,
						p_base_currencies,
					   	p_contra_currencies,
						p_quote_bases,
						p_interp_methods,
					   	p_data_sides,
						p_day_count_bases,
						p_interest_quote,
					   	p_currency_quote,
					   	p_spot_date, p_exp_date);
    	    				p_for_spot_rate_ask := p_rates_table(1);
				else
	    				p_for_spot_rate_ask := 1;
				end if;
     			end if;
     			if (p_dom_spot_rate_bid IS null) then
				if (p_domestic_ccy <> 'USD') then
	    				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT');
	    				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_ccy);
	    				p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_quote_usd);
	    				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID');
    	    				p_rates_table := get_rates_from_curves(p_rate_types,
						p_curve_codes,
						p_base_currencies,
					   	p_contra_currencies,
						p_quote_bases,
						p_interp_methods,
					   	p_data_sides,
						p_day_count_bases,
						p_interest_quote,
					   	p_currency_quote,
					   	p_spot_date, p_exp_date);
    	    				p_dom_spot_rate_bid := p_rates_table(1);
				else
	    				p_dom_spot_rate_bid := 1;
				end if;
     			end if;
     			if (p_dom_spot_rate_ask IS null) then
				if (p_dom_spot_rate_ask <> 'USD') then
	    				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT');
	    				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_ccy);
	    				p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_quote_usd);
	    				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('ASK');
    	    				p_rates_table := get_rates_from_curves(p_rate_types,
						p_curve_codes,
						p_base_currencies,
					   	p_contra_currencies,
						p_quote_bases,
						p_interp_methods,
					   	p_data_sides,
						p_day_count_bases,
						p_interest_quote,
					   	p_currency_quote,
					   	p_spot_date, p_exp_date);
    	   				p_dom_spot_rate_ask := p_rates_table(1);
				else
	    				p_dom_spot_rate_ask := 1;
				end if;
     			end if;

 		   	-- if INTEREST RATES are missing, first check if curve section is filled
     			-- if so, use curve;
     			-- else, go to base(defaults) section and default curve in curves section
     			if (p_for_int_rate_bid IS null) then
				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy);
 				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID');
				p_day_count_bases := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_day_count);
				-- if curve section is null, go to defaults
				if (p_foreign_curve IS null) then
	    				p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
	    				p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE('DEFAULT');
	    				p_curve_codes := get_curves_from_base(p_curve_types,
					      p_base_currencies,
					      p_contra_currencies);
	   				-- default curves section
	   				p_foreign_curve := p_curve_codes(1);
	   				p_foreign_interpolation := p_interp_methods(1);
				else
					-- curve section not null, use curve
	    				p_curve_codes := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_curve);
	    				p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_interpolation);
				end if;
				-- calculate rate
	    			p_rates_table := get_rates_from_curves(p_rate_types,
					p_curve_codes,p_base_currencies,p_contra_currencies,
					p_quote_bases,p_interp_methods,p_data_sides,
					p_day_count_bases,p_interest_quote,p_currency_quote,
					p_spot_date,p_exp_date);
					p_for_int_rate_bid := p_rates_table(1);
				IF (g_proc_level>=g_debug_level) THEN
				   xtr_risk_debug_pkg.dlog('fxo_calculator: ' || 'defaulted foreign bid rate',p_for_int_rate_bid);
				END IF;
     			end if;

			if (p_for_int_rate_ask IS null) then
				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy);
 				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('ASK');
				p_day_count_bases := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_day_count);
				-- if curve section is null, go to defaults
				if (p_foreign_curve IS null) then
	    				p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
	    				p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE('DEFAULT');
	    				p_curve_codes := get_curves_from_base(p_curve_types,
					      p_base_currencies,
					      p_contra_currencies);
	   				-- default curves section
	   				p_foreign_curve := p_curve_codes(1);
	   				p_foreign_interpolation := p_interp_methods(1);
				else
					-- curve section not null, use curve
	    				p_curve_codes := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_curve);
	    				p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_interpolation);
				end if;
				-- calculate rate
	    			p_rates_table := get_rates_from_curves(p_rate_types,
					p_curve_codes,p_base_currencies,p_contra_currencies,
					p_quote_bases,p_interp_methods,p_data_sides,
					p_day_count_bases,p_interest_quote,p_currency_quote,
					p_spot_date,p_exp_date);
					p_for_int_rate_ask := p_rates_table(1);
				IF (g_proc_level>=g_debug_level) THEN
				   xtr_risk_debug_pkg.dlog('fxo_calculator: ' || 'defaulted foreign ask rate',p_for_int_rate_ask);
				END IF;
     			end if;
			if (p_dom_int_rate_bid IS null) then
				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_ccy);
 				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID');
				p_day_count_bases := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_day_count);
				-- if curve section is null, go to defaults
				if (p_domestic_curve IS null) then
	    				p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
	    				p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE('DEFAULT');
	    				p_curve_codes := get_curves_from_base(p_curve_types,
					      p_base_currencies,
					      p_contra_currencies);
	   				-- default curves section
	   				p_domestic_curve := p_curve_codes(1);
	   				p_domestic_interpolation := p_interp_methods(1);
				else
					-- curve section not null, use curve
	    				p_curve_codes := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_curve);
	    				p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_interpolation);
				end if;
				-- calculate rate
	    			p_rates_table := get_rates_from_curves(p_rate_types,
					p_curve_codes,p_base_currencies,p_contra_currencies,
					p_quote_bases,p_interp_methods,p_data_sides,
					p_day_count_bases,p_interest_quote,p_currency_quote,
					p_spot_date,p_exp_date);
					p_dom_int_rate_bid := p_rates_table(1);
				IF (g_proc_level>=g_debug_level) THEN
				   xtr_risk_debug_pkg.dlog('fxo_calculator: ' || 'defaulted domestic bid rate',p_dom_int_rate_bid);
				END IF;
     			end if;
			if (p_dom_int_rate_ask IS null) then
				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_ccy);
 				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('ASK');
				p_day_count_bases := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_day_count);
				-- if curve section is null, go to defaults
				if (p_domestic_curve IS null) then
	    				p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
	    				p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE('DEFAULT');
	    				p_curve_codes := get_curves_from_base(p_curve_types,
					      p_base_currencies,
					      p_contra_currencies);
	   				-- default curves section
	   				p_domestic_curve := p_curve_codes(1);
	   				p_domestic_interpolation := p_interp_methods(1);
				else
					-- curve section not null, use curve
	    				p_curve_codes := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_curve);
	    				p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_interpolation);
				end if;
				-- calculate rate
	    			p_rates_table := get_rates_from_curves(p_rate_types,
					p_curve_codes,p_base_currencies,p_contra_currencies,
					p_quote_bases,p_interp_methods,p_data_sides,
					p_day_count_bases,p_interest_quote,p_currency_quote,
					p_spot_date,p_exp_date);
					p_dom_int_rate_ask := p_rates_table(1);
				IF (g_proc_level>=g_debug_level) THEN
				   xtr_risk_debug_pkg.dlog('fxo_calculator: ' || 'defaulted domestic ask rate',p_dom_int_rate_bid);
				END IF;
     			end if;




  		IF (g_proc_level>=g_debug_level) THEN
  		   xtr_risk_debug_pkg.dpop('fxo_calculator: ' || 'Calculation Based On Rates');
  		END IF;


		END IF;
		p_day_count_bases:=SYSTEM.QRM_VARCHAR_TABLE(p_domestic_day_count, p_foreign_day_count);

		--Interest rates needed to calculate implied volatility.  Need to verify which
		--side we want bid and ask on.


		--Gets Spot rate
		if (p_domestic_ccy = 'USD') THEN
			p_spot_rates:=XTR_FX_FORMULAS.FX_SPOT_RATE_CV(p_domestic_ccy, p_foreign_ccy,
				p_dom_spot_rate_bid, p_dom_spot_rate_ask, p_for_spot_rate_bid,
				p_for_spot_rate_ask, 'C', p_foreign_quote_usd);
		elsif (p_foreign_ccy = 'USD') THEN
			p_spot_rates:=XTR_FX_FORMULAS.FX_SPOT_RATE_CV(p_domestic_ccy, p_foreign_ccy,
				p_dom_spot_rate_bid, p_dom_spot_rate_ask, p_for_spot_rate_bid,
				p_for_spot_rate_ask, p_domestic_quote_usd, 'C');
		else
			p_spot_rates:=XTR_FX_FORMULAS.FX_SPOT_RATE_CV(p_domestic_ccy, p_foreign_ccy,
				p_dom_spot_rate_bid, p_dom_spot_rate_ask, p_for_spot_rate_bid,
				p_for_spot_rate_ask, p_domestic_quote_usd, p_foreign_quote_usd);
		end if;






		if (p_implied_vol_call_put = 'BUYCALL') THEN
			p_interest_rates:=xtr_md_num_table(p_dom_int_rate_ask, p_for_int_rate_bid);
			p_spot_rate:=p_spot_rates(2);
			p_option_indicator:='C';
		elsif (p_implied_vol_call_put = 'BUYPUT') THEN
			p_interest_rates:=xtr_md_num_table(p_dom_int_rate_bid, p_for_int_rate_ask);
			p_spot_rate:=p_spot_rates(1);
			p_option_indicator:='P';
		elsif (p_implied_vol_call_put = 'SELLCALL') THEN
			p_interest_rates:=xtr_md_num_table(p_dom_int_rate_bid, p_for_int_rate_ask);
			p_spot_rate:=p_spot_rates(1);
			p_option_indicator:='C';
		elsif (p_implied_vol_call_put = 'SELLPUT') THEN
			p_interest_rates:=xtr_md_num_table(p_dom_int_rate_ask, p_for_int_rate_bid);
			p_spot_rate:=p_spot_rates(2);
			p_option_indicator:='P';
		END IF;

		-- sets up rate type for calculate_implied_volatility ('S' for simple)
		p_rate_types:= SYSTEM.QRM_VARCHAR_TABLE(p_rate_type, p_rate_type);


		--Must give dummy values to compound freq
		p_compound_freq:=XTR_MD_NUM_TABLE(1, 1);





		p_res_impl_vol := QRM_MM_FORMULAS.calculate_implied_volatility('FXO', p_spot_date, p_exp_date, p_interest_rates, p_day_count_bases, p_rate_types, p_compound_freq, p_spot_rate, p_strike_price, p_implied_vol_price, p_option_indicator, null, null);



		p_vol_ask:=p_res_impl_vol;
		p_vol_bid:=p_res_impl_vol;


		p_volatility:= p_res_impl_vol;

	ELSIF (p_calc_type_indicator = 'P') THEN
		--Default Curve Data
		IF (p_indicator = 'D') THEN

			IF (g_proc_level>=g_debug_level) THEN
			   xtr_risk_debug_pkg.dpush('fxo_calculator: ' || 'Calculation Based On Defaults');
			END IF;

			p_volatility_curve:='';
			--Only want to set volatility curve if volatility has not been input
			if (p_volatility IS null) THEN
				p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD','YIELD', 'FXVOL');
    				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy,p_domestic_ccy, p_foreign_ccy);
				p_contra_currencies:= SYSTEM.QRM_VARCHAR_TABLE(null, null, p_domestic_ccy);
    				p_interp_methods:= SYSTEM.QRM_VARCHAR_TABLE('DEFAULT','DEFAULT', 'DEFAULT');
				p_curve_codes := get_curves_from_base(p_curve_types,p_base_currencies,
						p_contra_currencies);

				p_foreign_curve := p_curve_codes(1);
    				p_domestic_curve := p_curve_codes(2);
				p_volatility_curve := p_curve_codes(3);
			else
				p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD','YIELD');
    				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy,p_domestic_ccy);
				p_contra_currencies:= SYSTEM.QRM_VARCHAR_TABLE(null, null);
    				p_interp_methods:= SYSTEM.QRM_VARCHAR_TABLE('DEFAULT','DEFAULT');
				p_curve_codes := get_curves_from_base(p_curve_types,p_base_currencies,
						p_contra_currencies);

				p_foreign_curve := p_curve_codes(1);
    				p_domestic_curve := p_curve_codes(2);
			end if;


			IF (g_proc_level>=g_debug_level) THEN
			   xtr_risk_debug_pkg.dlog('fxo_calculator: ' || 'foreign curve', p_foreign_curve);
    			   xtr_risk_debug_pkg.dlog('fxo_calculator: ' || 'domestic curve', p_domestic_curve);
			   xtr_risk_debug_pkg.dlog('fxo_calculator: ' || 'volatility curve', p_volatility_curve);
			END IF;

			  -- since 'Calculate Using Defaults' was pressed, use default interpol.
    			p_foreign_interpolation := 'DEFAULT';
    			p_domestic_interpolation := 'DEFAULT';
			p_volatility_interpolation:= 'DEFAULT';

    			-- assume interest rate quote to be bid/ask;
    			p_interest_quote := 'BID/ASK';

		    	-- calculate Rates
			-- this follows the calculator table across each row
        		-- first do Spot Rates
    			p_quote_bases:=GET_SPOT_QUOTATION_BASIS(p_foreign_ccy, p_domestic_ccy, p_ow_spot_rates);
			p_foreign_quote_usd:= p_quote_bases(1);
			p_domestic_quote_usd:= p_quote_bases(2);

			if (p_foreign_ccy = 'USD' AND p_domestic_ccy <> 'USD') then
				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT','SPOT');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_ccy, p_domestic_ccy);
				p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_quote_usd,
					   p_domestic_quote_usd);
				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK');
				p_interp_methods:=SYSTEM.QRM_VARCHAR_TABLE('DEFAULT', 'DEFAULT');
				p_contra_currencies:=SYSTEM.QRM_VARCHAR_TABLE(null, null);
    			elsif (p_domestic_ccy = 'USD' AND p_foreign_ccy <> 'USD') then
				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT','SPOT');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy, p_foreign_ccy);
				p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_quote_usd,p_foreign_quote_usd);
				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK');
				p_interp_methods:=SYSTEM.QRM_VARCHAR_TABLE('DEFAULT', 'DEFAULT');
				p_contra_currencies:=SYSTEM.QRM_VARCHAR_TABLE(null, null);
    			elsif (p_foreign_ccy <> 'USD' AND p_domestic_ccy <> 'USD') then
    				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT','SPOT','SPOT','SPOT');
    				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy,p_foreign_ccy,
					p_domestic_ccy, p_domestic_ccy);
    				p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_quote_usd, p_foreign_quote_usd,
				       	p_domestic_quote_usd,p_domestic_quote_usd);
    				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK','BID','ASK');
				p_interp_methods:=SYSTEM.QRM_VARCHAR_TABLE('DEFAULT', 'DEFAULT', 'DEFAULT', 'DEFAULT');
				p_contra_currencies:=SYSTEM.QRM_VARCHAR_TABLE(null, null, null, null);
    			end if;


			p_rates_table := get_rates_from_base(p_rate_types, p_base_currencies,
					 p_contra_currencies, p_quote_bases,
					 p_interp_methods, p_data_sides,
					 p_day_count_bases,p_interest_quote,
					 p_currency_quote,p_spot_date,
					 p_exp_date);

			if (p_foreign_ccy = 'USD' AND p_domestic_ccy <> 'USD') then
				p_for_spot_rate_bid := 1;
				p_for_spot_rate_ask := 1;
    				p_dom_spot_rate_bid := p_rates_table(1);
    				p_dom_spot_rate_ask := p_rates_table(2);
    			elsif (p_domestic_ccy = 'USD' AND p_foreign_ccy <> 'USD') then
				p_for_spot_rate_bid := p_rates_table(1);
				p_for_spot_rate_ask := p_rates_table(2);
				p_dom_spot_rate_bid := 1;
				p_dom_spot_rate_ask := 1;
    			elsif (p_neither_usd) then
				p_for_spot_rate_bid := p_rates_table(1);
				p_for_spot_rate_ask := p_rates_table(2);
    				p_dom_spot_rate_bid := p_rates_table(3);
    				p_dom_spot_rate_ask := p_rates_table(4);
    			end if;




			  -- now do Interest Rates
    			p_rate_types.delete;
    			p_base_currencies.delete;
    			p_data_sides.delete;
    			p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE('DEFAULT','DEFAULT',
					  'DEFAULT','DEFAULT');
    			p_quote_bases := null;
    			p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD','YIELD','YIELD','YIELD');
    			p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy, p_foreign_ccy,
					   p_domestic_ccy, p_domestic_ccy);
    			p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK','BID','ASK');
    			p_day_count_bases := SYSTEM.QRM_VARCHAR_TABLE('ACTUAL365',
					'ACTUAL365', 'ACTUAL365', 'ACTUAL365');

			p_contra_currencies:=SYSTEM.QRM_VARCHAR_TABLE(null, null, null, null);

			--Call to get interest rates
    			p_rates_table := get_rates_from_base(p_rate_types, p_base_currencies,
					 p_contra_currencies, p_quote_bases,
					 p_interp_methods, p_data_sides,
					 p_day_count_bases,p_interest_quote,
					 p_currency_quote,p_spot_date,
					 p_exp_date);
    			p_for_int_rate_bid := p_rates_table(1);
    			p_for_int_rate_ask := p_rates_table(2);
    			p_dom_int_rate_bid := p_rates_table(3);
			p_dom_int_rate_ask := p_rates_table(4);



			--Call to get implied volatility from curve if needed
			if (p_volatility IS null) THEN
				p_rate_types.delete;
    				p_base_currencies.delete;
    				p_data_sides.delete;
				p_contra_currencies.delete;
				p_interp_methods:= SYSTEM.QRM_VARCHAR_TABLE('DEFAULT','DEFAULT');
				p_rate_types:=SYSTEM.QRM_VARCHAR_TABLE('FXVOL', 'FXVOL');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy, p_foreign_ccy);
				p_contra_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_ccy, p_domestic_ccy);
				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID', 'ASK');
				p_day_count_bases:=SYSTEM.QRM_VARCHAR_TABLE('ACTUAL365',
				   'ACTUAL365');


			--Call to get volatility values
				p_rates_table := get_rates_from_base(p_rate_types, p_base_currencies,
					 p_contra_currencies, p_quote_bases,
					 p_interp_methods, p_data_sides,
					 p_day_count_bases,p_interest_quote,
					 p_currency_quote,p_spot_date,
					 p_exp_date);
				p_vol_bid:= p_rates_table(1);
				p_volatility:=p_rates_table(1);
				p_vol_ask:= p_rates_table(2);

			else
				p_vol_bid:=p_volatility;
				p_vol_ask:=p_volatility;
			end if;

			--Values set to be passed back as default used
			p_domestic_day_count:='ACTUAL365';
			p_foreign_day_count:='ACTUAL365';


  			IF (g_proc_level>=g_debug_level) THEN
  			   xtr_risk_debug_pkg.dpop('fxo_calculator: ' || 'Calculation Based On Defaults');
  			END IF;









		--Optional Curve Data
		ELSIF (p_indicator = 'C') THEN
			IF (g_proc_level>=g_debug_level) THEN
			   xtr_risk_debug_pkg.dpush('fxo_calculator: ' || 'Calculation Based On Curves');
			END IF;
		    	-- GET DEFAULT CURVES

			--need dummy table of contra currencies
			p_contra_currencies:= SYSTEM.QRM_VARCHAR_TABLE('DUMMY');
			--If all curves are not input, defaults are gotten
			if (p_foreign_curve IS null) then
				p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy);
				p_curve_codes := get_curves_from_base(p_curve_types,
					      p_base_currencies,
					      p_contra_currencies);
				p_foreign_curve := p_curve_codes(1);
     			end if;
     			if (p_domestic_curve IS null) then
				p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_ccy);
        			p_curve_codes := get_curves_from_base(p_curve_types,
					      p_base_currencies,
					      p_contra_currencies);
				p_domestic_curve := p_curve_codes(1);
			end if;
    			if (p_volatility_curve IS null AND p_volatility IS null) then
				p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('FXVOL');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy);
				p_contra_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_ccy);
				p_curve_codes := get_curves_from_base(p_curve_types,
						p_base_currencies,
						p_contra_currencies);
				p_volatility_curve := p_curve_codes(1);

			end if;

  			-- GET DEFAULT RATES based on CURVES
    			-- first do SPOT RATES
			p_quote_bases:=GET_SPOT_QUOTATION_BASIS(p_foreign_ccy, p_domestic_ccy, p_ow_spot_rates);
			p_foreign_quote_usd:= p_quote_bases(1);
			p_domestic_quote_usd:= p_quote_bases(2);


			--curve codes are null on spot rates
 			p_curve_codes := SYSTEM.QRM_VARCHAR_TABLE('DUMMY', 'DUMMY');
    			p_day_count_bases := SYSTEM.QRM_VARCHAR_TABLE('DUMMY', 'DUMMY');
			p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE('DEFAULT', 'DEFAULT');
			p_contra_currencies := SYSTEM.QRM_VARCHAR_TABLE('DUMMY', 'DUMMY');
		    	-- calculate Rates
			-- this follows the calculator table across each row
        		-- first do Spot Rates
    			if (p_foreign_ccy = 'USD' AND p_domestic_ccy <> 'USD') then
				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT','SPOT');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_ccy, p_domestic_ccy);
				p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_quote_usd,
					   p_domestic_quote_usd);
				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK');
    			elsif (p_domestic_ccy = 'USD' AND p_foreign_ccy <> 'USD') then
				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT','SPOT');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy, p_foreign_ccy);
				p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_quote_usd,p_foreign_quote_usd);
				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK');
    			elsif (p_foreign_ccy <> 'USD' AND p_domestic_ccy <> 'USD') then
				p_contra_currencies := SYSTEM.QRM_VARCHAR_TABLE('DUMMY', 'DUMMY', 'DUMMY', 'DUMMY');
    				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT','SPOT','SPOT','SPOT');
    				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy,p_foreign_ccy,
					p_domestic_ccy, p_domestic_ccy);
    				p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_quote_usd, p_foreign_quote_usd,
				       	p_domestic_quote_usd,p_domestic_quote_usd);
    				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK','BID','ASK');
				p_curve_codes := SYSTEM.QRM_VARCHAR_TABLE('DUMMY', 'DUMMY', 'DUMMY', 'DUMMY');
    				p_day_count_bases := SYSTEM.QRM_VARCHAR_TABLE('DUMMY', 'DUMMY', 'DUMMY', 'DUMMY');
				p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE('DEFAULT', 'DEFAULT', 'DEFAULT', 'DEFAULT');
    			end if;


			--Gets spot rates
			p_rates_table := get_rates_from_curves(p_rate_types, p_curve_codes, p_base_currencies,
					 p_contra_currencies, p_quote_bases,
					 p_interp_methods, p_data_sides,
					 p_day_count_bases,p_interest_quote,
					 p_currency_quote,p_spot_date,
					 p_exp_date);

			if (p_foreign_ccy = 'USD' AND p_domestic_ccy <> 'USD') then
				p_for_spot_rate_bid := 1;
				p_for_spot_rate_ask := 1;
    				p_dom_spot_rate_bid := p_rates_table(1);
    				p_dom_spot_rate_ask := p_rates_table(2);
    			elsif (p_domestic_ccy = 'USD' AND p_foreign_ccy <> 'USD') then
				p_for_spot_rate_bid := p_rates_table(1);
				p_for_spot_rate_ask := p_rates_table(2);
				p_dom_spot_rate_bid := 1;
				p_dom_spot_rate_ask := 1;
    			elsif (p_neither_usd) then
				p_for_spot_rate_bid := p_rates_table(1);
				p_for_spot_rate_ask := p_rates_table(2);
    				p_dom_spot_rate_bid := p_rates_table(3);
    				p_dom_spot_rate_ask := p_rates_table(4);
    			end if;




			  -- now get INTEREST RATES
    			p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD','YIELD','YIELD','YIELD');
    			p_curve_codes := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_curve,p_foreign_curve,
				       p_domestic_curve,p_domestic_curve);
    			p_base_currencies.delete;
    			p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy,p_foreign_ccy,
					   p_domestic_ccy,p_domestic_ccy);
    			p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_interpolation,
				p_foreign_interpolation, p_domestic_interpolation, p_domestic_interpolation);

    			p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID','ASK','BID','ASK');
    			p_day_count_bases := SYSTEM.QRM_VARCHAR_TABLE('ACTUAL365',
				'ACTUAL365','ACTUAL365','ACTUAL365');
    			p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE('DUMMY', 'DUMMY', 'DUMMY', 'DUMMY');
			p_contra_currencies:=SYSTEM.QRM_VARCHAR_TABLE('DUMMY', 'DUMMY', 'DUMMY', 'DUMMY');

    			p_rates_table := get_rates_from_curves(p_rate_types,p_curve_codes,
					   p_base_currencies,
					   p_contra_currencies,
					   p_quote_bases,p_interp_methods,
					   p_data_sides,p_day_count_bases,
					   p_interest_quote,p_currency_quote,
					   p_spot_date,
					   p_exp_date);
    			p_for_int_rate_bid := p_rates_table(1);
    			p_for_int_rate_ask := p_rates_table(2);
    			p_dom_int_rate_bid := p_rates_table(3);
    			p_dom_int_rate_ask := p_rates_table(4);


			--Call to get implied volatility from curve if needed
			if (p_volatility_curve IS null) THEN
				p_vol_bid:=p_volatility;
				p_vol_ask:=p_volatility;


			else

				p_rate_types.delete;
    				p_base_currencies.delete;
    				p_data_sides.delete;
				p_contra_currencies.delete;
				p_interp_methods:= SYSTEM.QRM_VARCHAR_TABLE('DEFAULT','DEFAULT');
				p_rate_types:=SYSTEM.QRM_VARCHAR_TABLE('FXVOL', 'FXVOL');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy, p_foreign_ccy);
				p_contra_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_ccy, p_domestic_ccy);
				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID', 'ASK');
				p_day_count_bases:=SYSTEM.QRM_VARCHAR_TABLE('30/360', '30/360');
				p_curve_codes:=SYSTEM.QRM_VARCHAR_TABLE(p_volatility_curve, p_volatility_curve);
				p_quote_bases:= SYSTEM.QRM_VARCHAR_TABLE('DUMMY', 'DUMMY');

				--Call to get volatility values
				p_rates_table := get_rates_from_curves(p_rate_types, p_curve_codes,
					 p_base_currencies,
					 p_contra_currencies, p_quote_bases,
					 p_interp_methods, p_data_sides,
					 p_day_count_bases,p_interest_quote,
					 p_currency_quote,p_spot_date,
					 p_exp_date);
				p_vol_bid:= p_rates_table(1);
				p_volatility:=p_rates_table(1);
				p_vol_ask:= p_rates_table(2);
			end if;

			--Values set to be passed back as default used
			p_domestic_day_count:='ACTUAL365';
			p_foreign_day_count:='ACTUAL365';


  			IF (g_proc_level>=g_debug_level) THEN
  			   xtr_risk_debug_pkg.dpop('fxo_calculator: ' || 'Calculation Based On Curves');
  			END IF;





		--Optional Rates Data
		ELSIF (p_indicator = 'R') THEN
			IF (g_proc_level>=g_debug_level) THEN
			   xtr_risk_debug_pkg.dpush('fxo_calculator: ' || 'Calculation Based On Rates');
			END IF;
     			-- if a spot rate is missing, go to base(defaults) section
     			p_curve_codes:=SYSTEM.QRM_VARCHAR_TABLE('DUMMY');
			p_contra_currencies:=SYSTEM.QRM_VARCHAR_TABLE('DUMMY');
			p_interp_methods:=SYSTEM.QRM_VARCHAR_TABLE('DUMMY');
			if (p_for_spot_rate_bid IS null) then
				if (p_foreign_ccy <> 'USD') then
	    				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT');
	    				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy);
	    				p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_quote_usd);
	    				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID');
    	    				p_rates_table := get_rates_from_curves(p_rate_types,
						p_curve_codes,
						p_base_currencies,
					   	p_contra_currencies,
						p_quote_bases,
						p_interp_methods,
					   	p_data_sides,
						p_day_count_bases,
						p_interest_quote,
					   	p_currency_quote,
					   	p_spot_date, p_exp_date);
    	    				p_for_spot_rate_bid := p_rates_table(1);
				else
	    				p_for_spot_rate_bid := 1;
				end if;
			-- get corresponding base ccy curve
     			end if;
     			if (p_for_spot_rate_ask IS null) then
				if (p_foreign_ccy <> 'USD') then
	    				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT');
	    				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy);
	    				p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_quote_usd);
	    				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('ASK');
    	    				p_rates_table := get_rates_from_curves(p_rate_types,
						p_curve_codes,
						p_base_currencies,
					   	p_contra_currencies,
						p_quote_bases,
						p_interp_methods,
					   	p_data_sides,
						p_day_count_bases,
						p_interest_quote,
					   	p_currency_quote,
					   	p_spot_date, p_exp_date);
    	    				p_for_spot_rate_ask := p_rates_table(1);
				else
	    				p_for_spot_rate_ask := 1;
				end if;
     			end if;
     			if (p_dom_spot_rate_bid IS null) then
				if (p_domestic_ccy <> 'USD') then
	    				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT');
	    				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_ccy);
	    				p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_quote_usd);
	    				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID');
    	    				p_rates_table := get_rates_from_curves(p_rate_types,
						p_curve_codes,
						p_base_currencies,
					   	p_contra_currencies,
						p_quote_bases,
						p_interp_methods,
					   	p_data_sides,
						p_day_count_bases,
						p_interest_quote,
					   	p_currency_quote,
					   	p_spot_date, p_exp_date);
    	    				p_dom_spot_rate_bid := p_rates_table(1);
				else
					p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT');
	    				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy);
	    				p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_quote_usd);
	    				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID');
	    				p_dom_spot_rate_bid := 1;
				end if;
     			end if;
     			if (p_dom_spot_rate_ask IS null) then
				if (p_domestic_ccy <> 'USD') then
	    				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT');
	    				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_ccy);
	    				p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_quote_usd);
	    				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('ASK');
    	    				p_rates_table := get_rates_from_curves(p_rate_types,
						p_curve_codes,
						p_base_currencies,
					   	p_contra_currencies,
						p_quote_bases,
						p_interp_methods,
					   	p_data_sides,
						p_day_count_bases,
						p_interest_quote,
					   	p_currency_quote,
					   	p_spot_date, p_exp_date);
    	   				p_dom_spot_rate_ask := p_rates_table(1);
				else
					p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('SPOT');
	    				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy);
	    				p_quote_bases := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_quote_usd);
	    				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID');
	    				p_dom_spot_rate_ask := 1;
				end if;
     			end if;

 		   	-- if INTEREST RATES are missing, first check if curve section is filled
     			-- if so, use curve;
     			-- else, go to base(defaults) section and default curve in curves section
     			if (p_for_int_rate_bid IS null) then
				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy);
				p_contra_currencies := SYSTEM.QRM_VARCHAR_TABLE('DUMMY');
				p_quote_bases:= SYSTEM.QRM_VARCHAR_TABLE('DUMMY');
 				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID');
				p_day_count_bases := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_day_count);
				-- if curve section is null, go to defaults
				if (p_foreign_curve IS null) then
	    				p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
	    				p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE('DEFAULT');
	    				p_curve_codes := get_curves_from_base(p_curve_types,
					      p_base_currencies,
					      p_contra_currencies);
	   				-- default curves section
	   				p_foreign_curve := p_curve_codes(1);
	   				p_foreign_interpolation := p_interp_methods(1);
				else
					-- curve section not null, use curve
	    				p_curve_codes := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_curve);
	    				p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_interpolation);
				end if;
				-- calculate rate
	    			p_rates_table := get_rates_from_curves(p_rate_types,
					p_curve_codes,p_base_currencies,p_contra_currencies,
					p_quote_bases,p_interp_methods,p_data_sides,
					p_day_count_bases,p_interest_quote,p_currency_quote,
					p_spot_date,p_exp_date);
				p_for_int_rate_bid := p_rates_table(1);
				IF (g_proc_level>=g_debug_level) THEN
				   xtr_risk_debug_pkg.dlog('fxo_calculator: ' || 'defaulted foreign bid rate',p_for_int_rate_bid);
				END IF;
     			end if;

			if (p_for_int_rate_ask IS null) then
				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy);
 				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('ASK');
				p_contra_currencies := SYSTEM.QRM_VARCHAR_TABLE('DUMMY');
				p_quote_bases:= SYSTEM.QRM_VARCHAR_TABLE('DUMMY');
				p_day_count_bases := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_day_count);
				-- if curve section is null, go to defaults
				if (p_foreign_curve IS null) then
	    				p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
	    				p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE('DEFAULT');
	    				p_curve_codes := get_curves_from_base(p_curve_types,
					      p_base_currencies,
					      p_contra_currencies);
	   				-- default curves section
	   				p_foreign_curve := p_curve_codes(1);
	   				p_foreign_interpolation := p_interp_methods(1);
				else
					-- curve section not null, use curve
	    				p_curve_codes := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_curve);
	    				p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_interpolation);
				end if;
				-- calculate rate
	    			p_rates_table := get_rates_from_curves(p_rate_types,
					p_curve_codes,p_base_currencies,p_contra_currencies,
					p_quote_bases,p_interp_methods,p_data_sides,
					p_day_count_bases,p_interest_quote,p_currency_quote,
					p_spot_date,p_exp_date);
					p_for_int_rate_ask := p_rates_table(1);
				IF (g_proc_level>=g_debug_level) THEN
				   xtr_risk_debug_pkg.dlog('fxo_calculator: ' || 'defaulted foreign ask rate',p_for_int_rate_ask);
				END IF;
     			end if;
			if (p_dom_int_rate_bid IS null) then
				p_contra_currencies := SYSTEM.QRM_VARCHAR_TABLE('DUMMY');
				p_quote_bases:= SYSTEM.QRM_VARCHAR_TABLE('DUMMY');
				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_ccy);
 				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID');
				p_day_count_bases := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_day_count);
				-- if curve section is null, go to defaults
				if (p_domestic_curve IS null) then
	    				p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
	    				p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE('DEFAULT');
	    				p_curve_codes := get_curves_from_base(p_curve_types,
					      p_base_currencies,
					      p_contra_currencies);
	   				-- default curves section
	   				p_domestic_curve := p_curve_codes(1);
	   				p_domestic_interpolation := p_interp_methods(1);
				else
					-- curve section not null, use curve
	    				p_curve_codes := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_curve);
	    				p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_interpolation);
				end if;
				-- calculate rate
	    			p_rates_table := get_rates_from_curves(p_rate_types,
					p_curve_codes,p_base_currencies,p_contra_currencies,
					p_quote_bases,p_interp_methods,p_data_sides,
					p_day_count_bases,p_interest_quote,p_currency_quote,
					p_spot_date,p_exp_date);
					p_dom_int_rate_bid := p_rates_table(1);
				IF (g_proc_level>=g_debug_level) THEN
				   xtr_risk_debug_pkg.dlog('fxo_calculator: ' || 'defaulted domestic bid rate',p_dom_int_rate_bid);
				END IF;
     			end if;
			if (p_dom_int_rate_ask IS null) then
				p_contra_currencies := SYSTEM.QRM_VARCHAR_TABLE('DUMMY');
				p_quote_bases:= SYSTEM.QRM_VARCHAR_TABLE('DUMMY');
				p_rate_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
				p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_ccy);
 				p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('ASK');
				p_day_count_bases := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_day_count);
				-- if curve section is null, go to defaults
				if (p_domestic_curve IS null) then
	    				p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('YIELD');
	    				p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE('DEFAULT');
	    				p_curve_codes := get_curves_from_base(p_curve_types,
					      p_base_currencies,
					      p_contra_currencies);
	   				-- default curves section
	   				p_domestic_curve := p_curve_codes(1);
	   				p_domestic_interpolation := p_interp_methods(1);
				else
					-- curve section not null, use curve
	    				p_curve_codes := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_curve);
	    				p_interp_methods := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_interpolation);
				end if;
				-- calculate rate
	    			p_rates_table := get_rates_from_curves(p_rate_types,
					p_curve_codes,p_base_currencies,p_contra_currencies,
					p_quote_bases,p_interp_methods,p_data_sides,
					p_day_count_bases,p_interest_quote,p_currency_quote,
					p_spot_date,p_exp_date);
				p_dom_int_rate_ask := p_rates_table(1);
				IF (g_proc_level>=g_debug_level) THEN
				   xtr_risk_debug_pkg.dlog('fxo_calculator: ' || 'defaulted domestic ask rate',p_dom_int_rate_bid);
				END IF;
     			end if;

			if (p_vol_bid IS null OR p_vol_ask IS null) THEN

				if (p_volatility_curve IS null) THEN
					if (p_volatility IS null) THEN
						p_curve_types := SYSTEM.QRM_VARCHAR_TABLE('FXVOL');
						p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy);
						p_contra_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_ccy);
						p_curve_codes := get_curves_from_base(p_curve_types,
						p_base_currencies,
						p_contra_currencies);
						p_volatility_curve := p_curve_codes(1);


					else

						if (p_vol_bid IS null) THEN
							p_vol_bid:=p_volatility;
						end if;
						if (p_vol_ask IS null) THEN
							p_vol_ask:=p_volatility;
						end if;
					end if;

				end if;
				if (p_volatility_curve IS NOT null) THEN
					p_interp_methods:= SYSTEM.QRM_VARCHAR_TABLE('DEFAULT','DEFAULT');
					p_rate_types:=SYSTEM.QRM_VARCHAR_TABLE('FXVOL', 'FXVOL');
					p_base_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_foreign_ccy, p_foreign_ccy);
					p_contra_currencies := SYSTEM.QRM_VARCHAR_TABLE(p_domestic_ccy, p_domestic_ccy);
					p_quote_bases:= SYSTEM.QRM_VARCHAR_TABLE('DUMMY', 'DUMMY');
					p_data_sides := SYSTEM.QRM_VARCHAR_TABLE('BID', 'ASK');
					p_day_count_bases:=SYSTEM.QRM_VARCHAR_TABLE('30/360', '30/360');
					p_curve_codes:=SYSTEM.QRM_VARCHAR_TABLE(p_volatility_curve, p_volatility_curve);

					--Call to get volatility values
					p_rates_table := get_rates_from_curves(p_rate_types, p_curve_codes,
							p_base_currencies,
					 		p_contra_currencies, p_quote_bases,
					 		p_interp_methods, p_data_sides,
					 		p_day_count_bases,p_interest_quote,
					 		p_currency_quote,p_spot_date,
					 		p_exp_date);

					if (p_vol_bid IS null) THEN
						p_vol_bid:= p_rates_table(1);
					end if;
					if (p_vol_ask IS null) THEN
						p_vol_ask:= p_rates_table(2);
					end if;
					p_volatility:=p_rates_table(1);
     				end if;
			else
				p_volatility:=p_vol_bid;

	     		end if;
  		IF (g_proc_level>=g_debug_level) THEN
  		   xtr_risk_debug_pkg.dpop('fxo_calculator: ' || 'Calculation Based On Rates');
  		END IF;

		END IF;





		--Gets Spot rate
		if (p_domestic_ccy = 'USD') THEN
			p_spot_rates:=XTR_FX_FORMULAS.FX_SPOT_RATE_CV(p_domestic_ccy, p_foreign_ccy,
				p_dom_spot_rate_bid, p_dom_spot_rate_ask, p_for_spot_rate_bid,
				p_for_spot_rate_ask, 'C', p_foreign_quote_usd);
		elsif (p_foreign_ccy = 'USD') THEN
			p_spot_rates:=XTR_FX_FORMULAS.FX_SPOT_RATE_CV(p_domestic_ccy, p_foreign_ccy,
				p_dom_spot_rate_bid, p_dom_spot_rate_ask, p_for_spot_rate_bid,
				p_for_spot_rate_ask, p_domestic_quote_usd, 'C');
		else
			p_spot_rates:=XTR_FX_FORMULAS.FX_SPOT_RATE_CV(p_domestic_ccy, p_foreign_ccy,
				p_dom_spot_rate_bid, p_dom_spot_rate_ask, p_for_spot_rate_bid,
				p_for_spot_rate_ask, p_domestic_quote_usd, p_foreign_quote_usd);
		end if;



		fx_option_price_in.p_SPOT_DATE:= p_spot_date;
		fx_option_price_in.p_MATURITY_DATE := p_exp_date;
		fx_option_price_in.p_RATE_DOM:=p_dom_int_rate_bid;
		fx_option_price_in.p_RATE_TYPE_DOM:=p_rate_type;
		fx_option_price_in.p_COMPOUND_FREQ_DOM:= 1;
		fx_option_price_in.p_DAY_COUNT_BASIS_DOM:=p_domestic_day_count;
		fx_option_price_in.p_RATE_FOR:=p_for_int_rate_ask;
		fx_option_price_in.p_RATE_TYPE_FOR:=p_rate_type;
		fx_option_price_in.p_COMPOUND_FREQ_FOR:= 1;
		fx_option_price_in.p_DAY_COUNT_BASIS_FOR:=p_foreign_day_count;
		fx_option_price_in.p_SPOT_RATE:=p_spot_rates(1);
		fx_option_price_in.p_STRIKE_RATE:=p_strike_price;
		fx_option_price_in.p_VOLATILITY:= p_vol_bid;







		XTR_FX_FORMULAS.FX_GK_OPTION_PRICE_CV(fx_option_price_in, fx_option_price_out);
		p_res_call_bid:=fx_option_price_out.p_CALL_PRICE;
		p_res_fxforward_bid:=fx_option_price_out.p_FX_FWD_RATE;


		fx_option_price_in.p_SPOT_RATE:=p_spot_rates(2);
		fx_option_price_in.p_RATE_DOM:=p_dom_int_rate_ask;
		fx_option_price_in.p_RATE_FOR:=p_for_int_rate_bid;
		XTR_FX_FORMULAS.FX_GK_OPTION_PRICE_CV(fx_option_price_in, fx_option_price_out);
		p_res_put_bid:=fx_option_price_out.p_PUT_PRICE;






		/* need to find what bid/ask sides are needed to calculate different prices */
		fx_option_price_in.p_volatility:= p_vol_ask;
		XTR_FX_FORMULAS.FX_GK_OPTION_PRICE_CV(fx_option_price_in, fx_option_price_out);
		p_res_call_ask:=fx_option_price_out.p_CALL_PRICE;
		p_res_fxforward_ask:=fx_option_price_out.p_FX_FWD_RATE;

		fx_option_price_in.p_SPOT_RATE:=p_spot_rates(1);
		fx_option_price_in.p_RATE_DOM:=p_dom_int_rate_bid;
		fx_option_price_in.p_RATE_FOR:=p_for_int_rate_ask;
		XTR_FX_FORMULAS.FX_GK_OPTION_PRICE_CV(fx_option_price_in, fx_option_price_out);
		p_res_put_ask:=fx_option_price_out.p_PUT_PRICE;





		if (p_foreign_ccy_amt IS null) THEN
			p_foreign_ccy_amt:=1;
		end if;

		p_res_call_fair_value_bid:=p_res_call_bid*p_foreign_ccy_amt;
		p_res_call_fair_value_ask:=p_res_call_ask*p_foreign_ccy_amt;
		p_res_put_fair_value_bid:=p_res_put_bid*p_foreign_ccy_amt;
		p_res_put_fair_value_ask:=p_res_put_ask*p_foreign_ccy_amt;

		--Get number of days for sensitivities function
		--p_days := p_exp_date- p_spot_date;
		XTR_CALC_P.calc_days_run_c(p_spot_date,p_exp_date,p_foreign_day_count,
		null,p_days,p_years);
		--Gets number of years
		p_years:=p_days/p_years;



		--Must convert interest rates into continuous for sensitivities calculations

		if (p_rate_type = 'P') THEN
			XTR_RATE_CONVERSION.COMPOUND_TO_CONTINUOUS_RATE(
						p_for_int_rate_bid, 1, p_for_cint_rate_bid);
			XTR_RATE_CONVERSION.COMPOUND_TO_CONTINUOUS_RATE(
						p_for_int_rate_ask, 1, p_for_cint_rate_ask);
			XTR_RATE_CONVERSION.COMPOUND_TO_CONTINUOUS_RATE(
						p_dom_int_rate_bid, 1, p_dom_cint_rate_bid);
			XTR_RATE_CONVERSION.COMPOUND_TO_CONTINUOUS_RATE(
						p_dom_int_rate_ask, 1, p_dom_cint_rate_ask);
		ELSE
			XTR_RATE_CONVERSION.SIMPLE_TO_CONTINUOUS_RATE(
						p_for_int_rate_bid, p_years, p_for_cint_rate_bid);
			XTR_RATE_CONVERSION.SIMPLE_TO_CONTINUOUS_RATE(
						p_for_int_rate_ask, p_years, p_for_cint_rate_ask);
			XTR_RATE_CONVERSION.SIMPLE_TO_CONTINUOUS_RATE(
						p_dom_int_rate_bid, p_years, p_dom_cint_rate_bid);
			XTR_RATE_CONVERSION.SIMPLE_TO_CONTINUOUS_RATE(
						p_dom_int_rate_ask, p_years, p_dom_cint_rate_ask);
		END IF;



		QRM_FX_FORMULAS.FX_GK_OPTION_SENS(p_days, p_for_cint_rate_bid, p_dom_cint_rate_bid,
						p_spot_rates(1), p_strike_price, p_vol_bid,
						p_res_delta_call_bid, p_res_delta_put_bid,
						p_res_theta_call_bid, p_res_theta_put_bid,
						p_res_rho_dom_call_bid, p_res_rho_dom_put_bid,
						p_res_rho_for_call_bid, p_res_rho_for_put_bid,
							p_res_gamma_bid, p_res_vega_bid);

		QRM_FX_FORMULAS.FX_GK_OPTION_SENS(p_days, p_for_cint_rate_ask, p_dom_cint_rate_ask,
						p_spot_rates(2), p_strike_price, p_vol_ask,
						p_res_delta_call_ask, p_res_delta_put_ask,
						p_res_theta_call_ask, p_res_theta_put_ask,
						p_res_rho_dom_call_ask, p_res_rho_dom_put_ask,
						p_res_rho_for_call_ask, p_res_rho_for_put_ask,
						p_res_gamma_ask, p_res_vega_ask);






	END IF;
	p_varchar_args(5):= p_interest_quote;
	p_varchar_args(6):= p_foreign_curve;
	p_varchar_args(7):= p_domestic_curve;
	p_varchar_args(8):= p_volatility_curve;
	p_varchar_args(9):=p_foreign_interpolation;
	p_varchar_args(10):= p_domestic_interpolation;
	p_varchar_args(11):=p_volatility_interpolation;
	p_varchar_args(12):=p_foreign_quote_usd;
	p_varchar_args(13):=p_domestic_quote_usd;
	p_varchar_args(14):=p_foreign_day_count;
	p_varchar_args(15):=p_domestic_day_count;
   	p_num_args(1):=p_implied_vol_price;
	p_num_args(2):=p_foreign_ccy_amt;
   	p_num_args(3):=p_strike_price;
   	p_num_args(4):=p_volatility;
   	p_num_args(5):=p_for_spot_rate_bid;
	p_num_args(6):=p_for_spot_rate_ask;
   	p_num_args(7):=p_dom_spot_rate_bid;
   	p_num_args(8):=p_dom_spot_rate_ask;
   	p_num_args(9):=p_for_int_rate_bid;
   	p_num_args(10):=p_for_int_rate_ask;
   	p_num_args(11):=p_dom_int_rate_bid;
   	p_num_args(12):=p_dom_int_rate_ask;
   	p_num_args(13):=p_vol_bid;
   	p_num_args(14):=p_vol_ask;
	p_num_args(15):=p_res_impl_vol;


	p_num_args(16):=p_res_call_bid;
	p_num_args(17):=p_res_call_ask;
	p_num_args(18):=p_res_put_bid;
	p_num_args(19):=p_res_put_ask;
	p_num_args(20):=p_res_fxforward_bid;
	p_num_args(21):=p_res_fxforward_ask;
	p_num_args(22):=p_res_call_fair_value_bid;
	p_num_args(23):=p_res_call_fair_value_ask;
	p_num_args(24):=p_res_put_fair_value_bid;
	p_num_args(25):=p_res_put_fair_value_ask;

	p_num_args(26):=p_res_delta_call_bid;
	p_num_args(27):=p_res_delta_call_ask;
	p_num_args(28):=p_res_delta_put_bid;
	p_num_args(29):=p_res_delta_put_ask;
	p_num_args(30):=p_res_gamma_bid;
	p_num_args(31):=p_res_gamma_ask;
	p_num_args(32):=p_res_theta_call_bid;
	p_num_args(33):=p_res_theta_call_ask;
	p_num_args(34):=p_res_theta_put_bid;
	p_num_args(35):=p_res_theta_put_ask;
	p_num_args(36):=p_res_vega_bid;
	p_num_args(37):=p_res_vega_ask;
	p_num_args(38):=p_res_rho_dom_call_bid;
	p_num_args(39):=p_res_rho_dom_call_ask;
	p_num_args(40):=p_res_rho_dom_put_bid;
	p_num_args(41):=p_res_rho_dom_put_ask;
	p_num_args(42):=p_res_rho_for_call_bid;
	p_num_args(43):=p_res_rho_for_call_ask;
	p_num_args(44):=p_res_rho_for_put_bid;
	p_num_args(45):=p_res_rho_for_put_ask;

	EXCEPTION
  	WHEN e_no_int_rates THEN
    		fnd_msg_pub.add;
		IF (g_ERROR_level>=g_debug_level) THEN --BUG 3236479
        	   xtr_risk_debug_pkg.dlog('EXCEPTION','E_NO_INT_RATES',
		      'QRM_CALCULATORS_P.FXO_CALCULATOR',G_ERROR_LEVEL);
     		END IF;
  	WHEN e_no_rate_curve THEN
    		fnd_msg_pub.add;
		IF (g_ERROR_level>=g_debug_level) THEN --BUG 3236479
        	   xtr_risk_debug_pkg.dlog('EXCEPTION','E_NO_RATE_CURVE',
		      'QRM_CALCULATORS_P.FXO_CALCULATOR',G_ERROR_LEVEL);
     		END IF;
  	WHEN e_no_spot_rates THEN
	        IF (g_ERROR_level>=g_debug_level) THEN --BUG 3236479
        	   xtr_risk_debug_pkg.dlog('EXCEPTION','E_NO_SPOT_RATES',
		      'QRM_CALCULATORS_P.FXO_CALCULATOR',G_ERROR_LEVEL);
     		END IF;
    		fnd_msg_pub.add;
	WHEN QRM_MM_FORMULAS.e_exceed_vol_upper_bound THEN
	        IF (g_ERROR_level>=g_debug_level) THEN --BUG 3236479
        	   xtr_risk_debug_pkg.dlog('EXCEPTION','E_EXCEED_VOL_UPPER_BOUND',
		      'QRM_CALCULATORS_P.FXO_CALCULATOR',G_ERROR_LEVEL);
     		END IF;
		fnd_msg_pub.add;

	IF (g_proc_level>=g_debug_level) THEN
	   xtr_risk_debug_pkg.dpop(null,'QRM_CALCULATORS_P.fxo_calculator');
	END IF;

END fxo_calculator;

END;

/
