--------------------------------------------------------
--  DDL for Package Body FA_XLA_EXTRACT_TRX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_XLA_EXTRACT_TRX_PKG" AS

/*======================================================================+
|                Copyright (c) 1997 Oracle Corporation                  |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| Package Name                                                          |
|     FA_XLA_EXTRACT_TRX_PKG                                            |
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

G_MODULE_NAME         CONSTANT VARCHAR2(50):= 'fa.plsql.fa_xla_extract_trx_pkg.';


--+============================================+
--|                                            |
--|  PRIVATE  PROCEDURES/FUNCTIONS             |
--|                                            |
--+============================================+



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|    load_header_data_stg1                                                        |
|                                                                       |
+======================================================================*/

  PROCEDURE load_header_data_stg1 IS

     l_procedure_name  varchar2(80) := 'load_header_data_stg1';

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
           TRANSFER_TO_GL_FLAG                     ,
           AP_INTERCOMPANY_ACCT,
           AR_INTERCOMPANY_ACCT,
           COST_OF_REMOVAL_CLEARING_ACCT,
           COST_OF_REMOVAL_GAIN_ACCT,
           COST_OF_REMOVAL_LOSS_ACCT,
           DEPRN_ADJUSTMENT_ACCT,
           NBV_RETIRED_GAIN_ACCT,
           NBV_RETIRED_LOSS_ACCT,
           PROCEEDS_OF_SALE_CLEARING_ACCT,
           PROCEEDS_OF_SALE_GAIN_ACCT,
           PROCEEDS_OF_SALE_LOSS_ACCT,
           REVAL_RSV_RETIRED_GAIN_ACCT,
           REVAL_RSV_RETIRED_LOSS_ACCT )
    select ctlgd.event_id,
           bc.FLEXBUILDER_DEFAULTS_CCID            ,
           bc.book_type_code                       ,
           dp.PERIOD_NAME                          ,
           dp.CALENDAR_PERIOD_CLOSE_DATE           ,
           dp.PERIOD_COUNTER                       ,
           ctlgd.event_date                        ,
           decode(bc.GL_POSTING_ALLOWED_FLAG       ,
                 'YES', 'Y','N')         ,
           bc.AP_INTERCOMPANY_ACCT,
           bc.AR_INTERCOMPANY_ACCT,
           bc.COST_OF_REMOVAL_CLEARING_ACCT,
           bc.COST_OF_REMOVAL_GAIN_ACCT,
           bc.COST_OF_REMOVAL_LOSS_ACCT,
           bc.DEPRN_ADJUSTMENT_ACCT,
           bc.NBV_RETIRED_GAIN_ACCT,
           bc.NBV_RETIRED_LOSS_ACCT,
           bc.PROCEEDS_OF_SALE_CLEARING_ACCT,
           bc.PROCEEDS_OF_SALE_GAIN_ACCT,
           bc.PROCEEDS_OF_SALE_LOSS_ACCT,
           bc.REVAL_RSV_RETIRED_GAIN_ACCT,
           bc.REVAL_RSV_RETIRED_LOSS_ACCT
      FROM xla_events_gt                 ctlgd,
           fa_deprn_periods              dp,
           fa_book_controls              bc ,
           FA_TRANSACTION_HEADERS th 
     WHERE ctlgd.entity_code           = 'TRANSACTIONS'
       AND th.transaction_header_id    = ctlgd.source_id_int_1
       AND ctlgd.valuation_method      = dp.book_type_code
       AND ctlgd.valuation_method      = bc.book_type_code
       AND th.date_effective     between dp.period_open_date and
                                         nvl(dp.period_close_date, sysdate) ;

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

   end load_header_data_stg1;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|    load_header_data_stg2                                                        |
|                                                                       |
+======================================================================*/

  PROCEDURE load_header_data_stg2 IS

     l_procedure_name  varchar2(80) := 'load_header_data_stg2';

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
           TRANSFER_TO_GL_FLAG                     ,
           AP_INTERCOMPANY_ACCT,
           AR_INTERCOMPANY_ACCT )
    select ctlgd.event_id,
           bc.FLEXBUILDER_DEFAULTS_CCID            ,
           bc.book_type_code                       ,
           dp.PERIOD_NAME                          ,
           dp.CALENDAR_PERIOD_CLOSE_DATE           ,
           dp.PERIOD_COUNTER                       ,
           ctlgd.event_date                        ,
           decode(bc.GL_POSTING_ALLOWED_FLAG       ,
                 'YES', 'Y','N')         ,
           bc.AP_INTERCOMPANY_ACCT,
           bc.AR_INTERCOMPANY_ACCT
      FROM xla_events_gt                 ctlgd,
           fa_deprn_periods              dp,
           fa_book_controls              bc , 
           FA_TRX_REFERENCES trx 
     WHERE ctlgd.entity_code           = 'INTER_ASSET_TRANSACTIONS'
       AND trx.trx_reference_id        = ctlgd.source_id_int_1
       AND trx.event_id                = ctlgd.event_id
       AND trx.book_type_code          = dp.book_type_code
       AND trx.book_type_code          = bc.book_type_code
       AND dp.book_type_code           = trx.book_type_code
       AND trx.creation_date     between dp.period_open_date and
                                         nvl(dp.period_close_date, sysdate) ;

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

   end load_header_data_stg2;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|    load_line_data_stg1                                                        |
|                                                                       |
+======================================================================*/

  PROCEDURE load_line_data_stg1 IS

     l_procedure_name  varchar2(80) := 'load_line_data_stg1';

  BEGIN

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(G_LEVEL_PROCEDURE,
                       G_MODULE_NAME||l_procedure_name||'.begin',
                       'Beginning of procedure');
     END IF;


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
           DEPRN_EXPENSE_ACCT   ,
           ASSET_CLEARING_ACCT,
           ASSET_COST_ACCT,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           CIP_CLEARING_ACCT,
           CIP_COST_ACCT,
           DEPRN_RESERVE_ACCT,
           IMPAIR_EXPENSE_ACCT,
           IMPAIR_RESERVE_ACCT,
           REVAL_RESERVE_ACCT )
    select /*+ leading(ctgld) index(th, FA_TRANSACTION_HEADERS_U1) */ ctlgd.EVENT_ID                            ,
           ctlgd.event_type_code                     ,
           th.transaction_header_id                  ,
           nvl(th.member_transaction_header_id,
               th.transaction_header_id)             ,
           'TRX'                                   ,
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
           cb.DEPRN_EXPENSE_ACCT   ,
           cb.ASSET_CLEARING_ACCT,
           cb.ASSET_COST_ACCT,
           cb.BONUS_DEPRN_EXPENSE_ACCT,
           cb.BONUS_DEPRN_RESERVE_ACCT,
           cb.CIP_CLEARING_ACCT,
           cb.CIP_COST_ACCT,
           cb.DEPRN_RESERVE_ACCT,
           cb.IMPAIR_EXPENSE_ACCT,
           cb.IMPAIR_RESERVE_ACCT,
           cb.REVAL_RESERVE_ACCT
      from fa_additions_b            ad,
           fa_asset_history          ah,
           fa_book_controls          bc,
           fa_category_books         cb,
           gl_ledgers                le,
           fa_transaction_headers    th,
           xla_events_gt             ctlgd 
     where ctlgd.entity_code           = 'TRANSACTIONS'
       AND bc.book_type_code           = ctlgd.valuation_method
       AND le.ledger_id                = bc.set_of_books_id
       AND ad.asset_id                 = th.asset_id
       AND ah.asset_id                 = th.asset_id
       AND th.transaction_header_id    between ah.transaction_header_id_in and
                                               nvl(ah.transaction_header_id_out - 1, th.transaction_header_id)
       AND cb.category_id              = ah.category_id
       AND cb.book_type_code           = ctlgd.valuation_method
       AND ah.asset_type              in ('CAPITALIZED', 'CIP', 'GROUP')
       AND ad.asset_type              in ('CAPITALIZED', 'CIP', 'GROUP') 
        AND th.transaction_header_id        = ctlgd.source_id_int_1 ;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name,
                        'Rows inserted into staging main lines: ' || to_char(SQL%ROWCOUNT));
      END IF;



      if (fa_xla_extract_util_pkg.G_group_enabled) then



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
           DEPRN_EXPENSE_ACCT   ,
           ASSET_CLEARING_ACCT,
           ASSET_COST_ACCT,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           CIP_CLEARING_ACCT,
           CIP_COST_ACCT,
           DEPRN_RESERVE_ACCT,
           IMPAIR_EXPENSE_ACCT,
           IMPAIR_RESERVE_ACCT,
           REVAL_RESERVE_ACCT )
    select /*+ leading(ctgld) index(th, FA_TRANSACTION_HEADERS_N7) */ ctlgd.EVENT_ID                            ,
           ctlgd.event_type_code                     ,
           th.transaction_header_id                  ,
           nvl(th.member_transaction_header_id,
               th.transaction_header_id)             ,
           'TRX'                                   ,
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
           cb.DEPRN_EXPENSE_ACCT   ,
           cb.ASSET_CLEARING_ACCT,
           cb.ASSET_COST_ACCT,
           cb.BONUS_DEPRN_EXPENSE_ACCT,
           cb.BONUS_DEPRN_RESERVE_ACCT,
           cb.CIP_CLEARING_ACCT,
           cb.CIP_COST_ACCT,
           cb.DEPRN_RESERVE_ACCT,
           cb.IMPAIR_EXPENSE_ACCT,
           cb.IMPAIR_RESERVE_ACCT,
           cb.REVAL_RESERVE_ACCT
      from fa_additions_b            ad,
           fa_asset_history          ah,
           fa_book_controls          bc,
           fa_category_books         cb,
           gl_ledgers                le,
           fa_transaction_headers    th,
           xla_events_gt             ctlgd 
     where ctlgd.entity_code           = 'TRANSACTIONS'
       AND bc.book_type_code           = ctlgd.valuation_method
       AND le.ledger_id                = bc.set_of_books_id
       AND ad.asset_id                 = th.asset_id
       AND ah.asset_id                 = th.asset_id
       AND th.transaction_header_id    between ah.transaction_header_id_in and
                                               nvl(ah.transaction_header_id_out - 1, th.transaction_header_id)
       AND cb.category_id              = ah.category_id
       AND cb.book_type_code           = ctlgd.valuation_method
       AND ah.asset_type              in ('CAPITALIZED', 'CIP', 'GROUP')
       AND ad.asset_type              in ('CAPITALIZED', 'CIP', 'GROUP') 
        AND th.member_transaction_header_id        = ctlgd.source_id_int_1 ;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name,
                        'Rows inserted into staging group lines: ' || to_char(SQL%ROWCOUNT));
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

   end load_line_data_stg1;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|    load_line_data_stg2                                                        |
