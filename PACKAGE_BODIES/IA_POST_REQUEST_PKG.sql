--------------------------------------------------------
--  DDL for Package Body IA_POST_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IA_POST_REQUEST_PKG" as
/* $Header: IAPREQB.pls 120.1 2005/10/05 10:25:18 bridgway noship $   */

g_print_debug boolean := fa_cache_pkg.fa_print_debug;

FUNCTION validate_transfer (
            p_request_detail_id    IN NUMBER,
            p_book_type_code       IN VARCHAR2,
            p_asset_id             IN NUMBER,
            p_distribution_id_from IN NUMBER,
            p_calling_fn           IN VARCHAR2,
            x_units                OUT NOCOPY NUMBER
) RETURN BOOLEAN;

/*
FUNCTION get_current_units(p_asset_id        IN  NUMBER,
                           p_distribution_id IN  NUMBER,
                           x_units           OUT NOCOPY NUMBER
) RETURN BOOLEAN;
*/


PROCEDURE post_transfer (
     errbuf                  OUT NOCOPY     VARCHAR2,
     retcode                 OUT NOCOPY     NUMBER,
     p_book_type_code        IN      VARCHAR2
) IS

   cursor tfr_lines is
      select irh.request_id,
             irh.book_type_code,
             irh.request_date,
             ird.asset_id,
             ird.request_detail_id,
             ird.from_distribution_id,
             ird.to_distribution_id,
             ird.to_location_id,
             ird.to_employee_id,
             ird.to_expense_ccid,
             ird.effective_date,
             irh.status,
             ird.status,
             ad.asset_number
      from   ia_request_headers irh,
             ia_request_details ird,
             fa_book_controls bc,
             fa_additions ad,
             fa_deprn_periods dp
      where  irh.request_id = ird.request_id
      and    irh.book_type_code = p_book_type_code
      and    irh.book_type_code = ird.book_type_code
      and    irh.book_type_code = bc.book_type_code
      and    irh.status in ('POST','PARTIAL_POST')
      and    ird.status = 'POST'
      and    ird.asset_id = ad.asset_id
      and    ird.book_type_code = dp.book_type_code
      and    dp.period_close_date is null
      and    nvl(ird.effective_date,nvl(irh.request_date,sysdate))
                <= dp.calendar_period_close_date
--      and    ird.request_detail_id > px_max_detail_id
--      and    MOD(ird.request_detail_id, p_total_requests) = (p_request_number -1)
      order by irh.request_id, ird.request_detail_id;

   -- Used for bulk fetching
   l_batch_size                   number;
   l_counter                      number;

   -- Types for table variable
   type num_tbl_type  is table of number        index by binary_integer;
   type char_tbl_type is table of varchar2(200) index by binary_integer;
   type date_tbl_type is table of date          index by binary_integer;

   -- Used for formatting
   l_token                        varchar2(40);
   l_value                        varchar2(40);
   l_string                       varchar2(512);

   -- Variables and structs used for api call
   l_debug_flag                   varchar2(3)  := 'NO';
   l_api_version                  number       := 1;  -- 1.0
   l_init_msg_list                varchar2(50) := FND_API.G_FALSE; -- 1
   l_commit                       varchar2(1)  := FND_API.G_FALSE;
   l_validation_level             number       := FND_API.G_VALID_LEVEL_FULL;
   l_return_status                varchar2(10);
   l_msg_count                    number;
   l_msg_data                     varchar2(4000);
   l_calling_fn                   varchar2(100) := 'IA_POST_REQUEST_PKG.post_transfer';

   -- Standard Who columns
   l_last_update_login            number(15) := fnd_global.login_id;
   l_created_by                   number(15) := fnd_global.user_id;
   l_creation_date                date       := sysdate;

   l_trans_rec                    fa_api_types.trans_rec_type;
   l_asset_hdr_rec                fa_api_types.asset_hdr_rec_type;
   l_asset_dist_rec               fa_api_types.asset_dist_rec_type;
   l_asset_dist_tbl               fa_api_types.asset_dist_tbl_type;

   -- Column types for bulk fetch
   l_request_id           num_tbl_type;
   l_book_type_code       char_tbl_type;
   l_request_date         date_tbl_type;
   l_asset_id             num_tbl_type;
   l_asset_number         char_tbl_type;
   l_request_detail_id    num_tbl_type;
   l_distribution_id_from num_tbl_type;
   l_distribution_id_to   num_tbl_type;
   l_to_location_id       num_tbl_type;
   l_to_employee_id       num_tbl_type;
   l_to_expense_ccid      num_tbl_type;
   l_effective_date       date_tbl_type;
   l_head_status          char_tbl_type;
   l_det_status           char_tbl_type;

   l_success_count      number;
   l_failure_count      number;
   l_curr_units           number;
   l_txn_date           date;
   prev_req_id          number;
   error_occured          boolean;
   masstfr_err EXCEPTION;
   h_msg_count    NUMBER := 0;
   h_msg_data     VARCHAR2(2000) := NULL;
   prev_status    VARCHAR2(30) := NULL;


