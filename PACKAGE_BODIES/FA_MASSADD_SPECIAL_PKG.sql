--------------------------------------------------------
--  DDL for Package Body FA_MASSADD_SPECIAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASSADD_SPECIAL_PKG" as
/* $Header: FAMADSB.pls 120.4.12010000.2 2009/07/19 14:47:35 glchen ship $   */

g_log_level_rec fa_api_types.log_level_rec_type;

PROCEDURE Do_Validation
            (p_posting_status    IN     VARCHAR2,
             p_mass_add_rec      IN     FA_MASS_ADDITIONS%ROWTYPE,
             x_return_status        OUT NOCOPY VARCHAR2
            ) IS

   l_inv                    number;
   l_dist                   number;

   l_trans_rec              FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec          FA_API_TYPES.asset_hdr_rec_type;
   l_asset_desc_rec         FA_API_TYPES.asset_desc_rec_type;
   l_asset_type_rec         FA_API_TYPES.asset_type_rec_type;
   l_asset_cat_rec          FA_API_TYPES.asset_cat_rec_type;
   l_asset_fin_rec          FA_API_TYPES.asset_fin_rec_type;
   l_asset_deprn_rec        FA_API_TYPES.asset_deprn_rec_type;
   l_asset_dist_rec         FA_API_TYPES.asset_dist_rec_type;
   l_asset_dist_tbl         FA_API_TYPES.asset_dist_tbl_type;
   l_inv_tbl                FA_API_TYPES.inv_tbl_type;

/* Added Following two variables for bug 6597560 */
   l_method_code	    VARCHAR2(12);
   l_life		    integer;

   l_calling_fn             varchar2(40) := 'fa_massadd_special_pkg.do_validation';
   error_found              exception;

   CURSOR c_distributions IS
     select mad.units,
            mad.employee_id,
            mad.deprn_expense_ccid,
            mad.location_id
       from fa_massadd_distributions mad
      where mad.mass_addition_id = p_mass_add_rec.mass_addition_id
      union all
     select mad.units,
            mad.employee_id,
            mad.deprn_expense_ccid,
            mad.location_id
       from fa_massadd_distributions mad,
            fa_mass_additions mac,
            fa_mass_additions map
      where map.sum_units = 'YES'
        and map.mass_addition_id = p_mass_add_rec.mass_addition_id
        and map.mass_addition_id = mac.merge_parent_mass_additions_id
        and mad.mass_addition_id = mac.mass_addition_id;

