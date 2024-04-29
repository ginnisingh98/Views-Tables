--------------------------------------------------------
--  DDL for Package Body FA_MASS_REVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASS_REVAL_PKG" as
/* $Header: FAMRVLB.pls 120.10.12010000.3 2009/08/26 00:04:50 mswetha ship $   */

g_release                  number  := fa_cache_pkg.fazarel_release;

G_times_called    number := 0;

G_book_type_code                  varchar2(30);
G_description                     varchar2(80);
G_reval_date                      date;
G_def_reval_fully_rsvd_flag       varchar2(3);
G_def_life_extension_factor       number;
G_def_life_extension_ceiling      number;
G_def_max_fully_rsvd_revals       number;
G_status                          varchar2(10);
G_last_request_id                 number;
G_attribute1                      varchar2(150);
G_attribute2                      varchar2(150);
G_attribute3                      varchar2(150);
G_attribute4                      varchar2(150);
G_attribute5                      varchar2(150);
G_attribute6                      varchar2(150);
G_attribute7                      varchar2(150);
G_attribute8                      varchar2(150);
G_attribute9                      varchar2(150);
G_attribute10                     varchar2(150);
G_attribute11                     varchar2(150);
G_attribute12                     varchar2(150);
G_attribute13                     varchar2(150);
G_attribute14                     varchar2(150);
G_attribute15                     varchar2(150);
G_attribute_category_code         varchar2(30);
G_created_by                      number;
G_creation_date                   date;
G_last_updated_by                 number;
G_last_update_date                date;
G_last_update_login               number;
G_global_attribute1               varchar2(150);
G_global_attribute2               varchar2(150);
G_global_attribute3               varchar2(150);
G_global_attribute4               varchar2(150);
G_global_attribute5               varchar2(150);
G_global_attribute6               varchar2(150);
G_global_attribute7               varchar2(150);
G_global_attribute8               varchar2(150);
G_global_attribute9               varchar2(150);
G_global_attribute10              varchar2(150);
G_global_attribute11              varchar2(150);
G_global_attribute12              varchar2(150);
G_global_attribute13              varchar2(150);
G_global_attribute14              varchar2(150);
G_global_attribute15              varchar2(150);
G_global_attribute16              varchar2(150);
G_global_attribute17              varchar2(150);
G_global_attribute18              varchar2(150);
G_global_attribute19              varchar2(150);
G_global_attribute20              varchar2(150);
G_global_attribute_category       varchar2(30);
G_def_revalue_cip_assets_flag     varchar2(1);

G_period_rec                      FA_API_TYPES.period_rec_type;

G_batch_size                      number;

g_log_level_rec fa_api_types.log_level_rec_type;

