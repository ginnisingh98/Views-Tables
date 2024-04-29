--------------------------------------------------------
--  DDL for Package Body FA_MASSPTFR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASSPTFR_PKG" AS
/* $Header: FAMPTFRB.pls 120.17.12010000.2 2009/07/19 14:37:29 glchen ship $   */

g_log_level_rec fa_api_types.log_level_rec_type;

--*********************** Private procedures *****************************--

FUNCTION validate_transfer (
     p_mass_external_transfer_id     IN     NUMBER,
     p_book_type_code                IN     VARCHAR2,
     p_batch_name                    IN     VARCHAR2,
     p_external_reference_num        IN     VARCHAR2,
     p_transaction_reference_num     IN     NUMBER,
     p_transaction_type              IN     VARCHAR2,
     p_from_asset_id                 IN     NUMBER,
     p_to_asset_id                   IN     NUMBER,
     p_transaction_status            IN     VARCHAR2,
     p_transaction_date_entered      IN     DATE,
     p_from_distribution_id          IN     NUMBER,
     p_from_location_id              IN     NUMBER,
     p_from_gl_ccid                  IN     NUMBER,
     p_from_employee_id              IN     NUMBER,
     p_to_distribution_id            IN     NUMBER,
     p_to_location_id                IN     NUMBER,
     p_to_gl_ccid                    IN     NUMBER,
     p_to_employee_id                IN     NUMBER,
     p_description                   IN     VARCHAR2,
     p_transfer_units                IN     NUMBER,
     p_transfer_amount               IN     NUMBER,
     p_source_line_id                IN     NUMBER,
     p_post_batch_id                 IN     NUMBER,
     p_calling_fn                    IN     VARCHAR2) RETURN BOOLEAN;

--*********************** Public procedures ******************************--
PROCEDURE do_mass_transfer (
     p_book_type_code                IN     VARCHAR2,
     p_batch_name                    IN     VARCHAR2,
     p_parent_request_id             IN     NUMBER,
     p_total_requests                IN     NUMBER,
     p_request_number                IN     NUMBER,
     p_calling_interface             IN     VARCHAR2,
     px_max_mass_ext_transfer_id     IN OUT NOCOPY NUMBER,
     x_success_count                    OUT NOCOPY NUMBER,
     x_failure_count                    OUT NOCOPY NUMBER,
     x_return_status                    OUT NOCOPY NUMBER) IS

   cursor tfr_lines is
      select tfr.mass_external_transfer_id,
             bc.set_of_books_id,
             tfr.book_type_code,
             tfr.batch_name,
             tfr.external_reference_num,
             tfr.transaction_reference_num,
             tfr.transaction_type,
             tfr.from_asset_id,
             tfr.to_asset_id,
             tfr.transaction_status,
             tfr.transaction_date_entered,
             tfr.from_distribution_id,
             tfr.from_location_id,
             tfr.from_gl_ccid,
             tfr.from_employee_id,
             tfr.to_distribution_id,
             tfr.to_location_id,
             tfr.to_gl_ccid,
             tfr.to_employee_id,
             tfr.description,
             tfr.transfer_units,
             tfr.transfer_amount,
             tfr.source_line_id,
             tfr.post_batch_id,
             tfr.attribute1,
             tfr.attribute2,
             tfr.attribute3,
             tfr.attribute4,
             tfr.attribute5,
             tfr.attribute6,
             tfr.attribute7,
             tfr.attribute8,
             tfr.attribute9,
             tfr.attribute10,
             tfr.attribute11,
             tfr.attribute12,
             tfr.attribute13,
             tfr.attribute14,
             tfr.attribute15,
             tfr.attribute_category_code
      from   fa_mass_external_transfers tfr,
             fa_book_controls bc
      where  tfr.book_type_code = p_book_type_code
      and    tfr.book_type_code = bc.book_type_code
      and    tfr.batch_name = p_batch_name
      and    tfr.transaction_status = 'POST'
      and    tfr.transaction_type in ('INTRA','TRANSFER')
      and    tfr.mass_external_transfer_id > px_max_mass_ext_transfer_id
      and    nvl(tfr.worker_id, 1) = p_request_number
      order by tfr.mass_external_transfer_id;

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
   l_calling_fn                   varchar2(100)
                                     := 'fa_massptfr_pkg.do_mass_transfer';
   -- Standard Who columns
   l_last_update_login            number(15) := fnd_global.login_id;
   l_created_by                   number(15) := fnd_global.user_id;
   l_creation_date                date       := sysdate;

   l_trans_rec                    fa_api_types.trans_rec_type;
   l_asset_hdr_rec                fa_api_types.asset_hdr_rec_type;
   l_asset_dist_rec               fa_api_types.asset_dist_rec_type;
   l_asset_dist_tbl               fa_api_types.asset_dist_tbl_type;

   -- Column types for bulk fetch
   l_mass_external_transfer_id    num_tbl_type;
   l_set_of_books_id              num_tbl_type;
   l_book_type_code               char_tbl_type;
   l_batch_name                   char_tbl_type;
   l_external_reference_num       char_tbl_type;
   l_transaction_reference_num    num_tbl_type;
   l_transaction_type             char_tbl_type;
   l_from_asset_id                num_tbl_type;
   l_to_asset_id                  num_tbl_type;
   l_transaction_status           char_tbl_type;
   l_transaction_date_entered     date_tbl_type;
   l_from_distribution_id         num_tbl_type;
   l_from_location_id             num_tbl_type;
   l_from_gl_ccid                 num_tbl_type;
   l_from_employee_id             num_tbl_type;
   l_to_distribution_id           num_tbl_type;
   l_to_location_id               num_tbl_type;
   l_to_gl_ccid                   num_tbl_type;
   l_to_employee_id               num_tbl_type;
   l_description                  char_tbl_type;
   l_transfer_units               num_tbl_type;
   l_transfer_amount              num_tbl_type;
   l_source_line_id               num_tbl_type;
   l_post_batch_id                num_tbl_type;
   l_attribute1                   char_tbl_type;
   l_attribute2                   char_tbl_type;
   l_attribute3                   char_tbl_type;
   l_attribute4                   char_tbl_type;
   l_attribute5                   char_tbl_type;
   l_attribute6                   char_tbl_type;
   l_attribute7                   char_tbl_type;
   l_attribute8                   char_tbl_type;
   l_attribute9                   char_tbl_type;
   l_attribute10                  char_tbl_type;
   l_attribute11                  char_tbl_type;
   l_attribute12                  char_tbl_type;
   l_attribute13                  char_tbl_type;
   l_attribute14                  char_tbl_type;
   l_attribute15                  char_tbl_type;
   l_attribute_category_code      char_tbl_type;

   transfer_err                   exception;