BEGIN

   -- determine type of transaction and do appropriate validation
   if (p_mass_add_rec.add_to_asset_id is not null) then

      -- verify the add_to_asset exists in the book and is not fully retired
      if not fa_asset_val_pvt.validate_asset_book
             (p_transaction_type_code  => 'ADJUSTMENT',
              p_book_type_code         => p_mass_add_rec.book_type_code,
              p_asset_id               => p_mass_add_rec.add_to_asset_id,
              p_calling_fn             => l_calling_fn, p_log_level_rec => g_log_level_rec) then raise error_found;
      end if;

      if (p_mass_add_rec.transaction_type_code = 'FUTURE CAP' or
          p_mass_add_rec.transaction_type_code = 'FUTURE REV') then
         -- future capitalization and reversal
         null;
      else
         -- for add to asset lines with new master set
         if (p_mass_add_rec.New_Master_Flag = 'YES') then
            if (p_mass_add_rec.Description is NULL or
                p_mass_add_rec.Asset_Category_ID is NULL) then
               raise error_found;
            else
               if not fa_asset_val_pvt.validate_category
                      (p_transaction_type_code  => 'ADDITION',  -- needed
                       p_category_id            => p_mass_add_rec.asset_category_id,
                       p_book_type_code         => p_mass_add_rec.book_type_code,
                       p_calling_fn             => l_calling_fn, p_log_level_rec => g_log_level_rec) then raise error_found;
               end if;
            end if;
         end if;

         -- also verify amortized flag (book level and existing trx)
         -- (from mass_additions_3.S_Amortize_Flag)
         if (nvl(p_mass_add_rec.amortize_flag, 'NO') = 'YES') then
            if (fa_cache_pkg.fazcbc_record.amortize_flag <> 'YES') then
               raise error_found;
            end if;
         else
            if not fa_asset_val_pvt.validate_exp_after_amort
                   (p_asset_id => p_mass_add_rec.add_to_asset_id,
                    p_book     => p_mass_add_rec.book_type_code, p_log_level_rec => g_log_level_rec) then raise error_found;
            end if;
         end if;
      end if;
   else

      -- addition and future addition
      l_trans_rec.transaction_type_code        := 'ADDITION';
      l_trans_rec.calling_interface            := 'POST_ALL';
      l_asset_hdr_rec.asset_id                 := p_mass_add_rec.asset_id;
      l_asset_hdr_rec.book_type_code           := p_mass_add_rec.book_type_code;
      l_asset_desc_rec.asset_number            := p_mass_add_rec.asset_number;
      l_asset_desc_rec.current_units           := p_mass_add_rec.fixed_assets_units;  -- merges / sum units?
      l_asset_desc_rec.lease_id                := p_mass_add_rec.lease_id;
      l_asset_desc_rec.warranty_id             := p_mass_add_rec.warranty_id;
      l_asset_desc_rec.property_type_code      := p_mass_add_rec.property_type_code;
      l_asset_desc_rec.property_1245_1250_code := p_mass_add_rec.property_1245_1250_code;
      l_asset_desc_rec.in_use_flag             := p_mass_add_rec.in_use_flag;
      l_asset_desc_rec.owned_leased            := p_mass_add_rec.owned_leased;
      l_asset_desc_rec.new_used                := p_mass_add_rec.new_used;
      l_asset_desc_rec.asset_key_ccid          := p_mass_add_rec.asset_key_ccid;

      l_asset_type_rec.asset_type              := p_mass_add_rec.asset_type;
      l_asset_cat_rec.category_id              := p_mass_add_rec.asset_category_id;

      -- load the fin info - we should account for merged impacts and load the merged lines here?
      l_asset_fin_rec.cost                     := 0;
      l_asset_fin_rec.date_placed_in_service   := p_mass_add_rec.date_placed_in_service;
      l_asset_fin_rec.depreciate_flag          := p_mass_add_rec.depreciate_flag;
      l_asset_fin_rec.deprn_method_code        := p_mass_add_rec.deprn_method_code;
      l_asset_fin_rec.life_in_months           := p_mass_add_rec.life_in_months;
	l_asset_fin_rec.nbv_at_switch			   := p_mass_add_rec.nbv_at_switch ;
	l_asset_fin_rec.prior_deprn_limit_type		   := p_mass_add_rec.prior_deprn_limit_type;
	l_asset_fin_rec.prior_deprn_limit_amount	   := p_mass_add_rec.prior_deprn_limit_amount;
	l_asset_fin_rec.prior_deprn_limit		   := p_mass_add_rec.prior_deprn_limit;
	l_asset_fin_rec.period_full_reserve		   := p_mass_add_rec.period_full_reserve;
	l_asset_fin_rec.period_extd_deprn		   := p_mass_add_rec.period_extd_deprn;
	l_asset_fin_rec.prior_deprn_method		   := p_mass_add_rec.prior_deprn_method;
	l_asset_fin_rec.prior_life_in_months		   := p_mass_add_rec.prior_life_in_months;
	l_asset_fin_rec.prior_basic_rate		   := p_mass_add_rec.prior_basic_rate;
	l_asset_fin_rec.prior_adjusted_rate		   := p_mass_add_rec.prior_adjusted_rate;

      IF l_asset_fin_rec.deprn_method_code IS NULL THEN   --- Added by Satish Byreddy for the Bug 7002804.
	/* Fix for bug 6597560 Starts here */
	BEGIN
		SELECT	deprn_method,life_in_months
		INTO	l_method_code, l_life
		FROM	fa_category_book_defaults
		WHERE   book_type_code =p_mass_add_rec.book_type_code
		AND	category_id = p_mass_add_rec.asset_category_id
	/* Fix for bug 6884668 Starts here */ -- When multiple defaults exist for different from-date to-date ranges, pick correct one based on DPIS
		AND	p_mass_add_rec.date_placed_in_service BETWEEN start_dpis AND NVL(end_dpis,p_mass_add_rec.date_placed_in_service + 1);
	/* Fix for bug 6884668 Ends here */
		l_asset_fin_rec.deprn_method_code:= l_method_code;
		l_asset_fin_rec.life_in_months := l_life;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
	END;
	/* Fix for bug 6597560 Ends here */
      END IF;
      -- load the distributions
      l_dist := 0;
      open c_distributions;
      loop
         l_dist := l_dist + 1;
         fetch c_distributions into
            l_asset_dist_rec.units_assigned,
            l_asset_dist_rec.assigned_to,
            l_asset_dist_rec.expense_ccid,
            l_asset_dist_rec.location_ccid;
         if (c_distributions%NOTFOUND) then
            exit;
         end if;
         l_asset_dist_tbl(l_dist) := l_asset_dist_rec;
      end loop;
      close c_distributions;

      if not fa_asset_val_pvt.validate
         (p_trans_rec          => l_trans_rec,
          p_asset_hdr_rec      => l_asset_hdr_rec,
          p_asset_desc_rec     => l_asset_desc_rec,
          p_asset_type_rec     => l_asset_type_rec,
          p_asset_cat_rec      => l_asset_cat_rec,
          p_asset_fin_rec      => l_asset_fin_rec,
          p_asset_deprn_rec    => l_asset_deprn_rec,
          p_asset_dist_tbl     => l_asset_dist_tbl,
          p_inv_tbl            => l_inv_tbl,
          p_calling_fn         => l_calling_fn
         , p_log_level_rec => g_log_level_rec) then raise error_found;
      end if;

   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   when error_found then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      x_return_status := FND_API.G_RET_STS_ERROR;

