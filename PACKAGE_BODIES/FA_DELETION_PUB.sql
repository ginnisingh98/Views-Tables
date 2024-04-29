--------------------------------------------------------
--  DDL for Package Body FA_DELETION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_DELETION_PUB" as
/* $Header: FAPDELB.pls 120.8.12010000.6 2010/04/15 11:09:48 bmaddine ship $   */

--*********************** Global constants ******************************--

G_PKG_NAME      CONSTANT   varchar2(30) := 'FA_DELETION_PUB';
G_API_NAME      CONSTANT   varchar2(30) := 'Deletion API';
G_API_VERSION   CONSTANT   number       := 1.0;

g_log_level_rec fa_api_types.log_level_rec_type;

--*********************** Private functions ******************************--

-- private declaration for books (mrc) wrapper

FUNCTION do_all_books
   (px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec           IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec           IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec            IN     FA_API_TYPES.asset_cat_rec_type,
    p_validation_level         IN     NUMBER,
    p_log_level_rec            IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION delete_asset_events
        (px_asset_hdr_rec      IN     FA_API_TYPES.asset_hdr_rec_type
        ,p_asset_type_rec      IN     fa_api_types.asset_type_rec_type
        ,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null) RETURN BOOLEAN;

--*********************** Public procedures ******************************--

PROCEDURE do_delete
   (p_api_version              IN     NUMBER,
    p_init_msg_list            IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                   IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level         IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_calling_fn               IN     VARCHAR2,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2,

    px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type) IS

   CURSOR c_tax_books IS
    select distinct book_type_code
      from fa_books
     where asset_id = px_asset_hdr_rec.asset_id
   /*code fix for bug no.3768406.Changed the field from date_effective to date_ineffective*/
       and date_ineffective is null;

   l_reporting_flag          varchar2(1);
   l_inv_count               number := 0;
   l_rate_count              number := 0;
   l_deprn_count             number := 0;
   l_count                   number := 0;

   l_asset_desc_rec          FA_API_TYPES.asset_desc_rec_type;
   l_asset_type_rec          FA_API_TYPES.asset_type_rec_type;
   l_asset_cat_rec           FA_API_TYPES.asset_cat_rec_type;

   -- used for tax book loop
   l_asset_hdr_rec           FA_API_TYPES.asset_hdr_rec_type;
   l_tax_book_tbl            FA_CACHE_PKG.fazctbk_tbl_type;
   l_tax_index               NUMBER;  -- index for tax loop

   l_calling_fn              VARCHAR2(35) := 'fa_deletion_pub.do_delete';
   del_err                   EXCEPTION;


BEGIN

   SAVEPOINT do_delete;

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise del_err;
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
      raise del_err;
   end if;

   -- check to see if the asset is populated
   if (px_asset_hdr_rec.asset_id is null) then
      raise del_err;
   end if;


   -- check to see if the book is populated
   -- if not assume corporate
   if (px_asset_hdr_rec.book_type_code is null) then

      select bk.book_type_code
        into px_asset_hdr_rec.book_type_code
        from fa_books bk,
             fa_book_controls bc
       where bk.asset_id = px_asset_hdr_rec.asset_id
         and bk.date_ineffective is null
         and bk.book_type_code = bc.book_type_code
         and bc.book_class = 'CORPORATE';

   end if;


   -- call the cache for the primary transaction book
   if NOT fa_cache_pkg.fazcbc(X_book => px_asset_hdr_rec.book_type_code, p_log_level_rec => g_log_level_rec) then
      raise del_err;
   end if;

   px_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

   -- verify the asset exist in the book already
   if not FA_ASSET_VAL_PVT.validate_asset_book
              (p_transaction_type_code      => 'ADJUSTMENT',
               p_book_type_code             => px_asset_hdr_rec.book_type_code,
               p_asset_id                   => px_asset_hdr_rec.asset_id,
               p_calling_fn                 => l_calling_fn
              , p_log_level_rec => g_log_level_rec) then
      raise del_err;
   end if;

   -- Account for transaction submitted from a responsibility
   -- that is not tied to a SOB_ID by getting the value from
   -- the book struct

   -- Get the book type code P,R or N
   if not fa_cache_pkg.fazcsob
      (X_set_of_books_id   => px_asset_hdr_rec.set_of_books_id,
       X_mrc_sob_type_code => l_reporting_flag
      , p_log_level_rec => g_log_level_rec) then
      raise del_err;
   end if;

   --  Error out if the program is submitted from the Reporting Responsibility
   --  No transaction permitted directly on reporting books.

   IF l_reporting_flag = 'R' THEN
      fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name => 'MRC_OSP_INVALID_BOOK_TYPE', p_log_level_rec => g_log_level_rec);
      raise del_err;
   END IF;

   -- end initial MRC validation

   -- pop the structs for the non-fin information needed for trx
   if not FA_UTIL_PVT.get_asset_desc_rec
          (p_asset_hdr_rec         => px_asset_hdr_rec,
           px_asset_desc_rec       => l_asset_desc_rec
          , p_log_level_rec => g_log_level_rec) then
      raise del_err;
   end if;

   if not FA_UTIL_PVT.get_asset_type_rec
          (p_asset_hdr_rec         => px_asset_hdr_rec,
           px_asset_type_rec       => l_asset_type_rec,
           p_date_effective        => null
          , p_log_level_rec => g_log_level_rec) then
      raise del_err;
   end if;

   if not FA_UTIL_PVT.get_asset_cat_rec
          (p_asset_hdr_rec         => px_asset_hdr_rec,
           px_asset_cat_rec        => l_asset_cat_rec,
           p_date_effective        => null
          , p_log_level_rec => g_log_level_rec) then
      raise del_err;
   end if;


   -- cache the category info
   if not fa_cache_pkg.fazcat(X_cat_id => l_asset_cat_rec.category_id, p_log_level_rec => g_log_level_rec)  then
      raise del_err;
   end if;


   -- call the mrc wrapper for the transaction book
   if not do_all_books
      (px_asset_hdr_rec           => px_asset_hdr_rec,
       p_asset_type_rec           => l_asset_type_rec,
       p_asset_desc_rec           => l_asset_desc_rec,
       p_asset_cat_rec            => l_asset_cat_rec,
       p_validation_level         => p_validation_level,
       p_log_level_rec            => g_log_level_rec
       )then
      raise del_err;
   end if;

   if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then

      -- note: don't want to use fazctbk cache here
      --       because the asset may exist in ineffective books

      for l_tax_rec in c_tax_books loop

         l_asset_hdr_rec                   := px_asset_hdr_rec;
         l_asset_hdr_rec.book_type_code    := l_tax_rec.book_type_code;

         -- cache the book information for the tax book
         if (NOT fa_cache_pkg.fazcbc(X_book => l_tax_rec.book_type_code, p_log_level_rec => g_log_level_rec)) then
            raise del_err;
         end if;

         if not do_all_books
            (px_asset_hdr_rec           => l_asset_hdr_rec ,         -- tax
             p_asset_type_rec           => l_asset_type_rec,
             p_asset_desc_rec           => l_asset_desc_rec,
             p_asset_cat_rec            => l_asset_cat_rec,
             p_validation_level         => p_validation_level,
             p_log_level_rec            => g_log_level_rec
            ) then
            raise del_err;
         end if;

      end loop; -- tax books

   end if; -- corporate book

   -- commit if p_commit is TRUE.
   if (fnd_api.to_boolean (p_commit)) then
        COMMIT WORK;
   end if;

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when del_err then
      ROLLBACK TO do_delete;

      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      -- do not retrieve / clear messaging when this is being called
      -- from reclass api - allow calling util to dump them
      FND_MSG_PUB.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data
         );
      x_return_status :=  FND_API.G_RET_STS_ERROR;

   when others then
      ROLLBACK TO do_delete;

      fa_srvr_msg.add_sql_error(
              calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      -- do not retrieve / clear messaging when this is being called
      -- from reclass api - allow calling util to dump them
      FND_MSG_PUB.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data
         );

      x_return_status :=  FND_API.G_RET_STS_ERROR;

