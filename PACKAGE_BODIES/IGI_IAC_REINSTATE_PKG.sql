--------------------------------------------------------
--  DDL for Package Body IGI_IAC_REINSTATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_REINSTATE_PKG" AS
--  $Header: igiiarnb.pls 120.23.12010000.3 2010/06/24 17:32:57 schakkin ship $
-- ===================================================================
-- Global Variables
-- ===================================================================

--===========================FND_LOG.START=====================================

g_state_level NUMBER;
g_proc_level  NUMBER;
g_event_level NUMBER;
g_excep_level NUMBER;
g_error_level NUMBER;
g_unexp_level NUMBER;
g_path        VARCHAR2(100);

--===========================FND_LOG.END=======================================

 g_message     VARCHAR2(200);
 g_calling_fn  VARCHAR2(200);
 g_calling_fn1 VARCHAR2(200);

 g_book_type_code  igi_iac_transaction_headers.book_type_code%TYPE;
 g_asset_id        igi_iac_transaction_headers.asset_id%TYPE;
 g_retirement_id   NUMBER;
 g_adj_prior_ret   igi_iac_transaction_headers.adjustment_id%TYPE;

 -- define asset rec type
 TYPE fa_reins_rec_info IS RECORD (asset_id                 NUMBER,
                                   book_type_code           VARCHAR2(15),
                                   transaction_header_id    NUMBER,
                                   transaction_type_code    VARCHAR2(30),
                                   transaction_date_entered DATE,
                                   date_effective           DATE,
                                   mass_reference_id        NUMBER,
                                   transaction_subtype      VARCHAR2(30),
                                   asset_category_id        NUMBER,
                                   set_of_books_id          NUMBER,
                                   curr_period_counter      NUMBER,
                                   eff_ret_period_counter   NUMBER
                                   );

-- ===================================================================
-- Common Cursors
-- ===================================================================

 -- cursor to see if the asset has been fully reserved
 CURSOR c_fully_reserved(n_asset_id NUMBER,
                         n_book_type_code VARCHAR2)
 IS
 SELECT nvl(period_counter_fully_reserved,0)
 FROM fa_books
 WHERE book_type_code = n_book_type_code
 AND   asset_id = n_asset_id
 AND   date_ineffective IS NULL;

 -- the units_assigned can be obtained from fa_distribution_history
 CURSOR c_fa_units_assigned(n_dist_id NUMBER)
 IS
 SELECT units_assigned
 FROM fa_distribution_history
 WHERE distribution_id = n_dist_id;


 -- retrieve the transaction just prior to the
 -- retirement
 CURSOR c_trx_prev_ret(cp_book_type_code      igi_iac_transaction_headers.book_type_code%TYPE,
                       cp_asset_id            igi_iac_transaction_headers.asset_id%TYPE,
                       cp_trxhdr_id_retire     igi_iac_transaction_headers.transaction_header_id%TYPE)
 IS
 SELECT adjustment_id
 FROM   igi_iac_transaction_headers
 WHERE  book_type_code = cp_book_type_code
 AND    asset_id = cp_asset_id
 AND    adjustment_id_out = (select min(adjustment_id)
                         from igi_iac_transaction_headers
                         where transaction_header_id = cp_trxhdr_id_retire);
 /*CURSOR c_trx_prev_ret(n_trx_id NUMBER)
 IS
 SELECT adjustment_id,
        period_counter
 FROM igi_iac_transaction_headers
 WHERE adjustment_id_out = (SELECT adjustment_id
                            FROM igi_iac_transaction_headers
                            WHERE transaction_header_id = n_trx_id); */

 -- cursor to get the asset balances for the period
 CURSOR c_ret_ass_bal(n_asset_id  NUMBER,
                      n_book_type_code  VARCHAR2,
                      n_period_counter  NUMBER)
 IS
 SELECT iiab.period_counter,
        iiab.net_book_value,
        iiab.adjusted_cost,
        iiab.operating_acct,
        iiab.reval_reserve,
        iiab.deprn_amount,
        iiab.deprn_reserve,
        iiab.backlog_deprn_reserve,
        iiab.general_fund,
        iiab.last_reval_date,
        iiab.current_reval_factor,
        iiab.cumulative_reval_factor
 FROM   igi_iac_asset_balances iiab
 WHERE  iiab.asset_id = n_asset_id
 AND    iiab.book_type_code = n_book_type_code
 AND    iiab.period_counter = n_period_counter;

 -- cursor to get all distribution_ids
 -- from igi_iac_det_balances for an
 -- adjustment_id

 CURSOR c_det_bal(n_adjust_id NUMBER)
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
 WHERE  iidb.adjustment_id = n_adjust_id
 AND    iidb.active_flag IS NULL
 ORDER BY iidb.distribution_id;

 /* Bug 2906934 vgadde 25/04/2003 Start(1) */
 -- Cursor to fetch depreciation balances from
 -- igi_iac_fa_deprn for a adjustment_id and
 -- distribution_id
 CURSOR c_get_fa_deprn(cp_adjustment_id NUMBER,cp_distribution_id NUMBER) IS
 SELECT iifd.deprn_period,
        iifd.deprn_ytd,
        iifd.deprn_reserve
 FROM   igi_iac_fa_deprn iifd
 WHERE  iifd.adjustment_id = cp_adjustment_id
 AND    iifd.distribution_id = cp_distribution_id;

 -- Cursor to fetch depreciation balances from
 -- fa_deprn_detail for a distribution
 CURSOR c_get_fa_det(cp_book_type_code VARCHAR2,
                        cp_asset_id NUMBER,
                        cp_distribution_id NUMBER,
                        cp_period_counter NUMBER)
 IS
 SELECT nvl(deprn_reserve,0) deprn_reserve,
        (nvl(deprn_amount,0) - nvl(deprn_adjustment_amount,0)) deprn_amount
 FROM   fa_deprn_detail
 WHERE  book_type_code = cp_book_type_code
 AND    asset_id = cp_asset_id
 AND    distribution_id = cp_distribution_id
 AND    period_counter = (SELECT    max(period_counter)
                            FROM    fa_deprn_detail
                            WHERE   book_type_code = cp_book_type_code
                            AND     asset_id = cp_asset_id
                            AND     distribution_id = cp_distribution_id
                            AND     period_counter <= cp_period_counter);

 -- cursor to retieve the ytd value for a distribution
 CURSOR c_get_fa_ytd(cp_book_type_code varchar2,
                       cp_asset_id number,
                       cp_distribution_id number)
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
 /* Bug 2906934 vgadde 25/04/2003 End(1) */

 -- cursor to get the YTD rows associated to the
 -- retirement
 CURSOR c_get_ytd(cp_adjustment_id NUMBER,
                    cp_asset_id NUMBER,
                    cp_book_type_code VARCHAR2)
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
 FROM   igi_iac_det_balances iidb,
        fa_distribution_history fdh
 WHERE  iidb.adjustment_id = cp_adjustment_id
 AND    iidb.book_type_code = cp_book_type_code
 AND    iidb.asset_id = cp_asset_id
 AND    fdh.book_type_code = cp_book_type_code
 AND    fdh.asset_id  = cp_asset_id
 AND    iidb.distribution_id = fdh.distribution_id
 AND    fdh.transaction_header_id_out IS NOT NULL;

 -- cursor to retrieve the depreciation expense
 -- for an adjustment id and distribution id
 CURSOR c_deprn_expense(n_adjust_id  NUMBER,
                        n_dist_id    NUMBER)
 IS
 SELECT iidb.deprn_period,
        iidb.deprn_reserve,
        iidb.general_fund_acc,
        iidb.reval_reserve_gen_fund
 FROM   igi_iac_det_balances iidb
 WHERE  iidb.adjustment_id = n_adjust_id
 AND    iidb.distribution_id = n_dist_id;

 -- bug 2480915, start (1)
 -- cursor to retrieve a row from igi_iac_fa_deprn

 CURSOR c_fa_deprn(n_adjust_id NUMBER,
                   n_dist_id   NUMBER,
                   n_prd_cnt   NUMBER)
 IS
 SELECT ifd.book_type_code,
        ifd.asset_id,
        ifd.period_counter,
        ifd.adjustment_id,
        ifd.distribution_id,
        ifd.deprn_period,
        ifd.deprn_ytd,
        ifd.deprn_reserve,
        ifd.active_flag
 FROM  igi_iac_fa_deprn ifd
 WHERE ifd.adjustment_id = n_adjust_id
 AND   ifd.distribution_id = n_dist_id
 AND   ifd.period_counter = n_prd_cnt;

 -- cursor to retieve the ytd figure for a distribution
 CURSOR c_get_dist_ytd(cp_book_type_code varchar2,
                       cp_asset_id number,
                       cp_distribution_id number,
                       cp_period_counter number)
 IS
-- SELECT sum(nvl(fdd.deprn_amount,0)-nvl(fdd.deprn_adjustment_amount,0)) deprn_YTD
 SELECT fdd.ytd_deprn
 FROM fa_deprn_detail fdd
 WHERE fdd.distribution_id = cp_distribution_id
 AND fdd.book_type_code = cp_book_type_code
 AND fdd.asset_id = cp_asset_id
 AND fdd.period_counter = (SELECT period_counter
                            FROM fa_deprn_periods
                            WHERE book_type_code = cp_book_type_code
                            AND period_counter = cp_period_counter
                            AND fiscal_year = (SELECT fiscal_year
                                               FROM fa_deprn_periods
                                               WHERE period_close_date IS NULL
                                               AND book_type_code = cp_book_type_code)) ;
-- GROUP BY fdd.asset_id,fdd.distribution_id;
 -- bug 2480915, end (1)

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
-- ===================================================================
-- Local functions and procedures
-- ===================================================================
-- ===================================================================
-- FUNCTION DoRnding :
--
-- This procedure will round up the different amounts
-- ===================================================================
   FUNCTION DoRnding(x_amount IN NUMBER)
   RETURN number
   IS
     l_ret  BOOLEAN;
     l_amt  NUMBER := 0;

   BEGIN
     l_amt := x_amount;
     l_ret := IGI_IAC_COMMON_UTILS.Iac_Round(l_amt,
                                             g_book_type_code);
     RETURN l_amt;
   END DoRnding;

-- bug 2452521 start(1)
-- ===================================================================
-- FUNCTION is_revalued :

-- This function is part of enhancement requirement bug 2452521 which
-- will stop an asset from being reinstated if it has been revalued
-- even once after it has been retired partially
-- ===================================================================
   FUNCTION is_revalued(x_asset_id       IN NUMBER,
                        x_book_type_code IN VARCHAR2,
                    --    x_ret_trx_hdr_id IN NUMBER,
                        x_eff_ret_period_cnt   IN NUMBER,
                        X_curr_period_cnt      IN NUMBER
                        )
   RETURN boolean
   IS
     l_cnt    NUMBER;
   BEGIN
     SELECT count(*)
     INTO l_cnt
     FROM igi_iac_transaction_headers a1
     WHERE a1.asset_id = x_asset_id
     AND   a1.book_type_code = x_book_type_code
     AND   a1.transaction_type_code = 'REVALUATION'
     AND   a1.adjustment_status NOT IN ('PREVIEW', 'OBSOLETE')
     AND   a1.period_counter BETWEEN x_eff_ret_period_cnt AND x_curr_period_cnt;
   /*  AND   a1.adjustment_id > (SELECT a2.adjustment_id
                               FROM   igi_iac_transaction_headers a2
                               WHERE  a2.transaction_header_id = x_ret_trx_hdr_id
                               AND    a2.transaction_type_code = 'PARTIAL RETIRE'
                               AND    a2.period_counter <= a1.period_counter
                               AND    a2.asset_id = x_asset_id
                               AND    a2.book_type_code = x_book_type_code); */

     IF (l_cnt > 0) THEN
        RETURN TRUE;
     ELSE
        RETURN FALSE;
     END IF;

   END is_revalued;
-- bug 2452521 end(1)


-- ===================================================================
-- FUNCTION elapsed_periods :

-- SHOULD BE DELETED

-- function to calculate the number of periods elapsed between
-- reinstatement and retirement
-- ===================================================================
/* FUNCTION elapsed_periods(x_ret_adj_id   IN NUMBER,
                          x_ren_adj_id   IN NUMBER)
 RETURN number
 IS
    l_ret_prd_counter   NUMBER;
    l_ren_prd_counter   NUMBER;
    l_diff              NUMBER := 0;

    l_path 			 VARCHAR2(150) := g_path||'elapsed_periods';
 BEGIN
   -- get the retirement period counter
   SELECT period_counter
   INTO   l_ret_prd_counter
   FROM   igi_iac_transaction_headers
   WHERE  adjustment_id = x_ret_adj_id;

   -- get the reinstatement period counter
   SELECT period_counter
   INTO   l_ren_prd_counter
   FROM   igi_iac_transaction_headers
   WHERE  adjustment_id = x_ren_adj_id;

   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Reinstate period counter:  '||l_ren_prd_counter);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Retire period counter:  '||l_ret_prd_counter);
   -- elapsed period
   l_diff := l_ren_prd_counter - l_ret_prd_counter;
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Difference:  '||l_diff);

   RETURN l_diff;
 EXCEPTION
    WHEN OTHERS THEN
       igi_iac_debug_pkg.debug_unexpected_msg(l_path);
       RETURN 0;
 END elapsed_periods;
*/
-- =======================================================================
-- FUNCTION Get_Corr_Ren_Dist_id:

-- This function will retrieve the corresponding reinstatement distribution
-- id that is linked
-- to the retired distribution id
-- =======================================================================

 FUNCTION Get_Corr_Ren_Dist_Id(
                               n_trx_hdr_id_in IN NUMBER,
                               n_ret_dist_id   IN NUMBER
                              )
 RETURN NUMBER
 IS

     l_ren_dist_id   NUMBER := 0;
     l_cnt           NUMBER := 0;
     l_path 	     VARCHAR2(150);
 BEGIN
     l_path := g_path||'Get_Corr_Ren_Dist_Id';

 -- initially find out NOCOPY if the distribution has ever
 -- been unit or full retired or never been retired
    SELECT COUNT(*)
    INTO l_cnt
    FROM   fa_distribution_history old,
           fa_distribution_history new
    WHERE  old.location_id = new.location_id
    AND    old.code_combination_id = new.code_combination_id
    AND    NVL(old.assigned_to, -999) = NVL(new.assigned_to, -999)
    AND    old.retirement_id = g_retirement_id
    AND    new.transaction_header_id_in = n_trx_hdr_id_in
    AND    old.distribution_id = n_ret_dist_id;

    IF (l_cnt = 0) THEN
       -- never been retired
       l_ren_dist_id := n_ret_dist_id;
    ELSE
       -- has been retired partially(units) or fully
       SELECT new.distribution_id
       INTO   l_ren_dist_id
       FROM   fa_distribution_history old,
              fa_distribution_history new
       WHERE  old.location_id = new.location_id
       AND    old.code_combination_id = new.code_combination_id
       AND    NVL(old.assigned_to, -999) = NVL(new.assigned_to, -999)
       AND    old.retirement_id = g_retirement_id
       AND    new.transaction_header_id_in = n_trx_hdr_id_in
       AND    old.distribution_id = n_ret_dist_id;
    END IF;
    RETURN l_ren_dist_id;
 EXCEPTION
    WHEN OTHERS THEN
       igi_iac_debug_pkg.debug_unexpected_msg(l_path);
       RETURN 0;
 END Get_Corr_Ren_Dist_Id;

-- =======================================================================
-- FUNCTION Full_Reinstatement :

