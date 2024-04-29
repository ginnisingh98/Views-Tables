--------------------------------------------------------
--  DDL for Package Body FA_MASS_DPR_RSV_ADJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASS_DPR_RSV_ADJ_PKG" AS
/* $Header: FAMTRSVB.pls 120.5.12010000.3 2009/07/19 09:49:01 glchen ship $ */

 g_log_level_rec         fa_api_types.log_level_rec_type;

 g_phase                 VARCHAR2(100);

 G_success_count         NUMBER := 0;
 G_failure_count         NUMBER := 0;

 g_pers_per_yr           NUMBER;
 g_last_pc               NUMBER;
 g_current_pc            NUMBER;
 g_start_pc              NUMBER;
 g_end_pc                NUMBER;

 g_adj_asset_hdr_rec     FA_API_TYPES.asset_hdr_rec_type;
 g_ctl_asset_hdr_rec     FA_API_TYPES.asset_hdr_rec_type;
 g_corp_asset_hdr_rec    FA_API_TYPES.asset_hdr_rec_type;
 g_asset_tax_rsv_adj_rec FA_API_TYPES.asset_tax_rsv_adj_rec_type;
 g_asset_tax_rsv_ctl_rec FA_API_TYPES.asset_tax_rsv_adj_rec_type;


 g_fin_info              fa_std_types.fin_info_struct;
 g_dpr_row               fa_std_types.fa_deprn_row_struct;

 g_dpr_adj_factor        Number;

 g_string                varchar2(250);
 mass_dpr_rsv_adj_err    exception;


-- ------------------------------------------------------------
-- Private Functions and Procedures
-- ------------------------------------------------------------

------------------------------------------------------------------------
-- PROCEDURE PROCESS_ASSETS
--
-- NOTE:
--
------------------------------------------------------------------------

/* Bug 4597471 -- Added one more parameter "p_mode" which shows whether called from
   PREVIEW or RUN . Both have the same calculations but RUN mode updates the core tables
   whereas PREVIEW only updates the interface table
*/

