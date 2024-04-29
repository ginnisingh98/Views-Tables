--------------------------------------------------------
--  DDL for Package Body FA_XLA_CMP_SOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_XLA_CMP_SOURCES_PKG" AS
/* $Header: faxlacsb.pls 120.17.12010000.16 2009/12/22 22:06:33 bridgway ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     fa_xla_cmp_sources_pkg                                                 |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a FA private package, which contains all the APIs required     |
|     for to determine sql statments for GT insert based on sources in       |
|     use for each extract type                                              |
|                                                                            |
| NOTES                                                                      |
|     This package relies on some static business logic specific to FA       |
|     as well as the XLA AAD setups for determining addition sources,        |
|     tables, columns to extract.                                            |
|                                                                            |
|     Primary restrictions:                                                  |
|      1) in base R12 standard sources can only be seeded by ORACLE          |
|         thus attempts to add additional sources may either be ignored      |
|         or fail (depending on whether FKs for table/column are loaded)     |
|      2) on a related note, the tables allowed in the seeded setup are      |
|         a small subset and to add a table requires not only the seed       |
|         and case impacts (GT), but also if it is a new table not yet       |
|         recognized by this program, various sections of this code must be  |
|         updated - including arrays and the "where clause append" section   |
|           WITHOUT the correct where clause the risks of excluding data or  |
|           causing cartesion products (and thus ora-1) will appear          |
|      3) New sources from existing tables can be added at any time          |
|         without impact to this program, but require case changes to the    |
|         GT extract tables to hold those sources                            |
|      4) *** NEW ***                                                        |
|         DO NOT EDIT /SAVE THIS FILE WITH TABS!!!!!!!                       |
|         String comparison in particular looks for spaces and you risk      |
|         breaking the logic.  If your editor does this, than use vi!!!!!    |
|         if you do this, then dont !!!!                                     |
|                                                                            |
| *** CUSTOMIZATION OF THIS PACKAGE OR STANDARD SOURCES IS NOT SUPPORTED *** |
|                                                                            |
| HISTORY                                                                    |
|     25-FEB-2006 BRIDGWAY      Created                                      |
|                                                                            |
+===========================================================================*/


--+==========================================================================+
--|                                                                          |
--| Private global constants                                                 |
--|                                                                          |
--+==========================================================================+

C_CREATED_ERROR       CONSTANT BOOLEAN := FALSE;
C_CREATED             CONSTANT BOOLEAN := TRUE;

