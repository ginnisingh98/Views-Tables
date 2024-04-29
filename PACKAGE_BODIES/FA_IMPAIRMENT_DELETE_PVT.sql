--------------------------------------------------------
--  DDL for Package Body FA_IMPAIRMENT_DELETE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_IMPAIRMENT_DELETE_PVT" AS
/* $Header: FAVIMPDB.pls 120.6.12010000.1 2009/07/21 12:37:30 glchen noship $ */

g_print_debug boolean := fa_cache_pkg.fa_print_debug;
g_release     number  := fa_cache_pkg.fazarel_release;

  --
  -- Datatypes for pl/sql tables below
  --
  TYPE tab_rowid_type IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
--  TYPE tab_num15_type IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
  TYPE tab_num_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE tab_date_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  TYPE tab_char1_type IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
  TYPE tab_char3_type IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
  TYPE tab_char15_type IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
  TYPE tab_char30_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

  g_temp_number   number;
  g_temp_integer  binary_integer;
  g_temp_boolean  boolean;
  g_temp_varchar2 varchar2(100);


--*********************** Public functions ******************************--
FUNCTION delete_post(
              p_request_id        IN NUMBER,
              p_book_type_code    IN VARCHAR2,
              p_period_rec        IN FA_API_TYPES.period_rec_type,
              p_worker_id         IN NUMBER,
              p_mrc_sob_type_code IN VARCHAR2,
              p_set_of_books_id   IN NUMBER,
              p_calling_fn        IN VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_calling_fn   varchar2(60) := 'fa_process_impairment_pvt.process_depreciation';

   t_thid            tab_num15_type;
   t_asset_id        tab_num15_type;


   l_limit           binary_integer := 200;  -- limit constant for C1 cursor
   del_err           exception;

   Cursor c_mc_get_recs is
     select transaction_header_id_in,asset_id from
     fa_mc_books
     where  transaction_header_id_out is null
      and   book_type_code = p_book_type_code
      and   set_of_books_id = p_set_of_books_id
      and   asset_id in (select itf.asset_id
      from fa_mc_impairments imp
         , fa_mc_itf_impairments itf
      where itf.impairment_id = imp.impairment_id
      and   itf.book_type_code = p_book_type_code
      and   itf.worker_id = p_worker_id
      and   imp.request_id = p_request_id
      and   imp.set_of_books_id = p_set_of_books_id
      and   itf.set_of_books_id = p_set_of_books_id
      and   imp.status = 'DELETING POST');

   Cursor c_get_recs is
     select transaction_header_id_in,asset_id from
     fa_books
     where  transaction_header_id_out is null
      and   book_type_code = p_book_type_code
      and   asset_id in (select itf.asset_id
      from fa_impairments imp
         , fa_itf_impairments itf
      where itf.impairment_id = imp.impairment_id
      and   itf.book_type_code = p_book_type_code
      and   itf.worker_id = p_worker_id
      and   imp.request_id = p_request_id
      and   imp.status = 'DELETING POST');

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'Begin', p_book_type_code, p_log_level_rec => p_log_level_rec);
   end if;

   if (p_mrc_sob_type_code = 'R') then
      if G_release = 11 then
         delete from fa_mc_books
         where transaction_header_id_out is null
         and   book_type_code = p_book_type_code
         and   set_of_books_id = p_set_of_books_id
         and   asset_id in (select itf.asset_id
         from fa_mc_impairments imp
            , fa_mc_itf_impairments itf
         where itf.impairment_id = imp.impairment_id
         and   itf.book_type_code = p_book_type_code
         and   itf.worker_id = p_worker_id
         and   itf.set_of_books_id = p_set_of_books_id
         and   imp.request_id = p_request_id
         and   imp.status = 'DELETING POST'
         and   imp.set_of_books_id = p_set_of_books_id)
         returning transaction_header_id_in, asset_id
         bulk collect into t_thid
                      , t_asset_id;
      else
         open c_mc_get_recs;
         fetch c_mc_get_recs bulk collect into t_thid, t_asset_id;

         /* Ideally no need to call this again for MRC as already processed for primary
         not sure though.*/
         for i in 1..t_asset_id.count loop
            if not rollback_deprn_event(p_book_type_code,
                                  t_asset_id(i),
                                  p_mrc_sob_type_code,
                                  p_set_of_books_id,
                                  p_log_level_rec) then

               raise del_err;
            end if;
         end loop;
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'after rollback_deprn_event *********', '*********', p_log_level_rec => p_log_level_rec);
         end if;
         for i in 1..t_asset_id.count loop
            if not rollback_impair_event(p_request_id,
                                   p_book_type_code,
                                  t_asset_id(i),
                                  t_thid(i),
                                  p_mrc_sob_type_code,
                                  p_set_of_books_id,
                                  p_log_level_rec) then
              raise del_err;
            end if;
         end loop;
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'after rollback_impair_event *********', '*********', p_log_level_rec => p_log_level_rec);
         end if;
         close c_mc_get_recs;
      end if;

      if G_release = 11 then
         FORALL i in 1..t_thid.count
         delete from fa_mc_adjustments
         where  transaction_header_id = t_thid(i)
         and    asset_id = t_asset_id(i)
         and    book_type_code = p_book_type_code
         and    period_counter_created = p_period_rec.period_counter
         and    set_of_books_id = p_set_of_books_id;
      end if;

      FORALL i in 1..t_thid.count
      delete from fa_mc_deprn_detail
      where asset_id = t_asset_id(i)
      and    book_type_code = p_book_type_code
      and    period_counter = p_period_rec.period_counter
      and    set_of_books_id = p_set_of_books_id;

      FORALL i in 1..t_thid.count
      delete from fa_mc_deprn_summary
      where asset_id = t_asset_id(i)
      and    book_type_code = p_book_type_code
      and    period_counter = p_period_rec.period_counter
      and    set_of_books_id = p_set_of_books_id;

      if G_release = 11 then
       --Bug# 6766637 to update TRANSACTION_TYPE_CODE to ADDITION for period of addition.
         forall i in 1..t_thid.count
         update fa_transaction_headers
         set transaction_type_code ='ADDITION'
         where transaction_header_id = (
           select transaction_header_id_in
           from fa_mc_books
           where  transaction_header_id_out = t_thid(i)
           and set_of_books_id = p_set_of_books_id)
           and transaction_type_code = 'ADDITION/VOID'
           and book_type_code = p_book_type_code;

         FORALL i in 1..t_thid.count
         update fa_mc_books
         set date_ineffective = null
           , transaction_header_id_out = null
         where asset_id = t_asset_id(i)
         and    book_type_code = p_book_type_code
         and    transaction_header_id_out = t_thid(i)
         and    set_of_books_id = p_set_of_books_id ;
      end if;

      FORALL i in 1..t_thid.count
      delete from fa_mc_itf_impairments
      where asset_id = t_asset_id(i)
      and    book_type_code = p_book_type_code
      and   worker_id = p_worker_id
      and   period_counter = p_period_rec.period_counter
      and   set_of_books_id = p_set_of_books_id;

   else
      if G_release = 11 then
         delete from fa_books
         where transaction_header_id_out is null
         and   book_type_code = p_book_type_code
         and   asset_id in (select itf.asset_id
         from fa_impairments imp
            , fa_itf_impairments itf
         where itf.impairment_id = imp.impairment_id
         and   itf.book_type_code = p_book_type_code
         and   itf.worker_id = p_worker_id
         and   imp.request_id = p_request_id
         and   imp.status = 'DELETING POST')
         returning transaction_header_id_in, asset_id
         bulk collect into t_thid
                         , t_asset_id;
      else
         open c_get_recs;
         fetch c_get_recs bulk collect into t_thid, t_asset_id;

         for i in 1..t_asset_id.count loop
            if not rollback_deprn_event(p_book_type_code,
                                  t_asset_id(i),
                                  p_mrc_sob_type_code,
                                  p_set_of_books_id,
                                  p_log_level_rec) then

               raise del_err;
            end if;
         end loop;
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'after rollback_deprn_event *********', '*********', p_log_level_rec => p_log_level_rec);
         end if;
         for i in 1..t_asset_id.count loop
            if not rollback_impair_event(p_request_id,
                                   p_book_type_code,
                                  t_asset_id(i),
                                  t_thid(i),
                                  p_mrc_sob_type_code,
                                  p_set_of_books_id,
                                  p_log_level_rec) then
              raise del_err;
            end if;
         end loop;
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'after rollback_impair_event *********', '*********', p_log_level_rec => p_log_level_rec);
         end if;
         close c_get_recs;
      end if;

      if G_release = 11 then
         FORALL i in 1..t_thid.count
         delete from fa_adjustments
         where  transaction_header_id = t_thid(i)
         and    asset_id = t_asset_id(i)
         and    book_type_code = p_book_type_code
         and    period_counter_created = p_period_rec.period_counter;
      end if;

      FORALL i in 1..t_thid.count
      delete from fa_deprn_detail
      where asset_id = t_asset_id(i)
      and    book_type_code = p_book_type_code
      and    period_counter = p_period_rec.period_counter;

      FORALL i in 1..t_thid.count
      delete from fa_deprn_summary
      where asset_id = t_asset_id(i)
      and    book_type_code = p_book_type_code
      and    period_counter = p_period_rec.period_counter;

      --Bug# 6766637 to update TRANSACTION_TYPE_CODE to ADDITION for period of addition.
      if G_release = 11 then
         forall i in 1..t_thid.count
         update fa_transaction_headers
         set transaction_type_code='ADDITION'
         where transaction_header_id in(
           select transaction_header_id_in
           from fa_books
           where  transaction_header_id_out = t_thid(i))
           and transaction_type_code = 'ADDITION/VOID'
           and book_type_code = p_book_type_code;

         FORALL i in 1..t_thid.count
         update fa_books
         set date_ineffective = null
           , transaction_header_id_out = null
         where asset_id = t_asset_id(i)
         and    book_type_code = p_book_type_code
         and    transaction_header_id_out = t_thid(i);

         FORALL i in 1..t_thid.count
         delete from fa_transaction_headers
         where transaction_header_id = t_thid(i);
      end if;

      FORALL i in 1..t_thid.count
      delete from fa_itf_impairments
      where asset_id = t_asset_id(i)
      and    book_type_code = p_book_type_code
      and   worker_id = p_worker_id
      and   period_counter = p_period_rec.period_counter;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'Manual Override', 'BEGIN', p_log_level_rec => p_log_level_rec);
      end if;

      fa_std_types.deprn_override_trigger_enabled:= FALSE;

      FORALL i in 1..t_thid.count
      update fa_deprn_override
      set    status = 'POST'
      where  book_type_code = p_book_type_code
      and    asset_id = t_asset_id(i)
      and    period_name = p_period_rec.period_name
      and    used_by = 'DEPRECIATION'
      and    status = 'POSTED' ;

      fa_std_types.deprn_override_trigger_enabled:= TRUE;

   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'End', p_book_type_code, p_log_level_rec => p_log_level_rec);
   end if;

   return true;

