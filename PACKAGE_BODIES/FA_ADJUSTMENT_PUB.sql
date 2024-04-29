--------------------------------------------------------
--  DDL for Package Body FA_ADJUSTMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_ADJUSTMENT_PUB" as
/* $Header: FAPADJB.pls 120.54.12010000.25 2010/03/04 13:55:54 deemitta ship $   */

--*********************** Global constants ******************************--

G_PKG_NAME      CONSTANT   varchar2(30) := 'FA_ADJUSTMENT_PUB';
G_API_NAME      CONSTANT   varchar2(30) := 'Adjustment API';
G_API_VERSION   CONSTANT   number       := 1.0;

g_log_level_rec fa_api_types.log_level_rec_type;
g_release                  number  := fa_cache_pkg.fazarel_release;

--*********************** Private functions ******************************--

-- private declaration for books (mrc) wrapper

g_cip_cost    number  := 0;
g_cost        number  := 0;
g_last_invoice_thid   number;
g_last_group_asset_id number;

FUNCTION do_all_books
   (px_trans_rec               IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec           IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec           IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec            IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec_adj        IN     FA_API_TYPES.asset_fin_rec_type,
    px_inv_trans_rec           IN OUT NOCOPY FA_API_TYPES.inv_trans_rec_type,
    px_inv_tbl                 IN OUT NOCOPY FA_API_TYPES.inv_tbl_type,
    p_asset_deprn_rec_adj      IN     FA_API_TYPES.asset_deprn_rec_type,
    p_group_reclass_options_rec IN    FA_API_TYPES.group_reclass_options_rec_type,
    p_log_level_rec           IN     FA_API_TYPES.log_level_rec_type
     ) RETURN BOOLEAN;


--*********************** Public procedures ******************************--

PROCEDURE do_adjustment
   (p_api_version              IN     NUMBER,
    p_init_msg_list            IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                   IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level         IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_calling_fn               IN     VARCHAR2,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2,

    px_trans_rec               IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_fin_rec_adj        IN     FA_API_TYPES.asset_fin_rec_type,
    x_asset_fin_rec_new           OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    x_asset_fin_mrc_tbl_new       OUT NOCOPY FA_API_TYPES.asset_fin_tbl_type,
    px_inv_trans_rec           IN OUT NOCOPY FA_API_TYPES.inv_trans_rec_type,
    px_inv_tbl                 IN OUT NOCOPY FA_API_TYPES.inv_tbl_type,
    p_asset_deprn_rec_adj      IN     FA_API_TYPES.asset_deprn_rec_type,
    x_asset_deprn_rec_new         OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
    x_asset_deprn_mrc_tbl_new     OUT NOCOPY FA_API_TYPES.asset_deprn_tbl_type,
    p_group_reclass_options_rec IN    FA_API_TYPES.group_reclass_options_rec_type) IS

   l_reporting_flag          varchar2(1);
   l_inv_count               number := 0;
   l_rate_count              number := 0;
   l_deprn_count             number := 0;
   l_count                   number := 0;

   l_asset_fin_rec_adj       FA_API_TYPES.asset_fin_rec_type   := p_asset_fin_rec_adj;
   l_asset_fin_mrc_tbl_adj   FA_API_TYPES.asset_fin_tbl_type;
   l_asset_deprn_rec_adj     FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_mrc_tbl_adj FA_API_TYPES.asset_deprn_tbl_type;

   l_asset_fin_rec_new       FA_API_TYPES.asset_fin_rec_type   := p_asset_fin_rec_adj;
   l_asset_fin_mrc_tbl_new   FA_API_TYPES.asset_fin_tbl_type;
   l_asset_deprn_rec_new     FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_mrc_tbl_new FA_API_TYPES.asset_deprn_tbl_type;

   l_asset_desc_rec          FA_API_TYPES.asset_desc_rec_type;
   l_asset_type_rec          FA_API_TYPES.asset_type_rec_type;
   l_asset_cat_rec           FA_API_TYPES.asset_cat_rec_type;

   -- used for tax books when doing cip-in-tax or autocopy
   l_trans_rec               FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec           FA_API_TYPES.asset_hdr_rec_type;
   l_tax_book_tbl            FA_CACHE_PKG.fazctbk_tbl_type;
   l_tax_index               NUMBER;  -- index for tax loop

   -- Bug:5930979:Japan Tax Reform Project
   l_deprn_method_code       varchar2(12);
   l_life_in_months          Number(4);

   l_calling_fn              VARCHAR2(35) := 'fa_adjustment_pub.do_adjustment';
   adj_err                   EXCEPTION;



BEGIN

   SAVEPOINT DO_ADJUSTMENT;
   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise adj_err;
      end if;
   end if;

   g_release  := fa_cache_pkg.fazarel_release;

   g_cip_cost := 0;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   if (fnd_api.to_boolean(p_init_msg_list)) then
        -- initialize error message stack.
        fa_srvr_msg.init_server_message;

        -- initialize debug message stack.
        fa_debug_pkg.initialize;
   end if;

   -- Check version of the API
   -- Standard call to check for API call compatibility.
   if NOT fnd_api.compatible_api_call (
          G_API_VERSION,
          p_api_version,
          G_API_NAME,
          G_PKG_NAME
         ) then
      x_return_status := FND_API.G_RET_STS_ERROR;
      raise adj_err;
   end if;

   -- call the cache for the primary transaction book
   if NOT fa_cache_pkg.fazcbc(X_book => px_asset_hdr_rec.book_type_code, p_log_level_rec => g_log_level_rec) then
      raise adj_err;
   end if;

   px_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

   -- verify the asset exist in the book already
   if not FA_ASSET_VAL_PVT.validate_asset_book
              (p_transaction_type_code      => 'ADJUSTMENT',
               p_book_type_code             => px_asset_hdr_rec.book_type_code,
               p_asset_id                   => px_asset_hdr_rec.asset_id,
               p_calling_fn                 => l_calling_fn
              , p_log_level_rec => g_log_level_rec) then
      raise adj_err;
   end if;

   -- Account for transaction submitted from a responsibility
   -- that is not tied to a SOB_ID by getting the value from
   -- the book struct

   -- Get the book type code P,R or N
   if not fa_cache_pkg.fazcsob
      (X_set_of_books_id   => px_asset_hdr_rec.set_of_books_id,
       X_mrc_sob_type_code => l_reporting_flag
      , p_log_level_rec => g_log_level_rec) then
      raise adj_err;
   end if;

   --  Error out if the program is submitted from the Reporting Responsibility
   --  No transaction permitted directly on reporting books.

   IF l_reporting_flag = 'R' THEN
      fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name => 'MRC_OSP_INVALID_BOOK_TYPE', p_log_level_rec => g_log_level_rec);
      raise adj_err;
   END IF;

   --Verify if impairment has happened in same period
   if not FA_ASSET_VAL_PVT.validate_impairment_exists
              (p_asset_id                   => px_asset_hdr_rec.asset_id,
              p_book             => px_asset_hdr_rec.book_type_code,
              p_mrc_sob_type_code => l_reporting_flag,
              p_set_of_books_id => px_asset_hdr_rec.set_of_books_id,
              p_log_level_rec => g_log_level_rec) then
      raise adj_err;
   end if;
   -- end initial MRC validation
   /*phase5 This function will validate if current transaction is overlapping to any previously done impairment*/
   if not FA_ASSET_VAL_PVT.check_overlapping_impairment(
          p_trans_rec            => px_trans_rec,
          p_asset_hdr_rec        => px_asset_hdr_rec ,
          p_log_level_rec        => g_log_level_rec) then

	 fa_srvr_msg.add_message
                    (name       => 'FA_OVERLAPPING_IMP_NOT_ALLOWED',
                     calling_fn => 'FA_ASSET_VAL_PVT.check_overlapping_impairment'
                    ,p_log_level_rec => g_log_level_rec);
      raise adj_err;
   end if;

   -- pop the structs for the non-fin information needed for trx

   if not FA_UTIL_PVT.get_asset_desc_rec
          (p_asset_hdr_rec         => px_asset_hdr_rec,
           px_asset_desc_rec       => l_asset_desc_rec
          , p_log_level_rec => g_log_level_rec) then
      raise adj_err;
   end if;

   if not FA_UTIL_PVT.get_asset_cat_rec
          (p_asset_hdr_rec         => px_asset_hdr_rec,
           px_asset_cat_rec        => l_asset_cat_rec,
           p_date_effective        => null
          , p_log_level_rec => g_log_level_rec) then
      raise adj_err;
   end if;

   if not FA_UTIL_PVT.get_asset_type_rec
          (p_asset_hdr_rec         => px_asset_hdr_rec,
           px_asset_type_rec       => l_asset_type_rec,
           p_date_effective        => null
          , p_log_level_rec => g_log_level_rec) then
      raise adj_err;
   end if;


   -- don't see a reason to pop the dist info here since it's static
   -- and should be needed by the calc engine

   l_inv_count   := px_inv_tbl.count;


   -- Bug:5930979:Japan Tax Reform Project (Start)
   select deprn_method_code,
          life_in_months
   into l_deprn_method_code,
        l_life_in_months
   from fa_books
   where book_type_code = px_asset_hdr_rec.book_type_code
   and asset_id = px_asset_hdr_rec.asset_id
   and transaction_header_id_out is null;

   if not fa_cache_pkg.fazccmt (
      X_method  => l_deprn_method_code,
      X_life    => l_life_in_months, p_log_level_rec => g_log_level_rec) then
      raise adj_err;
   end if;


   if (nvl(fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag,'NO') = 'YES') and
       nvl(l_asset_fin_rec_adj.group_asset_id,
           FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
       fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name => 'FA_GROUP_NOT_AVAILABLE', p_log_level_rec => g_log_level_rec);
       raise adj_err;
   end if;
   -- Bug:5930979:Japan Tax Reform Project (End)

   -- do not allow manual cost changes on cip assets in tax
   -- except when api is called from the cip-in-tax gateway

   if (fa_cache_pkg.fazcbc_record.book_class = 'TAX' and
        l_asset_type_rec.asset_type = 'CIP' and
        p_calling_fn NOT IN ('fa_ciptax_api_pkg.cip_adj','FA_RECLASS_PVT.do_redefault'))
