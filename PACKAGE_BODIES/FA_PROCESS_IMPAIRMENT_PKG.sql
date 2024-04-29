--------------------------------------------------------
--  DDL for Package Body FA_PROCESS_IMPAIRMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_PROCESS_IMPAIRMENT_PKG" AS
/* $Header: FAPIMPB.pls 120.9.12010000.3 2009/09/11 09:14:43 gigupta noship $ */

g_log_level_rec fa_api_types.log_level_rec_type;
g_release                  number  := fa_cache_pkg.fazarel_release; /*Bug# 8394781- */

--*********************** Private functions ******************************--
FUNCTION assign_workers (p_request_id        IN NUMBER,
                         p_book_type_code    IN VARCHAR2,
                         p_total_requests    IN NUMBER,
                         p_period_rec        IN FA_API_TYPES.period_rec_type,
                         p_prev_sysdate      IN DATE,
                         p_login_id          IN NUMBER,
                         p_transaction_date  IN DATE,
                         p_set_of_books_id   In NUMBER,
                         p_mrc_sob_type_code IN VARCHAR2,
                         p_calling_fn        IN VARCHAR2) RETURN BOOLEAN;

FUNCTION check_je_post (p_book_type_code    IN VARCHAR2,
                        p_period_rec        IN FA_API_TYPES.period_rec_type,
                        p_mrc_sob_type_code IN VARCHAR2,
                        p_set_of_books_id   In NUMBER,
                        p_calling_fn        IN VARCHAR2)
RETURN BOOLEAN;

FUNCTION rollback_impairment (p_book_type_code    IN VARCHAR2,
                              p_request_id        IN NUMBER,
                              p_mode              IN VARCHAR2,
                              p_impairment_id     IN NUMBER,
                              p_calling_fn        IN VARCHAR2,
                              p_mrc_sob_type_code IN VARCHAR2,
                              p_set_of_books_id   In NUMBER) /* Bug 6437003 added p_mrc_sob_type_code to check for  Set of Books type */
RETURN BOOLEAN;


PROCEDURE process_impairments(
                errbuf                  OUT NOCOPY VARCHAR2,
                retcode                 OUT NOCOPY NUMBER,
                p_book_type_code        IN         VARCHAR2,
                p_mode                  IN         VARCHAR2,
                p_impairment_id         IN         NUMBER DEFAULT NULL,
                p_parent_request_id     IN         NUMBER DEFAULT NULL,
                p_total_requests        IN         NUMBER DEFAULT NULL,
                p_request_number        IN         NUMBER DEFAULT NULL,
                p_set_of_books_id       IN         NUMBER DEFAULT NULL,
                p_mrc_sob_type_code     IN         VARCHAR2 DEFAULT NULL) IS
   l_calling_fn   varchar2(60) := 'fa_process_impairment_pkg.process_impairment';
   l_calling_fn2  varchar2(60) := 'process_impairment';

   l_nls_lang         varchar2(255);
   l_iso_lang         varchar2(255);
   l_iso_territory    varchar2(255);

   CURSOR c_get_nls_lang is
      select value
      from   v$nls_parameters
     where parameter = 'NLS_LANGUAGE';

   CURSOR c_get_iso_values is
      select ISO_LANGUAGE
           , ISO_TERRITORY
      from   fnd_languages
      where  NLS_LANGUAGE = l_nls_lang;

   l_transaction_date  date;

   l_set_of_books_id NUMBER;
   --
   -- Get period information for impairment date
   --
   CURSOR c_get_period_rec IS
     select fy.fiscal_year * ct.NUMBER_PER_FISCAL_YEAR + cp.PERIOD_NUM period_counter
          , cp.start_date calendar_period_open_date
          , cp.end_date calendar_period_close_date
          , cp.period_num period_num
          , fy.fiscal_year fiscal_year
     from   fa_book_controls bc
          , fa_fiscal_year fy
          , fa_calendar_types ct
          , fa_calendar_periods cp
     where  bc.book_type_code = p_book_type_code
     and    bc.deprn_calendar = ct.calendar_type
     and    bc.fiscal_year_name = fy.fiscal_year_name
     and    ct.fiscal_year_name = bc.fiscal_year_name
     and    ct.calendar_type = cp.calendar_type
     and    cp.start_date between fy.start_date and fy.end_date
     and    bc.last_period_counter + 1 >= fy.fiscal_year * ct.NUMBER_PER_FISCAL_YEAR + cp.PERIOD_NUM
     and    l_transaction_date between cp.start_date and cp.end_date;

   CURSOR c_get_mc_period_rec IS
     select fy.fiscal_year * ct.NUMBER_PER_FISCAL_YEAR + cp.PERIOD_NUM period_counter
          , cp.start_date calendar_period_open_date
          , cp.end_date calendar_period_close_date
          , cp.period_num period_num
          , fy.fiscal_year fiscal_year
     from   fa_book_controls bc
          , fa_mc_book_controls mbc
          , fa_fiscal_year fy
          , fa_calendar_types ct
          , fa_calendar_periods cp
     where  bc.book_type_code = p_book_type_code
     and    mbc.book_type_code = p_book_type_code
     and    mbc.set_of_books_id = l_set_of_books_id
     and    bc.deprn_calendar = ct.calendar_type
     and    bc.fiscal_year_name = fy.fiscal_year_name
     and    ct.fiscal_year_name = bc.fiscal_year_name
     and    ct.calendar_type = cp.calendar_type
     and    cp.start_date between fy.start_date and fy.end_date
     and    bc.last_period_counter + 1 >= fy.fiscal_year * ct.NUMBER_PER_FISCAL_YEAR + cp.PERIOD_NUM
     and    l_transaction_date between cp.start_date and cp.end_date;


   TYPE tab_num15_type IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
   TYPE tab_date_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;

   l_rbs_name       VARCHAR2(30);
   l_sql_stmt       varchar2(101);

   l_msg_count      NUMBER := 0;
   l_msg_data       VARCHAR2(2000) := NULL;

   l_sob_tbl        FA_CACHE_PKG.fazcrsob_sob_tbl_type;
   l_total_requests BINARY_INTEGER;
   t_request_id     tab_num15_type;
   l_request_id     number(15);
   l_internal_mode  VARCHAR2(30);
   l_mrc_sob_type_code VARCHAR2(1);

   l_period_rec     FA_API_TYPES.period_rec_type;
   l_imp_period_rec FA_API_TYPES.period_rec_type;
   t_imp_date       tab_date_type;

   l_sysdate        date := sysdate;
   l_login_id       number(15) := fnd_global.user_id;

   l_phase          VARCHAR2(80);
   l_status         VARCHAR2(80);
   l_dev_phase      VARCHAR2(15);
   l_dev_status     VARCHAR2(30);
   l_message        VARCHAR2(240);


   l_temp_char      VARCHAR2(30);

   l_return_code    BOOLEAN;
   l_primary_sob    NUMBER(15);
   l_request_id2    NUMBER(15);

   l_new_count      NUMBER;

   imp_err      exception;

   l_temp   number;
   l_asset_id FA_IMPAIRMENT_PREV_PVT.tab_num_type;  -- Bug# 7000391
   l_nbv_value FA_IMPAIRMENT_PREV_PVT.tab_num_type;  -- Bug# 7000391
   l_ret_code number; -- Bug# 7000391

   /*Bug# 8394781- */
   CURSOR c_get_asset_id(c_request_id number,c_period_counter number) IS
     select asset_id
     from fa_impairments imp
     where imp.book_type_code = p_book_type_code
     and   imp.request_id = c_request_id
     and   imp.asset_id is not null
     and not exists
     (select 'POSTED'
        from   fa_impairments imp2
        where  status = 'POSTED'
        and    imp2.asset_id  = imp.asset_id
        and    imp2.book_type_code = p_book_type_code
        AND PERIOD_COUNTER_IMPAIRED = c_period_counter )
     UNION
     select bk.asset_id
     from fa_impairments imp,
          fa_books bk
     where bk.cash_generating_unit_id = imp.cash_generating_unit_id
     and bk.book_type_code = imp.book_type_code
     and imp.book_type_code = p_book_type_code
     and imp.request_id = c_request_id
     and imp .asset_id is null
     and not exists
     (select 'POSTED'
        from   fa_impairments imp2
        where  status = 'POSTED'
        and    imp2.cash_generating_unit_id  = imp.cash_generating_unit_id
        and    imp2.book_type_code = p_book_type_code
        and    PERIOD_COUNTER_IMPAIRED = c_period_counter );

   -- variables for deprn rollback
   l_return_status             VARCHAR2(1);
   l_deprn_run                 boolean := false;
   l_asset_hdr_rec             FA_API_TYPES.asset_hdr_rec_type;
   /*Bug# 8394781 - */
   x_return_status number := 0; --8666930

BEGIN

   -- set rollback segment if profile option is set
   fnd_profile.get('FA_LARGE_ROLLBACK_SEGMENT', l_rbs_name);

   if (l_rbs_name is not null) THEN
      l_sql_stmt := 'SET TRANSACTION USE ROLLBACK SEGMENT ' || l_rbs_name;
      execute immediate l_sql_stmt;
   end if;


   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise imp_err;
      end if;
   end if;

   fa_srvr_msg.Init_Server_Message; -- Initialize server message stack
   fa_debug_pkg.Initialize;         -- Initialize debug message stack

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'process_impairment', 'BEGIN', p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_book_type_code', p_book_type_code, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_mode', p_mode, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_impairment_id', p_impairment_id, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_parent_request_id', p_parent_request_id, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_total_requests', p_total_requests, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_request_number', p_request_number, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_set_of_books_id', p_set_of_books_id, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_mrc_sob_type_code', p_mrc_sob_type_code, p_log_level_rec => g_log_level_rec);
   end if;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add('set_rollback_seg','Rollback Segment is', l_rbs_name, p_log_level_rec => g_log_level_rec);
   end if;

   l_request_id := fnd_global.conc_request_id;
   -- Bug 7651572: Initialize  l_mrc_sob_type_code in case we call imp_err
   l_mrc_sob_type_code := p_mrc_sob_type_code; -- Bug 7651572

   if (p_parent_request_id is null) or (l_request_id = -1)
