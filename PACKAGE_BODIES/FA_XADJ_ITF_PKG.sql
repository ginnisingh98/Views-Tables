--------------------------------------------------------
--  DDL for Package Body FA_XADJ_ITF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_XADJ_ITF_PKG" as
/* $Header: faxadjib.pls 120.4.12010000.3 2009/07/19 12:55:17 glchen ship $   */

g_log_level_rec fa_api_types.log_level_rec_type;

PROCEDURE faxadji(
                p_batch_id           IN     VARCHAR2,
                p_old_flag           IN     VARCHAR2,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                p_request_number     IN     NUMBER,
                px_max_asset_id      IN OUT NOCOPY NUMBER,
                x_success_count         OUT NOCOPY number,
                x_failure_count         OUT NOCOPY number,
		x_worker_jobs           OUT  NOCOPY NUMBER,
                x_return_status         OUT NOCOPY number) IS

   -- messaging
   l_batch_size                   NUMBER;
   l_loop_count                   NUMBER;
   l_count		          NUMBER := 0;

   -- misc
   l_request_id                   NUMBER;
   l_trx_approval                 BOOLEAN;
   rbs_name	                  VARCHAR2(30);
   sql_stmt                       VARCHAR2(101);

   -- types
   TYPE rowid_tbl  IS TABLE OF VARCHAR2(50)  INDEX BY BINARY_INTEGER;
   TYPE number_tbl IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
   TYPE v30_tbl    IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;

   -- used for main cursor
   l_itf_rowid                    rowid_tbl;
   l_asset_id                     number_tbl;
   l_asset_number                 v30_tbl;
   l_book_type_code               v30_tbl;
   l_extended_deprn_flag          v30_tbl;
   l_extended_deprn_period        number_tbl;
   l_posting_status               v30_tbl;
   l_extended_deprn_limit         number_tbl;


   -- used for api call
   l_return_status                varchar2(1);
   l_mesg_count                   number := 0;
   l_mesg_name                    varchar2(30);
   l_mesg                         varchar2(4000);

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

   l_calling_fn                   VARCHAR2(30) := 'FA_XADJ_ITF_PKG.faxadji';

   -- for parallelization
   l_unassigned_cnt      number := 0;
   l_failed_cnt          number := 0;
   l_wip_cnt             number := 0;
   l_completed_cnt       number := 0;
   l_total_cnt           number := 0;
   l_counter             number := 0;
   l_start_range         number := 0;
   l_end_range           number := 0;

   v_err number;
   v_msg varchar2(255);

   cursor c_assets is
   select fat.rowid
        , fab.asset_id id
        , fat.asset_number num
	, fat.book_type_code book
        , fat.extended_deprn_flag flag
        , fat.extended_depreciation_period period
	, fat.posting_status status
	, fat.extended_deprn_limit -- bug 6658280
     from fa_adjustments_t fat,
          fa_additions_b fab
    where fat.asset_number = fab.asset_number
      and fat.posting_status = 'POST' /* bug 8597025  */
      and fat.batch_id = p_batch_id
      and fab.asset_id >= l_start_range
      and fab.asset_id <= l_end_range
 order by fat.book_type_code, fab.asset_id;

   -- Exceptions
   done_exc               EXCEPTION;
   data_error             EXCEPTION;
   fapadj_err             EXCEPTION;


BEGIN

