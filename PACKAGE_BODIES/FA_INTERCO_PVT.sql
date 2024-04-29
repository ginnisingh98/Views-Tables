--------------------------------------------------------
--  DDL for Package Body FA_INTERCO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_INTERCO_PVT" AS
/* $Header: FAVINCOB.pls 120.15.12010000.3 2009/07/19 11:34:26 glchen ship $ */

g_group_reclass boolean;

FUNCTION do_all_books
   (p_src_trans_rec       in FA_API_TYPES.trans_rec_type,
    p_src_asset_hdr_rec   in FA_API_TYPES.asset_hdr_rec_type,
    p_dest_trans_rec      in FA_API_TYPES.trans_rec_type,
    p_dest_asset_hdr_rec  in FA_API_TYPES.asset_hdr_rec_type,
    p_calling_fn          in varchar2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_reporting_flag          varchar2(1);
   l_set_of_books_id         number;
   l_sob_tbl                 FA_CACHE_PKG.fazcrsob_sob_tbl_type;

   l_src_asset_hdr_rec       FA_API_TYPES.asset_hdr_rec_type;

   l_calling_fn              varchar2(30) := 'fa_interco_pvt.do_all_books';
   interco_err               EXCEPTION;

BEGIN

   -- set up the global
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'p_claling_fn', p_calling_fn, p_log_level_rec => p_log_level_rec);
   end if;
--exit from the function if intercompany posting not allowed fapost  enhancement strat
   if (nvl(fa_cache_pkg.fazcbc_record.intercompany_posting_flag,'Y') = 'N')then
	if (p_log_level_rec.statement_level) then
 	     fa_debug_pkg.add(l_calling_fn, 'Intercompany posting not allowed exiting', p_calling_fn, p_log_level_rec => p_log_level_rec);
	end if;
	return TRUE;
   end if;
--fapost enhancement end
   if (p_calling_fn = 'fa_group_reclass_pvt.do_grp_reclass'  or
       p_calling_fn = 'fa_group_process_groups_pkg.do_rcl') then
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'group reclass mode', 'TRUE', p_log_level_rec => p_log_level_rec);
      end if;
      g_group_reclass := TRUE;
   else
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'group reclass mode', 'FALSE', p_log_level_rec => p_log_level_rec);
      end if;
      g_group_reclass := FALSE;
   end if;
   -- call the sob cache to get the table of sob_ids
   if not FA_CACHE_PKG.fazcrsob
          (x_book_type_code => p_src_asset_hdr_rec.book_type_code,
           x_sob_tbl        => l_sob_tbl, p_log_level_rec => p_log_level_rec) then
      raise interco_err;
   end if;

   -- loop through each book starting with the primary and
   -- call the private API for each

   l_src_asset_hdr_rec := p_src_asset_hdr_rec;

   FOR l_sob_index in 0..l_sob_tbl.count LOOP

      if (l_sob_index = 0) then
         l_reporting_flag := 'P';
         l_set_of_books_id := p_src_asset_hdr_rec.set_of_books_id;
      else
         l_reporting_flag := 'R';
         l_set_of_books_id := l_sob_tbl(l_sob_index);
         l_src_asset_hdr_rec.set_of_books_id := l_sob_tbl(l_sob_index);
      END IF;

      -- call the cache to set the sob_id used for rounding and other lower
      -- level code for each book.
      if NOT fa_cache_pkg.fazcbcs(X_book => p_src_asset_hdr_rec.book_type_code,
                                  X_set_of_books_id => l_set_of_books_id,
                                  p_log_level_rec => p_log_level_rec) then
         raise interco_err;
      end if;

  -- bug# 5383699 changed l_calling_fn to p_calling_fn
      if not do_intercompany
               (p_src_trans_rec       => p_src_trans_rec       ,
                p_src_asset_hdr_rec   => l_src_asset_hdr_rec   ,
                p_dest_trans_rec      => p_dest_trans_rec      ,
                p_dest_asset_hdr_rec  => p_dest_asset_hdr_rec  ,
                p_calling_fn          => p_calling_fn          ,
                p_mrc_sob_type_code   => l_reporting_flag      ,
                p_log_level_rec       => p_log_level_rec
                ) then raise interco_err;
      end if;

   end loop;

   return true;


EXCEPTION

   WHEN interco_err THEN
        fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;

END do_all_books;