|                                                                       |
+======================================================================*/

  PROCEDURE load_line_data_stg2 IS

     l_procedure_name  varchar2(80) := 'load_line_data_stg2';

  BEGIN

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        fnd_log.string(G_LEVEL_PROCEDURE,
                       G_MODULE_NAME||l_procedure_name||'.begin',
                       'Beginning of procedure');
     END IF;


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
           DEPRN_EXPENSE_ACCT   ,
           ASSET_CLEARING_ACCT,
           ASSET_COST_ACCT,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           CIP_CLEARING_ACCT,
           CIP_COST_ACCT,
           DEPRN_RESERVE_ACCT,
           IMPAIR_EXPENSE_ACCT,
           IMPAIR_RESERVE_ACCT,
           REVAL_RESERVE_ACCT )
    select /*+ leading(ctgld) index(th, FA_TRANSACTION_HEADERS_U1) */ ctlgd.EVENT_ID                            ,
           ctlgd.event_type_code                     ,
           th.transaction_header_id                  ,
           nvl(th.member_transaction_header_id,
               th.transaction_header_id)             ,
           'TRX'                                   ,
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
           cb.DEPRN_EXPENSE_ACCT   ,
           cb.ASSET_CLEARING_ACCT,
           cb.ASSET_COST_ACCT,
           cb.BONUS_DEPRN_EXPENSE_ACCT,
           cb.BONUS_DEPRN_RESERVE_ACCT,
           cb.CIP_CLEARING_ACCT,
           cb.CIP_COST_ACCT,
           cb.DEPRN_RESERVE_ACCT,
           cb.IMPAIR_EXPENSE_ACCT,
           cb.IMPAIR_RESERVE_ACCT,
           cb.REVAL_RESERVE_ACCT
      from fa_additions_b            ad,
           fa_asset_history          ah,
           fa_book_controls          bc,
           fa_category_books         cb,
           gl_ledgers                le,
           fa_transaction_headers    th,
           fa_trx_references         trx,
           xla_events_gt             ctlgd 
     where ctlgd.entity_code           = 'INTER_ASSET_TRANSACTIONS'
       AND trx.trx_reference_id        = ctlgd.source_id_int_1
       AND bc.book_type_code           = ctlgd.valuation_method
       AND le.ledger_id                = bc.set_of_books_id
       AND ad.asset_id                 = th.asset_id
       AND ah.asset_id                 = th.asset_id
       AND th.transaction_header_id    between ah.transaction_header_id_in and
                                               nvl(ah.transaction_header_id_out - 1, th.transaction_header_id)
       AND cb.category_id              = ah.category_id
       AND cb.book_type_code           = ctlgd.valuation_method --th.book_type_code
       AND ah.asset_type              in ('CAPITALIZED', 'CIP', 'GROUP')
       AND ad.asset_type              in ('CAPITALIZED', 'CIP', 'GROUP') 
       AND th.transaction_header_id = trx.src_transaction_header_id ;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name,
                        'Rows inserted into staging src main lines: ' || to_char(SQL%ROWCOUNT));
      END IF;



      if (fa_xla_extract_util_pkg.G_group_enabled) then



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
           DEPRN_EXPENSE_ACCT   ,
           ASSET_CLEARING_ACCT,
           ASSET_COST_ACCT,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           CIP_CLEARING_ACCT,
           CIP_COST_ACCT,
           DEPRN_RESERVE_ACCT,
           IMPAIR_EXPENSE_ACCT,
           IMPAIR_RESERVE_ACCT,
           REVAL_RESERVE_ACCT )
    select /*+ leading(ctgld) index(th, FA_TRANSACTION_HEADERS_N7) */ ctlgd.EVENT_ID                            ,
           ctlgd.event_type_code                     ,
           th.transaction_header_id                  ,
           nvl(th.member_transaction_header_id,
               th.transaction_header_id)             ,
           'TRX'                                   ,
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
           cb.DEPRN_EXPENSE_ACCT   ,
           cb.ASSET_CLEARING_ACCT,
           cb.ASSET_COST_ACCT,
           cb.BONUS_DEPRN_EXPENSE_ACCT,
           cb.BONUS_DEPRN_RESERVE_ACCT,
           cb.CIP_CLEARING_ACCT,
           cb.CIP_COST_ACCT,
           cb.DEPRN_RESERVE_ACCT,
           cb.IMPAIR_EXPENSE_ACCT,
           cb.IMPAIR_RESERVE_ACCT,
           cb.REVAL_RESERVE_ACCT
      from fa_additions_b            ad,
           fa_asset_history          ah,
           fa_book_controls          bc,
           fa_category_books         cb,
           gl_ledgers                le,
           fa_transaction_headers    th,
           fa_trx_references         trx,
           xla_events_gt             ctlgd 
     where ctlgd.entity_code           = 'INTER_ASSET_TRANSACTIONS'
       AND trx.trx_reference_id        = ctlgd.source_id_int_1
       AND bc.book_type_code           = ctlgd.valuation_method
       AND le.ledger_id                = bc.set_of_books_id
       AND ad.asset_id                 = th.asset_id
       AND ah.asset_id                 = th.asset_id
       AND th.transaction_header_id    between ah.transaction_header_id_in and
                                               nvl(ah.transaction_header_id_out - 1, th.transaction_header_id)
       AND cb.category_id              = ah.category_id
       AND cb.book_type_code           = ctlgd.valuation_method --th.book_type_code
       AND ah.asset_type              in ('CAPITALIZED', 'CIP', 'GROUP')
       AND ad.asset_type              in ('CAPITALIZED', 'CIP', 'GROUP') 
       AND th.member_transaction_header_id = trx.src_transaction_header_id ;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name,
                        'Rows inserted into staging src group lines: ' || to_char(SQL%ROWCOUNT));
      END IF;



      end if; 

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
           DEPRN_EXPENSE_ACCT   ,
           ASSET_CLEARING_ACCT,
           ASSET_COST_ACCT,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           CIP_CLEARING_ACCT,
           CIP_COST_ACCT,
           DEPRN_RESERVE_ACCT,
           IMPAIR_EXPENSE_ACCT,
           IMPAIR_RESERVE_ACCT,
           REVAL_RESERVE_ACCT )
    select /*+ leading(ctgld) index(th, FA_TRANSACTION_HEADERS_U1) */ ctlgd.EVENT_ID                            ,
           ctlgd.event_type_code                     ,
           th.transaction_header_id                  ,
           nvl(th.member_transaction_header_id,
               th.transaction_header_id)             ,
           'TRX'                                   ,
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
           cb.DEPRN_EXPENSE_ACCT   ,
           cb.ASSET_CLEARING_ACCT,
           cb.ASSET_COST_ACCT,
           cb.BONUS_DEPRN_EXPENSE_ACCT,
           cb.BONUS_DEPRN_RESERVE_ACCT,
           cb.CIP_CLEARING_ACCT,
           cb.CIP_COST_ACCT,
           cb.DEPRN_RESERVE_ACCT,
           cb.IMPAIR_EXPENSE_ACCT,
           cb.IMPAIR_RESERVE_ACCT,
           cb.REVAL_RESERVE_ACCT
      from fa_additions_b            ad,
           fa_asset_history          ah,
           fa_book_controls          bc,
           fa_category_books         cb,
           gl_ledgers                le,
           fa_transaction_headers    th,
           fa_trx_references         trx,
           xla_events_gt             ctlgd 
     where ctlgd.entity_code           = 'INTER_ASSET_TRANSACTIONS'
       AND trx.trx_reference_id        = ctlgd.source_id_int_1
       AND bc.book_type_code           = ctlgd.valuation_method
       AND le.ledger_id                = bc.set_of_books_id
       AND ad.asset_id                 = th.asset_id
       AND ah.asset_id                 = th.asset_id
       AND th.transaction_header_id    between ah.transaction_header_id_in and
                                               nvl(ah.transaction_header_id_out - 1, th.transaction_header_id)
       AND cb.category_id              = ah.category_id
       AND cb.book_type_code           = ctlgd.valuation_method --th.book_type_code
       AND ah.asset_type              in ('CAPITALIZED', 'CIP', 'GROUP')
       AND ad.asset_type              in ('CAPITALIZED', 'CIP', 'GROUP') 
       AND th.transaction_header_id = trx.dest_transaction_header_id ;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name,
                        'Rows inserted into staging dest main lines: ' || to_char(SQL%ROWCOUNT));
      END IF;



      if (fa_xla_extract_util_pkg.G_group_enabled) then



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
           DEPRN_EXPENSE_ACCT   ,
           ASSET_CLEARING_ACCT,
           ASSET_COST_ACCT,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           CIP_CLEARING_ACCT,
           CIP_COST_ACCT,
           DEPRN_RESERVE_ACCT,
           IMPAIR_EXPENSE_ACCT,
           IMPAIR_RESERVE_ACCT,
           REVAL_RESERVE_ACCT )
    select /*+ leading(ctgld) index(th, FA_TRANSACTION_HEADERS_N7) */ ctlgd.EVENT_ID                            ,
           ctlgd.event_type_code                     ,
           th.transaction_header_id                  ,
           nvl(th.member_transaction_header_id,
               th.transaction_header_id)             ,
           'TRX'                                   ,
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
           cb.DEPRN_EXPENSE_ACCT   ,
           cb.ASSET_CLEARING_ACCT,
           cb.ASSET_COST_ACCT,
           cb.BONUS_DEPRN_EXPENSE_ACCT,
           cb.BONUS_DEPRN_RESERVE_ACCT,
           cb.CIP_CLEARING_ACCT,
           cb.CIP_COST_ACCT,
           cb.DEPRN_RESERVE_ACCT,
           cb.IMPAIR_EXPENSE_ACCT,
           cb.IMPAIR_RESERVE_ACCT,
           cb.REVAL_RESERVE_ACCT
      from fa_additions_b            ad,
           fa_asset_history          ah,
           fa_book_controls          bc,
           fa_category_books         cb,
           gl_ledgers                le,
           fa_transaction_headers    th,
           fa_trx_references         trx,
           xla_events_gt             ctlgd 
     where ctlgd.entity_code           = 'INTER_ASSET_TRANSACTIONS'
       AND trx.trx_reference_id        = ctlgd.source_id_int_1
       AND bc.book_type_code           = ctlgd.valuation_method
       AND le.ledger_id                = bc.set_of_books_id
       AND ad.asset_id                 = th.asset_id
       AND ah.asset_id                 = th.asset_id
       AND th.transaction_header_id    between ah.transaction_header_id_in and
                                               nvl(ah.transaction_header_id_out - 1, th.transaction_header_id)
       AND cb.category_id              = ah.category_id
       AND cb.book_type_code           = ctlgd.valuation_method --th.book_type_code
       AND ah.asset_type              in ('CAPITALIZED', 'CIP', 'GROUP')
       AND ad.asset_type              in ('CAPITALIZED', 'CIP', 'GROUP') 
       AND th.member_transaction_header_id = trx.dest_transaction_header_id ;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name,
                        'Rows inserted into staging dest group lines: ' || to_char(SQL%ROWCOUNT));
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

   end load_line_data_stg2;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|    load_line_data_fin1                                                        |