or (p_mode = 'PREVIEW')
then
      --
      -- PARENT or STANDALONE
      --

      if p_mode = 'PREVIEW' then
         l_internal_mode := 'RUNNING DEPRN';
      elsif p_mode = 'POST' or
            p_impairment_id is not null then
         l_internal_mode := 'RUNNING POST';
      elsif p_mode = 'ROLLBACK' then
         l_internal_mode := 'DELETING POST';
      else
         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'Wrong mode', p_mode, p_log_level_rec => g_log_level_rec);
            fa_debug_pkg.add(l_calling_fn,'impairment_id', p_impairment_id, p_log_level_rec => g_log_level_rec);
         end if;

      end if;

      fnd_profile.get('FA_NUM_PARALLEL_REQUESTS', l_temp_char);
      l_total_requests := nvl(l_temp_char, 1);

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'Total Requests', l_total_requests, p_log_level_rec => g_log_level_rec);
      end if;

      if not FA_CACHE_PKG.fazcbc(X_book => p_book_type_code, p_log_level_rec => g_log_level_rec) then
         raise imp_err;
      end if;

      l_primary_sob := fa_cache_pkg.fazcbc_record.set_of_books_id;
         fa_debug_pkg.add(l_calling_fn,'Total l_primary_sob', l_primary_sob, p_log_level_rec => g_log_level_rec);

      -- call the sob cache to get the table of sob_ids
      if not FA_CACHE_PKG.fazcrsob(
                     x_book_type_code => p_book_type_code,
                     x_sob_tbl        => l_sob_tbl, p_log_level_rec => g_log_level_rec) then
         raise imp_err;
      end if;

      if not FA_UTIL_PVT.get_period_rec(
                              p_book           => p_book_type_code,
                              p_effective_date => NULL,
                              x_period_rec     => l_period_rec, p_log_level_rec => g_log_level_rec) then
         raise imp_err;
      end if;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'l_period_rec.period_counter', l_period_rec.period_counter, p_log_level_rec => g_log_level_rec);
      end if;

      if p_impairment_id is null then
         UPDATE FA_IMPAIRMENTS imp
         SET    imp.STATUS     = l_internal_mode
              , imp.REQUEST_ID = l_request_id
              , imp.PERIOD_COUNTER_IMPAIRED =
                          (select nvl(imp.PERIOD_COUNTER_IMPAIRED,
                                      fy.fiscal_year * ct.NUMBER_PER_FISCAL_YEAR + cp.PERIOD_NUM)
                           from   fa_fiscal_year fy
                                , fa_calendar_types ct
                                , fa_calendar_periods cp
                           where  fa_cache_pkg.fazcbc_record.deprn_calendar = ct.calendar_type
                           and    fa_cache_pkg.fazcbc_record.fiscal_year_name = fy.fiscal_year_name
                           and    ct.fiscal_year_name = fa_cache_pkg.fazcbc_record.fiscal_year_name
                           and    ct.calendar_type = cp.calendar_type
                           and    cp.start_date between fy.start_date and fy.end_date
                           and    fa_cache_pkg.fazcbc_record.last_period_counter + 1 >=
                                                       fy.fiscal_year * ct.NUMBER_PER_FISCAL_YEAR + cp.PERIOD_NUM
                           and    imp.impairment_date between cp.start_date and cp.end_date)
         WHERE  imp.STATUS     = p_mode
         -- Bug#7264536 - To handle situation when impairment is posted simultaneously for different books
         AND    imp.BOOK_TYPE_CODE = p_book_type_code
         RETURNING imp.IMPAIRMENT_DATE BULK COLLECT INTO t_imp_date;
      else
         UPDATE FA_IMPAIRMENTS imp
         SET    imp.STATUS     = l_internal_mode
              , imp.REQUEST_ID = l_request_id
              , imp.PERIOD_COUNTER_IMPAIRED =
                          (select nvl(imp.PERIOD_COUNTER_IMPAIRED,
                                      fy.fiscal_year * ct.NUMBER_PER_FISCAL_YEAR + cp.PERIOD_NUM)
                           from   fa_fiscal_year fy
                                , fa_calendar_types ct
                                , fa_calendar_periods cp
                           where  fa_cache_pkg.fazcbc_record.deprn_calendar = ct.calendar_type
                           and    fa_cache_pkg.fazcbc_record.fiscal_year_name = fy.fiscal_year_name
                           and    ct.fiscal_year_name = fa_cache_pkg.fazcbc_record.fiscal_year_name
                           and    ct.calendar_type = cp.calendar_type
                           and    cp.start_date between fy.start_date and fy.end_date
                           and    fa_cache_pkg.fazcbc_record.last_period_counter + 1 >=
                                                       fy.fiscal_year * ct.NUMBER_PER_FISCAL_YEAR + cp.PERIOD_NUM
                           and    imp.impairment_date between cp.start_date and cp.end_date)
         WHERE  imp.impairment_id = p_impairment_id
         RETURNING imp.IMPAIRMENT_DATE BULK COLLECT INTO t_imp_date;
      end if;

      if sql%rowcount = 0 and
         p_mode = 'PREVIEW' then

         SELECT count(IMPAIRMENT_ID)
         INTO   l_new_count
         FROM   FA_IMPAIRMENTS
         WHERE  STATUS     = 'NEW'
         AND    REQUEST_ID is null;

         --
         -- Check to see this user is just creating NEW impairment or not
         if l_new_count > 0 then

            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'This must be New impairment', 'No process required', p_log_level_rec => g_log_level_rec);
            end if;

            -- Dump Debug messages when run in debug mode to log file
            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.Write_Debug_Log;
            end if;

            fa_srvr_msg.add_message(
                               calling_fn => l_calling_fn,
                               name       => 'FA_SHARED_END_SUCCESS',
                               token1     => 'PROGRAM',
                               value1     => 'FAPIMP', p_log_level_rec => g_log_level_rec);

            fa_srvr_msg.Write_Msg_Log(1, null, p_log_level_rec => g_log_level_rec);

            -- Program needs to finish successfully even though there was nothing to do
            -- return success to concurrent manager
            retcode := 0;

            return;
         else
            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'No impairment to post', 'Check Impairment', p_log_level_rec => g_log_level_rec);
            end if;

            raise imp_err;
         end if;

      elsif sql%rowcount = 0 then
         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'No impairment to post', 'Check Impairment', p_log_level_rec => g_log_level_rec);
         end if;

         raise imp_err;
      end if;


      COMMIT;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'Number of sob', l_sob_tbl.count, p_log_level_rec => g_log_level_rec);
      end if;
      /*Bug#8590767 */
      if FA_IGI_EXT_PKG.IAC_Enabled then
         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'IAC is enabled..','Checking book is IAC enabled or not.', p_log_level_rec => g_log_level_rec);
         end if;
         /*Bug# 8887223 - to check if book is IAC enabled. */
         if IGI_IAC_COMMON_UTILS.is_iac_book(p_book_type_code) then
            fa_srvr_msg.add_message(
                calling_fn => l_calling_fn,
                name       => 'FA_IMPAIR_IAC_ENABLED',
                p_log_level_rec => g_log_level_rec);
            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'Failed...IAC Enabled','TRUE', p_log_level_rec => g_log_level_rec);
            end if;
            raise imp_err;
         end if;
      end if;

      FOR l_sob_index in 0..l_sob_tbl.count LOOP -- sob loop

         l_transaction_date  := nvl(t_imp_date(1), greatest(l_period_rec.calendar_period_open_date,
                                      least(trunc(sysdate),
                                            l_period_rec.calendar_period_close_date))) ;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'Current Period', l_period_rec.period_name, p_log_level_rec => g_log_level_rec);
         end if;

         if (l_sob_index = 0) then
            l_mrc_sob_type_code := 'P';
            l_set_of_books_id := l_primary_sob ;
            if l_transaction_date < l_period_rec.calendar_period_open_date then
               OPEN c_get_period_rec;
               FETCH c_get_period_rec INTO l_imp_period_rec.period_counter
                                         , l_imp_period_rec.calendar_period_open_date
                                         , l_imp_period_rec.calendar_period_close_date
                                         , l_imp_period_rec.period_num
                                         , l_imp_period_rec.fiscal_year;
               CLOSE c_get_period_rec;
            else
               l_imp_period_rec := l_period_rec;
            end if;
         else
            l_mrc_sob_type_code := 'R';
            l_set_of_books_id := l_sob_tbl(l_sob_index);

         end if;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'l_set_of_books_id', l_set_of_books_id, p_log_level_rec => g_log_level_rec);
         end if;

         if p_mode = 'PREVIEW' then

            --Bug#7594562 - To check whether deprn has run or not for current open period
            --            - if deprn is already run throw error.
            /*Bug# 8394781- */
            if g_release = 11 then
               if not FA_CHK_BOOKSTS_PKG.faxcdr(X_book => p_book_type_code, p_log_level_rec => g_log_level_rec) then
                   raise imp_err;
               end if;
            else
               l_asset_hdr_rec.book_type_code := p_book_type_code;
               For l_get_asset_id in c_get_asset_id(l_request_id,l_period_rec.period_counter)
               loop
                  l_asset_hdr_rec.asset_id := l_get_asset_id.asset_id;

                  FA_DEPRN_ROLLBACK_PUB.do_rollback

                       (p_api_version             => 1.0,
                        p_init_msg_list           => FND_API.G_FALSE,
                        p_commit                  => FND_API.G_FALSE,
                        p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
                        x_return_status           => l_return_status,
                        x_msg_count               => l_msg_count,
                        x_msg_data                => l_msg_data,
                        p_calling_fn              => l_calling_fn,
                        px_asset_hdr_rec          => l_asset_hdr_rec);

                  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                     raise imp_err;
                  else
                     if (g_log_level_rec.statement_level) then
                        fa_debug_pkg.add(l_calling_fn,
                                             'Successfully rolled back deprn asset:',l_get_asset_id.asset_id,g_log_level_rec);
                     end if;
                  end if;
               end loop;
            end if;
            /*Bug# 8394781- end */

            --
            -- Populate FA_ITF_IMPAIRMENTS with worker_ids etc
            --
            if not assign_workers (p_request_id        => l_request_id,
                                   p_book_type_code    => p_book_type_code,
                                   p_total_requests    => l_total_requests,
                                   p_period_rec        => l_imp_period_rec,
                                   p_prev_sysdate      => l_sysdate,
                                   p_login_id          => l_login_id,
                                   p_transaction_date  => l_transaction_date,
                                   p_set_of_books_id   => l_set_of_books_id,
                                   p_mrc_sob_type_code => l_mrc_sob_type_code,
                                   p_calling_fn        => l_calling_fn) then
               raise imp_err;
            end if;
         elsif p_mode = 'ROLLBACK' then
            --
            -- check to see if je has been rolled back
            --
            if G_release = 11 then
               if not check_je_post (p_book_type_code    => p_book_type_code,
                                 p_period_rec        => l_period_rec,
                                 p_mrc_sob_type_code => l_mrc_sob_type_code,
                                 p_set_of_books_id   => l_set_of_books_id,
                                 p_calling_fn        => l_calling_fn) then
                  raise imp_err;
               end if;
            end if;
         end if;


