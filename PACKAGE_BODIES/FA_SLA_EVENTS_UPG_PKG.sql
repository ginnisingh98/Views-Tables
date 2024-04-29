--------------------------------------------------------
--  DDL for Package Body FA_SLA_EVENTS_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_SLA_EVENTS_UPG_PKG" as
/* $Header: FAEVUPGB.pls 120.78.12010000.8 2010/03/15 08:59:24 gigupta ship $   */

Procedure Upgrade_Inv_Events (
             p_start_rowid             IN            rowid,
             p_end_rowid               IN            rowid,
             p_batch_size              IN            number,
             x_success_count              OUT NOCOPY number,
             x_failure_count              OUT NOCOPY number,
             x_return_status              OUT NOCOPY number
            ) IS

   c_application_id        constant number(15) := 140;
   c_upgrade_bugno         constant number(15) := -4107161;
   c_fnd_user              constant number(15) := 2;

   c_entity_code           constant varchar2(30) := 'INTER_ASSET_TRANSACTIONS';
   c_amb_context_code      constant varchar2(30) := 'DEFAULT';

   -- this value can be altered in order to process more of less per batch
   l_batch_size             NUMBER;

   l_rows_processed         NUMBER;

   -- type for table variable
   type num_tbl_type  is table of number        index by binary_integer;
   type char_tbl_type is table of varchar2(150) index by binary_integer;
   type date_tbl_type is table of date          index by binary_integer;
   type rowid_tbl_type is table of rowid        index by binary_integer;

   -- used for bulk fetching
   -- main cursor
   l_event_id_tbl                               num_tbl_type;
   l_src_asset_id_tbl                           num_tbl_type;
   l_dest_asset_id_tbl                          num_tbl_type;
   l_book_type_code_tbl                         char_tbl_type;
   l_primary_set_of_books_id_tbl                num_tbl_type;
   l_org_id_tbl                                 num_tbl_type;
   l_src_trans_type_code_tbl                    char_tbl_type;
   l_dest_trans_type_code_tbl                   char_tbl_type;
   l_transaction_date_entered_tbl               date_tbl_type;
   l_src_thid_tbl                               num_tbl_type;
   l_dest_thid_tbl                              num_tbl_type;
   l_period_counter_tbl                         num_tbl_type;
   l_period_name_tbl                            char_tbl_type;
   l_cal_period_close_date_tbl                  date_tbl_type;
   l_src_rowid_tbl                              rowid_tbl_type;
   l_dest_rowid_tbl                             rowid_tbl_type;
   l_tr_rowid_tbl                               rowid_tbl_type;
   l_trx_reference_id_tbl                       num_tbl_type;
   l_src_hdr_desc_tbl                           char_tbl_type;
   l_dest_hdr_desc_tbl                          char_tbl_type;
   l_date_effective_tbl                         date_tbl_type;

   l_upg_batch_id                               number;
   l_ae_header_id                               number;

   l_entity_id_tbl                              num_tbl_type;
   l_event_class_code_tbl                       char_tbl_type;
   l_rep_set_of_books_id_tbl                    num_tbl_type;
   l_currency_code_tbl                          char_tbl_type;
   l_je_category_name_tbl                       char_tbl_type;

   l_adj_thid_tbl                               num_tbl_type;
   l_adj_line_id_tbl                            num_tbl_type;
   l_xla_gl_sl_link_id_tbl                      num_tbl_type;
   l_ae_line_num_tbl                            num_tbl_type;
   l_debit_amount_tbl                           num_tbl_type;
   l_credit_amount_tbl                          num_tbl_type;
   l_ccid_tbl                                   num_tbl_type;
   l_acct_class_code_tbl                        char_tbl_type;
   l_line_def_owner_code_tbl                    char_tbl_type;
   l_line_def_code_tbl                          char_tbl_type;
   l_line_desc_tbl                              char_tbl_type;
   l_gl_transfer_status_code_tbl                char_tbl_type;
   l_je_batch_id_tbl                            num_tbl_type;
   l_je_header_id_tbl                           num_tbl_type;
   l_je_line_num_tbl                            num_tbl_type;
   l_distribution_id_tbl                        num_tbl_type;
   l_line_num_tbl                               num_tbl_type; -- Bug 6827893
   l_ae_header_id_tbl                           num_tbl_type; -- Bug 6827893

   l_error_level_tbl                            char_tbl_type;
   l_err_entity_id_tbl                          num_tbl_type;
   l_err_event_id_tbl                           num_tbl_type;
   l_err_ae_header_id_tbl                       num_tbl_type;
   l_err_ae_line_num_tbl                        num_tbl_type;
   l_err_temp_line_num_tbl                      num_tbl_type;
   l_error_message_name_tbl                     char_tbl_type;

   CURSOR c_trans IS
      select /*+ leading(tr) rowid(tr) */
             xla_events_s.nextval,
             th1.asset_id,
             th2.asset_id,
             tr.book_type_code,
             bc.set_of_books_id,
             bc.org_id,
             th1.transaction_type_code,
             th2.transaction_type_code,
             th1.transaction_date_entered,
             th1.transaction_header_id,
             th2.transaction_header_id,
             th1.rowid,
             th2.rowid,
             tr.rowid,
             xla_transaction_entities_s.nextval,
             decode(tr.transaction_type,
               'RESERVE TRANSFER', 'RESERVE_TRANSFERS',
               'INVOICE TRANSFER',
                        decode (th1.transaction_type_code,
                                'CIP ADJUSTMENT',
                                     decode (th2.transaction_type_code,
                                          'CIP ADJUSTMENT',
                                               'CIP_SOURCE_LINE_TRANSFERS',
                                               'SOURCE_LINE_TRANSFERS'),
                                'SOURCE_LINE_TRANSFERS'),
                'OTHER'
             ) event_class_code,
             dp.period_name,
             dp.period_counter,
             dp.calendar_period_close_date,
             tr.trx_reference_id,
             lk1.description || ' - ' ||
                to_char(dp.calendar_period_close_date, 'DD-MON-RR'),
             lk2.description || ' - ' ||
                to_char(dp.calendar_period_close_date, 'DD-MON-RR'),
             nvl (decode(tr.transaction_type,
               'RESERVE TRANSFER', bc.je_adjustment_category,
               'INVOICE TRANSFER',
                        decode (th1.transaction_type_code,
                                'CIP ADJUSTMENT',
                                     decode (th2.transaction_type_code,
                                          'CIP ADJUSTMENT',
                                               bc.je_cip_adjustment_category,
                                               bc.je_adjustment_category),
                                bc.je_adjustment_category),
                bc.je_adjustment_category
             ), 'OTHER') je_category_name,
             th1.date_effective
      from   fa_transaction_headers th1,
             fa_transaction_headers th2,
             fa_book_controls bc,
             fa_deprn_periods dp,
             fa_trx_references tr,
             fa_lookups_tl lk1,
             fa_lookups_tl lk2,
             gl_period_statuses ps
      where  tr.rowid between p_start_rowid and p_end_rowid
      and    ps.application_id = 101
      and    ((ps.migration_status_code in ('P', 'U')) or
              (dp.period_close_date is null))
      and    substr(dp.xla_conversion_status, 1, 1) in
             ('H', 'U', 'E', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
      and    dp.xla_conversion_status not in ('UT', 'UA')
      and    ps.set_of_books_id = bc.set_of_books_id
      and    ps.period_name = dp.period_name
      and    tr.transaction_type in ('INVOICE TRANSFER', 'RESERVE TRANSFER')
      and    tr.book_type_code = th1.book_type_code
      and    tr.src_asset_id = th1.asset_id
      and    tr.src_transaction_header_id = th1.transaction_header_id
      and    tr.book_type_code = th2.book_type_code
      and    tr.dest_asset_id = th2.asset_id
      and    tr.dest_transaction_header_id = th2.transaction_header_id
      and    tr.book_type_code = bc.book_type_code
      and    bc.book_type_code = dp.book_type_code
      and    th1.date_effective between
                dp.period_open_date and nvl(dp.period_close_date, sysdate)
      and    th1.member_transaction_header_id is null
      and    th1.event_id is null
      and    th1.transaction_type_code = lk1.lookup_code
      and    lk1.lookup_type = 'FAXOLTRX'
      and    th2.transaction_type_code = lk2.lookup_code
      and    lk2.lookup_type = 'FAXOLTRX'
      and    userenv('LANG') = lk1.language
      and    userenv('LANG') = lk2.language
      and exists
      (
       select 'x'
       from   fa_adjustments adj
       where  th1.transaction_header_id = adj.transaction_header_id
       and    th1.book_type_code = adj.book_type_code
       and    th1.asset_id = adj.asset_id
      )
      and    th2.date_effective between
                dp.period_open_date and nvl(dp.period_close_date, sysdate)
      and    th2.member_transaction_header_id is null
      and    th2.event_id is null
      and exists
      (
       select 'x'
       from   fa_adjustments adj
       where  th2.transaction_header_id = adj.transaction_header_id
       and    th2.book_type_code = adj.book_type_code
       and    th2.asset_id = adj.asset_id
      );

   -- Bug 6827893 : Added outerjoin between DD and gljh
   --               Corrected the Reserve row (second union)
   CURSOR c_adj (l_book_type_code        varchar2,
                 l_asset_id              number,
                 l_transaction_header_id number,
                 l_date_effective        date) IS
      select adj.transaction_header_id,
             adj.adjustment_line_id,
             decode (adj.debit_credit_flag,
                     'DR', adj.adjustment_amount, null),
             decode (adj.debit_credit_flag,
                     'CR', adj.adjustment_amount, null),
             adj.code_combination_id,
             glsob.currency_code,
             decode (adj.adjustment_type,
                'BONUS EXPENSE', 'EXPENSE',
                'BONUS RESERVE', 'ASSET',
                'CIP COST', 'ASSET',
                'COST', 'ASSET',
                'COST CLEARING', 'ASSET',
                'DEPRN ADJUST', 'EXPENSE',
                'EXPENSE', 'EXPENSE',
                'GRP COR RESERVE', 'ASSET',
                'GRP PRC RESERVE', 'ASSET',
                'INTERCO AP', 'LIABILITY',
                'INTERCO AR', 'ASSET',
                'NBV RETIRED', 'ASSET',
                'PROCEEDS', 'ASSET',
                'PROCEEDS CLR', 'ASSET',
                'REMOVALCOST', 'ASSET',
                'REMOVALCOST CLR', 'ASSET',
                'RESERVE', 'ASSET',
                'REVAL RESERVE', 'ASSET',
                'REVAL RSV RET', 'ASSET',
                'REVAL AMORT', 'EXPENSE',
                'REVAL EXPENSE', 'EXPENSE',
                'ASSET'),
             lk.description,
             decode (gljh.je_header_id, null, 'N', 'Y'),
             gljh.je_batch_id,
             adj.je_header_id,
             nvl(adj.je_line_num, 0),
             adj.distribution_id
      from   fa_adjustments adj,
             gl_sets_of_books glsob,
             fa_book_controls bc,
             fa_lookups_tl lk,
             gl_je_headers gljh
      where  bc.book_type_code = l_book_type_code
      and    bc.set_of_books_id = glsob.set_of_books_id
      and    bc.book_type_code = adj.book_type_code
      and    adj.asset_id = l_asset_id
      and    adj.transaction_header_id = l_transaction_header_id
      and    adj.code_combination_id is not null
      and    nvl(adj.track_member_flag, 'N') = 'N'
      and    lk.lookup_type = 'JOURNAL ENTRIES'
      and    lk.lookup_code = decode (adj.adjustment_type,
                              'BONUS EXPENSE', 'BONUS DEPRECIATION EXPENSE',
                              'BONUS RESERVE', 'BONUS DEPRECIATION RESERVE',
                              'CIP COST', adj.source_type_code ||' COST',
                              adj.source_type_code ||' '|| adj.adjustment_type)
      and    userenv('LANG') = lk.language
      and    adj.je_header_id = gljh.je_header_id (+)
   UNION ALL
      select adj.transaction_header_id,
             adj.adjustment_line_id,
             decode (adj.debit_credit_flag,
                     'CR', adj.adjustment_amount, null),
             decode (adj.debit_credit_flag,
                     'DR', adj.adjustment_amount, null),
             nvl(nvl(gljl.code_combination_id, da.deprn_reserve_account_ccid),
                 cb.reserve_account_ccid),
             glsob.currency_code,
             decode (adj.adjustment_type,
                'BONUS EXPENSE', 'EXPENSE',
                'BONUS RESERVE', 'ASSET',
                'CIP COST', 'ASSET',
                'COST', 'ASSET',
                'COST CLEARING', 'ASSET',
                'DEPRN ADJUST', 'EXPENSE',
                'EXPENSE', 'ASSET',
                'GRP COR RESERVE', 'ASSET',
                'GRP PRC RESERVE', 'ASSET',
                'INTERCO AP', 'LIABILITY',
                'INTERCO AR', 'ASSET',
                'NBV RETIRED', 'ASSET',
                'PROCEEDS', 'ASSET',
                'PROCEEDS CLR', 'ASSET',
                'REMOVALCOST', 'ASSET',
                'REMOVALCOST CLR', 'ASSET',
                'RESERVE', 'ASSET',
                'REVAL RESERVE', 'ASSET',
                'REVAL RSV RET', 'ASSET',
                'REVAL AMORT', 'EXPENSE',
                'REVAL EXPENSE', 'EXPENSE',
                'ASSET'),
             lk.description,
             decode (gljh.je_header_id, null, 'N', 'Y'),
             gljh.je_batch_id,
             dd.je_header_id,
             nvl(dd.deprn_reserve_je_line_num, 0),
             adj.distribution_id
      from   fa_adjustments adj,
             gl_sets_of_books glsob,
             fa_book_controls bc,
             fa_lookups_tl lk,
             gl_je_headers gljh,
             fa_deprn_detail dd,
             gl_je_lines gljl,
             fa_distribution_accounts da,
             fa_asset_history ah,
             fa_category_books cb
      where  bc.book_type_code = l_book_type_code
      and    bc.set_of_books_id = glsob.set_of_books_id
      and    bc.book_type_code = adj.book_type_code
      and    adj.asset_id = l_asset_id
      and    adj.transaction_header_id = l_transaction_header_id
      and    adj.adjustment_type = 'EXPENSE'
      and    adj.source_type_code in ('DEPRECIATION', 'CIP RETIREMENT',
                                      'RETIREMENT')
      and    adj.code_combination_id is not null
      and    nvl(adj.track_member_flag, 'N') = 'N'
      and    lk.lookup_type = 'JOURNAL ENTRIES'
      and    lk.lookup_code = adj.source_type_code ||' RESERVE'
      and    userenv('LANG') = lk.language
      and    adj.asset_id = dd.asset_id (+)
      and    adj.book_type_code = dd.book_type_code (+)
      and    adj.distribution_id = dd.distribution_id (+)
      and    adj.period_counter_created = dd.period_counter (+)
      and    dd.je_header_id = gljl.je_header_id (+)
      and    dd.deprn_reserve_je_line_num = gljl.je_line_num (+)
      and    dd.je_header_id = gljh.je_header_id (+)
      and    adj.book_type_code = da.book_type_code (+)
      and    adj.distribution_id = da.distribution_id (+)
      and    adj.asset_id = ah.asset_id
      and    l_date_effective >= ah.date_effective
      and    l_date_effective < nvl(ah.date_ineffective, sysdate+1)
      and    ah.category_id = cb.category_id
      and    bc.book_type_code = cb.book_type_code
   UNION ALL
      select adj.transaction_header_id,
             adj.adjustment_line_id,
             decode (adj.debit_credit_flag,
                     'DR', adj.adjustment_amount, null),
             decode (adj.debit_credit_flag,
                     'CR', adj.adjustment_amount, null),
             nvl(nvl(gljl.code_combination_id, da.deprn_reserve_account_ccid),
                 cb.reserve_account_ccid),
             glsob.currency_code,
             decode (adj.adjustment_type,
                'BONUS EXPENSE', 'EXPENSE',
                'BONUS RESERVE', 'ASSET',
                'CIP COST', 'ASSET',
                'COST', 'ASSET',
                'COST CLEARING', 'ASSET',
                'DEPRN ADJUST', 'EXPENSE',
                'EXPENSE', 'EXPENSE',
                'GRP COR RESERVE', 'ASSET',
                'GRP PRC RESERVE', 'ASSET',
                'INTERCO AP', 'LIABILITY',
                'INTERCO AR', 'ASSET',
                'NBV RETIRED', 'ASSET',
                'PROCEEDS', 'ASSET',
                'PROCEEDS CLR', 'ASSET',
                'REMOVALCOST', 'ASSET',
                'REMOVALCOST CLR', 'ASSET',
                'RESERVE', 'ASSET',
                'REVAL RESERVE', 'ASSET',
                'REVAL RSV RET', 'ASSET',
                'REVAL AMORT', 'EXPENSE',
                'REVAL EXPENSE', 'EXPENSE',
                'ASSET'),
             lk.description,
             decode (gljh.je_header_id, null, 'N', 'Y'),
             gljh.je_batch_id,
             dd.je_header_id,
             nvl(dd.deprn_reserve_je_line_num, 0),
             adj.distribution_id
      from   fa_adjustments adj,
             gl_sets_of_books glsob,
             fa_book_controls bc,
             fa_lookups_tl lk,
             gl_je_headers gljh,
             fa_deprn_detail dd,
             gl_je_lines gljl,
             fa_distribution_accounts da,
             fa_asset_history ah,
             fa_category_books cb
      where  bc.book_type_code = l_book_type_code
      and    bc.set_of_books_id = glsob.set_of_books_id
      and    bc.book_type_code = adj.book_type_code
      and    adj.asset_id = l_asset_id
      and    adj.transaction_header_id = l_transaction_header_id
      and    adj.adjustment_type = 'BONUS EXPENSE'
      and    adj.source_type_code = 'DEPRECIATION'
      and    adj.code_combination_id is not null
      and    nvl(adj.track_member_flag, 'N') = 'N'
      and    lk.lookup_type = 'JOURNAL ENTRIES'
      and    lk.lookup_code = 'BONUS DEPRECIATION RESERVE'
      and    userenv('LANG') = lk.language
      and    adj.asset_id = dd.asset_id (+)
      and    adj.book_type_code = dd.book_type_code (+)
      and    adj.distribution_id = dd.distribution_id (+)
      and    adj.period_counter_created = dd.period_counter (+)
      and    dd.je_header_id = gljl.je_header_id (+)
      and    dd.bonus_deprn_rsv_je_line_num = gljl.je_line_num (+)
      and    dd.je_header_id = gljh.je_header_id (+)
      and    adj.book_type_code = da.book_type_code (+)
      and    adj.distribution_id = da.distribution_id (+)
      and    adj.asset_id = ah.asset_id
      and    l_date_effective >= ah.date_effective
      and    l_date_effective < nvl(ah.date_ineffective, sysdate+1)
      and    ah.category_id = cb.category_id
      and    bc.book_type_code = cb.book_type_code;

   CURSOR c_mc_books (l_book_type_code      varchar2) IS
   select set_of_books_id
     from fa_mc_book_controls
    where book_type_code = l_book_type_code
      and enabled_flag = 'Y';

   -- Bug 6827893 : Added outerjoin between DD and gljh
   --               Corrected the Reserve row (second union)
   CURSOR c_mc_adj (l_book_type_code        varchar2,
                    l_asset_id              number,
                    l_set_of_books_id       number,
                    l_transaction_header_id number,
                    l_date_effective        date) IS
      select adj.transaction_header_id,
             adj.adjustment_line_id,
             decode (adj.debit_credit_flag,
                     'DR', adj.adjustment_amount, null),
             decode (adj.debit_credit_flag,
                     'CR', adj.adjustment_amount, null),
             adj.code_combination_id,
             glsob.currency_code,
             decode (adj.adjustment_type,
                'BONUS EXPENSE', 'EXPENSE',
                'BONUS RESERVE', 'ASSET',
                'CIP COST', 'ASSET',
                'COST', 'ASSET',
                'COST CLEARING', 'ASSET',
                'DEPRN ADJUST', 'EXPENSE',
                'EXPENSE', 'EXPENSE',
                'GRP COR RESERVE', 'ASSET',
                'GRP PRC RESERVE', 'ASSET',
                'INTERCO AP', 'LIABILITY',
                'INTERCO AR', 'ASSET',
                'NBV RETIRED', 'ASSET',
                'PROCEEDS', 'ASSET',
                'PROCEEDS CLR', 'ASSET',
                'REMOVALCOST', 'ASSET',
                'REMOVALCOST CLR', 'ASSET',
                'RESERVE', 'ASSET',
                'REVAL RESERVE', 'ASSET',
                'REVAL RSV RET', 'ASSET',
                'REVAL AMORT', 'EXPENSE',
                'REVAL EXPENSE', 'EXPENSE',
                'ASSET'),
             lk.description,
             decode (gljh.je_header_id, null, 'N', 'Y'),
             gljh.je_batch_id,
             adj.je_header_id,
             nvl(adj.je_line_num, 0),
             adj.distribution_id
      from   fa_mc_adjustments adj,
             gl_sets_of_books glsob,
             fa_mc_book_controls bc,
             fa_lookups_tl lk,
             gl_je_headers gljh
      where  bc.book_type_code = l_book_type_code
      and    bc.set_of_books_id = l_set_of_books_id
      and    bc.enabled_flag = 'Y'
      and    bc.set_of_books_id = glsob.set_of_books_id
      and    bc.book_type_code = adj.book_type_code
      and    bc.set_of_books_id = adj.set_of_books_id
      and    adj.asset_id = l_asset_id
      and    adj.transaction_header_id = l_transaction_header_id
      and    adj.code_combination_id is not null
      and    nvl(adj.track_member_flag, 'N') = 'N'
      and    lk.lookup_type = 'JOURNAL ENTRIES'
      and    lk.lookup_code = decode (adj.adjustment_type,
                              'BONUS EXPENSE', 'BONUS DEPRECIATION EXPENSE',
                              'BONUS RESERVE', 'BONUS DEPRECIATION RESERVE',
                              'CIP COST', adj.source_type_code ||' COST',
                              adj.source_type_code ||' '|| adj.adjustment_type)
      and    userenv('LANG') = lk.language
      and    adj.je_header_id = gljh.je_header_id (+)
   UNION ALL
      select adj.transaction_header_id,
             adj.adjustment_line_id,
             decode (adj.debit_credit_flag,
                     'CR', adj.adjustment_amount, null),
             decode (adj.debit_credit_flag,
                     'DR', adj.adjustment_amount, null),
             nvl(nvl(gljl.code_combination_id, da.deprn_reserve_account_ccid),
                 cb.reserve_account_ccid),
             glsob.currency_code,
             decode (adj.adjustment_type,
                'BONUS EXPENSE', 'EXPENSE',
                'BONUS RESERVE', 'ASSET',
                'CIP COST', 'ASSET',
                'COST', 'ASSET',
                'COST CLEARING', 'ASSET',
                'DEPRN ADJUST', 'EXPENSE',
                'EXPENSE', 'ASSET',
                'GRP COR RESERVE', 'ASSET',
                'GRP PRC RESERVE', 'ASSET',
                'INTERCO AP', 'LIABILITY',
                'INTERCO AR', 'ASSET',
                'NBV RETIRED', 'ASSET',
                'PROCEEDS', 'ASSET',
                'PROCEEDS CLR', 'ASSET',
                'REMOVALCOST', 'ASSET',
                'REMOVALCOST CLR', 'ASSET',
                'RESERVE', 'ASSET',
                'REVAL RESERVE', 'ASSET',
                'REVAL RSV RET', 'ASSET',
                'REVAL AMORT', 'EXPENSE',
                'REVAL EXPENSE', 'EXPENSE',
                'ASSET'),
             lk.description,
             decode (gljh.je_header_id, null, 'N', 'Y'),
             gljh.je_batch_id,
             dd.je_header_id,
             nvl(dd.deprn_reserve_je_line_num, 0),
             adj.distribution_id
      from   fa_mc_adjustments adj,
             gl_sets_of_books glsob,
             fa_mc_book_controls bc,
             fa_lookups_tl lk,
             gl_je_headers gljh,
             fa_mc_deprn_detail dd,
             gl_je_lines gljl,
             fa_distribution_accounts da,
             fa_asset_history ah,
             fa_category_books cb
      where  bc.book_type_code = l_book_type_code
      and    bc.set_of_books_id = l_set_of_books_id
      and    bc.enabled_flag = 'Y'
      and    bc.set_of_books_id = glsob.set_of_books_id
      and    bc.book_type_code = adj.book_type_code
      and    bc.set_of_books_id = adj.set_of_books_id
      and    adj.asset_id = l_asset_id
      and    adj.transaction_header_id = l_transaction_header_id
      and    adj.adjustment_type = 'EXPENSE'
      and    adj.source_type_code in ('DEPRECIATION', 'CIP RETIREMENT',
                                      'RETIREMENT')
      and    adj.code_combination_id is not null
      and    nvl(adj.track_member_flag, 'N') = 'N'
      and    lk.lookup_type = 'JOURNAL ENTRIES'
      and    lk.lookup_code = adj.source_type_code ||' RESERVE'
      and    userenv('LANG') = lk.language
      and    adj.asset_id = dd.asset_id (+)
      and    adj.book_type_code = dd.book_type_code (+)
      and    adj.set_of_books_id = dd.set_of_books_id (+)
      and    adj.distribution_id = dd.distribution_id (+)
      and    adj.period_counter_created = dd.period_counter (+)
      and    dd.je_header_id = gljl.je_header_id (+)
      and    dd.deprn_reserve_je_line_num = gljl.je_line_num (+)
      and    dd.je_header_id = gljh.je_header_id (+)
      and    adj.book_type_code = da.book_type_code (+)
      and    adj.distribution_id = da.distribution_id (+)
      and    adj.asset_id = ah.asset_id
      and    l_date_effective >= ah.date_effective
      and    l_date_effective < nvl(ah.date_ineffective, sysdate+1)
      and    ah.category_id = cb.category_id
      and    bc.book_type_code = cb.book_type_code
   UNION ALL
      select adj.transaction_header_id,
             adj.adjustment_line_id,
             decode (adj.debit_credit_flag,
                     'DR', adj.adjustment_amount, null),
             decode (adj.debit_credit_flag,
                     'CR', adj.adjustment_amount, null),
             nvl(nvl(gljl.code_combination_id, da.deprn_reserve_account_ccid),
                 cb.reserve_account_ccid),
             glsob.currency_code,
             decode (adj.adjustment_type,
                'BONUS EXPENSE', 'EXPENSE',
                'BONUS RESERVE', 'ASSET',
                'CIP COST', 'ASSET',
                'COST', 'ASSET',
                'COST CLEARING', 'ASSET',
                'DEPRN ADJUST', 'EXPENSE',
                'EXPENSE', 'EXPENSE',
                'GRP COR RESERVE', 'ASSET',
                'GRP PRC RESERVE', 'ASSET',
                'INTERCO AP', 'LIABILITY',
                'INTERCO AR', 'ASSET',
                'NBV RETIRED', 'ASSET',
                'PROCEEDS', 'ASSET',
                'PROCEEDS CLR', 'ASSET',
                'REMOVALCOST', 'ASSET',
                'REMOVALCOST CLR', 'ASSET',
                'RESERVE', 'ASSET',
                'REVAL RESERVE', 'ASSET',
                'REVAL RSV RET', 'ASSET',
                'REVAL AMORT', 'EXPENSE',
                'REVAL EXPENSE', 'EXPENSE',
                'ASSET'),
             lk.description,
             decode (gljh.je_header_id, null, 'N', 'Y'),
             gljh.je_batch_id,
             dd.je_header_id,
             nvl(dd.deprn_reserve_je_line_num, 0),
             adj.distribution_id
      from   fa_mc_adjustments adj,
             gl_sets_of_books glsob,
             fa_mc_book_controls bc,
             fa_lookups_tl lk,
             gl_je_headers gljh,
             fa_mc_deprn_detail dd,
             gl_je_lines gljl,
             fa_distribution_accounts da,
             fa_asset_history ah,
             fa_category_books cb
      where  bc.book_type_code = l_book_type_code
      and    bc.set_of_books_id = l_set_of_books_id
      and    bc.enabled_flag = 'Y'
      and    bc.set_of_books_id = glsob.set_of_books_id
      and    bc.book_type_code = adj.book_type_code
      and    bc.set_of_books_id = adj.set_of_books_id
      and    adj.asset_id = l_asset_id
      and    adj.transaction_header_id = l_transaction_header_id
      and    adj.adjustment_type = 'BONUS EXPENSE'
      and    adj.source_type_code = 'DEPRECIATION'
      and    adj.code_combination_id is not null
      and    nvl(adj.track_member_flag, 'N') = 'N'
      and    lk.lookup_type = 'JOURNAL ENTRIES'
      and    lk.lookup_code = 'BONUS DEPRECIATION RESERVE'
      and    userenv('LANG') = lk.language
      and    adj.asset_id = dd.asset_id (+)
      and    adj.book_type_code = dd.book_type_code (+)
      and    adj.set_of_books_id = dd.set_of_books_id (+)
      and    adj.distribution_id = dd.distribution_id (+)
      and    adj.period_counter_created = dd.period_counter (+)
      and    dd.je_header_id = gljl.je_header_id (+)
      and    dd.bonus_deprn_rsv_je_line_num = gljl.je_line_num (+)
      and    dd.je_header_id = gljh.je_header_id (+)
      and    adj.book_type_code = da.book_type_code (+)
      and    adj.distribution_id = da.distribution_id (+)
      and    adj.asset_id = ah.asset_id
      and    l_date_effective >= ah.date_effective
      and    l_date_effective < nvl(ah.date_ineffective, sysdate+1)
      and    ah.category_id = cb.category_id
      and    bc.book_type_code = cb.book_type_code;

BEGIN

   x_success_count := 0;
   x_failure_count := 0;

   l_batch_size := nvl(nvl(p_batch_size, fa_cache_pkg.fa_batch_size), 1000);

   open c_trans;
   loop

         fetch c_trans bulk collect
          into l_event_id_tbl,
               l_src_asset_id_tbl,
               l_dest_asset_id_tbl,
               l_book_type_code_tbl,
               l_primary_set_of_books_id_tbl,
               l_org_id_tbl,
               l_src_trans_type_code_tbl,
               l_dest_trans_type_code_tbl,
               l_transaction_date_entered_tbl,
               l_src_thid_tbl,
               l_dest_thid_tbl,
               l_src_rowid_tbl,
               l_dest_rowid_tbl,
               l_tr_rowid_tbl,
               l_entity_id_tbl,
               l_event_class_code_tbl,
               l_period_name_tbl,
               l_period_counter_tbl,
               l_cal_period_close_date_tbl,
               l_trx_reference_id_tbl,
               l_src_hdr_desc_tbl,
               l_dest_hdr_desc_tbl,
               l_je_category_name_tbl,
               l_date_effective_tbl
               limit l_batch_size;

      if (l_event_id_tbl.count = 0) then exit; end if;

      -- Select upg_batch_id
      select xla_upg_batches_s.nextval
      into   l_upg_batch_id
      from   dual;

      -- Update table with event_id
      FORALL l_count IN 1..l_event_id_tbl.count
         update fa_trx_references trx
         set    trx.event_id = l_event_id_tbl(l_count)
         where  trx.rowid = l_tr_rowid_tbl(l_count);

      FORALL l_count IN 1..l_event_id_tbl.count
         update fa_transaction_headers th
         set    th.event_id = l_event_id_tbl(l_count)
         where  th.rowid = l_src_rowid_tbl(l_count);

      FORALL l_count IN 1..l_event_id_tbl.count
         update fa_transaction_headers th
         set    th.event_id = l_event_id_tbl(l_count)
         where  th.rowid = l_dest_rowid_tbl(l_count);

      l_rows_processed := l_event_id_tbl.count;

      -- Business Rules for xla_transaction_entities
      -- * ledger_id is the same as set_of_books_id
      -- * legal_entity_id is null
      -- * entity_code is INTER_ASSET_TRANSACTIONS
      -- * for TRANSACTIONS:
      --       source_id_int_1 is trx_reference_id
      --       transaction_number is trx_reference_id
      -- * for DEPRECIATION:
      --       source_id_int is asset_id
      --       source_id_int_2 is period_counter
      --       source_id_int_3 is deprn_run_id
      --       transaction_number is set_of_books_id
      -- * source_char_id_1 is book_type_code
      -- * valuation_method is book_type_code

      FORALL i IN 1..l_event_id_tbl.count
         INSERT INTO xla_transaction_entities_upg (
            upg_batch_id,
            application_id,
            ledger_id,
            legal_entity_id,
            entity_code,
            source_id_int_1,
            source_id_int_2,
            source_id_int_3,
            source_id_int_4,
            source_id_char_1,
            source_id_char_2,
            source_id_char_3,
            source_id_char_4,
            security_id_int_1,
            security_id_int_2,
            security_id_int_3,
            security_id_char_1,
            security_id_char_2,
            security_id_char_3,
            transaction_number,
            valuation_method,
            source_application_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            entity_id,
            upg_source_application_id
         ) values (
            l_upg_batch_id,                        -- upg_batch_id
            c_application_id,                      -- application_id
            l_primary_set_of_books_id_tbl(i),      -- ledger_id
            null,                                  -- legal_entity_id,
            c_entity_code,                         -- entity_code
            l_trx_reference_id_tbl(i),             -- source_id_int_1
            null,                                  -- source_id_int_2
            null,                                  -- source_id_int_3
            null,                                  -- source_id_int_4
            l_book_type_code_tbl(i),               -- source_id_char_1  -- Bug 8239360
            null,                                  -- source_id_char_2
            null,                                  -- source_id_char_3
            null,                                  -- source_id_char_4
            null,                                  -- security_id_int_1
            null,                                  -- security_id_int_2
            null,                                  -- security_id_int_3
            null,                                  -- security_id_char_1
            null,                                  -- security_id_char_2
            null,                                  -- security_id_char_3
            l_trx_reference_id_tbl(i),             -- transaction number
            l_book_type_code_tbl(i),               -- valuation_method
            c_application_id,                      -- source_application_id
            sysdate,                               -- creation_date
            c_fnd_user,                            -- created_by
            sysdate,                               -- last_update_date
            c_upgrade_bugno,                       -- last_update_by
            c_upgrade_bugno,                       -- last_update_login
            l_entity_id_tbl(i),                    -- entity_id
            c_application_id                       -- upg_source_application_id
         );

      -- Business Rules for xla_events
      -- * event_type_code is similar to transaction_type_code
      -- * event_number is 1, but is the serial event for chronological order
      -- * event_status_code: N if event creates no journal entries
      --                      P if event would ultimately yield journals
      --                      I if event is not ready to be processed
      --                      U never use this value for upgrade
      -- * process_status_code: E if error and journals not yet created
      --                        P if processed and journals already generated
      --                        U if unprocessed and journals not generated
      --                        D only used for Global Accounting Engine
      --                        I do not use for upgrade
      -- * on_hold_flag: N should always be this value for upgraded entries
      -- * event_date is basically transaction_date_entered

      FORALL i IN 1..l_event_id_tbl.count
         insert into xla_events (
            upg_batch_id,
            application_id,
            event_type_code,
            event_number,
            event_status_code,
            process_status_code,
            on_hold_flag,
            event_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_update_date,
            program_id,
            program_application_id,
            request_id,
            entity_id,
            event_id,
            upg_source_application_id,
            transaction_date
         ) values (
            l_upg_batch_id,                          -- upg_batch_id
            c_application_id,                        -- application_id
            l_event_class_code_tbl(i),               -- event_type_code
            '1',                                     -- event_number
            'P',                                     -- event_status_code
            'P',                                     -- process_status_code
            'N',                                     -- on_hold_flag
            l_transaction_date_entered_tbl(i),       -- event_date
            sysdate,                                 -- creation_date
            c_fnd_user,                              -- created_by
            sysdate,                                 -- last_update_date
            c_upgrade_bugno,                         -- last_update_by
            c_upgrade_bugno,                         -- last_update_login
            null,                                    -- program_update_date
            null,                                    -- program_id
            null,                                    -- program_application_id
            null,                                    -- program_update_date
            l_entity_id_tbl(i),                      -- entity_id
            l_event_id_tbl(i),                       -- event_id
            c_application_id,                        -- upg_source_appl_id
            l_transaction_date_entered_tbl(i)        -- transaction_date
         );

      FOR i IN 1..l_event_id_tbl.count LOOP

            open c_adj (l_book_type_code_tbl(i),
                        l_src_asset_id_tbl(i),
                        l_src_thid_tbl(i),
                        l_date_effective_tbl(i));
            fetch c_adj bulk collect
             into l_adj_thid_tbl,
                  l_adj_line_id_tbl,
                  l_debit_amount_tbl,
                  l_credit_amount_tbl,
                  l_ccid_tbl,
                  l_currency_code_tbl,
                  l_acct_class_code_tbl,
                  l_line_desc_tbl,
                  l_gl_transfer_status_code_tbl,
                  l_je_batch_id_tbl,
                  l_je_header_id_tbl,
                  l_je_line_num_tbl,
                  l_distribution_id_tbl;
            close c_adj;

            FOR j IN 1..l_adj_line_id_tbl.count LOOP
               l_ae_line_num_tbl(j) := j;

               -- Bug 6811554
               select decode (l_gl_transfer_status_code_tbl(j),
                              'Y', xla_gl_sl_link_id_s.nextval
                                 , null)
               into   l_xla_gl_sl_link_id_tbl(j)
               from   dual;
            END LOOP;

            select xla_ae_headers_s.nextval
            into   l_ae_header_id
            from   dual;

            l_line_num_tbl(1) :=  l_adj_line_id_tbl.count; -- Bug 6827893
            l_ae_header_id_tbl(1) :=  l_ae_header_id; -- Bug 6827893

            -- Business Rules for xla_ae_headers
            -- * amb_context_code is DEFAULT
            -- * reference_date must be null
            -- * balance_type_code:
            --     A: Actual
            --     B: Budget
            --     E: Encumbrance
            -- * gl_transfer_status_code:
            --     Y: already transferred to GL
            --     N: not transferred to GL
            -- * gl_transfer_date is date entry transferred to GL
            -- * accounting_entry_status_code must be F
            -- * accounting_entry_type_code must be STANDARD
            -- * product_rule_* not relevant for upgrade

               insert into xla_ae_headers (
                  upg_batch_id,
                  application_id,
                  amb_context_code,
                  entity_id,
                  event_id,
                  event_type_code,
                  ae_header_id,
                  ledger_id,
                  accounting_date,
                  period_name,
                  reference_date,
                  balance_type_code,
                  je_category_name,
                  gl_transfer_status_code,
                  gl_transfer_date,
                  accounting_entry_status_code,
                  accounting_entry_type_code,
                  description,
                  budget_version_id,
                  funds_status_code,
                  encumbrance_type_id,
                  completed_date,
                  doc_sequence_id,
                  doc_sequence_value,
                  doc_category_code,
                  packet_id,
                  group_id,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  program_id,
                  program_application_id,
                  program_update_date,
                  request_id,
                  close_acct_seq_assign_id,
                  close_acct_seq_version_id,
                  close_acct_seq_value,
                  completion_acct_seq_assign_id,
                  completion_acct_seq_version_id,
                  completion_acct_seq_value,
                  accounting_batch_id,
                  product_rule_type_code,
                  product_rule_code,
                  product_rule_version,
                  upg_source_application_id,
                  upg_valid_flag
               ) values (
                  l_upg_batch_id,               -- upg_batch_id
                  c_application_id,             -- application_id
                  c_amb_context_code,           -- amb_context_code
                  l_entity_id_tbl(i),           -- entity_id
                  l_event_id_tbl(i),            -- event_id,
                  l_event_class_code_tbl(i),    -- event_type_code
                  l_ae_header_id,               -- ae_header_id,
                  l_primary_set_of_books_id_tbl(i),
                                                -- ledger_id/sob_id
                  l_cal_period_close_date_tbl(i),
                                                -- accounting_date,
                  l_period_name_tbl(i),         -- period_name,
                  null,                         -- reference_date
                  'A',                          -- balance_type_code,
                  l_je_category_name_tbl(i),    -- je_category_name
                  l_gl_transfer_status_code_tbl(1),  -- Bug 6811554
                                                -- gl_transfer_status_code
                  null,                         -- gl_transfer_date
                  'F',                          -- accounting_entry_status_code
                  'STANDARD',                   -- accounting_entry_type_code
                  l_src_hdr_desc_tbl(i),        -- description
                  null,                         -- budget_version_id
                  null,                         -- funds_status_code
                  null,                         -- encumbrance_type_id
                  null,                         -- completed_date
                  null,                         -- doc_sequence_id
                  null,                         -- doc_sequence_value
                  null,                         -- doc_category_code
                  null,                         -- packet_id,
                  null,                         -- group_id
                  sysdate,                      -- creation_date
                  c_fnd_user,                   -- created_by
                  sysdate,                      -- last_update_date
                  c_fnd_user,                   -- last_updated_by
                  c_upgrade_bugno,              -- last_update_login
                  null,                         -- program_id
                  c_application_id,             -- program_application_id
                  sysdate,                      -- program_update_date
                  null,                         -- request_id
                  null,                         -- close_acct_seq_assign_id
                  null,                         -- close_acct_seq_version_id
                  null,                         -- close_acct_seq_value
                  null,                         -- compl_acct_seq_assign_id
                  null,                         -- compl_acct_seq_version_id
                  null,                         -- compl_acct_seq_value
                  null,                         -- accounting_batch_id
                  null,                         -- product_rule_type_code
                  null,                         -- product_rule_code
                  null,                         -- product_rule_version
                  c_application_id,             -- upg_souce_application_id
                  null                          -- upg_valid_flag
               );

            -- Business Rules for xla_ae_lines
            -- * gl_transfer_mode_code:
            --       D: Detailed mode when transferred to GL
            --       S: Summary mode when transferred to GL
            -- * gl_sl_link_table must be XLAJEL
            -- * currency_conversion_* needs to be populated only if
            --   different from ledger currency

            forall j IN 1..l_xla_gl_sl_link_id_tbl.count
            insert into xla_ae_lines (
                  upg_batch_id,
                  ae_header_id,
                  ae_line_num,
                  displayed_line_number,
                  application_id,
                  code_combination_id,
                  gl_transfer_mode_code,
                  accounted_dr,
                  accounted_cr,
                  currency_code,
                  currency_conversion_date,
                  currency_conversion_rate,
                  currency_conversion_type,
                  entered_dr,
                  entered_cr,
                  description,
                  accounting_class_code,
                  gl_sl_link_id,
                  gl_sl_link_table,
                  party_type_code,
                  party_id,
                  party_site_id,
                  statistical_amount,
                  ussgl_transaction_code,
                  jgzz_recon_ref,
                  control_balance_flag,
                  analytical_balance_flag,
                  upg_tax_reference_id1,
                  upg_tax_reference_id2,
                  upg_tax_reference_id3,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  program_update_date,
                  program_id,
                  program_application_id,
                  request_id,
                  gain_or_loss_flag,
                  accounting_date,
                  ledger_id
            ) values (
                  l_upg_batch_id,                 -- upg_batch_id
                  l_ae_header_id,                 -- ae_header_id
                  l_ae_line_num_tbl(j),           -- ae_line_num
                  l_ae_line_num_tbl(j),           -- displayed_line_num
                  c_application_id,               -- application_id
                  l_ccid_tbl(j),                  -- code_combination_id
                  'S',                            -- gl_transfer_mode_code
                  l_debit_amount_tbl(j),          -- accounted_dr
                  l_credit_amount_tbl(j),         -- accounted_cr
                  l_currency_code_tbl(j),         -- currency_code
                  null,                           -- currency_conversion_date
                  null,                           -- currency_conversion_rate
                  null,                           -- currency_conversion_type
                  l_debit_amount_tbl(j),          -- entered_dr
                  l_credit_amount_tbl(j),         -- entered_cr
                  l_line_desc_tbl(j) || ' - ' ||
                     to_char(l_cal_period_close_date_tbl(i), 'DD-MON-RR'),
                                                  -- description
                  l_acct_class_code_tbl(j),       -- accounting_class_code
                  l_xla_gl_sl_link_id_tbl(j),     -- gl_sl_link_id
                  'XLAJEL',                       -- gl_sl_link_table
                  null,                           -- party_type_code
                  null,                           -- party_id
                  null,                           -- party_site_id
                  null,                           -- statistical_amount
                  null,                           -- ussgl_transaction_code
                  null,                           -- glzz_recon_ref
                  null,                           -- control_balance_flag
                  null,                           -- analytical_balance_flag
                  null,                           -- upg_tax_reference_id1
                  null,                           -- upg_tax_reference_id2
                  null,                           -- upg_tax_reference_id3
                  sysdate,                        -- creation_date
                  c_fnd_user,                     -- created_by
                  sysdate,                        -- last_update_date
                  c_fnd_user,                     -- last_updated_by
                  c_upgrade_bugno,                -- last_update_login
                  null,                           -- program_update_date
                  null,                           -- program_id
                  c_application_id,               -- program_application_id
                  null,                           -- request_id
                  'N',                            -- gain_or_loss_flag
                  l_cal_period_close_date_tbl(i), -- accounting_date,
                  l_primary_set_of_books_id_tbl(i)
                                                  -- ledger_id/sob_id
            );

            -- Business Rules for xla_distribution_links
            -- * accounting_line_code is similar to adjustment_type
            -- * accounting_line_type_code is S
            -- * merge_duplicate_code is N
            -- * source_distribution_type is TRX
            -- * source_distribution_id_num_1 is trx_reference_id
            -- * source_distribution_id_num_2 is event_id

            forall j IN 1..l_xla_gl_sl_link_id_tbl.count
            insert into xla_distribution_links (
                  upg_batch_id,
                  application_id,
                  event_id,
                  ae_header_id,
                  ae_line_num,
                  accounting_line_code,
                  accounting_line_type_code,
                  source_distribution_type,
                  source_distribution_id_char_1,
                  source_distribution_id_char_2,
                  source_distribution_id_char_3,
                  source_distribution_id_char_4,
                  source_distribution_id_char_5,
                  source_distribution_id_num_1,
                  source_distribution_id_num_2,
                  source_distribution_id_num_3,
                  source_distribution_id_num_4,
                  source_distribution_id_num_5,
                  merge_duplicate_code,
                  statistical_amount,
                  unrounded_entered_dr,
                  unrounded_entered_cr,
                  unrounded_accounted_dr,
                  unrounded_accounted_cr,
                  ref_ae_header_id,
                  ref_temp_line_num,
                  ref_event_id,
                  temp_line_num,
                  tax_line_ref_id,
                  tax_summary_line_ref_id,
                  tax_rec_nrec_dist_ref_id,
                  line_definition_owner_code,
                  line_definition_code,
                  event_class_code,
                  event_type_code
            ) values (
                  l_upg_batch_id,              -- upg_batch_id
                  c_application_id,            -- application_id
                  l_event_id_tbl(i),           -- event_id
                  l_ae_header_id,              -- ae_header_id
                  l_ae_line_num_tbl(j),        -- ae_line_num
                  null,                        -- accounting_line_code
                  'S',                         -- accounting_line_type_code
                  'TRX',                       -- source_distribution_type
                  null,                        -- source_distribution_id_char_1
                  null,                        -- source_distribution_id_char_2
                  null,                        -- source_distribution_id_char_3
                  null,                        -- source_distribution_id_char_4
                  null,                        -- source_distribution_id_char_5
                  l_adj_thid_tbl(j),           -- BUG# 6827893
                                               -- l_trx_reference_id_tbl(i),
                                               -- source_distribution_id_num_1
                  l_adj_line_id_tbl(j),        -- source_distribution_id_num_2
                  null,                        -- source_distribution_id_num_3
                  null,                        -- source_distribution_id_num_4
                  null,                        -- source_distribution_id_num_5
                  'N',                         -- merge_duplicate_code
                  null,                        -- statistical_amount
                  l_debit_amount_tbl(j),       -- unrounded_entered_dr
                  l_credit_amount_tbl(j),      -- unrounded_entered_cr
                  l_debit_amount_tbl(j),       -- unrounded_accounted_dr
                  l_credit_amount_tbl(j),      -- unrounded_accounted_cr
                  l_ae_header_id,              -- ref_ae_header_id
                  null,                        -- ref_temp_line_num
                  null,                        -- ref_event_id
                  l_ae_line_num_tbl(j),        -- temp_line_num
                  null,                        -- tax_line_ref_id
                  null,                        -- tax_summary_line_ref_id
                  null,                        -- tax_rec_nrec_dist_ref_id
                  null,                        -- line_definition_owner_code
                  null,                        -- line_definition_code
                  l_event_class_code_tbl(i),   -- event_class_code
                  l_event_class_code_tbl(i)    -- event_type_code
            );

            for j IN 1..l_xla_gl_sl_link_id_tbl.count loop
               if (l_je_batch_id_tbl(j) is not null) then
                  insert into gl_import_references (
                     je_batch_id,
                     je_header_id,
                     je_line_num,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     reference_1,
                     reference_2,
                     reference_3,
                     reference_4,
                     reference_5,
                     reference_6,
                     reference_7,
                     reference_8,
                     reference_9,
                     reference_10,
                     subledger_doc_sequence_id,
                     subledger_doc_sequence_value,
                     gl_sl_link_id,
                     gl_sl_link_table
                  ) values (
                     l_je_batch_id_tbl(j),        -- je_batch_id
                     l_je_header_id_tbl(j),       -- je_header_id
                     l_je_line_num_tbl(j),        -- je_line_num
                     sysdate,                     -- last_update_date
                     c_fnd_user,                  -- last_updated_by
                     sysdate,                     -- creation_date
                     c_fnd_user,                  -- created_by
                     c_upgrade_bugno,             -- last_update_login
                     to_char(l_src_thid_tbl(i)),
                                                  -- reference_1
                     to_char(l_src_asset_id_tbl(i)),
                                                  -- reference_2
                     to_char(l_distribution_id_tbl(j)),
                                                  -- reference_3
                     to_char(l_adj_line_id_tbl(j)),
                                                  -- reference_4
                     l_book_type_code_tbl(i),     -- reference_5
                     to_char(l_period_counter_tbl(i)),
                                                  -- reference_6
                     null,                        -- reference_7
                     null,                        -- reference_8
                     null,                        -- reference_9
                     null,                        -- reference_10
                     null,                        -- subledger_doc_seq_id
                     null,                        -- subledger_doc_seq_value
                     l_xla_gl_sl_link_id_tbl(j),  -- gl_sl_link_id
                     'XLAJEL'                     -- gl_sl_link_table
                  );
               end if;
            end loop;

            l_adj_line_id_tbl.delete;
            l_xla_gl_sl_link_id_tbl.delete;
            l_ae_line_num_tbl.delete;
            l_debit_amount_tbl.delete;
            l_credit_amount_tbl.delete;
            l_ccid_tbl.delete;
            l_acct_class_code_tbl.delete;
            l_currency_code_tbl.delete;
            l_line_def_owner_code_tbl.delete;
            l_line_def_code_tbl.delete;
            l_line_desc_tbl.delete;
            l_gl_transfer_status_code_tbl.delete;
            l_je_batch_id_tbl.delete;
            l_je_header_id_tbl.delete;
            l_je_line_num_tbl.delete;
            l_distribution_id_tbl.delete;

            open c_mc_books (l_book_type_code_tbl(i));
            fetch c_mc_books bulk collect
             into l_rep_set_of_books_id_tbl;
            close c_mc_books;

           for k IN 1..l_rep_set_of_books_id_tbl.count loop

            open c_mc_adj (l_book_type_code_tbl(i),
                        l_src_asset_id_tbl(i),
                        l_rep_set_of_books_id_tbl(k),
                        l_src_thid_tbl(i),
                        l_date_effective_tbl(i));
            fetch c_mc_adj bulk collect
             into l_adj_thid_tbl,
                  l_adj_line_id_tbl,
                  l_debit_amount_tbl,
                  l_credit_amount_tbl,
                  l_ccid_tbl,
                  l_currency_code_tbl,
                  l_acct_class_code_tbl,
                  l_line_desc_tbl,
                  l_gl_transfer_status_code_tbl,
                  l_je_batch_id_tbl,
                  l_je_header_id_tbl,
                  l_je_line_num_tbl,
                  l_distribution_id_tbl;
           close c_mc_adj;

            FOR j IN 1..l_adj_line_id_tbl.count LOOP
               l_ae_line_num_tbl(j) := j;

               -- Bug 6811554
               select decode (l_gl_transfer_status_code_tbl(j),
                              'Y', xla_gl_sl_link_id_s.nextval
                                 , null)
               into   l_xla_gl_sl_link_id_tbl(j)
               from   dual;
            END LOOP;

            select xla_ae_headers_s.nextval
            into   l_ae_header_id
            from   dual;

            l_line_num_tbl(k+1) :=  l_adj_line_id_tbl.count; -- Bug 6827893
            l_ae_header_id_tbl(k+1) :=  l_ae_header_id; -- Bug 6827893

            -- Business Rules for xla_ae_headers
            -- * amb_context_code is DEFAULT
            -- * reference_date must be null
            -- * balance_type_code:
            --     A: Actual
            --     B: Budget
            --     E: Encumbrance
            -- * gl_transfer_status_code:
            --     Y: already transferred to GL
            --     N: not transferred to GL
            -- * gl_transfer_date is date entry transferred to GL
            -- * accounting_entry_status_code must be F
            -- * accounting_entry_type_code must be STANDARD
            -- * product_rule_* not relevant for upgrade

               insert into xla_ae_headers (
                  upg_batch_id,
                  application_id,
                  amb_context_code,
                  entity_id,
                  event_id,
                  event_type_code,
                  ae_header_id,
                  ledger_id,
                  accounting_date,
                  period_name,
                  reference_date,
                  balance_type_code,
                  je_category_name,
                  gl_transfer_status_code,
                  gl_transfer_date,
                  accounting_entry_status_code,
                  accounting_entry_type_code,
                  description,
                  budget_version_id,
                  funds_status_code,
                  encumbrance_type_id,
                  completed_date,
                  doc_sequence_id,
                  doc_sequence_value,
                  doc_category_code,
                  packet_id,
                  group_id,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  program_id,
                  program_application_id,
                  program_update_date,
                  request_id,
                  close_acct_seq_assign_id,
                  close_acct_seq_version_id,
                  close_acct_seq_value,
                  completion_acct_seq_assign_id,
                  completion_acct_seq_version_id,
                  completion_acct_seq_value,
                  accounting_batch_id,
                  product_rule_type_code,
                  product_rule_code,
                  product_rule_version,
                  upg_source_application_id,
                  upg_valid_flag
               ) values (
                  l_upg_batch_id,               -- upg_batch_id
                  c_application_id,             -- application_id
                  c_amb_context_code,           -- amb_context_code
                  l_entity_id_tbl(i),           -- entity_id
                  l_event_id_tbl(i),            -- event_id,
                  l_event_class_code_tbl(i),    -- event_type_code
                  l_ae_header_id,               -- ae_header_id,
                  l_rep_set_of_books_id_tbl(k), -- ledger_id/sob_id
                  l_cal_period_close_date_tbl(i),
                                                -- accounting_date,
                  l_period_name_tbl(i),         -- period_name,
                  null,                         -- reference_date
                  'A',                          -- balance_type_code,
                  l_je_category_name_tbl(i),    -- je_category_name
                  l_gl_transfer_status_code_tbl(1),  -- Bug 6811554
                                                -- gl_transfer_status_code
                  null,                         -- gl_transfer_date
                  'F',                          -- accounting_entry_status_code
                  'STANDARD',                   -- accounting_entry_type_code
                  l_src_hdr_desc_tbl(i),        -- description
                  null,                         -- budget_version_id
                  null,                         -- funds_status_code
                  null,                         -- encumbrance_type_id
                  null,                         -- completed_date
                  null,                         -- doc_sequence_id
                  null,                         -- doc_sequence_value
                  null,                         -- doc_category_code
                  null,                         -- packet_id,
                  null,                         -- group_id
                  sysdate,                      -- creation_date
                  c_fnd_user,                   -- created_by
                  sysdate,                      -- last_update_date
                  c_fnd_user,                   -- last_updated_by
                  c_upgrade_bugno,              -- last_update_login
                  null,                         -- program_id
                  c_application_id,             -- program_application_id
                  sysdate,                      -- program_update_date
                  null,                         -- request_id
                  null,                         -- close_acct_seq_assign_id
                  null,                         -- close_acct_seq_version_id
                  null,                         -- close_acct_seq_value
                  null,                         -- compl_acct_seq_assign_id
                  null,                         -- compl_acct_seq_version_id
                  null,                         -- compl_acct_seq_value
                  null,                         -- accounting_batch_id
                  null,                         -- product_rule_type_code
                  null,                         -- product_rule_code
                  null,                         -- product_rule_version
                  c_application_id,             -- upg_souce_application_id
                  null                          -- upg_valid_flag
               );

            -- Business Rules for xla_ae_lines
            -- * gl_transfer_mode_code:
            --       D: Detailed mode when transferred to GL
            --       S: Summary mode when transferred to GL
            -- * gl_sl_link_table must be XLAJEL
            -- * currency_conversion_* needs to be populated only if
            --   different from ledger currency

            forall j IN 1..l_xla_gl_sl_link_id_tbl.count
            insert into xla_ae_lines (
                  upg_batch_id,
                  ae_header_id,
                  ae_line_num,
                  displayed_line_number,
                  application_id,
                  code_combination_id,
                  gl_transfer_mode_code,
                  accounted_dr,
                  accounted_cr,
                  currency_code,
                  currency_conversion_date,
                  currency_conversion_rate,
                  currency_conversion_type,
                  entered_dr,
                  entered_cr,
                  description,
                  accounting_class_code,
                  gl_sl_link_id,
                  gl_sl_link_table,
                  party_type_code,
                  party_id,
                  party_site_id,
                  statistical_amount,
                  ussgl_transaction_code,
                  jgzz_recon_ref,
                  control_balance_flag,
                  analytical_balance_flag,
                  upg_tax_reference_id1,
                  upg_tax_reference_id2,
                  upg_tax_reference_id3,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  program_update_date,
                  program_id,
                  program_application_id,
                  request_id,
                  gain_or_loss_flag,
                  accounting_date,
                  ledger_id
            ) values (
                  l_upg_batch_id,                 -- upg_batch_id
                  l_ae_header_id,                 -- ae_header_id
                  l_ae_line_num_tbl(j),           -- ae_line_num
                  l_ae_line_num_tbl(j),           -- displayed_line_num
                  c_application_id,               -- application_id
                  l_ccid_tbl(j),                  -- code_combination_id
                  'S',                            -- gl_transfer_mode_code
                  l_debit_amount_tbl(j),          -- accounted_dr
                  l_credit_amount_tbl(j),         -- accounted_cr
                  l_currency_code_tbl(j),         -- currency_code
                  null,                           -- currency_conversion_date
                  null,                           -- currency_conversion_rate
                  null,                           -- currency_conversion_type
                  l_debit_amount_tbl(j),          -- entered_dr
                  l_credit_amount_tbl(j),         -- entered_cr
                  l_line_desc_tbl(j) || ' - ' ||
                     to_char(l_cal_period_close_date_tbl(i), 'DD-MON-RR'),
                                                  -- description
                  l_acct_class_code_tbl(j),       -- accounting_class_code
                  l_xla_gl_sl_link_id_tbl(j),     -- gl_sl_link_id
                  'XLAJEL',                       -- gl_sl_link_table
                  null,                           -- party_type_code
                  null,                           -- party_id
                  null,                           -- party_site_id
                  null,                           -- statistical_amount
                  null,                           -- ussgl_transaction_code
                  null,                           -- glzz_recon_ref
                  null,                           -- control_balance_flag
                  null,                           -- analytical_balance_flag
                  null,                           -- upg_tax_reference_id1
                  null,                           -- upg_tax_reference_id2
                  null,                           -- upg_tax_reference_id3
                  sysdate,                        -- creation_date
                  c_fnd_user,                     -- created_by
                  sysdate,                        -- last_update_date
                  c_fnd_user,                     -- last_updated_by
                  c_upgrade_bugno,                -- last_update_login
                  null,                           -- program_update_date
                  null,                           -- program_id
                  c_application_id,               -- program_application_id
                  null,                           -- request_id
                  'N',                            -- gain_or_loss_flag
                  l_cal_period_close_date_tbl(i), -- accounting_date,
                  l_rep_set_of_books_id_tbl(k)    -- ledger_id/sob_id
            );

            -- Business Rules for xla_distribution_links
            -- * accounting_line_code is similar to adjustment_type
            -- * accounting_line_type_code is S
            -- * merge_duplicate_code is N
            -- * source_distribution_type is TRX
            -- * source_distribution_id_num_1 is trx_reference_id
            -- * source_distribution_id_num_2 is event_id

            forall j IN 1..l_xla_gl_sl_link_id_tbl.count
            insert into xla_distribution_links (
                  upg_batch_id,
                  application_id,
                  event_id,
                  ae_header_id,
                  ae_line_num,
                  accounting_line_code,
                  accounting_line_type_code,
                  source_distribution_type,
                  source_distribution_id_char_1,
                  source_distribution_id_char_2,
                  source_distribution_id_char_3,
                  source_distribution_id_char_4,
                  source_distribution_id_char_5,
                  source_distribution_id_num_1,
                  source_distribution_id_num_2,
                  source_distribution_id_num_3,
                  source_distribution_id_num_4,
                  source_distribution_id_num_5,
                  merge_duplicate_code,
                  statistical_amount,
                  unrounded_entered_dr,
                  unrounded_entered_cr,
                  unrounded_accounted_dr,
                  unrounded_accounted_cr,
                  ref_ae_header_id,
                  ref_temp_line_num,
                  ref_event_id,
                  temp_line_num,
                  tax_line_ref_id,
                  tax_summary_line_ref_id,
                  tax_rec_nrec_dist_ref_id,
                  line_definition_owner_code,
                  line_definition_code,
                  event_class_code,
                  event_type_code
            ) values (
                  l_upg_batch_id,              -- upg_batch_id
                  c_application_id,            -- application_id
                  l_event_id_tbl(i),           -- event_id
                  l_ae_header_id,              -- ae_header_id
                  l_ae_line_num_tbl(j),        -- ae_line_num
                  null,                        -- accounting_line_code
                  'S',                         -- accounting_line_type_code
                  'TRX',                       -- source_distribution_type
                  null,                        -- source_distribution_id_char_1
                  null,                        -- source_distribution_id_char_2
                  null,                        -- source_distribution_id_char_3
                  null,                        -- source_distribution_id_char_4

                  null,                        -- source_distribution_id_char_5
                  l_adj_thid_tbl(j),           -- Bug 6827893
                                               -- source_distribution_id_num_1
                  l_adj_line_id_tbl(j),        -- source_distribution_id_num_2
                  null,                        -- source_distribution_id_num_3
                  null,                        -- source_distribution_id_num_4
                  null,                        -- source_distribution_id_num_5
                  'N',                         -- merge_duplicate_code
                  null,                        -- statistical_amount
                  l_debit_amount_tbl(j),       -- unrounded_entered_dr
                  l_credit_amount_tbl(j),      -- unrounded_entered_cr
                  l_debit_amount_tbl(j),       -- unrounded_accounted_dr
                  l_credit_amount_tbl(j),      -- unrounded_accounted_cr
                  l_ae_header_id,              -- ref_ae_header_id
                  null,                        -- ref_temp_line_num
                  null,                        -- ref_event_id
                  l_ae_line_num_tbl(j),        -- temp_line_num
                  null,                        -- tax_line_ref_id
                  null,                        -- tax_summary_line_ref_id
                  null,                        -- tax_rec_nrec_dist_ref_id
                  null,                        -- line_definition_owner_code
                  null,                        -- line_definition_code
                  l_event_class_code_tbl(i),   -- event_class_code
                  l_event_class_code_tbl(i)    -- event_type_code
            );

            for j IN 1..l_xla_gl_sl_link_id_tbl.count loop
               if (l_je_batch_id_tbl(j) is not null) then
                  insert into gl_import_references (
                     je_batch_id,
                     je_header_id,
                     je_line_num,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     reference_1,
                     reference_2,
                     reference_3,
                     reference_4,
                     reference_5,
                     reference_6,
                     reference_7,
                     reference_8,
                     reference_9,
                     reference_10,
                     subledger_doc_sequence_id,
                     subledger_doc_sequence_value,
                     gl_sl_link_id,
                     gl_sl_link_table
                  ) values (
                     l_je_batch_id_tbl(j),        -- je_batch_id
                     l_je_header_id_tbl(j),       -- je_header_id
                     l_je_line_num_tbl(j),        -- je_line_num
                     sysdate,                     -- last_update_date
                     c_upgrade_bugno,             -- last_updated_by
                     sysdate,                     -- creation_date
                     c_fnd_user,                  -- created_by
                     c_upgrade_bugno,             -- last_update_login
                     to_char(l_src_thid_tbl(i)),
                                                  -- reference_1
                     to_char(l_src_asset_id_tbl(i)),
                                                  -- reference_2
                     to_char(l_distribution_id_tbl(j)),
                                                  -- reference_3
                     to_char(l_adj_line_id_tbl(j)),
                                                  -- reference_4
                     l_book_type_code_tbl(i),     -- reference_5
                     to_char(l_period_counter_tbl(i)),
                                                  -- reference_6
                     null,                        -- reference_7
                     null,                        -- reference_8
                     null,                        -- reference_9
                     null,                        -- reference_10
                     null,                        -- subledger_doc_seq_id
                     null,                        -- subledger_doc_seq_value
                     l_xla_gl_sl_link_id_tbl(j),  -- gl_sl_link_id
                     'XLAJEL'                     -- gl_sl_link_table
                  );
               end if;
            end loop;

            l_adj_line_id_tbl.delete;
            l_xla_gl_sl_link_id_tbl.delete;
            l_ae_line_num_tbl.delete;
            l_debit_amount_tbl.delete;
            l_credit_amount_tbl.delete;
            l_ccid_tbl.delete;
            l_acct_class_code_tbl.delete;
            l_currency_code_tbl.delete;
            l_line_def_owner_code_tbl.delete;
            l_line_def_code_tbl.delete;
            l_line_desc_tbl.delete;
            l_gl_transfer_status_code_tbl.delete;
            l_je_batch_id_tbl.delete;
            l_je_header_id_tbl.delete;
            l_je_line_num_tbl.delete;
            l_distribution_id_tbl.delete;

            end loop;

            l_rep_set_of_books_id_tbl.delete;

            open c_adj (l_book_type_code_tbl(i),
                        l_dest_asset_id_tbl(i),
                        l_dest_thid_tbl(i),
                        l_date_effective_tbl(i));
            fetch c_adj bulk collect
             into l_adj_thid_tbl,
                  l_adj_line_id_tbl,
                  l_debit_amount_tbl,
                  l_credit_amount_tbl,
                  l_ccid_tbl,
                  l_currency_code_tbl,
                  l_acct_class_code_tbl,
                  l_line_desc_tbl,
                  l_gl_transfer_status_code_tbl,
                  l_je_batch_id_tbl,
                  l_je_header_id_tbl,
                  l_je_line_num_tbl,
                  l_distribution_id_tbl;
            close c_adj;

            FOR j IN 1..l_adj_line_id_tbl.count LOOP
               l_ae_line_num_tbl(j) := j + l_line_num_tbl(1); -- Bug 6827893

               -- Bug 6811554
               select decode (l_gl_transfer_status_code_tbl(j),
                              'Y', xla_gl_sl_link_id_s.nextval
                                 , null)
               into   l_xla_gl_sl_link_id_tbl(j)
               from   dual;
            END LOOP;

            -- Bug 6827893: No need to create new ae_hdr_id. Use same as src
            l_ae_header_id := l_ae_header_id_tbl(1);

            -- Business Rules for xla_ae_lines
            -- * gl_transfer_mode_code:
            --       D: Detailed mode when transferred to GL
            --       S: Summary mode when transferred to GL
            -- * gl_sl_link_table must be XLAJEL
            -- * currency_conversion_* needs to be populated only if
            --   different from ledger currency

            forall j IN 1..l_xla_gl_sl_link_id_tbl.count
            insert into xla_ae_lines (
                  upg_batch_id,
                  ae_header_id,
                  ae_line_num,
                  displayed_line_number,
                  application_id,
                  code_combination_id,
                  gl_transfer_mode_code,
                  accounted_dr,
                  accounted_cr,
                  currency_code,
                  currency_conversion_date,
                  currency_conversion_rate,
                  currency_conversion_type,
                  entered_dr,
                  entered_cr,
                  description,
                  accounting_class_code,
                  gl_sl_link_id,
                  gl_sl_link_table,
                  party_type_code,
                  party_id,
                  party_site_id,
                  statistical_amount,
                  ussgl_transaction_code,
                  jgzz_recon_ref,
                  control_balance_flag,
                  analytical_balance_flag,
                  upg_tax_reference_id1,
                  upg_tax_reference_id2,
                  upg_tax_reference_id3,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  program_update_date,
                  program_id,
                  program_application_id,
                  request_id,
                  gain_or_loss_flag,
                  accounting_date,
                  ledger_id
            ) values (
                  l_upg_batch_id,                 -- upg_batch_id
                  l_ae_header_id,                 -- ae_header_id
                  l_ae_line_num_tbl(j),           -- ae_line_num
                  l_ae_line_num_tbl(j),           -- displayed_line_num
                  c_application_id,               -- application_id
                  l_ccid_tbl(j),                  -- code_combination_id
                  'S',                            -- gl_transfer_mode_code
                  l_debit_amount_tbl(j),          -- accounted_dr
                  l_credit_amount_tbl(j),         -- accounted_cr
                  l_currency_code_tbl(j),         -- currency_code
                  null,                           -- currency_conversion_date
                  null,                           -- currency_conversion_rate
                  null,                           -- currency_conversion_type
                  l_debit_amount_tbl(j),          -- entered_dr
                  l_credit_amount_tbl(j),         -- entered_cr
                  l_line_desc_tbl(j) || ' - ' ||
                     to_char(l_cal_period_close_date_tbl(i), 'DD-MON-RR'),
                                                  -- description
                  l_acct_class_code_tbl(j),       -- accounting_class_code
                  l_xla_gl_sl_link_id_tbl(j),     -- gl_sl_link_id
                  'XLAJEL',                       -- gl_sl_link_table
                  null,                           -- party_type_code
                  null,                           -- party_id
                  null,                           -- party_site_id
                  null,                           -- statistical_amount
                  null,                           -- ussgl_transaction_code
                  null,                           -- glzz_recon_ref
                  null,                           -- control_balance_flag
                  null,                           -- analytical_balance_flag
                  null,                           -- upg_tax_reference_id1
                  null,                           -- upg_tax_reference_id2
                  null,                           -- upg_tax_reference_id3
                  sysdate,                        -- creation_date
                  c_fnd_user,                     -- created_by
                  sysdate,                        -- last_update_date
                  c_fnd_user,                     -- last_updated_by
                  c_upgrade_bugno,                -- last_update_login
                  null,                           -- program_update_date
                  null,                           -- program_id
                  c_application_id,               -- program_application_id
                  null,                           -- request_id
                  'N',                            -- gain_or_loss_flag
                  l_cal_period_close_date_tbl(i), -- accounting_date,
                  l_primary_set_of_books_id_tbl(i)
                                                  -- ledger_id/sob_id
            );

            -- Business Rules for xla_distribution_links
            -- * accounting_line_code is similar to adjustment_type
            -- * accounting_line_type_code is S
            -- * merge_duplicate_code is N
            -- * source_distribution_type is TRX
            -- * source_distribution_id_num_1 is transaction_header_id
            -- * source_distribution_id_num_2 is event_id

            forall j IN 1..l_xla_gl_sl_link_id_tbl.count
            insert into xla_distribution_links (
                  upg_batch_id,
                  application_id,
                  event_id,
                  ae_header_id,
                  ae_line_num,
                  accounting_line_code,
                  accounting_line_type_code,
                  source_distribution_type,
                  source_distribution_id_char_1,
                  source_distribution_id_char_2,
                  source_distribution_id_char_3,
                  source_distribution_id_char_4,
                  source_distribution_id_char_5,
                  source_distribution_id_num_1,
                  source_distribution_id_num_2,
                  source_distribution_id_num_3,
                  source_distribution_id_num_4,
                  source_distribution_id_num_5,
                  merge_duplicate_code,
                  statistical_amount,
                  unrounded_entered_dr,
                  unrounded_entered_cr,
                  unrounded_accounted_dr,
                  unrounded_accounted_cr,
                  ref_ae_header_id,
                  ref_temp_line_num,
                  ref_event_id,
                  temp_line_num,
                  tax_line_ref_id,
                  tax_summary_line_ref_id,
                  tax_rec_nrec_dist_ref_id,
                  line_definition_owner_code,
                  line_definition_code,
                  event_class_code,
                  event_type_code
               ) values (
                  l_upg_batch_id,              -- upg_batch_id
                  c_application_id,            -- application_id
                  l_event_id_tbl(i),           -- event_id
                  l_ae_header_id,              -- ae_header_id
                  l_ae_line_num_tbl(j),        -- ae_line_num
                  null,                        -- accounting_line_code
                  'S',                         -- accounting_line_type_code
                  'TRX',                       -- source_distribution_type
                  null,                        -- source_distribution_id_char_1
                  null,                        -- source_distribution_id_char_2
                  null,                        -- source_distribution_id_char_3
                  null,                        -- source_distribution_id_char_4
                  null,                        -- source_distribution_id_char_5
                  l_adj_thid_tbl(j),           -- Bug 6827893
                                               -- source_distribution_id_num_1
                  l_adj_line_id_tbl(j),        -- source_distribution_id_num_2
                  null,                        -- source_distribution_id_num_3
                  null,                        -- source_distribution_id_num_4
                  null,                        -- source_distribution_id_num_5
                  'N',                         -- merge_duplicate_code
                  null,                        -- statistical_amount
                  l_debit_amount_tbl(j),       -- unrounded_entered_dr
                  l_credit_amount_tbl(j),      -- unrounded_entered_cr
                  l_debit_amount_tbl(j),       -- unrounded_accounted_dr
                  l_credit_amount_tbl(j),      -- unrounded_accounted_cr
                  l_ae_header_id,              -- ref_ae_header_id
                  null,                        -- ref_temp_line_num
                  null,                        -- ref_event_id
                  l_ae_line_num_tbl(j),        -- temp_line_num
                  null,                        -- tax_line_ref_id
                  null,                        -- tax_summary_line_ref_id
                  null,                        -- tax_rec_nrec_dist_ref_id
                  null,                        -- line_definition_owner_code
                  null,                        -- line_definition_code
                  l_event_class_code_tbl(i),   -- event_class_code
                  l_event_class_code_tbl(i)    -- event_type_code
               );

            for j IN 1..l_xla_gl_sl_link_id_tbl.count loop
               if (l_je_batch_id_tbl(j) is not null) then
                  insert into gl_import_references (
                     je_batch_id,
                     je_header_id,
                     je_line_num,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     reference_1,
                     reference_2,
                     reference_3,
                     reference_4,
                     reference_5,
                     reference_6,
                     reference_7,
                     reference_8,
                     reference_9,
                     reference_10,
                     subledger_doc_sequence_id,
                     subledger_doc_sequence_value,
                     gl_sl_link_id,
                     gl_sl_link_table
                  ) values (
                     l_je_batch_id_tbl(j),        -- je_batch_id
                     l_je_header_id_tbl(j),       -- je_header_id
                     l_je_line_num_tbl(j),        -- je_line_num
                     sysdate,                     -- last_update_date
                     c_fnd_user,                  -- last_updated_by
                     sysdate,                     -- creation_date
                     c_fnd_user,                  -- created_by
                     c_upgrade_bugno,             -- last_update_login
                     to_char(l_dest_thid_tbl(i)),
                                                  -- reference_1
                     to_char(l_dest_asset_id_tbl(i)),
                                                  -- reference_2
                     to_char(l_distribution_id_tbl(j)),
                                                  -- reference_3
                     to_char(l_adj_line_id_tbl(j)),
                                                  -- reference_4
                     l_book_type_code_tbl(i),     -- reference_5
                     to_char(l_period_counter_tbl(i)),
                                                  -- reference_6
                     null,                        -- reference_7
                     null,                        -- reference_8
                     null,                        -- reference_9
                     null,                        -- reference_10
                     null,                        -- subledger_doc_seq_id
                     null,                        -- subledger_doc_seq_value
                     l_xla_gl_sl_link_id_tbl(j),  -- gl_sl_link_id
                     'XLAJEL'                     -- gl_sl_link_table
                  );
               end if;
            end loop;

            l_adj_line_id_tbl.delete;
            l_xla_gl_sl_link_id_tbl.delete;
            l_ae_line_num_tbl.delete;
            l_debit_amount_tbl.delete;
            l_credit_amount_tbl.delete;
            l_ccid_tbl.delete;
            l_acct_class_code_tbl.delete;
            l_currency_code_tbl.delete;
            l_line_def_owner_code_tbl.delete;
            l_line_def_code_tbl.delete;
            l_line_desc_tbl.delete;
            l_gl_transfer_status_code_tbl.delete;
            l_je_batch_id_tbl.delete;
            l_je_header_id_tbl.delete;
            l_je_line_num_tbl.delete;
            l_distribution_id_tbl.delete;

            open c_mc_books (l_book_type_code_tbl(i));
            fetch c_mc_books bulk collect
             into l_rep_set_of_books_id_tbl;
            close c_mc_books;

           for k IN 1..l_rep_set_of_books_id_tbl.count loop

            open c_mc_adj (l_book_type_code_tbl(i),
                        l_dest_asset_id_tbl(i),
                        l_rep_set_of_books_id_tbl(k),
                        l_dest_thid_tbl(i),
                        l_date_effective_tbl(i));
            fetch c_mc_adj bulk collect
             into l_adj_thid_tbl,
                  l_adj_line_id_tbl,
                  l_debit_amount_tbl,
                  l_credit_amount_tbl,
                  l_ccid_tbl,
                  l_currency_code_tbl,
                  l_acct_class_code_tbl,
                  l_line_desc_tbl,
                  l_gl_transfer_status_code_tbl,
                  l_je_batch_id_tbl,
                  l_je_header_id_tbl,
                  l_je_line_num_tbl,
                  l_distribution_id_tbl;
           close c_mc_adj;

            FOR j IN 1..l_adj_line_id_tbl.count LOOP
               l_ae_line_num_tbl(j) := j + l_line_num_tbl(k+1); -- Bug 6827893

               -- Bug 6811554
               select decode (l_gl_transfer_status_code_tbl(j),
                              'Y', xla_gl_sl_link_id_s.nextval
                                 , null)
               into   l_xla_gl_sl_link_id_tbl(j)
               from   dual;
            END LOOP;

            -- Bug 6827893: No need to create new ae_hdr_id. Use same as src
            l_ae_header_id := l_ae_header_id_tbl(k+1);

            -- Business Rules for xla_ae_headers
            -- * amb_context_code is DEFAULT
            -- * reference_date must be null
            -- * balance_type_code:
            --     A: Actual
            --     B: Budget
            --     E: Encumbrance
            -- * gl_transfer_status_code:
            --     Y: already transferred to GL
            --     N: not transferred to GL
            -- * gl_transfer_date is date entry transferred to GL
            -- * accounting_entry_status_code must be F
            -- * accounting_entry_type_code must be STANDARD
            -- * product_rule_* not relevant for upgrade

               insert into xla_ae_headers (
                  upg_batch_id,
                  application_id,
                  amb_context_code,
                  entity_id,
                  event_id,
                  event_type_code,
                  ae_header_id,
                  ledger_id,
                  accounting_date,
                  period_name,
                  reference_date,
                  balance_type_code,
                  je_category_name,
                  gl_transfer_status_code,
                  gl_transfer_date,
                  accounting_entry_status_code,
                  accounting_entry_type_code,
                  description,
                  budget_version_id,
                  funds_status_code,
                  encumbrance_type_id,
                  completed_date,
                  doc_sequence_id,
                  doc_sequence_value,
                  doc_category_code,
                  packet_id,
                  group_id,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  program_id,
                  program_application_id,
                  program_update_date,
                  request_id,
                  close_acct_seq_assign_id,
                  close_acct_seq_version_id,
                  close_acct_seq_value,
                  completion_acct_seq_assign_id,
                  completion_acct_seq_version_id,
                  completion_acct_seq_value,
                  accounting_batch_id,
                  product_rule_type_code,
                  product_rule_code,
                  product_rule_version,
                  upg_source_application_id,
                  upg_valid_flag
               ) values (
                  l_upg_batch_id,               -- upg_batch_id
                  c_application_id,             -- application_id
                  c_amb_context_code,           -- amb_context_code
                  l_entity_id_tbl(i),           -- entity_id
                  l_event_id_tbl(i),            -- event_id,
                  l_event_class_code_tbl(i),    -- event_type_code
                  l_ae_header_id,               -- ae_header_id,
                  l_rep_set_of_books_id_tbl(k), -- ledger_id/sob_id
                  l_cal_period_close_date_tbl(i),
                                                -- accounting_date,
                  l_period_name_tbl(i),         -- period_name,
                  null,                         -- reference_date
                  'A',                          -- balance_type_code,
                  l_je_category_name_tbl(i),    -- je_category_name
                  l_gl_transfer_status_code_tbl(1),  -- Bug 6811554
                                                -- gl_transfer_status_code
                  null,                         -- gl_transfer_date
                  'F',                          -- accounting_entry_status_code
                  'STANDARD',                   -- accounting_entry_type_code
                  l_src_hdr_desc_tbl(i),        -- description
                  null,                         -- budget_version_id
                  null,                         -- funds_status_code
                  null,                         -- encumbrance_type_id
                  null,                         -- completed_date
                  null,                         -- doc_sequence_id
                  null,                         -- doc_sequence_value
                  null,                         -- doc_category_code
                  null,                         -- packet_id,
                  null,                         -- group_id
                  sysdate,                      -- creation_date
                  c_fnd_user,                   -- created_by
                  sysdate,                      -- last_update_date
                  c_fnd_user,                   -- last_updated_by
                  c_upgrade_bugno,              -- last_update_login
                  null,                         -- program_id
                  c_application_id,             -- program_application_id
                  sysdate,                      -- program_update_date
                  null,                         -- request_id
                  null,                         -- close_acct_seq_assign_id
                  null,                         -- close_acct_seq_version_id
                  null,                         -- close_acct_seq_value
                  null,                         -- compl_acct_seq_assign_id
                  null,                         -- compl_acct_seq_version_id
                  null,                         -- compl_acct_seq_value
                  null,                         -- accounting_batch_id
                  null,                         -- product_rule_type_code
                  null,                         -- product_rule_code
                  null,                         -- product_rule_version
                  c_application_id,             -- upg_souce_application_id
                  null                          -- upg_valid_flag
               );

            -- Business Rules for xla_ae_lines
            -- * gl_transfer_mode_code:
            --       D: Detailed mode when transferred to GL
            --       S: Summary mode when transferred to GL
            -- * gl_sl_link_table must be XLAJEL
            -- * currency_conversion_* needs to be populated only if
            --   different from ledger currency

            forall j IN 1..l_xla_gl_sl_link_id_tbl.count
            insert into xla_ae_lines (
                  upg_batch_id,
                  ae_header_id,
                  ae_line_num,
                  displayed_line_number,
                  application_id,
                  code_combination_id,
                  gl_transfer_mode_code,
                  accounted_dr,
                  accounted_cr,
                  currency_code,
                  currency_conversion_date,
                  currency_conversion_rate,
                  currency_conversion_type,
                  entered_dr,
                  entered_cr,
                  description,
                  accounting_class_code,
                  gl_sl_link_id,
                  gl_sl_link_table,
                  party_type_code,
                  party_id,
                  party_site_id,
                  statistical_amount,
                  ussgl_transaction_code,
                  jgzz_recon_ref,
                  control_balance_flag,
                  analytical_balance_flag,
                  upg_tax_reference_id1,
                  upg_tax_reference_id2,
                  upg_tax_reference_id3,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  program_update_date,
                  program_id,
                  program_application_id,
                  request_id,
                  gain_or_loss_flag,
                  accounting_date,
                  ledger_id
            ) values (
                  l_upg_batch_id,                 -- upg_batch_id
                  l_ae_header_id,                 -- ae_header_id
                  l_ae_line_num_tbl(j),           -- ae_line_num
                  l_ae_line_num_tbl(j),           -- displayed_line_num
                  c_application_id,               -- application_id
                  l_ccid_tbl(j),                  -- code_combination_id
                  'S',                            -- gl_transfer_mode_code
                  l_debit_amount_tbl(j),          -- accounted_dr
                  l_credit_amount_tbl(j),         -- accounted_cr
                  l_currency_code_tbl(j),         -- currency_code
                  null,                           -- currency_conversion_date
                  null,                           -- currency_conversion_rate
                  null,                           -- currency_conversion_type
                  l_debit_amount_tbl(j),          -- entered_dr
                  l_credit_amount_tbl(j),         -- entered_cr
                  l_line_desc_tbl(j) || ' - ' ||
                     to_char(l_cal_period_close_date_tbl(i), 'DD-MON-RR'),
                                                  -- description
                  l_acct_class_code_tbl(j),       -- accounting_class_code
                  l_xla_gl_sl_link_id_tbl(j),     -- gl_sl_link_id
                  'XLAJEL',                       -- gl_sl_link_table
                  null,                           -- party_type_code
                  null,                           -- party_id
                  null,                           -- party_site_id
                  null,                           -- statistical_amount
                  null,                           -- ussgl_transaction_code
                  null,                           -- glzz_recon_ref
                  null,                           -- control_balance_flag
                  null,                           -- analytical_balance_flag
                  null,                           -- upg_tax_reference_id1
                  null,                           -- upg_tax_reference_id2
                  null,                           -- upg_tax_reference_id3
                  sysdate,                        -- creation_date
                  c_fnd_user,                     -- created_by
                  sysdate,                        -- last_update_date
                  c_fnd_user,                     -- last_updated_by
                  c_upgrade_bugno,                -- last_update_login
                  null,                           -- program_update_date
                  null,                           -- program_id
                  c_application_id,               -- program_application_id
                  null,                           -- request_id
                  'N',                            -- gain_or_loss_flag
                  l_cal_period_close_date_tbl(i), -- accounting_date,
                  l_rep_set_of_books_id_tbl(k)    -- ledger_id/sob_id
            );

            -- Business Rules for xla_distribution_links
            -- * accounting_line_code is similar to adjustment_type
            -- * accounting_line_type_code is S
            -- * merge_duplicate_code is N
            -- * source_distribution_type is TRX
            -- * source_distribution_id_num_1 is trx_reference_id
            -- * source_distribution_id_num_2 is event_id

            forall j IN 1..l_xla_gl_sl_link_id_tbl.count
            insert into xla_distribution_links (
                  upg_batch_id,
                  application_id,
                  event_id,
                  ae_header_id,
                  ae_line_num,
                  accounting_line_code,
                  accounting_line_type_code,
                  source_distribution_type,
                  source_distribution_id_char_1,
                  source_distribution_id_char_2,
                  source_distribution_id_char_3,
                  source_distribution_id_char_4,
                  source_distribution_id_char_5,
                  source_distribution_id_num_1,
                  source_distribution_id_num_2,
                  source_distribution_id_num_3,
                  source_distribution_id_num_4,
                  source_distribution_id_num_5,
                  merge_duplicate_code,
                  statistical_amount,
                  unrounded_entered_dr,
                  unrounded_entered_cr,
                  unrounded_accounted_dr,
                  unrounded_accounted_cr,
                  ref_ae_header_id,
                  ref_temp_line_num,
                  ref_event_id,
                  temp_line_num,
                  tax_line_ref_id,
                  tax_summary_line_ref_id,
                  tax_rec_nrec_dist_ref_id,
                  line_definition_owner_code,
                  line_definition_code,
                  event_class_code,
                  event_type_code
            ) values (
                  l_upg_batch_id,              -- upg_batch_id
                  c_application_id,            -- application_id
                  l_event_id_tbl(i),           -- event_id
                  l_ae_header_id,              -- ae_header_id
                  l_ae_line_num_tbl(j),        -- ae_line_num
                  null,                        -- accounting_line_code
                  'S',                         -- accounting_line_type_code
                  'TRX',                       -- source_distribution_type
                  null,                        -- source_distribution_id_char_1
                  null,                        -- source_distribution_id_char_2
                  null,                        -- source_distribution_id_char_3
                  null,                        -- source_distribution_id_char_4

                  null,                        -- source_distribution_id_char_5
                  l_adj_thid_tbl(j),           -- Bug 6827893
                                               -- source_distribution_id_num_1
                  l_adj_line_id_tbl(j),        -- source_distribution_id_num_2
                  null,                        -- source_distribution_id_num_3
                  null,                        -- source_distribution_id_num_4
                  null,                        -- source_distribution_id_num_5
                  'N',                         -- merge_duplicate_code
                  null,                        -- statistical_amount
                  l_debit_amount_tbl(j),       -- unrounded_entered_dr
                  l_credit_amount_tbl(j),      -- unrounded_entered_cr
                  l_debit_amount_tbl(j),       -- unrounded_accounted_dr
                  l_credit_amount_tbl(j),      -- unrounded_accounted_cr
                  l_ae_header_id,              -- ref_ae_header_id
                  null,                        -- ref_temp_line_num
                  null,                        -- ref_event_id
                  l_ae_line_num_tbl(j),        -- temp_line_num
                  null,                        -- tax_line_ref_id
                  null,                        -- tax_summary_line_ref_id
                  null,                        -- tax_rec_nrec_dist_ref_id
                  null,                        -- line_definition_owner_code
                  null,                        -- line_definition_code
                  l_event_class_code_tbl(i),   -- event_class_code
                  l_event_class_code_tbl(i)    -- event_type_code
            );

            for j IN 1..l_xla_gl_sl_link_id_tbl.count loop
               if (l_je_batch_id_tbl(j) is not null) then
                  insert into gl_import_references (
                     je_batch_id,
                     je_header_id,
                     je_line_num,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     reference_1,
                     reference_2,
                     reference_3,
                     reference_4,
                     reference_5,
                     reference_6,
                     reference_7,
                     reference_8,
                     reference_9,
                     reference_10,
                     subledger_doc_sequence_id,
                     subledger_doc_sequence_value,
                     gl_sl_link_id,
                     gl_sl_link_table
                  ) values (
                     l_je_batch_id_tbl(j),        -- je_batch_id
                     l_je_header_id_tbl(j),       -- je_header_id
                     l_je_line_num_tbl(j),        -- je_line_num
                     sysdate,                     -- last_update_date
                     c_fnd_user,                  -- last_updated_by
                     sysdate,                     -- creation_date
                     c_fnd_user,                  -- created_by
                     c_upgrade_bugno,             -- last_update_login
                     to_char(l_src_thid_tbl(i)),
                                                  -- reference_1
                     to_char(l_src_asset_id_tbl(i)),
                                                  -- reference_2
                     to_char(l_distribution_id_tbl(j)),
                                                  -- reference_3
                     to_char(l_adj_line_id_tbl(j)),
                                                  -- reference_4
                     l_book_type_code_tbl(i),     -- reference_5
                     to_char(l_period_counter_tbl(i)),
                                                  -- reference_6
                     null,                        -- reference_7
                     null,                        -- reference_8
                     null,                        -- reference_9
                     null,                        -- reference_10
                     null,                        -- subledger_doc_seq_id
                     null,                        -- subledger_doc_seq_value
                     l_xla_gl_sl_link_id_tbl(j),  -- gl_sl_link_id
                     'XLAJEL'                     -- gl_sl_link_table
                  );
               end if;
            end loop;

            l_adj_line_id_tbl.delete;
            l_xla_gl_sl_link_id_tbl.delete;
            l_ae_line_num_tbl.delete;
            l_debit_amount_tbl.delete;
            l_credit_amount_tbl.delete;
            l_ccid_tbl.delete;
            l_acct_class_code_tbl.delete;
            l_currency_code_tbl.delete;
            l_line_def_owner_code_tbl.delete;
            l_line_def_code_tbl.delete;
            l_line_desc_tbl.delete;
            l_gl_transfer_status_code_tbl.delete;
            l_je_batch_id_tbl.delete;
            l_je_header_id_tbl.delete;
            l_je_line_num_tbl.delete;
            l_distribution_id_tbl.delete;

            end loop;

            l_rep_set_of_books_id_tbl.delete;
            l_line_num_tbl.delete;     -- Bug 6827893
            l_ae_header_id_tbl.delete; -- Bug 6827893

      END LOOP;

      l_src_rowid_tbl.delete;
      l_dest_rowid_tbl.delete;
      l_event_id_tbl.delete;
      l_src_asset_id_tbl.delete;
      l_dest_asset_id_tbl.delete;
      l_book_type_code_tbl.delete;
      l_primary_set_of_books_id_tbl.delete;
      l_org_id_tbl.delete;
      l_src_trans_type_code_tbl.delete;
      l_dest_trans_type_code_tbl.delete;
      l_transaction_date_entered_tbl.delete;
      l_src_thid_tbl.delete;
      l_dest_thid_tbl.delete;
      l_period_counter_tbl.delete;
      l_period_name_tbl.delete;
      l_cal_period_close_date_tbl.delete;
      l_entity_id_tbl.delete;
      l_event_class_code_tbl.delete;
      l_trx_reference_id_tbl.delete;
      l_src_hdr_desc_tbl.delete;
      l_dest_hdr_desc_tbl.delete;
      l_je_category_name_tbl.delete;
      l_date_effective_tbl.delete;

      commit;

      if (l_rows_processed < l_batch_size) then exit; end if;

   end loop;
   close c_trans;

EXCEPTION
   WHEN OTHERS THEN
      rollback;
      raise;

END Upgrade_Inv_Events;

Procedure Upgrade_Group_Trxn_Events (
             p_start_rowid             IN            rowid,
             p_end_rowid               IN            rowid,
             p_batch_size              IN            number,
             x_success_count              OUT NOCOPY number,
             x_failure_count              OUT NOCOPY number,
             x_return_status              OUT NOCOPY number
            ) IS

   c_application_id            constant number(15) := 140;
   c_upgrade_bugno             constant number(15) := -4107161;
   c_fnd_user                  constant number(15) := 2;

   c_entity_code               constant varchar2(30) := 'TRANSACTIONS';
   c_amb_context_code          constant varchar2(30) := 'DEFAULT';

   -- this value can be altered in order to process more of less per batch
   l_batch_size                NUMBER;

   l_rows_processed            NUMBER;

   -- type for table variable
   type num_tbl_type  is table of number        index by binary_integer;
   type char_tbl_type is table of varchar2(150) index by binary_integer;
   type date_tbl_type is table of date          index by binary_integer;
   type rowid_tbl_type is table of rowid        index by binary_integer;

   -- used for bulk fetching
   -- main cursor
   l_event_id_tbl                               num_tbl_type;
   l_asset_id_tbl                               num_tbl_type;
   l_book_type_code_tbl                         char_tbl_type;
   l_primary_set_of_books_id_tbl                num_tbl_type;
   l_org_id_tbl                                 num_tbl_type;
   l_transaction_type_code_tbl                  char_tbl_type;
   l_transaction_date_entered_tbl               date_tbl_type;
   l_transaction_header_id_tbl                  num_tbl_type;
   l_period_counter_tbl                         num_tbl_type;
   l_period_name_tbl                            char_tbl_type;
   l_cal_period_close_date_tbl                  date_tbl_type;
   l_rowid_tbl                                  rowid_tbl_type;
   l_member_thid_tbl                            num_tbl_type;

   l_upg_batch_id                               number;
   l_ae_header_id                               number;

   l_entity_id_tbl                              num_tbl_type;
   l_event_class_code_tbl                       char_tbl_type;
   l_rep_set_of_books_id_tbl                    num_tbl_type;
   l_currency_code_tbl                          char_tbl_type;
   l_hdr_desc_tbl                               char_tbl_type;
   l_je_category_name_tbl                       char_tbl_type;
   l_date_effective_tbl                         date_tbl_type;

   l_adj_line_id_tbl                            num_tbl_type;
   l_xla_gl_sl_link_id_tbl                      num_tbl_type;
   l_ae_line_num_tbl                            num_tbl_type;
   l_debit_amount_tbl                           num_tbl_type;
   l_credit_amount_tbl                          num_tbl_type;
   l_ccid_tbl                                   num_tbl_type;
   l_acct_class_code_tbl                        char_tbl_type;
   l_line_def_owner_code_tbl                    char_tbl_type;
   l_line_def_code_tbl                          char_tbl_type;
   l_line_desc_tbl                              char_tbl_type;
   l_gl_transfer_status_code_tbl                char_tbl_type;
   l_je_batch_id_tbl                            num_tbl_type;
   l_je_header_id_tbl                           num_tbl_type;
   l_je_line_num_tbl                            num_tbl_type;
   l_distribution_id_tbl                        num_tbl_type;

   l_error_level_tbl                            char_tbl_type;
   l_err_entity_id_tbl                          num_tbl_type;
   l_err_event_id_tbl                           num_tbl_type;
   l_err_ae_header_id_tbl                       num_tbl_type;
   l_err_ae_line_num_tbl                        num_tbl_type;
   l_err_temp_line_num_tbl                      num_tbl_type;
   l_error_message_name_tbl                     char_tbl_type;

   CURSOR c_trans IS
      select /*+ leading(th) rowid(th) */
             th.asset_id,
             th.book_type_code,
             bc.set_of_books_id,
             bc.org_id,
             th.transaction_type_code,
             th.transaction_date_entered,
             th.transaction_header_id,
             th.rowid,
             decode(th.transaction_type_code,
                'ADDITION', decode (ah.asset_type,
                                    'CIP', 'CAPITALIZATIONS',
                                    'ADDITIONS'),
                'ADJUSTMENT', 'ADJUSTMENTS',
                'CIP ADDITION', 'CIP_ADDITIONS',
                'CIP ADJUSTMENT', 'CIP_ADJUSTMENTS',
                'CIP REVERSE', 'REVERSE CAPITALIZATIONS',
                'CIP REINSTATEMENT', 'CIP_REINSTATEMENTS',
                'CIP RETIREMENT', 'CIP_RETIREMENTS',
                'CIP TRANSFER', 'CIP_TRANSFERS',
                'CIP UNIT ADJUSTMENTS', 'CIP_UNIT_ADJUSTMENTS',
                'FULL RETIREMENT', 'RETIREMENTS',
                'PARTIAL RETIREMENT', 'RETIREMENTS',
                'RECLASS', 'CATEGORY_RECLASS',
                'REINSTATEMENT', 'REINSTATEMENTS',
                'REVALUATION', 'REVALUATION',
                'TRANSFER', 'TRANSFERS',
                'TRANSFER IN', 'TRANSFERS',
                'TRANSFER IN/VOID', 'TRANSFERS',
                'TRANSFER OUT', 'TRANSFERS',
                'UNIT ADJUSTMENT', 'UNIT_ADJUSTMENTS',
                'UNPLANNED DEPRN', 'UNPLANNED_DEPRECIATION',
                'TAX', 'DEPRECIATION_ADJUSTMENTS',
                'OTHER'
             ) event_class_code,
             dp.period_name,
             dp.period_counter,
             dp.calendar_period_close_date,
             th.member_transaction_header_id,
             lk.description || ' - ' ||
                to_char(dp.calendar_period_close_date, 'DD-MON-RR'),
             nvl (decode(th.transaction_type_code,
                'ADDITION',             bc.je_addition_category,
                'ADJUSTMENT',           bc.je_adjustment_category,
                'CIP ADDITION',         bc.je_cip_addition_category,
                'CIP ADJUSTMENT',       bc.je_cip_adjustment_category,
                'CIP REVERSE',          bc.je_cip_addition_category,
                'CIP REINSTATEMENT',    bc.je_cip_retirement_category,
                'CIP RETIREMENT',       bc.je_cip_retirement_category,
                'CIP TRANSFER',         bc.je_cip_transfer_category,
                'CIP UNIT ADJUSTMENTS', bc.je_cip_transfer_category,
                'FULL RETIREMENT',      bc.je_retirement_category,
                'PARTIAL RETIREMENT',   bc.je_retirement_category,
                'RECLASS',              bc.je_reclass_category,
                'REINSTATEMENT',        bc.je_retirement_category,
                'REVALUATION',          bc.je_reval_category,
                'TRANSFER',             bc.je_transfer_category,
                'TRANSFER IN',          bc.je_transfer_category,
                'TRANSFER IN/VOID',     bc.je_transfer_category,
                'TRANSFER OUT',         bc.je_transfer_category,
                'UNIT ADJUSTMENT',      bc.je_transfer_category,
                'UNPLANNED DEPRN',      bc.je_depreciation_category,
                'TAX',                  bc.je_deprn_adjustment_category
             ), 'OTHER') je_category_name,
             th.date_effective
      from   fa_transaction_headers th,
             fa_asset_history ah,
             fa_deprn_periods dp,
             gl_sets_of_books glsob,
             fa_book_controls bc,
             fa_lookups_tl lk,
             gl_period_statuses ps
      where  th.rowid between p_start_rowid and p_end_rowid
      and    ps.application_id = 101
      and    ((ps.migration_status_code in ('P', 'U')) or
              (dp.period_close_date is null))
      and    substr(dp.xla_conversion_status, 1, 1) in
             ('H', 'U', 'E', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
      and    dp.xla_conversion_status not in ('UT', 'UA')
      and    ps.set_of_books_id = bc.set_of_books_id
      and    ps.period_name = dp.period_name
      and    th.book_type_code = bc.book_type_code
      and    bc.allow_group_deprn_flag = 'Y'
      and    bc.set_of_books_id = glsob.set_of_books_id
      and    dp.book_type_code = bc.book_type_code
      and    th.book_type_code = bc.book_type_code
      and    th.date_effective between
                dp.period_open_date and nvl(dp.period_close_date, sysdate)
      and    th.member_transaction_header_id is not null
      and    th.transaction_subtype not in ('GA', 'M%', 'GC', 'GV')
      and    th.asset_id = ah.asset_id (+)
      and    th.transaction_header_id = ah.transaction_header_id_out (+)
      and    th.event_id is null
      and    th.transaction_type_code = lk.lookup_code
      and    lk.lookup_type = 'FAXOLTRX'
      and    userenv('LANG') = lk.language
      and exists
      (
       select 'x'
       from   fa_adjustments adj
       where  th.transaction_header_id = adj.transaction_header_id
       and    th.book_type_code = adj.book_type_code
       and    th.asset_id = adj.asset_id
      )
   UNION ALL
      select /*+ leading(th) rowid(th) */
             th.asset_id,
             th.book_type_code,
             bc.set_of_books_id,
             bc.org_id,
             th.transaction_type_code,
             dp.calendar_period_close_date,
             th.transaction_header_id,
             th.rowid,
             decode(th.transaction_type_code,
                'CIP TRANSFER', 'CIP_TRANSFERS',
                'CIP UNIT ADJUSTMENTS', 'CIP_UNIT_ADJUSTMENTS',
                'CIP REINSTATEMENT', 'CIP_TRANSFERS',
                'RECLASS', 'CATEGORY_RECLASS',
                'REINSTATEMENT', 'REINSTATEMENTS',
                'TRANSFER', 'TRANSFERS',
                'TRANSFER OUT', 'TRANSFERS',
                'UNIT ADJUSTMENT', 'UNIT_ADJUSTMENTS',
                'OTHER'
             ) event_class_code,
             dp.period_name,
             dp.period_counter,
             dp.calendar_period_close_date,
             th.member_transaction_header_id,
             lk.description || ' - ' ||
                to_char(dp.calendar_period_close_date, 'DD-MON-RR'),
             nvl (decode(th.transaction_type_code,
                'CIP REINSTATEMENT',    bc.je_cip_transfer_category,
                'CIP TRANSFER',         bc.je_cip_transfer_category,
                'CIP UNIT ADJUSTMENTS', bc.je_cip_transfer_category,
                'RECLASS',              bc.je_reclass_category,
                'REINSTATEMENT',        bc.je_transfer_category,
                'TRANSFER',             bc.je_transfer_category,
                'TRANSFER OUT',         bc.je_transfer_category,
                'UNIT ADJUSTMENT',      bc.je_transfer_category),
                'OTHER') je_category_name,
             th.date_effective
      from   fa_transaction_headers th,
             fa_deprn_periods dp,
             gl_sets_of_books glsob,
             fa_book_controls bc,
             fa_lookups_tl lk,
             gl_period_statuses ps
      where  th.rowid between p_start_rowid and p_end_rowid
      and    ps.application_id = 101
      and    ((ps.migration_status_code in ('P', 'U')) or
              (dp.period_close_date is null))
      and    substr(dp.xla_conversion_status, 1, 1) in
             ('H', 'U', 'E', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
      and    dp.xla_conversion_status not in ('UT', 'UA')
      and    ps.set_of_books_id = bc.set_of_books_id
      and    ps.period_name = dp.period_name
      and    th.transaction_type_code in ('TRANSFER', 'TRANSFER OUT',
                   'RECLASS', 'UNIT ADJUSTMENT', 'REINSTATEMENT',
                   'CIP REINSTATEMENT', 'CIP TRANSFER', 'CIP UNIT ADJUSTMENTS')
      and    th.book_type_code = bc.distribution_source_book
      and    bc.book_class = 'TAX'
      and    bc.allow_group_deprn_flag = 'Y'
      and    bc.set_of_books_id = glsob.set_of_books_id
      and    dp.book_type_code = bc.book_type_code
      and    th.date_effective between
                dp.period_open_date and nvl(dp.period_close_date, sysdate)
      and    th.member_transaction_header_id is not null
      and    th.transaction_subtype not in ('GA', 'M%', 'GC', 'GV')
      and    th.event_id is null
      and    th.transaction_type_code = lk.lookup_code
      and    lk.lookup_type = 'FAXOLTRX'
      and    userenv('LANG') = lk.language
      and exists
      (
       select 'x'
       from   fa_adjustments adj
       where  th.transaction_header_id = adj.transaction_header_id
       and    bc.book_type_code = adj.book_type_code
       and    th.asset_id = adj.asset_id
      );

   -- Bug 6827893 : Added outerjoin between DD and gljh
   --               Corrected the Reserve row (second union)
   CURSOR c_adj (l_book_type_code        varchar2,
                 l_asset_id              number,
                 l_transaction_header_id number,
                 l_date_effective        date) IS
      select adj.adjustment_line_id,
             decode (adj.debit_credit_flag,
                     'DR', adj.adjustment_amount, null),
             decode (adj.debit_credit_flag,
                     'CR', adj.adjustment_amount, null),
             adj.code_combination_id,
             glsob.currency_code,
             decode (adj.adjustment_type,
                'BONUS EXPENSE', 'EXPENSE',
                'BONUS RESERVE', 'ASSET',
                'CIP COST', 'ASSET',
                'COST', 'ASSET',
                'COST CLEARING', 'ASSET',
                'DEPRN ADJUST', 'EXPENSE',
                'EXPENSE', 'EXPENSE',
                'GRP COR RESERVE', 'ASSET',
                'GRP PRC RESERVE', 'ASSET',
                'INTERCO AP', 'LIABILITY',
                'INTERCO AR', 'ASSET',
                'NBV RETIRED', 'ASSET',
                'PROCEEDS', 'ASSET',
                'PROCEEDS CLR', 'ASSET',
                'REMOVALCOST', 'ASSET',
                'REMOVALCOST CLR', 'ASSET',
                'RESERVE', 'ASSET',
                'REVAL RESERVE', 'ASSET',
                'REVAL RSV RET', 'ASSET',
                'REVAL AMORT', 'EXPENSE',
                'REVAL EXPENSE', 'EXPENSE',
                'ASSET'),
             lk.description,
             decode (adj.je_header_id, null, 'N', 'Y'),
             gljh.je_batch_id,
             adj.je_header_id,
             nvl(adj.je_line_num, 0),
             adj.distribution_id
      from   fa_adjustments adj,
             fa_lookups_tl lk,
             gl_je_headers gljh,
             fa_book_controls bc,
             gl_sets_of_books glsob
      where  bc.book_type_code = l_book_type_code
      and    bc.set_of_books_id = glsob.set_of_books_id
      and    bc.book_type_code = adj.book_type_code
      and    adj.asset_id = l_asset_id
      and    adj.transaction_header_id = l_transaction_header_id
      and    adj.code_combination_id is not null
      and    nvl(adj.track_member_flag, 'N') = 'N'
      and    lk.lookup_type = 'JOURNAL ENTRIES'
      and    lk.lookup_code = decode (adj.adjustment_type,
                              'BONUS EXPENSE', 'BONUS DEPRECIATION EXPENSE',
                              'BONUS RESERVE', 'BONUS DEPRECIATION RESERVE',
                              'CIP COST', adj.source_type_code ||' COST',
                              adj.source_type_code ||' '|| adj.adjustment_type)
      and    userenv('LANG') = lk.language
      and    adj.je_header_id = gljh.je_header_id (+)
   UNION ALL
      select adj.adjustment_line_id,
             decode (adj.debit_credit_flag,
                     'CR', adj.adjustment_amount, null),
             decode (adj.debit_credit_flag,
                     'DR', adj.adjustment_amount, null),
             nvl(nvl(gljl.code_combination_id, da.deprn_reserve_account_ccid),
                 cb.reserve_account_ccid),
             glsob.currency_code,
             decode (adj.adjustment_type,
                'BONUS EXPENSE', 'EXPENSE',
                'BONUS RESERVE', 'ASSET',
                'CIP COST', 'ASSET',
                'COST', 'ASSET',
                'COST CLEARING', 'ASSET',
                'DEPRN ADJUST', 'EXPENSE',
                'EXPENSE', 'ASSET',
                'GRP COR RESERVE', 'ASSET',
                'GRP PRC RESERVE', 'ASSET',
                'INTERCO AP', 'LIABILITY',
                'INTERCO AR', 'ASSET',
                'NBV RETIRED', 'ASSET',
                'PROCEEDS', 'ASSET',
                'PROCEEDS CLR', 'ASSET',
                'REMOVALCOST', 'ASSET',
                'REMOVALCOST CLR', 'ASSET',
                'RESERVE', 'ASSET',
                'REVAL RESERVE', 'ASSET',
                'REVAL RSV RET', 'ASSET',
                'REVAL AMORT', 'EXPENSE',
                'REVAL EXPENSE', 'EXPENSE',
                'ASSET'),
             lk.description,
             decode (dd.je_header_id, null, 'N', 'Y'),
             gljh.je_batch_id,
             dd.je_header_id,
             nvl(dd.deprn_reserve_je_line_num, 0),
             adj.distribution_id
      from   fa_adjustments adj,
             gl_sets_of_books glsob,
             fa_book_controls bc,
             fa_lookups_tl lk,
             gl_je_headers gljh,
             fa_deprn_detail dd,
             gl_je_lines gljl,
             fa_distribution_accounts da,
             fa_asset_history ah,
             fa_category_books cb
      where  bc.book_type_code = l_book_type_code
      and    bc.set_of_books_id = glsob.set_of_books_id
      and    bc.book_type_code = adj.book_type_code
      and    adj.asset_id = l_asset_id
      and    adj.transaction_header_id = l_transaction_header_id
      and    adj.adjustment_type = 'EXPENSE'
      and    adj.source_type_code in ('DEPRECIATION', 'CIP RETIREMENT',
                                      'RETIREMENT')
      and    adj.code_combination_id is not null
      and    nvl(adj.track_member_flag, 'N') = 'N'
      and    lk.lookup_type = 'JOURNAL ENTRIES'
      and    lk.lookup_code = adj.source_type_code ||' RESERVE'
      and    userenv('LANG') = lk.language
      and    adj.asset_id = dd.asset_id (+)
      and    adj.book_type_code = dd.book_type_code (+)
      and    adj.distribution_id = dd.distribution_id (+)
      and    adj.period_counter_created = dd.period_counter (+)
      and    dd.je_header_id = gljl.je_header_id (+)
      and    dd.deprn_reserve_je_line_num = gljl.je_line_num (+)
      and    dd.je_header_id = gljh.je_header_id (+)
      and    adj.book_type_code = da.book_type_code (+)
      and    adj.distribution_id = da.distribution_id (+)
      and    adj.asset_id = ah.asset_id
      and    l_date_effective >= ah.date_effective
      and    l_date_effective < nvl(ah.date_ineffective, sysdate+1)
      and    ah.category_id = cb.category_id
      and    bc.book_type_code = cb.book_type_code
   UNION ALL
      select adj.adjustment_line_id,
             decode (adj.debit_credit_flag,
                     'DR', adj.adjustment_amount, null),
             decode (adj.debit_credit_flag,
                     'CR', adj.adjustment_amount, null),
             nvl(nvl(gljl.code_combination_id, da.deprn_reserve_account_ccid),
                 cb.reserve_account_ccid),
             glsob.currency_code,
             decode (adj.adjustment_type,
                'BONUS EXPENSE', 'EXPENSE',
                'BONUS RESERVE', 'ASSET',
                'CIP COST', 'ASSET',
                'COST', 'ASSET',
                'COST CLEARING', 'ASSET',
                'DEPRN ADJUST', 'EXPENSE',
                'EXPENSE', 'EXPENSE',
                'GRP COR RESERVE', 'ASSET',
                'GRP PRC RESERVE', 'ASSET',
                'INTERCO AP', 'LIABILITY',
                'INTERCO AR', 'ASSET',
                'NBV RETIRED', 'ASSET',
                'PROCEEDS', 'ASSET',
                'PROCEEDS CLR', 'ASSET',
                'REMOVALCOST', 'ASSET',
                'REMOVALCOST CLR', 'ASSET',
                'RESERVE', 'ASSET',
                'REVAL RESERVE', 'ASSET',
                'REVAL RSV RET', 'ASSET',
                'REVAL AMORT', 'EXPENSE',
                'REVAL EXPENSE', 'EXPENSE',
                'ASSET'),
             lk.description,
             decode (dd.je_header_id, null, 'N', 'Y'),
             gljh.je_batch_id,
             dd.je_header_id,
             nvl(dd.deprn_reserve_je_line_num, 0),
             adj.distribution_id
      from   fa_adjustments adj,
             gl_sets_of_books glsob,
             fa_book_controls bc,
             fa_lookups_tl lk,
             gl_je_headers gljh,
             fa_deprn_detail dd,
             gl_je_lines gljl,
             fa_distribution_accounts da,
             fa_asset_history ah,
             fa_category_books cb
      where  bc.book_type_code = l_book_type_code
      and    bc.set_of_books_id = glsob.set_of_books_id
      and    bc.book_type_code = adj.book_type_code
      and    adj.asset_id = l_asset_id
      and    adj.transaction_header_id = l_transaction_header_id
      and    adj.adjustment_type = 'BONUS EXPENSE'
      and    adj.source_type_code = 'DEPRECIATION'
      and    adj.code_combination_id is not null
      and    nvl(adj.track_member_flag, 'N') = 'N'
      and    lk.lookup_type = 'JOURNAL ENTRIES'
      and    lk.lookup_code = 'BONUS DEPRECIATION RESERVE'
      and    userenv('LANG') = lk.language
      and    adj.asset_id = dd.asset_id (+)
      and    adj.book_type_code = dd.book_type_code (+)
      and    adj.distribution_id = dd.distribution_id (+)
      and    adj.period_counter_created = dd.period_counter (+)
      and    dd.je_header_id = gljl.je_header_id (+)
      and    dd.bonus_deprn_rsv_je_line_num = gljl.je_line_num (+)
      and    dd.je_header_id = gljh.je_header_id (+)
      and    adj.book_type_code = da.book_type_code (+)
      and    adj.distribution_id = da.distribution_id (+)
      and    adj.asset_id = ah.asset_id
      and    l_date_effective >= ah.date_effective
      and    l_date_effective < nvl(ah.date_ineffective, sysdate+1)
      and    ah.category_id = cb.category_id
      and    bc.book_type_code = cb.book_type_code;

   CURSOR c_mc_books (l_book_type_code      varchar2) IS
   select set_of_books_id
     from fa_mc_book_controls
    where book_type_code = l_book_type_code
      and enabled_flag = 'Y';

   -- Bug 6827893 : Added outerjoin between DD and gljh
   --               Corrected the Reserve row (second union)
   CURSOR c_mc_adj (l_book_type_code        varchar2,
                    l_asset_id              number,
                    l_set_of_books_id       number,
                    l_transaction_header_id number,
                    l_date_effective        date) IS
      select adj.adjustment_line_id,
             decode (adj.debit_credit_flag,
                     'DR', adj.adjustment_amount, null),
             decode (adj.debit_credit_flag,
                     'CR', adj.adjustment_amount, null),
             adj.code_combination_id,
             glsob.currency_code,
             decode (adj.adjustment_type,
                'BONUS EXPENSE', 'EXPENSE',
                'BONUS RESERVE', 'ASSET',
                'CIP COST', 'ASSET',
                'COST', 'ASSET',
                'COST CLEARING', 'ASSET',
                'DEPRN ADJUST', 'EXPENSE',
                'EXPENSE', 'EXPENSE',
                'GRP COR RESERVE', 'ASSET',
                'GRP PRC RESERVE', 'ASSET',
                'INTERCO AP', 'LIABILITY',
                'INTERCO AR', 'ASSET',
                'NBV RETIRED', 'ASSET',
                'PROCEEDS', 'ASSET',
                'PROCEEDS CLR', 'ASSET',
                'REMOVALCOST', 'ASSET',
                'REMOVALCOST CLR', 'ASSET',
                'RESERVE', 'ASSET',
                'REVAL RESERVE', 'ASSET',
                'REVAL RSV RET', 'ASSET',
                'REVAL AMORT', 'EXPENSE',
                'REVAL EXPENSE', 'EXPENSE',
                'ASSET'),
             lk.description,
             decode (adj.je_header_id, null, 'N', 'Y'),
             gljh.je_batch_id,
             adj.je_header_id,
             nvl(adj.je_line_num, 0),
             adj.distribution_id
      from   fa_mc_adjustments adj,
             fa_lookups_tl lk,
             gl_je_headers gljh,
             fa_mc_book_controls bc,
             gl_sets_of_books glsob
      where  bc.book_type_code = l_book_type_code
      and    bc.set_of_books_id = l_set_of_books_id
      and    bc.enabled_flag = 'Y'
      and    bc.set_of_books_id = glsob.set_of_books_id
      and    bc.book_type_code = adj.book_type_code
      and    bc.set_of_books_id = adj.set_of_books_id
      and    adj.asset_id = l_asset_id
      and    adj.transaction_header_id = l_transaction_header_id
      and    adj.code_combination_id is not null
      and    nvl(adj.track_member_flag, 'N') = 'N'
      and    lk.lookup_type = 'JOURNAL ENTRIES'
      and    lk.lookup_code = decode (adj.adjustment_type,
                              'BONUS EXPENSE', 'BONUS DEPRECIATION EXPENSE',
                              'BONUS RESERVE', 'BONUS DEPRECIATION RESERVE',
                              'CIP COST', adj.source_type_code ||' COST',
                              adj.source_type_code ||' '|| adj.adjustment_type)
      and    userenv('LANG') = lk.language
      and    adj.je_header_id = gljh.je_header_id (+)
   UNION ALL
      select adj.adjustment_line_id,
             decode (adj.debit_credit_flag,
                     'CR', adj.adjustment_amount, null),
             decode (adj.debit_credit_flag,
                     'DR', adj.adjustment_amount, null),
             nvl(nvl(gljl.code_combination_id, da.deprn_reserve_account_ccid),
                 cb.reserve_account_ccid),
             glsob.currency_code,
             decode (adj.adjustment_type,
                'BONUS EXPENSE', 'EXPENSE',
                'BONUS RESERVE', 'ASSET',
                'CIP COST', 'ASSET',
                'COST', 'ASSET',
                'COST CLEARING', 'ASSET',
                'DEPRN ADJUST', 'EXPENSE',
                'EXPENSE', 'ASSET',
                'GRP COR RESERVE', 'ASSET',
                'GRP PRC RESERVE', 'ASSET',
                'INTERCO AP', 'LIABILITY',
                'INTERCO AR', 'ASSET',
                'NBV RETIRED', 'ASSET',
                'PROCEEDS', 'ASSET',
                'PROCEEDS CLR', 'ASSET',
                'REMOVALCOST', 'ASSET',
                'REMOVALCOST CLR', 'ASSET',
                'RESERVE', 'ASSET',
                'REVAL RESERVE', 'ASSET',
                'REVAL RSV RET', 'ASSET',
                'REVAL AMORT', 'EXPENSE',
                'REVAL EXPENSE', 'EXPENSE',
                'ASSET'),
             lk.description,
             decode (dd.je_header_id, null, 'N', 'Y'),
             gljh.je_batch_id,
             dd.je_header_id,
             nvl(dd.deprn_reserve_je_line_num, 0),
             adj.distribution_id
      from   fa_mc_adjustments adj,
             gl_sets_of_books glsob,
             fa_mc_book_controls bc,
             fa_lookups_tl lk,
             gl_je_headers gljh,
             fa_mc_deprn_detail dd,
             gl_je_lines gljl,
             fa_distribution_accounts da,
             fa_asset_history ah,
             fa_category_books cb
      where  bc.book_type_code = l_book_type_code
      and    bc.set_of_books_id = l_set_of_books_id
      and    bc.enabled_flag = 'Y'
      and    bc.set_of_books_id = glsob.set_of_books_id
      and    bc.book_type_code = adj.book_type_code
      and    bc.set_of_books_id = adj.set_of_books_id
      and    adj.asset_id = l_asset_id
      and    adj.transaction_header_id = l_transaction_header_id
      and    adj.adjustment_type = 'EXPENSE'
      and    adj.source_type_code in ('DEPRECIATION', 'CIP RETIREMENT',
                                      'RETIREMENT')
      and    adj.code_combination_id is not null
      and    nvl(adj.track_member_flag, 'N') = 'N'
      and    lk.lookup_type = 'JOURNAL ENTRIES'
      and    lk.lookup_code = adj.source_type_code ||' RESERVE'
      and    userenv('LANG') = lk.language
      and    adj.asset_id = dd.asset_id (+)
      and    adj.book_type_code = dd.book_type_code (+)
      and    adj.set_of_books_id = dd.set_of_books_id (+)
      and    adj.distribution_id = dd.distribution_id (+)
      and    adj.period_counter_created = dd.period_counter (+)
      and    dd.je_header_id = gljl.je_header_id (+)
      and    dd.deprn_reserve_je_line_num = gljl.je_line_num (+)
      and    dd.je_header_id = gljh.je_header_id (+)
      and    adj.book_type_code = da.book_type_code (+)
      and    adj.distribution_id = da.distribution_id (+)
      and    adj.asset_id = ah.asset_id
      and    l_date_effective >= ah.date_effective
      and    l_date_effective < nvl(ah.date_ineffective, sysdate+1)
      and    ah.category_id = cb.category_id
      and    bc.book_type_code = cb.book_type_code
   UNION ALL
      select adj.adjustment_line_id,
             decode (adj.debit_credit_flag,
                     'DR', adj.adjustment_amount, null),
             decode (adj.debit_credit_flag,
                     'CR', adj.adjustment_amount, null),
             nvl(nvl(gljl.code_combination_id, da.deprn_reserve_account_ccid),
                 cb.reserve_account_ccid),
             glsob.currency_code,
             decode (adj.adjustment_type,
                'BONUS EXPENSE', 'EXPENSE',
                'BONUS RESERVE', 'ASSET',
                'CIP COST', 'ASSET',
                'COST', 'ASSET',
                'COST CLEARING', 'ASSET',
                'DEPRN ADJUST', 'EXPENSE',
                'EXPENSE', 'EXPENSE',
                'GRP COR RESERVE', 'ASSET',
                'GRP PRC RESERVE', 'ASSET',
                'INTERCO AP', 'LIABILITY',
                'INTERCO AR', 'ASSET',
                'NBV RETIRED', 'ASSET',
                'PROCEEDS', 'ASSET',
                'PROCEEDS CLR', 'ASSET',
                'REMOVALCOST', 'ASSET',
                'REMOVALCOST CLR', 'ASSET',
                'RESERVE', 'ASSET',
                'REVAL RESERVE', 'ASSET',
                'REVAL RSV RET', 'ASSET',
                'REVAL AMORT', 'EXPENSE',
                'REVAL EXPENSE', 'EXPENSE',
                'ASSET'),
             lk.description,
             decode (dd.je_header_id, null, 'N', 'Y'),
             gljh.je_batch_id,
             dd.je_header_id,
             nvl(dd.deprn_reserve_je_line_num, 0),
             adj.distribution_id
      from   fa_mc_adjustments adj,
             gl_sets_of_books glsob,
             fa_mc_book_controls bc,
             fa_lookups_tl lk,
             gl_je_headers gljh,
             fa_mc_deprn_detail dd,
             gl_je_lines gljl,
             fa_distribution_accounts da,
             fa_asset_history ah,
             fa_category_books cb
      where  bc.book_type_code = l_book_type_code
      and    bc.set_of_books_id = l_set_of_books_id
      and    bc.enabled_flag = 'Y'
      and    bc.set_of_books_id = glsob.set_of_books_id
      and    bc.book_type_code = adj.book_type_code
      and    bc.set_of_books_id = adj.set_of_books_id
      and    adj.asset_id = l_asset_id
      and    adj.transaction_header_id = l_transaction_header_id
      and    adj.adjustment_type = 'BONUS EXPENSE'
      and    adj.source_type_code = 'DEPRECIATION'
      and    adj.code_combination_id is not null
      and    nvl(adj.track_member_flag, 'N') = 'N'
      and    lk.lookup_type = 'JOURNAL ENTRIES'
      and    lk.lookup_code = 'BONUS DEPRECIATION RESERVE'
      and    userenv('LANG') = lk.language
      and    adj.asset_id = dd.asset_id (+)
      and    adj.book_type_code = dd.book_type_code (+)
      and    adj.set_of_books_id = dd.set_of_books_id (+)
      and    adj.distribution_id = dd.distribution_id (+)
      and    adj.period_counter_created = dd.period_counter (+)
      and    dd.je_header_id = gljl.je_header_id (+)
      and    dd.bonus_deprn_rsv_je_line_num = gljl.je_line_num (+)
      and    dd.je_header_id = gljh.je_header_id (+)
      and    adj.book_type_code = da.book_type_code (+)
      and    adj.distribution_id = da.distribution_id (+)
      and    adj.asset_id = ah.asset_id
      and    l_date_effective >= ah.date_effective
      and    l_date_effective < nvl(ah.date_ineffective, sysdate+1)
      and    ah.category_id = cb.category_id
      and    bc.book_type_code = cb.book_type_code;

BEGIN

   x_success_count := 0;
   x_failure_count := 0;

   l_batch_size := nvl(nvl(p_batch_size, fa_cache_pkg.fa_batch_size), 1000);

   open c_trans;
   loop

         fetch c_trans bulk collect
          into l_asset_id_tbl,
               l_book_type_code_tbl,
               l_primary_set_of_books_id_tbl,
               l_org_id_tbl,
               l_transaction_type_code_tbl,
               l_transaction_date_entered_tbl,
               l_transaction_header_id_tbl,
               l_rowid_tbl,
               l_event_class_code_tbl,
               l_period_name_tbl,
               l_period_counter_tbl,
               l_cal_period_close_date_tbl,
               l_member_thid_tbl,
               l_hdr_desc_tbl,
               l_je_category_name_tbl,
               l_date_effective_tbl
               limit l_batch_size;

      if (l_event_id_tbl.count = 0) then exit; end if;

      -- Select upg_batch_id
      select xla_upg_batches_s.nextval
      into   l_upg_batch_id
      from   dual;

      FOR i IN 1..l_rowid_tbl.count LOOP
         select xla_events_s.nextval, xla_transaction_entities_s.nextval
         into   l_event_id_tbl(i), l_entity_id_tbl(i)
         from   dual;
      END LOOP;

      -- Update table with event_id
      FORALL l_count IN 1..l_event_id_tbl.count
         update fa_transaction_headers th
         set    th.event_id = l_event_id_tbl(l_count)
         where  th.rowid = l_rowid_tbl(l_count);

      l_rows_processed := l_event_id_tbl.count;

      FORALL l_count IN 1..l_event_id_tbl.count
         update fa_transaction_headers th
         set    th.event_id = l_event_id_tbl(l_count)
         where  th.transaction_header_id = l_member_thid_tbl(l_count);

      -- Business Rules for xla_transaction_entities
      -- * ledger_id is the same as set_of_books_id
      -- * legal_entity_id is null
      -- * entity_code can be TRANSACTIONS or DEPRECIATION
      -- * for TRANSACTIONS:
      --       source_id_int_1 is transaction_header_id
      --       transaction_number is transaction_header_id
      -- * for DEPRECIATION:
      --       source_id_int is asset_id
      --       source_id_int_2 is period_counter
      --       source_id_int_3 is deprn_run_id
      --       transaction_number is set_of_books_id
      -- * source_char_id_1 is book_type_code
      -- * valuation_method is book_type_code

      FORALL i IN 1..l_event_id_tbl.count
         INSERT INTO xla_transaction_entities_upg (
            upg_batch_id,
            application_id,
            ledger_id,
            legal_entity_id,
            entity_code,
            source_id_int_1,
            source_id_int_2,
            source_id_int_3,
            source_id_int_4,
            source_id_char_1,
            source_id_char_2,
            source_id_char_3,
            source_id_char_4,
            security_id_int_1,
            security_id_int_2,
            security_id_int_3,
            security_id_char_1,
            security_id_char_2,
            security_id_char_3,
            transaction_number,
            valuation_method,
            source_application_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            entity_id,
            upg_source_application_id
         ) values (
            l_upg_batch_id,                        -- upg_batch_id
            c_application_id,                      -- application_id
            l_primary_set_of_books_id_tbl(i),      -- ledger_id
            null,                                  -- legal_entity_id,
            c_entity_code,                         -- entity_code
            l_transaction_header_id_tbl(i),        -- source_id_int_1
            null,                                  -- source_id_int_2
            null,                                  -- source_id_int_3
            null,                                  -- source_id_int_4
            l_book_type_code_tbl(i),               -- source_id_char_1  -- Bug 8239360
            null,                                  -- source_id_char_2
            null,                                  -- source_id_char_3
            null,                                  -- source_id_char_4
            null,                                  -- security_id_int_1
            null,                                  -- security_id_int_2
            null,                                  -- security_id_int_3
            null,                                  -- security_id_char_1
            null,                                  -- security_id_char_2
            null,                                  -- security_id_char_3
            l_transaction_header_id_tbl(i),        -- transaction number
            l_book_type_code_tbl(i),               -- valuation_method
            c_application_id,                      -- source_application_id
            sysdate,                               -- creation_date
            c_fnd_user,                            -- created_by
            sysdate,                               -- last_update_date
            c_upgrade_bugno,                       -- last_update_by
            c_upgrade_bugno,                       -- last_update_login
            l_entity_id_tbl(i),                    -- entity_id
            c_application_id                       -- upg_source_application_id
         );

      -- Business Rules for xla_events
      -- * event_type_code is similar to transaction_type_code
      -- * event_number is 1, but is the serial event for chronological order
      -- * event_status_code: N if event creates no journal entries
      --                      P if event would ultimately yield journals
      --                      I if event is not ready to be processed
      --                      U never use this value for upgrade
      -- * process_status_code: E if error and journals not yet created
      --                        P if processed and journals already generated
      --                        U if unprocessed and journals not generated
      --                        D only used for Global Accounting Engine
      --                        I do not use for upgrade
      -- * on_hold_flag: N should always be this value for upgraded entries
      -- * event_date is basically transaction_date_entered

      FORALL i IN 1..l_event_id_tbl.count
         insert into xla_events (
            upg_batch_id,
            application_id,
            event_type_code,
            event_number,
            event_status_code,
            process_status_code,
            on_hold_flag,
            event_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_update_date,
            program_id,
            program_application_id,
            request_id,
            entity_id,
            event_id,
            upg_source_application_id,
            transaction_date
         ) values (
            l_upg_batch_id,                          -- upg_batch_id
            c_application_id,                        -- application_id
            l_event_class_code_tbl(i),               -- event_type_code
            '1',                                     -- event_number
            'P',                                     -- event_status_code
            'P',                                     -- process_status_code
            'N',                                     -- on_hold_flag
            l_transaction_date_entered_tbl(i),       -- event_date
            sysdate,                                 -- creation_date
            c_fnd_user,                              -- created_by
            sysdate,                                 -- last_update_date
            c_upgrade_bugno,                         -- last_update_by
            c_upgrade_bugno,                         -- last_update_login
            null,                                    -- program_update_date
            null,                                    -- program_id
            null,                                    -- program_application_id
            null,                                    -- program_update_date
            l_entity_id_tbl(i),                      -- entity_id
            l_event_id_tbl(i),                       -- event_id
            c_application_id,                        -- upg_source_appl_id
            l_transaction_date_entered_tbl(i)        -- transaction_date
         );

      FOR i IN 1..l_event_id_tbl.count LOOP

            open c_adj (l_book_type_code_tbl(i),
                        l_asset_id_tbl(i),
                        l_transaction_header_id_tbl(i),
                        l_date_effective_tbl(i));
            fetch c_adj bulk collect
             into l_adj_line_id_tbl,
                  l_debit_amount_tbl,
                  l_credit_amount_tbl,
                  l_ccid_tbl,
                  l_currency_code_tbl,
                  l_acct_class_code_tbl,
                  l_line_desc_tbl,
                  l_gl_transfer_status_code_tbl,
                  l_je_batch_id_tbl,
                  l_je_header_id_tbl,
                  l_je_line_num_tbl,
                  l_distribution_id_tbl;
            close c_adj;

            FOR j IN 1..l_adj_line_id_tbl.count LOOP
               l_ae_line_num_tbl(j) := j;

               select xla_gl_sl_link_id_s.nextval
               into   l_xla_gl_sl_link_id_tbl(j)
               from   dual;
            END LOOP;

            select xla_ae_headers_s.nextval
            into   l_ae_header_id
            from   dual;

      -- Business Rules for xla_ae_headers
      -- * amb_context_code is DEFAULT
      -- * reference_date must be null
      -- * balance_type_code:
      --     A: Actual
      --     B: Budget
      --     E: Encumbrance
      -- * gl_transfer_status_code:
      --     Y: already transferred to GL
      --     N: not transferred to GL
      -- * gl_transfer_date is date entry transferred to GL
      -- * accounting_entry_status_code must be F
      -- * accounting_entry_type_code must be STANDARD
      -- * product_rule_* not relevant for upgrade

         insert into xla_ae_headers (
            upg_batch_id,
            application_id,
            amb_context_code,
            entity_id,
            event_id,
            event_type_code,
            ae_header_id,
            ledger_id,
            accounting_date,
            period_name,
            reference_date,
            balance_type_code,
            je_category_name,
            gl_transfer_status_code,
            gl_transfer_date,
            accounting_entry_status_code,
            accounting_entry_type_code,
            description,
            budget_version_id,
            funds_status_code,
            encumbrance_type_id,
            completed_date,
            doc_sequence_id,
            doc_sequence_value,
            doc_category_code,
            packet_id,
            group_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_id,
            program_application_id,
            program_update_date,
            request_id,
            close_acct_seq_assign_id,
            close_acct_seq_version_id,
            close_acct_seq_value,
            completion_acct_seq_assign_id,
            completion_acct_seq_version_id,
            completion_acct_seq_value,
            accounting_batch_id,
            product_rule_type_code,
            product_rule_code,
            product_rule_version,
            upg_source_application_id,
            upg_valid_flag
         ) values (
            l_upg_batch_id,                     -- upg_batch_id
            c_application_id,                   -- application_id
            c_amb_context_code,                 -- amb_context_code
            l_entity_id_tbl(i),                 -- entity_id
            l_event_id_tbl(i),                  -- event_id,
            l_event_class_code_tbl(i),          -- event_type_code
            l_ae_header_id,                     -- ae_header_id,
            l_primary_set_of_books_id_tbl(i),   -- ledger_id/sob_id
            l_cal_period_close_date_tbl(i),     -- accounting_date,
            l_period_name_tbl(i),               -- period_name,
            null,                               -- reference_date
            'A',                                -- balance_type_code,
            l_je_category_name_tbl(i),          -- je_category_name
            'Y',                                -- gl_transfer_status_code
            null,                               -- gl_transfer_date
            'F',                                -- accounting_entry_status_code
            'STANDARD',                         -- accounting_entry_type_code
            l_hdr_desc_tbl(i),                  -- description
            null,                               -- budget_version_id
            null,                               -- funds_status_code
            null,                               -- encumbrance_type_id
            null,                               -- completed_date
            null,                               -- doc_sequence_id
            null,                               -- doc_sequence_value
            null,                               -- doc_category_code
            null,                               -- packet_id,
            null,                               -- group_id
            sysdate,                            -- creation_date
            c_fnd_user,                         -- created_by
            sysdate,                            -- last_update_date
            c_fnd_user,                         -- last_updated_by
            c_upgrade_bugno,                    -- last_update_login
            null,                               -- program_id
            c_application_id,                   -- program_application_id
            sysdate,                            -- program_update_date
            null,                               -- request_id
            null,                               -- close_acct_seq_assign_id
            null,                               -- close_acct_seq_version_id
            null,                               -- close_acct_seq_value
            null,                               -- compl_acct_seq_assign_id
            null,                               -- compl_acct_seq_version_id
            null,                               -- compl_acct_seq_value
            null,                               -- accounting_batch_id
            null,                               -- product_rule_type_code
            null,                               -- product_rule_code
            null,                               -- product_rule_version
            c_application_id,                   -- upg_souce_application_id
            null                                -- upg_valid_flag
         );

            -- Business Rules for xla_ae_lines
            -- * gl_transfer_mode_code:
            --       D: Detailed mode when transferred to GL
            --       S: Summary mode when transferred to GL
            -- * gl_sl_link_table must be XLAJEL
            -- * currency_conversion_* needs to be populated only if
            --   different from ledger currency

            forall j IN 1..l_xla_gl_sl_link_id_tbl.count
            insert into xla_ae_lines (
                  upg_batch_id,
                  ae_header_id,
                  ae_line_num,
                  displayed_line_number,
                  application_id,
                  code_combination_id,
                  gl_transfer_mode_code,
                  accounted_dr,
                  accounted_cr,
                  currency_code,
                  currency_conversion_date,
                  currency_conversion_rate,
                  currency_conversion_type,
                  entered_dr,
                  entered_cr,
                  description,
                  accounting_class_code,
                  gl_sl_link_id,
                  gl_sl_link_table,
                  party_type_code,
                  party_id,
                  party_site_id,
                  statistical_amount,
                  ussgl_transaction_code,
                  jgzz_recon_ref,
                  control_balance_flag,
                  analytical_balance_flag,
                  upg_tax_reference_id1,
                  upg_tax_reference_id2,
                  upg_tax_reference_id3,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  program_update_date,
                  program_id,
                  program_application_id,
                  request_id,
                  gain_or_loss_flag,
                  accounting_date,
                  ledger_id
            ) values (
                  l_upg_batch_id,                 -- upg_batch_id
                  l_ae_header_id,                 -- ae_header_id
                  l_ae_line_num_tbl(j),           -- ae_line_num
                  l_ae_line_num_tbl(j),           -- displayed_line_num
                  c_application_id,               -- application_id
                  l_ccid_tbl(j),                  -- code_combination_id
                  'S',                            -- gl_transfer_mode_code
                  l_debit_amount_tbl(j),          -- accounted_dr
                  l_credit_amount_tbl(j),         -- accounted_cr
                  l_currency_code_tbl(j),         -- currency_code
                  null,                           -- currency_conversion_date
                  null,                           -- currency_conversion_rate
                  null,                           -- currency_conversion_type
                  l_debit_amount_tbl(j),          -- entered_dr
                  l_credit_amount_tbl(j),         -- entered_cr
                  l_line_desc_tbl(j) || ' - ' ||
                     to_char(l_cal_period_close_date_tbl(i), 'DD-MON-RR'),
                                                  -- description
                  l_acct_class_code_tbl(j),       -- accounting_class_code
                  l_xla_gl_sl_link_id_tbl(j),     -- gl_sl_link_id
                  'XLAJEL',                       -- gl_sl_link_table
                  null,                           -- party_type_code
                  null,                           -- party_id
                  null,                           -- party_site_id
                  null,                           -- statistical_amount
                  null,                           -- ussgl_transaction_code
                  null,                           -- glzz_recon_ref
                  null,                           -- control_balance_flag
                  null,                           -- analytical_balance_flag
                  null,                           -- upg_tax_reference_id1
                  null,                           -- upg_tax_reference_id2
                  null,                           -- upg_tax_reference_id3
                  sysdate,                        -- creation_date
                  c_fnd_user,                     -- created_by
                  sysdate,                        -- last_update_date
                  c_fnd_user,                     -- last_updated_by
                  c_upgrade_bugno,                -- last_update_login
                  null,                           -- program_update_date
                  null,                           -- program_id
                  c_application_id,               -- program_application_id
                  null,                           -- request_id
                  'N',                            -- gain_or_loss_flag
                  l_cal_period_close_date_tbl(i), -- accounting_date,
                  l_primary_set_of_books_id_tbl(i)
                                                  -- ledger_id/sob_id
            );

            -- Business Rules for xla_distribution_links
            -- * accounting_line_code is similar to adjustment_type
            -- * accounting_line_type_code is S
            -- * merge_duplicate_code is N
            -- * source_distribution_type is TRX
            -- * source_distribution_id_num_1 is transaction_header_id
            -- * source_distribution_id_num_2 is event_id

            forall j IN 1..l_xla_gl_sl_link_id_tbl.count
            insert into xla_distribution_links (
                  upg_batch_id,
                  application_id,
                  event_id,
                  ae_header_id,
                  ae_line_num,
                  accounting_line_code,
                  accounting_line_type_code,
                  source_distribution_type,
                  source_distribution_id_char_1,
                  source_distribution_id_char_2,
                  source_distribution_id_char_3,
                  source_distribution_id_char_4,
                  source_distribution_id_char_5,
                  source_distribution_id_num_1,
                  source_distribution_id_num_2,
                  source_distribution_id_num_3,
                  source_distribution_id_num_4,
                  source_distribution_id_num_5,
                  merge_duplicate_code,
                  statistical_amount,
                  unrounded_entered_dr,
                  unrounded_entered_cr,
                  unrounded_accounted_dr,
                  unrounded_accounted_cr,
                  ref_ae_header_id,
                  ref_temp_line_num,
                  ref_event_id,
                  temp_line_num,
                  tax_line_ref_id,
                  tax_summary_line_ref_id,
                  tax_rec_nrec_dist_ref_id,
                  line_definition_owner_code,
                  line_definition_code,
                  event_class_code,
                  event_type_code
               ) values (
                  l_upg_batch_id,              -- upg_batch_id
                  c_application_id,            -- application_id
                  l_event_id_tbl(i),           -- event_id
                  l_ae_header_id,              -- ae_header_id
                  l_ae_line_num_tbl(j),        -- ae_line_num
                  null,                        -- accounting_line_code
                  'S',                         -- accounting_line_type_code
                  'TRX',                       -- source_distribution_type
                  null,                        -- source_distribution_id_char_1
                  null,                        -- source_distribution_id_char_2
                  null,                        -- source_distribution_id_char_3
                  null,                        -- source_distribution_id_char_4
                  null,                        -- source_distribution_id_char_5
                  l_transaction_header_id_tbl(i),
                                               -- source_distribution_id_num_1
                  l_adj_line_id_tbl(j),        -- source_distribution_id_num_2
                  null,                        -- source_distribution_id_num_3
                  null,                        -- source_distribution_id_num_4
                  null,                        -- source_distribution_id_num_5
                  'N',                         -- merge_duplicate_code
                  null,                        -- statistical_amount
                  l_debit_amount_tbl(j),       -- unrounded_entered_dr
                  l_credit_amount_tbl(j),      -- unrounded_entered_cr
                  l_debit_amount_tbl(j),       -- unrounded_accounted_dr
                  l_credit_amount_tbl(j),      -- unrounded_accounted_cr
                  l_ae_header_id,              -- ref_ae_header_id
                  null,                        -- ref_temp_line_num
                  null,                        -- ref_event_id
                  l_ae_line_num_tbl(j),        -- temp_line_num
                  null,                        -- tax_line_ref_id
                  null,                        -- tax_summary_line_ref_id
                  null,                        -- tax_rec_nrec_dist_ref_id
                  null,                        -- line_definition_owner_code
                  null,                        -- line_definition_code
                  l_event_class_code_tbl(i),   -- event_class_code
                  l_event_class_code_tbl(i)    -- event_type_code
               );

            for j IN 1..l_xla_gl_sl_link_id_tbl.count loop
               if (l_je_batch_id_tbl(j) is not null) then
                  insert into gl_import_references (
                     je_batch_id,
                     je_header_id,
                     je_line_num,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     reference_1,
                     reference_2,
                     reference_3,
                     reference_4,
                     reference_5,
                     reference_6,
                     reference_7,
                     reference_8,
                     reference_9,
                     reference_10,
                     subledger_doc_sequence_id,
                     subledger_doc_sequence_value,
                     gl_sl_link_id,
                     gl_sl_link_table
                  ) values (
                     l_je_batch_id_tbl(j),        -- je_batch_id
                     l_je_header_id_tbl(j),       -- je_header_id
                     l_je_line_num_tbl(j),        -- je_line_num
                     sysdate,                     -- last_update_date
                     c_fnd_user,                  -- last_updated_by
                     sysdate,                     -- creation_date
                     c_fnd_user,                  -- created_by
                     c_upgrade_bugno,             -- last_update_login
                     to_char(l_transaction_header_id_tbl(i)),
                                                  -- reference_1
                     to_char(l_asset_id_tbl(i)),  -- reference_2
                     to_char(l_distribution_id_tbl(j)),
                                                  -- reference_3
                     to_char(l_adj_line_id_tbl(j)),
                                                  -- reference_4
                     l_book_type_code_tbl(i),     -- reference_5
                     to_char(l_period_counter_tbl(i)),
                                                  -- reference_6
                     null,                        -- reference_7
                     null,                        -- reference_8
                     null,                        -- reference_9
                     null,                        -- reference_10
                     null,                        -- subledger_doc_seq_id
                     null,                        -- subledger_doc_seq_value
                     l_xla_gl_sl_link_id_tbl(j),  -- gl_sl_link_id
                     'XLAJEL'                     -- gl_sl_link_table
                  );
               end if;
            end loop;

            l_adj_line_id_tbl.delete;
            l_xla_gl_sl_link_id_tbl.delete;
            l_ae_line_num_tbl.delete;
            l_debit_amount_tbl.delete;
            l_credit_amount_tbl.delete;
            l_ccid_tbl.delete;
            l_currency_code_tbl.delete;
            l_acct_class_code_tbl.delete;
            l_line_def_owner_code_tbl.delete;
            l_line_def_code_tbl.delete;
            l_line_desc_tbl.delete;
            l_gl_transfer_status_code_tbl.delete;
            l_je_batch_id_tbl.delete;
            l_je_header_id_tbl.delete;
            l_je_line_num_tbl.delete;
            l_distribution_id_tbl.delete;

            open c_mc_books (l_book_type_code_tbl(i));
            fetch c_mc_books bulk collect
             into l_rep_set_of_books_id_tbl;
            close c_mc_books;

           for k IN 1..l_rep_set_of_books_id_tbl.count loop

            open c_mc_adj (l_book_type_code_tbl(i),
                        l_asset_id_tbl(i),
                        l_rep_set_of_books_id_tbl(k),
                        l_transaction_header_id_tbl(i),
                        l_date_effective_tbl(i));
            fetch c_mc_adj bulk collect
             into l_adj_line_id_tbl,
                  l_debit_amount_tbl,
                  l_credit_amount_tbl,
                  l_ccid_tbl,
                  l_currency_code_tbl,
                  l_acct_class_code_tbl,
                  l_line_desc_tbl,
                  l_gl_transfer_status_code_tbl,
                  l_je_batch_id_tbl,
                  l_je_header_id_tbl,
                  l_je_line_num_tbl,
                  l_distribution_id_tbl;
           close c_mc_adj;

            FOR j IN 1..l_adj_line_id_tbl.count LOOP
               l_ae_line_num_tbl(j) := j;

               select xla_gl_sl_link_id_s.nextval
               into   l_xla_gl_sl_link_id_tbl(j)
               from   dual;
            END LOOP;

            select xla_ae_headers_s.nextval
            into   l_ae_header_id
            from   dual;

      -- Business Rules for xla_ae_headers
      -- * amb_context_code is DEFAULT
      -- * reference_date must be null
      -- * balance_type_code:
      --     A: Actual
      --     B: Budget
      --     E: Encumbrance
      -- * gl_transfer_status_code:
      --     Y: already transferred to GL
      --     N: not transferred to GL
      -- * gl_transfer_date is date entry transferred to GL
      -- * accounting_entry_status_code must be F
      -- * accounting_entry_type_code must be STANDARD
      -- * product_rule_* not relevant for upgrade

         insert into xla_ae_headers (
            upg_batch_id,
            application_id,
            amb_context_code,
            entity_id,
            event_id,
            event_type_code,
            ae_header_id,
            ledger_id,
            accounting_date,
            period_name,
            reference_date,
            balance_type_code,
            je_category_name,
            gl_transfer_status_code,
            gl_transfer_date,
            accounting_entry_status_code,
            accounting_entry_type_code,
            description,
            budget_version_id,
            funds_status_code,
            encumbrance_type_id,
            completed_date,
            doc_sequence_id,
            doc_sequence_value,
            doc_category_code,
            packet_id,
            group_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_id,
            program_application_id,
            program_update_date,
            request_id,
            close_acct_seq_assign_id,
            close_acct_seq_version_id,
            close_acct_seq_value,
            completion_acct_seq_assign_id,
            completion_acct_seq_version_id,
            completion_acct_seq_value,
            accounting_batch_id,
            product_rule_type_code,
            product_rule_code,
            product_rule_version,
            upg_source_application_id,
            upg_valid_flag
         ) values (
            l_upg_batch_id,                     -- upg_batch_id
            c_application_id,                   -- application_id
            c_amb_context_code,                 -- amb_context_code
            l_entity_id_tbl(i),                 -- entity_id
            l_event_id_tbl(i),                  -- event_id,
            l_event_class_code_tbl(i),          -- event_type_code
            l_ae_header_id,                     -- ae_header_id,
            l_rep_set_of_books_id_tbl(k),       -- ledger_id/sob_id
            l_cal_period_close_date_tbl(i),     -- accounting_date,
            l_period_name_tbl(i),               -- period_name,
            null,                               -- reference_date
            'A',                                -- balance_type_code,
            l_je_category_name_tbl(i),          -- je_category_name
            'Y',                                -- gl_transfer_status_code
            null,                               -- gl_transfer_date
            'F',                                -- accounting_entry_status_code
            'STANDARD',                         -- accounting_entry_type_code
            l_hdr_desc_tbl(i),                  -- description
            null,                               -- budget_version_id
            null,                               -- funds_status_code
            null,                               -- encumbrance_type_id
            null,                               -- completed_date

            null,                               -- doc_sequence_id
            null,                               -- doc_sequence_value
            null,                               -- doc_category_code
            null,                               -- packet_id,
            null,                               -- group_id
            sysdate,                            -- creation_date
            c_fnd_user,                         -- created_by
            sysdate,                            -- last_update_date
            c_fnd_user,                         -- last_updated_by
            c_upgrade_bugno,                    -- last_update_login
            null,                               -- program_id
            c_application_id,                   -- program_application_id
            sysdate,                            -- program_update_date
            null,                               -- request_id
            null,                               -- close_acct_seq_assign_id
            null,                               -- close_acct_seq_version_id
            null,                               -- close_acct_seq_value
            null,                               -- compl_acct_seq_assign_id
            null,                               -- compl_acct_seq_version_id
            null,                               -- compl_acct_seq_value
            null,                               -- accounting_batch_id
            null,                               -- product_rule_type_code
            null,                               -- product_rule_code
            null,                               -- product_rule_version
            c_application_id,                   -- upg_souce_application_id
            null                                -- upg_valid_flag
         );

            -- Business Rules for xla_ae_lines
            -- * gl_transfer_mode_code:
            --       D: Detailed mode when transferred to GL
            --       S: Summary mode when transferred to GL
            -- * gl_sl_link_table must be XLAJEL
            -- * currency_conversion_* needs to be populated only if
            --   different from ledger currency

            forall j IN 1..l_xla_gl_sl_link_id_tbl.count
            insert into xla_ae_lines (
                  upg_batch_id,
                  ae_header_id,
                  ae_line_num,
                  displayed_line_number,
                  application_id,
                  code_combination_id,
                  gl_transfer_mode_code,
                  accounted_dr,
                  accounted_cr,
                  currency_code,
                  currency_conversion_date,
                  currency_conversion_rate,
                  currency_conversion_type,
                  entered_dr,
                  entered_cr,
                  description,
                  accounting_class_code,
                  gl_sl_link_id,
                  gl_sl_link_table,
                  party_type_code,
                  party_id,
                  party_site_id,
                  statistical_amount,
                  ussgl_transaction_code,
                  jgzz_recon_ref,
                  control_balance_flag,
                  analytical_balance_flag,
                  upg_tax_reference_id1,
                  upg_tax_reference_id2,
                  upg_tax_reference_id3,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  program_update_date,
                  program_id,
                  program_application_id,
                  request_id,
                  gain_or_loss_flag,
                  accounting_date,
                  ledger_id
            ) values (
                  l_upg_batch_id,                 -- upg_batch_id
                  l_ae_header_id,                 -- ae_header_id
                  l_ae_line_num_tbl(j),           -- ae_line_num
                  l_ae_line_num_tbl(j),           -- displayed_line_num
                  c_application_id,               -- application_id
                  l_ccid_tbl(j),                  -- code_combination_id
                  'S',                            -- gl_transfer_mode_code
                  l_debit_amount_tbl(j),          -- accounted_dr
                  l_credit_amount_tbl(j),         -- accounted_cr
                  l_currency_code_tbl(j),         -- currency_code
                  null,                           -- currency_conversion_date
                  null,                           -- currency_conversion_rate
                  null,                           -- currency_conversion_type
                  l_debit_amount_tbl(j),          -- entered_dr
                  l_credit_amount_tbl(j),         -- entered_cr
                  l_line_desc_tbl(j) || ' - ' ||
                     to_char(l_cal_period_close_date_tbl(i), 'DD-MON-RR'),
                                                  -- description
                  l_acct_class_code_tbl(j),       -- accounting_class_code
                  l_xla_gl_sl_link_id_tbl(j),     -- gl_sl_link_id
                  'XLAJEL',                       -- gl_sl_link_table
                  null,                           -- party_type_code
                  null,                           -- party_id
                  null,                           -- party_site_id
                  null,                           -- statistical_amount
                  null,                           -- ussgl_transaction_code
                  null,                           -- glzz_recon_ref
                  null,                           -- control_balance_flag
                  null,                           -- analytical_balance_flag
                  null,                           -- upg_tax_reference_id1
                  null,                           -- upg_tax_reference_id2
                  null,                           -- upg_tax_reference_id3
                  sysdate,                        -- creation_date
                  c_fnd_user,                     -- created_by
                  sysdate,                        -- last_update_date
                  c_fnd_user,                     -- last_updated_by
                  c_upgrade_bugno,                -- last_update_login
                  null,                           -- program_update_date
                  null,                           -- program_id
                  c_application_id,               -- program_application_id
                  null,                           -- request_id
                  'N',                            -- gain_or_loss_flag
                  l_cal_period_close_date_tbl(i), -- accounting_date,
                  l_rep_set_of_books_id_tbl(k)    -- ledger_id/sob_id
            );

            -- Business Rules for xla_distribution_links
            -- * accounting_line_code is similar to adjustment_type
            -- * accounting_line_type_code is S
            -- * merge_duplicate_code is N
            -- * source_distribution_type is TRX
            -- * source_distribution_id_num_1 is transaction_header_id
            -- * source_distribution_id_num_2 is event_id

            forall j IN 1..l_xla_gl_sl_link_id_tbl.count
            insert into xla_distribution_links (
                  upg_batch_id,
                  application_id,
                  event_id,
                  ae_header_id,
                  ae_line_num,
                  accounting_line_code,
                  accounting_line_type_code,
                  source_distribution_type,
                  source_distribution_id_char_1,
                  source_distribution_id_char_2,
                  source_distribution_id_char_3,
                  source_distribution_id_char_4,
                  source_distribution_id_char_5,
                  source_distribution_id_num_1,
                  source_distribution_id_num_2,
                  source_distribution_id_num_3,
                  source_distribution_id_num_4,
                  source_distribution_id_num_5,
                  merge_duplicate_code,
                  statistical_amount,
                  unrounded_entered_dr,
                  unrounded_entered_cr,
                  unrounded_accounted_dr,
                  unrounded_accounted_cr,
                  ref_ae_header_id,
                  ref_temp_line_num,
                  ref_event_id,
                  temp_line_num,
                  tax_line_ref_id,
                  tax_summary_line_ref_id,
                  tax_rec_nrec_dist_ref_id,
                  line_definition_owner_code,
                  line_definition_code,
                  event_class_code,
                  event_type_code
               ) values (
                  l_upg_batch_id,              -- upg_batch_id
                  c_application_id,            -- application_id
                  l_event_id_tbl(i),           -- event_id
                  l_ae_header_id,              -- ae_header_id
                  l_ae_line_num_tbl(j),        -- ae_line_num
                  null,                        -- accounting_line_code
                  'S',                         -- accounting_line_type_code
                  'TRX',                       -- source_distribution_type
                  null,                        -- source_distribution_id_char_1
                  null,                        -- source_distribution_id_char_2
                  null,                        -- source_distribution_id_char_3
                  null,                        -- source_distribution_id_char_4
                  null,                        -- source_distribution_id_char_5
                  l_transaction_header_id_tbl(i),
                                               -- source_distribution_id_num_1
                  l_adj_line_id_tbl(j),        -- source_distribution_id_num_2
                  null,                        -- source_distribution_id_num_3
                  null,                        -- source_distribution_id_num_4
                  null,                        -- source_distribution_id_num_5
                  'N',                         -- merge_duplicate_code
                  null,                        -- statistical_amount
                  l_debit_amount_tbl(j),       -- unrounded_entered_dr
                  l_credit_amount_tbl(j),      -- unrounded_entered_cr
                  l_debit_amount_tbl(j),       -- unrounded_accounted_dr
                  l_credit_amount_tbl(j),      -- unrounded_accounted_cr
                  l_ae_header_id,              -- ref_ae_header_id
                  null,                        -- ref_temp_line_num
                  null,                        -- ref_event_id
                  l_ae_line_num_tbl(j),        -- temp_line_num
                  null,                        -- tax_line_ref_id
                  null,                        -- tax_summary_line_ref_id
                  null,                        -- tax_rec_nrec_dist_ref_id
                  null,                        -- line_definition_owner_code
                  null,                        -- line_definition_code
                  l_event_class_code_tbl(i),   -- event_class_code
                  l_event_class_code_tbl(i)    -- event_type_code
               );

            for j IN 1..l_xla_gl_sl_link_id_tbl.count loop
               if (l_je_batch_id_tbl(j) is not null) then
                  insert into gl_import_references (
                     je_batch_id,
                     je_header_id,
                     je_line_num,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     reference_1,
                     reference_2,
                     reference_3,
                     reference_4,
                     reference_5,
                     reference_6,
                     reference_7,
                     reference_8,
                     reference_9,
                     reference_10,
                     subledger_doc_sequence_id,
                     subledger_doc_sequence_value,
                     gl_sl_link_id,
                     gl_sl_link_table
                  ) values (
                     l_je_batch_id_tbl(j),        -- je_batch_id
                     l_je_header_id_tbl(j),       -- je_header_id
                     l_je_line_num_tbl(j),        -- je_line_num
                     sysdate,                     -- last_update_date
                     c_fnd_user,                  -- last_updated_by
                     sysdate,                     -- creation_date
                     c_fnd_user,                  -- created_by
                     c_upgrade_bugno,             -- last_update_login
                     to_char(l_transaction_header_id_tbl(i)),
                                                  -- reference_1
                     to_char(l_asset_id_tbl(i)),  -- reference_2
                     to_char(l_distribution_id_tbl(j)),
                                                  -- reference_3
                     to_char(l_adj_line_id_tbl(j)),
                                                  -- reference_4
                     l_book_type_code_tbl(i),     -- reference_5
                     to_char(l_period_counter_tbl(i)),
                                                  -- reference_6
                     null,                        -- reference_7
                     null,                        -- reference_8
                     null,                        -- reference_9
                     null,                        -- reference_10
                     null,                        -- subledger_doc_seq_id
                     null,                        -- subledger_doc_seq_value
                     l_xla_gl_sl_link_id_tbl(j),  -- gl_sl_link_id
                     'XLAJEL'                     -- gl_sl_link_table
                  );
               end if;
            end loop;

            l_adj_line_id_tbl.delete;
            l_xla_gl_sl_link_id_tbl.delete;
            l_ae_line_num_tbl.delete;
            l_debit_amount_tbl.delete;
            l_credit_amount_tbl.delete;
            l_ccid_tbl.delete;
            l_currency_code_tbl.delete;
            l_acct_class_code_tbl.delete;
            l_line_def_owner_code_tbl.delete;
            l_line_def_code_tbl.delete;
            l_line_desc_tbl.delete;
            l_gl_transfer_status_code_tbl.delete;
            l_je_batch_id_tbl.delete;
            l_je_header_id_tbl.delete;
            l_je_line_num_tbl.delete;
            l_distribution_id_tbl.delete;

         end loop;

         l_rep_set_of_books_id_tbl.delete;

      END LOOP;

      l_rowid_tbl.delete;
      l_event_id_tbl.delete;
      l_asset_id_tbl.delete;
      l_book_type_code_tbl.delete;
      l_primary_set_of_books_id_tbl.delete;
      l_org_id_tbl.delete;
      l_transaction_type_code_tbl.delete;
      l_transaction_date_entered_tbl.delete;
      l_transaction_header_id_tbl.delete;
      l_period_counter_tbl.delete;
      l_period_name_tbl.delete;
      l_cal_period_close_date_tbl.delete;
      l_entity_id_tbl.delete;
      l_event_class_code_tbl.delete;
      l_member_thid_tbl.delete;
      l_hdr_desc_tbl.delete;
      l_je_category_name_tbl.delete;
      l_date_effective_tbl.delete;

      commit;

      if (l_rows_processed < l_batch_size) then exit; end if;

   end loop;
   close c_trans;

EXCEPTION
   WHEN OTHERS THEN
      rollback;
      raise;

End Upgrade_Group_Trxn_Events;

Procedure Upgrade_Trxn_Events (
             p_start_rowid             IN            rowid,
             p_end_rowid               IN            rowid,
             p_batch_size              IN            number,
             x_success_count              OUT NOCOPY number,
             x_failure_count              OUT NOCOPY number,
             x_return_status              OUT NOCOPY number
            ) IS

   c_application_id            constant number(15) := 140;
   c_upgrade_bugno             constant number(15) := -4107161;
   c_fnd_user                  constant number(15) := 2;


   c_entity_code               constant varchar2(30) := 'TRANSACTIONS';
   c_amb_context_code          constant varchar2(30) := 'DEFAULT';

   -- this value can be altered in order to process more of less per batch
   l_batch_size                NUMBER;

   l_rows_processed            NUMBER;

   l_upg_batch_id              NUMBER(15);
   l_bonus_deprn_rsv_desc      VARCHAR2(80);
   l_mc_books                  NUMBER;


BEGIN

   x_success_count := 0;
   x_failure_count := 0;

   l_batch_size := nvl(nvl(p_batch_size, fa_cache_pkg.fa_batch_size), 1000);

   -- Select upg_batch_id
   select xla_upg_batches_s.nextval
   into   l_upg_batch_id
   from   dual;

   -- Save value into a variable
   select description
   into   l_bonus_deprn_rsv_desc
   from   fa_lookups
   where  lookup_type = 'JOURNAL ENTRIES'
   and    lookup_code = 'BONUS DEPRECIATION RESERVE';

   insert all
   when 1 = 1 then
      into fa_xla_upg_events_gt (
            event_id,
            entity_id,
            transaction_header_id,
            set_of_books_id,
            period_name,
            calendar_period_close_date,
            date_effective,
            je_category_name,
            description,
            event_type_code,
            event_class_code,
            asset_id,
            book_type_code,
            period_counter
      ) values (
            xla_events_s.nextval,
            xla_transaction_entities_s.nextval,
            transaction_header_id,
            set_of_books_id,
            period_name,
            calendar_period_close_date,
            date_effective,
            je_category_name,
            description,
            event_type_code,
            event_class_code,
            asset_id,
            book_type_code,
            period_counter
      )
   when 1 = 1 then
      into xla_transaction_entities_upg (
            upg_batch_id,
            application_id,
            ledger_id,
            legal_entity_id,
            entity_code,
            source_id_int_1,
            source_id_int_2,
            source_id_int_3,
            source_id_int_4,
            source_id_char_1,
            source_id_char_2,
            source_id_char_3,
            source_id_char_4,
            security_id_int_1,
            security_id_int_2,
            security_id_int_3,
            security_id_char_1,
            security_id_char_2,
            security_id_char_3,
            transaction_number,
            valuation_method,
            source_application_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            entity_id,
            upg_source_application_id
      ) values (
            l_upg_batch_id,        -- upg_batch_id
            c_application_id,      -- application_id
            set_of_books_id,       -- ledger_id
            null,                  -- legal_entity_id
            c_entity_code,         -- entity_code
            transaction_header_id, -- source_id_int_1
            null,                  -- source_id_int_2
            null,                  -- source_id_int_3
            null,                  -- source_id_int_4
            book_type_code,        -- source_id_char_1  -- Bug 8239360
            null,                  -- source_id_char_2
            null,                  -- source_id_char_3
            null,                  -- source_id_char_4
            null,                  -- security_id_int_1
            null,                  -- security_id_int_2
            null,                  -- security_id_int_3
            null,                  -- security_id_char_1
            null,                  -- security_id_char_2
            null,                  -- security_id_char_3
            to_char(transaction_header_id),
                                   -- transaction_number
            book_type_code,        -- valuation_method
            c_application_id,      -- source_application_id
            sysdate,               -- creation_date
            c_fnd_user,            -- created_by
            sysdate,               -- last_update_date
            c_fnd_user,            -- last_updated_by
            c_upgrade_bugno,       -- last_update_login
            xla_transaction_entities_s.currval,
                                   -- entity_id
            c_application_id       -- upg_source_application_id
      )
   when 1 = 1 then
      into xla_events (
            upg_batch_id,
            application_id,
            event_type_code,
            event_number,
            event_status_code,
            process_status_code,
            on_hold_flag,
            event_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_update_date,
            program_id,
            program_application_id,
            request_id,
            entity_id,
            event_id,
            upg_source_application_id,
            transaction_date
      ) values (
            l_upg_batch_id,        -- upg_batch_id
            c_application_id,      -- application_id
            event_type_code,
            1,                     -- event_number
            event_status_code,     -- Bug 6811554: event_status_code
            process_status_code,   -- Bug 6811554: process_status_code
            'N',                   -- on_hold_flag
            transaction_date_entered,
                                   -- event_date
            sysdate,               -- creation_date
            c_fnd_user,            -- created_by
            sysdate,               -- last_update_date
            c_fnd_user,            -- last_updated_by
            c_upgrade_bugno,       -- last_update_login
            null,                  -- program_update_date
            null,                  -- program_id
            null,                  -- program_application_id
            null,                  -- request_id
            xla_transaction_entities_s.currval,
                                   -- entity_id
            xla_events_s.currval,  -- event_id
            c_application_id,      -- upg_source_application_id
            transaction_date_entered
                                   -- transaction_date
      )
   when event_id is null then   -- Bug 6811554
      into fa_xla_upg_headers_gt (
         ae_header_id,
         event_id,
         set_of_books_id
      ) values (
         xla_ae_headers_s.nextval,
         xla_events_s.currval,
         set_of_books_id
      )
--   when 1 = 1 then
   when event_id is null then   -- Bug 6811554
      into xla_ae_headers (
            upg_batch_id,
            application_id,
            amb_context_code,
            entity_id,
            event_id,
            event_type_code,
            ae_header_id,
            ledger_id,
            accounting_date,
            period_name,
            reference_date,
            balance_type_code,
            je_category_name,
            gl_transfer_status_code,
            gl_transfer_date,
            accounting_entry_status_code,
            accounting_entry_type_code,
            description,
            budget_version_id,
            funds_status_code,
            encumbrance_type_id,
            completed_date,
            doc_sequence_id,
            doc_sequence_value,
            doc_category_code,
            packet_id,
            group_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_id,
            program_application_id,
            program_update_date,
            request_id,
            close_acct_seq_assign_id,
            close_acct_seq_version_id,
            close_acct_seq_value,
            completion_acct_seq_assign_id,
            completion_acct_seq_version_id,
            completion_acct_seq_value,
            accounting_batch_id,
            product_rule_type_code,
            product_rule_code,
            product_rule_version,
            upg_source_application_id,
            upg_valid_flag
      ) values (
            l_upg_batch_id,             -- upg_batch_id
            c_application_id,           -- application_id
            c_amb_context_code,         -- amb_context_code
            xla_transaction_entities_s.currval,
                                        -- entity_id
            xla_events_s.currval,       -- event_id
            event_type_code,            -- event_type_code
            xla_ae_headers_s.currval,   -- ae_header_id
            set_of_books_id,            -- ledger_id
            calendar_period_close_date, -- accounting_date
            period_name,                -- period_name
            null,                       -- reference_date
            'A',                        -- balance_type_code
            je_category_name,           -- je_category_name
            decode(je_hdr_id, null, 'N' -- Bug 6811554
                            ,'Y'),      -- gl_transfer_status_code
            null,                       -- gl_transfer_date
            'F',                        -- accounting_entry_status_code
            'STANDARD',                 -- accounting_entry_type_code
            description,                -- description
            null,                       -- budget_version_id
            null,                       -- funds_status_code
            null,                       -- encumbrance_type_id
            null,                       -- completed_date
            null,                       -- doc_sequence_id
            null,                       -- doc_sequence_value
            null,                       -- doc_category_code
            null,                       -- packet_id
            null,                       -- group_id
            sysdate,                    -- creation_date
            c_fnd_user,                 -- created_by
            sysdate,                    -- last_update_date
            c_fnd_user,                 -- last_updated_by
            c_upgrade_bugno,            -- last_update_login
            null,                       -- program_id
            c_application_id,           -- program_application_id
            sysdate,                    -- program_update_date
            null,                       -- request_id
            null,                       -- close_acct_seq_assign_id
            null,                       -- close_acct_seq_version_id
            null,                       -- close_acct_seq_value
            null,                       -- completion_acct_seq_assign_id
            null,                       -- completion_acct_seq_version_id
            null,                       -- completion_acct_seq_value
            null,                       -- accounting_batch_id
            null,                       -- product_rule_type_code
            null,                       -- product_rule_code
            null,                       -- product_rule_version
            c_application_id,           -- upg_source_application_id
            null                        -- upg_valid_flag
      )
      -- Bug 7498880: Added hint to use GL_PERIOD_STATUSES_U1
      select /*+ leading(th bc dp ps) rowid(th) swap_join_inputs(bc) swap_join_inputs(dp) index(ps GL_PERIOD_STATUSES_U1)*/
             bc.set_of_books_id                 set_of_books_id,
             th.transaction_header_id           transaction_header_id,
             bc.book_type_code                  book_type_code,
             bc.org_id                          org_id,
             decode(th.transaction_type_code,
                'ADDITION', decode (ah.asset_type,
                                    'CIP', 'CAPITALIZATIONS',
                                    'ADDITIONS'),
                'ADJUSTMENT', 'ADJUSTMENTS',
                'CIP ADDITION', 'CIP_ADDITIONS',
                'CIP ADJUSTMENT', 'CIP_ADJUSTMENTS',
                'CIP REVERSE', 'REVERSE CAPITALIZATIONS',
                'CIP REINSTATEMENT', 'CIP_REINSTATEMENTS',
                'CIP RETIREMENT', 'CIP_RETIREMENTS',
                'CIP TRANSFER', 'CIP_TRANSFERS',
                'CIP UNIT ADJUSTMENTS', 'CIP_UNIT_ADJUSTMENTS',
                'FULL RETIREMENT', 'RETIREMENTS',
                'PARTIAL RETIREMENT', 'RETIREMENTS',
                'RECLASS', 'CATEGORY_RECLASS',
                'REINSTATEMENT', 'REINSTATEMENTS',
                'REVALUATION', 'REVALUATION',
                'TRANSFER', 'TRANSFERS',
                'TRANSFER IN', 'TRANSFERS',
                'TRANSFER IN/VOID', 'TRANSFERS',
                'TRANSFER OUT', 'TRANSFERS',
                'UNIT ADJUSTMENT', 'UNIT_ADJUSTMENTS',
                'UNPLANNED DEPRN', 'UNPLANNED_DEPRECIATION',
                'TAX', 'DEPRECIATION_ADJUSTMENTS',
                'OTHER'
             )                                  event_class_code,
             decode(th.transaction_type_code,
                'ADDITION', decode (ah.asset_type,
                                    'CIP', 'CAPITALIZATIONS',
                                    'ADDITIONS'),
                'ADJUSTMENT', 'ADJUSTMENTS',
                'CIP ADDITION', 'CIP_ADDITIONS',
                'CIP ADJUSTMENT', 'CIP_ADJUSTMENTS',
                'CIP REVERSE', 'REVERSE CAPITALIZATIONS',
                'CIP REINSTATEMENT', 'CIP_REINSTATEMENTS',
                'CIP RETIREMENT', 'CIP_RETIREMENTS',
                'CIP TRANSFER', 'CIP_TRANSFERS',
                'CIP UNIT ADJUSTMENTS', 'CIP_UNIT_ADJUSTMENTS',
                'FULL RETIREMENT', 'RETIREMENTS',
                'PARTIAL RETIREMENT', 'RETIREMENTS',
                'RECLASS', 'CATEGORY_RECLASS',
                'REINSTATEMENT', 'REINSTATEMENTS',
                'REVALUATION', 'REVALUATION',
                'TRANSFER', 'TRANSFERS',
                'TRANSFER IN', 'TRANSFERS',
                'TRANSFER IN/VOID', 'TRANSFERS',
                'TRANSFER OUT', 'TRANSFERS',
                'UNIT ADJUSTMENT', 'UNIT_ADJUSTMENTS',
                'UNPLANNED DEPRN', 'UNPLANNED_DEPRECIATION',
                'TAX', 'DEPRECIATION_ADJUSTMENTS',
                'OTHER'
             )                                  event_type_code,
             th.transaction_date_entered        transaction_date_entered,
             dp.period_name                     period_name,
             dp.calendar_period_close_date      calendar_period_close_date,
             th.date_effective                  date_effective,
             nvl (decode(th.transaction_type_code,
                'ADDITION',             bc.je_addition_category,
                'ADJUSTMENT',           bc.je_adjustment_category,
                'CIP ADDITION',         bc.je_cip_addition_category,
                'CIP ADJUSTMENT',       bc.je_cip_adjustment_category,
                'CIP REVERSE',          bc.je_cip_addition_category,
                'CIP REINSTATEMENT',    bc.je_cip_retirement_category,
                'CIP RETIREMENT',       bc.je_cip_retirement_category,
                'CIP TRANSFER',         bc.je_cip_transfer_category,
                'CIP UNIT ADJUSTMENTS', bc.je_cip_transfer_category,
                'FULL RETIREMENT',      bc.je_retirement_category,
                'PARTIAL RETIREMENT',   bc.je_retirement_category,
                'RECLASS',              bc.je_reclass_category,
                'REINSTATEMENT',        bc.je_retirement_category,
                'REVALUATION',          bc.je_reval_category,
                'TRANSFER',             bc.je_transfer_category,
                'TRANSFER IN',          bc.je_transfer_category,
                'TRANSFER IN/VOID',     bc.je_transfer_category,
                'TRANSFER OUT',         bc.je_transfer_category,
                'UNIT ADJUSTMENT',      bc.je_transfer_category,
                'UNPLANNED DEPRN',      bc.je_depreciation_category,
                'TAX',                  bc.je_deprn_adjustment_category
             ), 'OTHER')                        je_category_name,
             lk.description || ' - ' ||
                to_char(dp.calendar_period_close_date, 'DD-MON-RR')
                                                description,
             dp.period_counter                  period_counter,
             th.asset_id                        asset_id,
             th.event_id                        event_id,  -- Bug 6811554
             decode(th.event_id, -2, 'U',
                                 -3, 'I',
                                 'P') event_status_code,   -- Bug 6811554
             decode(th.event_id, -2, 'U',
                                 -3, 'U',
                                 'P') process_status_code, -- Bug 6811554
             (select min(je_header_id)
              from   fa_adjustments adj
              where  adj.book_type_code = th.book_type_code
              and    adj.asset_id = th.asset_id
              and    adj.transaction_header_id = th.transaction_header_id
              and    nvl(adj.je_header_id,-1) > 0) je_hdr_id -- Bug 6811554
      from   fa_transaction_headers th,
             fa_book_controls bc,
             fa_deprn_periods dp,
             gl_period_statuses ps,
             fa_lookups_tl lk,
             fa_asset_history ah
      where th.rowid between p_start_rowid and p_end_rowid
      and   th.member_transaction_header_id is null
      and   (th.event_id is null or th.event_id in (-2,-3)) -- Bug 6811554
      and   ps.application_id = 101
      and   ((ps.migration_status_code in ('P', 'U')) or
             (dp.period_close_date is null))
      and   substr (dp.xla_conversion_status, 1, 1) in
            ('H', 'U', 'E', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
      and   dp.xla_conversion_status not in ('UT', 'UA')
      and   ps.set_of_books_id = bc.set_of_books_id
      and   ps.period_name = dp.period_name
      and   th.book_type_code = bc.book_type_code
      and   dp.book_type_code = bc.book_type_code
      and   th.date_effective between dp.period_open_date and
                                      nvl(dp.period_close_date, sysdate)
      and   th.asset_id = ah.asset_id (+)
      and   th.transaction_header_id = ah.transaction_header_id_out (+)
      and   th.transaction_type_code = lk.lookup_code
      and   lk.lookup_type = 'FAXOLTRX'
      and   userenv('LANG') = lk.language
      and   (exists
      (
       select /*+ index(adj, FA_ADJUSTMENTS_U1) */
              'x'
       from   fa_adjustments adj
       where  th.transaction_header_id = adj.transaction_header_id
       and    bc.book_type_code = adj.book_type_code
       and    th.asset_id = adj.asset_id
      ) or th.event_id = -3)  -- Bug 9055709
   union all -- Added for bug6820729
   -- Bug 7498880: Added hint to use GL_PERIOD_STATUSES_U1
   select /*+ leading(th bc dp ps) rowid(th) swap_join_inputs(bc) swap_join_inputs(dp) index(ps GL_PERIOD_STATUSES_U1)*/
             bc.set_of_books_id                 set_of_books_id,
             th.transaction_header_id           transaction_header_id,
             bc.book_type_code                  book_type_code,
             bc.org_id                          org_id,
             decode(th.transaction_type_code,
                'CIP REINSTATEMENT', 'CIP_REINSTATEMENTS',
                'CIP TRANSFER', 'CIP_TRANSFERS',
                'CIP UNIT ADJUSTMENTS', 'CIP_UNIT_ADJUSTMENTS',
                'RECLASS', 'CATEGORY_RECLASS',
                'REINSTATEMENT', 'REINSTATEMENTS',
                'TRANSFER', 'TRANSFERS',
                'TRANSFER OUT', 'TRANSFERS',
                'UNIT ADJUSTMENT', 'UNIT_ADJUSTMENTS',
                'OTHER'
             )                                  event_class_code,
             decode(th.transaction_type_code,
                'CIP REINSTATEMENT', 'CIP_REINSTATEMENTS',
                'CIP TRANSFER', 'CIP_TRANSFERS',
                'CIP UNIT ADJUSTMENTS', 'CIP_UNIT_ADJUSTMENTS',
                'RECLASS', 'CATEGORY_RECLASS',
                'REINSTATEMENT', 'REINSTATEMENTS',
                'TRANSFER', 'TRANSFERS',
                'TRANSFER OUT', 'TRANSFERS',
                'UNIT ADJUSTMENT', 'UNIT_ADJUSTMENTS',
                'OTHER'
             )                                  event_type_code,
             th.transaction_date_entered        transaction_date_entered,
             dp.period_name                     period_name,
             dp.calendar_period_close_date      calendar_period_close_date,
             th.date_effective                  date_effective,
             nvl (decode(th.transaction_type_code,
                'CIP REINSTATEMENT',    bc.je_cip_retirement_category,
                'CIP TRANSFER',         bc.je_cip_transfer_category,
                'CIP UNIT ADJUSTMENTS', bc.je_cip_transfer_category,
                'RECLASS',              bc.je_reclass_category,
                'REINSTATEMENT',        bc.je_retirement_category,
                'TRANSFER',             bc.je_transfer_category,
                'TRANSFER OUT',         bc.je_transfer_category,
                'UNIT ADJUSTMENT',      bc.je_transfer_category),
                'OTHER')                        je_category_name,
             lk.description || ' - ' ||
                to_char(dp.calendar_period_close_date, 'DD-MON-RR')
                                                description,
             dp.period_counter                  period_counter,
             th.asset_id                        asset_id,
             th.event_id                        event_id,  -- Bug 6811554
             decode(th.event_id, -2, 'U',
                                 -3, 'I',
                                 'P') event_status_code,   -- Bug 6811554
             decode(th.event_id, -2, 'U',
                                 -3, 'U',
                                 'P') process_status_code, -- Bug 6811554
             (select min(je_header_id)
              from   fa_adjustments adj
              where  adj.book_type_code = th.book_type_code
              and    adj.asset_id = th.asset_id
              and    adj.transaction_header_id = th.transaction_header_id
              and    nvl(adj.je_header_id,-1) > 0) je_hdr_id -- Bug 6811554
      from   fa_transaction_headers th,
             fa_book_controls bc,
             fa_deprn_periods dp,
             gl_period_statuses ps,
             fa_lookups_tl lk
      where th.rowid between p_start_rowid and p_end_rowid
      and   th.member_transaction_header_id is null
      and   (th.event_id is null or th.event_id in (-2,-3)) -- Bug 6811554
      and   ps.application_id = 101
      and   ((ps.migration_status_code in ('P', 'U')) or
             (dp.period_close_date is null))
      and   substr (dp.xla_conversion_status, 1, 1) in
            ('H', 'U', 'E', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
      and   dp.xla_conversion_status not in ('UT', 'UA')
      and   ps.set_of_books_id = bc.set_of_books_id
      and   ps.period_name = dp.period_name
      and   th.transaction_type_code in('TRANSFER','TRANSFER OUT',
                   'RECLASS','UNIT ADJUSTMENT','REINSTATEMENT',
                   'CIP REINSTATEMENT','CIP TRANSFER','CIP UNIT ADJUSTMENTS')
      and   th.book_type_code = bc.distribution_source_book
      and   bc.book_class = 'TAX'
      and   dp.book_type_code = bc.book_type_code
      and   th.date_effective between dp.period_open_date and
                                      nvl(dp.period_close_date, sysdate)
      and   th.transaction_type_code = lk.lookup_code
      and   lk.lookup_type = 'FAXOLTRX'
      and   userenv('LANG') = lk.language
      and   (exists
      (
       select /*+ index(adj, FA_ADJUSTMENTS_U1) */
              'x'
       from   fa_adjustments adj
       where  th.transaction_header_id = adj.transaction_header_id
       and    bc.book_type_code = adj.book_type_code
       and    th.asset_id = adj.asset_id
      ) or th.event_id = -3);  -- Bug 9055709

   update /*+ rowid(th) */
          fa_transaction_headers th
   set    th.event_id = nvl(
   ( select ev.event_id
     from   fa_xla_upg_events_gt ev
     where  ev.transaction_header_id = th.transaction_header_id
     and    ev.book_type_code = th.book_type_code
   ), th.event_id)
   where  th.rowid between p_start_rowid and p_end_rowid;

   insert all
      when (adj_row = 1) then
      into xla_ae_lines (
                  upg_batch_id,
                  ae_header_id,
                  ae_line_num,
                  displayed_line_number,
                  application_id,
                  code_combination_id,
                  gl_transfer_mode_code,
                  accounted_dr,
                  accounted_cr,
                  currency_code,
                  currency_conversion_date,
                  currency_conversion_rate,
                  currency_conversion_type,
                  entered_dr,
                  entered_cr,
                  description,
                  accounting_class_code,
                  gl_sl_link_id,
                  gl_sl_link_table,
                  party_type_code,
                  party_id,
                  party_site_id,
                  statistical_amount,
                  ussgl_transaction_code,
                  jgzz_recon_ref,
                  control_balance_flag,
                  analytical_balance_flag,
                  upg_tax_reference_id1,
                  upg_tax_reference_id2,
                  upg_tax_reference_id3,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  program_update_date,
                  program_id,
                  program_application_id,
                  request_id,
                  gain_or_loss_flag,
                  accounting_date,
                  ledger_id
            ) values (
                  l_upg_batch_id,                 -- upg_batch_id
                  ae_header_id,                   -- ae_header_id
                  ae_line_num,                    -- ae_line_num
                  ae_line_num,                    -- displayed_line_num
                  c_application_id,               -- application_id
                  ccid1,                          -- code_combination_id
                  'S',                            -- gl_transfer_mode_code
                  debit_amount,                   -- accounted_dr
                  credit_amount,                  -- accounted_cr
                  currency_code,                  -- currency_code
                  null,                           -- currency_conversion_date
                  null,                           -- currency_conversion_rate
                  null,                           -- currency_conversion_type
                  debit_amount,                   -- entered_dr
                  credit_amount,                  -- entered_cr
                  line_desc1 || ' - ' ||
                     to_char(cal_period_close_date, 'DD-MON-RR'),
                                                  -- description
                  accounting_class_code,          -- accounting_class_code
                  decode (je_batch_id1, null, null,
                          xla_gl_sl_link_id_s.nextval), -- gl_sl_link_id -- Bug 6811554
                  'XLAJEL',                       -- gl_sl_link_table
                  null,                           -- party_type_code
                  null,                           -- party_id
                  null,                           -- party_site_id
                  null,                           -- statistical_amount
                  null,                           -- ussgl_transaction_code
                  null,                           -- glzz_recon_ref
                  null,                           -- control_balance_flag
                  null,                           -- analytical_balance_flag
                  null,                           -- upg_tax_reference_id1
                  null,                           -- upg_tax_reference_id2
                  null,                           -- upg_tax_reference_id3
                  sysdate,                        -- creation_date
                  c_fnd_user,                     -- created_by
                  sysdate,                        -- last_update_date
                  c_fnd_user,                     -- last_updated_by
                  c_upgrade_bugno,                -- last_update_login
                  null,                           -- program_update_date
                  null,                           -- program_id
                  c_application_id,               -- program_application_id
                  null,                           -- request_id
                  'N',                            -- gain_or_loss_flag
                  cal_period_close_date,          -- accounting_date
                  set_of_books_id                 -- ledger_id
            )
      when (adj_row = 1) then
      into xla_distribution_links (
                  upg_batch_id,
                  application_id,
                  event_id,
                  ae_header_id,
                  ae_line_num,
                  accounting_line_code,
                  accounting_line_type_code,
                  source_distribution_type,
                  source_distribution_id_char_1,
                  source_distribution_id_char_2,
                  source_distribution_id_char_3,
                  source_distribution_id_char_4,
                  source_distribution_id_char_5,
                  source_distribution_id_num_1,
                  source_distribution_id_num_2,
                  source_distribution_id_num_3,
                  source_distribution_id_num_4,
                  source_distribution_id_num_5,
                  merge_duplicate_code,
                  statistical_amount,
                  unrounded_entered_dr,
                  unrounded_entered_cr,
                  unrounded_accounted_dr,
                  unrounded_accounted_cr,
                  ref_ae_header_id,
                  ref_temp_line_num,
                  ref_event_id,
                  temp_line_num,
                  tax_line_ref_id,
                  tax_summary_line_ref_id,
                  tax_rec_nrec_dist_ref_id,
                  line_definition_owner_code,
                  line_definition_code,
                  event_class_code,
                  event_type_code
      ) values (
                  l_upg_batch_id,              -- upg_batch_id
                  c_application_id,            -- application_id
                  event_id,                    -- event_id
                  ae_header_id,                -- ae_header_id
                  ae_line_num,                 -- ae_line_num
                  null,                        -- accounting_line_code
                  'S',                         -- accounting_line_type_code
                  'TRX',                       -- source_distribution_type
                  null,                        -- source_distribution_id_char_1
                  null,                        -- source_distribution_id_char_2
                  null,                        -- source_distribution_id_char_3
                  null,                        -- source_distribution_id_char_4
                  null,                        -- source_distribution_id_char_5
                  transaction_header_id,       -- source_distribution_id_num_1
                  adj_line_id,                 -- source_distribution_id_num_2
                  null,                        -- source_distribution_id_num_3
                  null,                        -- source_distribution_id_num_4
                  null,                        -- source_distribution_id_num_5
                  'N',                         -- merge_duplicate_code
                  null,                        -- statistical_amount
                  debit_amount,                -- unrounded_entered_dr
                  credit_amount,               -- unrounded_entered_cr
                  debit_amount,                -- unrounded_accounted_dr
                  credit_amount,               -- unrounded_accounted_cr
                  ae_header_id,                -- ref_ae_header_id
                  null,                        -- ref_temp_line_num
                  null,                        -- ref_event_id
                  ae_line_num,                 -- temp_line_num
                  null,                        -- tax_line_ref_id
                  null,                        -- tax_summary_line_ref_id
                  null,                        -- tax_rec_nrec_dist_ref_id
                  null,                        -- line_definition_owner_code
                  null,                        -- line_definition_code
                  event_class_code,            -- event_class_code
                  event_type_code              -- event_type_code
      )
      when (adj_row = 1) and (je_batch_id1 is not null) then
      into gl_import_references (
                     je_batch_id,
                     je_header_id,
                     je_line_num,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     reference_1,
                     reference_2,
                     reference_3,
                     reference_4,
                     reference_5,
                     reference_6,
                     reference_7,
                     reference_8,
                     reference_9,
                     reference_10,
                     subledger_doc_sequence_id,
                     subledger_doc_sequence_value,
                     gl_sl_link_id,
                     gl_sl_link_table
      ) values (
                     je_batch_id1,                -- je_batch_id
                     je_header_id1,               -- je_header_id
                     je_line_num1,                -- je_line_num
                     sysdate,                     -- last_update_date
                     c_fnd_user,                  -- last_updated_by
                     sysdate,                     -- creation_date
                     c_fnd_user,                  -- created_by
                     c_upgrade_bugno,             -- last_update_login
                     to_char(transaction_header_id),
                                                  -- reference_1
                     to_char(asset_id),           -- reference_2
                     to_char(distribution_id),    -- reference_3
                     to_char(adj_line_id),        -- reference_4
                     book_type_code,              -- reference_5
                     to_char(period_counter),     -- reference_6
                     null,                        -- reference_7
                     null,                        -- reference_8
                     null,                        -- reference_9
                     null,                        -- reference_10
                     null,                        -- subledger_doc_seq_id
                     null,                        -- subledger_doc_seq_value
                     xla_gl_sl_link_id_s.currval, -- gl_sl_link_id
                     'XLAJEL'                     -- gl_sl_link_table
      )
      when (adj_row = 2) then
      into xla_ae_lines (
                  upg_batch_id,
                  ae_header_id,
                  ae_line_num,
                  displayed_line_number,
                  application_id,
                  code_combination_id,
                  gl_transfer_mode_code,
                  accounted_dr,
                  accounted_cr,
                  currency_code,
                  currency_conversion_date,
                  currency_conversion_rate,
                  currency_conversion_type,
                  entered_dr,
                  entered_cr,
                  description,
                  accounting_class_code,
                  gl_sl_link_id,
                  gl_sl_link_table,
                  party_type_code,
                  party_id,
                  party_site_id,
                  statistical_amount,
                  ussgl_transaction_code,
                  jgzz_recon_ref,
                  control_balance_flag,
                  analytical_balance_flag,
                  upg_tax_reference_id1,
                  upg_tax_reference_id2,
                  upg_tax_reference_id3,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  program_update_date,
                  program_id,
                  program_application_id,
                  request_id,
                  gain_or_loss_flag,
                  accounting_date,
                  ledger_id
            ) values (
                  l_upg_batch_id,                 -- upg_batch_id
                  ae_header_id,                   -- ae_header_id
                  ae_line_num,                    -- ae_line_num
                  ae_line_num,                    -- displayed_line_num
                  c_application_id,               -- application_id
                  ccid2,                          -- code_combination_id
                  'S',                            -- gl_transfer_mode_code
                  -- Fix for Bug #5131737.  Need to switch CR/DR for pseudo-row
                  credit_amount,                  -- accounted_dr
                  debit_amount,                   -- accounted_cr
                  currency_code,                  -- currency_code
                  null,                           -- currency_conversion_date
                  null,                           -- currency_conversion_rate
                  null,                           -- currency_conversion_type
                  credit_amount,                  -- entered_dr
                  debit_amount,                   -- entered_cr
                  line_desc2 || ' - ' ||
                     to_char(cal_period_close_date, 'DD-MON-RR'),
                                                  -- description
                  'ASSET',                        -- accounting_class_code
                  decode (je_batch_id2, null, null,
                          xla_gl_sl_link_id_s.nextval), -- gl_sl_link_id -- Bug 6811554
                  'XLAJEL',                       -- gl_sl_link_table
                  null,                           -- party_type_code
                  null,                           -- party_id
                  null,                           -- party_site_id
                  null,                           -- statistical_amount
                  null,                           -- ussgl_transaction_code
                  null,                           -- glzz_recon_ref
                  null,                           -- control_balance_flag
                  null,                           -- analytical_balance_flag
                  null,                           -- upg_tax_reference_id1
                  null,                           -- upg_tax_reference_id2
                  null,                           -- upg_tax_reference_id3
                  sysdate,                        -- creation_date
                  c_fnd_user,                     -- created_by
                  sysdate,                        -- last_update_date
                  c_fnd_user,                     -- last_updated_by
                  c_upgrade_bugno,                -- last_update_login
                  null,                           -- program_update_date
                  null,                           -- program_id
                  c_application_id,               -- program_application_id
                  null,                           -- request_id
                  'N',                            -- gain_or_loss_flag
                  cal_period_close_date,          -- accounting_date
                  set_of_books_id                 -- ledger_id
            )
      when (adj_row = 2) then
      into xla_distribution_links (
                  upg_batch_id,
                  application_id,
                  event_id,
                  ae_header_id,
                  ae_line_num,
                  accounting_line_code,
                  accounting_line_type_code,
                  source_distribution_type,
                  source_distribution_id_char_1,
                  source_distribution_id_char_2,
                  source_distribution_id_char_3,
                  source_distribution_id_char_4,
                  source_distribution_id_char_5,
                  source_distribution_id_num_1,
                  source_distribution_id_num_2,
                  source_distribution_id_num_3,
                  source_distribution_id_num_4,
                  source_distribution_id_num_5,
                  merge_duplicate_code,
                  statistical_amount,
                  unrounded_entered_dr,
                  unrounded_entered_cr,
                  unrounded_accounted_dr,
                  unrounded_accounted_cr,
                  ref_ae_header_id,
                  ref_temp_line_num,
                  ref_event_id,
                  temp_line_num,
                  tax_line_ref_id,
                  tax_summary_line_ref_id,
                  tax_rec_nrec_dist_ref_id,
                  line_definition_owner_code,
                  line_definition_code,
                  event_class_code,
                  event_type_code
      ) values (
                  l_upg_batch_id,              -- upg_batch_id
                  c_application_id,            -- application_id
                  event_id,                    -- event_id
                  ae_header_id,                -- ae_header_id
                  ae_line_num,                 -- ae_line_num
                  null,                        -- accounting_line_code
                  'S',                         -- accounting_line_type_code
                  'TRX',                       -- source_distribution_type
                  null,                        -- source_distribution_id_char_1
                  null,                        -- source_distribution_id_char_2
                  null,                        -- source_distribution_id_char_3
                  null,                        -- source_distribution_id_char_4
                  null,                        -- source_distribution_id_char_5
                  transaction_header_id,       -- source_distribution_id_num_1
                  adj_line_id,                 -- source_distribution_id_num_2
                  null,                        -- source_distribution_id_num_3
                  null,                        -- source_distribution_id_num_4
                  null,                        -- source_distribution_id_num_5
                  'N',                         -- merge_duplicate_code
                  null,                        -- statistical_amount
                  -- Fix for Bug #5131737.  Need to switch CR/DR for pseudo-row
                  credit_amount,               -- unrounded_entered_dr
                  debit_amount,                -- unrounded_entered_cr
                  credit_amount,               -- unrounded_accounted_dr
                  debit_amount,                -- unrounded_accounted_cr
                  ae_header_id,                -- ref_ae_header_id
                  null,                        -- ref_temp_line_num
                  null,                        -- ref_event_id
                  ae_line_num,                 -- temp_line_num
                  null,                        -- tax_line_ref_id
                  null,                        -- tax_summary_line_ref_id
                  null,                        -- tax_rec_nrec_dist_ref_id
                  null,                        -- line_definition_owner_code
                  null,                        -- line_definition_code
                  event_class_code,            -- event_class_code
                  event_type_code              -- event_type_code
      )
      when (adj_row = 2) and (je_batch_id2 is not null) then
      into gl_import_references (
                     je_batch_id,
                     je_header_id,
                     je_line_num,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     reference_1,
                     reference_2,
                     reference_3,
                     reference_4,
                     reference_5,
                     reference_6,
                     reference_7,
                     reference_8,
                     reference_9,
                     reference_10,
                     subledger_doc_sequence_id,
                     subledger_doc_sequence_value,
                     gl_sl_link_id,
                     gl_sl_link_table
      ) values (
                     je_batch_id2,                -- je_batch_id
                     je_header_id2,               -- je_header_id
                     je_line_num2,                -- je_line_num
                     sysdate,                     -- last_update_date
                     c_fnd_user,                  -- last_updated_by
                     sysdate,                     -- creation_date
                     c_fnd_user,                  -- created_by
                     c_upgrade_bugno,             -- last_update_login
                     to_char(transaction_header_id),
                                                  -- reference_1
                     to_char(asset_id),           -- reference_2
                     to_char(distribution_id),    -- reference_3
                     to_char(adj_line_id),        -- reference_4
                     book_type_code,              -- reference_5
                     to_char(period_counter),     -- reference_6
                     null,                        -- reference_7
                     null,                        -- reference_8
                     null,                        -- reference_9
                     null,                        -- reference_10
                     null,                        -- subledger_doc_seq_id
                     null,                        -- subledger_doc_seq_value
                     xla_gl_sl_link_id_s.currval, -- gl_sl_link_id
                     'XLAJEL'                     -- gl_sl_link_table
      )
      when (adj_row = 3) then
      into xla_ae_lines (
                  upg_batch_id,
                  ae_header_id,
                  ae_line_num,
                  displayed_line_number,
                  application_id,
                  code_combination_id,
                  gl_transfer_mode_code,
                  accounted_dr,
                  accounted_cr,
                  currency_code,
                  currency_conversion_date,
                  currency_conversion_rate,
                  currency_conversion_type,
                  entered_dr,
                  entered_cr,
                  description,
                  accounting_class_code,
                  gl_sl_link_id,
                  gl_sl_link_table,
                  party_type_code,
                  party_id,
                  party_site_id,
                  statistical_amount,
                  ussgl_transaction_code,
                  jgzz_recon_ref,
                  control_balance_flag,
                  analytical_balance_flag,
                  upg_tax_reference_id1,
                  upg_tax_reference_id2,
                  upg_tax_reference_id3,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  program_update_date,
                  program_id,
                  program_application_id,
                  request_id,
                  gain_or_loss_flag,
                  accounting_date,
                  ledger_id
            ) values (
                  l_upg_batch_id,                 -- upg_batch_id
                  ae_header_id,                   -- ae_header_id
                  ae_line_num,                    -- ae_line_num
                  ae_line_num,                    -- displayed_line_num
                  c_application_id,               -- application_id
                  ccid3,                          -- code_combination_id
                  'S',                            -- gl_transfer_mode_code
                  -- Fix for Bug #5131737.  Need to switch CR/DR for pseudo-row
                  credit_amount,                  -- accounted_dr
                  debit_amount,                   -- accounted_cr
                  currency_code,                  -- currency_code
                  null,                           -- currency_conversion_date
                  null,                           -- currency_conversion_rate
                  null,                           -- currency_conversion_type
                  credit_amount,                  -- entered_dr
                  debit_amount,                   -- entered_cr
                  l_bonus_deprn_rsv_desc || ' - ' ||
                     to_char(cal_period_close_date, 'DD-MON-RR'),
                                                  -- description
                  'ASSET',                        -- accounting_class_code
                  decode (je_batch_id3, null, null,
                          xla_gl_sl_link_id_s.nextval), -- gl_sl_link_id -- Bug 6811554
                  'XLAJEL',                       -- gl_sl_link_table
                  null,                           -- party_type_code
                  null,                           -- party_id
                  null,                           -- party_site_id
                  null,                           -- statistical_amount
                  null,                           -- ussgl_transaction_code
                  null,                           -- glzz_recon_ref
                  null,                           -- control_balance_flag
                  null,                           -- analytical_balance_flag
                  null,                           -- upg_tax_reference_id1
                  null,                           -- upg_tax_reference_id2
                  null,                           -- upg_tax_reference_id3
                  sysdate,                        -- creation_date
                  c_fnd_user,                     -- created_by
                  sysdate,                        -- last_update_date
                  c_fnd_user,                     -- last_updated_by
                  c_upgrade_bugno,                -- last_update_login
                  null,                           -- program_update_date
                  null,                           -- program_id
                  c_application_id,               -- program_application_id
                  null,                           -- request_id
                  'N',                            -- gain_or_loss_flag
                  cal_period_close_date,          -- accounting_date
                  set_of_books_id                 -- ledger_id
            )
      when (adj_row = 3) then
      into xla_distribution_links (
                  upg_batch_id,
                  application_id,
                  event_id,
                  ae_header_id,
                  ae_line_num,
                  accounting_line_code,
                  accounting_line_type_code,
                  source_distribution_type,
                  source_distribution_id_char_1,
                  source_distribution_id_char_2,
                  source_distribution_id_char_3,
                  source_distribution_id_char_4,
                  source_distribution_id_char_5,
                  source_distribution_id_num_1,
                  source_distribution_id_num_2,
                  source_distribution_id_num_3,
                  source_distribution_id_num_4,
                  source_distribution_id_num_5,
                  merge_duplicate_code,
                  statistical_amount,
                  unrounded_entered_dr,
                  unrounded_entered_cr,
                  unrounded_accounted_dr,
                  unrounded_accounted_cr,
                  ref_ae_header_id,
                  ref_temp_line_num,
                  ref_event_id,
                  temp_line_num,
                  tax_line_ref_id,
                  tax_summary_line_ref_id,
                  tax_rec_nrec_dist_ref_id,
                  line_definition_owner_code,
                  line_definition_code,
                  event_class_code,
                  event_type_code
      ) values (
                  l_upg_batch_id,              -- upg_batch_id
                  c_application_id,            -- application_id
                  event_id,                    -- event_id
                  ae_header_id,                -- ae_header_id
                  ae_line_num,                 -- ae_line_num
                  null,                        -- accounting_line_code
                  'S',                         -- accounting_line_type_code
                  'TRX',                       -- source_distribution_type
                  null,                        -- source_distribution_id_char_1
                  null,                        -- source_distribution_id_char_2
                  null,                        -- source_distribution_id_char_3
                  null,                        -- source_distribution_id_char_4
                  null,                        -- source_distribution_id_char_5
                  transaction_header_id,       -- source_distribution_id_num_1
                  adj_line_id,                 -- source_distribution_id_num_2
                  null,                        -- source_distribution_id_num_3
                  null,                        -- source_distribution_id_num_4
                  null,                        -- source_distribution_id_num_5
                  'N',                         -- merge_duplicate_code
                  null,                        -- statistical_amount
                  -- Fix for Bug #5131737.  Need to switch CR/DR for pseudo-row
                  credit_amount,               -- unrounded_entered_dr
                  debit_amount,                -- unrounded_entered_cr
                  credit_amount,               -- unrounded_accounted_dr
                  debit_amount,                -- unrounded_accounted_cr
                  ae_header_id,                -- ref_ae_header_id
                  null,                        -- ref_temp_line_num
                  null,                        -- ref_event_id
                  ae_line_num,                 -- temp_line_num
                  null,                        -- tax_line_ref_id
                  null,                        -- tax_summary_line_ref_id
                  null,                        -- tax_rec_nrec_dist_ref_id
                  null,                        -- line_definition_owner_code
                  null,                        -- line_definition_code
                  event_class_code,            -- event_class_code
                  event_type_code              -- event_type_code
      )
      when (adj_row = 3) and (je_batch_id3 is not null) then
      into gl_import_references (
                     je_batch_id,
                     je_header_id,
                     je_line_num,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     reference_1,
                     reference_2,
                     reference_3,
                     reference_4,
                     reference_5,
                     reference_6,
                     reference_7,
                     reference_8,
                     reference_9,
                     reference_10,
                     subledger_doc_sequence_id,
                     subledger_doc_sequence_value,
                     gl_sl_link_id,
                     gl_sl_link_table
      ) values (
                     je_batch_id3,                -- je_batch_id
                     je_header_id3,               -- je_header_id
                     je_line_num3,                -- je_line_num
                     sysdate,                     -- last_update_date
                     c_fnd_user,                  -- last_updated_by
                     sysdate,                     -- creation_date
                     c_fnd_user,                  -- created_by
                     c_upgrade_bugno,             -- last_update_login
                     to_char(transaction_header_id),
                                                  -- reference_1
                     to_char(asset_id),           -- reference_2
                     to_char(distribution_id),    -- reference_3
                     to_char(adj_line_id),        -- reference_4
                     book_type_code,              -- reference_5
                     to_char(period_counter),     -- reference_6
                     null,                        -- reference_7
                     null,                        -- reference_8
                     null,                        -- reference_9
                     null,                        -- reference_10
                     null,                        -- subledger_doc_seq_id
                     null,                        -- subledger_doc_seq_value
                     xla_gl_sl_link_id_s.currval, -- gl_sl_link_id
                     'XLAJEL'                     -- gl_sl_link_table
      )
       -- Bug 7498880: Added hint to use FA_ASSET_HISTORY_N2 index
       select /*+ ordered index(adj, FA_ADJUSTMENTS_U1) use_nl(cb) index(cb, fa_category_books_u1) index(AH FA_ASSET_HISTORY_N2)*/
             adj.adjustment_line_id                    adj_line_id,
             decode(adj.debit_credit_flag,
                    'DR', adj.adjustment_amount, null) debit_amount,
             decode(adj.debit_credit_flag,
                    'CR', adj.adjustment_amount, null) credit_amount,
             adj.code_combination_id                   ccid1,
             nvl(nvl(gljl2.code_combination_id,
                     da.deprn_reserve_account_ccid),
                     cb.reserve_account_ccid)          ccid2,
             nvl(nvl(gljl3.code_combination_id,
                     da.deprn_reserve_account_ccid),
                     cb.reserve_account_ccid)          ccid3,
             glsob.currency_code                       currency_code,
             decode (adj.adjustment_type,
                'BONUS EXPENSE', 'EXPENSE',
                'BONUS RESERVE', 'ASSET',
                'CIP COST', 'ASSET',
                'COST', 'ASSET',
                'COST CLEARING', 'ASSET',
                'DEPRN ADJUST', 'EXPENSE',
                'EXPENSE', 'EXPENSE',
                'GRP COR RESERVE', 'ASSET',
                'GRP PRC RESERVE', 'ASSET',
                'INTERCO AP', 'LIABILITY',
                'INTERCO AR', 'ASSET',
                'NBV RETIRED', 'ASSET',
                'PROCEEDS', 'ASSET',
                'PROCEEDS CLR', 'ASSET',
                'REMOVALCOST', 'ASSET',
                'REMOVALCOST CLR', 'ASSET',
                'RESERVE', 'ASSET',
                'REVAL RESERVE', 'ASSET',
                'REVAL RSV RET', 'ASSET',
                'REVAL AMORT', 'EXPENSE',
                'REVAL EXPENSE', 'EXPENSE',
                'ASSET')                               accounting_class_code,
             lk.description                            line_desc1,
             lk2.description                           line_desc2,
             decode(adj.je_header_id, null, 'N', 'Y')  gl_transfer_status_code,
             gljh.je_batch_id                          je_batch_id1,
             gljh2.je_batch_id                         je_batch_id2,
             gljh2.je_batch_id                         je_batch_id3,
             adj.je_header_id                          je_header_id1,
             dd.je_header_id                           je_header_id2,
             dd.je_header_id                           je_header_id3,
             nvl(adj.je_line_num, 0)                   je_line_num1,
             nvl(dd.deprn_reserve_je_line_num,
                nvl(adj.je_line_num, 0))               je_line_num2,
             nvl(dd.bonus_deprn_rsv_je_line_num,
                nvl(adj.je_line_num, 0))               je_line_num3,
             adj.distribution_id                       distribution_id,
             ev.event_id                               event_id,
             he.ae_header_id                           ae_header_id,
             ev.calendar_period_close_date             cal_period_close_date,
             ev.transaction_header_id                  transaction_header_id,
             ev.event_type_code                        event_type_code,
             ev.event_class_code                       event_class_code,
             ev.asset_id                               asset_id,
             ev.book_type_code                         book_type_code,
             he.set_of_books_id                        set_of_books_id,
             ev.period_counter                         period_counter,
             adj.source_type_code                      source_type_code,
             adj.adjustment_type                       adjustment_type,
             row_number() over
                (partition by ev.transaction_header_id
                 order by adj.adjustment_line_id, mult.adj_row)    ae_line_num,
             mult.adj_row                         adj_row
      from
             fa_xla_upg_events_gt ev,
             fa_xla_upg_headers_gt he,
             fa_adjustments adj,
             fa_lookups_tl lk,
             fa_lookups_tl lk2,
             gl_je_headers gljh,
             fa_deprn_detail dd,
             gl_je_headers gljh2,
             gl_je_lines gljl2,
             gl_je_lines gljl3,
             fa_book_controls bc,
             gl_sets_of_books glsob,
             fa_distribution_accounts da,
             fa_asset_history ah,
             fa_category_books cb,
             (select 1 adj_row from dual
              union all
              select 2 adj_row from dual
              union all
              select 3 adj_row from dual) mult
      where  ev.event_id = he.event_id
      and    bc.book_type_code = ev.book_type_code
      and    bc.set_of_books_id = glsob.set_of_books_id
      and    bc.book_type_code = adj.book_type_code
      and    he.set_of_books_id = bc.set_of_books_id
      and    adj.asset_id = ev.asset_id
      and    adj.book_type_code = ev.book_type_code
      and    adj.period_counter_created = ev.period_counter
      and    adj.transaction_header_id = ev.transaction_header_id
      and    adj.code_combination_id is not null
      and    nvl(adj.track_member_flag, 'N') = 'N'
      and    lk.lookup_type = 'JOURNAL ENTRIES'
      and    lk.lookup_code = decode (adj.adjustment_type,
                              'BONUS EXPENSE', 'BONUS DEPRECIATION EXPENSE',
                              'BONUS RESERVE', 'BONUS DEPRECIATION RESERVE',
                              'CIP COST', adj.source_type_code ||' COST',
                              adj.source_type_code ||' '|| adj.adjustment_type)
      and    lk2.lookup_type = 'JOURNAL ENTRIES'
      and    lk2.lookup_code = decode(adj.adjustment_type,
                               'EXPENSE', adj.source_type_code ||' RESERVE',
                               'BONUS EXPENSE', 'BONUS DEPRECIATION RESERVE',
                               'BONUS RESERVE', 'BONUS DEPRECIATION RESERVE',
                               'CIP COST', adj.source_type_code ||' COST',
                               adj.source_type_code ||' '||adj.adjustment_type)
      and    userenv('LANG') = lk.language
      and    userenv('LANG') = lk2.language
      and    adj.je_header_id = gljh.je_header_id (+)
      and    adj.asset_id = dd.asset_id (+)
      and    adj.book_type_code = dd.book_type_code (+)
      and    adj.distribution_id = dd.distribution_id (+)
      and    adj.period_counter_created = dd.period_counter (+)
      and    dd.je_header_id = gljl2.je_header_id (+)
      and    dd.deprn_reserve_je_line_num = gljl2.je_line_num (+)
      and    dd.je_header_id = gljh2.je_header_id (+)
      and    dd.je_header_id = gljl3.je_header_id (+)
      and    dd.bonus_deprn_rsv_je_line_num = gljl3.je_line_num (+)
      and    adj.book_type_code = da.book_type_code (+)
      and    adj.distribution_id = da.distribution_id (+)
      and    ev.asset_id = ah.asset_id
      and    ev.date_effective >= ah.date_effective
      and    ev.date_effective < nvl(ah.date_ineffective, sysdate+1)
      and    ah.category_id = cb.category_id
      and    bc.book_type_code = cb.book_type_code
      and    ((mult.adj_row = 1)
           or ((mult.adj_row = 2) and
               (adjustment_type = 'EXPENSE') and
               (source_type_code in
                  ('DEPRECIATION', 'CIP RETIREMENT', 'RETIREMENT')))
           or ((mult.adj_row = 3) and
               (adjustment_type = 'BONUS EXPENSE') and
               (source_type_code = 'DEPRECIATION')));

   select count(*)
   into   l_mc_books
   from   fa_mc_book_controls
   where  enabled_flag = 'Y'
   and    rownum = 1;

   if (l_mc_books > 0) then

   insert all
   when 1 = 1 then
      into fa_xla_upg_headers_gt (
         ae_header_id,
         event_id,
         set_of_books_id
      ) values (
         xla_ae_headers_s.nextval,
         event_id,
         set_of_books_id
      )
   when 1 = 1 then
      into xla_ae_headers (
            upg_batch_id,
            application_id,
            amb_context_code,
            entity_id,
            event_id,
            event_type_code,
            ae_header_id,
            ledger_id,
            accounting_date,
            period_name,
            reference_date,
            balance_type_code,
            je_category_name,
            gl_transfer_status_code,
            gl_transfer_date,
            accounting_entry_status_code,
            accounting_entry_type_code,
            description,
            budget_version_id,
            funds_status_code,
            encumbrance_type_id,
            completed_date,
            doc_sequence_id,
            doc_sequence_value,
            doc_category_code,
            packet_id,
            group_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_id,
            program_application_id,
            program_update_date,
            request_id,
            close_acct_seq_assign_id,
            close_acct_seq_version_id,
            close_acct_seq_value,
            completion_acct_seq_assign_id,
            completion_acct_seq_version_id,
            completion_acct_seq_value,
            accounting_batch_id,
            product_rule_type_code,
            product_rule_code,
            product_rule_version,
            upg_source_application_id,
            upg_valid_flag
      ) values (
            l_upg_batch_id,             -- upg_batch_id
            c_application_id,           -- application_id
            c_amb_context_code,         -- amb_context_code
            entity_id,                  -- entity_id
            event_id,                   -- event_id
            event_type_code,            -- event_type_code
            xla_ae_headers_s.currval,   -- ae_header_id
            set_of_books_id,            -- ledger_id
            calendar_period_close_date, -- accounting_date
            period_name,                -- period_name
            null,                       -- reference_date
            'A',                        -- balance_type_code
            je_category_name,           -- je_category_name
            'Y',                        -- gl_transfer_status_code -- Need to revisit
            null,                       -- gl_transfer_date
            'F',                        -- accounting_entry_status_code
            'STANDARD',                 -- accounting_entry_type_code
            description,                -- description
            null,                       -- budget_version_id
            null,                       -- funds_status_code
            null,                       -- encumbrance_type_id
            null,                       -- completed_date
            null,                       -- doc_sequence_id
            null,                       -- doc_sequence_value
            null,                       -- doc_category_code
            null,                       -- packet_id
            null,                       -- group_id
            sysdate,                    -- creation_date
            c_fnd_user,                 -- created_by
            sysdate,                    -- last_update_date
            c_fnd_user,                 -- last_updated_by
            c_upgrade_bugno,            -- last_update_login
            null,                       -- program_id
            c_application_id,           -- program_application_id
            sysdate,                    -- program_update_date
            null,                       -- request_id
            null,                       -- close_acct_seq_assign_id
            null,                       -- close_acct_seq_version_id
            null,                       -- close_acct_seq_value
            null,                       -- completion_acct_seq_assign_id
            null,                       -- completion_acct_seq_version_id
            null,                       -- completion_acct_seq_value
            null,                       -- accounting_batch_id
            null,                       -- product_rule_type_code
            null,                       -- product_rule_code
            null,                       -- product_rule_version
            c_application_id,           -- upg_source_application_id
            null                        -- upg_valid_flag
      )
      select faev.entity_id         entity_id,
             faev.event_id          event_id,
             faev.event_type_code   event_type_code,
             mc.set_of_books_id     set_of_books_id,
             faev.calendar_period_close_date
                                    calendar_period_close_date,
             faev.period_name       period_name,
             faev.je_category_name  je_category_name,
             faev.description       description
      from   fa_xla_upg_events_gt faev,
             fa_mc_book_controls mc
      where  mc.book_type_code = faev.book_type_code
      and    mc.enabled_flag = 'Y';

   insert all
      when (adj_row = 1) then
      into xla_ae_lines (
                  upg_batch_id,
                  ae_header_id,
                  ae_line_num,
                  displayed_line_number,
                  application_id,
                  code_combination_id,
                  gl_transfer_mode_code,
                  accounted_dr,
                  accounted_cr,
                  currency_code,
                  currency_conversion_date,
                  currency_conversion_rate,
                  currency_conversion_type,
                  entered_dr,
                  entered_cr,
                  description,
                  accounting_class_code,
                  gl_sl_link_id,
                  gl_sl_link_table,
                  party_type_code,
                  party_id,
                  party_site_id,
                  statistical_amount,
                  ussgl_transaction_code,
                  jgzz_recon_ref,
                  control_balance_flag,
                  analytical_balance_flag,
                  upg_tax_reference_id1,
                  upg_tax_reference_id2,
                  upg_tax_reference_id3,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  program_update_date,
                  program_id,
                  program_application_id,
                  request_id,
                  gain_or_loss_flag,
                  accounting_date,
                  ledger_id
            ) values (
                  l_upg_batch_id,                 -- upg_batch_id
                  ae_header_id,                   -- ae_header_id
                  ae_line_num,                    -- ae_line_num
                  ae_line_num,                    -- displayed_line_num
                  c_application_id,               -- application_id
                  ccid1,                          -- code_combination_id
                  'S',                            -- gl_transfer_mode_code
                  debit_amount,                   -- accounted_dr
                  credit_amount,                  -- accounted_cr
                  currency_code,                  -- currency_code
                  null,                           -- currency_conversion_date
                  null,                           -- currency_conversion_rate
                  null,                           -- currency_conversion_type
                  debit_amount,                   -- entered_dr
                  credit_amount,                  -- entered_cr
                  line_desc1 || ' - ' ||
                     to_char(cal_period_close_date, 'DD-MON-RR'),
                                                  -- description
                  accounting_class_code,          -- accounting_class_code
                  xla_gl_sl_link_id_s.nextval,    -- gl_sl_link_id
                  'XLAJEL',                       -- gl_sl_link_table
                  null,                           -- party_type_code
                  null,                           -- party_id
                  null,                           -- party_site_id
                  null,                           -- statistical_amount
                  null,                           -- ussgl_transaction_code
                  null,                           -- glzz_recon_ref
                  null,                           -- control_balance_flag
                  null,                           -- analytical_balance_flag
                  null,                           -- upg_tax_reference_id1
                  null,                           -- upg_tax_reference_id2
                  null,                           -- upg_tax_reference_id3
                  sysdate,                        -- creation_date
                  c_fnd_user,                     -- created_by
                  sysdate,                        -- last_update_date
                  c_fnd_user,                     -- last_updated_by
                  c_upgrade_bugno,                -- last_update_login
                  null,                           -- program_update_date
                  null,                           -- program_id
                  c_application_id,               -- program_application_id
                  null,                           -- request_id
                  'N',                            -- gain_or_loss_flag
                  cal_period_close_date,          -- accounting_date
                  set_of_books_id                 -- ledger_id
            )
      when (adj_row = 1) then
      into xla_distribution_links (
                  upg_batch_id,
                  application_id,
                  event_id,
                  ae_header_id,
                  ae_line_num,
                  accounting_line_code,
                  accounting_line_type_code,
                  source_distribution_type,
                  source_distribution_id_char_1,
                  source_distribution_id_char_2,
                  source_distribution_id_char_3,
                  source_distribution_id_char_4,
                  source_distribution_id_char_5,
                  source_distribution_id_num_1,
                  source_distribution_id_num_2,
                  source_distribution_id_num_3,
                  source_distribution_id_num_4,
                  source_distribution_id_num_5,
                  merge_duplicate_code,
                  statistical_amount,
                  unrounded_entered_dr,
                  unrounded_entered_cr,
                  unrounded_accounted_dr,
                  unrounded_accounted_cr,
                  ref_ae_header_id,
                  ref_temp_line_num,
                  ref_event_id,
                  temp_line_num,
                  tax_line_ref_id,
                  tax_summary_line_ref_id,
                  tax_rec_nrec_dist_ref_id,
                  line_definition_owner_code,
                  line_definition_code,
                  event_class_code,
                  event_type_code
      ) values (
                  l_upg_batch_id,              -- upg_batch_id
                  c_application_id,            -- application_id
                  event_id,                    -- event_id
                  ae_header_id,                -- ae_header_id
                  ae_line_num,                 -- ae_line_num
                  null,                        -- accounting_line_code
                  'S',                         -- accounting_line_type_code
                  'TRX',                       -- source_distribution_type
                  null,                        -- source_distribution_id_char_1
                  null,                        -- source_distribution_id_char_2
                  null,                        -- source_distribution_id_char_3
                  null,                        -- source_distribution_id_char_4
                  null,                        -- source_distribution_id_char_5
                  transaction_header_id,       -- source_distribution_id_num_1
                  adj_line_id,                 -- source_distribution_id_num_2
                  null,                        -- source_distribution_id_num_3
                  null,                        -- source_distribution_id_num_4
                  null,                        -- source_distribution_id_num_5
                  'N',                         -- merge_duplicate_code
                  null,                        -- statistical_amount
                  debit_amount,                -- unrounded_entered_dr
                  credit_amount,               -- unrounded_entered_cr
                  debit_amount,                -- unrounded_accounted_dr
                  credit_amount,               -- unrounded_accounted_cr
                  ae_header_id,                -- ref_ae_header_id
                  null,                        -- ref_temp_line_num
                  null,                        -- ref_event_id
                  ae_line_num,                 -- temp_line_num
                  null,                        -- tax_line_ref_id
                  null,                        -- tax_summary_line_ref_id
                  null,                        -- tax_rec_nrec_dist_ref_id
                  null,                        -- line_definition_owner_code
                  null,                        -- line_definition_code
                  event_class_code,            -- event_class_code
                  event_type_code              -- event_type_code
      )
      when (adj_row = 1) and (je_batch_id1 is not null) then
      into gl_import_references (
                     je_batch_id,
                     je_header_id,
                     je_line_num,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     reference_1,
                     reference_2,
                     reference_3,
                     reference_4,
                     reference_5,
                     reference_6,
                     reference_7,
                     reference_8,
                     reference_9,
                     reference_10,
                     subledger_doc_sequence_id,
                     subledger_doc_sequence_value,
                     gl_sl_link_id,
                     gl_sl_link_table
      ) values (
                     je_batch_id1,                -- je_batch_id
                     je_header_id1,               -- je_header_id
                     je_line_num1,                -- je_line_num
                     sysdate,                     -- last_update_date
                     c_fnd_user,                  -- last_updated_by
                     sysdate,                     -- creation_date
                     c_fnd_user,                  -- created_by
                     c_upgrade_bugno,             -- last_update_login
                     to_char(transaction_header_id),
                                                  -- reference_1
                     to_char(asset_id),           -- reference_2
                     to_char(distribution_id),    -- reference_3
                     to_char(adj_line_id),        -- reference_4
                     book_type_code,              -- reference_5
                     to_char(period_counter),     -- reference_6
                     null,                        -- reference_7
                     null,                        -- reference_8
                     null,                        -- reference_9
                     null,                        -- reference_10
                     null,                        -- subledger_doc_seq_id
                     null,                        -- subledger_doc_seq_value
                     xla_gl_sl_link_id_s.currval, -- gl_sl_link_id
                     'XLAJEL'                     -- gl_sl_link_table
      )
      when (adj_row = 2) then
      into xla_ae_lines (
                  upg_batch_id,
                  ae_header_id,
                  ae_line_num,
                  displayed_line_number,
                  application_id,
                  code_combination_id,
                  gl_transfer_mode_code,
                  accounted_dr,
                  accounted_cr,
                  currency_code,
                  currency_conversion_date,
                  currency_conversion_rate,
                  currency_conversion_type,
                  entered_dr,
                  entered_cr,
                  description,
                  accounting_class_code,
                  gl_sl_link_id,
                  gl_sl_link_table,
                  party_type_code,
                  party_id,
                  party_site_id,
                  statistical_amount,
                  ussgl_transaction_code,
                  jgzz_recon_ref,
                  control_balance_flag,
                  analytical_balance_flag,
                  upg_tax_reference_id1,
                  upg_tax_reference_id2,
                  upg_tax_reference_id3,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  program_update_date,
                  program_id,
                  program_application_id,
                  request_id,
                  gain_or_loss_flag,
                  accounting_date,
                  ledger_id
            ) values (
                  l_upg_batch_id,                 -- upg_batch_id
                  ae_header_id,                   -- ae_header_id
                  ae_line_num,                    -- ae_line_num
                  ae_line_num,                    -- displayed_line_num
                  c_application_id,               -- application_id
                  ccid2,                          -- code_combination_id
                  'S',                            -- gl_transfer_mode_code
                  -- Fix for Bug #5131737.  Need to switch CR/DR for pseudo-row
                  credit_amount,                  -- accounted_dr
                  debit_amount,                   -- accounted_cr
                  currency_code,                  -- currency_code
                  null,                           -- currency_conversion_date
                  null,                           -- currency_conversion_rate
                  null,                           -- currency_conversion_type
                  credit_amount,                  -- entered_dr
                  debit_amount,                   -- entered_cr
                  line_desc2 || ' - ' ||
                     to_char(cal_period_close_date, 'DD-MON-RR'),
                                                  -- description
                  'ASSET',                        -- accounting_class_code
                  xla_gl_sl_link_id_s.nextval,    -- gl_sl_link_id
                  'XLAJEL',                       -- gl_sl_link_table
                  null,                           -- party_type_code
                  null,                           -- party_id
                  null,                           -- party_site_id
                  null,                           -- statistical_amount
                  null,                           -- ussgl_transaction_code
                  null,                           -- glzz_recon_ref
                  null,                           -- control_balance_flag
                  null,                           -- analytical_balance_flag
                  null,                           -- upg_tax_reference_id1
                  null,                           -- upg_tax_reference_id2
                  null,                           -- upg_tax_reference_id3
                  sysdate,                        -- creation_date
                  c_fnd_user,                     -- created_by
                  sysdate,                        -- last_update_date
                  c_fnd_user,                     -- last_updated_by
                  c_upgrade_bugno,                -- last_update_login
                  null,                           -- program_update_date
                  null,                           -- program_id
                  c_application_id,               -- program_application_id
                  null,                           -- request_id
                  'N',                            -- gain_or_loss_flag
                  cal_period_close_date,          -- accounting_date
                  set_of_books_id                 -- ledger_id
            )
      when (adj_row = 2) then
      into xla_distribution_links (
                  upg_batch_id,
                  application_id,
                  event_id,
                  ae_header_id,
                  ae_line_num,
                  accounting_line_code,
                  accounting_line_type_code,
                  source_distribution_type,
                  source_distribution_id_char_1,
                  source_distribution_id_char_2,
                  source_distribution_id_char_3,
                  source_distribution_id_char_4,
                  source_distribution_id_char_5,
                  source_distribution_id_num_1,
                  source_distribution_id_num_2,
                  source_distribution_id_num_3,
                  source_distribution_id_num_4,
                  source_distribution_id_num_5,
                  merge_duplicate_code,
                  statistical_amount,
                  unrounded_entered_dr,
                  unrounded_entered_cr,
                  unrounded_accounted_dr,
                  unrounded_accounted_cr,
                  ref_ae_header_id,
                  ref_temp_line_num,
                  ref_event_id,
                  temp_line_num,
                  tax_line_ref_id,
                  tax_summary_line_ref_id,
                  tax_rec_nrec_dist_ref_id,
                  line_definition_owner_code,
                  line_definition_code,
                  event_class_code,
                  event_type_code
      ) values (
                  l_upg_batch_id,              -- upg_batch_id
                  c_application_id,            -- application_id
                  event_id,                    -- event_id
                  ae_header_id,                -- ae_header_id
                  ae_line_num,                 -- ae_line_num
                  null,                        -- accounting_line_code
                  'S',                         -- accounting_line_type_code
                  'TRX',                       -- source_distribution_type
                  null,                        -- source_distribution_id_char_1
                  null,                        -- source_distribution_id_char_2
                  null,                        -- source_distribution_id_char_3
                  null,                        -- source_distribution_id_char_4
                  null,                        -- source_distribution_id_char_5
                  transaction_header_id,       -- source_distribution_id_num_1
                  adj_line_id,                 -- source_distribution_id_num_2
                  null,                        -- source_distribution_id_num_3
                  null,                        -- source_distribution_id_num_4
                  null,                        -- source_distribution_id_num_5
                  'N',                         -- merge_duplicate_code
                  null,                        -- statistical_amount
                  -- Fix for Bug #5131737.  Need to switch CR/DR for pseudo-row
                  credit_amount,               -- unrounded_entered_dr
                  debit_amount,                -- unrounded_entered_cr
                  credit_amount,               -- unrounded_accounted_dr
                  debit_amount,                -- unrounded_accounted_cr
                  ae_header_id,                -- ref_ae_header_id
                  null,                        -- ref_temp_line_num
                  null,                        -- ref_event_id
                  ae_line_num,                 -- temp_line_num
                  null,                        -- tax_line_ref_id
                  null,                        -- tax_summary_line_ref_id
                  null,                        -- tax_rec_nrec_dist_ref_id
                  null,                        -- line_definition_owner_code
                  null,                        -- line_definition_code
                  event_class_code,            -- event_class_code
                  event_type_code              -- event_type_code
      )
      when (adj_row = 2) and (je_batch_id2 is not null) then
      into gl_import_references (
                     je_batch_id,
                     je_header_id,
                     je_line_num,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     reference_1,
                     reference_2,
                     reference_3,
                     reference_4,
                     reference_5,
                     reference_6,
                     reference_7,
                     reference_8,
                     reference_9,
                     reference_10,
                     subledger_doc_sequence_id,
                     subledger_doc_sequence_value,
                     gl_sl_link_id,
                     gl_sl_link_table
      ) values (
                     je_batch_id2,                -- je_batch_id
                     je_header_id2,               -- je_header_id
                     je_line_num2,                -- je_line_num
                     sysdate,                     -- last_update_date
                     c_fnd_user,                  -- last_updated_by
                     sysdate,                     -- creation_date
                     c_fnd_user,                  -- created_by
                     c_upgrade_bugno,             -- last_update_login
                     to_char(transaction_header_id),
                                                  -- reference_1
                     to_char(asset_id),           -- reference_2
                     to_char(distribution_id),    -- reference_3
                     to_char(adj_line_id),        -- reference_4
                     book_type_code,              -- reference_5
                     to_char(period_counter),     -- reference_6
                     null,                        -- reference_7
                     null,                        -- reference_8
                     null,                        -- reference_9
                     null,                        -- reference_10
                     null,                        -- subledger_doc_seq_id
                     null,                        -- subledger_doc_seq_value
                     xla_gl_sl_link_id_s.currval, -- gl_sl_link_id
                     'XLAJEL'                     -- gl_sl_link_table
      )
      when (adj_row = 3) then
      into xla_ae_lines (
                  upg_batch_id,
                  ae_header_id,
                  ae_line_num,
                  displayed_line_number,
                  application_id,
                  code_combination_id,
                  gl_transfer_mode_code,
                  accounted_dr,
                  accounted_cr,
                  currency_code,
                  currency_conversion_date,
                  currency_conversion_rate,
                  currency_conversion_type,
                  entered_dr,
                  entered_cr,
                  description,
                  accounting_class_code,
                  gl_sl_link_id,
                  gl_sl_link_table,
                  party_type_code,
                  party_id,
                  party_site_id,
                  statistical_amount,
                  ussgl_transaction_code,
                  jgzz_recon_ref,
                  control_balance_flag,
                  analytical_balance_flag,
                  upg_tax_reference_id1,
                  upg_tax_reference_id2,
                  upg_tax_reference_id3,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  program_update_date,
                  program_id,
                  program_application_id,
                  request_id,
                  gain_or_loss_flag,
                  accounting_date,
                  ledger_id
            ) values (
                  l_upg_batch_id,                 -- upg_batch_id
                  ae_header_id,                   -- ae_header_id
                  ae_line_num,                    -- ae_line_num
                  ae_line_num,                    -- displayed_line_num
                  c_application_id,               -- application_id
                  ccid3,                          -- code_combination_id
                  'S',                            -- gl_transfer_mode_code
                  -- Fix for Bug #5131737.  Need to switch CR/DR for pseudo-row
                  credit_amount,                  -- accounted_dr
                  debit_amount,                   -- accounted_cr
                  currency_code,                  -- currency_code
                  null,                           -- currency_conversion_date
                  null,                           -- currency_conversion_rate
                  null,                           -- currency_conversion_type
                  credit_amount,                  -- entered_dr
                  debit_amount,                   -- entered_cr
                  l_bonus_deprn_rsv_desc || ' - ' ||
                     to_char(cal_period_close_date, 'DD-MON-RR'),
                                                  -- description
                  'ASSET',                        -- accounting_class_code
                  xla_gl_sl_link_id_s.nextval,    -- gl_sl_link_id
                  'XLAJEL',                       -- gl_sl_link_table
                  null,                           -- party_type_code
                  null,                           -- party_id
                  null,                           -- party_site_id
                  null,                           -- statistical_amount
                  null,                           -- ussgl_transaction_code
                  null,                           -- glzz_recon_ref
                  null,                           -- control_balance_flag
                  null,                           -- analytical_balance_flag
                  null,                           -- upg_tax_reference_id1
                  null,                           -- upg_tax_reference_id2
                  null,                           -- upg_tax_reference_id3
                  sysdate,                        -- creation_date
                  c_fnd_user,                     -- created_by
                  sysdate,                        -- last_update_date
                  c_fnd_user,                     -- last_updated_by
                  c_upgrade_bugno,                -- last_update_login
                  null,                           -- program_update_date
                  null,                           -- program_id
                  c_application_id,               -- program_application_id
                  null,                           -- request_id
                  'N',                            -- gain_or_loss_flag
                  cal_period_close_date,          -- accounting_date
                  set_of_books_id                 -- ledger_id
            )
      when (adj_row = 3) then
      into xla_distribution_links (
                  upg_batch_id,
                  application_id,
                  event_id,
                  ae_header_id,
                  ae_line_num,
                  accounting_line_code,
                  accounting_line_type_code,
                  source_distribution_type,
                  source_distribution_id_char_1,
                  source_distribution_id_char_2,
                  source_distribution_id_char_3,
                  source_distribution_id_char_4,
                  source_distribution_id_char_5,
                  source_distribution_id_num_1,
                  source_distribution_id_num_2,
                  source_distribution_id_num_3,
                  source_distribution_id_num_4,
                  source_distribution_id_num_5,
                  merge_duplicate_code,
                  statistical_amount,
                  unrounded_entered_dr,
                  unrounded_entered_cr,
                  unrounded_accounted_dr,
                  unrounded_accounted_cr,
                  ref_ae_header_id,
                  ref_temp_line_num,
                  ref_event_id,
                  temp_line_num,
                  tax_line_ref_id,
                  tax_summary_line_ref_id,
                  tax_rec_nrec_dist_ref_id,
                  line_definition_owner_code,
                  line_definition_code,
                  event_class_code,
                  event_type_code
      ) values (
                  l_upg_batch_id,              -- upg_batch_id
                  c_application_id,            -- application_id
                  event_id,                    -- event_id
                  ae_header_id,                -- ae_header_id
                  ae_line_num,                 -- ae_line_num
                  null,                        -- accounting_line_code
                  'S',                         -- accounting_line_type_code
                  'TRX',                       -- source_distribution_type
                  null,                        -- source_distribution_id_char_1
                  null,                        -- source_distribution_id_char_2
                  null,                        -- source_distribution_id_char_3
                  null,                        -- source_distribution_id_char_4
                  null,                        -- source_distribution_id_char_5
                  transaction_header_id,       -- source_distribution_id_num_1
                  adj_line_id,                 -- source_distribution_id_num_2
                  null,                        -- source_distribution_id_num_3
                  null,                        -- source_distribution_id_num_4
                  null,                        -- source_distribution_id_num_5
                  'N',                         -- merge_duplicate_code
                  null,                        -- statistical_amount
                  -- Fix for Bug #5131737.  Need to switch CR/DR for pseudo-row
                  credit_amount,               -- unrounded_entered_dr
                  debit_amount,                -- unrounded_entered_cr
                  credit_amount,               -- unrounded_accounted_dr
                  debit_amount,                -- unrounded_accounted_cr
                  ae_header_id,                -- ref_ae_header_id
                  null,                        -- ref_temp_line_num
                  null,                        -- ref_event_id
                  ae_line_num,                 -- temp_line_num
                  null,                        -- tax_line_ref_id
                  null,                        -- tax_summary_line_ref_id
                  null,                        -- tax_rec_nrec_dist_ref_id
                  null,                        -- line_definition_owner_code
                  null,                        -- line_definition_code
                  event_class_code,            -- event_class_code
                  event_type_code              -- event_type_code
      )
      when (adj_row = 3) and (je_batch_id3 is not null) then
      into gl_import_references (
                     je_batch_id,
                     je_header_id,
                     je_line_num,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     reference_1,
                     reference_2,
                     reference_3,
                     reference_4,
                     reference_5,
                     reference_6,
                     reference_7,
                     reference_8,
                     reference_9,
                     reference_10,
                     subledger_doc_sequence_id,
                     subledger_doc_sequence_value,
                     gl_sl_link_id,
                     gl_sl_link_table
      ) values (
                     je_batch_id3,                -- je_batch_id
                     je_header_id3,               -- je_header_id
                     je_line_num3,                -- je_line_num
                     sysdate,                     -- last_update_date
                     c_fnd_user,                  -- last_updated_by
                     sysdate,                     -- creation_date
                     c_fnd_user,                  -- created_by
                     c_upgrade_bugno,             -- last_update_login
                     to_char(transaction_header_id),
                                                  -- reference_1
                     to_char(asset_id),           -- reference_2
                     to_char(distribution_id),    -- reference_3
                     to_char(adj_line_id),        -- reference_4
                     book_type_code,              -- reference_5
                     to_char(period_counter),     -- reference_6
                     null,                        -- reference_7
                     null,                        -- reference_8
                     null,                        -- reference_9
                     null,                        -- reference_10
                     null,                        -- subledger_doc_seq_id
                     null,                        -- subledger_doc_seq_value
                     xla_gl_sl_link_id_s.currval, -- gl_sl_link_id
                     'XLAJEL'                     -- gl_sl_link_table
      )
       select /*+ ordered index(adj, FA_MC_ADJUSTMENTS_U1) use_nl(cb) index(cb, fa_category_books_u1) */
             adj.adjustment_line_id                    adj_line_id,
             decode(adj.debit_credit_flag,
                    'DR', adj.adjustment_amount, null) debit_amount,
             decode(adj.debit_credit_flag,
                    'CR', adj.adjustment_amount, null) credit_amount,
             adj.code_combination_id                   ccid1,
             nvl(nvl(gljl2.code_combination_id,
                     da.deprn_reserve_account_ccid),
                     cb.reserve_account_ccid)          ccid2,
             nvl(nvl(gljl3.code_combination_id,
                     da.deprn_reserve_account_ccid),
                     cb.reserve_account_ccid)          ccid3,
             glsob.currency_code                       currency_code,
             decode (adj.adjustment_type,
                'BONUS EXPENSE', 'EXPENSE',
                'BONUS RESERVE', 'ASSET',
                'CIP COST', 'ASSET',
                'COST', 'ASSET',
                'COST CLEARING', 'ASSET',
                'DEPRN ADJUST', 'EXPENSE',
                'EXPENSE', 'EXPENSE',
                'GRP COR RESERVE', 'ASSET',
                'GRP PRC RESERVE', 'ASSET',
                'INTERCO AP', 'LIABILITY',
                'INTERCO AR', 'ASSET',
                'NBV RETIRED', 'ASSET',
                'PROCEEDS', 'ASSET',
                'PROCEEDS CLR', 'ASSET',
                'REMOVALCOST', 'ASSET',
                'REMOVALCOST CLR', 'ASSET',
                'RESERVE', 'ASSET',
                'REVAL RESERVE', 'ASSET',
                'REVAL RSV RET', 'ASSET',
                'REVAL AMORT', 'EXPENSE',
                'REVAL EXPENSE', 'EXPENSE',
                'ASSET')                               accounting_class_code,
             lk.description                            line_desc1,
             lk2.description                           line_desc2,
             decode(adj.je_header_id, null, 'N', 'Y')  gl_transfer_status_code,
             gljh.je_batch_id                          je_batch_id1,
             gljh2.je_batch_id                         je_batch_id2,
             gljh2.je_batch_id                         je_batch_id3,
             adj.je_header_id                          je_header_id1,
             dd.je_header_id                           je_header_id2,
             dd.je_header_id                           je_header_id3,
             nvl(adj.je_line_num, 0)                   je_line_num1,
             nvl(dd.deprn_reserve_je_line_num,
                nvl(adj.je_line_num, 0))               je_line_num2,
             nvl(dd.bonus_deprn_rsv_je_line_num,
                nvl(adj.je_line_num, 0))               je_line_num3,
             adj.distribution_id                       distribution_id,
             ev.event_id                               event_id,
             he.ae_header_id                           ae_header_id,
             ev.calendar_period_close_date             cal_period_close_date,
             ev.transaction_header_id                  transaction_header_id,
             ev.event_type_code                        event_type_code,
             ev.event_class_code                       event_class_code,
             ev.asset_id                               asset_id,
             ev.book_type_code                         book_type_code,
             he.set_of_books_id                        set_of_books_id,
             ev.period_counter                         period_counter,
             adj.source_type_code                      source_type_code,
             adj.adjustment_type                       adjustment_type,
             row_number() over
                (partition by ev.transaction_header_id,
                              adj.set_of_books_id
                 order by adj.adjustment_line_id, mult.adj_row)  ae_line_num,
             mult.adj_row                              adj_row
      from
             fa_xla_upg_events_gt ev,
             fa_xla_upg_headers_gt he,
             fa_mc_adjustments adj,
             fa_lookups_tl lk,
             fa_lookups_tl lk2,
             gl_je_headers gljh,
             fa_mc_deprn_detail dd,
             gl_je_headers gljh2,
             gl_je_lines gljl2,
             gl_je_lines gljl3,
             fa_mc_book_controls bc,
             gl_sets_of_books glsob,
             fa_distribution_accounts da,
             fa_asset_history ah,
             fa_category_books cb,
             (select 1 adj_row from dual
              union all
              select 2 adj_row from dual
              union all
              select 3 adj_row from dual) mult
      where  ev.event_id = he.event_id
      and    bc.book_type_code = ev.book_type_code
      and    bc.set_of_books_id = glsob.set_of_books_id
      and    bc.book_type_code = adj.book_type_code
      and    bc.enabled_flag = 'Y'
      and    he.set_of_books_id = bc.set_of_books_id
      and    adj.set_of_books_id = bc.set_of_books_id
      and    adj.asset_id = ev.asset_id
      and    adj.book_type_code = ev.book_type_code
      and    adj.period_counter_created = ev.period_counter
      and    adj.transaction_header_id = ev.transaction_header_id
      and    adj.code_combination_id is not null
      and    nvl(adj.track_member_flag, 'N') = 'N'
      and    lk.lookup_type = 'JOURNAL ENTRIES'
      and    lk.lookup_code = decode (adj.adjustment_type,
                              'BONUS EXPENSE', 'BONUS DEPRECIATION EXPENSE',
                              'BONUS RESERVE', 'BONUS DEPRECIATION RESERVE',
                              'CIP COST', adj.source_type_code ||' COST',
                              adj.source_type_code ||' '|| adj.adjustment_type)
      and    lk2.lookup_type = 'JOURNAL ENTRIES'
      and    lk2.lookup_code = decode(adj.adjustment_type,
                               'EXPENSE', adj.source_type_code ||' RESERVE',
                               'BONUS EXPENSE', 'BONUS DEPRECIATION RESERVE',
                               'BONUS RESERVE', 'BONUS DEPRECIATION RESERVE',
                               'CIP COST', adj.source_type_code ||' COST',
                               adj.source_type_code ||' '||adj.adjustment_type)
      and    userenv('LANG') = lk.language
      and    userenv('LANG') = lk2.language
      and    adj.je_header_id = gljh.je_header_id (+)
      and    adj.asset_id = dd.asset_id (+)
      and    adj.book_type_code = dd.book_type_code (+)
      and    adj.distribution_id = dd.distribution_id (+)
      and    adj.period_counter_created = dd.period_counter (+)
      and    adj.set_of_books_id = dd.set_of_books_id (+)
      and    dd.je_header_id = gljl2.je_header_id (+)
      and    dd.deprn_reserve_je_line_num = gljl2.je_line_num (+)
      and    dd.je_header_id = gljh2.je_header_id (+)
      and    dd.je_header_id = gljl3.je_header_id (+)
      and    dd.bonus_deprn_rsv_je_line_num = gljl3.je_line_num (+)
      and    adj.book_type_code = da.book_type_code (+)
      and    adj.distribution_id = da.distribution_id (+)
      and    ev.asset_id = ah.asset_id
      and    ev.date_effective >= ah.date_effective
      and    ev.date_effective < nvl(ah.date_ineffective, sysdate+1)
      and    ah.category_id = cb.category_id
      and    bc.book_type_code = cb.book_type_code
      and    ((mult.adj_row = 1)
           or ((mult.adj_row = 2) and
               (adjustment_type = 'EXPENSE') and
               (source_type_code in
                  ('DEPRECIATION', 'CIP RETIREMENT', 'RETIREMENT')))
           or ((mult.adj_row = 3) and
               (adjustment_type = 'BONUS EXPENSE') and
               (source_type_code = 'DEPRECIATION')));

   end if;

   commit;

EXCEPTION
   WHEN OTHERS THEN
      rollback;
      raise;

End Upgrade_Trxn_Events;

Procedure Upgrade_Deprn_Events (
             p_mode                    IN            varchar,
             p_start_rowid             IN            rowid,
             p_end_rowid               IN            rowid,
             p_batch_size              IN            number,
             x_success_count              OUT NOCOPY number,
             x_failure_count              OUT NOCOPY number,
             x_return_status              OUT NOCOPY number
            ) IS

   c_application_id            constant number(15) := 140;
   c_upgrade_bugno             constant number(15) := -4107161;
   c_fnd_user                  constant number(15) := 2;


   c_entity_code               constant varchar2(30) := 'DEPRECIATION';
   c_amb_context_code          constant varchar2(30) := 'DEFAULT';

   -- this value can be altered in order to process more of less per batch
   l_batch_size                NUMBER;

   l_rows_processed            NUMBER;
   l_deprn_rows_processed      NUMBER;

   -- type for table variable
   type num_tbl_type  is table of number        index by binary_integer;
   type char_tbl_type is table of varchar2(150) index by binary_integer;
   type date_tbl_type is table of date          index by binary_integer;
   type rowid_tbl_type is table of rowid        index by binary_integer;

   l_upg_batch_id                               number;
   l_mc_books                                   number;

   l_de_description                             varchar2(80);
   l_dr_description                             varchar2(80);
   l_be_description                             varchar2(80);
   l_br_description                             varchar2(80);
   l_ra_description                             varchar2(80);
   l_rr_description                             varchar2(80);

   l_event_id_tbl                               num_tbl_type;
   l_asset_id_tbl                               num_tbl_type;
   l_book_type_code_tbl                         char_tbl_type;
   l_period_counter_tbl                         num_tbl_type;

   l_err_entity_id_tbl                          num_tbl_type;
   l_err_event_id_tbl                           num_tbl_type;
   l_err_ae_header_id_tbl                       num_tbl_type;
   l_err_ae_line_num_tbl                        num_tbl_type;
   l_err_temp_line_num_tbl                      num_tbl_type;
   l_error_message_name_tbl                     char_tbl_type;

BEGIN

   x_success_count := 0;
   x_failure_count := 0;

   l_batch_size := nvl(nvl(p_batch_size, fa_cache_pkg.fa_batch_size), 1000);

   -- Select upg_batch_id
   select xla_upg_batches_s.nextval
   into   l_upg_batch_id
   from   dual;

   select lk_de.description
   into   l_de_description
   from   fa_lookups_tl lk_de
   where  lk_de.lookup_type = 'JOURNAL ENTRIES'
   and    lk_de.lookup_code = 'DEPRECIATION EXPENSE'
   and    userenv('LANG') = lk_de.language;

   select lk_dr.description
   into   l_dr_description
   from   fa_lookups_tl lk_dr
   where  lk_dr.lookup_type = 'JOURNAL ENTRIES'
   and    lk_dr.lookup_code = 'DEPRECIATION RESERVE'
   and    userenv('LANG') = lk_dr.language;

   select lk_be.description
   into   l_be_description
   from   fa_lookups_tl lk_be
   where  lk_be.lookup_type = 'JOURNAL ENTRIES'
   and    lk_be.lookup_code = 'BONUS DEPRECIATION EXPENSE'
   and    userenv('LANG') = lk_be.language;

   select lk_br.description
   into   l_br_description
   from   fa_lookups_tl lk_br
   where  lk_br.lookup_type = 'JOURNAL ENTRIES'
   and    lk_br.lookup_code = 'BONUS DEPRECIATION RESERVE'
   and    userenv('LANG') = lk_br.language;

   select lk_ra.description
   into   l_ra_description
   from   fa_lookups_tl lk_ra
   where  lk_ra.lookup_type = 'JOURNAL ENTRIES'
   and    lk_ra.lookup_code = 'DEPRECIATION REVAL AMORT'
   and    userenv('LANG') = lk_ra.language;

   select lk_rr.description
   into   l_rr_description
   from   fa_lookups_tl lk_rr
   where  lk_rr.lookup_type = 'JOURNAL ENTRIES'
   and    lk_rr.lookup_code = 'DEPRECIATION REVAL RESERVE'
   and    userenv('LANG') = lk_rr.language;

   select count(*)
   into   l_mc_books
   from   fa_mc_book_controls
   where  enabled_flag = 'Y'
   and    rownum = 1;

   if (p_mode = 'downtime') then

      insert all
      when 1 = 1 then
         into fa_xla_upg_events_gt (
               event_id,
               entity_id,
               set_of_books_id,
               period_name,
               calendar_period_close_date,
               je_category_name,
               event_type_code,
               event_class_code,
               ds_asset_id,
               ds_book_type_code,
               ds_period_counter,
               reserve_acct_ccid,
               bonus_reserve_acct_ccid,
               reval_amort_acct_ccid,
               reval_reserve_acct_ccid
         ) values (
               xla_events_s.nextval,
               xla_transaction_entities_s.nextval,
               set_of_books_id,
               period_name,
               calendar_period_close_date,
               je_category_name,
               event_type_code,
               event_class_code,
               asset_id,
               book_type_code,
               period_counter,
               default_rsv_ccid,
               default_bonus_rsv_ccid,
               default_reval_amort_ccid,
               default_reval_rsv_ccid
         )
      when 1 = 1 then
         into fa_deprn_events (
            asset_id,
            book_type_code,
            period_counter,
            deprn_run_date,
            deprn_run_id,
            event_id,
            reversal_event_id,
            reversal_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login
         ) values (
            asset_id,
            book_type_code,
            period_counter,
            transaction_date_entered,
            1,
            xla_events_s.currval,
            null,
            null,
            sysdate,
            c_upgrade_bugno,
            sysdate,
            c_upgrade_bugno,
            c_upgrade_bugno
         )
      when 1 = 1 then
         into xla_transaction_entities_upg (
               upg_batch_id,
               application_id,
               ledger_id,
               legal_entity_id,
               entity_code,
               source_id_int_1,
               source_id_int_2,
               source_id_int_3,
               source_id_int_4,
               source_id_char_1,
               source_id_char_2,
               source_id_char_3,
               source_id_char_4,
               security_id_int_1,
               security_id_int_2,
               security_id_int_3,
               security_id_char_1,
               security_id_char_2,
               security_id_char_3,
               transaction_number,
               valuation_method,
               source_application_id,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by,
               last_update_login,
               entity_id,
               upg_source_application_id
         ) values (
               l_upg_batch_id,        -- upg_batch_id
               c_application_id,      -- application_id
               set_of_books_id,       -- ledger_id
               null,                  -- legal_entity_id
               c_entity_code,         -- entity_code
               asset_id,              -- source_id_int_1
               period_counter,        -- source_id_int_2
               1,                     -- source_id_int_3
               null,                  -- source_id_int_4
               book_type_code,        -- source_id_char_1
               null,                  -- source_id_char_2
               null,                  -- source_id_char_3
               null,                  -- source_id_char_4
               null,                  -- security_id_int_1
               null,                  -- security_id_int_2
               null,                  -- security_id_int_3
               null,                  -- security_id_char_1
               null,                  -- security_id_char_2
               null,                  -- security_id_char_3
               set_of_books_id,       -- transaction_number
               book_type_code,        -- valuation_method
               c_application_id,      -- source_application_id
               sysdate,               -- creation_date
               c_fnd_user,            -- created_by
               sysdate,               -- last_update_date
               c_fnd_user,            -- last_updated_by
               c_upgrade_bugno,       -- last_update_login
               xla_transaction_entities_s.currval,
                                      -- entity_id
               c_application_id       -- upg_source_application_id
         )
      when 1 = 1 then
         into xla_events (
               upg_batch_id,
               application_id,
               event_type_code,
               event_number,
               event_status_code,
               process_status_code,
               on_hold_flag,
               event_date,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by,
               last_update_login,
               program_update_date,
               program_id,
               program_application_id,
               request_id,
               entity_id,
               event_id,
               upg_source_application_id,
               transaction_date
         ) values (
               l_upg_batch_id,        -- upg_batch_id
               c_application_id,      -- application_id
               event_type_code,       -- event_type_code
               1,                     -- event_number
               'P',                   -- event_status_code
               'P',                   -- process_status_code
               'N',                   -- on_hold_flag
               calendar_period_close_date,
--  Bug 7036409             transaction_date_entered,
                                      -- event_date
               sysdate,               -- creation_date
               c_fnd_user,            -- created_by
               sysdate,               -- last_update_date
               c_fnd_user,            -- last_updated_by
               c_upgrade_bugno,       -- last_update_login
               null,                  -- program_update_date
               null,                  -- program_id
               null,                  -- program_application_id
               null,                  -- request_id
               xla_transaction_entities_s.currval,
                                      -- entity_id
               xla_events_s.currval,  -- event_id
               c_application_id,      -- upg_source_application_id
               transaction_date_entered
                                      -- transaction_date
         )
      when 1 = 1 then
         into fa_xla_upg_headers_gt (
            ae_header_id,
            event_id,
            set_of_books_id
         ) values (
            xla_ae_headers_s.nextval,
            xla_events_s.currval,
            set_of_books_id
         )
      when 1 = 1 then
         into xla_ae_headers (
               upg_batch_id,
               application_id,
               amb_context_code,
               entity_id,
               event_id,
               event_type_code,
               ae_header_id,
               ledger_id,
               accounting_date,
               period_name,
               reference_date,
               balance_type_code,
               je_category_name,
               gl_transfer_status_code,
               gl_transfer_date,
               accounting_entry_status_code,
               accounting_entry_type_code,
               description,
               budget_version_id,
               funds_status_code,
               encumbrance_type_id,
               completed_date,
               doc_sequence_id,
               doc_sequence_value,
               doc_category_code,
               packet_id,
               group_id,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by,
               last_update_login,
               program_id,
               program_application_id,
               program_update_date,
               request_id,
               close_acct_seq_assign_id,
               close_acct_seq_version_id,
               close_acct_seq_value,
               completion_acct_seq_assign_id,
               completion_acct_seq_version_id,
               completion_acct_seq_value,
               accounting_batch_id,
               product_rule_type_code,
               product_rule_code,
               product_rule_version,
               upg_source_application_id,
               upg_valid_flag
         ) values (
               l_upg_batch_id,             -- upg_batch_id
               c_application_id,           -- application_id
               c_amb_context_code,         -- amb_context_code
               xla_transaction_entities_s.currval,
                                           -- entity_id
               xla_events_s.currval,       -- event_id
               event_type_code,            -- event_type_code
               xla_ae_headers_s.currval,   -- ae_header_id
               set_of_books_id,            -- ledger_id
               calendar_period_close_date, -- accounting_date
               period_name,                -- period_name
               null,                       -- reference_date
               'A',                        -- balance_type_code
               je_category_name,           -- je_category_name
               'Y',                        -- gl_transfer_status_code
               null,                       -- gl_transfer_date
               'F',                        -- accounting_entry_status_code
               'STANDARD',                 -- accounting_entry_type_code
               'Depreciation - ' ||
                  to_char(calendar_period_close_date, 'DD-MON-RR'),
                                           -- description
               null,                       -- budget_version_id
               null,                       -- funds_status_code
               null,                       -- encumbrance_type_id
               null,                       -- completed_date
               null,                       -- doc_sequence_id
               null,                       -- doc_sequence_value
               null,                       -- doc_category_code
               null,                       -- packet_id
               null,                       -- group_id
               sysdate,                    -- creation_date
               c_fnd_user,                 -- created_by
               sysdate,                    -- last_update_date
               c_fnd_user,                 -- last_updated_by
               c_upgrade_bugno,            -- last_update_login
               null,                       -- program_id
               c_application_id,           -- program_application_id
               sysdate,                    -- program_update_date
               null,                       -- request_id
               null,                       -- close_acct_seq_assign_id
               null,                       -- close_acct_seq_version_id
               null,                       -- close_acct_seq_value
               null,                       -- completion_acct_seq_assign_id
               null,                       -- completion_acct_seq_version_id
               null,                       -- completion_acct_seq_value
               null,                       -- accounting_batch_id
               null,                       -- product_rule_type_code
               null,                       -- product_rule_code
               null,                       -- product_rule_version
               c_application_id,           -- upg_source_application_id
               null                        -- upg_valid_flag
         )
         select /*+ ordered leading(dp) index(dp fa_deprn_periods_u3) rowid(ds) index(ah fa_asset_history_n2) */
                ds.asset_id                asset_id,
                ds.book_type_code          book_type_code,
                bc.set_of_books_id         set_of_books_id,
                ds.deprn_run_date          transaction_date_entered,
                'DEPRECIATION'             event_type_code,
                'DEPRECIATION'             event_class_code,
                dp.period_name             period_name,
                dp.period_counter          period_counter,
                dp.calendar_period_close_date
                                           calendar_period_close_date,
                nvl(cb.reserve_account_ccid, -1)
                                           default_rsv_ccid,
                nvl(cb.bonus_reserve_acct_ccid, -1)
                                           default_bonus_rsv_ccid,
                nvl(cb.reval_amort_account_ccid, -1)
                                           default_reval_amort_ccid,
                nvl(cb.reval_reserve_account_ccid, -1)
                                           default_reval_rsv_ccid,
                nvl(bc.je_depreciation_category, 'OTHER')
                                           je_category_name
         from   fa_deprn_summary ds,
                fa_book_controls bc,
                gl_sets_of_books glsob,
                fa_deprn_periods dp,
                fa_asset_history ah,
                fa_category_books cb
         where  ds.rowid between p_start_rowid and p_end_rowid
         and    ds.book_type_code = bc.book_type_code
         and    bc.set_of_books_id = glsob.set_of_books_id
         and    dp.book_type_code = ds.book_type_code
         and    dp.period_counter = ds.period_counter
         and    dp.period_close_date is null
         and    ds.event_id is null
         and    ds.deprn_source_code <> 'TRACK'
         and    ds.asset_id = ah.asset_id
         and    nvl(dp.period_close_date, sysdate) >= ah.date_effective
         and    nvl(dp.period_close_date, sysdate) <
                nvl(ah.date_ineffective, sysdate+1)
         and    ah.category_id = cb.category_id
         and    bc.book_type_code = cb.book_type_code;

   else

      insert all
      when 1 = 1 then
         into fa_xla_upg_events_gt (
               event_id,
               entity_id,
               set_of_books_id,
               period_name,
               calendar_period_close_date,
               je_category_name,
               event_type_code,
               event_class_code,
               ds_asset_id,
               ds_book_type_code,
               ds_period_counter,
               reserve_acct_ccid,
               bonus_reserve_acct_ccid,
               reval_amort_acct_ccid,
               reval_reserve_acct_ccid
         ) values (
               xla_events_s.nextval,
               xla_transaction_entities_s.nextval,
               set_of_books_id,
               period_name,
               calendar_period_close_date,
               je_category_name,
               event_type_code,
               event_class_code,
               asset_id,
               book_type_code,
               period_counter,
               default_rsv_ccid,
               default_bonus_rsv_ccid,
               default_reval_amort_ccid,
               default_reval_rsv_ccid
         )
      when 1 = 1 then
         into fa_deprn_events (
            asset_id,
            book_type_code,
            period_counter,
            deprn_run_date,
            deprn_run_id,
            event_id,
            reversal_event_id,
            reversal_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login
         ) values (
            asset_id,
            book_type_code,
            period_counter,
            transaction_date_entered,
            1,
            xla_events_s.currval,
            null,
            null,
            sysdate,
            c_upgrade_bugno,
            sysdate,
            c_upgrade_bugno,
            c_upgrade_bugno
         )
      when 1 = 1 then
         into xla_transaction_entities_upg (
               upg_batch_id,
               application_id,
               ledger_id,
               legal_entity_id,
               entity_code,
               source_id_int_1,
               source_id_int_2,
               source_id_int_3,
               source_id_int_4,
               source_id_char_1,
               source_id_char_2,
               source_id_char_3,
               source_id_char_4,
               security_id_int_1,
               security_id_int_2,
               security_id_int_3,
               security_id_char_1,
               security_id_char_2,
               security_id_char_3,
               transaction_number,
               valuation_method,
               source_application_id,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by,
               last_update_login,
               entity_id,
               upg_source_application_id
         ) values (
               l_upg_batch_id,        -- upg_batch_id
               c_application_id,      -- application_id
               set_of_books_id,       -- ledger_id
               null,                  -- legal_entity_id
               c_entity_code,         -- entity_code
               asset_id,              -- source_id_int_1
               period_counter,        -- source_id_int_2
               1,                     -- source_id_int_3
               null,                  -- source_id_int_4
               book_type_code,        -- source_id_char_1
               null,                  -- source_id_char_2
               null,                  -- source_id_char_3
               null,                  -- source_id_char_4
               null,                  -- security_id_int_1
               null,                  -- security_id_int_2
               null,                  -- security_id_int_3
               null,                  -- security_id_char_1
               null,                  -- security_id_char_2
               null,                  -- security_id_char_3
               set_of_books_id,       -- transaction_number
               book_type_code,        -- valuation_method
               c_application_id,      -- source_application_id
               sysdate,               -- creation_date
               c_fnd_user,            -- created_by
               sysdate,               -- last_update_date
               c_fnd_user,            -- last_updated_by
               c_upgrade_bugno,       -- last_update_login
               xla_transaction_entities_s.currval,
                                      -- entity_id
               c_application_id       -- upg_source_application_id
         )
      when 1 = 1 then
         into xla_events (
               upg_batch_id,
               application_id,
               event_type_code,
               event_number,
               event_status_code,
               process_status_code,
               on_hold_flag,
               event_date,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by,
               last_update_login,
               program_update_date,
               program_id,
               program_application_id,
               request_id,
               entity_id,
               event_id,
               upg_source_application_id,
               transaction_date
         ) values (
               l_upg_batch_id,        -- upg_batch_id
               c_application_id,      -- application_id
               event_type_code,       -- event_type_code
               1,                     -- event_number
               'P',                   -- event_status_code
               'P',                   -- process_status_code
               'N',                   -- on_hold_flag
               calendar_period_close_date,
--  Bug 7036409             transaction_date_entered,
                                      -- event_date
               sysdate,               -- creation_date
               c_fnd_user,            -- created_by
               sysdate,               -- last_update_date
               c_fnd_user,            -- last_updated_by
               c_upgrade_bugno,       -- last_update_login
               null,                  -- program_update_date
               null,                  -- program_id
               null,                  -- program_application_id
               null,                  -- request_id
               xla_transaction_entities_s.currval,
                                      -- entity_id
               xla_events_s.currval,  -- event_id
               c_application_id,      -- upg_source_application_id
               transaction_date_entered
                                      -- transaction_date
         )
      when 1 = 1 then
         into fa_xla_upg_headers_gt (
            ae_header_id,
            event_id,
            set_of_books_id
         ) values (
            xla_ae_headers_s.nextval,
            xla_events_s.currval,
            set_of_books_id
         )
      when 1 = 1 then
         into xla_ae_headers (
               upg_batch_id,
               application_id,
               amb_context_code,
               entity_id,
               event_id,
               event_type_code,
               ae_header_id,
               ledger_id,
               accounting_date,
               period_name,
               reference_date,
               balance_type_code,
               je_category_name,
               gl_transfer_status_code,
               gl_transfer_date,
               accounting_entry_status_code,
               accounting_entry_type_code,
               description,
               budget_version_id,
               funds_status_code,
               encumbrance_type_id,
               completed_date,
               doc_sequence_id,
               doc_sequence_value,
               doc_category_code,
               packet_id,
               group_id,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by,
               last_update_login,
               program_id,
               program_application_id,
               program_update_date,
               request_id,
               close_acct_seq_assign_id,
               close_acct_seq_version_id,
               close_acct_seq_value,
               completion_acct_seq_assign_id,
               completion_acct_seq_version_id,
               completion_acct_seq_value,
               accounting_batch_id,
               product_rule_type_code,
               product_rule_code,
               product_rule_version,
               upg_source_application_id,
               upg_valid_flag
         ) values (
               l_upg_batch_id,             -- upg_batch_id
               c_application_id,           -- application_id
               c_amb_context_code,         -- amb_context_code
               xla_transaction_entities_s.currval,
                                           -- entity_id
               xla_events_s.currval,       -- event_id
               event_type_code,            -- event_type_code
               xla_ae_headers_s.currval,   -- ae_header_id
               set_of_books_id,            -- ledger_id
               calendar_period_close_date, -- accounting_date
               period_name,                -- period_name
               null,                       -- reference_date
               'A',                        -- balance_type_code
               je_category_name,           -- je_category_name
               'Y',                        -- gl_transfer_status_code
               null,                       -- gl_transfer_date
               'F',                        -- accounting_entry_status_code
               'STANDARD',                 -- accounting_entry_type_code
               'Depreciation - ' ||
                  to_char(calendar_period_close_date, 'DD-MON-RR'),
                                           -- description
               null,                       -- budget_version_id
               null,                       -- funds_status_code
               null,                       -- encumbrance_type_id
               null,                       -- completed_date
               null,                       -- doc_sequence_id
               null,                       -- doc_sequence_value
               null,                       -- doc_category_code
               null,                       -- packet_id
               null,                       -- group_id
               sysdate,                    -- creation_date
               c_fnd_user,                 -- created_by
               sysdate,                    -- last_update_date
               c_fnd_user,                 -- last_updated_by
               c_upgrade_bugno,            -- last_update_login
               null,                       -- program_id
               c_application_id,           -- program_application_id
               sysdate,                    -- program_update_date
               null,                       -- request_id
               null,                       -- close_acct_seq_assign_id
               null,                       -- close_acct_seq_version_id
               null,                       -- close_acct_seq_value
               null,                       -- completion_acct_seq_assign_id
               null,                       -- completion_acct_seq_version_id
               null,                       -- completion_acct_seq_value
               null,                       -- accounting_batch_id
               null,                       -- product_rule_type_code
               null,                       -- product_rule_code
               null,                       -- product_rule_version
               c_application_id,           -- upg_source_application_id
               null                        -- upg_valid_flag
         )
         select /*+ ordered leading(dp) index(dp fa_deprn_periods_u3) rowid(ds) index(ah fa_asset_history_n2) */
                ds.asset_id                asset_id,
                ds.book_type_code          book_type_code,
                bc.set_of_books_id         set_of_books_id,
                ds.deprn_run_date          transaction_date_entered,
                'DEPRECIATION'             event_type_code,
                'DEPRECIATION'             event_class_code,
                dp.period_name             period_name,
                dp.period_counter          period_counter,
                dp.calendar_period_close_date
                                           calendar_period_close_date,
                nvl(cb.reserve_account_ccid, -1)
                                           default_rsv_ccid,
                nvl(cb.bonus_reserve_acct_ccid, -1)
                                           default_bonus_rsv_ccid,
                nvl(cb.reval_amort_account_ccid, -1)
                                           default_reval_amort_ccid,
                nvl(cb.reval_reserve_account_ccid, -1)
                                           default_reval_rsv_ccid,
                nvl(bc.je_depreciation_category, 'OTHER')
                                           je_category_name
         from   fa_deprn_summary ds,
                fa_book_controls bc,
                gl_sets_of_books glsob,
                fa_deprn_periods dp,
                fa_asset_history ah,
                fa_category_books cb,
                gl_period_statuses ps
         where  ds.rowid between p_start_rowid and p_end_rowid
         and    ds.book_type_code = bc.book_type_code
         and    bc.set_of_books_id = glsob.set_of_books_id
         and    dp.book_type_code = ds.book_type_code
         and    dp.period_counter = ds.period_counter
         and    dp.period_close_date is not null
         and    ds.event_id is null
         and    ds.deprn_source_code <> 'TRACK'
         and    ds.asset_id = ah.asset_id
         and    dp.period_close_date >= ah.date_effective
         and    dp.period_close_date < nvl(ah.date_ineffective, sysdate+1)
         and    ah.category_id = cb.category_id
         and    bc.book_type_code = cb.book_type_code
         and    ps.application_id = 101
         and    ps.migration_status_code in ('P', 'U')
         and    ps.set_of_books_id = bc.set_of_books_id
         and    ps.period_name = dp.period_name
         and    substr(dp.xla_conversion_status, 1, 1) in
                ('H','U','E','0','1','2','3','4','5','6','7','8','9')
         and    dp.xla_conversion_status not in ('UD', 'UA')
         and    dp.xla_conversion_status is not null;

   end if;

   -- Update fa_deprn_summary table with event_id
   update /*+ rowid(ds) */
          fa_deprn_summary ds
   set    ds.event_id =
   ( select ev.event_id
     from   fa_xla_upg_events_gt ev
     where  ev.ds_asset_id = ds.asset_id
     and    ev.ds_book_type_code = ds.book_type_code
     and    ev.ds_period_counter = ds.period_counter
   ),
          ds.deprn_run_id = nvl(ds.deprn_run_id, 1)
   where  ds.rowid between p_start_rowid and p_end_rowid
   and    ds.event_id is null
   and    ds.deprn_source_code <> 'TRACK'
   returning ds.event_id,
             ds.asset_id,
             ds.book_type_code,
             ds.period_counter
   bulk collect
   into      l_event_id_tbl,
             l_asset_id_tbl,
             l_book_type_code_tbl,
             l_period_counter_tbl;

--Bug 6811544
   /* Bug 7498880: Removed the fix made in 6811544
      as it is already handled in faevddpupg.sql through bug 5882218 */
/*   FORALL l_count IN 1..l_event_id_tbl.count
      update fa_deprn_detail
      set    event_id = l_event_id_tbl(l_count),
             deprn_run_id = nvl(deprn_run_id, 1)
      where  asset_id = l_asset_id_tbl(l_count)
      and    book_type_code = l_book_type_code_tbl(l_count)
      and    period_counter = l_period_counter_tbl(l_count)
      and    event_id is null;  */

   if (l_mc_books > 0) then
      FORALL l_count IN 1..l_event_id_tbl.count
         update fa_mc_deprn_summary
         set    event_id = l_event_id_tbl(l_count),
                deprn_run_id = nvl(deprn_run_id, 1)
         where  asset_id = l_asset_id_tbl(l_count)
         and    book_type_code = l_book_type_code_tbl(l_count)
         and    period_counter = l_period_counter_tbl(l_count)
         and    event_id is null;

--Bug 6811544
   /* Bug 7498880: Removed the fix made in 6811544
      as it is already handled in faevddpupg.sql through bug 5882218 */
/*      FORALL l_count IN 1..l_event_id_tbl.count
         update fa_mc_deprn_detail
         set    event_id = l_event_id_tbl(l_count),
                deprn_run_id = nvl(deprn_run_id, 1)
         where  asset_id = l_asset_id_tbl(l_count)
         and    book_type_code = l_book_type_code_tbl(l_count)
         and    period_counter = l_period_counter_tbl(l_count)
         and    event_id is null; */

   end if;

   insert all
   when (1 = 1) then
      into xla_ae_lines (
            upg_batch_id,
            ae_header_id,
            ae_line_num,
            displayed_line_number,
            application_id,
            code_combination_id,
            gl_transfer_mode_code,
            accounted_dr,
            accounted_cr,
            currency_code,
            currency_conversion_date,
            currency_conversion_rate,
            currency_conversion_type,
            entered_dr,
            entered_cr,
            description,
            accounting_class_code,
            gl_sl_link_id,
            gl_sl_link_table,
            party_type_code,
            party_id,
            party_site_id,
            statistical_amount,
            ussgl_transaction_code,
            jgzz_recon_ref,
            control_balance_flag,
            analytical_balance_flag,
            upg_tax_reference_id1,
            upg_tax_reference_id2,
            upg_tax_reference_id3,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_update_date,
            program_id,
            program_application_id,
            request_id,
            gain_or_loss_flag,
            accounting_date,
            ledger_id
      ) values (
            l_upg_batch_id,                       -- upg_batch_id
            ae_header_id,                         -- ae_header_id
            ae_line_num,                          -- ae_line_num
            ae_line_num,                          -- displayed_line_num
            c_application_id,                     -- application_id
            decode(multiplier,                    -- code_combination_id
                   1, nvl(deprn_exp_ccid, default_ccid),
                   2, nvl(deprn_rsv_ccid,default_rsv_ccid),
                   3, nvl(bonus_exp_ccid, default_ccid),
                   4, nvl(bonus_rsv_ccid, default_bonus_rsv_ccid),
                   5, nvl(reval_amort_ccid, default_reval_amort_ccid),
                   6, nvl(reval_rsv_ccid, default_reval_rsv_ccid)),
            'S',                                  -- gl_transfer_mode_code
            decode(multiplier,                    -- accounted_dr
                   1, deprn_amount,
                   2, null,
                   3, bonus_amount,
                   4, null,
                   5, reval_amount,
                   6, null),
            decode(multiplier,                    -- accounted_cr
                   1, null,
                   2, deprn_amount,
                   3, null,
                   4, bonus_amount,
                   5, null,
                   6, reval_amount),
            currency_code,                        -- currency_code
            null,                                 -- currency_conversion_date
            null,                                 -- currency_conversion_rate
            null,                                 -- currency_conversion_type
            decode(multiplier,                    -- entered_dr
                   1, deprn_amount,
                   2, null,
                   3, bonus_amount,
                   4, null,
                   5, reval_amount,
                   6, null),
            decode(multiplier,                    -- entered_cr
                   1, null,
                   2, deprn_amount,
                   3, null,
                   4, bonus_amount,
                   5, null,
                   6, reval_amount),
            decode(multiplier,                    -- description
                   1, l_de_description,
                   2, l_dr_description,
                   3, l_be_description,
                   4, l_br_description,
                   5, l_ra_description,
                   6, l_rr_description) || ' - ' ||
               to_char(cal_period_close_date, 'DD-MON-RR'),
            decode(multiplier,                    -- accounting_class_code
                   1, 'EXPENSE',
                   2, 'ASSET',
                   3, 'EXPENSE',
                   4, 'ASSET',
                   5, 'EXPENSE',
                   6, 'ASSET'),
            xla_gl_sl_link_id_s.nextval,          -- gl_sl_link_id
            'XLAJEL',                             -- gl_sl_link_table
            null,                                 -- party_type_code
            null,                                 -- party_id
            null,                                 -- party_site_id
            null,                                 -- statistical_amount
            null,                                 -- ussgl_transaction_code
            null,                                 -- glzz_recon_ref
            null,                                 -- control_balance_flag
            null,                                 -- analytical_balance_flag
            null,                                 -- upg_tax_reference_id1
            null,                                 -- upg_tax_reference_id2
            null,                                 -- upg_tax_reference_id3
            sysdate,                              -- creation_date
            c_fnd_user,                           -- created_by
            sysdate,                              -- last_update_date
            c_fnd_user,                           -- last_updated_by
            c_upgrade_bugno,                      -- last_update_login
            null,                                 -- program_update_date
            null,                                 -- program_id
            c_application_id,                     -- program_application_id
            null,                                 -- request_id
            'N',                                  -- gain_or_loss_flag
            cal_period_close_date,                -- accounting_date,
            set_of_books_id                       -- ledger_id/sob_id
      )
   when (1 = 1) then
      into xla_distribution_links (
            upg_batch_id,
            application_id,
            event_id,
            ae_header_id,
            ae_line_num,
            accounting_line_code,
            accounting_line_type_code,
            source_distribution_type,
            source_distribution_id_char_1,
            source_distribution_id_char_2,
            source_distribution_id_char_3,
            source_distribution_id_char_4,
            source_distribution_id_char_5,
            source_distribution_id_num_1,
            source_distribution_id_num_2,
            source_distribution_id_num_3,
            source_distribution_id_num_4,
            source_distribution_id_num_5,
            merge_duplicate_code,
            statistical_amount,
            unrounded_entered_dr,
            unrounded_entered_cr,
            unrounded_accounted_dr,
            unrounded_accounted_cr,
            ref_ae_header_id,
            ref_temp_line_num,
            ref_event_id,
            temp_line_num,
            tax_line_ref_id,
            tax_summary_line_ref_id,
            tax_rec_nrec_dist_ref_id,
            line_definition_owner_code,
            line_definition_code,
            event_class_code,
            event_type_code
      ) values (
            l_upg_batch_id,                    -- upg_batch_id
            c_application_id,                  -- application_id
            event_id,                          -- event_id
            ae_header_id,                      -- ae_header_id
            ae_line_num,                       -- ae_line_num
            null,                              -- accounting_line_code
            'S',                               -- accounting_line_type_code
            'DEPRN',                           -- source_distribution_type
            null,                              -- source_distribution_id_char_1
            null,                              -- source_distribution_id_char_2
            null,                              -- source_distribution_id_char_3
            book_type_code,                    -- source_distribution_id_char_4
            null,                              -- source_distribution_id_char_5
            asset_id,                          -- source_distribution_id_num_1
            period_counter,                    -- source_distribution_id_num_2
            1,                                 -- source_distribution_id_num_3
            null,                              -- source_distribution_id_num_4
            distribution_id,                   -- source_distribution_id_num_5
            'N',                               -- merge_duplicate_code
            null,                              -- statistical_amount
            decode(multiplier,                 -- unrounded_entered_dr
                   1, deprn_amount,
                   2, null,
                   3, bonus_amount,
                   4, null,
                   5, reval_amount,
                   6, null),
            decode(multiplier,                -- unrounded_entered_cr
                   1, null,
                   2, deprn_amount,
                   3, null,
                   4, bonus_amount,
                   5, null,
                   6, reval_amount),
            decode(multiplier,                -- unrounded_accounted_dr
                   1, deprn_amount,
                   2, null,
                   3, bonus_amount,
                   4, null,
                   5, reval_amount,
                   6, null),
            decode(multiplier,                -- unrounded_accounted_cr
                   1, null,
                   2, deprn_amount,
                   3, null,
                   4, bonus_amount,
                   5, null,
                   6, reval_amount),
            ae_header_id,                      -- ref_ae_header_id
            null,                              -- ref_temp_line_num
            null,                              -- ref_event_id
            ae_line_num,                       -- temp_line_num
            null,                              -- tax_line_ref_id
            null,                              -- tax_summary_line_ref_id
            null,                              -- tax_rec_nrec_dist_ref_id
            null,                              -- line_definition_owner_code
            null,                              -- line_definition_code
            event_class_code,                  -- event_class_code
            event_type_code                    -- event_type_code
      )
   when (je_batch_id is not null) then
      into gl_import_references (
            je_batch_id,
            je_header_id,
            je_line_num,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            reference_1,
            reference_2,
            reference_3,
            reference_4,
            reference_5,
            reference_6,
            reference_7,
            reference_8,
            reference_9,
            reference_10,
            subledger_doc_sequence_id,
            subledger_doc_sequence_value,
            gl_sl_link_id,
            gl_sl_link_table
      ) values (
            je_batch_id,                       -- je_batch_id
            je_header_id,                      -- je_header_id
            decode(multiplier,                 -- je_line_num
                   1, de_je_line_num,
                   2, dr_je_line_num,
                   3, be_je_line_num,
                   4, br_je_line_num,
                   5, ra_je_line_num,
                   6, rr_je_line_num),
            sysdate,                           -- last_update_date
            c_fnd_user,                        -- last_updated_by
            sysdate,                           -- creation_date
            c_fnd_user,                        -- created_by
            c_upgrade_bugno,                   -- last_update_login
            null,                              -- reference_1
            to_char(asset_id),                 -- reference_2
            to_char(distribution_id),          -- reference_3
            null,                              -- reference_4
            book_type_code,                    -- reference_5
            to_char(period_counter),           -- reference_6
            null,                              -- reference_7
            null,                              -- reference_8
            null,                              -- reference_9
            null,                              -- reference_10
            null,                              -- subledger_doc_seq_id
            null,                              -- subledger_doc_seq_value
            xla_gl_sl_link_id_s.nextval,       -- gl_sl_link_id
            'XLAJEL'                           -- gl_sl_link_table
      )
      select /*+ leading(ev) index(dd, FA_DEPRN_DETAIL_N1) */
             ev.event_id                       event_id,
             he.ae_header_id                   ae_header_id,
             ev.calendar_period_close_date     cal_period_close_date,
             ev.event_type_code                event_type_code,
             ev.event_class_code               event_class_code,
             ev.ds_asset_id                    asset_id,
             ev.ds_book_type_code              book_type_code,
             he.set_of_books_id                set_of_books_id,
             ev.ds_period_counter              period_counter,
             dd.distribution_id                distribution_id,
             glsob.currency_code               currency_code,
             dd.deprn_amount - nvl(dd.deprn_adjustment_amount, 0)
                             - nvl(dd.bonus_deprn_amount, 0)
                                               deprn_amount,
             nvl(dd.bonus_deprn_amount -
                 nvl(dd.bonus_deprn_adjustment_amount, 0), 0)
                                               bonus_amount,
             nvl(dd.reval_amortization, 0)     reval_amount,
             ev.reserve_acct_ccid              default_rsv_ccid,
             ev.bonus_reserve_acct_ccid        default_bonus_rsv_ccid,
             ev.reval_amort_acct_ccid          default_reval_amort_ccid,
             ev.reval_reserve_acct_ccid        default_reval_rsv_ccid,
             nvl(jl_de.code_combination_id, da.deprn_expense_account_ccid)
                                               deprn_exp_ccid,
             nvl(jl_dr.code_combination_id, da.deprn_reserve_account_ccid)
                                               deprn_rsv_ccid,
             nvl(jl_be.code_combination_id, da.bonus_exp_account_ccid)
                                               bonus_exp_ccid,
             nvl(jl_br.code_combination_id, da.bonus_rsv_account_ccid)
                                               bonus_rsv_ccid,
             nvl(jl_ra.code_combination_id, da.reval_amort_account_ccid)
                                               reval_amort_ccid,
             nvl(jl_rr.code_combination_id, da.reval_rsv_account_ccid)
                                               reval_rsv_ccid,
             nvl(dh.code_combination_id, -1)   default_ccid,
             decode (dd.je_header_id, null, 'N', 'Y')
                                               gl_transfer_status_code,
             gljh.je_batch_id                  je_batch_id,
             dd.je_header_id                   je_header_id,
             nvl(dd.deprn_expense_je_line_num, 0)
                                               de_je_line_num,
             nvl(dd.deprn_reserve_je_line_num, 0)
                                               dr_je_line_num,
             nvl(dd.bonus_deprn_exp_je_line_num, 0)
                                               be_je_line_num,
             nvl(dd.bonus_deprn_rsv_je_line_num, 0)
                                               br_je_line_num,
             nvl(dd.reval_amort_je_line_num, 0)
                                               ra_je_line_num,
             nvl(dd.reval_reserve_je_line_num, 0)
                                               rr_je_line_num,
             row_number() over
                (partition by ev.event_id
                 order by dd.distribution_id, mult.multiplier)
                                               ae_line_num,
             mult.multiplier                   multiplier
      from   fa_xla_upg_events_gt ev,
             fa_xla_upg_headers_gt he,
             fa_deprn_detail dd,
             fa_distribution_history dh,
             fa_distribution_accounts da,
             gl_je_lines jl_de,
             gl_je_lines jl_dr,
             gl_je_lines jl_be,
             gl_je_lines jl_br,
             gl_je_lines jl_ra,
             gl_je_lines jl_rr,
             gl_je_headers gljh,
             fa_book_controls bc,
             gl_sets_of_books glsob,
             gl_row_multipliers mult
      where  ev.event_id = he.event_id
      and    bc.book_type_code = ev.ds_book_type_code
      and    bc.set_of_books_id = glsob.set_of_books_id
      and    bc.book_type_code = dd.book_type_code
      and    he.set_of_books_id = bc.set_of_books_id
      and    dd.book_type_code = ev.ds_book_type_code
      and    dd.asset_id = ev.ds_asset_id
      and    dd.period_counter = ev.ds_period_counter
      and    dd.deprn_source_code <> 'T'
      and    dd.je_header_id = jl_de.je_header_id (+)
      and    dd.je_header_id = jl_dr.je_header_id (+)
      and    dd.je_header_id = jl_be.je_header_id (+)
      and    dd.je_header_id = jl_br.je_header_id (+)
      and    dd.je_header_id = jl_ra.je_header_id (+)
      and    dd.je_header_id = jl_rr.je_header_id (+)
      and    dd.deprn_expense_je_line_num = jl_de.je_line_num (+)
      and    dd.deprn_reserve_je_line_num = jl_dr.je_line_num (+)
      and    dd.bonus_deprn_exp_je_line_num = jl_be.je_line_num (+)
      and    dd.bonus_deprn_rsv_je_line_num = jl_br.je_line_num (+)
      and    dd.reval_amort_je_line_num = jl_ra.je_line_num (+)
      and    dd.reval_reserve_je_line_num = jl_rr.je_line_num (+)
      and    dd.distribution_id = dh.distribution_id
      and    da.book_type_code (+) = dd.book_type_code
      and    da.distribution_id (+) = dd.distribution_id
      and    dd.je_header_id = gljh.je_header_id (+)
      and    mult.multiplier < 7
      and    ((mult.multiplier in (1, 2))
           or ((mult.multiplier in (3, 4)) and
               (nvl(dd.bonus_deprn_amount -
                    nvl(dd.bonus_deprn_adjustment_amount, 0), 0) <> 0))
           or ((mult.multiplier in (5, 6)) and
               (dd.reval_amortization <> 0)));

   if (l_mc_books > 0) then

   insert all
   when 1 = 1 then
      into fa_xla_upg_headers_gt (
         ae_header_id,
         event_id,
         set_of_books_id
      ) values (
         xla_ae_headers_s.nextval,
         event_id,
         set_of_books_id
      )
   when 1 = 1 then
      into xla_ae_headers (
            upg_batch_id,
            application_id,
            amb_context_code,
            entity_id,
            event_id,
            event_type_code,
            ae_header_id,
            ledger_id,
            accounting_date,
            period_name,
            reference_date,
            balance_type_code,
            je_category_name,
            gl_transfer_status_code,
            gl_transfer_date,
            accounting_entry_status_code,
            accounting_entry_type_code,
            description,
            budget_version_id,
            funds_status_code,
            encumbrance_type_id,
            completed_date,
            doc_sequence_id,
            doc_sequence_value,
            doc_category_code,
            packet_id,
            group_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_id,
            program_application_id,
            program_update_date,
            request_id,
            close_acct_seq_assign_id,
            close_acct_seq_version_id,
            close_acct_seq_value,
            completion_acct_seq_assign_id,
            completion_acct_seq_version_id,
            completion_acct_seq_value,
            accounting_batch_id,
            product_rule_type_code,
            product_rule_code,
            product_rule_version,
            upg_source_application_id,
            upg_valid_flag
      ) values (
            l_upg_batch_id,             -- upg_batch_id
            c_application_id,           -- application_id
            c_amb_context_code,         -- amb_context_code
            entity_id,                  -- entity_id
            event_id,                   -- event_id
            event_type_code,            -- event_type_code
            xla_ae_headers_s.currval,   -- ae_header_id
            set_of_books_id,            -- ledger_id
            calendar_period_close_date, -- accounting_date
            period_name,                -- period_name
            null,                       -- reference_date
            'A',                        -- balance_type_code
            je_category_name,           -- je_category_name
            'Y',                        -- gl_transfer_status_code
            null,                       -- gl_transfer_date
            'F',                        -- accounting_entry_status_code
            'STANDARD',                 -- accounting_entry_type_code
            description,                -- description
            null,                       -- budget_version_id
            null,                       -- funds_status_code
            null,                       -- encumbrance_type_id
            null,                       -- completed_date
            null,                       -- doc_sequence_id
            null,                       -- doc_sequence_value
            null,                       -- doc_category_code
            null,                       -- packet_id
            null,                       -- group_id
            sysdate,                    -- creation_date
            c_fnd_user,                 -- created_by
            sysdate,                    -- last_update_date
            c_fnd_user,                 -- last_updated_by
            c_upgrade_bugno,            -- last_update_login
            null,                       -- program_id
            c_application_id,           -- program_application_id
            sysdate,                    -- program_update_date
            null,                       -- request_id
            null,                       -- close_acct_seq_assign_id
            null,                       -- close_acct_seq_version_id
            null,                       -- close_acct_seq_value
            null,                       -- completion_acct_seq_assign_id
            null,                       -- completion_acct_seq_version_id
            null,                       -- completion_acct_seq_value
            null,                       -- accounting_batch_id
            null,                       -- product_rule_type_code
            null,                       -- product_rule_code
            null,                       -- product_rule_version
            c_application_id,           -- upg_source_application_id
            null                        -- upg_valid_flag
      )
      select faev.entity_id         entity_id,
             faev.event_id          event_id,
             faev.event_type_code   event_type_code,
             mc.set_of_books_id     set_of_books_id,
             faev.calendar_period_close_date
                                    calendar_period_close_date,
             faev.period_name       period_name,
             faev.je_category_name  je_category_name,
             faev.description       description
      from   fa_xla_upg_events_gt faev,
             fa_mc_book_controls mc
      where  mc.book_type_code = faev.ds_book_type_code
      and    mc.enabled_flag = 'Y';

   insert all
   when (1 = 1) then
      into xla_ae_lines (
            upg_batch_id,
            ae_header_id,
            ae_line_num,
            displayed_line_number,
            application_id,
            code_combination_id,
            gl_transfer_mode_code,
            accounted_dr,
            accounted_cr,
            currency_code,
            currency_conversion_date,
            currency_conversion_rate,
            currency_conversion_type,
            entered_dr,
            entered_cr,
            description,
            accounting_class_code,
            gl_sl_link_id,
            gl_sl_link_table,
            party_type_code,
            party_id,
            party_site_id,
            statistical_amount,
            ussgl_transaction_code,
            jgzz_recon_ref,
            control_balance_flag,
            analytical_balance_flag,
            upg_tax_reference_id1,
            upg_tax_reference_id2,
            upg_tax_reference_id3,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_update_date,
            program_id,
            program_application_id,
            request_id,
            gain_or_loss_flag,
            accounting_date,
            ledger_id
      ) values (
            l_upg_batch_id,                       -- upg_batch_id
            ae_header_id,                         -- ae_header_id
            ae_line_num,                          -- ae_line_num
            ae_line_num,                          -- displayed_line_num
            c_application_id,                     -- application_id
            decode(multiplier,                    -- code_combination_id
                   1, nvl(deprn_exp_ccid, default_ccid),
                   2, nvl(deprn_rsv_ccid,default_rsv_ccid),
                   3, nvl(bonus_exp_ccid, default_ccid),
                   4, nvl(bonus_rsv_ccid, default_bonus_rsv_ccid),
                   5, nvl(reval_amort_ccid, default_reval_amort_ccid),
                   6, nvl(reval_rsv_ccid, default_reval_rsv_ccid)),
            'S',                                  -- gl_transfer_mode_code
            decode(multiplier,                    -- accounted_dr
                   1, deprn_amount,
                   2, null,
                   3, bonus_amount,
                   4, null,
                   5, reval_amount,
                   6, null),
            decode(multiplier,                    -- accounted_cr
                   1, null,
                   2, deprn_amount,
                   3, null,
                   4, bonus_amount,
                   5, null,
                   6, reval_amount),
            currency_code,                        -- currency_code
            null,                                 -- currency_conversion_date
            null,                                 -- currency_conversion_rate
            null,                                 -- currency_conversion_type
            decode(multiplier,                    -- entered_dr
                   1, deprn_amount,
                   2, null,
                   3, bonus_amount,
                   4, null,
                   5, reval_amount,
                   6, null),
            decode(multiplier,                    -- entered_cr
                   1, null,
                   2, deprn_amount,
                   3, null,
                   4, bonus_amount,
                   5, null,
                   6, reval_amount),
            decode(multiplier,                    -- description
                   1, l_de_description,
                   2, l_dr_description,
                   3, l_be_description,
                   4, l_br_description,
                   5, l_ra_description,
                   6, l_rr_description) || ' - ' ||
               to_char(cal_period_close_date, 'DD-MON-RR'),
            decode(multiplier,                    -- accounting_class_code
                   1, 'EXPENSE',
                   2, 'ASSET',
                   3, 'EXPENSE',
                   4, 'ASSET',
                   5, 'EXPENSE',
                   6, 'ASSET'),
            xla_gl_sl_link_id_s.nextval,          -- gl_sl_link_id
            'XLAJEL',                             -- gl_sl_link_table
            null,                                 -- party_type_code
            null,                                 -- party_id
            null,                                 -- party_site_id
            null,                                 -- statistical_amount
            null,                                 -- ussgl_transaction_code
            null,                                 -- glzz_recon_ref
            null,                                 -- control_balance_flag
            null,                                 -- analytical_balance_flag
            null,                                 -- upg_tax_reference_id1
            null,                                 -- upg_tax_reference_id2
            null,                                 -- upg_tax_reference_id3
            sysdate,                              -- creation_date
            c_fnd_user,                           -- created_by
            sysdate,                              -- last_update_date
            c_fnd_user,                           -- last_updated_by
            c_upgrade_bugno,                      -- last_update_login
            null,                                 -- program_update_date
            null,                                 -- program_id
            c_application_id,                     -- program_application_id
            null,                                 -- request_id
            'N',                                  -- gain_or_loss_flag
            cal_period_close_date,                -- accounting_date,
            set_of_books_id                       -- ledger_id/sob_id
      )
   when (1 = 1) then
      into xla_distribution_links (
            upg_batch_id,
            application_id,
            event_id,
            ae_header_id,
            ae_line_num,
            accounting_line_code,
            accounting_line_type_code,
            source_distribution_type,
            source_distribution_id_char_1,
            source_distribution_id_char_2,
            source_distribution_id_char_3,
            source_distribution_id_char_4,
            source_distribution_id_char_5,
            source_distribution_id_num_1,
            source_distribution_id_num_2,
            source_distribution_id_num_3,
            source_distribution_id_num_4,
            source_distribution_id_num_5,
            merge_duplicate_code,
            statistical_amount,
            unrounded_entered_dr,
            unrounded_entered_cr,
            unrounded_accounted_dr,
            unrounded_accounted_cr,
            ref_ae_header_id,
            ref_temp_line_num,
            ref_event_id,
            temp_line_num,
            tax_line_ref_id,
            tax_summary_line_ref_id,
            tax_rec_nrec_dist_ref_id,
            line_definition_owner_code,
            line_definition_code,
            event_class_code,
            event_type_code
      ) values (
            l_upg_batch_id,                    -- upg_batch_id
            c_application_id,                  -- application_id
            event_id,                          -- event_id
            ae_header_id,                      -- ae_header_id
            ae_line_num,                       -- ae_line_num
            null,                              -- accounting_line_code
            'S',                               -- accounting_line_type_code
            'DEPRN',                           -- source_distribution_type
            null,                              -- source_distribution_id_char_1
            null,                              -- source_distribution_id_char_2
            null,                              -- source_distribution_id_char_3
            book_type_code,                    -- source_distribution_id_char_4
            null,                              -- source_distribution_id_char_5
            asset_id,                          -- source_distribution_id_num_1
            period_counter,                    -- source_distribution_id_num_2
            1,                                 -- source_distribution_id_num_3
            null,                              -- source_distribution_id_num_4
            distribution_id,                   -- source_distribution_id_num_5
            'N',                               -- merge_duplicate_code
            null,                              -- statistical_amount
            decode(multiplier,                 -- unrounded_entered_dr
                   1, deprn_amount,
                   2, null,
                   3, bonus_amount,
                   4, null,
                   5, reval_amount,
                   6, null),
            decode(multiplier,                -- unrounded_entered_cr
                   1, null,
                   2, deprn_amount,
                   3, null,
                   4, bonus_amount,
                   5, null,
                   6, reval_amount),
            decode(multiplier,                -- unrounded_accounted_dr
                   1, deprn_amount,
                   2, null,
                   3, bonus_amount,
                   4, null,
                   5, reval_amount,
                   6, null),
            decode(multiplier,                -- unrounded_accounted_cr
                   1, null,
                   2, deprn_amount,
                   3, null,
                   4, bonus_amount,
                   5, null,
                   6, reval_amount),
            ae_header_id,                      -- ref_ae_header_id
            null,                              -- ref_temp_line_num
            null,                              -- ref_event_id
            ae_line_num,                       -- temp_line_num
            null,                              -- tax_line_ref_id
            null,                              -- tax_summary_line_ref_id
            null,                              -- tax_rec_nrec_dist_ref_id
            null,                              -- line_definition_owner_code
            null,                              -- line_definition_code
            event_class_code,                  -- event_class_code
            event_type_code                    -- event_type_code
      )
   when (je_batch_id is not null) then
      into gl_import_references (
            je_batch_id,
            je_header_id,
            je_line_num,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            reference_1,
            reference_2,
            reference_3,
            reference_4,
            reference_5,
            reference_6,
            reference_7,
            reference_8,
            reference_9,
            reference_10,
            subledger_doc_sequence_id,
            subledger_doc_sequence_value,
            gl_sl_link_id,
            gl_sl_link_table
      ) values (
            je_batch_id,                       -- je_batch_id
            je_header_id,                      -- je_header_id
            decode(multiplier,                 -- je_line_num
                   1, de_je_line_num,
                   2, dr_je_line_num,
                   3, be_je_line_num,
                   4, br_je_line_num,
                   5, ra_je_line_num,
                   6, rr_je_line_num),
            sysdate,                           -- last_update_date
            c_fnd_user,                        -- last_updated_by
            sysdate,                           -- creation_date
            c_fnd_user,                        -- created_by
            c_upgrade_bugno,                   -- last_update_login
            null,                              -- reference_1
            to_char(asset_id),                 -- reference_2
            to_char(distribution_id),          -- reference_3
            null,                              -- reference_4
            book_type_code,                    -- reference_5
            to_char(period_counter),           -- reference_6
            null,                              -- reference_7
            null,                              -- reference_8
            null,                              -- reference_9
            null,                              -- reference_10
            null,                              -- subledger_doc_seq_id
            null,                              -- subledger_doc_seq_value
            xla_gl_sl_link_id_s.nextval,       -- gl_sl_link_id
            'XLAJEL'                           -- gl_sl_link_table
      )
      select /*+ leading(ev) index(dd, FA_MC_DEPRN_DETAIL_N1) */
             ev.event_id                       event_id,
             he.ae_header_id                   ae_header_id,
             ev.calendar_period_close_date     cal_period_close_date,
             ev.event_type_code                event_type_code,
             ev.event_class_code               event_class_code,
             ev.ds_asset_id                    asset_id,
             ev.ds_book_type_code              book_type_code,
             he.set_of_books_id                set_of_books_id,
             ev.ds_period_counter              period_counter,
             dd.distribution_id                distribution_id,
             glsob.currency_code               currency_code,
             dd.deprn_amount - nvl(dd.deprn_adjustment_amount, 0)
                             - nvl(dd.bonus_deprn_amount, 0)
                                               deprn_amount,
             nvl(dd.bonus_deprn_amount -
                 nvl(dd.bonus_deprn_adjustment_amount, 0), 0)
                                               bonus_amount,
             nvl(dd.reval_amortization, 0)     reval_amount,
             ev.reserve_acct_ccid              default_rsv_ccid,
             ev.bonus_reserve_acct_ccid        default_bonus_rsv_ccid,
             ev.reval_amort_acct_ccid          default_reval_amort_ccid,
             ev.reval_reserve_acct_ccid        default_reval_rsv_ccid,
             nvl(jl_de.code_combination_id, da.deprn_expense_account_ccid)
                                               deprn_exp_ccid,
             nvl(jl_dr.code_combination_id, da.deprn_reserve_account_ccid)
                                               deprn_rsv_ccid,
             nvl(jl_be.code_combination_id, da.bonus_exp_account_ccid)
                                               bonus_exp_ccid,
             nvl(jl_br.code_combination_id, da.bonus_rsv_account_ccid)
                                               bonus_rsv_ccid,
             nvl(jl_ra.code_combination_id, da.reval_amort_account_ccid)
                                               reval_amort_ccid,
             nvl(jl_rr.code_combination_id, da.reval_rsv_account_ccid)
                                               reval_rsv_ccid,
             nvl(dh.code_combination_id, -1)   default_ccid,
             decode (dd.je_header_id, null, 'N', 'Y')
                                               gl_transfer_status_code,
             gljh.je_batch_id                  je_batch_id,
             dd.je_header_id                   je_header_id,
             nvl(dd.deprn_expense_je_line_num, 0)
                                               de_je_line_num,
             nvl(dd.deprn_reserve_je_line_num, 0)
                                               dr_je_line_num,
             nvl(dd.bonus_deprn_exp_je_line_num, 0)
                                               be_je_line_num,
             nvl(dd.bonus_deprn_rsv_je_line_num, 0)
                                               br_je_line_num,
             nvl(dd.reval_amort_je_line_num, 0)
                                               ra_je_line_num,
             nvl(dd.reval_reserve_je_line_num, 0)
                                               rr_je_line_num,
             row_number() over
                (partition by ev.event_id
                 order by dd.distribution_id, mult.multiplier)
                                               ae_line_num,
             mult.multiplier                   multiplier
      from   fa_xla_upg_events_gt ev,
             fa_xla_upg_headers_gt he,
             fa_mc_deprn_detail dd,
             fa_distribution_history dh,
             fa_distribution_accounts da,
             gl_je_lines jl_de,
             gl_je_lines jl_dr,
             gl_je_lines jl_be,
             gl_je_lines jl_br,
             gl_je_lines jl_ra,
             gl_je_lines jl_rr,
             gl_je_headers gljh,
             fa_mc_book_controls bc,
             gl_sets_of_books glsob,
             gl_row_multipliers mult
      where  ev.event_id = he.event_id
      and    bc.book_type_code = ev.ds_book_type_code
      and    bc.set_of_books_id = glsob.set_of_books_id
      and    bc.enabled_flag = 'Y'
      and    he.set_of_books_id = bc.set_of_books_id
      and    dd.set_of_books_id = bc.set_of_books_id
      and    bc.book_type_code = dd.book_type_code
      and    dd.book_type_code = ev.ds_book_type_code
      and    dd.asset_id = ev.ds_asset_id
      and    dd.period_counter = ev.ds_period_counter
      and    dd.deprn_source_code <> 'T'
      and    dd.je_header_id = jl_de.je_header_id (+)
      and    dd.je_header_id = jl_dr.je_header_id (+)
      and    dd.je_header_id = jl_be.je_header_id (+)
      and    dd.je_header_id = jl_br.je_header_id (+)
      and    dd.je_header_id = jl_ra.je_header_id (+)
      and    dd.je_header_id = jl_rr.je_header_id (+)
      and    dd.deprn_expense_je_line_num = jl_de.je_line_num (+)
      and    dd.deprn_reserve_je_line_num = jl_dr.je_line_num (+)
      and    dd.bonus_deprn_exp_je_line_num = jl_be.je_line_num (+)
      and    dd.bonus_deprn_rsv_je_line_num = jl_br.je_line_num (+)
      and    dd.reval_amort_je_line_num = jl_ra.je_line_num (+)
      and    dd.reval_reserve_je_line_num = jl_rr.je_line_num (+)
      and    dd.distribution_id = dh.distribution_id
      and    da.book_type_code (+) = dd.book_type_code
      and    da.distribution_id (+) = dd.distribution_id
      and    dd.je_header_id = gljh.je_header_id (+)
      and    mult.multiplier < 7
      and    ((mult.multiplier in (1, 2))
           or ((mult.multiplier in (3, 4)) and
               (nvl(dd.bonus_deprn_amount -
                    nvl(dd.bonus_deprn_adjustment_amount, 0), 0) <> 0))
           or ((mult.multiplier in (5, 6)) and
               (dd.reval_amortization <> 0)));

   end if;

   l_event_id_tbl.delete;
   l_asset_id_tbl.delete;
   l_book_type_code_tbl.delete;
   l_period_counter_tbl.delete;

   commit;

EXCEPTION
   WHEN OTHERS THEN
      rollback;
      raise;

END Upgrade_Deprn_Events;

Procedure Upgrade_Deferred_Events (
             p_start_rowid             IN            rowid,
             p_end_rowid               IN            rowid,
             p_batch_size              IN            number,
             x_success_count              OUT NOCOPY number,
             x_failure_count              OUT NOCOPY number,
             x_return_status              OUT NOCOPY number
            ) IS

   c_application_id           constant number(15) := 140;
   c_upgrade_bugno            constant number(15) := -4107161;
   c_fnd_user                 constant number(15) := 2;


   c_entity_code              constant varchar2(30) := 'DEFERRED_DEPRECIATION';
   c_amb_context_code         constant varchar2(30) := 'DEFAULT';

   -- this value can be altered in order to process more of less per batch
   l_batch_size                NUMBER;

   l_rows_processed            NUMBER;

   -- type for table variable
   type num_tbl_type  is table of number        index by binary_integer;
   type char_tbl_type is table of varchar2(150) index by binary_integer;
   type date_tbl_type is table of date          index by binary_integer;
   type rowid_tbl_type is table of rowid        index by binary_integer;

   -- used for bulk fetching
   -- main cursor
   l_event_id_tbl                               num_tbl_type;
   l_asset_id_tbl                               num_tbl_type;
   l_corp_book_type_code_tbl                    char_tbl_type;
   l_tax_book_type_code_tbl                     char_tbl_type;
   l_corp_period_counter_tbl                    num_tbl_type;
   l_tax_period_counter_tbl                     num_tbl_type;
   l_set_of_books_id_tbl                        num_tbl_type;
   l_org_id_tbl                                 num_tbl_type;
   l_transaction_type_code_tbl                  char_tbl_type;
   l_transaction_date_entered_tbl               date_tbl_type;
   l_period_name_tbl                            char_tbl_type;
   l_cal_period_close_date_tbl                  date_tbl_type;
   l_rowid_tbl                                  rowid_tbl_type;

   l_upg_batch_id                               number;
   l_ae_header_id                               number;

   l_entity_id_tbl                              num_tbl_type;
   l_event_class_code_tbl                       char_tbl_type;
   l_currency_code_tbl                          char_tbl_type;
   l_je_category_name_tbl                       char_tbl_type;
   l_ae_header_id_tbl                           num_tbl_type;

   l_cr_ccid_tbl                                num_tbl_type;
   l_dr_ccid_tbl                                num_tbl_type;
   l_credit_amount_tbl                          num_tbl_type;
   l_debit_amount_tbl                           num_tbl_type;
   l_exp_xla_gl_sl_link_id_tbl                  num_tbl_type;
   l_rsv_xla_gl_sl_link_id_tbl                  num_tbl_type;
   l_line_def_owner_code_tbl                    char_tbl_type;
   l_line_def_code_tbl                          char_tbl_type;
   l_dfr_exp_desc_tbl                           char_tbl_type;
   l_dfr_rsv_desc_tbl                           char_tbl_type;
   l_gl_transfer_status_code_tbl                char_tbl_type;
   l_je_batch_id_tbl                            num_tbl_type;
   l_je_header_id_tbl                           num_tbl_type;
   l_exp_je_line_num_tbl                        num_tbl_type;
   l_rsv_je_line_num_tbl                        num_tbl_type;
   l_distribution_id_tbl                        num_tbl_type;
   l_line_num_tbl                               num_tbl_type;

   l_rep_set_of_books_id_tbl                    num_tbl_type;

   l_error_level_tbl                            char_tbl_type;
   l_err_entity_id_tbl                          num_tbl_type;
   l_err_event_id_tbl                           num_tbl_type;
   l_err_ae_header_id_tbl                       num_tbl_type;
   l_err_ae_line_num_tbl                        num_tbl_type;
   l_err_temp_line_num_tbl                      num_tbl_type;
   l_error_message_name_tbl                     char_tbl_type;

   CURSOR c_deferred_deprn IS
      select /*+ leading(df) rowid(df) */ distinct
             df.asset_id,
             df.corp_book_type_code,
             df.tax_book_type_code,
             bc.set_of_books_id,
             bc.org_id,
             'DEFERRED DEPRN',
             dp.calendar_period_close_date,
             'DEFERRED_DEPRECIATION' event_class_code,
             dp.period_name,
             dp.calendar_period_close_date,
             df.corp_period_counter,
             df.tax_period_counter,
             glsob.currency_code,
             nvl (bc.je_deferred_deprn_category, 'OTHER') je_category_name
      from   fa_deferred_deprn df,
             fa_deprn_periods dp,
             gl_sets_of_books glsob,
             fa_book_controls bc,
             fa_lookups_tl lk_de,
             fa_lookups_tl lk_dr,
             gl_je_headers gljh,
             gl_period_statuses ps
      where  df.rowid between p_start_rowid and p_end_rowid
      and    df.corp_book_type_code = bc.book_type_code
      and    bc.set_of_books_id = glsob.set_of_books_id
      and    dp.book_type_code = df.corp_book_type_code
      and    dp.period_counter = df.corp_period_counter
      and    df.event_id is null
      and    ps.application_id = 101
      and    ((ps.migration_status_code in ('P', 'U')) or
              (dp.period_close_date is null))
      and    substr(dp.xla_conversion_status, 1, 1) in
             ('H', 'U', 'E', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
      and    ps.set_of_books_id = bc.set_of_books_id
      and    ps.period_name = dp.period_name
      and    lk_de.lookup_type = 'JOURNAL ENTRIES'
      and    lk_dr.lookup_type = 'JOURNAL ENTRIES'
      and    lk_de.lookup_code = 'DEFERRED DEPRN EXPENSE'
      and    lk_dr.lookup_code = 'DEFERRED DEPRN RESERVE'
      and    userenv('LANG') = lk_de.language
      and    userenv('LANG') = lk_dr.language
      and    df.je_header_id = gljh.je_header_id (+);

   CURSOR c_detail (l_corp_book_type_code varchar2,
                    l_tax_book_type_code  varchar2,
                    l_asset_id            number,
                    l_corp_period_counter number,
                    l_tax_period_counter  number) IS
   select df.distribution_id,
          df.deferred_deprn_expense_amount,
          df.deferred_deprn_reserve_amount,
          df.deferred_deprn_expense_ccid,
          df.deferred_deprn_reserve_ccid,
          nvl(df.expense_je_line_num, 0),
          nvl(df.reserve_je_line_num, 0),
          lk_de.description,
          lk_dr.description,
          gljh.je_batch_id,
          df.je_header_id,
          decode (df.je_header_id, null, 'N', 'Y')
    from  fa_deferred_deprn df,
          fa_lookups_tl lk_de,
          fa_lookups_tl lk_dr,
          gl_je_headers gljh
    where df.corp_book_type_code = l_corp_book_type_code
    and   df.tax_book_type_code = l_tax_book_type_code
    and   df.asset_id = l_asset_id
    and   df.corp_period_counter = l_corp_period_counter
    and   df.tax_period_counter = l_tax_period_counter
    and   lk_de.lookup_type = 'JOURNAL ENTRIES'
    and   lk_dr.lookup_type = 'JOURNAL ENTRIES'
    and   lk_de.lookup_code = 'DEFERRED DEPRN EXPENSE'
    and   lk_dr.lookup_code = 'DEFERRED DEPRN RESERVE'
    and   userenv('LANG') = lk_de.language
    and   userenv('LANG') = lk_dr.language
    and   df.je_header_id = gljh.je_header_id (+);

   CURSOR c_mc_books (l_book_type_code      varchar2) IS
   select set_of_books_id
     from fa_mc_book_controls
    where book_type_code = l_book_type_code
      and enabled_flag = 'Y';

   CURSOR c_mc_detail (l_corp_book_type_code varchar2,
                    l_tax_book_type_code  varchar2,
                    l_asset_id            number,
                    l_set_of_books_id     number,
                    l_corp_period_counter number,
                    l_tax_period_counter  number) IS
   select df.distribution_id,
          df.deferred_deprn_expense_amount,
          df.deferred_deprn_reserve_amount,
          df.deferred_deprn_expense_ccid,
          df.deferred_deprn_reserve_ccid,
          nvl(df.expense_je_line_num, 0),
          nvl(df.reserve_je_line_num, 0),
          lk_de.description,
          lk_dr.description,
          gljh.je_batch_id,
          df.je_header_id,
          decode (df.je_header_id, null, 'N', 'Y'),
          glsob.currency_code
    from  fa_mc_deferred_deprn df,
          fa_lookups_tl lk_de,
          fa_lookups_tl lk_dr,
          gl_je_headers gljh,
          gl_sets_of_books glsob
    where df.corp_book_type_code = l_corp_book_type_code
    and   df.tax_book_type_code = l_tax_book_type_code
    and   df.asset_id = l_asset_id
    and   df.set_of_books_id = l_set_of_books_id
    and   df.corp_period_counter = l_corp_period_counter
    and   df.tax_period_counter = l_tax_period_counter
    and   lk_de.lookup_type = 'JOURNAL ENTRIES'
    and   lk_dr.lookup_type = 'JOURNAL ENTRIES'
    and   lk_de.lookup_code = 'DEFERRED DEPRN EXPENSE'
    and   lk_dr.lookup_code = 'DEFERRED DEPRN RESERVE'
    and   userenv('LANG') = lk_de.language
    and   userenv('LANG') = lk_dr.language
    and   df.je_header_id = gljh.je_header_id (+)
    and   df.set_of_books_id = glsob.set_of_books_id;

BEGIN

   x_success_count := 0;
   x_failure_count := 0;

   l_batch_size := nvl(nvl(p_batch_size, fa_cache_pkg.fa_batch_size), 1000);

   open c_deferred_deprn;

   loop

         fetch c_deferred_deprn bulk collect
          into
               l_asset_id_tbl,
               l_corp_book_type_code_tbl,
               l_tax_book_type_code_tbl,
               l_set_of_books_id_tbl,
               l_org_id_tbl,
               l_transaction_type_code_tbl,
               l_transaction_date_entered_tbl,
               l_event_class_code_tbl,
               l_period_name_tbl,
               l_cal_period_close_date_tbl,
               l_corp_period_counter_tbl,
               l_tax_period_counter_tbl,
               l_currency_code_tbl,
               l_je_category_name_tbl
               limit l_batch_size;

      FOR i IN 1..l_asset_id_tbl.count LOOP
         select xla_transaction_entities_s.nextval,
                xla_events_s.nextval
          into  l_entity_id_tbl(i),
                l_event_id_tbl(i)
          from  dual;

      END LOOP;

      -- Update fa_deferred_deprn table with event_id
      FORALL l_count IN 1..l_event_id_tbl.count
         update fa_deferred_deprn
         set    event_id = l_event_id_tbl(l_count)
         where  rowid between p_start_rowid and p_end_rowid
         and    asset_id = l_asset_id_tbl(l_count)
         and    corp_book_type_code = l_corp_book_type_code_tbl(l_count)
         and    tax_book_type_code = l_tax_book_type_code_tbl(l_count)
         and    corp_period_counter = l_corp_period_counter_tbl(l_count)
         and    event_id is null;


      l_rows_processed := l_event_id_tbl.count;

      -- Update fa_mc_deferred_deprn table with event_id
      FORALL l_count IN 1..l_event_id_tbl.count
         update fa_mc_deferred_deprn
         set    event_id = l_event_id_tbl(l_count)
         where  asset_id = l_asset_id_tbl(l_count)
         and    corp_book_type_code = l_corp_book_type_code_tbl(l_count)
         and    tax_book_type_code = l_tax_book_type_code_tbl(l_count)
         and    corp_period_counter = l_corp_period_counter_tbl(l_count)
         and    event_id is null;

      -- Add events to fa_deferred_deprn_events table
      FOR l_count IN 1..l_event_id_tbl.count LOOP
         insert into fa_deferred_deprn_events (
            asset_id,
            corp_book_type_code,
            tax_book_type_code,
            corp_period_counter,
            tax_period_counter,
            event_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login
         ) select
            l_asset_id_tbl(l_count),
            l_corp_book_type_code_tbl(l_count),
            l_tax_book_type_code_tbl(l_count),
            l_corp_period_counter_tbl(l_count),
            l_tax_period_counter_tbl(l_count),
            l_event_id_tbl(l_count),
            sysdate,
            c_upgrade_bugno,
            sysdate,
            c_upgrade_bugno,
            c_upgrade_bugno
         from dual
         where not exists
         (
          select 'x'
          from   fa_deferred_deprn_events
          where  asset_id = l_asset_id_tbl(l_count)
          and    corp_book_type_code = l_corp_book_type_code_tbl(l_count)
          and    corp_period_counter = l_corp_period_counter_tbl(l_count)
          and    tax_book_type_code = l_tax_book_type_code_tbl(l_count)
          and    tax_period_counter = l_tax_period_counter_tbl(l_count)
         );
      END LOOP;

      -- Business Rules for xla_transaction_entities
      -- * ledger_id is the same as set_of_books_id
      -- * legal_entity_id is null
      -- * entity_code can be TRANSACTIONS or DEPRECIATION
      -- * for TRANSACTIONS:
      --       source_id_int_1 is transaction_header_id
      --       transaction_number is transaction_header_id
      -- * for DEPRECIATION:
      --       source_id_int is asset_id
      --       source_id_int_2 is period_counter
      --       source_id_int_3 is deprn_run_id (always 1 for upgrade)
      --       transaction_number is set_of_books_id
      -- * source_char_id_1 is book_type_code
      -- * valuation_method is book_type_code

      FORALL i IN 1..l_event_id_tbl.count
         INSERT INTO xla_transaction_entities_upg (
            upg_batch_id,
            application_id,
            ledger_id,
            legal_entity_id,
            entity_code,
            source_id_int_1,
            source_id_int_2,
            source_id_int_3,
            source_id_int_4,
            source_id_char_1,
            source_id_char_2,
            source_id_char_3,
            source_id_char_4,
            security_id_int_1,
            security_id_int_2,
            security_id_int_3,
            security_id_char_1,
            security_id_char_2,
            security_id_char_3,
            transaction_number,
            valuation_method,
            source_application_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            entity_id,
            upg_source_application_id
         ) values (
            l_upg_batch_id,                        -- upg_batch_id
            c_application_id,                      -- application_id
            l_set_of_books_id_tbl(i),              -- ledger_id
            null,                                  -- legal_entity_id,
            c_entity_code,                         -- entity_code
            l_asset_id_tbl(i),                     -- source_id_int_1
            null,                                  -- source_id_int_2
            l_corp_period_counter_tbl(i),          -- source_id_int_3
            null,                                  -- source_id_int_4
            null,                                  -- source_id_char_1
            l_corp_book_type_code_tbl(i),          -- source_id_char_2
            null,                                  -- source_id_char_3
            l_tax_book_type_code_tbl(i),           -- source_id_char_4
            null,                                  -- security_id_int_1
            null,                                  -- security_id_int_2
            null,                                  -- security_id_int_3
            null,                                  -- security_id_char_1
            null,                                  -- security_id_char_2
            null,                                  -- security_id_char_3
            l_set_of_books_id_tbl(i),              -- transaction number
            l_corp_book_type_code_tbl(i),          -- valuation_method
            c_application_id,                      -- source_application_id
            sysdate,                               -- creation_date
            c_fnd_user,                            -- created_by
            sysdate,                               -- last_update_date
            c_upgrade_bugno,                       -- last_update_by
            c_upgrade_bugno,                       -- last_update_login
            l_entity_id_tbl(i),                    -- entity_id
            c_application_id                       -- upg_source_application_id
         );

      -- Business Rules for xla_transaction_entities
      -- * event_type_code is similar to transaction_type_code
      -- * event_number is 1, but is the serial event for chronological order
      -- * event_status_code: N if event creates no journal entries
      --                      P if event would ultimately yield journals
      --                      I if event is not ready to be processed
      --                      U never use this value for upgrade
      -- * process_status_code: E if error and journals not yet created
      --                        P if processed and journals already generated
      --                        U if unprocessed and journals not generated
      --                        D only used for Global Accounting Engine
      --                        I do not use for upgrade
      -- * on_hold_flag: N should always be this value for upgraded entries
      -- * event_date is basically transaction_date_entered

      FORALL i IN 1..l_event_id_tbl.count
         insert into xla_events (
            upg_batch_id,
            application_id,
            event_type_code,
            event_number,
            event_status_code,
            process_status_code,
            on_hold_flag,
            event_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_update_date,
            program_id,
            program_application_id,
            request_id,
            entity_id,
            event_id,
            upg_source_application_id,
            transaction_date
         ) values (
            l_upg_batch_id,                          -- upg_batch_id
            c_application_id,                        -- application_id
            l_event_class_code_tbl(i),               -- event_type_code
            '1',                                     -- event_number
            'P',                                     -- event_status_code
            'P',                                     -- process_status_code
            'N',                                     -- on_hold_flag
            l_cal_period_close_date_tbl(i),          -- event_date
-- Bug 7036409  l_transaction_date_entered_tbl(i),       -- event_date
            sysdate,                                 -- creation_date
            c_fnd_user,                              -- created_by
            sysdate,                                 -- last_update_date
            c_upgrade_bugno,                         -- last_update_by
            c_upgrade_bugno,                         -- last_update_login
            null,                                    -- program_update_date
            null,                                    -- program_id
            null,                                    -- program_application_id
            null,                                    -- program_update_date
            l_entity_id_tbl(i),                      -- entity_id
            l_event_id_tbl(i),                       -- event_id
            c_application_id,                        -- upg_source_appl_id
            l_transaction_date_entered_tbl(i)        -- transaction_date
         );

      FOR i IN 1..l_event_id_tbl.count LOOP

            open c_detail (l_corp_book_type_code_tbl(i),
                           l_tax_book_type_code_tbl(i),
                           l_asset_id_tbl(i),
                           l_corp_period_counter_tbl(i),
                           l_tax_period_counter_tbl(i));
            fetch c_detail bulk collect
            into l_distribution_id_tbl,
                 l_debit_amount_tbl,
                 l_credit_amount_tbl,
                 l_dr_ccid_tbl,
                 l_cr_ccid_tbl,
                 l_exp_je_line_num_tbl,
                 l_rsv_je_line_num_tbl,
                 l_dfr_exp_desc_tbl,
                 l_dfr_rsv_desc_tbl,
                 l_je_batch_id_tbl,
                 l_je_header_id_tbl,
                 l_gl_transfer_status_code_tbl;
            close c_detail;

            select xla_ae_headers_s.nextval
            into   l_ae_header_id
            from   dual;

            FOR j IN 1..l_distribution_id_tbl.count LOOP

               select xla_gl_sl_link_id_s.nextval
               into   l_exp_xla_gl_sl_link_id_tbl(j)
               from   dual;

               select xla_gl_sl_link_id_s.nextval
               into   l_rsv_xla_gl_sl_link_id_tbl(j)
               from   dual;

               l_line_num_tbl(j) := (j - 1) * 2;
            END LOOP;

      -- Business Rules for xla_ae_headers
      -- * amb_context_code is DEFAULT
      -- * reference_date must be null
      -- * balance_type_code:
      --     A: Actual
      --     B: Budget
      --     E: Encumbrance
      -- * gl_transfer_status_code:
      --     Y: already transferred to GL
      --     N: not transferred to GL
      -- * gl_transfer_date is date entry transferred to GL
      -- * accounting_entry_status_code must be F
      -- * accounting_entry_type_code must be STANDARD
      -- * product_rule_* not relevant for upgrade

         insert into xla_ae_headers (
            upg_batch_id,
            application_id,
            amb_context_code,
            entity_id,
            event_id,
            event_type_code,
            ae_header_id,
            ledger_id,
            accounting_date,
            period_name,
            reference_date,
            balance_type_code,
            je_category_name,
            gl_transfer_status_code,
            gl_transfer_date,
            accounting_entry_status_code,
            accounting_entry_type_code,
            description,
            budget_version_id,
            funds_status_code,
            encumbrance_type_id,
            completed_date,
            doc_sequence_id,
            doc_sequence_value,
            doc_category_code,
            packet_id,
            group_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_id,
            program_application_id,
            program_update_date,
            request_id,
            close_acct_seq_assign_id,
            close_acct_seq_version_id,
            close_acct_seq_value,
            completion_acct_seq_assign_id,
            completion_acct_seq_version_id,
            completion_acct_seq_value,
            accounting_batch_id,
            product_rule_type_code,
            product_rule_code,
            product_rule_version,
            upg_source_application_id,
            upg_valid_flag
         ) values (
            l_upg_batch_id,                     -- upg_batch_id
            c_application_id,                   -- application_id
            c_amb_context_code,                 -- amb_context_code
            l_entity_id_tbl(i),                 -- entity_id
            l_event_id_tbl(i),                  -- event_id,
            l_event_class_code_tbl(i),          -- event_type_code
            l_ae_header_id,                     -- ae_header_id,
            l_set_of_books_id_tbl(i),           -- ledger_id/sob_id
            l_cal_period_close_date_tbl(i),     -- accounting_date,
            l_period_name_tbl(i),               -- period_name,
            null,                               -- reference_date
            'A',                                -- balance_type_code,
            l_je_category_name_tbl(i),          -- je_category_name
            l_gl_transfer_status_code_tbl(1),   -- gl_transfer_status_code
            null,                               -- gl_transfer_date
            'F',                                -- accounting_entry_status_code
            'STANDARD',                         -- accounting_entry_type_code
            'Deferred Depreciation - ' ||
               to_char(l_cal_period_close_date_tbl(i), 'DD-MON-RR'),
                                                -- description
            null,                               -- budget_version_id
            null,                               -- funds_status_code
            null,                               -- encumbrance_type_id
            null,                               -- completed_date
            null,                               -- doc_sequence_id
            null,                               -- doc_sequence_value
            null,                               -- doc_category_code
            null,                               -- packet_id,
            null,                               -- group_id
            sysdate,                            -- creation_date
            c_fnd_user,                         -- created_by
            sysdate,                            -- last_update_date
            c_fnd_user,                         -- last_updated_by
            c_upgrade_bugno,                    -- last_update_login
            null,                               -- program_id
            c_application_id,                   -- program_application_id
            sysdate,                            -- program_update_date
            null,                               -- request_id
            null,                               -- close_acct_seq_assign_id
            null,                               -- close_acct_seq_version_id
            null,                               -- close_acct_seq_value
            null,                               -- compl_acct_seq_assign_id
            null,                               -- compl_acct_seq_version_id
            null,                               -- compl_acct_seq_value
            null,                               -- accounting_batch_id
            null,                               -- product_rule_type_code
            null,                               -- product_rule_code
            null,                               -- product_rule_version
            c_application_id,                   -- upg_souce_application_id
            null                                -- upg_valid_flag
         );

      -- Business Rules for xla_ae_lines
      -- * gl_transfer_mode_code:
      --       D: Detailed mode when transferred to GL
      --       S: Summary mode when transferred to GL
      -- * gl_sl_link_table must be XLAJEL
      -- * currency_conversion_* needs to be populated only if different from
      --       ledger currency

      FORALL j IN 1..l_distribution_id_tbl.count
         insert into xla_ae_lines (
            upg_batch_id,
            ae_header_id,
            ae_line_num,
            displayed_line_number,
            application_id,
            code_combination_id,
            gl_transfer_mode_code,
            accounted_dr,
            accounted_cr,
            currency_code,
            currency_conversion_date,
            currency_conversion_rate,
            currency_conversion_type,
            entered_dr,
            entered_cr,
            description,
            accounting_class_code,
            gl_sl_link_id,
            gl_sl_link_table,
            party_type_code,
            party_id,
            party_site_id,
            statistical_amount,
            ussgl_transaction_code,
            jgzz_recon_ref,
            control_balance_flag,
            analytical_balance_flag,
            upg_tax_reference_id1,
            upg_tax_reference_id2,
            upg_tax_reference_id3,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_update_date,
            program_id,
            program_application_id,
            request_id,
            gain_or_loss_flag,
            accounting_date,
            ledger_id
         ) values (
            l_upg_batch_id,                 -- upg_batch_id
            l_ae_header_id,                 -- ae_header_id
            l_line_num_tbl(j) + 1,          -- ae_line_num
            l_line_num_tbl(j) + 1,          -- displayed_line_num
            c_application_id,               -- application_id
            l_dr_ccid_tbl(j),               -- code_combination_id
            'S',                            -- gl_transfer_mode_code
            l_debit_amount_tbl(j),          -- accounted_dr
            null,                           -- accounted_cr
            l_currency_code_tbl(i),         -- currency_code
            null,                           -- currency_conversion_date
            null,                           -- currency_conversion_rate
            null,                           -- currency_conversion_type
            l_debit_amount_tbl(j),          -- entered_dr
            null,                           -- entered_cr
            l_dfr_exp_desc_tbl(j) || ' - ' ||
               to_char(l_cal_period_close_date_tbl(i), 'DD-MON-RR'),
                                            -- description
            'EXPENSE',                      -- accounting_class_code
            l_exp_xla_gl_sl_link_id_tbl(j), -- gl_sl_link_id
            'XLAJEL',                       -- gl_sl_link_table
            null,                           -- party_type_code
            null,                           -- party_id
            null,                           -- party_site_id
            null,                           -- statistical_amount
            null,                           -- ussgl_transaction_code
            null,                           -- glzz_recon_ref
            null,                           -- control_balance_flag
            null,                           -- analytical_balance_flag
            null,                           -- upg_tax_reference_id1
            null,                           -- upg_tax_reference_id2
            null,                           -- upg_tax_reference_id3
            sysdate,                        -- creation_date
            c_fnd_user,                     -- created_by
            sysdate,                        -- last_update_date
            c_fnd_user,                     -- last_updated_by
            c_upgrade_bugno,                -- last_update_login
            null,                           -- program_update_date
            null,                           -- program_id
            c_application_id,               -- program_application_id
            null,                           -- request_id
            'N',                            -- gain_or_loss_flag
            l_cal_period_close_date_tbl(i), -- accounting_date,
            l_set_of_books_id_tbl(i)        -- ledger_id/sob_id
         );

      FORALL j IN 1..l_distribution_id_tbl.count
         insert into xla_ae_lines (
            upg_batch_id,
            ae_header_id,
            ae_line_num,
            displayed_line_number,
            application_id,
            code_combination_id,
            gl_transfer_mode_code,
            accounted_dr,
            accounted_cr,
            currency_code,
            currency_conversion_date,
            currency_conversion_rate,
            currency_conversion_type,
            entered_dr,
            entered_cr,
            description,
            accounting_class_code,
            gl_sl_link_id,
            gl_sl_link_table,
            party_type_code,
            party_id,
            party_site_id,
            statistical_amount,
            ussgl_transaction_code,
            jgzz_recon_ref,
            control_balance_flag,
            analytical_balance_flag,
            upg_tax_reference_id1,
            upg_tax_reference_id2,
            upg_tax_reference_id3,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_update_date,
            program_id,
            program_application_id,
            request_id,
            gain_or_loss_flag,
            accounting_date,
            ledger_id
         ) values (
            l_upg_batch_id,                 -- upg_batch_id
            l_ae_header_id,                 -- ae_header_id
            l_line_num_tbl(j) + 2,          -- ae_line_num
            l_line_num_tbl(j) + 2,          -- displayed_line_num
            c_application_id,               -- application_id
            l_cr_ccid_tbl(j),               -- code_combination_id
            'S',                            -- gl_transfer_mode_code
            null,                           -- accounted_dr
            l_credit_amount_tbl(j),         -- accounted_cr
            l_currency_code_tbl(i),         -- currency_code
            null,                           -- currency_conversion_date
            null,                           -- currency_conversion_rate
            null,                           -- currency_conversion_type
            null,                           -- entered_dr
            l_credit_amount_tbl(j),         -- entered_cr
            l_dfr_rsv_desc_tbl(j) || ' - ' ||
               to_char(l_cal_period_close_date_tbl(i), 'DD-MON-RR'),
            'ASSET',                        -- accounting_class_code
            l_rsv_xla_gl_sl_link_id_tbl(j), -- gl_sl_link_id
            'XLAJEL',                       -- gl_sl_link_table
            null,                           -- party_type_code
            null,                           -- party_id
            null,                           -- party_site_id
            null,                           -- statistical_amount
            null,                           -- ussgl_transaction_code
            null,                           -- glzz_recon_ref
            null,                           -- control_balance_flag
            null,                           -- analytical_balance_flag
            null,                           -- upg_tax_reference_id1
            null,                           -- upg_tax_reference_id2
            null,                           -- upg_tax_reference_id3
            sysdate,                        -- creation_date
            c_fnd_user,                     -- created_by
            sysdate,                        -- last_update_date
            c_fnd_user,                     -- last_updated_by
            c_upgrade_bugno,                -- last_update_login
            null,                           -- program_update_date
            null,                           -- program_id
            c_application_id,               -- program_application_id
            null,                           -- request_id
            'N',                            -- gain_or_loss_flag
            l_cal_period_close_date_tbl(i), -- accounting_date,
            l_set_of_books_id_tbl(i)        -- ledger_id/sob_id
         );

      -- Business Rules for xla_distribution_links
      -- * accounting_line_code is similar to adjustment_type
      -- * accounting_line_type_code is S
      -- * merge_duplicate_code is N
      -- * source_distribution_type is DEFERRED
      -- * source_distribution_id_num_1 is transaction_header_id
      -- * source_distribution_id_num_2 is event_id

      FORALL j IN 1..l_distribution_id_tbl.count
         insert into xla_distribution_links (
            upg_batch_id,
            application_id,
            event_id,
            ae_header_id,
            ae_line_num,
            accounting_line_code,
            accounting_line_type_code,
            source_distribution_type,
            source_distribution_id_char_1,
            source_distribution_id_char_2,
            source_distribution_id_char_3,
            source_distribution_id_char_4,
            source_distribution_id_char_5,
            source_distribution_id_num_1,
            source_distribution_id_num_2,
            source_distribution_id_num_3,
            source_distribution_id_num_4,
            source_distribution_id_num_5,
            merge_duplicate_code,
            statistical_amount,
            unrounded_entered_dr,
            unrounded_entered_cr,
            unrounded_accounted_dr,
            unrounded_accounted_cr,
            ref_ae_header_id,
            ref_temp_line_num,
            ref_event_id,
            temp_line_num,
            tax_line_ref_id,
            tax_summary_line_ref_id,
            tax_rec_nrec_dist_ref_id,
            line_definition_owner_code,
            line_definition_code,
            event_class_code,
            event_type_code
         ) values (
            l_upg_batch_id,                 -- upg_batch_id
            c_application_id,               -- application_id
            l_event_id_tbl(i),              -- event_id
            l_ae_header_id,                 -- ae_header_id
            l_line_num_tbl(j) + 1,          -- ae_line_num
            null,                           -- accounting_line_code
            'S',                            -- accounting_line_type_code
            'DEFERRED',                     -- source_distribution_type
            null,                           -- source_distribution_id_char_1
            null,                           -- source_distribution_id_char_2
            null,                           -- source_distribution_id_char_3
            l_corp_book_type_code_tbl(i),   -- source_distribution_id_char_4
            l_tax_book_type_code_tbl(i),    -- source_distribution_id_char_5
            l_asset_id_tbl(i),              -- source_distribution_id_num_1
            l_corp_period_counter_tbl(i),   -- source_distribution_id_num_2
            l_distribution_id_tbl(j),       -- source_distribution_id_num_3
            null,                           -- source_distribution_id_num_4
            null,                           -- source_distribution_id_num_5
            'N',                            -- merge_duplicate_code
            null,                           -- statistical_amount
            l_debit_amount_tbl(j),          -- unrounded_entered_dr
            null,                           -- unrounded_entered_cr
            l_debit_amount_tbl(j),          -- unrounded_accounted_dr
            null,                           -- unrounded_accounted_cr
            l_ae_header_id,                 -- ref_ae_header_id
            null,                           -- ref_temp_line_num
            null,                           -- ref_event_id
            l_line_num_tbl(j) + 1,          -- temp_line_num
            null,                           -- tax_line_ref_id
            null,                           -- tax_summary_line_ref_id
            null,                           -- tax_rec_nrec_dist_ref_id
            null,                           -- line_definition_owner_code
            null,                           -- line_definition_code
            l_event_class_code_tbl(i),      -- event_class_code
            l_event_class_code_tbl(i)       -- event_type_code
         );

      FORALL j IN 1..l_distribution_id_tbl.count
         insert into xla_distribution_links (
            upg_batch_id,
            application_id,
            event_id,
            ae_header_id,
            ae_line_num,
            accounting_line_code,
            accounting_line_type_code,
            source_distribution_type,
            source_distribution_id_char_1,
            source_distribution_id_char_2,
            source_distribution_id_char_3,
            source_distribution_id_char_4,
            source_distribution_id_char_5,
            source_distribution_id_num_1,
            source_distribution_id_num_2,
            source_distribution_id_num_3,
            source_distribution_id_num_4,
            source_distribution_id_num_5,
            merge_duplicate_code,
            statistical_amount,
            unrounded_entered_dr,
            unrounded_entered_cr,
            unrounded_accounted_dr,
            unrounded_accounted_cr,
            ref_ae_header_id,
            ref_temp_line_num,
            ref_event_id,
            temp_line_num,
            tax_line_ref_id,
            tax_summary_line_ref_id,
            tax_rec_nrec_dist_ref_id,
            line_definition_owner_code,
            line_definition_code,
            event_class_code,
            event_type_code
         ) values (
            l_upg_batch_id,                 -- upg_batch_id
            c_application_id,               -- application_id
            l_event_id_tbl(i),              -- event_id
            l_ae_header_id,                 -- ae_header_id
            l_line_num_tbl(j) + 2,          -- ae_line_num
            null,                           -- accounting_line_code
            'S',                            -- accounting_line_type_code
            'DEFERRED',                     -- source_distribution_type
            null,                           -- source_distribution_id_char_1
            null,                           -- source_distribution_id_char_2
            null,                           -- source_distribution_id_char_3
            l_corp_book_type_code_tbl(i),   -- source_distribution_id_char_4
            l_tax_book_type_code_tbl(i),    -- source_distribution_id_char_5
            l_asset_id_tbl(i),              -- source_distribution_id_num_1
            l_corp_period_counter_tbl(i),   -- source_distribution_id_num_2
            l_distribution_id_tbl(j),       -- source_distribution_id_num_3
            null,                           -- source_distribution_id_num_4
            null,                           -- source_distribution_id_num_5
            'N',                            -- merge_duplicate_code
            null,                           -- statistical_amount
            null,                           -- unrounded_entered_dr
            l_credit_amount_tbl(j),         -- unrounded_entered_cr
            null,                           -- unrounded_accounted_dr
            l_credit_amount_tbl(j),         -- unrounded_accounted_cr
            l_ae_header_id,                 -- ref_ae_header_id
            null,                           -- ref_temp_line_num
            null,                           -- ref_event_id
            l_line_num_tbl(j) + 2,          -- temp_line_num
            null,                           -- tax_line_ref_id
            null,                           -- tax_summary_line_ref_id
            null,                           -- tax_rec_nrec_dist_ref_id
            null,                           -- line_definition_owner_code
            null,                           -- line_definition_code
            l_event_class_code_tbl(i),      -- event_class_code
            l_event_class_code_tbl(i)       -- event_type_code
         );

         FOR j IN 1..l_distribution_id_tbl.count LOOP
               if (l_je_batch_id_tbl(j) is not null) then
                  insert into gl_import_references (
                     je_batch_id,
                     je_header_id,
                     je_line_num,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     reference_1,
                     reference_2,
                     reference_3,
                     reference_4,
                     reference_5,
                     reference_6,
                     reference_7,
                     reference_8,
                     reference_9,
                     reference_10,
                     subledger_doc_sequence_id,
                     subledger_doc_sequence_value,
                     gl_sl_link_id,
                     gl_sl_link_table
                  ) values (
                     l_je_batch_id_tbl(j),        -- je_batch_id
                     l_je_header_id_tbl(j),       -- je_header_id
                     l_exp_je_line_num_tbl(j),    -- je_line_num
                     sysdate,                     -- last_update_date
                     c_fnd_user,                  -- last_updated_by
                     sysdate,                     -- creation_date
                     c_fnd_user,                  -- created_by
                     c_upgrade_bugno,             -- last_update_login
                     null,                        -- reference_1
                     to_char(l_asset_id_tbl(i)),  -- reference_2
                     to_char(l_distribution_id_tbl(j)),
                                                  -- reference_3
                     null,                        -- reference_4
                     l_corp_book_type_code_tbl(j),-- reference_5
                     to_char(l_corp_period_counter_tbl(j)),
                                                  -- reference_6
                     null,                        -- reference_7
                     null,                        -- reference_8
                     null,                        -- reference_9
                     null,                        -- reference_10
                     null,                        -- subledger_doc_seq_id
                     null,                        -- subledger_doc_seq_value
                     l_exp_xla_gl_sl_link_id_tbl(j),
                                                  -- gl_sl_link_id
                     'XLAJEL'                     -- gl_sl_link_table
                  );

                  insert into gl_import_references (
                     je_batch_id,
                     je_header_id,
                     je_line_num,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     reference_1,
                     reference_2,
                     reference_3,
                     reference_4,
                     reference_5,
                     reference_6,
                     reference_7,
                     reference_8,
                     reference_9,
                     reference_10,
                     subledger_doc_sequence_id,
                     subledger_doc_sequence_value,
                     gl_sl_link_id,
                     gl_sl_link_table
                  ) values (
                     l_je_batch_id_tbl(j),        -- je_batch_id
                     l_je_header_id_tbl(j),       -- je_header_id
                     l_rsv_je_line_num_tbl(j),    -- je_line_num
                     sysdate,                     -- last_update_date
                     c_fnd_user,                  -- last_updated_by
                     sysdate,                     -- creation_date
                     c_fnd_user,                  -- created_by
                     c_upgrade_bugno,             -- last_update_login
                     null,                        -- reference_1
                     to_char(l_asset_id_tbl(i)),  -- reference_2
                     to_char(l_distribution_id_tbl(j)),
                                                  -- reference_3
                     null,                        -- reference_4
                     l_corp_book_type_code_tbl(i),-- reference_5
                     to_char(l_corp_period_counter_tbl(i)),
                                                  -- reference_6
                     null,                        -- reference_7
                     null,                        -- reference_8
                     null,                        -- reference_9
                     null,                        -- reference_10
                     null,                        -- subledger_doc_seq_id
                     null,                        -- subledger_doc_seq_value
                     l_rsv_xla_gl_sl_link_id_tbl(j),
                                                  -- gl_sl_link_id
                     'XLAJEL'                     -- gl_sl_link_table
                  );
               end if;
            end loop;

      l_ae_header_id_tbl.delete;
      l_cr_ccid_tbl.delete;
      l_dr_ccid_tbl.delete;
      l_credit_amount_tbl.delete;
      l_debit_amount_tbl.delete;
      l_exp_xla_gl_sl_link_id_tbl.delete;
      l_rsv_xla_gl_sl_link_id_tbl.delete;
      l_line_def_owner_code_tbl.delete;
      l_line_def_code_tbl.delete;
      l_dfr_exp_desc_tbl.delete;
      l_dfr_rsv_desc_tbl.delete;
      l_gl_transfer_status_code_tbl.delete;
      l_je_batch_id_tbl.delete;
      l_je_header_id_tbl.delete;
      l_exp_je_line_num_tbl.delete;
      l_rsv_je_line_num_tbl.delete;
      l_distribution_id_tbl.delete;
      l_line_num_tbl.delete;

      open c_mc_books (l_corp_book_type_code_tbl(i));
      fetch c_mc_books bulk collect
      into l_rep_set_of_books_id_tbl;
      close c_mc_books;

      for k IN 1..l_rep_set_of_books_id_tbl.count loop

            open c_mc_detail (l_corp_book_type_code_tbl(i),
                           l_tax_book_type_code_tbl(i),
                           l_asset_id_tbl(i),
                           l_rep_set_of_books_id_tbl(k),
                           l_corp_period_counter_tbl(i),
                           l_tax_period_counter_tbl(i));
            fetch c_mc_detail bulk collect
            into l_distribution_id_tbl,
                 l_debit_amount_tbl,
                 l_credit_amount_tbl,
                 l_dr_ccid_tbl,
                 l_cr_ccid_tbl,
                 l_exp_je_line_num_tbl,
                 l_rsv_je_line_num_tbl,
                 l_dfr_exp_desc_tbl,
                 l_dfr_rsv_desc_tbl,
                 l_je_batch_id_tbl,
                 l_je_header_id_tbl,
                 l_gl_transfer_status_code_tbl,
                 l_currency_code_tbl;
            close c_mc_detail;

            select xla_ae_headers_s.nextval
            into   l_ae_header_id
            from   dual;

            FOR j IN 1..l_distribution_id_tbl.count LOOP

               select xla_gl_sl_link_id_s.nextval
               into   l_exp_xla_gl_sl_link_id_tbl(j)
               from   dual;

               select xla_gl_sl_link_id_s.nextval
               into   l_rsv_xla_gl_sl_link_id_tbl(j)
               from   dual;

               l_line_num_tbl(j) := (j - 1) * 2;
            END LOOP;

      -- Business Rules for xla_ae_headers
      -- * amb_context_code is DEFAULT
      -- * reference_date must be null
      -- * balance_type_code:
      --     A: Actual
      --     B: Budget
      --     E: Encumbrance
      -- * gl_transfer_status_code:
      --     Y: already transferred to GL
      --     N: not transferred to GL
      -- * gl_transfer_date is date entry transferred to GL
      -- * accounting_entry_status_code must be F
      -- * accounting_entry_type_code must be STANDARD
      -- * product_rule_* not relevant for upgrade

         insert into xla_ae_headers (
            upg_batch_id,
            application_id,
            amb_context_code,
            entity_id,
            event_id,
            event_type_code,
            ae_header_id,
            ledger_id,
            accounting_date,
            period_name,
            reference_date,
            balance_type_code,
            je_category_name,
            gl_transfer_status_code,
            gl_transfer_date,
            accounting_entry_status_code,
            accounting_entry_type_code,
            description,
            budget_version_id,
            funds_status_code,
            encumbrance_type_id,
            completed_date,
            doc_sequence_id,
            doc_sequence_value,
            doc_category_code,
            packet_id,
            group_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_id,
            program_application_id,
            program_update_date,
            request_id,
            close_acct_seq_assign_id,
            close_acct_seq_version_id,
            close_acct_seq_value,
            completion_acct_seq_assign_id,
            completion_acct_seq_version_id,
            completion_acct_seq_value,
            accounting_batch_id,
            product_rule_type_code,
            product_rule_code,
            product_rule_version,
            upg_source_application_id,
            upg_valid_flag
         ) values (
            l_upg_batch_id,                     -- upg_batch_id
            c_application_id,                   -- application_id
            c_amb_context_code,                 -- amb_context_code
            l_entity_id_tbl(i),                 -- entity_id
            l_event_id_tbl(i),                  -- event_id,
            l_event_class_code_tbl(i),          -- event_type_code
            l_ae_header_id,                     -- ae_header_id,
            l_rep_set_of_books_id_tbl(k),       -- ledger_id/sob_id
            l_cal_period_close_date_tbl(i),     -- accounting_date,
            l_period_name_tbl(i),               -- period_name,
            null,                               -- reference_date
            'A',                                -- balance_type_code,
            l_je_category_name_tbl(i),          -- je_category_name
            l_gl_transfer_status_code_tbl(1),   -- gl_transfer_status_code
            null,                               -- gl_transfer_date
            'F',                                -- accounting_entry_status_code
            'STANDARD',                         -- accounting_entry_type_code
            'Deferred Depreciation - ' ||
               to_char(l_cal_period_close_date_tbl(i), 'DD-MON-RR'),
                                                -- description
            null,                               -- budget_version_id
            null,                               -- funds_status_code
            null,                               -- encumbrance_type_id
            null,                               -- completed_date
            null,                               -- doc_sequence_id
            null,                               -- doc_sequence_value
            null,                               -- doc_category_code
            null,                               -- packet_id,
            null,                               -- group_id
            sysdate,                            -- creation_date
            c_fnd_user,                         -- created_by
            sysdate,                            -- last_update_date
            c_fnd_user,                         -- last_updated_by
            c_upgrade_bugno,                    -- last_update_login
            null,                               -- program_id
            c_application_id,                   -- program_application_id
            sysdate,                            -- program_update_date
            null,                               -- request_id
            null,                               -- close_acct_seq_assign_id
            null,                               -- close_acct_seq_version_id
            null,                               -- close_acct_seq_value
            null,                               -- compl_acct_seq_assign_id
            null,                               -- compl_acct_seq_version_id
            null,                               -- compl_acct_seq_value
            null,                               -- accounting_batch_id
            null,                               -- product_rule_type_code
            null,                               -- product_rule_code
            null,                               -- product_rule_version
            c_application_id,                   -- upg_souce_application_id
            null                                -- upg_valid_flag
         );

      -- Business Rules for xla_ae_lines
      -- * gl_transfer_mode_code:
      --       D: Detailed mode when transferred to GL
      --       S: Summary mode when transferred to GL
      -- * gl_sl_link_table must be XLAJEL
      -- * currency_conversion_* needs to be populated only if different from
      --       ledger currency

      FORALL j IN 1..l_distribution_id_tbl.count
         insert into xla_ae_lines (
            upg_batch_id,
            ae_header_id,
            ae_line_num,
            displayed_line_number,
            application_id,
            code_combination_id,
            gl_transfer_mode_code,
            accounted_dr,
            accounted_cr,
            currency_code,
            currency_conversion_date,
            currency_conversion_rate,
            currency_conversion_type,
            entered_dr,
            entered_cr,
            description,
            accounting_class_code,
            gl_sl_link_id,
            gl_sl_link_table,
            party_type_code,
            party_id,
            party_site_id,
            statistical_amount,
            ussgl_transaction_code,
            jgzz_recon_ref,
            control_balance_flag,
            analytical_balance_flag,
            upg_tax_reference_id1,
            upg_tax_reference_id2,
            upg_tax_reference_id3,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_update_date,
            program_id,
            program_application_id,
            request_id,
            gain_or_loss_flag,
            accounting_date,
            ledger_id
         ) values (
            l_upg_batch_id,                 -- upg_batch_id
            l_ae_header_id,                 -- ae_header_id
            l_line_num_tbl(j) + 1,          -- ae_line_num
            l_line_num_tbl(j) + 1,          -- displayed_line_num
            c_application_id,               -- application_id
            l_dr_ccid_tbl(j),               -- code_combination_id
            'S',                            -- gl_transfer_mode_code
            l_debit_amount_tbl(j),          -- accounted_dr
            null,                           -- accounted_cr
            l_currency_code_tbl(j),         -- currency_code
            null,                           -- currency_conversion_date
            null,                           -- currency_conversion_rate
            null,                           -- currency_conversion_type
            l_debit_amount_tbl(j),          -- entered_dr
            null,                           -- entered_cr
            l_dfr_exp_desc_tbl(j) || ' - ' ||
               to_char(l_cal_period_close_date_tbl(i), 'DD-MON-RR'),
                                            -- description
            'EXPENSE',                      -- accounting_class_code
            l_exp_xla_gl_sl_link_id_tbl(j), -- gl_sl_link_id
            'XLAJEL',                       -- gl_sl_link_table
            null,                           -- party_type_code
            null,                           -- party_id
            null,                           -- party_site_id
            null,                           -- statistical_amount
            null,                           -- ussgl_transaction_code
            null,                           -- glzz_recon_ref
            null,                           -- control_balance_flag
            null,                           -- analytical_balance_flag
            null,                           -- upg_tax_reference_id1
            null,                           -- upg_tax_reference_id2
            null,                           -- upg_tax_reference_id3
            sysdate,                        -- creation_date
            c_fnd_user,                     -- created_by
            sysdate,                        -- last_update_date
            c_fnd_user,                     -- last_updated_by
            c_upgrade_bugno,                -- last_update_login
            null,                           -- program_update_date
            null,                           -- program_id
            c_application_id,               -- program_application_id
            null,                           -- request_id
            'N',                            -- gain_or_loss_flag
            l_cal_period_close_date_tbl(i), -- accounting_date,
            l_rep_set_of_books_id_tbl(k)    -- ledger_id/sob_id
         );

      FORALL j IN 1..l_distribution_id_tbl.count
         insert into xla_ae_lines (
            upg_batch_id,
            ae_header_id,
            ae_line_num,
            displayed_line_number,
            application_id,
            code_combination_id,
            gl_transfer_mode_code,
            accounted_dr,
            accounted_cr,
            currency_code,
            currency_conversion_date,
            currency_conversion_rate,
            currency_conversion_type,
            entered_dr,
            entered_cr,
            description,
            accounting_class_code,
            gl_sl_link_id,
            gl_sl_link_table,
            party_type_code,
            party_id,
            party_site_id,
            statistical_amount,
            ussgl_transaction_code,
            jgzz_recon_ref,
            control_balance_flag,
            analytical_balance_flag,
            upg_tax_reference_id1,
            upg_tax_reference_id2,
            upg_tax_reference_id3,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_update_date,
            program_id,
            program_application_id,
            request_id,
            gain_or_loss_flag,
            accounting_date,
            ledger_id
         ) values (
            l_upg_batch_id,                 -- upg_batch_id
            l_ae_header_id,                 -- ae_header_id
            l_line_num_tbl(j) + 2,          -- ae_line_num
            l_line_num_tbl(j) + 2,          -- displayed_line_num
            c_application_id,               -- application_id
            l_cr_ccid_tbl(j),               -- code_combination_id
            'S',                            -- gl_transfer_mode_code
            null,                           -- accounted_dr
            l_credit_amount_tbl(j),         -- accounted_cr
            l_currency_code_tbl(j),         -- currency_code
            null,                           -- currency_conversion_date
            null,                           -- currency_conversion_rate
            null,                           -- currency_conversion_type
            null,                           -- entered_dr
            l_credit_amount_tbl(j),         -- entered_cr
            l_dfr_rsv_desc_tbl(j) || ' - ' ||
               to_char(l_cal_period_close_date_tbl(i), 'DD-MON-RR'),
            'ASSET',                        -- accounting_class_code
            l_rsv_xla_gl_sl_link_id_tbl(j), -- gl_sl_link_id
            'XLAJEL',                       -- gl_sl_link_table
            null,                           -- party_type_code
            null,                           -- party_id
            null,                           -- party_site_id
            null,                           -- statistical_amount
            null,                           -- ussgl_transaction_code
            null,                           -- glzz_recon_ref
            null,                           -- control_balance_flag
            null,                           -- analytical_balance_flag
            null,                           -- upg_tax_reference_id1
            null,                           -- upg_tax_reference_id2
            null,                           -- upg_tax_reference_id3
            sysdate,                        -- creation_date
            c_fnd_user,                     -- created_by
            sysdate,                        -- last_update_date
            c_fnd_user,                     -- last_updated_by
            c_upgrade_bugno,                -- last_update_login
            null,                           -- program_update_date
            null,                           -- program_id
            c_application_id,               -- program_application_id
            null,                           -- request_id
            'N',                            -- gain_or_loss_flag
            l_cal_period_close_date_tbl(i), -- accounting_date,
            l_rep_set_of_books_id_tbl(k)    -- ledger_id/sob_id
         );

      -- Business Rules for xla_distribution_links
      -- * accounting_line_code is similar to adjustment_type
      -- * accounting_line_type_code is S
      -- * merge_duplicate_code is N
      -- * source_distribution_type is DEFERRED
      -- * source_distribution_id_num_1 is transaction_header_id
      -- * source_distribution_id_num_2 is event_id

      FORALL j IN 1..l_distribution_id_tbl.count
         insert into xla_distribution_links (
            upg_batch_id,
            application_id,
            event_id,
            ae_header_id,
            ae_line_num,
            accounting_line_code,
            accounting_line_type_code,
            source_distribution_type,
            source_distribution_id_char_1,
            source_distribution_id_char_2,
            source_distribution_id_char_3,
            source_distribution_id_char_4,
            source_distribution_id_char_5,
            source_distribution_id_num_1,
            source_distribution_id_num_2,
            source_distribution_id_num_3,
            source_distribution_id_num_4,
            source_distribution_id_num_5,
            merge_duplicate_code,
            statistical_amount,
            unrounded_entered_dr,
            unrounded_entered_cr,
            unrounded_accounted_dr,
            unrounded_accounted_cr,
            ref_ae_header_id,
            ref_temp_line_num,
            ref_event_id,
            temp_line_num,
            tax_line_ref_id,
            tax_summary_line_ref_id,
            tax_rec_nrec_dist_ref_id,
            line_definition_owner_code,
            line_definition_code,
            event_class_code,
            event_type_code
         ) values (
            l_upg_batch_id,                 -- upg_batch_id
            c_application_id,               -- application_id
            l_event_id_tbl(i),              -- event_id
            l_ae_header_id,                 -- ae_header_id
            l_line_num_tbl(j) + 1,          -- ae_line_num
            null,                           -- accounting_line_code
            'S',                            -- accounting_line_type_code
            'DEFERRED',                     -- source_distribution_type
            /*
            null,                           -- source_distribution_id_char_1
            l_corp_book_type_code_tbl(i),   -- source_distribution_id_char_2
            null,                           -- source_distribution_id_char_3
            l_tax_book_type_code_tbl(i),    -- source_distribution_id_char_4
            null,                           -- source_distribution_id_char_5
            l_asset_id_tbl(i),              -- source_distribution_id_num_1
            null,                           -- source_distribution_id_num_2
            l_corp_period_counter_tbl(i),   -- source_distribution_id_num_3
            null,                           -- source_distribution_id_num_4
            l_distribution_id_tbl(j),       -- source_distribution_id_num_5 */
            null,                           -- source_distribution_id_char_1
            null,                           -- source_distribution_id_char_2
            null,                           -- source_distribution_id_char_3
            l_corp_book_type_code_tbl(i),   -- source_distribution_id_char_4
            l_tax_book_type_code_tbl(i),    -- source_distribution_id_char_5
            l_asset_id_tbl(i),              -- source_distribution_id_num_1
            l_corp_period_counter_tbl(i),   -- source_distribution_id_num_2
            l_distribution_id_tbl(j),       -- source_distribution_id_num_3
            null,                           -- source_distribution_id_num_4
            null,                           -- source_distribution_id_num_5
            'N',                            -- merge_duplicate_code
            null,                           -- statistical_amount
            l_debit_amount_tbl(j),          -- unrounded_entered_dr
            null,                           -- unrounded_entered_cr
            l_debit_amount_tbl(j),          -- unrounded_accounted_dr
            null,                           -- unrounded_accounted_cr
            l_ae_header_id,                 -- ref_ae_header_id
            null,                           -- ref_temp_line_num
            null,                           -- ref_event_id
            1,                              -- temp_line_num
            null,                           -- tax_line_ref_id
            null,                           -- tax_summary_line_ref_id
            null,                           -- tax_rec_nrec_dist_ref_id
            null,                           -- line_definition_owner_code
            null,                           -- line_definition_code
            l_event_class_code_tbl(i),      -- event_class_code
            l_event_class_code_tbl(i)       -- event_type_code
         );

      FORALL j IN 1..l_distribution_id_tbl.count
         insert into xla_distribution_links (
            upg_batch_id,
            application_id,
            event_id,
            ae_header_id,
            ae_line_num,
            accounting_line_code,
            accounting_line_type_code,
            source_distribution_type,
            source_distribution_id_char_1,
            source_distribution_id_char_2,
            source_distribution_id_char_3,
            source_distribution_id_char_4,
            source_distribution_id_char_5,
            source_distribution_id_num_1,
            source_distribution_id_num_2,
            source_distribution_id_num_3,
            source_distribution_id_num_4,
            source_distribution_id_num_5,
            merge_duplicate_code,
            statistical_amount,
            unrounded_entered_dr,
            unrounded_entered_cr,
            unrounded_accounted_dr,
            unrounded_accounted_cr,
            ref_ae_header_id,
            ref_temp_line_num,
            ref_event_id,
            temp_line_num,
            tax_line_ref_id,
            tax_summary_line_ref_id,
            tax_rec_nrec_dist_ref_id,
            line_definition_owner_code,
            line_definition_code,
            event_class_code,
            event_type_code
         ) values (
            l_upg_batch_id,                 -- upg_batch_id
            c_application_id,               -- application_id
            l_event_id_tbl(i),              -- event_id
            l_ae_header_id,                 -- ae_header_id
            l_line_num_tbl(j) + 2,          -- ae_line_num
            null,                           -- accounting_line_code
            'S',                            -- accounting_line_type_code
            'DEFERRED',                     -- source_distribution_type
            null,                           -- source_distribution_id_char_1
            null,                           -- source_distribution_id_char_2
            null,                           -- source_distribution_id_char_3
            l_corp_book_type_code_tbl(i),   -- source_distribution_id_char_4
            l_tax_book_type_code_tbl(i),    -- source_distribution_id_char_5
            l_asset_id_tbl(i),              -- source_distribution_id_num_1
            l_corp_period_counter_tbl(i),   -- source_distribution_id_num_2
            l_distribution_id_tbl(j),       -- source_distribution_id_num_3
            null,                           -- source_distribution_id_num_4
            null,                           -- source_distribution_id_num_5
            'N',                            -- merge_duplicate_code
            null,                           -- statistical_amount
            null,                           -- unrounded_entered_dr
            l_credit_amount_tbl(j),         -- unrounded_entered_cr
            null,                           -- unrounded_accounted_dr
            l_credit_amount_tbl(j),         -- unrounded_accounted_cr
            l_ae_header_id,                 -- ref_ae_header_id
            null,                           -- ref_temp_line_num
            null,                           -- ref_event_id
            l_line_num_tbl(j) + 2,          -- temp_line_num
            null,                           -- tax_line_ref_id
            null,                           -- tax_summary_line_ref_id
            null,                           -- tax_rec_nrec_dist_ref_id
            null,                           -- line_definition_owner_code
            null,                           -- line_definition_code
            l_event_class_code_tbl(i),      -- event_class_code
            l_event_class_code_tbl(i)       -- event_type_code
         );

         FOR j IN 1..l_distribution_id_tbl.count LOOP
               if (l_je_batch_id_tbl(j) is not null) then
                  insert into gl_import_references (
                     je_batch_id,
                     je_header_id,
                     je_line_num,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     reference_1,
                     reference_2,
                     reference_3,
                     reference_4,
                     reference_5,
                     reference_6,
                     reference_7,
                     reference_8,
                     reference_9,
                     reference_10,
                     subledger_doc_sequence_id,
                     subledger_doc_sequence_value,
                     gl_sl_link_id,
                     gl_sl_link_table
                  ) values (
                     l_je_batch_id_tbl(j),        -- je_batch_id
                     l_je_header_id_tbl(j),       -- je_header_id
                     l_exp_je_line_num_tbl(j),    -- je_line_num
                     sysdate,                     -- last_update_date
                     c_fnd_user,                  -- last_updated_by
                     sysdate,                     -- creation_date
                     c_fnd_user,                  -- created_by
                     c_upgrade_bugno,             -- last_update_login
                     null,                        -- reference_1
                     to_char(l_asset_id_tbl(i)),  -- reference_2
                     to_char(l_distribution_id_tbl(j)),
                                                  -- reference_3
                     null,                        -- reference_4
                     l_corp_book_type_code_tbl(j),-- reference_5
                     to_char(l_corp_period_counter_tbl(j)),
                                                  -- reference_6
                     null,                        -- reference_7
                     null,                        -- reference_8
                     null,                        -- reference_9
                     null,                        -- reference_10
                     null,                        -- subledger_doc_seq_id
                     null,                        -- subledger_doc_seq_value
                     l_exp_xla_gl_sl_link_id_tbl(j),
                                                  -- gl_sl_link_id
                     'XLAJEL'                     -- gl_sl_link_table
                  );

                  insert into gl_import_references (
                     je_batch_id,
                     je_header_id,
                     je_line_num,
                     last_update_date,
                     last_updated_by,
                     creation_date,
                     created_by,
                     last_update_login,
                     reference_1,
                     reference_2,
                     reference_3,
                     reference_4,
                     reference_5,
                     reference_6,
                     reference_7,
                     reference_8,
                     reference_9,
                     reference_10,
                     subledger_doc_sequence_id,
                     subledger_doc_sequence_value,
                     gl_sl_link_id,
                     gl_sl_link_table
                  ) values (
                     l_je_batch_id_tbl(j),        -- je_batch_id
                     l_je_header_id_tbl(j),       -- je_header_id
                     l_rsv_je_line_num_tbl(j),    -- je_line_num
                     sysdate,                     -- last_update_date
                     c_fnd_user,                  -- last_updated_by
                     sysdate,                     -- creation_date
                     c_fnd_user,                  -- created_by
                     c_upgrade_bugno,             -- last_update_login
                     null,                        -- reference_1
                     to_char(l_asset_id_tbl(i)),  -- reference_2
                     to_char(l_distribution_id_tbl(j)),
                                                  -- reference_3
                     null,                        -- reference_4
                     l_corp_book_type_code_tbl(i),-- reference_5
                     to_char(l_corp_period_counter_tbl(i)),
                                                  -- reference_6
                     null,                        -- reference_7
                     null,                        -- reference_8
                     null,                        -- reference_9
                     null,                        -- reference_10
                     null,                        -- subledger_doc_seq_id
                     null,                        -- subledger_doc_seq_value
                     l_rsv_xla_gl_sl_link_id_tbl(j),
                                                  -- gl_sl_link_id
                     'XLAJEL'                     -- gl_sl_link_table
                  );
               end if;
            end loop;

      l_ae_header_id_tbl.delete;
      l_cr_ccid_tbl.delete;
      l_dr_ccid_tbl.delete;
      l_credit_amount_tbl.delete;
      l_debit_amount_tbl.delete;
      l_exp_xla_gl_sl_link_id_tbl.delete;
      l_rsv_xla_gl_sl_link_id_tbl.delete;
      l_line_def_owner_code_tbl.delete;
      l_line_def_code_tbl.delete;
      l_dfr_exp_desc_tbl.delete;
      l_dfr_rsv_desc_tbl.delete;
      l_gl_transfer_status_code_tbl.delete;
      l_je_batch_id_tbl.delete;
      l_je_header_id_tbl.delete;
      l_exp_je_line_num_tbl.delete;
      l_rsv_je_line_num_tbl.delete;
      l_distribution_id_tbl.delete;
      l_line_num_tbl.delete;

      end loop;

      l_rep_set_of_books_id_tbl.delete;

    END LOOP;

    l_rowid_tbl.delete;
    l_event_id_tbl.delete;
    l_asset_id_tbl.delete;
    l_corp_book_type_code_tbl.delete;
    l_tax_book_type_code_tbl.delete;
    l_set_of_books_id_tbl.delete;
    l_org_id_tbl.delete;
    l_transaction_type_code_tbl.delete;
    l_transaction_date_entered_tbl.delete;
    l_corp_period_counter_tbl.delete;
    l_tax_period_counter_tbl.delete;
    l_period_name_tbl.delete;
    l_cal_period_close_date_tbl.delete;
    l_entity_id_tbl.delete;
    l_event_class_code_tbl.delete;
    l_currency_code_tbl.delete;

    commit;

    if (l_rows_processed < l_batch_size) then exit; end if;

 end loop;

 close c_deferred_deprn;

EXCEPTION
   WHEN OTHERS THEN
      rollback;
      raise;

END Upgrade_Deferred_Events;

END FA_SLA_EVENTS_UPG_PKG;

/