BEGIN

   -- Initialize variables
   px_max_mass_ext_transfer_id := nvl(px_max_mass_ext_transfer_id, 0);
   x_success_count := 0;
   x_failure_count := 0;
   x_return_status := 0;


   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise  transfer_err;
      end if;
   end if;

   -- Clear the debug stack for each asset
   fa_srvr_msg.init_server_message;
   fa_debug_pkg.initialize;

   -- Get Print Debug profile option.
   fnd_profile.get('PRINT_DEBUG', l_debug_flag);

   if (l_debug_flag = 'Y') then
       fa_debug_pkg.set_debug_flag;
   end if;

   -- load profiles for batch size
   if not fa_cache_pkg.fazprof then
      null;
   end if;

   l_batch_size := nvl(fa_cache_pkg.fa_batch_size, 200);

   if (px_max_mass_ext_transfer_id = 0) then
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'px_max_mass_ext_transfer_id',
            px_max_mass_ext_transfer_id, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'p_book', p_book_type_code, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'p_batch_name', p_batch_name, p_log_level_rec => g_log_level_rec);
      end if;

      FND_FILE.put(FND_FILE.output,'');
      FND_FILE.new_line(FND_FILE.output,1);
/*
      -- dump out the headings
      fnd_message.set_name('OFA', 'FA_POST_MASSRET_REPORT_COLUMN');
      l_string := fnd_message.get;

      FND_FILE.put(FND_FILE.output,l_string);
      FND_FILE.new_line(FND_FILE.output,1);
*/
      fnd_message.set_name('OFA', 'FA_POST_MASSRET_REPORT_LINE');
      l_string := fnd_message.get;
      FND_FILE.put(FND_FILE.output,l_string);
      FND_FILE.new_line(FND_FILE.output,1);

   end if;

   open tfr_lines;

   fetch tfr_lines bulk collect into
      l_mass_external_transfer_id,
      l_set_of_books_id,
      l_book_type_code,
      l_batch_name,
      l_external_reference_num,
      l_transaction_reference_num,
      l_transaction_type,
      l_from_asset_id,
      l_to_asset_id,
      l_transaction_status,
      l_transaction_date_entered,
      l_from_distribution_id,
      l_from_location_id,
      l_from_gl_ccid,
      l_from_employee_id,
      l_to_distribution_id,
      l_to_location_id,
      l_to_gl_ccid,
      l_to_employee_id,
      l_description,
      l_transfer_units,
      l_transfer_amount,
      l_source_line_id,
      l_post_batch_id,
      l_attribute1,
      l_attribute2,
      l_attribute3,
      l_attribute4,
      l_attribute5,
      l_attribute6,
      l_attribute7,
      l_attribute8,
      l_attribute9,
      l_attribute10,
      l_attribute11,
      l_attribute12,
      l_attribute13,
      l_attribute14,
      l_attribute15,
      l_attribute_category_code
   limit l_batch_size;

   close tfr_lines;

   -- Do transfer
   for i in 1..l_mass_external_transfer_id.count loop
      l_counter := i;

      SAVEPOINT process_transfer;

      -- Fix for Bug #3022144.  Distribution ID is not mandatory
      -- if the other fields are entered.
      if (l_from_distribution_id(i) is null) then
         begin
            select distinct distribution_id
            into   l_from_distribution_id(i)
            from   fa_distribution_history
            where  book_type_code = l_book_type_code(i)
            and    asset_id = l_from_asset_id(i)
            and    code_combination_id = l_from_gl_ccid(i)
            and    location_id = l_from_location_id(i)
            and    nvl(assigned_to, -999) = nvl(l_from_employee_id(i), -999)
            and    date_ineffective is null;
         exception
            when others then
               -- No error handling here because this error will
               -- be caught in the validate_transfer function
               -- with the CUA_INVALID_DISTRIBUTION_ID message.
               l_from_distribution_id(i) := -9999;
         end;
      end if;

      -- VALIDATIONS --
      if (not validate_transfer (
            p_mass_external_transfer_id => l_mass_external_transfer_id(i),
            p_book_type_code            => l_book_type_code(i),
            p_batch_name                => l_batch_name(i),
            p_external_reference_num    => l_external_reference_num(i),
            p_transaction_reference_num => l_transaction_reference_num(i),
            p_transaction_type          => l_transaction_type(i),
            p_from_asset_id             => l_from_asset_id(i),
            p_to_asset_id               => l_to_asset_id(i),
            p_transaction_status        => l_transaction_status(i),
            p_transaction_date_entered  => l_transaction_date_entered(i),
            p_from_distribution_id      => l_from_distribution_id(i),
            p_from_location_id          => l_from_location_id(i),
            p_from_gl_ccid              => l_from_gl_ccid(i),
            p_from_employee_id          => l_from_employee_id(i),
            p_to_distribution_id        => l_to_distribution_id(i),
            p_to_location_id            => l_to_location_id(i),
            p_to_gl_ccid                => l_to_gl_ccid(i),
            p_to_employee_id            => l_to_employee_id(i),
            p_description               => l_description(i),
            p_transfer_units            => l_transfer_units(i),
            p_transfer_amount           => l_transfer_amount(i),
            p_source_line_id            => l_source_line_id(i),
            p_post_batch_id             => l_post_batch_id(i),
            p_calling_fn                => l_calling_fn
      )) then
         -- Mark batch as failed but continue despite errors
         ROLLBACK TO process_transfer;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
         end if;

         l_transaction_status(i) := 'ERROR';
         x_failure_count := x_failure_count + 1;
         x_return_status := 1;

         fa_srvr_msg.add_message(
            calling_fn  => l_calling_fn,
            application => 'CUA',
            name        => 'CUA_TRF_FAILED',
            token1      => 'Mass_External_Transfer_ID',
            value1      => l_mass_external_transfer_id(i),
            p_log_level_rec => g_log_level_rec);

      else
         -- LOAD STRUCTS --
         -- ***** Asset Transaction Info ***** --
         --l_trans_rec.transaction_header_id :=
         --l_trans_rec.transaction_type_code :=
         l_trans_rec.transaction_date_entered := l_transaction_date_entered(i);
         --*** l_trans_rec.transaction_name := p_transaction_name;
         --l_trans_rec.source_transaction_header_id :=
         l_trans_rec.mass_reference_id := p_parent_request_id;
         l_trans_rec.mass_transaction_id := l_mass_external_transfer_id(i);
         --l_trans_rec.transaction_subtype :=
         --l_trans_rec.transaction_key :=
         --l_trans_rec.amortization_start_date :=
         l_trans_rec.calling_interface := p_calling_interface;
         l_trans_rec.desc_flex.attribute1 := l_attribute1(i);
         l_trans_rec.desc_flex.attribute2 := l_attribute2(i);
         l_trans_rec.desc_flex.attribute3 := l_attribute3(i);
         l_trans_rec.desc_flex.attribute4 := l_attribute4(i);
         l_trans_rec.desc_flex.attribute5 := l_attribute5(i);
         l_trans_rec.desc_flex.attribute6 := l_attribute6(i);
         l_trans_rec.desc_flex.attribute7 := l_attribute7(i);
         l_trans_rec.desc_flex.attribute8 := l_attribute8(i);
         l_trans_rec.desc_flex.attribute9 := l_attribute9(i);
         l_trans_rec.desc_flex.attribute10 := l_attribute10(i);
         l_trans_rec.desc_flex.attribute11 := l_attribute11(i);
         l_trans_rec.desc_flex.attribute12 := l_attribute12(i);
         l_trans_rec.desc_flex.attribute13 := l_attribute13(i);
         l_trans_rec.desc_flex.attribute14 := l_attribute14(i);
         l_trans_rec.desc_flex.attribute15 := l_attribute15(i);
         l_trans_rec.desc_flex.attribute_category_code :=
            l_attribute_category_code(i);
         l_trans_rec.who_info.last_update_date := l_creation_date;
         l_trans_rec.who_info.last_updated_by := l_created_by;
         l_trans_rec.who_info.created_by := l_created_by;
         l_trans_rec.who_info.creation_date := l_creation_date;
         l_trans_rec.who_info.last_update_login := l_last_update_login;

         -- BUG# 4422829
