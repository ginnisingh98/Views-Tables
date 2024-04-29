--------------------------------------------------------
--  DDL for Package Body FA_ADDITION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_ADDITION_PUB" AS
/* $Header: FAPADDB.pls 120.27.12010000.5 2009/08/13 04:51:03 bmaddine ship $   */

--*********************** Global constants *******************************--
G_PKG_NAME      CONSTANT   varchar2(30) := 'FA_ADDITION_PUB';
G_API_NAME      CONSTANT   varchar2(30) := 'Addition API';
G_API_VERSION   CONSTANT   number       := 1.0;

g_log_level_rec fa_api_types.log_level_rec_type;

g_release                  number  := fa_cache_pkg.fazarel_release;

--*********************** Private procedures *****************************--

function do_all_books (
   p_trans_rec               IN     fa_api_types.trans_rec_type,
   p_primary_asset_hdr_rec   IN     fa_api_types.asset_hdr_rec_type,
   p_primary_asset_fin_rec   IN     fa_api_types.asset_fin_rec_type,
   p_primary_asset_deprn_rec IN     fa_api_types.asset_deprn_rec_type,
   p_report_asset_hdr_rec    IN     fa_api_types.asset_hdr_rec_type,
   x_report_asset_fin_rec       OUT NOCOPY fa_api_types.asset_fin_rec_type,
   x_report_asset_deprn_rec     OUT NOCOPY fa_api_types.asset_deprn_rec_type,
   p_asset_fin_mrc_tbl       IN     fa_api_types.asset_fin_tbl_type,
   p_asset_deprn_mrc_tbl     IN     fa_api_types.asset_deprn_tbl_type,
   p_inv_tbl                 IN     fa_api_types.inv_tbl_type,
   x_exchange_rate              OUT NOCOPY NUMBER,
   x_return_status              OUT NOCOPY VARCHAR2,
   p_calling_fn              IN     VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

--*********************** Public procedures ******************************--
procedure do_addition (
   -- Standard Parameters --
   p_api_version              IN      NUMBER,
   p_init_msg_list            IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                   IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level         IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL,
   x_return_status               OUT NOCOPY  VARCHAR2,
   x_msg_count                   OUT NOCOPY  NUMBER,
   x_msg_data                    OUT NOCOPY  VARCHAR2,
   p_calling_fn               IN      VARCHAR2,
   -- Transaction Object --
   px_trans_rec                IN OUT NOCOPY  fa_api_types.trans_rec_type,
   px_dist_trans_rec           IN OUT NOCOPY  fa_api_types.trans_rec_type,
   -- Asset Object --
   px_asset_hdr_rec            IN OUT NOCOPY  fa_api_types.asset_hdr_rec_type,
   px_asset_desc_rec           IN OUT NOCOPY  fa_api_types.asset_desc_rec_type,
   px_asset_type_rec           IN OUT NOCOPY  fa_api_types.asset_type_rec_type,
   px_asset_cat_rec            IN OUT NOCOPY  fa_api_types.asset_cat_rec_type,
   px_asset_hierarchy_rec      IN OUT NOCOPY  fa_api_types.asset_hierarchy_rec_type,
   px_asset_fin_rec            IN OUT NOCOPY  fa_api_types.asset_fin_rec_type,
   px_asset_deprn_rec          IN OUT NOCOPY  fa_api_types.asset_deprn_rec_type,
   px_asset_dist_tbl           IN OUT NOCOPY  fa_api_types.asset_dist_tbl_type,
   -- Invoice Object --
   px_inv_tbl                  IN OUT NOCOPY  fa_api_types.inv_tbl_type) is

   add_err1                       exception;  -- sets return status
   add_err2                       exception;  -- does not set return status

   -- For corporate and tax books
   l_trans_rec                    fa_api_types.trans_rec_type;
   l_dist_trans_rec               fa_api_types.trans_rec_type;
   l_asset_hdr_rec                fa_api_types.asset_hdr_rec_type;
   l_asset_fin_rec_old            fa_api_types.asset_fin_rec_type;
   l_asset_fin_rec                fa_api_types.asset_fin_rec_type;
   l_asset_fin_rec_new            fa_api_types.asset_fin_rec_type;
   l_asset_fin_mrc_tbl_new        fa_api_types.asset_fin_tbl_type;
   l_asset_deprn_rec_old          fa_api_types.asset_deprn_rec_type;
   l_asset_deprn_rec_new          fa_api_types.asset_deprn_rec_type;
   l_asset_deprn_mrc_tbl          fa_api_types.asset_deprn_tbl_type;

   l_inv_rec                      fa_api_types.inv_rec_type;
   l_inv_trans_rec                fa_api_types.inv_trans_rec_type;
   l_period_rec                   fa_api_types.period_rec_type;

   l_tax_book_tbl                 fa_cache_pkg.fazctbk_tbl_type;
   l_initial_book                 boolean := TRUE;

   -- For primary and reporting books
   l_reporting_flag               varchar2(1) := 'P';
   l_rsob_tbl                     fa_cache_pkg.fazcrsob_sob_tbl_type;
   l_mrc_asset_hdr_rec            fa_api_types.asset_hdr_rec_type;
   l_mrc_asset_fin_rec_adj        fa_api_types.asset_fin_rec_type;
   l_mrc_asset_fin_rec_new        fa_api_types.asset_fin_rec_type;
   l_mrc_asset_deprn_rec_adj      fa_api_types.asset_deprn_rec_type;
   l_mrc_asset_deprn_rec_new      fa_api_types.asset_deprn_rec_type;
   l_exchange_rate                number;
   l_asset_hr_attr_rec_old        FA_API_TYPES.asset_hr_attr_rec_type;
   l_asset_hr_attr_rec_new        FA_API_TYPES.asset_hr_attr_rec_type;

   -- used for new group code
   l_group_trans_rec              fa_api_types.trans_rec_type;
   l_group_asset_hdr_rec          fa_api_types.asset_hdr_rec_type;
   l_group_asset_desc_rec         fa_api_types.asset_desc_rec_type;
   l_group_asset_type_rec         fa_api_types.asset_type_rec_type;
   l_group_asset_cat_rec          fa_api_types.asset_cat_rec_type;
   l_group_asset_fin_rec_old      fa_api_types.asset_fin_rec_type;
   l_group_asset_fin_rec_adj      fa_api_types.asset_fin_rec_type;
   l_group_asset_fin_rec_new      fa_api_types.asset_fin_rec_type;
   l_group_asset_deprn_rec_old    fa_api_types.asset_deprn_rec_type;
   l_group_asset_deprn_rec_adj    fa_api_types.asset_deprn_rec_type;
   l_group_asset_deprn_rec_new    fa_api_types.asset_deprn_rec_type;

   l_group_reclass_options_rec    fa_api_types.group_reclass_options_rec_type;

   l_cip_cost                     number  := 0;
   l_calling_fn  varchar2(30) := 'fa_addition_pub.do_addition';

begin

   SAVEPOINT do_addition;

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise add_err1;
      end if;
   end if;

   g_release  := fa_cache_pkg.fazarel_release;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   if (fnd_api.to_boolean(p_init_msg_list)) then
        -- initialize error message stack.
        fa_srvr_msg.init_server_message;

        -- initialize debug message stack.
        fa_debug_pkg.initialize;
   end if;

   -- Check version of the API
   -- Standard call to check for API call compatibility.
   if (NOT fnd_api.compatible_api_call (
          G_API_VERSION,
          p_api_version,
          G_API_NAME,
          G_PKG_NAME
   )) then
      raise add_err1;
   end if;

   -- Call the cache for the primary transaction book
   if (NOT fa_cache_pkg.fazcbc (
      X_book => px_asset_hdr_rec.book_type_code
   , p_log_level_rec => g_log_level_rec)) then
      raise add_err1;
   end if;

   -- Initialize the incoming values.
   if (NOT fa_addition_pvt.initialize (
          px_trans_rec              => px_trans_rec,
          px_dist_trans_rec         => px_dist_trans_rec,
          px_asset_hdr_rec          => px_asset_hdr_rec,
          px_asset_desc_rec         => px_asset_desc_rec,
          px_asset_type_rec         => px_asset_type_rec,
          px_asset_cat_rec          => px_asset_cat_rec,
          px_asset_hierarchy_rec    => px_asset_hierarchy_rec,
          px_asset_fin_rec          => px_asset_fin_rec,
          px_asset_deprn_rec        => px_asset_deprn_rec,
          px_asset_dist_tbl         => px_asset_dist_tbl,
          px_inv_tbl                => px_inv_tbl,
          x_return_status           => x_return_status,
          p_calling_fn              => 'fa_addition_pub.do_addition'
   , p_log_level_rec => g_log_level_rec)) then
      raise add_err2;
   end if;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('add after validate','allow_neg_nbv_type',
            px_asset_fin_rec.over_depreciate_option, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add('add after validate','px_asset_fin_rec.method',
            px_asset_fin_rec.deprn_method_code, p_log_level_rec => g_log_level_rec);
      end if;

   -- this function will check if parent is valid, otherwise return false
   -- check if override is allowed, otherwise return false
   -- derive asset attributes
   if px_asset_hierarchy_rec.parent_hierarchy_id is not null then
      if NOT fa_asset_hierarchy_pvt.derive_asset_attribute (
            px_asset_hdr_rec          => px_asset_hdr_rec,
            px_asset_desc_rec         => px_asset_desc_rec,
            px_asset_cat_rec          => px_asset_cat_rec,
            px_asset_hierarchy_rec    => px_asset_hierarchy_rec,
            px_asset_fin_rec          => px_asset_fin_rec,
            px_asset_dist_tbl         => px_asset_dist_tbl,
            p_derivation_type         => 'ALL',
            p_calling_function        => 'fa_addition_pub.do_addition' ,
            p_log_level_rec => g_log_level_rec) then
         raise add_err1;
      end if;
   end if;

   -- Call the cache to get the dependent tax books
   if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then
      if (NOT fa_cache_pkg.fazctbk (
         x_corp_book    => px_asset_hdr_rec.book_type_code,
         x_asset_type   => px_asset_type_rec.asset_type,
         x_tax_book_tbl => l_tax_book_tbl
      , p_log_level_rec => g_log_level_rec)) then
         raise add_err1;
      end if;
   end if;
   /*Bug# 8527619 */
   if px_asset_fin_rec.group_Asset_id is not null then
      if not FA_ASSET_VAL_PVT.validate_over_depreciation
         (p_asset_hdr_rec     => px_asset_hdr_rec,
          p_asset_fin_rec     => px_asset_fin_rec,
          p_validation_type   => 'ADDITION',
          p_cost_adj          => px_asset_fin_rec.cost,
          p_rsv_adj           => 0,
          p_log_level_rec     => g_log_level_rec) then
          raise add_err1;
       end if;
   end if;
   for book_index in 0..l_tax_book_tbl.COUNT loop

      l_asset_hdr_rec := px_asset_hdr_rec;
      l_trans_rec := px_trans_rec;

      -- BUG# 2417746 - populate the source_thid here for auto-copy
      --                and cip-in-tax loops
      if (book_index > 0) then
         l_trans_rec.source_transaction_header_id :=
            px_trans_rec.transaction_header_id;
      end if;

      -- Pop the transaction_header_id for the ADDITION row
      select fa_transaction_headers_s.nextval
      into   l_trans_rec.transaction_header_id
      from   dual;

      -- if the counter book_index is at 0, then process incoming
      -- book else iterate through tax books
      if (book_index = 0) then
         l_asset_hdr_rec.book_type_code :=
            px_asset_hdr_rec.book_type_code;

         l_initial_book := TRUE;
      else
         l_asset_hdr_rec.book_type_code :=
            l_tax_book_tbl(book_index);

         l_initial_book := FALSE;
      end if;

      -- call the cache for the primary transaction book
      if (NOT fa_cache_pkg.fazcbc (
          X_book => l_asset_hdr_rec.book_type_code
      , p_log_level_rec => g_log_level_rec)) then
          raise add_err1;
      end if;

      l_asset_hdr_rec.set_of_books_id :=
         fa_cache_pkg.fazcbc_record.set_of_books_id;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('Corporate/Tax Book','c_t_book',
            l_asset_hdr_rec.book_type_code, p_log_level_rec => g_log_level_rec);
      end if;

      if (NOT FA_UTIL_PVT.get_period_rec (
         p_book           => l_asset_hdr_rec.book_type_code,
         p_effective_date => NULL,
         x_period_rec     => l_period_rec
      , p_log_level_rec => g_log_level_rec)) then
         raise add_err1;
      end if;

      if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then
         -- Set the transaction_header_id for the corp book for later.
         px_trans_rec.transaction_header_id :=
            l_trans_rec.transaction_header_id;

         -- For the TRANSFER IN row, thid is shared for all corp/tax books.
         select fa_transaction_headers_s.nextval
         into   px_dist_trans_rec.transaction_header_id
         from   dual;

         -- Set the current fin_rec to the one that was passed in.
         l_asset_fin_rec := px_asset_fin_rec;
         l_asset_deprn_rec_new := px_asset_deprn_rec;
      else
         -- Check to see if the source_transaction_header_id need to be
         -- populated.   BMR: removing this code as we should only
         -- populate for trxs where the tax trx is spawned automatically
         -- from corp (either via cip-in-tax, autocopy, masscopy)
         --   ...  old code ...   see BUG# 2417746 for more details

         -- If this is a tax book and was the initial book passed, then we
         -- to set fin_rec to what was passed in.  The initialize function
         -- will have already handled everything.
         if (l_initial_book = TRUE) then
            l_asset_fin_rec := px_asset_fin_rec;
            --Bug 6377492
            px_trans_rec.transaction_header_id := l_trans_rec.transaction_header_id;

         else
            -- Otherwise we need to clear fin_rec and deprn_rec of everything
            -- except cost and let calc engine determine everything.
            l_asset_fin_rec := NULL;
            l_asset_deprn_rec_new := NULL;

            -- Initialize the incoming values.
            if (NOT fa_addition_pvt.initialize (
                   px_trans_rec              => l_trans_rec,
                   px_dist_trans_rec         => px_dist_trans_rec,
                   px_asset_hdr_rec          => l_asset_hdr_rec,
                   px_asset_desc_rec         => px_asset_desc_rec,
                   px_asset_type_rec         => px_asset_type_rec,
                   px_asset_cat_rec          => px_asset_cat_rec,
                   px_asset_hierarchy_rec    => px_asset_hierarchy_rec,
                   px_asset_fin_rec          => l_asset_fin_rec,
                   px_asset_deprn_rec        => l_asset_deprn_rec_new,
                   px_asset_dist_tbl         => px_asset_dist_tbl,
                   px_inv_tbl                => px_inv_tbl,
                   x_return_status           => x_return_status,
                   p_calling_fn              => 'fa_addition_pub.do_addition'
            , p_log_level_rec => g_log_level_rec)) then
               raise add_err2;
            end if;

            if (px_asset_type_rec.asset_type = 'GROUP') then
               l_asset_fin_rec.cost                            := 0;
               --  HH group ed.  Also set disabled_flag to Null as we
               -- want group assets added w/ the flag null.
               l_asset_fin_rec.disabled_flag := NULL; -- end HH

               l_asset_fin_rec.over_depreciate_option          := px_asset_fin_rec.over_depreciate_option;
               l_asset_fin_rec.super_group_id                  := px_asset_fin_rec.super_group_id;
               l_asset_fin_rec.reduction_rate                  := px_asset_fin_rec.reduction_rate;
               l_asset_fin_rec.reduce_addition_flag            := px_asset_fin_rec.reduce_addition_flag;
               l_asset_fin_rec.reduce_adjustment_flag          := px_asset_fin_rec.reduce_adjustment_flag;
               l_asset_fin_rec.reduce_retirement_flag          := px_asset_fin_rec.reduce_retirement_flag;
               l_asset_fin_rec.recognize_gain_loss             := px_asset_fin_rec.recognize_gain_loss;
               l_asset_fin_rec.recapture_reserve_flag          := px_asset_fin_rec.recapture_reserve_flag;
               l_asset_fin_rec.limit_proceeds_flag             := px_asset_fin_rec.limit_proceeds_flag;
               l_asset_fin_rec.terminal_gain_loss              := px_asset_fin_rec.terminal_gain_loss;
               l_asset_fin_rec.tracking_method                 := px_asset_fin_rec.tracking_method;
               l_asset_fin_rec.exclude_fully_rsv_flag          := px_asset_fin_rec.exclude_fully_rsv_flag;
               l_asset_fin_rec.excess_allocation_option        := px_asset_fin_rec.excess_allocation_option;
               l_asset_fin_rec.depreciation_option             := px_asset_fin_rec.depreciation_option;
               l_asset_fin_rec.member_rollup_flag              := px_asset_fin_rec.member_rollup_flag;
               l_asset_fin_rec.allocate_to_fully_rsv_flag      := px_asset_fin_rec.allocate_to_fully_rsv_flag;
               l_asset_fin_rec.allocate_to_fully_ret_flag      := px_asset_fin_rec.allocate_to_fully_ret_flag;

            else
               l_asset_fin_rec.cost := px_asset_fin_rec.cost;
            end if;

         end if;
      end if;

      -- Determine the asset_number if it was not provided
      if (px_asset_desc_rec.asset_number is null) then
         px_asset_desc_rec.asset_number :=
            to_char (px_asset_hdr_rec.asset_id);
      end if;

      -- Process invoices if they exist
      -- ignore group assets that might be coming from mass additions
      -- as we don't want the invoice info maintained

      if (px_inv_tbl.count > 0) and
         (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') and
         (px_asset_type_rec.asset_type <> 'GROUP')then

         if (l_trans_rec.calling_interface = 'FAMAPT') then
            l_inv_trans_rec.transaction_type := 'MASS ADDITION';
         else
            l_inv_trans_rec.transaction_type := 'INVOICE ADDITION';
         end if;

         if (NOT fa_invoice_pvt.invoice_engine (
           px_trans_rec               => l_trans_rec,
           px_asset_hdr_rec           => l_asset_hdr_rec,
           p_asset_desc_rec           => px_asset_desc_rec,
           p_asset_type_rec           => px_asset_type_rec,
           p_asset_cat_rec            => px_asset_cat_rec,
           p_asset_fin_rec_adj        => l_asset_fin_rec,
           x_asset_fin_rec_new        => l_asset_fin_rec_new,
           x_asset_fin_mrc_tbl_new    => l_asset_fin_mrc_tbl_new,
           px_inv_trans_rec           => l_inv_trans_rec,
           px_inv_tbl                 => px_inv_tbl,
           x_asset_deprn_rec_new      => l_asset_deprn_rec_new,
           x_asset_deprn_mrc_tbl_new  => l_asset_deprn_mrc_tbl,
           p_calling_fn               => 'fa_addition_pub.do_addition',
           p_log_level_rec => g_log_level_rec)) then
            raise add_err1;
         end if;

         l_cip_cost := l_asset_fin_rec_new.cip_cost;

         -- Need to account for case from FAXASSET if source
         -- lines were added through Detail Addition w/ no cost.
         if ((l_asset_fin_rec_new.cost = 0) and
             (px_asset_fin_rec.cost <> 0)) then
            l_asset_fin_rec_new := l_asset_fin_rec;
            l_asset_deprn_rec_new := px_asset_deprn_rec;
            l_asset_fin_mrc_tbl_new.delete;
            l_asset_deprn_mrc_tbl.delete;
         end if;
      else
         -- Need to set the new rec to the old rec so we
         -- are passing the same recs in for both non invoices
         -- and assets w/ invoices.
         l_asset_fin_rec_new := l_asset_fin_rec;
         l_asset_deprn_rec_new := px_asset_deprn_rec;

      end if;


      if (px_asset_type_rec.asset_type <> 'CIP') then
         l_asset_fin_rec_new.cip_cost := 0;
      elsif (nvl(fa_cache_pkg.fazcbc_record.allow_cip_dep_group_flag, 'N') = 'Y') then
         l_asset_fin_rec_new.cip_cost := l_cip_cost;
      else
         l_asset_fin_rec_new.cip_cost := l_asset_fin_rec_new.cost;
      end if;


      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('add after inv engine','allow_neg_nbv_type',
            l_asset_fin_rec_new.over_depreciate_option, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add('add after inv engine','l_asset_fin_rec.method',
            l_asset_fin_rec.deprn_method_code, p_log_level_rec => g_log_level_rec);

      end if;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('add before validate','allow_neg_nbv_type',
            l_asset_fin_rec.over_depreciate_option, p_log_level_rec => g_log_level_rec);
      end if;

      if (p_validation_level = FND_API.G_VALID_LEVEL_FULL) then

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('add before validate','asset_type',
            px_asset_type_rec.asset_type, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add('add before validate','trx_type',
            l_trans_rec.transaction_type_code, p_log_level_rec => g_log_level_rec);
      end if;


         -- Complete the initial validation of the asset.
         if (NOT fa_asset_val_pvt.validate (
              p_trans_rec               => l_trans_rec,
              p_asset_hdr_rec           => l_asset_hdr_rec,
              p_asset_desc_rec          => px_asset_desc_rec,
              p_asset_type_rec          => px_asset_type_rec,
              p_asset_cat_rec           => px_asset_cat_rec,
              p_asset_fin_rec           => l_asset_fin_rec_new,
              p_asset_deprn_rec         => l_asset_deprn_rec_new,
              p_asset_dist_tbl          => px_asset_dist_tbl,
              p_inv_tbl                 => px_inv_tbl,
              p_calling_fn              => 'fa_addition_pub.do_addition'
         , p_log_level_rec => g_log_level_rec)) then
               raise add_err1;
         end if;
      end if;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('add after validate','allow_neg_nbv_type',
            l_asset_fin_rec.over_depreciate_option, p_log_level_rec => g_log_level_rec);
      end if;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('Book','l_asset_hdr_rec.book_type_code',
           l_asset_hdr_rec.book_type_code, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add('SOB','l_asset_hdr_rec.set_of_books_id',
           to_char (l_asset_hdr_rec.set_of_books_id));
      end if;

      -- Call cache to verify whether this is a primary or reporting book
      if (NOT fa_cache_pkg.fazcsob (
         X_set_of_books_id   => l_asset_hdr_rec.set_of_books_id,
         X_mrc_sob_type_code => l_reporting_flag
      , p_log_level_rec => g_log_level_rec)) then
         raise add_err1;
      end if;

      -- Call the reporting books cache to get rep books.
      if (l_reporting_flag <> 'R') then
         if (NOT fa_cache_pkg.fazcrsob (
            x_book_type_code => l_asset_hdr_rec.book_type_code,
            x_sob_tbl        => l_rsob_tbl
         , p_log_level_rec => g_log_level_rec)) then
            raise add_err1;
         end if;
      end if;

      for mrc_index in 0..l_rsob_tbl.COUNT loop

         l_mrc_asset_hdr_rec := l_asset_hdr_rec;

         -- if the counter mrc_index  is at 0, then process incoming
         -- book else iterate through reporting books
         if (mrc_index  = 0) then
            l_mrc_asset_hdr_rec.set_of_books_id :=
               l_asset_hdr_rec.set_of_books_id;
         else
            l_mrc_asset_hdr_rec.set_of_books_id :=
               l_rsob_tbl(mrc_index);
            l_reporting_flag := 'R';
         end if;

         -- Need to always call fazcbcs
         if (NOT fa_cache_pkg.fazcbcs (
            X_book => l_mrc_asset_hdr_rec.book_type_code,
            X_set_of_books_id => l_mrc_asset_hdr_rec.set_of_books_id,
            p_log_level_rec => g_log_level_rec)) then
            raise add_err1;
         end if;

         -- call transaction approval for primary books only
         -- Will probably need to break this into an MRC wrapper thing
         if (l_reporting_flag <> 'R') then
            if (px_asset_type_rec.asset_type = 'GROUP') then
               l_trans_rec.transaction_key := 'GA';
            end if;

            -- call this for first bookonly if not a mass trx which
            -- would have already called trx approval
            if (nvl(fnd_global.conc_request_id, -1) <= 0) then
               if (NOT fa_trx_approval_pkg.faxcat (
                  X_book              => l_mrc_asset_hdr_rec.book_type_code,
                  X_asset_id          => l_mrc_asset_hdr_rec.asset_id,
                  X_trx_type          => l_trans_rec.transaction_type_code,
                  X_trx_date          => l_trans_rec.transaction_date_entered,
                  X_init_message_flag => 'NO'
               , p_log_level_rec => g_log_level_rec)) then
                  raise add_err1;
               end if;
            end if;

            -- Need to assign the primary financial info to the current
            -- mrc placeholder variables.
            l_mrc_asset_fin_rec_new := l_asset_fin_rec_new;
            l_mrc_asset_deprn_rec_new := l_asset_deprn_rec_new;
         else
            -- Logic for reporting book.
            if (NOT do_all_books (
               p_trans_rec               => l_trans_rec,
               p_primary_asset_hdr_rec   => l_asset_hdr_rec,
               p_primary_asset_fin_rec   => l_asset_fin_rec_new,
               p_primary_asset_deprn_rec => l_asset_deprn_rec_new,
               p_report_asset_hdr_rec    => l_mrc_asset_hdr_rec,
               x_report_asset_fin_rec    => l_mrc_asset_fin_rec_new,
               x_report_asset_deprn_rec  => l_mrc_asset_deprn_rec_new,
               p_asset_fin_mrc_tbl       => l_asset_fin_mrc_tbl_new,
               p_asset_deprn_mrc_tbl     => l_asset_deprn_mrc_tbl,
               p_inv_tbl                 => px_inv_tbl,
               x_exchange_rate           => l_exchange_rate,
               x_return_status           => x_return_status,
               p_calling_fn              => 'fa_addition_pub.do_addition',
               p_log_level_rec           => g_log_level_rec
            )) then
              raise add_err1;
            end if;
         end if;

         -- Fix for Bug #2653564.  Do no pass same record group to two
         -- different parameters, one of which is an OUT parameter.
         l_mrc_asset_fin_rec_adj   := l_mrc_asset_fin_rec_new;
         l_mrc_asset_deprn_rec_adj := l_mrc_asset_deprn_rec_new;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('add before calc engine','allow_neg_nbv_type',
            l_mrc_asset_fin_rec_new.over_depreciate_option, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add('add before calc engine','l_asset_fin_rec_old.method',
            l_asset_fin_rec_old.deprn_method_code, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add('add before calc engine','l_mrc_asset_fin_rec_adj.method',
            l_mrc_asset_fin_rec_adj.deprn_method_code, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add('add before calc engine','l_mrc_asset_fin_rec_new.method',
            l_mrc_asset_fin_rec_new.deprn_method_code, p_log_level_rec => g_log_level_rec);
      end if;


         -- Calculate intermediate variables.
         if (NOT fa_asset_calc_pvt.calc_fin_info (
            px_trans_rec           => l_trans_rec,
            p_inv_trans_rec        => l_inv_trans_rec,
            p_asset_hdr_rec        => l_mrc_asset_hdr_rec,
            p_asset_desc_rec       => px_asset_desc_rec,
            p_asset_type_rec       => px_asset_type_rec,
            p_asset_cat_rec        => px_asset_cat_rec,
            p_asset_fin_rec_old    => l_asset_fin_rec_old,
            p_asset_fin_rec_adj    => l_mrc_asset_fin_rec_adj,
            px_asset_fin_rec_new   => l_mrc_asset_fin_rec_new,
            p_asset_deprn_rec_old  => l_asset_deprn_rec_old,
            p_asset_deprn_rec_adj  => l_mrc_asset_deprn_rec_adj,
            px_asset_deprn_rec_new => l_mrc_asset_deprn_rec_new,
            p_period_rec           => l_period_rec,
            p_mrc_sob_type_code    => l_reporting_flag,
            p_group_reclass_options_rec => l_group_reclass_options_rec,
            p_calling_fn           => 'fa_addition_pub.do_addition'
         , p_log_level_rec => g_log_level_rec)) then
            raise add_err1;
         end if;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('add after calc engine','allow_neg_nbv_type',
            l_mrc_asset_fin_rec_new.over_depreciate_option, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add('add after calc engine','l_asset_fin_rec_old.method',
            l_asset_fin_rec_old.deprn_method_code, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add('add after calc engine','l_mrc_asset_fin_rec_adj.method',
            l_mrc_asset_fin_rec_adj.deprn_method_code, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add('add after calc engine','l_mrc_asset_fin_rec_new.method',
            l_mrc_asset_fin_rec_new.deprn_method_code, p_log_level_rec => g_log_level_rec);
      end if;

         -- If this is the corp primary book, we need to store the revised
         -- data back in the original recs.
         if ((fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') AND
             (l_reporting_flag <> 'R')) then
            px_asset_fin_rec := l_mrc_asset_fin_rec_new;
         end if;

         -- BUG#2797309 / BUG#3485177
         -- Do not set amortization_start_date for non-cip assets
         if (px_asset_type_rec.asset_type = 'CIP' and
             l_mrc_asset_fin_rec_new.group_asset_id is null) then
            l_trans_rec.amortization_start_date := NULL;
         else
            -- BUG# 2815608
            -- adding the following logic to set amortize subtype and date
            -- if not provided, it is defaulted to DPIS - BMR
            if (l_mrc_asset_fin_rec_new.group_asset_id is not null) then
               l_trans_rec.transaction_subtype := 'AMORTIZED';
               if (l_trans_rec.amortization_start_date is null) then
                  l_trans_rec.amortization_start_date :=
                     l_asset_fin_rec_new.date_placed_in_service;
               end if;
            end if;
         end if;

         -- SLA
         -- faxcde will result in null expense if prior fy expense
         -- is null... set to 0.

         if (l_mrc_asset_deprn_rec_new.prior_fy_expense is null and
             G_release <> 11) then
            l_mrc_asset_deprn_rec_new.prior_fy_expense := 0;
         end if;

         if (NOT fa_addition_pvt.insert_asset (
            p_trans_rec              => l_trans_rec,
            p_dist_trans_rec         => px_dist_trans_rec,
            p_asset_hdr_rec          => l_mrc_asset_hdr_rec,
            p_asset_desc_rec         => px_asset_desc_rec,
            p_asset_type_rec         => px_asset_type_rec,
            p_asset_cat_rec          => px_asset_cat_rec,
            p_asset_hierarchy_rec    => px_asset_hierarchy_rec,
            p_asset_fin_rec          => l_mrc_asset_fin_rec_new,
            p_asset_deprn_rec        => l_mrc_asset_deprn_rec_new,
            px_asset_dist_tbl        => px_asset_dist_tbl,
            p_inv_trans_rec          => l_inv_trans_rec,
            p_primary_cost           => l_asset_fin_rec_new.cost,
            p_exchange_rate          => l_exchange_rate,
            x_return_status          => x_return_status,
            p_mrc_sob_type_code      => l_reporting_flag,
            p_period_rec             => l_period_rec,
            p_calling_fn             => 'fa_addition_pub.do_addition'
         , p_log_level_rec => g_log_level_rec)) then
            raise add_err2;
         end if;

         -- call the group api
         if (l_mrc_asset_fin_rec_new.group_asset_id is not null ) then

            if (l_reporting_flag <> 'R') then

               -- set up the group recs
               l_group_asset_hdr_rec          := l_mrc_asset_hdr_rec;
               l_group_asset_hdr_rec.asset_id := l_mrc_asset_fin_rec_new.group_asset_id;

               l_group_trans_rec              := l_trans_rec;   -- will set the amort start date
               l_group_trans_rec.transaction_key := 'MA';

               if not FA_UTIL_PVT.get_asset_desc_rec
                       (p_asset_hdr_rec         => l_group_asset_hdr_rec,
                        px_asset_desc_rec       => l_group_asset_desc_rec
                       , p_log_level_rec => g_log_level_rec) then
                  raise add_err1;
               end if;

               if not FA_UTIL_PVT.get_asset_cat_rec
                       (p_asset_hdr_rec         => l_group_asset_hdr_rec,
                        px_asset_cat_rec        => l_group_asset_cat_rec,
                        p_date_effective        => null
                       , p_log_level_rec => g_log_level_rec) then
                  raise add_err1;
               end if;

               if not FA_UTIL_PVT.get_asset_type_rec
                       (p_asset_hdr_rec         => l_group_asset_hdr_rec,
                        px_asset_type_rec       => l_group_asset_type_rec,
                        p_date_effective        => null
                        , p_log_level_rec => g_log_level_rec) then
                  raise add_err1;
               end if;

               if not FA_ASSET_VAL_PVT.validate_period_of_addition
                       (p_asset_id            => l_group_asset_hdr_rec.asset_id,
                        p_book                => l_group_asset_hdr_rec.book_type_code,
                        p_mode                => 'ABSOLUTE',
                        px_period_of_addition => l_group_asset_hdr_rec.period_of_addition, p_log_level_rec => g_log_level_rec) then
                  raise add_err1;
               end if;

               l_group_trans_rec.transaction_type_code := 'GROUP ADJUSTMENT';
               l_group_trans_rec.member_transaction_header_id := l_trans_rec.transaction_header_id;

               if (NOT fa_trx_approval_pkg.faxcat
                         (X_book              => l_group_asset_hdr_rec.book_type_code,
                          X_asset_id          => l_group_asset_hdr_rec.asset_id,
                          X_trx_type          => l_group_trans_rec.transaction_type_code,
                          X_trx_date          => l_group_trans_rec.transaction_date_entered,
                          X_init_message_flag => 'NO', p_log_level_rec => g_log_level_rec)) then
                  raise add_err1;
               end if;

               l_group_trans_rec.transaction_subtype   := 'AMORTIZED';

               select fa_transaction_headers_s.nextval
                 into l_group_trans_rec.transaction_header_id
                 from dual;

            else

               l_group_asset_hdr_rec.set_of_books_id := l_mrc_asset_hdr_rec.set_of_books_id;
            end if;

            -- load the old structs
            if not FA_UTIL_PVT.get_asset_fin_rec
                    (p_asset_hdr_rec         => l_group_asset_hdr_rec,
                     px_asset_fin_rec        => l_group_asset_fin_rec_old,
                     p_transaction_header_id => NULL,
                      p_mrc_sob_type_code     => l_reporting_flag
                    , p_log_level_rec => g_log_level_rec) then raise add_err1;
            end if;

            --HH Validate disabled_flag
            --We don't want to perform any transaction on a disabled group.
            if not FA_ASSET_VAL_PVT.validate_disabled_flag
                  (p_group_asset_id  => l_group_asset_hdr_rec.asset_id,
                   p_book_type_code  => l_group_asset_hdr_rec.book_type_code,
                   p_old_flag        => l_group_asset_fin_rec_old.disabled_flag,
                   p_new_flag        => l_group_asset_fin_rec_old.disabled_flag
                  , p_log_level_rec => g_log_level_rec) then
               raise add_err1;
            end if; --End HH

            if not FA_UTIL_PVT.get_asset_deprn_rec
                    (p_asset_hdr_rec         => l_group_asset_hdr_rec ,
                     px_asset_deprn_rec      => l_group_asset_deprn_rec_old,
                     p_period_counter        => NULL,
                     p_mrc_sob_type_code     => l_reporting_flag
                     , p_log_level_rec => g_log_level_rec) then raise add_err1;
            end if;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('add before grp adj call','l_mrc_asset_fin_rec_new.cip_cost',
            l_mrc_asset_fin_rec_new.cip_cost, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add('add before grp adj call','l_mrc_asset_fin_rec_new.cost',
            l_mrc_asset_fin_rec_new.cost, p_log_level_rec => g_log_level_rec);
      end if;

            -- copy the delta cost if any into the group's fin_rec
            if (px_asset_type_rec.asset_type = 'CIP') then

               if (fa_cache_pkg.fazcbc_record.allow_cip_dep_group_flag = 'Y') then
                  l_group_asset_fin_rec_adj.cip_cost := nvl(l_mrc_asset_fin_rec_new.cip_cost, 0);
                  l_group_asset_fin_rec_adj.cost     := nvl(l_mrc_asset_fin_rec_new.cost, 0) - nvl(l_mrc_asset_fin_rec_new.cip_cost, 0);
               else
                  l_group_asset_fin_rec_adj.cip_cost := nvl(l_mrc_asset_fin_rec_new.cip_cost, 0);
               end if;
            else
               l_group_asset_fin_rec_adj.cost := nvl(l_mrc_asset_fin_rec_new.cost, 0);
               l_group_asset_fin_rec_adj.salvage_value :=
                                    nvl(l_mrc_asset_fin_rec_new.salvage_value, 0) -
                                    nvl(l_asset_fin_rec_old.salvage_value, 0);
               l_group_asset_fin_rec_adj.allowed_deprn_limit_amount :=
                                    nvl(l_mrc_asset_fin_rec_new.allowed_deprn_limit_amount, 0) -
                                    nvl(l_asset_fin_rec_old.allowed_deprn_limit_amount, 0);
            end if;

            if not FA_ADJUSTMENT_PVT.do_adjustment
                     (px_trans_rec              => l_group_trans_rec,
                      px_asset_hdr_rec          => l_group_asset_hdr_rec,
                      p_asset_desc_rec          => l_group_asset_desc_rec,
                      p_asset_type_rec          => l_group_asset_type_rec,
                      p_asset_cat_rec           => l_group_asset_cat_rec,
                      p_asset_fin_rec_old       => l_group_asset_fin_rec_old,
                      p_asset_fin_rec_adj       => l_group_asset_fin_rec_adj,
                      x_asset_fin_rec_new       => l_group_asset_fin_rec_new,
                      p_inv_trans_rec           => l_inv_trans_rec,
                      p_asset_deprn_rec_old     => l_group_asset_deprn_rec_old,
                      p_asset_deprn_rec_adj     => l_group_asset_deprn_rec_adj,
                      x_asset_deprn_rec_new     => l_group_asset_deprn_rec_new,
                      p_period_rec              => l_period_rec,
                      p_mrc_sob_type_code       => l_reporting_flag,
                      p_group_reclass_options_rec =>l_group_reclass_options_rec,
                      p_calling_fn              => 'fa_addition_pub.do_addition'
                     , p_log_level_rec => g_log_level_rec)then
               raise add_err1;
            end if; -- do_adjustment
         end if;       -- group asset id not null


         -- add asset to the Asset Hierarchy for CORP book
         if ((fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') AND
             (l_reporting_flag <> 'R')) then
           if px_asset_hierarchy_rec.parent_hierarchy_id is not null then
              if not fa_asset_hierarchy_pvt.add_asset(
                 p_asset_hdr_rec       => l_mrc_asset_hdr_rec,
                 p_asset_hierarchy_rec => px_asset_hierarchy_rec , p_log_level_rec => g_log_level_rec) then
       --        p_calling_fn     => 'fa_addition_pub.do_addition' ) then

                raise add_err1;
              end if;
           end if;
         end if;
      end loop;
   end loop;

   -- call to workflow business event

   fa_business_events.raise(p_event_name => 'oracle.apps.fa.addition.asset.add',
                 p_event_key => px_asset_hdr_rec.asset_id || to_char(sysdate,'RRDDDSSSSS'),
                 p_parameter_name1 => 'ASSET_ID',
                 p_parameter_value1 => px_asset_hdr_rec.asset_id,
                 p_parameter_name2 => 'ASSET_NUMBER',
                 p_parameter_value2 => px_asset_desc_rec.asset_number,
                 p_parameter_name3 => 'BOOK_TYPE_CODE',
                 p_parameter_value3 => l_asset_hdr_rec.book_type_code,
                 p_log_level_rec => g_log_level_rec);


   if cse_fa_integration_grp.is_oat_enabled then
      if not cse_fa_integration_grp.addition(
                             p_trans_rec      =>  l_trans_rec,
                             p_asset_hdr_rec  =>  l_asset_hdr_rec,
                             p_asset_desc_rec =>  px_asset_desc_rec,
                             p_asset_fin_rec  =>  l_asset_fin_rec,
                             p_asset_dist_tbl =>  px_asset_dist_tbl,
                             p_inv_tbl        =>  px_inv_tbl) then
          raise add_err1;
      end if;
   end if;

   -- Bug 6391045
   -- Code hook for IAC
   if (FA_IGI_EXT_PKG.IAC_Enabled) then
           if not FA_IGI_EXT_PKG.Do_Addition(
             p_trans_rec            =>  l_trans_rec,
             p_asset_hdr_rec        =>  l_asset_hdr_rec,
             p_asset_cat_rec        =>  px_asset_cat_rec,
             p_asset_desc_rec       =>  px_asset_desc_rec,
             p_asset_fin_rec        =>  l_asset_fin_rec,
             p_asset_deprn_rec      =>  px_asset_deprn_rec,
             p_asset_type_rec       =>  px_asset_type_rec,
             p_calling_function     =>  l_calling_fn) then
               raise add_err1;
            end if;
   end if; -- (FA_IGI_EXT_PKG.IAC_Enabled)

   -- commit if p_commit is TRUE.
   if (fnd_api.to_boolean (p_commit)) then
        COMMIT WORK;
   end if;

   -- Standard call to get message count and if count is 1 get message info.
   fnd_msg_pub.count_and_get (
      p_count   => x_msg_count,
      p_data    => x_msg_data
   );

   x_return_status := FND_API.G_RET_STS_SUCCESS;

exception
   when add_err1 then

      ROLLBACK TO do_addition;

      fa_srvr_msg.add_message
           (calling_fn => 'fa_addition_pub.do_addition', p_log_level_rec => g_log_level_rec);

      FND_MSG_PUB.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

      x_return_status := FND_API.G_RET_STS_ERROR;


   when add_err2 then

      ROLLBACK TO do_addition;

      fa_srvr_msg.add_message
           (calling_fn => 'fa_addition_pub.do_addition', p_log_level_rec => g_log_level_rec);

      FND_MSG_PUB.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

   when others then

      ROLLBACK TO do_addition;

      fa_srvr_msg.add_sql_error
           (calling_fn => 'fa_addition_pub.do_addition', p_log_level_rec => g_log_level_rec);

      FND_MSG_PUB.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

      x_return_status := FND_API.G_RET_STS_ERROR;

end do_addition;

function do_all_books (
   p_trans_rec               IN     fa_api_types.trans_rec_type,
   p_primary_asset_hdr_rec   IN     fa_api_types.asset_hdr_rec_type,
   p_primary_asset_fin_rec   IN     fa_api_types.asset_fin_rec_type,
   p_primary_asset_deprn_rec IN     fa_api_types.asset_deprn_rec_type,
   p_report_asset_hdr_rec    IN     fa_api_types.asset_hdr_rec_type,
   x_report_asset_fin_rec       OUT NOCOPY fa_api_types.asset_fin_rec_type,
   x_report_asset_deprn_rec     OUT NOCOPY fa_api_types.asset_deprn_rec_type,
   p_asset_fin_mrc_tbl       IN     fa_api_types.asset_fin_tbl_type,
   p_asset_deprn_mrc_tbl     IN     fa_api_types.asset_deprn_tbl_type,
   p_inv_tbl                 IN     fa_api_types.inv_tbl_type,
   x_exchange_rate              OUT NOCOPY NUMBER,
   x_return_status              OUT NOCOPY VARCHAR2,
   p_calling_fn              IN     VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean as

   l_count              number;
   l_mrc_populated      boolean := FALSE;
   l_exchange_date      date;
   l_exchange_rate      number;

   all_books_err        exception;

begin

   -- Initialize
   x_exchange_rate := NULL;

   -- Determine the correct currency records
   for i in 1..p_asset_fin_mrc_tbl.COUNT loop
      l_count := i;

      if (p_asset_fin_mrc_tbl(i).set_of_books_id =
          p_report_asset_hdr_rec.set_of_books_id) then

         l_mrc_populated := TRUE;
         exit;
      else
         l_mrc_populated := FALSE;
      end if;
   end loop;

   if (l_mrc_populated = TRUE) then
      x_report_asset_fin_rec := p_asset_fin_mrc_tbl(l_count);
   end if;

   -- Determine exchange rate if there are invoices.  For invoices, we
   -- always use the primary cost divided by the reporting cost.
   if ((p_inv_tbl.count > 0) and (l_mrc_populated)) then
      begin
         -- Exchange rate is then the cost of the reporting_book divided by
         -- the cost of the primary book.
         x_exchange_rate := x_report_asset_fin_rec.cost /
            p_primary_asset_fin_rec.cost;
      exception
         when zero_divide then
            x_exchange_rate := NULL;
      end;
   end if;

   -- For a tax book, we need to use the rate from the corporate book
   -- if it is not a manual transaction.
   if (p_trans_rec.source_transaction_header_id is not null and
       fa_cache_pkg.fazcbc_record.book_class = 'TAX') then
      if not FA_MC_UTIL_PVT.get_existing_rate
             (p_set_of_books_id        => p_report_asset_hdr_rec.set_of_books_id,
              p_transaction_header_id  => p_trans_rec.source_transaction_header_id,
              px_rate                  => l_exchange_rate,
              px_avg_exchange_rate     => x_exchange_rate
             , p_log_level_rec => p_log_level_rec) then

         -- rate not found (corp may not have the same reporting option)
         -- get the current average rate for the addition
         l_exchange_date    := p_trans_rec.transaction_date_entered;

         if not FA_MC_UTIL_PVT.get_trx_rate
                (p_prim_set_of_books_id       => p_primary_asset_hdr_rec.set_of_books_id,
                 p_reporting_set_of_books_id  => p_report_asset_hdr_rec.set_of_books_id,
                 px_exchange_date             => l_exchange_date,
                 p_book_type_code             => p_report_asset_hdr_rec.book_type_code,
                 px_rate                      => x_exchange_rate
                 , p_log_level_rec => p_log_level_rec)then
            raise all_books_err;
         end if;
      end if;
   else
      -- get the rate directly from gl if no invoices involved
      if (x_exchange_rate is null) then

         l_exchange_date := p_trans_rec.transaction_date_entered;

         if (NOT fa_mc_util_pvt.get_trx_rate (
            p_prim_set_of_books_id      => p_primary_asset_hdr_rec.set_of_books_id,
            p_reporting_set_of_books_id => p_report_asset_hdr_rec.set_of_books_id,
            px_exchange_date            => l_exchange_date,
            p_book_type_code            => p_report_asset_hdr_rec.book_type_code,
            px_rate                     => x_exchange_rate
         , p_log_level_rec => p_log_level_rec)) then
            raise all_books_err;
         end if;
      end if;
   end if;

   if (x_exchange_rate is null) then
       raise all_books_err;
   end if;

   -- If no fin_rec was found for the reporting sob, we'll have to calculate
   -- it manually by use the primary fin_rec and exchange rate.
   if (l_mrc_populated = FALSE) then

      -- Initialize values
      x_report_asset_fin_rec := p_primary_asset_fin_rec;
      x_report_asset_fin_rec.set_of_books_id :=
         p_report_asset_hdr_rec.set_of_books_id;

      -- Convert the non-derived financial amounts using the retrieved
      -- rate. All other amounts will be handled by the calculation
      -- engines (rec cost, etc)
      x_report_asset_fin_rec.cost :=
         p_primary_asset_fin_rec.cost * x_exchange_rate;
      x_report_asset_fin_rec.unrevalued_cost :=
         p_primary_asset_fin_rec.unrevalued_cost * x_exchange_rate;
      x_report_asset_fin_rec.salvage_value :=
         p_primary_asset_fin_rec.salvage_value * x_exchange_rate;
      x_report_asset_fin_rec.original_cost :=
         p_primary_asset_fin_rec.original_cost * x_exchange_rate;
      x_report_asset_fin_rec.cip_cost :=
         p_primary_asset_fin_rec.cip_cost * x_exchange_rate;


      -- Round the converted amounts
      if (NOT fa_utils_pkg.faxrnd (
         x_amount =>  x_report_asset_fin_rec.cost,
         x_book   =>  p_report_asset_hdr_rec.book_type_code,
         x_set_of_books_id => x_report_asset_fin_rec.set_of_books_id
      , p_log_level_rec => p_log_level_rec)) then
         raise all_books_err;
      end if;

      if (NOT fa_utils_pkg.faxrnd (
         x_amount =>  x_report_asset_fin_rec.unrevalued_cost,
         x_book   =>  p_report_asset_hdr_rec.book_type_code,
         x_set_of_books_id => x_report_asset_fin_rec.set_of_books_id
      , p_log_level_rec => p_log_level_rec)) then
         raise all_books_err;
      end if;

      if (NOT fa_utils_pkg.faxrnd (
         x_amount =>  x_report_asset_fin_rec.salvage_value,
         x_book   =>  p_report_asset_hdr_rec.book_type_code,
         x_set_of_books_id => x_report_asset_fin_rec.set_of_books_id
      , p_log_level_rec => p_log_level_rec)) then
         raise all_books_err;
      end if;

      if (NOT fa_utils_pkg.faxrnd (
         x_amount =>  x_report_asset_fin_rec.original_cost,
         x_book   =>  p_report_asset_hdr_rec.book_type_code,
         x_set_of_books_id => x_report_asset_fin_rec.set_of_books_id
      , p_log_level_rec => p_log_level_rec)) then
         raise all_books_err;
      end if;

      if (NOT fa_utils_pkg.faxrnd (
         x_amount =>  x_report_asset_fin_rec.cip_cost,
         x_book   =>  p_report_asset_hdr_rec.book_type_code,
         x_set_of_books_id => x_report_asset_fin_rec.set_of_books_id
      , p_log_level_rec => p_log_level_rec)) then
         raise all_books_err;
      end if;

   end if;

   for i in 1..p_asset_deprn_mrc_tbl.COUNT loop
      l_count := i;

      if (p_asset_deprn_mrc_tbl(i).set_of_books_id =
         p_report_asset_hdr_rec.set_of_books_id) then

         l_mrc_populated := TRUE;
         exit;
      else
         l_mrc_populated := FALSE;
      end if;
   end loop;

   if (l_mrc_populated = TRUE) then
      x_report_asset_deprn_rec := p_asset_deprn_mrc_tbl(l_count);
   else
      -- Initialize values
      x_report_asset_deprn_rec                  := p_primary_asset_deprn_rec;
      x_report_asset_deprn_rec.set_of_books_id  :=
         p_report_asset_hdr_rec.set_of_books_id;

      -- Convert the non-derived financial amounts using the retrieved
      -- rate. All other amounts will be handled by the calculation
      -- engines (rec cost, etc)
      x_report_asset_deprn_rec.deprn_reserve :=
         p_primary_asset_deprn_rec.deprn_reserve * x_exchange_rate;
      x_report_asset_deprn_rec.ytd_deprn :=
         p_primary_asset_deprn_rec.ytd_deprn * x_exchange_rate;
      x_report_asset_deprn_rec.bonus_deprn_reserve :=
         p_primary_asset_deprn_rec.bonus_deprn_reserve * x_exchange_rate;
      x_report_asset_deprn_rec.bonus_ytd_deprn :=
         p_primary_asset_deprn_rec.bonus_ytd_deprn * x_exchange_rate;
      x_report_asset_deprn_rec.reval_deprn_reserve :=
         p_primary_asset_deprn_rec.reval_deprn_reserve * x_exchange_rate;

      -- Round the converted amounts
      if (NOT fa_utils_pkg.faxrnd (
         x_amount =>  x_report_asset_deprn_rec.deprn_reserve,
         x_book   =>  p_report_asset_hdr_rec.book_type_code,
         x_set_of_books_id => x_report_asset_fin_rec.set_of_books_id
      , p_log_level_rec => p_log_level_rec)) then
         raise all_books_err;
      end if;

      if (NOT fa_utils_pkg.faxrnd (
         x_amount =>  x_report_asset_deprn_rec.ytd_deprn,
         x_book   =>  p_report_asset_hdr_rec.book_type_code,
         x_set_of_books_id => x_report_asset_fin_rec.set_of_books_id
      , p_log_level_rec => p_log_level_rec)) then
         raise all_books_err;
      end if;

      if (NOT fa_utils_pkg.faxrnd (
         x_amount =>  x_report_asset_deprn_rec.bonus_deprn_reserve,
         x_book   =>  p_report_asset_hdr_rec.book_type_code,
         x_set_of_books_id => x_report_asset_fin_rec.set_of_books_id
      , p_log_level_rec => p_log_level_rec)) then
         raise all_books_err;
      end if;

      if (NOT fa_utils_pkg.faxrnd (
         x_amount =>  x_report_asset_deprn_rec.bonus_ytd_deprn,
         x_book   =>  p_report_asset_hdr_rec.book_type_code,
         x_set_of_books_id => x_report_asset_fin_rec.set_of_books_id
      , p_log_level_rec => p_log_level_rec)) then
         raise all_books_err;
      end if;

      if (NOT fa_utils_pkg.faxrnd (
         x_amount =>  x_report_asset_deprn_rec.reval_deprn_reserve,
         x_book   =>  p_report_asset_hdr_rec.book_type_code,
         x_set_of_books_id => x_report_asset_fin_rec.set_of_books_id
      , p_log_level_rec => p_log_level_rec)) then
         raise all_books_err;
      end if;
   end if;

   return TRUE;

exception
   when all_books_err then
      fa_srvr_msg.add_message(
             calling_fn => 'fa_addition_pub.do_all_books', p_log_level_rec => p_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;

      return FALSE;
   when others then
      fa_srvr_msg.add_sql_error(
             calling_fn => 'fa_addition_pub.do_all_books', p_log_level_rec => p_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;

      return FALSE;
end do_all_books;

END FA_ADDITION_PUB;

/
