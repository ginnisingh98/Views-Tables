--------------------------------------------------------
--  DDL for Package Body FA_UNPLANNED_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_UNPLANNED_PUB" as
/* $Header: FAPUNPLB.pls 120.17.12010000.4 2009/09/16 14:19:17 gigupta ship $   */

--*********************** Global constants ******************************--

G_PKG_NAME      CONSTANT   varchar2(30) := 'FA_UNPLANNED_PUB';
G_API_NAME      CONSTANT   varchar2(30) := 'Unplanned API';
G_API_VERSION   CONSTANT   number       := 1.0;

g_log_level_rec fa_api_types.log_level_rec_type;
g_release                  number  := fa_cache_pkg.fazarel_release;

--*********************** Private functions ******************************--

-- private declaration for books (mrc) wrapper

FUNCTION do_all_books
   (px_trans_rec               IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec           IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec           IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec            IN     FA_API_TYPES.asset_cat_rec_type,
    p_unplanned_deprn_rec      IN     FA_API_TYPES.unplanned_deprn_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;


--*********************** Public procedures ******************************--

PROCEDURE do_unplanned
   (p_api_version             IN     NUMBER,
    p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_calling_fn              IN     VARCHAR2 := NULL,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    px_trans_rec              IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec          IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_unplanned_deprn_rec     IN     FA_API_TYPES.unplanned_deprn_rec_type) IS

   l_asset_desc_rec        FA_API_TYPES.asset_desc_rec_type;
   l_asset_type_rec        FA_API_TYPES.asset_type_rec_type;
   l_asset_cat_rec         FA_API_TYPES.asset_cat_rec_type;

   l_reporting_flag        VARCHAR2(1);

   l_calling_fn            VARCHAR2(35) := 'fa_unplanned_pub.do_unplanned';
   unp_err                 EXCEPTION;

BEGIN

   SAVEPOINT do_unplanned;

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise unp_err;
      end if;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   if (fnd_api.to_boolean(p_init_msg_list)) then
        -- initialize error message stack.
        fa_srvr_msg.init_server_message;

        -- initialize debug message stack.
        fa_debug_pkg.initialize;
   end if;

   -- reset after above cache initialization
   g_release := fa_cache_pkg.fazarel_release;

   -- Check version of the API
   -- Standard call to check for API call compatibility.
   if NOT fnd_api.compatible_api_call (
          G_API_VERSION,
          p_api_version,
          G_API_NAME,
          G_PKG_NAME
         ) then
      x_return_status := FND_API.G_RET_STS_ERROR;
      raise unp_err;
   end if;

   -- set up sob/mrc info
   -- call the cache for the primary transaction book
   if (NOT fa_cache_pkg.fazcbc(X_book => px_asset_hdr_rec.book_type_code, p_log_level_rec => g_log_level_rec)) then
      raise unp_err;
   end if;

   px_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

   if not (FA_ASSET_VAL_PVT.validate_asset_book
              (p_transaction_type_code      => 'ADJUSTMENT',
               p_book_type_code             => px_asset_hdr_rec.book_type_code,
               p_asset_id                   => px_asset_hdr_rec.asset_id,
               p_calling_fn                 => l_calling_fn, p_log_level_rec => g_log_level_rec)) then
      raise unp_err;
   end if;

   --  Account for transaction submitted from a responsibility
   --  that is not tied to a SOB_ID by getting the value from
   --  the book struct

   -- Get the book type code P,R or N
   if not fa_cache_pkg.fazcsob
           (X_set_of_books_id   => px_asset_hdr_rec.set_of_books_id,
            X_mrc_sob_type_code => l_reporting_flag, p_log_level_rec => g_log_level_rec) then
      raise unp_err;
   end if;

   --  Error out if the program is submitted from the Reporting Responsibility
   --  No transaction permitted directly on reporting books.

   IF l_reporting_flag = 'R' THEN
      fa_srvr_msg.add_message
          (NAME       => 'MRC_OSP_INVALID_BOOK_TYPE',
           CALLING_FN => l_calling_fn, p_log_level_rec => g_log_level_rec);
      raise unp_err;
   END IF;

   -- end initial MRC validation


   -- verify that the amortized type is populated and valid
   if (p_unplanned_deprn_rec.unplanned_type is not null) then
      if not FA_ASSET_VAL_PVT.validate_fa_lookup_code
              (p_lookup_type  => 'UNPLANNED DEPRN',
               p_lookup_code  => p_unplanned_deprn_rec.unplanned_type, p_log_level_rec => g_log_level_rec) then
         raise unp_err;
      end if;
   end if;

   --Check if impairment has been posted in current period.
   if not FA_ASSET_VAL_PVT.validate_impairment_exists
          (p_asset_id           => px_asset_hdr_rec.asset_id,
           p_book               => px_asset_hdr_rec.book_type_code,
           p_mrc_sob_type_code  => 'P',
           p_set_of_books_id    => px_asset_hdr_rec.set_of_books_id,
           p_log_level_rec      => g_log_level_rec) then
        raise FND_API.G_EXC_ERROR;
    end if;

   -- pop the asset type
   if not FA_UTIL_PVT.get_asset_type_rec
          (p_asset_hdr_rec         => px_asset_hdr_rec,
           px_asset_type_rec       => l_asset_type_rec,
           p_date_effective        => null
          , p_log_level_rec => g_log_level_rec) then
      raise unp_err;
   end if;

   -- pop the asset category
   if not FA_UTIL_PVT.get_asset_cat_rec
          (p_asset_hdr_rec         => px_asset_hdr_rec,
           px_asset_cat_rec        => l_asset_cat_rec,
           p_date_effective        => null
          , p_log_level_rec => g_log_level_rec) then
      raise unp_err;
   end if;

   -- pop the asset desc (needed for current units)
   if not FA_UTIL_PVT.get_asset_desc_rec
          (p_asset_hdr_rec         => px_asset_hdr_rec,
           px_asset_desc_rec       => l_asset_desc_rec
          , p_log_level_rec => g_log_level_rec) then
      raise unp_err;
   end if;

   if (l_asset_type_rec.asset_type <> 'CAPITALIZED' and
       l_asset_type_rec.asset_type <> 'GROUP') then
      fa_srvr_msg.add_message
          (name       => '** NO_UNPLANNED_NON_CAP **',
           calling_fn => l_calling_fn,
           p_log_level_rec => g_log_level_rec);
      raise unp_err;
   end if;

   -- Bug:4944700
   if not FA_ASSET_VAL_PVT.validate_period_of_addition
          (p_asset_id            => px_asset_hdr_rec.asset_id,
           p_book                => px_asset_hdr_rec.book_type_code,
           p_mode                => 'ABSOLUTE',
           px_period_of_addition => px_asset_hdr_rec.period_of_addition
          , p_log_level_rec => g_log_level_rec) then
      raise unp_err;
   end if;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'px_asset_hdr_rec.period_of_addition', px_asset_hdr_rec.period_of_addition, p_log_level_rec => g_log_level_rec);
   end if;


   -- check / default the trx info
   -- check the transaction_date

   -- R12 conditional handling
   if (px_asset_hdr_rec.period_of_addition = 'Y' and
       G_release = 11) then
      if l_asset_type_rec.asset_type = 'GROUP' then
         px_trans_rec.transaction_type_code := 'GROUP ADDITION';
      else
         px_trans_rec.transaction_type_code := 'ADDITION';
      end if;
   else
      if l_asset_type_rec.asset_type = 'GROUP' then
         px_trans_rec.transaction_type_code := 'GROUP ADJUSTMENT';
      else
         px_trans_rec.transaction_type_code := 'ADJUSTMENT';
      end if;
   end if;

   if (px_trans_rec.transaction_subtype is null) then
       px_trans_rec.transaction_subtype := 'EXPENSED';
   end if;

   -- but for group assets, we always amortize
   if (l_asset_type_rec.asset_type = 'GROUP') then
       px_trans_rec.transaction_subtype := 'AMORTIZED';
   end if;

   -- set the subtype
   if (px_trans_rec.transaction_subtype = 'AMORTIZED') then
      px_trans_rec.transaction_key := 'UA';
   else
      px_trans_rec.transaction_key := 'UE';
   end if;

   /* Added for bug 8584206 */
   IF not FA_ASSET_VAL_PVT.validate_energy_transactions (
               p_trans_rec            => px_trans_rec,
               p_asset_hdr_rec        => px_asset_hdr_rec,
               p_log_level_rec        => g_log_level_rec) then
           raise unp_err;
        END IF;

   -- check for prior amortizations/retirements
   if (px_trans_rec.transaction_subtype <> 'AMORTIZED') then
      if not FA_ASSET_VAL_PVT.validate_exp_after_amort
             (p_asset_id           => px_asset_hdr_rec.asset_id,
              p_book               => px_asset_hdr_rec.book_type_code
              , p_log_level_rec => g_log_level_rec) then
         raise unp_err;
      end if;
   else
      if (fa_cache_pkg.fazcbc_record.amortize_flag = 'NO') then
         fa_srvr_msg.add_message(
            calling_fn => l_calling_fn,
            name       => 'FA_BOOK_AMORTIZED_NOT_ALLOW', p_log_level_rec => g_log_level_rec);
         raise unp_err;
      end if;
   end if;

   if FA_ASSET_VAL_PVT.validate_fully_retired
          (p_asset_id           => px_asset_hdr_rec.asset_id,
           p_book               => px_asset_hdr_rec.book_type_code
          , p_log_level_rec => g_log_level_rec) then
      fa_srvr_msg.add_message
          (name       => 'FA_REC_RETIRED',
           calling_fn =>  l_calling_fn, p_log_level_rec => g_log_level_rec);
      raise unp_err;
   end if;

   -- call the mrc wrapper for the transaction book
   if not do_all_books
         (px_trans_rec               => px_trans_rec,
          px_asset_hdr_rec           => px_asset_hdr_rec,
          p_asset_desc_rec           => l_asset_desc_rec,
          p_asset_type_rec           => l_asset_type_rec,
          p_asset_cat_rec            => l_asset_cat_rec,
          p_unplanned_deprn_rec      => p_unplanned_deprn_rec,
          p_log_level_rec => g_log_level_rec
          )then
      raise unp_err;
   end if;

   -- commit if p_commit is TRUE.
   if (fnd_api.to_boolean (p_commit)) then
        COMMIT WORK;
   end if;

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   when unp_err then
      ROLLBACK to do_unplanned;

      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      FA_DEBUG_PKG.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);

      FND_MSG_PUB.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

      x_return_status := FND_API.G_RET_STS_ERROR;

   when others then
      ROLLBACK to do_unplanned;

      fa_srvr_msg.add_sql_error(
               calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      FA_DEBUG_PKG.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);

      FND_MSG_PUB.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

      x_return_status := FND_API.G_RET_STS_ERROR;