--         l_trans_rec.transaction_name := l_description(i);
         -- bug# 8213984
         l_trans_rec.transaction_name := substr(l_description(i),1,30);

         -- ***** Asset Header Info ***** --
         l_asset_hdr_rec.asset_id        := l_from_asset_id(i);
         l_asset_hdr_rec.book_type_code  := l_book_type_code(i);
         l_asset_hdr_rec.set_of_books_id := l_set_of_books_id(i);
         --l_asset_hdr_rec.period_of_addition :=

         -- ***** Asset Distribution Info ***** --
         l_asset_dist_tbl.delete;

         l_asset_dist_rec.distribution_id := l_from_distribution_id(i);
         --l_asset_dist_rec.units_assigned :=
         l_asset_dist_rec.transaction_units := -1 * l_transfer_units(i);
         l_asset_dist_rec.assigned_to := l_from_employee_id(i);
         l_asset_dist_rec.expense_ccid := l_from_gl_ccid(i);
         l_asset_dist_rec.location_ccid := l_from_location_id(i);

         l_asset_dist_tbl(1) := l_asset_dist_rec;

         l_asset_dist_rec.distribution_id := NULL;
         --l_asset_dist_rec.units_assigned :=
         l_asset_dist_rec.transaction_units := l_transfer_units(i);
         l_asset_dist_rec.assigned_to := l_to_employee_id(i);
         l_asset_dist_rec.expense_ccid := l_to_gl_ccid(i);
         l_asset_dist_rec.location_ccid := l_to_location_id(i);

         l_asset_dist_tbl(2) := l_asset_dist_rec;

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

         if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            -- Mark batch as failed but continue despite errors
            ROLLBACK TO process_transfer;

            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
            end if;

            l_transaction_status(i) := 'ERROR';
            x_failure_count := x_failure_count + 1;
            x_return_status := 1;

            fa_srvr_msg.add_message(
               calling_fn  => l_calling_fn,
               application => 'CUA',
               name        => 'CUA_TRF_FAILED',
               token1      => 'Mass_External_Transfer_ID',
               value1      => l_mass_external_transfer_id(i),
               p_log_level_rec => g_log_level_rec);
         else
            l_transaction_status(i) := 'POSTED';
            x_success_count := x_success_count + 1;

            fa_srvr_msg.add_message(
               calling_fn  => l_calling_fn,
               application => 'CUA',
               name        => 'CUA_TRF_SUCCESS',
               token1      => 'Mass_External_Transfer_ID',
               value1      => l_mass_external_transfer_id(i),
               p_log_level_rec => g_log_level_rec);
         end if;
      end if;
   end loop;

   -- Update status
   begin
      forall i in 1..l_mass_external_transfer_id.count
         update fa_mass_external_transfers
         set    transaction_status = l_transaction_status(i)
         where  mass_external_transfer_id = l_mass_external_transfer_id(i);
   end;

   FND_CONCURRENT.AF_COMMIT;

   if (l_mass_external_transfer_id.count = 0) then
      -- Exit worker
      return;
   else
      -- Set the max id only if rows were fetched
      px_max_mass_ext_transfer_id :=
        l_mass_external_transfer_id(l_mass_external_transfer_id.count);
   end if;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'px_max_mass_ext_transfer_id',
         px_max_mass_ext_transfer_id, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'End of Mass External Transfers session',
         x_return_status, p_log_level_rec => g_log_level_rec);
   end if;

