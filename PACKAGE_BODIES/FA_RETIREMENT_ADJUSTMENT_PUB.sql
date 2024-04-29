--------------------------------------------------------
--  DDL for Package Body FA_RETIREMENT_ADJUSTMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RETIREMENT_ADJUSTMENT_PUB" AS
/* $Header: FAPRADJB.pls 120.15.12010000.3 2009/07/19 12:17:20 glchen ship $ */


--*********************** Global constants ******************************--

G_PKG_NAME      CONSTANT   varchar2(30) := 'FA_ADJUSTMENT_PUB';
G_API_NAME      CONSTANT   varchar2(30) := 'Adjustment API';
G_API_VERSION   CONSTANT   number       := 1.0;

g_log_level_rec fa_api_types.log_level_rec_type;

--*********************** Private functions ******************************--
-- This private function calls fa_asset_val_pvt.validate_over_depreciate
-- to determine this retirement adjustment is valid or not
FUNCTION validate_over_depreciate
   (p_asset_hdr_rec                   FA_API_TYPES.asset_hdr_rec_type,
    p_asset_type_rec                  FA_API_TYPES.asset_type_rec_type,
    p_asset_fin_rec                   FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec                 FA_API_TYPES.asset_deprn_rec_type,
    p_proceeds_of_sale                NUMBER,
    p_cost_of_removal                 NUMBER
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION do_all_books
   (px_trans_rec               IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_cost_of_removal          IN     NUMBER,
    p_proceeds                 IN     NUMBER,
    p_cost_of_removal_ccid     IN     NUMBER,
    p_proceeds_ccid            IN     NUMBER

   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;


--*********************** Public procedures ******************************--


PROCEDURE do_retirement_adjustment
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
    p_cost_of_removal          IN     NUMBER,
    p_proceeds                 IN     NUMBER,
    p_cost_of_removal_ccid     IN     NUMBER DEFAULT NULL,
    p_proceeds_ccid            IN     NUMBER DEFAULT NULL) IS

   l_reporting_flag          varchar2(1);

   l_calling_fn              VARCHAR2(35) := 'fa_ret_adj_pub.do_ret_adj';
   ret_adj_err               EXCEPTION;

BEGIN

   SAVEPOINT do_retirement_adjustment;


   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise ret_adj_err;
      end if;
   end if;

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
      raise ret_adj_err;
   end if;

   -- call the cache for the primary transaction book
   if NOT fa_cache_pkg.fazcbc(X_book => px_asset_hdr_rec.book_type_code, p_log_level_rec => g_log_level_rec) then
      raise ret_adj_err;
   end if;

   -- verify the asset exists in the book already
   if not FA_ASSET_VAL_PVT.validate_asset_book
              (p_transaction_type_code      => 'ADJUSTMENT',
               p_book_type_code             => px_asset_hdr_rec.book_type_code,
               p_asset_id                   => px_asset_hdr_rec.asset_id,
               p_calling_fn                 => l_calling_fn
              , p_log_level_rec => g_log_level_rec) then
      raise ret_adj_err;
   end if;

   -- Account for transaction submitted from a responsibility
   -- that is not tied to a SOB_ID by getting the value from
   -- the book struct

   -- Get the book type code P,R or N
   if not fa_cache_pkg.fazcsob
      (X_set_of_books_id   => fa_cache_pkg.fazcbc_record.set_of_books_id,
       X_mrc_sob_type_code => l_reporting_flag
      , p_log_level_rec => g_log_level_rec) then
      raise ret_adj_err;
   end if;

   --  Error out if the program is submitted from the Reporting Responsibility
   --  No transaction permitted directly on reporting books.

   IF l_reporting_flag = 'R' THEN
      fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name => 'MRC_OSP_INVALID_BOOK_TYPE', p_log_level_rec => g_log_level_rec);
      raise ret_adj_err;
   END IF;

   -- end initial MRC validation



   -- call the mrc wrapper for the transaction book

   if not do_all_books
      (px_asset_hdr_rec        => px_asset_hdr_rec,
       px_trans_rec            => px_trans_rec,
       p_cost_of_removal       => p_cost_of_removal,
       p_proceeds              => p_proceeds,
       p_cost_of_removal_ccid  => p_cost_of_removal_ccid,
       p_proceeds_ccid         => p_proceeds_ccid,
       p_log_level_rec         => g_log_level_rec
      )then
      raise ret_adj_err;
   end if;

   -- no auto-copy / cip in tax for group reclass transactions

   -- commit if p_commit is TRUE.
   if (fnd_api.to_boolean (p_commit)) then
        COMMIT WORK;
   end if;


   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when ret_adj_err then
      ROLLBACK TO do_retirement_adjustment;

      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      -- do not retrieve / clear messaging when this is being called
      -- from reclass api - allow calling util to dump them
      FND_MSG_PUB.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data
         );
      x_return_status :=  FND_API.G_RET_STS_ERROR;

   when others then
      ROLLBACK TO do_retirement_adjustment;

      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      -- do not retrieve / clear messaging when this is being called
      -- from reclass api - allow calling util to dump them
      FND_MSG_PUB.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data
         );

      x_return_status :=  FND_API.G_RET_STS_ERROR;

