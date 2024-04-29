--------------------------------------------------------
--  DDL for Package Body FA_GROUP_RECLASS2_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_GROUP_RECLASS2_PVT" AS
/* $Header: FAVGRECB.pls 120.51.12010000.13 2009/10/26 09:47:01 gigupta ship $ */

g_release                  number  := fa_cache_pkg.fazarel_release;

TYPE num_tbl  IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;
TYPE date_tbl IS TABLE OF DATE         INDEX BY BINARY_INTEGER;
TYPE v30_tbl  IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

FUNCTION do_group_reclass
   (p_trans_rec               IN     FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec          IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec           IN     FA_API_TYPES.asset_cat_rec_type,
    px_src_trans_rec          IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_src_asset_hdr_rec      IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_src_asset_desc_rec      IN     FA_API_TYPES.asset_desc_rec_type,
    p_src_asset_type_rec      IN     FA_API_TYPES.asset_type_rec_type,
    p_src_asset_cat_rec       IN     FA_API_TYPES.asset_cat_rec_type,
    px_dest_trans_rec         IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_dest_asset_hdr_rec     IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_dest_asset_desc_rec     IN     FA_API_TYPES.asset_desc_rec_type,
    p_dest_asset_type_rec     IN     FA_API_TYPES.asset_type_rec_type,
    p_dest_asset_cat_rec      IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_new       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_old     IN     FA_API_TYPES.asset_deprn_rec_type,
    p_asset_deprn_rec_adj     IN     FA_API_TYPES.asset_deprn_rec_type,
    p_asset_deprn_rec_new     IN     FA_API_TYPES.asset_deprn_rec_type,
    px_group_reclass_options_rec IN OUT NOCOPY FA_API_TYPES.group_reclass_options_rec_type,
    p_period_rec              IN     FA_API_TYPES.period_rec_type,
    p_mrc_sob_type_code       IN     VARCHAR2,
    p_calling_fn              IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS


   l_src_asset_hdr_rec          fa_api_types.asset_hdr_rec_type;
   l_src_asset_desc_rec         fa_api_types.asset_desc_rec_type;
   l_src_asset_type_rec         fa_api_types.asset_type_rec_type;
   l_src_asset_cat_rec          fa_api_types.asset_cat_rec_type;
   l_src_asset_fin_rec_old      fa_api_types.asset_fin_rec_type;
   l_src_asset_fin_rec_adj      fa_api_types.asset_fin_rec_type;
   l_src_asset_fin_rec_new      fa_api_types.asset_fin_rec_type;
   l_src_asset_deprn_rec_old    fa_api_types.asset_deprn_rec_type;
   l_src_asset_deprn_rec_adj    fa_api_types.asset_deprn_rec_type;
   l_src_asset_deprn_rec_new    fa_api_types.asset_deprn_rec_type;

   l_dest_asset_hdr_rec         fa_api_types.asset_hdr_rec_type;
   l_dest_asset_desc_rec        fa_api_types.asset_desc_rec_type;
   l_dest_asset_type_rec        fa_api_types.asset_type_rec_type;
   l_dest_asset_cat_rec         fa_api_types.asset_cat_rec_type;
   l_dest_asset_fin_rec_old     fa_api_types.asset_fin_rec_type;
   l_dest_asset_fin_rec_adj     fa_api_types.asset_fin_rec_type;
   l_dest_asset_fin_rec_new     fa_api_types.asset_fin_rec_type;
   l_dest_asset_deprn_rec_old   fa_api_types.asset_deprn_rec_type;
   l_dest_asset_deprn_rec_adj   fa_api_types.asset_deprn_rec_type;
   l_dest_asset_deprn_rec_new   fa_api_types.asset_deprn_rec_type;

   l_inv_trans_rec              fa_api_types.inv_trans_rec_type;
   l_null_dist_tbl              FA_API_TYPES.asset_dist_tbl_type;

   l_transaction_date           date;
   l_group_reclass_code         varchar2(20);

   l_trx_reference_id           number;
   l_return_status              boolean;
   l_rowid                      varchar2(200);

   l_calling_fn                 VARCHAR2(35) := 'fa_group_reclass_pvt.do_grp_reclass';

   -- BUG# 6936546
   l_api_version                NUMBER      := 1.0;
   l_init_msg_list              VARCHAR2(1) := FND_API.G_FALSE;
   l_commit                     VARCHAR2(1) := FND_API.G_FALSE;
   l_validation_level           NUMBER      := FND_API.G_VALID_LEVEL_NONE;
   l_return_status2             VARCHAR2(1);
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(2000);
   l_trans_rec                  FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec              FA_API_TYPES.asset_hdr_rec_type :=
                                   p_asset_hdr_rec;
   l_asset_dist_tbl             FA_API_TYPES.asset_dist_tbl_type;

   l_distribution_id            num_tbl;
   l_units_assigned             num_tbl;
   l_code_combination_id        num_tbl;
   l_location_id                num_tbl;
   l_assigned_to                num_tbl;

   l_transfer_amount            NUMBER;
   l_reserve_amt                NUMBER;

   cursor c_member_dists (p_asset_id number) is
   select distribution_id,
          units_assigned,
          code_combination_id,
          location_id,
          assigned_to
     from fa_distribution_history
    where asset_id = p_asset_id
      and transaction_header_id_out is null;

   --Bug6987743: Getting previously transfered reserve
   cursor c_get_reserve is
      select nvl(reserve_transfer_amount, 0)
      from fa_trx_references
      where dest_asset_id = l_src_asset_hdr_rec.asset_id
      and   member_asset_id = p_asset_hdr_rec.asset_id
      and   book_type_code = p_asset_hdr_rec.book_type_code
      order by trx_reference_id desc;


   -- used for faxinaj calls
   l_rsv_adj                    FA_ADJUST_TYPE_PKG.fa_adj_row_struct;

   grp_rec_err                  exception;


BEGIN

   fa_debug_pkg.add(l_calling_fn, 'src exp amount', px_group_reclass_options_rec.source_exp_amount, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.add(l_calling_fn, 'dest exp amount', px_group_reclass_options_rec.destination_exp_amount, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.add(l_calling_fn, 'reserve amount',  px_group_reclass_options_rec.reserve_amount, p_log_level_rec => p_log_level_rec);
   fa_debug_pkg.add(l_calling_fn, 'p_trans_rec.amort_start_date',  p_trans_rec.amortization_start_date, p_log_level_rec => p_log_level_rec);

   -- note that adjustments to both expense and reserve will be handled
   -- here in and not in the adjustment api/calc engine (via faadjust)
   -- note this code will be bypassed by a cominbation of the following:
   --
   -- trx_type = 'GROUP RECLASS'
   -- trx_subtype = ''
   --

   -- note that we need to investigate / determine transaction subtype and track member impacts!!!!
   -- including merging this into the adjustment API
   --
   -- how to handle amort start / trx_date , etc on the member in all three scenarios
   --  - the transaction date currently must be equal among all three
   --  - validate / prevent it exceeding the dpis of member and or group
   --  - should be able to "expense" the adjustment on the member when
   --    pulling it out of a group (per last discussion on UI)
   --    thus when amort comes in as expense, we need to
   --    set to amort for group leave as expensed for member


-- use this
   -- *** VERIFY THE TWO GROUP TRX APP CALLS - they may too expensive
   --     though some form of locking is required ***
   -- now doen in the calling public api

   -- verify a change in group is occurring / otherwise error out
   -- store the "reclass code" for easy reference at various
   -- points in the api
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'p_asset_fin_rec_old.group_asset_id', p_asset_fin_rec_old.group_asset_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_asset_fin_rec_adj.group_asset_id', p_asset_fin_rec_adj.group_asset_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_asset_fin_rec_new.group_asset_id', p_asset_fin_rec_new.group_asset_id, p_log_level_rec => p_log_level_rec);
   end if;


   if (nvl(p_asset_fin_rec_old.group_asset_id, -99) = nvl(p_asset_fin_rec_new.group_asset_id, -99)) then

      raise grp_rec_err;
   elsif (p_asset_fin_rec_old.group_asset_id is not null and
          p_asset_fin_rec_new.group_asset_id is not null) then
      l_group_reclass_code := 'GRP-GRP';
   elsif (p_asset_fin_rec_old.group_asset_id is not null) then
      l_group_reclass_code := 'GRP-NONE';
   else
      l_group_reclass_code := 'NONE-GRP';
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'reclass code', l_group_reclass_code, p_log_level_rec => p_log_level_rec);
   end if;

   -- validate intercompany impacts before doing anything else
   if (l_group_reclass_code <> 'GRP-NONE' and
      nvl(fa_cache_pkg.fazcbc_record.allow_interco_group_flag, 'N') <> 'Y') then

      if not fa_interco_pvt.validate_grp_interco
                   (p_asset_hdr_rec    => p_asset_hdr_rec,
                    p_trans_rec        => p_trans_rec,
                    p_asset_type_rec   => p_asset_type_rec,
                    p_group_asset_id   => px_dest_asset_hdr_rec.asset_id,
                    p_asset_dist_tbl   => l_null_dist_tbl,
                    p_calling_fn       => l_calling_fn, p_log_level_rec => p_log_level_rec) then
         raise grp_rec_err;
      end if;
   end if;

   -- do not allow reclasses from or to none in conjunction with manual amounts
   -- this is still questionable - refernece open issues as we could
   -- do this by performing two calculations/insert branches:
   --   1) inserting the manual amount
   --   2) taking the difference between oracle's calc and the entered amount
   --
   -- this would allow the effective "backdating" of a group reclass
   -- where the amount entered is < reserve (NONE->GRP)


--         if ((l_group_reclass_code = 'GRP-NONE' or l_group_reclass_code = 'NONE-GRP') and
--             (p_group_reclass_options_rec.group_reclass_type = 'MANUAL-EXP' or
--              p_group_reclass_options_rec.group_reclass_type = 'MANUAL-RES')) then
--            raise grp_rec_err;
--         end if;

   -- Do not allow amort date is not either DPIS of member asset to be reclassified
   -- or current date in case of the group asset id defined as Year End Balance
   -- Method.

   -- For Source Group
   -- Populate Subtract Ytd Flag
   if not fa_cache_pkg.fazccmt(X_method => p_asset_fin_rec_old.deprn_method_code,
                                  X_life => p_asset_fin_rec_old.life_in_months, p_log_level_rec => p_log_level_rec) then
     raise grp_rec_err;
   end if;

   if nvl(fa_cache_pkg.fazcdrd_record.subtract_ytd_flag,'N') = 'Y' and
      p_trans_rec.amortization_start_date <> p_asset_fin_rec_old.date_placed_in_service and
      p_trans_rec.amortization_start_date < p_period_rec.calendar_period_open_date then
     fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                                name => '***FA_AMORT_DATE_SUB***',
                   p_log_level_rec => p_log_level_rec);
     return false;
     raise grp_rec_err;
   end if;

   -- For Target Group
   -- Populate Subtract Ytd Flag
   if not fa_cache_pkg.fazccmt(X_method => p_asset_fin_rec_new.deprn_method_code,
                               X_life => p_asset_fin_rec_new.life_in_months, p_log_level_rec => p_log_level_rec) then
     raise grp_rec_err;
   end if;

   if nvl(fa_cache_pkg.fazcdrd_record.subtract_ytd_flag,'N') = 'Y' and
      p_trans_rec.amortization_start_date <> p_asset_fin_rec_old.date_placed_in_service and
      p_trans_rec.amortization_start_date < p_period_rec.calendar_period_open_date then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                              name => '***FA_AMORT_DATE_SUB***',
                   p_log_level_rec => p_log_level_rec);
      raise grp_rec_err;
   end if;

   -- now process the group(s) and or deprn / reserve impacts
   --
   -- open issues in terms of sequence when you are combining
   -- a cost change with a change in group in the same transaction
   --
   -- option1:   backout old.cost only
   -- option2:   perform adj for cost change, then backout the total new cost

   -- Bug#3737670
   -- get the old fin and deprn information of destination group

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'px_dest_asset_hdr_rec.asset_id:book_type_code',px_dest_asset_hdr_rec.asset_id||':'||
                                                                                     px_dest_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
   end if;

   if l_group_reclass_code <> 'GRP-NONE' then
     if not FA_UTIL_PVT.get_asset_fin_rec
              (p_asset_hdr_rec         => px_dest_asset_hdr_rec,
               px_asset_fin_rec        => l_dest_asset_fin_rec_old,
               p_transaction_header_id => NULL,
               p_mrc_sob_type_code     => p_mrc_sob_type_code
              , p_log_level_rec => p_log_level_rec) then raise grp_rec_err;
     end if;
   end if;


   ------------
   -- SOURCE --
   ------------

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'processing','source asset', p_log_level_rec => p_log_level_rec);
   end if;

   -- For Source Group
   -- Populate Subtract Ytd Flag
   if not fa_cache_pkg.fazccmt(X_method => p_asset_fin_rec_old.deprn_method_code,
                               X_life => p_asset_fin_rec_old.life_in_months, p_log_level_rec => p_log_level_rec) then
      raise grp_rec_err;
   end if;


   -- If the asset was moved out of a group, deduct the asset's cost from the old group
   if p_asset_fin_rec_old.group_asset_id is not null then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'source is','group', p_log_level_rec => p_log_level_rec);
      end if;

      l_src_asset_hdr_rec       := px_src_asset_hdr_rec;
      l_src_asset_desc_rec      := p_src_asset_desc_rec;
      l_src_asset_type_rec      := p_src_asset_type_rec;
      l_src_asset_cat_rec       := p_src_asset_cat_rec;

      -- load the delta cost for the group with the -ve cost of the member
      -- NOTE: iniital test we'll use the od cost and not increment the
      --       source group's cost first in the case of a combo cost/reclass

      if (p_asset_type_rec.asset_type = 'CIP') then
         l_src_asset_fin_rec_adj.cost     := -(p_asset_fin_rec_old.cost - p_asset_fin_rec_old.cip_cost);
         l_src_asset_fin_rec_adj.cip_cost := -p_asset_fin_rec_old.cip_cost;
      else
         l_src_asset_fin_rec_adj.cost := -p_asset_fin_rec_old.cost;
      end if;

      if (p_mrc_sob_type_code <> 'R') then

         -- set up the group recs
         px_src_trans_rec                              := p_trans_rec;
         px_src_trans_rec.member_transaction_header_id := p_trans_rec.transaction_header_id;
         px_src_trans_rec.transaction_type_code        := 'GROUP ADJUSTMENT';
         px_src_trans_rec.member_transaction_header_id := p_trans_rec.transaction_header_id;
         px_src_trans_rec.transaction_subtype          := 'AMORTIZED';
         px_src_trans_rec.transaction_key              := 'GC';

         if (p_trans_rec.amortization_start_date is not null) then
            px_src_trans_rec.transaction_date_entered     := p_trans_rec.amortization_start_date;
         end if;

         select fa_transaction_headers_s.nextval
           into px_src_trans_rec.transaction_header_id
           from dual;

      end if;

      -- get the old fin and deprn information
      if not FA_UTIL_PVT.get_asset_fin_rec
                 (p_asset_hdr_rec         => px_src_asset_hdr_rec,
                  px_asset_fin_rec        => l_src_asset_fin_rec_old,
                  p_transaction_header_id => NULL,
                  p_mrc_sob_type_code     => p_mrc_sob_type_code
                 , p_log_level_rec => p_log_level_rec) then raise grp_rec_err;
      end if;
      /* Bug#8640802  */
      if nvl(l_src_asset_fin_rec_old.member_rollup_flag,'N') = 'Y' and px_group_reclass_options_rec.group_reclass_type = 'MANUAL' then
         fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                              name => 'FA_INVALID_RECLASS_TRX',
                              p_log_level_rec => p_log_level_rec);
         raise grp_rec_err;
      end if;
      --HH Validate disabled_flag
      --Reject transaction if src group is disabled
      if not FA_ASSET_VAL_PVT.validate_disabled_flag
                  (p_group_asset_id => l_src_asset_fin_rec_old.group_asset_id,
                   p_book_type_code => px_src_asset_hdr_rec.book_type_code,
                   p_old_flag       => l_src_asset_fin_rec_old.disabled_flag,
                   p_new_flag       => l_src_asset_fin_rec_old.disabled_flag
                  , p_log_level_rec => p_log_level_rec) then
         raise grp_rec_err;
      end if; --End HH

      if not FA_UTIL_PVT.get_asset_deprn_rec
                 (p_asset_hdr_rec         => px_src_asset_hdr_rec,
                  px_asset_deprn_rec      => l_src_asset_deprn_rec_old,
                  p_period_counter        => NULL,
                  p_mrc_sob_type_code     => p_mrc_sob_type_code
                 , p_log_level_rec => p_log_level_rec) then raise grp_rec_err;
      end if;

      -- If the deprn basis rule is defined as Year End Balance type,
      -- new adjusted cost must be calculated based on the entered eofy_reserve
      -- Need to set adj.eofy_reserve
