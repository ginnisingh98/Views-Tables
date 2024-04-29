--------------------------------------------------------
--  DDL for Package Body FA_MASSCP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASSCP_PKG" as
/* $Header: FAMCPB.pls 120.51.12010000.11 2010/04/16 15:37:55 dvjoshi ship $   */

G_success_count number;
G_failure_count number;
G_warning_count number;
G_fatal_error   boolean  := FALSE;
G_request_id    number;
G_times_called  number := 0;

g_release       number  := fa_cache_pkg.fazarel_release;

g_log_level_rec fa_api_types.log_level_rec_type;

TYPE num_tbl  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE date_tbl IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE v30_tbl  IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

-- following variables added to prevent transactions from copying
-- if a prior one failed

g_asset_error1_tbl            num_tbl;  -- incremental used for bulk insert
g_asset_error2_tbl            num_tbl;  -- indexes by asset id used for exists checks

PROCEDURE do_mass_copy (
                p_book_type_code     IN     VARCHAR2,
                p_period_name        IN     VARCHAR2,
                p_period_counter     IN     NUMBER,
                p_mode               IN     NUMBER,
                p_loop_count         IN     NUMBER,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                p_request_number     IN     NUMBER,
                x_success_count         OUT NOCOPY number,
                x_warning_count         OUT NOCOPY number,
                x_failure_count         OUT NOCOPY number,
                x_return_status         OUT NOCOPY number) IS

   -- used for bulk fetching
   l_batch_size                 number;
   l_loop_count                 number := 0;

   -- misc
   l_calling_fn                 varchar2(40) := 'fa_masscp_pkg.do_mass_copy';

   -- used for error counts etc

   rbs_name                     VARCHAR2(30);
   sql_stmt                     VARCHAR2(100);

   l_return_status              VARCHAR2(1);
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(4000);

   -- used for trx info
   l_rowid                      v30_tbl;
   l_asset_id                   num_tbl;
   l_asset_number               v30_tbl;
   l_asset_type                 v30_tbl;
   l_transaction_type_code      v30_tbl;
   l_corp_thid                  num_tbl;
   l_tax_thid                   num_tbl;
   l_asset_id_fail              num_tbl;

   l_cip_in_tax_add             number;
   l_string                     varchar2(250);
   l_orig_src_trx_header_id     number;

   fa_asset_id_fail_tab         fa_num15_tbl_type;
   l_process_status             v30_tbl;

   l_prior_thid                 num_tbl;

   done_exc                     EXCEPTION;
   masscp_err                   EXCEPTION;
   error_found_trx              EXCEPTION;
   error_found_fatal_trx        EXCEPTION;


   -- This cursor now drives off the temp table loaded in allocate workers
   -- for parallelization / allocation
   cursor c_trx (p_parent_request_id number,
                 p_request_number    number,
                 p_process_order     number) is
        select fpw.rowid,
               fpw.asset_id,
               fpw.asset_number,
               fpw.asset_type,
               fpw.transaction_type_code,
               fpw.corp_transaction_header_id,
               fpw.tax_transaction_header_id,
               af.asset_id        same_asset_id_fail
          from fa_parallel_workers      fpw,
               fa_asset_failures_gt     af
         where fpw.request_id                   = p_parent_request_id
           and fpw.process_status               = 'UNASSIGNED'
           and fpw.worker_number                = p_request_number
           and fpw.process_order                = p_process_order
           and af.asset_id(+)                   = fpw.asset_id
         order by fpw.corp_transaction_header_id;

   -- BUG# 5128900
   -- finds all adjustments in period of addition in between
   -- last copied trx and the current addition being copied
   cursor c_prior_adjs (p_asset_id     number,
                        p_corp_book    varchar2,
                        p_start_thid   number,
                        p_end_thid     number) is
       select transaction_header_id
         from fa_transaction_headers
        where asset_id              = p_asset_id
          and book_type_code        = p_corp_book
          and transaction_type_code = 'ADDITION/VOID'
          and transaction_header_id > p_start_thid
          and transaction_header_id < p_end_thid
        order by transaction_header_id;

   -- Bug 5864939
   cursor c_last_copied_trx (p_asset_id number) is
       select source_transaction_header_id
       from fa_transaction_headers
       where book_type_code = p_book_type_code
       and   asset_id = p_asset_id
       and   source_transaction_header_id  is not null
       order by transaction_header_id desc;

BEGIN

   G_request_id   := p_parent_request_id;
   G_times_called := G_times_called + 1;
   g_asset_error1_tbl.delete;
   g_asset_error2_tbl.delete;

   x_success_count := 0;
   x_failure_count := 0;
   x_warning_count := 0;

   G_success_count := 0;
   G_failure_count := 0;
   G_warning_count := 0;

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise masscp_err;
      end if;
   end if;

   g_release  := fa_cache_pkg.fazarel_release;

   -- get book information
   if not fa_cache_pkg.fazcbc(X_book => p_book_type_code, p_log_level_rec => g_log_level_rec) then
      raise masscp_err;
   end if;

   if (g_times_called = 1) then

      if (fa_cache_pkg.fazcbc_record.copy_additions_flag <> 'YES') then
         fnd_message.set_name('OFA', 'FA_MCP_SHARED_NO_COPY');
         fnd_message.set_token('TYPE','ADDITIONS',FALSE);
         l_string := fnd_message.get;
         FND_FILE.put(FND_FILE.output,l_string);
         FND_FILE.new_line(FND_FILE.output,1);
      end if;

      if (fa_cache_pkg.fazcbc_record.copy_adjustments_flag <> 'YES') then
         fnd_message.set_name('OFA', 'FA_MCP_SHARED_NO_COPY');
         fnd_message.set_token('TYPE','ADJUSTMENTS',FALSE);
         l_string := fnd_message.get;
         FND_FILE.put(FND_FILE.output,l_string);
         FND_FILE.new_line(FND_FILE.output,1);
      end if;

      if (fa_cache_pkg.fazcbc_record.copy_retirements_flag <> 'YES') then
         fnd_message.set_name('OFA', 'FA_MCP_SHARED_NO_COPY');
         fnd_message.set_token('TYPE','RETIREMENTS',FALSE);
         l_string := fnd_message.get;
         FND_FILE.put(FND_FILE.output,l_string);
         FND_FILE.new_line(FND_FILE.output,1);
      end if;

      if (nvl(fa_cache_pkg.fazcbc_record.allow_group_deprn_flag, 'N') = 'Y' and
          nvl(fa_cache_pkg.fazcbc_record.copy_group_addition_flag, 'N') <> 'Y') then
         fnd_message.set_name('OFA', 'FA_MCP_SHARED_NO_COPY');
         fnd_message.set_token('TYPE','GROUP ADDITIONS',FALSE);
         l_string := fnd_message.get;
         FND_FILE.put(FND_FILE.output,l_string);
         FND_FILE.new_line(FND_FILE.output,1);
      end if;

      FND_FILE.put(FND_FILE.output,'');
      FND_FILE.new_line(FND_FILE.output,1);

      -- dump out the headings
      fnd_message.set_name('OFA', 'FA_MCP_REPORT_COLUMN');
      l_string := fnd_message.get;

      FND_FILE.put(FND_FILE.output,l_string);
      FND_FILE.new_line(FND_FILE.output,1);

      fnd_message.set_name('OFA', 'FA_MCP_REPORT_LINES');
      l_string := fnd_message.get;

      FND_FILE.put(FND_FILE.output,l_string);
      FND_FILE.new_line(FND_FILE.output,1);

   end if;


   l_batch_size  := nvl(fa_cache_pkg.fa_batch_size, 200);

   if(g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'opening c_trx_parent cursor at', sysdate, p_log_level_rec => g_log_level_rec);
   end if;

   open c_trx(p_parent_request_id => p_parent_request_id,
              p_request_number    => p_request_number,
              p_process_order     => p_loop_count);

   fetch c_trx bulk collect
         into l_rowid,
              l_asset_id,
              l_asset_number,
              l_asset_type,
              l_transaction_type_code,
              l_corp_thid,
              l_tax_thid,
              l_asset_id_fail
        limit l_batch_size;

   close c_trx;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add('test',
                       'after fetch thid count is',
                       l_corp_thid.count, p_log_level_rec => g_log_level_rec);
   end if;


   -- exit the bulk fetch loop when no more rows are retrived
   if l_corp_thid.count = 0 then
      raise done_exc;
   end if;

   -- dump any debug messages from above
   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
   end if;

   for l_loop_count in 1..l_corp_thid.count loop

      -- clear the debug stack for each asset
      FA_DEBUG_PKG.Initialize;
      -- reset the message level to prevent bogus errors
      FA_SRVR_MSG.Set_Message_Level(message_level => 10, p_log_level_rec => g_log_level_rec);

      BEGIN


         -- display the asset/thid in the log for matching back to report
         fa_srvr_msg.add_message
            (calling_fn => null,
             name       => 'FA_SHARED_ASSET_NUMBER',
             token1     => 'NUMBER',
             value1     => l_asset_number(l_loop_count),
             p_log_level_rec => g_log_level_rec);

         fa_srvr_msg.add_message
            (calling_fn => null,
             name       => 'FA_MCP_SHARED_FAILED_THID',
             token1     => 'SOURCE_THID',
             value1     => l_corp_thid(l_loop_count),
             p_log_level_rec => g_log_level_rec);


         -- BUG# 2521472
         -- need to account for cip-in-tax scenario where
         -- the asset was capitalized and adjusted in the
         -- period of addition
         --
         --   CIP ADDITION/VOID -> ADDITION/VOID -> ADDITION
         --
         -- in such a case, the addition row needs to be
         -- processed as an adjustment by mass copy

         -- R12 conditional handling
         -- removing this logic as part of BUG# 5128900
         -- as the VOID logic is obsolete for adjustments
         -- in R12 - an adjustment will always have that trx_type

         -- call the appropriate preocedure for the given transaction

         l_orig_src_trx_header_id := null;

         if (l_transaction_type_code(l_loop_count) = 'ADDITION' and
             l_tax_thid(l_loop_count) is not null and
              G_release = 11) then

            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,
                                'entering',
                                'logic for ADDITION and tax exists', p_log_level_rec => g_log_level_rec);
            end if;

            select source_transaction_header_id
              into l_orig_src_trx_header_id
              from fa_transaction_headers
             where transaction_header_id = l_tax_thid(l_loop_count);

            -- Bug 5864939 start
            -- If l_orig_src_trx_header_id is null populate it with the
            -- transaction_header_id of the last transaction copied from corp book.
            if (l_orig_src_trx_header_id is null) then

               open  c_last_copied_trx (l_asset_id(l_loop_count));

               fetch c_last_copied_trx
               into l_orig_src_trx_header_id;

               -- If tax book contains no transaction copied from
               -- corp book error out.
               if (c_last_copied_trx%notfound) then
                  close c_last_copied_trx;
                  if (g_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn,
                                      'Tax Book contains',
                                      'no transaction copied from corp book', p_log_level_rec => g_log_level_rec);
                  end if;
                  raise error_found_trx;
               end if;

               close c_last_copied_trx;
            end if;
            -- Bug 5864939 end

            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,
                                'Last copied corp book txn',
                                l_orig_src_trx_header_id, p_log_level_rec => g_log_level_rec);
            end if;


           if (l_orig_src_trx_header_id < l_corp_thid(l_loop_count)) then
              if (g_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn,
                                  'processing ADDITION as ADJUSTMENT using source thid of ',
                                  l_orig_src_trx_header_id, p_log_level_rec => g_log_level_rec);
              end if;

              -- BUG# 5128900
              -- loop through all VOIDs in between the last copied
              -- transaction and the ADDITION selected
              if (g_asset_error2_tbl.exists(l_asset_id(l_loop_count)) or
                  l_asset_id_fail(l_loop_count) is not null ) then

                 write_message
                    (p_asset_number    => l_asset_number(l_loop_count),
                     p_thid            => l_corp_thid(l_loop_count),
                     p_message         => 'FA_MCP_PRIOR_TRX_FAILED',
                     p_token           => NULL,
                     p_value           => NULL,
                     p_mode            => 'F');

                 raise error_found_fatal_trx;
              end if;

              if (g_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn,
                                  'finding in between trxs ',
                                  '', p_log_level_rec => g_log_level_rec);
                 fa_debug_pkg.add(l_calling_fn,
                                  'asset id ',
                                  l_asset_id(l_loop_count));
                 fa_debug_pkg.add(l_calling_fn,
                                  'corp book',
                                   fa_cache_pkg.fazcbc_record.distribution_source_book, p_log_level_rec => g_log_level_rec);
                 fa_debug_pkg.add(l_calling_fn,
                                  'start thid',
                                  l_orig_src_trx_header_id, p_log_level_rec => g_log_level_rec);
                 fa_debug_pkg.add(l_calling_fn,
                                  'end thid ',
                                  l_corp_thid(l_loop_count));

              end if;

              open c_prior_adjs (p_asset_id     => l_asset_id(l_loop_count),
                                 p_corp_book    => fa_cache_pkg.fazcbc_record.distribution_source_book,
                                 p_start_thid   => l_orig_src_trx_header_id,
                                 p_end_thid     => l_corp_thid(l_loop_count));

              fetch c_prior_adjs bulk collect
               into l_prior_thid;

              close c_prior_adjs;

              if (l_prior_thid.count = 0) then
                 if (g_log_level_rec.statement_level) then
                    fa_debug_pkg.add(l_calling_fn,
                                     'no ADDITION/VOIDs found',
                                     '', p_log_level_rec => g_log_level_rec);
                 end if;
              end if;

              for x in 1..l_prior_thid.count loop

                 --  Bug 5888273 Start
                 --  Consider each call to mcp_adjustment as a separate
                 --  Transaction (record) and handle the exceptions here itself
                 BEGIN
                    if (g_log_level_rec.statement_level) then
                       fa_debug_pkg.add(l_calling_fn,
                                        'in loop',
                                        '', p_log_level_rec => g_log_level_rec);
                       fa_debug_pkg.add(l_calling_fn,
                                        'calling mcp_adjustment with thid of ',
                                        l_prior_thid(x));
                    end if;

                    mcp_adjustment (
                       p_corp_thid     => l_prior_thid(x),
                       p_asset_id      => l_asset_id(l_loop_count),
                       p_asset_number  => l_asset_number(l_loop_count),
                       p_tax_book      => p_book_type_code,
                       x_return_status => l_return_status);


                    if (l_return_status = FND_API.G_RET_STS_ERROR) then
                       raise error_found_trx;
                    elsif (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
                       raise error_found_fatal_trx;
                    else
                       -- do not set the status on the dependant trxs here!
                       -- l_process_status(l_loop_count) := 'SUCCESS';
                      null;
                    end if;

                 EXCEPTION

                    WHEN error_found_trx THEN
                       FND_CONCURRENT.AF_ROLLBACK;

                       l_process_status(l_loop_count) := 'WARNING';
                       fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

                    WHEN error_found_fatal_trx THEN
                       FND_CONCURRENT.AF_ROLLBACK;

                       l_process_status(l_loop_count) := 'FAILURE';
                       g_asset_error1_tbl(g_asset_error1_tbl.count + 1) := l_asset_id(l_loop_count);
                       g_asset_error2_tbl(l_asset_id(l_loop_count))     := l_asset_id(l_loop_count);

                       fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

                    WHEN OTHERS THEN
                       FND_CONCURRENT.AF_ROLLBACK;

                       l_process_status(l_loop_count) := 'FAILURE';
                       g_asset_error1_tbl(g_asset_error1_tbl.count + 1) := l_asset_id(l_loop_count);
                       g_asset_error2_tbl(l_asset_id(l_loop_count))     := l_asset_id(l_loop_count);

                       g_fatal_error := TRUE;
                       fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

                 END;

                 if (g_log_level_rec.statement_level) then
                     fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
                 end if;

                 -- FND_CONCURRENT.AF_COMMIT each record
                 FND_CONCURRENT.AF_COMMIT;

                 --- Bug 5888273 end
              end loop;

              -- now continue with the transaction in question
              l_transaction_type_code(l_loop_count) := 'ADJUSTMENT';
           end if;

         end if;

         -- call the appropriate preocedure for the given transaction

         if (l_transaction_type_code(l_loop_count) = 'PARTIAL RETIREMENT' or
             l_transaction_type_code(l_loop_count) = 'FULL RETIREMENT' or
             l_transaction_type_code(l_loop_count) = 'REINSTATEMENT' ) then

            if (g_asset_error2_tbl.exists(l_asset_id(l_loop_count)) or
                l_asset_id_fail(l_loop_count) is not null ) then

                write_message
                   (p_asset_number    => l_asset_number(l_loop_count),
                    p_thid            => l_corp_thid(l_loop_count),
                    p_message         => 'FA_MCP_PRIOR_TRX_FAILED',
                    p_token           => NULL,
                    p_value           => NULL,
                    p_mode            => 'F');

               raise error_found_fatal_trx;
            end if;

            mcp_retirement (
                  p_corp_thid     => l_corp_thid(l_loop_count),
                  p_asset_id      => l_asset_id(l_loop_count),
                  p_asset_number  => l_asset_number(l_loop_count),
                  p_tax_book      => p_book_type_code,
                  x_return_status => l_return_status);

         elsif (l_transaction_type_code(l_loop_count) = 'ADDITION' or
                l_transaction_type_code(l_loop_count) = 'GROUP ADDITION') then

            -- note we could check for parent exist here,
            -- but this shoudl be a rare case, so we allow
            -- api to trap it and report fatal error instead

            mcp_addition (
                  p_corp_thid     => l_corp_thid(l_loop_count),
                  p_asset_id      => l_asset_id(l_loop_count),
                  p_asset_number  => l_asset_number(l_loop_count),
                  p_tax_book      => p_book_type_code,
                  p_asset_type    => l_asset_type(l_loop_count),
                  x_return_status => l_return_status);

         elsif (l_transaction_type_code(l_loop_count) = 'ADJUSTMENT') then -- adjustment

            if (g_asset_error2_tbl.exists(l_asset_id(l_loop_count)) or
                l_asset_id_fail(l_loop_count) is not null ) then

                write_message
                   (p_asset_number    => l_asset_number(l_loop_count),
                    p_thid            => l_corp_thid(l_loop_count),
                    p_message         => 'FA_MCP_PRIOR_TRX_FAILED',
                    p_token           => NULL,
                    p_value           => NULL,
                    p_mode            => 'F');

               raise error_found_fatal_trx;
            end if;

            mcp_adjustment (
                  p_corp_thid     => l_corp_thid(l_loop_count),
                  p_asset_id      => l_asset_id(l_loop_count),
                  p_asset_number  => l_asset_number(l_loop_count),
                  p_tax_book      => p_book_type_code,
                  x_return_status => l_return_status);
         else
            raise error_found_trx;
         end if;

         if (l_return_status = FND_API.G_RET_STS_ERROR) then
            raise error_found_trx;
         elsif (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
            raise error_found_fatal_trx;
         else
            l_process_status(l_loop_count) := 'SUCCESS';
         end if;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
         end if;

      EXCEPTION
         -- do not set the fatal error flag here!
         WHEN error_found_trx THEN
            FND_CONCURRENT.AF_ROLLBACK;

            l_process_status(l_loop_count) := 'WARNING';
            fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
            end if;

         WHEN error_found_fatal_trx THEN
            FND_CONCURRENT.AF_ROLLBACK;

            l_process_status(l_loop_count) := 'FAILURE';
            g_asset_error1_tbl(g_asset_error1_tbl.count + 1) := l_asset_id(l_loop_count);
            g_asset_error2_tbl(l_asset_id(l_loop_count))     := l_asset_id(l_loop_count);

            fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
            end if;

         WHEN OTHERS THEN
            FND_CONCURRENT.AF_ROLLBACK;

            l_process_status(l_loop_count) := 'FAILURE';
            g_asset_error1_tbl(g_asset_error1_tbl.count + 1) := l_asset_id(l_loop_count);
            g_asset_error2_tbl(l_asset_id(l_loop_count))     := l_asset_id(l_loop_count);

            g_fatal_error := TRUE;
            fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
            end if;

      END;  -- asset level block

      -- FND_CONCURRENT.AF_COMMIT each record
      FND_CONCURRENT.AF_COMMIT;

   end loop; -- array loop

   -- now flags the rows process status accordingly
   forall i in 1..l_rowid.count
   update fa_parallel_workers mct
      set process_status = l_process_status(i)
    where rowid          = l_rowid(i);

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'rows updated in fa_parallel_workersfor status', sql%rowcount);
   end if;

   FND_CONCURRENT.AF_COMMIT;



   -- now insert all failures into the error table for subsequent loops

   fa_asset_id_fail_tab := fa_num15_tbl_type();

   for i in 1..g_asset_error1_tbl.count loop

      fa_asset_id_fail_tab.EXTEND;
      fa_asset_id_fail_tab(fa_asset_id_fail_tab.last) := g_asset_error1_tbl(i);

   end loop;

   -- since it's possible the same asset could be picked up in multiple
   -- loops, we are using minus here to insure we don't raise ora-1

   insert into fa_asset_failures_gt (asset_id)
   select distinct column_value
     from TABLE(CAST(fa_asset_id_fail_tab AS fa_num15_tbl_type)) trx
    minus
   select asset_id
     from fa_asset_failures_gt;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'rows inserted into fa_asset_failures', g_asset_error1_tbl.count, p_log_level_rec => g_log_level_rec);
   end if;


   x_success_count := G_success_count;
   x_warning_count := G_warning_count;
   x_failure_count := G_failure_count;

   x_return_status := 0;