-- For now, only sigle processing is only option
--         if l_request_id <> -1 and l_total_requests > 1 then
         if l_request_id <> -1 and l_total_requests < 1 then
            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'Pararell process', 'Start', p_log_level_rec => g_log_level_rec);
            end if;
            --              *****************
            -- *************                 *****************
            --              Parallel Requests
            -- *************                 *****************
            --              *****************

            for i in 1..l_total_requests loop

               t_request_id(i) := FND_REQUEST.SUBMIT_REQUEST(
                                                application => 'OFA'
                                              , program     => 'FAPIMP'
                                              , argument1   => p_book_type_code
                                              , argument2   => l_internal_mode
                                              , argument3   => l_request_id
                                              , argument4   => l_total_requests
                                              , argument5   => i
                                              , argument6   => l_set_of_books_id
                                              , argument7   => l_mrc_sob_type_code);
            end loop;

            for i in 1..l_total_requests loop
               if not FND_CONCURRENT.WAIT_FOR_REQUEST(
                                           request_id => t_request_id(i)
                                         , interval   => 60
                                         , phase      => l_phase
                                         , status     => l_status
                                         , dev_phase  => l_dev_phase
                                         , dev_status => l_dev_status
                                         , message    => l_message) then
                  raise imp_err;
               end if;
            end loop;

            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'Pararell process', 'End', p_log_level_rec => g_log_level_rec);
            end if;

         end if;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'Setting MRC related info', 'Start', p_log_level_rec => g_log_level_rec);
         end if;

         if (l_sob_index <> 0) then

            if l_transaction_date < l_period_rec.calendar_period_open_date then
               OPEN c_get_mc_period_rec;
               FETCH c_get_mc_period_rec INTO l_imp_period_rec.period_counter
                                         , l_imp_period_rec.calendar_period_open_date
                                         , l_imp_period_rec.calendar_period_close_date
                                         , l_imp_period_rec.period_num
                                         , l_imp_period_rec.fiscal_year;
               CLOSE c_get_mc_period_rec;
            end if;

         end if;

         -- call the cache to set the sob_id used for rounding and other lower
         -- level code for each book.
         if NOT fa_cache_pkg.fazcbcs(X_book => p_book_type_code,
                                     X_set_of_books_id => l_set_of_books_id,
                                     p_log_level_rec => g_log_level_rec) then
            raise imp_err;
         end if;


-- For now, only sigle processing is only option
--         if (l_request_id = -1) or (l_total_requests = 1) then
        if (l_request_id = -1) or ( l_total_requests >= 1 ) then
            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'Standalone Mode', p_mode, p_log_level_rec => g_log_level_rec);
            end if;
            --              ****************
            -- *************                *****************
            --              Comand Line Mode
            -- *************                *****************
            --              ****************
            if p_mode = 'PREVIEW' then
                  --              *************
                  -- *************             *****************
                  --              Preview Phase
                  -- *************             *****************
                  --              *************
               if not  FA_IMPAIRMENT_PREV_PVT.process_depreciation(
                                      p_request_id        => l_request_id,
                                      p_book_type_code    => p_book_type_code,
                                      p_worker_id         => 0,
                                      p_period_rec        => l_period_rec,
                                      p_imp_period_rec    => l_imp_period_rec,
                                      p_mrc_sob_type_code => l_mrc_sob_type_code,
                                      p_set_of_books_id   => l_set_of_books_id,
                                      p_calling_fn        => l_calling_fn, p_log_level_rec => g_log_level_rec) then
                  if (g_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn,'Failed calling', 'process_depreciation', p_log_level_rec => g_log_level_rec);
                  end if;

                  raise imp_err;
               end if;
            elsif p_mode = 'POST' then
                  --              ************
                  -- *************            *****************
                  --               Post Phase
                  -- *************            *****************
                  --              ************
               --8666930
               if l_mrc_sob_type_code = 'R' then
                  UPDATE FA_MC_IMPAIRMENTS imp
                      SET   imp.STATUS     = l_internal_mode
                          , imp.REQUEST_ID = l_request_id
                          , imp.PERIOD_COUNTER_IMPAIRED = l_period_rec.PERIOD_COUNTER
                  WHERE  imp.SET_OF_BOOKS_ID = l_set_of_books_id
                  AND    imp.BOOK_TYPE_CODE  = p_book_type_code
                  AND    exists (SELECT IMPAIRMENT_ID
                                      FROM FA_IMPAIRMENTS imp2
                                 WHERE imp2.status = l_internal_mode
                                 AND   imp2.BOOK_TYPE_CODE = p_book_type_code
                                 AND   imp2.impairment_id = IMP.IMPAIRMENT_ID);
               end if;
               if not  FA_IMPAIRMENT_POST_PVT.process_post(
                                      p_request_id        => l_request_id,
                                      p_book_type_code    => p_book_type_code,
                                      p_period_rec        => l_period_rec,
                                      p_worker_id         => 0,
                                      p_mrc_sob_type_code => l_mrc_sob_type_code,
                                      p_set_of_books_id   => l_set_of_books_id,
                                      p_calling_fn        => l_calling_fn, p_log_level_rec => g_log_level_rec) then
                  if (g_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn,'Failed calling', 'process_post', p_log_level_rec => g_log_level_rec);
                  end if;

                  raise imp_err;
               end if;

            elsif p_mode = 'ROLLBACK' then
               --8666930
               if l_mrc_sob_type_code = 'R' then
                      UPDATE FA_MC_IMPAIRMENTS imp
                      SET   imp.STATUS     = l_internal_mode
                      , imp.REQUEST_ID = l_request_id
                      , imp.PERIOD_COUNTER_IMPAIRED = l_period_rec.PERIOD_COUNTER
                  WHERE  imp.SET_OF_BOOKS_ID = l_set_of_books_id
                  AND    imp.BOOK_TYPE_CODE  = p_book_type_code
                  AND    exists (SELECT IMPAIRMENT_ID
                                    FROM FA_IMPAIRMENTS imp2
                                 WHERE imp2.status = l_internal_mode
                                 AND   imp2.BOOK_TYPE_CODE = p_book_type_code
                                 AND   imp2.impairment_id = IMP.IMPAIRMENT_ID);
               end if;
               if not  FA_IMPAIRMENT_DELETE_PVT.delete_post(
                                      p_request_id        => l_request_id,
                                      p_book_type_code    => p_book_type_code,
                                      p_period_rec        => l_period_rec,
                                      p_worker_id         => 0,
                                      p_mrc_sob_type_code => l_mrc_sob_type_code,
                                      p_set_of_books_id   => l_set_of_books_id,
                                      p_calling_fn        => l_calling_fn, p_log_level_rec => g_log_level_rec) then
                  raise imp_err;
               end if;
            end if;

         end if; --

         if p_mode = 'PREVIEW' then
            -- ****************************************************
            --           Calculate total NBV and Allocation Phase
            -- ****************************************************

              if not  FA_IMPAIRMENT_PREV_PVT.calc_total_nbv(
                                      p_request_id            => l_request_id
                                     , p_book_type_code    => p_book_type_code
                                     , p_transaction_date      => l_transaction_date
--                                     , p_period_rec            => l_period_rec
                                     , p_period_rec            => l_imp_period_rec
                                     , p_mrc_sob_type_code     => l_mrc_sob_type_code
                                     , p_set_of_books_id   => l_set_of_books_id
                                     , p_calling_fn            => l_calling_fn
                                     , p_asset_id => l_asset_id
                                     , p_nbv => l_nbv_value, p_log_level_rec => g_log_level_rec) then
                 if (g_log_level_rec.statement_level) then
                    fa_debug_pkg.add(l_calling_fn,'Failed calling', 'calc_total_nbv', p_log_level_rec => g_log_level_rec);
                 end if;

                 raise imp_err;
              end if;

              --
              -- Calculating catch-up is necessary only for back dated impairment
              --
              if (l_imp_period_rec.period_counter < l_period_rec.period_counter) then
                 -- *************************************************
                 --  Calculate catch-up expense due to bd impairment
                 -- *************************************************

                 if not  FA_IMPAIRMENT_PREV_PVT.calculate_catchup(
                                          p_request_id        => l_request_id
                                        , p_book_type_code    => p_book_type_code
                                        , p_worker_id         => 0
                                        , p_period_rec        => l_period_rec
                                        , p_imp_period_rec    => l_imp_period_rec
                                        , p_mrc_sob_type_code => l_mrc_sob_type_code
                                    -- BMR    , p_set_of_books_id   => l_set_of_books_id
                                        , p_calling_fn        => l_calling_fn, p_log_level_rec => g_log_level_rec) then
                    if (g_log_level_rec.statement_level) then
                       fa_debug_pkg.add(l_calling_fn,'Failed calling', 'calculate_catchup', p_log_level_rec => g_log_level_rec);
                    end if;
                    raise imp_err;
                 end if;

              end if;

         else
