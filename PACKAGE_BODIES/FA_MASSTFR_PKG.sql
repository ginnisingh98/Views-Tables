--------------------------------------------------------
--  DDL for Package Body FA_MASSTFR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASSTFR_PKG" as
/* $Header: FAMTFRB.pls 120.12.12010000.5 2009/07/19 14:39:22 glchen ship $   */

g_log_level_rec fa_api_types.log_level_rec_type;

PROCEDURE do_mass_transfer (
                p_mass_transfer_id     IN     NUMBER,
                p_parent_request_id    IN     NUMBER,
                p_total_requests       IN     NUMBER,
                p_request_number       IN     NUMBER,
                px_max_asset_id        IN OUT NOCOPY NUMBER,
                x_success_count           OUT NOCOPY number,
                x_failure_count           OUT NOCOPY number,
                x_return_status           OUT NOCOPY number) IS


   -- used for bulk fetching
   l_batch_size                 number;

   l_count                      number;
   l_book_type_code             varchar2(30);
   l_trans_date			date;
   l_from_gl			number;
   l_from_loc			number;
   l_from_emp			number;
   l_to_gl			number;
   l_to_loc			number;
   l_to_emp			number;
   l_category_id                number;

   TYPE v30_tbl  IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
   TYPE num_tbl  IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;

   l_asset_number               v30_tbl;
   l_asset_id                   num_tbl;
   l_dist_id                    num_tbl;
   l_assigned_to                num_tbl;
   l_loc_id                     num_tbl;
   l_units_assigned             num_tbl;
   l_ccid			num_tbl;
   l_to_ccid			number;
   l_to_loc_id			number;
   l_to_emp_id			number;
   l_txn_units			number;
   l_success                    boolean;
   l_rowcount                   number;
   l_warn_status                boolean := FALSE;

   done_exc			EXCEPTION;
   mtfr_err			EXCEPTION;
   masstfr_err			EXCEPTION;


   -- variables and structs used for api call
   l_api_version                  NUMBER      := 1.0;
   l_init_msg_list                VARCHAR2(1) := FND_API.G_FALSE;
   l_commit                       VARCHAR2(1) := FND_API.G_FALSE;
   l_validation_level             NUMBER      := FND_API.G_VALID_LEVEL_FULL;
   l_return_status                VARCHAR2(1);
   l_msg_count                    number := 0;
   l_msg_data                     VARCHAR2(4000);
   l_calling_fn                   VARCHAR2(40) := 'fa_masstfr_pkg.do_mass_transfer';

   l_trans_rec                    FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec                FA_API_TYPES.asset_hdr_rec_type;
   l_asset_dist_tbl               FA_API_TYPES.asset_dist_tbl_type;

   -- mass transfer info

   cursor c_mass_tfr_info is
        SELECT famt.*
        FROM   FA_MASS_TRANSFERS  famt
        WHERE  MASS_TRANSFER_ID = p_mass_transfer_id;
   mtfr_rec                       fa_mass_transfers%ROWTYPE;

   cursor CUA_C1 is
      select faad.asset_id,
             faad.asset_number,
             fadh.distribution_id,
             fadh.assigned_to,
             fadh.location_id,
             fadh.code_combination_id,
             fadh.units_assigned
      from fa_books fabk,
           gl_code_combinations gcc,
           fa_additions_b faad,
           fa_distribution_history fadh
      where    (fadh.code_combination_id = gcc.code_combination_id)
      AND (fadh.asset_id = faad.asset_id)
      AND (fabk.asset_id = faad.asset_id)
      AND (fadh.book_type_code = l_book_type_code)
      AND (fabk.book_type_code = fadh.book_type_code)
      AND (faad.asset_category_id = nvl(l_category_id,faad.asset_category_id))
      AND (faad.asset_type <> 'GROUP')
      AND (nvl(l_from_loc,fadh.location_id) = fadh.location_id)
      AND (nvl(l_from_emp,nvl(fadh.assigned_to,-99)) = nvl(fadh.assigned_to,-99))
      AND (fadh.transaction_header_id_out is null)
      AND (fadh.retirement_id is null)
      AND (fabk.date_ineffective is null)
      AND (fabk.period_counter_fully_retired is null)
      AND (gcc.segment1 is NULL or
           gcc.segment1 BETWEEN nvl(mtfr_rec.segment1_Low,gcc.segment1) AND nvl(mtfr_rec.segment1_High,gcc.segment1))
      AND (gcc.segment2 is NULL or
           gcc.segment2 BETWEEN nvl(mtfr_rec.segment2_Low,gcc.segment2) AND nvl(mtfr_rec.segment2_High,gcc.segment2))
      AND (gcc.segment3 is NULL or
           gcc.segment3 BETWEEN nvl(mtfr_rec.segment3_Low,gcc.segment3) AND nvl(mtfr_rec.segment3_High,gcc.segment3))
      AND (gcc.segment4 is NULL or
           gcc.segment4 BETWEEN nvl(mtfr_rec.segment4_Low,gcc.segment4) AND nvl(mtfr_rec.segment4_High,gcc.segment4))
      AND (gcc.segment5 is NULL or
           gcc.segment5 BETWEEN nvl(mtfr_rec.segment5_Low,gcc.segment5) AND nvl(mtfr_rec.segment5_High,gcc.segment5))
      AND (gcc.segment6 is NULL or
           gcc.segment6 BETWEEN nvl(mtfr_rec.segment6_Low,gcc.segment6) AND nvl(mtfr_rec.segment6_High,gcc.segment6))
      AND (gcc.segment7 is NULL or
           gcc.segment7 BETWEEN nvl(mtfr_rec.segment7_Low,gcc.segment7) AND nvl(mtfr_rec.segment7_High,gcc.segment7))
      AND (gcc.segment8 is NULL or
           gcc.segment8 BETWEEN nvl(mtfr_rec.segment8_Low,gcc.segment8) AND nvl(mtfr_rec.segment8_High,gcc.segment8))
      AND (gcc.segment9 is NULL or
           gcc.segment9 BETWEEN nvl(mtfr_rec.segment9_Low,gcc.segment9) AND nvl(mtfr_rec.segment9_High,gcc.segment9))
      AND (gcc.segment10 is NULL or
           gcc.segment10 BETWEEN nvl(mtfr_rec.segment10_Low,gcc.segment10) AND nvl(mtfr_rec.segment10_High,gcc.segment10))
      AND (gcc.segment11 is NULL or
           gcc.segment11 BETWEEN nvl(mtfr_rec.segment11_Low,gcc.segment11) AND nvl(mtfr_rec.segment11_High,gcc.segment11))
      AND (gcc.segment12 is NULL or
           gcc.segment12 BETWEEN nvl(mtfr_rec.segment12_Low,gcc.segment12) AND nvl(mtfr_rec.segment12_High,gcc.segment12))
      AND (gcc.segment13 is NULL or
           gcc.segment13 BETWEEN nvl(mtfr_rec.segment13_Low,gcc.segment13) AND nvl(mtfr_rec.segment13_High,gcc.segment13))
      AND (gcc.segment14 is NULL or
           gcc.segment14 BETWEEN nvl(mtfr_rec.segment14_Low,gcc.segment14) AND nvl(mtfr_rec.segment14_High,gcc.segment14))
      AND (gcc.segment15 is NULL or
           gcc.segment15 BETWEEN nvl(mtfr_rec.segment15_Low,gcc.segment15) AND nvl(mtfr_rec.segment15_High,gcc.segment15))
      AND (gcc.segment16 is NULL or
           gcc.segment16 BETWEEN nvl(mtfr_rec.segment16_Low,gcc.segment16) AND nvl(mtfr_rec.segment16_High,gcc.segment16))
      AND (gcc.segment17 is NULL or
           gcc.segment17 BETWEEN nvl(mtfr_rec.segment17_Low,gcc.segment17) AND nvl(mtfr_rec.segment17_High,gcc.segment17))
      AND (gcc.segment18 is NULL or
           gcc.segment18 BETWEEN nvl(mtfr_rec.segment18_Low,gcc.segment18) AND nvl(mtfr_rec.segment18_High,gcc.segment18))
      AND (gcc.segment19 is NULL or
           gcc.segment19 BETWEEN nvl(mtfr_rec.segment19_Low,gcc.segment19) AND nvl(mtfr_rec.segment19_High,gcc.segment19))
      AND (gcc.segment20 is NULL or
           gcc.segment20 BETWEEN nvl(mtfr_rec.segment20_Low,gcc.segment20) AND nvl(mtfr_rec.segment20_High,gcc.segment20))
      AND (gcc.segment21 is NULL or
           gcc.segment21 BETWEEN nvl(mtfr_rec.segment21_Low,gcc.segment21) AND nvl(mtfr_rec.segment21_High,gcc.segment21))
      AND (gcc.segment22 is NULL or
           gcc.segment22 BETWEEN nvl(mtfr_rec.segment22_Low,gcc.segment22) AND nvl(mtfr_rec.segment22_High,gcc.segment22))
      AND (gcc.segment23 is NULL or
           gcc.segment23 BETWEEN nvl(mtfr_rec.segment23_Low,gcc.segment23) AND nvl(mtfr_rec.segment23_High,gcc.segment23))
      AND (gcc.segment24 is NULL or
           gcc.segment24 BETWEEN nvl(mtfr_rec.segment24_Low,gcc.segment24) AND nvl(mtfr_rec.segment24_High,gcc.segment24))
      AND (gcc.segment25 is NULL or
           gcc.segment25 BETWEEN nvl(mtfr_rec.segment25_Low,gcc.segment25) AND nvl(mtfr_rec.segment25_High,gcc.segment25))
      AND (gcc.segment26 is NULL or
           gcc.segment26 BETWEEN nvl(mtfr_rec.segment26_Low,gcc.segment26) AND nvl(mtfr_rec.segment26_High,gcc.segment26))
      AND (gcc.segment27 is NULL or
           gcc.segment27 BETWEEN nvl(mtfr_rec.segment27_Low,gcc.segment27) AND nvl(mtfr_rec.segment27_High,gcc.segment27))
      AND (gcc.segment28 is NULL or
           gcc.segment28 BETWEEN nvl(mtfr_rec.segment28_Low,gcc.segment28) AND nvl(mtfr_rec.segment28_High,gcc.segment28))
      AND (gcc.segment29 is NULL or
           gcc.segment29 BETWEEN nvl(mtfr_rec.segment29_Low,gcc.segment29) AND nvl(mtfr_rec.segment29_High,gcc.segment29))
      AND (gcc.segment30 is NULL or
           gcc.segment30 BETWEEN nvl(mtfr_rec.segment30_Low,gcc.segment30) AND nvl(mtfr_rec.segment30_High,gcc.segment30))
      AND not exists (select 1
                      from   FA_ASSET_HIERARCHY ASH
                      where  ASH.ASSET_ID            = FAAD.ASSET_ID
                      and    ASH.PARENT_HIERARCHY_ID is not null)
      AND faad.asset_id > px_max_asset_id
      AND MOD(faad.asset_id, p_total_requests) = (p_request_number - 1)
      order by faad.asset_id;


   cursor C1 is
      select faad.asset_id,
             faad.asset_number,
             fadh.distribution_id,
             fadh.assigned_to,
             fadh.location_id,
             fadh.code_combination_id,
             fadh.units_assigned
      from fa_books fabk,
           fa_additions_b faad,
           gl_code_combinations gcc,
           fa_distribution_history fadh
      where (fadh.code_combination_id = gcc.code_combination_id)
      AND (fadh.asset_id = faad.asset_id)
      AND (fabk.asset_id = faad.asset_id)
      AND (fadh.book_type_code = l_book_type_code)
      AND (fabk.book_type_code = fadh.book_type_code)
      AND (faad.asset_category_id = nvl(l_category_id,faad.asset_category_id))
      AND (faad.asset_type <> 'GROUP')
      AND (nvl(l_from_loc,fadh.location_id) = fadh.location_id)
      AND (nvl(l_from_emp,nvl(fadh.assigned_to,-99)) = nvl(fadh.assigned_to,-99))
      AND (fadh.transaction_header_id_out is null)
      AND (fadh.retirement_id is null)
      AND (fabk.date_ineffective is null)
      AND (fabk.period_counter_fully_retired is null)
      AND (gcc.segment1 is NULL or
           gcc.segment1 BETWEEN nvl(mtfr_rec.segment1_Low,gcc.segment1) AND nvl(mtfr_rec.segment1_High,gcc.segment1))
      AND (gcc.segment2 is NULL or
           gcc.segment2 BETWEEN nvl(mtfr_rec.segment2_Low,gcc.segment2) AND nvl(mtfr_rec.segment2_High,gcc.segment2))
      AND (gcc.segment3 is NULL or
           gcc.segment3 BETWEEN nvl(mtfr_rec.segment3_Low,gcc.segment3) AND nvl(mtfr_rec.segment3_High,gcc.segment3))
      AND (gcc.segment4 is NULL or
           gcc.segment4 BETWEEN nvl(mtfr_rec.segment4_Low,gcc.segment4) AND nvl(mtfr_rec.segment4_High,gcc.segment4))
      AND (gcc.segment5 is NULL or
           gcc.segment5 BETWEEN nvl(mtfr_rec.segment5_Low,gcc.segment5) AND nvl(mtfr_rec.segment5_High,gcc.segment5))
      AND (gcc.segment6 is NULL or
           gcc.segment6 BETWEEN nvl(mtfr_rec.segment6_Low,gcc.segment6) AND nvl(mtfr_rec.segment6_High,gcc.segment6))
      AND (gcc.segment7 is NULL or
           gcc.segment7 BETWEEN nvl(mtfr_rec.segment7_Low,gcc.segment7) AND nvl(mtfr_rec.segment7_High,gcc.segment7))
      AND (gcc.segment8 is NULL or
           gcc.segment8 BETWEEN nvl(mtfr_rec.segment8_Low,gcc.segment8) AND nvl(mtfr_rec.segment8_High,gcc.segment8))
      AND (gcc.segment9 is NULL or
           gcc.segment9 BETWEEN nvl(mtfr_rec.segment9_Low,gcc.segment9) AND nvl(mtfr_rec.segment9_High,gcc.segment9))
      AND (gcc.segment10 is NULL or
           gcc.segment10 BETWEEN nvl(mtfr_rec.segment10_Low,gcc.segment10) AND nvl(mtfr_rec.segment10_High,gcc.segment10))
      AND (gcc.segment11 is NULL or
           gcc.segment11 BETWEEN nvl(mtfr_rec.segment11_Low,gcc.segment11) AND nvl(mtfr_rec.segment11_High,gcc.segment11))
      AND (gcc.segment12 is NULL or
           gcc.segment12 BETWEEN nvl(mtfr_rec.segment12_Low,gcc.segment12) AND nvl(mtfr_rec.segment12_High,gcc.segment12))
      AND (gcc.segment13 is NULL or
           gcc.segment13 BETWEEN nvl(mtfr_rec.segment13_Low,gcc.segment13) AND nvl(mtfr_rec.segment13_High,gcc.segment13))
      AND (gcc.segment14 is NULL or
           gcc.segment14 BETWEEN nvl(mtfr_rec.segment14_Low,gcc.segment14) AND nvl(mtfr_rec.segment14_High,gcc.segment14))
      AND (gcc.segment15 is NULL or
           gcc.segment15 BETWEEN nvl(mtfr_rec.segment15_Low,gcc.segment15) AND nvl(mtfr_rec.segment15_High,gcc.segment15))
      AND (gcc.segment16 is NULL or
           gcc.segment16 BETWEEN nvl(mtfr_rec.segment16_Low,gcc.segment16) AND nvl(mtfr_rec.segment16_High,gcc.segment16))
      AND (gcc.segment17 is NULL or
           gcc.segment17 BETWEEN nvl(mtfr_rec.segment17_Low,gcc.segment17) AND nvl(mtfr_rec.segment17_High,gcc.segment17))
      AND (gcc.segment18 is NULL or
           gcc.segment18 BETWEEN nvl(mtfr_rec.segment18_Low,gcc.segment18) AND nvl(mtfr_rec.segment18_High,gcc.segment18))
      AND (gcc.segment19 is NULL or
           gcc.segment19 BETWEEN nvl(mtfr_rec.segment19_Low,gcc.segment19) AND nvl(mtfr_rec.segment19_High,gcc.segment19))
      AND (gcc.segment20 is NULL or
           gcc.segment20 BETWEEN nvl(mtfr_rec.segment20_Low,gcc.segment20) AND nvl(mtfr_rec.segment20_High,gcc.segment20))
      AND (gcc.segment21 is NULL or
           gcc.segment21 BETWEEN nvl(mtfr_rec.segment21_Low,gcc.segment21) AND nvl(mtfr_rec.segment21_High,gcc.segment21))
      AND (gcc.segment22 is NULL or
           gcc.segment22 BETWEEN nvl(mtfr_rec.segment22_Low,gcc.segment22) AND nvl(mtfr_rec.segment22_High,gcc.segment22))
      AND (gcc.segment23 is NULL or
           gcc.segment23 BETWEEN nvl(mtfr_rec.segment23_Low,gcc.segment23) AND nvl(mtfr_rec.segment23_High,gcc.segment23))
      AND (gcc.segment24 is NULL or
           gcc.segment24 BETWEEN nvl(mtfr_rec.segment24_Low,gcc.segment24) AND nvl(mtfr_rec.segment24_High,gcc.segment24))
      AND (gcc.segment25 is NULL or
           gcc.segment25 BETWEEN nvl(mtfr_rec.segment25_Low,gcc.segment25) AND nvl(mtfr_rec.segment25_High,gcc.segment25))
      AND (gcc.segment26 is NULL or
           gcc.segment26 BETWEEN nvl(mtfr_rec.segment26_Low,gcc.segment26) AND nvl(mtfr_rec.segment26_High,gcc.segment26))
      AND (gcc.segment27 is NULL or
           gcc.segment27 BETWEEN nvl(mtfr_rec.segment27_Low,gcc.segment27) AND nvl(mtfr_rec.segment27_High,gcc.segment27))
      AND (gcc.segment28 is NULL or
           gcc.segment28 BETWEEN nvl(mtfr_rec.segment28_Low,gcc.segment28) AND nvl(mtfr_rec.segment28_High,gcc.segment28))
      AND (gcc.segment29 is NULL or
           gcc.segment29 BETWEEN nvl(mtfr_rec.segment29_Low,gcc.segment29) AND nvl(mtfr_rec.segment29_High,gcc.segment29))
      AND (gcc.segment30 is NULL or
           gcc.segment30 BETWEEN nvl(mtfr_rec.segment30_Low,gcc.segment30) AND nvl(mtfr_rec.segment30_High,gcc.segment30))
      AND faad.asset_id > px_max_asset_id
      AND MOD(faad.asset_id, p_total_requests) = (p_request_number - 1)
      order by faad.asset_id;