PROCEDURE PROCESS_ASSETS(p_mass_tax_adjustment_id  IN NUMBER,
                         p_parent_request_id       IN NUMBER,
                         p_mode 		   IN VARCHAR2,
                         p_start_range             IN NUMBER,
                         p_end_range               IN NUMBER) IS

   l_trans_rec            FA_API_TYPES.trans_rec_type;

   l_pers_per_yr          NUMBER;
   l_last_pc              NUMBER;
   l_current_pc           NUMBER;
   l_start_pc             NUMBER;
   l_end_pc               NUMBER;

   l_primary_sob_id       NUMBER;

   l_deprn_rsv_corp_end   NUMBER;

   l_min_deprn_rsv        NUMBER;
   l_max_deprn_rsv        NUMBER;

   l_asset_desc_rec       FA_API_TYPES.asset_desc_rec_type;

   l_adj_cost             NUMBER;
   l_ctl_cost             NUMBER;
   l_corp_cost            NUMBER;
   l_adj_rec_cost         NUMBER;

   mass_dpr_rsv_adj_err   EXCEPTION;
   dpr_row                FA_STD_TYPES.fa_deprn_row_struct;

   l_string               VARCHAR2(500);
   p_init_msg_list        VARCHAR2(10);  --vmarella check

   p_commit               VARCHAR2(10);
   P_VALIDATION_LEVEL     NUMBER;
   x_return_status        VARCHAR2(1);
   x_msg_count            NUMBER := 0;
   x_mesg_len             NUMBER;
   x_msg_data             VARCHAR2(4000);
   l_calling_fn           VARCHAR2(50) := 'fa_mass_dpr_rsv_adj_pkg.process_assets';
   l_trx_date             DATE := sysdate;
   l_asset_id             NUMBER;

   l_dummy_bool           BOOLEAN;
   l_deprn_rsv_ctl_end    NUMBER;
   l_deprn_rsv_adj_end    NUMBER;
   l_ytd_rsv_adj_end      NUMBER;
   l_deprn_rsv_adj_begin  NUMBER;
   asset_ret              EXCEPTION;
   CURSOR C_ASSETS IS
            SELECT DISTINCT AD.ASSET_ID/*,
                            AD.ASSET_NUMBER,
                            AD.ASSET_TYPE,
                            AD.ASSET_CATEGORY_ID,
                            AD.CURRENT_UNITS */ --vmarella <all I want is an asset id>.
                       FROM FA_DEPRN_SUMMARY DS,
                            FA_BOOKS BK,
                            FA_ADDITIONS AD,
                            FA_TRANSACTION_HEADERS TH
                      WHERE DS.BOOK_TYPE_CODE        = g_adj_asset_hdr_rec.book_type_code
                        AND DS.ASSET_ID              = AD.ASSET_ID
                        AND (DS.PERIOD_COUNTER       BETWEEN g_start_pc AND g_end_pc)
                        AND BK.ASSET_ID              = AD.ASSET_ID
                        AND BK.BOOK_TYPE_CODE        = g_adj_asset_hdr_rec.book_type_code
                        AND BK.DATE_INEFFECTIVE      IS NULL
                        AND TH.ASSET_ID (+)          = AD.ASSET_ID
                        AND TH.BOOK_TYPE_CODE (+)    = g_adj_asset_hdr_rec.book_type_code
                        AND TH.MASS_TRANSACTION_ID (+) = p_mass_tax_adjustment_id
                        AND TH.MASS_TRANSACTION_ID     IS NULL
                        AND AD.ASSET_ID              BETWEEN p_start_range AND p_end_range;

    x_transaction_header_id   NUMBER;

 BEGIN

   ------------------------------------------------
   -- Get the Adj and Ctl book details
   ------------------------------------------------

   SELECT ADJUSTED_BOOK_TYPE_CODE,
          CONTROL_BOOK_TYPE_CODE,
          DEPRN_ADJUSTMENT_FACTOR,
          FISCAL_YEAR
   INTO   g_adj_asset_hdr_rec.book_type_code,
          g_ctl_asset_hdr_rec.book_type_code,
          g_dpr_adj_factor,
          g_asset_tax_rsv_adj_rec.fiscal_year
   FROM   FA_MASS_TAX_ADJUSTMENTS
   WHERE  MASS_TAX_ADJUSTMENT_ID = p_mass_tax_adjustment_id;


   /* Get the Adjusted Book from Book Controls Cache */

   if not fa_cache_pkg.fazcbc(X_book => g_adj_asset_hdr_rec.book_type_code) then
      raise mass_dpr_rsv_adj_err;
   end if;

   /* Get the Depreciation Calendar from Book Controls Cache */

   -- Get calendar period information from cache

   if not fa_cache_pkg.fazcct(fa_cache_pkg.fazcbc_record.PRORATE_CALENDAR) then  --vmarella check
          raise mass_dpr_rsv_adj_err;
   end if;

   g_pers_per_yr := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;
   g_last_pc     := fa_cache_pkg.fazcbc_record.last_period_counter;
   g_current_pc  := l_last_pc + 1;
   g_start_pc    := g_asset_tax_rsv_adj_rec.fiscal_year * g_pers_per_yr ;
   g_end_pc      := (g_asset_tax_rsv_adj_rec.fiscal_year * g_pers_per_yr) + g_pers_per_yr;

   if not fa_cache_pkg.fazcbcs(g_adj_asset_hdr_rec.book_type_code,
                               fa_cache_pkg.fazcbc_record.set_of_books_id) then
      raise mass_dpr_rsv_adj_err;
   end if;

   l_primary_sob_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'opening c_assets cursor','');
      fa_debug_pkg.add(l_calling_fn,'g_start_pc',g_start_pc);
      fa_debug_pkg.add(l_calling_fn,'g_end_pc',g_end_pc);
   end if;

   Open c_assets;

   loop

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'in main loop ' , '');
      end if;

      fetch c_assets into l_asset_id;
      Exit when c_assets%NOTFOUND;

      BEGIN  /* Inside Loop */

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'in main block ' , '');
         end if;

         g_adj_asset_hdr_rec.asset_id       := l_asset_id;

         if not FA_UTIL_PVT.get_asset_desc_rec
               (p_asset_hdr_rec         => g_adj_asset_hdr_rec,
                px_asset_desc_rec       => l_asset_desc_rec,
                p_log_level_rec         => g_log_level_rec
               ) then
            raise mass_dpr_rsv_adj_err;
         end if;

         -- List of validations.

        /*
         * Check if the asset is fully retired or
         * had been partially retired during the
         * fiscal year being adjusted.
         */

         if (fa_asset_val_pvt.validate_fully_retired
               (p_asset_id           => g_adj_asset_hdr_rec.asset_id,
                p_book               => g_adj_asset_hdr_rec.book_type_code,
                p_log_level_rec      => g_log_level_rec))
            then
               raise mass_dpr_rsv_adj_err;
         end if;

         -- now check for partial ret in current year
         /*
                Bug 4597471 --
                code modified to include the fully retired assets also
                an exception -- asset_ret will be raised if the asset is either fully retired
                or partially retired   */

         Declare  /*editing code to handle the retired assets skchawla*/

            l_is_retired   number;

         Begin
             SELECT
                DISTINCT 1
             INTO
                 l_is_retired
             FROM
                 FA_TRANSACTION_HEADERS TH
             WHERE
                 TH.ASSET_ID = g_adj_asset_hdr_rec.asset_id AND
                 TH.BOOK_TYPE_CODE = g_adj_asset_hdr_rec.book_type_code  AND
                TH.TRANSACTION_TYPE_CODE = 'FULL RETIREMENT';
         EXCEPTION
             when no_data_found then
               begin
                 select distinct 1
                 into l_is_retired
                 from FA_TRANSACTION_HEADERS TH,
                     FA_DEPRN_PERIODS DP1,
                     FA_DEPRN_PERIODS DP2
                 where TH.asset_id = g_adj_asset_hdr_rec.asset_id
                 and TH.book_type_code = g_adj_asset_hdr_rec.book_type_code
                 and TH.transaction_type_code = 'PARTIAL RETIREMENT'
                 and DP1.period_counter = g_start_pc and
                     DP1.book_type_code = g_adj_asset_hdr_rec.book_type_code and
                     DP1.period_open_date <=  TH.date_effective
                 and DP2.period_counter = g_end_pc and
                     DP2.book_type_code = g_adj_asset_hdr_rec.book_type_code and
                     DP2.period_close_date >= TH.date_effective;
                 if(l_is_retired = 1)then
                   raise asset_ret;
                 end if;
               EXCEPTION
                 when no_data_found then
                     null;
                 when others then
                     raise asset_ret;
               end;
         End;


         /* Don't process UOP assets */
         /* Obtain fa_methods.rate_source_rule from cache */

         -- MVK : Find suitable validation.

         /* Don't process an asset with a Polish deprn basis rule */
          -- MVK : Handled in API as well.  ( Need to check w/ brad )

         g_fin_info := Null;

         /* Get the Corporate Book from Book Controls Cache */

          if not fa_cache_pkg.fazcbc(fa_cache_pkg.fazcbc_record.distribution_source_book) then
             raise mass_dpr_rsv_adj_err;
          end if;

          /* Get Deprn Calendar for Corp Book from Book Controls Cache */

          if not fa_cache_pkg.fazcct(fa_cache_pkg.fazcbc_record.deprn_calendar) then
             raise mass_dpr_rsv_adj_err;
          end if;

          /* Get Number of Periods per Fiscal Year from Calendars Cache */

          l_pers_per_yr  := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;
          l_start_pc     :=  g_asset_tax_rsv_adj_rec.fiscal_year * l_pers_per_yr;
          l_end_pc       := (g_asset_tax_rsv_adj_rec.fiscal_year * l_pers_per_yr ) + l_pers_per_yr;


         /**  Get End of Fiscal Year Depreciation for Corporate Book **/

          dpr_row.asset_id := g_adj_asset_hdr_rec.asset_id;
          dpr_row.book := fa_cache_pkg.fazcbc_record.book_type_code;
          dpr_row.dist_id := 0;
          dpr_row.period_ctr := l_end_pc;
          dpr_row.adjusted_flag := FALSE;
          dpr_row.deprn_exp := 0;
          dpr_row.reval_deprn_exp := 0;
          dpr_row.reval_amo := 0;
          dpr_row.prod := 0;
          dpr_row.ytd_deprn := 0;
          dpr_row.ytd_reval_deprn_exp := 0;
          dpr_row.ytd_prod := 0;
          dpr_row.deprn_rsv := 0;
          dpr_row.reval_rsv := 0;
          dpr_row.ltd_prod := 0;
          dpr_row.cost := 0;
          dpr_row.add_cost_to_clear := 0;
          dpr_row.adj_cost := 0;
          dpr_row.reval_amo_basis := 0;
          dpr_row.bonus_rate := 0;
          dpr_row.deprn_source_code := NULL;
          dpr_row.mrc_sob_type_code := 'P';

          FA_QUERY_BALANCES_PKG.QUERY_BALANCES_INT (
               dpr_row,
               'ADJUSTED',
               FALSE,
               l_dummy_bool,
               l_calling_fn,
               -1,
               g_log_level_rec);

          l_deprn_rsv_corp_end := dpr_row.deprn_rsv;

          /* Get Deprn Calendar for Control Book from Book Controls Cache */

          if not fa_cache_pkg.fazcbc(g_ctl_asset_hdr_rec.book_type_code) then --vmarella checking
             raise mass_dpr_rsv_adj_err;
          end if;

         /* Get Deprn Calendar for Control Book from Book Controls Cache */

         if not fa_cache_pkg.fazcct(fa_cache_pkg.fazcbc_record.deprn_calendar) then
            raise mass_dpr_rsv_adj_err;
         end if;

         /* Get Number of Periods per Fiscal Year from Calendars Cache */
	 /* spooyath -- till now g_asset_tax_rsv_ctl_rec.fiscal_year was used which was not populated
	 so l_end_pc was populated as null

         i am using g_asset_tax_rsv_adj_rec.fiscal_year since fiscal year will be same for both
	 control books and adjusted book */

         l_pers_per_yr  := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;
         l_start_pc     :=  g_asset_tax_rsv_adj_rec.fiscal_year * l_pers_per_yr;
         l_end_pc       := (g_asset_tax_rsv_adj_rec.fiscal_year * l_pers_per_yr ) + l_pers_per_yr;

         /**  Get End of Fiscal Year Depreciation for Control Book **/

         dpr_row.asset_id := g_adj_asset_hdr_rec.asset_id;
         dpr_row.book := fa_cache_pkg.fazcbc_record.book_type_code;
         dpr_row.dist_id := 0;
         dpr_row.period_ctr := l_end_pc;
         dpr_row.adjusted_flag := FALSE;
         dpr_row.deprn_exp := 0;
         dpr_row.reval_deprn_exp := 0;
         dpr_row.reval_amo := 0;
         dpr_row.prod := 0;
         dpr_row.ytd_deprn := 0;
         dpr_row.ytd_reval_deprn_exp := 0;
         dpr_row.ytd_prod := 0;
         dpr_row.deprn_rsv := 0;
         dpr_row.reval_rsv := 0;
         dpr_row.ltd_prod := 0;
         dpr_row.cost := 0;
         dpr_row.add_cost_to_clear := 0;
         dpr_row.adj_cost := 0;
         dpr_row.reval_amo_basis := 0;
         dpr_row.bonus_rate := 0;
         dpr_row.deprn_source_code := NULL;

         FA_QUERY_BALANCES_PKG.QUERY_BALANCES_INT (
               dpr_row,
               'ADJUSTED',
               FALSE,
               l_dummy_bool,
               l_calling_fn,
               -1,
               g_log_level_rec);

         l_deprn_rsv_ctl_end := dpr_row.deprn_rsv;

        /* Reset the cache for the adj. book */
	/* spooyath --- fa_cache_pkg.fazcbc_record.book_type_code was used for the adjusted book
	till now with out initializing the cache resulting in the usage of control book as adjusted book */

        if not fa_cache_pkg.fazcbc(X_book => g_adj_asset_hdr_rec.book_type_code) then
           raise mass_dpr_rsv_adj_err;
        end if;


         /**  Get End of Fiscal Year Depreciation for Adjusted Book **/

         dpr_row.asset_id := g_adj_asset_hdr_rec.asset_id;
         dpr_row.book := fa_cache_pkg.fazcbc_record.book_type_code;
         dpr_row.dist_id := 0;
         dpr_row.period_ctr := g_end_pc;
         dpr_row.adjusted_flag := FALSE;
         dpr_row.deprn_exp := 0;
         dpr_row.reval_deprn_exp := 0;
         dpr_row.reval_amo := 0;
         dpr_row.prod := 0;
         dpr_row.ytd_deprn := 0;
         dpr_row.ytd_reval_deprn_exp := 0;
         dpr_row.ytd_prod := 0;
         dpr_row.deprn_rsv := 0;
         dpr_row.reval_rsv := 0;
         dpr_row.ltd_prod := 0;
         dpr_row.cost := 0;
         dpr_row.add_cost_to_clear := 0;
         dpr_row.adj_cost := 0;
         dpr_row.reval_amo_basis := 0;
         dpr_row.bonus_rate := 0;
         dpr_row.deprn_source_code := NULL;

         FA_QUERY_BALANCES_PKG.QUERY_BALANCES_INT (
               dpr_row,
               'ADJUSTED',
               FALSE,
               l_dummy_bool,
               l_calling_fn,
               -1,
               g_log_level_rec);

         l_deprn_rsv_adj_end := dpr_row.deprn_rsv;
         l_ytd_rsv_adj_end   := dpr_row.ytd_deprn;


       /**  Get Start of Fiscal Year Depreciation for Adjusted Book **/

        dpr_row.asset_id := g_adj_asset_hdr_rec.asset_id;
        dpr_row.book := fa_cache_pkg.fazcbc_record.book_type_code;
        dpr_row.dist_id := 0;
        dpr_row.period_ctr := g_start_pc;
        dpr_row.adjusted_flag := FALSE;
        dpr_row.deprn_exp := 0;
        dpr_row.reval_deprn_exp := 0;
        dpr_row.reval_amo := 0;
        dpr_row.prod := 0;
        dpr_row.ytd_deprn := 0;
        dpr_row.ytd_reval_deprn_exp := 0;
        dpr_row.ytd_prod := 0;
        dpr_row.deprn_rsv := 0;
        dpr_row.reval_rsv := 0;
        dpr_row.ltd_prod := 0;
        dpr_row.cost := 0;
        dpr_row.add_cost_to_clear := 0;
        dpr_row.adj_cost := 0;
        dpr_row.reval_amo_basis := 0;
        dpr_row.bonus_rate := 0;
        dpr_row.deprn_source_code := NULL;

        FA_QUERY_BALANCES_PKG.QUERY_BALANCES_INT (
               dpr_row,
               'ADJUSTED',
               FALSE,
               l_dummy_bool,
               l_calling_fn,
               -1,
               g_log_level_rec);

        l_deprn_rsv_adj_begin := dpr_row.deprn_rsv;

        /* Find cost for all three books, don't process asset if not same */

        select bk1.cost, bk2.cost, bk3.cost, nvl(bk1.adjusted_recoverable_cost, bk1.recoverable_cost)
          into l_adj_cost, l_ctl_cost, l_corp_cost, l_adj_rec_cost
          from fa_books bk1,fa_books bk2, fa_books bk3
         where bk1.book_type_code = g_adj_asset_hdr_rec.book_type_code and
               bk1.asset_id = g_adj_asset_hdr_rec.asset_id and
               bk1.date_ineffective is null
           and bk2.book_type_code = g_ctl_asset_hdr_rec.book_type_code and
               bk2.date_ineffective is null and
               bk2.asset_id = bk1.asset_id
           and bk3.book_type_code = fa_cache_pkg.fazcbc_record.distribution_source_book and
               bk3.date_ineffective is null and
               bk3.asset_id = bk1.asset_id;

        If ((l_adj_cost <> l_ctl_cost ) OR
            (l_corp_cost <> l_adj_cost )) then --vmarella

            /* Bug 4597471 --  added the following messages */

	    fa_srvr_msg.add_message (
	       calling_fn => l_calling_fn,
	       name => 'FA_TAX_ASSET_WARN',
	       token1 => 'VARIABLE',
	       value1 => 'ASSET',
	       token2 => 'VALUE',
	       value2 => l_asset_desc_rec.asset_number,
	       translate => FALSE,
               p_log_level_rec => g_log_level_rec
	      );

	    fa_srvr_msg.add_message (
	       calling_fn => l_calling_fn,
	       name => 'FA_TAX_DIFF_COST',
	       translate => FALSE,
               p_log_level_rec => g_log_level_rec
	       );

