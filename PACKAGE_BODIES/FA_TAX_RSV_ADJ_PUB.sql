--------------------------------------------------------
--  DDL for Package Body FA_TAX_RSV_ADJ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_TAX_RSV_ADJ_PUB" as
/* $Header: FAPTRSVB.pls 120.8.12010000.2 2009/07/19 09:51:21 glchen ship $   */

--*********************** Global constants ******************************--

G_PKG_NAME      CONSTANT   varchar2(30) := 'FA_TAX_RSV_ADJ_PUB';
G_API_NAME      CONSTANT   varchar2(30) := 'Tax Reserve Adjustment API';
G_API_VERSION   CONSTANT   number       := 1.0;

--*********************** Private functions ******************************--

-- private declaration for books (mrc) wrapper

g_log_level_rec            fa_api_types.log_level_rec_type;
g_cip_cost    number  := 0;
g_cost        number  := 0;

FUNCTION do_all_books
   (px_trans_rec            IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec        IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec        IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec        IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec         IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_tax_rsv_adj_rec IN     FA_API_TYPES.asset_tax_rsv_adj_rec_type,
    p_calling_fn            IN     VARCHAR2
   ,p_log_level_rec           IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN;


FUNCTION is_amortized
	(p_asset_id	    IN  fa_books.asset_id%type,
	 p_book		    IN  fa_book_controls.book_type_code%type,
	 p_period_counter   IN  number,
	 x_is_amortized	    OUT NOCOPY boolean
	,p_log_level_rec           IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN;


--*********************** Public procedures *****************************--

PROCEDURE do_tax_rsv_adj
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
    p_asset_tax_rsv_adj_rec    IN     FA_API_TYPES.asset_tax_rsv_adj_rec_type)
IS

   l_asset_type_rec         FA_API_TYPES.asset_type_rec_type;
   l_asset_desc_rec         FA_API_TYPES.asset_desc_rec_type;
   l_asset_cat_rec          FA_API_TYPES.asset_cat_rec_type;
   l_asset_tax_rsv_adj_rec  FA_API_TYPES.asset_tax_rsv_adj_rec_type;

   x_is_amortized           Boolean;
   l_fully_rsv              Boolean;

   l_reporting_flag         varchar2(1);
   l_count                   number;

   l_calling_fn             VARCHAR2(35) := 'fa_tax_rsv_adj_pub.do_tax_rsv_adj';
   tax_rsv_adj_err          EXCEPTION;


-- fin_info   fa_std_types.fin_info_struct;

BEGIN

   SAVEPOINT do_tax_rsv_adj;
   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise tax_rsv_adj_err;
      end if;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.

--   if (fnd_api.to_boolean(p_init_msg_list)) then

       -- initialize error message stack.
       fa_srvr_msg.init_server_message;

       -- initialize debug message stack.
       fa_debug_pkg.initialize;
--   end if;

   -- Check version of the API
   -- Standard call to check for API call compatibility.

   if NOT fnd_api.compatible_api_call (
          G_API_VERSION,
          p_api_version,
          G_API_NAME,
          G_PKG_NAME) then
      x_return_status := FND_API.G_RET_STS_ERROR;
      raise tax_rsv_adj_err;
   end if;

   -- call the cache for the primary transaction book

   if NOT fa_cache_pkg.fazcbc(X_book => px_asset_hdr_rec.book_type_code,
                              p_log_level_rec => g_log_level_rec) then
    	raise tax_rsv_adj_err;
   end if;

   px_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

   -- verify the asset exist in the book already

   if not FA_ASSET_VAL_PVT.validate_asset_book
         (p_transaction_type_code      => 'ADJUSTMENT',
          p_book_type_code             => px_asset_hdr_rec.book_type_code,
          p_asset_id                   => px_asset_hdr_rec.asset_id,
          p_calling_fn                 => l_calling_fn,
          p_log_level_rec              => g_log_level_rec) then
      raise tax_rsv_adj_err;
   end if;

   -- Account for transaction submitted from a responsibility
   -- that is not tied to a SOB_ID by getting the value from
   -- the book struct

   -- Get the book type code P,R or N

   if not fa_cache_pkg.fazcsob
         (X_set_of_books_id   => px_asset_hdr_rec.set_of_books_id,
          X_mrc_sob_type_code => l_reporting_flag,
          p_log_level_rec     => g_log_level_rec) then
      raise tax_rsv_adj_err;
   end if;

   --  Error out if the program is submitted from the Reporting Responsibility
   --  No transaction permitted directly on reporting books.

   if l_reporting_flag = 'R' then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn,name => 'MRC_OSP_INVALID_BOOK_TYPE',
                              p_log_level_rec => g_log_level_rec);
      raise tax_rsv_adj_err;
   end if;

   -- end initial MRC validation


   -- load cache fazcbc.

   if not fa_cache_pkg.fazcbc(X_book => px_asset_hdr_rec.book_type_code,
                              p_log_level_rec => g_log_level_rec) then
      raise tax_rsv_adj_err;
   end if;
   if fa_cache_pkg.fazcbc_record.allow_deprn_adjustments = 'NO' then
      -- Bug 5472772 Added fa_srvr_msg call
      fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name       => 'FA_ADJ_RSV_ADJ_NOT_ALLOWED'
           ,p_log_level_rec => g_log_level_rec);
      raise tax_rsv_adj_err;
   end if;

   --  pop the structs for the non-fin information needed for trx

   if not FA_UTIL_PVT.get_asset_type_rec
          (p_asset_hdr_rec         => px_asset_hdr_rec,
           px_asset_type_rec       => l_asset_type_rec,
           p_date_effective        => null,
           p_log_level_rec         => g_log_level_rec) then
      raise tax_rsv_adj_err;
   end if;

   if not FA_UTIL_PVT.get_asset_desc_rec
          (p_asset_hdr_rec         => px_asset_hdr_rec,
           px_asset_desc_rec       => l_asset_desc_rec,
           p_log_level_rec         => g_log_level_rec) then
      raise tax_rsv_adj_err;
   end if;

   if not FA_UTIL_PVT.get_asset_cat_rec
         (p_asset_hdr_rec         => px_asset_hdr_rec,
          px_asset_cat_rec        => l_asset_cat_rec,
          p_date_effective        => null,
          p_log_level_rec         => g_log_level_rec) then
      raise tax_rsv_adj_err;
   end if;

   -- end of pop structs

   -- Allow if Tax Book

   if not fa_cache_pkg.fazcbc_record.book_class = 'TAX' then
      -- Bug 5472772 Added fa_srvr_msg call
      fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name       => 'FA_ADJ_TAX_BOOK'
           ,p_log_level_rec => g_log_level_rec);
      raise tax_rsv_adj_err;
   end if;

   -- Check if Group Asset if 'Yes' raise error.

   if l_asset_type_rec.asset_type = 'GROUP' then
      -- Bug 5472772 Added fa_srvr_msg call
      fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name       => 'FA_PROD_ASSET_NOT_CAPITALIZED'
           ,p_log_level_rec => g_log_level_rec);
      raise tax_rsv_adj_err;
   end if;


   -- CIP assets should not have reserve adjustments

   if l_asset_type_rec.asset_type = 'CIP' then
      -- Bug 5472772 Added fa_srvr_msg call
      fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name       => 'FA_TAX_ASSET_IS_CIP'
           ,p_log_level_rec => g_log_level_rec);
      raise tax_rsv_adj_err;
   end if;

   -- Check for Tax book, Allow Deprn Adjustment is allowed.

   if fa_cache_pkg.fazcbc_record.allow_deprn_adjustments = 'NO' then
      -- Bug 5472772 Added fa_srvr_msg call
      fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name       => 'FA_ADJ_RSV_ADJ_NOT_ALLOWED'
           ,p_log_level_rec => g_log_level_rec);
      raise tax_rsv_adj_err;
   end if;

   l_asset_tax_rsv_adj_rec := p_asset_tax_rsv_adj_rec;


   -- Find the first period adjusted
   SELECT MAX(DP.PERIOD_COUNTER),
          MIN(DP.PERIOD_COUNTER)
   INTO   l_asset_tax_rsv_adj_rec.max_period_ctr_adjusted,
          l_asset_tax_rsv_adj_rec.min_period_ctr_adjusted
   FROM   FA_DEPRN_PERIODS DP
   WHERE  DP.BOOK_TYPE_CODE = px_asset_hdr_rec.book_type_code
   AND    DP.FISCAL_YEAR = l_asset_tax_rsv_adj_rec.fiscal_year;


   /*  Check if amortized transaction was done between the
    *  period adjusted and the current open period, if so
    *  return error */

   If not is_amortized( px_asset_hdr_rec.asset_id
                   ,px_asset_hdr_rec.book_type_code
                   ,l_asset_tax_rsv_adj_rec.max_period_ctr_adjusted
                   ,x_is_amortized
                   ,p_log_level_rec => g_log_level_rec) then
      -- Bug 5472772 Added fa_srvr_msg call
      fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name       => 'FA_ADJ_RSV_ADJ_NOT_ALLOWED'
           ,p_log_level_rec => g_log_level_rec);
      raise tax_rsv_adj_err;
   end if;



   -- check if impairment has been in the current fiscal year. if so error
   SELECT count(*)
   into   l_count
   from   fa_transaction_headers th,
          fa_deprn_periods dp,
          fa_book_controls bc
   where  th.asset_id = px_asset_hdr_rec.asset_id
   and    th.book_type_code = px_asset_hdr_rec.book_type_code
   and    th.transaction_key = 'IM'
   and    th.date_effective > dp.period_open_date
   and    dp.book_type_code = th.book_type_code
   and    dp.period_num = 1
   and    bc.book_type_code = th.book_type_code
   and    bc.current_fiscal_year = dp.fiscal_year
   and    bc.book_type_code = dp.book_type_code;

   if l_count <> 0 then
      fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name       => 'FA_SHARED_OTHER_TRX_FOLLOW'
           ,p_log_level_rec => g_log_level_rec);
      raise tax_rsv_adj_err;
   end if;


   -- also check if this is the period of addition - use absolute mode for adjustments
   -- we will only clear cost outside period of addition
   if not FA_ASSET_VAL_PVT.validate_period_of_addition
         (p_asset_id            => px_asset_hdr_rec.asset_id,
          p_book                => px_asset_hdr_rec.book_type_code,
          p_mode                => 'ABSOLUTE',
          px_period_of_addition => px_asset_hdr_rec.period_of_addition,
          p_log_level_rec       => g_log_level_rec) then
      raise tax_rsv_adj_err;
   end if;

   px_trans_rec.transaction_type_code := 'TAX';

   -- Call do_all_books;
   -- call the mrc wrapper for the transaction book

   if not do_all_books
         (px_trans_rec                => px_trans_rec,
          px_asset_hdr_rec            => px_asset_hdr_rec ,
          p_asset_desc_rec            => l_asset_desc_rec ,
          p_asset_type_rec            => l_asset_type_rec ,
          p_asset_cat_rec             => l_asset_cat_rec ,
          p_asset_tax_rsv_adj_rec     => l_asset_tax_rsv_adj_rec,
          p_calling_fn                => l_calling_fn,
          p_log_level_rec             => g_log_level_rec)then
      raise tax_rsv_adj_err;
   end if;


   -- commit if p_commit is TRUE.
   if (fnd_api.to_boolean (p_commit)) then
        COMMIT WORK;
   end if;

   -- Bug 5472772
   -- Standard call to get message count and if count is 1 get message info.
   fnd_msg_pub.count_and_get (
      p_count   => x_msg_count,
      p_data    => x_msg_data
   );

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when tax_rsv_adj_err then

      ROLLBACK TO do_tax_rsv_adj;

      fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                              p_log_level_rec => g_log_level_rec);

      -- Bug 5472772
      -- Standard call to get message count and if count is 1 get message info.
      FND_MSG_PUB.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

      x_return_status :=  FND_API.G_RET_STS_ERROR;

   when others then
      ROLLBACK TO do_tax_rsv_adj;

      fa_srvr_msg.add_sql_error(
              calling_fn => l_calling_fn,
              p_log_level_rec => g_log_level_rec);

      -- Bug 5472772
      -- Standard call to get message count and if count is 1 get message info.
      FND_MSG_PUB.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

      x_return_status :=  FND_API.G_RET_STS_ERROR;


