--------------------------------------------------------
--  DDL for Package Body FA_TRANSFER_XIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_TRANSFER_XIT_PKG" as
/* $Header: FAXTFRXB.pls 120.12.12010000.3 2009/07/19 11:11:32 glchen ship $ */

g_release                  number  := fa_cache_pkg.fazarel_release;

-- Constants used for function setacct
FA_TFR_COST        CONSTANT NUMBER := 1;
FA_TFR_DEPRN_RSV   CONSTANT NUMBER := 2;
FA_TFR_REVAL_RSV   CONSTANT NUMBER := 3;
FA_TFR_BONUS_DEPRN_RSV CONSTANT NUMBER := 6;
FA_TFR_IMPAIRMENT_RSV CONSTANT NUMBER := 7;
FA_CAPITAL_ADJUSTMENT CONSTANT NUMBER := 8; -- Bug 6666666
FA_GENERAL_FUND    CONSTANT NUMBER := 9;    -- Bug 6666666



/* BUG# 1823498 MRC changes
 * following cursor was borrowed from famcospb.pls and is
 * used to pick up the primary and all associated reporting books
 * for processing
 *    -- bridgway 6/20/01
 */

  CURSOR n_sob_id (p_psob_id IN NUMBER,
                   p_book_type_code IN VARCHAR2) is
  SELECT p_psob_id AS sob_id,
         1 AS index_id
    FROM dual
   UNION
  SELECT set_of_books_id AS sob_id,
         2 AS index_id
    FROM fa_mc_book_controls
   WHERE book_type_code = p_book_type_code
     AND primary_set_of_books_id = p_psob_id
     AND enabled_flag = 'Y'
   ORDER BY 2;


--
-- FUNCTION fautfr
--

FUNCTION fautfr(X_thid               IN   NUMBER,
                X_asset_id           IN   NUMBER,
                X_book               IN   VARCHAR2,
                X_txn_type_code      IN   VARCHAR2,
                X_period_ctr         IN   NUMBER,
                X_curr_units         IN   NUMBER,
                X_today              IN   DATE,
                X_old_cat_id         IN   NUMBER,
                X_new_cat_id         IN   NUMBER,
                X_asset_type         IN   VARCHAR2,
                X_last_update_date   IN DATE default sysdate,
                X_last_updated_by    IN NUMBER default -1,
                X_last_update_login  IN NUMBER default -1,
                X_init_message_flag  IN VARCHAR2 DEFAULT 'NO', p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return BOOLEAN is


   h_amount_cleard NUMBER := 0;
   h_book          fa_book_controls.book_type_code%TYPE;
   h_book_class    fa_book_controls.book_class%TYPE;
   h_dist_book     fa_book_controls.distribution_source_book%TYPE;

   h_date_eff      DATE;
   h_msg_name      VARCHAR2(30) := NULL;
   h_cur_per_ctr   NUMBER;
   h_period_ctr    NUMBER;

   h_adj           fa_adjust_type_pkg.fa_adj_row_struct;
   h_dpr           fa_std_types.fa_deprn_row_struct;

   h_proceed       BOOLEAN;
   ERROR_FOUND     EXCEPTION;
   h_count         NUMBER;
   h_status        BOOLEAN;

-- BUG# 1823498 mrc changes
   h_primary_sob_id  number;
   h_profile_sob_id  number;
   h_currency_context varchar2(64);
   h_mrc_sob_type_code varchar2(1);

   --bug2353154
   l_account_flex              NUMBER;
   l_bal_segnum                NUMBER;
   l_old_dist_id               NUMBER;
   l_old_ccid                  NUMBER;
   l_total_amt_to_prorate      NUMBER;
   l_total_units_to_process    NUMBER;
   l_amount_inserted_tr_out    NUMBER;
   l_old_bal_seg               VARCHAR2(25);
   h_pc 		       number;
   h_tracking_method     VARCHAR2(30);
   h_member_rollup_flag  VARCHAR2(1);
   h_is_prior_period	boolean;
   h_exp_moved		boolean := false;

   -- R12 removing this cursor as FAVDISTB.pls now drives by book

   BEGIN

     if (X_init_message_flag = 'YES') then
         FA_SRVR_MSG.INIT_SERVER_MESSAGE;   /* init server msg stack */
         fa_debug_pkg.initialize;           /* init debug msg stack */
     end if;

     /* BUG# 1823498
      * get the current sob profile option value for later usage
      * as it needs to reset upon completion or failure, then get
      * the set_of_books_id for the corp book being processed
      */

     if (X_txn_type_code NOT in ('TRANSFER','UNIT ADJUSTMENT','RECLASS',
                                 'TRANSFER OUT')) then
        return (TRUE);
     end if;

     if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fautfr',
                         element => 'txn_type_code',
                         value   => X_txn_type_code, p_log_level_rec => p_log_level_rec);
     end if;

     if (nvl(fa_cache_pkg.fazcbc_record.allow_group_deprn_flag, 'N') = 'Y' and
         nvl(fa_cache_pkg.fazcbc_record.allow_member_tracking_flag, 'N') = 'Y') then
        select nvl(bk.tracking_method, 'NONE'),
               nvl(bk.member_rollup_flag, 'N')
          into h_tracking_method,
               h_member_rollup_flag
          from fa_books bk
         where asset_id = X_asset_id
           and book_type_code = X_book
           and transaction_header_id_out is null;

     else
        h_tracking_method := 'NONE';
        h_member_rollup_flag := 'Y';
     end if;


     h_adj.asset_invoice_id := 0;
     h_adj.leveling_flag := TRUE;

     if (X_txn_type_code = 'RECLASS') then
        h_adj.source_type_code := 'RECLASS';
     else
        h_adj.source_type_code := 'TRANSFER';
     end if;

     h_adj.code_combination_id := 0;
     h_adj.transaction_header_id := X_thid;
     h_adj.asset_id := X_asset_id;
     h_adj.adjustment_amount := 0;
     h_adj.distribution_id := 0;
     h_adj.annualized_adjustment := 0;
     h_adj.last_update_date := X_today;
     h_adj.current_units := X_curr_units;
     h_adj.selection_thid := X_thid;
     h_adj.flush_adj_flag := FALSE;
     h_adj.gen_ccid_flag := TRUE;
     h_adj.amount_inserted := 0;

     h_msg_name := 'FA_TFR_BOOK_INFO';

     h_proceed := TRUE;
     h_book    := X_book;

     if (X_txn_type_code = 'TRANSFER OUT') then
        h_dist_book := fa_cache_pkg.fazcbc_record.distribution_source_book;
        if (h_dist_book = h_book) then
           return TRUE;
        end if;
     end if;


     -- SLA: always used passed period counter
     h_cur_per_ctr := X_period_ctr;

     h_adj.book_type_code := h_book;
     h_adj.period_counter_created := h_cur_per_ctr;
     h_adj.period_counter_adjusted := h_cur_per_ctr;

     h_primary_sob_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

     -- BUG# 6951826
      if (X_Asset_Type     <> 'GROUP' and
          (h_tracking_method = 'ALLOCATE' OR
           (h_tracking_method = 'CALCULATE' AND
            h_member_rollup_flag = 'N'))) then
         h_adj.track_member_flag := 'Y';
      else
         h_adj.track_member_flag := null;
      end if;

      /* BUG# 1823498 adding for MRC enhancements
       * loop through each SOB (primary and reporting) and
       * and process each directly to avoid rounding errors
       *    -- bridgway 06/20/01
       */

      for c_rec in n_sob_id(h_primary_sob_id, h_book) loop

         if c_rec.index_id = 1 then
            h_mrc_sob_type_code := 'P';
         else
            h_mrc_sob_type_code := 'R';
         end if;

         h_dpr.asset_id := X_asset_id;
         h_dpr.book := h_book;
         h_dpr.period_ctr := 0;
         h_dpr.dist_id := 0;
         h_dpr.mrc_sob_type_code := h_mrc_sob_type_code;
         h_dpr.set_of_books_id := c_rec.sob_id;

         -- query for the deprn reserve, reval reserve, before we clear out
         -- the accounts, for a consistent read value
         -- bonus: bonus_deprn_rsv,bonus_ytd_deprn,bonus_exp added
         --        to query balances
         fa_query_balances_pkg.query_balances_int(
                              X_DPR_ROW => h_dpr,
                              X_RUN_MODE => 'STANDARD',
                              X_DEBUG => FALSE,
                              X_SUCCESS => h_status,
                              X_CALLING_FN => 'FA_TRANSFER_XIT_PKG.fautfr',
                              X_TRANSACTION_HEADER_ID => -1, p_log_level_rec => p_log_level_rec);
         if (NOT h_status) then
            raise ERROR_FOUND;
         end if;


         if (X_txn_type_code = 'TRANSFER') then

            if (NOT fatsgl(X_adj => h_adj,
                                 X_cat_id => X_new_cat_id,
                                 X_asset_type => X_asset_type,
                                 X_last_update_date  => X_last_update_date,
                                 X_last_updated_by   => X_last_updated_by,
                                 X_last_update_login => X_last_update_login,
                                 X_mrc_sob_type_code => h_mrc_sob_type_code,
                                 X_set_of_books_id => c_rec.sob_id,
                                 p_log_level_rec => p_log_level_rec)) then
                raise ERROR_FOUND;
            end if;

         -- bonus: implies reclass
         else

            h_adj.track_member_flag := null;

            -- move the cost
            if (NOT fadotfr(X_adj_ptr => h_adj,
                                  X_acctcode => FA_TFR_COST,
                                  X_old_cat_id => X_old_cat_id,
                                  X_new_cat_id => X_new_cat_id,
                                  X_asset_type => X_asset_type,
                                  X_last_update_date  => X_last_update_date,
                                  X_last_updated_by   => X_last_updated_by,
                                  X_last_update_login => X_last_update_login,
                                  X_mrc_sob_type_code => h_mrc_sob_type_code,
                                  X_set_of_books_id => c_rec.sob_id,
                                  p_log_level_rec => p_log_level_rec)) then
                raise ERROR_FOUND;
             end if;


             -- BUG# 6951826
             if (X_Asset_Type     <> 'GROUP' and
                 (h_tracking_method = 'ALLOCATE' OR
                  (h_tracking_method = 'CALCULATE' AND
                   h_member_rollup_flag = 'N'))) then
                h_adj.track_member_flag := 'Y';
             else
                h_adj.track_member_flag := null;
             end if;


             -- move the deprn reserve
             h_adj.flush_adj_flag := TRUE;
             if (NOT fadotfr(X_adj_ptr => h_adj,
                                  X_acctcode => FA_TFR_DEPRN_RSV,
                                  X_old_cat_id => X_old_cat_id,
                                  X_new_cat_id => X_new_cat_id,
                                  X_asset_type => X_asset_type,
                                  X_last_update_date  => X_last_update_date,
                                  X_last_updated_by   => X_last_updated_by,
                                  X_last_update_login => X_last_update_login,
                                  X_mrc_sob_type_code => h_mrc_sob_type_code,
                                  X_set_of_books_id => c_rec.sob_id,
                                  p_log_level_rec => p_log_level_rec)) then
                raise ERROR_FOUND;
             end if;


             -- bonus: move the bonus deprn reserve if bonus reserve exist
             if nvl(h_dpr.bonus_deprn_rsv,0) <> 0 then
                h_adj.flush_adj_flag := TRUE;
                if (NOT fadotfr(X_adj_ptr => h_adj,
                                     X_acctcode => FA_TFR_BONUS_DEPRN_RSV,
                                     X_old_cat_id => X_old_cat_id,
                                     X_new_cat_id => X_new_cat_id,
                                     X_asset_type => X_asset_type,
                                     X_last_update_date  => X_last_update_date,
                                     X_last_updated_by   => X_last_updated_by,
                                     X_last_update_login => X_last_update_login,
                                     X_mrc_sob_type_code => h_mrc_sob_type_code,
                                     X_set_of_books_id => c_rec.sob_id,
                                     p_log_level_rec => p_log_level_rec)) then
                raise ERROR_FOUND;                     end if;
             end if;

             if nvl(h_dpr.impairment_rsv,0) <> 0 then
                h_adj.flush_adj_flag := TRUE;
                if (NOT fadotfr(X_adj_ptr => h_adj,
                                     X_acctcode => FA_TFR_IMPAIRMENT_RSV,
                                     X_old_cat_id => X_old_cat_id,
                                     X_new_cat_id => X_new_cat_id,
                                     X_asset_type => X_asset_type,
                                     X_last_update_date  => X_last_update_date,
                                     X_last_updated_by   => X_last_updated_by,
                                     X_last_update_login => X_last_update_login,
                                     X_mrc_sob_type_code => h_mrc_sob_type_code,
                                     X_set_of_books_id => c_rec.sob_id,
                                     p_log_level_rec => p_log_level_rec)) then
                raise ERROR_FOUND;                     end if;
             end if;

             -- move the reval_reserve, set flush = TRUE to insert all the
             -- FA_ADJUSTMENTS rows to the database

             if (nvl(h_dpr.reval_rsv,0) <> 0) then
                h_adj.flush_adj_flag := TRUE;
                if (NOT fadotfr(X_adj_ptr => h_adj,
                                      X_acctcode => FA_TFR_REVAL_RSV,
                                      X_old_cat_id => X_old_cat_id,
                                      X_new_cat_id => X_new_cat_id,
                                      X_asset_type => X_asset_type,
                                      X_last_update_date  => X_last_update_date,
                                      X_last_updated_by   => X_last_updated_by,
                                      X_last_update_login => X_last_update_login,
                                      X_mrc_sob_type_code => h_mrc_sob_type_code,
                                      X_set_of_books_id => c_rec.sob_id,
                                      p_log_level_rec => p_log_level_rec)) then
                    raise ERROR_FOUND;
                end if;
             end if;

             /* Bug 6666666 : Added for SORP Compliance */
             if nvl(h_dpr.capital_adjustment,0) <> 0 then
                -- h_adj.flush_adj_flag := TRUE;
                if (NOT fadotfr(X_adj_ptr => h_adj,
                                     X_acctcode => FA_CAPITAL_ADJUSTMENT,
                                     X_old_cat_id => X_old_cat_id,
                                     X_new_cat_id => X_new_cat_id,
                                     X_asset_type => X_asset_type,
                                     X_last_update_date  => X_last_update_date,
                                     X_last_updated_by   => X_last_updated_by,
                                     X_last_update_login => X_last_update_login,
                                     X_mrc_sob_type_code => h_mrc_sob_type_code,
                                     X_set_of_books_id => c_rec.sob_id,
                                     p_log_level_rec => p_log_level_rec)) then
                raise ERROR_FOUND;                     end if;
             end if;

             /* Bug 6666666 : Added for SORP Compliance */
             if nvl(h_dpr.general_fund,0) <> 0 then
                -- h_adj.flush_adj_flag := TRUE;
                if (NOT fadotfr(X_adj_ptr => h_adj,
                                     X_acctcode => FA_GENERAL_FUND,
                                     X_old_cat_id => X_old_cat_id,
                                     X_new_cat_id => X_new_cat_id,
                                     X_asset_type => X_asset_type,
                                     X_last_update_date  => X_last_update_date,
                                     X_last_updated_by   => X_last_updated_by,
                                     X_last_update_login => X_last_update_login,
                                     X_mrc_sob_type_code => h_mrc_sob_type_code,
                                     X_set_of_books_id => c_rec.sob_id,
                                     p_log_level_rec => p_log_level_rec)) then
                        raise ERROR_FOUND;                     end if;
             end if;

          end if;  -- if X_txn_type_code

      end loop;  -- end mrc

     /* Bug#4424613:
        By having a new function faumvexp, we will be moving the existing catchup expense
        created by amortized adj expense
        to a new distribution created by reclass
        in period of addition.
        Please note that the main select in fautfr returns no rows to process in this scenario
        though it is called even in period of addition.
     */

     -- R12 conditional logic
     if (G_release = 11) then
        h_is_prior_period := TRUE;
        IF NOT faucper(X_asset_id => X_asset_id,
                    X_is_prior_period => h_is_prior_period,
                    X_book => X_book,
                    p_log_level_rec => p_log_level_rec)  THEN
           RAISE error_found;
        END IF;

        --Bug#7396223:
        --Included Transfer along with reclass
        if (NOT h_is_prior_period
            and X_txn_type_code in ('RECLASS','TRANSFER')) then

           IF NOT faumvexp(X_asset_id => X_asset_id
                      ,X_book_type_code => X_book
                      ,X_th_id => X_thid
                      ,X_to_category_id => X_new_cat_id
                      ,X_exp_moved => h_exp_moved
                      ,X_last_update_date => X_last_update_date
                      ,X_last_updated_by => X_last_updated_by
                      ,X_last_update_login => X_last_update_login,
                      p_log_level_rec => p_log_level_rec) THEN

                    RAISE error_found;
           END IF;

        end if;

     end if;

     return (TRUE);


  EXCEPTION
     when ERROR_FOUND then
        fa_srvr_msg.add_message(calling_fn => 'FA_TRANSFER_XIT_PKG.fautfr',
                                name => h_msg_name, p_log_level_rec => p_log_level_rec);

        return(FALSE);


     when others then
        fa_srvr_msg.add_sql_error(calling_fn => 'FA_TRANSFER_XIT_PKG.fautfr', p_log_level_rec => p_log_level_rec);

        return(FALSE);

  END;