/*
            fnd_message.set_name('OFA', 'FA_TAX_ASSET_WARN' ||l_asset_desc_rec.asset_number );
            l_string := fnd_message.get;

            fnd_message.set_name('OFA', 'FA_TAX_DIFF_COST' ||l_asset_desc_rec.asset_number );
            l_string := fnd_message.get;
*/
            raise mass_dpr_rsv_adj_err;

        end if;

       /** Find out minimum depreciation reserve **/

         if nvl(l_adj_cost,0) > 0 then   -- { cost > 0 }

            if (l_deprn_rsv_adj_begin > l_deprn_rsv_corp_end )then --vmarella
               if (l_deprn_rsv_adj_begin > l_deprn_rsv_ctl_end )then
                   l_min_deprn_rsv := l_deprn_rsv_adj_begin;
               else
                   l_min_deprn_rsv := l_deprn_rsv_ctl_end;
            end if;
            else
               if (l_deprn_rsv_corp_end > l_deprn_rsv_ctl_end ) then --vmarella
                   l_min_deprn_rsv := l_deprn_rsv_corp_end;
               else
                   l_min_deprn_rsv := l_deprn_rsv_ctl_end;
               end if;
            end if;


         else   -- { cost < 0 }

            if (l_deprn_rsv_adj_begin < l_deprn_rsv_corp_end ) then
               if (l_deprn_rsv_adj_begin < l_deprn_rsv_ctl_end )then--vmarella
                   l_min_deprn_rsv := l_deprn_rsv_adj_begin;
               else
                   l_min_deprn_rsv := l_deprn_rsv_ctl_end;
               end if;
            else
               if (l_deprn_rsv_corp_end < l_deprn_rsv_ctl_end )then --vmarella
                   l_min_deprn_rsv := l_deprn_rsv_corp_end;
               else
                   l_min_deprn_rsv := l_deprn_rsv_ctl_end;
               end if;
            end if;
         end if;


       /** Find out maximium depreciation reserve **/

       /* spooyath -- modified the statements because the logic was wrong */

         if nvl(l_adj_cost,0) > 0 then   -- { cost > 0 }

            if (l_deprn_rsv_adj_end > l_deprn_rsv_corp_end ) then--vmarella
               if (l_deprn_rsv_adj_end > l_deprn_rsv_ctl_end )then
                   l_max_deprn_rsv := l_deprn_rsv_adj_end;
               else
                   l_max_deprn_rsv := l_deprn_rsv_ctl_end;
               end if;
            else
               if (l_deprn_rsv_corp_end > l_deprn_rsv_ctl_end ) then
                   l_max_deprn_rsv := l_deprn_rsv_corp_end;
               else
                   l_max_deprn_rsv := l_deprn_rsv_ctl_end;
               end if;
            end if;


         else   -- { cost < 0 }

            if (l_deprn_rsv_adj_end < l_deprn_rsv_corp_end ) then--vmarella
               if (l_deprn_rsv_adj_end < l_deprn_rsv_ctl_end )then
                   l_max_deprn_rsv := l_deprn_rsv_adj_end;
               else
                   l_max_deprn_rsv := l_deprn_rsv_ctl_end;
               end if;
            else
               if (l_deprn_rsv_corp_end < l_deprn_rsv_ctl_end ) then
                   l_max_deprn_rsv := l_deprn_rsv_corp_end;
               else
                   l_max_deprn_rsv := l_deprn_rsv_ctl_end;
              end if;
            end if;
         end if;

       /* Make sure min_deprn_rsv <= max_deprn_rsv */

         if (nvl(l_adj_cost,0) > 0 and (l_min_deprn_rsv > l_max_deprn_rsv)) OR
            (nvl(l_adj_cost,0) < 0 and (l_min_deprn_rsv < l_max_deprn_rsv)) then

                  fa_srvr_msg.add_message (
                       calling_fn => l_calling_fn,
                       name => 'FA_TAX_ASSET_WARN',
                       token1 => 'VARIABLE',
                       value1 => 'ASSET',
                       token2 => 'VALUE',
                       value2 => l_asset_desc_rec.asset_number,
                       translate => FALSE,
                       p_log_level_rec => g_log_level_rec
                       );

                  fa_srvr_msg.add_message (
                       calling_fn => l_calling_fn,
                       name => 'FA_TAX_MAX_LESS_MIN',
                       translate => FALSE,
                       p_log_level_rec => g_log_level_rec
                       );
                  raise mass_dpr_rsv_adj_err; -- vmarella check

         end if;

       /* Compute Adjusted Depreciation Reserve
          Bug 4597471 --  added nvl for each value used for calculating the Deprn Reserve */

       /* spooyath -- The formula used was wrong corrected the formula */
        /* g_asset_tax_rsv_adj_rec.adjusted_ytd_deprn := (nvl(l_min_deprn_rsv,0) +(nvl(g_dpr_adj_factor,0) * (nvl(l_max_deprn_rsv,0) - nvl(l_min_deprn_rsv,0)))) -
                                                        nvl(l_deprn_rsv_adj_begin,0);*/

         g_asset_tax_rsv_adj_rec.adjusted_ytd_deprn := nvl(l_min_deprn_rsv,0) +
	                                               ( nvl(g_dpr_adj_factor,0) *
						         (nvl(l_max_deprn_rsv,0) - nvl(l_min_deprn_rsv,0)));


         --Bug7630553: fa_tax_rsv_adj_pub.do_tax_rsv_adj is expecting delta reserve between current one and user specified reserve
         g_asset_tax_rsv_adj_rec.adjusted_ytd_deprn :=  (g_asset_tax_rsv_adj_rec.adjusted_ytd_deprn -  l_deprn_rsv_adj_end);

         if (g_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn,'g_asset_tax_rsv_adj_rec.adjusted_ytd_deprn',
                                      g_asset_tax_rsv_adj_rec.adjusted_ytd_deprn, g_log_level_rec);
         end if;


         /*  Bug 4597471 -- Populate the run mode for passing it to the public api */

         g_asset_tax_rsv_adj_rec.run_mode := p_mode ;

        /* Call the public api, which process for each Primary and corresponding Reporting SOB's. */

          -- ***** Transaction Header Info ***** --
          l_trans_rec.mass_reference_id   := p_parent_request_id;
          l_trans_rec.mass_transaction_id := p_mass_tax_adjustment_id;
          l_trans_rec.calling_interface   := 'FATMTA';

          p_init_msg_list := FND_API.G_TRUE;
          fa_tax_rsv_adj_pub.do_tax_rsv_adj
             (p_api_version           => 1.0,
              p_init_msg_list         => FND_API.G_TRUE,
              p_commit                => FND_API.G_FALSE,
              p_validation_level      => p_validation_level,
              p_calling_fn            => l_calling_fn,
              x_return_status         => x_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data,
              px_trans_rec            => l_trans_rec,
              px_asset_hdr_rec        => g_adj_asset_hdr_rec,
              p_asset_tax_rsv_adj_rec => g_asset_tax_rsv_adj_rec
             );

          if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
             raise mass_dpr_rsv_adj_err;
          else
             -- commit each succes
             fnd_concurrent.af_commit;
             G_success_count := G_success_count + 1;
          end if;

      EXCEPTION

             /* Bug 4597471 -- messages for partially / fully reserved assets */
             when asset_ret then
                  fa_srvr_msg.add_message(
                  calling_fn => l_calling_fn,
                  name       => 'FA_TAX_ASSET_WARN',
                  token1     => 'ASSET_NUMBER',
                  value1     => l_asset_desc_rec.asset_number,
                  p_log_level_rec => g_log_level_rec);

                  fa_srvr_msg.add_message(
                  calling_fn => l_calling_fn,
                  name       => 'FA_TAX_FULLY_RET');
                  if (g_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn,'asset_ret ','',g_log_level_rec);

