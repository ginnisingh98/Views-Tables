--------------------------------------------------------
--  DDL for Package Body FA_XLA_EXTRACT_DEPRN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_XLA_EXTRACT_DEPRN_PKG" AS

/*======================================================================+
|                Copyright (c) 1997 Oracle Corporation                  |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| Package Name                                                          |
|     FA_XLA_EXTRACT_DEPRN_PKG                                          |
|                                                                       |
| DESCRIPTION                                                           |
|     Package generated From FA AAD setups                              |
|                                                                       |
| HISTORY                                                               |
|     Generated at 16-06-2018 at 10:06:40 by user ANONYMOUS             |
+=======================================================================*/


-- TYPES
-- globals / constants

G_CURRENT_RUNTIME_LEVEL        NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

G_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
G_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
G_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
G_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

G_MODULE_NAME         CONSTANT VARCHAR2(50):= 'fa.plsql.fa_xla_extract_deprn_pkg.';


--+============================================+
--|                                            |
--|  PRIVATE  PROCEDURES/FUNCTIONS             |
--|                                            |
--+============================================+



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|    load_header_data                                                        |
|                                                                       |
+======================================================================*/

  PROCEDURE load_header_data IS

     l_procedure_name  varchar2(80) := 'load_header_data';

  BEGIN

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(G_LEVEL_PROCEDURE,
                       G_MODULE_NAME||l_procedure_name||'.begin',
                       'Beginning of procedure');
     END IF;


    insert into fa_xla_ext_headers_b_gt (
           event_id                                ,
           DEFAULT_CCID                            ,
           BOOK_TYPE_CODE                          ,
           PERIOD_NAME                             ,
           PERIOD_CLOSE_DATE                       ,
           PERIOD_COUNTER                          ,
           ACCOUNTING_DATE                         ,
           TRANSFER_TO_GL_FLAG                      )
    select ctlgd.event_id,
           bc.FLEXBUILDER_DEFAULTS_CCID            ,
           bc.book_type_code                       ,
           dp.PERIOD_NAME                          ,
           dp.CALENDAR_PERIOD_CLOSE_DATE           ,
           dp.PERIOD_COUNTER                       ,
           ctlgd.event_date                        ,
           decode(bc.GL_POSTING_ALLOWED_FLAG       ,
                 'YES', 'Y','N')         
      FROM xla_events_gt                 ctlgd,
           fa_deprn_periods              dp,
           fa_book_controls              bc 
     WHERE ctlgd.entity_code         = 'DEPRECIATION'
       AND ctlgd.event_type_code     = 'DEPRECIATION'
       AND dp.book_type_code         = ctlgd.source_id_char_1
       AND dp.period_counter         = ctlgd.source_id_int_2
       AND bc.book_type_code         = ctlgd.source_id_char_1;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name,
                        'Rows inserted into headers: ' || to_char(SQL%ROWCOUNT));
      END IF;




      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name||'.end',
                        'End of procedure');
      END IF;

   EXCEPTION
      WHEN others THEN
           IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
              fnd_message.set_token('ORACLE_ERR',SQLERRM);
              FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
           END IF;
           raise;

   end load_header_data;



  PROCEDURE Load_header_data_rb IS

     l_procedure_name  varchar2(80) := 'load_header_data_rb';

  BEGIN

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(G_LEVEL_PROCEDURE,
                       G_MODULE_NAME||l_procedure_name||'.begin',
                       'Beginning of procedure');
     END IF;

     INSERT INTO FA_XLA_EXT_HEADERS_B_GT (
          event_id                                ,
          period_close_date                       ,
          reversal_flag                           ,
          transfer_to_gl_flag                     ,
          accounting_date                         )
    SELECT ctlgd.event_id                         ,
           dp.CALENDAR_PERIOD_CLOSE_DATE          ,
           'Y'                                  ,
           decode(bc.GL_POSTING_ALLOWED_FLAG      ,
                 'YES', 'Y',
                 'N'),
           dp.CALENDAR_PERIOD_CLOSE_DATE
      FROM xla_events_gt                 ctlgd,
           fa_book_controls              bc,
           fa_deprn_periods              dp,
           fa_deprn_events               ds
     WHERE ctlgd.entity_code         = 'DEPRECIATION'
       AND ctlgd.event_type_code     = 'ROLLBACK_DEPRECIATION'
       AND ds.asset_id               = ctlgd.source_id_int_1
       AND ds.book_type_code         = ctlgd.source_id_char_1
       AND ds.period_counter         = ctlgd.source_id_int_2
       AND ds.deprn_run_id           = ctlgd.source_id_int_3
       AND bc.book_type_code         = ctlgd.source_id_char_1