--    if nvl(fa_cache_pkg.fazcdrd_record.subtract_ytd_flag,'N') = 'Y' then
         l_src_asset_fin_rec_adj.eofy_reserve := (-1)*nvl(px_group_reclass_options_rec.source_eofy_reserve,0);
--    end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'l_src_asset_fin_rec_old.eofy_reserve',
                          l_src_asset_fin_rec_old.eofy_reserve, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_src_asset_fin_rec_adj.eofy_reserve',
                          l_src_asset_fin_rec_adj.eofy_reserve, p_log_level_rec => p_log_level_rec);
      end if;

      -- now process the adjustment on the group
      -- raf / adjusted_cost to be updated later

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'source is','group', p_log_level_rec => p_log_level_rec);
      end if;


      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'amort start date2',p_trans_rec.amortization_start_date , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'amort start date2a',px_src_trans_rec.amortization_start_date , p_log_level_rec => p_log_level_rec);
      end if;

      --
      -- Initialize Member Tables
      --
      FA_AMORT_PVT.initMemberTable;

      --
      -- Bug3537474:  pass reserve entered by user to pass it to faxama.
      --
      if px_group_reclass_options_rec.group_reclass_type = 'MANUAL' then
         l_src_asset_deprn_rec_adj.deprn_reserve := -1 * px_group_reclass_options_rec.reserve_amount;
         l_reserve_amt := px_group_reclass_options_rec.reserve_amount;
      --Bug6987743:Following make sure to pass reserve transfered to faxama so
      --that previously transferred amount will be taken out form Books Summary table.
      elsif px_group_reclass_options_rec.group_reclass_type = 'CALC' and
            (l_src_asset_fin_rec_old.tracking_method = 'ALLOCATE' or
             (l_src_asset_fin_rec_old.tracking_method = 'CALCULATE' and
              nvl(l_src_asset_fin_rec_old.member_rollup_flag, 'N') = 'N')) then

         /*Bug 8814747 added this condition for Energy methods amortization date is always current period.
                So we are calculating the reserve in bsRecalculate. Not required to pass from here.*/
              if (not(fa_cache_pkg.fazcdbr_record.rule_name = 'ENERGY PERIOD END BALANCE' and
                      l_src_asset_fin_rec_old.tracking_method = 'ALLOCATE')) then
         OPEN c_get_reserve;
         FETCH c_get_reserve INTO l_transfer_amount;
         CLOSE c_get_reserve;

         l_src_asset_deprn_rec_adj.deprn_reserve := -1 * nvl(l_transfer_amount, 0);

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Getting previously transferred rsv', l_transfer_amount , p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_src_asset_deprn_rec_adj.deprn_reserve', l_src_asset_deprn_rec_adj.deprn_reserve, p_log_level_rec => p_log_level_rec);
         end if;
         end if;
         l_reserve_amt := p_asset_deprn_rec_old.deprn_reserve;
      end if;
      /*Bug# 8527619 */
      if not FA_ASSET_VAL_PVT.validate_over_depreciation
             (p_asset_hdr_rec      => px_src_asset_hdr_rec,
              p_asset_fin_rec      => p_asset_fin_rec_old,
              p_validation_type    => 'RECLASS_SOURCE',
              p_cost_adj           => p_asset_fin_rec_old.cost,
              p_rsv_adj            => l_reserve_amt,
              p_log_level_rec => p_log_level_rec) then
          raise grp_rec_err;
      end if;

      if not FA_ADJUSTMENT_PVT.do_adjustment
                  (px_trans_rec              => px_src_trans_rec,
                   px_asset_hdr_rec          => px_src_asset_hdr_rec,
                   p_asset_desc_rec          => p_src_asset_desc_rec,
                   p_asset_type_rec          => p_src_asset_type_rec,
                   p_asset_cat_rec           => p_src_asset_cat_rec,
                   p_asset_fin_rec_old       => l_src_asset_fin_rec_old,
                   p_asset_fin_rec_adj       => l_src_asset_fin_rec_adj,
                   x_asset_fin_rec_new       => l_src_asset_fin_rec_new,
                   p_inv_trans_rec           => l_inv_trans_rec,
                   p_asset_deprn_rec_old     => l_src_asset_deprn_rec_old,
                   p_asset_deprn_rec_adj     => l_src_asset_deprn_rec_adj,
                   x_asset_deprn_rec_new     => l_src_asset_deprn_rec_new,
                   p_period_rec              => p_period_rec,
                   p_reclassed_asset_id      => p_asset_hdr_rec.asset_id,
                   p_reclass_src_dest        => 'SOURCE',
                   p_reclassed_asset_dpis    => p_asset_fin_rec_old.date_placed_in_service,
                   p_mrc_sob_type_code       => p_mrc_sob_type_code,
                   p_group_reclass_options_rec => px_group_reclass_options_rec,
                   p_calling_fn              => l_calling_fn
                  , p_log_level_rec => p_log_level_rec) then
         raise grp_rec_err;
      end if; -- do_adjustment


      if px_group_reclass_options_rec.group_reclass_type = 'MANUAL' then

         -- BUG# 2683922, issue #2
         -- delete any expense rows taken in the above call from
         -- calc_fin_info.  currently, there's no easy way to
         -- distinguish whether the group adjustment was from
         -- a group reclass / member adjustment, etc inside
         -- calc_fin_info when calling faxama/faxiat

         if (p_mrc_sob_type_code = 'R') then
            delete from fa_mc_adjustments
             where asset_id         = px_src_asset_hdr_rec.asset_id
               and book_type_code   = px_src_asset_hdr_rec.book_type_code
               and transaction_header_id = px_src_trans_rec.transaction_header_id
               and adjustment_type in ('EXPENSE', 'BONUS EXPENSE', 'IMPAIR EXPENSE')
               and source_type_code = 'DEPRECIATION'
               and set_of_books_id  = px_src_asset_hdr_rec.set_of_books_id;
         else
            delete from fa_adjustments
             where asset_id         = px_src_asset_hdr_rec.asset_id
               and book_type_code   = px_src_asset_hdr_rec.book_type_code
               and transaction_header_id = px_src_trans_rec.transaction_header_id
               and adjustment_type in ('EXPENSE', 'BONUS EXPENSE', 'IMPAIR EXPENSE')
               and source_type_code = 'DEPRECIATION';
         end if;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'amort start date2.5',p_trans_rec.amortization_start_date , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'amort start date2.5a',px_src_trans_rec.amortization_start_date , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_src_asset_fin_rec_new.eofy_reserve',l_src_asset_fin_rec_new.eofy_reserve, p_log_level_rec => p_log_level_rec);
      end if;

      l_src_asset_deprn_rec_new := l_src_asset_deprn_rec_old;

   else  -- asset was originally standalone

      if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'source is','standalone', p_log_level_rec => p_log_level_rec);
      end if;


      -- whether expense or reserve transfer, amount must be set to
      -- the current reserve balance in order to remove all balances
      -- from the memeber asset (i.e. ignore calc / manual) this is
      -- done internally inside the private api


      -- set the main structs equal to member if asset was
      -- originally standalone

      px_src_trans_rec          := p_trans_rec;
      l_src_asset_hdr_rec       := p_asset_hdr_rec;
      l_src_asset_desc_rec      := p_asset_desc_rec;
      l_src_asset_type_rec      := p_asset_type_rec;
      l_src_asset_cat_rec       := p_asset_cat_rec;
      l_src_asset_fin_rec_new   := p_asset_fin_rec_old;    -- NOTE: using old here
      l_src_asset_deprn_rec_new := p_asset_deprn_rec_old;

   end if;

   px_src_trans_rec.amortization_start_date := p_trans_rec.amortization_start_date;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'fin_rec_new.deprn_method',l_src_asset_fin_rec_new.deprn_method_code, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'fin_rec_new.eofy_reserve',l_src_asset_fin_rec_new.eofy_reserve, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'fin_rec_old.eofy_reserve',l_src_asset_fin_rec_old.eofy_reserve, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'amort start date3',p_trans_rec.amortization_start_date , p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'amort start date3a',px_src_trans_rec.amortization_start_date , p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'destination tracking method',l_dest_asset_fin_rec_old.tracking_method, p_log_level_rec => p_log_level_rec);
   end if;

   -- If the asset was moved out of a group, deduct the asset's cost from the old group
   if (l_src_asset_type_rec.asset_type <> 'GROUP' and
       nvl(l_dest_asset_fin_rec_old.tracking_method,'NONE') <> 'CALCULATE') or
      px_group_reclass_options_rec.group_reclass_type = 'MANUAL' then
      if not FA_GROUP_RECLASS2_PVT.do_adjustment
                      (px_trans_rec                 => px_src_trans_rec,
                       p_asset_hdr_rec              => l_src_asset_hdr_rec,
                       p_asset_desc_rec             => l_src_asset_desc_rec,
                       p_asset_type_rec             => l_src_asset_type_rec,
                       p_asset_cat_rec              => l_src_asset_cat_rec,
                       p_asset_fin_rec_old          => l_src_asset_fin_rec_old,
                       p_asset_fin_rec_new          => l_src_asset_fin_rec_new,
                       p_asset_deprn_rec_old        => l_src_asset_deprn_rec_new,
                       p_mem_asset_hdr_rec          => p_asset_hdr_rec,
                       p_mem_asset_desc_rec         => p_asset_desc_rec,
                       p_mem_asset_type_rec         => p_asset_type_rec,
                       p_mem_asset_cat_rec          => p_asset_cat_rec,
                       p_mem_asset_fin_rec_new      => p_asset_fin_rec_old,
                       p_mem_asset_deprn_rec_new    => p_asset_deprn_rec_old,
                       px_group_reclass_options_rec => px_group_reclass_options_rec,
                       p_period_rec                 => p_period_rec,
                       p_mrc_sob_type_code          => p_mrc_sob_type_code,
                       p_src_dest                   => 'SOURCE'
                      , p_log_level_rec => p_log_level_rec) then
         raise grp_rec_err;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'amort start date4',p_trans_rec.amortization_start_date , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'amort start date4a',px_src_trans_rec.amortization_start_date , p_log_level_rec => p_log_level_rec);
      end if;
   end if;

   -----------------
   -- DESTINATION --
   -----------------

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'processing','detination asset', p_log_level_rec => p_log_level_rec);
   end if;

   -- For Source Group
   -- Populate Subtract Ytd Flag
   if not fa_cache_pkg.fazccmt(X_method => p_asset_fin_rec_new.deprn_method_code,
                               X_life => p_asset_fin_rec_new.life_in_months, p_log_level_rec => p_log_level_rec) then
      raise grp_rec_err;
   end if;

   -- If the asset was moved into a group, add the asset's cost to the new group
   if p_asset_fin_rec_new.group_asset_id is not null then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'processing dest as ','group', p_log_level_rec => p_log_level_rec);
      end if;

      l_dest_asset_hdr_rec       := px_dest_asset_hdr_rec;
      l_dest_asset_desc_rec      := p_dest_asset_desc_rec;
      l_dest_asset_type_rec      := p_dest_asset_type_rec;
      l_dest_asset_cat_rec       := p_dest_asset_cat_rec;

      -- load the delta cost for the group with the cost of the member

      if (p_asset_type_rec.asset_type = 'CIP') then
         l_dest_asset_fin_rec_adj.cost     := p_asset_fin_rec_new.cost - p_asset_fin_rec_new.cip_cost;
         l_dest_asset_fin_rec_adj.cip_cost := p_asset_fin_rec_new.cip_cost;
      else
         l_dest_asset_fin_rec_adj.cost := p_asset_fin_rec_new.cost;
      end if;

      if (p_mrc_sob_type_code <> 'R') then

         -- set up the group recs
         px_dest_trans_rec                              := p_trans_rec;
         px_dest_trans_rec.member_transaction_header_id := p_trans_rec.transaction_header_id;

         px_dest_trans_rec.transaction_type_code        := 'GROUP ADJUSTMENT';
         px_dest_trans_rec.member_transaction_header_id := p_trans_rec.transaction_header_id;
         px_dest_trans_rec.transaction_subtype          := 'AMORTIZED';
         px_dest_trans_rec.transaction_key              := 'GC';

         if (p_trans_rec.amortization_start_date is not null) then
            px_dest_trans_rec.transaction_date_entered     := p_trans_rec.amortization_start_date;
         end if;

         select fa_transaction_headers_s.nextval
           into px_dest_trans_rec.transaction_header_id
           from dual;

      end if;

      -- get the old fin and deprn information
      if not FA_UTIL_PVT.get_asset_fin_rec
              (p_asset_hdr_rec         => px_dest_asset_hdr_rec,
               px_asset_fin_rec        => l_dest_asset_fin_rec_old,
               p_transaction_header_id => NULL,
               p_mrc_sob_type_code     => p_mrc_sob_type_code
              , p_log_level_rec => p_log_level_rec) then raise grp_rec_err;
      end if;

      --HH Validate disabled_flag
      --Reject transaction if dest group is disabled
      if not FA_ASSET_VAL_PVT.validate_disabled_flag
                  (p_group_asset_id => l_dest_asset_fin_rec_old.group_asset_id,
                   p_book_type_code => px_dest_asset_hdr_rec.book_type_code,
                   p_old_flag       => l_dest_asset_fin_rec_old.disabled_flag,
                   p_new_flag       => l_dest_asset_fin_rec_old.disabled_flag
                  , p_log_level_rec => p_log_level_rec) then
         raise grp_rec_err;
      end if; --End HH

      if not FA_UTIL_PVT.get_asset_deprn_rec
              (p_asset_hdr_rec         => px_dest_asset_hdr_rec,
               px_asset_deprn_rec      => l_dest_asset_deprn_rec_old,
               p_period_counter        => NULL,
               p_mrc_sob_type_code     => p_mrc_sob_type_code
              , p_log_level_rec => p_log_level_rec) then raise grp_rec_err;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'amort start date6', p_trans_rec.amortization_start_date , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'amort start date6a',px_dest_trans_rec.amortization_start_date , p_log_level_rec => p_log_level_rec);
      end if;

      -- If the deprn basis rule is defined as Year End Balance type,
      -- new adjusted cost must be calculated based on the entered eofy_reserve
      if nvl(fa_cache_pkg.fazcdrd_record.subtract_ytd_flag,'N') = 'Y' then
         l_dest_asset_fin_rec_adj.eofy_reserve := nvl(px_group_reclass_options_rec.destination_eofy_reserve,0);
      end if;

      --
      -- Populating eofy_reserve is necessary because fin_rec_adj is not populated in
      -- faxama if this is not called from FAXASSET
      --
      if (p_asset_fin_rec_old.group_asset_id is null) and
         (p_trans_rec.calling_interface <> 'FAXASSET') then
         l_dest_asset_fin_rec_adj.eofy_reserve := nvl(p_asset_fin_rec_new.eofy_reserve,0);
      end if;

      if px_group_reclass_options_rec.group_reclass_type = 'MANUAL' then
         l_dest_asset_deprn_rec_adj.deprn_reserve := px_group_reclass_options_rec.reserve_amount;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'l_dest_asset_fin_rec_old.eofy_reserve',
                          l_dest_asset_fin_rec_old.eofy_reserve, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_dest_asset_fin_rec_adj.eofy_reserve',
                          l_dest_asset_fin_rec_adj.eofy_reserve, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_dest_asset_fin_rec_new.eofy_reserve',
                          l_dest_asset_fin_rec_new.eofy_reserve, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'amort start date befor calling faxama',
                          px_dest_trans_rec.amortization_start_date , p_log_level_rec => p_log_level_rec);
      end if;
      /*Bug# 8527619 */
      if not FA_ASSET_VAL_PVT.validate_over_depreciation
             (p_asset_hdr_rec => px_dest_asset_hdr_rec,
              p_asset_fin_rec     =>l_dest_asset_fin_rec_old,
              p_validation_type    => 'RECLASS_DEST',
              p_cost_adj           => p_asset_fin_rec_old.cost,
              p_rsv_adj            => l_reserve_amt,
              p_log_level_rec => p_log_level_rec) then
         raise grp_rec_err;
      end if;
      -- now process the adjustment on the group
      if not FA_ADJUSTMENT_PVT.do_adjustment
                  (px_trans_rec              => px_dest_trans_rec,
                   px_asset_hdr_rec          => px_dest_asset_hdr_rec,
                   p_asset_desc_rec          => p_dest_asset_desc_rec,
                   p_asset_type_rec          => p_dest_asset_type_rec,
                   p_asset_cat_rec           => p_dest_asset_cat_rec,
                   p_asset_fin_rec_old       => l_dest_asset_fin_rec_old,
                   p_asset_fin_rec_adj       => l_dest_asset_fin_rec_adj,
                   x_asset_fin_rec_new       => l_dest_asset_fin_rec_new,
                   p_inv_trans_rec           => l_inv_trans_rec,
                   p_asset_deprn_rec_old     => l_dest_asset_deprn_rec_old,
                   p_asset_deprn_rec_adj     => l_dest_asset_deprn_rec_adj,
                   x_asset_deprn_rec_new     => l_dest_asset_deprn_rec_new,
                   p_period_rec              => p_period_rec,
                   p_reclassed_asset_id      => p_asset_hdr_rec.asset_id,
                   p_reclass_src_dest        => 'DESTINATION',
                   p_reclassed_asset_dpis    => p_asset_fin_rec_old.date_placed_in_service,
                   p_mrc_sob_type_code       => p_mrc_sob_type_code,
                   p_group_reclass_options_rec => px_group_reclass_options_rec,
                   p_calling_fn              => l_calling_fn
                  , p_log_level_rec => p_log_level_rec)then
         raise grp_rec_err;
      end if; -- do_adjustment

      if px_group_reclass_options_rec.group_reclass_type = 'MANUAL' then
         -- BUG# 2683922, issue #2
         -- delete any expense rows taken in the above call from
         -- calc_fin_info.  currently, there's no easy way to
         -- distinguish whether the group adjustment was from
         -- a group reclass / member adjustment, etc inside
         -- calc_fin_info when calling faxama/faxiat

         if (p_mrc_sob_type_code = 'R') then
              delete from fa_mc_adjustments
                where asset_id         = px_dest_asset_hdr_rec.asset_id
                  and book_type_code   = px_dest_asset_hdr_rec.book_type_code
                  and transaction_header_id = px_dest_trans_rec.transaction_header_id
                  and adjustment_type in ('EXPENSE', 'BONUS EXPENSE',
                                          'IMPAIR EXPENSE')
                  and source_type_code = 'DEPRECIATION'
                  and set_of_books_id  = px_dest_asset_hdr_rec.set_of_books_id;
         else
            delete from fa_adjustments
             where asset_id         = px_dest_asset_hdr_rec.asset_id
               and book_type_code   = px_dest_asset_hdr_rec.book_type_code
               and transaction_header_id = px_dest_trans_rec.transaction_header_id
               and adjustment_type in ('EXPENSE', 'BONUS EXPENSE',
                                       'IMPAIR EXPENSE')
               and source_type_code = 'DEPRECIATION';
         end if;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'amort start date7', p_trans_rec.amortization_start_date , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'amort start date7a',px_dest_trans_rec.amortization_start_date , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_dest_asset_fin_rec_new.eofy_reserve',
                          l_dest_asset_fin_rec_new.eofy_reserve, p_log_level_rec => p_log_level_rec);
      end if;

      l_dest_asset_deprn_rec_new := l_dest_asset_deprn_rec_old;

   else -- asset is now standalone

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'processing dest as','standalone', p_log_level_rec => p_log_level_rec);
      end if;

      -- set the main structs equal to member if asset is
      -- now standalone

      px_dest_trans_rec          := p_trans_rec;
      l_dest_asset_hdr_rec       := p_asset_hdr_rec;
      l_dest_asset_desc_rec      := p_asset_desc_rec;
      l_dest_asset_type_rec      := p_asset_type_rec;
      l_dest_asset_cat_rec       := p_asset_cat_rec;
      l_dest_asset_fin_rec_old   := p_asset_fin_rec_old;
      l_dest_asset_fin_rec_new   := p_asset_fin_rec_new;
      l_dest_asset_deprn_rec_old := p_asset_deprn_rec_old;
      l_dest_asset_deprn_rec_new := p_asset_deprn_rec_new;

   end if;

   px_dest_trans_rec.amortization_start_date          := p_trans_rec.amortization_start_date;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'amort start date8',p_trans_rec.amortization_start_date , p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'amort start date8a',px_dest_trans_rec.amortization_start_date , p_log_level_rec => p_log_level_rec);
   end if;

   -- If the asset was moved into a group, add the asset's cost to the new group
   if (l_dest_asset_type_rec.asset_type <> 'GROUP' and
      nvl(l_src_asset_fin_rec_old.tracking_method,'NONE') <> 'CALCULATE' ) or
      (px_group_reclass_options_rec.group_reclass_type = 'MANUAL') then