FUNCTION do_intercompany
   (p_src_trans_rec       in FA_API_TYPES.trans_rec_type,
    p_src_asset_hdr_rec   in FA_API_TYPES.asset_hdr_rec_type,
    p_dest_trans_rec      in FA_API_TYPES.trans_rec_type,
    p_dest_asset_hdr_rec  in FA_API_TYPES.asset_hdr_rec_type,
    p_calling_fn          in varchar2,
    p_mrc_sob_type_code   in varchar2,
    p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   -- used for src
   l_src_tbl               interco_tbl_type;
   l_src_count             number;

   -- used for dest
   l_dest_trans_rec        FA_API_TYPES.trans_rec_type;
   l_dest_asset_hdr_rec    FA_API_TYPES.asset_hdr_rec_type;
   l_dest_tbl              interco_tbl_type;
   l_dest_count            number;

   -- used for summing amounts/account types src and dest
   -- ok to sum as net amount (+ or -) will tell us src or dest when we allocate it down
   l_src_summary_tbl       interco_tbl_type;
   l_src_summary_count     number;

   l_dest_summary_tbl      interco_tbl_type;
   l_dest_summary_count    number;

   -- used for getting overall amounts and determining where to allocate (src/dest)
   l_summary_tbl           interco_tbl_type;
   l_summary_count         number;

   -- used for processing the distributions
   l_dist_tbl              dist_tbl_type;
   l_dist_count            number;
   l_dist_tbl_count        number;

   -- used for faxinaj calls
   l_adj                   fa_adjust_type_pkg.fa_adj_row_struct;
   l_interco_ar_acct       varchar2(250);
   l_interco_ap_acct       varchar2(250);
   l_src_source_type_code  varchar2(30);
   l_dest_source_type_code varchar2(30);

   -- not needed
   -- l_src_cat_book_rec      FA_CATEGORY_BOOKS%RowType;
   -- l_dest_cat_book_rec     FA_CATEGORY_BOOKS%RowType;


   -- general variables
   l_account_flex          number;
   l_column_name           varchar2(30);
   l_bal_segnum            number;

   l_seg_name              VARCHAR2(30);
   l_prompt                VARCHAR2(80);
   l_value_set_name        VARCHAR2(60);

   l_cursor_id             number;
   l_statement             varchar2(2000);
   l_dummy                 number;
   l_found                 boolean;
   l_balancing_seg         varchar2(250);
   l_sum_amount            number;
   l_distribution_id       number;
   l_code_combination_id   number;
   l_units                 number;

   l_total_units           number;
   l_total_prorated_amount number;
   l_prorated_amount       number;

   l_amount                number;
   l_count                 number;
   l_loop                  boolean;
   l_status                boolean;

   l_calling_fn            varchar2(40) := 'fa_interco_pvt.do_intercompany';
   interco_err             exception;
   done_exception          exception;

BEGIN


   l_account_flex := fa_cache_pkg.fazcbc_record.ACCOUNTING_FLEX_STRUCTURE;
--exit from the function if intercompany posting not allowed fapost  enhancement strat
   if (nvl(fa_cache_pkg.fazcbc_record.intercompany_posting_flag,'Y') <> 'Y')then
	if (p_log_level_rec.statement_level) then
 	     fa_debug_pkg.add(l_calling_fn, 'Intercompany posting not allowed exiting', p_calling_fn, p_log_level_rec => p_log_level_rec);
	end if;
	return TRUE;
   end if;
--fapost enhancement end

   -- VERIFY the following - think this is returning logical segment number not actual column!!!!
   -- get balancing segment number for the accouting structure
/*
   l_status := fnd_flex_apis.get_qualifier_segnum(appl_id          => 101,
                                                  key_flex_code    => 'GL#',
                                                  structure_number => l_account_flex,
                                                  flex_qual_name   => 'GL_BALANCING',
                                                  segment_number   => l_bal_segnum);
*/
/* Bug 5246620. Wrong segment_number retrieved */
    SELECT s.segment_num INTO l_bal_segnum
      FROM fnd_id_flex_segments s, fnd_segment_attribute_values sav,
           fnd_segment_attribute_types sat
     WHERE s.application_id = 101
       AND s.id_flex_code = 'GL#'
       AND s.id_flex_num = l_account_flex
       AND s.enabled_flag = 'Y'
       AND s.application_column_name = sav.application_column_name
       AND sav.application_id = 101
       AND sav.id_flex_code = 'GL#'
       AND sav.id_flex_num = l_account_flex
       AND sav.attribute_value = 'Y'
       AND sav.segment_attribute_type = sat.segment_attribute_type
       AND sat.application_id = 101
       AND sat.id_flex_code = 'GL#'
       AND sat.unique_flag = 'Y'
       AND sat.segment_attribute_type = 'GL_BALANCING';

--   if not l_status then
--      raise interco_err;
--   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'GL Balancing Segment Number', l_bal_segnum, p_log_level_rec => p_log_level_rec);
   end if;


   l_status := fnd_flex_apis.get_segment_info(
                          x_application_id => 101,
                          x_id_flex_code   => 'GL#',
                          x_id_flex_num    => l_account_flex,
                          x_seg_num        => l_bal_segnum,
                          x_appcol_name    => l_column_name,
                          x_seg_name       => l_seg_name,
                          x_prompt         => l_prompt,
                          x_value_set_name => l_value_set_name );

   if not l_status then
      raise interco_err;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'GL Balancing Column Name', l_column_name, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'processing', 'source', p_log_level_rec => p_log_level_rec);
   end if;


   -- not needed
   -- call the ccb cache for src
   --   if not fa_cache_pkg.fazccb
   --        (X_book   => p_src_asset_hdr_rec.book_type_code,
   --         X_cat_id => p_src_asset_cat_rec.category_id
   --         ) then raise interco_err;
   -- end if;
   --
   -- l_src_cat_book_rec := fa_cache_pkg.fazccb_record;


   -- get each balancing segment and the sum of the amounts
   l_cursor_id := DBMS_SQL.OPEN_CURSOR;

   l_statement :=
      ' select nvl(glcc1.' || l_column_name || ', glcc2.' || l_column_name || '),
               sum(decode(adjustment_type,
                          ''COST'',          decode (debit_credit_flag,
                                                   ''CR'', adjustment_amount,
                                                   adjustment_amount * -1),
                          ''CIP COST'',      decode (debit_credit_flag,
                                                   ''CR'', adjustment_amount,
                                                   adjustment_amount * -1),
                          ''COST CLEARING'', decode (debit_credit_flag,
                                                   ''CR'', adjustment_amount,
                                                   adjustment_amount * -1),
                          ''RESERVE'',       decode (debit_credit_flag,
                                                   ''CR'', adjustment_amount,
                                                   adjustment_amount * -1),
                          ''REVAL RESERVE'', decode (debit_credit_flag,
                                                   ''CR'', adjustment_amount,
                                                   adjustment_amount * -1),
                           0)) ' ||
      ' from fa_adjustments adj,
             fa_distribution_history dh,
             gl_code_combinations glcc1,
             gl_code_combinations glcc2
       where adj.asset_id               = :p_asset_id
         and adj.book_type_code         = :p_book
         and adj.period_counter_created = :p_period_counter
         and adj.transaction_header_id  = :p_thid
         and adj.distribution_id        = dh.distribution_id
         and dh.code_combination_id     = glcc2.code_combination_id
         and adj.code_combination_id(+) = glcc1.code_combination_id
         and adj.track_member_flag is null
       group by nvl(glcc1.' || l_column_name || ', glcc2.' || l_column_name || ')';


   if (p_mrc_sob_type_code = 'R') then
      l_statement := replace(l_statement, 'fa_adjustments', 'fa_mc_adjustments');
      l_statement := replace(l_statement, 'flag is null', 'flag is null
        and adj.set_of_books_id = :p_set_of_books_id');
   end if;

   DBMS_SQL.PARSE(l_cursor_id, l_statement, DBMS_SQL.NATIVE);

   DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_asset_id',       p_src_asset_hdr_rec.asset_id);
   DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_book',           p_src_asset_hdr_rec.book_type_code);
   DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_period_counter', fa_cache_pkg.fazcbc_record.last_period_counter + 1);
   DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_thid',           p_src_trans_rec.transaction_header_id);

   if (p_mrc_sob_type_code = 'R') then
      DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_set_of_books_id', p_src_asset_hdr_rec.set_of_books_id);
   end if;


   DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 1, l_balancing_seg, 30);
   DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 2, l_sum_amount);

   l_dummy := DBMS_SQL.EXECUTE(l_cursor_id);

   loop

      l_src_count := l_src_tbl.count;

      if DBMS_SQL.FETCH_ROWS(l_cursor_id) = 0 then
         exit;
      end if;

      DBMS_SQL.COLUMN_VALUE(l_cursor_id, 1, l_balancing_seg);
      DBMS_SQL.COLUMN_VALUE(l_cursor_id, 2, l_sum_amount);

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'balancing_seg for first source tbl: ', l_balancing_seg, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'sum_amount for first source tbl: ', l_sum_amount, p_log_level_rec => p_log_level_rec);
      end if;


      -- add these values to the table
      l_src_tbl(l_src_count + 1).balancing_segment := l_balancing_seg;
      l_src_tbl(l_src_count + 1).amount            := l_sum_amount;

   end loop;

   DBMS_SQL.CLOSE_CURSOR(l_cursor_id);


   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'source table count', l_src_tbl.count, p_log_level_rec => p_log_level_rec);
   end if;



   -- and now for each destination
   if (p_dest_trans_rec.transaction_header_id is not null) then

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'processing', 'destination', p_log_level_rec => p_log_level_rec);
      end if;

      l_dest_asset_hdr_rec  := p_dest_asset_hdr_rec;
      l_dest_trans_rec      := p_dest_trans_rec;

      -- not needed
      -- call the ccb cache for src
      -- if not fa_cache_pkg.fazccb
      --         (X_book   => l_dest_asset_hdr_rec.book_type_code,
      --          X_cat_id => l_dest_asset_cat_rec.category_id
      --          ) then raise interco_err;
      -- end if;
      --
      -- l_dest_cat_book_rec := fa_cache_pkg.fazccb_record;


      -- get each balancing segment and the sum of the amounts
      l_cursor_id := DBMS_SQL.OPEN_CURSOR;

      l_statement :=
         ' select nvl(glcc1.' || l_column_name || ', glcc2.' || l_column_name || '),
                  sum(decode(adjustment_type,
                             ''COST'',          decode (debit_credit_flag,
                                                      ''DR'', adjustment_amount,
                                                      adjustment_amount * -1),
                             ''CIP COST'',      decode (debit_credit_flag,
                                                      ''DR'', adjustment_amount,
                                                      adjustment_amount * -1),
                             ''COST CLEARING'', decode (debit_credit_flag,
                                                      ''DR'', adjustment_amount,
                                                      adjustment_amount * -1),
                             ''RESERVE'',       decode (debit_credit_flag,
                                                      ''DR'', adjustment_amount,
                                                      adjustment_amount * -1),
                             ''REVAL RESERVE'', decode (debit_credit_flag,
                                                      ''DR'', adjustment_amount,
                                                      adjustment_amount * -1),
                             0)) ' ||
         ' from fa_adjustments adj,
                fa_distribution_history dh,
                gl_code_combinations glcc1,
                gl_code_combinations glcc2
          where adj.asset_id               = :p_asset_id
            and adj.book_type_code         = :p_book
            and adj.period_counter_created = :p_period_counter
            and adj.transaction_header_id  = :p_thid
            and adj.distribution_id        = dh.distribution_id
            and dh.code_combination_id     = glcc2.code_combination_id
            and adj.code_combination_id(+) = glcc1.code_combination_id
            and adj.track_member_flag is null
       group by nvl(glcc1.' || l_column_name || ', glcc2.' || l_column_name || ')';

   if (p_mrc_sob_type_code = 'R') then
      l_statement := replace(l_statement, 'fa_adjustments', 'fa_mc_adjustments');
      l_statement := replace(l_statement, 'flag is null', 'flag is null
        and adj.set_of_books_id = :p_set_of_books_id');
   end if;

      DBMS_SQL.PARSE(l_cursor_id, l_statement, DBMS_SQL.NATIVE);

      DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_asset_id',       p_dest_asset_hdr_rec.asset_id);
      DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_book',           p_dest_asset_hdr_rec.book_type_code);
      DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_period_counter', fa_cache_pkg.fazcbc_record.last_period_counter + 1);
      DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_thid',           p_dest_trans_rec.transaction_header_Id);


   if (p_mrc_sob_type_code = 'R') then
      DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_set_of_books_id', p_dest_asset_hdr_rec.set_of_books_id);
   end if;


      DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 1, l_balancing_seg, 30);
      DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 2, l_sum_amount);

      l_dummy := DBMS_SQL.EXECUTE(l_cursor_id);

      loop

         l_dest_count := l_dest_tbl.count;

         if DBMS_SQL.FETCH_ROWS(l_cursor_id) = 0 then
            exit;
         end if;

         DBMS_SQL.COLUMN_VALUE(l_cursor_id, 1, l_balancing_seg);
         DBMS_SQL.COLUMN_VALUE(l_cursor_id, 2, l_sum_amount);

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'balancing_seg for first dest tbl: ', l_balancing_seg, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'sum_amount for first dest tbl: ', l_sum_amount, p_log_level_rec => p_log_level_rec);
         end if;

         -- add these values to the table
         l_dest_tbl(l_dest_count + 1).balancing_segment := l_balancing_seg;
         l_dest_tbl(l_dest_count + 1).amount            := l_sum_amount;

      end loop;

      DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'dest table count', l_dest_tbl.count, p_log_level_rec => p_log_level_rec);
      end if;


   else
      -- set dest = src for later use in the distribution processing
      l_dest_asset_hdr_rec  := p_src_asset_hdr_rec;
      l_dest_trans_rec      := p_src_trans_rec;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'not processing', 'destination', p_log_level_rec => p_log_level_rec);
      end if;

   end if;



   -- sum all accounts into a single amount per balancing segment
   -- first create a new table indexed by balancing segment

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'summing', 'source amounts', p_log_level_rec => p_log_level_rec);
   end if;

   for l_src_count in 1..l_src_tbl.count loop

      l_found := FALSE;

      for l_src_summary_count in 1 .. l_src_summary_tbl.count loop

         if (l_src_tbl(l_src_count).balancing_segment = l_src_summary_tbl(l_src_summary_count).balancing_segment) then
            l_src_summary_tbl(l_src_summary_count).amount :=
              l_src_summary_tbl(l_src_summary_count).amount +
                l_src_tbl(l_src_count).amount;
            l_found := TRUE;
            exit;
         end if;

      end loop;

      -- if not found, add to the summary table
      if not l_found then
         l_src_summary_count := l_src_summary_tbl.count;
         l_src_summary_tbl(l_src_summary_count + 1).balancing_segment  := l_src_tbl(l_src_count).balancing_segment ;
         l_src_summary_tbl(l_src_summary_count + 1).amount             := l_src_tbl(l_src_count).amount;
      end if;

   end loop;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'source summary table count', l_src_summary_tbl.count, p_log_level_rec => p_log_level_rec);
   end if;



   -- now do the same for the destination

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'summing', 'dest amounts', p_log_level_rec => p_log_level_rec);
   end if;

   for l_dest_count in 1 ..l_dest_tbl.count loop

      l_found := FALSE;

      for l_dest_summary_count in 1 .. l_dest_summary_tbl.count loop

         if (l_dest_tbl(l_dest_count).balancing_segment = l_dest_summary_tbl(l_dest_summary_count).balancing_segment) then
            l_dest_summary_tbl(l_dest_summary_count).amount :=
              l_dest_summary_tbl(l_dest_summary_count).amount +
                l_dest_tbl(l_dest_count).amount;
            l_found := TRUE;
            exit;
         end if;

      end loop;


      -- if not found, add to the summary table
      if not l_found then
         l_dest_summary_count := l_dest_summary_tbl.count;
         l_dest_summary_tbl(l_dest_summary_count + 1).balancing_segment  := l_dest_tbl(l_dest_count).balancing_segment ;
         l_dest_summary_tbl(l_dest_summary_count + 1).amount             := l_dest_tbl(l_dest_count).amount;
      end if;

   end loop;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'dest summary table count', l_dest_summary_tbl.count, p_log_level_rec => p_log_level_rec);
   end if;


   -- remove all the 0 amount rows
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'removing', 'source 0 amounts', p_log_level_rec => p_log_level_rec);
   end if;

   -- BUG# 3537535
   -- changing this loop. since its count is changing, that
   -- cant be the end check condition or it will result in
   -- NO_DATA_FOUND.  Instead, just continue to loop until
   -- no 0 rows have found in a given execution
   --
   -- same fix has been made to dest and final summary tables

   l_loop := TRUE;

   while (l_loop) loop

      l_loop := FALSE;
      l_count := l_src_summary_tbl.count;

      for l_src_summary_count in 1 .. l_src_summary_tbl.count loop

         if (l_src_summary_count > l_count) then
            exit;
         end if;

         if (l_src_summary_tbl(l_src_summary_count).amount = 0) then

            l_loop := true;
            l_src_summary_tbl.delete(l_src_summary_count);

            -- reset the values so there is no missing member for future use
            l_count := l_src_summary_tbl.count ;

            if (l_count > 0) then

               for i in l_src_summary_count .. l_count loop
                  -- copy the next member into the current one
                  l_src_summary_tbl(i) := l_src_summary_tbl(i+1);
               end loop;

               -- delete the last member in the array which is now a duplicate
               l_src_summary_tbl.delete(l_count + 1);
            end if;

         end if;
      end loop;
   end loop;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'source summary table count', l_src_summary_tbl.count, p_log_level_rec => p_log_level_rec);
   end if;



   -- same for dest

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'removing', 'dest 0 amounts', p_log_level_rec => p_log_level_rec);
   end if;

   l_loop := TRUE;

   while (l_loop) loop

      l_loop := FALSE;
      l_count := l_dest_summary_tbl.count;

      for l_dest_summary_count in 1 .. l_dest_summary_tbl.count loop

         if (l_dest_summary_count > l_count) then
            exit;
         end if;

         if (l_dest_summary_tbl(l_dest_summary_count).amount = 0) then

            l_loop := true;
            l_dest_summary_tbl.delete(l_dest_summary_count );

            -- reset the values so there is no missing member for future use
            l_count := l_dest_summary_tbl.count ;

            if (l_count > 0) then
               for i in l_dest_summary_count .. l_count loop
                   -- copy the next member into the current one
                   l_dest_summary_tbl(i) := l_dest_summary_tbl(i+1);
               end loop;

               -- delete the last member in the array which is now a duplicate
               l_dest_summary_tbl.delete(l_count + 1);
            end if;

         end if;

      end loop;

   end loop;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'after', 'removing 0 cost dest rows', p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'dest summary table count', l_dest_summary_tbl.count, p_log_level_rec => p_log_level_rec);
   end if;



   -- now find the matches
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'finding', 'balancing segment matches', p_log_level_rec => p_log_level_rec);
   end if;

   if (l_src_summary_tbl.count = 0 and
       l_dest_summary_tbl.count = 0) then

      -- no interco effects at all
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'no intercompany impacts found' ,'', p_log_level_rec => p_log_level_rec);
      end if;

      raise done_exception;

   elsif (l_dest_summary_tbl.count = 0) then

      -- one sided
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'found: ', 'source intercompany impacts only', p_log_level_rec => p_log_level_rec);
      end if;

      l_summary_tbl := l_src_summary_tbl;

      -- loop through the rows and flip the src on the negative amounts in order to
      -- process the interco ap an ar effects...  note thisgoes against the premise
      -- of the current interco transfer logic where src always gets the INTERCO AR
      -- regardless of sign, but there's no better way to do it since we need to
      -- know the net effects..   (maybe derive cost for the asset and go off that?)

      for l_summary_count in 1..l_summary_tbl.count loop

         if (sign(l_summary_tbl(l_summary_count).amount) < 0 ) then
            l_summary_tbl(l_summary_count).amount := -l_summary_tbl(l_summary_count).amount;
            l_summary_tbl(l_summary_count).type := 'DEST';
         else
            l_summary_tbl(l_summary_count).type := 'SRC';
         end if;

      end loop;


   elsif (l_src_summary_tbl.count = 0) then   -- THIS SHOULDN'T HAPPEN!!!!!!!!!!

      -- one sided
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'found: ', 'dest intercompany impacts only', p_log_level_rec => p_log_level_rec);
      end if;

      l_summary_tbl := l_dest_summary_tbl;

      -- in this case, do we need to flip the signs???

   else
      -- cross asset intercompany effects
      -- need to determine overall impacts

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'found: ', 'source and destination intercompany impacts', p_log_level_rec => p_log_level_rec);
      end if;

      l_summary_tbl := l_src_summary_tbl;

      -- set type to src for all lines
      for i in 1..l_summary_tbl.count loop
         l_summary_tbl(i).type := 'SRC';
      end loop;


      -- still iffy in interco transfers, we always charce AR to source
      -- regardless if amount is -ve or +ve
      --
      -- believe we can check abs values and post the difference
      -- to the larger value..  thus driving check is currently on the
      -- absolute values rather than on the sign of the difference
      --
      -- but this premise wouldn't work for intra-asset effects (like add/adj)

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'combining: ', 'source and destination impacts', p_log_level_rec => p_log_level_rec);
      end if;


      for l_dest_summary_count in 1..l_dest_summary_tbl.count loop

         l_found := false;

         for l_summary_count in 1..l_summary_tbl.count loop

            if (l_dest_summary_tbl(l_dest_summary_count).balancing_segment = l_summary_tbl(l_summary_count).balancing_segment) then

               -- match found - now add the two and place any different with correct sign to
               -- allocate it to the desired side of the transaction

               -- BUG# 2726345
               -- changing the following to minus instead of add
               -- since we're coming up with same signs and amounts

               l_amount := l_summary_tbl(l_summary_count).amount - l_dest_summary_tbl(l_dest_summary_count).amount;

               if (sign(l_amount) = 0) then

                  l_summary_tbl(l_summary_count).amount := 0;

               elsif (abs(l_dest_summary_tbl(l_dest_summary_count).amount) >
                      abs(l_summary_tbl(l_summary_count).amount )) then
                  l_amount := -l_amount;

                  l_summary_tbl(l_summary_count).amount := l_amount;
                  l_summary_tbl(l_summary_count).type := 'DEST';

               else -- source drives
                  l_summary_tbl(l_summary_count).amount := l_amount;
               end if;

               l_found := true;
               exit;

               -- BUG# 3468256 (last part)
               -- removed the else and put outside loop as we don't want to add a row multiple times
               -- when more than one receiving segment is involved

            end if;

         end loop;

         if (not l_found) then
            -- if we reach here, match not found and we didn't exit the loop, add it to table
            l_count := l_summary_tbl.count + 1;
            l_summary_tbl(l_count).balancing_segment := l_dest_summary_tbl(l_dest_summary_count).balancing_segment;
            l_summary_tbl(l_count).amount            := l_dest_summary_tbl(l_dest_summary_count).amount;
            l_summary_tbl(l_count).type              := l_dest_summary_tbl(l_dest_summary_count).type;
         end if;

      end loop;

      if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'summary table count', l_summary_tbl.count, p_log_level_rec => p_log_level_rec);
      end if;



      -- remove all the 0 amount rows
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'removing: ', '0 amount summary intercompany lines', p_log_level_rec => p_log_level_rec);
      end if;


      l_loop := TRUE;

      while (l_loop) loop

         l_loop := FALSE;
         l_count := l_summary_tbl.count;

         for l_summary_count in 1 .. l_summary_tbl.count loop

            if (l_summary_count > l_count) then
               exit;
            end if;

            if (l_summary_tbl(l_summary_count).amount = 0) then

               l_loop := true;
               l_summary_tbl.delete(l_summary_count);

               -- reset the values so there is no missing member for future use
               l_count := l_summary_tbl.count ;

               if (l_count > 0) then
                  for i in l_summary_count .. l_count loop
                      -- copy the next member into the current one
                      l_summary_tbl(i) := l_summary_tbl(i+1);
                  end loop;

                  -- delete the last member in the array which is now a duplicate
                  l_summary_tbl.delete(l_count + 1);
               end if;

            end if;

         end loop;

      end loop;

      if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'summary table count', l_summary_tbl.count, p_log_level_rec => p_log_level_rec);
      end if;

   end if;

   -- load the constant values for each asset
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'setting up for: ', 'faxinaj calls', p_log_level_rec => p_log_level_rec);
   end if;


   l_interco_ar_acct := fa_cache_pkg.fazcbc_record.ar_intercompany_acct;
   l_interco_ap_acct := fa_cache_pkg.fazcbc_record.ap_intercompany_acct;


   -- set the source type code...
   -- currently only transaction that should call this engine
   -- are non-distirbution ones, such that this value should
   -- equate to the contents of trx_type_code...  would need to
   -- expand this, if called for UNIT ADJ, etc at any time

   l_src_source_type_code := p_src_trans_rec.transaction_type_code;


   if (l_src_source_type_code = 'GROUP ADJUSTMENT' or
       l_src_source_type_code = 'GROUP ADDITION') then
      l_src_source_type_code := 'ADJUSTMENT';
   end if;

   if (p_dest_trans_rec.transaction_header_id is not null) then
      l_dest_source_type_code := p_dest_trans_rec.transaction_type_code;

      if (l_dest_source_type_code = 'GROUP ADJUSTMENT' or
          l_dest_source_type_code = 'GROUP ADDITION') then
         l_dest_source_type_code := 'ADJUSTMENT';
      end if;

   else
      l_dest_source_type_code := l_src_source_type_code;
   end if;

   -- BUG# 3543423
   -- any impact from group reclass will insure we insert the
   --  source type as ADJUSTMENT to avoid out-of-balance batches
   if g_group_reclass then
      l_src_source_type_code  := 'ADJUSTMENT';
      l_dest_source_type_code := 'ADJUSTMENT';
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'src source_type_code', l_src_source_type_code, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'dest source_type_code', l_dest_source_type_code, p_log_level_rec => p_log_level_rec);
   end if;

   l_adj.period_counter_created   := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
   l_adj.period_counter_adjusted  := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
   l_adj.last_update_date         := p_src_trans_rec.transaction_date_entered;
   l_adj.selection_mode           := FA_ADJUST_TYPE_PKG.FA_AJ_SINGLE;
   l_adj.selection_thid           := 0;
   l_adj.selection_retid          := 0;
   l_adj.leveling_flag            := TRUE;
   l_adj.flush_adj_flag           := TRUE;
   l_adj.gen_ccid_flag            := TRUE;
   l_adj.annualized_adjustment    := 0;
   l_adj.asset_invoice_id         := 0;
   l_adj.deprn_override_flag      := '';
   l_adj.mrc_sob_type_code        := p_mrc_sob_type_code;
   l_adj.set_of_books_id          := p_src_asset_hdr_rec.set_of_books_id;


   -- ???
   l_adj.current_units            := 1;


   -- loop through the distributions on each side and post the difference
   -- note that in this proposal, there is no distinction between source
   -- and destination.  If the src and destination share even a portion
   -- between the same segment, the interco values will cascade to all of them

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'looping: ', 'through summary interco records', p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'summary_tbl.count: ', l_summary_tbl.count , p_log_level_rec => p_log_level_rec);
   end if;

   for l_summary_count in 1..l_summary_tbl.count loop

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'looping through summary records, count: ', l_summary_count, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'summary amount', l_summary_tbl(l_summary_count).amount);
      end if;

      l_dist_tbl.delete;
      l_dist_tbl_count  := 0;
      l_prorated_amount := 0;
      l_total_prorated_amount := 0;


      -- get each balancing segment and the sum of the amounts
      l_cursor_id := DBMS_SQL.OPEN_CURSOR;

      l_statement :=
         ' select distinct
                  dh.distribution_id,
                  dh.code_combination_id,
                  dh.units_assigned
             from fa_adjustments adj,
                  fa_distribution_history dh,
                  gl_code_combinations glcc
            where adj.asset_id                  = :p_asset_id
              and adj.book_type_code            = :p_book_type_code
              and adj.period_counter_created    = :p_period_counter_created
              and adj.transaction_header_id     = :p_thid
              and adj.distribution_id           = dh.distribution_id
              and dh.asset_id                   = :p_asset_id
              and dh.code_combination_id        = glcc.code_combination_id
              and glcc. ' || l_column_name || ' = :p_balancing_segment ';

      if (p_mrc_sob_type_code = 'R') then

         l_statement := replace(l_statement, 'fa_adjustments', 'fa_mc_adjustments');
         l_statement := replace(l_statement, 'flag is null', 'flag is null
              and adj.set_of_books_id = :p_set_of_books_id');
      end if;

      DBMS_SQL.PARSE(l_cursor_id, l_statement, DBMS_SQL.NATIVE);

      -- need to use local for dest variable for intra-asset trxs
      if (l_summary_tbl(l_summary_count).type = 'SRC') then
         DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_asset_id',               p_src_asset_hdr_rec.asset_id);
         DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_book_type_code',         p_src_asset_hdr_rec.book_type_code);
         DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_period_counter_created', fa_cache_pkg.fazcbc_record.last_period_counter + 1);
         DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_thid',                   p_src_trans_rec.transaction_header_id);
      else
         DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_asset_id',               l_dest_asset_hdr_rec.asset_id);
         DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_book_type_code',         l_dest_asset_hdr_rec.book_type_code);
         DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_period_counter_created', fa_cache_pkg.fazcbc_record.last_period_counter + 1);
         DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_thid',                   l_dest_trans_rec.transaction_header_id);
      end if;

      DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_balancing_segment', l_summary_tbl(l_summary_count).balancing_segment);

      DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 1, l_distribution_id);
      DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 2, l_code_combination_id);
      DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 3, l_units);

      l_dummy := DBMS_SQL.EXECUTE(l_cursor_id);

      loop

         if DBMS_SQL.FETCH_ROWS(l_cursor_id) = 0 then


            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'dist cursor: ', 'no more rows fetched', p_log_level_rec => p_log_level_rec);
            end if;

            -- get total units
            l_total_units := 0;
            for l_dist_count in 1..l_dist_tbl.count loop
               l_total_units := l_total_units + l_dist_tbl(l_dist_count).units;
            end loop;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'dist cursor: ', 'looping through dists', p_log_level_rec => p_log_level_rec);
            end if;

            for l_dist_count in 1..l_dist_tbl.count loop
               -- process the rows into fa_adj for that balancing segment
               -- call faxinaj to insert the amounts (flush them too)

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'inside ', 'dist loop', p_log_level_rec => p_log_level_rec);
               end if;

               l_adj.code_combination_id      := l_dist_tbl(l_dist_count).code_combination_id;
               l_adj.distribution_id          := l_dist_tbl(l_dist_count).distribution_id;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'l_summary_tbl(l_summary_count).amount', l_summary_tbl(l_summary_count).amount);
                  fa_debug_pkg.add(l_calling_fn, 'l_total_prorated_amount',l_total_prorated_amount, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'l_total_units', l_total_units, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'l_dist_tbl(l_dist_count).units', l_dist_tbl(l_dist_count).units);
               end if;

               if (l_dist_count = l_dist_tbl.count) then

                  l_adj.adjustment_amount        := l_summary_tbl(l_summary_count).amount - l_total_prorated_amount;
               else
                  l_prorated_amount              := l_summary_tbl(l_summary_count).amount * (l_dist_tbl(l_dist_count).units / l_total_units);

                  if not fa_utils_pkg.faxrnd
                          (x_amount => l_prorated_amount,
                           x_book   => p_src_asset_hdr_rec.book_type_code,
                           X_set_of_books_id => p_src_asset_hdr_rec.set_of_books_id
                           , p_log_level_rec => p_log_level_rec) then raise interco_err;
                  end if;

                  l_total_prorated_amount := l_total_prorated_amount + l_prorated_amount;
                  l_adj.adjustment_amount := l_prorated_amount;

               end if;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'l_adj.adj_amount', l_adj.adjustment_amount, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'setting up ', 'local variables', p_log_level_rec => p_log_level_rec);
               end if;

               if (l_summary_tbl(l_summary_count).type = 'SRC') then
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'processing', 'src', p_log_level_rec => p_log_level_rec);
                  end if;

                  l_adj.transaction_header_id    := p_src_trans_rec.transaction_header_id;
                  l_adj.asset_id                 := p_src_asset_hdr_rec.asset_id;
                  l_adj.book_type_code           := p_src_asset_hdr_rec.book_type_code;
                  l_adj.debit_credit_flag        := 'DR';
                  l_adj.adjustment_type          := 'INTERCO AR';
                  l_adj.account_type             := 'AR_INTERCOMPANY_ACCT';
                  l_adj.account                  := l_interco_ar_acct;
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'source_type_code', l_src_source_type_code, p_log_level_rec => p_log_level_rec);
                  end if;

                  l_adj.source_type_code         := l_src_source_type_code;

               else
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'processing', 'dest', p_log_level_rec => p_log_level_rec);
                  end if;

                  -- need to use locals for intra-assets
		  -- Bug7496364:modified account type correctly to AP
                  l_adj.transaction_header_id    := l_dest_trans_rec.transaction_header_id;
                  l_adj.asset_id                 := l_dest_asset_hdr_rec.asset_id;
                  l_adj.book_type_code           := l_dest_asset_hdr_rec.book_type_code;

                  l_adj.debit_credit_flag        := 'CR';
                  l_adj.adjustment_type          := 'INTERCO AP';
                  l_adj.account_type             := 'AP_INTERCOMPANY_ACCT';
                  l_adj.account                  := l_interco_ap_acct;
                  l_adj.source_type_code         := l_dest_source_type_code;
               end if;

               if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, 'calling: ', 'faxinaj', p_log_level_rec => p_log_level_rec);
               end if;

               if not FA_INS_ADJUST_PKG.faxinaj
                       (l_adj,
                        p_src_trans_rec.who_info.last_update_date,
                        p_src_trans_rec.who_info.last_updated_by,
                        p_src_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
                  raise interco_err;
               end if;

            end loop;

            exit;  -- exit distribution loop and continue to next balancing segment

         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'populating: ', 'values from dist cursor', p_log_level_rec => p_log_level_rec);
         end if;

         DBMS_SQL.COLUMN_VALUE(l_cursor_id, 1, l_distribution_id);
         DBMS_SQL.COLUMN_VALUE(l_cursor_id, 2, l_code_combination_id);
         DBMS_SQL.COLUMN_VALUE(l_cursor_id, 3, l_units);


         -- add these values to the table
         l_dist_tbl_count                                 := l_dist_tbl.count + 1;
         l_dist_tbl(l_dist_tbl_count).distribution_id     := l_distribution_id;
         l_dist_tbl(l_dist_tbl_count).code_combination_id := l_code_combination_id;
         l_dist_tbl(l_dist_tbl_count).units               := l_units;

      end loop;

      DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

   end loop;

   raise done_exception;