--       AND ds.book_type_code         = ctlgd.valuation_method
       AND ds.reversal_event_id      = ctlgd.event_id
       AND dp.book_type_code         = ds.book_type_code
       AND dp.period_counter         = ds.period_counter;


      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name||'.end',
                        'End of procedure');
      END IF;

   EXCEPTION
      WHEN others THEN
           IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
              fnd_message.set_token('ORACLE_ERR',SQLERRM);
              FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
           END IF;
           raise;

  END Load_header_data_rb ;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|    load_line_data                                                        |
|                                                                       |
+======================================================================*/

  PROCEDURE load_line_data IS

     l_procedure_name  varchar2(80) := 'load_line_data';

  BEGIN

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(G_LEVEL_PROCEDURE,
                       G_MODULE_NAME||l_procedure_name||'.begin',
                       'Beginning of procedure');
     END IF;


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
           PERIOD_COUNTER                       ,
           ASSET_ID,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           DEPRN_RESERVE_ACCT,
           REVAL_AMORT_ACCT,
           REVAL_RESERVE_ACCT,
           DEPRN_RUN_ID,
           EXPENSE_ACCOUNT_CCID )
    select /*+ ordered use_hash(CB,BC,LE) swap_join_inputs(CB)  swap_join_inputs(BC) swap_join_inputs(LE) */ ctlgd.EVENT_ID                            ,
           dd.distribution_id                        as distribution_id,
           dd.distribution_id                        as dist_id,
           'DEPRN'                                 ,
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
           dp.period_counter                         ,
           ad.ASSET_ID,
           cb.BONUS_DEPRN_EXPENSE_ACCT,
           cb.BONUS_DEPRN_RESERVE_ACCT,
           cb.DEPRN_RESERVE_ACCT,
           cb.REVAL_AMORTIZATION_ACCT,
           cb.REVAL_RESERVE_ACCT,
           dd.DEPRN_RUN_ID,
           dh.CODE_COMBINATION_ID
      from xla_events_gt             ctlgd,
           fa_deprn_detail           dd,
           fa_distribution_history   dh,
           fa_additions_b            ad,
           fa_asset_history          ah,
           fa_category_books         cb,
           fa_book_controls          bc,
           gl_ledgers                le,
           fa_deprn_periods          dp 
     where ctlgd.entity_code           = 'DEPRECIATION'
       AND ctlgd.event_type_code       = 'DEPRECIATION'
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
       AND ah.asset_type              in ('CAPITALIZED', 'GROUP')
       AND ad.asset_type              in ('CAPITALIZED', 'GROUP')
       AND bc.book_type_code           = ctlgd.source_id_char_1
       AND le.ledger_id                = bc.set_of_books_id
       AND dp.book_type_code           = ctlgd.source_id_char_1
       AND dp.period_counter           = ctlgd.source_id_int_2 ;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name,
                        'Rows inserted into lines: ' || to_char(SQL%ROWCOUNT));
      END IF;



      if (fa_xla_extract_util_pkg.G_alc_enabled) then



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
           PERIOD_COUNTER                       ,
           ASSET_ID,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           DEPRN_RESERVE_ACCT,
           REVAL_AMORT_ACCT,
           REVAL_RESERVE_ACCT,
           DEPRN_RUN_ID,
           EXPENSE_ACCOUNT_CCID )
    select /*+ ordered use_hash(CB,BC,LE) swap_join_inputs(CB)  swap_join_inputs(BC) swap_join_inputs(LE) */ ctlgd.EVENT_ID                            ,
           dd.distribution_id                        as distribution_id,
           dd.distribution_id                        as dist_id,
           'DEPRN'                                 ,
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
           dp.period_counter                         ,
           ad.ASSET_ID,
           cb.BONUS_DEPRN_EXPENSE_ACCT,
           cb.BONUS_DEPRN_RESERVE_ACCT,
           cb.DEPRN_RESERVE_ACCT,
           cb.REVAL_AMORTIZATION_ACCT,
           cb.REVAL_RESERVE_ACCT,
           dd.DEPRN_RUN_ID,
           dh.CODE_COMBINATION_ID
      from xla_events_gt             ctlgd,
           fa_mc_deprn_detail           dd,
           fa_distribution_history   dh,
           fa_additions_b            ad,
           fa_asset_history          ah,
           fa_category_books         cb,
           fa_mc_book_controls          bc,
           gl_ledgers                le,
           fa_deprn_periods          dp 
     where ctlgd.entity_code           = 'DEPRECIATION'
       AND ctlgd.event_type_code       = 'DEPRECIATION'
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
       AND ah.asset_type              in ('CAPITALIZED', 'GROUP')
       AND ad.asset_type              in ('CAPITALIZED', 'GROUP')
       AND bc.book_type_code           = ctlgd.source_id_char_1
       AND le.ledger_id                = bc.set_of_books_id
       AND dp.book_type_code           = ctlgd.source_id_char_1
       AND dp.period_counter           = ctlgd.source_id_int_2 
       AND dd.set_of_books_id = bc.set_of_books_id;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name,
                        'Rows inserted into alc lines: ' || to_char(SQL%ROWCOUNT));
      END IF;



      end if; 


      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name||'.end',
                        'End of procedure');
      END IF;

   EXCEPTION
      WHEN others THEN
           IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
              fnd_message.set_token('ORACLE_ERR',SQLERRM);
              FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
           END IF;
           raise;

   end load_line_data;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|    load_mls_data                                                        |