--
-- FUNCTION fadotfr
--

FUNCTION fadotfr(X_adj_ptr       IN OUT NOCOPY  fa_adjust_type_pkg.fa_adj_row_struct,
                 X_acctcode      IN   NUMBER,
                 X_old_cat_id    IN   NUMBER,
                 X_new_cat_id    IN   NUMBER,
                 X_asset_type    IN   VARCHAR2,
                 X_last_update_date  IN DATE default sysdate,
                 X_last_updated_by   IN NUMBER default -1,
                 X_last_update_login IN NUMBER default -1,
                 X_mrc_sob_type_code IN VARCHAR2,
                 X_set_of_books_id   IN NUMBER,
                 p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return BOOLEAN is

  h_amount_cleared NUMBER;
  h_msg_name       VARCHAR2(30);
  h_token1         VARCHAR2(30);
  h_token2         VARCHAR2(30);
  h_value1         NUMBER;
  h_value2         NUMBER;
  ERROR_FOUND      EXCEPTION;


  BEGIN

     h_msg_name := NULL;


     -- clear out the account for all distributions
     if (NOT setacct(X_adj_ptr => X_adj_ptr,
                     X_acctcode => X_acctcode,
                     X_select_mode => fa_adjust_type_pkg.FA_AJ_CLEAR,
                     X_cat_id => X_old_cat_id,
                     X_asset_type => X_asset_type,
                     p_log_level_rec => p_log_level_rec)) then
         raise ERROR_FOUND;
     end if;

     X_adj_ptr.selection_retid := X_old_cat_id;
     X_adj_ptr.selection_mode := fa_adjust_type_pkg.FA_AJ_CLEAR;
     X_adj_ptr.mrc_sob_type_code := X_mrc_sob_type_code;
     X_adj_ptr.source_dest_code  := 'SOURCE';
     X_adj_ptr.set_of_books_id := X_set_of_books_id;

     if (NOT fa_ins_adjust_pkg.faxinaj(X_adj_ptr,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then
        if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fadotfr',
                             element => 'X_acctcode',
                             value   => X_acctcode, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fadotfr',
                             element => 'adjustment_type',
                             value   => X_adj_ptr.adjustment_type, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fadotfr',
                             element => 'select_mode',
                             value   => X_adj_ptr.selection_mode, p_log_level_rec => p_log_level_rec);
        end if;
        raise ERROR_FOUND;
     end if;

     -- save amount cleared

     h_amount_cleared := X_adj_ptr.amount_inserted;

     -- set adjustment amount to be amount cleared
     X_adj_ptr.adjustment_amount := h_amount_cleared;

     X_adj_ptr.amount_inserted := 0;

     -- transfer cleared amount to new account
     if (NOT setacct(X_adj_ptr => X_adj_ptr,
                     X_acctcode => X_acctcode,
                     X_select_mode => fa_adjust_type_pkg.FA_AJ_ACTIVE,
                     X_cat_id => X_new_cat_id,
                     X_asset_type => X_asset_type,
                     p_log_level_rec => p_log_level_rec )) then
         raise ERROR_FOUND;
     end if;

     X_adj_ptr.selection_retid := X_new_cat_id;
     X_adj_ptr.selection_mode := fa_adjust_type_pkg.FA_AJ_ACTIVE;
     X_adj_ptr.mrc_sob_type_code := X_mrc_sob_type_code;
     X_adj_ptr.source_dest_code  := 'DEST';
     X_adj_ptr.set_of_books_id := X_set_of_books_id;

     if (NOT fa_ins_adjust_pkg.faxinaj(X_adj_ptr,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then
        if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fadotfr',
                             element => 'X_acctcode',
                             value   => X_acctcode, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fadotfr',
                             element => 'adjustment_type',
                             value   => X_adj_ptr.adjustment_type, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fadotfr',
                             element => 'select_mode',
                             value   => X_adj_ptr.selection_mode, p_log_level_rec => p_log_level_rec);
        end if;
        raise ERROR_FOUND;
     end if;

   -- check to make sure amount cleared is same as amount transferred.
     if (h_amount_cleared <> X_adj_ptr.amount_inserted) then
         h_msg_name := 'FA_TFR_UNBAL_AMTS';
         h_token1 := 'CLEARED';
         h_token2 := 'INSERTED';
         h_value1 := h_amount_cleared;
         h_value2 := X_adj_ptr.amount_inserted;
         raise ERROR_FOUND;
     end if;

     /* clear the amount inserted */

     X_adj_ptr.amount_inserted := 0;

     return TRUE;


  EXCEPTION
    when ERROR_FOUND then
      fa_srvr_msg.add_message(calling_fn => 'FA_TRANSFER_XIT_PKG.fadotfr',
                              name => h_msg_name,
                              token1=> h_token1, value1=>h_value1,
                              token2=> h_token2, value2=>h_value2, p_log_level_rec => p_log_level_rec);
      return FALSE;

    when OTHERS then
      fa_srvr_msg.add_sql_error(calling_fn => 'FA_TRANSFER_XIT_PKG.fadotfr', p_log_level_rec => p_log_level_rec);
      return FALSE;

  END fadotfr;


--
-- FUNCTION setacct
--

FUNCTION setacct(X_adj_ptr  IN OUT NOCOPY fa_adjust_type_pkg.fa_adj_row_struct,
                 X_acctcode IN NUMBER,
                 X_select_mode IN NUMBER,
                 X_cat_id      IN NUMBER,
                 X_asset_type  IN VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
        return BOOLEAN is

  h_book          X_adj_ptr.book_type_code%type;
  h_category_id   NUMBER;

  BEGIN

      if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.setacct',
                           element => 'X_acctcode',
                           value   => X_acctcode, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.setacct',
                           element => 'adjustment_type',
                           value   => X_adj_ptr.adjustment_type, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.setacct',
                           element => 'X_select_mode',
                           value   => X_select_mode, p_log_level_rec => p_log_level_rec);
      end if;

      h_book := X_adj_ptr.book_type_code;
      h_category_id := X_cat_id;

      if (X_acctcode = FA_TFR_COST) then

          X_adj_ptr.adjustment_type := 'COST';

          if (X_asset_type = 'CIP') then
              X_adj_ptr.account_type := 'CIP_COST_ACCT';

             select cip_cost_acct
             into X_adj_ptr.account
             from fa_category_books
             where book_type_code = h_book
             and category_id = h_category_id;

          elsif (X_asset_type = 'CAPITALIZED' OR
                 X_asset_type = 'EXPENSED' OR
                 X_asset_type = 'GROUP' ) then

             X_adj_ptr.account_type := 'ASSET_COST_ACCT';

             select asset_cost_acct
             into X_adj_ptr.account
             from fa_category_books
             where book_type_code = h_book
             and category_id = h_category_id;
          end if;

          if (X_select_mode = fa_adjust_type_pkg.FA_AJ_CLEAR) then
              X_adj_ptr.debit_credit_flag := 'CR';
          else
              X_adj_ptr.debit_credit_flag := 'DR';
          end if;

      elsif (X_acctcode = FA_TFR_DEPRN_RSV) then

          X_adj_ptr.adjustment_type := 'RESERVE';
          X_adj_ptr.account_type := 'DEPRN_RESERVE_ACCT';


          select deprn_reserve_acct
          into X_adj_ptr.account
          from fa_category_books
          where book_type_code = h_book
          and category_id = h_category_id;

          if (X_select_mode = fa_adjust_type_pkg.FA_AJ_CLEAR) then
             X_adj_ptr.debit_credit_flag := 'DR';
          else
             X_adj_ptr.debit_credit_flag := 'CR';
          end if;
-- bonus
      elsif (X_acctcode = FA_TFR_BONUS_DEPRN_RSV) then

          X_adj_ptr.adjustment_type := 'BONUS RESERVE';
          X_adj_ptr.account_type := 'BONUS_DEPRN_RESERVE_ACCT';


          select bonus_deprn_reserve_acct
          into X_adj_ptr.account
          from fa_category_books
          where book_type_code = h_book
          and category_id = h_category_id;

          if (X_select_mode = fa_adjust_type_pkg.FA_AJ_CLEAR) then
             X_adj_ptr.debit_credit_flag := 'DR';
          else
             X_adj_ptr.debit_credit_flag := 'CR';
          end if;

      elsif (X_acctcode = FA_TFR_IMPAIRMENT_RSV) then

          X_adj_ptr.adjustment_type := 'IMPAIR RESERVE';
          X_adj_ptr.account_type := 'IMPAIR_RESERVE_ACCT';


          select impair_reserve_acct
          into X_adj_ptr.account
          from fa_category_books
          where book_type_code = h_book
          and category_id = h_category_id;

          if (X_select_mode = fa_adjust_type_pkg.FA_AJ_CLEAR) then
             X_adj_ptr.debit_credit_flag := 'DR';
          else
             X_adj_ptr.debit_credit_flag := 'CR';
          end if;

      /*Bug 6666666 : Added for SORP Compliance */
      elsif (X_acctcode = FA_CAPITAL_ADJUSTMENT) then

          X_adj_ptr.adjustment_type := 'CAPITAL ADJ';
          X_adj_ptr.account_type := 'CAPITAL_ADJ_ACCT';

          select capital_adj_acct
          into X_adj_ptr.account
          from fa_category_books
          where book_type_code = h_book
          and category_id = h_category_id;

          if (X_select_mode = fa_adjust_type_pkg.FA_AJ_CLEAR) then
             X_adj_ptr.debit_credit_flag := 'CR';
          else
             X_adj_ptr.debit_credit_flag := 'DR';
          end if;

      /*Bug 6666666 : Added for SORP Compliance */
      elsif (X_acctcode = FA_GENERAL_FUND) then

          X_adj_ptr.adjustment_type := 'GENERAL FUND';
          X_adj_ptr.account_type := 'GENERAL_FUND_ACCT';

          select general_fund_acct
          into X_adj_ptr.account
          from fa_category_books
          where book_type_code = h_book
          and category_id = h_category_id;

          if (X_select_mode = fa_adjust_type_pkg.FA_AJ_CLEAR) then
             X_adj_ptr.debit_credit_flag := 'DR';
          else
             X_adj_ptr.debit_credit_flag := 'CR';
          end if;

      elsif (X_acctcode = FA_TFR_REVAL_RSV) then

          X_adj_ptr.adjustment_type := 'REVAL RESERVE';
          X_adj_ptr.account_type := 'REVAL_RESERVE_ACCT';

          select reval_reserve_acct
          into X_adj_ptr.account
          from fa_category_books
          where book_type_code = h_book
          and category_id = h_category_id;

          if (X_select_mode = fa_adjust_type_pkg.FA_AJ_CLEAR) then
             X_adj_ptr.debit_credit_flag := 'DR';
          else
             X_adj_ptr.debit_credit_flag := 'CR';
          end if;

      end if;

      if (X_select_mode = fa_adjust_type_pkg.FA_AJ_CLEAR) then
         X_adj_ptr.source_dest_code := 'SOURCE';
      else
         X_adj_ptr.source_dest_code := 'DEST';
      end if;

      return TRUE;

  EXCEPTION
      when OTHERS then
         fa_srvr_msg.add_sql_error(calling_fn=>'FA_TRANSFER_XIT_PKG.setacct', p_log_level_rec => p_log_level_rec);
         return FALSE;

  END setacct;


--
-- FUNCTION fatsgl
--

FUNCTION fatsgl(X_adj         IN OUT NOCOPY fa_adjust_type_pkg.fa_adj_row_struct,
                X_cat_id      IN  NUMBER,
                X_asset_type  IN VARCHAR2,
                X_last_update_date  IN DATE default sysdate,
                X_last_updated_by   IN NUMBER default -1,
                X_last_update_login IN NUMBER default -1,
                X_mrc_sob_type_code IN VARCHAR2,
                X_set_of_books_id   IN NUMBER,
                p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return BOOLEAN is

  h_dpr        FA_STD_TYPES.FA_DEPRN_ROW_STRUCT;
  h_msg_name   VARCHAR2(30);
  h_status     BOOLEAN;

  h_total_cost_to_prorate  NUMBER := 0;
  h_total_rsv_to_prorate   NUMBER := 0;
  h_total_rev_to_prorate   NUMBER := 0;
  h_total_bonus_rsv_to_prorate   NUMBER := 0;
  h_total_impair_rsv_to_prorate   NUMBER := 0;

  h_total_capital_to_prorate NUMBER := 0; -- Bug 6666666 : Capital Adjustment to prorate
  h_total_general_to_prorate NUMBER := 0; -- Bug 6666666 : General Fund to prorate

  h_total_units_to_process NUMBER := 0;
  h_num_units_processed    NUMBER := 0;

  h_cost_inserted_so_far   NUMBER := 0;
  h_rsv_inserted_so_far    NUMBER := 0;
  h_rev_inserted_so_far    NUMBER := 0;
  h_bonus_rsv_inserted_so_far NUMBER := 0;
  h_impair_rsv_inserted_so_far NUMBER := 0;

  h_capital_inserted_so_far NUMBER := 0; -- Bug 6666666 : Capital Adjustment inserted so far
  h_general_inserted_so_far NUMBER := 0; -- Bug 6666666 : General Fund inserted so far

  h_term_dist_flag NUMBER;
  h_thid           NUMBER;
  h_dist_id        NUMBER;
  h_ccid           NUMBER;
  h_units_assigned NUMBER;

  l_orig_track_member_flag varchar2(1);

  ERROR_FOUND      EXCEPTION;

  -- find all distributions affected by the transfer
  CURSOR dist_cursor is

      SELECT
          DECODE(TH.TRANSACTION_HEADER_ID,
                 DH.TRANSACTION_HEADER_ID_OUT, 1,
                 DH.TRANSACTION_HEADER_ID_IN, 2,
                 3),
          TH.TRANSACTION_HEADER_ID,
          DH.DISTRIBUTION_ID,
          DH.CODE_COMBINATION_ID,
          DH.UNITS_ASSIGNED
      FROM
          FA_DISTRIBUTION_HISTORY DH,
          FA_TRANSACTION_HEADERS TH
      WHERE
          TH.TRANSACTION_HEADER_ID = X_adj.selection_thid AND
         (TH.TRANSACTION_HEADER_ID = DH.TRANSACTION_HEADER_ID_IN OR
          TH.TRANSACTION_HEADER_ID = DH.TRANSACTION_HEADER_ID_OUT)
      ORDER BY
          1,
          DH.DISTRIBUTION_ID;

  BEGIN

     l_orig_track_member_flag := X_adj.track_member_flag;

     h_msg_name := 'FA_TFR_OPEN_DIST';

     open dist_cursor;

     loop

        h_msg_name := 'FA_TFR_FETCH_DIST';

        fetch dist_cursor into
           h_term_dist_flag,
           h_thid,
           h_dist_id,
           h_ccid,
           h_units_assigned;

        exit when dist_cursor%NOTFOUND;

        h_msg_name := NULL;

        X_adj.code_combination_id := h_ccid;
        X_adj.distribution_id := h_dist_id;

        -- call the insert into fa_adjusments funtion in SINGLE mode to insert the
        -- individual fa_adjustments rows. other values already set in fautfr.

        X_adj.selection_mode := fa_adjust_type_pkg.FA_AJ_TRANSFER_SINGLE;
        X_adj.gen_ccid_flag := TRUE;

        -- will process terminated rows first.
        if (h_term_dist_flag = 1) then
            -- if terminated distribution rows

            h_total_units_to_process := h_total_units_to_process + h_units_assigned;

            -- get the amounts to insert: cost, deprn_reserve, reval_reserve
            -- by calling the query fin info funtion.

            h_dpr.asset_id := X_adj.asset_id;
            h_dpr.period_ctr := 0;
            h_dpr.book := X_adj.book_type_code;
            h_dpr.dist_id := h_dist_id;
            h_dpr.mrc_sob_type_code := X_mrc_sob_type_code;
            h_dpr.set_of_books_id := X_set_of_books_id;

            fa_query_balances_pkg.query_balances_int(
                                  X_DPR_ROW => h_dpr,
                                  X_RUN_MODE => 'STANDARD',
                                  X_DEBUG => FALSE,
                                  X_SUCCESS => h_status,
                                  X_CALLING_FN => 'FA_TRANSFER_XIT_PKG.fatsgl',
                              X_TRANSACTION_HEADER_ID => -1, p_log_level_rec => p_log_level_rec);
            if (NOT h_status) then
               raise ERROR_FOUND;
            end if;

            if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                 element => 'h_dpr.cost',
                                 value   => h_dpr.cost, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                 element => 'h_dpr.deprn_reserve',
                                 value   => h_dpr.deprn_rsv, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                 element => 'h_dpr.reval_reserve',
                                 value   => h_dpr.reval_rsv, p_log_level_rec => p_log_level_rec);
            end if;

            -- clear cost

            if (NOT setacct(X_adj_ptr => X_adj,
                            X_acctcode => FA_TFR_COST,
                            X_select_mode => fa_adjust_type_pkg.FA_AJ_CLEAR,
                            X_cat_id => X_cat_id,
                            X_asset_type => X_asset_type,
                            p_log_level_rec => p_log_level_rec)) then
                raise ERROR_FOUND;
            end if;
            X_adj.adjustment_amount := h_dpr.cost;
            X_adj.mrc_sob_type_code := X_mrc_sob_type_code;
            X_adj.track_member_flag := null;
            X_adj.set_of_books_id := X_set_of_books_id;

            if (NOT fa_ins_adjust_pkg.faxinaj(X_adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then
              if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                   element => 'X_acctcode',
                                   value   => 'FA_TFR_COST', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                   element => 'adjustment_type',
                                   value   => X_adj.adjustment_type, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                   element => 'select_mode',
                                   value   => X_adj.selection_mode, p_log_level_rec => p_log_level_rec);
              end if;
              raise ERROR_FOUND;
            end if;


            -- accumulate cost from terminated rows to redistribute to active rows.
            h_total_cost_to_prorate := h_total_cost_to_prorate +
                                       X_adj.amount_inserted;


            X_adj.track_member_flag := l_orig_track_member_flag;

            -- clear deprn_reserve

            if (NOT setacct(X_adj_ptr => X_adj,
                            X_acctcode => FA_TFR_DEPRN_RSV,
                            X_select_mode => fa_adjust_type_pkg.FA_AJ_CLEAR,
                            X_cat_id => X_cat_id,
                            X_asset_type => X_asset_type,
                            p_log_level_rec => p_log_level_rec)) then
               raise ERROR_FOUND;
            end if;
            X_adj.adjustment_amount := h_dpr.deprn_rsv;
            X_adj.mrc_sob_type_code := X_mrc_sob_type_code;
            X_adj.set_of_books_id := X_set_of_books_id;

            if (NOT fa_ins_adjust_pkg.faxinaj(X_adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then
              if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                   element => 'X_acctcode',
                                   value   => 'FA_TFR_DEPRN_RSV', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                   element => 'adjustment_type',
                                   value   => X_adj.adjustment_type, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                   element => 'select_mode',
                                   value   => X_adj.selection_mode, p_log_level_rec => p_log_level_rec);
              end if;
              raise ERROR_FOUND;
            end if;
-- accumulate deprn_reserve from terminated rows to redistribute to active rows
            h_total_rsv_to_prorate := h_total_rsv_to_prorate +
                                      X_adj.amount_inserted;

            -- clear bonus_deprn_reserve
            -- bonus: move the bonus deprn reserve if bonus reserve exist
         if nvl(h_dpr.bonus_deprn_rsv,0) <> 0 then
                       if (NOT setacct(X_adj_ptr => X_adj,
                            X_acctcode => FA_TFR_BONUS_DEPRN_RSV,
                            X_select_mode => fa_adjust_type_pkg.FA_AJ_CLEAR,
                            X_cat_id => X_cat_id,
                            X_asset_type => X_asset_type,
                            p_log_level_rec => p_log_level_rec)) then
                 raise ERROR_FOUND;
              end if;
              X_adj.adjustment_amount := h_dpr.bonus_deprn_rsv;
              X_adj.mrc_sob_type_code := X_mrc_sob_type_code;
              X_adj.set_of_books_id := X_set_of_books_id;

              if (NOT fa_ins_adjust_pkg.faxinaj(X_adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then
                if (p_log_level_rec.statement_level) then
                    fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                   element => 'X_acctcode',
                                   value   => 'FA_TFR_BONUS_DEPRN_RSV', p_log_level_rec => p_log_level_rec);
                    fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                   element => 'adjustment_type',
                                   value   => X_adj.adjustment_type, p_log_level_rec => p_log_level_rec);
                    fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                   element => 'select_mode',
                                   value   => X_adj.selection_mode, p_log_level_rec => p_log_level_rec);
                end if;
                raise ERROR_FOUND;
              end if;


-- accumulate bonus_deprn_reserve from terminated rows to redistribute to active rows
-- bonus: calculation to be checked.
-- bonus: same logic as for deprn reserve used.
              h_total_bonus_rsv_to_prorate := h_total_bonus_rsv_to_prorate +
                                      X_adj.amount_inserted;
            end if; -- end bonus rule condition

         if nvl(h_dpr.impairment_rsv,0) <> 0 then
                       if (NOT setacct(X_adj_ptr => X_adj,
                            X_acctcode => FA_TFR_IMPAIRMENT_RSV,
                            X_select_mode => fa_adjust_type_pkg.FA_AJ_CLEAR,
                            X_cat_id => X_cat_id,
                            X_asset_type => X_asset_type,
                            p_log_level_rec => p_log_level_rec)) then
                 raise ERROR_FOUND;
              end if;
              X_adj.adjustment_amount := h_dpr.impairment_rsv;
              X_adj.mrc_sob_type_code := X_mrc_sob_type_code;
              X_adj.set_of_books_id := X_set_of_books_id;

              if (NOT fa_ins_adjust_pkg.faxinaj(X_adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then
                if (p_log_level_rec.statement_level) then
                    fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                   element => 'X_acctcode',
                                   value   => 'FA_TFR_IMPAIRMENT_RSV', p_log_level_rec => p_log_level_rec);
                    fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                   element => 'adjustment_type',
                                   value   => X_adj.adjustment_type, p_log_level_rec => p_log_level_rec);
                    fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                   element => 'select_mode',
                                   value   => X_adj.selection_mode, p_log_level_rec => p_log_level_rec);
                end if;
                raise ERROR_FOUND;
              end if;

              h_total_impair_rsv_to_prorate :=
                  h_total_impair_rsv_to_prorate + X_adj.amount_inserted;

            end if;

         -- Bug 6666666
         -- Capital Adjustment
         if nvl(h_dpr.capital_adjustment,0) <> 0 then
                       if (NOT setacct(X_adj_ptr => X_adj,
                            X_acctcode => FA_CAPITAL_ADJUSTMENT,
                            X_select_mode => fa_adjust_type_pkg.FA_AJ_CLEAR,
                            X_cat_id => X_cat_id,
                            X_asset_type => X_asset_type,
                            p_log_level_rec => p_log_level_rec)) then
                 raise ERROR_FOUND;
              end if;
              X_adj.adjustment_amount := h_dpr.capital_adjustment;
              X_adj.mrc_sob_type_code := X_mrc_sob_type_code;
              X_adj.set_of_books_id := X_set_of_books_id;

              if (NOT fa_ins_adjust_pkg.faxinaj(X_adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then
                if (p_log_level_rec.statement_level) then
                    fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                   element => 'X_acctcode',
                                   value   => 'FA_CAPITAL_ADJUSTMENT', p_log_level_rec => p_log_level_rec);
                    fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                   element => 'adjustment_type',
                                   value   => X_adj.adjustment_type, p_log_level_rec => p_log_level_rec);
                    fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                   element => 'select_mode',
                                   value   => X_adj.selection_mode, p_log_level_rec => p_log_level_rec);
                end if;
                raise ERROR_FOUND;
              end if;

              h_total_capital_to_prorate :=
                  h_total_capital_to_prorate + X_adj.amount_inserted;

            end if;

         -- Bug 6666666
         -- General Fund
         if nvl(h_dpr.general_fund,0) <> 0 then
                       if (NOT setacct(X_adj_ptr => X_adj,
                            X_acctcode => FA_GENERAL_FUND,
                            X_select_mode => fa_adjust_type_pkg.FA_AJ_CLEAR,
                            X_cat_id => X_cat_id,
                            X_asset_type => X_asset_type,
                            p_log_level_rec => p_log_level_rec)) then
                 raise ERROR_FOUND;
              end if;
              X_adj.adjustment_amount := h_dpr.general_fund;
              X_adj.mrc_sob_type_code := X_mrc_sob_type_code;
              X_adj.set_of_books_id := X_set_of_books_id;

              if (NOT fa_ins_adjust_pkg.faxinaj(X_adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then
                if (p_log_level_rec.statement_level) then
                    fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                   element => 'X_acctcode',
                                   value   => 'FA_GENERAL_FUND', p_log_level_rec => p_log_level_rec);
                    fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                   element => 'adjustment_type',
                                   value   => X_adj.adjustment_type, p_log_level_rec => p_log_level_rec);
                    fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                   element => 'select_mode',
                                   value   => X_adj.selection_mode, p_log_level_rec => p_log_level_rec);
                end if;
                raise ERROR_FOUND;
              end if;

              h_total_general_to_prorate :=
                  h_total_general_to_prorate + X_adj.amount_inserted;

            end if;


            -- clear reval reserve
            if (nvl(h_dpr.reval_rsv,0) <> 0) then
                X_adj.adjustment_amount := h_dpr.reval_rsv;
                X_adj.mrc_sob_type_code := X_mrc_sob_type_code;
                X_adj.set_of_books_id := X_set_of_books_id;

                if (NOT setacct(X_adj_ptr => X_adj,
                                X_acctcode => FA_TFR_REVAL_RSV,
                                X_select_mode => fa_adjust_type_pkg.FA_AJ_CLEAR,
                                X_cat_id => X_cat_id,
                                X_asset_type => X_asset_type,
                                p_log_level_rec => p_log_level_rec)) then
                    raise ERROR_FOUND;
                end if;

                if (NOT fa_ins_adjust_pkg.faxinaj(X_adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then
                  if (p_log_level_rec.statement_level) then
                      fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                      element => 'X_acctcode',
                                      value   => 'FA_TFR_REVAL_RSV', p_log_level_rec => p_log_level_rec);
                      fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                      element => 'adjustment_type',
                                      value   => X_adj.adjustment_type, p_log_level_rec => p_log_level_rec);
                      fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                       element => 'select_mode',
                                       value   => X_adj.selection_mode, p_log_level_rec => p_log_level_rec);
                  end if;
                  raise ERROR_FOUND;
                end if;


                -- accumulate reval reserve
                h_total_rev_to_prorate := h_total_rev_to_prorate +
                                          X_adj.amount_inserted;
            end if;

        elsif (h_term_dist_flag = 2) then
            -- if active distribution rows

            h_num_units_processed := h_num_units_processed + h_units_assigned;

            if (h_num_units_processed < h_total_units_to_process) then
              -- if not the last distribution


              X_adj.track_member_flag := null;

              -- transfer cost
              if (NOT setacct(X_adj_ptr => X_adj,
                                X_acctcode => FA_TFR_COST,
                                X_select_mode => fa_adjust_type_pkg.FA_AJ_ACTIVE,
                                X_cat_id => X_cat_id,
                                X_asset_type => X_asset_type,
                                p_log_level_rec => p_log_level_rec)) then
                    raise ERROR_FOUND;
                end if;

                X_adj.adjustment_amount := (h_total_cost_to_prorate *
                                            h_units_assigned) /
                                            h_total_units_to_process;

                if (NOT fa_utils_pkg.faxrnd(X_amount => X_adj.adjustment_amount,
                                            X_book => X_adj.book_type_code,
                                            X_set_of_books_id => X_adj.set_of_books_id,
                                            p_log_level_rec => p_log_level_rec)) then
                    raise ERROR_FOUND;
                end if;

                h_cost_inserted_so_far := h_cost_inserted_so_far +
                                          X_adj.adjustment_amount;

                X_adj.mrc_sob_type_code := X_mrc_sob_type_code;
                X_adj.set_of_books_id := X_set_of_books_id;

                if (NOT fa_ins_adjust_pkg.faxinaj(X_adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then
                  if (p_log_level_rec.statement_level) then
                      fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                       element => 'X_acctcode',
                                       value   => 'FA_TFR_COST', p_log_level_rec => p_log_level_rec);
                      fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                       element => 'adjustment_type',
                                       value   => X_adj.adjustment_type, p_log_level_rec => p_log_level_rec);
                      fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                       element => 'select_mode',
                                       value   => X_adj.selection_mode, p_log_level_rec => p_log_level_rec);
                  end if;
                  raise ERROR_FOUND;
                end if;


               X_adj.track_member_flag := l_orig_track_member_flag;

               -- transfer deprn reserve

               if (NOT setacct(X_adj_ptr => X_adj,
                                X_acctcode => FA_TFR_DEPRN_RSV,
                                X_select_mode => fa_adjust_type_pkg.FA_AJ_ACTIVE,
                                X_cat_id => X_cat_id,
                                X_asset_type => X_asset_type,
                                p_log_level_rec => p_log_level_rec)) then
                    raise ERROR_FOUND;
                end if;

                X_adj.adjustment_amount := (h_total_rsv_to_prorate *
                                            h_units_assigned) /
                                            h_total_units_to_process;
                if (NOT fa_utils_pkg.faxrnd(X_amount=>X_adj.adjustment_amount,
                                            X_book  => X_adj.book_type_code,
                                            X_set_of_books_id => X_adj.set_of_books_id,
                                            p_log_level_rec => p_log_level_rec)) then
                    raise ERROR_FOUND;
                end if;
                h_rsv_inserted_so_far := h_rsv_inserted_so_far +
                                         X_adj.adjustment_amount;

                X_adj.mrc_sob_type_code := X_mrc_sob_type_code;
                X_adj.set_of_books_id := X_set_of_books_id;

                if (NOT fa_ins_adjust_pkg.faxinaj(X_adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then

                   if (p_log_level_rec.statement_level) then
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                        element => 'X_acctcode',
                                        value   => 'FA_TFR_DEPRN_RSV', p_log_level_rec => p_log_level_rec);
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                        element => 'adjustment_type',
                                        value   => X_adj.adjustment_type, p_log_level_rec => p_log_level_rec);
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                        element => 'select_mode',
                                        value   => X_adj.selection_mode, p_log_level_rec => p_log_level_rec);
                   end if;
                   raise ERROR_FOUND;
                end if;


               -- transfer bonus deprn reserve
