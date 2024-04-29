--------------------------------------------------------
--  DDL for Package Body FA_DEFERRED_DEPRN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_DEFERRED_DEPRN_PKG" AS
/* $Header: FAXDEFB.pls 120.8.12010000.9 2009/07/19 14:22:15 glchen ship $ */

---------------------------------------------------
-- Declaration of global variables               --
---------------------------------------------------

G_CURRENT_RUNTIME_LEVEL        NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

G_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
G_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
G_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
G_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

G_MODULE_NAME         CONSTANT VARCHAR2(50):= 'fa.plsql.fa_deferred_deprn_pkg.';

g_log_level_rec fa_api_types.log_level_rec_type;

TYPE number_tbl_type       IS TABLE OF number INDEX BY BINARY_INTEGER;
TYPE char_tbl_type         IS TABLE OF varchar2(30) INDEX BY BINARY_INTEGER;
TYPE rowid_tbl_type        IS TABLE OF varchar2(64) INDEX BY BINARY_INTEGER;

---------------------------------------------------
-- Declaration of local procedures and functions --
---------------------------------------------------

--------------------------------------------------------------------------------
--
-- write_mesg
--
-- used to write messages which we want in both execution report and log
--  (i.e. DO NOT USE THIS FOR DEBUG!!!!)
--
--------------------------------------------------------------------------------


PROCEDURE Write_Mesg (p_calling_fn varchar2,
                      p_name       varchar2,
                      p_token1     varchar2 DEFAULT NULL,
                      p_value1     varchar2 DEFAULT NULL,
                      p_token2     varchar2 DEFAULT NULL,
                      p_value2     varchar2 DEFAULT NULL,
                      p_mode       varchar2 DEFAULT 'W') IS

   l_string      varchar2(2000);
   l_encoded     varchar2(1) := fnd_api.G_FALSE;

   l_calling_fn  varchar2(150);
   l_mesg_count  number := 0;

BEGIN

   -- when error set the calling fn for log purposes
   if (p_mode = 'E') then
      l_calling_fn := p_calling_fn;
   end if;

   -- set up and dump to execution report
   fnd_message.set_name('OFA', p_name);

   if (p_token1 is not null) then
      fnd_message.set_token(p_token1, p_value1);
   end if;

   if (p_token2 is not null) then
      fnd_message.set_token(p_token2, p_value2);
   end if;

   l_string := fnd_message.get;
   FND_FILE.put(FND_FILE.output,l_string);
   FND_FILE.new_line(FND_FILE.output,1);

   -- now add to log as well
   fa_srvr_msg.add_message
       (calling_fn => l_calling_fn,
        name       => p_name,
        token1     => p_token1,
        value1     => p_value1,
        token2     => p_token2,
        value2     => p_value2);

EXCEPTION
   WHEN OTHERS THEN
        null;

END Write_Mesg;

--------------------------------------------------------------------------------
--
-- write_errmsg_log
--
-- dump messages (and debug) to the log
-- this will work for the gl tieback as well and show at the end of Gl's logfile
--
--------------------------------------------------------------------------------


PROCEDURE Write_ErrMsg_Log IS

   l_encoded     varchar2(1)  := fnd_api.G_FALSE;
   l_mesg_count  number       := 0;
   l_calling_fn  varchar2(60) := 'fa_journals_pkg.write_errmsg_log';
BEGIN

   l_mesg_count := fnd_msg_pub.count_msg;

   if (l_mesg_count > 0) then
        fnd_file.put(FND_FILE.LOG,
            fnd_msg_pub.get(fnd_msg_pub.G_FIRST, l_encoded));
        fnd_file.new_line(FND_FILE.LOG,1);

        for i in 1..(l_mesg_count-1) loop
            fnd_file.put(FND_FILE.LOG,
               fnd_msg_pub.get(fnd_msg_pub.G_NEXT, l_encoded));
            fnd_file.new_line(FND_FILE.LOG,1);
        end loop;

    end if;

EXCEPTION
    WHEN OTHERS THEN
         fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn);

END Write_ErrMsg_Log;

--------------------------------------------------------------------------------

