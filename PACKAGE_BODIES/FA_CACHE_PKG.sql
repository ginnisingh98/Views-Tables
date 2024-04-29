--------------------------------------------------------
--  DDL for Package Body FA_CACHE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CACHE_PKG" as
/* $Header: FACACHEB.pls 120.24.12010000.6 2010/04/16 15:36:08 dvjoshi ship $ */

-----------------------------------------------------------------------------

Function fazcbc
           (X_book in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
         return boolean is

   l_found       boolean;
   l_count       number;
   fazcbc_err    exception;

begin <<FAZCBC>>

   -- due to caching problem, will do direct select
   -- BUG# 1910467 - reinstating cache
   -- transaction approval will insure the cache is not
   -- not stale every time it is called
   --   bridgway   08/01/01

   if nvl(fazcbc_record.book_type_code, X_book || 'NULL') = X_book then
      null;
   else
      if fazcbc_table.count = 0 then
         l_found := FALSE;

         -- load profiles
         if not fazprof then
            raise fazcbc_err;
         end if;

      end if;

      for i in 1..fazcbc_table.count loop

         if (fazcbc_table(i).book_type_code = X_book) then
            l_found := TRUE;
            l_count := i;
            exit;
         else
            l_found := FALSE;
         end if;

      end loop;

      if l_found = TRUE then
         fazcbc_record       := fazcbc_table(l_count);
         fazcbc_index        := l_count;
      else
         SELECT book_type_code,
                book_type_name,
                set_of_books_id,
                initial_date,
                last_deprn_run_date,
                amortize_flag,
                fully_reserved_flag,
                deprn_calendar,
                book_class,
                gl_posting_allowed_flag,
                current_fiscal_year,
                allow_mass_changes,
                allow_deprn_adjustments,
                accounting_flex_structure,
                last_update_date,
                last_updated_by,
                prorate_calendar,
                date_ineffective,
                je_retirement_category,
                je_depreciation_category,
                je_reclass_category,
                gl_je_source,
                je_addition_category,
                je_adjustment_category,
                distribution_source_book,
                je_transfer_category,
                copy_retirements_flag,
                copy_adjustments_flag,
                deprn_request_id,
                allow_cost_ceiling,
                allow_deprn_exp_ceiling,
                calculate_nbv,
                run_year_end_program,
                je_deferred_deprn_category,
                itc_allowed_flag,
                created_by,
                creation_date,
                last_update_login,
                allow_mass_copy,
                allow_purge_flag,
                allow_reval_flag,
                amortize_reval_reserve_flag,
                ap_intercompany_acct,
                ar_intercompany_acct,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                attribute_category_code,
                capital_gain_threshold,
                copy_salvage_value_flag,
                cost_of_removal_clearing_acct,
                cost_of_removal_gain_acct,
                cost_of_removal_loss_acct,
                default_life_extension_ceiling,
                default_life_extension_factor,
                default_max_fully_rsvd_revals,
                default_reval_fully_rsvd_flag,
                deferred_deprn_expense_acct,
                deferred_deprn_reserve_acct,
                deprn_allocation_code,
                deprn_status,
                fiscal_year_name,
                initial_period_counter,
                je_cip_adjustment_category,
                je_cip_addition_category,
                je_cip_reclass_category,
                je_cip_retirement_category,
                je_cip_reval_category,
                je_cip_transfer_category,
                je_reval_category,
                last_mass_copy_period_counter,
                last_period_counter,
                last_purge_period_counter,
                mass_copy_source_book,
                mass_request_id,
                nbv_amount_threshold,
                nbv_fraction_threshold,
                nbv_retired_gain_acct,
                nbv_retired_loss_acct,
                proceeds_of_sale_clearing_acct,
                proceeds_of_sale_gain_acct,
                proceeds_of_sale_loss_acct,
                revalue_on_retirement_flag,
                reval_deprn_reserve_flag,
                reval_rsv_retired_gain_acct,
                reval_rsv_retired_loss_acct,
                deprn_adjustment_acct,
                immediate_copy_flag,
                je_deprn_adjustment_category,
                depr_first_year_ret_flag,
                flexbuilder_defaults_ccid,
                retire_reval_reserve_flag,
                use_current_nbv_for_deprn,
                copy_additions_flag,
                use_percent_salvage_value_flag,
                reval_posting_flag,
                global_attribute1,
                global_attribute2,
                global_attribute3,
                global_attribute4,
                global_attribute5,
                global_attribute6,
                global_attribute7,
                global_attribute8,
                global_attribute9,
                global_attribute10,
                global_attribute11,
                global_attribute12,
                global_attribute13,
                global_attribute14,
                global_attribute15,
                global_attribute16,
                global_attribute17,
                global_attribute18,
                global_attribute19,
                global_attribute20,
                global_attribute_category,
                mc_source_flag,
                reval_ytd_deprn_flag,
                allow_cip_assets_flag,
                org_id,
                allow_group_deprn_flag,
                allow_cip_dep_group_flag,
                allow_interco_group_flag,
                copy_group_addition_flag,
                copy_group_assignment_flag,
                allow_cip_member_flag,
                allow_member_tracking_flag,
                INTERCOMPANY_POSTING_FLAG,
                allow_cost_sign_change_flag,
                sorp_enabled_flag,
                allow_impairment_flag,
                copy_amort_adaj_exp_flag,
                copy_group_change_flag
           INTO fazcbc_record.book_type_code,
                fazcbc_record.book_type_name,
                fazcbc_record.set_of_books_id,
                fazcbc_record.initial_date,
                fazcbc_record.last_deprn_run_date,
                fazcbc_record.amortize_flag,
                fazcbc_record.fully_reserved_flag,
                fazcbc_record.deprn_calendar,
                fazcbc_record.book_class,
                fazcbc_record.gl_posting_allowed_flag,
                fazcbc_record.current_fiscal_year,
                fazcbc_record.allow_mass_changes,
                fazcbc_record.allow_deprn_adjustments,
                fazcbc_record.accounting_flex_structure,
                fazcbc_record.last_update_date,
                fazcbc_record.last_updated_by,
                fazcbc_record.prorate_calendar,
                fazcbc_record.date_ineffective,
                fazcbc_record.je_retirement_category,
                fazcbc_record.je_depreciation_category,
                fazcbc_record.je_reclass_category,
                fazcbc_record.gl_je_source,
                fazcbc_record.je_addition_category,
                fazcbc_record.je_adjustment_category,
                fazcbc_record.distribution_source_book,
                fazcbc_record.je_transfer_category,
                fazcbc_record.copy_retirements_flag,
                fazcbc_record.copy_adjustments_flag,
                fazcbc_record.deprn_request_id,
                fazcbc_record.allow_cost_ceiling,
                fazcbc_record.allow_deprn_exp_ceiling,
                fazcbc_record.calculate_nbv,
                fazcbc_record.run_year_end_program,
                fazcbc_record.je_deferred_deprn_category,
                fazcbc_record.itc_allowed_flag,
                fazcbc_record.created_by,
                fazcbc_record.creation_date,
                fazcbc_record.last_update_login,
                fazcbc_record.allow_mass_copy,
                fazcbc_record.allow_purge_flag,
                fazcbc_record.allow_reval_flag,
                fazcbc_record.amortize_reval_reserve_flag,
                fazcbc_record.ap_intercompany_acct,
                fazcbc_record.ar_intercompany_acct,
                fazcbc_record.attribute1,
                fazcbc_record.attribute2,
                fazcbc_record.attribute3,
                fazcbc_record.attribute4,
                fazcbc_record.attribute5,
                fazcbc_record.attribute6,
                fazcbc_record.attribute7,
                fazcbc_record.attribute8,
                fazcbc_record.attribute9,
                fazcbc_record.attribute10,
                fazcbc_record.attribute11,
                fazcbc_record.attribute12,
                fazcbc_record.attribute13,
                fazcbc_record.attribute14,
                fazcbc_record.attribute15,
                fazcbc_record.attribute_category_code,
                fazcbc_record.capital_gain_threshold,
                fazcbc_record.copy_salvage_value_flag,
                fazcbc_record.cost_of_removal_clearing_acct,
                fazcbc_record.cost_of_removal_gain_acct,
                fazcbc_record.cost_of_removal_loss_acct,
                fazcbc_record.default_life_extension_ceiling,
                fazcbc_record.default_life_extension_factor,
                fazcbc_record.default_max_fully_rsvd_revals,
                fazcbc_record.default_reval_fully_rsvd_flag,
                fazcbc_record.deferred_deprn_expense_acct,
                fazcbc_record.deferred_deprn_reserve_acct,
                fazcbc_record.deprn_allocation_code,
                fazcbc_record.deprn_status,
                fazcbc_record.fiscal_year_name,
                fazcbc_record.initial_period_counter,
                fazcbc_record.je_cip_adjustment_category,
                fazcbc_record.je_cip_addition_category,
                fazcbc_record.je_cip_reclass_category,
                fazcbc_record.je_cip_retirement_category,
                fazcbc_record.je_cip_reval_category,
                fazcbc_record.je_cip_transfer_category,
                fazcbc_record.je_reval_category,
                fazcbc_record.last_mass_copy_period_counter,
                fazcbc_record.last_period_counter,
                fazcbc_record.last_purge_period_counter,
                fazcbc_record.mass_copy_source_book,
                fazcbc_record.mass_request_id,
                fazcbc_record.nbv_amount_threshold,
                fazcbc_record.nbv_fraction_threshold,
                fazcbc_record.nbv_retired_gain_acct,
                fazcbc_record.nbv_retired_loss_acct,
                fazcbc_record.proceeds_of_sale_clearing_acct,
                fazcbc_record.proceeds_of_sale_gain_acct,
                fazcbc_record.proceeds_of_sale_loss_acct,
                fazcbc_record.revalue_on_retirement_flag,
                fazcbc_record.reval_deprn_reserve_flag,
                fazcbc_record.reval_rsv_retired_gain_acct,
                fazcbc_record.reval_rsv_retired_loss_acct,
                fazcbc_record.deprn_adjustment_acct,
                fazcbc_record.immediate_copy_flag,
                fazcbc_record.je_deprn_adjustment_category,
                fazcbc_record.depr_first_year_ret_flag,
                fazcbc_record.flexbuilder_defaults_ccid,
                fazcbc_record.retire_reval_reserve_flag,
                fazcbc_record.use_current_nbv_for_deprn,
                fazcbc_record.copy_additions_flag,
                fazcbc_record.use_percent_salvage_value_flag,
                fazcbc_record.reval_posting_flag,
                fazcbc_record.global_attribute1,
                fazcbc_record.global_attribute2,
                fazcbc_record.global_attribute3,
                fazcbc_record.global_attribute4,
                fazcbc_record.global_attribute5,
                fazcbc_record.global_attribute6,
                fazcbc_record.global_attribute7,
                fazcbc_record.global_attribute8,
                fazcbc_record.global_attribute9,
                fazcbc_record.global_attribute10,
                fazcbc_record.global_attribute11,
                fazcbc_record.global_attribute12,
                fazcbc_record.global_attribute13,
                fazcbc_record.global_attribute14,
                fazcbc_record.global_attribute15,
                fazcbc_record.global_attribute16,
                fazcbc_record.global_attribute17,
                fazcbc_record.global_attribute18,
                fazcbc_record.global_attribute19,
                fazcbc_record.global_attribute20,
                fazcbc_record.global_attribute_category,
                fazcbc_record.mc_source_flag,
                fazcbc_record.reval_ytd_deprn_flag,
                fazcbc_record.allow_cip_assets_flag,
                fazcbc_record.org_id,
                fazcbc_record.allow_group_deprn_flag,
                fazcbc_record.allow_cip_dep_group_flag,
                fazcbc_record.allow_interco_group_flag,
                fazcbc_record.copy_group_addition_flag,
                fazcbc_record.copy_group_assignment_flag,
                fazcbc_record.allow_cip_member_flag,
                fazcbc_record.allow_member_tracking_flag,
                fazcbc_record.INTERCOMPANY_POSTING_FLAG,
                fazcbc_record.allow_cost_sign_change_flag,
                fazcbc_record.sorp_enabled_flag,
                fazcbc_record.allow_impairment_flag,
                fazcbc_record.copy_amort_adaj_exp_flag,
                fazcbc_record.copy_group_change_flag
           FROM fa_book_controls
          WHERE book_type_code = X_book;

         fazcbc_table(fazcbc_table.count + 1):= fazcbc_record;
         fazcbc_index                   := fazcbc_table.count;

      end if;
   end if;

   -- now load the fazcbcs cache proactively
   if NOT fa_cache_pkg.fazcbcs(X_book => x_book,
                               X_set_of_books_id => fazcbc_record.set_of_books_id,
                               p_log_level_rec => p_log_level_rec) then
      raise fazcbc_err;
   end if;

   return (TRUE);

exception
   when NO_DATA_FOUND then
        fa_srvr_msg.add_message(calling_fn => NULL,
                        name       => 'FA_CACHE_BOOK_CONTROLS',
                        token1     => 'BOOK',
                        value1     => X_book, p_log_level_rec => p_log_level_rec);
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazcbc', p_log_level_rec => p_log_level_rec);
        return (false);
   when fazcbc_err then
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazcbc', p_log_level_rec => p_log_level_rec);
        return (false);
   when others then
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazcbc', p_log_level_rec => p_log_level_rec);
        return (FALSE);

end FAZCBC;

-----------------------------------------------------------------------------

Function fazcbcs
          (X_book in VARCHAR2,
           X_set_of_books_id in number,
           p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
         return boolean is

   l_found            boolean;
   l_count            number;
   h_reporting_flag   varchar2(1);

begin <<FAZCBCS>>

   if (X_set_of_books_id is not null) then
      if not fazcsob
              (X_set_of_books_id   => X_set_of_books_id,
               X_mrc_sob_type_code => h_reporting_flag) then
                   fa_srvr_msg.add_sql_error
                     (calling_fn => 'fa_cache_pkg.fazcbcs', p_log_level_rec => p_log_level_rec);
                   return(FALSE);
      end if;
   else
      h_reporting_flag := 'P';
   end if;

   if ((nvl(fazcbcs_record.book_type_code, X_book || 'NULL') = X_book) and
       (fazcbcs_record.set_of_books_id = X_set_of_books_id)) then
      return true;
   else
      if fazcbcs_table.count = 0 then
         l_found := FALSE;
      end if;

      for i in 1..fazcbcs_table.count loop
          if ((fazcbcs_table(i).book_type_code  = X_book) and
              (fazcbcs_table(i).set_of_books_id = X_set_of_books_id)) then
             l_found := TRUE;
             l_count := i;
             exit;
          else
             l_found := FALSE;
          end if;
      end loop;

      if l_found = TRUE then
         fazcbcs_record       := fazcbcs_table(l_count);
         fazcbcs_index        := l_count;
      else
         -- load primary cache first if needed
         if (nvl(fazcbc_record.book_type_code, X_book || 'NULL') <> X_book)
then
            if not (fazcbc (X_book, p_log_level_rec)) then
               fa_srvr_msg.add_sql_error
                  (calling_fn => 'fa_cache_pkg.fazcbcs', p_log_level_rec => p_log_level_rec);
               return(FALSE);
            end if;
         end if;

         if h_reporting_flag = 'R' then

            -- initialize the value to primary
            fazcbcs_record                  := fazcbc_record;

            -- overlay the matching MC columns

            SELECT  DEPRN_REQUEST_ID
                  , LAST_UPDATE_LOGIN
                  , DEPRN_STATUS
                  , LAST_PERIOD_COUNTER
                  , MASS_REQUEST_ID
                  , NBV_AMOUNT_THRESHOLD
                  , BOOK_TYPE_CODE
                  , SET_OF_BOOKS_ID
                  , LAST_DEPRN_RUN_DATE
                  , CURRENT_FISCAL_YEAR
                  , LAST_UPDATE_DATE
                  , LAST_UPDATED_BY
              INTO  fazcbcs_record.DEPRN_REQUEST_ID
                  , fazcbcs_record.LAST_UPDATE_LOGIN
                  , fazcbcs_record.DEPRN_STATUS
                  , fazcbcs_record.LAST_PERIOD_COUNTER
                  , fazcbcs_record.MASS_REQUEST_ID
                  , fazcbcs_record.NBV_AMOUNT_THRESHOLD
                  , fazcbcs_record.BOOK_TYPE_CODE
                  , fazcbcs_record.SET_OF_BOOKS_ID
                  , fazcbcs_record.LAST_DEPRN_RUN_DATE
                  , fazcbcs_record.CURRENT_FISCAL_YEAR
                  , fazcbcs_record.LAST_UPDATE_DATE
                  , fazcbcs_record.LAST_UPDATED_BY
              FROM fa_mc_book_controls
             WHERE book_type_code = X_book
               AND set_of_books_id = X_set_of_books_id;
         else
             fazcbcs_record := fazcbc_record;
         end if;

         fazcbcs_table(fazcbcs_table.count + 1):= fazcbcs_record;
         fazcbcs_index                   := fazcbcs_table.count;

      end if;
   end if;

   return (TRUE);

exception
   when NO_DATA_FOUND then
        fa_srvr_msg.add_message(calling_fn => NULL,
                        name       => 'FA_CACHE_MC_BOOK_CONTROLS',
                        token1     => 'BOOK',
                        value1     => X_book,
                        token2     => 'SET_OF_BOOKS_ID',
                        value2     => X_set_of_books_id, p_log_level_rec => p_log_level_rec);
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazcbcs', p_log_level_rec => p_log_level_rec);
        return (FALSE);
   when others then
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazcbcs', p_log_level_rec => p_log_level_rec);
        return (FALSE);

end FAZCBCS;

-----------------------------------------------------------------------------

Function fazcbc_clr
          (X_book in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
         return boolean is

   l_count   number;

BEGIN <<fazcbc_clr>>

   -- clear the record
   fazcbc_record.book_type_code := 'NULL';

   -- clear the member in the table. since the cache should always
   -- be called before doing this (i.e. faxcps) we know the global
   -- index variable will have the correct index from fazcbc

   -- correction on the above - this is not necessarily true
   -- since we're proatviely clearing it in query_balances
   -- in the client interface to prevent stale data in the
   -- last period counter

   if nvl(fazcbc_index, 0) > 0 then

      fazcbc_table.delete(fazcbc_index);

      -- reset the values so there is no missing member for future use
      l_count := fazcbc_table.count;

      for i in fazcbc_index..l_count loop
          -- copy the next member into the current one
          fazcbc_table(i) := fazcbc_table(i+1);
      end loop;

      -- delete the last member in the array which is now a duplicate
      fazcbc_table.delete(l_count + 1);
   end if;

   fazcbcs_record.book_type_code := 'NULL';

   if nvl(fazcbcs_index, 0) > 0 then

      fazcbcs_table.delete(fazcbcs_index);

      -- reset the values so there is no missing member for future use
      l_count := fazcbcs_table.count;

      for i in fazcbcs_index..l_count loop
          -- copy the next member into the current one
          fazcbcs_table(i) := fazcbcs_table(i+1);
      end loop;

      -- delete the last member in the array which is now a duplicate
      fazcbcs_table.delete(l_count + 1);
   end if;

   return TRUE;

exception
   when others then
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazcbc_clr', p_log_level_rec => p_log_level_rec);
        return (FALSE);

END fazcbc_clr;

-----------------------------------------------------------------------------

Function fazcct
          (X_calendar in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
         return boolean is

   l_found       boolean;
   l_count       number;

begin <<FAZCCT>>
   if nvl(fazcct_record.calendar_type, 'NULL') = X_calendar then
      return true;
   else

      if fazcct_table.count = 0 then
         l_found := FALSE;
      end if;

      for i in 1..fazcct_table.count loop

          if (fazcct_table(i).calendar_type = X_calendar) then
             l_found := TRUE;
             l_count := i;
             exit;
          else
             l_found := FALSE;
          end if;

      end loop;

      if l_found = TRUE then
         fazcct_record           := fazcct_table(l_count);
      else
         SELECT *
           INTO fazcct_record
           FROM fa_calendar_types
          WHERE calendar_type = X_calendar;

         fazcct_table(fazcct_table.count + 1):= fazcct_record;

      end if;
   end if;

   return (TRUE);

exception
   when NO_DATA_FOUND then
        fa_srvr_msg.add_message(calling_fn => NULL,
                        name       => 'FA_CACHE_CALENDAR_TYPES',
                        token1     => 'CALENDAR',
                        value1     => X_calendar, p_log_level_rec => p_log_level_rec);
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazcct', p_log_level_rec => p_log_level_rec);
        return (FALSE);

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazcct', p_log_level_rec => p_log_level_rec);
        return (FALSE);

end FAZCCT;

-----------------------------------------------------------------------------

Function fazcff
          (X_calendar         varchar2,
           X_book             varchar2,
           X_fy               integer,
           X_period_fracs out NOCOPY fa_std_types.table_fa_cp_struct
          , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
         return boolean is

   l_count            number;
   l_period           number;
   l_found            boolean;

   h_fiscal_year_name varchar2(30);
   h_deprn_alloc_code varchar2(30);
   h_pers_per_yr integer(5);

   CURSOR FAZCFF_CURSOR IS
       SELECT decode (substr(h_deprn_alloc_code,1,1),
                      'E', 1.0 / h_pers_per_yr,
                     (cp.end_date + 1 - cp.start_date) /
                     (fy.end_date + 1 - fy.start_date)),
              to_number (to_char (cp.start_date, 'J')),
              to_number (to_char (cp.end_date, 'J'))
         FROM fa_calendar_periods cp, fa_fiscal_year fy
        WHERE fy.fiscal_year = X_fy
          AND fy.fiscal_year_name = h_fiscal_year_name
          AND cp.calendar_type = X_calendar
          AND cp.start_date BETWEEN fy.start_date AND fy.end_date
          AND cp.end_date BETWEEN fy.start_date AND fy.end_date
        ORDER BY period_num;

begin <<FAZCFF>>

   -- NOTE: the internal fazcff table is indexed starting at 1
   --       the out paramter starts at 0!!!!

   if fazcff_table.count = 0 then
      l_found := FALSE;
   end if;

      for i in 1..fazcff_table.count loop
         -- find first match which is the first period of the year
         if (fazcff_table(i).book_type_code = X_book and
             fazcff_table(i).calendar_type  = X_calendar and
             fazcff_table(i).fiscal_year    = X_fy) then
            l_count := i;
            l_found := TRUE;
            exit;
         else
            l_found := FALSE;
         end if;
      end loop;

      -- Get number of periods per year
      if not fazcct (X_calendar) then
        fa_srvr_msg.add_message(calling_fn => 'fa_cache_pkg.fazcff', p_log_level_rec => p_log_level_rec);
        return (FALSE);
      end if;

      h_pers_per_yr := fazcct_record.number_per_fiscal_year;

      if l_found = TRUE then

         -- init l_period which is used for output struct to 0
         l_period := 0;
         for x in l_count..l_count + h_pers_per_yr - 1 loop
             X_period_fracs(l_period).frac        := fazcff_table(x).frac;
             X_period_fracs(l_period).start_jdate := fazcff_table(x).start_jdate;
             X_period_fracs(l_period).end_jdate   := fazcff_table(x).end_jdate;
             l_period                             := l_period + 1;
         end loop;
      else

/*  will implement this later for this cache type in order
 *  to prevent the pl/sql table from getting to big
 *  logic should delete all rows for the book/cal/fy combo
 *  though this may get tricky and we might need to bump max_size

         -- do not let array get to big.. once it is at the
         -- max begin clearing values from the array
         if fazcff_table.count >= G_max_array_size then

            -- get the first record

            -- clear the first record
            fazcff_record.book_type_code := 'NULL';

            -- clear the first member in the table
            fazcff_table.delete(1);

            -- reset values so there is no missing member for future use
            l_count := fazcff_table.count;

            for i in 1..l_count loop
               -- copy the next member into the current one
               fazcff_table(i) := fazcff_table(i+1);
            end loop;

            -- delete the last member in the array which is now a duplicate
            fazcff_table.delete(l_count + 1);

         end if;
*/

         -- Get fiscal year name (book cache should already be loaded)

         h_fiscal_year_name := fazcbc_record.fiscal_year_name;
         h_deprn_alloc_code := fazcbc_record.deprn_allocation_code;

         OPEN FAZCFF_CURSOR;
         for ctr in 0..h_pers_per_yr-1 loop
             FETCH FAZCFF_CURSOR
              INTO X_period_fracs(ctr).frac,
                   X_period_fracs(ctr).start_jdate,
                   X_period_fracs(ctr).end_jdate;

             fazcff_table(fazcff_table.count + 1).book_type_code := X_book;
             fazcff_table(fazcff_table.count).calendar_type      := X_calendar;
             fazcff_table(fazcff_table.count).fiscal_year        := X_fy;
             fazcff_table(fazcff_table.count).frac               := X_period_fracs(ctr).frac;
             fazcff_table(fazcff_table.count).start_jdate        := X_period_fracs(ctr).start_jdate;
             fazcff_table(fazcff_table.count).end_jdate          := X_period_fracs(ctr).end_jdate;

         end loop;

         if FAZCFF_CURSOR%ROWCOUNT = 0 then
            CLOSE FAZCFF_CURSOR;
            raise NO_DATA_FOUND;
         end if;

         CLOSE FAZCFF_CURSOR;
      end if;

   return (TRUE);

Exception
   when NO_DATA_FOUND then
        fa_srvr_msg.add_message(calling_fn => NULL,
                        name       => 'FA_CACHE_CALENDAR_FRAC',
                        token1     => 'CALENDAR',
                        value1     => X_calendar,
                        token2     => 'BOOK',
                        value2     => X_book,
                        token3     => 'FY',
                        value3     => X_fy, p_log_level_rec => p_log_level_rec);
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazcff', p_log_level_rec => p_log_level_rec);
        return (FALSE);
   when others then
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazcff', p_log_level_rec => p_log_level_rec);
        return (FALSE);

end FAZCFF;

-----------------------------------------------------------------------------

Function fazccl
         (X_target_ceiling_name varchar2,
          X_target_jdate        integer,
          X_target_year         integer,
          X_ceiling         out NOCOPY number
         , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
return boolean is

   l_found       boolean;
   l_count       number;

begin <<FAZCCL>>

   if (nvl(fazccl_record.t_ceiling_name, 'NULL') = X_target_ceiling_name and
       nvl(fazccl_record.t_jdate, -1)        = X_target_jdate and
       nvl(fazccl_record.t_year, -1)         = X_target_year ) then
      X_ceiling := fazccl_record.ceiling;
      return (TRUE);
   else
      if fazccl_table.count = 0 then
         l_found := FALSE;
      end if;

      for i in 1..fazccl_table.count loop

         if (nvl(fazccl_table(i).t_ceiling_name, 'NULL') = X_target_ceiling_name and
             nvl(fazccl_table(i).t_jdate, -1)        = X_target_jdate and
             nvl(fazccl_table(i).t_year, -1)         = X_target_year ) then
            l_found := TRUE;
            l_count := i;
            exit;
         else
            l_found := FALSE;
         end if;
      end loop;

      if l_found = TRUE then
         fazccl_record           := fazccl_table(l_count);
      else
         SELECT cur_one.limit
           INTO fazccl_record.ceiling
           FROM fa_ceilings cur_one,
                fa_ceilings this_one,
                fa_ceilings next_one
          WHERE cur_one.ceiling_name = X_target_ceiling_name
            AND this_one.ceiling_name = X_target_ceiling_name
            AND next_one.ceiling_name (+) = X_target_ceiling_name
            AND to_date (X_target_jdate, 'J') BETWEEN
                 cur_one.start_date AND
                 nvl (cur_one.end_date, to_date (X_target_jdate, 'J'))
            AND to_date (X_target_jdate, 'J') BETWEEN
                 this_one.start_date AND
                 nvl (this_one.end_date, to_date (X_target_jdate, 'J'))
            AND to_date (X_target_jdate, 'J') BETWEEN
                 next_one.start_date (+) AND
                 nvl (next_one.end_date (+),
                      to_date (X_target_jdate, 'J'))
            AND X_target_year >= nvl (this_one.year_of_life, 0)
            AND nvl (cur_one.year_of_life, 0) < next_one.year_of_life (+)
          GROUP BY cur_one.limit, cur_one.year_of_life,
                   cur_one.start_date, cur_one.end_date
          HAVING  nvl (cur_one.year_of_life, 0) =
                          nvl (max (this_one.year_of_life), 0);

         fazccl_record.t_ceiling_name         := X_target_ceiling_name;
         fazccl_record.t_jdate                := X_target_jdate;
         fazccl_record.t_year                 := X_target_year;
         fazccl_table(fazccl_table.count + 1) := fazccl_record;

      end if;
   end if;

   X_ceiling := fazccl_record.ceiling;
   return (TRUE);

Exception
   when no_data_found then
        X_ceiling := 1000000000000.00;
        return (TRUE);
   when others then
        fa_srvr_msg.add_sql_error (calling_fn => 'fa_cache_pkg.fazccl', p_log_level_rec => p_log_level_rec);
        return (FALSE);

end FAZCCL;

-----------------------------------------------------------------------------

Function fazcbr
          (X_target_bonus_rule                 varchar2,
           X_target_year                       number,
           X_bonus_rate             out NOCOPY number,
           X_deprn_factor           out NOCOPY number,
           X_alternate_deprn_factor out NOCOPY number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
         return boolean is

   l_found       boolean;
   l_count       number;

begin <<FAZCBR>>

   if (nvl(fazcbr_record.t_bonus_rule, 'NULL') = X_target_bonus_rule and
      fazcbr_record.t_year = X_target_year) then
      X_bonus_rate := fazcbr_record.bonus_rate;
      X_deprn_factor := fazcbr_record.deprn_factor;
      X_alternate_deprn_factor := fazcbr_record.alternate_deprn_factor;
      return (TRUE);
   else
      if fazcbr_table.count = 0 then
         l_found := FALSE;
      end if;

      for i in 1..fazcbr_table.count loop

         if (fazcbr_table(i).t_bonus_rule = X_target_bonus_rule and
             fazcbr_table(i).t_year       = X_target_year) then
            l_count := i;
            l_found := TRUE;
            exit;
         else
            l_found := FALSE;
         end if;
      end loop;

      if l_found = TRUE then
         fazcbr_record           := fazcbr_table(l_count);
      else

         SELECT bonus_rate,
                deprn_factor,
                alternate_deprn_factor
           INTO fazcbr_record.bonus_rate,
                fazcbr_record.deprn_factor,
                fazcbr_record.alternate_deprn_factor
           FROM fa_bonus_rates
          WHERE bonus_rule = X_target_bonus_rule
            AND X_target_year BETWEEN
                  start_year AND nvl (end_year, X_target_year);

         fazcbr_record.t_bonus_rule     := X_target_bonus_rule;
         fazcbr_record.t_year           := X_target_year;
         fazcbr_table(fazcbr_table.count + 1):= fazcbr_record;

      end if;
   end if;

   X_bonus_rate := fazcbr_record.bonus_rate;
   X_deprn_factor := fazcbr_record.deprn_factor;
   X_alternate_deprn_factor := fazcbr_record.alternate_deprn_factor;

   return (TRUE);

Exception
   when no_data_found then
        X_bonus_rate := 0;
        X_deprn_factor := 0;
        X_alternate_deprn_factor := 0;

        return (TRUE);
   when others then
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazcbr', p_log_level_rec => p_log_level_rec);
        return (FALSE);

end FAZCBR;

-----------------------------------------------------------------------------

Function fazccp
          (X_target_calendar       varchar2,
           X_target_fy_name        varchar2,
           X_target_jdate          number,
           X_period_num     in out NOCOPY number,
           X_fiscal_year    in out NOCOPY number,
           X_start_jdate    in out NOCOPY number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
return boolean is

   x_target_date  date;
   l_found        boolean;
   l_count        number;

begin <<FAZCCP>>

   if (fazccp_record.t_calendar = X_target_calendar and
       fazccp_record.t_fy_name  = X_target_fy_name and
       fazccp_record.t_jdate    = X_target_jdate) then
      X_period_num   := fazccp_record.period_num;
      X_fiscal_year  := fazccp_record.fiscal_year;
      X_start_jdate  := fazccp_record.start_jdate;
      return (TRUE);
   else
      if fazccp_table.count = 0 then
         l_found := FALSE;
      end if;

      for i in 1..fazccp_table.count loop
          if (fazccp_table(i).t_calendar = X_target_calendar and
              fazccp_table(i).t_fy_name  = X_target_fy_name and
              fazccp_table(i).t_jdate    = X_target_jdate) then
             l_found := TRUE;
             l_count := i;
             exit;
          else
             l_found := FALSE;
          end if;

      end loop;

      if l_found = TRUE then
         fazccp_record  := fazccp_table(l_count);
      else
         x_target_date := to_date (to_char (X_target_jdate), 'J');

         SELECT to_number (to_char (cp.start_date, 'J')),
                cp.period_num,
                fy.fiscal_year
           INTO fazccp_record.start_jdate,
                fazccp_record.period_num,
                fazccp_record.fiscal_year
           FROM fa_calendar_periods cp,
                fa_fiscal_year fy
          WHERE fy.fiscal_year_name = X_target_fy_name
            AND cp.calendar_type    = X_target_calendar
            AND x_target_date       between fy.start_date and fy.end_date
            AND cp.start_date       between fy.start_date and fy.end_date
            AND cp.end_date         between fy.start_date and fy.end_date
            AND x_target_date       between cp.start_date and cp.end_date;

         fazccp_record.t_calendar := X_target_calendar;
         fazccp_record.t_fy_name := X_target_fy_name;
         fazccp_record.t_jdate := X_target_jdate;
         fazccp_table(fazccp_table.count + 1):= fazccp_record;
      end if;
   end if;

   X_period_num   := fazccp_record.period_num;
   X_fiscal_year  := fazccp_record.fiscal_year;
   X_start_jdate  := fazccp_record.start_jdate;
   return (TRUE);

exception
   when NO_DATA_FOUND then
        fa_srvr_msg.add_message(calling_fn => NULL,
                        name       => 'FA_CACHE_CALENDAR_PERIODS',
                        token1     => 'CALENDAR',
                        value1     => X_target_calendar,
                        token2     => 'FY_NAME',
                        value2     => X_target_fy_name,
                        token3     => 'DATE',
                        value3     => X_target_date, p_log_level_rec => p_log_level_rec);
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazccp', p_log_level_rec => p_log_level_rec);
        return (FALSE);
   when others then
        fa_srvr_msg.add_sql_error ( calling_fn => 'fa_cache_pkg.fazccp', p_log_level_rec => p_log_level_rec);
        return (FALSE);

end FAZCCP;

function fazccb
          (X_book   in varchar2,
           X_cat_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
         return boolean is

   l_found       boolean;
   l_count       number;

begin <<FAZCCB>>

   if (fazccb_record.book_type_code = X_book and
       fazccb_record.category_id    = X_cat_id) then
      return (TRUE);
   else
      if fazccb_table.count = 0 then
         l_found := FALSE;
      end if;

      for i in 1..fazccb_table.count loop

         if (fazccb_table(i).book_type_code = X_book and
             fazccb_table(i).category_id    = X_cat_id ) then
            l_count := i;
            l_found := TRUE;
            exit;
         else
            l_found := FALSE;
         end if;

      end loop;

      if l_found = TRUE then
         fazccb_record           := fazccb_table(l_count);
      else
         SELECT *
           INTO fazccb_record
           FROM fa_category_books
          WHERE book_type_code = X_book
            AND category_id = X_cat_id;

         fazccb_table(fazccb_table.count + 1):= fazccb_record;

      end if;

   end if;

   return (TRUE);

exception
   when NO_DATA_FOUND then
        fa_srvr_msg.add_message(calling_fn => NULL,
                        name       => 'FA_CACHE_CATEGORY_BOOKS',
                        token1     => 'CATEGORY_ID',
                        value1     => X_cat_id,
                        token2     => 'BOOK',
                        value2     => X_book, p_log_level_rec => p_log_level_rec);
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazccb', p_log_level_rec => p_log_level_rec);
        return (FALSE);
   when others then
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazccb', p_log_level_rec => p_log_level_rec);
        return (FALSE);

end fazccb;

--------------------------------------------------------------------------

Function fazccmt
          (X_method                    varchar2,
           X_life                      integer, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
        return boolean is

   l_found       boolean;
   l_count       number;
   l_table_name  varchar2(15);

begin

   if (nvl(fazccmt_record.method_code, '-NULL') = X_method and
       nvl(fazccmt_record.life_in_months, -99)  = nvl(X_life, -99)) then
      return true;
   else

      l_table_name := 'METHODS';

      if fazccmt_table.count = 0 then
         l_found := FALSE;
      end if;

      for i in 1..fazccmt_table.count loop

         if (fazccmt_table(i).method_code              = X_method and
             nvl(fazccmt_table(i).life_in_months, -99) = nvl(X_life, -99)) then
            l_count := i;
            l_found := TRUE;
            exit;
         else
            l_found := FALSE;
         end if;

      end loop;

      if l_found = TRUE then

         fazccmt_record           := fazccmt_table(l_count);

      else

         -- Performance issue.
         -- Split into different selects to use index better

         if (X_life is not null and X_life <> 0) then

            SELECT *
              INTO fazccmt_record
              FROM fa_methods
             WHERE method_code = X_method
               AND life_in_months = X_life;

         else

            SELECT *
              INTO fazccmt_record
              FROM fa_methods
             WHERE method_code = X_method
               AND (life_in_months is null OR
                    life_in_months = 0);

         end if;

         if (fazccmt_record.deprn_basis_rule_id is null) then
            fazccmt_record.deprn_basis_rule_id := 0;
         end if;

         fazccmt_table(fazccmt_table.count + 1) := fazccmt_record;

      end if;
   end if;

   -- load fa_formulas if formula based asset
   if (fazccmt_record.rate_source_rule = 'FORMULA') then
      if (fazccmt_record.method_id = nvl(fazcfor_record.method_id, -99)) then
         -- return true;
         null; -- keep what is in the fazcfor cache
      else
         l_table_name := 'FORMULAS';

         if fazcfor_table.count = 0 then
            l_found := FALSE;
         end if;

         for i in 1..fazcfor_table.count loop
            if (fazcfor_table(i).method_id  = fazccmt_record.method_id) then

               l_count := i;
               l_found := TRUE;
               exit;
            else
               l_found := FALSE;
            end if;
         end loop;

         if l_found = TRUE then

            fazcfor_record           := fazcfor_table(l_count);

         else
            begin
               select *
               into   fazcfor_record
               from   fa_formulas
               where  method_id = fazccmt_record.method_id;

               fazcfor_table(fazcfor_table.count + 1) := fazcfor_record;
            exception
               when no_data_found then

                  -- For Japan Tax reform, when loading seed formula rates,
                  -- the record in fa_methods will exist, but the one in
                  -- fa_formulas will not exist.
                  fazcfor_record.method_id := null;
                  fazcfor_record.formula_actual := null;
                  fazcfor_record.formula_displayed := null;
                  fazcfor_record.formula_parsed := null;
                  fazcfor_record.original_rate := null;
                  fazcfor_record.revised_rate := null;
                  fazcfor_record.guarantee_rate := null;
            end;
         end if;
      end if;
   else
      -- Not a formula method, so make sure everything is null
      fazcfor_record.method_id := null;
      fazcfor_record.formula_actual := null;
      fazcfor_record.formula_displayed := null;
      fazcfor_record.formula_parsed := null;
      fazcfor_record.original_rate := null;
      fazcfor_record.revised_rate := null;
      fazcfor_record.guarantee_rate := null;
   end if;

   -- now find and load the deprn basis rules
   if (fazcdbr_record.deprn_basis_rule_id= nvl(fazccmt_record.deprn_basis_rule_id, 0)) then
      return true;
   else
      l_table_name  := 'RULES';

      if fazcdbr_table.count = 0 then
         l_found := FALSE;
      end if;

      for j in 1..fazcdbr_table.count loop
         if fazcdbr_table(j).deprn_basis_rule_id = nvl(fazccmt_record.deprn_basis_rule_id, 0) then
            l_count := j;
            l_found := TRUE;
            exit;
         else
            l_found := FALSE;
         end if;
      end loop;

      if l_found = TRUE then
         fazcdbr_record := fazcdbr_table(l_count);
      else

         if (fazccmt_record.deprn_basis_rule_id = 0) then
            fazcdbr_record.deprn_basis_rule_id := 0;
            fazcdbr_record.rule_name           := null;
            fazcdbr_record.user_rule_name      := null;
            fazcdbr_record.rate_source         := null;
            fazcdbr_record.deprn_basis         := null;
            fazcdbr_record.enabled_flag        := null;
            fazcdbr_record.program_name        := null;
            fazcdbr_record.polish_rule         :=
                              FA_STD_TYPES.FAD_DBR_POLISH_NONE;
         else
            select deprn_basis_rule_id,
                   rule_name,
                   user_rule_name,
                   last_update_date,
                   last_updated_by,
                   created_by,
                   creation_date,
                   last_update_login,
                   rate_source,
                   deprn_basis,
                   enabled_flag,
                   program_name,
                   description
              into fazcdbr_record.deprn_basis_rule_id,
                   fazcdbr_record.rule_name,
                   fazcdbr_record.user_rule_name,
                   fazcdbr_record.last_update_date,
                   fazcdbr_record.last_updated_by,
                   fazcdbr_record.created_by,
                   fazcdbr_record.creation_date,
                   fazcdbr_record.last_update_login,
                   fazcdbr_record.rate_source,
                   fazcdbr_record.deprn_basis,
                   fazcdbr_record.enabled_flag,
                   fazcdbr_record.program_name,
                   fazcdbr_record.description
              from fa_deprn_basis_rules
             where deprn_basis_rule_id = fazccmt_record.deprn_basis_rule_id;
         end if;

         -- Determine the Polish Rule
         if (fazcdbr_record.rule_name =
            'POLISH 30% WITH A SWITCH TO DECLINING CLASSICAL AND FLAT RATE'
         ) then
            -- Polish Mechanism 1
            fazcdbr_record.polish_rule := FA_STD_TYPES.FAD_DBR_POLISH_1;
         elsif (fazcdbr_record.rule_name =
            'POLISH 30% WITH A SWITCH TO FLAT RATE'
         ) then
            -- Polish Mechanism 2
            fazcdbr_record.polish_rule :=  FA_STD_TYPES.FAD_DBR_POLISH_2;
         elsif (fazcdbr_record.rule_name =
            'POLISH DECLINING MODIFIED WITH A SWITCH TO DECLINING CLASSICAL AND FLAT RATE'
         ) then
            -- Polish Mechanism 3
            fazcdbr_record.polish_rule := FA_STD_TYPES.FAD_DBR_POLISH_3;
         elsif (fazcdbr_record.rule_name =
            'POLISH DECLINING MODIFIED WITH A SWITCH TO FLAT RATE'
         ) then
            -- Polish Mechanism 4
            fazcdbr_record.polish_rule := FA_STD_TYPES.FAD_DBR_POLISH_4;
         elsif (fazcdbr_record.rule_name =
            'POLISH STANDARD DECLINING WITH A SWITCH TO FLAT RATE'
         ) then
            -- Polish Mechansism 5
            fazcdbr_record.polish_rule := FA_STD_TYPES.FAD_DBR_POLISH_5;
         else
            -- No Polish Mechanism
            fazcdbr_record.polish_rule := FA_STD_TYPES.FAD_DBR_POLISH_NONE;
         end if;

         fazcdbr_table(fazcdbr_table.count + 1) := fazcdbr_record;
      end if;
   end if;

   -- now find and load the deprn basis rule details
  if   (fazcdrd_record.deprn_basis_rule_id  = nvl(fazccmt_record.deprn_basis_rule_id, 0))
        and fazcdrd_record.rate_source_rule = fazccmt_record.rate_source_rule
        and fazcdrd_record.deprn_basis_rule = fazccmt_record.deprn_basis_rule
  then
    return true;

   else
    l_table_name := 'RULE_DETAILS';

    if fazcdrd_table.count =0 then
      l_found := FALSE;
    end if;

    for k in 1..fazcdrd_table.count loop
      if nvl(fazcdrd_table(k).deprn_basis_rule_id,0) = nvl(fazccmt_record.deprn_basis_rule_id, 0)
      and fazcdrd_table(k).rate_source_rule = fazccmt_record.rate_source_rule
      and fazcdrd_table(k).deprn_basis_rule = fazccmt_record.deprn_basis_rule then
        l_count := k;
        l_found := TRUE;
        exit;
      else
        l_found := FALSE;
      end if;
   end loop;

   if l_found = TRUE then
     fazcdrd_record := fazcdrd_table(l_count);
   else

     if (fazccmt_record.deprn_basis_rule_id = 0) then
            -- For FA_DEPRN_RULE_DETAILS
       fazcdrd_record.deprn_rule_detail_id        := 0;
       fazcdrd_record.deprn_basis_rule_id         := 0;
       fazcdrd_record.rule_name                   := null;
       fazcdrd_record.rate_source_rule            := null;
       fazcdrd_record.deprn_basis_rule            := null;
       fazcdrd_record.asset_type                  := null;
       fazcdrd_record.period_update_flag          := null;
       fazcdrd_record.subtract_ytd_flag           := null;
       fazcdrd_record.allow_reduction_rate_flag   := null;
       fazcdrd_record.use_eofy_reserve_flag       := null;
       fazcdrd_record.use_rsv_after_imp_flag      := null;
     else

       select *
         into fazcdrd_record
         from fa_deprn_rule_details
        where deprn_basis_rule_id = fazccmt_record.deprn_basis_rule_id
          and rate_source_rule = fazccmt_record.rate_source_rule
          and deprn_basis_rule = fazccmt_record.deprn_basis_rule;
     end if;

     fazcdrd_table(fazcdrd_table.count + 1) := fazcdrd_record;

   end if; -- End l_found
  end if;  -- End FA_DEPRN_RULE_DETAILS

  return (TRUE);

exception
   when NO_DATA_FOUND then
        if (l_table_name = 'METHODS')then
           fa_srvr_msg.add_message(calling_fn => NULL,
                           name       => 'FA_CACHE_METHODS',
                           token1     => 'METHOD',
                           value1     => X_method,
                           token2     => 'LIFE',
                           value2     => X_life, p_log_level_rec => p_log_level_rec);
        else
           fa_srvr_msg.add_message(calling_fn => NULL,
                           name       => 'FA_CACHE_DEPRN_BASIS_RULES',
                           token1     => 'RULE_ID',
                           value1     => fazccmt_record.deprn_basis_rule_id, p_log_level_rec => p_log_level_rec);
        end if;

        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazccmt', p_log_level_rec => p_log_level_rec);
        return (FALSE);

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazccmt', p_log_level_rec => p_log_level_rec);
        return (False);

end FAZCCMT;

--------------------------------------------------------------

-- sob_book_type_code
function fazcsob
          (X_set_of_books_id   in  number,
           X_mrc_sob_type_code out NOCOPY varchar, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
         return boolean is

   l_found       boolean;
   l_count       number;

begin

   if (nvl(fazcsob_record.set_of_books_id, -1) = X_set_of_books_id) then
      X_mrc_sob_type_code := fazcsob_record.mrc_sob_type_code;
      return (TRUE);
   else
      if fazcsob_table.count = 0 then
         l_found := FALSE;
      end if;

      for i in 1..fazcsob_table.count loop

         if (fazcsob_table(i).set_of_books_id = X_set_of_books_id) then
            l_count := i;
            l_found := TRUE;
            exit;
         else
            l_found := FALSE;
         end if;

      end loop;

      if l_found = TRUE then
         X_mrc_sob_type_code      := fazcsob_table(l_count).mrc_sob_type_code;
         fazcsob_record           := fazcsob_table(l_count);
      else
         SELECT set_of_books_id,
                mrc_sob_type_code
           INTO fazcsob_record.set_of_books_id,
                fazcsob_record.mrc_sob_type_code
           FROM gl_sets_of_books
          WHERE set_of_books_id = X_set_of_books_id;

         fazcsob_table(fazcsob_table.count + 1)    := fazcsob_record;
      end if;
   end if;

   X_mrc_sob_type_code := fazcsob_record.mrc_sob_type_code;
   return (TRUE);

exception
   when NO_DATA_FOUND then
        fa_srvr_msg.add_message(calling_fn => NULL,
                        name       => 'FA_CACHE_SETS_OF_BOOKS',
                        token1     => 'SET_OF_BOOKS_ID',
                        value1     => X_set_of_books_id, p_log_level_rec => p_log_level_rec);
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazcsob', p_log_level_rec => p_log_level_rec);
        return (FALSE);
   when others then
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazcsob', p_log_level_rec => p_log_level_rec);
        return(FALSE);

end fazcsob;

-------------------------------------------------------------------

FUNCTION fazccbd
          (X_book    in varchar2,
           X_cat_id  in number,
           X_jdpis   in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
         return boolean is

   l_found           boolean;
   l_count           number;

begin <<FAZCCBD>>

   if (fazccbd_record.book_type_code = X_book and
       fazccbd_record.category_id    = X_cat_id and
       fazccbd_record.start_dpis    <= to_date(X_jdpis, 'J') and
       nvl(fazccbd_record.end_dpis, to_date(X_jdpis, 'J')) >=
           to_date(X_jdpis, 'J')) then
      return (TRUE);
   else
      if fazccbd_table.count = 0 then
         l_found := FALSE;
      end if;

      for i in 1..fazccbd_table.count loop

         if (fazccbd_table(i).book_type_code = X_book and
             fazccbd_table(i).category_id    = X_cat_id and
             fazccbd_table(i).start_dpis      <= to_date(X_jdpis, 'J') and
             nvl(fazccbd_table(i).end_dpis, to_date(X_jdpis, 'J')) >=
                 to_date(X_jdpis, 'J')) then
            l_count := i;
            l_found := TRUE;
            exit;
         else
            l_found := FALSE;
         end if;
      end loop;

      if l_found = TRUE then
         fazccbd_record           := fazccbd_table(l_count);
      else
         -- do not let array get to big.. once it is at the
         -- max begin clearing values from the array
         if fazccbd_table.count = G_max_array_size then

            -- clear the first record
            fazccbd_record.book_type_code := 'NULL';

            -- clear the first member in the table
            fazccbd_table.delete(1);

            -- reset values so there is no missing member for future use
            l_count := fazccbd_table.count;

            for i in 1..l_count loop
               -- copy the next member into the current one
               fazccbd_table(i) := fazccbd_table(i+1);
            end loop;

            -- delete the last member in the array which is now a duplicate
            fazccbd_table.delete(l_count + 1);

         end if;

         SELECT *
           INTO fazccbd_record
                FROM fa_category_book_defaults
               WHERE book_type_code = X_book
                 AND category_id = X_cat_id
                 AND to_date (X_jdpis, 'J') BETWEEN
                        start_dpis AND
                        nvl (end_dpis, to_date (X_jdpis, 'J'));

         fazccbd_table(fazccbd_table.count + 1):= fazccbd_record;

      end if;
   end if;

   return (TRUE);

exception
   when NO_DATA_FOUND then
        fa_srvr_msg.add_message(calling_fn => NULL,
                        name       => 'FA_CACHE_CATEGORY_BOOK_DEF',
                        token1     => 'BOOK',
                        value1     => X_book,
                        token2     => 'CATEGORY_ID',
                        value2     => X_cat_id,
                        token3     => 'DATE',
                        value3     => to_date(X_jdpis, 'J'));
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazccbd', p_log_level_rec => p_log_level_rec);
        return (FALSE);

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazccbd', p_log_level_rec => p_log_level_rec);
        return (FALSE);

end fazccbd;

-------------------------------------------------------------------

FUNCTION fazcat
          (X_cat_id  in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
         return boolean is

   l_found           boolean;
   l_count           number;

begin <<FAZCAT>>

   if (fazcat_record.category_id = X_cat_id) then
      return (TRUE);
   else
      if fazcat_table.count = 0 then
         l_found := FALSE;
      end if;

      for i in 1..fazcat_table.count loop

         if (fazcat_table(i).category_id = X_cat_id)then
            l_count := i;
            l_found := TRUE;
            exit;
         else
            l_found := FALSE;
         end if;

      end loop;


      if l_found = TRUE then
         fazcat_record           := fazcat_table(l_count);
      else
         -- do not let array get to big.. once it is at the
         -- max begin clearing values from the array
         if fazcat_table.count = G_max_array_size then

            -- clear the first record
            fazcat_record.category_id := NULL;

            -- clear the first member in the table
            fazcat_table.delete(1);

            -- reset values so there is no missing member for future use
            l_count := fazcat_table.count;

            for i in 1..l_count loop
                -- copy the next member into the current one
                fazcat_table(i) := fazcat_table(i+1);
            end loop;

            -- delete the last member in the array which is now a duplicate
            fazcat_table.delete(l_count + 1);

         end if;

         SELECT *
           INTO fazcat_record
           FROM fa_categories
          WHERE category_id = X_cat_id;

         fazcat_table(fazcat_table.count + 1):= fazcat_record;

      end if;
   end if;

   return (TRUE);

exception
   when NO_DATA_FOUND then
        fa_srvr_msg.add_message(calling_fn => NULL,
                        name       => 'FA_CACHE_CATEGORIES',
                        token1     => 'CATEGORY',
                        value1     => X_cat_id, p_log_level_rec => p_log_level_rec);
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazcat', p_log_level_rec => p_log_level_rec);
        return (FALSE);

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazcat', p_log_level_rec => p_log_level_rec);
        return (FALSE);

end fazcat;

------------------------------------------------------------------------

Function fazsys (p_log_level_rec        IN
FA_API_TYPES.log_level_rec_type default null)
return boolean is

begin <<FAZSYS>>

   if (fazsys_record.company_name is not null) then
      return (TRUE);
   else
      SELECT *
        INTO fazsys_record
        FROM fa_system_controls;
   end if;

   return (TRUE);

exception
   when NO_DATA_FOUND then
        fa_srvr_msg.add_message(calling_fn => NULL,
                        name       => 'FA_SYSTEM_CONTROLS', p_log_level_rec => p_log_level_rec);
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazsys', p_log_level_rec => p_log_level_rec);
        return (FALSE);

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazsys', p_log_level_rec => p_log_level_rec);
        return (FALSE);

end FAZSYS;


---------------------------------------------------------------------

Function fazctbk
          (x_corp_book     in     varchar2,
           x_asset_type    in     varchar2,
           x_tax_book_tbl     out NOCOPY fazctbk_tbl_type, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
         return boolean is

   l_tax_rec            fazctbk_pvt_rec_type;
   l_found              boolean := FALSE;
   l_main_array_count   number  := fazctbk_main_tbl.count;
   l_corp_array_count   number  := fazctbk_corp_tbl.count;
   l_tax_array_count    number  := fazctbk_tax_tbl.count;

   i number  := 0;

   CURSOR c_tax_books IS
     select distribution_source_book,
            book_type_code,
            nvl(allow_cip_assets_flag, 'NO') allow_cip_assets_flag,
            nvl(immediate_copy_flag, 'NO') immediate_copy_flag,
            nvl(copy_group_addition_flag, 'N') copy_group_addition_flag
       from fa_book_controls
      where book_class = 'TAX'
        and distribution_source_book = x_corp_book
        and date_ineffective is null;

begin <<FAZCTBK>>

   -- check if values are the same as the last cobination requested

   if ((nvl(fazctbk_last_book_used, 'NULL') = x_corp_book ) and
       (nvl(fazctbk_last_type_used, 'NULL') = x_asset_type)) then
      x_tax_book_tbl := fazctbk_tax_tbl;
      return (TRUE);
   else
      -- delete the existing return table contents
      fazctbk_tax_tbl.delete;
      l_tax_array_count := 0;

      -- see if the corp book in question has previously been cached
      for i in 1..l_corp_array_count loop

         if (fazctbk_corp_tbl(i) = x_corp_book) then  -- book_type_code
             l_found := TRUE;
             exit;
         else
             l_found := FALSE;
         end if;

      end loop;

      if l_found then

         -- load the values for this particular asset type and book into return table
         for i in 1..fazctbk_main_tbl.count loop
            if (((x_asset_type = 'CIP' and
                  fazctbk_main_tbl(i).allow_cip_assets_flag = 'YES') or
                 (x_asset_type = 'CAPITALIZED' and
                  fazctbk_main_tbl(i).immediate_copy_flag = 'YES') or
                 (x_asset_type = 'GROUP' and
                  fazctbk_main_tbl(i).copy_group_addition_flag = 'Y' and
                  fazctbk_main_tbl(i).immediate_copy_flag = 'YES')) and
                (fazctbk_main_tbl(i).corp_book = x_corp_book)) then

                -- add record to return table
                fazctbk_tax_tbl(l_tax_array_count + 1) := fazctbk_main_tbl(i).tax_book;  -- book_type_code
                l_tax_array_count := l_tax_array_count + 1;
             end if;
         end loop;

      else

         -- corp book not been cached before so first get each enabled tax book regardless
         -- of auto-copy / cip-intax value into the main table

         for c_rec in c_tax_books loop
            -- populate the tax record

            l_tax_rec.corp_book                := c_rec.distribution_source_book;
            l_tax_rec.tax_book                 := c_rec.book_type_code;
            l_tax_rec.allow_cip_assets_flag    := c_rec.allow_cip_assets_flag;
            l_tax_rec.immediate_copy_flag      := c_rec.immediate_copy_flag;
            l_tax_rec.copy_group_addition_flag := c_rec.copy_group_addition_flag;

            -- add record to the main association table
            fazctbk_main_tbl(l_main_array_count + 1) := l_tax_rec;
            l_main_array_count := l_main_array_count + 1;
         end loop;

         -- add the corp book to the array of corp book to indicate it's been processed
         fazctbk_corp_tbl(l_corp_array_count + 1) := x_corp_book;
         l_corp_array_count := l_corp_array_count + 1;


         -- load the values for this particular asset type and book into return table
         for i in 1..fazctbk_main_tbl.count loop
            if (((x_asset_type = 'CIP' and
                  fazctbk_main_tbl(i).allow_cip_assets_flag = 'YES') or
                 (x_asset_type = 'CAPITALIZED' and
                  fazctbk_main_tbl(i).immediate_copy_flag = 'YES') or
                 (x_asset_type = 'GROUP' and
                  fazctbk_main_tbl(i).copy_group_addition_flag = 'Y' and
                  fazctbk_main_tbl(i).immediate_copy_flag = 'YES')) and
                (fazctbk_main_tbl(i).corp_book = x_corp_book)) then
                 -- add record to return table
                fazctbk_tax_tbl(l_tax_array_count + 1) := fazctbk_main_tbl(i).tax_book;
                l_tax_array_count := l_tax_array_count + 1;
            end if;
         end loop;

      end if;

      fazctbk_last_book_used := x_corp_book;
      fazctbk_last_type_used := x_asset_type;

   end if;

   -- set the return table to the new loaded one
   x_tax_book_tbl := fazctbk_tax_tbl;
   return (TRUE);

exception
   when NO_DATA_FOUND then
        fa_srvr_msg.add_message(calling_fn => NULL,
                        name       => 'FA_CACHE_BOOK_CONTROLS',
                        token1     => 'BOOK',
                        value1     => X_corp_book, p_log_level_rec => p_log_level_rec);
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazctbk', p_log_level_rec => p_log_level_rec);
        return (FALSE);

   when others then
        fa_srvr_msg.add_sql_error (calling_fn => 'fa_cache_pkg.fazctbk', p_log_level_rec => p_log_level_rec);
        return (FALSE);

end fazctbk;


---------------------------------------------------------------------

Function fazcrsob
          (x_book_type_code     in     varchar2,
           x_sob_tbl               out NOCOPY fazcrsob_sob_tbl_type, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
         return boolean is

   l_sob_rec            fazcrsob_pvt_rec_type;
   l_found              boolean;
   l_main_array_count   number  := fazcrsob_main_tbl.count;
   l_book_array_count   number  := fazcrsob_book_tbl.count;
   l_sob_array_count    number  := fazcrsob_sob_tbl.count;

   i number  := 0;

   CURSOR r_sob_id is
   SELECT set_of_books_id
     FROM fa_mc_book_controls
    WHERE book_type_code          = x_book_type_code
      AND enabled_flag            = 'Y'
      AND mrc_converted_flag      = 'Y';


begin <<FAZCRSOB>>

   -- check if values are the same as the last cobination requested

   if (nvl(fazcrsob_last_book_used, 'NULL') = x_book_type_code) then
      -- set the return table to the new loaded one
      x_sob_tbl := fazcrsob_sob_tbl;
   else
      -- delete the existing return table contents
      fazcrsob_sob_tbl.delete;
      l_sob_array_count := 0;

      -- see if the book in question has previously been cached
      for i in 1..l_book_array_count loop

          if (fazcrsob_book_tbl(i) = x_book_type_code) then
              l_found := TRUE;
              exit;
          else
              l_found := FALSE;
          end if;

      end loop;

      if l_found then

         -- load the reporting sobs into the return table
         for i in 1..fazcrsob_main_tbl.count loop
            if (fazcrsob_main_tbl(i).book_type_code = x_book_type_code) then

               -- add record to return table
               fazcrsob_sob_tbl(l_sob_array_count + 1) := fazcrsob_main_tbl(i).set_of_books_id;
               l_sob_array_count := l_sob_array_count + 1;
            end if;
         end loop;

      else

         -- book has not been cached before so first get each enabled
         -- reporting book that is enabled and converted

         for c_sob_id in r_sob_id loop
            -- populate the tax record
            l_sob_rec.book_type_code   := x_book_type_code;
            l_sob_rec.set_of_books_id  := c_sob_id.set_of_books_id;

            -- add record to the main association table
            fazcrsob_main_tbl(l_main_array_count + 1) := l_sob_rec;
            l_main_array_count := l_main_array_count + 1;
         end loop;

         -- add the book to the array of books to indicate it's been processed
         fazcrsob_book_tbl(l_book_array_count + 1) := x_book_type_code;
         l_book_array_count := l_book_array_count + 1;


         -- load the values for this particular asset type and book into return table
         for i in 1..fazcrsob_main_tbl.count loop
            if (fazcrsob_main_tbl(i).book_type_code = x_book_type_code) then

               -- add record to return table
               fazcrsob_sob_tbl(l_sob_array_count + 1) := fazcrsob_main_tbl(i).set_of_books_id;
               l_sob_array_count := l_sob_array_count + 1;
            end if;
         end loop;

      end if;

      fazcrsob_last_book_used := x_book_type_code;

   end if;

   -- set the return table to the new loaded one
   x_sob_tbl := fazcrsob_sob_tbl;

   return (TRUE);

exception
   when others then
        fa_srvr_msg.add_sql_error (calling_fn => 'fa_cache_pkg.fazcrsob', p_log_level_rec => p_log_level_rec);
        return (FALSE);

end fazcrsob;

-----------------------------------------------------------------------------

Function fazccvt
          (x_prorate_convention_code in  varchar2,
           x_fiscal_year_name        in  varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
         return boolean is

   l_found       boolean;
   l_count       number;

begin

   if (nvl(fazccvt_record.prorate_convention_code, 'NULL') = X_prorate_convention_code and
       nvl(fazccvt_record.fiscal_year_name, 'NULL') = X_fiscal_year_name) then
      return (TRUE);
   else
      if fazccvt_table.count = 0 then
         l_found := FALSE;
      end if;

      for i in 1..fazccvt_table.count loop

         if (fazccvt_table(i).prorate_convention_code = X_prorate_convention_code and
             fazccvt_table(i).fiscal_year_name        = X_fiscal_year_name) then
            l_count := i;
            l_found := TRUE;
            exit;
         else
            l_found := FALSE;
         end if;

      end loop;

      if l_found = TRUE then
         fazccvt_record           := fazccvt_table(l_count);
      else
         -- do not let array get to big.. once it is at the
         -- max begin clearing values from the array
         if fazccvt_table.count = G_max_array_size then

            -- clear the first record
            fazccvt_record.fiscal_year_name := 'NULL';

            -- clear the first member in the table
            fazccvt_table.delete(1);

            -- reset values so there is no missing member for future use
            l_count := fazccvt_table.count;

            for i in 1..l_count loop
               -- copy the next member into the current one
               fazccvt_table(i) := fazccvt_table(i+1);
            end loop;

            -- delete the last member in the array which is now a duplicate
            fazccvt_table.delete(l_count + 1);

         end if;

         SELECT *
           INTO fazccvt_record
           FROM fa_convention_types
          WHERE prorate_convention_code = X_prorate_convention_code
            AND fiscal_year_name = X_fiscal_year_name;

         fazccvt_table(fazccvt_table.count + 1):= fazccvt_record;
     end if;
  end if;

  return (TRUE);

exception
   when NO_DATA_FOUND then
        fa_srvr_msg.add_message(calling_fn => NULL,
                        name       => 'FA_CACHE_CONVENTION_TYPES',
                        token1     => 'CONVENTION',
                        value1     => X_prorate_convention_code,
                        token2     => 'FISCAL_YEAR_NAME',
                        value2     => X_fiscal_year_name, p_log_level_rec => p_log_level_rec);
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazccvt', p_log_level_rec => p_log_level_rec);
        return (FALSE);
   when others then
        fa_srvr_msg.add_sql_error (
           calling_fn => 'fa_cache_pkg.fazccvt', p_log_level_rec => p_log_level_rec);
        return (FALSE);
end fazccvt;

-----------------------------------------------------------------------------

Function fazcfy
          (x_fiscal_year_name in varchar2,
           x_fiscal_year      in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
         return boolean is

   l_found       boolean;
   l_count       number;

begin


   if (nvl(fazcfy_record.fiscal_year_name, 'NULL') = X_fiscal_year_name and
       nvl(fazcfy_record.fiscal_year,      -99)    = X_fiscal_year) then
      return (TRUE);
   else
      if fazcfy_table.count = 0 then
         l_found := FALSE;
      end if;

      for i in 1..fazcfy_table.count loop
         if (fazcfy_table(i).fiscal_year_name = X_fiscal_year_name and
             fazcfy_table(i).fiscal_year      = X_fiscal_year) then
            l_count := i;
            l_found := TRUE;
            exit;
         else
            l_found := FALSE;
         end if;

      end loop;

      if l_found = TRUE then
         fazcfy_record           := fazcfy_table(l_count);
      else
         -- do not let array get to big.. once it is at the
         -- max begin clearing values from the array
         if fazcfy_table.count  = G_max_array_size then

            -- clear the first record
            fazcfy_record.fiscal_year_name := 'NULL';

            -- clear the first member in the table
            fazcfy_table.delete(1);

            -- reset values so there is no missing member for future use
            l_count := fazcfy_table.count;

            for i in 1..l_count loop
               -- copy the next member into the current one
               fazcfy_table(i) := fazcfy_table(i+1);
            end loop;

            -- delete the last member in the array which is now a duplicate
            fazcfy_table.delete(l_count + 1);

         end if;

         SELECT *
           INTO fazcfy_record
           FROM fa_fiscal_year
          WHERE fiscal_year_name = X_fiscal_year_name
            AND fiscal_year      = X_fiscal_year;

         fazcfy_table(fazcfy_table.count + 1):= fazcfy_record;

      end if;
   end if;

   return (TRUE);

exception
   when NO_DATA_FOUND then
        fa_srvr_msg.add_message(calling_fn => NULL,
                        name       => 'FA_CACHE_FISCAL_YEARS',
                        token1     => 'FY_NAME',
                        value1     => X_fiscal_year_name,
                        token2     => 'FY',
                        value2     => X_fiscal_year, p_log_level_rec => p_log_level_rec);
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazcfy', p_log_level_rec => p_log_level_rec);
        return (FALSE);

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazcfy', p_log_level_rec => p_log_level_rec);
        return (FALSE);
end fazcfy;

-----------------------------------------------------------------------------

Function fazcdp
          (x_book_type_code  in  varchar2,
           x_period_counter  in  number   default null,
           x_effective_date  in  date     default null, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
         return boolean is

   l_found       boolean;
   l_count       number;

begin

   if ((nvl(fazcdp_record.book_type_code, 'NULL') = X_book_type_code) and
       (((X_period_counter is not null) and
         (nvl(fazcdp_record.period_counter, -99)   = X_period_counter)) or
        ((x_effective_date is not null) and
         (fazcdp_record.period_open_date                <= x_effective_date) and
         (nvl(fazcdp_record.period_close_date, sysdate) >= x_effective_date)) or
        (X_period_counter is null and
         x_effective_date is null and
         fazcdp_record.period_close_date is null))) then
      null;
   else
      if fazcdp_table.count = 0 then
         l_found := FALSE;
      end if;

      for i in 1..fazcdp_table.count loop

         if ((fazcdp_table(i).book_type_code  = X_book_type_code) and
             ((X_period_counter is not null and
               fazcdp_table(i).period_counter = X_period_counter) or
              (x_effective_date is not null and
               (fazcdp_table(i).period_open_date                <= x_effective_date) and
               (nvl(fazcdp_table(i).period_close_date, sysdate) >= x_effective_date)) or
              (X_period_counter is null and
               x_effective_date is null and
               fazcdp_table(i).period_close_date is null))) then
            l_count := i;
            l_found := TRUE;
            exit;
         else
            l_found := FALSE;
         end if;

      end loop;

      if l_found = TRUE then
         fazcdp_record           := fazcdp_table(l_count);
         fazcdp_index            := l_count;
      else
         -- do not let array get to big.. once it is at the
         -- max begin clearing values from the array
         if fazcdp_table.count = G_max_array_size then

            -- clear the first record
            fazcdp_record.book_type_code := 'NULL';
            fazcdp_record.period_counter := NULL;

            -- clear the first member in the table
            fazcdp_table.delete(1);

            -- reset values so there is no missing member for future use
            l_count := fazcdp_table.count;

            for i in 1..l_count loop
               -- copy the next member into the current one
               fazcdp_table(i) := fazcdp_table(i+1);
            end loop;

            -- delete the last member in the array which is now a duplicate
            fazcdp_table.delete(l_count + 1);

         end if;

         if X_period_counter is not null then
            SELECT book_type_code,
                   period_name,
                   period_counter,
                   fiscal_year,
                   period_num,
                   period_open_date,
                   period_close_date,
                   calendar_period_open_date,
                   calendar_period_close_date,
                   deprn_run
              INTO fazcdp_record
              FROM fa_deprn_periods
             WHERE book_type_code = X_book_type_code
               AND period_counter = X_period_counter;
         elsif X_effective_date is not null then
            SELECT book_type_code,
                   period_name,
                   period_counter,
                   fiscal_year,
                   period_num,
                   period_open_date,
                   period_close_date,
                   calendar_period_open_date,
                   calendar_period_close_date,
                   deprn_run
              INTO fazcdp_record
              FROM fa_deprn_periods
             WHERE book_type_code = X_book_type_code
               AND x_effective_date between
                       period_open_date and nvl(period_close_date, sysdate);
         else
            SELECT book_type_code,
                   period_name,
                   period_counter,
                   fiscal_year,
                   period_num,
                   period_open_date,
                   period_close_date,
                   calendar_period_open_date,
                   calendar_period_close_date,
                   deprn_run
              INTO fazcdp_record
              FROM fa_deprn_periods
             WHERE book_type_code = X_book_type_code
               AND period_close_date is null;
         end if;

         fazcdp_table(fazcdp_table.count + 1):= fazcdp_record;
         fazcdp_index                        := fazcdp_table.count;

      end if;
   end if;

   return (TRUE);

exception
   when NO_DATA_FOUND then
        fa_srvr_msg.add_message(calling_fn => NULL,
                        name       => 'FA_CACHE_DEPRN_PERIODS',
                        token1     => 'BOOK',
                        value1     => X_book_type_code,
                        token2     => 'PERIOD_COUNTER',
                        value2     => X_period_counter,
                        token3     => 'DATE',
                        value3     => X_effective_date, p_log_level_rec => p_log_level_rec);
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazcdp', p_log_level_rec => p_log_level_rec);
        return (FALSE);

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazcdp', p_log_level_rec => p_log_level_rec);
        return (FALSE);
end fazcdp;

-----------------------------------------------------------------------------

Function fazcdp_clr
          (X_book in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
         return boolean is

   l_count   number;

BEGIN <<fazcdp_clr>>

   -- clear the record
   fazcdp_record.book_type_code := 'NULL';
   fazcdp_record.period_counter := NULL;

   -- clear the member in the table. since the cache should always
   -- be called before doing this (i.e. faxcps) we know the global
   -- index variable will have the correct index from fazcdp

   fazcdp_table.delete(fazcdp_index);

   -- reset the values so there is no missing member for future use
   l_count := fazcdp_table.count;

   for i in fazcdp_index..l_count loop
       -- copy the next member into the current one
       fazcdp_table(i) := fazcdp_table(i+1);
   end loop;

   -- delete the last member in the array which is now a duplicate
   fazcdp_table.delete(l_count + 1);

   return TRUE;

exception
   when others then
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazcdp_clr', p_log_level_rec => p_log_level_rec);
        return (FALSE);

END fazcdp_clr;

-----------------------------------------------------------------------------

Function fazprof return boolean IS

   l_fa_crl_enabled                 varchar2(3);
   l_fa_print_debug                 varchar2(3);
   l_fa_use_threshold               varchar2(3);
   l_fa_gen_expense_account         varchar2(3);
   l_fa_pregen_asset_account        varchar2(3);
   l_fa_pregen_book_account         varchar2(3);
   l_fa_pregen_cat_account          varchar2(3);
   l_fa_mcp_all_cost_adj            varchar2(3);
   l_fa_deprn_override_enabled      varchar2(3);
   l_fa_deprn_basis_enabled         varchar2(3);
   l_fa_batch_size                  varchar2(15);
   l_fa_custom_gen_ccid             varchar2(3);

   fazprof_err                      exception;

BEGIN

   if not fa_profile_init then

      -- load profiles
      fnd_profile.get('FA_DEBUG_FILE', fa_debug_file);
      fnd_profile.get('FA_LARGE_ROLLBACK_SEGMENT', fa_large_rollback);
      fnd_profile.get('FA_ANNUAL_ROUND', fa_annual_round );

      fnd_profile.get('CRL-FA ENABLED', l_fa_crl_enabled);
      fnd_profile.get('PRINT_DEBUG', l_fa_print_debug);
      fnd_profile.get('FA_USE_THRESHOLD', l_fa_use_threshold);
      fnd_profile.get('FA_GEN_EXPENSE_ACCOUNT', l_fa_gen_expense_account);
      fnd_profile.get('FA_PREGEN_ASSET_ACCOUNT', l_fa_pregen_asset_account);
      fnd_profile.get('FA_PREGEN_BOOK_ACCOUNT', l_fa_pregen_book_account);
      fnd_profile.get('FA_PREGEN_CAT_ACCOUNT', l_fa_pregen_cat_account );
      fnd_profile.get('FA_MCP_ALL_COST_ADJ', l_fa_mcp_all_cost_adj);
      fnd_profile.get('FA_DEPRN_OVERRIDE_ENABLED', l_fa_deprn_override_enabled);
      fnd_profile.get('FA_ENABLED_DEPRN_BASIS_FORMULA', l_fa_deprn_basis_enabled);

      fnd_profile.get('FA_BATCH_SIZE', l_fa_batch_size);
      fnd_profile.get('FA_CUSTOM_GEN_CCID', l_fa_custom_gen_ccid);

      if (nvl(l_fa_crl_enabled, 'N') = 'Y') then
         fa_crl_enabled := TRUE;
      else
         fa_crl_enabled := FALSE;
      end if;

      if (nvl(l_fa_print_debug, 'N') = 'Y') then
         fa_print_debug := TRUE;
      else
         fa_print_debug := FALSE;
      end if;

      if (nvl(l_fa_use_threshold, 'N') = 'Y') then
         fa_use_threshold := TRUE;
      else
         fa_use_threshold := FALSE;
      end if;

      if (nvl(l_fa_gen_expense_account, 'N') = 'Y') then
         fa_gen_expense_account := TRUE;
      else
         fa_gen_expense_account := FALSE;
      end if;

      if (nvl(l_fa_pregen_asset_account, 'Y') = 'Y') then
         fa_pregen_asset_account := TRUE;
      else
         fa_pregen_asset_account := FALSE;
      end if;

      if (nvl(l_fa_pregen_book_account, 'Y') = 'Y') then
         fa_pregen_book_account := TRUE;
      else
         fa_pregen_book_account := FALSE;
      end if;

      if (nvl(l_fa_pregen_cat_account, 'Y') = 'Y') then
         fa_pregen_cat_account := TRUE;
      else
         fa_pregen_cat_account := FALSE;
      end if;

      if (nvl(l_fa_mcp_all_cost_adj, 'N') = 'Y') then
         fa_mcp_all_cost_adj := TRUE;
      else
         fa_mcp_all_cost_adj := FALSE;
      end if;

      if (nvl(l_fa_deprn_override_enabled, 'N') = 'Y') then
         fa_deprn_override_enabled := TRUE;
      else
         fa_deprn_override_enabled := FALSE;
      end if;

      if (nvl(l_fa_deprn_basis_enabled, 'N') = 'Y') then
         fa_enabled_deprn_basis_formula := TRUE;
      else
         fa_enabled_deprn_basis_formula := FALSE;
      end if;

      if (nvl(l_fa_custom_gen_ccid, 'N') = 'Y') then
         fa_custom_gen_ccid := TRUE;
      else
         fa_custom_gen_ccid := FALSE;
      end if;

      begin
         fa_batch_size  := to_number(nvl(l_fa_batch_size, '200'));
      exception
        when others then
          fa_batch_size  := 200;
      end;

      -- proactively load the applications release
      if not fazarel then
         raise fazprof_err;
      end if;

      fa_profile_init := true;

   end if;

   return true;

EXCEPTION
   WHEN fazprof_err then
        fa_srvr_msg.add_message(calling_fn => 'fa_cache_pkg.fazprof');
        return (FALSE);

   WHEN others then
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazprof');
        return (FALSE);

END fazprof;

-----------------------------------------------------------------------------

Function fazcsgr(
     X_super_group_id  in  number,
     X_book_type_code  in  varchar2,
     X_period_counter  in  number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
return boolean is

   CURSOR c_get_super_group_rules is
         select super_group_id,
                book_type_code,
                start_period_counter,
                end_period_counter,
                deprn_method_code,
                basic_rate,
                adjusted_rate,
                percent_salvage_value
         from   fa_super_group_rules
         where  super_group_id = X_super_group_id
         and    book_type_code = X_book_type_code
         and    X_period_counter between start_period_counter
                                     and nvl(end_period_counter, X_period_counter)
         and    date_ineffective is null;

   CURSOR c_get_init_super_group_rules is
         select super_group_id,
                book_type_code,
                0,
                start_period_counter -1,
                deprn_method_code,
                0,
                0,
                1
         from   fa_super_group_rules
         where  super_group_id = X_super_group_id
         and    book_type_code = X_book_type_code
         and    date_ineffective is null
         order by start_period_counter;

   l_found       boolean;
   l_count       number;

begin
   if (fazcsgr_record.book_type_code = X_book_type_code and
       fazcsgr_record.super_group_id    = X_super_group_id and
       X_period_counter >= fazcsgr_record.start_period_counter and
       X_period_counter <= nvl(fazcsgr_record.end_period_counter, X_period_counter)) then
      return (TRUE);
   else
      if fazcsgr_table.count = 0 then
         l_found := FALSE;
      end if;

      for i in 1..fazcsgr_table.count loop

         if (fazcsgr_table(i).book_type_code = X_book_type_code and
             fazcsgr_table(i).super_group_id = X_super_group_id and
             X_period_counter >= fazcsgr_table(i).start_period_counter and
             X_period_counter <= nvl(fazcsgr_table(i).end_period_counter, X_period_counter)) then
            l_count := i;
            l_found := TRUE;
            exit;
         else
            l_found := FALSE;
         end if;

      end loop;

      if l_found = TRUE then
         fazcsgr_record           := fazcsgr_table(l_count);
      else
         -- do not let array get to big.. once it is at the
         -- max begin clearing values from the array
         if fazcsgr_table.count = G_max_array_size then

            -- clear the first record
            fazcsgr_record.book_type_code := 'NULL';

            -- clear the first member in the table
            fazcsgr_table.delete(1);

            -- reset values so there is no missing member for future use
            l_count := fazcsgr_table.count;

            for i in 1..l_count loop
               -- copy the next member into the current one
               fazcsgr_table(i) := fazcsgr_table(i+1);
            end loop;

            -- delete the last member in the array which is now a duplicate
            fazcsgr_table.delete(l_count + 1);

         end if;

         OPEN c_get_super_group_rules;
         FETCH c_get_super_group_rules
             INTO fazcsgr_record.super_group_id,
                  fazcsgr_record.book_type_code,
                  fazcsgr_record.start_period_counter,
                  fazcsgr_record.end_period_counter,
                  fazcsgr_record.deprn_method_code,
                  fazcsgr_record.basic_rate,
                  fazcsgr_record.adjusted_rate,
                  fazcsgr_record.percent_salvage_value;

         -- Bug4037112
         -- Added to handle the case that super group rule
         -- is not available. Earlier periods
         if c_get_super_group_rules%NOTFOUND then
            OPEN c_get_init_super_group_rules;
            FETCH c_get_init_super_group_rules
                INTO fazcsgr_record.super_group_id,
                     fazcsgr_record.book_type_code,
                     fazcsgr_record.start_period_counter,
                     fazcsgr_record.end_period_counter,
                     fazcsgr_record.deprn_method_code,
                     fazcsgr_record.basic_rate,
                     fazcsgr_record.adjusted_rate,
                     fazcsgr_record.percent_salvage_value;
               CLOSE c_get_init_super_group_rules;
         end if;

         CLOSE c_get_super_group_rules;

         fazcsgr_table(fazcsgr_table.count + 1):= fazcsgr_record;

      end if;
   end if;

   return (TRUE);

exception
   when NO_DATA_FOUND then
        fa_srvr_msg.add_message(calling_fn => NULL,
                        name       => 'FA_CACHE_SUPER_GROUP_RULES',
                        token1     => 'BOOK',
                        value1     => X_book_type_code,
                        token2     => 'PERIOD_COUNTER',
                        value2     => X_period_counter, p_log_level_rec => p_log_level_rec);
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazcsgr', p_log_level_rec => p_log_level_rec);
        return (FALSE);

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazcsgr', p_log_level_rec => p_log_level_rec);
        return (FALSE);
end fazcsgr;

-----------------------------------------------------------------------------

Function fazarel return boolean is

   l_release_name         varchar2(30);
   l_other_release_info   varchar2(2000);
   fazarel_err            exception;

begin <<FAZAREL>>

   if (fazarel_release = 999999999) then

      if not FND_RELEASE.get_release (l_release_name, l_other_release_info) then
         null;
      end if;

      if (substrb(l_release_name, 1, 2) = '11') then
         fazarel_release := 11;
      elsif (substrb(l_release_name, 1, 2) = '12') then
         fazarel_release := 12;
      else
         -- unknown release
         raise fazarel_err;
      end if;
   end if;

   return (TRUE);

Exception
   when fazarel_err then
        fa_srvr_msg.add_message(calling_fn => 'fa_cache_pkg.fazarel');
        return (FALSE);

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_cache_pkg.fazarel');
        return (FALSE);

end FAZAREL;

END FA_CACHE_PKG;

/