--bonus: adjustment_amount must be checked.
--bonus: h_total_bonus_rsv_to_prorate is created.
-- bonus:same logic as for deprn_reserve used.
-- bonus: move the bonus deprn reserve if bonus reserve exist
            if nvl(h_dpr.bonus_deprn_rsv,0) <> 0 then
                 if (NOT setacct(X_adj_ptr => X_adj,
                                X_acctcode => FA_TFR_BONUS_DEPRN_RSV,
                                X_select_mode => fa_adjust_type_pkg.FA_AJ_ACTIVE,
                                X_cat_id => X_cat_id,
                                X_asset_type => X_asset_type,
                                p_log_level_rec => p_log_level_rec)) then
                      raise ERROR_FOUND;
                  end if;

                  X_adj.adjustment_amount := (h_total_bonus_rsv_to_prorate *
                                            h_units_assigned) /
                                            h_total_units_to_process;
                  if (NOT fa_utils_pkg.faxrnd(X_amount=>X_adj.adjustment_amount,
                                            X_book  => X_adj.book_type_code,
                                            X_set_of_books_id => X_adj.set_of_books_id,
                                            p_log_level_rec => p_log_level_rec)) then
                    raise ERROR_FOUND;
                  end if;
                  h_bonus_rsv_inserted_so_far := h_bonus_rsv_inserted_so_far +
                                         X_adj.adjustment_amount;

                  X_adj.mrc_sob_type_code := X_mrc_sob_type_code;
                  X_adj.set_of_books_id := X_set_of_books_id;

                  if (NOT fa_ins_adjust_pkg.faxinaj(X_adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then

                     if (p_log_level_rec.statement_level) then
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                        element => 'X_acctcode',
                                        value   => 'FA_TFR_BONUS_DEPRN_RSV', p_log_level_rec => p_log_level_rec);
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                        element => 'adjustment_type',
                                        value   => X_adj.adjustment_type, p_log_level_rec => p_log_level_rec);
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                        element => 'select_mode',
                                        value   => X_adj.selection_mode, p_log_level_rec => p_log_level_rec);
                     end if;
                     raise ERROR_FOUND;
                  end if;
             end if;  -- end bonus rule condition

            if nvl(h_dpr.impairment_rsv,0) <> 0 then
                 if (NOT setacct(X_adj_ptr => X_adj,
                                X_acctcode => FA_TFR_IMPAIRMENT_RSV,
                                X_select_mode => fa_adjust_type_pkg.FA_AJ_ACTIVE
,
                                X_cat_id => X_cat_id,
                                X_asset_type => X_asset_type,
                                p_log_level_rec => p_log_level_rec)) then
                      raise ERROR_FOUND;
                  end if;

                  X_adj.adjustment_amount :=
                                   (h_total_impair_rsv_to_prorate *
                                            h_units_assigned) /
                                            h_total_units_to_process;
                  if (NOT fa_utils_pkg.faxrnd(X_amount=>X_adj.adjustment_amount,
                                       X_book  => X_adj.book_type_code,
                                       X_set_of_books_id => X_adj.set_of_books_id,
                                       p_log_level_rec => p_log_level_rec)) then
                    raise ERROR_FOUND;
                  end if;
                  h_impair_rsv_inserted_so_far :=
                    h_impair_rsv_inserted_so_far + X_adj.adjustment_amount;

                  X_adj.mrc_sob_type_code := X_mrc_sob_type_code;
                  X_adj.set_of_books_id := X_set_of_books_id;

                  if (NOT fa_ins_adjust_pkg.faxinaj(X_adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then

                     if (p_log_level_rec.statement_level) then
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                        element => 'X_acctcode',
                                        value   => 'FA_TFR_IMPAIRMENT_RSV', p_log_level_rec => p_log_level_rec);
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                        element => 'adjustment_type',
                                        value   => X_adj.adjustment_type, p_log_level_rec => p_log_level_rec);
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                        element => 'select_mode',
                                        value   => X_adj.selection_mode, p_log_level_rec => p_log_level_rec);
                     end if;
                     raise ERROR_FOUND;
                  end if;
             end if;

            /* Bug 666666 : SORP Compliance */
            /* Capital Adjustment */
            if nvl(h_dpr.capital_adjustment,0) <> 0 then
                 if (NOT setacct(X_adj_ptr => X_adj,
                                X_acctcode => FA_CAPITAL_ADJUSTMENT,
                                X_select_mode => fa_adjust_type_pkg.FA_AJ_ACTIVE
,
                                X_cat_id => X_cat_id,
                                X_asset_type => X_asset_type,
                                p_log_level_rec => p_log_level_rec)) then
                      raise ERROR_FOUND;
                  end if;

                  X_adj.adjustment_amount :=
                                   (h_total_capital_to_prorate *
                                            h_units_assigned) /
                                            h_total_units_to_process;
                  if (NOT fa_utils_pkg.faxrnd(X_amount=>X_adj.adjustment_amount,
                                       X_book  => X_adj.book_type_code,
                                       X_set_of_books_id => X_adj.set_of_books_id,
                                       p_log_level_rec => p_log_level_rec)) then
                    raise ERROR_FOUND;
                  end if;
                  h_capital_inserted_so_far :=
                    h_capital_inserted_so_far + X_adj.adjustment_amount;

                  X_adj.mrc_sob_type_code := X_mrc_sob_type_code;
                  X_adj.set_of_books_id := X_set_of_books_id;

                  if (NOT fa_ins_adjust_pkg.faxinaj(X_adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then

                     if (p_log_level_rec.statement_level) then
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                        element => 'X_acctcode',
                                        value   => 'FA_CAPITAL_ADJUSTMENT', p_log_level_rec => p_log_level_rec);
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                        element => 'adjustment_type',
                                        value   => X_adj.adjustment_type, p_log_level_rec => p_log_level_rec);
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                        element => 'select_mode',
                                        value   => X_adj.selection_mode, p_log_level_rec => p_log_level_rec);
                     end if;
                     raise ERROR_FOUND;
                  end if;
             end if;


            /* Bug 666666 : SORP Compliance */
            /* General Fund */
            if nvl(h_dpr.general_fund,0) <> 0 then
                 if (NOT setacct(X_adj_ptr => X_adj,
                                X_acctcode => FA_GENERAL_FUND,
                                X_select_mode => fa_adjust_type_pkg.FA_AJ_ACTIVE
,
                                X_cat_id => X_cat_id,
                                X_asset_type => X_asset_type,
                                p_log_level_rec => p_log_level_rec)) then
                      raise ERROR_FOUND;
                  end if;

                  X_adj.adjustment_amount :=
                                   (h_total_general_to_prorate *
                                            h_units_assigned) /
                                            h_total_units_to_process;
                  if (NOT fa_utils_pkg.faxrnd(X_amount=>X_adj.adjustment_amount,
                                       X_book  => X_adj.book_type_code,
                                       X_set_of_books_id => X_adj.set_of_books_id,

                                       p_log_level_rec => p_log_level_rec)) then
                    raise ERROR_FOUND;
                  end if;
                  h_general_inserted_so_far :=
                    h_general_inserted_so_far + X_adj.adjustment_amount;

                  X_adj.mrc_sob_type_code := X_mrc_sob_type_code;
                  X_adj.set_of_books_id := X_set_of_books_id;

                  if (NOT fa_ins_adjust_pkg.faxinaj(X_adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then

                     if (p_log_level_rec.statement_level) then
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                        element => 'X_acctcode',
                                        value   => 'FA_GENERAL_FUND', p_log_level_rec => p_log_level_rec);
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                        element => 'adjustment_type',
                                        value   => X_adj.adjustment_type, p_log_level_rec => p_log_level_rec);
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                        element => 'select_mode',
                                        value   => X_adj.selection_mode, p_log_level_rec => p_log_level_rec);
                     end if;
                     raise ERROR_FOUND;
                  end if;
             end if;

                -- transfer reval reserve

                if (nvl(h_total_rev_to_prorate,0) <> 0) then

                    if (NOT setacct(X_adj_ptr => X_adj,
                                    X_acctcode => FA_TFR_REVAL_RSV,
                                    X_select_mode => fa_adjust_type_pkg.FA_AJ_ACTIVE,
                                    X_cat_id => X_cat_id,
                                    X_asset_type => X_asset_type,
                                    p_log_level_rec => p_log_level_rec)) then
                        raise ERROR_FOUND;
                    end if;
                    X_adj.adjustment_amount := (h_total_rev_to_prorate *
                                                h_units_assigned) /
                                                h_total_units_to_process;
                    if (NOT fa_utils_pkg.faxrnd(X_amount => X_adj.adjustment_amount,
                                                X_book   => X_adj.book_type_code,
                                                X_set_of_books_id => X_adj.set_of_books_id,
p_log_level_rec => p_log_level_rec)) then
                        raise ERROR_FOUND;
                    end if;
                    h_rev_inserted_so_far := h_rev_inserted_so_far +
                                             X_adj.adjustment_amount;

                    X_adj.mrc_sob_type_code := X_mrc_sob_type_code;
                    X_adj.set_of_books_id := X_set_of_books_id;

                    if (NOT fa_ins_adjust_pkg.faxinaj(X_adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then
                      if (p_log_level_rec.statement_level) then
                        fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                         element => 'X_acctcode',
                                         value   => 'FA_TFR_REVAL_RSV', p_log_level_rec => p_log_level_rec);
                        fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                         element => 'adjustment_type',
                                         value   => X_adj.adjustment_type, p_log_level_rec => p_log_level_rec);
                        fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                         element => 'select_mode',
                                         value   => X_adj.selection_mode, p_log_level_rec => p_log_level_rec);
                     end if;
                     raise ERROR_FOUND;
                    end if;

                end if;

            elsif (h_num_units_processed = h_total_units_to_process) then
              -- if last active distribution row

              -- move cost

              X_adj.track_member_flag := null;

              if (NOT setacct(X_adj_ptr => X_adj,
                                X_acctcode => FA_TFR_COST,
                                X_select_mode => fa_adjust_type_pkg.FA_AJ_ACTIVE,
                                X_cat_id => X_cat_id,
                                X_asset_type => X_asset_type,
                                p_log_level_rec => p_log_level_rec)) then
                    raise ERROR_FOUND;
                end if;

                -- assign remaining penny to last distribution
                X_adj.adjustment_amount := h_total_cost_to_prorate -
                                           h_cost_inserted_so_far;

                X_adj.mrc_sob_type_code := X_mrc_sob_type_code;
                X_adj.set_of_books_id := X_set_of_books_id;

                if (NOT fa_ins_adjust_pkg.faxinaj(X_adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then
                  if (p_log_level_rec.statement_level) then
                      fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                       element => 'X_acctcode',
                                       value   => 'FA_TFR_COST', p_log_level_rec => p_log_level_rec);
                      fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                       element => 'adjustment_type',
                                       value   => X_adj.adjustment_type, p_log_level_rec => p_log_level_rec);
                      fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                       element => 'select_mode',
                                       value   => X_adj.selection_mode, p_log_level_rec => p_log_level_rec);
                  end if;
                    raise ERROR_FOUND;
                end if;

                X_adj.flush_adj_flag := TRUE;  -- flush to db
                X_adj.track_member_flag := l_orig_track_member_flag;

                -- move deprn reserve
                if (NOT setacct(X_adj_ptr => X_adj,
                                X_acctcode => FA_TFR_DEPRN_RSV,
                                X_select_mode => fa_adjust_type_pkg.FA_AJ_ACTIVE,
                                X_cat_id => X_cat_id,
                                X_asset_type => X_asset_type,
                                p_log_level_rec => p_log_level_rec)) then
                    raise ERROR_FOUND;
                end if;
                X_adj.adjustment_amount := h_total_rsv_to_prorate -
                                           h_rsv_inserted_so_far;

                X_adj.mrc_sob_type_code := X_mrc_sob_type_code;
                X_adj.set_of_books_id := X_set_of_books_id;

                if (NOT fa_ins_adjust_pkg.faxinaj(X_adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then
                  if (p_log_level_rec.statement_level) then
                      fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                       element => 'X_acctcode',
                                       value   => 'FA_TFR_DEPRN_RSV', p_log_level_rec => p_log_level_rec);
                      fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                       element => 'adjustment_type',
                                       value   => X_adj.adjustment_type, p_log_level_rec => p_log_level_rec);
                      fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                       element => 'select_mode',
                                       value   => X_adj.selection_mode, p_log_level_rec => p_log_level_rec);
                  end if;
                    raise ERROR_FOUND;
                end if;

                -- move bonus deprn reserve