--       l_dest_asset_type_rec.asset_type = 'GROUP')  then
      if not FA_GROUP_RECLASS2_PVT.do_adjustment
                      (px_trans_rec                => px_dest_trans_rec,
                       p_asset_hdr_rec             => l_dest_asset_hdr_rec,
                       p_asset_desc_rec            => l_dest_asset_desc_rec,
                       p_asset_type_rec            => l_dest_asset_type_rec,
                       p_asset_cat_rec             => l_dest_asset_cat_rec,
                       p_asset_fin_rec_old         => l_dest_asset_fin_rec_old,
                       p_asset_fin_rec_new         => l_dest_asset_fin_rec_new,
                       p_asset_deprn_rec_old       => l_dest_asset_deprn_rec_new,
                       p_mem_asset_hdr_rec         => p_asset_hdr_rec,
                       p_mem_asset_desc_rec        => p_asset_desc_rec,
                       p_mem_asset_type_rec        => p_asset_type_rec,
                       p_mem_asset_cat_rec         => p_asset_cat_rec,
                       p_mem_asset_fin_rec_new     => p_asset_fin_rec_new,
                       p_mem_asset_deprn_rec_new   => p_asset_deprn_rec_new,
                       px_group_reclass_options_rec => px_group_reclass_options_rec,
                       p_period_rec                => p_period_rec,
                       p_mrc_sob_type_code         => p_mrc_sob_type_code,
                       p_src_dest                  => 'DESTINATION'
                      , p_log_level_rec => p_log_level_rec) then
         raise grp_rec_err;
      end if;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'amort start date9',p_trans_rec.amortization_start_date , p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'amort start date9a',px_dest_trans_rec.amortization_start_date , p_log_level_rec => p_log_level_rec);
   end if;

   --
   -- Initialize Member Tables
   --
   FA_AMORT_PVT.initMemberTable;

   -- Adding this if statement because this will be called in FAPGADJB.pls
   if (G_release = 11 and
       (px_group_reclass_options_rec.group_reclass_type = 'MANUAL' or
        p_trans_rec.calling_interface <> 'FAXASSET')   -- COMMENT THIS LINE OUT FOR NON-CONC PROGRAM TESTING
      ) then
      -- process any intercompany effects
      if not fa_interco_pvt.do_all_books
                   (p_src_trans_rec          => px_src_trans_rec,
                    p_src_asset_hdr_rec      => l_src_asset_hdr_rec,
                    p_dest_trans_rec         => px_dest_trans_rec,
                    p_dest_asset_hdr_rec     => l_dest_asset_hdr_rec,
                    p_calling_fn             => l_calling_fn
                   , p_log_level_rec => p_log_level_rec) then raise grp_rec_err;
      end if;
   end if;

   -- insert the transaction link record
   -- note that the trx_ref_id was loaded in FAPADJB.pls

   if (p_mrc_sob_type_code <> 'R') then

      l_trx_reference_id := p_trans_rec.trx_reference_id;

      fa_trx_references_pkg.insert_row
            (X_Rowid                          => l_rowid,
             X_Trx_Reference_Id               => l_trx_reference_id,
             X_Book_Type_Code                 => p_asset_hdr_rec.book_type_code,
             X_Src_Asset_Id                   => l_src_asset_hdr_rec.asset_id,
             X_Src_Transaction_Header_Id      => px_src_trans_rec.transaction_header_id,
             X_Dest_Asset_Id                  => l_dest_asset_hdr_rec.asset_id,
             X_Dest_Transaction_Header_Id     => px_dest_trans_rec.transaction_header_id,
             X_Member_Asset_Id                => p_asset_hdr_rec.asset_id,
             X_Member_Transaction_Header_Id   => p_trans_rec.transaction_header_id,
             X_Transaction_Type               => 'GROUP CHANGE',
             X_Src_Transaction_Subtype        => px_src_trans_rec.transaction_subtype || ' ' || px_group_reclass_options_rec.group_reclass_type,
             X_Dest_Transaction_Subtype       => px_dest_trans_rec.transaction_subtype || ' ' || px_group_reclass_options_rec.group_reclass_type,
             X_Src_Amortization_Start_Date    => px_src_trans_rec.amortization_start_date,
             X_Dest_Amortization_Start_Date   => px_dest_trans_rec.amortization_start_date,
             X_Reserve_Transfer_Amount        => px_group_reclass_options_rec.reserve_amount,
             X_Src_Expense_Amount             => px_group_reclass_options_rec.source_exp_amount,
             X_Dest_Expense_Amount            => px_group_reclass_options_rec.destination_exp_amount,
             X_Src_Eofy_Reserve               => px_group_reclass_options_rec.source_eofy_reserve,
             X_Dest_Eofy_Reserve              => px_group_reclass_options_rec.destination_eofy_reserve,
             X_Creation_Date                  => p_trans_rec.who_info.creation_date,
             X_Created_By                     => p_trans_rec.who_info.created_by,
             X_Last_Update_Date               => p_trans_rec.who_info.last_update_date,
             X_Last_Updated_By                => p_trans_rec.who_info.last_updated_by,
             X_Last_Update_Login              => p_trans_rec.who_info.last_update_login,
             X_Return_Status                  => l_return_status,
             X_Calling_Fn                     => l_calling_fn
            , p_log_level_rec => p_log_level_rec);

   end if;

   -- no go back and update all transaction header rows with the link_id

   --
   -- Source group is the only potential group requires terminal gain loss
   -- calculation.
   --
   if (nvl(l_src_asset_fin_rec_new.adjustment_required_status, 'NONE') <> 'GADJ') then
      if not FA_RETIREMENT_PVT.Check_Terminal_Gain_Loss(
                      p_trans_rec         => px_src_trans_rec,
                      p_asset_hdr_rec     => px_src_asset_hdr_rec,
                      p_asset_type_rec    => p_src_asset_type_rec,
                      p_asset_fin_rec     => l_src_asset_fin_rec_new,
                      p_period_rec        => p_period_rec,
                      p_mrc_sob_type_code => p_mrc_sob_type_code,
                      p_calling_fn        => l_calling_fn, p_log_level_rec => p_log_level_rec) then
         if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, 'Failed Calling',
                              ' FA_RETIREMENT_PVT.Check_Terminal_Gain_Loss',  p_log_level_rec => p_log_level_rec);
         end if;
         raise grp_rec_err;

      end if;
   end if; -- (nvl(l_src_asset_fin_rec_new.adjustment_required_status, 'NONE') <> 'GADJ')



   return true;

