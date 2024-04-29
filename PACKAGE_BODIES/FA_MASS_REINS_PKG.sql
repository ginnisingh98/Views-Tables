--------------------------------------------------------
--  DDL for Package Body FA_MASS_REINS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASS_REINS_PKG" as
/* $Header: faxmrsb.pls 120.10.12010000.3 2009/07/19 09:57:22 glchen ship $ */

g_log_level_rec fa_api_types.log_level_rec_type;

PROCEDURE Mass_Reinstate(
                p_mass_retirement_id IN     	   NUMBER,
                p_parent_request_id  IN     	   NUMBER,
                p_total_requests     IN     	   NUMBER,
                p_request_number     IN     	   NUMBER,
                px_max_asset_id      IN OUT NOCOPY NUMBER,
                x_success_count         OUT NOCOPY NUMBER,
                x_failure_count         OUT NOCOPY NUMBER,
                x_return_status         OUT NOCOPY NUMBER) IS

   -- Local Variables holding Mass Retirements Information
   l_Retirement_Rowid        VARCHAR2(30);
   l_Mass_Retirement_Id      fa_mass_retirements.Mass_Retirement_Id%TYPE;
   l_Reinstate_Request_Id    fa_mass_retirements.Reinstate_Request_Id%TYPE;
   l_Retire_Request_Id       fa_mass_retirements.Retire_Request_Id%TYPE;
   l_Book_Type_Code          fa_mass_retirements.Book_Type_Code%TYPE;

   TYPE v30_tbl  IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
   TYPE num_tbl  IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;

   l_Asset_Id                num_tbl;
   l_Asset_Number            v30_tbl;
   l_Retirement_Status       v30_tbl;
   l_Retirement_Id           num_tbl;
   l_FY_Start_Date           fa_fiscal_year.start_date%TYPE;
   l_FY_End_Date             fa_fiscal_year.end_date%TYPE;

   -- Control Variables
   l_Varchar2_Dummy        VARCHAR2(80);
   l_Number_Dummy          NUMBER(15);

   -- used for bulk fetch
   l_batch_size       NUMBER;
   l_loop_count       NUMBER;

   -- variables and structs used for api call
   l_api_version                  NUMBER      := 1.0;
   l_init_msg_list                VARCHAR2(1) := FND_API.G_FALSE;
   l_commit                       VARCHAR2(1) := FND_API.G_FALSE;
   l_validation_level             NUMBER      := FND_API.G_VALID_LEVEL_FULL;
   l_return_status                VARCHAR2(1);
   l_msg_count                    number;
   l_msg_data                     VARCHAR2(4000);

   l_trans_rec         FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec     FA_API_TYPES.asset_hdr_rec_type;
   l_asset_retire_rec  FA_API_TYPES.asset_retire_rec_type;
   l_asset_dist_tbl    FA_API_TYPES.asset_dist_tbl_type;
   l_subcomp_tbl       FA_API_TYPES.subcomp_tbl_type;
   l_inv_tbl           FA_API_TYPES.inv_tbl_type;

   l_calling_fn        varchar2(35) := 'FA_MASS_REINS_PKG.mass_reinstate';
   l_string            varchar2(250);

   ret_err             EXCEPTION;
   done_exc            EXCEPTION;
   error_found         EXCEPTION;

   CURSOR mass_reinstatement IS
   SELECT fmr.mass_retirement_id,
          fmr.reinstate_request_id,
          fmr.retire_request_id,
          fmr.book_type_code,
          ffy.start_date,
          ffy.end_date
     FROM fa_mass_retirements    fmr,
          fa_book_controls       fbc,
          fa_fiscal_year         ffy
    WHERE fmr.mass_retirement_id         = p_Mass_Retirement_Id
      AND fmr.book_type_code             = fbc.book_type_code
      AND ffy.fiscal_year_name           = fbc.fiscal_year_name
      AND ffy.fiscal_year                = fbc.current_fiscal_year ;

   CURSOR qualified_assets IS
   SELECT th.asset_id,
          ad.asset_number,
          ret.status,
          ret.retirement_id
     FROM fa_retirements         ret,
          fa_transaction_headers th,
          fa_additions_b ad,
          fa_books bk
    WHERE th.mass_transaction_id         = l_mass_retirement_id
      AND th.book_type_code              = l_Book_Type_Code
      AND th.transaction_type_code       in ('FULL RETIREMENT','PARTIAL RETIREMENT') -- df. this change makes partial unit retirements to be mass reinstated.
      AND th.transaction_key             = 'R'
      AND ret.book_type_code             = th.book_type_code
      AND ret.asset_id                   = th.asset_id
      AND ret.transaction_header_id_in   = th.transaction_header_id
      AND ret.transaction_header_id_out IS NULL
      AND ret.date_retired BETWEEN l_FY_Start_Date
                               AND l_FY_End_Date
      AND ret.asset_id > px_max_asset_id
      AND ret.asset_id = ad.asset_id
      AND ret.asset_id = bk.asset_id
      AND ret.book_type_code = bk.book_type_code
      AND bk.date_ineffective is null
      AND MOD(nvl(bk.group_asset_id,
                  ret.asset_id),
              p_total_requests) = (p_request_number - 1)
    ORDER BY ret.asset_id, ret.retirement_id;

    /* Bug7013720: added ret.asset_id to order by clause.
       This should not be a permanent solution.  Ideally, we should
       move away from the px_max_* logic. */