-- bonus: same logic as for deprn_reserve used.
-- bonus: move the bonus deprn reserve if bonus reserve exist
            if nvl(h_dpr.bonus_deprn_rsv,0) <> 0 then
                  if (NOT setacct(X_adj_ptr => X_adj,
                                X_acctcode => FA_TFR_BONUS_DEPRN_RSV,
                                X_select_mode => fa_adjust_type_pkg.FA_AJ_ACTIVE,
                                X_cat_id => X_cat_id,
                                X_asset_type => X_asset_type,
                                p_log_level_rec => p_log_level_rec)) then
                      raise ERROR_FOUND;
                  end if;
                  X_adj.adjustment_amount := h_total_bonus_rsv_to_prorate -
                                           h_bonus_rsv_inserted_so_far;

                  X_adj.mrc_sob_type_code := X_mrc_sob_type_code;
                  X_adj.set_of_books_id := X_set_of_books_id;

                  if (NOT fa_ins_adjust_pkg.faxinaj(X_adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then
                    if (p_log_level_rec.statement_level) then
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                       element => 'X_acctcode',
                                       value   => 'FA_TFR_BONUS_DEPRN_RSV', p_log_level_rec => p_log_level_rec);
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                       element => 'adjustment_type',
                                       value   => X_adj.adjustment_type, p_log_level_rec => p_log_level_rec);
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                       element => 'select_mode',
                                       value   => X_adj.selection_mode, p_log_level_rec => p_log_level_rec);
                    end if;
                    raise ERROR_FOUND;
               end if;
          end if;

            if nvl(h_dpr.impairment_rsv,0) <> 0 then
                  if (NOT setacct(X_adj_ptr => X_adj,
                                X_acctcode => FA_TFR_IMPAIRMENT_RSV,
                                X_select_mode => fa_adjust_type_pkg.FA_AJ_ACTIVE,
                                X_cat_id => X_cat_id,
                                X_asset_type => X_asset_type,
                                p_log_level_rec => p_log_level_rec)) then
                      raise ERROR_FOUND;
                  end if;
                  X_adj.adjustment_amount := h_total_impair_rsv_to_prorate -
                                             h_impair_rsv_inserted_so_far;

                  X_adj.mrc_sob_type_code := X_mrc_sob_type_code;
                  X_adj.set_of_books_id := X_set_of_books_id;

                  if (NOT fa_ins_adjust_pkg.faxinaj(X_adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then
                    if (p_log_level_rec.statement_level) then
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                       element => 'X_acctcode',
                                       value   => 'FA_TFR_IMPAIRMENT_RSV', p_log_level_rec => p_log_level_rec);
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                       element => 'adjustment_type',
                                       value   => X_adj.adjustment_type, p_log_level_rec => p_log_level_rec);
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                       element => 'select_mode',
                                       value   => X_adj.selection_mode, p_log_level_rec => p_log_level_rec);
                    end if;
                    raise ERROR_FOUND;
               end if;
          end if;

          /* Bug 6666666 : SORP Complaince */
          /* Capital Adjustment */
            if nvl(h_dpr.capital_adjustment,0) <> 0 then
                  if (NOT setacct(X_adj_ptr => X_adj,
                                X_acctcode => FA_CAPITAL_ADJUSTMENT,
                                X_select_mode => fa_adjust_type_pkg.FA_AJ_ACTIVE,
                                X_cat_id => X_cat_id,
                                X_asset_type => X_asset_type,
                                p_log_level_rec => p_log_level_rec)) then
                      raise ERROR_FOUND;
                  end if;
                  X_adj.adjustment_amount := h_total_capital_to_prorate -
                                             h_capital_inserted_so_far;

                  X_adj.mrc_sob_type_code := X_mrc_sob_type_code;
                  X_adj.set_of_books_id := X_set_of_books_id;

                  if (NOT fa_ins_adjust_pkg.faxinaj(X_adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then
                    if (p_log_level_rec.statement_level) then
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                       element => 'X_acctcode',
                                       value   => 'FA_CAPITAL_ADJUSTMENT', p_log_level_rec => p_log_level_rec);
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                       element => 'adjustment_type',
                                       value   => X_adj.adjustment_type, p_log_level_rec => p_log_level_rec);
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                       element => 'select_mode',
                                       value   => X_adj.selection_mode, p_log_level_rec => p_log_level_rec);
                    end if;
                    raise ERROR_FOUND;
               end if;
          end if;


          /* Bug 6666666 : SORP Complaince */
          /* General Fund */
            if nvl(h_dpr.general_fund,0) <> 0 then
                  if (NOT setacct(X_adj_ptr => X_adj,
                                X_acctcode => FA_GENERAL_FUND,
                                X_select_mode => fa_adjust_type_pkg.FA_AJ_ACTIVE,
                                X_cat_id => X_cat_id,
                                X_asset_type => X_asset_type,
                                p_log_level_rec => p_log_level_rec)) then
                      raise ERROR_FOUND;
                  end if;
                  X_adj.adjustment_amount := h_total_general_to_prorate -
                                             h_general_inserted_so_far;

                  X_adj.mrc_sob_type_code := X_mrc_sob_type_code;
                  X_adj.set_of_books_id := X_set_of_books_id;

                  if (NOT fa_ins_adjust_pkg.faxinaj(X_adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then
                    if (p_log_level_rec.statement_level) then
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                       element => 'X_acctcode',
                                       value   => 'FA_GENERAL_FUND', p_log_level_rec => p_log_level_rec);
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                       element => 'adjustment_type',
                                       value   => X_adj.adjustment_type, p_log_level_rec => p_log_level_rec);
                       fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                       element => 'select_mode',
                                       value   => X_adj.selection_mode, p_log_level_rec => p_log_level_rec);
                    end if;
                    raise ERROR_FOUND;
               end if;
          end if;

                -- move reval reserve

                if (nvl(h_total_rev_to_prorate,0) <> 0) then

                    X_adj.flush_adj_flag := TRUE;  -- flush to db

                    if (NOT setacct(X_adj_ptr => X_adj,
                                    X_acctcode => FA_TFR_REVAL_RSV,
                                    X_select_mode => fa_adjust_type_pkg.FA_AJ_ACTIVE,
                                    X_cat_id => X_cat_id,
                                    X_asset_type => X_asset_type,
                                    p_log_level_rec => p_log_level_rec)) then
                        raise ERROR_FOUND;
                    end if;
                    X_adj.adjustment_amount := h_total_rev_to_prorate -
                                               h_rev_inserted_so_far;

                    X_adj.mrc_sob_type_code := X_mrc_sob_type_code;
                    X_adj.set_of_books_id := X_set_of_books_id;

                    if (NOT fa_ins_adjust_pkg.faxinaj(X_adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then
                      if (p_log_level_rec.statement_level) then
                         fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                          element => 'X_acctcode',
                                          value   => 'FA_TFR_REVAL_RSV', p_log_level_rec => p_log_level_rec);
                         fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                          element => 'adjustment_type',
                                          value   => X_adj.adjustment_type, p_log_level_rec => p_log_level_rec);
                         fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                          element => 'select_mode',
                                          value   => X_adj.selection_mode, p_log_level_rec => p_log_level_rec);
                      end if;
                      raise ERROR_FOUND;
                    end if;
                end if;
            else
                h_msg_name := 'FA_TFR_INTERCO_UNBAL';
                raise ERROR_FOUND;
            end if;
        else
            h_msg_name := 'FA_TFR_INVALID_DIST_FLAG';
            raise ERROR_FOUND;
        end if;

    end loop;

    h_msg_name := 'FA_TFR_CLOSE_DIST_CURSOR';
    close dist_cursor;

    return TRUE;

  EXCEPTION
    when ERROR_FOUND then
        fa_srvr_msg.add_message(calling_fn => 'FA_TRANSFER_XIT_PKG.fatsgl',
                                name => h_msg_name, p_log_level_rec => p_log_level_rec);
        close dist_cursor;
        return FALSE;

    when OTHERS then
        fa_srvr_msg.add_sql_error(calling_fn=> 'FA_TRANSFER_XIT_PKG.fatsgl', p_log_level_rec => p_log_level_rec);
        close dist_cursor;
        return FALSE;

  END fatsgl;