-- Function to reinstate the asset fully
-- 1. This procedure will retrieve the rows just prior to the full retirement
-- and bring them forward as reinstated with catchup calculated for
-- depreciation reserve and expense. Catchup will be calculated for general
-- fund and reval resrve general fund if the adjustment cost is greater than
-- zero. Catchup for deprn expense
-- will be the whole amount brought forward from the transaction previous
-- to retirement
-- 2. The ytd rows associated with the retirement will be brought forward
-- ========================================================================
  FUNCTION Full_Reinstatement(
                              p_adjust_id_reinstate NUMBER,
                              p_trxhdr_id_retire    NUMBER,
                              p_trxhdr_id_reinstate NUMBER,
                              p_sob_id              NUMBER,
                              p_period_counter      NUMBER,
                              p_effective_retire_period_cnt NUMBER,
                              p_transaction_run   VARCHAR2,
                              p_event_id           NUMBER
                             )
 RETURN BOOLEAN
 IS

 -- local variables
   l_rowid                 ROWID;

   l_prev_adj_id           igi_iac_transaction_headers.adjustment_id%TYPE;
   l_rsv_catchup_amt       igi_iac_det_balances.deprn_period%TYPE;
   l_gf_catchup_amt        igi_iac_det_balances.general_fund_acc%TYPE;

   l_ren_dist_id           igi_iac_transaction_headers.adjustment_id%TYPE;
   l_prorate_factor        NUMBER;
   l_elapsed_periods       NUMBER;

   l_adjustment_cost         NUMBER := 0;
   l_net_book_value          NUMBER := 0;
   l_reval_reserve_cost      NUMBER := 0;
   l_reval_reserve_backlog   NUMBER := 0;
   l_reval_reserve_gen_fund  NUMBER := 0;
   l_reval_reserve_net       NUMBER := 0;
   l_operating_acct_cost     NUMBER := 0;
   l_operating_acct_backlog  NUMBER := 0;
   l_operating_acct_net      NUMBER := 0;
   l_operating_acct_ytd      NUMBER := 0;
   l_deprn_period            NUMBER := 0;
   l_deprn_ytd               NUMBER := 0;
   l_deprn_reserve           NUMBER := 0;
   l_deprn_reserve_backlog   NUMBER := 0;
   l_general_fund_per        NUMBER := 0;
   l_general_fund_acc        NUMBER := 0;

   l_tot_adjustment_cost         NUMBER := 0;
   l_tot_net_book_value          NUMBER := 0;
   l_tot_reval_reserve_cost      NUMBER := 0;
   l_tot_reval_reserve_backlog   NUMBER := 0;
   l_tot_reval_reserve_gen_fund  NUMBER := 0;
   l_tot_reval_reserve_net       NUMBER := 0;
   l_tot_operating_acct_cost     NUMBER := 0;
   l_tot_operating_acct_backlog  NUMBER := 0;
   l_tot_operating_acct_net      NUMBER := 0;
   l_tot_operating_acct_ytd      NUMBER := 0;
   l_tot_deprn_period            NUMBER := 0;
   l_tot_deprn_ytd               NUMBER := 0;
   l_tot_deprn_reserve           NUMBER := 0;
   l_tot_deprn_reserve_backlog   NUMBER := 0;
   l_tot_general_fund_per        NUMBER := 0;
   l_tot_general_fund_acc        NUMBER := 0;

   l_ab_net_book_value           NUMBER := 0;
   l_ab_adjusted_cost            NUMBER := 0;
   l_ab_operating_acct           NUMBER := 0;
   l_ab_reval_reserve            NUMBER := 0;
   l_ab_deprn_amount             NUMBER := 0;
   l_ab_deprn_reserve            NUMBER := 0;
   l_ab_backlog_deprn_reserve    NUMBER := 0;
   l_ab_general_fund             NUMBER := 0;

   l_ccid                        igi_iac_adjustments.code_combination_id%TYPE;
   l_reval_rsv_ccid              igi_iac_adjustments.code_combination_id%TYPE;
   l_exists                      NUMBER;
   l_fully_reserved              NUMBER;

   l_ret_ass_bal           c_ret_ass_bal%ROWTYPE;
   l_units_assigned        fa_distribution_history.units_assigned%TYPE;

   -- bug 2480915 start(1)
   l_fa_deprn_ytd                igi_iac_fa_deprn.deprn_ytd%TYPE;
   l_fa_deprn_period             igi_iac_fa_deprn.deprn_period%TYPE;
   l_fa_deprn_reserve            igi_iac_fa_deprn.deprn_reserve%TYPE;
   -- bug 2480915 end(1)
   l_active_flag                igi_iac_det_balances.active_flag%TYPE;

   -- exceptions
   e_no_corr_reinstatement   EXCEPTION;
   e_no_ccid_found           EXCEPTION;

   l_path 	     	     VARCHAR2(150);
 BEGIN
   l_path := g_path||'Full_Reinstatement';
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'In Full Reinstatements function');
    -- get the adjustment_id of the transaction previous to the
    -- retirement
   -- OPEN c_trx_prev_ret(p_trxhdr_id_retire);
    OPEN c_trx_prev_ret(cp_book_type_code     => g_book_type_code,
                        cp_asset_id           => g_asset_id,
                        cp_trxhdr_id_retire   => p_trxhdr_id_retire);
    FETCH c_trx_prev_ret INTO l_prev_adj_id;
    IF c_trx_prev_ret%NOTFOUND THEN
       CLOSE c_trx_prev_ret;
       RETURN FALSE;
    END IF;

    CLOSE c_trx_prev_ret;

    -- calculate the number of periods that have elapsed between the transaction
    -- previous to the retirement and reinstatement of the asset
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Reinstatement period counter:   '|| p_period_counter);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Retirement period cntr:   '|| p_effective_retire_period_cnt);

  --  l_elapsed_periods := p_period_counter - l_prev_prd_cnt;
    l_elapsed_periods := p_period_counter - p_effective_retire_period_cnt;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Elapsed periods:   '|| l_elapsed_periods);

    -- find out NOCOPY if the asset has been fully reserved prior to retirement
    OPEN c_fully_reserved(g_asset_id, g_book_type_code);
    FETCH c_fully_reserved INTO l_fully_reserved;
    IF c_fully_reserved%NOTFOUND THEN
       CLOSE c_fully_reserved;
       RETURN FALSE;
    END IF;
    CLOSE c_fully_reserved;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Asset fully reserved period counter:   '||l_fully_reserved);

    -- get all the previous balances to reinstate
    FOR l_det_bal IN c_det_bal(l_prev_adj_id) LOOP

        -- initialise to zero for each distribution_id
        l_gf_catchup_amt := 0;
        IF (l_fully_reserved <= 0) THEN
           l_gf_catchup_amt := l_elapsed_periods *l_det_bal.deprn_period;
	   do_round(l_gf_catchup_amt,g_book_type_code);
        ELSE
           l_gf_catchup_amt := 0;
        END IF;

        l_rsv_catchup_amt := 0;
        IF (p_transaction_run = 'SECOND') THEN
            -- calculate the catchup for depreciation reserve
           l_rsv_catchup_amt := l_elapsed_periods *l_det_bal.deprn_period;
	   do_round(l_rsv_catchup_amt,g_book_type_code);
        ELSE
           l_rsv_catchup_amt := 0;
        END IF;

        -- If asset is fully reserved then catchup is 0
        IF (l_fully_reserved > 0) THEN
           l_rsv_catchup_amt := 0;
        END IF;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Depreciation expense:  '||l_det_bal.deprn_period);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Depreciation reserve:  '||l_rsv_catchup_amt);
        -- get the link between the reinstated distribution_ids to the
        -- retired distribution id
         l_ren_dist_id := Get_Corr_Ren_Dist_Id(
                                               p_trxhdr_id_reinstate,
                                               l_det_bal.distribution_id  -- retirement
                                              );

         IF (l_ren_dist_id = 0) THEN
            RAISE e_no_corr_reinstatement;
         END IF;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Reinstatement dist id:   '||l_ren_dist_id);


        -- from this the units_assigned can be obtained from fa_distribution_history
        SELECT units_assigned
        INTO l_units_assigned
        FROM fa_distribution_history
        WHERE distribution_id = l_ren_dist_id;

       -- get account values
       l_adjustment_cost        := l_det_bal.adjustment_cost;
       l_reval_reserve_cost     := l_det_bal.reval_reserve_cost;
       l_reval_reserve_backlog  := l_det_bal.reval_reserve_backlog;
       l_operating_acct_cost    := l_det_bal.operating_acct_cost;
       l_operating_acct_backlog := l_det_bal.operating_acct_backlog;
       l_operating_acct_ytd     := l_det_bal.operating_acct_ytd;
       l_deprn_period           := l_det_bal.deprn_period;
       l_deprn_reserve_backlog  := l_det_bal.deprn_reserve_backlog;

       l_deprn_ytd           := l_det_bal.deprn_ytd +l_rsv_catchup_amt;
       l_deprn_reserve       := l_det_bal.deprn_reserve + l_rsv_catchup_amt;
       IF (l_det_bal.adjustment_cost > 0) THEN
          l_general_fund_per       := l_deprn_period;
          l_general_fund_acc       := l_det_bal.general_fund_acc + l_gf_catchup_amt;
          l_reval_reserve_gen_fund := l_general_fund_acc;
          l_reval_reserve_net      := l_reval_reserve_cost - ( l_reval_reserve_backlog + l_reval_reserve_gen_fund);
       ELSE
          l_general_fund_per       := l_det_bal.general_fund_per;
          l_general_fund_acc       := l_det_bal.general_fund_acc;
          l_reval_reserve_gen_fund := l_det_bal.reval_reserve_gen_fund;
          l_reval_reserve_net      := l_det_bal.reval_reserve_net;
       END IF;

       l_operating_acct_net     := l_operating_acct_cost - l_operating_acct_backlog;
       l_net_book_value         := l_adjustment_cost - (l_deprn_reserve + l_deprn_reserve_backlog);

       -- bug 2480915 start(5) Modified for bug 2906034
       -- get the deprn values from igi_iac_fa_deprn or fa_deprn_detail
        OPEN c_get_fa_deprn(l_prev_adj_id, l_det_bal.distribution_id);
        FETCH c_get_fa_deprn INTO l_fa_deprn_period, l_fa_deprn_ytd, l_fa_deprn_reserve;
        IF c_get_fa_deprn%NOTFOUND THEN
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Record not found in igi_iac_fa_deprn');
            OPEN c_get_fa_det(g_book_type_code,
                                g_asset_id,
                                l_det_bal.distribution_id,
                                l_det_bal.period_counter);
            FETCH c_get_fa_det INTO l_fa_deprn_period, l_fa_deprn_reserve;
            CLOSE c_get_fa_det;

            OPEN c_get_fa_ytd(g_book_type_code,
                                g_asset_id,
                                l_det_bal.distribution_id);
            FETCH c_get_fa_ytd INTO l_fa_deprn_ytd;
            IF c_get_fa_ytd%NOTFOUND THEN
                l_fa_deprn_ytd := 0;
            END IF;
            CLOSE c_get_fa_ytd;
        ELSE
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Record found in igi_iac_fa_deprn');
            IF l_fully_reserved > 0 THEN
                l_fa_deprn_period := 0;
            END IF;
            IF (p_transaction_run = 'SECOND') THEN
               l_fa_deprn_ytd := l_fa_deprn_ytd + (l_elapsed_periods*l_fa_deprn_period);
	       do_round(l_fa_deprn_ytd,g_book_type_code);
               l_fa_deprn_reserve := l_fa_deprn_reserve + (l_elapsed_periods*l_fa_deprn_period);
	       do_round(l_fa_deprn_reserve,g_book_type_code);
            END IF;
        END IF;
        CLOSE c_get_fa_deprn;

       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'FA Depreciation amount:  '||l_fa_deprn_period);
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Detail level FA deprn rsv:   '||l_fa_deprn_reserve);
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Detail level FA deprn YTD:   '||l_fa_deprn_ytd);
       -- bug 2480915 end(5) modified for bug 2906034

       -- keep a running total of the different account amounts after they have
       -- been prorated
       l_tot_adjustment_cost         := l_tot_adjustment_cost + l_adjustment_cost;
       l_tot_net_book_value          := l_tot_net_book_value + l_net_book_value;
       l_tot_reval_reserve_cost      := l_tot_reval_reserve_cost + l_reval_reserve_cost;
       l_tot_reval_reserve_backlog   := l_tot_reval_reserve_backlog + l_reval_reserve_backlog;
       l_tot_reval_reserve_gen_fund  := l_tot_reval_reserve_gen_fund + l_reval_reserve_gen_fund;
       l_tot_reval_reserve_net       := l_tot_reval_reserve_net + l_reval_reserve_net;
       l_tot_operating_acct_cost     := l_tot_operating_acct_cost + l_operating_acct_cost;
       l_tot_operating_acct_backlog  := l_tot_operating_acct_backlog + l_operating_acct_backlog;
       l_tot_operating_acct_net      := l_tot_operating_acct_net + l_operating_acct_net;
       l_tot_operating_acct_ytd      := l_tot_operating_acct_ytd + l_operating_acct_ytd;
       l_tot_deprn_period            := l_tot_deprn_period + l_deprn_period;
       l_tot_deprn_ytd               := l_tot_deprn_ytd + l_deprn_ytd;
       l_tot_deprn_reserve           := l_tot_deprn_reserve + l_deprn_reserve;
       l_tot_deprn_reserve_backlog   := l_tot_deprn_reserve_backlog + l_deprn_reserve_backlog;
       l_tot_general_fund_per        := l_tot_general_fund_per + l_general_fund_per;
       l_tot_general_fund_acc        := l_tot_general_fund_acc + l_general_fund_acc;

        -- insert into igi_iac_det_balances with reinstatement adjustment_id
        IGI_IAC_DET_BALANCES_PKG.Insert_Row(
                     x_rowid                    => l_rowid,
                     x_adjustment_id            => p_adjust_id_reinstate,
                     x_asset_id                 => g_asset_id,
                     x_book_type_code           => g_book_type_code,
                     x_distribution_id          => l_ren_dist_id,
                     x_period_counter           => p_period_counter,
                     x_adjustment_cost          => l_adjustment_cost,
                     x_net_book_value           => l_net_book_value,
                     x_reval_reserve_cost       => l_reval_reserve_cost,
                     x_reval_reserve_backlog    => l_reval_reserve_backlog,
                     x_reval_reserve_gen_fund   => l_reval_reserve_gen_fund,
                     x_reval_reserve_net        => l_reval_reserve_net,
                     x_operating_acct_cost      => l_operating_acct_cost,
                     x_operating_acct_backlog   => l_operating_acct_backlog,
                     x_operating_acct_net       => l_operating_acct_net,
                     x_operating_acct_ytd       => l_operating_acct_ytd,
                     x_deprn_period             => l_deprn_period,
                     x_deprn_ytd                => l_deprn_ytd,
                     x_deprn_reserve            => l_deprn_reserve,
                     x_deprn_reserve_backlog    => l_deprn_reserve_backlog,
                     x_general_fund_per         => l_general_fund_per,
                     x_general_fund_acc         => l_general_fund_acc,
                     x_last_reval_date          => l_det_bal.last_reval_date,
                     x_current_reval_factor     => l_det_bal.current_reval_factor,
                     x_cumulative_reval_factor  => l_det_bal.cumulative_reval_factor,
                     x_active_flag              => null,
                     x_mode                     => 'R'
                                                );

       -- Bug 2480915, start(6)
       -- insert into igi_iac_fa_deprn with the reinstatement adjustment_id
       IGI_IAC_FA_DEPRN_PKG.Insert_Row(
               x_rowid                => l_rowid,
               x_book_type_code       => g_book_type_code,
               x_asset_id             => g_asset_id,
               x_period_counter       => p_period_counter,
               x_adjustment_id        => p_adjust_id_reinstate,
               x_distribution_id      => l_ren_dist_id,
               x_deprn_period         => l_fa_deprn_period,
               x_deprn_ytd            => l_fa_deprn_ytd,
               x_deprn_reserve        => l_fa_deprn_reserve,
               x_active_flag          => null,
               x_mode                 => 'R'
                                      );
       -- Bug 2480915, end(6)

       -- do the adjustment catchup journals here, insert only if the catchup amount
       -- is greater than zero and is the second Depreciation transaction
       IF (p_transaction_run = 'SECOND') THEN
          IF (l_elapsed_periods > 0) THEN
              -- get the ccid for the account type Depreciation Expense
              IF NOT igi_iac_common_utils.get_account_ccid(g_book_type_code,
                                                           g_asset_id,
                                                           l_det_bal.distribution_id,
                                                           'DEPRN_EXPENSE_ACCT',
                                                           p_trxhdr_id_reinstate,
                                                           'RETIREMENT',
                                                           l_ccid)
              THEN
                 --RETURN false;
                 g_message := 'No account code combination found for Depreciation Expense';
                 RAISE e_no_ccid_found;
              END IF;
              -- insert into igi_iac_adjustments
              IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                     x_rowid                    => l_rowid,
                     x_adjustment_id            => p_adjust_id_reinstate,
                     x_book_type_code           => g_book_type_code,
                     x_code_combination_id      => l_ccid,
                     x_set_of_books_id          => p_sob_id,
                     x_dr_cr_flag               => 'DR',
                     x_amount                   => l_rsv_catchup_Amt, -- l_deprn_period,
                     x_adjustment_type          => 'EXPENSE',
                     x_adjustment_offset_type   => 'RESERVE',
                     x_report_ccid              => Null,
                     x_transfer_to_gl_flag      => 'Y',
                     x_units_assigned           => l_units_assigned,
                     x_asset_id                 => g_asset_id,
                     x_distribution_id          => l_ren_dist_id,
                     x_period_counter           => p_period_counter,
                     x_mode                     => 'R',
                     x_event_id                 => p_event_id );
              igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Done Expense:   '||l_rsv_catchup_amt);
              -- insert RESERVE journal into igi_iac_adjustments with the reserve catchup amount
              -- get the ccid for the account type
              IF NOT igi_iac_common_utils.get_account_ccid(g_book_type_code,
                                                           g_asset_id,
                                                           l_ren_dist_id,
                                                           'DEPRN_RESERVE_ACCT',
                                                           p_trxhdr_id_reinstate,
                                                           'RETIREMENT',
                                                           l_ccid)
              THEN
                  --RETURN false;
                  g_message := 'No account code combination found for Accumulated Depreciation';
                  RAISE e_no_ccid_found;
              END IF;
              -- insert into igi_iac_adjustments
              IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                     x_rowid                    => l_rowid,
                     x_adjustment_id            => p_adjust_id_reinstate,
                     x_book_type_code           => g_book_type_code,
                     x_code_combination_id      => l_ccid,
                     x_set_of_books_id          => p_sob_id,
                     x_dr_cr_flag               => 'CR',
                     x_amount                   => l_rsv_catchup_amt,
                     x_adjustment_type          => 'RESERVE',
                     x_adjustment_offset_type   => 'EXPENSE',
                     x_report_ccid              => Null,
                     x_transfer_to_gl_flag      => 'Y',
                     x_units_assigned           => l_units_assigned,
                     x_asset_id                 => g_asset_id,
                     x_distribution_id          => l_ren_dist_id,
                     x_period_counter           => p_period_counter,
                     x_mode                     => 'R',
                     x_event_id                 => p_event_id );
              igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Done Deprn Reserve:   '||l_rsv_catchup_amt);
              -- insert GENERAL FUND journal into igi_iac_adjustments with the catchup amount
              -- only if adjustment amount is greater than zero
              IF (l_det_bal.adjustment_cost > 0) THEN
                  -- get the ccid for the account type Reval Reserve
                  IF NOT igi_iac_common_utils.get_account_ccid(g_book_type_code,
                                                               g_asset_id,
                                                               l_ren_dist_id,
                                                               'REVAL_RESERVE_ACCT',
                                                               p_trxhdr_id_reinstate,
                                                               'RETIREMENT',
                                                               l_ccid)
                  THEN
                      --RETURN false;
                      g_message := 'No account code combination found for Revaluation Reserve';
                      RAISE e_no_ccid_found;
                  END IF;

                  l_reval_rsv_ccid := l_ccid;

                  -- insert into igi_iac_adjustments
                  IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                         x_rowid                    => l_rowid,
                         x_adjustment_id            => p_adjust_id_reinstate,
                         x_book_type_code           => g_book_type_code,
                         x_code_combination_id      => l_ccid,
                         x_set_of_books_id          => p_sob_id,
                         x_dr_cr_flag               => 'DR',
                         x_amount                   => l_rsv_catchup_Amt, --l_gf_catchup_amt,
                         x_adjustment_type          => 'REVAL RESERVE',
                         x_adjustment_offset_type   => 'GENERAL FUND',
                         x_report_ccid              => Null,
                         x_transfer_to_gl_flag      => 'Y',
                         x_units_assigned           => l_units_assigned,
                         x_asset_id                 => g_asset_id,
                         x_distribution_id          => l_ren_dist_id,
                         x_period_counter           => p_period_counter,
                         x_mode                     => 'R',
                         x_event_id                 => p_event_id );

                  -- get the ccid for the account type General Fund
                  IF NOT igi_iac_common_utils.get_account_ccid(g_book_type_code,
                                                               g_asset_id,
                                                               l_ren_dist_id,
                                                               'GENERAL_FUND_ACCT',
                                                               p_trxhdr_id_reinstate,
                                                               'RETIREMENT',
                                                               l_ccid)
                  THEN
                      --RETURN false;
                      g_message := 'No account code combination found for General Fund';
                      RAISE e_no_ccid_found;
                  END IF;
                  -- insert into igi_iac_adjustments
                  IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                          x_rowid                    => l_rowid,
                          x_adjustment_id            => p_adjust_id_reinstate,
                          x_book_type_code           => g_book_type_code,
                          x_code_combination_id      => l_ccid,
                          x_set_of_books_id          => p_sob_id,
                          x_dr_cr_flag               => 'CR',
                          x_amount                   => l_rsv_catchup_Amt, --l_gf_catchup_amt,
                          x_adjustment_type          => 'GENERAL FUND',
                          x_adjustment_offset_type   => 'REVAL RESERVE',
                          x_report_ccid              => l_reval_rsv_ccid,
                          x_transfer_to_gl_flag      => 'Y',
                          x_units_assigned           => l_units_assigned,
                          x_asset_id                 => g_asset_id,
                          x_distribution_id          => l_ren_dist_id,
                          x_period_counter           => p_period_counter,
                          x_mode                     => 'R',
                          x_event_id                 => p_event_id
                                                );
               END IF; -- adjustment cost > 0
           END IF; -- elapsed periods > 0
        END IF; -- second transaction
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'End for distribution:  '||l_det_bal.distribution_id);
    END LOOP;

    -- bring the YTD rows associated to the retirement over with the
    -- reinstatement adjustment id and current period counter
    FOR l_get_ytd IN c_get_ytd(cp_adjustment_id => l_prev_adj_id,
                                cp_asset_id     => g_asset_id,
                                cp_book_type_code => g_book_type_code) LOOP
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'In YTD:  dist id:   '||l_get_ytd.distribution_id);

        IF nvl(l_get_ytd.active_flag,'Y') = 'Y' THEN
            l_get_ytd.adjustment_cost := 0;
            l_get_ytd.net_book_value := 0;
            l_get_ytd.reval_reserve_cost := 0;
            l_get_ytd.reval_reserve_backlog := 0;
            l_get_ytd.reval_reserve_gen_fund := 0;
            l_get_ytd.reval_reserve_net := 0;
            l_get_ytd.operating_acct_cost := 0;
            l_get_ytd.operating_acct_backlog := 0;
            l_get_ytd.operating_acct_net := 0;
            l_get_ytd.operating_acct_ytd := 0;
            l_get_ytd.deprn_period := 0;
            l_get_ytd.deprn_ytd := 0;
            l_get_ytd.deprn_reserve := 0;
            l_get_ytd.deprn_reserve_backlog := 0;
            l_get_ytd.general_fund_per := 0;
            l_get_ytd.general_fund_acc := 0;
        END IF;
        l_active_flag := 'N';

        -- insert into igi_iac_det_balances with reinstatement adjustment_id
        IGI_IAC_DET_BALANCES_PKG.Insert_Row(
                     x_rowid                    => l_rowid,
                     x_adjustment_id            => p_adjust_id_reinstate,
                     x_asset_id                 => g_asset_id,
                     x_book_type_code           => g_book_type_code,
                     x_distribution_id          => l_get_ytd.distribution_id,
                     x_period_counter           => p_period_counter,
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
                     x_active_flag              => l_active_flag
                                                );

       -- Bug 2480915, start(7) Modified for 2906034
       OPEN c_get_fa_deprn(l_get_ytd.adjustment_id, l_get_ytd.distribution_id);
       FETCH c_get_fa_deprn INTO l_fa_deprn_period, l_fa_deprn_ytd, l_fa_deprn_reserve;
       IF c_get_fa_deprn%NOTFOUND THEN
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Record not found in igi_iac_fa_deprn');
            OPEN c_get_fa_ytd(g_book_type_code,
                                g_asset_id,
                                l_get_ytd.distribution_id);
            FETCH c_get_fa_ytd INTO l_fa_deprn_ytd;
            IF c_get_fa_ytd%NOTFOUND THEN
                l_fa_deprn_ytd := 0;
            END IF;
            CLOSE c_get_fa_ytd;
       END IF;
       CLOSE c_get_fa_deprn;
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'In YTD:  YTD deprn: '||l_fa_deprn_ytd);

        IF nvl(l_get_ytd.active_flag,'Y') = 'Y' THEN
            l_fa_deprn_ytd := 0;
        END IF;
       -- insert into igi_iac_fa_deprn with the reinstatement adjustment_id
       IGI_IAC_FA_DEPRN_PKG.Insert_Row(
               x_rowid                => l_rowid,
               x_book_type_code       => g_book_type_code,
               x_asset_id             => g_asset_id,
               x_period_counter       => p_period_counter,
               x_adjustment_id        => p_adjust_id_reinstate,
               x_distribution_id      => l_get_ytd.distribution_id,
               x_deprn_period         => 0,
               x_deprn_ytd            => l_fa_deprn_ytd,
               x_deprn_reserve        => 0,
               x_active_flag          => 'N',
               x_mode                 => 'R'
                                      );
       -- Bug 2480915, end(7) Modified for 2906034
    END LOOP;

    -- update the asset balances table for the asset to reflect the full reinstatement
    -- if a row exists for the asset for the current period else create a new row
    SELECT count(*)
    INTO l_exists
    FROM igi_iac_asset_balances
    WHERE asset_id = g_asset_id
    AND   book_type_code = g_book_type_code
    AND   period_counter = p_period_counter;

    -- fetch asset balances for the period prior to retirement
    OPEN c_ret_ass_bal(g_Asset_id,
                       g_book_type_code,
                       p_effective_retire_period_cnt --l_prev_prd_cnt
                      );
    FETCH c_ret_ass_bal INTO l_ret_ass_bal;
    IF c_ret_ass_bal%NOTFOUND THEN
       CLOSE c_ret_ass_bal;
       RETURN FALSE;
    END IF;
    CLOSE c_ret_ass_bal;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Retrieved the asset balance');

    -- update the existing asset balances record
    l_ab_net_book_value        := l_tot_net_book_value;
    l_ab_adjusted_cost         := l_tot_adjustment_cost;
    l_ab_operating_acct        := l_tot_operating_acct_net;
    l_ab_reval_reserve         := l_tot_reval_reserve_net;
    l_ab_deprn_amount          := l_tot_deprn_period;
    l_ab_deprn_reserve         := l_tot_deprn_reserve;
    l_ab_backlog_deprn_reserve := l_tot_deprn_reserve_backlog;
    l_ab_general_fund          := l_tot_general_fund_acc;

    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'NBV:    '||l_ab_net_book_value);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Adjusted Cost:    '||l_ab_adjusted_cost);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Operating acct:    '||l_ab_operating_acct);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Reval Reserve:    '||l_ab_reval_reserve);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Deprn Amount/Expense:    '||l_ab_deprn_amount);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Deprn Reserve:    '||l_ab_deprn_reserve);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Blog deprn reserve:    '||l_ab_backlog_deprn_reserve);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Gen Fund:    '||l_ab_general_fund);

    IF (l_exists > 0) THEN
       -- update the existing asset balances record
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Updating asset balances');
       IGI_IAC_ASSET_BALANCES_PKG.Update_Row(
                  X_asset_id                => g_asset_id,
                  X_book_type_code          => g_book_type_code,
                  X_period_counter          => p_period_counter,
                  X_net_book_value          => l_ab_net_book_value,
                  X_adjusted_cost           => l_ab_adjusted_cost,
                  X_operating_acct          => l_ab_operating_acct,
                  X_reval_reserve           => l_ab_reval_reserve,
                  X_deprn_amount            => l_ab_deprn_amount,
                  X_deprn_reserve           => l_ab_deprn_reserve,
                  X_backlog_deprn_reserve   => l_ab_backlog_deprn_reserve,
                  X_general_fund            => l_ab_general_fund,
                  X_last_reval_date         => l_ret_ass_bal.last_reval_date,
                  X_current_reval_factor    => l_ret_ass_bal.current_reval_factor,
                  X_cumulative_reval_factor => l_ret_ass_bal.cumulative_reval_factor
                                         ) ;

    ELSE
        -- insert a new record for the reinstatement period by bringing forward the record previous to the
        -- retired with catchup values adjusted for account type RESERVE and GENERAL FUND
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Inserting into asset balances');
        IGI_IAC_ASSET_BALANCES_PKG.Insert_Row(
                   X_rowid                   => l_rowid,
                   X_asset_id                => g_asset_id,
                   X_book_type_code          => g_book_type_code,
                   X_period_counter          => p_period_counter,
                   X_net_book_value          => l_ab_net_book_value,
                   X_adjusted_cost           => l_ab_adjusted_cost,
                   X_operating_acct          => l_ab_operating_acct,
                   X_reval_reserve           => l_ab_reval_reserve,
                   X_deprn_amount            => l_ab_deprn_amount,
                   X_deprn_reserve           => l_ab_deprn_reserve,
                   X_backlog_deprn_reserve   => l_ab_backlog_deprn_reserve,
                   X_general_fund            => l_ab_general_fund,
                   X_last_reval_date         => l_ret_ass_bal.last_reval_date,
                   X_current_reval_factor    => l_ret_ass_bal.current_reval_factor,
                   X_cumulative_reval_factor => l_ret_ass_bal.cumulative_reval_factor
                                             ) ;
    END IF;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Finished reinstating asset balances fully');
 RETURN TRUE;
 EXCEPTION
     WHEN e_no_corr_reinstatement THEN
         IF c_get_ytd%ISOPEN THEN
            CLOSE c_get_ytd;
         END IF;
         g_message := 'No corresponding reinstatement found for the retirement distribution';
         igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,g_message);
         FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_NO_CORR_REIN_DIST_ID'
                            );
         RETURN FALSE;

     WHEN e_no_ccid_found THEN
         IF c_get_ytd%ISOPEN THEN
            CLOSE c_get_ytd;
         END IF;

         igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,g_message);
         FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_WF_FAILED_CCID'
                            );
         RETURN FALSE;

     WHEN others THEN
         IF c_get_ytd%ISOPEN THEN
            CLOSE c_get_ytd;
         END IF;
         g_message := 'Error:'||SQLERRM;
	     igi_iac_debug_pkg.debug_unexpected_msg(l_path);
         g_calling_fn1 := g_calling_fn||' : Full';
         FA_SRVR_MSG.add_sql_error(
                Calling_Fn  => g_calling_fn1
                            );
         RETURN FALSE;
 END Full_Reinstatement;