BEGIN

   X_success_count := 0;
   X_failure_count := 0;
   px_max_asset_id := nvl(px_max_asset_id, 0);


   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise  ret_err;
      end if;
   end if;

   if (px_max_asset_id = 0) then

      FND_FILE.put(FND_FILE.output,'');
      FND_FILE.new_line(FND_FILE.output,1);

      -- dump out the headings
      fnd_message.set_name('OFA', 'FA_MASSRET_REPORT_COLUMN');
      l_string := fnd_message.get;

      FND_FILE.put(FND_FILE.output,l_string);
      FND_FILE.new_line(FND_FILE.output,1);

      fnd_message.set_name('OFA', 'FA_MASSRET_REPORT_LINE');
      l_string := fnd_message.get;

      FND_FILE.put(FND_FILE.output,l_string);
      FND_FILE.new_line(FND_FILE.output,1);

   end if;

   -- clear the debug stack for each asset
   FA_DEBUG_PKG.Initialize;
   -- reset the message level to prevent bogus errors
   FA_SRVR_MSG.Set_Message_Level(message_level => 10, p_log_level_rec => g_log_level_rec);

   OPEN  mass_reinstatement;
   FETCH mass_reinstatement
    INTO l_Mass_Retirement_Id,
         l_reinstate_request_id,
         l_retire_request_id,
         l_Book_Type_Code,
         l_FY_Start_Date,
         l_FY_End_Date;

   CLOSE  mass_reinstatement;


   if not fa_cache_pkg.fazcbc(X_book => l_book_type_code, p_log_level_rec => g_log_level_rec) then
      raise error_found;
   end if;

   l_batch_size  := nvl(fa_cache_pkg.fa_batch_size, 200);

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'fetching assets', '', p_log_level_rec => g_log_level_rec);
   end if;


   OPEN qualified_assets;
   FETCH qualified_assets BULK COLLECT
    INTO l_Asset_Id,
         l_Asset_Number,
         l_Retirement_Status,
         l_Retirement_Id
   LIMIT l_batch_size;


   if (l_asset_id.count = 0) then
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'no assets to process', '', p_log_level_rec => g_log_level_rec);
      end if;
      raise done_exc;
   end if;

   l_asset_hdr_rec.book_type_code    := l_book_type_code;

   for l_loop_count in 1..l_asset_id.count loop -- qualified_assets

      -- clear the debug stack for each asset
      FA_DEBUG_PKG.Initialize;
      -- reset the message level to prevent bogus errors
      FA_SRVR_MSG.Set_Message_Level(message_level => 10, p_log_level_rec => g_log_level_rec);

      fa_srvr_msg.add_message(
          calling_fn => NULL,
          name       => 'FA_SHARED_ASSET_NUMBER',
          token1     => 'NUMBER',
          value1     => l_asset_number(l_loop_count),
          p_log_level_rec => g_log_level_rec);

      BEGIN

         l_trans_rec.transaction_header_id     := NULL;
         l_trans_rec.transaction_type_code     := NULL;
         l_trans_rec.who_info.last_update_date := sysdate;
         l_asset_hdr_rec.asset_id              := l_asset_id(l_loop_count);
         l_asset_retire_rec.retirement_id      := l_retirement_id(l_loop_count);

         IF l_Retirement_Status(l_loop_count) = 'PENDING' THEN

            fa_retirement_pub.undo_retirement
               (p_api_version         => l_api_version,
                p_init_msg_list       => l_init_msg_list,
                p_commit              => l_commit,
                p_validation_level    => l_validation_level,
                p_calling_fn          => l_calling_fn,
                x_return_status       => l_return_status,
                x_msg_count           => l_msg_count,
                x_msg_data            => l_msg_data,
                px_trans_rec          => l_trans_rec,
                px_asset_hdr_rec      => l_asset_hdr_rec,
                px_asset_retire_rec   => l_asset_retire_rec
               );

         ELSIF l_Retirement_Status(l_loop_count) = 'PROCESSED' THEN

            fa_retirement_pub.do_reinstatement
               (p_api_version         => l_api_version,
                p_init_msg_list       => l_init_msg_list,
                p_commit              => l_commit,
                p_validation_level    => l_validation_level,
                p_calling_fn          => l_calling_fn,
                x_return_status       => l_return_status,
                x_msg_count           => l_msg_count,
                x_msg_data            => l_msg_data,
                px_trans_rec          => l_trans_rec,
                px_asset_hdr_rec      => l_asset_hdr_rec,
                px_asset_retire_rec   => l_asset_retire_rec,
                p_asset_dist_tbl      => l_asset_dist_tbl,
                p_subcomp_tbl         => l_subcomp_tbl,
                p_inv_tbl             => l_inv_tbl
               );

         END IF; -- l_Retirement_Status =...

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            raise ret_err;
         END IF;

         X_success_count := X_success_count + 1;

         write_message(l_asset_number(l_loop_count),
                       'FA_MCP_REINSTATE_SUCCESS');

      EXCEPTION
         WHEN ret_err THEN
              FND_CONCURRENT.AF_ROLLBACK;
               x_failure_count := x_failure_count + 1;
               write_message(l_asset_number(l_loop_count),
                             NULL);
               if (g_log_level_rec.statement_level) then
                  fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
               end if;

         WHEN others THEN
               FND_CONCURRENT.AF_ROLLBACK;
               x_failure_count := x_failure_count + 1;
               write_message(l_asset_number(l_loop_count),
                             NULL);
               if (g_log_level_rec.statement_level) then
                  fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
               end if;

      END;

   END LOOP; -- qualified_assets

   px_max_asset_id := l_asset_id(l_asset_id.count);

   FND_CONCURRENT.AF_COMMIT;

   x_return_status := 0;


