--------------------------------------------------------
--  DDL for Package Body FA_DEPRN_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_DEPRN_EVENTS_PKG" as
/* $Header: fadpevnb.pls 120.13.12010000.6 2009/07/19 11:02:22 glchen ship $   */

g_log_level_rec fa_api_types.log_level_rec_type;

PROCEDURE process_deprn_events
           (p_book_type_code varchar2,
            p_period_counter number,
            p_total_requests NUMBER,
            p_request_number NUMBER,
            x_return_status  OUT NOCOPY number) IS

  l_asset_id_tbl FA_XLA_EVENTS_PVT.number_tbl_type;
  l_rowid_tbl    rowid_tbl_type;
  l_event_id_tbl FA_XLA_EVENTS_PVT.number_tbl_type;
  l_event_date   date;

  l_sob_index    number;
  l_sob_tbl      fa_cache_pkg.fazcrsob_sob_tbl_type;

  l_batch_size   number;
  l_calling_fn   varchar2(60) := 'FA_DEPRN_EVENTS_PKG.process_deprn_events';

  error_found exception;

  CURSOR DEPRN_EVENTS (p_book_type_code varchar2,
                       p_period_counter number
) IS
  select rowid,
         asset_id
    from fa_deprn_summary
   where book_type_code = p_book_type_code
     and period_counter = p_period_counter
     and event_id      is null
     and (deprn_amount - deprn_adjustment_amount <> 0 or
          reval_amortization <> 0)
     and MOD(asset_id, p_total_requests) = (p_request_number - 1)
     and deprn_source_code        <> 'TRACK';

  CURSOR MC_DEPRN_EVENTS (p_set_of_books_id number,
                          p_book_type_code  varchar2,
                          p_period_counter  number
) IS
  select rowid,
         asset_id
    from fa_mc_deprn_summary
   where set_of_books_id = p_set_of_books_id
     and book_type_code  = p_book_type_code
     and period_counter  = p_period_counter
     and event_id       is null
     and (deprn_amount - deprn_adjustment_amount <> 0 or
          reval_amortization <> 0)
     and MOD(asset_id, p_total_requests) = (p_request_number - 1)
     and deprn_source_code        <> 'TRACK';

   l_deprn_run_id number;