-- ===============================================================================
-- FUNCTION Cost Reinstatement :

-- Function to reinstate the asset partially based on Cost
-- 1. This procedure will retrieve the rows just prior to the partial retirement
-- and bring them forward as reinstated with catchup calculated for
-- depreciation reserve and expense.
-- 2. The catchup amount for the catchup journals will be calculated as the difference
-- between the reinstated amount and the latest amount
-- 2. The ytd rows associated with the retirement will be brought forward
-- ===============================================================================
FUNCTION Cost_Reinstatement(
                              p_adjust_id_reinstate NUMBER,
                              p_adjust_id_retire    NUMBER,
                              p_trxhdr_id_retire    NUMBER,
                              p_trxhdr_id_reinstate NUMBER,
                              p_latest_adjust_id    NUMBER,
                              p_sob_id              NUMBER,
                              p_period_counter      NUMBER,
                              p_retirement_type     VARCHAR2,
                              p_effective_retire_period_cnt   NUMBER,
                              p_transaction_run   VARCHAR2,
                              p_event_id          NUMBER
                             )
RETURN BOOLEAN
 IS


 -- local variables
   l_rowid                 ROWID;

   l_path 	     	     VARCHAR2(150);

   l_prev_adj_id           NUMBER;
   l_rsv_catchup_amt       NUMBER := 0;
   l_gf_catchup_amt        NUMBER := 0;

   l_prorate_factor        NUMBER := 0;
 --  l_prev_prd_cnt          NUMBER;
   l_de_catchup            NUMBER;
   l_rsv_catchup           NUMBER;
   l_latest_dep_exp        NUMBER;
   l_latest_dep_rsv        NUMBER;
   l_latest_gen_fund       NUMBER;
   l_latest_rev_rsv        NUMBER;

   l_ccid                  igi_iac_adjustments.code_combination_id%TYPE;
   l_reval_rsv_ccid        igi_iac_adjustments.code_combination_id%TYPE;
   l_elapsed_periods       NUMBER;

   l_exists                NUMBER;
   l_ret_ass_bal           c_ret_ass_bal%ROWTYPE;

   l_adjustment_cost         NUMBER;
   l_net_book_value          NUMBER;
   l_reval_reserve_cost      NUMBER;
   l_reval_reserve_backlog   NUMBER;
   l_reval_reserve_gen_fund  NUMBER;
   l_reval_reserve_net       NUMBER;
   l_operating_acct_cost     NUMBER;
   l_operating_acct_backlog  NUMBER;
   l_operating_acct_net      NUMBER;
   l_operating_acct_ytd      NUMBER;
   l_deprn_period            NUMBER;
   l_deprn_ytd               NUMBER;
   l_deprn_reserve           NUMBER;
   l_deprn_reserve_backlog   NUMBER;
   l_general_fund_per        NUMBER;
   l_general_fund_acc        NUMBER;

   l_tot_adjustment_cost         NUMBER := 0;
   l_tot_net_book_value          NUMBER := 0;
   l_tot_reval_reserve_cost      NUMBER := 0;
   l_tot_reval_reserve_backlog   NUMBER := 0;
   l_tot_reval_reserve_gen_fund  NUMBER := 0;
   l_tot_reval_reserve_net       NUMBER := 0;
   l_tot_operating_acct_cost     NUMBER := 0;
   l_tot_operating_acct_backlog  NUMBER := 0;
   l_tot_operating_acct_net      NUMBER := 0;
   l_tot_operating_acct_ytd      NUMBER := 0;
   l_tot_deprn_period            NUMBER := 0;
   l_tot_deprn_ytd               NUMBER := 0;
   l_tot_deprn_reserve           NUMBER := 0;
   l_tot_deprn_reserve_backlog   NUMBER := 0;
   l_tot_general_fund_per        NUMBER := 0;
   l_tot_general_fund_acc        NUMBER := 0;

   l_ab_net_book_value           NUMBER;
   l_ab_adjusted_cost            NUMBER;
   l_ab_operating_acct           NUMBER;
   l_ab_reval_reserve            NUMBER;
   l_ab_deprn_amount             NUMBER;
   l_ab_deprn_reserve            NUMBER;
   l_ab_backlog_deprn_reserve    NUMBER;
   l_ab_general_fund             NUMBER;

   l_units_assigned              fa_distribution_history.units_assigned%TYPE;
   l_fully_reserved              NUMBER;

   -- bug 2480915 start(8)
   l_fa_deprn_ytd                igi_iac_fa_deprn.deprn_ytd%TYPE;
   l_fa_deprn_period             igi_iac_fa_deprn.deprn_period%TYPE;
   l_fa_deprn_reserve            igi_iac_fa_deprn.deprn_reserve%TYPE;
   -- bug 2480915 end(8)
    l_ret                          boolean;
   -- exceptions
   e_no_ccid_found           EXCEPTION;
   e_no_cost_prorate         EXCEPTION;
 BEGIN
    l_path := g_path||'Cost_Reinstatement';

    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'In reinstatement cost');
    -- get the adjustment id  and period counter for the transaction previous to retirement
    -- OPEN c_trx_prev_ret(p_trxhdr_id_retire);
    OPEN c_trx_prev_ret(cp_book_type_code     => g_book_type_code,
                        cp_asset_id           => g_asset_id,
                        cp_trxhdr_id_retire   => p_trxhdr_id_retire);
    FETCH c_trx_prev_ret INTO l_prev_adj_id;
    IF c_trx_prev_ret%NOTFOUND THEN
       CLOSE c_trx_prev_ret;
       RETURN FALSE;
    END IF;
    CLOSE c_trx_prev_ret;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Adjustment id previous to retirement:   '||l_prev_adj_id);

    -- get the cost retirement factor
    IF NOT igi_iac_common_utils.get_cost_retirement_factor(g_book_type_code,
                                                           g_asset_id,
                                                           g_retirement_id,
                                                           l_prorate_factor)
    THEN
        RAISE e_no_cost_prorate;
    END IF;
    -- calculate the reinstatement prorate factor from the retirement
    -- prorate factor
    --l_prorate_factor := 1/(1 - l_prorate_factor);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Cost prorate factor:  '||l_prorate_factor);

    -- calculate the number of periods that have elapsed between the transaction
    -- previous to the retirement and reinstatement of the asset
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Reinstatement period counter:   '|| p_period_counter);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Retirement period cntr:   '|| p_effective_retire_period_cnt);
 --   l_elapsed_periods := p_period_counter - l_prev_prd_cnt;
    l_elapsed_periods := p_period_counter - p_effective_retire_period_cnt;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Elapsed periods:   '|| l_elapsed_periods);

    -- find out NOCOPY if the asset has been fully reserved prior to retirement
    OPEN c_fully_reserved(g_asset_id, g_book_type_code);
    FETCH c_fully_reserved INTO l_fully_reserved;
    IF c_fully_reserved%NOTFOUND THEN
       CLOSE c_fully_reserved;
       RETURN FALSE;
    END IF;
    CLOSE c_fully_reserved;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Asset fully reserved period counter:   '||l_fully_reserved);

    -- get all the previous balances to reinstate
    FOR l_det_bal IN c_det_bal(l_prev_adj_id) LOOP
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'getting all previous row for reinstatement');
       -- calculate catchup amount if second transaction
       -- initialise to zero for each distribution_id
       l_rsv_catchup_amt := 0;
       l_gf_catchup_amt := 0;
       l_general_fund_acc:=0;

      IF (l_fully_reserved <= 0) THEN
           If l_det_bal.adjustment_cost >= 0 THEN
                l_gf_catchup_amt := l_det_bal.general_fund_acc  + (l_elapsed_periods * l_det_bal.deprn_period * l_prorate_factor);
		do_round(l_gf_catchup_amt,g_book_type_code);
		l_ret:= igi_iac_common_utils.iac_round(l_gf_catchup_amt,g_book_type_code) ;
                l_general_fund_acc := l_gf_catchup_amt;
           END IF;
       ELSE
           l_gf_catchup_amt := 0;
       END IF;

       IF (p_transaction_run = 'SECOND') THEN
            -- calculate the catchup for depreciation reserve
           l_rsv_catchup_amt := l_elapsed_periods * l_det_bal.deprn_period;
	   do_round(l_rsv_catchup_amt,g_book_type_code);

           If l_det_bal.adjustment_cost >= 0 THEN
                l_gf_catchup_amt := l_elapsed_periods * l_det_bal.deprn_period ;
		do_round(l_gf_catchup_amt,g_book_type_code);
                l_ret:= igi_iac_common_utils.iac_round(l_gf_catchup_amt,g_book_type_code) ;
                l_general_fund_acc:= l_det_bal.general_fund_acc + l_gf_catchup_amt;
           END IF;
       ELSE
           l_rsv_catchup_amt := 0;
       END IF;



       -- If asset is fully reserved then catchup is 0
       IF (l_fully_reserved > 0) THEN
           l_rsv_catchup_amt := 0;
       END IF;
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Reinstated Depreciation expense:  				'||l_det_bal.deprn_period);
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Depreciation reserve catchup amount:  				'||l_rsv_catchup_amt);

       -- get account values
       -- add the catchup amounts as well
       l_adjustment_cost        := l_det_bal.adjustment_cost;
       l_reval_reserve_cost     := l_det_bal.reval_reserve_cost;
       l_reval_reserve_backlog  := l_det_bal.reval_reserve_backlog;
       l_operating_acct_cost    := l_det_bal.operating_acct_cost;
       l_operating_acct_backlog := l_det_bal.operating_acct_backlog;
       l_operating_acct_ytd     := l_det_bal.operating_acct_ytd;
       l_deprn_period           := l_det_bal.deprn_period;
       l_deprn_reserve_backlog  := l_det_bal.deprn_reserve_backlog;

       l_deprn_ytd           := l_det_bal.deprn_ytd +l_rsv_catchup_amt;
       l_deprn_reserve       := l_det_bal.deprn_reserve + l_rsv_catchup_amt;
       IF (l_det_bal.adjustment_cost > 0) THEN
          l_general_fund_per       := l_deprn_period;
          l_general_fund_acc       := l_general_fund_acc;
          l_reval_reserve_gen_fund := l_general_fund_acc;
          l_reval_reserve_net      := l_reval_reserve_cost - ( l_reval_reserve_backlog + l_reval_reserve_gen_fund);
       ELSE
          l_general_fund_per       := l_det_bal.general_fund_per;
          l_general_fund_acc       := l_det_bal.general_fund_acc;
          l_reval_reserve_gen_fund := l_det_bal.reval_reserve_gen_fund;
          l_reval_reserve_net      := l_det_bal.reval_reserve_net;
       END IF;
       -- calculate these
       l_operating_acct_net     := l_operating_acct_cost - l_operating_acct_backlog;
       l_net_book_value         := l_adjustment_cost - (l_deprn_reserve + l_deprn_reserve_backlog);

       -- bug 2480915 start(12) Modified for Bug 2906034
        OPEN c_get_fa_deprn(l_prev_adj_id, l_det_bal.distribution_id);
        FETCH c_get_fa_deprn INTO l_fa_deprn_period, l_fa_deprn_ytd, l_fa_deprn_reserve;
        IF c_get_fa_deprn%NOTFOUND THEN
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Record not found in igi_iac_fa_deprn');
            OPEN c_get_fa_det(g_book_type_code,
                                g_asset_id,
                                l_det_bal.distribution_id,
                                l_det_bal.period_counter);
            FETCH c_get_fa_det INTO l_fa_deprn_period, l_fa_deprn_reserve;
            CLOSE c_get_fa_det;

            OPEN c_get_fa_ytd(g_book_type_code,
                                g_asset_id,
                                l_det_bal.distribution_id);
            FETCH c_get_fa_ytd INTO l_fa_deprn_ytd;
            IF c_get_fa_ytd%NOTFOUND THEN
                l_fa_deprn_ytd := 0;
            END IF;
            CLOSE c_get_fa_ytd;
        ELSE
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Record found in igi_iac_fa_deprn');
            IF l_fully_reserved > 0 THEN
                l_fa_deprn_period := 0;
            END IF;
            IF (p_transaction_run = 'SECOND') THEN
               l_fa_deprn_ytd := l_fa_deprn_ytd + (l_elapsed_periods*l_fa_deprn_period);
	       do_round(l_fa_deprn_ytd,g_book_type_code);
               l_fa_deprn_reserve := l_fa_deprn_reserve + (l_elapsed_periods*l_fa_deprn_period);
	       do_round(l_fa_deprn_reserve,g_book_type_code);
            END IF;
        END IF;
        CLOSE c_get_fa_deprn;

       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'FA Depreciation amount:  '||l_fa_deprn_period);
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Detail level FA deprn rsv:   '||l_fa_deprn_reserve);
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Detail level FA deprn YTD:   '||l_fa_deprn_ytd);
       -- bug 2480915 end(12) Modified for Bug 2906034

       -- keep a running total of the different account amounts after they have
       -- been prorated
       l_tot_adjustment_cost         := l_tot_adjustment_cost + l_adjustment_cost;
       l_tot_net_book_value          := l_tot_net_book_value + l_net_book_value;
       l_tot_reval_reserve_cost      := l_tot_reval_reserve_cost + l_reval_reserve_cost;
       l_tot_reval_reserve_backlog   := l_tot_reval_reserve_backlog + l_reval_reserve_backlog;
       l_tot_reval_reserve_gen_fund  := l_tot_reval_reserve_gen_fund + l_reval_reserve_gen_fund;
       l_tot_reval_reserve_net       := l_tot_reval_reserve_net + l_reval_reserve_net;
       l_tot_operating_acct_cost     := l_tot_operating_acct_cost + l_operating_acct_cost;
       l_tot_operating_acct_backlog  := l_tot_operating_acct_backlog + l_operating_acct_backlog;
       l_tot_operating_acct_net      := l_tot_operating_acct_net + l_operating_acct_net;
       l_tot_operating_acct_ytd      := l_tot_operating_acct_ytd + l_operating_acct_ytd;
       l_tot_deprn_period            := l_tot_deprn_period + l_deprn_period;
       l_tot_deprn_ytd               := l_tot_deprn_ytd + l_deprn_ytd;
       l_tot_deprn_reserve           := l_tot_deprn_reserve + l_deprn_reserve;
       l_tot_deprn_reserve_backlog   := l_tot_deprn_reserve_backlog + l_deprn_reserve_backlog;
       l_tot_general_fund_per        := l_tot_general_fund_per + l_general_fund_per;
       l_tot_general_fund_acc        := l_tot_general_fund_acc + l_general_fund_acc;

        -- insert into igi_iac_det_balances with reinstatement adjustment_id
        IGI_IAC_DET_BALANCES_PKG.Insert_Row(
                     x_rowid                    => l_rowid,
                     x_adjustment_id            => p_adjust_id_reinstate,
                     x_asset_id                 => g_asset_id,
                     x_book_type_code           => g_book_type_code,
                     x_distribution_id          => l_det_bal.distribution_id,
                     x_period_counter           => p_period_counter,
                     x_adjustment_cost          => l_adjustment_cost,
                     x_net_book_value           => l_net_book_value,
                     x_reval_reserve_cost       => l_reval_reserve_cost,
                     x_reval_reserve_backlog    => l_reval_reserve_backlog,
                     x_reval_reserve_gen_fund   => l_reval_reserve_gen_fund,
                     x_reval_reserve_net        => l_reval_reserve_net,
                     x_operating_acct_cost      => l_operating_acct_cost,
                     x_operating_acct_backlog   => l_operating_acct_backlog,
                     x_operating_acct_net       => l_operating_acct_net,
                     x_operating_acct_ytd       => l_operating_acct_ytd,
                     x_deprn_period             => l_deprn_period,
                     x_deprn_ytd                => l_deprn_ytd,
                     x_deprn_reserve            => l_deprn_reserve,
                     x_deprn_reserve_backlog    => l_deprn_reserve_backlog,
                     x_general_fund_per         => l_general_fund_per,
                     x_general_fund_acc         => l_general_fund_acc,
                     x_last_reval_date          => l_det_bal.last_reval_date,
                     x_current_reval_factor     => l_det_bal.current_reval_factor,
                     x_cumulative_reval_factor  => l_det_bal.cumulative_reval_factor,
                     x_active_flag              => null,
                     x_mode                     => 'R'
                                                );

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Inserted into det balances dist id   				'||l_det_bal.distribution_id);
       -- Bug 2480915, start(13)
       -- insert into igi_iac_fa_deprn with the reinstatement adjustment_id
       IGI_IAC_FA_DEPRN_PKG.Insert_Row(
               x_rowid                => l_rowid,
               x_book_type_code       => g_book_type_code,
               x_asset_id             => g_asset_id,
               x_period_counter       => p_period_counter,
               x_adjustment_id        => p_adjust_id_reinstate,
               x_distribution_id      => l_det_bal.distribution_id,
               x_deprn_period         => l_fa_deprn_period,
               x_deprn_ytd            => l_fa_deprn_ytd,
               x_deprn_reserve        => l_fa_deprn_reserve,
               x_active_flag          => null,
               x_mode                 => 'R'
                                      );
       -- Bug 2480915, end(13)
       -- create the catchup adjustment entries for the second transaction only
       IF (p_transaction_run = 'SECOND') THEN
          -- get the number of units assigned to the distribution
          SELECT units_assigned
          INTO l_units_assigned
          FROM fa_distribution_history
          WHERE distribution_id = l_det_bal.distribution_id;
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Units assigned to distribution    '||l_units_assigned);

          -- create the catchup journals only if the catchup amounts are greater than zero,
          -- which will be only if the number of elapsed periods is greater than zero
          IF (l_elapsed_periods > 0) THEN
             -- get the latest account amounts for calculating adjustment catchups
             OPEN c_deprn_expense(p_latest_adjust_id, l_det_bal.distribution_id);
             FETCH c_deprn_expense INTO l_latest_dep_exp, l_latest_dep_rsv,
                                        l_latest_gen_fund, l_latest_rev_rsv;
             IF c_deprn_expense%NOTFOUND THEN
                CLOSE c_deprn_expense;
                RETURN FALSE;
             END IF;
             CLOSE c_deprn_expense;
             -- get the ccid for the account type Depreciation Expense
             IF NOT igi_iac_common_utils.get_account_ccid(g_book_type_code,
                                                          g_asset_id,
                                                          l_det_bal.distribution_id,
                                                          'DEPRN_EXPENSE_ACCT',
                                                          p_trxhdr_id_reinstate,
                                                          'RETIREMENT',
                                                          l_ccid)
             THEN
                 --RETURN false;
                 g_message := 'No account code combination found for Depreciation Expense';
                 RAISE e_no_ccid_found;
             END IF;
             -- depreciation expense catchup
             l_rsv_catchup := (l_deprn_period - l_latest_dep_exp)*l_elapsed_periods;
	     do_round(l_rsv_catchup,g_book_type_code);

             -- insert into igi_iac_adjustments
             IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                 x_rowid                    => l_rowid,
                 x_adjustment_id            => p_adjust_id_reinstate,
                 x_book_type_code           => g_book_type_code,
                 x_code_combination_id      => l_ccid,
                 x_set_of_books_id          => p_sob_id,
                 x_dr_cr_flag               => 'DR',
                 x_amount                   => l_rsv_catchup,
                 x_adjustment_type          => 'EXPENSE',
                 x_adjustment_offset_type   => 'RESERVE', --Null,
                 x_report_ccid              => Null,
                 x_transfer_to_gl_flag      => 'Y',
                 x_units_assigned           => l_units_assigned,
                 x_asset_id                 => g_asset_id,
                 x_distribution_id          => l_det_bal.distribution_id,
                 x_period_counter           => p_period_counter,
                 x_mode                     => 'R',
                 x_event_id                 => p_event_id
                                             );
             igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Done Expense:   '||l_rsv_catchup);

             -- insert RESERVE journal into igi_iac_adjustments with the reserve catchup amount
             -- calculate the catchup amount
             --l_de_catchup := l_deprn_reserve - l_latest_dep_rsv;
             -- get the ccid for the account type
             IF NOT igi_iac_common_utils.get_account_ccid(g_book_type_code,
                                                          g_asset_id,
                                                          l_det_bal.distribution_id,
                                                          'DEPRN_RESERVE_ACCT',
                                                          p_trxhdr_id_reinstate,
                                                          'RETIREMENT',
                                                          l_ccid)
             THEN
               --RETURN false;
               g_message := 'No account code combination found for Accumulated Depreciation';
               RAISE e_no_ccid_found;
             END IF;

             -- insert into igi_iac_adjustments
             IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                 x_rowid                    => l_rowid,
                 x_adjustment_id            => p_adjust_id_reinstate,
                 x_book_type_code           => g_book_type_code,
                 x_code_combination_id      => l_ccid,
                 x_set_of_books_id          => p_sob_id,
                 x_dr_cr_flag               => 'CR',
                 x_amount                   => l_rsv_catchup, --l_rsv_catchup_amt,
                 x_adjustment_type          => 'RESERVE',
                 x_adjustment_offset_type   => 'EXPENSE', -- Null,
                 x_report_ccid              => Null,
                 x_transfer_to_gl_flag      => 'Y',
                 x_units_assigned           => l_units_assigned,
                 x_asset_id                 => g_asset_id,
                 x_distribution_id          => l_det_bal.distribution_id,
                 x_period_counter           => p_period_counter,
                 x_mode                     => 'R',
                 x_event_id                 => p_event_id
                                              );
             igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Done Reserve:   '|| l_rsv_catchup);

             -- insert GENERAL FUND a REVAL RESERVE journal into igi_iac_adjustments with the catchup amount
             -- only if adjustment amount is greater than zero
             IF (l_det_bal.adjustment_cost > 0) THEN
                -- get the ccid for the account type REVAL RESERVE
                IF NOT igi_iac_common_utils.get_account_ccid(g_book_type_code,
                                                             g_asset_id,
                                                             l_det_bal.distribution_id,
                                                             'REVAL_RESERVE_ACCT',
                                                             p_trxhdr_id_reinstate,
                                                             'RETIREMENT',
                                                             l_ccid)
                THEN
                   --RETURN false;
                   g_message := 'No account code combination found for Revaluation Reserve';
                   RAISE e_no_ccid_found;
                END IF;

                l_reval_rsv_ccid := l_ccid;

                -- insert into igi_iac_adjustments
                IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                     x_rowid                    => l_rowid,
                     x_adjustment_id            => p_adjust_id_reinstate,
                     x_book_type_code           => g_book_type_code,
                     x_code_combination_id      => l_ccid,
                     x_set_of_books_id          => p_sob_id,
                     x_dr_cr_flag               => 'DR',
                     x_amount                   => l_rsv_catchup,
                     x_adjustment_type          => 'REVAL RESERVE',
                     x_adjustment_offset_type   => 'GENERAL FUND', --Null,
                     x_report_ccid              => Null,
                     x_transfer_to_gl_flag      => 'Y',
                     x_units_assigned           => l_units_assigned,
                     x_asset_id                 => g_asset_id,
                     x_distribution_id          => l_det_bal.distribution_id,
                     x_period_counter           => p_period_counter,
                     x_mode                     => 'R',
                     x_event_id                 => p_event_id
                                                );
	            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Done Reval Reserve:   '||l_rsv_catchup);

                 -- get the ccid for the account type General Fund
                 IF NOT igi_iac_common_utils.get_account_ccid(g_book_type_code,
                                                              g_asset_id,
                                                              l_det_bal.distribution_id,
                                                              'GENERAL_FUND_ACCT',
                                                              p_trxhdr_id_reinstate,
                                                              'RETIREMENT',
                                                              l_ccid)
                THEN
                  --RETURN false;
                  g_message := 'No account code combination found for General Fund';
                  RAISE e_no_ccid_found;
                END IF;
                -- insert into igi_iac_adjustments
                IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                    x_rowid                    => l_rowid,
                    x_adjustment_id            => p_adjust_id_reinstate,
                    x_book_type_code           => g_book_type_code,
                    x_code_combination_id      => l_ccid,
                    x_set_of_books_id          => p_sob_id,
                    x_dr_cr_flag               => 'CR',
                    x_amount                   => l_rsv_catchup,
                    x_adjustment_type          => 'GENERAL FUND',
                    x_adjustment_offset_type   => 'REVAL RESERVE', -- Null,
                    x_report_ccid              => l_reval_rsv_ccid, -- Null,
                    x_transfer_to_gl_flag      => 'Y',
                    x_units_assigned           => l_units_assigned,
                    x_asset_id                 => g_asset_id,
                    x_distribution_id          => l_det_bal.distribution_id,
                    x_period_counter           => p_period_counter,
                    x_mode                     => 'R',
                    x_event_id                 => p_event_id
                                                );
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Done General Fund:    '||l_rsv_catchup);

              END IF; -- adjustment cost > 0
           END IF; -- elapsed periods > 0
        END IF; -- second transaction
    END LOOP;

    -- bring the YTD rows associated to the retirement over with the
    -- reinstatement adjustment id and current period counter
    FOR l_get_ytd IN c_get_ytd(cp_adjustment_id   => l_prev_adj_id,
                                cp_asset_id       => g_asset_id,
                                cp_book_type_code => g_book_type_code) LOOP
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'In YTD:  dist id:   '||l_get_ytd.distribution_id);
        -- insert into igi_iac_det_balances with reinstatement adjustment_id
        IGI_IAC_DET_BALANCES_PKG.Insert_Row(
                     x_rowid                    => l_rowid,
                     x_adjustment_id            => p_adjust_id_reinstate,
                     x_asset_id                 => g_asset_id,
                     x_book_type_code           => g_book_type_code,
                     x_distribution_id          => l_get_ytd.distribution_id,
                     x_period_counter           => p_period_counter,
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

       -- Bug 2480915, start(14)
        OPEN c_get_fa_deprn(l_get_ytd.adjustment_id, l_get_ytd.distribution_id);
        FETCH c_get_fa_deprn INTO l_fa_deprn_period, l_fa_deprn_ytd, l_fa_deprn_reserve;
        IF c_get_fa_deprn%NOTFOUND THEN
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Record not found in igi_iac_fa_deprn');
            OPEN c_get_fa_ytd(g_book_type_code,
                                g_asset_id,
                                l_get_ytd.distribution_id);
            FETCH c_get_fa_ytd INTO l_fa_deprn_ytd;
            IF c_get_fa_ytd%NOTFOUND THEN
                l_fa_deprn_ytd := 0;
            END IF;
            CLOSE c_get_fa_ytd;
        END IF;
        CLOSE c_get_fa_deprn;
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'In YTD:  YTD deprn: '||l_fa_deprn_ytd);

       -- insert into igi_iac_fa_deprn with the reinstatement adjustment_id
       IGI_IAC_FA_DEPRN_PKG.Insert_Row(
               x_rowid                => l_rowid,
               x_book_type_code       => g_book_type_code,
               x_asset_id             => g_asset_id,
               x_period_counter       => p_period_counter,
               x_adjustment_id        => p_adjust_id_reinstate,
               x_distribution_id      => l_get_ytd.distribution_id,
               x_deprn_period         => 0,
               x_deprn_ytd            => l_fa_deprn_ytd,
               x_deprn_reserve        => 0,
               x_active_flag          => 'N',
               x_mode                 => 'R'
                                      );
       -- Bug 2480915, end(14)
    END LOOP;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Get the asset balance for the period counter:  			'||p_effective_retire_period_cnt);
    -- update the asset balances table for the asset to reflect the full reinstatement
     -- fetch asset balances for the period prior to retirement

    -- if a row exists for the asset for the current period else create a new row
    SELECT count(*)
    INTO l_exists
    FROM igi_iac_asset_balances
    WHERE asset_id = g_asset_id
    AND   book_type_code = g_book_type_code
    AND   period_counter = p_period_counter;

    -- fetch asset balances for the period prior to retirement
    OPEN c_ret_ass_bal(g_Asset_id,
                       g_book_type_code,
                       p_effective_retire_period_cnt --l_prev_prd_cnt
                      );
    FETCH c_ret_ass_bal INTO l_ret_ass_bal;
    IF c_ret_ass_bal%NOTFOUND THEN
       CLOSE c_ret_ass_bal;
       RETURN FALSE;
    END IF;
    CLOSE c_ret_ass_bal;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Retrieved the asset balance');

    -- update the existing asset balances record
    l_ab_net_book_value        := l_tot_net_book_value;
    l_ab_adjusted_cost         := l_tot_adjustment_cost;
    l_ab_operating_acct        := l_tot_operating_acct_net;
    l_ab_reval_reserve         := l_tot_reval_reserve_net;
    l_ab_deprn_amount          := l_tot_deprn_period;
    l_ab_deprn_reserve         := l_tot_deprn_reserve;
    l_ab_backlog_deprn_reserve := l_tot_deprn_reserve_backlog;
    l_ab_general_fund          := l_tot_general_fund_acc;

    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'NBV:    '||l_ab_net_book_value);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Adjusted Cost:    '||l_ab_adjusted_cost);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Operating acct:    '||l_ab_operating_acct);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Reval Reserve:    '||l_ab_reval_reserve);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Deprn Amount/Expense:    '||l_ab_deprn_amount);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Deprn Reserve:    '||l_ab_deprn_reserve);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Blog deprn reserve:    '||l_ab_backlog_deprn_reserve);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Gen Fund:    '||l_ab_general_fund);

    IF (l_exists > 0) THEN
       -- update the asset balances to reflect the reinstatement
       IGI_IAC_ASSET_BALANCES_PKG.Update_Row(
              X_asset_id                => g_asset_id,
              X_book_type_code	        => g_book_type_code,
              X_period_counter	        => p_period_counter,
              X_net_book_value          => l_ab_net_book_value,
              X_adjusted_cost           => l_ab_adjusted_cost,
              X_operating_acct          => l_ab_operating_acct,
              X_reval_reserve           => l_ab_reval_reserve,
              X_deprn_amount            => l_ab_deprn_amount,
              X_deprn_reserve           => l_ab_deprn_reserve,
              X_backlog_deprn_reserve   => l_ab_backlog_deprn_reserve,
              X_general_fund            => l_ab_general_fund,
              X_last_reval_date         => l_ret_ass_bal.last_reval_date,
              X_current_reval_factor    => l_ret_ass_bal.current_reval_factor,
              X_cumulative_reval_factor => l_ret_ass_bal.cumulative_reval_factor
                                         ) ;
    ELSE
       -- insert a row for the current period counter

        IGI_IAC_ASSET_BALANCES_PKG.Insert_Row(
                   X_rowid                   => l_rowid,
                   X_asset_id                => g_asset_id,
                   X_book_type_code          => g_book_type_code,
                   X_period_counter          => p_period_counter,
                   X_net_book_value          => l_ab_net_book_value,
                   X_adjusted_cost           => l_ab_adjusted_cost,
                   X_operating_acct          => l_ab_operating_acct,
                   X_reval_reserve           => l_ab_reval_reserve,
                   X_deprn_amount            => l_ab_deprn_amount,
                   X_deprn_reserve           => l_ab_deprn_reserve,
                   X_backlog_deprn_reserve   => l_ab_backlog_deprn_reserve,
                   X_general_fund            => l_ab_general_fund,
                   X_last_reval_date         => l_ret_ass_bal.last_reval_date,
                   X_current_reval_factor    => l_ret_ass_bal.current_reval_factor,
                   X_cumulative_reval_factor => l_ret_ass_bal.cumulative_reval_factor
                                             ) ;
    END IF;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'finish asset balance updates');

 RETURN TRUE;
 EXCEPTION
   WHEN e_no_cost_prorate THEN
       g_message := 'Could not get a cost prorate factor';
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,g_message);
       FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_NO_REINS_PRORATE'
                            );
       RETURN FALSE;

     WHEN e_no_ccid_found THEN
         IF c_get_ytd%ISOPEN THEN
            CLOSE c_get_ytd;
         END IF;

         igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,g_message);
         FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_WF_FAILED_CCID'
                            );
         RETURN FALSE;

     WHEN others THEN
         IF c_get_ytd%ISOPEN THEN
            CLOSE c_get_ytd;
         END IF;
         g_message := 'Error:'||SQLERRM;
	 igi_iac_debug_pkg.debug_unexpected_msg(l_path);

         g_calling_fn1 := g_calling_fn||' : Cost';
         FA_SRVR_MSG.add_sql_error(
                Calling_Fn  => g_calling_fn1
                            );
         RETURN FALSE;
 END Cost_Reinstatement;