EXCEPTION
   WHEN TRANSFER_ERR THEN
      ROLLBACK TO process_transfer;
      x_return_status := 2;

   WHEN OTHERS THEN

      fa_srvr_msg.add_sql_error(
              calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      ROLLBACK TO process_transfer;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;

      l_transaction_status(l_counter) := 'ERROR';
      x_failure_count := x_failure_count + 1;
      x_return_status := 2;

      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         application => 'CUA',
         name        => 'CUA_TRF_FAILED',
         token1      => 'Mass_External_Transfer_ID',
         value1      => l_mass_external_transfer_id(l_counter),
         p_log_level_rec => g_log_level_rec);

      -- Update status
      begin
         forall i in 1..l_counter
         update fa_mass_external_transfers
         set    transaction_status = l_transaction_status(i)
         where  mass_external_transfer_id = l_mass_external_transfer_id(i);
      end;

      FND_CONCURRENT.AF_COMMIT;

      if (l_counter <> 0) then
         -- Set the max id only if rows were fetched
         px_max_mass_ext_transfer_id :=
           l_mass_external_transfer_id(l_counter);
      end if;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'px_max_mass_ext_transfer_id',
            px_max_mass_ext_transfer_id, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'End of Mass External Transfers session',
            x_return_status, p_log_level_rec => g_log_level_rec);
      end if;