then
      fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name       => 'FA_BOOK_NO_CIP_COST_CHANGE', p_log_level_rec => g_log_level_rec);
      raise adj_err;
   end if;


   -- nor invoice related adjustments
   if (l_asset_type_rec.asset_type = 'GROUP' and
       px_inv_tbl.count <> 0) then
      fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name       => 'FA_BOOK_NO_GROUP_COST_CHANGE', p_log_level_rec => g_log_level_rec);
      raise adj_err;
   end if;



   -- set the trx type to ADJUSTMENT or CIP ADJUSTMENT
   -- is reset in the private api for period of addition

   if (l_asset_type_rec.asset_type = 'CIP') then
      px_trans_rec.transaction_type_code := 'CIP ADJUSTMENT';
   elsif (l_asset_type_rec.asset_type = 'GROUP') then
      px_trans_rec.transaction_type_code := 'GROUP ADJUSTMENT';
      if (nvl(px_trans_rec.transaction_key, 'XX') <> 'SG') then
         px_trans_rec.transaction_key       := 'GJ';
      end if;
   else
      px_trans_rec.transaction_type_code := 'ADJUSTMENT';
   end if;

   -- default the trx_subtype to EXPENSED if null (AMORTIZED for group)
   if (l_asset_type_rec.asset_type = 'GROUP' and
       px_trans_rec.transaction_subtype is null) then
      px_trans_rec.transaction_subtype := 'AMORTIZED';
   elsif (px_trans_rec.transaction_subtype is null) then
      px_trans_rec.transaction_subtype := 'EXPENSED';
   end if;

   -- R12 logic
   -- we need the thid first for inserting clearing into adjustments
   -- SLA: do not populate when this is called from an invoice transfer
   -- and the id was already populated

   if (nvl(px_inv_trans_rec.transaction_type, 'X') <> 'INVOICE TRANSFER') then
      select fa_transaction_headers_s.nextval
        into px_trans_rec.transaction_header_id
        from dual;
   end if;

   -- also check if this is the period of addition - use absolute mode for adjustments
   -- we will only clear cost outside period of addition
   if not FA_ASSET_VAL_PVT.validate_period_of_addition
             (p_asset_id            => px_asset_hdr_rec.asset_id,
              p_book                => px_asset_hdr_rec.book_type_code,
              p_mode                => 'ABSOLUTE',
              px_period_of_addition => px_asset_hdr_rec.period_of_addition, p_log_level_rec => g_log_level_rec) then
      raise adj_err;
   end if;
   /*Bug# 8527619 */
   if  nvl(l_asset_fin_rec_adj.group_asset_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
      if not FA_ASSET_VAL_PVT.validate_over_depreciation
             (p_asset_hdr_rec      => px_asset_hdr_rec,
              p_asset_fin_rec      => p_asset_fin_rec_adj,
              p_validation_type    => 'ADJUSTMENT',
              p_cost_adj           => p_asset_fin_rec_adj.cost,
              p_rsv_adj            => 0,
              p_log_level_rec      => g_log_level_rec) then
          raise adj_err;
       end if;
    end if;

   -- Bug 8471701: Prevent reserve change if any 'B' row distribution is inactive
   if (nvl(p_asset_deprn_rec_adj.deprn_reserve, 0) <> 0) or (nvl(p_asset_deprn_rec_adj.ytd_deprn, 0) <> 0) then
      if not FA_ASSET_VAL_PVT.validate_ltd_deprn_change
          (p_book_type_code      => px_asset_hdr_rec.book_type_code,
           p_asset_Id            => px_asset_hdr_rec.asset_id,
           p_calling_fn          => l_calling_fn,
           p_log_level_rec       => g_log_level_rec) then
         raise adj_err;
      end if;
   end if;
   -- End Bug 8471701

   -- call the mrc wrapper for the transaction book

   if not do_all_books
      (px_trans_rec               => px_trans_rec,
       px_asset_hdr_rec           => px_asset_hdr_rec ,
       p_asset_desc_rec           => l_asset_desc_rec ,
       p_asset_type_rec           => l_asset_type_rec ,
       p_asset_cat_rec            => l_asset_cat_rec ,
       p_asset_fin_rec_adj        => p_asset_fin_rec_adj,
       px_inv_trans_rec           => px_inv_trans_rec,
       px_inv_tbl                 => px_inv_tbl,
       p_asset_deprn_rec_adj      => p_asset_deprn_rec_adj,
       p_group_reclass_options_rec=> p_group_reclass_options_rec
      ,p_log_level_rec => g_log_level_rec
      )then
      raise adj_err;
   end if;

   -- If book is a corporate book, process cip assets and autocopy

   if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then

      -- BUG# 2792134
      -- null out the fin_rec table as well as deprn
      -- cost and mrc cost will be rederived using corp values

      l_asset_fin_rec_adj := null;
      l_asset_fin_mrc_tbl_adj.delete;

      l_asset_fin_rec_adj.cost := G_cost;
      -- excluding salvage changes for now
      -- nothing else should apply to tax (method, etc, and remain the same)

      -- do not continue if there are no changes to process

      if (nvl(l_asset_fin_rec_adj.cost, 0) = 0) then
         null;
      else
         -- null out the deprn_adj table as we do not want to autocopy
         -- any deprn info to tax books

         l_asset_deprn_rec_adj := null;

         l_trans_rec                       := px_trans_rec;
         l_asset_hdr_rec                   := px_asset_hdr_rec;

         if not fa_cache_pkg.fazctbk
                   (x_corp_book    => px_asset_hdr_rec.book_type_code,
                    x_asset_type   => l_asset_type_rec.asset_type,
                    x_tax_book_tbl => l_tax_book_tbl, p_log_level_rec => g_log_level_rec) then
            raise adj_err;
         end if;

         for l_tax_index in 1..l_tax_book_tbl.count loop

            -- verify that the asset exists in the tax book
            -- if not just bypass it

            if not (FA_ASSET_VAL_PVT.validate_asset_book
                    (p_transaction_type_code      => 'ADJUSTMENT',
                     p_book_type_code             => l_tax_book_tbl(l_tax_index),
                     p_asset_id                   => px_asset_hdr_rec.asset_id,
                     p_calling_fn                 => l_calling_fn,
                     p_log_level_rec              => g_log_level_rec)) then
               null;
            else

               -- cache the book information for the tax book
               if (NOT fa_cache_pkg.fazcbc(X_book => l_tax_book_tbl(l_tax_index),
                                           p_log_level_rec => g_log_level_rec)) then
                  raise adj_err;
               end if;

               -- NOTE!!!!
               -- May need to set the transaction date, trx_type, subtype here as well
               -- based on the open period and settings for each tax book in the loop

               l_asset_hdr_rec.book_type_code           := l_tax_book_tbl(l_tax_index);
               l_asset_hdr_rec.set_of_books_id          := fa_cache_pkg.fazcbc_record.set_of_books_id;
               l_trans_rec.source_transaction_header_id := px_trans_rec.transaction_header_id;
               l_trans_rec.transaction_header_id        := null;

               -- SLA: we need the thid or each tax book as well
               -- note that we do it here rather than do_all
               -- books because of invoice impacts in corp above
               select fa_transaction_headers_s.nextval
                 into l_trans_rec.transaction_header_id
                 from dual;

              if not do_all_books
                (px_trans_rec               => l_trans_rec,              -- tax
                 px_asset_hdr_rec           => l_asset_hdr_rec ,         -- tax
                 p_asset_desc_rec           => l_asset_desc_rec ,
                 p_asset_type_rec           => l_asset_type_rec ,
                 p_asset_cat_rec            => l_asset_cat_rec ,
                 p_asset_fin_rec_adj        => l_asset_fin_rec_adj,
                 px_inv_trans_rec           => px_inv_trans_rec,
                 px_inv_tbl                 => px_inv_tbl,
                 p_asset_deprn_rec_adj      => l_asset_deprn_rec_adj,
                 p_group_reclass_options_rec=> p_group_reclass_options_rec,
                 p_log_level_rec            => g_log_level_rec
               ) then
                raise adj_err;
              end if;

           end if; -- exists in tax book

         end loop; -- tax books

      end if; -- cost change

   end if; -- corporate book

   -- commit if p_commit is TRUE.
   if (fnd_api.to_boolean (p_commit)) then
        COMMIT WORK;
   end if;

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when adj_err then
      ROLLBACK TO do_adjustment;

      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      -- do not retrieve / clear messaging when this is being called
      -- from reclass api - allow calling util to dump them
      if (p_calling_fn <> 'FA_RECLASS_PVT.do_redefault'  and
          p_calling_fn <> 'fa_inv_xfr_pub.do_transfer') then
         FND_MSG_PUB.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data
         );
      end if;

      x_return_status :=  FND_API.G_RET_STS_ERROR;

   when others then
      ROLLBACK TO do_adjustment;

      fa_srvr_msg.add_sql_error(
              calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      -- do not retrieve / clear messaging when this is being called
      -- from reclass api - allow calling util to dump them
      if (p_calling_fn <> 'FA_RECLASS_PVT.do_redefault'  and
          p_calling_fn <> 'fa_inv_xfr_pub.do_transfer') then
         FND_MSG_PUB.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data
         );
      end if;

      x_return_status :=  FND_API.G_RET_STS_ERROR;

END do_adjustment;

-----------------------------------------------------------------------------

-- Books (MRC) Wrapper - called from public API above
--
-- For non mrc books, this just calls the private API with provided params
-- For MRC, it processes the primary and then loops through each reporting
-- book calling the private api for each.


FUNCTION do_all_books
   (px_trans_rec               IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec           IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec           IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec            IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec_adj        IN     FA_API_TYPES.asset_fin_rec_type,
    px_inv_trans_rec           IN OUT NOCOPY FA_API_TYPES.inv_trans_rec_type,
    px_inv_tbl                 IN OUT NOCOPY FA_API_TYPES.inv_tbl_type,
    p_asset_deprn_rec_adj      IN     FA_API_TYPES.asset_deprn_rec_type,
    p_group_reclass_options_rec IN    FA_API_TYPES.group_reclass_options_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type
) RETURN BOOLEAN IS

   -- used for calling private api for reporting books
   l_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;
   l_asset_fin_rec_adj        FA_API_TYPES.asset_fin_rec_type;
   l_asset_deprn_rec_adj      FA_API_TYPES.asset_deprn_rec_type;
   l_asset_fin_mrc_tbl_adj    FA_API_TYPES.asset_fin_tbl_type;
   l_asset_deprn_mrc_tbl_adj  FA_API_TYPES.asset_deprn_tbl_type;

   -- used to store the primary info for later use in mrc calcs
   -- initially to store the incoming adj upon invoice engine call
   l_asset_fin_rec_adj_init   FA_API_TYPES.asset_fin_rec_type;
   l_asset_deprn_rec_adj_init FA_API_TYPES.asset_deprn_rec_type;
   l_group_rcl_options_rec_init   FA_API_TYPES.group_reclass_options_rec_type;

   -- used for retrieving "old" and "new" structs from private api calls
   l_asset_fin_rec_old        FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_rec_new        FA_API_TYPES.asset_fin_rec_type;
   l_asset_deprn_rec_old      FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_rec_new      FA_API_TYPES.asset_deprn_rec_type;

   -- used for group reclass api call
   l_group_rcl_trans_rec       FA_API_TYPES.trans_rec_type;
   l_group_rcl_options_rec     FA_API_TYPES.group_reclass_options_rec_type;

   l_reporting_flag          varchar2(1);

   l_period_rec               FA_API_TYPES.period_rec_type;
   l_sob_tbl                  FA_CACHE_PKG.fazcrsob_sob_tbl_type;

   -- used for local runs
   l_responsibility_id       number;
   l_application_id          number;

   -- used for get_rate
   l_deprn_ratio             number;
   l_exchange_date           date;
   l_rate                    number;
   l_result_code             varchar2(15);

   l_old_primary_cost        number;
   l_new_primary_cost        number;

   l_old_primary_deprn_reserve        number;  --bug 6619897

   l_complete                varchar2(1);
   l_result_code1            varchar2(15);

   l_index_fin               number;
   l_index_dep               number;

   l_exchange_rate           number;
   l_avg_rate                number;
   l_inv_rate_sum            number := 0;
   l_inv_rate_index          number;
   l_rate_count              number := 0;
   l_expense_amount          number := 0;
   l_transaction_date        date;

   adj_row             FA_ADJUST_TYPE_PKG.fa_adj_row_struct;

   -- used for new group stuff
   l_src_trans_rec              fa_api_types.trans_rec_type;
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

   l_dest_trans_rec              fa_api_types.trans_rec_type;
   l_dest_asset_hdr_rec          fa_api_types.asset_hdr_rec_type;
   l_dest_asset_desc_rec         fa_api_types.asset_desc_rec_type;
   l_dest_asset_type_rec         fa_api_types.asset_type_rec_type;
   l_dest_asset_cat_rec          fa_api_types.asset_cat_rec_type;
   l_dest_asset_fin_rec_old      fa_api_types.asset_fin_rec_type;
   l_dest_asset_fin_rec_adj      fa_api_types.asset_fin_rec_type;
   l_dest_asset_fin_rec_new      fa_api_types.asset_fin_rec_type;
   l_dest_asset_deprn_rec_old    fa_api_types.asset_deprn_rec_type;
   l_dest_asset_deprn_rec_adj    fa_api_types.asset_deprn_rec_type;
   l_dest_asset_deprn_rec_new    fa_api_types.asset_deprn_rec_type;

   l_max_reclass_date            DATE;
   l_max_ret_date                DATE;

   /* Japan Tax Phase3 extended deprn flags */
   l_extended_flag               boolean := FALSE;
   l_set_extend_flag             boolean := FALSE;
   l_reset_extend_flag           boolean := FALSE;

   /* Bug 6950629: For contract_id adjustment */
   l_contract_change_flag         boolean := FALSE;
   l_validate_flag                boolean := FALSE;

   cursor c_get_max_reclass_date (p_asset_id       number,
                                  p_book_type_code varchar2) is
   select dest_amortization_start_date
     from fa_trx_references
    where member_asset_id = p_asset_id
      and book_type_code  = p_book_type_code
    order by dest_amortization_start_date desc;

   cursor c_get_overlapping_ret (p_asset_id       number,
                                 p_book_type_code varchar2) is
   select transaction_date_entered
     from fa_transaction_headers
    where asset_id       = p_asset_id
      and book_type_code = p_book_type_code
      and transaction_type_code in
           ('PARTIAL RETIREMENT','REINSTATEMENT')
    order by transaction_date_entered desc;

   -- Japan Tax phase3
   -- Cursor to fetch original deprn info before last extended
   -- Fetch only one row to get the latest one.
   -- Bug 6614551 no need to change salvage value
   CURSOR c_extend_get_original_deprn (p_asset_id       number,
                                       p_book_type_code varchar2) is
     /* select NVL(bk_extnd.prior_deprn_method,bk_old.deprn_method_code) deprn_method_code,
             NVL(bk_extnd.prior_life_in_months,bk_old.life_in_months) life_in_months,
             --bk_old.salvage_value,
             --bk_old.period_counter_fully_reserved,
             --bk_old.period_counter_life_complete,
             NVL(bk_extnd.prior_basic_rate, bk_old.basic_rate) basic_rate,
             NVL(bk_extnd.prior_adjusted_rate, bk_old.adjusted_rate) adjusted_rate,
             bk_old.allowed_deprn_limit,
             bk_old.deprn_limit_type,
             bk_old.allowed_deprn_limit_amount
      from fa_books bk_old, fa_books bk_extnd
      where bk_old.book_type_code = p_book_type_code and
            bk_old.asset_id = p_asset_id and
            bk_old.extended_depreciation_period is null and
            bk_extnd.book_type_code = p_book_type_code and
            bk_extnd.asset_id = p_asset_id and
            bk_extnd.extended_depreciation_period is not null and
            bk_extnd.transaction_header_id_in = bk_old.transaction_header_id_out
      order by bk_extnd.transaction_header_id_in desc;*/

      SELECT FB.deprn_method_code
           , FB.life_in_months
           , FB.basic_rate
           , FB.adjusted_rate
           , FB.allowed_deprn_limit
           , FB.deprn_limit_type
           , FB.allowed_deprn_limit_amount
      FROM   FA_BOOKS FB
           , FA_TRANSACTION_HEADERS FT
      WHERE  FB.BOOK_TYPE_CODE = p_book_type_code
      AND    FB.ASSET_ID = p_asset_id
      AND    FB.BOOK_TYPE_CODE = FT.BOOK_TYPE_CODE
      AND    FB.ASSET_ID = FT.ASSET_ID
      AND    FB.TRANSACTION_HEADER_ID_OUT = FT.TRANSACTION_HEADER_ID
      AND    FT.TRANSACTION_KEY = 'ES'
      UNION
        SELECT FB.prior_deprn_method
           , FB.prior_life_in_months
           , FB.prior_basic_rate
           , FB.prior_adjusted_rate
           , FB.prior_deprn_limit
           , FB.prior_deprn_limit_type
           , FB.prior_deprn_limit_amount
        FROM   FA_BOOKS FB
        WHERE  FB.BOOK_TYPE_CODE = p_book_type_code
        AND    FB.ASSET_ID = p_asset_id
        AND    FB.date_ineffective IS NULL;


     -- Bug# 7154793
     /*---------------------------------------------------------
     -- Below cursor is added to verify if retirement prorate
     -- date is greater then current period close date. And
     -- If this is true than donot allow any adjustment trans
     -- on this asset. As this will corrupt the data
     --
     ----------------------------------------------------------*/
     Cursor Check_retirement_prorate_date(
                                       p_asset_id       number,
                                       p_book_type_code varchar2
                                      ) is
     Select 1
     from
       fa_transaction_headers fath
     , fa_deprn_periods fadp
     , fa_retirements faret
     , fa_conventions facon
     where fath.book_type_code = p_book_type_code
     and fath.asset_id = p_asset_id
     and fath.transaction_type_code in ('PARTIAL RETIREMENT','FULL RETIREMENT')
     and fath.book_type_code = fadp.book_type_code
     and fath.date_effective between fadp.period_open_date and nvl(fadp.period_close_date,sysdate)
     and fadp.period_close_date is null
     and fath.transaction_header_id = faret.TRANSACTION_HEADER_ID_IN
     and faret.TRANSACTION_HEADER_ID_OUT is null
     and faret.retirement_prorate_convention = facon.prorate_convention_code
     and faret.date_retired between facon.start_date and facon.end_date
     and facon.prorate_date  >  fadp.CALENDAR_PERIOD_CLOSE_DATE
     ;



   -- Japan Tax phase3 Bug 6614543
   l_extend_calendar_pod date;
   l_extend_calendar_pcd date;

  --Bug# 7715678
   cursor c_get_context_date(c_book_type_code varchar2) is
   select   greatest(calendar_period_open_date,
            least(sysdate, calendar_period_close_date))
   from     fa_deprn_periods
   where    book_type_code = c_book_type_code
   and      period_close_date is null;

   --Bug 8941132 MRC RECLASS
   cursor get_trx_ref is
   select   TRX_REFERENCE_ID,
            TRANSACTION_TYPE,
            SRC_TRANSACTION_SUBTYPE,
            DEST_TRANSACTION_SUBTYPE,
            BOOK_TYPE_CODE,
            SRC_ASSET_ID,
            SRC_TRANSACTION_HEADER_ID,
            DEST_ASSET_ID,
            DEST_TRANSACTION_HEADER_ID,
            MEMBER_ASSET_ID,
            MEMBER_TRANSACTION_HEADER_ID,
            SRC_AMORTIZATION_START_DATE,
            DEST_AMORTIZATION_START_DATE,
            RESERVE_TRANSFER_AMOUNT,
            SRC_EXPENSE_AMOUNT,
            DEST_EXPENSE_AMOUNT,
            SRC_EOFY_RESERVE,
            DEST_EOFY_RESERVE
   from fa_trx_references
   where TRX_REFERENCE_ID = px_trans_rec.trx_reference_id;

   l_trx_ref_rec                fa_api_types.trx_ref_rec_type; --Bug 8941132
   l_group_reclass              boolean := FALSE;  --Bug 8941132

   l_trx_date           date;
  --Bug# 7715678 end

   --Bug7627286
   l_deprn_amount             NUMBER;

   l_calling_fn                  varchar2(30) := 'fa_adjustment_pub.do_all_books';
   adj_err                       EXCEPTION;
   fol_month_trans               number :=0;



