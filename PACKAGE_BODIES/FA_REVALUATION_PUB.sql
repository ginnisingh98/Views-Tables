--------------------------------------------------------
--  DDL for Package Body FA_REVALUATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_REVALUATION_PUB" as
/* $Header: FAPRVLB.pls 120.5.12010000.2 2009/07/19 12:03:18 glchen ship $   */

--*********************** Global constants ******************************--

G_PKG_NAME      CONSTANT   varchar2(30) := 'FA_REVALUATION_PUB';
G_API_NAME      CONSTANT   varchar2(30) := 'Revaluation API';
G_API_VERSION   CONSTANT   number       := 1.0;

g_log_level_rec fa_api_types.log_level_rec_type;
g_release       number  := fa_cache_pkg.fazarel_release;

--*********************** Private functions ******************************--

-- private declaration for books (mrc) wrapper

g_cip_cost    number  := 0;
g_cost        number  := 0;

FUNCTION do_all_books
   (px_trans_rec                IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec            IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec            IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec            IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec             IN     FA_API_TYPES.asset_cat_rec_type,
    p_reval_options_rec         IN     FA_API_TYPES.reval_options_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;


--*********************** Public procedures ******************************--

PROCEDURE do_reval
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
    p_reval_options_rec        IN     FA_API_TYPES.reval_options_rec_type) IS

   l_reporting_flag          varchar2(1);

   x_asset_fin_rec_new       FA_API_TYPES.asset_fin_rec_type;
   x_asset_fin_mrc_tbl_new   FA_API_TYPES.asset_fin_tbl_type;
   x_asset_deprn_rec_new     FA_API_TYPES.asset_deprn_rec_type;
   x_asset_deprn_mrc_tbl_new FA_API_TYPES.asset_deprn_tbl_type;

   l_asset_desc_rec          FA_API_TYPES.asset_desc_rec_type;
   l_asset_type_rec          FA_API_TYPES.asset_type_rec_type;
   l_asset_cat_rec           FA_API_TYPES.asset_cat_rec_type;

   l_calling_fn              VARCHAR2(35) := 'fa_reval_pub.do_reval';
   reval_err                 EXCEPTION;