-- ======================================================================================
-- FUNCTION Unit_Reinstatement :

-- Function to reinstate the asset partially based on Units

-- Note: This procedure needs to consider following cases:
-- 1. Distribution is fully retired, then reinstate the row previous to retirement
-- 2. Distribution is partially retired, then reinstate the row by prorating the active
--    transaction with the reinstatement proration factor
-- 3. Distribution was never retired, so need not be reinstated, but bring the row forward
--    with the reinstatement adjustment id
-- 4. Distribution A was retired fully in partial retirement 1, then Distribution B
--    is fully retired in partial retirement 2. On reinstatement, only Distribution B
--    must be reinstated and ytd figures for Distribution A must be brought forward
-- ======================================================================================

 FUNCTION Unit_Reinstatement(
                              p_adjust_id_reinstate NUMBER,
                              p_trxhdr_id_retire    NUMBER,
                              p_trxhdr_id_reinstate NUMBER,
                              p_latest_adjust_id    NUMBER,
                              p_sob_id              NUMBER,
                              p_period_counter      NUMBER,
                              p_retirement_type     VARCHAR2,
                              p_effective_retire_period_cnt  NUMBER,
                              p_transaction_run    VARCHAR2,
                              p_event_id           NUMBER

                             )
 RETURN BOOLEAN
 IS

   -- cursor to get all distribution_ids
   -- from igi_iac_det_balances for an
   -- adjustment_id and distribution id
   CURSOR c_dist_det_bal(n_adjust_id     NUMBER,
                         n_dist_id       NUMBER,
                         n_retirement_id NUMBER)
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
          iidb.last_reval_date,
          iidb.current_reval_factor,
          iidb.cumulative_reval_factor,
          iidb.active_flag
   FROM   igi_iac_det_balances iidb,
          fa_distribution_history fdh
   WHERE  iidb.adjustment_id = n_adjust_id
   AND    iidb.distribution_id = n_dist_id
   AND    fdh.distribution_id = iidb.distribution_id
   AND    fdh.retirement_id = n_retirement_id;

   -- bug 2485778, start 1
   -- cursor that will retrieve all
   -- the distributions that had been retired
   -- and is now being reinstated, thes will then be brought
   -- forward as YTD rows in addition to the YTD rows
   -- from the previous transaction

   CURSOR c_ret_ytd(n_dist_id NUMBER)
   IS
   SELECT iidb.distribution_id,
   	  iidb.adjustment_id,
          iidb.operating_acct_ytd,
          iidb.deprn_ytd,
          iidb.last_reval_date,
          iidb.current_reval_factor,
          iidb.cumulative_reval_factor
   FROM   igi_iac_det_balances iidb
   WHERE  iidb.distribution_id = n_dist_id
   AND    iidb.period_counter = (SELECT max(idb1.period_counter)
                                 FROM   igi_iac_det_balances idb1
                                 WHERE  idb1.distribution_id = n_dist_id
                                 AND    active_flag IS NULL);
   -- bug 2485778, end 1

   -- local variables
    l_rowid            ROWID;
    l_path 	       VARCHAR2(150);

    l_units_ren        fa_distribution_history.units_assigned%TYPE;
    l_units_ret        fa_distribution_history.units_assigned%TYPE;
    l_prev_adj_id      igi_iac_transaction_headers.adjustment_id%TYPE;
    l_prev_dist_id     igi_iac_det_balances.distribution_id%TYPE;

    l_retire_effect    NUMBER := 0;
    l_prorate_factor   NUMBER;
    l_rsv_catchup      NUMBER;

    l_latest_dep_exp   NUMBER;
    l_latest_dep_rsv   NUMBER;
    l_latest_gen_fund  NUMBER;
    l_latest_rev_rsv   NUMBER;
    l_de_catchup       NUMBER;

    l_units_before     NUMBER;
    l_units_after      NUMBER;
    l_elapsed_periods  NUMBER := 0;
    l_ret_type         VARCHAR2(4);

    l_ccid             igi_iac_adjustments.code_combination_id%TYPE;
    l_reval_rsv_ccid   igi_iac_adjustments.code_combination_id%TYPE;

    l_rsv_catchup_amt         igi_iac_det_balances.deprn_period%TYPE;
    l_gf_catchup_amt          igi_iac_det_balances.general_fund_acc%TYPE;
    l_adjustment_cost         NUMBER;
    l_net_book_value          NUMBER;
    l_reval_reserve_cost      NUMBER;
    l_reval_reserve_backlog   NUMBER;
    l_reval_reserve_gen_fund  NUMBER;
    l_reval_reserve_net       NUMBER;
    l_operating_acct_cost     NUMBER;
    l_operating_acct_backlog  NUMBER;
    l_operating_acct_net      NUMBER;
    l_operating_acct_ytd      NUMBER;
    l_deprn_period            NUMBER;
    l_deprn_ytd               NUMBER;
    l_deprn_reserve           NUMBER;
    l_deprn_reserve_backlog   NUMBER;
    l_general_fund_per        NUMBER;
    l_general_fund_acc        NUMBER;

    l_tot_adjustment_cost         NUMBER := 0;
    l_tot_net_book_value          NUMBER := 0;
    l_tot_reval_reserve_cost      NUMBER := 0;
    l_tot_reval_reserve_backlog   NUMBER := 0;
    l_tot_reval_reserve_gen_fund  NUMBER := 0;
    l_tot_reval_reserve_net       NUMBER := 0;
    l_tot_operating_acct_cost     NUMBER := 0;
    l_tot_operating_acct_backlog  NUMBER := 0;
    l_tot_operating_acct_net      NUMBER := 0;
    l_tot_operating_acct_ytd      NUMBER := 0;
    l_tot_deprn_period            NUMBER := 0;
    l_tot_deprn_ytd               NUMBER := 0;
    l_tot_deprn_reserve           NUMBER := 0;
    l_tot_deprn_reserve_backlog   NUMBER := 0;
    l_tot_general_fund_per        NUMBER := 0;
    l_tot_general_fund_acc        NUMBER := 0;

    l_ab_net_book_value       NUMBER;
    l_ab_adjusted_cost        NUMBER;
    l_ab_operating_acct       NUMBER;
    l_ab_reval_reserve        NUMBER;
    l_ab_deprn_amount         NUMBER;
    l_ab_deprn_reserve        NUMBER;
    l_ab_backlog_deprn_reserve   NUMBER;
    l_ab_general_fund         NUMBER;

    l_ren_dist_id      igi_iac_det_balances.distribution_id%TYPE;
    l_ret_dist_id      igi_iac_det_balances.distribution_id%TYPE;
    l_units_assigned   fa_distribution_history.units_assigned%TYPE;
    l_dist_units       fa_distribution_history.transaction_units%TYPE;
    l_curr_units       fa_distribution_history.units_assigned%TYPE;

    l_retire_id        fa_distribution_history.retirement_id%TYPE;
    l_trx_hdr_id_out   fa_distribution_history.transaction_header_id_out%TYPE;

    l_ret_ass_bal      c_ret_ass_bal%ROWTYPE;
    l_ret_ytd          c_ret_ytd%ROWTYPE;
    l_fully_reserved          NUMBER;
    l_exists                  NUMBER;

   -- bug 2480915 start(15)
   l_fa_deprn_ytd                igi_iac_fa_deprn.deprn_ytd%TYPE;
   l_fa_deprn_period             igi_iac_fa_deprn.deprn_period%TYPE;
   l_fa_deprn_reserve            igi_iac_fa_deprn.deprn_reserve%TYPE;
   -- bug 2480915 end(15)
   l_active_flag                igi_iac_det_balances.active_flag%TYPE;

    -- exceptions
   e_no_corr_reinstatement   EXCEPTION;
   e_no_ccid_found           EXCEPTION;
   e_no_unit_prorate         EXCEPTION;

 BEGIN
     l_path := g_path||'Unit_Reinstatement';
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'In Unit Reinstatement function');

    -- get the adjustment_id of the transaction previous to the
    -- retirement, for distributions that will need to be fully reinstated
    -- OPEN c_trx_prev_ret(p_trxhdr_id_retire);
    OPEN c_trx_prev_ret(cp_book_type_code     => g_book_type_code,
                        cp_asset_id           => g_asset_id,
                        cp_trxhdr_id_retire   => p_trxhdr_id_retire);
    FETCH c_trx_prev_ret INTO l_prev_adj_id;
    IF c_trx_prev_ret%NOTFOUND THEN
       CLOSE c_trx_prev_ret;
       RETURN FALSE;
    END IF;
    CLOSE c_trx_prev_ret;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Adjustment Id previous to retirement:'|| l_prev_adj_id);

    -- count the elapsed periods
    --l_elapsed_periods := p_period_counter - l_prev_prd_cnt;
    l_elapsed_periods := p_period_counter - p_effective_retire_period_cnt;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Elapsed periods:   '||l_elapsed_periods);

    -- find out NOCOPY if the asset has been fully reserved prior to retirement
    OPEN c_fully_reserved(g_asset_id, g_book_type_code);
    FETCH c_fully_reserved INTO l_fully_reserved;
    IF c_fully_reserved%NOTFOUND THEN
       CLOSE c_fully_reserved;
       RETURN FALSE;
    END IF;
    CLOSE c_fully_reserved;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Asset fully reserved period counter:   '||l_fully_reserved);

    -- get the active distributions for the transaction
    -- from igi_iac_det_balances previous to the retirement
    FOR l_det_bal IN c_det_bal(l_prev_adj_id) LOOP
         -- initialise to zero for each distribution_id
        l_rsv_catchup_amt := 0;

         -- find out NOCOPY if the distribution has been touched by retirement
        SELECT COUNT(*)
        INTO   l_retire_effect
        FROM   fa_distribution_history
        WHERE  distribution_id = l_det_bal.distribution_id
        AND    retirement_id = g_retirement_id;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Retirement effect:   '||l_retire_effect);

        -- get the reinstatement distribution id associated to the retired
        -- distribution id
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Retirement distribution id:   			'||l_det_bal.distribution_id);
        IF (l_retire_effect > 0) THEN
            l_ren_dist_id := Get_Corr_Ren_Dist_Id(
                                                  p_trxhdr_id_reinstate,
                                                  l_det_bal.distribution_id -- retirement distribution id
                                                  );

            IF (l_ren_dist_id = 0) THEN
               RAISE e_no_corr_reinstatement;
            END IF;
        ELSE
            l_ren_dist_id := l_det_bal.distribution_id;
        END IF;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Reinstate distribution id:   '||l_ren_dist_id);

        -- calculate GF catchup for first transaction
        l_gf_catchup_amt := 0;
        IF (l_fully_reserved <= 0) THEN
          l_gf_catchup_amt := l_elapsed_periods *l_det_bal.deprn_period;
	  do_round(l_gf_catchup_amt,g_book_type_code);
        ELSE
           l_gf_catchup_amt := 0;
        END IF;

        -- Calculate the depreciation expense catchup amount if called from Second_Transaction
        IF (p_transaction_run = 'SECOND') THEN
            -- calculate the catchup for depreciation reserve
           l_rsv_catchup_amt := l_elapsed_periods *l_det_bal.deprn_period;
	   do_round(l_rsv_catchup_amt,g_book_type_code);
        ELSE
           l_rsv_catchup_amt := 0;
        END IF;
        -- If asset is fully reserved then catchup is 0
        IF (l_fully_reserved > 0) THEN
             l_rsv_catchup_amt := 0;
        END IF;

        -- get all the account amounts
        l_adjustment_cost        := l_det_bal.adjustment_cost;
        l_reval_reserve_cost     := l_det_bal.reval_reserve_cost;
        l_reval_reserve_backlog  := l_det_bal.reval_reserve_backlog;
        l_operating_acct_cost    := l_det_bal.operating_acct_cost;
        l_operating_acct_backlog := l_det_bal.operating_acct_backlog;
        l_operating_acct_ytd     := l_det_bal.operating_acct_ytd;
        l_deprn_period           := l_det_bal.deprn_period;
        l_deprn_reserve_backlog  := l_det_bal.deprn_reserve_backlog;

        l_deprn_ytd           := l_det_bal.deprn_ytd +l_rsv_catchup_amt;
        l_deprn_reserve       := l_det_bal.deprn_reserve + l_rsv_catchup_amt;
        IF (l_det_bal.adjustment_cost > 0) THEN
          l_general_fund_per       := l_deprn_period;
          l_general_fund_acc       := l_det_bal.general_fund_acc + l_gf_catchup_amt;
          l_reval_reserve_gen_fund := l_general_fund_acc;
          l_reval_reserve_net      := l_reval_reserve_cost - ( l_reval_reserve_backlog + l_reval_reserve_gen_fund);
        ELSE
          l_general_fund_per       := l_det_bal.general_fund_per;
          l_general_fund_acc       := l_det_bal.general_fund_acc;
          l_reval_reserve_gen_fund := l_det_bal.reval_reserve_gen_fund;
          l_reval_reserve_net      := l_det_bal.reval_reserve_net;
        END IF;

        l_operating_acct_net     := l_operating_acct_cost - l_operating_acct_backlog;
        l_net_book_value         := l_adjustment_cost - (l_deprn_reserve + l_deprn_reserve_backlog);

        -- bug 2480915 start(19) Modified for bug 2906034
        OPEN c_get_fa_deprn(l_prev_adj_id, l_det_bal.distribution_id);
        FETCH c_get_fa_deprn INTO l_fa_deprn_period, l_fa_deprn_ytd, l_fa_deprn_reserve;
        IF c_get_fa_deprn%NOTFOUND THEN
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Record not found in igi_iac_fa_deprn');
            OPEN c_get_fa_det(g_book_type_code,
                                g_asset_id,
                                l_det_bal.distribution_id,
                                l_det_bal.period_counter);
            FETCH c_get_fa_det INTO l_fa_deprn_period, l_fa_deprn_reserve;
            CLOSE c_get_fa_det;

            OPEN c_get_fa_ytd(g_book_type_code,
                                g_asset_id,
                                l_det_bal.distribution_id);
            FETCH c_get_fa_ytd INTO l_fa_deprn_ytd;
            IF c_get_fa_ytd%NOTFOUND THEN
                l_fa_deprn_ytd := 0;
            END IF;
            CLOSE c_get_fa_ytd;
        ELSE
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Record found in igi_iac_fa_deprn');
            IF l_fully_reserved > 0 THEN
                l_fa_deprn_period := 0;
            END IF;
            IF (p_transaction_run = 'SECOND') THEN
               l_fa_deprn_ytd := l_fa_deprn_ytd + (l_elapsed_periods*l_fa_deprn_period);
	       do_round(l_fa_deprn_ytd,g_book_type_code);
               l_fa_deprn_reserve := l_fa_deprn_reserve + (l_elapsed_periods*l_fa_deprn_period);
	       do_round(l_fa_deprn_reserve,g_book_type_code);
            END IF;
        END IF;
        CLOSE c_get_fa_deprn;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'FA Depreciation amount:  '||l_fa_deprn_period);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Detail level FA deprn rsv:   '||l_fa_deprn_reserve);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Detail level FA deprn YTD:   '||l_fa_deprn_ytd);
        -- bug 2480915 end(19) Modified for bug 2906034

        -- keep a sum total for all the amounts
        l_tot_adjustment_cost         := l_tot_adjustment_cost + l_adjustment_cost;
        l_tot_net_book_value          := l_tot_net_book_value + l_net_book_value;
        l_tot_reval_reserve_cost      := l_tot_reval_reserve_cost + l_reval_reserve_cost;
        l_tot_reval_reserve_backlog   := l_tot_reval_reserve_backlog + l_reval_reserve_backlog;
        l_tot_reval_reserve_gen_fund  := l_tot_reval_reserve_gen_fund + l_reval_reserve_gen_fund;
        l_tot_reval_reserve_net       := l_tot_reval_reserve_net + l_reval_reserve_net;
        l_tot_operating_acct_cost     := l_tot_operating_acct_cost + l_operating_acct_cost;
        l_tot_operating_acct_backlog  := l_tot_operating_acct_backlog + l_operating_acct_backlog;
        l_tot_operating_acct_net      := l_tot_operating_acct_net + l_operating_acct_net;
        l_tot_operating_acct_ytd      := l_tot_operating_acct_ytd + l_operating_acct_ytd;
        l_tot_deprn_period            := l_tot_deprn_period + l_deprn_period;
        l_tot_deprn_ytd               := l_tot_deprn_ytd + l_deprn_ytd;
        l_tot_deprn_reserve           := l_tot_deprn_reserve + l_deprn_reserve;
        l_tot_deprn_reserve_backlog   := l_tot_deprn_reserve_backlog + l_deprn_reserve_backlog;
        l_tot_general_fund_per        := l_tot_general_fund_per + l_general_fund_per;
        l_tot_general_fund_acc        := l_tot_general_fund_acc + l_general_fund_acc;

        -- insert into detail balances
        IGI_IAC_DET_BALANCES_PKG.Insert_Row(
                     x_rowid                    => l_rowid,
                     x_adjustment_id            => p_adjust_id_reinstate,
                     x_asset_id                 => g_asset_id,
                     x_book_type_code           => g_book_type_code,
                     x_distribution_id          => l_ren_dist_id,
                     x_period_counter           => p_period_counter,
                     x_adjustment_cost          => l_adjustment_cost,
                     x_net_book_value           => l_net_book_value,
                     x_reval_reserve_cost       => l_reval_reserve_cost,
                     x_reval_reserve_backlog    => l_reval_reserve_backlog,
                     x_reval_reserve_gen_fund   => l_reval_reserve_gen_fund,
                     x_reval_reserve_net        => l_reval_reserve_net,
                     x_operating_acct_cost      => l_operating_acct_cost,
                     x_operating_acct_backlog   => l_operating_acct_backlog,
                     x_operating_acct_net       => l_operating_acct_net,
                     x_operating_acct_ytd       => l_operating_acct_ytd,
                     x_deprn_period             => l_deprn_period,
                     x_deprn_ytd                => l_deprn_ytd,
                     x_deprn_reserve            => l_deprn_reserve,
                     x_deprn_reserve_backlog    => l_deprn_reserve_backlog,
                     x_general_fund_per         => l_general_fund_per,
                     x_general_fund_acc         => l_general_fund_acc,
                     x_last_reval_date          => l_det_bal.last_reval_date,
                     x_current_reval_factor     => l_det_bal.current_reval_factor,
                     x_cumulative_reval_factor  => l_det_bal.cumulative_reval_factor,
                     x_active_flag              => null,
                     x_mode                     => 'R'
                                                );

        -- Bug 2480915, start(20)
        -- insert into igi_iac_fa_deprn with the reinstatement adjustment_id
        IGI_IAC_FA_DEPRN_PKG.Insert_Row(
               x_rowid                => l_rowid,
               x_book_type_code       => g_book_type_code,
               x_asset_id             => g_asset_id,
               x_period_counter       => p_period_counter,
               x_adjustment_id        => p_adjust_id_reinstate,
               x_distribution_id      => l_ren_dist_id,
               x_deprn_period         => l_fa_deprn_period,
               x_deprn_ytd            => l_fa_deprn_ytd,
               x_deprn_reserve        => l_fa_deprn_reserve,
               x_active_flag          => null,
               x_mode                 => 'R'
                                      );
        -- Bug 2480915, end(20)
        -- do the catchup adjustments here only if the amounts are greater than zero
        IF (l_elapsed_periods > 0) THEN
           IF (l_retire_effect > 0) THEN
              -- check if full or partial retirement
              SELECT units_assigned,
                     transaction_units
              INTO   l_units_assigned,
                     l_dist_units
              FROM   fa_distribution_history
              WHERE  distribution_id = l_det_bal.distribution_id;

              -- get the retirement prorate factor
              l_prorate_factor := l_dist_units/l_units_assigned;
              l_prorate_factor := abs(l_prorate_factor);

              IF (l_prorate_factor = 1) THEN
                 -- this is a full retirement
                 -- create catchup adjustment entries only for the second
                 -- depreciation transaction
                 IF (p_transaction_run = 'SECOND') THEN
                    -- get the ccid for the account type Depreciation Expense
                    IF NOT igi_iac_common_utils.get_account_ccid(g_book_type_code,
                                                              g_asset_id,
                                                              l_det_bal.distribution_id,
                                                              'DEPRN_EXPENSE_ACCT',
                                                              p_trxhdr_id_reinstate,
                                                              'RETIREMENT',
                                                              l_ccid)
                    THEN
                       --RETURN false;
                       g_message := 'No account code combination found for Depreciation Expense';
                       RAISE e_no_ccid_found;
                    END IF;
                    -- insert into igi_iac_adjustments
                    IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                           x_rowid                    => l_rowid,
                           x_adjustment_id            => p_adjust_id_reinstate,
                           x_book_type_code           => g_book_type_code,
                           x_code_combination_id      => l_ccid,
                           x_set_of_books_id          => p_sob_id,
                           x_dr_cr_flag               => 'DR',
                           x_amount                   => l_rsv_catchup_amt, -- l_deprn_period,
                           x_adjustment_type          => 'EXPENSE',
                           x_adjustment_offset_type   => 'RESERVE',
                           x_report_ccid              => Null,
                           x_transfer_to_gl_flag      => 'Y',
                           x_units_assigned           => l_units_assigned,
                           x_asset_id                 => g_asset_id,
                           x_distribution_id          => l_ren_dist_id,
                           x_period_counter           => p_period_counter,
                           x_mode                     => 'R',
                           x_event_id                 => p_event_id
                                                      );
                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'FULL:Done Expense:  '||l_rsv_catchup_amt);
                    -- insert RESERVE journal into igi_iac_adjustments with the reserve catchup amount
                    -- get the ccid for the account type
                    IF NOT igi_iac_common_utils.get_account_ccid(g_book_type_code,
                                                                 g_asset_id,
                                                                 l_ren_dist_id,
                                                                 'DEPRN_RESERVE_ACCT',
                                                                 p_trxhdr_id_reinstate,
                                                                 'RETIREMENT',
                                                                 l_ccid)
                   THEN
                       --RETURN false;
                       g_message := 'No account code combination found for Accumulated Depreciation';
                       RAISE e_no_ccid_found;
                   END IF;
                   -- insert into igi_iac_adjustments
                   IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                          x_rowid                    => l_rowid,
                          x_adjustment_id            => p_adjust_id_reinstate,
                          x_book_type_code           => g_book_type_code,
                          x_code_combination_id      => l_ccid,
                          x_set_of_books_id          => p_sob_id,
                          x_dr_cr_flag               => 'CR',
                          x_amount                   => l_rsv_catchup_amt,
                          x_adjustment_type          => 'RESERVE',
                          x_adjustment_offset_type   => 'EXPENSE',
                          x_report_ccid              => Null,
                          x_transfer_to_gl_flag      => 'Y',
                          x_units_assigned           => l_units_assigned,
                          x_asset_id                 => g_asset_id,
                          x_distribution_id          => l_ren_dist_id,
                          x_period_counter           => p_period_counter,
                          x_mode                     => 'R',
                          x_event_id                 => p_event_id
                                                      );
	               igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'FULL:Done Deprn Reserve:   '||l_rsv_catchup_amt);
                   -- insert GENERAL FUND journal into igi_iac_adjustments with the catchup amount
                   -- only if adjustment amount is greater than zero
                   IF (l_det_bal.adjustment_cost > 0) THEN
                      -- get the ccid for the account type Reval Reserve
                      IF NOT igi_iac_common_utils.get_account_ccid(g_book_type_code,
                                                                   g_asset_id,
                                                                   l_ren_dist_id,
                                                                   'REVAL_RESERVE_ACCT',
                                                                   p_trxhdr_id_reinstate,
                                                                   'RETIREMENT',
                                                                   l_ccid)
                      THEN
                         --RETURN false;
                         g_message := 'No account code combination found for Revaluation Reserve';
                         RAISE e_no_ccid_found;
                      END IF;

                      l_reval_rsv_ccid := l_ccid;

                      -- insert into igi_iac_adjustments
                      IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                             x_rowid                    => l_rowid,
                             x_adjustment_id            => p_adjust_id_reinstate,
                             x_book_type_code           => g_book_type_code,
                             x_code_combination_id      => l_ccid,
                             x_set_of_books_id          => p_sob_id,
                             x_dr_cr_flag               => 'DR',
                             x_amount                   => l_rsv_catchup_amt, --l_gf_catchup_amt,
                             x_adjustment_type          => 'REVAL RESERVE',
                             x_adjustment_offset_type   => 'GENERAL FUND', -- Null,
                             x_report_ccid              => Null,
                             x_transfer_to_gl_flag      => 'Y',
                             x_units_assigned           => l_units_assigned,
                             x_asset_id                 => g_asset_id,
                             x_distribution_id          => l_ren_dist_id,
                             x_period_counter           => p_period_counter,
                             x_mode                     => 'R',
                             x_event_id                 => p_event_id           );
	                --  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'FULL:Done Reval Reserve:   '||l_gf_catchup_amt);

                      -- get the ccid for the account type
                      IF NOT igi_iac_common_utils.get_account_ccid(g_book_type_code,
                                                                   g_asset_id,
                                                                   l_ren_dist_id,
                                                                   'GENERAL_FUND_ACCT',
                                                                   p_trxhdr_id_reinstate,
                                                                   'RETIREMENT',
                                                                   l_ccid)
                      THEN
                         --RETURN false;
                         g_message := 'No account code combination found for General Fund';
                         RAISE e_no_ccid_found;
                      END IF;
                      -- insert into igi_iac_adjustments
                      IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                              x_rowid                    => l_rowid,
                              x_adjustment_id            => p_adjust_id_reinstate,
                              x_book_type_code           => g_book_type_code,
                              x_code_combination_id      => l_ccid,
                              x_set_of_books_id          => p_sob_id,
                              x_dr_cr_flag               => 'CR',
                              x_amount                   => l_rsv_catchup_amt, --l_gf_catchup_amt,
                              x_adjustment_type          => 'GENERAL FUND',
                              x_adjustment_offset_type   => 'REVAL RESERVE',
                              x_report_ccid              => l_reval_rsv_ccid,
                              x_transfer_to_gl_flag      => 'Y',
                              x_units_assigned           => l_units_assigned,
                              x_asset_id                 => g_asset_id,
                              x_distribution_id          => l_ren_dist_id,
                              x_period_counter           => p_period_counter,
                              x_mode                     => 'R',
                              x_event_id                 => p_event_id                          );
	               --   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'FULL:Done General Fund:  '||l_gf_catchup_amt);
                   END IF; -- adjustment cost > 0
                END IF; -- second transaction
             ELSE
                -- this is a partial retirement
                -- get the latest account amounts for calculating adjustment catchups
                -- get the associated retirement distribution id
                SELECT new.distribution_id
                INTO   l_ret_dist_id
                FROM   fa_distribution_history new, fa_distribution_history old
                WHERE  old.retirement_id = g_retirement_id
                AND    old.location_id = new.location_id
                AND    old.code_combination_id = new.code_combination_id
                AND    NVL(old.assigned_to,-99) = NVL(new.assigned_to,-99)
                AND    old.transaction_header_id_out = new.transaction_header_id_in
                AND    old.distribution_id = l_det_bal.distribution_id ;

  	            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Latest adjustment id:  '||p_latest_adjust_id||' 					dist id:  '||l_ret_dist_id);
                -- bug 2485778, start 2
                -- the retirement distribution needs to be rolled forward as a YTD row
                -- for the reinstatement transaction
                OPEN c_ret_ytd(l_ret_dist_id);
                FETCH c_ret_ytd INTO l_ret_ytd;
                IF c_ret_ytd%NOTFOUND THEN
                   CLOSE c_ret_ytd;
                   RETURN FALSE;
                END IF;
                CLOSE c_ret_ytd;

                -- insert into detail balances
                IGI_IAC_DET_BALANCES_PKG.Insert_Row(
                        x_rowid                    => l_rowid,
                        x_adjustment_id            => p_adjust_id_reinstate,
                        x_asset_id                 => g_asset_id,
                        x_book_type_code           => g_book_type_code,
                        x_distribution_id          => l_ret_dist_id,
                        x_period_counter           => p_period_counter,
                        x_adjustment_cost          => 0,
                        x_net_book_value           => 0,
                        x_reval_reserve_cost       => 0,
                        x_reval_reserve_backlog    => 0,
                        x_reval_reserve_gen_fund   => 0,
                        x_reval_reserve_net        => 0,
                        x_operating_acct_cost      => 0,
                        x_operating_acct_backlog   => 0,
                        x_operating_acct_net       => 0,
                        x_operating_acct_ytd       => l_ret_ytd.operating_acct_ytd,
                        x_deprn_period             => 0,
                        x_deprn_ytd                => 0, --l_ret_ytd.deprn_ytd,
                        x_deprn_reserve            => 0,
                        x_deprn_reserve_backlog    => 0,
                        x_general_fund_per         => 0,
                        x_general_fund_acc         => 0,
                        x_last_reval_date          => l_ret_ytd.last_reval_date,
                        x_current_reval_factor     => l_ret_ytd.current_reval_factor,
                        x_cumulative_reval_factor  => l_ret_ytd.cumulative_reval_factor,
                        x_active_flag              => 'N',
                        x_mode                     => 'R'
                                                );

	            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Inserted YTD for partially retired distribution: 				'||l_ret_dist_id);
                -- bug 2485778, end 2

                -- Bug 2480915, start(21) Modified for 2906034
                -- insert into igi_iac_fa_deprn with the reinstatement adjustment_id
                OPEN c_get_fa_deprn(l_ret_ytd.adjustment_id, l_ret_ytd.distribution_id);
                FETCH c_get_fa_deprn INTO l_fa_deprn_period, l_fa_deprn_ytd, l_fa_deprn_reserve;
                IF c_get_fa_deprn%NOTFOUND THEN
		            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Record not found in igi_iac_fa_deprn');
                    OPEN c_get_fa_ytd(g_book_type_code,
                                        g_asset_id,
                                        l_ret_ytd.distribution_id);
                    FETCH c_get_fa_ytd INTO l_fa_deprn_ytd;
                    IF c_get_fa_ytd%NOTFOUND THEN
                        l_fa_deprn_ytd := 0;
                    END IF;
                    CLOSE c_get_fa_ytd;
                END IF;
                CLOSE c_get_fa_deprn;

	            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'In YTD:  YTD deprn: '||l_fa_deprn_ytd);
                IGI_IAC_FA_DEPRN_PKG.Insert_Row(
                        x_rowid                => l_rowid,
                        x_book_type_code       => g_book_type_code,
                        x_asset_id             => g_asset_id,
                        x_period_counter       => p_period_counter,
                        x_adjustment_id        => p_adjust_id_reinstate,
                        x_distribution_id      => l_ret_dist_id,
                        x_deprn_period         => 0,
                        x_deprn_ytd            => 0, --l_fa_deprn_ytd,
                        x_deprn_reserve        => 0,
                        x_active_flag          => 'N',
                        x_mode                 => 'R'
                                               );
                -- Bug 2480915, end(21) Modified for 2906034
                IF (p_transaction_run = 'SECOND') THEN
                   OPEN c_deprn_expense(p_latest_adjust_id, l_ret_dist_id);
                   FETCH c_deprn_expense INTO l_latest_dep_exp, l_latest_dep_rsv,
                                              l_latest_gen_fund, l_latest_rev_rsv;
                   IF c_deprn_expense%NOTFOUND THEN
                      CLOSE c_deprn_expense;
                      RETURN FALSE;
                   END IF;
                   CLOSE c_deprn_expense;
                   -- get the ccid for the account type Depreciation Expense
                   IF NOT igi_iac_common_utils.get_account_ccid(g_book_type_code,
                                                                g_asset_id,
                                                                l_ren_dist_id,
                                                                'DEPRN_EXPENSE_ACCT',
                                                                p_trxhdr_id_reinstate,
                                                                'RETIREMENT',
                                                                l_ccid)
                   THEN
                       --RETURN false;
                       g_message := 'No account code combination found for Depreciation Expense';
                       RAISE e_no_ccid_found;
                   END IF;

                   -- depreciation expense catchup
                   l_rsv_catchup := (l_deprn_period - l_latest_dep_exp)*l_elapsed_periods;
		   do_round(l_rsv_catchup,g_book_type_code);

                   -- insert into igi_iac_adjustments
                   IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                           x_rowid                    => l_rowid,
                           x_adjustment_id            => p_adjust_id_reinstate,
                           x_book_type_code           => g_book_type_code,
                           x_code_combination_id      => l_ccid,
                           x_set_of_books_id          => p_sob_id,
                           x_dr_cr_flag               => 'DR',
                           x_amount                   => l_rsv_catchup,
                           x_adjustment_type          => 'EXPENSE',
                           x_adjustment_offset_type   => 'RESERVE',
                           x_report_ccid              => Null,
                           x_transfer_to_gl_flag      => 'Y',
                           x_units_assigned           => l_units_assigned,
                           x_asset_id                 => g_asset_id,
                           x_distribution_id          => l_ren_dist_id,
                           x_period_counter           => p_period_counter,
                           x_mode                     => 'R',
                           x_event_id                 => p_event_id                           );
	               igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'PARTIAL:Done Expense:   '||l_rsv_catchup);
                   -- insert RESERVE journal into igi_iac_adjustments with the reserve catchup amount
                   -- get the ccid for the account type
                   IF NOT igi_iac_common_utils.get_account_ccid(g_book_type_code,
                                                                g_asset_id,
                                                                l_ren_dist_id,
                                                                'DEPRN_RESERVE_ACCT',
                                                                p_trxhdr_id_reinstate,
                                                                'RETIREMENT',
                                                                l_ccid)
                  THEN
                      --RETURN false;
                      g_message := 'No account code combination found for Accumulated Depreciation';
                      RAISE e_no_ccid_found;
                  END IF;
                  -- insert into igi_iac_adjustments
                  IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                         x_rowid                    => l_rowid,
                         x_adjustment_id            => p_adjust_id_reinstate,
                         x_book_type_code           => g_book_type_code,
                         x_code_combination_id      => l_ccid,
                         x_set_of_books_id          => p_sob_id,
                         x_dr_cr_flag               => 'CR',
                         x_amount                   => l_rsv_catchup, --l_rsv_catchup_amt,
                         x_adjustment_type          => 'RESERVE',
                         x_adjustment_offset_type   => 'EXPENSE',
                         x_report_ccid              => Null,
                         x_transfer_to_gl_flag      => 'Y',
                         x_units_assigned           => l_units_assigned,
                         x_asset_id                 => g_asset_id,
                         x_distribution_id          => l_ren_dist_id,
                         x_period_counter           => p_period_counter,
                         x_mode                     => 'R',
                         x_event_id                 => p_event_id                            );
	              igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'PARTIAL:Done Dep Reserve:  '||l_rsv_catchup);
                  -- insert GENERAL FUND journal into igi_iac_adjustments with the catchup amount
                  -- only if adjustment amount is greater than zero
                  IF (l_det_bal.adjustment_cost > 0) THEN
                     -- get the ccid for the account type Revaluaion Reserve
                     IF NOT igi_iac_common_utils.get_account_ccid(g_book_type_code,
                                                                  g_asset_id,
                                                                  l_ren_dist_id,
                                                                  'REVAL_RESERVE_ACCT',
                                                                  p_trxhdr_id_reinstate,
                                                                  'RETIREMENT',
                                                                  l_ccid)
                     THEN
                         --RETURN false;
                         g_message := 'No account code combination found for Revaluation Reserve';
                         RAISE e_no_ccid_found;
                     END IF;

                     l_reval_rsv_ccid := l_ccid;

                     -- insert into igi_iac_adjustments
                     IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                             x_rowid                    => l_rowid,
                             x_adjustment_id            => p_adjust_id_reinstate,
                             x_book_type_code           => g_book_type_code,
                             x_code_combination_id      => l_ccid,
                             x_set_of_books_id          => p_sob_id,
                             x_dr_cr_flag               => 'DR',
                             x_amount                   => l_rsv_catchup,
                             x_adjustment_type          => 'REVAL RESERVE',
                             x_adjustment_offset_type   => 'GENERAL FUND',
                             x_report_ccid              => Null,
                             x_transfer_to_gl_flag      => 'Y',
                             x_units_assigned           => l_units_assigned,
                             x_asset_id                 => g_asset_id,
                             x_distribution_id          => l_ren_dist_id,
                             x_period_counter           => p_period_counter,
                             x_mode                     => 'R',
                             x_event_id                 => p_event_id                            );
		             igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'PARTIAL:Done Reval Reserve:  				'||l_rsv_catchup);

                     -- get the ccid for the account type General Fund
                     IF NOT igi_iac_common_utils.get_account_ccid(g_book_type_code,
                                                                  g_asset_id,
                                                                  l_ren_dist_id,
                                                                  'GENERAL_FUND_ACCT',
                                                                  p_trxhdr_id_reinstate,
                                                                  'RETIREMENT',
                                                                  l_ccid)
                     THEN
                         --RETURN false;
                         g_message := 'No account code combination found for General Fund';
                         RAISE e_no_ccid_found;
                     END IF;

                     -- insert into igi_iac_adjustments
                     IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                         x_rowid                    => l_rowid,
                         x_adjustment_id            => p_adjust_id_reinstate,
                         x_book_type_code           => g_book_type_code,
                         x_code_combination_id      => l_ccid,
                         x_set_of_books_id          => p_sob_id,
                         x_dr_cr_flag               => 'CR',
                         x_amount                   => l_rsv_catchup,
                         x_adjustment_type          => 'GENERAL FUND',
                         x_adjustment_offset_type   => 'REVAL RESERVE',
                         x_report_ccid              => l_reval_rsv_ccid,
                         x_transfer_to_gl_flag      => 'Y',
                         x_units_assigned           => l_units_assigned,
                         x_asset_id                 => g_asset_id,
                         x_distribution_id          => l_ren_dist_id,
                         x_period_counter           => p_period_counter,
                         x_mode                     => 'R',
                         x_event_id                 => p_event_id                           );
	                 igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'PARTIAL:Done General Fund:  '||l_de_catchup);
                   END IF; -- adjustment cost > 0
                END IF; -- second transaction
              END IF; -- partial or full retirement
           END IF; -- distribution has retirement effect
        END IF; -- elapsed periods > 0
    END LOOP; -- all active dists from adjustment just prior to retirement

    -- bring the YTD rows associated to the retirement over with the
    -- reinstatement adjustment id and current period counter
    FOR l_get_ytd IN c_get_ytd(cp_adjustment_id  => l_prev_adj_id,
                                cp_asset_id      => g_asset_id,
                                cp_book_type_code => g_book_type_code) LOOP
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'In YTD:  dist id:   '||l_get_ytd.distribution_id);

        IF nvl(l_get_ytd.active_flag,'Y') = 'Y' THEN
           -- Set all except deprn_ytd to zeroes
            l_get_ytd.adjustment_cost := 0;
            l_get_ytd.net_book_value := 0;
            l_get_ytd.reval_reserve_cost := 0;
            l_get_ytd.reval_reserve_backlog := 0;
            l_get_ytd.reval_reserve_gen_fund := 0;
            l_get_ytd.reval_reserve_net := 0;
            l_get_ytd.operating_acct_cost := 0;
            l_get_ytd.operating_acct_backlog := 0;
            l_get_ytd.operating_acct_net := 0;
            l_get_ytd.operating_acct_ytd := 0;
            l_get_ytd.deprn_period := 0;
            l_get_ytd.deprn_ytd := 0;
            l_get_ytd.deprn_reserve := 0;
            l_get_ytd.deprn_reserve_backlog := 0;
            l_get_ytd.general_fund_per := 0;
            l_get_ytd.general_fund_acc := 0;
        END IF;
        l_active_flag := 'N';

        -- insert into igi_iac_det_balances with reinstatement adjustment_id
        IGI_IAC_DET_BALANCES_PKG.Insert_Row(
                     x_rowid                    => l_rowid,
                     x_adjustment_id            => p_adjust_id_reinstate,
                     x_asset_id                 => g_asset_id,
                     x_book_type_code           => g_book_type_code,
                     x_distribution_id          => l_get_ytd.distribution_id,
                     x_period_counter           => p_period_counter,
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
                     x_active_flag              => l_active_flag
                                                );

        -- Bug 2480915, start(22)
        OPEN c_get_fa_deprn(l_get_ytd.adjustment_id, l_get_ytd.distribution_id);
        FETCH c_get_fa_deprn INTO l_fa_deprn_period, l_fa_deprn_ytd, l_fa_deprn_reserve;
        IF c_get_fa_deprn%NOTFOUND THEN
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Record not found in igi_iac_fa_deprn');
            OPEN c_get_fa_ytd(g_book_type_code,
                                g_asset_id,
                                l_get_ytd.distribution_id);
            FETCH c_get_fa_ytd INTO l_fa_deprn_ytd;
            IF c_get_fa_ytd%NOTFOUND THEN
                l_fa_deprn_ytd := 0;
            END IF;
            CLOSE c_get_fa_ytd;
        END IF;
        CLOSE c_get_fa_deprn;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'In YTD:  YTD deprn: '||l_fa_deprn_ytd);
        IF nvl(l_get_ytd.active_flag,'Y') = 'Y' THEN
            l_fa_deprn_ytd := 0;
        END IF;
        -- insert into igi_iac_fa_deprn with the reinstatement adjustment_id
        IGI_IAC_FA_DEPRN_PKG.Insert_Row(
               x_rowid                => l_rowid,
               x_book_type_code       => g_book_type_code,
               x_asset_id             => g_asset_id,
               x_period_counter       => p_period_counter,
               x_adjustment_id        => p_adjust_id_reinstate,
               x_distribution_id      => l_get_ytd.distribution_id,
               x_deprn_period         => 0,
               x_deprn_ytd            => l_fa_deprn_ytd,
               x_deprn_reserve        => 0,
               x_active_flag          => 'N',
               x_mode                 => 'R'
                                      );
        -- Bug 2480915, end(22)
    END LOOP;

    -- update the existing asset balances record
    -- if a row exists for the asset for the current period else create a new row
    SELECT count(*)
    INTO l_exists
    FROM igi_iac_asset_balances
    WHERE asset_id = g_asset_id
    AND   book_type_code = g_book_type_code
    AND   period_counter = p_period_counter;

    -- fetch asset balances for the effective retirement period
    OPEN c_ret_ass_bal(g_asset_id,
                       g_book_type_code,
                       p_effective_retire_period_cnt --p_period_counter
                      );
    FETCH c_ret_ass_bal INTO l_ret_ass_bal;
    IF c_ret_ass_bal%NOTFOUND THEN
       CLOSE c_ret_ass_bal;
       RETURN FALSE;
    END IF;
    CLOSE c_ret_ass_bal;

    l_ab_net_book_value        := l_tot_net_book_value;
    l_ab_adjusted_cost         := l_tot_adjustment_cost;
    l_ab_operating_acct        := l_tot_operating_acct_net;
    l_ab_reval_reserve         := l_tot_reval_reserve_net;
    l_ab_deprn_amount          := l_tot_deprn_period;
    l_ab_deprn_reserve         := l_tot_deprn_reserve;
    l_ab_backlog_deprn_reserve := l_tot_deprn_reserve_backlog;
    l_ab_general_fund          := l_tot_general_fund_acc;

    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'NBV:    '||l_ab_net_book_value);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Adjusted Cost:    '||l_ab_adjusted_cost);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Operating acct:    '||l_ab_operating_acct);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Reval Reserve:    '||l_ab_reval_reserve);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Deprn Amount/Expense:    '||l_ab_deprn_amount);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Deprn Reserve:    '||l_ab_deprn_reserve);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Blog deprn reserve:    '||l_ab_backlog_deprn_reserve);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Gen Fund:    '||l_ab_general_fund);

    IF (l_exists > 0) THEN
        IGI_IAC_ASSET_BALANCES_PKG.Update_Row(
                   X_asset_id                => g_asset_id,
                   X_book_type_code          => g_book_type_code,
                   X_period_counter          => p_period_counter,
                   X_net_book_value          => l_ab_net_book_value,
                   X_adjusted_cost           => l_ab_adjusted_cost,
                   X_operating_acct          => l_ab_operating_acct,
                   X_reval_reserve           => l_ab_reval_reserve,
                   X_deprn_amount            => l_ab_deprn_amount,
                   X_deprn_reserve           => l_ab_deprn_reserve,
                   X_backlog_deprn_reserve   => l_ab_backlog_deprn_reserve,
                   X_general_fund            => l_ab_general_fund,
                   X_last_reval_date         => l_ret_ass_bal.last_reval_date,
                   X_current_reval_factor    => l_ret_ass_bal.current_reval_factor,
                   X_cumulative_reval_factor => l_ret_ass_bal.cumulative_reval_factor
                                              ) ;
    ELSE
       -- insert a row for the current period counter
        IGI_IAC_ASSET_BALANCES_PKG.Insert_Row(
                   X_rowid                   => l_rowid,
                   X_asset_id                => g_asset_id,
                   X_book_type_code          => g_book_type_code,
                   X_period_counter          => p_period_counter,
                   X_net_book_value          => l_ab_net_book_value,
                   X_adjusted_cost           => l_ab_adjusted_cost,
                   X_operating_acct          => l_ab_operating_acct,
                   X_reval_reserve           => l_ab_reval_reserve,
                   X_deprn_amount            => l_ab_deprn_amount,
                   X_deprn_reserve           => l_ab_deprn_reserve,
                   X_backlog_deprn_reserve   => l_ab_backlog_deprn_reserve,
                   X_general_fund            => l_ab_general_fund,
                   X_last_reval_date         => l_ret_ass_bal.last_reval_date,
                   X_current_reval_factor    => l_ret_ass_bal.current_reval_factor,
                   X_cumulative_reval_factor => l_ret_ass_bal.cumulative_reval_factor
                                             ) ;
    END IF;

  RETURN TRUE;
 EXCEPTION
     WHEN e_no_corr_reinstatement THEN
         IF c_dist_det_bal%ISOPEN THEN
            CLOSE c_dist_det_bal;
         END IF;
         g_message := 'No corresponding reinstatement found for the retirement distribution';
         igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,g_message);
         FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_NO_CORR_REIN_DIST_ID'
                            );
         RETURN FALSE;

     WHEN e_no_unit_prorate THEN
         IF c_dist_det_bal%ISOPEN THEN
            CLOSE c_dist_det_bal;
         END IF;
         g_message := 'Prorate factor for unit reinstatement not found';
         igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,g_message);
         FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_NO_REINS_PRORATE'
                            );
         RETURN FALSE;

     WHEN e_no_ccid_found THEN
         IF c_dist_det_bal%ISOPEN THEN
            CLOSE c_dist_det_bal;
         END IF;
         igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,g_message);
         FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_WF_FAILED_CCID'
                            );
         RETURN FALSE;

     WHEN others THEN
         IF c_dist_det_bal%ISOPEN THEN
            CLOSE c_dist_det_bal;
         END IF;
         g_message := 'Error:'||SQLERRM;
	 igi_iac_debug_pkg.debug_unexpected_msg(l_path);
         g_calling_fn1 := g_calling_fn||' : Unit';
         FA_SRVR_MSG.add_sql_error(
                Calling_Fn  => g_calling_fn1
                            );
         RETURN FALSE;
 END Unit_Reinstatement;