-- Commented for bugfix 4672237
--                     FA_DEBUG_PKG.dump_debug_messages(max_mesgs => 0);

		  end if;
             when mass_dpr_rsv_adj_err then
                  FND_CONCURRENT.AF_ROLLBACK;
                  fa_srvr_msg.add_message(calling_fn => l_calling_fn);
                  if (g_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn,'mass_dpr_rsv_adj_err','',g_log_level_rec);

-- Commented for bugfix 4672237
--                     FA_DEBUG_PKG.dump_debug_messages(max_mesgs => 0);

		  end if;
                  G_failure_count := G_failure_count + 1;


             when others then
                  FA_SRVR_MSG.ADD_SQL_ERROR(
                     CALLING_FN      => l_calling_fn,
                     p_log_level_rec => g_log_level_rec);
                  fnd_concurrent.af_rollback;
                  if (g_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn,'when others','end of main block in loop',g_log_level_rec);

-- Commented for bugfix 4672237
--                     fa_debug_pkg.dump_debug_messages(max_mesgs => 0);
                  end if;
                  G_failure_count := G_failure_count + 1;

      END;  /* Inside Loop */

   end loop; -- c_assets;

EXCEPTION
   when others then
        FA_SRVR_MSG.ADD_SQL_ERROR(
           CALLING_FN      => l_calling_fn,
           p_log_level_rec => g_log_level_rec);
        fnd_concurrent.af_rollback;
        if (g_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn,'when others','end of process_assets', g_log_level_rec);

