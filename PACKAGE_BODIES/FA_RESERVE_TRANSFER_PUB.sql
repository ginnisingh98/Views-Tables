--------------------------------------------------------
--  DDL for Package Body FA_RESERVE_TRANSFER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RESERVE_TRANSFER_PUB" AS
/* $Header: FAPRSVXB.pls 120.9.12010000.3 2009/07/19 12:02:22 glchen ship $ */


--*********************** Global constants ******************************--

G_PKG_NAME      CONSTANT   varchar2(30) := 'FA_RESERVE_TRANSFER_PUB';
G_API_NAME      CONSTANT   varchar2(30) := 'Reserve Transfer API';
G_API_VERSION   CONSTANT   number       := 1.0;

g_log_level_rec fa_api_types.log_level_rec_type;
g_release                  number  := fa_cache_pkg.fazarel_release;

--*********************** Private functions ******************************--

FUNCTION do_all_books
   (p_src_asset_id             IN     NUMBER,
    p_dest_asset_id            IN     NUMBER,
    p_book_type_code           IN     VARCHAR2,
    px_src_trans_rec           IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_dest_trans_rec          IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    p_amount                   IN     NUMBER
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;


--*********************** Public procedures ******************************--


PROCEDURE do_reserve_transfer
   (p_api_version              IN     NUMBER,
    p_init_msg_list            IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                   IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level         IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_calling_fn               IN     VARCHAR2,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2,

    p_src_asset_id             IN     NUMBER,
    p_dest_asset_id            IN     NUMBER,
    p_book_type_code           IN     VARCHAR2,
    p_amount                   IN     NUMBER,
    px_src_trans_rec           IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_dest_trans_rec          IN OUT NOCOPY FA_API_TYPES.trans_rec_type) IS

   l_reporting_flag          varchar2(1);

   l_calling_fn              VARCHAR2(35) := 'fa_rsv_transfer_pub.do_rsv_transfer';
   rsv_xfr_err               EXCEPTION;

BEGIN

   SAVEPOINT do_reserve_transfer;

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise rsv_xfr_err;
      end if;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   if (fnd_api.to_boolean(p_init_msg_list)) then
        -- initialize error message stack.
        fa_srvr_msg.init_server_message;

        -- initialize debug message stack.
        fa_debug_pkg.initialize;
   end if;

   -- insure we reset this after cache call
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
      raise rsv_xfr_err;
   end if;

   -- call the cache for the primary transaction book
   if NOT fa_cache_pkg.fazcbc(X_book => p_book_type_code, p_log_level_rec => g_log_level_rec) then
      raise rsv_xfr_err;
   end if;

   -- verify the asset exists in the book already
   if not FA_ASSET_VAL_PVT.validate_asset_book
              (p_transaction_type_code      => 'ADJUSTMENT',
               p_book_type_code             => p_book_type_code,
               p_asset_id                   => p_src_asset_id,
               p_calling_fn                 => l_calling_fn
              , p_log_level_rec => g_log_level_rec) then
      raise rsv_xfr_err;
   end if;

   if not FA_ASSET_VAL_PVT.validate_asset_book
              (p_transaction_type_code      => 'ADJUSTMENT',
               p_book_type_code             => p_book_type_code,
               p_asset_id                   => p_dest_asset_id,
               p_calling_fn                 => l_calling_fn
              , p_log_level_rec => g_log_level_rec) then
      raise rsv_xfr_err;
   end if;

   -- Bug#7260056 Validate reserve transfer amount
   if not FA_ASSET_VAL_PVT.validate_reserve_transfer
              (p_book_type_code             => p_book_type_code,
               p_asset_id                   => p_src_asset_id,
               p_transfer_amount            => p_amount,
               p_calling_fn                 => l_calling_fn
               , p_log_level_rec => g_log_level_rec) then
      raise rsv_xfr_err;
   end if;

   -- Account for transaction submitted from a responsibility
   -- that is not tied to a SOB_ID by getting the value from
   -- the book struct

   -- Get the book type code P,R or N
   if not fa_cache_pkg.fazcsob
      (X_set_of_books_id   => fa_cache_pkg.fazcbc_record.set_of_books_id,
       X_mrc_sob_type_code => l_reporting_flag
      , p_log_level_rec => g_log_level_rec) then
      raise rsv_xfr_err;
   end if;

   --  Error out if the program is submitted from the Reporting Responsibility
   --  No transaction permitted directly on reporting books.

   IF l_reporting_flag = 'R' THEN
      fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name => 'MRC_OSP_INVALID_BOOK_TYPE', p_log_level_rec => g_log_level_rec);
      raise rsv_xfr_err;
   END IF;

   -- end initial MRC validation



   -- call the mrc wrapper for the transaction book

   if not do_all_books
      (p_src_asset_id       => p_src_asset_id,
       p_dest_asset_id      => p_dest_asset_id,
       p_book_type_code     => p_book_type_code,
       px_src_trans_rec     => px_src_trans_rec,
       px_dest_trans_rec    => px_dest_trans_rec,
       p_amount             => p_amount,
       p_log_level_rec      => g_log_level_rec
      )then
      raise rsv_xfr_err;
   end if;


   -- no auto-copy / cip in tax for group reclass transactions

   -- commit if p_commit is TRUE.
   if (fnd_api.to_boolean (p_commit)) then
        COMMIT WORK;
   end if;

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when rsv_xfr_err then
      ROLLBACK TO do_reserve_transfer;

      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      -- do not retrieve / clear messaging when this is being called
      -- from reclass api - allow calling util to dump them
      if (p_calling_fn <> 'FA_RECLASS_PVT.do_redefault') then
         FND_MSG_PUB.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data
         );
      end if;

      x_return_status :=  FND_API.G_RET_STS_ERROR;

   when others then
      ROLLBACK TO do_reserve_transfer;

      fa_srvr_msg.add_sql_error(
              calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      -- do not retrieve / clear messaging when this is being called
      -- from reclass api - allow calling util to dump them
      if (p_calling_fn <> 'FA_RECLASS_PVT.do_redefault') then
         FND_MSG_PUB.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data
         );
      end if;

      x_return_status :=  FND_API.G_RET_STS_ERROR;