-- ========================================================================
-- PROCEDURE First_Transaction: Will record the first transaction of type
-- REINSTATEMENT for the reinstatement transaction
-- ========================================================================
 FUNCTION First_Transaction(p_fa_reins_rec_info    IN fa_reins_rec_info,
                            p_retirement_type      IN VARCHAR2,
                            p_fa_ret_rec           IN FA_API_TYPES.asset_retire_rec_type,
                            p_event_id             IN NUMBER
                            )
 RETURN BOOLEAN
 IS
  -- cursor to retrieve all the journal records associated with the
  -- retirement_id
  CURSOR c_reverse_je(p_trx_header_id NUMBER)
  IS
  SELECT iaa.adjustment_id,
         iaa.book_type_code,
         iaa.code_combination_id,
         iaa.set_of_books_id,
         iaa.dr_cr_flag,
         iaa.amount,
         iaa.adjustment_type,
         iaa.transfer_to_gl_flag,
         iaa.units_assigned,
         iaa.asset_id,
         iaa.distribution_id,
         iaa.period_counter,
         iaa.adjustment_offset_type,
         iaa.report_ccid
  FROM   igi_iac_adjustments iaa,
         igi_iac_transaction_headers iath
  WHERE  iaa.adjustment_id = iath.adjustment_id
  AND    iath.transaction_header_id = p_trx_header_id;

  -- local variables
  l_rowid                ROWID;
  l_latest_trx_type      igi_iac_transaction_headers.transaction_type_code%TYPE;
  l_latest_trx_id        igi_iac_transaction_headers.transaction_header_id%TYPE;
  l_latest_mref_id       igi_iac_transaction_headers.mass_reference_id%TYPE;
  l_latest_adj_id        igi_iac_transaction_headers.adjustment_id%TYPE;
  l_latest_adj_status    igi_iac_transaction_headers.adjustment_status%TYPE;
  l_prev_adjustment_id   igi_iac_transaction_headers.adjustment_id%TYPE;
  l_adjust_id_reinstate  igi_iac_transaction_headers.adjustment_id%TYPE;
  l_dr_cr_flag           igi_iac_adjustments.dr_cr_flag%TYPE;
  l_ren_dist_id          igi_iac_det_balances.distribution_id%TYPE;
  l_units_assigned       fa_distribution_history.units_assigned%TYPE;

  l_path 		  VARCHAR2(150);

  -- exceptions
  e_latest_trx_not_avail  EXCEPTION;
  e_no_corr_reinstatement EXCEPTION;
  e_reinstate_failed      EXCEPTION;

 BEGIN
  l_path := g_path||'First_Transaction';

   -- get the latest transaction for the asset
  IF NOT igi_iac_common_utils.get_latest_transaction(p_fa_reins_rec_info.book_type_code,
                                                     p_fa_reins_rec_info.asset_id,
                                                     l_latest_trx_type,
                                                     l_latest_trx_id,
                                                     l_latest_mref_id,
                                                     l_latest_adj_id,
                                                     l_prev_adjustment_id,
                                                     l_latest_adj_status)
  THEN
     RAISE e_latest_trx_not_avail;
  END IF;

  -- insert a new row for the asset with transaction type REINSTATEMENT
  -- into igi_iac_transaction_headers
  l_adjust_id_reinstate := null;
  IGI_IAC_TRANS_HEADERS_PKG.Insert_Row(
               x_rowid                     => l_rowid,
               x_adjustment_id             => l_adjust_id_reinstate, -- out parameter
               x_transaction_header_id     => p_fa_reins_rec_info.transaction_header_id,
               x_adjustment_id_out         => null,
               x_transaction_type_code     => p_fa_reins_rec_info.transaction_type_code,
               x_transaction_date_entered  => p_fa_reins_rec_info.transaction_date_entered,
               x_mass_refrence_id          => p_fa_reins_rec_info.mass_reference_id,
               x_transaction_sub_type      => p_fa_reins_rec_info.transaction_subtype,
               x_book_type_code            => g_book_type_code,
               x_asset_id                  => g_asset_id,
               x_category_id               => p_fa_reins_rec_info.asset_category_id,
               x_adj_deprn_start_date      => null,
               x_revaluation_type_flag     => null,
               x_adjustment_status         => 'COMPLETE',
               x_period_counter            => p_fa_reins_rec_info.curr_period_counter,
               x_event_id                 => p_event_id                            );
  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Inserted into headers table');

  -- update the previous active row for the asset in igi_iac_transaction_headers
  -- in order to make it inactive by setting adjustment_id_out= adjustment_id of
  -- the active row in igi_iac_transaction_headers
  IGI_IAC_TRANS_HEADERS_PKG.Update_Row(
               x_prev_adjustment_id    => l_latest_adj_id,
               x_adjustment_id         => l_adjust_id_reinstate
                                       );
  g_adj_prior_ret := l_latest_adj_id;

  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Updated Headers table');
  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Latest adjustment id:   '||l_latest_adj_id);
  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Reinstatement adjustment id:   '||l_adjust_id_reinstate);

  -- find all the journal entries for the retirement from igi_iac_adjustments
  -- and create reverse journal entries for each of them for reinstatement
  FOR l_reverse_je IN c_reverse_je(p_fa_ret_rec.detail_info.transaction_header_id_in) LOOP

           -- the dr_cr_flag will reverse, if it was DR then it will become CR
           IF (l_reverse_je.dr_cr_flag = 'DR') THEN
              l_dr_cr_flag := 'CR';
           ELSIF (l_reverse_je.dr_cr_flag = 'CR') THEN
              l_dr_cr_flag := 'DR';
           END IF;
           -- get the associated reinstatement distribution id if it exists

          l_ren_dist_id := Get_Corr_Ren_Dist_Id(
                                                p_fa_ret_rec.detail_info.transaction_header_id_out,
                                                l_reverse_je.distribution_id -- retirement distribution id
                                                );

          IF (l_ren_dist_id = 0) THEN
                  RAISE e_no_corr_reinstatement;
          END IF;
           -- get the units_assigned value for the distribution
           -- from fa_distribution_history
           SELECT units_assigned
           INTO l_units_assigned
           FROM fa_distribution_history
           WHERE distribution_id = l_reverse_je.distribution_id;

           -- insert into igi_iac_adjustments
           IGI_IAC_ADJUSTMENTS_PKG.Insert_Row(
                   x_rowid                    => l_rowid,
                   x_adjustment_id            => l_adjust_id_reinstate,
                   x_book_type_code           => l_reverse_je.book_type_code,
                   x_code_combination_id      => l_reverse_je.code_combination_id,
                   x_set_of_books_id          => l_reverse_je.set_of_books_id,
                   x_dr_cr_flag               => l_dr_cr_flag,
                   x_amount                   => l_reverse_je.amount,
                   x_adjustment_type          => l_reverse_je.adjustment_type,
                   x_adjustment_offset_type   => l_reverse_je.adjustment_offset_type,
                   x_report_ccid              => l_reverse_je.report_ccid,
                   x_transfer_to_gl_flag      => 'Y',
                   x_units_assigned           => l_units_assigned,
                   x_asset_id                 => l_reverse_je.asset_id,
                   x_distribution_id          => l_ren_dist_id,
                   x_period_counter           => p_fa_reins_rec_info.curr_period_counter,
                   x_mode                     => 'R',
                   x_event_id                 => p_event_id
                                             );

  END LOOP;
  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Done reversing retirement journals');

  -- action accordingly based on retirement type
  IF (p_retirement_type = 'FULL') THEN
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Calling Full Reinstatement');
         -- call procedure to do full reinstatement
         IF NOT Full_Reinstatement(l_adjust_id_reinstate,
                                   p_fa_ret_rec.detail_info.transaction_header_id_in, -- trx id of the retirement
                                   p_fa_ret_rec.detail_info.transaction_header_id_out, -- trx id for reinstatement
                                   p_fa_reins_rec_info.set_of_books_id,
                                   p_fa_reins_rec_info.curr_period_counter,
                                   p_fa_reins_rec_info.eff_ret_period_counter,
                                   'FIRST',
                                   p_event_id
                                   )
         THEN
             g_message := 'Full reinstatement failure';
             RAISE e_reinstate_failed;
         END IF;
  ELSIF (p_retirement_type = 'COST') THEN
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Calling Cost Reinstatement');
         -- call procedure to do partial cost reinstatement
         IF NOT Cost_Reinstatement(l_adjust_id_reinstate,
                                   l_latest_adj_id,
                                   p_fa_ret_rec.detail_info.transaction_header_id_in, -- trx id of the retirement
                                   p_fa_ret_rec.detail_info.transaction_header_id_out, -- trx id for reinstatement
                                   l_latest_adj_id,
                                   p_fa_reins_rec_info.set_of_books_id,
                                   p_fa_reins_rec_info.curr_period_counter,
                                   p_retirement_type,
                                   p_fa_reins_rec_info.eff_ret_period_counter,
                                   'FIRST',
                                   p_event_id
                                   )
         THEN
             g_message := 'Cost reinstatement failure';
             RAISE e_reinstate_failed;
         END IF;
  ELSIF (p_retirement_type = 'UNIT') THEN
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Calling Unit Reinstatement');
         -- call procedure to do partial unit reinstatement
         IF NOT Unit_Reinstatement(l_adjust_id_reinstate,
                                   p_fa_ret_rec.detail_info.transaction_header_id_in, -- trx id of the retirement
                                   p_fa_ret_rec.detail_info.transaction_header_id_out, -- trx id for reinstatement
                                   l_latest_adj_id,
                                   p_fa_reins_rec_info.set_of_books_id,
                                   p_fa_reins_rec_info.curr_period_counter,
                                   p_retirement_type,
                                   p_fa_reins_rec_info.eff_ret_period_counter,
                                   'FIRST',
                                   p_event_id
                                   )
         THEN
             g_message := 'Unit reinstatement failure';
             RAISE e_reinstate_failed;
         END IF;

  END IF;

  RETURN TRUE;
 EXCEPTION
   WHEN e_latest_trx_not_avail THEN
     -- close open cursors
     IF c_reverse_je%ISOPEN THEN
        CLOSE c_reverse_je;
     END IF;
     g_message := 'Latest transaction could not be retrieved for the asset';
     igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,g_message);
     FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_NO_LATEST_TRX'
                            );
     RETURN FALSE;

   WHEN e_no_corr_reinstatement THEN
     -- close open cursors
     IF c_reverse_je%ISOPEN THEN
        CLOSE c_reverse_je;
     END IF;
     g_message := 'Could not get corresponding reinstatement distribution id';
     igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,g_message);
     FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_NO_CORR_REIN_DIST_ID'
                            );
     RETURN FALSE;

   WHEN e_reinstate_failed THEN
     -- close open cursors
     IF c_reverse_je%ISOPEN THEN
        CLOSE c_reverse_je;
     END IF;
     igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,g_message);
     FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_REINSTATE_FAILED'
                            );
     RETURN FALSE;

   WHEN others THEN
     -- close open cursors
     IF c_reverse_je%ISOPEN THEN
        CLOSE c_reverse_je;
     END IF;
     g_message := 'Error: '||SQLERRM;
     igi_iac_debug_pkg.debug_unexpected_msg(l_path);
     g_calling_fn1 := g_calling_fn||' : First_Transaction';
     FA_SRVR_MSG.add_sql_error(
                Calling_Fn  => g_calling_fn1
                             );
      RETURN FALSE;
 END First_Transaction;