END do_tax_rsv_adj;

FUNCTION is_amortized
   ( p_asset_id		IN         fa_books.asset_id%type
    ,p_book		IN         fa_book_controls.book_type_code%type
    ,p_period_counter   IN         number
    ,x_is_amortized	OUT NOCOPY boolean
    ,p_log_level_rec    IN         FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN is

   Cursor c_amort is
   SELECT 1
   FROM  FA_TRANSACTION_HEADERS TH, FA_DEPRN_PERIODS DP
   WHERE TH.ASSET_ID = p_asset_id
   AND   TH.BOOK_TYPE_CODE = p_book
   AND   TH.TRANSACTION_SUBTYPE = 'AMORTIZED'
   AND   DP.PERIOD_COUNTER = p_period_counter
   AND   DP.BOOK_TYPE_CODE = p_book
   AND   DP.PERIOD_CLOSE_DATE < TH.DATE_EFFECTIVE;


   l_temp number := 0;

BEGIN
 open c_amort;
 fetch c_amort into l_temp;
 close c_amort;
if l_temp = 1 then
	X_is_amortized := TRUE;
else
	X_is_amortized := FALSE;
end if;
return (TRUE);

EXCEPTION
   when no_data_found then
        X_is_amortized := FALSE;
	  return (TRUE);

   when others then
   	  fa_srvr_msg.add_sql_error (calling_fn => 'fa_txrsv_pkg.fautca',
   	     	                     p_log_level_rec => p_log_level_rec);
	  return (FALSE);

END is_amortized;

-----------------------------------------------------------------------------

-- Books (MRC) Wrapper - called from public API above
--
-- For non mrc books, this just calls the private API with provided params
-- For MRC, it processes the primary and then loops through each reporting
-- book calling the private api for each.

FUNCTION do_all_books
   (px_trans_rec            IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec        IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec        IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec        IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec         IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_tax_rsv_adj_rec IN     FA_API_TYPES.asset_tax_rsv_adj_rec_type,
    p_calling_fn            IN     VARCHAR2,
    p_log_level_rec           IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN IS

   l_asset_hdr_rec_mrc      FA_API_TYPES.asset_hdr_rec_type;
   l_asset_fin_rec          FA_API_TYPES.asset_fin_rec_type;
   l_period_rec             FA_API_TYPES.period_rec_type;

   l_transaction_date       date;
   l_fully_rsv              boolean;
   l_sob_tbl                FA_CACHE_PKG.fazcrsob_sob_tbl_type;

   l_reporting_flag         varchar2(1);
   l_exchange_rate          number;
   l_avg_rate               number;

   l_calling_fn             varchar2(35) := 'fa_tax_rsv_adj_pub.do_all_books';
   tax_rsv_adj_err          EXCEPTION;

BEGIN

/* Bug 4597471 -- only for 'RUN' mode */
    if (p_asset_tax_rsv_adj_rec.run_mode = 'RUN') then
       if not FA_TRX_APPROVAL_PKG.faxcat
             (X_book              => px_asset_hdr_rec.book_type_code,
              X_asset_id          => px_asset_hdr_rec.asset_id,
              X_trx_type          => px_trans_rec.transaction_type_code,
              X_trx_date          => px_trans_rec.transaction_date_entered,
              X_init_message_flag => 'NO',
              p_log_level_rec     => p_log_level_rec) then
          raise tax_rsv_adj_err;
       end if;
    end if;


   -- load the period struct for current period info

   if not FA_UTIL_PVT.get_period_rec
          (p_book           => px_asset_hdr_rec.book_type_code,
           p_effective_date => NULL,
           x_period_rec     => l_period_rec,
           p_log_level_rec  => p_log_level_rec) then
      raise tax_rsv_adj_err;
   end if;

   -- load the struct asset_fin_rec.

   if not FA_UTIL_PVT.get_asset_fin_rec
         (p_asset_hdr_rec         => px_asset_hdr_rec,
          px_asset_fin_rec        => l_asset_fin_rec,
          p_transaction_header_id => NULL,
          p_mrc_sob_type_code     => l_reporting_flag,
          p_log_level_rec         => p_log_level_rec) then
      raise tax_rsv_adj_err;
   end if;

   -- verify asset is not fully retired
   if fa_asset_val_pvt.validate_fully_retired
          (p_asset_id          => px_asset_hdr_rec.asset_id,
           p_book              => px_asset_hdr_rec.book_type_code,
           p_log_level_rec     => p_log_level_rec) then
      fa_srvr_msg.add_message
          (name      => 'FA_REC_RETIRED',
           calling_fn => l_calling_fn,
           p_log_level_rec => p_log_level_rec);
      raise tax_rsv_adj_err;
   end if;

   -- call the sob cache to get the table of sob_ids

        if not FA_CACHE_PKG.fazcrsob
             (x_book_type_code => px_asset_hdr_rec.book_type_code,
              x_sob_tbl        => l_sob_tbl,
              p_log_level_rec  => p_log_level_rec) then
           raise tax_rsv_adj_err;
        end if;

        -- MVK : Other validation is for the POLISH .


        -- set up the local asset_header and sob_id for mrc.

        l_asset_hdr_rec_mrc := px_asset_hdr_rec;

     /* Bug 4597471 -- only for RUN mode we need to call the reporting books
        for preview mode we need only the primary (else part) */

     if ( p_asset_tax_rsv_adj_rec.run_mode = 'RUN') then

        -- loop through each book starting with the primary and
        -- call the private API for each

        FOR l_sob_index in 0..l_sob_tbl.count LOOP
           if (l_sob_index = 0) then
             l_reporting_flag := 'P';
             l_transaction_date := greatest(l_period_rec.calendar_period_open_date,
                                          least(sysdate,l_period_rec.calendar_period_close_date));
             px_trans_rec.transaction_date_entered :=
                to_date(to_char(l_transaction_date, 'DD/MM/YYYY'),'DD/MM/YYYY');

             l_exchange_rate := 1;
             l_avg_rate      := 1;

          else
            l_reporting_flag := 'R';
            l_asset_hdr_rec_mrc.set_of_books_id := l_sob_tbl(l_sob_index);
          end if;

	 -- Call the private api ... FA_TAX_RSV_ADJ_PVT.do_tax_rsv_adj;

          /* Bug 4597471 -- changed the signature of FA_TAX_RSV_ADJ_PVT.do_tax_rsv_adj to include the the reporting flag */

          if not FA_TAX_RSV_ADJ_PVT.do_tax_rsv_adj
             (px_trans_rec            => px_trans_rec,
              px_asset_hdr_rec        => l_asset_hdr_rec_mrc,
              p_asset_desc_rec        => p_asset_desc_rec,
              p_asset_type_rec        => p_asset_type_rec,
              p_asset_cat_rec         => p_asset_cat_rec,
              px_asset_fin_rec        => l_asset_fin_rec,
              p_asset_tax_rsv_adj_rec => p_asset_tax_rsv_adj_rec,
              p_mrc_sob_type_code     => l_reporting_flag,
              p_calling_fn            => l_calling_fn,
              p_log_level_rec         => p_log_level_rec) then
                  raise tax_rsv_adj_err;
           end if;

        End Loop;
     else
          /* Bug 4597471 -- only Primary book in the case of PREVIEW mode */

          l_reporting_flag := 'P';
          l_transaction_date := greatest(l_period_rec.calendar_period_open_date,
                                          least(sysdate,l_period_rec.calendar_period_close_date));
          px_trans_rec.transaction_date_entered :=
                to_date(to_char(l_transaction_date, 'DD/MM/YYYY'),'DD/MM/YYYY');

          if not FA_TAX_RSV_ADJ_PVT.do_tax_rsv_adj
             (px_trans_rec            => px_trans_rec,
              px_asset_hdr_rec        => l_asset_hdr_rec_mrc,
              p_asset_desc_rec        => p_asset_desc_rec,
              p_asset_type_rec        => p_asset_type_rec,
              p_asset_cat_rec         => p_asset_cat_rec,
              px_asset_fin_rec        => l_asset_fin_rec,
              p_asset_tax_rsv_adj_rec => p_asset_tax_rsv_adj_rec,
              p_mrc_sob_type_code     => l_reporting_flag,
              p_calling_fn            => l_calling_fn,
              p_log_level_rec         => p_log_level_rec) then
                  raise tax_rsv_adj_err;
           end if;
     end if; --- RUN mode checking

return (TRUE);
EXCEPTION

   WHEN TAX_RSV_ADJ_ERR THEN
      fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                              p_log_level_rec => p_log_level_rec);
      return FALSE;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn,
                                p_log_level_rec => p_log_level_rec);
      return FALSE;

End do_all_books;

-----------------------------------------------------------------------------

END FA_TAX_RSV_ADJ_PUB;

/