END do_delete;

-----------------------------------------------------------------------------

-- Books (MRC) Wrapper - called from public API above
--
-- For non mrc books, this just calls the private API with provided params
-- For MRC, it processes the primary and then loops through each reporting
-- book calling the private api for each.


FUNCTION do_all_books
   (px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec           IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec           IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec            IN     FA_API_TYPES.asset_cat_rec_type,
    p_validation_level         IN     NUMBER
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   -- used for calling private api for reporting books
   l_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;

   l_period_rec               FA_API_TYPES.period_rec_type;
   l_sob_tbl                  FA_CACHE_PKG.fazcrsob_sob_tbl_type;

   -- used for local runs
   l_responsibility_id       number;
   l_application_id          number;

   l_rowid                   varchar2(120);

   l_calling_fn              varchar2(30) := 'fa_delete_pub.do_all_books';
   del_err                   EXCEPTION;

   -- Added as a result of High Cost SQL drill bugfix 3116047 msiddiqu
   Cursor C1 is
   SELECT INVOICE_TRANSACTION_ID_IN,
          INVOICE_TRANSACTION_ID_OUT
   FROM FA_ASSET_INVOICES
   WHERE ASSET_ID = px_asset_hdr_rec.asset_id;

BEGIN

   -- only call transaction approval
   -- BUG# 2247404 and 2230178 - call regardless if from a mass request
   if not FA_TRX_APPROVAL_PKG.faxcat
          (X_book              => px_asset_hdr_rec.book_type_code,
           X_asset_id          => px_asset_hdr_rec.asset_id,
           X_trx_type          => 'DELETE',
           X_trx_date          => sysdate,
           X_init_message_flag => 'NO'
          , p_log_level_rec => p_log_level_rec) then
      raise del_err;
   end if;

   -- check if this is the period of addition - use absolute mode for adjustments
   if not FA_ASSET_VAL_PVT.validate_period_of_addition
             (p_asset_id            => px_asset_hdr_rec.asset_id,
              p_book                => px_asset_hdr_rec.book_type_code,
              p_mode                => 'ABSOLUTE',
              px_period_of_addition => px_asset_hdr_rec.period_of_addition, p_log_level_rec => p_log_level_rec) then
      raise del_err;
   end if;

   -- load the period struct for current period info
   if not FA_UTIL_PVT.get_period_rec
          (p_book           => px_asset_hdr_rec.book_type_code,
           p_effective_date => NULL,
           x_period_rec     => l_period_rec
          , p_log_level_rec => p_log_level_rec) then
      raise del_err;
   end if;

   -- handle needed validation
   -- bypass if validation level <> FULL

   if (p_validation_level = FND_API.G_VALID_LEVEL_FULL) then
      if not fa_deletion_pvt.do_validation
             (px_asset_hdr_rec           => px_asset_hdr_rec,
              p_asset_type_rec           => p_asset_type_rec,
              p_asset_desc_rec           => p_asset_desc_rec,
              p_asset_cat_rec            => p_asset_cat_rec, p_log_level_rec => p_log_level_rec) then
         raise del_err;
      end if;
   end if;

   --Delete associated events
   if not delete_asset_events (px_asset_hdr_rec
                              ,p_asset_type_rec
                              ,p_log_level_rec) then
      raise del_err;
   end if;

   DELETE FROM FA_ADJUSTMENTS
          WHERE Asset_Id          = px_asset_hdr_rec.asset_id
          AND book_Type_Code    = px_asset_hdr_rec.book_type_code;

   DELETE FROM FA_BOOKS
          WHERE Asset_Id          = px_asset_hdr_rec.asset_id
          AND book_Type_Code    = px_asset_hdr_rec.book_type_code;

   DELETE FROM FA_DEPRN_DETAIL
          WHERE Asset_Id          = px_asset_hdr_rec.asset_id
          AND book_Type_Code    = px_asset_hdr_rec.book_type_code;

   DELETE FROM FA_DEPRN_SUMMARY
          WHERE Asset_Id          = px_asset_hdr_rec.asset_id
          AND book_Type_Code    = px_asset_hdr_rec.book_type_code;

   DELETE FROM FA_RETIREMENTS
          WHERE Asset_Id          = px_asset_hdr_rec.asset_id
          AND book_Type_Code    = px_asset_hdr_rec.book_type_code;

   DELETE FROM FA_TRANSACTION_HEADERS
          WHERE Asset_Id          = px_asset_hdr_rec.asset_id
          AND book_Type_Code    = px_asset_hdr_rec.book_type_code;

         -- mrc
   DELETE FROM FA_MC_ADJUSTMENTS
          WHERE Asset_Id          = px_asset_hdr_rec.asset_id
          AND book_Type_Code    = px_asset_hdr_rec.book_type_code;

   DELETE FROM FA_MC_BOOKS
          WHERE Asset_Id          = px_asset_hdr_rec.asset_id
          AND book_Type_Code    = px_asset_hdr_rec.book_type_code;

   DELETE FROM FA_MC_DEPRN_DETAIL
          WHERE Asset_Id          = px_asset_hdr_rec.asset_id
          AND book_Type_Code    = px_asset_hdr_rec.book_type_code;

   DELETE FROM FA_MC_DEPRN_SUMMARY
          WHERE Asset_Id          = px_asset_hdr_rec.asset_id
          AND book_Type_Code    = px_asset_hdr_rec.book_type_code;

   DELETE FROM FA_MC_RETIREMENTS
          WHERE Asset_Id          = px_asset_hdr_rec.asset_id
          AND book_Type_Code    = px_asset_hdr_rec.book_type_code;


-- Asset hierarchy delete
    if (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then
          fa_cua_wb_ext_pkg.facuas1(px_asset_hdr_rec.Asset_Id, p_log_level_rec => p_log_level_rec);
    end if;


    if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then

           -- Added transfer_header_id in the where clause
           -- as a result of High Cost SQL drill bugfix 3116047 msiddiqu

           DELETE FROM FA_TRANSFER_DETAILS
           WHERE ( DISTRIBUTION_ID, transfer_header_id) IN
                 ( SELECT DISTRIBUTION_ID, transaction_header_id_in transfer_header_id
                   FROM FA_DISTRIBUTION_HISTORY
                   WHERE ASSET_ID = px_asset_hdr_rec.asset_id );

         -- BUG# 4173695
         -- removing this for performance and because invoice
         -- transfers could affect other assets

         -- For C1_rec in C1 Loop
         --   DELETE FROM FA_INVOICE_TRANSACTIONS
         --   WHERE INVOICE_TRANSACTION_ID = C1_rec.INVOICE_TRANSACTION_ID_IN
         --   OR INVOICE_TRANSACTION_ID = C1_rec.INVOICE_TRANSACTION_ID_OUT;
         -- End Loop;

         DELETE FROM FA_DISTRIBUTION_HISTORY
          WHERE Asset_Id          = px_asset_hdr_rec.asset_id;

         DELETE FROM FA_ASSET_HISTORY
          WHERE Asset_Id          = px_asset_hdr_rec.asset_id;

         FA_ADDITIONS_PKG.DELETE_ROW
            (X_Rowid      => l_rowid,
             X_Asset_id   => px_asset_hdr_rec.asset_id,
             X_Calling_Fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

         DELETE FROM FA_ASSET_INVOICES
          WHERE Asset_Id          = px_asset_hdr_rec.asset_id;

         DELETE FROM FA_MC_ASSET_INVOICES
          WHERE Asset_Id          = px_asset_hdr_rec.asset_id;

         DELETE FROM FA_PERIODIC_PRODUCTION WHERE ASSET_ID = px_asset_hdr_rec.asset_id;

         DELETE FROM fa_add_warranties
          WHERE asset_id= px_asset_hdr_rec.asset_id;

         if ( (fa_cache_pkg.fazcat_record.category_type = 'LEASEHOLD IMPROVEMENT')
	    and (p_asset_desc_rec.lease_id is not null) )	then
            FA_LEASES_PKG.Delete_Row
               (X_Lease_Id   => p_asset_desc_rec.lease_id,
                X_Calling_Fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
         end if;

    elsif (fa_cache_pkg.fazcbc_record.book_class = 'BUDGET') then

         DELETE FROM FA_CAPITAL_BUDGET WHERE ASSET_ID = px_asset_hdr_rec.asset_id ;

    End if;

/*
      DELETE FROM FA_ACE_BOOKS
       WHERE ASSET_ID = px_asset_hdr_rec.asset_id;

      DELETE FROM FA_BALANCES_REPORT
       WHERE ASSET_ID = px_asset_hdr_rec.asset_id;

      DELETE FROM FA_DEFERRED_DEPRN
       WHERE ASSET_ID = px_asset_hdr_rec.asset_id;

      DELETE FROM FA_MASS_REVALUATION_RULES
       WHERE ASSET_ID = px_asset_hdr_rec.asset_id;

      DELETE FROM FA_RESERVE_LEDGER
       WHERE ASSET_ID = px_asset_hdr_rec.asset_id;
*/


   return true;


EXCEPTION

   WHEN DEL_ERR THEN
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

END do_all_books;

FUNCTION delete_asset_events (px_asset_hdr_rec IN FA_API_TYPES.asset_hdr_rec_type,
                              p_asset_type_rec IN fa_api_types.asset_type_rec_type,
                              p_log_level_rec  IN fa_api_types.log_level_rec_type default null) RETURN BOOLEAN IS

   del_err              EXCEPTION;
   l_calling_fn         varchar2(80) := 'fa_delete_pub.delete_asset_events';

   --Need this to get any events that might have been sent to SLA to avoid
   --leaving orphans there.  Second part of union is used to get dist-related
   --trxs in tax book, since we use the th id from corp book in such cases.

   CURSOR get_trx_id IS
     select th.transaction_header_id, th.event_id, th.book_type_code
     from fa_transaction_headers th
     where th.book_type_code = px_asset_hdr_rec.book_type_code
     and th.asset_id = px_asset_hdr_rec.asset_id
     and th.event_id is not null
     union
     select en.source_id_int_1, ev.event_id, en.valuation_method
     from xla_transaction_entities en, xla_events ev,
          fa_transaction_headers th, fa_book_controls bc
     where bc.book_class = 'TAX'
     and bc.date_ineffective is null
     and ev.entity_id          = en.entity_id
     and ev.application_id     = 140
     and ev.event_status_code  <> 'P'
     and th.book_type_code     = bc.distribution_source_book
     and th.asset_id           = px_asset_hdr_rec.asset_id
     and en.source_id_int_1    = th.transaction_header_id
     and en.valuation_method   = bc.book_type_code
     and en.entity_code        = 'TRANSACTIONS'
     and en.ledger_id          = bc.set_of_books_id
     and en.application_id     = 140
     and en.source_id_int_1 is not null;

BEGIN

   FOR trx_rec IN get_trx_id LOOP

      if not fa_xla_events_pvt.delete_transaction_event
           (p_ledger_id              => px_asset_hdr_rec.set_of_books_id,
            p_transaction_header_id  => trx_rec.transaction_header_id,
            p_book_type_code         => trx_rec.book_type_code,
            p_asset_type             => p_asset_type_rec.asset_type,
            p_calling_fn             => l_calling_fn,
            p_log_level_rec          => p_log_level_rec) then
         raise del_err;
      end if;

   END LOOP; -- end for

   return TRUE;

EXCEPTION

   WHEN DEL_ERR THEN
      fa_srvr_msg.add_message(calling_fn => l_calling_fn
            ,p_log_level_rec => p_log_level_rec);
      return FALSE;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
            ,p_log_level_rec => p_log_level_rec);
      return FALSE;

END delete_asset_events;

-----------------------------------------------------------------------------

END FA_DELETION_PUB;

/