END Do_Validation;


PROCEDURE Update_All_Records
            (p_posting_status    IN     VARCHAR2,
             p_where_clause      IN     VARCHAR2,
             x_success_count        OUT NOCOPY NUMBER,
             x_failure_count        OUT NOCOPY NUMBER,
             x_return_status        OUT NOCOPY VARCHAR2) IS

   TYPE cursor_ref   IS REF cursor;
   TYPE num_tab      IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
   TYPE date_tab     IS TABLE OF DATE          INDEX BY BINARY_INTEGER;
   TYPE char_tab     IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
   TYPE rowid_tab    IS TABLE OF ROWID         INDEX BY BINARY_INTEGER;

   l_rowid                 varchar2(30);
   l_rowid_tbl             dbms_sql.varchar2_table;
   l_upd_rowid             char_tab;

   -- bulk operations
   i                       number;
   first_time              boolean  := TRUE;
   l_num_rows              number;
   l_batch_size            number;
   l_queue_name            char_tab;
   l_posting_status        char_tab;

   l_massadd_rec           fa_mass_additions%ROWTYPE;

   -- dynamic sql
   l_ret_val               number;
   l_cursor_id             number;
   l_sql_statement         varchar2(2000);

   l_ret_status            varchar2(1) := FND_API.G_RET_STS_SUCCESS;
   l_calling_fn            varchar2(40) := 'fa_massadd_special_pkg.update_all';

   error_found             exception;
   error_found2            exception;   -- used in nested block

/*Bug 7184647  added following 3 lines*/
   l_date       DATE;
   l_user_id    number;
   l_login_id   number;

   cursor c_massadd is
   select *
     from fa_mass_additions
    where rowid = l_rowid;