BEGIN

   --Bug7627286
   --Call the function to check if deprn has been run for the period
   -- and also to fetch the deprn amount
   if not FA_UTIL_PVT.check_deprn_run
      (X_book              => px_asset_hdr_rec.book_type_code,
       X_asset_id          => px_asset_hdr_rec.asset_id,
       X_deprn_amount      => l_deprn_amount,
       p_log_level_rec     => p_log_level_rec) then
         null;
   end if;


   -- BUG# 2247404 and 2230178 - call regardless if from a mass request
   if not FA_TRX_APPROVAL_PKG.faxcat
          (X_book              => px_asset_hdr_rec.book_type_code,
           X_asset_id          => px_asset_hdr_rec.asset_id,
           X_trx_type          => px_trans_rec.transaction_type_code,
           X_trx_date          => px_trans_rec.transaction_date_entered,
           X_init_message_flag => 'NO'
          , p_log_level_rec => p_log_level_rec) then
      raise adj_err;
   end if;

         -- Bug 7154793
         open Check_retirement_prorate_date(p_asset_id      => px_asset_hdr_rec.asset_id,
                                           p_book_type_code => px_asset_hdr_rec.book_type_code);
         FETCH Check_retirement_prorate_date
         INTO  fol_month_trans;
         close Check_retirement_prorate_date;

         if fol_month_trans = 1 then
              fa_srvr_msg.add_message(
                       calling_fn => l_calling_fn,
                       name       => 'FA_ADJ_PENDING_RET'
                       , p_log_level_rec => p_log_level_rec);
              raise adj_err;
          end if;


   -- check if this is the period of addition - use absolute mode for adjustments

   if not FA_ASSET_VAL_PVT.validate_period_of_addition
             (p_asset_id            => px_asset_hdr_rec.asset_id,
              p_book                => px_asset_hdr_rec.book_type_code,
              p_mode                => 'ABSOLUTE',
              px_period_of_addition => px_asset_hdr_rec.period_of_addition, p_log_level_rec => p_log_level_rec) then
      raise adj_err;
   end if;

   -- load the period struct for current period info
   if not FA_UTIL_PVT.get_period_rec
          (p_book           => px_asset_hdr_rec.book_type_code,
           p_effective_date => NULL,
           x_period_rec     => l_period_rec
          , p_log_level_rec => p_log_level_rec) then
      raise adj_err;
   end if;

   -- moving subtype/date logic into the mrc loop after getting fin_rec_old

   -- verify asset is not fully retired
   if fa_asset_val_pvt.validate_fully_retired
          (p_asset_id          => px_asset_hdr_rec.asset_id,
           p_book              => px_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec) then
      fa_srvr_msg.add_message
          (name      => 'FA_REC_RETIRED',
           calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      raise adj_err;
   end if;


   -- call the sob cache to get the table of sob_ids
   if not FA_CACHE_PKG.fazcrsob
          (x_book_type_code => px_asset_hdr_rec.book_type_code,
           x_sob_tbl        => l_sob_tbl, p_log_level_rec => p_log_level_rec) then
      raise adj_err;
   end if;

   -- set up the local asset_header and sob_id
   l_asset_hdr_rec                 := px_asset_hdr_rec;

   -- loop through each book starting with the primary and
   -- call the private API for each
   FOR l_sob_index in 0..l_sob_tbl.count LOOP

      if (l_sob_index = 0) then
         l_reporting_flag := 'P';
      else
         l_reporting_flag := 'R';
         l_asset_hdr_rec.set_of_books_id := l_sob_tbl(l_sob_index);
      end if;

      -- call the cache to set the sob_id used for rounding and other lower
      -- level code for each book.
      if NOT fa_cache_pkg.fazcbcs(X_book => px_asset_hdr_rec.book_type_code,
                                  X_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                                  p_log_level_rec => p_log_level_rec) then
         raise adj_err;
      end if;

      -- load the old structs
      if not FA_UTIL_PVT.get_asset_fin_rec
              (p_asset_hdr_rec         => l_asset_hdr_rec,
               px_asset_fin_rec        => l_asset_fin_rec_old,
               p_transaction_header_id => NULL,
               p_mrc_sob_type_code     => l_reporting_flag
              , p_log_level_rec => p_log_level_rec) then raise adj_err;
      end if;

      if (l_sob_index = 0) then
         l_old_primary_cost := l_asset_fin_rec_old.cost;

         l_asset_fin_rec_adj      := p_asset_fin_rec_adj;
         l_asset_deprn_rec_adj    := p_asset_deprn_rec_adj;
         l_group_rcl_options_rec  := p_group_reclass_options_rec;


         -- call the custom hook
         if not (fa_custom_trx_pkg.override_values
            (p_asset_hdr_rec              => px_asset_hdr_rec,
             px_trans_rec                 => px_trans_rec,
             p_asset_desc_rec             => p_asset_desc_rec,
             p_asset_type_rec             => p_asset_type_rec,
             p_asset_cat_rec              => p_asset_cat_rec,
             p_asset_fin_rec_old          => l_asset_fin_rec_old,
             px_asset_fin_rec_adj         => l_asset_fin_rec_adj,
             px_asset_deprn_rec_adj       => l_asset_deprn_rec_adj,
             p_inv_trans_rec              => px_inv_trans_rec,
             px_inv_tbl                   => px_inv_tbl,
             px_group_reclass_options_rec => l_group_rcl_options_rec,
             p_calling_fn                 => l_calling_fn)) then
            raise adj_err;
         end if;

         -- do not allow manual cost changes on cip assets in corp
         -- cost adjustments must be done via invoices
         if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE' and
             p_asset_type_rec.asset_type = 'CIP' and
             nvl(l_asset_fin_rec_adj.cost, 0) <> 0) then
            fa_srvr_msg.add_message
                (calling_fn => l_calling_fn,
                 name       => 'FA_BOOK_NO_CIP_COST_CHANGE', p_log_level_rec => p_log_level_rec);
            raise adj_err;
         end if;


         -- do not allow cost adjustment on group assets
         if (p_asset_type_rec.asset_type = 'GROUP' and
             nvl(l_asset_fin_rec_adj.cost, 0) <> 0) then
            fa_srvr_msg.add_message
                (calling_fn => l_calling_fn,
                 name       => 'FA_BOOK_NO_GROUP_COST_CHANGE', p_log_level_rec => p_log_level_rec);
            raise adj_err;
         end if;

         -- Validate disabled_flag
         if (p_asset_type_rec.asset_type = 'GROUP') then

            if not FA_ASSET_VAL_PVT.validate_disabled_flag
                     (p_group_asset_id => px_asset_hdr_rec.asset_id,
                      p_book_type_code => px_asset_hdr_rec.book_type_code,
                      p_old_flag       => l_asset_fin_rec_old.disabled_flag,
                      p_new_flag       => l_asset_fin_rec_adj.disabled_flag
                     , p_log_level_rec => p_log_level_rec) then
               raise adj_err;
            end if;
            /* Bug#8351285- Validate salvage_type or deprn_limit_type change of group */
            if not FA_ASSET_VAL_PVT.validate_sal_deprn_sum
               ( p_asset_hdr_rec         => px_asset_hdr_rec,
                 p_asset_fin_rec_old     => l_asset_fin_rec_old,
                 p_asset_fin_rec_adj     => p_asset_fin_rec_adj ) then

               raise adj_err;
            end if;

         end if;

         l_transaction_date := greatest(l_period_rec.calendar_period_open_date,
                                        least(sysdate,l_period_rec.calendar_period_close_date));
         --HH group ed.
         --set trx key.
         if px_trans_rec.transaction_type_code = 'GROUP ADJUSTMENT' then
           if ((nvl(l_asset_fin_rec_adj.disabled_flag,'Y')='N') and
               (nvl(l_asset_fin_rec_old.disabled_flag, 'N')='Y')) then
                      px_trans_rec.transaction_key :='GE';
           elsif ((nvl(l_asset_fin_rec_adj.disabled_flag,'N')='Y') and
                  (nvl(l_asset_fin_rec_old.disabled_flag, 'N')='N')) then
                         px_trans_rec.transaction_key :='GD';
           end if;
         end if; --end HH.

         -- BUG# 3046621
         -- for group members (or previous members) force
         -- the amort start date to be populated

         if (px_trans_rec.transaction_subtype = 'EXPENSED') then
            if (l_asset_fin_rec_old.group_asset_id is not null or
                nvl(l_asset_fin_rec_adj.group_asset_id,
                    FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM) then
               px_trans_rec.transaction_subtype := 'AMORTIZED';
            end if;
         end if;

         /* Japan Tax Phase3 Set the extended deprn flags */
         -- Possible values of extended_deprn_flag are 'Y', 'N', 'D', null and FND_API.G_MISS_CHAR
         -- l_asset_fin_rec_adj.extended_deprn_flag = null means no change
         -- = FND_API.G_MISS_CHAR means make it null
         if (nvl(l_asset_fin_rec_old.extended_deprn_flag,'N') = 'Y') then
            l_extended_flag := TRUE;
            if (nvl(l_asset_fin_rec_adj.extended_deprn_flag,'X') in ('N','D',FND_API.G_MISS_CHAR)) then
               l_reset_extend_flag := TRUE;
               l_extended_flag := FALSE; -- Bug 6737486 don't need validations when resetting
            end if;
         elsif ((nvl(l_asset_fin_rec_adj.extended_deprn_flag,'N') = 'Y') and
                (nvl(l_asset_fin_rec_old.extended_deprn_flag,'D') in ('D','N'))) then
            l_set_extend_flag := TRUE;
         end if;

         -- Bug 7491880 Validation for extended deprn on group/member
         if (l_set_extend_flag) then
            if ( p_asset_type_rec.asset_type = 'GROUP' ) OR
             (l_asset_fin_rec_old.group_asset_id is not null or
              nvl(p_asset_fin_rec_adj.group_asset_id,
              FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM) then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn,name =>'FA_EXT_DPRN_NOT_ALLOWED_ON_GRP', p_log_level_rec => p_log_level_rec);
               raise adj_err;
            end if;
         end if;

         if (px_trans_rec.transaction_subtype = 'EXPENSED') then

            /* Japan Tax Phase3 don't call validate_exp_after_amort for the
               extended transaction */
            /*--Bug# 6974541 - Added l_reset_extend_flag
            Don't call validate_exp_after_amort while reseting extended depreciation
            i.e. while setting extended_deprn_flag from Yes to No */
            if (not (l_set_extend_flag or l_reset_extend_flag)) then
               if not FA_ASSET_VAL_PVT.validate_exp_after_amort
                         (p_asset_id      => px_asset_hdr_rec.asset_id,
                          p_book          => px_asset_hdr_rec.book_type_code,
                          p_extended_flag => l_extended_flag
                         , p_log_level_rec => p_log_level_rec) then raise adj_err;
               end if;
            -- Japan Tax phase3 Bug 6614543
            -- trx_date_entered for the extended transaction should be
            -- corrresponding to extended_depreciation_period
            elsif (l_asset_fin_rec_adj.extended_depreciation_period is not null) then
               BEGIN
                  -- Assuming that extended_deprn_period will always be first
                  -- period of some fiscal year
                  select cp.start_date,
                         cp.end_date
                  into   l_extend_calendar_pod,
                         l_extend_calendar_pcd
                  from   fa_book_controls bc,
                         fa_fiscal_year fy,
                         fa_calendar_types ct,
                         fa_calendar_periods cp
                  where  bc.book_type_code = px_asset_hdr_rec.book_type_code and
                         bc.deprn_calendar = ct.calendar_type and
                         cp.calendar_type = ct.calendar_type and
                         bc.fiscal_year_name = ct.fiscal_year_name and
                         fy.fiscal_year_name = ct.fiscal_year_name and
                         cp.period_num = 1 and
                         fy.fiscal_year = round (
                          (l_asset_fin_rec_adj.extended_depreciation_period -cp.period_num)/ct.number_per_fiscal_year) --bug 7719717
                         and cp.start_date = fy.start_date;

               EXCEPTION
                  WHEN OTHERS THEN
                     if (p_log_level_rec.statement_level) then
                        fa_debug_pkg.add(l_calling_fn, 'Japan Tax:0 Exception in ', 'trx_date_entered', p_log_level_rec => p_log_level_rec);
                     end if;
                     raise adj_err;
               END;

               l_transaction_date := greatest(l_extend_calendar_pod,
                                              least(sysdate,l_extend_calendar_pcd));
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Japan Tax:0 l_transaction_date', l_transaction_date, p_log_level_rec => p_log_level_rec);
               end if;
            end if;

            -- trx_date for all expensed transactions will be last date of open period
            px_trans_rec.transaction_date_entered := l_transaction_date;
            px_trans_rec.amortization_start_date := NULL;

         else

            -- might want to try to determine user intent here
            -- if they populate amort_start_date instead of trx_date
            -- BUG# 8342853  - reording to insure Energy supercedes
            --                 any provided value
            -- Bug# 7613544 to default amortization start date for energy if not provided.

            --Bug# 7715678 to default amortization start date for energy if not provided.
            if( fa_cache_pkg.fazccmt_record.rate_source_rule = 'PRODUCTION'
                AND fa_cache_pkg.fazcdrd_record.rule_name = 'ENERGY PERIOD END BALANCE') then
               open  c_get_context_date(px_asset_hdr_rec.book_type_code);
               fetch c_get_context_date into l_trx_date ;
               close c_get_context_date;
               px_trans_rec.amortization_start_date := px_trans_rec.transaction_date_entered;
            elsif (px_trans_rec.amortization_start_date is not null) then
               px_trans_rec.transaction_date_entered := px_trans_rec.amortization_start_date;
            end if;

            px_trans_rec.amortization_start_date := px_trans_rec.transaction_date_entered;

            --Bug# 7715678 end

            if (px_trans_rec.amortization_start_date is null) then
               if (p_asset_type_rec.asset_type = 'GROUP') and
                  (px_asset_hdr_rec.period_of_addition = 'Y') then
                  px_trans_rec.transaction_date_entered :=
                      nvl(l_asset_fin_rec_adj.date_placed_in_service,
                          l_asset_fin_rec_old.date_placed_in_service);
               else
                  px_trans_rec.transaction_date_entered := l_transaction_date;
               end if;
            end if;

            px_trans_rec.amortization_start_date := px_trans_rec.transaction_date_entered;

            -- adding this for group, cip-in-tax, and autocopy...
            -- basically if future date is passed, automatically set to
            -- the current period (this accomidates the cip-in-tax and autocopy loops)

            if (px_trans_rec.transaction_date_entered > l_period_rec.calendar_period_close_date) then
               px_trans_rec.amortization_start_date  := l_transaction_date;
               px_trans_rec.transaction_date_entered :=
                  px_trans_rec.amortization_start_date;
            end if;

         end if;

         -- BUG# 3549470
         -- remove time stamps from the dates

         px_trans_rec.transaction_date_entered :=
            to_date(to_char(px_trans_rec.transaction_date_entered, 'DD/MM/YYYY'),'DD/MM/YYYY');

         px_trans_rec.amortization_start_date :=
            to_date(to_char(px_trans_rec.amortization_start_date, 'DD/MM/YYYY'),'DD/MM/YYYY');



         -- call the invoice api which will return a populated fin_rec_adj
         -- for the delta cost, etc.   invoice engine will alter the gl sob
         -- and currency context from the above setting as it processes primary
         -- and reporting, but will reset them at temrination back to primary.

         if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then

            if (px_inv_trans_rec.transaction_type is not null) then

               l_asset_fin_rec_adj_init     := p_asset_fin_rec_adj;
               l_asset_deprn_rec_adj_init   := p_asset_deprn_rec_adj;

               if not FA_INVOICE_PVT.invoice_engine
                   (px_trans_rec              => px_trans_rec,
                    px_asset_hdr_rec          => px_asset_hdr_rec,
                    p_asset_desc_rec          => p_asset_desc_rec,
                    p_asset_type_rec          => p_asset_type_rec,
                    p_asset_cat_rec           => p_asset_cat_rec,
                    p_asset_fin_rec_adj       => l_asset_fin_rec_adj_init,
                    x_asset_fin_rec_new       => l_asset_fin_rec_adj,
                    x_asset_fin_mrc_tbl_new   => l_asset_fin_mrc_tbl_adj,
                    px_inv_trans_rec          => px_inv_trans_rec,
                    px_inv_tbl                => px_inv_tbl,
                    x_asset_deprn_rec_new     => l_asset_deprn_rec_adj,
                    x_asset_deprn_mrc_tbl_new => l_asset_deprn_mrc_tbl_adj,
                    p_calling_fn              => l_calling_fn,
                    p_log_level_rec => p_log_level_rec) then
                 raise adj_err;
               end if;

               G_cip_cost := l_asset_fin_rec_adj.cip_cost;
               G_cost     := l_asset_fin_rec_adj.cost;

            else

               G_cip_cost := 0;
               G_cost     := 0;

            end if; -- invoice based

         else

            -- this is not an invoice scenario and we need to set up the deprn
            -- amounts directly from the struct passed in

            -- also insure delta_cip cost is null as this can only be changed
            -- via the specific invoice transactions

            l_asset_fin_rec_adj          := l_asset_fin_rec_adj;
            l_asset_deprn_rec_adj        := l_asset_deprn_rec_adj;

         end if; -- corp

         if (p_asset_type_rec.asset_type <> 'CIP') then
            l_asset_fin_rec_adj.cip_cost := 0;
         elsif (nvl(fa_cache_pkg.fazcbc_record.allow_cip_dep_group_flag, 'N') = 'Y') then
            l_asset_fin_rec_adj.cip_cost := g_cip_cost;
         else
            l_asset_fin_rec_adj.cip_cost := l_asset_fin_rec_adj.cost;
         end if;

         -- store the calculated values for future use in the mrc loop
         l_asset_fin_rec_adj_init     := l_asset_fin_rec_adj;
         l_asset_deprn_rec_adj_init   := l_asset_deprn_rec_adj;
         l_group_rcl_options_rec_init := l_group_rcl_options_rec;

         /* Japan Tax phase3 -- Do not allow cost adjustment
            and method change for assets in extended depreciation */
         if (l_extended_flag) then
            if not FA_ASSET_VAL_PVT.validate_extended_asset
                    (p_asset_hdr_rec         => px_asset_hdr_rec,
                     p_asset_fin_rec_old     => l_asset_fin_rec_old,
                     p_asset_fin_rec_adj     => l_asset_fin_rec_adj
                 , p_log_level_rec => p_log_level_rec) then raise adj_err;
            end if;
         end if;

         -- Fix for Bug #6371789.  Validate if Japan 250 DB asset.
         -- Passed deprn_method_code and life_in_months from l_asset_fin_rec_old
         -- to avoid "no data found" error
         if not FA_ASSET_VAL_PVT.validate_jp250db
                   (p_transaction_type_code   => 'ADJUSTMENT',
                    p_book_type_code          => px_asset_hdr_rec.book_type_code,
                    p_asset_id                => px_asset_hdr_rec.asset_id,
                    p_method_code             =>
                       l_asset_fin_rec_old.deprn_method_code,
                    p_life_in_months          => l_asset_fin_rec_old.life_in_months,
                    p_asset_type              => p_asset_type_rec.asset_type,
                    p_bonus_rule              => l_asset_fin_rec_adj.bonus_rule,
                    p_transaction_key         => px_trans_rec.transaction_key,
                    p_cash_generating_unit_id =>
                       l_asset_fin_rec_adj.cash_generating_unit_id,
                    p_deprn_override_flag     => px_trans_rec.deprn_override_flag,
                    p_calling_fn              => l_calling_fn, p_log_level_rec => p_log_level_rec) then

            raise adj_err;
         end if;

      end if;

      --
      --Bug: 4698440 - Check certain adjs to extended life assets.
      --This presumably could have been added to validate_adjustment, but that skips
      --over invoice-related changes.  So, putting here for now.  It can be moved in future
      --if necessary.
      --
      IF ((l_asset_fin_rec_old.period_counter_life_complete is not null) AND
                               (l_asset_fin_rec_old.period_Counter_fully_reserved is null)) THEN
         IF (nvl(l_asset_fin_rec_old.cost, 0)
                 <> nvl(l_asset_fin_rec_adj.cost, 0) OR
             nvl(l_asset_fin_rec_old.salvage_value, 0)
                 <> nvl(l_asset_fin_rec_adj.salvage_value,0) OR
             nvl(l_asset_fin_rec_old.ceiling_name,'NONE')
                 <> nvl(l_asset_fin_rec_adj.ceiling_name,'NONE') OR
             nvl(l_asset_fin_rec_old.reval_ceiling,0)
                 <> nvl(l_asset_fin_rec_adj.reval_ceiling,0) OR
             nvl(l_asset_fin_rec_old.deprn_method_code,'NONE')
                  <> nvl(l_asset_fin_rec_adj.deprn_method_code,'NONE') OR
             nvl(l_asset_fin_rec_old.date_placed_in_service,'NONE')
                  <> nvl(l_asset_fin_rec_adj.date_placed_in_service,'NONE') OR
             nvl(l_asset_fin_rec_old.prorate_convention_code, 'NONE')
                  <> nvl(l_asset_fin_rec_adj.prorate_convention_code, 'NONE') OR
             nvl(l_asset_fin_rec_old.life_in_months,0)
                  <> nvl(l_asset_fin_rec_adj.life_in_months ,0) OR
             nvl(l_asset_fin_rec_old.depreciate_flag,'NONE') <>
                     nvl(l_asset_fin_rec_adj.depreciate_flag,'NONE') OR
             nvl(l_asset_fin_rec_old.bonus_rule,'NONE') <>
                     nvl(l_asset_fin_rec_adj.bonus_rule,'NONE') OR
             nvl(l_asset_fin_rec_old.production_capacity,0) <>
                     nvl(l_asset_fin_rec_adj.production_capacity,0)) THEN

             fa_srvr_msg.add_message(calling_fn => 'fa_adjustment_pub.do_all_books',
                                                          name =>'FA_NO_TRX_WHEN_LIFE_COMPLETE', p_log_level_rec => p_log_level_rec);
             raise adj_err;
         END IF;
      END IF;

      if not FA_UTIL_PVT.get_asset_deprn_rec
              (p_asset_hdr_rec         => l_asset_hdr_rec ,
               px_asset_deprn_rec      => l_asset_deprn_rec_old,
               p_period_counter        => NULL,
               p_mrc_sob_type_code     => l_reporting_flag
               , p_log_level_rec => p_log_level_rec) then raise adj_err;
      end if;

      -- bug 6619897 store old primary reserve for future use
      if (l_sob_index = 0) then
         l_old_primary_deprn_reserve := l_asset_deprn_rec_old.deprn_reserve;
      end if;

      -- Bug2887954: Following delete stmts are relocated from
      --  above (just before get_asset_fin_rec)
      --
      -- remove any previously calculated catchup expense for
      -- group assets when initial reserve adjustment is being
      -- performed

      -- SLA uptake
      -- this needs rework - see DLD section on adj api
      -- we can't delete lines which are accounted for by extract
      -- need to either auto reverse them or restict
      --
      -- ***REVISIT***


      if (p_asset_type_rec.asset_type = 'GROUP' and
          px_asset_hdr_rec.period_of_addition = 'Y' and
          nvl(p_asset_deprn_rec_adj.deprn_reserve, 0) <> 0) then

         if (G_release = 11) then
            if (l_reporting_flag = 'R') then
               delete from fa_mc_adjustments
                where asset_id = px_asset_hdr_rec.asset_id
                  and book_type_code = px_asset_hdr_rec.book_type_code
                  and source_type_code = 'DEPRECIATION'
                  and adjustment_type = 'EXPENSE'
                  and set_of_books_id = l_asset_hdr_rec.set_of_books_id;
            else
               delete from fa_adjustments
                where asset_id = px_asset_hdr_rec.asset_id
                  and book_type_code = px_asset_hdr_rec.book_type_code
                  and source_type_code = 'DEPRECIATION'
                  and adjustment_type = 'EXPENSE';
            end if;
         else

            -- Added the below code to reverse the DEPRN EXPENSE
            -- when reserve is manually adjusted in period of addition
            --     bug 4439919

           adj_row.account := fa_cache_pkg.fazccb_record.DEPRN_EXPENSE_ACCT;
           adj_row.account_type := 'DEPRN_EXPENSE_ACCT';
           adj_row.gen_ccid_flag := TRUE;
           adj_row.debit_credit_flag := 'CR';
           adj_row.selection_mode := fa_std_types.FA_AJ_ACTIVE;
           adj_row.last_update_date := sysdate;
           adj_row.period_counter_created := l_period_rec.period_counter;
           adj_row.asset_id := px_asset_hdr_rec.asset_id;
           adj_row.period_counter_adjusted := l_period_rec.period_counter;
           adj_row.book_type_code := px_asset_hdr_rec.book_type_code;
           adj_row.source_type_code := 'DEPRECIATION';
           adj_row.transaction_header_id := px_trans_rec.transaction_header_id;
           adj_row.adjustment_type := 'EXPENSE';

           if (l_reporting_flag = 'R') then
              adj_row.mrc_sob_type_code := 0;
              begin
                 select sum(decode(debit_credit_flag,'DR',adjustment_amount,-1*adjustment_amount))
                   into l_expense_amount
                   from fa_mc_adjustments
                  where asset_id = px_asset_hdr_rec.asset_id
                    and book_type_code = px_asset_hdr_rec.book_type_code
                    and source_type_code = 'DEPRECIATION'
                    and adjustment_type = 'EXPENSE'
                    and set_of_books_id = l_asset_hdr_rec.set_of_books_id;
              exception
                 when no_data_found then
                     null;
              end;
           else
              adj_row.mrc_sob_type_code := 1;
              begin
                 select sum(decode(debit_credit_flag,'DR',adjustment_amount,-1*adjustment_amount))
                   into l_expense_amount
                   from fa_adjustments
                  where asset_id = px_asset_hdr_rec.asset_id
                    and book_type_code = px_asset_hdr_rec.book_type_code
                    and source_type_code = 'DEPRECIATION'
                    and adjustment_type = 'EXPENSE';
              exception
                  when no_data_found then
                      null;
              end;
            end if; -- mrc
         end if;  -- release
      end if; -- group

      -- load the adj structs
      if (l_sob_index = 0) then

         -- validate changes are being made and are valid
         l_validate_flag := fa_adjustment_pvt.validate_adjustment
                (p_inv_trans_rec           => px_inv_trans_rec,
                 p_trans_rec               => px_trans_rec,
                 p_asset_type_rec          => p_asset_type_rec,
                 p_asset_fin_rec_old       => l_asset_fin_rec_old,
                 p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
                 p_asset_deprn_rec_old     => l_asset_deprn_rec_old,
                 p_asset_hdr_rec           => px_asset_hdr_rec,
                 p_asset_deprn_rec_adj     => l_asset_deprn_rec_adj,
                 p_log_level_rec           => p_log_level_rec
                 );

         -- Removing not before l_validate_flag inif condtion for bug 9168436
         if (nvl(l_asset_fin_rec_old.contract_id, FND_API.G_MISS_NUM) <>
             nvl(p_asset_fin_rec_adj.contract_id,
             nvl(l_asset_fin_rec_old.contract_id, FND_API.G_MISS_NUM)) ) and
              l_validate_flag then

                  l_contract_change_flag := TRUE;
                  l_asset_fin_rec_adj.contract_change_flag := TRUE;

         end if;

         if not l_contract_change_flag and not l_validate_flag then
                  raise adj_err;
         end if;


         -- populate the trx_reference_id when group change occurs
--         if (nvl(l_asset_fin_rec_old.group_asset_id, -99) <>
--                     nvl(l_asset_fin_rec_adj.group_asset_id, -99)) then
         if (l_asset_fin_rec_old.group_asset_id is null and
             nvl(l_asset_fin_rec_adj.group_asset_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM) or
            (l_asset_fin_rec_old.group_asset_id <> l_asset_fin_rec_adj.group_asset_id) then
            select fa_trx_references_s.nextval
              into px_trans_rec.trx_reference_id
              from dual;
         end if;

         -- BUG# 2877651
         -- if this is or was a amember asset, force amortized subtype
         if (px_trans_rec.transaction_subtype = 'EXPENSED' and
             (l_asset_fin_rec_old.group_asset_id is not null or
              nvl(l_asset_fin_rec_adj.group_asset_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM)) then
            px_trans_rec.transaction_subtype      := 'AMORTIZED';
            px_trans_rec.amortization_start_date  := to_date(to_char(l_transaction_date,'DD/MM/YYYY'),'DD/MM/YYYY');
            px_trans_rec.transaction_date_entered := px_trans_rec.amortization_start_date;
         end if;

      else

         -- get the latest average rate (used conditionally in some cases below)
         if not fa_mc_util_pvt.get_latest_rate
                (p_asset_id            => l_asset_hdr_rec.asset_id,
                 p_book_type_code      => l_asset_hdr_rec.book_type_code,
                 p_set_of_books_id     => l_asset_hdr_rec.set_of_books_id,
                 px_rate               => l_exchange_rate,
                 px_avg_exchange_rate  => l_avg_rate
                 , p_log_level_rec => p_log_level_rec) then
            raise adj_err;
         end if;

         -- process the reporting books by getting the rate and applying to the corp amount
         -- if the transaction was not originating from an invoice transaction.  In such a
         -- a case, we must get the exchange rate and convert the amounts.  If an invoice
         -- was involved, the amounts were already calculated and populated in the mrc
         -- pl/sql tables and we just need to copy them into the local variables.

         if (px_inv_trans_rec.transaction_type is null or
             fa_cache_pkg.fazcbc_record.book_class = 'TAX') then

            -- Get the associated rate for the adjustment when the invoice table is
            -- not populated.  If this is a transaction being copied form corp to tax
            -- (masscp, cip-in-tax, autocopy), then we will always get the rate for
            -- the corp trx and use that -  unless the corp is not mrc enabled

            if ((px_trans_rec.source_transaction_header_id is not null) and
                (fa_cache_pkg.fazcbc_record.book_class = 'TAX')) then
                -- get the exchange rate from the corporate transaction
               if not FA_MC_UTIL_PVT.get_existing_rate
                     (p_set_of_books_id        => l_sob_tbl(l_sob_index),
                      p_transaction_header_id  => px_trans_rec.source_transaction_header_id,
                      px_rate                  => l_rate,
                      px_avg_exchange_rate     => l_avg_rate,
                      p_log_level_rec          => p_log_level_rec
                     ) then

                  -- no rate found for corp - reporting option may not exist on corp
                  -- get the current average rate for the adjustment
                  l_exchange_date    := px_trans_rec.transaction_date_entered;

                  if not FA_MC_UTIL_PVT.get_trx_rate
                            (p_prim_set_of_books_id       => fa_cache_pkg.fazcbc_record.set_of_books_id,
                             p_reporting_set_of_books_id  => l_sob_tbl(l_sob_index),
                             px_exchange_date             => l_exchange_date,
                             p_book_type_code             => px_asset_hdr_rec.book_type_code,
                             px_rate                      => l_rate,
                             p_log_level_rec              => p_log_level_rec
                            )then
                     raise adj_err;
                  end if;
               end if;

            elsif (px_asset_hdr_rec.period_of_addition <> 'Y') then

               -- get the current average rate for the addition
               l_exchange_date    := px_trans_rec.transaction_date_entered;

               if not FA_MC_UTIL_PVT.get_trx_rate
                      (p_prim_set_of_books_id       => fa_cache_pkg.fazcbc_record.set_of_books_id,
                       p_reporting_set_of_books_id  => l_sob_tbl(l_sob_index),
                       px_exchange_date             => l_exchange_date,
                       p_book_type_code             => px_asset_hdr_rec.book_type_code,
                       px_rate                      => l_rate,
                       p_log_level_rec              => p_log_level_rec

                      )then
                  raise adj_err;
               end if;
            else -- period of addition, set to existing rate
               l_rate := l_exchange_rate;

            end if;  -- copied trx from corp

            l_exchange_rate := l_rate;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('do_all_books', 'l_exchange_rate', l_exchange_rate, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add('do_all_books', 'l_asset_fin_rec_adj_init.cost', l_asset_fin_rec_adj_init.cost, p_log_level_rec => p_log_level_rec);
            end if;

            -- Set the initial mrc struct equal to the primary structs
            --
            -- Note: it may be better to actually modify our API's to return
            -- the new structs so that we can just due a direct copy and avoid
            -- most of the calculation logic for performance reasons.

            l_asset_fin_rec_adj       := l_asset_fin_rec_adj_init;
            l_asset_deprn_rec_adj     := l_asset_deprn_rec_adj_init;
            l_group_rcl_options_rec   := l_group_rcl_options_rec_init;

            -- set the SOB info
            l_asset_fin_rec_adj.set_of_books_id       := l_sob_tbl(l_sob_index);
            l_asset_deprn_rec_adj.set_of_books_id     := l_sob_tbl(l_sob_index);

            -- convert the non-derived financial amounts using the retrieved rate
            -- all other amounts will be handled by the calculation engines (rec cost, etc)

            -- BUG# 2966849
            -- when a manual cost adjustment to 0 is done, ignore
            -- daily rates and enforce reporting cost to 0 as well
            if (l_asset_fin_rec_adj_init.cost = -l_old_primary_cost and
                l_old_primary_cost <> 0) then
               l_asset_fin_rec_adj.cost               := -l_asset_fin_rec_old.cost;
               l_asset_fin_rec_adj.unrevalued_cost    := -l_asset_fin_rec_old.unrevalued_cost;
               l_asset_fin_rec_adj.salvage_value      := -l_asset_fin_rec_old.salvage_value;
               l_asset_fin_rec_adj.original_cost      := l_asset_fin_rec_adj_init.original_cost   * l_rate;
               l_asset_fin_rec_adj.cip_cost           := l_asset_fin_rec_adj_init.cip_cost        * l_rate;
            else
               l_asset_fin_rec_adj.cost               := l_asset_fin_rec_adj_init.cost            * l_rate;
               l_asset_fin_rec_adj.unrevalued_cost    := l_asset_fin_rec_adj_init.unrevalued_cost * l_rate;
               l_asset_fin_rec_adj.salvage_value      := l_asset_fin_rec_adj_init.salvage_value   * l_rate;
               l_asset_fin_rec_adj.original_cost      := l_asset_fin_rec_adj_init.original_cost   * l_rate;
               l_asset_fin_rec_adj.cip_cost           := l_asset_fin_rec_adj_init.cip_cost        * l_rate;
            end if;

            l_group_rcl_options_rec.reserve_amount           := l_group_rcl_options_rec_init.reserve_amount           * l_rate;
            l_group_rcl_options_rec.source_exp_amount        := l_group_rcl_options_rec_init.source_exp_amount        * l_rate;
            l_group_rcl_options_rec.destination_exp_amount   := l_group_rcl_options_rec_init.destination_exp_amount   * l_rate;
            l_group_rcl_options_rec.source_eofy_reserve      := l_group_rcl_options_rec_init.source_eofy_reserve      * l_rate;
            l_group_rcl_options_rec.destination_eofy_reserve := l_group_rcl_options_rec_init.destination_eofy_reserve * l_rate;

            -- round the converted amounts using faxrnd
            -- note that precision here doesn't matter since the calculatation engine
            -- will take the finally amount and round with faxrnd (book and sob specific)

            -- round the amounts

            -- Bug 6619897 moving the rounding to the end

         else  -- invoice based trx, copy from the already populated mrc parameters

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('do_all_books', 'in', 'mrc logic for invoice', p_log_level_rec => p_log_level_rec);
            end if;

            -- find the indexes for the SOB_ID being processed in this loop

            for i in 1..l_asset_fin_mrc_tbl_adj.count loop
                if (l_asset_fin_mrc_tbl_adj(i).set_of_books_id = l_sob_tbl(l_sob_index)) then
                   l_index_fin := i;
                   exit;
                end if;
            end loop;

            if (l_asset_deprn_mrc_tbl_adj.exists(1)) then

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add('do_all_books', 'finding', 'mrc deprn rec', p_log_level_rec => p_log_level_rec);
               end if;

               for i in 1..l_asset_deprn_mrc_tbl_adj.count loop
                   if (l_asset_deprn_mrc_tbl_adj(i).set_of_books_id = l_sob_tbl(l_sob_index)) then
                      l_index_dep := i;
                      exit;
                   end if;
               end loop;

            end if;

            if ((l_index_fin is null) or
                (l_asset_deprn_mrc_tbl_adj.exists(1) and l_index_dep is null)) then
               raise adj_err;
            end if;

            l_asset_fin_rec_adj          := l_asset_fin_mrc_tbl_adj(l_index_fin);
            if (l_asset_deprn_mrc_tbl_adj.exists(1)) then
               l_asset_deprn_rec_adj     := l_asset_deprn_mrc_tbl_adj(l_index_dep);
            end if;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('do_all_books', 'l_asset_deprn_rec_adj.deprn_reserve for mrc', l_asset_deprn_rec_adj.deprn_reserve, p_log_level_rec => p_log_level_rec);
            end if;

            if (l_asset_fin_rec_adj_init.cost <> 0) then
                l_exchange_rate := l_asset_fin_rec_adj.cost /
                                   l_asset_fin_rec_adj_init.cost;
            else

                -- R12: replacing this with imbedded array
                -- for i in 1..px_inv_rate_tbl.count loop
                --     l_inv_rate_sum := l_inv_rate_sum +
                --                       px_inv_rate_tbl(i).exchange_rate;
                -- end loop;

                l_rate_count  := 0;

                for i in 1..px_inv_tbl.count loop
                   for l_inv_rate_index in 1..px_inv_tbl(i).inv_rate_tbl.count
loop
                       l_rate_count   := l_rate_count + 1;

                       l_inv_rate_sum := l_inv_rate_sum +
                                          px_inv_tbl(i).inv_rate_tbl(l_inv_rate_index).exchange_rate;
                   end loop;
                end loop;

                -- Fix for Bug #2551273.  To avoid divide by zero error
                -- only do this when the inv_rate_tbl has been populated,
                -- otherwise, it will default to the previous exchange_rate
                if (l_rate_count > 0) then
                   l_exchange_rate := l_inv_rate_sum / l_rate_count;
                end if;

            end if;

         end if; --manual or invoice transaction

         -- in period of addition, we need to insure the proportion
         -- of reserve to cost is equal between primary and reporting
         if (l_asset_fin_rec_adj_init.cost <> 0) then
            l_deprn_ratio := l_asset_fin_rec_adj.cost /
                             l_asset_fin_rec_adj_init.cost;
         else
            l_deprn_ratio := l_exchange_rate;
         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add('do_all_books', 'l_deprn_ratio', l_deprn_ratio, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('do_all_books', 'l_asset_deprn_rec_adj_init.deprn_reserve', l_asset_deprn_rec_adj_init.deprn_reserve, p_log_level_rec => p_log_level_rec);
         end if;

         l_asset_deprn_rec_adj.deprn_reserve       := l_asset_deprn_rec_adj_init.deprn_reserve * l_deprn_ratio;
         l_asset_deprn_rec_adj.ytd_deprn           := l_asset_deprn_rec_adj_init.ytd_deprn * l_deprn_ratio;
         l_asset_deprn_rec_adj.bonus_deprn_reserve := l_asset_deprn_rec_adj_init.bonus_deprn_reserve * l_deprn_ratio;
         l_asset_deprn_rec_adj.bonus_ytd_deprn     := l_asset_deprn_rec_adj_init.bonus_ytd_deprn * l_deprn_ratio;
         l_asset_deprn_rec_adj.reval_deprn_reserve := l_asset_deprn_rec_adj_init.reval_deprn_reserve * l_deprn_ratio;

         l_group_rcl_options_rec.reserve_amount           := l_group_rcl_options_rec_init.reserve_amount           * l_deprn_ratio;
         l_group_rcl_options_rec.source_exp_amount        := l_group_rcl_options_rec_init.source_exp_amount        * l_deprn_ratio;
         l_group_rcl_options_rec.destination_exp_amount   := l_group_rcl_options_rec_init.destination_exp_amount   * l_deprn_ratio;
         l_group_rcl_options_rec.source_eofy_reserve      := l_group_rcl_options_rec_init.source_eofy_reserve      * l_deprn_ratio;
         l_group_rcl_options_rec.destination_eofy_reserve := l_group_rcl_options_rec_init.destination_eofy_reserve * l_deprn_ratio;

         -- round the amounts
         --begin bug 6619897
         if not fa_utils_pkg.faxrnd
                      (x_amount => l_asset_fin_rec_adj.cost,
                       x_book   => px_asset_hdr_rec.book_type_code,
                       x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                       p_log_level_rec => p_log_level_rec) then raise adj_err;
         end if;

         if not fa_utils_pkg.faxrnd
                      (x_amount => l_asset_fin_rec_adj.unrevalued_cost,
                       x_book   => px_asset_hdr_rec.book_type_code,
                       x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                       p_log_level_rec => p_log_level_rec) then raise adj_err;
         end if;

         if not fa_utils_pkg.faxrnd
                      (x_amount => l_asset_fin_rec_adj.salvage_value,
                       x_book   => px_asset_hdr_rec.book_type_code,
                       x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                       p_log_level_rec => p_log_level_rec) then raise adj_err;
         end if;

         if not fa_utils_pkg.faxrnd
                      (x_amount => l_asset_fin_rec_adj.original_cost,
                       x_book   => px_asset_hdr_rec.book_type_code,
                       x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                       p_log_level_rec => p_log_level_rec) then raise adj_err;
         end if;

         if not fa_utils_pkg.faxrnd
                      (x_amount => l_asset_fin_rec_adj.cip_cost,
                       x_book   => px_asset_hdr_rec.book_type_code,
                       x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                       p_log_level_rec => p_log_level_rec) then raise adj_err;
         end if;


         if not fa_utils_pkg.faxrnd
                      (x_amount => l_group_rcl_options_rec.reserve_amount,
                       x_book   => px_asset_hdr_rec.book_type_code,
                       x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                       p_log_level_rec => p_log_level_rec) then raise adj_err;
         end if;

         if not fa_utils_pkg.faxrnd
                      (x_amount => l_group_rcl_options_rec.source_exp_amount,
                       x_book   => px_asset_hdr_rec.book_type_code,
                       x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                       p_log_level_rec => p_log_level_rec) then raise adj_err;
         end if;

         if not fa_utils_pkg.faxrnd
                      (x_amount => l_group_rcl_options_rec.destination_exp_amount,
                       x_book   => px_asset_hdr_rec.book_type_code,
                       x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                       p_log_level_rec => p_log_level_rec) then raise adj_err;
         end if;

         if not fa_utils_pkg.faxrnd
                      (x_amount => l_group_rcl_options_rec.source_eofy_reserve,
                       x_book   => px_asset_hdr_rec.book_type_code,
                       x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                       p_log_level_rec => p_log_level_rec) then raise adj_err;
         end if;

         if not fa_utils_pkg.faxrnd
                      (x_amount => l_group_rcl_options_rec.destination_eofy_reserve,
                       x_book   => px_asset_hdr_rec.book_type_code,
                       x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                       p_log_level_rec => p_log_level_rec) then raise adj_err;
         end if;

         --end bug 6619897

         if not fa_utils_pkg.faxrnd
                      (x_amount => l_asset_deprn_rec_adj.deprn_reserve,
                       x_book   => px_asset_hdr_rec.book_type_code,
                       x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                       p_log_level_rec => p_log_level_rec) then raise adj_err;
         end if;

         if not fa_utils_pkg.faxrnd
                      (x_amount => l_asset_deprn_rec_adj.ytd_deprn,
                       x_book   => px_asset_hdr_rec.book_type_code,
                       x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                       p_log_level_rec => p_log_level_rec) then raise adj_err;
         end if;

         if not fa_utils_pkg.faxrnd
                      (x_amount => l_asset_deprn_rec_adj.bonus_deprn_reserve,
                       x_book   => px_asset_hdr_rec.book_type_code,
                       x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                       p_log_level_rec => p_log_level_rec) then raise adj_err;
         end if;

         if not fa_utils_pkg.faxrnd
                      (x_amount => l_asset_deprn_rec_adj.bonus_ytd_deprn,
                       x_book   => px_asset_hdr_rec.book_type_code,
                       x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                       p_log_level_rec => p_log_level_rec) then raise adj_err;
         end if;

         if not fa_utils_pkg.faxrnd
                      (x_amount => l_asset_deprn_rec_adj.reval_deprn_reserve,
                       x_book   => px_asset_hdr_rec.book_type_code,
                       x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                       p_log_level_rec => p_log_level_rec) then raise adj_err;
         end if;

         if not fa_utils_pkg.faxrnd
                      (x_amount => l_group_rcl_options_rec.reserve_amount,
                       x_book   => px_asset_hdr_rec.book_type_code,
                       x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                       p_log_level_rec => p_log_level_rec) then raise adj_err;
         end if;

         if not fa_utils_pkg.faxrnd
                      (x_amount => l_group_rcl_options_rec.source_exp_amount,
                       x_book   => px_asset_hdr_rec.book_type_code,
                       x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                       p_log_level_rec => p_log_level_rec) then raise adj_err;
         end if;

         if not fa_utils_pkg.faxrnd
                      (x_amount => l_group_rcl_options_rec.destination_exp_amount,
                       x_book   => px_asset_hdr_rec.book_type_code,
                       x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                       p_log_level_rec => p_log_level_rec) then raise adj_err;
         end if;

         if not fa_utils_pkg.faxrnd
                      (x_amount => l_group_rcl_options_rec.source_eofy_reserve,
                       x_book   => px_asset_hdr_rec.book_type_code,
                       x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                       p_log_level_rec => p_log_level_rec) then raise adj_err;
         end if;

         if not fa_utils_pkg.faxrnd
                      (x_amount => l_group_rcl_options_rec.destination_eofy_reserve,
                       x_book   => px_asset_hdr_rec.book_type_code,
                       x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                       p_log_level_rec => p_log_level_rec) then raise adj_err;
         end if;

         -- begin bug 6619897
         -- when a manual adjustment to fully reserve is done, ignore
         -- daily rates and enforce reporting reserve to fully reserve as well
         if l_asset_fin_rec_adj_init.cost + l_old_primary_cost =
             l_asset_deprn_rec_adj_init.deprn_reserve + l_old_primary_deprn_reserve then

            l_asset_deprn_rec_adj.deprn_reserve := l_asset_fin_rec_old.cost + l_asset_fin_rec_adj.cost
                                                   - l_asset_deprn_rec_old.deprn_reserve;

            if l_asset_deprn_rec_adj.ytd_deprn > l_asset_deprn_rec_adj.deprn_reserve then
              l_asset_deprn_rec_adj.ytd_deprn := l_asset_deprn_rec_adj.deprn_reserve;
            end if;
         end if;

         -- end  bug 6619897

      end if;  -- primary of reporting

      -- Fix for Bug #3499223
      -- For Polish, we need additional changes here, so we know if the
      -- transaction is an adjustment if deprn catchup is needed.
      -- First find out if we have a polish mechanism here
      if (p_asset_type_rec.asset_type <> 'GROUP') and
         (nvl(l_asset_fin_rec_new.deprn_method_code,
              l_asset_fin_rec_adj.deprn_method_code) is not null) and
         (fa_cache_pkg.fazccmt (
         X_method                => nvl(l_asset_fin_rec_new.deprn_method_code,
                                        l_asset_fin_rec_adj.deprn_method_code),
         X_life                  => nvl(l_asset_fin_rec_new.life_in_months,
                                        l_asset_fin_rec_adj.life_in_months),
         p_log_level_rec => p_log_level_rec
      )) then
         if (fa_cache_pkg.fazccmt_record.deprn_basis_rule_id is not null) then
            if (fa_cache_pkg.fazcdbr_record.polish_rule in (
                     FA_STD_TYPES.FAD_DBR_POLISH_1,
                     FA_STD_TYPES.FAD_DBR_POLISH_2,
                     FA_STD_TYPES.FAD_DBR_POLISH_3,
                     FA_STD_TYPES.FAD_DBR_POLISH_4,
                     FA_STD_TYPES.FAD_DBR_POLISH_5)) then

                 fa_polish_pvt.calling_mode := 'ADJUSTMENT';
                 fa_polish_pvt.amortization_start_date :=
                    px_trans_rec.amortization_start_date;
                 fa_polish_pvt.adjustment_amount := l_asset_fin_rec_adj.cost;
            end if;
         end if;
      end if;

      --Bug8316273
      if ((p_asset_type_rec.asset_type = 'CIP')
              and (px_trans_rec.transaction_subtype = 'AMORTIZED' )) then

                px_trans_rec.transaction_subtype := 'EXPENSED';
                px_trans_rec.amortization_start_date := NULL;
      end if;

      -- Japan Tax phase3 Start
      if (l_set_extend_flag) then

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Japan Tax:1 Setting l_asset_fin_rec_adj values', 'TRUE...', p_log_level_rec => p_log_level_rec);
         end if;

         l_asset_fin_rec_adj.deprn_method_code := 'JP-STL-EXTND'; -- New STL method with life 60 months
         l_asset_fin_rec_adj.life_in_months := 60;
         --l_asset_fin_rec_adj.period_counter_fully_reserved := null;
         --l_asset_fin_rec_adj.period_counter_life_complete := null;
         l_asset_fin_rec_adj.basic_rate := null;
         l_asset_fin_rec_adj.adjusted_rate := null;
         l_asset_fin_rec_adj.allowed_deprn_limit := null;
         l_asset_fin_rec_adj.deprn_limit_type := 'AMT';
         -- bug#6658280 l_asset_fin_rec_adj.allowed_deprn_limit_amount := 1; -- Memorandum price

         /* Japan Tax phase3 Bug 6614551
            Salvage need not be changed to zero for extended asset
         if (l_asset_fin_rec_old.salvage_type = 'PCT') then
            l_asset_fin_rec_adj.percent_salvage_value := -1 * l_asset_fin_rec_old.percent_salvage_value;
         elsif (l_asset_fin_rec_old.salvage_type = 'AMT') then
            l_asset_fin_rec_adj.salvage_value := 0;
         end if; */

         px_trans_rec.transaction_key := 'ES';

      elsif (l_reset_extend_flag) then

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Japan Tax:2 Resetting l_asset_fin_rec_adj values', 'TRUE...', p_log_level_rec => p_log_level_rec);
         end if;

         -- Japan Tax phase3 Bug 6614551 no need to change salvage value
         open c_extend_get_original_deprn(l_asset_hdr_rec.asset_id, l_asset_hdr_rec.book_type_code);
         FETCH c_extend_get_original_deprn
         INTO  l_asset_fin_rec_adj.deprn_method_code,
               l_asset_fin_rec_adj.life_in_months,
               --l_asset_fin_rec_adj.salvage_value,
               --l_asset_fin_rec_adj.period_counter_fully_reserved,
               --l_asset_fin_rec_adj.period_counter_life_complete,
               l_asset_fin_rec_adj.basic_rate,
               l_asset_fin_rec_adj.adjusted_rate,
               l_asset_fin_rec_adj.allowed_deprn_limit,
               l_asset_fin_rec_adj.deprn_limit_type,
               l_asset_fin_rec_adj.allowed_deprn_limit_amount;
         close c_extend_get_original_deprn;

         l_asset_fin_rec_adj.extended_depreciation_period := FND_API.G_MISS_NUM;

         -- Added this condition for Bug#7297680

         if (l_asset_fin_rec_adj.deprn_limit_type =  l_asset_fin_rec_old.deprn_limit_type ) then
             l_asset_fin_rec_adj.allowed_deprn_limit := l_asset_fin_rec_adj.allowed_deprn_limit
                                                        - l_asset_fin_rec_old.allowed_deprn_limit;
             l_asset_fin_rec_adj.allowed_deprn_limit_amount := l_asset_fin_rec_adj.allowed_deprn_limit_amount
                                                              -l_asset_fin_rec_old.allowed_deprn_limit_amount;
         end if;

         px_trans_rec.transaction_key := 'ER';
      end if;
      -- Japan Tax phase3  end

      --Bug7627286
      --Add the rolled back deprn amount to the adj rec
      if ((px_asset_hdr_rec.period_of_addition = 'Y')
           and ((nvl(l_asset_deprn_rec_adj.deprn_reserve,0) <> 0)
           or (nvl(l_asset_deprn_rec_adj.ytd_deprn,0) <> 0))) then
                 l_asset_deprn_rec_adj.deprn_reserve := l_asset_deprn_rec_adj.deprn_reserve + nvl(l_deprn_amount,0);
                 l_asset_deprn_rec_adj.ytd_deprn := l_asset_deprn_rec_adj.ytd_deprn + nvl(l_deprn_amount,0);
      end if;


      -- call the private API for primary or reporting using the local variables for sob related info
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add('do_all_books', 'l_asset_fin_rec_adj.cost', l_asset_fin_rec_adj.cost, p_log_level_rec => p_log_level_rec);
      end if;

      if not FA_ADJUSTMENT_PVT.do_adjustment
            (px_trans_rec              => px_trans_rec,
             px_asset_hdr_rec          => l_asset_hdr_rec ,           -- mrc
             p_asset_desc_rec          => p_asset_desc_rec ,
             p_asset_type_rec          => p_asset_type_rec ,
             p_asset_cat_rec           => p_asset_cat_rec ,
             p_asset_fin_rec_old       => l_asset_fin_rec_old,    -- mrc
             p_asset_fin_rec_adj       => l_asset_fin_rec_adj,    -- mrc
             x_asset_fin_rec_new       => l_asset_fin_rec_new,    -- mrc
             p_inv_trans_rec           => px_inv_trans_rec,
             p_asset_deprn_rec_old     => l_asset_deprn_rec_old,  -- mrc
             p_asset_deprn_rec_adj     => l_asset_deprn_rec_adj,  -- mrc
             x_asset_deprn_rec_new     => l_asset_deprn_rec_new,  -- mrc
             p_period_rec              => l_period_rec,
             p_mrc_sob_type_code       => l_reporting_flag,
             p_group_reclass_options_rec => l_group_rcl_options_rec,
             p_calling_fn              => l_calling_fn
            , p_log_level_rec => p_log_level_rec)then
            raise adj_err;
     end if;

     if (l_sob_index <> 0) then
         -- if there was a cost change rederive average rate, otherwise use the prior one
         -- which has been derived above

         if (l_new_primary_cost <> 0) then
            l_avg_rate      := l_asset_fin_rec_new.cost /
                               l_new_primary_cost;
         end if;

         -- insert the books_rates record

         MC_FA_UTILITIES_PKG.insert_books_rates
              (p_set_of_books_id              => l_asset_hdr_rec.set_of_books_id,
               p_asset_id                     => l_asset_hdr_rec.asset_id,
               p_book_type_code               => l_asset_hdr_rec.book_type_code,
               p_transaction_header_id        => px_trans_rec.transaction_header_id,
               p_invoice_transaction_id       => px_inv_trans_rec.invoice_transaction_id,
               p_exchange_date                => px_trans_rec.transaction_date_entered,
               p_cost                         => l_asset_fin_rec_adj_init.cost,
               p_exchange_rate                => l_exchange_rate,
               p_avg_exchange_rate            => l_avg_rate,
               p_last_updated_by              => px_trans_rec.who_info.last_updated_by,
               p_last_update_date             => px_trans_rec.who_info.last_update_date,
               p_last_update_login            => px_trans_rec.who_info.last_update_login,
               p_complete                     => 'Y',
               p_trigger                      => 'adj api',
               p_currency_code                => l_asset_hdr_rec.set_of_books_id, p_log_level_rec => p_log_level_rec);

      else
        l_new_primary_cost := l_asset_fin_rec_new.cost;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add('do_all_books', 'before', 'group logic', p_log_level_rec => p_log_level_rec);
      end if;


      -- call the group api
      if (l_asset_fin_rec_old.group_asset_id is not null or
          l_asset_fin_rec_new.group_asset_id is not null ) then

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add('do_all_books', 'entering', 'group logic', p_log_level_rec => p_log_level_rec);
         end if;

         if (l_sob_index = 0) then

            -- set up the group recs

            l_src_asset_hdr_rec          := l_asset_hdr_rec;
            l_dest_asset_hdr_rec         := l_asset_hdr_rec;

            l_src_asset_hdr_rec.asset_id  := l_asset_fin_rec_old.group_asset_id;
            l_dest_asset_hdr_rec.asset_id := l_asset_fin_rec_new.group_asset_id;

            -- get src info
            if (l_asset_fin_rec_old.group_asset_id is not null) then

               if not FA_UTIL_PVT.get_asset_desc_rec
                           (p_asset_hdr_rec         => l_src_asset_hdr_rec,
                            px_asset_desc_rec       => l_src_asset_desc_rec
                           , p_log_level_rec => p_log_level_rec) then
                  raise adj_err;
               end if;

               if not FA_UTIL_PVT.get_asset_cat_rec
                           (p_asset_hdr_rec         => l_src_asset_hdr_rec,
                            px_asset_cat_rec        => l_src_asset_cat_rec,
                            p_date_effective        => null
                           , p_log_level_rec => p_log_level_rec) then
                  raise adj_err;
               end if;

               if not FA_UTIL_PVT.get_asset_type_rec
                           (p_asset_hdr_rec         => l_src_asset_hdr_rec,
                            px_asset_type_rec       => l_src_asset_type_rec,
                            p_date_effective        => null
                            , p_log_level_rec => p_log_level_rec) then
                  raise adj_err;
               end if;

               if not FA_ASSET_VAL_PVT.validate_period_of_addition
                           (p_asset_id            => l_src_asset_hdr_rec.asset_id,
                            p_book                => l_src_asset_hdr_rec.book_type_code,
                            p_mode                => 'ABSOLUTE',
                            px_period_of_addition => l_src_asset_hdr_rec.period_of_addition, p_log_level_rec => p_log_level_rec) then
                  raise adj_err;
               end if;

               -- call transaction approval for source asset (dest is done below)
               -- but not if destination invocation from inv xfr is on a member
               -- in the same group as the source

               if (nvl(px_inv_trans_rec.transaction_type, 'X') <> 'INVOICE TRANSFER' OR
                   nvl(g_last_group_asset_id, 0) <> nvl(l_src_asset_hdr_rec.asset_id, 0)) then
                  if not FA_TRX_APPROVAL_PKG.faxcat
                          (X_book              => l_src_asset_hdr_rec.book_type_code,
                           X_asset_id          => l_src_asset_hdr_rec.asset_id,
                           X_trx_type          => 'ADJUSTMENT',
                           X_trx_date          => px_trans_rec.transaction_date_entered,
                           X_init_message_flag => 'NO'
                          , p_log_level_rec => p_log_level_rec) then
                     raise adj_err;
                  end if;
               end if;
            end if;  -- old group asset id not null

            if (l_asset_fin_rec_new.group_asset_id is not null and
                nvl(l_asset_fin_rec_old.group_asset_id, -99) <> l_asset_fin_rec_new.group_asset_id ) then

               -- get dest info
               if not FA_UTIL_PVT.get_asset_desc_rec
                           (p_asset_hdr_rec         => l_dest_asset_hdr_rec,
                            px_asset_desc_rec       => l_dest_asset_desc_rec
                           , p_log_level_rec => p_log_level_rec) then
                  raise adj_err;
               end if;

               if not FA_UTIL_PVT.get_asset_cat_rec
                           (p_asset_hdr_rec         => l_dest_asset_hdr_rec,
                            px_asset_cat_rec        => l_dest_asset_cat_rec,
                            p_date_effective        => null
                           , p_log_level_rec => p_log_level_rec) then
                  raise adj_err;
               end if;

               if not FA_UTIL_PVT.get_asset_type_rec
                           (p_asset_hdr_rec         => l_dest_asset_hdr_rec,
                            px_asset_type_rec       => l_dest_asset_type_rec,
                            p_date_effective        => null
                            , p_log_level_rec => p_log_level_rec) then
                  raise adj_err;
               end if;

               if not FA_ASSET_VAL_PVT.validate_period_of_addition
                           (p_asset_id            => l_dest_asset_hdr_rec.asset_id,
                            p_book                => l_dest_asset_hdr_rec.book_type_code,
                            p_mode                => 'ABSOLUTE',
                            px_period_of_addition => l_dest_asset_hdr_rec.period_of_addition, p_log_level_rec => p_log_level_rec) then
                  raise adj_err;
               end if;

            end if;  -- new group asset id not null

         else
            l_src_asset_hdr_rec.set_of_books_id  :=
               l_asset_hdr_rec.set_of_books_id;
            l_dest_asset_hdr_rec.set_of_books_id :=
               l_asset_hdr_rec.set_of_books_id;

         end if;  -- primary book


         if (nvl(l_asset_fin_rec_old.group_asset_id, -99) = nvl(l_asset_fin_rec_new.group_asset_id, -99)) then
--            nvl(l_asset_fin_rec_new.member_rollup_flag,'N') <> 'Y' then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('do_all_books', 'entering', 'group adj logic', p_log_level_rec => p_log_level_rec);
            end if;

            if (l_sob_index = 0) then
               l_src_trans_rec                              := px_trans_rec;
               l_src_trans_rec.transaction_type_code        := 'GROUP ADJUSTMENT';
               l_src_trans_rec.member_transaction_header_id := px_trans_rec.transaction_header_id;
               l_src_trans_rec.transaction_subtype          := 'AMORTIZED';
               if (nvl(px_inv_trans_rec.transaction_type, 'X') = 'INVOICE DEP') then
                  l_src_trans_rec.transaction_key              := 'MD';
               elsif (nvl(px_inv_trans_rec.transaction_type, 'X') = 'INVOICE NO DEP') then
                  l_src_trans_rec.transaction_key              := 'MN';
               else
                  l_src_trans_rec.transaction_key              := 'MJ';
               end if;

               select fa_transaction_headers_s.nextval
                 into l_src_trans_rec.transaction_header_id
                 from dual;

            end if;


            -- load the old structs
            if not FA_UTIL_PVT.get_asset_fin_rec
                    (p_asset_hdr_rec         => l_src_asset_hdr_rec,
                     px_asset_fin_rec        => l_src_asset_fin_rec_old,
                     p_transaction_header_id => NULL,
                     p_mrc_sob_type_code     => l_reporting_flag
                    , p_log_level_rec => p_log_level_rec) then raise adj_err;
            end if;

            if not FA_UTIL_PVT.get_asset_deprn_rec
                    (p_asset_hdr_rec         => l_src_asset_hdr_rec ,
                     px_asset_deprn_rec      => l_src_asset_deprn_rec_old,
                     p_period_counter        => NULL,
                     p_mrc_sob_type_code     => l_reporting_flag
                     , p_log_level_rec => p_log_level_rec) then raise adj_err;
            end if;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('do_all_books', 'group adj: cip_cost', l_asset_fin_rec_adj.cip_cost, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add('do_all_books', 'group adj: cost', l_asset_fin_rec_adj.cost, p_log_level_rec => p_log_level_rec);
            end if;

            -- copy the delta cost if any into the group's fin_rec
            if (p_asset_type_rec.asset_type = 'CIP') then

               if (fa_cache_pkg.fazcbc_record.allow_cip_dep_group_flag = 'Y') then
                  l_src_asset_fin_rec_adj.cip_cost := nvl(l_asset_fin_rec_adj.cip_cost, 0);
                  l_src_asset_fin_rec_adj.cost     := nvl(l_asset_fin_rec_adj.cost, 0) - nvl(l_asset_fin_rec_adj.cip_cost, 0);
               else
                  l_src_asset_fin_rec_adj.cip_cost := nvl(l_asset_fin_rec_adj.cost, 0);
               end if;
            else
               l_src_asset_fin_rec_adj.cost := l_asset_fin_rec_adj.cost;
               l_src_asset_fin_rec_adj.salvage_value := nvl(l_asset_fin_rec_new.salvage_value, 0) -
                                                        nvl(l_asset_fin_rec_old.salvage_value, 0);
               l_src_asset_fin_rec_adj.allowed_deprn_limit_amount :=
                                          nvl(l_asset_fin_rec_new.allowed_deprn_limit_amount, 0) -
                                          nvl(l_asset_fin_rec_old.allowed_deprn_limit_amount, 0);
            end if;

            if not FA_ADJUSTMENT_PVT.do_adjustment
                     (px_trans_rec              => l_src_trans_rec,
                      px_asset_hdr_rec          => l_src_asset_hdr_rec,
                      p_asset_desc_rec          => l_src_asset_desc_rec,
                      p_asset_type_rec          => l_src_asset_type_rec,
                      p_asset_cat_rec           => l_src_asset_cat_rec,
                      p_asset_fin_rec_old       => l_src_asset_fin_rec_old,
                      p_asset_fin_rec_adj       => l_src_asset_fin_rec_adj,
                      x_asset_fin_rec_new       => l_src_asset_fin_rec_new,
                      p_inv_trans_rec           => px_inv_trans_rec,
                      p_asset_deprn_rec_old     => l_src_asset_deprn_rec_old,
                      p_asset_deprn_rec_adj     => l_src_asset_deprn_rec_adj,
                      x_asset_deprn_rec_new     => l_src_asset_deprn_rec_new,
                      p_period_rec              => l_period_rec,
                      p_mrc_sob_type_code       => l_reporting_flag,
                      p_group_reclass_options_rec => l_group_rcl_options_rec,
                      p_calling_fn              => l_calling_fn
                     , p_log_level_rec => p_log_level_rec)then
               raise adj_err;
            end if;

--         else  -- group reclass is occuring
           elsif (nvl(l_asset_fin_rec_old.group_asset_id, -99) <> nvl(l_asset_fin_rec_new.group_asset_id, -99)) then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('do_all_books', 'entering', 'group reclass logic', p_log_level_rec => p_log_level_rec);
            end if;

            /*Bug 8975022 - Group Reclass on revalued assets can not be done*/
            IF fa_asset_val_pvt.validate_reval_exists
                                 (p_book_type_code => px_asset_hdr_rec.book_type_code,
                                  p_asset_Id       => px_asset_hdr_rec.asset_id,
                                  p_calling_fn     => l_calling_fn,
                                  p_log_level_rec  => p_log_level_rec) then
               fa_srvr_msg.add_message(
                     calling_fn => l_calling_fn,
                     name       => 'FA_REVAL_TRX_EXIST', p_log_level_rec => p_log_level_rec);
               RAISE adj_err;
            END IF;

		 --Added for 6990774
           IF NOT (fa_asset_val_pvt.validate_grp_track_method
                                 (l_asset_fin_rec_old,
                                  l_asset_fin_rec_new,
				              p_group_reclass_options_rec,
 	                             p_log_level_rec)
	             ) THEN
                  RAISE adj_err;
           END IF;
            --End of 6990774

            if (l_sob_index = 0) then
               -- call transaction approval for destination asset (src was done above)
               if not FA_TRX_APPROVAL_PKG.faxcat
                       (X_book              => l_dest_asset_hdr_rec.book_type_code,
                        X_asset_id          => l_dest_asset_hdr_rec.asset_id,
                        X_trx_type          => 'ADJUSTMENT',
                        X_trx_date          => px_trans_rec.transaction_date_entered,
                        X_init_message_flag => 'NO'
                       , p_log_level_rec => p_log_level_rec) then
                  raise adj_err;
               end if;

               -- BUG# 3188779
               -- moving reclass overlap logic here from val_amort_start code
               -- Checking Max Reclass Date and restrict
               -- any transaction beyond the date.
               OPEN c_get_max_reclass_date(p_asset_id       => px_asset_hdr_rec.asset_id,
                                           p_book_type_code => px_asset_hdr_rec.book_type_code);
               FETCH c_get_max_reclass_date INTO l_max_reclass_date;
               CLOSE c_get_max_reclass_date;

               if (l_max_reclass_date is not null and
                   px_trans_rec.amortization_start_date < l_max_reclass_date) then
                  fa_srvr_msg.add_message(
                     calling_fn => l_calling_fn,
                     name       => 'FA_NO_TRX_BEFORE_RECLASS', p_log_level_rec => p_log_level_rec);
                  raise adj_err;
               end if;

               OPEN c_get_overlapping_ret (p_asset_id       => px_asset_hdr_rec.asset_id,
                                           p_book_type_code => px_asset_hdr_rec.book_type_code);
               FETCH c_get_overlapping_ret INTO l_max_ret_date;
               CLOSE c_get_overlapping_ret;

               if (l_max_ret_date is not null and
                   px_trans_rec.amortization_start_date < l_max_ret_date) then
                  fa_srvr_msg.add_message(
                     calling_fn => l_calling_fn,
                     name       => 'FA_OTHER_TRX_FOLLOW', p_log_level_rec => p_log_level_rec);
                  raise adj_err;
               end if;

               -- default the trx_type if needed
               if (l_group_rcl_options_rec.group_reclass_type is null) then
                  l_group_rcl_options_rec.group_reclass_type := 'CALC';
               end if;

               l_src_trans_rec.trx_reference_id  := px_trans_rec.trx_reference_id;
               l_dest_trans_rec.trx_reference_id := px_trans_rec.trx_reference_id;

            end if;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('do_all_books', 'l_src_asset_cat',
                                 l_src_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add('do_all_books', 'l_dest_asset_cat',
                                 l_dest_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec);
            end if;

            -- need to reclass, call the wrapper
            if not fa_group_reclass2_pvt.do_group_reclass
                     (p_trans_rec               => px_trans_rec,
                      p_asset_hdr_rec           => l_asset_hdr_rec,
                      p_asset_desc_rec          => p_asset_desc_rec,
                      p_asset_type_rec          => p_asset_type_rec,
                      p_asset_cat_rec           => p_asset_cat_rec,
                      px_src_trans_rec          => l_src_trans_rec,
                      px_src_asset_hdr_rec      => l_src_asset_hdr_rec,
                      p_src_asset_desc_rec      => l_src_asset_desc_rec,
                      p_src_asset_type_rec      => l_src_asset_type_rec,
                      p_src_asset_cat_rec       => l_src_asset_cat_rec,
                      px_dest_trans_rec         => l_dest_trans_rec,
                      px_dest_asset_hdr_rec     => l_dest_asset_hdr_rec,
                      p_dest_asset_desc_rec     => l_dest_asset_desc_rec,
                      p_dest_asset_type_rec     => l_dest_asset_type_rec,
                      p_dest_asset_cat_rec      => l_dest_asset_cat_rec,
                      p_asset_fin_rec_old       => l_asset_fin_rec_old,
                      p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
                      p_asset_fin_rec_new       => l_asset_fin_rec_new,
                      p_asset_deprn_rec_old     => l_asset_deprn_rec_old,
                      p_asset_deprn_rec_adj     => l_asset_deprn_rec_adj,
                      p_asset_deprn_rec_new     => l_asset_deprn_rec_new,
                      px_group_reclass_options_rec => l_group_rcl_options_rec,
                      p_period_rec              => l_period_rec,
                      p_mrc_sob_type_code       => l_reporting_flag,
                      p_calling_fn              => l_calling_fn
                     , p_log_level_rec => p_log_level_rec)then
               raise adj_err;
            end if;  -- do_adjustment

            /*Bug 8941132: load the trx_ref rec - start*/
            If (px_trans_rec.calling_interface <> 'FAXASSET' and l_sob_index = 0 ) then
               l_group_reclass := TRUE;
               l_trx_ref_rec.TRX_REFERENCE_ID := px_trans_rec.trx_reference_id;
               l_trx_ref_rec.TRANSACTION_TYPE := 'GROUP CHANGE';
               l_trx_ref_rec.SRC_TRANSACTION_SUBTYPE := l_src_trans_rec.transaction_subtype || ' ' || l_group_rcl_options_rec.group_reclass_type;
               l_trx_ref_rec.DEST_TRANSACTION_SUBTYPE := l_dest_trans_rec.transaction_subtype || ' ' || l_group_rcl_options_rec.group_reclass_type;
               l_trx_ref_rec.BOOK_TYPE_CODE := l_asset_hdr_rec.book_type_code;
               l_trx_ref_rec.SRC_ASSET_ID := l_src_asset_hdr_rec.asset_id;
               l_trx_ref_rec.SRC_TRANSACTION_HEADER_ID := l_src_trans_rec.transaction_header_id;
               l_trx_ref_rec.DEST_ASSET_ID := l_dest_asset_hdr_rec.asset_id;
               l_trx_ref_rec.DEST_TRANSACTION_HEADER_ID := l_dest_trans_rec.transaction_header_id;
               l_trx_ref_rec.MEMBER_ASSET_ID := l_asset_hdr_rec.asset_id;
               l_trx_ref_rec.MEMBER_TRANSACTION_HEADER_ID := px_trans_rec.transaction_header_id;
               l_trx_ref_rec.SRC_AMORTIZATION_START_DATE := l_src_trans_rec.amortization_start_date;
               l_trx_ref_rec.DEST_AMORTIZATION_START_DATE := l_dest_trans_rec.amortization_start_date;
               l_trx_ref_rec.RESERVE_TRANSFER_AMOUNT := l_group_rcl_options_rec.reserve_amount;
               l_trx_ref_rec.SRC_EXPENSE_AMOUNT := l_group_rcl_options_rec.source_exp_amount;
               l_trx_ref_rec.DEST_EXPENSE_AMOUNT := l_group_rcl_options_rec.destination_exp_amount;
               l_trx_ref_rec.SRC_EOFY_RESERVE := l_group_rcl_options_rec.source_eofy_reserve;
               l_trx_ref_rec.DEST_EOFY_RESERVE := l_group_rcl_options_rec.destination_eofy_reserve;
            end if;
            /*Bug 8941132: load the trx_ref rec - end*/
         end if;     -- end adjustment or group reclass
      end if;           -- group_asset_ids not null

      if (l_sob_index = 0) then

         -- set the primary structs
         -- no need anymore - using locals anyway
         -- Code hook for IAC

         if (FA_IGI_EXT_PKG.IAC_Enabled) then
            if not FA_IGI_EXT_PKG.Do_Adjustment(
                        p_trans_rec               => px_trans_rec,
                        p_asset_hdr_rec           => px_asset_hdr_rec,
                        p_asset_cat_rec           => p_asset_cat_rec,
                        p_asset_desc_rec          => p_asset_desc_rec,
                        p_asset_type_rec          => p_asset_type_rec,
                        p_asset_fin_rec           => l_asset_fin_rec_new,
                        p_asset_deprn_rec         => l_asset_deprn_rec_new,
                        p_calling_function        => l_calling_fn) then
               raise adj_err;
            end if;
         end if; -- (FA_IGI_EXT_PKG.IAC_Enabled)

         if cse_fa_integration_grp.is_oat_enabled then
            if not cse_fa_integration_grp.adjustment(
                         p_trans_rec          =>  px_trans_rec,
                         p_asset_hdr_rec      =>  px_asset_hdr_rec,
                         p_asset_fin_rec_adj  =>  l_asset_fin_rec_adj,
                         p_inv_tbl            =>  px_inv_tbl) then
               raise ADJ_ERR;
            end if;
         end if;


      end if;    -- primary book

   end loop;     -- sob loop

   --Bug 8941132: Calls FAPGADJB.do_group_reclass
   if (l_group_reclass) then
      if not FA_PROCESS_GROUPS_PKG.do_group_reclass(
                        p_trx_ref_rec           => l_trx_ref_rec,
                        p_mrc_sob_type_code     => 'P',
                        p_set_of_books_id       => l_asset_hdr_rec.set_of_books_id,
                        p_log_level_rec         => p_log_level_rec) then
         raise adj_err;
      end if;
   end if;

   -- Depreciation Override
   -- Bug #2688789
   --     removed thid from where clause.
   fa_std_types.deprn_override_trigger_enabled:= FALSE;
   UPDATE FA_DEPRN_OVERRIDE
      SET status = 'POSTED'
    WHERE used_by = 'ADJUSTMENT'
      AND status = 'SELECTED';
--        transaction_header_id = px_trans_rec.transaction_header_id ;
   fa_std_types.deprn_override_trigger_enabled:= TRUE;
   -- End of Depreciation Override

   -- save the group processed in the case of locking  case...
   if (nvl(px_inv_trans_rec.transaction_type, 'X') = 'INVOICE TRANSFER'
       and fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then
      if (px_inv_trans_rec.invoice_transaction_id = g_last_invoice_thid) then
         g_last_group_asset_id := null;
         g_last_invoice_thid   := null;
      else
         g_last_group_asset_id := l_asset_fin_rec_new.group_asset_id;
         g_last_invoice_thid   := px_inv_trans_rec.invoice_transaction_id;
      end if;
   end if;

   return true;

EXCEPTION

   WHEN ADJ_ERR THEN
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

END do_all_books;

-----------------------------------------------------------------------------

END FA_ADJUSTMENT_PUB;

/