PROCEDURE do_mass_reval (
                p_mass_reval_id      IN     NUMBER,
                p_mode               IN     VARCHAR2,
                p_loop_count         IN     NUMBER,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                p_request_number     IN     NUMBER,
                x_success_count         OUT NOCOPY number,
                x_failure_count         OUT NOCOPY number,
                x_return_status         OUT NOCOPY number) IS

   -- used for bulk fetching
   l_loop_count                 number;

   -- local variables
   l_period_of_addition         varchar2(1);

   -- local variables
   TYPE v150_tbl IS TABLE OF VARCHAR2(150)  INDEX BY BINARY_INTEGER;
   TYPE v30_tbl  IS TABLE OF VARCHAR2(30)   INDEX BY BINARY_INTEGER;
   TYPE num_tbl  IS TABLE OF NUMBER         INDEX BY BINARY_INTEGER;
   TYPE date_tbl IS TABLE OF DATE           INDEX BY BINARY_INTEGER;

   -- for main selection
   l_rowid                      v30_tbl;
   l_asset_id                   num_tbl;
   l_asset_number               v30_tbl;
   l_asset_type                 v30_tbl;
   l_asset_category_id          num_tbl;
   l_current_units              num_tbl;
   l_reval_percent              num_tbl;
   l_value_type                 v30_tbl; -- Bug#6666666 SORP
   l_mass_reval_id              num_tbl; -- Bug#6666666 SORP
   l_linked_flag                v30_tbl; -- Bug#6666666 SORP
   l_reval_type_flag            v30_tbl; -- Bug#6666666 SORP
   l_override_defaults_flag     v30_tbl;
   l_reval_fully_rsvd_flag      v30_tbl;
   l_life_extension_factor      num_tbl;
   l_life_extension_ceiling     num_tbl;
   l_max_fully_rsvd_revals      num_tbl;
   l_r_attribute1               v150_tbl;
   l_r_attribute2               v150_tbl;
   l_r_attribute3               v150_tbl;
   l_r_attribute4               v150_tbl;
   l_r_attribute5               v150_tbl;
   l_r_attribute6               v150_tbl;
   l_r_attribute7               v150_tbl;
   l_r_attribute8               v150_tbl;
   l_r_attribute9               v150_tbl;
   l_r_attribute10              v150_tbl;
   l_r_attribute11              v150_tbl;
   l_r_attribute12              v150_tbl;
   l_r_attribute13              v150_tbl;
   l_r_attribute14              v150_tbl;
   l_r_attribute15              v150_tbl;
   l_r_attribute_category_code  v30_tbl;
   l_reval_attribute_category   v30_tbl;
   l_revalue_cip_assets_flag    v30_tbl;

   -- variables and structs used for api call
   l_api_version                  NUMBER      := 1.0;
   l_init_msg_list                VARCHAR2(1) := FND_API.G_FALSE;
   l_commit                       VARCHAR2(1) := FND_API.G_FALSE;
   l_validation_level             NUMBER      := FND_API.G_VALID_LEVEL_FULL;
   l_return_status                VARCHAR2(1);
   l_mesg_count                   number;
   l_mesg                         VARCHAR2(4000);
   l_calling_fn                   VARCHAR2(30) := 'fa_mass_reval_pkg.do_reval';
   l_string                       varchar2(250);

   l_asset_fin_rec_old            FA_API_TYPES.asset_fin_rec_type;

   l_trans_rec                    FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec                FA_API_TYPES.asset_hdr_rec_type;
   l_asset_fin_rec_adj            FA_API_TYPES.asset_fin_rec_type;
   l_asset_deprn_rec_adj          FA_API_TYPES.asset_deprn_rec_type;

   l_reval_options_rec            FA_API_TYPES.reval_options_rec_type;

   l_mesg_name                    VARCHAR2(30);

   l_process_status               v30_tbl;

   -- main cursors
   -- asset based

   cursor c_assets is
   select pw.rowid,
          pw.asset_id,
          pw.asset_number,
          pw.asset_type,
          ad.asset_category_id,
          ad.current_units,
          rr.reval_percent,
          rr.value_type, -- Bug#6666666 SORP
          rr.mass_reval_id, -- Bug#6666666 SORP
          rr.linked_flag, -- Bug#6666666 SORP
          'A' "reval_type_flag",-- Bug#6666666 SORP
          rr.override_defaults_flag,
          DECODE(rr.override_defaults_flag,
                 'YES', rr.reval_fully_rsvd_flag,
                 g_def_reval_fully_rsvd_flag),
          DECODE(rr.override_defaults_flag,
                 'YES', rr.life_extension_factor,
                 g_def_life_extension_factor),
          DECODE(rr.override_defaults_flag,
                 'YES', rr.life_extension_ceiling,
                 g_def_life_extension_ceiling),
          DECODE(rr.override_defaults_flag,
                 'YES', rr.max_fully_rsvd_revals,
                 g_def_max_fully_rsvd_revals),
          rr.attribute1,
          rr.attribute2,
          rr.attribute3,
          rr.attribute4,
          rr.attribute5,
          rr.attribute6,
          rr.attribute7,
          rr.attribute8,
          rr.attribute9,
          rr.attribute10,
          rr.attribute11,
          rr.attribute12,
          rr.attribute13,
          rr.attribute14,
          rr.attribute15,
          rr.attribute_category_code,
          rr.reval_attribute_category,
          DECODE(rr.override_defaults_flag,
                 'YES', rr.revalue_cip_assets_flag,
                 g_def_revalue_cip_assets_flag)
     FROM fa_parallel_workers pw,
          fa_mass_revaluation_rules rr,
          fa_additions_b ad
    WHERE pw.request_id     = p_parent_request_id
      AND pw.worker_number  = p_request_number
      AND pw.process_status = 'UNPROCESSED'
      AND pw.asset_category_id is null
      AND rr.mass_reval_id  = p_mass_reval_id
      AND rr.asset_id       = pw.asset_id
      AND ad.asset_id       = pw.asset_id;


   cursor c_assets_cat is
   select pw.rowid,
          pw.asset_id,
          pw.asset_number,
          pw.asset_type,
          ad.asset_category_id,
          ad.current_units,
          rr.reval_percent,
          rr.value_type,  -- Bug#6666666 SORP
          rr.mass_reval_id, -- Bug#6666666 SORP
          rr.linked_flag, -- Bug#6666666 SORP
          'C' "reval_type_flag", -- Bug#6666666 SORP
          rr.override_defaults_flag,
          DECODE(rr.override_defaults_flag,
                 'YES', rr.reval_fully_rsvd_flag,
                 g_def_reval_fully_rsvd_flag),
          DECODE(rr.override_defaults_flag,
                 'YES', rr.life_extension_factor,
                 g_def_life_extension_factor),
          DECODE(rr.override_defaults_flag,
                 'YES', rr.life_extension_ceiling,
                 g_def_life_extension_ceiling),
          DECODE(rr.override_defaults_flag,
                 'YES', rr.max_fully_rsvd_revals,
                 g_def_max_fully_rsvd_revals),
          rr.attribute1,
          rr.attribute2,
          rr.attribute3,
          rr.attribute4,
          rr.attribute5,
          rr.attribute6,
          rr.attribute7,
          rr.attribute8,
          rr.attribute9,
          rr.attribute10,
          rr.attribute11,
          rr.attribute12,
          rr.attribute13,
          rr.attribute14,
          rr.attribute15,
          rr.attribute_category_code,
          rr.reval_attribute_category,
          DECODE(rr.override_defaults_flag,
                 'YES', rr.revalue_cip_assets_flag,
                 g_def_revalue_cip_assets_flag)
     FROM fa_parallel_workers pw,
          fa_mass_revaluation_rules rr,
          fa_additions_b ad
    WHERE pw.request_id         = p_parent_request_id
      AND pw.worker_number      = p_request_number
      AND pw.process_status     = 'UNPROCESSED'
      AND pw.asset_category_id is not null
      AND rr.mass_reval_id      = p_mass_reval_id
      AND rr.category_id        = pw.asset_category_id
      AND ad.asset_id           = pw.asset_id;

   done_exc      EXCEPTION;
   massrvl_err   EXCEPTION;
   reval_err       EXCEPTION;