|                                                                       |
+======================================================================*/

  PROCEDURE load_line_data_fin1 IS

     l_procedure_name  varchar2(80) := 'load_line_data_fin1';

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
           ENTERED_AMOUNT                       ,
           ADJUSTMENT_LINE_ID,
           ADJUSTMENT_TYPE,
           PAYABLES_CCID,
           EXPENSE_ACCOUNT_CCID,
           ASSET_CLEARING_ACCT,
           ASSET_COST_ACCT,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           CIP_CLEARING_ACCT,
           CIP_COST_ACCT,
           DEPRN_RESERVE_ACCT,
           IMPAIR_EXPENSE_ACCT,
           IMPAIR_RESERVE_ACCT,
           REVAL_RESERVE_ACCT,
           TRANSACTION_HEADER_ID )
    select /*+ leading(stg) index(adj, FA_ADJUSTMENTS_U1) */ stg.EVENT_ID                            ,
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
           stg.GENERAL_FUND_ACCOUNT_CCID           ,
           decode(adj.adjustment_type,
                  'COST CLEARING',
                      decode(debit_credit_flag,
                             'CR', adjustment_amount,
                             -1 * adjustment_amount),
                  'RESERVE',
                      decode(debit_credit_flag,
                             'CR', adjustment_amount,
                             -1 * adjustment_amount),
                  'BONUS RESERVE',
                      decode(debit_credit_flag,
                             'CR', adjustment_amount,
                             -1 * adjustment_amount),
                  'REVAL RESERVE',
                      decode(debit_credit_flag,
                             'CR', adjustment_amount,
                             -1 * adjustment_amount),
                  'CIP COST',
                      decode(stg.event_type_code,
                             'CAPITALIZATION',
                                   decode(debit_credit_flag,
                                          'CR', adjustment_amount,
                                          -1 * adjustment_amount),
                             'REVERSE_CAPITALIZATION',
                                   decode(debit_credit_flag,
                                          'CR', adjustment_amount,
                                          -1 * adjustment_amount),
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount)),
                  'COST',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'EXPENSE',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'BONUS EXPENSE',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                              -1 * adjustment_amount),
                  'NBV RETIRED',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'PROCEEDS CLR',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'REMOVALCOST CLR',
                      decode(debit_credit_flag,
                             'CR', adjustment_amount,
                             -1 * adjustment_amount),
                  'IMPAIR EXPENSE',
                      decode(debit_credit_flag,
                             'DR',adjustment_amount,
                              -1 * adjustment_amount),
                  'IMPAIR RESERVE',
                      decode(debit_credit_flag,
                             'CR',adjustment_amount,
                              -1 * adjustment_amount),
                  'CAPITAL ADJ',
                      decode(debit_credit_flag,
                             'DR',adjustment_amount,
                              -1 * adjustment_amount),
                  'GENERAL FUND',
                      decode(debit_credit_flag,
                             'CR',adjustment_amount,
                              -1 * adjustment_amount),
                  'LINK IMPAIR EXP',
                      decode(debit_credit_flag,
                             'CR',adjustment_amount,
                              -1 * adjustment_amount),
                  decode(debit_credit_flag,
                         'DR', adjustment_amount,
                         -1 * adjustment_amount))  ,
           adj.ADJUSTMENT_LINE_ID,
           adj.ADJUSTMENT_TYPE,
           ai.PAYABLES_CODE_COMBINATION_ID,
           dh.CODE_COMBINATION_ID,
           stg.ASSET_CLEARING_ACCT,
           stg.ASSET_COST_ACCT,
           stg.BONUS_DEPRN_EXPENSE_ACCT,
           stg.BONUS_RESERVE_ACCT,
           stg.CIP_CLEARING_ACCT,
           stg.CIP_COST_ACCT,
           stg.DEPRN_RESERVE_ACCT,
           stg.IMPAIR_EXPENSE_ACCT,
           stg.IMPAIR_RESERVE_ACCT,
           stg.REVAL_RESERVE_ACCT,
           stg.TRANSACTION_HEADER_ID
      from fa_xla_ext_lines_stg_gt   stg,
           fa_adjustments            adj,
           fa_distribution_history   dh,
           fa_locations              loc,
           fa_lookups                lu , 
           FA_ASSET_INVOICES ai
     WHERE adj.transaction_header_id   = stg.transaction_header_id
       AND adj.book_type_code          = stg.book_type_code
       AND adj.distribution_id         = dh.distribution_id
       AND dh.location_id              = loc.location_id
       -- AND dh.assigned_to           = emp.employee_id(+)
       AND lu.lookup_type              = 'JOURNAL ENTRIES'
       AND lu.lookup_code              = adj.source_type_code || ' ' ||
                                         decode (adj.adjustment_type,
                                                 'CIP COST', 'COST',
                                                 adj.adjustment_type)
       AND adj.adjustment_type    not in ('REVAL EXPENSE', 'REVAL AMORT')
       AND nvl(adj.track_member_flag, 'N') = 'N'
       AND adj.adjustment_amount <> 0 
       AND stg.event_type_code        in ('ADDITIONS',      'CIP_ADDITIONS',
                                          'ADJUSTMENTS',    'CIP_ADJUSTMENTS',
                                          'CAPITALIZATION', 'REVERSE_CAPITALIZATION',
                                          'REVALUATION',    'CIP_REVALUATION',
                                          'DEPRECIATION_ADJUSTMENTS',
                                          'UNPLANNED_DEPRECIATION',
                                          'TERMINAL_GAIN_LOSS',
                                          'RETIREMENT_ADJUSTMENTS',
                                          'IMPAIRMENT') 
       AND adj.source_line_id          = ai.source_line_id(+) ;

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
           ENTERED_AMOUNT                       ,
           ADJUSTMENT_LINE_ID,
           ADJUSTMENT_TYPE,
           PAYABLES_CCID,
           EXPENSE_ACCOUNT_CCID,
           ASSET_CLEARING_ACCT,
           ASSET_COST_ACCT,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           CIP_CLEARING_ACCT,
           CIP_COST_ACCT,
           DEPRN_RESERVE_ACCT,
           IMPAIR_EXPENSE_ACCT,
           IMPAIR_RESERVE_ACCT,
           REVAL_RESERVE_ACCT,
           TRANSACTION_HEADER_ID )
    select /*+ leading(stg) index(adj, FA_MC_ADJUSTMENTS_U1) */ stg.EVENT_ID                            ,
           adj.adjustment_line_id                  ,
           adj.distribution_id                     ,
           stg.distribution_type_code              ,
           bc.set_of_books_id                           ,
           le.currency_code                       ,
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
           stg.GENERAL_FUND_ACCOUNT_CCID           ,
           decode(adj.adjustment_type,
                  'COST CLEARING',
                      decode(debit_credit_flag,
                             'CR', adjustment_amount,
                             -1 * adjustment_amount),
                  'RESERVE',
                      decode(debit_credit_flag,
                             'CR', adjustment_amount,
                             -1 * adjustment_amount),
                  'BONUS RESERVE',
                      decode(debit_credit_flag,
                             'CR', adjustment_amount,
                             -1 * adjustment_amount),
                  'REVAL RESERVE',
                      decode(debit_credit_flag,
                             'CR', adjustment_amount,
                             -1 * adjustment_amount),
                  'CIP COST',
                      decode(stg.event_type_code,
                             'CAPITALIZATION',
                                   decode(debit_credit_flag,
                                          'CR', adjustment_amount,
                                          -1 * adjustment_amount),
                             'REVERSE_CAPITALIZATION',
                                   decode(debit_credit_flag,
                                          'CR', adjustment_amount,
                                          -1 * adjustment_amount),
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount)),
                  'COST',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'EXPENSE',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'BONUS EXPENSE',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                              -1 * adjustment_amount),
                  'NBV RETIRED',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'PROCEEDS CLR',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'REMOVALCOST CLR',
                      decode(debit_credit_flag,
                             'CR', adjustment_amount,
                             -1 * adjustment_amount),
                  'IMPAIR EXPENSE',
                      decode(debit_credit_flag,
                             'DR',adjustment_amount,
                              -1 * adjustment_amount),
                  'IMPAIR RESERVE',
                      decode(debit_credit_flag,
                             'CR',adjustment_amount,
                              -1 * adjustment_amount),
                  'CAPITAL ADJ',
                      decode(debit_credit_flag,
                             'DR',adjustment_amount,
                              -1 * adjustment_amount),
                  'GENERAL FUND',
                      decode(debit_credit_flag,
                             'CR',adjustment_amount,
                              -1 * adjustment_amount),
                  'LINK IMPAIR EXP',
                      decode(debit_credit_flag,
                             'CR',adjustment_amount,
                              -1 * adjustment_amount),
                  decode(debit_credit_flag,
                         'DR', adjustment_amount,
                         -1 * adjustment_amount))  ,
           adj.ADJUSTMENT_LINE_ID,
           adj.ADJUSTMENT_TYPE,
           ai.PAYABLES_CODE_COMBINATION_ID,
           dh.CODE_COMBINATION_ID,
           stg.ASSET_CLEARING_ACCT,
           stg.ASSET_COST_ACCT,
           stg.BONUS_DEPRN_EXPENSE_ACCT,
           stg.BONUS_RESERVE_ACCT,
           stg.CIP_CLEARING_ACCT,
           stg.CIP_COST_ACCT,
           stg.DEPRN_RESERVE_ACCT,
           stg.IMPAIR_EXPENSE_ACCT,
           stg.IMPAIR_RESERVE_ACCT,
           stg.REVAL_RESERVE_ACCT,
           stg.TRANSACTION_HEADER_ID
      from fa_xla_ext_lines_stg_gt   stg,
           fa_mc_adjustments            adj,
           fa_distribution_history   dh,
           fa_locations              loc,
           fa_lookups                lu , 
           fa_mc_asset_invoices ai, 
           fa_mc_book_controls bc , 
           gl_ledgers le 
     WHERE adj.transaction_header_id   = stg.transaction_header_id
       AND adj.book_type_code          = stg.book_type_code
       AND adj.distribution_id         = dh.distribution_id
       AND dh.location_id              = loc.location_id
       -- AND dh.assigned_to           = emp.employee_id(+)
       AND lu.lookup_type              = 'JOURNAL ENTRIES'
       AND lu.lookup_code              = adj.source_type_code || ' ' ||
                                         decode (adj.adjustment_type,
                                                 'CIP COST', 'COST',
                                                 adj.adjustment_type)
       AND adj.adjustment_type    not in ('REVAL EXPENSE', 'REVAL AMORT')
       AND nvl(adj.track_member_flag, 'N') = 'N'
       AND adj.adjustment_amount <> 0 
       AND stg.event_type_code        in ('ADDITIONS',      'CIP_ADDITIONS',
                                          'ADJUSTMENTS',    'CIP_ADJUSTMENTS',
                                          'CAPITALIZATION', 'REVERSE_CAPITALIZATION',
                                          'REVALUATION',    'CIP_REVALUATION',
                                          'DEPRECIATION_ADJUSTMENTS',
                                          'UNPLANNED_DEPRECIATION',
                                          'TERMINAL_GAIN_LOSS',
                                          'RETIREMENT_ADJUSTMENTS',
                                          'IMPAIRMENT') 
       AND adj.source_line_id          = ai.source_line_id(+) 
       AND bc.book_type_code  = stg.book_type_code 
       AND bc.set_of_books_id = le.ledger_id 
      AND adj.set_of_books_id = bc.set_of_books_id 
      AND adj.set_of_books_id = ai.set_of_books_id(+) ;

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

   end load_line_data_fin1;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|    load_line_data_fin2                                                        |
|                                                                       |
+======================================================================*/

  PROCEDURE load_line_data_fin2 IS

     l_procedure_name  varchar2(80) := 'load_line_data_fin2';

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
           ENTERED_AMOUNT                       ,
           ADJUSTMENT_LINE_ID,
           ADJUSTMENT_TYPE,
           SOURCE_DEST_CODE,
           PAYABLES_CCID,
           EXPENSE_ACCOUNT_CCID,
           ASSET_CLEARING_ACCT,
           ASSET_COST_ACCT,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           CIP_CLEARING_ACCT,
           CIP_COST_ACCT,
           DEPRN_RESERVE_ACCT,
           IMPAIR_EXPENSE_ACCT,
           IMPAIR_RESERVE_ACCT,
           REVAL_RESERVE_ACCT,
           TRANSACTION_HEADER_ID )
    select /*+ leading(stg) index(adj, FA_ADJUSTMENTS_U1) */ stg.EVENT_ID                            ,
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
           stg.GENERAL_FUND_ACCOUNT_CCID           ,
           decode(adj.source_dest_code,
                  'SOURCE',
                  decode(adj.adjustment_type,
                         'RESERVE',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'BONUS RESERVE',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'REVAL RESERVE',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'IMPAIR RESERVE',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'CAPITAL ADJ',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'GENERAL FUND',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                          decode(debit_credit_flag,
                                 'CR', adjustment_amount,
                                 -1 * adjustment_amount)),
                  decode(adj.adjustment_type,
                         'RESERVE',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                     -1 * adjustment_amount),
                         'BONUS RESERVE',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'REVAL RESERVE',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'IMPAIR RESERVE',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'CAPITAL ADJ',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'GENERAL FUND',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                    -1 * adjustment_amount),
                         decode(debit_credit_flag,
                                'DR', adjustment_amount,
                                -1 * adjustment_amount))) ,
           adj.ADJUSTMENT_LINE_ID,
           adj.ADJUSTMENT_TYPE,
           adj.SOURCE_DEST_CODE,
           ai.PAYABLES_CODE_COMBINATION_ID,
           dh.CODE_COMBINATION_ID,
           stg.ASSET_CLEARING_ACCT,
           stg.ASSET_COST_ACCT,
           stg.BONUS_DEPRN_EXPENSE_ACCT,
           stg.BONUS_RESERVE_ACCT,
           stg.CIP_CLEARING_ACCT,
           stg.CIP_COST_ACCT,
           stg.DEPRN_RESERVE_ACCT,
           stg.IMPAIR_EXPENSE_ACCT,
           stg.IMPAIR_RESERVE_ACCT,
           stg.REVAL_RESERVE_ACCT,
           stg.TRANSACTION_HEADER_ID
      from fa_xla_ext_lines_stg_gt   stg,
           fa_adjustments            adj,
           fa_distribution_history   dh,
           fa_locations              loc,
           fa_lookups                lu , 
           FA_ASSET_INVOICES ai
     WHERE adj.transaction_header_id   = stg.transaction_header_id
       AND adj.book_type_code          = stg.book_type_code
       AND adj.distribution_id         = dh.distribution_id
       AND dh.location_id              = loc.location_id
       -- AND dh.assigned_to           = emp.employee_id(+)
       AND lu.lookup_type              = 'JOURNAL ENTRIES'
       AND lu.lookup_code              = adj.source_type_code || ' ' ||
                                         decode (adj.adjustment_type,
                                                 'CIP COST', 'COST',
                                                 adj.adjustment_type)
       AND adj.adjustment_type    not in ('REVAL EXPENSE', 'REVAL AMORT')
       AND nvl(adj.track_member_flag, 'N') = 'N'
       AND adj.adjustment_amount <> 0 
       AND stg.event_type_code        in ('SOURCE_LINE_TRANSFERS',
                                          'CIP_SOURCE_LINE_TRANSFERS',
                                          'RESERVE_TRANSFERS') 
       AND adj.source_line_id          = ai.source_line_id(+) ;

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
           ENTERED_AMOUNT                       ,
           ADJUSTMENT_LINE_ID,
           ADJUSTMENT_TYPE,
           SOURCE_DEST_CODE,
           PAYABLES_CCID,
           EXPENSE_ACCOUNT_CCID,
           ASSET_CLEARING_ACCT,
           ASSET_COST_ACCT,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           CIP_CLEARING_ACCT,
           CIP_COST_ACCT,
           DEPRN_RESERVE_ACCT,
           IMPAIR_EXPENSE_ACCT,
           IMPAIR_RESERVE_ACCT,
           REVAL_RESERVE_ACCT,
           TRANSACTION_HEADER_ID )
    select /*+ leading(stg) index(adj, FA_MC_ADJUSTMENTS_U1) */ stg.EVENT_ID                            ,
           adj.adjustment_line_id                  ,
           adj.distribution_id                     ,
           stg.distribution_type_code              ,
           bc.set_of_books_id                           ,
           le.currency_code                       ,
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
           stg.GENERAL_FUND_ACCOUNT_CCID           ,
           decode(adj.source_dest_code,
                  'SOURCE',
                  decode(adj.adjustment_type,
                         'RESERVE',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'BONUS RESERVE',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'REVAL RESERVE',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'IMPAIR RESERVE',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'CAPITAL ADJ',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'GENERAL FUND',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                          decode(debit_credit_flag,
                                 'CR', adjustment_amount,
                                 -1 * adjustment_amount)),
                  decode(adj.adjustment_type,
                         'RESERVE',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                     -1 * adjustment_amount),
                         'BONUS RESERVE',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'REVAL RESERVE',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'IMPAIR RESERVE',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'CAPITAL ADJ',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'GENERAL FUND',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                    -1 * adjustment_amount),
                         decode(debit_credit_flag,
                                'DR', adjustment_amount,
                                -1 * adjustment_amount))) ,
           adj.ADJUSTMENT_LINE_ID,
           adj.ADJUSTMENT_TYPE,
           adj.SOURCE_DEST_CODE,
           ai.PAYABLES_CODE_COMBINATION_ID,
           dh.CODE_COMBINATION_ID,
           stg.ASSET_CLEARING_ACCT,
           stg.ASSET_COST_ACCT,
           stg.BONUS_DEPRN_EXPENSE_ACCT,
           stg.BONUS_RESERVE_ACCT,
           stg.CIP_CLEARING_ACCT,
           stg.CIP_COST_ACCT,
           stg.DEPRN_RESERVE_ACCT,
           stg.IMPAIR_EXPENSE_ACCT,
           stg.IMPAIR_RESERVE_ACCT,
           stg.REVAL_RESERVE_ACCT,
           stg.TRANSACTION_HEADER_ID
      from fa_xla_ext_lines_stg_gt   stg,
           fa_mc_adjustments            adj,
           fa_distribution_history   dh,
           fa_locations              loc,
           fa_lookups                lu , 
           fa_mc_asset_invoices ai, 
           fa_mc_book_controls bc , 
           gl_ledgers le 
     WHERE adj.transaction_header_id   = stg.transaction_header_id
       AND adj.book_type_code          = stg.book_type_code
       AND adj.distribution_id         = dh.distribution_id
       AND dh.location_id              = loc.location_id
       -- AND dh.assigned_to           = emp.employee_id(+)
       AND lu.lookup_type              = 'JOURNAL ENTRIES'
       AND lu.lookup_code              = adj.source_type_code || ' ' ||
                                         decode (adj.adjustment_type,
                                                 'CIP COST', 'COST',
                                                 adj.adjustment_type)
       AND adj.adjustment_type    not in ('REVAL EXPENSE', 'REVAL AMORT')
       AND nvl(adj.track_member_flag, 'N') = 'N'
       AND adj.adjustment_amount <> 0 
       AND stg.event_type_code        in ('SOURCE_LINE_TRANSFERS',
                                          'CIP_SOURCE_LINE_TRANSFERS',
                                          'RESERVE_TRANSFERS') 
       AND adj.source_line_id          = ai.source_line_id(+) 
       AND bc.book_type_code  = stg.book_type_code 
       AND bc.set_of_books_id = le.ledger_id 
      AND adj.set_of_books_id = bc.set_of_books_id 
      AND adj.set_of_books_id = ai.set_of_books_id(+) ;

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

   end load_line_data_fin2;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|    load_line_data_xfr                                                        |