BEGIN

   -- Initialize variables
   --px_max_detail_id := nvl(px_max_detail_id, 0);
   l_success_count := 0;
   l_failure_count := 0;
   retcode := 0;
   prev_req_id := 0;
   error_occured := FALSE;

   -- Clear the debug stack for each asset
   fa_debug_pkg.initialize;
   fa_srvr_msg.init_server_message;

   if not fa_cache_pkg.fazcbc(X_book => p_book_type_code) then
      raise masstfr_err;
   end if;
   l_batch_size := nvl(fa_cache_pkg.fa_batch_size, 200);

   open tfr_lines;

   fetch tfr_lines bulk collect into
        l_request_id,
        l_book_type_code,
        l_request_date,
        l_asset_id,
        l_request_detail_id,
        l_distribution_id_from,
        l_distribution_id_to,
        l_to_location_id,
        l_to_employee_id,
        l_to_expense_ccid,
        l_effective_date,
        l_head_status,
        l_det_status ,
        l_asset_number

   limit l_batch_size;

   close tfr_lines;

   -- Do transfer
   for i in 1..l_request_detail_id.count loop
      l_counter := i;

      SAVEPOINT process_transfer;

      -- VALIDATIONS --
      if (not validate_transfer (
            p_request_detail_id => l_request_detail_id(i),
            p_book_type_code    => l_book_type_code(i),
            p_asset_id          => l_asset_id(i),
            p_distribution_id_from => l_distribution_id_from(i),
            p_calling_fn        => l_calling_fn,
            x_units             => l_curr_units)) then

         -- Mark batch as failed but continue despite errors
         --ROLLBACK TO process_transfer;

         l_det_status(i) := 'ERROR';
         l_failure_count := l_failure_count + 1;
         retcode := 2;

         fa_srvr_msg.add_message(
               calling_fn => NULL,
               name        => 'FA_TAXUP_ASSET_FAILURE',
               token1      => 'NUMBER',
               value1      => l_asset_number(i));

      else

         -- LOAD STRUCTS --
         -- ***** Asset Transaction Info ***** --
         l_trans_rec                    := NULL;
         l_asset_hdr_rec                := NULL;