null;
         end if;

      END LOOP; -- sob loop

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'After sob loop', sysdate, p_log_level_rec => g_log_level_rec);
      end if;


   elsif (p_parent_request_id is not null) then

      if not FA_CACHE_PKG.fazcbc(X_book => p_book_type_code, p_log_level_rec => g_log_level_rec) then
         raise imp_err;
      end if;

      -- call the cache to set the sob_id used for rounding and other lower
      -- level code for each book.
      if not FA_CACHE_PKG.fazcbcs(X_book => p_book_type_code,
                                  X_set_of_books_id => l_set_of_books_id,
                                  p_log_level_rec => g_log_level_rec) then
         raise imp_err;
      end if;

      if not FA_UTIL_PVT.get_period_rec(
                              p_book           => p_book_type_code,
                              p_effective_date => NULL,
                              x_period_rec     => l_period_rec, p_log_level_rec => g_log_level_rec) then
         raise imp_err;
      end if;

      if p_mode = 'RUNNING DEPRN' then
            --              *************
            -- *************             *****************
            --              Preview Phase
            -- *************             *****************
            --              *************
         if not FA_IMPAIRMENT_PREV_PVT.process_depreciation(
                                      p_request_id        => p_parent_request_id,
                                      p_book_type_code    => p_book_type_code,
                                      p_worker_id         => p_request_number,
                                      p_period_rec        => l_period_rec,
                                      p_imp_period_rec    => l_imp_period_rec,
                                      p_mrc_sob_type_code => p_mrc_sob_type_code,
                                      p_set_of_books_id   => l_set_of_books_id,
                                      p_calling_fn        => l_calling_fn, p_log_level_rec => g_log_level_rec) then
            raise imp_err;
         end if;
      elsif p_mode = 'RUNNING POST' then
            --              ************
            -- *************            *****************
            --               Post Phase
            -- *************            *****************
            --              ************
         if not  FA_IMPAIRMENT_POST_PVT.process_post(
                                      p_request_id        => p_parent_request_id,
                                      p_book_type_code    => p_book_type_code,
                                      p_period_rec        => l_period_rec,
                                      p_worker_id         => p_request_number,
                                      p_mrc_sob_type_code => p_mrc_sob_type_code,
                                      p_set_of_books_id   => l_set_of_books_id,
                                      p_calling_fn        => l_calling_fn, p_log_level_rec => g_log_level_rec) then
            raise imp_err;
         end if;
      elsif p_mode = 'DELETING POST' then
               if not  FA_IMPAIRMENT_DELETE_PVT.delete_post(
                                      p_request_id        => p_parent_request_id,
                                      p_book_type_code    => p_book_type_code,
                                      p_period_rec        => l_period_rec,
                                      p_worker_id         => p_request_number,
                                      p_mrc_sob_type_code => l_mrc_sob_type_code,
                                      p_set_of_books_id   => l_set_of_books_id,
                                      p_calling_fn        => l_calling_fn, p_log_level_rec => g_log_level_rec) then
                  raise imp_err;
               end if;
      end if;

   end if; -- (p_parent_request_id is not null) or (l_request_id = -1)


   -- ###########################################################
   -- ###########################################################
   -- ###########################################################
   -- This may need to relocated somewhere to show some of them
   -- are succeeded and some of them are failed.
   -- ###########################################################
   -- ###########################################################
   -- ###########################################################
   if p_mode = 'PREVIEW' then
      l_internal_mode := 'PREVIEWED';
   elsif p_mode = 'POST' then
      /*8666930 - Need to process deprn event here after processing is done for both primary and reporting books
                  this is to create same depreciation event for both primary and reporting book */
      if g_release <> 11 then
         FA_DEPRN_EVENTS_PKG.process_deprn_events(p_book_type_code,
                                                  l_period_rec.period_counter,
                                                  1, /*Change the parameter if parallel programing is enabled */
                                                  1,
                                                  x_return_status);
         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'x_return_status after process_deprn_events ', x_return_status, p_log_level_rec => g_log_level_rec);
         end if;
         if x_return_status <> 0 then
            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'Process deprn event has failed ', 'true', p_log_level_rec => g_log_level_rec);
            end if;
            raise imp_err;
         end if;
      end if;
      l_internal_mode := 'POSTED';
   elsif p_mode = 'ROLLBACK' then
      l_internal_mode := 'DELETED';
   end if;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'Updating status ', p_mode||' to '||l_internal_mode, p_log_level_rec => g_log_level_rec);
   end if;



   UPDATE FA_IMPAIRMENTS
   SET    STATUS     = l_internal_mode
   WHERE  REQUEST_ID = l_request_id
   AND    PERIOD_COUNTER_IMPAIRED = l_imp_period_rec.period_counter;

   --Bug# 7045739 start to update status to Deprn Failed if multiple rows are uploaded.
   UPDATE FA_IMPAIRMENTS IMP
   SET    STATUS='RUNNING DEPRN FAILED'
   WHERE  REQUEST_ID = l_request_id
   AND    EXISTS
          (SELECT 'DUPLICATE RECORD'
           FROM   FA_ITF_IMPAIRMENTS ITF
           WHERE  ITF.PERIOD_OF_ADDITION_FLAG = 'F'
           AND    ITF.IMPAIRMENT_ID = IMP.IMPAIRMENT_ID);
   --Bug# 7045739 end
   /*8666930 start - There could be more than one set_of_books_id attached.Need to update for all */
   FOR l_sob_index in 0..l_sob_tbl.count LOOP
            fa_debug_pkg.add(l_calling_fn,'GIRIRAJ', 'inside for', p_log_level_rec => g_log_level_rec);
            fa_debug_pkg.add(l_calling_fn,'GIRIRAJ l_sob_index', l_sob_index, p_log_level_rec => g_log_level_rec);
      if (l_sob_index = 0) then
         l_mrc_sob_type_code := 'P';
         l_set_of_books_id := l_primary_sob ;
         if l_transaction_date < l_period_rec.calendar_period_open_date then
            OPEN c_get_period_rec;
            FETCH c_get_period_rec INTO l_imp_period_rec.period_counter
                                         , l_imp_period_rec.calendar_period_open_date
                                         , l_imp_period_rec.calendar_period_close_date
                                         , l_imp_period_rec.period_num
                                         , l_imp_period_rec.fiscal_year;
            CLOSE c_get_period_rec;
         else
            l_imp_period_rec := l_period_rec;
         end if;
      else
         l_mrc_sob_type_code := 'R';
         l_set_of_books_id := l_sob_tbl(l_sob_index);
      end if;
      /* bug #6658765 - added if condition*/
      if l_mrc_sob_type_code = 'R' then
           UPDATE FA_MC_IMPAIRMENTS
           SET    STATUS     = l_internal_mode
           WHERE  REQUEST_ID = l_request_id
           AND    PERIOD_COUNTER_IMPAIRED = l_imp_period_rec.period_counter
           AND    SET_OF_BOOKS_ID = l_set_of_books_id;

           --Bug# 7045739 start to update status to Deprn Failed if multiple rows are uploaded.
           UPDATE FA_MC_IMPAIRMENTS IMP
           SET    STATUS='RUNNING DEPRN FAILED'
           WHERE  REQUEST_ID = l_request_id
           AND    SET_OF_BOOKS_ID = l_set_of_books_id
           AND    IMPAIRMENT_ID IN
                  (SELECT IMPAIRMENT_ID
                   FROM   FA_MC_ITF_IMPAIRMENTS
                   WHERE  PERIOD_OF_ADDITION_FLAG = 'F'
                   AND    REQUEST_ID = l_request_id
                   AND    SET_OF_BOOKS_ID = l_set_of_books_id);
           --Bug# 7045739 end
      end if;
   END LOOP;
   --8666930 end
   COMMIT;
   -- ###########################################################
   -- ###########################################################
   -- ###########################################################


   if (l_internal_mode in ('PREVIEWED', 'POSTED')) and
      (l_request_id <> -1)  then

      -- Get NLS LUNGAGE to get iso values
      OPEN c_get_nls_lang;
      FETCH c_get_nls_lang INTO l_nls_lang;
      CLOSE c_get_nls_lang;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'nls lang', l_nls_lang, p_log_level_rec => g_log_level_rec);
      end if;

      -- Get iso language and territory
      OPEN c_get_iso_values;
      FETCH c_get_iso_values INTO l_iso_lang, l_iso_territory;
      CLOSE c_get_iso_values;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'iso lang', l_iso_lang, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'iso Territory', l_iso_territory, p_log_level_rec => g_log_level_rec);
      end if;
      if nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag,'N') <> 'Y' then

                l_return_code := FND_REQUEST.add_layout (
                         template_appl_name => 'OFA'
                       , template_code      => 'FAXRASIM'
                       , template_language  => l_iso_lang
                       , template_territory => l_iso_territory
                       , output_format      => 'PDF');
          else
                l_return_code := FND_REQUEST.add_layout (
                         template_appl_name => 'OFA'
                       , template_code      => 'FAXSRPIM'
                       , template_language  => l_iso_lang
                       , template_territory => l_iso_territory
                       , output_format      => 'PDF');
      end if;
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'Submitting Report', l_internal_mode, p_log_level_rec => g_log_level_rec);
      end if;

      --
      -- Submitting Asset Impairment Report
      --
      l_request_id2 := FND_REQUEST.SUBMIT_REQUEST(
                                application => 'OFA'
                              , program     => 'FAXRASIM'
                              , argument1   => p_book_type_code
                              , argument2   => l_primary_sob   -- sob id
                              , argument3   => l_period_rec.period_counter -- per ctr
                              , argument4   => null          -- imp id
                              , argument5   => null          -- cgu id
                              , argument6   => l_request_id -- req id
                              , argument7   => l_internal_mode); -- status

   end if; -- (l_internal_mode in ('PREVIEWED', 'POSTED'))

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'l_request_id', l_request_id, p_log_level_rec => g_log_level_rec);
   end if;


   -- Dump Debug messages when run in debug mode to log file
   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.Write_Debug_Log;
   end if;

   --Bug# 7000391 start
   l_ret_code:=0;
   for i in 1..l_asset_id.count LOOP
         if l_nbv_value(i) = 0  then
                 fa_srvr_msg.add_message(
                         calling_fn => null,
                         name       => 'FA_IMPAIR_UPLOAD_WARN',
                         token1     => 'FA_ASSET_ID',
                         value1     =>  '' || l_asset_id(i),
                   p_log_level_rec => g_log_level_rec);

              l_ret_code:=1;
         -- Bug# 7045739 start - when multiple rows are uploaded for an asset in same request.
         elsif l_nbv_value(i) = -1 then
         fa_srvr_msg.add_message(
                         calling_fn => null,
                         name       => 'FA_IMPAIR_MULTI_ASSET_UPLOAD',
                         token1     => 'FA_ASSET_ID',
                         value1     =>  '' || l_asset_id(i),
                   p_log_level_rec => g_log_level_rec);

              l_ret_code:=1;
         -- Bug# 7045739 end
         --Bug#7594562 - When an impairment is already posted in current period for an asset.
         elsif l_nbv_value(i) = -2 then
         fa_srvr_msg.add_message(
                         calling_fn => null,
                         name       => 'FA_IMPAIR_ROLLBACK_ASSET',
                         token1     => 'FA_ASSET_ID',
                         value1     =>  '' || l_asset_id(i),
                   p_log_level_rec => g_log_level_rec);

              l_ret_code:=1;
         --Bug#7594562 end
         /*Bug#8555199 - Negative impairment loss amount is not allowed*/
         elsif l_nbv_value(i) = -3 then
         fa_srvr_msg.add_message(
                         calling_fn => null,
                         name       => 'FA_NEG_IMPAIR_LOSS_AMOUNT',
                         token1     => 'FA_ASSET_ID',
                         value1     =>  '' || l_asset_id(i),
                   p_log_level_rec => g_log_level_rec);

              l_ret_code:=1;
         --Bug#8614268 - Impairment Accounts not defined.
         elsif l_nbv_value(i) = -4 then
         fa_srvr_msg.add_message(
                         calling_fn => null,
                         name       => 'FA_IMPAIR_ACCTS_NOT_DEFINED',
                         token1     => 'FA_ASSET_ID',
                         value1     =>  '' || l_asset_id(i),
                   p_log_level_rec => g_log_level_rec);

              l_ret_code:=1;
         --Bug#8614268 end
         end if;
   end loop;

   if l_ret_code = 1 then --Bug# 7000391 added if condition
         fa_srvr_msg.add_message(
                        calling_fn => null,
                        name       => 'FA_SHARED_END_WITH_WARNING',
                        token1     => 'PROGRAM',
                        value1     => 'FAPIMP', p_log_level_rec => g_log_level_rec);
            FND_MSG_PUB.Count_And_Get(
                       p_count         => l_msg_count,
                       p_data          => l_msg_data);

           fa_srvr_msg.Write_Msg_Log(l_msg_count, l_msg_data, p_log_level_rec => g_log_level_rec);
           --return warning to concurrent manager
           retcode := 1;
    else --Bug# 7000391 end
        fa_srvr_msg.add_message(
                        calling_fn => l_calling_fn,
                        name       => 'FA_SHARED_END_SUCCESS',
                        token1     => 'PROGRAM',
                        value1     => 'FAPIMP', p_log_level_rec => g_log_level_rec);

        --   FND_MSG_PUB.Count_And_Get(
        --                p_count         => l_msg_count,
        --                p_data          => l_msg_data);

           fa_srvr_msg.Write_Msg_Log(1, null, p_log_level_rec => g_log_level_rec);

           -- return success to concurrent manager
           retcode := 0;
    END IF; --Bug# 7000391