END do_mass_transfer;

PROCEDURE allocate_workers (
     p_book_type_code                IN     VARCHAR2,
     p_batch_name                    IN     VARCHAR2,
     p_total_requests                IN     NUMBER,
     x_return_status                    OUT NOCOPY NUMBER) IS

   cursor tfr_lines is
      select tfr.mass_external_transfer_id,
             tfr.book_type_code,
             tfr.batch_name,
             tfr.from_group_asset_id,
             tfr.from_asset_id,
             tfr.to_asset_id,
             tfr.transaction_status,
             tfr.transaction_date_entered,
             tfr.from_distribution_id,
             tfr.from_location_id,
             tfr.from_gl_ccid,
             tfr.from_employee_id,
             tfr.to_distribution_id,
             tfr.to_location_id,
             tfr.to_gl_ccid,
             tfr.to_employee_id,
             tfr.source_line_id,
             tfr.worker_id
      from   fa_mass_external_transfers tfr
      where  tfr.book_type_code = p_book_type_code
      and    tfr.batch_name = p_batch_name
      and    tfr.transaction_status = 'POST'
      and    tfr.transaction_type in ('INTRA', 'TRANSFER')
      and    tfr.worker_id is null;

   l_min_asset_id                 number(15);
   l_max_asset_id                 number(15);
   l_min_group_asset_id           number(15);
   l_max_group_asset_id           number(15);

   -- Used for bulk fetching
   l_batch_size                   number;

   -- Types for table variable
   type num_tbl_type  is table of number        index by binary_integer;
   type char_tbl_type is table of varchar2(200) index by binary_integer;
   type date_tbl_type is table of date          index by binary_integer;

   -- Column types for bulk fetch
   l_mass_external_transfer_id    num_tbl_type;
   l_set_of_books_id              num_tbl_type;
   l_book_type_code               char_tbl_type;
   l_batch_name                   char_tbl_type;
   l_from_group_asset_id          num_tbl_type;
   l_from_asset_id                num_tbl_type;
   l_to_asset_id                  num_tbl_type;
   l_transaction_status           char_tbl_type;
   l_transaction_date_entered     date_tbl_type;
   l_from_distribution_id         num_tbl_type;
   l_from_location_id             num_tbl_type;
   l_from_gl_ccid                 num_tbl_type;
   l_from_employee_id             num_tbl_type;
   l_to_distribution_id           num_tbl_type;
   l_to_location_id               num_tbl_type;
   l_to_gl_ccid                   num_tbl_type;
   l_to_employee_id               num_tbl_type;
   l_source_line_id               num_tbl_type;
   l_worker_id                    num_tbl_type;

   allocation_err                 exception;

BEGIN

   x_return_status := 0;

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise allocation_err;
      end if;
   end if;

   -- If not run in parallel, don't need to do this logic.
   if (nvl(p_total_requests, 1) = 1) then
      return;
   end if;

   if not fa_cache_pkg.fazprof then
      null;
   end if;

   l_batch_size := nvl(fa_cache_pkg.fa_batch_size, 200);

   -- Allocate each external transfer line to a worker_id.
   open tfr_lines;
   loop

      SAVEPOINT allocate_process;

      fetch tfr_lines bulk collect into
         l_mass_external_transfer_id,
         l_book_type_code,
         l_batch_name,
         l_from_group_asset_id,
         l_from_asset_id,
         l_to_asset_id,
         l_transaction_status,
         l_transaction_date_entered,
         l_from_distribution_id,
         l_from_location_id,
         l_from_gl_ccid,
         l_from_employee_id,
         l_to_distribution_id,
         l_to_location_id,
         l_to_gl_ccid,
         l_to_employee_id,
         l_source_line_id,
         l_worker_id
      limit l_batch_size;

      -- Allocate worker logic
      for i in 1..l_mass_external_transfer_id.count loop

         -- Not using striping but dividing by 1000 to avoid block contention
         -- for multiple workers.
         l_worker_id(i) := (floor(l_from_asset_id(i) / 1000) mod
                            p_total_requests) + 1;

         -- Need this to take care of min values and etc.
         if ((l_worker_id(i) is null) or (l_worker_id(i) < 1) or
             (l_worker_id(i) > p_total_requests)) then
            l_worker_id(i) := 1;
         end if;

      end loop;

      -- Update table
      forall i IN 1..l_mass_external_transfer_id.count
         update fa_mass_external_transfers
         set    worker_id = l_worker_id(i)
         where  mass_external_transfer_id = l_mass_external_transfer_id(i);

      FND_CONCURRENT.AF_COMMIT;

      exit when tfr_lines%NOTFOUND;

   end loop;
   close tfr_lines;

