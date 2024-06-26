--------------------------------------------------------
--  DDL for Package Body IGI_IAC_ADJ_COST_REVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_ADJ_COST_REVAL_PKG" AS
-- $Header: igiiadcb.pls 120.22.12010000.2 2010/06/24 11:07:12 schakkin ship $
   -- ===================================================================
   -- Global Variables
   -- ===================================================================

   l_calling_function varchar2(255);
   g_calling_fn  VARCHAR2(200);
   g_debug_mode  BOOLEAN;

   l_rowid       ROWID;

   --===========================FND_LOG.START=====================================

   g_state_level NUMBER;
   g_proc_level  NUMBER;
   g_event_level NUMBER;
   g_excep_level NUMBER;
   g_error_level NUMBER;
   g_unexp_level NUMBER;
   g_path        VARCHAR2(100);

   --===========================FND_LOG.END=====================================

   -- ===================================================================
   -- Local functions and procedures
   -- ===================================================================

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
   PROCEDURE debug_adj_asset(p_asset igi_iac_types.iac_adj_hist_asset_info)
   IS
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

-- -------------------------------------------------------------------
-- FUNCTION Chk_Asset_Life: Find if the life of asset is completed in
-- the given period
-- -------------------------------------------------------------------
  FUNCTION  Chk_Asset_Life(p_book_code fa_books.book_type_code%TYPE,
                           p_period_counter fa_deprn_periods.period_counter%TYPE,
                           p_asset_id fa_books.asset_id%TYPE,
                           l_last_period_counter OUT NOCOPY fa_deprn_periods.period_counter%TYPE
                           )
  RETURN BOOLEAN
  IS

  CURSOR c_get_asset_det(n_book_code   fa_books.book_type_code%TYPE,
                         n_asset_id    fa_books.asset_id%TYPE
                        )
  IS
  SELECT date_placed_in_service,
         life_in_months
  FROM fa_books
  WHERE book_type_code = n_book_code
  AND asset_id = n_asset_id
  AND transaction_header_id_out IS NULL;

  CURSOR c_get_periods_in_year(n_book_code fa_books.book_type_code%TYPE)
  IS
  SELECT number_per_fiscal_year
  FROM fa_calendar_types
  WHERE calendar_type = (SELECT deprn_calendar
                         FROM fa_book_controls
                         WHERE book_type_code = n_book_code);


  l_prd_rec_frm_ctr 		igi_iac_types.prd_rec;
  l_prd_rec_frm_date		igi_iac_types.prd_rec;
  l_end_date            	DATE;
  l_asset_rec			c_get_asset_det%ROWTYPE;
  l_ret_flag			BOOLEAN;
  l_mess			varchar2(255);

  l_periods_in_year             fa_calendar_types.number_per_fiscal_year%TYPE;
  l_dpis_prd_rec                igi_iac_types.prd_rec;
  l_total_periods               NUMBER;
  l_path_name VARCHAR2(150);

  BEGIN
	l_path_name := g_path||'chk_asset_life';

       OPEN  c_get_asset_det(p_book_code,
                             p_asset_id
                            );
       FETCH c_get_asset_det INTO l_asset_rec;
       CLOSE c_get_asset_det;

       OPEN c_get_periods_in_year(p_book_code);
       FETCH c_get_periods_in_year INTO l_periods_in_year;
       CLOSE c_get_periods_in_year;

	   -- Get the period info for the dpis
	   l_ret_flag := igi_iac_common_utils.Get_period_info_for_date(p_book_code,
                                                                    l_asset_rec.date_placed_in_service,
                                                                    l_dpis_prd_rec
                                                                   );
       l_total_periods := ceil((l_asset_rec.life_in_months*l_periods_in_year)/12);
       l_last_period_counter := (l_dpis_prd_rec.period_counter + l_total_periods - 1);

       RETURN TRUE;

  EXCEPTION
  WHEN OTHERS THEN
      igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
      RETURN FALSE;
  END Chk_Asset_Life;

   -- -------------------------------------------------------------------
   -- PROCEDURE Roll_YTD_Forward: Procedure that will roll forward any
   -- YTD rows from the previous adjustment_id
   -- -------------------------------------------------------------------
   PROCEDURE Roll_YTD_Forward(p_asset_id        igi_iac_det_balances.asset_id%TYPE,
                              p_book_type_code  igi_iac_det_balances.book_type_code%TYPE,
                              p_prev_adj_id     igi_iac_det_balances.adjustment_id%TYPE,
                              p_new_adj_id      igi_iac_det_balances.adjustment_id%TYPE,
                              p_prd_counter     igi_iac_det_balances.period_counter%TYPE)
   IS

   -- cursor to retrieve the YTD row that will be rolled forward
   CURSOR c_get_ytd(cp_adjustment_id   igi_iac_det_balances.adjustment_id%TYPE,
                    cp_asset_id        igi_iac_det_balances.asset_id%TYPE,
                    cp_book_type_code  igi_iac_det_balances.book_type_code%TYPE)
   IS
   SELECT iidb.adjustment_id,
          iidb.distribution_id,
          iidb.adjustment_cost,
          iidb.net_book_value,
          iidb.reval_reserve_cost,
          iidb.reval_reserve_backlog,
          iidb.reval_reserve_gen_fund,
          iidb.reval_reserve_net,
          iidb.operating_acct_cost,
          iidb.operating_acct_backlog,
          iidb.operating_acct_net,
          iidb.operating_acct_ytd,
          iidb.deprn_period,
          iidb.deprn_ytd,
          iidb.deprn_reserve,
          iidb.deprn_reserve_backlog,
          iidb.general_fund_per,
          iidb.general_fund_acc,
          iidb.active_flag,
          iidb.last_reval_date,
          iidb.current_reval_factor,
          iidb.cumulative_reval_factor
   FROM   igi_iac_det_balances iidb
   WHERE  iidb.adjustment_id = cp_adjustment_id
   AND    iidb.asset_id = cp_asset_id
   AND    iidb.book_type_code = cp_book_type_code
   AND    iidb.active_flag = 'N';

   -- Cursor to fetch depreciation balances from
   -- igi_iac_fa_deprn for a adjustment_id and
   -- distribution_id
   CURSOR c_get_fa_deprn(cp_adjustment_id   igi_iac_fa_deprn.adjustment_id%TYPE,
                         cp_distribution_id igi_iac_fa_deprn.distribution_id%TYPE)
   IS
   SELECT iifd.deprn_ytd
   FROM   igi_iac_fa_deprn iifd
   WHERE  iifd.adjustment_id = cp_adjustment_id
   AND    iifd.distribution_id = cp_distribution_id
   AND    iifd.active_flag = 'N';

   -- cursor to retieve the ytd value for a distribution
   CURSOR c_get_fa_ytd(cp_book_type_code  fa_deprn_detail.book_type_code%TYPE,
                       cp_asset_id        fa_deprn_detail.asset_id%TYPE,
                       cp_distribution_id fa_deprn_detail.distribution_id%TYPE)
   IS
   SELECT sum(nvl(fdd.deprn_amount,0)-nvl(fdd.deprn_adjustment_amount,0)) deprn_YTD
   FROM fa_deprn_detail fdd
   WHERE fdd.distribution_id = cp_distribution_id
   AND fdd.book_type_code = cp_book_type_code
   AND fdd.asset_id = cp_asset_id
   AND fdd.period_counter IN (SELECT period_counter
                              FROM fa_deprn_periods
                              WHERE book_type_code = cp_book_type_code
                              AND fiscal_year = (SELECT fiscal_year
                                                 FROM fa_deprn_periods
                                                 WHERE period_close_date IS NULL
                                                 AND book_type_code = cp_book_type_code))
   GROUP BY fdd.distribution_id;

   -- local variables
   l_get_ytd       c_get_ytd%ROWTYPE;
   l_fa_deprn_ytd  igi_iac_fa_deprn.deprn_ytd%TYPE;

   BEGIN
       FOR l_get_ytd IN c_get_ytd(p_prev_adj_id,p_asset_id, p_book_type_code)  LOOP
       -- insert into igi_iac_det_balances with reinstatement adjustment_id

        IGI_IAC_DET_BALANCES_PKG.Insert_Row(
                     x_rowid                    => l_rowid,
                     x_adjustment_id            => p_new_adj_id,
                     x_asset_id                 => p_asset_id,
                     x_book_type_code           => p_book_type_code,
                     x_distribution_id          => l_get_ytd.distribution_id,
                     x_period_counter           => p_prd_counter,
                     x_adjustment_cost          => l_get_ytd.adjustment_cost,
                     x_net_book_value           => l_get_ytd.net_book_value,
                     x_reval_reserve_cost       => l_get_ytd.reval_reserve_cost,
                     x_reval_reserve_backlog    => l_get_ytd.reval_reserve_backlog,
                     x_reval_reserve_gen_fund   => l_get_ytd.reval_reserve_gen_fund,
                     x_reval_reserve_net        => l_get_ytd.reval_reserve_net,
                     x_operating_acct_cost      => l_get_ytd.operating_acct_cost,
                     x_operating_acct_backlog   => l_get_ytd.operating_acct_backlog,
                     x_operating_acct_net       => l_get_ytd.operating_acct_net,
                     x_operating_acct_ytd       => l_get_ytd.operating_acct_ytd,
                     x_deprn_period             => l_get_ytd.deprn_period,
                     x_deprn_ytd                => l_get_ytd.deprn_ytd,
                     x_deprn_reserve            => l_get_ytd.deprn_reserve,
                     x_deprn_reserve_backlog    => l_get_ytd.deprn_reserve_backlog,
                     x_general_fund_per         => l_get_ytd.general_fund_per,
                     x_general_fund_acc         => l_get_ytd.general_fund_acc,
                     x_last_reval_date          => l_get_ytd.last_reval_date,
                     x_current_reval_factor     => l_get_ytd.current_reval_factor,
                     x_cumulative_reval_factor  => l_get_ytd.cumulative_reval_factor,
                     x_active_flag              => l_get_ytd.active_flag
                                                );

        -- roll forward YTD rows for igi_iac_fa_deprn as well
        OPEN c_get_fa_deprn(l_get_ytd.adjustment_id,
                            l_get_ytd.distribution_id);
        FETCH c_get_fa_deprn INTO l_fa_deprn_ytd;
        IF c_get_fa_deprn%NOTFOUND THEN
            OPEN c_get_fa_ytd(p_book_type_code,
                              p_asset_id,
                              l_get_ytd.distribution_id);
            FETCH c_get_fa_ytd INTO l_fa_deprn_ytd;
            IF c_get_fa_ytd%NOTFOUND THEN
                l_fa_deprn_ytd := 0;
            END IF;
            CLOSE c_get_fa_ytd;
        END IF;
        CLOSE c_get_fa_deprn;

        -- insert into igi_iac_fa_deprn with the new adjustment_id
        IGI_IAC_FA_DEPRN_PKG.Insert_Row(
               x_rowid                => l_rowid,
               x_book_type_code       => p_book_type_code,
               x_asset_id             => p_asset_id,
               x_period_counter       => p_prd_counter,
               x_adjustment_id        => p_new_adj_id,
               x_distribution_id      => l_get_ytd.distribution_id,
               x_deprn_period         => 0,
               x_deprn_ytd            => l_fa_deprn_ytd,
               x_deprn_reserve        => 0,
               x_active_flag          => 'N',
               x_mode                 => 'R'
                                      );

       END LOOP;
   END Roll_YTD_Forward;

   -- ===================================================================
   -- Main public functions and procedures
   -- ===================================================================

   -- -------------------------------------------------------------------
   -- PROCEDURE Do_Cost_Revaluation: This is the main function that will
   -- do the cost revaluation if an asset has had cost adjustment done
   -- against it
   -- -------------------------------------------------------------------
   FUNCTION Do_Cost_Revaluation
               (p_asset_iac_adj_info    igi_iac_types.iac_adj_hist_asset_info,
                p_asset_iac_dist_info   igi_iac_types.iac_adj_dist_info_tab,
                p_adj_hist              igi_iac_adjustments_history%ROWTYPE,
                p_event_id              number)  --R12 uptake
   RETURN BOOLEAN
   IS
     -- local cursors

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
    CURSOR c_get_fa_iac_deprn(cp_adjustment_id   igi_iac_fa_deprn.adjustment_id%TYPE,
                              cp_distribution_id igi_iac_fa_deprn.distribution_id%TYPE)
    IS
    SELECT iifd.deprn_ytd,
           iifd.deprn_period,
           iifd.deprn_reserve
    FROM   igi_iac_fa_deprn iifd
    WHERE  iifd.adjustment_id = cp_adjustment_id
    AND    iifd.distribution_id = cp_distribution_id
    AND    iifd.active_flag IS NULL;

    -- cursor to check if asset is non depreciating