EXCEPTION
   WHEN imp_err THEN
      ROLLBACK WORK;

      if (p_parent_request_id is null) then
         if not rollback_impairment(p_book_type_code    => p_book_type_code
                                  , p_request_id        => l_request_id
                                  , p_mode              => p_mode
                                  , p_impairment_id     => p_impairment_id
                                  , p_calling_fn        => l_calling_fn
                                  , p_mrc_sob_type_code => l_mrc_sob_type_code
                                  , p_set_of_books_id   => p_set_of_books_id) then /* Bug 6437003 added p_mrc_sob_type_code to check for set of books type code*/
            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'calling rollback_impairment', 'FAILED', p_log_level_rec => g_log_level_rec);
            end if;

         end if;
      end if;
      fa_srvr_msg.add_message(
                 calling_fn => 'fa_process_impairment_pkg.do_process_impairment',
                 name       => 'FA_SHARED_END_WITH_ERROR',
                 token1     => 'PROGRAM',
                 value1     => 'FAPIMP',  p_log_level_rec => g_log_level_rec);

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.Write_Debug_Log;
      end if;
      FND_MSG_PUB.Count_And_Get(
                        p_count         => l_msg_count,
                        p_data          => l_msg_data);
      fa_srvr_msg.Write_Msg_Log(l_msg_count, l_msg_data, p_log_level_rec => g_log_level_rec);
      -- return failure to concurrent manager
      retcode := 2;

   WHEN OTHERS THEN
      ROLLBACK WORK;

      if (p_parent_request_id is null) then
         if not rollback_impairment(p_book_type_code    => p_book_type_code
                                  , p_request_id        => l_request_id
                                  , p_mode              => p_mode
                                  , p_impairment_id     => p_impairment_id
                                  , p_calling_fn        => l_calling_fn
                                  , p_mrc_sob_type_code => l_mrc_sob_type_code
                                  , p_set_of_books_id   => p_set_of_books_id) then /* Bug 6437003 added p_mrc_sob_type_code to check for set of books type code*/
            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'calling rollback_impairment', 'FAILED', p_log_level_rec => g_log_level_rec);
            end if;

         end if;
      end if;

      fa_srvr_msg.add_sql_error (
                calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      fa_srvr_msg.add_message(
                calling_fn => l_calling_fn,
                name       => 'FA_SHARED_END_WITH_ERROR',
                token1     => 'PROGRAM',
                value1     => 'FAPIMP', p_log_level_rec => g_log_level_rec);

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.Write_Debug_Log;
      end if;
      FND_MSG_PUB.Count_And_Get(
                        p_count         => l_msg_count,
                        p_data          => l_msg_data);
      fa_srvr_msg.Write_Msg_Log(l_msg_count, l_msg_data, p_log_level_rec => g_log_level_rec);
      -- return failure to concurrent manager
      retcode := 2;
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'EXCEPTION(OTHERS)', sqlerrm);
      end if;
END process_impairments;


FUNCTION assign_workers (p_request_id        IN NUMBER,
                         p_book_type_code    IN VARCHAR2,
                         p_total_requests    IN NUMBER,
                         p_period_rec        IN FA_API_TYPES.period_rec_type,
                         p_prev_sysdate      IN DATE,
                         p_login_id          IN NUMBER,
                         p_transaction_date  IN DATE,
                         p_set_of_books_id   In NUMBER,
                         p_mrc_sob_type_code IN VARCHAR2,
                         p_calling_fn        IN VARCHAR2)
RETURN BOOLEAN IS

--   l_calling_fn varchar2(50) := 'fa_process_impairment_pkg.assign_workers';
   l_calling_fn varchar2(50) := 'assign_workers';

   l_process_order   number(15);
   l_mode            varchar2(30) := 'RUNNING DEPRN';

   CURSOR c_get_currency_info(c_set_of_books_id number) IS
      SELECT curr.precision
      FROM   fnd_currencies curr
           , gl_sets_of_books sob
      WHERE  sob.set_of_books_id = c_set_of_books_id
      AND    curr.currency_code  = sob.currency_code;

   l_exchange_date       date;
   l_rate                number;
   l_precision           number;
   l_mrc_nsp             number;  -- converted net selling price
   l_mrc_viu             number;  -- converted value in use
   l_mrc_gwa             number;  -- converted goodwill amount

   agn_err EXCEPTION;
BEGIN
   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'assign_workers', 'BEGIN: '||to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS'));
   end if;

   --
   -- Copy primary book impairment over fa_impairment_mrc_v
   --
   if p_mrc_sob_type_code = 'R' then

      l_exchange_date := p_transaction_date;

      OPEN c_get_currency_info(p_set_of_books_id);
      FETCH c_get_currency_info INTO l_precision;
      CLOSE c_get_currency_info;


      -- Need to get exchange rate
      if not FA_MC_UTIL_PVT.get_trx_rate
                 (p_prim_set_of_books_id       => fa_cache_pkg.fazcbc_record.set_of_books_id,
                  p_reporting_set_of_books_id  => p_set_of_books_id,
                  px_exchange_date             => l_exchange_date,
                  p_book_type_code             => p_book_type_code,
                  px_rate                      => l_rate, p_log_level_rec => g_log_level_rec)then
         raise agn_err;
      end if;


      -- round values

      insert into fa_mc_impairments(
                                IMPAIRMENT_ID
                              , IMPAIRMENT_NAME
                              , DESCRIPTION
                              , REQUEST_ID
                              , STATUS
                              , BOOK_TYPE_CODE
                              , CASH_GENERATING_UNIT_ID
                              , ASSET_ID
                              , NET_BOOK_VALUE
                              , NET_SELLING_PRICE
                              , VALUE_IN_USE
                              , GOODWILL_ASSET_ID
                              , GOODWILL_AMOUNT
                              , USER_DATE
                              , IMPAIRMENT_DATE
                              , PERIOD_COUNTER_IMPAIRED
                              , IMPAIRMENT_AMOUNT
                              , DATE_INEFFECTIVE
                              , CREATION_DATE
                              , CREATED_BY
                              , LAST_UPDATE_DATE
                              , LAST_UPDATED_BY
                              , LAST_UPDATE_LOGIN
                              , SET_OF_BOOKS_ID
                              , IMPAIR_CLASS          -- Start of Bug 6666666
                              , REASON
                              , IMPAIR_LOSS_ACCT
                              , SPLIT_IMPAIR_FLAG
                              , SPLIT1_IMPAIR_CLASS
                              , SPLIT1_REASON
                              , SPLIT1_PERCENT
                              , SPLIT1_LOSS_ACCT
                              , SPLIT2_IMPAIR_CLASS
                              , SPLIT2_REASON
                              , SPLIT2_PERCENT
                              , SPLIT2_LOSS_ACCT
                              , SPLIT3_IMPAIR_CLASS
                              , SPLIT3_REASON
                              , SPLIT3_PERCENT
                              , SPLIT3_LOSS_ACCT       -- End of Bug 6666666

      ) select IMPAIRMENT_ID
             , IMPAIRMENT_NAME
             , DESCRIPTION
             , p_request_id -- REQUEST_ID
             , STATUS
             , p_book_type_code -- BOOK_TYPE_CODE
             , CASH_GENERATING_UNIT_ID
             , ASSET_ID
             , round(NET_BOOK_VALUE*l_rate, l_precision) --  NET_BOOK_VALUE
             , round(NET_SELLING_PRICE*l_rate, l_precision) -- NET_SELLING_PRICE
             , round(VALUE_IN_USE*l_rate, l_precision) -- VALUE_IN_USE
             , GOODWILL_ASSET_ID
             , round(GOODWILL_AMOUNT*l_rate, l_precision) -- GOODWILL_AMOUNT
             , USER_DATE
             , IMPAIRMENT_DATE
             , PERIOD_COUNTER_IMPAIRED
             , round(IMPAIRMENT_AMOUNT*l_rate, l_precision) -- IMPAIRMENT_AMOUNT
             , null -- DATE_INEFFECTIVE
             , CREATION_DATE
             , CREATED_BY
             , LAST_UPDATE_DATE
             , LAST_UPDATED_BY
             , null -- LAST_UPDATE_LOGIN
             , p_set_of_books_id --SET_OF_BOOKS_ID
             , IMPAIR_CLASS     -- Start of Bug 6666666
             , REASON
             , IMPAIR_LOSS_ACCT
             , SPLIT_IMPAIR_FLAG
             , SPLIT1_IMPAIR_CLASS
             , SPLIT1_REASON
             , SPLIT1_PERCENT
             , SPLIT1_LOSS_ACCT
             , SPLIT2_IMPAIR_CLASS
             , SPLIT2_REASON
             , SPLIT2_PERCENT
             , SPLIT2_LOSS_ACCT
             , SPLIT3_IMPAIR_CLASS
             , SPLIT3_REASON
             , SPLIT3_PERCENT
             , SPLIT3_LOSS_ACCT -- End of Bug 6666666
        from   fa_impairments -- 8666930 changed to fa_impairments from fa_mc_impairments
        where  request_id = p_request_id
        and    book_type_code = p_book_type_code
        and    PERIOD_COUNTER_IMPAIRED = p_period_rec.period_counter