Procedure deferred_deprn (p_corp_book         varchar2,
                          p_tax_book          varchar2,
                          p_corp_period_ctr   number,
                          p_tax_period_ctr    number,
                          p_mrc_sob_type_code varchar2,
                          p_set_of_books_id   number) is

   l_batch_size  number;
   l_procedure_name  varchar2(80) := 'FA_DEFERRED_PKG.deferred_deprn';
   l_calling_fn      varchar2(80) := 'FA_DEFERRED_PKG.deferred_deprn';

   error_found                EXCEPTION;

   l_corp_sob_id              number_tbl_type;
   l_tax_sob_id               number_tbl_type;
   l_sob_id                   number_tbl_type;
   l_asset_id                 number_tbl_type;
   l_rowid_tbl                rowid_tbl_type;
   l_dist_id                  number_tbl_type;
   l_dh_ccid                  number_tbl_type;
   l_corp_deprn               number_tbl_type;
   l_tax_deprn                number_tbl_type;
   l_corp_dd_period_counter   number_tbl_type;
   l_tax_dd_period_counter    number_tbl_type;
   l_rsv_adj                  number_tbl_type;
   l_book                     varchar2(30);
   l_book_class               varchar2(15);
   l_prior_period_tfr         number_tbl_type;



   CURSOR c_mrc_deferred is
         SELECT corp_bc.set_of_books_id,
                tax_bc.set_of_books_id,
                DH.Asset_ID,
                DH.Distribution_ID,
                DH.Code_Combination_ID,
                nvl(CORP_DD.Deprn_Amount, 0),
                nvl(TAX_DD.Deprn_Amount, 0),
                nvl(CORP_DD.Period_Counter, -1),
                nvl(TAX_DD.Period_Counter, -1)
           FROM FA_DISTRIBUTION_HISTORY DH,
                FA_ASSET_HISTORY        AH,
                FA_MC_DEPRN_PERIODS     DP,
                FA_MC_DEPRN_DETAIL      CORP_DD,
                FA_MC_DEPRN_DETAIL      TAX_DD,
                fa_mc_book_controls     corp_bc,
                fa_mc_book_controls     tax_bc
          WHERE DH.Book_Type_Code              = p_corp_book
            AND DP.Period_Counter              = p_tax_period_ctr
            AND DP.Book_Type_Code              = p_tax_book
            AND DP.set_of_books_id             = p_set_of_books_id
            AND AH.Asset_ID                    = DH.Asset_ID
            AND AH.Date_Effective              <  DP.Period_Close_Date
            AND DP.Period_Close_Date          <= NVL(AH.Date_Ineffective,
                                                     DP.Period_Close_Date)
            AND AH.Asset_Type                 in ('CAPITALIZED', 'GROUP')
            AND CORP_BC.book_type_code         = p_corp_book
            AND CORP_BC.set_of_books_id        = p_set_of_books_id
            AND TAX_BC.book_type_code          = p_tax_book
            AND TAX_BC.set_of_books_id         = p_set_of_books_id
            AND CORP_DD.Book_Type_Code (+)     = p_corp_book
            AND CORP_DD.set_of_books_id(+)     = p_set_of_books_id
            AND CORP_DD.Period_Counter (+)     = p_tax_period_ctr
            AND CORP_DD.Distribution_ID (+)    = DH.Distribution_ID
            AND CORP_DD.Deprn_Source_Code (+) <> 'T'
            AND TAX_DD.Book_Type_Code (+)      = p_tax_book
            AND TAX_DD.set_of_books_id(+)      = p_set_of_books_id
            AND TAX_DD.Period_Counter (+)      = p_tax_period_ctr
            AND TAX_DD.Distribution_ID (+)     = DH.Distribution_ID
            AND TAX_DD.Deprn_Source_Code (+)  <> 'T'
            AND TAX_DD.asset_id(+)             = DH.asset_id
            AND (TAX_DD.asset_id is not null OR CORP_DD.asset_id is not null)
            AND exists
                (select 1
                   from fa_books bk
                  where bk.asset_id       = DH.asset_id
                    and bk.book_type_code = p_tax_book
                    and bk.transaction_header_id_out is null)
       ORDER BY DH.Asset_ID,
                DH.Distribution_ID,
                DH.Code_Combination_ID;

   CURSOR c_deferred IS
         SELECT DH.Asset_ID,
                DH.Distribution_ID,
                DH.Code_Combination_ID,
                nvl(CORP_DD.Deprn_Amount, 0),
                nvl(TAX_DD.Deprn_Amount, 0),
                nvl(CORP_DD.Period_Counter, -1),
                nvl(TAX_DD.Period_Counter, -1)
           FROM FA_DISTRIBUTION_HISTORY DH,
                FA_ASSET_HISTORY        AH,
                FA_DEPRN_PERIODS        DP,
                FA_DEPRN_DETAIL         CORP_DD,
                FA_DEPRN_DETAIL         TAX_DD
          WHERE DH.Book_Type_Code              = p_corp_book
            AND DP.Period_Counter              = p_tax_period_ctr
            AND DP.Book_Type_Code              = p_tax_book
            AND AH.Asset_ID                    = DH.Asset_ID
            AND AH.Date_Effective              <  DP.Period_Close_Date
            AND DP.Period_Close_Date          <= NVL(AH.Date_Ineffective,
                                                     DP.Period_Close_Date)
            AND AH.Asset_Type                 in ('CAPITALIZED', 'GROUP')
            AND CORP_DD.Book_Type_Code (+)     = p_corp_book
            AND CORP_DD.Period_Counter (+)     = p_tax_period_ctr
            AND CORP_DD.Distribution_ID (+)    = DH.Distribution_ID
            AND CORP_DD.Deprn_Source_Code (+) <> 'T'
            AND TAX_DD.Book_Type_Code (+)      = p_tax_book
            AND TAX_DD.Period_Counter (+)      = p_tax_period_ctr
            AND TAX_DD.Distribution_ID (+)     = DH.Distribution_ID
            AND TAX_DD.Deprn_Source_Code (+)  <> 'T'
            AND TAX_DD.asset_id(+)             = DH.asset_id
            AND (TAX_DD.asset_id is not null OR CORP_DD.asset_id is not null)
            AND exists
                (select 1
                   from fa_books bk
                  where bk.asset_id       = DH.asset_id
                    and bk.book_type_code = p_tax_book
                    and bk.transaction_header_id_out is null)
       ORDER BY DH.Asset_ID,
                DH.Distribution_ID,
                DH.Code_Combination_ID;


   CURSOR c_deferred_adj(p_book       varchar2,
                         p_period_ctr number,
                         p_book_class varchar2) is
         SELECT asset_id,
                distribution_id,
                nvl(sum(nvl(decode(p_book_class,
                                   'TAX', decode(AJ.debit_credit_flag,
                                                 'CR', 1, -1),
                                          decode(AJ.debit_credit_flag,
                                                 'DR', 1, -1)) *
                                   AJ.Adjustment_Amount, 0)), 0)
           from fa_adjustments AJ
          WHERE AJ.Book_Type_Code (+)            = p_book
            AND AJ.Period_Counter_Created (+)    = p_period_ctr
            AND nvl(AJ.Adjustment_Amount,-9999) <> 0
            AND AJ.Adjustment_Type (+)           = 'RESERVE'
            AND nvl(AJ.Track_Member_Flag,'N')    = 'N'
            AND exists
                (select 1
                   from fa_deferred_deprn def
                  where def.asset_id       = AJ.asset_id
                    and def.corp_book_type_code = p_corp_book
                    and def.tax_book_type_code  = p_tax_book
                    and def.corp_period_counter = p_corp_period_ctr
                    and def.tax_period_counter  = p_tax_period_ctr)
          GROUP BY asset_id,
                   distribution_id;

   CURSOR c_mrc_deferred_adj(p_book       varchar2,
                             p_period_ctr number,
                             p_book_class varchar2) IS
         SELECT set_of_books_id,
                asset_id,
                distribution_id,
                nvl(sum(nvl(decode(p_book_class,
                                   'TAX', decode(AJ.debit_credit_flag,
                                                 'CR', 1, -1),
                                          decode(AJ.debit_credit_flag,
                                                 'DR', 1, -1)) *
                                   AJ.Adjustment_Amount, 0)), 0)
           from fa_mc_adjustments AJ
          WHERE AJ.Book_Type_Code (+)            = p_book
            AND AJ.Period_Counter_Created (+)    = p_period_ctr
            AND AJ.set_of_books_id               = p_set_of_books_id
            AND nvl(AJ.Adjustment_Amount,-9999) <> 0
            AND AJ.Adjustment_Type (+)           = 'RESERVE'
            AND nvl(AJ.Track_Member_Flag,'N')     = 'N'
            AND exists
                (select 1
                   from fa_deferred_deprn def
                  where def.asset_id       = AJ.asset_id
                    and def.corp_book_type_code = p_corp_book
                    and def.tax_book_type_code  = p_tax_book
                    and def.corp_period_counter = p_corp_period_ctr
                    and def.tax_period_counter  = p_tax_period_ctr)
          GROUP BY set_of_books_id,
                   asset_id,
                   distribution_id;

