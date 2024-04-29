--------------------------------------------------------
--  DDL for Package Body FA_DEPRN_ROLLBACK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_DEPRN_ROLLBACK_PVT" AS
/* $Header: FAVDRBB.pls 120.15.12010000.7 2010/04/23 08:47:17 spooyath ship $   */

g_print_debug boolean := fa_cache_pkg.fa_print_debug;
g_l_thid                         NUMBER;  /* Bug#9018861 - For reporting currecny */

function do_rollback (
   p_asset_hdr_rec          IN     fa_api_types.asset_hdr_rec_type,
   p_period_rec             IN     fa_api_types.period_rec_type,
   p_deprn_run_id           IN     NUMBER,
   p_reversal_event_id      IN     NUMBER,
   p_reversal_date          IN     DATE,
   p_deprn_exists_count     IN     NUMBER,
   p_mrc_sob_type_code      IN     VARCHAR2,
   p_calling_fn             IN     VARCHAR2,
   p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return boolean as

   CURSOR c_get_thid IS
      select transaction_header_id
           , event_id
      from   fa_transaction_headers
      where  asset_id = p_asset_hdr_rec.asset_id
      and    book_type_code = p_asset_hdr_rec.book_type_code
      and    date_effective between p_period_rec.period_open_date
                                   and nvl(p_period_rec.period_close_date, sysdate)
      and   calling_interface = 'FADEPR'
      and   transaction_key = 'TG';

   CURSOR c_get_new_thid IS
      select transaction_header_id
           , date_effective
      from   fa_transaction_headers
      where  asset_id = p_asset_hdr_rec.asset_id
      and    book_type_code = p_asset_hdr_rec.book_type_code
      and    date_effective between p_period_rec.period_open_date
                                   and nvl(p_period_rec.period_close_date, sysdate)
      and   calling_interface = 'FAXDRB'
      and   transaction_key = 'TG'
      order by transaction_header_id desc;

   l_deprn_run_date               DATE;

   -- Terminal Gain/Loss
   l_thid                         NUMBER;
   l_event_id                     NUMBER;
   l_event_status                 VARCHAR2(1);
   l_deprn_source_info            XLA_EVENTS_PUB_PKG.t_event_source_info;
   l_security_context             XLA_EVENTS_PUB_PKG.t_security;
   l_trans_rec                    FA_API_TYPES.trans_rec_type;
   l_asset_type_rec               FA_API_TYPES.asset_type_rec_type;
   l_asset_fin_rec                FA_API_TYPES.asset_fin_rec_type;
   l_status                       boolean;
   l_bks_rowid                    ROWID;
   pers_per_yr                    NUMBER; -- Bug:5701095

   l_calling_fn  varchar2(40) := 'fa_deprn_rollback_pvt.do_rollback';

   rb_error        exception;

    -- Bug:6665510:Japan Tax Reform Project
    TYPE tab_rowid_type   is table of rowid index by binary_integer;
    TYPE tab_number_type  is table of number index by binary_integer;
    TYPE tab_varchar_type2 is table of varchar2(150) index by binary_integer;

    l_bks_rowid_tbl2      tab_rowid_type;
    l_asset_id_tbl2       tab_number_type;
    l_method_code_tbl2    tab_varchar_type2;
    l_life_in_months_tbl2 tab_number_type;
    l_rate_in_use_tbl     tab_number_type;

    l_method_type         number := 0;
    l_success             integer;
    l_rate_in_use         number;

    -- used for bulk fetching
    l_batch_size            NUMBER;
    l_rows_processed        NUMBER;
    l_result              integer;

    -- Bug:6665510:Japan Tax Reform Project
   cursor c_rate_in_use
   Is
      select bks.rowid,
             bks.asset_id,
             bks.deprn_method_code,
             bks.life_in_months
      from   fa_books bks,
             fa_methods mt
      where  bks.asset_id = p_asset_hdr_rec.asset_id
      and    bks.book_type_code = p_asset_hdr_rec.book_type_code
      and    bks.transaction_header_id_out is null
      and    bks.deprn_method_code = mt.method_code
      and    nvl(bks.life_in_months, -99) = nvl(mt.life_in_months, -99)
      and    nvl(mt.guarantee_rate_method_flag, 'NO') = 'YES';

    -- Bug:6665510:Japan Tax Reform Project
   cursor c_mc_rate_in_use
   Is
      select bks.rowid,
             bks.asset_id,
             bks.deprn_method_code,
             bks.life_in_months
      from   fa_mc_books bks,
             fa_methods mt
      where  bks.asset_id = p_asset_hdr_rec.asset_id
      and    bks.book_type_code = p_asset_hdr_rec.book_type_code
      and    bks.transaction_header_id_out is null
      and    bks.deprn_method_code = mt.method_code
      and    nvl(bks.life_in_months, -99) = nvl(mt.life_in_months, -99)
      and    nvl(mt.guarantee_rate_method_flag, 'NO') = 'YES'
      and    bks.set_of_books_id = p_asset_hdr_rec.set_of_books_id;
begin


   -- SLA UPTAKE
   -- backup the data delete or reverse the event

   if (p_reversal_event_id is not null) then

     if (p_mrc_sob_type_code = 'R') then

      insert into fa_mc_deprn_summary_h
            (SET_OF_BOOKS_ID              ,
             BOOK_TYPE_CODE               ,
             ASSET_ID                     ,
             DEPRN_RUN_DATE               ,
             DEPRN_AMOUNT                 ,
             YTD_DEPRN                    ,
             DEPRN_RESERVE                ,
             DEPRN_SOURCE_CODE            ,
             ADJUSTED_COST                ,
             BONUS_RATE                   ,
             LTD_PRODUCTION               ,
             PERIOD_COUNTER               ,
             PRODUCTION                   ,
             REVAL_AMORTIZATION           ,
             REVAL_AMORTIZATION_BASIS     ,
             REVAL_DEPRN_EXPENSE          ,
             REVAL_RESERVE                ,
             YTD_PRODUCTION               ,
             YTD_REVAL_DEPRN_EXPENSE      ,
             PRIOR_FY_EXPENSE             ,
             BONUS_DEPRN_AMOUNT           ,
             BONUS_YTD_DEPRN              ,
             BONUS_DEPRN_RESERVE          ,
             PRIOR_FY_BONUS_EXPENSE       ,
             DEPRN_OVERRIDE_FLAG          ,
             SYSTEM_DEPRN_AMOUNT          ,
             SYSTEM_BONUS_DEPRN_AMOUNT    ,
             EVENT_ID                     ,
             DEPRN_RUN_ID                 ,
             REVERSAL_EVENT_ID            ,
             REVERSAL_DATE                )
      select SET_OF_BOOKS_ID              ,
             BOOK_TYPE_CODE               ,
             ASSET_ID                     ,
             DEPRN_RUN_DATE               ,
             DEPRN_AMOUNT                 ,
             YTD_DEPRN                    ,
             DEPRN_RESERVE                ,
             DEPRN_SOURCE_CODE            ,
             ADJUSTED_COST                ,
             BONUS_RATE                   ,
             LTD_PRODUCTION               ,
             PERIOD_COUNTER               ,
             PRODUCTION                   ,
             REVAL_AMORTIZATION           ,
             REVAL_AMORTIZATION_BASIS     ,
             REVAL_DEPRN_EXPENSE          ,
             REVAL_RESERVE                ,
             YTD_PRODUCTION               ,
             YTD_REVAL_DEPRN_EXPENSE      ,
             PRIOR_FY_EXPENSE             ,
             BONUS_DEPRN_AMOUNT           ,
             BONUS_YTD_DEPRN              ,
             BONUS_DEPRN_RESERVE          ,
             PRIOR_FY_BONUS_EXPENSE       ,
             DEPRN_OVERRIDE_FLAG          ,
             SYSTEM_DEPRN_AMOUNT          ,
             SYSTEM_BONUS_DEPRN_AMOUNT    ,
             EVENT_ID                     ,
             DEPRN_RUN_ID                 ,
             P_REVERSAL_EVENT_ID          ,
             P_REVERSAL_DATE
        from fa_mc_deprn_summary ds
       where ds.book_type_code = p_asset_hdr_rec.book_type_code
         and ds.asset_id       = p_asset_hdr_rec.asset_id
         and ds.period_counter = p_period_rec.period_counter
         and ds.deprn_source_code in ('DEPRN','TRACK')
         and ds.set_of_books_id = p_asset_hdr_rec.set_of_books_id;

      insert into fa_mc_deprn_detail_h
            (SET_OF_BOOKS_ID                                    ,
             BOOK_TYPE_CODE                                     ,
             ASSET_ID                                           ,
             PERIOD_COUNTER                                     ,
             DISTRIBUTION_ID                                    ,
             DEPRN_SOURCE_CODE                                  ,
             DEPRN_RUN_DATE                                     ,
             DEPRN_AMOUNT                                       ,
             YTD_DEPRN                                          ,
             DEPRN_RESERVE                                      ,
             ADDITION_COST_TO_CLEAR                             ,
             COST                                               ,
             DEPRN_ADJUSTMENT_AMOUNT                            ,
             REVAL_AMORTIZATION                                 ,
             REVAL_DEPRN_EXPENSE                                ,
             REVAL_RESERVE                                      ,
             YTD_REVAL_DEPRN_EXPENSE                            ,
             BONUS_DEPRN_AMOUNT                                 ,
             BONUS_YTD_DEPRN                                    ,
             BONUS_DEPRN_RESERVE                                ,
             BONUS_DEPRN_ADJUSTMENT_AMOUNT                      ,
             EVENT_ID                                           ,
             DEPRN_RUN_ID                                       ,
             REVERSAL_EVENT_ID                                  ,
             REVERSAL_DATE                                      )
      select SET_OF_BOOKS_ID                                    ,
             BOOK_TYPE_CODE                                     ,
             ASSET_ID                                           ,
             PERIOD_COUNTER                                     ,
             DISTRIBUTION_ID                                    ,
             DEPRN_SOURCE_CODE                                  ,
             DEPRN_RUN_DATE                                     ,
             DEPRN_AMOUNT                                       ,
             YTD_DEPRN                                          ,
             DEPRN_RESERVE                                      ,
             ADDITION_COST_TO_CLEAR                             ,
             COST                                               ,
             DEPRN_ADJUSTMENT_AMOUNT                            ,
             REVAL_AMORTIZATION                                 ,
             REVAL_DEPRN_EXPENSE                                ,
             REVAL_RESERVE                                      ,
             YTD_REVAL_DEPRN_EXPENSE                            ,
             BONUS_DEPRN_AMOUNT                                 ,
             BONUS_YTD_DEPRN                                    ,
             BONUS_DEPRN_RESERVE                                ,
             BONUS_DEPRN_ADJUSTMENT_AMOUNT                      ,
             EVENT_ID                                           ,
             DEPRN_RUN_ID                                       ,
             P_REVERSAL_EVENT_ID                                ,
             P_REVERSAL_DATE
        from fa_mc_deprn_detail  ds
       where ds.book_type_code = p_asset_hdr_rec.book_type_code
         and ds.asset_id       = p_asset_hdr_rec.asset_id
         and ds.period_counter = p_period_rec.period_counter
         and ds.deprn_source_code in ('D','T')
         and ds.set_of_books_id = p_asset_hdr_rec.set_of_books_id;

     else

      -- archive the prior info into the backup table
      insert into fa_deprn_summary_h
            (BOOK_TYPE_CODE               ,
             ASSET_ID                     ,
             DEPRN_RUN_DATE               ,
             DEPRN_AMOUNT                 ,
             YTD_DEPRN                    ,
             DEPRN_RESERVE                ,
             DEPRN_SOURCE_CODE            ,
             ADJUSTED_COST                ,
             BONUS_RATE                   ,
             LTD_PRODUCTION               ,
             PERIOD_COUNTER               ,
             PRODUCTION                   ,
             REVAL_AMORTIZATION           ,
             REVAL_AMORTIZATION_BASIS     ,
             REVAL_DEPRN_EXPENSE          ,
             REVAL_RESERVE                ,
             YTD_PRODUCTION               ,
             YTD_REVAL_DEPRN_EXPENSE      ,
             PRIOR_FY_EXPENSE             ,
             BONUS_DEPRN_AMOUNT           ,
             BONUS_YTD_DEPRN              ,
             BONUS_DEPRN_RESERVE          ,
             PRIOR_FY_BONUS_EXPENSE       ,
             DEPRN_OVERRIDE_FLAG          ,
             SYSTEM_DEPRN_AMOUNT          ,
             SYSTEM_BONUS_DEPRN_AMOUNT    ,
             EVENT_ID                     ,
             DEPRN_RUN_ID                 ,
             REVERSAL_EVENT_ID            ,
             REVERSAL_DATE                )
      select BOOK_TYPE_CODE               ,
             ASSET_ID                     ,
             DEPRN_RUN_DATE               ,
             DEPRN_AMOUNT                 ,
             YTD_DEPRN                    ,
             DEPRN_RESERVE                ,
             DEPRN_SOURCE_CODE            ,
             ADJUSTED_COST                ,
             BONUS_RATE                   ,
             LTD_PRODUCTION               ,
             PERIOD_COUNTER               ,
             PRODUCTION                   ,
             REVAL_AMORTIZATION           ,
             REVAL_AMORTIZATION_BASIS     ,
             REVAL_DEPRN_EXPENSE          ,
             REVAL_RESERVE                ,
             YTD_PRODUCTION               ,
             YTD_REVAL_DEPRN_EXPENSE      ,
             PRIOR_FY_EXPENSE             ,
             BONUS_DEPRN_AMOUNT           ,
             BONUS_YTD_DEPRN              ,
             BONUS_DEPRN_RESERVE          ,
             PRIOR_FY_BONUS_EXPENSE       ,
             DEPRN_OVERRIDE_FLAG          ,
             SYSTEM_DEPRN_AMOUNT          ,
             SYSTEM_BONUS_DEPRN_AMOUNT    ,
             EVENT_ID                     ,
             DEPRN_RUN_ID                 ,
             P_REVERSAL_EVENT_ID          ,
             P_REVERSAL_DATE
        from fa_deprn_summary  ds
       where ds.book_type_code = p_asset_hdr_rec.book_type_code
         and ds.asset_id       = p_asset_hdr_rec.asset_id
         and ds.period_counter = p_period_rec.period_counter
         and ds.deprn_source_code in ('DEPRN','TRACK');

      insert into fa_deprn_detail_h
            (BOOK_TYPE_CODE                                     ,
             ASSET_ID                                           ,
             PERIOD_COUNTER                                     ,
             DISTRIBUTION_ID                                    ,
             DEPRN_SOURCE_CODE                                  ,
             DEPRN_RUN_DATE                                     ,
             DEPRN_AMOUNT                                       ,
             YTD_DEPRN                                          ,
             DEPRN_RESERVE                                      ,
             ADDITION_COST_TO_CLEAR                             ,
             COST                                               ,
             DEPRN_ADJUSTMENT_AMOUNT                            ,
             REVAL_AMORTIZATION                                 ,
             REVAL_DEPRN_EXPENSE                                ,
             REVAL_RESERVE                                      ,
             YTD_REVAL_DEPRN_EXPENSE                            ,
             BONUS_DEPRN_AMOUNT                                 ,
             BONUS_YTD_DEPRN                                    ,
             BONUS_DEPRN_RESERVE                                ,
             BONUS_DEPRN_ADJUSTMENT_AMOUNT                      ,
             EVENT_ID                                           ,
             DEPRN_RUN_ID                                       ,
             REVERSAL_EVENT_ID                                  ,
             REVERSAL_DATE                                      )
      select BOOK_TYPE_CODE                                     ,
             ASSET_ID                                           ,
             PERIOD_COUNTER                                     ,
             DISTRIBUTION_ID                                    ,
             DEPRN_SOURCE_CODE                                  ,
             DEPRN_RUN_DATE                                     ,
             DEPRN_AMOUNT                                       ,
             YTD_DEPRN                                          ,
             DEPRN_RESERVE                                      ,
             ADDITION_COST_TO_CLEAR                             ,
             COST                                               ,
             DEPRN_ADJUSTMENT_AMOUNT                            ,
             REVAL_AMORTIZATION                                 ,
             REVAL_DEPRN_EXPENSE                                ,
             REVAL_RESERVE                                      ,
             YTD_REVAL_DEPRN_EXPENSE                            ,
             BONUS_DEPRN_AMOUNT                                 ,
             BONUS_YTD_DEPRN                                    ,
             BONUS_DEPRN_RESERVE                                ,
             BONUS_DEPRN_ADJUSTMENT_AMOUNT                      ,
             EVENT_ID                                           ,
             DEPRN_RUN_ID                                       ,
             P_REVERSAL_EVENT_ID                                ,
             P_REVERSAL_DATE
        from fa_deprn_detail  ds
       where ds.book_type_code = p_asset_hdr_rec.book_type_code
         and ds.asset_id       = p_asset_hdr_rec.asset_id
         and ds.period_counter = p_period_rec.period_counter
         and ds.deprn_source_code in ('D','T');

      -- flag the header table too
      update fa_deprn_events
         set reversal_event_id = P_REVERSAL_EVENT_ID,
             reversal_date     = p_reversal_date
       where asset_id          = p_asset_hdr_rec.asset_id
         and book_type_code    = p_asset_hdr_rec.book_type_code
         and period_counter    = p_period_rec.period_counter
         and deprn_run_id      = p_deprn_run_id;

    end if;
   else -- event was not final -0 need to delete the dpern event
      delete from fa_deprn_events
       where asset_id          = p_asset_hdr_rec.asset_id
         and book_type_code    = p_asset_hdr_rec.book_type_code
         and period_counter    = p_period_rec.period_counter
         and reversal_event_id is null;
   end if;

   -- now continue with main processing


   if not fa_cache_pkg.fazcct(X_calendar => fa_cache_pkg.fazcbc_record.deprn_calendar
                                ,p_log_level_rec => p_log_level_rec) then
      raise rb_error;
   end if;

   -- Bug:5701095
   pers_per_yr  := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;

   -- Bug:6665510:Japan Tax Reform Project
   l_batch_size := nvl(fa_cache_pkg.fa_batch_size, 200);

   -- Bug# 3798413: Reset adjusted_cost back to the original adjusted_cost
   -- for the addition transaction.
   -- For period of addition transaction, we are getting the value
   -- from fa_deprn_summary's BOOKS row
   -- since Adj API also sets adjusted_cost in BOOKS' row to the latest value
   -- before depreciation correctly.
   --
   -- BUG# 4094166
   -- also update eofy_reserve and limit update to make
   -- sure this is period of addition only

   if (p_mrc_sob_type_code = 'R') then

       -- Bug:5701095
       update fa_mc_books bk
       set (adjusted_cost, eofy_reserve, formula_factor, adjusted_capacity) =
                           (Select Decode(ds2.deprn_source_code,
                                          'BOOKS', ds2.adjusted_cost,
                                          decode(p_period_rec.period_num - pers_per_yr,
                                                 0, decode(bk2.eofy_adj_cost,
                                                           null, decode(bk2.eop_adj_cost,
                                                                        null, decode(ds1.asset_id,
                                                                                     null, bk2.adjusted_cost,
                                                                                     ds1.adjusted_cost),
                                                                        bk2.eop_adj_cost),
                                                           bk2.eofy_adj_cost),
                                                 decode(bk2.eop_adj_cost,
                                                        null, decode(ds1.asset_id,
                                                                     null, bk2.adjusted_cost,
                                                                     ds1.adjusted_cost),
                                                        Decode(ds1.deprn_source_code,
                                                               'DEPRN', bk2.eop_adj_cost,
                                                               decode(ds1.asset_id,
                                                                      null, bk2.adjusted_cost,
                                                                      ds1.adjusted_cost)))
                                         )),
                                   Decode(ds2.deprn_source_code,
                                          'BOOKS', nvl(bk2.prior_eofy_reserve, bk2.eofy_reserve),
                                          decode(p_period_rec.period_num - pers_per_yr,
                                                 0, decode(bk2.prior_eofy_reserve,
                                                           null, bk2.eofy_reserve,
                                                           bk2.prior_eofy_reserve),
                                                 bk2.eofy_reserve)),
                                   Decode(p_period_rec.period_num - pers_per_yr,
                                          0, decode(bk2.eofy_adj_cost,
                                                    null, decode(bk2.eop_adj_cost,
                                                                 null, bk2.formula_factor,
                                                                 bk2.eop_formula_factor),
                                                    bk2.eofy_formula_factor),
                                          decode(bk2.eop_adj_cost,
                                                 null, bk2.formula_factor,
                                                 bk2.eop_formula_factor)),
                                   Decode(bk2.eop_adj_cost,
                                          null, bk2.adjusted_capacity,
                                          bk2.old_adjusted_capacity)
                            From  fa_mc_deprn_summary ds2, fa_mc_deprn_summary ds1, fa_mc_books bk2
                            where bk2.transaction_header_id_in = bk.transaction_header_id_in
                            and   bk2.set_of_books_id = p_asset_hdr_rec.set_of_books_id
                            and   ds2.asset_id(+) = bk2.asset_id
                            and   ds2.book_type_code(+) = bk2.book_type_code
                            and   ds2.period_counter(+) = (p_period_rec.period_counter - 1)
                            and   ds2.set_of_books_id(+) = p_asset_hdr_rec.set_of_books_id
                            and   ds1.asset_id (+) = bk2.asset_id
                            and   ds1.book_type_code (+) = bk2.book_type_code
                            and   ds1.period_counter (+) = (p_period_rec.period_counter)
                            and   ds1.set_of_books_id (+) = p_asset_hdr_rec.set_of_books_id
),
            eop_adj_cost = NULL,
            eop_formula_factor = NULL,
            eofy_adj_cost = Decode(p_period_rec.period_num - pers_per_yr,
                                   0, NULL,
                                   eofy_adj_cost),
            eofy_formula_factor = Decode(p_period_rec.period_num - pers_per_yr,
                                         0, NULL,
                                         eofy_formula_factor),
            prior_eofy_reserve = Decode(p_period_rec.period_num - pers_per_yr,
                                        0, NULL,
                                        prior_eofy_reserve),
            period_counter_fully_reserved = Decode(period_counter_fully_reserved,
                                                   p_period_rec.period_counter,
                                                   Null,
                                                   period_counter_fully_reserved),
            period_counter_life_complete = Decode(period_counter_life_complete,
                                                  p_period_rec.period_counter,
                                                  Null,
                                                  period_counter_life_complete)
       where asset_id = p_asset_hdr_rec.asset_id -- Bug:6778581
       and   book_type_code = p_asset_hdr_rec.book_type_code
       and   transaction_header_id_out is null
       and   set_of_books_id = p_asset_hdr_rec.set_of_books_id
;

   else -- if (p_mrc_sob_type_code = 'R') then

       -- Bug:5701095
       update fa_books  bk
       set (adjusted_cost, eofy_reserve, formula_factor, adjusted_capacity) =
                           (Select Decode(ds2.deprn_source_code,
                                          'BOOKS', ds2.adjusted_cost,
                                          decode(p_period_rec.period_num - pers_per_yr,
                                                 0, decode(bk2.eofy_adj_cost,
                                                           null, decode(bk2.eop_adj_cost,
                                                                        null, decode(ds1.asset_id,
                                                                                     null, bk2.adjusted_cost,
                                                                                     ds1.adjusted_cost),
                                                                        bk2.eop_adj_cost),
                                                           bk2.eofy_adj_cost),
                                                 decode(bk2.eop_adj_cost,
                                                        null, decode(ds1.asset_id,
                                                                     null, bk2.adjusted_cost,
                                                                     ds1.adjusted_cost),
                                                        decode(ds1.deprn_source_code,
                                                               'DEPRN', bk2.eop_adj_cost,
                                                                decode(ds1.asset_id,
                                                                       null, bk2.adjusted_cost,
                                                                       ds1.adjusted_cost)))
                                         )),
                                   Decode(ds2.deprn_source_code,
                                          'BOOKS', nvl(bk2.prior_eofy_reserve, bk2.eofy_reserve),
                                          decode(p_period_rec.period_num - pers_per_yr,
                                                 0, decode(bk2.prior_eofy_reserve,
                                                           null, bk2.eofy_reserve,
                                                           bk2.prior_eofy_reserve),
                                                 bk2.eofy_reserve)),
                                   Decode(p_period_rec.period_num - pers_per_yr,
                                          0, decode(bk2.eofy_adj_cost,
                                                    null, decode(bk2.eop_adj_cost,
                                                                 null, bk2.formula_factor,
                                                                 bk2.eop_formula_factor),
                                                    bk2.eofy_formula_factor),
                                          decode(bk2.eop_adj_cost,
                                                 null, bk2.formula_factor,
                                                 bk2.eop_formula_factor)),
                                   Decode(bk2.eop_adj_cost,
                                          null, bk2.adjusted_capacity,
                                          bk2.old_adjusted_capacity)
                            From  fa_deprn_summary ds2, fa_deprn_summary ds1, fa_books bk2
                            where bk2.transaction_header_id_in = bk.transaction_header_id_in
                            and   ds2.asset_id(+) = bk2.asset_id
                            and   ds2.book_type_code(+) = bk2.book_type_code
                            and   ds2.period_counter(+) = (p_period_rec.period_counter - 1)
                            and   ds1.asset_id (+) = bk2.asset_id
                            and   ds1.book_type_code (+) = bk2.book_type_code
                            and   ds1.period_counter (+) = (p_period_rec.period_counter)),
            eop_adj_cost = NULL,
            eop_formula_factor = NULL,
            eofy_adj_cost = Decode(p_period_rec.period_num - pers_per_yr,
                                   0, NULL,
                                   eofy_adj_cost),
            eofy_formula_factor = Decode(p_period_rec.period_num - pers_per_yr,
                                         0, NULL,
                                         eofy_formula_factor),
            prior_eofy_reserve = Decode(p_period_rec.period_num - pers_per_yr,
                                        0, NULL,
                                        prior_eofy_reserve),
            period_counter_fully_reserved = Decode(period_counter_fully_reserved,
                                                   p_period_rec.period_counter,
                                                   Null,
                                                   period_counter_fully_reserved),
            period_counter_life_complete = Decode(period_counter_life_complete,
                                                  p_period_rec.period_counter,
                                                  Null,
                                                  period_counter_life_complete)
        where asset_id = p_asset_hdr_rec.asset_id -- Bug:6778581
        and   book_type_code = p_asset_hdr_rec.book_type_code
        and   transaction_header_id_out is null;
   end if; -- if (p_mrc_sob_type_code = 'R') then

   -- delete from DS

   if (p_mrc_sob_type_code = 'R') then
      delete
        from fa_mc_deprn_summary  ds
       where ds.asset_id                   = p_asset_hdr_rec.asset_id
         and ds.book_type_code             = p_asset_hdr_rec.book_type_code
         and ds.period_counter             = p_period_rec.period_counter
         and ds.deprn_source_code in ('DEPRN','TRACK')
         and ds.set_of_books_id = p_asset_hdr_rec.set_of_books_id ;
   else
      delete
        from fa_deprn_summary  ds
       where ds.asset_id                   = p_asset_hdr_rec.asset_id
         and ds.book_type_code             = p_asset_hdr_rec.book_type_code
         and ds.period_counter             = p_period_rec.period_counter
         and ds.deprn_source_code in ('DEPRN','TRACK');
   end if;


   -- delete from DD

   if (p_mrc_sob_type_code = 'R') then
      delete
        from fa_mc_deprn_detail  dd
       where dd.asset_id                   = p_asset_hdr_rec.asset_id
         and dd.book_type_code             = p_asset_hdr_rec.book_type_code
         and dd.period_counter             = p_period_rec.period_counter
         and dd.deprn_source_code in ('D','T')
         and dd.set_of_books_id = p_asset_hdr_rec.set_of_books_id ;
   else
      delete
        from fa_deprn_detail  dd
       where dd.asset_id                   = p_asset_hdr_rec.asset_id
         and dd.book_type_code             = p_asset_hdr_rec.book_type_code
         and dd.period_counter             = p_period_rec.period_counter
         and dd.deprn_source_code in ('D','T');
   end if;

   -- Delete from FA_BOOKS_SUMMARY

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       'Deleting FA_BOOKS_SUMMARY rows, next period ctr',
                       p_period_rec.period_counter + 1
                        ,p_log_level_rec => p_log_level_rec);
   end if;

   if (p_mrc_sob_type_code = 'R') then

      delete from fa_mc_books_summary bs
       where bs.asset_id             = p_asset_hdr_rec.asset_id
         and bs.book_type_code       = p_asset_hdr_rec.book_type_code
         and bs.period_counter       = p_period_rec.period_counter + 1
         and bs.set_of_books_id      = p_asset_hdr_rec.set_of_books_id ;

      update fa_mc_books_summary bs
         set deprn_amount            = expense_adjustment_amount,
             ytd_deprn               = ytd_deprn     - nvl(deprn_amount,0) + nvl(expense_adjustment_amount,0), --Bug8244128
             deprn_reserve           = deprn_reserve - nvl(deprn_amount,0) + nvl(expense_adjustment_amount,0), --Bug8244128
             bonus_deprn_amount      = 0,
             bonus_ytd_deprn         = bonus_ytd_deprn     - bonus_deprn_amount,
             bonus_deprn_reserve     = bonus_deprn_reserve - bonus_deprn_amount,
             bonus_rate              = 0,
             adjusted_capacity       = adjusted_capacity + production,
             ltd_production          = ltd_production - production,
             ytd_production          = ytd_production - production,
             production              = 0,
             reval_deprn_expense     = 0,
             reval_reserve           = reval_reserve           - reval_deprn_expense,
             ytd_reval_deprn_expense = ytd_reval_deprn_expense - reval_deprn_expense
       where bs.asset_id             = p_asset_hdr_rec.asset_id
         and bs.book_type_code       = p_asset_hdr_rec.book_type_code
         and bs.period_counter       = p_period_rec.period_counter
         and bs.set_of_books_id      = p_asset_hdr_rec.set_of_books_id ;

   else

      delete from fa_books_summary bs
       where bs.asset_id             = p_asset_hdr_rec.asset_id
         and bs.book_type_code       = p_asset_hdr_rec.book_type_code
         and bs.period_counter       = p_period_rec.period_counter + 1;

      update fa_books_summary bs
         set deprn_amount            = expense_adjustment_amount,
             ytd_deprn               = ytd_deprn     - nvl(deprn_amount,0) + nvl(expense_adjustment_amount,0), --Bug8244128
             deprn_reserve           = deprn_reserve - nvl(deprn_amount,0) + nvl(expense_adjustment_amount,0), --Bug8244128
             bonus_deprn_amount      = 0,
             bonus_ytd_deprn         = bonus_ytd_deprn     - bonus_deprn_amount,
             bonus_deprn_reserve     = bonus_deprn_reserve - bonus_deprn_amount,
             bonus_rate              = 0,
             adjusted_capacity       = adjusted_capacity + production,
             ltd_production          = ltd_production - production,
             ytd_production          = ytd_production - production,
             production              = 0,
             reval_deprn_expense     = 0,
             reval_reserve           = reval_reserve           - reval_deprn_expense,
             ytd_reval_deprn_expense = ytd_reval_deprn_expense - reval_deprn_expense
       where bs.asset_id             = p_asset_hdr_rec.asset_id
         and bs.book_type_code       = p_asset_hdr_rec.book_type_code
         and bs.period_counter       = p_period_rec.period_counter;

   end if;

   -- rollback/reverse terminal gain loss
   -- pending new api / logic

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'BEGIN', 'Processing terminal gain loss'
            ,p_log_level_rec => p_log_level_rec);
   end if;

   open c_get_thid;
   fetch c_get_thid into l_thid, l_event_id;
   close c_get_thid;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'THID of TGL', l_thid
            ,p_log_level_rec => p_log_level_rec);
   end if;
   /* Bug#9018861 - set global variable for reporting currency */
   if p_mrc_sob_type_code <> 'R' then
      g_l_thid := l_thid;
   else
      l_thid := g_l_thid;
   end if;
   if (l_thid is not null ) then
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'event id', l_event_id
                  ,p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'sob type code', p_mrc_sob_type_code
                  ,p_log_level_rec => p_log_level_rec);
      end if;

      if (l_event_id is not null) then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'calling get event status for event ', l_event_id
                        ,p_log_level_rec => p_log_level_rec);
         end if;

         l_deprn_source_info.application_id        := 140;
         l_deprn_source_info.ledger_id             := p_asset_hdr_rec.set_of_books_id;