--      and    set_of_books_id = p_set_of_books_id --8666930 commented
      ;
   end if;


   if p_mrc_sob_type_code = 'R' then
      --
      -- Primary Book
      --
      --Bug# 7292608 When updating uploaded impairment,existing row needs to be deleted first
      delete from fa_mc_itf_impairments itmp
      where set_of_books_id = p_set_of_books_id
      and exists
      (select  'Uploaded impairment'
       from  fa_mc_books bk , fa_mc_impairments imp
       where imp.book_type_code = p_book_type_code
       and   imp.status         = l_mode
       and   imp.request_id = p_request_id
       and   imp.set_of_books_id = p_set_of_books_id
       and   bk.book_type_code  = p_book_type_code
       and   bk.set_of_books_id = p_set_of_books_id
       and   (bk.period_counter_fully_retired is null or bk.adjustment_required_status <> 'NONE')
       /* Bug#7581881 Removed condition on fully reserve asset and show warning  */
       and   bk.deprn_start_date <= p_period_rec.calendar_period_close_date
       and   (imp.asset_id  =  bk.asset_id      or
                  bk.cash_generating_unit_id = imp.cash_generating_unit_id)
       and   bk.transaction_header_id_out is null
       and   itmp.impairment_id = imp.impairment_id);
      --Bug6433799
      --Added the Set_of_books_id
      insert into fa_mc_itf_impairments(
                     SET_OF_BOOKS_ID
                   , REQUEST_ID
                   , IMPAIRMENT_ID
                   , BOOK_TYPE_CODE
                   , ASSET_ID
                   , CASH_GENERATING_UNIT_ID
                   , GOODWILL_ASSET_FLAG
                   , ADJUSTED_COST
                   , PERIOD_COUNTER
                   , COST
                   , IMPAIRMENT_AMOUNT
                   , YTD_IMPAIRMENT
                   , impairment_reserve
                   , CREATION_DATE
                   , CREATED_BY
                   , LAST_UPDATE_DATE
                   , LAST_UPDATED_BY
                   , IMPAIRMENT_DATE
                   , WORKER_ID
                   , PROCESS_ORDER
                   , IMPAIR_CLASS          -- Start of Bug 6666666
                   , REASON
                   , IMPAIR_LOSS_ACCT
                   , SPLIT_IMPAIR_FLAG
                   , SPLIT1_IMPAIR_CLASS
                   , SPLIT1_REASON
                   , SPLIT1_PERCENT
                   , SPLIT1_LOSS_ACCT
                   , SPLIT2_IMPAIR_CLASS
                   , SPLIT2_REASON
                   , SPLIT2_PERCENT
                   , SPLIT2_LOSS_ACCT
                   , SPLIT3_IMPAIR_CLASS
                   , SPLIT3_REASON
                   , SPLIT3_PERCENT
                   , SPLIT3_LOSS_ACCT       -- End of Bug 6666666
                   ) select  p_set_of_books_id --SET_OF_BOOKS_ID
                           , p_request_id                 --REQUEST_ID
                           , imp.impairment_id              --IMPAIRMENT_ID
                           , p_book_type_code             --BOOK_TYPE_CODE
                           , bk.ASSET_ID                  --ASSET_ID
                           , bk.CASH_GENERATING_UNIT_ID   --CASH_GENERATING_UNIT_ID
                           , decode(bk.asset_id,imp.goodwill_asset_id, 'Y', null) --GOODWILL_ASSET_FLAG
                           , bk.ADJUSTED_COST             --ADJUSTED_COST
                           , p_period_rec.period_counter  --PERIOD_COUNTER
                           , bk.COST                      --COST
                           , 0                            -- IMPAIRMENT_AMOUNT
                           , 0                            --YTD_IMPAIRMENT
                           , 0                            --impairment_reserve
                           , p_prev_sysdate               --CREATION_DATE
                           , p_login_id                   --CREATED_BY
                           , p_prev_sysdate               --LAST_UPDATE_DATE
                           , p_login_id                   --LAST_UPDATED_BY
                           , nvl(imp.impairment_date, p_transaction_date) --IMPAIRMENT_DATE
                           , 0 --mod(rank() over(order by bk.asset_id), p_total_requests) --WORKER_ID --Bug5736200
                           , l_process_order              --PROCESS_ORDER
                           , imp.IMPAIR_CLASS          -- Start of Bug 6666666
                           , imp.REASON
                           , imp.IMPAIR_LOSS_ACCT
                           , imp.SPLIT_IMPAIR_FLAG
                           , imp.SPLIT1_IMPAIR_CLASS
                           , imp.SPLIT1_REASON
                           , imp.SPLIT1_PERCENT
                           , imp.SPLIT1_LOSS_ACCT
                           , imp.SPLIT2_IMPAIR_CLASS
                           , imp.SPLIT2_REASON
                           , imp.SPLIT2_PERCENT
                           , imp.SPLIT2_LOSS_ACCT
                           , imp.SPLIT3_IMPAIR_CLASS
                           , imp.SPLIT3_REASON
                           , imp.SPLIT3_PERCENT
                           , imp.SPLIT3_LOSS_ACCT       -- End of Bug 6666666
                        from fa_mc_books bk
                           , fa_mc_impairments imp
                        where imp.book_type_code = p_book_type_code
                        and   imp.status         = l_mode
                        and   imp.request_id = p_request_id
                        and   imp.set_of_books_id = p_set_of_books_id
                        and   bk.book_type_code  = p_book_type_code
                        and   (bk.period_counter_fully_retired is null or bk.adjustment_required_status <> 'NONE')
                        /* Bug#7581881 Removed condition on fully reserve asset and show warning  */
                        and   bk.deprn_start_date <= p_period_rec.calendar_period_close_date
                        and   (imp.asset_id  =  bk.asset_id      or
                                  bk.cash_generating_unit_id = imp.cash_generating_unit_id)
                        and   bk.transaction_header_id_out is null
                        and   bk.set_of_books_id = p_set_of_books_id;


      if sql%rowcount = 0 then
         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'No rows to assign', 'Check Impairment', p_log_level_rec => g_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'p_book_type_code', p_book_type_code, p_log_level_rec => g_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_mode', l_mode, p_log_level_rec => g_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'p_period_rec.period_close_date', p_period_rec.period_close_date, p_log_level_rec => g_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'p_prev_sysdate', p_prev_sysdate, p_log_level_rec => g_log_level_rec);
         end if;

         raise agn_err;
      end if;

      commit;

      --Bug# 7292608 When updating uploaded impairment,existing row needs to be deleted first
      delete from fa_mc_itf_impairments itmp
      where set_of_books_id = p_set_of_books_id
      and exists
      (select  'Uploaded impairment'
       from  fa_mc_books bk , fa_mc_impairments imp
       where imp.book_type_code = p_book_type_code
       and   imp.status         = l_mode
       and   imp.request_id = p_request_id
       and   imp.set_of_books_id = p_set_of_books_id
       and   bk.book_type_code  = p_book_type_code
       and   bk.set_of_books_id = p_set_of_books_id
       and   (bk.period_counter_fully_retired is null or bk.adjustment_required_status <> 'NONE')
       /* Bug#7581881 Removed condition on fully reserve asset and show warning  */
       and   bk.deprn_start_date <= p_period_rec.calendar_period_close_date
       and   imp.goodwill_asset_id  =  bk.asset_id
       and   bk.transaction_header_id_out is null
       and   itmp.impairment_id = imp.impairment_id);

      -- Insert goodwill asset record into itf table
      insert into fa_mc_itf_impairments(
                     SET_OF_BOOKS_ID
                   , REQUEST_ID
                   , IMPAIRMENT_ID
                   , BOOK_TYPE_CODE
                   , ASSET_ID
                   , CASH_GENERATING_UNIT_ID
                   , GOODWILL_ASSET_FLAG
                   , ADJUSTED_COST
                   , PERIOD_COUNTER
                   , COST
                   , IMPAIRMENT_AMOUNT
                   , YTD_IMPAIRMENT
                   , impairment_reserve
                   , CREATION_DATE
                   , CREATED_BY
                   , LAST_UPDATE_DATE
                   , LAST_UPDATED_BY
                   , IMPAIRMENT_DATE
                   , WORKER_ID
                   , PROCESS_ORDER
                   , IMPAIR_CLASS          -- Start of Bug 6666666
                   , REASON
                   , IMPAIR_LOSS_ACCT
                   , SPLIT_IMPAIR_FLAG
                   , SPLIT1_IMPAIR_CLASS
                   , SPLIT1_REASON
                   , SPLIT1_PERCENT
                   , SPLIT1_LOSS_ACCT
                   , SPLIT2_IMPAIR_CLASS
                   , SPLIT2_REASON
                   , SPLIT2_PERCENT
                   , SPLIT2_LOSS_ACCT
                   , SPLIT3_IMPAIR_CLASS
                   , SPLIT3_REASON
                   , SPLIT3_PERCENT
                   , SPLIT3_LOSS_ACCT       -- End of Bug 6666666
                   ) select
                             p_set_of_books_id
                           , p_request_id                 --REQUEST_ID
                           , imp.impairment_id            --IMPAIRMENT_ID
                           , p_book_type_code             --BOOK_TYPE_CODE
                           , bk.ASSET_ID                  --ASSET_ID
                           , bk.CASH_GENERATING_UNIT_ID   --CASH_GENERATING_UNIT_ID
                           , 'Y'                          --GOODWILL_ASSET_FLAG
                           , bk.ADJUSTED_COST             --ADJUSTED_COST
                           , p_period_rec.period_counter  --PERIOD_COUNTER
                           , bk.COST                      --COST
                           , imp.GOODWILL_AMOUNT          --IMPAIRMENT_AMOUNT
                           , imp.GOODWILL_AMOUNT          --YTD_IMPAIRMENT
                           , imp.GOODWILL_AMOUNT          --impairment_reserve
                           , p_prev_sysdate               --CREATION_DATE
                           , p_login_id                   --CREATED_BY
                           , p_prev_sysdate               --LAST_UPDATE_DATE
                           , p_login_id                   --LAST_UPDATED_BY
                           , nvl(imp.impairment_date, p_transaction_date) --IMPAIRMENT_DATE
                           , 0 --mod(rank() over(order by bk.asset_id), p_total_requests) --WORKER_ID --Bug5736200
                           , l_process_order              --PROCESS_ORDER
                           , imp.IMPAIR_CLASS          -- Start of Bug 6666666
                           , imp.REASON
                           , imp.IMPAIR_LOSS_ACCT
                           , imp.SPLIT_IMPAIR_FLAG
                           , imp.SPLIT1_IMPAIR_CLASS
                           , imp.SPLIT1_REASON
                           , imp.SPLIT1_PERCENT
                           , imp.SPLIT1_LOSS_ACCT
                           , imp.SPLIT2_IMPAIR_CLASS
                           , imp.SPLIT2_REASON
                           , imp.SPLIT2_PERCENT
                           , imp.SPLIT2_LOSS_ACCT
                           , imp.SPLIT3_IMPAIR_CLASS
                           , imp.SPLIT3_REASON
                           , imp.SPLIT3_PERCENT
                           , imp.SPLIT3_LOSS_ACCT       -- End of Bug 6666666
                        from fa_mc_books bk
                           , fa_mc_impairments imp
                        where imp.book_type_code = p_book_type_code
                        and   imp.status         = l_mode
                        and   imp.request_id = p_request_id
                        and   imp.set_of_books_id = p_set_of_books_id
                        and   bk.book_type_code  = p_book_type_code
                        and   bk.set_of_books_id = p_set_of_books_id
                        and   (bk.period_counter_fully_retired is null or bk.adjustment_required_status <> 'NONE')
                        /* Bug#7581881 Removed condition on fully reserve asset and show warning  */
                        and   bk.deprn_start_date <= p_period_rec.calendar_period_close_date
                        and   imp.goodwill_asset_id  =  bk.asset_id
                        and   bk.transaction_header_id_out is null;




   else
      --
      -- Primary Book
      --
      --Bug# 7292608 When updating uploaded impairment,existing row needs to be deleted first
      delete from fa_itf_impairments itmp
      where exists
      (select  'Uploaded impairment'
       from  fa_books bk , fa_impairments imp
       where imp.book_type_code = p_book_type_code
       and   imp.status         = l_mode
       and   imp.request_id = p_request_id
       and   bk.book_type_code  = p_book_type_code
       and   (bk.period_counter_fully_retired is null or bk.adjustment_required_status <> 'NONE')
       /* Bug#7581881 Removed condition on fully reserve asset and show warning  */
       and   bk.deprn_start_date <= p_period_rec.calendar_period_close_date
       and   (imp.asset_id  =  bk.asset_id      or
               bk.cash_generating_unit_id = imp.cash_generating_unit_id)
       and   bk.transaction_header_id_out is null
       and   itmp.impairment_id = imp.impairment_id);

      insert into fa_itf_impairments(
                     REQUEST_ID
                   , IMPAIRMENT_ID
                   , BOOK_TYPE_CODE
                   , ASSET_ID
                   , CASH_GENERATING_UNIT_ID
                   , GOODWILL_ASSET_FLAG
                   , ADJUSTED_COST
                   , PERIOD_COUNTER
                   , COST
                   , IMPAIRMENT_AMOUNT
                   , YTD_IMPAIRMENT
                   , impairment_reserve
                   , CREATION_DATE
                   , CREATED_BY
                   , LAST_UPDATE_DATE
                   , LAST_UPDATED_BY
                   , IMPAIRMENT_DATE
                   , WORKER_ID
                   , PROCESS_ORDER
                   , IMPAIR_CLASS          -- Start of Bug 6666666
                   , REASON
                   , IMPAIR_LOSS_ACCT
                   , SPLIT_IMPAIR_FLAG
                   , SPLIT1_IMPAIR_CLASS
                   , SPLIT1_REASON
                   , SPLIT1_PERCENT
                   , SPLIT1_LOSS_ACCT
                   , SPLIT2_IMPAIR_CLASS
                   , SPLIT2_REASON
                   , SPLIT2_PERCENT
                   , SPLIT2_LOSS_ACCT
                   , SPLIT3_IMPAIR_CLASS
                   , SPLIT3_REASON
                   , SPLIT3_PERCENT
                   , SPLIT3_LOSS_ACCT       -- End of Bug 6666666
                   ) select  p_request_id                 --REQUEST_ID
                           , imp.impairment_id              --IMPAIRMENT_ID
                           , p_book_type_code             --BOOK_TYPE_CODE
                           , bk.ASSET_ID                  --ASSET_ID
                           , bk.CASH_GENERATING_UNIT_ID   --CASH_GENERATING_UNIT_ID
                           , decode(bk.asset_id,imp.goodwill_asset_id, 'Y', null) --GOODWILL_ASSET_FLAG
                           , bk.ADJUSTED_COST             --ADJUSTED_COST
                           , p_period_rec.period_counter  --PERIOD_COUNTER
                           , bk.COST                      --COST
                           , 0                            -- IMPAIRMENT_AMOUNT
                           , 0                            --YTD_IMPAIRMENT
                           , 0                            --impairment_reserve
                           , p_prev_sysdate               --CREATION_DATE
                           , p_login_id                   --CREATED_BY
                           , p_prev_sysdate               --LAST_UPDATE_DATE
                           , p_login_id                   --LAST_UPDATED_BY
                           , nvl(imp.impairment_date, p_transaction_date) --IMPAIRMENT_DATE
                           , 0 --mod(rank() over(order by bk.asset_id), p_total_requests) --WORKER_ID --Bug5736200
                           , l_process_order              --PROCESS_ORDER
                           , imp.IMPAIR_CLASS          -- Start of Bug 6666666
                           , imp.REASON
                           , imp.IMPAIR_LOSS_ACCT
                           , imp.SPLIT_IMPAIR_FLAG
                           , imp.SPLIT1_IMPAIR_CLASS
                           , imp.SPLIT1_REASON
                           , imp.SPLIT1_PERCENT
                           , imp.SPLIT1_LOSS_ACCT
                           , imp.SPLIT2_IMPAIR_CLASS
                           , imp.SPLIT2_REASON
                           , imp.SPLIT2_PERCENT
                           , imp.SPLIT2_LOSS_ACCT
                           , imp.SPLIT3_IMPAIR_CLASS
                           , imp.SPLIT3_REASON
                           , imp.SPLIT3_PERCENT
                           , imp.SPLIT3_LOSS_ACCT       -- End of Bug 6666666
                        from fa_books bk
                           , fa_impairments imp
                        where imp.book_type_code = p_book_type_code
                        and   imp.status         = l_mode
                        and   imp.request_id = p_request_id
                        and   bk.book_type_code  = p_book_type_code
                        and   (bk.period_counter_fully_retired is null or bk.adjustment_required_status <> 'NONE')
                        /* Bug#7581881 Removed condition on fully reserve asset and show warning  */
                        and   bk.deprn_start_date <= p_period_rec.calendar_period_close_date
                        and   (imp.asset_id  =  bk.asset_id      or
                                  bk.cash_generating_unit_id = imp.cash_generating_unit_id)
                        and   bk.transaction_header_id_out is null;

      if sql%rowcount = 0 then
         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'No rows to assign', 'Check Impairment', p_log_level_rec => g_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'p_book_type_code', p_book_type_code, p_log_level_rec => g_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_mode', l_mode, p_log_level_rec => g_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'p_period_rec.period_close_date', p_period_rec.period_close_date, p_log_level_rec => g_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'p_prev_sysdate', p_prev_sysdate, p_log_level_rec => g_log_level_rec);
         end if;

         raise agn_err;
      end if;

      commit;

       --Bug# 7292608 When updating uploaded impairment,existing row needs to be deleted first
      delete from fa_itf_impairments itmp
      where exists
      (select  'Uploaded impairment'
       from  fa_books bk , fa_impairments imp
       where imp.book_type_code = p_book_type_code
       and   imp.status         = l_mode
       and   imp.request_id = p_request_id
       and   bk.book_type_code  = p_book_type_code
       and   (bk.period_counter_fully_retired is null or bk.adjustment_required_status <> 'NONE')
       /* Bug#7581881 Removed condition on fully reserve asset and show warning  */
       and   bk.deprn_start_date <= p_period_rec.calendar_period_close_date
       and   imp.goodwill_asset_id  =  bk.asset_id
       and   bk.transaction_header_id_out is null
       and   itmp.impairment_id = imp.impairment_id);

      -- Insert goodwill asset record into itf table
      insert into fa_itf_impairments(
                     REQUEST_ID
                   , IMPAIRMENT_ID
                   , BOOK_TYPE_CODE
                   , ASSET_ID
                   , CASH_GENERATING_UNIT_ID
                   , GOODWILL_ASSET_FLAG
                   , ADJUSTED_COST
                   , PERIOD_COUNTER
                   , COST
                   , IMPAIRMENT_AMOUNT
                   , YTD_IMPAIRMENT
                   , impairment_reserve
                   , CREATION_DATE
                   , CREATED_BY
                   , LAST_UPDATE_DATE
                   , LAST_UPDATED_BY
                   , IMPAIRMENT_DATE
                   , WORKER_ID
                   , PROCESS_ORDER
                   , IMPAIR_CLASS          -- Start of Bug 6666666
                   , REASON
                   , IMPAIR_LOSS_ACCT
                   , SPLIT_IMPAIR_FLAG
                   , SPLIT1_IMPAIR_CLASS
                   , SPLIT1_REASON
                   , SPLIT1_PERCENT
                   , SPLIT1_LOSS_ACCT
                   , SPLIT2_IMPAIR_CLASS
                   , SPLIT2_REASON
                   , SPLIT2_PERCENT
                   , SPLIT2_LOSS_ACCT
                   , SPLIT3_IMPAIR_CLASS
                   , SPLIT3_REASON
                   , SPLIT3_PERCENT
                   , SPLIT3_LOSS_ACCT       -- End of Bug 6666666
                   ) select
                             p_request_id                 --REQUEST_ID
                           , imp.impairment_id            --IMPAIRMENT_ID
                           , p_book_type_code             --BOOK_TYPE_CODE
                           , bk.ASSET_ID                  --ASSET_ID
                           , bk.CASH_GENERATING_UNIT_ID   --CASH_GENERATING_UNIT_ID
                           , 'Y'                          --GOODWILL_ASSET_FLAG
                           , bk.ADJUSTED_COST             --ADJUSTED_COST
                           , p_period_rec.period_counter  --PERIOD_COUNTER
                           , bk.COST                      --COST
                           , imp.GOODWILL_AMOUNT          --IMPAIRMENT_AMOUNT
                           , imp.GOODWILL_AMOUNT          --YTD_IMPAIRMENT
                           , imp.GOODWILL_AMOUNT          --impairment_reserve
                           , p_prev_sysdate               --CREATION_DATE
                           , p_login_id                   --CREATED_BY
                           , p_prev_sysdate               --LAST_UPDATE_DATE
                           , p_login_id                   --LAST_UPDATED_BY
                           , nvl(imp.impairment_date, p_transaction_date) --IMPAIRMENT_DATE
                           , 0 --mod(rank() over(order by bk.asset_id), p_total_requests) --WORKER_ID --Bug5736200
                           , l_process_order              --PROCESS_ORDER
                           , imp.IMPAIR_CLASS          -- Start of Bug 6666666
                           , imp.REASON
                           , imp.IMPAIR_LOSS_ACCT
                           , imp.SPLIT_IMPAIR_FLAG
                           , imp.SPLIT1_IMPAIR_CLASS
                           , imp.SPLIT1_REASON
                           , imp.SPLIT1_PERCENT
                           , imp.SPLIT1_LOSS_ACCT
                           , imp.SPLIT2_IMPAIR_CLASS
                           , imp.SPLIT2_REASON
                           , imp.SPLIT2_PERCENT
                           , imp.SPLIT2_LOSS_ACCT
                           , imp.SPLIT3_IMPAIR_CLASS
                           , imp.SPLIT3_REASON
                           , imp.SPLIT3_PERCENT
                           , imp.SPLIT3_LOSS_ACCT       -- End of Bug 6666666
                        from fa_books bk
                           , fa_impairments imp
                        where imp.book_type_code = p_book_type_code
                        and   imp.status         = l_mode
                        and   imp.request_id = p_request_id
                        and   bk.book_type_code  = p_book_type_code
                        and   (bk.period_counter_fully_retired is null or bk.adjustment_required_status <> 'NONE')
                        /* Bug#7581881 Removed condition on fully reserve asset and show warning  */
                        and   bk.deprn_start_date <= p_period_rec.calendar_period_close_date
                        and   imp.goodwill_asset_id  =  bk.asset_id
                        and   bk.transaction_header_id_out is null;

   end if;

   commit;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'assign_workers', 'END: '||to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS'));
   end if;

   return TRUE;