-- Commented for bugfix 4672237
--           fa_debug_pkg.dump_debug_messages(max_mesgs => 0);

	end if;

END PROCESS_ASSETS;

-- ------------------------------------------------------------
-- Public Functions and Procedures
-- ------------------------------------------------------------

/* Bug 4597471 -- Added one more parameter "p_mode" which shows whether called from
   PREVIEW or RUN . Both have the same calculations but RUN mode updates the core tables
   whereas PREVIEW only updates the interface table
*/

PROCEDURE Do_Deprn_Adjustment
               (p_mass_tax_adjustment_id  IN      NUMBER,
		p_mode                    IN      VARCHAR2,
                p_parent_request_id       IN      NUMBER,
                p_total_requests          IN      NUMBER,
                p_request_number          IN      NUMBER,
                x_success_count           OUT NOCOPY NUMBER,
                x_failure_count           OUT NOCOPY NUMBER,
                x_worker_jobs             OUT NOCOPY NUMBER,
                x_return_status           OUT NOCOPY NUMBER
) IS


   return_status        BOOLEAN := TRUE;
   p_number_of_rows     NUMBER  := 0;
   p_no_worker          NUMBER  := 1;

   l_retcode            VARCHAR2(3);
   l_errbuf             VARCHAR2(500);
   l_stmt               VARCHAR2(300);
   l_dir                VARCHAR2(100);

   -- Used for bulk fetching
   l_counter                      number;
   l_calling_fn                  varchar2(60):='fa_mass_dpr_rsv_adj_pkg.Do_Deprn_Adjustment';
   -- used fort paralization - new method
   l_unassigned_cnt       NUMBER := 0;
   l_failed_cnt           NUMBER := 0;
   l_wip_cnt              NUMBER := 0;
   l_completed_cnt        NUMBER := 0;
   l_total_cnt            NUMBER := 0;
   l_count                NUMBER := 0;
   l_start_range          NUMBER := 0;
   l_end_range            NUMBER := 0;

   l_ret_val            BOOLEAN;
   l_ret_code           VARCHAR2(30);

   done_exc               exception;
   error_found            exception;