EXCEPTION
   when done_exc then
      FND_CONCURRENT.AF_ROLLBACK;

      x_success_count := G_success_count;
      x_warning_count := G_warning_count;
      x_failure_count := G_failure_count;

      x_return_status := 0;

   when masscp_err then
      FND_CONCURRENT.AF_ROLLBACK;

      x_success_count := G_success_count;
      x_warning_count := G_warning_count;
      x_failure_count := G_failure_count;

      fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      x_return_status := 2;

   when others then
      FND_CONCURRENT.AF_ROLLBACK;

      x_success_count := G_success_count;
      x_warning_count := G_warning_count;
      x_failure_count := G_failure_count;

      fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      x_return_status := 2;

END do_mass_copy;

----------------------------------------------------------------

procedure mcp_addition
        (p_corp_thid     IN  NUMBER,
         p_asset_id      IN  NUMBER,
         p_asset_number  IN  VARCHAR2,
         p_tax_book      IN  VARCHAR2,
         p_asset_type    IN  VARCHAR2,
         x_return_status OUT NOCOPY VARCHAR2) IS

   -- local variables
   l_count                    NUMBER;
   l_valid                    BOOLEAN;
   l_category_id              number;

   -- used for api call
   l_api_version              NUMBER      := 1.0;
   l_init_msg_list            VARCHAR2(1) := FND_API.G_FALSE;
   l_commit                   VARCHAR2(1) := FND_API.G_FALSE;
   l_validation_level         NUMBER      := FND_API.G_VALID_LEVEL_FULL;
   l_return_status            VARCHAR2(1);
   l_mesg_count               number;
   l_mesg                     VARCHAR2(4000);

   -- local messaging
   l_mesg_name                VARCHAR2(30);
   l_token                    varchar2(40);
   l_value                    varchar2(40);
   l_calling_fn               VARCHAR2(30) := 'fa_masscp_pkg.mcp_addition';

   l_trans_rec                FA_API_TYPES.trans_rec_type;
   l_dist_trans_rec           FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;
   l_asset_desc_rec           FA_API_TYPES.asset_desc_rec_type;
   l_asset_cat_rec            FA_API_TYPES.asset_cat_rec_type;
   l_asset_type_rec           FA_API_TYPES.asset_type_rec_type;
   l_asset_fin_rec            FA_API_TYPES.asset_fin_rec_type;
   l_asset_deprn_rec          FA_API_TYPES.asset_deprn_rec_type;
   l_asset_dist_rec           FA_API_TYPES.asset_dist_rec_type;
   l_asset_dist_tbl           FA_API_TYPES.asset_dist_tbl_type;
   l_inv_tbl                  FA_API_TYPES.inv_tbl_type;
   l_asset_hierarchy_rec      FA_API_TYPES.asset_hierarchy_rec_type;

   l_corp_asset_hdr_rec       FA_API_TYPES.asset_hdr_rec_type;
   l_corp_asset_fin_rec       FA_API_TYPES.asset_fin_rec_type;

   val_err1                   EXCEPTION; -- invalid, non fatal
   add_err1                   EXCEPTION; -- warning
   add_err2                   EXCEPTION; -- fatal