END do_unplanned;


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
    p_unplanned_deprn_rec      IN     FA_API_TYPES.unplanned_deprn_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   -- used for calling private api for reporting books
   l_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;
   l_asset_fin_rec_adj        FA_API_TYPES.asset_fin_rec_type;
   l_asset_deprn_rec_adj      FA_API_TYPES.asset_deprn_rec_type;

   -- used for retrieving "old" and "new" structs from private api calls
   l_asset_fin_rec            FA_API_TYPES.asset_fin_rec_type;
   l_asset_deprn_rec          FA_API_TYPES.asset_deprn_rec_type;

   l_unplanned_deprn_rec FA_API_TYPES.unplanned_deprn_rec_type;

   l_reporting_flag           varchar2(1);
   l_period_rec               FA_API_TYPES.period_rec_type;
   l_sob_tbl                  FA_CACHE_PKG.fazcrsob_sob_tbl_type;

   -- used for local runs
   l_responsibility_id        number;
   l_application_id           number;

   -- used for get_rate
   l_deprn_ratio              number;
   l_exchange_date            date;
   l_rate                     number;
   l_result_code              varchar2(15);

   l_complete                 varchar2(1);
   l_result_code1             varchar2(15);

   l_exchange_rate            number;
   l_avg_rate                 number;

   l_transaction_date         date;

   l_flex_structure_num       number;
   n_segs                     number;
   all_segments               fnd_flex_ext.SegmentArray;
   l_account_segnum           number;

   l_status                boolean;
   l_rowid                 rowid;

   -- Track Member
   l_grp_trans_rec                FA_API_TYPES.trans_rec_type;
   l_grp_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;
   l_grp_asset_desc_rec           FA_API_TYPES.asset_desc_rec_type;
   l_grp_asset_type_rec           FA_API_TYPES.asset_type_rec_type;
   l_grp_asset_cat_rec            FA_API_TYPES.asset_cat_rec_type;
   l_grp_asset_fin_rec            FA_API_TYPES.asset_fin_rec_type;
   l_grp_asset_deprn_rec          FA_API_TYPES.asset_deprn_rec_type;
   l_grp_deprn_basis_rule         VARCHAR2(4);
   l_grp_rate_source_rule         VARCHAR2(10);
   l_ret_code                     number;
   l_group_level_override         VARCHAR2(1) := 'Y';
   x_group_deprn_amount           number;
   x_group_bonus_amount           number;


   l_calling_fn               varchar2(30) := 'fa_unplanned_pub.do_all_books';
   unp_err                    EXCEPTION;