EXCEPTION

   WHEN GRP_REC_ERR THEN
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;


end do_group_reclass;

---------------------------------------------------------------------------------------

FUNCTION do_adjustment
   (px_trans_rec                 IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec              IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec             IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec             IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec              IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec_old          IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_new          IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_old        IN     FA_API_TYPES.asset_deprn_rec_type,
    p_mem_asset_hdr_rec          IN     FA_API_TYPES.asset_hdr_rec_type,
    p_mem_asset_desc_rec         IN     FA_API_TYPES.asset_desc_rec_type,
    p_mem_asset_type_rec         IN     FA_API_TYPES.asset_type_rec_type,
    p_mem_asset_cat_rec          IN     FA_API_TYPES.asset_cat_rec_type,
    p_mem_asset_fin_rec_new      IN     FA_API_TYPES.asset_fin_rec_type,
    p_mem_asset_deprn_rec_new    IN     FA_API_TYPES.asset_deprn_rec_type,
    px_group_reclass_options_rec IN OUT NOCOPY FA_API_TYPES.group_reclass_options_rec_type,
    p_period_rec                 IN     fa_api_types.period_rec_type,
    p_mrc_sob_type_code          IN     VARCHAR2,
    p_src_dest                   IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   -- used for faxinaj calls
   l_exp_adj                 FA_ADJUST_TYPE_PKG.fa_adj_row_struct;
   l_rsv_adj                 FA_ADJUST_TYPE_PKG.fa_adj_row_struct;


   -- used for temporary holding
   l_exp_amount              number := 0;
   l_rsv_amount              number := 0;
   l_total_rsv_amount        number := 0;
   l_bonus_exp_amount        number := 0;
   l_impair_exp_amount       number := 0;


   -- used for temporary storage for calls to faxama
   l_asset_fin_rec_adj       FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_rec_new       FA_API_TYPES.asset_fin_rec_type;
   l_asset_deprn_rec_old     FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_rec_adj     FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_rec_new     FA_API_TYPES.asset_deprn_rec_type;
   l_trans_rec               FA_API_TYPES.trans_rec_type;
   l_group_reclass_options_rec FA_API_TYPES.group_reclass_options_rec_type;
   l_deprn_exp               number;
   l_bonus_deprn_exp         number;
   l_impairment_exp          number;

   l_difference_eofy_reserve number;
   l_exp_adjust_for_ye       number;
   l_exp_amount_by_system    number;
   l_eofy_reserve            number;

   l_backed_out_exp          number;

   --bug6983091: getting expense just backed out
   CURSOR c_get_exp_amount IS
      select NVL(SUM(DECODE(adj.debit_credit_flag,
                                  'DR', adj.adjustment_amount,
                                  'CR', -1 * adj.adjustment_amount)), 0)
      from   fa_adjustments adj
      where  adj.asset_id               = p_asset_hdr_rec.asset_id
      and    adj.book_type_code         = p_asset_hdr_rec.book_type_code
      and    adj.adjustment_type        = 'EXPENSE'
      and    adj.period_counter_created = p_period_rec.period_counter
      and    adj.track_member_flag      = 'Y'
      and    adj.transaction_header_id  = px_trans_rec.transaction_header_id;
      /* Bug 8237945 added above transaction_header_id condition. To get the backed out expense
        we need to consider the expense just inserted into fa_adjustments by this transaction*/

   --bug6983091: MRC: getting expense just backed out
   CURSOR c_get_mc_exp_amount IS
      select NVL(SUM(DECODE(adj.debit_credit_flag,
                                  'DR', adj.adjustment_amount,
                                  'CR', -1 * adj.adjustment_amount)), 0)
      from   fa_mc_adjustments adj
      where  adj.asset_id               = p_asset_hdr_rec.asset_id
      and    adj.book_type_code         = p_asset_hdr_rec.book_type_code
      and    adj.adjustment_type        = 'EXPENSE'
      and    adj.period_counter_created = p_period_rec.period_counter
      and    adj.track_member_flag      = 'Y'
      and    adj.transaction_header_id  = px_trans_rec.transaction_header_id
      and    adj.set_of_books_id        = p_asset_hdr_rec.set_of_books_id;
      /* Bug 8237945 added above transaction_header_id condition. To get the backed out expense
        we need to consider the expense just inserted into fa_adjustments by this transaction*/

   l_calling_fn              VARCHAR2(35) := 'fa_group_reclass_pvt.do_adjustment';
   grp_rec_err               EXCEPTION;


BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'amort start date inside 1',px_trans_rec.amortization_start_date , p_log_level_rec => p_log_level_rec);
   end if;


   l_asset_fin_rec_new := p_asset_fin_rec_new;

   if (p_src_dest = 'SOURCE') then
      l_asset_fin_rec_adj.cost           := -1 * p_mem_asset_fin_rec_new.cost;
      l_asset_fin_rec_adj.salvage_value  := -1 * p_mem_asset_fin_rec_new.salvage_value;
      l_asset_fin_rec_adj.allowed_deprn_limit_amount
                                         := -1 * p_mem_asset_fin_rec_new.allowed_deprn_limit_amount;
   else
      l_asset_fin_rec_adj.cost           := p_mem_asset_fin_rec_new.cost;
      l_asset_fin_rec_adj.salvage_value  := p_mem_asset_fin_rec_new.salvage_value;
      l_asset_fin_rec_adj.allowed_deprn_limit_amount
                                         := p_mem_asset_fin_rec_new.allowed_deprn_limit_amount;
   end if;

   -- calculate / insert the expense and reserve accordingly
   --
   -- notes:
   --  1) we do not allow NONE in conjunction with manual  (***OPEN ISSUE***)
   --       UPDATE: yes we will as the form will default the amount and not allow
   --               it to change.  validation below will validate that for
   --               NONE-GRP, that the amount is equal to the member's reserve
   --
   --  2) precedence is as follows:
   --      - reserve portion (calc only)
   --         - NONE-GRP  (the asset's reserve is always used)
   --         - GRP-NONE  (the asset's dpis is used to derive
   --                      the amount of grp reserve to extract)
   --         - GRP-GRP   (the asset's dpis is used to derive
   --                      the amount of source group's reserve)
   --      - expense
   --         - (both CALC and MANUAL):
   --            each side of the expense part of transaction is treated
   --            totally independantly.
   --         - (CALC only): each side uses same amortization start date.
   --           if there is any difference between the amort start date and
   --           current period open date, we will charge expense for the periods
   --           in between.  In the event the amort start date = members dpis,
   --           the axpense will equal reserve portion leaving no reserve to
   --           transfer.
   --
   --  3) for mrc scenarios, the incoming values will already be
   --     set to the reporting values we will always convert the amounts
   --     so that the ratio of new reserve / new cost is the same
   --     as in primary *** as in CRL, this poses a problem when
   --     using transfer reserve because there is the likely
   --     potential that when this ratio is applied to both the
   --     and destination, the amounts will not be equal, but
   --     from an accounting standpoint - they must be
   --


   -- call the category books cache for the accounts
   if not fa_cache_pkg.fazccb
             (X_book   => p_asset_hdr_rec.book_type_code,
              X_cat_id => p_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
      raise grp_rec_err;
   end if;

   -- set up the structs to be passed to faxinaj
   l_rsv_adj.transaction_header_id    := px_trans_rec.transaction_header_id;
   l_rsv_adj.asset_id                 := p_asset_hdr_rec.asset_id;   -- p_asset_fin_rec_new.group_asset_id;
   l_rsv_adj.book_type_code           := p_asset_hdr_rec.book_type_code;
   l_rsv_adj.period_counter_created   := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
   l_rsv_adj.period_counter_adjusted  := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
   l_rsv_adj.current_units            := p_asset_desc_rec.current_units;
   l_rsv_adj.selection_mode           := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
   l_rsv_adj.selection_thid           := 0;
   l_rsv_adj.selection_retid          := 0;
   l_rsv_adj.leveling_flag            := TRUE;
   l_rsv_adj.last_update_date         := px_trans_rec.transaction_date_entered;
   l_rsv_adj.flush_adj_flag           := TRUE;
   l_rsv_adj.gen_ccid_flag            := TRUE;
   l_rsv_adj.annualized_adjustment    := 0;
   l_rsv_adj.asset_invoice_id         := 0;
   l_rsv_adj.distribution_id          := 0;
   l_rsv_adj.mrc_sob_type_code        := p_mrc_sob_type_code;
   l_rsv_adj.set_of_books_id          := p_asset_hdr_rec.set_of_books_id;

   l_exp_adj.transaction_header_id    := px_trans_rec.transaction_header_id;
   l_exp_adj.asset_id                 := p_asset_hdr_rec.asset_id;  -- p_asset_fin_rec_new.group_asset_id;
   l_exp_adj.book_type_code           := p_asset_hdr_rec.book_type_code;
   l_exp_adj.period_counter_created   := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
   l_exp_adj.period_counter_adjusted  := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
   l_exp_adj.current_units            := p_asset_desc_rec.current_units;
   l_exp_adj.selection_mode           := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
   l_exp_adj.selection_thid           := 0;
   l_exp_adj.selection_retid          := 0;
   l_exp_adj.leveling_flag            := TRUE;
   l_exp_adj.last_update_date         := px_trans_rec.transaction_date_entered;
   l_exp_adj.flush_adj_flag           := TRUE;
   l_exp_adj.gen_ccid_flag            := TRUE;
   l_exp_adj.annualized_adjustment    := 0;
   l_exp_adj.asset_invoice_id         := 0;
   l_exp_adj.distribution_id          := 0;
   l_exp_adj.mrc_sob_type_code        := p_mrc_sob_type_code;
   l_exp_adj.set_of_books_id          := p_asset_hdr_rec.set_of_books_id;

   -- most of the following logic was stolen from FAVGRCLB.pls (CRL)
   -- basically, derive the info for each insert into fa_adjustments
   -- based on the source / destination / asset type, etc

   -- set up the accounting related values in the adj_ptr
   if (p_src_dest = 'SOURCE') then

      -- Expense accounts have to be CR for the old acct
      -- Reserve accounts have to be DR for the old acct

      l_rsv_adj.source_type_code    := 'ADJUSTMENT';
      l_rsv_adj.adjustment_type     := 'RESERVE';
      l_rsv_adj.code_combination_id := fa_cache_pkg.fazccb_record.reserve_account_ccid;
      l_rsv_adj.account             := fa_cache_pkg.fazccb_record.deprn_reserve_acct;
      l_rsv_adj.account_type        := 'DEPRN_RESERVE_ACCT';
      l_rsv_adj.debit_credit_flag   := 'DR';

      -- Bug4335926:
      -- Set l_rsv_adj.track_member_flag accordingly.
      --
      -- Bug5736734: Modified so that it only set flag for member tracking
      if (p_mem_asset_fin_rec_new.group_asset_id is not null) and
         (p_mem_asset_fin_rec_new.tracking_method is not null) and
         (p_asset_type_rec.asset_type <> 'GROUP') then
         l_rsv_adj.track_member_flag := 'Y';
         l_exp_adj.track_member_flag := 'Y';
      else
         l_rsv_adj.track_member_flag := null;
         l_exp_adj.track_member_flag := null;
      end if;

      l_exp_adj.source_type_code    := 'DEPRECIATION';
      l_exp_adj.adjustment_type     := 'EXPENSE';
      l_exp_adj.code_combination_id := 0;
      l_exp_adj.account             := fa_cache_pkg.fazccb_record.deprn_expense_acct;
      l_exp_adj.account_type        := 'DEPRN_EXPENSE_ACCT';
      l_exp_adj.debit_credit_flag   := 'CR';

   else  --  (p_src_dest = 'DESTINATION') then

      -- Expense accounts have to be DR for the new acct
      -- Reserve accounts have to be CR for the new acct

      l_rsv_adj.source_type_code    := 'ADJUSTMENT';
      l_rsv_adj.adjustment_type     := 'RESERVE';
      l_rsv_adj.code_combination_id := fa_cache_pkg.fazccb_record.reserve_account_ccid;
      l_rsv_adj.account             := fa_cache_pkg.fazccb_record.deprn_reserve_acct;
      l_rsv_adj.account_type        := 'DEPRN_RESERVE_ACCT';
      l_rsv_adj.debit_credit_flag   := 'CR';

      l_exp_adj.source_type_code    := 'DEPRECIATION';
      l_exp_adj.adjustment_type     := 'EXPENSE';
      l_exp_adj.code_combination_id := 0;
      l_exp_adj.account             := fa_cache_pkg.fazccb_record.deprn_expense_acct;
      l_exp_adj.account_type        := 'DEPRN_EXPENSE_ACCT';
      l_exp_adj.debit_credit_flag   := 'DR';

   end if;

   -- here are how the the various options are calculated / handled:
   --
   --  MANUAL     : use the entered amounts for expense and reserve for both assets
   --
   --  CALC       : use the member's dpis and derive the amount of reserve
   --               which it contributed (for standalone source, use query balances)
   --               use the amort start date and derive the expense for all periods
   --               since that date.  transfer the difference between the two as reserve
   --               use the difference and the respective expense amounts for source and dest
   --
   --    (In Case the Tracking Method is enabled)
   --    When the Tracking Method is enabled, reclass option is passed as 'CALC',
   --    But the amounts for reserve and expense will be populated from stored amounts
   --    instead of calculating the amounts.
   --    This behavior is similar to MANUAL type.
   --
   --  implications: we can/must always use the same reserve for source and dest
   --                regardless of the reclass type
   --

   if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn, 'debug message','just before if-clause to switch logic by reclass type', p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'group_reclass_type',px_group_reclass_options_rec.group_reclass_type, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'asset_type',p_asset_type_rec.asset_type, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'tracking_method',p_asset_fin_rec_new.tracking_method, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'Source or Dest',p_src_dest, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'src exp amount', px_group_reclass_options_rec.source_exp_amount, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'dest exp amount', px_group_reclass_options_rec.destination_exp_amount, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'reserve amount',  px_group_reclass_options_rec.reserve_amount, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'src eofy reserve amount',  px_group_reclass_options_rec.source_eofy_reserve, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'dest eofy_reserve amount',  px_group_reclass_options_rec.destination_eofy_reserve, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_new.eofy_reserve',  l_asset_fin_rec_new.eofy_reserve, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_new.group_asset_id',  l_asset_fin_rec_new.group_asset_id, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_new.tracking_method',  l_asset_fin_rec_new.tracking_method, p_log_level_rec => p_log_level_rec);
   end if;

   if (px_group_reclass_options_rec.group_reclass_type = 'MANUAL') then

      -- note: this section is interdependent on the section following calc logic
      -- where the rsv is rederived.  For destination we are intentionally
      -- not adding the two together here, for source we are.
      if (p_src_dest = 'SOURCE') then
         l_exp_amount       := nvl(px_group_reclass_options_rec.source_exp_amount, 0);
         l_total_rsv_amount := nvl(px_group_reclass_options_rec.reserve_amount, 0) +
                                   nvl(px_group_reclass_options_rec.source_exp_amount, 0);
         l_eofy_reserve     := nvl(px_group_reclass_options_rec.source_eofy_reserve, 0);
      else
         l_exp_amount       := nvl(px_group_reclass_options_rec.destination_exp_amount, 0);
         l_rsv_amount       := nvl(px_group_reclass_options_rec.reserve_amount, 0);
         l_total_rsv_amount := nvl(px_group_reclass_options_rec.reserve_amount, 0);
         l_eofy_reserve     := nvl(px_group_reclass_options_rec.destination_eofy_reserve,l_eofy_reserve);
      end if;

   elsif (px_group_reclass_options_rec.group_reclass_type = 'CALC') and
         (p_asset_type_rec.asset_type = 'GROUP') and
         (p_asset_fin_rec_new.tracking_method is not null) then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'entering','populate member amounts logic', p_log_level_rec => p_log_level_rec);
      end if;

      if not fa_group_reclass2_pvt.populate_member_amounts
                      (p_trans_rec                  => px_trans_rec,
                       p_asset_hdr_rec              => p_asset_hdr_rec,
                       p_asset_fin_rec_new          => p_asset_fin_rec_new,
                       p_mem_asset_hdr_rec          => p_mem_asset_hdr_rec,
                       p_mem_asset_fin_rec_new      => p_mem_asset_fin_rec_new,
                       px_group_reclass_options_rec => px_group_reclass_options_rec,
                       p_period_rec                 => p_period_rec,
                       p_mrc_sob_type_code          => p_mrc_sob_type_code,
                       p_src_dest                   => p_src_dest
                      , p_log_level_rec => p_log_level_rec) then
         raise grp_rec_err;
      end if;

      l_eofy_reserve := nvl(px_group_reclass_options_rec.source_eofy_reserve,0);

      if (p_src_dest = 'SOURCE') then
          l_exp_amount       := nvl(px_group_reclass_options_rec.source_exp_amount, 0);
          l_rsv_amount       := nvl(px_group_reclass_options_rec.reserve_amount, 0);
          l_total_rsv_amount := nvl(px_group_reclass_options_rec.reserve_amount, 0);

      else -- for destination group, needs to calculate expense amount.
        if (px_trans_rec.amortization_start_date < p_period_rec.calendar_period_open_date and
            px_trans_rec.calling_interface = 'FAPGADJ') then

          if not FA_AMORT_PVT.faxama
                     (px_trans_rec          => px_trans_rec,              -- use amort start
                      p_asset_hdr_rec       => p_asset_hdr_rec,
                      p_asset_desc_rec      => p_asset_desc_rec,
                      p_asset_cat_rec       => p_asset_cat_rec,
                      p_asset_type_rec      => p_asset_type_rec,
                      p_asset_fin_rec_old   => p_asset_fin_rec_new,
                      p_asset_fin_rec_adj   => l_asset_fin_rec_adj,
                      px_asset_fin_rec_new  => l_asset_fin_rec_new,
                      p_asset_deprn_rec     => p_asset_deprn_rec_old,
                      p_asset_deprn_rec_adj => l_asset_deprn_rec_adj,
                      p_period_rec          => p_period_rec,
                      p_mrc_sob_type_code   => p_mrc_sob_type_code,
                      p_running_mode        => fa_std_types.FA_DPR_NORMAL,
                      p_used_by_revaluation => null,
                      p_reclassed_asset_id  => p_mem_asset_hdr_rec.asset_id,
                      p_reclass_src_dest    => p_src_dest,
                      p_reclassed_asset_dpis => p_mem_asset_fin_rec_new.date_placed_in_service,
                      x_deprn_exp           => l_deprn_exp,
                      x_bonus_deprn_exp     => l_bonus_deprn_exp,
                      x_impairment_exp      => l_impairment_exp
                     , p_log_level_rec => p_log_level_rec) then
                raise grp_rec_err;
          end if;

          if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'deprn expense from faxama - in tracking logic',l_deprn_exp, p_log_level_rec => p_log_level_rec);
          end if;
          l_total_rsv_amount := nvl(px_group_reclass_options_rec.reserve_amount, 0);
          l_rsv_amount := nvl(px_group_reclass_options_rec.reserve_amount, 0);
          l_exp_amount := l_deprn_exp; -- l_rsv_amount;
        else
          l_exp_amount := 0;
        end if;
      end if;

   elsif (px_group_reclass_options_rec.group_reclass_type = 'CALC') then

      -- get the portion of reserve which the member contributed
      -- (starting from dpis) and store temporarily - needed only
      -- for the source asset (same amount used for destination)

      if (p_src_dest = 'SOURCE') then

         -- Populate Subtract Ytd Flag
         if not fa_cache_pkg.fazccmt(X_method => l_asset_fin_rec_new.deprn_method_code,
                                     X_life => l_asset_fin_rec_new.life_in_months, p_log_level_rec => p_log_level_rec) then
           raise grp_rec_err;
         end if;

         if (p_asset_type_rec.asset_type = 'GROUP' and
             px_trans_rec.calling_interface = 'FAPGADJ') then

            l_trans_rec := px_trans_rec;
            l_trans_rec.amortization_start_date := p_mem_asset_fin_rec_new.date_placed_in_service;

            if not FA_AMORT_PVT.faxama
                        (px_trans_rec          => l_trans_rec,              -- uses DPIS for amort start
                         p_asset_hdr_rec       => p_asset_hdr_rec,
                         p_asset_desc_rec      => p_asset_desc_rec,
                         p_asset_cat_rec       => p_asset_cat_rec,
                         p_asset_type_rec      => p_asset_type_rec,
                         p_asset_fin_rec_old   => p_asset_fin_rec_new,
                         p_asset_fin_rec_adj   => l_asset_fin_rec_adj,
                         px_asset_fin_rec_new  => l_asset_fin_rec_new,
                         p_asset_deprn_rec     => p_asset_deprn_rec_old,
                         p_period_rec          => p_period_rec,
                         p_mrc_sob_type_code   => p_mrc_sob_type_code,
                         p_running_mode        => fa_std_types.FA_DPR_NORMAL,
                         p_used_by_revaluation => null,
                         p_reclassed_asset_id  => p_mem_asset_hdr_rec.asset_id,
                         p_reclass_src_dest    => p_src_dest,
                         p_reclassed_asset_dpis => p_mem_asset_fin_rec_new.date_placed_in_service,
                         x_deprn_exp           => l_deprn_exp,
                         x_bonus_deprn_exp     => l_bonus_deprn_exp,
                         x_impairment_exp      => l_impairment_exp
                        , p_log_level_rec => p_log_level_rec) then
                 raise grp_rec_err;
            end if;

            if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn, 'faxama from DPIS',l_deprn_exp, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, 'New eofy_reserve', l_asset_fin_rec_new.eofy_reserve, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, 'Old eofy_reserve', p_asset_fin_rec_old.eofy_reserve, p_log_level_rec => p_log_level_rec);
            end if;

            l_eofy_reserve := nvl(p_asset_fin_rec_old.eofy_reserve,0) - nvl(l_asset_fin_rec_new.eofy_reserve,0);
            px_group_reclass_options_rec.source_eofy_reserve := l_eofy_reserve;
            px_group_reclass_options_rec.destination_eofy_reserve := l_eofy_reserve;

            -- flip the sign as the amount will be negative since this is a negative cost adj
            l_total_rsv_amount := -l_deprn_exp;

            -- In case the Source Method is Year End Balance,
            -- Necessary Reserve Amount is NEW Eofy Reserve Amount.
            -- Here, the total rsv amount is calculated as New.Eofy - Old.Eofy
            -- This may be negative amount.
            if nvl(fa_cache_pkg.fazcdrd_record.subtract_ytd_flag,'N') = 'Y' then
              if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn, 'Source group method type', 'Year End Balance', p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, 'New eofy_reserve', l_asset_fin_rec_new.eofy_reserve, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, 'Old eofy_reserve', p_asset_fin_rec_old.eofy_reserve, p_log_level_rec => p_log_level_rec);
              end if;
              l_total_rsv_amount := nvl(p_asset_fin_rec_old.eofy_reserve,0) - nvl(l_asset_fin_rec_new.eofy_reserve,0);
              l_difference_eofy_reserve := l_total_rsv_amount;
            end if;
         else -- asset was originally standalone, use current reserve balance
           -- Bug# 3737670
           -- If the tracking method is 'CALCULATE' then doesn't need to reverse calculated reserve amount
           -- at member level. So set 0 to l_total_rsv_amount
           if nvl(l_asset_fin_rec_new.tracking_method,'NONE') = 'CALCULATE' then
             l_total_rsv_amount := 0;
           else
             l_total_rsv_amount := p_asset_deprn_rec_old.deprn_reserve;
           end if;

           if nvl(fa_cache_pkg.fazcdrd_record.subtract_ytd_flag,'N') = 'Y' then
             l_total_rsv_amount := nvl(l_eofy_reserve,0);
           end if;
         end if;

      else

        l_rsv_amount       := nvl(px_group_reclass_options_rec.reserve_amount, 0);
        l_total_rsv_amount := nvl(px_group_reclass_options_rec.reserve_amount, 0);
        if nvl(px_group_reclass_options_rec.source_eofy_reserve,0) = 0 then
           l_group_reclass_options_rec := px_group_reclass_options_rec;
           -- Call populate member amounts to get eofy_reserve;
           if not fa_group_reclass2_pvt.populate_member_amounts
                      (p_trans_rec                  => px_trans_rec,
                       p_asset_hdr_rec              => p_asset_hdr_rec,
                       p_asset_fin_rec_new          => p_asset_fin_rec_new,
                       p_mem_asset_hdr_rec          => p_mem_asset_hdr_rec,
                       p_mem_asset_fin_rec_new      => p_mem_asset_fin_rec_new,
                       px_group_reclass_options_rec => px_group_reclass_options_rec,
                       p_period_rec                 => p_period_rec,
                       p_mrc_sob_type_code          => p_mrc_sob_type_code,
                       p_src_dest                   => p_src_dest
                      , p_log_level_rec => p_log_level_rec) then
             raise grp_rec_err;
           end if;

           l_eofy_reserve := nvl(px_group_reclass_options_rec.source_eofy_reserve,0);
           px_group_reclass_options_rec := l_group_reclass_options_rec;

        else
           l_eofy_reserve := nvl(px_group_reclass_options_rec.destination_eofy_reserve,
                                 px_group_reclass_options_rec.source_eofy_reserve);
        end if;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'l_exp_amount(1)', l_exp_amount);
         fa_debug_pkg.add(l_calling_fn, 'l_rsv_amount(1)', l_rsv_amount);
         fa_debug_pkg.add(l_calling_fn, 'l_total_rsv_amount(1)', l_total_rsv_amount);
         fa_debug_pkg.add(l_calling_fn, 'l_eofy_reserve(1)', l_eofy_reserve);
      end if;

      -- get the portion of expense which the member contributed
      -- (starting from amort_start) for both source and desitnation
      --
      -- only needed when the transaction is backdated
      -- for the source asset, if the amort start = dpis,
      -- we can use the reserve amount in full
      -- but for destination, we always need the amount

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'amort start date',px_trans_rec.amortization_start_date , p_log_level_rec => p_log_level_rec);
      end if;

      if (px_trans_rec.amortization_start_date < p_period_rec.calendar_period_open_date) then

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'entering','catchup expense logic', p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'subtract_ytd_flag', fa_cache_pkg.fazcdrd_record.subtract_ytd_flag, p_log_level_rec => p_log_level_rec);
         end if;

         if ((px_trans_rec.amortization_start_date  <> p_mem_asset_fin_rec_new.date_placed_in_service OR
              p_src_dest = 'DESTINATION') and
              px_trans_rec.calling_interface ='FAPGADJ') then

           --bug6983091: getting expense just backed out
           -- Set up-to-date deprn info when it becomes standalone
           -- necessry because when reclassed out, there may be
           -- expense row created while processing source
           l_backed_out_exp := 0;
           if (p_src_dest = 'DESTINATION') and
              (l_asset_fin_rec_new.group_asset_id is null) and
              (p_asset_fin_rec_old.tracking_method = 'ALLOCATE' or
               (p_asset_fin_rec_old.tracking_method = 'CALCULATE' and
                nvl(p_asset_fin_rec_old.member_rollup_flag, 'N') = 'N')) then

              if p_mrc_sob_type_code <> 'R' then
                 OPEN c_get_exp_amount;
                 FETCH c_get_exp_amount INTO l_backed_out_exp;
                 CLOSE c_get_exp_amount;
              else
                 OPEN c_get_mc_exp_amount;
                 FETCH c_get_mc_exp_amount INTO l_backed_out_exp;
                 CLOSE c_get_mc_exp_amount;
              end if;
           end if;

           if (p_src_dest = 'SOURCE') then
             l_asset_fin_rec_adj.eofy_reserve := (-1)*l_eofy_reserve;
           else
             l_asset_fin_rec_adj.eofy_reserve := l_eofy_reserve;
           end if;

            if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn, 'faxama from amort date','before calling', p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, 'Adj eofy_reserve', l_asset_fin_rec_adj.eofy_reserve, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, 'p_asset_deprn_rec_old.deprn_reserve', p_asset_deprn_rec_old.deprn_reserve, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, 'l_backed_out_exp', l_backed_out_exp, p_log_level_rec => p_log_level_rec);
            end if;

            --bug6983091: setting up-to-date reserve
            l_asset_deprn_rec_old := p_asset_deprn_rec_old;
            l_asset_deprn_rec_old.deprn_reserve := l_asset_deprn_rec_old.deprn_reserve + nvl(l_backed_out_exp, 0);

           if not FA_AMORT_PVT.faxama
                     (px_trans_rec          => px_trans_rec,              -- use amort start
                      p_asset_hdr_rec       => p_asset_hdr_rec,
                      p_asset_desc_rec      => p_asset_desc_rec,
                      p_asset_cat_rec       => p_asset_cat_rec,
                      p_asset_type_rec      => p_asset_type_rec,
                      p_asset_fin_rec_old   => p_asset_fin_rec_new,
                      p_asset_fin_rec_adj   => l_asset_fin_rec_adj,
                      px_asset_fin_rec_new  => l_asset_fin_rec_new,
                      p_asset_deprn_rec     => l_asset_deprn_rec_old,
                      p_asset_deprn_rec_adj => l_asset_deprn_rec_adj,
                      p_period_rec          => p_period_rec,
                      p_mrc_sob_type_code   => p_mrc_sob_type_code,
                      p_running_mode        => fa_std_types.FA_DPR_NORMAL,
                      p_used_by_revaluation => null,
                      p_reclassed_asset_id  => p_mem_asset_hdr_rec.asset_id,
                      p_reclass_src_dest    => p_src_dest,
                      p_reclassed_asset_dpis => p_mem_asset_fin_rec_new.date_placed_in_service,
                      x_deprn_exp           => l_deprn_exp,
                      x_bonus_deprn_exp     => l_bonus_deprn_exp,
                      x_impairment_exp      => l_impairment_exp
                     , p_log_level_rec => p_log_level_rec) then
                raise grp_rec_err;
            end if;

            if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn, 'deprn expense from faxama',l_deprn_exp, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, 'Target group method type(expense)', 'Year End Balance');
              fa_debug_pkg.add(l_calling_fn, 'New eofy_reserve', l_asset_fin_rec_new.eofy_reserve, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, 'Old eofy_reserve', p_asset_fin_rec_old.eofy_reserve, p_log_level_rec => p_log_level_rec);
            end if;