EXCEPTION
   WHEN done_exception THEN
        return true;

   WHEN interco_err THEN
        fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;


END do_intercompany;

--------------------------------------------------------------------------------

function validate_grp_interco
            (p_asset_hdr_rec    in fa_api_types.asset_hdr_rec_type,
             p_trans_rec        in fa_api_types.trans_rec_type,
             p_asset_type_rec   in fa_api_types.asset_type_rec_type,
             p_group_asset_id   in number,
             p_asset_dist_tbl   in FA_API_TYPES.asset_dist_tbl_type,
             p_calling_fn       in varchar2
            , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN is

   CURSOR c_asset_distributions IS
   select code_combination_id
     from fa_distribution_history
    where asset_id         = p_asset_hdr_rec.asset_id
      and date_ineffective is null;

   l_asset_dist_tbl        FA_API_TYPES.asset_dist_tbl_type;

   TYPE l_bal_tbl_type     is table of varchar2(30) index by binary_integer;
   l_bal_tbl1              l_bal_tbl_type;
   l_bal_tbl2              l_bal_tbl_type;
   l_bal_count1            number;
   l_bal_count2            number;
   l_dist_tbl_count        number;

   l_cursor_id             number;
   l_statement             varchar2(4000);
   l_dummy                 number;
   l_found                 boolean;

   l_account_flex          number;
   l_balancing_seg         varchar2(250);
   l_bal_segnum            number;
   l_column_name           varchar2(30);
   l_seg_name              VARCHAR2(30);
   l_prompt                VARCHAR2(80);
   l_value_set_name        VARCHAR2(60);
   l_ccid_string           varchar2(4000) := '';
   l_status                boolean;

   l_ccid                  number;
   l_asset_id              number;

   l_calling_fn            varchar2(35) := 'fa_interco_pvt.validate_grp_interco';
   interco_err             exception;

begin

   if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'inside', 'validate interco code', p_log_level_rec => p_log_level_rec);
   end if;

   l_account_flex := fa_cache_pkg.fazcbc_record.ACCOUNTING_FLEX_STRUCTURE;

