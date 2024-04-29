--------------------------------------------------------
--  DDL for Package Body FA_DEPRN_ROLLBACK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_DEPRN_ROLLBACK_PUB" AS
/* $Header: FAPDRBB.pls 120.9.12010000.5 2010/03/05 08:35:13 gigupta ship $   */

--*********************** Global constants *******************************--
G_PKG_NAME      CONSTANT   varchar2(30) := 'FA_DEPRN_ROLLBACK_PUB';
G_API_NAME      CONSTANT   varchar2(30) := 'Depreciation Rollback API';
G_API_VERSION   CONSTANT   number       := 1.0;

g_log_level_rec fa_api_types.log_level_rec_type; -- Bug:5475024

--*********************** Private functions ******************************--

FUNCTION do_all_books
   (px_asset_hdr_rec   IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_calling_fn       IN     VARCHAR2,
    p_log_level_rec    IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN; -- Bug:5475024

--*********************** Public procedures ******************************--
procedure do_rollback (
   -- Standard Parameters --
   p_api_version              IN      NUMBER,
   p_init_msg_list            IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                   IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level         IN      NUMBER :=FND_API.G_VALID_LEVEL_FULL,
   x_return_status               OUT NOCOPY  VARCHAR2,
   x_msg_count                   OUT NOCOPY  NUMBER,
   x_msg_data                    OUT NOCOPY  VARCHAR2,
   p_calling_fn               IN      VARCHAR2,
   -- Asset Object --
   px_asset_hdr_rec           IN OUT NOCOPY  fa_api_types.asset_hdr_rec_type
)  as

   l_asset_type_rec          fa_api_types.asset_type_rec_type;
   l_asset_hdr_rec           fa_api_types.asset_hdr_rec_type;
   l_group_asset_id          number;
   l_tracking_method         varchar2(30);

   -- used to store original sob info upon entry into api
   l_orig_set_of_books_id    number;
   l_orig_currency_context   varchar2(64);

   l_calling_fn              varchar2(40) := 'fa_deprn_rollback_pub.do_rollback';

   rb_err                    exception;  -- sets return status


   cursor c_members (p_book_type_code varchar2,
                     p_group_asset_id number) is
   select asset_id
     from fa_books
    where group_asset_id = p_group_asset_id
      and book_type_code = p_book_type_code
          and transaction_header_id_out is null;

begin

   SAVEPOINT do_rollback;

   -- Bug:5475024
   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise rb_err;
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
   if (NOT fnd_api.compatible_api_call (
          G_API_VERSION,
          p_api_version,
          G_API_NAME,
          G_PKG_NAME
   )) then
      raise rb_err;
   end if;

   -- Call the cache for the primary transaction book
   if (NOT fa_cache_pkg.fazcbc (X_book => px_asset_hdr_rec.book_type_code,
                                p_log_level_rec => g_log_level_rec)) then -- Bug:5475024
      raise rb_err;
   end if;

   px_asset_hdr_rec.set_of_books_id :=
      fa_cache_pkg.fazcbc_record.set_of_books_id;

   if (p_validation_level = FND_API.G_VALID_LEVEL_FULL) then

      null;

   end if;

   -- Bug:5475024
   -- verify the asset exist in the book already
   if not FA_ASSET_VAL_PVT.validate_asset_book
              (p_transaction_type_code      => 'DEPRECIATION',
               p_book_type_code             => px_asset_hdr_rec.book_type_code,
               p_asset_id                   => px_asset_hdr_rec.asset_id,
               p_calling_fn                 => l_calling_fn,
               p_log_level_rec              => g_log_level_rec) then
      raise rb_err;
   end if;

   if not FA_UTIL_PVT.get_asset_type_rec
          (p_asset_hdr_rec         => px_asset_hdr_rec,
           px_asset_type_rec       => l_asset_type_rec,
           p_date_effective        => null,
           p_log_level_rec         => g_log_level_rec -- Bug:5475024
          ) then
      raise rb_err;
   end if;

   -- get group info for processing
   select group_asset_id,
          tracking_method
     into l_group_asset_id,
          l_tracking_method
     from fa_books
    where asset_id       = px_asset_hdr_rec.asset_id
      and book_type_code = px_asset_hdr_rec.book_type_code
      and transaction_header_id_out is null;

   -- call the routine to loop through primary and reporting books
   if not do_all_books
      (px_asset_hdr_rec   => px_asset_hdr_rec,
       p_calling_fn       => p_calling_fn,
       p_log_level_rec    => g_log_level_rec) then -- Bug:5475024
      raise rb_err;
   end if;

   l_asset_hdr_rec := px_asset_hdr_rec;

   if (l_asset_type_rec.asset_type = 'GROUP' and
       l_tracking_method is not null) then

      for c_rec in c_members (p_book_type_code => px_asset_hdr_rec.book_type_code,
                              p_group_asset_id => px_asset_hdr_rec.asset_id) loop

         l_asset_hdr_rec.asset_id := c_rec.asset_id;

         if not do_all_books
              (px_asset_hdr_rec   => l_asset_hdr_rec,
               p_calling_fn       => p_calling_fn,
               p_log_level_rec    => g_log_level_rec) then -- Bug:5475024
            raise rb_err;
         end if;

      end loop;


   elsif (l_group_asset_id is not null) then

      l_asset_hdr_rec.asset_id    := l_group_asset_id;

      if not do_all_books
           (px_asset_hdr_rec   => l_asset_hdr_rec,
            p_calling_fn       => p_calling_fn,
            p_log_level_rec    => g_log_level_rec) then -- Bug:5475024
         raise rb_err;
      end if;

      if (l_tracking_method = 'ALLOCATE') then
        --Bug6680499 changed px_asset_hdr_rec.asset_id to l_asset_hdr_rec.asset_id
         for c_rec in c_members (p_book_type_code => px_asset_hdr_rec.book_type_code,
                                 p_group_asset_id => l_asset_hdr_rec.asset_id) loop

            l_asset_hdr_rec.asset_id := c_rec.asset_id;

            if not do_all_books
                 (px_asset_hdr_rec   => l_asset_hdr_rec,
                  p_calling_fn       => p_calling_fn,
                  p_log_level_rec    => g_log_level_rec) then -- Bug:5475024
               raise rb_err;
            end if;

         end loop;

      end if;
   end if;

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
   when rb_err then

      ROLLBACK TO do_rollback;

      fa_srvr_msg.add_message
           (calling_fn      => l_calling_fn,
            p_log_level_rec => g_log_level_rec); -- Bug:5475024

      FND_MSG_PUB.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

      x_return_status := FND_API.G_RET_STS_ERROR;

   when others then

      ROLLBACK TO do_rollback;

      fa_srvr_msg.add_sql_error
           (calling_fn      => l_calling_fn,
            p_log_level_rec => g_log_level_rec); -- Bug:5475024

      FND_MSG_PUB.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

      x_return_status := FND_API.G_RET_STS_ERROR;

end do_rollback;

-----------------------------------------------------------------------------

-- Books (MRC) Wrapper - called from public API above
--
-- For non mrc books, this just calls the private API with provided params
-- For MRC, it processes the primary and then loops through each reporting
-- book calling the private api for each.


FUNCTION do_all_books
   (px_asset_hdr_rec   IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_calling_fn       IN     VARCHAR2,
    p_log_level_rec    IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN IS -- Bug:5475024

   l_mrc_asset_hdr_rec    FA_API_TYPES.asset_hdr_rec_type;
   l_period_rec                   fa_api_types.period_rec_type;
   l_rsob_tbl                     fa_cache_pkg.fazcrsob_sob_tbl_type;
   l_mrc_sob_type_code            varchar2(1);

   l_deprn_source_info XLA_EVENTS_PUB_PKG.t_event_source_info;
   l_security_context  XLA_EVENTS_PUB_PKG.t_security;


   l_event_id          number;
   l_rev_event_id      number;

   l_deprn_run_id      number;
   l_event_status      varchar2(1);
   l_deprn_count       number;
   l_sysdate           date;
   l_result            integer;

   l_txn_status        boolean;

   l_calling_fn        varchar2(60) := 'fa_deprn_rollback_pub.do_all_books';
   rb_err              exception;

BEGIN

   l_sysdate := sysdate;

   if (NOT FA_UTIL_PVT.get_period_rec (
       p_book           => px_asset_hdr_rec.book_type_code,
       p_effective_date => NULL,
       x_period_rec     => l_period_rec,
       p_log_level_rec  => p_log_level_rec -- Bug:5475024
      )) then
      raise rb_err;
   end if;

   -- see if any rows actually exist in any currencies

   BEGIN

      select event_id, deprn_run_id
        into l_event_id,
             l_deprn_run_id
        from fa_deprn_events_v de
       where de.book_type_code = px_asset_hdr_rec.book_type_code
         and de.asset_id       = px_asset_hdr_rec.asset_id
         and de.period_counter = l_period_rec.period_counter
         and de.reversal_event_id is null;

         if (g_log_level_rec.statement_level) then -- Bug:5475024
            fa_debug_pkg.add(l_calling_fn, 'l_event_id', l_event_id,
                             p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_deprn_run_id', l_deprn_run_id,
                             p_log_level_rec => p_log_level_rec);
         end if;

   EXCEPTION

      WHEN NO_DATA_FOUND THEN
           if (g_log_level_rec.statement_level) then -- Bug:5475024
              fa_debug_pkg.add(l_calling_fn, 'no event found', 'for this asset',
                               p_log_level_rec => p_log_level_rec);
           end if;
   END;



   -- call transaction approval for primary books only
   -- note that we don't need all the logic in faxcat since no transaction
   -- would be allowed on a transaction in the open period.  We need to insure
   -- two things:
   --  1) no pending mass transaction on the book.  (which could be mass deprn rollback)
   --  2) no deprn run ongoing since closing the book and rolling back deprn
   --     on one or more of the already processed assets would not be good combination

   -- BUG# 8247224
   --  removing call to faxcat... replaceing with condition book level check
   --
   -- as originally written, this call will become recursive in the
   -- event depreciatio nhas run for the period.  When called from
   -- faxcdr (via a transaction API), we're covered.   in the event
   -- it is called directly, we need to cover as book level check

   if (nvl(p_calling_fn, '-X') <> 'FA_CHK_BOOKSTS_PKG.faxcdr') then
      if not FA_CHK_BOOKSTS_PKG.faxcps
              (X_book         => px_asset_hdr_rec.book_type_code,
               X_submit       => FALSE,
               X_start        => FALSE,
               X_asset_id     => 0,
               X_trx_type     => 'RB_DEP',
               X_txn_status   => l_txn_status,
               X_close_period => 0,
               p_log_level_rec  => p_log_level_rec
              ) then
         raise rb_err;
      else
         if (not l_txn_status ) then
            raise rb_err;
         end if;
      end if;
   end if;

   if (l_event_id is not null) then
      l_deprn_source_info.application_id        := 140;
      l_deprn_source_info.ledger_id             := px_asset_hdr_rec.set_of_books_id;
      l_deprn_source_info.source_id_int_1       := px_asset_hdr_rec.asset_id ;
      l_deprn_source_info.source_id_char_1      := px_asset_hdr_rec.book_type_code;
      l_deprn_source_info.source_id_int_2       := l_period_rec.period_counter;
      l_deprn_source_info.source_id_int_3       := l_deprn_run_id;
      l_deprn_source_info.entity_type_code      := 'DEPRECIATION';

      if (g_log_level_rec.statement_level) then -- Bug:5475024
         fa_debug_pkg.add(l_calling_fn, 'calling get event status for event ', l_event_id,
                          p_log_level_rec => p_log_level_rec);
      end if;

      -- check the event status
      l_event_status := XLA_EVENTS_PUB_PKG.get_event_status
                        (p_event_source_info            => l_deprn_source_info,
                         p_event_id                     => l_event_id,
                         p_valuation_method             => px_asset_hdr_rec.book_type_code,
                         p_security_context             => l_security_context);

      if (g_log_level_rec.statement_level) then -- Bug:5475024
         fa_debug_pkg.add(l_calling_fn, 'event status ', l_event_status,
                          p_log_level_rec => p_log_level_rec);
      end if;

      if (l_event_status = XLA_EVENTS_PUB_PKG.C_EVENT_PROCESSED) then

         -- create the reversal event
         l_rev_event_id := xla_events_pub_pkg.create_event
             (p_event_source_info            => l_deprn_source_info,
              p_event_type_code              => 'ROLLBACK_DEPRECIATION',
              p_event_date                   => greatest(l_period_rec.calendar_period_open_date, /*Bug#9274982 */
                                                         least(l_period_rec.calendar_period_close_date,
                                                               sysdate)),
              p_event_status_code            => XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED,
              p_event_number                 => NULL,
              p_reference_info               => NULL,
              p_valuation_method             => px_asset_hdr_rec.book_type_code,
              p_security_context             => l_security_context);

         if (g_log_level_rec.statement_level) then -- Bug:5475024
            fa_debug_pkg.add(l_calling_fn, 'rollback event id', l_event_id,
                             p_log_level_rec => p_log_level_rec);
               end if;

      elsif (l_event_status = XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED) then

         if (g_log_level_rec.statement_level) then -- Bug:5475024
            fa_debug_pkg.add(l_calling_fn, 'deleting event', l_event_id,
                             p_log_level_rec => p_log_level_rec);
               end if;

         XLA_EVENTS_PUB_PKG.delete_event
            (p_event_source_info            => l_deprn_source_info,
             p_event_id                     => l_event_id,
             p_valuation_method             => px_asset_hdr_rec.book_type_code,
             p_security_context             => l_security_context);

         --6702657
         BEGIN
           l_result := XLA_EVENTS_PUB_PKG.delete_entity
                       (p_source_info       => l_deprn_source_info,
                        p_valuation_method  => px_asset_hdr_rec.book_type_code,
                        p_security_context  => l_security_context);

         EXCEPTION
           WHEN OTHERS THEN
             l_result := 1;
             fa_debug_pkg.add(l_calling_fn, 'Unable to delete entity for rb event',
                       l_event_id, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add(l_calling_fn, 'l_result', l_result, p_log_level_rec => p_log_level_rec);
         END; --annonymous
      else
         raise rb_err;
      end if;

   end if;  -- event is not null

   if (g_log_level_rec.statement_level) then -- Bug:5475024
      fa_debug_pkg.add(l_calling_fn, 'entering ', 'main logic',
                       p_log_level_rec => p_log_level_rec);
   end if;


   if (NOT fa_cache_pkg.fazcrsob (
       x_book_type_code => px_asset_hdr_rec.book_type_code,
       x_sob_tbl        => l_rsob_tbl,
       p_log_level_rec  => p_log_level_rec -- Bug:5475024
      )) then
      raise rb_err;
   end if;

   for mrc_index in 0..l_rsob_tbl.COUNT loop

      l_mrc_asset_hdr_rec := px_asset_hdr_rec;

      -- if the counter mrc_index  is at 0, then process incoming
      -- book else iterate through reporting books
      if (mrc_index  = 0) then
         l_mrc_asset_hdr_rec.set_of_books_id :=
            px_asset_hdr_rec.set_of_books_id;
        l_mrc_sob_type_code := 'P';
      else
         l_mrc_asset_hdr_rec.set_of_books_id :=
            l_rsob_tbl(mrc_index);
        l_mrc_sob_type_code := 'R';
      end if;

      -- Need to always call fazcbcs
      if (NOT fa_cache_pkg.fazcbcs (
         X_book => l_mrc_asset_hdr_rec.book_type_code,
         X_set_of_books_id => l_mrc_asset_hdr_rec.set_of_books_id,
         p_log_level_rec => p_log_level_rec -- Bug:5475024
      )) then
         raise rb_err;
      end if;

      -- check to make sure there are deprn rows for the
      -- currency in question

      if (mrc_index  = 0) then
         select count(*)
           into l_deprn_count
           from fa_deprn_summary ds
          where ds.book_type_code = px_asset_hdr_rec.book_type_code
            and ds.asset_id       = px_asset_hdr_rec.asset_id
            and ds.period_counter = l_period_rec.period_counter;
      else
         select count(*)
           into l_deprn_count
           from fa_mc_deprn_summary ds
          where ds.book_type_code = px_asset_hdr_rec.book_type_code
            and ds.asset_id       = px_asset_hdr_rec.asset_id
            and ds.period_counter = l_period_rec.period_counter
            and ds.set_of_books_id = l_mrc_asset_hdr_rec.set_of_books_id;
      end if;

      --8666930
      if l_deprn_count <> 0 then
         -- now rollback deprn
         if not fa_deprn_rollback_pvt.do_rollback
                  (p_asset_hdr_rec          => l_mrc_asset_hdr_rec,
                   p_period_rec             => l_period_rec,
                   p_deprn_run_id           => l_deprn_run_id,
                   p_reversal_event_id      => l_rev_event_id,
                   p_reversal_date          => l_sysdate,
                   p_deprn_exists_count     => l_deprn_count,
                   p_mrc_sob_type_code      => l_mrc_sob_type_code,
                   p_calling_fn             => l_calling_fn,
                   p_log_level_rec          => p_log_level_rec) then -- Bug:5475024
            raise rb_err;
         end if;
      end if;
   end loop;


   -- Bug 6391045
   -- Code hook for IAC

      if (FA_IGI_EXT_PKG.IAC_Enabled) then
         if not FA_IGI_EXT_PKG.Do_Rollback_Deprn(
                p_asset_hdr_rec             =>  px_asset_hdr_rec,
                p_period_rec                =>  l_period_rec,
                p_deprn_run_id              =>  l_deprn_run_id,
                p_reversal_event_id         =>  l_rev_event_id,
                p_reversal_date             =>  l_sysdate,
                p_deprn_exists_count        =>  l_deprn_count,
                p_calling_function          =>  l_calling_fn) then
         raise rb_err;
         end if;
    end if; -- (FA_IGI_EXT_PKG.IAC_Enabled)



 return true;

EXCEPTION

   WHEN rb_ERR THEN
      fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                              p_log_level_rec => p_log_level_rec); -- Bug:5475024
      return FALSE;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn,
                                p_log_level_rec => p_log_level_rec); -- Bug:5475024
      return FALSE;

END do_all_books;

END FA_DEPRN_ROLLBACK_PUB;

/