--            l_eofy_reserve := nvl(l_asset_fin_rec_new.eofy_reserve,0);

            -- flip the sign as the amount will be negative since this is a negative cost adj
            if (p_src_dest = 'SOURCE') then
              l_exp_amount := -l_deprn_exp;
            else
              l_exp_amount := l_deprn_exp;
            end if;

            -- In case of Year End Balance, amort date can be set only DPIS of reclassified member or
            -- Current Date.
            -- If the amort date is set as DPIS of member, all amount is treated as expense.
            -- on the other hand, it is treated as reserve.
            if nvl(fa_cache_pkg.fazcdrd_record.subtract_ytd_flag,'N') = 'Y' and
               px_trans_rec.amortization_start_date = p_mem_asset_fin_rec_new.date_placed_in_service then
              if (p_src_dest = 'SOURCE') then
                l_exp_amount := l_total_rsv_amount;
              else
                l_exp_amount := nvl(p_asset_fin_rec_new.eofy_reserve,0) - nvl(p_asset_fin_rec_old.eofy_reserve,0);
              end if;
            -- BUG# 2774165: removing this code as it overwrights value from faxama
            --else
            --  l_exp_amount := 0;
            end if;

          else
            l_exp_amount := l_total_rsv_amount;
            l_eofy_reserve := 0;
        end if;
      else
         l_exp_amount := 0;
      end if;

      if (p_src_dest = 'SOURCE') then
        l_eofy_reserve := p_asset_fin_rec_new.eofy_reserve - l_asset_fin_rec_new.eofy_reserve;
      end if;

   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'l_exp_amount(2)', l_exp_amount);
      fa_debug_pkg.add(l_calling_fn, 'l_rsv_amount(2)', l_rsv_amount);
      fa_debug_pkg.add(l_calling_fn, 'l_total_rsv_amount(2)', l_total_rsv_amount);
      fa_debug_pkg.add(l_calling_fn, 'l_eofy_reserve(2)', l_eofy_reserve);
   end if;

   -- load the amounts regardless of the type of reclass
   -- signs are assumed to all be the same (i.e. generally +ve)
   -- with reliance on the debit_credit_flags to due the rest
   --
   -- need to insure the total reserve transfered from source
   -- is used here as well
   --
   -- reverting initial change for BUG# 2780960 as this section
   -- applies to calc and manual and is dependant on code above
   -- note that values for total_rsv are different in both scenarios
   -- for src and dest assets.  for destination total only stores the
   -- amount of reserve transfered from source at this point, so
   -- we need to add in the expense, not subtract it

   if (p_src_dest = 'DESTINATION') then
      l_rsv_amount       := l_total_rsv_amount;
      l_total_rsv_amount := l_total_rsv_amount + l_exp_amount;
   else
      l_rsv_amount := l_total_rsv_amount - l_exp_amount;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'l_exp_amount(3)', l_exp_amount);
      fa_debug_pkg.add(l_calling_fn, 'l_rsv_amount(3)', l_rsv_amount);
   end if;

   l_rsv_adj.adjustment_amount := l_rsv_amount;
   l_exp_adj.adjustment_amount := l_exp_amount; -- l_deprn_exp; (need to use one with same sign as tot_rsv)

   -- In case of Year End Balance, back the values into original amount
   if nvl(fa_cache_pkg.fazcdrd_record.subtract_ytd_flag,'N') = 'Y' then
     l_exp_amount := l_exp_amount_by_system;
   end if;
   -- if this is the source asset, reset the amount in the
   -- reclass structure to be the delta amount as dest will use this
   --  (i.e. the reserve which was transfered)
   -- if it's the destination, we need to update the total amount
   -- to be the transfered value + expense

   if (p_src_dest = 'SOURCE') then
      px_group_reclass_options_rec.reserve_amount := l_rsv_amount;
   else
      l_total_rsv_amount := l_rsv_amount + l_exp_amount;
   end if;

   -- flush all the reserve and expense rows to the db

   -- Fix for bug 3062207. Quick fix to not call faxinaj for CALC
   -- and FAXASSET combination since no reserve or exp rows must be inserted
   -- if called from faxasset.

    if (l_rsv_adj.adjustment_amount <> 0 and
       (px_group_reclass_options_rec.group_reclass_type <> 'CALC' OR
        px_trans_rec.calling_interface = 'FAPGADJ')) then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'calling faxinaj','for rsv', p_log_level_rec => p_log_level_rec);
      end if;

      if not FA_INS_ADJUST_PKG.faxinaj
                (l_rsv_adj,
                 px_trans_rec.who_info.last_update_date,
                 px_trans_rec.who_info.last_updated_by,
                 px_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
             raise grp_rec_err;
      end if;
   end if;

   if (l_exp_adj.adjustment_amount <> 0 and
       (px_group_reclass_options_rec.group_reclass_type <> 'CALC' OR
        px_trans_rec.calling_interface = 'FAPGADJ')) then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'calling faxinaj','for exp', p_log_level_rec => p_log_level_rec);
      end if;

      if not FA_INS_ADJUST_PKG.faxinaj
                (l_exp_adj,
                 px_trans_rec.who_info.last_update_date,
                 px_trans_rec.who_info.last_updated_by,
                 px_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
             raise grp_rec_err;
      end if;
   end if;


   -- now that rows are flushed, call the amort package again
   -- this time just to amortize the nbv over remaining life
   -- first we need to add the deprn effects to the deprn_old values

   l_asset_deprn_rec_new := p_asset_deprn_rec_old;

   -- Bug7487450: Modified condition in case of DESTINATION. if destination
   --             is standalone, and used to be tracked, then total amount
   --             will be the new rsv.
   if (p_src_dest = 'SOURCE') then
      l_asset_deprn_rec_new.deprn_reserve :=
         l_asset_deprn_rec_new.deprn_reserve - l_total_rsv_amount;
   else
      if (l_asset_fin_rec_new.group_asset_id is null) and
         (p_asset_fin_rec_old.tracking_method is not null) then
         l_asset_deprn_rec_new.deprn_reserve := l_total_rsv_amount;
      else
         l_asset_deprn_rec_new.deprn_reserve :=
              l_asset_deprn_rec_new.deprn_reserve + l_total_rsv_amount;
      end if;
   end if;

   if (p_src_dest = 'SOURCE') then
      l_asset_deprn_rec_adj.deprn_reserve := -1 * l_rsv_amount;
      l_asset_fin_rec_adj.eofy_reserve := (-1)*nvl(l_eofy_reserve,0);
      if (px_group_reclass_options_rec.group_reclass_type = 'CALC') and
         (p_asset_type_rec.asset_type = 'GROUP') and
         (p_asset_fin_rec_new.tracking_method is not null) then
        l_asset_fin_rec_new.eofy_reserve := nvl(l_asset_fin_rec_new.eofy_reserve,0) - nvl(l_eofy_reserve,0);
      elsif (px_group_reclass_options_rec.group_reclass_type = 'MANUAL') and
            (p_asset_type_rec.asset_type = 'GROUP') then
        l_asset_fin_rec_new.eofy_reserve := nvl(p_asset_fin_rec_old.eofy_reserve,0) - nvl(l_eofy_reserve,0);
      end if;
   else
      l_asset_fin_rec_adj.eofy_reserve := nvl(l_eofy_reserve,0);
      if (px_group_reclass_options_rec.group_reclass_type = 'MANUAL') and
         (p_asset_type_rec.asset_type = 'GROUP') then
        l_asset_fin_rec_new.eofy_reserve := nvl(p_asset_fin_rec_old.eofy_reserve,0) + nvl(l_eofy_reserve,0);
      else
        l_asset_fin_rec_new.eofy_reserve := nvl(l_asset_fin_rec_new.eofy_reserve,0) + nvl(l_eofy_reserve,0);
      end if;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'just before last call to faxama-p_src_dest',p_src_dest, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'existing reserve before last call to faxama',l_asset_deprn_rec_new.deprn_reserve , p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'new expense before last call to faxama',l_exp_amount , p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'new reserve before last call to faxama',l_rsv_amount, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'new total reserve before last call to faxama',l_total_rsv_amount, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'total reserve before last call to faxama',l_asset_deprn_rec_new.deprn_reserve , p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'old eofy reserve before last call to faxama',p_asset_fin_rec_new.eofy_reserve , p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'new eofy reserve before last call to faxama',l_asset_fin_rec_new.eofy_reserve , p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'adj eofy reserve before last call to faxama',l_asset_fin_rec_adj.eofy_reserve , p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'amort start date',px_trans_rec.amortization_start_date , p_log_level_rec => p_log_level_rec);
   end if;