BEGIN

   if NOT fa_cache_pkg.fazcbc(X_book => p_tax_book, p_log_level_rec => g_log_level_rec) then
      raise add_err1;
   end if;

   if (p_asset_type = 'GROUP' and
       nvl(fa_cache_pkg.fazcbc_record.copy_group_addition_flag, 'N') = 'N') then

       l_mesg_name := 'FA_MCP_SHARED_NO_COPY';
       l_token     := 'TYPE';
       l_value     := 'GROUP ADDITIONS';

       raise add_err1;
   elsif (p_asset_type <> 'GROUP' and
          fa_cache_pkg.fazcbc_record.copy_additions_flag = 'NO') then

       l_mesg_name := 'FA_MCP_SHARED_NO_COPY';
       l_token     := 'TYPE';
       l_value     := 'ADDITIONS';

       raise add_err1;
   end if;

   -- get prorate
   -- percent salvage stuff (handled in API)
   -- start logic form fampvt

   BEGIN

      -- cat not in tax (handled in api but placing here to avoid fatal error)
      select asset_category_id
        into l_category_id
        from fa_additions_b
       where asset_id = p_asset_id;

      if not fa_cache_pkg.fazccb (
               X_Book    => p_tax_book,
               X_Cat_Id  => l_category_id
             , p_log_level_rec => g_log_level_rec) then
             l_mesg_name := 'FA_MCP_CAT_NOT_IN_TAX';
             raise val_err1;
      end if;

      -- cursor to check asset added flags etc used below
      -- retire pending    - invalid for additions
      -- pending unit adj  - obsolete

      -- already exists in tax
      -- (this is handled in api automatically so not needed
      --  but including to avoid fatal error)

      if not fa_asset_val_pvt.validate_asset_book
        (p_transaction_type_code      => 'ADDITION',
         p_book_type_code             => p_tax_book,
         p_asset_id                   => p_asset_id,
         p_calling_fn                 => l_calling_fn
        , p_log_level_rec => g_log_level_rec)then
         l_mesg_name := 'FA_MCP_ASSET_IN_TAX_ALREADY';
         raise val_err1;
      end if;

      -- valid prorate date (API) - intentionally treat as fatal

      -- verify asset was capitalized and retired in same period
      -- if so, don't copy the addition

      select count(*)
        into l_count
        from fa_books                corp_bk,
             fa_deprn_periods        dp,
             fa_transaction_headers  corp_th
       where corp_bk.transaction_header_id_in   = corp_th.transaction_header_id
         and corp_bk.book_type_code             = fa_cache_pkg.fazcbc_record.distribution_source_book
         and corp_bk.asset_id                   = p_asset_id
         and corp_bk.book_type_code             = dp.book_type_code
         and corp_bk.period_counter_capitalized = dp.period_counter
         and corp_th.date_effective between
             dp.period_open_date and nvl(dp.period_close_date, sysdate)
         and corp_th.transaction_type_code      like '%RETIREMENT';

      if (l_count <> 0 and G_release = 11) then
         l_mesg_name := 'FA_MCP_CHECK_ASSET_CAP';
         raise val_err1;
      end if;


      -- Check if PRODUCTION rsr in tax, but not in corp
      -- handled in the calculation engine already
      -- note: previously this did not result in fatal error,
      -- but leaving as is for now.

      l_valid := TRUE;

   EXCEPTION
      when val_err1 then
         l_valid := FALSE;
      when others then
         l_valid := FALSE;
   END;

   if (l_valid) then

      -- logic from famppc
      -- select corp value
      -- do salvage calc for japan

      -- ceiling stuff (from cbd) should be handled in api
      -- copy itc from corp???? yikes

      -- end famppc

      -- rounding falg - handled in api
      -- remaining life for child - api
      -- Salvage Value Requirement for Japan (handled in api)

      -- short tax values - handled in api

      -- load the structs
      l_asset_hdr_rec.asset_id       := p_asset_id;
      l_asset_hdr_rec.book_type_code := p_tax_book;

      l_trans_rec.source_transaction_header_id := p_corp_thid;
      l_trans_rec.calling_interface            := 'FAMCP';
      l_trans_rec.mass_reference_id            := G_request_id;

      -- BUG# 2707210
      -- need to load the values from corp thid otherwise
      -- if books aren't in sync, the tax addition will always
      -- get the current corporate cost (even from later periods)
      -- deriving this here as initialize code in api will just
      -- get current info

      select decode(p_asset_type,
                    'GROUP', 0,
                    cost),
             date_placed_in_service,
             group_asset_id,
             salvage_type,
             percent_salvage_value,
             salvage_value
        into l_asset_fin_rec.cost,
             l_asset_fin_rec.date_placed_in_service,
             l_asset_fin_rec.group_asset_id,
             l_asset_fin_rec.salvage_type,
             l_asset_fin_rec.percent_salvage_value,
             l_asset_fin_rec.salvage_value
        from fa_books
       where asset_id = p_asset_id
         and book_type_code = fa_cache_pkg.fazcbc_record.distribution_source_book
         and transaction_header_id_in = p_corp_thid;

      -- set the group asset and salvage information according to options
      -- selected in book controls.  last option will force null inside the addition api

      if (nvl(fa_cache_pkg.fazcbc_record.copy_group_assignment_flag, 'N') = 'N') then
         l_asset_fin_rec.group_asset_id := null;
      end if;

      if (nvl(fa_cache_pkg.fazcbc_record.copy_salvage_value_flag, 'NO') = 'NO') then
         l_asset_fin_rec.salvage_type          := null;
         l_asset_fin_rec.percent_salvage_value := null;
         l_asset_fin_rec.salvage_value         := null;
      end if;

      -- for group assets we will copy the group related flags from the
      -- corporate book - if we offer category defaulting, we can
      -- change this

      if (p_asset_type = 'GROUP') then

         l_corp_asset_hdr_rec.asset_id       := p_asset_id;
         l_corp_asset_hdr_rec.book_type_code := fa_cache_pkg.fazcbc_record.distribution_source_book;

         if not FA_UTIL_PVT.get_asset_fin_rec
                 (p_asset_hdr_rec         => l_corp_asset_hdr_rec,
                  px_asset_fin_rec        => l_corp_asset_fin_rec,
                  p_transaction_header_id => p_corp_thid,
                  p_mrc_sob_type_code     => 'P'
                 , p_log_level_rec => g_log_level_rec) then raise add_err1;
         end if;

         --HH Validate disabled_flag
         --We don't want to copy from/to a disabled group.
         if not FA_ASSET_VAL_PVT.validate_disabled_flag
                  (p_group_asset_id  => l_corp_asset_hdr_rec.asset_id,
                   p_book_type_code  => l_corp_asset_hdr_rec.book_type_code,
                   p_old_flag        => l_corp_asset_fin_rec.disabled_flag,
                   p_new_flag        => l_corp_asset_fin_rec.disabled_flag
                  , p_log_level_rec => g_log_level_rec) then
            l_mesg_name := 'FA_MCP_GRP_DISABLED';
            raise add_err1;
         end if; --End HH

         l_asset_fin_rec.cost := 0;
         --HH add disabled_flag as null
         l_asset_fin_rec.disabled_flag := NULL;

         l_asset_fin_rec.over_depreciate_option          := l_corp_asset_fin_rec.over_depreciate_option;
         l_asset_fin_rec.super_group_id                  := l_corp_asset_fin_rec.super_group_id;
         l_asset_fin_rec.reduction_rate                  := l_corp_asset_fin_rec.reduction_rate;
         l_asset_fin_rec.reduce_addition_flag            := l_corp_asset_fin_rec.reduce_addition_flag;
         l_asset_fin_rec.reduce_adjustment_flag          := l_corp_asset_fin_rec.reduce_adjustment_flag;
         l_asset_fin_rec.reduce_retirement_flag          := l_corp_asset_fin_rec.reduce_retirement_flag;
         l_asset_fin_rec.recognize_gain_loss             := l_corp_asset_fin_rec.recognize_gain_loss;
         l_asset_fin_rec.recapture_reserve_flag          := l_corp_asset_fin_rec.recapture_reserve_flag;
         l_asset_fin_rec.limit_proceeds_flag             := l_corp_asset_fin_rec.limit_proceeds_flag;
         l_asset_fin_rec.terminal_gain_loss              := l_corp_asset_fin_rec.terminal_gain_loss;
         l_asset_fin_rec.tracking_method                 := l_corp_asset_fin_rec.tracking_method;
         l_asset_fin_rec.exclude_fully_rsv_flag          := l_corp_asset_fin_rec.exclude_fully_rsv_flag;
         l_asset_fin_rec.excess_allocation_option        := l_corp_asset_fin_rec.excess_allocation_option;
         l_asset_fin_rec.depreciation_option             := l_corp_asset_fin_rec.depreciation_option;
         l_asset_fin_rec.member_rollup_flag              := l_corp_asset_fin_rec.member_rollup_flag;
         l_asset_fin_rec.allocate_to_fully_rsv_flag      := l_corp_asset_fin_rec.allocate_to_fully_rsv_flag;
         l_asset_fin_rec.allocate_to_fully_ret_flag      := l_corp_asset_fin_rec.allocate_to_fully_ret_flag;

      end if;


      FA_ADDITION_PUB.do_addition
         (p_api_version             => 1.0,
          p_init_msg_list           => FND_API.G_FALSE,
          p_commit                  => FND_API.G_FALSE,
          p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
          x_return_status           => l_return_status,
          x_msg_count               => l_mesg_count,
          x_msg_data                => l_mesg,
          p_calling_fn              => null,
          px_trans_rec              => l_trans_rec,
          px_dist_trans_rec         => l_dist_trans_rec,
          px_asset_hdr_rec          => l_asset_hdr_rec,
          px_asset_desc_rec         => l_asset_desc_rec,
          px_asset_type_rec         => l_asset_type_rec,
          px_asset_cat_rec          => l_asset_cat_rec,
          px_asset_hierarchy_rec    => l_asset_hierarchy_rec,
          px_asset_fin_rec          => l_asset_fin_rec,
          px_asset_deprn_rec        => l_asset_deprn_rec,
          px_asset_dist_tbl         => l_asset_dist_tbl,
          px_inv_tbl                => l_inv_tbl
         );

      if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
         l_mesg_name := 'FA_MCP_FAIL_THID';
         raise add_err2;
      end if;
   else --invalid
      raise add_err1;
   end if;  -- if valid


   -- dump success to log
   if (p_asset_type = 'GROUP') then
      l_mesg_name := 'FA_MCP_GRP_ADDITION_SUCCESS';
   else
      l_mesg_name := 'FA_MCP_ADDITION_SUCCESS';
   end if;

   write_message
        (p_asset_number    => p_asset_number,
         p_thid            => p_corp_thid,
         p_message         => l_mesg_name,
         p_token           => l_token,
         p_value           => l_value,
         p_mode            => 'S');

   X_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   when add_err1 then
      -- non-fatal
      write_message
        (p_asset_number    => p_asset_number,
         p_thid            => p_corp_thid,
         p_message         => l_mesg_name,
         p_token           => l_token,
         p_value           => l_value,
         p_mode            => 'W');
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      x_return_status :=  FND_API.G_RET_STS_ERROR;

   when add_err2 then
      -- fatal
      write_message
        (p_asset_number    => p_asset_number,
         p_thid            => p_corp_thid,
         p_message         => l_mesg_name,
         p_token           => l_token,
         p_value           => l_value,
         p_mode            => 'F');
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;

   when others then
      -- fatal
      fa_srvr_msg.add_sql_error(calling_fn => null, p_log_level_rec => g_log_level_rec);
      write_message
        (p_asset_number    => p_asset_number,
         p_thid            => p_corp_thid,
         p_message         => 'FA_MCP_FAIL_THID',
         p_token           => null,
         p_value           => null,
         p_mode            => 'F');
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;


END mcp_addition;


----------------------------------------------------------------

procedure mcp_adjustment
        (p_corp_thid     IN  NUMBER,
         p_asset_id      IN  NUMBER,
         p_asset_number  IN  VARCHAR2,
         p_tax_book      IN  VARCHAR2,
         x_return_status OUT NOCOPY VARCHAR2) IS

   -- local variables
   l_copy_abs_cost_flag           varchar2(1);
   l_trx_date_entered             date;
   l_trx_subtype                  varchar2(9);
   l_delta_cost                   number;
   l_delta_salvage_value          number;
   l_delta_salvage_percent        number;
   l_change_in_salvage_type       boolean;
   l_valid_salvage_change         boolean;
   l_salvage_change               boolean;

   l_delta_capacity               number;
   l_cost_sign                    NUMBER;
   l_rec_cost_sign                NUMBER;
   l_fraction                     NUMBER;
   l_precision                    NUMBER;
   l_percent_salvage              NUMBER;
   l_tax_new_salvage_type         VARCHAR2(30);
   l_tax_new_salvage_value        NUMBER;
   l_tax_new_salvage_percent      NUMBER;


   -- used for method cache
   l_corp_old_rsr                 VARCHAR2(10);
   l_corp_new_rsr                 VARCHAR2(10);
   l_tax_rsr                      VARCHAR2(10);

   l_valid                        BOOLEAN;      -- used for the validation from fapmvt
   l_count                        NUMBER;


   -- used for getting current and old values for corp and tax
   l_asset_id                     number;
   l_category_id                  number;
   l_parent_asset                 number;
   l_tax_dpis                     date;
   l_corp_old_cost                number;
   l_corp_old_salvage_type        varchar2(30);
   l_corp_old_salvage_value       number;
   l_corp_old_salvage_percent     number;
   l_corp_old_capacity            number;
   l_corp_old_unrevalued_cost     number;
   l_corp_new_cost                number;
   l_corp_new_salvage_type        varchar2(30);
   l_corp_new_salvage_value       number;
   l_corp_new_salvage_percent     number;
   l_corp_new_capacity            number;
   l_corp_new_unrevalued_cost     number;
   l_corp_old_deprn_method_code   varchar2(15);
   l_corp_new_deprn_method_code   varchar2(15);
   l_corp_old_life                number;
   l_corp_new_life                number;

   -- new group code
   l_corp_old_group_asset_id      number;
   l_corp_new_group_asset_id      number;

   l_tax_cost                     number;
   l_tax_salvage_type             varchar2(30);
   l_tax_salvage_value            number;
   l_tax_salvage_percent          number;
   l_tax_capacity                 number;
   l_tax_unrevalued_cost          number;
   l_tax_deprn_method_code        varchar2(15);
   l_tax_life                     number;
   l_tax_life_complete            number;
   l_tax_group_asset_id           number;

   -- variables and structs used for api call
   l_api_version                  NUMBER      := 1.0;
   l_init_msg_list                VARCHAR2(1) := FND_API.G_FALSE;
   l_commit                       VARCHAR2(1) := FND_API.G_FALSE;
   l_validation_level             NUMBER      := FND_API.G_VALID_LEVEL_FULL;
   l_return_status                VARCHAR2(1);
   l_mesg_count                   number;
   l_mesg                         VARCHAR2(4000);

   -- local messaging
   l_mesg_name                    VARCHAR2(30);
   l_token                        varchar2(40);
   l_value                        varchar2(40);
   l_calling_fn                   VARCHAR2(30) := 'fa_masscp_pkg.mcp_adjustment';

   l_trans_rec                    FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec                FA_API_TYPES.asset_hdr_rec_type;
   l_asset_fin_rec_adj            FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_rec_new            FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_mrc_tbl_new        FA_API_TYPES.asset_fin_tbl_type;
   l_inv_trans_rec                FA_API_TYPES.inv_trans_rec_type;
   l_inv_tbl                      FA_API_TYPES.inv_tbl_type;
   l_asset_deprn_rec_adj          FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_rec_new          FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_mrc_tbl_new      FA_API_TYPES.asset_deprn_tbl_type;
   l_group_reclass_options_rec    FA_API_TYPES.group_reclass_options_rec_type;
   l_group_change                 boolean;
   l_group_reclass_type           FA_TRX_REFERENCES.src_transaction_subtype%type;


   val_err1                       EXCEPTION;  -- invalid
   val_err2                       EXCEPTION;  -- invalid but ok for capacity

   adj_err1                       EXCEPTION;  -- warning
   adj_err2
   EXCEPTION;  -- fatal
  --Bug6332519
   l_amortization_start_date      date;
   --Added corp_th.amortization_start_date to the following cursor
   CURSOR c_adjustment IS
        select  corp_th.asset_id,
                ad.asset_category_id,
                corp_th.transaction_date_entered,
                corp_th.amortization_start_date,
                nvl(corp_th.transaction_subtype, 'EXPENSED'),
                tax_bk.date_placed_in_service,              -- changed as shouldn't this be tax for ccbd cache
                nvl(ad.parent_asset_id, -1),
                corp_bk_old.cost,
                corp_bk_old.salvage_type,
                corp_bk_old.salvage_value,
                corp_bk_old.percent_salvage_value,
                nvl(corp_bk_old.production_capacity, 0),
                corp_bk_old.unrevalued_cost,
                corp_bk_new.cost,
                corp_bk_new.salvage_type,
                corp_bk_new.salvage_value,
                corp_bk_new.percent_salvage_value,
                nvl(corp_bk_new.production_capacity, 0),
                corp_bk_new.unrevalued_cost,
                corp_bk_old.deprn_method_code,
                corp_bk_new.deprn_method_code,
                corp_bk_old.life_in_months,
                corp_bk_new.life_in_months,
                corp_bk_old.group_asset_id,
                corp_bk_new.group_asset_id,
                tax_bk.cost,
                tax_bk.salvage_type,
                tax_bk.salvage_value,
                tax_bk.percent_salvage_value,
                nvl(tax_bk.production_capacity, 0),
                tax_bk.unrevalued_cost,
                tax_bk.deprn_method_code,
                tax_bk.life_in_months,
                decode(tax_bk.period_counter_fully_reserved,null,
                       (nvl(tax_bk.period_counter_life_complete,0)), 0),
                tax_bk.group_asset_id
         from   fa_asset_history                ah,
                fa_transaction_headers          corp_th,
                fa_additions_b                  ad,
                fa_books                        corp_bk_new,
                fa_books                        corp_bk_old,
                fa_books                        tax_bk
        where   corp_th.transaction_header_id         = p_corp_thid
          and   corp_th.asset_id                      = ah.asset_id
          and   ah.date_ineffective                  is null
          and   ah.asset_type                         = 'CAPITALIZED'
          and   ad.asset_id                           = corp_th.asset_id
          and   corp_bk_new.transaction_header_id_in  = p_corp_thid
          and   corp_bk_old.transaction_header_id_out = p_corp_thid
          and   tax_bk.asset_id                       = corp_th.asset_id
          and   tax_bk.book_type_code                 = p_tax_book
          and   tax_bk.date_ineffective              is null;

      cursor c_trx_subtype is
      select ref.src_transaction_subtype
      from   FA_TRX_REFERENCES ref, fa_transaction_headers th
      where  th.transaction_header_id = p_corp_thid
      and    ref.trx_reference_id = th.trx_reference_id;