END do_reserve_transfer;

-----------------------------------------------------------------------------

-- Books (MRC) Wrapper - called from public API above
--
-- For non mrc books, this just calls the private API with provided params
-- For MRC, it processes the primary and then loops through each reporting
-- book calling the private api for each.


FUNCTION do_all_books
   (p_src_asset_id             IN     NUMBER,
    p_dest_asset_id            IN     NUMBER,
    p_book_type_code           IN     VARCHAR2,
    px_src_trans_rec           IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_dest_trans_rec          IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    p_amount                   IN     NUMBER
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS


   -- used for new source asset
   l_src_asset_hdr_rec          fa_api_types.asset_hdr_rec_type;
   l_mrc_src_asset_hdr_rec      fa_api_types.asset_hdr_rec_type;
   l_src_asset_desc_rec         fa_api_types.asset_desc_rec_type;
   l_src_asset_type_rec         fa_api_types.asset_type_rec_type;
   l_src_asset_cat_rec          fa_api_types.asset_cat_rec_type;
   l_src_asset_fin_rec_old      fa_api_types.asset_fin_rec_type;
   l_src_asset_fin_rec_new      fa_api_types.asset_fin_rec_type;
   l_src_asset_deprn_rec_old    fa_api_types.asset_deprn_rec_type;
   l_src_asset_deprn_rec_new    fa_api_types.asset_deprn_rec_type;


   -- used for new destination asset
   l_dest_asset_hdr_rec         fa_api_types.asset_hdr_rec_type;
   l_mrc_dest_asset_hdr_rec     fa_api_types.asset_hdr_rec_type;
   l_dest_asset_desc_rec        fa_api_types.asset_desc_rec_type;
   l_dest_asset_type_rec        fa_api_types.asset_type_rec_type;
   l_dest_asset_cat_rec         fa_api_types.asset_cat_rec_type;
   l_dest_asset_fin_rec_old     fa_api_types.asset_fin_rec_type;
   l_dest_asset_fin_rec_new     fa_api_types.asset_fin_rec_type;
   l_dest_asset_deprn_rec_old   fa_api_types.asset_deprn_rec_type;
   l_dest_asset_deprn_rec_new   fa_api_types.asset_deprn_rec_type;

   l_src_row_id                 varchar2(30);
   l_dest_row_id                varchar2(30);
   l_src_return_status          boolean;
   l_dest_return_status         boolean;

   l_amount                     number;
   l_src_primary_cost           number;   -- ??? use ???

   l_period_rec                 FA_API_TYPES.period_rec_type;
   l_rsob_tbl                   FA_CACHE_PKG.fazcrsob_sob_tbl_type;
   l_reporting_flag             varchar2(1);

   l_exchange_rate              number;
   l_avg_rate                   number;

   l_rowid                      varchar2(40);
   l_return_status              boolean;

   l_calling_fn                 VARCHAR2(35) := 'fa_rsv_transfer_pub.do_all_books';
   rsv_xfr_err                  exception;

BEGIN

   -- load the initial values in structs
   l_src_asset_hdr_rec.asset_id            := p_src_asset_id;
   l_src_asset_hdr_rec.book_type_code      := p_book_type_code;
   l_src_asset_hdr_rec.set_of_books_id    := fa_cache_pkg.fazcbc_record.set_of_books_id;

   l_dest_asset_hdr_rec.asset_id           := p_dest_asset_id;
   l_dest_asset_hdr_rec.book_type_code     := p_book_type_code;
   l_dest_asset_hdr_rec.set_of_books_id    := fa_cache_pkg.fazcbc_record.set_of_books_id;

   px_src_trans_rec.transaction_type_code  := 'GROUP ADJUSTMENT';
   px_src_trans_rec.transaction_subtype    := 'AMORTIZED';
   px_src_trans_rec.transaction_key        := 'GV';
   px_dest_trans_rec.transaction_type_code := 'GROUP ADJUSTMENT';
   px_dest_trans_rec.transaction_subtype   := 'AMORTIZED';
   px_dest_trans_rec.transaction_key       := 'GV';

   -- load the period struct for current period info
   if not FA_UTIL_PVT.get_period_rec
          (p_book           => p_book_type_code,
           p_effective_date => NULL,
           x_period_rec     => l_period_rec
          , p_log_level_rec => p_log_level_rec) then
      raise rsv_xfr_err;
   end if;

   -- note that we need to investigate / determine transaction subtype and track member impacts!!!!
   -- how to handle amort start / trx_date , etc on the member in all three scenarios
   -- can this be effectively backdated?

   px_src_trans_rec.transaction_date_entered :=
      greatest(l_period_rec.calendar_period_open_date,
               least(sysdate,l_period_rec.calendar_period_close_date));

   px_dest_trans_rec.transaction_date_entered := px_src_trans_rec.transaction_date_entered ;


   -- we need the thid first for inserting clearing into adjustments
   select fa_transaction_headers_s.nextval
     into px_src_trans_rec.transaction_header_id
     from dual;

   select fa_transaction_headers_s.nextval
     into px_dest_trans_rec.transaction_header_id
     from dual;

   select fa_trx_references_s.nextval
     into px_src_trans_rec.trx_reference_id
     from dual;

   px_dest_trans_rec.trx_reference_id := px_src_trans_rec.trx_reference_id;

   if not fa_xla_events_pvt.create_dual_transaction_event
           (p_asset_hdr_rec_src      => l_src_asset_hdr_rec,
            p_asset_hdr_rec_dest     => l_dest_asset_hdr_rec,
            p_asset_type_rec_src     => l_src_asset_type_rec,
            p_asset_type_rec_dest    => l_dest_asset_type_rec,
            px_trans_rec_src         => px_src_trans_rec,
            px_trans_rec_dest        => px_dest_trans_rec,
            p_event_status           => NULL,
            p_calling_fn             => l_calling_fn,
            p_log_level_rec  => p_log_level_rec) then
      raise rsv_xfr_err;
   end if;

   -- insert the transaction link record (sequence will be used in table handler)

   fa_trx_references_pkg.insert_row
      (X_Rowid                          => l_rowid,
       X_Trx_Reference_Id               => px_src_trans_rec.trx_reference_id,
       X_Book_Type_Code                 => l_src_asset_hdr_rec.book_type_code,
       X_Src_Asset_Id                   => l_src_asset_hdr_rec.asset_id,
       X_Src_Transaction_Header_Id      => px_src_trans_rec.transaction_header_id,
       X_Dest_Asset_Id                  => l_dest_asset_hdr_rec.asset_id,
       X_Dest_Transaction_Header_Id     => px_dest_trans_rec.transaction_header_id,
       X_Member_Asset_Id                => null,
       X_Member_Transaction_Header_Id   => null,
       X_Transaction_Type               => 'RESERVE TRANSFER',
       X_Src_Transaction_Subtype        => px_src_trans_rec.transaction_subtype,
       X_Dest_Transaction_Subtype       => px_dest_trans_rec.transaction_subtype,
       X_Src_Amortization_Start_Date    => px_src_trans_rec.amortization_start_date,
       X_Dest_Amortization_Start_Date   => px_dest_trans_rec.amortization_start_date,
       X_Reserve_Transfer_Amount        => p_amount,
       X_Src_Expense_Amount             => null,
       X_Dest_Expense_Amount            => null,
       X_Src_Eofy_Reserve               => null,
       X_Dest_Eofy_Reserve              => null,
       X_event_id                       => px_src_trans_rec.event_id,
       X_Creation_Date                  => px_src_trans_rec.who_info.creation_date,
       X_Created_By                     => px_src_trans_rec.who_info.created_by,
       X_Last_Update_Date               => px_src_trans_rec.who_info.last_update_date,
       X_Last_Updated_By                => px_src_trans_rec.who_info.last_updated_by,
       X_Last_Update_Login              => px_src_trans_rec.who_info.last_update_login,
       X_Return_Status                  => l_return_status,
       X_Calling_Fn                     => l_calling_fn
      , p_log_level_rec => p_log_level_rec);


   -- Create transaction header rows
   fa_transaction_headers_pkg.insert_row
      (x_rowid                    => l_src_row_id,
       x_transaction_header_id    => px_src_trans_rec.transaction_header_id,
       x_book_type_code           => p_book_type_code,
       x_asset_id                 => p_src_asset_id,
       x_transaction_type_code    => 'GROUP ADJUSTMENT',
       x_transaction_date_entered => px_src_trans_rec.transaction_date_entered,
       x_date_effective           => px_src_trans_rec.who_info.last_update_date,
       x_last_update_date         => px_src_trans_rec.who_info.last_update_date,
       x_last_updated_by          => px_src_trans_rec.who_info.last_updated_by,
       x_transaction_name         => px_src_trans_rec.transaction_name,
       x_last_update_login        => px_src_trans_rec.who_info.last_update_login,
       x_transaction_key          => px_src_trans_rec.transaction_key,
       x_transaction_subtype      => px_dest_trans_rec.transaction_subtype,
       x_amortization_start_date  => px_src_trans_rec.amortization_start_date,
       x_calling_interface        => px_src_trans_rec.calling_interface,
       x_mass_transaction_id      => px_src_trans_rec.mass_transaction_id,
       x_trx_reference_id         => px_src_trans_rec.trx_reference_id,
       x_event_id                 => px_src_trans_rec.event_id,
       x_return_status            => l_src_return_status,
       x_calling_fn               => l_calling_fn, p_log_level_rec => p_log_level_rec);

   fa_transaction_headers_pkg.insert_row
      (x_rowid                    => l_dest_row_id,
       x_transaction_header_id    => px_dest_trans_rec.transaction_header_id,
       x_book_type_code           => p_book_type_code,
       x_asset_id                 => p_dest_asset_id,
       x_transaction_type_code    => 'GROUP ADJUSTMENT',
       x_transaction_date_entered => px_dest_trans_rec.transaction_date_entered,
       x_date_effective           => px_dest_trans_rec.who_info.last_update_date,
       x_last_update_date         => px_dest_trans_rec.who_info.last_update_date,
       x_last_updated_by          => px_dest_trans_rec.who_info.last_updated_by,
       x_transaction_name         => px_dest_trans_rec.transaction_name,
       x_last_update_login        => px_dest_trans_rec.who_info.last_update_login,
       x_transaction_key          => px_dest_trans_rec.transaction_key,
       x_transaction_subtype      => px_dest_trans_rec.transaction_subtype,
       x_amortization_start_date  => px_dest_trans_rec.amortization_start_date,
       x_calling_interface        => px_dest_trans_rec.calling_interface,
       x_mass_transaction_id      => px_dest_trans_rec.mass_transaction_id,
       x_trx_reference_id         => px_dest_trans_rec.trx_reference_id,
       x_event_id                 => px_dest_trans_rec.event_id,
       x_return_status            => l_dest_return_status,
       x_calling_fn               => l_calling_fn, p_log_level_rec => p_log_level_rec);


   -- load the period struct for current period info
   if not FA_UTIL_PVT.get_period_rec
          (p_book           => l_src_asset_hdr_rec.book_type_code,
           p_effective_date => NULL,
           x_period_rec     => l_period_rec
          , p_log_level_rec => p_log_level_rec) then
      raise rsv_xfr_err;
   end if;

   -- call transaction approval for source asset
   if not FA_TRX_APPROVAL_PKG.faxcat
          (X_book              => p_book_type_code,
           X_asset_id          => p_src_asset_id,
           X_trx_type          => px_src_trans_rec.transaction_type_code,
           X_trx_date          => px_src_trans_rec.transaction_date_entered,
           X_init_message_flag => 'NO'
          , p_log_level_rec => p_log_level_rec) then
      raise rsv_xfr_err;
   end if;


   -- call transaction approval for destination asset
   if not FA_TRX_APPROVAL_PKG.faxcat
          (X_book              => p_book_type_code,
           X_asset_id          => p_dest_asset_id,
           X_trx_type          => px_dest_trans_rec.transaction_type_code,
           X_trx_date          => px_dest_trans_rec.transaction_date_entered,
           X_init_message_flag => 'NO'
          , p_log_level_rec => p_log_level_rec) then
      raise rsv_xfr_err;
   end if;


   -- also check if this is the period of addition - use absolute mode for adjustments
   -- we will only clear cost outside period of addition
   if not FA_ASSET_VAL_PVT.validate_period_of_addition
             (p_asset_id            => l_src_asset_hdr_rec.asset_id,
              p_book                => l_src_asset_hdr_rec.book_type_code,
              p_mode                => 'ABSOLUTE',
              px_period_of_addition => l_src_asset_hdr_rec.period_of_addition, p_log_level_rec => p_log_level_rec) then
      raise rsv_xfr_err;
   end if;

   if not FA_ASSET_VAL_PVT.validate_period_of_addition
             (p_asset_id            => l_dest_asset_hdr_rec.asset_id,
              p_book                => l_dest_asset_hdr_rec.book_type_code,
              p_mode                => 'ABSOLUTE',
              px_period_of_addition => l_dest_asset_hdr_rec.period_of_addition, p_log_level_rec => p_log_level_rec) then
      raise rsv_xfr_err;
   end if;

   /*
    * BUG# 2795816: allowing this now
    * if (l_src_asset_hdr_rec.period_of_addition <>
    *   l_dest_asset_hdr_rec.period_of_addition) then
    *
    *   raise rsv_xfr_err;
    * end if;
    *
    */


   -- pop the structs for the non-fin information needed for trx
   -- source
   if not FA_UTIL_PVT.get_asset_desc_rec
          (p_asset_hdr_rec         => l_src_asset_hdr_rec,
           px_asset_desc_rec       => l_src_asset_desc_rec
          , p_log_level_rec => p_log_level_rec) then
      raise rsv_xfr_err;
   end if;

   if not FA_UTIL_PVT.get_asset_cat_rec
          (p_asset_hdr_rec         => l_src_asset_hdr_rec,
           px_asset_cat_rec        => l_src_asset_cat_rec,
           p_date_effective        => null
          , p_log_level_rec => p_log_level_rec) then
      raise rsv_xfr_err;
   end if;

   if not FA_UTIL_PVT.get_asset_type_rec
          (p_asset_hdr_rec         => l_src_asset_hdr_rec,
           px_asset_type_rec       => l_src_asset_type_rec,
           p_date_effective        => null
          , p_log_level_rec => p_log_level_rec) then
      raise rsv_xfr_err;
   end if;



   -- destination
   if not FA_UTIL_PVT.get_asset_desc_rec
          (p_asset_hdr_rec         => l_dest_asset_hdr_rec,
           px_asset_desc_rec       => l_dest_asset_desc_rec
          , p_log_level_rec => p_log_level_rec) then
      raise rsv_xfr_err;
   end if;

   if not FA_UTIL_PVT.get_asset_cat_rec
          (p_asset_hdr_rec         => l_dest_asset_hdr_rec,
           px_asset_cat_rec        => l_dest_asset_cat_rec,
           p_date_effective        => null
          , p_log_level_rec => p_log_level_rec) then
      raise rsv_xfr_err;
   end if;

   if not FA_UTIL_PVT.get_asset_type_rec
          (p_asset_hdr_rec         => l_dest_asset_hdr_rec,
           px_asset_type_rec       => l_dest_asset_type_rec,
           p_date_effective        => null
          , p_log_level_rec => p_log_level_rec) then
      raise rsv_xfr_err;
   end if;



   -- Call the reporting books cache to get rep books.
   if (NOT fa_cache_pkg.fazcrsob (
             x_book_type_code => l_src_asset_hdr_rec.book_type_code,
             x_sob_tbl        => l_rsob_tbl
           , p_log_level_rec => p_log_level_rec)) then
       raise rsv_xfr_err;
   end if;

   for l_mrc_index in 0..l_rsob_tbl.COUNT loop

      l_mrc_src_asset_hdr_rec  := l_src_asset_hdr_rec;
      l_mrc_dest_asset_hdr_rec := l_dest_asset_hdr_rec;

      if (l_mrc_index  = 0) then
         l_mrc_src_asset_hdr_rec.set_of_books_id  := fa_cache_pkg.fazcbc_record.set_of_books_id;
         l_mrc_dest_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;
         l_reporting_flag := 'P';
      else
         l_mrc_src_asset_hdr_rec.set_of_books_id  := l_rsob_tbl(l_mrc_index);
         l_mrc_dest_asset_hdr_rec.set_of_books_id := l_rsob_tbl(l_mrc_index);
         l_reporting_flag := 'R';
      end if;

      -- Need to always call fazcbcs
      if (NOT fa_cache_pkg.fazcbcs (
                X_book => l_mrc_src_asset_hdr_rec.book_type_code,
                X_set_of_books_id =>   l_mrc_src_asset_hdr_rec.set_of_books_id
         , p_log_level_rec => p_log_level_rec)) then
         raise rsv_xfr_err;
      end if;

      -- get the old fin and deprn information
      if not FA_UTIL_PVT.get_asset_fin_rec
              (p_asset_hdr_rec         => l_mrc_src_asset_hdr_rec,
               px_asset_fin_rec        => l_src_asset_fin_rec_old,
               p_transaction_header_id => NULL,
               p_mrc_sob_type_code     => l_reporting_flag
              , p_log_level_rec => p_log_level_rec) then raise rsv_xfr_err;
      end if;

      --HH validate disabled_flag for source
      if not FA_ASSET_VAL_PVT.validate_disabled_flag
                  (p_group_asset_id => l_mrc_src_asset_hdr_rec.asset_id,
                   p_book_type_code => l_mrc_src_asset_hdr_rec.book_type_code,
                   p_old_flag       => l_src_asset_fin_rec_old.disabled_flag,
                   p_new_flag       => l_src_asset_fin_rec_old.disabled_flag
                  , p_log_level_rec => p_log_level_rec) then
            raise rsv_xfr_err;
      end if;  --end HH

      if not FA_UTIL_PVT.get_asset_deprn_rec
              (p_asset_hdr_rec         => l_mrc_src_asset_hdr_rec ,
               px_asset_deprn_rec      => l_src_asset_deprn_rec_old,
               p_period_counter        => NULL,
               p_mrc_sob_type_code     => l_reporting_flag
              , p_log_level_rec => p_log_level_rec) then raise rsv_xfr_err;
      end if;


      -- in order to derive the transfer amount for the reporting
      -- books, we will use a ratio of the primary amount / primary cost
      -- for the source asset


      if (l_mrc_index = 0) then
         l_amount  := p_amount;
         l_src_primary_cost := l_src_asset_fin_rec_old.cost;

      else
         if (l_src_primary_cost <> 0) then
            l_amount := p_amount * (l_src_asset_fin_rec_old.cost / l_src_primary_cost);
         else
            -- get the latest average rate (used conditionally in some cases below)
            if not fa_mc_util_pvt.get_latest_rate
                   (p_asset_id            => l_mrc_src_asset_hdr_rec.asset_id,
                    p_book_type_code      => l_mrc_src_asset_hdr_rec.book_type_code,
                    p_set_of_books_id     => l_mrc_src_asset_hdr_rec.set_of_books_id,
                    px_rate               => l_exchange_rate,
                    px_avg_exchange_rate  => l_avg_rate
                   , p_log_level_rec => p_log_level_rec) then raise rsv_xfr_err;
            end if;
         end if;
      end if;



      -- now process the source and detination impacts

      ------------
      -- SOURCE --
      ------------

      if not FA_RESERVE_TRANSFER_PVT.do_adjustment
               (px_trans_rec              => px_src_trans_rec,
                px_asset_hdr_rec          => l_mrc_src_asset_hdr_rec,
                p_asset_desc_rec          => l_src_asset_desc_rec,
                p_asset_type_rec          => l_src_asset_type_rec,
                p_asset_cat_rec           => l_src_asset_cat_rec,
                p_asset_fin_rec_old       => l_src_asset_fin_rec_old,
                x_asset_fin_rec_new       => l_src_asset_fin_rec_new,
                p_asset_deprn_rec_old     => l_src_asset_deprn_rec_old,
                x_asset_deprn_rec_new     => l_src_asset_deprn_rec_new,
                p_period_rec              => l_period_rec,
                p_mrc_sob_type_code       => l_reporting_flag,
                p_source_dest             => 'S',
                p_amount                  => l_amount
               , p_log_level_rec => p_log_level_rec)then
         raise rsv_xfr_err;
      end if; -- do_adjustment



      -----------------
      -- DESTINATION --
      -----------------

      -- get the destination fin and deprn information
      if not FA_UTIL_PVT.get_asset_fin_rec
              (p_asset_hdr_rec         => l_mrc_dest_asset_hdr_rec,
               px_asset_fin_rec        => l_dest_asset_fin_rec_old,
               p_transaction_header_id => NULL,
               p_mrc_sob_type_code     => l_reporting_flag
              , p_log_level_rec => p_log_level_rec) then raise rsv_xfr_err;
      end if;

      --HH validate disabled_flag for dest.
      if not FA_ASSET_VAL_PVT.validate_disabled_flag
                  (p_group_asset_id => l_mrc_dest_asset_hdr_rec.asset_id,
                   p_book_type_code => l_mrc_dest_asset_hdr_rec.book_type_code,
                   p_old_flag       => l_dest_asset_fin_rec_old.disabled_flag,
                   p_new_flag       => l_dest_asset_fin_rec_old.disabled_flag
                  , p_log_level_rec => p_log_level_rec) then
            raise rsv_xfr_err;
      end if;  --end HH

      if not FA_UTIL_PVT.get_asset_deprn_rec
              (p_asset_hdr_rec         => l_mrc_dest_asset_hdr_rec ,
               px_asset_deprn_rec      => l_dest_asset_deprn_rec_old,
               p_period_counter        => NULL,
               p_mrc_sob_type_code     => l_reporting_flag
              , p_log_level_rec => p_log_level_rec) then raise rsv_xfr_err;
      end if;

      if not FA_RESERVE_TRANSFER_PVT.do_adjustment
               (px_trans_rec              => px_dest_trans_rec,
                px_asset_hdr_rec          => l_mrc_dest_asset_hdr_rec,
                p_asset_desc_rec          => l_dest_asset_desc_rec,
                p_asset_type_rec          => l_dest_asset_type_rec,
                p_asset_cat_rec           => l_dest_asset_cat_rec,
                p_asset_fin_rec_old       => l_dest_asset_fin_rec_old,
                x_asset_fin_rec_new       => l_dest_asset_fin_rec_new,
                p_asset_deprn_rec_old     => l_dest_asset_deprn_rec_old,
                x_asset_deprn_rec_new     => l_src_asset_deprn_rec_new,
                p_period_rec              => l_period_rec,
                p_mrc_sob_type_code       => l_reporting_flag,
                p_source_dest             => 'D',
                p_amount                  => l_amount
              , p_log_level_rec => p_log_level_rec)then
          raise rsv_xfr_err;
      end if; -- do_adjustment

      if (G_release = 11) then
         if not fa_interco_pvt.do_intercompany(
                p_src_trans_rec          => px_src_trans_rec,
                p_src_asset_hdr_rec      => l_mrc_src_asset_hdr_rec,
                p_dest_trans_rec         => px_dest_trans_rec,
                p_dest_asset_hdr_rec     => l_mrc_dest_asset_hdr_rec,
                p_calling_fn             => l_calling_fn,
                p_mrc_sob_type_code      => l_reporting_flag
              , p_log_level_rec => p_log_level_rec) then raise rsv_xfr_err;
         end if;
      end if;

   end loop;

   return true;

EXCEPTION

   WHEN RSV_XFR_ERR THEN
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;


end do_all_books;

END FA_RESERVE_TRANSFER_PUB;

/