|                                                                       |
+======================================================================*/

  PROCEDURE load_mls_data IS

     l_procedure_name  varchar2(80) := 'load_mls_data';

  BEGIN

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(G_LEVEL_PROCEDURE,
                       G_MODULE_NAME||l_procedure_name||'.begin',
                       'Beginning of procedure');
     END IF;

     return;   

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(G_LEVEL_PROCEDURE,
                       G_MODULE_NAME||l_procedure_name,
                       'Rows inserted into mls: ' || to_char(SQL%ROWCOUNT));
     END IF;



      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name||'.end',
                        'End of procedure');
      END IF;

   EXCEPTION
      WHEN others THEN
           IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
              fnd_message.set_token('ORACLE_ERR',SQLERRM);
              FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
           END IF;
           raise;

   end load_mls_data;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|    Load_Generated_Ccids                                               |
|                                                                       |
+======================================================================*/

 ----------------------------------------------------
  --
  --  Account Generator Hook
  --
  ----------------------------------------------------
   PROCEDURE Load_Generated_Ccids
              (p_log_level_rec IN FA_API_TYPES.log_level_rec_type) IS

      l_mesg_count               number := 0;
      l_mesg_len                 number;
      l_mesg                     varchar2(4000);

      l_procedure_name  varchar2(80) := 'fa_xla_extract_def_pkg.load_generated_ccids';   -- BMR make this dynamic on type

      type char_tab_type is table of varchar2(64) index by binary_integer;
      type num_tab_type  is table of number       index by binary_integer;




      type deprn_rec_type is record
        (rowid                       VARCHAR2(64),
         book_type_code              VARCHAR2(30),
         distribution_id             NUMBER(15),
         distribution_ccid           NUMBER(15),
         deprn_entered_amount        NUMBER,
         bonus_entered_amount        NUMBER,
         reval_entered_amount        NUMBER,
         generated_ccid              NUMBER(15),
         generated_offset_ccid       NUMBER(15),
         bonus_generated_ccid        NUMBER(15),
         bonus_generated_offset_ccid NUMBER(15),
         reval_generated_ccid        NUMBER(15),
         reval_generated_offset_ccid NUMBER(15),
         capital_adj_generated_ccid  NUMBER(15),
         general_fund_generated_ccid NUMBER(15),
         -- DEPRN_EXPENSE_ACCOUNT_CCID  NUMBER(15),
         DEPRN_RESERVE_ACCOUNT_CCID  NUMBER(15),
         --BONUS_EXP_ACCOUNT_CCID      NUMBER(15),
         BONUS_RSV_ACCOUNT_CCID      NUMBER(15),
         REVAL_AMORT_ACCOUNT_CCID    NUMBER(15),
         REVAL_RSV_ACCOUNT_CCID      NUMBER(15),
         CAPITAL_ADJ_ACCOUNT_CCID    NUMBER(15),
         GENERAL_FUND_ACCOUNT_CCID   NUMBER(15),
         DEPRN_EXPENSE_ACCT          VARCHAR2(25),
         DEPRN_RESERVE_ACCT          VARCHAR2(25),
         BONUS_DEPRN_EXPENSE_ACCT    VARCHAR2(25),
         BONUS_RESERVE_ACCT          VARCHAR2(25),
         REVAL_AMORT_ACCT            VARCHAR2(25),
         REVAL_RESERVE_ACCT          VARCHAR2(25),
         CAPITAL_ADJ_ACCT            VARCHAR2(25),
         GENERAL_FUND_ACCT           VARCHAR2(25)
        );

      type deprn_tbl_type is table of deprn_rec_type index by binary_integer;

      l_deprn_tbl deprn_tbl_type;

      l_generated_ccid              num_tab_type;
      l_generated_offset_ccid       num_tab_type;
      l_bonus_generated_ccid        num_tab_type;
      l_bonus_generated_offset_ccid num_tab_type;
      l_reval_generated_ccid        num_tab_type;
      l_reval_generated_offset_ccid num_tab_type;
      l_capital_adj_generated_ccid  num_tab_type;
      l_general_fund_generated_ccid num_tab_type;
      l_rowid                       char_tab_type;

      l_last_book    varchar2(30) := ' ';

      cursor c_deprn is
      select /*+ leading(xg) index(xb, FA_XLA_EXT_HEADERS_B_GT_U1) index(xl, FA_XLA_EXT_LINES_B_GT_U1) */
             xl.rowid,
             xb.book_type_code,
             xl.distribution_id,
             xl.EXPENSE_ACCOUNT_CCID,
             xl.entered_amount,
             xl.bonus_entered_amount,
             xl.reval_entered_amount,
             nvl(xl.GENERATED_CCID,              da.DEPRN_EXPENSE_ACCOUNT_CCID),
             nvl(xl.GENERATED_OFFSET_CCID,       da.DEPRN_RESERVE_ACCOUNT_CCID),
             nvl(xl.BONUS_GENERATED_CCID,        da.BONUS_EXP_ACCOUNT_CCID),
             nvl(xl.BONUS_GENERATED_OFFSET_CCID, da.BONUS_RSV_ACCOUNT_CCID),
             nvl(xl.REVAL_GENERATED_CCID,        da.REVAL_AMORT_ACCOUNT_CCID),
             nvl(xl.REVAL_GENERATED_OFFSET_CCID, da.REVAL_RSV_ACCOUNT_CCID),
             da.CAPITAL_ADJ_ACCOUNT_CCID,
             da.GENERAL_FUND_ACCOUNT_CCID,
    --       xl.DEPRN_EXPENSE_ACCOUNT_CCID,
             xl.RESERVE_ACCOUNT_CCID,
    --       xl.BONUS_EXP_ACCOUNT_CCID,
             xl.BONUS_RESERVE_ACCT_CCID,
             xl.REVAL_AMORT_ACCOUNT_CCID,
             xl.REVAL_RESERVE_ACCOUNT_CCID,
             xl.CAPITAL_ADJ_ACCOUNT_CCID,
             xl.GENERAL_FUND_ACCOUNT_CCID,
             xl.deprn_expense_acct,
             xl.DEPRN_RESERVE_ACCT,
             xl.bonus_deprn_expense_acct,
             xl.BONUS_RESERVE_ACCT,
             xl.REVAL_AMORT_ACCT,
             xl.REVAL_RESERVE_ACCT,
             xl.CAPITAL_ADJ_ACCT,
             xl.GENERAL_FUND_ACCT
        from xla_events_gt            xg,
             fa_xla_ext_headers_b_gt  xb,
             fa_xla_ext_lines_b_gt    xl,
             fa_distribution_accounts da
       where xg.event_class_code = 'DEPRECIATION'
         and xb.event_id         = xg.event_id
         and xl.event_id         = xg.event_id
         and xl.distribution_id  = da.distribution_id(+)
         and xl.book_type_code   = da.book_type_code(+);


   BEGIN

      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name||'.begin',
                        'Beginning of procedure');
      END IF;

      open  c_deprn;
      fetch c_deprn bulk collect into l_deprn_tbl;
      close c_deprn;

      for i in 1..l_deprn_tbl.count loop

         if (l_last_book <> l_deprn_tbl(i).book_type_code or
             i = 1) then

            if not (fa_cache_pkg.fazcbc
                      (X_BOOK => l_deprn_tbl(i).book_type_code,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then
               null;

            end if;
            l_last_book := l_deprn_tbl(i).book_type_code;
         end if;


         -- call FAFBGCC if the ccid doesnt exist in distribution accounts

         if (l_deprn_tbl(i).generated_ccid is null and
             l_deprn_tbl(i).deprn_entered_amount   <> 0) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_deprn_tbl(i).book_type_code,
                       X_fn_trx_code     => 'DEPRN_EXPENSE_ACCT',
                       X_dist_ccid       => l_deprn_tbl(i).distribution_ccid,
                       X_acct_segval     => l_deprn_tbl(i).deprn_expense_acct,
                       X_account_ccid    => 0,
                       X_distribution_id => l_deprn_tbl(i).distribution_id,
                       X_rtn_ccid        => l_deprn_tbl(i).generated_ccid,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then
               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => 'FA_GET_ACCOUNT_CCID',
                   CALLING_FN => 'FA_INS_ADJUST_PKG.fadoflx',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_deprn_tbl(i).generated_ccid := -1;
            end if;
         end if;

         if (l_deprn_tbl(i).generated_offset_ccid is null and
             l_deprn_tbl(i).deprn_entered_amount <> 0) then


            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_deprn_tbl(i).book_type_code,
                       X_fn_trx_code     => 'DEPRN_RESERVE_ACCT',
                       X_dist_ccid       => l_deprn_tbl(i).distribution_ccid,
                       X_acct_segval     => l_deprn_tbl(i).deprn_reserve_acct,
                       X_account_ccid    => l_deprn_tbl(i).deprn_reserve_account_ccid,
                       X_distribution_id => l_deprn_tbl(i).distribution_id,
                       X_rtn_ccid        => l_deprn_tbl(i).generated_offset_ccid,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then

               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => 'FA_GET_ACCOUNT_CCID',
                   CALLING_FN => 'FA_INS_ADJUST_PKG.fadoflx',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_deprn_tbl(i).generated_offset_ccid := -1;
            end if;
         end if;

         if (l_deprn_tbl(i).bonus_generated_ccid is null and
             l_deprn_tbl(i).bonus_entered_amount <> 0) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_deprn_tbl(i).book_type_code,
                       X_fn_trx_code     => 'BONUS_DEPRN_EXPENSE_ACCT',
                       X_dist_ccid       => l_deprn_tbl(i).distribution_ccid,
                       X_acct_segval     => l_deprn_tbl(i).bonus_deprn_expense_acct,
                       X_account_ccid    => 0,
                       X_distribution_id => l_deprn_tbl(i).distribution_id,
                       X_rtn_ccid        => l_deprn_tbl(i).bonus_generated_ccid,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then
               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => 'FA_GET_ACCOUNT_CCID',
                   CALLING_FN => 'FA_INS_ADJUST_PKG.fadoflx',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_deprn_tbl(i).bonus_generated_ccid := -1;

            end if;
         end if;

         if (l_deprn_tbl(i).bonus_generated_offset_ccid is null and
             l_deprn_tbl(i).bonus_entered_amount <> 0) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_deprn_tbl(i).book_type_code,
                       X_fn_trx_code     => 'BONUS_DEPRN_RESERVE_ACCT',
                       X_dist_ccid       => l_deprn_tbl(i).distribution_ccid,
                       X_acct_segval     => l_deprn_tbl(i).bonus_reserve_acct,
                       X_account_ccid    => l_deprn_tbl(i).bonus_rsv_account_ccid,
                       X_distribution_id => l_deprn_tbl(i).distribution_id,
                       X_rtn_ccid        => l_deprn_tbl(i).bonus_generated_offset_ccid,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then
               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => 'FA_GET_ACCOUNT_CCID',
                   CALLING_FN => 'FA_INS_ADJUST_PKG.fadoflx',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_deprn_tbl(i).bonus_generated_offset_ccid := -1;

            end if;
         end if;


         if (l_deprn_tbl(i).reval_generated_ccid is null and
             l_deprn_tbl(i).reval_entered_amount <> 0) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_deprn_tbl(i).book_type_code,
                       X_fn_trx_code     => 'REVAL_AMORTIZATION_ACCT',
                       X_dist_ccid       => l_deprn_tbl(i).distribution_ccid,
                       X_acct_segval     => l_deprn_tbl(i).reval_amort_acct,
                       X_account_ccid    => l_deprn_tbl(i).reval_amort_account_ccid,
                       X_distribution_id => l_deprn_tbl(i).distribution_id,
                       X_rtn_ccid        => l_deprn_tbl(i).reval_generated_ccid,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then
               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => 'FA_GET_ACCOUNT_CCID',
                   CALLING_FN => 'FA_INS_ADJUST_PKG.fadoflx',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_deprn_tbl(i).reval_generated_ccid := -1;
            end if;
         end if;

         if (l_deprn_tbl(i).reval_generated_offset_ccid is null and
             l_deprn_tbl(i).reval_entered_amount <> 0) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_deprn_tbl(i).book_type_code,
                       X_fn_trx_code     => 'REVAL_RESERVE_ACCT',
                       X_dist_ccid       => l_deprn_tbl(i).distribution_ccid,
                       X_acct_segval     => l_deprn_tbl(i).reval_reserve_acct,
                       X_account_ccid    => l_deprn_tbl(i).reval_rsv_account_ccid,
                       X_distribution_id => l_deprn_tbl(i).distribution_id,
                       X_rtn_ccid        => l_deprn_tbl(i).reval_generated_offset_ccid,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then
               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => 'FA_GET_ACCOUNT_CCID',
                   CALLING_FN => 'FA_INS_ADJUST_PKG.fadoflx',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_deprn_tbl(i).reval_generated_offset_ccid := -1;

            end if;
         end if;

         if (l_deprn_tbl(i).capital_adj_generated_ccid is null and
             l_deprn_tbl(i).deprn_entered_amount <> 0 and
             fa_xla_extract_util_pkg.G_sorp_enabled) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_deprn_tbl(i).book_type_code,
                       X_fn_trx_code     => 'CAPITAL_ADJ_ACCT',
                       X_dist_ccid       => l_deprn_tbl(i).distribution_ccid,
                       X_acct_segval     => l_deprn_tbl(i).capital_adj_acct,
                       X_account_ccid    => l_deprn_tbl(i).capital_adj_account_ccid,
                       X_distribution_id => l_deprn_tbl(i).distribution_id,
                       X_rtn_ccid        => l_deprn_tbl(i).capital_adj_generated_ccid,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then

               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => 'FA_GET_ACCOUNT_CCID',
                   CALLING_FN => 'FA_INS_ADJUST_PKG.fadoflx',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_deprn_tbl(i).capital_adj_generated_ccid := -1;
            end if;
         end if;

         if (l_deprn_tbl(i).general_fund_generated_ccid is null and
             l_deprn_tbl(i).deprn_entered_amount <> 0 and
             fa_xla_extract_util_pkg.G_sorp_enabled) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_deprn_tbl(i).book_type_code,
                       X_fn_trx_code     => 'GENERAL_FUND_ACCT',
                       X_dist_ccid       => l_deprn_tbl(i).distribution_ccid,
                       X_acct_segval     => l_deprn_tbl(i).general_fund_acct,
                       X_account_ccid    => l_deprn_tbl(i).general_fund_account_ccid,
                       X_distribution_id => l_deprn_tbl(i).distribution_id,
                       X_rtn_ccid        => l_deprn_tbl(i).general_fund_generated_ccid,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then

               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => 'FA_GET_ACCOUNT_CCID',
                   CALLING_FN => 'FA_INS_ADJUST_PKG.fadoflx',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_deprn_tbl(i).general_fund_generated_ccid := -1;
            end if;
         end if;

      end loop;

      for i in 1.. l_deprn_tbl.count loop

         l_generated_ccid(i)              := l_deprn_tbl(i).generated_ccid;
         l_generated_offset_ccid(i)       := l_deprn_tbl(i).generated_offset_ccid;
         l_bonus_generated_ccid(i)        := l_deprn_tbl(i).bonus_generated_ccid;
         l_bonus_generated_offset_ccid(i) := l_deprn_tbl(i).bonus_generated_offset_ccid;
         l_reval_generated_ccid(i)        := l_deprn_tbl(i).reval_generated_ccid;
         l_reval_generated_offset_ccid(i) := l_deprn_tbl(i).reval_generated_offset_ccid;
         l_capital_adj_generated_ccid(i)  := l_deprn_tbl(i).capital_adj_generated_ccid;
         l_general_fund_generated_ccid(i) := l_deprn_tbl(i).general_fund_generated_ccid;
         l_rowid(i)                       := l_deprn_tbl(i).rowid;

      end loop;

      forall i in 1..l_deprn_tbl.count
      update fa_xla_ext_lines_b_gt
         set generated_ccid              = l_generated_ccid(i),
             generated_offset_ccid       = l_generated_offset_ccid(i),
             bonus_generated_ccid        = l_bonus_generated_ccid(i),
             bonus_generated_offset_ccid = l_bonus_generated_offset_ccid(i),
             reval_generated_ccid        = l_reval_generated_ccid(i),
             reval_generated_offset_ccid = l_reval_generated_offset_ccid(i),
             capital_adj_generated_ccid =  l_capital_adj_generated_ccid(i),
             general_fund_generated_ccid = l_general_fund_generated_ccid(i)
       where rowid                       = l_rowid(i);


--

      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name||'.end',
                        'End of procedure');
      END IF;

   EXCEPTION
      WHEN others THEN
           IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
              fnd_message.set_token('ORACLE_ERR',SQLERRM);
              FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
           END IF;
           raise;

   END load_generated_ccids;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|    Lock_Data                                                          |
|                                                                       |
+======================================================================*/

  --------------------------------------------------
  -- Locking Routine                              --
  --------------------------------------------------

  PROCEDURE Lock_Data IS

     TYPE number_tbl_type IS TABLE OF number INDEX BY BINARY_INTEGER;
     l_lock               number_tbl_type;
     l_procedure_name     varchar2(80) := 'lock_data';

  BEGIN

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(G_LEVEL_PROCEDURE,
                       G_MODULE_NAME||l_procedure_name||'.begin',
                       'Beginning of procedure');
     END IF;

 
--
     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(G_LEVEL_PROCEDURE,
                       G_MODULE_NAME||l_procedure_name||'.end',
                       'End of procedure');
     END IF;

   EXCEPTION
      WHEN others THEN
           IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
              fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
              fnd_message.set_token('ORACLE_ERR',SQLERRM);
              FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
           END IF;
           raise;


  END Lock_Data;



/*======================================================================+
|                                                                       |
| Public Function                                                       |
|    Lock_Data                                                          |
|                                                                       |
+======================================================================*/

  --------------------------------------------------
  -- Main Load Routine                            --
  --------------------------------------------------
   PROCEDURE load_data IS

      l_log_level_rec   FA_API_TYPES.log_level_rec_type;
      l_use_fafbgcc     varchar2(25);
      l_procedure_name  varchar2(80) := 'load_data';   -- BMR make this dynamic on type
      error_found       EXCEPTION;

   BEGIN

      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name||'.begin',
                        'Beginning of procedure');
      END IF;



         if (fa_xla_extract_util_pkg.G_deprn_exists) then
            Lock_Data;
            Load_header_data;
            Load_line_data;
            Load_mls_data;

            


      fnd_profile.get ('FA_WF_GENERATE_CCIDS', l_use_fafbgcc);
      if (nvl(l_use_fafbgcc, 'N') = 'Y') then
         if (NOT fa_util_pub.get_log_level_rec (
                   x_log_level_rec =>  l_log_level_rec)) then raise error_found;
         end if;

         Load_Generated_Ccids
            (p_log_level_rec => l_log_level_rec);
      end if;




         end if;

         if (fa_xla_extract_util_pkg.G_rollback_deprn_exists) then
            Load_header_data_rb;
         end if;




      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name||'.end',
                        'End of procedure');
      END IF;

   EXCEPTION
      WHEN error_found THEN
           IF (G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string (G_LEVEL_ERROR,
                              G_MODULE_NAME||l_procedure_name,
                              'ended in error');
           END IF;
           raise;

      WHEN others THEN
           IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
              fnd_message.set_token('ORACLE_ERR',SQLERRM);
              FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
           END IF;
           raise;

   END load_data;



END FA_XLA_EXTRACT_DEPRN_PKG;


/