BEGIN

   -- call transaction approval
   if not FA_TRX_APPROVAL_PKG.faxcat
          (X_book              => px_asset_hdr_rec.book_type_code,
           X_asset_id          => px_asset_hdr_rec.asset_id,
           X_trx_type          => 'ADJUSTMENT',
           X_trx_date          => px_trans_rec.transaction_date_entered,
           X_init_message_flag => 'NO'
          , p_log_level_rec => p_log_level_rec) then
      raise unp_err;
   end if;

   if not FA_UTIL_PVT.get_period_rec
          (p_book           => px_asset_hdr_rec.book_type_code,
           p_effective_date => NULL,
           x_period_rec     => l_period_rec
          , p_log_level_rec => p_log_level_rec) then
      raise unp_err;
   end if;

   -- Bug # 4882700
   -- value for parameter "p_mode" is changed to ABSOLUTE from CAPITALIZED.
   -- check period of addition
   if not FA_ASSET_VAL_PVT.validate_period_of_addition
         (p_asset_id            => px_asset_hdr_rec.asset_id,
          p_book                => px_asset_hdr_rec.book_type_code,
          p_mode                => 'ABSOLUTE',
          px_period_of_addition => px_asset_hdr_rec.period_of_addition
         , p_log_level_rec => p_log_level_rec) then
      raise unp_err;
   end if;


   -- trx_date for all expensed transactions will be last date of open period
   l_transaction_date := greatest(l_period_rec.calendar_period_open_date,
                                  least(sysdate,l_period_rec.calendar_period_close_date));


   if (px_trans_rec.transaction_subtype = 'EXPENSED') then

       if not FA_ASSET_VAL_PVT.validate_exp_after_amort
                (p_asset_id     => px_asset_hdr_rec.asset_id,
                 p_book         => px_asset_hdr_rec.book_type_code
                , p_log_level_rec => p_log_level_rec) then
          raise unp_err;
       end if;

       px_trans_rec.transaction_date_entered :=
          to_date(to_char(l_transaction_date,'DD/MM/YYYY'),'DD/MM/YYYY');

       px_trans_rec.amortization_start_date := NULL;

   else
       -- might want to try to determin user intent here
       -- if they populate amort_start_date instead of trx_date
       if (px_trans_rec.amortization_start_date is not null) then
          px_trans_rec.transaction_date_entered := px_trans_rec.amortization_start_date;
       else
          if (px_trans_rec.transaction_date_entered is null) then
             l_transaction_date := greatest(l_period_rec.calendar_period_open_date,
                                           least(sysdate,l_period_rec.calendar_period_close_date));
             px_trans_rec.transaction_date_entered :=
                to_date(to_char(l_transaction_date,'DD/MM/YYYY'),'DD/MM/YYYY');
          end if;
          px_trans_rec.amortization_start_date := px_trans_rec.transaction_date_entered;
       end if;
   end if;

   -- BUG# 3549470
   -- remove time stamps from both dates

   px_trans_rec.transaction_date_entered :=
      to_date(to_char(px_trans_rec.transaction_date_entered,'DD/MM/YYYY'),'DD/MM/YYYY');

   px_trans_rec.amortization_start_date :=
      to_date(to_char(px_trans_rec.amortization_start_date,'DD/MM/YYYY'),'DD/MM/YYYY');

   if FA_ASSET_VAL_PVT.validate_fully_retired
          (p_asset_id           => px_asset_hdr_rec.asset_id,
           p_book               => px_asset_hdr_rec.book_type_code
          , p_log_level_rec => p_log_level_rec) then
      fa_srvr_msg.add_message
          (name       => 'FA_REC_RETIRED',
           calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      raise unp_err;
   end if;

   l_flex_structure_num             := fa_cache_pkg.fazcbc_record.accounting_flex_structure;

   -- check the ccid / set up flex info
   if not fnd_flex_apis.get_qualifier_segnum
                (appl_id          => 101,
                 key_flex_code    => 'GL#',
                 structure_number => l_flex_structure_num,
                 flex_qual_name   => 'GL_BALANCING',
                 segment_number   => l_account_segnum
                 ) then
      fa_srvr_msg.add_message
         (calling_fn => 'fnd_flex_apis.get_qualifier_segnum', p_log_level_rec => p_log_level_rec);
      raise unp_err;
   end if;

   if not fnd_flex_ext.get_segments
                (application_short_name => 'SQLGL',
                 key_flex_code          => 'GL#',
                 structure_number       => l_flex_structure_num,
                 combination_id         => p_unplanned_deprn_rec.code_combination_id,
                 n_segments             => n_segs,
                 segments               => all_segments
                ) then
      fa_srvr_msg.add_message
         (calling_fn => 'fnd_flex_ext.get_segments', p_log_level_rec => p_log_level_rec);
      raise unp_err;
   end if;

   G_expense_account := all_segments(l_account_segnum);


   -- Check whether the balancing segments values for
   -- different distributions are same or not.

   l_status := FALSE;

   FA_CHK_BALSEG_PKG.check_balancing_segments
          (book       => px_asset_hdr_rec.book_type_code,
           asset_id   => px_asset_hdr_rec.asset_id,
           success    => l_status,
           calling_fn => 'CLIENT', p_log_level_rec => p_log_level_rec);

   if not (l_status) then
      FA_SRVR_MSG.ADD_MESSAGE
         (calling_fn => 'FA_CHK_BALSEG_PKG.chk_bal_segs',  p_log_level_rec => p_log_level_rec);
      raise unp_err;
   end if;


   -- call the sob cache to get the table of sob_ids
   if not FA_CACHE_PKG.fazcrsob
          (x_book_type_code => px_asset_hdr_rec.book_type_code,
           x_sob_tbl        => l_sob_tbl, p_log_level_rec => p_log_level_rec) then
      raise unp_err;
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
         raise unp_err;
      end if;

      -- load the old structs
      if not FA_UTIL_PVT.get_asset_fin_rec
              (p_asset_hdr_rec            => l_asset_hdr_rec,
               px_asset_fin_rec           => l_asset_fin_rec,
               p_transaction_header_id    => NULL,
               p_mrc_sob_type_code        => l_reporting_flag
               , p_log_level_rec => p_log_level_rec) then
         raise unp_err;
      end if;

      if not FA_UTIL_PVT.get_asset_deprn_rec
              (p_asset_hdr_rec            => l_asset_hdr_rec ,
               px_asset_deprn_rec         => l_asset_deprn_rec,
               p_period_counter           => NULL,
               p_mrc_sob_type_code        => l_reporting_flag
               , p_log_level_rec => p_log_level_rec) then
         raise unp_err;
      end if;
      -- set the primary structs
      l_unplanned_deprn_rec           := p_unplanned_deprn_rec; /*Bug#8766910  - Intialize here */
      -- load the adj structs
      if (l_sob_index = 0) then
         -- do not allow unplanned on member assets in group centric
         -- setups...   will allow when tracking is enabled

         if (l_asset_fin_rec.group_asset_id is not null and
             l_asset_fin_rec.tracking_method is null) then
            fa_srvr_msg.add_message
               (name       => '***FA_NO_UNPLANNED_MEMBER***',
                calling_fn => l_calling_fn,
                p_log_level_rec => p_log_level_rec);
            raise unp_err;
         end if;

      else

         -- get the current average exchange rate to convert the unplanned amount
         select avg_exchange_rate
           into l_avg_rate
           from fa_mc_books_rates
          where asset_id                = l_asset_hdr_rec.asset_id
            and book_type_code          = l_asset_hdr_rec.book_type_code
            and set_of_books_id         = l_asset_hdr_rec.set_of_books_id
            and transaction_header_id   =
                (select max(transaction_header_id)
                   from fa_mc_books_rates
                  where asset_id        = l_asset_hdr_rec.asset_id
                    and book_type_code  = l_asset_hdr_rec.book_type_code
                    and set_of_books_id = l_asset_hdr_rec.set_of_books_id);

         l_unplanned_deprn_rec.unplanned_amount := l_unplanned_deprn_rec.unplanned_amount * l_avg_rate;

         if not FA_UTILS_PKG.faxrnd(l_unplanned_deprn_rec.unplanned_amount,
                                    px_asset_hdr_rec.book_type_code,
                                    l_asset_hdr_rec.set_of_books_id,
                                    p_log_level_rec => p_log_level_rec) then
             raise unp_err;
         end if;

      end if;


      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'call private do_unplanned', px_trans_rec.calling_interface, p_log_level_rec => p_log_level_rec);
      end if;

      -- this could be broken into a seperate do_all_books function if desired
      -- call the private api for the primary book
      if not FA_UNPLANNED_PVT.do_unplanned
             (px_trans_rec              => px_trans_rec,
              p_asset_hdr_rec           => l_asset_hdr_rec,
              p_asset_desc_rec          => p_asset_desc_rec,
              p_asset_type_rec          => p_asset_type_rec,
              p_asset_cat_rec           => p_asset_cat_rec,
              p_asset_fin_rec           => l_asset_fin_rec,    -- mrc
              p_asset_deprn_rec         => l_asset_deprn_rec,  -- mrc
              p_unplanned_deprn_rec     => l_unplanned_deprn_rec,
              p_period_rec              => l_period_rec,
              p_mrc_sob_type_code       => l_reporting_flag
             , p_log_level_rec => p_log_level_rec) then
         raise unp_err;
      end if;


      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Done FA_UNPLANNED_PVT.do_unplanned', ' ',  p_log_level_rec => p_log_level_rec);
      end if;

      if (l_sob_index = 0) then

         -- set the primary structs
         -- no need anymore - using locals anyway
         -- Code hook for IAC
         if (FA_IGI_EXT_PKG.IAC_Enabled) then
            if not FA_IGI_EXT_PKG.Do_Unplanned(
                    p_trans_rec               => px_trans_rec,
                    p_asset_hdr_rec           => px_asset_hdr_rec,
                    p_asset_cat_rec           => p_asset_cat_rec,
                    p_asset_desc_rec          => p_asset_desc_rec,
                    p_asset_type_rec          => p_asset_type_rec,
                    p_unplanned_deprn_rec     => p_unplanned_deprn_rec,
                    p_period_rec              => l_period_rec,
                    p_calling_function        => 'FA_UNPLANNED_PUB.Do_Unplanned') then raise unp_err;
            end if;

         end if; -- (FA_IGI_EXT_PKG.IAC_Enabled)

      else
         -- insert rates row into mc_books_rates
         MC_FA_UTILITIES_PKG.insert_books_rates
           (p_set_of_books_id              => l_asset_hdr_rec.set_of_books_id,
            p_asset_id                     => l_asset_hdr_rec.asset_id,
            p_book_type_code               => l_asset_hdr_rec.book_type_code,
            p_transaction_header_id        => px_trans_rec.transaction_header_id,
            p_invoice_transaction_id       => NULL,
            p_exchange_date                => px_trans_rec.transaction_date_entered,
            p_cost                         => 0,
            p_exchange_rate                => l_avg_rate,
            p_avg_exchange_rate            => l_avg_rate,
            p_last_updated_by              => px_trans_rec.who_info.last_updated_by,
            p_last_update_date             => px_trans_rec.who_info.last_update_date,
            p_last_update_login            => px_trans_rec.who_info.last_update_login,
            p_complete                     => 'Y',
            p_trigger                      => 'unplanned api',
            p_currency_code                => l_asset_hdr_rec.set_of_books_id, p_log_level_rec => p_log_level_rec);
      end if;    -- primary book


      -- ENERGY
      -- Eventually, following allocation process should not happen when user performs
      -- unplan from FAXASSET.  For rel 11, I modified the condition so that the
      -- allocation process will differ to Process Group Adjustment only if the deprn
      -- basis rule is ENERGY PERIOD END BALANCE'.
      --      if (px_trans_rec.calling_interface <> 'FAXASSET') then

      if (not (px_trans_rec.calling_interface = 'FAXASSET' and
                 fa_cache_pkg.fazcdrd_record.rule_name = 'ENERGY PERIOD END BALANCE')) then

         -- Calcualte Group Assets to which the processed member asset belongs
         -- This is only when the Tracking Method is ALLOCATE.

         -- If the processed asset is GROUP asset and tracking method is 'ALLOCATE',
         -- Call TRACK_ASSETS to allocate unplanned amount into members.
         -- For track member feature
         -- Only when the unplanned depreciation is kicked from group asset whose tracking method is
         -- ALLOCATE, system needs to allocate the entered unplanned depreciation amount into
         -- members.

         if l_asset_fin_rec.group_asset_id is null and
            nvl(l_asset_fin_rec.tracking_method,'OTHER') = 'ALLOCATE' then

            if not fa_cache_pkg.fazccmt (l_asset_fin_rec.deprn_method_code,l_asset_fin_rec.life_in_months, p_log_level_rec => p_log_level_rec) then
               fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
               raise unp_err;
            end if;


            l_ret_code := FA_TRACK_MEMBER_PVT.TRACK_ASSETS
                              (P_book_type_code             => px_asset_hdr_rec.book_type_code,
                               P_group_asset_id             => px_asset_hdr_rec.asset_id,
                               P_period_counter             => l_period_rec.period_num,
                               P_fiscal_year                => l_period_rec.fiscal_year,
                               P_group_deprn_basis          => fa_cache_pkg.fazccmt_record.deprn_basis_rule,
                               P_group_exclude_salvage      => fa_cache_pkg.fazccmt_record.exclude_salvage_value_flag,
                               P_group_bonus_rule           => l_asset_fin_rec.bonus_rule,
                               P_group_deprn_amount         => l_unplanned_deprn_rec.unplanned_amount,
                               P_group_bonus_amount         => 0,
                               P_tracking_method            => l_asset_fin_rec.tracking_method,
                               P_allocate_to_fully_ret_flag => l_asset_fin_rec.allocate_to_fully_ret_flag,
                               P_allocate_to_fully_rsv_flag => l_asset_fin_rec.allocate_to_fully_rsv_flag,
                               P_excess_allocation_option   => l_asset_fin_rec.excess_allocation_option,
                               P_subtraction_flag           => 'N',
                               P_group_level_override       => l_group_level_override,
                               P_transaction_date_entered   => px_trans_rec.transaction_date_entered,
                               P_mode                       => 'UNPLANNED',
                               P_MRC_SOB_TYPE_CODE          => l_reporting_flag,
                               P_SET_OF_BOOKS_ID            => l_asset_hdr_rec.set_of_books_id,

                               X_new_deprn_amount           => x_group_deprn_amount,
                               X_new_bonus_amount           => x_group_bonus_amount,  p_log_level_rec => p_log_level_rec);

            if l_ret_code <> 0 then
               raise unp_err;
            elsif x_group_deprn_amount <> l_unplanned_deprn_rec.unplanned_amount then
               raise unp_err;
            end if;

         end if;


      end if;

      -- If the asset is member asset and the group asset has tracking method, ALLOCATE,
      -- Need to process Group Level Unplanned Depreciation Calculation.

      if l_asset_fin_rec.group_asset_id is not null and
         nvl(l_asset_fin_rec.tracking_method,'OTHER') = 'ALLOCATE' then

         -- Copy group asset id to l_asset_hdr_rec.asset_id and get asset_fin_rec for the group
         -- Copy member transaction header id to l_grp_trans_rec.member_transaction_header_id
         -- and get new transaction_header_id for the group

         l_grp_asset_hdr_rec := px_asset_hdr_rec;
         l_grp_asset_hdr_rec.asset_id := l_asset_fin_rec.group_asset_id;

         l_grp_trans_rec := px_trans_rec;
         l_grp_trans_rec.member_transaction_header_id := px_trans_rec.transaction_header_id;

         select fa_transaction_headers_s.nextval
           into l_grp_trans_rec.transaction_header_id
           from dual;

         -- check period of addition for the group

         if not FA_ASSET_VAL_PVT.validate_period_of_addition
            (p_asset_id            => l_grp_asset_hdr_rec.asset_id,
             p_book                => l_grp_asset_hdr_rec.book_type_code,
             p_mode                => 'ABSOLUTE',
             px_period_of_addition => l_grp_asset_hdr_rec.period_of_addition
            , p_log_level_rec => p_log_level_rec) then
            raise unp_err;
         end if;

         -- pop the asset type
         if not FA_UTIL_PVT.get_asset_type_rec
           (p_asset_hdr_rec         => l_grp_asset_hdr_rec,
            px_asset_type_rec       => l_grp_asset_type_rec,
            p_date_effective        => null
            , p_log_level_rec => p_log_level_rec) then
            raise unp_err;
         end if;

         -- pop the asset category
         if not FA_UTIL_PVT.get_asset_cat_rec
            (p_asset_hdr_rec         => l_grp_asset_hdr_rec,
             px_asset_cat_rec        => l_grp_asset_cat_rec,
             p_date_effective        => null
            , p_log_level_rec => p_log_level_rec) then
           raise unp_err;
         end if;

         -- pop the asset desc (needed for current units)
         if not FA_UTIL_PVT.get_asset_desc_rec
            (p_asset_hdr_rec         => l_grp_asset_hdr_rec,
             px_asset_desc_rec       => l_grp_asset_desc_rec
            , p_log_level_rec => p_log_level_rec) then
           raise unp_err;
         end if;

         if (l_grp_asset_type_rec.asset_type <> 'CAPITALIZED' and
             l_grp_asset_type_rec.asset_type <> 'GROUP') then
           fa_srvr_msg.add_message
            (name       => '** NO_UNPLANNED_NON_CAP **',
             calling_fn => l_calling_fn,
             p_log_level_rec => p_log_level_rec);
           raise unp_err;
         end if;

         -- check / default the trx info (This process assumes Group Asset)
         -- R12 conditional handling
         if (l_grp_asset_hdr_rec.period_of_addition = 'Y' and
             G_release = 11) then
             l_grp_trans_rec.transaction_type_code := 'GROUP ADDITION';
         else
             l_grp_trans_rec.transaction_type_code := 'GROUP ADJUSTMENT';
         end if;

         l_grp_trans_rec.transaction_subtype := 'AMORTIZED';
         l_grp_trans_rec.transaction_key := 'UA';

         if FA_ASSET_VAL_PVT.validate_fully_retired
            (p_asset_id           => l_grp_asset_hdr_rec.asset_id,
             p_book               => l_grp_asset_hdr_rec.book_type_code
            , p_log_level_rec => p_log_level_rec) then
           fa_srvr_msg.add_message
            (name       => '*** fully retired ***',
             calling_fn => l_calling_fn,
             p_log_level_rec => p_log_level_rec);
           raise unp_err;
         end if;

         -- Check whether the balancing segments values for
         -- different distributions are same or not.

         l_status := FALSE;

         FA_CHK_BALSEG_PKG.check_balancing_segments
             (book       => l_grp_asset_hdr_rec.book_type_code,
              asset_id   => l_grp_asset_hdr_rec.asset_id,
              success    => l_status,
              calling_fn => 'CLIENT', p_log_level_rec => p_log_level_rec);