--         l_trans_rec.mass_reference_id           := p_parent_request_id;
         l_trans_rec.calling_interface           := 'IAPTFR';

         --l_trans_rec.mass_transaction_id         := p_mass_transfer_id;
         --l_trans_rec.transaction_date_entered := l_effective_date(i);
         --l_trans_rec.source_transaction_header_id :=
         --l_trans_rec.transaction_subtype :=
         --l_trans_rec.transaction_key :=
         --l_trans_rec.amortization_start_date :=

         l_txn_date := nvl(l_effective_date(i), nvl(l_request_date(i),sysdate));
         l_trans_rec.transaction_date_entered := l_txn_date;
         l_trans_rec.who_info.last_update_date := l_creation_date;
         l_trans_rec.who_info.last_updated_by := l_created_by;
         l_trans_rec.who_info.created_by := l_created_by;
         l_trans_rec.who_info.creation_date := l_creation_date;
         l_trans_rec.who_info.last_update_login := l_last_update_login;

         -- ***** Asset Header Info ***** --
         l_asset_hdr_rec.asset_id        := l_asset_id(i);
         l_asset_hdr_rec.book_type_code  := l_book_type_code(i);
         --l_asset_hdr_rec.set_of_books_id := l_set_of_books_id(i);
         --l_asset_hdr_rec.period_of_addition :=

         -- ***** Asset Distribution Info ***** --
         l_asset_dist_tbl.delete;

         l_asset_dist_rec := NULL;
         l_asset_dist_rec.distribution_id := l_distribution_id_from(i);
         --l_asset_dist_rec.units_assigned :=
         l_asset_dist_rec.transaction_units := -1 * l_curr_units;
         --l_asset_dist_rec.assigned_to := l_from_employee_id(i);
         --l_asset_dist_rec.expense_ccid := l_from_gl_ccid(i);
         --l_asset_dist_rec.location_ccid := l_from_location_id(i);

         l_asset_dist_tbl(1) := l_asset_dist_rec;

         l_asset_dist_rec := NULL;
         l_asset_dist_rec.distribution_id := NULL;
         --l_asset_dist_rec.units_assigned :=
         l_asset_dist_rec.transaction_units := l_curr_units;
         l_asset_dist_rec.assigned_to := l_to_employee_id(i);
         l_asset_dist_rec.expense_ccid := l_to_expense_ccid(i);
         l_asset_dist_rec.location_ccid := l_to_location_id(i);

         l_asset_dist_tbl(2) := l_asset_dist_rec;

         if (g_print_debug) then
            fa_debug_pkg.add('IAPTFR','tbl-1:dist_id',l_asset_dist_tbl(1).distribution_id);
            fa_debug_pkg.add('IAPTFR','tbl-1:txn_units',l_asset_dist_tbl(1).transaction_units);
            fa_debug_pkg.add('IAPTFR','tbl-1:assignto',l_asset_dist_tbl(1).assigned_to);
            fa_debug_pkg.add('IAPTFR','tbl-1:loc_id',l_asset_dist_tbl(1).location_ccid);
            fa_debug_pkg.add('IAPTFR','tbl-1:exp_id',l_asset_dist_tbl(1).expense_ccid);

            fa_debug_pkg.add('IAPTFR','tbl-2:dist_id',l_asset_dist_tbl(2).distribution_id);
            fa_debug_pkg.add('IAPTFR','tbl-2:txn_units',l_asset_dist_tbl(2).transaction_units);
            fa_debug_pkg.add('IAPTFR','tbl-2:assignto',l_asset_dist_tbl(2).assigned_to);
            fa_debug_pkg.add('IAPTFR','tbl-2:loc_id',l_asset_dist_tbl(2).location_ccid);
            fa_debug_pkg.add('IAPTFR','tbl-2:exp_id',l_asset_dist_tbl(2).expense_ccid);
         end if;

         -- Call Public Transfer API
         fa_transfer_pub.do_transfer(
                    p_api_version       => l_api_version,
                    p_init_msg_list     => l_init_msg_list,
                    p_commit            => l_commit,
                    p_validation_level  => l_validation_level,
                    p_calling_fn        => l_calling_fn,
                    x_return_status     => l_return_status,
                    x_msg_count         => l_msg_count,
                    x_msg_data          => l_msg_data,
                    px_trans_rec        => l_trans_rec,
                    px_asset_hdr_rec    => l_asset_hdr_rec,
                    px_asset_dist_tbl   => l_asset_dist_tbl);

          if (g_print_debug) then
                 fa_debug_pkg.add(l_calling_fn, 'Returned from Transfer API','');
          end if;

         if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            -- Mark batch as failed but continue despite errors
            ROLLBACK TO process_transfer;

            if (g_print_debug) then
                 fa_debug_pkg.add(l_calling_fn, 'Transfer API','returned error');
               --fa_debug_pkg.dump_debug_messages(max_mesgs => 0);
            end if;

            l_det_status(i) := 'ERROR';
--            l_head_status(i) := 'ERROR';
            l_failure_count := l_failure_count + 1;
            retcode := 2;
            fa_srvr_msg.add_message(
               calling_fn => NULL,
               name        => 'FA_TAXUP_ASSET_FAILURE',
               token1      => 'NUMBER',
               value1      => l_asset_number(i));
         else
            l_det_status(i) := 'POSTED';
--            l_head_status(i) := 'POSTED';
            l_success_count := l_success_count + 1;

            fa_srvr_msg.add_message(
               calling_fn => NULL,
               name        => 'FA_TAXUP_ASSET_SUCCESS',
               token1      => 'NUMBER',
               value1      => l_asset_number(i));
         end if;
         commit;
      end if;
   end loop;

   -- Update status
   begin
      for i in 1..l_request_detail_id.count loop

         if (prev_req_id = 0) then
             prev_req_id := l_request_id(i);
             prev_status := l_head_status(i);
         end if;

         update ia_request_details
         set    status = l_det_status(i)
         where  request_detail_id = l_request_detail_id(i);

         if (l_request_id(i) <> prev_req_id) then

            if (error_occured) then
               update ia_request_headers
               set status = 'COMPLETED_ERROR'
               where request_id = prev_req_id;

            elsif (prev_status = 'PARTIAL_POST') then
               null; -- remain the same

            else
               update ia_request_headers
               set status = 'COMPLETED'
               where request_id = prev_req_id;
            end if;

            prev_req_id := l_request_id(i);
            prev_status := l_head_status(i);
            error_occured := FALSE;
         end if;

         if (l_det_status(i) <> 'POSTED') then
             error_occured := TRUE;
         end if;
      end loop;

      if (prev_req_id <> 0) then

         if (error_occured) then
            update ia_request_headers
            set status = 'COMPLETED_ERROR'
            where request_id = prev_req_id;

         elsif (prev_status = 'PARTIAL_POST') then
               null; -- remain the same

         else
            update ia_request_headers
            set status = 'COMPLETED'
            where request_id = prev_req_id;
         end if;
      end if;
   end;

   commit;

   fa_srvr_msg.add_message(
                calling_fn => NULL,
                name       => 'FA_SHARED_NUMBER_SUCCESS',
                token1     => 'NUMBER',
                value1     => l_success_count);

   fa_srvr_msg.add_message(
                calling_fn => NULL,
                name       => 'FA_SHARED_NUMBER_FAIL',
                token1     => 'NUMBER',
                value1     => l_failure_count);

   if (l_failure_count > 0) then
     fa_srvr_msg.add_message(
                calling_fn => NULL,
                name       => 'FA_SHARED_END_WITH_ERROR',
                token1     => 'PROGRAM',
                value1     => 'IAPTFR');

     retcode := 2;

   else
      fa_srvr_msg.add_message(
                calling_fn => NULL,
                name       => 'FA_SHARED_END_SUCCESS',
                token1     => 'PROGRAM',
                value1     => 'IAPTFR');

      retcode := 0;
   end if;

   if (g_print_debug) then
      fa_debug_pkg.Write_Debug_Log;
   end if;

   FND_MSG_PUB.Count_And_Get(
                p_count         => h_msg_count,
                p_data          => h_msg_data);

   fa_srvr_msg.Write_Msg_Log(h_msg_count, h_msg_data);


