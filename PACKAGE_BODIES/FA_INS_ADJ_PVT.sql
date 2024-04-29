--------------------------------------------------------
--  DDL for Package Body FA_INS_ADJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_INS_ADJ_PVT" AS
/* $Header: FAVIATB.pls 120.8.12010000.2 2009/07/19 11:33:28 glchen ship $ */

Function faxiat
          (p_trans_rec       IN FA_API_TYPES.trans_rec_type,
           p_asset_hdr_rec   IN FA_API_TYPES.asset_hdr_rec_type,
           p_asset_desc_rec  IN FA_API_TYPES.asset_desc_rec_type,
           p_asset_cat_rec   IN FA_API_TYPES.asset_cat_rec_type,
           p_asset_type_rec  IN FA_API_TYPES.asset_type_rec_type,
           p_cost            IN number DEFAULT 0,
           p_clearing        IN number DEFAULT 0,
           p_deprn_expense   IN number DEFAULT 0,
           p_bonus_expense   IN number DEFAULT 0,
           p_impair_expense  IN number DEFAULT 0,
           p_deprn_reserve   IN number DEFAULT 0,
           p_bonus_reserve   IN number DEFAULT 0,
           p_ann_adj_amt     IN number DEFAULT 0,
           p_track_member_flag IN varchar2 DEFAULT NULL,
           p_mrc_sob_type_code IN VARCHAR2,
           p_calling_fn      IN VARCHAR2
          , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean is

   l_adj                    fa_adjust_type_pkg.fa_adj_row_struct;
   l_clear_adj              fa_adjust_type_pkg.fa_adj_row_struct;

   l_mesg_name              varchar2(30);
   l_action_buf             varchar2(30);
   l_calling_fn             varchar2(35) := 'FA_INS_ADJ_PVT.faxiat';

   l_cost_acct              Varchar2(240);
   l_clearing_acct          Varchar2(240);
   l_cost_acct_type         Varchar2(240);
   l_clearing_acct_type     Varchar2(240);
   l_source                 Varchar2(240);
   l_tracking_method        Varchar2(30);
   l_member_rollup_flag     Varchar2(1);

   i                        number := 0;
   inv                      number := 0;
   l_bool_dummy             boolean;
   error_found              exception;

begin

   if not fa_cache_pkg.fazcct(fa_cache_pkg.fazcbc_record.deprn_calendar, p_log_level_rec => p_log_level_rec) then
      raise error_found;
   end if;

   l_adj.transaction_header_id    := p_trans_rec.transaction_header_id;
   l_adj.asset_id                 := p_asset_hdr_rec.asset_id;
   l_adj.book_type_code           := p_asset_hdr_rec.book_type_code;
   l_adj.period_counter_created   := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
   l_adj.period_counter_adjusted  := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
   l_adj.current_units            := p_asset_desc_rec.current_units ;
   l_adj.selection_mode           := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
   l_adj.selection_thid           := 0;
   l_adj.selection_retid          := 0;
   l_adj.leveling_flag            := TRUE;
   l_adj.last_update_date         := p_trans_rec.who_info.last_update_date;

   l_adj.flush_adj_flag           := FALSE;
   l_adj.gen_ccid_flag            := TRUE;
   l_adj.annualized_adjustment    := 0;
   l_adj.asset_invoice_id         := 0;
   l_adj.code_combination_id      := 0;
   l_adj.distribution_id          := 0;

   l_adj.deprn_override_flag:= '';

   if not fa_cache_pkg.fazccb
            (p_asset_hdr_rec.book_type_code,
             p_asset_cat_rec.category_id , p_log_level_rec => p_log_level_rec) then
      raise error_found;
   end if;


   l_source                := p_trans_rec.transaction_type_code;

   --BUG FIX 5410699
   if(substr(l_source,1,5) = 'GROUP')then
      l_source := substr(l_source,7,length(l_source));
   end if;


   if p_asset_type_rec.asset_type = 'CIP' then
      l_cost_acct_type     := 'CIP_COST_ACCT';
      l_clearing_acct_type := 'CIP_CLEARING_ACCT';
      l_cost_acct          := fa_cache_pkg.fazccb_record.CIP_COST_ACCT;
      l_clearing_acct      := fa_cache_pkg.fazccb_record.CIP_CLEARING_ACCT;
   else
      l_cost_acct_type     := 'ASSET_COST_ACCT';
      l_clearing_acct_type := 'ASSET_CLEARING_ACCT';
      l_cost_acct          := fa_cache_pkg.fazccb_record.ASSET_COST_ACCT;
      l_clearing_acct      := fa_cache_pkg.fazccb_record.ASSET_CLEARING_ACCT;
   end if;

   -- first, process the COST row

   if (p_cost <> 0 and p_asset_type_rec.asset_type <> 'GROUP') then

      l_adj.source_type_code    := l_source;
      l_adj.adjustment_type     := 'COST';
      l_adj.account             := l_cost_acct;
      l_adj.account_type        := l_cost_acct_type;

      if p_cost > 0 then
         l_adj.debit_credit_flag   := 'DR';
         l_adj.adjustment_amount   := p_cost;
      else
         l_adj.debit_credit_flag   := 'CR';
         l_adj.adjustment_amount   := -p_cost;
      end if;

      l_adj.mrc_sob_type_code := p_mrc_sob_type_code;
      l_adj.set_of_books_id   := p_asset_hdr_rec.set_of_books_id;

      if not FA_INS_ADJUST_PKG.faxinaj
                (l_adj,
                 p_trans_rec.who_info.last_update_date,
                 p_trans_rec.who_info.last_updated_by,
                 p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
         raise error_found;
      end if;

   end if;


   -- clear the difference between the cleared payables and total cost
   -- to the account built using category accounts

   if (p_clearing <> 0 and p_asset_type_rec.asset_type <> 'GROUP') then

      l_adj.source_type_code  := l_source;
      l_adj.adjustment_type   := 'COST CLEARING';
      l_adj.account           := l_clearing_acct;
      l_adj.account_type      := l_clearing_acct_type;

      if p_clearing > 0 then
         l_adj.debit_credit_flag   := 'CR';
         l_adj.adjustment_amount   := p_clearing;
      else
         l_adj.debit_credit_flag   := 'DR';
         l_adj.adjustment_amount   := -p_clearing;
      end if;

      l_adj.mrc_sob_type_code := p_mrc_sob_type_code;
      l_adj.set_of_books_id   := p_asset_hdr_rec.set_of_books_id;

      if not FA_INS_ADJUST_PKG.faxinaj
                (l_adj,
                 p_trans_rec.who_info.last_update_date,
                 p_trans_rec.who_info.last_updated_by,
                 p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
         raise error_found;
      end if;
   end if;

   l_adj.annualized_adjustment    := nvl(p_ann_adj_amt, 0);

   -- insert the depreciation expense
   if p_deprn_expense <> 0 then

      l_adj.source_type_code    := 'DEPRECIATION';
      l_adj.adjustment_type     := 'EXPENSE';
      l_adj.debit_credit_flag   := 'DR';
      l_adj.account_type        := 'DEPRN_EXPENSE_ACCT';
      l_adj.account             := FA_CACHE_PKG.fazccb_record.deprn_expense_acct;
      l_adj.adjustment_amount   := p_deprn_expense;

      --  manual override
      FA_DEBUG_PKG.ADD
               (fname   => 'FA_AMORT_PKG.faxiat',
                element => 'faxiat: deprn_override_flag',
                value   => p_trans_rec.deprn_override_flag, p_log_level_rec => p_log_level_rec);

      if p_trans_rec.deprn_override_flag in (fa_std_types.FA_OVERRIDE_DPR,
                                             fa_std_types.FA_OVERRIDE_BONUS,
                                             fa_std_types.FA_OVERRIDE_DPR_BONUS) then
         l_adj.deprn_override_flag:= 'Y';
      else
         l_adj.deprn_override_flag:= '';
      end if;
      -- End of Manual Override

      if nvl(p_track_member_flag, 'N') = 'Y' then
         l_adj.track_member_flag := 'Y';
      else
         l_adj.track_member_flag := null;
      end if;

      l_adj.mrc_sob_type_code := p_mrc_sob_type_code;
      l_adj.set_of_books_id   := p_asset_hdr_rec.set_of_books_id;

      if not FA_INS_ADJUST_PKG.faxinaj
                (l_adj,
                 p_trans_rec.who_info.last_update_date,
                 p_trans_rec.who_info.last_updated_by,
                 p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
         raise error_found;
      end if;

      /* Bug 6666666 : Added for SORP Compliance (via Bug 7590545) */
      /* Creating SORP Neutralizing entries */
      if FA_CACHE_PKG.fazcbc_record.sorp_enabled_flag = 'Y' then
          if not FA_SORP_UTIL_PVT.create_sorp_neutral_acct (
                p_amount                => p_deprn_expense,
                p_reversal              => 'N',
                p_adj                   => l_adj,
                p_created_by            => NULL,
                p_creation_date         => NULL,
                p_last_update_date      => p_trans_rec.who_info.last_update_date,
                p_last_updated_by       => p_trans_rec.who_info.last_updated_by,
                p_last_update_login     => p_trans_rec.who_info.last_update_login,
                p_who_mode              => 'UPDATE'
                , p_log_level_rec => p_log_level_rec) then
                    raise error_found;
          end if;
      end if;
      /*End of Bug 6666666 */
   end if;


   -- insert the bonus expense
   if p_bonus_expense <> 0 then

      l_adj.source_type_code    := 'DEPRECIATION';
      l_adj.adjustment_type     := 'BONUS EXPENSE';
      l_adj.debit_credit_flag   := 'DR';
      l_adj.account_type        := 'BONUS_DEPRN_EXPENSE_ACCT';
      l_adj.account             := FA_CACHE_PKG.fazccb_record.bonus_deprn_expense_acct;
      l_adj.adjustment_amount   := p_bonus_expense;

      -- Manual Override
      if p_trans_rec.deprn_override_flag in (fa_std_types.FA_OVERRIDE_BONUS,
                                             fa_std_types.FA_OVERRIDE_DPR_BONUS) then
         l_adj.deprn_override_flag:= 'Y';
      else
         l_adj.deprn_override_flag:= '';
      end if;
      -- End of Manual Override

      l_adj.mrc_sob_type_code := p_mrc_sob_type_code;
      l_adj.set_of_books_id   := p_asset_hdr_rec.set_of_books_id;

      if not FA_INS_ADJUST_PKG.faxinaj
                (l_adj,
                 p_trans_rec.who_info.last_update_date,
                 p_trans_rec.who_info.last_updated_by,
                 p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
         raise error_found;
      end if;
   end if;

   if p_impair_expense <> 0 then

      l_adj.source_type_code    := 'DEPRECIATION';
      l_adj.adjustment_type     := 'IMPAIR EXPENSE';
      l_adj.debit_credit_flag   := 'DR';
      l_adj.account_type        := 'IMPAIR_EXPENSE_ACCT';
      l_adj.account             := FA_CACHE_PKG.fazccb_record.impair_expense_acct;
      l_adj.adjustment_amount   := p_impair_expense;

      -- Manual Override
      if p_trans_rec.deprn_override_flag in (fa_std_types.FA_OVERRIDE_IMPAIR,
                                             fa_std_types.FA_OVERRIDE_DPR_IMPAIR) then

         l_adj.deprn_override_flag:= 'Y';
      else
         l_adj.deprn_override_flag:= '';
      end if;
      -- End of Manual Override

      l_adj.mrc_sob_type_code := p_mrc_sob_type_code;
      l_adj.set_of_books_id   := p_asset_hdr_rec.set_of_books_id;

      if not FA_INS_ADJUST_PKG.faxinaj
                (l_adj,
                 p_trans_rec.who_info.last_update_date,
                 p_trans_rec.who_info.last_updated_by,
                 p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
         raise error_found;
      end if;
   end if;

   -- insert the reserve
   if p_deprn_reserve <> 0 then

      l_adj.source_type_code    := l_source;
      l_adj.adjustment_type     := 'RESERVE';
      l_adj.account_type        := 'DEPRN_RESERVE_ACCT';
      l_adj.account             := FA_CACHE_PKG.fazccb_record.deprn_reserve_acct;

      if p_deprn_reserve > 0 then
         l_adj.debit_credit_flag   := 'CR';
         l_adj.adjustment_amount   := p_deprn_reserve;
      else
         l_adj.debit_credit_flag   := 'DR';
         l_adj.adjustment_amount   := -p_deprn_reserve;
      end if;

      l_adj.mrc_sob_type_code := p_mrc_sob_type_code;
      l_adj.set_of_books_id   := p_asset_hdr_rec.set_of_books_id;

      if not FA_INS_ADJUST_PKG.faxinaj
                (l_adj,
                 p_trans_rec.who_info.last_update_date,
                 p_trans_rec.who_info.last_updated_by,
                 p_trans_rec.who_info.last_update_login
                 ,p_log_level_rec => p_log_level_rec) then
         raise error_found;
      end if;
   end if;

   -- insert the bonus reserve
   if p_bonus_reserve <> 0 then

      l_adj.source_type_code    := l_source;
      l_adj.adjustment_type     := 'BONUS RESERVE';
      l_adj.account_type        := 'BONUS_DEPRN_RESERVE_ACCT';
      l_adj.account             := FA_CACHE_PKG.fazccb_record.bonus_deprn_reserve_acct;

      if p_bonus_reserve > 0 then
         l_adj.debit_credit_flag   := 'CR';
         l_adj.adjustment_amount   := p_bonus_reserve;
      else
         l_adj.debit_credit_flag   := 'DR';
         l_adj.adjustment_amount   := -p_bonus_reserve;
      end if;

      l_adj.mrc_sob_type_code := p_mrc_sob_type_code;
      l_adj.set_of_books_id   := p_asset_hdr_rec.set_of_books_id;

      if not FA_INS_ADJUST_PKG.faxinaj
                (l_adj,
                 p_trans_rec.who_info.last_update_date,
                 p_trans_rec.who_info.last_updated_by,
                 p_trans_rec.who_info.last_update_login
                 ,p_log_level_rec => p_log_level_rec) then
         raise error_found;
      end if;
   end if;

   -- flush fa_adjustments
   l_adj.transaction_header_id := 0;
   l_adj.flush_adj_flag        := TRUE;
   l_adj.leveling_flag         := TRUE;

   if not FA_INS_ADJUST_PKG.faxinaj
             (l_adj,
              p_trans_rec.who_info.last_update_date,
              p_trans_rec.who_info.last_updated_by,
              p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
          raise error_found;
   end if;

   return true;

EXCEPTION
   WHEN error_found THEN
        fa_srvr_msg.add_message(
              calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return (FALSE);

   WHEN others THEN
        fa_srvr_msg.add_sql_error
           (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return (FALSE);

end faxiat;

End FA_INS_ADJ_PVT;

/