BEGIN


   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise massrvl_err;
      end if;
   end if;

   g_release  := fa_cache_pkg.fazarel_release;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'at begin', '', p_log_level_rec => g_log_level_rec);
   end if;

   G_times_called := G_times_called + 1;

   x_success_count := 0;
   x_failure_count := 0;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'before init', '', p_log_level_rec => g_log_level_rec);
   end if;

   if (G_times_called = 1) then

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

      -- get mass reval info
      if not get_mass_reval_info (p_mass_reval_id => p_mass_reval_id) then
         raise massrvl_err;
      end if;

      -- initial book control validation
      if (fa_cache_pkg.fazcbc_record.allow_reval_flag <> 'YES') then
         fa_srvr_msg.add_message
             (calling_fn => l_calling_fn,
              name       => 'FA_BOOK_REVAL_NOT_ALLOW', p_log_level_rec => g_log_level_rec);
         raise massrvl_err;
      elsif (fa_cache_pkg.fazcbc_record.date_ineffective is not null) then
         fa_srvr_msg.add_message
             (calling_fn => l_calling_fn,
              name       => 'FA_DATA_ERR_MASS_REVAL', p_log_level_rec => g_log_level_rec);
         raise massrvl_err;
      end if;

      G_batch_size := nvl(fa_cache_pkg.fa_batch_size, 200);

   end if;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'after init', '', p_log_level_rec => g_log_level_rec);
   end if;

   if p_loop_count = 1 then  -- asset level first

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'opening c_assets cursor at', sysdate, p_log_level_rec => g_log_level_rec);
      end if;

      OPEN c_assets;
      FETCH c_assets BULK COLLECT INTO
            l_rowid                      ,
            l_asset_id                   ,
            l_asset_number               ,
            l_asset_type                 ,
            l_asset_category_id          ,
            l_current_units              ,
            l_reval_percent              ,
            l_value_type                 ,  -- Bug#6666666 SORP
            l_mass_reval_id              ,  -- Bug#6666666 SORP
            l_linked_flag                ,  -- Bug#6666666 SORP
            l_reval_type_flag            ,  -- Bug#6666666 SORP
            l_override_defaults_flag     ,
            l_reval_fully_rsvd_flag      ,
            l_life_extension_factor      ,
            l_life_extension_ceiling     ,
            l_max_fully_rsvd_revals      ,
            l_r_attribute1               ,
            l_r_attribute2               ,
            l_r_attribute3               ,
            l_r_attribute4               ,
            l_r_attribute5               ,
            l_r_attribute6               ,
            l_r_attribute7               ,
            l_r_attribute8               ,
            l_r_attribute9               ,
            l_r_attribute10              ,
            l_r_attribute11              ,
            l_r_attribute12              ,
            l_r_attribute13              ,
            l_r_attribute14              ,
            l_r_attribute15              ,
            l_r_attribute_category_code  ,
            l_reval_attribute_category ,
            l_revalue_cip_assets_flag
      LIMIT G_batch_size;

      close c_assets;


   else  -- category level

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'opening c_assets_cat cursor at', sysdate, p_log_level_rec => g_log_level_rec);
      end if;

      OPEN c_assets_cat;
      FETCH c_assets_cat BULK COLLECT INTO
            l_rowid                      ,
            l_asset_id                   ,
            l_asset_number               ,
            l_asset_type                 ,
            l_asset_category_id          ,
            l_current_units              ,
            l_reval_percent              ,
            l_value_type                 ,  -- Bug#6666666 SORP
            l_mass_reval_id              ,  -- Bug#6666666 SORP
            l_linked_flag                ,  -- Bug#6666666 SORP
            l_reval_type_flag            ,  -- Bug#6666666 SORP
            l_override_defaults_flag     ,
            l_reval_fully_rsvd_flag      ,
            l_life_extension_factor      ,
            l_life_extension_ceiling     ,
            l_max_fully_rsvd_revals      ,
            l_r_attribute1               ,
            l_r_attribute2               ,
            l_r_attribute3               ,
            l_r_attribute4               ,
            l_r_attribute5               ,
            l_r_attribute6               ,
            l_r_attribute7               ,
            l_r_attribute8               ,
            l_r_attribute9               ,
            l_r_attribute10              ,
            l_r_attribute11              ,
            l_r_attribute12              ,
            l_r_attribute13              ,
            l_r_attribute14              ,
            l_r_attribute15              ,
            l_r_attribute_category_code  ,
            l_reval_attribute_category ,
            l_revalue_cip_assets_flag
      LIMIT G_batch_size;

      close c_assets_cat;


   end if;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add('test',
                       'after fetch asset count is',
                       l_rowid.count, p_log_level_rec => g_log_level_rec);
   end if;

   if (l_asset_id.count = 0) then
      raise done_exc;
   end if;


   for l_loop_count in 1..l_asset_id.count loop

      -- clear the debug stack for each asset
      FA_DEBUG_PKG.Initialize;
      -- reset the message level to prevent bogus errors
      FA_SRVR_MSG.Set_Message_Level(message_level => 10, p_log_level_rec => g_log_level_rec);

      l_mesg_name := null;

      BEGIN

         -- Check that assets do not have transactions dated after the
         -- request was submitted

         /* not sure if this is needed
         if l_date_effective(l_loop_count) >= l_mass_date_effective then
            l_mesg_name := 'FA_MASSCHG_DATE';
            raise reval_err;
         end if;
         */

         -- R12 conditional handling
         if (G_release = 11 and
             not FA_ASSET_VAL_PVT.validate_period_of_addition
             (p_asset_id            => l_asset_id(l_loop_count),
              p_book                => G_book_type_code,
              p_mode                => 'ABSOLUTE',
              px_period_of_addition => l_period_of_addition,
              p_log_level_rec       => g_log_level_rec)) then
            raise reval_err;
         elsif (l_period_of_addition = 'Y') then
            l_mesg_name := 'FA_REVAL_NO_DEPRECIATED';
            raise reval_err;
         end if;


         -- validation ok, null out then load the structs and process the adjustment
         l_trans_rec                    := NULL;
         l_asset_hdr_rec                := NULL;
         l_reval_options_rec            := NULL;

         -- reset the who info in trans rec
         l_trans_rec.who_info.last_update_date   := sysdate;
         l_trans_rec.who_info.last_updated_by    := FND_GLOBAL.USER_ID;
         l_trans_rec.who_info.created_by         := FND_GLOBAL.USER_ID;
         l_trans_rec.who_info.creation_date      := sysdate;
         l_trans_rec.who_info.last_update_login  := FND_GLOBAL.CONC_LOGIN_ID;
         l_trans_rec.mass_reference_id           := p_parent_request_id;
         l_trans_rec.calling_interface           := 'FAMRVL';
         l_trans_rec.mass_transaction_id         := p_mass_reval_id;

         l_trans_rec.transaction_date_entered    := G_reval_date;     -- does this need validation like date effective above
         l_trans_rec.transaction_name            := substr(G_description , 1, 30);  -- Bug#8602476
         -- asset header struct
         l_asset_hdr_rec.asset_id                := l_asset_id(l_loop_count);
         l_asset_hdr_rec.book_type_code          := G_book_type_code;

         -- reval options struct
         -- the flags must be converted from 3 char to 1

         l_reval_options_rec.REVAL_PERCENT          := l_reval_percent(l_loop_count);
         l_reval_options_rec.value_type             := l_value_type(l_loop_count); --Bug#6666666 SORP
         l_reval_options_rec.mass_reval_id          := l_mass_reval_id(l_loop_count); --Bug#6666666 SORP
         l_reval_options_rec.linked_flag            := l_linked_flag(l_loop_count); --Bug#6666666 SORP
         l_reval_options_rec.reval_type_flag        := l_reval_type_flag(l_loop_count); --Bug#6666666 SORP

         if (nvl(l_override_defaults_flag(l_loop_count), 'NO') = 'YES') then
            l_reval_options_rec.OVERRIDE_DEFAULTS_FLAG := 'Y';
         else
            l_reval_options_rec.OVERRIDE_DEFAULTS_FLAG := 'N';
         end if;

         if (nvl(l_reval_fully_rsvd_flag(l_loop_count), 'NO') = 'YES') then
            l_reval_options_rec.REVAL_FULLY_RSVD_FLAG := 'Y';
         else
            l_reval_options_rec.REVAL_FULLY_RSVD_FLAG := 'N';
         end if;

         l_reval_options_rec.LIFE_EXTENSION_FACTOR  := l_life_extension_factor(l_loop_count);
         l_reval_options_rec.LIFE_EXTENSION_CEILING := l_life_extension_ceiling(l_loop_count);
         l_reval_options_rec.MAX_FULLY_RSVD_REVALS  := l_max_fully_rsvd_revals(l_loop_count);
         l_reval_options_rec.RUN_MODE               := p_mode;


         -- call the reval api now
         FA_REVALUATION_PUB.do_reval
                 (p_api_version             => l_api_version,
                  p_init_msg_list           => l_init_msg_list,
                  p_commit                  => l_commit,
                  p_validation_level        => l_validation_level,
                  x_return_status           => l_return_status,
                  x_msg_count               => l_mesg_count,
                  x_msg_data                => l_mesg,
                  p_calling_fn              => l_calling_fn,
                  px_trans_rec              => l_trans_rec,
                  px_asset_hdr_rec          => l_asset_hdr_rec,
                  p_reval_options_rec       => l_reval_options_rec
                 );

         if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            l_mesg_name := null;
            raise reval_err;
         end if;

         x_success_count := x_success_count + 1;
         l_process_status(l_loop_count) := 'SUCCESS';

         write_message(l_asset_number(l_loop_count),
                       'FA_MCP_SHARED_SUCCEED',
                       p_mode);

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
         end if;

      EXCEPTION
         when reval_err then
            FND_CONCURRENT.AF_ROLLBACK;

            l_process_status(l_loop_count) := 'FAILURE';
            x_failure_count                := x_failure_count + 1;

            write_message(l_asset_number(l_loop_count),
                          l_mesg_name,
                          p_mode);
            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
            end if;

         when others then
            FND_CONCURRENT.AF_ROLLBACK;

            l_process_status(l_loop_count) := 'FAILURE';
            x_failure_count                := x_failure_count + 1;

            write_message(l_asset_number(l_loop_count),
                          null,
                          p_mode);

            fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
            end if;

      END;

      -- FND_CONCURRENT.AF_COMMIT each record
      FND_CONCURRENT.AF_COMMIT;

      fa_debug_pkg.add(l_calling_fn,
                       'asset_id : ', l_asset_id(l_asset_id.count));
      fa_debug_pkg.add(l_calling_fn,
                       'count : ',(l_asset_id.count));

   end loop;  -- main bulk fetch loop

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'updating fa_parallel_workers for status', '', p_log_level_rec => g_log_level_rec);
   end if;

   -- now flags the rows process status accordingly
   forall i in 1..l_rowid.count
   update fa_parallel_workers fpw
      set process_status = l_process_status(i)
    where rowid          = l_rowid(i);

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'rows updated in fa_parallel_workers for status', l_rowid.count, p_log_level_rec => g_log_level_rec);
   end if;

   x_return_status :=  0;

   if (p_mode = 'PREVIEW') then
      write_preview_messages;
   end if;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
   end if;