BEGIN

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise error_found;
      end if;
   end if;


   -- clear the debug stack for each line
   FA_DEBUG_PKG.Initialize;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'at ', 'begin' ,p_log_level_rec => g_log_level_rec);
   end if;

   if not fa_cache_pkg.fazcbc(X_book => p_book_type_code,
                              p_log_level_rec => g_log_level_rec) then
      raise error_found;
   end if;

   if not fa_cache_pkg.fazcdp(x_book_type_code  => p_book_type_code,
                              x_period_counter  => p_period_counter,
                              x_effective_date  => null,
                              p_log_level_rec => g_log_level_rec) then
      raise error_found;
   end if;


   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'setting ', 'batch size',
                       p_log_level_rec => g_log_level_rec);
   end if;

   l_batch_size := nvl(fa_cache_pkg.fa_batch_size, 200);

   select fa_deprn_summary_s.nextval
     into l_deprn_run_id
     from dual;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'initializing', 'debug stack',
                       p_log_level_rec => g_log_level_rec);
   end if;



   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'opening', 'deprn_events cursor',
                       p_log_level_rec => g_log_level_rec);
   end if;


   OPEN deprn_events(p_book_type_code  => p_book_type_code,
                     p_period_counter  => p_period_counter);


   loop

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'in', 'loop',
                          p_log_level_rec => g_log_level_rec);
      end if;

      FETCH deprn_events bulk collect
       into l_rowid_tbl,
            l_asset_id_tbl
      LIMIT l_batch_size;



      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'l_asset_id_tbl.count', l_asset_id_tbl.count,
                          p_log_level_rec => g_log_level_rec);
      end if;

      if (l_asset_id_tbl.count = 0) then
         exit;
      end if;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'calling', 'xla event api',
                          p_log_level_rec => g_log_level_rec);
      end if;

      l_event_date :=
         greatest(fa_cache_pkg.fazcdp_record.calendar_period_open_date,
                  least(nvl(fa_cache_pkg.fazcdp_record.calendar_period_close_date,
                            sysdate),
                        sysdate));


      fa_xla_events_pvt.create_bulk_deprn_event
           (p_asset_id_tbl      => l_asset_id_tbl,
            p_book_type_code    => p_book_type_code,
            p_period_counter    => p_period_counter,
            p_period_close_date => l_event_date,
            p_deprn_run_id      => l_deprn_run_id,
            p_entity_type_code  => 'DEPRECIATION',
            x_event_id_tbl      => l_event_id_tbl,
            p_calling_fn        => l_calling_fn,
            p_log_level_rec     => g_log_level_rec);

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'performing', 'bulk update - primary',
                          p_log_level_rec => g_log_level_rec);
      end if;

      FORALL l_count in 1..l_asset_id_tbl.count
       UPDATE FA_DEPRN_SUMMARY
          SET event_id     = l_event_id_tbl(l_count),
              deprn_run_id = l_deprn_run_id
        WHERE rowid        = l_rowid_tbl(l_count);


      FORALL l_count in 1..l_asset_id_tbl.count
       UPDATE FA_DEPRN_DETAIL
          SET event_id       = l_event_id_tbl(l_count),
              deprn_run_id   = l_deprn_run_id
        WHERE asset_id       = l_asset_id_tbl(l_count)
          AND book_type_code = p_book_type_code
          AND period_counter = p_period_counter;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'performing', 'bulk update - reporting',
                          p_log_level_rec => g_log_level_rec);
      end if;

      -- now process all matching mrc rows
      FORALL l_count in 1..l_asset_id_tbl.count
       UPDATE FA_MC_DEPRN_SUMMARY
          SET event_id       = l_event_id_tbl(l_count),
              deprn_run_id   = l_deprn_run_id
        WHERE asset_id       = l_asset_id_tbl(l_count)
          AND book_type_code = p_book_type_code
          AND period_counter = p_period_counter;


      FORALL l_count in 1..l_asset_id_tbl.count
       UPDATE FA_MC_DEPRN_DETAIL
          SET event_id       = l_event_id_tbl(l_count),
              deprn_run_id   = l_deprn_run_id
        WHERE asset_id       = l_asset_id_tbl(l_count)
          AND book_type_code = p_book_type_code
          AND period_counter = p_period_counter;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'done', 'bulk updates',
                          p_log_level_rec => g_log_level_rec);
      end if;

      FORALL l_count in 1..l_asset_id_tbl.count
      INSERT into fa_deprn_events
          (asset_id            ,
           book_type_code      ,
           period_counter      ,
           deprn_run_id        ,
           deprn_run_date      ,
           event_id            ,
           reversal_event_id
           )
       VALUES
          (l_asset_id_tbl(l_count),
           p_book_type_code,
           p_period_counter,
           l_deprn_run_id,
           sysdate,
           l_event_id_tbl(l_count),
           null);

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'done', 'bulk insert',
                          p_log_level_rec => g_log_level_rec);
      end if;

      commit;

   end loop;

   CLOSE deprn_events;

   -- now find any mrc rows which are not processed yet and update
   if not FA_CACHE_PKG.fazcrsob
          (x_book_type_code => p_book_type_code,
           x_sob_tbl        => l_sob_tbl,
           p_log_level_rec => g_log_level_rec) then
      raise error_found;
   end if;


   -- begin at index of 1 not 0 as in apis
   FOR l_sob_index in 1..l_sob_tbl.count LOOP

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'opening mc_deprn_events for sob', l_sob_tbl(l_sob_index),
                          p_log_level_rec => g_log_level_rec);
      end if;

      OPEN mc_deprn_events(p_set_of_books_id => l_sob_tbl(l_sob_index),
                           p_book_type_code  => p_book_type_code,
                           p_period_counter  => p_period_counter);

      loop

 	     if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'in', 'mrc loop',
                             p_log_level_rec => g_log_level_rec);
         end if;

         FETCH mc_deprn_events bulk collect
          into l_rowid_tbl,
               l_asset_id_tbl
         LIMIT l_batch_size;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'l_asset_id_tbl.count', l_asset_id_tbl.count,
                             p_log_level_rec => g_log_level_rec);
         end if;

         if (l_asset_id_tbl.count = 0) then
            exit;
         end if;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'calling', 'xla event api',
                             p_log_level_rec => g_log_level_rec);
         end if;

         fa_xla_events_pvt.create_bulk_deprn_event
              (p_asset_id_tbl      => l_asset_id_tbl,
               p_book_type_code    => p_book_type_code,
               p_period_counter    => p_period_counter,
               p_period_close_date => sysdate,         -- fa_cache_pkg.fazcdp_record.period_close_date,
               p_deprn_run_id      => l_deprn_run_id,
               p_entity_type_code  => 'DEPRECIATION',
               x_event_id_tbl      => l_event_id_tbl,
               p_calling_fn        => l_calling_fn,
               p_log_level_rec     => g_log_level_rec);

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'performing', 'bulk update - reporting1',
                             p_log_level_rec => g_log_level_rec);
         end if;

         FORALL l_count in 1..l_asset_id_tbl.count
         UPDATE FA_MC_DEPRN_SUMMARY
            SET event_id     = l_event_id_tbl(l_count),
                deprn_run_id = l_deprn_run_id
          WHERE rowid        = l_rowid_tbl(l_count);


         FORALL l_count in 1..l_asset_id_tbl.count
         UPDATE FA_MC_DEPRN_DETAIL
            SET event_id       = l_event_id_tbl(l_count),
                deprn_run_id   = l_deprn_run_id
          WHERE asset_id       = l_asset_id_tbl(l_count)
            AND book_type_code = p_book_type_code
            AND period_counter = p_period_counter;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'performing', 'bulk update - reporting2',
                             p_log_level_rec => g_log_level_rec);
         end if;

         -- now process all matching mrc rows for summary
         FORALL l_count in 1..l_asset_id_tbl.count
         UPDATE FA_MC_DEPRN_SUMMARY
            SET event_id         = l_event_id_tbl(l_count),
                deprn_run_id     = l_deprn_run_id
          WHERE set_of_books_id <> l_sob_tbl(l_sob_index)
            AND asset_id         = l_asset_id_tbl(l_count)
            AND book_type_code   = p_book_type_code
            AND period_counter   = p_period_counter;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'done', 'mc bulk updates',
                             p_log_level_rec => g_log_level_rec);
         end if;

         FORALL l_count in 1..l_asset_id_tbl.count
         INSERT into fa_deprn_events
             (asset_id            ,
              book_type_code      ,
              period_counter      ,
              deprn_run_id        ,
              deprn_run_date      ,
              event_id            ,
              reversal_event_id
              )
          VALUES
             (l_asset_id_tbl(l_count),
              p_book_type_code,
              p_period_counter,
              l_deprn_run_id,
              sysdate,
              l_event_id_tbl(l_count),
              null);

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'done', 'bulk insert',
                             p_log_level_rec => g_log_level_rec);
         end if;


      end loop;

      commit;

      CLOSE mc_deprn_events;

   END LOOP; -- sob loop

   -- Bug 6391045
   -- Code hook for IAC

   if (FA_IGI_EXT_PKG.IAC_Enabled) then
       if not FA_IGI_EXT_PKG.Do_Depreciation(
	 p_book_type_code   =>  p_book_type_code,
	 p_period_counter    =>  p_period_counter,
	 p_calling_function  =>  l_calling_fn ) then
	raise error_found;
      end if;
   end if; -- (FA_IGI_EXT_PKG.IAC_Enabled)

   x_return_status := 0;

EXCEPTION
  WHEN error_found THEN
       fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                               p_log_level_rec => g_log_level_rec);
       x_return_status := 2;

       commit;

       raise;

  WHEN OTHERS THEN
       fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn,
                                 p_log_level_rec => g_log_level_rec);
       x_return_status := 2;

       commit;

       raise;


END process_deprn_events;

--------------------------------------------------------------------------------

END FA_DEPRN_EVENTS_PKG;

/