EXCEPTION

   WHEN agn_err THEN
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'agn_err', p_log_level_rec => g_log_level_rec);
      end if;
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      return FALSE;

   WHEN OTHERS THEN
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'OTHERS', p_log_level_rec => g_log_level_rec);
      end if;
      fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      return FALSE;

END assign_workers;

FUNCTION check_je_post (p_book_type_code    IN VARCHAR2,
                        p_period_rec        IN FA_API_TYPES.period_rec_type,
                        p_mrc_sob_type_code IN VARCHAR2,
                        p_set_of_books_id   IN NUMBER,
                        p_calling_fn        IN VARCHAR2)
RETURN BOOLEAN IS

--   l_calling_fn varchar2(50) := 'fa_process_impairment_pkg.check_je_post';
   l_calling_fn varchar2(50) := 'check_je_post';


   l_je_post_count      number(15);
   l_dp_post_count      number(15);


   chk_err EXCEPTION;
BEGIN
   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Begin', p_book_type_code, p_log_level_rec => g_log_level_rec);
   end if;

   if (p_mrc_sob_type_code = 'R') then
      select count(*)
      into   l_je_post_count
      from   fa_journal_entries je,
             fa_mc_book_controls bc
      where  bc.book_type_code = p_book_type_code
      and    bc.set_of_books_id = p_set_of_books_id
      and    je.set_of_books_id = p_set_of_books_id
      and    bc.book_type_code = je.book_type_code
      and    je.period_counter = p_period_rec.period_counter
      and    je.je_status in ('C', 'E')
      and    ((addition_batch_id is NOT NULL) or
              (adjustment_batch_id is NOT NULL) or
              (depreciation_batch_id is NOT NULL) or
              (reclass_batch_id is NOT NULL) or
              (retirement_batch_id is NOT NULL) or
              (reval_batch_id is NOT NULL) or
              (transfer_batch_id is NOT NULL) or
              (cip_addition_batch_id is NOT NULL) or
              (cip_adjustment_batch_id is NOT NULL) or
              (cip_reclass_batch_id is NOT NULL) or
              (cip_retirement_batch_id is NOT NULL) or
              (cip_reval_batch_id is NOT NULL) or
              (cip_transfer_batch_id is NOT NULL) or
              (deprn_adjustment_batch_id is NOT NULL));

      select count(*)
      into   l_dp_post_count
      from   fa_mc_deprn_periods
      where  book_type_code = p_book_type_code
      and    period_counter = p_period_rec.period_counter
      and    set_of_books_id = p_set_of_books_id
      and    ((addition_batch_id is NOT NULL) or
              (adjustment_batch_id is NOT NULL) or
              (depreciation_batch_id is NOT NULL) or
              (reclass_batch_id is NOT NULL) or
              (retirement_batch_id is NOT NULL) or
              (reval_batch_id is NOT NULL) or
              (transfer_batch_id is NOT NULL) or
              (cip_addition_batch_id is NOT NULL) or
              (cip_adjustment_batch_id is NOT NULL) or
              (cip_reclass_batch_id is NOT NULL) or
              (cip_retirement_batch_id is NOT NULL) or
              (cip_reval_batch_id is NOT NULL) or
              (cip_transfer_batch_id is NOT NULL) or
              (deprn_adjustment_batch_id is NOT NULL));

   else
      select count(*)
      into   l_je_post_count
      from   fa_journal_entries je,
             fa_book_controls bc
      where  bc.book_type_code = p_book_type_code
      and    bc.set_of_books_id = je.set_of_books_id
      and    bc.book_type_code = je.book_type_code
      and    je.period_counter = p_period_rec.period_counter
      and    je.je_status in ('C', 'E')
      and    ((addition_batch_id is NOT NULL) or
              (adjustment_batch_id is NOT NULL) or
              (depreciation_batch_id is NOT NULL) or
              (reclass_batch_id is NOT NULL) or
              (retirement_batch_id is NOT NULL) or
              (reval_batch_id is NOT NULL) or
              (transfer_batch_id is NOT NULL) or
              (cip_addition_batch_id is NOT NULL) or
              (cip_adjustment_batch_id is NOT NULL) or
              (cip_reclass_batch_id is NOT NULL) or
              (cip_retirement_batch_id is NOT NULL) or
              (cip_reval_batch_id is NOT NULL) or
              (cip_transfer_batch_id is NOT NULL) or
              (deprn_adjustment_batch_id is NOT NULL));

      select count(*)
      into   l_dp_post_count
      from   fa_deprn_periods
      where  book_type_code = p_book_type_code
      and    period_counter = p_period_rec.period_counter
      and    ((addition_batch_id is NOT NULL) or
              (adjustment_batch_id is NOT NULL) or
              (depreciation_batch_id is NOT NULL) or
              (reclass_batch_id is NOT NULL) or
              (retirement_batch_id is NOT NULL) or
              (reval_batch_id is NOT NULL) or
              (transfer_batch_id is NOT NULL) or
              (cip_addition_batch_id is NOT NULL) or
              (cip_adjustment_batch_id is NOT NULL) or
              (cip_reclass_batch_id is NOT NULL) or
              (cip_retirement_batch_id is NOT NULL) or
              (cip_reval_batch_id is NOT NULL) or
              (cip_transfer_batch_id is NOT NULL) or
              (deprn_adjustment_batch_id is NOT NULL));

   end if;

   if (l_je_post_count <> 0) OR (l_dp_post_count <> 0) then
      fa_srvr_msg.add_message(calling_fn =>l_calling_fn,
                              name       =>'FA_RJE_ROLLBACK_JE_NOT_RUN2', p_log_level_rec => g_log_level_rec);
      raise chk_err;
   end if;




   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'End', 'Success', p_log_level_rec => g_log_level_rec);
   end if;

   return TRUE;