begin

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   -- call the book_controls cache
   if NOT fa_cache_pkg.fazcbc(X_book => p_tax_book) then
      raise error_found;
   end if;

   l_batch_size := nvl(fa_cache_pkg.fa_batch_size, 200);



   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'opening ' || p_mrc_sob_type_code || ' deferred cursor');
   END IF;

   -- mrc loop
   if (p_mrc_sob_type_code = 'R') then
      OPEN C_MRC_DEFERRED;
   else
      OPEN C_DEFERRED;
   end if;

   while (TRUE) loop

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'fetching ' || p_mrc_sob_type_code || ' cursor');
      END IF;

      if (p_mrc_sob_type_code = 'R') then
          FETCH C_MRC_DEFERRED BULK COLLECT INTO
                l_corp_sob_id,
                l_tax_sob_id,
                l_asset_id,
                l_dist_id,
                l_dh_ccid,
                l_corp_deprn,
                l_tax_deprn,
                l_corp_dd_period_counter,
                l_tax_dd_period_counter
          LIMIT l_batch_size;
      else
         FETCH C_DEFERRED BULK COLLECT INTO
                l_asset_id,
                l_dist_id,
                l_dh_ccid,
                l_corp_deprn,
                l_tax_deprn,
                l_corp_dd_period_counter,
                l_tax_dd_period_counter
          LIMIT l_batch_size;
      end if;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'rows fetched: ' || to_char(l_asset_id.count));
      END IF;

      if (l_asset_id.count = 0) then

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            fnd_log.string(G_LEVEL_STATEMENT,
                           G_MODULE_NAME||l_procedure_name,
                           'exiting loop');
         END IF;

         exit;
      end if;


      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'bulk inserting into fa_deferred_deprn*' || p_mrc_sob_type_code);
      END IF;

      if (p_mrc_sob_type_code = 'R') then

          FORALL i in 1..l_asset_id.count
          INSERT INTO FA_MC_DEFERRED_DEPRN
              (set_of_books_id,
               corp_book_type_code,
               tax_book_type_code,
               asset_id,
               distribution_id,
               deferred_deprn_expense_ccid,
               deferred_deprn_reserve_ccid,
               deferred_deprn_expense_amount,
               deferred_deprn_reserve_amount,
               corp_period_counter,
               tax_period_counter,
               expense_je_line_num,
               reserve_je_line_num)
          values
              (l_tax_sob_id(i),
               p_corp_book,
               p_tax_book,
               l_asset_id(i),
               l_dist_id(i),
               null, -- l_deferred_deprn_expense_ccid,
               null, -- l_deferred_deprn_reserve_ccid,
               (l_tax_deprn(i) - l_corp_deprn(i)),
               (l_tax_deprn(i) - l_corp_deprn(i)),
               p_corp_period_ctr,
               p_tax_period_ctr,
               0,
               0);

      else
          FORALL i in 1..l_asset_id.count
          INSERT INTO FA_DEFERRED_DEPRN
              (corp_book_type_code,
               tax_book_type_code,
               asset_id,
               distribution_id,
               deferred_deprn_expense_ccid,
               deferred_deprn_reserve_ccid,
               deferred_deprn_expense_amount,
               deferred_deprn_reserve_amount,
               corp_period_counter,
               tax_period_counter,
               expense_je_line_num,
               reserve_je_line_num)
          values
              (p_corp_book,
               p_tax_book,
               l_asset_id(i),
               l_dist_id(i),
               null, -- l_deferred_deprn_expense_ccid,
               null, -- l_deferred_deprn_reserve_ccid,
               (l_tax_deprn(i) - l_corp_deprn(i)),
               (l_tax_deprn(i) - l_corp_deprn(i)),
               p_corp_period_ctr,
               p_tax_period_ctr,
               0,
               0);
      end if;

      l_corp_sob_id.delete;
      l_tax_sob_id.delete;
      l_asset_id.delete;
      l_dist_id.delete;
      l_dh_ccid.delete;
      l_corp_deprn.delete;
      l_tax_deprn.delete;
      l_corp_dd_period_counter.delete;
      l_tax_dd_period_counter.delete;

   end loop;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'closing ' || p_mrc_sob_type_code || ' deferred cursor');
   END IF;

   if (p_mrc_sob_type_code = 'R') then
      CLOSE C_MRC_DEFERRED;
   else
      CLOSE C_DEFERRED;
   end if;


   -------------------------------------
   -- process the corp/tax adjustments
   -------------------------------------

   for x in 1..2 loop

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'in ADJ loop, interation #:' || to_char(x));
      END IF;

      if (x = 1) then
         l_book_class := 'CORP';
         l_book       := p_corp_book;
      else
         l_book_class := 'TAX';
         l_book       := p_tax_book;
      end if;

      if (p_mrc_sob_type_code = 'R') then
         OPEN C_MRC_DEFERRED_ADJ(l_book, p_tax_period_ctr, l_book_class);
      else
         OPEN C_DEFERRED_ADJ(l_book, p_tax_period_ctr, l_book_class);
      end if;

      while (TRUE) loop

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            fnd_log.string(G_LEVEL_STATEMENT,
                           G_MODULE_NAME||l_procedure_name,
                           'fetching ' || p_mrc_sob_type_code || ' ADJ cursor');
         END IF;

         if (p_mrc_sob_type_code = 'R') then
            FETCH C_MRC_DEFERRED_ADJ BULK COLLECT INTO
                l_sob_id,
                l_asset_id,
                l_dist_id,
                l_rsv_adj
            LIMIT l_batch_size;
         else
            FETCH C_DEFERRED_ADJ BULK COLLECT INTO
                l_asset_id,
                l_dist_id,
                l_rsv_adj
            LIMIT l_batch_size;
         end if;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'rows fetched: ' || to_char(l_asset_id.count));
         END IF;

         if (l_asset_id.count = 0) then

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
               fnd_log.string(G_LEVEL_STATEMENT,
                              G_MODULE_NAME||l_procedure_name,
                             'exiting loop');
            END IF;

            exit;
         end if;

