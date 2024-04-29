--------------------------------------------------------
--  DDL for Package Body FA_SUPER_GROUP_CHANGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_SUPER_GROUP_CHANGE_PKG" AS
/* $Header: FAXPSGCB.pls 120.4.12010000.2 2009/07/19 11:09:31 glchen ship $ */


g_log_level_rec fa_api_types.log_level_rec_type;


PROCEDURE do_super_group_change(
                errbuf                  OUT NOCOPY VARCHAR2,
                retcode                 OUT NOCOPY NUMBER) IS

    l_calling_fn   varchar2(60) := 'fa_super_group_change_pkg.do_super_group_change';
    l_calling_fn2  varchar2(60) := 'do_super_group_change';

    h_msg_count    NUMBER := 0;
    h_msg_data     VARCHAR2(2000) := NULL;
    l_trx_approval BOOLEAN;

    --++++++++++++++++++ Table types ++++++++++++++++++
    TYPE tab_num15_type IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
    TYPE tab_char15_type IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
    TYPE tab_date_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;

    t_super_group_id        tab_num15_type;
    t_book_type_code        tab_char15_type;
    t_start_period_counter  tab_num15_type;
    t_end_period_counter    tab_num15_type;
    t_asset_id              tab_num15_type;
    t_dpis                  tab_date_type;

    CURSOR c_get_sg_change IS
      SELECT super_group_id
           , book_type_code
           , start_period_counter
           , end_period_counter
      FROM   fa_super_group_rules
      WHERE  adjustment_required_flag = 'Y'
      AND    date_ineffective is null
      ORDER BY book_type_code, start_period_counter;

    CURSOR c_check_sg_used(c_super_group_id number
                         , c_book_type_code varchar2) IS
      SELECT asset_id
           , date_placed_in_service
      FROM   fa_books
      WHERE  book_type_code = c_book_type_code
      AND    super_group_id = c_super_group_id
      AND    transaction_header_id_out is null;

    CURSOR c_get_trx_date (c_book_type_code varchar2,
                           c_period_counter number) IS
      SELECT cp.start_date
      FROM   fa_calendar_periods cp
           , fa_calendar_types ct
           , fa_fiscal_year fy
           , fa_book_controls bc
      WHERE  bc.book_type_code = c_book_type_code
      AND    ct.calendar_type = bc.deprn_calendar
      AND    ct.calendar_type = cp.calendar_type
      AND    ct.fiscal_year_name = fy.fiscal_year_name
      AND    fy.fiscal_year = trunc(c_period_counter/ct.number_per_fiscal_year)
      AND    cp.period_num = round(((c_period_counter/ct.number_per_fiscal_year)
                                    - fy.fiscal_year)*ct.number_per_fiscal_year)
      AND    cp.start_date between fy.start_date and fy.end_date;


    l_limit     BINARY_INTEGER := 500;


    l_trans_rec                  FA_API_TYPES.trans_rec_type;
    l_asset_hdr_rec              FA_API_TYPES.asset_hdr_rec_type;
    l_asset_desc_rec             FA_API_TYPES.asset_desc_rec_type;
    l_asset_type_rec             FA_API_TYPES.asset_type_rec_type;
    l_asset_cat_rec              FA_API_TYPES.asset_cat_rec_type;
    l_asset_fin_rec_old          FA_API_TYPES.asset_fin_rec_type;
    l_asset_fin_rec_adj          FA_API_TYPES.asset_fin_rec_type;
    l_asset_fin_rec_new          FA_API_TYPES.asset_fin_rec_type;
    l_inv_trans_rec              FA_API_TYPES.inv_trans_rec_type;
    l_asset_deprn_rec_old        FA_API_TYPES.asset_deprn_rec_type;
    l_asset_deprn_rec_adj        FA_API_TYPES.asset_deprn_rec_type;
    l_asset_deprn_rec_new        FA_API_TYPES.asset_deprn_rec_type;
    l_period_rec                 FA_API_TYPES.period_rec_type;
    l_asset_fin_mrc_tbl_new      FA_API_TYPES.asset_fin_tbl_type;

    l_asset_deprn_mrc_tbl_new    FA_API_TYPES.asset_deprn_tbl_type;
    l_inv_tbl                    FA_API_TYPES.inv_tbl_type;
    l_group_reclass_options_rec  FA_API_TYPES.group_reclass_options_rec_type;

    l_mrc_sob_type_code VARCHAR2(1);

    l_book_type_code  VARCHAR2(30);
    l_request_id      NUMBER(15);
    l_temp_sysdate    DATE;
    l_sg_processed    NUMBER(15) := 0;
    l_bk_processed    VARCHAR2(15);
    l_process_sgc     BOOLEAN;

    l_api_version       NUMBER := 1.0;
    l_init_msg_list     VARCHAR2(1) := 'T';
    l_commit            VARCHAR2(1) := 'F';
    l_validation_level  NUMBER := 100;
    l_return_status     VARCHAR2(10);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(512);


   fapsgc_err         EXCEPTION;