BEGIN

   SAVEPOINT do_reval;

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise reval_err;
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
   if NOT fnd_api.compatible_api_call (
          G_API_VERSION,
          p_api_version,
          G_API_NAME,
          G_PKG_NAME
         ) then
      x_return_status := FND_API.G_RET_STS_ERROR;
      raise reval_err;
   end if;

   -- call the cache for the primary transaction book
   if NOT fa_cache_pkg.fazcbc(X_book => px_asset_hdr_rec.book_type_code, p_log_level_rec => g_log_level_rec) then
      raise reval_err;
   end if;

   px_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

   -- verify the book allows revaluation
   if (nvl(fa_cache_pkg.fazcbc_record.allow_reval_flag, 'NO') = 'NO') then
      fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name       => 'FA_BOOK_REVAL_NOT_ALLOW', p_log_level_rec => g_log_level_rec);
      raise reval_err;
   end if;

   -- verify the asset exist in the book already
   if not FA_ASSET_VAL_PVT.validate_asset_book
              (p_transaction_type_code      => 'ADJUSTMENT',
               p_book_type_code             => px_asset_hdr_rec.book_type_code,
               p_asset_id                   => px_asset_hdr_rec.asset_id,
               p_calling_fn                 => l_calling_fn
              , p_log_level_rec => g_log_level_rec) then
      raise reval_err;
   end if;

   -- Account for transaction submitted from a responsibility
   -- that is not tied to a SOB_ID by getting the value from
   -- the book struct

   -- Get the book type code P,R or N
   if not fa_cache_pkg.fazcsob
      (X_set_of_books_id   => px_asset_hdr_rec.set_of_books_id,
       X_mrc_sob_type_code => l_reporting_flag
      , p_log_level_rec => g_log_level_rec) then
      raise reval_err;
   end if;

   --Verify if impairment has happened in same period
   if not FA_ASSET_VAL_PVT.validate_impairment_exists
              (p_asset_id         => px_asset_hdr_rec.asset_id,
              p_book              => px_asset_hdr_rec.book_type_code,
              p_mrc_sob_type_code => l_reporting_flag,
              p_set_of_books_id   => px_asset_hdr_rec.set_of_books_id,
              p_log_level_rec     => g_log_level_rec) then
      raise reval_err;
   end if;

   --  Error out if the program is submitted from the Reporting Responsibility
   --  No transaction permitted directly on reporting books.

   IF l_reporting_flag = 'R' THEN
      fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name => 'MRC_OSP_INVALID_BOOK_TYPE', p_log_level_rec => g_log_level_rec);
      raise reval_err;
   END IF;

   -- end initial MRC validation


   -- pop the structs for the non-fin information needed for trx

   if not FA_UTIL_PVT.get_asset_desc_rec
          (p_asset_hdr_rec         => px_asset_hdr_rec,
           px_asset_desc_rec       => l_asset_desc_rec
          , p_log_level_rec => g_log_level_rec) then
      raise reval_err;
   end if;

   if not FA_UTIL_PVT.get_asset_cat_rec
          (p_asset_hdr_rec         => px_asset_hdr_rec,
           px_asset_cat_rec        => l_asset_cat_rec,
           p_date_effective        => null
          , p_log_level_rec => g_log_level_rec) then
      raise reval_err;
   end if;

   if not FA_UTIL_PVT.get_asset_type_rec
          (p_asset_hdr_rec         => px_asset_hdr_rec,
           px_asset_type_rec       => l_asset_type_rec,
           p_date_effective        => null
          , p_log_level_rec => g_log_level_rec) then
      raise reval_err;
   end if;

   -- also check if this is the period of addition - use absolute mode for revaluations
   -- do not allow reval on assets in the period of initial addition, but it's ok on the
   -- asset in same period as capitalization

   if not FA_ASSET_VAL_PVT.validate_period_of_addition
             (p_asset_id            => px_asset_hdr_rec.asset_id,
              p_book                => px_asset_hdr_rec.book_type_code,
              p_mode                => 'ABSOLUTE',
              px_period_of_addition => px_asset_hdr_rec.period_of_addition, p_log_level_rec => g_log_level_rec) then
      raise reval_err;
   elsif (px_asset_hdr_rec.period_of_addition = 'Y' and
          G_release = 11) then
      fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name => 'FA_REVAL_NO_DEPRECIATED', p_log_level_rec => g_log_level_rec);
      raise reval_err;
   end if;

   -- call the mrc wrapper for the transaction book

   if not do_all_books
      (px_trans_rec               => px_trans_rec,
       px_asset_hdr_rec           => px_asset_hdr_rec ,
       p_asset_desc_rec           => l_asset_desc_rec ,
       p_asset_type_rec           => l_asset_type_rec ,
       p_asset_cat_rec            => l_asset_cat_rec ,
       p_reval_options_rec        => p_reval_options_rec ,
       p_log_level_rec            => g_log_level_rec
      )then
      raise reval_err;
   end if;

   -- If book is a corporate book, process cip assets and autocopy
   -- NOTE: not implementing this for REVAL!

   -- commit if p_commit is TRUE.
   if (fnd_api.to_boolean (p_commit) and
       p_reval_options_rec.run_mode = 'RUN') then
        COMMIT WORK;
   end if;

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when reval_err then
      ROLLBACK TO do_reval;

      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      FND_MSG_PUB.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

      x_return_status :=  FND_API.G_RET_STS_ERROR;

   when others then
      ROLLBACK TO do_reval;

      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      FND_MSG_PUB.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

      x_return_status :=  FND_API.G_RET_STS_ERROR;

END do_reval;

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
    p_reval_options_rec        IN     FA_API_TYPES.reval_options_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   -- used for calling private api for reporting books
   l_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;

   -- used for retrieving "old" and "new" structs from private api calls
   l_asset_fin_rec_old        FA_API_TYPES.asset_fin_rec_type;
   l_asset_deprn_rec_old      FA_API_TYPES.asset_deprn_rec_type;

   l_reporting_flag          varchar2(1);

   l_period_rec               FA_API_TYPES.period_rec_type;
   l_sob_tbl                  FA_CACHE_PKG.fazcrsob_sob_tbl_type;

   l_transaction_date        date;

   l_calling_fn              varchar2(30) := 'fa_reval_pub.do_all_books';
   reval_err                 EXCEPTION;