/*
      for i in 1..l_asset_id.count loop

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        to_char(l_dist_id(i)) || ': ' ||
                        to_char(l_corp_rsv_adj(i)));
      END IF;

      end loop;
*/


         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            fnd_log.string(G_LEVEL_STATEMENT,
                           G_MODULE_NAME||l_procedure_name,
                           'bulk updating fa_deferred_deprn for corp adj' || p_mrc_sob_type_code);
         END IF;


         if (p_mrc_sob_type_code = 'R') then

          FORALL i in 1..l_asset_id.count
          UPDATE FA_MC_DEFERRED_DEPRN
             SET deferred_deprn_expense_amount = deferred_deprn_expense_amount + l_rsv_adj(i),
                 deferred_deprn_reserve_amount = deferred_deprn_reserve_amount + l_rsv_adj(i)
           WHERE set_of_books_id        = l_tax_sob_id(i)
             AND corp_book_type_code    = p_corp_book
             AND tax_book_type_code     = p_tax_book
             AND corp_period_counter    = p_corp_period_ctr
             AND tax_period_counter     = p_tax_period_ctr
             AND asset_id               = l_asset_id(i)
             AND distribution_id        = l_dist_id(i);

         else

          FORALL i in 1..l_asset_id.count
          UPDATE FA_DEFERRED_DEPRN
             SET deferred_deprn_expense_amount = deferred_deprn_expense_amount + l_rsv_adj(i),
                 deferred_deprn_reserve_amount = deferred_deprn_reserve_amount + l_rsv_adj(i)
           WHERE corp_book_type_code    = p_corp_book
             AND tax_book_type_code     = p_tax_book
             AND corp_period_counter    = p_corp_period_ctr
             AND tax_period_counter     = p_tax_period_ctr
             AND asset_id               = l_asset_id(i)
             AND distribution_id        = l_dist_id(i);

         end if;

         l_sob_id.delete;
         l_asset_id.delete;
         l_dist_id.delete;
         l_rsv_adj.delete;

      end loop;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'closing ' || p_mrc_sob_type_code || ' ADJ cursor');
      END IF;

      if (p_mrc_sob_type_code = 'R') then
         CLOSE C_MRC_DEFERRED_ADJ;
      else
         CLOSE C_DEFERRED_ADJ;
      end if;

   end loop; -- corp/tax loop

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                   'End of procedure');
   END IF;

