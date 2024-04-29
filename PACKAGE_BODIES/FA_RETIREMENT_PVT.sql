--------------------------------------------------------
--  DDL for Package Body FA_RETIREMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RETIREMENT_PVT" as
/* $Header: FAVRETB.pls 120.55.12010000.31 2010/05/25 02:40:58 anujain ship $   */

-- +++++ Global Variables +++++
--Adding for 3440308
g_current_units number:=0;
g_grp_trx_hdr_id number; -- Bug 8674833
G_PART_RET_FLAG BOOLEAN;

-- +++++ Forward Declarations +++++
FUNCTION CALC_GAIN_LOSS_FOR_RET(
               p_trans_rec         IN     FA_API_TYPES.trans_rec_type,
               p_asset_hdr_rec     IN     FA_API_TYPES.asset_hdr_rec_type,
               p_asset_type_rec    IN     FA_API_TYPES.asset_type_rec_type,
               p_asset_desc_rec    IN     FA_API_TYPES.asset_desc_rec_type,
               p_asset_cat_rec     IN     FA_API_TYPES.asset_cat_rec_type,
               p_asset_fin_rec     IN     FA_API_TYPES.asset_fin_rec_type,
               p_period_rec        IN     FA_API_TYPES.period_rec_type,
               p_asset_retire_rec  IN     FA_API_TYPES.asset_retire_rec_type,
               p_group_thid        IN     NUMBER,
               p_salvage_value_retired IN NUMBER,
               p_mrc_sob_type_code IN     VARCHAR2,
               p_mode              IN     VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN;

FUNCTION CALC_GAIN_LOSS_FOR_REI(
           p_trans_rec         IN            FA_API_TYPES.trans_rec_type,
           p_asset_hdr_rec     IN            FA_API_TYPES.asset_hdr_rec_type,
           p_asset_type_rec    IN            FA_API_TYPES.asset_type_rec_type,
           p_asset_desc_rec    IN            FA_API_TYPES.asset_desc_rec_type,
           p_asset_cat_rec     IN            FA_API_TYPES.asset_cat_rec_type,
           p_asset_fin_rec     IN            FA_API_TYPES.asset_fin_rec_type,
           p_period_rec        IN            FA_API_TYPES.period_rec_type,
           p_asset_retire_rec  IN            FA_API_TYPES.asset_retire_rec_type,
           p_group_thid        IN            NUMBER,
           x_asset_fin_rec        OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
           p_mrc_sob_type_code IN            VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN;
-- +++++ End of Forward Declarations +++++

FUNCTION DO_RETIREMENT(p_trans_rec             IN     FA_API_TYPES.trans_rec_type,
                       p_asset_retire_rec      IN     FA_API_TYPES.asset_retire_rec_type,
                       p_asset_hdr_rec         IN     FA_API_TYPES.asset_hdr_rec_type,
                       p_asset_type_rec        IN     FA_API_TYPES.asset_type_rec_type,
                       p_asset_cat_rec         IN     FA_API_TYPES.asset_cat_rec_type,
                       p_asset_fin_rec         IN     FA_API_TYPES.asset_fin_rec_type,
                       p_asset_desc_rec        IN     FA_API_TYPES.asset_desc_rec_type,
                       p_period_rec            IN     FA_API_TYPES.period_rec_type,
                       p_mrc_sob_type_code     IN     VARCHAR2,
                       p_calling_fn            IN     VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean IS

  l_trans_rec             FA_API_TYPES.trans_rec_type;
  l_asset_hdr_rec         FA_API_TYPES.asset_hdr_rec_type;

  CURSOR c_get_group_exp_row IS
    select adjustment_type,
           debit_credit_flag,
           adjustment_amount,
           period_counter_adjusted,
           period_counter_created
    from   fa_adjustments
    where  asset_id = l_asset_hdr_rec.asset_id
    and    book_type_code = l_asset_hdr_rec.book_type_code
    and    transaction_header_id = l_trans_rec.transaction_header_id
    and    source_type_code = 'DEPRECIATION';

  CURSOR c_member_exists IS
    select 'Y'
    from   fa_books
    where  book_type_code = p_asset_hdr_rec.book_type_code
    and    group_asset_id = p_asset_fin_rec.group_asset_id
    and    period_counter_fully_retired is null
    and    transaction_header_id_out is null;

  CURSOR c_get_thid is
    select fa_transaction_headers_s.nextval
    from   dual;

  CURSOR c_get_primary_thid is
    select transaction_header_id
    from   fa_transaction_headers
    where  asset_id = p_asset_fin_rec.group_asset_id
    and    book_type_code = p_asset_hdr_rec.book_type_code
    and    member_transaction_header_id = p_trans_rec.transaction_header_id;

  l_calling_fn            VARCHAR2(100) := 'fa_retirement_pvt.do_retirement';

  l_transaction_header_id FA_TRANSACTION_HEADERS.TRANSACTION_HEADER_ID%TYPE;

  l_asset_desc_rec_m      FA_API_TYPES.asset_desc_rec_type;
  l_asset_desc_rec        FA_API_TYPES.asset_desc_rec_type;
  l_asset_type_rec        FA_API_TYPES.asset_type_rec_type;
  l_asset_cat_rec         FA_API_TYPES.asset_cat_rec_type;
  l_asset_fin_rec_new_m   FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_rec_old     FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_rec_adj     FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_rec_new     FA_API_TYPES.asset_fin_rec_type;
  l_inv_trans_rec         FA_API_TYPES.inv_trans_rec_type;
  l_asset_deprn_rec_old   FA_API_TYPES.asset_deprn_rec_type;
  l_asset_deprn_rec_adj   FA_API_TYPES.asset_deprn_rec_type;
  l_asset_deprn_rec_new   FA_API_TYPES.asset_deprn_rec_type;

  l_group_reclass_options_rec FA_API_TYPES.group_reclass_options_rec_type;

  l_deprn_exp             NUMBER;
  l_bonus_deprn_exp       NUMBER;
  l_impairment_exp        NUMBER;

  l_adj                   FA_ADJUST_TYPE_PKG.FA_ADJ_ROW_STRUCT;

  l_member_exists         VARCHAR2(1) := 'N';
  l_deprn_reserve         NUMBER;
  l_temp_num              NUMBER;
  l_temp_char             VARCHAR2(30);
  l_temp_bool             BOOLEAN;

  l_new_reserve           NUMBER;
  l_new_rec_cost          NUMBER;
  l_recapture_amount      NUMBER;

  l_alloc_amount          NUMBER; -- Used to pass amount to allocate across
                                  -- member assets

  l_rowid                 ROWID; -- temp variable
  l_cglfr_mode            VARCHAR2(2); --For CALC_GAIN_LOSS_FOR_RET
  l_cost_sign             NUMBER; --Bug 8535921
  ret_err                 EXCEPTION;

BEGIN
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Begin',
                       p_asset_hdr_rec.asset_id||':'||p_asset_fin_rec.group_asset_id, p_log_level_rec => p_log_level_rec);
   end if;

   --Adding to bypass the issue in 3440308 (case where an equal # of units is
   --retired as is left in the asset.
   --This is required because we're resetting asset_desc_rec below
   g_current_units := nvl(p_asset_desc_rec.current_units,0);

   -- Get asset description for member asset
   -- p_asset_desc may be null
   if not FA_UTIL_PVT.get_asset_desc_rec (
                p_asset_hdr_rec         => p_asset_hdr_rec,
                px_asset_desc_rec       => l_asset_desc_rec_m, p_log_level_rec => p_log_level_rec) then
      raise ret_err;
   end if;

   if (p_mrc_sob_type_code <> 'R') then
      OPEN c_get_thid;
      FETCH c_get_thid INTO l_trans_rec.transaction_header_id;
      CLOSE c_get_thid;
   else
      OPEN c_get_primary_thid;
      FETCH c_get_primary_thid INTO l_trans_rec.transaction_header_id;
      CLOSE c_get_primary_thid;
   end if;

   --
   -- Prepare to call FA_ADJUSTMENT_PVT.do_adjustment to process group
   -- asset after member asset retirement.
   --

   l_trans_rec.transaction_type_code := 'GROUP ADJUSTMENT';
   l_trans_rec.transaction_subtype := 'AMORTIZED';
   l_trans_rec.transaction_date_entered := p_trans_rec.transaction_date_entered;
   l_trans_rec.amortization_start_date  := p_trans_rec.transaction_date_entered;
   l_trans_rec.transaction_key := 'MR';
   l_trans_rec.who_info.creation_date := p_trans_rec.who_info.creation_date;
   l_trans_rec.who_info.created_by := p_trans_rec.who_info.created_by;
   l_trans_rec.who_info.last_update_date := p_trans_rec.who_info.last_update_date;
   l_trans_rec.who_info.last_updated_by := p_trans_rec.who_info.last_updated_by;
   l_trans_rec.who_info.last_update_login := p_trans_rec.who_info.last_update_login;
   l_trans_rec.member_transaction_header_id := p_trans_rec.transaction_header_id;
   l_trans_rec.mass_transaction_id := p_trans_rec.mass_transaction_id;
   l_trans_rec.calling_interface := p_trans_rec.calling_interface;
   l_trans_rec.mass_reference_id := p_trans_rec.mass_reference_id;
   l_trans_rec.event_id := p_trans_rec.event_id;

   l_asset_hdr_rec.asset_id := p_asset_fin_rec.group_asset_id;
   l_asset_hdr_rec.book_type_code := p_asset_hdr_rec.book_type_code;
   l_asset_hdr_rec.set_of_books_id := p_asset_hdr_rec.set_of_books_id;
   --l_asset_hdr_rec.period_of_addition := 'N'; -- Guess not necessary

   if not FA_UTIL_PVT.get_asset_type_rec (
                   p_asset_hdr_rec      => l_asset_hdr_rec,
                   px_asset_type_rec    => l_asset_type_rec, p_log_level_rec => p_log_level_rec) then
      raise ret_err;
   end if;

   if not FA_UTIL_PVT.get_asset_desc_rec (
                   p_asset_hdr_rec         => l_asset_hdr_rec,
                   px_asset_desc_rec       => l_asset_desc_rec, p_log_level_rec => p_log_level_rec) then
      raise ret_err;
   end if;

   if not FA_UTIL_PVT.get_asset_cat_rec (
                   p_asset_hdr_rec         => l_asset_hdr_rec,
                   px_asset_cat_rec        => l_asset_cat_rec,
                   p_date_effective        => null, p_log_level_rec => p_log_level_rec) then
      raise ret_err;
   end if;

   if not fa_util_pvt.get_asset_fin_rec (
                   p_asset_hdr_rec         => l_asset_hdr_rec,
                   px_asset_fin_rec        => l_asset_fin_rec_old,
                   p_mrc_sob_type_code     => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
      raise ret_err;
   end if;

   /* Added for bug 8535921 */
   if l_asset_fin_rec_old.cost < 0 then
      l_cost_sign := -1;
   else
      l_cost_sign := 1;
   end if;
   /* End of bug 8535921 */

--tk_util.DumpFinRec(l_asset_fin_rec_old, 'OLD');

   if not fa_util_pvt.get_asset_deprn_rec (
                   p_asset_hdr_rec         => l_asset_hdr_rec,
                   px_asset_deprn_rec      => l_asset_deprn_rec_old,
                   p_mrc_sob_type_code     => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
      raise ret_err;
   end if;

   if (p_asset_type_rec.asset_type = 'CIP') then
      l_asset_fin_rec_adj.cip_cost := -1 * p_asset_retire_rec.cost_retired;
   else
      l_asset_fin_rec_adj.cost := -1 * p_asset_retire_rec.cost_retired;
   end if;

   l_asset_fin_rec_adj.unrevalued_cost := -1 * p_asset_retire_rec.cost_retired;
   l_asset_fin_rec_adj.ytd_proceeds := p_asset_retire_rec.proceeds_of_sale;
   l_asset_fin_rec_adj.ltd_proceeds := p_asset_retire_rec.proceeds_of_sale;
   l_asset_fin_rec_adj.ltd_cost_of_removal := p_asset_retire_rec.cost_of_removal;

   l_asset_deprn_rec_adj.deprn_reserve := -1 * p_asset_retire_rec.reserve_retired;

   -- Get new member's fin_rec
   if not fa_util_pvt.get_asset_fin_rec (
                   p_asset_hdr_rec         => p_asset_hdr_rec,
                   px_asset_fin_rec        => l_asset_fin_rec_new_m,
                   p_mrc_sob_type_code     => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
      raise ret_err;
   end if;

   l_asset_fin_rec_adj.salvage_value := nvl(l_asset_fin_rec_new_m.salvage_value, 0) -
                                        nvl(p_asset_fin_rec.salvage_value, 0);

   l_asset_fin_rec_adj.allowed_deprn_limit_amount :=
                                        nvl(l_asset_fin_rec_new_m.allowed_deprn_limit_amount, 0) -
                                        nvl(p_asset_fin_rec.allowed_deprn_limit_amount, 0);
   --Need this for CALC_GAIN_LOSS_FOR_RET.
   if p_calling_fn <> 'DO_RETIREMENT.CGLFR_CR_ONLY' then
      l_cglfr_mode := 'DR';
   else
      l_cglfr_mode := 'CR';
   end if;
   --
   -- Insert COST, RESERVE, PROCEEDS CLR, and REMOVALCOST CLR
   -- into FA_ADJUSTMENTS.
   --

   /* Added for bug 7537762 */
   if not fa_util_pvt.get_asset_deprn_rec (
                   p_asset_hdr_rec         => l_asset_hdr_rec,
                   px_asset_deprn_rec      => l_asset_deprn_rec_old,
                   p_mrc_sob_type_code     => p_mrc_sob_type_code,
                   p_log_level_rec         => p_log_level_rec) then
      raise ret_err;
   end if;

--tk_util.debug('Before calling CALC_GAIN_LOSS_FOR_RET');
   if not CALC_GAIN_LOSS_FOR_RET(
                              p_trans_rec             => p_trans_rec,
                              p_asset_hdr_rec         => p_asset_hdr_rec,
                              p_asset_type_rec        => p_asset_type_rec,
                              p_asset_desc_rec        => l_asset_desc_rec_m,
                              p_asset_cat_rec         => p_asset_cat_rec,
                              p_asset_fin_rec         => p_asset_fin_rec,
                              p_period_rec            => p_period_rec,
                              p_asset_retire_rec      => p_asset_retire_rec,
                              p_group_thid            => l_trans_rec.transaction_header_id,
                              p_salvage_value_retired => l_asset_fin_rec_adj.salvage_value,
                              p_mrc_sob_type_code     => p_mrc_sob_type_code,
                              p_mode                  => l_cglfr_mode,
                              p_log_level_rec       => p_log_level_rec) then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'ERROR',
                             'returned from CALC_GAIN_LOSS_FOR_RET', p_log_level_rec => p_log_level_rec);
         end if;

         raise ret_err;
   end if;
--tk_util.debug('After calling CALC_GAIN_LOSS_FOR_RET');

   -- Do the rest only if not called for credit row (fix for 3188851)
   if p_calling_fn <> 'DO_RETIREMENT.CGLFR_CR_ONLY' then
   --
   -- Process Recapture Excess Reserve
   --
   if (nvl(p_asset_fin_rec.recapture_reserve_flag, 'N') = 'Y') then

      if (nvl(p_asset_fin_rec.limit_proceeds_flag, 'N')  = 'Y') and
         (nvl(p_asset_retire_rec.proceeds_of_sale, 0) -
          nvl(p_asset_retire_rec.cost_of_removal, 0)) >
                              (p_asset_retire_rec.cost_retired -
                               l_asset_fin_rec_adj.salvage_value) then

         l_new_reserve := l_asset_deprn_rec_old.deprn_reserve +
                          (p_asset_retire_rec.cost_retired -
                           l_asset_fin_rec_adj.salvage_value) -
                          p_asset_retire_rec.cost_retired;
      else

         l_new_reserve := l_asset_deprn_rec_old.deprn_reserve +
                          nvl(p_asset_retire_rec.proceeds_of_sale, 0) -
                          p_asset_retire_rec.cost_retired -
                          nvl(p_asset_retire_rec.cost_of_removal, 0);

      end if;

      l_new_rec_cost := l_asset_fin_rec_old.recoverable_cost -
                        (p_asset_retire_rec.cost_retired -
                         l_asset_fin_rec_adj.salvage_value);

      if (l_cost_sign*l_new_rec_cost < l_cost_sign*l_new_reserve) then --Bug8535921
         l_adj.adjustment_amount := l_new_reserve - l_new_rec_cost;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Recapture Excess Reserve',
                             l_adj.adjustment_amount, p_log_level_rec => p_log_level_rec);
         end if;

         if p_asset_type_rec.asset_type = 'CIP' then
            l_adj.source_type_code := 'CIP RETIREMENT';
         else
            l_adj.source_type_code := 'RETIREMENT';
         end if;

         l_adj.asset_id                := l_asset_hdr_rec.asset_id;
         l_adj.transaction_header_id   := l_trans_rec.transaction_header_id;
         l_adj.book_type_code          := l_asset_hdr_rec.book_type_code;
         l_adj.period_counter_created  := p_period_rec.period_counter;
         l_adj.period_counter_adjusted := p_period_rec.period_counter;
         l_adj.current_units           := l_asset_desc_rec.current_units;
         l_adj.selection_retid         := 0;
         l_adj.selection_mode          := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
         l_adj.leveling_flag           := TRUE;
         l_adj.flush_adj_flag          := FALSE;
         l_adj.last_update_date        := p_trans_rec.who_info.last_update_date;
         l_adj.gen_ccid_flag           := TRUE;
         l_adj.adjustment_type         := 'RESERVE';
         l_adj.account_type            := 'DEPRN_RESERVE_ACCT';
         l_adj.debit_credit_flag       := 'DR';
         l_adj.set_of_books_id         := l_asset_hdr_rec.set_of_books_id;
         l_adj.mrc_sob_type_code       := p_mrc_sob_type_code;

         if not fa_cache_pkg.fazccb(l_asset_hdr_rec.book_type_code,
                                    l_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
            fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            raise ret_err;
         end if;

         l_adj.account           := fa_cache_pkg.fazccb_record.DEPRN_RESERVE_ACCT;

         if not FA_INS_ADJUST_PKG.faxinaj
                            (l_adj,
                             p_trans_rec.who_info.last_update_date,
                             p_trans_rec.who_info.last_updated_by,
                             p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
            raise ret_err;
         end if;

         l_adj.adjustment_type         := 'NBV RETIRED';
         l_adj.adjustment_amount       := l_new_reserve - l_new_rec_cost;
         l_adj.flush_adj_flag          := TRUE;

         l_adj.debit_credit_flag       := 'CR';
         l_adj.account_type            := 'NBV_RETIRED_GAIN_ACCT';
         l_adj.account                 := fa_cache_pkg.fazcbc_record.nbv_retired_gain_acct;

         if not FA_INS_ADJUST_PKG.faxinaj
                            (l_adj,
                             p_trans_rec.who_info.last_update_date,
                             p_trans_rec.who_info.last_updated_by,
                             p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
            raise ret_err;
         end if;

         l_recapture_amount := l_new_reserve - l_new_rec_cost;
      else
         l_recapture_amount := 0;

      end if; -- (l_new_rec_cost < l_new_reserve)

   else

      l_recapture_amount := 0;

   end if; -- (nvl(p_asset_fin_rec.recapture_reserve_flag, 'N') = 'Y') and

-- ENERGY
   if (not fa_cache_pkg.fazccmt(l_asset_fin_rec_old.deprn_method_code,
                                l_asset_fin_rec_old.life_in_months, p_log_level_rec => p_log_level_rec)) then
      if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Error calling', 'fa_cache_pkg.fazccmt', p_log_level_rec => p_log_level_rec);
      end if;

      raise ret_err;
   end if;

   if (nvl(l_asset_fin_rec_old.tracking_method, 'NO TRACK') = 'ALLOCATE') then

--and            -- ENERGY
--      (fa_cache_pkg.fazcdrd_record.rule_name = 'ENERGY PERIOD END BALANCE') then         -- ENERGY
      l_asset_deprn_rec_adj.deprn_reserve := - 1 * (p_asset_retire_rec.cost_retired -
                                                   (nvl(p_asset_retire_rec.proceeds_of_sale, 0) -
                                                    nvl(p_asset_retire_rec.cost_of_removal, 0)) + nvl(l_recapture_amount,0));
   end if;
-- ENERGY

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Call FA_ADJUSTMENT_PVT.do_adjustment1',
                       'Begin',  p_log_level_rec => p_log_level_rec);
   end if;

   if not FA_ADJUSTMENT_PVT.do_adjustment
               (px_trans_rec              => l_trans_rec,
                px_asset_hdr_rec          => l_asset_hdr_rec,
                p_asset_desc_rec          => l_asset_desc_rec,
                p_asset_type_rec          => l_asset_type_rec,
                p_asset_cat_rec           => l_asset_cat_rec,
                p_asset_fin_rec_old       => l_asset_fin_rec_old,
                p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
                x_asset_fin_rec_new       => l_asset_fin_rec_new,
                p_inv_trans_rec           => l_inv_trans_rec,
                p_asset_deprn_rec_old     => l_asset_deprn_rec_old,
                p_asset_deprn_rec_adj     => l_asset_deprn_rec_adj,
                x_asset_deprn_rec_new     => l_asset_deprn_rec_new,
                p_period_rec              => p_period_rec,
                p_mrc_sob_type_code       => p_mrc_sob_type_code,
                p_group_reclass_options_rec => l_group_reclass_options_rec,
                p_calling_fn              => l_calling_fn, p_log_level_rec => p_log_level_rec) then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Calling FA_ADJUSTMENT_PVT.do_adjustment', 'Failed',  p_log_level_rec => p_log_level_rec);
      end if;

      raise ret_err;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'FA_ADJUSTMENT_PVT.do_adjustment', 'End',  p_log_level_rec => p_log_level_rec);
   end if;

   if (p_trans_rec.calling_interface <> 'FAXASSET') and
      (nvl(l_asset_fin_rec_new.cost, 0) <> 0) and
      (nvl(l_asset_fin_rec_new.tracking_method, 'NO TRACK') = 'ALLOCATE') and
      (fa_cache_pkg.fazcdrd_record.rule_name = 'ENERGY PERIOD END BALANCE') then

      l_alloc_amount := p_asset_retire_rec.cost_retired -
                        p_asset_retire_rec.reserve_retired -
                        (nvl(p_asset_retire_rec.proceeds_of_sale, 0) -
                         nvl(p_asset_retire_rec.cost_of_removal, 0) -
                         nvl(l_recapture_amount, 0)
                         );

      l_asset_deprn_rec_new.deprn_reserve := l_asset_deprn_rec_new.deprn_reserve -
                                             (p_asset_retire_rec.cost_retired -
                                              (nvl(p_asset_retire_rec.proceeds_of_sale, 0) -
                                               nvl(p_asset_retire_rec.cost_of_removal, 0)));

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Calling Do_Allocation', l_alloc_amount, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'Calling Do_Allocation', p_asset_retire_rec.proceeds_of_sale, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'Calling Do_Allocation', p_asset_retire_rec.cost_of_removal, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'Calling Do_Allocation', p_asset_retire_rec.reserve_retired, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'Calling Do_Allocation : l_recapture_amount', l_recapture_amount, p_log_level_rec => p_log_level_rec);
      end if;

      if not FA_RETIREMENT_PVT.Do_Allocation(
                      p_trans_rec         => l_trans_rec,
                      p_asset_hdr_rec     => l_asset_hdr_rec,
                      p_asset_fin_rec     => l_asset_fin_rec_new,
                      p_asset_deprn_rec_new => l_asset_deprn_rec_new, -- group new deprn rec
                      p_period_rec        => p_period_rec,
                      p_reserve_amount    => l_alloc_amount,
                      p_mrc_sob_type_code => p_mrc_sob_type_code,
                      p_calling_fn        => l_calling_fn, p_log_level_rec => p_log_level_rec) then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Calling FA_ADJUSTMENT_PVT.do_adjustment', 'Failed',  p_log_level_rec => p_log_level_rec);
         end if;

         raise ret_err;
      end if;
   end if; -- (nvl(l_asset_fin_rec_new.cost, 0) <> 0) and

   --
   -- Set status of retirement to PROCESSED so Gain Loss program won't pick this
   -- retirement up later.   This cannot be done at the time of insert since
   -- Distribution API called after FA_RETIREMENT_PUB.do_sub_regular_retirement
   -- is expecting the status to be PENDING.
   --
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Call FA_RETIREMENTS_PKG.Update_Row', 'Begin', p_log_level_rec => p_log_level_rec);
   end if;

   FA_RETIREMENTS_PKG.Update_Row(
                              X_Rowid             => l_rowid,
                              X_Retirement_Id     => p_asset_retire_rec.retirement_id,
                              X_Status            => 'PROCESSED',
                              X_Recapture_Amount  => l_recapture_amount,
                              X_mrc_sob_type_code => p_mrc_sob_type_code,
                              X_set_of_books_id   => p_asset_hdr_rec.set_of_books_id,
                              X_Calling_Fn        => l_calling_fn, p_log_level_rec => p_log_level_rec);

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Call FA_RETIREMENTS_PKG.Update_Row', 'End', p_log_level_rec => p_log_level_rec);
   end if;

   -- SLA: update the event status in SLA as well to unprocessed
   -- as original api inserted as incomplete

   if (p_mrc_sob_type_code <> 'R') then

      if p_log_level_rec.statement_level then
         fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'calling fa_xla_events_pvt.update_transaction_event with thid: ',
             value   => p_trans_rec.transaction_header_id);
      end if;

      if not fa_xla_events_pvt.update_transaction_event
               (p_ledger_id              => p_asset_hdr_rec.set_of_books_id,
                p_transaction_header_id  => p_trans_rec.transaction_header_id,
                p_book_type_code         => p_asset_hdr_rec.book_type_code,
                p_event_type_code        => 'RETIREMENTS',
                p_event_date             => p_asset_retire_rec.date_retired, --?
                p_event_status_code      => FA_XLA_EVENTS_PVT.C_EVENT_UNPROCESSED,
                p_calling_fn             => l_calling_fn,
                p_log_level_rec          => p_log_level_rec) then
         raise ret_err;
      end if;
   end if;


   -- Processing Terminal Gain Loss
   --
   -- If this is full retirement, check to see there is at least
   -- one asset remained in this group.  If not, declare remaining
   -- group reserve as terminal gain loss if group's terminal gain
   -- loss is set to 'YES'.
   --
   if (nvl(l_asset_fin_rec_old.terminal_gain_loss, 'NO')  <> 'NO') and
      (nvl(l_asset_fin_rec_new.cost, 0) = 0) and
      (p_trans_rec.transaction_type_code = 'FULL RETIREMENT') then

      OPEN c_member_exists;
      FETCH c_member_exists INTO l_member_exists;
      CLOSE c_member_exists;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Is there a member asset',
                          l_member_exists, p_log_level_rec => p_log_level_rec);
      end if;

      if (nvl(l_member_exists, 'N') <> 'Y') then

         FA_BOOKS_PKG.Update_Row(
                   X_Book_Type_Code               => l_asset_hdr_rec.book_type_code,
                   X_Asset_Id                     => l_asset_hdr_rec.asset_id,
                   X_terminal_gain_loss_flag      => 'Y',
                   X_mrc_sob_type_code            => p_mrc_sob_type_code,
                   X_set_of_books_id              => p_asset_hdr_rec.set_of_books_id,
                   X_Calling_Fn                   => l_calling_fn, p_log_level_rec => p_log_level_rec);

      end if; -- (nvl(l_member_exists, 'N') <> 'Y')

   end  if; -- (nvl(l_asset_fin_rec_old.terminal_gain_loss, 'NO')  = 'YES')

   end if; -- p_calling_fn <> 'DO_RETIREMENT.CGLFR_CR_ONLY'
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'End', 'Success', p_log_level_rec => p_log_level_rec);
   end if;

   return true;
EXCEPTION
  when ret_err then
    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'End', 'Failed', p_log_level_rec => p_log_level_rec);
    end if;

    fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return false;

  when OTHERS then
    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'End', 'Failed'||':'||sqlerrm, p_log_level_rec => p_log_level_rec);
    end if;

    fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return false;

END DO_RETIREMENT;

FUNCTION UNDO_RETIREMENT_REINSTATEMENT(p_transaction_header_id IN NUMBER,
                                       p_asset_hdr_rec         IN  FA_API_TYPES.asset_hdr_rec_type,
                                       p_group_asset_id        IN  NUMBER,
                                       p_set_of_books_id       IN NUMBER,
                                       p_mrc_sob_type_code     IN VARCHAR2,
                                       p_calling_fn            IN VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean IS

  CURSOR c_get_thid IS
    select transaction_header_id
    from   fa_transaction_headers
    where  asset_id = p_group_asset_id
    and    book_type_code = p_asset_hdr_rec.book_type_code
    and    member_transaction_header_id = p_transaction_header_id;

  l_transaction_header_id NUMBER(15);

  CURSOR c_adj IS
    select rowid
    from   fa_adjustments
    where  asset_id = p_group_asset_id
    and    book_type_code = p_asset_hdr_rec.book_type_code
    and    transaction_header_id = l_transaction_header_id;

  CURSOR c_mc_adj IS
    select rowid
    from   fa_mc_adjustments
    where  transaction_header_id = l_transaction_header_id
    and    set_of_books_id = p_set_of_books_id;

  l_calling_fn            VARCHAR2(100) := 'fa_group_retirement_pvt.undo_retirement_reinstatement';

BEGIN
--tk_util.debug(l_calling_fn||'()+');

  OPEN c_get_thid;
  FETCH c_get_thid INTO l_transaction_header_id;
  CLOSE c_get_thid;

  if (p_mrc_sob_type_code = 'R') then

    FA_BOOKS_PKG.Delete_Row(
                       X_Transaction_Header_Id_in => l_transaction_header_id,
                       X_mrc_sob_type_code        => p_mrc_sob_type_code,
                       X_set_of_books_id          => p_set_of_books_id,
                       X_Calling_Fn               => l_calling_fn, p_log_level_rec => p_log_level_rec);

    FA_BOOKS_PKG.Reactivate_Row(
                       X_Transaction_Header_Id_Out => l_transaction_header_id,
                       X_mrc_sob_type_code         => p_mrc_sob_type_code,
                       X_set_of_books_id          => p_set_of_books_id,
                       X_Calling_Fn                => l_calling_fn, p_log_level_rec => p_log_level_rec);

    for l_adj in c_mc_adj loop

      FA_ADJUSTMENTS_PKG.DELETE_ROW(
                       X_Rowid             => l_adj.rowid,
                       X_mrc_sob_type_code => p_mrc_sob_type_code,
                       X_set_of_books_id          => p_set_of_books_id,
                       X_Calling_Fn        => l_calling_fn, p_log_level_rec => p_log_level_rec);
    end loop;

  else

    FA_BOOKS_PKG.Delete_Row(
                       X_Transaction_Header_Id_in => l_transaction_header_id,
                       X_mrc_sob_type_code        => p_mrc_sob_type_code,
                       X_set_of_books_id          => p_set_of_books_id,
                       X_Calling_Fn               => l_calling_fn, p_log_level_rec => p_log_level_rec);

    FA_BOOKS_PKG.Reactivate_Row(
                       X_Transaction_Header_Id_Out => l_transaction_header_id,
                       X_mrc_sob_type_code         => p_mrc_sob_type_code,
                       X_set_of_books_id          => p_set_of_books_id,
                       X_Calling_Fn                => l_calling_fn, p_log_level_rec => p_log_level_rec);

    for l_adj in c_adj loop

      FA_ADJUSTMENTS_PKG.DELETE_ROW(
                         X_Rowid             => l_adj.rowid,
                         X_mrc_sob_type_code => p_mrc_sob_type_code,
                         X_set_of_books_id          => p_set_of_books_id,
                         X_Calling_Fn        => l_calling_fn, p_log_level_rec => p_log_level_rec);
    end loop;

  end if; -- (p_mrc_sob_type_code = 'R')

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'End', 'Success', p_log_level_rec => p_log_level_rec);
   end if;

  return true;

EXCEPTION
  when OTHERS then
    fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

    if c_get_thid%ISOPEN then
      CLOSE c_get_thid;
    end if;

    return false;

END UNDO_RETIREMENT_REINSTATEMENT;