-- +++ This won't be necessary
   l_trans_rec := px_trans_rec;
   l_trans_rec.amortization_start_date := null;  -- use current period


   -- no need to do the amort and update when an asset is
   -- reclassed into a group

/*
   if (((p_asset_type_rec.asset_type = 'GROUP') or
       (p_src_dest = 'DESTINATION' and
        p_asset_type_rec.asset_type = 'CAPITALIZED')) and
        (px_group_reclass_options_rec.group_reclass_type = 'MANUAL' OR
         (px_trans_rec.calling_interface <> 'FAXASSET' and
          px_group_reclass_options_rec.group_reclass_type = 'CALC'))) then
*/

   if ((p_asset_type_rec.asset_type = 'GROUP') or
       (p_src_dest = 'DESTINATION' and
        p_asset_type_rec.asset_type = 'CAPITALIZED')) then


       if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           'LAST CALL TO FAXAMA',
                           'CALLING FAXAMA', p_log_level_rec => p_log_level_rec);
       end if;


      -- use calc_raf_adj_cost rather than faxama if trx is in current
      -- period or it's a manual transaction for performance

      if (px_group_reclass_options_rec.group_reclass_type = 'MANUAL' or
          px_trans_rec.amortization_start_date >= p_period_rec.calendar_period_open_date) then

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'calling','calc_raf_adj_cost', p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'p_asset_deprn_rec_old.rsv',       p_asset_deprn_rec_old.deprn_reserve, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'p_asset_deprn_rec_old.bonus_rsv', p_asset_deprn_rec_old.bonus_deprn_reserve, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_asset_deprn_rec_adj.rsv',       l_asset_deprn_rec_adj.deprn_reserve, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_asset_deprn_rec_adj.bonus_rsv', l_asset_deprn_rec_adj.bonus_deprn_reserve, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_asset_deprn_rec_new.rsv',       l_asset_deprn_rec_new.deprn_reserve, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_asset_deprn_rec_new.bonus_rsv', l_asset_deprn_rec_new.bonus_deprn_reserve, p_log_level_rec => p_log_level_rec);
         end if;

         if not FA_AMORT_PVT.calc_raf_adj_cost
             (p_trans_rec           => px_trans_rec,
              p_asset_hdr_rec       => p_asset_hdr_rec,
              p_asset_desc_rec      => p_asset_desc_rec,
              p_asset_type_rec      => p_asset_type_rec,
              p_asset_fin_rec_old   => p_asset_fin_rec_old,
              px_asset_fin_rec_new  => l_asset_fin_rec_new,
              p_asset_deprn_rec_adj => l_asset_deprn_rec_adj, -- should contain the total delta (set to l_rsv)
              p_asset_deprn_rec_new => l_asset_deprn_rec_new, -- total new amount old + adj (set above)
              p_period_rec          => p_period_rec,
                    p_group_reclass_options_rec => px_group_reclass_options_rec,
              p_mrc_sob_type_code   => p_mrc_sob_type_code,
              p_log_level_rec       => p_log_level_rec
             ) then raise grp_rec_err;
         end if;

      elsif (px_trans_rec.calling_interface = 'FAPGADJ') then

         if not FA_AMORT_PVT.faxama
                     (px_trans_rec          => px_trans_rec,              -- use amort start date
                      p_asset_hdr_rec       => p_asset_hdr_rec,
                      p_asset_desc_rec      => p_asset_desc_rec,
                      p_asset_cat_rec       => p_asset_cat_rec,
                      p_asset_type_rec      => p_asset_type_rec,
                      p_asset_fin_rec_old   => p_asset_fin_rec_new,
                      p_asset_fin_rec_adj   => l_asset_fin_rec_adj,
                      px_asset_fin_rec_new  => l_asset_fin_rec_new,
                      p_asset_deprn_rec     => p_asset_deprn_rec_old,
                      p_asset_deprn_rec_adj => l_asset_deprn_rec_adj,
                      p_period_rec          => p_period_rec,
                      p_mrc_sob_type_code   => p_mrc_sob_type_code,
                      p_running_mode        => fa_std_types.FA_DPR_NORMAL,
                      p_used_by_revaluation => null,
                      p_reclassed_asset_id  => p_mem_asset_hdr_rec.asset_id,
                      p_reclass_src_dest    => p_src_dest,
                      p_reclassed_asset_dpis => p_mem_asset_fin_rec_new.date_placed_in_service,
                      x_deprn_exp           => l_deprn_exp,
                      x_bonus_deprn_exp     => l_bonus_deprn_exp,
                      x_impairment_exp      => l_impairment_exp
                     , p_log_level_rec => p_log_level_rec) then
            raise grp_rec_err;
         end if;
      end if;

      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn, 'new adjusted_cost after last call to faxama',l_asset_fin_rec_new.adjusted_cost, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'new eofy_reserve after last call to faxama',l_asset_fin_rec_new.eofy_reserve, p_log_level_rec => p_log_level_rec);
      end if;

      -- if reclassing out of the group to standalone, then
      -- insure the amount doesn't exceed the recoverable_cost
      -- of the standalone asset  (open issue - see japan / track member)

      --   if (l_temp_rsv + l_exp_amount > l_asset_fin_rec_new.recoverable_cost) then
      --      l_src_amount := l_src_asset_fin_rec_new.recoverable_cost;
      --   end if;

      -- now update fa_books with new RAF / adjusted_cost

      fa_books_pkg.update_row
            (X_asset_id                  => p_asset_hdr_rec.asset_id,
             X_book_type_code            => p_asset_hdr_rec.book_type_code,
             X_rate_adjustment_factor    => l_asset_fin_rec_new.rate_adjustment_factor,
             X_reval_amortization_basis  => l_asset_fin_rec_new.reval_amortization_basis,
             X_adjusted_cost             => l_asset_fin_rec_new.adjusted_cost,
             X_adjusted_capacity         => l_asset_fin_rec_new.adjusted_capacity,
             X_eofy_reserve              => l_asset_fin_rec_new.eofy_reserve,
             X_mrc_sob_type_code         => p_mrc_sob_type_code,
             X_set_of_books_id           => p_asset_hdr_rec.set_of_books_id,
             X_calling_fn                => l_calling_fn, p_log_level_rec => p_log_level_rec);

   end if;

   return true;