BEGIN

   px_max_asset_id := nvl(px_max_asset_id, 0);
   x_success_count := 0;
   x_failure_count := 0;

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise  masstfr_err;
      end if;
   end if;

   open c_mass_tfr_info;
   fetch c_mass_tfr_info into mtfr_rec;

   if (c_mass_tfr_info%NOTFOUND) then
      close c_mass_tfr_info;
      raise masstfr_err;
   end if;
   close c_mass_tfr_info;

   l_book_type_code := mtfr_rec.book_type_code;
   l_trans_date := mtfr_rec.transaction_date_entered;
   l_from_gl := mtfr_rec.from_gl_ccid;
   l_from_loc := mtfr_rec.from_location_id;
   l_from_emp := mtfr_rec.from_employee_id;
   l_to_gl := mtfr_rec.to_gl_ccid;
   l_to_loc := mtfr_rec.to_location_id;
   l_to_emp := mtfr_rec.to_employee_id;
   l_category_id := mtfr_rec.category_id;

   if not fa_cache_pkg.fazcbc(X_book => l_book_type_code, p_log_level_rec => g_log_level_rec) then
      raise masstfr_err;
   end if;

   l_batch_size := nvl(fa_cache_pkg.fa_batch_size, 200);

   --dbms_output.put_line(to_char(l_category_id));
   --dbms_output.put_line('before OPEN CURSOR');

   if (fa_cache_pkg.fa_crl_enabled) then
      OPEN CUA_C1;
      FETCH CUA_C1 BULK COLLECT INTO
          l_asset_id,
          l_asset_number,
          l_dist_id,
          l_assigned_to,
          l_loc_id,
          l_ccid,
          l_units_assigned
      LIMIT l_batch_size;
      close CUA_C1;
   else
      OPEN C1;
      FETCH C1 BULK COLLECT INTO
           l_asset_id,
           l_asset_number,
           l_dist_id,
           l_assigned_to,
           l_loc_id,
           l_ccid,
           l_units_assigned
      LIMIT l_batch_size;
      close C1;
   end if;

   if l_asset_id.count = 0 then
         raise done_exc;
   end if;

   --dbms_output.put_line('after the fetch');
   for l_count in 1..l_asset_id.count loop

      -- clear the debug stack for each asset
      FA_DEBUG_PKG.Initialize;
      -- reset the message level to prevent bogus errors
      FA_SRVR_MSG.Set_Message_Level(message_level => 10, p_log_level_rec => g_log_level_rec);

      BEGIN

         -- if partial segments were entered for destination
         -- call famtgcc to generate new ccid(l_to_ccid)
         if (l_to_gl is null) then
             l_to_ccid := -99; -- set to -99 for NULL for famtgcc below to work correctly
             l_success := FA_MASS_TRANSFERS_PKG.famtgcc(
                               x_mass_transfer_id => p_mass_transfer_id,
                               x_from_glccid      => l_ccid(l_count),
                               x_to_glccid        => l_to_ccid,
                               p_Log_level_rec    => g_log_level_rec);
             if (not l_success) then
                 raise mtfr_err;
             end if;
             if (l_to_ccid is null) then
                raise mtfr_err;
             end if;
         else
            l_to_ccid := l_to_gl;
         end if;

         if (l_to_loc is not null) then
            l_to_loc_id := l_to_loc;
         else
            l_to_loc_id := l_loc_id(l_count);
         end if;

         if (l_to_emp is not null) then
            l_to_emp_id := l_to_emp;
         else
            l_to_emp_id := l_assigned_to(l_count);

            /* fix 2783537 - null out assigned_to column when invalid
               employee is encountered. Also return warning status to calling program */

            if (l_assigned_to(l_count) is not null) then
               select count(*)
               into l_rowcount
               from per_periods_of_service s, per_people_f p
               where p.person_id = s.person_id
               and trunc(l_trans_date) between
               p.effective_start_date and p.effective_end_date
               and nvl(s.actual_termination_date,l_trans_date) >= l_trans_date
               and p.person_id = l_assigned_to(l_count);
               if (l_rowcount = 0) then
                  l_to_emp_id := NULL;  -- null out invalid employees
                  fa_srvr_msg.add_message(
                      calling_fn => NULL,
                      name       => 'FA_INVALID_ASSIGNED_TO',
		      token1     => 'ASSET_NUMBER',
                      value1     => l_asset_number(l_count),
                      token2     => 'ASSIGNED_TO',
                      value2     => l_assigned_to(l_count),
                      p_log_level_rec => g_log_level_rec);
                      l_warn_status := TRUE;
               end if;
            end if;
         end if;


         l_trans_rec                    := NULL;
         l_asset_hdr_rec                := NULL;
         l_asset_dist_tbl.delete;

         l_trans_rec.who_info.last_update_date   := sysdate;
         l_trans_rec.who_info.last_updated_by    := FND_GLOBAL.USER_ID;
         l_trans_rec.who_info.created_by         := FND_GLOBAL.USER_ID;
         l_trans_rec.who_info.creation_date      := sysdate;
         l_trans_rec.who_info.last_update_login  := FND_GLOBAL.CONC_LOGIN_ID;

         l_trans_rec.mass_reference_id           := p_parent_request_id;
         l_trans_rec.mass_transaction_id         := p_mass_transfer_id;
         l_trans_rec.calling_interface           := 'FAMTFR';

         l_trans_rec.transaction_date_entered     := l_trans_date;

         l_trans_rec.transaction_name             := substr(mtfr_rec.description, 1, 30); --bug7126485

         l_asset_hdr_rec.asset_id                 := l_asset_id(l_count);
         l_asset_hdr_rec.book_type_code           := l_book_type_code;

         l_txn_units := l_units_assigned(l_count);

         l_asset_dist_tbl(1).distribution_id := l_dist_id(l_count);
         l_asset_dist_tbl(1).transaction_units := -1 * l_txn_units;

         l_asset_dist_tbl(2).transaction_units := l_txn_units;
         l_asset_dist_tbl(2).assigned_to := l_to_emp_id;
         l_asset_dist_tbl(2).location_ccid := l_to_loc_id;
         l_asset_dist_tbl(2).expense_ccid := l_to_ccid;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add('FAMTFR','tbl-1:dist_id',l_asset_dist_tbl(1).distribution_id);
            fa_debug_pkg.add('FAMTFR','tbl-1:txn_units',l_asset_dist_tbl(1).transaction_units);
            fa_debug_pkg.add('FAMTFR','tbl-1:assignto',l_asset_dist_tbl(1).assigned_to);
            fa_debug_pkg.add('FAMTFR','tbl-1:loc_id',l_asset_dist_tbl(1).location_ccid);
            fa_debug_pkg.add('FAMTFR','tbl-1:exp_id',l_asset_dist_tbl(1).expense_ccid);

            fa_debug_pkg.add('FAMTFR','tbl-2:dist_id',l_asset_dist_tbl(2).distribution_id);
            fa_debug_pkg.add('FAMTFR','tbl-2:txn_units',l_asset_dist_tbl(2).transaction_units);
            fa_debug_pkg.add('FAMTFR','tbl-2:assignto',l_asset_dist_tbl(2).assigned_to);
            fa_debug_pkg.add('FAMTFR','tbl-2:loc_id',l_asset_dist_tbl(2).location_ccid);
            fa_debug_pkg.add('FAMTFR','tbl-2:exp_id',l_asset_dist_tbl(2).expense_ccid);
         end if;
         --dbms_output.put_line('before fa_transfer_pub');
         FA_TRANSFER_PUB.do_transfer
                     (p_api_version       => l_api_version,
                      p_init_msg_list     => l_init_msg_list,
                      p_commit            => l_commit,
                      p_validation_level  => l_validation_level,
                      x_return_status     => l_return_status,
                      x_msg_count         => l_msg_count,
                      x_msg_data          => l_msg_data,
                      p_calling_fn        => l_calling_fn,
                      px_trans_rec        => l_trans_rec,
                      px_asset_hdr_rec    => l_asset_hdr_rec,
                      px_asset_dist_tbl   => l_asset_dist_tbl);

         if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
           raise mtfr_err;
         end if;

         --dbms_output.put_line('after fa_transfer_pub');
         x_success_count := x_success_count + 1;
             fa_srvr_msg.add_message(
                calling_fn => NULL,
                name       => 'FA_TAXUP_ASSET_SUCCESS',
                token1     => 'NUMBER',
                value1     => l_asset_number(l_count),
                p_log_level_rec => g_log_level_rec);

      EXCEPTION
         when mtfr_err then
               --dbms_output.put_line('when mtfr_err');
               FND_CONCURRENT.AF_ROLLBACK;
               if (g_log_level_rec.statement_level) then
                  fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
               end if;
               x_failure_count := x_failure_count + 1;
               fa_srvr_msg.add_message(
                  calling_fn => l_calling_fn,
                  name       => 'FA_TAXUP_ASSET_FAILURE',
                  token1     => 'NUMBER',
                  value1     => l_asset_number(l_count),
                  p_log_level_rec => g_log_level_rec);

         when others then
               --dbms_output.put_line('when others');
               FND_CONCURRENT.AF_ROLLBACK;
               if (g_log_level_rec.statement_level) then
                  fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
               end if;
               x_failure_count := x_failure_count + 1;
               fa_srvr_msg.add_message(
                  calling_fn => l_calling_fn,
                  name       => 'FA_TAXUP_ASSET_FAILURE',
                  token1     => 'NUMBER',
                  value1     => l_asset_number(l_count),
                  p_log_level_rec => g_log_level_rec);
      END;

      -- FND_CONCURRENT.AF_COMMIT each record
      FND_CONCURRENT.AF_COMMIT;

   end loop;  -- main bulk fetch loop

   --dbms_output.put_line('after loop');
   px_max_asset_id := l_asset_id(l_asset_id.count);
   if (l_warn_status) then
      x_return_status := 1;  -- return warning
   else
      x_return_status := 0;  -- success
   end if;

EXCEPTION
   when done_exc then
     --dbms_output.put_line('when done_exc');
   if (l_warn_status) then
      x_return_status := 1;
   else
      x_return_status :=  0;
   end if;

   when masstfr_err then
      --dbms_output.put_line('when masstfr_err 2');
      FND_CONCURRENT.AF_ROLLBACK;
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      if (g_log_level_rec.statement_level) then
         FA_DEBUG_PKG.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;
      x_return_status :=  2;

   when others then
      --dbms_output.put_line('when others then');
      FND_CONCURRENT.AF_ROLLBACK;
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      x_return_status :=  2;

END do_mass_transfer;

END FA_MASSTFR_PKG;

/