FUNCTION faucper(X_asset_id NUMBER,
                 X_is_prior_period IN OUT NOCOPY BOOLEAN,
                 X_book VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)         RETURN BOOLEAN IS

        h_is_prior_period       NUMBER :=0;
        h_book_spec             NUMBER :=0;
    BEGIN

        IF (X_book IS NULL) THEN
            h_book_spec := 0 ;
        ELSE
            h_book_spec := 1;
        END IF;


        SELECT distinct 1
        INTO
            h_is_prior_period
        FROM
            FA_DEPRN_PERIODS DP_NOW,
            FA_DEPRN_PERIODS DP,
            FA_BOOK_CONTROLS BC,
            FA_TRANSACTION_HEADERS TH
        WHERE
            TH.ASSET_ID = X_asset_id AND
            TH.TRANSACTION_TYPE_CODE = DECODE(BC.BOOK_CLASS,'CORPORATE',
                                              'TRANSFER IN','ADDITION') AND
            TH.BOOK_TYPE_CODE = BC.BOOK_TYPE_CODE AND
            BC.BOOK_TYPE_CODE = DECODE(h_book_spec, 1,
                                       X_book,
                                       TH.BOOK_TYPE_CODE) AND
            TH.DATE_EFFECTIVE BETWEEN
                DP.PERIOD_OPEN_DATE AND
                NVL(DP.PERIOD_CLOSE_DATE, SYSDATE)
        AND
            DP.BOOK_TYPE_CODE = TH.BOOK_TYPE_CODE AND
            DP.PERIOD_COUNTER < DP_NOW.PERIOD_COUNTER AND
            DP_NOW.BOOK_TYPE_CODE = TH.BOOK_TYPE_CODE AND
            DP_NOW.PERIOD_CLOSE_DATE IS NULL;

        if h_is_prior_period = 1 then
           X_is_prior_period := TRUE ;
        else
           X_is_prior_period := FALSE;
        end if;

        RETURN (TRUE);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            X_is_prior_period := FALSE;
            RETURN (TRUE);

        WHEN OTHERS THEN
            FA_SRVR_MSG.ADD_SQL_ERROR (
                        CALLING_FN => 'FA_TRANSFER_XIT_PKG.faucper', p_log_level_rec => p_log_level_rec);

            RETURN (FALSE);

    END faucper;