BEGIN

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise error_found;
      end if;
   end if;

   G_success_count := 0;
   G_failure_count := 0;

   ------------------------------------------------
   -- Get the Adj and Ctl book details
   ------------------------------------------------

   SELECT ADJUSTED_BOOK_TYPE_CODE,
          CONTROL_BOOK_TYPE_CODE,
          DEPRN_ADJUSTMENT_FACTOR,
          FISCAL_YEAR
   INTO   g_adj_asset_hdr_rec.book_type_code,
          g_ctl_asset_hdr_rec.book_type_code,
          g_dpr_adj_factor,
          g_asset_tax_rsv_adj_rec.fiscal_year
   FROM   FA_MASS_TAX_ADJUSTMENTS
   WHERE  MASS_TAX_ADJUSTMENT_ID = p_mass_tax_adjustment_id;

   -- ------------------------------------------
   -- Loop thru job list
   -- -----------------------------------------

   g_phase := 'Loop thru job list';

   SELECT NVL(sum(decode(status,'UNASSIGNED', 1, 0)),0),
          NVL(sum(decode(status,'FAILED', 1, 0)),0),
          NVL(sum(decode(status,'IN PROCESS', 1, 0)),0),
          NVL(sum(decode(status,'COMPLETED',1 , 0)),0),
          count(*)
     INTO l_unassigned_cnt,
          l_failed_cnt,
          l_wip_cnt,
          l_completed_cnt,
          l_total_cnt
     FROM FA_WORKER_JOBS
    WHERE request_Id = p_parent_request_id;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'Job status - Unassigned: '||l_unassigned_cnt||
                       ' In Process: '||l_wip_cnt||
                       ' Completed: '||l_completed_cnt||
                       ' Failed: '||l_failed_cnt||
                       ' Total: ', l_total_cnt);
      fa_debug_pkg.add(l_calling_fn,'p_parent_request_id',p_parent_request_id);
   end if;


   IF (l_failed_cnt > 0) THEN
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'','');
         fa_debug_pkg.add(l_calling_fn,'Another worker have errored out.  Stop processing.','');
      end if;
      raise error_found; -- ???  this is dbi behavior - we shoudl probably continue
   ELSIF (l_unassigned_cnt = 0) THEN
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'','');
         fa_debug_pkg.add(l_calling_fn,'No more jobs left.  Terminating.','');
      end if;
      raise done_exc;
   ELSIF (l_completed_cnt = l_total_cnt) THEN
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'','');
         fa_debug_pkg.add(l_calling_fn,'All jobs completed, no more job.  Terminating','');
      end if;
      raise done_exc;
   ELSIF (l_unassigned_cnt > 0) THEN
      UPDATE FA_WORKER_JOBS
         SET status = 'IN PROCESS',
             worker_num = p_request_number
       WHERE status = 'UNASSIGNED'
         AND request_Id = p_parent_request_id
         AND rownum < 2;

      l_count := sql%rowcount;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'Taking job from job queue','');
         fa_debug_pkg.add(l_calling_fn,'count: ' , l_count);
      end if;

      FND_CONCURRENT.AF_COMMIT;
   END IF;

   -- -----------------------------------
   -- There could be rare situations where
   -- between Section 30 and Section 50
   -- the unassigned job gets taken by
   -- another worker.  So, if unassigned
   -- job no longer exist.  Do nothing.
   -- -----------------------------------
   IF (l_count > 0) THEN
      DECLARE
      BEGIN
         g_phase := 'Getting ID range from FA_WORKER_JOBS table';

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,g_phase,'');
         end if;

         SELECT start_range,
                end_range
           INTO l_start_range,
                l_end_range
           FROM FA_WORKER_JOBS
          WHERE worker_num = p_request_number
            AND request_Id = p_parent_request_id
            AND status = 'IN PROCESS';


         --------------------------------------------------
         --  Calc. deprn expense for the adjusted tax book
         --  using the start_range and end_range.
         --------------------------------------------------
         g_phase := 'Calc. adj. deprn expense ';
         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,g_phase,'');
         end if;

         PROCESS_ASSETS(p_mass_tax_adjustment_id,
                        p_parent_request_id,
                        p_mode,
                        l_start_range,
                        l_end_range);

         -----------------------------------------------------
         -- Do other work if necessary to finish the child
         -- process
         -- After completing the work, set the job status
         -- to complete
         -----------------------------------------------------
         g_phase:='Updating job status in FA_WORKER_JOBS table';
         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,g_phase,'');
         end if;

         UPDATE FA_WORKER_JOBS
            SET status     = 'COMPLETED'
          WHERE request_id = p_parent_request_id
            AND worker_num = p_request_number
            AND status     = 'IN PROCESS';

         FND_CONCURRENT.AF_COMMIT;

         --   Handle any exception that occured during
         --   your child process

      EXCEPTION
         WHEN OTHERS THEN

              FA_SRVR_MSG.ADD_SQL_ERROR(
                 CALLING_FN => l_calling_fn,
                 p_log_level_rec => g_log_level_rec);

              UPDATE FA_WORKER_JOBS
                 SET status     = 'FAILED'
               WHERE request_id = p_parent_request_id
                 AND worker_num = p_request_number
                 AND status     = 'IN PROCESS';

              FND_CONCURRENT.AF_COMMIT;
              Raise error_found;

      END;  -- block

   END IF; /* IF (l_count> 0) */

   -- using these as dummys - leave as zero when we've done nothing
   x_success_count := G_success_count;
   x_failure_count := G_failure_count;