BEGIN

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise   fapsgc_err;
      end if;
   end if;

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn2,'Begin', 1, p_log_level_rec => g_log_level_rec);
   end if;

   fa_srvr_msg.Init_Server_Message; -- Initialize server message stack
   fa_debug_pkg.Initialize;         -- Initialize debug message stack

/*

 1. Fetch all updated super group rules.
    take the earliest one and process adjustment for all groups
    which has this super group assigned.
 2. When going to next record, if it is the same as precious
    super group, skip and fetch next.  If it has difference super group
    id, process as 1.
 3. when processing, follow program flow as default one (rollback deprn).


Processing super group change.
 1.  Create super_group_id in dpr struct in pro*c and pl/sql
 2.  Modify G1 cursor to make not to join fa_super_group_rules.
 3.  populate super_group_id in G1.
 4.  Create cache program for super group rules.
 5.  in faxcde, in the early stage, get super group rules info if super_group_id is populated
 6.  replace with super group info (deprn rate) etc...


Deprn
 1. if possible, create array to store super group id and it's rec cost, reserve and deprn expense
 2. check to see if it is fully reserved at super gorup level.
 3.  If rec cost < reserve, then either redistribute recalculated (use subtraction) amount
     or take out excess amounts evenly.
 4. set period counter fully reserved for all suepr group assigned group.
*5. create function to unset period counter fully reserved if super group id
    is not null and which result in increase of nbv for the group asset.
    Also if the super group is assigned to a group, unset period counter fully
    reserved for all groups which has the super group assigned.
 6. If super group id is changed to different one, need to check as well.

 */

   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn2,'Start Processing', 'Main', p_log_level_rec => g_log_level_rec);
   end if;

   OPEN c_get_sg_change;

   LOOP -- loop through each 500 of super group changes
      t_super_group_id.delete;

      FETCH c_get_sg_change BULK COLLECT INTO t_super_group_id
                                            , t_book_type_code
                                            , t_start_period_counter
                                            , t_end_period_counter LIMIT l_limit;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Number of super group changes fetched',
                          t_super_group_id.COUNT, p_log_level_rec => g_log_level_rec);
      end if;

      EXIT WHEN t_super_group_id.COUNT = 0;

      FOR i IN 1..t_super_group_id.COUNT LOOP -- super group for loop

         l_process_sgc := TRUE;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 't_super_group_id('||to_char(i)||')',
                             t_super_group_id(i));
            fa_debug_pkg.add(l_calling_fn, 't_book_type_code('||to_char(i)||')',
                             t_book_type_code(i));
            fa_debug_pkg.add(l_calling_fn, 't_start_period_counter('||to_char(i)||')',
                             t_start_period_counter(i));
            fa_debug_pkg.add(l_calling_fn, 't_end_period_counter('||to_char(i)||')',
                             t_end_period_counter(i));

         end if;

         if (l_sg_processed <> t_super_group_id(i)) then
            l_sg_processed := t_super_group_id(i);
            l_bk_processed := t_book_type_code(i);
         elsif (l_bk_processed <> t_book_type_code(i)) then
            l_bk_processed := t_book_type_code(i);
         else
            l_process_sgc := FALSE;
         end if;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'l_process_sgc', l_process_sgc, p_log_level_rec => g_log_level_rec);
         end if;

         if (l_process_sgc) then
            OPEN c_check_sg_used (t_super_group_id(i), t_book_type_code(i));

            l_book_type_code := t_book_type_code(i);
            l_temp_sysdate := sysdate;

            FETCH c_check_sg_used BULK COLLECT INTO t_asset_id, t_dpis;

            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Number of group assets fetched',
                                t_asset_id.COUNT, p_log_level_rec => g_log_level_rec);
            end if;

            FOR j IN 1..t_asset_id.COUNT LOOP -- group asset for loop

               if (g_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 't_asset_id('||to_char(j)||')',
                                   t_asset_id(j));
               end if;

               --=============================================
               -- Get transaction approval and lock the book.
               --=============================================
               l_request_id := fnd_global.conc_request_id;

               IF NOT FA_BEGIN_MASS_TRX_PKG.faxbmt(
                                       X_book          => l_book_type_code,
                                       X_request_id    => l_request_id,
                                       X_result        => l_trx_approval, p_log_level_rec => g_log_level_rec) THEN
                  RAISE fapsgc_err;
               END IF;

               IF NOT l_trx_approval THEN
               -- Transaction was not approved.
                  fa_srvr_msg.add_message(
                                     calling_fn => 'fa_super_group_change.do_super_group_change',
                                     name       => 'FA_TRXAPP_LOCK_FAILED',
                                     token1     => 'BOOK',
                                     value1     => l_book_type_code, p_log_level_rec => g_log_level_rec);
                  RAISE fapsgc_err ;
               END IF;

               -- Commit the change made to fa_book_controls table to lock the book.
               FND_CONCURRENT.AF_COMMIT;

               --
               -- Prepare to call FA_ADJUSTMENT_PUB.do_adjustment to process group
               -- asset after member asset retirement.
               --
               l_trans_rec.transaction_type_code := 'GROUP ADJUSTMENT';
               l_trans_rec.transaction_subtype := 'AMORTIZED';

               OPEN c_get_trx_date (t_book_type_code(i),
                                    t_start_period_counter(i));
               FETCH c_get_trx_date INTO l_trans_rec.transaction_date_entered;
               CLOSE c_get_trx_date;

               if (l_trans_rec.transaction_date_entered < t_dpis(j)) then
                  l_trans_rec.transaction_date_entered := t_dpis(j);
               end if;

               l_trans_rec.amortization_start_date := l_trans_rec.transaction_date_entered;
               l_trans_rec.transaction_date_entered := null;
               l_trans_rec.transaction_key := 'SG';
               l_trans_rec.who_info.creation_date := l_temp_sysdate;
               l_trans_rec.who_info.created_by := FND_GLOBAL.USER_ID;
               l_trans_rec.who_info.last_update_date := l_temp_sysdate;
               l_trans_rec.who_info.last_updated_by := FND_GLOBAL.USER_ID;
               l_trans_rec.who_info.last_update_login := FND_GLOBAL.USER_ID;
               l_trans_rec.member_transaction_header_id := null;
               l_trans_rec.mass_transaction_id := null;
               l_trans_rec.calling_interface := 'FAPSGC';
               l_trans_rec.mass_reference_id := l_request_id;

               l_asset_hdr_rec.asset_id := t_asset_id(j);
               l_asset_hdr_rec.book_type_code := t_book_type_code(i);
               l_asset_hdr_rec.set_of_books_id := null;

               if not FA_UTIL_PVT.get_asset_type_rec (
                                  p_asset_hdr_rec      => l_asset_hdr_rec,
                                  px_asset_type_rec    => l_asset_type_rec, p_log_level_rec => g_log_level_rec) then
                  if (g_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Failed calling function',
                                      'FA_UTIL_PVT.get_asset_type_rec',  p_log_level_rec => g_log_level_rec);
                  end if;

                  raise fapsgc_err;
               end if;

               if not FA_UTIL_PVT.get_asset_desc_rec (
                                  p_asset_hdr_rec         => l_asset_hdr_rec,
                                  px_asset_desc_rec       => l_asset_desc_rec, p_log_level_rec => g_log_level_rec) then
                  if (g_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Failed calling function',
                                      'FA_UTIL_PVT.get_asset_desc_rec',  p_log_level_rec => g_log_level_rec);
                  end if;

                  raise fapsgc_err;
               end if;

               if not FA_UTIL_PVT.get_asset_cat_rec (
                                  p_asset_hdr_rec         => l_asset_hdr_rec,
                                  px_asset_cat_rec        => l_asset_cat_rec,
                                  p_date_effective        => null, p_log_level_rec => g_log_level_rec) then
                  if (g_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Failed calling function',
                                      'FA_UTIL_PVT.get_asset_cat_rec',  p_log_level_rec => g_log_level_rec);
                  end if;

                  raise fapsgc_err;
               end if;


               if (g_log_level_rec.statement_level) then
                     fa_debug_pkg.add('-', '-----', '--------------------------', p_log_level_rec => g_log_level_rec);
                     fa_debug_pkg.add(l_calling_fn, 'Calling Adjustment API', t_asset_id(j));
                     fa_debug_pkg.add('-', '-----', '--------------------------', p_log_level_rec => g_log_level_rec);
               end if;

               fa_adjustment_pub.do_adjustment
                     (p_api_version               => l_api_version,
                      p_init_msg_list             => l_init_msg_list,
                      p_commit                    => l_commit,
                      p_validation_level          => l_validation_level,
                      p_calling_fn                => l_calling_fn,
                      x_return_status             => l_return_status,
                      x_msg_count                 => l_msg_count,
                      x_msg_data                  => l_msg_data,
                      px_trans_rec                => l_trans_rec,
                      px_asset_hdr_rec            => l_asset_hdr_rec,
                      p_asset_fin_rec_adj         => l_asset_fin_rec_adj,
                      x_asset_fin_rec_new         => l_asset_fin_rec_new,
                      x_asset_fin_mrc_tbl_new     => l_asset_fin_mrc_tbl_new,
                      p_asset_deprn_rec_adj       => l_asset_deprn_rec_adj,
                      x_asset_deprn_rec_new       => l_asset_deprn_rec_new,
                      x_asset_deprn_mrc_tbl_new   => l_asset_deprn_mrc_tbl_new,
                      px_inv_trans_rec            => l_inv_trans_rec,
                      px_inv_tbl                  => l_inv_tbl,
                      p_group_reclass_options_rec => l_group_reclass_options_rec
                     );

               if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                  raise fapsgc_err;
               end if;

               --=============================================
               -- End mass transaction and unlock the book.
               --=============================================
               IF NOT FA_BEGIN_MASS_TRX_PKG.faxemt(
                                  X_book          => l_book_type_code,
                                  X_request_id    => l_request_id, p_log_level_rec => g_log_level_rec) THEN
                  FA_SRVR_MSG.Add_Message(
                               CALLING_FN => 'fa_super_group_change.do_super_group_change', p_log_level_rec => g_log_level_rec);
               END IF;

            END LOOP; -- group asset for loop

            CLOSE c_check_sg_used;

            update fa_super_group_rules
            set    adjustment_required_flag = 'N'
            where  super_group_id = t_super_group_id(i)
            and    book_type_code = t_book_type_code(i)
            and    adjustment_required_flag = 'Y';

            FND_CONCURRENT.AF_COMMIT;

         end if;  -- (l_process_sgc)

      END LOOP; -- super group for loop

      EXIT WHEN c_get_sg_change%NOTFOUND;

   END LOOP; -- super group change loop

   CLOSE c_get_sg_change;


   -- Dump Debug messages when run in debug mode to log file
   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.Write_Debug_Log;
   end if;

   fa_srvr_msg.add_message(
                calling_fn => 'fa_super_group_change.do_super_group_change',
                name       => 'FA_SHARED_END_SUCCESS',
                token1     => 'PROGRAM',
                value1     => 'FAPSGC', p_log_level_rec => g_log_level_rec);

   FND_MSG_PUB.Count_And_Get(
                p_count         => h_msg_count,
                p_data          => h_msg_data);

   fa_srvr_msg.Write_Msg_Log(h_msg_count, h_msg_data, p_log_level_rec => g_log_level_rec);

   -- return success to concurrent manager

   retcode := 0;