--
-- Old thid or new thid?
--
         l_deprn_source_info.source_id_int_1       := l_thid;
         l_deprn_source_info.entity_type_code      := 'TRANSACTIONS';
         l_deprn_source_info.transaction_number    := to_char(l_thid);
         l_deprn_source_info.source_id_char_1      := p_asset_hdr_rec.book_type_code;

         -- check the event status
         l_event_status := XLA_EVENTS_PUB_PKG.get_event_status
                           (p_event_source_info            => l_deprn_source_info,
                            p_event_id                     => l_event_id,
                            p_valuation_method             => p_asset_hdr_rec.book_type_code,
                            p_security_context             => l_security_context);

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'event status ', l_event_status
                        ,p_log_level_rec => p_log_level_rec);
         end if;

      end if;

      if (l_event_status = XLA_EVENTS_PUB_PKG.C_EVENT_PROCESSED) then
         -- Reverse Terminal Gain Loss

         if (p_mrc_sob_type_code <> 'R') then
            SELECT fa_transaction_headers_s.nextval
            INTO   l_trans_rec.transaction_header_id
            FROM   DUAL;

            --
            -- Populating for calling FA_XLA_EVENTS_PVT.create_transaction_event
            --
            l_trans_rec.transaction_subtype := 'AMORTIZED';
            l_trans_rec.transaction_type_code := 'ADJUSTMENT';
            l_trans_rec.transaction_key := 'TG';
            l_trans_rec.transaction_date_entered := greatest(p_period_rec.calendar_period_open_date,
                                                             least(sysdate,p_period_rec.calendar_period_close_date));
            l_trans_rec.amortization_start_date := l_trans_rec.transaction_date_entered;
            l_trans_rec.calling_interface := 'FAXDRB';

            l_asset_type_rec.asset_type := 'GROUP';

            if not FA_XLA_EVENTS_PVT.create_transaction_event(
                        p_asset_hdr_rec          => p_asset_hdr_rec,
                        p_asset_type_rec         => l_asset_type_rec,
                        px_trans_rec             => l_trans_rec,
                        p_event_status           => NULL,
                        p_calling_fn             => l_calling_fn
                        ,p_log_level_rec => p_log_level_rec) then
               fa_debug_pkg.add(l_calling_fn, 'ERROR', 'Calling create_transaction_event'
                              ,p_log_level_rec => p_log_level_rec);
               raise rb_error;
            end if;

            INSERT INTO FA_TRANSACTION_HEADERS(
                    TRANSACTION_HEADER_ID
                  , BOOK_TYPE_CODE
                  , ASSET_ID
                  , TRANSACTION_TYPE_CODE
                  , TRANSACTION_DATE_ENTERED
                  , DATE_EFFECTIVE
                  , LAST_UPDATE_DATE
                  , LAST_UPDATED_BY
                  , TRANSACTION_NAME
                  , INVOICE_TRANSACTION_ID
                  , SOURCE_TRANSACTION_HEADER_ID
                  , MASS_REFERENCE_ID
                  , LAST_UPDATE_LOGIN
                  , TRANSACTION_SUBTYPE
                  , ATTRIBUTE1
                  , ATTRIBUTE2
                  , ATTRIBUTE3
                  , ATTRIBUTE4
                  , ATTRIBUTE5
                  , ATTRIBUTE6
                  , ATTRIBUTE7
                  , ATTRIBUTE8
                  , ATTRIBUTE9
                  , ATTRIBUTE10
                  , ATTRIBUTE11
                  , ATTRIBUTE12
                  , ATTRIBUTE13
                  , ATTRIBUTE14
                  , ATTRIBUTE15
                  , ATTRIBUTE_CATEGORY_CODE
                  , TRANSACTION_KEY
                  , AMORTIZATION_START_DATE
                  , CALLING_INTERFACE
                  , MASS_TRANSACTION_ID
                  , MEMBER_TRANSACTION_HEADER_ID
                  , TRX_REFERENCE_ID
                  , EVENT_ID
            ) select
                    l_trans_rec.transaction_header_id --TRANSACTION_HEADER_ID
                  , BOOK_TYPE_CODE
                  , ASSET_ID
                  , TRANSACTION_TYPE_CODE
                  , TRANSACTION_DATE_ENTERED
                  , p_reversal_date -- DATE_EFFECTIVE
                  , p_reversal_date -- LAST_UPDATE_DATE
                  , l_trans_rec.who_info.last_updated_by
                  , TRANSACTION_NAME
                  , INVOICE_TRANSACTION_ID
                  , SOURCE_TRANSACTION_HEADER_ID
                  , MASS_REFERENCE_ID
                  , LAST_UPDATE_LOGIN
                  , TRANSACTION_SUBTYPE
                  , ATTRIBUTE1
                  , ATTRIBUTE2
                  , ATTRIBUTE3
                  , ATTRIBUTE4
                  , ATTRIBUTE5
                  , ATTRIBUTE6
                  , ATTRIBUTE7
                  , ATTRIBUTE8
                  , ATTRIBUTE9
                  , ATTRIBUTE10
                  , ATTRIBUTE11
                  , ATTRIBUTE12
                  , ATTRIBUTE13
                  , ATTRIBUTE14
                  , ATTRIBUTE15
                  , ATTRIBUTE_CATEGORY_CODE
                  , TRANSACTION_KEY
                  , AMORTIZATION_START_DATE
                  , 'FAXDRB' -- CALLING_INTERFACE
                  , MASS_TRANSACTION_ID
                  , MEMBER_TRANSACTION_HEADER_ID
                  , TRX_REFERENCE_ID
                  , l_trans_rec.event_id -- EVENT_ID
              from  fa_transaction_headers
              where asset_id = p_asset_hdr_rec.asset_id
              and   book_type_code = p_asset_hdr_rec.book_type_code
              and   transaction_header_id = l_thid
            ;

            INSERT INTO FA_ADJUSTMENTS(
                TRANSACTION_HEADER_ID
              , SOURCE_TYPE_CODE
              , ADJUSTMENT_TYPE
              , DEBIT_CREDIT_FLAG
              , CODE_COMBINATION_ID
              , BOOK_TYPE_CODE
              , ASSET_ID
              , ADJUSTMENT_AMOUNT
              , DISTRIBUTION_ID
              , LAST_UPDATE_DATE
              , LAST_UPDATED_BY
              , LAST_UPDATE_LOGIN
              , ANNUALIZED_ADJUSTMENT
              , PERIOD_COUNTER_ADJUSTED
              , PERIOD_COUNTER_CREATED
              , ASSET_INVOICE_ID
              , GLOBAL_ATTRIBUTE1
              , GLOBAL_ATTRIBUTE2
              , GLOBAL_ATTRIBUTE3
              , GLOBAL_ATTRIBUTE4
              , GLOBAL_ATTRIBUTE5
              , GLOBAL_ATTRIBUTE6
              , GLOBAL_ATTRIBUTE7
              , GLOBAL_ATTRIBUTE8
              , GLOBAL_ATTRIBUTE9
              , GLOBAL_ATTRIBUTE10
              , GLOBAL_ATTRIBUTE11
              , GLOBAL_ATTRIBUTE12
              , GLOBAL_ATTRIBUTE13
              , GLOBAL_ATTRIBUTE14
              , GLOBAL_ATTRIBUTE15
              , GLOBAL_ATTRIBUTE16
              , GLOBAL_ATTRIBUTE17
              , GLOBAL_ATTRIBUTE18
              , GLOBAL_ATTRIBUTE19
              , GLOBAL_ATTRIBUTE20
              , GLOBAL_ATTRIBUTE_CATEGORY
              , DEPRN_OVERRIDE_FLAG
              , TRACK_MEMBER_FLAG
              , ADJUSTMENT_LINE_ID
              , SOURCE_LINE_ID
              , SOURCE_DEST_CODE
            ) select
                l_trans_rec.transaction_header_id --  TRANSACTION_HEADER_ID
              , SOURCE_TYPE_CODE
              , ADJUSTMENT_TYPE
              , decode(debit_credit_flag, 'DR', 'CR', 'DR') --DEBIT_CREDIT_FLAG
              , CODE_COMBINATION_ID
              , BOOK_TYPE_CODE
              , ASSET_ID
              , ADJUSTMENT_AMOUNT
              , DISTRIBUTION_ID
              , p_reversal_date --LAST_UPDATE_DATE
              , l_trans_rec.who_info.last_updated_by --LAST_UPDATED_BY
              , l_trans_rec.who_info.last_update_login --LAST_UPDATE_LOGIN
              , ANNUALIZED_ADJUSTMENT
              , PERIOD_COUNTER_ADJUSTED
              , PERIOD_COUNTER_CREATED
              , ASSET_INVOICE_ID
              , GLOBAL_ATTRIBUTE1
              , GLOBAL_ATTRIBUTE2
              , GLOBAL_ATTRIBUTE3
              , GLOBAL_ATTRIBUTE4
              , GLOBAL_ATTRIBUTE5
              , GLOBAL_ATTRIBUTE6
              , GLOBAL_ATTRIBUTE7
              , GLOBAL_ATTRIBUTE8
              , GLOBAL_ATTRIBUTE9
              , GLOBAL_ATTRIBUTE10
              , GLOBAL_ATTRIBUTE11
              , GLOBAL_ATTRIBUTE12
              , GLOBAL_ATTRIBUTE13
              , GLOBAL_ATTRIBUTE14
              , GLOBAL_ATTRIBUTE15
              , GLOBAL_ATTRIBUTE16
              , GLOBAL_ATTRIBUTE17
              , GLOBAL_ATTRIBUTE18
              , GLOBAL_ATTRIBUTE19
              , GLOBAL_ATTRIBUTE20
              , GLOBAL_ATTRIBUTE_CATEGORY
              , DEPRN_OVERRIDE_FLAG
              , TRACK_MEMBER_FLAG
              , fa_adjustments_s.nextval -- ADJUSTMENT_LINE_ID
              , SOURCE_LINE_ID
              , SOURCE_DEST_CODE
              from fa_adjustments
              where asset_id = p_asset_hdr_rec.asset_id
              and   book_type_code = p_asset_hdr_rec.book_type_code
              and   transaction_header_id = l_thid
            ;

         else -- Reporting book
            open c_get_new_thid;
            fetch c_get_new_thid into l_trans_rec.transaction_header_id
                                    , l_trans_rec.who_info.last_update_date;
            close c_get_new_thid;

            INSERT INTO FA_MC_ADJUSTMENTS(
                SET_OF_BOOKS_ID
              , TRANSACTION_HEADER_ID
              , SOURCE_TYPE_CODE
              , ADJUSTMENT_TYPE
              , DEBIT_CREDIT_FLAG
              , CODE_COMBINATION_ID
              , BOOK_TYPE_CODE
              , ASSET_ID
              , ADJUSTMENT_AMOUNT
              , DISTRIBUTION_ID
              , LAST_UPDATE_DATE
              , LAST_UPDATED_BY
              , LAST_UPDATE_LOGIN
              , ANNUALIZED_ADJUSTMENT
              , PERIOD_COUNTER_ADJUSTED
              , PERIOD_COUNTER_CREATED
              , ASSET_INVOICE_ID
              , GLOBAL_ATTRIBUTE1
              , GLOBAL_ATTRIBUTE2
              , GLOBAL_ATTRIBUTE3
              , GLOBAL_ATTRIBUTE4
              , GLOBAL_ATTRIBUTE5
              , GLOBAL_ATTRIBUTE6
              , GLOBAL_ATTRIBUTE7
              , GLOBAL_ATTRIBUTE8
              , GLOBAL_ATTRIBUTE9
              , GLOBAL_ATTRIBUTE10
              , GLOBAL_ATTRIBUTE11
              , GLOBAL_ATTRIBUTE12
              , GLOBAL_ATTRIBUTE13
              , GLOBAL_ATTRIBUTE14
              , GLOBAL_ATTRIBUTE15
              , GLOBAL_ATTRIBUTE16
              , GLOBAL_ATTRIBUTE17
              , GLOBAL_ATTRIBUTE18
              , GLOBAL_ATTRIBUTE19
              , GLOBAL_ATTRIBUTE20
              , GLOBAL_ATTRIBUTE_CATEGORY
              , DEPRN_OVERRIDE_FLAG
              , TRACK_MEMBER_FLAG
              , ADJUSTMENT_LINE_ID
              , SOURCE_LINE_ID
              , SOURCE_DEST_CODE
            ) select
                SET_OF_BOOKS_ID
              , l_trans_rec.transaction_header_id --  TRANSACTION_HEADER_ID
              , SOURCE_TYPE_CODE
              , ADJUSTMENT_TYPE
              , decode(debit_credit_flag, 'DR', 'CR', 'DR') --DEBIT_CREDIT_FLAG
              , CODE_COMBINATION_ID
              , BOOK_TYPE_CODE
              , ASSET_ID
              , ADJUSTMENT_AMOUNT
              , DISTRIBUTION_ID
              , l_trans_rec.who_info.last_update_date --LAST_UPDATE_DATE
              , l_trans_rec.who_info.last_updated_by --LAST_UPDATED_BY
              , l_trans_rec.who_info.last_update_login --LAST_UPDATE_LOGIN
              , ANNUALIZED_ADJUSTMENT
              , PERIOD_COUNTER_ADJUSTED
              , PERIOD_COUNTER_CREATED
              , ASSET_INVOICE_ID
              , GLOBAL_ATTRIBUTE1
              , GLOBAL_ATTRIBUTE2
              , GLOBAL_ATTRIBUTE3
              , GLOBAL_ATTRIBUTE4
              , GLOBAL_ATTRIBUTE5
              , GLOBAL_ATTRIBUTE6
              , GLOBAL_ATTRIBUTE7
              , GLOBAL_ATTRIBUTE8
              , GLOBAL_ATTRIBUTE9
              , GLOBAL_ATTRIBUTE10
              , GLOBAL_ATTRIBUTE11
              , GLOBAL_ATTRIBUTE12
              , GLOBAL_ATTRIBUTE13
              , GLOBAL_ATTRIBUTE14
              , GLOBAL_ATTRIBUTE15
              , GLOBAL_ATTRIBUTE16
              , GLOBAL_ATTRIBUTE17
              , GLOBAL_ATTRIBUTE18
              , GLOBAL_ATTRIBUTE19
              , GLOBAL_ATTRIBUTE20
              , GLOBAL_ATTRIBUTE_CATEGORY
              , DEPRN_OVERRIDE_FLAG
              , TRACK_MEMBER_FLAG
              , fa_adjustments_s.nextval -- ADJUSTMENT_LINE_ID
              , SOURCE_LINE_ID
              , SOURCE_DEST_CODE
              from fa_mc_adjustments
              where asset_id = p_asset_hdr_rec.asset_id
              and   book_type_code = p_asset_hdr_rec.book_type_code
              and   transaction_header_id = l_thid
              and   set_of_books_id = p_asset_hdr_rec.set_of_books_id
            ;

         end if; -- (p_mrc_sob_type_code <> 'R')

         fa_books_pkg.deactivate_row
               (X_asset_id                  => p_asset_hdr_rec.asset_id,
                X_book_type_code            => p_asset_hdr_rec.book_type_code,
                X_transaction_header_id_out => l_trans_rec.transaction_header_id,
                X_date_ineffective          => l_trans_rec.who_info.last_update_date,
                X_mrc_sob_type_code         => p_mrc_sob_type_code,
                X_set_of_books_id           => p_asset_hdr_rec.set_of_books_id,
                X_Calling_Fn                => l_calling_fn
                ,p_log_level_rec => p_log_level_rec);

         fa_books_pkg.insert_row
               (X_Rowid                        => l_bks_rowid,
                X_Book_Type_Code               => p_asset_hdr_rec.book_type_code,
                X_Asset_Id                     => p_asset_hdr_rec.asset_id,
                X_Date_Placed_In_Service       => l_asset_fin_rec.date_placed_in_service,
                X_Date_Effective               => l_trans_rec.who_info.last_update_date,
                X_Deprn_Start_Date             => l_asset_fin_rec.deprn_start_date,
                X_Deprn_Method_Code            => l_asset_fin_rec.deprn_method_code,
                X_Life_In_Months               => l_asset_fin_rec.life_in_months,
                X_Rate_Adjustment_Factor       => l_asset_fin_rec.rate_adjustment_factor,
                X_Adjusted_Cost                => l_asset_fin_rec.adjusted_cost,
                X_Cost                         => l_asset_fin_rec.cost,
                X_Original_Cost                => l_asset_fin_rec.original_cost,
                X_Salvage_Value                => l_asset_fin_rec.salvage_value,
                X_Prorate_Convention_Code      => l_asset_fin_rec.prorate_convention_code,
                X_Prorate_Date                 => l_asset_fin_rec.prorate_date,
                X_Cost_Change_Flag             => l_asset_fin_rec.cost_change_flag,
                X_Adjustment_Required_Status   => l_asset_fin_rec.adjustment_required_status,
                X_Capitalize_Flag              => l_asset_fin_rec.capitalize_flag,
                X_Retirement_Pending_Flag      => l_asset_fin_rec.retirement_pending_flag,
                X_Depreciate_Flag              => l_asset_fin_rec.depreciate_flag,
                X_Disabled_Flag                => l_asset_fin_rec.disabled_flag, --HH
                X_Last_Update_Date             => l_trans_rec.who_info.last_update_date,
                X_Last_Updated_By              => l_trans_rec.who_info.last_updated_by,
                X_Date_Ineffective             => NULL,
                X_Transaction_Header_Id_In     => l_trans_rec.transaction_header_id,
                X_Transaction_Header_Id_Out    => NULL,
                X_Itc_Amount_Id                => l_asset_fin_rec.itc_amount_id,
                X_Itc_Amount                   => l_asset_fin_rec.itc_amount,
                X_Retirement_Id                => l_asset_fin_rec.retirement_id,
                X_Tax_Request_Id               => l_asset_fin_rec.tax_request_id,
                X_Itc_Basis                    => l_asset_fin_rec.itc_basis,
                X_Basic_Rate                   => l_asset_fin_rec.basic_rate,
                X_Adjusted_Rate                => l_asset_fin_rec.adjusted_rate,
                X_Bonus_Rule                   => l_asset_fin_rec.bonus_rule,
                X_Ceiling_Name                 => l_asset_fin_rec.ceiling_name,
                X_Recoverable_Cost             => l_asset_fin_rec.recoverable_cost,
                X_Last_Update_Login            => l_trans_rec.who_info.last_update_login,
                X_Adjusted_Capacity            => l_asset_fin_rec.adjusted_capacity,
                X_Fully_Rsvd_Revals_Counter    => l_asset_fin_rec.fully_rsvd_revals_counter,
                X_Idled_Flag                   => l_asset_fin_rec.idled_flag,
                X_Period_Counter_Capitalized   => l_asset_fin_rec.period_counter_capitalized,
                X_PC_Fully_Reserved            => l_asset_fin_rec.period_counter_fully_reserved,
                X_Period_Counter_Fully_Retired => l_asset_fin_rec.period_counter_fully_retired,
                X_Production_Capacity          => l_asset_fin_rec.production_capacity,
                X_Reval_Amortization_Basis     => l_asset_fin_rec.reval_amortization_basis,
                X_Reval_Ceiling                => l_asset_fin_rec.reval_ceiling,
                X_Unit_Of_Measure              => l_asset_fin_rec.unit_of_measure,
                X_Unrevalued_Cost              => l_asset_fin_rec.unrevalued_cost,
                X_Annual_Deprn_Rounding_Flag   => l_asset_fin_rec.annual_deprn_rounding_flag,
                X_Percent_Salvage_Value        => l_asset_fin_rec.percent_salvage_value,
                X_Allowed_Deprn_Limit          => l_asset_fin_rec.allowed_deprn_limit,
                X_Allowed_Deprn_Limit_Amount   => l_asset_fin_rec.allowed_deprn_limit_amount,
                X_Period_Counter_Life_Complete => l_asset_fin_rec.period_counter_life_complete,
                X_Adjusted_Recoverable_Cost    => l_asset_fin_rec.adjusted_recoverable_cost,
                X_Short_Fiscal_Year_Flag       => l_asset_fin_rec.short_fiscal_year_flag,
                X_Conversion_Date              => l_asset_fin_rec.conversion_date,
                X_Orig_Deprn_Start_Date        => l_asset_fin_rec.orig_deprn_start_date,
                X_Remaining_Life1              => l_asset_fin_rec.remaining_life1,
                X_Remaining_Life2              => l_asset_fin_rec.remaining_life2,
                X_Old_Adj_Cost                 => l_asset_fin_rec.old_adjusted_cost,
                X_Formula_Factor               => l_asset_fin_rec.formula_factor,
                X_gf_Attribute1                => l_asset_fin_rec.global_attribute1,
                X_gf_Attribute2                => l_asset_fin_rec.global_attribute2,
                X_gf_Attribute3                => l_asset_fin_rec.global_attribute3,
                X_gf_Attribute4                => l_asset_fin_rec.global_attribute4,
                X_gf_Attribute5                => l_asset_fin_rec.global_attribute5,
                X_gf_Attribute6                => l_asset_fin_rec.global_attribute6,
                X_gf_Attribute7                => l_asset_fin_rec.global_attribute7,
                X_gf_Attribute8                => l_asset_fin_rec.global_attribute8,
                X_gf_Attribute9                => l_asset_fin_rec.global_attribute9,
                X_gf_Attribute10               => l_asset_fin_rec.global_attribute10,
                X_gf_Attribute11               => l_asset_fin_rec.global_attribute11,
                X_gf_Attribute12               => l_asset_fin_rec.global_attribute12,
                X_gf_Attribute13               => l_asset_fin_rec.global_attribute13,
                X_gf_Attribute14               => l_asset_fin_rec.global_attribute14,
                X_gf_Attribute15               => l_asset_fin_rec.global_attribute15,
                X_gf_Attribute16               => l_asset_fin_rec.global_attribute16,
                X_gf_Attribute17               => l_asset_fin_rec.global_attribute17,
                X_gf_Attribute18               => l_asset_fin_rec.global_attribute18,
                X_gf_Attribute19               => l_asset_fin_rec.global_attribute19,
                X_gf_Attribute20               => l_asset_fin_rec.global_attribute20,
                X_global_attribute_category    => l_asset_fin_rec.global_attribute_category,
                X_group_asset_id               => l_asset_fin_rec.group_asset_id,
                X_salvage_type                 => l_asset_fin_rec.salvage_type,
                X_deprn_limit_type             => l_asset_fin_rec.deprn_limit_type,
                X_over_depreciate_option       => l_asset_fin_rec.over_depreciate_option,
                X_super_group_id               => l_asset_fin_rec.super_group_id,
                X_reduction_rate               => l_asset_fin_rec.reduction_rate,
                X_reduce_addition_flag         => l_asset_fin_rec.reduce_addition_flag,
                X_reduce_adjustment_flag       => l_asset_fin_rec.reduce_adjustment_flag,
                X_reduce_retirement_flag       => l_asset_fin_rec.reduce_retirement_flag,
                X_recognize_gain_loss          => l_asset_fin_rec.recognize_gain_loss,
                X_recapture_reserve_flag       => l_asset_fin_rec.recapture_reserve_flag,
                X_limit_proceeds_flag          => l_asset_fin_rec.limit_proceeds_flag,
                X_terminal_gain_loss           => l_asset_fin_rec.terminal_gain_loss,
                X_exclude_proceeds_from_basis  => l_asset_fin_rec.exclude_proceeds_from_basis,
                X_retirement_deprn_option      => l_asset_fin_rec.retirement_deprn_option,
                X_tracking_method              => l_asset_fin_rec.tracking_method,
                X_allocate_to_fully_rsv_flag   => l_asset_fin_rec.allocate_to_fully_rsv_flag,
                X_allocate_to_fully_ret_flag   => l_asset_fin_rec.allocate_to_fully_ret_flag,
                X_exclude_fully_rsv_flag       => l_asset_fin_rec.exclude_fully_rsv_flag,
                X_excess_allocation_option     => l_asset_fin_rec.excess_allocation_option,
                X_depreciation_option          => l_asset_fin_rec.depreciation_option,
                X_member_rollup_flag           => l_asset_fin_rec.member_rollup_flag,
                X_ytd_proceeds                 => l_asset_fin_rec.ytd_proceeds,
                X_ltd_proceeds                 => l_asset_fin_rec.ltd_proceeds,
                X_eofy_reserve                 => l_asset_fin_rec.eofy_reserve,
                X_cip_cost                     => l_asset_fin_rec.cip_cost,
                X_terminal_gain_loss_amount    => null,
                X_terminal_gain_loss_flag      => 'Y',
                X_ltd_cost_of_removal          => l_asset_fin_rec.ltd_cost_of_removal,
                X_mrc_sob_type_code            => p_mrc_sob_type_code,
                X_set_of_books_id              => p_asset_hdr_rec.set_of_books_id,
                X_Return_Status                => l_status,
                X_Calling_Fn                   => l_calling_fn
                ,p_log_level_rec => p_log_level_rec);

         if not l_status then
            fa_debug_pkg.add(l_calling_fn, 'Failed to insert ', 'FA_BOOKS'
                        ,p_log_level_rec => p_log_level_rec);
            raise rb_error;
         end if;
      /* Bug#9018861 - Modified condition for reporting currency */
      elsif (l_event_status = XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED OR p_mrc_sob_type_code = 'R' ) then

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'deleting event', l_event_id
                        ,p_log_level_rec => p_log_level_rec);
         end if;
         /* Bug#9018861 - Null means already deleted for primary book */
         if p_mrc_sob_type_code <> 'R' then
            XLA_EVENTS_PUB_PKG.delete_event
               (p_event_source_info            => l_deprn_source_info,
                p_event_id                     => l_event_id,
                p_valuation_method             => p_asset_hdr_rec.book_type_code,
                p_security_context             => l_security_context);

            --6702657
            BEGIN
              l_result := XLA_EVENTS_PUB_PKG.delete_entity
                       (p_source_info       => l_deprn_source_info,
                        p_valuation_method  => p_asset_hdr_rec.book_type_code,
                        p_security_context  => l_security_context);

            EXCEPTION
              WHEN OTHERS THEN
                l_result := 1;
                fa_debug_pkg.add(l_calling_fn, 'Unable to delete entity for rb event',
                       l_event_id, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, 'l_result', l_result, p_log_level_rec => p_log_level_rec);
            END; --annonymous
         end if;
         -- Rollback Terminal Gain Loss
         if (p_mrc_sob_type_code <> 'R') then
            delete from fa_transaction_headers
            where  transaction_header_id = l_thid;

            delete from fa_adjustments
            where asset_id = p_asset_hdr_rec.asset_id
            and   book_type_code = p_asset_hdr_rec.book_type_code
            and   transaction_header_id = l_thid;

            delete from fa_books
            where asset_id = p_asset_hdr_rec.asset_id
            and   book_type_code = p_asset_hdr_rec.book_type_code
            and   transaction_header_id_in = l_thid;

            update fa_books
            set    transaction_header_id_out = null,
                   date_ineffective = null
            where asset_id = p_asset_hdr_rec.asset_id
            and   book_type_code = p_asset_hdr_rec.book_type_code
            and   transaction_header_id_out = l_thid;

         else

            delete from fa_mc_adjustments
            where asset_id = p_asset_hdr_rec.asset_id
            and   book_type_code = p_asset_hdr_rec.book_type_code
            and   transaction_header_id = g_l_thid
            and   set_of_books_id = p_asset_hdr_rec.set_of_books_id ;

            delete from fa_mc_books
            where asset_id = p_asset_hdr_rec.asset_id
            and   book_type_code = p_asset_hdr_rec.book_type_code
            and   transaction_header_id_in = g_l_thid
            and   set_of_books_id = p_asset_hdr_rec.set_of_books_id ;

            update fa_mc_books
            set    transaction_header_id_out = null,
                   date_ineffective = null
            where asset_id = p_asset_hdr_rec.asset_id
            and   book_type_code = p_asset_hdr_rec.book_type_code
            and   transaction_header_id_out = g_l_thid
            and   set_of_books_id = p_asset_hdr_rec.set_of_books_id ;

         end if; -- (p_mrc_sob_type_code <> 'R')

      else
         raise rb_error;
      end if; -- (l_event_status = XLA_EVENTS_PUB_PKG.C_EVENT_PROCESSED)

      -- Common for both situations (reverse, delete)
      if (p_mrc_sob_type_code <> 'R') then
         update fa_books_summary
         set    terminal_gain_loss_flag = 'Y',
                terminal_gain_loss_amount = null,
                reserve_adjustment_amount = reserve_adjustment_amount - terminal_gain_loss_amount,
                deprn_reserve = deprn_reserve - terminal_gain_loss_amount,
                last_update_date = l_trans_rec.who_info.last_update_date,
                last_update_login = l_trans_rec.who_info.last_update_login,
                last_updated_by = l_trans_rec.who_info.last_updated_by
         where  book_type_code = p_asset_hdr_rec.book_type_code
         and    asset_id = p_asset_hdr_rec.asset_id
         and    period_counter = p_period_rec.period_counter;
      else
         update fa_mc_books_summary
         set    terminal_gain_loss_flag = 'Y',
                terminal_gain_loss_amount = null,
                reserve_adjustment_amount = reserve_adjustment_amount - terminal_gain_loss_amount,
                deprn_reserve = deprn_reserve - terminal_gain_loss_amount,
                last_update_date = l_trans_rec.who_info.last_update_date,
                last_update_login = l_trans_rec.who_info.last_update_login,
                last_updated_by = l_trans_rec.who_info.last_updated_by
         where  book_type_code = p_asset_hdr_rec.book_type_code
         and    asset_id = p_asset_hdr_rec.asset_id
         and    period_counter = p_period_rec.period_counter
         and    set_of_books_id = p_asset_hdr_rec.set_of_books_id;
      end if;

   end if; -- l_thid is not null)

   -- End of terminal gain loss

    -- Bug:6665510:Japan Tax Reform Project
    if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add('FAVDRBB', 'guarantee_flag', fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag);
        fa_debug_pkg.add('FAVDRBB', 'period_num', p_period_rec.period_num);
        fa_debug_pkg.add('FAVDRBB', 'pers_per_yr', pers_per_yr);
    end if;

    if ((p_period_rec.period_num - pers_per_yr) = 0) and
       (nvl(fnd_profile.value('FA_JAPAN_TAX_REFORMS'),'N') = 'Y') then

       if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add('Updating rate_in_use', 'EOFY', 'YES');
       end if;

       if (p_mrc_sob_type_code = 'R') then
          Null;
       else
          open c_rate_in_use;
       end if;

       loop
          if (p_mrc_sob_type_code = 'R') then
              exit; -- Bug 9012515
          else

              fetch c_rate_in_use bulk collect
              into  l_bks_rowid_tbl2,
                    l_asset_id_tbl2,
                    l_method_code_tbl2,
                    l_life_in_months_tbl2
              LIMIT l_batch_size;

              l_rows_processed := l_bks_rowid_tbl2.count;

              if l_rows_processed = 0 then
                 exit;
              end if;

              if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add('FAVDRBB', 'l_bks_rowid_tbl2.count', l_bks_rowid_tbl2.count);
              end if;

              for i in 1..l_bks_rowid_tbl2.count loop

                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add('FAVDRBB', 'l_asset_id_tbl2(i)', l_asset_id_tbl2(i));
                     fa_debug_pkg.add('FAVDRBB', 'l_method_code_tbl2(i)', l_method_code_tbl2(i));
                  end if;

                  FA_CDE_PKG.faxgfr (X_Book_Type_Code => p_asset_hdr_rec.book_type_code,
                           X_Asset_Id               => l_asset_id_tbl2(i),
                           X_Short_Fiscal_Year_Flag => NULL,
                           X_Conversion_Date        => NULL,
                           X_Prorate_Date           => NULL,
                           X_Orig_Deprn_Start_Date  => NULL,
                           C_Prorate_Date           => NULL,
                           C_Conversion_Date        => NULL,
                           C_Orig_Deprn_Start_Date  => NULL,
                           X_Method_Code            => l_method_code_tbl2(i),
                           X_Life_In_Months         => l_life_in_months_tbl2(i),
                           X_Fiscal_Year            => -99,
                           X_Current_Period         => -99,
                           X_calling_interface      => 'ROLLBACK_DEPRN',
                           X_Rate                   => l_rate_in_use_tbl(i),
                           X_Method_Type            => l_method_type,
                           X_Success                => l_success);

                  if (l_success <= 0) then
                      fa_srvr_msg.add_message(calling_fn => 'FA_DEPRN_ROLLBACK_PKG.do_rollback');
                      raise rb_error;
                  end if;
              end loop;

              fa_debug_pkg.add('FAVDRBB', 'update fa_books.rate_in_use', l_bks_rowid_tbl2.count);

              forall i IN 1..l_bks_rowid_tbl2.count
              update fa_books
              set rate_in_use = l_rate_in_use_tbl(i)
              where rowid = l_bks_rowid_tbl2(i);
           end if;
       end loop;

       if (p_mrc_sob_type_code = 'R') then
           Null;
       else
           close c_rate_in_use;
       end if;
    end if;
    -- Bug:6665510:Japan Tax Reform Project (End)

   -- updates to adj_req_status should be obseolete at this point
   -- since deprn will not catchup

   -- BUG# 2238090
   -- reset the periodic production amounts for primary only
   --    bridgway  02/25/02

   if (p_mrc_sob_type_code <> 'R') then

      update fa_periodic_production pp
         set used_flag          = 'NO'
       where pp.asset_id        = p_asset_hdr_rec.asset_id
         and pp.book_type_code  = p_asset_hdr_rec.book_type_code
         and pp.start_date     >= p_period_rec.calendar_period_open_date
         and pp.end_date       <= p_period_rec.calendar_period_close_date;

      -- Manual Override

      fa_std_types.deprn_override_trigger_enabled:= FALSE;

      update FA_DEPRN_OVERRIDE do
         set status            = 'POST'
       where do.asset_id       = p_asset_hdr_rec.asset_id
         and do.book_type_code = p_asset_hdr_rec.book_type_code
         and do.period_name    = p_period_rec.period_name
         and do.used_by        = 'DEPRECIATION'
         and do.status         = 'POSTED';

      fa_std_types.deprn_override_trigger_enabled:= TRUE;

      -- End of Manual Override

   end if;


   return TRUE;

EXCEPTION
    when rb_error then
         fa_srvr_msg.add_message(calling_fn => l_calling_fn
                  ,p_log_level_rec => p_log_level_rec);
         return FALSE;

    when others then
         fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                  ,p_log_level_rec => p_log_level_rec);
         return FALSE;

end do_rollback;

END FA_DEPRN_ROLLBACK_PVT;

/