EXCEPTION
   WHEN error_found THEN
        fa_srvr_msg.add_message(calling_fn => l_calling_fn);
        raise;


   WHEN others THEN
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn);
        raise;

end deferred_deprn;

--------------------------------------------------------------------------------

procedure create_bulk_deferred_events (
             p_tax_book                IN     VARCHAR2,
             p_corp_book               IN     VARCHAR2,
             p_tax_period_counter      IN     NUMBER,
             p_corp_period_counter     IN     NUMBER
            ) IS

   l_batch_size     number;
   l_period_rec      fa_api_types.period_rec_type;

   error_found                EXCEPTION;

   l_asset_id_tbl FA_XLA_EVENTS_PVT.number_tbl_type;
   l_rowid_tbl    rowid_tbl_type;
   l_event_id_tbl FA_XLA_EVENTS_PVT.number_tbl_type;

   l_sob_tbl                  FA_CACHE_PKG.fazcrsob_sob_tbl_type;

   cursor c_deferred_events is
   select asset_id, min(rowid)
     from fa_deferred_deprn
    where corp_book_type_code = p_corp_book
      and tax_book_type_code  = p_tax_book
      and corp_period_counter = p_corp_period_counter
      and tax_period_counter  = p_tax_period_counter
      and event_id           is null
    group by asset_id;

   cursor c_mc_deferred_events (p_set_of_books_id number) is
   select asset_id, min(rowid)
     from fa_mc_deferred_deprn
    where corp_book_type_code = p_corp_book
      and tax_book_type_code  = p_tax_book
      and corp_period_counter = p_corp_period_counter
      and tax_period_counter  = p_tax_period_counter
      and set_of_books_id     = p_set_of_books_id
      and event_id           is null
    group by asset_id;

   -- Bugfix 6122229: Increased the length from varchar2(35) to varchar2(80)
   -- for variable l_calling_fn
   l_calling_fn      varchar2(80) := 'FA_DEFERRED_PKG.create_bulk_deprn_events';
   l_procedure_name  varchar2(80) := 'FA_DEFERRED_PKG.create_bulk_deprn_events';

   --Bug6122229
   --Initializing the second count variable
   l_count2 number := 1 ;