BEGIN

   if (p_reval_options_rec.run_mode = 'RUN') then
      -- BUG# 2247404 and 2230178 - call regardless if from a mass request
      if not FA_TRX_APPROVAL_PKG.faxcat
          (X_book              => px_asset_hdr_rec.book_type_code,
           X_asset_id          => px_asset_hdr_rec.asset_id,
           X_trx_type          => px_trans_rec.transaction_type_code,
           X_trx_date          => px_trans_rec.transaction_date_entered,
           X_init_message_flag => 'NO'
          , p_log_level_rec => p_log_level_rec) then
         raise reval_err;
      end if;
   end if;

   -- load the period struct for current period info
   if not FA_UTIL_PVT.get_period_rec
          (p_book           => px_asset_hdr_rec.book_type_code,
           p_effective_date => NULL,
           x_period_rec     => l_period_rec
          , p_log_level_rec => p_log_level_rec) then
      raise reval_err;
   end if;


   -- verify asset is not fully retired ? valid for reval?
   if fa_asset_val_pvt.validate_fully_retired
          (p_asset_id          => px_asset_hdr_rec.asset_id,
           p_book              => px_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec) then
      fa_srvr_msg.add_message
          (name      => 'FA_REC_RETIRED',
           calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      raise reval_err;
   end if;


   -- call the sob cache to get the table of sob_ids
   if not FA_CACHE_PKG.fazcrsob
          (x_book_type_code => px_asset_hdr_rec.book_type_code,
           x_sob_tbl        => l_sob_tbl, p_log_level_rec => p_log_level_rec) then
      raise reval_err;
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
         raise reval_err;
      end if;

      -- load the old structs
      if not FA_UTIL_PVT.get_asset_fin_rec
              (p_asset_hdr_rec         => l_asset_hdr_rec,
               px_asset_fin_rec        => l_asset_fin_rec_old,
               p_transaction_header_id => NULL,
               p_mrc_sob_type_code     => l_reporting_flag
              , p_log_level_rec => p_log_level_rec) then raise reval_err;
      end if;

      -- set the trx date
      -- note favrvl.opc currently only uses greatest (sysdate/cpod)

      l_transaction_date := greatest(l_period_rec.calendar_period_open_date,
                                     least(sysdate,l_period_rec.calendar_period_close_date));

      px_trans_rec.transaction_date_entered :=
         to_date(to_char(l_transaction_date,'DD/MM/YYYY'),'DD/MM/YYYY');

      if not FA_UTIL_PVT.get_asset_deprn_rec
              (p_asset_hdr_rec         => l_asset_hdr_rec ,
               px_asset_deprn_rec      => l_asset_deprn_rec_old,
               p_period_counter        => NULL,
               p_mrc_sob_type_code     => l_reporting_flag
               , p_log_level_rec => p_log_level_rec) then raise reval_err;
      end if;

      -- load the adj structs
      if (l_sob_index = 0) then

         -- validate changes are being made and are valid
         if not fa_revaluation_pvt.validate_reval
                (p_trans_rec           => px_trans_rec,
                 p_asset_hdr_rec       => px_asset_hdr_rec,
                 p_asset_desc_rec      => p_asset_desc_rec,
                 p_asset_type_rec      => p_asset_type_rec,
                 p_asset_cat_rec       => p_asset_cat_rec,
                 p_asset_fin_rec_old   => l_asset_fin_rec_old,
                 p_asset_deprn_rec_old => l_asset_deprn_rec_old,
                 p_reval_options_rec   => p_reval_options_rec, p_log_level_rec => p_log_level_rec) then
            raise reval_err;
         end if;

         -- no else else here for reporting as we do nothing with rate converisons, etc

      end if;  -- primary of reporting


      -- call the private API for primary and reporting using the local variables for sob related info
      -- only if the mode is RUN
      -- if the mode is PREVIEW call the private API only for primary
      -- spooyath


      if (p_reval_options_rec.run_mode = 'PREVIEW') then

         if (l_sob_index = 0) then
            if not FA_REVALUATION_PVT.do_reval
                   (px_trans_rec              => px_trans_rec,
                    px_asset_hdr_rec          => l_asset_hdr_rec ,           -- mrc
                    p_asset_desc_rec          => p_asset_desc_rec ,
                    p_asset_type_rec          => p_asset_type_rec ,
                    p_asset_cat_rec           => p_asset_cat_rec ,
                    p_asset_fin_rec_old       => l_asset_fin_rec_old,    -- mrc
                    p_asset_deprn_rec_old     => l_asset_deprn_rec_old,  -- mrc
                    p_period_rec              => l_period_rec,
                    p_mrc_sob_type_code       => l_reporting_flag,
                    p_reval_options_rec       => p_reval_options_rec,
                    p_calling_fn              => l_calling_fn
                   , p_log_level_rec => p_log_level_rec)then
                   raise reval_err;
            end if;
            EXIT;
         end if;
      else
         if not FA_REVALUATION_PVT.do_reval
                   (px_trans_rec              => px_trans_rec,
                    px_asset_hdr_rec          => l_asset_hdr_rec ,           -- mrc
                    p_asset_desc_rec          => p_asset_desc_rec ,
                    p_asset_type_rec          => p_asset_type_rec ,
                    p_asset_cat_rec           => p_asset_cat_rec ,
                    p_asset_fin_rec_old       => l_asset_fin_rec_old,    -- mrc
                    p_asset_deprn_rec_old     => l_asset_deprn_rec_old,  -- mrc
                    p_period_rec              => l_period_rec,
                    p_mrc_sob_type_code       => l_reporting_flag,
                    p_reval_options_rec       => p_reval_options_rec,
                    p_calling_fn              => l_calling_fn
                   , p_log_level_rec => p_log_level_rec)then
                   raise reval_err;
         end if;
      end if;

      -- do not insert the books_rates record for reval
      -- no group logic here (not allowed on group members)

      -- should be need for an IAC hook - verify!

   end loop;     -- sob loop

   return true;

EXCEPTION

   WHEN reval_err THEN
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

END do_all_books;

-----------------------------------------------------------------------------

END FA_REVALUATION_PUB;

/