EXCEPTION
   WHEN del_err THEN

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'EXCEPTION', 'del_err', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'sqlerrm', substrb(sqlerrm, 1, 200));
      end if;

      return false;

   WHEN OTHERS THEN

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'EXCEPTION', 'OTHERS', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'sqlerrm', substrb(sqlerrm, 1, 200));
      end if;

      return false;

END delete_post;

FUNCTION process_impair_event(
              p_book_type_code    IN VARCHAR2,
              p_mrc_sob_type_code IN VARCHAR2,
              p_set_of_books_id   IN NUMBER,
              p_calling_fn        IN VARCHAR2,
              p_thid              IN tab_num15_type,
              p_log_level_rec     IN FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   -- Info for event creation.
   l_legal_entity_id  number;
   l_event_type_code  varchar2(30) ;
   l_event_id         number;
   l_event_date       date;
   l_event_id_tbl     FA_XLA_EVENTS_PVT.number_tbl_type;
   l_thid             tab_num15_type;

   l_calling_fn       varchar2(60) := 'FA_IMPAIRMENT_DELETE_PVT.process_impair_event';

begin
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Begins ', 'process_impair_event',p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_book_type_code ', p_book_type_code,p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_mrc_sob_type_code ', p_mrc_sob_type_code,p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_set_of_books_id ', p_set_of_books_id,p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_thid count ', p_thid.count ,p_log_level_rec => p_log_level_rec);
   end if;

   l_event_date :=
         greatest(fa_cache_pkg.fazcdp_record.calendar_period_open_date,
                  least(nvl(fa_cache_pkg.fazcdp_record.calendar_period_close_date,
                            sysdate),
                        sysdate));

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Before inserting into : ', 'xla_events_int_gt',p_log_level_rec => p_log_level_rec);
   end if;
   -- load the array as required by SLA:
   -- verify event number and transaction number relevance here
   -- since neither table uses a transaction sequence
   forall i in 1..p_thid.count
      insert into xla_events_int_gt
      (APPLICATION_ID       ,
       LEDGER_ID            ,
       LEGAL_ENTITY_ID      ,
       ENTITY_CODE          ,
       event_type_code      ,
       event_date           ,
       event_number         ,
       event_status_code    ,
       transaction_number   ,
       source_id_int_1      ,
       source_id_char_1     ,
       -- source_id_int_2      ,
       --source_id_int_3      ,
       valuation_method
      )
     values
     (140                  ,
      p_set_of_books_id,
      l_legal_entity_id    ,
      'TRANSACTIONS'    ,
      'IMPAIRMENT'       ,
      l_event_date  ,
      NULL    ,
      XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED,
      to_char(p_thid(i))    ,
      p_thid(i)   ,
      p_book_type_code     ,
      -- p_period_rec.period_counter     ,
      -- NULL       ,
      p_book_type_code
     );

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'calling : ', 'create_bulk_events',p_log_level_rec => p_log_level_rec);
   end if;

   XLA_EVENTS_PUB_PKG.create_bulk_events
                                   (p_source_application_id   => NULL,
                                    p_application_id          => 140,
                                    p_legal_entity_id         => l_legal_entity_id,
                                    p_ledger_id               => p_set_of_books_id,
                                    p_entity_type_code        => 'TRANSACTIONS'
                                    );

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Created events ', 'SUCCESSFULLY',p_log_level_rec => p_log_level_rec);
   end if;
   --Fetch event ids created.
   select event_id,source_id_int_1 bulk collect
     into l_event_id_tbl,l_thid
   from xla_events_int_gt;


   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Updating event id in : ', 'fa_transaction_headers',p_log_level_rec => p_log_level_rec);
   end if;

   FORALL i in 1..l_thid.count
      UPDATE FA_TRANSACTION_HEADERS
      SET    event_id = l_event_id_tbl(i)
      WHERE  TRANSACTION_HEADER_ID = l_thid(i)
      AND    BOOK_TYPE_CODE = p_book_type_code;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'process_impair_event', 'ends',p_log_level_rec => p_log_level_rec);
   end if;

   return true;