--    px_max_asset_id := nvl(px_max_asset_id, 0);
    x_success_count := 0;
    x_failure_count := 0;
    x_worker_jobs   := 0;

    l_request_id := fnd_global.conc_request_id;

    if (rbs_name is not null) then
        sql_stmt := 'Set Transaction Use Rollback Segment '|| rbs_name;
        execute immediate sql_stmt;
    end if;


   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise  fapadj_err;
      end if;
   end if;

    l_batch_size  := nvl(fa_cache_pkg.fa_batch_size, 1000);

    if (g_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,'Before','Fetching data', p_log_level_rec => g_log_level_rec);
    end if;

      /*Added for parallelism start */
    if (p_total_requests > 1) then

      begin

             select nvl(sum(decode(status,'UNASSIGNED', 1, 0)),0),
          	     nvl(sum(decode(status,'FAILED', 1, 0)),0),
          	     nvl(sum(decode(status,'IN PROCESS', 1, 0)),0),
          	     nvl(sum(decode(status,'COMPLETED',1 , 0)),0),
          	     count(*)
             into   l_unassigned_cnt,
          	     l_failed_cnt,
          	     l_wip_cnt,
          	     l_completed_cnt,
          	     l_total_cnt
             from   fa_worker_jobs
             where  request_id = p_parent_request_id;
      exception
             when others then
                   raise fapadj_err;
      end;
      if g_log_level_rec.statement_level then
         fa_debug_pkg.add(l_calling_fn, 'Job status - Unassigned: ', l_unassigned_cnt, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'Job status - In Process: ', l_wip_cnt, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'Job status - Completed: ',  l_completed_cnt, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'Job status - Failed: ',     l_failed_cnt, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'Job status - Total: ',      l_total_cnt, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'Job status - p_parent_request_id ',      p_parent_request_id, p_log_level_rec => g_log_level_rec);
      end if;

      if (l_failed_cnt > 0) then
         if g_log_level_rec.statement_level then
   	fa_debug_pkg.add(l_calling_fn, 'another worker has errored out: ', 'stop processing', p_log_level_rec => g_log_level_rec);
         end if;
         raise fapadj_err;  -- probably not
      elsif (l_unassigned_cnt = 0) then
         if g_log_level_rec.statement_level then
   	 fa_debug_pkg.add(l_calling_fn, 'no more jobs left', 'terminating.', p_log_level_rec => g_log_level_rec);
         end if;
         raise done_exc;
      elsif (l_completed_cnt = l_total_cnt) then
         if g_log_level_rec.statement_level then
   	 fa_debug_pkg.add(l_calling_fn, 'all jobs completed, no more jobs. ', 'terminating', p_log_level_rec => g_log_level_rec);
         end if;
         raise done_exc;
      elsif (l_unassigned_cnt > 0) then
         begin

	       update fa_worker_jobs
               set    status = 'IN PROCESS',
         	     worker_num = p_request_number
               where  status = 'UNASSIGNED'
               and    request_id = p_parent_request_id
               and    rownum < 2;

               l_counter := sql%rowcount;

	       if g_log_level_rec.statement_level then
                  fa_debug_pkg.add(l_calling_fn, 'taking job from job queue',  l_counter, p_log_level_rec => g_log_level_rec);
               end if;

	       commit;
	 exception
               when others then
               fa_debug_pkg.add(l_calling_fn, 'exception ',  ' raised', p_log_level_rec => g_log_level_rec);
               raise fapadj_err;
	 end;


	 x_worker_jobs := l_unassigned_cnt;

      end if;
   end if;     --  if (p_total_requests > 1) then

   /*end parallelism*/

   if (l_counter > 0 or p_total_requests < 2) then
          begin

               select start_range
                     ,end_range
                into l_start_range
                    ,l_end_range
                from fa_worker_jobs
               where request_id = p_parent_request_id
                 and worker_num = p_request_number
                 and  status = 'IN PROCESS';

          exception

                 when no_data_found then

        	      select min(asset_id), max(asset_id)
                        into l_start_range
            	       , l_end_range
                        from fa_adjustments_t fat
            	       , fa_additions_b fab
                       where batch_id = p_batch_id
                         and fat.asset_number = fab.asset_number;

        	 when others then
                      fa_debug_pkg.add(l_calling_fn, 'exception', 'raised', p_log_level_rec => g_log_level_rec);
        	      raise fapadj_err;
          end;

   end if;

   open c_assets;
   loop
   fetch c_assets bulk collect
       into l_itf_rowid                    ,
            l_asset_id                     ,
            l_asset_number                 ,
            l_book_type_code               ,
            l_extended_deprn_flag          ,
            l_extended_deprn_period        ,
            l_posting_status               ,
            l_extended_deprn_limit  -- bug 6658280
      limit l_batch_size;

   -- 7339522 closing the cursor after loop.
   --close c_assets;

    if (g_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn,'After','Fetching data', p_log_level_rec => g_log_level_rec);
    end if;

   if l_itf_rowid.count = 0 then
      raise done_exc;
   end if;

   for l_loop_count in 1..l_itf_rowid.count loop

      -- set savepoint
      savepoint fapadj_savepoint;

      -- clear the debug stack for each asset
      FA_DEBUG_PKG.initialize;
      -- reset the message level to prevent bogus errors
      FA_SRVR_MSG.Set_Message_Level(message_level => 10, p_log_level_rec => g_log_level_rec);

      l_mesg_name := null;
      fa_srvr_msg.add_message(
          calling_fn => NULL,
          name       => 'FA_SHARED_ASSET_NUMBER',
          token1     => 'NUMBER',
          value1     => l_asset_number(l_loop_count));

      if (nvl(l_extended_deprn_flag(l_loop_count), 'NULL') <> 'Y' and
          nvl(p_old_flag, 'NULL') <> 'Y') then

	       if(nvl(l_posting_status(l_loop_count),'NULL') <> 'POST') then
                    update fa_adjustments_t
                       set request_id = l_request_id
                     where rowid      = l_itf_rowid(l_loop_count);

                else
                    if(nvl(l_extended_deprn_flag(l_loop_count),'NULL') <> 'NULL' or
		       nvl(l_extended_deprn_flag(l_loop_count),'NULL') <> nvl(p_old_flag,'NULL')) then
           		    update fa_books
                               set extended_deprn_flag = l_extended_deprn_flag(l_loop_count)
                             where asset_id = l_asset_id(l_loop_count)
                               and book_type_code = l_book_type_code(l_loop_count)
                               and transaction_header_id_out is null;
                    end if;
                    update fa_adjustments_t
                       set posting_status = 'POSTED'
                         , request_id = l_request_id
                     where rowid      = l_itf_rowid(l_loop_count);
	       end if;

            -- Increment asset count and dump asset_number to the log file
               x_success_count := x_success_count + 1;
               write_message(l_asset_number(l_loop_count),'FA_MCP_ADJUSTMENT_SUCCESS');

               if (g_log_level_rec.statement_level) then
                 fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
               end if;

     else
		if(nvl(l_posting_status(l_loop_count),'NULL') <> 'POST' or
		   nvl(l_extended_deprn_flag(l_loop_count),'NULL') = 'NULL' or
		   nvl(l_extended_deprn_flag(l_loop_count),'NULL') = nvl(p_old_flag,'NULL')) then
                    update fa_adjustments_t
                       set request_id = l_request_id
                     where rowid      = l_itf_rowid(l_loop_count);
		else

                      BEGIN

                               -- reset the structs to null
			       l_trans_rec                    := NULL;
			       l_asset_hdr_rec                := NULL;
			       l_asset_fin_rec_adj            := NULL;
			       l_asset_fin_rec_new            := NULL;
			       l_asset_fin_mrc_tbl_new.delete;
			       l_inv_trans_rec                := NULL;
			       l_inv_tbl.delete;
			       l_asset_deprn_rec_adj          := NULL;
			       l_asset_deprn_rec_new          := NULL;
			       l_asset_deprn_mrc_tbl_new.delete;

			       -- reset the who info in trans rec
			       l_trans_rec.who_info.last_updated_by    := FND_GLOBAL.USER_ID;
			       l_trans_rec.who_info.created_by         := FND_GLOBAL.USER_ID;
			       l_trans_rec.who_info.creation_date      := sysdate;
			       l_trans_rec.who_info.last_update_date   := sysdate;
			       l_trans_rec.who_info.last_update_login  := FND_GLOBAL.CONC_LOGIN_ID;
			       l_trans_rec.mass_reference_id           := p_parent_request_id;
			       l_trans_rec.calling_interface           := 'FAXADJ';

			    -- counter for the number of assets
			       l_count       := l_count + 1;

			    -- asset header info
			       l_asset_hdr_rec.asset_id       := l_asset_id(l_loop_count);
			       l_asset_hdr_rec.book_type_code := l_book_type_code(l_loop_count);

			    -- asset fin info
			       l_asset_fin_rec_adj.extended_deprn_flag := nvl(l_extended_deprn_flag(l_loop_count), FND_API.G_MISS_CHAR);
			       l_asset_fin_rec_adj.extended_depreciation_period := l_extended_deprn_period(l_loop_count);
			       -- bug6658280  incase the extended_deprn_limit is null then give it a default value of 1
			       l_asset_fin_rec_adj.allowed_deprn_limit_amount := nvl(l_extended_deprn_limit(l_loop_count),1);


			    -- asset transaction info
			       l_trans_rec.calling_interface := 'FAEXDEPR';
			       l_trans_rec.transaction_subtype := 'EXPENSED';
			       l_trans_rec.amortization_start_date := null;

			       if l_trans_rec.amortization_start_date is not null then
				 l_trans_rec.transaction_date_entered := l_trans_rec.amortization_start_date;
			       end if;

			       l_trans_rec.who_info.last_updated_by   := FND_GLOBAL.USER_ID;
			       l_trans_rec.transaction_type_code      := 'ADJUSTMENT';

			    -- set up other needed struct values
			       l_trans_rec.mass_reference_id := l_request_id;

			    -- perform the Adjustment
			       fa_adjustment_pub.do_adjustment
				  (p_api_version             => 1.0,
				   p_init_msg_list           => FND_API.G_FALSE,
				   p_commit                  => FND_API.G_FALSE,
				   p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
				   x_return_status           => l_return_status,
				   x_msg_count               => l_mesg_count,
				   x_msg_data                => l_mesg,
				   p_calling_fn              => l_calling_fn,
				   px_trans_rec              => l_trans_rec,
				   px_asset_hdr_rec          => l_asset_hdr_rec,
				   p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
				   x_asset_fin_rec_new       => l_asset_fin_rec_new,
				   x_asset_fin_mrc_tbl_new   => l_asset_fin_mrc_tbl_new,
				   px_inv_trans_rec          => l_inv_trans_rec,
				   px_inv_tbl                => l_inv_tbl,
				   p_asset_deprn_rec_adj     => l_asset_deprn_rec_adj,
				   x_asset_deprn_rec_new     => l_asset_deprn_rec_new,
				   x_asset_deprn_mrc_tbl_new => l_asset_deprn_mrc_tbl_new,
				   p_group_reclass_options_rec => l_group_reclass_options_rec
				  );

			       if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
				  raise data_error;
			       end if;

			       -- flag interface record as posted
			       update fa_adjustments_t
				  set posting_status   = 'POSTED',
				      request_id   = l_request_id
				where rowid        = l_itf_rowid(l_loop_count);

			       -- Increment asset count and dump asset_number to the log file
			       x_success_count := x_success_count + 1;
			       write_message(l_asset_number(l_loop_count),'FA_MCP_ADJUSTMENT_SUCCESS');

			       if (g_log_level_rec.statement_level) then
				  fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
			       end if;


			 EXCEPTION -- exceptions

			       when data_error then
				  x_failure_count := x_failure_count + 1;

				  write_message(l_asset_number(l_loop_count),l_mesg_name);

				  if (g_log_level_rec.statement_level) then
				      fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
				  end if;

				  rollback to savepoint fapadj_savepoint;

			       when others then
				  x_failure_count := x_failure_count + 1;

				  write_message(l_asset_number(l_loop_count),'FA_TAXUP_FAIL_TRX');
				  fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

				  if (g_log_level_rec.statement_level) then
				     fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
				  end if;

				  rollback to savepoint fapadj_savepoint;

			 END;    -- end
		end if;
        end if;

   -- commit every batch and reset the large rollback segment
      COMMIT WORK;

      end loop; -- inner loop to loop through arrays

      --7339522 Exiting when No of records fetched < limit i.e. no more records are to fetched

      EXIT WHEN l_itf_rowid.COUNT < l_batch_size;
      end loop;
      close c_assets;

      --7339522 Closing the cursor here instead of closing it in starting