/*
   l_status := fnd_flex_apis.get_qualifier_segnum(appl_id          => 101,
                                                  key_flex_code    => 'GL#',
                                                  structure_number => l_account_flex,
                                                  flex_qual_name   => 'GL_BALANCING',
                                                  segment_number   => l_bal_segnum);
*/
/* Bug 5246620. Wrong segment_number retrieved */
    SELECT s.segment_num INTO l_bal_segnum
      FROM fnd_id_flex_segments s, fnd_segment_attribute_values sav,
           fnd_segment_attribute_types sat
     WHERE s.application_id = 101
       AND s.id_flex_code = 'GL#'
       AND s.id_flex_num = l_account_flex
       AND s.enabled_flag = 'Y'
       AND s.application_column_name = sav.application_column_name
       AND sav.application_id = 101
       AND sav.id_flex_code = 'GL#'
       AND sav.id_flex_num = l_account_flex
       AND sav.attribute_value = 'Y'
       AND sav.segment_attribute_type = sat.segment_attribute_type
       AND sat.application_id = 101
       AND sat.id_flex_code = 'GL#'
       AND sat.unique_flag = 'Y'
       AND sat.segment_attribute_type = 'GL_BALANCING';


--   if not l_status then
--      raise interco_err;
--   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'GL Balancing Segment Number', l_bal_segnum, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'transaction type code', p_trans_rec.transaction_type_code, p_log_level_rec => p_log_level_rec);
   end if;


   l_status := fnd_flex_apis.get_segment_info(
                          x_application_id => 101,
                          x_id_flex_code   => 'GL#',
                          x_id_flex_num    => l_account_flex,
                          x_seg_num        => l_bal_segnum,
                          x_appcol_name    => l_column_name,
                          x_seg_name       => l_seg_name,
                          x_prompt         => l_prompt,
                          x_value_set_name => l_value_set_name );

   if not l_status then
      raise interco_err;
   end if;

   -- for group reclasses, the incoming dist table is null
   -- so we need to load the member asset's distribution info here...
   if (p_asset_dist_tbl.count = 0) then


       if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'loading', 'dist table', p_log_level_rec => p_log_level_rec);
       end if;

       open c_asset_distributions;

       loop

          fetch c_asset_distributions
           into l_ccid;

          if c_asset_distributions%NOTFOUND then
             exit;
          end if;

          l_asset_dist_tbl(l_asset_dist_tbl.count + 1).expense_ccid := l_ccid;

       end loop;

       close c_asset_distributions;

   else
       if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'using', 'provided dist table', p_log_level_rec => p_log_level_rec);
       end if;

       l_asset_dist_tbl := p_asset_dist_tbl;
   end if;



   -- load the balancing segments for the driving asset
   -- using the distirbution table parameter and flex api
   for l_dist_tbl_count in 1..l_asset_dist_tbl.count loop

       if l_asset_dist_tbl(l_dist_tbl_count).expense_ccid is null then
          select code_combination_id
            into l_ccid
            from fa_distribution_history
           where distribution_id = l_asset_dist_tbl(l_dist_tbl_count).distribution_id;
       else
          l_ccid := l_asset_dist_tbl(l_dist_tbl_count).expense_ccid;
       end if;

       if (l_dist_tbl_count = 1) then
          l_ccid_string := l_ccid_string || to_char(l_ccid);
       else
          l_ccid_string := l_ccid_string || ',' || to_char(l_ccid);
       end if;

   end loop;

   l_statement :=
      'select distinct glcc.' || l_column_name ||
       ' from gl_code_combinations glcc ' ||
       ' where code_combination_id in (' || l_ccid_string || ')';

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'executing', 'first dynamic sql', p_log_level_rec => p_log_level_rec);
   end if;


   -- execute the statment
   l_cursor_id := DBMS_SQL.OPEN_CURSOR;
   DBMS_SQL.PARSE(l_cursor_id, l_statement, DBMS_SQL.NATIVE);

   DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 1, l_balancing_seg, 30);

   l_dummy := DBMS_SQL.EXECUTE(l_cursor_id);

   loop

      l_bal_count1 := l_bal_tbl1.count;

      if DBMS_SQL.FETCH_ROWS(l_cursor_id) = 0 then
         exit;
      end if;

      DBMS_SQL.COLUMN_VALUE(l_cursor_id, 1, l_balancing_seg);

      l_bal_tbl1(l_bal_count1 + 1) := l_balancing_seg;

   end loop;

   DBMS_SQL.CLOSE_CURSOR(l_cursor_id);



   -- now for group, check all member distributions
   -- and for members, check the groups distributions
   --
   -- we have two options...   use dynamic sql which
   -- would result in much smaller tables to compare
   -- or we could use fnd apis on each distinct ccid
   -- resulting in additional operations to get only
   -- the distinct ccids and there would be more values
   -- for which youd have to call the api and then compare

   -- for transfers, we check all associated books
   -- for the flag...   for groups, this is only called
   -- from transfers/unit adjustments, not additions


   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'setting', 'second dynamic sql', p_log_level_rec => p_log_level_rec);
   end if;


   if (p_asset_type_rec.asset_type = 'GROUP') then

      l_statement :=
         'select distinct glcc.' || l_column_name ||
          ' from gl_code_combinations glcc,
                 fa_books bk,
                 fa_book_controls bc,
                 fa_distribution_history dh
           where bk.asset_id                 = dh.asset_id
             and bk.group_asset_id           = :p_asset_id
             and bk.book_type_code           = bc.book_type_code
             and bc.distribution_source_book = :p_book
             and dh.book_type_code           = :p_book
             and bc.allow_interco_group_flag = ''N''
             and bc.date_ineffective         is null
             and bk.date_ineffective         is null
             and dh.date_ineffective         is null
             and dh.code_combination_id      = glcc.code_combination_id' ;

      l_asset_id := p_asset_hdr_rec.asset_id;


   -- member additions or group reclasses into a destination group
   elsif (p_trans_rec.transaction_type_code = 'ADDITION' or
          p_trans_rec.transaction_type_code = 'CIP ADDITION' or
          p_trans_rec.transaction_type_code = 'ADJUSTMENT' or
          p_trans_rec.transaction_type_code = 'CIP ADJUSTMENT') then

      -- only care about the book in question

      l_statement :=
         'select distinct glcc.' || l_column_name ||
          ' from gl_code_combinations glcc,
                 fa_book_controls bc,
                 fa_distribution_history dh
           where dh.asset_id                 = :p_asset_Id
             and dh.date_ineffective         is null
             and dh.code_combination_id      = glcc.code_combination_id
             and bc.distribution_source_book = :p_book
             and bc.book_type_code           = dh.book_type_code
             and bc.allow_interco_group_flag = ''N''';

      l_asset_id := p_group_asset_id;

   else -- member transfer / unit adj

      -- need to look at all groups for all books to which its assigned

      l_statement :=
         'select distinct glcc.' || l_column_name ||
          ' from gl_code_combinations glcc,
                 fa_books bk,
                 fa_distribution_history dh,
                 fa_book_controls bc
           where dh.asset_id                 = bk.group_asset_id
             and dh.date_ineffective        is null
             and dh.code_combination_id      = glcc.code_combination_id
             and bk.asset_id                 = :p_asset_id
             and bk.book_type_code           = bc.book_type_code
             and bc.distribution_source_book = :p_book
             and bc.allow_interco_group_flag = ''N''
             and dh.book_type_code           = :p_book ';

      l_asset_id := p_asset_hdr_rec.asset_id;

   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'executing', 'second dynamic sql', p_log_level_rec => p_log_level_rec);
   end if;


   -- execute the statment
   l_cursor_id := DBMS_SQL.OPEN_CURSOR;
   DBMS_SQL.PARSE(l_cursor_id, l_statement, DBMS_SQL.NATIVE);

   DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_asset_id',  l_asset_id);
   DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_book',      p_asset_hdr_rec.book_type_code);

   DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 1, l_balancing_seg, 30);

   l_dummy := DBMS_SQL.EXECUTE(l_cursor_id);

   loop

      l_bal_count2 := l_bal_tbl2.count;

      if DBMS_SQL.FETCH_ROWS(l_cursor_id) = 0 then
         exit;
      end if;

      DBMS_SQL.COLUMN_VALUE(l_cursor_id, 1, l_balancing_seg);

      l_bal_tbl2(l_bal_count2 + 1) := l_balancing_seg;

   end loop;

   DBMS_SQL.CLOSE_CURSOR(l_cursor_id);


   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'looking', 'for mismatches', p_log_level_rec => p_log_level_rec);
   end if;


   -- look for any mismatches
   for l_bal_tbl1_count in 1..l_bal_tbl1.count loop

       for l_bal_tbl2_count in 1..l_bal_tbl2.count loop

          if (l_bal_tbl1(l_bal_tbl1_count) <> l_bal_tbl2(l_bal_tbl2_count)) then
             raise interco_err;
          end if;

       end loop;

   end loop;

   return true;

exception
   when interco_err then
        fa_srvr_msg.add_message(name => 'FA_NO_GROUP_INTERCO',
                                calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;


end validate_grp_interco;

--------------------------------------------------------------------------------

function validate_inv_interco
            (p_src_asset_hdr_rec    in fa_api_types.asset_hdr_rec_type,
             p_src_trans_rec        in fa_api_types.trans_rec_type,
             p_dest_asset_hdr_rec   in fa_api_types.asset_hdr_rec_type,
             p_dest_trans_rec       in fa_api_types.trans_rec_type,
             p_calling_fn           in varchar2,
             x_interco_impact       out nocopy boolean
            , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN is

   CURSOR c_asset_distributions (p_asset_id number) IS
   select code_combination_id
     from fa_distribution_history
    where asset_id         = p_asset_id
      and date_ineffective is null;

   TYPE l_bal_tbl_type     is table of varchar2(30) index by binary_integer;
   TYPE l_ccid_tbl_type    is table of number index by binary_integer;

   l_ccid_tbl              l_ccid_tbl_type;
   l_bal_tbl1              l_bal_tbl_type;
   l_bal_tbl2              l_bal_tbl_type;
   l_bal_count1            number;
   l_bal_count2            number;
   l_ccid_tbl_count        number;

   l_cursor_id             number;
   l_statement             varchar2(4000);
   l_dummy                 number;
   l_found                 boolean;

   l_account_flex          number;
   l_balancing_seg         varchar2(250);
   l_bal_segnum            number;
   l_column_name           varchar2(30);
   l_seg_name              VARCHAR2(30);
   l_prompt                VARCHAR2(80);
   l_value_set_name        VARCHAR2(60);
   l_ccid_string           varchar2(4000) := '';
   l_status                boolean;

   l_ccid                  number;
   l_asset_id              number;

   l_calling_fn            varchar2(35) := 'fa_interco_pvt.validate_inv_interco';
   interco_err             exception;

begin

   x_interco_impact := FALSE;

   if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, 'inside', 'validate interco code', p_log_level_rec => p_log_level_rec);
   end if;

   l_account_flex := fa_cache_pkg.fazcbc_record.ACCOUNTING_FLEX_STRUCTURE;

/*
   l_status := fnd_flex_apis.get_qualifier_segnum(appl_id          => 101,
                                                  key_flex_code    => 'GL#',
                                                  structure_number => l_account_flex,
                                                  flex_qual_name   => 'GL_BALANCING',
                                                  segment_number   => l_bal_segnum);
*/
/* Bug 5246620. Wrong segment_number retrieved */
    SELECT s.segment_num INTO l_bal_segnum
      FROM fnd_id_flex_segments s, fnd_segment_attribute_values sav,
           fnd_segment_attribute_types sat
     WHERE s.application_id = 101
       AND s.id_flex_code = 'GL#'
       AND s.id_flex_num = l_account_flex
       AND s.enabled_flag = 'Y'
       AND s.application_column_name = sav.application_column_name
       AND sav.application_id = 101
       AND sav.id_flex_code = 'GL#'
       AND sav.id_flex_num = l_account_flex
       AND sav.attribute_value = 'Y'
       AND sav.segment_attribute_type = sat.segment_attribute_type
       AND sat.application_id = 101
       AND sat.id_flex_code = 'GL#'
       AND sat.unique_flag = 'Y'
       AND sat.segment_attribute_type = 'GL_BALANCING';


--   if not l_status then
--      raise interco_err;
--   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'GL Balancing Segment Number', l_bal_segnum, p_log_level_rec => p_log_level_rec);
   end if;


   l_status := fnd_flex_apis.get_segment_info(
                          x_application_id => 101,
                          x_id_flex_code   => 'GL#',
                          x_id_flex_num    => l_account_flex,
                          x_seg_num        => l_bal_segnum,
                          x_appcol_name    => l_column_name,
                          x_seg_name       => l_seg_name,
                          x_prompt         => l_prompt,
                          x_value_set_name => l_value_set_name );

   if not l_status then
      raise interco_err;
   end if;


   -- load the balancing segments for the driving asset (src)
   -- using the distirbution table parameter and flex api
   for i in 1..2 loop

      if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'loading', 'dist table', p_log_level_rec => p_log_level_rec);
      end if;

      if i = 1 then
         l_asset_id := p_src_asset_hdr_rec.asset_id;
      else
         l_asset_id := p_dest_asset_hdr_rec.asset_id;
      end if;

      open c_asset_distributions (p_asset_id => l_asset_id);

      loop

         fetch c_asset_distributions
          into l_ccid;

         if c_asset_distributions%NOTFOUND then
            exit;
         end if;

         l_ccid_tbl(l_ccid_tbl.count + 1) := l_ccid;

      end loop;

      close c_asset_distributions;

      if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'building', 'ccid string', p_log_level_rec => p_log_level_rec);
      end if;

      for l_ccid_tbl_count in 1..l_ccid_tbl.count loop

         l_ccid := l_ccid_tbl(l_ccid_tbl_count);

         if (l_ccid_tbl_count = 1) then
            l_ccid_string := l_ccid_string || to_char(l_ccid);
         else
            l_ccid_string := l_ccid_string || ',' || to_char(l_ccid);
         end if;

      end loop;

      l_statement :=
         'select distinct glcc.' || l_column_name ||
          ' from gl_code_combinations glcc ' ||
         ' where code_combination_id in (' || l_ccid_string || ')';

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'executing', 'first dynamic sql', p_log_level_rec => p_log_level_rec);
      end if;

      -- execute the statment
      l_cursor_id := DBMS_SQL.OPEN_CURSOR;
      DBMS_SQL.PARSE(l_cursor_id, l_statement, DBMS_SQL.NATIVE);

      DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 1, l_balancing_seg, 30);

      l_dummy := DBMS_SQL.EXECUTE(l_cursor_id);

      loop

         l_bal_count1 := l_bal_tbl1.count;

         if DBMS_SQL.FETCH_ROWS(l_cursor_id) = 0 then
            exit;
         end if;

         DBMS_SQL.COLUMN_VALUE(l_cursor_id, 1, l_balancing_seg);

         l_bal_tbl1(l_bal_count1 + 1) := l_balancing_seg;

      end loop;

      DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

      -- copy this table to the second array and delete the original
      if (i = 1) then
         l_bal_tbl2 := l_bal_tbl1;
         l_bal_tbl1.delete;
      end if;

   end loop;  -- this ends the fixed two time loop (src and dest)


   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'looking', 'for mismatches', p_log_level_rec => p_log_level_rec);
   end if;

   -- look for any mismatches
   for l_bal_tbl1_count in 1..l_bal_tbl1.count loop

       for l_bal_tbl2_count in 1..l_bal_tbl2.count loop

          if (l_bal_tbl1(l_bal_tbl1_count) <> l_bal_tbl2(l_bal_tbl2_count)) then
             x_interco_impact := TRUE;
          end if;

       end loop;

   end loop;

   return true;

exception
   when interco_err then
        fa_srvr_msg.add_message(name => 'FA_NO_GROUP_INTERCO',
                                calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;


end validate_inv_interco;


END FA_INTERCO_PVT;

/
