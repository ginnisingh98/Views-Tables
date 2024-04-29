--------------------------------------------------------
--  DDL for Package Body IGI_IAC_ADJ_AMORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_ADJ_AMORT_PKG" AS
-- $Header: igiiadab.pls 120.18.12010000.2 2010/06/24 11:02:14 schakkin ship $

    -- ===================================================================
    -- Global Variables
    -- ===================================================================

    l_calling_function varchar2(255);

    l_rowid       ROWID;
    g_calling_fn  VARCHAR2(200);
    g_asset_num   fa_additions.asset_number%TYPE;

    -- ===================================================================
    -- Local functions and procedures
    -- ===================================================================

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

    -- -------------------------------------------------------------------
    -- PROCEDURE Debug_Adj_Asset : Procedure that will print the historic
    -- asset information
    -- -------------------------------------------------------------------

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
            p_string => 'adjusted_Expensed..........'|| p_asset.adjusted_cost );
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

    -- ===================================================================
    -- Main public functions and procedures
    -- ===================================================================

    -- -------------------------------------------------------------------
    -- PROCEDURE Do_Amort_Deprn_Reval: This is the main function that will
    -- do the Amortization Depreciation revaluation for the asset
    -- -------------------------------------------------------------------
    FUNCTION Do_Amort_Deprn_Reval(p_asset_iac_adj_info igi_iac_types.iac_adj_hist_asset_info,
                                  p_asset_iac_dist_info igi_iac_types.iac_adj_dist_info_tab,
                                  p_adj_hist            igi_iac_adjustments_history%ROWTYPE,
                                  p_event_id            number)  --R12 uptake
    RETURN BOOLEAN
    IS
        -- cursors
        /*-- cursor to check if asset is non depreciating
        CURSOR c_asset_non_depr(cp_asset_id       fa_books.asset_id%TYPE,
                              cp_book_type_code fa_books.book_type_code%TYPE)
        IS
        SELECT depreciate_flag
        FROM fa_books
        WHERE book_type_code = cp_book_type_code
        AND   asset_id = cp_asset_id
        AND   date_ineffective IS NULL;
        */

        -- cursor to get iac asset balance information
        CURSOR c_iac_asset_bal(cp_asset_id       igi_iac_asset_balances.asset_id%TYPE,
                             cp_book_type_code igi_iac_asset_balances.book_type_code%TYPE,
                             cp_period_counter igi_iac_asset_balances.period_counter%TYPE)
        IS
        SELECT period_counter,
             net_book_value,
             adjusted_cost,
             operating_acct,
             reval_reserve,
             deprn_amount,
             deprn_reserve,
             backlog_deprn_reserve,
             general_fund,
             last_reval_date,
             current_reval_factor,
             cumulative_reval_factor
        FROM igi_iac_asset_balances
        WHERE asset_id = cp_asset_id
        AND book_type_code = cp_book_type_code
        AND period_counter = cp_period_counter;

        -- cursor to get the detail balances for a distribution
        CURSOR c_det_bal(cp_adjust_id      igi_iac_det_balances.adjustment_id%TYPE,
                       cp_asset_id       fa_books.asset_id%TYPE,
                       cp_book_type_code fa_books.book_type_code%TYPE,
                       cp_dist_id        igi_iac_det_balances.distribution_id%TYPE)
        IS
        SELECT iidb.adjustment_id,
             iidb.distribution_id,
             iidb.period_counter,
             iidb.adjustment_cost,
             iidb.net_book_value,
             iidb.reval_reserve_cost,
             iidb.reval_reserve_backlog,
             iidb.reval_reserve_gen_fund,
             iidb.reval_reserve_net,
             iidb.operating_acct_cost,
             iidb.operating_acct_backlog,
             iidb.operating_acct_ytd,
             iidb.operating_acct_net,
             iidb.deprn_period,
             iidb.deprn_ytd,
             iidb.deprn_reserve,
             iidb.deprn_reserve_backlog,
             iidb.general_fund_per,
             iidb.general_fund_acc,
             iidb.last_reval_date,
             iidb.current_reval_factor,
             iidb.cumulative_reval_factor,
             iidb.active_flag
        FROM   igi_iac_det_balances iidb
        WHERE  iidb.adjustment_id = cp_adjust_id
        AND    iidb.book_type_code = cp_book_type_code
        AND    iidb.asset_id = cp_asset_id
        AND    iidb.distribution_id = cp_dist_id
        AND    iidb.active_flag IS NULL
        ORDER BY iidb.distribution_id;

        -- cursor to get the latest fa figures from
        -- igi_iac_fa_deprn
        CURSOR c_get_fa_iac_deprn(cp_distribution_id igi_iac_fa_deprn.distribution_id%TYPE,
                                cp_adjustment_id    igi_iac_fa_deprn.adjustment_id%TYPE)
        IS
        SELECT iifd.deprn_ytd,
             iifd.deprn_period,
             iifd.deprn_reserve
        FROM   igi_iac_fa_deprn iifd
        WHERE  iifd.adjustment_id = cp_adjustment_id
        AND    iifd.distribution_id = cp_distribution_id
        AND    iifd.active_flag IS NULL;

        -- cursor to get the fa_depreciation adjustment amount
        CURSOR c_fa_deprn_adjust_amt(cp_asset_id       fa_deprn_detail.book_type_code%TYPE,
                                   cp_book_type_code fa_deprn_detail.book_type_code%TYPE,
                                   cp_period_counter fa_deprn_detail.period_counter%TYPE)
        IS
        SELECT SUM(NVL(deprn_amount,0)) deprn_amount,
                SUM(NVL(deprn_adjustment_amount,0)) deprn_adjustment_amount,
                SUM(NVL(deprn_reserve,0)) deprn_reserve
        FROM   fa_deprn_detail
        WHERE  book_type_code = cp_book_type_code
        AND    asset_id = cp_asset_id
        AND    period_counter = cp_period_counter;

        CURSOR c_get_period_first_adj(cp_asset_id igi_iac_adjustments_history.asset_id%TYPE,
                                    cp_book_type_code igi_iac_adjustments_history.book_type_code%TYPE,
                                    cp_period_counter igi_iac_adjustments_history.period_counter%TYPE)
        IS
        SELECT ah.pre_adjusted_cost, ah.pre_salvage_value
        FROM igi_iac_adjustments_history ah
        WHERE ah.book_type_code = cp_book_type_code
        AND ah.asset_id = cp_asset_id
        AND ah.transaction_header_id_in = (SELECT min(iah.transaction_header_id_in)
                                            FROM igi_iac_adjustments_history iah
                                            WHERE iah.book_type_code = cp_book_type_code
                                            AND iah.asset_id = cp_asset_id
                                            AND iah.period_counter = cp_period_counter);


        -- local variables
        l_asset_id            fa_books.asset_id%TYPE;
        l_book_type_code      fa_books.book_type_code%TYPE;
        l_last_period_counter igi_iac_transaction_headers.period_counter%TYPE;
        l_sob_id              NUMBER;
        l_coa_id              NUMBER;
        l_currency            VARCHAR2(15);
        l_precision           NUMBER;

        l_latest_trx_type     igi_iac_transaction_headers.transaction_type_code%TYPE;
        l_latest_trx_id       igi_iac_transaction_headers.transaction_header_id%TYPE;
        l_latest_mref_id      igi_iac_transaction_headers.mass_reference_id%TYPE;
        l_latest_adj_id       igi_iac_transaction_headers.adjustment_id%TYPE;
        l_prev_adj_id         igi_iac_transaction_headers.adjustment_id%TYPE;
        l_latest_adj_status   igi_iac_transaction_headers.adjustment_status%TYPE;
        l_adj_id_out          igi_iac_transaction_headers.adjustment_id_out%TYPE;

        l_fully_rsvd_pc       fa_books.period_counter_fully_reserved%TYPE;
        --  l_deprn_flag          fa_books.depreciate_flag%TYPE;

        l_new_adj_id          igi_iac_transaction_headers.adjustment_id%TYPE;
        l_rsvd_pc             igi_iac_transaction_headers.period_counter%TYPE;
        l_iac_asset_bal       c_iac_asset_bal%ROWTYPE;

        l_fa_deprn_adj_amount    fa_deprn_detail.deprn_adjustment_amount%TYPE;
        l_iac_new_deprn_adj_amt  igi_iac_asset_balances.deprn_amount%TYPE;
        l_iac_new_deprn_period   igi_iac_asset_balances.deprn_amount%TYPE;
        l_iac_new_deprn_reserve  igi_iac_asset_balances.deprn_reserve%TYPE;

        l_iac_new_nbv         igi_iac_asset_balances.net_book_value%TYPE;
        l_iac_new_rr          igi_iac_asset_balances.reval_reserve%TYPE;
        l_iac_new_gf          igi_iac_asset_balances.general_fund%TYPE;

        l_fa_idx              NUMBER;
        l_det_bal             c_det_bal%ROWTYPE;
        l_det_table           IGI_IAC_TYPES.dist_amt_tab;
        l_dist_idx            NUMBER;
        l_dist_id             igi_iac_det_balances.distribution_id%TYPE;
        l_dep_adj_amount      igi_iac_det_balances.deprn_period%TYPE;
        l_units_assigned      igi_iac_adjustments.units_assigned%TYPE;

        l_new_dist_dep_prd    igi_iac_det_balances.deprn_period%TYPE;
        l_new_dist_dep_rsv    igi_iac_det_balances.deprn_reserve%TYPE;
        l_new_dist_dep_ytd    igi_iac_det_balances.deprn_ytd%TYPE;

        l_new_dist_nbv        igi_iac_det_balances.net_book_value%TYPE;
        l_new_dist_rr_gf      igi_iac_det_balances.reval_reserve_gen_fund%TYPE;
        l_new_dist_rr_net     igi_iac_det_balances.reval_reserve_net%TYPE;
        l_new_dist_gf_per     igi_iac_det_balances.general_fund_per%TYPE;
        l_new_dist_gf_acc     igi_iac_det_balances.general_fund_acc%TYPE;

        l_round_diff          NUMBER ;
        l_fa_deprn_period     igi_iac_fa_deprn.deprn_period%TYPE;
        l_fa_deprn_reserve    igi_iac_fa_deprn.deprn_reserve%TYPE;
        l_fa_deprn_ytd        igi_iac_fa_deprn.deprn_ytd%TYPE;

        l_ccid                igi_iac_adjustments.code_combination_id%TYPE;
	l_reval_rsv_ccid	igi_iac_adjustments.code_combination_id%TYPE;
        l_exists              NUMBER;
        l_ret                 BOOLEAN;

        l_deprn_amount          fa_deprn_detail.deprn_amount%TYPE;
        l_deprn_reserve         fa_deprn_detail.deprn_reserve%TYPE;
        l_prev_cost             fa_books.cost%TYPE;
        l_prev_salvage          fa_books.salvage_value%TYPE;
        l_curr_cost             fa_books.cost%TYPE;
        l_curr_Salvage          fa_books.salvage_value%TYPE;
        l_prev_sv_correction    NUMBER;
        l_curr_sv_correction    NUMBER;
        l_diff_sv_correction    NUMBER;
        l_iac_deprn_period_amount   NUMBER;
        l_fa_deprn_period_amount    NUMBER;

        -- exceptions
        e_latest_trx_not_avail    EXCEPTION;
        e_no_period_info_avail    EXCEPTION;
        e_no_ccid_found           EXCEPTION;
        e_no_proration            EXCEPTION;
        e_asset_life_err          EXCEPTION;
        e_no_gl_info              EXCEPTION;
        e_non_dep_asset           EXCEPTION;
        e_curr_period_amort       EXCEPTION;

        l_path_name VARCHAR2(150);

    BEGIN -- do amort deprn reval
        l_path_name := g_path||'do_amort_deprn_reval';
        l_round_diff := 0;
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'In Amortized  Depreciation Revaluation');
        debug_adj_asset( p_asset_iac_adj_info);

        -- set local variables
        l_book_type_code := p_asset_iac_adj_info.book_type_code;
        l_asset_id := p_asset_iac_adj_info.asset_id;
        l_last_period_counter := p_asset_iac_adj_info.last_period_counter;

        -- get the asset number for debugging purpose
        SELECT asset_number
        INTO g_asset_num
        FROM fa_additions
        WHERE asset_id = l_asset_id;

        -- get the GL set of books id
        IF NOT igi_iac_common_utils.get_book_GL_info(l_book_type_code,
                                                   l_sob_id,
                                                   l_coa_id,
                                                   l_currency,
                                                   l_precision)
        THEN
            RAISE e_no_gl_info;
        END IF;

        -- Get the latest transaction or adjustment from igi_iac_common_utils.get_latest_transaction
        -- for the asset and book
        IF NOT igi_iac_common_utils.get_latest_transaction(l_book_type_code,
                                                         l_asset_id,
                                                         l_latest_trx_type,
                                                         l_latest_trx_id,
                                                         l_latest_mref_id,
                                                         l_latest_adj_id,
                                                         l_prev_adj_id,
                                                         l_latest_adj_status)
        THEN
            RAISE e_latest_trx_not_avail;
        END IF;

        -- set the adjustment_id_out
        l_adj_id_out := l_latest_adj_id;

        -- check if latest adjustment is a REVALUATION in PREVIEW status
        IF (l_latest_trx_type = 'REVALUATION' AND l_latest_adj_status IN ('PREVIEW', 'OBSOLETE')) THEN
            l_latest_adj_id := l_prev_adj_id;
        END IF;

        -- check if the asset is fully reserved
        IF NOT  igi_iac_adj_cost_reval_pkg.chk_asset_life(p_book_code => l_book_type_code,
                                                        p_period_counter => l_last_period_counter,
                                                        p_asset_id => l_asset_id,
                                                        l_last_period_counter => l_fully_rsvd_pc)
        THEN
            RAISE e_asset_life_err;
        END IF;
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'Fully reserved period counter: '||l_fully_rsvd_pc);

        -- check if asset is non depreciating asset
        /*     OPEN c_asset_non_depr(l_asset_id,
                            l_book_type_code);
        FETCH c_asset_non_depr INTO l_deprn_flag;
        IF (c_asset_non_depr%NOTFOUND) THEN
            RAISE NO_DATA_FOUND;
        END IF;
        CLOSE c_asset_non_depr;

        Debug('Asset depreciation flag:  '||l_deprn_flag);
        */
        -- if asset is non depreciating do not process any further
        IF (p_asset_iac_adj_info.depreciate_flag = 'NO') THEN
            RAISE e_non_dep_asset;
        END IF;

        OPEN c_get_period_first_adj(l_asset_id,
                                    l_book_type_code,
                                    l_last_period_counter);
        FETCH c_get_period_first_adj INTO l_prev_cost, l_prev_salvage;
        CLOSE c_get_period_first_adj;

        l_curr_cost := p_adj_hist.adjusted_cost;
        l_curr_salvage := p_adj_hist.salvage_value;

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'Before adjustment Cost: '||l_prev_cost);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'Before adjustment Salvage Value: '||l_prev_salvage);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'After adjustment Cost: '||l_curr_cost);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'After adjustment Salvage Value: '||l_curr_salvage);

        -- check if asset is amortized in current period, if yes then
        -- do not process any further
        IF (p_adj_hist.current_period_amortization = 'Y' AND
            (l_prev_cost = l_curr_cost OR
            (l_prev_cost <> l_curr_cost AND l_prev_salvage = 0 AND l_curr_salvage = 0)) AND
            l_prev_salvage = l_curr_salvage) THEN
            RAISE e_curr_period_amort;
        END IF;

        IF (l_last_period_counter >= l_fully_rsvd_pc) THEN
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => 'Asset is fully reserved or non depreciable');
            -- get the period counter associated with the latest adjustment
            -- for the asset
            SELECT period_counter
            INTO l_rsvd_pc
            FROM igi_iac_transaction_headers
            WHERE adjustment_id = l_latest_adj_id;

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => 'Last period counter for fully reserved or non deprn asset:  '||l_rsvd_pc);
        ELSE
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => 'asset is depreciable with life');
            l_rsvd_pc := l_last_period_counter;
        END IF;

        -- Fetch the latest IGI_IAC_ASSET_BALANCES for the asset regardless of type
        -- bug 3391000, start 1
        /* OPEN c_iac_asset_bal(l_asset_id,
                           l_book_type_code,
                           l_rsvd_pc);
        FETCH c_iac_asset_bal INTO l_iac_asset_bal;
        IF c_iac_asset_bal%NOTFOUND THEN
            RAISE NO_DATA_FOUND ;
        END IF ;
        CLOSE c_iac_asset_bal; */

        -- Fetch the latest IGI_IAC_ASSET_BALANCES for the asset regardless of type
        -- if a balance row exists for the latest open period counter then retrieve
        -- that else, retrieve the last active row
        OPEN c_iac_asset_bal(l_asset_id,
                           l_book_type_code,
                           l_last_period_counter);
        FETCH c_iac_asset_bal INTO l_iac_asset_bal;
        IF c_iac_asset_bal%NOTFOUND THEN
            CLOSE c_iac_asset_bal;
            OPEN c_iac_asset_bal(l_asset_id,
                              l_book_type_code,
                              l_rsvd_pc);
            FETCH c_iac_asset_bal INTO l_iac_asset_bal;
            IF c_iac_asset_bal%NOTFOUND THEN
                RAISE NO_DATA_FOUND ;
            END IF ;
        END IF;
        CLOSE c_iac_asset_bal;

        -- bug 3391000, end 1

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'Latest period counter:   '||l_last_period_counter);

        -- Calculate the new revalued FA depreciation amount
        IF (p_asset_iac_adj_info.deprn_adjustment_amount = 0) THEN
          -- fetch from fa_deprn_detail
            OPEN c_fa_deprn_adjust_amt(l_asset_id,
                                    l_book_type_code,
                                    l_last_period_counter);
            FETCH c_fa_deprn_adjust_amt INTO l_deprn_amount,
                                            l_fa_deprn_adj_amount,
                                            l_deprn_reserve;
            IF c_fa_deprn_adjust_amt%NOTFOUND THEN
                RAISE NO_DATA_FOUND;
            END IF;
            CLOSE c_fa_deprn_adjust_amt;
        ELSE
            l_deprn_amount := p_asset_iac_adj_info.deprn_amount;
            l_fa_deprn_adj_amount := p_asset_iac_adj_info.deprn_adjustment_amount;
            l_deprn_reserve := p_asset_iac_adj_info.deprn_reserve;
        END IF;

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'FA depreciation adjustment amount:   '||l_fa_deprn_adj_amount);

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'FA depreciation amount:   '||l_deprn_amount);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'FA depreciation reserve:   '||l_deprn_reserve);

        IF ((l_prev_cost <> l_curr_cost OR l_prev_salvage <> l_curr_salvage) AND
            (l_prev_salvage <> 0 OR l_curr_salvage <> 0)) THEN
            l_prev_sv_correction := (l_deprn_reserve - l_deprn_amount) * (l_prev_salvage/(l_prev_cost-l_prev_salvage));
	    do_round(l_prev_sv_correction,l_book_type_code);
            l_curr_sv_correction := (l_deprn_reserve - l_deprn_amount) * (l_curr_salvage/(l_curr_cost-l_curr_salvage));
	    do_round(l_curr_sv_correction,l_book_type_code);
            l_diff_sv_correction := l_curr_sv_correction - l_prev_sv_correction;
        ELSE
            l_diff_sv_correction := 0;
        END IF;
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'Prev Salvage Value Correction:   '||l_prev_sv_correction);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'Curr Salvage Value Correction:   '||l_curr_sv_correction);

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'Salvage Value Correction:   '||l_diff_sv_correction);

        l_fa_deprn_adj_amount := l_fa_deprn_adj_amount + l_diff_sv_correction;

        IF (l_fa_deprn_adj_amount = 0) THEN
            RAISE e_curr_period_amort;
        END IF;

        -- create a new row in igi_iac_transaction_headers with transaction type code
        -- ADJUSTMENT and transaction sub type as COST
        l_new_adj_id := null;

        IGI_IAC_TRANS_HEADERS_PKG.Insert_Row(
               x_rowid                     => l_rowid,
               x_adjustment_id             => l_new_adj_id, -- out NOCOPY parameter
               x_transaction_header_id     => p_adj_hist.transaction_header_id_in, -- bug 3391000 null,
               x_adjustment_id_out         => null,
               x_transaction_type_code     => 'DEPRECIATION',
               x_transaction_date_entered  => sysdate,
               x_mass_refrence_id          => null,
               x_transaction_sub_type      => 'ADJUSTMENT',
               x_book_type_code            => l_book_type_code,
               x_asset_id                  => l_asset_id,
               x_category_id               => p_adj_hist.category_id,
               x_adj_deprn_start_date      => null,
               x_revaluation_type_flag     => null,
               x_adjustment_status         => 'COMPLETE',
               x_period_counter            => l_last_period_counter,
               x_event_id                  => p_event_id
                                           );

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'New adjustment id:   '||l_new_adj_id);

        -- update the previous active row for the asset in igi_iac_transaction_headers
        -- in order to make it inactive by setting adjustment_id_out= adjustment_id of
        -- the active row in igi_iac_transaction_headers
        IGI_IAC_TRANS_HEADERS_PKG.Update_Row(
              x_prev_adjustment_id        => l_adj_id_out,
              x_adjustment_id             => l_new_adj_id
                                          );

        -- calculate the new revlaued deprn adjustment amount
        l_iac_new_deprn_adj_amt := l_fa_deprn_adj_amount*(l_iac_asset_bal.cumulative_reval_factor - 1);

        -- round the depreciation adjustment amount
        l_ret := igi_iac_common_utils.iac_round(l_iac_new_deprn_adj_amt,
                                              l_book_type_code) ;

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'New IAC revalued depreciation adjustment amount:    '||l_iac_new_deprn_adj_amt);

        -- calculate the new deprn_amount, deprn_ytd and deprn_reserve
        l_iac_new_deprn_period := l_iac_new_deprn_adj_amt;
        l_iac_new_deprn_reserve:= l_iac_asset_bal.deprn_reserve + l_iac_new_deprn_adj_amt;

        -- calculate net book value
        -- l_iac_new_nbv := l_iac_asset_bal.net_book_value - l_iac_new_deprn_adj_amt;
        l_iac_new_nbv := l_iac_asset_bal.adjusted_cost -
                          (l_iac_new_deprn_reserve + l_iac_asset_bal.backlog_deprn_reserve);
        -- added 2: 16/12/2003
        -- add gen fun and change IF condition
        --    IF (l_iac_asset_bal.adjusted_cost > 0) THEN
        IF (l_iac_asset_bal.cumulative_reval_factor >= 1) THEN
            l_iac_new_gf := l_iac_asset_bal.general_fund + l_iac_new_deprn_adj_amt;
            l_iac_new_rr := l_iac_asset_bal.reval_reserve -l_iac_new_deprn_adj_amt;
        ELSE
            l_iac_new_gf := l_iac_asset_bal.general_fund;
            l_iac_new_rr := l_iac_asset_bal.reval_reserve;
        END IF;
        -- end 1: 12/12/2003

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'new deprn period:   '||l_iac_new_deprn_period);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            p_full_path => l_path_name,
            p_string => 'new deprn reserve:   '||l_iac_new_deprn_reserve);

        -- Prorate th depreciation ajustment amount for the active distributions in the
        -- ratio of the units assigned to them
        IF NOT igi_iac_common_utils.prorate_amt_to_active_dists(l_book_type_code,
                                                              l_asset_id,
                                                              l_iac_new_deprn_adj_amt,
                                                              l_det_table)
        THEN
            RAISE e_no_proration;
        END IF;

        l_round_diff := 0;

        -- create a new row in igi_iac_det_balances for each active distribution
        FOR l_dist_idx IN l_det_table.FIRST..l_det_table.LAST LOOP
            l_dist_id := l_det_table(l_dist_idx).distribution_id;
            l_dep_adj_amount := l_det_table(l_dist_idx).amount;
            l_units_assigned := l_det_table(l_dist_idx).units;

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
		     	p_string => ' Dist ID: '||l_dist_id||' Units:   '||l_units_assigned
				    ||' adjusted amount:   '||l_dep_adj_amount);

            -- get the detail balances for the distribution for l_latest_adj_id
            OPEN c_det_bal(l_latest_adj_id,
                         l_asset_id,
                         l_book_type_code,
                         l_dist_id);
            FETCH c_det_bal INTO l_det_bal;
            IF c_det_bal%NOTFOUND THEN
                RAISE NO_DATA_FOUND ;
            END IF ;
            CLOSE c_det_bal;
            -- round dep_adj_amount
            l_ret := igi_iac_common_utils.iac_round(l_dep_adj_amount,
                                                  l_book_type_code);
            -- maintain the diff due to rounding
            l_round_diff := l_round_diff + l_dep_adj_amount;

            IF (l_dist_idx = l_det_table.LAST) THEN
                -- add rounding diff to the last distribution
                l_dep_adj_amount := l_dep_adj_amount + (l_iac_new_deprn_adj_amt - l_round_diff);
            END IF;

            -- calcluate the new depreciation figures
            l_new_dist_dep_prd := l_dep_adj_amount;
            l_new_dist_dep_rsv := l_det_bal.deprn_reserve + l_dep_adj_amount;
            l_new_dist_dep_ytd := l_det_bal.deprn_ytd + l_dep_adj_amount;

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => 'new dist deprn period:   '||l_new_dist_dep_prd);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => 'new dist deprn reserve:   '||l_new_dist_dep_rsv);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => 'new dist deprn ytd:    '||l_new_dist_dep_ytd);

            -- added 2, 16/12/2003
            -- added gen fund, and change IF condition
            --     IF (l_det_bal.adjustment_cost > 0) THEN
            IF (l_iac_asset_bal.cumulative_reval_factor >= 1) THEN
                l_new_dist_rr_gf := l_det_bal.reval_reserve_gen_fund + l_dep_adj_amount;
                --    l_new_dist_rr_net := l_det_bal.reval_reserve_net + l_dep_adj_amount;
                l_new_dist_rr_net := l_det_bal.reval_reserve_cost -
                                   ( l_det_bal.reval_reserve_backlog + l_new_dist_rr_gf);

                l_new_dist_gf_per := l_new_dist_dep_prd;
                l_new_dist_gf_acc := l_det_bal.general_fund_acc + l_dep_adj_amount;
            ELSE
                l_new_dist_rr_gf := l_det_bal.reval_reserve_gen_fund;
                l_new_dist_rr_net := l_det_bal.reval_reserve_net;
                l_new_dist_gf_per := l_det_bal.general_fund_per;
                l_new_dist_gf_acc := l_det_bal.general_fund_acc;
            END IF;
            -- calculate the nbv
            --  l_new_dist_nbv := l_det_bal.net_book_value - l_dep_adj_amount;
            l_new_dist_nbv := l_det_bal.adjustment_cost -
                          (l_new_dist_dep_rsv + l_det_bal.deprn_reserve_backlog);
            -- insert the row into igi_iac_det_balances
            IF p_asset_iac_adj_info.period_counter_fully_reserved IS NOT NULL THEN
                l_iac_deprn_period_amount := 0;
            ELSE
                l_iac_deprn_period_amount := l_new_dist_dep_prd;
            END IF;

            IGI_IAC_DET_BALANCES_PKG.Insert_Row(
                     x_rowid                    => l_rowid,
                     x_adjustment_id            => l_new_adj_id,
                     x_asset_id                 => l_asset_id,
                     x_book_type_code           => l_book_type_code,
                     x_distribution_id          => l_dist_id,
                     x_period_counter           => l_last_period_counter,
                     x_adjustment_cost          => l_det_bal.adjustment_cost,
                     x_net_book_value           => l_new_dist_nbv, -- l_det_bal.net_book_value,
                     x_reval_reserve_cost       => l_det_bal.reval_reserve_cost,
                     x_reval_reserve_backlog    => l_det_bal.reval_reserve_backlog,
                     x_reval_reserve_gen_fund   => l_new_dist_rr_gf, -- l_det_bal.reval_reserve_gen_fund,
                     x_reval_reserve_net        => l_new_dist_rr_net, -- l_det_bal.reval_reserve_net,
                     x_operating_acct_cost      => l_det_bal.operating_acct_cost,
                     x_operating_acct_backlog   => l_det_bal.operating_acct_backlog,
                     x_operating_acct_net       => l_det_bal.operating_acct_net,
                     x_operating_acct_ytd       => l_det_bal.operating_acct_ytd,
                     x_deprn_period             => l_iac_deprn_period_amount,
                     x_deprn_ytd                => l_new_dist_dep_ytd,
                     x_deprn_reserve            => l_new_dist_dep_rsv,
                     x_deprn_reserve_backlog    => l_det_bal.deprn_reserve_backlog,
                     x_general_fund_per         => l_new_dist_gf_per, -- l_det_bal.general_fund_per,
                     x_general_fund_acc         => l_new_dist_gf_acc, -- l_det_bal.general_fund_acc,
                     x_last_reval_date          => l_det_bal.last_reval_date,
                     x_current_reval_factor     => l_det_bal.current_reval_factor,
                     x_cumulative_reval_factor  => l_det_bal.cumulative_reval_factor,
                     x_active_flag              => null,
                     x_mode                     => 'R'
                                                );

            -- create accounting entries only if iac adjustment is not equal to zero
            IF (l_dep_adj_amount <> 0) THEN
                -- find the ccid for EXPENSE
                IF NOT igi_iac_common_utils.get_account_ccid(l_book_type_code,
                                                         l_asset_id,
                                                         l_det_bal.distribution_id,
                                                         'DEPRN_EXPENSE_ACCT',
                                                         l_ccid)
                THEN
                    RAISE e_no_ccid_found;
                END IF;

                -- insert into igi_iac_adjustments for EXPENSE
                IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                                    x_rowid    => l_rowid,
                            x_adjustment_id    => l_new_adj_id,
                           x_book_type_code    => l_book_type_code,
                      x_code_combination_id    => l_ccid,
                          x_set_of_books_id    => l_sob_id,
                               x_dr_cr_flag    => 'DR',
                                   x_amount    => l_new_dist_dep_prd,
                          x_adjustment_type    => 'EXPENSE',
                      x_transfer_to_gl_flag    => 'Y',
                           x_units_assigned    => l_units_assigned,
                                 x_asset_id    => l_asset_id,
                          x_distribution_id    => l_det_bal.distribution_id,
                           x_period_counter    => l_last_period_counter,
                   x_adjustment_offset_type    => 'RESERVE',
                              x_report_ccid    => Null,
                                     x_mode    => 'R',
                                 x_event_id    => p_event_id
                                                );

                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                    p_full_path => l_path_name,
                    p_string => 'EXPENSE ccid:  '||l_ccid);

                -- find the ccid for RESERVE
                IF NOT igi_iac_common_utils.get_account_ccid(l_book_type_code,
                                                         l_asset_id,
                                                         l_det_bal.distribution_id,
                                                         'DEPRN_RESERVE_ACCT',
                                                         l_ccid)
                THEN
                    RAISE e_no_ccid_found;
                END IF;

                -- insert into igi_iac_adjustments for RESERVE
                IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                                    x_rowid    => l_rowid,
                            x_adjustment_id    => l_new_adj_id,
                           x_book_type_code    => l_book_type_code,
                      x_code_combination_id    => l_ccid,
                          x_set_of_books_id    => l_sob_id,
                               x_dr_cr_flag    => 'CR',
                                   x_amount    => l_new_dist_dep_prd,
                          x_adjustment_type    => 'RESERVE',
                      x_transfer_to_gl_flag    => 'Y',
                           x_units_assigned    => l_units_assigned,
                                 x_asset_id    => l_asset_id,
                          x_distribution_id    => l_det_bal.distribution_id,
                           x_period_counter    => l_last_period_counter,
		   x_adjustment_offset_type    => 'EXPENSE',
			      x_report_ccid    => Null,
                                     x_mode    => 'R',
                  x_event_id                   => p_event_id
                                                );

                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                    p_full_path => l_path_name,
                    p_string => 'RESERVE ccid:  '||l_ccid);

                IF (l_iac_asset_bal.cumulative_reval_factor >= 1) THEN
                    -- find the ccid for REVAL RESERVE
                    IF NOT igi_iac_common_utils.get_account_ccid(l_book_type_code,
                                                             l_asset_id,
                                                             l_det_bal.distribution_id,
                                                             'REVAL_RESERVE_ACCT',
                                                             l_reval_rsv_ccid)
                    THEN
                        RAISE e_no_ccid_found;
                    END IF;

                    -- insert into igi_iac_adjustments for EXPENSE
                    IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                                    x_rowid    => l_rowid,
                            x_adjustment_id    => l_new_adj_id,
                           x_book_type_code    => l_book_type_code,
                      x_code_combination_id    => l_reval_rsv_ccid,
                          x_set_of_books_id    => l_sob_id,
                               x_dr_cr_flag    => 'DR',
                                   x_amount    => l_new_dist_dep_prd,
                          x_adjustment_type    => 'REVAL RESERVE',
                      x_transfer_to_gl_flag    => 'Y',
                           x_units_assigned    => l_units_assigned,
                                 x_asset_id    => l_asset_id,
                          x_distribution_id    => l_det_bal.distribution_id,
                           x_period_counter    => l_last_period_counter,
		   x_adjustment_offset_type    => 'GENERAL FUND',
			      x_report_ccid    => Null ,
                                     x_mode    => 'R',
                  x_event_id                   => p_event_id
                                                );

                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'EXPENSE ccid:  '||l_ccid);

                    -- find the ccid for GENERAL FUND
                    IF NOT igi_iac_common_utils.get_account_ccid(l_book_type_code,
                                                            l_asset_id,
                                                            l_det_bal.distribution_id,
                                                            'GENERAL_FUND_ACCT',
                                                            l_ccid)
                    THEN
                        RAISE e_no_ccid_found;
                    END IF;

                    -- insert into igi_iac_adjustments for EXPENSE
                    IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                                    x_rowid    => l_rowid,
                            x_adjustment_id    => l_new_adj_id,
                           x_book_type_code    => l_book_type_code,
                      x_code_combination_id    => l_ccid,
                          x_set_of_books_id    => l_sob_id,
                               x_dr_cr_flag    => 'CR',
                                   x_amount    => l_new_dist_dep_prd,
                          x_adjustment_type    => 'GENERAL FUND',
                      x_transfer_to_gl_flag    => 'Y',
                           x_units_assigned    => l_units_assigned,
                                 x_asset_id    => l_asset_id,
                          x_distribution_id    => l_det_bal.distribution_id,
                           x_period_counter    => l_last_period_counter,
		   x_adjustment_offset_type    => 'REVAL RESERVE',
			      x_report_ccid    => l_reval_rsv_ccid ,
                                     x_mode    => 'R',
                  x_event_id                   => p_event_id
                                                );

                    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                        p_full_path => l_path_name,
                        p_string => 'RESERVE ccid:  '||l_ccid);

                END IF; -- reval factor >= 1
            END IF; -- if iac deprn adjustment amount <> 0
        END LOOP;

        -- do the igi_iac_fa_deprn active distributions
        FOR l_fa_idx  IN p_asset_iac_dist_info.FIRST.. p_asset_iac_dist_info.LAST LOOP
            l_fa_deprn_adj_amount := p_asset_iac_dist_info(l_fa_idx).deprn_adjustment_amount;

            -- calculate the IAC maintained YTD figures
            OPEN c_get_fa_iac_deprn(p_asset_iac_dist_info(l_fa_idx).distribution_id,
                                  l_latest_adj_id);

            FETCH c_get_fa_iac_deprn INTO l_fa_deprn_ytd, l_fa_deprn_period, l_fa_deprn_reserve;
            IF c_get_fa_iac_deprn%NOTFOUND THEN
                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                    p_full_path => l_path_name,
                    p_string => 'Fetching FA deprn detail values for IGI_IAC_FA_DEPRN');
                l_fa_deprn_period := p_asset_iac_dist_info(l_fa_idx).deprn_adjustment_amount;
                l_fa_deprn_ytd := p_asset_iac_dist_info(l_fa_idx).ytd_deprn;
                l_fa_deprn_reserve := p_asset_iac_dist_info(l_fa_idx).deprn_reserve;
            ELSE
                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                    p_full_path => l_path_name,
                    p_string => 'Fetching IAC FA deprn detail values for IGI_IAC_FA_DEPRN');
                l_fa_deprn_period := l_fa_deprn_adj_amount;
                l_fa_deprn_ytd := l_fa_deprn_ytd + l_fa_deprn_adj_amount;
                l_fa_deprn_reserve := l_fa_deprn_reserve + l_fa_deprn_adj_amount;
            END IF;
            CLOSE c_get_fa_iac_deprn;

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                p_full_path => l_path_name,
                p_string => 'new FA dist deprn period:   '||l_fa_deprn_period);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		    	p_string => 'new FA dist deprn reserve:   '||l_fa_deprn_reserve);
            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		    	p_string => 'new FA dist deprn ytd:    '||l_fa_deprn_ytd);

            IF p_asset_iac_adj_info.period_counter_fully_reserved IS NOT NULL THEN
                l_fa_deprn_period_amount := 0;
            ELSE
                l_fa_deprn_period_amount := l_fa_deprn_period;
            END IF;
           -- insert into igi_iac_fa_deprn
            IGI_IAC_FA_DEPRN_PKG.Insert_Row(
                 x_rowid                => l_rowid,
                 x_book_type_code       => l_book_type_code,
                 x_asset_id             => l_asset_id,
                 x_period_counter       => l_last_period_counter,
                 x_adjustment_id        => l_new_adj_id,
                 x_distribution_id      => p_asset_iac_dist_info(l_fa_idx).distribution_id,
                 x_deprn_period         => l_fa_deprn_period_amount,
                 x_deprn_ytd            => l_fa_deprn_ytd,
                 x_deprn_reserve        => l_fa_deprn_reserve,
                 x_active_flag          => null,
                 x_mode                 => 'R'
                                        );

            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'IAC FA Deprn row inserted:   '||l_new_adj_id);

        END LOOP;

        -- Roll YTD rows forward
        -- Carry forward any inactive distributions from the previous adjustment to the new adjustment
        igi_iac_adj_cost_reval_pkg.Roll_YTD_Forward(l_asset_id,
                                                  l_book_type_code,
                                                  l_latest_adj_id,
                                                  l_new_adj_id,
                                                  l_last_period_counter);

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'YTD rows rolled forward');

        -- check if a row exists in igi_iac_asset_balances for l_last_period_counter
        -- if it does then update it else insert a new row
        SELECT count(*)
        INTO l_exists
        FROM igi_iac_asset_balances
        WHERE asset_id = l_asset_id
        AND   book_type_code = l_book_type_code
        AND   period_counter = l_last_period_counter;

        -- Update row in IGI_IAC_ASSET_BALANCES for the asset for the new revalued iac cost using
        -- IGI_IAC_ASSET_BALANCES.Update_Row

        IF p_asset_iac_adj_info.period_counter_fully_reserved IS NOT NULL THEN
            l_iac_deprn_period_amount := 0;
        ELSE
            l_iac_deprn_period_amount := l_iac_new_deprn_period;
        END IF;

        IF (l_exists > 0) THEN
            IGI_IAC_ASSET_BALANCES_PKG.Update_Row(
                   X_asset_id                => l_asset_id,
                   X_book_type_code          => l_book_type_code,
                   X_period_counter          => l_iac_asset_bal.period_counter,
                   X_net_book_value          => l_iac_new_nbv, -- l_iac_asset_bal.net_book_value,
                   X_adjusted_cost           => l_iac_asset_bal.adjusted_cost,
                   X_operating_acct          => l_iac_asset_bal.operating_acct,
                   X_reval_reserve           => l_iac_new_rr, -- l_iac_asset_bal.reval_reserve,
                   X_deprn_amount            => l_iac_deprn_period_amount,
                   X_deprn_reserve           => l_iac_new_deprn_reserve,
                   X_backlog_deprn_reserve   => l_iac_asset_bal.backlog_deprn_reserve,
                   X_general_fund            => l_iac_new_gf, -- l_iac_asset_bal.general_fund,
                   X_last_reval_date         => l_iac_asset_bal.last_reval_date,
                   X_current_reval_factor    => l_iac_asset_bal.current_reval_factor,
                   X_cumulative_reval_factor => l_iac_asset_bal.cumulative_reval_factor
                                             ) ;
        ELSE
            -- insert a row for the last period counter
            IGI_IAC_ASSET_BALANCES_PKG.Insert_Row(
                   X_rowid                   => l_rowid,
                   X_asset_id                => l_asset_id,
                   X_book_type_code          => l_book_type_code,
                   X_period_counter          => l_last_period_counter,
                   X_net_book_value          => l_iac_new_nbv, -- l_iac_asset_bal.net_book_value,
                   X_adjusted_cost           => l_iac_asset_bal.adjusted_cost,
                   X_operating_acct          => l_iac_asset_bal.operating_acct,
                   X_reval_reserve           => l_iac_new_rr, -- l_iac_asset_bal.reval_reserve,
                   X_deprn_amount            => l_iac_deprn_period_amount,
                   X_deprn_reserve           => l_iac_new_deprn_reserve,
                   X_backlog_deprn_reserve   => l_iac_asset_bal.backlog_deprn_reserve,
                   X_general_fund            => l_iac_new_gf, -- l_iac_asset_bal.general_fund,
                   X_last_reval_date         => l_iac_asset_bal.last_reval_date,
                   X_current_reval_factor    => l_iac_asset_bal.current_reval_factor,
                   X_cumulative_reval_factor => l_iac_asset_bal.cumulative_reval_factor
                                              ) ;
        END IF;

        -- successful completion
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'Adjustment Amortized Depreciation Reval completed successfully!!!');
        -- rollback;
        RETURN TRUE;

    EXCEPTION
        WHEN e_latest_trx_not_avail THEN
            igi_iac_debug_pkg.debug_other_string(p_level => g_excep_level,
                p_full_path => l_path_name,
                p_string => 'Latest transaction for the asset could not be retrieved');
            FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_NO_LATEST_TRX');
            RETURN FALSE;

        WHEN e_no_period_info_avail THEN
            igi_iac_debug_pkg.debug_other_string(p_level => g_excep_level,
                p_full_path => l_path_name,
                p_string => 'No open period information available for the book');
            FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_NO_PERIOD_INFO');
            RETURN FALSE;

        WHEN e_no_gl_info THEN
            igi_iac_debug_pkg.debug_other_string(p_level => g_excep_level,
                p_full_path => l_path_name,
                p_string => 'Could not retrive GL information for Book');
            FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_NO_GL_INFO');
            RETURN FALSE;

        WHEN e_no_ccid_found THEN
            igi_iac_debug_pkg.debug_other_string(p_level => g_excep_level,
                p_full_path => l_path_name,
                p_string => 'CCID could not be found');
            FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_WF_FAILED_CCID');
            RETURN FALSE;

        WHEN e_no_proration THEN
            igi_iac_debug_pkg.debug_other_string(p_level => g_excep_level,
                p_full_path => l_path_name,
                p_string => 'Amount could not be prorated among the distributions');
            FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_NO_PRORATION');
            RETURN FALSE;

        WHEN e_asset_life_err THEN
            igi_iac_debug_pkg.debug_other_string(p_level => g_excep_level,
                p_full_path => l_path_name,
                p_string => 'Asset life could not be checked');
            FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_ASSET_LIFE_ERR');
            RETURN FALSE;

        WHEN e_non_dep_asset THEN
            igi_iac_debug_pkg.debug_other_string(p_level => g_excep_level,
                p_full_path => l_path_name,
                p_string => 'No further processing for non-depreciating asset');
            FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_NON_DEP_ASSET',
                Token1      => 'ASSET_NUM',
                Value1      =>  g_asset_num);
            RETURN TRUE;

        WHEN e_curr_period_amort THEN
            igi_iac_debug_pkg.debug_other_string(p_level => g_excep_level,
                p_full_path => l_path_name,
                p_string => 'No further processing for current period amortized asset');
            FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_CURR_PRD_AMORT',
                Token1      => 'ASSET_NUM',
                Value1      => g_asset_num);
            RETURN TRUE;

        WHEN others  THEN
            igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
            FA_SRVR_MSG.add_sql_error(Calling_Fn  => g_calling_fn);
            RETURN FALSE;

    END Do_Amort_Deprn_Reval;

BEGIN
    l_calling_function := '***Amort***';
    g_calling_fn  := 'IGI_IAC_ADJ_AMORT_PKG.Do_Amort_Deprn_Reval';

    --===========================FND_LOG.START=====================================
    g_state_level 	     	:=	FND_LOG.LEVEL_STATEMENT;
    g_proc_level  	     	:=	FND_LOG.LEVEL_PROCEDURE;
    g_event_level 	     	:=	FND_LOG.LEVEL_EVENT;
    g_excep_level 	     	:=	FND_LOG.LEVEL_EXCEPTION;
    g_error_level 	     	:=	FND_LOG.LEVEL_ERROR;
    g_unexp_level 	     	:=	FND_LOG.LEVEL_UNEXPECTED;
    g_path          := 'IGI.PLSQL.igiiadab.igi_iac_adj_amort_pkg.';
    --===========================FND_LOG.END=====================================

END IGI_IAC_ADJ_AMORT_PKG;

/