--   px_max_asset_id := l_asset_id(l_asset_id.count);

       if (p_total_requests > 1) then

          if (x_failure_count <> 0) then

               update fa_worker_jobs
                  set status     = 'FAILED'
                where request_id = p_parent_request_id
                  and worker_num = p_request_number
                  and status     = 'IN PROCESS';

		commit;
     	  else
               	   update fa_worker_jobs
                      set status     = 'COMPLETED'
                    where request_id = p_parent_request_id
                      and worker_num = p_request_number
                      and status     = 'IN PROCESS';

	       commit;

	  end if;


	   if g_log_level_rec.statement_level then
              fa_debug_pkg.add(l_calling_fn, 'updating', 'worker jobs', p_log_level_rec => g_log_level_rec);
           end if;

       end if;

   x_return_status := 0;

EXCEPTION
   when done_exc then

       if (p_total_requests > 1) then

	   update fa_worker_jobs
              set status     = 'COMPLETED'
            where request_id = p_parent_request_id
              and worker_num = p_request_number
              and status     = 'IN PROCESS';
            commit;

	   if g_log_level_rec.statement_level then
              fa_debug_pkg.add(l_calling_fn, 'updating', 'worker jobs', p_log_level_rec => g_log_level_rec);
           end if;
       end if;

    x_return_status := 0;

   when fapadj_err then

       if (p_total_requests > 1) then

	   update fa_worker_jobs
              set status     = 'FAILED'
            where request_id = p_parent_request_id
              and worker_num = p_request_number
              and status     = 'IN PROCESS';
            commit;

	   if g_log_level_rec.statement_level then
              fa_debug_pkg.add(l_calling_fn, 'updating', 'worker jobs', p_log_level_rec => g_log_level_rec);
           end if;
       end if;

      ROLLBACK WORK;
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      -- Dump Debug messages when run in debug mode to log file
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;

      x_return_status := 2;

   when others then

       if (p_total_requests > 1) then

	   update fa_worker_jobs
              set status     = 'FAILED'
            where request_id = p_parent_request_id
              and worker_num = p_request_number
              and status     = 'IN PROCESS';
            commit;

	   if g_log_level_rec.statement_level then
              fa_debug_pkg.add(l_calling_fn, 'updating', 'worker jobs', p_log_level_rec => g_log_level_rec);
           end if;
       end if;

      ROLLBACK WORK;
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      -- Dump Debug messages when run in debug mode to log file
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;

      x_return_status := 2;

