--------------------------------------------------------
--  DDL for Package Body FA_TRANSFER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_TRANSFER_PVT" AS
/* $Header: FAVTFRB.pls 120.9.12010000.6 2009/08/07 14:07:00 souroy ship $   */


FUNCTION faxzdrs (drs in out nocopy fa_std_types.fa_deprn_row_struct, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
         return boolean is

begin <<FAXZDRS>>
    drs.asset_id            := 0;
    drs.book                := '0';
    drs.dist_id             := 0;
    drs.period_ctr          := 0;
    drs.adjusted_flag       := FALSE;
    drs.deprn_exp           := 0;
    drs.reval_deprn_exp     := 0;
    drs.reval_amo           := 0;
    drs.prod                := 0;
    drs.ytd_deprn           := 0;
    drs.ytd_reval_deprn_exp := 0;
    drs.ytd_prod            := 0;
    drs.deprn_adjust_exp    := 0;
    drs.deprn_rsv           := 0;
    drs.reval_rsv           := 0;
    drs.ltd_prod            := 0;
    drs.cost                := 0;
    drs.adj_cost            := 0;
    drs.reval_amo_basis     := 0;
    drs.bonus_rate          := 0;
    drs.add_cost_to_clear   := 0;
    drs.deprn_source_code   := null;
    drs.bonus_deprn_amount        := 0; --
    drs.bonus_ytd_deprn           := 0;
    drs.bonus_deprn_rsv           := 0;
--    drs.bonus_deprn_adjust_exp    := 0;
--    drs.bonus_reval_deprn_exp     := 0;
--    drs.bonus_ytd_reval_deprn_exp := 0;

    drs.prior_fy_exp := 0;
    drs.prior_fy_bonus_exp := 0;

    return (TRUE);
end FAXZDRS;


FUNCTION faxidda
             (p_trans_rec       fa_api_types.trans_rec_type,
              p_asset_hdr_rec   fa_api_types.asset_hdr_rec_type,
              p_asset_desc_rec  fa_api_types.asset_desc_rec_type,
              p_asset_cat_rec   fa_api_types.asset_cat_rec_type,
              p_asset_dist_rec  fa_api_types.asset_dist_rec_type,
              cur_per_ctr       integer,
              adj_amts          in out nocopy fa_std_types.fa_deprn_row_struct,
              source            varchar2,
              reverse_flag      boolean,
              ann_adj_amts      fa_std_types.fa_deprn_row_struct,
              mrc_sob_type_code varchar2
             , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean is

   account              varchar2(40);
   adj                  fa_adjust_type_pkg.fa_adj_row_struct;
   h_interco_num        number;
   h_tfr_num            number;
   h_transaction_units  number;
   h_orig_units         number;

   X_LAST_UPDATE_DATE  date := sysdate;
   X_last_updated_by   number := -888;
   X_last_update_login number := -888;

   l_calling_fn       varchar2(40) := '';
   error_found        exception;

begin <<FAXIDDA>>

   adj.transaction_header_id   := p_trans_rec.transaction_header_id;
   adj.asset_invoice_id        := 0;
   adj.source_type_code        := source;
   adj.code_combination_id     := p_asset_dist_rec.expense_ccid;
   adj.book_type_code          := p_asset_hdr_rec.book_type_code;
   adj.period_counter_created  := cur_per_ctr;
   adj.asset_id                := p_asset_hdr_rec.asset_id;
   adj.period_counter_adjusted := cur_per_ctr;
   adj.distribution_id         := p_asset_dist_rec.distribution_id;
   adj.annualized_adjustment   := 0;
   adj.last_update_date        := p_trans_rec.who_info.last_update_date;
   adj.current_units           := p_asset_desc_rec.current_units;
   adj.selection_mode          := fa_adjust_type_pkg.FA_AJ_SINGLE;
   adj.selection_thid          := 0;
   adj.selection_retid         := 0;
   adj.flush_adj_flag          := TRUE;
   adj.leveling_flag           := TRUE;
   adj.annualized_adjustment   := 0;
   adj.mrc_sob_type_code       := mrc_sob_type_code;
   adj.set_of_books_id         := p_asset_hdr_rec.set_of_books_id;
   adj.gen_ccid_flag := TRUE;

   if not fa_cache_pkg.fazccb (p_asset_hdr_rec.book_type_code,
                               p_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
      raise error_found;
   end if;



   /* Insert FA_ADJUSTMENTS rows for all nonzero elements, and for */
   /* Deprn Expense even if zero */

   if TRUE then

      account               := fa_cache_pkg.fazccb_record.DEPRN_EXPENSE_ACCT;
      adj.adjustment_type   := 'EXPENSE';
      adj.debit_credit_flag := 'DR';

      if reverse_flag then
         adj.adjustment_amount     := -adj_amts.deprn_exp;
         adj_amts.deprn_exp        := -adj_amts.deprn_exp;
         adj.source_dest_code      := 'SOURCE';
      else
         adj.adjustment_amount     := adj_amts.deprn_exp;
         adj.annualized_adjustment := ann_adj_amts.deprn_exp;
         adj.source_dest_code      := 'DEST';
      end if;

      adj.account_type := 'DEPRN_EXPENSE_ACCT';
      adj.account      := account;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'adjustment_amount', adj.adjustment_amount, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'annualized', adj.annualized_adjustment, p_log_level_rec => p_log_level_rec);
      end if;

      if (NOT FA_INS_ADJUST_PKG.faxinaj(adj,
                                        X_last_update_date,
                                        X_last_updated_by,
                                        X_last_update_login, p_log_level_rec => p_log_level_rec)) then
         raise error_found;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'after faxinaj',1, p_log_level_rec => p_log_level_rec);
      end if;

   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'adj_amts.reval_deprn_exp', adj_amts.reval_deprn_exp, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'adj_amts.reval_amo ', adj_amts.reval_amo, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'adj_amts.deprn_rsv',  adj_amts.deprn_rsv, p_log_level_rec => p_log_level_rec);
   end if;


   if adj_amts.bonus_deprn_amount <> 0 then
      -- Post bonus_deprn_exp to BONUS_DEPRN_EXPENSE_ACCT,
      -- so use value of account/account_type (set above)

      account               := fa_cache_pkg.fazccb_record.BONUS_DEPRN_EXPENSE_ACCT;
      adj.adjustment_type   := 'BONUS EXPENSE';
      adj.debit_credit_flag :=  'DR';

      if reverse_flag then
         adj.adjustment_amount        := -adj_amts.bonus_deprn_amount;
         adj_amts.bonus_deprn_amount  := -adj_amts.bonus_deprn_amount;
         adj.source_dest_code         := 'SOURCE';
      else
         adj.adjustment_amount     := adj_amts.bonus_deprn_amount;
         adj.annualized_adjustment := ann_adj_amts.bonus_deprn_amount;
         adj.source_dest_code      := 'DEST';
      end if;

      adj.account_type  := 'BONUS_DEPRN_EXPENSE_ACCT';
      adj.account       := account;

      if (NOT FA_INS_ADJUST_PKG.faxinaj(adj,
                                        X_last_update_date,
                                        X_last_updated_by,
                                        X_last_update_login, p_log_level_rec => p_log_level_rec)) then

         raise error_found;
      end if;
   end if;

   if adj_amts.bonus_deprn_rsv <> 0 then

      -- Post bonus_deprn_rsv to BONUS_DEPRN_RESERVE_ACCT,
      -- so use value of account/account_type (set above)

      account               := fa_cache_pkg.fazccb_record.BONUS_DEPRN_RESERVE_ACCT;
      adj.adjustment_type   := 'BONUS RESERVE';
      adj.debit_credit_flag :=  'DR';

      if reverse_flag then
         adj.adjustment_amount     := -adj_amts.bonus_deprn_rsv;
         adj_amts.bonus_deprn_rsv  := -adj_amts.bonus_deprn_rsv;
         adj.source_dest_code         := 'SOURCE';
      else
         adj.adjustment_amount     := adj_amts.bonus_deprn_rsv;
         adj.annualized_adjustment := ann_adj_amts.bonus_deprn_rsv;
         adj.source_dest_code      := 'DEST';
      end if;

      adj.account_type  := 'BONUS_DEPRN_RESERVE_ACCT';
      adj.account       := account;

      if p_trans_rec.transaction_type_code = 'TRANSFER' then
         adj.source_type_code := 'TRANSFER';
      end if;

      if (NOT FA_INS_ADJUST_PKG.faxinaj(adj,
                                        X_last_update_date,
                                        X_last_updated_by,
                                        X_last_update_login, p_log_level_rec => p_log_level_rec)) then
         raise error_found;
      end if;
   end if;

   if adj_amts.reval_deprn_exp <> 0 then

      -- Post reval_deprn_exp to DEPRN_EXPENSE_ACCT,
      -- so use value of account/account_type (set above)

      account := fa_cache_pkg.fazccb_record.DEPRN_EXPENSE_ACCT;
      adj.debit_credit_flag := 'DR';
      adj.adjustment_type := 'REVAL EXPENSE';
      adj.debit_credit_flag :=  'DR';

      if reverse_flag then
         adj.adjustment_amount     := -adj_amts.reval_deprn_exp;
         adj_amts.reval_deprn_exp  := -adj_amts.reval_deprn_exp;
         adj.source_dest_code         := 'SOURCE';
      else
         adj.adjustment_amount     := adj_amts.reval_deprn_exp;
         adj.annualized_adjustment := ann_adj_amts.reval_deprn_exp;
         adj.source_dest_code      := 'DEST';
      end if;

      adj.account_type := 'DEPRN_EXPENSE_ACCT';
      adj.account      := account;

      if (NOT FA_INS_ADJUST_PKG.faxinaj(adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then

         raise error_found;
      end if;
   end if;

   if adj_amts.reval_amo <> 0 then

      account               := fa_cache_pkg.fazccb_record.REVAL_AMORTIZATION_ACCT;
      adj.adjustment_type   := 'REVAL AMORT'; -- bug 3233299
      adj.debit_credit_flag := 'DR';

      if reverse_flag then
         adj.adjustment_amount := -adj_amts.reval_amo;
         adj_amts.reval_amo    := -adj_amts.reval_amo;
         adj.source_dest_code         := 'SOURCE';
      else
         adj.adjustment_amount     := adj_amts.reval_amo;
         adj.annualized_adjustment := ann_adj_amts.reval_amo;
         adj.source_dest_code      := 'DEST';
      end if;

      adj.account      := account;
      adj.account_type := 'REVAL_AMORTIZATION_ACCT';

      if (NOT FA_INS_ADJUST_PKG.faxinaj(adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then
         raise error_found;
      end if;
   end if;

   if adj_amts.deprn_rsv <> 0 then

      account               := fa_cache_pkg.fazccb_record.DEPRN_RESERVE_ACCT;
      adj.adjustment_type   := 'RESERVE';
      adj.debit_credit_flag := 'DR';

      if reverse_flag then
         adj.adjustment_amount := -adj_amts.deprn_rsv;
         adj_amts.deprn_rsv    := -adj_amts.deprn_rsv;
         adj.source_dest_code  := 'SOURCE';
      else
         adj.adjustment_amount := adj_amts.deprn_rsv;
         adj.source_dest_code  := 'DEST';
      end if;

      adj.account      := account;
      adj.account_type := 'DEPRN_RESERVE_ACCT';


      if p_trans_rec.transaction_type_code = 'TRANSFER' then
         adj.source_type_code := 'TRANSFER';
      end if;


      if (NOT FA_INS_ADJUST_PKG.faxinaj(adj,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then

         raise error_found;
      end if;
   end if;


   -- SLA: interco logic is completely obsolete

   if adj_amts.reval_rsv <> 0 then

      account := fa_cache_pkg.fazccb_record.REVAL_RESERVE_ACCT;
      adj.adjustment_type   := 'REVAL RESERVE';
      adj.debit_credit_flag :='DR';

/* bug4277366
      if reverse_flag then
         adj.adjustment_amount := -adj_amts.reval_rsv;
         adj_amts.reval_rsv    := -adj_amts.reval_rsv;
      else
         adj.adjustment_amount := adj_amts.reval_rsv;
      end if;
*/
      adj.adjustment_amount := adj_amts.reval_rsv;

      adj.account := account;
      adj.account_type := 'REVAL_RESERVE_ACCT';

      if (NOT FA_INS_ADJUST_PKG.faxinaj(adj,
                                             X_last_update_date,
                                             X_last_updated_by,
                                             X_last_update_login, p_log_level_rec => p_log_level_rec)) then
         raise error_found;
      end if;
   end if;

   /* sla: obsolete - not needed at time of trx
   if not fa_drs_pkg.faxaadr (adj_amts, detail_amts, p_log_level_rec => p_log_level_rec) then
      raise error_found;
   end if;

   if not fa_drs_pkg.faxaadr (adj_amts, summary_amts, p_log_level_rec => p_log_level_rec) then
      raise error_found;
   end if;
   */

   if p_log_level_rec.statement_level then
      fa_debug_pkg.add(l_calling_fn,'END',1, p_log_level_rec => p_log_level_rec);
   end if;

   return (TRUE);

exception
   when error_found then
        fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return (FALSE);

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return (FALSE);

end FAXIDDA;
/*===========================================================================+
 |                                                                           |
 |   faxrda                                                                  |
 |                                                                           |
 |   FA Utility Reverse Depreciation and Adjustments                         |
 |                                                                           |
 +===========================================================================*/
FUNCTION faxrda (p_trans_rec       fa_api_types.trans_rec_type,
                 p_asset_hdr_rec   fa_api_types.asset_hdr_rec_type,
                 p_asset_desc_rec  fa_api_types.asset_desc_rec_type,
                 p_asset_cat_rec   fa_api_types.asset_cat_rec_type,
                 p_asset_dist_rec  fa_api_types.asset_dist_rec_type,
                 cur_per_ctr       integer,
                 from_per_ctr      integer,
                 adj_amts          in out nocopy fa_std_types.fa_deprn_row_struct,
                 ins_adj_flag      boolean,
                 source            varchar2,
                 mrc_sob_type_code varchar2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean is

   fy                 integer(5);
   period_fracs       fa_std_types.table_fa_cp_struct;

   frac_to_backout    number;
   from_fy            integer(5);
   adj_to_retain      number;

   adj_deprn          fa_std_types.fa_deprn_row_struct;
   ann_adj_amts       fa_std_types.fa_deprn_row_struct;

   dd_deprn_exp       number;
   dd_reval_deprn_exp number;
   dd_reval_amo       number;
   deprn_calendar     varchar2(30);
   pers_per_yr        integer(5);
   b                  boolean;
   dd_bonus_deprn_exp number;

   aj_per_ctr_created    number;
   aj_adj_dr             number;
   aj_ann_adj_dr         number;
   aj_adj_type           varchar2(30);

   l_calling_fn       varchar2(40) := 'faxrda';
   error_found        exception;

   /* Bug 3810323 */
   tot_per               integer;
   no_of_per_to_exclude  integer;
   prev_trx_id           number(15);
   prev_from_ctr_trx     number(15);
   prev_from_ctr_eff     number(15);



   CURSOR AJ IS
        SELECT aj.period_counter_created per_ctr_created,
               decode (aj.debit_credit_flag,
                       'DR', aj.adjustment_amount,
                       'CR', -aj.adjustment_amount,
                       0) adj_dr,
               decode (aj.debit_credit_flag,
                       'DR', aj.annualized_adjustment,
                       'CR', -aj.annualized_adjustment,
                       0) ann_adj_dr,
               decode (aj.adjustment_type,
                       'EXPENSE',              1,
                       'REVAL EXPENSE',        2,
                       'REVAL AMORT',          3, -- BUG# 3233299
                       'RESERVE',              4,
                       'REVAL RESERVE',        5,
                       'BONUS EXPENSE',        6,
                       'BONUS RESERVE',        7,
                       0) adj_type
          FROM fa_adjustments aj
         WHERE aj.book_type_code  = p_asset_hdr_rec.book_type_code
           AND aj.asset_id        = p_asset_hdr_rec.asset_id
           AND aj.distribution_id = p_asset_dist_rec.distribution_id
           AND aj.period_counter_created between
                       from_per_ctr and cur_per_ctr
           AND aj.adjustment_type||'' <> 'RESERVE'
           AND decode (aj.adjustment_type,
                       'EXPENSE',              1,
                       'REVAL EXPENSE',        2,
                       'REVAL AMORT',          3,
                       'RESERVE',              4,
                       'REVAL RESERVE',        5,
                       'BONUS EXPENSE',        6,
                       'BONUS RESERVE',        7,
                       0) <> 0;


   CURSOR MRC_AJ IS
        SELECT aj.period_counter_created per_ctr_created,
               decode (aj.debit_credit_flag,
                       'DR', aj.adjustment_amount,
                       'CR', -aj.adjustment_amount,
                       0) adj_dr,
               decode (aj.debit_credit_flag,
                       'DR', aj.annualized_adjustment,
                       'CR', -aj.annualized_adjustment,
                       0) ann_adj_dr,
               decode (aj.adjustment_type,
                       'EXPENSE',              1,
                       'REVAL EXPENSE',        2,
                       'REVAL AMORT',          3,  -- BUG# 3233299
                       'RESERVE',              4,
                       'REVAL RESERVE',        5,
                       'BONUS EXPENSE',        6,
                       'BONUS RESERVE',        7,
                       0) adj_type
          FROM fa_mc_adjustments aj
         WHERE aj.book_type_code  = p_asset_hdr_rec.book_type_code
           AND aj.asset_id        = p_asset_hdr_rec.asset_id
           AND aj.distribution_id = p_asset_dist_rec.distribution_id
           AND aj.set_of_books_id = p_asset_hdr_rec.set_of_books_id
           AND aj.period_counter_created between
                  from_per_ctr and cur_per_ctr
           AND aj.adjustment_type||'' <> 'RESERVE'
           AND decode (aj.adjustment_type,
                       'EXPENSE',              1,
                       'REVAL EXPENSE',        2,
                       'REVAL AMORT',          3,
                       'RESERVE',              4,
                       'REVAL RESERVE',        5,
                       'BONUS EXPENSE',        6,
                       'BONUS RESERVE',        7,
                       0) <> 0;


    -- Get Fractions for all periods in Fiscal Year containing Cur_Per_Ctr
    -- and From_Per_Ctr; cache this information for future use

begin <<FAXRDA>>

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add('FAXRDA','dist_id',p_asset_dist_rec.distribution_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'from_per_ctr', from_per_ctr, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'cur_per_ctr',  cur_per_ctr, p_log_level_rec => p_log_level_rec);
   end if;

   deprn_calendar:=fa_cache_pkg.fazcbc_record.DEPRN_CALENDAR;

   if not fa_cache_pkg.fazcct (deprn_calendar, p_log_level_rec => p_log_level_rec) then
      raise error_found;
   end if;

   pers_per_yr := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;

   fy      := trunc((cur_per_ctr-1)  / pers_per_yr);  -- Integer\
   from_fy := trunc((from_per_ctr-1) / pers_per_yr);  -- Division

   if from_fy <> fy then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                              name       => 'FA_RDA_BACKOUT_ACROSS_YEARS', p_log_level_rec => p_log_level_rec);
      raise error_found;
   end if;

   if not fa_cache_pkg.fazcff (deprn_calendar,
                               p_asset_hdr_rec.book_type_code,
                               fy,
                               period_fracs, p_log_level_rec => p_log_level_rec) then
      raise error_found;
   end if;


   -- Get information from FA_DEPRN_DETAIL for the Distribution requested

   begin
      if (mrc_sob_type_code = 'R') then

         SELECT nvl (sum (dd.deprn_amount), 0),
                nvl (sum (dd.reval_deprn_expense), 0),
                nvl (sum (dd.reval_amortization), 0),
                nvl (sum (nvl(dd.bonus_deprn_amount,0)), 0)
           INTO dd_deprn_exp,
                dd_reval_deprn_exp,
                dd_reval_amo,
                dd_bonus_deprn_exp
           FROM fa_mc_deprn_detail dd
          WHERE dd.book_type_code  = p_asset_hdr_rec.book_type_code
            AND dd.asset_id        = p_asset_hdr_rec.asset_id
            AND dd.distribution_id = p_asset_dist_rec.distribution_id
            AND dd.period_counter  between
                    from_per_ctr and cur_per_ctr
            AND dd.set_of_books_id = p_asset_hdr_rec.set_of_books_id;
      else
         SELECT nvl (sum (dd.deprn_amount), 0),
                nvl (sum (dd.reval_deprn_expense), 0),
                nvl (sum (dd.reval_amortization), 0),
                nvl (sum (nvl(dd.bonus_deprn_amount,0)), 0)
           INTO dd_deprn_exp,
                dd_reval_deprn_exp,
                dd_reval_amo,
                dd_bonus_deprn_exp
           FROM fa_deprn_detail dd
          WHERE dd.book_type_code  = p_asset_hdr_rec.book_type_code
            AND dd.asset_id        = p_asset_hdr_rec.asset_id
            AND dd.distribution_id = p_asset_dist_rec.distribution_id
            AND dd.period_counter  between
                    from_per_ctr and cur_per_ctr;
      end if;
   exception
      when others then
           null;
   end;



    /* Fix for bug 3810323 - start */

    tot_per := 0;
    no_of_per_to_exclude := 0;
    prev_trx_id := 0;
    prev_from_ctr_trx := 0;
    prev_from_ctr_eff := 0;

    /* Check if the current prior period transfer overlaps the previous one */
    begin
       select max(trx.transaction_header_id)
       into prev_trx_id
       from fa_transaction_headers trx
       where  trx.book_type_code = p_asset_hdr_rec.book_type_code
         and  trx.asset_id = p_asset_hdr_rec.asset_id
         and  trx.transaction_type_code = 'TRANSFER'
         and  trx.transaction_header_id < p_trans_rec.transaction_header_id
         and  exists
              (select 1
               from fa_transaction_headers trx2,
                    fa_deprn_periods dp_trx,
                    fa_deprn_periods dp_eff
               where trx2.transaction_header_id=trx.transaction_header_id
                 and trx2.transaction_date_entered between dp_trx.calendar_period_open_date
                                                       and dp_trx.calendar_period_close_date
                 and dp_trx.book_type_code=trx2.book_type_code
                 and trx2.date_effective between dp_eff.period_open_date
                                             and dp_eff.period_close_date
                 and dp_eff.book_type_code=trx2.book_type_code
                 and dp_trx.period_counter < dp_eff.period_counter
                 and from_per_ctr > dp_trx.period_counter
                 and from_per_ctr < dp_eff.period_counter
              )
       ;
    exception
      when no_data_found then
         null;
    end;


    if (prev_trx_id >= 1) then

       begin
           select dp1.period_counter
                 ,dp2.period_counter
           into   prev_from_ctr_trx
                 ,prev_from_ctr_eff
           from   fa_transaction_headers trx,
                  fa_deprn_periods dp1,
                  fa_deprn_periods dp2
           where  trx.transaction_header_id=prev_trx_id
             and  dp1.book_type_code = trx.book_type_code
             and  trx.transaction_date_entered between dp1.CALENDAR_PERIOD_OPEN_DATE
                                                   and dp1.CALENDAR_PERIOD_CLOSE_DATE
             and  dp2.book_type_code = trx.book_type_code
             and  trx.date_effective between dp2.period_open_date
                                         and dp2.period_close_date
           ;
      exception
        when no_data_found then
           raise error_found;
      end;

      tot_per := cur_per_ctr - prev_from_ctr_trx;
      no_of_per_to_exclude :=  from_per_ctr - prev_from_ctr_trx;

   end if;

   /*Fix for 3810323 - end*/



   if p_log_level_rec.statement_level then
      fa_debug_pkg.add(l_calling_fn,'dd_deprn_exp to reverse', dd_deprn_exp, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,'dd_reval_deprn_exp to reverse', dd_reval_deprn_exp, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,'dd_reval_amo to reverse ', dd_reval_amo, p_log_level_rec => p_log_level_rec);
   end if;


   -- Get information from FA_ADJUSTMENTS for the Distribution requested

   b := faxzdrs (adj_deprn,p_log_level_rec);
   b := faxzdrs (ann_adj_amts,p_log_level_rec);

   if p_log_level_rec.statement_level then
      fa_debug_pkg.add(l_calling_fn,'opening', 'aj cursor', p_log_level_rec => p_log_level_rec);
   end if;

   if (mrc_sob_type_code = 'R') then
      open mrc_aj;
   else
      open aj;
   end if;

   LOOP

      if p_log_level_rec.statement_level then
         fa_debug_pkg.add(l_calling_fn,'fetching', 'aj cursor', p_log_level_rec => p_log_level_rec);
      end if;

      if (mrc_sob_type_code = 'R') then
         fetch mrc_aj
          into aj_per_ctr_created    ,
               aj_adj_dr             ,
               aj_ann_adj_dr         ,
               aj_adj_type           ;
         EXIT WHEN MRC_AJ%NOTFOUND OR MRC_AJ%NOTFOUND IS NULL;
      else
         fetch aj
          into aj_per_ctr_created    ,
               aj_adj_dr             ,
               aj_ann_adj_dr         ,
               aj_adj_type           ;
         EXIT WHEN AJ%NOTFOUND OR AJ%NOTFOUND IS NULL;
      end if;

      frac_to_backout := 0;

      if p_log_level_rec.statement_level then
         fa_debug_pkg.add(l_calling_fn,'starting', 'fy calc', p_log_level_rec => p_log_level_rec);
      end if;

      for i in  mod(from_per_ctr-1,fy)..mod(aj_per_ctr_created-1,fy)-1 loop
          frac_to_backout := frac_to_backout + period_fracs(i).frac;
      end loop;

      if p_log_level_rec.statement_level then
         fa_debug_pkg.add(l_calling_fn,'calcing', 'adj_to_retain1', p_log_level_rec => p_log_level_rec);
      end if;

      adj_to_retain := aj_adj_dr - frac_to_backout * aj_ann_adj_dr;

      b := FA_UTILS_PKG.faxrnd ( adj_to_retain, p_asset_hdr_rec.book_type_code, p_asset_hdr_rec.set_of_books_id,  p_log_level_rec => p_log_level_rec);

      if p_log_level_rec.statement_level then
         fa_debug_pkg.add(l_calling_fn,'calcing', 'adj_to_retain2', p_log_level_rec => p_log_level_rec);
      end if;

      if (adj_to_retain*aj_adj_dr < 0) or
         (adj_to_retain=0 and aj_adj_dr <> 0) or
         (aj_adj_dr = 0 and  adj_to_retain <> 0) then
         adj_to_retain := 0;
      end if;

      if p_log_level_rec.statement_level then
         fa_debug_pkg.add(l_calling_fn,'entering', 'main branching', p_log_level_rec => p_log_level_rec);
      end if;

      if aj_adj_type = 0 then
         null;
      elsif aj_adj_type = 1 then
         adj_deprn.deprn_exp := adj_to_retain + adj_deprn.deprn_exp;
      elsif aj_adj_type = 2 then
         adj_deprn.reval_deprn_exp := adj_deprn.reval_deprn_exp + adj_to_retain;
      elsif aj_adj_type = 3 then
         adj_deprn.reval_amo := adj_deprn.reval_amo + adj_to_retain;
      elsif aj_adj_type = 4 then
         adj_deprn.deprn_rsv := adj_deprn.deprn_rsv + adj_to_retain;
      elsif aj_adj_type = 5 then
         adj_deprn.reval_rsv := adj_deprn.reval_rsv + adj_to_retain;
      elsif aj_adj_type = 6 then
         adj_deprn.bonus_deprn_amount := adj_deprn.bonus_deprn_amount + adj_to_retain;
      elsif aj_adj_type = 7 then
         adj_deprn.bonus_deprn_rsv := adj_deprn.bonus_deprn_rsv + adj_to_retain;
      else
         fa_srvr_msg.add_message (calling_fn => 'l_calling_fn',
                                  name         => 'switch', p_log_level_rec => p_log_level_rec);
         raise error_found;
      end if;

   end loop;

   if p_log_level_rec.statement_level then
      fa_debug_pkg.add(l_calling_fn,'closing', 'aj cursor', p_log_level_rec => p_log_level_rec);
   end if;

   if (mrc_sob_type_code = 'R') then
      close mrc_aj;
   else
      close aj;
   end if;

   if p_log_level_rec.statement_level then
      fa_debug_pkg.add(l_calling_fn,'getting', 'total reserveral amounts', p_log_level_rec => p_log_level_rec);
   end if;

   /* Fix for bug 3810323: commented out this

   -- Set ADJ = DD - Tot_Adj_To_Reverse
   -- BUG# 3296373 : adding this if condition
   if (adj_deprn.deprn_exp <> 0) then
      adj_amts.deprn_exp      := adj_deprn.deprn_exp;
   else
      adj_amts.deprn_exp      := dd_deprn_exp       - adj_deprn.deprn_exp;
   end if;

   adj_amts.reval_deprn_exp   := dd_reval_deprn_exp - adj_deprn.reval_deprn_exp;
   adj_amts.reval_amo         := dd_reval_amo       - adj_deprn.reval_amo;
   adj_amts.bonus_deprn_amount := dd_bonus_deprn_exp - adj_deprn.bonus_deprn_amount;

   -- RKP: offset the deprn_exp's effect on rsv; reval_exp also
   adj_amts.deprn_rsv := adj_amts.deprn_exp;
   adj_amts.reval_rsv := adj_amts.reval_deprn_exp;
  */

  /* Fix for bug 3810323 - start*/

   adj_amts.deprn_exp := dd_deprn_exp - adj_deprn.deprn_exp;

   if ((prev_trx_id > 0) and (tot_per <> 0) and (no_of_per_to_exclude <> 0)) then

     adj_amts.deprn_exp := dd_deprn_exp - (no_of_per_to_exclude * (dd_deprn_exp / tot_per));
     b := fa_utils_pkg.faxrnd(adj_amts.deprn_exp, p_asset_hdr_rec.book_type_code, p_asset_hdr_rec.set_of_books_id, p_log_level_rec => p_log_level_rec);

   end if;

   adj_amts.reval_deprn_exp   := dd_reval_deprn_exp - adj_deprn.reval_deprn_exp;
   adj_amts.reval_amo         := dd_reval_amo       - adj_deprn.reval_amo;
   adj_amts.bonus_deprn_amount   := adj_deprn.bonus_deprn_amount - adj_amts.bonus_deprn_amount;

   adj_amts.deprn_rsv := adj_amts.deprn_exp;
   adj_amts.reval_rsv := adj_amts.reval_deprn_exp;


  /* Fix for bug 3810323 - end*/

   if p_log_level_rec.statement_level then
      fa_debug_pkg.add(l_calling_fn,'calling', 'faxidda', p_log_level_rec => p_log_level_rec);
   end if;

   if ins_adj_flag then
      if not faxidda (p_trans_rec,
                      p_asset_hdr_rec ,
                      p_asset_desc_rec ,
                      p_asset_cat_rec  ,
                      p_asset_dist_rec  ,
                      cur_per_ctr,
                      adj_amts,
                      source,
                      TRUE,
                      ann_adj_amts,
                      mrc_sob_type_code,
                      p_log_level_rec) then
         raise error_found;
      end if;
   end if;

   return (TRUE);

Exception
   when error_found then
        fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return (FALSE);

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return (FALSE);

end FAXRDA;


/*===========================================================================+
 |  NAME                                                                     |
 |      fadgdd - get prior pd deprn detail                                   |
 |                                                                           |
 +===========================================================================*/

FUNCTION fadgdd (p_trans_rec       fa_api_types.trans_rec_type,
                 p_asset_hdr_rec   fa_api_types.asset_hdr_rec_type,
                 p_asset_desc_rec  fa_api_types.asset_desc_rec_type,
                 p_asset_cat_rec   fa_api_types.asset_cat_rec_type,
                 p_asset_dist_rec  fa_api_types.asset_dist_rec_type,
                 p_period_rec      fa_api_types.period_rec_type,
                 from_per_ctr      integer,
                 drs               in out nocopy fa_std_types.fa_deprn_row_struct,
                 backout_flag      boolean,
                 mrc_sob_type_code varchar2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)  return boolean is

    dist                fa_std_types.dh_adj_type;
    counter             integer(4);
    b                   boolean;

    -- BUG 1301957:
    --  ann_adj_amts has been created
    --  to store annulized adjustment amounts - YYOON

    ann_adj_amts         fa_std_types.fa_deprn_row_struct;
    i_temp              number;
    num_of_periods      number;

    cur_per_ctr    number;
    period_num     number;
    ccp_start_date date;
    ccp_end_date   date;
    cp_start_date  date;
    cp_end_date    date;

    l_calling_fn       varchar2(40) := 'fadgdd';
    error_found        exception;


begin <<FADGDD>>

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'dist_id',      p_asset_dist_rec.distribution_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'from_per_ctr', from_per_ctr, p_log_level_rec => p_log_level_rec);
   end if;

   cur_per_ctr    := p_period_rec.period_counter;
   period_num     := p_period_rec.period_num;
   ccp_start_date := p_period_rec.calendar_period_open_date;
   ccp_end_date   := p_period_rec.calendar_period_close_date;
   cp_start_date  := p_period_rec.period_open_date;
   cp_end_date    := sysdate;

   counter := 1;

   -- BUG1301957:
   -- Initialize ann_adj_amts - YYOON

   b:= faxzdrs (ann_adj_amts,p_log_level_rec);


   if backout_flag then

      -- Backing out depreciation from terminated distribution
      if p_log_level_rec.statement_level then
         fa_debug_pkg.add(l_calling_fn,'calling faxrda',1, p_log_level_rec => p_log_level_rec);
      end if;

      if not faxrda
                            (p_trans_rec,
                             p_asset_hdr_rec,
                             p_asset_desc_rec,
                             p_asset_cat_rec,
                             p_asset_dist_rec,
                             cur_per_ctr,
                             from_per_ctr,
                             drs,
                             TRUE,
                             'DEPRECIATION',
                             mrc_sob_type_code,
                             p_log_level_rec) then
         raise error_found;
      end if;

      -- Now flip sign of the adjustment amounts we reversed out

      drs.deprn_exp       := -drs.deprn_exp;
      drs.reval_deprn_exp := -drs.reval_deprn_exp;
      drs.reval_amo       := -drs.reval_amo;
      drs.deprn_rsv       := -drs.deprn_rsv;
      drs.reval_rsv       := -drs.reval_rsv;


      -- excluding deprn_adj_exp updates as this will be done by deprn

      if p_log_level_rec.statement_level then
         fa_debug_pkg.add(l_calling_fn,'flip backout drs.deprn_rsv', drs.deprn_rsv, p_log_level_rec => p_log_level_rec);
      end if;

      drs.bonus_deprn_amount := -drs.bonus_deprn_amount;
      drs.bonus_deprn_rsv := -drs.bonus_deprn_rsv;

   else

      if p_log_level_rec.statement_level then
         fa_debug_pkg.add(l_calling_fn,'backout_flag', 'FALSE', p_log_level_rec => p_log_level_rec);
      end if;

      -- Moving backed out depreciation to created distribution

      -- BUG# 1527238
      -- fix is obsolete as this will be processed immediately upon
      -- transfer transaction so category is always the same

      -- BUG 1301957:
      -- Get the number of periods in a fiscal year
      -- YYOON on 6/13/01

      num_of_periods := fa_cache_pkg.fazcct_record.number_per_fiscal_year;

      -- BUG 1301957:
      --  The following routine calculates annualized adjustment amounts
      --  and copy them to ann_adj_amts structure.
      --  - YYOON on 6/13/01

      ann_adj_amts.deprn_exp          := drs.deprn_exp * num_of_periods;
      ann_adj_amts.reval_deprn_exp    := drs.reval_deprn_exp *
                                                num_of_periods;
      ann_adj_amts.reval_amo          := drs.reval_amo * num_of_periods;
      ann_adj_amts.bonus_deprn_amount := drs.bonus_deprn_amount * num_of_periods;

      if p_log_level_rec.statement_level then
         fa_debug_pkg.add(l_calling_fn,' calling faxidda',1, p_log_level_rec => p_log_level_rec);
      end if;

      if not faxidda
                      (p_trans_rec,
                       p_asset_hdr_rec ,
                       p_asset_desc_rec ,
                       p_asset_cat_rec  ,
                       p_asset_dist_rec  ,
                       cur_per_ctr,
                       drs,
                       'DEPRECIATION',
                       FALSE,
                       ann_adj_amts,
                       mrc_sob_type_code,
                       p_log_level_rec) then
         raise error_found;
      end if;

   end if;

   return (TRUE);

exception
   when error_found then
        fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return (FALSE);

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return (FALSE);

end FADGDD;

/*===========================================================================+
 |  NAME                                                                     |
 |      fadppt                                                               |
 |                                                                           |
 |  FUNCTION                                                                 |
 |      Calculates depreciation for a prior period transfer.                 |
 |                                                                           |
 |  NOTES                                                                    |
 +===========================================================================*/

FUNCTION fadppt (p_trans_rec       fa_api_types.trans_rec_type,
                 p_asset_hdr_rec   fa_api_types.asset_hdr_rec_type,
                 p_asset_desc_rec  fa_api_types.asset_desc_rec_type,
                 p_asset_cat_rec   fa_api_types.asset_cat_rec_type,
                 p_asset_dist_tbl  fa_api_types.asset_dist_tbl_type
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean is

   b                 boolean;
   total_dep_backout number;
   total_ua_backout  number;
   backout_share     number;
   backout_taken     number;
   old_backout_taken number;
   dist_total_deprn  number;    /* total deprn for a dist record */
   row_ctr           integer;
   row_ctr_temp      integer :=0;   /* bug# 5523484*/
   dist_book         varchar2(30);

   backout_drs       fa_std_types.fa_deprn_row_struct;
   total_backout_drs fa_std_types.fa_deprn_row_struct;
   insert_drs        fa_std_types.fa_deprn_row_struct;
   taken_drs         fa_std_types.fa_deprn_row_struct;

   ppd_ctr           integer;
   in_dist           integer;
   units_assigned    number;
   trans_id          integer;
   deprn_calendar    varchar2(30);
   pers_per_yr       integer(5);
   fy_name           varchar2(30);

   cur_period_ctr number;
   period_num     number;
   ccp_start_date date;
   ccp_end_date   date;
   cp_start_date  date;
   cp_end_date    date;

   l_mrc_sob_type_code varchar2(1);

   l_asset_hdr_rec    fa_api_types.asset_hdr_rec_type;
   l_asset_dist_rec   fa_api_types.asset_dist_rec_type;
   l_period_rec       fa_api_types.period_rec_type;

   l_calling_fn       varchar2(40) := 'fadgdd';
   error_found        exception;

   -- C3 not needed since we're taking in dist_tbl
   -- adding new cursor just to get dist id from new distributions
   CURSOR c_dist_id (p_asset_id     number,
                     p_expense_ccid number,
                     p_location_id  number,
                     p_assigned_to  number) is
     select distribution_id
       from fa_distribution_history
      where asset_id                = p_asset_id
        and nvl(assigned_to,-9999) = nvl(p_assigned_to,-9999)
        and code_combination_id    = p_expense_ccid
        and location_id            = p_location_id
        and date_ineffective      is null;

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


begin <<FADPPT>>

   -- moving logic from fadgbi here:
   -- load the cache for current period counter

   dist_book      := fa_cache_pkg.fazcbc_record.distribution_source_book;
   deprn_calendar := fa_cache_pkg.fazcbc_record.deprn_calendar;
   fy_name        := fa_cache_pkg.fazcbc_record.fiscal_year_name;

   if not fa_util_pvt.get_period_rec
           (p_book           => p_asset_hdr_rec.book_type_code,
            x_period_rec     => l_period_rec, p_log_level_rec => p_log_level_rec) then
      raise error_found;
   end if;

   cur_period_ctr := l_period_rec.period_counter;
   period_num     := l_period_rec.period_num;
   ccp_start_date := l_period_rec.calendar_period_open_date;
   ccp_end_date   := l_period_rec.calendar_period_close_date;
   cp_start_date  := l_period_rec.period_open_date;
   cp_end_date    := sysdate;

   if not fa_cache_pkg.fazcct
           (x_calendar => deprn_calendar, p_log_level_rec => p_log_level_rec) then
      raise error_found;
   end if;

   pers_per_yr    := fa_cache_pkg.fazcct_record.number_per_fiscal_year;

   if p_log_level_rec.statement_level then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                              name       => 'FA_DEPRN_DEBUG2',
                              token1     => 'CCP_DATE',
                              value1     => ccp_start_date,
                              token2     => 'CP_DATE',
                              value2     => cp_start_date, p_log_level_rec => p_log_level_rec);
   end if;

   backout_taken     := 0;
   old_backout_taken := 0;

   SELECT cp.period_num + (pers_per_yr * fy.fiscal_year)
     INTO ppd_ctr
     FROM fa_calendar_periods cp,
          fa_calendar_types ct,
          fa_fiscal_year fy
    WHERE p_trans_rec.transaction_date_entered
              between cp.start_date and cp.end_date
      AND cp.calendar_type = deprn_calendar
      AND ct.calendar_type = cp.calendar_type
      AND p_trans_rec.transaction_date_entered
              between fy.start_date and fy.end_date
      AND fy.fiscal_year_name = fy_name;


   row_ctr           := 0;
   total_dep_backout := 0;
   total_ua_backout  := 0;

   -- continue until all distribution records are found

   if fa_cache_pkg.fazcbc_record.book_class = 'TAX' then
      trans_id := p_trans_rec.source_transaction_header_id;
   else
      trans_id := p_trans_rec.transaction_header_id;
   end if;

   -- first determine total units effected
   for row_ctr in 1..p_asset_dist_tbl.count loop --C3
      if (p_asset_dist_tbl(row_ctr).distribution_id is null) then
         total_ua_backout := total_ua_backout +
                             p_asset_dist_tbl(row_ctr).transaction_units;
      end if;
   end loop;

   --total_ua_backout := -total_ua_backout;

   l_asset_hdr_rec :=  p_asset_hdr_rec;

   -- loop through primary and reportign and then through each distribution
   for c_rec in n_sob_id(fa_cache_pkg.fazcbc_record.set_of_books_id,
                         p_asset_hdr_rec.book_type_code) loop

      b := faxzdrs (backout_drs, p_log_level_rec);
      b := faxzdrs (total_backout_drs, p_log_level_rec);
      b := faxzdrs (insert_drs, p_log_level_rec);
      b := faxzdrs (taken_drs, p_log_level_rec);

      if (c_rec.index_id = 1) then
         l_mrc_sob_type_code := 'P';
      else
         l_mrc_sob_type_code := 'R';
      end if;

      l_asset_hdr_rec.set_of_books_id := c_rec.sob_id;

      for row_ctr in 1..p_asset_dist_tbl.count loop --C3

         row_ctr_temp := row_ctr; --bug# 5523484
         dist_total_deprn := 0;
         l_asset_dist_rec := p_asset_dist_tbl(row_ctr);

         if (l_asset_dist_rec.distribution_id is not null) then

            -- terminated distribution, back out

            if not fadgdd (p_trans_rec,
                           l_asset_hdr_rec,
                           p_asset_desc_rec,
                           p_asset_cat_rec,
                           l_asset_dist_rec,
                           l_period_rec,
                           ppd_ctr,
                           backout_drs,
                           TRUE,
                           l_mrc_sob_type_code,
                            p_log_level_rec) then
               raise error_found;
            end if;


            total_backout_drs.deprn_exp       := total_backout_drs.deprn_exp +
                                                 backout_drs.deprn_exp;
            total_backout_drs.reval_deprn_exp := total_backout_drs.reval_deprn_exp +
                                                 backout_drs.reval_deprn_exp;
            total_backout_drs.reval_amo       := total_backout_drs.reval_amo +
                                                 backout_drs.reval_amo;
            total_backout_drs.deprn_rsv       := total_backout_drs.deprn_rsv +
                                                 backout_drs.deprn_rsv;
            total_backout_drs.reval_rsv       := total_backout_drs.reval_rsv +
                                                 backout_drs.reval_rsv;
            total_backout_drs.bonus_deprn_amount := total_backout_drs.bonus_deprn_amount +
                                                 backout_drs.bonus_deprn_amount;

            total_backout_drs.bonus_deprn_rsv := total_backout_drs.bonus_deprn_rsv +
                                                 backout_drs.bonus_deprn_rsv;

            b := faxzdrs (backout_drs, p_log_level_rec);

         else

            -- newly created distribution

            -- retrieve the dist id
            open c_dist_id (p_asset_hdr_rec.asset_id,
                            l_asset_dist_rec.expense_ccid,
                            l_asset_dist_rec.location_ccid,
                            l_asset_dist_rec.assigned_to);

            fetch c_dist_id into l_asset_dist_rec.distribution_id;
            close c_dist_id;

            insert_drs.deprn_exp := total_backout_drs.deprn_exp *
                                    (l_asset_dist_rec.transaction_units /
                                     total_ua_backout);

            b := fa_utils_pkg.faxrnd(insert_drs.deprn_exp, p_asset_hdr_rec.book_type_code, l_asset_hdr_rec.set_of_books_id,p_log_level_rec => p_log_level_rec);

            taken_drs.deprn_exp := taken_drs.deprn_exp + insert_drs.deprn_exp;

            insert_drs.reval_deprn_exp := total_backout_drs.reval_deprn_exp *
                                          (l_asset_dist_rec.transaction_units /
                                           total_ua_backout);

            b:=fa_utils_pkg.faxrnd(insert_drs.reval_deprn_exp, p_asset_hdr_rec.book_type_code, l_asset_hdr_rec.set_of_books_id, p_log_level_rec => p_log_level_rec);

            taken_drs.reval_deprn_exp := taken_drs.reval_deprn_exp +
                                         insert_drs.reval_deprn_exp;
            taken_drs.reval_deprn_exp := taken_drs.reval_deprn_exp +
                                         insert_drs.reval_deprn_exp;

            insert_drs.reval_amo := total_backout_drs.reval_amo *
                                    (l_asset_dist_rec.transaction_units /
                                     total_ua_backout);

            b := fa_utils_pkg.faxrnd(insert_drs.reval_amo, p_asset_hdr_rec.book_type_code,l_asset_hdr_rec.set_of_books_id, p_log_level_rec => p_log_level_rec);

            taken_drs.reval_amo := taken_drs.reval_amo + insert_drs.reval_amo;

            -- RKP: also do this for rsv, reval rsv

            insert_drs.deprn_rsv := total_backout_drs.deprn_rsv *
                                    (l_asset_dist_rec.transaction_units /
                                     total_ua_backout);


            b := fa_utils_pkg.faxrnd(insert_drs.deprn_rsv, p_asset_hdr_rec.book_type_code, l_asset_hdr_rec.set_of_books_id, p_log_level_rec => p_log_level_rec);

            taken_drs.deprn_rsv := taken_drs.deprn_rsv + insert_drs.deprn_rsv;

            insert_drs.reval_rsv := total_backout_drs.reval_rsv *
                                    (l_asset_dist_rec.transaction_units /
                                     total_ua_backout);

            b := fa_utils_pkg.faxrnd(insert_drs.reval_rsv, p_asset_hdr_rec.book_type_code, l_asset_hdr_rec.set_of_books_id, p_log_level_rec => p_log_level_rec);

            taken_drs.reval_rsv := taken_drs.reval_rsv + insert_drs.reval_rsv;

            insert_drs.bonus_deprn_amount := total_backout_drs.bonus_deprn_amount *
                                          (l_asset_dist_rec.transaction_units /
                                           total_ua_backout);

            b := fa_utils_pkg.faxrnd (insert_drs.bonus_deprn_amount, p_asset_hdr_rec.book_type_code,l_asset_hdr_rec.set_of_books_id, p_log_level_rec => p_log_level_rec);


            taken_drs.bonus_deprn_amount := taken_drs.bonus_deprn_amount +
                                         insert_drs.bonus_deprn_amount;

            insert_drs.bonus_deprn_rsv := total_backout_drs.bonus_deprn_rsv *
                                          (l_asset_dist_rec.transaction_units /
                                          total_ua_backout);

            b := fa_utils_pkg.faxrnd (insert_drs.bonus_deprn_rsv, p_asset_hdr_rec.book_type_code, l_asset_hdr_rec.set_of_books_id, p_log_level_rec => p_log_level_rec);


            taken_drs.bonus_deprn_rsv := taken_drs.bonus_deprn_rsv +
                                         insert_drs.bonus_deprn_rsv;


            if not fadgdd (p_trans_rec,
                           l_asset_hdr_rec,
                           p_asset_desc_rec,
                           p_asset_cat_rec,
                           l_asset_dist_rec,
                           l_period_rec,
                           ppd_ctr,
                           insert_drs,
                           FALSE,
                           l_mrc_sob_type_code,
                           p_log_level_rec) then
               raise error_found;
            end if;
         end if;
      end loop; -- end of dist loop

      -- if row_ctr <> 0 then
      if row_ctr_temp <> 0 then

         -- Bug#6999340: Allocating unprocessed amount to the new distribution_id created.
         l_asset_dist_rec := p_asset_dist_tbl(row_ctr_temp);

         open c_dist_id (p_asset_hdr_rec.asset_id,
                            l_asset_dist_rec.expense_ccid,
                            l_asset_dist_rec.location_ccid,
                            l_asset_dist_rec.assigned_to);


         fetch c_dist_id into l_asset_dist_rec.distribution_id;

         if c_dist_id%found then  -- bug# 5523484


            insert_drs.deprn_exp       := total_backout_drs.deprn_exp - taken_drs.deprn_exp;
            insert_drs.reval_deprn_exp := total_backout_drs.reval_deprn_exp -
                                          taken_drs.reval_deprn_exp;
            insert_drs.reval_amo       := total_backout_drs.reval_amo-taken_drs.reval_amo;

            -- RKP: also do this for deprn rsv, reval rsv
            insert_drs.deprn_rsv := total_backout_drs.deprn_rsv-taken_drs.deprn_rsv;
            insert_drs.reval_rsv := total_backout_drs.reval_rsv-taken_drs.reval_rsv;

            insert_drs.bonus_deprn_amount := total_backout_drs.bonus_deprn_amount -
                                             taken_drs.bonus_deprn_amount;

            insert_drs.bonus_deprn_rsv := total_backout_drs.bonus_deprn_rsv -
                                          taken_drs.bonus_deprn_rsv;

            backout_share    := total_dep_backout - old_backout_taken;
            dist_total_deprn := backout_share;

            if not fadgdd (p_trans_rec,
                        l_asset_hdr_rec,
                        p_asset_desc_rec,
                        p_asset_cat_rec,
                        l_asset_dist_rec,
                        l_period_rec,
                        ppd_ctr,
                        insert_drs,
                        FALSE,
                        l_mrc_sob_type_code,
                        p_log_level_rec) then
               raise error_found;
            end if;
         end if; -- bug# 5523484
         close c_dist_id;

      else
         fa_srvr_msg.add_message
                             (calling_fn => l_calling_fn,
                              name       => 'FA_DEPRN_NO_DIST_HIST',
                              token1     => 'ROUTINE',
                              value1     => l_calling_fn,
                              token2     => 'ASSET_NUM',
                              value2     => p_asset_desc_rec.asset_number,
                              token3     => 'ASSET_ID',
                              value3     => p_asset_hdr_rec.asset_id,
                              token4     => 'BOOK_TYPE',
                              value4     => p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);

      end if;

   end loop;    -- end of mrc loop

   return (TRUE);

<<fadppt_no_ppt>>
    fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                            name       => 'FA_DEPRN_NO_PRIOR',
                            token1     => 'ASSET_NUM',
                            value1     => p_asset_desc_rec.asset_number, p_log_level_rec => p_log_level_rec);

    -- SLA: fadrars call is obsolete:

    return (TRUE);

Exception

   when error_found then
        fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return (FALSE);

   when others then

        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return (FALSE);

end FADPPT;



/*===========================================================================+
 |  NAME                                                                     |
 |      fadrars                                                              |
 |                                                                           |
 |  FUNCTION                                                                 |
 |      Resets fa_distribution_history.period_adjustment values to 0 for     |
 |  all records of a specified asset and book type.  Also resets the         |
 |  fa_books.adjustment_required_status to 'NONE' for the specified record.  |
 |                                                                           |
 |  NOTE                                                                     |
 |     obsolete for SLA for transfers                                        |
 +===========================================================================*/

/*===========================================================================+
 |  NAME                                                                     |
 |      fadppa                                                               |
 |                                                                           |
 |  FUNCTION                                                                 |
 |      Calculates depreciation for a Prior Period Addition.                 |
 |      Also, added faduxx to update FA_BOOKS with new adjusted rates, bonus |
 |      rule, bonus rates for NBV assets                                     |
 |                                                                           |
 |  NOTES                                                                    |
 |      obsolete for SLA                                                     |
 +===========================================================================*/

/*===========================================================================+
 |                                                                           |
 |      fadpaa                                                               |
 |                                                                           |
 |      FA Depreciation Process Adjustments Array                            |
 |                                                                           |
 |      Inserts a row into fa_deprn_detail for each row in the Adjustments   |
 |              array; then inserts one row into fa_deprn_summary for        |
 |              sum of values in array                                       |
 |                                                                           |
 |  NOTES                                                                    |
 |      obsolete for SLA                                                     |
 +===========================================================================*/

/*===========================================================================+
 |  NAME                                                                     |
 |      fadadp                                                               |
 |                                                                           |
 |  FUNCTION                                                                 |
 |      Calculates adjusted depreciation for a specified asset_id and        |
 |  book_type and stores the distributed depreciation amounts in the         |
 |  fa_deprn_detail table.                                                   |
 |      Returns the total amount of adjusted depreciation on the asset.      |
 |                                                                           |
 |  NOTES                                                                    |
 |      This routine was rewritten to handle prior period transfers.  Now    |
 |      it does very little except call routines to handle either transfers  |
 |      or additions.                                                        |
 |                                                                           |
 |      obsolete for SLA                                                     |
 +===========================================================================*/


/*===========================================================================+
 |  NAME                                                                     |
 |      fadatd                                                               |
 |                                                                           |
 |  FUNCTION                                                                 |
 |      1.  updates deprn_detail and deprn_summary records by adding the     |
 |              adjustments records to them where the deprn records exist.   |
 |      2.  inserts deprn_detail and deprn_summary records by copying        |
 |              the adjustments records where the deprn records don't exist. |
 |                                                                           |
 |  NOTES                                                                    |
 |      this remains in pro*c and is not part of SLA                         |
 +===========================================================================*/


END FA_TRANSFER_PVT;

/