FUNCTION DO_REINSTATEMENT(
                      p_trans_rec         IN     FA_API_TYPES.trans_rec_type,
                      p_asset_retire_rec  IN     FA_API_TYPES.asset_retire_rec_type,
                      p_asset_hdr_rec     IN     FA_API_TYPES.asset_hdr_rec_type,
                      p_asset_type_rec    IN     FA_API_TYPES.asset_type_rec_type,
                      p_asset_cat_rec     IN     FA_API_TYPES.asset_cat_rec_type,
                      p_asset_fin_rec     IN     FA_API_TYPES.asset_fin_rec_type,
                      p_asset_desc_rec    IN     FA_API_TYPES.asset_desc_rec_type,
                      p_period_rec        IN     FA_API_TYPES.period_rec_type,
                      p_mrc_sob_type_code IN     VARCHAR2,
                      p_calling_fn        IN     VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean IS

  l_calling_fn             VARCHAR2(100) := 'fa_group_retirement_pvt.do_reinstatement';

  l_out_trx_id        NUMBER(15); -- Transfer Out thid due to retirement

  CURSOR c_get_ret_dists IS
    select FA_DISTRIBUTION_HISTORY_S.NEXTVAL
         , -1 * transaction_units
         , assigned_to
         , code_combination_id
         , location_id
                        , units_assigned
    from   fa_distribution_history
    where  retirement_id = p_asset_retire_rec.retirement_id;

  CURSOR c_get_cur_dists (c_assigned_to   number,
                          c_expense_ccid  number,
                          c_location_ccid number) IS
    select distribution_id
         , units_assigned + nvl(transaction_units, 0)
    from   fa_distribution_history
    where  asset_id = p_asset_hdr_rec.asset_id
    and    book_type_code = p_asset_hdr_rec.book_type_code
    and    transaction_header_id_out is null
    and    (assigned_to = c_assigned_to
       or  (assigned_to is null and
            c_assigned_to is null))
    and    code_combination_id = c_expense_ccid
    and    location_id = c_location_ccid;

    CURSOR c_get_transaction_type_code IS
    select transaction_type_code
      from fa_transaction_headers
     where asset_id =  p_asset_hdr_rec.asset_id
       and book_type_code = p_asset_hdr_rec.book_type_code
       and transaction_header_id = p_asset_retire_rec.detail_info.transaction_header_id_in;

  l_trans_rec             FA_API_TYPES.trans_rec_type;
  l_asset_hdr_rec         FA_API_TYPES.asset_hdr_rec_type;


  CURSOR c_get_thid is
    select fa_transaction_headers_s.nextval
    from   dual;

  CURSOR c_get_primary_thid is
    select transaction_header_id
    from   fa_transaction_headers
    where  asset_id = p_asset_fin_rec.group_asset_id
    and    book_type_code = p_asset_hdr_rec.book_type_code
    and    member_transaction_header_id = p_trans_rec.transaction_header_id;

  l_rowid             ROWID;
  l_status            BOOLEAN := TRUE;

  TYPE tab_num_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE tab_num15_type IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;

  t_distribution_id tab_num15_type;
  t_units_assigned  tab_num_type;
  t_assigned_to     tab_num15_type;
  t_expense_ccid    tab_num15_type;
  t_location_ccid   tab_num15_type;
  t_tot_units       tab_num_type;
  l_row_fetched          NUMBER;

  l_distribution_id NUMBER(15);
  l_units_assigned  NUMBER;

  l_transaction_type_code varchar2(20);   -- Bug#8580378
  l_partial_retirement_flag BOOLEAN := FALSE;
  l_tot_units NUMBER := 0;

  l_adj              FA_ADJUST_TYPE_PKG.FA_ADJ_ROW_STRUCT;

  l_deprn_exp             NUMBER;
  l_bonus_deprn_exp       NUMBER;
  l_impairment_exp        NUMBER;

  -- +++++ Stores new fin_rec of member +++++
  l_asset_fin_rec_mn      FA_API_TYPES.asset_fin_rec_type;

  l_period_rec            FA_API_TYPES.period_rec_type;
  l_asset_desc_rec_m      FA_API_TYPES.asset_desc_rec_type;
  l_asset_desc_rec        FA_API_TYPES.asset_desc_rec_type;
  l_asset_type_rec        FA_API_TYPES.asset_type_rec_type;
  l_asset_cat_rec         FA_API_TYPES.asset_cat_rec_type;
  l_asset_fin_rec_new_m   FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_rec_old     FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_rec_adj     FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_rec_new     FA_API_TYPES.asset_fin_rec_type;
  l_inv_trans_rec         FA_API_TYPES.inv_trans_rec_type;
  l_asset_deprn_rec_old   FA_API_TYPES.asset_deprn_rec_type;
  l_asset_deprn_rec_adj   FA_API_TYPES.asset_deprn_rec_type;
  l_asset_deprn_rec_new   FA_API_TYPES.asset_deprn_rec_type;
  l_group_reclass_options_rec FA_API_TYPES.group_reclass_options_rec_type;

  l_salvage_value_retired NUMBER;
  l_cip_cost_retired      NUMBER;
  l_adj_rec_cost_retired  NUMBER;
  l_rec_cost_retired      NUMBER;
  l_deprn_limit_retired   NUMBER;

  l_reserve_allocated     NUMBER;

  cursor c_dist is
    select distribution_id
         , transaction_header_id_in
         , transaction_header_id_out
         , units_assigned
         , transaction_units
    from   fa_distribution_history
    where  asset_id = p_asset_hdr_rec.asset_id
    order by distribution_id;


  rein_err           EXCEPTION;
BEGIN
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Begin', p_asset_hdr_rec.asset_id||':'||p_asset_fin_rec.group_asset_id, p_log_level_rec => p_log_level_rec);
   end if;

   G_PART_RET_FLAG := FALSE;

   -- +++++ populate current period_rec info +++++
   if not FA_UTIL_PVT.get_period_rec
          (p_book           => p_asset_hdr_rec.book_type_code,
           x_period_rec     => l_period_rec, p_log_level_rec => p_log_level_rec) then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Calling FA_UTIL_PVT.get_period_rec', 'Failed',  p_log_level_rec => p_log_level_rec);
      end if;

      raise rein_err;
   end if;

   -- Get asset description for member asset
   -- p_asset_desc may be null
   if not FA_UTIL_PVT.get_asset_desc_rec (
                p_asset_hdr_rec         => p_asset_hdr_rec,
                px_asset_desc_rec       => l_asset_desc_rec_m, p_log_level_rec => p_log_level_rec) then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Calling FA_UTIL_PVT.get_asset_desc_rec', 'Failed',  p_log_level_rec => p_log_level_rec);
      end if;

      raise rein_err;
   end if;

   --
   -- Recreate Distributions, Asset History, and Addition only if
   -- retirement about to be reisntate is partial unit/full retirement and
   -- book class is CORPORATE.
   if nvl(p_asset_retire_rec.units_retired, 0) > 0 and
      fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE' and
      l_asset_desc_rec_m.current_units <> 0 then

      -- +++++ Get retired distribution +++++
      OPEN c_get_ret_dists;
      FETCH c_get_ret_dists BULK COLLECT INTO t_distribution_id,
                                              t_units_assigned,
                                              t_assigned_to,
                                              t_expense_ccid,
                                              t_location_ccid,
                                              t_tot_units;
      CLOSE c_get_ret_dists;

      l_row_fetched := t_distribution_id.COUNT;

      if (t_distribution_id.COUNT = 0) then

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Getting distribution info', 'Failed', p_log_level_rec => p_log_level_rec);
         end if;

         raise rein_err;
      end if;

      --
      -- For each distribution retired, if there is a existing active distribution
      -- which shares the same exp_ccid, location, and assigned_to, deactivate it
      -- and then added existing units to the retired units.
      for i in 1..l_row_fetched loop

         l_distribution_id          := to_number(null);
         l_units_assigned           := to_number(null);

         OPEN c_get_cur_dists(t_assigned_to(i), t_expense_ccid(i), t_location_ccid(i));
         FETCH c_get_cur_dists into l_distribution_id, l_units_assigned;
         CLOSE c_get_cur_dists;

         if (l_distribution_id is not null) then

            update FA_DISTRIBUTION_HISTORY
            set    transaction_units = nvl(transaction_units, t_units_assigned(i)),
                   transaction_header_id_out = p_trans_rec.transaction_header_id,
                   date_ineffective = p_trans_rec.who_info.last_update_date,
                   last_update_date = p_trans_rec.who_info.last_update_date,
                   last_updated_by = p_trans_rec.who_info.last_updated_by,
                   last_update_login = p_trans_rec.who_info.last_update_login
            where  distribution_id = l_distribution_id;

            t_units_assigned(i) := t_units_assigned(i) + l_units_assigned;

         end if;
         l_tot_units := l_tot_units + t_tot_units(i);
      end loop;

      -- +++++ Create retired distributions +++++
      FORALL i in 1..t_distribution_id.LAST
      insert into FA_DISTRIBUTION_HISTORY(
                            DISTRIBUTION_ID,
                            BOOK_TYPE_CODE,
                            ASSET_ID,
                            UNITS_ASSIGNED,
                            DATE_EFFECTIVE,
                            CODE_COMBINATION_ID,
                            LOCATION_ID,
                            TRANSACTION_HEADER_ID_IN,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            ASSIGNED_TO)
                     VALUES(t_distribution_id(i),
                            p_asset_hdr_rec.book_type_code,
                            p_asset_hdr_rec.asset_id,
                            t_units_assigned(i),
                            p_trans_rec.who_info.creation_date,
                            t_expense_ccid(i),
                            t_location_ccid(i),
                            p_trans_rec.transaction_header_id,
                            p_trans_rec.who_info.last_update_date,
                            p_trans_rec.who_info.last_updated_by,
                            t_assigned_to(i));

      --
      -- Full retirement didn't update Asset History and Additions, so maintain
      -- these only if it was partial unit retirement
      --

      if (l_tot_units <> p_asset_retire_rec.units_retired) then
          l_partial_retirement_flag := TRUE;
      else
          OPEN c_get_transaction_type_code;
          FETCH c_get_transaction_type_code into l_transaction_type_code;
          CLOSE c_get_transaction_type_code;

          if ( l_transaction_type_code <> 'FULL RETIREMENT' )  then
             l_partial_retirement_flag := TRUE;
          end if;
      end if;

      if ( l_partial_retirement_flag )  then
                   G_PART_RET_FLAG := TRUE;
         -- terminate old asset_history
         FA_ASSET_HISTORY_PKG.Update_Row
                   (X_Asset_Id                  => p_asset_hdr_rec.asset_id,
                    X_Date_Ineffective          => p_trans_rec.who_info.last_update_date,
                    X_Transaction_Header_Id_Out => p_trans_rec.transaction_header_id,
                    X_Last_Update_Date          => p_trans_rec.who_info.last_update_date,
                    X_Last_Updated_By           => p_trans_rec.who_info.last_updated_by,
                    X_Last_Update_Login         => p_trans_rec.who_info.last_update_login,
                    X_Return_Status             => l_status,
                    X_Calling_Fn                => l_calling_fn, p_log_level_rec => p_log_level_rec);
         if not(l_status) then
            raise rein_err;
         end if;

         -- insert new row with new units
         FA_ASSET_HISTORY_PKG.Insert_Row
                   (X_Rowid                     => l_rowid,
                    X_Asset_Id                  => p_asset_hdr_rec.asset_id,
                    X_Category_Id               => p_asset_cat_rec.category_id,
                    X_Asset_Type                => p_asset_type_rec.asset_type,
                    X_Units                     => l_asset_desc_rec_m.current_units + p_asset_retire_rec.units_retired,
                    X_Date_Effective            => p_trans_rec.who_info.last_update_date,
                    X_Transaction_Header_Id_In  => p_trans_rec.transaction_header_id,
                    X_Last_Update_Date          => p_trans_rec.who_info.last_update_date,
                    X_Last_Updated_By           => p_trans_rec.who_info.last_updated_by,
                    X_Return_Status             => l_status,
                    X_Calling_Fn                => 'FA_DISTRIBUTION_PVT.update_asset_history',  p_log_level_rec => p_log_level_rec);
         if not(l_status) then
            raise rein_err;
         end if;

         update fa_additions_b
         set    current_units = current_units + p_asset_retire_rec.units_retired
         where  asset_id = p_asset_hdr_rec.asset_id;

      end if; -- (l_asset_desc_rec_m.current_units > p_asset_retire_rec.units_retired)

   end if; --(nvl(p_asset_retire_rec.units_retired, 0) > 0)

   if (p_mrc_sob_type_code <> 'R') then
      OPEN c_get_thid;
      FETCH c_get_thid INTO l_trans_rec.transaction_header_id;
      CLOSE c_get_thid;
   else
      OPEN c_get_primary_thid;
      FETCH c_get_primary_thid INTO l_trans_rec.transaction_header_id;
      CLOSE c_get_primary_thid;
   end if;

   -- +++++ Process Group Asset +++++

   l_trans_rec.transaction_type_code := 'GROUP ADJUSTMENT';
   l_trans_rec.transaction_subtype := 'AMORTIZED';

   l_trans_rec.transaction_key := 'MS';
   l_trans_rec.who_info.creation_date := p_trans_rec.who_info.creation_date;
   l_trans_rec.who_info.created_by := p_trans_rec.who_info.created_by;
   l_trans_rec.who_info.last_update_date := p_trans_rec.who_info.last_update_date;
   l_trans_rec.who_info.last_updated_by := p_trans_rec.who_info.last_updated_by;
   l_trans_rec.who_info.last_update_login := p_trans_rec.who_info.last_update_login;
   l_trans_rec.member_transaction_header_id := p_trans_rec.transaction_header_id;
   l_trans_rec.mass_transaction_id := p_trans_rec.mass_transaction_id;
   l_trans_rec.calling_interface := p_trans_rec.calling_interface;
   l_trans_rec.mass_reference_id := p_trans_rec.mass_reference_id;
   l_trans_rec.event_id := p_trans_rec.event_id;

   -- Need deprn rec before reinstatement
   l_asset_hdr_rec.asset_id := p_asset_fin_rec.group_asset_id;
   l_asset_hdr_rec.book_type_code := p_asset_hdr_rec.book_type_code;
   l_asset_hdr_rec.set_of_books_id := p_asset_hdr_rec.set_of_books_id;
   --l_asset_hdr_rec.period_of_addition := 'N'; -- Guess not necessary

   if not CALC_GAIN_LOSS_FOR_REI(
                 p_trans_rec         => p_trans_rec,
                 p_asset_hdr_rec     => p_asset_hdr_rec,
                 p_asset_type_rec    => p_asset_type_rec,
                 p_asset_desc_rec    => l_asset_desc_rec_m,
                 p_asset_cat_rec     => p_asset_cat_rec,
                 p_asset_fin_rec     => p_asset_fin_rec,
                 p_period_rec        => l_period_rec,
                 p_asset_retire_rec  => p_asset_retire_rec,
                 p_group_thid        => l_trans_rec.transaction_header_id,
                 x_asset_fin_rec     => l_asset_fin_rec_mn,
                 p_mrc_sob_type_code => p_mrc_sob_type_code,
                 p_log_level_rec         => p_log_level_rec) then
      raise rein_err;
   end if;

   if not fa_util_pvt.get_asset_deprn_rec (
                   p_asset_hdr_rec         => l_asset_hdr_rec,
                   px_asset_deprn_rec      => l_asset_deprn_rec_old,
                   p_mrc_sob_type_code     => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
      raise rein_err;
   end if;

   if not FA_UTIL_PVT.get_asset_type_rec
                  (p_asset_hdr_rec      => l_asset_hdr_rec,
                   px_asset_type_rec    => l_asset_type_rec, p_log_level_rec => p_log_level_rec) then
      raise rein_err;
   end if;

   if not FA_UTIL_PVT.get_asset_desc_rec
             (p_asset_hdr_rec         => l_asset_hdr_rec,
              px_asset_desc_rec       => l_asset_desc_rec, p_log_level_rec => p_log_level_rec) then
      raise rein_err;
   end if;

   if not FA_UTIL_PVT.get_asset_cat_rec
             (p_asset_hdr_rec         => l_asset_hdr_rec,
              px_asset_cat_rec        => l_asset_cat_rec,
              p_date_effective        => null, p_log_level_rec => p_log_level_rec) then
      raise rein_err;
   end if;

   if not fa_util_pvt.get_asset_fin_rec (
                   p_asset_hdr_rec         => l_asset_hdr_rec,
                   px_asset_fin_rec        => l_asset_fin_rec_old,
                   p_mrc_sob_type_code     => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
      raise rein_err;
   end if;

   --HH Validate disabled_flag
   --We don't want to reinstate assets belonging to a disabled group.
   if not FA_ASSET_VAL_PVT.validate_disabled_flag
                  (p_group_asset_id => l_asset_hdr_rec.asset_id,
                   p_book_type_code => l_asset_hdr_rec.book_type_code,
                   p_old_flag       => l_asset_fin_rec_old.disabled_flag,
                   p_new_flag       => l_asset_fin_rec_old.disabled_flag
                  , p_log_level_rec => p_log_level_rec) then
               raise rein_err;
   end if; --End HH

/*
   if not fa_util_pvt.get_asset_deprn_rec (
                   p_asset_hdr_rec         => l_asset_hdr_rec,
                   px_asset_deprn_rec      => l_asset_deprn_rec_old,
                   p_mrc_sob_type_code     => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
      raise rein_err;
   end if;
*/

   l_asset_fin_rec_adj.cost := p_asset_retire_rec.cost_retired;
   l_asset_fin_rec_adj.unrevalued_cost := p_asset_retire_rec.cost_retired;

   -- Get new member's fin_rec
   if not fa_util_pvt.get_asset_fin_rec (
                   p_asset_hdr_rec         => p_asset_hdr_rec,
                   px_asset_fin_rec        => l_asset_fin_rec_new_m,
                   p_mrc_sob_type_code     => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
      raise rein_err;
   end if;

   l_asset_fin_rec_adj.salvage_value := nvl(l_asset_fin_rec_new_m.salvage_value, 0) -
                                        nvl(p_asset_fin_rec.salvage_value, 0);

   l_asset_fin_rec_adj.allowed_deprn_limit_amount :=
                                        nvl(l_asset_fin_rec_new_m.allowed_deprn_limit_amount, 0) -
                                        nvl(p_asset_fin_rec.allowed_deprn_limit_amount, 0);

--   l_asset_deprn_rec_adj.deprn_reserve := p_asset_retire_rec.reserve_retired;

   --
   -- Process member asset reinstatement
   --
   -- Find Salvage value retired, recoverable cost, deprn limit, adjusted recoverable cost
   -- cip_cost_retired, new adjusted cost by calling deprn basis.
   -- Also find out whether there is other amount to reinstate.  I guess not.
   FA_BOOKS_PKG.Deactivate_Row(
          X_Asset_Id                     => p_asset_hdr_rec.asset_id,
          X_Book_Type_Code               => p_asset_hdr_rec.book_type_code,
          X_Transaction_Header_Id_Out    => p_trans_rec.transaction_header_id,
          X_Date_Ineffective             => p_trans_rec.who_info.last_update_date,
          X_mrc_sob_type_code            => p_mrc_sob_type_code,
          X_set_of_books_id              => p_asset_hdr_rec.set_of_books_id,
          X_Calling_Fn                   => l_calling_fn, p_log_level_rec => p_log_level_rec);

--tk_util.DumpFinRec(l_asset_fin_rec_mn, 'member');

   FA_BOOKS_PKG.INSERT_ROW(
          X_Rowid                        => l_rowid,
          X_Book_Type_Code               => p_asset_hdr_rec.book_type_code,
          X_Asset_Id                     => p_asset_hdr_rec.asset_id,
          X_Date_Placed_In_Service       => p_asset_fin_rec.date_placed_in_service,
          X_Date_Effective               => p_trans_rec.who_info.creation_date,
          X_Deprn_Start_Date             => p_asset_fin_rec.deprn_start_date,
          X_Deprn_Method_Code            => p_asset_fin_rec.deprn_method_code,
          X_Life_In_Months               => p_asset_fin_rec.life_in_months,
          X_Rate_Adjustment_Factor       => l_asset_fin_rec_mn.rate_adjustment_factor,
          X_Adjusted_Cost                => l_asset_fin_rec_mn.adjusted_cost,
          X_Cost                         => l_asset_fin_rec_mn.cost,
          X_Original_Cost                => p_asset_fin_rec.original_cost,
          X_Salvage_Value                => l_asset_fin_rec_mn.salvage_value,
          X_Prorate_Convention_Code      => p_asset_fin_rec.prorate_convention_code,
          X_Prorate_Date                 => p_asset_fin_rec.prorate_date,
          X_Cost_Change_Flag             => p_asset_fin_rec.cost_change_flag,
          X_Adjustment_Required_Status   => p_asset_fin_rec.adjustment_required_status,
          X_Capitalize_Flag              => p_asset_fin_rec.capitalize_flag,
          X_Retirement_Pending_Flag      => 'NO',
          X_Depreciate_Flag              => p_asset_fin_rec.depreciate_flag,
          X_Disabled_Flag                => p_asset_fin_rec.disabled_flag, --HH
          X_Last_Update_Date             => p_trans_rec.who_info.last_update_date,
          X_Last_Updated_By              => p_trans_rec.who_info.last_updated_by,
          X_Transaction_Header_Id_In     => p_trans_rec.transaction_header_id,
          X_Itc_Amount_Id                => p_asset_fin_rec.itc_amount_id,
          X_Itc_Amount                   => p_asset_fin_rec.itc_amount,
  --        X_Retirement_Id                => ,
  --        X_Tax_Request_Id               => ,
          X_Itc_Basis                    => p_asset_fin_rec.itc_basis,
          X_Basic_Rate                   => p_asset_fin_rec.basic_rate,
          X_Adjusted_Rate                => p_asset_fin_rec.adjusted_rate,
          X_Bonus_Rule                   => p_asset_fin_rec.bonus_rule,
          X_Ceiling_Name                 => p_asset_fin_rec.ceiling_name,
          X_Recoverable_Cost             => l_asset_fin_rec_mn.recoverable_cost,
          X_Adjusted_Capacity            => l_asset_fin_rec_mn.adjusted_capacity,
          X_Fully_Rsvd_Revals_Counter    => p_asset_fin_rec.fully_rsvd_revals_counter,
          X_Idled_Flag                   => p_asset_fin_rec.idled_flag,
          X_Period_Counter_Capitalized   => p_asset_fin_rec.period_counter_capitalized,
          X_PC_Fully_Reserved            => null,
          X_Production_Capacity          => p_asset_fin_rec.production_capacity,
          X_Reval_Amortization_Basis     => l_asset_fin_rec_mn.reval_amortization_basis,
          X_Reval_Ceiling                => l_asset_fin_rec_mn.reval_ceiling,
          X_Unit_Of_Measure              => p_asset_fin_rec.unit_of_measure,
          X_Unrevalued_Cost              => l_asset_fin_rec_mn.unrevalued_cost,
          X_Annual_Deprn_Rounding_Flag   => l_asset_fin_rec_mn.annual_deprn_rounding_flag,
          X_Percent_Salvage_Value        => p_asset_fin_rec.percent_salvage_value,
          X_Allowed_Deprn_Limit          => p_asset_fin_rec.allowed_deprn_limit,
          X_Allowed_Deprn_Limit_Amount   => l_asset_fin_rec_mn.allowed_deprn_limit_amount,
          X_Period_Counter_Life_Complete => p_asset_fin_rec.period_counter_life_complete,
          X_Adjusted_Recoverable_Cost    => l_asset_fin_rec_mn.adjusted_recoverable_cost,
          X_Short_Fiscal_Year_Flag       => p_asset_fin_rec.short_fiscal_year_flag,
          X_Conversion_Date              => p_asset_fin_rec.conversion_date,
          X_Orig_Deprn_Start_Date        => p_asset_fin_rec.orig_deprn_start_date,
          X_Remaining_Life1              => p_asset_fin_rec.remaining_life1,
          X_Remaining_Life2              => p_asset_fin_rec.remaining_life2,
          X_Old_Adj_Cost                 => p_asset_fin_rec.adjusted_cost,   ---???
          X_Formula_Factor               => l_asset_fin_rec_mn.formula_factor,
          X_gf_Attribute1                => p_asset_fin_rec.global_attribute1,
          X_gf_Attribute2                => p_asset_fin_rec.global_attribute2,
          X_gf_Attribute3                => p_asset_fin_rec.global_attribute3,
          X_gf_Attribute4                => p_asset_fin_rec.global_attribute4,
          X_gf_Attribute5                => p_asset_fin_rec.global_attribute5,
          X_gf_Attribute6                => p_asset_fin_rec.global_attribute6,
          X_gf_Attribute7                => p_asset_fin_rec.global_attribute7,
          X_gf_Attribute8                => p_asset_fin_rec.global_attribute8,
          X_gf_Attribute9                => p_asset_fin_rec.global_attribute9,
          X_gf_Attribute10               => p_asset_fin_rec.global_attribute10,
          X_gf_Attribute11               => p_asset_fin_rec.global_attribute11,
          X_gf_Attribute12               => p_asset_fin_rec.global_attribute12,
          X_gf_Attribute13               => p_asset_fin_rec.global_attribute13,
          X_gf_Attribute14               => p_asset_fin_rec.global_attribute14,
          X_gf_Attribute15               => p_asset_fin_rec.global_attribute15,
          X_gf_Attribute16               => p_asset_fin_rec.global_attribute16,
          X_gf_Attribute17               => p_asset_fin_rec.global_attribute17,
          X_gf_Attribute18               => p_asset_fin_rec.global_attribute18,
          X_gf_Attribute19               => p_asset_fin_rec.global_attribute19,
          X_gf_Attribute20               => p_asset_fin_rec.global_attribute20,
          X_global_attribute_category    => p_asset_fin_rec.global_attribute_category,
          X_group_asset_id               => p_asset_fin_rec.group_asset_id,
          X_salvage_type                 => p_asset_fin_rec.salvage_type,
          X_deprn_limit_type             => p_asset_fin_rec.deprn_limit_type,
          X_over_depreciate_option       => p_asset_fin_rec.over_depreciate_option,
          X_super_group_id               => p_asset_fin_rec.super_group_id,
          X_reduction_rate               => l_asset_fin_rec_mn.reduction_rate,
          X_reduce_addition_flag         => p_asset_fin_rec.reduce_addition_flag,
          X_reduce_adjustment_flag       => p_asset_fin_rec.reduce_adjustment_flag,
          X_reduce_retirement_flag       => p_asset_fin_rec.reduce_retirement_flag,
          X_recognize_gain_loss          => p_asset_fin_rec.recognize_gain_loss,
          X_recapture_reserve_flag       => p_asset_fin_rec.recapture_reserve_flag,
          X_limit_proceeds_flag          => p_asset_fin_rec.limit_proceeds_flag,
          X_terminal_gain_loss           => p_asset_fin_rec.terminal_gain_loss,
          X_tracking_method              => p_asset_fin_rec.tracking_method,
          X_allocate_to_fully_rsv_flag   => p_asset_fin_rec.allocate_to_fully_rsv_flag,
          X_allocate_to_fully_ret_flag   => p_asset_fin_rec.allocate_to_fully_ret_flag,
          X_exclude_fully_rsv_flag       => p_asset_fin_rec.exclude_fully_rsv_flag,
          X_excess_allocation_option     => p_asset_fin_rec.excess_allocation_option,
          X_depreciation_option          => p_asset_fin_rec.depreciation_option,
          X_member_rollup_flag           => p_asset_fin_rec.member_rollup_flag,
          X_ytd_proceeds                 => l_asset_fin_rec_mn.ytd_proceeds,
          X_ltd_proceeds                 => l_asset_fin_rec_mn.ltd_proceeds,
          X_eofy_reserve                 => l_asset_fin_rec_mn.eofy_reserve,
          X_cip_cost                     => l_asset_fin_rec_mn.cip_cost,
          X_terminal_gain_loss_amount    => l_asset_fin_rec_mn.terminal_gain_loss_amount,
          X_ltd_cost_of_removal          => l_asset_fin_rec_mn.ltd_cost_of_removal,
          X_cash_generating_unit_id      =>
                                      p_asset_fin_rec.cash_generating_unit_id,
          X_Return_Status                => l_status,
          X_mrc_sob_type_code            => p_mrc_sob_type_code,
          X_set_of_books_id              => p_asset_hdr_rec.set_of_books_id,
          X_Calling_Fn                   => l_calling_fn,
          p_log_level_rec                => p_log_level_rec);

   if (not(l_status)) then
      raise rein_err;
   end if;

   if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn, 'transaction_date_entered',
                          p_trans_rec.transaction_date_entered, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'amortization_start_date',
                          p_trans_rec.amortization_start_date, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'new.cost', l_asset_fin_rec_new.cost, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'tracking_method',l_asset_fin_rec_old.tracking_method, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'rule_name',fa_cache_pkg.fazcdrd_record.rule_name, p_log_level_rec => p_log_level_rec);
   end if;


   if (nvl(l_asset_fin_rec_old.tracking_method, 'NO TRACK') = 'ALLOCATE') and
      (fa_cache_pkg.fazcdrd_record.rule_name = 'ENERGY PERIOD END BALANCE') then
      l_trans_rec.transaction_date_entered := p_trans_rec.transaction_date_entered;
      l_trans_rec.amortization_start_date := p_trans_rec.transaction_date_entered;
   else
      l_trans_rec.transaction_date_entered := p_asset_retire_rec.date_retired;
      l_trans_rec.amortization_start_date := p_asset_retire_rec.date_retired;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Call FA_ADJUSTMENT_PVT.do_adjustment2',
                       'Begin',  p_log_level_rec => p_log_level_rec);

   end if;


      if not FA_ADJUSTMENT_PVT.do_adjustment
               (px_trans_rec              => l_trans_rec,
                px_asset_hdr_rec          => l_asset_hdr_rec,
                p_asset_desc_rec          => l_asset_desc_rec,
                p_asset_type_rec          => l_asset_type_rec,
                p_asset_cat_rec           => l_asset_cat_rec,
                p_asset_fin_rec_old       => l_asset_fin_rec_old,
                p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
                x_asset_fin_rec_new       => l_asset_fin_rec_new,
                p_inv_trans_rec           => l_inv_trans_rec,
                p_asset_deprn_rec_old     => l_asset_deprn_rec_old,
                p_asset_deprn_rec_adj     => l_asset_deprn_rec_adj,
                x_asset_deprn_rec_new     => l_asset_deprn_rec_new,
                p_period_rec              => l_period_rec,
                p_mrc_sob_type_code       => p_mrc_sob_type_code,
                p_group_reclass_options_rec => l_group_reclass_options_rec,
                p_calling_fn              => l_calling_fn, p_log_level_rec => p_log_level_rec)then
         raise rein_err;
      end if;

   if (nvl(l_asset_fin_rec_old.member_rollup_flag, 'N') = 'Y') then
      --
      -- This is Sum up member depreciation to group asset
      --
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Process Member Rollup Group',
                          l_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
      end if;
      -- +++++ Remove group expense rows +++++
      DELETE FROM FA_ADJUSTMENTS
      WHERE  ASSET_ID = l_asset_hdr_rec.asset_id
      AND    BOOK_TYPE_CODE = l_asset_hdr_rec.book_type_code
      AND    TRANSACTION_HEADER_ID = l_trans_rec.member_transaction_header_id
      AND    SOURCE_TYPE_CODE = 'DEPRECIATION'
      AND    ADJUSTMENT_TYPE in ('EXPENSE', 'BONUS EXPENSE',
                                 'IMPAIR EXPENSE');

   end if; -- (nvl(l_asset_fin_rec_old.member_rollup_flag, 'N') = 'Y')

   -- +++++ Clear Terminal Gain Loss Amount +++++
   FA_BOOKS_PKG.Update_Row(
                   X_Book_Type_Code            => l_asset_hdr_rec.book_type_code,
                   X_Asset_Id                  => l_asset_hdr_rec.asset_id,
                   X_terminal_gain_loss_amount => FND_API.G_MISS_NUM,
                   X_mrc_sob_type_code         => p_mrc_sob_type_code,
                   X_set_of_books_id           => p_asset_hdr_rec.set_of_books_id,
                   X_Calling_Fn                => l_calling_fn, p_log_level_rec => p_log_level_rec);


   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'End', 'Success', p_log_level_rec => p_log_level_rec);
   end if;

   if (p_trans_rec.calling_interface <> 'FAXASSET') then

      if (nvl(l_asset_fin_rec_old.tracking_method, 'NO TRACK') = 'ALLOCATE') and
         (fa_cache_pkg.fazcdrd_record.rule_name = 'ENERGY PERIOD END BALANCE') then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Calling Do_Allocation', ' ', p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'proceeds_of_sale', p_asset_retire_rec.proceeds_of_sale, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'cost_of_removal', p_asset_retire_rec.cost_of_removal, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'reserve_retired', p_asset_retire_rec.reserve_retired, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'recapture_amount', p_asset_retire_rec.detail_info.recapture_amount, p_log_level_rec => p_log_level_rec);
         end if;

         l_reserve_allocated := p_asset_retire_rec.cost_retired -
                                nvl(p_asset_retire_rec.proceeds_of_sale, 0) +
                                nvl(p_asset_retire_rec.cost_of_removal, 0) -
                                nvl(p_asset_retire_rec.reserve_retired, 0)+
                                nvl(p_asset_retire_rec.detail_info.recapture_amount, 0);

         if not FA_RETIREMENT_PVT.Do_Allocation(
                         p_trans_rec         => l_trans_rec,
                         p_asset_hdr_rec     => l_asset_hdr_rec,
                         p_asset_fin_rec     => l_asset_fin_rec_new,
                         p_asset_deprn_rec_new => l_asset_deprn_rec_new,
                         p_period_rec        => l_period_rec,
                         p_reserve_amount    => l_reserve_allocated,
                         p_mem_ret_thid      => p_asset_retire_rec.detail_info.transaction_header_id_in,
                         p_mrc_sob_type_code => p_mrc_sob_type_code,
                         p_calling_fn        => l_calling_fn, p_log_level_rec => p_log_level_rec) then
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Calling FA_ADJUSTMENT_PVT.Do_Allocation', 'Failed',  p_log_level_rec => p_log_level_rec);
            end if;

            raise rein_err;
         end if;
      end if; -- (nvl(l_asset_fin_rec_old.tracking_method, 'NO TRACK') = 'ALLOCATE')

   end if; -- (p_trans_rec.calling_interface <> 'FAXASSET')

   if (p_log_level_rec.statement_level) then
      for r_dist in c_dist loop
         fa_debug_pkg.add(l_calling_fn, 'distribution_id', r_dist.distribution_id, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'transaction_header_id_in', r_dist.transaction_header_id_in, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'transaction_header_id_out', r_dist.transaction_header_id_out, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'units_assigned', r_dist.units_assigned, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'transaction_units', r_dist.transaction_units, p_log_level_rec => p_log_level_rec);
      end loop;
   end if;

   return true;

EXCEPTION
  when rein_err then
    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, '(rein_err)Processing reinstatement', 'Failed');
    end if;

    fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

    return false;

  when OTHERS then
    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, '(others)Processing reinstatement', 'Failed');
    end if;

    fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

    return false;

END DO_REINSTATEMENT;

/*====================================================================+
 | Function                                                           |
 |   CALC_GAIN_LOSS_FOR_RET                                           |
 |                                                                    |
 | Description                                                        |
 |   This function maintain FA_(MC_)ADJUSTMENTS table for group       |
 |   retirement.                                                      |
 |                                                                    |
 +====================================================================*/