END faxadji;   -- end

-----------------------------------------------------------------------------

PROCEDURE write_message
              (p_asset_number    in varchar2,
               p_message         in varchar2) IS

   l_message      varchar2(30);
   l_mesg         varchar2(100);
   l_string       varchar2(512);
   l_calling_fn   varchar2(40);   -- condiajitfonally populated below

BEGIN

   -- first dump the message to the output file
   -- set/translate/retrieve the mesg from fnd

   l_message := nvl(p_message,  'FA_TAXUP_FAIL_TRX');

   if (l_message <> 'FA_MCP_ADJUSTMENT_SUCCESS') then
      l_calling_fn := 'fa_masschg_pkg.do_mass_change';
   end if;

   fnd_message.set_name('OFA', l_message);
   l_mesg := substrb(fnd_message.get, 1, 100);

   l_string       := rpad(p_asset_number, 15) || ' ' || l_mesg;

   FND_FILE.put(FND_FILE.output,l_string);
   FND_FILE.new_line(FND_FILE.output,1);

   -- now process the messages for the log file
   fa_srvr_msg.add_message
       (calling_fn => l_calling_fn,
        name       => l_message, p_log_level_rec => g_log_level_rec);

EXCEPTION
   when others then
       raise;

END write_message;
-----------------------------------------------------------------------------
PROCEDURE Load_Workers(
                p_batch_id           IN     NUMBER,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                x_return_status      OUT NOCOPY NUMBER) IS

   l_batch_size         number;
   l_calling_fn         varchar2(60) := 'FA_XADJ_ITF_PKG.Load_Workers';
   error_found          exception;