EXCEPTION -- Mass_Reinstate
   WHEN done_exc then
        x_return_status :=  0;

   WHEN error_found THEN
        fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
        FND_CONCURRENT.AF_ROLLBACK;
        if (g_log_level_rec.statement_level) then
           fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
        end if;

        x_return_status :=  2;

   WHEN Others THEN
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
        FND_CONCURRENT.AF_ROLLBACK;
        if (g_log_level_rec.statement_level) then
           fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
        end if;

        x_return_status :=  2;

END Mass_Reinstate;

-----------------------------------------------------------------------------

PROCEDURE write_message
              (p_asset_number    in varchar2,
               p_message         in varchar2) IS

   l_message      varchar2(30);
   l_mesg         varchar2(100);
   l_string       varchar2(512);
   l_calling_fn   varchar2(40);  -- conditionally populated below

BEGIN

   -- first dump the message to the output file
   -- set/translate/retrieve the mesg from fnd

   l_message := nvl(p_message,  'FA_MASSRST_FAIL_TRX');

   if (l_message <> 'FA_MCP_REINSTATE_SUCCESS') then
      l_calling_fn := 'fa_mass_reins_pkg.mass_reins';
   end if;

   fnd_message.set_name('OFA', p_message);
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

END FA_MASS_REINS_PKG;

/