FUNCTION CALC_GAIN_LOSS_FOR_RET(
               p_trans_rec             IN     FA_API_TYPES.trans_rec_type,
               p_asset_hdr_rec         IN     FA_API_TYPES.asset_hdr_rec_type,
               p_asset_type_rec        IN     FA_API_TYPES.asset_type_rec_type,
               p_asset_desc_rec        IN     FA_API_TYPES.asset_desc_rec_type,
               p_asset_cat_rec         IN     FA_API_TYPES.asset_cat_rec_type,
               p_asset_fin_rec         IN     FA_API_TYPES.asset_fin_rec_type,
               p_period_rec            IN     FA_API_TYPES.period_rec_type,
               p_asset_retire_rec      IN     FA_API_TYPES.asset_retire_rec_type,
               p_group_thid            IN     NUMBER,
               p_salvage_value_retired IN     NUMBER,
               p_mrc_sob_type_code     IN     VARCHAR2,
               p_mode                  IN     VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return BOOLEAN is

/* --Commented out as part of fix for 3188851.
  -- Cursor to get transaction header id of transfer out in
  -- case of partial unit retirement
  CURSOR c_get_thid IS
    select distinct nvl(transaction_header_id_out,0)
    from   fa_distribution_history
    where  asset_id = p_asset_hdr_rec.asset_id
    and    book_type_code = p_asset_hdr_rec.book_type_code
    and    retirement_id = p_asset_retire_rec.retirement_id; */

   CURSOR c_get_group_method_info is                  -- ENERGY
      select db.rule_name                             -- ENERGY
      from   fa_deprn_basis_rules db                  -- ENERGY
           , fa_methods mt                            -- ENERGY
           , fa_books bk                              -- ENERGY
      where  bk.asset_id = p_asset_fin_rec.group_asset_id           -- ENERGY
      and    bk.book_type_code = p_asset_hdr_rec.book_type_code   -- ENERGY
      and    bk.transaction_header_id_out is null                      -- ENERGY
      and    bk.deprn_method_code = mt.method_code                     -- ENERGY
      and    nvl(bk.life_in_months, -99) = nvl(mt.life_in_months, -99) -- ENERGY
      and    mt.deprn_basis_rule_id = db.deprn_basis_rule_id;          -- ENERGY

  l_calling_fn        VARCHAR2(100) := 'fa_retirement_pvt.calc_gain_loss_for_ret';

  l_asset_hdr_rec   FA_API_TYPES.asset_hdr_rec_type;
  l_asset_cat_rec   FA_API_TYPES.asset_cat_rec_type;

  l_trans_rec         FA_API_TYPES.trans_rec_type;
  l_asset_fin_rec_adj FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_rec_new FA_API_TYPES.asset_fin_rec_type;
  l_asset_deprn_rec   FA_API_TYPES.asset_deprn_rec_type;

  l_adj               FA_ADJUST_TYPE_PKG.FA_ADJ_ROW_STRUCT;

  l_deprn_exp         NUMBER;
  l_bonus_deprn_exp   NUMBER;
  l_impairment_exp    NUMBER;

  l_group_db_rule_name VARCHAR2(80);

  calc_err            EXCEPTION;


BEGIN
  if (p_log_level_rec.statement_level) then
    fa_debug_pkg.add(l_calling_fn, 'Begin',
                     p_asset_hdr_rec.asset_id||':'||p_asset_fin_rec.group_asset_id, p_log_level_rec => p_log_level_rec);
  end if;

  -- BUG# 3641747
  -- call cache as it was not yet initialized
  if not fa_cache_pkg.fazccb(p_asset_hdr_rec.book_type_code,
                             p_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
     fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
     raise calc_err;
  end if;

  l_adj.transaction_header_id   := p_trans_rec.transaction_header_id;
  l_adj.book_type_code          := p_asset_hdr_rec.book_type_code;
  l_adj.period_counter_created  := p_period_rec.period_counter;
  l_adj.period_counter_adjusted := p_period_rec.period_counter;
  l_adj.current_units           := p_asset_desc_rec.current_units;
  l_adj.selection_retid         := 0;
  l_adj.leveling_flag           := TRUE;
  l_adj.flush_adj_flag          := FALSE;

  l_adj.last_update_date        := p_trans_rec.who_info.last_update_date;

  l_adj.gen_ccid_flag           := TRUE;

  l_adj.asset_id                := p_asset_hdr_rec.asset_id;

  l_adj.adjustment_type         := 'COST';
  l_adj.debit_credit_flag       := 'CR';
  l_adj.code_combination_id     := 0;
  l_adj.mrc_sob_type_code       := p_mrc_sob_type_code;
  l_adj.set_of_books_id         := p_asset_hdr_rec.set_of_books_id;

  if p_asset_type_rec.asset_type = 'CIP' then
    l_adj.source_type_code := 'CIP RETIREMENT';
    l_adj.account := fa_cache_pkg.fazccb_record.cip_cost_acct;
    l_adj.account_type := 'CIP_COST_ACCT';
  else
    l_adj.source_type_code := 'RETIREMENT';
    l_adj.account := fa_cache_pkg.fazccb_record.asset_cost_acct;
    l_adj.account_type := 'ASSET_COST_ACCT';
  end if;

  --fa_debug_pkg.add(l_calling_fn,'Before 1st check, book_class', fa_cache_pkg.fazcbc_record.book_class, p_log_level_rec => p_log_level_rec);

  if ((nvl(p_asset_retire_rec.units_retired, 0) > 0) and
      (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') and
      (p_mode = 'CR')) then
    /* --Commented out as part of fix for 3188851.
     OPEN c_get_thid;
     FETCH c_get_thid INTO l_adj.selection_thid;
     CLOSE c_get_thid;

     if (nvl(l_adj.selection_thid, 0) = 0) then

        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'Error', 'Getting selection_thid', p_log_level_rec => p_log_level_rec);
        end if;

        raise calc_err;
     end if; */
     l_adj.adjustment_amount       := p_asset_fin_rec.cost;
     l_adj.selection_thid          := p_trans_rec.transaction_header_id;
     l_adj.selection_mode          := FA_STD_TYPES.FA_AJ_CLEAR;
--tk_util.DumpAdjRec(l_adj, 'URCR');
     if not FA_INS_ADJUST_PKG.faxinaj
                         (l_adj,
                          p_trans_rec.who_info.last_update_date,
                          p_trans_rec.who_info.last_updated_by,
                          p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
        raise calc_err;
     end if;

  -- Not a partial unit ret.
  -- 3440308
  elsif ((p_asset_retire_rec.units_retired IS NULL) OR
        (NVL(p_asset_retire_rec.units_retired, 0) = g_current_units)) THEN
  --end 3440308
     l_adj.adjustment_amount       := p_asset_retire_rec.cost_retired;
     l_adj.selection_thid          := 0;
     l_adj.selection_mode          := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;

     if not FA_INS_ADJUST_PKG.faxinaj
                         (l_adj,
                          p_trans_rec.who_info.last_update_date,
                          p_trans_rec.who_info.last_updated_by,
                          p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
        raise calc_err;
     end if;
  end if;

  --fa_debug_pkg.add(l_calling_fn,'Before DR logic, book',p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
  -- Need to call cache again as this gets reset when the dist api gets called.
  if not fa_cache_pkg.fazcbc(x_book => p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
  end if;

  --Doing this check due to 3188851.
  if p_mode <> 'CR' then

    --fa_debug_pkg.add(l_calling_fn,'In DR logic, units_retired',p_asset_retire_rec.units_retired, p_log_level_rec => p_log_level_rec);
    --fa_debug_pkg.add(l_calling_fn,'In DR logic, book_class', fa_cache_pkg.fazcbc_record.book_class, p_log_level_rec => p_log_level_rec);

    if ((nvl(p_asset_retire_rec.units_retired, 0) > 0) and
       (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE')) then
       --
       -- With unkonwn reason l_adj.account is set to null so
       -- need to resert the same value.
       --
       if p_asset_type_rec.asset_type = 'CIP' then
          l_adj.account := fa_cache_pkg.fazccb_record.cip_cost_acct;
       else
          l_adj.account := fa_cache_pkg.fazccb_record.asset_cost_acct;
       end if;

       l_adj.selection_thid          := 0;
       l_adj.selection_mode          := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
       l_adj.current_units           := p_asset_desc_rec.current_units;

       l_adj.debit_credit_flag := 'DR';
       l_adj.leveling_flag := FALSE;
       l_adj.adjustment_amount := p_asset_fin_rec.cost - p_asset_retire_rec.cost_retired;
--tk_util.DumpAdjRec(l_adj, 'URDR');
       if (l_adj.adjustment_amount <>0) then
          if not FA_INS_ADJUST_PKG.faxinaj
                              (l_adj,
                               p_trans_rec.who_info.last_update_date,
                               p_trans_rec.who_info.last_updated_by,
                               p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
            raise calc_err;
          end if;
       end if;
/* -- no need for this since it will use above condition in CR logic.
    else
      --tk_util.DumpAdjRec(l_adj, 'URCR');
       if not FA_INS_ADJUST_PKG.faxinaj
                         (l_adj,
                          p_trans_rec.who_info.last_update_date,
                          p_trans_rec.who_info.last_updated_by,
                          p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
          raise calc_err;
       end if; */

    end if; -- ((nvl(p_asset_retire_rec.units_retired, 0) > 0) and

   --
   -- Creating Member Entires for Tracking
   --
   if (p_asset_fin_rec.tracking_method = 'ALLOCATE') or
      (p_asset_fin_rec.tracking_method = 'CALCULATE') and
       (nvl(p_asset_fin_rec.member_rollup_flag, 'N') = 'N') then
      l_adj.selection_mode          := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
      l_adj.distribution_id         := 0;

      l_adj.adjustment_type         := 'RESERVE';
      l_adj.debit_credit_flag       := 'DR';
      l_adj.account_type            := 'DEPRN_RESERVE_ACCT';
      l_adj.account                 := fa_cache_pkg.fazccb_record.DEPRN_RESERVE_ACCT;

      OPEN c_get_group_method_info;                                                          -- ENERGY
      FETCH c_get_group_method_info INTO l_group_db_rule_name;                               -- ENERGY
      CLOSE c_get_group_method_info;                                                         -- ENERGY

      -- BUG# 6899255
      -- now handling member track amount the same for energy
      -- and non-energy cases by hitting the true tracked
      -- amount, rather than the cost to avoid leaving a balance.
      --
      -- (l_group_db_rule_name = 'ENERGY PERIOD END BALANCE')
      -- ENERGY

      if (nvl(p_asset_fin_rec.tracking_method, 'NON TRACK')  = 'ALLOCATE') then
                                                                                             -- ENERGY
         if not fa_util_pvt.get_asset_deprn_rec (                                            -- ENERGY
                 p_asset_hdr_rec         => p_asset_hdr_rec,                                 -- ENERGY
                 px_asset_deprn_rec      => l_asset_deprn_rec,                               -- ENERGY
                 p_mrc_sob_type_code     => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then                        -- ENERGY
            raise calc_err;                                                                  -- ENERGY
         end if;                                                                             -- ENERGY
         -- bug9431199
         if (p_asset_fin_rec.cost <> 0 ) then                                                                                   -- ENERGY
             l_adj.adjustment_amount := l_asset_deprn_rec.deprn_reserve *                        -- ENERGY
                                        (p_asset_retire_rec.cost_retired/p_asset_fin_rec.cost);  -- ENERGY
         else
             l_adj.adjustment_amount :=0;
         end if;
                                                                                             -- ENERGY
         if not FA_UTILS_PKG.faxrnd(l_adj.adjustment_amount,                                 -- ENERGY
                                    p_asset_hdr_rec.book_type_code,
                                    p_asset_hdr_rec.set_of_books_id,
                                    p_log_level_rec => p_log_level_rec) then                    -- ENERGY
            raise calc_err;                                                                  -- ENERGY
         end if;                                                                             -- ENERGY
      else                                                                                   -- ENERGY
         l_adj.adjustment_amount       := p_asset_retire_rec.cost_retired;
      end if;                                                                                -- ENERGY

      l_adj.track_member_flag       := 'Y';

      if (nvl(p_asset_retire_rec.cost_of_removal, 0) = 0) and
         (nvl(p_asset_retire_rec.proceeds_of_sale, 0) = 0) then
         l_adj.flush_adj_flag          := TRUE;
      end if;

--tk_util.DumpAdjRec(l_adj, 'RSVm');
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Retired Reserve', l_adj.adjustment_amount, p_log_level_rec => p_log_level_rec);
      end if;

      if not FA_INS_ADJUST_PKG.faxinaj
                            (l_adj,
                             p_trans_rec.who_info.last_update_date,
                             p_trans_rec.who_info.last_updated_by,
                             p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
        raise calc_err;
      end if;

      if (p_asset_fin_rec.tracking_method <>  'ALLOCATE') then

         if (nvl(p_asset_retire_rec.proceeds_of_sale, 0) <> 0) then
            l_adj.account_type            := 'DEPRN_RESERVE_ACCT';
            l_adj.account                 := fa_cache_pkg.fazccb_record.DEPRN_RESERVE_ACCT;
            l_adj.adjustment_amount       := p_asset_retire_rec.proceeds_of_sale;
            l_adj.track_member_flag       := 'Y';
            l_adj.flush_adj_flag          := FALSE;

--tk_util.DumpAdjRec(l_adj, 'RSVposm');

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Retired Reserve for Proceeds of Sale', l_adj.adjustment_amount, p_log_level_rec => p_log_level_rec);
            end if;

            if not FA_INS_ADJUST_PKG.faxinaj
                                  (l_adj,
                                   p_trans_rec.who_info.last_update_date,
                                   p_trans_rec.who_info.last_updated_by,
                                   p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
               raise calc_err;
            end if;
         end if; -- (nvl(p_asset_retire_rec.proceeds_of_sale, 0) <> 0)

         if (nvl(p_asset_retire_rec.cost_of_removal, 0) <> 0) then
            l_adj.account_type            := 'DEPRN_RESERVE_ACCT';
            l_adj.account                 := fa_cache_pkg.fazccb_record.DEPRN_RESERVE_ACCT;
            l_adj.adjustment_amount       := p_asset_retire_rec.cost_of_removal;
            l_adj.track_member_flag       := 'Y';
            l_adj.flush_adj_flag          := FALSE;

--tk_util.DumpAdjRec(l_adj, 'RSVcorm');

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Retired Reserve for Cost of Removal', l_adj.adjustment_amount, p_log_level_rec => p_log_level_rec);
            end if;

            if not FA_INS_ADJUST_PKG.faxinaj
                                  (l_adj,
                                   p_trans_rec.who_info.last_update_date,
                                   p_trans_rec.who_info.last_updated_by,
                                   p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
              raise calc_err;
            end if;
         end if;

         if (nvl(p_asset_retire_rec.cost_of_removal, 0) <> 0) then
            l_adj.adjustment_type         := 'REMOVALCOST CLR';
            l_adj.debit_credit_flag       := 'CR';
            l_adj.account_type            := 'COST_OF_REMOVAL_GAIN_ACCT';
            l_adj.account                 := fa_cache_pkg.fazcbc_record.cost_of_removal_gain_acct;
            l_adj.adjustment_amount       := p_asset_retire_rec.cost_of_removal;
            l_adj.flush_adj_flag          := FALSE;
            l_adj.track_member_flag       := 'Y';

--tk_util.DumpAdjRec(l_adj, 'Member COR');

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Cost of Removal for member asset', l_adj.adjustment_amount, p_log_level_rec => p_log_level_rec);
            end if;

            if not FA_INS_ADJUST_PKG.faxinaj
                                  (l_adj,
                                   p_trans_rec.who_info.last_update_date,
                                   p_trans_rec.who_info.last_updated_by,
                                   p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
               raise calc_err;
            end if;
         end if;

        --BUG5614568: modified the account_type,account and added the adjustment_amount.
        if (nvl(p_asset_retire_rec.proceeds_of_sale, 0) <> 0) then
           l_adj.adjustment_type         := 'PROCEEDS CLR';
           l_adj.debit_credit_flag       := 'DR';
           l_adj.account_type            := 'PROCEEDS_OF_SALE_CLEARING_ACCT';
           l_adj.account                 := fa_cache_pkg.fazcbc_record.proceeds_of_sale_clearing_acct;
           l_adj.adjustment_amount       := p_asset_retire_rec.proceeds_of_sale;
           l_adj.flush_adj_flag          := FALSE;
           l_adj.track_member_flag       := 'Y';

--tk_util.DumpAdjRec(l_adj, 'MemberPOS');

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Proceeds of Sale for member asset', l_adj.adjustment_amount, p_log_level_rec => p_log_level_rec);
            end if;

            if not FA_INS_ADJUST_PKG.faxinaj
                                  (l_adj,
                                   p_trans_rec.who_info.last_update_date,
                                   p_trans_rec.who_info.last_updated_by,
                                   p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
               raise calc_err;
            end if;
         end if;
      end if; -- ((p_asset_fin_rec.tracking_method <>  'ALLOCATE')

   end if; -- (p_asset_fin_rec.tracking_method = 'ALLOCATE') or
   -- End of Creating Member Entires for Tracking


  --***********************************************
  -- Prepare local variables with group information
  --
  l_asset_hdr_rec.asset_id := p_asset_fin_rec.group_asset_id;
  l_asset_hdr_rec.book_type_code := p_asset_hdr_rec.book_type_code;
  l_asset_hdr_rec.set_of_books_id := p_asset_hdr_rec.set_of_books_id;
  -- l_asset_hdr_rec.period_of_addition := 'N';  -- Set this if necessary

  if not FA_UTIL_PVT.get_asset_cat_rec (
                         p_asset_hdr_rec  => l_asset_hdr_rec,
                         px_asset_cat_rec => l_asset_cat_rec,
                         p_date_effective  => NULL, p_log_level_rec => p_log_level_rec) then
    raise calc_err;
  end if;

  --
  -- Set category book cache w/ group information.
  --
  if not fa_cache_pkg.fazccb(l_asset_hdr_rec.book_type_code,
                             l_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
    fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    raise calc_err;
  end if;

  l_adj.asset_id                := p_asset_fin_rec.group_asset_id;
  l_adj.transaction_header_id   := p_group_thid;
  l_adj.selection_mode          := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
  l_adj.distribution_id         := 0;

  l_adj.adjustment_type         := 'RESERVE';
  l_adj.debit_credit_flag       := 'DR';
  l_adj.account_type            := 'DEPRN_RESERVE_ACCT';
  l_adj.account                 := fa_cache_pkg.fazccb_record.DEPRN_RESERVE_ACCT;
  l_adj.adjustment_amount       := p_asset_retire_rec.cost_retired;
  l_adj.track_member_flag       := null;

  if (nvl(p_asset_retire_rec.cost_of_removal, 0) = 0) and
     (nvl(p_asset_retire_rec.proceeds_of_sale, 0) = 0) then
    l_adj.flush_adj_flag          := TRUE;
  end if;

--tk_util.DumpAdjRec(l_adj, 'RSV');
  if not FA_INS_ADJUST_PKG.faxinaj
                         (l_adj,
                          p_trans_rec.who_info.last_update_date,
                          p_trans_rec.who_info.last_updated_by,
                          p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
    raise calc_err;
  end if;

  --
  -- NBV RETIRED/RESERVE entries as a result of limiting net proceeds to cost retired
  --
  if (p_asset_fin_rec.limit_proceeds_flag = 'Y') then
     if (nvl(p_asset_retire_rec.proceeds_of_sale, 0) -
         nvl(p_asset_retire_rec.cost_of_removal, 0) > (p_asset_retire_rec.cost_retired -
                                                       p_salvage_value_retired)) then

        l_adj.adjustment_type   := 'RESERVE';
        l_adj.debit_credit_flag := 'DR';
        l_adj.account_type      := 'DEPRN_RESERVE_ACCT';
        l_adj.account           := fa_cache_pkg.fazccb_record.DEPRN_RESERVE_ACCT;
        l_adj.adjustment_amount := p_asset_retire_rec.detail_info.gain_loss_amount;

--tk_util.DumpAdjRec(l_adj, 'LNP RSV');
        if not FA_INS_ADJUST_PKG.faxinaj
                               (l_adj,
                                p_trans_rec.who_info.last_update_date,
                                p_trans_rec.who_info.last_updated_by,
                                p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
          raise calc_err;
        end if;


        l_adj.adjustment_type   := 'NBV RETIRED';
        l_adj.debit_credit_flag := 'CR';
        l_adj.account_type      := 'NBV_RETIRED_GAIN_ACCT';
        l_adj.account           := fa_cache_pkg.fazcbc_record.nbv_retired_gain_acct;
        l_adj.adjustment_amount := p_asset_retire_rec.detail_info.gain_loss_amount;

--tk_util.DumpAdjRec(l_adj, 'LNP NBVRET');
        if not FA_INS_ADJUST_PKG.faxinaj
                               (l_adj,
                                l_trans_rec.who_info.last_update_date,
                                l_trans_rec.who_info.last_updated_by,
                                l_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
           raise calc_err;
        end if;
     end if; -- nvl(p_asset_retire_rec.proceeds_of_sale, 0) -


  end if; -- (p_asset_fin_rec.limit_proceeds_flag = 'Y')

  --
  -- Create REMOVALCOST CLR and RESERVE entries
  --
  if (not(nvl(p_asset_retire_rec.cost_of_removal, 0) = 0)) then
    l_adj.adjustment_type   := 'RESERVE';
    l_adj.debit_credit_flag := 'DR';
    l_adj.account_type      := 'DEPRN_RESERVE_ACCT';
    l_adj.account           := fa_cache_pkg.fazccb_record.DEPRN_RESERVE_ACCT;
    l_adj.adjustment_amount       := p_asset_retire_rec.cost_of_removal;
--tk_util.DumpAdjRec(l_adj, 'COR');
    if not FA_INS_ADJUST_PKG.faxinaj
                           (l_adj,
                            p_trans_rec.who_info.last_update_date,
        --p_mode <> 'CR'                     p_trans_rec.who_info.last_updated_by,
                            p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
    end if;

    l_adj.asset_id                := p_asset_fin_rec.group_asset_id;
    l_adj.adjustment_type         := 'REMOVALCOST CLR';
    l_adj.debit_credit_flag       := 'CR';
    l_adj.account_type            := 'COST_OF_REMOVAL_GAIN_ACCT';
    l_adj.account                 := fa_cache_pkg.fazcbc_record.cost_of_removal_gain_acct;

    if (nvl(p_asset_retire_rec.proceeds_of_sale, 0) = 0) then
      l_adj.flush_adj_flag          := TRUE;
    end if;
--tk_util.DumpAdjRec(l_adj, 'COR');
    if not FA_INS_ADJUST_PKG.faxinaj
                           (l_adj,
                            p_trans_rec.who_info.last_update_date,
                            p_trans_rec.who_info.last_updated_by,
                            p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
    end if;

  end if;

  --
  -- Create PROCEEDS CLR and RESERVE entries
  --
  if (not(nvl(p_asset_retire_rec.proceeds_of_sale, 0) = 0)) then
    l_adj.adjustment_type         := 'RESERVE';
    l_adj.debit_credit_flag       := 'CR';
    l_adj.asset_id                := p_asset_fin_rec.group_asset_id;
    l_adj.account_type            := 'DEPRN_RESERVE_ACCT';
    l_adj.account                 := fa_cache_pkg.fazccb_record.DEPRN_RESERVE_ACCT;
    l_adj.adjustment_amount       := p_asset_retire_rec.proceeds_of_sale;

--tk_util.DumpAdjRec(l_adj, 'POS');
    if not FA_INS_ADJUST_PKG.faxinaj
                           (l_adj,
                            p_trans_rec.who_info.last_update_date,
                            p_trans_rec.who_info.last_updated_by,
                            p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
    end if;

    l_adj.adjustment_type         := 'PROCEEDS CLR';
    l_adj.debit_credit_flag       := 'DR';
    l_adj.asset_id                := p_asset_fin_rec.group_asset_id;
    --l_adj.account_type          := 'COST_OF_REMOVAL_GAIN_ACCT';  --bug 8580562
    --l_adj.account               := fa_cache_pkg.fazcbc_record.proceeds_of_sale_gain_acct;  --bug 8580562
    l_adj.account_type            := 'PROCEEDS_OF_SALE_CLEARING_ACCT';
    l_adj.account                 := fa_cache_pkg.fazcbc_record.proceeds_of_sale_clearing_acct;
    l_adj.flush_adj_flag          := TRUE;

--tk_util.DumpAdjRec(l_adj, 'POS');
    if not FA_INS_ADJUST_PKG.faxinaj
                           (l_adj,
                            p_trans_rec.who_info.last_update_date,
                            p_trans_rec.who_info.last_updated_by,
                            p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
    end if;

  end if; -- (not(nvl(p_asset_retire_rec.proceeds_of_sale, 0) = 0))

  --
  -- Calculating catchup only if tracking method is "CALCULATE".
  -- This is only necessary if this is prior period retirement.
  -- For now member asset prior period retirement is restricted.
  --
  if (p_asset_fin_rec.tracking_method = 'CALCULATE') and
     (p_period_rec.calendar_period_open_date >
      p_trans_rec.transaction_date_entered) then

     l_trans_rec := p_trans_rec;

     if not fa_util_pvt.get_asset_deprn_rec (
                p_asset_hdr_rec         => p_asset_hdr_rec,
                px_asset_deprn_rec      => l_asset_deprn_rec,
                p_mrc_sob_type_code     => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
        raise calc_err;
     end if;

     l_asset_fin_rec_adj.cost := -1 * p_asset_retire_rec.cost_retired;
     l_asset_fin_rec_adj.unrevalued_cost := -1 * p_asset_retire_rec.cost_retired;

     if not FA_AMORT_PVT.faxama(
                         px_trans_rec          => l_trans_rec,
                         p_asset_hdr_rec       => p_asset_hdr_rec,
                         p_asset_desc_rec      => p_asset_desc_rec,
                         p_asset_cat_rec       => p_asset_cat_rec,
                         p_asset_type_rec      => p_asset_type_rec,
                         p_asset_fin_rec_old   => p_asset_fin_rec,
                         p_asset_fin_rec_adj   => l_asset_fin_rec_adj,
                         px_asset_fin_rec_new  => l_asset_fin_rec_new,
                         p_asset_deprn_rec     => l_asset_deprn_rec,
                         p_period_rec          => p_period_rec,
                         p_mrc_sob_type_code   => p_mrc_sob_type_code,
                         p_running_mode        => fa_std_types.FA_DPR_NORMAL,
                         p_used_by_revaluation => null,
                         x_deprn_exp           => l_deprn_exp,
                         x_bonus_deprn_exp     => l_bonus_deprn_exp,
                         x_impairment_exp      => l_impairment_exp, p_log_level_rec => p_log_level_rec) then
        raise calc_err;
     end if;

     if (nvl(l_deprn_exp, 0) <> 0) or
        (nvl(l_bonus_deprn_exp, 0) <> 0) or
        (nvl(l_impairment_exp, 0) <> 0) then

        l_adj.transaction_header_id   := p_trans_rec.transaction_header_id;
        l_adj.book_type_code          := p_asset_hdr_rec.book_type_code;
        l_adj.period_counter_created  := p_period_rec.period_counter;
        l_adj.period_counter_adjusted := p_period_rec.period_counter;
        l_adj.current_units           := p_asset_desc_rec.current_units;
        l_adj.selection_retid         := 0;
        l_adj.leveling_flag           := TRUE;
        l_adj.last_update_date        := p_trans_rec.who_info.last_update_date;
        l_adj.gen_ccid_flag           := TRUE;
        l_adj.flush_adj_flag          := FALSE;

        if (nvl(l_deprn_exp, 0) <> 0) then
           -- Catchup expense for Member
           -- Call category book cache for group to get expense account
           if not fa_cache_pkg.fazccb
                  (X_book   => p_asset_hdr_rec.book_type_code,
                   X_cat_id => p_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
              raise calc_err;
           end if;

           l_adj.source_type_code        := 'DEPRECIATION';
           l_adj.adjustment_type         := 'EXPENSE';
           l_adj.account                 := fa_cache_pkg.fazccb_record.deprn_expense_acct;
           l_adj.account_type            := 'DEPRN_EXPENSE_ACCT';
           l_adj.asset_id                := p_asset_hdr_rec.asset_id;
           l_adj.adjustment_amount       := abs(l_deprn_exp);
           l_adj.selection_mode          := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
           l_adj.mrc_sob_type_code       :=  p_mrc_sob_type_code;
           l_adj.set_of_books_id         := p_asset_hdr_rec.set_of_books_id;

           if (nvl(p_asset_fin_rec.member_rollup_flag, 'N') = 'N') then
              l_adj.track_member_flag       := 'Y';
           else
              l_adj.track_member_flag       := null;
           end if;

           if (nvl(l_bonus_deprn_exp, 0) = 0) then
              l_adj.flush_adj_flag          := TRUE;
           end if;

           if (nvl(l_impairment_exp, 0) = 0) then
              l_adj.flush_adj_flag          := TRUE;
           end if;

           if (l_deprn_exp > 0) then
              l_adj.debit_credit_flag     := 'CR';
           else
              l_adj.debit_credit_flag     := 'DR';
           end if;

           if not FA_INS_ADJUST_PKG.faxinaj
                                (l_adj,
                                 p_trans_rec.who_info.last_update_date,
                                 p_trans_rec.who_info.last_updated_by,
                                 p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
              raise calc_err;
           end if;
        end if; --(nvl(l_deprn_exp, 0) <> 0)

        if (nvl(l_bonus_deprn_exp, 0) <> 0) then
           -- Catchup bonus expense for Member
           -- Need to call cache function if it is not called for expense.

           if (nvl(l_deprn_exp, 0) = 0) then

              if not fa_cache_pkg.fazccb(
                                 X_book   => p_asset_hdr_rec.book_type_code,
                                 X_cat_id => p_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
                 raise calc_err;
              end if;
           end if;

           l_adj.source_type_code        := 'DEPRECIATION';
           l_adj.adjustment_type         := 'BONUS EXPENSE';
           l_adj.account                 := fa_cache_pkg.fazccb_record.bonus_deprn_expense_acct;
           l_adj.account_type            := 'BONUS_DEPRN_EXPENSE_ACCT';
           l_adj.asset_id                := p_asset_hdr_rec.asset_id;
           l_adj.adjustment_amount       := abs(l_deprn_exp);
           l_adj.selection_mode          := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
           l_adj.mrc_sob_type_code       :=  p_mrc_sob_type_code;
           l_adj.set_of_books_id         := p_asset_hdr_rec.set_of_books_id;

           if (nvl(p_asset_fin_rec.member_rollup_flag, 'N') = 'N') then
              l_adj.track_member_flag       := 'Y';
           else
              l_adj.track_member_flag       := null;
           end if;
           l_adj.flush_adj_flag          := TRUE;

           if (l_deprn_exp > 0) then
              l_adj.debit_credit_flag     := 'CR';
           else
              l_adj.debit_credit_flag     := 'DR';
           end if;

           if not FA_INS_ADJUST_PKG.faxinaj
                                (l_adj,
                                 p_trans_rec.who_info.last_update_date,
                                 p_trans_rec.who_info.last_updated_by,
                                 p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
              raise calc_err;
           end if;
        end if; -- (nvl(l_bonus_deprn_exp, 0) <> 0)

        if (nvl(l_impairment_exp, 0) <> 0) then
           -- Catchup impairment expense for Member
           -- Need to call cache function if it is not called for expense.

           if (nvl(l_deprn_exp, 0) = 0) then

              if not fa_cache_pkg.fazccb(
                                 X_book   => p_asset_hdr_rec.book_type_code,
                                 X_cat_id => p_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
                 raise calc_err;
              end if;
           end if;

           l_adj.source_type_code        := 'DEPRECIATION';
           l_adj.adjustment_type         := 'IMPAIR EXPENSE';
           l_adj.account                 := fa_cache_pkg.fazccb_record.impair_expense_acct;
           l_adj.account_type            := 'IMPAIR_EXPENSE_ACCT';
           l_adj.asset_id                := p_asset_hdr_rec.asset_id;
           l_adj.adjustment_amount       := abs(l_impairment_exp);
           l_adj.selection_mode          := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
           l_adj.mrc_sob_type_code       :=  p_mrc_sob_type_code;
           l_adj.set_of_books_id         := p_asset_hdr_rec.set_of_books_id;

           if (nvl(p_asset_fin_rec.member_rollup_flag, 'N') = 'N') then
              l_adj.track_member_flag       := 'Y';
           else
              l_adj.track_member_flag       := null;
           end if;
           l_adj.flush_adj_flag          := TRUE;

           if (l_impairment_exp > 0) then
              l_adj.debit_credit_flag     := 'CR';
           else
              l_adj.debit_credit_flag     := 'DR';
           end if;

           if not FA_INS_ADJUST_PKG.faxinaj
                                (l_adj,
                                 p_trans_rec.who_info.last_update_date,
                                 p_trans_rec.who_info.last_updated_by,
                                 p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
              raise calc_err;
           end if;
        end if; -- (nvl(l_impairment_exp, 0) <> 0)

     end if; -- (nvl(l_deprn_exp, 0) <> 0) or

  end if; -- (p_asset_fin_rec.tracking_method = 'CALCULATE')

  end if; --p_mode <> 'CR'

  if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, 'End', 'Success', p_log_level_rec => p_log_level_rec);
  end if;

  return true;

EXCEPTION
  when calc_err then
    fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

    return false;

  when OTHERS then
    fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

    return false;

END CALC_GAIN_LOSS_FOR_RET;

/*====================================================================+
 | Function                                                           |
 |   CALC_GAIN_LOSS_FOR_REI                                           |
 |                                                                    |
 | Description                                                        |
 |   This function maintain FA_(MC_)ADJUSTMENTS table for group       |
 |   reinstatement.                                                   |
 |                                                                    |
 +====================================================================*/
FUNCTION CALC_GAIN_LOSS_FOR_REI(
           p_trans_rec         IN            FA_API_TYPES.trans_rec_type,
           p_asset_hdr_rec     IN            FA_API_TYPES.asset_hdr_rec_type,
           p_asset_type_rec    IN            FA_API_TYPES.asset_type_rec_type,
           p_asset_desc_rec    IN            FA_API_TYPES.asset_desc_rec_type,
           p_asset_cat_rec     IN            FA_API_TYPES.asset_cat_rec_type,
           p_asset_fin_rec     IN            FA_API_TYPES.asset_fin_rec_type,
           p_period_rec        IN            FA_API_TYPES.period_rec_type,
           p_asset_retire_rec  IN            FA_API_TYPES.asset_retire_rec_type,
           p_group_thid        IN            NUMBER,
           x_asset_fin_rec        OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
           p_mrc_sob_type_code IN            VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN IS

  l_calling_fn             VARCHAR2(100) := 'fa_group_retirement_pvt.calc_gain_loss_for_rei';

  -- Cursor to get transaction header id of transfer out in
  -- case of partial unit retirement
  CURSOR c_get_thid_for_dist IS
/*    select transaction_header_id_out
    from   fa_distribution_history
    where  asset_id = p_asset_hdr_rec.asset_id
    and    book_type_code = p_asset_hdr_rec.book_type_code
    and    retirement_id = p_asset_retire_rec.retirement_id;
bug 4411892*/
    select  transaction_header_id_out
    from    fa_retirements
    where   asset_id = p_asset_hdr_rec.asset_id
    and     retirement_id = p_asset_retire_rec.retirement_id
    and     book_type_code = p_asset_hdr_rec.book_type_code;

   /* Added for bug 8527733 */
   CURSOR c_get_ret_salvage IS
   select outbk.salvage_value - inbk.salvage_value
   from   fa_books inbk , fa_books outbk
   where  inbk.transaction_header_id_in = p_asset_retire_rec.detail_info.transaction_header_id_in
   and    outbk.asset_id = p_asset_hdr_rec.asset_id
   and    outbk.book_type_code = p_asset_hdr_rec.book_type_code
   and    outbk.transaction_header_id_out = p_asset_retire_rec.detail_info.transaction_header_id_in;

   CURSOR c_get_ret_salvage_mrc IS
   select outbk.salvage_value - inbk.salvage_value
   from   fa_mc_books inbk , fa_mc_books outbk
   where  inbk.transaction_header_id_in = p_asset_retire_rec.detail_info.transaction_header_id_in
   and    outbk.asset_id = p_asset_hdr_rec.asset_id
   and    outbk.book_type_code = p_asset_hdr_rec.book_type_code
   and    outbk.transaction_header_id_out = p_asset_retire_rec.detail_info.transaction_header_id_in
   and    inbk.set_of_books_id = p_asset_hdr_rec.set_of_books_id
   and    outbk.set_of_books_id = p_asset_hdr_rec.set_of_books_id ;
   /*End of bug 8527733 */


  CURSOR c_get_group_thid IS
    SELECT transaction_header_id,
           asset_id,
           date_effective
    FROM   fa_transaction_headers
    WHERE  member_transaction_header_id =
               p_asset_retire_rec.detail_info.transaction_header_id_in
    AND    asset_id = p_asset_fin_rec.group_asset_id
    AND    book_type_code = p_asset_hdr_rec.book_type_code;

  l_group_thid     NUMBER(15);
  l_group_asset_id NUMBER(15);
  l_date_effective DATE;
  l_period_rec     FA_API_TYPES.period_rec_type;

  -- BUG# 3031357
  -- adding additional columns to use N2 index for performance

  CURSOR c_mc_pos_cor_adj IS
  SELECT TRANSACTION_HEADER_ID,
         SOURCE_TYPE_CODE,
         ADJUSTMENT_TYPE,
         DEBIT_CREDIT_FLAG,
         CODE_COMBINATION_ID,
         BOOK_TYPE_CODE,
         ASSET_ID,
         ADJUSTMENT_AMOUNT,
         DISTRIBUTION_ID,
         ANNUALIZED_ADJUSTMENT,
         PERIOD_COUNTER_ADJUSTED,
         PERIOD_COUNTER_CREATED,
         ASSET_INVOICE_ID
  FROM   FA_MC_ADJUSTMENTS
  WHERE  TRANSACTION_HEADER_ID  = l_group_thid
  AND    ASSET_ID               = l_group_asset_id
  AND    BOOK_TYPE_CODE         = p_asset_hdr_rec.book_type_code
  AND    PERIOD_COUNTER_CREATED = l_period_rec.period_counter
  AND    ADJUSTMENT_TYPE in ('PROCEEDS CLR', 'REMOVALCOST CLR', 'NBV RETIRED')
  AND    set_of_books_id = p_asset_hdr_rec.set_of_books_id;

  CURSOR c_pos_cor_adj IS
  SELECT TRANSACTION_HEADER_ID,
         SOURCE_TYPE_CODE,
         ADJUSTMENT_TYPE,
         DEBIT_CREDIT_FLAG,
         CODE_COMBINATION_ID,
         BOOK_TYPE_CODE,
         ASSET_ID,
         ADJUSTMENT_AMOUNT,
         DISTRIBUTION_ID,
         ANNUALIZED_ADJUSTMENT,
         PERIOD_COUNTER_ADJUSTED,
         PERIOD_COUNTER_CREATED,
         ASSET_INVOICE_ID
  FROM   FA_ADJUSTMENTS
  WHERE  TRANSACTION_HEADER_ID  = l_group_thid
  AND    ASSET_ID               = l_group_asset_id
  AND    BOOK_TYPE_CODE         = p_asset_hdr_rec.book_type_code
  AND    PERIOD_COUNTER_CREATED = l_period_rec.period_counter
  AND    ADJUSTMENT_TYPE in ('PROCEEDS CLR', 'REMOVALCOST CLR', 'NBV RETIRED');

--kawa
--  CURSOR c_get_ret_reserve

  l_ret_period_counter     NUMBER := to_number(null);
  l_adj                    FA_ADJUST_TYPE_PKG.FA_ADJ_ROW_STRUCT;

  l_asset_hdr_rec   FA_API_TYPES.asset_hdr_rec_type;
  l_asset_cat_rec   FA_API_TYPES.asset_cat_rec_type;

  l_trans_rec         FA_API_TYPES.trans_rec_type;
  l_asset_fin_rec_adj FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_rec_new FA_API_TYPES.asset_fin_rec_type;
  l_asset_deprn_rec   FA_API_TYPES.asset_deprn_rec_type;

  l_deprn_exp         NUMBER;
  l_bonus_deprn_exp   NUMBER;
  l_impairment_exp    NUMBER;

  calc_err         EXCEPTION;


BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Begin', p_asset_hdr_rec.asset_id||':'||p_asset_fin_rec.group_asset_id, p_log_level_rec => p_log_level_rec);
   end if;

   -- BUG# 3641747
   -- call cache as it was not yet initialized
   if not fa_cache_pkg.fazccb(p_asset_hdr_rec.book_type_code,
                              p_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      raise calc_err;
   end if;

   --
   -- populate FA_ADJUST_TYPE_PKG.FA_ADJ_ROW_STRUCT(l_adj)to
   -- call FA_INS_ADJUST_PKG.faxinaj
   --
   l_adj.transaction_header_id   := p_trans_rec.transaction_header_id;
   l_adj.source_type_code        := 'RETIREMENT';
   l_adj.period_counter_created  := p_period_rec.period_counter;
   l_adj.period_counter_adjusted := p_period_rec.period_counter;
   l_adj.current_units           := p_asset_desc_rec.current_units;
   l_adj.book_type_code          := p_asset_hdr_rec.book_type_code;
   l_adj.selection_thid          := 0;
   l_adj.selection_retid         := 0;
   l_adj.leveling_flag           := TRUE;
   l_adj.last_update_date        := p_trans_rec.who_info.last_update_date;

   l_adj.flush_adj_flag          := FALSE;
   l_adj.gen_ccid_flag           := TRUE;

   l_adj.asset_id                := p_asset_hdr_rec.asset_id;

   l_adj.adjustment_type         := 'COST';
   l_adj.code_combination_id     := 0;
   l_adj.adjustment_amount       := p_asset_retire_rec.cost_retired;
   l_adj.mrc_sob_type_code       := p_mrc_sob_type_code;
   l_adj.set_of_books_id         := p_asset_hdr_rec.set_of_books_id;

   -- +++++ Process Cost entries +++++
   if p_asset_type_rec.asset_type = 'CIP' then
      l_adj.source_type_code := 'CIP RETIREMENT';
      l_adj.account          := fa_cache_pkg.fazccb_record.cip_cost_acct;
      l_adj.account_type     := 'CIP_COST_ACCT';
   else
      l_adj.source_type_code := 'RETIREMENT';
      l_adj.account          := fa_cache_pkg.fazccb_record.asset_cost_acct;
      l_adj.account_type     := 'ASSET_COST_ACCT';
   end if;

   if ((nvl(p_asset_retire_rec.units_retired, 0) > 0) and
       (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE')) and
      --(p_asset_desc_rec.current_units > p_asset_retire_rec.units_retired)
                (G_PART_RET_FLAG = TRUE) then
      OPEN c_get_thid_for_dist;
      FETCH c_get_thid_for_dist INTO l_adj.selection_thid;
      CLOSE c_get_thid_for_dist;

      if (nvl(l_adj.selection_thid, 0) = 0) then
         raise calc_err;
      end if;

      l_adj.selection_mode    := FA_STD_TYPES.FA_AJ_CLEAR;
      l_adj.debit_credit_flag := 'CR';
   else
      l_adj.debit_credit_flag := 'DR';
      l_adj.selection_thid    := 0;
      l_adj.selection_mode    := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
   end if;

--tk_util.DumpAdjRec(l_adj, l_adj.debit_credit_flag||':'||to_char(nvl(p_asset_retire_rec.units_retired, 0)));
   if not FA_INS_ADJUST_PKG.faxinaj
                         (l_adj,
                          p_trans_rec.who_info.last_update_date,
                          p_trans_rec.who_info.last_updated_by,
                          p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if ((nvl(p_asset_retire_rec.units_retired, 0) > 0) and
       (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE')) and
      --(p_asset_desc_rec.current_units > p_asset_retire_rec.units_retired)
                 (G_PART_RET_FLAG = TRUE) then

      --
      -- With unkonwn reason l_adj.account is set to null so
      -- need to resert the same value.
      --
      if p_asset_type_rec.asset_type = 'CIP' then
         l_adj.account := fa_cache_pkg.fazccb_record.cip_cost_acct;
      else
         l_adj.account := fa_cache_pkg.fazccb_record.asset_cost_acct;
      end if;

      l_adj.selection_thid    := 0;
      l_adj.selection_mode    := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
      l_adj.current_units     := p_asset_desc_rec.current_units;
      l_adj.debit_credit_flag := 'DR';
      l_adj.leveling_flag     := FALSE;
      l_adj.adjustment_amount := l_adj.amount_inserted +
                                p_asset_retire_rec.cost_retired;
--tk_util.DumpAdjRec(l_adj, 'URDR');
      if not FA_INS_ADJUST_PKG.faxinaj
                             (l_adj,
                              p_trans_rec.who_info.last_update_date,
                              p_trans_rec.who_info.last_updated_by,
                              p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
         raise calc_err;
      end if;

   end if; -- ((nvl(p_asset_retire_rec.units_retired, 0) > 0) and

-- ENERGY
   if (not fa_cache_pkg.fazccmt(p_asset_fin_rec.deprn_method_code,
                                p_asset_fin_rec.life_in_months, p_log_level_rec => p_log_level_rec)) then
      if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Error calling', 'fa_cache_pkg.fazccmt', p_log_level_rec => p_log_level_rec);
      end if;

      raise calc_err;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'tracking_method',
                       p_asset_fin_rec.tracking_method, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'rule_name',
                       fa_cache_pkg.fazcdrd_record.rule_name, p_log_level_rec => p_log_level_rec);
   end if;
   -- toru
   -- Energy: Need to reinstate member reserve entry cre
   -- BUG# 6899255
   -- handle all allocate cases the same  rather than just energy
   --  (fa_cache_pkg.fazcdrd_record.rule_name = 'ENERGY PERIOD END BALANCE')
   -- ENERGY

   if (nvl(p_asset_fin_rec.tracking_method, 'NO TRACK') = 'ALLOCATE') then
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'reserve retired',
                          p_asset_retire_rec.reserve_retired, p_log_level_rec => p_log_level_rec);
      end if;

  l_adj.selection_mode          := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
  l_adj.distribution_id         := 0;

  l_adj.adjustment_type         := 'RESERVE';
  l_adj.debit_credit_flag       := 'CR';
  l_adj.account_type            := 'DEPRN_RESERVE_ACCT';
  l_adj.account                 := fa_cache_pkg.fazccb_record.DEPRN_RESERVE_ACCT;
  l_adj.adjustment_amount       := p_asset_retire_rec.reserve_retired;
  l_adj.track_member_flag       := 'Y';

--tk_util.DumpAdjRec(l_adj, 'mRSV');
  if not FA_INS_ADJUST_PKG.faxinaj
                         (l_adj,
                          p_trans_rec.who_info.last_update_date,
                          p_trans_rec.who_info.last_updated_by,
                          p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
    raise calc_err;
  end if;

   end if; -- ENERGY

  --
  -- Process Reserve
  -- Prepare local variables with group information so category cache will
  -- hold group category.  This is because Reserve, POS, and COR entries are
  -- created with group info.
  --
  l_asset_hdr_rec.asset_id := p_asset_fin_rec.group_asset_id;
  l_asset_hdr_rec.book_type_code := p_asset_hdr_rec.book_type_code;
  l_asset_hdr_rec.set_of_books_id := p_asset_hdr_rec.set_of_books_id;
  -- l_asset_hdr_rec.period_of_addition := 'N';  -- Set this if necessary

  if not FA_UTIL_PVT.get_asset_cat_rec (
                         p_asset_hdr_rec  => l_asset_hdr_rec,
                         px_asset_cat_rec => l_asset_cat_rec,
                         p_date_effective  => NULL, p_log_level_rec => p_log_level_rec) then
    raise calc_err;
  end if;

  --
  -- Set category book cache w/ group information.
  --
  if not fa_cache_pkg.fazccb(l_asset_hdr_rec.book_type_code,
                             l_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
    fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    raise calc_err;
  end if;

  l_adj.asset_id                := p_asset_fin_rec.group_asset_id;
  l_adj.transaction_header_id   := p_group_thid;
  l_adj.selection_mode          := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
  l_adj.distribution_id         := 0;

  l_adj.adjustment_type         := 'RESERVE';
  l_adj.debit_credit_flag       := 'CR';
  l_adj.account_type            := 'DEPRN_RESERVE_ACCT';
  l_adj.account                 := fa_cache_pkg.fazccb_record.DEPRN_RESERVE_ACCT;
  l_adj.adjustment_amount       := p_asset_retire_rec.cost_retired;
  l_adj.track_member_flag       := null;

--tk_util.DumpAdjRec(l_adj, 'RSV');
  if not FA_INS_ADJUST_PKG.faxinaj
                         (l_adj,
                          p_trans_rec.who_info.last_update_date,
                          p_trans_rec.who_info.last_updated_by,
                          p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
    raise calc_err;
  end if;

  -- +++ Get Group's transaciton_header_id for retirement to be reinstated
  OPEN c_get_group_thid;
  FETCH c_get_group_thid INTO l_group_thid, l_group_asset_id, l_date_effective;
  CLOSE c_get_group_thid;

  if not FA_UTIL_PVT.get_period_rec(
                  p_book           => l_asset_hdr_rec.book_type_code,
                  p_effective_date => l_date_effective,
                  x_period_rec     => l_period_rec, p_log_level_rec => p_log_level_rec) then
     raise calc_err;
  end if;

  --
  -- Reinstate Proceeds of Sale and Cost of Removal and reserve entries for
  -- each of these.
  --
  if (p_mrc_sob_type_code <> 'R') then
     for r_pos_cor_adj in c_pos_cor_adj loop
        if (r_pos_cor_adj.debit_credit_flag = 'CR') then
           l_adj.debit_credit_flag   := 'DR';
        else
           l_adj.debit_credit_flag   := 'CR';
        end if;

        l_adj.adjustment_type     := r_pos_cor_adj.adjustment_type;
        l_adj.code_combination_id := r_pos_cor_adj.code_combination_id;
        l_adj.asset_id            := r_pos_cor_adj.asset_id;
        l_adj.adjustment_amount   := r_pos_cor_adj.adjustment_amount;
        l_adj.distribution_id     := r_pos_cor_adj.distribution_id;
--tk_util.DumpAdjRec(l_adj, r_pos_cor_adj.adjustment_type);
        if not FA_INS_ADJUST_PKG.faxinaj
                                 (l_adj,
                                  p_trans_rec.who_info.last_update_date,
                                  p_trans_rec.who_info.last_updated_by,
                                  p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
           raise calc_err;
        end if;

        --
        -- Set category book cache w/ group information.
        --
        if (l_asset_cat_rec.category_id is null) then
           if not fa_cache_pkg.fazccb(l_asset_hdr_rec.book_type_code,
                                      l_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
              fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
              raise calc_err;
           end if;
        end if;

        l_adj.asset_id                := p_asset_fin_rec.group_asset_id;
        l_adj.selection_mode          := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
        l_adj.distribution_id         := 0;
        l_adj.adjustment_type         := 'RESERVE';

        if (l_adj.debit_credit_flag = 'CR') then
           l_adj.debit_credit_flag       := 'DR';
        else
           l_adj.debit_credit_flag       := 'CR';
        end if;

        l_adj.account_type            := 'DEPRN_RESERVE_ACCT';
        l_adj.account                 := fa_cache_pkg.fazccb_record.DEPRN_RESERVE_ACCT;

--tk_util.DumpAdjRec(l_adj, 'RSV');
        if not FA_INS_ADJUST_PKG.faxinaj
                                      (l_adj,
                                       p_trans_rec.who_info.last_update_date,
                                       p_trans_rec.who_info.last_updated_by,
                                       p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
           raise calc_err;
        end if;

     end loop;
  else -- Reporting Book
     for r_pos_cor_adj in c_mc_pos_cor_adj loop
        if (r_pos_cor_adj.debit_credit_flag = 'CR') then
           l_adj.debit_credit_flag   := 'DR';
        else
           l_adj.debit_credit_flag   := 'CR';
        end if;

        l_adj.adjustment_type     := r_pos_cor_adj.adjustment_type;
        l_adj.code_combination_id := r_pos_cor_adj.code_combination_id;
        l_adj.asset_id            := r_pos_cor_adj.asset_id;
        l_adj.adjustment_amount   := r_pos_cor_adj.adjustment_amount;
        l_adj.distribution_id     := r_pos_cor_adj.distribution_id;

        if not FA_INS_ADJUST_PKG.faxinaj
                                 (l_adj,
                                  p_trans_rec.who_info.last_update_date,
                                  p_trans_rec.who_info.last_updated_by,
                                  p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
           raise calc_err;
        end if;

        --
        -- Set category book cache w/ group information.
        --
        if (l_asset_cat_rec.category_id is null) then
           if not fa_cache_pkg.fazccb(l_asset_hdr_rec.book_type_code,
                                      l_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
              fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
              raise calc_err;
           end if;
        end if;

        l_adj.asset_id                := p_asset_fin_rec.group_asset_id;
        l_adj.selection_mode          := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
        l_adj.distribution_id         := 0;
        l_adj.adjustment_type         := 'RESERVE';

        if (l_adj.debit_credit_flag = 'CR') then
           l_adj.debit_credit_flag       := 'DR';
        else
           l_adj.debit_credit_flag       := 'CR';
        end if;

        l_adj.account_type            := 'DEPRN_RESERVE_ACCT';
        l_adj.account                 := fa_cache_pkg.fazccb_record.DEPRN_RESERVE_ACCT;

--tk_util.DumpAdjRec(l_adj, 'RSV');
        if not FA_INS_ADJUST_PKG.faxinaj
                                      (l_adj,
                                       p_trans_rec.who_info.last_update_date,
                                       p_trans_rec.who_info.last_updated_by,
                                       p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
           raise calc_err;
        end if;

     end loop;

  end if; --(p_mrc_sob_type_code <> 'R')

  --
  -- Flash adjustments cache.
  --
  l_adj.flush_adj_flag          := TRUE;
  l_adj.transaction_header_id   := 0;
  l_adj.mrc_sob_type_code       :=  p_mrc_sob_type_code;
  l_adj.set_of_books_id         := p_asset_hdr_rec.set_of_books_id;


  if not FA_INS_ADJUST_PKG.faxinaj
                             (l_adj,
                              p_trans_rec.who_info.last_update_date,
                              p_trans_rec.who_info.last_updated_by,
                              p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
     raise calc_err;
  end if;

  l_trans_rec := p_trans_rec;

  if not fa_util_pvt.get_asset_deprn_rec (
                p_asset_hdr_rec         => p_asset_hdr_rec,
                px_asset_deprn_rec      => l_asset_deprn_rec,
                p_mrc_sob_type_code     => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
     raise calc_err;
  end if;

  l_asset_fin_rec_adj.cost := p_asset_retire_rec.cost_retired;
  l_asset_fin_rec_adj.unrevalued_cost := p_asset_retire_rec.cost_retired;
--tk_util.debug('recovering cost : '||to_char(l_asset_fin_rec_adj.cost));

  --Bug 8527733
  if (p_asset_fin_rec.salvage_type='AMT') then
     if (p_mrc_sob_type_code = 'R') then
        OPEN c_get_ret_salvage_mrc;
        FETCH c_get_ret_salvage_mrc
        INTO l_asset_fin_rec_adj.salvage_value;
        CLOSE c_get_ret_salvage_mrc;
     else
        OPEN c_get_ret_salvage;
        FETCH c_get_ret_salvage
        INTO l_asset_fin_rec_adj.salvage_value;
        CLOSE c_get_ret_salvage;
     end if;
  end if;

  if not FA_AMORT_PVT.faxama
                        (px_trans_rec          => l_trans_rec,
                         p_asset_hdr_rec       => p_asset_hdr_rec,
                         p_asset_desc_rec      => p_asset_desc_rec,
                         p_asset_cat_rec       => p_asset_cat_rec,
                         p_asset_type_rec      => p_asset_type_rec,
                         p_asset_fin_rec_old   => p_asset_fin_rec,
                         p_asset_fin_rec_adj   => l_asset_fin_rec_adj,
                         px_asset_fin_rec_new  => l_asset_fin_rec_new,
                         p_asset_deprn_rec     => l_asset_deprn_rec,
                         p_period_rec          => p_period_rec,
                         p_mrc_sob_type_code   => p_mrc_sob_type_code,
                         p_running_mode        => fa_std_types.FA_DPR_NORMAL,
                         p_used_by_revaluation => null,
                         x_deprn_exp           => l_deprn_exp,
                         x_bonus_deprn_exp     => l_bonus_deprn_exp,
                         x_impairment_exp      => l_impairment_exp, p_log_level_rec => p_log_level_rec) then
     raise calc_err;
  end if;

  x_asset_fin_rec := l_asset_fin_rec_new;
--tk_util.debug('new cost : '||to_char(x_asset_fin_rec.cost));
--tk_util.debug('new adj cost : '||to_char(x_asset_fin_rec.adjusted_cost));

  --
  -- Calculating catchup only if tracking method is "CALCULATE".
  -- This is only necessary if this is prior period retirement.
  -- For now member asset prior period retirement is restricted.
  --
  if (p_asset_fin_rec.tracking_method = 'CALCULATE') and
      (p_period_rec.calendar_period_open_date >
       p_trans_rec.transaction_date_entered) then


     if (nvl(l_deprn_exp, 0) <> 0) or
        (nvl(l_bonus_deprn_exp, 0) <> 0) or
        (nvl(l_impairment_exp, 0) <> 0) then

        l_adj.transaction_header_id   := p_trans_rec.transaction_header_id;
        l_adj.book_type_code          := p_asset_hdr_rec.book_type_code;
        l_adj.period_counter_created  := p_period_rec.period_counter;
        l_adj.period_counter_adjusted := p_period_rec.period_counter;
        l_adj.current_units           := p_asset_desc_rec.current_units;
        l_adj.selection_retid         := 0;
        l_adj.leveling_flag           := TRUE;
        l_adj.last_update_date        := p_trans_rec.who_info.last_update_date;
        l_adj.gen_ccid_flag           := TRUE;
        l_adj.flush_adj_flag          := FALSE;

        if (nvl(l_deprn_exp, 0) <> 0) then
           -- Catchup expense for Member
           -- Call category book cache for group to get expense account

           if not fa_cache_pkg.fazccb
                     (X_book   => p_asset_hdr_rec.book_type_code,
                      X_cat_id => p_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
              raise calc_err;
           end if;

           l_adj.source_type_code        := 'DEPRECIATION';
           l_adj.adjustment_type         := 'EXPENSE';
           l_adj.account                 := fa_cache_pkg.fazccb_record.deprn_expense_acct;
           l_adj.account_type            := 'DEPRN_EXPENSE_ACCT';
           l_adj.asset_id                := p_asset_hdr_rec.asset_id;
           l_adj.adjustment_amount       := abs(l_deprn_exp);
           l_adj.selection_mode          := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
           l_adj.mrc_sob_type_code       :=  p_mrc_sob_type_code;
           l_adj.set_of_books_id         := p_asset_hdr_rec.set_of_books_id;

           if (nvl(p_asset_fin_rec.member_rollup_flag, 'N') = 'N') then
              l_adj.track_member_flag       := 'Y';
           else
              l_adj.track_member_flag       := null;
           end if;

           if (nvl(l_bonus_deprn_exp, 0) = 0) then
              l_adj.flush_adj_flag          := TRUE;
           end if;

           if (nvl(l_impairment_exp, 0) = 0) then
              l_adj.flush_adj_flag          := TRUE;
           end if;

           if (l_deprn_exp > 0) then
              l_adj.debit_credit_flag     := 'CR';
           else
              l_adj.debit_credit_flag     := 'DR';
           end if;

           if not FA_INS_ADJUST_PKG.faxinaj
                                   (l_adj,
                                    p_trans_rec.who_info.last_update_date,
                                    p_trans_rec.who_info.last_updated_by,
                                    p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
              raise calc_err;
           end if;
        end if; --(nvl(l_deprn_exp, 0) <> 0)

        if (nvl(l_bonus_deprn_exp, 0) <> 0) then
           -- Catchup bonus expense for Member
           -- Need to call cache function if it is not called for expense.

           if (nvl(l_deprn_exp, 0) = 0) then
              if not fa_cache_pkg.fazccb
                      (X_book   => p_asset_hdr_rec.book_type_code,
                       X_cat_id => p_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
                 raise calc_err;
              end if;
           end if;

           l_adj.source_type_code        := 'DEPRECIATION';
           l_adj.adjustment_type         := 'BONUS EXPENSE';
           l_adj.account                 := fa_cache_pkg.fazccb_record.bonus_deprn_expense_acct;
           l_adj.account_type            := 'BONUS_DEPRN_EXPENSE_ACCT';
           l_adj.asset_id                := p_asset_hdr_rec.asset_id;
           l_adj.adjustment_amount       := abs(l_deprn_exp);
           l_adj.selection_mode          := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
           l_adj.mrc_sob_type_code       :=  p_mrc_sob_type_code;
           l_adj.set_of_books_id         := p_asset_hdr_rec.set_of_books_id;

           if (nvl(p_asset_fin_rec.member_rollup_flag, 'N') = 'N') then
              l_adj.track_member_flag       := 'Y';
           else
              l_adj.track_member_flag       := null;
           end if;
           l_adj.flush_adj_flag          := TRUE;

           if (l_deprn_exp > 0) then
              l_adj.debit_credit_flag     := 'CR';
           else
              l_adj.debit_credit_flag     := 'DR';
           end if;

           if not FA_INS_ADJUST_PKG.faxinaj
                                   (l_adj,
                                    p_trans_rec.who_info.last_update_date,
                                    p_trans_rec.who_info.last_updated_by,
                                    p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
              raise calc_err;
           end if;
        end if; -- (nvl(l_bonus_deprn_exp, 0) <> 0)

        if (nvl(l_impairment_exp, 0) <> 0) then
           -- Catchup impairment expense for Member
           -- Need to call cache function if it is not called for expense.

           if (nvl(l_deprn_exp, 0) = 0) then
              if not fa_cache_pkg.fazccb
                      (X_book   => p_asset_hdr_rec.book_type_code,
                       X_cat_id => p_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
                 raise calc_err;
              end if;
           end if;

           l_adj.source_type_code        := 'DEPRECIATION';
           l_adj.adjustment_type         := 'IMPAIR EXPENSE';
           l_adj.account                 := fa_cache_pkg.fazccb_record.impair_expense_acct;
           l_adj.account_type            := 'IMPAIR_EXPENSE_ACCT';
           l_adj.asset_id                := p_asset_hdr_rec.asset_id;
           l_adj.adjustment_amount       := abs(l_impairment_exp);
           l_adj.selection_mode          := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
           l_adj.mrc_sob_type_code       :=  p_mrc_sob_type_code;
           l_adj.set_of_books_id         := p_asset_hdr_rec.set_of_books_id;

           if (nvl(p_asset_fin_rec.member_rollup_flag, 'N') = 'N') then
              l_adj.track_member_flag       := 'Y';
           else
              l_adj.track_member_flag       := null;
           end if;
           l_adj.flush_adj_flag          := TRUE;

           if (l_impairment_exp > 0) then
              l_adj.debit_credit_flag     := 'CR';
           else
              l_adj.debit_credit_flag     := 'DR';
           end if;

           if not FA_INS_ADJUST_PKG.faxinaj
                                   (l_adj,
                                    p_trans_rec.who_info.last_update_date,
                                    p_trans_rec.who_info.last_updated_by,
                                    p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
              raise calc_err;
           end if;
        end if; -- (nvl(l_impairment_exp, 0) <> 0)

     end if; -- (nvl(l_deprn_exp, 0) <> 0) or

  end if; -- (p_asset_fin_rec.tracking_method = 'CALCULATE')

  if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, 'End', 'Success', p_log_level_rec => p_log_level_rec);
  end if;

  return true;

EXCEPTION
  when calc_err then
    fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

    return false;

  when OTHERS then
    fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

    return false;

END CALC_GAIN_LOSS_FOR_REI;

FUNCTION Do_Retirement_in_CGL(
                      p_ret                 IN fa_ret_types.ret_struct,
                      p_bk                  IN fa_ret_types.book_struct,
                      p_dpr                 IN fa_STD_TYPES.dpr_struct,
                      p_asset_deprn_rec_old IN FA_API_TYPES.asset_deprn_rec_type,
                      p_mrc_sob_type_code   IN VARCHAR2,
                      p_calling_fn          IN VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean IS

  CURSOR c_get_thid is
    select fa_transaction_headers_s.nextval
    from   dual;

  CURSOR c_get_thx is
    select trx.transaction_date_entered
         , trx.last_update_date
         , trx.last_updated_by
         , trx.last_update_login
         , trx.mass_transaction_id
         , trx.calling_interface
         , trx.mass_reference_id
         , nvl(trx.amortization_start_date, trx.transaction_date_entered)
         , trx.event_id
    from   fa_transaction_headers trx
    where  trx.transaction_header_id = p_ret.th_id_in;

  CURSOR c_member_exists IS
    select 'Y'
    from   fa_books
    where  book_type_code = p_ret.book
    and    group_asset_id = p_bk.group_asset_id
    and    ((period_counter_fully_retired is null)
        or  (period_counter_fully_retired is not null
         and retirement_pending_flag = 'YES'))
    and    transaction_header_id_out is null;

  CURSOR c_get_ret_info IS
    select -1 * eofy_reserve
    from   fa_retirements
    where retirement_id = p_ret.retirement_id;

  CURSOR c_get_mc_ret_info IS
    select -1 * eofy_reserve
    from   fa_mc_retirements
    where retirement_id = p_ret.retirement_id
    and set_of_books_id = p_ret.set_of_books_id;

  l_calling_fn            VARCHAR2(100) := 'fa_retirement_pvt.Do_Retirement_in_CGL';

  l_trans_rec             FA_API_TYPES.trans_rec_type;
  l_asset_hdr_rec         FA_API_TYPES.asset_hdr_rec_type;
  l_asset_hdr_rec_m       FA_API_TYPES.asset_hdr_rec_type;
  l_asset_desc_rec        FA_API_TYPES.asset_desc_rec_type;
  l_asset_type_rec        FA_API_TYPES.asset_type_rec_type;
  l_asset_cat_rec         FA_API_TYPES.asset_cat_rec_type;
  l_asset_fin_rec_new_m   FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_rec_old     FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_rec_adj     FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_rec_new     FA_API_TYPES.asset_fin_rec_type;
  l_inv_trans_rec         FA_API_TYPES.inv_trans_rec_type;
  l_asset_deprn_rec_adj   FA_API_TYPES.asset_deprn_rec_type;
  l_asset_deprn_rec_new   FA_API_TYPES.asset_deprn_rec_type;
  l_period_rec            FA_API_TYPES.period_rec_type;
  l_group_reclass_options_rec FA_API_TYPES.group_reclass_options_rec_type;

  l_member_exists         VARCHAR2(1) := 'N';
  l_deprn_reserve         NUMBER;
  l_temp_num              NUMBER;
  l_temp_char             VARCHAR2(30);
  l_temp_bool             BOOLEAN;

  l_new_reserve           NUMBER;
  l_new_rec_cost          NUMBER;
  l_recapture_amount      NUMBER;

  l_adj                    FA_ADJUST_TYPE_PKG.FA_ADJ_ROW_STRUCT;

  l_rowid                 ROWID; -- temp variable

  l_cost_sign             NUMBER; --Bug 8535921

  calc_err    EXCEPTION;

BEGIN
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Begin',
                       p_ret.asset_id||':'||p_bk.group_asset_id, p_log_level_rec => p_log_level_rec);
   end if;

   /* Added for bug 8535921 */
   if p_ret.cost_retired < 0 then
      l_cost_sign := -1;
   else
      l_cost_sign := 1;
   end if;
   /* End of bug 8535921 */

   --
   -- Prepare to call FA_ADJUSTMENT_PVT.do_adjustment to process group
   -- asset after member asset retirement.
   --
   if (p_mrc_sob_type_code <> 'R') then
      OPEN c_get_thid;
      FETCH c_get_thid INTO l_trans_rec.transaction_header_id;
      CLOSE c_get_thid;

      -- Bug 8674833: Save the grp_trx_hdr_id for mrc loop
      g_grp_trx_hdr_id := l_trans_rec.transaction_header_id;
   else
      -- Bug 8674833: Get the grp_trx_hdr_id from the global
      l_trans_rec.transaction_header_id := g_grp_trx_hdr_id;
   end if;

--tk_util.debug('l_trans_rec.transaction_header_id: '||to_char(l_trans_rec.transaction_header_id));

   l_trans_rec.transaction_type_code := 'GROUP ADJUSTMENT';
   l_trans_rec.transaction_subtype := 'AMORTIZED';
   l_trans_rec.member_transaction_header_id := p_ret.th_id_in;
   l_trans_rec.transaction_key := 'MR';

   OPEN c_get_thx;
   FETCH c_get_thx INTO l_trans_rec.transaction_date_entered
                      , l_trans_rec.who_info.last_update_date
                      , l_trans_rec.who_info.last_updated_by
                      , l_trans_rec.who_info.last_update_login
                      , l_trans_rec.mass_transaction_id
                      , l_trans_rec.calling_interface
                      , l_trans_rec.mass_reference_id
                      , l_trans_rec.amortization_start_date
                      , l_trans_rec.event_id;
   CLOSE c_get_thx;

   if (l_trans_rec.transaction_date_entered is null) then
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Looking for retirement transaction', 'FAILED', p_log_level_rec => p_log_level_rec);

      end if;

      raise calc_err;
   end if;
--tk_util.DumpTrxRec(l_trans_rec, 'trx');

   l_trans_rec.who_info.creation_date := l_trans_rec.who_info.last_update_date;
   l_trans_rec.who_info.created_by := l_trans_rec.who_info.last_updated_by;

   l_asset_hdr_rec.asset_id := p_bk.group_asset_id;
   l_asset_hdr_rec.book_type_code := p_ret.book;

   -- Bug 8674833 : Populate sob_id from p_ret populated in Do_Calc_GainLoss_Asset
   l_asset_hdr_rec.set_of_books_id := p_ret.set_of_books_id;

   if not FA_UTIL_PVT.get_asset_type_rec (
                   p_asset_hdr_rec      => l_asset_hdr_rec,
                   px_asset_type_rec    => l_asset_type_rec, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not FA_UTIL_PVT.get_asset_desc_rec (
                   p_asset_hdr_rec         => l_asset_hdr_rec,
                   px_asset_desc_rec       => l_asset_desc_rec, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not FA_UTIL_PVT.get_asset_cat_rec (
                   p_asset_hdr_rec         => l_asset_hdr_rec,
                   px_asset_cat_rec        => l_asset_cat_rec,
                   p_date_effective        => null, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not fa_util_pvt.get_asset_fin_rec (
                   p_asset_hdr_rec         => l_asset_hdr_rec,
                   px_asset_fin_rec        => l_asset_fin_rec_old,
                   p_mrc_sob_type_code     => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not FA_UTIL_PVT.get_period_rec(
                   p_book           => l_asset_hdr_rec.book_type_code,
                   x_period_rec     => l_period_rec, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

--tk_util.DumpFinRec(l_asset_fin_rec_old, 'OLD');

   if (l_asset_type_rec.asset_type = 'CIP') then
      l_asset_fin_rec_adj.cip_cost := -1 * p_ret.cost_retired;
   else
      l_asset_fin_rec_adj.cost := -1 * p_ret.cost_retired;
   end if;

   l_asset_fin_rec_adj.unrevalued_cost := -1 * p_ret.cost_retired;
   l_asset_fin_rec_adj.ytd_proceeds := p_ret.proceeds_of_sale;
   l_asset_fin_rec_adj.ltd_proceeds := p_ret.proceeds_of_sale;
   l_asset_fin_rec_adj.ltd_cost_of_removal := p_ret.cost_of_removal;

   --  This seems not necessary since the amount is in old_deprn_rec
   l_asset_deprn_rec_adj.deprn_reserve := -1 * p_ret.reserve_retired;

   if (p_mrc_sob_type_code = 'R') then
      OPEN c_get_mc_ret_info;
      FETCH c_get_mc_ret_info INTO  l_asset_fin_rec_adj.eofy_reserve;
      CLOSE c_get_mc_ret_info;
   else
      OPEN c_get_ret_info;
      FETCH c_get_ret_info INTO l_asset_fin_rec_adj.eofy_reserve;
      CLOSE c_get_ret_info;
   end if;

   l_asset_hdr_rec_m.asset_id := p_ret.asset_id;
   l_asset_hdr_rec_m.book_type_code := p_ret.book;

   -- Bug 8674833 : Populate sob_id from p_ret populated in Do_Calc_GainLoss_Asset
   l_asset_hdr_rec_m.set_of_books_id := p_ret.set_of_books_id;

   -- Get new member's fin_rec
   if not fa_util_pvt.get_asset_fin_rec (
                   p_asset_hdr_rec         => l_asset_hdr_rec_m,
                   px_asset_fin_rec        => l_asset_fin_rec_new_m,
                   p_mrc_sob_type_code     => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   l_asset_fin_rec_adj.salvage_value := nvl(l_asset_fin_rec_new_m.salvage_value, 0) -
                                        nvl(p_bk.salvage_value, 0);

   l_asset_fin_rec_adj.allowed_deprn_limit_amount :=
                                        nvl(l_asset_fin_rec_new_m.allowed_deprn_limit_amount, 0) -
                                        nvl(p_bk.allowed_deprn_limit_amount, 0);

   --
   -- Process Recapture Excess Reserve
   --
   if (nvl(p_bk.recapture_reserve_flag, 'N') = 'Y') then

      l_new_reserve := p_asset_deprn_rec_old.deprn_reserve -
                       p_ret.reserve_retired;

      l_new_rec_cost := l_asset_fin_rec_old.recoverable_cost -
                        (p_ret.cost_retired -
                         l_asset_fin_rec_adj.salvage_value);

       if (l_cost_sign*l_new_rec_cost < l_cost_sign*l_new_reserve) then --Bug 8535921
         l_adj.adjustment_amount := l_new_reserve - l_new_rec_cost;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Recapture Excess Reserve',
                             l_adj.adjustment_amount, p_log_level_rec => p_log_level_rec);
         end if;

         if l_asset_type_rec.asset_type = 'CIP' then
            l_adj.source_type_code := 'CIP RETIREMENT';
         else
            l_adj.source_type_code := 'RETIREMENT';
         end if;

         l_adj.asset_id                := l_asset_hdr_rec.asset_id;
         l_adj.transaction_header_id   := l_trans_rec.transaction_header_id;
         l_adj.book_type_code          := l_asset_hdr_rec.book_type_code;
         l_adj.period_counter_created  := l_period_rec.period_counter;
         l_adj.period_counter_adjusted := l_period_rec.period_counter;
         l_adj.current_units           := l_asset_desc_rec.current_units;
         l_adj.selection_retid         := 0;
         l_adj.selection_mode          := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
         l_adj.leveling_flag           := TRUE;
         l_adj.flush_adj_flag          := FALSE;
         l_adj.last_update_date        := l_trans_rec.who_info.last_update_date;
         l_adj.gen_ccid_flag           := TRUE;
         l_adj.adjustment_type         := 'RESERVE';
         l_adj.account_type            := 'DEPRN_RESERVE_ACCT';
         l_adj.debit_credit_flag       := 'DR';
         l_adj.mrc_sob_type_code       := p_mrc_sob_type_code;
         l_adj.set_of_books_id         := p_ret.set_of_books_id;

         if not fa_cache_pkg.fazccb(l_asset_hdr_rec.book_type_code,
                                    l_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
            fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            raise calc_err;
         end if;

         l_adj.account           := fa_cache_pkg.fazccb_record.DEPRN_RESERVE_ACCT;

         if not FA_INS_ADJUST_PKG.faxinaj
                            (l_adj,
                             l_trans_rec.who_info.last_update_date,
                             l_trans_rec.who_info.last_updated_by,
                             l_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
            raise calc_err;
         end if;

         l_adj.adjustment_type         := 'NBV RETIRED';
         l_adj.adjustment_amount       := l_new_reserve - l_new_rec_cost;
         l_adj.flush_adj_flag          := TRUE;

         l_adj.debit_credit_flag       := 'CR';
         l_adj.account_type            := 'NBV_RETIRED_GAIN_ACCT';
         l_adj.account                 := fa_cache_pkg.fazcbc_record.nbv_retired_gain_acct;

         if not FA_INS_ADJUST_PKG.faxinaj
                            (l_adj,
                             l_trans_rec.who_info.last_update_date,
                             l_trans_rec.who_info.last_updated_by,
                             l_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
            raise calc_err;
         end if;

         l_recapture_amount := l_new_reserve - l_new_rec_cost;

      else
         l_recapture_amount := 0;

      end if; -- (l_new_rec_cost < l_new_reserve)

   else

      l_recapture_amount := 0;

   end if; -- (nvl(p_bk.recapture_reserve_flag, 'N') = 'Y') and

   -- Bug 8674833 : Populate sob_id from p_ret
   FA_RETIREMENTS_PKG.Update_Row(
                              X_Rowid             => l_rowid,
                              X_Retirement_Id     => p_ret.retirement_id,
                              X_Recapture_Amount  => l_recapture_amount,
                              X_mrc_sob_type_code => p_mrc_sob_type_code,
                              X_set_of_books_id   => p_ret.set_of_books_id,
                              X_Calling_Fn        => l_calling_fn, p_log_level_rec => p_log_level_rec);


   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Process Non Member Rollup Group',
                       l_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
   end if;


   if (p_mrc_sob_type_code = 'R') then
      UPDATE FA_MC_ADJUSTMENTS
      SET    TRANSACTION_HEADER_ID = l_trans_rec.transaction_header_id
      WHERE  TRANSACTION_HEADER_ID = l_trans_rec.member_transaction_header_id
      AND    ASSET_ID = l_asset_hdr_rec.asset_id
      AND    BOOK_TYPE_CODE = l_asset_hdr_rec.book_type_code
      AND    SET_OF_BOOKS_ID = p_ret.set_of_books_id;
   else
      UPDATE FA_ADJUSTMENTS
      SET    TRANSACTION_HEADER_ID = l_trans_rec.transaction_header_id
      WHERE  TRANSACTION_HEADER_ID = l_trans_rec.member_transaction_header_id
      AND    ASSET_ID = l_asset_hdr_rec.asset_id
      AND    BOOK_TYPE_CODE = l_asset_hdr_rec.book_type_code;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Call FA_ADJUSTMENT_PVT.do_adjustment3',
                       'Begin',  p_log_level_rec => p_log_level_rec);
   end if;

   if not FA_ADJUSTMENT_PVT.do_adjustment
                  (px_trans_rec              => l_trans_rec,
                   px_asset_hdr_rec          => l_asset_hdr_rec,
                   p_asset_desc_rec          => l_asset_desc_rec,
                   p_asset_type_rec          => l_asset_type_rec,
                   p_asset_cat_rec           => l_asset_cat_rec,
                   p_asset_fin_rec_old       => l_asset_fin_rec_old,
                   p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
                   x_asset_fin_rec_new       => l_asset_fin_rec_new,
                   p_inv_trans_rec           => l_inv_trans_rec,
                   p_asset_deprn_rec_old     => p_asset_deprn_rec_old,
                   p_asset_deprn_rec_adj     => l_asset_deprn_rec_adj,
                   x_asset_deprn_rec_new     => l_asset_deprn_rec_new,
                   p_period_rec              => l_period_rec,
                   p_mrc_sob_type_code       => p_mrc_sob_type_code,
                   p_group_reclass_options_rec => l_group_reclass_options_rec,
                   p_calling_fn              => l_calling_fn, p_log_level_rec => p_log_level_rec)then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Call FA_ADJUSTMENT_PVT.do_adjustment',
                          'Failed',  p_log_level_rec => p_log_level_rec);
      end if;

      raise calc_err;

   end if;

   if (nvl(l_asset_fin_rec_old.member_rollup_flag, 'N') = 'Y') then
      --
      -- This is Sum up member depreciation to group asset
      --
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Process Member Rollup Group',
                          l_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
      end if;
   end if; -- (nvl(l_asset_fin_rec_old.member_rollup_flag, 'N') = 'N')

   if (nvl(l_asset_fin_rec_old.terminal_gain_loss, 'NO') <> 'NO' ) and
      (nvl(l_asset_fin_rec_new.cost, 0) = 0) then

      OPEN c_member_exists;
      FETCH c_member_exists INTO l_member_exists;
      CLOSE c_member_exists;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Is there a member asset',
                          l_member_exists, p_log_level_rec => p_log_level_rec);
      end if;

      if (nvl(l_member_exists, 'N') <> 'Y') then

         if (nvl(l_asset_fin_rec_old.terminal_gain_loss, 'NO') = 'END_OF_YEAR') then

            FA_BOOKS_PKG.Update_Row(
                   X_Book_Type_Code               => l_asset_hdr_rec.book_type_code,
                   X_Asset_Id                     => l_asset_hdr_rec.asset_id,
                   X_terminal_gain_loss_flag      => 'Y',
                   X_mrc_sob_type_code            => p_mrc_sob_type_code,
                   X_set_of_books_id              => p_ret.set_of_books_id,
                   X_Calling_Fn                   => l_calling_fn, p_log_level_rec => p_log_level_rec);

         else

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Call',
                                'fa_query_balances_pkg.query_balances', p_log_level_rec => p_log_level_rec);
            end if;

            fa_query_balances_pkg.query_balances(
                      X_asset_id => l_asset_hdr_rec.asset_id,
                      X_book => l_asset_hdr_rec.book_type_code,
                      X_period_ctr => 0,
                      X_dist_id => 0,
                      X_run_mode => 'STANDARD',
                      X_cost => l_temp_num,
                      X_deprn_rsv => l_deprn_reserve,
                      X_reval_rsv => l_temp_num,
                      X_ytd_deprn => l_temp_num,
                      X_ytd_reval_exp => l_temp_num,
                      X_reval_deprn_exp => l_temp_num,
                      X_deprn_exp => l_temp_num,
                      X_reval_amo => l_temp_num,
                      X_prod => l_temp_num,
                      X_ytd_prod => l_temp_num,
                      X_ltd_prod => l_temp_num,
                      X_adj_cost => l_temp_num,
                      X_reval_amo_basis => l_temp_num,
                      X_bonus_rate => l_temp_num,
                      X_deprn_source_code => l_temp_char,
                      X_adjusted_flag => l_temp_bool,
                      X_transaction_header_id => -1,
                      X_bonus_deprn_rsv => l_temp_num,
                      X_bonus_ytd_deprn => l_temp_num,
                      X_bonus_deprn_amount => l_temp_num,
                      X_impairment_rsv => l_temp_num,
                      X_ytd_impairment => l_temp_num,
                      X_impairment_amount => l_temp_num,
                      X_capital_adjustment => l_temp_num,
                      X_general_fund => l_temp_num,
                      X_mrc_sob_type_code => p_mrc_sob_type_code,
                      X_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                      p_log_level_rec => p_log_level_rec);

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'l_deprn_reserve',
                                l_deprn_reserve, p_log_level_rec => p_log_level_rec);
            end if;

            -- If remaining resrve is not 0, insert NBV RETIRED GAIN/LOSS,
            -- and RESERVE to fa_adjustments table.
            -- update terminal gain loss amount in fa_books
            if (nvl(l_deprn_reserve, 0) <> 0) then

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Create Terminal Gain/Loss entries',
                                   'Begin', p_log_level_rec => p_log_level_rec);
               end if;

               l_adj.asset_id                := l_asset_hdr_rec.asset_id;
               l_adj.transaction_header_id   := l_trans_rec.transaction_header_id;
               l_adj.book_type_code          := l_asset_hdr_rec.book_type_code;
               l_adj.period_counter_created  := l_period_rec.period_counter;
               l_adj.period_counter_adjusted := l_period_rec.period_counter;
               l_adj.current_units           := l_asset_desc_rec.current_units;
               l_adj.selection_retid         := 0;
               l_adj.leveling_flag           := TRUE;
               l_adj.flush_adj_flag          := FALSE;
               l_adj.last_update_date        := l_trans_rec.who_info.last_update_date;
               l_adj.gen_ccid_flag           := TRUE;
               l_adj.adjustment_type         := 'RESERVE';
               l_adj.account_type            := 'DEPRN_RESERVE_ACCT';
               l_adj.adjustment_amount       := l_deprn_reserve;
               l_adj.mrc_sob_type_code       := p_mrc_sob_type_code;
               l_adj.set_of_books_id         := p_ret.set_of_books_id;

               if (l_deprn_reserve > 0) then
                  l_adj.debit_credit_flag       := 'DR';
               else
                  l_adj.debit_credit_flag       := 'CR';
               end if;

               if not fa_cache_pkg.fazccb(l_asset_hdr_rec.book_type_code,
                                          l_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
                  fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                  raise calc_err;
               end if;

               l_adj.account           := fa_cache_pkg.fazccb_record.DEPRN_RESERVE_ACCT;

               if not FA_INS_ADJUST_PKG.faxinaj
                               (l_adj,
                                l_trans_rec.who_info.last_update_date,
                                l_trans_rec.who_info.last_updated_by,
                                l_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
                  raise calc_err;
               end if;

               l_adj.adjustment_type         := 'NBV RETIRED';
               l_adj.adjustment_amount := l_deprn_reserve;
               l_adj.flush_adj_flag          := TRUE;

               if (l_deprn_reserve > 0) then
                  l_adj.debit_credit_flag := 'CR';
                  l_adj.account_type      := 'NBV_RETIRED_GAIN_ACCT';
                  l_adj.account           := fa_cache_pkg.fazcbc_record.nbv_retired_gain_acct;
               else
                  l_adj.debit_credit_flag       := 'DR';
                  l_adj.debit_credit_flag := 'CR';
                  l_adj.account_type      := 'NBV_RETIRED_LOSS_ACCT';
                  l_adj.account           := fa_cache_pkg.fazcbc_record.nbv_retired_loss_acct;
               end if; -- (nvl(l_deprn_reserve, 0) <> 0)

               if not FA_INS_ADJUST_PKG.faxinaj
                               (l_adj,
                                l_trans_rec.who_info.last_update_date,
                                l_trans_rec.who_info.last_updated_by,
                                l_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
                  raise calc_err;
               end if;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Create Terminal Gain/Loss entries',
                                   'End', p_log_level_rec => p_log_level_rec);
               end if;

               FA_BOOKS_PKG.Update_Row(
                      X_Book_Type_Code            => l_asset_hdr_rec.book_type_code,
                      X_Asset_Id                  => l_asset_hdr_rec.asset_id,
                      X_terminal_gain_loss_amount => l_deprn_reserve,
                      X_mrc_sob_type_code         => p_mrc_sob_type_code,
                      X_set_of_books_id           => p_ret.set_of_books_id,
                      X_Calling_Fn                => l_calling_fn, p_log_level_rec => p_log_level_rec);

            end if;

         end if; -- (nvl(l_asset_fin_rec_old.terminal_gain_loss, 'NO') = 'END_OF_YEAR')

      end if; -- (nvl(l_member_exists, 'N') <> 'Y')

   end if; -- (nvl(l_asset_fin_rec_old.terminal_gain_loss, 'NO')  = 'YES') and

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'End', 'Success', p_log_level_rec => p_log_level_rec);
   end if;

   return TRUE;

EXCEPTION
   WHEN calc_err THEN
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

      return false;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

      return false;


END Do_Retirement_in_CGL;

FUNCTION Do_Reinstatement_in_CGL(
                      p_ret               IN fa_ret_types.ret_struct,
                      p_bk                IN fa_ret_types.book_struct,
                      p_dpr               IN fa_STD_TYPES.dpr_struct,
                      p_mrc_sob_type_code IN VARCHAR2,
                      p_calling_fn        IN VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean IS

  CURSOR c_get_thid is
    select fa_transaction_headers_s.nextval
    from   dual;

  CURSOR c_get_thx is
    select trx.transaction_header_id
         , trx.transaction_date_entered
         , trx.last_update_date
         , trx.last_updated_by
         , trx.last_update_login
         , trx.mass_transaction_id
         , trx.calling_interface
         , trx.mass_reference_id
         , nvl(trx.amortization_start_date, trx.transaction_date_entered)
         , event_id
    from   fa_retirements ret
       ,   fa_transaction_headers trx
    where  ret.retirement_id = p_ret.retirement_id
    and    ret.transaction_header_id_out = trx.transaction_header_id;


  --Bug8425794: finding reserve retired if fa_retirements doesn't have it.
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- gets reserve retired amounts if FA_RETIREMENTS doesn't store it
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  CURSOR c_get_rsv_retired (c_transaction_header_id number) IS
    select sum(decode(debit_credit_flag, 'CR', -1 * adjustment_amount,
                                                  adjustment_amount))
    from   fa_adjustments
    where  source_type_code = 'RETIREMENT'
    and    adjustment_type = 'RESERVE'
    and    asset_id = p_ret.asset_id
    and    book_type_code = p_ret.book
    and    transaction_header_id = c_transaction_header_id;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- For MRC
  -- gets reserve retired amounts if FA_RETIREMENTS doesn't store it
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  CURSOR c_get_mc_rsv_retired (c_transaction_header_id number) IS
    select sum(decode(debit_credit_flag, 'CR', -1 * adjustment_amount,
                                                  adjustment_amount))
    from   fa_mc_adjustments
    where  source_type_code = 'RETIREMENT'
    and    adjustment_type = 'RESERVE'
    and    asset_id = p_ret.asset_id
    and    book_type_code = p_ret.book
    and    transaction_header_id = c_transaction_header_id
    and    set_of_books_id = p_ret.set_of_books_id;

  l_calling_fn            VARCHAR2(100) := 'fa_retirement_pvt.Do_Reinstatement_in_CGL';

  l_trans_rec             FA_API_TYPES.trans_rec_type;
  l_asset_hdr_rec         FA_API_TYPES.asset_hdr_rec_type;
  l_asset_hdr_rec_m       FA_API_TYPES.asset_hdr_rec_type;
  l_asset_desc_rec        FA_API_TYPES.asset_desc_rec_type;
  l_asset_type_rec        FA_API_TYPES.asset_type_rec_type;
  l_asset_cat_rec         FA_API_TYPES.asset_cat_rec_type;
  l_asset_fin_rec_new_m   FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_rec_old     FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_rec_adj     FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_rec_new     FA_API_TYPES.asset_fin_rec_type;
  l_inv_trans_rec         FA_API_TYPES.inv_trans_rec_type;
  l_asset_deprn_rec_old   FA_API_TYPES.asset_deprn_rec_type;
  l_asset_deprn_rec_adj   FA_API_TYPES.asset_deprn_rec_type;
  l_asset_deprn_rec_new   FA_API_TYPES.asset_deprn_rec_type;
  l_period_rec            FA_API_TYPES.period_rec_type;
  l_group_reclass_options_rec FA_API_TYPES.group_reclass_options_rec_type;

  calc_err    EXCEPTION;

BEGIN
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Begin',
                       p_ret.asset_id||':'||p_bk.group_asset_id, p_log_level_rec => p_log_level_rec);
   end if;

   --
   -- Prepare to call FA_ADJUSTMENT_PVT.do_adjustment to process group
   -- asset after member asset retirement.
   --
   if (p_mrc_sob_type_code <> 'R') then
      OPEN c_get_thid;
      FETCH c_get_thid INTO l_trans_rec.transaction_header_id;
      CLOSE c_get_thid;

      -- Bug 8674833: Save the grp_trx_hdr_id for mrc loop
      g_grp_trx_hdr_id := l_trans_rec.transaction_header_id;
   else
      -- Bug 8674833: Get the grp_trx_hdr_id from the global
      l_trans_rec.transaction_header_id := g_grp_trx_hdr_id;
   end if;

   l_trans_rec.transaction_type_code := 'GROUP ADJUSTMENT';
   l_trans_rec.transaction_subtype := 'AMORTIZED';
   l_trans_rec.transaction_key := 'MS';

   OPEN c_get_thx;
   FETCH c_get_thx INTO l_trans_rec.member_transaction_header_id
                      , l_trans_rec.transaction_date_entered
                      , l_trans_rec.who_info.last_update_date
                      , l_trans_rec.who_info.last_updated_by
                      , l_trans_rec.who_info.last_update_login
                      , l_trans_rec.mass_transaction_id
                      , l_trans_rec.calling_interface
                      , l_trans_rec.mass_reference_id
                      , l_trans_rec.amortization_start_date
                      , l_trans_rec.event_id;
   CLOSE c_get_thx;

   if (l_trans_rec.transaction_date_entered is null) then
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Looking for retirement transaction', 'FAILED', p_log_level_rec => p_log_level_rec);

      end if;

      raise calc_err;
   end if;

   l_trans_rec.who_info.creation_date := l_trans_rec.who_info.last_update_date;
   l_trans_rec.who_info.created_by := l_trans_rec.who_info.last_updated_by;

   l_asset_hdr_rec.asset_id := p_bk.group_asset_id;
   l_asset_hdr_rec.book_type_code := p_ret.book;
   l_asset_hdr_rec.set_of_books_id := p_ret.set_of_books_id;

   if not FA_UTIL_PVT.get_asset_type_rec (
                   p_asset_hdr_rec      => l_asset_hdr_rec,
                   px_asset_type_rec    => l_asset_type_rec, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not FA_UTIL_PVT.get_asset_desc_rec (
                   p_asset_hdr_rec         => l_asset_hdr_rec,
                   px_asset_desc_rec       => l_asset_desc_rec, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not FA_UTIL_PVT.get_asset_cat_rec (
                   p_asset_hdr_rec         => l_asset_hdr_rec,
                   px_asset_cat_rec        => l_asset_cat_rec,
                   p_date_effective        => null, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not fa_util_pvt.get_asset_fin_rec (
                   p_asset_hdr_rec         => l_asset_hdr_rec,
                   px_asset_fin_rec        => l_asset_fin_rec_old,
                   p_mrc_sob_type_code     => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not FA_UTIL_PVT.get_period_rec(
                   p_book           => l_asset_hdr_rec.book_type_code,
                   x_period_rec     => l_period_rec, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

--tk_util.DumpFinRec(l_asset_fin_rec_old, 'OLD');

   if not fa_util_pvt.get_asset_deprn_rec (
                   p_asset_hdr_rec         => l_asset_hdr_rec,
                   px_asset_deprn_rec      => l_asset_deprn_rec_old,
                   p_mrc_sob_type_code     => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if (l_asset_type_rec.asset_type = 'CIP') then
      l_asset_fin_rec_adj.cip_cost := p_ret.cost_retired;
   else
      l_asset_fin_rec_adj.cost :=  p_ret.cost_retired;
   end if;

   l_asset_fin_rec_adj.unrevalued_cost := p_ret.cost_retired;
   l_asset_fin_rec_adj.ytd_proceeds := p_ret.proceeds_of_sale;
   l_asset_fin_rec_adj.ltd_proceeds := p_ret.proceeds_of_sale;
   l_asset_fin_rec_adj.ltd_cost_of_removal := p_ret.cost_of_removal;


   --Bug8425794: passing reserve to be reinstated
   --            Ideally the reserve retired is stored in fa_retirements but
   --            the may not be the case so fetching the value if it is null
  --l_asset_deprn_rec_adj.deprn_reserve := -1*p_ret.reserve_retired;

   if p_ret.reserve_retired is null then
      if (p_mrc_sob_type_code = 'R') then
         OPEN c_get_mc_rsv_retired (p_ret.th_id_in);
         FETCH c_get_mc_rsv_retired INTO l_asset_deprn_rec_adj.deprn_reserve;
         CLOSE c_get_mc_rsv_retired;
      else
         OPEN c_get_rsv_retired (p_ret.th_id_in);
         FETCH c_get_rsv_retired INTO l_asset_deprn_rec_adj.deprn_reserve;
         CLOSE c_get_rsv_retired;
      end if;
   end if;

   l_asset_hdr_rec_m.asset_id := p_ret.asset_id;
   l_asset_hdr_rec_m.book_type_code := p_ret.book;
   l_asset_hdr_rec_m.set_of_books_id := p_ret.set_of_books_id;

   -- Get new member's fin_rec
   if not fa_util_pvt.get_asset_fin_rec (
                   p_asset_hdr_rec         => l_asset_hdr_rec_m,
                   px_asset_fin_rec        => l_asset_fin_rec_new_m,
                   p_mrc_sob_type_code     => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   l_asset_fin_rec_adj.salvage_value := nvl(l_asset_fin_rec_new_m.salvage_value, 0) -
                                        nvl(p_bk.salvage_value, 0);

   l_asset_fin_rec_adj.allowed_deprn_limit_amount :=
                                        nvl(l_asset_fin_rec_new_m.allowed_deprn_limit_amount, 0) -
                                        nvl(p_bk.allowed_deprn_limit_amount, 0);

   UPDATE FA_ADJUSTMENTS
   SET TRANSACTION_HEADER_ID = l_trans_rec.transaction_header_id
   WHERE TRANSACTION_HEADER_ID = l_trans_rec.member_transaction_header_id
   AND   ASSET_ID = l_asset_hdr_rec.asset_id
   AND   BOOK_TYPE_CODE = l_asset_hdr_rec.book_type_code;

   /*8206076 -Start */
   if not((nvl(l_asset_fin_rec_old.tracking_method, 'NO TRACK') = 'ALLOCATE') and
       (fa_cache_pkg.fazcdrd_record.rule_name = 'ENERGY PERIOD END BALANCE')) then
               l_trans_rec.transaction_date_entered := p_ret.date_retired;
               l_trans_rec.amortization_start_date := p_ret.date_retired;
          if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'New transaction_date_entered',l_trans_rec.transaction_date_entered);
            fa_debug_pkg.add(l_calling_fn, 'New amortization_start_date',l_trans_rec.transaction_date_entered);
          end if;
   end if;
  /*8206076 -End */

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Call FA_ADJUSTMENT_PVT.do_adjustment4',
                       'Begin',  p_log_level_rec => p_log_level_rec);

   end if;

      if not FA_ADJUSTMENT_PVT.do_adjustment
                  (px_trans_rec              => l_trans_rec,
                   px_asset_hdr_rec          => l_asset_hdr_rec,
                   p_asset_desc_rec          => l_asset_desc_rec,
                   p_asset_type_rec          => l_asset_type_rec,
                   p_asset_cat_rec           => l_asset_cat_rec,
                   p_asset_fin_rec_old       => l_asset_fin_rec_old,
                   p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
                   x_asset_fin_rec_new       => l_asset_fin_rec_new,
                   p_inv_trans_rec           => l_inv_trans_rec,
                   p_asset_deprn_rec_old     => l_asset_deprn_rec_old,
                   p_asset_deprn_rec_adj     => l_asset_deprn_rec_adj,
                   x_asset_deprn_rec_new     => l_asset_deprn_rec_new,
                   p_period_rec              => l_period_rec,
                   p_mrc_sob_type_code       => p_mrc_sob_type_code,
                   p_group_reclass_options_rec => l_group_reclass_options_rec,
                   p_calling_fn              => l_calling_fn, p_log_level_rec => p_log_level_rec)then
         raise calc_err;
      end if;

   if (nvl(l_asset_fin_rec_old.member_rollup_flag, 'N') = 'Y') then
      --
      -- This is Sum up member depreciation to group asset
      --
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Process Member Rollup Group',
                          l_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
      end if;

      -- +++++ Remove group expense rows +++++
      DELETE FROM FA_ADJUSTMENTS
      WHERE  ASSET_ID = l_asset_hdr_rec.asset_id
      AND    BOOK_TYPE_CODE = l_asset_hdr_rec.book_type_code
      AND    TRANSACTION_HEADER_ID = l_trans_rec.member_transaction_header_id
      AND    SOURCE_TYPE_CODE = 'DEPRECIATION'
      AND    ADJUSTMENT_TYPE in ('EXPENSE', 'BONUS EXPENSE', 'IMPAIR EXPENSE');

   end if; -- (nvl(l_asset_fin_rec_old.member_rollup_flag, 'N') = 'N')

   -- +++++ Clear Terminal Gain Loss Amount +++++
   FA_BOOKS_PKG.Update_Row(
                   X_Book_Type_Code            => l_asset_hdr_rec.book_type_code,
                   X_Asset_Id                  => l_asset_hdr_rec.asset_id,
                   X_terminal_gain_loss_amount => FND_API.G_MISS_NUM,
                   X_mrc_sob_type_code         => p_mrc_sob_type_code,
                   X_set_of_books_id           => p_ret.set_of_books_id,
                   X_Calling_Fn                => l_calling_fn, p_log_level_rec => p_log_level_rec);
   return true;

EXCEPTION
   WHEN calc_err THEN
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

      return false;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

      return false;

END Do_Reinstatement_in_CGL;

FUNCTION Do_Terminal_Gain_Loss_All_Bk (
   p_book_type_code    VARCHAR2,
   p_asset_id          NUMBER,
   p_period_rec        FA_API_TYPES.period_rec_type,
   p_mrc_sob_type_code VARCHAR2,
   p_set_of_books_id   NUMBER,
   p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)RETURN BOOLEAN IS

   l_calling_fn VARCHAR2(50) := 'FA_RETIREMENT_PVT.Do_Terminal_Gain_Loss_All_Bk';

   cursor c_member_exists IS
     select 'Y'
     from   fa_books
     where  book_type_code = p_book_type_code
     and    group_asset_id = p_asset_id
     and    period_counter_fully_retired is null
     and    transaction_header_id_out is null;

   cursor c_max_ret_thid is
     select max(gth.transaction_header_id)
     from   fa_transaction_headers gth,
            fa_transaction_headers mth,
            fa_retirements ret,
            fa_books bk
     where  bk.group_asset_id = p_asset_id
     and    bk.book_type_code = p_book_type_code
     and    ret.asset_id = bk.asset_id
     and    ret.book_type_code = p_book_type_code
     and    mth.asset_id = bk.asset_id
     and    mth.book_type_code = p_book_type_code
     and    gth.asset_id = p_asset_id
     and    gth.book_type_code = p_book_type_code
     and    mth.transaction_type_code = 'FULL RETIREMENT'
     and    mth.transaction_header_id = gth.member_transaction_header_id;

   cursor c_mc_member_exists IS
     select 'Y'
     from   fa_mc_books
     where  book_type_code = p_book_type_code
     and    group_asset_id = p_asset_id
     and    period_counter_fully_retired is null
     and    transaction_header_id_out is null
     and    set_of_books_id = p_set_of_books_id;

   cursor c_max_mc_ret_thid is
     select max(gth.transaction_header_id)
     from   fa_transaction_headers gth,
            fa_transaction_headers mth,
            fa_mc_retirements ret,
            fa_mc_books bk
     where  bk.group_asset_id = p_asset_id
     and    bk.book_type_code = p_book_type_code
     and    bk.set_of_books_id = p_set_of_books_id
     and    ret.asset_id = bk.asset_id
     and    ret.book_type_code = p_book_type_code
     and    ret.set_of_books_id = p_set_of_books_id
     and    mth.asset_id = bk.asset_id
     and    mth.book_type_code = p_book_type_code
     and    gth.asset_id = p_asset_id
     and    gth.book_type_code = p_book_type_code
     and    mth.transaction_type_code = 'FULL RETIREMENT'
     and    mth.transaction_header_id = gth.member_transaction_header_id;

    -- +++++ Get Current Unit of Group Asset +++++
   cursor c_get_unit is
     select units,
            category_id
     from   fa_asset_history
     where  asset_id = p_asset_id
     and    transaction_header_id_out is null;

   l_adj                        fa_adjust_type_pkg.fa_adj_row_struct;
   l_asset_cat_rec              FA_API_TYPES.asset_cat_rec_type;

   l_member_exists              VARCHAR2(1) := 'N';
   l_deprn_reserve   NUMBER;
   l_last_update_date  DATE := sysdate;
   l_last_updated_by   NUMBER(15) := fnd_global.user_id;
   l_last_update_login NUMBER(15) := fnd_global.user_id;

  l_temp_num              NUMBER;
  l_temp_char             VARCHAR2(30);
  l_temp_bool             BOOLEAN;

   gl_err      EXCEPTION;

BEGIN

   if (p_mrc_sob_type_code = 'R') then
      OPEN c_mc_member_exists;
      FETCH c_mc_member_exists INTO l_member_exists;
      CLOSE c_mc_member_exists;
   else
      OPEN c_member_exists;
      FETCH c_member_exists INTO l_member_exists;
      CLOSE c_member_exists;
   end if;

   if (nvl(l_member_exists, 'N') = 'N' ) then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Call',
                          'fa_query_balances_pkg.query_balances', p_log_level_rec => p_log_level_rec);
      end if;

      fa_query_balances_pkg.query_balances(
                      X_asset_id => p_asset_id,
                      X_book => p_book_type_code,
                      X_period_ctr => 0,
                      X_dist_id => 0,
                      X_run_mode => 'STANDARD',
                      X_cost => l_temp_num,
                      X_deprn_rsv => l_deprn_reserve,
                      X_reval_rsv => l_temp_num,
                      X_ytd_deprn => l_temp_num,
                      X_ytd_reval_exp => l_temp_num,
                      X_reval_deprn_exp => l_temp_num,
                      X_deprn_exp => l_temp_num,
                      X_reval_amo => l_temp_num,
                      X_prod => l_temp_num,
                      X_ytd_prod => l_temp_num,
                      X_ltd_prod => l_temp_num,
                      X_adj_cost => l_temp_num,
                      X_reval_amo_basis => l_temp_num,
                      X_bonus_rate => l_temp_num,
                      X_deprn_source_code => l_temp_char,
                      X_adjusted_flag => l_temp_bool,
                      X_transaction_header_id => -1,
                      X_bonus_deprn_rsv => l_temp_num,
                      X_bonus_ytd_deprn => l_temp_num,
                      X_bonus_deprn_amount => l_temp_num,
                      X_impairment_rsv => l_temp_num,
                      X_ytd_impairment => l_temp_num,
                      X_impairment_amount => l_temp_num,
                      X_capital_adjustment => l_temp_num,
                      X_general_fund => l_temp_num,
                      X_mrc_sob_type_code => p_mrc_sob_type_code,
                      X_set_of_books_id => p_set_of_books_id,
                      p_log_level_rec => p_log_level_rec);

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Coming back from Query Balance',
                          l_deprn_reserve, p_log_level_rec => p_log_level_rec);
      end if;

      l_adj.asset_id                := p_asset_id;

      if (p_mrc_sob_type_code = 'R') then
         OPEN c_max_mc_ret_thid;
         FETCH c_max_mc_ret_thid INTO l_adj.transaction_header_id;
         CLOSE c_max_mc_ret_thid;
      else
         OPEN c_max_ret_thid;
         FETCH c_max_ret_thid INTO l_adj.transaction_header_id;
         CLOSE c_max_ret_thid;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Transaction_Header_Id for Terminal GL',
                          l_adj.transaction_header_id, p_log_level_rec => p_log_level_rec);
      end if;

      l_adj.book_type_code          := p_book_type_code;
      l_adj.period_counter_created  := p_period_rec.period_counter;
      l_adj.period_counter_adjusted := p_period_rec.period_counter;

      OPEN c_get_unit;
      FETCH c_get_unit INTO l_adj.current_units , l_asset_cat_rec.category_id;
      CLOSE c_get_unit;

      l_adj.selection_retid         := 0;
      l_adj.selection_mode          := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
      l_adj.leveling_flag           := TRUE;
      l_adj.flush_adj_flag          := FALSE;
      l_adj.last_update_date        := sysdate;
      l_adj.gen_ccid_flag           := TRUE;
      l_adj.adjustment_type         := 'RESERVE';
      l_adj.account_type            := 'DEPRN_RESERVE_ACCT';
      l_adj.adjustment_amount       := l_deprn_reserve;

      if (l_deprn_reserve > 0) then
         l_adj.debit_credit_flag    := 'DR';
      else
         l_adj.debit_credit_flag    := 'CR';
      end if;

      if not fa_cache_pkg.fazccb(p_book_type_code,
                                 l_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
         fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
         raise gl_err;
      end if;

      l_adj.account           := fa_cache_pkg.fazccb_record.DEPRN_RESERVE_ACCT;
      l_adj.mrc_sob_type_code := p_mrc_sob_type_code;
      l_adj.set_of_books_id   := p_set_of_books_id;

      if not FA_INS_ADJUST_PKG.faxinaj
                               (l_adj,
                                l_last_update_date,
                                l_last_updated_by,
                                l_last_update_login, p_log_level_rec => p_log_level_rec) then
         raise gl_err;
      end if;

      l_adj.adjustment_type      := 'NBV RETIRED';
      l_adj.adjustment_amount    := l_deprn_reserve;
      l_adj.flush_adj_flag       := TRUE;

      if (l_deprn_reserve > 0) then
         l_adj.debit_credit_flag := 'CR';
         l_adj.account_type      := 'NBV_RETIRED_GAIN_ACCT';
         l_adj.account           := fa_cache_pkg.fazcbc_record.nbv_retired_gain_acct;
      else
         l_adj.debit_credit_flag := 'CR';
         l_adj.account_type      := 'NBV_RETIRED_LOSS_ACCT';
         l_adj.account           := fa_cache_pkg.fazcbc_record.nbv_retired_loss_acct;
      end if;

      if not FA_INS_ADJUST_PKG.faxinaj
                               (l_adj,
                                l_last_update_date,
                                l_last_updated_by,
                                l_last_update_login, p_log_level_rec => p_log_level_rec) then

         raise gl_err;
      end if;

      FA_BOOKS_PKG.Update_Row(
                      X_Book_Type_Code               => p_book_type_code,
                      X_Asset_Id                     => p_asset_id,
                      X_terminal_gain_loss_amount    => l_deprn_reserve,
                      X_terminal_gain_loss_flag      => 'N',
                      X_mrc_sob_type_code            => p_mrc_sob_type_code,
                      X_set_of_books_id              => fa_cache_pkg.fazcbc_record.set_of_books_id,
                      X_Calling_Fn                   => l_calling_fn, p_log_level_rec => p_log_level_rec);

   else
      if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'There is at least non retired member exists',
                           p_asset_id, p_log_level_rec => p_log_level_rec);
      end if;
      --
      -- Must not calculate terminal gain loss as long as some
      -- non-retired member exists
      --
      FA_BOOKS_PKG.Update_Row(
                   X_Book_Type_Code               => p_book_type_code,
                   X_Asset_Id                     => p_asset_id,
                   X_terminal_gain_loss_flag      => FND_API.G_MISS_CHAR,
                   X_mrc_sob_type_code            => p_mrc_sob_type_code,
                   X_set_of_books_id              => fa_cache_pkg.fazcbc_record.set_of_books_id,
                   X_Calling_Fn                   => l_calling_fn, p_log_level_rec => p_log_level_rec);

   end if; -- (nvl(l_member_exists, 'N') = 'N' )

  return true;

EXCEPTION
   WHEN gl_err THEN
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

      return false;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

      return false;

END Do_Terminal_Gain_Loss_All_Bk;

FUNCTION Do_Terminal_Gain_Loss (
   p_book_type_code    VARCHAR2,
   p_set_of_books_id    NUMBER,
   p_total_requests     NUMBER,
   p_request_number     NUMBER,
   p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)RETURN BOOLEAN IS

   l_calling_fn VARCHAR2(50) := 'FA_RETIREMENT_PVT.Do_Terminal_Gain_Loss';

   l_period_rec    FA_API_TYPES.period_rec_type;

   cursor c_get_groups is
     select bk.asset_id asset_id
     from   fa_books bk,
            fa_additions ad
     where  bk.book_type_code = p_book_type_code
     and    bk.transaction_header_id_out is null
     and    bk.asset_id = ad.asset_id
     and    ad.asset_type = 'GROUP'
     and    bk.terminal_gain_loss = 'YES'
     and    bk.terminal_gain_loss_flag = 'Y'
     and    MOD(bk.asset_id, p_total_requests) = (p_request_number - 1);

   cursor c_get_eofy_groups is
     select bk.asset_id asset_id
     from   fa_books bk,
            fa_additions ad
     where  bk.book_type_code = p_book_type_code
     and    bk.transaction_header_id_out is null
     and    bk.asset_id = ad.asset_id
     and    ad.asset_type = 'GROUP'
     and    bk.terminal_gain_loss_flag = 'Y'
     and    MOD(bk.asset_id, p_total_requests) = (p_request_number - 1);

   l_sob_tbl                    FA_CACHE_PKG.fazcrsob_sob_tbl_type;

   TYPE tab_num15_type IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
   t_asset_id                   tab_num15_type;

   gl_err      EXCEPTION;

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Begin', p_book_type_code, p_log_level_rec => p_log_level_rec);
   end if;

   --+++++ Get Current Period Info +++++
   if not FA_UTIL_PVT.get_period_rec(
                   p_book           => p_book_type_code,
                   x_period_rec     => l_period_rec, p_log_level_rec => p_log_level_rec) then
      raise gl_err;
   end if;

   if not fa_cache_pkg.fazcct(fa_cache_pkg.fazcbc_record.deprn_calendar, p_log_level_rec => p_log_level_rec) then
      raise gl_err;
   end if;

   -- Process Terminal Gain Loss only if this is last period of
   -- the fiscal year.

   --+++++ Check to see if this is ast period of the fiscal year.
   if (fa_cache_pkg.fazcct_record.number_per_fiscal_year =
      l_period_rec.period_num) then

      OPEN c_get_eofy_groups;
   else
      OPEN c_get_groups;
   end if;

   LOOP -- loop for bulk fetch with limit

      if (fa_cache_pkg.fazcct_record.number_per_fiscal_year =
          l_period_rec.period_num) then

         FETCH c_get_eofy_groups BULK COLLECT INTO t_asset_id;
      else
         FETCH c_get_groups BULK COLLECT INTO t_asset_id;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Number of rows fetched',
                          to_char(t_asset_id.count));
      end if;

      EXIT WHEN t_asset_id.count = 0;

      for i IN 1..t_asset_id.count loop

         if not Do_Terminal_Gain_Loss_All_Bk (
                      p_book_type_code => p_book_type_code,
                      p_asset_id       => t_asset_id(i),
                      p_period_rec     => l_period_rec,
                      p_mrc_sob_type_code => 'P',
                      p_set_of_books_id => p_set_of_books_id,
                      p_log_level_rec     => p_log_level_rec) then
            raise gl_err;
         end if;

         if fa_cache_pkg.fazcbc_record.mc_source_flag = 'Y' then

            -- call the sob cache to get the table of sob_ids
            if not FA_CACHE_PKG.fazcrsob
                      (x_book_type_code => p_book_type_code,
                       x_sob_tbl        => l_sob_tbl, p_log_level_rec => p_log_level_rec) then
               raise gl_err;
            end if;

            for l_sob_index in 1..l_sob_tbl.count loop

               if p_log_level_rec.statement_level then
                  fa_debug_pkg.add (l_calling_fn, 'Reporting book loop: Set_of_books_id',
                                    l_sob_tbl(l_sob_index));
               end if;

               if not fa_cache_pkg.fazcbcs(x_book => p_book_type_code,
                                           x_set_of_books_id => p_set_of_books_id,
                                           p_log_level_rec => p_log_level_rec) then
                  raise gl_err;
               end if;

               if not Do_Terminal_Gain_Loss_All_Bk (
                             p_book_type_code => p_book_type_code,
                             p_asset_id       => t_asset_id(i),
                             p_period_rec     => l_period_rec,
                             p_mrc_sob_type_code => 'P',
                             p_set_of_books_id => p_set_of_books_id,
                             p_log_level_rec     => p_log_level_rec) then
                  raise gl_err;
               end if;

            end loop;
         end if; -- fa_cache_pkg.fazcbc_record.mc_source_flag = 'Y'

      end loop; -- for i IN 1..t_asset_id.count

   end loop; -- loop for bulk fetch with limit

   if (fa_cache_pkg.fazcct_record.number_per_fiscal_year =
       l_period_rec.period_num) then

      CLOSE c_get_eofy_groups;
   else
      CLOSE c_get_groups;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'End', p_book_type_code, p_log_level_rec => p_log_level_rec);
   end if;

   return true;

EXCEPTION
   WHEN gl_err THEN
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

      return false;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

      return false;

END Do_Terminal_Gain_Loss;

FUNCTION Check_Terminal_Gain_Loss(
                      p_trans_rec         IN     FA_API_TYPES.trans_rec_type,
                      p_asset_hdr_rec     IN     FA_API_TYPES.asset_hdr_rec_type,
                      p_asset_type_rec    IN     FA_API_TYPES.asset_type_rec_type,
                      p_asset_fin_rec     IN     FA_API_TYPES.asset_fin_rec_type,
                      p_period_rec        IN     FA_API_TYPES.period_rec_type,
                      p_mrc_sob_type_code IN     VARCHAR2,
                      p_calling_fn        IN     VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_calling_fn     VARCHAR2(50) := 'FA_RETIREMENT_PVT.Check_Terminal_Gain_Loss';

   --
   -- This cursor tries to find not full retired member of given group asset
   --  if there is any.
   --
   CURSOR c_find_member IS
      select asset_id
      from   fa_books
      where  group_asset_id = p_asset_hdr_rec.asset_id
      and    book_type_code = p_asset_hdr_rec.book_type_code
      and    period_counter_fully_retired is null
      and    transaction_header_id_out is null;

   CURSOR c_find_mc_member IS
      select asset_id
      from   fa_mc_books
      where  group_asset_id = p_asset_hdr_rec.asset_id
      and    book_type_code = p_asset_hdr_rec.book_type_code
      and    period_counter_fully_retired is null
      and    transaction_header_id_out is null
      and    set_of_books_id = p_asset_hdr_rec.set_of_books_id;


   l_asset_id       NUMBER;
   l_is_tgl_due     BOOLEAN := FALSE;

   -- query balance variables
   l_deprn_reserve         NUMBER;
   l_temp_num              NUMBER;
   l_temp_char             VARCHAR2(30);
   l_temp_bool             BOOLEAN;

   tgl_err   EXCEPTION;
BEGIN
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Begin', to_char(p_asset_hdr_rec.asset_id)||':'||
                                              p_asset_hdr_rec.book_type_code);
   end if;

   --
   -- Check to see the group asset is eligible for terminal gain loss
   --
   if (p_asset_fin_rec.cost = 0) and
      (p_asset_fin_rec.cip_cost =  0) and
      (p_asset_fin_rec.terminal_gain_loss in ('YES', 'END_OF_YEAR')) then

      if (p_mrc_sob_type_code = 'R') then

         OPEN c_find_mc_member;
         FETCH c_find_mc_member INTO l_asset_id;
         CLOSE c_find_mc_member;

      else

         OPEN c_find_member;
         FETCH c_find_member INTO l_asset_id;
         CLOSE c_find_member;

      end if;

      if (l_asset_id is not null) then

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Member exists', to_char(l_asset_id));
            fa_debug_pkg.add(l_calling_fn, 'End', 'No Terminal Gain Loss Calculatd', p_log_level_rec => p_log_level_rec);
         end if;

         return TRUE;

      end if;

      if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Continue', 'Checking remaining reserve ', p_log_level_rec => p_log_level_rec);
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Call',
                          'fa_query_balances_pkg.query_balances', p_log_level_rec => p_log_level_rec);
      end if;

      fa_query_balances_pkg.query_balances(
                      X_asset_id => p_asset_hdr_rec.asset_id,
                      X_book => p_asset_hdr_rec.book_type_code,
                      X_period_ctr => 0,
                      X_dist_id => 0,
                      X_run_mode => 'STANDARD',
                      X_cost => l_temp_num,
                      X_deprn_rsv => l_deprn_reserve,
                      X_reval_rsv => l_temp_num,
                      X_ytd_deprn => l_temp_num,
                      X_ytd_reval_exp => l_temp_num,
                      X_reval_deprn_exp => l_temp_num,
                      X_deprn_exp => l_temp_num,
                      X_reval_amo => l_temp_num,
                      X_prod => l_temp_num,
                      X_ytd_prod => l_temp_num,
                      X_ltd_prod => l_temp_num,
                      X_adj_cost => l_temp_num,
                      X_reval_amo_basis => l_temp_num,
                      X_bonus_rate => l_temp_num,
                      X_deprn_source_code => l_temp_char,
                      X_adjusted_flag => l_temp_bool,
                      X_transaction_header_id => -1,
                      X_bonus_deprn_rsv => l_temp_num,
                      X_bonus_ytd_deprn => l_temp_num,
                      X_bonus_deprn_amount => l_temp_num,
                      X_impairment_rsv => l_temp_num,
                      X_ytd_impairment => l_temp_num,
                      X_impairment_amount => l_temp_num,
                      X_capital_adjustment => l_temp_num,
                      X_general_fund => l_temp_num,
                      X_mrc_sob_type_code => p_mrc_sob_type_code,
                      X_set_of_books_id => p_asset_hdr_rec.set_of_books_id,
                      p_log_level_rec => p_log_level_rec);

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'l_deprn_reserve',
                          l_deprn_reserve, p_log_level_rec => p_log_level_rec);
      end if;

      if (nvl(l_deprn_reserve, 0) = 0) then

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Reserve is 0', 'No Terminal Gain Loss Calculatd', p_log_level_rec => p_log_level_rec);
         end if;

         return TRUE;

      end if;

      if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Continue', 'Eligible for Terminal Gain Loss', p_log_level_rec => p_log_level_rec);
      end if;

      --
      -- Setting TERMINAL_GAIN_LOSS_FLAG so terminal gain loss will be
      -- processed during depreciation
      --
      if (p_mrc_sob_type_code = 'R') then

         UPDATE FA_MC_BOOKS
         SET    TERMINAL_GAIN_LOSS_FLAG = 'Y'
         WHERE  ASSET_ID = p_asset_hdr_rec.asset_id
         AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
         AND    TRANSACTION_HEADER_ID_OUT is null
         AND    set_of_books_id = p_asset_hdr_rec.set_of_books_id;

         UPDATE FA_MC_BOOKS_SUMMARY
         SET    TERMINAL_GAIN_LOSS_FLAG = 'Y'
         WHERE  ASSET_ID = p_asset_hdr_rec.asset_id
         AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
         AND    PERIOD_COUNTER = p_period_rec.period_counter
         AND    set_of_books_id = p_asset_hdr_rec.set_of_books_id;

      else

         UPDATE FA_BOOKS
         SET    TERMINAL_GAIN_LOSS_FLAG = 'Y'
         WHERE  ASSET_ID = p_asset_hdr_rec.asset_id
         AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
         AND    TRANSACTION_HEADER_ID_OUT is null;

         UPDATE FA_BOOKS_SUMMARY
         SET    TERMINAL_GAIN_LOSS_FLAG = 'Y'
         WHERE  ASSET_ID = p_asset_hdr_rec.asset_id
         AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
         AND    PERIOD_COUNTER = p_period_rec.period_counter;

      end if;

   end if; -- (p_asset_fin_rec.cost = 0) and


   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'l_is_tgl_due', l_is_tgl_due, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'End', 'SUCCESS', p_log_level_rec => p_log_level_rec);
   end if;

   return TRUE;

EXCEPTION
   WHEN tgl_err THEN
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'End', FALSE, p_log_level_rec => p_log_level_rec);
      end if;

      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

   WHEN OTHERS THEN
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'End', FALSE, p_log_level_rec => p_log_level_rec);
      end if;

      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

END Check_Terminal_Gain_Loss;

FUNCTION Do_Allocation(
                      p_trans_rec         IN     FA_API_TYPES.trans_rec_type,
                      p_asset_hdr_rec     IN     FA_API_TYPES.asset_hdr_rec_type,
                      p_asset_fin_rec     IN     FA_API_TYPES.asset_fin_rec_type,
                      p_asset_deprn_rec_new IN   FA_API_TYPES.asset_deprn_rec_type,
                      p_period_rec        IN     FA_API_TYPES.period_rec_type,
                      p_reserve_amount    IN     NUMBER,
                      p_mem_ret_thid      IN     NUMBER  DEFAULT NULL,
                      p_mode              IN     VARCHAR2 DEFAULT 'NORMAL',
                      p_mrc_sob_type_code IN     VARCHAR2,
                      p_calling_fn        IN     VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN IS

   l_calling_fn varchar2(40) := 'FA_RETIREMENT_PVT.Do_Allocation';
   /* bug 8633654 starts*/
   h_rein_mem_asset_id number;
   l_ind number;
   bln_rein_mem_reqd boolean := FALSE;
   bln_other_mem_exists boolean := FALSE;
   bln_use_cur_asset    boolean := TRUE;
   l_rein_mem_deprn_resv fa_books.adjusted_cost%type;
   l_rein_mem_adj_cost fa_books.adjusted_cost%type;


   CURSOR c_reins_mem_details IS
      SELECT BK.ASSET_ID                  ASSET_ID
           , BK.TRANSACTION_HEADER_ID_IN  TRANSACTION_HEADER_ID_IN
           , BK.RATE_ADJUSTMENT_FACTOR    RATE_ADJUSTMENT_FACTOR
           , BK.ADJUSTED_COST             ADJUSTED_COST
           , BK.RECOVERABLE_COST          RECOVERABLE_COST
      FROM   FA_BOOKS BK
           , FA_ADDITIONS_B AD
           , fa_transaction_headers th
      WHERE  BK.BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
      AND    BK.TRANSACTION_HEADER_ID_OUT is null
      AND    BK.GROUP_ASSET_ID = p_asset_hdr_rec.asset_id
      AND    nvl(BK.CIP_COST, 0) = 0
      AND    BK.ASSET_ID = th.asset_id
      AND    th.transaction_header_id = p_mem_ret_thid
      AND    AD.ASSET_TYPE = 'CAPITALIZED';

   CURSOR c_mc_reins_mem_details IS
      SELECT BK.ASSET_ID                  ASSET_ID
           , BK.TRANSACTION_HEADER_ID_IN  TRANSACTION_HEADER_ID_IN
           , BK.RATE_ADJUSTMENT_FACTOR    RATE_ADJUSTMENT_FACTOR
           , BK.ADJUSTED_COST             ADJUSTED_COST
           , BK.RECOVERABLE_COST          RECOVERABLE_COST
      FROM   FA_MC_BOOKS BK
           , FA_ADDITIONS_B AD
           , fa_transaction_headers th
      WHERE  BK.BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
      AND    BK.TRANSACTION_HEADER_ID_OUT is null
      AND    BK.GROUP_ASSET_ID = p_asset_hdr_rec.asset_id
      AND    nvl(BK.CIP_COST, 0) = 0
      AND    BK.ASSET_ID = th.asset_id
      AND    th.transaction_header_id = p_mem_ret_thid
      AND    AD.ASSET_TYPE = 'CAPITALIZED'
      AND    BK.SET_OF_BOOKS_ID = p_asset_hdr_rec.set_of_books_id;

   l_reins_mem_details c_reins_mem_details%rowtype;

   /* bug 8633654 ends*/

   CURSOR C_GET_SUM_REC_COST IS
      SELECT SUM(RECOVERABLE_COST)
      FROM   FA_BOOKS
      WHERE  BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
      AND    TRANSACTION_HEADER_ID_OUT is null
      AND    PERIOD_COUNTER_FULLY_RESERVED is null
      AND    PERIOD_COUNTER_FULLY_RETIRED is null
      AND    nvl(CIP_COST, 0) = 0
      AND    GROUP_ASSET_ID = p_asset_hdr_rec.asset_id;


   CURSOR C_MC_GET_SUM_REC_COST IS
      SELECT SUM(RECOVERABLE_COST)
      FROM   FA_MC_BOOKS
      WHERE  BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
      AND    TRANSACTION_HEADER_ID_OUT is null
      AND    PERIOD_COUNTER_FULLY_RESERVED is null
      AND    PERIOD_COUNTER_FULLY_RETIRED is null
      AND    nvl(CIP_COST, 0) = 0
      AND    GROUP_ASSET_ID = p_asset_hdr_rec.asset_id
      AND    set_of_books_id = p_asset_hdr_rec.set_of_books_id;

   CURSOR C_GET_BS_SUM_ADJ_COST IS
      SELECT SUM(ADJUSTED_COST)
      FROM   FA_BOOKS_SUMMARY
      WHERE  BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
      AND    TRANSACTION_HEADER_ID_OUT is null
      AND    nvl(FULLY_RESERVED_FLAG, 'N') = 'N'
      AND    nvl(FULLY_RETIRED_FLAG, 'N') = 'N'
      AND    GROUP_ASSET_ID = p_asset_hdr_rec.asset_id
      AND    nvl(CIP_COST, 0) = 0
      AND    PERIOD_COUNTER = p_period_rec.period_counter;

   CURSOR C_MC_GET_BS_SUM_ADJ_COST IS
      SELECT SUM(ADJUSTED_COST)
      FROM   FA_MC_BOOKS_SUMMARY
      WHERE  BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
      AND    TRANSACTION_HEADER_ID_OUT is null
      AND    nvl(FULLY_RESERVED_FLAG, 'N') = 'N'
      AND    nvl(FULLY_RETIRED_FLAG, 'N') = 'N'
      AND    GROUP_ASSET_ID = p_asset_hdr_rec.asset_id
      AND    nvl(CIP_COST, 0) = 0
      AND    PERIOD_COUNTER = p_period_rec.period_counter
      AND    set_of_books_id = p_asset_hdr_rec.set_of_books_id;

   CURSOR C_GET_GROUP_RSV_RET IS
      SELECT sum(decode(AJ.DEBIT_CREDIT_FLAG, 'CR', -1, 1)*AJ.ADJUSTMENT_AMOUNT)
      FROM   FA_ADJUSTMENTS AJ
      WHERE  AJ.ASSET_ID = p_asset_hdr_rec.asset_id
      AND    AJ.BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
      AND    AJ.TRANSACTION_HEADER_ID = p_trans_rec.transaction_header_id;

   CURSOR C_MC_GET_GROUP_RSV_RET IS
      SELECT sum(decode(AJ.DEBIT_CREDIT_FLAG, 'CR', -1, 1)*AJ.ADJUSTMENT_AMOUNT)
      FROM   FA_ADJUSTMENTS AJ
      WHERE  AJ.ASSET_ID = p_asset_hdr_rec.asset_id
      AND    AJ.BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
      AND    AJ.TRANSACTION_HEADER_ID = p_trans_rec.transaction_header_id;


   CURSOR C_GET_MEMBER_ASSETS IS
      SELECT BK.ASSET_ID                  ASSET_ID
           , BK.TRANSACTION_HEADER_ID_IN  TRANSACTION_HEADER_ID_IN
           , BK.RATE_ADJUSTMENT_FACTOR    RATE_ADJUSTMENT_FACTOR
           , BK.ADJUSTED_COST             ADJUSTED_COST
           , BK.CAPITALIZE_FLAG           CAPITALIZE_FLAG
           , BK.RECOVERABLE_COST          RECOVERABLE_COST
           , BK.ADJUSTED_RECOVERABLE_COST ADJUSTED_RECOVERABLE_COST
           , AD.ASSET_CATEGORY_ID         ASSET_CATEGORY_ID
           , AD.CURRENT_UNITS             CURRENT_UNITS
           , 'NO' REINS_ASSET_FLAG
      FROM   FA_BOOKS BK
           , FA_ADDITIONS_B AD
      WHERE  BK.BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
      AND    BK.TRANSACTION_HEADER_ID_OUT is null
      AND    BK.GROUP_ASSET_ID = p_asset_hdr_rec.asset_id
      AND    nvl(BK.CIP_COST, 0) = 0
      AND    BK.PERIOD_COUNTER_FULLY_RESERVED is null
      AND    BK.PERIOD_COUNTER_FULLY_RETIRED is null
      AND    BK.ASSET_ID = AD.ASSET_ID
      AND    BK.ASSET_ID <> decode(p_mode,'RECURR',nvl(h_rein_mem_asset_id,-1),-1)
      AND    AD.ASSET_TYPE = 'CAPITALIZED'
      UNION ALL
      SELECT BK.ASSET_ID                  ASSET_ID
           , BK.TRANSACTION_HEADER_ID_IN  TRANSACTION_HEADER_ID_IN
           , BK.RATE_ADJUSTMENT_FACTOR    RATE_ADJUSTMENT_FACTOR
           , BK.ADJUSTED_COST             ADJUSTED_COST
           , BK.CAPITALIZE_FLAG           CAPITALIZE_FLAG
           , BK.RECOVERABLE_COST          RECOVERABLE_COST
           , BK.ADJUSTED_RECOVERABLE_COST ADJUSTED_RECOVERABLE_COST
           , AD.ASSET_CATEGORY_ID         ASSET_CATEGORY_ID
           , AD.CURRENT_UNITS             CURRENT_UNITS
           , 'YES' REINS_ASSET_FLAG
      FROM   FA_BOOKS BK
           , FA_ADDITIONS_B AD
      WHERE  BK.BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
      AND    BK.TRANSACTION_HEADER_ID_OUT is null
      AND    BK.GROUP_ASSET_ID = p_asset_hdr_rec.asset_id
      AND    nvl(BK.CIP_COST, 0) = 0
      AND    BK.ASSET_ID = AD.ASSET_ID
      AND    BK.ASSET_ID = decode(p_mode,'RECURR',nvl(h_rein_mem_asset_id,-1),-1)
      AND    AD.ASSET_TYPE = 'CAPITALIZED'
      order by 10,1; --Please never change this Order By clause. If changed will cause huge corruption.


   CURSOR C_MC_GET_MEMBER_ASSETS IS
      SELECT BK.ASSET_ID                  ASSET_ID
           , BK.TRANSACTION_HEADER_ID_IN  TRANSACTION_HEADER_ID_IN
           , BK.RATE_ADJUSTMENT_FACTOR    RATE_ADJUSTMENT_FACTOR
           , BK.ADJUSTED_COST             ADJUSTED_COST
           , BK.CAPITALIZE_FLAG           CAPITALIZE_FLAG
           , BK.RECOVERABLE_COST          RECOVERABLE_COST
           , BK.ADJUSTED_RECOVERABLE_COST ADJUSTED_RECOVERABLE_COST
           , AD.ASSET_CATEGORY_ID         ASSET_CATEGORY_ID
           , AD.CURRENT_UNITS             CURRENT_UNITS
           , 'NO' REINS_ASSET_FLAG
      FROM   FA_MC_BOOKS BK
           , FA_ADDITIONS_B AD
      WHERE  BK.BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
      AND    BK.TRANSACTION_HEADER_ID_OUT is null
      AND    BK.GROUP_ASSET_ID = p_asset_hdr_rec.asset_id
      AND    nvl(BK.CIP_COST, 0) = 0
      AND    BK.PERIOD_COUNTER_FULLY_RESERVED is null
      AND    BK.PERIOD_COUNTER_FULLY_RETIRED is null
      AND    BK.ASSET_ID = AD.ASSET_ID
      AND    BK.ASSET_ID <> decode(p_mode,'RECURR',nvl(h_rein_mem_asset_id,-1),-1)
      AND    AD.ASSET_TYPE = 'CAPITALIZED'
      AND    BK.SET_OF_BOOKS_ID = p_asset_hdr_rec.set_of_books_id
      UNION ALL
      SELECT BK.ASSET_ID                  ASSET_ID
           , BK.TRANSACTION_HEADER_ID_IN  TRANSACTION_HEADER_ID_IN
           , BK.RATE_ADJUSTMENT_FACTOR    RATE_ADJUSTMENT_FACTOR
           , BK.ADJUSTED_COST             ADJUSTED_COST
           , BK.CAPITALIZE_FLAG           CAPITALIZE_FLAG
           , BK.RECOVERABLE_COST          RECOVERABLE_COST
           , BK.ADJUSTED_RECOVERABLE_COST ADJUSTED_RECOVERABLE_COST
           , AD.ASSET_CATEGORY_ID         ASSET_CATEGORY_ID
           , AD.CURRENT_UNITS             CURRENT_UNITS
           , 'YES' REINS_ASSET_FLAG
      FROM   FA_MC_BOOKS BK
           , FA_ADDITIONS_B AD
      WHERE  BK.BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
      AND    BK.TRANSACTION_HEADER_ID_OUT is null
      AND    BK.GROUP_ASSET_ID = p_asset_hdr_rec.asset_id
      AND    nvl(BK.CIP_COST, 0) = 0
      AND    BK.ASSET_ID = AD.ASSET_ID
      AND    BK.ASSET_ID = decode(p_mode,'RECURR',nvl(h_rein_mem_asset_id,-1),-1)
      AND    AD.ASSET_TYPE = 'CAPITALIZED'
      AND    BK.SET_OF_BOOKS_ID = p_asset_hdr_rec.set_of_books_id
      order by 10,1; --Please never change this Order By clause. If changed will cause huge corruption.

   /*Bug 9076882 - For MRC we need to retrieve the transaction headers from primary*/
   CURSOR C_THIDS (p_asset_ids FA_NUM15_TBL_TYPE,p_source_trans_id number) is
      SELECT transaction_header_id
        FROM fa_transaction_headers fath,
             TABLE(CAST(p_asset_ids AS FA_NUM15_TBL_TYPE)) fatab
       WHERE fath.asset_id = fatab.column_value
         and fath.source_transaction_header_id = p_source_trans_id
       ORDER BY transaction_header_id;

   CURSOR C_THIDS_RECURR (p_asset_ids FA_NUM15_TBL_TYPE,p_source_trans_id number) is
      SELECT max(transaction_header_id)
        FROM fa_transaction_headers fath,
             TABLE(CAST(p_asset_ids AS FA_NUM15_TBL_TYPE)) fatab
       WHERE fath.asset_id = fatab.column_value
         and fath.source_transaction_header_id = p_source_trans_id
       ORDER BY transaction_header_id;

   CURSOR C_DIST_EXCESS IS
      SELECT ASSET_ID
           , TRANSACTION_HEADER_ID_IN
           , ADJUSTED_COST
      FROM   FA_BOOKS
      WHERE  BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
      AND    TRANSACTION_HEADER_ID_OUT is null
      AND    GROUP_ASSET_ID = p_asset_hdr_rec.asset_id
      AND    PERIOD_COUNTER_FULLY_RESERVED is null
      AND    PERIOD_COUNTER_FULLY_RETIRED is null
      AND    nvl(CIP_COST, 0) = 0
      AND    ADJUSTED_COST <> 0;

   CURSOR C_MC_DIST_EXCESS IS
      SELECT ASSET_ID
           , TRANSACTION_HEADER_ID_IN
           , ADJUSTED_COST
      FROM   FA_MC_BOOKS
      WHERE  BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
      AND    TRANSACTION_HEADER_ID_OUT is null
      AND    GROUP_ASSET_ID = p_asset_hdr_rec.asset_id
      AND    PERIOD_COUNTER_FULLY_RESERVED is null
      AND    PERIOD_COUNTER_FULLY_RETIRED is null
      AND    nvl(CIP_COST, 0) = 0
      AND    ADJUSTED_COST <> 0
      AND    set_of_books_id = p_asset_hdr_rec.set_of_books_id;


   -- Get old trx info for member and group
   CURSOR c_get_ret_member IS
      select th.asset_id
           , th.transaction_header_id
           , aj.debit_credit_flag
           , ad.current_units
           , ad.asset_category_id
           , bk.adjusted_recoverable_cost
           , sum(aj.adjustment_amount)
      from   fa_transaction_headers th    -- member
           , fa_transaction_headers gth -- group
           , fa_adjustments aj
           , fa_deprn_periods dp
           , fa_additions_b ad
           , fa_books bk
      where  th.book_type_code = p_asset_hdr_rec.book_type_code
--      and    th.date_effective = gth.date_effective
      and    th.source_transaction_header_id = gth.transaction_header_id
      and    gth.book_type_code = p_asset_hdr_rec.book_type_code
      and    gth.member_transaction_header_id = p_mem_ret_thid
      and    aj.asset_id = th.asset_id
      and    aj.book_type_code = p_asset_hdr_rec.book_type_code
      and    aj.transaction_header_id  = th.transaction_header_id
      and    dp.book_type_code = p_asset_hdr_rec.book_type_code
      and    gth.date_effective between dp.period_open_date and nvl(dp.period_close_date, sysdate)
      and    dp.period_counter = aj.period_counter_created
      and    th.asset_id = ad.asset_id
      and    bk.asset_id = th.asset_id
      and    bk.book_type_code = p_asset_hdr_rec.book_type_code
      and    bk.group_asset_id = gth.asset_id
      and    bk.transaction_header_id_out is null
      group by th.asset_id
             , th.transaction_header_id
             , aj.debit_credit_flag
             , ad.current_units
             , ad.asset_category_id
             , bk.adjusted_recoverable_cost;

   /*Bug 9076882 Get old trx info for member and group*/
   CURSOR c_mc_get_ret_member IS
      select th.asset_id
           , th.transaction_header_id
           , aj.debit_credit_flag
           , ad.current_units
           , ad.asset_category_id
           , bk.adjusted_recoverable_cost
           , sum(aj.adjustment_amount)
      from   fa_transaction_headers th    -- member
           , fa_transaction_headers gth -- group
           , fa_mc_adjustments aj
           , fa_mc_deprn_periods dp
           , fa_additions_b ad
           , fa_mc_books bk
      where  th.book_type_code = p_asset_hdr_rec.book_type_code
--      and    th.date_effective = gth.date_effective
      and    th.source_transaction_header_id = gth.transaction_header_id
      and    gth.book_type_code = p_asset_hdr_rec.book_type_code
      and    gth.member_transaction_header_id = p_mem_ret_thid
      and    aj.asset_id = th.asset_id
      and    aj.book_type_code = p_asset_hdr_rec.book_type_code
      and    aj.transaction_header_id  = th.transaction_header_id
      and    dp.book_type_code = p_asset_hdr_rec.book_type_code
      and    gth.date_effective between dp.period_open_date and nvl(dp.period_close_date, sysdate)
      and    dp.period_counter = aj.period_counter_created
      and    th.asset_id = ad.asset_id
      and    bk.asset_id = th.asset_id
      and    bk.book_type_code = p_asset_hdr_rec.book_type_code
      and    bk.group_asset_id = gth.asset_id
      and    bk.transaction_header_id_out is null
      and    bk.set_of_books_id = p_asset_hdr_rec.set_of_books_id
      and    aj.set_of_books_id = bk.set_of_books_id
      and    dp.set_of_books_id = aj.set_of_books_id
      group by th.asset_id
             , th.transaction_header_id
             , aj.debit_credit_flag
             , ad.current_units
             , ad.asset_category_id
             , bk.adjusted_recoverable_cost;

   CURSOR c_get_thid (c_asset_id number) IS
      select  transaction_header_id_in
      from    fa_books
      where book_type_code = p_asset_hdr_rec.book_type_code
      and   asset_id = c_asset_id
      and   transaction_header_id_out is null;

   CURSOR c_mc_get_thid (c_asset_id number) IS
      select  transaction_header_id_in
      from    fa_mc_books
      where book_type_code = p_asset_hdr_rec.book_type_code
      and   asset_id = c_asset_id
      and   transaction_header_id_out is null
      and   set_of_books_id = p_asset_hdr_rec.set_of_books_id;

   /*
   Bug 8633654
   cursor to find if any retirement adjustment happened against any
   member during retirement. If not, not need to reverse during
   reinstatement
   */
   CURSOR c_ret_adj_count IS
     select count(1)
     from   fa_transaction_headers th    -- member
          , fa_transaction_headers gth -- group
          , fa_adjustments aj
     where  th.book_type_code = p_asset_hdr_rec.book_type_code
     and    th.source_transaction_header_id = gth.transaction_header_id
     and    gth.book_type_code = p_asset_hdr_rec.book_type_code
     and    gth.member_transaction_header_id = p_mem_ret_thid
     and    aj.asset_id = th.asset_id
     and    aj.book_type_code = p_asset_hdr_rec.book_type_code
     and    aj.transaction_header_id  = th.transaction_header_id;

   TYPE tab_num15_type IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
   TYPE tab_num_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE tab_char3_type IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;

   l_adj              FA_ADJUST_TYPE_PKG.FA_ADJ_ROW_STRUCT;
   t_asset_id                    FA_NUM15_TBL_TYPE := FA_NUM15_TBL_TYPE(); --Bug 9076882
   t_transaction_header_id_in    tab_num15_type;
   t_rate_adjustment_factor      tab_num_type;
   t_recoverable_cost            tab_num_type;
   t_adjusted_cost               tab_num_type;
   t_capitalize_flag             tab_char3_type;
   t_adjusted_recoverable_cost   tab_num_type;
   t_asset_category_id           tab_num15_type;
   t_current_units               tab_num_type;
   t_thid                        tab_num15_type;
   t_new_adj_cost                tab_num_type;
   t_new_deprn_reserve           tab_num_type;
   t_adjustment_amount           tab_num_type;
   l_ret_adj_count               number := 0;
   l_actual_rsv_total            number := 0;

   t_debit_credit_flag           tab_char3_type;  -- reinstatement only
   t_reins_asset_flag            tab_char3_type;  -- RECURR only, bug 8633654
   l_th_count                    number := 0;


   l_last_asset_id    number(15);
   l_last_thid        number(15);

   l_sum_rec_cost     number;
   l_sum_adj_cost     number;
   l_group_rsv_ret    number;

   l_reallocate_amount number;

   -- Query balance parameters
   l_deprn_reserve         NUMBER;
   l_temp_num              NUMBER;
   l_temp_char             VARCHAR2(30);
   l_temp_bool             BOOLEAN;

   l_limit   BINARY_INTEGER := 500;
   allocate_err       EXCEPTION;

   l_loc   varchar2(245);

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Begin', p_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'Transaction_key', p_trans_rec.transaction_key, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_mode', p_mode,p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_reserve_amount', p_reserve_amount,p_log_level_rec);
   end if;

   if (p_reserve_amount = 0) then
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Returning from do_allocation as p_reserve_amount is 0', '',p_log_level_rec);
      end if;
      return TRUE;
   end if;

   -- Prepare common FA_ADJUST_TYPE_PKG.FA_ADJ_ROW_STRUCT parameters
   l_adj.book_type_code          := p_asset_hdr_rec.book_type_code;
   l_adj.period_counter_created  := p_period_rec.period_counter;
   l_adj.period_counter_adjusted := p_period_rec.period_counter;
   l_adj.selection_mode          := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
   l_adj.selection_retid         := 0;
   l_adj.leveling_flag           := TRUE;
   l_adj.flush_adj_flag          := TRUE;  -- FALSE;
   l_adj.last_update_date        := p_trans_rec.who_info.last_update_date;
   l_adj.gen_ccid_flag           := TRUE;
   l_adj.adjustment_type         := 'RESERVE';
   l_adj.account_type            := 'DEPRN_RESERVE_ACCT';
   l_adj.track_member_flag       := 'Y';
   l_adj.source_type_code := 'ADJUSTMENT';

   l_adj.mrc_sob_type_code := p_mrc_sob_type_code;
   l_adj.set_of_books_id   := p_asset_hdr_rec.set_of_books_id;
   --
   -- If this is called from retirement, then we know
   -- debit/credit flag from p_reserve_amount
   --
   if (p_trans_rec.transaction_key = 'MR') or
      (p_mode = 'RECURR') then

      /* bug 8633654 starts */
      if (p_mode = 'RECURR') then
        if (p_mrc_sob_type_code = 'R') then
            open c_mc_reins_mem_details;
            fetch c_mc_reins_mem_details into l_reins_mem_details;
            close c_mc_reins_mem_details;
         else
            open c_reins_mem_details;
            fetch c_reins_mem_details into l_reins_mem_details;
            close c_reins_mem_details;
         end if;
         h_rein_mem_asset_id := l_reins_mem_details.asset_id;
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'h_rein_mem_asset_id', h_rein_mem_asset_id,p_log_level_rec);
         end if;

         fa_query_balances_pkg.query_balances(
                   X_asset_id => h_rein_mem_asset_id,
                   X_book => p_asset_hdr_rec.book_type_code,
                   X_period_ctr => 0,
                   X_dist_id => 0,
                   X_run_mode => 'STANDARD',
                   X_cost => l_temp_num,
                   X_deprn_rsv => l_rein_mem_deprn_resv,
                   X_reval_rsv => l_temp_num,
                   X_ytd_deprn => l_temp_num,
                   X_ytd_reval_exp => l_temp_num,
                   X_reval_deprn_exp => l_temp_num,
                   X_deprn_exp => l_temp_num,
                   X_reval_amo => l_temp_num,
                   X_prod => l_temp_num,
                   X_ytd_prod => l_temp_num,
                   X_ltd_prod => l_temp_num,
                   X_adj_cost => l_temp_num,
                   X_reval_amo_basis => l_temp_num,
                   X_bonus_rate => l_temp_num,
                   X_deprn_source_code => l_temp_char,
                   X_adjusted_flag => l_temp_bool,
                   X_transaction_header_id => -1,
                   X_bonus_deprn_rsv => l_temp_num,
                   X_bonus_ytd_deprn => l_temp_num,
                   X_bonus_deprn_amount => l_temp_num,
                   X_impairment_rsv => l_temp_num,
                   X_ytd_impairment => l_temp_num,
                   X_impairment_amount => l_temp_num,
                   X_capital_adjustment => l_temp_num,
                   X_general_fund => l_temp_num,
                   X_mrc_sob_type_code => p_mrc_sob_type_code,
                   X_set_of_books_id => p_asset_hdr_rec.set_of_books_id,
                   p_log_level_rec => p_log_level_rec);
         l_rein_mem_adj_cost := l_reins_mem_details.recoverable_cost - l_rein_mem_deprn_resv;
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'l_rein_mem_adj_cost', l_rein_mem_adj_cost,p_log_level_rec);
         end if;
      end if;
      /* bug 8633654 ends */

      --
      -- If this is called from retirement, then we know
      -- debit/credit flag from p_reserve_amount
      --
      if (p_reserve_amount > 0) then
         l_adj.debit_credit_flag := 'DR';
      else
         l_adj.debit_credit_flag := 'CR';
      end if;

--toru
      l_sum_adj_cost := p_asset_fin_rec.recoverable_cost - p_asset_deprn_rec_new.deprn_reserve -
                        p_reserve_amount - nvl(l_rein_mem_adj_cost,0);

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'group reserve', p_asset_deprn_rec_new.deprn_reserve, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'sum rec_cost', p_asset_fin_rec.recoverable_cost, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'p_reserve_amount', p_reserve_amount, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_rein_mem_adj_cost', l_rein_mem_adj_cost,p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_sum_adj_cost', l_sum_adj_cost, p_log_level_rec => p_log_level_rec);
      end if;


      if (p_mrc_sob_type_code = 'R') then
         OPEN C_MC_GET_MEMBER_ASSETS;
      else
         OPEN C_GET_MEMBER_ASSETS;
      end if;

   elsif (p_trans_rec.transaction_key = 'MS') then
      /* Bug 8633654 */
      open c_ret_adj_count;
      fetch c_ret_adj_count into l_ret_adj_count;
      close c_ret_adj_count;
      IF (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'l_ret_adj_count', l_ret_adj_count,p_log_level_rec);
      END IF;
      IF l_ret_adj_count = 0 THEN
         IF (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'No allocation happened during retirement', ' ',p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'End of allocation', ' ',p_log_level_rec);
         END IF;
         return TRUE;

      END IF;

      if (p_mrc_sob_type_code <> 'R') then
         OPEN c_get_ret_member;
      else
         OPEN c_mc_get_ret_member;
      end if;
   end if;

   l_loc := 'Before Main Loop';
   LOOP -- MAIN OUTER LOOP

      t_thid.delete;
      t_asset_id.delete;
      t_transaction_header_id_in.delete;
      t_rate_adjustment_factor.delete;
      t_adjusted_cost.delete;
      t_capitalize_flag.delete;
      t_recoverable_cost.delete;
      t_adjusted_recoverable_cost.delete;
      t_asset_category_id.delete;
      t_current_units.delete;
      t_new_adj_cost.delete;
      t_adjustment_amount.delete;
      t_reins_asset_flag.delete;

      if (p_trans_rec.transaction_key = 'MR') or
         (p_mode = 'RECURR') then
         -- can this be update statement?
         if (p_mrc_sob_type_code = 'R') then
            FETCH C_MC_GET_MEMBER_ASSETS BULK COLLECT INTO t_asset_id
                                                      , t_transaction_header_id_in
                                                      , t_rate_adjustment_factor
                                                      , t_adjusted_cost
                                                      , t_capitalize_flag
                                                      , t_recoverable_cost
                                                      , t_adjusted_recoverable_cost
                                                      , t_asset_category_id
                                                      , t_current_units
                                                      , t_reins_asset_flag LIMIT l_limit;
         else
            FETCH C_GET_MEMBER_ASSETS BULK COLLECT INTO t_asset_id
                                                      , t_transaction_header_id_in
                                                      , t_rate_adjustment_factor
                                                      , t_adjusted_cost
                                                      , t_capitalize_flag
                                                      , t_recoverable_cost
                                                      , t_adjusted_recoverable_cost
                                                      , t_asset_category_id
                                                      , t_current_units
                                                      , t_reins_asset_flag LIMIT l_limit;
         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'In Main Cursor', t_asset_id.count, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_sum_adj_cost', l_sum_adj_cost, p_log_level_rec => p_log_level_rec);
         end if;

         if t_asset_id.count = 0 then

            if (p_mrc_sob_type_code = 'R') then
               CLOSE C_MC_GET_MEMBER_ASSETS;
            else
               CLOSE C_GET_MEMBER_ASSETS;
            end if;
            EXIT;
         end if;

      elsif (p_trans_rec.transaction_key = 'MS') then

         if (p_mrc_sob_type_code <> 'R') then --Bug 9076882
         FETCH c_get_ret_member BULK COLLECT INTO t_asset_id
                                                , t_transaction_header_id_in
                                                , t_debit_credit_flag
                                                , t_current_units
                                                , t_asset_category_id
                                                , t_adjusted_recoverable_cost
                                                , t_adjustment_amount
                                                  LIMIT l_limit;

         else
         FETCH c_mc_get_ret_member BULK COLLECT INTO t_asset_id
                                                , t_transaction_header_id_in
                                                , t_debit_credit_flag
                                                , t_current_units
                                                , t_asset_category_id
                                                , t_adjusted_recoverable_cost
                                                , t_adjustment_amount
                                                  LIMIT l_limit;
         end if;
         if t_asset_id.count = 0 then

            IF (p_mrc_sob_type_code <> 'R') THEN
               CLOSE c_get_ret_member;
               EXIT;
            ELSE
               CLOSE c_mc_get_ret_member;
               EXIT;
            END IF;

         end if;

      end if; -- (p_trans_rec.transaction_key = 'MR')

      l_loc := 'Before Insert TH';
      l_th_count := t_asset_id.last;

      /* Do not insert last record in RECURR mode and reinstated asset flag is YES */

      if(p_mode = 'RECURR' AND t_reins_asset_flag(l_th_count) = 'YES') THEN
         l_th_count := l_th_count-1;
      END IF;

      IF (p_mrc_sob_type_code <> 'R') THEN  --Bug 9076882 No need insert transaction headers for MRC
      FORALL i in t_asset_id.first..l_th_count
         INSERT INTO FA_TRANSACTION_HEADERS(
                         TRANSACTION_HEADER_ID
                       , BOOK_TYPE_CODE
                       , ASSET_ID
                       , TRANSACTION_TYPE_CODE
                       , TRANSACTION_DATE_ENTERED
                       , DATE_EFFECTIVE
                       , LAST_UPDATE_DATE
                       , LAST_UPDATED_BY
                       , SOURCE_TRANSACTION_HEADER_ID
                       , MASS_REFERENCE_ID
                       , LAST_UPDATE_LOGIN
                       , TRANSACTION_SUBTYPE
                       , TRANSACTION_KEY
                       , AMORTIZATION_START_DATE
                       , CALLING_INTERFACE
                       , MASS_TRANSACTION_ID
         ) VALUES (
                         FA_TRANSACTION_HEADERS_S.NEXTVAL
                       , p_asset_hdr_rec.book_type_code
                       , t_asset_id(i)
                       , 'ADJUSTMENT'
                       , p_trans_rec.transaction_date_entered
                       , p_trans_rec.who_info.last_update_date
                       , p_trans_rec.who_info.last_update_date
                       , p_trans_rec.who_info.last_updated_by
                       , p_trans_rec.transaction_header_id
                       , p_trans_rec.mass_reference_id
                       , p_trans_rec.who_info.last_update_login
                       , 'AMORTIZED'
                       , 'RA'
                       , p_trans_rec.amortization_start_date
                       , p_trans_rec.calling_interface
                       , p_trans_rec.mass_transaction_id
         ) RETURNING transaction_header_id BULK COLLECT INTO t_thid;
      ELSE --Fetch all primary transaction hedaers for mrc
         if(p_mode <> 'RECURR') then
         OPEN C_THIDS (p_asset_ids => t_asset_id,p_source_trans_id => p_trans_rec.transaction_header_id);
         FETCH C_THIDS BULK COLLECT INTO t_thid;
         CLOSE C_THIDS;
         else
         OPEN C_THIDS_RECURR (p_asset_ids => t_asset_id,p_source_trans_id => p_trans_rec.transaction_header_id);
         FETCH C_THIDS_RECURR BULK COLLECT INTO t_thid;
         CLOSE C_THIDS_RECURR;
         end if;
      END IF;


      l_loc := 'Before ADJ LOOP';
      -- Prepare non-common FA_ADJUST_TYPE_PKG.FA_ADJ_ROW_STRUCT parameters and
      -- call faxinaj to create records in FA_ADJUSTMENTS table
      if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Before ADJ LOOP', t_asset_id(1));
            fa_debug_pkg.add(l_calling_fn, 't_asset_id.last', t_asset_id.last, p_log_level_rec => p_log_level_rec);
      end if;


      FOR i in 1..t_asset_id.last LOOP

         if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, 'asset_id', t_asset_id(i),p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'p_reserve_amount', p_reserve_amount, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_sum_adj_cost', l_sum_adj_cost, p_log_level_rec => p_log_level_rec);
         end if;

         if (p_trans_rec.transaction_key = 'MR') or
            (p_mode = 'RECURR') then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Call',
                                'fa_query_balances_pkg.query_balances', p_log_level_rec => p_log_level_rec);
            end if;
            bln_use_cur_asset := FALSE;
            if (p_trans_rec.transaction_key = 'MR' OR (p_mode = 'RECURR' AND t_reins_asset_flag(i) = 'NO') ) THEN
               bln_other_mem_exists := TRUE;
            fa_query_balances_pkg.query_balances(
                      X_asset_id => t_asset_id(i),
                      X_book => p_asset_hdr_rec.book_type_code,
                      X_period_ctr => 0,
                      X_dist_id => 0,
                      X_run_mode => 'STANDARD',
                      X_cost => l_temp_num,
                      X_deprn_rsv => l_deprn_reserve,
                      X_reval_rsv => l_temp_num,
                      X_ytd_deprn => l_temp_num,
                      X_ytd_reval_exp => l_temp_num,
                      X_reval_deprn_exp => l_temp_num,
                      X_deprn_exp => l_temp_num,
                      X_reval_amo => l_temp_num,
                      X_prod => l_temp_num,
                      X_ytd_prod => l_temp_num,
                      X_ltd_prod => l_temp_num,
                      X_adj_cost => l_temp_num,
                      X_reval_amo_basis => l_temp_num,
                      X_bonus_rate => l_temp_num,
                      X_deprn_source_code => l_temp_char,
                      X_adjusted_flag => l_temp_bool,
                      X_transaction_header_id => -1,
                      X_bonus_deprn_rsv => l_temp_num,
                      X_bonus_ytd_deprn => l_temp_num,
                      X_bonus_deprn_amount => l_temp_num,
                      X_impairment_rsv => l_temp_num,
                      X_ytd_impairment => l_temp_num,
                      X_impairment_amount => l_temp_num,
                      X_capital_adjustment => l_temp_num,
                      X_general_fund => l_temp_num,
                      X_mrc_sob_type_code => p_mrc_sob_type_code,
                      X_set_of_books_id => p_asset_hdr_rec.set_of_books_id,
                      p_log_level_rec     => p_log_level_rec);

            if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 't_asset_id('||to_char(i)||')',
                                   t_asset_id(i),p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'l_deprn_reserve',
                                   l_deprn_reserve,p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 't_adjusted_cost('||to_char(i)||')',
                                   t_adjusted_cost(i),p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 't_recoverable_cost('||to_char(i)||')',
                                   t_recoverable_cost(i),p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 't_adjusted_recoverable_cost('||to_char(i)||')',
                                   t_adjusted_recoverable_cost(i),p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'l_actual_rsv_total',
                                   l_actual_rsv_total,p_log_level_rec);
            end if;

            t_adjusted_cost(i) := t_recoverable_cost(i) - l_deprn_reserve;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 't_adjusted_cost('||to_char(i)||')', t_adjusted_cost(i));
            end if;

            if t_adjusted_cost(i) <> 0 then
                  l_adj.adjustment_amount := abs(p_reserve_amount) * (t_adjusted_cost(i)/l_sum_adj_cost);
            else
                  l_adj.adjustment_amount := 0;
            end if;

            if not FA_UTILS_PKG.faxrnd(l_adj.adjustment_amount,
                                       p_asset_hdr_rec.book_type_code,
                                       p_asset_hdr_rec.set_of_books_id,
                                       p_log_level_rec => p_log_level_rec) then
               raise allocate_err;
            end if;

            t_adjustment_amount(i) := sign(p_reserve_amount) * -1 * l_adj.adjustment_amount;


               /* Bug 8633654 starts */
               if (t_adjusted_recoverable_cost(i) >= 0) then
                 if (t_adjusted_recoverable_cost(i) - l_deprn_reserve - t_adjustment_amount(i) < 0) then
                   l_adj.adjustment_amount := t_adjusted_recoverable_cost(i) - l_deprn_reserve;
                   bln_rein_mem_reqd := TRUE;
                 end if;
               else
                 if (t_adjusted_recoverable_cost(i) - l_deprn_reserve - t_adjustment_amount(i) > 0) then
                   l_adj.adjustment_amount := t_adjusted_recoverable_cost(i) - l_deprn_reserve;
                   bln_rein_mem_reqd := TRUE;
                 end if;
               end if;
               bln_use_cur_asset := TRUE;
               /* Bug 8633654 ends */

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'new l_adj.adjustment_amount',
                                   l_adj.adjustment_amount,p_log_level_rec);
               end if;

               l_actual_rsv_total := l_actual_rsv_total + sign(p_reserve_amount) * l_adj.adjustment_amount;
               t_adjustment_amount(i) := sign(p_reserve_amount) * -1 * l_adj.adjustment_amount;

            /* Bug 8633654 starts */
            elsif (p_mode = 'RECURR' AND t_reins_asset_flag(i) = 'YES') THEN
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Reinstated member','start',p_log_level_rec);
               end if;
               if (bln_rein_mem_reqd OR (NOT bln_other_mem_exists) ) THEN
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Reinstated member','allocate remaining',p_log_level_rec);
                  end if;
                  bln_rein_mem_reqd := TRUE;
                  bln_use_cur_asset := TRUE;
                  l_adj.adjustment_amount := abs(p_reserve_amount - l_actual_rsv_total);
                  t_adjustment_amount(i) := sign(p_reserve_amount) * -1 * l_adj.adjustment_amount;
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 't_asset_id('||to_char(i)||')',
                                      t_asset_id(i),p_log_level_rec);
                     fa_debug_pkg.add(l_calling_fn, 'l_rein_mem_deprn_resv',
                                      l_rein_mem_deprn_resv,p_log_level_rec);
                     fa_debug_pkg.add(l_calling_fn, 't_adjusted_recoverable_cost('||to_char(i)||')',
                                      t_adjusted_recoverable_cost(i),p_log_level_rec);
                     fa_debug_pkg.add(l_calling_fn, 't_adjustment_amount('||to_char(i)||')',
                                      t_adjustment_amount(i),p_log_level_rec);
                  end if;

                  if (t_adjusted_recoverable_cost(i) >= 0) then
                     if (t_adjusted_recoverable_cost(i) - l_rein_mem_deprn_resv - t_adjustment_amount(i) < 0) then
                        fa_srvr_msg.add_message(
                        calling_fn => l_calling_fn,
                        name       => 'FA_EGY_REINS_NOT_POSSIBLE',
                        p_log_level_rec => p_log_level_rec);
                        raise allocate_err;
                     end if;
                  else
                     if (t_adjusted_recoverable_cost(i) - l_rein_mem_deprn_resv - t_adjustment_amount(i) > 0) then
                        fa_srvr_msg.add_message(
                        calling_fn => l_calling_fn,
                        name       => 'FA_EGY_REINS_NOT_POSSIBLE',
                        p_log_level_rec => p_log_level_rec);
                        raise allocate_err;
                     end if;
                  end if;

                  IF (p_mrc_sob_type_code <> 'R') THEN
                  --Bug 9076882. No need to insert transaction for MRC.This is already fethced above using c_thids cursor

                  select FA_TRANSACTION_HEADERS_S.NEXTVAL
                  into   t_thid(i)
                  from   dual;

                  /* Insert record into fa_transaction_headers */
                  INSERT INTO FA_TRANSACTION_HEADERS(
                                  TRANSACTION_HEADER_ID
                                , BOOK_TYPE_CODE
                                , ASSET_ID
                                , TRANSACTION_TYPE_CODE
                                , TRANSACTION_DATE_ENTERED
                                , DATE_EFFECTIVE
                                , LAST_UPDATE_DATE
                                , LAST_UPDATED_BY
                                , SOURCE_TRANSACTION_HEADER_ID
                                , MASS_REFERENCE_ID
                                , LAST_UPDATE_LOGIN
                                , TRANSACTION_SUBTYPE
                                , TRANSACTION_KEY
                                , AMORTIZATION_START_DATE
                                , CALLING_INTERFACE
                                , MASS_TRANSACTION_ID
                  ) VALUES (
                                  t_thid(i)
                                , p_asset_hdr_rec.book_type_code
                                , t_asset_id(i)
                                , 'ADJUSTMENT'
                                , p_trans_rec.transaction_date_entered
                                , p_trans_rec.who_info.last_update_date
                                , p_trans_rec.who_info.last_update_date
                                , p_trans_rec.who_info.last_updated_by
                                , p_trans_rec.transaction_header_id
                                , p_trans_rec.mass_reference_id
                                , p_trans_rec.who_info.last_update_login
                                , 'AMORTIZED'
                                , 'RA'
                                , p_trans_rec.amortization_start_date
                                , p_trans_rec.calling_interface
                                , p_trans_rec.mass_transaction_id
                  );
                  END IF;

                  l_actual_rsv_total := p_reserve_amount;

                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'l_adj.adjustment_amount',l_adj.adjustment_amount,p_log_level_rec);
                     fa_debug_pkg.add(l_calling_fn, 't_adjustment_amount('||i||')',t_adjustment_amount(i),p_log_level_rec);
                  end if;
               end if;
            /* Bug 8633654 ends */
            end if;

         elsif (p_trans_rec.transaction_key = 'MS') then

            if (p_mrc_sob_type_code = 'R') then
--toru
               OPEN c_mc_get_thid(t_asset_id(i));
               FETCH c_mc_get_thid INTO t_transaction_header_id_in(i);
               CLOSE c_mc_get_thid;

            else

               OPEN c_get_thid(t_asset_id(i));
               FETCH c_get_thid INTO t_transaction_header_id_in(i);
               CLOSE c_get_thid;

            end if;

            fa_query_balances_pkg.query_balances(
                      X_asset_id => t_asset_id(i),
                      X_book => p_asset_hdr_rec.book_type_code,
                      X_period_ctr => 0,
                      X_dist_id => 0,
                      X_run_mode => 'STANDARD',
                      X_cost => l_temp_num,
                      X_deprn_rsv => l_deprn_reserve,
                      X_reval_rsv => l_temp_num,
                      X_ytd_deprn => l_temp_num,
                      X_ytd_reval_exp => l_temp_num,
                      X_reval_deprn_exp => l_temp_num,
                      X_deprn_exp => l_temp_num,
                      X_reval_amo => l_temp_num,
                      X_prod => l_temp_num,
                      X_ytd_prod => l_temp_num,
                      X_ltd_prod => l_temp_num,
                      X_adj_cost => l_temp_num,
                      X_reval_amo_basis => l_temp_num,
                      X_bonus_rate => l_temp_num,
                      X_deprn_source_code => l_temp_char,
                      X_adjusted_flag => l_temp_bool,
                      X_transaction_header_id => -1,
                      X_bonus_deprn_rsv => l_temp_num,
                      X_bonus_ytd_deprn => l_temp_num,
                      X_bonus_deprn_amount => l_temp_num,
                      X_impairment_rsv => l_temp_num,
                      X_ytd_impairment => l_temp_num,
                      X_impairment_amount => l_temp_num,
                      X_capital_adjustment => l_temp_num,
                      X_general_fund => l_temp_num,
                      X_mrc_sob_type_code => p_mrc_sob_type_code,
                      X_set_of_books_id => p_asset_hdr_rec.set_of_books_id,
                      p_log_level_rec     => p_log_level_rec);

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'l_deprn_reserve',
                                l_deprn_reserve, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 't_adjusted_recoverable_cost('||to_char(i)||')',
                                t_adjusted_recoverable_cost(i));
            end if;

            /*8425794 - Start - 1*/
            if (t_debit_credit_flag(i) = 'CR') then
               t_adjustment_amount(i) := -1 * t_adjustment_amount(i);
            end if;
            /*8425794 - End - 1*/

            -- Check to see if the asset can take entire reserve reinstated or not.
            -- If not, it takes as much as it can.
            if (t_adjusted_recoverable_cost(i) >= 0) then
               if (t_adjusted_recoverable_cost(i) - l_deprn_reserve - t_adjustment_amount(i) < 0) then
                  t_adjustment_amount(i) := t_adjusted_recoverable_cost(i) - l_deprn_reserve;
               end if;
            else
                if (t_adjusted_recoverable_cost(i) - l_deprn_reserve - t_adjustment_amount(i) > 0) then
                    t_adjustment_amount(i) := t_adjusted_recoverable_cost(i) - l_deprn_reserve;
                end if;
            end if;

            if (t_debit_credit_flag(i) = 'DR') then
               l_adj.adjustment_amount := t_adjustment_amount(i);
               l_adj.debit_credit_flag := 'CR';
            else
               t_adjustment_amount(i) := -1 * t_adjustment_amount(i);
               l_adj.adjustment_amount := t_adjustment_amount(i);
               l_adj.debit_credit_flag := 'DR';
            end if;

            /*8425794 - Start - 2*/
            if (p_reserve_amount >= 0) then
                l_actual_rsv_total := l_actual_rsv_total + l_adj.adjustment_amount;
            else
               l_actual_rsv_total := l_actual_rsv_total - l_adj.adjustment_amount;
            end if;
            /*8425794 - End - 2*/





         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Recapture Excess Reserve',
                             l_adj.adjustment_amount, p_log_level_rec => p_log_level_rec);
         end if;

         IF(bln_use_cur_asset) THEN

         l_adj.asset_id                := t_asset_id(i);
         l_adj.transaction_header_id   := t_thid(i);
         l_adj.current_units           := t_current_units(i);

         if not fa_cache_pkg.fazccb(p_asset_hdr_rec.book_type_code,
                                    t_asset_category_id(i),
                                    p_log_level_rec) then
            fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            raise allocate_err;
         end if;

         l_adj.account           := fa_cache_pkg.fazccb_record.DEPRN_RESERVE_ACCT;

         if not FA_INS_ADJUST_PKG.faxinaj
                            (l_adj,
                             p_trans_rec.who_info.last_update_date,
                             p_trans_rec.who_info.last_updated_by,
                             p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
            raise allocate_err;
         end if;
--tk_util.debug('finish adj');

         l_last_asset_id := t_asset_id(i);
         l_last_thid     := t_thid(i);
         END IF;
      END LOOP;
      /* Bug 8633654 starts (delete last record when it is not required)*/

      IF (p_mode = 'RECURR' and (NOT bln_rein_mem_reqd)) THEN
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Delete Reinstated member from PL-SQL','CHECK',p_log_level_rec);
         end if;
         l_loc := 'Before PL-SQL Delete';

         IF (t_asset_id(t_asset_id.last) = h_rein_mem_asset_id) THEN
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 't_asset_id(t_asset_id.last)',t_asset_id(t_asset_id.last),p_log_level_rec);
            end if;

            l_ind := t_thid.last;
            t_asset_id.delete(t_asset_id.last);
            t_transaction_header_id_in.delete(t_transaction_header_id_in.last);
            t_rate_adjustment_factor.delete(t_rate_adjustment_factor.last);
            t_adjusted_cost.delete(t_adjusted_cost.last);
            t_capitalize_flag.delete(t_capitalize_flag.last);
            t_recoverable_cost.delete(t_recoverable_cost.last);
            t_adjusted_recoverable_cost.delete(t_adjusted_recoverable_cost.last);
            t_asset_category_id.delete(t_asset_category_id.last);
            t_current_units.delete(t_current_units.last);
            t_reins_asset_flag.delete(t_reins_asset_flag.last);
         END IF;
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Delete Reinstated member from PL-SQL','Done',p_log_level_rec);
         end if;
      END IF;

      /* Bug 8633654 ends*/

      if (p_mrc_sob_type_code = 'R') then
         l_loc := 'Before BS';
         -- Update FA_MC_BOOKS_SUMAMRY table with new reserve adjustment amount and
         -- related columns.  Return new adjusted_cost and deprn reserve for later use
         FORALL i in t_asset_id.first..t_asset_id.last
            UPDATE FA_MC_BOOKS_SUMMARY
            SET    RESERVE_ADJUSTMENT_AMOUNT = RESERVE_ADJUSTMENT_AMOUNT + t_adjustment_amount(i)
                 , DEPRN_RESERVE = DEPRN_RESERVE + t_adjustment_amount(i)
                 , ADJUSTED_COST = RECOVERABLE_COST - DEPRN_RESERVE - t_adjustment_amount(i)
            WHERE  ASSET_ID = t_asset_id(i)
            AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
            AND    PERIOD_COUNTER = p_period_rec.period_counter
            AND    TRANSACTION_HEADER_ID_OUT IS NULL
            AND    set_of_books_id = p_asset_hdr_rec.set_of_books_id
            RETURNING ADJUSTED_COST, DEPRN_RESERVE
            BULK COLLECT INTO t_new_adj_cost, t_new_deprn_reserve;


         l_loc := 'Before Books';
         -- Deactivate FA_BOOKS row for processed assets
         FORALL i in t_asset_id.first..t_asset_id.last
            UPDATE FA_MC_BOOKS
            SET    DATE_INEFFECTIVE = p_trans_rec.who_info.last_update_date
                 , TRANSACTION_HEADER_ID_OUT = t_thid(i)
            WHERE  TRANSACTION_HEADER_ID_IN = t_transaction_header_id_in(i)
              AND  set_of_books_id = p_asset_hdr_rec.set_of_books_id;


         -- Insert new FA_BOOKS records for processed assets
         FORALL i in t_asset_id.first..t_asset_id.last
            INSERT INTO FA_MC_BOOKS( BOOK_TYPE_CODE
                                      , ASSET_ID
                                      , DATE_PLACED_IN_SERVICE
                                      , DATE_EFFECTIVE
                                      , DEPRN_START_DATE
                                      , DEPRN_METHOD_CODE
                                      , LIFE_IN_MONTHS
                                      , RATE_ADJUSTMENT_FACTOR
                                      , ADJUSTED_COST
                                      , COST
                                      , ORIGINAL_COST
                                      , SALVAGE_VALUE
                                      , PRORATE_CONVENTION_CODE
                                      , PRORATE_DATE
                                      , COST_CHANGE_FLAG
                                      , ADJUSTMENT_REQUIRED_STATUS
                                      , CAPITALIZE_FLAG
                                      , RETIREMENT_PENDING_FLAG
                                      , DEPRECIATE_FLAG
                                      , LAST_UPDATE_DATE
                                      , LAST_UPDATED_BY
                                      , TRANSACTION_HEADER_ID_IN
                                      , ITC_AMOUNT_ID
                                      , ITC_AMOUNT
                                      , RETIREMENT_ID
                                      , TAX_REQUEST_ID
                                      , ITC_BASIS
                                      , BASIC_RATE
                                      , ADJUSTED_RATE
                                      , BONUS_RULE
                                      , CEILING_NAME
                                      , RECOVERABLE_COST
                                      , LAST_UPDATE_LOGIN
                                      , ADJUSTED_CAPACITY
                                      , FULLY_RSVD_REVALS_COUNTER
                                      , IDLED_FLAG
                                      , PERIOD_COUNTER_CAPITALIZED
                                      , PERIOD_COUNTER_FULLY_RESERVED
                                      , PERIOD_COUNTER_FULLY_RETIRED
                                      , PRODUCTION_CAPACITY
                                      , REVAL_AMORTIZATION_BASIS
                                      , REVAL_CEILING
                                      , UNIT_OF_MEASURE
                                      , UNREVALUED_COST
                                      , ANNUAL_DEPRN_ROUNDING_FLAG
                                      , PERCENT_SALVAGE_VALUE
                                      , ALLOWED_DEPRN_LIMIT
                                      , ALLOWED_DEPRN_LIMIT_AMOUNT
                                      , PERIOD_COUNTER_LIFE_COMPLETE
                                      , ADJUSTED_RECOVERABLE_COST
                                      , ANNUAL_ROUNDING_FLAG
                                      , GLOBAL_ATTRIBUTE1
                                      , GLOBAL_ATTRIBUTE2
                                      , GLOBAL_ATTRIBUTE3
                                      , GLOBAL_ATTRIBUTE4
                                      , GLOBAL_ATTRIBUTE5
                                      , GLOBAL_ATTRIBUTE6
                                      , GLOBAL_ATTRIBUTE7
                                      , GLOBAL_ATTRIBUTE8
                                      , GLOBAL_ATTRIBUTE9
                                      , GLOBAL_ATTRIBUTE10
                                      , GLOBAL_ATTRIBUTE11
                                      , GLOBAL_ATTRIBUTE12
                                      , GLOBAL_ATTRIBUTE13
                                      , GLOBAL_ATTRIBUTE14
                                      , GLOBAL_ATTRIBUTE15
                                      , GLOBAL_ATTRIBUTE16
                                      , GLOBAL_ATTRIBUTE17
                                      , GLOBAL_ATTRIBUTE18
                                      , GLOBAL_ATTRIBUTE19
                                      , GLOBAL_ATTRIBUTE20
                                      , GLOBAL_ATTRIBUTE_CATEGORY
                                      , EOFY_ADJ_COST
                                      , EOFY_FORMULA_FACTOR
                                      , SHORT_FISCAL_YEAR_FLAG
                                      , CONVERSION_DATE
                                      , ORIGINAL_DEPRN_START_DATE
                                      , REMAINING_LIFE1
                                      , REMAINING_LIFE2
                                      , OLD_ADJUSTED_COST
                                      , FORMULA_FACTOR
                                      , GROUP_ASSET_ID
                                      , SALVAGE_TYPE
                                      , DEPRN_LIMIT_TYPE
                                      , REDUCTION_RATE
                                      , REDUCE_ADDITION_FLAG
                                      , REDUCE_ADJUSTMENT_FLAG
                                      , REDUCE_RETIREMENT_FLAG
                                      , RECOGNIZE_GAIN_LOSS
                                      , RECAPTURE_RESERVE_FLAG
                                      , LIMIT_PROCEEDS_FLAG
                                      , TERMINAL_GAIN_LOSS
                                      , TRACKING_METHOD
                                      , EXCLUDE_FULLY_RSV_FLAG
                                      , EXCESS_ALLOCATION_OPTION
                                      , DEPRECIATION_OPTION
                                      , MEMBER_ROLLUP_FLAG
                                      , ALLOCATE_TO_FULLY_RSV_FLAG
                                      , ALLOCATE_TO_FULLY_RET_FLAG
                                      , TERMINAL_GAIN_LOSS_AMOUNT
                                      , CIP_COST
                                      , YTD_PROCEEDS
                                      , LTD_PROCEEDS
                                      , LTD_COST_OF_REMOVAL
                                      , EOFY_RESERVE
                                      , PRIOR_EOFY_RESERVE
                                      , EOP_ADJ_COST
                                      , EOP_FORMULA_FACTOR
                                      , EXCLUDE_PROCEEDS_FROM_BASIS
                                      , RETIREMENT_DEPRN_OPTION
                                      , TERMINAL_GAIN_LOSS_FLAG
                                      , SUPER_GROUP_ID
                                      , OVER_DEPRECIATE_OPTION
                                      , DISABLED_FLAG
                                      , SET_OF_BOOKS_ID
            ) SELECT BOOK_TYPE_CODE
                   , ASSET_ID
                   , DATE_PLACED_IN_SERVICE
                   , p_trans_rec.who_info.last_update_date -- DATE_EFFECTIVE
                   , DEPRN_START_DATE
                   , DEPRN_METHOD_CODE
                   , LIFE_IN_MONTHS
                   , RATE_ADJUSTMENT_FACTOR
                   , t_new_adj_cost(i) -- ADJUSTED_COST
                   , COST
                   , ORIGINAL_COST
                   , SALVAGE_VALUE
                   , PRORATE_CONVENTION_CODE
                   , PRORATE_DATE
                   , COST_CHANGE_FLAG
                   , ADJUSTMENT_REQUIRED_STATUS
                   , CAPITALIZE_FLAG
                   , RETIREMENT_PENDING_FLAG
                   , DEPRECIATE_FLAG
                   , p_trans_rec.who_info.last_update_date -- LAST_UPDATE_DATE
                   , p_trans_rec.who_info.last_updated_by -- LAST_UPDATED_BY
                   , t_thid(i) -- TRANSACTION_HEADER_ID_IN
                   , ITC_AMOUNT_ID
                   , ITC_AMOUNT
                   , RETIREMENT_ID
                   , TAX_REQUEST_ID
                   , ITC_BASIS
                   , BASIC_RATE
                   , ADJUSTED_RATE
                   , BONUS_RULE
                   , CEILING_NAME
                   , RECOVERABLE_COST
                   , p_trans_rec.who_info.last_update_login -- LAST_UPDATE_LOGIN
                   , ADJUSTED_CAPACITY
                   , FULLY_RSVD_REVALS_COUNTER
                   , IDLED_FLAG
                   , PERIOD_COUNTER_CAPITALIZED
                   , PERIOD_COUNTER_FULLY_RESERVED
                   , PERIOD_COUNTER_FULLY_RETIRED
                   , PRODUCTION_CAPACITY
                   , REVAL_AMORTIZATION_BASIS
                   , REVAL_CEILING
                   , UNIT_OF_MEASURE
                   , UNREVALUED_COST
                   , ANNUAL_DEPRN_ROUNDING_FLAG
                   , PERCENT_SALVAGE_VALUE
                   , ALLOWED_DEPRN_LIMIT
                   , ALLOWED_DEPRN_LIMIT_AMOUNT
                   , PERIOD_COUNTER_LIFE_COMPLETE
                   , ADJUSTED_RECOVERABLE_COST
                   , ANNUAL_ROUNDING_FLAG
                   , GLOBAL_ATTRIBUTE1
                   , GLOBAL_ATTRIBUTE2
                   , GLOBAL_ATTRIBUTE3
                   , GLOBAL_ATTRIBUTE4
                   , GLOBAL_ATTRIBUTE5
                   , GLOBAL_ATTRIBUTE6
                   , GLOBAL_ATTRIBUTE7
                   , GLOBAL_ATTRIBUTE8
                   , GLOBAL_ATTRIBUTE9
                   , GLOBAL_ATTRIBUTE10
                   , GLOBAL_ATTRIBUTE11
                   , GLOBAL_ATTRIBUTE12
                   , GLOBAL_ATTRIBUTE13
                   , GLOBAL_ATTRIBUTE14
                   , GLOBAL_ATTRIBUTE15
                   , GLOBAL_ATTRIBUTE16
                   , GLOBAL_ATTRIBUTE17
                   , GLOBAL_ATTRIBUTE18
                   , GLOBAL_ATTRIBUTE19
                   , GLOBAL_ATTRIBUTE20
                   , GLOBAL_ATTRIBUTE_CATEGORY
                   , EOFY_ADJ_COST
                   , EOFY_FORMULA_FACTOR
                   , SHORT_FISCAL_YEAR_FLAG
                   , CONVERSION_DATE
                   , ORIGINAL_DEPRN_START_DATE
                   , REMAINING_LIFE1
                   , REMAINING_LIFE2
                   , OLD_ADJUSTED_COST
                   , FORMULA_FACTOR
                   , GROUP_ASSET_ID
                   , SALVAGE_TYPE
                   , DEPRN_LIMIT_TYPE
                   , REDUCTION_RATE
                   , REDUCE_ADDITION_FLAG
                   , REDUCE_ADJUSTMENT_FLAG
                   , REDUCE_RETIREMENT_FLAG
                   , RECOGNIZE_GAIN_LOSS
                   , RECAPTURE_RESERVE_FLAG
                   , LIMIT_PROCEEDS_FLAG
                   , TERMINAL_GAIN_LOSS
                   , TRACKING_METHOD
                   , EXCLUDE_FULLY_RSV_FLAG
                   , EXCESS_ALLOCATION_OPTION
                   , DEPRECIATION_OPTION
                   , MEMBER_ROLLUP_FLAG
                   , ALLOCATE_TO_FULLY_RSV_FLAG
                   , ALLOCATE_TO_FULLY_RET_FLAG
                   , TERMINAL_GAIN_LOSS_AMOUNT
                   , CIP_COST
                   , YTD_PROCEEDS
                   , LTD_PROCEEDS
                   , LTD_COST_OF_REMOVAL
                   , EOFY_RESERVE
                   , PRIOR_EOFY_RESERVE
                   , EOP_ADJ_COST
                   , EOP_FORMULA_FACTOR
                   , EXCLUDE_PROCEEDS_FROM_BASIS
                   , RETIREMENT_DEPRN_OPTION
                   , TERMINAL_GAIN_LOSS_FLAG
                   , SUPER_GROUP_ID
                   , OVER_DEPRECIATE_OPTION
                   , DISABLED_FLAG
                   , SET_OF_BOOKS_ID
              FROM  FA_MC_BOOKS
              WHERE TRANSACTION_HEADER_ID_IN = t_transaction_header_id_in(i)
                AND set_of_books_id = p_asset_hdr_rec.set_of_books_id;

      else
         l_loc := 'Before BS';
         -- Update FA_BOOKS_SUMAMRY table with new reserve adjustment amount and
         -- related columns.  Return new adjusted_cost and deprn reserve for later use
         FORALL i in t_asset_id.first..t_asset_id.last
            UPDATE FA_BOOKS_SUMMARY
            SET    RESERVE_ADJUSTMENT_AMOUNT = RESERVE_ADJUSTMENT_AMOUNT + t_adjustment_amount(i)
                 , DEPRN_RESERVE = DEPRN_RESERVE + t_adjustment_amount(i)
                 , ADJUSTED_COST = RECOVERABLE_COST - DEPRN_RESERVE - t_adjustment_amount(i)
            WHERE  ASSET_ID = t_asset_id(i)
            AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
            AND    PERIOD_COUNTER = p_period_rec.period_counter
            AND    TRANSACTION_HEADER_ID_OUT IS NULL
            RETURNING ADJUSTED_COST, DEPRN_RESERVE
            BULK COLLECT INTO t_new_adj_cost, t_new_deprn_reserve;

         if (p_log_level_rec.statement_level) then
            for i in t_asset_id.first..t_asset_id.last loop
               fa_debug_pkg.add(l_calling_fn, 'i', i, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 't_new_adj_cost', t_new_adj_cost(i));
               fa_debug_pkg.add(l_calling_fn, 't_new_deprn_reserve', t_new_deprn_reserve(i));
               fa_debug_pkg.add(l_calling_fn, 't_transaction_header_id_in', t_transaction_header_id_in(i));
               fa_debug_pkg.add(l_calling_fn, 't_asset_id', t_asset_id(i));
               fa_debug_pkg.add(l_calling_fn, 't_thid', t_thid(i));
            end loop;
         end if;

         l_loc := 'Before Books';
         -- Deactivate FA_BOOKS row for processed assets
         FORALL i in t_asset_id.first..t_asset_id.last
            UPDATE FA_BOOKS
            SET    DATE_INEFFECTIVE = p_trans_rec.who_info.last_update_date
                 , TRANSACTION_HEADER_ID_OUT = t_thid(i)
            WHERE  TRANSACTION_HEADER_ID_IN = t_transaction_header_id_in(i);

         l_loc := 'Before Insert Books';
         -- Insert new FA_BOOKS records for processed assets
         FORALL i in t_asset_id.first..t_asset_id.last
            INSERT INTO FA_BOOKS( BOOK_TYPE_CODE
                                , ASSET_ID
                                , DATE_PLACED_IN_SERVICE
                                , DATE_EFFECTIVE
                                , DEPRN_START_DATE
                                , DEPRN_METHOD_CODE
                                , LIFE_IN_MONTHS
                                , RATE_ADJUSTMENT_FACTOR
                                , ADJUSTED_COST
                                , COST
                                , ORIGINAL_COST
                                , SALVAGE_VALUE
                                , PRORATE_CONVENTION_CODE
                                , PRORATE_DATE
                                , COST_CHANGE_FLAG
                                , ADJUSTMENT_REQUIRED_STATUS
                                , CAPITALIZE_FLAG
                                , RETIREMENT_PENDING_FLAG
                                , DEPRECIATE_FLAG
                                , LAST_UPDATE_DATE
                                , LAST_UPDATED_BY
                                , TRANSACTION_HEADER_ID_IN
                                , ITC_AMOUNT_ID
                                , ITC_AMOUNT
                                , RETIREMENT_ID
                                , TAX_REQUEST_ID
                                , ITC_BASIS
                                , BASIC_RATE
                                , ADJUSTED_RATE
                                , BONUS_RULE
                                , CEILING_NAME
                                , RECOVERABLE_COST
                                , LAST_UPDATE_LOGIN
                                , ADJUSTED_CAPACITY
                                , FULLY_RSVD_REVALS_COUNTER
                                , IDLED_FLAG
                                , PERIOD_COUNTER_CAPITALIZED
                                , PERIOD_COUNTER_FULLY_RESERVED
                                , PERIOD_COUNTER_FULLY_RETIRED
                                , PRODUCTION_CAPACITY
                                , REVAL_AMORTIZATION_BASIS
                                , REVAL_CEILING
                                , UNIT_OF_MEASURE
                                , UNREVALUED_COST
                                , ANNUAL_DEPRN_ROUNDING_FLAG
                                , PERCENT_SALVAGE_VALUE
                                , ALLOWED_DEPRN_LIMIT
                                , ALLOWED_DEPRN_LIMIT_AMOUNT
                                , PERIOD_COUNTER_LIFE_COMPLETE
                                , ADJUSTED_RECOVERABLE_COST
                                , ANNUAL_ROUNDING_FLAG
                                , GLOBAL_ATTRIBUTE1
                                , GLOBAL_ATTRIBUTE2
                                , GLOBAL_ATTRIBUTE3
                                , GLOBAL_ATTRIBUTE4
                                , GLOBAL_ATTRIBUTE5
                                , GLOBAL_ATTRIBUTE6
                                , GLOBAL_ATTRIBUTE7
                                , GLOBAL_ATTRIBUTE8
                                , GLOBAL_ATTRIBUTE9
                                , GLOBAL_ATTRIBUTE10
                                , GLOBAL_ATTRIBUTE11
                                , GLOBAL_ATTRIBUTE12
                                , GLOBAL_ATTRIBUTE13
                                , GLOBAL_ATTRIBUTE14
                                , GLOBAL_ATTRIBUTE15
                                , GLOBAL_ATTRIBUTE16
                                , GLOBAL_ATTRIBUTE17
                                , GLOBAL_ATTRIBUTE18
                                , GLOBAL_ATTRIBUTE19
                                , GLOBAL_ATTRIBUTE20
                                , GLOBAL_ATTRIBUTE_CATEGORY
                                , EOFY_ADJ_COST
                                , EOFY_FORMULA_FACTOR
                                , SHORT_FISCAL_YEAR_FLAG
                                , CONVERSION_DATE
                                , ORIGINAL_DEPRN_START_DATE
                                , REMAINING_LIFE1
                                , REMAINING_LIFE2
                                , OLD_ADJUSTED_COST
                                , FORMULA_FACTOR
                                , GROUP_ASSET_ID
                                , SALVAGE_TYPE
                                , DEPRN_LIMIT_TYPE
                                , REDUCTION_RATE
                                , REDUCE_ADDITION_FLAG
                                , REDUCE_ADJUSTMENT_FLAG
                                , REDUCE_RETIREMENT_FLAG
                                , RECOGNIZE_GAIN_LOSS
                                , RECAPTURE_RESERVE_FLAG
                                , LIMIT_PROCEEDS_FLAG
                                , TERMINAL_GAIN_LOSS
                                , TRACKING_METHOD
                                , EXCLUDE_FULLY_RSV_FLAG
                                , EXCESS_ALLOCATION_OPTION
                                , DEPRECIATION_OPTION
                                , MEMBER_ROLLUP_FLAG
                                , ALLOCATE_TO_FULLY_RSV_FLAG
                                , ALLOCATE_TO_FULLY_RET_FLAG
                                , TERMINAL_GAIN_LOSS_AMOUNT
                                , CIP_COST
                                , YTD_PROCEEDS
                                , LTD_PROCEEDS
                                , LTD_COST_OF_REMOVAL
                                , EOFY_RESERVE
                                , PRIOR_EOFY_RESERVE
                                , EOP_ADJ_COST
                                , EOP_FORMULA_FACTOR
                                , EXCLUDE_PROCEEDS_FROM_BASIS
                                , RETIREMENT_DEPRN_OPTION
                                , TERMINAL_GAIN_LOSS_FLAG
                                , SUPER_GROUP_ID
                                , OVER_DEPRECIATE_OPTION
                                , DISABLED_FLAG
            ) SELECT BOOK_TYPE_CODE
                   , ASSET_ID
                   , DATE_PLACED_IN_SERVICE
                   , p_trans_rec.who_info.last_update_date -- DATE_EFFECTIVE
                   , DEPRN_START_DATE
                   , DEPRN_METHOD_CODE
                   , LIFE_IN_MONTHS
                   , RATE_ADJUSTMENT_FACTOR
                   , t_new_adj_cost(i) -- ADJUSTED_COST
                   , COST
                   , ORIGINAL_COST
                   , SALVAGE_VALUE
                   , PRORATE_CONVENTION_CODE
                   , PRORATE_DATE
                   , COST_CHANGE_FLAG
                   , ADJUSTMENT_REQUIRED_STATUS
                   , CAPITALIZE_FLAG
                   , RETIREMENT_PENDING_FLAG
                   , DEPRECIATE_FLAG
                   , p_trans_rec.who_info.last_update_date -- LAST_UPDATE_DATE
                   , p_trans_rec.who_info.last_updated_by -- LAST_UPDATED_BY
                   , t_thid(i) -- TRANSACTION_HEADER_ID_IN
                   , ITC_AMOUNT_ID
                   , ITC_AMOUNT
                   , RETIREMENT_ID
                   , TAX_REQUEST_ID
                   , ITC_BASIS
                   , BASIC_RATE
                   , ADJUSTED_RATE
                   , BONUS_RULE
                   , CEILING_NAME
                   , RECOVERABLE_COST
                   , p_trans_rec.who_info.last_update_login -- LAST_UPDATE_LOGIN
                   , ADJUSTED_CAPACITY
                   , FULLY_RSVD_REVALS_COUNTER
                   , IDLED_FLAG
                   , PERIOD_COUNTER_CAPITALIZED
                   , PERIOD_COUNTER_FULLY_RESERVED
                   , PERIOD_COUNTER_FULLY_RETIRED
                   , PRODUCTION_CAPACITY
                   , REVAL_AMORTIZATION_BASIS
                   , REVAL_CEILING
                   , UNIT_OF_MEASURE
                   , UNREVALUED_COST
                   , ANNUAL_DEPRN_ROUNDING_FLAG
                   , PERCENT_SALVAGE_VALUE
                   , ALLOWED_DEPRN_LIMIT
                   , ALLOWED_DEPRN_LIMIT_AMOUNT
                   , PERIOD_COUNTER_LIFE_COMPLETE
                   , ADJUSTED_RECOVERABLE_COST
                   , ANNUAL_ROUNDING_FLAG
                   , GLOBAL_ATTRIBUTE1
                   , GLOBAL_ATTRIBUTE2
                   , GLOBAL_ATTRIBUTE3
                   , GLOBAL_ATTRIBUTE4
                   , GLOBAL_ATTRIBUTE5
                   , GLOBAL_ATTRIBUTE6
                   , GLOBAL_ATTRIBUTE7
                   , GLOBAL_ATTRIBUTE8
                   , GLOBAL_ATTRIBUTE9
                   , GLOBAL_ATTRIBUTE10
                   , GLOBAL_ATTRIBUTE11
                   , GLOBAL_ATTRIBUTE12
                   , GLOBAL_ATTRIBUTE13
                   , GLOBAL_ATTRIBUTE14
                   , GLOBAL_ATTRIBUTE15
                   , GLOBAL_ATTRIBUTE16
                   , GLOBAL_ATTRIBUTE17
                   , GLOBAL_ATTRIBUTE18
                   , GLOBAL_ATTRIBUTE19
                   , GLOBAL_ATTRIBUTE20
                   , GLOBAL_ATTRIBUTE_CATEGORY
                   , EOFY_ADJ_COST
                   , EOFY_FORMULA_FACTOR
                   , SHORT_FISCAL_YEAR_FLAG
                   , CONVERSION_DATE
                   , ORIGINAL_DEPRN_START_DATE
                   , REMAINING_LIFE1
                   , REMAINING_LIFE2
                   , OLD_ADJUSTED_COST
                   , FORMULA_FACTOR
                   , GROUP_ASSET_ID
                   , SALVAGE_TYPE
                   , DEPRN_LIMIT_TYPE
                   , REDUCTION_RATE
                   , REDUCE_ADDITION_FLAG
                   , REDUCE_ADJUSTMENT_FLAG
                   , REDUCE_RETIREMENT_FLAG
                   , RECOGNIZE_GAIN_LOSS
                   , RECAPTURE_RESERVE_FLAG
                   , LIMIT_PROCEEDS_FLAG
                   , TERMINAL_GAIN_LOSS
                   , TRACKING_METHOD
                   , EXCLUDE_FULLY_RSV_FLAG
                   , EXCESS_ALLOCATION_OPTION
                   , DEPRECIATION_OPTION
                   , MEMBER_ROLLUP_FLAG
                   , ALLOCATE_TO_FULLY_RSV_FLAG
                   , ALLOCATE_TO_FULLY_RET_FLAG
                   , TERMINAL_GAIN_LOSS_AMOUNT
                   , CIP_COST
                   , YTD_PROCEEDS
                   , LTD_PROCEEDS
                   , LTD_COST_OF_REMOVAL
                   , EOFY_RESERVE
                   , PRIOR_EOFY_RESERVE
                   , EOP_ADJ_COST
                   , EOP_FORMULA_FACTOR
                   , EXCLUDE_PROCEEDS_FROM_BASIS
                   , RETIREMENT_DEPRN_OPTION
                   , TERMINAL_GAIN_LOSS_FLAG
                   , SUPER_GROUP_ID
                   , OVER_DEPRECIATE_OPTION
                   , DISABLED_FLAG
              FROM  FA_BOOKS
              WHERE TRANSACTION_HEADER_ID_IN = t_transaction_header_id_in(i);

      end if; -- (p_mrc_sob_type_code = 'R')

      -- flush the rows to the db
      l_adj.transaction_header_id := 0;
      l_adj.flush_adj_flag        := TRUE;
      l_adj.leveling_flag         := TRUE;
      l_adj.mrc_sob_type_code     :=  p_mrc_sob_type_code;
      l_adj.set_of_books_id         := p_asset_hdr_rec.set_of_books_id;

      if not FA_INS_ADJUST_PKG.faxinaj
             (l_adj,
              p_trans_rec.who_info.last_update_date,
              p_trans_rec.who_info.last_updated_by,
              p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
         raise allocate_err;
      end if;

      -- As of now, following commit is commented out.
      -- It may be necessary in future if we see pl/sql table used in this function
      -- caused memory problem.
--      COMMIT;
   END LOOP; -- MAIN OUTER LOOP

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'End of Main Loop', p_reserve_amount - l_actual_rsv_total, p_log_level_rec => p_log_level_rec);
   end if;

   if (l_actual_rsv_total = p_reserve_amount) then
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'End of allocation', ' ', p_log_level_rec => p_log_level_rec);
      end if;

      return TRUE;

   end if;

    /* Bug 8633654 */
            if (nvl(l_actual_rsv_total,0) = 0 and p_trans_rec.transaction_key = 'MR') then
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'No member to allocate', ' ',p_log_level_rec);
               end if;

               return TRUE;

            end if;

   --
   -- If process reaches to this point, it means that reinstatement could not
   -- reinstate all amounts because member at the time of retirement does not exist
   -- or could not reinstate the reserve because some member become fully reserved.
   if (p_trans_rec.transaction_key = 'MS') and
      (p_mode = 'NORMAL') then
      -- Call Do_Allocation again to distribute remaining amounts
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Recurrsive Call Do_Allocation', 'Calling...', p_log_level_rec => p_log_level_rec);
      end if;
--toru
      if not Do_Allocation(
                      p_trans_rec         => p_trans_rec,
                      p_asset_hdr_rec     => p_asset_hdr_rec,
                      p_asset_fin_rec     => p_asset_fin_rec,
                      p_asset_deprn_rec_new => p_asset_deprn_rec_new, -- group new deprn rec
                      p_period_rec        => p_period_rec,
                      p_reserve_amount    => -1 *(p_reserve_amount - l_actual_rsv_total),
                      p_mode              => 'RECURR',
                      p_mrc_sob_type_code => p_mrc_sob_type_code,
                      p_mem_ret_thid      => p_mem_ret_thid,
                      p_calling_fn        => l_calling_fn,
                      p_log_level_rec       => p_log_level_rec) then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Recurrsive Call to Do_Allocation', 'Failed', p_log_level_rec => p_log_level_rec);
         end if;

         raise allocate_err;
      end if;

      return TRUE;
   end if;

   -- This portion of code is necessary to distribute fraction
   -- produced during allocation process above.
   -- For performance reason (to avoid issuing sql) reuse what's in pl/sql table now
   -- If there is a difference between
   if (p_reserve_amount <> l_actual_rsv_total) then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Inside rounding correction', ' ',p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'p_reserve_amount', p_reserve_amount,p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_actual_rsv_total', l_actual_rsv_total,p_log_level_rec);
      end if;

      if (p_reserve_amount > 0) then
         l_reallocate_amount := p_reserve_amount - l_actual_rsv_total;
      else
         l_reallocate_amount := l_actual_rsv_total - p_reserve_amount;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'l_reallocate_amount', l_reallocate_amount,p_log_level_rec);
      end if;

      -- First, if it needs to take out some reserve, then do that against
      -- last processed asset. If not, then first go through the assets in
      -- pl/sql table to check for the same. if not done yet, hit db to do the same.
      if (p_reserve_amount < 0 or
          p_reserve_amount < l_actual_rsv_total) then

          if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Rounding : Takeout some resv', ' ',p_log_level_rec);
          end if;

         -- Need to backout some reserve so do that from last processed asset

         if (p_mrc_sob_type_code = 'R') then
            UPDATE FA_MC_ADJUSTMENTS
            SET    ADJUSTMENT_AMOUNT = ADJUSTMENT_AMOUNT + l_reallocate_amount
            WHERE  ASSET_ID = l_last_asset_id
            AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
            AND    TRANSACTION_HEADER_ID = l_last_thid
            AND    DISTRIBUTION_ID = (SELECT MIN(DISTRIBUTION_ID)
                                      FROM   FA_MC_ADJUSTMENTS
                                      WHERE  ASSET_ID = l_last_asset_id
                                      AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
                                      AND    TRANSACTION_HEADER_ID = l_last_thid
                                      AND    set_of_books_id = p_asset_hdr_rec.set_of_books_id)
            AND    set_of_books_id = p_asset_hdr_rec.set_of_books_id;

            UPDATE FA_MC_BOOKS_SUMMARY
            SET    RESERVE_ADJUSTMENT_AMOUNT = RESERVE_ADJUSTMENT_AMOUNT + ( l_reallocate_amount * sign(p_reserve_amount) * -1 )
                 , DEPRN_RESERVE = DEPRN_RESERVE + ( l_reallocate_amount * sign(p_reserve_amount) * -1 )
                 , ADJUSTED_COST = ADJUSTED_COST - ( l_reallocate_amount * sign(p_reserve_amount) * -1 )
            WHERE  ASSET_ID = l_last_asset_id
            AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
            AND    PERIOD_COUNTER = p_period_rec.period_counter
            AND    TRANSACTION_HEADER_ID_OUT IS NULL
            AND    set_of_books_id = p_asset_hdr_rec.set_of_books_id;


            UPDATE FA_MC_BOOKS
            SET    ADJUSTED_COST = ADJUSTED_COST - ( l_reallocate_amount * sign(p_reserve_amount) * -1 )
            WHERE  TRANSACTION_HEADER_ID_IN = l_last_thid
              AND  set_of_books_id = p_asset_hdr_rec.set_of_books_id;
         else
            UPDATE FA_ADJUSTMENTS
            SET    ADJUSTMENT_AMOUNT = ADJUSTMENT_AMOUNT + l_reallocate_amount
            WHERE  ASSET_ID = l_last_asset_id
            AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
            AND    TRANSACTION_HEADER_ID = l_last_thid
            AND    DISTRIBUTION_ID = (SELECT MIN(DISTRIBUTION_ID)
                                      FROM   FA_ADJUSTMENTS
                                      WHERE  ASSET_ID = l_last_asset_id
                                      AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
                                      AND    TRANSACTION_HEADER_ID = l_last_thid);

            UPDATE FA_BOOKS_SUMMARY
            SET    RESERVE_ADJUSTMENT_AMOUNT = RESERVE_ADJUSTMENT_AMOUNT + ( l_reallocate_amount * sign(p_reserve_amount) * -1 )
                 , DEPRN_RESERVE = DEPRN_RESERVE + ( l_reallocate_amount * sign(p_reserve_amount) * -1 )
                 , ADJUSTED_COST = ADJUSTED_COST - ( l_reallocate_amount * sign(p_reserve_amount) * -1 )
            WHERE  ASSET_ID = l_last_asset_id
            AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
            AND    PERIOD_COUNTER = p_period_rec.period_counter
            AND    TRANSACTION_HEADER_ID_OUT IS NULL;


            UPDATE FA_BOOKS
            SET    ADJUSTED_COST = ADJUSTED_COST - ( l_reallocate_amount * sign(p_reserve_amount) * -1 )
            WHERE  TRANSACTION_HEADER_ID_IN = l_last_thid;
         end if; -- (p_mrc_sob_type_code = 'R')
      else

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Rounding : Add additional resv', ' ',p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'Rounding : current PL_SQL count', t_asset_id.count,p_log_level_rec);
         end if;

         -- Need to hit db to allocate excess amount if any at this point.
         -- Basically, do the same thing done in above loop but this time against
         -- data in db.
         if (l_reallocate_amount <> 0) then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Rounding : reallocate_amount at 2', l_reallocate_amount,p_log_level_rec);
            end if;

            t_thid.delete;
            t_asset_id.delete;
            t_adjusted_cost.delete;

            if (p_mrc_sob_type_code = 'R') then
               OPEN C_MC_DIST_EXCESS;
            else
               OPEN C_DIST_EXCESS;
            end if;

            LOOP -- *** DIST EXCESS OUTER LOOP **

               if (l_reallocate_amount = 0) then
                  if (p_mrc_sob_type_code = 'R') then
                     CLOSE C_MC_DIST_EXCESS;
                  else
                     CLOSE C_DIST_EXCESS;
                  end if;
                  EXIT;
               end if;

               if (p_mrc_sob_type_code = 'R') then
                  FETCH C_MC_DIST_EXCESS BULK COLLECT INTO t_asset_id
                                                      , t_thid
                                                      , t_adjusted_cost LIMIT l_limit;
               else
                  FETCH C_DIST_EXCESS BULK COLLECT INTO t_asset_id
                                                      , t_thid
                                                      , t_adjusted_cost LIMIT l_limit;
               end if;

               if (t_asset_id.count = 0) then
                  if (p_mrc_sob_type_code = 'R') then
                     CLOSE C_MC_DIST_EXCESS;
                  else
                     CLOSE C_DIST_EXCESS;
                  end if;
                  EXIT;
               end if;

               FOR i in t_asset_id.first..t_asset_id.last LOOP

                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Rounding 2 : ', i,p_log_level_rec);
                     fa_debug_pkg.add(l_calling_fn, 'Rounding 2 : t_asset_id('||i||')', t_asset_id(i),p_log_level_rec);
                     fa_debug_pkg.add(l_calling_fn, 'Rounding 2 : t_adjusted_cost('||i||')', t_adjusted_cost(i),p_log_level_rec);
                  end if;

                  if (t_adjusted_cost(i) >= l_reallocate_amount) then

                     if (p_log_level_rec.statement_level) then
                        fa_debug_pkg.add(l_calling_fn, 'Rounding 2 : Adjust reallocate_amount ',' ',p_log_level_rec);
                     end if;

                     if (p_mrc_sob_type_code = 'R') then
                        UPDATE FA_MC_ADJUSTMENTS
                        SET    ADJUSTMENT_AMOUNT = ADJUSTMENT_AMOUNT + l_reallocate_amount
                        WHERE  ASSET_ID = t_asset_id(i)
                        AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
                        AND    TRANSACTION_HEADER_ID = t_thid(i)
                        AND    set_of_books_id = p_asset_hdr_rec.set_of_books_id
                        AND    DISTRIBUTION_ID = (SELECT MIN(DISTRIBUTION_ID)
                                                  FROM   FA_MC_ADJUSTMENTS
                                                  WHERE  ASSET_ID = t_asset_id(i)
                                                  AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
                                                  AND    set_of_books_id = p_asset_hdr_rec.set_of_books_id
                                                  AND    TRANSACTION_HEADER_ID = t_thid(i));

                        UPDATE FA_MC_BOOKS_SUMMARY
                        SET    RESERVE_ADJUSTMENT_AMOUNT = RESERVE_ADJUSTMENT_AMOUNT + (l_reallocate_amount * sign(p_reserve_amount) * -1)
                             , DEPRN_RESERVE = DEPRN_RESERVE + (l_reallocate_amount * sign(p_reserve_amount) * -1)
                             , ADJUSTED_COST = ADJUSTED_COST + l_reallocate_amount
                        WHERE  ASSET_ID = t_asset_id(i)
                        AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
                        AND    PERIOD_COUNTER = p_period_rec.period_counter
                        AND    set_of_books_id = p_asset_hdr_rec.set_of_books_id
                        AND    TRANSACTION_HEADER_ID_OUT is null;


                        UPDATE FA_MC_BOOKS
                        SET    ADJUSTED_COST = ADJUSTED_COST + l_reallocate_amount
                        WHERE  TRANSACTION_HEADER_ID_IN = t_thid(i)
                          AND  set_of_books_id = p_asset_hdr_rec.set_of_books_id;
                     else
                        if (p_log_level_rec.statement_level) then
                           fa_debug_pkg.add(l_calling_fn, 'Rounding 2 : adj rallocate ',(l_reallocate_amount * sign(p_reserve_amount) * -1),p_log_level_rec);
                        end if;

                        UPDATE FA_ADJUSTMENTS
                        SET    ADJUSTMENT_AMOUNT = ADJUSTMENT_AMOUNT + l_reallocate_amount
                        WHERE  ASSET_ID = t_asset_id(i)
                        AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
                        AND    TRANSACTION_HEADER_ID = t_thid(i)
                        AND    DISTRIBUTION_ID = (SELECT MIN(DISTRIBUTION_ID)
                                                  FROM   FA_ADJUSTMENTS
                                                  WHERE  ASSET_ID = t_asset_id(i)
                                                  AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
                                                  AND    TRANSACTION_HEADER_ID = t_thid(i));

                        UPDATE FA_BOOKS_SUMMARY
                        SET    RESERVE_ADJUSTMENT_AMOUNT = RESERVE_ADJUSTMENT_AMOUNT + (l_reallocate_amount * sign(p_reserve_amount) * -1)
                             , DEPRN_RESERVE = DEPRN_RESERVE + (l_reallocate_amount * sign(p_reserve_amount) * -1)
                             , ADJUSTED_COST = ADJUSTED_COST + l_reallocate_amount
                        WHERE  ASSET_ID = t_asset_id(i)
                        AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
                        AND    PERIOD_COUNTER = p_period_rec.period_counter
                        AND    TRANSACTION_HEADER_ID_OUT is null;


                        UPDATE FA_BOOKS
                        SET    ADJUSTED_COST = ADJUSTED_COST + l_reallocate_amount
                        WHERE  TRANSACTION_HEADER_ID_IN = t_thid(i);
                     end if;

                     l_reallocate_amount := 0;

                  else

                     if (p_mrc_sob_type_code = 'R') then
                        UPDATE FA_MC_ADJUSTMENTS
                        SET    ADJUSTMENT_AMOUNT = ADJUSTMENT_AMOUNT + t_adjusted_cost(i)
                        WHERE  ASSET_ID = t_asset_id(i)
                        AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
                        AND    TRANSACTION_HEADER_ID = t_thid(i)
                        AND    set_of_books_id = p_asset_hdr_rec.set_of_books_id
                        AND    DISTRIBUTION_ID = (SELECT MIN(DISTRIBUTION_ID)
                                                  FROM   FA_MC_ADJUSTMENTS
                                                  WHERE  ASSET_ID = t_asset_id(i)
                                                  AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
                                                  AND    set_of_books_id = p_asset_hdr_rec.set_of_books_id
                                                  AND    TRANSACTION_HEADER_ID = t_thid(i));

                        UPDATE FA_MC_BOOKS_SUMMARY
                        SET    RESERVE_ADJUSTMENT_AMOUNT = RESERVE_ADJUSTMENT_AMOUNT + t_adjusted_cost(i)
                             , DEPRN_RESERVE = ADJUSTED_RECOVERABLE_COST
                             , ADJUSTED_COST = RECOVERABLE_COST - ADJUSTED_RECOVERABLE_COST
                        WHERE  ASSET_ID = t_asset_id(i)
                        AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
                        AND    set_of_books_id = p_asset_hdr_rec.set_of_books_id
                        AND    PERIOD_COUNTER = p_period_rec.period_counter;


                        UPDATE FA_MC_BOOKS
                        SET    ADJUSTED_COST = RECOVERABLE_COST - ADJUSTED_RECOVERABLE_COST
                        WHERE  TRANSACTION_HEADER_ID_IN = t_thid(i)
                          AND  set_of_books_id = p_asset_hdr_rec.set_of_books_id;
                     else
                        UPDATE FA_ADJUSTMENTS
                        SET    ADJUSTMENT_AMOUNT = ADJUSTMENT_AMOUNT + t_adjusted_cost(i)
                        WHERE  ASSET_ID = t_asset_id(i)
                        AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
                        AND    TRANSACTION_HEADER_ID = t_thid(i)
                        AND    DISTRIBUTION_ID = (SELECT MIN(DISTRIBUTION_ID)
                                                  FROM   FA_ADJUSTMENTS
                                                  WHERE  ASSET_ID = t_asset_id(i)
                                                  AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
                                                  AND    TRANSACTION_HEADER_ID = t_thid(i));

                        UPDATE FA_BOOKS_SUMMARY
                        SET    RESERVE_ADJUSTMENT_AMOUNT = RESERVE_ADJUSTMENT_AMOUNT + t_adjusted_cost(i)
                             , DEPRN_RESERVE = ADJUSTED_RECOVERABLE_COST
                             , ADJUSTED_COST = RECOVERABLE_COST - ADJUSTED_RECOVERABLE_COST
                        WHERE  ASSET_ID = t_asset_id(i)
                        AND    BOOK_TYPE_CODE = p_asset_hdr_rec.book_type_code
                        AND    PERIOD_COUNTER = p_period_rec.period_counter;


                        UPDATE FA_BOOKS
                        SET    ADJUSTED_COST = RECOVERABLE_COST - ADJUSTED_RECOVERABLE_COST
                        WHERE  TRANSACTION_HEADER_ID_IN = t_thid(i);
                     end if;

                     l_reallocate_amount := l_reallocate_amount - t_adjusted_cost(i);
                  end if; -- (t_adjusted_recoverable_cost(i) -  t_new_deprn_reserve(i) >= l_reallocate_amount)

                  if (l_reallocate_amount = 0) then
                     EXIT;
                  end if;


               END LOOP; -- FOR i in t_asset_id.first..t_asset_id.last

            END LOOP; -- *** DIST EXCESS OUTER LOOP ***

         end if;

      end if; -- (p_reserve_amount < 0 or

   end if; -- (p_reserve_amount <> l_actual_rsv_total)


   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'End', p_reserve_amount, p_log_level_rec => p_log_level_rec);
   end if;

   return true;

EXCEPTION
   WHEN OTHERS THEN
    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'l_loc', l_loc, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'End', 'Failed'||':'||sqlerrm, p_log_level_rec => p_log_level_rec);
    end if;

    fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
    return false;

END Do_Allocation;


END FA_RETIREMENT_PVT;

/