EXCEPTION
   when done_exc then
      x_return_status :=  0;

   when massrvl_err then
      FND_CONCURRENT.AF_ROLLBACK;
   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'in massrvl_err main', '', p_log_level_rec => g_log_level_rec);
   end if;

      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      if (g_log_level_rec.statement_level) then
         FA_DEBUG_PKG.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;
      x_return_status :=  2;

      if (p_mode = 'PREVIEW') then
         write_preview_messages;
      end if;

   when others then
      FND_CONCURRENT.AF_ROLLBACK;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'in massrvl_err when otherx', '', p_log_level_rec => g_log_level_rec);
   end if;

      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      if (g_log_level_rec.statement_level) then
         FA_DEBUG_PKG.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;
      x_return_status :=  2;

      if (p_mode = 'PREVIEW') then
         write_preview_messages;
      end if;

END do_mass_reval;

-----------------------------------------------------------------------------

PROCEDURE write_message
              (p_asset_number    in varchar2,
               p_message         in varchar2,
               p_mode            in varchar2) IS

   l_token varchar2(15);
   l_value varchar2(15);

   l_message      varchar2(30);
   l_mesg         varchar2(100);
   l_string       varchar2(512);
   l_calling_fn   varchar2(40);   -- conditionally populated below

BEGIN

   -- first dump the message to the output file
   -- set/translate/retrieve the mesg from fnd

   l_message := nvl(p_message,  'FA_MCP_FAIL_ACTION');

   if (l_message <> 'FA_MCP_SHARED_SUCCEED') then
      l_calling_fn := 'fa_mass_reval_pkg.do_mass_reval';
   end if;

   if (l_message = 'FA_MCP_SHARED_SUCCEED' or
       l_message = 'FA_MCP_FAIL_ACTION') then
      l_token := 'ASSET';
      l_value := p_asset_number;
   end if;

   if (p_mode = 'RUN') then
      fnd_message.set_name('OFA', l_message);
      if (l_message = 'FA_MCP_SHARED_SUCCEED' or
          l_message = 'FA_MCP_FAIL_ACTION') then
         fnd_message.set_token(l_token, l_value);
      end if;

      l_mesg := substrb(fnd_message.get, 1, 100);

      l_string       := rpad(p_asset_number, 15) || ' ' || l_mesg;

      FND_FILE.put(FND_FILE.output,l_string);
      FND_FILE.new_line(FND_FILE.output,1);

   end if;

   -- now process the messages for the log file
   fa_srvr_msg.add_message
      (calling_fn => l_calling_fn,
       token1     => l_token,
       value1     => l_value,
       name       => l_message, p_log_level_rec => g_log_level_rec);

