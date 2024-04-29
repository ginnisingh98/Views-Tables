--------------------------------------------------------
--  DDL for Package Body FA_XLA_EXTRACT_DEF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_XLA_EXTRACT_DEF_PKG" AS

/*======================================================================+
|                Copyright (c) 1997 Oracle Corporation                  |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| Package Name                                                          |
|     FA_XLA_EXTRACT_DEF_PKG                                            |
|                                                                       |
| DESCRIPTION                                                           |
|     Package generated From FA AAD setups                              |
|                                                                       |
| HISTORY                                                               |
|     Generated at 16-06-2018 at 10:06:41 by user ANONYMOUS             |
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

G_MODULE_NAME         CONSTANT VARCHAR2(50):= 'fa.plsql.fa_xla_extract_def_pkg.';


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
           TRANSFER_TO_GL_FLAG                     ,
           DEFERRED_DEPRN_EXPENSE_ACCT,
           DEFERRED_DEPRN_RESERVE_ACCT )
    select ctlgd.event_id,
           bc.FLEXBUILDER_DEFAULTS_CCID            ,
           bc.book_type_code                       ,
           dp.PERIOD_NAME                          ,
           dp.CALENDAR_PERIOD_CLOSE_DATE           ,
           dp.PERIOD_COUNTER                       ,
           ctlgd.event_date                        ,
           'Y'                                   ,
           bc.DEFERRED_DEPRN_EXPENSE_ACCT,
           bc.DEFERRED_DEPRN_RESERVE_ACCT
      FROM xla_events_gt                 ctlgd,
           fa_deprn_periods              dp,
           fa_book_controls              bc 
     WHERE ctlgd.entity_code         = 'DEFERRED_DEPRECIATION'
       AND ctlgd.event_type_code     = 'DEFERRED_DEPRECIATION'
       AND bc.book_type_code         = ctlgd.source_id_char_1
       AND dp.book_type_code         = ctlgd.source_id_char_1
       AND dp.period_counter         = ctlgd.source_id_int_2 ;

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
           BOOK_TYPE_CODE                       ,
           TAX_BOOK_TYPE_CODE                   ,
           GENERATED_CCID                       ,
           GENERATED_OFFSET_CCID                ,
           ASSET_ID,
           EXPENSE_ACCOUNT_CCID )
    select ctlgd.EVENT_ID                            ,
           df.distribution_id                        as distribution_id,
           df.distribution_id                        as dist_id,
           'DEFERRED'                              ,
           bc.set_of_books_id                        ,
           le.currency_code                          ,
           ah.category_id                            ,
           df.deferred_deprn_expense_amount          ,
           df.corp_book_type_code                    ,
           df.tax_book_type_code                     ,
           df.deferred_deprn_expense_ccid            ,
           df.deferred_deprn_reserve_ccid            ,
           ad.ASSET_ID,
           dh.CODE_COMBINATION_ID
      from fa_additions_b            ad,
           fa_asset_history          ah,
           fa_book_controls          bc,
           fa_category_books         cb,
           fa_distribution_history   dh,
           fa_deferred_deprn         df,
           gl_ledgers                le,
           xla_events_gt             ctlgd 
     where ctlgd.entity_code           = 'DEFERRED_DEPRECIATION'
       AND ctlgd.event_type_code       = 'DEFERRED_DEPRECIATION'
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
       AND ah.asset_type              in ('CAPITALIZED', 'GROUP')
       AND ad.asset_type              in ('CAPITALIZED', 'GROUP')
       AND bc.book_type_code           = ctlgd.source_id_char_1
       AND le.ledger_id                = bc.set_of_books_id ;

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
           BOOK_TYPE_CODE                       ,
           TAX_BOOK_TYPE_CODE                   ,
           GENERATED_CCID                       ,
           GENERATED_OFFSET_CCID                ,
           ASSET_ID,
           EXPENSE_ACCOUNT_CCID )
    select ctlgd.EVENT_ID                            ,
           df.distribution_id                        as distribution_id,
           df.distribution_id                        as dist_id,
           'DEFERRED'                              ,
           bc.set_of_books_id                        ,
           le.currency_code                          ,
           ah.category_id                            ,
           df.deferred_deprn_expense_amount          ,
           df.corp_book_type_code                    ,
           df.tax_book_type_code                     ,
           df.deferred_deprn_expense_ccid            ,
           df.deferred_deprn_reserve_ccid            ,
           ad.ASSET_ID,
           dh.CODE_COMBINATION_ID
      from fa_additions_b            ad,
           fa_asset_history          ah,
           fa_mc_book_controls          bc,
           fa_category_books         cb,
           fa_distribution_history   dh,
           fa_mc_deferred_deprn         df,
           gl_ledgers                le,
           xla_events_gt             ctlgd 
     where ctlgd.entity_code           = 'DEFERRED_DEPRECIATION'
       AND ctlgd.event_type_code       = 'DEFERRED_DEPRECIATION'
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
       AND ah.asset_type              in ('CAPITALIZED', 'GROUP')
       AND ad.asset_type              in ('CAPITALIZED', 'GROUP')
       AND bc.book_type_code           = ctlgd.source_id_char_1
       AND le.ledger_id                = bc.set_of_books_id 
       AND df.set_of_books_id = bc.set_of_books_id;

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




      type def_deprn_rec_type is record
        (rowid                           VARCHAR2(64),
         book_type_code                  VARCHAR2(30),
         distribution_id                 NUMBER(15),
         distribution_ccid               NUMBER(15),
         def_deprn_entered_amount        NUMBER,
         generated_ccid                  NUMBER(15),
         generated_offset_ccid           NUMBER(15),
         DEF_DEPRN_EXPENSE_ACCT          VARCHAR2(25),
         DEF_DEPRN_RESERVE_ACCT          VARCHAR2(25)
        );

      type def_deprn_tbl_type is table of def_deprn_rec_type index by binary_integer;

      l_def_deprn_tbl def_deprn_tbl_type;

      l_generated_ccid              num_tab_type;
      l_generated_offset_ccid       num_tab_type;
      l_rowid                       char_tab_type;

      l_last_book    varchar2(30) := ' ';

      cursor c_def_deprn is
      select /*+ leading(xg) index(xb, FA_XLA_EXT_HEADERS_B_GT_U1) index(xl, FA_XLA_EXT_LINES_B_GT_U1) */
             xl.rowid,
             xb.book_type_code,
             xl.distribution_id,
             xl.EXPENSE_ACCOUNT_CCID,
             xl.entered_amount,
             nvl(xl.generated_ccid,        da.DEFERRED_EXP_ACCOUNT_CCID),
             nvl(xl.generated_offset_ccid, da.DEFERRED_RSV_ACCOUNT_CCID),
             xb.DEFERRED_DEPRN_EXPENSE_ACCT,
             xb.DEFERRED_DEPRN_RESERVE_ACCT
        from xla_events_gt            xg,
             fa_xla_ext_headers_b_gt  xb,
             fa_xla_ext_lines_b_gt    xl,
             fa_distribution_accounts da
       where xg.event_class_code = 'DEFERRED DEPRECIATION'
         and xb.event_id         = xg.event_id
         and xl.event_id         = xg.event_id
         and xl.distribution_id  = da.distribution_id(+)
         and xl.tax_book_type_code   = da.book_type_code(+);



   BEGIN

      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name||'.begin',
                        'Beginning of procedure');
      END IF;

      open  c_def_deprn;
      fetch c_def_deprn bulk collect into l_def_deprn_tbl;
      close c_def_deprn;

      for i in 1..l_def_deprn_tbl.count loop

         if (l_last_book <> l_def_deprn_tbl(i).book_type_code or
             i = 1) then

            if not (fa_cache_pkg.fazcbc
                      (X_BOOK => l_def_deprn_tbl(i).book_type_code,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then
               null;

            end if;
            l_last_book := l_def_deprn_tbl(i).book_type_code;
         end if;


         -- call FAFBGCC if the ccid doesnt exist in distribution accounts

         if (l_def_deprn_tbl(i).generated_ccid is null and
             l_def_deprn_tbl(i).def_deprn_entered_amount   <> 0) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_def_deprn_tbl(i).book_type_code,
                       X_fn_trx_code     => 'DEFERRED_DEPRN_EXPENSE_ACCT',
                       X_dist_ccid       => l_def_deprn_tbl(i).distribution_ccid,
                       X_acct_segval     => l_def_deprn_tbl(i).def_deprn_expense_acct,
                       X_account_ccid    => 0,
                       X_distribution_id => l_def_deprn_tbl(i).distribution_id,
                       X_rtn_ccid        => l_def_deprn_tbl(i).generated_ccid,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then
               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => 'FA_GET_ACCOUNT_CCID',
                   CALLING_FN => 'fa_xla_extract_def_pkg.Load_Generated_Ccids',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_def_deprn_tbl(i).generated_ccid := -1;
            end if;
         end if;

         if (l_def_deprn_tbl(i).generated_offset_ccid is null and
             l_def_deprn_tbl(i).def_deprn_entered_amount <> 0) then


            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_def_deprn_tbl(i).book_type_code,
                       X_fn_trx_code     => 'DEFERRED_DEPRN_RESERVE_ACCT',
                       X_dist_ccid       => l_def_deprn_tbl(i).distribution_ccid,
                       X_acct_segval     => l_def_deprn_tbl(i).def_deprn_reserve_acct,
                       X_account_ccid    => 0,
                       X_distribution_id => l_def_deprn_tbl(i).distribution_id,
                       X_rtn_ccid        => l_def_deprn_tbl(i).generated_offset_ccid,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then

               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => 'FA_GET_ACCOUNT_CCID',
                   CALLING_FN => 'fa_xla_extract_def_pkg.Load_Generated_Ccids',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_def_deprn_tbl(i).generated_offset_ccid := -1;
            end if;
         end if;

      end loop;

      for i in 1.. l_def_deprn_tbl.count loop

         l_generated_ccid(i)              := l_def_deprn_tbl(i).generated_ccid;
         l_generated_offset_ccid(i)       := l_def_deprn_tbl(i).generated_offset_ccid;
         l_rowid(i)                       := l_def_deprn_tbl(i).rowid;

      end loop;

      forall i in 1..l_def_deprn_tbl.count
      update fa_xla_ext_lines_b_gt
         set generated_ccid              = l_generated_ccid(i),
             generated_offset_ccid       = l_generated_offset_ccid(i)
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



END FA_XLA_EXTRACT_DEF_PKG;


/