EXCEPTION
   WHEN ALLOCATION_ERR THEN
      ROLLBACK TO allocate_process;

      x_return_status := 2;

   WHEN OTHERS THEN
      ROLLBACK TO allocate_process;

      x_return_status := 2;
END allocate_workers;

FUNCTION validate_transfer (
     p_mass_external_transfer_id     IN     NUMBER,
     p_book_type_code                IN     VARCHAR2,
     p_batch_name                    IN     VARCHAR2,
     p_external_reference_num        IN     VARCHAR2,
     p_transaction_reference_num     IN     NUMBER,
     p_transaction_type              IN     VARCHAR2,
     p_from_asset_id                 IN     NUMBER,
     p_to_asset_id                   IN     NUMBER,
     p_transaction_status            IN     VARCHAR2,
     p_transaction_date_entered      IN     DATE,
     p_from_distribution_id          IN     NUMBER,
     p_from_location_id              IN     NUMBER,
     p_from_gl_ccid                  IN     NUMBER,
     p_from_employee_id              IN     NUMBER,
     p_to_distribution_id            IN     NUMBER,
     p_to_location_id                IN     NUMBER,
     p_to_gl_ccid                    IN     NUMBER,
     p_to_employee_id                IN     NUMBER,
     p_description                   IN     VARCHAR2,
     p_transfer_units                IN     NUMBER,
     p_transfer_amount               IN     NUMBER,
     p_source_line_id                IN     NUMBER,
     p_post_batch_id                 IN     NUMBER,
     p_calling_fn                    IN     VARCHAR2) RETURN BOOLEAN IS

   validate_err                  exception;

   l_calling_fn                  varchar2(40)
                                    := 'fa_massptfr_pkg.validate_transfer';

   l_from_asset_id               number(15);
   l_book_type_code              varchar2(30);
   l_from_date_ineffective       date;
   l_from_units_assigned         number;
   l_from_gl_ccid                number(15);
   l_from_location_id            number(15);
   l_from_employee_id            number(15);
   l_to_gl_ccid_exists           number;
   l_to_location_id_exists       number;
   l_to_employee_id_exists       number;
   l_check_prior_period          number;
   l_check_retired               number := 0;
   l_check_pending_batch         number := 0;
   l_txn_status                  boolean := FALSE;

   cursor  ck_asset_retired is
   select  nvl(b.period_counter_fully_retired,0)
   from    fa_books b
   where   b.asset_id = p_from_asset_id
   and     b.date_ineffective is null
   and     b.book_type_code = p_book_type_code;

   cursor  ck_check_batch_for_transfers is
   select 1
   from dual
   where exists
   ( select 'x'
     from fa_mass_update_batch_headers a
     where a.status_code IN ('P', 'E', 'R', 'N', 'IP')
     and a.book_type_code = p_book_type_code
     and (a.event_code IN ('CHANGE_NODE_PARENT', 'CHANGE_NODE_ATTRIBUTE',
                           'CHANGE_NODE_RULE_SET', 'CHANGE_CATEGORY_RULE_SET',
                           'HR_MASS_TRANSFER', 'CHANGE_CATEGORY_LIFE',
                           'CHANGE_CATEGORY_LIFE_END_DATE') or
            (a.event_code IN ('CHANGE_ASSET_PARENT','CHANGE_ASSET_LEASE',
                              'CHANGE_ASSET_CATEGORY') and
             to_number(a.source_entity_key_value) = p_from_asset_id)
            )
   );