EXCEPTION

   WHEN chk_err THEN
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'chk_err', p_log_level_rec => g_log_level_rec);
      end if;
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      return FALSE;

   WHEN OTHERS THEN
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'OTHERS', p_log_level_rec => g_log_level_rec);
      end if;
      fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      return FALSE;

END check_je_post;

FUNCTION rollback_impairment (p_book_type_code    IN VARCHAR2,
                              p_request_id        IN NUMBER,
                              p_mode              IN VARCHAR2,
                              p_impairment_id     IN NUMBER,
                              p_calling_fn        IN VARCHAR2,
                              p_mrc_sob_type_code IN VARCHAR2,
                              p_set_of_books_id   IN NUMBER) /* Bug 6437003 added p_mrc_sob_type_code to check for set of books type code*/
RETURN BOOLEAN IS

   l_calling_fn varchar2(50) := 'FA_PROCESS_IMPAIRMENT_PKG.rollback_impairment';

   l_new_status   varchar2(30);
   l_status       varchar2(30);

   rbi_err EXCEPTION;
BEGIN

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'BEGIN', ' ', p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_book_type_code', p_book_type_code, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_request_id', p_request_id, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_mode', p_mode, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_impairment_id', p_impairment_id, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_mrc_sob_type_code', p_mrc_sob_type_code, p_log_level_rec => g_log_level_rec);  /* Bug 6437003 displayed the value of p_mrc_sob_type_code */
   end if;

   if p_mode = 'PREVIEW' then
      l_new_status := 'RUNNING DEPRN FAILED';
      l_status     := 'RUNNING DEPRN';
   elsif p_mode = 'POST' or p_impairment_id is not null then
      l_new_status := 'POST FAILED';
      l_status     := 'RUNNING POST';
   else
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Not valid mode', ' rollback failed', p_log_level_rec => g_log_level_rec);
         raise rbi_err;
      end if;
   end if;

   update fa_impairments
   set    status = l_new_status
   where  status = l_status
   and    request_id = p_request_id;

   if p_mrc_sob_type_code = 'R' then /* Bug 6437003 added condition to check for set of books type code*/
      update fa_mc_impairments
      set    status = l_new_status
      where  status = l_status
      and    request_id = p_request_id
      and    set_of_books_id = p_set_of_books_id;
   end if;

   COMMIT; --Bug#7594562 - to commit the new status before exit.

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'End', 'Success', p_log_level_rec => g_log_level_rec);
   end if;

   return TRUE;
EXCEPTION

   WHEN rbi_err THEN
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'rbi_err', p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'sqlerrm', sqlerrm, p_log_level_rec => g_log_level_rec);
      end if;
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      return FALSE;

  /* bug #6658765 - Added NO_DATA_FOUND */
  WHEN NO_DATA_FOUND THEN
      NULL;

   WHEN OTHERS THEN
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'EXCEPTION', 'OTHERS', p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'sqlerrm', sqlerrm, p_log_level_rec => g_log_level_rec);
      end if;
      fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      return FALSE;

END rollback_impairment;


END FA_PROCESS_IMPAIRMENT_PKG;

/
