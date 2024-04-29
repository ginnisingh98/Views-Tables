--------------------------------------------------------
--  DDL for Package Body FA_DEPRN_ROLLBACK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_DEPRN_ROLLBACK_PKG" AS
/* $Header: FAXDRB.pls 120.30.12010000.4 2009/08/18 13:22:16 spooyath ship $ */

g_log_level_rec  fa_api_types.log_level_rec_type;

PROCEDURE do_rollback(
      errbuf                  OUT NOCOPY     VARCHAR2,
      retcode                 OUT NOCOPY     NUMBER,
      p_book_type_code   IN   VARCHAR2,
      p_period_name      IN    VARCHAR2) IS

   l_trx_approval     BOOLEAN;
   l_request_id       NUMBER;
   l_period_counter   number;

   l_asset_hdr_rec    fa_api_types.asset_hdr_rec_type;

   l_msg_count        NUMBER := 0;
   l_msg_data         VARCHAR2(2000) := NULL;
   l_return_status    varchar2(1);

   cursor c_assets is
   select asset_id
     from fa_deprn_summary
    where book_type_code = p_book_type_code
      and period_counter = l_period_counter;

   faxdrb_err         EXCEPTION;


BEGIN

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise faxdrb_err;
      end if;
   end if;


   -- changing the call for the rollback segment to use
   -- dynamic sql as using the variable name doesn't work
   -- correctly.  It interprets it as a literal.

   -- Initialize server message stack
   FA_SRVR_MSG.Init_Server_Message;
   -- Initialize debug message stack
   FA_DEBUG_PKG.Initialize;


   /*====================================================================
    Get transaction approval and lock the book.
   ======================================================================*/

   l_request_id := fnd_global.conc_request_id;
   IF NOT FA_BEGIN_MASS_TRX_PKG.faxbmt(
             X_book          => p_book_type_code,
             X_request_id    => l_request_id,
             X_result        => l_trx_approval,
             p_log_level_rec => g_log_level_rec) THEN
      RAISE faxdrb_err;
   END IF;

   IF NOT l_trx_approval THEN
      -- Transaction was not approved.
      fa_srvr_msg.add_message(
         calling_fn => 'fa_deprn_rollback_pkg.do_rollback',
         name       => 'FA_TRXAPP_LOCK_FAILED',
         token1     => 'BOOK',
         value1     => p_book_type_code,
         p_log_level_rec => g_log_level_rec);
      RAISE faxdrb_err ;
   END IF;

   -- Commit the change made to fa_book_controls table to lock the book.
   COMMIT WORK;

   l_asset_hdr_rec.book_type_code := p_book_type_code;

   if not fa_cache_pkg.fazcbc (p_book_type_code,
                               p_log_level_rec => g_log_level_rec) then
      raise faxdrb_err;
   end if;

   l_period_counter := fa_cache_pkg.fazcbc_record.last_period_counter + 1;

   for c_rec in c_assets loop

      l_asset_hdr_rec.asset_id := c_rec.asset_id;


      -- loop through the assets in the book calling api for each
      FA_DEPRN_ROLLBACK_PUB.do_rollback
         (p_api_version             => 1.0,
          p_init_msg_list           => FND_API.G_FALSE,
          p_commit                  => FND_API.G_FALSE,
          p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
          x_return_status           => l_return_status,
          x_msg_count               => l_msg_count,
          x_msg_data                => l_msg_data,
          p_calling_fn              => null,
          px_asset_hdr_rec          => l_asset_hdr_rec);

      if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
         raise faxdrb_err ;
      end if;

   end loop;


   -- reset deprn_run to indicate that depreciation has been
   -- rolled back

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add('Updating FA_DEPRN_PERIODS',
                       'DEPRN_RUN',
                       'NULL',
                       p_log_level_rec => g_log_level_rec);
   end if;

   update fa_deprn_periods_mrc_v
      set deprn_run          = null
    where book_type_code     = p_book_type_code
      and period_counter     = l_period_counter
      and period_close_date is null
      and deprn_run          = 'Y';

   update fa_deprn_periods
      set deprn_run          = null
    where book_type_code     = p_book_type_code
      and period_counter     = l_period_counter
      and period_close_date is null
      and deprn_run          = 'Y';


   /*=================================================================
     End mass transaction and unlock the book.
     ===================================================================*/
   IF NOT FA_BEGIN_MASS_TRX_PKG.faxemt(
             X_book          => p_book_type_code,
             X_request_id    => l_request_id,
             p_log_level_rec => g_log_level_rec) THEN
      FA_SRVR_MSG.Add_Message(
         CALLING_FN => 'fa_deprn_rollback_pkg.do_rollback',
          p_log_level_rec => g_log_level_rec);
   END IF;

   -- Commit all deletes and updates done to rollback deprn
   COMMIT;

   -- Dump Debug messages when run in debug mode to log file

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.Write_Debug_Log;
   end if;

   fa_srvr_msg.add_message(
      calling_fn => 'fa_deprn_rollback_pkg.do_rollback',
      name       => 'FA_SHARED_END_SUCCESS',
      token1     => 'PROGRAM',
      value1     => 'FADRB',
      p_log_level_rec => g_log_level_rec);

   FND_MSG_PUB.Count_And_Get(
      p_count         => l_msg_count,
      p_data          => l_msg_data);

   fa_srvr_msg.Write_Msg_Log(l_msg_count, l_msg_data);

   -- return success to concurrent manager
   retcode := 0;