|                                                                       |
+======================================================================*/

  PROCEDURE load_line_data_xfr IS

     l_procedure_name  varchar2(80) := 'load_line_data_xfr';

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
           ENTERED_AMOUNT                       ,
           ADJUSTMENT_LINE_ID,
           ADJUSTMENT_TYPE,
           SOURCE_DEST_CODE,
           EXPENSE_ACCOUNT_CCID,
           ASSET_COST_ACCT,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           CIP_COST_ACCT,
           DEPRN_RESERVE_ACCT,
           IMPAIR_RESERVE_ACCT,
           REVAL_RESERVE_ACCT,
           TRANSACTION_HEADER_ID )
    select /*+ leading(stg) index(adj, FA_ADJUSTMENTS_U1) */ stg.EVENT_ID                            ,
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
           stg.GENERAL_FUND_ACCOUNT_CCID           ,
           decode(adj.source_dest_code,
                  'SOURCE',
                  decode(adj.adjustment_type,
                         'RESERVE',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'BONUS RESERVE',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'REVAL RESERVE',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'IMPAIR RESERVE',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'CAPITAL ADJ',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'GENERAL FUND',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                         decode(debit_credit_flag,
                                'CR', adjustment_amount,
                                -1 * adjustment_amount)),
                  decode(adj.adjustment_type,
                         'RESERVE',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'BONUS RESERVE',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'REVAL RESERVE',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'IMPAIR RESERVE',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'CAPITAL ADJ',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'GENERAL FUND',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                    -1 * adjustment_amount),
                         decode(debit_credit_flag,
                                'DR', adjustment_amount,
                                -1 * adjustment_amount))) ,
           adj.ADJUSTMENT_LINE_ID,
           adj.ADJUSTMENT_TYPE,
           adj.SOURCE_DEST_CODE,
           dh.CODE_COMBINATION_ID,
           stg.ASSET_COST_ACCT,
           stg.BONUS_DEPRN_EXPENSE_ACCT,
           stg.BONUS_RESERVE_ACCT,
           stg.CIP_COST_ACCT,
           stg.DEPRN_RESERVE_ACCT,
           stg.IMPAIR_RESERVE_ACCT,
           stg.REVAL_RESERVE_ACCT,
           stg.TRANSACTION_HEADER_ID
      from fa_xla_ext_lines_stg_gt   stg,
           fa_adjustments            adj,
           fa_distribution_history   dh,
           fa_locations              loc,
           fa_lookups                lu 
     WHERE adj.transaction_header_id   = stg.transaction_header_id
       AND adj.book_type_code          = stg.book_type_code
       AND adj.distribution_id         = dh.distribution_id
       AND dh.location_id              = loc.location_id
       -- AND dh.assigned_to           = emp.employee_id(+)
       AND lu.lookup_type              = 'JOURNAL ENTRIES'
       AND lu.lookup_code              = adj.source_type_code || ' ' ||
                                         decode (adj.adjustment_type,
                                                 'CIP COST', 'COST',
                                                 adj.adjustment_type)
       AND adj.adjustment_type    not in ('REVAL EXPENSE', 'REVAL AMORT')
       AND nvl(adj.track_member_flag, 'N') = 'N'
       AND adj.adjustment_amount <> 0 
       AND stg.event_type_code        in ('TRANSFERS', 'CIP_TRANSFERS') ;

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
           ENTERED_AMOUNT                       ,
           ADJUSTMENT_LINE_ID,
           ADJUSTMENT_TYPE,
           SOURCE_DEST_CODE,
           EXPENSE_ACCOUNT_CCID,
           ASSET_COST_ACCT,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           CIP_COST_ACCT,
           DEPRN_RESERVE_ACCT,
           IMPAIR_RESERVE_ACCT,
           REVAL_RESERVE_ACCT,
           TRANSACTION_HEADER_ID )
    select /*+ leading(stg) index(adj, FA_MC_ADJUSTMENTS_U1) */ stg.EVENT_ID                            ,
           adj.adjustment_line_id                  ,
           adj.distribution_id                     ,
           stg.distribution_type_code              ,
           bc.set_of_books_id                           ,
           le.currency_code                       ,
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
           stg.GENERAL_FUND_ACCOUNT_CCID           ,
           decode(adj.source_dest_code,
                  'SOURCE',
                  decode(adj.adjustment_type,
                         'RESERVE',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'BONUS RESERVE',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'REVAL RESERVE',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'IMPAIR RESERVE',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'CAPITAL ADJ',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'GENERAL FUND',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                         decode(debit_credit_flag,
                                'CR', adjustment_amount,
                                -1 * adjustment_amount)),
                  decode(adj.adjustment_type,
                         'RESERVE',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'BONUS RESERVE',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'REVAL RESERVE',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'IMPAIR RESERVE',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'CAPITAL ADJ',
                             decode(debit_credit_flag,
                                    'DR', adjustment_amount,
                                    -1 * adjustment_amount),
                         'GENERAL FUND',
                             decode(debit_credit_flag,
                                    'CR', adjustment_amount,
                                    -1 * adjustment_amount),
                         decode(debit_credit_flag,
                                'DR', adjustment_amount,
                                -1 * adjustment_amount))) ,
           adj.ADJUSTMENT_LINE_ID,
           adj.ADJUSTMENT_TYPE,
           adj.SOURCE_DEST_CODE,
           dh.CODE_COMBINATION_ID,
           stg.ASSET_COST_ACCT,
           stg.BONUS_DEPRN_EXPENSE_ACCT,
           stg.BONUS_RESERVE_ACCT,
           stg.CIP_COST_ACCT,
           stg.DEPRN_RESERVE_ACCT,
           stg.IMPAIR_RESERVE_ACCT,
           stg.REVAL_RESERVE_ACCT,
           stg.TRANSACTION_HEADER_ID
      from fa_xla_ext_lines_stg_gt   stg,
           fa_mc_adjustments            adj,
           fa_distribution_history   dh,
           fa_locations              loc,
           fa_lookups                lu , 
           fa_mc_book_controls bc , 
           gl_ledgers le 
     WHERE adj.transaction_header_id   = stg.transaction_header_id
       AND adj.book_type_code          = stg.book_type_code
       AND adj.distribution_id         = dh.distribution_id
       AND dh.location_id              = loc.location_id
       -- AND dh.assigned_to           = emp.employee_id(+)
       AND lu.lookup_type              = 'JOURNAL ENTRIES'
       AND lu.lookup_code              = adj.source_type_code || ' ' ||
                                         decode (adj.adjustment_type,
                                                 'CIP COST', 'COST',
                                                 adj.adjustment_type)
       AND adj.adjustment_type    not in ('REVAL EXPENSE', 'REVAL AMORT')
       AND nvl(adj.track_member_flag, 'N') = 'N'
       AND adj.adjustment_amount <> 0 
       AND stg.event_type_code        in ('TRANSFERS', 'CIP_TRANSFERS') 
       AND bc.book_type_code  = stg.book_type_code 
       AND bc.set_of_books_id = le.ledger_id 
      AND adj.set_of_books_id = bc.set_of_books_id ;

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

   end load_line_data_xfr;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|    load_line_data_dist                                                        |