EXCEPTION
    when masstfr_err then
      ROLLBACK;
      if (g_print_debug) then
         fa_debug_pkg.add(l_calling_fn,'Exception','masstfr_err');
         fa_debug_pkg.Write_Debug_Log;
      end if;

      fa_srvr_msg.add_message(calling_fn => l_calling_fn);
      FND_MSG_PUB.Count_And_Get(p_count => h_msg_count,
                                p_data  => h_msg_data);

      fa_srvr_msg.Write_Msg_Log(h_msg_count, h_msg_data);

      retcode :=  2;

   WHEN OTHERS THEN
      ROLLBACK TO process_transfer;

      if (g_print_debug) then
         fa_debug_pkg.add(l_calling_fn,'Exception','when others');
         fa_debug_pkg.Write_Debug_Log;
         --fa_debug_pkg.dump_debug_messages(max_mesgs => 0);
      end if;

      l_det_status(l_counter) := 'ERROR';
      l_failure_count := l_failure_count + 1;
      retcode := 2;

      fa_srvr_msg.add_sql_error(
         		calling_fn  => l_calling_fn);
      FND_MSG_PUB.Count_And_Get(p_count => h_msg_count,
                                p_data  => h_msg_data);

      fa_srvr_msg.Write_Msg_Log(h_msg_count, h_msg_data);

END post_transfer;

/*
FUNCTION get_current_units(p_asset_id IN NUMBER,
                           p_distribution_id IN NUMBER,
                           x_units OUT NOCOPY NUMBER
) RETURN BOOLEAN IS

l_curr_units number;
validate_err exception;
l_calling_fn varchar2(40) := 'IA_POST_REQUEST_PKG.get_current_units';

BEGIN
     select  units_assigned
     into    l_curr_units
     from    fa_distribution_history
     where   asset_id = p_asset_id
     and     distribution_id = p_distribution_id
     and     date_ineffective IS NULL;

     x_units := l_curr_units;

     return TRUE;

EXCEPTION
   WHEN OTHERS THEN
        fa_srvr_msg.add_sql_error(
              calling_fn  => l_calling_fn);

        return FALSE;
END get_current_units;
*/

FUNCTION validate_transfer (
     p_request_detail_id             IN     NUMBER,
     p_book_type_code                IN     VARCHAR2,
     p_asset_id                      IN     NUMBER,
     p_distribution_id_from          IN     NUMBER,
     p_calling_fn                    IN     VARCHAR2,
     x_units                     OUT NOCOPY NUMBER
) RETURN BOOLEAN IS

   l_curr_units number;
   validate_err   exception;
   l_calling_fn   varchar2(40) := 'IA_POST_REQUEST_PKG.validate_transfer';


BEGIN
   -- most of validation is done in transfer API
   -- will add as more validation is necessary

   -- check if valid asset/distribution
   -- and get current units as it's needed in calling procedure

     select  units_assigned
     into    l_curr_units
     from    fa_distribution_history
     where   asset_id = p_asset_id
     and     distribution_id = p_distribution_id_from
     and     date_ineffective IS NULL;

     x_units := l_curr_units;

     return TRUE;

EXCEPTION
   WHEN validate_err THEN
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn);
      return FALSE;
   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(
         calling_fn  => l_calling_fn);

      return FALSE;
END validate_transfer;

END IA_POST_REQUEST_PKG;

/
