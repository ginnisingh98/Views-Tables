--------------------------------------------------------
--  DDL for Package Body FA_MASSPSLTFR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASSPSLTFR_PKG" AS
/* $Header: FAMPSLTFRB.pls 120.21.12010000.2 2009/07/19 14:36:31 glchen ship $   */

g_log_level_rec fa_api_types.log_level_rec_type;

--************************* Private types ********************************--
-- Types for table variable
TYPE num_tbl_type  is table of number        index by binary_integer;
TYPE char_tbl_type is table of varchar2(200) index by binary_integer;
TYPE date_tbl_type is table of date          index by binary_integer;

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

PROCEDURE add_dependencies (
     px_dep_group_asset_id           IN OUT NOCOPY NUM_TBL_TYPE,
     px_dep_asset_id                 IN OUT NOCOPY NUM_TBL_TYPE,
     p_sub_group_asset_id            IN     NUM_TBL_TYPE,
     p_sub_asset_id                  IN     NUM_TBL_TYPE,
     px_new_group_total              IN OUT NOCOPY NUMBER,
     px_new_asset_total              IN OUT NOCOPY NUMBER);

--*********************** Public procedures ******************************--
PROCEDURE do_mass_sl_transfer (
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
      and    tfr.transaction_type in ('INTER', 'ADJUSTMENT')
      and    tfr.mass_external_transfer_id > px_max_mass_ext_transfer_id
      and    nvl(tfr.worker_id, 1) = p_request_number
      order by tfr.mass_external_transfer_id;

   CURSOR source_lines (p_src_line_id number) IS
   select b.source_line_id
     from fa_asset_invoices b
    where b.source_line_id in (
          select a.source_line_id
            from fa_asset_invoices a
           start with a.source_Line_id = p_src_line_id
         connect by prior a.source_line_id = a.prior_source_line_id
                and prior a.asset_id = a.asset_id)
     and b.date_ineffective is null;



   -- Used for bulk fetching
   l_batch_size                   number;
   l_counter                      number;

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
                                     := 'fa_masspsltfr_pkg.do_mass_sl_transfer';
   -- Standard Who columns
   l_last_update_login            number(15) := fnd_global.login_id;
   l_created_by                   number(15) := fnd_global.user_id;
   l_creation_date                date       := sysdate;

   l_src_trans_rec                fa_api_types.trans_rec_type;
   l_src_asset_hdr_rec            fa_api_types.asset_hdr_rec_type;
   l_dest_trans_rec               fa_api_types.trans_rec_type;
   l_dest_asset_hdr_rec           fa_api_types.asset_hdr_rec_type;
   l_inv_rec                      fa_api_types.inv_rec_type;
   l_inv_tbl                      fa_api_types.inv_tbl_type;

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

   l_derived_source_line_id       number;
   error_found                    exception;

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
         raise error_found;
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

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('FAMPSLTFRB.pls',
            'FND_FILE init: BOOK ', P_BOOK_TYPE_CODE, p_log_level_rec => g_log_level_rec);
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

      BEGIN -- line level block

         OPEN source_lines (l_source_line_id(i));
         FETCH source_lines into l_derived_source_line_id;
         if source_lines%NOTFOUND then
            CLOSE source_lines;
            fa_srvr_msg.add_message(
               calling_fn  => l_calling_fn,
               application => 'CUA',
               name        => 'CUA_INVALID_SOURCE_LINE_ID', p_log_level_rec => g_log_level_rec);
            raise error_found;
         end if;
         CLOSE source_lines;

         l_source_line_id(i) := l_derived_source_line_id;

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
            raise error_found;
         else
            -- no need to load source line rec here

            -- LOAD STRUCTS --
            -- ***** Source Asset Transaction Info ***** --
            --l_src_trans_rec.transaction_header_id :=
            --l_src_trans_rec.transaction_type_code :=
            l_src_trans_rec.transaction_date_entered :=
               l_transaction_date_entered(i);
            --l_src_trans_rec.transaction_name :=
            --l_src_trans_rec.source_transaction_header_id :=
            l_src_trans_rec.mass_reference_id := p_parent_request_id;
            l_src_trans_rec.mass_transaction_id := l_mass_external_transfer_id(i);
            --l_src_trans_rec.transaction_subtype :=
            --l_src_trans_rec.transaction_key :=
            --l_src_trans_rec.amortization_start_date :=
            l_src_trans_rec.calling_interface := p_calling_interface;
            --l_src_trans_rec.desc_flex.attribute1 :=
            --l_src_trans_rec.desc_flex.attribute2 :=
            --l_src_trans_rec.desc_flex.attribute3 :=
            --l_src_trans_rec.desc_flex.attribute4 :=
            --l_src_trans_rec.desc_flex.attribute5 :=
            --l_src_trans_rec.desc_flex.attribute6 :=
            --l_src_trans_rec.desc_flex.attribute7 :=
            --l_src_trans_rec.desc_flex.attribute8 :=
            --l_src_trans_rec.desc_flex.attribute9 :=
            --l_src_trans_rec.desc_flex.attribute10 :=
            --l_src_trans_rec.desc_flex.attribute11 :=
            --l_src_trans_rec.desc_flex.attribute11 :=
            --l_src_trans_rec.desc_flex.attribute12 :=
            --l_src_trans_rec.desc_flex.attribute13 :=
            --l_src_trans_rec.desc_flex.attribute14 :=
            --l_src_trans_rec.desc_flex.attribute15 :=
            --l_src_trans_rec.desc_flex.attribute_category_code :=
            l_src_trans_rec.who_info.last_update_date := l_creation_date;
            l_src_trans_rec.who_info.last_updated_by := l_created_by;
            l_src_trans_rec.who_info.created_by := l_created_by;
            l_src_trans_rec.who_info.creation_date := l_creation_date;
            l_src_trans_rec.who_info.last_update_login := l_last_update_login;

            -- ***** Source Asset Header Info ***** --
            l_src_asset_hdr_rec.asset_id := l_from_asset_id(i);
            l_src_asset_hdr_rec.book_type_code := l_book_type_code(i);
            l_src_asset_hdr_rec.set_of_books_id := l_set_of_books_id(i);
            --l_src_asset_hdr_rec.period_of_addition :=

            -- ***** Destination Asset Transaction Info ***** --
            --l_dest_trans_rec.transaction_header_id :=
            --l_dest_trans_rec.transaction_type_code :=
            l_dest_trans_rec.transaction_date_entered :=
               l_transaction_date_entered(i);
            --l_dest_trans_rec.transaction_name :=
            --l_dest_trans_rec.source_transaction_header_id :=
            l_dest_trans_rec.mass_reference_id := p_parent_request_id;
            l_dest_trans_rec.mass_transaction_id := l_mass_external_transfer_id(i);
            --l_dest_trans_rec.transaction_subtype :=
            --l_dest_trans_rec.transaction_key :=
            --l_dest_trans_rec.amortization_start_date :=
            l_dest_trans_rec.calling_interface := p_calling_interface;
            --l_dest_trans_rec.desc_flex.attribute1 :=
            --l_dest_trans_rec.desc_flex.attribute2 :=
            --l_dest_trans_rec.desc_flex.attribute3 :=
            --l_dest_trans_rec.desc_flex.attribute4 :=
            --l_dest_trans_rec.desc_flex.attribute5 :=
            --l_dest_trans_rec.desc_flex.attribute6 :=
            --l_dest_trans_rec.desc_flex.attribute7 :=
            --l_dest_trans_rec.desc_flex.attribute8 :=
            --l_dest_trans_rec.desc_flex.attribute9 :=
            --l_dest_trans_rec.desc_flex.attribute10 :=
            --l_dest_trans_rec.desc_flex.attribute11 :=
            --l_dest_trans_rec.desc_flex.attribute11 :=
            --l_dest_trans_rec.desc_flex.attribute12 :=
            --l_dest_trans_rec.desc_flex.attribute13 :=
            --l_dest_trans_rec.desc_flex.attribute14 :=
            --l_dest_trans_rec.desc_flex.attribute15 :=
            --l_dest_trans_rec.desc_flex.attribute_category_code :=
            l_dest_trans_rec.who_info.last_update_date := l_creation_date;
            l_dest_trans_rec.who_info.last_updated_by := l_created_by;
            l_dest_trans_rec.who_info.created_by := l_created_by;
            l_dest_trans_rec.who_info.creation_date := l_creation_date;
            l_dest_trans_rec.who_info.last_update_login := l_last_update_login;

            -- ***** Destination Asset Header Info ***** --
            l_dest_asset_hdr_rec.asset_id := l_to_asset_id(i);
            l_dest_asset_hdr_rec.book_type_code := l_book_type_code(i);
            l_dest_asset_hdr_rec.set_of_books_id := l_set_of_books_id(i);
            --l_dest_asset_hdr_rec.period_of_addition :=

            -- ***** Invoice Info ***** --
            l_inv_tbl.delete;

            l_inv_rec.fixed_assets_cost := 0 - l_transfer_amount(i);
            l_inv_rec.source_line_id := l_source_line_id(i);

            l_inv_tbl(1) := l_inv_rec;

            -- Call the Public Invoice Transfer API
            fa_inv_xfr_pub.do_transfer
               (p_api_version         => l_api_version,
                p_init_msg_list       => l_init_msg_list,
                p_commit              => l_commit,
                p_validation_level    => l_validation_level,
                p_calling_fn          => l_calling_fn,
                x_return_status       => l_return_status,
                x_msg_count           => l_msg_count,
                x_msg_data            => l_msg_data,
                px_src_trans_rec      => l_src_trans_rec,
                px_src_asset_hdr_rec  => l_src_asset_hdr_rec,
                px_dest_trans_rec     => l_dest_trans_rec,
                px_dest_asset_hdr_rec => l_dest_asset_hdr_rec,
                p_inv_tbl             => l_inv_tbl
            );

            if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
               raise error_found;
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

      EXCEPTION
         -- Mark batch as failed but continue despite errors
         WHEN error_found THEN
              ROLLBACK to process_transfer;
              l_transaction_status(i) := 'ERROR';
              x_failure_count := x_failure_count + 1;
              x_return_status := 1;

              if (g_log_level_rec.statement_level) then
                 fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
              end if;

              fa_srvr_msg.add_message(
                 calling_fn  => l_calling_fn,
                 application => 'CUA',
                 name        => 'CUA_TRF_FAILED',
                 token1      => 'Mass_External_Transfer_ID',
                 value1      => l_mass_external_transfer_id(i),
                 p_log_level_rec => g_log_level_rec);


         WHEN others then
              ROLLBACK to process_transfer;
              l_transaction_status(i) := 'ERROR';
              x_failure_count := x_failure_count + 1;
              x_return_status := 1;

              if (g_log_level_rec.statement_level) then
                 fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
              end if;

              fa_srvr_msg.add_message(
                 calling_fn  => l_calling_fn,
                 application => 'CUA',
                 name        => 'CUA_TRF_FAILED',
                 token1      => 'Mass_External_Transfer_ID',
                 value1      => l_mass_external_transfer_id(i),
                 p_log_level_rec => g_log_level_rec);

      END;  -- end line level block

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
   WHEN OTHERS THEN
      ROLLBACK TO process_transfer;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;

      l_transaction_status(l_counter) := 'ERROR';
      x_failure_count := x_failure_count + 1;
      x_return_status := 2;

      fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

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

END do_mass_sl_transfer;

PROCEDURE allocate_workers (
     p_book_type_code                IN     VARCHAR2,
     p_batch_name                    IN     VARCHAR2,
     p_total_requests                IN     NUMBER,
     x_return_status                    OUT NOCOPY NUMBER) IS

   l_max_mass_ext_transfer_id     number(15);

   cursor group_lines is
      select tfr.mass_external_transfer_id,
             bks1.group_asset_id,  -- from_group_asset_id
             bks2.group_asset_id   -- to_group_asset_id
      from   fa_books bks1,
             fa_books bks2,
             fa_mass_external_transfers tfr
      where  tfr.book_type_code = p_book_type_code
      and    tfr.batch_name = p_batch_name
      and    tfr.transaction_status = 'POST'
      and    tfr.transaction_type in ('INTER', 'ADJUSTMENT')
      and    tfr.mass_external_transfer_id > l_max_mass_ext_transfer_id
      and    bks1.book_type_code = p_book_type_code
      and    bks1.asset_id = tfr.from_asset_id
      and    bks1.date_ineffective is null
      and    bks2.book_type_code = p_book_type_code
      and    bks2.asset_id = tfr.to_asset_id
      and    bks2.date_ineffective is null
      order by tfr.mass_external_transfer_id;

   cursor tfr_lines is
      select tfr.mass_external_transfer_id,
             tfr.book_type_code,
             tfr.batch_name,
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
             tfr.from_group_asset_id,
             tfr.to_group_asset_id,
             tfr.worker_id
      from   fa_mass_external_transfers tfr
      where  tfr.book_type_code = p_book_type_code
      and    tfr.batch_name = p_batch_name
      and    tfr.transaction_status = 'POST'
      and    tfr.transaction_type in ('INTER', 'ADJUSTMENT')
      and    tfr.worker_id is null;

   l_group_enabled                varchar(1) := 'Y';
   allocate_err                   exception;

   -- Used for bulk fetching
   l_batch_size                   number;

   -- Column types for bulk update
   l_mass_ext_transfer_id_tbl     num_tbl_type;
   l_from_group_asset_id_tbl      num_tbl_type;
   l_to_group_asset_id_tbl        num_tbl_type;
   l_sub_from_group_asset_id      num_tbl_type;
   l_sub_to_group_asset_id        num_tbl_type;
   l_sub_from_asset_id            num_tbl_type;
   l_sub_to_asset_id              num_tbl_type;

   l_dep_group_asset_id           num_tbl_type;
   l_dep_asset_id                 num_tbl_type;
   l_dep_group_idx                number := 0;
   l_dep_asset_idx                number := 0;
   l_dep_group_total              number := 0;
   l_dep_asset_total              number := 0;
   l_new_group_total              number := 0;
   l_new_asset_total              number := 0;

   -- Column types for cursor
   l_mass_external_transfer_id    number(15);
   l_set_of_books_id              number(15);
   l_book_type_code               varchar2(30);
   l_batch_name                   varchar2(15);
   l_from_group_asset_id          number(15);
   l_from_asset_id                number(15);
   l_to_group_asset_id            number(15);
   l_to_asset_id                  number(15);
   l_transaction_status           varchar2(20);
   l_transaction_date_entered     date;
   l_from_distribution_id         number(15);
   l_from_location_id             number(15);
   l_from_gl_ccid                 number(15);
   l_from_employee_id             number(15);
   l_to_distribution_id           number(15);
   l_to_location_id               number(15);
   l_to_gl_ccid                   number(15);
   l_to_employee_id               number(15);
   l_source_line_id               number(15);
   l_worker_id                    number(15);

BEGIN

   x_return_status := 0;


   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise allocate_err;
      end if;
   end if;

   -- If not run in parallel, don't need to do this logic.
   if (nvl(p_total_requests, 1) = 1) then
      return;
   end if;

   -- Call the cache for the book
   if (NOT fa_cache_pkg.fazcbc (
      X_book => p_book_type_code
   , p_log_level_rec => g_log_level_rec)) then
      raise allocate_err;
   end if;

   -- Check to see if group is enabled for the book.
   l_group_enabled :=
      nvl(fa_cache_pkg.fazcbc_record.allow_group_deprn_flag, 'N');

   -- load profiles for batch size
   if not fa_cache_pkg.fazprof then
      null;
   end if;

   l_batch_size := nvl(fa_cache_pkg.fa_batch_size, 200);

   -- Populate the group asset id if group is enabled
   if (l_group_enabled = 'Y') then

       l_max_mass_ext_transfer_id := 0;

       loop
          open group_lines;
          fetch group_lines bulk collect into
            l_mass_ext_transfer_id_tbl,
            l_from_group_asset_id_tbl,
            l_to_group_asset_id_tbl
          limit l_batch_size;
          close group_lines;

          if l_mass_ext_transfer_id_tbl.count = 0 then
             exit;
          end if;

          forall i in 1..l_mass_ext_transfer_id_tbl.count
             update fa_mass_external_transfers
             set    from_group_asset_id = l_from_group_asset_id_tbl(i),
                    to_group_asset_id = l_to_group_asset_id_tbl(i)
             where  mass_external_transfer_id = l_mass_ext_transfer_id_tbl(i);

          FND_CONCURRENT.AF_COMMIT;

          l_max_mass_ext_transfer_id :=
             l_mass_ext_transfer_id_tbl(l_mass_ext_transfer_id_tbl.count);

       end loop;
   end if;

   -- Allocate each external transfer line to a worker_id.
   loop

      -- start with the from assets
      -- need to reopen/fetch each time so that
      -- we don't pick up rows updated by a prior one
      open tfr_lines;

      fetch tfr_lines into
         l_mass_external_transfer_id,
         l_book_type_code,
         l_batch_name,
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
         l_from_group_asset_id,
         l_to_group_asset_id,
         l_worker_id;

      if (tfr_lines%NOTFOUND) then
         close tfr_lines;
         exit;
      end if;
      close tfr_lines;

   -- Check to see if this record has already been allocated
   if (l_worker_id is null) then

      SAVEPOINT allocate_process;

      -- Allocate worker logic
      if (l_from_group_asset_id is not null) then
         -- Not using striping but dividing by 10 to avoid block contention
         -- for multiple workers.
         l_worker_id := (floor(l_from_group_asset_id / 10) mod
                         p_total_requests) + 1;

         -- Need this to take care of min values and etc.
         if ((l_worker_id is null) or (l_worker_id < 1))  then
            l_worker_id := 1;
         elsif (l_worker_id > p_total_requests) then
            l_worker_id := p_total_requests;
         end if;

         -- Populate the dependent assets array
         l_dep_group_asset_id(1) := l_from_group_asset_id;
         l_dep_group_total := 1;
         l_dep_group_idx := 1;
         l_dep_asset_idx := 1;

         if (l_to_group_asset_id is not null) then
            l_dep_group_asset_id(2) := l_to_group_asset_id;
            l_dep_group_total := 2;
            l_dep_asset_total := 0;
         else
            l_dep_asset_id(1) := l_to_asset_id;
            l_dep_asset_total := 1;
         end if;

      elsif (l_from_asset_id is not null) then
         -- Not using striping but dividing by 10 to avoid block contention
         -- for multiple workers.
         l_worker_id := (floor(l_from_asset_id / 10) mod
                         p_total_requests) + 1;

         -- Need this to take care of min values and etc.
         if ((l_worker_id is null) or (l_worker_id < 1) or
             (l_worker_id > p_total_requests)) then
            l_worker_id := 1;
         end if;

         -- Now we need to make sure we set all dependent rows to this
         -- same worker id

         -- Populate the dependent assets array
         l_dep_asset_id(1) := l_from_asset_id;
         l_dep_asset_total := 1;
         l_dep_group_idx := 1;
         l_dep_asset_idx := 1;

         if (l_to_group_asset_id is null) then
            l_dep_asset_id(2) := l_to_asset_id;
            l_dep_asset_total := 2;
            l_dep_group_total := 0;
         else
            l_dep_group_asset_id(1) := l_to_group_asset_id;
            l_dep_group_total := 1;
         end if;

     else
         l_worker_id := 1;

         update fa_mass_external_transfers
         set worker_id = l_worker_id
         where mass_external_transfer_id = l_mass_external_transfer_id;

         l_dep_group_idx := 1;
         l_dep_asset_idx := 1;
         l_dep_group_total := 0;
         l_dep_asset_total := 0;

     end if;

     -- Update table with dependencies
     loop
        -- Initialize variables
        l_new_group_total := l_dep_group_total;
        l_new_asset_total := l_dep_asset_total;

        -- Set all records w/ same from_group to this worker
        for i in l_dep_group_idx..l_dep_group_total loop
           begin
              update fa_mass_external_transfers tfr
              set    tfr.worker_id = l_worker_id
              where  tfr.book_type_code = p_book_type_code
              and    tfr.batch_name = p_batch_name
              and    tfr.transaction_status = 'POST'
              and    tfr.transaction_type in ('INTER', 'ADJUSTMENT')
              and    tfr.from_group_asset_id = l_dep_group_asset_id(i)
              and    tfr.worker_id is null
              returning tfr.to_group_asset_id, tfr.to_asset_id bulk collect
                        into l_sub_to_group_asset_id, l_sub_to_asset_id;

              -- Add additional group dependencies found
              add_dependencies (
                 px_dep_group_asset_id => l_dep_group_asset_id,
                 px_dep_asset_id       => l_dep_asset_id,
                 p_sub_group_asset_id  => l_sub_to_group_asset_id,
                 p_sub_asset_id        => l_sub_to_asset_id,
                 px_new_group_total    => l_new_group_total,
                 px_new_asset_total    => l_new_asset_total);

           exception
              when no_data_found then
                  null;
           end;
        end loop;

        -- Set all records w/ same to_group to this worker
        for i in l_dep_group_idx..l_dep_group_total loop
           begin
              update fa_mass_external_transfers tfr
              set    tfr.worker_id = l_worker_id
              where  tfr.book_type_code = p_book_type_code
              and    tfr.batch_name = p_batch_name
              and    tfr.transaction_status = 'POST'
              and    tfr.transaction_type in ('INTER', 'ADJUSTMENT')
              and    tfr.to_group_asset_id = l_dep_group_asset_id(i)
              and    tfr.worker_id is null
              returning tfr.from_group_asset_id,tfr.from_asset_id bulk collect
                        into l_sub_from_group_asset_id, l_sub_from_asset_id;

              -- Add additional group dependencies found
              add_dependencies (
                 px_dep_group_asset_id => l_dep_group_asset_id,
                 px_dep_asset_id       => l_dep_asset_id,
                 p_sub_group_asset_id  => l_sub_from_group_asset_id,
                 p_sub_asset_id        => l_sub_from_asset_id,
                 px_new_group_total    => l_new_group_total,
                 px_new_asset_total    => l_new_asset_total);

           exception
              when no_data_found then
                  null;
           end;
        end loop;

        -- Set all records w/ same from_asset to this worker
        for i in l_dep_asset_idx..l_dep_asset_total loop
           begin
              update fa_mass_external_transfers tfr
              set    tfr.worker_id = l_worker_id
              where  tfr.book_type_code = p_book_type_code
              and    tfr.batch_name = p_batch_name
              and    tfr.transaction_status = 'POST'
              and    tfr.transaction_type in ('INTER', 'ADJUSTMENT')
              and    tfr.from_asset_id = l_dep_asset_id(i)
              and    tfr.worker_id is null
              returning tfr.to_group_asset_id, tfr.to_asset_id bulk collect
                        into l_sub_to_group_asset_id, l_sub_to_asset_id;

              -- Add additional group dependencies found
              add_dependencies (
                 px_dep_group_asset_id => l_dep_group_asset_id,
                 px_dep_asset_id       => l_dep_asset_id,
                 p_sub_group_asset_id  => l_sub_to_group_asset_id,
                 p_sub_asset_id        => l_sub_to_asset_id,
                 px_new_group_total    => l_new_group_total,
                 px_new_asset_total    => l_new_asset_total);

           exception
              when no_data_found then
                 null;
           end;
        end loop;

        -- Set all records w/ same to_asset to this worker
        for i in l_dep_asset_idx..l_dep_asset_total loop
           begin
              update fa_mass_external_transfers tfr
              set    tfr.worker_id = l_worker_id
              where  tfr.book_type_code = p_book_type_code
              and    tfr.batch_name = p_batch_name
              and    tfr.transaction_status = 'POST'
              and    tfr.transaction_type in ('INTER', 'ADJUSTMENT')
              and    tfr.to_asset_id = l_dep_asset_id(i)
              and    tfr.worker_id is null
              returning tfr.from_group_asset_id,tfr.from_asset_id bulk collect
                        into l_sub_from_group_asset_id, l_sub_from_asset_id;

              -- Add additional group dependencies found
              add_dependencies (
                 px_dep_group_asset_id => l_dep_group_asset_id,
                 px_dep_asset_id       => l_dep_asset_id,
                 p_sub_group_asset_id  => l_sub_from_group_asset_id,
                 p_sub_asset_id        => l_sub_from_asset_id,
                 px_new_group_total    => l_new_group_total,
                 px_new_asset_total    => l_new_asset_total);

           exception
               when no_data_found then
                  null;
           end;
        end loop;

        -- Set the counters to their new values
        l_dep_group_idx := l_dep_group_total + 1;
        l_dep_group_total := l_new_group_total;
        l_dep_asset_idx := l_dep_asset_total + 1;
        l_dep_asset_total := l_new_asset_total;

        -- Check to see if we are done with the dependencies
        if (l_dep_group_idx > l_dep_group_total) and
           (l_dep_asset_idx > l_dep_asset_total) then
           exit;
        end if;
     end loop;

     FND_CONCURRENT.AF_COMMIT;

   end if;

   end loop;

EXCEPTION
   WHEN ALLOCATE_ERR THEN

      x_return_status := 2;

   WHEN OTHERS THEN
      ROLLBACK TO allocate_process;

      x_return_status := 2;
END allocate_workers;

PROCEDURE add_dependencies (
     px_dep_group_asset_id           IN OUT NOCOPY NUM_TBL_TYPE,
     px_dep_asset_id                 IN OUT NOCOPY NUM_TBL_TYPE,
     p_sub_group_asset_id            IN     NUM_TBL_TYPE,
     p_sub_asset_id                  IN     NUM_TBL_TYPE,
     px_new_group_total              IN OUT NOCOPY NUMBER,
     px_new_asset_total              IN OUT NOCOPY NUMBER) IS

   l_found      boolean;

BEGIN

   -- Add additional group dependencies found
   for j in 1..p_sub_group_asset_id.count loop
       l_found := FALSE;

       if (p_sub_group_asset_id(j) is not null) then
          -- Check to see if this dependency already exists
          for k in 1..px_new_group_total loop
              if (px_dep_group_asset_id(k) = p_sub_group_asset_id(j)) then
                 l_found := TRUE;
                 exit;
              end if;
          end loop;
          if (l_found = TRUE) then
              -- Don't add it since it already exists
              null;
          else
              -- Add new dependency to the end of the array
              px_dep_group_asset_id(px_new_group_total + 1) :=
                 p_sub_group_asset_id(j);
              px_new_group_total := px_new_group_total + 1;

          end if;
       else
          -- Add additional asset dependencies.
          -- Check to see if this dependency already exists
          for k in 1..px_new_asset_total loop
              if (px_dep_asset_id(k) = p_sub_asset_id(j)) then
                 l_found := TRUE;
                 exit;
              end if;
          end loop;
          if (l_found = TRUE) then
             -- Don't add it since it already exists
             null;
          else
             -- Add new dependency to the end of the array
             px_dep_asset_id(px_new_asset_total + 1) := p_sub_asset_id(j);
             px_new_asset_total := px_new_asset_total + 1;
          end if;
       end if;
   end loop;

END add_dependencies;

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

   validate_err                   exception;

   l_calling_fn                   varchar2(40)
                                     := 'fa_masspsltfr_pkg.validate_transfer';

   l_book_exists                  number;
   l_from_asset_exists            number;
   l_to_asset_exists              number;
   l_fixed_assets_cost            number;
   l_amt_count                    number;
   l_his_count                    number;
   l_retire_pending_count         number;
   l_period_counter_life_complete number(15);
   l_period_counter_fully_rsvd    number(15);
   l_period_counter_fully_retired number(15);
   l_from_asset_type              varchar2(11);
   l_to_asset_type                varchar2(11);
   l_return_status                boolean;
   l_check_pending_batch          number := 0;
   l_txn_status                   boolean := FALSE;

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
             to_number(a.source_entity_key_value) in
                (p_from_asset_id, p_to_asset_id))
            )
   );