-- ========================================================================
-- PROCEDURE Second_Transaction: Will record the second transaction of type
-- DEPRECIATION - REINSTATEMENT for the reinstatement transaction
-- ========================================================================
 FUNCTION  Second_Transaction(p_fa_reins_rec_info    IN fa_reins_rec_info,
                              p_retirement_type      IN VARCHAR2,
                              p_fa_ret_rec           IN FA_API_TYPES.asset_retire_rec_type,
                              p_event_id             IN NUMBER
                              )
 RETURN BOOLEAN
 IS

  -- local variables
  l_rowid                ROWID;
  l_latest_trx_type      igi_iac_transaction_headers.transaction_type_code%TYPE;
  l_latest_trx_id        igi_iac_transaction_headers.transaction_header_id%TYPE;
  l_latest_mref_id       igi_iac_transaction_headers.mass_reference_id%TYPE;
  l_latest_adj_id        igi_iac_transaction_headers.adjustment_id%TYPE;
  l_latest_adj_status    igi_iac_transaction_headers.adjustment_status%TYPE;
  l_prev_adjustment_id   igi_iac_transaction_headers.adjustment_id%TYPE;
  l_adjust_id_reinstate  igi_iac_transaction_headers.adjustment_id%TYPE;

  l_path 		  VARCHAR2(150);

  -- exceptions
  e_latest_trx_not_avail   EXCEPTION;
  e_reinstate_failed      EXCEPTION;
 BEGIN
  l_path := g_path||'Second_Transaction';
  -- get the latest transaction for the asset
  IF NOT igi_iac_common_utils.get_latest_transaction(p_fa_reins_rec_info.book_type_code,
                                                     p_fa_reins_rec_info.asset_id,
                                                     l_latest_trx_type,
                                                     l_latest_trx_id,
                                                     l_latest_mref_id,
                                                     l_latest_adj_id,
                                                     l_prev_adjustment_id,
                                                     l_latest_adj_status)
  THEN
     RAISE e_latest_trx_not_avail;
  END IF;

  -- insert a new row for the asset with transaction type REINSTATEMENT
  -- into igi_iac_transaction_headers
  l_adjust_id_reinstate := null;
  IGI_IAC_TRANS_HEADERS_PKG.Insert_Row(
               x_rowid                     => l_rowid,
               x_adjustment_id             => l_adjust_id_reinstate, -- out parameter
               x_transaction_header_id     => null,
               x_adjustment_id_out         => null,
               x_transaction_type_code     => 'DEPRECIATION',
               x_transaction_date_entered  => p_fa_reins_rec_info.transaction_date_entered,
               x_mass_refrence_id          => null,
               x_transaction_sub_type      => 'REINSTATEMENT',
               x_book_type_code            => g_book_type_code,
               x_asset_id                  => g_asset_id,
               x_category_id               => p_fa_reins_rec_info.asset_category_id,
               x_adj_deprn_start_date      => null,
               x_revaluation_type_flag     => null,
               x_adjustment_status         => 'COMPLETE',
               x_period_counter            => p_fa_reins_rec_info.curr_period_counter,
               x_event_id                  => p_event_id
                                           );
  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Inserted into headers table');

  -- update the previous active row for the asset in igi_iac_transaction_headers
  -- in order to make it inactive by setting adjustment_id_out= adjustment_id of
  -- the active row in igi_iac_transaction_headers
  IGI_IAC_TRANS_HEADERS_PKG.Update_Row(
               x_prev_adjustment_id    => l_latest_adj_id,
               x_adjustment_id         => l_adjust_id_reinstate
                                       );
  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Updated Headers table');
  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Latest adjustment id:   '||l_latest_adj_id);
  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Reinstatement adjustment id:   '||l_adjust_id_reinstate);

  -- action accordingly based on retirement type
  IF (p_retirement_type = 'FULL') THEN
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Calling Full Reinstatement');
         -- call procedure to do full reinstatement
         IF NOT Full_Reinstatement(l_adjust_id_reinstate,
                                   p_fa_ret_rec.detail_info.transaction_header_id_in, -- trx id of the retirement
                                   p_fa_ret_rec.detail_info.transaction_header_id_out, -- trx id for reinstatement
                                   p_fa_reins_rec_info.set_of_books_id,
                                   p_fa_reins_rec_info.curr_period_counter,
                                   p_fa_reins_rec_info.eff_ret_period_counter,
                                   'SECOND',
                                   p_event_id
                                   )
         THEN
             g_message := 'Full reinstatement failure';
             RAISE e_reinstate_failed;
         END IF;
  ELSIF (p_retirement_type = 'COST') THEN
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Calling Cost Reinstatement');
         -- call procedure to do partial cost reinstatement
         IF NOT Cost_Reinstatement(l_adjust_id_reinstate,
                                   l_latest_adj_id,
                                   p_fa_ret_rec.detail_info.transaction_header_id_in, -- trx id of the retirement
                                   p_fa_ret_rec.detail_info.transaction_header_id_out, -- trx id for reinstatement
                                   g_adj_prior_ret, --l_latest_adj_id,
                                   p_fa_reins_rec_info.set_of_books_id,
                                   p_fa_reins_rec_info.curr_period_counter,
                                   p_retirement_type,
                                   p_fa_reins_rec_info.eff_ret_period_counter,
                                   'SECOND',
                                   p_event_id
                                   )
         THEN
             g_message := 'Cost reinstatement failure';
             RAISE e_reinstate_failed;
         END IF;
  ELSIF (p_retirement_type = 'UNIT') THEN
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Calling Unit Reinstatement');
         -- call procedure to do partial unit reinstatement
         IF NOT Unit_Reinstatement(l_adjust_id_reinstate,
                                   p_fa_ret_rec.detail_info.transaction_header_id_in, -- trx id of the retirement
                                   p_fa_ret_rec.detail_info.transaction_header_id_out, -- trx id for reinstatement
                                   g_adj_prior_ret, --l_latest_adj_id,
                                   p_fa_reins_rec_info.set_of_books_id,
                                   p_fa_reins_rec_info.curr_period_counter,
                                   p_retirement_type,
                                   p_fa_reins_rec_info.eff_ret_period_counter,
                                   'SECOND',
                                   p_event_id
                                   )
         THEN
             g_message := 'Unit reinstatement failure';
             RAISE e_reinstate_failed;
         END IF;

  END IF;
  RETURN TRUE;
 EXCEPTION
    WHEN e_latest_trx_not_avail THEN
     g_message := 'Latest transaction could not be retrieved for the asset';
     igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,g_message);
     FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_NO_LATEST_TRX'
                            );
     RETURN FALSE;
    WHEN e_reinstate_failed THEN
     igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,g_message);
     FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_REINSTATE_FAILED'
                            );
     RETURN FALSE;
    WHEN others THEN
     g_message := 'Error: '||SQLERRM;
     igi_iac_debug_pkg.debug_unexpected_msg(l_path);
     g_calling_fn1 := g_calling_fn||' : Second_Transaction';
     FA_SRVR_MSG.add_sql_error(
                Calling_Fn  => g_calling_fn1
                             );
      RETURN FALSE;
 END Second_Transaction;