|                                                                       |
+======================================================================*/

  PROCEDURE load_line_data_dist IS

     l_procedure_name  varchar2(80) := 'load_line_data_dist';

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
           ENTERED_AMOUNT                       ,
           ADJUSTMENT_LINE_ID,
           ADJUSTMENT_TYPE,
           SOURCE_DEST_CODE,
           ASSET_COST_ACCT,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           CIP_COST_ACCT,
           DEPRN_RESERVE_ACCT,
           IMPAIR_RESERVE_ACCT,
           REVAL_RESERVE_ACCT,
           EXPENSE_ACCOUNT_CCID,
           TRANSACTION_HEADER_ID )
    select /*+ leading(stg) index(adj, FA_ADJUSTMENTS_U1) */ stg.EVENT_ID                            ,
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
           cb.GENERAL_FUND_ACCOUNT_CCID           ,
           decode(adj.adjustment_type,
                  'RESERVE',
                     decode(debit_credit_flag,
                         'DR', adjustment_amount,
                         -1 * adjustment_amount),
                  'BONUS RESERVE',
                     decode(debit_credit_flag,
                         'DR', adjustment_amount,
                         -1 * adjustment_amount),
                  'REVAL RESERVE',
                     decode(debit_credit_flag,
                            'DR', adjustment_amount,
                            -1 * adjustment_amount),
                  'IMPAIR RESERVE',
                     decode(debit_credit_flag,
                            'DR', adjustment_amount,
                            -1 * adjustment_amount),
                  'CAPITAL ADJ',
                     decode(debit_credit_flag,
                            'CR', adjustment_amount,
                            -1 * adjustment_amount),
                  'GENERAL FUND',
                     decode(debit_credit_flag,
                            'DR', adjustment_amount,
                            -1 * adjustment_amount),
                  decode(debit_credit_flag,
                         'CR', adjustment_amount,
                          -1 * adjustment_amount)) ,
           adj.ADJUSTMENT_LINE_ID,
           adj.ADJUSTMENT_TYPE,
           adj.SOURCE_DEST_CODE,
           cb.ASSET_COST_ACCT,
           cb.BONUS_DEPRN_EXPENSE_ACCT,
           cb.BONUS_DEPRN_RESERVE_ACCT,
           cb.CIP_COST_ACCT,
           cb.DEPRN_RESERVE_ACCT,
           cb.IMPAIR_RESERVE_ACCT,
           cb.REVAL_RESERVE_ACCT,
           dh.CODE_COMBINATION_ID,
           stg.TRANSACTION_HEADER_ID
      from fa_xla_ext_lines_stg_gt   stg,
           fa_adjustments            adj,
           fa_distribution_history   dh,
           fa_locations              loc,
           fa_lookups                lu ,
           fa_asset_history          ah,
           fa_category_books         cb 
     WHERE adj.transaction_header_id   = stg.transaction_header_id
       AND adj.book_type_code          = stg.book_type_code
       AND adj.distribution_id         = dh.distribution_id
       AND dh.location_id              = loc.location_id
       -- AND dh.assigned_to           = emp.employee_id(+)
       AND lu.lookup_type              = 'JOURNAL ENTRIES'
       AND lu.lookup_code              = adj.source_type_code || ' ' ||
                                         decode (adj.adjustment_type,
                                                 'CIP COST', 'COST',
                                                 adj.adjustment_type)
       AND adj.adjustment_type    not in ('REVAL EXPENSE', 'REVAL AMORT')
       AND nvl(adj.track_member_flag, 'N') = 'N'
       AND adj.adjustment_amount <> 0 
       AND stg.event_type_code      in ('CATEGORY_RECLASS', 'CIP_CATEGORY_RECLASS',
                                        'UNIT_ADJUSTMENTS', 'CIP_UNIT_ADJUSTMENTS')
       AND adj.asset_id                = ah.asset_id
       AND adj.transaction_header_id   = ah.transaction_header_id_out -- terminated row
       AND cb.category_id              = ah.category_id
       AND cb.book_type_code           = adj.book_type_code
       AND adj.source_dest_code        = 'SOURCE' ;

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
           ENTERED_AMOUNT                       ,
           ADJUSTMENT_LINE_ID,
           ADJUSTMENT_TYPE,
           SOURCE_DEST_CODE,
           ASSET_COST_ACCT,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           CIP_COST_ACCT,
           DEPRN_RESERVE_ACCT,
           IMPAIR_RESERVE_ACCT,
           REVAL_RESERVE_ACCT,
           EXPENSE_ACCOUNT_CCID,
           TRANSACTION_HEADER_ID )
    select /*+ leading(stg) index(adj, FA_MC_ADJUSTMENTS_U1) */ stg.EVENT_ID                            ,
           adj.adjustment_line_id                  ,
           adj.distribution_id                     ,
           stg.distribution_type_code              ,
           bc.set_of_books_id                           ,
           le.currency_code                       ,
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
           cb.GENERAL_FUND_ACCOUNT_CCID           ,
           decode(adj.adjustment_type,
                  'RESERVE',
                     decode(debit_credit_flag,
                         'DR', adjustment_amount,
                         -1 * adjustment_amount),
                  'BONUS RESERVE',
                     decode(debit_credit_flag,
                         'DR', adjustment_amount,
                         -1 * adjustment_amount),
                  'REVAL RESERVE',
                     decode(debit_credit_flag,
                            'DR', adjustment_amount,
                            -1 * adjustment_amount),
                  'IMPAIR RESERVE',
                     decode(debit_credit_flag,
                            'DR', adjustment_amount,
                            -1 * adjustment_amount),
                  'CAPITAL ADJ',
                     decode(debit_credit_flag,
                            'CR', adjustment_amount,
                            -1 * adjustment_amount),
                  'GENERAL FUND',
                     decode(debit_credit_flag,
                            'DR', adjustment_amount,
                            -1 * adjustment_amount),
                  decode(debit_credit_flag,
                         'CR', adjustment_amount,
                          -1 * adjustment_amount)) ,
           adj.ADJUSTMENT_LINE_ID,
           adj.ADJUSTMENT_TYPE,
           adj.SOURCE_DEST_CODE,
           cb.ASSET_COST_ACCT,
           cb.BONUS_DEPRN_EXPENSE_ACCT,
           cb.BONUS_DEPRN_RESERVE_ACCT,
           cb.CIP_COST_ACCT,
           cb.DEPRN_RESERVE_ACCT,
           cb.IMPAIR_RESERVE_ACCT,
           cb.REVAL_RESERVE_ACCT,
           dh.CODE_COMBINATION_ID,
           stg.TRANSACTION_HEADER_ID
      from fa_xla_ext_lines_stg_gt   stg,
           fa_mc_adjustments            adj,
           fa_distribution_history   dh,
           fa_locations              loc,
           fa_lookups                lu ,
           fa_asset_history          ah,
           fa_category_books         cb , 
           fa_mc_book_controls bc , 
           gl_ledgers le 
     WHERE adj.transaction_header_id   = stg.transaction_header_id
       AND adj.book_type_code          = stg.book_type_code
       AND adj.distribution_id         = dh.distribution_id
       AND dh.location_id              = loc.location_id
       -- AND dh.assigned_to           = emp.employee_id(+)
       AND lu.lookup_type              = 'JOURNAL ENTRIES'
       AND lu.lookup_code              = adj.source_type_code || ' ' ||
                                         decode (adj.adjustment_type,
                                                 'CIP COST', 'COST',
                                                 adj.adjustment_type)
       AND adj.adjustment_type    not in ('REVAL EXPENSE', 'REVAL AMORT')
       AND nvl(adj.track_member_flag, 'N') = 'N'
       AND adj.adjustment_amount <> 0 
       AND stg.event_type_code      in ('CATEGORY_RECLASS', 'CIP_CATEGORY_RECLASS',
                                        'UNIT_ADJUSTMENTS', 'CIP_UNIT_ADJUSTMENTS')
       AND adj.asset_id                = ah.asset_id
       AND adj.transaction_header_id   = ah.transaction_header_id_out -- terminated row
       AND cb.category_id              = ah.category_id
       AND cb.book_type_code           = adj.book_type_code
       AND adj.source_dest_code        = 'SOURCE' 
       AND bc.book_type_code  = stg.book_type_code 
       AND bc.set_of_books_id = le.ledger_id 
      AND adj.set_of_books_id = bc.set_of_books_id ;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name,
                        'Rows inserted into alc lines: ' || to_char(SQL%ROWCOUNT));
      END IF;



      end if; 

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
           ENTERED_AMOUNT                       ,
           ADJUSTMENT_LINE_ID,
           ADJUSTMENT_TYPE,
           SOURCE_DEST_CODE,
           EXPENSE_ACCOUNT_CCID,
           ASSET_COST_ACCT,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           CIP_COST_ACCT,
           DEPRN_RESERVE_ACCT,
           IMPAIR_RESERVE_ACCT,
           REVAL_RESERVE_ACCT,
           TRANSACTION_HEADER_ID )
    select /*+ leading(stg) index(adj, FA_ADJUSTMENTS_U1) */ stg.EVENT_ID                            ,
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
           stg.GENERAL_FUND_ACCOUNT_CCID           ,
           decode(adj.adjustment_type,
                  'RESERVE',
                      decode(debit_credit_flag,
                             'CR', adjustment_amount,
                             -1 * adjustment_amount),
                  'BONUS RESERVE',
                      decode(debit_credit_flag,
                             'CR', adjustment_amount,
                             -1 * adjustment_amount),
                  'REVAL RESERVE',
                      decode(debit_credit_flag,
                             'CR', adjustment_amount,
                             -1 * adjustment_amount),
                  'IMPAIR RESERVE',
                     decode(debit_credit_flag,
                            'CR', adjustment_amount,
                            -1 * adjustment_amount),
                  'CAPITAL ADJ',
                     decode(debit_credit_flag,
                            'DR', adjustment_amount,
                            -1 * adjustment_amount),
                  'GENERAL FUND',
                     decode(debit_credit_flag,
                            'CR', adjustment_amount,
                            -1 * adjustment_amount),
                  decode(debit_credit_flag,
                         'DR', adjustment_amount,
                         -1 * adjustment_amount)) ,
           adj.ADJUSTMENT_LINE_ID,
           adj.ADJUSTMENT_TYPE,
           adj.SOURCE_DEST_CODE,
           dh.CODE_COMBINATION_ID,
           stg.ASSET_COST_ACCT,
           stg.BONUS_DEPRN_EXPENSE_ACCT,
           stg.BONUS_RESERVE_ACCT,
           stg.CIP_COST_ACCT,
           stg.DEPRN_RESERVE_ACCT,
           stg.IMPAIR_RESERVE_ACCT,
           stg.REVAL_RESERVE_ACCT,
           stg.TRANSACTION_HEADER_ID
      from fa_xla_ext_lines_stg_gt   stg,
           fa_adjustments            adj,
           fa_distribution_history   dh,
           fa_locations              loc,
           fa_lookups                lu 
     WHERE adj.transaction_header_id   = stg.transaction_header_id
       AND adj.book_type_code          = stg.book_type_code
       AND adj.distribution_id         = dh.distribution_id
       AND dh.location_id              = loc.location_id
       -- AND dh.assigned_to           = emp.employee_id(+)
       AND lu.lookup_type              = 'JOURNAL ENTRIES'
       AND lu.lookup_code              = adj.source_type_code || ' ' ||
                                         decode (adj.adjustment_type,
                                                 'CIP COST', 'COST',
                                                 adj.adjustment_type)
       AND adj.adjustment_type    not in ('REVAL EXPENSE', 'REVAL AMORT')
       AND nvl(adj.track_member_flag, 'N') = 'N'
       AND adj.adjustment_amount <> 0 
       AND stg.event_type_code       in ('CATEGORY_RECLASS', 'CIP_CATEGORY_RECLASS',
                                         'UNIT_ADJUSTMENTS', 'CIP_UNIT_ADJUSTMENTS')
       AND adj.source_dest_code        = 'DEST' ;

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
           ENTERED_AMOUNT                       ,
           ADJUSTMENT_LINE_ID,
           ADJUSTMENT_TYPE,
           SOURCE_DEST_CODE,
           EXPENSE_ACCOUNT_CCID,
           ASSET_COST_ACCT,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           CIP_COST_ACCT,
           DEPRN_RESERVE_ACCT,
           IMPAIR_RESERVE_ACCT,
           REVAL_RESERVE_ACCT,
           TRANSACTION_HEADER_ID )
    select /*+ leading(stg) index(adj, FA_MC_ADJUSTMENTS_U1) */ stg.EVENT_ID                            ,
           adj.adjustment_line_id                  ,
           adj.distribution_id                     ,
           stg.distribution_type_code              ,
           bc.set_of_books_id                           ,
           le.currency_code                       ,
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
           stg.GENERAL_FUND_ACCOUNT_CCID           ,
           decode(adj.adjustment_type,
                  'RESERVE',
                      decode(debit_credit_flag,
                             'CR', adjustment_amount,
                             -1 * adjustment_amount),
                  'BONUS RESERVE',
                      decode(debit_credit_flag,
                             'CR', adjustment_amount,
                             -1 * adjustment_amount),
                  'REVAL RESERVE',
                      decode(debit_credit_flag,
                             'CR', adjustment_amount,
                             -1 * adjustment_amount),
                  'IMPAIR RESERVE',
                     decode(debit_credit_flag,
                            'CR', adjustment_amount,
                            -1 * adjustment_amount),
                  'CAPITAL ADJ',
                     decode(debit_credit_flag,
                            'DR', adjustment_amount,
                            -1 * adjustment_amount),
                  'GENERAL FUND',
                     decode(debit_credit_flag,
                            'CR', adjustment_amount,
                            -1 * adjustment_amount),
                  decode(debit_credit_flag,
                         'DR', adjustment_amount,
                         -1 * adjustment_amount)) ,
           adj.ADJUSTMENT_LINE_ID,
           adj.ADJUSTMENT_TYPE,
           adj.SOURCE_DEST_CODE,
           dh.CODE_COMBINATION_ID,
           stg.ASSET_COST_ACCT,
           stg.BONUS_DEPRN_EXPENSE_ACCT,
           stg.BONUS_RESERVE_ACCT,
           stg.CIP_COST_ACCT,
           stg.DEPRN_RESERVE_ACCT,
           stg.IMPAIR_RESERVE_ACCT,
           stg.REVAL_RESERVE_ACCT,
           stg.TRANSACTION_HEADER_ID
      from fa_xla_ext_lines_stg_gt   stg,
           fa_mc_adjustments            adj,
           fa_distribution_history   dh,
           fa_locations              loc,
           fa_lookups                lu , 
           fa_mc_book_controls bc , 
           gl_ledgers le 
     WHERE adj.transaction_header_id   = stg.transaction_header_id
       AND adj.book_type_code          = stg.book_type_code
       AND adj.distribution_id         = dh.distribution_id
       AND dh.location_id              = loc.location_id
       -- AND dh.assigned_to           = emp.employee_id(+)
       AND lu.lookup_type              = 'JOURNAL ENTRIES'
       AND lu.lookup_code              = adj.source_type_code || ' ' ||
                                         decode (adj.adjustment_type,
                                                 'CIP COST', 'COST',
                                                 adj.adjustment_type)
       AND adj.adjustment_type    not in ('REVAL EXPENSE', 'REVAL AMORT')
       AND nvl(adj.track_member_flag, 'N') = 'N'
       AND adj.adjustment_amount <> 0 
       AND stg.event_type_code       in ('CATEGORY_RECLASS', 'CIP_CATEGORY_RECLASS',
                                         'UNIT_ADJUSTMENTS', 'CIP_UNIT_ADJUSTMENTS')
       AND adj.source_dest_code        = 'DEST' 
       AND bc.book_type_code  = stg.book_type_code 
       AND bc.set_of_books_id = le.ledger_id 
      AND adj.set_of_books_id = bc.set_of_books_id ;

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

   end load_line_data_dist;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|    load_line_data_ret                                                        |