BEGIN

   x_success_count := 0;
   x_failure_count := 0;

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise error_found;
      end if;
   end if;

   if not fa_cache_pkg.fazprof then
      null;
   end if;

   l_batch_size  := nvl(fa_cache_pkg.fa_batch_size, 200);

   l_cursor_id := dbms_sql.open_cursor;

   l_sql_statement := 'select row_id ' ||
                       ' from fa_mass_additions_v ' ||
                      p_where_clause              ||
                        ' and posting_status not in (''POSTED'', ''MERGED'', ''SPLIT'')';

   dbms_sql.parse(l_cursor_id, l_sql_statement, DBMS_SQL.NATIVE);
   dbms_sql.define_array(l_cursor_id, 1, l_rowid_tbl, l_batch_size, 1);

   l_ret_val := DBMS_SQL.EXECUTE(l_cursor_id);

   loop

      -- reset the array to 1
      dbms_sql.define_array(l_cursor_id, 1, l_rowid_tbl, l_batch_size, 1);

      l_num_rows := dbms_sql.fetch_rows(l_cursor_id);
      dbms_sql.column_value(l_cursor_id, 1, l_rowid_tbl);

      if (l_num_rows = 0) then
         exit;
      end if;

      for i in 1..l_rowid_tbl.count loop

         l_rowid := l_rowid_tbl(i);

         open c_massadd;
         fetch c_massadd into l_massadd_rec;
         close c_massadd;

         begin

            -- bug# 2241114 load the cache if needed
            if nvl(g_last_book_used, '-NULL') <> l_massadd_rec.book_type_code then
               if not fa_cache_pkg.fazcbc(X_book => l_massadd_rec.book_type_code, p_log_level_rec => g_log_level_rec) then
                  raise error_found;
               end if;
               G_last_book_used := l_massadd_rec.book_type_code;
            end if;

            if (p_posting_status = 'POST') then

               do_validation
                  (p_posting_status,
                   l_massadd_rec,
                   l_ret_status);
            end if;

            if l_ret_status <> FND_API.G_RET_STS_SUCCESS then
               raise error_found2;
            else
               l_upd_rowid(l_upd_rowid.count + 1) := l_rowid_tbl(i);
               if (p_posting_status = 'POST') then
                  l_posting_status(l_upd_rowid.count) := 'POST';
                  if (l_massadd_rec.add_to_asset_id is not null and
                      nvl(l_massadd_rec.transaction_type_code, 'XX') <> 'FUTURE CAP' and
                      nvl(l_massadd_rec.transaction_type_code, 'XX') <> 'FUTURE REV') then
                     l_queue_name(l_upd_rowid.count) := 'ADD TO ASSET';
                  else
                     l_queue_name(l_upd_rowid.count) := 'POST';
                  end if;
               else
                  l_posting_status(l_upd_rowid.count) := p_posting_status;
                  l_queue_name(l_upd_rowid.count)     := p_posting_status;
               end if;
            end if;

         exception
            -- do not error at the invoice line level
            -- just increment the total failure count and continue
            when error_found2 then
               x_failure_count := x_failure_count + 1;
            when others then
               x_failure_count := x_failure_count + 1;
         end;

      end loop;

	/*Bug 7184647  added following 3 lines*/
	l_date := sysdate;
	l_user_id := fnd_global.user_id;
	l_login_id := fnd_global.login_id;

      -- now do the update on the validated records
      forall i in 1..l_upd_rowid.count
      update fa_mass_additions
         set posting_status   = l_posting_status(i),
             queue_name       = l_queue_name(i), /*Bug 7184647  added following 3 lines*/
	     last_updated_by   = l_user_id,
             last_update_date  = l_date,
             last_update_login = l_login_id
       where rowid            = l_upd_rowid(i);

      if l_upd_rowid.count > 0 then
         x_success_count := x_success_count + SQL%ROWCOUNT;
      end if;

      l_rowid_tbl.delete;
      l_upd_rowid.delete;

      commit;  -- commit at each batch interval

      exit when l_num_rows < l_batch_size;

   end loop;

   DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
   commit;

   -- returning success here even though individual lines may have failed.
   if (x_failure_count = 0) then
      X_return_status := FND_API.G_RET_STS_SUCCESS;
   else
      X_return_status := FND_API.G_RET_STS_ERROR;
   end if;

EXCEPTION
  when error_found then
     fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
     X_return_status := FND_API.G_RET_STS_ERROR;

  when others then
     fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
     X_return_status := FND_API.G_RET_STS_ERROR;


END Update_All_Records;


END FA_MASSADD_SPECIAL_PKG;

/