BEGIN

   if NOT fa_cache_pkg.fazcbc(X_book => p_tax_book, p_log_level_rec => g_log_level_rec) then
      raise adj_err1;
   end if;

   -- get the copy absolute cost profile option
   fnd_profile.get('FA_MCP_ALL_COST_ADJ', l_copy_abs_cost_flag);
--Bug6332519
-- Added l_amortization_start_date
   open c_adjustment;
   fetch c_adjustment
    into l_asset_id,
         l_category_id,
         l_trx_date_entered,
         l_amortization_start_date,
         l_trx_subtype,
         l_tax_dpis,
         l_parent_asset,
         l_corp_old_cost,
         l_corp_old_salvage_type,
         l_corp_old_salvage_value,
         l_corp_old_salvage_percent,
         l_corp_old_capacity,
         l_corp_old_unrevalued_cost,
         l_corp_new_cost,
         l_corp_new_salvage_type,
         l_corp_new_salvage_value,
         l_corp_new_salvage_percent,
         l_corp_new_capacity,
         l_corp_new_unrevalued_cost,
         l_corp_old_deprn_method_code,
         l_corp_new_deprn_method_code,
         l_corp_old_life,
         l_corp_new_life,
         l_corp_old_group_asset_id,
         l_corp_new_group_asset_id,
         l_tax_cost,
         l_tax_salvage_type,
         l_tax_salvage_value,
         l_tax_salvage_percent,
         l_tax_capacity,
         l_tax_unrevalued_cost,
         l_tax_deprn_method_code,
         l_tax_life,
         l_tax_life_complete,
         l_tax_group_asset_id;
    if (c_adjustment%notfound) then
       close c_adjustment;
       l_mesg_name := 'FA_MCP_ASSET_NOT_IN_TAX';
       raise adj_err1;
    end if;
    close c_adjustment;

    -- BUG# 2661925
    -- need to check if the trx date is in the future
    -- to account for various calendars, reject if so
    -- this new logic replaces the following fix to redefault date:

    -- BUG# 2428815, if transaction date falls in a future period,
    -- then reset it to the normal defaulting mechanism using the
    -- current period note that the tax period was the last one
    -- loaded into the deprn period cache via the call to
    -- get_deprn_period above.

    if (l_trx_date_entered > fa_cache_pkg.fazcdp_record.calendar_period_close_date) then
        l_mesg_name := 'FA_MCP_SHARED_FUTURE_COPY';

        raise adj_err1;
    end if;

    -- set the deltas - salvage derived later for japan requirements

    l_delta_cost     := l_corp_new_cost -
                        l_corp_old_cost;
    l_delta_capacity := nvl(l_corp_new_capacity,0) -
                        nvl(l_corp_old_capacity,0);

    if (fa_cache_pkg.fazcbc_record.copy_adjustments_flag = 'NO' and
        l_delta_capacity = 0) then

        l_mesg_name := 'FA_MCP_SHARED_NO_COPY';
        l_token     := 'TYPE';
        l_value     := 'ADJUSTMENTS';

        raise adj_err1;
    end if;


    if(l_trx_subtype = 'AMORTIZED' and
       fa_cache_pkg.fazcbc_record.amortize_flag = 'NO' and
       l_delta_capacity = 0) then

        l_mesg_name := 'FA_MCP_SHARED_NO_COPY';
        l_token     := 'TYPE';
        l_value     := 'AMORTIZED ADJUSTMENTS';

        raise adj_err1;
    end if;

-- =====================================================================
-- MacDonald's ER
-- we force the sub type to EXPENSED if it is AMORTIZED and the copy flag is set
-- fa_cache_pkg.fazcbc_record.amortize_flag = 'NO' - should we check for this?
--
    if(l_trx_subtype = 'AMORTIZED' and
       NVL(fa_cache_pkg.fazcbc_record.copy_amort_adaj_exp_flag,'N') = 'Y' AND
       fa_cache_pkg.fazcbc_record.copy_adjustments_flag = 'YES'  ) then
       l_trx_subtype := 'EXPENSED';
    end if;