EXCEPTION
   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn,
                                p_log_level_rec => p_log_level_rec);
      return FALSE;
END process_impair_event;

FUNCTION rollback_deprn_event(
              p_book_type_code    IN VARCHAR2,
              p_asset_id          IN number,
              p_mrc_sob_type_code IN VARCHAR2,
              p_set_of_books_id   IN NUMBER,
              p_log_level_rec     IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS


   --Deprn event info
   l_deprn_source_info XLA_EVENTS_PUB_PKG.t_event_source_info;
   l_security_context  XLA_EVENTS_PUB_PKG.t_security;

   l_event_id          number;
   l_deprn_run_id      number;
   l_event_status      varchar2(1);

   --For reversal
   l_rev_event_id      number;

   l_sysdate           date:= sysdate;
   l_period_rec        fa_api_types.period_rec_type;
   l_result            integer;

   l_calling_fn        varchar2(60) := 'FA_IMPAIRMENT_DELETE_PVT.rollback_deprn_event';
   rb_err              exception;

begin
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Rollback_deprn_event ', 'Begins',p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_book_type_code ', p_book_type_code,p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_asset_id  ', p_asset_id ,p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_mrc_sob_type_code ', p_mrc_sob_type_code,p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_set_of_books_id ', p_set_of_books_id,p_log_level_rec => p_log_level_rec);
   end if;

   if (NOT FA_UTIL_PVT.get_period_rec (
       p_book           => p_book_type_code,
       p_effective_date => NULL,
       x_period_rec     => l_period_rec,
       p_log_level_rec  => p_log_level_rec
      )) then
      raise rb_err;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'fetched', 'period rec', p_log_level_rec => p_log_level_rec);
   end if;

   BEGIN
      select event_id, deprn_run_id
        into l_event_id,
             l_deprn_run_id
        from fa_deprn_events_v de
      where de.book_type_code = p_book_type_code
         and de.asset_id       = p_asset_id
         and de.period_counter = l_period_rec.period_counter
         and de.reversal_event_id is null;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'l_event_id', l_event_id,p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_deprn_run_id', l_deprn_run_id, p_log_level_rec => p_log_level_rec);
      end if;
   EXCEPTION

   WHEN NO_DATA_FOUND THEN
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'no event found for this asset',p_asset_id,p_log_level_rec => p_log_level_rec);
      end if;
   END;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'fetched event_id :', l_event_id, p_log_level_rec => p_log_level_rec);
   end if;

   if (l_event_id is not null) then
      l_deprn_source_info.application_id        := 140;
      l_deprn_source_info.ledger_id             := p_set_of_books_id;
      l_deprn_source_info.source_id_int_1       := p_asset_id ;
      l_deprn_source_info.source_id_char_1      := p_book_type_code;
      l_deprn_source_info.source_id_int_2       := l_period_rec.period_counter;
      l_deprn_source_info.source_id_int_3       := l_deprn_run_id;
      l_deprn_source_info.entity_type_code      := 'DEPRECIATION';

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'fetching status of event  ', l_event_id,p_log_level_rec => p_log_level_rec);
      end if;

      -- fetch the event status
      l_event_status := XLA_EVENTS_PUB_PKG.get_event_status
                        (p_event_source_info            => l_deprn_source_info,
                         p_event_id                     => l_event_id,
                         p_valuation_method             => p_book_type_code,
                         p_security_context             => l_security_context);

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'event status ', l_event_status,p_log_level_rec => p_log_level_rec);
      end if;

      if (l_event_status <> XLA_EVENTS_PUB_PKG.C_EVENT_PROCESSED) then

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Deleting unprocessed event', l_event_id,p_log_level_rec => p_log_level_rec);
         end if;

         XLA_EVENTS_PUB_PKG.delete_event
            (p_event_source_info            => l_deprn_source_info,
             p_event_id                     => l_event_id,
             p_valuation_method             => p_book_type_code,
             p_security_context             => l_security_context);

         BEGIN
           l_result := XLA_EVENTS_PUB_PKG.delete_entity
                       (p_source_info       => l_deprn_source_info,
                        p_valuation_method  => p_book_type_code,
                        p_security_context  => l_security_context);

         EXCEPTION
           WHEN OTHERS THEN
             l_result := 1;
             fa_debug_pkg.add(l_calling_fn, 'Unable to delete entity for rb event',l_event_id, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add(l_calling_fn, 'l_result', l_result, p_log_level_rec => p_log_level_rec);
             raise rb_err;
         END; --annonymous

         DELETE from fa_deprn_events
         where asset_id         = p_asset_id
         and book_type_code    = p_book_type_code
         and period_counter    = l_period_rec.period_counter
         and reversal_event_id is null;

      elsif (l_event_status = XLA_EVENTS_PUB_PKG.C_EVENT_PROCESSED) then
         -- create the reversal event
         if (p_mrc_sob_type_code = 'P') then
            l_rev_event_id := xla_events_pub_pkg.create_event
                (p_event_source_info            => l_deprn_source_info,
                 p_event_type_code              => 'ROLLBACK_DEPRECIATION',
                 p_event_date                   => l_period_rec.calendar_period_close_date,
                 p_event_status_code            => XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED,
                 p_event_number                 => NULL,
                 p_reference_info               => NULL,
                 p_valuation_method             => p_book_type_code,
                 p_security_context             => l_security_context);

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'rollback event id', l_event_id, p_log_level_rec => p_log_level_rec);
            end if;

            -- flag the header table too
            update fa_deprn_events
               set reversal_event_id = l_rev_event_id,
                   reversal_date     = l_sysdate
            where asset_id           = p_asset_id
               and book_type_code    = p_book_type_code
               and period_counter    = l_period_rec.period_counter
               and deprn_run_id      = l_deprn_run_id;
         end if;
      else
         raise rb_err;
      end if;
   end if;  -- event is not null

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Rollback_deprn_event ', 'Ends',p_log_level_rec => p_log_level_rec);
   end if;

   return true;

EXCEPTION
   WHEN rb_ERR THEN
      fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                              p_log_level_rec => p_log_level_rec);
      return FALSE;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn,
                                p_log_level_rec => p_log_level_rec);
      return FALSE;

END rollback_deprn_event;

