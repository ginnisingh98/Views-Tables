--------------------------------------------------------
--  DDL for Package Body FA_PROCESS_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_PROCESS_GROUPS_PKG" AS
/* $Header: FAPGADJB.pls 120.13.12010000.11 2010/02/01 14:58:05 bmaddine ship $ */
TYPE num_tbl  IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;
TYPE date_tbl IS TABLE OF DATE         INDEX BY BINARY_INTEGER;
TYPE v30_tbl  IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

g_log_level_rec fa_api_types.log_level_rec_type;
g_release       number  := fa_cache_pkg.fazarel_release;

--*********************** Private functions ******************************--
-- private declaration for books (mrc) wrapper
FUNCTION do_all_books(
                p_book                  IN  VARCHAR2,
                p_source_group_asset_id IN  NUMBER DEFAULT NULL,
                p_dest_group_asset_id   IN  NUMBER DEFAULT NULL,
                p_trx_number            IN  NUMBER DEFAULT NULL)
                        RETURN BOOLEAN;

PROCEDURE do_pending_groups(
                errbuf                  OUT NOCOPY VARCHAR2,
                retcode                 OUT NOCOPY NUMBER,
                p_book                  IN  VARCHAR2,
                p_source_group_asset_id IN  NUMBER,
                p_dest_group_asset_id   IN  NUMBER DEFAULT NULL,
                p_trx_number            IN  NUMBER DEFAULT NULL) IS

    l_calling_fn   varchar2(60) :=
                'fa_process_groups_pkg.do_pending_groups';
    l_calling_fn2  varchar2(60) := 'do_pending_groups';

    l_msg_count         NUMBER := 0;
    l_msg_data          VARCHAR2(2000) := NULL;

    group_adj_err       exception;

BEGIN

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise  FND_API.G_EXC_ERROR;
      end if;
   end if;

   g_release := fa_cache_pkg.fazarel_release;

   fa_srvr_msg.Init_Server_Message; -- Initialize server message stack
   fa_debug_pkg.Initialize;         -- Initialize debug message stack

   if not do_all_books(
                p_book                  => p_book,
                p_source_group_asset_id => p_source_group_asset_id,
                p_dest_group_asset_id   => p_dest_group_asset_id,
                p_trx_number            => p_trx_number) then
      raise group_adj_err;
   end if;

   -- Dump Debug messages when run in debug mode to log file
   if (g_log_level_rec.statement_level) then
      fa_debug_pkg.Write_Debug_Log;
   end if;

   fa_srvr_msg.add_message(
                calling_fn => NULL, --Bug 8528173
                name       => 'FA_SHARED_END_SUCCESS',
                token1     => 'PROGRAM',
                value1     => 'FAPGADJ', p_log_level_rec => g_log_level_rec);

   FND_MSG_PUB.Count_And_Get(
                p_count         => l_msg_count,
                p_data          => l_msg_data);

   fa_srvr_msg.Write_Msg_Log(l_msg_count, l_msg_data, p_log_level_rec => g_log_level_rec);

   -- return success to concurrent manager
   retcode := 0;