begin

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   l_batch_size := nvl(fa_cache_pkg.fa_batch_size, 200);

   if not FA_UTIL_PVT.get_period_rec
          (p_book           => p_corp_book,
           p_period_counter => p_corp_period_counter,
           x_period_rec     => l_period_rec,
           p_log_level_rec  => g_log_level_rec
          ) then
      raise error_found;
   end if;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'opening c_deferred_events');
   END IF;

   open c_deferred_events;

   loop -- Loop for c_deferred_events

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'bulk fetching c_deferred_events cursor');
      END IF;

      fetch c_deferred_events bulk collect
       into l_asset_id_tbl,
            l_rowid_tbl
      LIMIT l_batch_size;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'rows fetched: ' || to_char(l_asset_id_tbl.count));
      END IF;

      if l_asset_id_tbl.count = 0 then
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            fnd_log.string(G_LEVEL_STATEMENT,
                           G_MODULE_NAME||l_procedure_name,
                           'exiting loop...');
         END IF;

         exit;
      end if;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'calling FA_XLA_EVENTS_PVT.create_bulk_deferred_event for primary');
      END IF;

      -- call bulk event api
      FA_XLA_EVENTS_PVT.create_bulk_deferred_event
               (p_asset_id_tbl        => l_asset_id_tbl,
                p_corp_book           => p_corp_book,
                p_tax_book            => p_tax_book,
                p_corp_period_counter => p_corp_period_counter,
                p_tax_period_counter  => p_tax_period_counter,
                p_period_close_date   => l_period_rec.calendar_period_close_date,
--                p_legal_entity        => null,
                p_entity_type_code    => 'DEFERRED_DEPRECIATION',
                x_event_id_tbl        => l_event_id_tbl,
                p_calling_fn          => l_calling_fn
                );

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'bulk inserting into fa_deferred_deprn_events');
      END IF;

      FORALL l_count in 1..l_asset_id_tbl.count
      INSERT into fa_deferred_deprn_events
             (asset_id            ,
              corp_book_type_code ,
              tax_book_type_code  ,
              corp_period_counter ,
              tax_period_counter  ,
              event_id
              )
       VALUES
             (l_asset_id_tbl(l_count),
              p_corp_book,
              p_tax_book,
              p_corp_period_counter,
              p_tax_period_counter,
              l_event_id_tbl(l_count));

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'bulk updating fa_deferred_deprn with event ids');
      END IF;

      FORALL l_count in 1..l_asset_id_tbl.count
      update fa_deferred_deprn
         set event_id            = l_event_id_tbl(l_count)
       where asset_id            = l_asset_id_tbl(l_count)
         AND corp_book_type_code = p_corp_book
         AND tax_book_type_code  = p_tax_book
         AND corp_period_counter = p_corp_period_counter
         AND tax_period_counter  = p_tax_period_counter;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'bulk updating fa_mc_deferred_deprn with event ids');
      END IF;

      -- now process all matching mrc rows
      FORALL l_count in 1..l_asset_id_tbl.count
      update fa_mc_deferred_deprn
         SET event_id            = l_event_id_tbl(l_count)
       WHERE asset_id            = l_asset_id_tbl(l_count)
         AND corp_book_type_code = p_corp_book
         AND tax_book_type_code  = p_tax_book
         AND corp_period_counter = p_corp_period_counter
         AND tax_period_counter  = p_tax_period_counter;

      delete from xla_events_int_gt;

   end loop; --End of loop for c_deferred_events

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'closing c_deferred_events');
   END IF;

   close c_deferred_events;

   -- now find any mrc rows which are not processed yet and update
   if not FA_CACHE_PKG.fazcrsob
          (x_book_type_code => p_corp_book,
           x_sob_tbl        => l_sob_tbl) then
      raise error_found;
   end if;

   -- begin at index of 1 not 0 as in apis
   FOR l_sob_index in 1..l_sob_tbl.count LOOP

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'opening c_mc_deferred_events cursor');
      END IF;

      OPEN c_mc_deferred_events(p_set_of_books_id => l_sob_tbl(l_sob_index));

      loop -- Loop for c_mc_deferred_events

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            fnd_log.string(G_LEVEL_STATEMENT,
                           G_MODULE_NAME||l_procedure_name,
                           'fetching c_mc_deferred_events cursor');
         END IF;

         FETCH c_mc_deferred_events bulk collect
          into l_asset_id_tbl,
               l_rowid_tbl
         LIMIT l_batch_size;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            fnd_log.string(G_LEVEL_STATEMENT,
                           G_MODULE_NAME||l_procedure_name,
                           'rows fetched: ' || to_char(l_asset_id_tbl.count));
         END IF;

         if (l_asset_id_tbl.count = 0) then
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
               fnd_log.string(G_LEVEL_STATEMENT,
                              G_MODULE_NAME||l_procedure_name,
                              'exiting loop...');
            END IF;

            exit;
         end if;

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            fnd_log.string(G_LEVEL_STATEMENT,
                           G_MODULE_NAME||l_procedure_name,
                           'calling FA_XLA_EVENTS_PVT.create_bulk_deferred_event for reporting');
         END IF;

         -- call bulk event api
         FA_XLA_EVENTS_PVT.create_bulk_deferred_event
               (p_asset_id_tbl        => l_asset_id_tbl,
                p_corp_book           => p_corp_book,
                p_tax_book            => p_tax_book,
                p_corp_period_counter => p_corp_period_counter,
                p_tax_period_counter  => p_tax_period_counter,
                p_period_close_date   => l_period_rec.calendar_period_close_date,
--                p_legal_entity        => px_max_legal_entity_id,
                p_entity_type_code    => 'DEFERRED_DEPRECIATION',
                x_event_id_tbl        => l_event_id_tbl,
                p_calling_fn          => l_calling_fn
                );

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            fnd_log.string(G_LEVEL_STATEMENT,
                           G_MODULE_NAME||l_procedure_name,
                           'bulk inserting into fa_deferred_deprn_events');
         END IF;

         FORALL l_count in 1..l_asset_id_tbl.count
         INSERT into fa_deferred_deprn_events
             (asset_id            ,
              corp_book_type_code ,
              tax_book_type_code  ,
              corp_period_counter ,
              tax_period_counter  ,
              event_id
              )
          VALUES
             (l_asset_id_tbl(l_count),
              p_corp_book,
              p_tax_book,
              p_corp_period_counter,
              p_tax_period_counter,
              l_event_id_tbl(l_count));

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            fnd_log.string(G_LEVEL_STATEMENT,
                           G_MODULE_NAME||l_procedure_name,
                           'bulk updating fa_mc_deferred_deprn with event ids');
         END IF;

         FORALL l_count in 1..l_asset_id_tbl.count
         UPDATE FA_MC_DEFERRED_DEPRN
            SET event_id            = l_event_id_tbl(l_count)
          WHERE asset_id            = l_asset_id_tbl(l_count)
            AND corp_book_type_code = p_corp_book
            AND tax_book_type_code  = p_tax_book
            AND corp_period_counter = p_corp_period_counter
            AND tax_period_counter  = p_tax_period_counter;

         delete from xla_events_int_gt;

      end loop; --End of loop for c_mc_deferred_events

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'closing c_mc_deferred_events');
      END IF;


      CLOSE c_mc_deferred_events;

   END LOOP; -- sob loop

   commit;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                   'End of procedure');
   END IF;