g_Max_line            CONSTANT NUMBER := 225;
g_chr_quote           CONSTANT VARCHAR2(10):='''';
g_chr_newline         CONSTANT VARCHAR2(10):= fa_cmp_string_pkg.g_chr_newline;

g_log_level_rec fa_api_types.log_level_rec_type;

G_CURRENT_RUNTIME_LEVEL        NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

G_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
G_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
G_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
G_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

G_MODULE_NAME         CONSTANT VARCHAR2(50):= 'fa.plsql.fa_xla_cmp_header_pkg.';

G_initialized         boolean  := FALSE;

-- deprn
G_deprn_event_class_table     fa_char30_tbl_type;
G_known_deprn_hdr_tables      fa_char30_tbl_type;
G_known_deprn_line_tables     fa_char30_tbl_type;

-- deferred
G_def_event_class_table       fa_char30_tbl_type;
G_known_def_hdr_tables        fa_char30_tbl_type;
G_known_def_line_tables       fa_char30_tbl_type;

-- transactions (header and statging)
G_trx1_hdr_event_class_table  fa_char30_tbl_type;
G_trx2_hdr_event_class_table  fa_char30_tbl_type;
G_known_trx_hdr_tables        fa_char30_tbl_type;
G_known_stg_tables            fa_char30_tbl_type;

-- line level event classes
G_fin1_line_event_class_table fa_char30_tbl_type;
G_fin2_line_event_class_table fa_char30_tbl_type;
G_xfr_line_event_class_table  fa_char30_tbl_type;
G_dist_line_event_class_table fa_char30_tbl_type;
G_ret_line_event_class_table  fa_char30_tbl_type;

-- line level tables
G_known_fin1_line_tables      fa_char30_tbl_type;
G_known_fin2_line_tables      fa_char30_tbl_type;
G_known_xfr_line_tables       fa_char30_tbl_type;
G_known_dist1_line_tables     fa_char30_tbl_type;
G_known_dist2_line_tables     fa_char30_tbl_type;
G_known_ret_line_tables       fa_char30_tbl_type;

-- mls level tables
G_trx_mls_event_class_table   fa_char30_tbl_type;
G_known_mls_tables            fa_char30_tbl_type;

G_known_schemas               fa_char30_tbl_type;

TYPE num_tbl  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE date_tbl IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE v30_tbl  IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

g_select                      VARCHAR2(32000);
g_where                       VARCHAR2(32000);
g_rowcount_debug              VARCHAR2(32000);

-- header level constant values

c_hdr_insert CONSTANT VARCHAR2(32000)   := '
    insert into fa_xla_ext_headers_b_gt (
           event_id                                ,
           DEFAULT_CCID                            ,
           BOOK_TYPE_CODE                          ,
           PERIOD_NAME                             ,
           PERIOD_CLOSE_DATE                       ,
           PERIOD_COUNTER                          ,
           ACCOUNTING_DATE                         ,
           TRANSFER_TO_GL_FLAG                     ';

c_hdr_select CONSTANT VARCHAR2(32000)   := ' )
    select ctlgd.event_id,
           bc.FLEXBUILDER_DEFAULTS_CCID            ,
           bc.book_type_code                       ,
           dp.PERIOD_NAME                          ,
           dp.CALENDAR_PERIOD_CLOSE_DATE           ,
           dp.PERIOD_COUNTER                       ,
           ctlgd.event_date                        ,';

c_hdr_select1 CONSTANT  VARCHAR2(32000)   := '
           ''Y''                                   ' ;

c_hdr_select2 CONSTANT  VARCHAR2(32000)   := '
           decode(bc.GL_POSTING_ALLOWED_FLAG       ,
                 ''YES'', ''Y'',''N'')         ';

c_hdr_from CONSTANT VARCHAR2(32000)     := '
      FROM xla_events_gt                 ctlgd,
           fa_deprn_periods              dp,
           fa_book_controls              bc ';

c_hdr_where_trx CONSTANT VARCHAR2(32000) := '
     WHERE ctlgd.entity_code           = ''TRANSACTIONS''
       AND th.transaction_header_id    = ctlgd.source_id_int_1
       AND ctlgd.valuation_method      = dp.book_type_code
       AND ctlgd.valuation_method      = bc.book_type_code
       AND th.date_effective     between dp.period_open_date and
                                         nvl(dp.period_close_date, sysdate) ';

c_hdr_where_itrx CONSTANT VARCHAR2(32000) := '
     WHERE ctlgd.entity_code           = ''INTER_ASSET_TRANSACTIONS''
       AND trx.trx_reference_id        = ctlgd.source_id_int_1
       AND trx.event_id                = ctlgd.event_id
       AND trx.book_type_code          = dp.book_type_code
       AND trx.book_type_code          = bc.book_type_code
       AND dp.book_type_code           = trx.book_type_code
       AND trx.creation_date     between dp.period_open_date and
                                         nvl(dp.period_close_date, sysdate) ';

c_hdr_where_deprn CONSTANT VARCHAR2(32000) := '
     WHERE ctlgd.entity_code         = ''DEPRECIATION''
       AND ctlgd.event_type_code     = ''DEPRECIATION''
       AND dp.book_type_code         = ctlgd.source_id_char_1
       AND dp.period_counter         = ctlgd.source_id_int_2
       AND bc.book_type_code         = ctlgd.source_id_char_1';

c_hdr_where_def CONSTANT VARCHAR2(32000) := '
     WHERE ctlgd.entity_code         = ''DEFERRED_DEPRECIATION''
       AND ctlgd.event_type_code     = ''DEFERRED_DEPRECIATION''
       AND bc.book_type_code         = ctlgd.source_id_char_1
       AND dp.book_type_code         = ctlgd.source_id_char_1
       AND dp.period_counter         = ctlgd.source_id_int_2 ';

-- line level constant values

-- deprn

c_line_insert_deprn CONSTANT VARCHAR2(32000) := '
    insert into fa_xla_ext_lines_b_gt (
           EVENT_ID                             ,
           LINE_NUMBER                          ,
           DISTRIBUTION_ID                      ,
           DISTRIBUTION_TYPE_CODE               ,
           LEDGER_ID                            ,
           CURRENCY_CODE                        ,
           CAT_ID                               ,
           ENTERED_AMOUNT                       ,
           BONUS_ENTERED_AMOUNT                 ,
           REVAL_ENTERED_AMOUNT                 ,
           GENERATED_CCID                       ,
           GENERATED_OFFSET_CCID                ,
           BONUS_GENERATED_CCID                 ,
           BONUS_GENERATED_OFFSET_CCID          ,
           REVAL_GENERATED_CCID                 ,
           REVAL_GENERATED_OFFSET_CCID          ,
           RESERVE_ACCOUNT_CCID                 ,
           DEPRN_EXPENSE_ACCOUNT_CCID           ,
           BONUS_RESERVE_ACCT_CCID              ,
           BONUS_EXPENSE_ACCOUNT_CCID           ,
           REVAL_AMORT_ACCOUNT_CCID             ,
           REVAL_RESERVE_ACCOUNT_CCID           ,
           IMPAIR_EXPENSE_ACCOUNT_CCID          ,
           IMPAIR_RESERVE_ACCOUNT_CCID          ,
           CAPITAL_ADJ_ACCOUNT_CCID             ,
           GENERAL_FUND_ACCOUNT_CCID            ,
           BOOK_TYPE_CODE                       ,
           PERIOD_COUNTER                       '; -- Bug:6399642

c_line_select_deprn CONSTANT VARCHAR2(32000) := ' )
    select ctlgd.EVENT_ID                            ,
           dd.distribution_id                        as distribution_id,
           dd.distribution_id                        as dist_id,
           ''DEPRN''                                 ,
           bc.set_of_books_id                        ,
           le.currency_code                          ,
           cb.category_id                            ,
           dd.deprn_amount
              - dd.deprn_adjustment_amount           , -- BUG# 5094085 removing bonus subtraction intentionally
           dd.bonus_deprn_amount
              - dd.bonus_deprn_adjustment_amount     ,
           dd.reval_amortization                     ,
           dd.deprn_expense_ccid                     ,
           dd.deprn_reserve_ccid                     ,
           dd.bonus_deprn_expense_ccid               ,
           dd.bonus_deprn_reserve_ccid               ,
           dd.reval_amort_ccid                       ,
           dd.reval_reserve_ccid                     ,
           cb.RESERVE_ACCOUNT_CCID                   ,
           cb.DEPRN_EXPENSE_ACCOUNT_CCID             ,
           cb.BONUS_RESERVE_ACCT_CCID                ,
           cb.BONUS_EXPENSE_ACCOUNT_CCID             ,
           cb.REVAL_AMORT_ACCOUNT_CCID               ,
           cb.REVAL_RESERVE_ACCOUNT_CCID             ,
           cb.IMPAIR_EXPENSE_ACCOUNT_CCID            ,
           cb.IMPAIR_RESERVE_ACCOUNT_CCID            ,
           cb.CAPITAL_ADJ_ACCOUNT_CCID               ,
           cb.GENERAL_FUND_ACCOUNT_CCID              ,
           ctlgd.source_id_char_1                    ,
           dp.period_counter                         '; -- Bug:8702451

c_line_from_deprn CONSTANT VARCHAR2(32000) := '
      from xla_events_gt             ctlgd,
           fa_deprn_detail           dd,
           fa_distribution_history   dh,
           fa_additions_b            ad,
           fa_asset_history          ah,
           fa_category_books         cb,
           fa_book_controls          bc,
           gl_ledgers                le,
           fa_deprn_periods          dp ';  -- Bug 8702451

-- NOTE: we do not post track or zero lines
-- will taken care of in preprocessing hook (check track)

c_line_where_deprn CONSTANT VARCHAR2(32000) := '
     where ctlgd.entity_code           = ''DEPRECIATION''
       AND ctlgd.event_type_code       = ''DEPRECIATION''
       AND dd.asset_id                 = ctlgd.source_id_int_1
       AND dd.book_type_code           = ctlgd.source_id_char_1
       AND dd.period_counter           = ctlgd.source_id_int_2
       AND dd.deprn_run_id             = ctlgd.source_id_int_3
       AND ad.asset_id                 = ctlgd.source_id_int_1
       AND dd.distribution_id          = dh.distribution_id
       AND ah.asset_id                 = ctlgd.source_id_int_1
       AND AH.Date_Effective           < nvl(DH.Date_ineffective, SYSDATE)
       AND nvl(DH.Date_ineffective, SYSDATE) <=
           nvl(AH.Date_ineffective, SYSDATE)
       AND cb.category_id              = ah.category_id
       AND cb.book_type_code           = ctlgd.source_id_char_1
       AND ah.asset_type              in (''CAPITALIZED'', ''GROUP'')
       AND ad.asset_type              in (''CAPITALIZED'', ''GROUP'')
       AND bc.book_type_code           = ctlgd.source_id_char_1
       AND le.ledger_id                = bc.set_of_books_id
       AND dp.book_type_code           = ctlgd.source_id_char_1
       AND dp.period_counter           = ctlgd.source_id_int_2 ';



-- deferred

c_line_insert_def CONSTANT VARCHAR2(32000) := '
    insert into fa_xla_ext_lines_b_gt (
           EVENT_ID                             ,
           LINE_NUMBER                          ,
           DISTRIBUTION_ID                      ,
           DISTRIBUTION_TYPE_CODE               ,
           LEDGER_ID                            ,
           CURRENCY_CODE                        ,
           CAT_ID                               ,
           ENTERED_AMOUNT                       ,
           BOOK_TYPE_CODE                       ,
           TAX_BOOK_TYPE_CODE                   ,
           GENERATED_CCID                       ,
           GENERATED_OFFSET_CCID                ';

c_line_select_def CONSTANT VARCHAR2(32000) := ' )
    select ctlgd.EVENT_ID                            ,
           df.distribution_id                        as distribution_id,
           df.distribution_id                        as dist_id,
           ''DEFERRED''                              ,
           bc.set_of_books_id                        ,
           le.currency_code                          ,
           ah.category_id                            ,
           df.deferred_deprn_expense_amount          ,
           df.corp_book_type_code                    ,
           df.tax_book_type_code                     ,
           df.deferred_deprn_expense_ccid            ,
           df.deferred_deprn_reserve_ccid            ';

c_line_from_def CONSTANT VARCHAR2(32000) := '
      from fa_additions_b            ad,
           fa_asset_history          ah,
           fa_book_controls          bc,
           fa_category_books         cb,
           fa_distribution_history   dh,
           fa_deferred_deprn         df,
           gl_ledgers                le,
           xla_events_gt             ctlgd ';

c_line_where_def CONSTANT VARCHAR2(32000) := '
     where ctlgd.entity_code           = ''DEFERRED_DEPRECIATION''
       AND ctlgd.event_type_code       = ''DEFERRED_DEPRECIATION''
       AND df.asset_id                 = ctlgd.source_id_int_1
       AND df.corp_book_type_code      = ctlgd.source_id_char_1
       AND df.corp_period_counter      = ctlgd.source_id_int_2
       AND df.tax_book_type_code       = ctlgd.source_id_char_2
       AND df.event_id                 = ctlgd.event_id
       AND ad.asset_id                 = ctlgd.source_id_int_1
       AND dh.distribution_id          = df.distribution_id
       AND ah.asset_id                 = ctlgd.source_id_int_1
       AND AH.Date_Effective           < nvl(DH.Date_ineffective, SYSDATE)
       AND nvl(DH.Date_ineffective, SYSDATE) <=
           nvl(AH.Date_ineffective, SYSDATE)
       AND cb.category_id              = ah.category_id
       AND cb.book_type_code           = ctlgd.source_id_char_1
       AND ah.asset_type              in (''CAPITALIZED'', ''GROUP'')
       AND ad.asset_type              in (''CAPITALIZED'', ''GROUP'')
       AND bc.book_type_code           = ctlgd.source_id_char_1
       AND le.ledger_id                = bc.set_of_books_id ';


-- trx-staging

c_line_insert_stg CONSTANT VARCHAR2(32000) := '
    insert into fa_xla_ext_lines_stg_gt (
           EVENT_ID                             ,
           EVENT_TYPE_CODE                      ,
           TRANSACTION_HEADER_ID                ,
           MEMBER_TRANSACTION_HEADER_ID         ,
           DISTRIBUTION_TYPE_CODE               ,
           BOOK_TYPE_CODE                       ,
           LEDGER_ID                            ,
           CURRENCY_CODE                        ,
           CAT_ID                               ,
           ASSET_TYPE                           ,
           ASSET_COST_ACCOUNT_CCID              ,
           ASSET_CLEARING_ACCOUNT_CCID          ,
           CIP_COST_ACCOUNT_CCID                ,
           CIP_CLEARING_ACCOUNT_CCID            ,
           RESERVE_ACCOUNT_CCID                 ,
           DEPRN_EXPENSE_ACCOUNT_CCID           ,
           BONUS_RESERVE_ACCT_CCID              ,
           BONUS_EXPENSE_ACCOUNT_CCID           ,
           REVAL_AMORT_ACCOUNT_CCID             ,
           REVAL_RESERVE_ACCOUNT_CCID           ,
           UNPLAN_EXPENSE_ACCOUNT_CCID          ,
           ALT_COST_ACCOUNT_CCID                ,
           WRITE_OFF_ACCOUNT_CCID               ,
           IMPAIR_EXPENSE_ACCOUNT_CCID          ,
           IMPAIR_RESERVE_ACCOUNT_CCID          ,
           CAPITAL_ADJ_ACCOUNT_CCID             ,
           GENERAL_FUND_ACCOUNT_CCID            ,
           DEPRN_EXPENSE_ACCT   ';

c_line_select_stg CONSTANT VARCHAR2(32000) := ' )
    select ctlgd.EVENT_ID                            ,
           ctlgd.event_type_code                     ,
           th.transaction_header_id                  ,
           nvl(th.member_transaction_header_id,
               th.transaction_header_id)             ,
           ''TRX''                                   ,
           bc.book_type_code                         , -- Bug:6272229
           bc.set_of_books_id                        ,
           le.currency_code                          ,
           cb.category_id                            ,
           ah.asset_type                             ,
           cb.ASSET_COST_ACCOUNT_CCID                ,
           cb.ASSET_CLEARING_ACCOUNT_CCID            ,
           cb.WIP_COST_ACCOUNT_CCID                  ,
           cb.WIP_CLEARING_ACCOUNT_CCID              ,
           cb.RESERVE_ACCOUNT_CCID                   ,
           cb.DEPRN_EXPENSE_ACCOUNT_CCID             ,
           cb.BONUS_RESERVE_ACCT_CCID                ,
           cb.BONUS_EXPENSE_ACCOUNT_CCID             ,
           cb.REVAL_AMORT_ACCOUNT_CCID               ,
           cb.REVAL_RESERVE_ACCOUNT_CCID             ,
           cb.UNPLAN_EXPENSE_ACCOUNT_CCID            ,
           cb.ALT_COST_ACCOUNT_CCID                  ,
           cb.WRITE_OFF_ACCOUNT_CCID                 ,
           cb.IMPAIR_EXPENSE_ACCOUNT_CCID            ,
           cb.IMPAIR_RESERVE_ACCOUNT_CCID            ,
           cb.CAPITAL_ADJ_ACCOUNT_CCID               ,
           cb.GENERAL_FUND_ACCOUNT_CCID              ,
           cb.DEPRN_EXPENSE_ACCT   ';

c_line_from_stg1 CONSTANT VARCHAR2(32000) := '
      from fa_additions_b            ad,
           fa_asset_history          ah,
           fa_book_controls          bc,
           fa_category_books         cb,
           gl_ledgers                le,
           fa_transaction_headers    th,
           xla_events_gt             ctlgd ';

c_line_from_stg2 CONSTANT VARCHAR2(32000) := '
      from fa_additions_b            ad,
           fa_asset_history          ah,
           fa_book_controls          bc,
           fa_category_books         cb,
           gl_ledgers                le,
           fa_transaction_headers    th,
           fa_trx_references         trx,
           xla_events_gt             ctlgd ';

c_line_where_stg1 CONSTANT VARCHAR2(32000) := '
     where ctlgd.entity_code           = ''TRANSACTIONS''
       AND bc.book_type_code           = ctlgd.valuation_method
       AND le.ledger_id                = bc.set_of_books_id
       AND ad.asset_id                 = th.asset_id
       AND ah.asset_id                 = th.asset_id
       AND th.transaction_header_id    between ah.transaction_header_id_in and
                                               nvl(ah.transaction_header_id_out - 1, th.transaction_header_id)
       AND cb.category_id              = ah.category_id
       AND cb.book_type_code           = ctlgd.valuation_method
       AND ah.asset_type              in (''CAPITALIZED'', ''CIP'', ''GROUP'')
       AND ad.asset_type              in (''CAPITALIZED'', ''CIP'', ''GROUP'') ';

c_line_where_stg1a CONSTANT VARCHAR2(32000) := '
        AND th.transaction_header_id        = ctlgd.source_id_int_1 ';

c_line_where_stg1b CONSTANT VARCHAR2(32000) := '
        AND th.member_transaction_header_id        = ctlgd.source_id_int_1 ';

c_line_where_stg2 CONSTANT VARCHAR2(32000) := '
     where ctlgd.entity_code           = ''INTER_ASSET_TRANSACTIONS''
       AND trx.trx_reference_id        = ctlgd.source_id_int_1
       AND bc.book_type_code           = ctlgd.valuation_method
       AND le.ledger_id                = bc.set_of_books_id
       AND ad.asset_id                 = th.asset_id
       AND ah.asset_id                 = th.asset_id
       AND th.transaction_header_id    between ah.transaction_header_id_in and
                                               nvl(ah.transaction_header_id_out - 1, th.transaction_header_id)
       AND cb.category_id              = ah.category_id
       AND cb.book_type_code           = ctlgd.valuation_method --th.book_type_code
       AND ah.asset_type              in (''CAPITALIZED'', ''CIP'', ''GROUP'')
       AND ad.asset_type              in (''CAPITALIZED'', ''CIP'', ''GROUP'') ';

c_line_where_stg2a CONSTANT VARCHAR2(32000) := '
       AND th.transaction_header_id = trx.src_transaction_header_id ';

c_line_where_stg2b CONSTANT VARCHAR2(32000) := '
       AND th.member_transaction_header_id = trx.src_transaction_header_id ';

c_line_where_stg2c CONSTANT VARCHAR2(32000) := '
       AND th.transaction_header_id = trx.dest_transaction_header_id ';

c_line_where_stg2d CONSTANT VARCHAR2(32000) := '
       AND th.member_transaction_header_id = trx.dest_transaction_header_id ';

-- trx - lines

c_line_insert_trx CONSTANT VARCHAR2(32000) := '
    insert into fa_xla_ext_lines_b_gt (
           EVENT_ID                             ,
           LINE_NUMBER                          ,
           DISTRIBUTION_ID                      ,
           DISTRIBUTION_TYPE_CODE               ,
           LEDGER_ID                            ,
           CURRENCY_CODE                        ,
           BOOK_TYPE_CODE                       ,
           GENERATED_CCID                       ,
           ASSET_ID                             ,
           CAT_ID                               ,
           ASSET_TYPE                           ,
           ASSET_COST_ACCOUNT_CCID              ,
           ASSET_CLEARING_ACCOUNT_CCID          ,
           CIP_COST_ACCOUNT_CCID                ,
           CIP_CLEARING_ACCOUNT_CCID            ,
           RESERVE_ACCOUNT_CCID                 ,
           DEPRN_EXPENSE_ACCOUNT_CCID           ,
           BONUS_RESERVE_ACCT_CCID              ,
           BONUS_EXPENSE_ACCOUNT_CCID           ,
           REVAL_AMORT_ACCOUNT_CCID             ,
           REVAL_RESERVE_ACCOUNT_CCID           ,
           UNPLAN_EXPENSE_ACCOUNT_CCID          ,
           ALT_COST_ACCOUNT_CCID                ,
           WRITE_OFF_ACCOUNT_CCID               ,
           DEPRN_EXPENSE_ACCT                   ,
           IMPAIR_EXPENSE_ACCOUNT_CCID          ,
           IMPAIR_RESERVE_ACCOUNT_CCID          ,
           CAPITAL_ADJ_ACCOUNT_CCID             ,
           GENERAL_FUND_ACCOUNT_CCID            ,
           ENTERED_AMOUNT                       '; -- Bug:6399642

c_line_select_trx CONSTANT VARCHAR2(32000) := ' )
    select stg.EVENT_ID                            ,
           adj.adjustment_line_id                  ,
           adj.distribution_id                     ,
           stg.distribution_type_code              ,
           stg.ledger_id                           ,
           stg.currency_code                       ,
           stg.book_type_code                      ,
           adj.code_combination_id                 ,
           adj.asset_id                            ,
           stg.cat_id                              ,
           stg.asset_type                          ,
           stg.ASSET_COST_ACCOUNT_CCID             ,
           stg.ASSET_CLEARING_ACCOUNT_CCID         ,
           stg.CIP_COST_ACCOUNT_CCID               ,
           stg.CIP_CLEARING_ACCOUNT_CCID           ,
           stg.RESERVE_ACCOUNT_CCID                ,
           stg.DEPRN_EXPENSE_ACCOUNT_CCID          ,
           stg.BONUS_RESERVE_ACCT_CCID             ,
           stg.BONUS_EXPENSE_ACCOUNT_CCID          ,
           stg.REVAL_AMORT_ACCOUNT_CCID            ,
           stg.REVAL_RESERVE_ACCOUNT_CCID          ,
           stg.UNPLAN_EXPENSE_ACCOUNT_CCID         ,
           stg.ALT_COST_ACCOUNT_CCID               ,
           stg.WRITE_OFF_ACCOUNT_CCID              ,
           stg.DEPRN_EXPENSE_ACCT                  ,
           stg.IMPAIR_EXPENSE_ACCOUNT_CCID         ,
           stg.IMPAIR_RESERVE_ACCOUNT_CCID         ,
           stg.CAPITAL_ADJ_ACCOUNT_CCID            ,
           stg.GENERAL_FUND_ACCOUNT_CCID           ,';

-- BUG# 7693865
c_line_select_trx_dist1 CONSTANT VARCHAR2(32000) := ' )
    select stg.EVENT_ID                            ,
           adj.adjustment_line_id                  ,
           adj.distribution_id                     ,
           stg.distribution_type_code              ,
           stg.ledger_id                           ,
           stg.currency_code                       ,
           stg.book_type_code                      ,
           adj.code_combination_id                 ,
           adj.asset_id                            ,
           cb.category_id                          ,
           stg.asset_type                          ,
           cb.ASSET_COST_ACCOUNT_CCID             ,
           cb.ASSET_CLEARING_ACCOUNT_CCID         ,
           cb.WIP_COST_ACCOUNT_CCID               ,
           cb.WIP_CLEARING_ACCOUNT_CCID           ,
           cb.RESERVE_ACCOUNT_CCID                ,
           cb.DEPRN_EXPENSE_ACCOUNT_CCID          ,
           cb.BONUS_RESERVE_ACCT_CCID             ,
           cb.BONUS_EXPENSE_ACCOUNT_CCID          ,
           cb.REVAL_AMORT_ACCOUNT_CCID            ,
           cb.REVAL_RESERVE_ACCOUNT_CCID          ,
           cb.UNPLAN_EXPENSE_ACCOUNT_CCID         ,
           cb.ALT_COST_ACCOUNT_CCID               ,
           cb.WRITE_OFF_ACCOUNT_CCID              ,
           cb.DEPRN_EXPENSE_ACCT                  ,
           cb.IMPAIR_EXPENSE_ACCOUNT_CCID         ,
           cb.IMPAIR_RESERVE_ACCOUNT_CCID         ,
           cb.CAPITAL_ADJ_ACCOUNT_CCID            ,
           cb.GENERAL_FUND_ACCOUNT_CCID           ,';

-- adjustment_amount decode handling

c_line_adj_amt_fin1 CONSTANT VARCHAR2(32000) := '
           decode(adj.adjustment_type,
                  ''COST CLEARING'',
                      decode(debit_credit_flag,
                             ''CR'', adjustment_amount,
                             -1 * adjustment_amount),
                  ''RESERVE'',
                      decode(debit_credit_flag,
                             ''CR'', adjustment_amount,
                             -1 * adjustment_amount),
                  ''BONUS RESERVE'',
                      decode(debit_credit_flag,
                             ''CR'', adjustment_amount,
                             -1 * adjustment_amount),
                  ''REVAL RESERVE'',
                      decode(debit_credit_flag,
                             ''CR'', adjustment_amount,
                             -1 * adjustment_amount),
                  ''CIP COST'',
                      decode(stg.event_type_code,
                             ''CAPITALIZATION'',
                                   decode(debit_credit_flag,
                                          ''CR'', adjustment_amount,
                                          -1 * adjustment_amount),
                             ''REVERSE_CAPITALIZATION'',
                                   decode(debit_credit_flag,
                                          ''CR'', adjustment_amount,
                                          -1 * adjustment_amount),
                             decode(debit_credit_flag,
                                    ''DR'', adjustment_amount,
                                    -1 * adjustment_amount)),
                  ''COST'',
                      decode(debit_credit_flag,
                             ''DR'', adjustment_amount,
                             -1 * adjustment_amount),
                  ''EXPENSE'',
                      decode(debit_credit_flag,
                             ''DR'', adjustment_amount,
                             -1 * adjustment_amount),
                  ''BONUS EXPENSE'',
                      decode(debit_credit_flag,
                             ''DR'', adjustment_amount,
                              -1 * adjustment_amount),
                  ''NBV RETIRED'',
                      decode(debit_credit_flag,
                             ''DR'', adjustment_amount,
                             -1 * adjustment_amount),
                  ''PROCEEDS CLR'',
                      decode(debit_credit_flag,
                             ''DR'', adjustment_amount,
                             -1 * adjustment_amount),
                  ''REMOVALCOST CLR'',
                      decode(debit_credit_flag,
                             ''CR'', adjustment_amount,
                             -1 * adjustment_amount),
                  ''IMPAIR EXPENSE'',
                      decode(debit_credit_flag,
                             ''DR'',adjustment_amount,
                              -1 * adjustment_amount),
                  ''IMPAIR RESERVE'',
                      decode(debit_credit_flag,
                             ''CR'',adjustment_amount,
                              -1 * adjustment_amount),
                  ''CAPITAL ADJ'',
                      decode(debit_credit_flag,
                             ''DR'',adjustment_amount,
                              -1 * adjustment_amount),
                  ''GENERAL FUND'',
                      decode(debit_credit_flag,
                             ''CR'',adjustment_amount,
                              -1 * adjustment_amount),
                  ''LINK IMPAIR EXP'',
                      decode(debit_credit_flag,
                             ''CR'',adjustment_amount,
                              -1 * adjustment_amount),
                  decode(debit_credit_flag,
                         ''DR'', adjustment_amount,
                         -1 * adjustment_amount))  ';


c_line_adj_amt_fin2 CONSTANT VARCHAR2(32000) := '
           decode(adj.source_dest_code,
                  ''SOURCE'',
                  decode(adj.adjustment_type,
                         ''RESERVE'',
                             decode(debit_credit_flag,
                                    ''DR'', adjustment_amount,
                                    -1 * adjustment_amount),
                         ''BONUS RESERVE'',
                             decode(debit_credit_flag,
                                    ''DR'', adjustment_amount,
                                    -1 * adjustment_amount),
                         ''REVAL RESERVE'',
                             decode(debit_credit_flag,
                                    ''DR'', adjustment_amount,
                                    -1 * adjustment_amount),
                         ''IMPAIR RESERVE'',
                             decode(debit_credit_flag,
                                    ''DR'', adjustment_amount,
                                    -1 * adjustment_amount),
                         ''CAPITAL ADJ'',
                             decode(debit_credit_flag,
                                    ''CR'', adjustment_amount,
                                    -1 * adjustment_amount),
                         ''GENERAL FUND'',
                             decode(debit_credit_flag,
                                    ''DR'', adjustment_amount,
                                    -1 * adjustment_amount),
                          decode(debit_credit_flag,
                                 ''CR'', adjustment_amount,
                                 -1 * adjustment_amount)),
                  decode(adj.adjustment_type,
                         ''RESERVE'',
                             decode(debit_credit_flag,
                                    ''CR'', adjustment_amount,
                                     -1 * adjustment_amount),
                         ''BONUS RESERVE'',
                             decode(debit_credit_flag,
                                    ''CR'', adjustment_amount,
                                    -1 * adjustment_amount),
                         ''REVAL RESERVE'',
                             decode(debit_credit_flag,
                                    ''CR'', adjustment_amount,
                                    -1 * adjustment_amount),
                         ''IMPAIR RESERVE'',
                             decode(debit_credit_flag,
                                    ''CR'', adjustment_amount,
                                    -1 * adjustment_amount),
                         ''CAPITAL ADJ'',
                             decode(debit_credit_flag,
                                    ''DR'', adjustment_amount,
                                    -1 * adjustment_amount),
                         ''GENERAL FUND'',
                             decode(debit_credit_flag,
                                    ''CR'', adjustment_amount,
                                    -1 * adjustment_amount),
                         decode(debit_credit_flag,
                                ''DR'', adjustment_amount,
                                -1 * adjustment_amount))) ';

c_line_adj_amt_xfr CONSTANT VARCHAR2(32000) := '
           decode(adj.source_dest_code,
                  ''SOURCE'',
                  decode(adj.adjustment_type,
                         ''RESERVE'',
                             decode(debit_credit_flag,
                                    ''DR'', adjustment_amount,
                                    -1 * adjustment_amount),
                         ''BONUS RESERVE'',
                             decode(debit_credit_flag,
                                    ''DR'', adjustment_amount,
                                    -1 * adjustment_amount),
                         ''REVAL RESERVE'',
                             decode(debit_credit_flag,
                                    ''DR'', adjustment_amount,
                                    -1 * adjustment_amount),
                         ''IMPAIR RESERVE'',
                             decode(debit_credit_flag,
                                    ''DR'', adjustment_amount,
                                    -1 * adjustment_amount),
                         ''CAPITAL ADJ'',
                             decode(debit_credit_flag,
                                    ''CR'', adjustment_amount,
                                    -1 * adjustment_amount),
                         ''GENERAL FUND'',
                             decode(debit_credit_flag,
                                    ''DR'', adjustment_amount,
                                    -1 * adjustment_amount),
                         decode(debit_credit_flag,
                                ''CR'', adjustment_amount,
                                -1 * adjustment_amount)),
                  decode(adj.adjustment_type,
                         ''RESERVE'',
                             decode(debit_credit_flag,
                                    ''CR'', adjustment_amount,
                                    -1 * adjustment_amount),
                         ''BONUS RESERVE'',
                             decode(debit_credit_flag,
                                    ''CR'', adjustment_amount,
                                    -1 * adjustment_amount),
                         ''REVAL RESERVE'',
                             decode(debit_credit_flag,
                                    ''CR'', adjustment_amount,
                                    -1 * adjustment_amount),
                         ''IMPAIR RESERVE'',
                             decode(debit_credit_flag,
                                    ''CR'', adjustment_amount,
                                    -1 * adjustment_amount),
                         ''CAPITAL ADJ'',
                             decode(debit_credit_flag,
                                    ''DR'', adjustment_amount,
                                    -1 * adjustment_amount),
                         ''GENERAL FUND'',
                             decode(debit_credit_flag,
                                    ''CR'', adjustment_amount,
                                    -1 * adjustment_amount),
                         decode(debit_credit_flag,
                                ''DR'', adjustment_amount,
                                -1 * adjustment_amount))) ';

c_line_adj_amt_dist1 CONSTANT VARCHAR2(32000) := '
           decode(adj.adjustment_type,
                  ''RESERVE'',
                     decode(debit_credit_flag,
                         ''DR'', adjustment_amount,
                         -1 * adjustment_amount),
                  ''BONUS RESERVE'',
                     decode(debit_credit_flag,
                         ''DR'', adjustment_amount,
                         -1 * adjustment_amount),
                  ''REVAL RESERVE'',
                     decode(debit_credit_flag,
                            ''DR'', adjustment_amount,
                            -1 * adjustment_amount),
                  ''IMPAIR RESERVE'',
                     decode(debit_credit_flag,
                            ''DR'', adjustment_amount,
                            -1 * adjustment_amount),
                  ''CAPITAL ADJ'',
                     decode(debit_credit_flag,
                            ''CR'', adjustment_amount,
                            -1 * adjustment_amount),
                  ''GENERAL FUND'',
                     decode(debit_credit_flag,
                            ''DR'', adjustment_amount,
                            -1 * adjustment_amount),
                  decode(debit_credit_flag,
                         ''CR'', adjustment_amount,
                          -1 * adjustment_amount)) ';

c_line_adj_amt_dist2 CONSTANT VARCHAR2(32000) := '
           decode(adj.adjustment_type,
                  ''RESERVE'',
                      decode(debit_credit_flag,
                             ''CR'', adjustment_amount,
                             -1 * adjustment_amount),
                  ''BONUS RESERVE'',
                      decode(debit_credit_flag,
                             ''CR'', adjustment_amount,
                             -1 * adjustment_amount),
                  ''REVAL RESERVE'',
                      decode(debit_credit_flag,
                             ''CR'', adjustment_amount,
                             -1 * adjustment_amount),
                  ''IMPAIR RESERVE'',
                     decode(debit_credit_flag,
                            ''CR'', adjustment_amount,
                            -1 * adjustment_amount),
                  ''CAPITAL ADJ'',
                     decode(debit_credit_flag,
                            ''DR'', adjustment_amount,
                            -1 * adjustment_amount),
                  ''GENERAL FUND'',
                     decode(debit_credit_flag,
                            ''CR'', adjustment_amount,
                            -1 * adjustment_amount),
                  decode(debit_credit_flag,
                         ''DR'', adjustment_amount,
                         -1 * adjustment_amount)) ';

c_line_adj_amt_ret CONSTANT VARCHAR2(32000) := '
           decode(adj.adjustment_type,
                  ''RESERVE'',
                      decode(debit_credit_flag,
                             ''DR'', adjustment_amount,
                             -1 * adjustment_amount),
                  ''BONUS RESERVE'',
                      decode(debit_credit_flag,
                             ''DR'', adjustment_amount,
                             -1 * adjustment_amount),
                  ''REVAL RESERVE'',
                      decode(debit_credit_flag,
                             ''DR'', adjustment_amount,
                             -1 * adjustment_amount),
                  ''NBV RETIRED'',
                      decode(debit_credit_flag,
                             ''DR'', adjustment_amount,
                             -1 * adjustment_amount),
                  ''PROCEEDS CLR'',
                      decode(debit_credit_flag,
                             ''DR'', adjustment_amount,
                             -1 * adjustment_amount),
                  ''REMOVALCOST'',
                      decode(debit_credit_flag,
                             ''DR'', adjustment_amount,
                             -1 * adjustment_amount),
                  ''IMPAIR RESERVE'',
                      decode(debit_credit_flag,
                             ''DR'', adjustment_amount,
                             -1 * adjustment_amount),
                  ''CAPITAL ADJ'',
                      decode(debit_credit_flag,
                             ''DR'', adjustment_amount,
                             -1 * adjustment_amount),
                  ''GENERAL FUND'',
                      decode(debit_credit_flag,
                             ''CR'', adjustment_amount,
                             -1 * adjustment_amount),
                  decode(debit_credit_flag,
                         ''CR'', adjustment_amount,
                          -1 * adjustment_amount))  ';


c_line_from_trx CONSTANT VARCHAR2(32000) := '
      from fa_xla_ext_lines_stg_gt   stg,
           fa_adjustments            adj,
           fa_distribution_history   dh,
           fa_locations              loc,
           fa_lookups                lu ';

c_line_from_trx_dist1 CONSTANT VARCHAR2(32000) := ',
           fa_asset_history          ah,
           fa_category_books         cb ';

c_line_from_trx_ret CONSTANT VARCHAR2(32000) := ',
           fa_retirements            ret ';

c_line_where_trx CONSTANT VARCHAR2(32000) := '
     WHERE adj.transaction_header_id   = stg.transaction_header_id
       AND adj.book_type_code          = stg.book_type_code
       AND adj.distribution_id         = dh.distribution_id
       AND dh.location_id              = loc.location_id
       -- AND dh.assigned_to           = emp.employee_id(+)
       AND lu.lookup_type              = ''JOURNAL ENTRIES''
       AND lu.lookup_code              = adj.source_type_code || '' '' ||
                                         decode (adj.adjustment_type,
                                                 ''CIP COST'', ''COST'',
                                                 adj.adjustment_type)
       AND adj.adjustment_type    not in (''REVAL EXPENSE'', ''REVAL AMORT'')
       AND nvl(adj.track_member_flag, ''N'') = ''N''
       AND adj.adjustment_amount <> 0 ';

c_line_where_trx_fin1 CONSTANT VARCHAR2(32000) := '
       AND stg.event_type_code        in (''ADDITIONS'',      ''CIP_ADDITIONS'',
                                          ''ADJUSTMENTS'',    ''CIP_ADJUSTMENTS'',
                                          ''CAPITALIZATION'', ''REVERSE_CAPITALIZATION'',
                                          ''REVALUATION'',    ''CIP_REVALUATION'',
                                          ''DEPRECIATION_ADJUSTMENTS'',
                                          ''UNPLANNED_DEPRECIATION'',
                                          ''TERMINAL_GAIN_LOSS'',
                                          ''RETIREMENT_ADJUSTMENTS'',
                                          ''IMPAIRMENT'') ';

c_line_where_trx_fin2 CONSTANT VARCHAR2(32000) := '
       AND stg.event_type_code        in (''SOURCE_LINE_TRANSFERS'',
                                          ''CIP_SOURCE_LINE_TRANSFERS'',
                                          ''RESERVE_TRANSFERS'') ';

c_line_where_trx_xfr CONSTANT VARCHAR2(32000) := '
       AND stg.event_type_code        in (''TRANSFERS'', ''CIP_TRANSFERS'') ';

c_line_where_trx_dist1 CONSTANT VARCHAR2(32000) := '
       AND stg.event_type_code      in (''CATEGORY_RECLASS'', ''CIP_CATEGORY_RECLASS'',
                                        ''UNIT_ADJUSTMENTS'', ''CIP_UNIT_ADJUSTMENTS'')
       AND adj.asset_id                = ah.asset_id
       AND adj.transaction_header_id   = ah.transaction_header_id_out -- terminated row
       AND cb.category_id              = ah.category_id
       AND cb.book_type_code           = adj.book_type_code
       AND adj.source_dest_code        = ''SOURCE'' ';


c_line_where_trx_dist2 CONSTANT VARCHAR2(32000) := '
       AND stg.event_type_code       in (''CATEGORY_RECLASS'', ''CIP_CATEGORY_RECLASS'',
                                         ''UNIT_ADJUSTMENTS'', ''CIP_UNIT_ADJUSTMENTS'')
       AND adj.source_dest_code        = ''DEST'' ';


-- need to think about group in the following!!!

c_line_where_trx_ret CONSTANT VARCHAR2(32000) := '
       AND stg.event_type_code          in (''RETIREMENTS'', ''CIP_RETIREMENTS'')
       AND ret.transaction_header_id_in  = stg.member_transaction_header_id ';


c_line_where_trx_res CONSTANT VARCHAR2(32000) := '
       AND stg.event_type_code          in (''REINSTATEMENTS'',''CIP_REINSTATEMENTS'')
       AND ret.transaction_header_id_out = stg.member_transaction_header_id ';


c_rowcount_debug CONSTANT VARCHAR2(32000) := '
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name,
                        ''Rows inserted into lines: '' || to_char(SQL%ROWCOUNT));
      END IF;

';

c_mc_if_condition    CONSTANT VARCHAR2(32000) := '
      if (fa_xla_extract_util_pkg.G_alc_enabled) then

';

c_group_if_condition    CONSTANT VARCHAR2(32000) := '
      if (fa_xla_extract_util_pkg.G_group_enabled) then

';


-- header level constant values

c_mls_insert CONSTANT VARCHAR2(32000)   := '
    insert into fa_xla_ext_lines_tl_gt (
           event_id                                ,
           line_number                             ,
           LEDGER_ID                               ,
           TRANSACTION_HEADER_ID                   ,
           ASSET_ID                                ,
           DEPRN_RUN_ID                            ,
           BOOK_TYPE_CODE                          ,
           PERIOD_COUNTER                          '; -- Bug:6399642

c_mls_select CONSTANT VARCHAR2(32000)   := ' )
    select xl.event_id                             ,
           xl.line_number                          ,
           xl.ledger_id                            ,
           xl.TRANSACTION_HEADER_ID                ,
           xl.ASSET_ID                             ,
           xl.DEPRN_RUN_ID                         ,
           xl.BOOK_TYPE_CODE                       ,
           xl.PERIOD_COUNTER                       '; -- Bug:6399642

c_mls_from CONSTANT VARCHAR2(32000)     := '
      FROM fa_xla_ext_lines_b_gt     xl    ';



--+============================================+
--|                                            |
--|  PRIVATE  PROCEDURES/FUNCTIONS             |
--|                                            |
--+============================================+

-- AddMember
-- Extends and Inserts a value into table

Procedure AddMember (p_table IN OUT NOCOPY fa_char30_tbl_type,
                     p_value IN VARCHAR2)IS

   l_procedure_name  varchar2(80) := 'AddMember';

BEGIN

   p_table.EXTEND;
   p_table(p_table.last) := p_value;

EXCEPTION
   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        RAISE;

END AddMember;




procedure delete_table_member (p_table IN OUT NOCOPY v30_tbl,
                               p_index IN number) is

   l_procedure_name varchar2(80) := ' delete_table_member';
   l_count          number;

begin
   if nvl(p_index, 0) > 0 then

      p_table.delete(p_index);

      l_count := p_table.count;

      for i in p_index..l_count loop

          -- copy the next member into the current one
          p_table(i) := p_table(i+1);
      end loop;

      -- delete the last member in the array which is now a duplicate
      p_table.delete(l_count + 1);

   end if;

EXCEPTION
   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        RAISE;

end delete_table_member;



--  Initialize
--  Loads plsql tables for known tables, enttites and events classes

Procedure initialize is

   l_procedure_name  varchar2(80) := 'Initialize';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   -- schemas
   G_known_schemas :=  fa_char30_tbl_type();
   AddMember(G_known_schemas, 'FA');
   AddMember(G_known_schemas, 'GL');
   AddMember(G_known_schemas, 'XLA');


   -- deprn (used for header and lines)
   G_deprn_event_class_table := fa_char30_tbl_type();
   AddMember(G_deprn_event_class_table, 'DEPRECIATION');

   G_known_deprn_hdr_tables  := fa_char30_tbl_type();
   G_known_deprn_line_tables := fa_char30_tbl_type();

   -- header
   AddMember(G_known_deprn_hdr_tables, 'FA_BOOK_CONTROLS');
   AddMember(G_known_deprn_hdr_tables, 'FA_DEPRN_PERIODS');
   AddMember(G_known_deprn_hdr_tables, 'XLA_EVENTS_GT');

   -- lines standard
   AddMember(G_known_deprn_line_tables, 'FA_ADDITIONS_B');
   AddMember(G_known_deprn_line_tables, 'FA_ASSET_HISTORY');
   AddMember(G_known_deprn_line_tables, 'FA_BOOK_CONTROLS');
   AddMember(G_known_deprn_line_tables, 'FA_DISTRIBUTION_HISTORY');
   AddMember(G_known_deprn_line_tables, 'FA_DEPRN_DETAIL');
   AddMember(G_known_deprn_line_tables, 'FA_DEPRN_PERIODS');
   AddMember(G_known_deprn_line_tables, 'GL_LEDGERS');
   AddMember(G_known_deprn_line_tables, 'XLA_EVENTS_GT');

   -- lines non-standard
   AddMember(G_known_deprn_line_tables, 'FA_ASSET_KEYWORDS');
   AddMember(G_known_deprn_line_tables, 'FA_BOOKS');
   AddMember(G_known_deprn_line_tables, 'FA_CATEGORIES_B');
   AddMember(G_known_deprn_line_tables, 'FA_CATEGORY_BOOKS');
   AddMember(G_known_deprn_line_tables, 'FA_DEPRN_SUMMARY');
   AddMember(G_known_deprn_line_tables, 'FA_LEASES');
   AddMember(G_known_deprn_line_tables, 'FA_LOCATIONS');
   AddMember(G_known_deprn_line_tables, 'FA_METHODS');


   -- deferred (used for header and lines)
   G_def_event_class_table := fa_char30_tbl_type();
   AddMember(G_def_event_class_table,   'DEFERRED_DEPRECIATION');

   -- deferred
   G_known_def_hdr_tables  := fa_char30_tbl_type();
   G_known_def_hdr_tables  := G_known_deprn_hdr_tables;
   G_known_def_line_tables := fa_char30_tbl_type();

   -- standard
   AddMember(G_known_def_line_tables, 'FA_ADDITIONS_B');
   AddMember(G_known_def_line_tables, 'FA_ASSET_HISTORY');
   AddMember(G_known_def_line_tables, 'FA_BOOK_CONTROLS');
   AddMember(G_known_def_line_tables, 'FA_DISTRIBUTION_HISTORY');
   AddMember(G_known_def_line_tables, 'FA_DEFERRED_DEPRN');
   AddMember(G_known_def_line_tables, 'FA_DEPRN_PERIODS');
   AddMember(G_known_def_line_tables, 'GL_LEDGERS');
   AddMember(G_known_def_line_tables, 'XLA_EVENTS_GT');

   -- non-standard
   AddMember(G_known_def_line_tables, 'FA_ASSET_KEYWORDS');
   AddMember(G_known_def_line_tables, 'FA_BOOKS');
   AddMember(G_known_def_line_tables, 'FA_CATEGORIES_B');
   AddMember(G_known_def_line_tables, 'FA_CATEGORY_BOOKS');
   AddMember(G_known_def_line_tables, 'FA_LEASES');
   AddMember(G_known_def_line_tables, 'FA_LOCATIONS');
   AddMember(G_known_def_line_tables, 'FA_METHODS');


   -- headers only
   -- transactions
   G_trx1_hdr_event_class_table := fa_char30_tbl_type();

   AddMember(G_trx1_hdr_event_class_table,   'ADDITIONS');
   AddMember(G_trx1_hdr_event_class_table,   'CIP_ADDITIONS');
   AddMember(G_trx1_hdr_event_class_table,   'ADJUSTMENTS');
   AddMember(G_trx1_hdr_event_class_table,   'CIP_ADJUSTMENTS');
   AddMember(G_trx1_hdr_event_class_table,   'CAPITALIZATION');
   AddMember(G_trx1_hdr_event_class_table,   'REVALUATION');
   AddMember(G_trx1_hdr_event_class_table,   'CIP_REVALUATION');
   AddMember(G_trx1_hdr_event_class_table,   'TRANSFERS');
   AddMember(G_trx1_hdr_event_class_table,   'CIP_TRANSFERS');
   AddMember(G_trx1_hdr_event_class_table,   'CATEGORY_RECLASS');
   AddMember(G_trx1_hdr_event_class_table,   'CIP_CATEGORY_RECLASS');
   AddMember(G_trx1_hdr_event_class_table,   'UNIT_ADJUSTMENTS');
   AddMember(G_trx1_hdr_event_class_table,   'CIP_UNIT_ADJUSTMENTS');
   AddMember(G_trx1_hdr_event_class_table,   'RETIREMENTS');
   AddMember(G_trx1_hdr_event_class_table,   'CIP_RETIREMENTS');
   AddMember(G_trx1_hdr_event_class_table,   'DEPRECIATION_ADJUSTMENTS');
   AddMember(G_trx1_hdr_event_class_table,   'UNPLANNED_DEPRECIATION');
   AddMember(G_trx1_hdr_event_class_table,   'TERMINAL_GAIN_LOSS');
   AddMember(G_trx1_hdr_event_class_table,   'RETIREMENT_ADJUSTMENTS');
   AddMember(G_trx1_hdr_event_class_table,   'IMPAIRMENT');

   -- inter asset trxs
   -- used for staging and line
   G_trx2_hdr_event_class_table := fa_char30_tbl_type();

   AddMember(G_trx2_hdr_event_class_table,   'SOURCE_LINE_TRANSFERS');
   AddMember(G_trx2_hdr_event_class_table,   'CIP_SOURCE_LINE_TRANSFERS');
   AddMember(G_trx2_hdr_event_class_table,   'RESERVE_TRANSFERS');


   -- line level event classes
   G_fin1_line_event_class_table := fa_char30_tbl_type();
   G_fin2_line_event_class_table := fa_char30_tbl_type();
   G_xfr_line_event_class_table  := fa_char30_tbl_type();
   G_dist_line_event_class_table := fa_char30_tbl_type();
   G_ret_line_event_class_table  := fa_char30_tbl_type();

   AddMember(G_fin1_line_event_class_table,   'ADDITIONS');
   AddMember(G_fin1_line_event_class_table,   'CIP_ADDITIONS');
   AddMember(G_fin1_line_event_class_table,   'ADJUSTMENTS');
   AddMember(G_fin1_line_event_class_table,   'CIP_ADJUSTMENTS');
   AddMember(G_fin1_line_event_class_table,   'CAPITALIZATION');
   AddMember(G_fin1_line_event_class_table,   'REVALUATION');
   AddMember(G_fin1_line_event_class_table,   'CIP_REVALUATION');
   AddMember(G_fin1_line_event_class_table,   'DEPRECIATION_ADJUSTMENTS');
   AddMember(G_fin1_line_event_class_table,   'UNPLANNED_DEPRECIATION');
   AddMember(G_fin1_line_event_class_table,   'TERMINAL_GAIN_LOSS');
   AddMember(G_fin1_line_event_class_table,   'RETIREMENT_ADJUSTMENTS');
   AddMember(G_fin1_line_event_class_table,   'IMPAIRMENT');

   AddMember(G_fin2_line_event_class_table,   'SOURCE_LINE_TRANSFERS');
   AddMember(G_fin2_line_event_class_table,   'CIP_SOURCE_LINE_TRANSFERS');
   AddMember(G_fin2_line_event_class_table,   'RESERVE_TRANSFERS');

   AddMember(G_xfr_line_event_class_table,    'TRANSFERS');
   AddMember(G_xfr_line_event_class_table,    'CIP_TRANSFERS');

   AddMember(G_dist_line_event_class_table,   'CATEGORY_RECLASS');
   AddMember(G_dist_line_event_class_table,   'CIP_CATEGORY_RECLASS');
   AddMember(G_dist_line_event_class_table,   'UNIT_ADJUSTMENTS');
   AddMember(G_dist_line_event_class_table,   'CIP_UNIT_ADJUSTMENTS');

   AddMember(G_ret_line_event_class_table,    'RETIREMENTS');
   AddMember(G_ret_line_event_class_table,    'CIP_RETIREMENTS');

   G_known_trx_hdr_tables  := fa_char30_tbl_type();
   G_known_trx_hdr_tables  := G_known_deprn_hdr_tables;

   -- line level tables
   G_known_fin1_line_tables  := fa_char30_tbl_type();
   G_known_fin2_line_tables  := fa_char30_tbl_type();
   G_known_xfr_line_tables   := fa_char30_tbl_type();
   G_known_dist1_line_tables := fa_char30_tbl_type();
   G_known_dist2_line_tables := fa_char30_tbl_type();
   G_known_ret_line_tables   := fa_char30_tbl_type();

   AddMember(G_known_fin1_line_tables, 'FA_XLA_EXT_LINES_STG_GT');
   AddMember(G_known_fin1_line_tables, 'FA_ADJUSTMENTS');
   AddMember(G_known_fin1_line_tables, 'FA_DISTRIBUTION_HISTORY');
   AddMember(G_known_fin1_line_tables, 'FA_LOCATIONS');
   AddMember(G_known_fin1_line_tables, 'FA_LOOKUPS');

   G_known_fin2_line_tables  := G_known_fin1_line_tables;
   G_known_xfr_line_tables   := G_known_fin1_line_tables;
   G_known_dist1_line_tables := G_known_fin1_line_tables;
   G_known_dist2_line_tables := G_known_fin1_line_tables;
   G_known_ret_line_tables   := G_known_fin1_line_tables;

   AddMember(G_known_fin1_line_tables,   'FA_ASSET_INVOICES');
   AddMember(G_known_fin2_line_tables,   'FA_ASSET_INVOICES');
   AddMember(G_known_dist1_line_tables,  'FA_ASSET_HISTORY');
   AddMember(G_known_dist1_line_tables,  'FA_CATEGORY_BOOKS');
   AddMember(G_known_dist1_line_tables,  'FA_CATEGORIES_B');

   AddMember(G_known_ret_line_tables, 'FA_ASSET_INVOICES');
   AddMember(G_known_ret_line_tables, 'FA_RETIREMENTS');


   -- staging
   G_known_stg_tables := fa_char30_tbl_type();

   -- standard
   AddMember(G_known_stg_tables, 'FA_ADDITIONS_B');
   AddMember(G_known_stg_tables, 'FA_ASSET_HISTORY');
   AddMember(G_known_stg_tables, 'FA_CATEGORY_BOOKS');
   AddMember(G_known_stg_tables, 'FA_BOOK_CONTROLS');
   AddMember(G_known_stg_tables, 'FA_TRANSACTION_HEADERS');
   AddMember(G_known_stg_tables, 'GL_LEDGERS');
   AddMember(G_known_stg_tables, 'XLA_EVENTS_GT');

   -- non-standard
   AddMember(G_known_stg_tables, 'FA_ASSET_KEYWORDS');
   AddMember(G_known_stg_tables, 'FA_CATEGORIES_B');
   AddMember(G_known_stg_tables, 'FA_LEASES');
   AddMember(G_known_stg_tables, 'FA_METHODS');

   -- mls
   G_trx_mls_event_class_table := fa_char30_tbl_type();
   AddMember(G_trx_mls_event_class_table,   'ADDITIONS');
   AddMember(G_trx_mls_event_class_table,   'CIP_ADDITIONS');
   AddMember(G_trx_mls_event_class_table,   'ADJUSTMENTS');
   AddMember(G_trx_mls_event_class_table,   'CIP_ADJUSTMENTS');
   AddMember(G_trx_mls_event_class_table,   'CAPITALIZATION');
   AddMember(G_trx_mls_event_class_table,   'REVALUATION');
   AddMember(G_trx_mls_event_class_table,   'CIP_REVALUATION');
   AddMember(G_trx_mls_event_class_table,   'TRANSFERS');
   AddMember(G_trx_mls_event_class_table,   'CIP_TRANSFERS');
   AddMember(G_trx_mls_event_class_table,   'CATEGORY_RECLASS');
   AddMember(G_trx_mls_event_class_table,   'CIP_CATEGORY_RECLASS');
   AddMember(G_trx_mls_event_class_table,   'UNIT_ADJUSTMENTS');
   AddMember(G_trx_mls_event_class_table,   'CIP_UNIT_ADJUSTMENTS');
   AddMember(G_trx_mls_event_class_table,   'RETIREMENTS');
   AddMember(G_trx_mls_event_class_table,   'CIP_RETIREMENTS');
   AddMember(G_trx_mls_event_class_table,   'DEPRECIATION_ADJUSTMENTS');
   AddMember(G_trx_mls_event_class_table,   'UNPLANNED_DEPRECIATION');
   AddMember(G_trx_mls_event_class_table,   'TERMINAL_GAIN_LOSS');
   AddMember(G_trx_mls_event_class_table,   'RETIREMENT_ADJUSTMENTS');
   AddMember(G_trx_mls_event_class_table,   'SOURCE_LINE_TRANSFERS');
   AddMember(G_trx_mls_event_class_table,   'CIP_SOURCE_LINE_TRANSFERS');
   AddMember(G_trx_mls_event_class_table,   'RESERVE_TRANSFERS');
   AddMember(G_trx_mls_event_class_table,   'DEPRECIATION');
   AddMember(G_trx_mls_event_class_table,   'DEFERRED_DEPRECIATION');
   AddMember(G_trx_mls_event_class_table,   'IMPAIRMENT');

   G_known_mls_tables      := fa_char30_tbl_type();
   AddMember(G_known_mls_tables, 'FA_ADDITIONS_TL');
   AddMember(G_known_mls_tables, 'FA_CATEGORIES_TL');

   G_initialized := TRUE;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;


EXCEPTION
   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        RAISE;

end initialize;






--+==========================================================================+
--|                                                                          |
--| PUBLIC Procedure GenerateSourcesExtract                                  |
--|                                                                          |
--|
--|
--|    valid params:
--|       HEADER/DEPRN
--|       HEADER/DEF
--|       HEADER/TRX1
--|       HEADER/TRX2
--|
--|       STG/TRX1
--|       STG/TRX2
--|
--|       LINE/FIN1
--|       LINE/FIN2
--|       LINE/XFR
--|       LINE/DIST1
--|       LINE/DIST2
--|       LINE/RET
--|       LINE/RES
--|
--|       LINE/DEPRN
--|       LINE/DEF
--|
--|       MLS/DEPRN
--|       MLS/DEF
--|       MLS/TRX
--|
--+==========================================================================+


FUNCTION GenerateSourcesExtract
      (p_extract_type                 IN VARCHAR2,  -- dep/trx/def
       p_level                        IN VARCHAR2,  -- header/line/stg
       p_package_body                 OUT NOCOPY DBMS_SQL.VARCHAR2S) RETURN BOOLEAN IS


   cursor c_tables (p_tables fa_char30_tbl_type,
                    p_schemas fa_char30_tbl_type) is
   select distinct table_name,
          decode(table_name,
              -- standard headers/lines
              'FA_BOOK_CONTROLS'        , 'bc',
              'FA_DEPRN_PERIODS'        , 'dp',
              'XLA_EVENTS_GT'           , 'ctgld',
              -- standard lines
              'FA_ADDITIONS_B'          , 'ad',
              'FA_ADJUSTMENTS'          , 'adj',
              'FA_ASSET_HISTORY'        , 'ah',
              'FA_CATEGORY_BOOKS'       , 'cb',
              'FA_DISTRIBUTION_HISTORY' , 'dh',
              'FA_DEFERRED_DEPRN'       , 'df',
              'FA_DEPRN_DETAIL'         , 'dd',
              'FA_LOOKUPS'              , 'lu',
              'FA_TRANSACTION_HEADERS'  , 'th',
              'FA_RETIREMENTS'          , 'ret',
              'FA_XLA_EXT_LINES_STG_GT' , 'stg',
              'GL_LEDGERS'              , 'le',
              -- non-standard
              'FA_ADDITIONS_TL'         , 'adtl',
              'FA_ASSET_INVOICES'       , 'ai',
              'FA_ASSET_KEYWORDS'       , 'key',
              'FA_BOOKS'                , 'bk',
              'FA_CATEGORIES_B'         , 'cat',
              'FA_CATEGORIES_TL'        , 'cattl',
              'FA_DEPRN_SUMMARY'        , 'ds',
              'FA_LEASES'               , 'ls',
              'FA_LOCATIONS'            , 'loc',
              'FA_METHODS'              , 'mt',
              'INVALID')
     from all_tables tab,
          TABLE(CAST(p_tables AS fa_char30_tbl_type)) fatab,
          TABLE(CAST(p_schemas AS fa_char30_tbl_type)) stab
    where tab.table_name = fatab.column_value
      and tab.owner = stab.column_value;


   -- NOTE: we use four versions of this due to the use of the
   -- intermediate staging table for trxs...
   --
   -- 1) for header and all deprn/def line sources,
   --    select is as would be expected.
   -- 2) for trx staging, we only use known tables within the event classes
   -- 3) for trx lines, for sources already in staging table,
   --    stg becomes the table/alias and the source_code becomes the column name
   -- 4) for mls level, we use line level source but force the
   --    values selected to use one of the two known MLS tables

   cursor c_sources (p_entity_code        VARCHAR2,
                     p_source_level_code  VARCHAR2,
                     p_event_class_table  fa_char30_tbl_type) is
   select distinct
          sources.source_code,
          sources.source_table_name,
          sources.source_column_name
     from xla_aad_sources aad,
          xla_sources_b   sources,
          TABLE(CAST(p_event_class_table AS fa_char30_tbl_type)) fatab
    where aad.application_id     = 140
      and sources.application_id = 140
      and aad.entity_code        = p_entity_code
      and aad.source_level_code  = p_source_level_code
      and aad.event_class_code   = fatab.column_value
      and aad.source_code        = sources.source_code
      and sources.source_table_name is not null
      and sources.source_table_name not in ('FA_ADDITIONS_TL', 'FA_CATEGORIES_TL')
    order by 2,1;

   cursor c_sources_stg (p_entity_code        VARCHAR2,
                         p_source_level_code  VARCHAR2,
                         p_event_class_table  fa_char30_tbl_type,
                         p_known_tables       fa_char30_tbl_type) is
   select distinct
          sources.source_code,
          sources.source_table_name,
          sources.source_column_name
     from xla_aad_sources aad,
          xla_sources_b   sources,
          TABLE(CAST(p_event_class_table AS fa_char30_tbl_type)) fatab
    where aad.application_id     = 140
      and sources.application_id = 140
      and aad.entity_code        = p_entity_code
      and aad.source_level_code  = p_source_level_code
      and aad.event_class_code   = fatab.column_value
      and aad.source_code        = sources.source_code
      and sources.source_table_name is not null
      and sources.source_table_name in
          (select fatab2.column_value
             from TABLE(CAST(p_known_tables AS fa_char30_tbl_type)) fatab2)
    order by 2,1;

   cursor c_sources_trx (p_entity_code        VARCHAR2,
                         p_source_level_code  VARCHAR2,
                         p_event_class_table  fa_char30_tbl_type,
                         p_known_tables       fa_char30_tbl_type) is
   select distinct
          sources.source_code,
          'FA_XLA_EXT_LINES_STG_GT',
          sources.source_code
     from xla_aad_sources aad,
          xla_sources_b   sources,
          TABLE(CAST(p_event_class_table AS fa_char30_tbl_type)) fatab
    where aad.application_id     = 140
      and sources.application_id = 140
      and aad.entity_code        = p_entity_code
      and aad.source_level_code  = p_source_level_code
      and aad.event_class_code   = fatab.column_value
      and aad.source_code        = sources.source_code
      and sources.source_table_name is not null
      and sources.source_table_name not in
          (select fatab2.column_value
             from TABLE(CAST(p_known_tables AS fa_char30_tbl_type)) fatab2)
   union
   select distinct
          sources.source_code,
          sources.source_table_name,
          sources.source_column_name
     from xla_aad_sources aad,
          xla_sources_b   sources,
          TABLE(CAST(p_event_class_table AS fa_char30_tbl_type)) fatab
    where aad.application_id     = 140
      and sources.application_id = 140
      and aad.entity_code        = p_entity_code
      and aad.source_level_code  = p_source_level_code
      and aad.event_class_code   = fatab.column_value
      and aad.source_code        = sources.source_code
      and sources.source_table_name is not null
      and sources.source_table_name in
          (select fatab2.column_value
             from TABLE(CAST(p_known_tables AS fa_char30_tbl_type)) fatab2)
    order by 2,1;


 cursor c_sources_mls (p_entity_code        VARCHAR2,
                       p_source_level_code  VARCHAR2,
                       p_event_class_table  fa_char30_tbl_type) is
   select distinct
          sources.source_code,
          sources.source_table_name,
          sources.source_column_name
     from xla_aad_sources aad,
          xla_sources_b   sources,
          TABLE(CAST(p_event_class_table AS fa_char30_tbl_type)) fatab
    where aad.application_id     = 140
      and sources.application_id = 140
      and aad.entity_code        = p_entity_code
      and aad.source_level_code  = p_source_level_code
      and aad.event_class_code   = fatab.column_value
      and aad.source_code        = sources.source_code
      and sources.source_table_name   in ('FA_ADDITIONS_TL', 'FA_CATEGORIES_TL')
    order by 2,1;

   l_insert    varchar2(32000);
   l_select    varchar2(32000);
   l_from      varchar2(32000);
   l_where     varchar2(32000);

   l_rowcount_debug varchar2(32000);

   -- fetching sources
   l_source_code  v30_tbl;
   l_table_name   v30_tbl;
   l_column_name  v30_tbl;
   l_alias        v30_tbl;

   -- uses to fetch known tables / sources
   l_table_known  v30_tbl;
   l_alias_known  v30_tbl;

   -- used to set to the global constants from initialization
   l_known_tables      fa_char30_tbl_type;
   l_entity_code       varchar2(30);
   l_event_class_table fa_char30_tbl_type;

   l_level        varchar2(30);
   l_found        boolean := false;
   l_loop_total   number := 1;
   l_loop_index   number := 1;
   l_count        number;
   l_count2       number;
   l_index        number;

   l_add_tl_in_use boolean := FALSE;

   l_array_pkg              DBMS_SQL.VARCHAR2S;
   l_BodyPkg                VARCHAR2(32000);
   l_array_body             DBMS_SQL.VARCHAR2S;
   l_procedure_name         varchar2(80) := 'GenerateSourcesExtract';

   invalid_mode    EXCEPTION;
   table_not_found EXCEPTION;

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   l_array_body    := fa_cmp_string_pkg.g_null_varchar2s;
   l_array_pkg     := fa_cmp_string_pkg.g_null_varchar2s;

   l_known_tables      := fa_char30_tbl_type();
   l_event_class_table := fa_char30_tbl_type();


   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'p_extract_type: ' || p_extract_type);
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'p_level: ' || p_level);
   END IF;


   if (not g_initialized) then
      initialize;
   end if;

   -- load known tables and columns
   if (p_level = 'HEADER') then

      l_loop_total := 1;
      l_level := 'HEADER';
      l_rowcount_debug := replace(c_rowcount_debug, 'lines' ,'headers');

      l_insert := c_hdr_insert;
      l_select := c_hdr_select;
      l_from   := c_hdr_from;

      if (p_extract_type = 'DEF') then
         l_select := l_select || c_hdr_select1;
      else
         l_select := l_select || c_hdr_select2;
      end if;

      -- FYI: deprn and deferred do not need additional joins
      if (p_extract_type = 'DEPRN') then
         l_where := c_hdr_where_deprn;

         l_entity_code        := 'DEPRECIATION';
         l_known_tables       := G_known_deprn_hdr_tables;
         l_event_class_table  := G_deprn_event_class_table;

      elsif (p_extract_type = 'DEF') then
         l_where := c_hdr_where_def;

         l_entity_code        := 'DEFERRED_DEPRECIATION';
         l_known_tables       := G_known_def_hdr_tables;
         l_event_class_table  := G_def_event_class_table;

      elsif (p_extract_type = 'TRX1') then
         l_where := c_hdr_where_trx;
         l_from  := l_from || ',' || fa_cmp_string_pkg.g_chr_newline ||
                                    '           FA_TRANSACTION_HEADERS th ';

         l_entity_code        := 'TRANSACTIONS';
         l_known_tables       := G_known_trx_hdr_tables;
         l_event_class_table  := G_trx1_hdr_event_class_table;

      elsif (p_extract_type = 'TRX2') then
         l_where := c_hdr_where_itrx;
         l_from  := l_from || ', ' || fa_cmp_string_pkg.g_chr_newline ||
                                    '           FA_TRX_REFERENCES trx ' ;

         l_entity_code        := 'INTER_ASSET_TRANSACTIONS';
         l_known_tables       := G_known_trx_hdr_tables;
         l_event_class_table  := G_trx2_hdr_event_class_table;

      else
         raise invalid_mode;
      end if;

   elsif (p_level = 'LINE') then

      l_loop_total := 2;
      l_level := 'LINE';
      l_rowcount_debug := c_rowcount_debug;

      if (p_extract_type = 'DEPRN') then
         l_insert := c_line_insert_deprn;
         l_select := c_line_select_deprn;
         l_from   := c_line_from_deprn;
         l_where  := c_line_where_deprn;

         l_select := replace(l_select, 'select ' ,
                     'select /*+ ordered use_hash(CB,BC,LE) swap_join_inputs(CB)  swap_join_inputs(BC) swap_join_inputs(LE) */ ');

         l_entity_code        := 'DEPRECIATION';
         l_known_tables       := G_known_deprn_line_tables;
         l_event_class_table  := G_deprn_event_class_table;

      elsif (p_extract_type = 'DEF') then

         l_insert := c_line_insert_def;
         l_select := c_line_select_def;
         l_from   := c_line_from_def;
         l_where  := c_line_where_def;

         l_entity_code        := 'DEFERRED_DEPRECIATION';
         l_known_tables       := G_known_def_line_tables;
         l_event_class_table  := G_def_event_class_table;

      elsif (p_extract_type  in ('FIN1','FIN2','XFR','DIST1','DIST2','RET','RES')) then

         l_insert := c_line_insert_trx;

         -- BUG# 7693865
         if (p_extract_type = 'DIST1') then
            l_select := c_line_select_trx_dist1;
         else
            l_select := c_line_select_trx;
         end if;

         l_from   := c_line_from_trx;
         l_where  := c_line_where_trx;

         -- NOTE: constants for from clause already include the proceeding comma!!!

         if (p_extract_type = 'FIN1') then
            l_select := l_select || c_line_adj_amt_fin1;
            l_where  := l_where  || c_line_where_trx_fin1;

            l_entity_code        := 'TRANSACTIONS';
            l_known_tables       := G_known_fin1_line_tables;
            l_event_class_table  := G_fin1_line_event_class_table;

         elsif (p_extract_type = 'FIN2') then
            l_select := l_select || c_line_adj_amt_fin2;
            l_where  := l_where  || c_line_where_trx_fin2;

            l_entity_code        := 'INTER_ASSET_TRANSACTIONS';
            l_known_tables       := G_known_fin2_line_tables;
            l_event_class_table  := G_fin2_line_event_class_table;

         elsif (p_extract_type = 'XFR') then
            l_select := l_select || c_line_adj_amt_xfr;
            l_where  := l_where || c_line_where_trx_xfr;

            l_entity_code        := 'TRANSACTIONS';
            l_known_tables       := G_known_xfr_line_tables;
            l_event_class_table  := G_xfr_line_event_class_table;

         elsif (p_extract_type = 'DIST1') then
            l_select := l_select || c_line_adj_amt_dist1;
            l_from   := l_from   || c_line_from_trx_dist1;
            l_where  := l_where  || c_line_where_trx_dist1;

            l_entity_code        := 'TRANSACTIONS';
            l_known_tables       := G_known_dist1_line_tables;
            l_event_class_table  := G_dist_line_event_class_table;

         elsif (p_extract_type = 'DIST2') then
            l_select := l_select || c_line_adj_amt_dist2;
            l_where  := l_where  || c_line_where_trx_dist2;

            l_entity_code        := 'TRANSACTIONS';
            l_known_tables       := G_known_dist2_line_tables;
            l_event_class_table  := G_dist_line_event_class_table;

         elsif (p_extract_type = 'RET') then
            l_select := l_select || c_line_adj_amt_ret;
            l_from  := l_from    || c_line_from_trx_ret;
            l_where := l_where   || c_line_where_trx_ret;

            l_entity_code        := 'TRANSACTIONS';
            l_known_tables       := G_known_ret_line_tables;
            l_event_class_table  := G_ret_line_event_class_table;

         elsif (p_extract_type = 'RES') then
            l_select := l_select || c_line_adj_amt_ret;
            l_from  := l_from    || c_line_from_trx_ret;
            l_where := l_where   || c_line_where_trx_res;

            l_entity_code        := 'TRANSACTIONS';
            l_known_tables       := G_known_ret_line_tables;
            l_event_class_table  := G_ret_line_event_class_table;
         else
            raise invalid_mode;
         end if;

         -- perf to insure we lead by gt and use adj_u1,
         -- add hint where appropriate
         l_select := replace(l_select, 'select ' ,
                     'select /*+ leading(stg) index(adj, FA_ADJUSTMENTS_U1) */ ');
      else
         raise invalid_mode;
      end if;

   elsif (p_level = 'STG') then

      l_level  := 'LINE';
      l_rowcount_debug := replace(c_rowcount_debug, 'lines' ,'staging lines');

      l_insert := c_line_insert_stg;
      l_select := c_line_select_stg;

      if (p_extract_type = 'TRX1') then

         l_loop_total := 2;

         l_from   := c_line_from_stg1;
         l_where  := c_line_where_stg1;

         l_entity_code        := 'TRANSACTIONS';
         l_known_tables       := G_known_stg_tables;
         l_event_class_table  := G_trx1_hdr_event_class_table;

      elsif (p_extract_type = 'TRX2') then

         l_loop_total := 4;

         l_from   := c_line_from_stg2;
         l_where  := c_line_where_stg2;

         l_entity_code        := 'INTER_ASSET_TRANSACTIONS';
         l_known_tables       := G_known_stg_tables;
         l_event_class_table  := G_trx2_hdr_event_class_table;

      else
         raise invalid_mode;
      end if;

   elsif (p_level = 'MLS') then

      l_loop_total := 1;
      l_level  := 'LINE_MLS';
      l_rowcount_debug := replace(c_rowcount_debug, 'lines' ,'MLS lines');

      l_insert := c_mls_insert;
      l_select := c_mls_select;
      l_from   := c_mls_from;
      l_where  := '';

      if (p_extract_type = 'DEPRN') then
         l_entity_code        := 'DEPRECIATION';
         l_known_tables       := G_known_mls_tables;
         l_event_class_table  := G_deprn_event_class_table;

      elsif (p_extract_type = 'DEF') then
         l_entity_code        := 'DEFERRED_DEPRECIATION';
         l_known_tables       := G_known_mls_tables;
         l_event_class_table  := G_def_event_class_table;

      elsif (p_extract_type = 'TRX') then
         l_entity_code        := 'TRANSACTIONS';
         l_known_tables       := G_known_mls_tables;
         l_event_class_table  := G_trx_mls_event_class_table;
      else
         raise invalid_mode;
      end if;
   else
      raise invalid_mode;
   end if;



   -- determine known tables - this will return all known tables we can handle
   -- across event classes so if an invalid one is used, we will trap later...
   open c_tables (p_tables => l_known_tables,
                  p_schemas => G_known_schemas);
   fetch c_tables bulk collect
    into l_table_known,
         l_alias_known;
   close c_tables;


   -- fetch the sources actually used
   if ((l_entity_code = 'TRANSACTIONS' or
        l_entity_code = 'INTER_ASSET_TRANSACTIONS') and
       p_level = 'LINE') then

      open c_sources_trx (p_entity_code        => l_entity_code,
                          p_source_level_code  => l_level,
                          p_event_class_table  => l_event_class_table,
                          p_known_tables       => l_known_tables);
      fetch c_sources_trx bulk collect
       into l_source_code,
            l_table_name,
            l_column_name;
      close c_sources_trx;
   elsif ((l_entity_code = 'TRANSACTIONS' or
           l_entity_code = 'INTER_ASSET_TRANSACTIONS') and
          p_level = 'STG') then

      open c_sources_stg (p_entity_code        => l_entity_code,
                          p_source_level_code  => l_level,
                          p_event_class_table  => l_event_class_table,
                          p_known_tables       => l_known_tables);
      fetch c_sources_stg bulk collect
       into l_source_code,
            l_table_name,
            l_column_name;
      close c_sources_stg;

   elsif (p_level = 'MLS') then

      open c_sources_mls (p_entity_code        => l_entity_code,
                          p_source_level_code  => l_level,
                          p_event_class_table  => l_event_class_table );
      fetch c_sources_mls bulk collect
       into l_source_code,
            l_table_name,
            l_column_name;
      close c_sources_mls;

      -- for mls, if neither table is in use, return a dummy line to the calling code
      if (l_source_code.count = 0) then

         l_bodypkg := '     return;   ';

         fa_cmp_string_pkg.CreateString
             (p_package_text  => l_BodyPkg
             ,p_array_string  => l_array_pkg);

         p_package_body := l_array_pkg;

         return true;
      end if;
   else
      open c_sources (p_entity_code        => l_entity_code,
                      p_source_level_code  => l_level,
                      p_event_class_table  => l_event_class_table );
      fetch c_sources bulk collect
       into l_source_code,
            l_table_name,
            l_column_name;
      close c_sources;
   end if;


   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'l_source_code.count: ' || to_char(l_source_code.count));
   END IF;

   -- remove all sources already in the base statements
   l_count  := 0;
   l_count2 := l_source_code.count;
   l_index  := 1;

   for i in 1..l_count2 loop

      if (instr(upper(l_insert), ' ' || l_source_code(l_index) || ' ') > 0) then   -- BUG# 6779783
         delete_table_member(l_source_code, l_index);
         delete_table_member(l_column_name, l_index);
         delete_table_member(l_table_name,  l_index);
         l_count := l_count + 1;
      else
         l_index := l_index + 1;
      end if;

   end loop;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'l_source_code.count after deletion: ' || to_char(l_source_code.count));
   END IF;

   -- build the alias column array and insure validity
   for i in 1..l_table_name.count loop

      l_found := false;

      for x in 1..l_table_known.count loop
         if (l_table_known(x) = l_table_name(i)) then
            if (l_table_name(i) <> 'INVALID') then
               l_alias(i) := l_alias_known(x);
               l_found    := true;
            end if;
         end if;
      end loop;

      -- if no match found - problem!!!
      if (not l_found) then

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            fnd_log.string(G_LEVEL_STATEMENT,
                           G_MODULE_NAME||l_procedure_name,
                           'no match: l_table_name(i): ' || l_table_name(i) );
            fnd_log.string(G_LEVEL_STATEMENT,
                           G_MODULE_NAME||l_procedure_name,
                           'no match: l_source_code(i): ' || l_source_code(i) );
         END IF;

         raise table_not_found;
      end if;

   end loop;

   -- build the insert/select clause by appending new aliases/columns

   for i in 1..l_source_code.count loop
      l_insert := l_insert || ',' || fa_cmp_string_pkg.g_chr_newline  || '           ' || l_source_code(i);
      l_select := l_select || ',' || fa_cmp_string_pkg.g_chr_newline  || '           ' || l_alias(i)  || '.' || l_column_name(i) ;
   end loop;

   -- only line level can increase the from/to...
   -- for transactions where we break into staging vs lines,
   -- the local variable for known_table already is restricted to tables we can handle
   -- so any violation would have been caught above - no further breakdown needed

   if (p_level <> 'HEADER') then

      -- find distinct alias/tables for adding to from / where clause
      for i in 1..l_table_name.count loop
         l_found := false;

         -- first look in the existing from clause to see if table is being selected
         -- we previously set all the aliases and checked to insure the table names are valid
         --
         -- note that we need to verify validity here...   across not only
         -- event classes, but also within transactions across staging vs lines object!!!!
         -- finally, if we add to staging, we must by nature add the columns to lines too

         if (instr(upper(l_from),l_table_name(i))) = 0 then

            l_from  := l_from  || ', ' || fa_cmp_string_pkg.g_chr_newline || '           ' || l_table_name(i) || ' ' || l_alias(i);

            if (l_table_name(i) = 'FA_ASSET_KEYWORDS') then
               l_where := l_where || fa_cmp_string_pkg.g_chr_newline ||  '      ' ||
                                     ' AND ad.asset_key_ccid           = key.code_combination_id(+) ';
            elsif (l_table_name(i) = 'FA_ASSET_INVOICES') then
               l_where := l_where || fa_cmp_string_pkg.g_chr_newline ||  '      ' ||
                                     ' AND adj.source_line_id          = ai.source_line_id(+) ';
            elsif (l_table_name(i) = 'FA_CATEGORIES_B') then
               l_where := l_where || fa_cmp_string_pkg.g_chr_newline ||  '      ' ||
                                     ' AND cat.category_id             = ah.category_id ';
            elsif (l_table_name(i) = 'FA_LEASES') then
               l_where := l_where || fa_cmp_string_pkg.g_chr_newline ||  '      ' ||
                                     ' AND ad.lease_id                 = ls.lease_id(+) ';
            elsif (l_table_name(i) = 'FA_LOCATIONS') then
               l_where := l_where || fa_cmp_string_pkg.g_chr_newline ||  '      ' ||
                                     ' AND dh.location_id              = loc.location_id ';
            elsif (l_table_name(i) = 'FA_METHODS') then
               l_where := l_where || fa_cmp_string_pkg.g_chr_newline ||  '      ' ||
                                     ' AND mt.method_code              = bk.deprn_method_code ';
            elsif  (l_table_name(i) = 'FA_BOOKS') then
               if (p_extract_type = 'DEPRN') then
                  l_where := l_where || fa_cmp_string_pkg.g_chr_newline                      ||  '      ' ||
                                     ' AND bk.asset_id                 = dd.asset_id       ' ||  '      ' ||
                                     ' AND bk.book_type_code           = dd.book_type_code ' ||  '      ' ||
                                     ' AND nvl(dp.period_close_date, sysdate)  between bk.date_effective and ' ||  '      ' ||
                                     '     nvl(bk.date_ineffective, sysdate) ';
               elsif (p_extract_type = 'TRX') then
                  l_where := l_where || fa_cmp_string_pkg.g_chr_newline                      ||  '      ' ||
                                     ' AND bk.asset_id                 = th.asset_id       ' ||  '      ' ||
                                     ' AND bk.book_type_code           = th.book_type_code ' ||  '      ' ||
                                     ' AND nvl(dp.period_close_date, sysdate)  between bk.date_effective and ' ||  '      ' ||
                                     '     nvl(bk.date_ineffective, sysdate) ';
               else -- deferred
                  l_where := l_where || fa_cmp_string_pkg.g_chr_newline                      ||  '      ' ||
                                     ' AND bk.asset_id                 = df.asset_id'        ||  '      ' ||
                                     ' AND bk.book_type_code           = df.book_type_code'  ||  '      ' ||
                                     ' AND nvl(dp.period_close_date, sysdate)  between bk.date_effective and'  ||  '      ' ||
                                     '     nvl(bk.date_ineffective, sysdate) ';

               end if;
            elsif  (l_table_name(i) = 'FA_DEPRN_SUMMARY') then
               if (p_extract_type  = 'DEPRN') then
                  l_where := l_where || fa_cmp_string_pkg.g_chr_newline                           ||  '      ' ||
                                     ' AND ds.asset_id                 = ctlgd.source_id_int_1  ' ||  '      ' ||
                                     ' AND ds.book_type_code           = ctlgd.source_id_char_1 ' ||  '      ' ||
                                     ' AND ds.period_counter           = ctlgd.source_id_int_2  ' ||  '      ' ||
                                     ' AND ds.deprn_run_id             = ctlgd.source_id_int_3 ';

               else
                  raise table_not_found;
               end if;
            elsif  (l_table_name(i) = 'FA_ADDITIONS_TL') then

                  l_insert := l_insert || ', LANGUAGE ';
                  l_select := l_select || ', adtl.language ';
                  l_where := l_where || fa_cmp_string_pkg.g_chr_newline                           ||  '      ' ||
                                     ' WHERE adtl.asset_id                 = xl.asset_id '        ||  '      ' ||
                                     ' AND xl.distribution_type_code       = ''' || p_extract_type || ''' ';
                  l_add_tl_in_use := TRUE;
            elsif  (l_table_name(i) = 'FA_CATEGORIES_TL') then

                  l_where := l_where || fa_cmp_string_pkg.g_chr_newline                           ||  '    ' ||
                                     ' WHERE cattl.category_id             = xl.cat_id ';
                  if (l_add_tl_in_use) then
                     l_where := l_where || fa_cmp_string_pkg.g_chr_newline                        ||  '      ' ||
                                        ' AND cattl.language                = adtl.language ';
                     l_where := replace(l_where, 'WHERE cattl',   'AND cattl');

                  else
                     l_where := l_where || fa_cmp_string_pkg.g_chr_newline                        ||  '      ' ||
                                        ' AND xl.distribution_type_code       = ''' || p_extract_type || ''' '; -- bug 8580251
                     l_insert := l_insert || ', LANGUAGE ';
                     l_select := l_select || ', cattl.language ';

                  end if;
            end if;
         end if;
      end loop;
   end if;


   -- loop (if applicable) for generating both the primary and the reporting statements
   -- we only loop for lines (hdr/stg are single)
   -- bug 8415466 - fyi: we now loop for staging too

   if (p_level = 'STG') then
      g_select := l_select;
      g_where  := l_where;
      g_rowcount_debug := l_rowcount_debug;
   end if;

   for l_loop_index in 1..l_loop_total loop

       -- for trx and inter, handle the thid vs member_thid and source vs dest
       if (p_level = 'STG') then

          if    (l_loop_index = 1 and p_extract_type  = 'TRX1') then
             l_select := replace(g_select, 'select ' ,
                     'select /*+ leading(ctgld) index(th, FA_TRANSACTION_HEADERS_U1) */ ');
             l_where :=  g_where || c_line_where_stg1a;
             l_rowcount_debug := replace(g_rowcount_debug, 'lines', 'main lines');
          elsif (l_loop_index = 2 and p_extract_type  = 'TRX1') then
             l_select := replace(g_select, 'select ' ,
                     'select /*+ leading(ctgld) index(th, FA_TRANSACTION_HEADERS_N7) */ ');
             l_where :=  g_where || c_line_where_stg1b;
             l_rowcount_debug := replace(g_rowcount_debug, 'lines', 'group lines');
          elsif (l_loop_index = 1 and p_extract_type  = 'TRX2') then
             l_select := replace(g_select, 'select ' ,
                     'select /*+ leading(ctgld) index(th, FA_TRANSACTION_HEADERS_U1) */ ');
             l_where :=  g_where || c_line_where_stg2a;
             l_rowcount_debug := replace(g_rowcount_debug, 'lines', 'src main lines');
          elsif (l_loop_index = 2 and p_extract_type  = 'TRX2') then
             l_select := replace(g_select, 'select ' ,
                     'select /*+ leading(ctgld) index(th, FA_TRANSACTION_HEADERS_N7) */ ');
             l_where :=  g_where || c_line_where_stg2b;
             l_rowcount_debug := replace(g_rowcount_debug, 'lines', 'src group lines');
          elsif (l_loop_index = 3 and p_extract_type  = 'TRX2') then
             l_select := replace(g_select, 'select ' ,
                     'select /*+ leading(ctgld) index(th, FA_TRANSACTION_HEADERS_U1) */ ');
             l_where :=  g_where || c_line_where_stg2c;
             l_rowcount_debug := replace(g_rowcount_debug, 'lines', 'dest main lines');
          elsif (l_loop_index = 4 and p_extract_type  = 'TRX2') then
             l_select := replace(g_select, 'select ' ,
                     'select /*+ leading(ctgld) index(th, FA_TRANSACTION_HEADERS_N7) */ ');
             l_where :=  g_where || c_line_where_stg2d;
             l_rowcount_debug := replace(g_rowcount_debug, 'lines', 'dest group lines');
          end if;

       -- for mrc insert the MC_ prefix

       elsif (l_loop_index = 2 and p_level = 'LINE') then

          -- alter index name to have MC
          l_select := replace(l_select, 'FA_ADJUSTMENTS_U1' ,
                                        'FA_MC_ADJUSTMENTS_U1') ;

          l_from := replace(l_from, 'fa_book_controls', 'fa_mc_book_controls');
          l_rowcount_debug := replace(l_rowcount_debug, 'lines', 'alc lines');

          if (p_extract_type = 'DEPRN') then
             l_from := replace(l_from, 'fa_deprn_summary',  'fa_mc_deprn_summary');
             l_from := replace(l_from, 'fa_deprn_detail',   'fa_mc_deprn_detail');

             l_where := l_where ||  fa_cmp_string_pkg.g_chr_newline ||
                          '       AND dd.set_of_books_id = bc.set_of_books_id';

             -- only apend the DS clause if it's used!!!!
             if (instr(l_from,'fa_mc_deprn_summary') > 0) then
                l_where := l_where || ' and ds.set_of_books_id = bc.set_of_books_id' || fa_cmp_string_pkg.g_chr_newline ;
             end if;
          elsif (p_extract_type = 'DEF') then
             l_from := replace(l_from, 'fa_deferred_deprn',  'fa_mc_deferred_deprn');

             l_where := l_where || fa_cmp_string_pkg.g_chr_newline  ||
                          '       AND df.set_of_books_id = bc.set_of_books_id';
          else
             if (instr(l_from,'fa_book_controls') = 0) then
                l_from  := l_from  || ', ' || fa_cmp_string_pkg.g_chr_newline || '           fa_mc_book_controls bc ';
                l_from  := l_from  || ', ' || fa_cmp_string_pkg.g_chr_newline || '           gl_ledgers le ';

                l_where := l_where || fa_cmp_string_pkg.g_chr_newline ||
                          '       AND bc.book_type_code  = stg.book_type_code ' || fa_cmp_string_pkg.g_chr_newline ||
                          '       AND bc.set_of_books_id = le.ledger_id ';

             end if;

             l_select := replace(l_select, 'stg.ledger_id',       'bc.set_of_books_id');
             l_select := replace(l_select, 'stg.currency_code',   'le.currency_code');

             l_from := replace(l_from, 'fa_adjustments',    'fa_mc_adjustments');

             -- Bug 5159010 changed fa_asset_invoices to upper case
             l_from := replace(l_from, 'FA_ASSET_INVOICES', 'fa_mc_asset_invoices');

             l_where := l_where || fa_cmp_string_pkg.g_chr_newline ||
                          '      AND adj.set_of_books_id = bc.set_of_books_id ' ;

             -- only apend the AI clause if it's used!!!!
             if (instr(l_from,'fa_mc_asset_invoices') > 0) then
                l_where := l_where || fa_cmp_string_pkg.g_chr_newline  ||
                          '      AND adj.set_of_books_id = ai.set_of_books_id(+) ' ;
             end if;

          end if;

       end if;

       -- concatonate all the clauses into a single statment
       l_bodypkg := l_insert || l_select || l_from || l_where || ';' || fa_cmp_string_pkg.g_chr_newline || l_rowcount_debug  || fa_cmp_string_pkg.g_chr_newline;


       -- add rowcount debug after the primary statement and before report select
       -- also add an if condition around the mrc so we don't needlessly execute statements when mrc is not enabled
       if (l_loop_index <> 1) then

          if (p_level = 'LINE') then
             l_bodypkg := c_mc_if_condition      || fa_cmp_string_pkg.g_chr_newline ||
                          l_bodypkg              || fa_cmp_string_pkg.g_chr_newline ||
                          '      end if; '       || fa_cmp_string_pkg.g_chr_newline ;
          end if;

          if (p_level = 'STG' and l_loop_index in (2,4)) then
             l_bodypkg := c_group_if_condition      || fa_cmp_string_pkg.g_chr_newline ||
                          l_bodypkg              || fa_cmp_string_pkg.g_chr_newline ||
                          '      end if; '       || fa_cmp_string_pkg.g_chr_newline ;
          end if;
       end if;

       -- build the package value to return

       if (l_loop_index = 1) then
          fa_cmp_string_pkg.CreateString
             (p_package_text  => l_BodyPkg
             ,p_array_string  => l_array_pkg);
       else
          fa_cmp_string_pkg.CreateString
             (p_package_text  => l_BodyPkg
             ,p_array_string  => l_array_body);

          l_array_pkg :=
             fa_cmp_string_pkg.ConcatTwoStrings
                (p_array_string_1  =>  l_array_pkg
                ,p_array_string_2  =>  l_array_body);
       end if;

   end loop;

   p_package_body := l_array_pkg;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                     'End of procedure');
   END IF;

   RETURN TRUE;

EXCEPTION

   WHEN invalid_mode THEN
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_log.string(G_LEVEL_STATEMENT,
                          G_MODULE_NAME||l_procedure_name,
                         'invalid mode');
        END IF;
        RETURN FALSE;

   WHEN table_not_found THEN
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_log.string(G_LEVEL_STATEMENT,
                          G_MODULE_NAME||l_procedure_name,
                          'table not found');
        END IF;
        RETURN FALSE;

   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        RETURN FALSE;

END GenerateSourcesExtract;

END fa_xla_cmp_sources_pkg;

/