|                                                                       |
+======================================================================*/

  PROCEDURE load_line_data_ret IS

     l_procedure_name  varchar2(80) := 'load_line_data_ret';

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
           ENTERED_AMOUNT                       ,
           ADJUSTMENT_LINE_ID,
           ADJUSTMENT_TYPE,
           EXPENSE_ACCOUNT_CCID,
           GAIN_LOSS_AMOUNT,
           ASSET_COST_ACCT,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           CIP_COST_ACCT,
           DEPRN_RESERVE_ACCT,
           IMPAIR_RESERVE_ACCT,
           REVAL_RESERVE_ACCT,
           TRANSACTION_HEADER_ID )
    select /*+ leading(stg) index(adj, FA_ADJUSTMENTS_U1) */ stg.EVENT_ID                            ,
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
           stg.GENERAL_FUND_ACCOUNT_CCID           ,
           decode(adj.adjustment_type,
                  'RESERVE',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'BONUS RESERVE',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'REVAL RESERVE',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'NBV RETIRED',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'PROCEEDS CLR',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'REMOVALCOST',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'IMPAIR RESERVE',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'CAPITAL ADJ',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'GENERAL FUND',
                      decode(debit_credit_flag,
                             'CR', adjustment_amount,
                             -1 * adjustment_amount),
                  decode(debit_credit_flag,
                         'CR', adjustment_amount,
                          -1 * adjustment_amount))  ,
           adj.ADJUSTMENT_LINE_ID,
           adj.ADJUSTMENT_TYPE,
           dh.CODE_COMBINATION_ID,
           ret.GAIN_LOSS_AMOUNT,
           stg.ASSET_COST_ACCT,
           stg.BONUS_DEPRN_EXPENSE_ACCT,
           stg.BONUS_RESERVE_ACCT,
           stg.CIP_COST_ACCT,
           stg.DEPRN_RESERVE_ACCT,
           stg.IMPAIR_RESERVE_ACCT,
           stg.REVAL_RESERVE_ACCT,
           stg.TRANSACTION_HEADER_ID
      from fa_xla_ext_lines_stg_gt   stg,
           fa_adjustments            adj,
           fa_distribution_history   dh,
           fa_locations              loc,
           fa_lookups                lu ,
           fa_retirements            ret 
     WHERE adj.transaction_header_id   = stg.transaction_header_id
       AND adj.book_type_code          = stg.book_type_code
       AND adj.distribution_id         = dh.distribution_id
       AND dh.location_id              = loc.location_id
       -- AND dh.assigned_to           = emp.employee_id(+)
       AND lu.lookup_type              = 'JOURNAL ENTRIES'
       AND lu.lookup_code              = adj.source_type_code || ' ' ||
                                         decode (adj.adjustment_type,
                                                 'CIP COST', 'COST',
                                                 adj.adjustment_type)
       AND adj.adjustment_type    not in ('REVAL EXPENSE', 'REVAL AMORT')
       AND nvl(adj.track_member_flag, 'N') = 'N'
       AND adj.adjustment_amount <> 0 
       AND stg.event_type_code          in ('RETIREMENTS', 'CIP_RETIREMENTS')
       AND ret.transaction_header_id_in  = stg.member_transaction_header_id ;

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
           ENTERED_AMOUNT                       ,
           ADJUSTMENT_LINE_ID,
           ADJUSTMENT_TYPE,
           EXPENSE_ACCOUNT_CCID,
           GAIN_LOSS_AMOUNT,
           ASSET_COST_ACCT,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           CIP_COST_ACCT,
           DEPRN_RESERVE_ACCT,
           IMPAIR_RESERVE_ACCT,
           REVAL_RESERVE_ACCT,
           TRANSACTION_HEADER_ID )
    select /*+ leading(stg) index(adj, FA_MC_ADJUSTMENTS_U1) */ stg.EVENT_ID                            ,
           adj.adjustment_line_id                  ,
           adj.distribution_id                     ,
           stg.distribution_type_code              ,
           bc.set_of_books_id                           ,
           le.currency_code                       ,
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
           stg.GENERAL_FUND_ACCOUNT_CCID           ,
           decode(adj.adjustment_type,
                  'RESERVE',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'BONUS RESERVE',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'REVAL RESERVE',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'NBV RETIRED',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'PROCEEDS CLR',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'REMOVALCOST',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'IMPAIR RESERVE',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'CAPITAL ADJ',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'GENERAL FUND',
                      decode(debit_credit_flag,
                             'CR', adjustment_amount,
                             -1 * adjustment_amount),
                  decode(debit_credit_flag,
                         'CR', adjustment_amount,
                          -1 * adjustment_amount))  ,
           adj.ADJUSTMENT_LINE_ID,
           adj.ADJUSTMENT_TYPE,
           dh.CODE_COMBINATION_ID,
           ret.GAIN_LOSS_AMOUNT,
           stg.ASSET_COST_ACCT,
           stg.BONUS_DEPRN_EXPENSE_ACCT,
           stg.BONUS_RESERVE_ACCT,
           stg.CIP_COST_ACCT,
           stg.DEPRN_RESERVE_ACCT,
           stg.IMPAIR_RESERVE_ACCT,
           stg.REVAL_RESERVE_ACCT,
           stg.TRANSACTION_HEADER_ID
      from fa_xla_ext_lines_stg_gt   stg,
           fa_mc_adjustments            adj,
           fa_distribution_history   dh,
           fa_locations              loc,
           fa_lookups                lu ,
           fa_retirements            ret , 
           fa_mc_book_controls bc , 
           gl_ledgers le 
     WHERE adj.transaction_header_id   = stg.transaction_header_id
       AND adj.book_type_code          = stg.book_type_code
       AND adj.distribution_id         = dh.distribution_id
       AND dh.location_id              = loc.location_id
       -- AND dh.assigned_to           = emp.employee_id(+)
       AND lu.lookup_type              = 'JOURNAL ENTRIES'
       AND lu.lookup_code              = adj.source_type_code || ' ' ||
                                         decode (adj.adjustment_type,
                                                 'CIP COST', 'COST',
                                                 adj.adjustment_type)
       AND adj.adjustment_type    not in ('REVAL EXPENSE', 'REVAL AMORT')
       AND nvl(adj.track_member_flag, 'N') = 'N'
       AND adj.adjustment_amount <> 0 
       AND stg.event_type_code          in ('RETIREMENTS', 'CIP_RETIREMENTS')
       AND ret.transaction_header_id_in  = stg.member_transaction_header_id 
       AND bc.book_type_code  = stg.book_type_code 
       AND bc.set_of_books_id = le.ledger_id 
      AND adj.set_of_books_id = bc.set_of_books_id ;

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

   end load_line_data_ret;