-- Commented for bugfix 4672237
--   if (g_log_level_rec.statement_level) then
--       fa_debug_pkg.dump_debug_messages(max_mesgs => 0);
--   end if;

   x_return_status := 0;

EXCEPTION
   WHEN done_exc then
        x_success_count := G_success_count;
        x_failure_count := G_failure_count;

-- Commented for bugfix 4672237
--        if (g_log_level_rec.statement_level) then
--           fa_debug_pkg.dump_debug_messages(max_mesgs => 0);
--        end if;

        x_return_status := 0;

   WHEN error_found then
        x_success_count := G_success_count;
        x_failure_count := G_failure_count;
        fa_srvr_msg.add_message(calling_fn      => l_calling_fn,
                                p_log_level_rec => g_log_level_rec);

-- Commented for bugfix 4672237
--        if (g_log_level_rec.statement_level) then
--           fa_debug_pkg.dump_debug_messages(max_mesgs => 0);
--        end if;
        x_return_status := 2;

   WHEN OTHERS THEN
        x_success_count := G_success_count;
        x_failure_count := G_failure_count;
        FA_SRVR_MSG.ADD_SQL_ERROR(
           CALLING_FN      => l_calling_fn,
           p_log_level_rec => g_log_level_rec);

-- Commented for bugfix 4672237
--        if (g_log_level_rec.statement_level) then
--           fa_debug_pkg.dump_debug_messages(max_mesgs => 0);
--        end if;
        x_return_status := 2;