BEGIN


   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise  FND_API.G_EXC_ERROR;
      end if;
   end if;

  l_batch_size  := nvl(fa_cache_pkg.fa_batch_size, 1000);

  if (p_total_requests > 1) then

   insert into fa_worker_jobs
          (start_range, end_range, worker_num, status,request_id)
   select min(aid), max(aid), 0,
          'UNASSIGNED', p_parent_request_id  from ( select /*+ parallel(dh) */
          fab.asset_id aid, floor(rank()
          over (order by fab.asset_id)/l_batch_size ) unit_id
     from fa_adjustments_t fat, fa_additions_b fab
    where batch_id = p_batch_id
      and fat.asset_number = fab.asset_number)
    group by unit_id;

    commit;
  end if;

   if g_log_level_rec.statement_level then
      fa_debug_pkg.add(l_calling_fn, 'rows inserted into worker jobs: ', SQL%ROWCOUNT);
   end if;

   x_return_status := 0;

EXCEPTION
   when error_found then
        x_return_status := 2;

   when OTHERS then
        fa_srvr_msg.add_sql_error(calling_fn => 'FA_XADJ_ITF_PKG.Load_Workers',  p_log_level_rec => g_log_level_rec);
        rollback;
        if (g_log_level_rec.statement_level) then
           fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
        end if;
        x_return_status := 2;

END Load_Workers;

END FA_XADJ_ITF_PKG;

/