/*======================================================================+
|                                                                       |
| Private Function                                                      |
|    load_line_data_res                                                        |
|                                                                       |
+======================================================================*/

  PROCEDURE load_line_data_res IS

     l_procedure_name  varchar2(80) := 'load_line_data_res';

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
           ENTERED_AMOUNT                       ,
           ADJUSTMENT_LINE_ID,
           ADJUSTMENT_TYPE,
           EXPENSE_ACCOUNT_CCID,
           GAIN_LOSS_AMOUNT,
           ASSET_COST_ACCT,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           CIP_COST_ACCT,
           DEPRN_RESERVE_ACCT,
           IMPAIR_RESERVE_ACCT,
           REVAL_RESERVE_ACCT,
           TRANSACTION_HEADER_ID )
    select /*+ leading(stg) index(adj, FA_ADJUSTMENTS_U1) */ stg.EVENT_ID                            ,
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
           stg.GENERAL_FUND_ACCOUNT_CCID           ,
           decode(adj.adjustment_type,
                  'RESERVE',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'BONUS RESERVE',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'REVAL RESERVE',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'NBV RETIRED',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'PROCEEDS CLR',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'REMOVALCOST',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'IMPAIR RESERVE',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'CAPITAL ADJ',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'GENERAL FUND',
                      decode(debit_credit_flag,
                             'CR', adjustment_amount,
                             -1 * adjustment_amount),
                  decode(debit_credit_flag,
                         'CR', adjustment_amount,
                          -1 * adjustment_amount))  ,
           adj.ADJUSTMENT_LINE_ID,
           adj.ADJUSTMENT_TYPE,
           dh.CODE_COMBINATION_ID,
           ret.GAIN_LOSS_AMOUNT,
           stg.ASSET_COST_ACCT,
           stg.BONUS_DEPRN_EXPENSE_ACCT,
           stg.BONUS_RESERVE_ACCT,
           stg.CIP_COST_ACCT,
           stg.DEPRN_RESERVE_ACCT,
           stg.IMPAIR_RESERVE_ACCT,
           stg.REVAL_RESERVE_ACCT,
           stg.TRANSACTION_HEADER_ID
      from fa_xla_ext_lines_stg_gt   stg,
           fa_adjustments            adj,
           fa_distribution_history   dh,
           fa_locations              loc,
           fa_lookups                lu ,
           fa_retirements            ret 
     WHERE adj.transaction_header_id   = stg.transaction_header_id
       AND adj.book_type_code          = stg.book_type_code
       AND adj.distribution_id         = dh.distribution_id
       AND dh.location_id              = loc.location_id
       -- AND dh.assigned_to           = emp.employee_id(+)
       AND lu.lookup_type              = 'JOURNAL ENTRIES'
       AND lu.lookup_code              = adj.source_type_code || ' ' ||
                                         decode (adj.adjustment_type,
                                                 'CIP COST', 'COST',
                                                 adj.adjustment_type)
       AND adj.adjustment_type    not in ('REVAL EXPENSE', 'REVAL AMORT')
       AND nvl(adj.track_member_flag, 'N') = 'N'
       AND adj.adjustment_amount <> 0 
       AND stg.event_type_code          in ('REINSTATEMENTS','CIP_REINSTATEMENTS')
       AND ret.transaction_header_id_out = stg.member_transaction_header_id ;

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
           ENTERED_AMOUNT                       ,
           ADJUSTMENT_LINE_ID,
           ADJUSTMENT_TYPE,
           EXPENSE_ACCOUNT_CCID,
           GAIN_LOSS_AMOUNT,
           ASSET_COST_ACCT,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           CIP_COST_ACCT,
           DEPRN_RESERVE_ACCT,
           IMPAIR_RESERVE_ACCT,
           REVAL_RESERVE_ACCT,
           TRANSACTION_HEADER_ID )
    select /*+ leading(stg) index(adj, FA_MC_ADJUSTMENTS_U1) */ stg.EVENT_ID                            ,
           adj.adjustment_line_id                  ,
           adj.distribution_id                     ,
           stg.distribution_type_code              ,
           bc.set_of_books_id                           ,
           le.currency_code                       ,
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
           stg.GENERAL_FUND_ACCOUNT_CCID           ,
           decode(adj.adjustment_type,
                  'RESERVE',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'BONUS RESERVE',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'REVAL RESERVE',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'NBV RETIRED',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'PROCEEDS CLR',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'REMOVALCOST',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'IMPAIR RESERVE',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'CAPITAL ADJ',
                      decode(debit_credit_flag,
                             'DR', adjustment_amount,
                             -1 * adjustment_amount),
                  'GENERAL FUND',
                      decode(debit_credit_flag,
                             'CR', adjustment_amount,
                             -1 * adjustment_amount),
                  decode(debit_credit_flag,
                         'CR', adjustment_amount,
                          -1 * adjustment_amount))  ,
           adj.ADJUSTMENT_LINE_ID,
           adj.ADJUSTMENT_TYPE,
           dh.CODE_COMBINATION_ID,
           ret.GAIN_LOSS_AMOUNT,
           stg.ASSET_COST_ACCT,
           stg.BONUS_DEPRN_EXPENSE_ACCT,
           stg.BONUS_RESERVE_ACCT,
           stg.CIP_COST_ACCT,
           stg.DEPRN_RESERVE_ACCT,
           stg.IMPAIR_RESERVE_ACCT,
           stg.REVAL_RESERVE_ACCT,
           stg.TRANSACTION_HEADER_ID
      from fa_xla_ext_lines_stg_gt   stg,
           fa_mc_adjustments            adj,
           fa_distribution_history   dh,
           fa_locations              loc,
           fa_lookups                lu ,
           fa_retirements            ret , 
           fa_mc_book_controls bc , 
           gl_ledgers le 
     WHERE adj.transaction_header_id   = stg.transaction_header_id
       AND adj.book_type_code          = stg.book_type_code
       AND adj.distribution_id         = dh.distribution_id
       AND dh.location_id              = loc.location_id
       -- AND dh.assigned_to           = emp.employee_id(+)
       AND lu.lookup_type              = 'JOURNAL ENTRIES'
       AND lu.lookup_code              = adj.source_type_code || ' ' ||
                                         decode (adj.adjustment_type,
                                                 'CIP COST', 'COST',
                                                 adj.adjustment_type)
       AND adj.adjustment_type    not in ('REVAL EXPENSE', 'REVAL AMORT')
       AND nvl(adj.track_member_flag, 'N') = 'N'
       AND adj.adjustment_amount <> 0 
       AND stg.event_type_code          in ('REINSTATEMENTS','CIP_REINSTATEMENTS')
       AND ret.transaction_header_id_out = stg.member_transaction_header_id 
       AND bc.book_type_code  = stg.book_type_code 
       AND bc.set_of_books_id = le.ledger_id 
      AND adj.set_of_books_id = bc.set_of_books_id ;

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

   end load_line_data_res;



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





      -- bug 5563601: Increased length of variable account_type to 50
      type adj_rec_type is record
           (rowid                       VARCHAR2(64),
            book_type_code              VARCHAR2(30),
            distribution_id             NUMBER(15),
            distribution_ccid           NUMBER(15),
            entered_amount              NUMBER,
            account_type                VARCHAR2(50),
            generated_ccid              NUMBER(15),
            account_ccid                NUMBER(15),
            account_segment             VARCHAR2(25),
            offset_account_type         VARCHAR2(25),
            generated_offset_ccid       NUMBER(15),
            offset_account_ccid         NUMBER(15),
            offset_account_segment      VARCHAR2(25),
            counter_account_type        VARCHAR2(50),   -- Bug 6962827:
            counter_generated_ccid      NUMBER(15),     -- Bug 6962827:
            counter_account_ccid        NUMBER(15),     -- Bug 6962827:
            counter_account_segment     VARCHAR2(25),   -- Bug 6962827:
            counter_generated_offset_ccid NUMBER(15),   -- Bug 6962827:
            counter_offset_account_ccid NUMBER(15),     -- Bug 6962827:
            counter_offset_account_segment VARCHAR2(25) -- Bug 6962827:
           );

      type adj_tbl_type is table of adj_rec_type index by binary_integer;

      l_adj_tbl adj_tbl_type;

      l_generated_ccid              num_tab_type;
      l_generated_offset_ccid       num_tab_type;
      l_rowid                       char_tab_type;
      l_counter_generated_ccid      num_tab_type;  -- Bug 6962827:
      l_ctr_generated_off_ccid      num_tab_type;  -- Bug 6962827:

      error_found                   exception;

      l_last_book    varchar2(30) := ' ';

      cursor c_trx is
      select /*+ leading(xg) index(xb, FA_XLA_EXT_HEADERS_B_GT_U1) index(xl, FA_XLA_EXT_LINES_B_GT_U1) */
             xl.rowid,
             xb.book_type_code,
             xl.distribution_id,
             xl.expense_account_ccid,
             xl.entered_amount,
             decode
             (adjustment_type,
              'COST',            'ASSET_COST_ACCT',
              'CIP COST',        'CIP_COST_ACCT',
              'COST CLEARING',   decode(xl.asset_type,
                                        'CIP', 'CIP_CLEARING_ACCT',
                                                 'ASSET_CLEARING_ACCT'),
              'EXPENSE',         'DEPRN_EXPENSE_ACCT',
              'RESERVE',         'DEPRN_RESERVE_ACCT',
              'BONUS EXPENSE',   'BONUS_DEPRN_EXPENSE_ACCT',
              'BONUS RESERVE',   'BONUS_DEPRN_RESERVE_ACCT',
              'REVAL RESERVE',   'REVAL_RESERVE_ACCT',
              'CAPITAL ADJ',     'CAPITAL_ADJ_ACCT',
              'GENERAL FUND',    'GENERAL_FUND_ACCT',
              'IMPAIR EXPENSE',  'IMPAIR_EXPENSE_ACCT',
              'IMPAIR RESERVE',  'IMPAIR_RESERVE_ACCT',
              'LINK IMPAIR EXP', 'IMPAIR_EXPENSE_ACCT',
              'DEPRN ADJUST',    'DEPRN_ADJUSTMENT_ACCT',
              'PROCEEDS CLR',    'PROCEEDS_OF_SALE_CLEARING_ACCT',
              'REMOVALCOST CLR', 'COST_OF_REMOVAL_CLEARING_ACCT',
              'REMOVALCOST',     decode(sign(gain_loss_amount),
                                        -1, 'COST_OF_REMOVAL_LOSS_ACCT',
                                            'COST_OF_REMOVAL_GAIN_ACCT'),
              'PROCEEDS',        decode(sign(gain_loss_amount),
                                        -1, 'PROCEEDS_OF_SALE_LOSS_ACCT',
                                            'PROCEEDS_OF_SALE_GAIN_ACCT'),
              'REVAL RSV RET',   decode(sign(gain_loss_amount),
                                        -1, 'REVAL_RSV_RETIRED_LOSS_ACCT',
                                            'REVAL_RSV_RETIRED_GAIN_ACCT'),
              'NBV RETIRED',     decode(asset_type,
                                        'GROUP', decode(sign(gain_loss_amount),
                                                        -1, 'NBV_RETIRED_LOSS_ACCT',
                                                            'NBV_RETIRED_GAIN_ACCT'),
                                        decode(sign(gain_loss_amount),
                                               -1, 'NBV_RETIRED_LOSS_ACCT',
                                                   'NBV_RETIRED_GAIN_ACCT')),
              NULL),
             decode(xl.adjustment_type,
              'COST',             nvl(xl.generated_ccid, da.ASSET_COST_ACCOUNT_CCID),
              'CIP COST',         nvl(xl.generated_ccid, da.CIP_COST_ACCOUNT_CCID),
              'COST CLEARING',    decode(xl.asset_type,
                                         'CIP', nvl(xl.generated_ccid, da.CIP_CLEARING_ACCOUNT_CCID),
                                                  nvl(xl.generated_ccid, da.ASSET_CLEARING_ACCOUNT_CCID)),
              'EXPENSE',          nvl(xl.generated_ccid, da.DEPRN_EXPENSE_ACCOUNT_CCID),
              'RESERVE',          nvl(xl.generated_ccid, da.DEPRN_RESERVE_ACCOUNT_CCID),
              'BONUS EXPENSE',    nvl(xl.generated_ccid, da.BONUS_EXP_ACCOUNT_CCID),
              'BONUS RESERVE',    nvl(xl.generated_ccid, da.BONUS_RSV_ACCOUNT_CCID),
              'REVAL RESERVE',    nvl(xl.generated_ccid, da.REVAL_RSV_ACCOUNT_CCID),
              'CAPITAL ADJ',      nvl(xl.generated_ccid, da.CAPITAL_ADJ_ACCOUNT_CCID),
              'GENERAL FUND',     nvl(xl.generated_ccid, da.GENERAL_FUND_ACCOUNT_CCID),
              'IMPAIR EXPENSE',   nvl(xl.generated_ccid, da.IMPAIR_EXPENSE_ACCOUNT_CCID),
              'IMPAIR RESERVE',   nvl(xl.generated_ccid, da.IMPAIR_RESERVE_ACCOUNT_CCID),
              'LINK IMPAIR EXP',  nvl(xl.generated_ccid, da.IMPAIR_EXPENSE_ACCOUNT_CCID),
              'DEPRN ADJUST',     nvl(xl.generated_ccid, da.DEPRN_ADJ_ACCOUNT_CCID),
              'PROCEEDS CLR',     nvl(xl.generated_ccid, da.PROCEEDS_SALE_CLEARING_CCID),
              'REMOVALCOST CLR',  nvl(xl.generated_ccid, da.COST_REMOVAL_CLEARING_CCID),
              'PROCEEDS',         decode(sign(xl.gain_loss_amount),
                                         -1, nvl(xl.generated_ccid, da.PROCEEDS_SALE_LOSS_CCID),
                                             nvl(xl.generated_ccid, da.PROCEEDS_SALE_GAIN_CCID)),
              'REMOVALCOST',      decode(sign(xl.gain_loss_amount),
                                         -1, nvl(xl.generated_ccid, da.COST_REMOVAL_LOSS_CCID),
                                             nvl(xl.generated_ccid, da.COST_REMOVAL_GAIN_CCID)),
              'REVAL RSV RET',    decode(sign(xl.gain_loss_amount),
                                         -1, nvl(xl.generated_ccid, da.REVAL_RSV_LOSS_ACCOUNT_CCID),
                                             nvl(xl.generated_ccid, da.REVAL_RSV_GAIN_ACCOUNT_CCID)),
              'NBV RETIRED',      decode(sign(xl.gain_loss_amount),
                                         -1, nvl(xl.generated_ccid, da.NBV_RETIRED_LOSS_CCID),
                                             nvl(xl.generated_ccid, da.NBV_RETIRED_GAIN_CCID)),
              NULL),
             decode(xl.adjustment_type,
              'COST',             xl.ASSET_COST_ACCOUNT_CCID,
              'CIP COST',         xl.CIP_COST_ACCOUNT_CCID,
              'COST CLEARING',    decode(xl.asset_type,
                                         'CIP', xl.CIP_CLEARING_ACCOUNT_CCID,
                                                  xl.ASSET_CLEARING_ACCOUNT_CCID),
              'RESERVE',          xl.RESERVE_ACCOUNT_CCID,
              'BONUS RESERVE',    xl.BONUS_RESERVE_ACCT_CCID,
              'REVAL RESERVE',    xl.REVAL_RESERVE_ACCOUNT_CCID,
              'CAPITAL ADJ',      xl.CAPITAL_ADJ_ACCOUNT_CCID,
              'GENERAL FUND',     xl.GENERAL_FUND_ACCOUNT_CCID,
              'IMPAIR EXPENSE',   xl.IMPAIR_EXPENSE_ACCOUNT_CCID,
              'IMPAIR RESERVE',   xl.IMPAIR_RESERVE_ACCOUNT_CCID,
              'LINK IMPAIR EXP',  xl.IMPAIR_EXPENSE_ACCOUNT_CCID,
              0),
             decode(xl.adjustment_type,
              'COST',             xl.ASSET_COST_ACCT,
              'CIP COST',         xl.CIP_COST_ACCT,
              'COST CLEARING',    decode(xl.asset_type,
                                         'CIP', xl.CIP_CLEARING_ACCT,
                                                  xl.ASSET_CLEARING_ACCT),
              'EXPENSE',          xl.DEPRN_EXPENSE_ACCT,
              'RESERVE',          xl.DEPRN_RESERVE_ACCT,
              'BONUS EXPENSE',    xl.BONUS_DEPRN_EXPENSE_ACCT,
              'BONUS RESERVE',    xl.BONUS_RESERVE_ACCT,
              'REVAL RESERVE',    xl.REVAL_RESERVE_ACCT,
              'CAPITAL ADJ',      xl.CAPITAL_ADJ_ACCT,
              'GENERAL FUND',     xl.GENERAL_FUND_ACCT,
              'IMPAIR EXPENSE',   xl.IMPAIR_EXPENSE_ACCT,
              'IMPAIR RESERVE',   xl.IMPAIR_RESERVE_ACCT,
              'LINK IMPAIR EXP',  xl.IMPAIR_EXPENSE_ACCT,
              'PROCEEDS CLR',     xb.PROCEEDS_OF_SALE_CLEARING_ACCT,
              'REMOVALCOST CLR',  xb.COST_OF_REMOVAL_CLEARING_ACCT,
              'NBV RETIRED',      decode(sign(xl.gain_loss_amount),
                                          -1, xb.NBV_RETIRED_LOSS_ACCT,
                                              xb.NBV_RETIRED_GAIN_ACCT),
              'PROCEEDS',         decode(sign(xl.gain_loss_amount),
                                          -1, xb.PROCEEDS_OF_SALE_LOSS_ACCT,
                                              xb.PROCEEDS_OF_SALE_GAIN_ACCT),
              'REMOVALCOST',      decode(sign(xl.gain_loss_amount),
                                          -1, xb.COST_OF_REMOVAL_LOSS_ACCT,
                                              xb.COST_OF_REMOVAL_GAIN_ACCT),
              'REVAL RSV RET',    decode(sign(xl.gain_loss_amount),
                                          -1, xb.REVAL_RSV_RETIRED_LOSS_ACCT,
                                              xb.REVAL_RSV_RETIRED_GAIN_ACCT),
              NULL),
             decode(xl.adjustment_type,
              'EXPENSE',       'DEPRN_RESERVE_ACCT',
              'BONUS EXPENSE', 'BONUS_DEPRN_RESERVE_ACCT',
              NULL),
             decode(xl.adjustment_type,
              'EXPENSE',       da.DEPRN_RESERVE_ACCOUNT_CCID,
              'BONUS EXPENSE', da.BONUS_RSV_ACCOUNT_CCID,
              NULL),
             decode(xl.adjustment_type,
              'EXPENSE',       xl.RESERVE_ACCOUNT_CCID,
              'BONUS EXPENSE', xl.BONUS_RESERVE_ACCT_CCID,
              NULL),
             decode(xl.adjustment_type,
              'EXPENSE',       xl.DEPRN_RESERVE_ACCT,
              'BONUS EXPENSE', xl.BONUS_RESERVE_ACCT,
              NULL),
             -- Bug 6962827: counter_account_type
             decode(adjustment_type,
              'BONUS EXPENSE',         'DEPRN_EXPENSE_ACCT',
              'BONUS RESERVE',         'DEPRN_RESERVE_ACCT',
              NULL),
             -- Bug 6962827: counter_generated_ccid
             decode(xl.adjustment_type,
              'BONUS EXPENSE', da.DEPRN_EXPENSE_ACCOUNT_CCID,
              'BONUS RESERVE', da.DEPRN_RESERVE_ACCOUNT_CCID,
              NULL),
              -- Bug 6962827 : counter_account_ccid
             decode(xl.adjustment_type,
              'BONUS RESERVE', xl.RESERVE_ACCOUNT_CCID,
              0),
              -- Bug 6962827 : counter_account_segment
             decode(xl.adjustment_type,
              'BONUS EXPENSE', xl.DEPRN_EXPENSE_ACCT,
              'BONUS RESERVE', xl.DEPRN_RESERVE_ACCT,
              NULL),
             -- Bug 6962827 : counter_generated_offset_ccid
             decode(xl.adjustment_type,
              'BONUS EXPENSE', da.DEPRN_RESERVE_ACCOUNT_CCID,
              NULL),
              -- Bug 6962827 : counter_offset_account_ccid
             decode(xl.adjustment_type,
              'BONUS EXPENSE', xl.RESERVE_ACCOUNT_CCID,
              NULL),
              -- Bug 6962827 : counter_offset_account_segment
             decode(xl.adjustment_type,
              'BONUS EXPENSE', xl.DEPRN_RESERVE_ACCT,
              NULL)
        from xla_events_gt            xg,
             fa_xla_ext_headers_b_gt  xb,
             fa_xla_ext_lines_b_gt    xl,
             fa_distribution_accounts da
       where xg.event_class_code     not in ('DEPRECIATION', 'DEFERRED')
         and xb.event_id        = xg.event_id
         and xl.event_id        = xg.event_id
         and xl.distribution_id = da.distribution_id(+)
         and xl.book_type_code  = da.book_type_code(+);


   BEGIN

      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name||'.begin',
                        'Beginning of procedure');
      END IF;


      open  c_trx;
      fetch c_trx
       bulk collect into l_adj_tbl;
      close c_trx;

      for i in 1..l_adj_tbl.count loop

         if (l_last_book <> l_adj_tbl(i).book_type_code or
             i = 1) then
            if not (fa_cache_pkg.fazcbc
                      (X_BOOK => l_adj_tbl(1).book_type_code,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then
               null;
            end if;
            l_last_book := l_adj_tbl(i).book_type_code;
         end if;

         -- call FAFBGCC if the ccid doesnt exist in distribution accounts

         if (l_adj_tbl(i).generated_ccid is null and
             l_adj_tbl(i).entered_amount   <> 0) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_adj_tbl(i).book_type_code,
                       X_fn_trx_code     => l_adj_tbl(i).account_type,
                       X_dist_ccid       => l_adj_tbl(i).distribution_ccid,
                       X_acct_segval     => l_adj_tbl(i).account_segment,
                       X_account_ccid    => l_adj_tbl(i).account_ccid,
                       X_distribution_id => l_adj_tbl(i).distribution_id,
                       X_rtn_ccid        => l_adj_tbl(i).generated_ccid,
                       P_LOG_LEVEL_REC => p_log_level_rec)) then
               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => 'FA_GET_ACCOUNT_CCID',
                   CALLING_FN => 'FA_INS_ADJUST_PKG.fadoflx',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_adj_tbl(i).generated_ccid := -1;
            end if;
         end if;

         if (l_adj_tbl(i).account_type in
              ('DEPRN_EXPENSE_ACCT', 'BONUS_DEPRN_EXPENSE_ACCT') and
             l_adj_tbl(i).generated_offset_ccid is null and
             l_adj_tbl(i).entered_amount <> 0) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_adj_tbl(i).book_type_code,
                       X_fn_trx_code     => l_adj_tbl(i).offset_account_type,
                       X_dist_ccid       => l_adj_tbl(i).distribution_ccid,
                       X_acct_segval     => l_adj_tbl(i).offset_account_segment,
                       X_account_ccid    => l_adj_tbl(i).offset_account_ccid,
                       X_distribution_id => l_adj_tbl(i).distribution_id,
                       X_rtn_ccid        => l_adj_tbl(i).generated_offset_ccid,
                       P_LOG_LEVEL_REC => p_log_level_rec)) then
               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => 'FA_GET_ACCOUNT_CCID',
                   CALLING_FN => 'FA_INS_ADJUST_PKG.fadoflx',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_adj_tbl(i).generated_offset_ccid := -1;
            end if;
         end if;

         -- Bug 6962827 start
         -- Populate counter_generated_ccid with the Expense acct for
         -- Bonus expense and with Reserve acct for Bonus Reserve lines.
         if (l_adj_tbl(i).account_type in ('BONUS_DEPRN_EXPENSE_ACCT','BONUS_DEPRN_RESERVE_ACCT') and
             l_adj_tbl(i).counter_generated_ccid is null and
             l_adj_tbl(i).entered_amount   <> 0) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_adj_tbl(i).book_type_code,
                       X_fn_trx_code     => l_adj_tbl(i).counter_account_type,
                       X_dist_ccid       => l_adj_tbl(i).distribution_ccid,
                       X_acct_segval     => l_adj_tbl(i).counter_account_segment,
                       X_account_ccid    => l_adj_tbl(i).counter_account_ccid,
                       X_distribution_id => l_adj_tbl(i).distribution_id,
                       X_rtn_ccid        => l_adj_tbl(i).counter_generated_ccid,
                       P_LOG_LEVEL_REC => p_log_level_rec)) then
               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => 'FA_GET_ACCOUNT_CCID',
                   CALLING_FN => 'FA_INS_ADJUST_PKG.fadoflx',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_adj_tbl(i).counter_generated_ccid := -1;
            end if;

         end if;

         -- Populate counter_generated_offset_ccid with the Reserve acct
         -- for Bonus expense lines.
         if (l_adj_tbl(i).account_type = 'BONUS_DEPRN_EXPENSE_ACCT' and
             l_adj_tbl(i).counter_generated_offset_ccid is null and
             l_adj_tbl(i).entered_amount   <> 0) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_adj_tbl(i).book_type_code,
                       X_fn_trx_code     => 'DEPRN_RESERVE_ACCT',
                       X_dist_ccid       => l_adj_tbl(i).distribution_ccid,
                       X_acct_segval     => l_adj_tbl(i).counter_offset_account_segment,
                       X_account_ccid    => l_adj_tbl(i).counter_offset_account_ccid,
                       X_distribution_id => l_adj_tbl(i).distribution_id,
                       X_rtn_ccid        => l_adj_tbl(i).counter_generated_offset_ccid,
                       P_LOG_LEVEL_REC => p_log_level_rec)) then
               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => 'FA_GET_ACCOUNT_CCID',
                   CALLING_FN => 'FA_INS_ADJUST_PKG.fadoflx',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_adj_tbl(i).counter_generated_offset_ccid := -1;
            end if;

         end if;
         -- Bug 6962827 end

      end loop;

      for i in 1.. l_adj_tbl.count loop

         l_generated_ccid(i)              := l_adj_tbl(i).generated_ccid;
         l_generated_offset_ccid(i)       := l_adj_tbl(i).generated_offset_ccid;
         l_rowid(i)                       := l_adj_tbl(i).rowid;
         -- Bug 6962827
         l_counter_generated_ccid(i)       := l_adj_tbl(i).counter_generated_ccid;
         l_ctr_generated_off_ccid(i)       := l_adj_tbl(i).counter_generated_offset_ccid;
      end loop;

      forall i in 1..l_adj_tbl.count
      update fa_xla_ext_lines_b_gt
         set generated_ccid              = l_generated_ccid(i),
             generated_offset_ccid       = l_generated_offset_ccid(i),
             counter_generated_ccid      = l_counter_generated_ccid(i), -- Bug 6962827
             counter_generated_offset_ccid = l_ctr_generated_off_ccid(i) -- Bug 6962827
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



         Lock_Data;
         if (fa_xla_extract_util_pkg.G_trx_exists) then
            load_header_data_stg1;
            Load_line_data_stg1;
         end if;

         if (fa_xla_extract_util_pkg.G_inter_trx_exists) then
            load_header_data_stg2;
            Load_line_data_stg2;
         end if;

         if (fa_xla_extract_util_pkg.G_fin_trx_exists) then
            Load_line_data_fin1;
         end if;

         if (fa_xla_extract_util_pkg.G_inter_trx_exists) then
            Load_line_data_fin2;
         end if;

         if (fa_xla_extract_util_pkg.G_xfr_trx_exists) then
            Load_line_data_xfr;
         end if;

         if (fa_xla_extract_util_pkg.G_dist_trx_exists) then
            Load_line_data_dist;
         end if;

         if (fa_xla_extract_util_pkg.G_ret_trx_exists) then
            Load_line_data_ret;
         end if;

         if (fa_xla_extract_util_pkg.G_res_trx_exists) then
            Load_line_data_res;
         end if;

         Load_mls_data;

         


      fnd_profile.get ('FA_WF_GENERATE_CCIDS', l_use_fafbgcc);
      if (nvl(l_use_fafbgcc, 'N') = 'Y') then
         if (NOT fa_util_pub.get_log_level_rec (
                   x_log_level_rec =>  l_log_level_rec)) then raise error_found;
         end if;

         Load_Generated_Ccids
            (p_log_level_rec => l_log_level_rec);
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



END FA_XLA_EXTRACT_TRX_PKG;


/