END Do_Deprn_Adjustment;

-----------------------------------------------------------------
-- PROCEDURE LOAD_WORKERS
-----------------------------------------------------------------
PROCEDURE LOAD_WORKERS
            (p_mass_tax_adjustment_id IN NUMBER,
             p_book_type_code         IN VARCHAR2,
             p_parent_request_id      IN NUMBER,
             p_total_requests         IN NUMBER,
             x_worker_jobs               OUT NOCOPY NUMBER,
             x_return_status             OUT NOCOPY NUMBER) IS

   l_max_number   NUMBER;
   l_start_number NUMBER;
   l_end_number   NUMBER;
   l_count        NUMBER := 0;

   l_batch_size     number;
   l_book_type_code FA_BOOKS.book_type_code%type;
   l_calling_fn     varchar2(60) := 'fa_mass_dpr_rsv_adj_pkg.load_jobs';

   error_found      exception;
BEGIN

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise error_found;
      end if;
   end if;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'Calling procedure: LOAD_JOBS','');
      fa_debug_pkg.add(l_calling_fn,'','');
   end if;

   if not (fa_cache_pkg.fazcbc(x_book => p_book_type_code
                              ,p_log_level_rec => g_log_level_rec)) then
      raise error_found;
   end if;

   l_batch_size := nvl(fa_cache_pkg.fa_batch_size, 1000);

   g_phase := 'Register jobs for workers';
   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'Register jobs for workers','');
      fa_debug_pkg.add(l_calling_fn,'p_parent_request_id',p_parent_request_id);
   end if;

   ------------------------------------------------------------
   --  select min and max sequence IDs from your ID Temp table
   ------------------------------------------------------------
   -- Get the Adj and Ctl book details

   g_phase := 'select min and max asset ids';

/*

   SELECT NVL(max(asset_id), 0),
          nvl(min(asset_id), 1)
   INTO   l_max_number,
          l_start_number
   FROM   FA_books
   WHERE  book_type_code = p_book_type_code
   AND    transaction_header_id_out is null;

   WHILE (l_start_number <= l_max_number) LOOP

      l_end_number:= l_start_number + l_batch_size;
      g_phase := 'Loop to insert into FA_WORKER_JOBS: '
                  || l_start_number || ', ' || l_end_number;

      l_count := l_count + 1;
      INSERT INTO FA_WORKER_JOBS (start_range, end_range, status, request_id)
      VALUES (l_start_number, least(l_end_number, l_max_number),'UNASSIGNED');


      l_start_number := least(l_end_number, l_max_number) + 1;

   END LOOP; -- (l_start_number <= l_max_number)

*/

   INSERT INTO FA_WORKER_JOBS
          (START_RANGE, END_RANGE, WORKER_NUM, STATUS,REQUEST_ID)
   SELECT MIN(ASSET_ID), MAX(ASSET_ID), 0,
          'UNASSIGNED', p_parent_request_id
     FROM ( SELECT /*+ parallel(BK) */
                   ASSET_ID, FLOOR(RANK()
              OVER (ORDER BY ASSET_ID)/l_batch_size ) UNIT_ID
              FROM FA_BOOKS BK
             WHERE BK.BOOK_TYPE_CODE = p_book_type_code
               AND BK.TRANSACTION_HEADER_ID_OUT IS NULL )
    GROUP BY UNIT_ID;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'Inserted ' || SQL%ROWCOUNT || ' jobs into FA_WORKER_JOBS table','');
   end if;

   fnd_concurrent.af_commit;

   x_return_status := 0;

EXCEPTION
   WHEN error_found then
        fnd_concurrent.af_rollback;

-- Commented for bugfix 4672237
--        if (g_log_level_rec.statement_level) then
--           fa_debug_pkg.dump_debug_messages(max_mesgs => 0);
--        end if;
        fa_srvr_msg.add_message(calling_fn      => l_calling_fn,
                                p_log_level_rec => g_log_level_rec);
        x_return_status := 2;

   WHEN OTHERS THEN
        FA_SRVR_MSG.ADD_SQL_ERROR(
           CALLING_FN      => l_calling_fn,
           p_log_level_rec => g_log_level_rec);
        fnd_concurrent.af_rollback;

-- Commented for bugfix 4672237
--        if (g_log_level_rec.statement_level) then
--           fa_debug_pkg.dump_debug_messages(max_mesgs => 0);
--        end if;
        x_return_status := 2;

END LOAD_WORKERS;

-----------------------------------------------------------------

END FA_MASS_DPR_RSV_ADJ_PKG;

/