-- =======================================================================

    -- here's where we handle salvage change
    -- drastically changed for group
    -- further changed for BUG# 4725962

    if (l_corp_old_salvage_type             <> l_corp_new_salvage_type or
        (nvl(l_corp_old_salvage_value, 0)   <> nvl(l_corp_new_salvage_value, 0) and
         l_corp_old_salvage_type             = 'AMT') or
        (nvl(l_corp_old_salvage_percent, 0) <> nvl(l_corp_new_salvage_percent, 0) and
         l_corp_old_salvage_type             = 'PCT'))  then

       l_salvage_change := TRUE;

       if ((l_tax_salvage_type                  = 'AMT' and
            nvl(l_corp_old_salvage_value, 0)   <> nvl(l_tax_salvage_value, 0)) or
           (l_tax_salvage_type                  = 'PCT' and
            nvl(l_corp_old_salvage_percent, 0) <> nvl(l_tax_salvage_percent, 0)) or
           (l_tax_salvage_type                 <> l_corp_old_salvage_type)) then

          l_valid_salvage_change   := FALSE;
          l_delta_salvage_value    := null;
          l_delta_salvage_percent  := null;
          l_tax_new_salvage_type   := null;

       else

          if (l_corp_old_salvage_type <> l_corp_new_salvage_type) then
             l_delta_salvage_value   := nvl(l_corp_new_salvage_value, 0);
             l_delta_salvage_percent := nvl(l_corp_new_salvage_percent, 0);
          else
             l_delta_salvage_value   := nvl(l_corp_new_salvage_value, 0) -
                                        nvl(l_corp_old_salvage_value, 0);

             l_delta_salvage_percent := nvl(l_corp_new_salvage_percent, 0) -
                                        nvl(l_corp_old_salvage_percent, 0);
          end if;

          l_tax_new_salvage_type      := l_corp_new_salvage_type;

          -- if no effective change, clear the values
          if (l_tax_new_salvage_type    = 'PCT') then
             l_delta_salvage_value     := null;
          elsif (l_tax_new_salvage_type = 'AMT') then
             l_delta_salvage_percent   := null;
          end if;

          l_valid_salvage_change := TRUE;

       end if;
    else

       l_salvage_change         := FALSE;
       l_valid_salvage_change   := FALSE;
       l_delta_salvage_value    := null;
       l_delta_salvage_percent  := null;
       l_tax_new_salvage_type   := null;

    end if;
      if ( nvl(l_corp_old_group_asset_id,-99) <> nvl(l_corp_new_group_asset_id,-99) ) then
         l_group_change := TRUE;
      else
         l_group_change := FALSE;
      end if;


    if (g_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'l_tax_new_salvage_type',  l_tax_new_salvage_type, p_log_level_rec => g_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'l_delta_salvage_value',   l_delta_salvage_value, p_log_level_rec => g_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'l_delta_salvage_percent', l_delta_salvage_percent, p_log_level_rec => g_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'l_valid_salvage_change',  l_valid_salvage_change, p_log_level_rec => g_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'l_salvage_change',        l_salvage_change, p_log_level_rec => g_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'l_group_change',          l_group_change, p_log_level_rec => g_log_level_rec);
    end if;



    -- most validation is handled in the adjustment api itself
    -- including salvage defaulting, etc ** double check **

    -- start validation (from fampvt in fampck.lpc)
    BEGIN

    -- start shared
       -- check h_ind, cat not in tax                          - done in api
       -- big select merged into one
       -- verify that the assets was not previously amortized  - done in api
       -- check for pending unit adj - obsolete
       -- check for cap in this same period as ret - used only for additions

    -- start non addition
       -- asset not in tax - handled in above cursor
       -- check prorate - not needed handled in api

       -- check if trxs follow (old alias th4) - keeping for non-fatal
       -- BUG# 3028986
       -- removing as there is no reason to prevent overlaps for
       -- adjustment transactions: expensed will always use date defaulting
       -- logic and amortized can always overlap now with faxaam


       -- pending ret/reinstate
       -- non reistatement
          -- check fully retired in tax (done in api)
          -- check if manual retirements were ever entered in tax
              select count (*)
                into l_count
                from fa_transaction_headers  th
               where th.book_type_code = p_tax_book
                 and th.asset_id       = l_asset_id
                 and th.transaction_type_code in
                     ('FULL RETIREMENT', 'PARTIAL RETIREMENT', 'REINSTATEMENT')
                 and th.source_transaction_header_id is null;

             if l_count <> 0 then
                l_mesg_name := 'FA_MCP_RET_MANUAL_TAX';
                raise val_err1;
             end if;

      -- end shared
      -- begin add only
      -- begin adjustment only
         -- costs retrieved in select above
         -- ALL EXCLUSIONS THAT DO NOT PERMIT CAPACITY ADJUSTMENTS
         -- MUST BE CHECKED BEFORE ALLOWING THE CAPACITY ADJUSTMENT
         -- EXCEPTIONS (valid = INVALID, capacity_adj_flag = TRUE,
         -- which will continue the copy of the capacity ONLY!)

         -- check costs

         -- Cannot copy salvage value if that is the only change
         -- and copy salvage value is not 'YES'

         -- Cannot copy SV adjustments where CORP SV before adj <> TAX SV
         -- modified for group enhancements to account for changes
         -- in type and percentage as well

         if (nvl(fa_cache_pkg.fazcbc_record.copy_salvage_value_flag, 'NO') = 'NO') then

            if ((l_delta_cost     =  0) and
                (l_delta_capacity =  0) and
                (l_salvage_change)) then
               l_mesg_name  := 'FA_MCP_SHARED_NO_COPY';
               l_token      := 'TYPE';
               l_value      := 'SALVAGE VALUE ADJUSTMENTS';
               raise val_err1;
            else
               -- continue if other portion of adjustment is valid
               l_delta_salvage_value     := null;
               l_delta_salvage_percent   := null;
               l_tax_new_salvage_type    := null;
               l_valid_salvage_change    := FALSE;
            end if;

         elsif (l_salvage_change and
                not l_valid_salvage_change) then
            if((l_delta_cost     =  0) and
               (l_delta_capacity =  0)) then
               l_mesg_name := 'FA_MCP_DIFF_SV_TAX_CORP';
               raise val_err1;
            else
               -- continue if other portion of adjustment is valid
               l_delta_salvage_value     := null;
               l_delta_salvage_percent   := null;
               l_tax_new_salvage_type    := null;
            end if;
         end if;

         -- Cannot do adjustment if asset is beyond useful life
         -- (tax's period_counter_life_complete is not null).

         if (l_tax_life_complete <> 0) then
            l_mesg_name := 'FA_MCP_PAST_USEFUL_LIFE';
            raise val_err1;
         end if;


         -- Cannot copy adjustments where corp method is prod, but tax is not
         -- a prod method

         -- Get rsr for old corp deprn_method
         if not fa_cache_pkg.fazccmt
                  (X_method                => l_corp_old_deprn_method_code,
                   X_life                  => l_corp_old_life
                  , p_log_level_rec => g_log_level_rec) then
            l_mesg_name := 'FA_MCP_FAIL_THID';
            raise val_err1;
         end if;

         l_corp_old_rsr := fa_cache_pkg.fazccmt_record.rate_source_rule;

         -- Get rsr for new corp deprn_method
         if not fa_cache_pkg.fazccmt
                  (X_method                => l_corp_new_deprn_method_code,
                   X_life                  => l_corp_new_life
                  , p_log_level_rec => g_log_level_rec) then
            l_mesg_name := 'FA_MCP_FAIL_THID';
            raise val_err1;
         end if;

         l_corp_new_rsr := fa_cache_pkg.fazccmt_record.rate_source_rule;

         -- Get rsr for tax.deprn_method
         if not fa_cache_pkg.fazccmt
                  (X_method                => l_tax_deprn_method_code,
                   X_life                  => l_tax_life
                  , p_log_level_rec => g_log_level_rec) then
             l_mesg_name := 'FA_MCP_FAIL_THID';
             raise val_err1;
         end if;

         l_tax_rsr := fa_cache_pkg.fazccmt_record.rate_source_rule;


         -- Cannot copy adjustments that are not cost adjustments,
         -- OR salvage value adjustments
         -- OR production capacity adjustments

         -- Also don't copy method adjustments that result in
         -- capacity changes (ie. non-prod to prod method)

         if ((l_delta_cost      = 0)  and
             (not l_valid_salvage_change)   and
             (l_delta_capacity  = 0) and
             (not l_group_change)) or
            ((l_corp_old_rsr   <> l_corp_new_rsr) and
             (l_delta_capacity <> 0)) then

            l_mesg_name := 'FA_MCP_INVALID_ADJ_COPY';
            raise val_err1;
         end if;

         -- Cannot copy prod cap change if TAX asset not production
         if ((l_tax_rsr <> l_corp_new_rsr) and
              l_delta_capacity <> 0) then
            l_mesg_name := 'FA_MCP_CANNOT_ADJ_PC_TAX';
            raise val_err1;
         end if;

         -- Cannot copy adjustments where corp prod cap <> tax prod cap
         if (l_corp_old_capacity <> l_tax_capacity) then
            l_mesg_name := 'FA_MCP_DIFF_PROD_CAP';
            raise val_err1;
         end if;

         -- TESTS FOR EXCLUSIONS FROM THIS POINT ON CAN ALLOW
         -- CAPACITY ADJUSTMENT COPY TO CONTINUE IF THEY FAIL
         -- (valid = INVALID, capacity_adj_flag = TRUE)

         -- Amortized adjustments are not allowed in TAX book
         if (fa_cache_pkg.fazcbc_record.amortize_flag = 'NO' and
            l_trx_subtype = 'AMORTIZED') then

            l_mesg_name := 'FA_MCP_NO_AMORT_ADJS';
            l_trx_subtype := 'EXPENSED';
            raise val_err2;
         end if;


        -- Exp adj is not allowed after Amort adj in TAX BOOK
        -- this is handled in api, how about cap - should be able to pu in adj engine ???
        if l_trx_subtype = 'EXPENSED' then
           if not FA_ASSET_VAL_PVT.validate_exp_after_amort
                   (p_asset_id     => l_asset_id,
                    p_book         => p_tax_book
                   , p_log_level_rec => g_log_level_rec) then

              l_mesg_name := 'FA_MCP_EXPENSE_AFTER_AMORT';
              l_trx_subtype := 'AMORTIZED';
              raise val_err2;

           end if; -- amort exist
        end if; -- expensed

        -- done capacity adj specific checks
        -- checks for negative recoverable cost
        -- handled in adjustment api ???if not maybe add it???

        l_cost_sign := sign(l_corp_new_cost);


        -- modifications to salvage as part of group
        -- removing orginal validations on cost sign changes here
        -- this will be caught by new flag in book controls and by api in such rare cases

        -- only check costs when the absolute profile is not enabled
        if (nvl(l_copy_abs_cost_flag, 'N') <> 'Y') then

           -- Cannot copy cost adjustments where corp unrev cost <> tax unrev cost
           if (l_delta_cost <> 0 and
               l_corp_old_unrevalued_cost <> l_tax_unrevalued_cost) then

              l_mesg_name := 'FA_MCP_DIFF_UNREV_COST';
              raise val_err1;
           end if;

           -- Cannot copy adjustments that have TAX cost that
           -- are different than before-change CORP cost
           if (l_corp_old_cost <> l_tax_cost) then
              l_mesg_name := 'FA_MCP_DIFF_COST';
              raise val_err1;
           end if;

        end if;

        if (l_group_change) then
            if (nvl(fa_cache_pkg.fazcbc_record.copy_group_change_flag, 'N') = 'N' ) then
               l_mesg_name  := 'FA_MCP_SHARED_NO_COPY';
               l_token      := 'TYPE';
               l_value      := 'GROUP CHANGE ADJUSTMENTS';
               raise val_err1;
            end if;
            if (nvl(l_corp_old_group_asset_id,-99) <> nvl(l_tax_group_asset_id,-99)) then
               l_mesg_name  := 'FA_MCP_DIFF_GROUP';
               raise val_err1;
            end if;

            open c_trx_subtype;
            fetch c_trx_subtype into l_group_reclass_type;
            close c_trx_subtype;
            if l_group_reclass_type like '%MANUAL%' then
               l_mesg_name  := 'FA_MCP_GROUP_ADJ_MANUAL';
               raise val_err1;
            end if;

        end if;


        -- check dated adjustment -- should this be handled in the api????
        --
        -- BUG# 2799286
        -- removing overlapping validation - no need to prevent this as the
        -- new amort package can handle it and i is too restrictive
        -- when trying to copy group reclasses - BMR


    EXCEPTION
      when val_err1 then
         l_valid := FALSE;
         l_delta_capacity := 0;

      when val_err2 then
         l_valid := FALSE;

      when others then
         l_valid := FALSE;
         l_delta_capacity := 0;

   END; -- end logic from fampvt


   if (not l_valid and l_delta_capacity = 0)  then
      -- invalid
      raise adj_err1;
   elsif (not l_valid and l_delta_capacity <> 0) then
      -- if capacity adjustment only, don't copy cost
      l_delta_cost            := 0;
   end if;


   -- load the info (no longer needed, only deltas)
   -- all checks and settings for 0 cost shoudl be handled in api
   -- begin calc stuff from fampms.lpc only called for
   -- non-capacity adjustment

   -- insure prior derived values are cleared for salvage if not valid
   if (not l_valid) then
      l_delta_salvage_value     := null;
      l_delta_salvage_percent   := null;
      l_tax_new_salvage_type    := null;
   end if; -- end if valid


   -- itc - should be handled in api

   -- end calcstuff from famppc in fampms.lpc


   -- start more from fampaj before insert
   -- setting cost / rec/salvage to 0 should be handled in api

   -- removed for group
   -- Salvage Value Requirement for Japan  (SHOULD THIS BE HANDLED IN API?!?!)
   -- If valid = FALSE, then this is a special case of copy capacity
   -- adjustments, and only capacity should be copied
   -- Here is the place rounding up occur


   /* removing this as we will not copy reclasses in phase 1 */

   -- group change logic
   -- group reclasses will be performed when the asset shared the same group
   -- association in corp and tax and when there was a change due to this
   -- adjustment in corp.  Currently any such reclass will be copied using
   -- the same amortization start date as in the corporate book ???  VERIFY ???

   if (l_group_change) then

      -- get the corporate amortization start date for the
      -- corporate change and use it here

      select m.amortization_start_date
        into l_trans_rec.amortization_start_date
        from fa_transaction_headers m
       where m.transaction_header_id = p_corp_thid;

      -- set the group asset id for tax
      l_asset_fin_rec_adj.group_asset_id := nvl(l_corp_new_group_asset_id, FND_API.G_MISS_NUM);
      l_group_reclass_options_rec.group_reclass_type := 'CALC';
      l_group_reclass_options_rec.transfer_flag := 'YES';

   end if;


   -- validation ok, load the structs and process the adjustment
   l_trans_rec.transaction_date_entered      := l_trx_date_entered;
   --Bug6332519
   l_trans_rec.amortization_start_date       := l_amortization_start_date;

   l_trans_rec.transaction_type_code         := 'ADJUSTMENT';
   l_trans_rec.transaction_subtype           := l_trx_subtype;
   l_trans_rec.source_transaction_header_id  := p_corp_thid;
   l_trans_rec.calling_interface             := 'FAMCP';
   l_trans_rec.mass_reference_id             := G_request_id;

   l_asset_hdr_rec.asset_id                  := l_asset_id;
   l_asset_hdr_rec.book_type_code            := p_tax_book;
   l_asset_fin_rec_adj.cost                  := l_delta_cost;
   l_asset_fin_rec_adj.salvage_type          := l_tax_new_salvage_type;
   l_asset_fin_rec_adj.salvage_value         := l_delta_salvage_value;
   l_asset_fin_rec_adj.percent_salvage_value := l_delta_salvage_percent;

   l_asset_fin_rec_adj.production_capacity   := l_delta_capacity;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_adj.salvage_type', l_asset_fin_rec_adj.salvage_type, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_adj.salvage_value', l_asset_fin_rec_adj.salvage_value, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec_adj.percent_salvage_value', l_asset_fin_rec_adj.percent_salvage_value, p_log_level_rec => g_log_level_rec);
   end if;

   FA_ADJUSTMENT_PUB.do_adjustment
        (p_api_version               => 1.0,
         p_init_msg_list             => FND_API.G_FALSE,
         p_commit                    => FND_API.G_FALSE,
         p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
         x_return_status             => l_return_status,
         x_msg_count                 => l_mesg_count,
         x_msg_data                  => l_mesg,
         p_calling_fn                => l_calling_fn,
         px_trans_rec                => l_trans_rec,
         px_asset_hdr_rec            => l_asset_hdr_rec,
         p_asset_fin_rec_adj         => l_asset_fin_rec_adj,
         x_asset_fin_rec_new         => l_asset_fin_rec_new,
         x_asset_fin_mrc_tbl_new     => l_asset_fin_mrc_tbl_new,
         px_inv_trans_rec            => l_inv_trans_rec,
         px_inv_tbl                  => l_inv_tbl,
         p_asset_deprn_rec_adj       => l_asset_deprn_rec_adj,
         x_asset_deprn_rec_new       => l_asset_deprn_rec_new,
         x_asset_deprn_mrc_tbl_new   => l_asset_deprn_mrc_tbl_new,
         p_group_reclass_options_rec => l_group_reclass_options_rec
        );

   if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       l_mesg_name := 'FA_MCP_FAIL_THID';
       raise adj_err2;
   end if;


   -- dump success message
   l_mesg_name := 'FA_MCP_ADJUSTMENT_SUCCESS';
   write_message
        (p_asset_number    => p_asset_number,
         p_thid            => p_corp_thid,
         p_message         => l_mesg_name,
         p_token           => l_token,
         p_value           => l_value,
         p_mode            => 'S');

   X_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   when adj_err1 then
      -- non-fatal
      write_message
        (p_asset_number    => p_asset_number,
         p_thid            => p_corp_thid,
         p_message         => l_mesg_name,
         p_token           => l_token,
         p_value           => l_value,
         p_mode            => 'W');

      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      x_return_status :=  FND_API.G_RET_STS_ERROR;

   when adj_err2 then
      -- fatal
      write_message
        (p_asset_number    => p_asset_number,
         p_thid            => p_corp_thid,
         p_message         => l_mesg_name,
         p_token           => l_token,
         p_value           => l_value,
         p_mode            => 'F');

      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;

   when others then
      -- fatal
      fa_srvr_msg.add_sql_error(calling_fn => null, p_log_level_rec => g_log_level_rec);
      write_message
        (p_asset_number    => p_asset_number,
         p_thid            => p_corp_thid,
         p_message         => 'FA_MCP_FAIL_THID',
         p_token           => null,
         p_value           => null,
         p_mode            => 'F');

      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;


END mcp_adjustment;


----------------------------------------------------------------

procedure mcp_retirement
        (p_corp_thid     IN  NUMBER,
         p_asset_id      IN  NUMBER,
         p_asset_number  IN  VARCHAR2,
         p_tax_book      IN  VARCHAR2,
         x_return_status OUT NOCOPY VARCHAR2) IS


   -- local variables
   l_valid                        BOOLEAN;
   l_count                        NUMBER;
   l_jdpis                        NUMBER;
   l_trx_date_entered             DATE;
   l_date_effective               DATE;
   l_transaction_type_code        VARCHAR2(30);
   l_category_id                  NUMBER;
   l_asset_number                 VARCHAR2(30);
   l_old_corp_cost                NUMBER;
   l_corp_cost_retired            NUMBER;
   l_tax_cost                     NUMBER;
   l_tax_dpis                     DATE;
   l_tax_pc_fully_ret             NUMBER;
   l_period_of_addition           VARCHAR2(1);
   l_ret_status                   VARCHAR2(30);
   l_tax_cost_retired             NUMBER;
   l_tax_reinst_thid              NUMBER; -- 8364239

   l_cost_of_removal              number;
   l_proceeds_of_sale             number;
   l_retirement_type_code         varchar2(15);
   l_itc_recapture_id             number(15);
   l_reference_num                varchar2(15);
   l_sold_to                      varchar2(30);
   l_trade_in_asset_id            number(15);

   -- used for api call
   l_api_version                  NUMBER      := 1.0;
   l_init_msg_list                VARCHAR2(1) := FND_API.G_FALSE;
   l_commit                       VARCHAR2(1) := FND_API.G_FALSE;
   l_validation_level             NUMBER      := FND_API.G_VALID_LEVEL_FULL;
   l_return_status                VARCHAR2(1);
   l_msg_count                    number;
   l_msg_data                     VARCHAR2(4000);

   -- local messaging
   l_mesg_name                    VARCHAR2(30);
   l_token                        varchar2(40);
   l_value                        varchar2(40);
   l_calling_fn                   VARCHAR2(30) := 'fa_masscp_pkg.mcp_retirement';

   l_trans_rec                    FA_API_TYPES.trans_rec_type;
   l_dist_trans_rec               FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec                FA_API_TYPES.asset_hdr_rec_type;
   l_asset_retire_rec             FA_API_TYPES.asset_retire_rec_type;
   l_asset_dist_tbl               FA_API_TYPES.asset_dist_tbl_type;
   l_subcomp_tbl                  FA_API_TYPES.subcomp_tbl_type;
   l_inv_tbl                      FA_API_TYPES.inv_tbl_type;

   -- exceptions
   val_err                        EXCEPTION;
   ret_err1                       EXCEPTION;
   ret_err2                       EXCEPTION;


   -- cursors
   cursor c_ret_id is
    select retirement_id,status
     from fa_retirements
    where book_type_code            = p_tax_book
      and asset_id                  = p_asset_id
      order by retirement_id desc;

   cursor c_retirement (p_asset_id   number,
                        p_corp_thid  number,
                        p_tax_book   varchar2,
                        p_corp_book  varchar2) is
   select corp_th.transaction_date_entered,
          corp_th.date_effective,
          corp_th.transaction_type_code,
          ah.category_id,
          ad.asset_number,
          corp_bk.cost,
          corp_rt.cost_retired,
          corp_rt.retirement_id,
          tax_bk.cost,
          tax_bk.date_placed_in_service,
          tax_bk.period_counter_fully_retired,
          corp_rt.cost_of_removal,
          corp_rt.proceeds_of_sale,
          corp_rt.retirement_type_code,
          corp_rt.itc_recapture_id,
          corp_rt.reference_num,
          corp_rt.sold_to,
          corp_rt.trade_in_asset_id
     from fa_transaction_headers          corp_th,
          fa_books                        corp_bk,
          fa_books                        tax_bk,
          fa_retirements                  corp_rt,
          fa_additions_b                  ad,
          fa_asset_history                ah
    where corp_th.transaction_header_id    = p_corp_thid
      and corp_th.asset_id                 = ah.asset_id
      and corp_th.date_effective           < nvl(ah.date_ineffective,
                                                 sysdate)
      and corp_th.date_effective          >= ah.date_effective
      and corp_th.transaction_header_id    = corp_bk.transaction_header_id_out
      and corp_th.transaction_header_id    = decode(corp_th.transaction_type_code,
                                                    'REINSTATEMENT', corp_rt.transaction_header_id_out,
                                                    corp_rt.transaction_header_id_in)
      and corp_rt.asset_id                 = p_asset_id
      and corp_rt.book_type_code           = p_corp_book
      and tax_bk.asset_id                  = p_asset_id
      and tax_bk.book_type_code            = p_tax_book
      and tax_bk.date_ineffective         is null
      and ah.asset_type                    = 'CAPITALIZED'
      and ad.asset_id                      = corp_th.asset_id;

BEGIN

   if NOT fa_cache_pkg.fazcbc(X_book => p_tax_book, p_log_level_rec => g_log_level_rec) then
      raise ret_err1;
   end if;

   if (fa_cache_pkg.fazcbc_record.copy_retirements_flag = 'NO') then

       l_mesg_name := 'FA_MCP_SHARED_NO_COPY';
       l_token     := 'TYPE';
       l_value     := 'RETIREMENTS';

       raise ret_err1;
   end if;

   -- verify the asset exists in the book
   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add('test',
                       'getting',
                       'c_retirement cursor', p_log_level_rec => g_log_level_rec);
   end if;

   l_trans_rec.source_transaction_header_id := p_corp_thid;
   l_trans_rec.calling_interface            := 'FAMCP';
   l_trans_rec.mass_reference_id            := G_request_id;

   -- get basic info including corp ret info and tax cost, etc
   open c_retirement(p_asset_id   => p_asset_id,
                     p_corp_thid  => p_corp_thid,
                     p_tax_book   => p_tax_book,
                     p_corp_book  => fa_cache_pkg.fazcbc_record.distribution_source_book);

   fetch c_retirement
     into l_trx_date_entered,
          l_date_effective,
          l_transaction_type_code,
          l_category_id,
          l_asset_number,
          l_old_corp_cost,
          l_corp_cost_retired,
          l_asset_retire_rec.retirement_id,
          l_tax_cost,
          l_tax_dpis,
          l_tax_pc_fully_ret,
          l_cost_of_removal,
          l_proceeds_of_sale,
          l_retirement_type_code,
          l_itc_recapture_id,
          l_reference_num,
          l_sold_to,
          l_trade_in_asset_id;

   -- BUG# 2818124
   -- do not raise fatal error here...
   if c_retirement%NOTFOUND then
      close c_retirement;
      l_mesg_name := 'FA_MCP_ASSET_NOT_IN_TAX'; -- 'FA_MCP_RET_SELECT_DEFAULTS';
      raise ret_err1;
   end if;

   close c_retirement;

   -- BUG# 2661925
   -- need to check if the trx date is in the future
   -- to account for various calendars, reject if so
   -- this new logic replaces the following fix to redefault date:

   -- BUG# 2447234, if transaction date falls in a future period,
   -- then reset it to the normal defaulting mechanism using the
   -- current period note that the tax period was the last one
   -- loaded into the deprn period cache via the call to
   -- get_deprn_period above.

   if (l_trx_date_entered > fa_cache_pkg.fazcdp_record.calendar_period_close_date) then
       l_mesg_name := 'FA_MCP_SHARED_FUTURE_COPY';

       raise ret_err1;
   end if;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add('test',
                       'getting',
                       'category cache', p_log_level_rec => g_log_level_rec);
   end if;

   -- call the category cache
   l_jdpis := to_number(to_char(l_tax_dpis, 'J'));

   if not fa_cache_pkg.fazccbd (X_book   => p_tax_book,
                                X_cat_id => l_category_id,
                                X_jdpis  => l_jdpis, p_log_level_rec => g_log_level_rec) then
      l_mesg_name := 'FA_MCP_FAIL_THID';
      raise ret_err2;
   end if;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add('test',
                       'doing',
                       'validation', p_log_level_rec => g_log_level_rec);
   end if;

   -- validation logic (from fampvt)
   BEGIN

      -- get the basic asset and transaction info (broken up)
      -- asset exists (accounted for above)
      -- check for subsequent transactions

      -- BugNo:348403, we should copy the prior period retirement
      -- tranaction which asset was already reinstated in TAX book

      -- BUG# 3126641
      -- changing if condition as it was backwards and not fully
      -- doing what it was supposed to do (need to make
      -- sure that no transaction other then previous rets
      -- are impacted

      if (l_transaction_type_code = 'PARTIAL RETIREMENT' or
          l_transaction_type_code = 'FULL RETIREMENT') then

         select count(*)
           into l_count
           from fa_transaction_headers th,
                fa_retirements ret
          where th.book_type_code        = p_tax_book
            and th.asset_id              = p_asset_id
            and ret.book_type_code(+)    = p_tax_book
            and ret.asset_id(+)          = p_asset_id
            and th.transaction_header_id = ret.transaction_header_id_in(+)
            and ret.status(+)            not in ('REINSTATE', 'DELETED')
            and transaction_type_code    not in ('ADDITION/VOID', 'CIP ADDITION VOID')
            and th.transaction_date_entered > l_trx_date_entered;

      else

         select count(*)
           into l_count
           from fa_transaction_headers
          where asset_id                 = p_asset_id
            and book_type_code           = p_tax_book
            and transaction_type_code    not in ('ADDITION/VOID', 'CIP ADDITION VOID')
            and transaction_date_entered > l_trx_date_entered;

      end if;

      -- BUG# 3235346
      -- need to do this for reinstatement as well

      if (l_count > 0) then

         -- l_mesg_name := 'FA_SHARED_OTHER_TRX_FOLLOW';
         -- raise val_err;
         -- BUG# 3092853
         -- we need to reset trx date in case adjustments
         -- have been copied/entered in the same period
         -- where the transaction date was cal_per_close.
         -- only do this if date_retired equals falls in
         -- the same period as CPD.

         if (l_trx_date_entered <= fa_cache_pkg.fazcdp_record.calendar_period_close_date and
             l_trx_date_entered >= fa_cache_pkg.fazcdp_record.calendar_period_open_date) then

            -- BUG# 4212279
            -- don't allow a change where prorate date would change
            -- as a result

            select count(*)
              into l_count
              from fa_conventions      conv1,
                   fa_conventions      conv2,
                   fa_calendar_periods cal1,
                   fa_calendar_periods cal2
             where conv1.prorate_convention_code =
                   fa_cache_pkg.fazccbd_record.retirement_prorate_convention
               and conv2.prorate_convention_code =
                   fa_cache_pkg.fazccbd_record.retirement_prorate_convention
               and l_trx_date_entered
                   between conv1.start_date and conv1.end_date
               and fa_cache_pkg.fazcdp_record.calendar_period_close_date
                   between conv2.start_date and conv2.end_date
               and cal1.calendar_type = fa_cache_pkg.fazcbc_record.prorate_calendar
               and cal2.calendar_type = fa_cache_pkg.fazcbc_record.prorate_calendar
               and conv1.prorate_date between cal1.start_date and cal1.end_date
               and conv2.prorate_date between cal2.start_date and cal2.end_date
               and cal1.end_date      = cal2.end_date;

            if (l_count > 0) then
               l_trx_date_entered :=
                  fa_cache_pkg.fazcdp_record.calendar_period_close_date;
            end if;

            -- if date is not redefaulted, API will trap the
            -- overlap and return failure

         end if;
      end if;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('test',
                          'doing',
                          'validation part 2', p_log_level_rec => g_log_level_rec);
      end if;

      -- pending ret reinstate
      select count(*)
        into l_count
        from fa_retirements
       where book_type_code = p_tax_book
         and asset_id       = p_asset_id
         and status        in ('REINSTATE', 'PENDING');

      if (l_count > 0) then
         l_mesg_name := 'FA_SHARED_PENDING_RETIREMENT';
         raise val_err;
      end if;


      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('test',
                          'doing',
                          'validation for period of addition', p_log_level_rec => g_log_level_rec);
      end if;

      -- Check retirements (moved in retirement code below)
      -- Check reinstatements (moved into reinstate code below)
      -- add this period
      if not FA_ASSET_VAL_PVT.validate_period_of_addition
             (p_asset_id            => p_asset_id,
              p_book                => p_tax_book,
              p_mode                => 'ABSOLUTE',
              px_period_of_addition => l_period_of_addition, p_log_level_rec => g_log_level_rec) then
         l_mesg_name := 'FA_MCP_FAIL_THID';
         raise val_err;
      end if;

      if (l_period_of_addition = 'Y' and
          G_release = 11) then
         l_mesg_name := 'FA_MCP_ADD_RET_SAME_PERIOD';
         raise val_err;
      end if;

      -- BUG# 6905121 no longer validate period of capitalization
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('test',
                          'doing',
                          'after validating period of addition', p_log_level_rec => g_log_level_rec);
      end if;

      l_valid := TRUE;


   EXCEPTION
      when val_err then
         l_valid := FALSE;

      when others then
         l_valid := FALSE;

   END;

   -- end validation from fampvt

   if (l_valid) then

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('test',
                          'trx',
                          'is valid', p_log_level_rec => g_log_level_rec);
      end if;

      -- code from within the insert ret function (famprt.lpc)
      if l_transaction_type_code = 'REINSTATEMENT' then

         -- HH: 8364239
         BEGIN
           select rtx.transaction_header_id_out
           into  l_tax_reinst_thid
           from  fa_retirements rt, fa_transaction_headers th,
                 fa_retirements rtx
           where rt.transaction_header_id_out    = p_corp_thid
           and   th.book_type_code               = p_tax_book
           and   th.asset_id                     = p_asset_id
           and   th.transaction_type_code
                        in ('FULL RETIREMENT', 'PARTIAL RETIREMENT')
           and   th.source_transaction_header_id = rt.transaction_header_id_in
           and   rtx.book_type_code              = th.book_type_code
           and   rtx.transaction_header_id_in    = th.transaction_header_id;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             l_count :=0;
         END;

         -- verify asset has been retired
         if (l_count = 0) then
            l_mesg_name := 'FA_MCP_REIN_NO_RET';
            raise ret_err1;
         end if;

         -- Check that the asset was not manually reinstated in tax.
         if (nvl(l_tax_reinst_thid,0) > 0) then
            l_mesg_name := 'FA_MCP_RET_MANUAL_TAX';
            raise ret_err1;
         end if;
         -- eHH: 8364239

         -- all we need when calling the api is the retirement_id loaded
         -- and nothing else it is all done in the api including asset_hdr
         open c_ret_id;
         fetch c_ret_id into l_asset_retire_rec.retirement_id,l_ret_status; --bug fix 5743332
         if c_ret_id%NOTFOUND then
            close c_ret_id;
            l_mesg_name := 'FA_MCP_FAIL_GET_FA_RETIRE';
            raise ret_err2;
         end if;
         close c_ret_id;

/*  bug fix 5743332
         -- Can't reinstate if asset is already reinstated
         select status
           into l_ret_status
           from fa_retirements
          where book_type_code = p_tax_book
            and asset_id       = p_asset_id
            and retirement_id  = l_asset_retire_rec.retirement_id;
*/
         if (l_ret_status = 'REINSTATE' or
             l_ret_status = 'DELETED') then
            l_mesg_name := 'FA_MCP_RET_MANUAL_TAX';
            raise ret_err1;
         end if;


         -- insure we run gainloss
         l_asset_retire_rec.calculate_gain_loss       := FND_API.G_TRUE;
         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add('test',
                             'calling',
                             'do reinstatement', p_log_level_rec => g_log_level_rec);
         end if;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add('test',
                             'calling',
                             'do retirement', p_log_level_rec => g_log_level_rec);
            fa_debug_pkg.add('test',
                             'souce thid before call',
                             l_trans_rec.source_transaction_header_id, p_log_level_rec => g_log_level_rec);
         end if;

         FA_RETIREMENT_PUB.do_reinstatement
            (p_api_version               => l_api_version,
             p_init_msg_list             => l_init_msg_list,
             p_commit                    => l_commit,
             p_validation_level          => l_validation_level,
             p_calling_fn                => l_calling_fn,
             x_return_status             => l_return_status,
             x_msg_count                 => l_msg_count,
             x_msg_data                  => l_msg_data,
             px_trans_rec                => l_trans_rec,
             px_asset_hdr_rec            => l_asset_hdr_rec,
             px_asset_retire_rec         => l_asset_retire_rec,
             p_asset_dist_tbl            => l_asset_dist_tbl,
             p_subcomp_tbl               => l_subcomp_tbl,
             p_inv_tbl                   => l_inv_tbl
            );

      else -- full or partial retirement

         -- validation from fampvt
         -- verify asset is not already fully retired
         if (l_tax_pc_fully_ret is not null) then
            l_mesg_name := 'FA_MCP_RET_MANUAL_TAX';
            raise ret_err1;
         end if;

         -- verify there have never been any manual retirements
         select count(*)
           into l_count
           from fa_transaction_headers  th
          where th.book_type_code = p_tax_book
            and th.asset_id       = p_asset_id
            and th.transaction_type_code in
                   ('FULL RETIREMENT', 'PARTIAL RETIREMENT', 'REINSTATEMENT')
            and th.source_transaction_header_id is null;

         if (l_count > 0) then
            l_mesg_name := 'FA_MCP_RET_MANUAL_TAX';
            raise ret_err1;
         end if;

         -- call famppc (does nothing but get the costs)
         -- get dist source book /cost retired from corp (not needed , use pop util)

         -- pop the retirement struct with corp vales
         -- uses the retirement id for lookup

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add('test',
                             'l_asset_retire_rec.retirement_id',
                             l_asset_retire_rec.retirement_id, p_log_level_rec => g_log_level_rec);
         end if;

         if not fa_util_pvt.get_asset_retire_rec
               (px_asset_retire_rec => l_asset_retire_rec,
                p_mrc_sob_type_code => 'P',
                p_set_of_books_id => null,
                p_log_level_rec => g_log_level_rec) then
            l_mesg_name := 'FA_MCP_FAIL_THID';
            raise ret_err2;
         end if;

         if (l_old_corp_cost = 0) then
            l_tax_cost_retired := l_tax_cost;
         else
            l_tax_cost_retired := l_tax_cost * (l_asset_retire_rec.cost_retired / l_old_corp_cost);
         end if;

         -- round cost retired
         -- Bug 8643319: Passed the sob_id from cache
         if not fa_utils_pkg.faxrnd
               (l_tax_cost_retired,
                p_tax_book,
                fa_cache_pkg.fazcbc_record.set_of_books_id,
                p_log_level_rec => g_log_level_rec) then
            l_mesg_name := 'FA_MCP_FAIL_THID';
            raise ret_err2;
         end if;

         -- BUG# 3610820
         -- do not fail here, but trap condition , dump error and warn
         if (l_tax_cost_retired = 0 and l_tax_cost <> 0) then
            l_mesg_name := 'FA_RET_COST_TOO_BIG';
            raise ret_err1; -- non-fatal
         end if;

         -- set up the tax specific values in the retirement structure
         -- need to double check if some of these might be defaulted from api

         l_asset_retire_rec.cost_retired    := l_tax_cost_retired;
         l_asset_retire_rec.status          := 'PENDING';
         l_asset_retire_rec.retirement_prorate_convention :=
            fa_cache_pkg.fazccbd_record.retirement_prorate_convention;
         l_asset_retire_rec.retirement_id   := NULL;
         l_asset_retire_rec.units_retired   := NULL;

         -- BUG# 2737472
         -- need to set stl_method_code, etc
         if (fa_cache_pkg.fazccbd_record.use_stl_retirements_flag = 'YES') then
            l_asset_retire_rec.detail_info.stl_method_code    := fa_cache_pkg.fazccbd_record.stl_method_code;
            l_asset_retire_rec.detail_info.stl_life_in_months := fa_cache_pkg.fazccbd_record.stl_life_in_months;
         end if;

         l_asset_retire_rec.cost_of_removal      := l_cost_of_removal;
         l_asset_retire_rec.proceeds_of_sale     := l_proceeds_of_sale;
         l_asset_retire_rec.retirement_type_code := l_retirement_type_code;
         l_asset_retire_rec.detail_info.itc_recapture_id     := l_itc_recapture_id;
         l_asset_retire_rec.reference_num        := l_reference_num;
         l_asset_retire_rec.sold_to              := l_sold_to;
         l_asset_retire_rec.trade_in_asset_id    := l_trade_in_asset_id;

         l_asset_hdr_rec.asset_id       := p_asset_id;
         l_asset_hdr_rec.book_type_code := p_tax_book;


         -- BUG# 2447234
         -- reset the date_retired to the transaction_date in case it
         -- fell in a future period in respect to tax and was thus
         -- redefaulted above

         l_asset_retire_rec.date_retired := l_trx_date_entered;

         -- insure we run gainloss
         l_asset_retire_rec.calculate_gain_loss       := FND_API.G_TRUE;

         -- call the appropriate api
         -- passing calc_gain_loss flag as true

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add('test',
                             'calling',
                             'do retirement', p_log_level_rec => g_log_level_rec);
            fa_debug_pkg.add('test',
                             'souce thid before call',
                             l_trans_rec.source_transaction_header_id, p_log_level_rec => g_log_level_rec);
         end if;

         FA_RETIREMENT_PUB.do_retirement
            (p_api_version               => l_api_version,
             p_init_msg_list             => l_init_msg_list,
             p_commit                    => l_commit,
             p_validation_level          => l_validation_level,
             p_calling_fn                => l_calling_fn,
             x_return_status             => l_return_status,
             x_msg_count                 => l_msg_count,
             x_msg_data                  => l_msg_data,
             px_trans_rec                => l_trans_rec,
             px_dist_trans_rec           => l_dist_trans_rec,
             px_asset_hdr_rec            => l_asset_hdr_rec,
             px_asset_retire_rec         => l_asset_retire_rec,
             p_asset_dist_tbl            => l_asset_dist_tbl,
             p_subcomp_tbl               => l_subcomp_tbl,
             p_inv_tbl                   => l_inv_tbl
            );

      end if;  -- ret vs. reinstate

      if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
         l_mesg_name := 'FA_MCP_FAIL_THID';
         raise ret_err2;
      end if;

   else -- invalid
      raise ret_err1;
   end if; -- valid

   l_mesg_name := 'FA_MCP_RETIRE_SUCCESS';
   write_message
        (p_asset_number    => p_asset_number,
         p_thid            => p_corp_thid,
         p_message         => l_mesg_name,
         p_token           => l_token,
         p_value           => l_value,
         p_mode            => 'S');

   X_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   when ret_err1 then
      -- non-fatal
      write_message
        (p_asset_number    => p_asset_number,
         p_thid            => p_corp_thid,
         p_message         => l_mesg_name,
         p_token           => l_token,
         p_value           => l_value,
         p_mode            => 'W');

      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      x_return_status :=  FND_API.G_RET_STS_ERROR;

   when ret_err2 then
      -- fatal
      write_message
        (p_asset_number    => p_asset_number,
         p_thid            => p_corp_thid,
         p_message         => l_mesg_name,
         p_token           => l_token,
         p_value           => l_value,
         p_mode            => 'F');

      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;

   when others then
      -- fatal
      fa_srvr_msg.add_sql_error(calling_fn => null, p_log_level_rec => g_log_level_rec);
      write_message
        (p_asset_number    => p_asset_number,
         p_thid            => p_corp_thid,
         p_message         => 'FA_MCP_FAIL_THID',
         p_token           => null,
         p_value           => null,
         p_mode            => 'F');

      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;

END mcp_retirement;

----------------------------------------------------------------

-- this is used to maintaint the old execution report seperately
-- from the log.  Only the main message will be dumped to out file.
-- all messaging and debug will be demped to the log file

PROCEDURE write_message
              (p_asset_number    in varchar2,
               p_thid            in number,
               p_message         in varchar2,
               p_token           in varchar2,
               p_value           in varchar2,
               p_mode            in varchar2) IS

   l_asset_number varchar2(50);
   l_thid         varchar2(20);
   l_mesg         varchar2(100);
   l_string       varchar2(512);
   l_calling_fn   varchar2(40);
   l_return_char  number;

BEGIN

   -- only pass calling_fn for failures
   if p_mode = 'F' then
      -- l_calling_fn  := 'fa_masscp_pkg.write_message';
      G_fatal_error := TRUE;
      G_failure_count := G_failure_count + 1;
   elsif p_mode = 'W' then
      G_warning_count := G_warning_count + 1;
   else
      G_success_count := G_success_count + 1;
   end if;

   -- first dump the message to the output file
   -- set/translate/retrieve the mesg from fnd

   fnd_message.set_name('OFA', p_message);
   if p_token is not null then
      fnd_message.set_token(p_token, p_value);
   end if;

   -- get the message but only display up to
   -- the return character (if it exists)
   -- for nicer formatting in the exception report

   l_mesg          := substrb(fnd_message.get, 1, 100);
   l_return_char   := instrb(l_mesg, fnd_global.local_chr(10));

   if (l_return_char > 0) then
      l_mesg          := substrb(l_mesg, 1, l_return_char - 1);
   end if;

   l_asset_number := rpad(p_asset_number, 15);
   l_thid         := rpad(to_char(p_thid), 20);
   l_string       := l_asset_number || ' ' || l_thid || ' ' || l_mesg;

   FND_FILE.put(FND_FILE.output,l_string);
   FND_FILE.new_line(FND_FILE.output,1);

   -- now process the message for the log file
   fa_srvr_msg.add_message
       (calling_fn => l_calling_fn,
        name       => p_message,
        token1     => p_token,
        value1     => p_value, p_log_level_rec => g_log_level_rec);

EXCEPTION
   when others then
       raise;
END ;

----------------------------------------------------------------

-- This function will select all candidate transactions in a single
-- shot (no longer distinguishes between parent / child). The primary
-- cursors have removed logic for checking if parent or group exist.
-- We will only stripe the worker number based on the following order:
--
-- In the initial phase, group / parent /child assets will all to
-- worker 1 until we get response from perf team on how to better
-- handle these hierarchies

PROCEDURE allocate_workers (
                p_book_type_code     IN     VARCHAR2,
                p_period_name        IN     VARCHAR2,
                p_period_counter     IN     NUMBER,
                p_mode               IN     NUMBER,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                x_return_status         OUT NOCOPY NUMBER) IS

   -- find all top level parent assets for use by next cursor
   -- regardless if parent belongs to group or not
   -- also include non-child assets here too

   -- note that parent asset is is only populated for addition trxs to start with
   -- thus this can only pull a given asset once for parent not null,
   -- but for null parent id, assets can come back multiple times, thus distinct

   cursor c_parent_assets (p_parent_request_id number) is
   select /*+ parallel(fpw_p) parallel(fpw_c) */
          distinct
          fpw_p.asset_id,
          fpw_p.worker_number
     from fa_parallel_workers fpw_p,
          fa_parallel_workers fpw_c
    where fpw_p.request_id            = p_parent_request_id
      and fpw_p.transaction_type_code = 'ADDITION'
      and (fpw_p.parent_asset_id      is null or
           not exists
           (select 1
              from fa_parallel_workers fpw_p1
             where fpw_p1.request_id             = p_parent_request_id
               and fpw_p1.asset_id               = fpw_p.parent_asset_id
               and fpw_p1.transaction_type_code = 'ADDITION'))
      and fpw_c.request_id            = fpw_p.request_id
      and fpw_c.parent_asset_id       = fpw_p.asset_id
      and fpw_c.transaction_type_code = 'ADDITION';


   -- allocates all child assets to workers

   -- note that it's technically possible to have a child in the middle
   -- of the hierarchy already assigned due to a group to a worker
   -- other than the parent.  It's also possible to have children
   -- assigned to different groups in the same fashion.
   --
   -- currently this should not be a common scenario, but if it
   -- arises, we will have to introduce logic to deal with it
   -- which will be similar to that in FAMPSLTFRB.pls for
   -- src and dest assets with different groups.

   -- since join is by ADDITION, there is no need for distinct usage here

   cursor c_child_assets (p_parent_asset_id   number,
                          p_parent_request_id number) is
          select /*+ parallel(fpw1)*/
                 fpw1.asset_id,
                 level
            from fa_parallel_workers fpw1
           start with fpw1.asset_id                  = p_parent_asset_id
                  and fpw1.request_id                = p_parent_request_id
                  and fpw1.transaction_type_code     = 'ADDITION'
         connect by prior fpw1.asset_id              = fpw1.parent_asset_id
                and prior fpw1.request_id            = fpw1.request_id
                and prior fpw1.transaction_type_code = 'ADDITION';


   -- local variables
   l_corp_period_rec            FA_API_TYPES.period_rec_type;
   l_tax_period_rec             FA_API_TYPES.period_rec_type;


   -- Used for bulk fetching
   l_batch_size                 number := 200;

   -- used for subsequent parent / group updates
   l_asset_id                   num_tbl;
   l_worker_number              num_tbl;

   l_child_asset_id             num_tbl;
   l_child_worker_number        num_tbl;
   l_child_process_order        num_tbl;

   l_group_increment            number := 0;
   l_date_effective             date;   -- bug fix 5900321
   fa_trx_types_tab             fa_char30_tbl_type;

   l_calling_fn                 varchar2(40) := 'fa_masscp_pkg.allocate_workers';
   masscp_err                   exception;

BEGIN


   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise masscp_err;
      end if;
   end if;

   if(g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,  'at beginning of', 'worker allocation', p_log_level_rec => g_log_level_rec);
   end if;

   x_return_status := 0;

   -- get corp book information
   if not fa_cache_pkg.fazcbc(X_book => p_book_type_code, p_log_level_rec => g_log_level_rec) then
      raise masscp_err;
   end if;

   -- get corp period info
   if not FA_UTIL_PVT.get_period_rec
          (p_book           => fa_cache_pkg.fazcbc_record.distribution_source_book,
           p_period_counter => p_period_counter,
           x_period_rec     => l_corp_period_rec
          , p_log_level_rec => g_log_level_rec) then
      raise masscp_err;
   end if;

   -- get tax period info
   if not FA_UTIL_PVT.get_period_rec
          (p_book           => p_book_type_code,
           x_period_rec     => l_tax_period_rec
          , p_log_level_rec => g_log_level_rec) then
      raise masscp_err;
   end if;

   -- determine transactions available for copying

   fa_trx_types_tab := fa_char30_tbl_type();

   if (fa_cache_pkg.fazcbc_record.copy_additions_flag = 'YES') then
      fa_trx_types_tab.EXTEND;
      fa_trx_types_tab(fa_trx_types_tab.last) := 'ADDITION';
   else
      fa_srvr_msg.add_message
         (calling_fn => l_calling_fn,
          name       => 'FA_MCP_SHARED_NO_COPY',
          token1     => 'TYPE',
          value1     => 'ADDITIONS', p_log_level_rec => g_log_level_rec);
   end if;

   if (fa_cache_pkg.fazcbc_record.copy_adjustments_flag = 'YES') then
      fa_trx_types_tab.EXTEND;
      fa_trx_types_tab(fa_trx_types_tab.last) := 'ADJUSTMENT';
   else
      fa_srvr_msg.add_message
         (calling_fn => l_calling_fn,
          name       => 'FA_MCP_SHARED_NO_COPY',
          token1     => 'TYPE',
          value1     => 'ADJUSTMENTS', p_log_level_rec => g_log_level_rec);
   end if;

   if (fa_cache_pkg.fazcbc_record.copy_retirements_flag = 'YES') then
      fa_trx_types_tab.EXTEND;
      fa_trx_types_tab(fa_trx_types_tab.last) := 'FULL RETIREMENT';

      fa_trx_types_tab.EXTEND;
      fa_trx_types_tab(fa_trx_types_tab.last) := 'PARTIAL RETIREMENT';

      fa_trx_types_tab.EXTEND;
      fa_trx_types_tab(fa_trx_types_tab.last) := 'REINSTATEMENT';
   else
      fa_srvr_msg.add_message
         (calling_fn => l_calling_fn,
          name       => 'FA_MCP_SHARED_NO_COPY',
          token1     => 'TYPE',
          value1     => 'RETIREMENTS', p_log_level_rec => g_log_level_rec);
   end if;

   if (nvl(fa_cache_pkg.fazcbc_record.allow_group_deprn_flag, 'N') = 'Y') then
      if (nvl(fa_cache_pkg.fazcbc_record.copy_group_addition_flag, 'N') = 'Y') then
         fa_trx_types_tab.EXTEND;
         fa_trx_types_tab(fa_trx_types_tab.last) := 'GROUP ADDITION';
      else
         fa_srvr_msg.add_message
         (calling_fn => l_calling_fn,
          name       => 'FA_MCP_SHARED_NO_COPY',
          token1     => 'TYPE',
          value1     => 'GROUP ADDITIONS', p_log_level_rec => g_log_level_rec);
      end if;
   end if;



   -- load the mass copy table with all transactions to be copied
   -- statement loads initial values for worker/order based on group / mod only
   -- parent / child logic will fire later and update the relevant children accordingly

   if (p_mode = 1) then

      -- skip if additions are not selected for copying
      if (fa_cache_pkg.fazcbc_record.copy_additions_flag <> 'YES') then
         x_return_status := 0;
         return;
      end if;

      if(g_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn, 'inserting initial transactions at', sysdate, p_log_level_rec => g_log_level_rec);
      end if;

     -- bug fix 5900321 (Initial Mass Copy copies capitalized assets to wrong fiscal year and period in TAX book)
     l_date_effective := nvl(l_corp_period_rec.period_close_date, sysdate);
     -- End bug fix 5900321

      insert into fa_parallel_workers
                    (request_id                     ,
                     asset_id                       ,
                     asset_number                   ,
                     asset_type                     ,
                     asset_category_id              ,
                     parent_asset_id                ,
                     book_type_code                 ,
                     transaction_date_entered       ,
                     corp_transaction_header_id     ,
                     tax_transaction_header_id      ,
                     transaction_type_code          ,
                     old_group_asset_id             ,
                     new_group_asset_id             ,
                     worker_number                  ,
                     process_order                  ,
                     process_status                 )
        select p_parent_request_id,
               assets.asset_id,
               assets.asset_number,
               assets.asset_type,
               assets.asset_category_id,
               assets.parent_asset_id,
               p_book_type_code,
               assets.date_placed_in_service,
               assets.transaction_header_id_in,
               NULL tax_transaction_header_id,
               'ADDITION' transaction_type_code,
               NULL,
               decode(fa_cache_pkg.fazcbc_record.copy_group_assignment_flag,
                      'Y', assets.group_asset_id,
                      cbd.group_asset_id),
               decode(asset_type, 'GROUP', 1,
                                  decode(fa_cache_pkg.fazcbc_record.copy_group_assignment_flag,
                                         'Y', decode(assets.group_asset_id,
                                                     null, mod(assets.asset_id, p_total_requests) + 1,
                                                     1),
                                         decode(cbd.group_asset_id,
                                                null, mod(assets.asset_id, p_total_requests) + 1,
                                                1))),
               decode(asset_type, 'GROUP', 1,
                                  decode(fa_cache_pkg.fazcbc_record.copy_group_assignment_flag,
                                         'Y', decode(assets.group_asset_id,
                                                     null, 1,
                                                     2),
                                         decode(cbd.group_asset_id,
                                                null, 1,
                                                2))),
               'UNASSIGNED'
          from (select ad.asset_id,
                       ad.asset_number,
--                       ad.asset_type,
                       ah.asset_type,        -- bug fix 5900321
                       ad.asset_category_id,
                       ad.parent_asset_id,
                       books.book_type_code,
                       books.group_asset_id,
                       books.date_placed_in_service,
                       books.transaction_header_id_in,
                       books.period_counter_fully_retired
                  from fa_books books,
                       fa_additions_b ad,
                       fa_deprn_periods dp,
                       fa_asset_history ah    -- bug fix 5900321
                 where books.date_effective                 <= nvl(l_corp_period_rec.period_close_date, sysdate)
                   and nvl(books.date_ineffective, sysdate)  > nvl(l_corp_period_rec.period_close_date, sysdate - 1)
                   and books.book_type_code                  = fa_cache_pkg.fazcbc_record.distribution_source_book

                   -- bug fix 5900321 (Initial Mass Copy copies capitalized assets to wrong fiscal year and period in TAX book)
                   and ah.asset_id                           = books.asset_id
                   and ah.date_effective <= l_date_effective
                   and nvl(ah.date_ineffective, sysdate+1) > l_date_effective
                   and ah.asset_type                        in ('CAPITALIZED', 'GROUP')
                   -- End bug fix 5900321

                   and dp.book_type_code (+)                 = fa_cache_pkg.fazcbc_record.distribution_source_book
                   and dp.period_counter (+)                 = books.period_counter_fully_retired
                   and nvl(dp.period_counter,
                           l_corp_period_rec.period_counter + 1) > l_corp_period_rec.period_counter
                   and ad.asset_type                        in ('CAPITALIZED', 'GROUP')
                   and ad.asset_id                           = books.asset_id) assets,
               fa_books                  taxbk,
               fa_category_book_defaults cbd
         where taxbk.asset_id(+)                    = assets.asset_id
           and taxbk.book_type_code(+)              = p_book_type_code
           and taxbk.transaction_header_id_out(+)  is null
           and taxbk.asset_id                      is null
           and cbd.category_id(+)                   = assets.asset_category_id
           and cbd.book_type_code(+)                = p_book_type_code
           and assets.date_placed_in_service between cbd.start_dpis(+) and nvl(cbd.end_dpis(+), assets.date_placed_in_service);


   else

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'opening c_per_trx_child cursor at', sysdate, p_log_level_rec => g_log_level_rec);
      end if;

      insert into fa_parallel_workers
                    (request_id                     ,
                     asset_id                       ,
                     asset_number                   ,
                     asset_type                     ,
                     asset_category_id              ,
                     parent_asset_id                ,
                     book_type_code                 ,
                     transaction_date_entered       ,
                     corp_transaction_header_id     ,
                     tax_transaction_header_id      ,
                     transaction_type_code          ,
                     old_group_asset_id             ,
                     new_group_asset_id             ,
                     worker_number                  ,
                     process_order                  ,
                     process_status                 )
        select p_parent_request_id,
               assets.asset_id,
               assets.asset_number,
               assets.asset_type,
               assets.asset_category_id,
               decode(tax_bk.transaction_header_id_in,    -- if asset exists in tax, parent is irrelevant
                      null, assets.parent_asset_id,
                      null),
               p_book_type_code,
               assets.transaction_date_entered,
               assets.transaction_header_id,
               tax_bk.transaction_header_id_in,
               assets.transaction_type_code,
               tax_bk.group_asset_id,
               decode(tax_bk.asset_id,
                      null, decode(fa_cache_pkg.fazcbc_record.copy_group_assignment_flag,
                                   'Y', nvl(new_group_asset_id, cbd.group_asset_id),
                                   cbd.group_asset_id),
                      tax_bk.group_asset_id),
               decode(asset_type,
                      'GROUP', 1,
                       decode(tax_bk.asset_id,
                              null, decode(fa_cache_pkg.fazcbc_record.copy_group_assignment_flag,
                                           'Y', decode(nvl(new_group_asset_id, cbd.group_asset_id),
                                                       null, mod(assets.asset_id, p_total_requests) + 1,
                                                       1),
                                           decode(cbd.group_asset_id,
                                                  null, mod(assets.asset_id, p_total_requests) + 1,
                                                  1)),
                              decode(tax_bk.group_asset_id,
                                     null, mod(assets.asset_id, p_total_requests) + 1,
                                     1))),
               decode(asset_type,
                      'GROUP', 1,
                       decode(tax_bk.asset_id,
                              null, decode(fa_cache_pkg.fazcbc_record.copy_group_assignment_flag,
                                           'Y', decode(nvl(new_group_asset_id, cbd.group_asset_id),
                                                       null, 1,
                                                       2),
                                           decode(cbd.group_asset_id,
                                                  null, 1,
                                                  2)),
                              decode(tax_bk.group_asset_id,
                                     null, 1,
                                     2))),
               'UNASSIGNED'
          from (select ad.asset_id,
                       ad.asset_number,
                       ad.asset_type,
                       ad.asset_category_id,
                       ad.parent_asset_id,
                       corp_th.transaction_date_entered,
                       corp_th.transaction_header_id,
                       corp_th.transaction_type_code,
                       corp_bk_old.group_asset_id   old_group_asset_id,
                       corp_bk.group_asset_id       new_group_asset_id
                  from fa_additions_b                  ad,
                       fa_transaction_headers          corp_th,
                       fa_books                        corp_bk,
                       fa_books                        corp_bk_old,
                       TABLE(CAST(fa_trx_types_tab AS fa_char30_tbl_type)) trx
                 where corp_th.book_type_code                   = fa_cache_pkg.fazcbc_record.distribution_source_book
                   and corp_th.transaction_type_code            = trx.column_value
                   and corp_th.date_effective                  <= nvl(l_corp_period_rec.period_close_date, sysdate)
                   and corp_th.date_effective                  >= l_corp_period_rec.period_open_date
                   and corp_th.source_transaction_header_id    is null
                   and ad.asset_type                           in('CAPITALIZED', 'GROUP')
                   and ad.asset_id                              = corp_th.asset_id
                   and corp_bk.asset_id                         = corp_th.asset_id
                   and corp_bk.book_type_code                   = corp_th.book_type_code
                   and corp_bk.transaction_header_id_in         = corp_th.transaction_header_id
                   and corp_bk_old.asset_id(+)                  = corp_th.asset_id
                   and corp_bk_old.book_type_code(+)            = corp_th.book_type_code
                   and corp_bk_old.transaction_header_id_out(+) = corp_th.transaction_header_id) assets,
               fa_transaction_headers     tax_th,
               fa_books                   tax_bk,
               fa_category_book_defaults  cbd
         where tax_th.book_type_code(+)                  = p_book_type_code
           and tax_th.asset_id(+)                        = assets.asset_id
           and tax_th.source_transaction_header_id(+)    = assets.transaction_header_id
           and tax_th.source_transaction_header_id      is null
           and tax_bk.asset_id(+)                        = assets.asset_id
           and tax_bk.book_type_code(+)                  = p_book_type_code
           and tax_bk.transaction_header_id_out(+)      is null
           and cbd.category_id(+)                        = assets.asset_category_id
           and cbd.book_type_code(+)                     = p_book_type_code
           and assets.transaction_date_entered     between cbd.start_dpis(+) and nvl(cbd.end_dpis(+), assets.transaction_date_entered);

   end if;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'rows inserted into fa_parallel_workers', sql%rowcount);
   end if;

   FND_CONCURRENT.AF_COMMIT;
   /* Bug 9020567 */
   /* When Data volumes are hign in fa_parallel_workers table we need to */
   /* analze this table to compute statistics for performance reason*/

    EXECUTE IMMEDIATE 'begin sys.dbms_stats.gather_table_stats('
                 ||'''fa'''
                 ||','
                 ||'''fa_parallel_workers'''
                 ||',estimate_percent=>100, cascade=>TRUE); end;';

   -- increase the process order for group if applicable
   if nvl(fa_cache_pkg.fazcbc_record.allow_group_deprn_flag, 'N') = 'Y' then
      l_group_increment  := 1;
   end if;  -- group



   -- find all top level parent/non-parent/orphan assets for use by next cursor
   -- regardless if parent belongs to group or not

   open c_parent_assets (p_parent_request_id);

   loop

      fetch c_parent_assets bulk collect
       into l_asset_id,
            l_worker_number
      limit l_batch_size;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'rows fetched for parents, non-children and orphaned children', l_asset_id.count, p_log_level_rec => g_log_level_rec);
      end if;

      if (l_asset_id.count = 0) then
         exit;
      end if;

      -- allocates all child assets to workers
      -- note that it's technically possible to have a child in the middle
      -- of the hierarchy already assigned due to group - open for now...

      for x in 1..l_asset_id.count loop

         open c_child_assets (l_asset_id(x),
                              p_parent_request_id);

         loop

            fetch c_child_assets bulk collect
             into l_child_asset_id,
                  l_child_process_order;

            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'rows fetched for child assets', l_child_asset_id.count, p_log_level_rec => g_log_level_rec);
            end if;

            if (l_child_asset_id.count = 0) then
               exit;
            end if;

            for i in 1..l_child_asset_id.count loop
               l_child_worker_number(i) := l_worker_number(x);
            end loop;

            -- note update by asset id instead of rowid is intentional
            -- we need all lines for the asset to go to the same worker
            forall i in 1..l_child_asset_id.count
            update fa_parallel_workers
               set worker_number = l_child_worker_number(i),
                   process_order = l_child_process_order(i) + l_group_increment
             where request_id    = p_parent_request_id
               and asset_id      = l_child_asset_id(i);

         end loop;

         close c_child_assets;

      end loop;

   end loop;

   close c_parent_assets;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'done process parent and child cursors', '', p_log_level_rec => g_log_level_rec);
   end if;

   FND_CONCURRENT.AF_COMMIT;

   -- dump any debug messages from above
   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
   end if;


   x_return_status := 0;

EXCEPTION
   WHEN masscp_err THEN
      FND_CONCURRENT.AF_ROLLBACK;
      fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      -- dump any debug messages from above
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;


      X_return_status := 2;

   WHEN OTHERS THEN
      FND_CONCURRENT.AF_ROLLBACK;
      fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      -- dump any debug messages from above
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;

      x_return_status := 2;

END allocate_workers;

END fa_masscp_pkg;

/
