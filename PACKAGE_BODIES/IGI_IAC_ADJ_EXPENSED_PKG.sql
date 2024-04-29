--------------------------------------------------------
--  DDL for Package Body IGI_IAC_ADJ_EXPENSED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_ADJ_EXPENSED_PKG" AS
-- $Header: igiiadxb.pls 120.17.12010000.2 2010/06/24 11:52:50 schakkin ship $

    --===========================FND_LOG.START=====================================

    g_state_level NUMBER;
    g_proc_level  NUMBER;
    g_event_level NUMBER;
    g_excep_level NUMBER;
    g_error_level NUMBER;
    g_unexp_level NUMBER;
    g_path        VARCHAR2(100);

    --===========================FND_LOG.END=====================================

    PROCEDURE do_round ( p_amount in out NOCOPY number, p_book_type_code in varchar2) is
      l_path varchar2(150) := g_path||'do_round(p_amount,p_book_type_code)';
      l_amount number     := p_amount;
      l_amount_old number := p_amount;
      --l_path varchar2(150) := g_path||'do_round';
    begin
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'--- Inside Round() ---');
       IF IGI_IAC_COMMON_UTILS.Iac_Round(X_Amount => l_amount, X_Book => p_book_type_code)
       THEN
          p_amount := l_amount;
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'IGI_IAC_COMMON_UTILS.Iac_Round is TRUE');
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_amount = '||p_amount);
       ELSE
          p_amount := round( l_amount, 2);
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'IGI_IAC_COMMON_UTILS.Iac_Round is FALSE');
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_amount = '||p_amount);
       END IF;
    exception when others then
      p_amount := l_amount_old;
      igi_iac_debug_pkg.debug_unexpected_msg(l_path);
      Raise;
    END;

    PROCEDURE debug_adj_asset(p_asset igi_iac_types.iac_adj_hist_asset_info) IS
        l_path_name VARCHAR2(150);
    BEGIN
        l_path_name := g_path||'debug_adj_asset';
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'asset_id...............'|| p_asset.asset_id);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'book_type_code.........'|| p_asset.book_type_code);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'cost...................'|| p_asset.cost );
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'original_Expensed..........'|| p_asset.original_cost);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'adjusted_Expensed..........'|| p_asset.adjusted_cost);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'salvage_value..........'|| p_asset.salvage_value );
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'life_in_months.........'|| p_asset.life_in_months);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'rate_adjustment_factor..'||p_asset.rate_adjustment_factor);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'period_counter_fully_reserved '|| p_asset.period_counter_fully_reserved);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'recoverable_Expensed.......'|| p_asset.recoverable_cost);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'date_placed_in_service..'||p_asset.date_placed_in_service);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'deprn_start_date........'||p_asset.deprn_start_date);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'deprn_periods_elapsed...'||p_asset.deprn_periods_elapsed);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'deprn_periods_current_year..'||p_asset.deprn_periods_current_year);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'prior year periods..'|| p_asset.deprn_periods_prior_year);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'last_period_counter.........'|| p_asset.last_period_counter);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'ytd_deprn...................'|| p_asset.ytd_deprn);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'deprn_reserve................'|| p_asset.deprn_reserve);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'pys_deprn_reserve............'|| p_asset.pys_deprn_reserve);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'deprn_amount................'|| p_asset.deprn_amount);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'depreciate_flag................'|| p_asset.depreciate_flag);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'deprn_adjustment_amount................'|| p_asset.deprn_adjustment_amount);
    END debug_adj_asset;

    FUNCTION Calculate_New_Balances( p_asset_iac_adj_info IN OUT NOCOPY  igi_iac_types.iac_adj_hist_asset_info,
                                    P_asset_balance IN OUT NOCOPY  igi_iac_asset_balances%ROWTYPE,
                                    p_adj_hist IN igi_iac_adjustments_history%ROWTYPE)
    RETURN  boolean IS

        CURSOR c_period_num_for_catchup IS
           SELECT period_num_for_catchup
           FROM igi_iac_book_controls
           WHERE book_type_code = p_asset_iac_adj_info.book_type_code;

        CURSOR C_get_curr_reval_rate IS
          SELECT irr.*
          FROM igi_iac_revaluation_rates irr
          WHERE irr.asset_id = p_asset_iac_adj_info.asset_id
          AND irr.book_type_code = p_asset_iac_adj_info.book_type_code
          AND irr.latest_record = 'Y'
          AND irr.revaluation_id = (SELECT max(iar.revaluation_id)
                                    FROM igi_iac_revaluation_rates iar ,
                                        igi_iac_transaction_headers ith
                                    WHERE iar.asset_id = p_asset_iac_adj_info.asset_id
                                    AND iar.book_type_code = p_asset_iac_adj_info.book_type_code
                                    AND ith.book_type_code = p_asset_iac_adj_info.book_type_code
                                    AND ith.asset_id = p_asset_iac_adj_info.asset_id
                                    AND iar.adjustment_id = ith.adjustment_id
                                    AND ith.adjustment_status IN ('COMPLETE','RUN'));

        l_get_curr_reval_rate       igi_iac_revaluation_rates%ROWTYPE;
        l_cumulative_backlog        igi_iac_asset_balances.backlog_deprn_reserve%TYPE;
        l_current_backlog           igi_iac_asset_balances.backlog_deprn_reserve%TYPE;
        l_Reval_rsv_backlog         igi_iac_asset_balances.backlog_deprn_reserve%TYPE;
        l_operating_acct_backlog    igi_iac_asset_balances.backlog_deprn_reserve%TYPE;
        l_dpis_period_info          igi_iac_types.prd_rec;
        l_period_info               igi_iac_types.prd_rec;
        l_latest_reval_period_info  igi_iac_types.prd_rec;
        l_dpis_price_index          Number;
        l_prev_price_index          Number;
        l_period_num_for_catchup    Number;
        l_curr_price_index          Number;
        l_reval_factor              Number;
        l_prev_reval_factor         Number;
        l_Prev_cumm_reval_factor    Number;
        l_cumm_reval_factor         Number;
        l_period_counter            Number;
        l_fa_asset_info             igi_iac_types.fa_hist_asset_info;
        l_latest_closed_period      fa_deprn_periods.period_counter%TYPE;
        l_last_deprn_period         igi_iac_types.prd_rec;
        l_deprn_periods_elapsed     NUMBER;
        l_deprn_periods_current_year  NUMBER;

        l_path_name VARCHAR2(150);
    BEGIN
        l_path_name := g_path||'Calculate_New_Balances';

        IF NOT igi_iac_common_utils.get_Period_Info_for_Date(p_asset_iac_adj_info.book_type_code,
                                                             P_asset_iac_adj_info.date_placed_in_service,
                                                             l_dpis_period_info) THEN
            RETURN FALSE;
        END IF;

        IF NOT igi_iac_common_utils.get_price_index_value(
                                        p_asset_iac_adj_info.book_type_code,
                                        p_asset_iac_adj_info.asset_id,
                                        l_dpis_period_info.period_name,
                                        l_dpis_price_index) THEN
            RETURN FALSE;
        END IF;
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'Backlog:Price Index for DPIS :'||TO_CHAR(l_dpis_price_index));
        l_prev_price_index := l_dpis_price_index;

        -- get revalaution period num
        OPEN c_period_num_for_catchup;
        FETCH c_period_num_for_catchup INTO l_period_num_for_catchup;
        CLOSE c_period_num_for_catchup;

        -- get the latest  revaluation of the asset
        OPEN C_get_curr_reval_rate;
        FETCH C_get_curr_reval_rate INTO l_get_curr_reval_rate;
        CLOSE c_get_curr_reval_rate;

        l_fa_asset_info.cost := p_asset_iac_adj_info.cost;
        l_fa_asset_info.adjusted_cost := p_asset_iac_adj_info.adjusted_cost;
        l_fa_asset_info.original_cost := p_asset_iac_adj_info.original_cost;
        l_fa_asset_info.salvage_value := p_asset_iac_adj_info.salvage_value;
        l_fa_asset_info.life_in_months := p_asset_iac_adj_info.life_in_months;
        l_fa_asset_info.rate_adjustment_factor := p_asset_iac_adj_info.rate_adjustment_factor;
        l_fa_asset_info.period_counter_fully_reserved := p_asset_iac_adj_info.period_counter_fully_reserved;
        l_fa_asset_info.adjusted_recoverable_cost := p_asset_iac_adj_info.adjusted_recoverable_cost;
        l_fa_asset_info.recoverable_cost := p_asset_iac_adj_info.recoverable_cost;
        l_fa_asset_info.date_placed_in_service := p_asset_iac_adj_info.date_placed_in_service;
        l_fa_asset_info.deprn_periods_elapsed := p_asset_iac_adj_info.deprn_periods_elapsed;
        l_fa_asset_info.deprn_periods_current_year := p_asset_iac_adj_info.deprn_periods_current_year;
        l_fa_asset_info.deprn_periods_prior_year := p_asset_iac_adj_info.deprn_periods_prior_year;
        l_fa_asset_info.last_period_counter := p_asset_iac_adj_info.last_period_counter;
        l_fa_asset_info.gl_posting_allowed_flag := p_asset_iac_adj_info.gl_posting_allowed_flag;
        l_fa_asset_info.ytd_deprn := p_asset_iac_adj_info.ytd_deprn;
        l_fa_asset_info.deprn_reserve := p_asset_iac_adj_info.deprn_reserve;
        l_fa_asset_info.pys_deprn_reserve := p_asset_iac_adj_info.pys_deprn_reserve;
        l_fa_asset_info.deprn_amount := p_asset_iac_adj_info.deprn_amount;
        l_fa_asset_info.deprn_start_date := p_asset_iac_adj_info.deprn_start_date;
        l_fa_asset_info.depreciate_flag := p_asset_iac_adj_info.depreciate_flag;

        l_latest_closed_period := p_adj_hist.period_counter - 1;
        IF NOT igi_iac_ytd_engine.Calculate_YTD
                                ( p_asset_iac_adj_info.book_type_code,
                                p_asset_iac_adj_info.asset_id,
                                l_fa_asset_info,
                                l_dpis_period_info.period_counter,
                                l_latest_closed_period,
                                'EXPENSED') THEN
                    RETURN FALSE;
        END IF;

        p_asset_iac_adj_info.last_period_counter := l_fa_asset_info.last_period_counter ;
        p_asset_iac_adj_info.ytd_deprn := l_fa_asset_info.ytd_deprn ;
        p_asset_iac_adj_info.deprn_amount := l_fa_asset_info.deprn_amount ;

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'ytd_deprn from YTD engine :'||l_fa_asset_info.ytd_deprn);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'deprn_amount from YTD engine :'||l_fa_asset_info.deprn_amount);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'Last period counter from YTD engine :'||l_fa_asset_info.last_period_counter);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'Last revaluation period for the asset : '|| to_char(l_get_curr_reval_rate.period_counter));

        IF NOT igi_iac_common_utils.get_period_info_for_counter(p_asset_iac_adj_info.book_type_code,
                                                                    l_get_curr_reval_rate.period_counter,
                                                                    l_latest_reval_period_info) THEN
            igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
                p_full_path => l_path_name,
                p_string => 'Backlog:*** Error in fetching period information');
            RETURN FALSE;
        END IF;

        l_cumulative_backlog:= 0;
        l_reval_rsv_backlog := 0;
        l_operating_acct_backlog := 0;
        l_Prev_cumm_reval_factor := 1;
        l_cumm_reval_factor := 1;
        l_current_backlog:=0;

        FOR l_period_counter IN l_dpis_period_info.period_counter..(l_latest_reval_period_info.period_counter) LOOP

            IF NOT igi_iac_common_utils.get_period_info_for_counter(p_asset_iac_adj_info.book_type_code,
                                                                        l_period_counter,
                                                                        l_period_info) THEN
                igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
                    p_full_path => l_path_name,
                    p_string => 'Backlog:*** Error in fetching period information');
                RETURN FALSE;
            END IF;

    	        /* if the period in the loop is a catchup period for revaluation
	            then initialize revaluation structures              */
            IF (l_period_num_for_catchup = l_period_info.period_num)
                OR (l_period_info.period_counter = l_latest_reval_period_info.period_counter) THEN

                IF (l_period_info.period_counter = l_latest_reval_period_info.period_counter) THEN
                    l_cumm_reval_factor := l_get_curr_reval_rate.cumulative_reval_factor;
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'Cumulative reval factor from last reval : '||l_cumm_reval_factor);
                ELSE
                    IF NOT (igi_iac_common_utils.get_price_index_value(
                                            p_asset_iac_adj_info.book_type_code,
                                            p_asset_iac_adj_info.asset_id,
                                            l_period_info.period_name,
                                            l_curr_price_index)) THEN
                        RETURN FALSE;
                    END IF;
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => ' Backlog:    Period counter for revaluation  :'|| l_period_info.period_counter);
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'Backlog:     Price Index for current revaluation catchup period :'||TO_CHAR(l_curr_price_index));

                    IF (l_prev_price_index = 9999.99 OR l_curr_price_index = 9999.99 OR l_prev_price_index = 0) THEN
                        RETURN FALSE;
                    END IF;
                    l_reval_factor := l_curr_price_index / l_prev_price_index ;
                    l_cumm_reval_factor := l_reval_factor * l_Prev_cumm_reval_factor;
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'Current Price Index value :'||l_curr_price_index);
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'Cumulative reval factor from catchup : '||l_cumm_reval_factor);
                END IF;

                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                    p_full_path => l_path_name,
                    p_string => 'Backlog:  Current Reval Factor : '||TO_CHAR(l_reval_factor));
                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                    p_full_path => l_path_name,
                    p_string => 'Backlog:  Cummulative  Reval Factor : '||TO_CHAR(l_cumm_reval_factor));
                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                    p_full_path => l_path_name,
                    p_string => 'Backlog:  Previous    Cummulative  Reval Factor : '||TO_CHAR(l_Prev_cumm_reval_factor));

                l_deprn_periods_elapsed := l_period_info.period_counter - l_dpis_period_info.period_counter + 1;
                l_deprn_periods_current_year := l_period_info.period_num;
                IF (l_period_info.fiscal_year = l_dpis_period_info.fiscal_year) THEN
                    l_deprn_periods_current_year := l_period_info.period_counter - l_dpis_period_info.period_counter + 1;
                    l_deprn_periods_elapsed := l_deprn_periods_current_year;
                END IF;

                IF (l_fa_asset_info.last_period_counter < l_period_info.period_counter) THEN

                    IF NOT igi_iac_common_utils.get_period_info_for_counter(p_asset_iac_adj_info.book_type_code,
                                                                l_fa_asset_info.last_period_counter,
                                                                l_last_deprn_period) THEN
                        RETURN FALSE;
                    END IF;

                    l_deprn_periods_elapsed := l_last_deprn_period.period_counter - l_dpis_period_info.period_counter + 1;
                    IF (l_period_info.fiscal_year = l_last_deprn_period.fiscal_year) THEN
                        l_deprn_periods_current_year := l_last_deprn_period.period_num;
                    END IF;

                    IF (l_dpis_period_info.fiscal_year = l_last_deprn_period.fiscal_year) THEN
                        l_deprn_periods_current_year := l_last_deprn_period.period_num - l_dpis_period_info.period_num + 1;
                    END IF;

                    IF (l_last_deprn_period.fiscal_year < l_period_info.fiscal_year ) THEN
                        l_deprn_periods_current_year := 0;
                    END IF;
                END IF;

                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                    p_full_path => l_path_name,
                    p_string => 'periods elapsed..'||   l_deprn_periods_elapsed);
                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                    p_full_path => l_path_name,
                    p_string => 'current year  periods ...'|| l_deprn_periods_current_year);
                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                    p_full_path => l_path_name,
                    p_string => 'FA deprn period..'||l_fa_asset_info.deprn_amount);
                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                    p_full_path => l_path_name,
                    p_string => 'previous factor..'|| l_Prev_cumm_reval_factor);
                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                    p_full_path => l_path_name,
                    p_string => 'current factor..'|| l_cumm_reval_factor);

                IF (l_cumm_reval_factor >= 1 AND l_Prev_cumm_reval_factor < 1) THEN
                    /* Movement from <1 to 1 */
                    l_current_backlog := ((l_deprn_periods_elapsed - l_deprn_periods_current_year)
                                    * l_fa_asset_info.deprn_amount) * (1 - l_prev_cumm_reval_factor);
		    do_round(l_current_backlog,p_asset_iac_adj_info.book_type_code);
                    l_operating_acct_backlog := l_Operating_acct_backlog + l_current_backlog;
                    l_cumulative_backlog := l_cumulative_backlog + l_current_backlog;
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'current backlog1 ..'|| l_current_backlog);

                    /* Movement from 1 to >1 */
                    l_current_backlog :=  ((l_deprn_periods_elapsed - l_deprn_periods_current_year)
                                    * l_fa_asset_info.deprn_amount) * (l_cumm_reval_factor - 1);
		    do_round(l_current_backlog,p_asset_iac_adj_info.book_type_code);
                    l_Reval_Rsv_Backlog := l_Reval_Rsv_Backlog  + l_current_backlog;
                    l_cumulative_backlog := l_cumulative_backlog + l_current_backlog;
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'current backlog2 ..'|| l_current_backlog);

                ELSIF (l_cumm_reval_factor < 1 AND l_Prev_cumm_reval_factor >= 1) THEN
                    /* Movement from >1 to 1 */
                    l_current_backlog := ((l_deprn_periods_elapsed - l_deprn_periods_current_year)
                                    * l_fa_asset_info.deprn_amount) * (1 - l_Prev_cumm_reval_factor);
		    do_round(l_current_backlog,p_asset_iac_adj_info.book_type_code);
                    l_Reval_Rsv_Backlog := l_Reval_Rsv_Backlog + l_current_backlog;
                    l_cumulative_backlog := l_cumulative_backlog + l_current_backlog;
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'current backlog3 ..'|| l_current_backlog);

                    /* Movement from 1 to <1 */
                    l_current_backlog :=  ((l_deprn_periods_elapsed - l_deprn_periods_current_year)
                                    * l_fa_asset_info.deprn_amount) * (l_cumm_reval_factor - 1);
		   do_round(l_current_backlog,p_asset_iac_adj_info.book_type_code);
                    l_Operating_Acct_Backlog := l_Operating_Acct_Backlog + l_current_backlog;
                    l_cumulative_backlog := l_cumulative_backlog + l_current_backlog;
                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'current backlog4 ..'|| l_current_backlog);
                ELSE
                    l_current_backlog :=  ((l_deprn_periods_elapsed - l_deprn_periods_current_year)
                                        * l_fa_asset_info.deprn_amount) * (l_cumm_reval_factor - l_Prev_cumm_reval_factor);
		    do_round(l_current_backlog,p_asset_iac_adj_info.book_type_code);
                    l_cumulative_backlog := l_cumulative_backlog + l_current_backlog;

                    IF (l_cumm_reval_factor >= 1) THEN
                              l_Reval_Rsv_Backlog := l_Reval_Rsv_Backlog + l_current_backlog;
                    ELSE
                         l_Operating_Acct_Backlog := l_Operating_Acct_Backlog + l_current_backlog;

                    END IF;

                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'current backlog5 ..'|| l_current_backlog);
                END IF;
                l_prev_price_index := l_curr_price_index;
                l_Prev_cumm_reval_factor := l_cumm_reval_factor;

                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                    p_full_path => l_path_name,
                    p_string => 'Backlog Accumalted...'|| l_cumulative_backlog);
                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                    p_full_path => l_path_name,
                    p_string => 'Backlog RR...'|| l_Reval_Rsv_backlog);
                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                    p_full_path => l_path_name,
                    p_string => 'Backlog OP...'|| l_Operating_Acct_backlog);
            END IF;

        END LOOP;

        IF NOT (igi_iac_common_utils.iac_round(l_cumulative_backlog,p_asset_iac_adj_info.book_type_code)) THEN
            RETURN FALSE;
        END IF;
        IF NOT (igi_iac_common_utils.iac_round(l_Reval_Rsv_backlog,p_asset_iac_adj_info.book_type_code)) THEN
            RETURN FALSE;
        END IF;
        IF NOT (igi_iac_common_utils.iac_round(l_Operating_Acct_backlog,p_asset_iac_adj_info.book_type_code)) THEN
            RETURN FALSE;
        END IF;

        p_asset_balance.backlog_deprn_reserve := l_cumulative_backlog;
        p_asset_balance.deprn_reserve := p_asset_iac_adj_info.deprn_reserve * (l_cumm_reval_factor - 1)
                                            - l_cumulative_backlog;
	do_round(p_asset_balance.deprn_reserve,p_asset_iac_adj_info.book_type_code);
        IF NOT (igi_iac_common_utils.iac_round(p_asset_balance.deprn_reserve,p_asset_iac_adj_info.book_type_code)) THEN
            RETURN FALSE;
        END IF;

        p_asset_balance.net_book_value := p_asset_balance.adjusted_cost - p_asset_balance.deprn_reserve
                                                - l_cumulative_backlog;

        IF l_cumm_reval_factor >= 1 THEN
            p_asset_balance.reval_reserve := p_asset_balance.net_book_value;
            p_asset_balance.Operating_acct := 0 - l_Operating_Acct_backlog;
            p_asset_balance.General_Fund := p_asset_balance.adjusted_cost - l_Reval_Rsv_backlog - p_asset_balance.reval_reserve;
        ELSE
            p_asset_balance.reval_reserve := 0;
            p_asset_balance.Operating_acct := p_asset_balance.adjusted_cost - l_Operating_Acct_backlog;
            p_asset_balance.General_Fund := 0 - l_Reval_Rsv_backlog - p_asset_balance.reval_reserve;
        END IF;

        RETURN TRUE;
    EXCEPTION
        WHEN OTHERS THEN
            igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
            RETURN FALSE;
    END Calculate_New_Balances;

    FUNCTION Do_Expensed_Adj
                    (p_asset_iac_adj_info igi_iac_types.iac_adj_hist_asset_info,
                    P_asset_iac_dist_info igi_iac_types.iac_adj_dist_info_tab,
                    p_adj_hist               igi_iac_adjustments_history%ROWTYPE,
                    p_event_id               number)    --R12 uptake
        RETURN BOOLEAN
    IS

        CURSOR c_get_asset_balance (p_asset_id  igi_iac_asset_balances.asset_id%TYPE,
                                    P_book_type_code igi_iac_asset_balances.book_type_code%TYPE
                                     ) IS
   	        SELECT *
   	        FROM igi_iac_asset_balances
   	        WHERE asset_id = p_asset_id
   	        AND book_type_code = p_book_type_code
 	        AND period_counter = (SELECT MAX(period_counter)
                                    FROM igi_iac_asset_balances
                           	        WHERE asset_id = p_asset_id
                           	        AND book_type_code = p_book_type_code);

                 /* Cursor to get balance information for each distribution of asset */
   	    CURSOR c_get_inactive_det_balances(p_asset_id igi_iac_det_balances.asset_id%TYPE,
                                    P_book_type_code igi_iac_asset_balances.book_type_code%TYPE,
                                    p_prev_adjustment_id igi_iac_det_balances.adjustment_id%TYPE) IS
   	        SELECT *
   	        FROM igi_iac_det_balances
   	        WHERE asset_id = p_asset_id
   	        AND book_type_code = p_book_type_code
   	        AND adjustment_id =  p_prev_adjustment_id
            AND NVL(active_flag,'Y') = 'N'  ;

        CURSOR  C_get_iac_fa_deprn(P_book_type_code igi_iac_asset_balances.book_type_code%TYPE,
                                    p_asset_id igi_iac_det_balances.asset_id%TYPE ,
                                   P_distribution_id igi_iac_det_balances.distribution_id%TYPE
   	    	         		        , p_prev_adjustment_id igi_iac_det_balances.adjustment_id%TYPE) IS

          SELECT *
          FROM igi_iac_fa_deprn
          WHERE book_type_code =P_book_type_code
          AND asset_id =p_asset_id
          AND adjustment_id =p_prev_adjustment_id
          AND distribution_id = P_distribution_id;

  	    /* Cursor to get total units assigned for the Asset from FA */
   	    CURSOR c_get_fa_asset(p_asset_id fa_additions.asset_id%TYPE) IS
   	        SELECT asset_category_id,current_units
   	        FROM fa_additions
   	        WHERE asset_id = p_asset_id;

        CURSOR c_get_active_det_balances (cp_book_type_code in varchar2
                        , cp_asset_id      in number
                        , cp_adjustment_id   in number
                        ) is
            SELECT fdh.units_assigned,
                idb.*
            FROM   fa_distribution_history fdh,
                igi_iac_det_balances idb
            WHERE  fdh.book_type_code = cp_book_type_code
            AND    fdh.asset_id       = cp_asset_id
            AND    fdh.date_ineffective IS NULL
            AND    idb.book_type_code = cp_book_type_code
            AND    idb.asset_id = cp_asset_id
            AND    idb.distribution_id = fdh.distribution_id
            AND    idb.adjustment_id = cp_adjustment_id;

   	    l_prev_asset_balance  	 igi_iac_asset_balances%ROWTYPE;
        l_asset_balance_mvmt    igi_iac_asset_balances%ROWTYPE;
        l_curr_asset_balance  igi_iac_asset_balances%ROWTYPE;
   	    l_det_balances 	 igi_iac_det_balances%ROWTYPE;
        l_get_iac_fa_deprn   C_get_iac_fa_deprn%ROWTYPE;
   	    l_adjustment_id  	 igi_iac_adjustments.adjustment_id%TYPE;
        l_adjustment_id_out  igi_iac_adjustments.adjustment_id%TYPE;
   	    l_prev_adjustment_id igi_iac_adjustments.adjustment_id%TYPE;
   	    l_category_id    	 fa_additions.asset_category_id%TYPE;
   	    l_asset_units	 fa_additions.current_units%TYPE;
   	    l_distribution_units fa_distribution_history.units_assigned%TYPE;
        l_Transaction_Type_Code	igi_iac_transaction_headers.transaction_type_code%TYPE;
        l_Transaction_Id      igi_iac_transaction_headers.transaction_header_id%TYPE;
        l_Mass_Reference_ID	  igi_iac_transaction_headers.mass_reference_id%TYPE;
        l_Adjustment_Status   igi_iac_transaction_headers.adjustment_status%TYPE;
        l_backlog  Number;
        l_rowid ROWID;
        l_sob_id number;
        l_coa_id number;
        l_currency varchar2(30);
        l_precision number;
        l_revl_rsv_ccid gl_code_combinations.code_combination_id%TYPE;
        l_blog_rsv_ccid gl_code_combinations.code_combination_id%TYPE;
        l_op_exp_ccid   gl_code_combinations.code_combination_id%TYPE;
        l_gen_fund_ccid gl_code_combinations.code_combination_id%TYPE;
        l_asset_cost_ccid gl_code_combinations.code_combination_id%TYPE;
        l_deprn_rsv_ccid gl_code_combinations.code_combination_id%TYPE;
        l_deprn_exp_ccid gl_code_combinations.code_combination_id%TYPE;
        l_asset_iac_adj_info    igi_iac_types.Iac_adj_hist_asset_info;
        l_iac_inactive_dists_ytd    NUMBER ;
        l_iac_current_ytd           NUMBER ;
        l_iac_active_dists_ytd      NUMBER ;
        l_fa_inactive_dists_ytd     NUMBER ;
        l_fa_current_ytd            NUMBER ;
        l_fa_active_dists_ytd       NUMBER ;
        l_total_dist_units          NUMBER ;
        l_dist_prorate_factor       NUMBER;
        l_total_db                  IGI_IAC_TYPES.iac_det_balances;
        l_remaining_db              IGI_IAC_TYPES.iac_det_balances;
        l_current_db                IGI_IAC_TYPES.iac_det_balances;
        l_operatg_cost              NUMBER ;
        l_operatg_net               NUMBER ;
        l_operatg_blog              NUMBER ;
        l_reserve_blog              NUMBER ;
        l_deprn_blog                NUMBER ;
        l_reserve_cost              NUMBER ;
        l_operatg_ytd               NUMBER ;
        l_total_db_fa               igi_iac_fa_deprn%ROWTYPE;
        l_remaining_db_fa           igi_iac_fa_deprn%ROWTYPE;
        l_current_db_fa             igi_iac_fa_deprn%ROWTYPE;
        l_ytd_prorate_dists_tab     igi_iac_types.prorate_dists_tab;
        l_ytd_prorate_dists_idx     binary_integer;
        l_path_name                 VARCHAR2(150);
        l_dist_ytd_factor           NUMBER;
        idx_YTD                     BINARY_INTEGER;


    BEGIN -- do expensed  adj
        l_Transaction_Type_Code	:= NULL;
        l_Transaction_Id      := NULL;
        l_Mass_Reference_ID	  := NULL;
        l_Adjustment_Status   := NULL;

        l_iac_inactive_dists_ytd     := 0;
        l_iac_current_ytd            := 0;
        l_iac_active_dists_ytd       := 0;
        l_fa_inactive_dists_ytd      := 0;
        l_fa_current_ytd             := 0;
        l_fa_active_dists_ytd        := 0;
        l_total_dist_units           := 0;
        l_operatg_cost               := 0;
        l_operatg_net                := 0;
        l_operatg_blog               := 0;
        l_reserve_blog               := 0;
        l_deprn_blog                 := 0;
        l_reserve_cost               := 0;
        l_operatg_ytd                := 0;
        l_path_name  := g_path||'do_expensed_adj';

        debug_adj_asset( p_asset_iac_adj_info);

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => '    IN Process adjustments');
        l_Transaction_Type_Code := NULL;
        l_Transaction_Id := NULL;
        l_Mass_Reference_ID := NULL;
        l_adjustment_id_out := NULL;
        l_prev_adjustment_id := NULL;
        l_Adjustment_Status := NULL;

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Get previous adjustment');
        IF NOT igi_iac_common_utils.Get_Latest_Transaction (
                       		X_book_type_code    => p_asset_iac_adj_info.book_type_code,
                       		X_asset_id          => p_asset_iac_adj_info.asset_id,
                       		X_Transaction_Type_Code	=> l_Transaction_Type_Code,
                       		X_Transaction_Id	=> l_Transaction_Id,
                       		X_Mass_Reference_ID	=> l_Mass_Reference_ID,
                       		X_Adjustment_Id		=> l_adjustment_id_out,
                       		X_Prev_Adjustment_Id => l_prev_adjustment_id,
                       		X_Adjustment_Status	=> l_Adjustment_Status) THEN
            igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
            p_full_path => l_path_name,
            p_string => '*** Error in fetching the latest transaction');
            RETURN FALSE;
        END IF;
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' previous adjustment..is '||l_prev_adjustment_id);
        l_adjustment_id := NULL;
		l_rowid := NULL;

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Create a new adjustment');
        igi_iac_trans_headers_pkg.insert_row(
	    			 X_rowid		 => l_rowid ,
					 X_adjustment_id	 => l_adjustment_id ,
					 X_transaction_header_id => P_adj_hist.transaction_header_id_in,
					 X_adjustment_id_out	 => NULL ,
					 X_transaction_type_code => 'DEPRECIATION' ,
					 X_transaction_date_entered => SYSDATE ,
					 X_mass_refrence_id	 => NULL ,
					 X_transaction_sub_type	 => 'ADJUSTMENT',
					 X_book_type_code	 => p_asset_iac_adj_info.book_type_code,
					 X_asset_id		 => p_asset_iac_adj_info.asset_id,
 					 X_category_id		 => P_adj_hist.category_id, -- p_asset_iac_adj_info.category_id ,
					 X_adj_deprn_start_date	 => NULL, --p_asset_iac_adj_info.last_period_counter   ,
					 X_revaluation_type_flag => NULL,
					 X_adjustment_status	 => 'COMPLETE' ,
					 X_period_counter	 => p_adj_hist.period_counter,
                     X_event_id          => p_event_id ) ;

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => '  New adjustment id :'||TO_CHAR(l_adjustment_id));

              -- get the IAC asset balance record;
        OPEN c_get_asset_balance(p_asset_iac_adj_info.asset_id,
                                 p_asset_iac_adj_info.book_type_code);
        FETCH c_get_asset_balance INTO l_prev_asset_balance;
		CLOSE c_get_asset_balance;

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Asset_id:'||l_prev_asset_balance.asset_id);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Period_counter :'||l_prev_asset_balance.period_counter);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Net book value :'||TO_CHAR(l_prev_asset_balance.net_book_value));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Adjusted Cost :'||TO_CHAR(l_prev_asset_balance.adjusted_cost));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Operating Account :'||TO_CHAR(l_prev_asset_balance.operating_acct));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Reval Reserve :'||TO_CHAR(l_prev_asset_balance.reval_reserve));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Deprn Amount :'||TO_CHAR(l_prev_asset_balance.deprn_amount));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Deprn Reserve :'||TO_CHAR(l_prev_asset_balance.deprn_reserve));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Backlog Deprn Reserve :'||TO_CHAR(l_prev_asset_balance.backlog_deprn_reserve));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' General Fund :'||TO_CHAR(l_prev_asset_balance.general_fund));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Current Reval Factor :'||TO_CHAR(l_prev_asset_balance.current_reval_factor));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Cumulative Reval Factor :'||TO_CHAR(l_prev_asset_balance.Cumulative_reval_factor));

            -- get the movement of the adjustment amount ;
        l_curr_asset_balance := l_prev_asset_balance;
        l_asset_iac_adj_info := p_asset_iac_adj_info;

        IF NOT Calculate_New_Balances( l_asset_iac_adj_info,
                                        l_curr_asset_balance,
                                        p_adj_hist)THEN
            igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
                p_full_path => l_path_name,
                p_string => ' Error in backlog calculation');
            RETURN FALSE;
        END IF;

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Asset: after new calucation ');
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Asset_id:'||l_curr_asset_balance.asset_id);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Period_counter :'||l_curr_asset_balance.period_counter);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Net book value :'||TO_CHAR(l_curr_asset_balance.net_book_value));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Adjusted Cost :'||TO_CHAR(l_curr_asset_balance.adjusted_cost));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Operating Account :'||TO_CHAR(l_curr_asset_balance.operating_acct));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Reval Reserve :'||TO_CHAR(l_curr_asset_balance.reval_reserve));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Deprn Amount :'||TO_CHAR(l_curr_asset_balance.deprn_amount));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Deprn Reserve :'||TO_CHAR(l_curr_asset_balance.deprn_reserve));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Backlog Deprn Reserve :'||TO_CHAR(l_curr_asset_balance.backlog_deprn_reserve));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' General Fund :'||TO_CHAR(l_curr_asset_balance.general_fund));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Current Reval Factor :'||TO_CHAR(l_curr_asset_balance.current_reval_factor));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Cumulative Reval Factor :'||TO_CHAR(l_curr_asset_balance.Cumulative_reval_factor));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' IAC deprn resrevre..... amount '||P_asset_iac_adj_info.deprn_reserve);

        IF (p_adj_hist.period_counter > l_asset_iac_adj_info.last_period_counter) THEN
            l_curr_asset_balance.deprn_amount := 0;
        ELSE
            l_curr_asset_balance.deprn_amount := l_asset_iac_adj_info.deprn_amount * (l_curr_asset_balance.Cumulative_reval_factor-1);
	    do_round(l_curr_asset_balance.deprn_amount,p_asset_iac_adj_info.book_type_code);
            IF NOT (igi_iac_common_utils.iac_round(l_curr_asset_balance.deprn_amount,l_curr_asset_balance.book_type_code)) THEN
                RETURN FALSE;
            END IF;
        END IF;
        l_iac_current_ytd := l_asset_iac_adj_info.ytd_deprn * (l_curr_asset_balance.Cumulative_reval_factor-1);
	do_round(l_iac_current_ytd,p_asset_iac_adj_info.book_type_code);
        IF NOT (igi_iac_common_utils.iac_round(l_iac_current_ytd,l_curr_asset_balance.book_type_code)) THEN
            RETURN FALSE;
        END IF;
        l_fa_current_ytd := l_asset_iac_adj_info.ytd_deprn;
        IF NOT (igi_iac_common_utils.iac_round(l_fa_current_ytd,l_curr_asset_balance.book_type_code)) THEN
            RETURN FALSE;
        END IF;

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Asset: after new calucation ');
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Asset_id:'||l_curr_asset_balance.asset_id);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Period_counter :'||l_curr_asset_balance.period_counter);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Net book value :'||TO_CHAR(l_curr_asset_balance.net_book_value));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Adjusted Cost :'||TO_CHAR(l_curr_asset_balance.adjusted_cost));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Operating Account :'||TO_CHAR(l_curr_asset_balance.operating_acct));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Reval Reserve :'||TO_CHAR(l_curr_asset_balance.reval_reserve));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Deprn Amount :'||TO_CHAR(l_curr_asset_balance.deprn_amount));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Deprn Reserve :'||TO_CHAR(l_curr_asset_balance.deprn_reserve));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Backlog Deprn Reserve :'||TO_CHAR(l_curr_asset_balance.backlog_deprn_reserve));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' General Fund :'||TO_CHAR(l_curr_asset_balance.general_fund));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Current Reval Factor :'||TO_CHAR(l_curr_asset_balance.current_reval_factor));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Cumulative Reval Factor :'||TO_CHAR(l_curr_asset_balance.Cumulative_reval_factor));

        l_asset_balance_mvmt.asset_id := l_curr_asset_balance.asset_id;
        l_asset_balance_mvmt.book_type_code := l_curr_asset_balance.book_type_code;
        l_asset_balance_mvmt.period_counter := p_adj_hist.period_counter;
        l_asset_balance_mvmt.net_book_value := l_curr_asset_balance.net_book_value - l_prev_asset_balance.net_book_value;
        l_asset_balance_mvmt.adjusted_cost := l_curr_asset_balance.adjusted_cost - l_prev_asset_balance.adjusted_cost;
        l_asset_balance_mvmt.operating_acct := l_curr_asset_balance.operating_acct - l_prev_asset_balance.operating_acct;
        l_asset_balance_mvmt.reval_reserve := l_curr_asset_balance.reval_reserve - l_prev_asset_balance.reval_reserve;
        l_asset_balance_mvmt.deprn_amount := l_curr_asset_balance.deprn_amount;
        l_asset_balance_mvmt.deprn_reserve := l_curr_asset_balance.deprn_reserve - l_prev_asset_balance.deprn_reserve;
        l_asset_balance_mvmt.backlog_deprn_reserve := l_curr_asset_balance.backlog_deprn_reserve - l_prev_asset_balance.backlog_deprn_reserve;
        l_asset_balance_mvmt.General_Fund := l_curr_asset_balance.General_Fund - l_prev_asset_balance.General_Fund;

        OPEN c_get_fa_asset(l_curr_asset_balance.asset_id);
		FETCH c_get_fa_asset INTO l_category_id,l_asset_units;
		CLOSE c_get_fa_asset;
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => '     Units assigned for the asset :'||TO_CHAR(l_asset_units));

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' Processing incative distributions ');
        FOR l_det_balances IN c_get_inactive_det_balances(l_asset_balance_mvmt.asset_id,
                                                              l_asset_balance_mvmt.book_type_code,
                                                              l_prev_adjustment_id  )
        LOOP
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => ' Inactive distribution' || l_det_balances.distribution_id);
            l_rowid := NULL;
            IGI_IAC_DET_BALANCES_PKG.insert_row (
                            x_rowid                    => l_rowid,
                            x_adjustment_id            => l_adjustment_id,
                            x_asset_id                 => l_det_balances.asset_id,
                            x_distribution_id          => l_det_balances.distribution_id,
                            x_book_type_code           => l_det_balances.book_type_code,
                            x_period_counter           => l_asset_balance_mvmt.period_counter,
                            x_adjustment_cost          => l_det_balances.adjustment_cost,
                            x_net_book_value           => l_det_balances.net_book_value,
                            x_reval_reserve_cost       => l_det_balances.reval_reserve_cost,
                            x_reval_reserve_backlog    => l_det_balances.reval_reserve_backlog,
                            x_reval_reserve_gen_fund   => l_det_balances.reval_reserve_gen_fund,
                            x_reval_reserve_net        => l_det_balances.reval_reserve_net,
                            x_operating_acct_cost      => l_det_balances.operating_acct_cost,
                            x_operating_acct_backlog   => l_det_balances.operating_acct_backlog,
                            x_operating_acct_net       => l_det_balances.operating_acct_net,
                            x_operating_acct_ytd       => l_det_balances.operating_acct_ytd,
                            x_deprn_period             => l_det_balances.deprn_period,
                            x_deprn_ytd                => l_det_balances.deprn_ytd,
                            x_deprn_reserve            => l_det_balances.deprn_reserve,
                            x_deprn_reserve_backlog    => l_det_balances.deprn_reserve_backlog,
                            x_general_fund_per         => l_det_balances.general_fund_per,
                            x_general_fund_acc         => l_det_balances.general_fund_acc,
                            x_last_reval_date          => l_det_balances.last_reval_date,
                            x_current_reval_factor     => l_det_balances.current_reval_factor,
                            x_cumulative_reval_factor  => l_det_balances.cumulative_reval_factor,
                            x_active_flag              => l_det_balances.active_flag,
                            x_mode                     => 'R' );
            l_iac_inactive_dists_ytd := l_iac_inactive_dists_ytd + l_det_balances.deprn_ytd;

            OPEN C_get_iac_fa_deprn(l_det_balances.book_type_code,
                                             l_det_balances.asset_id,
                                             l_det_balances.distribution_id,
                                             l_prev_adjustment_id
                                              );
            FETCH c_get_iac_fa_deprn INTO l_get_iac_fa_deprn;
            IF C_get_iac_fa_deprn%FOUND THEN
                l_rowid := NULL;
                igi_iac_fa_deprn_pkg.insert_row(
    					x_rowid			    => l_rowid,
						x_book_type_code	=> l_det_balances.book_type_code,
						x_asset_id		    => l_det_balances.asset_id,
						x_distribution_id	=> l_det_balances.distribution_id,
						x_period_counter	=> l_asset_balance_mvmt.period_counter,
						x_adjustment_id		=> l_adjustment_id,
						x_deprn_period		=> l_get_iac_fa_deprn.deprn_period,
						x_deprn_ytd		    => l_get_iac_fa_deprn.deprn_ytd ,
						x_deprn_reserve		=> l_get_iac_fa_deprn.deprn_reserve,
						x_active_flag		=> l_get_iac_fa_deprn.active_flag,
						x_mode			    => 'R');
            END IF;
            CLOSE c_get_iac_fa_deprn;
            l_fa_inactive_dists_ytd := l_fa_inactive_dists_ytd + l_get_iac_fa_deprn.deprn_ytd;
        END LOOP;

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' End of Processing incative distributions ');
        l_iac_active_dists_ytd := l_iac_current_ytd - l_iac_inactive_dists_ytd;
        l_fa_active_dists_ytd := l_fa_current_ytd - l_fa_inactive_dists_ytd;

        if l_curr_asset_balance.adjusted_cost >= 0 then
            l_operatg_cost := 0;
            l_operatg_net  := l_asset_balance_mvmt.Operating_Acct;
            l_operatg_blog := l_operatg_cost - l_operatg_net;

            l_reserve_blog := l_asset_balance_mvmt.backlog_deprn_reserve + l_asset_balance_mvmt.Operating_acct;
            l_deprn_blog   := l_asset_balance_mvmt.backlog_deprn_reserve;
            l_reserve_cost := l_asset_balance_mvmt.adjusted_cost;
        else
            l_operatg_net  := l_asset_balance_mvmt.operating_acct;
            l_operatg_blog := l_asset_balance_mvmt.backlog_deprn_reserve + l_asset_balance_mvmt.General_Fund;
            l_operatg_cost := l_asset_balance_mvmt.adjusted_cost;
            l_deprn_blog   := l_asset_balance_mvmt.backlog_deprn_reserve;

            l_reserve_cost := 0;
            l_reserve_blog := l_reserve_cost - l_asset_balance_mvmt.General_Fund;
        end if;

        IF p_asset_iac_adj_info.period_counter_fully_reserved IS NOT NULL THEN
            l_asset_balance_mvmt.deprn_amount := 0;
            l_asset_iac_adj_info.deprn_amount := 0;
            l_curr_asset_balance.deprn_amount := 0;
        END IF;

        l_total_db.adjustment_id           :=  l_adjustment_id;
        l_total_db.asset_id                :=  l_asset_balance_mvmt.asset_id;
        l_total_db.distribution_id         :=  -1;
        l_total_db.book_type_code          :=  l_asset_balance_mvmt.book_type_code;
        l_total_db.period_counter          :=  l_asset_balance_mvmt.period_counter;
        l_total_db.adjustment_cost         :=  l_asset_balance_mvmt.adjusted_cost;
        l_total_db.reval_reserve_cost      :=  l_reserve_cost;
        l_total_db.reval_reserve_backlog   :=  l_reserve_blog;
        l_total_db.reval_reserve_gen_fund  :=  l_asset_balance_mvmt.general_fund;
        l_total_db.reval_reserve_net       :=  l_asset_balance_mvmt.reval_reserve;
        l_total_db.operating_acct_cost     :=  l_operatg_cost ;
        l_total_db.operating_acct_backlog  :=  l_operatg_blog;
        l_total_db.operating_acct_net      :=  l_operatg_net;
        l_total_db.operating_acct_ytd      :=  l_operatg_ytd;
        l_total_db.deprn_period            :=  l_asset_balance_mvmt.deprn_amount;
        l_total_db.deprn_ytd               :=  l_iac_active_dists_ytd;

        l_total_db.deprn_reserve           :=  l_asset_balance_mvmt.deprn_reserve;
        l_total_db.deprn_reserve_backlog   :=  l_deprn_blog;

        l_total_db.general_fund_per        :=  l_asset_balance_mvmt.deprn_amount;
        l_total_db.general_fund_acc        :=  l_asset_balance_mvmt.general_fund;
        l_total_db.last_reval_date         :=  sysdate;
        l_total_db.current_reval_factor    :=  l_asset_balance_mvmt.current_reval_factor;
        l_total_db.cumulative_reval_factor :=  l_asset_balance_mvmt.cumulative_reval_factor;
        l_total_db.net_book_value          :=  l_total_db.adjustment_cost - l_total_db.deprn_reserve -
                                        l_total_db.deprn_reserve_backlog;
        l_total_db.active_flag             :=  NULL;

        l_total_db_fa.deprn_period  := l_asset_iac_adj_info.deprn_amount;
        l_total_db_fa.deprn_ytd     := l_fa_active_dists_ytd;
        l_total_db_fa.deprn_reserve := l_asset_iac_adj_info.deprn_reserve;
        l_remaining_db := l_total_db;
        l_remaining_db_fa := l_total_db_fa;

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => ' +acctg creation get gl information');
        IF NOT IGI_IAC_COMMON_UTILS.GET_BOOK_GL_INFO
                              ( X_BOOK_TYPE_CODE      => l_asset_balance_mvmt.book_type_code
                              , SET_OF_BOOKS_ID       => l_sob_id
                              , CHART_OF_ACCOUNTS_ID  => l_coa_id
                              , CURRENCY              => l_currency
                              , PRECISION             => l_precision
                                 )
        THEN
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => ' +acctg creation unable to get gl info');
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => ' end create_iac_acctg');
            RETURN FALSE;
        END IF;

        IF NOT igi_iac_reval_utilities.prorate_active_dists_YTD ( fp_asset_id => l_asset_balance_mvmt.asset_id
                       , fp_book_type_code => l_asset_balance_mvmt.book_type_code
                       , fp_current_period_counter => l_asset_balance_mvmt.period_counter
                       , fp_prorate_dists_tab => l_ytd_prorate_dists_tab
                       , fp_prorate_dists_idx => l_ytd_prorate_dists_idx
                       ) THEN
            RETURN FALSE;
        END IF;

        FOR l_det_balances IN c_get_active_det_balances(l_asset_balance_mvmt.book_type_code,l_asset_balance_mvmt.asset_id,l_prev_adjustment_id)
        LOOP
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => ' +DET BALANCES');
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_adjustment_id            => '|| l_det_balances.adjustment_id);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_asset_id                 =>'|| l_det_balances.asset_id);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_distribution_id          => '||l_det_balances.distribution_id);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_book_type_code           => '||l_det_balances.book_type_code);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_period_counter           => '||l_det_balances.period_counter);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_adjustment_cost          => '||l_det_balances.adjustment_cost);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_net_book_value           => '||l_det_balances.net_book_value);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_reval_reserve_cost       => '||l_det_balances.reval_reserve_cost);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_reval_reserve_backlog    => '||l_det_balances.reval_reserve_backlog);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_reval_reserve_gen_fund   => '||l_det_balances.reval_reserve_gen_fund);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_reval_reserve_net        => '||l_det_balances.reval_reserve_net);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_operating_acct_cost      => '||l_det_balances.operating_acct_cost);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_operating_acct_backlog   => '||l_det_balances.operating_acct_backlog);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_operating_acct_net       => '||l_det_balances.operating_acct_net);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_operating_acct_ytd       => '||l_det_balances.operating_acct_ytd);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_deprn_period             => '||l_det_balances.deprn_period);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_deprn_ytd                => '||l_det_balances.deprn_ytd);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_deprn_reserve            => '||l_det_balances.deprn_reserve);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_deprn_reserve_backlog    => '||l_det_balances.deprn_reserve_backlog);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_general_fund_per         => '||l_det_balances.general_fund_per);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_general_fund_acc         => '||l_det_balances.general_fund_acc);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_last_reval_date          => '||l_det_balances.last_reval_date);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_current_reval_factor     => '||l_det_balances.current_reval_factor);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_cumulative_reval_factor  => '||l_det_balances.cumulative_reval_factor);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_active_flag              => '||l_det_balances.active_flag);

            l_total_dist_units := l_total_dist_units + l_det_balances.units_assigned;
            l_dist_prorate_factor := l_det_balances.units_assigned / l_asset_units;

            l_dist_ytd_factor := 0;
            idx_YTD := l_YTD_prorate_dists_tab.FIRST;
            WHILE idx_YTD <= l_YTD_prorate_dists_tab.LAST LOOP
                IF l_YTD_prorate_dists_tab(idx_YTD).distribution_id = l_det_balances.distribution_id THEN
                    l_dist_ytd_factor := l_YTD_prorate_dists_tab(idx_YTD).ytd_prorate_factor;
                    EXIT;
                END IF;
                idx_ytd := l_YTD_prorate_dists_tab.Next(idx_ytd);
            END LOOP;

            IF l_curr_asset_balance.adjusted_cost >= 0 THEN
                l_reserve_cost := l_dist_prorate_factor * l_total_db.adjustment_cost;
		do_round(l_reserve_cost,l_det_balances.book_type_code);
                l_reserve_blog := l_dist_prorate_factor * l_total_db.reval_reserve_backlog;
		do_round(l_reserve_blog,l_det_balances.book_type_code);
                l_operatg_cost := 0;
                l_operatg_blog := l_dist_prorate_factor * l_total_db.operating_acct_backlog;
		do_round(l_operatg_blog,l_det_balances.book_type_code);
                l_operatg_net  := l_operatg_cost - l_operatg_blog;
                l_deprn_blog   := l_dist_prorate_factor * l_total_db.deprn_reserve_backlog;
		do_round(l_deprn_blog,l_det_balances.book_type_code);
            ELSE
                l_operatg_blog := l_dist_prorate_factor * l_total_db.operating_acct_backlog;
		do_round(l_operatg_blog,l_det_balances.book_type_code);
                l_operatg_cost := l_dist_prorate_factor * l_total_db.operating_acct_cost;
		do_round(l_operatg_cost,l_det_balances.book_type_code);
                l_operatg_net  := l_operatg_cost  - l_operatg_blog;
                l_reserve_cost := 0;
                l_reserve_blog := l_dist_prorate_factor * l_total_db.reval_reserve_backlog;
		do_round(l_reserve_blog,l_det_balances.book_type_code);
                l_deprn_blog   := l_dist_prorate_factor * l_total_db.deprn_reserve_backlog;
		do_round(l_deprn_blog,l_det_balances.book_type_code);
            END IF;

            IF (l_total_dist_units < l_asset_units) THEN
                l_current_db.adjustment_id           :=  l_adjustment_id;
                l_current_db.asset_id                :=  l_det_balances.asset_id;
                l_current_db.distribution_id         :=  l_det_balances.distribution_id;
                l_current_db.book_type_code          :=  l_det_balances.book_type_code;
                l_current_db.period_counter          :=  l_asset_balance_mvmt.period_counter;
                l_current_db.adjustment_cost         :=  l_dist_prorate_factor * l_total_db.adjustment_cost;
		do_round(l_current_db.adjustment_cost,l_det_balances.book_type_code);
                l_current_db.net_book_value          :=  l_dist_prorate_factor * l_total_db.net_book_value;
		do_round(l_current_db.net_book_value,l_det_balances.book_type_code);
                l_current_db.reval_reserve_cost      :=  l_reserve_cost;
                l_current_db.reval_reserve_backlog   :=  l_reserve_blog;
                l_current_db.reval_reserve_gen_fund  :=  l_dist_prorate_factor * l_total_db.reval_reserve_gen_fund;
		do_round(l_current_db.reval_reserve_gen_fund,l_det_balances.book_type_code);
                l_current_db.reval_reserve_net       :=  l_dist_prorate_factor * l_total_db.reval_reserve_net;
		do_round(l_current_db.reval_reserve_net,l_det_balances.book_type_code);
                l_current_db.operating_acct_cost     :=  l_operatg_cost;
                l_current_db.operating_acct_backlog  :=  l_operatg_blog;
                l_current_db.operating_acct_net      :=  l_operatg_net;
                l_current_db.operating_acct_ytd      :=  l_det_balances.operating_acct_ytd + l_operatg_net;
                l_current_db.deprn_period            :=  l_dist_prorate_factor * l_total_db.deprn_period;
		do_round(l_current_db.deprn_period,l_det_balances.book_type_code);
                l_current_db.deprn_ytd               :=  l_dist_ytd_factor * l_total_db.deprn_ytd;
		do_round(l_current_db.deprn_ytd,l_det_balances.book_type_code);
                l_current_db.deprn_reserve           :=  l_dist_prorate_factor * l_total_db.deprn_reserve;
		do_round(l_current_db.deprn_reserve,l_det_balances.book_type_code);
                l_current_db.deprn_reserve_backlog   :=  l_deprn_blog;
                l_current_db.general_fund_per        :=  l_dist_prorate_factor * l_total_db.general_fund_per;
		do_round(l_current_db.general_fund_per,l_det_balances.book_type_code);
                l_current_db.general_fund_acc        :=  l_dist_prorate_factor * l_total_db.general_fund_acc;
		do_round(l_current_db.general_fund_acc,l_det_balances.book_type_code);
                l_current_db.last_reval_date         :=  l_det_balances.last_reval_date;
                l_current_db.current_reval_factor    :=  l_det_balances.current_reval_factor;
                l_current_db.cumulative_reval_factor :=  l_det_balances.cumulative_reval_factor;
                l_current_db.active_flag             :=  l_det_balances.active_flag;

                IF NOT (igi_iac_common_utils.iac_round(l_current_db.adjustment_cost,l_det_balances.book_type_code)) THEN
                    RETURN FALSE;
                END IF;
                IF NOT (igi_iac_common_utils.iac_round(l_current_db.net_book_value,l_det_balances.book_type_code)) THEN
                    RETURN FALSE;
                END IF;
                IF NOT (igi_iac_common_utils.iac_round(l_current_db.reval_reserve_cost,l_det_balances.book_type_code)) THEN
                    RETURN FALSE;
                END IF;
                IF NOT (igi_iac_common_utils.iac_round(l_current_db.reval_reserve_backlog,l_det_balances.book_type_code)) THEN
                    RETURN FALSE;
                END IF;
                IF NOT (igi_iac_common_utils.iac_round(l_current_db.reval_reserve_gen_fund,l_det_balances.book_type_code)) THEN
                    RETURN FALSE;
                END IF;
                IF NOT (igi_iac_common_utils.iac_round(l_current_db.reval_reserve_net,l_det_balances.book_type_code)) THEN
                    RETURN FALSE;
                END IF;
                IF NOT (igi_iac_common_utils.iac_round(l_current_db.operating_acct_cost,l_det_balances.book_type_code)) THEN
                    RETURN FALSE;
                END IF;
                IF NOT (igi_iac_common_utils.iac_round(l_current_db.operating_acct_backlog,l_det_balances.book_type_code)) THEN
                    RETURN FALSE;
                END IF;
                IF NOT (igi_iac_common_utils.iac_round(l_current_db.operating_acct_net,l_det_balances.book_type_code)) THEN
                    RETURN FALSE;
                END IF;
                IF NOT (igi_iac_common_utils.iac_round(l_current_db.operating_acct_ytd,l_det_balances.book_type_code)) THEN
                    RETURN FALSE;
                END IF;
                IF NOT (igi_iac_common_utils.iac_round(l_current_db.deprn_period,l_det_balances.book_type_code)) THEN
                    RETURN FALSE;
                END IF;
                IF NOT (igi_iac_common_utils.iac_round(l_current_db.deprn_ytd,l_det_balances.book_type_code)) THEN
                    RETURN FALSE;
                END IF;
                IF NOT (igi_iac_common_utils.iac_round(l_current_db.deprn_reserve,l_det_balances.book_type_code)) THEN
                    RETURN FALSE;
                END IF;
                IF NOT (igi_iac_common_utils.iac_round(l_current_db.deprn_reserve_backlog,l_det_balances.book_type_code)) THEN
                    RETURN FALSE;
                END IF;
                IF NOT (igi_iac_common_utils.iac_round(l_current_db.general_fund_per,l_det_balances.book_type_code)) THEN
                    RETURN FALSE;
                END IF;
                IF NOT (igi_iac_common_utils.iac_round(l_current_db.general_fund_acc,l_det_balances.book_type_code)) THEN
                    RETURN FALSE;
                END IF;
                IF NOT (igi_iac_common_utils.iac_round(l_current_db_fa.deprn_period,l_det_balances.book_type_code)) THEN
                    RETURN FALSE;
                END IF;
                IF NOT (igi_iac_common_utils.iac_round(l_current_db_fa.deprn_ytd,l_det_balances.book_type_code)) THEN
                    RETURN FALSE;
                END IF;
                IF NOT (igi_iac_common_utils.iac_round(l_current_db_fa.deprn_reserve,l_det_balances.book_type_code)) THEN
                    RETURN FALSE;
                END IF;

                l_remaining_db.adjustment_cost         := nvl(l_remaining_db.adjustment_cost,0)
                                                   - nvl(l_current_db.adjustment_cost,0) ;
                l_remaining_db.reval_reserve_cost      := nvl(l_remaining_db.reval_reserve_cost,0)
                                                   - nvl(l_current_db.reval_reserve_cost,0) ;
                l_remaining_db.reval_reserve_backlog   := nvl(l_remaining_db.reval_reserve_backlog,0)
                                                   - nvl(l_current_db.reval_reserve_backlog,0) ;
                l_remaining_db.reval_reserve_gen_fund  := nvl(l_remaining_db.reval_reserve_gen_fund,0)
                                                   - nvl(l_current_db.reval_reserve_gen_fund,0) ;
                l_remaining_db.reval_reserve_net       := nvl(l_remaining_db.reval_reserve_cost,0)
                                                   -  nvl(l_remaining_db.reval_reserve_backlog,0)
                                                   -  nvl(l_remaining_db.reval_reserve_gen_fund,0) ;
                l_remaining_db.operating_acct_cost     := nvl(l_remaining_db.operating_acct_cost,0)
                                                   -   nvl(l_current_db.operating_acct_cost,0) ;
                l_remaining_db.operating_acct_backlog  := nvl(l_remaining_db.operating_acct_backlog,0)
                                                   -  nvl(l_current_db.operating_acct_backlog,0) ;
                l_remaining_db.operating_acct_net      := l_remaining_db.operating_acct_cost
                                                   - l_remaining_db.operating_acct_backlog ;
                l_remaining_db.operating_acct_ytd      := nvl(l_remaining_db.operating_acct_ytd ,0)
                                                   - l_current_db.operating_acct_ytd;
                l_remaining_db.deprn_period            := nvl(l_remaining_db.deprn_period,0)
                                                   - nvl(l_current_db.deprn_period,0) ;
                l_remaining_db.deprn_ytd               := nvl(l_remaining_db.deprn_ytd  ,0)
                                                   -  nvl(l_current_db.deprn_ytd,0) ;
                l_remaining_db.deprn_reserve           := nvl(l_remaining_db.deprn_reserve  ,0)
                                                   -  nvl(l_current_db.deprn_reserve,0) ;
                l_remaining_db.deprn_reserve_backlog   := nvl(l_remaining_db.deprn_reserve_backlog ,0)
                                                   - nvl(l_current_db.deprn_reserve_backlog,0) ;
                l_remaining_db.general_fund_per        := nvl(l_remaining_db.general_fund_per ,0)
                                                   - nvl(l_current_db.general_fund_per,0) ;
                l_remaining_db.general_fund_acc        := nvl(l_remaining_db.general_fund_acc  ,0)
                                                   - nvl(l_current_db.general_fund_acc,0) ;

                l_current_db_fa.deprn_period  := l_dist_prorate_factor * l_total_db_fa.deprn_period;
		do_round(l_current_db.deprn_period,l_det_balances.book_type_code);
                l_current_db_fa.deprn_ytd     := l_dist_ytd_factor * l_total_db_fa.deprn_ytd;
		do_round(l_current_db.deprn_ytd,l_det_balances.book_type_code);
                l_current_db_fa.deprn_reserve := l_dist_prorate_factor * l_total_db_fa.deprn_reserve;
		do_round(l_current_db.deprn_reserve,l_det_balances.book_type_code);

                l_remaining_db_fa.deprn_period  := l_remaining_db_fa.deprn_period - l_current_db_fa.deprn_period;
                l_remaining_db_fa.deprn_ytd     := l_remaining_db_fa.deprn_ytd - l_current_db_fa.deprn_ytd;
                l_remaining_db_fa.deprn_reserve := l_remaining_db_fa.deprn_reserve - l_current_db_fa.deprn_reserve;

            ELSE
                l_current_db.adjustment_id           :=  l_adjustment_id;
                l_current_db.asset_id                :=  l_det_balances.asset_id;
                l_current_db.distribution_id         :=  l_det_balances.distribution_id;
                l_current_db.book_type_code          :=  l_det_balances.book_type_code;
                l_current_db.period_counter          :=  l_asset_balance_mvmt.period_counter;
                l_current_db.adjustment_cost         :=  l_remaining_db.adjustment_cost;
                l_current_db.net_book_value          :=  l_remaining_db.net_book_value;
                l_current_db.reval_reserve_cost      :=  l_remaining_db.reval_reserve_cost;
                l_current_db.reval_reserve_backlog   :=  l_remaining_db.reval_reserve_backlog;
                l_current_db.reval_reserve_gen_fund  :=  l_remaining_db.reval_reserve_gen_fund;
                l_current_db.reval_reserve_net       :=  l_remaining_db.reval_reserve_net;
                l_current_db.operating_acct_cost     :=  l_remaining_db.operating_acct_cost;
                l_current_db.operating_acct_backlog  :=  l_remaining_db.operating_acct_backlog;
                l_current_db.operating_acct_net      :=  l_remaining_db.operating_acct_net;
                l_current_db.operating_acct_ytd      :=  l_det_balances.operating_acct_ytd + l_current_db.operating_acct_net;
                l_current_db.deprn_period            :=  l_remaining_db.deprn_period;
                l_current_db.deprn_ytd               :=  l_remaining_db.deprn_ytd;
                l_current_db.deprn_reserve           :=  l_remaining_db.deprn_reserve;
                l_current_db.deprn_reserve_backlog   :=  l_remaining_db.deprn_reserve_backlog;
                l_current_db.general_fund_per        :=  l_remaining_db.general_fund_per;
                l_current_db.general_fund_acc        :=  l_remaining_db.general_fund_acc;
                l_current_db.last_reval_date         :=  l_det_balances.last_reval_date;
                l_current_db.current_reval_factor    :=  l_det_balances.current_reval_factor;
                l_current_db.cumulative_reval_factor :=  l_det_balances.cumulative_reval_factor;
                l_current_db.active_flag             :=  l_det_balances.active_flag;

                l_current_db_fa.deprn_period  := l_remaining_db_fa.deprn_period;
                l_current_db_fa.deprn_ytd     := l_remaining_db_fa.deprn_ytd;
                l_current_db_fa.deprn_reserve := l_remaining_db_fa.deprn_reserve;

                IF NOT (igi_iac_common_utils.iac_round(l_current_db_fa.deprn_period,l_det_balances.book_type_code)) THEN
                    RETURN FALSE;
                END IF;

            END IF;

            -- get the account details for adjustments
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => ' +acctg creation get all accounts');
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => ' +distribution id '|| l_det_balances.distribution_id );

            IF NOT IGI_IAC_COMMON_UTILS.get_account_ccid
                                        ( X_book_type_code => l_det_balances.book_type_code
                                        , X_asset_id       => l_det_balances.asset_id
                                        , X_distribution_id => l_det_balances.distribution_id
                                        , X_account_type    => 'REVAL_RESERVE_ACCT'
                                        , account_ccid      => l_revl_rsv_ccid
                                        )
            THEN
                igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
                    p_full_path => l_path_name,
                    p_string => ' Error in fetching reval reserve');
                RETURN FALSE;
            END IF;

            IF NOT IGI_IAC_COMMON_UTILS.get_account_ccid
                                        ( X_book_type_code => l_det_balances.book_type_code
                                        , X_asset_id       => l_det_balances.asset_id
                                        , X_distribution_id => l_det_balances.distribution_id
                                        , X_account_type    => 'GENERAL_FUND_ACCT'
                                        , account_ccid      => l_gen_fund_ccid
                                        )
            THEN
                igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
                    p_full_path => l_path_name,
                    p_string => ' Error in fetching general fund');
                RETURN FALSE;
            END IF;

            IF NOT IGI_IAC_COMMON_UTILS.get_account_ccid
                                        ( X_book_type_code => l_det_balances.book_type_code
                                        , X_asset_id       => l_det_balances.asset_id
                                        , X_distribution_id => l_det_balances.distribution_id
                                        , X_account_type    => 'BACKLOG_DEPRN_RSV_ACCT'
                                        , account_ccid      => l_blog_rsv_ccid
                                        )
            THEN
                igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
                    p_full_path => l_path_name,
                    p_string => ' Error in fetching backlog deprn rsv acct');
                RETURN FALSE;
            END IF;

            IF NOT IGI_IAC_COMMON_UTILS.get_account_ccid
                                        ( X_book_type_code => l_det_balances.book_type_code
                                        , X_asset_id       => l_det_balances.asset_id
                                        , X_distribution_id => l_det_balances.distribution_id
                                        , X_account_type    => 'OPERATING_EXPENSE_ACCT'
                                        , account_ccid      => l_op_exp_ccid
                                        )
            THEN
                igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
                    p_full_path => l_path_name,
                    p_string => ' Error in fetching operating expense acct');
                RETURN FALSE;
            END IF;

            IF NOT IGI_IAC_COMMON_UTILS.get_account_ccid
                                        ( X_book_type_code => l_det_balances.book_type_code
                                        , X_asset_id       => l_det_balances.asset_id
                                        , X_distribution_id => l_det_balances.distribution_id
                                        , X_account_type    => 'DEPRN_RESERVE_ACCT'
                                        , account_ccid      => l_deprn_rsv_ccid
                                           )
            THEN
                igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
                    p_full_path => l_path_name,
                    p_string => ' Error in fetching deprn reserve');
                RETURN FALSE;
            END IF;

            IF NOT IGI_IAC_COMMON_UTILS.get_account_ccid
                                        ( X_book_type_code => l_det_balances.book_type_code
                                        , X_asset_id       => l_det_balances.asset_id
                                        , X_distribution_id => l_det_balances.distribution_id
                                        , X_account_type    => 'DEPRN_EXPENSE_ACCT'
                                        , account_ccid      => l_deprn_exp_ccid
                                        )
            THEN
                igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
                    p_full_path => l_path_name,
                    p_string => ' Error in fecthing deprn expense acct');
                RETURN FALSE;
            END IF;

            /* Create accounting entries for non zero values*/
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '   Creating accounting entries in igi_iac_adjustments');
            IF l_current_db.deprn_reserve <> 0 THEN
                l_rowid := NULL ;
               	igi_iac_adjustments_pkg.insert_row(
            			         		X_rowid			        => l_rowid ,
             				           	X_adjustment_id		    => l_adjustment_id ,
                    					X_book_type_code	    => l_det_balances.book_type_code ,
            		        			X_code_combination_id	=> l_deprn_exp_ccid,
            				           	X_set_of_books_id	    => l_sob_id ,
             					        X_dr_cr_flag   		    => 'DR' ,
                    					X_amount               	=> l_current_db.deprn_reserve,
            		           			X_adjustment_type      	=> 'EXPENSE' ,
            					        X_transfer_to_gl_flag  	=> 'Y' ,
                    					X_units_assigned        => l_det_balances.units_assigned ,
             		        			X_asset_id		        => l_det_balances.asset_id ,
            				        	X_distribution_id      	=> l_det_balances.distribution_id ,
                    					X_period_counter       	=> l_asset_balance_mvmt.period_counter,
							X_adjustment_offset_type => 'RESERVE',
							X_report_ccid 		=> Null,
                                         x_mode                  => 'R',
                                         X_event_id          => p_event_id
										) ;

                l_rowid := NULL ;
                igi_iac_adjustments_pkg.insert_row(
        		                        X_rowid			        => l_rowid ,
                     					X_adjustment_id		    => l_adjustment_id ,
                    					X_book_type_code	    => l_det_balances.book_type_code ,
                    					X_code_combination_id	=> l_deprn_rsv_ccid,
                    					X_set_of_books_id	    => l_sob_id ,
                     					X_dr_cr_flag   		    => 'CR' ,
                    					X_amount               	=>l_current_db.deprn_reserve,
                    					X_adjustment_type      	=> 'RESERVE' ,
                    					X_transfer_to_gl_flag  	=> 'Y' ,
                    					X_units_assigned        => l_det_balances.units_assigned ,
                     					X_asset_id		        => l_det_balances.asset_id ,
                    					X_distribution_id      	=> l_det_balances.distribution_id ,
					                X_period_counter       	=> l_asset_balance_mvmt.period_counter,
							X_adjustment_offset_type => 'EXPENSE',
							X_report_ccid 		=> Null,
                                        		x_mode                  => 'R',
                                        		X_event_id          => p_event_id
										 ) ;
            END IF;

            IF l_current_db.reval_reserve_gen_fund <> 0 THEN
                    l_rowid := NULL ;
                    igi_iac_adjustments_pkg.insert_row(
		    	     	        	X_rowid			            => l_rowid ,
                 					X_adjustment_id		        => l_adjustment_id ,
			                		X_book_type_code	        => l_det_balances.book_type_code ,
            		    			        X_code_combination_id	    => l_revl_rsv_ccid,
			                		X_set_of_books_id	        => l_sob_id ,
             				    	        X_dr_cr_flag   		        => 'DR' ,
			            		        X_amount               	    => l_current_db.reval_reserve_gen_fund ,
                					X_adjustment_type      	    => 'REVAL RESERVE' ,
	    		            		        X_transfer_to_gl_flag  	    => 'Y' ,
                					X_units_assigned            => l_det_balances.units_assigned ,
 			                                X_asset_id		            => l_det_balances.asset_id ,
            	    				        X_distribution_id      	    => l_det_balances.distribution_id ,
			                		X_period_counter       	    => l_asset_balance_mvmt.period_counter,
							X_adjustment_offset_type    => 'GENERAL FUND',
							X_report_ccid 		    => Null,
                                                        x_mode                      => 'R',
                                                        X_event_id          => p_event_id
									 ) ;

                    l_rowid := NULL ;
                    igi_iac_adjustments_pkg.insert_row(
		                    	    X_rowid			            => l_rowid ,
                         			X_adjustment_id		        => l_adjustment_id ,
                        			X_book_type_code	        => l_det_balances.book_type_code ,
                        			X_code_combination_id	    => l_gen_fund_ccid,
                        			X_set_of_books_id	        => l_sob_id ,
                         			X_dr_cr_flag   		        => 'CR' ,
                        			X_amount               	    =>l_current_db.reval_reserve_gen_fund ,
                        			X_adjustment_type      	    => 'GENERAL FUND' ,
                        			X_transfer_to_gl_flag  	    => 'Y' ,
                        			X_units_assigned            => l_det_balances.units_assigned ,
                         			X_asset_id		    => l_det_balances.asset_id ,
                        			X_distribution_id      	    => l_det_balances.distribution_id ,
                        			X_period_counter       	    => l_asset_balance_mvmt.period_counter,
						X_adjustment_offset_type    => 'REVAL RESERVE',
						X_report_ccid 		    => l_revl_rsv_ccid,
                                    		x_mode                      => 'R',
                                    		X_event_id          => p_event_id
									) ;
            END IF;

            IF l_current_db.reval_reserve_backlog <> 0 THEN
                l_rowid := NULL;
                igi_iac_adjustments_pkg.insert_row(
		                    	    X_rowid			            => l_rowid ,
                         			X_adjustment_id		        => l_adjustment_id ,
                        			X_book_type_code	        => l_det_balances.book_type_code ,
                        			X_code_combination_id	    => l_blog_rsv_ccid,
                        			X_set_of_books_id	        => l_sob_id ,
                         			X_dr_cr_flag   		        => 'CR' ,
                        			X_amount               	    =>l_current_db.reval_reserve_backlog ,
                        			X_adjustment_type      	    => 'BL RESERVE' ,
                        			X_transfer_to_gl_flag  	    => 'Y' ,
                        			X_units_assigned            => l_det_balances.units_assigned ,
                         			X_asset_id		            => l_det_balances.asset_id ,
                        			X_distribution_id      	    => l_det_balances.distribution_id ,
                        			X_period_counter       	    => l_asset_balance_mvmt.period_counter,
						X_adjustment_offset_type => 'REVAL RESERVE',
						X_report_ccid 			=> l_revl_rsv_ccid,
                                    		x_mode                      => 'R',
                                    		X_event_id          => p_event_id
									 ) ;


                l_rowid := NULL;
                igi_iac_adjustments_pkg.insert_row(
			         	        	X_rowid			            => l_rowid ,
             	    				X_adjustment_id		        => l_adjustment_id ,
			                		X_book_type_code	        => l_det_balances.book_type_code ,
            			    		X_code_combination_id	    => l_revl_rsv_ccid,
			            	    	X_set_of_books_id	        => l_sob_id ,
                 					X_dr_cr_flag   		        => 'DR' ,
			            		    X_amount               	    =>l_current_db.reval_reserve_backlog ,
                					X_adjustment_type      	    => 'REVAL RESERVE' ,
		                    		X_transfer_to_gl_flag  	    => 'Y' ,
            	    				X_units_assigned            => l_det_balances.units_assigned ,
 			                        X_asset_id		            => l_det_balances.asset_id ,
            			    		X_distribution_id      	    => l_det_balances.distribution_id ,
			            	    	X_period_counter       	    => l_asset_balance_mvmt.period_counter,
						X_adjustment_offset_type 	=> 'BL RESERVE',
						X_report_ccid 			=> Null,
                                    		x_mode                      => 'R',
                                    		X_event_id          => p_event_id
									 ) ;

            END IF;

            IF l_current_db.operating_acct_backlog <> 0 THEN
                l_rowid := NULL;
                igi_iac_adjustments_pkg.insert_row(
		                    	    X_rowid			            => l_rowid ,
                         			X_adjustment_id		        => l_adjustment_id ,
                        			X_book_type_code	        => l_det_balances.book_type_code ,
                        			X_code_combination_id	    => l_blog_rsv_ccid,
                        			X_set_of_books_id	        => l_sob_id ,
                         			X_dr_cr_flag   		        => 'CR' ,
                        			X_amount               	    =>l_current_db.operating_acct_backlog ,
                        			X_adjustment_type      	    => 'BL RESERVE' ,
                        			X_transfer_to_gl_flag  	    => 'Y' ,
                        			X_units_assigned            => l_det_balances.units_assigned ,
                         			X_asset_id		            => l_det_balances.asset_id ,
                        			X_distribution_id      	    => l_det_balances.distribution_id ,
                        			X_period_counter       	    => l_asset_balance_mvmt.period_counter,
						X_adjustment_offset_type 	=> 'OP EXPENSE',
						X_report_ccid 				=> l_op_exp_ccid,
                                    		x_mode                      => 'R',
                                    		X_event_id          => p_event_id
									 ) ;

                l_rowid := NULL;
                igi_iac_adjustments_pkg.insert_row(
			         	        X_rowid			            => l_rowid ,
                   				X_adjustment_id		        => l_adjustment_id ,
			                	X_book_type_code	        => l_det_balances.book_type_code ,
            			    		X_code_combination_id	    => l_op_exp_ccid,
			            	    	X_set_of_books_id	        => l_sob_id ,
             					X_dr_cr_flag   		        => 'DR' ,
    			            		X_amount               	    =>l_current_db.operating_acct_backlog ,
                				X_adjustment_type      	    => 'OP EXPENSE' ,
		    	            		X_transfer_to_gl_flag  	    => 'Y' ,
                				X_units_assigned            => l_det_balances.units_assigned ,
 			                        X_asset_id		            => l_det_balances.asset_id ,
            		    			X_distribution_id      	    => l_det_balances.distribution_id ,
			                	X_period_counter       	    => l_asset_balance_mvmt.period_counter,
						X_adjustment_offset_type 	=> 'BL RESERVE',
						X_report_ccid 				=> Null,
                                    		x_mode                      => 'R',
                                    		X_event_id          => p_event_id
                                    		) ;

            END IF;

            l_det_balances.adjustment_cost  := l_det_balances.adjustment_cost + l_current_db.adjustment_cost;
            l_det_balances.net_book_value   := l_det_balances.net_book_value + l_current_db.net_book_value;
            l_det_balances.reval_reserve_cost := l_det_balances.reval_reserve_cost + l_current_db.reval_reserve_cost;
            l_det_balances.reval_reserve_backlog := l_det_balances.reval_reserve_backlog + l_current_db.reval_reserve_backlog;
            l_det_balances.reval_reserve_gen_fund := l_det_balances.reval_reserve_gen_fund + l_current_db.reval_reserve_gen_fund;
            l_det_balances.reval_reserve_net := l_det_balances.reval_reserve_net + l_current_db.reval_reserve_net;
            l_det_balances.operating_acct_cost := l_det_balances.operating_acct_cost + l_current_db.operating_acct_cost;
            l_det_balances.operating_acct_backlog := l_det_balances.operating_acct_backlog + l_current_db.operating_acct_backlog;
            l_det_balances.operating_acct_net := l_det_balances.operating_acct_net + l_current_db.operating_acct_net;
            l_det_balances.deprn_reserve := l_det_balances.deprn_reserve + l_current_db.deprn_reserve;
            l_det_balances.deprn_reserve_backlog := l_det_balances.deprn_reserve_backlog + l_current_db.deprn_reserve_backlog;
            l_det_balances.general_fund_acc := l_det_balances.general_fund_acc + l_current_db.general_fund_acc;

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => ' +DET BALANCES..... AFTER');
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_adjustment_id            => '|| l_current_db.adjustment_id);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_asset_id                 =>'|| l_current_db.asset_id);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_distribution_id          => '||l_current_db.distribution_id);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_book_type_code           => '||l_current_db.book_type_code);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_period_counter           => '||l_current_db.period_counter);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_adjustment_cost          => '||l_det_balances.adjustment_cost);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_net_book_value           => '||l_det_balances.net_book_value);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_reval_reserve_cost       => '||l_det_balances.reval_reserve_cost);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_reval_reserve_backlog    => '||l_det_balances.reval_reserve_backlog);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_reval_reserve_gen_fund   => '||l_det_balances.reval_reserve_gen_fund);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_reval_reserve_net        => '||l_det_balances.reval_reserve_net);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_operating_acct_cost      => '||l_det_balances.operating_acct_cost);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_operating_acct_backlog   => '||l_det_balances.operating_acct_backlog);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_operating_acct_net       => '||l_det_balances.operating_acct_net);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_operating_acct_ytd       => '||l_current_db.operating_acct_ytd);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_deprn_period             => '||l_current_db.deprn_period);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_deprn_ytd                => '||l_current_db.deprn_ytd);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_deprn_reserve            => '||l_det_balances.deprn_reserve);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_deprn_reserve_backlog    => '||l_det_balances.deprn_reserve_backlog);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_general_fund_per         => '||l_current_db.general_fund_per);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_general_fund_acc         => '||l_det_balances.general_fund_acc);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_last_reval_date          => '||l_det_balances.last_reval_date);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_current_reval_factor     => '||l_det_balances.current_reval_factor);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_cumulative_reval_factor  => '||l_det_balances.cumulative_reval_factor);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => '     x_active_flag              => '||l_det_balances.active_flag);

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => 'IGI_IAC_DET_BALANCES_PKG.insert_row');
            l_rowid := NULL;
            IGI_IAC_DET_BALANCES_PKG.insert_row (
                    x_rowid                    => l_rowid,
                    x_adjustment_id            => l_current_db.adjustment_id,
                    x_asset_id                 => l_current_db.asset_id,
                    x_distribution_id          => l_current_db.distribution_id,
                    x_book_type_code           => l_current_db.book_type_code,
                    x_period_counter           => l_current_db.period_counter,
                    x_adjustment_cost          => l_det_balances.adjustment_cost ,
                    x_net_book_value           => l_det_balances.net_book_value ,
                    x_reval_reserve_cost       => l_det_balances.reval_reserve_cost ,
                    x_reval_reserve_backlog    => l_det_balances.reval_reserve_backlog ,
                    x_reval_reserve_gen_fund   => l_det_balances.reval_reserve_gen_fund ,
                    x_reval_reserve_net        => l_det_balances.reval_reserve_net ,
                    x_operating_acct_cost      => l_det_balances.operating_acct_cost ,
                    x_operating_acct_backlog   => l_det_balances.operating_acct_backlog ,
                    x_operating_acct_net       => l_det_balances.operating_acct_net ,
                    x_operating_acct_ytd       => l_current_db.operating_acct_ytd,
                    x_deprn_period             => l_current_db.deprn_period,
                    x_deprn_ytd                => l_current_db.deprn_ytd,
                    x_deprn_reserve            => l_det_balances.deprn_reserve ,
                    x_deprn_reserve_backlog    => l_det_balances.deprn_reserve_backlog ,
                    x_general_fund_per         => l_current_db.general_fund_per,
                    x_general_fund_acc         => l_det_balances.general_fund_acc ,
                    x_last_reval_date          => l_current_db.last_reval_date,
                    x_current_reval_factor     => l_current_db.current_reval_factor,
                    x_cumulative_reval_factor  => l_current_db.cumulative_reval_factor,
                    x_active_flag              => l_current_db.active_flag,
                    x_mode                     => 'R' );

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => 'Before igi_iac_fa_deprn_pkg.insert_row');
            l_rowid := NULL;
            igi_iac_fa_deprn_pkg.insert_row(
    					x_rowid			    => l_rowid,
						x_book_type_code	=> l_det_balances.book_type_code,
						x_asset_id		    => l_det_balances.asset_id,
						x_distribution_id	=> l_det_balances.distribution_id,
						x_period_counter	=> l_asset_balance_mvmt.period_counter,
						x_adjustment_id		=> l_adjustment_id,
						x_deprn_period		=> l_current_db_fa.deprn_period,
						x_deprn_ytd		    => l_current_db_fa.deprn_ytd ,
						x_deprn_reserve		=> l_current_db_fa.deprn_reserve,
						x_active_flag		=> l_det_balances.active_flag,
						x_mode			    => 'R');
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => 'After igi_iac_fa_deprn_pkg.insert_row');
        END LOOP;

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => '         Asset_id:'||l_curr_asset_balance.asset_id);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => '         Period_counter :'||l_curr_asset_balance.period_counter);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => '         Net book value :'||TO_CHAR(l_curr_asset_balance.net_book_value));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => '         Adjusted Cost :'||TO_CHAR(l_curr_asset_balance.adjusted_cost));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => '         Operating Account :'||TO_CHAR(l_curr_asset_balance.operating_acct));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => '         Reval Reserve :'||TO_CHAR(l_curr_asset_balance.reval_reserve));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => '         Deprn Amount :'||TO_CHAR(l_curr_asset_balance.deprn_amount));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => '         Deprn Reserve :'||TO_CHAR(l_curr_asset_balance.deprn_reserve));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => '         Backlog Deprn Reserve :'||TO_CHAR(l_curr_asset_balance.backlog_deprn_reserve));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => '         General Fund :'||TO_CHAR(l_curr_asset_balance.general_fund));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => '         Current Reval Factor :'||TO_CHAR(l_curr_asset_balance.current_reval_factor));
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => '         Cumulative Reval Factor :'||TO_CHAR(l_curr_asset_balance.Cumulative_reval_factor));

        IGI_IAC_ASSET_BALANCES_PKG.update_row (
            x_asset_id                  => l_curr_asset_balance.asset_id,
            x_book_type_code            => l_curr_asset_balance.book_type_code,
            x_period_counter            => l_asset_balance_mvmt.period_counter,
            x_net_book_value            => l_curr_asset_balance.net_book_value,
            x_adjusted_cost             => l_curr_asset_balance.adjusted_cost,
            x_operating_acct            => l_curr_asset_balance.operating_acct,
            x_reval_reserve             => l_curr_asset_balance.reval_reserve,
            x_deprn_amount              => l_curr_asset_balance.deprn_amount,
            x_deprn_reserve             => l_curr_asset_balance.deprn_reserve,
            x_backlog_deprn_reserve     => l_curr_asset_balance.backlog_deprn_reserve,
            x_general_fund              => l_curr_asset_balance.general_fund,
            x_last_reval_date           => l_curr_asset_balance.last_reval_date,
            x_current_reval_factor      => l_curr_asset_balance.current_reval_factor,
            x_cumulative_reval_factor   => l_curr_asset_balance.cumulative_reval_factor,
            x_mode                      => 'R'
            );

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => '     Making previous transaction inactive.');
		igi_iac_trans_headers_pkg.update_row(
		    			X_prev_adjustment_id	=> l_adjustment_id_out ,
					X_adjustment_id		=> l_adjustment_id ) ;

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => '   Expensed Adjustment Success.');

       Return TRUE;

    EXCEPTION
        WHEN others  THEN
            igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
            RETURN FALSE;
    END Do_Expensed_Adj;
BEGIN
    --===========================FND_LOG.START=====================================
    g_state_level 	     :=	FND_LOG.LEVEL_STATEMENT;
    g_proc_level  	     :=	FND_LOG.LEVEL_PROCEDURE;
    g_event_level 	     :=	FND_LOG.LEVEL_EVENT;
    g_excep_level 	     :=	FND_LOG.LEVEL_EXCEPTION;
    g_error_level 	     :=	FND_LOG.LEVEL_ERROR;
    g_unexp_level 	     :=	FND_LOG.LEVEL_UNEXPECTED;
    g_path               := 'IGI.PLSQL.igiiadxb.igi_iac_adj_expensed_pkg.';
    --===========================FND_LOG.END=====================================

END igi_iac_adj_expensed_pkg;

/