BEGIN

   -- removing these checks as they are no longer needed


   -- incorporated / redundant with api validations:
   --
   --   Check for nulls (asset_ids, book, source_line, amount)
   --   Zero Transfer Amount
   --   From and To Asset Ids Identical
   --   Book Type Code Is Invalid
   --   Invalid From Asset Id
   --   Invalid To Asset Id
   --   Source Line ID is invalid
   --   From Asset has some retirement transactions pending
   --   To Asset has some retirement transactions pending
   --   From Asset's Life is complete, but not yet fully reserved
   --   From Asset is fully retired
   --   To Asset's Life is complete, but not yet fully reserved
   --   To Asset is fully retired
   --   Transfer Amount must be between zero and the invoice line cost
   --   Cannot Transfer Lines between expensed and Non Expensed Assets


   --
   -- obsolete...
   --
   -- allowed as of FA.K:
   --   From Asset has previously had an amortized adjustment
   --   To Asset has previously had an amortized adjustment
   --   Cannot transfer lines between assets added in the current
   --      period and assets added in prior periods.
   --
   -- not possible in GUI:
   --   From Asset not assigned to a cost centre
   --   To Asset not assigned to a cost centre


   -- BUG# 3035601 - removed call to faxcbs as faxbmt is called
   -- from pro*c wrapper
   -- Check if book in use


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

-- Added the procedure for bug 3442951
PROCEDURE Purge(
               ERRBUF   OUT NOCOPY  VARCHAR2,
               RETCODE  OUT NOCOPY  VARCHAR2)
IS
	Cursor Assets_C is
		select Mass_External_Transfer_ID
		from fa_mass_external_transfers
		where transaction_status in ('DELETE','POSTED')
		for update nowait;
	LV_Mass_External_Transfer_ID	NUMBER;
BEGIN
	Open Assets_C;
	Loop
		Fetch Assets_C into LV_Mass_External_Transfer_ID;
		Exit when Assets_C%NOTFOUND;

		Delete from fa_mass_external_transfers
		where mass_external_transfer_id = LV_Mass_External_Transfer_ID;

	End Loop;
	Close Assets_C;
EXCEPTION
	When NO_DATA_FOUND Then
		Return;

  	WHEN OTHERS THEN
    		errbuf :=  SQLERRM(SQLCODE);
    		retcode := SQLCODE;
    		return;
END Purge;

END FA_MASSPSLTFR_PKG;

/
