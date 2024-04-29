--------------------------------------------------------
--  DDL for Package Body FA_INS_ADJUST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_INS_ADJUST_PKG" as
/* $Header: FAXIAJ2B.pls 120.16.12010000.3 2009/07/19 14:24:13 glchen ship $ */

g_release                  number  := fa_cache_pkg.fazarel_release;

-----------------------------------------------------------------------
-- adj_ptr is the parameter in the original C-Code. Here adj_ptr is
-- global to this package and hence not required to be passed
-----------------------------------------------------------------------
FUNCTION fadoflx (X_book_type_code   in varchar2,
                  X_account_type     in varchar2,
                  X_dist_ccid        in number,
                  X_spec_ccid        in number,
                  X_account          in varchar2,
                  X_calculated_ccid     out nocopy number,
                  X_gen_ccid_flag    in boolean,
                  X_asset_id         in number,
                  X_cat_id           in out nocopy number,
                  X_distribution_id  in number,
                  X_source_type_code in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return boolean is

   h_acct_ccid_col_name            varchar2(30);
   h_account_ccid                  number;
   h_mesg_name                     varchar2(30);
   h_asset_id                      number;
   h_cat_id                        number;
   h_calculated_ccid               number;
   h_status                        varchar2(1);

BEGIN  <<fadoflx>>

   if (p_log_level_rec.statement_level) then
      FA_DEBUG_PKG.ADD
       (fname   => 'FA_INS_ADJUST_PKG.fadoflx',
        element => 'Dist Ccid in fadoflx is',
        value   => X_dist_ccid, p_log_level_rec => p_log_level_rec);
   end if;

   -- if X_gen_ccid_flag=TRUE then call the ccid calculation function to
   -- determine the ccid, using the account and account type arguments
   if (X_gen_ccid_flag and
       G_release = 11) then
      -- gen ccid
      h_asset_id := X_asset_id;
      h_cat_id := 0;
      h_mesg_name := 'FA_GET_CAT_ID';

      if (X_source_type_code <> 'RECLASS') then
         -- reclass
         SELECT asset_category_id
           INTO h_cat_id
           FROM fa_additions_b
          WHERE asset_id=h_asset_id;

         X_cat_id := h_cat_id;
      end if; -- Reclass

      -- replace direct fetch with call to cache
      -- for reducing db hits

      if not fa_cache_pkg.fazccb
                 (X_book   => X_book_type_code,
                  X_cat_id => X_cat_id, p_log_level_rec => p_log_level_rec) then
         FA_SRVR_MSG.ADD_MESSAGE
                 (NAME       => 'FA_GET_CAT_ID',
                  CALLING_FN => 'FA_INS_ADJUST_PKG.fadoflx', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

      if (X_account_type='ASSET_COST_ACCT') then
         h_account_ccid := fa_cache_pkg.fazccb_record.asset_cost_account_ccid;
      elsif (X_account_type='ASSET_CLEARING_ACCT') then
         h_account_ccid := fa_cache_pkg.fazccb_record.asset_clearing_account_ccid;
      elsif (X_account_type='CIP_COST_ACCT') then
         h_account_ccid := fa_cache_pkg.fazccb_record.wip_cost_account_ccid;
      elsif (X_account_type='CIP_CLEARING_ACCT') then
         h_account_ccid := fa_cache_pkg.fazccb_record.wip_clearing_account_ccid;
      elsif (X_account_type='REVAL_RESERVE_ACCT') then
         h_account_ccid := fa_cache_pkg.fazccb_record.reval_reserve_account_ccid;
      elsif (X_account_type='REVAL_AMORTIZATION_ACCT') then
         h_account_ccid := fa_cache_pkg.fazccb_record.reval_amort_account_ccid;
      elsif (X_account_type='DEPRN_RESERVE_ACCT') then
         h_account_ccid := fa_cache_pkg.fazccb_record.reserve_account_ccid;
      elsif (X_account_type='BONUS_DEPRN_RESERVE_ACCT')  then
         h_account_ccid := fa_cache_pkg.fazccb_record.bonus_reserve_acct_ccid;
      elsif (X_account_type='IMPAIR_EXPENSE_ACCT') then
         h_account_ccid := fa_cache_pkg.fazccb_record.impair_expense_account_ccid;
      elsif (X_account_type='IMPAIR_RESERVE_ACCT')  then
         h_account_ccid := fa_cache_pkg.fazccb_record.impair_reserve_account_ccid;
      else
         h_account_ccid := 0;
      end if;

      if (not FA_GCCID_PKG.fafbgcc
                   (X_book_type_code  => X_book_type_code,
                    X_fn_trx_code     => X_account_type,
                    X_dist_ccid       => X_dist_ccid,
                    X_acct_segval     => X_account,
                    X_account_ccid    => h_account_ccid,
                    X_distribution_id => X_distribution_id,
                    X_rtn_ccid        => h_calculated_ccid, p_log_level_rec => p_log_level_rec)) then
         h_mesg_name := 'FA_GET_ACCOUNT_CCID';
         FA_SRVR_MSG.ADD_MESSAGE
                     (NAME       => 'FA_GET_ACCOUNT_CCID',
                      CALLING_FN => 'FA_INS_ADJUST_PKG.fadoflx', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

      X_calculated_ccid := h_calculated_ccid;
      if (p_log_level_rec.statement_level) then
            FA_DEBUG_PKG.ADD (
               'FA_INS_ADJUST_PKG.fadoflx',
               'h_calc_ccid',
               h_calculated_ccid, p_log_level_rec => p_log_level_rec);
      end if;
   elsif (X_gen_ccid_flag = TRUE and
          G_release <> 11) then

      -- SLA: no longer gen the ccid, leave null
      X_calculated_ccid := NULL;

   elsif (X_spec_ccid <> 0) then
      -- gen ccid
      X_calculated_ccid := X_spec_ccid;
      if (p_log_level_rec.statement_level) then
             FA_DEBUG_PKG.ADD (
                'FA_INS_ADJUST_PKG.fadoflx',
                'h_calc_ccid',
                X_spec_ccid, p_log_level_rec => p_log_level_rec);
      end if;
   elsif (G_release  = 11) then
      X_calculated_ccid := X_dist_ccid;
   else
      X_calculated_ccid := null;  -- SLA: formerly X_dist_ccid;
   end if;
   return TRUE;

EXCEPTION
   WHEN OTHERS then
        FA_SRVR_MSG.ADD_SQL_ERROR(CALLING_FN => 'FA_INS_ADJUST_PKG.fadoflx', p_log_level_rec => p_log_level_rec);
     return FALSE;
END fadoflx;

--------------------------------------------------------------------------

FUNCTION factotp (total_amount     out nocopy  number,
                  adjustment_amount in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return boolean is

   h_debug_str          varchar2(255);
   h_total_amount   number;
   h_current_cost   number;

BEGIN  <<factotp>>
   -- Calculate the total_amount to prorate based on the
   -- adjustment_type.
   if (not adj_ptr.leveling_flag) then
      -- If the leveling_flag is off, then we just set
      -- total_amount to the raw adjustment_amount
      --   h_total_amount := adj_ptr.adjustment_amount;
      h_total_amount := adjustment_amount;
   elsif (adj_ptr.adjustment_type = 'COST' OR
          adj_ptr.adjustment_type = 'CIP COST') then
      -- Get the current FA_BOOKS.COST value
      -- if (not fagetcc(X_cost =>h_current_cost) then
      --    return FALSE;
      -- end if;
      -- h_total_amount := h_total_amount + h_current_cost;

      -- Commented out the above to test fix for transfer user  exit.
      --    h_total_amount := adj_ptr.adjustment_amount;
      h_total_amount := adjustment_amount;

   elsif (adj_ptr.adjustment_type='RESERVE') then
      h_total_amount := adjustment_amount + dpr_ptr.deprn_rsv;
   elsif (adj_ptr.adjustment_type='REVAL RESERVE') then
      h_total_amount := adjustment_amount + dpr_ptr.reval_rsv;
   elsif (adj_ptr.adjustment_type='BONUS RESERVE') then
      h_total_amount := adjustment_amount + dpr_ptr.bonus_deprn_rsv;
   elsif (adj_ptr.adjustment_type='IMPAIR RESERVE') then
      /* --changing this for 6866711
     h_total_amount := adjustment_amount + dpr_ptr.impairment_rsv;
     --Not sure why we started adding the value in adj_amt if the
     --intent is to obtain the value tracked in FA_DEPRN_DETAIL.
     --adjustment_amount is stored by the calling function; so, we shouldn't
     --be adding it again which would cause a problem in a multi-dist situation
     --we should probably look into above cases as well, but dealing with this
     --single one for now.  */
     /*Bug# 8392319 -Need to redo the fix for 6866711 as wrong entries in case of
       reclass for multi-dist asset,Verified test case for 6866711 as well
       used adjustment_amount instead of dpr_ptr.imapirment_rsv*/
      h_total_amount := adjustment_amount ;
   elsif (adj_ptr.adjustment_type='CAPITAL ADJ') then -- Bug 6666666
     h_total_amount := dpr_ptr.capital_adjustment;
   elsif (adj_ptr.adjustment_type='GENERAL FUND') then -- Bug 6666666
     h_total_amount := dpr_ptr.general_fund;
   else
      h_total_amount := adjustment_amount;
   end if;

   total_amount := h_total_amount;
   if (p_log_level_rec.statement_level) then
      FA_DEBUG_PKG.ADD (
         'FA_INS_ADJUST_PKG.factotp',
         'total_amount',
         h_total_amount, p_log_level_rec => p_log_level_rec);
   end if;
   return TRUE;

END factotp;

--------------------------------------------------------------------------

FUNCTION facdamt (adj_dd_amount  out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return boolean is

   h_adj_dd_amount  number;

BEGIN  <<facdamt>>
   -- If the account type is an amount that we track in
   -- FA_DEPRN_DETAIL, then figure out the detail_amount;
   -- For those account types that we do not track
   -- (ie DEPRN_EXPENSE),  the detail amount is
   -- set to zero.
   if (not adj_ptr.leveling_flag) then
      -- Leveling is turned off;adj_dd_amount should be zero here
      null;
   end if;

   if (adj_ptr.adjustment_type='COST') then
      h_adj_dd_amount := dpr_ptr.cost;
   elsif (adj_ptr.adjustment_type='CIP COST') then
      h_adj_dd_amount := dpr_ptr.cost;
   elsif (adj_ptr.adjustment_type='RESERVE') then
      h_adj_dd_amount := dpr_ptr.deprn_rsv;
   elsif (adj_ptr.adjustment_type='REVAL RESERVE') then
      h_adj_dd_amount := dpr_ptr.reval_rsv;
   elsif (adj_ptr.adjustment_type='BONUS RESERVE') then
      h_adj_dd_amount := dpr_ptr.bonus_deprn_rsv;
   elsif (adj_ptr.adjustment_type='IMPAIR RESERVE') then
      h_adj_dd_amount := dpr_ptr.impairment_rsv;
   elsif (adj_ptr.adjustment_type='CAPITAL ADJ') then --Bug 6666666
      h_adj_dd_amount := dpr_ptr.capital_adjustment;
   elsif (adj_ptr.adjustment_type='GENERAL FUND') then --Bug 6666666
      h_adj_dd_amount := dpr_ptr.general_fund;
   else
      h_adj_dd_amount := 0;
   end if;

   adj_dd_amount := h_adj_dd_amount;
   if (p_log_level_rec.statement_level) then
         FA_DEBUG_PKG.ADD
           (fname   => 'FA_INS_ADJUST_PKG.facdamt',
            element => 'h_adj_dd_amount',
            value   => h_adj_dd_amount, p_log_level_rec => p_log_level_rec);
   end if;
   return TRUE;

EXCEPTION
   WHEN OTHERS then
        FA_SRVR_MSG.ADD_SQL_ERROR(CALLING_FN => 'FA_INS_ADJUST_PKG.facdamt', p_log_level_rec => p_log_level_rec);
     return FALSE;
END facdamt;

----------------------------------------------------------------

FUNCTION fagetcc (X_cost out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return boolean is

   h_mesg_name    varchar2(50);
   h_asset_id     number;
   h_book         varchar2(30);
   h_cost         number;

BEGIN  <<fagetcc>>

   h_asset_id := adj_ptr.asset_id;
   h_book := adj_ptr.book_type_code;
   h_mesg_name := 'FA_TFR_NO_BOOKS_ROW';

   SELECT cost
     INTO h_cost
     FROM FA_BOOKS
    WHERE asset_id = h_asset_id
      AND book_type_code = h_book
      AND date_ineffective is null;

      X_cost := h_cost;

   return TRUE;

EXCEPTION
   WHEN NO_DATA_FOUND then
        FA_SRVR_MSG.ADD_MESSAGE (NAME => h_mesg_name,
               CALLING_FN => 'FA_INS_ADJUST_PKG.fagetcc', p_log_level_rec => p_log_level_rec);
        return FALSE;
   WHEN OTHERS then
        FA_SRVR_MSG.ADD_SQL_ERROR(CALLING_FN => 'FA_INS_ADJUST_PKG.fagetcc', p_log_level_rec => p_log_level_rec);
        return FALSE;

END fagetcc;

-----------------------------------------------------------------------
FUNCTION fainajc(X_flush_mode boolean,
                 X_mode       boolean,
                 X_last_update_date date default sysdate,
                 X_last_updated_by  number default -1,
                 X_last_update_login number default -1, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return boolean is

   h_max_cache_rows    number :=  FA_ADJUST_TYPE_PKG.MAX_ADJ_CACHE_ROWS;
   h_last_updated_by   number;
   h_last_update_login number;
   h_mesg_name         varchar2(30);
   h_num_rows          number;
   h_i                 number;
   h_j                 number;

BEGIN  <<fainajc>>

   -- Get the standard WHO columns -
   h_last_updated_by   := X_last_updated_by;
   h_last_update_login := X_last_update_login;

   if (X_flush_mode=FALSE) then
      -- Test if the cache is full;
      -- if MAX_ADJ_CACHE_ROWS = cache_index, then recursively
      -- call this function fainajc() with flush_mode = TRUE.
      if (h_cache_index > h_max_cache_rows OR h_cache_index < 0) then
         -- error: we're out of bounds on the array
         -- the cache index should always be 1 to MAX_ADJ_CACHE_ROWS
         h_mesg_name := 'FA_INS_ADJ_MAX_ROWS';
         raise NO_DATA_FOUND;
      elsif (h_cache_index=h_max_cache_rows) then
         -- The cache is full; we must dump it out.
         -- "Full" means we're at cache_index > MAX_ADJ_CACHE_ROWS
         h_mesg_name := 'FA_INS_ADJ_CANT_INSERT';
         h_num_rows := h_cache_index;

         -- BUG# 1823498 MRC changes
         -- transfers and reclasses will be calling this directly
         -- so using the GL SOB profile retrieved above, we need to
         -- derive which table to insert into
         --   -- bridgway 06/20/01

         if (h_mrc_sob_type_code = 'R') then
            FOR h_i in 1..h_num_rows LOOP
               INSERT INTO FA_MC_ADJUSTMENTS
                      (set_of_books_id,
                       transaction_header_id,
                       asset_invoice_id,
                       source_type_code,
                       adjustment_type,
                       debit_credit_flag,
                       code_combination_id,
                       book_type_code,
                       period_counter_created,
                       asset_id,
                       adjustment_amount,
                       period_counter_adjusted,
                       distribution_id,
                       annualized_adjustment,
                       deprn_override_flag,
                       last_update_date,
                       last_updated_by,
                       last_update_login,
                       track_member_flag, -- Added for Track Member feature
                       adjustment_line_id,
                       source_dest_code,
                       source_line_id)
               VALUES (adj_table(h_i).set_of_books_id,
                       adj_table(h_i).transaction_header_id,
                       adj_table(h_i).asset_invoice_id,
                       adj_table(h_i).source_type_code,
                       adj_table(h_i).adjustment_type,
                       adj_table(h_i).debit_credit_flag,
                       adj_table(h_i).code_combination_id,
                       adj_table(h_i).book_type_code,
                       adj_table(h_i).period_counter_created,
                       adj_table(h_i).asset_id,
                       adj_table(h_i).adjustment_amount,
                       adj_table(h_i).period_counter_adjusted,
                       adj_table(h_i).distribution_id,
                       adj_table(h_i).annualized_adjustment,
                       adj_table(h_i).deprn_override_flag,
                       adj_table(h_i).last_update_date,
                       h_last_updated_by,
                       h_last_update_login,
                       adj_table(h_i).track_member_flag,
                       fa_adjustments_s.nextval,
                       adj_table(h_i).source_dest_code,
                       adj_table(h_i).source_line_id); --adjustment_line_id
               h_j := h_i;
            END LOOP;
         else
            FOR h_i in 1..h_num_rows LOOP
               INSERT INTO FA_ADJUSTMENTS
                      (transaction_header_id,
                       asset_invoice_id,
                       source_type_code,
                       adjustment_type,
                       debit_credit_flag,
                       code_combination_id,
                       book_type_code,
                       period_counter_created,
                       asset_id,
                       adjustment_amount,
                       period_counter_adjusted,
                       distribution_id,
                       annualized_adjustment,
                       deprn_override_flag,
                       last_update_date,
                       last_updated_by,
                       last_update_login,
                       adjustment_line_id,
                       source_dest_code,
                       source_line_id)
               VALUES (adj_table(h_i).transaction_header_id,
                       adj_table(h_i).asset_invoice_id,
                       adj_table(h_i).source_type_code,
                       adj_table(h_i).adjustment_type,
                       adj_table(h_i).debit_credit_flag,
                       adj_table(h_i).code_combination_id,
                       adj_table(h_i).book_type_code,
                       adj_table(h_i).period_counter_created,
                       adj_table(h_i).asset_id,
                       adj_table(h_i).adjustment_amount,
                       adj_table(h_i).period_counter_adjusted,
                       adj_table(h_i).distribution_id,
                       adj_table(h_i).annualized_adjustment,
                       adj_table(h_i).deprn_override_flag,
                       adj_table(h_i).last_update_date,
                       h_last_updated_by,
                       h_last_update_login,
                       fa_adjustments_s.nextval,
                       adj_table(h_i).source_dest_code,
                       adj_table(h_i).source_line_id); --adjustment_line_id
               h_j := h_i;
            END LOOP;
         end if;  -- end MRC

         if (h_j <> h_cache_index) then
            h_mesg_name := 'FA_INS_NEQ_CACHE';
            raise NO_DATA_FOUND;
         end if;

         h_cache_index := 0;
         h_num_rows:=h_cache_index;

      end if;   -- cache

      -- Bug 2723165 : Added faxrnd rounding func.
      IF (NOT FA_UTILS_PKG.faxrnd(X_amount => adj_ptr.adjustment_amount,
                                  X_book   => adj_ptr.book_type_code,
                                  X_set_of_books_id => adj_ptr.set_of_books_id,
                                  p_log_level_rec => p_log_level_rec)) THEN
         FA_SRVR_MSG.add_message(CALLING_FN => 'FA_INS_ADJUST_PKG.fainajc', p_log_level_rec => p_log_level_rec);
         return (FALSE);
      END IF;

      if (p_log_level_rec.statement_level) then
           FA_DEBUG_PKG.ADD (
                   fname   => 'fainajc',
                   element => 'h_cache_index',
                   value   => h_cache_index, p_log_level_rec => p_log_level_rec);
           FA_DEBUG_PKG.ADD (
                   fname   => 'fainajc',
                   element => 'adj amount',
                   value   => adj_ptr.adjustment_amount, p_log_level_rec => p_log_level_rec);
      end if;

      -- Insert the values into the cache now.
      h_cache_index:=h_cache_index + 1;
      h_num_rows:=h_cache_index;
      adj_table(h_cache_index).set_of_books_id :=
               adj_ptr.set_of_books_id;
      adj_table(h_cache_index).transaction_header_id :=
               adj_ptr.transaction_header_id;
      adj_table(h_cache_index).asset_invoice_id :=
               adj_ptr.asset_invoice_id;
      adj_table(h_cache_index).source_type_code :=
               adj_ptr.source_type_code;
      adj_table(h_cache_index).adjustment_type :=
               adj_ptr.adjustment_type;
      adj_table(h_cache_index).debit_credit_flag :=
               adj_ptr.debit_credit_flag;
      adj_table(h_cache_index).code_combination_id :=
               adj_ptr.code_combination_id;
      adj_table(h_cache_index).book_type_code :=
               adj_ptr.book_type_code;
      adj_table(h_cache_index).period_counter_created :=
               adj_ptr.period_counter_created;
      adj_table(h_cache_index).asset_id :=
               adj_ptr.asset_id;
      adj_table(h_cache_index).adjustment_amount :=
               adj_ptr.adjustment_amount;
      adj_table(h_cache_index).period_counter_adjusted :=
               adj_ptr.period_counter_adjusted;
      adj_table(h_cache_index).distribution_id :=
               adj_ptr.distribution_id;
      adj_table(h_cache_index).annualized_adjustment :=
               adj_ptr.annualized_adjustment;
      adj_table(h_cache_index).deprn_override_flag :=
               adj_ptr.deprn_override_flag;
      adj_table(h_cache_index).last_update_date :=
               adj_ptr.last_update_date;
      adj_table(h_cache_index).track_member_flag :=
               adj_ptr.track_member_flag; -- Added for Track Member feature
      adj_table(h_cache_index).source_dest_code :=
               adj_ptr.source_dest_code;
      adj_table(h_cache_index).source_line_id :=
               adj_ptr.source_line_id;

      if (p_log_level_rec.statement_level)  then
           FA_DEBUG_PKG.ADD (
                   fname   => 'fainajc',
                   element => 'Adj Type',
                   value   => adj_ptr.adjustment_type, p_log_level_rec => p_log_level_rec);
           FA_DEBUG_PKG.ADD (
                   fname   => 'fainajc',
                   element => 'DR/CR Type',
                   value   => adj_ptr.debit_credit_flag, p_log_level_rec => p_log_level_rec);
           FA_DEBUG_PKG.ADD (
                   fname   => 'fainajc',
                   element => 'Code Combination Id',
                   value   => adj_ptr.code_combination_id, p_log_level_rec => p_log_level_rec);
           FA_DEBUG_PKG.ADD (
                   fname   => 'fainajc',
                   element => 'book_type_code',
                   value   => adj_ptr.book_type_code, p_log_level_rec => p_log_level_rec);
           FA_DEBUG_PKG.ADD (
                   fname   => 'fainajc',
                   element => 'asset id',
                   value   => adj_ptr.asset_id, p_log_level_rec => p_log_level_rec);
           FA_DEBUG_PKG.ADD (
                   fname   => 'fainajc',
                   element => 'adj amt',
                   value   => adj_ptr.adjustment_amount, p_log_level_rec => p_log_level_rec);
           FA_DEBUG_PKG.ADD (
                   fname   => 'fainajc',
                   element => 'prd ctr cr',
                   value   => adj_ptr.period_counter_created, p_log_level_rec => p_log_level_rec);
           FA_DEBUG_PKG.ADD (
                   fname   => 'fainajc',
                   element => 'prd ctr adj',
                   value   => adj_ptr.period_counter_adjusted, p_log_level_rec => p_log_level_rec);
          FA_DEBUG_PKG.ADD (
                   fname   => 'fainajc',
                   element => 'deprn_override_flag',
                   value   => adj_ptr.deprn_override_flag, p_log_level_rec => p_log_level_rec);
          FA_DEBUG_PKG.ADD (
                   fname   => 'fainajc',
                   element => 'track_member_flag',
                   value   => adj_ptr.track_member_flag, p_log_level_rec => p_log_level_rec);
      end if;
   elsif (X_flush_mode=TRUE and h_cache_index > 0) then
      h_num_rows := h_cache_index;
      h_mesg_name := 'FA_INS_ADJ_CANT_INSERT';
      if (p_log_level_rec.statement_level) then
           FA_DEBUG_PKG.ADD (
                   fname   => 'fainajc',
                   element => 'Rows in CACHE-INSERT IN TRUE',
                   value   => h_num_rows, p_log_level_rec => p_log_level_rec);
      end if;

      -- BUG# 1823498 MRC changes
      -- transfers and reclasses will be calling this directly
      -- so using the GL SOB profile retrieved above, we need to
      -- derive which table to insert into
      --   -- bridgway 06/20/01

      if (h_mrc_sob_type_code ='R') then
         FOR h_i in 1..h_num_rows LOOP
            INSERT INTO FA_MC_ADJUSTMENTS
                   (set_of_books_id,
                    transaction_header_id,
                    asset_invoice_id,
                    source_type_code,
                    adjustment_type,
                    debit_credit_flag,
                    code_combination_id,
                    book_type_code,
                    period_counter_created,
                    asset_id,
                    adjustment_amount,
                    period_counter_adjusted,
                    distribution_id,
                    annualized_adjustment,
                    deprn_override_flag,
                    last_update_date,
                    last_updated_by,
                    last_update_login,
                    track_member_flag, -- Added for Track Member feature
                    adjustment_line_id,
                    source_dest_code,
                    source_line_id)
            VALUES (adj_table(h_i).set_of_books_id,
                    adj_table(h_i).transaction_header_id,
                    adj_table(h_i).asset_invoice_id,
                    adj_table(h_i).source_type_code,
                    adj_table(h_i).adjustment_type,
                    adj_table(h_i).debit_credit_flag,
                    adj_table(h_i).code_combination_id,
                    adj_table(h_i).book_type_code,
                    adj_table(h_i).period_counter_created,
                    adj_table(h_i).asset_id,
                    adj_table(h_i).adjustment_amount,
                    adj_table(h_i).period_counter_adjusted,
                    adj_table(h_i).distribution_id,
                    adj_table(h_i).annualized_adjustment,
                    adj_table(h_i).deprn_override_flag,
                    adj_table(h_i).last_update_date,
                    h_last_updated_by,
                    h_last_update_login,
                    adj_table(h_i).track_member_flag, -- Added for Track Member
                    fa_adjustments_s.nextval,
                    adj_table(h_i).source_dest_code,
                    adj_table(h_i).source_line_id);
            h_j := h_i;
         END LOOP;
      else
         FOR h_i in 1..h_num_rows LOOP
            INSERT INTO FA_ADJUSTMENTS
                   (transaction_header_id,
                    asset_invoice_id,
                    source_type_code,
                    adjustment_type,
                    debit_credit_flag,
                    code_combination_id,
                    book_type_code,
                    period_counter_created,
                    asset_id,
                    adjustment_amount,
                    period_counter_adjusted,
                    distribution_id,
                    annualized_adjustment,
                    deprn_override_flag,
                    last_update_date,
                    last_updated_by,
                    last_update_login,
                    track_member_flag, -- Added for Track Member
                    adjustment_line_id,
                    source_dest_code,
                    source_line_id)
            VALUES (adj_table(h_i).transaction_header_id,
                    adj_table(h_i).asset_invoice_id,
                    adj_table(h_i).source_type_code,
                    adj_table(h_i).adjustment_type,
                    adj_table(h_i).debit_credit_flag,
                    adj_table(h_i).code_combination_id,
                    adj_table(h_i).book_type_code,
                    adj_table(h_i).period_counter_created,
                    adj_table(h_i).asset_id,
                    adj_table(h_i).adjustment_amount,
                    adj_table(h_i).period_counter_adjusted,
                    adj_table(h_i).distribution_id,
                    adj_table(h_i).annualized_adjustment,
                    adj_table(h_i).deprn_override_flag,
                    adj_table(h_i).last_update_date,
                    h_last_updated_by,
                    h_last_update_login,
                    adj_table(h_i).track_member_flag, -- Track Member
                    fa_adjustments_s.nextval,
                    adj_table(h_i).source_dest_code,
                    adj_table(h_i).source_line_id);
            h_j := h_i;
         END LOOP;
      end if;  -- end mrc

      if (h_j <> h_cache_index) then
         h_mesg_name := 'FA_INS_NEQ_CACHE';
         raise NO_DATA_FOUND;
      end if;
      h_cache_index := 0;
      h_num_rows:=0;
   end if;   -- X_flush_mode
   return TRUE;

EXCEPTION
   WHEN NO_DATA_FOUND then
        FA_SRVR_MSG.ADD_MESSAGE
             (NAME       => h_mesg_name,
              CALLING_FN => 'FA_INS_ADJUST_PKG.fainajc', p_log_level_rec => p_log_level_rec);
        return FALSE;
   WHEN OTHERS then
        FA_SRVR_MSG.ADD_SQL_ERROR
             (CALLING_FN => 'FA_INS_ADJUST_PKG.fainajc', p_log_level_rec => p_log_level_rec);
        return FALSE;
 END fainajc;

-------------------------------------------------------------------

FUNCTION fadoact(X_last_update_date  date   default sysdate,
                 X_last_updated_by   number default -1,
                 X_last_update_login number default -1, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return boolean is

   h_dist_book          varchar2(30);
   h_asset_id           number;
   h_success            boolean;
   h_distribution_lines number;
   h_distribution_id    number :=0;
   h_calculated_ccid    number;
   h_dist_ccid          number;
   h_units_assigned     number;
   h_adj_type           varchar2(20);
   h_mesg_name          varchar2(30);
   h_row_ctr            number:=0;
   h_amount_so_far      number :=0;
   h_amount_to_insert   number :=0;
   h_adj_dd_amount      number;
   h_total_amount       number :=0;
   h_adjustment_amount  number :=0;
   h_temp_adj_amount number :=0; /*Bug#8411280 */

-- Fix for Bug# 4459256
CURSOR C1 IS
 SELECT DISTRIBUTION_ID,
        CODE_COMBINATION_ID,
        UNITS_ASSIGNED
   FROM FA_DISTRIBUTION_HISTORY
  WHERE ASSET_ID = h_asset_id
    AND BOOK_TYPE_CODE = h_dist_book
    AND (
          (adj_ptr.selection_mode <> FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE_PARTIAL
           AND date_ineffective is null
          )
          OR
          (adj_ptr.selection_mode = FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE_PARTIAL
           AND transaction_header_id_in=adj_ptr.selection_thid
          )
        )
  ORDER BY DISTRIBUTION_ID;

BEGIN  <<fadoact>>

   -- First Store the adj_ptr.adjustment_amount into h_adjustment_amount
   -- This is done because adj_ptr.adjustment gets changed here and we
   -- need to retain the original passed value for calculation of amount for
   --  each distribution
   h_adjustment_amount := adj_ptr.adjustment_amount;
   h_temp_adj_amount := adj_ptr.adjustment_amount;/*Bug#8411280 */

   -- Flush out the unposted rows in the cache to the db
   -- since there might be some pending rows out there,
   -- and we can't read through the cache
   h_asset_id := adj_ptr.asset_id;

   if (p_log_level_rec.statement_level) then
      FA_DEBUG_PKG.ADD
          (fname   => 'FA_INS_ADJUST_PKG.fadoact',
           element => 'Before Flush',
           value   => 'TRUE', p_log_level_rec => p_log_level_rec);
   end if;

   if (not fainajc
             (X_flush_mode        => TRUE,
              X_mode              => FALSE,
              X_last_update_date  => X_last_update_date,
              X_last_updated_by   => X_last_updated_by,
              X_last_update_login => X_last_update_login,
              p_log_level_rec     => p_log_level_rec)) then
      FA_SRVR_MSG.ADD_MESSAGE
           (CALLING_FN => 'FA_INS_ADJUST_PKG.fadoact', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- Call the Query Fin Info function in detail mode to figure
   -- out how much to clear for this distribution
   H_DPR_ROW.asset_id   := adj_ptr.asset_id;
   H_DPR_ROW.book       := adj_ptr.book_type_code;
   H_DPR_ROW.dist_id    := h_distribution_id;
   H_DPR_ROW.period_ctr := 0;
   H_DPR_ROW.mrc_sob_type_code := h_mrc_sob_type_code;
   H_DPR_ROW.set_of_books_id := h_set_of_books_id;

   FA_QUERY_BALANCES_PKG.QUERY_BALANCES_INT
                            (H_DPR_ROW,
                             'STANDARD',
                             FALSE,
                             H_SUCCESS,
                             'FA_INS_ADJUST_PKG.fadoact',
                             -1, p_log_level_rec => p_log_level_rec);

   -- Assign H_DPR_ROW to dpr_ptr
   dpr_ptr := H_DPR_ROW;

   -- Calculate the total_amount to prorate based on the
   -- adjustment_type.
   if (p_log_level_rec.statement_level) then
      FA_DEBUG_PKG.ADD
               (fname   => 'FA_INS_ADJUST_PKG.fadoact',
                element => 'ALL BLANKS',
                value   => '                             ', p_log_level_rec => p_log_level_rec);
      FA_DEBUG_PKG.ADD
               (fname   => 'FA_INS_ADJUST_PKG.fadoact',
                element => 'adj_ptr.amount',
                value   => h_adjustment_amount, p_log_level_rec => p_log_level_rec);
   end if;
   /*Bug#8411280 */
   if (adj_ptr.source_type_code = 'RETIREMENT' and adj_ptr.adjustment_type = 'IMPAIR RESERVE') THEN
      h_adjustment_amount := h_adjustment_amount + dpr_ptr.impairment_rsv ;
   end if;
   if (not factotp
              (total_amount      => h_total_amount,
               adjustment_amount => h_adjustment_amount,
               p_log_level_rec => p_log_level_rec)) then
      FA_SRVR_MSG.ADD_MESSAGE
           (CALLING_FN => 'FA_INS_ADJUST_PKG.fadoact', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   if (p_log_level_rec.statement_level) then
         FA_DEBUG_PKG.ADD
               (fname   => 'FA_INS_ADJUST_PKG.fadoact',
                element => 'Total Amount',
                value   => h_total_amount, p_log_level_rec => p_log_level_rec);
   end if;

   -- no need to call the book controls cache here - it shoudl already be loaded
   h_dist_book := FA_CACHE_PKG.fazcbc_record.distribution_source_book;

   h_mesg_name:='FA_INS_ADJ_CNT_ACTIVE';

   if (adj_ptr.selection_mode <> FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE_PARTIAL) then

     SELECT COUNT(*)
       INTO h_distribution_lines
       FROM FA_DISTRIBUTION_HISTORY
      WHERE ASSET_ID=h_asset_id
        AND book_type_code=h_dist_book
        AND DATE_INEFFECTIVE IS NULL;

   else

     -- the number of the newly created rows only
     SELECT COUNT(*)
       INTO h_distribution_lines
       FROM FA_DISTRIBUTION_HISTORY
      WHERE ASSET_ID=h_asset_id
        AND book_type_code=h_dist_book
        AND transaction_header_id_in=adj_ptr.selection_thid;

   end if;

   -- SLA: fail if count = 0
   if ((SQL%NOTFOUND or h_distribution_lines = 0) and
       G_release = 11) THEN
      FA_SRVR_MSG.ADD_MESSAGE (NAME=>h_mesg_name,
         CALLING_FN => 'FA_GCCID_PKG.fadoact', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   h_mesg_name:='FA_INS_ADJ_DCUR_C1';
   for distribution IN C1 loop
      h_mesg_name       := 'FA_INS_ADJ_FCUR_C1';
      h_distribution_id := distribution.distribution_id;
      h_dist_ccid       := distribution.code_combination_id;
      h_units_assigned  := distribution.units_assigned;
      h_row_ctr         := h_row_ctr+1;

      -- Get the FA_DEPRN_DETAIL value for the PERIOD_ADJUSTED,
      -- plus/minus any adjustments by calling Query Fin Info
      -- in detail mode:
      H_DPR_ROW.asset_id:=adj_ptr.asset_id;
      H_DPR_ROW.book:=adj_ptr.book_type_code;
      H_DPR_ROW.dist_id:=h_distribution_id;
      H_DPR_ROW.period_ctr:=0;
      H_DPR_ROW.mrc_sob_type_code := h_mrc_sob_type_code;
      H_DPR_ROW.set_of_books_id := h_set_of_books_id;

      FA_QUERY_BALANCES_PKG.QUERY_BALANCES_INT
                            (H_DPR_ROW,
                             'STANDARD',
                             FALSE,
                             H_SUCCESS,
                             -1, p_log_level_rec => p_log_level_rec);
      if not h_success then
         FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN => 'FA_GCCID_PKG.fadoact', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

      -- Assign H_DPR_ROW to dpr_ptr. They are of the same type
      dpr_ptr:=H_DPR_ROW;

      -- Calculate the detail amount to subtract for leveling
      -- Test change, always treat cost adjustments in as false

      if ((adj_ptr.leveling_flag=TRUE) AND
          (adj_ptr.adjustment_type<>'COST') AND
          (adj_ptr.adjustment_type<>'CIP COST')) then
         if (not facdamt(h_adj_dd_amount, p_log_level_rec)) then
            FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN => 'FA_GCCID_PKG.fadoact', p_log_level_rec => p_log_level_rec);
            return FALSE;
         end if;
      else
         h_adj_dd_amount:=0;   -- Set to 0 if leveling off
      end if;

      if (h_row_ctr<>h_distribution_lines) then
         -- not the last distribution
         h_amount_to_insert := (h_total_amount * h_units_assigned/
                                                 adj_ptr.current_units) -
                                h_adj_dd_amount;
      else
         -- Last distribution gets extra
         if (p_log_level_rec.statement_level) then
             FA_DEBUG_PKG.ADD
                (fname   => 'FA_INS_ADJUST_PKG.fadoact',
                 element => 'Total Amount',
                 value   => h_total_amount, p_log_level_rec => p_log_level_rec);
         end if;

         -- YYOON: Propagated from PRO*C version(faxiaj2.lpc)

         if (adj_ptr.account_type = 'REVAL_RESERVE_ACCT'
             and adj_ptr.selection_mode <> FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE_REVAL) then

             h_amount_to_insert := h_total_amount - h_amount_so_far;

         else
             /*Bug#8411280 */
             if (adj_ptr.source_type_code = 'RETIREMENT' and adj_ptr.adjustment_type = 'IMPAIR RESERVE') THEN
                h_amount_to_insert := h_temp_adj_amount - h_amount_so_far;
             else
                h_amount_to_insert := h_adjustment_amount - h_amount_so_far;
             end if;

         end if;

      end if;

      if (p_log_level_rec.statement_level) then
         FA_DEBUG_PKG.ADD
              (fname   => 'FA_INS_ADJUST_PKG.fadoact',
               element => 'ADJ_PTR.ADJUSTMENT_AMOUNT',
               value   => h_adjustment_amount, p_log_level_rec => p_log_level_rec);
         FA_DEBUG_PKG.ADD
              (fname   => 'FA_INS_ADJUST_PKG.fadoact',
               element => 'AMOUNT SO FAR',
               value   => h_amount_so_far, p_log_level_rec => p_log_level_rec);
         FA_DEBUG_PKG.ADD
              (fname   => 'FA_INS_ADJUST_PKG.fadoact',
               element => 'h_amount_to_insert',
               value   => h_amount_to_insert, p_log_level_rec => p_log_level_rec);
      end if;

      -- Round the h_amount_to_insert - faxrnd.....
      IF (NOT FA_UTILS_PKG.faxrnd(X_amount => h_amount_to_insert,
                                  X_book   => adj_ptr.book_type_code,
                                  X_set_of_books_id => adj_ptr.set_of_books_id,
                                  p_log_level_rec => p_log_level_rec)) THEN
         FA_SRVR_MSG.add_message(CALLING_FN => 'FA_INS_ADJUST_PKG.fadoact', p_log_level_rec => p_log_level_rec);
         return (FALSE);
      END IF;

      h_amount_so_far:=h_amount_so_far+h_amount_to_insert;
      if (p_log_level_rec.statement_level) then
         FA_DEBUG_PKG.ADD
                (fname   => 'FA_INS_ADJUST_PKG.fadoact',
                 element => 'dist ccid in fadoact',
                 value   => h_dist_ccid, p_log_level_rec => p_log_level_rec);
         FA_DEBUG_PKG.ADD
                (fname   => 'FA_INS_ADJUST_PKG.fadoact',
                 element => 'Amount so far-amount inserted ',
                 value   => h_amount_so_far, p_log_level_rec => p_log_level_rec);
      end if;

      -- Calculate the ccid to use
      if (not fadoflx
               (X_book_type_code   => adj_ptr.book_type_code,
                X_account_type     => adj_ptr.account_type,
                X_dist_ccid        => h_dist_ccid,
                X_spec_ccid        => adj_ptr.code_combination_id,
                X_account          => adj_ptr.account,
                X_calculated_ccid  => h_calculated_ccid,
                X_gen_ccid_flag    => adj_ptr.gen_ccid_flag,
                X_asset_id         => adj_ptr.asset_id,
                X_cat_id           => adj_ptr.selection_retid,
                X_distribution_id  => h_distribution_id,
                X_source_type_code => adj_ptr.source_type_code,
              p_log_level_rec     => p_log_level_rec)) then
         FA_SRVR_MSG.ADD_MESSAGE
             (CALLING_FN => 'FA_GCCID_PKG.fadoact',
              NAME       => h_mesg_name, p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

      -- Call the function fainajc, which performs the insert into
      -- FA_ADJUSTMENTS, caching the inserts if appropiate
      if adj_ptr.account_type='CIP_COST_ACCT' then
         h_adj_type:='CIP COST';
      else
         h_adj_type:=adj_ptr.adjustment_type;
      end if;

      if (p_log_level_rec.statement_level) then
         FA_DEBUG_PKG.ADD
                (fname   => 'FA_INS_ADJUST_PKG.fadoact',
                 element => 'Adj Amt in fadoact',
                 value   => h_amount_to_insert, p_log_level_rec => p_log_level_rec);
      end if;

      adj_ptr.code_combination_id := h_calculated_ccid;
      adj_ptr.adjustment_type := h_adj_type;
      adj_ptr.adjustment_amount := h_amount_to_insert;
      adj_ptr.distribution_id := h_distribution_id;
      if (not fainajc
                (X_flush_mode        => FALSE,
                 X_mode              => FALSE,
                 X_last_update_date  => X_last_update_date,
                 X_last_updated_by   => X_last_updated_by,
                 X_last_update_login => X_last_update_login,
              p_log_level_rec     => p_log_level_rec)) then
         FA_SRVR_MSG.ADD_MESSAGE (CALLING_FN => 'FA_INS_ADJUST_PKG.fadoact', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;
   end loop;

   adj_ptr.amount_inserted := h_amount_so_far;
   return TRUE;

exception
   when others then
        FA_SRVR_MSG.ADD_SQL_ERROR(CALLING_FN => 'FA_INS_ADJUST_PKG.fadoact', p_log_level_rec => p_log_level_rec);
        return FALSE;

END fadoact;

-------------------------------------------------------------------

FUNCTION fadoclr(X_last_update_date  date default sysdate,
                 X_last_updated_by   number default -1,
                 X_last_update_login number default -1, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return boolean is

   h_row_ctr          number :=0;
   h_dist_book        varchar2(30);
   h_asset_id         number;
   h_selection_thid   number;
   h_mesg_name        varchar2(30);
   h_dist_ccid        number;
   h_distribution_id  number :=0;
   h_units_assigned   number;
   h_thid_in          number;
   h_calculated_ccid  number;
   h_adj_dd_amount    number:=0;
   h_amount_to_insert number :=0;
   h_amount_so_far    number :=0;

   -- The following variables are declared for QUERY_BALANCES_INT
   h_success    boolean;
   hx_debug     boolean :=FALSE;
   h_adj_type   varchar2(20);

   -- Fix for Bug# 4459256
   CURSOR FA_CLEAR IS
   SELECT distribution_id,
          code_combination_id,
          units_assigned,
          transaction_header_id_in
     FROM FA_DISTRIBUTION_HISTORY
    WHERE asset_id = h_asset_id
      AND book_type_code=h_dist_book
      AND (
            (adj_ptr.selection_mode <> FA_ADJUST_TYPE_PKG.FA_AJ_CLEAR_PARTIAL
             AND (date_ineffective is null
                  OR transaction_header_id_out=adj_ptr.selection_thid
                 )
            )
           OR
            (adj_ptr.selection_mode = FA_ADJUST_TYPE_PKG.FA_AJ_CLEAR_PARTIAL
             AND transaction_header_id_out=adj_ptr.selection_thid
            )
          )
    ORDER BY distribution_id;

BEGIN <<fadoclr>>

   h_asset_id := adj_ptr.asset_id;
   h_selection_thid:=adj_ptr.selection_thid;
   -- Flush out the unposted rows in the cache to the DB. Since there
   -- might be some pending rows and we can't read through the cache;

   if (not fainajc
             (X_flush_mode        => TRUE,
              X_mode              => FALSE,
              X_last_update_date  => X_last_update_date,
              X_last_updated_by   => X_last_updated_by,
              X_last_update_login => X_last_update_login,
              p_log_level_rec     => p_log_level_rec)) then
      FA_SRVR_MSG.ADD_MESSAGE
           (NAME       => 'FA_GET_CAT_ID',
            CALLING_FN => 'FA_INS_ADJUST_PKG.fadoclr', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- no need to call book controls cache here - it should already be loaded
   h_dist_book := FA_CACHE_PKG.fazcbc_record.distribution_source_book;
   if (p_log_level_rec.statement_level) then
      FA_DEBUG_PKG.ADD
          (fname   => 'FA_INS_ADJUST_PKG.fadoclr',
           element => 'Dist Ccid in fadoclr is',
           value   => h_dist_ccid, p_log_level_rec => p_log_level_rec);
   end if;
   h_mesg_name := 'FA_INS_ADJ_OCUR_CLEAR';

   for distval IN FA_CLEAR loop
      h_mesg_name       := 'FA_INS_ADJ_FCUR_CLEAR';
      h_distribution_id := distval.distribution_id;
      h_dist_ccid       := distval.code_combination_id;
      h_units_assigned  := distval.units_assigned;
      h_thid_in         := distval.transaction_header_id_in;
      h_row_ctr         := h_row_ctr + 1;

      --  Do not clear out rows created by the selection thid
      if (h_thid_in <> adj_ptr.selection_thid) then
         -- Call the Query Fin Info function in detail mode to figure
         -- out how much to clear for this distribution
         H_DPR_ROW.asset_id   := adj_ptr.asset_id;
         H_DPR_ROW.book       := adj_ptr.book_type_code;
         H_DPR_ROW.dist_id    := h_distribution_id;
         H_DPR_ROW.period_ctr :=0;
         H_DPR_ROW.mrc_sob_type_code := h_mrc_sob_type_code;
         H_DPR_ROW.set_of_books_id := h_set_of_books_id;

         FA_QUERY_BALANCES_PKG.QUERY_BALANCES_INT
                            (H_DPR_ROW,
                             'STANDARD',
                             FALSE,
                             H_SUCCESS,
                             'FA_INS_ADJUST_PKG.fadoclr',
                             -1, p_log_level_rec => p_log_level_rec);

         -- Assign H_DPR_ROW to dpr_ptr. They are of same type
         dpr_ptr:=H_DPR_ROW;

         -- call facdamt to calculate the detail amount for leveling
         if (not facdamt(adj_dd_amount=>h_adj_dd_amount,
                         p_log_level_rec => p_log_level_rec)) then
            FA_SRVR_MSG.ADD_MESSAGE
                (CALLING_FN => 'FA_INS_ADJUST_PKG.fadoclr',
                 NAME       => h_mesg_name, p_log_level_rec => p_log_level_rec);
         end if;

         h_amount_to_insert := h_adj_dd_amount;

         if (p_log_level_rec.statement_level) then
            FA_DEBUG_PKG.ADD
               (fname   => 'FA_INS_ADJUST_PKG.fadoclr',
                element => 'JUST BLANK',
                value   => '00000000000000000000000000', p_log_level_rec => p_log_level_rec);
            FA_DEBUG_PKG.ADD
               (fname   => 'FA_INS_ADJUST_PKG.fadoclr',
                element => 'DD ADJ AMOUNT-after FACDAMT',
                value   => h_adj_dd_amount, p_log_level_rec => p_log_level_rec);
            FA_DEBUG_PKG.ADD
               (fname   => 'FA_INS_ADJUST_PKG.fadoclr',
                element => 'amount to insert-after FACDAMT',
                value   => h_amount_to_insert, p_log_level_rec => p_log_level_rec);
         end if;

         -- round amount to insert (h_amount_to_insert) according to the
         -- functional currency  faxrnd(...)
         IF (NOT FA_UTILS_PKG.faxrnd(X_amount => h_amount_to_insert,
                                     X_book   => adj_ptr.book_type_code,
                                     X_set_of_books_id => adj_ptr.set_of_books_id,
                                     p_log_level_rec => p_log_level_rec))  THEN
            FA_SRVR_MSG.add_message(
                 CALLING_FN => 'FA_INS_ADJUST_PKG.fadoclr', p_log_level_rec => p_log_level_rec);
            return (FALSE);
         END IF;

         adj_ptr.adjustment_amount := h_amount_to_insert;
         h_amount_so_far := h_amount_so_far + h_amount_to_insert;

         if (p_log_level_rec.statement_level) then
            FA_DEBUG_PKG.ADD
                (fname   => 'FA_INS_ADJUST_PKG.fadoclr',
                 element => 'amount to insert-AFTER ROUNDING',
                 value   => h_amount_to_insert, p_log_level_rec => p_log_level_rec);
            FA_DEBUG_PKG.ADD
                (fname   => 'FA_INS_ADJUST_PKG.fadoclr',
                 element => 'amount so far-AFTER ROUNDING',
                 value   => h_amount_so_far, p_log_level_rec => p_log_level_rec);
         end if;

         -- Calculate the ccid to use
         if (not fadoflx
                  (X_book_type_code   => adj_ptr.book_type_code,
                   X_account_type     => adj_ptr.account_type,
                   X_dist_ccid        => h_dist_ccid,
                   X_spec_ccid        => adj_ptr.code_combination_id,
                   X_account          => adj_ptr.account,
                   X_calculated_ccid  => h_calculated_ccid,
                   X_gen_ccid_flag    => adj_ptr.gen_ccid_flag,
                   X_asset_id         => adj_ptr.asset_id,
                   X_cat_id           => adj_ptr.selection_retid,
                   X_distribution_id  => h_distribution_id,
                   X_source_type_code => adj_ptr.source_type_code,
              p_log_level_rec     => p_log_level_rec)) then
            FA_SRVR_MSG.ADD_MESSAGE
                (CALLING_FN => 'FA_GCCID_PKG.fadoclr',
                 NAME       => h_mesg_name, p_log_level_rec => p_log_level_rec);
            return FALSE;
         end if;

         -- Bug 1131364
         if adj_ptr.account_type='CIP_COST_ACCT' then
            h_adj_type := 'CIP COST';
         else
            h_adj_type := adj_ptr.adjustment_type;
         end if;

         -- Call the function fainajc, which performs the insert into
         -- FA_ADJUSTMENTS, caching the inserts if appropiate
         adj_ptr.adjustment_type     := h_adj_type;
         adj_ptr.code_combination_id := h_calculated_ccid;
         adj_ptr.distribution_id     := h_distribution_id;
         if (not fainajc
                  (X_flush_mode        => FALSE,
                   X_mode              => FALSE,
                   X_last_update_date  => X_last_update_date,
                   X_last_updated_by   => X_last_updated_by,
                   X_last_update_login => X_last_update_login,
              p_log_level_rec     => p_log_level_rec)) then
            FA_SRVR_MSG.ADD_MESSAGE
                 (NAME       => 'FA_GET_CAT_ID',
                  CALLING_FN => 'FA_INS_ADJUST_PKG.fadoclr', p_log_level_rec => p_log_level_rec);
            return FALSE;
         end if;
      end if;   -- thid<>adj_ptr.selection_thid
   end loop;

   adj_ptr.amount_inserted := h_amount_so_far;

   if (p_log_level_rec.statement_level) then
      FA_DEBUG_PKG.ADD
          (fname   => 'FA_INS_ADJUST_PKG.fadoclr',
           element => 'AMOUNT INSERTED ',
           value   => adj_ptr.amount_inserted, p_log_level_rec => p_log_level_rec);
      FA_DEBUG_PKG.ADD
          (fname   => 'FA_INS_ADJUST_PKG.fadoclr',
           element => 'AMOUNT SO FAR ',
           value   => h_amount_so_far, p_log_level_rec => p_log_level_rec);
   end if;
   return TRUE;

exception
   when others then
        FA_SRVR_MSG.ADD_SQL_ERROR
           (CALLING_FN => 'FA_INS_ADJUST_PKG.fadoclr', p_log_level_rec => p_log_level_rec);
        return FALSE;

END fadoclr;

-----------------------------------------------------------------------

FUNCTION fadosglf(X_last_update_date  date default sysdate,
                  X_last_updated_by   number default -1,
                  X_last_update_login number default -1, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return boolean is

   h_calculated_ccid   number;
   h_dist_id           number;
   h_adj_type          varchar2(20);

BEGIN <<fadosglf>>
   if (not fainajc
              (X_flush_mode        => TRUE,
               X_mode              => FALSE,
               X_last_update_date  => X_last_update_date,
               X_last_updated_by   => X_last_updated_by,
               X_last_update_login => X_last_update_login,
              p_log_level_rec     => p_log_level_rec)) then
      FA_SRVR_MSG.ADD_MESSAGE (CALLING_FN => 'FA_INS_ADJUST_PKG.fadosglf', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- Calculate what CCID to use
   h_dist_id := adj_ptr.code_combination_id;
   if (not fadoflx
           (X_book_type_code   => adj_ptr.book_type_code,
            X_account_type     => adj_ptr.account_type,
            X_dist_ccid        => h_dist_id,
            X_spec_ccid        => adj_ptr.code_combination_id,
            X_account          => adj_ptr.account,
            X_calculated_ccid  => h_calculated_ccid,
            X_gen_ccid_flag    => adj_ptr.gen_ccid_flag,
            X_asset_id         => adj_ptr.asset_id,
            X_cat_id           => adj_ptr.selection_retid,
            X_distribution_id  => adj_ptr.distribution_id,
            X_source_type_code => adj_ptr.source_type_code,
              p_log_level_rec     => p_log_level_rec)) then
      FA_SRVR_MSG.ADD_MESSAGE
         (CALLING_FN =>'FA_GCCID_PKG.fadosglf', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- Round the amount_to_insert according to functional currency */
   -- faxrnd(adj_ptr.adjustment_amount,adj_ptr.book_type_code
   if (not FA_UTILS_PKG.faxrnd(X_amount => adj_ptr.adjustment_amount,
                               X_book   => adj_ptr.book_type_code,
                               X_set_of_books_id => adj_ptr.set_of_books_id,
                               p_log_level_rec => p_log_level_rec))then
      FA_SRVR_MSG.add_message(CALLING_FN => 'FA_INS_ADJUST_PKG.fadosglf', p_log_level_rec => p_log_level_rec);
      return (FALSE);
   end if;

   if adj_ptr.account_type='CIP_COST_ACCT' then
      h_adj_type:='CIP COST';
   else
      h_adj_type:=adj_ptr.adjustment_type;
   end if;

   adj_ptr.code_combination_id := h_calculated_ccid;
   adj_ptr.adjustment_type := h_adj_type;
   -- Call the function fainajc which performs the insert into
   -- FA_ADJUSTMENTS, caching the inserts if appropiate
   if (not fainajc
            (X_flush_mode        => FALSE,
             X_mode              => FALSE,
             X_last_update_date  => X_last_update_date,
             X_last_updated_by   => X_last_updated_by,
             X_last_update_login => X_last_update_login,
              p_log_level_rec     => p_log_level_rec)) then
      FA_SRVR_MSG.ADD_MESSAGE (CALLING_FN => 'FA_INS_ADJUST_PKG.fadosglf', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   adj_ptr.amount_inserted:=adj_ptr.adjustment_amount;
   if (p_log_level_rec.statement_level) then
      FA_DEBUG_PKG.ADD (fname   => 'FA_INS_ADJUST_PKG.fadosglf',
                        element => 'Amt Inserted-before return',
                        value   => adj_ptr.amount_inserted, p_log_level_rec => p_log_level_rec);
   end if;
   return TRUE;

exception
   when others then
        FA_SRVR_MSG.ADD_SQL_ERROR(CALLING_FN => 'FA_INS_ADJUST_PKG.fadosglf', p_log_level_rec => p_log_level_rec);
   return FALSE;

END fadosglf;

-----------------------------------------------------------------------

FUNCTION fadosgl(X_last_update_date date default sysdate,
                 X_last_updated_by  number default -1,
                 X_last_update_login number default -1, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return boolean is

   h_calculated_ccid   number;
   h_dist_id           number;
   h_adj_type          varchar2(20);

BEGIN <<fadosgl>>

   -- Calculate what CCID to use
   h_dist_id := adj_ptr.code_combination_id;
   if (not fadoflx
            (X_book_type_code   => adj_ptr.book_type_code,
             X_account_type     => adj_ptr.account_type,
             X_dist_ccid        => h_dist_id,
             X_spec_ccid        => adj_ptr.code_combination_id,
             X_account          => adj_ptr.account,
             X_calculated_ccid  => h_calculated_ccid,
             X_gen_ccid_flag    => adj_ptr.gen_ccid_flag,
             X_asset_id         => adj_ptr.asset_id,
             X_cat_id           => adj_ptr.selection_retid,
             X_distribution_id  => adj_ptr.distribution_id,
             X_source_type_code => adj_ptr.source_type_code,
              p_log_level_rec     => p_log_level_rec)) then
      FA_SRVR_MSG.ADD_MESSAGE (CALLING_FN =>'FA_GCCID_PKG.fadosgl', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- Round the amount_to_insert according to functional currency
   -- faxrnd(adj_ptr.adjustment_amount,adj_ptr.book_type_code
   if (not FA_UTILS_PKG.faxrnd(X_amount  => adj_ptr.adjustment_amount,
                               X_book    => adj_ptr.book_type_code,
                               X_set_of_books_id => adj_ptr.set_of_books_id,
                               p_log_level_rec => p_log_level_rec)) then
      FA_SRVR_MSG.add_message(CALLING_FN => 'FA_INS_ADJUST_PKG.fadosgl', p_log_level_rec => p_log_level_rec);
      return (FALSE);
   end if;

   if adj_ptr.account_type='CIP_COST_ACCT' then
      h_adj_type:='CIP COST';
   else
       h_adj_type:=adj_ptr.adjustment_type;
   end if;

   adj_ptr.code_combination_id := h_calculated_ccid;
   adj_ptr.adjustment_type := h_adj_type;

   -- Call the function fainajc which performs the insert into
   -- FA_ADJUSTMENTS, caching the inserts if appropiate

   if (not fainajc
              (X_flush_mode        => FALSE,
               X_mode              => FALSE,
               X_last_update_date  => X_last_update_date,
               X_last_updated_by   => X_last_updated_by,
               X_last_update_login => X_last_update_login,
              p_log_level_rec     => p_log_level_rec)) then
      FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN => 'FA_INS_ADJUST_PKG.fadosgl', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   adj_ptr.amount_inserted:=adj_ptr.adjustment_amount;
   return TRUE;

exception
   when others then
        FA_SRVR_MSG.ADD_SQL_ERROR(CALLING_FN => 'FA_INS_ADJUST_PKG.fadosgl', p_log_level_rec => p_log_level_rec);
        return FALSE;
END fadosgl;

-----------------------------------------------------------------

FUNCTION fadoret(X_last_update_date  date default sysdate,
                 X_last_updated_by   number default -1,
                 X_last_update_login number default -1, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return boolean is

   h_dist_book          varchar2(30);
   h_asset_id           number;
   h_success            boolean;
   h_distribution_lines number;
   h_distribution_id    number;
   h_trans_units        number;
   h_dist_ccid          number;
   h_calculated_ccid    number;
   h_ret_id             number;
   h_units_assigned     number;
   h_adj_type           varchar2(20);
   h_mesg_name          varchar2(30);
   h_row_ctr            number:=0;
   h_amount_so_far      number :=0;
   h_amount_to_insert   number:=0;
   h_adj_dd_amount      number;
   h_total_amount       number:=0;
   h_adjustment_amount  number :=0;

   CURSOR C1 IS
    SELECT DISTRIBUTION_ID,
           CODE_COMBINATION_ID,
           TRANSACTION_UNITS
      FROM FA_DISTRIBUTION_HISTORY
     WHERE ASSET_ID       = h_asset_id
       AND BOOK_TYPE_CODE = h_dist_book
       AND RETIREMENT_ID  = h_ret_id
     ORDER BY DISTRIBUTION_ID;

BEGIN  <<fadoret>>

   -- First store the passed adjustment amount in h_adjustment_amount
   -- This is done because adj_ptr.adjustment gets changed here and we
   -- need to retain the original passed value for calculation of amount for
   -- each distribution
   h_adjustment_amount := adj_ptr.adjustment_amount;

   -- Flush out the unposted rows in the cache to the db
   -- since there might be some pending rows out there.
   if (not fainajc
            (X_flush_mode        => TRUE,
             X_mode              => FALSE,
             X_last_update_date  => X_last_update_date,
             X_last_updated_by   => X_last_updated_by,
             X_last_update_login => X_last_update_login,
              p_log_level_rec     => p_log_level_rec)) then
      FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN => 'FA_INS_ADJUST_PKG.fadoret', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   h_asset_id           := adj_ptr.asset_id;
   h_ret_id             := adj_ptr.selection_retid;
   H_DPR_ROW.asset_id   := adj_ptr.asset_id;
   H_DPR_ROW.book       := adj_ptr.book_type_code;
   H_DPR_ROW.dist_id    := h_distribution_id;
   H_DPR_ROW.period_ctr := 0;
   H_DPR_ROW.mrc_sob_type_code := h_mrc_sob_type_code;
   H_DPR_ROW.set_of_books_id   := h_set_of_books_id;

   FA_QUERY_BALANCES_PKG.QUERY_BALANCES_INT(H_DPR_ROW,
                             'STANDARD',
                             FALSE,
                             H_SUCCESS,
                            'FA_INS_ADJUST_PKG.fadoret',
                            -1, p_log_level_rec => p_log_level_rec);
   -- Assign H_DPR_ROW to dpr_ptr. They are of same type
   dpr_ptr:=H_DPR_ROW;

   if (not factotp(total_amount=>h_total_amount,
                   adjustment_amount=>h_adjustment_amount,
                   p_log_level_rec => p_log_level_rec)) then
      FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN => 'FA_INS_ADJUST_PKG.fadoret', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   -- no need t call book controls cache here should already be loaded
   h_dist_book := FA_CACHE_PKG.fazcbc_record.distribution_source_book;
   h_mesg_name:='FA_INS_ADJ_CNT_ACTIVE';
   SELECT COUNT(*)
     INTO h_distribution_lines
     FROM FA_DISTRIBUTION_HISTORY
    WHERE ASSET_ID       = h_asset_id
      AND book_type_code = h_dist_book
      AND RETIREMENT_ID  = h_ret_id;

   if SQL%NOTFOUND THEN
      FA_SRVR_MSG.ADD_MESSAGE
         (NAME       => h_mesg_name,
          CALLING_FN => 'FA_GCCID_PKG.fadoret', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   h_mesg_name:='FA_INS_ADJ_DCUR_C1';
   for distn IN C1 loop
      h_distribution_id   := distn.distribution_id;
      h_mesg_name         := 'FA_INS_ADJ_FCUR_C1';
      h_dist_ccid         := distn.code_combination_id;
      h_trans_units       := distn.transaction_units;
      h_row_ctr           := h_row_ctr+1;
      H_DPR_ROW.asset_id  := adj_ptr.asset_id;
      H_DPR_ROW.book      := adj_ptr.book_type_code;
      H_DPR_ROW.dist_id   := h_distribution_id;
      H_DPR_ROW.period_ctr:= 0;
      H_DPR_ROW.mrc_sob_type_code := h_mrc_sob_type_code;
      H_DPR_ROW.set_of_books_id   := h_set_of_books_id;

      -- Get the FA_DEPRN_DETAIL value for the period_adjusted, plus/minus
      --  any adjustments by calling Query Fin Info in detail mode
      FA_QUERY_BALANCES_PKG.QUERY_BALANCES_INT(H_DPR_ROW,
                             'STANDARD',
                             FALSE,
                             H_SUCCESS,
                             -1, p_log_level_rec => p_log_level_rec);
      if not h_success then
         FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN => 'FA_GCCID_PKG.fadoret', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;
      -- Assign H_DPR_ROW to dpr_ptr. They are of same type
      dpr_ptr:=H_DPR_ROW;

      -- Calculate the detail amount to subtract for leveling
      -- Test change, always treat cost adjustments in as false
      if ((adj_ptr.leveling_flag=TRUE)) then
         if (not facdamt(h_adj_dd_amount,p_log_level_rec)) then
            FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN => 'FA_GCCID_PKG.fadoret', p_log_level_rec => p_log_level_rec);
            return FALSE;
         end if;
      else
         h_adj_dd_amount:=0;   -- Set to 0 if leveling off
      end if;

      if (h_row_ctr<>h_distribution_lines) then
-- bug 3205956.
--         h_amount_to_insert := (h_total_amount * h_trans_units/adj_ptr.units_retired)
--                                - h_adj_dd_amount;
         h_amount_to_insert := (h_total_amount * abs(h_trans_units)/adj_ptr.units_retired)
                                - h_adj_dd_amount;

      else
         h_amount_to_insert :=h_adjustment_amount - h_amount_so_far;
      end if;


      /* bug 3519644 */
      IF (NOT FA_UTILS_PKG.faxrnd(X_amount => h_amount_to_insert,
                                  X_book  => adj_ptr.book_type_code,
                                  X_set_of_books_id => adj_ptr.set_of_books_id,
                                  p_log_level_rec => p_log_level_rec)) THEN
         FA_SRVR_MSG.add_message(CALLING_FN => 'FA_INS_ADJUST_PKG.fadoret', p_log_level_rec => p_log_level_rec);
         return (FALSE);
      END IF;
      /* bug 3519644 */

      h_amount_so_far:=h_amount_so_far+h_amount_to_insert;
      if (p_log_level_rec.statement_level) then
         FA_DEBUG_PKG.ADD
               (fname   => 'FA_INS_ADJUST_PKG.fadoact',
                element => 'dist ccid in fadoact',
                value   => h_dist_ccid, p_log_level_rec => p_log_level_rec);
      end if;

      if (not fadoflx
                (X_book_type_code   => adj_ptr.book_type_code,
                 X_account_type     => adj_ptr.account_type,
                 X_dist_ccid        => h_dist_ccid,
                 X_spec_ccid        => adj_ptr.code_combination_id,
                 X_account          => adj_ptr.account,
                 X_calculated_ccid  => h_calculated_ccid,
                 X_gen_ccid_flag    => adj_ptr.gen_ccid_flag,
                 X_asset_id         => adj_ptr.asset_id,
                 X_cat_id           => adj_ptr.selection_retid,
                 X_distribution_id  => h_distribution_id,
                 X_source_type_code => adj_ptr.source_type_code,
              p_log_level_rec     => p_log_level_rec)) then
         FA_SRVR_MSG.ADD_MESSAGE
              (CALLING_FN => 'FA_GCCID_PKG.fadoact',
               NAME=>h_mesg_name, p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

      if adj_ptr.account_type='CIP_COST_ACCT' then
         h_adj_type:='CIP COST';
      else
         h_adj_type:=adj_ptr.adjustment_type;
      end if;

      adj_ptr.code_combination_id := h_calculated_ccid;
      adj_ptr.adjustment_type     := h_adj_type;
      adj_ptr.adjustment_amount   := h_amount_to_insert;
      adj_ptr.distribution_id     := h_distribution_id;

      if (not fainajc
                (X_flush_mode        => FALSE,
                 X_mode              => FALSE,
                 X_last_update_date  => X_last_update_date,
                 X_last_updated_by   => X_last_updated_by,
                 X_last_update_login => X_last_update_login,
              p_log_level_rec     => p_log_level_rec)) then
         FA_SRVR_MSG.ADD_MESSAGE (CALLING_FN => 'FA_INS_ADJUST_PKG.fadoret', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

   end loop;
   adj_ptr.amount_inserted := h_amount_so_far;
   return TRUE;

exception
   when others then
        FA_SRVR_MSG.ADD_SQL_ERROR(CALLING_FN => 'FA_INS_ADJUST_PKG.fadoret', p_log_level_rec => p_log_level_rec);
        return FALSE;

END fadoret;

-----------------------------------------------------------------

-- BUG# 2352985
-- removing rows from cache and resetting cache index upon failure
-- no dependancies unless code is ever implemented that uses the cache
-- for multiple transactions / assets without flushing (like fadcje)
--   bridgway

FUNCTION faxinaj(adj_ptr_passed      in out nocopy FA_ADJUST_TYPE_PKG.fa_adj_row_struct,
                 X_last_update_date  date   default sysdate,
                 X_last_updated_by   number default -1,
                 X_last_update_login number default -1, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return boolean is

BEGIN <<faxinaj>>

   -- Assign the passed values from adj_ptr_passed to adj_ptr.
   adj_ptr := adj_ptr_passed;

   -- put the mrc_sob_type in the global
   h_mrc_sob_type_code := nvl(adj_ptr_passed.mrc_sob_type_code, 'P');
   h_set_of_books_id   := adj_ptr_passed.set_of_books_id;

   IF (p_log_level_rec.statement_level) then
      FA_DEBUG_PKG.ADD
            (fname   => 'FA_INS_ADJUST_PKG.faxinaj',
             element => 'adj amt - first',
             value   => adj_ptr.adjustment_amount, p_log_level_rec => p_log_level_rec);
      FA_DEBUG_PKG.ADD
            (fname   => 'FA_INS_ADJUST_PKG.faxinaj',
             element => 'deprn_override_flag',
             value   => adj_ptr.deprn_override_flag, p_log_level_rec => p_log_level_rec);
   end if;

   if (adj_ptr.flush_adj_flag=TRUE AND adj_ptr.transaction_header_id=0) then
      -- Flush out the unposted rows in the cache to the DB
      if (not fainajc
               (X_flush_mode        => TRUE,
                X_mode              => FALSE,
                X_last_update_date  => X_last_update_date,
                X_last_updated_by   => X_last_updated_by,
                X_last_update_login => X_last_update_login,
              p_log_level_rec     => p_log_level_rec)) then
         adj_table.delete;
         h_cache_index := 0;

         FA_SRVR_MSG.ADD_MESSAGE (CALLING_FN => 'FA_INS_ADJUST_PKG.faxinaj', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;
   else
      -- round the adj_ptr.annualized_adjustment
      if (not FA_UTILS_PKG.faxrnd(X_amount => adj_ptr.annualized_adjustment,
                                  X_book   => adj_ptr.book_type_code,
                                  X_set_of_books_id => adj_ptr.set_of_books_id,
                                  p_log_level_rec => p_log_level_rec)) then
         adj_table.delete;
         h_cache_index := 0;

         FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN => 'FA_INS_ADJUST_PKG.faxinaj', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

      if (adj_ptr.selection_mode in (FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE , FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE_PARTIAL)) then
         if (not fadoact
                  (X_last_update_date  => X_last_update_date,
                   X_last_updated_by   => X_last_updated_by,
                   X_last_update_login => X_last_update_login,
              p_log_level_rec     => p_log_level_rec)) then
            adj_table.delete;
            h_cache_index := 0;

            FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN => 'FA_INS_ADJUST_PKG.faxinaj', p_log_level_rec => p_log_level_rec);
            return FALSE;
         end if;
      elsif (adj_ptr.selection_mode=FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE_REVAL) then -- YYOON
         if (not fadoact
                  (X_last_update_date  => X_last_update_date,
                   X_last_updated_by   => X_last_updated_by,
                   X_last_update_login => X_last_update_login,
              p_log_level_rec     => p_log_level_rec)) then
            adj_table.delete;
            h_cache_index := 0;

            FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN => 'FA_INS_ADJUST_PKG.faxinaj', p_log_level_rec => p_log_level_rec);
            return FALSE;
         end if;
      elsif (adj_ptr.selection_mode=FA_ADJUST_TYPE_PKG.FA_AJ_SINGLE) then
         if (not fadosgl
                  (X_last_update_date  => X_last_update_date,
                   X_last_updated_by   => X_last_updated_by,
                   X_last_update_login => X_last_update_login,
              p_log_level_rec     => p_log_level_rec)) then
            adj_table.delete;
            h_cache_index := 0;

            FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN => 'FA_INS_ADJUST_PKG.faxinaj', p_log_level_rec => p_log_level_rec);
            return FALSE;
         end if;
      elsif (adj_ptr.selection_mode=FA_ADJUST_TYPE_PKG.FA_AJ_TRANSFER_SINGLE) then
         if (not fadosglf
                  (X_last_update_date  => X_last_update_date,
                   X_last_updated_by   => X_last_updated_by,
                   X_last_update_login => X_last_update_login,
              p_log_level_rec     => p_log_level_rec)) then
            adj_table.delete;
            h_cache_index := 0;

            FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN => 'FA_INS_ADJUST_PKG.faxinaj', p_log_level_rec => p_log_level_rec);
            return FALSE;
         end if;
      elsif (adj_ptr.selection_mode in (FA_ADJUST_TYPE_PKG.FA_AJ_CLEAR, FA_ADJUST_TYPE_PKG.FA_AJ_CLEAR_PARTIAL)) then
         if (not fadoclr
                  (X_last_update_date  => X_last_update_date,
                   X_last_updated_by   => X_last_updated_by,
                   X_last_update_login => X_last_update_login,
              p_log_level_rec     => p_log_level_rec)) then
            adj_table.delete;
            h_cache_index := 0;

            FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN => 'FA_INS_ADJUST_PKG.faxinaj', p_log_level_rec => p_log_level_rec);
            return FALSE;
         end if;
      elsif (adj_ptr.selection_mode=FA_ADJUST_TYPE_PKG.FA_AJ_RETIRE) then
         if (not fadoret
                  (X_last_update_date  => X_last_update_date,
                   X_last_updated_by   => X_last_updated_by,
                   X_last_update_login => X_last_update_login,
              p_log_level_rec     => p_log_level_rec)) then
            adj_table.delete;
            h_cache_index := 0;

            FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN => 'FA_INS_ADJUST_PKG.faxinaj', p_log_level_rec => p_log_level_rec);
            return FALSE;
         end if;
      else
         -- undefined mode
         adj_table.delete;
         h_cache_index := 0;

         FA_SRVR_MSG.ADD_MESSAGE
            (CALLING_FN => 'FA_INS_ADJUST_PKG.faxinaj',
             NAME       => 'FA_INS_ADJ_BAD_MODE', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;     -- of adj_ptr.selection_mode
   end if;   -- end of else-not flush mode only

   if (adj_ptr.flush_adj_flag=TRUE AND adj_ptr.transaction_header_id<>0) then
      -- Flush out the inserts into the cache if the flush_adj_flag
      -- was set and we are not in "flush only" mode
      if (not fainajc
               (X_flush_mode        => TRUE,
                X_mode              => FALSE,
                X_last_update_date  => X_last_update_date,
                X_last_updated_by   => X_last_updated_by,
                X_last_update_login => X_last_update_login,
              p_log_level_rec     => p_log_level_rec)) then
         adj_table.delete;
         h_cache_index := 0;

         FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN => 'FA_INS_ADJUST_PKG.faxinaj', p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;
   end if;

   adj_ptr_passed.amount_inserted := adj_ptr.amount_inserted;

   IF (p_log_level_rec.statement_level) then
      FA_DEBUG_PKG.ADD
            (fname   => 'FA_INS_ADJUST_PKG.faxinaj',
             element => 'adj inserted - BEFORE RETURN',
             value   => adj_ptr_passed.amount_inserted, p_log_level_rec => p_log_level_rec);
   end if;
   return TRUE;

exception
  when others then
       FA_SRVR_MSG.ADD_SQL_ERROR(CALLING_FN => 'FA_INS_ADJUST_PKG.faxinaj', p_log_level_rec => p_log_level_rec);
       return FALSE;
END faxinaj;

-----------------------------------------------------------------

FUNCTION faxinadj (X_transaction_header_id   in number,
                   X_source_type_code        in varchar2,
                   X_adjustment_type         in varchar2,
                   X_debit_credit_flag           in varchar2,
                   X_code_combination_id     in number,
                   X_book_type_code           in varchar2,
                   X_period_counter_created  in number,
                   X_asset_id               in number,
                   X_adjustment_amount          in number,
                   X_period_counter_adjusted in number,
                   X_distribution_id          in number,
                   X_annualized_adjustment   in number,
                   X_last_update_date          in date default sysdate,
                   X_account               in varchar2,
                   X_account_type          in varchar2,
                   X_current_units          in number,
                   X_selection_mode          in varchar2,
                   X_flush_adj_flag          in varchar2,
                   X_gen_ccid_flag          in varchar2,
                   X_leveling_flag          in varchar2,
                   X_asset_invoice_id          in number,
                   X_amount_inserted          out nocopy number,
                   X_last_updated_by             number default -1,
                   X_last_update_login           number default -1,
                   X_init_message_flag           varchar2 default 'NO', p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return boolean is

   adj_ptr_local           FA_ADJUST_TYPE_PKG.fa_adj_row_struct;

BEGIN  <<faxinadj>>

   if (X_init_message_flag = 'YES') then
      -- initialize Message and Debug stacks
      FA_SRVR_MSG.Init_Server_Message;
      FA_DEBUG_PKG.Initialize;
   end if;

   -- Get the parameters passed by form
   adj_ptr_local.transaction_header_id   := X_transaction_header_id;
   adj_ptr_local.asset_invoice_id        := X_asset_invoice_id;
   adj_ptr_local.source_type_code        := X_source_type_code;
   adj_ptr_local.adjustment_type         := X_adjustment_type;
   adj_ptr_local.debit_credit_flag       := X_debit_credit_flag;
   adj_ptr_local.code_combination_id     := X_code_combination_id;
   adj_ptr_local.book_type_code          := X_book_type_code;
   adj_ptr_local.period_counter_created  := X_period_counter_created;
   adj_ptr_local.asset_id                := X_asset_id;
   adj_ptr_local.adjustment_amount       := X_adjustment_amount;
   adj_ptr_local.period_counter_adjusted := X_period_counter_adjusted;
   adj_ptr_local.distribution_id         := X_distribution_id;
   adj_ptr_local.annualized_adjustment   := X_annualized_adjustment;
   adj_ptr_local.last_update_date        := X_last_update_date;
   adj_ptr_local.account                 := X_account;
   adj_ptr_local.account_type            := X_account_type;

   if (X_current_units=0) then
      FA_SRVR_MSG.ADD_MESSAGE
             (CALLING_FN => 'FA_INS_ADJUST_PKG.faxinadj',
              NAME       => 'FA_INS_ADJ_ZERO_UNITS', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;
   adj_ptr_local.current_units := X_current_units;

   if (X_selection_mode='ACTIVE') then
      adj_ptr_local.selection_mode := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
   elsif (X_selection_mode='SINGLE') then
      adj_ptr_local.selection_mode := FA_ADJUST_TYPE_PKG.FA_AJ_SINGLE;
   else
      FA_SRVR_MSG.ADD_MESSAGE
             (CALLING_FN => 'FA_INS_ADJUST_PKG.faxinadj',
              NAME       => 'FA_INS_ADJ_BAD_SEL_MODE', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   if (X_flush_adj_flag='TRUE') then
      adj_ptr_local.flush_adj_flag := TRUE;
   elsif (X_flush_adj_flag='FALSE') then
      adj_ptr_local.flush_adj_flag:=FALSE;
   else
      FA_SRVR_MSG.ADD_MESSAGE
             (CALLING_FN => 'FA_INS_ADJUST_PKG.faxinadj',
              NAME       => 'FA_INS_ADJ_BAD_FLUSH_FLAG', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   if (X_gen_ccid_flag='TRUE') then
      adj_ptr_local.gen_ccid_flag := TRUE;
   elsif (X_gen_ccid_flag='FALSE') then
      adj_ptr_local.gen_ccid_flag:=FALSE;
   else
      FA_SRVR_MSG.ADD_MESSAGE
             (CALLING_FN => 'FA_INS_ADJUST_PKG.faxinadj',
              NAME       => 'FA_INS_ADJ_BAD_GEN_CCID_FLAG', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   if (X_leveling_flag='TRUE') then
      adj_ptr_local.leveling_flag := TRUE;
   else
      adj_ptr_local.leveling_flag:=FALSE;
   end if;

   adj_ptr_local.mrc_sob_type_code := 'P';

   -- Call the Insert into Adjustments Function
   if (not faxinaj
             (adj_ptr_local,
              X_last_update_date,
              X_last_updated_by,
              X_last_update_login,
              p_log_level_rec     => p_log_level_rec)) then
      FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN => 'FA_INS_ADJUST_PKG.faxinadj', p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   --Return the amount inserted to the form
   X_amount_inserted := adj_ptr_local.amount_inserted;
   return TRUE;

exception
   when others then
        FA_SRVR_MSG.ADD_SQL_ERROR(CALLING_FN => 'FA_INS_ADJUST_PKG.faxinadj', p_log_level_rec => p_log_level_rec);
        return FALSE;

END faxinadj;

END FA_INS_ADJUST_PKG;

/