EXCEPTION
   when error_found then
        rollback;
        fa_srvr_msg.add_message(calling_fn => l_calling_fn);
        raise;

   when others then
        rollback;
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn);
        raise;


end create_bulk_deferred_events;

--------------------------------------------------------------------------------

Procedure do_deferred (errbuf                OUT NOCOPY     VARCHAR2,
                       retcode               OUT NOCOPY     NUMBER,
                       p_tax_book_type_code  IN varchar2,
                       p_tax_period_name     IN varchar2,
                       p_corp_period_name    IN varchar2) is

   l_reporting_flag  varchar2(1);
   l_procedure_name  varchar2(80) := 'do_deferred';
   l_calling_fn      varchar2(80) := 'FA_DEFERRED_PKG.do_deferred';

   l_tax_period_counter  number;
   l_corp_period_counter number;

   error_found exception;

   l_deferred_exists_count    number;


   CURSOR C_BOOKS (p_book_type_code varchar2)IS
      SELECT 0,
             set_of_books_id
        FROM fa_book_controls
       WHERE book_type_code = p_book_type_code
       UNION ALL
      SELECT 1, bcm.set_of_books_id
        FROM fa_book_controls    bc,
             fa_mc_book_controls bcm
       WHERE bc.book_type_code  = p_book_type_code
         AND bc.mc_source_flag  = 'Y'
         AND bcm.book_type_code = bc.book_type_code
         AND bcm.primary_set_of_books_id = bc.set_of_books_id
         AND bcm.enabled_flag = 'Y'
      ORDER BY 1 DESC, 2; -- Process the reporting books first

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   if not fa_cache_pkg.fazcbc(X_book => p_tax_book_type_code) then
      raise error_found;
   end if;

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise error_found;
      end if;
   end if;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'fetching period information');
   END IF;

   -- Convert period names to period counters
   begin
      select period_counter
      into   l_tax_period_counter
      from   fa_deprn_periods
      where  book_type_code = p_tax_book_type_code
      and    period_name = p_tax_period_name;

      select period_counter
      into   l_corp_period_counter
      from   fa_deprn_periods
      where  book_type_code =
             fa_cache_pkg.fazcbc_record.distribution_source_book
      and    period_name = p_corp_period_name;

   exception
      when others then
         raise error_found;
   end;

   -- BUG# 8393653
   -- exit if already run
   -- no partial as commit is at end of event processing

   begin

      select 1
        into l_deferred_exists_count
        from fa_deferred_deprn
       where tax_book_type_code  = p_tax_book_type_code
         and corp_book_type_code =
             fa_cache_pkg.fazcbc_record.distribution_source_book
         and tax_period_counter  = l_tax_period_counter
         and corp_period_counter = l_tax_period_counter
         and rownum = 1;

   exception
      when no_data_found then
           l_deferred_exists_count := 0;
   end;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'l_deferred_exists_count :' || to_char(l_deferred_exists_count));
   END IF;

   if (l_deferred_exists_count <> 0) then
      return;
   end if;

   for c_rec in c_books (p_book_type_code => p_tax_book_type_code) loop

      fnd_profile.put('GL_SET_OF_BKS_ID', c_rec.set_of_books_id);
      fnd_client_info.set_currency_context (c_rec.set_of_books_id);

      if not fa_cache_pkg.fazcsob
         (X_set_of_books_id   => c_rec.set_of_books_id,
          X_mrc_sob_type_code => l_reporting_flag
         ) then
         raise error_found;
      end if;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_STATEMENT,
                        G_MODULE_NAME||l_procedure_name,
                        'calling deferred_deprn');
      END IF;

      deferred_deprn
              (p_corp_book         => fa_cache_pkg.fazcbc_record.distribution_source_book,
               p_tax_book          => p_tax_book_type_code,
               p_corp_period_ctr   => l_corp_period_counter,
               p_tax_period_ctr    => l_tax_period_counter,
               p_mrc_sob_type_code => l_reporting_flag,
               p_set_of_books_id   => c_rec.set_of_books_id);

   end loop;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_STATEMENT,
                     G_MODULE_NAME||l_procedure_name,
                     'calling create_bulk_deferred_events');
   END IF;

   -- now process the events
   create_bulk_deferred_events
             (p_tax_book                => p_tax_book_type_code,
              p_corp_book               => fa_cache_pkg.fazcbc_record.distribution_source_book,
              p_tax_period_counter      => l_tax_period_counter,
              p_corp_period_counter     => l_corp_period_counter);

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.end',
                   'End of procedure');
   END IF;

   Write_Mesg(l_calling_fn,
              'FA_SHARED_END_SUCCESS',
              'PROGRAM',
              'FAXDEF');

   Write_ErrMsg_Log;
   retcode := 0;

EXCEPTION
   WHEN error_found THEN
        fa_srvr_msg.add_message(calling_fn => l_calling_fn);

        Write_Mesg(l_calling_fn,
              'FA_SHARED_PROGRAM_FAILED',
              'PROGRAM',
              'FAXDEF');

        Write_ErrMsg_Log;
        retcode := 2;

   WHEN others THEN
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn);

        Write_Mesg(l_calling_fn,
              'FA_SHARED_PROGRAM_FAILED',
              'PROGRAM',
              'FAXDEF');

        Write_ErrMsg_Log;
        retcode := 2;

end do_deferred;

END FA_DEFERRED_DEPRN_PKG;

/