EXCEPTION
   when grp_rec_err then
        fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;

END do_adjustment;

----------------------------------------------
-- Function: populate_member_amounts
-- Description:
--    In case tracking is enabled, transferred amount will be populated from
--    tables.
----------------------------------------------

FUNCTION populate_member_amounts
   (p_trans_rec                  IN     FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec              IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_fin_rec_new          IN     FA_API_TYPES.asset_fin_rec_type,
    p_mem_asset_hdr_rec          IN     FA_API_TYPES.asset_hdr_rec_type,
    p_mem_asset_fin_rec_new      IN     FA_API_TYPES.asset_fin_rec_type,
    px_group_reclass_options_rec  IN OUT NOCOPY FA_API_TYPES.group_reclass_options_rec_type,
    p_period_rec                 IN     fa_api_types.period_rec_type,
    p_mrc_sob_type_code          IN     VARCHAR2,
    p_src_dest                   IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_asset_fin_rec_new           FA_API_TYPES.asset_fin_rec_type;

   h_book_type_code              varchar2(30);
   h_member_asset_id             number(15);
   h_group_asset_id              number(15);
   h_period_counter              number;
   h_cur_fiscal_year             number;
   h_amort_fiscal_year           number;

   h_reserve_dpis_current        number;
   h_reserve_dpis_amort          number;
   h_eofy_reserve                number;
   h_set_of_books_id             number;

   h_amort_start_date            date;

   h_ytd_deprn                   number;
   h_ds_fiscal_year              number;

   h_adj_eofy_reserve            number;
   h_adj_reserve                 number;

--* Cursor to populate the member level amounts
   cursor MEM_EXP_RESERVE is
     select ds1.deprn_reserve,ds1.ytd_deprn,dp1.fiscal_year
       from fa_deprn_summary ds1,
            fa_deprn_periods dp1
      where ds1.book_type_code = h_book_type_code
        and ds1.asset_id = h_member_asset_id
        and dp1.book_type_code = ds1.book_type_Code
        and dp1.period_counter = ds1.period_counter
        and ds1.period_counter =
            (select max(period_counter)
               from fa_deprn_summary ds2
              where ds2.book_type_code = h_book_type_code
                and ds2.asset_id = h_member_asset_id
                and period_counter <= h_period_counter);

   cursor MEM_EXP_RESERVE_MRC is
     select ds1.deprn_reserve,ds1.ytd_deprn,dp1.fiscal_year
       from fa_mc_deprn_summary ds1,
            fa_mc_deprn_periods dp1
      where ds1.book_type_code = h_book_type_code
        and ds1.asset_id = h_member_asset_id
        and dp1.book_type_code = ds1.book_type_Code
        and dp1.period_counter = ds1.period_counter
        and dp1.set_of_books_id = h_set_of_books_id
        and ds1.period_counter =
            (select max(period_counter)
               from fa_deprn_summary ds2
              where ds2.book_type_code = h_book_type_code
                and ds2.asset_id = h_member_asset_id
                and period_counter <= h_period_counter)
        and ds1.set_of_books_id = h_set_of_books_id;

--* Cursor for EOFY_RESERVE adjustment
cursor FA_RET_RSV is
  select sum(nvl(ret.reserve_retired,0) - nvl(ret.eofy_reserve,0))
    from fa_retirements ret
   where ret.book_type_code = h_book_type_code
     and ret.asset_id = h_member_asset_id
     and ret.transaction_header_id_in in
         (select th1.transaction_header_id
            from fa_transaction_headers th1,
                 fa_deprn_periods dp1,
                 fa_deprn_periods dp3
           where th1.asset_id = ret.asset_id
             and dp1.book_type_code = h_book_type_code
             and dp1.fiscal_year =
                 (select dp2.fiscal_year
                    from fa_deprn_periods dp2
                   where dp2.book_type_code = dp1.book_type_code
                     and dp2.period_Counter = h_period_counter - 1)
             and dp1.period_num = 1
             and dp3.book_type_code = dp1.book_type_code
             and dp3.period_counter = h_period_counter - 1
             and th1.transaction_date_entered >= dp1.calendar_period_open_date
             and th1.transaction_date_entered <= dp3.calendar_period_close_date
             and th1.transaction_type_code in ('PARTIAL RETIREMENT','FULL RETIREMENT'));

cursor FA_RET_RSV_MRC is
  select sum(nvl(ret.reserve_retired,0) - nvl(ret.eofy_reserve,0))
    from fa_mc_retirements ret
   where ret.book_type_code = h_book_type_code
     and ret.asset_id = h_member_asset_id
     and ret.set_of_books_id = h_set_of_books_id
     and ret.transaction_header_id_in in
         (select th1.transaction_header_id
            from fa_transaction_headers th1,
                 fa_deprn_periods dp1,
                 fa_deprn_periods dp3
           where th1.asset_id = ret.asset_id
             and dp1.book_type_code = h_book_type_code
             and dp1.fiscal_year =
                 (select dp2.fiscal_year
                    from fa_deprn_periods dp2
                   where dp2.book_type_code = dp1.book_type_code
                     and dp2.period_Counter = h_period_counter - 1)
             and dp1.period_num = 1
             and dp3.book_type_code = dp1.book_type_code
             and dp3.period_counter = h_period_counter - 1
             and th1.transaction_date_entered >= dp1.calendar_period_open_date
             and th1.transaction_date_entered <= dp3.calendar_period_close_date
             and th1.transaction_type_code in ('PARTIAL RETIREMENT','FULL RETIREMENT'));

cursor FA_ADJ_RESERVE is
   select sum(decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount))
     from fa_adjustments adj
    where adj.book_type_code = h_book_type_code
      and adj.asset_id = h_member_asset_id
      and adj.adjustment_type = 'RESERVE'
      and adj.source_type_code = 'ADJUSTMENT'
      and adj.period_counter_adjusted in
         (select dp2.period_counter
            from fa_deprn_periods dp1,
                 fa_deprn_periods dp2
           where dp1.book_type_code = adj.book_type_code
             and dp1.period_counter = h_period_counter - 1
             and dp2.book_type_code = dp1.book_type_code
             and dp2.fiscal_year = dp1.fiscal_year
             and dp2.period_counter <= dp1.period_counter);