-- ===================================================================
-- Public functions and procedures
-- ===================================================================

-- ===================================================================
-- FUNCTION Do_Iac_Reinstatement:
--
-- Main IAC reinsatement function that will be called from Assets Gains
-- and Losses program via codehook
-- ===================================================================
 FUNCTION Do_Iac_Reinstatement(p_asset_id         NUMBER,
                               p_book_type_code   VARCHAR2,
                               p_retirement_id    NUMBER,
                               p_calling_function VARCHAR2,
                               p_event_id         NUMBER)    --R12 uptake
 RETURN BOOLEAN
 IS
  -- cursor to retrieve information from fa_transaction_headers
  -- associated with a given transaction_header_id
  CURSOR c_fa_trx_headers(p_trx_hdr_id NUMBER)
  IS
  SELECT fth.transaction_header_id,
         fth.book_type_code,
         fth.asset_id,
         fth.transaction_type_code,
         fth.transaction_date_entered,
         fth.date_effective,
         fth.mass_reference_id,
         fth.transaction_subtype,
         fab.asset_category_id
  FROM  fa_transaction_headers fth,
        fa_additions_b  fab
  WHERE fth.asset_id = fab.asset_id
  AND   fth.transaction_header_id = p_trx_hdr_id;

  -- local variables
  l_path 		  VARCHAR2(150);
  l_retirement_type       VARCHAR2(5);
  l_asset_num             FA_ADDITIONS.asset_number%TYPE;

  l_fa_trx_headers        c_fa_trx_headers%ROWTYPE;
  l_ret_rec               FA_API_TYPES.asset_retire_rec_type;
  l_prd_rec               IGI_IAC_TYPES.prd_rec;
  l_eff_ret_rec           IGI_IAC_TYPES.prd_rec;
  l_sob_id                NUMBER;
  l_coa_id                NUMBER;
  l_currency              VARCHAR2(15);
  l_precision             NUMBER;
  l_mrc_sob_type          VARCHAR2(30);
  l_fa_reins_rec_info     fa_reins_rec_info;

  -- exceptions
  e_iac_not_enabled       EXCEPTION;
  e_not_iac_book          EXCEPTION;
  e_no_iac_effect         EXCEPTION;
  e_no_retire_effect      EXCEPTION;
  e_no_period_info_avail  EXCEPTION;
  e_indef_ret_type        EXCEPTION;
  e_asset_revalued        EXCEPTION;
  e_iac_fa_deprn          EXCEPTION;
  e_first_trans_failed    EXCEPTION;
  e_second_trans_failed   EXCEPTION;

  -- Sekhar ,14-07-2003
  -- Status for adjustments in a period
  FUNCTION Get_Adjustment_Status(
                                 X_book_type_code IN VARCHAR2,
                                 X_asset_id       IN NUMBER,
                                 X_Period_Counter IN NUMBER
                                 )
  RETURN BOOLEAN
  IS
     CURSOR C_get_asset_adj (p_book_type_code   fa_transaction_headers.book_type_code%TYPE,
                             p_asset_id  fa_transaction_headers.asset_id%TYPE,
                             P_period_counter number)
     IS
     SELECT *
     FROM IGI_IAC_TRANSACTION_HEADERS
     WHERE book_type_code = p_book_type_code
     AND period_counter >= p_period_counter
     AND asset_id = p_asset_id
     AND transaction_type_code='REVALUATION' and transaction_sub_type in ('OCCASSIONAL','PRFOESSIONAL');

      l_get_asset_adj   C_get_asset_adj%rowtype;

  BEGIN
     OPEN c_get_asset_adj( X_book_type_code,
                           X_asset_id ,
                           X_Period_Counter);
     FETCH c_get_asset_adj INTO l_get_asset_adj;
     IF c_get_asset_adj%FOUND THEN
        CLOSE c_get_asset_adj;
        RETURN FALSE;
     ELSE
        CLOSE c_get_asset_adj;
        RETURN TRUE;
     END IF;
  END Get_Adjustment_Status;


 BEGIN
  l_path := g_path||'Do_Iac_Reinstatement';

  -- check if IAC option is enabled in IGI
  IF NOT igi_gen.is_req_installed('IAC')
  THEN
      	RAISE e_iac_not_enabled;
  END IF;
  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'IAC is enabled');

  -- check if the FA book is an IAC book
  IF NOT igi_iac_common_utils.is_iac_book(p_book_type_code)
  THEN
      	RAISE e_not_iac_book;
  END IF;
  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' This is an IAC book:   '|| p_book_type_code);

   -- check if there is an IAC effect on the asset
  IF NOT igi_iac_common_utils.is_asset_proc(p_book_type_code,
                                            p_asset_id)
  THEN
      	RAISE e_no_iac_effect;
  END IF;

  -- get the asset number for easier debugging
  SELECT asset_number
  INTO l_asset_num
  FROM fa_additions_b
  WHERE asset_id = p_asset_id;
  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'There is an IAC effect on the asset:  '||l_asset_num);

  -- bug 2480915 start, call ytd preprocessor to populate igi_iac_fa_deprn
  -- if no entries exist for the book in the table
  IF NOT igi_iac_common_utils.populate_iac_fa_deprn_data(p_book_type_code,
                                                         'REINSTATEMENT')
  THEN
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Problems creating rows in igi_iac_fa_deprn');
    RAISE e_iac_fa_deprn;
  END IF;
  -- bug 2480915, end

  -- set up the global variables
  g_book_type_code := p_book_type_code;
  g_asset_id       := p_asset_id;
  g_retirement_id  := p_retirement_id;

  -- get the period counter value
  IF NOT igi_iac_common_utils.get_open_period_info(p_book_type_code,
                                                   l_prd_rec)
  THEN
           RAISE e_no_period_info_avail;
  END IF;

   -- get the GL set of books id
  IF NOT igi_iac_common_utils.get_book_GL_info(p_book_type_code,
                                               l_sob_id,
                                               l_coa_id,
                                               l_currency,
                                               l_precision)
  THEN
      RETURN false;
  END IF;
  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Obtained GL information');

  -- from the p_retirement_id parameter passed in, retrieve the active
  -- transaction_header_id and the associated adjustment_id of the asset
  -- from igi_iac_transaction_headers
  l_ret_rec.retirement_id := p_retirement_id;
  l_mrc_sob_type := null;
  IF NOT fa_util_pvt.get_asset_retire_rec(l_ret_rec,
                                          l_mrc_sob_type,
                                          l_sob_id)