EXCEPTION
   WHEN faxdrb_err THEN
      ROLLBACK WORK;

      IF l_trx_approval THEN
         IF NOT FA_BEGIN_MASS_TRX_PKG.faxemt(
                   X_book          => p_book_type_code,
                   X_request_id    => l_request_id,
                   p_log_level_rec => g_log_level_rec) THEN
            FA_SRVR_MSG.Add_Message(
               CALLING_FN => 'fa_deprn_rollback_pkg.do_rollback',
               p_log_level_rec => g_log_level_rec);
         END IF;
      END IF;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.Write_Debug_Log;
      end if;

      FND_MSG_PUB.Count_And_Get(
         p_count         => l_msg_count,
         p_data          => l_msg_data);

      fa_srvr_msg.Write_Msg_Log(l_msg_count, l_msg_data);

      -- return failure to concurrent manager
      retcode := 2;

   WHEN OTHERS THEN
      ROLLBACK WORK;

      IF l_trx_approval THEN
         IF NOT FA_BEGIN_MASS_TRX_PKG.faxemt(
                   X_book          => p_book_type_code,
                   X_request_id    => l_request_id,
                   p_log_level_rec => g_log_level_rec) THEN
            FA_SRVR_MSG.Add_Message(
               CALLING_FN => 'fa_deprn_rollback_pkg.do_rollback',
               p_log_level_rec => g_log_level_rec);
         END IF;
      END IF;

      fa_srvr_msg.add_sql_error (calling_fn => 'fa_deprn_rollback_pkg.do_rollback'
            ,p_log_level_rec => g_log_level_rec);
      fa_srvr_msg.add_message(
         calling_fn => 'fa_deprn_rollback_pkg.do_rollback',
         name       => 'FA_SHARED_END_WITH_ERROR',
         token1     => 'PROGRAM',
         value1     => 'FADRB',
         p_log_level_rec => g_log_level_rec);

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.Write_Debug_Log;
      end if;

      FND_MSG_PUB.Count_And_Get(
         p_count         => l_msg_count,
         p_data          => l_msg_data);

      fa_srvr_msg.Write_Msg_Log(l_msg_count, l_msg_data);

      -- return failure to concurrent manager
      retcode := 2;

END do_rollback;

END FA_DEPRN_ROLLBACK_PKG;

/