END do_retirement_adjustment;

-----------------------------------------------------------------------------

-- Books (MRC) Wrapper - called from public API above
--
-- For non mrc books, this just calls the private API with provided params
-- For MRC, it processes the primary and then loops through each reporting
-- book calling the private api for each.


FUNCTION do_all_books
   (px_trans_rec               IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_cost_of_removal          IN     NUMBER,
    p_proceeds                 IN     NUMBER,
    p_cost_of_removal_ccid     IN     NUMBER,
    p_proceeds_ccid            IN     NUMBER
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS


   -- used for new source asset
   l_asset_hdr_rec          fa_api_types.asset_hdr_rec_type;
   l_mrc_asset_hdr_rec      fa_api_types.asset_hdr_rec_type;
   l_asset_desc_rec         fa_api_types.asset_desc_rec_type;
   l_asset_type_rec         fa_api_types.asset_type_rec_type;
   l_asset_cat_rec          fa_api_types.asset_cat_rec_type;
   l_asset_fin_rec_old      fa_api_types.asset_fin_rec_type;
   l_asset_fin_rec_new      fa_api_types.asset_fin_rec_type;
   l_asset_deprn_rec_old    fa_api_types.asset_deprn_rec_type;
   l_asset_deprn_rec_new    fa_api_types.asset_deprn_rec_type;

   l_proceeds                   number;
   l_cost_of_removal            number;

   l_primary_cost               number;   -- ??? use ???

   l_period_rec                 FA_API_TYPES.period_rec_type;
   l_rsob_tbl                   FA_CACHE_PKG.fazcrsob_sob_tbl_type;
   l_reporting_flag             varchar2(1);

   l_exchange_rate              number;
   l_avg_rate                   number;

   l_rowid                      varchar2(40);
   l_return_status              boolean;

   l_calling_fn                 VARCHAR2(35) := 'fa_ret_adj_pub.do_all_books';
   ret_adj_err                  exception;

BEGIN

   -- load the initial values in structs
   px_asset_hdr_rec.set_of_books_id    := fa_cache_pkg.fazcbc_record.set_of_books_id;

   l_asset_hdr_rec       := px_asset_hdr_rec;

   px_trans_rec.transaction_type_code := 'GROUP ADJUSTMENT';  -- **** ??? ****
   px_trans_rec.transaction_subtype   := 'AMORTIZED';
   px_trans_rec.transaction_key       := 'GR';

   -- we need the thid first for inserting clearing into adjustments
   select fa_transaction_headers_s.nextval
     into px_trans_rec.transaction_header_id
     from dual;

   -- load the period struct for current period info
   if not FA_UTIL_PVT.get_period_rec
          (p_book           => l_asset_hdr_rec.book_type_code,
           p_effective_date => NULL,
           x_period_rec     => l_period_rec
          , p_log_level_rec => p_log_level_rec) then
      raise ret_adj_err;
   end if;

   -- note that we need to investigate / determine transaction subtype and track member impacts!!!!
   -- how to handle amort start / trx_date , etc on the member in all three scenarios

   px_trans_rec.transaction_date_entered :=
      greatest(l_period_rec.calendar_period_open_date,
               least(sysdate,l_period_rec.calendar_period_close_date));

   -- call transaction approval for source asset
   if not FA_TRX_APPROVAL_PKG.faxcat
          (X_book              => px_asset_hdr_rec.book_type_code,
           X_asset_id          => px_asset_hdr_rec.asset_id,
           X_trx_type          => px_trans_rec.transaction_type_code,
           X_trx_date          => px_trans_rec.transaction_date_entered,
           X_init_message_flag => 'NO'
          , p_log_level_rec => p_log_level_rec) then
      raise ret_adj_err;
   end if;


   -- also check if this is the period of addition - use absolute mode for adjustments
   -- we will only clear cost outside period of addition
   if not FA_ASSET_VAL_PVT.validate_period_of_addition
             (p_asset_id            => l_asset_hdr_rec.asset_id,
              p_book                => l_asset_hdr_rec.book_type_code,
              p_mode                => 'ABSOLUTE',
              px_period_of_addition => l_asset_hdr_rec.period_of_addition, p_log_level_rec => p_log_level_rec) then
      raise ret_adj_err;
   end if;


   -- pop the structs for the non-fin information needed for trx
   -- source
   if not FA_UTIL_PVT.get_asset_desc_rec
          (p_asset_hdr_rec          => l_asset_hdr_rec,
           px_asset_desc_rec        => l_asset_desc_rec
          , p_log_level_rec => p_log_level_rec) then
      raise ret_adj_err;
   end if;

   if not FA_UTIL_PVT.get_asset_cat_rec
          (p_asset_hdr_rec          => l_asset_hdr_rec,
           px_asset_cat_rec         => l_asset_cat_rec,
           p_date_effective         => null
          , p_log_level_rec => p_log_level_rec) then
      raise ret_adj_err;
   end if;

   if not FA_UTIL_PVT.get_asset_type_rec
          (p_asset_hdr_rec         => l_asset_hdr_rec,
           px_asset_type_rec       => l_asset_type_rec,
           p_date_effective        => null
          , p_log_level_rec => p_log_level_rec) then
      raise ret_adj_err;
   end if;

   -- Call the reporting books cache to get rep books.
   if (NOT fa_cache_pkg.fazcrsob (
             x_book_type_code => l_asset_hdr_rec.book_type_code,
             x_sob_tbl        => l_rsob_tbl
           , p_log_level_rec => p_log_level_rec)) then
       raise ret_adj_err;
   end if;

   if not FA_XLA_EVENTS_PVT.create_transaction_event
            (p_asset_hdr_rec          => px_asset_hdr_rec,
             p_asset_type_rec         => l_asset_type_rec,
             px_trans_rec             => px_trans_rec,
             p_event_status           => NULL,
             p_calling_fn             => l_calling_fn,
             p_log_level_rec => p_log_level_rec) then
      raise ret_adj_err;
   end if;

   fa_transaction_headers_pkg.insert_row
      (x_rowid                    => l_rowid,
       x_transaction_header_id    => px_trans_rec.transaction_header_id,
       x_book_type_code           => px_asset_hdr_rec.book_type_code,
       x_asset_id                 => px_asset_hdr_rec.asset_id,
       x_transaction_type_code    => px_trans_rec.transaction_type_code,
       x_transaction_date_entered => px_trans_rec.transaction_date_entered,
       x_date_effective           => px_trans_rec.who_info.last_update_date,
       x_last_update_date         => px_trans_rec.who_info.last_update_date,
       x_last_updated_by          => px_trans_rec.who_info.last_updated_by,
       x_transaction_name         => px_trans_rec.transaction_name,
       x_last_update_login        => px_trans_rec.who_info.last_update_login,
       x_transaction_key          => px_trans_rec.transaction_key,
       x_transaction_subtype      => px_trans_rec.transaction_subtype,
       x_amortization_start_date  => px_trans_rec.amortization_start_date,
       x_calling_interface        => px_trans_rec.calling_interface,
       x_mass_transaction_id      => px_trans_rec.mass_transaction_id,
       x_trx_reference_id         => px_trans_rec.trx_reference_id,
       x_event_id                 => px_trans_rec.event_id,
       x_return_status            => l_return_status,
       x_calling_fn               => l_calling_fn, p_log_level_rec => p_log_level_rec);


   for l_mrc_index in 0..l_rsob_tbl.COUNT loop

      l_mrc_asset_hdr_rec  := l_asset_hdr_rec;

      if (l_mrc_index  = 0) then
         l_mrc_asset_hdr_rec.set_of_books_id  := fa_cache_pkg.fazcbc_record.set_of_books_id;
         l_reporting_flag := 'P';
      else
         l_mrc_asset_hdr_rec.set_of_books_id  := l_rsob_tbl(l_mrc_index);
         l_reporting_flag := 'R';
      end if;

      -- Need to always call fazcbcs
      if (NOT fa_cache_pkg.fazcbcs (
                X_book => l_mrc_asset_hdr_rec.book_type_code,
                X_set_of_books_id => l_mrc_asset_hdr_rec.set_of_books_id
         , p_log_level_rec => p_log_level_rec)) then
         raise ret_adj_err;
      end if;

      -- get the old fin and deprn information
      if not FA_UTIL_PVT.get_asset_fin_rec
              (p_asset_hdr_rec         => l_mrc_asset_hdr_rec,
               px_asset_fin_rec        => l_asset_fin_rec_old,
               p_transaction_header_id => NULL,
               p_mrc_sob_type_code     => l_reporting_flag
              , p_log_level_rec => p_log_level_rec) then raise ret_adj_err;
      end if;
      --HH validate disabled_flag
      if not FA_ASSET_VAL_PVT.validate_disabled_flag
                  (p_group_asset_id => l_mrc_asset_hdr_rec.asset_id,
                   p_book_type_code => l_mrc_asset_hdr_rec.book_type_code,
                   p_old_flag       => l_asset_fin_rec_old.disabled_flag,
                   p_new_flag       => l_asset_fin_rec_old.disabled_flag
                  , p_log_level_rec => p_log_level_rec) then
            raise ret_adj_err;
      end if; -- end HH

      if not FA_UTIL_PVT.get_asset_deprn_rec
              (p_asset_hdr_rec         => l_mrc_asset_hdr_rec ,
               px_asset_deprn_rec      => l_asset_deprn_rec_old,
               p_period_counter        => NULL,
               p_mrc_sob_type_code     => l_reporting_flag
              , p_log_level_rec => p_log_level_rec) then raise ret_adj_err;
      end if;


      -- in order to derive the transfer amount for the reporting
      -- books, we will use a ratio of the primary amount / primary cost
      -- for the source asset


      if (l_mrc_index = 0) then
         l_proceeds        := p_proceeds;
         l_cost_of_removal := p_cost_of_removal;
         l_primary_cost    := l_asset_fin_rec_old.cost;
      else
         if (l_primary_cost <> 0) then
            l_proceeds        := p_proceeds        * (l_asset_fin_rec_old.cost / l_primary_cost);
            l_cost_of_removal := p_cost_of_removal * (l_asset_fin_rec_old.cost / l_primary_cost);
         else
            -- get the latest average rate (used conditionally in some cases below)
            if not fa_mc_util_pvt.get_latest_rate
                   (p_asset_id            => l_mrc_asset_hdr_rec.asset_id,
                    p_book_type_code      => l_mrc_asset_hdr_rec.book_type_code,
                    p_set_of_books_id     => l_mrc_asset_hdr_rec.set_of_books_id,
                    px_rate               => l_exchange_rate,
                    px_avg_exchange_rate  => l_avg_rate
                   , p_log_level_rec => p_log_level_rec) then raise ret_adj_err;
            end if;

            l_proceeds        := p_proceeds        * l_avg_rate;
            l_cost_of_removal := p_cost_of_removal * l_avg_rate;

         end if;
      end if;

      if not validate_over_depreciate
             (p_asset_hdr_rec         => l_mrc_asset_hdr_rec,
              p_asset_type_rec        => l_asset_type_rec,
              p_asset_fin_rec         => l_asset_fin_rec_old,
              p_asset_deprn_rec       => l_asset_deprn_rec_old,
              p_proceeds_of_sale      => l_proceeds,
              p_cost_of_removal       => l_cost_of_removal,
              p_log_level_rec         => p_log_level_rec
             ) then
         raise ret_adj_err;
      end if;

      -- now call the private api to do the processing

      if not FA_RETIREMENT_ADJUSTMENT_PVT.do_retirement_adjustment
               (px_trans_rec              => px_trans_rec,
                px_asset_hdr_rec          => l_mrc_asset_hdr_rec,
                p_asset_desc_rec          => l_asset_desc_rec,
                p_asset_type_rec          => l_asset_type_rec,
                p_asset_cat_rec           => l_asset_cat_rec,
                p_asset_fin_rec_old       => l_asset_fin_rec_old,
                x_asset_fin_rec_new       => l_asset_fin_rec_new,
                p_asset_deprn_rec_old     => l_asset_deprn_rec_old,
                x_asset_deprn_rec_new     => l_asset_deprn_rec_new,
                p_period_rec              => l_period_rec,
                p_mrc_sob_type_code       => l_reporting_flag,
                p_cost_of_removal         => l_cost_of_removal,
                p_proceeds                => l_proceeds,
                p_cost_of_removal_ccid    => p_cost_of_removal_ccid,
                p_proceeds_ccid           => p_proceeds_ccid
               , p_log_level_rec => p_log_level_rec)then
         raise ret_adj_err;
      end if; -- do_adjustment

   end loop;

   return true;

EXCEPTION

   WHEN ret_adj_err THEN
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;


end do_all_books;

FUNCTION validate_over_depreciate
   (p_asset_hdr_rec                   FA_API_TYPES.asset_hdr_rec_type,
    p_asset_type_rec                  FA_API_TYPES.asset_type_rec_type,
    p_asset_fin_rec                   FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec                 FA_API_TYPES.asset_deprn_rec_type,
    p_proceeds_of_sale                NUMBER,
    p_cost_of_removal                 NUMBER
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_deprn_reserve_new  NUMBER := 0;
BEGIN

   l_deprn_reserve_new := nvl(p_asset_deprn_rec.deprn_reserve, 0) +
                          nvl(p_proceeds_of_sale, 0) -
                          nvl(p_cost_of_removal, 0);

   if (not fa_asset_val_pvt.validate_over_depreciate(
              p_asset_hdr_rec              => p_asset_hdr_rec,
              p_asset_type                 => p_asset_type_rec.asset_type,
              p_over_depreciate_option     => p_asset_fin_rec.over_depreciate_option,
              p_adjusted_recoverable_cost  => p_asset_fin_rec.adjusted_recoverable_cost,
              p_recoverable_cost           => p_asset_fin_rec.recoverable_cost,
              p_deprn_reserve_new          => l_deprn_reserve_new, p_log_level_rec => p_log_level_rec)) then

      return false;
   end if;

   return TRUE;

END validate_over_depreciate;

END FA_RETIREMENT_ADJUSTMENT_PUB ;

/