-- Bug 8762275 . Added l_sob_id
  THEN
       RAISE e_no_retire_effect;
  ELSE
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Have retiremen info from fa_retirements');
       -- in fa_retirements, transaction_header_id_in is fa_transaction_headers.transaction_header_id
       -- of the retirement
       -- transaction_header_id_out is fa_transaction_headers.transaction_header_id of the
       -- reinstatement

       -- get the period info for the effective retirement date
       -- get the period counter value
       IF NOT igi_iac_common_utils.Get_Period_Info_for_Date(p_book_type_code,
                                                            l_ret_rec.date_retired,
                                                            l_eff_ret_rec)
       THEN
           RAISE e_no_period_info_avail;
       END IF;

   --- Check if adjustment has been processed in the current period
          IF NOT Get_Adjustment_Status(p_book_type_code,
                                       P_Asset_Id,
                                       l_eff_ret_rec.period_counter ) THEN


               FA_SRVR_MSG.Add_Message(
    	                    Calling_FN 	=>  p_calling_function ,
                	        Name 		=> 'IGI_IAC_NO_REINST_REVAL',
            	            TOKEN1		=> 'NUMBER',
        	                VALUE1		=> l_asset_num,
        	                TRANSLATE   => TRUE,
                            APPLICATION => 'IGI');

             RETURN FALSE;
      END IF;


       -- check if type of retirement is full, partial cost or partial unit as the
       -- cases have to be handled somewhat differently
       IF NOT igi_iac_common_utils.get_retirement_type(p_book_type_code,
                                                       p_asset_id,
                                                       p_retirement_id,
                                                       l_retirement_type
                                                       )
       THEN
         RAISE e_indef_ret_type;
       END IF;
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'retirement type  '||l_retirement_type);

       -- bug 2452521 start(2), check if a revaluation has been done
       -- after the asset has been partially retired
       -- revaluation for fully retired assets can be ignored
       IF (l_retirement_type <> 'FULL') THEN
          IF is_revalued(p_asset_id,
                         p_book_type_code,
                      --  l_ret_rec.detail_info.transaction_header_id_in,
                         l_eff_ret_rec.period_counter,
                         l_prd_rec.period_counter)
          THEN
             RAISE e_asset_revalued;
          END IF;
       END IF;
       -- bug 2452521 end(2)

       -- retrieve information from fa_transaction_headers for the
       -- corresponding reinstatement row
       OPEN c_fa_trx_headers(l_ret_rec.detail_info.transaction_header_id_out);
       FETCH c_fa_trx_headers INTO l_fa_trx_headers;
       CLOSE c_fa_trx_headers;

       -- populate the fa reinstatement header info record group
       l_fa_reins_rec_info.asset_id                 := l_fa_trx_headers.asset_id;
       l_fa_reins_rec_info.book_type_code           := l_fa_trx_headers.book_type_code;
       l_fa_reins_rec_info.transaction_header_id    := l_fa_trx_headers.transaction_header_id;
       l_fa_reins_rec_info.transaction_type_code    := l_fa_trx_headers.transaction_type_code;
       l_fa_reins_rec_info.transaction_date_entered := l_fa_trx_headers.transaction_date_entered;
       l_fa_reins_rec_info.date_effective           := l_fa_trx_headers.date_effective;
       l_fa_reins_rec_info.mass_reference_id        := l_fa_trx_headers.mass_reference_id;
       l_fa_reins_rec_info.transaction_subtype      := l_fa_trx_headers.transaction_subtype;
       l_fa_reins_rec_info.asset_category_id        := l_fa_trx_headers.asset_category_id;
       l_fa_reins_rec_info.set_of_books_id          := l_sob_id;
       l_fa_reins_rec_info.curr_period_counter      := l_prd_rec.period_counter;
       l_fa_reins_rec_info.eff_ret_period_counter   := l_eff_ret_rec.period_counter;

       -- call first transaction procedure
       IF NOT First_Transaction(p_fa_reins_rec_info    => l_fa_reins_rec_info,
                                p_retirement_type      => l_retirement_type,
                                p_fa_ret_rec           => l_ret_rec,
                                p_event_id             => p_event_id
                                )
       THEN
          RAISE e_first_trans_failed;
       END IF;

       -- call second transaction procedure
       IF NOT Second_Transaction(p_fa_reins_rec_info    => l_fa_reins_rec_info,
                                 p_retirement_type      => l_retirement_type,
                                 p_fa_ret_rec           => l_ret_rec,
                                 p_event_id             => p_event_id
                                 )
       THEN
          RAISE e_second_trans_failed;
       END IF;

  END IF;
  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Inflation Accounting Reinstatement successful');

  --ROLLBACK;
  --RETURN FALSE;
  RETURN TRUE;
 EXCEPTION
   WHEN e_iac_not_enabled THEN
     -- close open cursors
     IF c_fa_trx_headers%ISOPEN THEN
        CLOSE c_fa_trx_headers;
     END IF;

     g_message := 'IAC is not enabled in IGI options.';
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,g_message);
     FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_NOT_INSTALLED'
                            );

     RETURN TRUE;

   WHEN e_not_iac_book THEN
     -- close open cursors
     IF c_fa_trx_headers%ISOPEN THEN
        CLOSE c_fa_trx_headers;
     END IF;

     g_message := 'The book is not an IAC book';
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,g_message);
     FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_NOT_IAC_BOOK'
                            );

     RETURN TRUE;

   WHEN e_no_iac_effect THEN
     -- close open cursors
     IF c_fa_trx_headers%ISOPEN THEN
        CLOSE c_fa_trx_headers;
     END IF;

     g_message := 'This asset has not been revalued with IAC.';
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,g_message);
     FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_NO_IAC_EFFECT'
                            );

     RETURN TRUE;

   WHEN e_iac_fa_deprn THEN
     -- close open cursors
     IF c_fa_trx_headers%ISOPEN THEN
        CLOSE c_fa_trx_headers;
     END IF;

     g_message := 'Could not create the ytd rows in igi_iac_fa_deprn';
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,g_message);
     FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_FA_DEPR_CREATE_PROB',
                Token1      => 'BOOK',
                Value1      => g_book_type_code
                            );

     RETURN TRUE;

   -- bug 2452521 start (3)
   WHEN e_asset_revalued THEN
     -- close open cursors
     IF c_fa_trx_headers%ISOPEN THEN
        CLOSE c_fa_trx_headers;
     END IF;
     g_message := 'This asset has been revalued atleast once after retirement. Cannot be reinstated.';
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,g_message);
     FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_REVAL_POST_RETIRE'
                            );
     ROLLBACK;
     RETURN TRUE;
   -- bug 2452521 end (3)

   WHEN e_no_retire_effect THEN
     -- close open cursors
     IF c_fa_trx_headers%ISOPEN THEN
        CLOSE c_fa_trx_headers;
     END IF;

     g_message := 'Retirement information not available for asset';
     igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,g_message);
     FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_NO_RETIRE_EFFECT'
                            );
      --ROLLBACK;
      RETURN FALSE;

   WHEN e_no_period_info_avail THEN
     -- close open cursors
     IF c_fa_trx_headers%ISOPEN THEN
        CLOSE c_fa_trx_headers;
     END IF;

     g_message := 'Period Info Error: '||SQLERRM;
     igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,g_message);
     FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_NO_PERIOD_INFO'
                           );
     --ROLLBACK;
     RETURN FALSE;

   WHEN e_indef_ret_type THEN
     -- close open cursors
     IF c_fa_trx_headers%ISOPEN THEN
        CLOSE c_fa_trx_headers;
     END IF;

     g_message := 'Cannot define retirement type';
     igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,g_message);
     FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_INDEF_RETIRE_TYPE'
                            );
     --ROLLBACK;
     RETURN FALSE;

   WHEN e_first_trans_failed THEN
     -- close open cursors
     IF c_fa_trx_headers%ISOPEN THEN
        CLOSE c_fa_trx_headers;
     END IF;

     igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,g_message);
     FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_REINSTATE_FAILED'
                            );
     --ROLLBACK;
     RETURN FALSE;

   WHEN e_second_trans_failed THEN
     -- close open cursors
     IF c_fa_trx_headers%ISOPEN THEN
        CLOSE c_fa_trx_headers;
     END IF;

     igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,g_message);
     FA_SRVR_MSG.add_message(
                Calling_Fn  => g_calling_fn,
                Name        => 'IGI_IAC_REINSTATE_FAILED'
                            );
     --ROLLBACK;
     RETURN FALSE;

   WHEN others THEN
     -- close open cursors
     IF c_fa_trx_headers%ISOPEN THEN
        CLOSE c_fa_trx_headers;
     END IF;

     g_message := 'Error: '||SQLERRM;
     igi_iac_debug_pkg.debug_unexpected_msg(l_path);
     g_calling_fn1 := g_calling_fn||' : Main';
     FA_SRVR_MSG.add_sql_error(
                Calling_Fn  => g_calling_fn1
                             );
      --ROLLBACK;
      RETURN FALSE;

 END Do_Iac_Reinstatement;

BEGIN
--===========================FND_LOG.START=====================================
g_state_level :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level :=	FND_LOG.LEVEL_EVENT;
g_excep_level :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level :=	FND_LOG.LEVEL_ERROR;
g_unexp_level :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        := 'IGI.PLSQL.igiiarnb.IGI_IAC_REINSTATE_PKG.';
--===========================FND_LOG.END=======================================

 g_calling_fn  := 'IGI_IAC_REINSTATE_PKG.Do_Iac_Reinstatement';

END IGI_IAC_REINSTATE_PKG;

/