--???  message needed here?
        if not (l_status) then
           FA_SRVR_MSG.ADD_MESSAGE
                (NAME => '***flex fail***',
                 CALLING_FN => l_calling_fn,
                 p_log_level_rec => p_log_level_rec);
           raise unp_err;
        end if;

        -- load the old structs
        if not FA_UTIL_PVT.get_asset_fin_rec
              (p_asset_hdr_rec            => l_grp_asset_hdr_rec,
               px_asset_fin_rec           => l_grp_asset_fin_rec,
               p_transaction_header_id    => NULL,
               p_mrc_sob_type_code        => l_reporting_flag
               , p_log_level_rec => p_log_level_rec) then
           raise unp_err;
        end if;

        --HH validate disabled_flag
        --Doing this just as a precaustion in case the api get called directly.
        --The form, if used, won't allow the trx as the button is not shown.
        if not FA_ASSET_VAL_PVT.validate_disabled_flag
                  (p_group_asset_id => l_grp_asset_hdr_rec.asset_id,
                   p_book_type_code => l_grp_asset_hdr_rec.book_type_code,
                   p_old_flag       => l_grp_asset_fin_rec.disabled_flag,
                   p_new_flag       => l_grp_asset_fin_rec.disabled_flag
                  , p_log_level_rec => p_log_level_rec) then
            fa_srvr_msg.add_message
                   (name       => 'FA_NO_UNPLANNED_DIS_GROUP',
                    calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            raise unp_err;
        end if; --end HH.

        if not FA_UTIL_PVT.get_asset_deprn_rec
              (p_asset_hdr_rec            => l_grp_asset_hdr_rec ,
               px_asset_deprn_rec         => l_grp_asset_deprn_rec,
               p_period_counter           => NULL,
               p_mrc_sob_type_code        => l_reporting_flag
               , p_log_level_rec => p_log_level_rec) then
           raise unp_err;
        end if;

        -- this could be broken into a seperate do_all_books function if desired
        -- call the private api for the primary book
        if not FA_UNPLANNED_PVT.do_unplanned
             (px_trans_rec              => l_grp_trans_rec,
              p_asset_hdr_rec           => l_grp_asset_hdr_rec,
              p_asset_desc_rec          => l_grp_asset_desc_rec,
              p_asset_type_rec          => l_grp_asset_type_rec,
              p_asset_cat_rec           => l_grp_asset_cat_rec,
              p_asset_fin_rec           => l_grp_asset_fin_rec, -- mrc
              p_asset_deprn_rec         => l_grp_asset_deprn_rec, --mrc
              p_unplanned_deprn_rec     => l_unplanned_deprn_rec,
              p_period_rec              => l_period_rec,
              p_mrc_sob_type_code       => l_reporting_flag
             , p_log_level_rec => p_log_level_rec) then
          raise unp_err;
        end if;

      end if; -- Group Asset Process

   end loop;      -- sob loop

   return true;

EXCEPTION
   when unp_err then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

END do_all_books;

END FA_UNPLANNED_PUB;

/