BEGIN

   -- Check for nulls
   if (p_from_asset_id is null) then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         application => 'CUA',
         name        => 'CUA_NULL_FROM ASSET_ID',
         token1      => 'FROM_ASSET_ID',
         value1      => p_mass_external_transfer_id, p_log_level_rec => g_log_level_rec);
      raise validate_err;
   end if;

   if (p_book_type_code is null) then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         application => 'CUA',
         name        => 'CUA_NULL_BOOK',
         token1      => 'BOOK',
         value1      => p_mass_external_transfer_id, p_log_level_rec => g_log_level_rec);
      raise validate_err;
   end if;

   if (p_from_distribution_id is null) then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         application => 'CUA',
         name        => 'CUA_NULL_DISTRIBUTION_ID',
         token1      => 'DISTRIBUTION_ID',
         value1      => p_mass_external_transfer_id, p_log_level_rec => g_log_level_rec);
      raise validate_err;
   end if;

   if (p_to_location_id is null) then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         application => 'CUA',
         name        => 'CUA_NULL_LOCATION_ID',
         token1      => 'LOCATION_ID',
         value1      => p_mass_external_transfer_id, p_log_level_rec => g_log_level_rec);
      raise validate_err;
   end if;

   if (p_to_gl_ccid is null) then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         application => 'CUA',
         name        => 'CUA_NULL_GL_CCID',
         token1      => 'GL_CCID',
         value1      => p_mass_external_transfer_id, p_log_level_rec => g_log_level_rec);
      raise validate_err;
   end if;

   if (p_transfer_units is null) then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         application => 'CUA',
         name        => 'CUA_NULL_TRANSFER_UNITS',
         token1      => 'TRANSFER_UNITS',
         value1      => p_mass_external_transfer_id, p_log_level_rec => g_log_level_rec);
      raise validate_err;
   end if;

   -- Zero Or Less Transfer Units
   if (p_transfer_units <= 0) then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         application => 'CUA',
         name        => 'CUA_ZERO_TRANSFER_UNITS',
         token1      => 'TRANSFER_UNITS',
         value1      => p_mass_external_transfer_id, p_log_level_rec => g_log_level_rec);
      raise validate_err;
   end if;

   -- The Distribution Id is Invalid
   begin
      select asset_id,
             book_type_code,
             date_ineffective,
             units_assigned,
             code_combination_id,
             location_id,
             assigned_to
      into   l_from_asset_id,
             l_book_type_code,
             l_from_date_ineffective,
             l_from_units_assigned,
             l_from_gl_ccid,
             l_from_location_id,
             l_from_employee_id
      from   fa_distribution_history
      where  distribution_id = p_from_distribution_id;

   exception
      when no_data_found then
         fa_srvr_msg.add_message(
            calling_fn  => l_calling_fn,
            application => 'CUA',
            name        => 'CUA_INVALID_DISTRIBUTION_ID',
            token1      => 'DISTRIBUTION_ID',
            value1      => p_mass_external_transfer_id, p_log_level_rec => g_log_level_rec);
         raise validate_err;
   end ;

   -- Transfer Units Greater than units assigned
   if (p_transfer_units > l_from_units_assigned) then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         application => 'CUA',
         name        => 'CUA_GREATER_TRANSFER_UNITS',
         token1      => 'TRANSFER_UNITS',
         value1      => p_mass_external_transfer_id, p_log_level_rec => g_log_level_rec);
      raise validate_err;
   end if;

   -- The From Asset Id Is Invalid
   if (p_from_asset_id <> l_from_asset_id) then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         application => 'CUA',
         name        => 'CUA_INVALID_FROM_ASSET_ID',
         token1      => 'FROM_ASSET_ID',
         value1      => p_mass_external_transfer_id, p_log_level_rec => g_log_level_rec);
      raise validate_err;
   end if;

   -- Book Type Code Is Invalid
   if (p_book_type_code <> l_book_type_code) then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         application => 'CUA',
         name        => 'CUA_INVALID_BOOK',
         token1      => 'BOOK',
         value1      => p_mass_external_transfer_id, p_log_level_rec => g_log_level_rec);
      raise validate_err;
   end if;

   -- Distribution Id Is Invalid / terminated distribution
   if (l_from_date_ineffective is not null) then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         application => 'CUA',
         name        => 'CUA_INVALID_DISTRIBUTION_ID',
         token1      => 'DISTRIBUTION_ID',
         value1      => p_mass_external_transfer_id, p_log_level_rec => g_log_level_rec);
      raise validate_err;
   end if;

   -- GL_CCID Is Invalid
   select count(*)
   into   l_to_gl_ccid_exists
   from   gl_code_combinations
   where  code_combination_id = p_to_gl_ccid
   and    enabled_flag = 'Y'
   and    nvl(start_date_active, sysdate) <= sysdate
   and    nvl(end_date_active, sysdate + 1) > sysdate ;

   if (l_to_gl_ccid_exists = 0) then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         application => 'CUA',
         name        => 'CUA_INVALID_GL_CCID',
         token1      => 'GL_CCID',
         value1      => p_mass_external_transfer_id, p_log_level_rec => g_log_level_rec);
      raise validate_err;
   end if;

   -- Location Id Is Invalid
   select count(*)
   into   l_to_location_id_exists
   from   fa_locations
   where  location_id = p_to_location_id
   and    enabled_flag = 'Y'
   and    nvl(start_date_active, sysdate) <= sysdate
   and    nvl(end_date_active, sysdate + 1) > sysdate ;

   if (l_to_location_id_exists = 0) then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         application => 'CUA',
         name        => 'CUA_INVALID_LOCATION_ID',
         token1      => 'LOCATION_ID',
         value1      => p_mass_external_transfer_id, p_log_level_rec => g_log_level_rec);
      raise validate_err;
   end if;

   -- Employee Id Is Invalid
   if (p_to_employee_id is not null) then

      select count(*)
      into   l_to_employee_id_exists
      from   per_periods_of_service s,
             per_people_f p
      where  p.person_id = p_to_employee_id
      and    p.person_id = s.person_id
      and    trunc(sysdate) between p.effective_start_date
      and    p.effective_end_date
      and    nvl(s.actual_termination_date,sysdate) >= sysdate; -- Bug 7573372

      if (l_to_employee_id_exists = 0) then
         fa_srvr_msg.add_message(
            calling_fn  => l_calling_fn,
            application => 'CUA',
            name        => 'CUA_INVALID_EMPLOYEE_ID',
            token1      => 'EMPLOYEE_ID',
            value1      => p_mass_external_transfer_id, p_log_level_rec => g_log_level_rec);
         raise validate_err;
      end if;
   end if;

   -- From and To Distribution Lines Identical
   if ((l_from_gl_ccid      =  p_to_gl_ccid)     and
       (l_from_location_id  =  p_to_location_id) and
       (nvl(l_from_employee_id, -999) = nvl(p_to_employee_id, -999))) then

      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         application => 'CUA',
         name        => 'CUA_IDENTICAL_DISTRIBUTION',
         token1      => 'DISTRIBUTION',
         value1      => p_mass_external_transfer_id, p_log_level_rec => g_log_level_rec);
      raise validate_err;
   end if;

   -- Invalid From Asset Id
   open  ck_asset_retired;
   fetch ck_asset_retired into l_check_retired;
   if (ck_asset_retired%notfound) then
      close ck_asset_retired;

      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         application => 'CUA',
         name        => 'CUA_INVALID_FROM_ASSET_ID',
         token1      => 'FROM_ASSET_ID',
         value1      => p_mass_external_transfer_id, p_log_level_rec => g_log_level_rec);
      raise validate_err;
   end if;
   close ck_asset_retired;

   -- From Asset is fully retired
   if (l_check_retired > 0) then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         application => 'CUA',
         name        => 'CUA_RETIRED_ASSET',
         token1      => 'ASSET',
         value1      => p_mass_external_transfer_id, p_log_level_rec => g_log_level_rec);
      raise validate_err;
   end if;

   -- Check that only one prior period transfer is allowed
   select count(*)
   into   l_check_prior_period
   from   fa_transaction_headers th,
          fa_deprn_periods fadp
   where  th.asset_id = p_from_asset_id
   and    th.book_type_Code = p_book_type_code
   and    th.transaction_type_code = 'TRANSFER'
   and    th.transaction_date_entered < fadp.calendar_period_open_date
   and    th.date_effective > fadp.period_open_date
   and    p_transaction_date_entered < fadp.calendar_period_open_date
   and    fadp.book_type_Code = p_book_type_code
   and    fadp.period_close_date is null;

   if (l_check_prior_period <> 0) then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         application => 'CUA',
         name        => 'CUA_ONE_PRIOR_PERIOD_TRX',
         token1      => 'TRANSACTION_DATE',
         value1      => p_mass_external_transfer_id, p_log_level_rec => g_log_level_rec);
      raise validate_err;
   end if;

   -- Check if book in use
   -- BUG# 3035601 - removed call to faxcbs as faxbmt is called
   -- from pro*c wrapper

   -- Check pending batch
   open ck_check_batch_for_transfers;
   fetch ck_check_batch_for_transfers into l_check_pending_batch;
   close ck_check_batch_for_transfers;
   if(l_check_pending_batch = 1) then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         application => 'CUA',
         name        => 'CUA_PENDING_BATCH',
         token1      => 'BOOK',
         value1      => p_mass_external_transfer_id, p_log_level_rec => g_log_level_rec);
      raise validate_err;
   end if;

   return TRUE;

EXCEPTION
   WHEN validate_err THEN
      return FALSE;
   WHEN OTHERS THEN
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         application => 'CUA',
         name        => 'CUA_INVALID_DATA',
         token1      => 'INVALID_DATA',
         value1      => p_mass_external_transfer_id, p_log_level_rec => g_log_level_rec);

      return FALSE;
END validate_transfer;

END FA_MASSPTFR_PKG;

/