FUNCTION rollback_impair_event(
              p_request_id        IN NUMBER,
              p_book_type_code    IN VARCHAR2,
              p_asset_id          IN NUMBER,
              p_thid              IN NUMBER,
              p_mrc_sob_type_code IN VARCHAR2,
              p_set_of_books_id   IN NUMBER,
              p_log_level_rec     IN FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_period_rec        fa_api_types.period_rec_type;
   l_event_id          number;
   l_rev_event_id      number;

   l_deprn_run_id      number;
   l_deprn_source_info XLA_EVENTS_PUB_PKG.t_event_source_info;
   l_security_context  XLA_EVENTS_PUB_PKG.t_security;

   l_event_status      varchar2(1);
   l_deprn_count       number;
   l_sysdate           date;
   l_result            integer;

   l_txn_status        boolean;

   l_calling_fn        varchar2(60) := 'FA_IMPAIRMENT_DELETE_PVT.rollback_impair_event';
   rb_err              exception;
   l_set_of_books_id   number;
   l_amount_inserted   number;

   l_adj               fa_adjust_type_pkg.fa_adj_row_struct;
   l_clear_adj         fa_adjust_type_pkg.fa_adj_row_struct;

   l_adj_row_rec       FA_ADJUSTMENTS%rowtype;
   l_current_units number;
   l_thid number;
   l_login_id       number(15) := fnd_global.user_id;

   l_trx_source_info  XLA_EVENTS_PUB_PKG.t_event_source_info;

   CURSOR c_mrc_adjustments (p_thid number) IS
   SELECT adj.code_combination_id    ,
          adj.distribution_id        ,
          adj.debit_credit_flag      ,
          adj.adjustment_amount      ,
          adj.adjustment_type        ,
          adj.source_type_code       ,
          ad.current_units
     FROM fa_mc_adjustments adj,
          fa_additions_b ad
    WHERE transaction_header_id = p_thid
    AND   set_of_books_id = p_set_of_books_id
    AND   ad.asset_id = adj.asset_id;

   CURSOR c_adjustments (p_thid number) IS
   SELECT adj.code_combination_id    ,
          adj.distribution_id        ,
          adj.debit_credit_flag      ,
          adj.adjustment_amount      ,
          adj.adjustment_type        ,
          adj.source_type_code       ,
          ad.current_units
     FROM fa_adjustments adj,
          fa_additions_b ad
    WHERE transaction_header_id = p_thid
    AND   ad.asset_id = adj.asset_id;

begin
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Rollback_impair_event ', 'Begins',p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_request_id ', p_request_id,p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_book_type_code ', p_book_type_code,p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_thid   ', p_thid ,p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_asset_id  ', p_asset_id ,p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_mrc_sob_type_code ', p_mrc_sob_type_code,p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_set_of_books_id ', p_set_of_books_id,p_log_level_rec => p_log_level_rec);
   end if;

   if (NOT FA_UTIL_PVT.get_period_rec (
       p_book           => p_book_type_code,
       p_effective_date => NULL,
       x_period_rec     => l_period_rec,
       p_log_level_rec  => p_log_level_rec -- Bug:5475024
      )) then
      raise rb_err;
   end if;
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'fetched', 'period rec', p_log_level_rec => p_log_level_rec);
   end if;

   /*8666930 - For mrc we will not find event as it was already deleted for primary if uprocessed*/
   BEGIN

      select  event_id
        into l_event_id
      from fa_transaction_headers
      where asset_id              = p_asset_id
        and book_type_code        = p_book_type_code
        and transaction_header_id = p_thid;

   EXCEPTION

   WHEN NO_DATA_FOUND THEN
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'no event found for this asset',p_asset_id,p_log_level_rec => p_log_level_rec);
      end if;
   END;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'l_event_id : ', l_event_id, p_log_level_rec => p_log_level_rec);
   end if;

   if (l_event_id is not null) then
      l_trx_source_info.application_id        := 140;
      l_trx_source_info.ledger_id             := p_set_of_books_id;
      l_trx_source_info.source_id_int_1       := p_thid ;
      l_trx_source_info.source_id_char_1      := p_book_type_code;
      l_trx_source_info.entity_type_code      := 'TRANSACTIONS';

      -- check the event status

      l_event_status := XLA_EVENTS_PUB_PKG.get_event_status
                        (p_event_source_info            => l_trx_source_info,
                         p_event_id                     => l_event_id,
                         p_valuation_method             => p_book_type_code,
                         p_security_context             => l_security_context);
       if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'event status ', l_event_status,p_log_level_rec => p_log_level_rec);
       end if;

      if l_event_status  = FA_XLA_EVENTS_PVT.C_EVENT_UNPROCESSED then
         if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'deleting unprocessed impairment event',p_thid,p_log_level_rec => p_log_level_rec);
         end if;

         if not fa_xla_events_pvt.delete_transaction_event
              (p_ledger_id             => p_set_of_books_id,
               p_transaction_header_id => p_thid,
               p_book_type_code        => p_book_type_code,
               p_calling_fn            => l_calling_fn
               ,p_log_level_rec => p_log_level_rec) then
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'Failed ','delete_transaction_event',p_log_level_rec => p_log_level_rec);
            end if;
            raise rb_err;
         end if;

         if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'deleted accounting impacts for impairment thid',p_thid,p_log_level_rec => p_log_level_rec);
         end if;

         delete from fa_books
         where transaction_header_id_out is null
           and transaction_header_id_in = p_thid
           and book_type_code = p_book_type_code
           and asset_id = p_asset_id ;

         delete from fa_adjustments
         where  transaction_header_id = p_thid
         and    asset_id = p_asset_id
         and    book_type_code = p_book_type_code
         and    period_counter_created = l_period_rec.period_counter;

         update fa_books
         set date_ineffective = null
           , transaction_header_id_out = null
         where asset_id = p_asset_id
         and   book_type_code = p_book_type_code
         and   transaction_header_id_out = p_thid;

         delete from fa_transaction_headers
         where transaction_header_id = p_thid;

      elsif (l_event_status = XLA_EVENTS_PUB_PKG.C_EVENT_PROCESSED) then
         if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'event already processed need to reverse impairment entries.',p_thid,p_log_level_rec => p_log_level_rec);
         end if;

         if (p_mrc_sob_type_code = 'R') then

            UPDATE FA_TRANSACTION_HEADERS
            SET    ATTRIBUTE15 = ATTRIBUTE15
            WHERE  ASSET_ID = p_asset_id
            AND    BOOK_TYPE_CODE = p_book_type_code
            AND    TRANSACTION_TYPE_CODE = 'ADJUSTMENT'
            AND    TRANSACTION_SUBTYPE = 'AMORTIZED'
            AND    TRANSACTION_KEY = 'IM'
            AND    CALLING_INTERFACE = 'FAPIMP'
            AND    MASS_TRANSACTION_ID = p_request_id
            RETURNING TRANSACTION_HEADER_ID INTO l_thid;
         else
            INSERT INTO FA_TRANSACTION_HEADERS(
                            TRANSACTION_HEADER_ID
                          , BOOK_TYPE_CODE
                          , ASSET_ID
                          , TRANSACTION_TYPE_CODE
                          , TRANSACTION_DATE_ENTERED
                          , DATE_EFFECTIVE
                          , LAST_UPDATE_DATE
                          , LAST_UPDATED_BY
                          , TRANSACTION_SUBTYPE
                          , TRANSACTION_KEY
                          , AMORTIZATION_START_DATE
                          , CALLING_INTERFACE
                          , MASS_TRANSACTION_ID
             ) VALUES (
                            FA_TRANSACTION_HEADERS_S.NEXTVAL
                          , p_book_type_code
                          , p_asset_id
                          , 'ADJUSTMENT'  /*This must be some new transaction */
                          , l_period_rec.calendar_period_open_date /* need to modify to populate correct who info */
                          , sysdate
                          , SYSDATE
                          , fnd_global.user_id
                          , 'AMORTIZED'
                          , 'RM' --8582979
                          , l_period_rec.calendar_period_open_date
                          , 'FAPIMP'
                          , p_request_id ) RETURNING transaction_header_id INTO l_thid;

            --Populate to create event for reversal
            l_trx_source_info.application_id        := 140;
            l_trx_source_info.legal_entity_id       := NULL;
            l_trx_source_info.ledger_id             := 1;
            l_trx_source_info.transaction_number    := to_char(l_thid);
            l_trx_source_info.source_id_int_1       := l_thid;
            l_trx_source_info.source_id_char_1      := p_book_type_code;

            l_rev_event_id := xla_events_pub_pkg.create_event
             (p_event_source_info            => l_trx_source_info,
              p_event_type_code              => 'IMPAIRMENT',
              p_event_date                   => l_period_rec.calendar_period_close_date,
              p_event_status_code            => XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED,
              p_event_number                 => NULL,
              p_reference_info               => NULL,
              p_valuation_method             => p_book_type_code,
              p_security_context             => l_security_context);

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'rolled back IMPAIRMENT event id', l_rev_event_id,p_log_level_rec => p_log_level_rec);
            end if;

            update fa_transaction_headers
                  set event_id = l_rev_event_id
            where transaction_header_id = l_thid;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'Deactivating ', 'FA_BOOKS', p_log_level_rec => p_log_level_rec);
            end if;
         end if;

         if (p_mrc_sob_type_code = 'R') then
            UPDATE FA_MC_BOOKS
               SET    DATE_INEFFECTIVE = sysdate
                    , TRANSACTION_HEADER_ID_OUT = l_thid
            WHERE  ASSET_ID = p_asset_id
            AND    BOOK_TYPE_CODE = p_book_type_code
            AND    TRANSACTION_HEADER_ID_in = p_thid
            AND    TRANSACTION_HEADER_ID_OUT is null
            AND    SET_OF_BOOKS_ID = p_set_of_books_id;
         else
            UPDATE FA_BOOKS
               SET    DATE_INEFFECTIVE = sysdate
                    , TRANSACTION_HEADER_ID_OUT = l_thid
            WHERE  ASSET_ID = p_asset_id
            AND    BOOK_TYPE_CODE = p_book_type_code
            AND    TRANSACTION_HEADER_ID_in = p_thid
            AND    TRANSACTION_HEADER_ID_OUT is null;
         end if;


         if (p_mrc_sob_type_code = 'R') then
            INSERT INTO FA_MC_BOOKS( SET_OF_BOOKS_ID
                                , BOOK_TYPE_CODE
                                , ASSET_ID
                                , DATE_PLACED_IN_SERVICE
                                , DATE_EFFECTIVE
                                , DEPRN_START_DATE
                                , DEPRN_METHOD_CODE
                                , LIFE_IN_MONTHS
                                , RATE_ADJUSTMENT_FACTOR
                                , ADJUSTED_COST
                                , COST
                                , ORIGINAL_COST
                                , SALVAGE_VALUE
                                , PRORATE_CONVENTION_CODE
                                , PRORATE_DATE
                                , COST_CHANGE_FLAG
                                , ADJUSTMENT_REQUIRED_STATUS
                                , CAPITALIZE_FLAG
                                , RETIREMENT_PENDING_FLAG
                                , DEPRECIATE_FLAG
                                , LAST_UPDATE_DATE
                                , LAST_UPDATED_BY
                                , TRANSACTION_HEADER_ID_IN
                                , ITC_AMOUNT_ID
                                , ITC_AMOUNT
                                , RETIREMENT_ID
                                , TAX_REQUEST_ID
                                , ITC_BASIS
                                , BASIC_RATE
                                , ADJUSTED_RATE
                                , BONUS_RULE
                                , CEILING_NAME
                                , RECOVERABLE_COST
                                , ADJUSTED_CAPACITY
                                , FULLY_RSVD_REVALS_COUNTER
                                , IDLED_FLAG
                                , PERIOD_COUNTER_CAPITALIZED
                                , PERIOD_COUNTER_FULLY_RESERVED
                                , PERIOD_COUNTER_FULLY_RETIRED
                                , PRODUCTION_CAPACITY
                                , REVAL_AMORTIZATION_BASIS
                                , REVAL_CEILING
                                , UNIT_OF_MEASURE
                                , UNREVALUED_COST
                                , ANNUAL_DEPRN_ROUNDING_FLAG
                                , PERCENT_SALVAGE_VALUE
                                , ALLOWED_DEPRN_LIMIT
                                , ALLOWED_DEPRN_LIMIT_AMOUNT
                                , PERIOD_COUNTER_LIFE_COMPLETE
                                , ADJUSTED_RECOVERABLE_COST
                                , ANNUAL_ROUNDING_FLAG
                                , GLOBAL_ATTRIBUTE1
                                , GLOBAL_ATTRIBUTE2
                                , GLOBAL_ATTRIBUTE3
                                , GLOBAL_ATTRIBUTE4
                                , GLOBAL_ATTRIBUTE5
                                , GLOBAL_ATTRIBUTE6
                                , GLOBAL_ATTRIBUTE7
                                , GLOBAL_ATTRIBUTE8
                                , GLOBAL_ATTRIBUTE9
                                , GLOBAL_ATTRIBUTE10
                                , GLOBAL_ATTRIBUTE11
                                , GLOBAL_ATTRIBUTE12
                                , GLOBAL_ATTRIBUTE13
                                , GLOBAL_ATTRIBUTE14
                                , GLOBAL_ATTRIBUTE15
                                , GLOBAL_ATTRIBUTE16
                                , GLOBAL_ATTRIBUTE17
                                , GLOBAL_ATTRIBUTE18
                                , GLOBAL_ATTRIBUTE19
                                , GLOBAL_ATTRIBUTE20
                                , GLOBAL_ATTRIBUTE_CATEGORY
                                , EOFY_ADJ_COST
                                , EOFY_FORMULA_FACTOR
                                , SHORT_FISCAL_YEAR_FLAG
                                , CONVERSION_DATE
                                , ORIGINAL_DEPRN_START_DATE
                                , REMAINING_LIFE1
                                , REMAINING_LIFE2
                                , OLD_ADJUSTED_COST
                                , FORMULA_FACTOR
                                , GROUP_ASSET_ID
                                , SALVAGE_TYPE
                                , DEPRN_LIMIT_TYPE
                                , REDUCTION_RATE
                                , REDUCE_ADDITION_FLAG
                                , REDUCE_ADJUSTMENT_FLAG
                                , REDUCE_RETIREMENT_FLAG
                                , RECOGNIZE_GAIN_LOSS
                                , RECAPTURE_RESERVE_FLAG
                                , LIMIT_PROCEEDS_FLAG
                                , TERMINAL_GAIN_LOSS
                                , TRACKING_METHOD
                                , EXCLUDE_FULLY_RSV_FLAG
                                , EXCESS_ALLOCATION_OPTION
                                , DEPRECIATION_OPTION
                                , MEMBER_ROLLUP_FLAG
                                , ALLOCATE_TO_FULLY_RSV_FLAG
                                , ALLOCATE_TO_FULLY_RET_FLAG
                                , TERMINAL_GAIN_LOSS_AMOUNT
                                , CIP_COST
                                , YTD_PROCEEDS
                                , LTD_PROCEEDS
                                , LTD_COST_OF_REMOVAL
                                , EOFY_RESERVE
                                , PRIOR_EOFY_RESERVE
                                , EOP_ADJ_COST
                                , EOP_FORMULA_FACTOR
                                , EXCLUDE_PROCEEDS_FROM_BASIS
                                , RETIREMENT_DEPRN_OPTION
                                , TERMINAL_GAIN_LOSS_FLAG
                                , SUPER_GROUP_ID
                                , OVER_DEPRECIATE_OPTION
                                , DISABLED_FLAG
                                , CASH_GENERATING_UNIT_ID
            ) SELECT SET_OF_BOOKS_ID
                   , BOOK_TYPE_CODE
                   , ASSET_ID
                   , DATE_PLACED_IN_SERVICE
                   , SYSDATE -- DATE_EFFECTIVE
                   , DEPRN_START_DATE
                   , DEPRN_METHOD_CODE
                   , LIFE_IN_MONTHS
                   , RATE_ADJUSTMENT_FACTOR --RATE_ADJUSTMENT_FACTOR
                   , ADJUSTED_COST -- ADJUSTED_COST
                   , COST
                   , ORIGINAL_COST
                   , SALVAGE_VALUE
                   , PRORATE_CONVENTION_CODE
                   , PRORATE_DATE
                   , COST_CHANGE_FLAG
                   , ADJUSTMENT_REQUIRED_STATUS
                   , CAPITALIZE_FLAG
                   , RETIREMENT_PENDING_FLAG
                   , DEPRECIATE_FLAG
                   , sysdate -- LAST_UPDATE_DATE
                   , fnd_global.user_id -- LAST_UPDATED_BY
                   , l_thid -- TRANSACTION_HEADER_ID_IN
                   , ITC_AMOUNT_ID
                   , ITC_AMOUNT
                   , RETIREMENT_ID
                   , TAX_REQUEST_ID
                   , ITC_BASIS
                   , BASIC_RATE
                   , ADJUSTED_RATE
                   , BONUS_RULE
                   , CEILING_NAME
                   , RECOVERABLE_COST
                   , ADJUSTED_CAPACITY
                   , FULLY_RSVD_REVALS_COUNTER
                   , IDLED_FLAG
                   , PERIOD_COUNTER_CAPITALIZED
                   , PERIOD_COUNTER_FULLY_RESERVED
                   , PERIOD_COUNTER_FULLY_RETIRED
                   , PRODUCTION_CAPACITY
                   , REVAL_AMORTIZATION_BASIS
                   , REVAL_CEILING
                   , UNIT_OF_MEASURE
                   , UNREVALUED_COST
                   , ANNUAL_DEPRN_ROUNDING_FLAG
                   , PERCENT_SALVAGE_VALUE
                   , ALLOWED_DEPRN_LIMIT
                   , ALLOWED_DEPRN_LIMIT_AMOUNT
                   , PERIOD_COUNTER_LIFE_COMPLETE
                   , ADJUSTED_RECOVERABLE_COST
                   , ANNUAL_ROUNDING_FLAG
                   , GLOBAL_ATTRIBUTE1
                   , GLOBAL_ATTRIBUTE2
                   , GLOBAL_ATTRIBUTE3
                   , GLOBAL_ATTRIBUTE4
                   , GLOBAL_ATTRIBUTE5
                   , GLOBAL_ATTRIBUTE6
                   , GLOBAL_ATTRIBUTE7
                   , GLOBAL_ATTRIBUTE8
                   , GLOBAL_ATTRIBUTE9
                   , GLOBAL_ATTRIBUTE10
                   , GLOBAL_ATTRIBUTE11
                   , GLOBAL_ATTRIBUTE12
                   , GLOBAL_ATTRIBUTE13
                   , GLOBAL_ATTRIBUTE14
                   , GLOBAL_ATTRIBUTE15
                   , GLOBAL_ATTRIBUTE16
                   , GLOBAL_ATTRIBUTE17
                   , GLOBAL_ATTRIBUTE18
                   , GLOBAL_ATTRIBUTE19
                   , GLOBAL_ATTRIBUTE20
                   , GLOBAL_ATTRIBUTE_CATEGORY
                   , EOFY_ADJ_COST
                   , EOFY_FORMULA_FACTOR
                   , SHORT_FISCAL_YEAR_FLAG
                   , CONVERSION_DATE
                   , ORIGINAL_DEPRN_START_DATE
                   , REMAINING_LIFE1
                   , REMAINING_LIFE2
                   , OLD_ADJUSTED_COST
                   , formula_factor --FORMULA_FACTOR
                   , GROUP_ASSET_ID
                   , SALVAGE_TYPE
                   , DEPRN_LIMIT_TYPE
                   , REDUCTION_RATE
                   , REDUCE_ADDITION_FLAG
                   , REDUCE_ADJUSTMENT_FLAG
                   , REDUCE_RETIREMENT_FLAG
                   , RECOGNIZE_GAIN_LOSS
                   , RECAPTURE_RESERVE_FLAG
                   , LIMIT_PROCEEDS_FLAG
                   , TERMINAL_GAIN_LOSS
                   , TRACKING_METHOD
                   , EXCLUDE_FULLY_RSV_FLAG
                   , EXCESS_ALLOCATION_OPTION
                   , DEPRECIATION_OPTION
                   , MEMBER_ROLLUP_FLAG
                   , ALLOCATE_TO_FULLY_RSV_FLAG
                   , ALLOCATE_TO_FULLY_RET_FLAG
                   , TERMINAL_GAIN_LOSS_AMOUNT
                   , CIP_COST
                   , YTD_PROCEEDS
                   , LTD_PROCEEDS
                   , LTD_COST_OF_REMOVAL
                   , eofy_reserve --EOFY_RESERVE
                   , PRIOR_EOFY_RESERVE
                   , EOP_ADJ_COST
                   , EOP_FORMULA_FACTOR
                   , EXCLUDE_PROCEEDS_FROM_BASIS
                   , RETIREMENT_DEPRN_OPTION
                   , TERMINAL_GAIN_LOSS_FLAG
                   , SUPER_GROUP_ID
                   , OVER_DEPRECIATE_OPTION
                   , DISABLED_FLAG
                   , CASH_GENERATING_UNIT_ID
              FROM  FA_MC_BOOKS
              WHERE TRANSACTION_HEADER_ID_out = p_thid
              AND   SET_OF_BOOKS_ID = p_set_of_books_id ;
         else
            INSERT INTO FA_BOOKS( BOOK_TYPE_CODE
                                , ASSET_ID
                                , DATE_PLACED_IN_SERVICE
                                , DATE_EFFECTIVE
                                , DEPRN_START_DATE
                                , DEPRN_METHOD_CODE
                                , LIFE_IN_MONTHS
                                , RATE_ADJUSTMENT_FACTOR
                                , ADJUSTED_COST
                                , COST
                                , ORIGINAL_COST
                                , SALVAGE_VALUE
                                , PRORATE_CONVENTION_CODE
                                , PRORATE_DATE
                                , COST_CHANGE_FLAG
                                , ADJUSTMENT_REQUIRED_STATUS
                                , CAPITALIZE_FLAG
                                , RETIREMENT_PENDING_FLAG
                                , DEPRECIATE_FLAG
                                , LAST_UPDATE_DATE
                                , LAST_UPDATED_BY
                                , TRANSACTION_HEADER_ID_IN
                                , ITC_AMOUNT_ID
                                , ITC_AMOUNT
                                , RETIREMENT_ID
                                , TAX_REQUEST_ID
                                , ITC_BASIS
                                , BASIC_RATE
                                , ADJUSTED_RATE
                                , BONUS_RULE
                                , CEILING_NAME
                                , RECOVERABLE_COST
                                , ADJUSTED_CAPACITY
                                , FULLY_RSVD_REVALS_COUNTER
                                , IDLED_FLAG
                                , PERIOD_COUNTER_CAPITALIZED
                                , PERIOD_COUNTER_FULLY_RESERVED
                                , PERIOD_COUNTER_FULLY_RETIRED
                                , PRODUCTION_CAPACITY
                                , REVAL_AMORTIZATION_BASIS
                                , REVAL_CEILING
                                , UNIT_OF_MEASURE
                                , UNREVALUED_COST
                                , ANNUAL_DEPRN_ROUNDING_FLAG
                                , PERCENT_SALVAGE_VALUE
                                , ALLOWED_DEPRN_LIMIT
                                , ALLOWED_DEPRN_LIMIT_AMOUNT
                                , PERIOD_COUNTER_LIFE_COMPLETE
                                , ADJUSTED_RECOVERABLE_COST
                                , ANNUAL_ROUNDING_FLAG
                                , GLOBAL_ATTRIBUTE1
                                , GLOBAL_ATTRIBUTE2
                                , GLOBAL_ATTRIBUTE3
                                , GLOBAL_ATTRIBUTE4
                                , GLOBAL_ATTRIBUTE5
                                , GLOBAL_ATTRIBUTE6
                                , GLOBAL_ATTRIBUTE7
                                , GLOBAL_ATTRIBUTE8
                                , GLOBAL_ATTRIBUTE9
                                , GLOBAL_ATTRIBUTE10
                                , GLOBAL_ATTRIBUTE11
                                , GLOBAL_ATTRIBUTE12
                                , GLOBAL_ATTRIBUTE13
                                , GLOBAL_ATTRIBUTE14
                                , GLOBAL_ATTRIBUTE15
                                , GLOBAL_ATTRIBUTE16
                                , GLOBAL_ATTRIBUTE17
                                , GLOBAL_ATTRIBUTE18
                                , GLOBAL_ATTRIBUTE19
                                , GLOBAL_ATTRIBUTE20
                                , GLOBAL_ATTRIBUTE_CATEGORY
                                , EOFY_ADJ_COST
                                , EOFY_FORMULA_FACTOR
                                , SHORT_FISCAL_YEAR_FLAG
                                , CONVERSION_DATE
                                , ORIGINAL_DEPRN_START_DATE
                                , REMAINING_LIFE1
                                , REMAINING_LIFE2
                                , OLD_ADJUSTED_COST
                                , FORMULA_FACTOR
                                , GROUP_ASSET_ID
                                , SALVAGE_TYPE
                                , DEPRN_LIMIT_TYPE
                                , REDUCTION_RATE
                                , REDUCE_ADDITION_FLAG
                                , REDUCE_ADJUSTMENT_FLAG
                                , REDUCE_RETIREMENT_FLAG
                                , RECOGNIZE_GAIN_LOSS
                                , RECAPTURE_RESERVE_FLAG
                                , LIMIT_PROCEEDS_FLAG
                                , TERMINAL_GAIN_LOSS
                                , TRACKING_METHOD
                                , EXCLUDE_FULLY_RSV_FLAG
                                , EXCESS_ALLOCATION_OPTION
                                , DEPRECIATION_OPTION
                                , MEMBER_ROLLUP_FLAG
                                , ALLOCATE_TO_FULLY_RSV_FLAG
                                , ALLOCATE_TO_FULLY_RET_FLAG
                                , TERMINAL_GAIN_LOSS_AMOUNT
                                , CIP_COST
                                , YTD_PROCEEDS
                                , LTD_PROCEEDS
                                , LTD_COST_OF_REMOVAL
                                , EOFY_RESERVE
                                , PRIOR_EOFY_RESERVE
                                , EOP_ADJ_COST
                                , EOP_FORMULA_FACTOR
                                , EXCLUDE_PROCEEDS_FROM_BASIS
                                , RETIREMENT_DEPRN_OPTION
                                , TERMINAL_GAIN_LOSS_FLAG
                                , SUPER_GROUP_ID
                                , OVER_DEPRECIATE_OPTION
                                , DISABLED_FLAG
                                , CASH_GENERATING_UNIT_ID
            ) SELECT BOOK_TYPE_CODE
                   , ASSET_ID
                   , DATE_PLACED_IN_SERVICE
                   , SYSDATE -- DATE_EFFECTIVE
                   , DEPRN_START_DATE
                   , DEPRN_METHOD_CODE
                   , LIFE_IN_MONTHS
                   , RATE_ADJUSTMENT_FACTOR --RATE_ADJUSTMENT_FACTOR
                   , ADJUSTED_COST -- ADJUSTED_COST
                   , COST
                   , ORIGINAL_COST
                   , SALVAGE_VALUE
                   , PRORATE_CONVENTION_CODE
                   , PRORATE_DATE
                   , COST_CHANGE_FLAG
                   , ADJUSTMENT_REQUIRED_STATUS
                   , CAPITALIZE_FLAG
                   , RETIREMENT_PENDING_FLAG
                   , DEPRECIATE_FLAG
                   , sysdate -- LAST_UPDATE_DATE
                   , fnd_global.user_id -- LAST_UPDATED_BY
                   , l_thid -- TRANSACTION_HEADER_ID_IN
                   , ITC_AMOUNT_ID
                   , ITC_AMOUNT
                   , RETIREMENT_ID
                   , TAX_REQUEST_ID
                   , ITC_BASIS
                   , BASIC_RATE
                   , ADJUSTED_RATE
                   , BONUS_RULE
                   , CEILING_NAME
                   , RECOVERABLE_COST
                   , ADJUSTED_CAPACITY
                   , FULLY_RSVD_REVALS_COUNTER
                   , IDLED_FLAG
                   , PERIOD_COUNTER_CAPITALIZED
                   , PERIOD_COUNTER_FULLY_RESERVED
                   , PERIOD_COUNTER_FULLY_RETIRED
                   , PRODUCTION_CAPACITY
                   , REVAL_AMORTIZATION_BASIS
                   , REVAL_CEILING
                   , UNIT_OF_MEASURE
                   , UNREVALUED_COST
                   , ANNUAL_DEPRN_ROUNDING_FLAG
                   , PERCENT_SALVAGE_VALUE
                   , ALLOWED_DEPRN_LIMIT
                   , ALLOWED_DEPRN_LIMIT_AMOUNT
                   , PERIOD_COUNTER_LIFE_COMPLETE
                   , ADJUSTED_RECOVERABLE_COST
                   , ANNUAL_ROUNDING_FLAG
                   , GLOBAL_ATTRIBUTE1
                   , GLOBAL_ATTRIBUTE2
                   , GLOBAL_ATTRIBUTE3
                   , GLOBAL_ATTRIBUTE4
                   , GLOBAL_ATTRIBUTE5
                   , GLOBAL_ATTRIBUTE6
                   , GLOBAL_ATTRIBUTE7
                   , GLOBAL_ATTRIBUTE8
                   , GLOBAL_ATTRIBUTE9
                   , GLOBAL_ATTRIBUTE10
                   , GLOBAL_ATTRIBUTE11
                   , GLOBAL_ATTRIBUTE12
                   , GLOBAL_ATTRIBUTE13
                   , GLOBAL_ATTRIBUTE14
                   , GLOBAL_ATTRIBUTE15
                   , GLOBAL_ATTRIBUTE16
                   , GLOBAL_ATTRIBUTE17
                   , GLOBAL_ATTRIBUTE18
                   , GLOBAL_ATTRIBUTE19
                   , GLOBAL_ATTRIBUTE20
                   , GLOBAL_ATTRIBUTE_CATEGORY
                   , EOFY_ADJ_COST
                   , EOFY_FORMULA_FACTOR
                   , SHORT_FISCAL_YEAR_FLAG
                   , CONVERSION_DATE
                   , ORIGINAL_DEPRN_START_DATE
                   , REMAINING_LIFE1
                   , REMAINING_LIFE2
                   , OLD_ADJUSTED_COST
                   , formula_factor --FORMULA_FACTOR
                   , GROUP_ASSET_ID
                   , SALVAGE_TYPE
                   , DEPRN_LIMIT_TYPE
                   , REDUCTION_RATE
                   , REDUCE_ADDITION_FLAG
                   , REDUCE_ADJUSTMENT_FLAG
                   , REDUCE_RETIREMENT_FLAG
                   , RECOGNIZE_GAIN_LOSS
                   , RECAPTURE_RESERVE_FLAG
                   , LIMIT_PROCEEDS_FLAG
                   , TERMINAL_GAIN_LOSS
                   , TRACKING_METHOD
                   , EXCLUDE_FULLY_RSV_FLAG
                   , EXCESS_ALLOCATION_OPTION
                   , DEPRECIATION_OPTION
                   , MEMBER_ROLLUP_FLAG
                   , ALLOCATE_TO_FULLY_RSV_FLAG
                   , ALLOCATE_TO_FULLY_RET_FLAG
                   , TERMINAL_GAIN_LOSS_AMOUNT
                   , CIP_COST
                   , YTD_PROCEEDS
                   , LTD_PROCEEDS
                   , LTD_COST_OF_REMOVAL
                   , eofy_reserve --EOFY_RESERVE
                   , PRIOR_EOFY_RESERVE
                   , EOP_ADJ_COST
                   , EOP_FORMULA_FACTOR
                   , EXCLUDE_PROCEEDS_FROM_BASIS
                   , RETIREMENT_DEPRN_OPTION
                   , TERMINAL_GAIN_LOSS_FLAG
                   , SUPER_GROUP_ID
                   , OVER_DEPRECIATE_OPTION
                   , DISABLED_FLAG
                   , CASH_GENERATING_UNIT_ID
              FROM  FA_BOOKS
              WHERE TRANSACTION_HEADER_ID_out = p_thid;
            end if;
         if (p_mrc_sob_type_code = 'R') then
            open c_mrc_adjustments(p_thid => p_thid);
         else
             open c_adjustments(p_thid => p_thid);
         end if;

            loop
               if (p_mrc_sob_type_code = 'R') then
                  fetch c_mrc_adjustments
                   into l_adj_row_rec.code_combination_id    ,
                        l_adj_row_rec.distribution_id        ,
                        l_adj_row_rec.debit_credit_flag      ,
                        l_adj_row_rec.adjustment_amount      ,
                        l_adj_row_rec.adjustment_type        ,
                        l_adj_row_rec.source_type_code       ,
                        l_current_units;
               else
                  fetch c_adjustments
                   into l_adj_row_rec.code_combination_id    ,
                        l_adj_row_rec.distribution_id        ,
                        l_adj_row_rec.debit_credit_flag      ,
                        l_adj_row_rec.adjustment_amount      ,
                        l_adj_row_rec.adjustment_type        ,
                        l_adj_row_rec.source_type_code       ,
                        l_current_units;
               end if;

               if (p_mrc_sob_type_code = 'R') then
                  EXIT WHEN c_mrc_adjustments%NOTFOUND;
               else
                  EXIT WHEN c_adjustments%NOTFOUND;
               end if;


               l_adj.transaction_header_id    := l_thid;
               l_adj.asset_id                 := p_asset_id;
               l_adj.book_type_code           := p_book_type_code;
               l_adj.period_counter_created   := l_period_rec.period_counter;
               l_adj.period_counter_adjusted  := l_period_rec.period_counter;
               l_adj.current_units            := l_current_units;
               l_adj.selection_mode           := FA_ADJUST_TYPE_PKG.FA_AJ_SINGLE;
               l_adj.selection_thid           := 0;
               l_adj.selection_retid          := 0;
               l_adj.leveling_flag            := FALSE;
               l_adj.last_update_date         := sysdate ; --px_trans_rec.who_info.last_update_date;

               l_adj.gen_ccid_flag            := FALSE;
               l_adj.annualized_adjustment    := 0;
               l_adj.asset_invoice_id         := 0;
               l_adj.code_combination_id      := l_adj_row_rec.code_combination_id;
               l_adj.distribution_id          := l_adj_row_rec.distribution_id;

               l_adj.adjustment_amount        := l_adj_row_rec.adjustment_amount;
               l_adj.flush_adj_flag           := FALSE;
               l_adj.adjustment_type          := l_adj_row_rec.adjustment_type;
               l_adj.source_type_code         := l_adj_row_rec.source_type_code;
               l_adj.set_of_books_id := p_set_of_books_id; -- RER12
               if (l_adj_row_rec.debit_credit_flag = 'DR') then
                  l_adj.debit_credit_flag     := 'CR';
               else
                  l_adj.debit_credit_flag     := 'DR';
               end if;

               l_adj.account                  := NULL;

               if (l_adj_row_rec.adjustment_type = 'IMPAIR RESERVE') then
                  l_adj.account_type             := 'IMPAIR_RESERVE_ACCT';
               elsif (l_adj_row_rec.adjustment_type = 'IMPAIR EXPENSE') then
                  l_adj.account_type             := 'IMPAIR_EXPENSE_ACCT';
               elsif (l_adj_row_rec.adjustment_type = 'REVAL RESERVE') then
                  l_adj.account_type             := 'REVAL_RESERVE_ACCT';
               elsif (l_adj_row_rec.adjustment_type = 'CAPITAL ADJ') then
                  l_adj.account_type             := 'CAPITAL_ADJ_ACCT';
               elsif (l_adj_row_rec.adjustment_type = 'GENERAL FUND') then
                  l_adj.account_type             := 'GENERAL_FUND_ACCT';
               end if;

               l_adj.mrc_sob_type_code        := p_mrc_sob_type_code;

               if not FA_INS_ADJUST_PKG.faxinaj
                        (l_adj,
                         sysdate,
                         l_login_id,
                         l_login_id
                         ,p_log_level_rec => p_log_level_rec) then
                  raise rb_err;
               end if;

            end loop;
            -- now flush the rows to db
            l_adj.transaction_header_id := 0;
            l_adj.flush_adj_flag        := TRUE;
            l_adj.leveling_flag         := TRUE;

            if not FA_INS_ADJUST_PKG.faxinaj
                     (l_adj,
                      sysdate,
                      l_login_id,
                      l_login_id
                      ,p_log_level_rec => p_log_level_rec) then
               raise rb_err;
            end if;

            if (p_mrc_sob_type_code = 'R') then
              close c_mrc_adjustments;
            else
              close c_adjustments;
            end if;
      /* not sure whether we need to update event_id to null for impairment transaction if event is already processed.*/

      end if;--Event status
   elsif (l_event_id is null and p_mrc_sob_type_code = 'R') then
         /*if event is already deleted for primary currency,this block will execute for reporting currency */
         delete from fa_mc_books
         where transaction_header_id_out is null
           and transaction_header_id_in = p_thid
           and book_type_code = p_book_type_code
           and asset_id = p_asset_id
           and set_of_books_id = p_set_of_books_id;

         delete from fa_mc_adjustments
         where  transaction_header_id = p_thid
         and    asset_id = p_asset_id
         and    book_type_code = p_book_type_code
         and    period_counter_created = l_period_rec.period_counter
         and    set_of_books_id = p_set_of_books_id;

         update fa_mc_books
         set date_ineffective = null
           , transaction_header_id_out = null
         where asset_id = p_asset_id
         and   book_type_code = p_book_type_code
         and   transaction_header_id_out = p_thid
         and   set_of_books_id = p_set_of_books_id;

   end if;-- Event id not null
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'rollback_impair_event ','Ends',p_log_level_rec => p_log_level_rec);
   end if;
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
End rollback_impair_event;

END FA_IMPAIRMENT_DELETE_PVT;

/