EXCEPTION
   WHEN GROUP_ADJ_ERR THEN
      ROLLBACK WORK;
      fa_srvr_msg.add_message(
                 calling_fn => 'fa_process_groups_pkg.do_pending_groups',
                 name       => 'FA_SHARED_END_WITH_ERROR',
                 token1     => 'PROGRAM',
                 value1     => 'FAPGADJ',  p_log_level_rec => g_log_level_rec);

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.Write_Debug_Log;
      end if;
      FND_MSG_PUB.Count_And_Get(
                        p_count         => l_msg_count,
                        p_data          => l_msg_data);
      fa_srvr_msg.Write_Msg_Log(l_msg_count, l_msg_data, p_log_level_rec => g_log_level_rec);
      -- return failure to concurrent manager
      retcode := 2;
   WHEN OTHERS THEN
      ROLLBACK WORK;
      fa_srvr_msg.add_sql_error (
                calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      fa_srvr_msg.add_message(
                calling_fn => l_calling_fn,
                name       => 'FA_SHARED_END_WITH_ERROR',
                token1     => 'PROGRAM',
                value1     => 'FAPGADJ', p_log_level_rec => g_log_level_rec);

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.Write_Debug_Log;
      end if;
      FND_MSG_PUB.Count_And_Get(
                        p_count         => l_msg_count,
                        p_data          => l_msg_data);
      fa_srvr_msg.Write_Msg_Log(l_msg_count, l_msg_data, p_log_level_rec => g_log_level_rec);
      -- return failure to concurrent manager
      retcode := 2;
END do_pending_groups;

FUNCTION do_all_books(
                p_book                  IN  VARCHAR2,
                p_source_group_asset_id IN  NUMBER DEFAULT NULL,
                p_dest_group_asset_id   IN  NUMBER DEFAULT NULL,
                p_trx_number            IN  NUMBER DEFAULT NULL)
                        RETURN BOOLEAN IS

   -- source group asset
   -- if not group reclass then this is the only group which is being
   -- impacted by member trxn
   l_trans_rec                  FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec              FA_API_TYPES.asset_hdr_rec_type;
   l_asset_desc_rec             FA_API_TYPES.asset_desc_rec_type;
   l_asset_type_rec             FA_API_TYPES.asset_type_rec_type;
   l_asset_cat_rec              FA_API_TYPES.asset_cat_rec_type;
   l_asset_fin_rec_old          FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_rec_adj          FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_rec_new          FA_API_TYPES.asset_fin_rec_type;
   l_asset_deprn_rec_old        FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_rec_adj        FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_rec_new        FA_API_TYPES.asset_deprn_rec_type;
   l_period_rec                 FA_API_TYPES.period_rec_type;

   l_asset_fin_rec_adj_null     FA_API_TYPES.asset_fin_rec_type;
   l_asset_deprn_rec_adj_null   FA_API_TYPES.asset_deprn_rec_type;

   l_trx_ref_rec                fa_api_types.trx_ref_rec_type;

   l_sob_tbl                    FA_CACHE_PKG.fazcrsob_sob_tbl_type;
   l_mrc_sob_type_code          varchar2(1);

   l_source_asset_id            number;
   l_dest_asset_id              number;
   l_asset_id                   number;
   l_old_trx_id                 number;
   l_trx_id_in                  number;

   l_adj_count                  number;

   l_reclassed_asset_id         number;
   l_reclass_src_dest           varchar2(10);
   l_reclassed_asset_dpis       date;
   l_deprn_exp                  number;
   l_bonus_deprn_exp            number;
   l_impairment_exp             number;
   l_rowid                      rowid;

   l_deprn_rsv                  number;

   -- HHIRAGA added
   l_group_level_override       varchar2(1) := NULL;
   x_new_deprn_amount           number;
   x_new_bonus_amount           number;
   l_rc                         number;

   -- SLA
   l_thid                       number(15);
   l_prior_trx_reference_id     number(15) := 0;
   l_prior_trx_count            number(15);
   l_event_type_code            varchar2(30);
   l_trx_ref_type               varchar2(30);
   l_asset_type                 varchar2(30);
   l_src_asset_type             varchar2(30);
   l_dest_asset_type            varchar2(30);

   l_calling_fn   varchar2(60) :=
                'fa_process_groups_pkg.do_all_books';

   cursor get_group_assets is
        select  bk.asset_id,
                bk.transaction_header_id_in,
                bk.rowid,
                th.transaction_type_code,
                th.transaction_date_entered,
                th.transaction_subtype,
                th.transaction_key,
                th.amortization_start_date,
                th.calling_interface,
                th.member_transaction_header_id,
                th.trx_reference_id,
                th.event_id
        from fa_books bk,
             fa_transaction_headers th
        where bk.asset_id in (l_source_asset_id, l_dest_asset_id)
        and   bk.book_type_code = p_book
        and   bk.adjustment_required_status = 'GADJ'
        and   bk.date_ineffective is null
        and   th.transaction_header_id = bk.transaction_header_id_in
        order by bk.transaction_header_id_in;

   cursor get_all_groups is
        select  bk.asset_id,
                bk.transaction_header_id_in,
                bk.rowid,
                th.transaction_type_code,
                th.transaction_date_entered,
                th.transaction_subtype,
                th.transaction_key,
                th.amortization_start_date,
                th.calling_interface,
                th.member_transaction_header_id,
                th.trx_reference_id,
                th.event_id
        from fa_books bk,
             fa_transaction_headers th
        where bk.book_type_code = p_book
        and   bk.adjustment_required_status = 'GADJ'
        and   bk.date_ineffective is null
        and   th.transaction_header_id = bk.transaction_header_id_in
        order by bk.transaction_header_id_in;

   cursor get_old_trx is
        select transaction_header_id_in
        from fa_books
        where asset_id = l_asset_id
        and   book_type_code = p_book
        and   transaction_header_id_out = l_trx_id_in;

   cursor check_adj_status is
        select count(*)
        from fa_books
        where transaction_header_id_in = l_trx_id_in
        and   adjustment_required_status = 'GADJ';

   --Bug#8675920
   cursor check_mc_adj_status is
        select count(*)
        from fa_mc_books
        where transaction_header_id_in = l_trx_id_in
        and set_of_books_id = l_asset_hdr_rec.set_of_books_id
        and   adjustment_required_status = 'GADJ';

   cursor get_trx_ref is
        select  TRX_REFERENCE_ID,
                 TRANSACTION_TYPE,
                 SRC_TRANSACTION_SUBTYPE,
                 DEST_TRANSACTION_SUBTYPE,
                 BOOK_TYPE_CODE,
                 SRC_ASSET_ID,
                 SRC_TRANSACTION_HEADER_ID,
                 DEST_ASSET_ID,
                 DEST_TRANSACTION_HEADER_ID,
                 MEMBER_ASSET_ID,
                 MEMBER_TRANSACTION_HEADER_ID,
                 SRC_AMORTIZATION_START_DATE,
                 DEST_AMORTIZATION_START_DATE,
                 RESERVE_TRANSFER_AMOUNT,
                 SRC_EXPENSE_AMOUNT,
                 DEST_EXPENSE_AMOUNT,
                 SRC_EOFY_RESERVE,
                 DEST_EOFY_RESERVE
        from fa_trx_references
        where TRX_REFERENCE_ID = l_trans_rec.trx_reference_id;

   --
   -- Energy Enhancement.
   --
   CURSOR c_get_unplanned_amt IS
      select adjustment_amount
      from   fa_adjustments
      where  asset_id = l_asset_hdr_rec.asset_id
      and    book_type_code = l_asset_hdr_rec.book_type_code
      and    transaction_header_id = l_trans_rec.transaction_header_id;

   CURSOR c_mc_get_unplanned_amt IS
      select adjustment_amount
      from   fa_mc_adjustments
      where  asset_id = l_asset_hdr_rec.asset_id
      and    book_type_code = l_asset_hdr_rec.book_type_code
      and    transaction_header_id = l_trans_rec.transaction_header_id
      and    set_of_books_id = l_asset_hdr_rec.set_of_books_id;

   l_unplanned_deprn_rec  FA_API_TYPES.unplanned_deprn_rec_type;
   l_group_deprn_amount   NUMBER;
   l_group_bonus_amount   NUMBER;
   l_return_code          NUMBER;


   -- Cursor to get member's reserve retired
   CURSOR c_get_member_rsv_ret IS
      select nvl(reserve_retired, 0)
      from   fa_retirements
      where  transaction_header_id_in = l_trans_rec.member_transaction_header_id;

   CURSOR c_mc_get_member_rsv_ret IS
      select nvl(reserve_retired, 0)
      from   fa_mc_retirements
      where  transaction_header_id_in = l_trans_rec.member_transaction_header_id
      and    set_of_books_id = l_asset_hdr_rec.set_of_books_id;

   CURSOR c_get_member_rsv_rei IS
      select nvl(reserve_retired, 0)
           , transaction_header_id_in
      from   fa_retirements
      where  transaction_header_id_out = l_trans_rec.member_transaction_header_id;

   CURSOR c_mc_get_member_rsv_rei IS
      select nvl(reserve_retired, 0)
           , transaction_header_id_in
      from   fa_mc_retirements
      where  transaction_header_id_out = l_trans_rec.member_transaction_header_id
      and    set_of_books_id = l_asset_hdr_rec.set_of_books_id;


   -- Cursor to get group's reserve retired
   CURSOR c_get_group_rsv_ret IS
      select sum(decode(debit_credit_flag, 'CR', -1, 1) *
                 decode(l_trans_rec.transaction_key, 'MR', 1, -1) *
                 adjustment_amount)
      from   fa_adjustments
      where  asset_id = l_asset_hdr_rec.asset_id
      and    book_type_code = l_asset_hdr_rec.book_type_code
      and    transaction_header_id = l_trans_rec.transaction_header_id
      and    adjustment_type = 'RESERVE';

   CURSOR c_mc_get_group_rsv_ret IS --Bug 9076882
      select sum(decode(debit_credit_flag, 'CR', -1, 1) *
                 decode(l_trans_rec.transaction_key, 'MR', 1, -1) *
                 adjustment_amount)
      from   fa_mc_adjustments
      where  asset_id = l_asset_hdr_rec.asset_id
      and    book_type_code = l_asset_hdr_rec.book_type_code
      and    transaction_header_id = l_trans_rec.transaction_header_id
      and    adjustment_type = 'RESERVE'
      and    set_of_books_id = l_asset_hdr_rec.set_of_books_id;


   l_member_reserve_amount   number;
   l_group_reserve_amount    number;

   CURSOR c_get_member_trx is
      select th.asset_id
           , th.transaction_header_id
           , th.transaction_type_code
           , th.transaction_date_entered
           , th.transaction_name
           , th.source_transaction_header_id
           , th.mass_reference_id
           , th.transaction_subtype
           , th.transaction_key
           , th.amortization_start_date
           , th.calling_interface
           , th.mass_transaction_id
           , th.member_transaction_header_id
           , th.trx_reference_id
           , th.last_update_date
           , th.last_updated_by
           , th.last_update_login
           , th.event_id
           , tr.transaction_type
      from   fa_transaction_headers th,
             fa_trx_references tr  --Added for bug 537059
      where  th.transaction_header_id = l_trans_rec.member_transaction_header_id
      and    tr.trx_reference_id(+) = th.trx_reference_id;  --Added for bug 537059



   lm_trans_rec              FA_API_TYPES.trans_rec_type;
   lm_asset_hdr_rec          FA_API_TYPES.asset_hdr_rec_type;
   lm_asset_desc_rec         FA_API_TYPES.asset_desc_rec_type;
   lm_asset_fin_rec          FA_API_TYPES.asset_fin_rec_type;
   lm_asset_cat_rec          FA_API_TYPES.asset_cat_rec_type;
   lm_asset_type_rec         FA_API_TYPES.asset_type_rec_type;
   lm_asset_deprn_rec        FA_API_TYPES.asset_deprn_rec_type;

   l_mem_ret_thid            NUMBER; -- Member asset retirement thid

   l_return_status  varchar2(10);
   l_msg_count      number;
   l_msg_data       varchar2(512);

   group_adj_err      exception;

   TRX_CUR             boolean := FALSE;
   BOOK_CUR            boolean := FALSE;

   -- Bug 8862296 Changes start here
   l_src_trans_rec                 FA_API_TYPES.trans_rec_type;
   l_src_asset_hdr_rec             FA_API_TYPES.asset_hdr_rec_type;
   l_dest_trans_rec                FA_API_TYPES.trans_rec_type;
   l_dest_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;
   l_inv_trans_rec                 FA_API_TYPES.inv_trans_rec_type;
   l_dest_inv_tbl                  FA_API_TYPES.inv_tbl_type;

   CURSOR c_get_trx_reference IS
   SELECT SRC_ASSET_ID,
          BOOK_TYPE_CODE,
          SRC_TRANSACTION_HEADER_ID,
          SRC_TRANSACTION_SUBTYPE,
          SRC_AMORTIZATION_START_DATE,
          TRX_REFERENCE_ID,
          EVENT_ID,
          DEST_ASSET_ID,
          BOOK_TYPE_CODE,
          DEST_TRANSACTION_HEADER_ID,
          DEST_TRANSACTION_SUBTYPE,
          DEST_AMORTIZATION_START_DATE,
          TRX_REFERENCE_ID,
          EVENT_ID,
          TRANSACTION_TYPE,
          INVOICE_TRANSACTION_ID
     FROM FA_TRX_REFERENCES
    WHERE SRC_TRANSACTION_HEADER_ID = P_TRX_NUMBER;

   CURSOR c_inv_tbl IS
   SELECT PO_VENDOR_ID,
          ASSET_INVOICE_ID,
          FIXED_ASSETS_COST,
          DELETED_FLAG,
          PO_NUMBER,
          INVOICE_NUMBER,
          PAYABLES_BATCH_NAME,
          PAYABLES_CODE_COMBINATION_ID,
          FEEDER_SYSTEM_NAME,
          CREATE_BATCH_DATE,
          CREATE_BATCH_ID,
          INVOICE_DATE,
          PAYABLES_COST,
          POST_BATCH_ID,
          INVOICE_ID,
          AP_DISTRIBUTION_LINE_NUMBER,
          PAYABLES_UNITS,
          SPLIT_MERGED_CODE,
          DESCRIPTION,
          PARENT_MASS_ADDITION_ID,
          UNREVALUED_COST,
          MERGED_CODE,
          SPLIT_CODE,
          MERGE_PARENT_MASS_ADDITIONS_ID,
          SPLIT_PARENT_MASS_ADDITIONS_ID,
          PROJECT_ASSET_LINE_ID,
          PROJECT_ID,
          TASK_ID,
          DEPRECIATE_IN_GROUP_FLAG,
          MATERIAL_INDICATOR_FLAG,
          SOURCE_LINE_ID,
          INVOICE_DISTRIBUTION_ID,
          INVOICE_LINE_NUMBER,
          PO_DISTRIBUTION_ID
     FROM FA_ASSET_INVOICES
    WHERE ASSET_ID = L_SRC_ASSET_HDR_REC.ASSET_ID
      AND INVOICE_TRANSACTION_ID_OUT = L_INV_TRANS_REC.INVOICE_TRANSACTION_ID;

   CURSOR c_inv_rate (P_SOURCE_LINE_ID IN NUMBER) IS
   SELECT MCAI.SET_OF_BOOKS_ID,
          MCAI.EXCHANGE_RATE,
          MCAI.FIXED_ASSETS_COST
     FROM FA_MC_ASSET_INVOICES MCAI,
          FA_MC_BOOK_CONTROLS  MCBK
    WHERE MCAI.SOURCE_LINE_ID  = P_SOURCE_LINE_ID
      AND MCAI.SET_OF_BOOKS_ID = MCBK.SET_OF_BOOKS_ID
      AND MCBK.BOOK_TYPE_CODE  = L_SRC_ASSET_HDR_REC.BOOK_TYPE_CODE
      AND MCBK.ENABLED_FLAG    = 'Y';

   i NUMBER;
   j NUMBER;
   -- Bug 8862296 Changes end here

BEGIN

   if (g_log_level_rec.statement_level) then
       fa_debug_pkg.add('do_pending_groups',
                        'do_all_books',
                        'begin', p_log_level_rec => g_log_level_rec);
   end if;

   -- call the sob cache to get the table of sob_ids
   if not FA_CACHE_PKG.fazcrsob
          (x_book_type_code => p_book,
           x_sob_tbl        => l_sob_tbl, p_log_level_rec => g_log_level_rec) then
      raise group_adj_err;
   end if;

   -- call the book_controls cache
   if NOT fa_cache_pkg.fazcbc(X_book => p_book, p_log_level_rec => g_log_level_rec) then
      raise group_adj_err;
   end if;

   l_source_asset_id := nvl(p_source_group_asset_id, -1);
   l_dest_asset_id := nvl(p_dest_group_asset_id,-1);

   if (l_source_asset_id = -1 and l_dest_asset_id = -1) then
      BOOK_CUR := TRUE;
      open get_all_groups;
   else
      TRX_CUR := TRUE;
      open get_group_assets;
   end if;
   loop

      -- recall the book_controls cache for each trx
      if NOT fa_cache_pkg.fazcbc(X_book => p_book,
                                 p_log_level_rec => g_log_level_rec) then
         raise group_adj_err;
      end if;

      if TRX_CUR then
          if (g_log_level_rec.statement_level) then
             fa_debug_pkg.add('do_pending_groups',
                        'CURSOR',
                        'USING TRX_CUR', p_log_level_rec => g_log_level_rec);
          end if;
         fetch get_group_assets into
                l_asset_id,
                l_trx_id_in,
                l_rowid,
                l_trans_rec.transaction_type_code,
                l_trans_rec.transaction_date_entered,
                l_trans_rec.transaction_subtype,
                l_trans_rec.transaction_key,
                l_trans_rec.amortization_start_date,
                l_trans_rec.calling_interface,
                l_trans_rec.member_transaction_header_id,
                l_trans_rec.trx_reference_id,
                l_trans_rec.event_id;
         if (get_group_assets%NOTFOUND) then
            exit;
         end if;
      elsif BOOK_CUR then
          if (g_log_level_rec.statement_level) then
             fa_debug_pkg.add('do_pending_groups',
                        'USING BOOK_CUR CURSOR',
                        'USING BOOK_CUR', p_log_level_rec => g_log_level_rec);
          end if;

         fetch get_all_groups into
                l_asset_id,
                l_trx_id_in,
                l_rowid,
                l_trans_rec.transaction_type_code,
                l_trans_rec.transaction_date_entered,
                l_trans_rec.transaction_subtype,
                l_trans_rec.transaction_key,
                l_trans_rec.amortization_start_date,
                l_trans_rec.calling_interface,
                l_trans_rec.member_transaction_header_id,
                l_trans_rec.trx_reference_id,
                l_trans_rec.event_id;

         if (get_all_groups%NOTFOUND) then
            exit;
         end if;
      end if;

      --bridgway: SLA, moving commit cycle here due to inter-asset transactions
      if (nvl(l_trans_rec.trx_reference_id, -99) <> nvl(l_prior_trx_reference_id, -99)) then
         fnd_concurrent.af_commit;
      end if;

      l_prior_trx_reference_id := l_trans_rec.trx_reference_id;


      l_trans_rec.transaction_header_id := l_trx_id_in;

      open get_old_trx;
      fetch get_old_trx into l_old_trx_id;
      close get_old_trx;

      l_asset_hdr_rec.asset_id := l_asset_id;
      l_asset_hdr_rec.book_type_code := p_book;
      l_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

      if (g_log_level_rec.statement_level) then
          fa_debug_pkg.add('do_pending_groups.do_all_books',
                        'fetched asset and trx',
                        l_asset_id || ' - ' || l_trx_id_in, p_log_level_rec => g_log_level_rec);
      end if;


      -- loop through each book starting with the primary and
      -- call the private API for each
      FOR l_sob_index in 0..l_sob_tbl.count LOOP
         if (l_sob_index = 0) then
            l_mrc_sob_type_code := 'P';
            l_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

            -- SLA uptake - set event status from incomplete to unprocessed
            -- need to determine original event type in this case
            --
            -- invoice transfer and group reclass pose a two-fold issue in that both
            -- events must be completely processed.
            --
            -- in order to call the api, we must know pretty much everything
            -- we new at time of the original member event including the
            -- asset type, etc

            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,
                           'fetching member_trx cursor',
                           '',
                           p_log_level_rec => g_log_level_rec);
            end if;

            if (l_trans_rec.member_transaction_header_id is not null) then

               OPEN c_get_member_trx;
               FETCH c_get_member_trx INTO lm_asset_hdr_rec.asset_id
                                         , lm_trans_rec.transaction_header_id
                                         , lm_trans_rec.transaction_type_code
                                         , lm_trans_rec.transaction_date_entered
                                         , lm_trans_rec.transaction_name
                                         , lm_trans_rec.source_transaction_header_id
                                         , lm_trans_rec.mass_reference_id
                                         , lm_trans_rec.transaction_subtype
                                         , lm_trans_rec.transaction_key
                                         , lm_trans_rec.amortization_start_date
                                         , lm_trans_rec.calling_interface
                                         , lm_trans_rec.mass_transaction_id
                                         , lm_trans_rec.member_transaction_header_id
                                         , lm_trans_rec.trx_reference_id
                                         , lm_trans_rec.who_info.last_update_date
                                         , lm_trans_rec.who_info.last_updated_by
                                         , lm_trans_rec.who_info.last_update_login
                                         , lm_trans_rec.event_id  --Added for bug 537059
                                         , l_trx_ref_type; -- bug 5475029
               CLOSE c_get_member_trx;

            end if;

            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,
                           'fetching event from XLA',
                           l_trans_rec.event_id,
                           p_log_level_rec => g_log_level_rec);
            end if;

            if not fa_xla_events_pvt.get_event_type
                       (p_event_id         => l_trans_rec.event_id,
                        x_event_type_code  => l_event_type_code ,
                        p_log_level_rec    => g_log_level_rec
                       ) then
                 raise group_adj_err;
            end if;

            --Added one more condition lm_trans_rec.event_id is not null in following
            --if for bug 537059.
            -- bug 5475029: modified the following if condition
            --if (l_trans_rec.trx_reference_id is not null and lm_trans_rec.event_id is not null) then
            if (nvl(l_trx_ref_type,'STANDARD TRX') = 'INVOICE TRANSFER') then

               if not fa_xla_events_pvt.update_inter_transaction_event
                  (p_ledger_id              => l_asset_hdr_rec.set_of_books_id,
                   p_trx_reference_id       => lm_trans_rec.trx_reference_id,
                   p_book_type_code         => p_book,
                   p_event_type_code        => l_event_type_code,
                   p_event_date             => l_trans_rec.transaction_date_entered,
                   p_event_status_code      => FA_XLA_EVENTS_PVT.C_EVENT_UNPROCESSED,
                   p_calling_fn             => l_calling_fn,
                   p_log_level_rec          => g_log_level_rec) then
                 raise group_adj_err;
               end if;

            else -- non inter asset trx

               if (l_trans_rec.member_transaction_header_id is not null) then
                  -- member driven transactions
                  l_thid := lm_trans_rec.transaction_header_id;
               else
                  -- direct group transaction
                  l_thid := l_trans_rec.transaction_header_id;
               end if;

               if not fa_xla_events_pvt.update_transaction_event
                  (p_ledger_id              => l_asset_hdr_rec.set_of_books_id,
                   p_transaction_header_id  => l_thid,
                   p_book_type_code         => p_book,
                   p_event_type_code        => l_event_type_code,
                   p_event_date             => l_trans_rec.transaction_date_entered,
                   p_event_status_code      => FA_XLA_EVENTS_PVT.C_EVENT_UNPROCESSED,
                   p_calling_fn             => l_calling_fn,
                   p_log_level_rec          => g_log_level_rec) then
                  raise group_adj_err;
               end if;

            end if;

         else
            l_mrc_sob_type_code := 'R';
            l_asset_hdr_rec.set_of_books_id := l_sob_tbl(l_sob_index);

         end if;

         -- call the cache to set the sob_id used for rounding and other lower
         -- level code for each book.
         if NOT fa_cache_pkg.fazcbcs(X_book => p_book,
                                     X_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                                     p_log_level_rec => g_log_level_rec)
                                                                        then
            raise group_adj_err;
         end if;

         if (g_log_level_rec.statement_level) then
            fa_debug_pkg.add('do_pending_groups.do_all_books',
                        'TRX KEY',
                        l_trans_rec.transaction_key, p_log_level_rec => g_log_level_rec);
         end if;

         if (l_trans_rec.transaction_key  not in ('GC', 'UA', 'UE', 'MR', 'MS')) then

            if not FA_ASSET_VAL_PVT.validate_period_of_addition
              (p_asset_id            => l_asset_hdr_rec.asset_id,
               p_book                => l_asset_hdr_rec.book_type_code,
               p_mode                => 'ABSOLUTE',
               px_period_of_addition => l_asset_hdr_rec.period_of_addition, p_log_level_rec => g_log_level_rec) then
                  raise group_adj_err;
            end if;

            if (g_log_level_rec.statement_level) then
                fa_debug_pkg.add('do_pending_groups',
                        'AFTER validate_period_of_addition',
                        l_asset_hdr_rec.period_of_addition, p_log_level_rec => g_log_level_rec);
            end if;

            if not FA_UTIL_PVT.get_asset_desc_rec
              (p_asset_hdr_rec         => l_asset_hdr_rec,
               px_asset_desc_rec       => l_asset_desc_rec
               , p_log_level_rec => g_log_level_rec) then
               raise group_adj_err;
            end if;
            if (g_log_level_rec.statement_level) then
                fa_debug_pkg.add('do_pending_groups',
                        'AFTER',
                        'get_asset_desc_rec', p_log_level_rec => g_log_level_rec);
            end if;

            if not FA_UTIL_PVT.get_asset_cat_rec
               (p_asset_hdr_rec         => l_asset_hdr_rec,
                px_asset_cat_rec        => l_asset_cat_rec,
                p_date_effective        => null
                , p_log_level_rec => g_log_level_rec) then
                raise group_adj_err;
            end if;

            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('do_pending_groups',
                        'AFTER',
                        'get_asset_cat_rec', p_log_level_rec => g_log_level_rec);
            end if;

            if not FA_UTIL_PVT.get_asset_type_rec
               (p_asset_hdr_rec         => l_asset_hdr_rec,
                px_asset_type_rec       => l_asset_type_rec,
                p_date_effective        => null
                , p_log_level_rec => g_log_level_rec) then
                raise group_adj_err;
            end if;

            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('do_pending_groups',
                        'AFTER get_asset_cat_rec',
                        l_asset_type_rec.asset_type, p_log_level_rec => g_log_level_rec);
            end if;

            -- load the old structs
            if not FA_UTIL_PVT.get_asset_fin_rec
               (p_asset_hdr_rec         => l_asset_hdr_rec,
                px_asset_fin_rec        => l_asset_fin_rec_old,
                p_transaction_header_id => l_old_trx_id,
                p_mrc_sob_type_code     => l_mrc_sob_type_code
                , p_log_level_rec => g_log_level_rec) then raise group_adj_err;
            end if;
            if (g_log_level_rec.statement_level) then
                fa_debug_pkg.add('do_pending_groups',
                        'AFTER get_asset_fin_rec OLD',
                        l_asset_fin_rec_old.cost, p_log_level_rec => g_log_level_rec);
            end if;

            if not FA_UTIL_PVT.get_asset_deprn_rec
               (p_asset_hdr_rec         => l_asset_hdr_rec ,
                px_asset_deprn_rec      => l_asset_deprn_rec_old,
                p_period_counter        => NULL,
                p_mrc_sob_type_code     => l_mrc_sob_type_code
                , p_log_level_rec => g_log_level_rec) then raise group_adj_err;
            end if;

            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('do_pending_groups',
                        'AFTER',
                        'get_asset_deprn_rec OLD', p_log_level_rec => g_log_level_rec);
            end if;
            -- load the new structs
            if not FA_UTIL_PVT.get_asset_fin_rec
               (p_asset_hdr_rec         => l_asset_hdr_rec,
                px_asset_fin_rec        => l_asset_fin_rec_new,
                p_transaction_header_id => NULL,
                p_mrc_sob_type_code     => l_mrc_sob_type_code
                , p_log_level_rec => g_log_level_rec) then raise group_adj_err;
            end if;
            if (g_log_level_rec.statement_level) then
                fa_debug_pkg.add('do_pending_groups',
                        'AFTER get_asset_fin_rec NEW',
                        l_asset_fin_rec_new.cost, p_log_level_rec => g_log_level_rec);
            end if;
            if (NOT FA_UTIL_PVT.get_period_rec (
              p_book           => l_asset_hdr_rec.book_type_code,
              p_effective_date => NULL,
              x_period_rec     => l_period_rec, p_log_level_rec => g_log_level_rec)) then
              raise group_adj_err;
            end if;

            if (g_log_level_rec.statement_level) then
                fa_debug_pkg.add('do_pending_groups',
                        'AFTERALLSTRUCTS',
                        'AFTERALLSTRUCTS', p_log_level_rec => g_log_level_rec);
            end if;

            if (g_log_level_rec.statement_level) then
                fa_debug_pkg.add('do_pending_groups',
                        'not-groupreclass',
                        'CALLING FAXAMA', p_log_level_rec => g_log_level_rec);
            end if;

            if (not FA_AMORT_PVT.faxama(
                         px_trans_rec            => l_trans_rec,
                         p_asset_hdr_rec         => l_asset_hdr_rec,
                         p_asset_desc_rec        => l_asset_desc_rec,
                         p_asset_cat_rec         => l_asset_cat_rec,
                         p_asset_type_rec        => l_asset_type_rec,
                         p_asset_fin_rec_old     => l_asset_fin_rec_old,
                         p_asset_fin_rec_adj     => l_asset_fin_rec_adj_null,
                         px_asset_fin_rec_new    => l_asset_fin_rec_new,
                         p_asset_deprn_rec       => l_asset_deprn_rec_old,
                         p_asset_deprn_rec_adj   => l_asset_deprn_rec_adj_null,
                         p_period_rec            => l_period_rec,
                         p_mrc_sob_type_code     => l_mrc_sob_type_code,
                         p_running_mode          => fa_std_types.FA_DPR_NORMAL,
                         p_used_by_revaluation   => null,
                         p_reclassed_asset_id    => l_reclassed_asset_id,
                         p_reclass_src_dest      => l_reclass_src_dest,
                         p_reclassed_asset_dpis  => l_reclassed_asset_dpis,
                         p_update_books_summary  => TRUE,
                         p_proceeds_of_sale      => 0,
                         p_cost_of_removal       => 0,
                         x_deprn_exp             => l_deprn_exp,
                         x_bonus_deprn_exp       => l_bonus_deprn_exp,
                         x_impairment_exp        => l_impairment_exp,
                         x_deprn_rsv             => l_deprn_rsv, p_log_level_rec => g_log_level_rec)) then

               if (g_log_level_rec.statement_level) then
                  fa_debug_pkg.add('calc_fin_info', 'calling FA_AMORT_PVT.faxama', 'FAILED',  p_log_level_rec => g_log_level_rec);
               end if;

               raise group_adj_err;

            end if; -- (not FA_AMORT_PVT.faxama


            -- insert the deprn amounts
            if not FA_INS_ADJ_PVT.faxiat
                     (p_trans_rec       => l_trans_rec,
                      p_asset_hdr_rec   => l_asset_hdr_rec,
                      p_asset_desc_rec  => l_asset_desc_rec,
                      p_asset_cat_rec   => l_asset_cat_rec,
                      p_asset_type_rec  => l_asset_type_rec,
                      p_cost            => 0,
                      p_clearing        => 0,
                      p_deprn_expense   => l_deprn_exp,
                      p_bonus_expense   => l_bonus_deprn_exp,
                      p_impair_expense  => l_impairment_exp,
                      p_ann_adj_amt     => 0,
                      p_mrc_sob_type_code => l_mrc_sob_type_code,
                      p_calling_fn      => l_calling_fn
                     , p_log_level_rec => g_log_level_rec) then raise group_adj_err;
            end if;


            --
            -- Dupulicate group FA_ADJUSTMENTS entries on member asset
            --
            if (nvl(l_deprn_exp, 0) <> 0 or nvl(l_bonus_deprn_exp, 0) <> 0) and
               (l_asset_type_rec.asset_type = 'GROUP') and
               (l_trans_rec.member_transaction_header_id is not null) and
               (nvl(l_asset_fin_rec_new.tracking_method,'NO TRACK') = 'ALLOCATE') then

               -- bridgway: moved the member fetch above as we need info for SLA purposes

               lm_trans_rec.who_info.created_by := l_trans_rec.who_info.last_updated_by;
               lm_trans_rec.who_info.creation_date := l_trans_rec.who_info.last_update_date;

               lm_asset_hdr_rec.book_type_code := l_asset_hdr_rec.book_type_code;
               lm_asset_hdr_rec.set_of_books_id := l_asset_hdr_rec.set_of_books_id;

               -- load the old structs
               if not FA_UTIL_PVT.get_asset_fin_rec
                       (p_asset_hdr_rec         => lm_asset_hdr_rec,
                        px_asset_fin_rec        => lm_asset_fin_rec,
                        p_transaction_header_id => NULL,
                        p_mrc_sob_type_code     => l_mrc_sob_type_code, p_log_level_rec => g_log_level_rec) then
                  raise group_adj_err;
               end if;

               if not FA_UTIL_PVT.get_asset_desc_rec
                       (p_asset_hdr_rec         => lm_asset_hdr_rec,
                        px_asset_desc_rec       => lm_asset_desc_rec, p_log_level_rec => g_log_level_rec) then
                  raise group_adj_err;
               end if;

               if not FA_UTIL_PVT.get_asset_cat_rec
                       (p_asset_hdr_rec         => lm_asset_hdr_rec,
                        px_asset_cat_rec        => lm_asset_cat_rec,
                        p_date_effective        => null, p_log_level_rec => g_log_level_rec) then
                  raise group_adj_err;
               end if;

               if not FA_UTIL_PVT.get_asset_type_rec
                       (p_asset_hdr_rec         => lm_asset_hdr_rec,
                        px_asset_type_rec       => lm_asset_type_rec,
                        p_date_effective        => null, p_log_level_rec => g_log_level_rec) then
                  raise group_adj_err;
               end if;

               --Bug7008015: Need member reserve
               if not FA_UTIL_PVT.get_asset_deprn_rec
                      (p_asset_hdr_rec         => lm_asset_hdr_rec ,
                       px_asset_deprn_rec      => lm_asset_deprn_rec,
                       p_period_counter        => NULL,
                       p_mrc_sob_type_code     => l_mrc_sob_type_code, p_log_level_rec => g_log_level_rec) then
                  raise group_adj_err;
               end if;

               -- Bug7008015
               -- Fully reserve member asset if
               -- - l_adjust_type is AMORTIZED: If this is expensed, this won't be necessary as it takes care this
               -- - This is a member asset.  - premature to apply this for all assets
               -- - Tracking method is allocate - premature to apply this for all assets
               -- - This is not group reclass
               -- - There is a change in cost
               -- - New reserve is more than the adj rec cost or adj rec cost is 0 while there is rsv balance
               -- If all above condition is met, asset will be fully reserve by expensing remaining nbv (adj rec cost - rsv)
               if (g_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'lm_asset_fin_rec.group_asset_id', lm_asset_fin_rec.group_asset_id, p_log_level_rec => g_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'lm_asset_fin_rec.tracking_method', lm_asset_fin_rec.tracking_method, p_log_level_rec => g_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'l_trans_rec.transaction_key', l_trans_rec.transaction_key, p_log_level_rec => g_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'delta cost', nvl(l_asset_fin_rec_new.cost , 0) - nvl(l_asset_fin_rec_old.cost, 0));
                  fa_debug_pkg.add(l_calling_fn, 'lm_asset_deprn_rec.deprn_reserve', lm_asset_deprn_rec.deprn_reserve, p_log_level_rec => g_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'lm_asset_fin_rec.adjusted_recoverable_cost', lm_asset_fin_rec.adjusted_recoverable_cost, p_log_level_rec => g_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'l_deprn_exp', l_deprn_exp, p_log_level_rec => g_log_level_rec);
               end if;

               if lm_asset_fin_rec.group_asset_id is not null and
                  lm_asset_fin_rec.tracking_method = 'ALLOCATE' and
                  l_trans_rec.transaction_key <> 'GC' and
                  nvl(l_asset_fin_rec_new.cost , 0) - nvl(l_asset_fin_rec_old.cost, 0) <> 0 and
                  ( ( ( sign(nvl(lm_asset_deprn_rec.deprn_reserve, 0) + nvl(l_deprn_exp, 0)) =
                                                            sign(lm_asset_fin_rec.adjusted_recoverable_cost) ) and
                         ( abs(nvl(lm_asset_deprn_rec.deprn_reserve, 0) + nvl(l_deprn_exp, 0)) >
                                                            abs(lm_asset_fin_rec.adjusted_recoverable_cost)   )  ) or
                    (lm_asset_fin_rec.adjusted_recoverable_cost = 0 and lm_asset_deprn_rec.deprn_reserve <> 0)     ) then
                  l_deprn_exp := lm_asset_fin_rec.adjusted_recoverable_cost - nvl(lm_asset_deprn_rec.deprn_reserve, 0);
               end if;

               if not FA_INS_ADJ_PVT.faxiat
                        (p_trans_rec       => lm_trans_rec,
                         p_asset_hdr_rec   => lm_asset_hdr_rec,
                         p_asset_desc_rec  => lm_asset_desc_rec,
                         p_asset_cat_rec   => lm_asset_cat_rec,
                         p_asset_type_rec  => lm_asset_type_rec,
                         p_cost            => 0,
                         p_clearing        => 0,
                         p_deprn_expense   => l_deprn_exp,
                         p_bonus_expense   => l_bonus_deprn_exp,
                         p_impair_expense  => l_impairment_exp,
                         p_ann_adj_amt     => 0,
                         p_track_member_flag => 'Y',
                         p_mrc_sob_type_code => l_mrc_sob_type_code,
                         p_calling_fn      => l_calling_fn, p_log_level_rec => g_log_level_rec) then
                  raise group_adj_err;
               end if;

            end if;

            -- now update fa_books
            if (l_mrc_sob_type_code = 'R') then
               update fa_mc_books
               set rate_adjustment_factor =
                        l_asset_fin_rec_new.rate_adjustment_factor,
                   reval_amortization_basis =
                        l_asset_fin_rec_new.reval_amortization_basis,
                   adjusted_cost = l_asset_fin_rec_new.adjusted_cost,
                   adjusted_capacity = l_asset_fin_rec_new.adjusted_capacity,
                   eofy_reserve = l_asset_fin_rec_new.eofy_reserve,
                   adjustment_required_status = 'NONE'
               where asset_id = l_asset_id
                 and book_type_code = p_book
                 and transaction_header_id_out is null;
            else
               update fa_books
               set rate_adjustment_factor =
                        l_asset_fin_rec_new.rate_adjustment_factor,
                   reval_amortization_basis =
                        l_asset_fin_rec_new.reval_amortization_basis,
                   adjusted_cost = l_asset_fin_rec_new.adjusted_cost,
                   adjusted_capacity = l_asset_fin_rec_new.adjusted_capacity,
                   eofy_reserve = l_asset_fin_rec_new.eofy_reserve,
                   adjustment_required_status = 'NONE'
               where rowid = l_rowid;
            end if;

            -- HHIRAGA
            --++ Added for tracking
            -- When Group Adjustment is processed for the group whose tracking
            -- method is allocate but the transaction kicked at group level,
            -- expense must be allocated to members.
            -- HH assuming this is not a change to disabled_flag
            if l_trans_rec.transaction_type_code = 'GROUP ADJUSTMENT' and
               l_trans_rec.member_transaction_header_id is null and
               nvl(l_asset_fin_rec_new.tracking_method,'OTHER') = 'ALLOCATE' then
--               not l_disabled_flag_changed then
           -- Call TRACK_ASSETS
               l_rc := fa_track_member_pvt.track_assets
                     (P_book_type_code             => l_asset_hdr_rec.book_type_code,
                      P_group_asset_id             => l_asset_hdr_rec.asset_id,
                      P_period_counter             => l_period_rec.period_num,
                      P_fiscal_year                => l_period_rec.fiscal_year,
                      P_group_deprn_basis          => fa_cache_pkg.fazccmt_record.deprn_basis_rule,
                      P_group_exclude_salvage      => fa_cache_pkg.fazccmt_record.exclude_salvage_value_flag,
                      P_group_bonus_rule           => l_asset_fin_rec_new.bonus_rule,
                      P_group_deprn_amount         => l_deprn_exp,
                      P_group_bonus_amount         => l_bonus_deprn_exp,
                      P_tracking_method            => l_asset_fin_rec_new.tracking_method,
                      P_allocate_to_fully_ret_flag => l_asset_fin_rec_new.allocate_to_fully_ret_flag,
                      P_allocate_to_fully_rsv_flag => l_asset_fin_rec_new.allocate_to_fully_rsv_flag,
                      P_excess_allocation_option   => l_asset_fin_rec_new.excess_allocation_option,
                      P_depreciation_option        => l_asset_fin_rec_new.depreciation_option,
                      P_member_rollup_flag         => l_asset_fin_rec_new.member_rollup_flag,
                      P_group_level_override       => l_group_level_override,
                      P_period_of_addition         => l_asset_hdr_rec.period_of_addition,
                      P_transaction_date_entered   => l_trans_rec.transaction_date_entered,
                      P_mode                       => 'GROUP ADJUSTMENT',
                      P_mrc_sob_type_code          => l_mrc_sob_type_code,
                      P_set_of_books_id            => l_asset_hdr_rec.set_of_books_id,
                      X_new_deprn_amount           => x_new_deprn_amount,
                      X_new_bonus_amount           => x_new_bonus_amount,  p_log_level_rec => g_log_level_rec);
               if l_rc <> 0  then
                 raise group_adj_err;
               end if;
           end if; -- Tracking is ALLOCATE


         elsif (l_trans_rec.transaction_key = 'GC' and l_sob_index = 0) then --Bug 8941132 Reclass call only for primary book

            -- the asset currently fetched could have have been
            -- processed already as source,dest trxn in this run
            -- after the initial fetch
            --Bug#8675920 Need to call do_group_reclass for Reporting currecy too.
            if l_mrc_sob_type_code = 'P' then
               open check_adj_status;
               fetch check_adj_status into l_adj_count;
               close check_adj_status;
            else
               open check_mc_adj_status;
               fetch check_mc_adj_status into l_adj_count;
               close check_mc_adj_status;
            end if;
            if (l_adj_count = 1) then
               open get_trx_ref;
               fetch get_trx_ref into
                        l_trx_ref_rec.TRX_REFERENCE_ID,
                        l_trx_ref_rec.TRANSACTION_TYPE,
                        l_trx_ref_rec.SRC_TRANSACTION_SUBTYPE,
                        l_trx_ref_rec.DEST_TRANSACTION_SUBTYPE,
                        l_trx_ref_rec.BOOK_TYPE_CODE,
                        l_trx_ref_rec.SRC_ASSET_ID,
                        l_trx_ref_rec.SRC_TRANSACTION_HEADER_ID,
                        l_trx_ref_rec.DEST_ASSET_ID,
                        l_trx_ref_rec.DEST_TRANSACTION_HEADER_ID,
                        l_trx_ref_rec.MEMBER_ASSET_ID,
                        l_trx_ref_rec.MEMBER_TRANSACTION_HEADER_ID,
                        l_trx_ref_rec.SRC_AMORTIZATION_START_DATE,
                        l_trx_ref_rec.DEST_AMORTIZATION_START_DATE,
                        l_trx_ref_rec.RESERVE_TRANSFER_AMOUNT,
                        l_trx_ref_rec.SRC_EXPENSE_AMOUNT,
                        l_trx_ref_rec.DEST_EXPENSE_AMOUNT,
                        l_trx_ref_rec.SRC_EOFY_RESERVE,
                        l_trx_ref_rec.DEST_EOFY_RESERVE;
               close get_trx_ref;
               if (g_log_level_rec.statement_level) then
                   fa_debug_pkg.add('do_all_books',
                        'calling do_group_reclass',
                         'calling do_group_reclass', p_log_level_rec => g_log_level_rec);
               end if;

               if not do_group_reclass(
                        p_trx_ref_rec           => l_trx_ref_rec,
                        p_mrc_sob_type_code     => l_mrc_sob_type_code,
                        p_set_of_books_id       => l_asset_hdr_rec.set_of_books_id,
                        p_log_level_rec         => g_log_level_rec) then --Bug 8941132 added g_log_level_rec
                  raise GROUP_ADJ_ERR;
               end if;
            end if; -- l_adj_count = 1

         elsif (l_trans_rec.transaction_key in ('UA', 'UE')) then
            --
            -- Allocating unplanned depreciation against group to its member assets
            --

            -- load the new structs
            if not FA_UTIL_PVT.get_asset_fin_rec(
                      p_asset_hdr_rec         => l_asset_hdr_rec,
                      px_asset_fin_rec        => l_asset_fin_rec_new,
                      p_transaction_header_id => NULL,
                      p_mrc_sob_type_code     => l_mrc_sob_type_code, p_log_level_rec => g_log_level_rec) then
               raise group_adj_err;
            end if;

            if not FA_UTIL_PVT.get_period_rec (
                      p_book           => l_asset_hdr_rec.book_type_code,
                      p_effective_date => NULL,
                      x_period_rec     => l_period_rec, p_log_level_rec => g_log_level_rec) then
               raise group_adj_err;
            end if;

            if (l_mrc_sob_type_code <> 'R') then
               if not fa_cache_pkg.fazccmt(l_asset_fin_rec_new.deprn_method_code
                                         , l_asset_fin_rec_new.life_in_months, p_log_level_rec => g_log_level_rec) then
                  fa_srvr_msg.add_message (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
                  raise group_adj_err;
               end if;
            end if;

            --
            -- Get unplanned amount
            --
            if (l_mrc_sob_type_code = 'R') then
               OPEN c_mc_get_unplanned_amt;
               FETCH c_mc_get_unplanned_amt INTO l_unplanned_deprn_rec.unplanned_amount;
               CLOSE c_mc_get_unplanned_amt;
            else
               OPEN c_get_unplanned_amt;
               FETCH c_get_unplanned_amt INTO l_unplanned_deprn_rec.unplanned_amount;
               CLOSE c_get_unplanned_amt;
            end if;

            l_rc := FA_TRACK_MEMBER_PVT.TRACK_ASSETS
                       (P_book_type_code             => l_asset_hdr_rec.book_type_code,
                        P_group_asset_id             => l_asset_hdr_rec.asset_id,
                        P_period_counter             => l_period_rec.period_num,
                        P_fiscal_year                => l_period_rec.fiscal_year,
                        P_group_deprn_basis          => fa_cache_pkg.fazccmt_record.deprn_basis_rule,
                        P_group_exclude_salvage      => fa_cache_pkg.fazccmt_record.exclude_salvage_value_flag,
                        P_group_bonus_rule           => l_asset_fin_rec_new.bonus_rule,
                        P_group_deprn_amount         => l_unplanned_deprn_rec.unplanned_amount,
                        P_group_bonus_amount         => 0,
                        P_tracking_method            => l_asset_fin_rec_new.tracking_method,
                        P_allocate_to_fully_ret_flag => l_asset_fin_rec_new.allocate_to_fully_ret_flag,
                        P_allocate_to_fully_rsv_flag => l_asset_fin_rec_new.allocate_to_fully_rsv_flag,
                        P_excess_allocation_option   => l_asset_fin_rec_new.excess_allocation_option,
                        P_subtraction_flag           => 'N',
                        P_group_level_override       => l_group_level_override,
                        P_transaction_date_entered   => l_trans_rec.transaction_date_entered,
                        P_mode                       => 'UNPLANNED',
                        P_mrc_sob_type_code          => l_mrc_sob_type_code,
                        P_set_of_books_id            => l_asset_hdr_rec.set_of_books_id,
                        X_new_deprn_amount           => l_group_deprn_amount,
                        X_new_bonus_amount           => l_group_bonus_amount,  p_log_level_rec => g_log_level_rec);

            if l_rc <> 0 then
               raise GROUP_ADJ_ERR;
            elsif l_group_deprn_amount <> l_unplanned_deprn_rec.unplanned_amount then
               raise GROUP_ADJ_ERR;
            end if;


         elsif l_trans_rec.transaction_key in ('MR', 'MS') then
            --
            -- Allocating remaining reserve(group reserve retired - retired member reserve retired) to
            -- remaining member assets.
            --

            -- load the new structs
            if not FA_UTIL_PVT.get_asset_fin_rec(
                      p_asset_hdr_rec         => l_asset_hdr_rec,
                      px_asset_fin_rec        => l_asset_fin_rec_new,
                      p_transaction_header_id => NULL,
                      p_mrc_sob_type_code     => l_mrc_sob_type_code, p_log_level_rec => g_log_level_rec) then
               raise group_adj_err;
            end if;

            if not FA_UTIL_PVT.get_period_rec (
                      p_book           => l_asset_hdr_rec.book_type_code,
                      p_effective_date => NULL,
                      x_period_rec     => l_period_rec, p_log_level_rec => g_log_level_rec) then
               raise group_adj_err;
            end if;

            --
            -- Get member's and group's reserve retired to find out
            -- amount to allocate to remaining member assets
            --
            if (l_mrc_sob_type_code = 'R') then
               if (l_trans_rec.transaction_key = 'MR') then
                  OPEN c_mc_get_member_rsv_ret;
                  FETCH c_mc_get_member_rsv_ret INTO l_member_reserve_amount;
                  CLOSE c_mc_get_member_rsv_ret;

                  l_mem_ret_thid := null;
               else
                  OPEN c_mc_get_member_rsv_rei;
                  FETCH c_mc_get_member_rsv_rei INTO l_member_reserve_amount, l_mem_ret_thid;
                  CLOSE c_mc_get_member_rsv_rei;
               end if;

               OPEN c_mc_get_group_rsv_ret;
               FETCH c_mc_get_group_rsv_ret INTO l_group_reserve_amount;
               CLOSE c_mc_get_group_rsv_ret;
            else
               if (l_trans_rec.transaction_key = 'MR') then
                  OPEN c_get_member_rsv_ret;
                  FETCH c_get_member_rsv_ret INTO l_member_reserve_amount;
                  CLOSE c_get_member_rsv_ret;

                  l_mem_ret_thid := null;
               else
                  OPEN c_get_member_rsv_rei;
                  FETCH c_get_member_rsv_rei INTO l_member_reserve_amount, l_mem_ret_thid;
                  CLOSE c_get_member_rsv_rei;
               end if;

               OPEN c_get_group_rsv_ret;
               FETCH c_get_group_rsv_ret INTO l_group_reserve_amount;
               CLOSE c_get_group_rsv_ret;
            end if;

            if not FA_UTIL_PVT.get_asset_deprn_rec
                (p_asset_hdr_rec         => l_asset_hdr_rec ,
                 px_asset_deprn_rec      => l_asset_deprn_rec_new,
                 p_period_counter        => NULL,
                 p_mrc_sob_type_code     => l_mrc_sob_type_code
                 , p_log_level_rec => g_log_level_rec) then raise group_adj_err;
            end if;

            if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'l_trans_rec.transaction_key', l_trans_rec.transaction_key, p_log_level_rec => g_log_level_rec);
               fa_debug_pkg.add(l_calling_fn,'p_reserve_amount', l_group_reserve_amount - l_member_reserve_amount, p_log_level_rec => g_log_level_rec);
               fa_debug_pkg.add(l_calling_fn,'p_mem_ret_thid', l_mem_ret_thid, p_log_level_rec => g_log_level_rec);
            end if;

            if not FA_RETIREMENT_PVT.Do_Allocation(
                      p_trans_rec         => l_trans_rec,
                      p_asset_hdr_rec     => l_asset_hdr_rec,
                      p_asset_fin_rec     => l_asset_fin_rec_new,
                      p_asset_deprn_rec_new => l_asset_deprn_rec_new,
                      p_period_rec        => l_period_rec,
                      p_reserve_amount    => l_group_reserve_amount - l_member_reserve_amount,
                      p_mem_ret_thid      => l_mem_ret_thid,
                      p_mrc_sob_type_code => l_mrc_sob_type_code,
                      p_calling_fn        => 'FAPGADJ', p_log_level_rec => g_log_level_rec) then
               raise group_adj_err;
            end if;

         end if;  -- l_trans_rec.transaction_key <> GC

         if (l_trans_rec.transaction_key in ('UA', 'UE', 'MR', 'MS')) then

            if(l_mrc_sob_type_code = 'R') then
               update fa_mc_books
               set adjustment_required_status = 'NONE'
               where asset_id = l_asset_id
               and book_type_code = p_book
               and transaction_header_id_out is null;
            else
               update fa_books
               set adjustment_required_status = 'NONE'
               where rowid = l_rowid;
            end if;
         end if;

         -- Bug 8862296 Changes start here
         if (l_trans_rec.transaction_key = 'MJ' and
             lm_trans_rec.transaction_key = 'IT' and
             nvl(p_source_group_asset_id,-99) = nvl(p_dest_group_asset_id,-99)) then

            -- call for dest
            OPEN c_get_trx_reference;
            FETCH c_get_trx_reference
             INTO l_src_asset_hdr_rec.asset_id,
                  l_src_asset_hdr_rec.book_type_code,
                  l_src_trans_rec.transaction_header_id,
                  l_src_trans_rec.transaction_subtype,
                  l_src_trans_rec.amortization_start_date,
                  l_src_trans_rec.trx_reference_id,
                  l_src_trans_rec.event_id,
                  l_dest_asset_hdr_rec.asset_id,
                  l_dest_asset_hdr_rec.book_type_code,
                  l_dest_trans_rec.transaction_header_id,
                  l_dest_trans_rec.transaction_subtype,
                  l_dest_trans_rec.amortization_start_date,
                  l_dest_trans_rec.trx_reference_id,
                  l_dest_trans_rec.event_id,
                  l_inv_trans_rec.transaction_type,
                  l_inv_trans_rec.invoice_transaction_id;
            CLOSE c_get_trx_reference;

            l_src_trans_rec.transaction_type_code := 'ADJUSTMENT';
            l_src_trans_rec.transaction_key := 'IT';
            l_src_trans_rec.transaction_date_entered := l_dest_trans_rec.amortization_start_date;
            l_src_trans_rec.calling_interface := 'CUSTOM';

            l_dest_trans_rec.transaction_type_code := 'ADJUSTMENT';
            l_dest_trans_rec.transaction_key := 'IT';
            l_dest_trans_rec.transaction_date_entered := l_dest_trans_rec.amortization_start_date;
            l_dest_trans_rec.calling_interface := 'CUSTOM';

            l_src_asset_hdr_rec.set_of_books_id := l_asset_hdr_rec.set_of_books_id;
            l_dest_asset_hdr_rec.set_of_books_id := l_asset_hdr_rec.set_of_books_id;

            OPEN c_inv_tbl;
            i :=1;
            LOOP
               J :=1;
               FETCH c_inv_tbl
               INTO l_dest_inv_tbl(i).PO_VENDOR_ID,
                    l_dest_inv_tbl(i).ASSET_INVOICE_ID,
                    l_dest_inv_tbl(i).FIXED_ASSETS_COST,
                    l_dest_inv_tbl(i).DELETED_FLAG,
                    l_dest_inv_tbl(i).PO_NUMBER,
                    l_dest_inv_tbl(i).INVOICE_NUMBER,
                    l_dest_inv_tbl(i).PAYABLES_BATCH_NAME,
                    l_dest_inv_tbl(i).PAYABLES_CODE_COMBINATION_ID,
                    l_dest_inv_tbl(i).FEEDER_SYSTEM_NAME,
                    l_dest_inv_tbl(i).CREATE_BATCH_DATE,
                    l_dest_inv_tbl(i).CREATE_BATCH_ID,
                    l_dest_inv_tbl(i).INVOICE_DATE,
                    l_dest_inv_tbl(i).PAYABLES_COST,
                    l_dest_inv_tbl(i).POST_BATCH_ID,
                    l_dest_inv_tbl(i).INVOICE_ID,
                    l_dest_inv_tbl(i).AP_DISTRIBUTION_LINE_NUMBER,
                    l_dest_inv_tbl(i).PAYABLES_UNITS,
                    l_dest_inv_tbl(i).SPLIT_MERGED_CODE,
                    l_dest_inv_tbl(i).DESCRIPTION,
                    l_dest_inv_tbl(i).PARENT_MASS_ADDITION_ID,
                    l_dest_inv_tbl(i).UNREVALUED_COST,
                    l_dest_inv_tbl(i).MERGED_CODE,
                    l_dest_inv_tbl(i).SPLIT_CODE,
                    l_dest_inv_tbl(i).MERGE_PARENT_MASS_ADDITIONS_ID,
                    l_dest_inv_tbl(i).SPLIT_PARENT_MASS_ADDITIONS_ID,
                    l_dest_inv_tbl(i).PROJECT_ASSET_LINE_ID,
                    l_dest_inv_tbl(i).PROJECT_ID,
                    l_dest_inv_tbl(i).TASK_ID,
                    l_dest_inv_tbl(i).DEPRECIATE_IN_GROUP_FLAG,
                    l_dest_inv_tbl(i).MATERIAL_INDICATOR_FLAG,
                    l_dest_inv_tbl(i).PRIOR_SOURCE_LINE_ID,
                    l_dest_inv_tbl(i).INVOICE_DISTRIBUTION_ID,
                    l_dest_inv_tbl(i).INVOICE_LINE_NUMBER,
                    l_dest_inv_tbl(i).PO_DISTRIBUTION_ID;

               EXIT WHEN c_inv_tbl%NOTFOUND;
               l_dest_inv_tbl(i).source_line_id    := null;

               FOR c_rec in c_inv_rate(l_dest_inv_tbl(i).PRIOR_SOURCE_LINE_ID) LOOP
                  if (g_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn,'set_of_books_id', c_rec.set_of_books_id,  p_log_level_rec => g_log_level_rec);
                     fa_debug_pkg.add(l_calling_fn,'exchange_rate', c_rec.exchange_rate,  p_log_level_rec => g_log_level_rec);
                  end if;
                  l_dest_inv_tbl(i).inv_rate_tbl(j).set_of_books_id  := c_rec.set_of_books_id;
                  l_dest_inv_tbl(i).inv_rate_tbl(j).exchange_rate    := c_rec.exchange_rate;
                  l_dest_inv_tbl(i).inv_rate_tbl(j).cost             := c_rec.fixed_assets_cost;
                  j := j+1;
               END LOOP;

               i := i+1;
            END LOOP;

            IF NOT FA_INV_XFR_PUB.do_inv_sub_transfer
                  (p_src_trans_rec      => l_src_trans_rec,
                   p_src_asset_hdr_rec  => l_src_asset_hdr_rec,
                   p_dest_trans_rec     => l_dest_trans_rec,
                   p_dest_asset_hdr_rec => l_dest_asset_hdr_rec,
                   p_inv_tbl            => l_dest_inv_tbl,
                   p_inv_trans_rec      => l_inv_trans_rec,
                   p_log_level_rec      => g_log_level_rec) then
               raise GROUP_ADJ_ERR;
            end if;

         end if;
         -- Bug 8862296 Changes end here

      end loop; -- FOR all books loop
               --
      COMMIT WORK;
   end loop; -- trxs loop
   if (TRX_CUR) then
      close get_group_assets;
   else close get_all_groups;
   end if;

   return TRUE;
EXCEPTION
   WHEN GROUP_ADJ_ERR THEN
      fa_srvr_msg.add_message(
          calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      return FALSE;
   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error (
          calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      return FALSE;

END do_all_books;

FUNCTION do_group_reclass(
                p_trx_ref_rec           IN  fa_api_types.trx_ref_rec_type,
                p_mrc_sob_type_code     IN VARCHAR2,
                p_set_of_books_id       IN number,
                p_log_level_rec         IN FA_API_TYPES.log_level_rec_type) --Bug 8941132 added p_log_level_rec
                        RETURN BOOLEAN IS

   l_mem_trans_rec              fa_api_types.trans_rec_type;
   l_mem_asset_hdr_rec          fa_api_types.asset_hdr_rec_type;
   l_mem_asset_desc_rec         fa_api_types.asset_desc_rec_type;
   l_mem_asset_type_rec         fa_api_types.asset_type_rec_type;
   l_mem_asset_cat_rec          fa_api_types.asset_cat_rec_type;
   l_mem_asset_fin_rec_old      fa_api_types.asset_fin_rec_type;
   l_mem_asset_fin_rec_adj      fa_api_types.asset_fin_rec_type;
   l_mem_asset_fin_rec_new      fa_api_types.asset_fin_rec_type;
   l_mem_asset_deprn_rec_old    fa_api_types.asset_deprn_rec_type;
   l_mem_asset_deprn_rec_adj    fa_api_types.asset_deprn_rec_type;
   l_mem_asset_deprn_rec_new    fa_api_types.asset_deprn_rec_type;

   l_src_trans_rec              fa_api_types.trans_rec_type;
   l_src_asset_hdr_rec          fa_api_types.asset_hdr_rec_type;
   l_src_asset_desc_rec         fa_api_types.asset_desc_rec_type;
   l_src_asset_type_rec         fa_api_types.asset_type_rec_type;
   l_src_asset_cat_rec          fa_api_types.asset_cat_rec_type;
   l_src_asset_fin_rec_old      fa_api_types.asset_fin_rec_type;
   l_src_asset_fin_rec_adj      fa_api_types.asset_fin_rec_type;
   l_src_asset_fin_rec_new      fa_api_types.asset_fin_rec_type;
   l_src_asset_deprn_rec_old    fa_api_types.asset_deprn_rec_type;
   l_src_asset_deprn_rec_adj    fa_api_types.asset_deprn_rec_type;
   l_src_asset_deprn_rec_new    fa_api_types.asset_deprn_rec_type;

   l_dest_trans_rec              fa_api_types.trans_rec_type;
   l_dest_asset_hdr_rec          fa_api_types.asset_hdr_rec_type;
   l_dest_asset_desc_rec         fa_api_types.asset_desc_rec_type;
   l_dest_asset_type_rec         fa_api_types.asset_type_rec_type;
   l_dest_asset_cat_rec          fa_api_types.asset_cat_rec_type;
   l_dest_asset_fin_rec_old      fa_api_types.asset_fin_rec_type;
   l_dest_asset_fin_rec_adj      fa_api_types.asset_fin_rec_type;
   l_dest_asset_fin_rec_new      fa_api_types.asset_fin_rec_type;
   l_dest_asset_deprn_rec_old    fa_api_types.asset_deprn_rec_type;
   l_dest_asset_deprn_rec_adj    fa_api_types.asset_deprn_rec_type;
   l_dest_asset_deprn_rec_new    fa_api_types.asset_deprn_rec_type;

   l_period_rec                  fa_api_types.period_rec_type;

   -- For calling faxama
   l_asset_deprn_rec_adj         fa_api_types.asset_deprn_rec_type;
   l_bonus_deprn_exp             number;
   l_impairment_exp              number;
   l_deprn_rsv                   number;

   -- used for faxinaj calls
   l_exp_adj                 FA_ADJUST_TYPE_PKG.fa_adj_row_struct;
   l_rsv_adj                 FA_ADJUST_TYPE_PKG.fa_adj_row_struct;

   l_asset_id                   number;
   l_trx_id_in                  number;
   l_old_trx_id                 number;
   l_trx_id                     number;

   l_src_asset                  number := -1;
   l_dest_asset                 number := -1;

   l_group_reclass_code         varchar2(20);
   l_calling_fn                 varchar2(60) := 'fa_group_process_groups_pkg.do_rcl';

   group_rec_err                exception;

   -- BUG# 6936546
   l_api_version                NUMBER      := 1.0;
   l_init_msg_list              VARCHAR2(1) := FND_API.G_FALSE;
   l_commit                     VARCHAR2(1) := FND_API.G_FALSE;
   l_validation_level           NUMBER      := FND_API.G_VALID_LEVEL_NONE;
   l_return_status2             VARCHAR2(1);
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(2000);
   l_trans_rec                  FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec              FA_API_TYPES.asset_hdr_rec_type;
   l_asset_dist_tbl             FA_API_TYPES.asset_dist_tbl_type;

   l_distribution_id            num_tbl;
   l_units_assigned             num_tbl;
   l_code_combination_id        num_tbl;
   l_location_id                num_tbl;
   l_assigned_to                num_tbl;

   l_transfer_amount            NUMBER; --Bug6987743:

   cursor c_member_dists (p_asset_id number) is
   select distribution_id,
          units_assigned,
          code_combination_id,
          location_id,
          assigned_to
     from fa_distribution_history
    where asset_id = p_asset_id
      and transaction_header_id_out is null;

   cursor get_old_trx is
        select transaction_header_id_in
        from fa_books
        where asset_id = l_asset_id
        and   book_type_code = p_trx_ref_rec.book_type_code
        and   transaction_header_id_out = l_trx_id_in;


   cursor get_trx_rec_info is
        select transaction_header_id,
                transaction_type_code,
                transaction_date_entered,
                transaction_name,
                source_transaction_header_id,
                mass_reference_id,
                transaction_subtype,
                transaction_key,
                amortization_start_date,
                'FAPGADJ',
                mass_transaction_id,
                member_transaction_header_id,
                trx_reference_id
        from fa_transaction_headers
        where transaction_header_id = l_trx_id;

   --Bug6987743: Getting previously transfered reserve
   cursor c_get_reserve is
      select nvl(reserve_transfer_amount, 0)
      from fa_trx_references
      where dest_asset_id = l_src_asset_hdr_rec.asset_id
      and   member_asset_id = p_trx_ref_rec.member_asset_id
      and   book_type_code = p_trx_ref_rec.book_type_code
      order by trx_reference_id desc;

   --Bug 8941132 Start
   l_sob_tbl                     FA_CACHE_PKG.fazcrsob_sob_tbl_type;

   TYPE reclass_option_tbl       IS TABLE OF FA_API_TYPES.group_reclass_options_rec_type INDEX BY BINARY_INTEGER;
   TYPE asset_fin_rec_new_tbl    IS TABLE OF FA_API_TYPES.asset_fin_rec_type             INDEX BY BINARY_INTEGER;
   TYPE trans_rec_new_tbl        IS TABLE OF FA_API_TYPES.trans_rec_type                 INDEX BY BINARY_INTEGER;
   TYPE asset_hdr_rec_new_tbl    IS TABLE OF FA_API_TYPES.asset_hdr_rec_type             INDEX BY BINARY_INTEGER;
   TYPE asset_type_rec_new_tbl   IS TABLE OF FA_API_TYPES.asset_type_rec_type            INDEX BY BINARY_INTEGER;
   TYPE amort_init_member_tbl    IS TABLE OF FA_API_TYPES.amort_init_rec_type            INDEX BY BINARY_INTEGER;
   TYPE asset_deprn_rec_tbl      IS TABLE OF FA_API_TYPES.asset_deprn_rec_type           INDEX BY BINARY_INTEGER;

   l_group_reclass_options_rec   reclass_option_tbl;
   l_grp_src_trans_rec           trans_rec_new_tbl;
   l_grp_src_asset_hdr_rec       asset_hdr_rec_new_tbl;
   l_grp_src_asset_type_rec      asset_type_rec_new_tbl;
   l_grp_src_asset_fin_rec_new   asset_fin_rec_new_tbl;
   l_grp_dest_trans_rec          trans_rec_new_tbl;
   l_grp_dest_asset_hdr_rec      asset_hdr_rec_new_tbl;
   l_grp_dest_asset_type_rec     asset_type_rec_new_tbl;
   l_grp_dest_asset_fin_rec_new  asset_fin_rec_new_tbl;
   l_amort_init_member_rec       amort_init_member_tbl;
   l_mem_asset_deprn_rec_old_tbl asset_deprn_rec_tbl;

   l_mrc_sob_type_code           VARCHAR2(2);
   l_src_old_trx_id              number;
   l_mem_old_trx_id              number;
   l_dest_old_trx_id             number;
   --Bug 8941132 End

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add('do_group_reclass',
                       'in do_group_reclass',
                       'in do_group_reclass', p_log_level_rec => p_log_level_rec);
   end if;

   -- Bug 8941132: call the sob cache to get the table of sob_ids
   if not FA_CACHE_PKG.fazcrsob
          (x_book_type_code => p_trx_ref_rec.book_type_code,
           x_sob_tbl        => l_sob_tbl,
           p_log_level_rec  => p_log_level_rec) then
      raise group_rec_err;
   end if;

   -- get the member asset recs
   l_mem_asset_hdr_rec.asset_id := p_trx_ref_rec.member_asset_id;
   l_mem_asset_hdr_rec.book_type_code := p_trx_ref_rec.book_type_code;
   l_mem_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

   l_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add('do_group_reclass',
                       'member_asset_id START',
                       l_mem_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
   end if;

   if not FA_ASSET_VAL_PVT.validate_period_of_addition
             (p_asset_id            => l_mem_asset_hdr_rec.asset_id,
              p_book                => l_mem_asset_hdr_rec.book_type_code,
              p_mode                => 'ABSOLUTE',
              px_period_of_addition => l_mem_asset_hdr_rec.period_of_addition, p_log_level_rec => p_log_level_rec) then
                  raise group_rec_err;
   end if;

   if not FA_UTIL_PVT.get_asset_desc_rec
              (p_asset_hdr_rec         => l_mem_asset_hdr_rec,
               px_asset_desc_rec       => l_mem_asset_desc_rec
               , p_log_level_rec => p_log_level_rec) then
               raise group_rec_err;
   end if;

   if not FA_UTIL_PVT.get_asset_cat_rec
               (p_asset_hdr_rec         => l_mem_asset_hdr_rec,
                px_asset_cat_rec        => l_mem_asset_cat_rec,
                p_date_effective        => null
                , p_log_level_rec => p_log_level_rec) then
                raise group_rec_err;
   end if;

   if not FA_UTIL_PVT.get_asset_type_rec
               (p_asset_hdr_rec         => l_mem_asset_hdr_rec,
                px_asset_type_rec       => l_mem_asset_type_rec,
                p_date_effective        => null
                , p_log_level_rec => p_log_level_rec) then
                raise group_rec_err;
   end if;

   if NOT FA_UTIL_PVT.get_period_rec
               (p_book           => l_mem_asset_hdr_rec.book_type_code,
                p_effective_date => NULL,
                x_period_rec     => l_period_rec,
                p_log_level_rec  => p_log_level_rec) then
                raise group_rec_err;
   end if;

   -- load the old structs

   l_trx_id_in := p_trx_ref_rec.MEMBER_TRANSACTION_HEADER_ID;
   l_asset_id := l_mem_asset_hdr_rec.asset_id;
   open get_old_trx;
   fetch get_old_trx into l_old_trx_id;
   close get_old_trx;

   if not FA_UTIL_PVT.get_asset_fin_rec
               (p_asset_hdr_rec         => l_mem_asset_hdr_rec,
                px_asset_fin_rec        => l_mem_asset_fin_rec_old,
                p_transaction_header_id => l_old_trx_id,
                p_mrc_sob_type_code     => p_mrc_sob_type_code,
                p_log_level_rec         => p_log_level_rec) then
                raise group_rec_err;
   end if;

   if not FA_UTIL_PVT.get_asset_fin_rec
               (p_asset_hdr_rec         => l_mem_asset_hdr_rec,
                px_asset_fin_rec        => l_mem_asset_fin_rec_new,
                p_transaction_header_id => NULL,
                p_mrc_sob_type_code     => p_mrc_sob_type_code,
                p_log_level_rec         => p_log_level_rec) then raise group_rec_err;
   end if;
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add('do_group_reclass','l_mem_asset_fin_rec_old.cost',l_mem_asset_fin_rec_old.cost, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add('do_group_reclass','l_mem_asset_fin_rec_new.cost',l_mem_asset_fin_rec_new.cost, p_log_level_rec => p_log_level_rec);
   end if;

   if not FA_UTIL_PVT.get_asset_deprn_rec
               (p_asset_hdr_rec         => l_mem_asset_hdr_rec ,
                px_asset_deprn_rec      => l_mem_asset_deprn_rec_old,
                p_period_counter        => NULL,
                p_mrc_sob_type_code     => p_mrc_sob_type_code,
                p_log_level_rec         => p_log_level_rec) then raise group_rec_err;
   end if;

   l_trx_id := p_trx_ref_rec.member_transaction_header_id;
   open get_trx_rec_info;
   fetch get_trx_rec_info into
                l_mem_trans_rec.transaction_header_id,
                l_mem_trans_rec.transaction_type_code,
                l_mem_trans_rec.transaction_date_entered,
                l_mem_trans_rec.transaction_name,
                l_mem_trans_rec.source_transaction_header_id,
                l_mem_trans_rec.mass_reference_id,
                l_mem_trans_rec.transaction_subtype,
                l_mem_trans_rec.transaction_key,
                l_mem_trans_rec.amortization_start_date,
                l_mem_trans_rec.calling_interface,
                l_mem_trans_rec.mass_transaction_id,
                l_mem_trans_rec.member_transaction_header_id,
                l_mem_trans_rec.trx_reference_id;
    close get_trx_rec_info;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add('do_group_reclass',
                       'member_asset_id recs done',
                       l_mem_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
   end if;

   l_src_asset_hdr_rec          := l_mem_asset_hdr_rec;
   l_dest_asset_hdr_rec         := l_mem_asset_hdr_rec;

   l_src_asset_hdr_rec.asset_id  := l_mem_asset_fin_rec_old.group_asset_id;
   l_dest_asset_hdr_rec.asset_id := l_mem_asset_fin_rec_new.group_asset_id;

   -- get src info
   if (l_mem_asset_fin_rec_old.group_asset_id is not null) then

      l_src_asset := l_mem_asset_fin_rec_old.group_asset_id;
      if not FA_UTIL_PVT.get_asset_desc_rec
                           (p_asset_hdr_rec         => l_src_asset_hdr_rec,
                            px_asset_desc_rec       => l_src_asset_desc_rec
                           , p_log_level_rec => p_log_level_rec) then
         raise group_rec_err;
      end if;

      if not FA_UTIL_PVT.get_asset_cat_rec
                          (p_asset_hdr_rec         => l_src_asset_hdr_rec,
                            px_asset_cat_rec        => l_src_asset_cat_rec,
                            p_date_effective        => null
                           , p_log_level_rec => p_log_level_rec) then
         raise group_rec_err;
      end if;

      if not FA_UTIL_PVT.get_asset_type_rec
                          (p_asset_hdr_rec         => l_src_asset_hdr_rec,
                            px_asset_type_rec       => l_src_asset_type_rec,
                            p_date_effective        => null
                            , p_log_level_rec => p_log_level_rec) then
         raise group_rec_err;
      end if;

      if not FA_ASSET_VAL_PVT.validate_period_of_addition
                      (p_asset_id            => l_src_asset_hdr_rec.asset_id,
                       p_book                => l_src_asset_hdr_rec.book_type_code,
                       p_mode                => 'ABSOLUTE',
                       px_period_of_addition =>
                                l_src_asset_hdr_rec.period_of_addition, p_log_level_rec => p_log_level_rec) then
         raise group_rec_err;
      end if;

      l_trx_id := p_trx_ref_rec.src_transaction_header_id;
      open get_trx_rec_info;
      fetch get_trx_rec_info into
                l_src_trans_rec.transaction_header_id,
                l_src_trans_rec.transaction_type_code,
                l_src_trans_rec.transaction_date_entered,
                l_src_trans_rec.transaction_name,
                l_src_trans_rec.source_transaction_header_id,
                l_src_trans_rec.mass_reference_id,
                l_src_trans_rec.transaction_subtype,
                l_src_trans_rec.transaction_key,
                l_src_trans_rec.amortization_start_date,
                l_src_trans_rec.calling_interface,
                l_src_trans_rec.mass_transaction_id,
                l_src_trans_rec.member_transaction_header_id,
                l_src_trans_rec.trx_reference_id;
      close get_trx_rec_info;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add('do_group_reclass',
                       'src_asset_id recs done',
                       l_src_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
      end if;

   end if;

   if (l_mem_asset_fin_rec_new.group_asset_id is not null and
       nvl(l_mem_asset_fin_rec_old.group_asset_id, -99) <>
                        l_mem_asset_fin_rec_new.group_asset_id ) then

      l_dest_asset := l_mem_asset_fin_rec_new.group_asset_id;

      -- get dest info
      if not FA_UTIL_PVT.get_asset_desc_rec
                           (p_asset_hdr_rec         => l_dest_asset_hdr_rec,
                            px_asset_desc_rec       => l_dest_asset_desc_rec
                           , p_log_level_rec => p_log_level_rec) then
         raise group_rec_err;
      end if;

      if not FA_UTIL_PVT.get_asset_cat_rec
                           (p_asset_hdr_rec         => l_dest_asset_hdr_rec,
                            px_asset_cat_rec        => l_dest_asset_cat_rec,
                            p_date_effective        => null
                           , p_log_level_rec => p_log_level_rec) then
         raise group_rec_err;
      end if;

      if not FA_UTIL_PVT.get_asset_type_rec
                           (p_asset_hdr_rec         => l_dest_asset_hdr_rec,
                            px_asset_type_rec       => l_dest_asset_type_rec,
                            p_date_effective        => null
                            , p_log_level_rec => p_log_level_rec) then
         raise group_rec_err;
      end if;

      if not FA_ASSET_VAL_PVT.validate_period_of_addition
               (p_asset_id            => l_dest_asset_hdr_rec.asset_id,
                p_book                => l_dest_asset_hdr_rec.book_type_code,
                p_mode                => 'ABSOLUTE',
                px_period_of_addition =>
                        l_dest_asset_hdr_rec.period_of_addition, p_log_level_rec => p_log_level_rec) then
         raise group_rec_err;
      end if;

      l_trx_id := p_trx_ref_rec.dest_transaction_header_id;
      open get_trx_rec_info;
      fetch get_trx_rec_info into
                l_dest_trans_rec.transaction_header_id,
                l_dest_trans_rec.transaction_type_code,
                l_dest_trans_rec.transaction_date_entered,
                l_dest_trans_rec.transaction_name,
                l_dest_trans_rec.source_transaction_header_id,
                l_dest_trans_rec.mass_reference_id,
                l_dest_trans_rec.transaction_subtype,
                l_dest_trans_rec.transaction_key,
                l_dest_trans_rec.amortization_start_date,
                l_dest_trans_rec.calling_interface,
                l_dest_trans_rec.mass_transaction_id,
                l_dest_trans_rec.member_transaction_header_id,
                l_dest_trans_rec.trx_reference_id;
      close get_trx_rec_info;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add('do_group_reclass',
                       'dest_asset_id recs done',
                       l_dest_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
      end if;


   end if;  -- dest info

   if (nvl(l_mem_asset_fin_rec_old.group_asset_id, -99)
                        = nvl(l_mem_asset_fin_rec_new.group_asset_id, -99)) then
            raise group_rec_err;
   elsif (l_mem_asset_fin_rec_old.group_asset_id is not null and
                l_mem_asset_fin_rec_new.group_asset_id is not null) then
            l_group_reclass_code := 'GRP-GRP';
   elsif (l_mem_asset_fin_rec_old.group_asset_id is not null) then
            l_group_reclass_code := 'GRP-NONE';
   else
            l_group_reclass_code := 'NONE-GRP';
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'reclass code', l_group_reclass_code, p_log_level_rec => p_log_level_rec);
   end if;

   l_trx_id_in := l_src_trans_rec.transaction_header_id;
   l_asset_id := l_src_asset_hdr_rec.asset_id;
   open get_old_trx;
   fetch get_old_trx into l_src_old_trx_id;
   close get_old_trx;

   l_trx_id_in := p_trx_ref_rec.MEMBER_TRANSACTION_HEADER_ID;
   l_asset_id := l_mem_asset_hdr_rec.asset_id;
   open get_old_trx;
   fetch get_old_trx into l_mem_old_trx_id;
   close get_old_trx;

   l_trx_id_in := l_dest_trans_rec.transaction_header_id;
   l_asset_id := l_dest_asset_hdr_rec.asset_id;
   open get_old_trx;
   fetch get_old_trx into l_dest_old_trx_id;
   close get_old_trx;

   FOR l_sob_index in 0..l_sob_tbl.count LOOP

      if (l_sob_index = 0) then
         l_mrc_sob_type_code := 'P';
         l_mem_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;
      else
         l_mrc_sob_type_code := 'R';
         l_mem_asset_hdr_rec.set_of_books_id := l_sob_tbl(l_sob_index);
      end if;

      if not FA_UTIL_PVT.get_asset_deprn_rec
              (p_asset_hdr_rec         => l_mem_asset_hdr_rec ,
               px_asset_deprn_rec      => l_mem_asset_deprn_rec_old,
               p_period_counter        => NULL,
               p_mrc_sob_type_code     => l_mrc_sob_type_code,
               p_log_level_rec         => p_log_level_rec) then raise group_rec_err;
      end if;
      l_mem_asset_deprn_rec_old_tbl(l_sob_index) := l_mem_asset_deprn_rec_old;

   END LOOP;

   ------------
   -- SOURCE --
   ------------
   if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'processing','source asset', p_log_level_rec => p_log_level_rec);
   end if;

   -- If the asset was moved out of a group, deduct the asset's cost from the
   -- old group
   FOR l_sob_index in 0..l_sob_tbl.count LOOP
      --
      -- Initialize Member Tables
      --
      FA_AMORT_PVT.initMemberTable;

      if (l_sob_index = 0) then
         l_mrc_sob_type_code := 'P';
         l_src_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;
         l_mem_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;
      else
         l_mrc_sob_type_code := 'R';
         l_src_asset_hdr_rec.set_of_books_id := l_sob_tbl(l_sob_index);
         l_mem_asset_hdr_rec.set_of_books_id := l_sob_tbl(l_sob_index);
      end if;

      l_group_reclass_options_rec(l_sob_index).group_reclass_type := 'CALC';

      if not FA_UTIL_PVT.get_asset_fin_rec
            (p_asset_hdr_rec         => l_mem_asset_hdr_rec,
             px_asset_fin_rec        => l_mem_asset_fin_rec_old,
             p_transaction_header_id => l_mem_old_trx_id,
             p_mrc_sob_type_code     => l_mrc_sob_type_code,
             p_log_level_rec         => p_log_level_rec) then raise group_rec_err;
      end if;

      if not FA_UTIL_PVT.get_asset_deprn_rec
            (p_asset_hdr_rec         => l_mem_asset_hdr_rec ,
             px_asset_deprn_rec      => l_mem_asset_deprn_rec_old,
             p_period_counter        => NULL,
             p_mrc_sob_type_code     => l_mrc_sob_type_code,
             p_log_level_rec         => p_log_level_rec) then raise group_rec_err;
      end if;

      if l_mem_asset_fin_rec_old.group_asset_id is not null then

         -- get the old and new fin,deprn information
         if not FA_UTIL_PVT.get_asset_fin_rec
                    (p_asset_hdr_rec         => l_src_asset_hdr_rec,
                     px_asset_fin_rec        => l_src_asset_fin_rec_old,
                     p_transaction_header_id => l_src_old_trx_id,
                     p_mrc_sob_type_code     => l_mrc_sob_type_code,
                     p_log_level_rec         => p_log_level_rec) then raise group_rec_err;
         end if;

         if not FA_UTIL_PVT.get_asset_fin_rec
                    (p_asset_hdr_rec         => l_src_asset_hdr_rec,
                     px_asset_fin_rec        => l_src_asset_fin_rec_new,
                     p_transaction_header_id => null,
                     p_mrc_sob_type_code     => l_mrc_sob_type_code,
                     p_log_level_rec         => p_log_level_rec) then raise group_rec_err;
         end if;

         if not FA_UTIL_PVT.get_asset_deprn_rec
                    (p_asset_hdr_rec         => l_src_asset_hdr_rec,
                     px_asset_deprn_rec      => l_src_asset_deprn_rec_old,
                     p_period_counter        => NULL,
                     p_mrc_sob_type_code     => l_mrc_sob_type_code,
                     p_log_level_rec         => p_log_level_rec) then raise group_rec_err;
         end if;

         if not FA_UTIL_PVT.get_asset_deprn_rec
                    (p_asset_hdr_rec         => l_src_asset_hdr_rec ,
                     px_asset_deprn_rec      => l_src_asset_deprn_rec_new,
                     p_period_counter        => NULL,
                     p_mrc_sob_type_code     => l_mrc_sob_type_code,
                     p_log_level_rec         => p_log_level_rec) then raise group_rec_err;
         end if;

         /*Bug 8765735 - Start*/
 	      if not fa_cache_pkg.fazccmt(l_src_asset_fin_rec_old.deprn_method_code,
 	                                  l_src_asset_fin_rec_old.life_in_months,
 	                                  p_log_level_rec => g_log_level_rec) then
 	                                  fa_srvr_msg.add_message (calling_fn => l_calling_fn,p_log_level_rec=>g_log_level_rec);
 	         raise group_rec_err;
 	      end if;
 	      /*Bug 8765735 - End*/
         /*Bug 8814747 added this condition for Energy methods amortization date is always current period.
 	        So we are calculating the reserve in bsRecalculate. Not required to pass from here.*/
 	      if (not(nvl(fa_cache_pkg.fazcdbr_record.rule_name,'ZZ') = 'ENERGY PERIOD END BALANCE' and
 	              l_src_asset_fin_rec_old.tracking_method = 'ALLOCATE')) then

         if (l_src_asset_fin_rec_old.tracking_method = 'ALLOCATE' or
             (l_src_asset_fin_rec_old.tracking_method = 'CALCULATE' and
              nvl(l_src_asset_fin_rec_old.member_rollup_flag, 'N') = 'N')) then

            OPEN c_get_reserve;
            FETCH c_get_reserve INTO l_transfer_amount;
            CLOSE c_get_reserve;

            l_src_asset_deprn_rec_adj.deprn_reserve := -1 * nvl(l_transfer_amount, 0);

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Getting previously transferred rsv', l_transfer_amount , p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_src_asset_deprn_rec_adj.deprn_reserve', l_src_asset_deprn_rec_adj.deprn_reserve, p_log_level_rec => p_log_level_rec);
            end if;
         end if;
         end if;

         --
         -- Calling faxama
         --
         if (not FA_AMORT_PVT.faxama(
                            px_trans_rec            => l_src_trans_rec,
                            p_asset_hdr_rec         => l_src_asset_hdr_rec,
                            p_asset_desc_rec        => l_src_asset_desc_rec,
                            p_asset_cat_rec         => l_src_asset_cat_rec,
                            p_asset_type_rec        => l_src_asset_type_rec,
                            p_asset_fin_rec_old     => l_src_asset_fin_rec_old,
                            px_asset_fin_rec_new    => l_src_asset_fin_rec_new,
                            p_asset_deprn_rec       => l_src_asset_deprn_rec_old,
                            p_asset_deprn_rec_adj   => l_src_asset_deprn_rec_adj,
                            p_period_rec            => l_period_rec,
                            p_mrc_sob_type_code     => l_mrc_sob_type_code,
                            p_running_mode          => fa_std_types.FA_DPR_NORMAL,
                            p_used_by_revaluation   => null,
                            p_reclassed_asset_id    => l_mem_asset_hdr_rec.asset_id,
                            p_reclass_src_dest      => 'SOURCE',
                            p_reclassed_asset_dpis  => l_mem_asset_fin_rec_old.date_placed_in_service,
                            p_update_books_summary  => TRUE,
                            p_proceeds_of_sale      => 0,
                            p_cost_of_removal       => 0,
                            x_deprn_exp             => l_group_reclass_options_rec(l_sob_index).source_exp_amount,
                            x_bonus_deprn_exp       => l_bonus_deprn_exp,
                            x_impairment_exp        => l_impairment_exp,
                            x_deprn_rsv             => l_deprn_rsv, p_log_level_rec => p_log_level_rec)) then

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'calling FA_AMORT_PVT.faxama', 'FAILED',  p_log_level_rec => p_log_level_rec);
               end if;

               raise group_rec_err;

         end if; -- (not FA_AMORT_PVT.faxama

         l_grp_src_trans_rec(l_sob_index) := l_src_trans_rec;
         l_grp_src_asset_hdr_rec(l_sob_index) := l_src_asset_hdr_rec;
         l_grp_src_asset_type_rec(l_sob_index) := l_src_asset_type_rec;
         l_grp_src_asset_fin_rec_new(l_sob_index) := l_src_asset_fin_rec_new;

         If (l_group_reclass_code = 'GRP-GRP') then
            FOR i in 1..fa_amort_pvt.tmd_period_counter.COUNT LOOP
               l_amort_init_member_rec(l_sob_index).tmd_period_counter(i)     := fa_amort_pvt.tmd_period_counter(i);
               l_amort_init_member_rec(l_sob_index).tmd_cost(i)               := fa_amort_pvt.tmd_cost(i);
               l_amort_init_member_rec(l_sob_index).tm_cost(i)                := fa_amort_pvt.tm_cost(i);
               l_amort_init_member_rec(l_sob_index).tmd_cip_cost(i)           := fa_amort_pvt.tmd_cip_cost(i);
               l_amort_init_member_rec(l_sob_index).tm_cip_cost(i)            := fa_amort_pvt.tm_cip_cost(i);
               l_amort_init_member_rec(l_sob_index).tmd_salvage_value(i)      := fa_amort_pvt.tmd_salvage_value(i);
               l_amort_init_member_rec(l_sob_index).tm_salvage_value(i)       := fa_amort_pvt.tm_salvage_value(i);
               l_amort_init_member_rec(l_sob_index).tmd_deprn_limit_amount(i) := fa_amort_pvt.tmd_deprn_limit_amount(i);
               l_amort_init_member_rec(l_sob_index).tm_deprn_limit_amount(i)  := fa_amort_pvt.tm_deprn_limit_amount(i);
            END LOOP;
         End If;

         -- call the category books cache for the accounts
         if not fa_cache_pkg.fazccb
            (X_book   => l_src_asset_hdr_rec.book_type_code,
            X_cat_id => l_src_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
            raise group_rec_err;
         end if;

         -- set up the structs to be passed to faxinaj
         l_rsv_adj.book_type_code           := l_src_asset_hdr_rec.book_type_code;
         l_rsv_adj.period_counter_created   := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
         l_rsv_adj.period_counter_adjusted  := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
         l_rsv_adj.selection_mode           := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
         l_rsv_adj.selection_thid           := 0;
         l_rsv_adj.selection_retid          := 0;
         l_rsv_adj.leveling_flag            := TRUE;
         l_rsv_adj.last_update_date         := l_src_trans_rec.transaction_date_entered;
         l_rsv_adj.flush_adj_flag           := TRUE;
         l_rsv_adj.gen_ccid_flag            := TRUE;
         l_rsv_adj.annualized_adjustment    := 0;
         l_rsv_adj.asset_invoice_id         := 0;
         l_rsv_adj.distribution_id          := 0;
         l_rsv_adj.mrc_sob_type_code        := l_mrc_sob_type_code;
         l_rsv_adj.set_of_books_id          := l_src_asset_hdr_rec.set_of_books_id;
         l_rsv_adj.source_type_code         := 'ADJUSTMENT';
         l_rsv_adj.adjustment_type          := 'RESERVE';
         l_rsv_adj.code_combination_id      := fa_cache_pkg.fazccb_record.reserve_account_ccid;
         l_rsv_adj.account                  := fa_cache_pkg.fazccb_record.deprn_reserve_acct;
         l_rsv_adj.account_type             := 'DEPRN_RESERVE_ACCT';

         l_rsv_adj.transaction_header_id    := l_src_trans_rec.transaction_header_id;
         l_rsv_adj.asset_id                 := l_src_asset_hdr_rec.asset_id;
         l_rsv_adj.current_units            := l_src_asset_desc_rec.current_units;
         l_rsv_adj.code_combination_id      := fa_cache_pkg.fazccb_record.reserve_account_ccid;
         l_rsv_adj.account                  := fa_cache_pkg.fazccb_record.deprn_reserve_acct;
         l_rsv_adj.debit_credit_flag        := 'DR';


         l_exp_adj.book_type_code           := l_src_asset_hdr_rec.book_type_code;
         l_exp_adj.period_counter_created   := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
         l_exp_adj.period_counter_adjusted  := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
         l_exp_adj.selection_mode           := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
         l_exp_adj.selection_thid           := 0;
         l_exp_adj.selection_retid          := 0;
         l_exp_adj.leveling_flag            := TRUE;
         l_exp_adj.last_update_date         := l_src_trans_rec.transaction_date_entered;
         l_exp_adj.flush_adj_flag           := TRUE;
         l_exp_adj.gen_ccid_flag            := TRUE;
         l_exp_adj.annualized_adjustment    := 0;
         l_exp_adj.asset_invoice_id         := 0;
         l_exp_adj.distribution_id          := 0;
         l_exp_adj.mrc_sob_type_code        := l_mrc_sob_type_code;
         l_exp_adj.set_of_books_id          := l_src_asset_hdr_rec.set_of_books_id;
         l_exp_adj.source_type_code         := 'DEPRECIATION';
         l_exp_adj.adjustment_type          := 'EXPENSE';
         l_exp_adj.account_type             := 'DEPRN_EXPENSE_ACCT';

         l_exp_adj.transaction_header_id    := l_src_trans_rec.transaction_header_id;
         l_exp_adj.asset_id                 := l_src_asset_hdr_rec.asset_id;
         l_exp_adj.current_units            := l_src_asset_desc_rec.current_units;
         l_exp_adj.code_combination_id      := 0;
         l_exp_adj.account                  := fa_cache_pkg.fazccb_record.deprn_expense_acct;
         l_exp_adj.debit_credit_flag        := 'CR';

         -- Expense accounts have to be CR for the old acct
         -- Reserve accounts have to be DR for the old acct

         if (nvl(l_group_reclass_options_rec(l_sob_index).source_exp_amount, 0) <> 0) then

            l_exp_adj.adjustment_amount := -1 * l_group_reclass_options_rec(l_sob_index).source_exp_amount;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'calling faxinaj','for exp source group', p_log_level_rec => p_log_level_rec);
            end if;

            l_exp_adj.track_member_flag := null; --Bug 9089120

            if not FA_INS_ADJUST_PKG.faxinaj
                  (l_exp_adj,
                   l_src_trans_rec.who_info.last_update_date,
                   l_src_trans_rec.who_info.last_updated_by,
                   l_src_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
               raise group_rec_err;
            end if;

            if (nvl(l_src_asset_fin_rec_old.tracking_method, 'NO TRACK') = 'ALLOCATE') then

              -- call the category books cache for the accounts
               if not fa_cache_pkg.fazccb
                         (X_book   => l_mem_asset_hdr_rec.book_type_code,
                          X_cat_id => l_mem_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
                  raise group_rec_err;
               end if;

               l_exp_adj.transaction_header_id    := l_mem_trans_rec.transaction_header_id;
               l_exp_adj.current_units            := l_mem_asset_desc_rec.current_units;
               l_exp_adj.asset_id                 := l_mem_asset_hdr_rec.asset_id;
               l_exp_adj.account                  := fa_cache_pkg.fazccb_record.deprn_expense_acct;
               l_exp_adj.track_member_flag        := 'Y';

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'calling faxinaj','for exp source track', p_log_level_rec => p_log_level_rec);
               end if;

               if not FA_INS_ADJUST_PKG.faxinaj
                       (l_exp_adj,
                       l_src_trans_rec.who_info.last_update_date,
                       l_src_trans_rec.who_info.last_updated_by,
                       l_src_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
                     raise group_rec_err;
               end if;
            end if;

         end if;

         if (nvl(l_deprn_rsv, 0) <> 0) then

            l_group_reclass_options_rec(l_sob_index).reserve_amount := -1 * l_deprn_rsv;
            l_rsv_adj.adjustment_amount := l_group_reclass_options_rec(l_sob_index).reserve_amount;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'calling faxinaj','for rsv source group', p_log_level_rec => p_log_level_rec);
            end if;

            l_rsv_adj.track_member_flag := null; --Bug 9089120

            if not FA_INS_ADJUST_PKG.faxinaj
                  (l_rsv_adj,
                   l_src_trans_rec.who_info.last_update_date,
                   l_src_trans_rec.who_info.last_updated_by,
                   l_src_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
                  raise group_rec_err;
            end if;

            if (nvl(l_src_asset_fin_rec_old.tracking_method,'NO TRACK')='ALLOCATE') then

               -- call the category books cache for the accounts
               if not fa_cache_pkg.fazccb
                         (X_book   => l_mem_asset_hdr_rec.book_type_code,
                          X_cat_id => l_mem_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
                  raise group_rec_err;
               end if;

               l_rsv_adj.transaction_header_id    := l_mem_trans_rec.transaction_header_id;
               l_rsv_adj.current_units            := l_mem_asset_desc_rec.current_units;
               l_rsv_adj.asset_id                 := l_mem_asset_hdr_rec.asset_id;
               l_rsv_adj.code_combination_id      := fa_cache_pkg.fazccb_record.reserve_account_ccid;
               l_rsv_adj.account                  := fa_cache_pkg.fazccb_record.deprn_reserve_acct;
               l_rsv_adj.track_member_flag        := 'Y';

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'calling faxinaj','for rsv source track', p_log_level_rec => p_log_level_rec);
               end if;

               if not FA_INS_ADJUST_PKG.faxinaj
                  (l_rsv_adj,
                  l_src_trans_rec.who_info.last_update_date,
                  l_src_trans_rec.who_info.last_updated_by,
                  l_src_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
                  raise group_rec_err;
               end if;
            end if;

         end if;

      -- Modified to call FA_GROUP_RECLASS2_PVT.do_adjustment
      -- even old group id is populated if the track method is allocate

      else  -- asset was originally standalone

         if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'source is','standalone', p_log_level_rec => p_log_level_rec);
         end if;

         -- whether expense or reserve transfer, amount must be set to
         -- the current reserve balance in order to remove all balances
         -- from the memeber asset (i.e. ignore calc / manual) this is
         -- done internally inside the private api

         -- set the main structs equal to member if asset was
         -- originally standalone

         l_src_trans_rec           := l_mem_trans_rec;
         l_src_asset_hdr_rec       := l_mem_asset_hdr_rec;
         l_src_asset_desc_rec      := l_mem_asset_desc_rec;
         l_src_asset_type_rec      := l_mem_asset_type_rec;
         l_src_asset_cat_rec       := l_mem_asset_cat_rec;
         l_src_asset_fin_rec_new   := l_mem_asset_fin_rec_old; -- NOTE: using old
         l_src_asset_deprn_rec_new := l_mem_asset_deprn_rec_old_tbl(l_sob_index);


         if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'calling FA_GROUP_RECLASS2_PVT.do_adjustment', l_src_asset_hdr_rec.asset_id,  p_log_level_rec => p_log_level_rec);
         end if;

         if not FA_GROUP_RECLASS2_PVT.do_adjustment
                    (px_trans_rec                 => l_src_trans_rec,
                     p_asset_hdr_rec              => l_src_asset_hdr_rec,
                     p_asset_desc_rec             => l_src_asset_desc_rec,
                     p_asset_type_rec             => l_src_asset_type_rec,
                     p_asset_cat_rec              => l_src_asset_cat_rec,
                     p_asset_fin_rec_old          => l_src_asset_fin_rec_old,
                     p_asset_fin_rec_new          => l_src_asset_fin_rec_new,
                     p_asset_deprn_rec_old        => l_src_asset_deprn_rec_new,
                     p_mem_asset_hdr_rec          => l_mem_asset_hdr_rec,
                     p_mem_asset_desc_rec         => l_mem_asset_desc_rec,
                     p_mem_asset_type_rec         => l_mem_asset_type_rec,
                     p_mem_asset_cat_rec          => l_mem_asset_cat_rec,
                     p_mem_asset_fin_rec_new      => l_mem_asset_fin_rec_old,
                     p_mem_asset_deprn_rec_new    => l_mem_asset_deprn_rec_old_tbl(l_sob_index),
                     px_group_reclass_options_rec => l_group_reclass_options_rec(l_sob_index),
                     p_period_rec                 => l_period_rec,
                     p_mrc_sob_type_code          => l_mrc_sob_type_code,
                     p_src_dest                   => 'SOURCE',
                     p_log_level_rec              => p_log_level_rec) then
            raise group_rec_err;
         end if;
         l_grp_src_trans_rec(l_sob_index) := l_src_trans_rec;
         l_grp_src_asset_hdr_rec(l_sob_index) := l_src_asset_hdr_rec;
         l_grp_src_asset_type_rec(l_sob_index) := l_src_asset_type_rec;
         l_grp_src_asset_fin_rec_new(l_sob_index) := l_src_asset_fin_rec_new;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'after FA_GROUP_RECLASS2_PVT.do_adjustment',l_src_asset_hdr_rec.asset_id,  p_log_level_rec => p_log_level_rec);
         end if;

      end if; -- end of source
   END LOOP;


   -- clear the track flags before we start again
   l_exp_adj.track_member_flag        := NULL;
   l_rsv_adj.track_member_flag        := NULL;



   --------------------------
   -- CONDITIONAL TRANSFER --
   --------------------------

   -- BUG# 6936546
   -- in allocation cases it is possible in cases where asset is moving into or out of
   -- a standalone status for true expense to be combined with tracked expense in the
   -- same period.  In order to seperate these for correct reserve processing from DD
   -- for journaling purposes, we will force a transfer so we can seperate the two
   -- into different distributions when the reclass is backdated creating expense
   --
   -- thus this transfer effectively is a complete wash, although only cost
   -- will be moved in the transaction.
   --
   -- NOTE: this would spawn a transfer when occuring in tax books as well
   --       since we share distirubtions, there is really no way around this...

   if ((l_group_reclass_code = 'GRP-NONE' or
        l_group_reclass_code = 'NONE-GRP') and
       (nvl(l_src_asset_fin_rec_old.tracking_method,'NONE')  <> 'CALCULATE' or
        nvl(l_dest_asset_fin_rec_old.tracking_method,'NONE') <> 'CALCULATE') and
       l_mem_asset_hdr_rec.period_of_addition <> 'Y') then

      if (p_mrc_sob_type_code <> 'R') then

         open c_member_dists (p_asset_id => l_mem_asset_hdr_rec.asset_id);
         fetch c_member_dists bulk collect
          into l_distribution_id,
               l_units_assigned,
               l_code_combination_id,
               l_location_id,
               l_assigned_to;
         close c_member_dists;

         -- load current dists into array
         for i in 1..l_distribution_id.count loop
            l_asset_dist_tbl(i).distribution_id   := l_distribution_id(i);
            l_asset_dist_tbl(i).transaction_units := -l_units_assigned(i);
         end loop;

         -- load the new dists into array
         for i in 1..l_distribution_id.count loop
            l_asset_dist_tbl(i+l_distribution_id.count).expense_ccid      := l_code_combination_id(i);
            l_asset_dist_tbl(i+l_distribution_id.count).location_ccid     := l_location_id(i);
            l_asset_dist_tbl(i+l_distribution_id.count).assigned_to       := l_assigned_to(i);
            l_asset_dist_tbl(i+l_distribution_id.count).transaction_units := l_units_assigned(i);
         end loop;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'calling' ,'transfer api for standalone asset', p_log_level_rec => p_log_level_rec);
         end if;

         l_asset_hdr_rec := l_mem_asset_hdr_rec;
         l_asset_hdr_rec.book_type_code := fa_cache_pkg.fazcbc_record.distribution_source_book;

         FA_TRANSFER_PUB.do_transfer
            (p_api_version         => l_api_version,
             p_init_msg_list       => l_init_msg_list,
             p_commit              => l_commit,
             p_validation_level    => l_validation_level,
             p_calling_fn          => l_calling_fn,
             x_return_status       => l_return_status2,
             x_msg_count           => l_msg_count,
             x_msg_data            => l_msg_data,
             px_trans_rec          => l_trans_rec,
             px_asset_hdr_rec      => l_asset_hdr_rec,
             px_asset_dist_tbl     => l_asset_dist_tbl);

         if (l_return_status2 <> FND_API.G_RET_STS_SUCCESS) then
            raise group_rec_err;
         end if;

         -- following update and that in the else is needed in case
         -- the transfer was performed on STANDALONE->GROUP
         -- case where the reserve would have been inserted as track
         -- when it should not have been.

         if (l_group_reclass_code = 'NONE-GRP') then

            update fa_adjustments
               set track_member_flag     = null
             where transaction_header_id = l_trans_rec.transaction_header_id
               and book_type_code        = l_asset_hdr_rec.book_type_code;

         end if;

      elsif (l_group_reclass_code = 'NONE-GRP') then  -- reporting is implied in else

         select transaction_header_id
           into l_trans_rec.transaction_header_id
           from fa_transaction_headers
          where asset_id = l_mem_asset_hdr_rec.asset_id
            and book_type_code = l_mem_asset_hdr_rec.book_type_code
            and transaction_type_code = 'TRANSFER'
            and transaction_header_id > l_mem_trans_rec.transaction_header_id;

         update fa_mc_adjustments
            set track_member_flag     = null
          where transaction_header_id = l_trans_rec.transaction_header_id
            and book_type_code        = l_asset_hdr_rec.book_type_code
            and set_of_books_id = l_asset_hdr_rec.set_of_books_id;

      end if;

   end if;


   ------------
   -- DESTINATION --
   ------------
   if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'processing','dest asset', p_log_level_rec => p_log_level_rec);
   end if;

   FOR l_sob_index in 0..l_sob_tbl.count LOOP

      --
      -- Initialize Member Tables
      --
      FA_AMORT_PVT.initMemberTable;

      if (l_sob_index = 0) then
         l_mrc_sob_type_code := 'P';
         l_dest_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;
         l_mem_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;
      else
         l_mrc_sob_type_code := 'R';
         l_dest_asset_hdr_rec.set_of_books_id := l_sob_tbl(l_sob_index);
         l_mem_asset_hdr_rec.set_of_books_id := l_sob_tbl(l_sob_index);
      end if;


      if not FA_UTIL_PVT.get_asset_fin_rec
              (p_asset_hdr_rec         => l_mem_asset_hdr_rec,
               px_asset_fin_rec        => l_mem_asset_fin_rec_old,
               p_transaction_header_id => l_mem_old_trx_id,
               p_mrc_sob_type_code     => l_mrc_sob_type_code,
               p_log_level_rec         => p_log_level_rec) then raise group_rec_err;
      end if;

      if not FA_UTIL_PVT.get_asset_fin_rec
              (p_asset_hdr_rec         => l_mem_asset_hdr_rec,
               px_asset_fin_rec        => l_mem_asset_fin_rec_new,
               p_transaction_header_id => null,
               p_mrc_sob_type_code     => l_mrc_sob_type_code,
               p_log_level_rec         => p_log_level_rec) then raise group_rec_err;
      end if;

      if not FA_UTIL_PVT.get_asset_deprn_rec
              (p_asset_hdr_rec         => l_mem_asset_hdr_rec ,
               px_asset_deprn_rec      => l_mem_asset_deprn_rec_new,
               p_period_counter        => NULL,
               p_mrc_sob_type_code     => l_mrc_sob_type_code,
               p_log_level_rec         => p_log_level_rec) then raise group_rec_err;
      end if;

      -- If the asset was moved into a group, add the asset's cost to the new group
      if l_mem_asset_fin_rec_new.group_asset_id is not null then

         if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn, 'processing dest as ','group', p_log_level_rec => p_log_level_rec);
         end if;

          -- get the old fin and deprn information
         if not FA_UTIL_PVT.get_asset_fin_rec
                 (p_asset_hdr_rec         => l_dest_asset_hdr_rec,
                  px_asset_fin_rec        => l_dest_asset_fin_rec_old,
                  p_transaction_header_id => l_dest_old_trx_id,
                  p_mrc_sob_type_code     => l_mrc_sob_type_code,
                  p_log_level_rec         => p_log_level_rec) then raise group_rec_err;
         end if;

         if not FA_UTIL_PVT.get_asset_fin_rec
                 (p_asset_hdr_rec         => l_dest_asset_hdr_rec,
                  px_asset_fin_rec        => l_dest_asset_fin_rec_new,
                  p_transaction_header_id => null,
                  p_mrc_sob_type_code     => l_mrc_sob_type_code,
                  p_log_level_rec         => p_log_level_rec) then raise group_rec_err;
         end if;

         if not FA_UTIL_PVT.get_asset_deprn_rec
                 (p_asset_hdr_rec         => l_dest_asset_hdr_rec,
                  px_asset_deprn_rec      => l_dest_asset_deprn_rec_old,
                  p_period_counter        => NULL,
                  p_mrc_sob_type_code     => l_mrc_sob_type_code,
                  p_log_level_rec         => p_log_level_rec) then raise group_rec_err;
         end if;

         if not FA_UTIL_PVT.get_asset_deprn_rec
                 (p_asset_hdr_rec         => l_dest_asset_hdr_rec,
                  px_asset_deprn_rec      => l_dest_asset_deprn_rec_new,
                  p_period_counter        => NULL,
                  p_mrc_sob_type_code     => l_mrc_sob_type_code,
                  p_log_level_rec         => p_log_level_rec) then raise group_rec_err;
         end if;

         l_asset_deprn_rec_adj.deprn_reserve := l_group_reclass_options_rec(l_sob_index).reserve_amount;
         --
         -- This is used to calculate adj.eofy_reserve in faxama.
         --
         if l_mem_asset_fin_rec_old.group_asset_id is null then
            l_asset_deprn_rec_adj.ytd_deprn := l_mem_asset_deprn_rec_old_tbl(l_sob_index).ytd_deprn;
         end if;

         If (l_group_reclass_code = 'GRP-GRP') then
            FOR i in 1..l_amort_init_member_rec(l_sob_index).tmd_period_counter.count LOOP
               fa_amort_pvt.tmd_period_counter(i)     := l_amort_init_member_rec(l_sob_index).tmd_period_counter(i);
               fa_amort_pvt.tmd_cost(i)               := l_amort_init_member_rec(l_sob_index).tmd_cost(i);
               fa_amort_pvt.tm_cost(i)                := l_amort_init_member_rec(l_sob_index).tm_cost(i);
               fa_amort_pvt.tmd_cip_cost(i)           := l_amort_init_member_rec(l_sob_index).tmd_cip_cost(i);
               fa_amort_pvt.tm_cip_cost(i)            := l_amort_init_member_rec(l_sob_index).tm_cip_cost(i);
               fa_amort_pvt.tmd_salvage_value(i)      := l_amort_init_member_rec(l_sob_index).tmd_salvage_value(i);
               fa_amort_pvt.tm_salvage_value(i)       := l_amort_init_member_rec(l_sob_index).tm_salvage_value(i);
               fa_amort_pvt.tmd_deprn_limit_amount(i) := l_amort_init_member_rec(l_sob_index).tmd_deprn_limit_amount(i);
               fa_amort_pvt.tm_deprn_limit_amount(i)  := l_amort_init_member_rec(l_sob_index).tm_deprn_limit_amount(i);
            END LOOP;
         End If;

         if (not FA_AMORT_PVT.faxama(
                         px_trans_rec            => l_dest_trans_rec,
                         p_asset_hdr_rec         => l_dest_asset_hdr_rec,
                         p_asset_desc_rec        => l_dest_asset_desc_rec,
                         p_asset_cat_rec         => l_dest_asset_cat_rec,
                         p_asset_type_rec        => l_dest_asset_type_rec,
                         p_asset_fin_rec_old     => l_dest_asset_fin_rec_old,
                         px_asset_fin_rec_new    => l_dest_asset_fin_rec_new,
                         p_asset_deprn_rec       => l_dest_asset_deprn_rec_old,
                         p_asset_deprn_rec_adj   => l_asset_deprn_rec_adj,
                         p_period_rec            => l_period_rec,
                         p_mrc_sob_type_code     => l_mrc_sob_type_code,
                         p_running_mode          => fa_std_types.FA_DPR_NORMAL,
                         p_used_by_revaluation   => null,
                         p_reclassed_asset_id    => l_mem_asset_hdr_rec.asset_id,
                         p_reclass_src_dest      => 'DESTINATION',
                         p_reclassed_asset_dpis  => l_mem_asset_fin_rec_old.date_placed_in_service,
                         p_update_books_summary  => TRUE,
                         p_proceeds_of_sale      => 0,
                         p_cost_of_removal       => 0,
                         x_deprn_exp             => l_group_reclass_options_rec(l_sob_index).destination_exp_amount,
                         x_bonus_deprn_exp       => l_bonus_deprn_exp,
                         x_impairment_exp        => l_impairment_exp,
                         x_deprn_rsv             => l_deprn_rsv, p_log_level_rec => p_log_level_rec)) then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add('calc_fin_info', 'calling FA_AMORT_PVT.faxama', 'FAILED',  p_log_level_rec => p_log_level_rec);
            end if;
            return (FALSE);

         end if; -- (not FA_AMORT_PVT.faxama

         l_grp_dest_trans_rec(l_sob_index) := l_dest_trans_rec;
         l_grp_dest_asset_hdr_rec(l_sob_index) := l_dest_asset_hdr_rec;
         l_grp_dest_asset_type_rec(l_sob_index) := l_dest_asset_type_rec;
         l_grp_dest_asset_fin_rec_new(l_sob_index) := l_dest_asset_fin_rec_new;

         -- call the category books cache for the accounts
         if not fa_cache_pkg.fazccb
               (X_book   => l_dest_asset_hdr_rec.book_type_code,
                X_cat_id => l_dest_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
            raise group_rec_err;
         end if;

         -- set up the structs to be passed to faxinaj
         l_rsv_adj.book_type_code           := l_src_asset_hdr_rec.book_type_code;
         l_rsv_adj.period_counter_created   := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
         l_rsv_adj.period_counter_adjusted  := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
         l_rsv_adj.selection_mode           := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
         l_rsv_adj.selection_thid           := 0;
         l_rsv_adj.selection_retid          := 0;
         l_rsv_adj.leveling_flag            := TRUE;
         l_rsv_adj.last_update_date         := l_grp_src_trans_rec(l_sob_index).transaction_date_entered;
         l_rsv_adj.flush_adj_flag           := TRUE;
         l_rsv_adj.gen_ccid_flag            := TRUE;
         l_rsv_adj.annualized_adjustment    := 0;
         l_rsv_adj.asset_invoice_id         := 0;
         l_rsv_adj.distribution_id          := 0;
         l_rsv_adj.mrc_sob_type_code        := l_mrc_sob_type_code;
         l_rsv_adj.set_of_books_id          := l_dest_asset_hdr_rec.set_of_books_id;
         l_rsv_adj.source_type_code         := 'ADJUSTMENT';
         l_rsv_adj.adjustment_type          := 'RESERVE';
         l_rsv_adj.code_combination_id      := fa_cache_pkg.fazccb_record.reserve_account_ccid;
         l_rsv_adj.account                  := fa_cache_pkg.fazccb_record.deprn_reserve_acct;
         l_rsv_adj.account_type             := 'DEPRN_RESERVE_ACCT';

         l_rsv_adj.asset_id                 := l_src_asset_hdr_rec.asset_id;
         l_rsv_adj.current_units            := l_src_asset_desc_rec.current_units;
         l_rsv_adj.code_combination_id      := fa_cache_pkg.fazccb_record.reserve_account_ccid;
         l_rsv_adj.account                  := fa_cache_pkg.fazccb_record.deprn_reserve_acct;
         l_rsv_adj.debit_credit_flag        := 'CR';

         l_exp_adj.book_type_code           := l_src_asset_hdr_rec.book_type_code;
         l_exp_adj.period_counter_created   := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
         l_exp_adj.period_counter_adjusted  := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
         l_exp_adj.selection_mode           := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
         l_exp_adj.selection_thid           := 0;
         l_exp_adj.selection_retid          := 0;
         l_exp_adj.leveling_flag            := TRUE;
         l_exp_adj.last_update_date         := l_grp_src_trans_rec(l_sob_index).transaction_date_entered;
         l_exp_adj.flush_adj_flag           := TRUE;
         l_exp_adj.gen_ccid_flag            := TRUE;
         l_exp_adj.annualized_adjustment    := 0;
         l_exp_adj.asset_invoice_id         := 0;
         l_exp_adj.distribution_id          := 0;
         l_exp_adj.mrc_sob_type_code        := l_mrc_sob_type_code;
         l_exp_adj.set_of_books_id          := l_dest_asset_hdr_rec.set_of_books_id;
         l_exp_adj.source_type_code         := 'DEPRECIATION';
         l_exp_adj.adjustment_type          := 'EXPENSE';
         l_exp_adj.account_type             := 'DEPRN_EXPENSE_ACCT';

         l_exp_adj.asset_id                 := l_src_asset_hdr_rec.asset_id;
         l_exp_adj.current_units            := l_src_asset_desc_rec.current_units;
         l_exp_adj.code_combination_id      := 0;
         l_exp_adj.account                  := fa_cache_pkg.fazccb_record.deprn_expense_acct;
         l_exp_adj.debit_credit_flag        := 'DR';

         -- set up the structs to be passed to faxinaj
         l_rsv_adj.transaction_header_id    := l_dest_trans_rec.transaction_header_id;
         l_rsv_adj.asset_id                 := l_dest_asset_hdr_rec.asset_id;
         l_rsv_adj.current_units            := l_dest_asset_desc_rec.current_units;

         l_exp_adj.transaction_header_id    := l_dest_trans_rec.transaction_header_id;
         l_exp_adj.asset_id                 := l_dest_asset_hdr_rec.asset_id;
         l_exp_adj.current_units            := l_dest_asset_desc_rec.current_units;

         -- Expense accounts have to be DR for the new acct
         -- Reserve accounts have to be CR for the new acct

         if (nvl(l_group_reclass_options_rec(l_sob_index).destination_exp_amount, 0) <> 0) then

            l_exp_adj.adjustment_amount := l_group_reclass_options_rec(l_sob_index).destination_exp_amount;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'calling faxinaj','for exp dest', p_log_level_rec => p_log_level_rec);
            end if;

            l_exp_adj.track_member_flag := null; --Bug 9089120

            if not FA_INS_ADJUST_PKG.faxinaj
               (l_exp_adj,
                l_dest_trans_rec.who_info.last_update_date,
                l_dest_trans_rec.who_info.last_updated_by,
                l_dest_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
               raise group_rec_err;
            end if;


            if (nvl(l_dest_asset_fin_rec_new.tracking_method, 'NO TRACK') = 'ALLOCATE') then

               -- call the category books cache for the accounts
               if not fa_cache_pkg.fazccb
                         (X_book   => l_mem_asset_hdr_rec.book_type_code,
                          X_cat_id => l_mem_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
                  raise group_rec_err;
               end if;

               l_exp_adj.transaction_header_id    := l_mem_trans_rec.transaction_header_id;
               l_exp_adj.current_units            := l_mem_asset_desc_rec.current_units;
               l_exp_adj.asset_id                 := l_mem_asset_hdr_rec.asset_id;
               l_exp_adj.account                  := fa_cache_pkg.fazccb_record.deprn_expense_acct;
               l_exp_adj.track_member_flag        := 'Y';

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'calling faxinaj','for exp dest track', p_log_level_rec => p_log_level_rec);
               end if;

               if not FA_INS_ADJUST_PKG.faxinaj
                       (l_exp_adj,
                       l_grp_src_trans_rec(l_sob_index).who_info.last_update_date,
                       l_grp_src_trans_rec(l_sob_index).who_info.last_updated_by,
                       l_grp_src_trans_rec(l_sob_index).who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
                  raise group_rec_err;
               end if;
            end if;

         end if;

         if (nvl(l_group_reclass_options_rec(l_sob_index).reserve_amount, 0) <> 0) then

            l_rsv_adj.adjustment_amount := l_group_reclass_options_rec(l_sob_index).reserve_amount;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'calling faxinaj','for rsv dest', p_log_level_rec => p_log_level_rec);
            end if;

            l_rsv_adj.track_member_flag := null; --Bug 9089120

            if not FA_INS_ADJUST_PKG.faxinaj
               (l_rsv_adj,
                l_dest_trans_rec.who_info.last_update_date,
                l_dest_trans_rec.who_info.last_updated_by,
                l_dest_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
               raise group_rec_err;
            end if;

            if (nvl(l_dest_asset_fin_rec_new.tracking_method,'NO TRACK')='ALLOCATE') then

               -- call the category books cache for the accounts
               if not fa_cache_pkg.fazccb
                         (X_book   => l_mem_asset_hdr_rec.book_type_code,
                          X_cat_id => l_mem_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
                  raise group_rec_err;
               end if;

               l_rsv_adj.transaction_header_id    := l_mem_trans_rec.transaction_header_id;
               l_rsv_adj.current_units            := l_mem_asset_desc_rec.current_units;
               l_rsv_adj.asset_id                 := l_mem_asset_hdr_rec.asset_id;
               l_rsv_adj.code_combination_id      := fa_cache_pkg.fazccb_record.reserve_account_ccid;
               l_rsv_adj.account                  := fa_cache_pkg.fazccb_record.deprn_reserve_acct;
               l_rsv_adj.track_member_flag        := 'Y';

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'calling faxinaj','for rsv dest track', p_log_level_rec => p_log_level_rec);
               end if;

               if not FA_INS_ADJUST_PKG.faxinaj
                  (l_rsv_adj,
                  l_grp_src_trans_rec(l_sob_index).who_info.last_update_date,
                  l_grp_src_trans_rec(l_sob_index).who_info.last_updated_by,
                  l_grp_src_trans_rec(l_sob_index).who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
                  raise group_rec_err;
               end if;
            end if;
         end if;

      else -- asset is now standalone

         -- set the main structs equal to member if asset was
         -- originally standalone

         l_dest_trans_rec           := l_mem_trans_rec;
         l_dest_asset_hdr_rec       := l_mem_asset_hdr_rec;
         l_dest_asset_desc_rec      := l_mem_asset_desc_rec;
         l_dest_asset_type_rec      := l_mem_asset_type_rec;
         l_dest_asset_cat_rec       := l_mem_asset_cat_rec;
         l_dest_asset_fin_rec_old   := l_mem_asset_fin_rec_old;
         l_dest_asset_fin_rec_new   := l_mem_asset_fin_rec_new;
         l_dest_asset_deprn_rec_old := l_mem_asset_deprn_rec_old_tbl(l_sob_index);
         l_dest_asset_deprn_rec_new := l_mem_asset_deprn_rec_new;

         if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'calling FA_GROUP_RECLASS2_PVT.do_adjustment',l_dest_asset_hdr_rec.asset_id,  p_log_level_rec => p_log_level_rec);
         end if;

         --Bug6983091: Replaced l_dest_asset_deprn_rec_new with l_dest_asset_deprn_rec_old
         --            as parameter for p_asset_deprn_rec_old
         if not FA_GROUP_RECLASS2_PVT.do_adjustment
                 (px_trans_rec                 => l_dest_trans_rec,
                  p_asset_hdr_rec              => l_dest_asset_hdr_rec,
                  p_asset_desc_rec             => l_dest_asset_desc_rec,
                  p_asset_type_rec             => l_dest_asset_type_rec,
                  p_asset_cat_rec              => l_dest_asset_cat_rec,
                  p_asset_fin_rec_old          => l_dest_asset_fin_rec_old,
                  p_asset_fin_rec_new          => l_dest_asset_fin_rec_new,
                  p_asset_deprn_rec_old        => l_dest_asset_deprn_rec_old,
                  p_mem_asset_hdr_rec          => l_mem_asset_hdr_rec,
                  p_mem_asset_desc_rec         => l_mem_asset_desc_rec,
                  p_mem_asset_type_rec         => l_mem_asset_type_rec,
                  p_mem_asset_cat_rec          => l_mem_asset_cat_rec,
                  p_mem_asset_fin_rec_new      => l_mem_asset_fin_rec_new,
                  p_mem_asset_deprn_rec_new    => l_mem_asset_deprn_rec_new,
                  px_group_reclass_options_rec => l_group_reclass_options_rec(l_sob_index),
                  p_period_rec                 => l_period_rec,
                  p_mrc_sob_type_code          => l_mrc_sob_type_code,
                  p_src_dest                   => 'DESTINATION'
                         , p_log_level_rec => p_log_level_rec) then
            raise group_rec_err;
         end if;

         if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn,'after FA_GROUP_RECLASS2_PVT.do_adjustment',l_dest_asset_hdr_rec.asset_id,  p_log_level_rec => p_log_level_rec);
         end if;

      end if; -- end of destination
   END LOOP;

   -- process any intercompany effects
   -- R12 conditional logic
   FOR l_sob_index in 0..l_sob_tbl.count LOOP
      if (G_release = 11) then
         if not fa_interco_pvt.do_all_books
                   (p_src_trans_rec          => l_grp_src_trans_rec(l_sob_index),
                    p_src_asset_hdr_rec      => l_grp_src_asset_hdr_rec(l_sob_index),
                    p_dest_trans_rec         => l_grp_dest_trans_rec(l_sob_index),
                    p_dest_asset_hdr_rec     => l_grp_dest_asset_hdr_rec(l_sob_index),
                    p_calling_fn             => l_calling_fn
                   , p_log_level_rec => p_log_level_rec) then raise group_rec_err;
         end if;
      end if;
   END LOOP;

   FOR l_sob_index in 0..l_sob_tbl.count LOOP

      if (l_sob_index = 0) then

         if (l_src_asset_type_rec.asset_type = 'GROUP') then
            update fa_books
            set    adjustment_required_status = 'NONE'
                 , adjusted_cost = l_grp_src_asset_fin_rec_new(l_sob_index).adjusted_cost
                 , rate_adjustment_factor = l_grp_src_asset_fin_rec_new(l_sob_index).rate_adjustment_factor
                 , formula_factor = l_grp_src_asset_fin_rec_new(l_sob_index).formula_factor
                 , salvage_value = l_grp_src_asset_fin_rec_new(l_sob_index).salvage_value
                 , allowed_deprn_limit_amount = l_grp_src_asset_fin_rec_new(l_sob_index).allowed_deprn_limit_amount
                 , recoverable_cost = l_grp_src_asset_fin_rec_new(l_sob_index).recoverable_cost
                 , adjusted_recoverable_cost = l_grp_src_asset_fin_rec_new(l_sob_index).adjusted_recoverable_cost
                 , adjusted_capacity = l_grp_src_asset_fin_rec_new(l_sob_index).adjusted_capacity
                 , reval_amortization_basis = l_grp_src_asset_fin_rec_new(l_sob_index).reval_amortization_basis
                 , eofy_reserve = l_grp_src_asset_fin_rec_new(l_sob_index).eofy_reserve
            where  asset_id = l_src_asset
            and    book_type_code = p_trx_ref_rec.book_type_code
            and    transaction_header_id_out is null;
         else
            update fa_books
            set    adjustment_required_status = 'NONE'
            where  asset_id = l_src_asset
            and    book_type_code = p_trx_ref_rec.book_type_code
            and    transaction_header_id_out is null;
         end if;

         if (l_dest_asset_type_rec.asset_type = 'GROUP') then
            update fa_books
            set    adjustment_required_status = 'NONE'
                 , adjusted_cost = l_grp_dest_asset_fin_rec_new(l_sob_index).adjusted_cost
                 , rate_adjustment_factor = l_grp_dest_asset_fin_rec_new(l_sob_index).rate_adjustment_factor
                 , formula_factor = l_grp_dest_asset_fin_rec_new(l_sob_index).formula_factor
                 , salvage_value = l_grp_dest_asset_fin_rec_new(l_sob_index).salvage_value
                 , allowed_deprn_limit_amount = l_grp_dest_asset_fin_rec_new(l_sob_index).allowed_deprn_limit_amount
                 , recoverable_cost = l_grp_dest_asset_fin_rec_new(l_sob_index).recoverable_cost
                 , adjusted_recoverable_cost = l_grp_dest_asset_fin_rec_new(l_sob_index).adjusted_recoverable_cost
                 , adjusted_capacity = l_grp_dest_asset_fin_rec_new(l_sob_index).adjusted_capacity
                 , reval_amortization_basis = l_grp_dest_asset_fin_rec_new(l_sob_index).reval_amortization_basis
                 , eofy_reserve = l_grp_dest_asset_fin_rec_new(l_sob_index).eofy_reserve
            where  asset_id = l_dest_asset
            and    book_type_code = p_trx_ref_rec.book_type_code
            and    transaction_header_id_out is null;
         else
            update fa_books
            set    adjustment_required_status = 'NONE'
            where  asset_id = l_dest_asset
            and    book_type_code = p_trx_ref_rec.book_type_code
            and    transaction_header_id_out is null;
         end if;

         update fa_trx_references
         set reserve_transfer_amount = l_group_reclass_options_rec(l_sob_index).reserve_amount
           , src_expense_amount = l_group_reclass_options_rec(l_sob_index).source_exp_amount
           , dest_expense_amount = l_group_reclass_options_rec(l_sob_index).destination_exp_amount
         where trx_reference_id =  l_src_trans_rec.trx_reference_id;

      else
         if (l_src_asset_type_rec.asset_type = 'GROUP') then
            update fa_mc_books
            set    adjustment_required_status = 'NONE'
                 , adjusted_cost = l_grp_src_asset_fin_rec_new(l_sob_index).adjusted_cost
                 , rate_adjustment_factor = l_grp_src_asset_fin_rec_new(l_sob_index).rate_adjustment_factor
                 , formula_factor = l_grp_src_asset_fin_rec_new(l_sob_index).formula_factor
                 , salvage_value = l_grp_src_asset_fin_rec_new(l_sob_index).salvage_value
                 , allowed_deprn_limit_amount = l_grp_src_asset_fin_rec_new(l_sob_index).allowed_deprn_limit_amount
                 , recoverable_cost = l_grp_src_asset_fin_rec_new(l_sob_index).recoverable_cost
                 , adjusted_recoverable_cost = l_grp_src_asset_fin_rec_new(l_sob_index).adjusted_recoverable_cost
                 , adjusted_capacity = l_grp_src_asset_fin_rec_new(l_sob_index).adjusted_capacity
                 , reval_amortization_basis = l_grp_src_asset_fin_rec_new(l_sob_index).reval_amortization_basis
                 , eofy_reserve = l_grp_src_asset_fin_rec_new(l_sob_index).eofy_reserve
            where  asset_id = l_src_asset
            and    book_type_code = p_trx_ref_rec.book_type_code
            and    transaction_header_id_out is null
            and    set_of_books_id = l_sob_tbl(l_sob_index);
         else
            update fa_mc_books
            set    adjustment_required_status = 'NONE'
            where  asset_id = l_src_asset
            and    book_type_code = p_trx_ref_rec.book_type_code
            and    transaction_header_id_out is null
            and    set_of_books_id = l_sob_tbl(l_sob_index);
         end if;

         if (l_dest_asset_type_rec.asset_type = 'GROUP') then
            update fa_mc_books
            set    adjustment_required_status = 'NONE'
                 , adjusted_cost = l_grp_dest_asset_fin_rec_new(l_sob_index).adjusted_cost
                 , rate_adjustment_factor = l_grp_dest_asset_fin_rec_new(l_sob_index).rate_adjustment_factor
                 , formula_factor = l_grp_dest_asset_fin_rec_new(l_sob_index).formula_factor
                 , salvage_value = l_grp_dest_asset_fin_rec_new(l_sob_index).salvage_value
                 , allowed_deprn_limit_amount = l_grp_dest_asset_fin_rec_new(l_sob_index).allowed_deprn_limit_amount
                 , recoverable_cost = l_grp_dest_asset_fin_rec_new(l_sob_index).recoverable_cost
                 , adjusted_recoverable_cost = l_grp_dest_asset_fin_rec_new(l_sob_index).adjusted_recoverable_cost
                 , adjusted_capacity = l_grp_dest_asset_fin_rec_new(l_sob_index).adjusted_capacity
                 , reval_amortization_basis = l_grp_dest_asset_fin_rec_new(l_sob_index).reval_amortization_basis
                 , eofy_reserve = l_grp_dest_asset_fin_rec_new(l_sob_index).eofy_reserve
            where  asset_id = l_dest_asset
            and    book_type_code = p_trx_ref_rec.book_type_code
            and    transaction_header_id_out is null
            and    set_of_books_id = l_sob_tbl(l_sob_index);
         else
            update fa_mc_books
            set    adjustment_required_status = 'NONE'
            where  asset_id = l_dest_asset
            and    book_type_code = p_trx_ref_rec.book_type_code
            and    transaction_header_id_out is null
            and    set_of_books_id = l_sob_tbl(l_sob_index);
         end if;
      end if;
   END LOOP;

   --
   -- Source group is the only potential group requires terminal gain loss
   -- calculation.
   --
   FOR l_sob_index in 0..l_sob_tbl.count LOOP
      if (l_sob_index = 0) then
         l_mrc_sob_type_code := 'P';
      else
         l_mrc_sob_type_code := 'R';
      end if;

      if not FA_RETIREMENT_PVT.Check_Terminal_Gain_Loss(
                      p_trans_rec         => l_grp_src_trans_rec(l_sob_index),
                      p_asset_hdr_rec     => l_grp_src_asset_hdr_rec(l_sob_index),
                      p_asset_type_rec    => l_grp_src_asset_type_rec(l_sob_index),
                      p_asset_fin_rec     => l_grp_src_asset_fin_rec_new(l_sob_index),
                      p_period_rec        => l_period_rec,
                      p_mrc_sob_type_code => l_mrc_sob_type_code,
                      p_calling_fn        => l_calling_fn, p_log_level_rec => p_log_level_rec) then
         if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Failed Calling',
                           ' FA_RETIREMENT_PVT.Check_Terminal_Gain_Loss',  p_log_level_rec => p_log_level_rec);
         end if;
         raise group_rec_err;
      end if;
   END LOOP;

   --
   -- Initialize Member Tables
   --
   FA_AMORT_PVT.initMemberTable;

   if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
                        'FA_GROUP_RECLASS2_PVT.do_adjustment END',
                        'RECLASS PROCESSED FOR SOURCE AND DEST',  p_log_level_rec => p_log_level_rec);
   end if;

   return TRUE;

EXCEPTION

   WHEN GROUP_REC_ERR THEN
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error (calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

END do_group_reclass;

END FA_PROCESS_GROUPS_PKG;

/