EXCEPTION
   when others then
       raise;

END write_message;

-----------------------------------------------------------------------------

PROCEDURE write_preview_messages IS

   l_msg_count number;

BEGIN

   l_msg_count := fnd_msg_pub.count_msg;

   if (l_msg_count > 0) then

      fa_rx_conc_mesg_pkg.log(
          fnd_msg_pub.get(fnd_msg_pub.G_FIRST, fnd_api.G_FALSE));

      for i in 1..(l_msg_count-1) loop
         fa_rx_conc_mesg_pkg.log(
           fnd_msg_pub.get(fnd_msg_pub.G_NEXT, fnd_api.G_FALSE));
      end loop;

   end if;

   -- clear the stack
   fnd_msg_pub.delete_msg();

EXCEPTION
   WHEN OTHERS THEN
      NULL;
END;

-----------------------------------------------------------------------------

FUNCTION get_mass_reval_info (p_mass_reval_id number) RETURN BOOLEAN IS

   -- mass reval info
   cursor c_mass_reval_info is
        select mrvl.BOOK_TYPE_CODE                  ,
               mrvl.DESCRIPTION                     ,
               mrvl.REVAL_DATE                      ,
               mrvl.DEFAULT_REVAL_FULLY_RSVD_FLAG   ,
               mrvl.DEFAULT_LIFE_EXTENSION_FACTOR   ,
               mrvl.DEFAULT_LIFE_EXTENSION_CEILING  ,
               mrvl.DEFAULT_MAX_FULLY_RSVD_REVALS   ,
               mrvl.STATUS                          ,
               mrvl.LAST_REQUEST_ID                 ,
               mrvl.ATTRIBUTE1                      ,
               mrvl.ATTRIBUTE2                      ,
               mrvl.ATTRIBUTE3                      ,
               mrvl.ATTRIBUTE4                      ,
               mrvl.ATTRIBUTE5                      ,
               mrvl.ATTRIBUTE6                      ,
               mrvl.ATTRIBUTE7                      ,
               mrvl.ATTRIBUTE8                      ,
               mrvl.ATTRIBUTE9                      ,
               mrvl.ATTRIBUTE10                     ,
               mrvl.ATTRIBUTE11                     ,
               mrvl.ATTRIBUTE12                     ,
               mrvl.ATTRIBUTE13                     ,
               mrvl.ATTRIBUTE14                     ,
               mrvl.ATTRIBUTE15                     ,
               mrvl.ATTRIBUTE_CATEGORY_CODE         ,
               mrvl.CREATED_BY                      ,
               mrvl.CREATION_DATE                   ,
               mrvl.LAST_UPDATED_BY                 ,
               mrvl.LAST_UPDATE_DATE                ,
               mrvl.LAST_UPDATE_LOGIN               ,
               mrvl.GLOBAL_ATTRIBUTE1               ,
               mrvl.GLOBAL_ATTRIBUTE2               ,
               mrvl.GLOBAL_ATTRIBUTE3               ,
               mrvl.GLOBAL_ATTRIBUTE4               ,
               mrvl.GLOBAL_ATTRIBUTE5               ,
               mrvl.GLOBAL_ATTRIBUTE6               ,
               mrvl.GLOBAL_ATTRIBUTE7               ,
               mrvl.GLOBAL_ATTRIBUTE8               ,
               mrvl.GLOBAL_ATTRIBUTE9               ,
               mrvl.GLOBAL_ATTRIBUTE10              ,
               mrvl.GLOBAL_ATTRIBUTE11              ,
               mrvl.GLOBAL_ATTRIBUTE12              ,
               mrvl.GLOBAL_ATTRIBUTE13              ,
               mrvl.GLOBAL_ATTRIBUTE14              ,
               mrvl.GLOBAL_ATTRIBUTE15              ,
               mrvl.GLOBAL_ATTRIBUTE16              ,
               mrvl.GLOBAL_ATTRIBUTE17              ,
               mrvl.GLOBAL_ATTRIBUTE18              ,
               mrvl.GLOBAL_ATTRIBUTE19              ,
               mrvl.GLOBAL_ATTRIBUTE20              ,
               mrvl.GLOBAL_ATTRIBUTE_CATEGORY       ,
               mrvl.REVALUE_CIP_ASSETS_FLAG
          from fa_mass_revaluations    mrvl
         where mrvl.mass_reval_id      = p_mass_reval_id;

   l_calling_fn                  VARCHAR2(60) := 'fa_mass_reval_pkg.get_mass_reval_info';
   massrvl_err                   exception;