EXCEPTION
   WHEN fapsgc_err THEN
      FND_CONCURRENT.AF_ROLLBACK;

      IF l_trx_approval THEN
         IF NOT FA_BEGIN_MASS_TRX_PKG.faxemt(
                        X_book          => l_book_type_code,
                        X_request_id    => l_request_id, p_log_level_rec => g_log_level_rec) THEN
            FA_SRVR_MSG.Add_Message(CALLING_FN => 'fa_deprn_rollback_pkg.do_rollback',  p_log_level_rec => g_log_level_rec);
         END IF;
      END IF;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.Write_Debug_Log;
      end if;

      FND_MSG_PUB.Count_And_Get(p_count => h_msg_count,
                	        p_data  => h_msg_data);

      fa_srvr_msg.Write_Msg_Log(h_msg_count, h_msg_data, p_log_level_rec => g_log_level_rec);

      -- return failure to concurrent manager
      retcode := 2;

   WHEN OTHERS THEN
      FND_CONCURRENT.AF_ROLLBACK;

      IF l_trx_approval THEN
         IF NOT FA_BEGIN_MASS_TRX_PKG.faxemt(
                        X_book          => l_book_type_code,
                        X_request_id    => l_request_id, p_log_level_rec => g_log_level_rec) THEN
            FA_SRVR_MSG.Add_Message(
                        CALLING_FN => 'fa_super_group_change.do_super_group_change', p_log_level_rec => g_log_level_rec);
         END IF;
      END IF;

      fa_srvr_msg.add_sql_error (
                        calling_fn => 'fa_super_group_change.do_super_group_change', p_log_level_rec => g_log_level_rec);
      fa_srvr_msg.add_message(
                        calling_fn => 'fa_super_group_change.do_super_group_change',
                        name       => 'FA_SHARED_END_WITH_ERROR',
                        token1     => 'PROGRAM',
                        value1     => 'FAPSGC', p_log_level_rec => g_log_level_rec);

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.Write_Debug_Log;
      end if;
      FND_MSG_PUB.Count_And_Get(
                        p_count         => h_msg_count,
                        p_data          => h_msg_data);
      fa_srvr_msg.Write_Msg_Log(h_msg_count, h_msg_data, p_log_level_rec => g_log_level_rec);

      -- return failure to concurrent manager
      retcode := 2;
END do_super_group_change;

END FA_SUPER_GROUP_CHANGE_PKG;

/