/*    CURSOR c_asset_non_depr(cp_asset_id       fa_books.asset_id%TYPE,
                            cp_book_type_code fa_books.book_type_code%TYPE)
    IS
    SELECT depreciate_flag
    FROM fa_books
    WHERE book_type_code = cp_book_type_code
    AND   asset_id = cp_asset_id
    AND   date_ineffective IS NULL;
*/
     -- local variables
     l_asset_id            fa_books.asset_id%TYPE;
     l_book_type_code      fa_books.book_type_code%TYPE;
     l_fully_rsvd_pc       fa_books.period_counter_fully_reserved%TYPE;
--     l_deprn_flag          fa_books.depreciate_flag%TYPE;
     l_adj_id_out          igi_iac_transaction_headers.adjustment_id_out%TYPE;

     l_latest_trx_type     igi_iac_transaction_headers.transaction_type_code%TYPE;
     l_latest_trx_id       igi_iac_transaction_headers.transaction_header_id%TYPE;
     l_latest_mref_id      igi_iac_transaction_headers.mass_reference_id%TYPE;
     l_latest_adj_id       igi_iac_transaction_headers.adjustment_id%TYPE;
     l_prev_adj_id         igi_iac_transaction_headers.adjustment_id%TYPE;
     l_latest_adj_status   igi_iac_transaction_headers.adjustment_status%TYPE;
     l_iac_asset_bal       c_iac_asset_bal%ROWTYPE;
     l_new_adj_id          igi_iac_transaction_headers.adjustment_id%TYPE;
     l_prd_rec             IGI_IAC_TYPES.prd_rec;
     l_iac_new_reval_cost  igi_iac_asset_balances.adjusted_cost%TYPE;
     l_iac_new_nbv         igi_iac_asset_balances.net_book_value%TYPE;
     l_iac_new_rr          igi_iac_asset_balances.reval_reserve%TYPE;
     l_iac_new_op          igi_iac_asset_balances.operating_acct%TYPE;

     l_diff_cost           igi_iac_asset_balances.adjusted_cost%TYPE;
     l_ret                 BOOLEAN;
     l_det_table           IGI_IAC_TYPES.dist_amt_tab;
     l_det_bal             c_det_bal%ROWTYPE;

     l_dist_idx            NUMBER;
     l_add_cost            igi_iac_det_balances.adjustment_cost%TYPE;
     l_dist_id             igi_iac_det_balances.distribution_id%TYPE;
     l_new_dist_cost       igi_iac_det_balances.adjustment_cost%TYPE;
     l_new_dist_nbv        igi_iac_det_balances.net_book_value%TYPE;
     l_new_dist_rr_cost    igi_iac_det_balances.reval_reserve_cost%TYPE;
     l_new_dist_rr_net     igi_iac_det_balances.reval_reserve_net%TYPE;
     l_new_dist_op_cost    igi_iac_det_balances.operating_acct_cost%TYPE;
     l_new_dist_op_net     igi_iac_det_balances.operating_acct_net%TYPE;

     l_fa_deprn_period     igi_iac_fa_deprn.deprn_period%TYPE;
     l_fa_deprn_reserve    igi_iac_fa_deprn.deprn_reserve%TYPE;
     l_fa_deprn_ytd        igi_iac_fa_deprn.deprn_ytd%TYPE;

     l_dr_cr_flag_c        igi_iac_adjustments.dr_cr_flag%TYPE;
     l_dr_cr_flag_ro       igi_iac_adjustments.dr_cr_flag%TYPE;
     l_adjust_type         VARCHAR2(15);
 --    l_ccid                igi_iac_adjustments.code_combination_id%TYPE;
     l_cost_ccid           igi_iac_adjustments.code_combination_id%TYPE;
     l_reval_rsv_ccid      igi_iac_adjustments.code_combination_id%TYPE;
     l_op_exp_ccid         igi_iac_adjustments.code_combination_id%TYPE;
     l_report_ccid         igi_iac_adjustments.code_combination_id%TYPE;
     l_adjustment_offset_type VARCHAR2(50);
     l_units_assigned      igi_iac_adjustments.units_assigned%TYPE;
     l_last_period_counter igi_iac_transaction_headers.period_counter%TYPE;
     l_rsvd_pc             igi_iac_transaction_headers.period_counter%TYPE;

     l_sob_id              NUMBER;
     l_coa_id              NUMBER;
     l_currency            VARCHAR2(15);
     l_precision           NUMBER;

     l_fa_idx              NUMBER;
     l_round_diff          NUMBER;
     l_round_diff_nbv      NUMBER;
     l_round_diff_rr_cost  NUMBER;
     l_round_diff_rr_net   NUMBER;
     l_round_diff_op_cost  NUMBER;
     l_round_diff_op_net   NUMBER;

     l_exists              NUMBER;
     l_path_name VARCHAR2(150);

     -- exceptions
     e_latest_trx_not_avail    EXCEPTION;
     e_no_period_info_avail    EXCEPTION;
     e_no_ccid_found           EXCEPTION;
     e_no_proration            EXCEPTION;
     e_asset_life_err          EXCEPTION;
     e_no_gl_info              EXCEPTION;

   BEGIN -- do cost revaluation
     l_round_diff           := 0;
     l_round_diff_nbv       := 0;
     l_round_diff_rr_cost   := 0;
     l_round_diff_rr_net    := 0;
     l_round_diff_op_cost   := 0;
     l_round_diff_op_net    := 0;
     l_adjustment_offset_type := null;
     l_path_name  := g_path||'do_cost_revaluation';

      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'In Cost Revaluation');
      -- display the initial state of the asset
      debug_adj_asset( p_asset_iac_adj_info);

      -- set local variables
      l_book_type_code := p_asset_iac_adj_info.book_type_code;
      l_asset_id := p_asset_iac_adj_info.asset_id;
      l_last_period_counter := p_asset_iac_adj_info.last_period_counter;

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
      IF NOT chk_asset_life(p_book_code => l_book_type_code,
                            p_period_counter => l_last_period_counter,
                            p_asset_id => l_asset_id,
                            l_last_period_counter => l_fully_rsvd_pc)
      THEN
          RAISE e_asset_life_err;
      END IF;
      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'Fully reserved period counter: '||l_fully_rsvd_pc);

      IF (l_last_period_counter >= l_fully_rsvd_pc OR p_asset_iac_adj_info.depreciate_flag = 'NO') THEN
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
      -- bug 3391000 start 1
      /*OPEN c_iac_asset_bal(l_asset_id,
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

      -- create a new row in igi_iac_transaction_headers with transaction type code
      -- ADJUSTMENT and transaction sub type as COST
      l_new_adj_id := null;

      IGI_IAC_TRANS_HEADERS_PKG.Insert_Row(
               x_rowid                     => l_rowid,
               x_adjustment_id             => l_new_adj_id, -- out NOCOPY parameter
               x_transaction_header_id     => p_adj_hist.transaction_header_id_in, -- bug 3391000 null,
               x_adjustment_id_out         => null,
               x_transaction_type_code     => 'ADJUSTMENT',
               x_transaction_date_entered  => sysdate,
               x_mass_refrence_id          => null,
               x_transaction_sub_type      => 'COST',
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

      -- Calculate the new revalued FA Cost
      l_iac_new_reval_cost := p_asset_iac_adj_info.cost*(l_iac_asset_bal.cumulative_reval_factor - 1);
      do_round(l_iac_new_reval_cost,l_book_type_code);

      -- round the cost
      l_ret := igi_iac_common_utils.iac_round(l_iac_new_reval_cost,
                                              l_book_type_code) ;
      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'New revalued cost:    '||l_iac_new_reval_cost);

      -- Calculate the difference between the new revalued iac cost and the latest adjusted_cost from
      -- igi_iac_asset_balances
      l_diff_cost := l_iac_new_reval_cost - l_iac_asset_bal.adjusted_cost;
      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'Difference:  '||l_diff_cost);

      -- calculate other asset balance figures
      --01/12/2003, l_iac_new_nbv := l_iac_asset_bal.net_book_value + l_iac_new_reval_cost;

      l_iac_new_nbv := l_iac_new_reval_cost - (l_iac_asset_bal.deprn_reserve + l_iac_asset_bal.backlog_deprn_reserve);

      IF (l_iac_new_reval_cost >= 0) THEN
         l_iac_new_rr := l_iac_asset_bal.reval_reserve + l_diff_cost;
         l_iac_new_op := l_iac_asset_bal.operating_acct;
      ELSE
         l_iac_new_rr := l_iac_asset_bal.reval_reserve;
         l_iac_new_op := l_iac_asset_bal.operating_acct + l_diff_cost;
      END IF;


      -- Prorate this amount for the active distributions in the ratio of the units assigned to them
      IF NOT igi_iac_common_utils.prorate_amt_to_active_dists(l_book_type_code,
                                                              l_asset_id,
                                                              l_diff_cost,
                                                              l_det_table)
      THEN
          RAISE e_no_proration;
      END IF;

      -- create a new row in igi_iac_det_balances for each active distribution where only the cost
      -- will change and the other amounts will be same as those for the previous active adjustment
      FOR l_dist_idx IN l_det_table.FIRST..l_det_table.LAST LOOP

          l_dist_id := l_det_table(l_dist_idx).distribution_id;
          l_add_cost := l_det_table(l_dist_idx).amount;
          l_units_assigned := l_det_table(l_dist_idx).units;

  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => ' Dist ID: '||l_dist_id||' Units:   '||l_units_assigned
				 ||' Additional Cost:   '||l_add_cost);
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

          -- calcluate the new cost

          l_new_dist_cost := l_det_bal.adjustment_cost + l_add_cost;


          -- round the new cost
          l_ret := igi_iac_common_utils.iac_round(l_new_dist_cost,
                                                  l_book_type_code) ;

          l_ret := igi_iac_common_utils.iac_round(l_add_cost,
                                              l_book_type_code) ;


          IF (l_new_dist_cost >= 0) THEN
             l_new_dist_rr_cost := l_new_dist_cost;
             l_new_dist_rr_net := l_det_bal.reval_reserve_net + l_add_cost;
             l_new_dist_op_cost :=0 ;
             l_new_dist_op_net := l_det_bal.operating_acct_net;

          ELSE
             l_new_dist_rr_cost := 0;
             l_new_dist_rr_net := 0;
             l_new_dist_op_cost := l_new_dist_cost;
             l_new_dist_op_net := l_det_bal.operating_acct_net + l_add_cost;

          END IF;

          -- calculate the nbv
          l_new_dist_nbv := l_det_bal.net_book_value + l_add_cost;

          -- round the new cost
          l_ret := igi_iac_common_utils.iac_round(l_new_dist_nbv,
                                                  l_book_type_code) ;
          -- maintain the diff due to rounding
          l_round_diff := l_round_diff + l_new_dist_cost;
          l_round_diff_nbv := l_round_diff_nbv + l_new_dist_nbv;

          IF (l_dist_idx = l_det_table.LAST) THEN
             -- add rounding diff to the last distribution
             l_new_dist_cost := l_new_dist_cost + (l_iac_new_reval_cost - l_round_diff);
             IF l_new_dist_cost >= 0 Then
               l_new_dist_rr_cost := l_new_dist_rr_cost + (l_iac_new_reval_cost - l_round_diff);
               l_new_dist_rr_net := l_new_dist_rr_net + (l_iac_new_reval_cost - l_round_diff);
             Else
              l_new_dist_op_cost := l_new_dist_op_cost + (l_iac_new_reval_cost - l_round_diff);
              l_new_dist_op_net := l_new_dist_op_net + (l_iac_new_reval_cost - l_round_diff);
            End If;

             l_new_dist_nbv  := l_new_dist_nbv + (l_iac_new_nbv - l_round_diff_nbv);
          END IF;

          -- insert the row into igi_iac_det_balances
          IGI_IAC_DET_BALANCES_PKG.Insert_Row(
                     x_rowid                    => l_rowid,
                     x_adjustment_id            => l_new_adj_id,
                     x_asset_id                 => l_asset_id,
                     x_book_type_code           => l_book_type_code,
                     x_distribution_id          => l_dist_id,
                     x_period_counter           => l_last_period_counter,
                     x_adjustment_cost          => l_new_dist_cost,
                     x_net_book_value           => l_new_dist_nbv, --l_det_bal.net_book_value,
                     x_reval_reserve_cost       => l_new_dist_rr_cost, --l_det_bal.reval_reserve_cost,
                     x_reval_reserve_backlog    => l_det_bal.reval_reserve_backlog,
                     x_reval_reserve_gen_fund   => l_det_bal.reval_reserve_gen_fund,
                     x_reval_reserve_net        => l_new_dist_rr_net, --l_det_bal.reval_reserve_net,
                     x_operating_acct_cost      => l_new_dist_op_cost, --l_det_bal.operating_acct_cost,
                     x_operating_acct_backlog   => l_det_bal.operating_acct_backlog,
                     x_operating_acct_net       => l_new_dist_op_net, --l_det_bal.operating_acct_net,
                     x_operating_acct_ytd       => l_det_bal.operating_acct_ytd,
                     x_deprn_period             => l_det_bal.deprn_period,
                     x_deprn_ytd                => l_det_bal.deprn_ytd,
                     x_deprn_reserve            => l_det_bal.deprn_reserve,
                     x_deprn_reserve_backlog    => l_det_bal.deprn_reserve_backlog,
                     x_general_fund_per         => l_det_bal.general_fund_per,
                     x_general_fund_acc         => l_det_bal.general_fund_acc,
                     x_last_reval_date          => l_det_bal.last_reval_date,
                     x_current_reval_factor     => l_det_bal.current_reval_factor,
                     x_cumulative_reval_factor  => l_det_bal.cumulative_reval_factor,
                     x_active_flag              => null,
                     x_mode                     => 'R'
                                                );

         -- create distributions for igi_iac_fa_deprn for the new adjustment_id as well
         OPEN c_get_fa_iac_deprn(l_det_bal.adjustment_id,
                                 l_det_bal.distribution_id);
         FETCH c_get_fa_iac_deprn INTO l_fa_deprn_ytd, l_fa_deprn_period, l_fa_deprn_reserve;
         IF c_get_fa_iac_deprn%NOTFOUND THEN
            -- get the fa figures instead
            FOR l_fa_idx  IN p_asset_iac_dist_info.FIRST.. p_asset_iac_dist_info.LAST LOOP
               IF (p_asset_iac_dist_info(l_fa_idx).distribution_id = l_dist_id) THEN
                  l_fa_deprn_period := p_asset_iac_dist_info(l_fa_idx).deprn_amount;
                  l_fa_deprn_ytd := p_asset_iac_dist_info(l_fa_idx).ytd_deprn;
                  l_fa_deprn_reserve := p_asset_iac_dist_info(l_fa_idx).deprn_reserve;
                  EXIT;
               END IF;
            END LOOP;
         END IF;
         CLOSE c_get_fa_iac_deprn;

         IGI_IAC_FA_DEPRN_PKG.Insert_Row(
                 x_rowid                => l_rowid,
                 x_book_type_code       => l_book_type_code,
                 x_asset_id             => l_asset_id,
                 x_period_counter       => l_last_period_counter,
                 x_adjustment_id        => l_new_adj_id,
                 x_distribution_id      => l_dist_id,
                 x_deprn_period         => l_fa_deprn_period,
                 x_deprn_ytd            => l_fa_deprn_ytd,
                 x_deprn_reserve        => l_fa_deprn_reserve,
                 x_active_flag          => null,
                 x_mode                 => 'R'
                                        );

  	 igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'IAC Deprn row inserted');

         -- Create the following accounting entries with the prorated amounts in IGI_IAC_ADJUSTMENTS

	 -- find the ccid for COST

     If l_add_cost <> 0 Then
       -- get the ccids
         IF NOT igi_iac_common_utils.get_account_ccid(l_book_type_code,
                                                      l_asset_id,
                                                      l_det_bal.distribution_id,
                                                      'ASSET_COST_ACCT',
                                                      l_cost_ccid)
        THEN
           RAISE e_no_ccid_found;
        END IF;

  	 igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'COST ccid:  '||l_cost_ccid||' Flag: '||l_dr_cr_flag_c);

         -- insert into igi_iac_adjustments for REVAL RESERVE or OP EXPENSE
         IF (l_iac_asset_bal.cumulative_reval_factor >= 1 ) THEN
            -- find the ccid for COST
            IF NOT igi_iac_common_utils.get_account_ccid(l_book_type_code,
                                                         l_asset_id,
                                                         l_det_bal.distribution_id,
                                                         'REVAL_RESERVE_ACCT',
                                                         l_reval_rsv_ccid)
            THEN
               RAISE e_no_ccid_found;
            END IF;

	    l_adjustment_offset_type:='REVAL RESERVE';
            l_report_ccid :=l_reval_rsv_ccid;

		-------- REVAL RESERVE A/C Entry-------------

            -- insert into igi_iac_adjustments for REVAL RESERVE
            IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                   x_rowid                    => l_rowid,
                   x_adjustment_id            => l_new_adj_id,
                   x_book_type_code           => l_book_type_code,
                   x_code_combination_id      => l_reval_rsv_ccid,
                   x_set_of_books_id          => l_sob_id,
                   x_dr_cr_flag               => 'CR', -- l_dr_cr_flag_ro,
                   x_amount                   => l_add_cost,
                   x_adjustment_type          => 'REVAL RESERVE',
                   x_transfer_to_gl_flag      => 'Y',
                   x_units_assigned           => l_units_assigned,
                   x_asset_id                 => l_asset_id,
                   x_distribution_id          => l_det_bal.distribution_id,
                   x_period_counter           => l_last_period_counter,
                   x_adjustment_offset_type   => 'COST',
                   x_report_ccid	      => Null,
                   x_mode                     => 'R',
                   x_event_id                 => p_event_id
                                              );

  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'REVAL RESERVE ccid:  '||l_reval_rsv_ccid||' Flag: '||l_dr_cr_flag_ro);
         ELSE

		-------- OP EXPENSE A/C Entry-------------

            -- find the ccid for OP EXPENSE
            IF NOT igi_iac_common_utils.get_account_ccid(l_book_type_code,
                                                         l_asset_id,
                                                         l_det_bal.distribution_id,
                                                         'OPERATING_EXPENSE_ACCT', -- bug 3449361 'OP_EXPENSE_ACCT',
                                                         l_op_exp_ccid)
            THEN
              RAISE e_no_ccid_found;
            END IF;

            l_adjustment_offset_type:='OP EXPENSE';
            l_report_ccid :=l_op_exp_ccid;

            -- insert into igi_iac_adjustments for OP EXPENSE
            IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                   x_rowid                    => l_rowid,
                   x_adjustment_id            => l_new_adj_id,
                   x_book_type_code           => l_book_type_code,
                   x_code_combination_id      => l_op_exp_ccid,
                   x_set_of_books_id          => l_sob_id,
                   x_dr_cr_flag               => 'CR', -- l_dr_cr_flag_ro,
                   x_amount                   => l_add_cost,
                   x_adjustment_type          => 'OP EXPENSE',
                   x_transfer_to_gl_flag      => 'Y',
                   x_units_assigned           => l_units_assigned,
                   x_asset_id                 => l_asset_id,
                   x_distribution_id          => l_det_bal.distribution_id,
                   x_period_counter           => l_last_period_counter,
                   x_adjustment_offset_type   =>'COST',
                   x_report_ccid	      => Null,
                   x_mode                     => 'R',
                   x_event_id                  => p_event_id
                                              );
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'OP EXPENSE ccid:  '||l_op_exp_ccid||' Flag: '||l_dr_cr_flag_ro);
         END IF;

        -- insert into igi_iac_adjustments for COST
        IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
               x_rowid                    => l_rowid,
               x_adjustment_id            => l_new_adj_id,
               x_book_type_code           => l_book_type_code,
               x_code_combination_id      => l_cost_ccid,
               x_set_of_books_id          => l_sob_id,
               x_dr_cr_flag               => 'DR', -- l_dr_cr_flag_c,
               x_amount                   => l_add_cost,
               x_adjustment_type          => 'COST',
               x_transfer_to_gl_flag      => 'Y',
               x_units_assigned           => l_units_assigned,
               x_asset_id                 => l_asset_id,
               x_distribution_id          => l_det_bal.distribution_id,
               x_period_counter           => l_last_period_counter,
               x_adjustment_offset_type	  => l_adjustment_offset_type,
               x_report_ccid		  => l_report_ccid,
               x_mode                     => 'R',
               x_event_id                  => p_event_id
                                          );
       End If;

      END LOOP;

      -- Carry forward any inactive distributions from the previous adjustment to the new adjustment
      Roll_YTD_Forward(l_asset_id,
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
      IF (l_exists > 0) THEN
         IGI_IAC_ASSET_BALANCES_PKG.Update_Row(
                   X_asset_id                => l_asset_id,
                   X_book_type_code          => l_book_type_code,
                   X_period_counter          => l_iac_asset_bal.period_counter,
                   X_net_book_value          => l_iac_new_nbv, --l_iac_asset_bal.net_book_value,
                   X_adjusted_cost           => l_iac_new_reval_cost,
                   X_operating_acct          => l_iac_new_op, --l_iac_asset_bal.operating_acct,
                   X_reval_reserve           => l_iac_new_rr, --l_iac_asset_bal.reval_reserve,
                   X_deprn_amount            => l_iac_asset_bal.deprn_amount,
                   X_deprn_reserve           => l_iac_asset_bal.deprn_reserve,
                   X_backlog_deprn_reserve   => l_iac_asset_bal.backlog_deprn_reserve,
                   X_general_fund            => l_iac_asset_bal.general_fund,
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
                   X_net_book_value          => l_iac_new_nbv, --l_iac_asset_bal.net_book_value,
                   X_adjusted_cost           => l_iac_new_reval_cost,
                   X_operating_acct          => l_iac_new_op, --l_iac_asset_bal.operating_acct,
                   X_reval_reserve           => l_iac_new_rr, --l_iac_asset_bal.reval_reserve,
                   X_deprn_amount            => l_iac_asset_bal.deprn_amount,
                   X_deprn_reserve           => l_iac_asset_bal.deprn_reserve,
                   X_backlog_deprn_reserve   => l_iac_asset_bal.backlog_deprn_reserve,
                   X_general_fund            => l_iac_asset_bal.general_fund,
                   X_last_reval_date         => l_iac_asset_bal.last_reval_date,
                   X_current_reval_factor    => l_iac_asset_bal.current_reval_factor,
                   X_cumulative_reval_factor => l_iac_asset_bal.cumulative_reval_factor
                                              ) ;
      END IF;
      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => ' Success!!!');
      -- return true if process completes successfully
      --rollback;
      RETURN TRUE;
   EXCEPTION
      WHEN e_latest_trx_not_avail THEN
	 fnd_file.put_line(fnd_file.log, 'Latest transaction for the asset could not be retrieved');
  	 igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     p_full_path => l_path_name,
		     p_string => 'Latest transaction for the asset could not be retrieved');
         FA_SRVR_MSG.add_message(
                                 Calling_Fn  => g_calling_fn,
                                 Name        => 'IGI_IAC_NO_LATEST_TRX'
                                );
         RETURN FALSE;

      WHEN e_no_period_info_avail THEN
	 fnd_file.put_line(fnd_file.log, 'No open period information available for the book');
  	 igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     p_full_path => l_path_name,
		     p_string => 'No open period information available for the book');
         FA_SRVR_MSG.add_message(
                                 Calling_Fn  => g_calling_fn,
                                 Name        => 'IGI_IAC_NO_PERIOD_INFO'
                                );
      RETURN FALSE;

      WHEN e_no_gl_info THEN
	 fnd_file.put_line(fnd_file.log, 'Could not retrive GL information for Book');
  	 igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     p_full_path => l_path_name,
		     p_string => 'Could not retrive GL information for Book');
         FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_NO_GL_INFO'
                            );
         RETURN FALSE;

      WHEN e_no_ccid_found THEN
	 fnd_file.put_line(fnd_file.log, 'CCID could not be found');
  	 igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     p_full_path => l_path_name,
		     p_string => 'CCID could not be found');
         FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_WF_FAILED_CCID'
                            );
         RETURN FALSE;

      WHEN e_no_proration THEN
	 fnd_file.put_line(fnd_file.log, 'Amount could not be prorated among the distributions');
  	 igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     p_full_path => l_path_name,
		     p_string => 'Amount could not be prorated among the distributions');
         FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_NO_PRORATION'
                            );
         RETURN FALSE;

      WHEN e_asset_life_err THEN
	 fnd_file.put_line(fnd_file.log, 'Asset life could not be checked');
  	 igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     p_full_path => l_path_name,
		     p_string => 'Asset life could not be checked');
         FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_ASSET_LIFE_ERR'
                            );
         RETURN FALSE;

      WHEN others  THEN
  	 igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
         FA_SRVR_MSG.add_sql_error(Calling_Fn  => g_calling_fn);
         RETURN FALSE;

   END Do_Cost_Revaluation;
BEGIN
   l_calling_function := '***Cost***';
   g_calling_fn  := 'IGI_IAC_ADJ_COST_REVAL_PKG.Do_Cost_Revaluation';
   g_debug_mode  := FALSE;

   --===========================FND_LOG.START=====================================
   g_state_level 	     :=	FND_LOG.LEVEL_STATEMENT;
   g_proc_level  	     :=	FND_LOG.LEVEL_PROCEDURE;
   g_event_level 	     :=	FND_LOG.LEVEL_EVENT;
   g_excep_level 	     :=	FND_LOG.LEVEL_EXCEPTION;
   g_error_level 	     :=	FND_LOG.LEVEL_ERROR;
   g_unexp_level 	     :=	FND_LOG.LEVEL_UNEXPECTED;
   g_path          := 'IGI.PLSQL.igiiadcb.igi_iac_adj_cost_reval_pkg.';
   --===========================FND_LOG.END=====================================


END IGI_IAC_ADJ_COST_REVAL_PKG;


/