BEGIN

   -- get the massrvl info
   open c_mass_reval_info;
   fetch c_mass_reval_info
    into G_book_type_code                  ,
         G_description                     ,
         G_reval_date                      ,
         G_def_reval_fully_rsvd_flag       ,
         G_def_life_extension_factor       ,
         G_def_life_extension_ceiling      ,
         G_def_max_fully_rsvd_revals       ,
         G_status                          ,
         G_last_request_id                 ,
         G_attribute1                      ,
         G_attribute2                      ,
         G_attribute3                      ,
         G_attribute4                      ,
         G_attribute5                      ,
         G_attribute6                      ,
         G_attribute7                      ,
         G_attribute8                      ,
         G_attribute9                      ,
         G_attribute10                     ,
         G_attribute11                     ,
         G_attribute12                     ,
         G_attribute13                     ,
         G_attribute14                     ,
         G_attribute15                     ,
         G_attribute_category_code         ,
         G_created_by                      ,
         G_creation_date                   ,
         G_last_updated_by                 ,
         G_last_update_date                ,
         G_last_update_login               ,
         G_global_attribute1               ,
         G_global_attribute2               ,
         G_global_attribute3               ,
         G_global_attribute4               ,
         G_global_attribute5               ,
         G_global_attribute6               ,
         G_global_attribute7               ,
         G_global_attribute8               ,
         G_global_attribute9               ,
         G_global_attribute10              ,
         G_global_attribute11              ,
         G_global_attribute12              ,
         G_global_attribute13              ,
         G_global_attribute14              ,
         G_global_attribute15              ,
         G_global_attribute16              ,
         G_global_attribute17              ,
         G_global_attribute18              ,
         G_global_attribute19              ,
         G_global_attribute20              ,
         G_global_attribute_category       ,
         G_def_revalue_cip_assets_flag     ;

      if (c_mass_reval_info%NOTFOUND) then
         close c_mass_reval_info;
         fa_srvr_msg.add_message
           (calling_fn => l_calling_fn,
            name       => 'FA_DATA_ERR_MASS_REVAL', p_log_level_rec => g_log_level_rec);
         raise massrvl_err;
      end if;
      close c_mass_reval_info;

      -- get book information
      if not fa_cache_pkg.fazcbc(X_book => g_book_type_code, p_log_level_rec => g_log_level_rec) then
         raise massrvl_err;
      end if;

      -- load the period struct for current period info
      if not FA_UTIL_PVT.get_period_rec
          (p_book           => G_book_type_code,
           p_effective_date => NULL,
           x_period_rec     => G_period_rec
           , p_log_level_rec => g_log_level_rec) then raise massrvl_err;
      end if;

      G_batch_size  := nvl(fa_cache_pkg.fa_batch_size, 1000);

      return true;