cursor FA_ADJ_RESERVE_MRC is
   select sum(decode(adj.debit_credit_flag,
                     'DR',adj.adjustment_amount,
                     'CR', -1 * adj.adjustment_amount))
     from fa_mc_adjustments adj
    where adj.book_type_code = h_book_type_code
      and adj.asset_id = h_member_asset_id
      and adj.adjustment_type = 'RESERVE'
      and adj.source_type_code = 'ADJUSTMENT'
      and adj.set_of_books_id = h_set_of_books_id
      and adj.period_counter_adjusted in
         (select dp2.period_counter
            from fa_mc_deprn_periods dp1,
                 fa_mc_deprn_periods dp2
           where dp1.book_type_code = adj.book_type_code
             and dp1.period_counter = h_period_counter - 1
             and dp1.set_of_books_id = h_set_of_books_id
             and dp2.book_type_code = dp1.book_type_code
             and dp2.fiscal_year = dp1.fiscal_year
             and dp2.set_of_books_id = h_set_of_books_id
             and dp2.period_counter <= dp1.period_counter);


   l_calling_fn                  VARCHAR2(50) := 'fa_group_reclass_pvt.populate_member_amounts';
   pop_mem_amt_err               EXCEPTION;


BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'populate member amt',p_trans_rec.amortization_start_date , p_log_level_rec => p_log_level_rec);
   end if;

   l_asset_fin_rec_new := p_asset_fin_rec_new;
   h_book_type_code := p_asset_hdr_rec.book_type_code;
   h_group_asset_id := p_asset_hdr_rec.asset_id;
   h_member_asset_id := p_mem_asset_hdr_rec.asset_id;
   h_amort_start_date := nvl(p_trans_rec.amortization_start_date,sysdate);
   h_set_of_books_id := p_asset_hdr_rec.set_of_books_id;
   h_eofy_reserve := p_asset_fin_rec_new.eofy_reserve;

   -- Populate Subtract Ytd Flag
   if not fa_cache_pkg.fazccmt(X_method => l_asset_fin_rec_new.deprn_method_code,
                               X_life => l_asset_fin_rec_new.life_in_months, p_log_level_rec => p_log_level_rec) then
     raise pop_mem_amt_err;
   end if;

   -- Get Period Counter for current period
   h_period_counter := fa_cache_pkg.fazcbc_record.last_period_counter;

   -- Get Reserve Amount between member's DPIS and current period -- For Source Group Reserve
   if p_mrc_sob_type_code <> 'R' then

       select fiscal_year into h_cur_fiscal_year
         from fa_deprn_periods
        where book_type_code = h_book_type_code
          and period_counter = h_period_counter;

       open MEM_EXP_RESERVE;
       fetch MEM_EXP_RESERVE into h_reserve_dpis_current,h_ytd_deprn,h_ds_fiscal_year;
       if MEM_EXP_RESERVE%NOTFOUND then
         h_reserve_dpis_current := 0;
       end if;
       close MEM_EXP_RESERVE;

       open FA_RET_RSV;
       fetch FA_RET_RSV into h_adj_eofy_reserve;
       close FA_RET_RSV;

       open FA_ADJ_RESERVE;
       fetch FA_ADJ_RESERVE into h_adj_reserve;
       close FA_ADJ_RESERVE;

   else

       select fiscal_year into h_cur_fiscal_year
         from fa_mc_deprn_periods
        where book_type_code = h_book_type_code
          and period_counter = h_period_counter
          and set_of_books_id = h_set_of_books_id;

       open MEM_EXP_RESERVE_MRC;
       fetch MEM_EXP_RESERVE_MRC into h_reserve_dpis_current,h_ytd_deprn,h_ds_fiscal_year;
       if MEM_EXP_RESERVE_MRC%NOTFOUND then
         h_reserve_dpis_current := 0;
       end if;
       close MEM_EXP_RESERVE_MRC;

       open FA_RET_RSV_MRC;
       fetch FA_RET_RSV_MRC into h_adj_eofy_reserve;
       close FA_RET_RSV_MRC;

       open FA_ADJ_RESERVE_MRC;
       fetch FA_ADJ_RESERVE_MRC into h_adj_reserve;
       close FA_ADJ_RESERVE_MRC;

   end if;

   -- calculate current eofy_reserve using amounts above
   h_eofy_reserve := p_mem_asset_fin_rec_new.eofy_reserve;

   if (p_log_level_rec.statement_level) then
     fa_debug_pkg.add(l_calling_fn,'h_eofy_reserve',h_eofy_reserve, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn,'h_cur_fiscal_yesr',h_cur_fiscal_year, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn,'h_ds_fiscal_year',h_ds_fiscal_year, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn,'h_reserve_dpis_current',h_reserve_dpis_current, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn,'h_ytd_deprn',h_ytd_deprn, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn,'h_adj_eofy_reserve',h_adj_eofy_reserve, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn,'h_adj_reserve',h_adj_reserve, p_log_level_rec => p_log_level_rec);
   end if;

   if nvl(h_eofy_reserve,0) = 0 then
     if h_cur_fiscal_year = h_ds_fiscal_year then
       h_eofy_reserve := h_reserve_dpis_current - h_ytd_deprn + nvl(h_adj_eofy_reserve,0) + nvl(h_adj_reserve,0);
     else
       h_eofy_reserve := h_reserve_dpis_current;
     end if;
   end if;

   if nvl(fa_cache_pkg.fazcdrd_record.subtract_ytd_flag,'N') = 'Y' then
     h_reserve_dpis_current := nvl(h_eofy_reserve,0);
   end if; -- Subtarct Flag

   if (p_src_dest = 'SOURCE') then
     px_group_reclass_options_rec.reserve_amount := h_reserve_dpis_current;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'reserve_amount',px_group_reclass_options_rec.reserve_amount, p_log_level_rec => p_log_level_rec);
   end if;

   -- Get Period Counter of amortization start date
   if (p_trans_rec.amortization_start_date <> p_mem_asset_fin_rec_new.date_placed_in_service) then

       --Bug6933735: Replaced fa_deprn_period based cursor with following.
       select fy.fiscal_year * ct.NUMBER_PER_FISCAL_YEAR + cp.PERIOD_NUM period_counter
            , fy.fiscal_year fiscal_year
       into   h_period_counter,h_amort_fiscal_year
       from   fa_fiscal_year fy
            , fa_calendar_types ct
            , fa_calendar_periods cp
       where  fa_cache_pkg.fazcbc_record.deprn_calendar = ct.calendar_type
       and    fa_cache_pkg.fazcbc_record.fiscal_year_name = fy.fiscal_year_name
       and    ct.fiscal_year_name = fa_cache_pkg.fazcbc_record.fiscal_year_name
       and    ct.calendar_type = cp.calendar_type
       and    cp.start_date between fy.start_date and fy.end_date
       and    fa_cache_pkg.fazcbc_record.last_period_counter + 1 >= fy.fiscal_year * ct.NUMBER_PER_FISCAL_YEAR + cp.PERIOD_NUM
       and    h_amort_start_date between cp.start_date and cp.end_date;

       h_period_counter := h_period_counter - 1;

       -- Get Reserve Amount between amortization start date and current date -- For destination
       if (p_mrc_sob_type_code <> 'R') then

         open MEM_EXP_RESERVE;
         fetch MEM_EXP_RESERVE into h_reserve_dpis_amort,h_ytd_deprn,h_ds_fiscal_year;
         if MEM_EXP_RESERVE%NOTFOUND then
           h_reserve_dpis_amort := 0;
         end if;
         close MEM_EXP_RESERVE;

         open FA_RET_RSV;
         fetch FA_RET_RSV into h_adj_eofy_reserve;
         close FA_RET_RSV;

         open FA_ADJ_RESERVE;
         fetch FA_ADJ_RESERVE into h_adj_reserve;
         close FA_ADJ_RESERVE;

       else

         open MEM_EXP_RESERVE_MRC;
         fetch MEM_EXP_RESERVE_MRC into h_reserve_dpis_amort,h_ytd_deprn,h_ds_fiscal_year;
         if MEM_EXP_RESERVE_MRC%NOTFOUND then
           h_reserve_dpis_amort := 0;
         end if;
         close MEM_EXP_RESERVE_MRC;

         open FA_RET_RSV_MRC;
         fetch FA_RET_RSV_MRC into h_adj_eofy_reserve;
         close FA_RET_RSV_MRC;

         open FA_ADJ_RESERVE_MRC;
         fetch FA_ADJ_RESERVE_MRC into h_adj_reserve;
         close FA_ADJ_RESERVE_MRC;

       end if;

       if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'h_cur_fiscal_yesr',h_cur_fiscal_year, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'h_amort_fiscal_year',h_amort_fiscal_year, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'h_ds_fiscal_year',h_ds_fiscal_year, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'h_reserve_dpis_amort',h_reserve_dpis_amort, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'h_ytd_deprn',h_ytd_deprn, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'h_adj_eofy_reserve',h_adj_eofy_reserve, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'h_adj_reserve',h_adj_reserve, p_log_level_rec => p_log_level_rec);
       end if;

       -- calculate current eofy_reserve using amounts above
       if h_cur_fiscal_year <> h_amort_fiscal_year then
         if h_amort_fiscal_year = h_ds_fiscal_year then
           h_eofy_reserve := h_reserve_dpis_amort - h_ytd_deprn + nvl(h_adj_eofy_reserve,0) + nvl(h_adj_reserve,0);
         else
           h_eofy_reserve := h_reserve_dpis_amort;
         end if;
       end if;

       px_group_reclass_options_rec.source_exp_amount := h_reserve_dpis_current - h_reserve_dpis_amort;
--       px_group_reclass_options_rec.reserve_amount := h_reserve_dpis_amort;

   else -- amortization start date is equal to the DPIS

     h_eofy_reserve := 0;
     px_group_reclass_options_rec.source_exp_amount := h_reserve_dpis_current;

   end if;

   px_group_reclass_options_rec.source_eofy_reserve := h_eofy_reserve;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'reserve_dpis_current',h_reserve_dpis_current, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,'reserve_dpis_amort',h_reserve_dpis_amort, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,'source_exp_amount',px_group_reclass_options_rec.source_exp_amount, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,'eofy_reserve',px_group_reclass_options_rec.source_eofy_reserve, p_log_level_rec => p_log_level_rec);
   end if;

--   x_eofy_reserve := h_eofy_reserve;

return true;

EXCEPTION
   when pop_mem_amt_err then
        fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;

end populate_member_amounts;


END FA_GROUP_RECLASS2_PVT;

/