/*===========================================================================
 |
 | NAME:         faumvexp() - FA Move Expense
 |
 | DESCRIPTION:  Move catchup expense like amort adj expense
 |               to a new distribution for reclass in period of addition...
 |
 |               Even though the main select in fautfr is called in period of addition
 |               it doesn't return any rows to process.
 |               Using this new function, we will be processing
 |               the movement of any catchup expenses
 |               from the old dist to the new dist.
 |
 |
 | RETURNS:    TRUE, on successful completion
 |             FALSE, on error condition
 |
 |   History
 |        16-Aug-2005           YYOON              Created
 |
============================================================================*/

FUNCTION faumvexp(X_asset_id 		NUMBER
                 ,X_book_type_code 	VARCHAR2
                 ,X_th_id 		NUMBER
                 ,X_to_category_id	NUMBER
                 ,X_exp_moved 		OUT NOCOPY BOOLEAN
		 ,X_last_update_date 	DATE
                 ,X_last_updated_by	NUMBER
                 ,X_last_update_login	NUMBER
                 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS


   l_set_of_books_id           number;

  CURSOR n_sob_id (p_psob_id IN NUMBER,
                   p_book_type_code IN VARCHAR2) is
  SELECT p_psob_id AS sob_id,
         1 AS index_id
    FROM dual
   UNION
  SELECT set_of_books_id AS sob_id,
         2 AS index_id
    FROM fa_mc_book_controls
   WHERE book_type_code = p_book_type_code
     AND primary_set_of_books_id = p_psob_id
     AND enabled_flag = 'Y'
   ORDER BY 2;


  CURSOR c_sum_exp (p_asset_id       number
               ,p_book_type_code varchar
               ,p_pc             number
               ,p_thid           number
               ) IS
    select adj.adjustment_type, max('DR'),
           sum(decode(adj.debit_credit_flag,'DR', adj.adjustment_amount,
               -adj.adjustment_amount)) adjustment_amount,
           sum(decode(adj.debit_credit_flag,'DR', adj.annualized_adjustment,
               -adj.annualized_adjustment)) annualized_adjustment,
           max(adj.track_member_flag) -- Bug7461343
    from fa_adjustments adj
        ,fa_additions_b ad
        ,fa_distribution_history fad
    where adj.asset_id = p_asset_id
      and adj.book_type_code = p_book_type_code
      and adj.source_type_code = 'DEPRECIATION'
      and adj.adjustment_type in ('EXPENSE', 'BONUS EXPENSE', 'IMPAIR EXPENSE')
      and adj.period_counter_created = p_pc
      and ad.asset_id = adj.asset_id
      and fad.asset_id = adj.asset_id
      and fad.book_type_code = adj.book_type_code
      and fad.distribution_id = adj.distribution_id
      and fad.transaction_header_id_out = p_thid
    group by adj.adjustment_type;

  CURSOR c_sum_mrc_exp (p_asset_id       number
               ,p_book_type_code varchar
               ,p_pc             number
               ,p_thid           number
               ) IS
    select adj.adjustment_type, max('DR'),
           sum(decode(adj.debit_credit_flag,'DR', adj.adjustment_amount,
               -adj.adjustment_amount)) adjustment_amount,
           sum(decode(adj.debit_credit_flag,'DR', adj.annualized_adjustment,
               -adj.annualized_adjustment)) annualized_adjustment,
           max(adj.track_member_flag) -- Bug7461343
    from fa_mc_adjustments adj
        ,fa_additions_b ad
        ,fa_distribution_history fad
    where adj.asset_id = p_asset_id
      and adj.book_type_code = p_book_type_code
      and adj.source_type_code = 'DEPRECIATION'
      and adj.adjustment_type in ('EXPENSE', 'BONUS EXPENSE', 'IMPAIR EXPENSE')
      and adj.period_counter_created = p_pc
      and adj.set_of_books_id = l_set_of_books_id
      and ad.asset_id = adj.asset_id
      and fad.asset_id = adj.asset_id
      and fad.book_type_code = adj.book_type_code
      and fad.distribution_id = adj.distribution_id
      and fad.transaction_header_id_out = p_thid
    group by adj.adjustment_type;

  CURSOR c_new_dists (p_thid number) IS
    select dh.distribution_id, dh.code_combination_id, dh.units_assigned
    from fa_distribution_history dh
    where dh.transaction_header_id_in = p_thid
      and dh.date_ineffective is null
    order by dh.distribution_id;

  CURSOR c_sum_dists (p_thid number) IS
    select sum(dh.units_assigned)
    from fa_distribution_history dh
    where dh.transaction_header_id_in = p_thid;

    ERROR_FOUND     EXCEPTION;


    l_adj                  	fa_adjust_type_pkg.fa_adj_row_struct;

    l_pc		  	number(15);
    l_primary_sob_id  		number(15);
    l_mrc_sob_type_code 	varchar2(1);
    l_deprn_exp_acct 		varchar2(25);
    l_bonus_deprn_exp_acct 	varchar2(25);
    l_impairment_exp_acct       varchar2(25);

    l_adj_type			varchar2(15);
    l_dr_cr_flag		varchar2(2);
    l_adj_amount		number;
    l_annualized_adj_amount	number;
    l_current_units		number;
    l_sum_units_assigned	number;
    l_track_member_flag         varchar2(1); -- Bug7461343

    l_new_dist_id		number(15);
    l_new_ccid			number(15);


    BEGIN

        -- h_book_class := fa_cache_pkg.fazcbc_record.book_class;
        l_primary_sob_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

        for c_rec in n_sob_id(l_primary_sob_id, X_book_type_code) loop

          if c_rec.index_id = 1 then
             l_mrc_sob_type_code := 'P';
          else
             l_mrc_sob_type_code := 'R';
          end if;

          l_set_of_books_id := c_rec.sob_id;

          begin

            if (l_mrc_sob_type_code='R') then

              select ds.period_counter + 1
              into l_pc
              from fa_mc_deprn_summary ds
              where ds.asset_id = X_asset_id
                and ds.book_type_code = X_book_type_code
                and ds.deprn_source_code = 'BOOKS'
                and ds.set_of_books_id = l_set_of_books_id;

            else

              select ds.period_counter + 1
              into l_pc
              from fa_deprn_summary ds
              where ds.asset_id = X_asset_id
                and ds.book_type_code = X_book_type_code
                and ds.deprn_source_code = 'BOOKS';

            end if;


            select DEPRN_EXPENSE_ACCT,
                   BONUS_DEPRN_EXPENSE_ACCT,
                   IMPAIR_EXPENSE_ACCT
            into l_deprn_exp_acct,
                 l_bonus_deprn_exp_acct,
                 l_impairment_exp_acct
            from fa_category_books
            where book_type_code = X_book_type_code
              and category_id = X_to_category_id;

          exception
            when others then raise no_data_found;
          end;



          if (l_mrc_sob_type_code='R') then
             open c_sum_mrc_exp(X_asset_id
                       ,X_book_type_code
                       ,l_pc
                       ,X_th_id
                       );
          else
             open c_sum_exp(X_asset_id
                        ,X_book_type_code
                        ,l_pc
                        ,X_th_id
                        );
          end if;

          open c_sum_dists(X_th_id);
          fetch c_sum_dists into l_sum_units_assigned;
          if c_sum_dists%NOTFOUND then exit; end if;
          close c_sum_dists;

          l_adj.transaction_header_id   := X_th_id;
          l_adj.period_counter_created  := l_pc;
          l_adj.period_counter_adjusted := l_pc;
          l_adj.asset_id                := X_asset_id;
          l_adj.book_type_code          := X_book_type_code;

          loop

            if (l_mrc_sob_type_code='R') then
               fetch c_sum_mrc_exp into
                  l_adj_type,
                  l_dr_cr_flag,
                  l_adj_amount,
                  l_annualized_adj_amount,
                  l_track_member_flag; --Bug7461343

               if c_sum_mrc_exp%NOTFOUND then exit; end if;
            else
               fetch c_sum_exp into
                  l_adj_type,
                  l_dr_cr_flag,
                  l_adj_amount,
                  l_annualized_adj_amount,
                  l_track_member_flag; --Bug7461343

               if c_sum_exp%NOTFOUND then exit; end if;
            end if;

            l_adj.track_member_flag       := l_track_member_flag; -- Bug7461343
            l_adj.adjustment_type         := l_adj_type;
            l_adj.debit_credit_flag       := l_dr_cr_flag;

            open c_new_dists(X_th_id);

            loop

              l_adj.selection_mode := FA_ADJUST_TYPE_PKG.FA_AJ_TRANSFER_SINGLE;
              l_adj.selection_thid          := 0;
              l_adj.selection_retid         := 0;
              l_adj.asset_invoice_id        := 0;
              l_adj.source_type_code        := 'DEPRECIATION';
              l_adj.last_update_date        := SYSDATE;
              l_adj.flush_adj_flag          := TRUE;
              l_adj.leveling_flag           := TRUE;
              l_adj.gen_ccid_flag           := TRUE;
              l_adj.code_combination_id     := 0;


              fetch c_new_dists into l_new_dist_id
                                    ,l_new_ccid
                                    ,l_current_units;
              if c_new_dists%NOTFOUND then exit; end if;

              l_adj.distribution_id         := l_new_dist_id;
              l_adj.code_combination_id     := l_new_ccid;
              l_adj.current_units  	  := l_current_units;


              if (l_adj_type = 'BONUS EXPENSE') then
                l_adj.account_type := 'BONUS_DEPRN_EXPENSE_ACCT';
                l_adj.account      := l_bonus_deprn_exp_acct;
              elsif (l_adj_type = 'IMPAIR EXPENSE') then
                l_adj.account_type := 'IMPAIR_EXPENSE_ACCT';
                l_adj.account      := l_impairment_exp_acct;
              else
                l_adj.account_type := 'DEPRN_EXPENSE_ACCT';
                l_adj.account      := l_deprn_exp_acct;
              end if;

              l_adj.mrc_sob_type_code       := l_mrc_sob_type_code;
              l_adj.set_of_books_id := l_set_of_books_id;

              l_adj.adjustment_amount       := l_adj_amount * l_current_units /
                                               l_sum_units_assigned;
              l_adj.annualized_adjustment   := l_annualized_adj_amount * l_current_units /
                                               l_sum_units_assigned;


              if (NOT fa_ins_adjust_pkg.faxinaj(l_adj,
                                                X_last_update_date,
                                                X_last_updated_by,
                                                X_last_update_login, p_log_level_rec => p_log_level_rec)) then
                 if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.faumvexp',
                                    element => 'account',
                                    value   => l_adj.account, p_log_level_rec => p_log_level_rec);
                   fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.faumvexp',
                                    element => 'adjustment_type',
                                    value   => l_adj.adjustment_type, p_log_level_rec => p_log_level_rec);
                   fa_debug_pkg.add(fname => 'FA_TRANSFER_XIT_PKG.faumvexp',
                                    element => 'selection_mode',
                                    value   => l_adj.selection_mode, p_log_level_rec => p_log_level_rec);
                 end if;
                 raise ERROR_FOUND;
              end if;
            end loop;
            close c_new_dists;
         end loop;
         if (l_mrc_sob_type_code='R') then
            close c_sum_mrc_exp;
         else
            close c_sum_exp;
         end if;

         begin

           if (l_mrc_sob_type_code='R') then

              delete from fa_mc_adjustments adj
               where adj.asset_id = X_asset_id
                 and adj.book_type_code = X_book_type_code
                 and adj.period_counter_created = l_pc
                 and adj.set_of_books_id = l_set_of_books_id
                 and adj.source_type_code = 'DEPRECIATION'
                 and adj.adjustment_type in ('EXPENSE', 'BONUS EXPENSE', 'IMPAIR EXPENSE')
                 and adj.distribution_id in
                    (select dh.distribution_id
                       from fa_distribution_history dh
                      where dh.transaction_header_id_out = X_th_id)
                 and exists
                    (select adj1.transaction_header_id
                       from fa_mc_adjustments adj1
                      where adj1.asset_id = X_asset_id
                        and adj1.transaction_header_id = X_th_id
                        and adj1.book_type_code = X_book_type_code
                        and adj1.period_counter_created = l_pc
                        and adj1.set_of_books_id = l_set_of_books_id
                        and adj1.source_type_code = 'DEPRECIATION'
                        and adj1.adjustment_type in ('EXPENSE', 'BONUS EXPENSE', 'IMPAIR EXPENSE'));

           else

              delete from fa_adjustments adj
               where adj.asset_id = X_asset_id
                 and adj.book_type_code = X_book_type_code
                 and adj.period_counter_created = l_pc
                 and adj.source_type_code = 'DEPRECIATION'
                 and adj.adjustment_type in ('EXPENSE', 'BONUS EXPENSE', 'IMPAIR EXPENSE')
                 and adj.distribution_id in
                    (select dh.distribution_id
                       from fa_distribution_history dh
                      where dh.transaction_header_id_out = X_th_id)
                 and exists
                    (select adj1.transaction_header_id
                       from fa_adjustments adj1
                      where adj1.asset_id = X_asset_id
                        and adj1.transaction_header_id = X_th_id
                        and adj1.book_type_code = X_book_type_code
                        and adj1.period_counter_created = l_pc
                        and adj1.source_type_code = 'DEPRECIATION'
                        and adj1.adjustment_type in ('EXPENSE', 'BONUS EXPENSE', 'IMPAIR EXPENSE'));
           end if;

         exception
            when others then null;

         end;

       end loop; -- loop for sob_id

       X_exp_moved := TRUE;
       RETURN (TRUE);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            X_exp_moved := FALSE;

            RETURN (TRUE);

        WHEN OTHERS THEN
            X_exp_moved := FALSE;
            FA_SRVR_MSG.ADD_SQL_ERROR (
                        CALLING_FN => 'FA_TRANSFER_XIT_PKG.faumvexp', p_log_level_rec => p_log_level_rec);

            RETURN (FALSE);

    END faumvexp;


END FA_TRANSFER_XIT_PKG;

/