EXCEPTION
   WHEN massrvl_err THEN
      fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      return false;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      return false;

END get_mass_reval_info;

-----------------------------------------------------------------------------

-- This function will select all candidate transactions in a single
-- shot. The primary-- We will only stripe the worker number based
-- on asset_id as group/parent are irrelavant to reval

PROCEDURE allocate_workers (
                p_book_type_code     IN     VARCHAR2,
                p_mass_reval_id      IN     NUMBER,
                p_mode               IN     VARCHAR2,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                x_return_status         OUT NOCOPY NUMBER) AS


   -- local variables
   l_corp_period_rec            FA_API_TYPES.period_rec_type;
   l_tax_period_rec             FA_API_TYPES.period_rec_type;
   l_min_period_counter         number(15);

   l_calling_fn                 varchar2(40) := 'fa_mass_reval_pkg.allocate_workers';

   -- Used for bulk fetching
   massrvl_err                   exception;

BEGIN

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise  massrvl_err;
      end if;
   end if;

   g_release := fa_cache_pkg.fazarel_release;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'at beginning of', 'worker allocation', p_log_level_rec => g_log_level_rec);
   end if;

   x_return_status := 0;

   -- get mass reval info
   if not get_mass_reval_info (p_mass_reval_id => p_mass_reval_id) then
      raise massrvl_err;
   end if;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'inserting initial transactions at', sysdate, p_log_level_rec => g_log_level_rec);
   end if;

   -- NOTE: on first cursor, we do not want to insert category
   -- as it's used to indicate asset/category later on

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'rows inserted into fa_parallel_workers - asset based', sql%rowcount);
   end if;

   -- R12 conditional handling
   if (G_release = 11) then
      l_min_period_counter := G_period_rec.period_counter - 1;
   else
      l_min_period_counter := G_period_rec.period_counter;
   end if;

   -- asset based
   insert into fa_parallel_workers
                    (request_id                     ,
                     asset_id                       ,
                     asset_number                   ,
                     asset_type                     ,
                     -- asset_category_id              ,
                     book_type_code                 ,
                     worker_number                  ,
                     process_order                  ,
                     process_status                 )
   select p_parent_request_id,
          ad.asset_id,
          ad.asset_number,
          ad.asset_type,
          -- ad.asset_category_id,
          p_book_type_code,
          mod(ad.asset_id, p_total_requests) + 1,
          1,
          'UNPROCESSED'
    FROM fa_additions_b ad,
         fa_books bk,
         fa_deprn_summary ds,
         fa_mass_revaluation_rules rr
    WHERE rr.mass_reval_id = p_mass_reval_id
      AND rr.category_id IS NULL
      AND rr.asset_id is not null
      AND ad.asset_id = rr.asset_id
      AND bk.asset_id = rr.asset_id
      AND bk.book_type_code = G_book_type_code
      AND bk.transaction_header_id_out IS NULL
      AND bk.group_asset_id IS NULL
      AND bk.period_counter_fully_retired IS NULL
      AND NVL(bk.period_counter_fully_reserved, 99) = NVL(bk.
          period_counter_life_complete, 99)
      AND bk.conversion_date IS NULL
      AND ad.asset_type = DECODE(NVL(rr.revalue_cip_assets_flag,
                                     g_def_revalue_cip_assets_flag), NULL, 'CAPITALIZED', 'N', 'CAPITALIZED',
          ad.asset_type)
      AND ad.asset_type <> 'GROUP'
      AND ds.asset_id = rr.asset_id
      AND ds.book_type_code = G_book_type_code
      AND ds.deprn_source_code = 'BOOKS'
      AND ds.period_counter < l_min_period_counter
      AND NOT EXISTS (SELECT 1
                        FROM fa_books oldbk
                       WHERE oldbk.asset_id = rr.asset_id
                         AND oldbk.book_type_code = G_book_type_code
                         AND oldbk.date_ineffective IS NOT NULL
                         AND oldbk.group_asset_id IS NOT NULL)
      AND NOT EXISTS (SELECT 1
                        FROM fa_transaction_headers th_rev
                       WHERE th_rev.asset_id = rr.asset_id
                         AND th_rev.book_type_code = G_book_type_code
                         AND th_rev.transaction_type_code = 'REVALUATION'
                         AND th_rev.mass_transaction_id = p_mass_reval_id);

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'rows inserted into fa_parallel_workers2', sql%rowcount);
   end if;


   -- category based
   insert into fa_parallel_workers
                    (request_id                     ,
                     asset_id                       ,
                     asset_number                   ,
                     asset_type                     ,
                     asset_category_id              ,
                     book_type_code                 ,
                     worker_number                  ,
                     process_order                  ,
                     process_status                 )
   select p_parent_request_id,
          ad.asset_id,
          ad.asset_number,
          ad.asset_type,
          ad.asset_category_id,
          p_book_type_code,
          mod(ad.asset_id, p_total_requests) + 1,
          1,
          'UNPROCESSED'
     FROM fa_additions_b ad,
          fa_books bk,
          fa_deprn_summary ds,
          fa_mass_revaluation_rules rr
    WHERE rr.mass_reval_id  = p_mass_reval_id
      AND rr.category_id    = ad.asset_category_id
      AND rr.category_id   IS not NULL
      AND rr.asset_id      is null
      AND bk.asset_id       = ad.asset_id
      AND bk.book_type_code = G_book_type_code
      AND bk.transaction_header_id_out IS NULL
      AND bk.group_asset_id IS NULL
      AND bk.period_counter_fully_retired IS NULL
      AND NVL(bk.period_counter_fully_reserved, 99) =
          NVL(bk.period_counter_life_complete, 99)
      AND bk.conversion_date IS NULL
      AND ad.asset_type = DECODE(NVL(rr.revalue_cip_assets_flag,
                                     g_def_revalue_cip_assets_flag),
                                      NULL, 'CAPITALIZED',
                                     'N', 'CAPITALIZED',
                                     ad.asset_type)
      AND ad.asset_type <> 'GROUP'
      AND ds.asset_id = ad.asset_id
      AND ds.book_type_code = G_book_type_code
      AND ds.deprn_source_code = 'BOOKS'
      AND ds.period_counter < l_min_period_counter
      AND NOT EXISTS (SELECT 1
                          FROM fa_books oldbk
                          WHERE oldbk.asset_id = ad.asset_id
                            AND oldbk.book_type_code = G_book_type_code
                            AND oldbk.date_ineffective IS NOT NULL
                            AND oldbk.group_asset_id IS NOT NULL)
      AND NOT EXISTS (SELECT 1
                          FROM fa_transaction_headers th_rev
                          WHERE th_rev.asset_id = ad.asset_id
                            AND th_rev.book_type_code = G_book_type_code
                            AND th_rev.transaction_type_code = 'REVALUATION'
                            AND th_rev.mass_transaction_id = p_mass_reval_id)
      AND NOT EXISTS (SELECT 1
                        FROM fa_parallel_workers pw
                       WHERE pw.request_id = p_parent_request_id
                         AND pw.asset_id = ad.asset_id);

   FND_CONCURRENT.AF_COMMIT;

   X_return_status := 0;

EXCEPTION
   WHEN massrvl_err THEN
      FND_CONCURRENT.AF_ROLLBACK;
      fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      X_return_status := 2;

   WHEN OTHERS THEN
      FND_CONCURRENT.AF_ROLLBACK;
      fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      x_return_status := 2;

END allocate_workers;

----------------------------------------------------------------


END FA_MASS_REVAL_PKG;


/
