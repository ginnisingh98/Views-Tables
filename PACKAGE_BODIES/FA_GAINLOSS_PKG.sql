--------------------------------------------------------
--  DDL for Package Body FA_GAINLOSS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_GAINLOSS_PKG" as
/* $Header: FAGMNB.pls 120.29.12010000.4 2009/11/10 10:23:50 bmaddine ship $   */

g_log_level_rec fa_api_types.log_level_rec_type;
g_release       number  := fa_cache_pkg.fazarel_release;
g_run_mode      varchar2(20) := 'NORMAL';

PROCEDURE Do_Calc_GainLoss (
                p_book_type_code     IN     VARCHAR2,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                p_request_number     IN     NUMBER,
                px_max_retirement_id IN OUT NOCOPY number,
                x_success_count         OUT NOCOPY number,
                x_failure_count         OUT NOCOPY number,
                x_return_status         OUT NOCOPY number) IS

   -- used for bulk fetching
   l_batch_size                 number;
   l_loop_count                 number;

   -- local variables
   l_count                      number;
   l_request_id                 number := -1;
   l_user_id                    number := -1;
   l_login                      number := -1;
   l_book_type_code             varchar2(30);
   l_return_status              number;
   -- local variables
   TYPE num_tbl  IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;
   TYPE v15_tbl  IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER; --Bug# 6937117

   l_retirement_id              num_tbl;
   l_asset_id                   num_tbl;
   l_asset_number               v15_tbl; --Bug# 6937117

   -- variables and structs used for api call
   l_calling_fn                 VARCHAR2(50) := 'fa_gainloss_pkg.do_calc_gainloss';

   ret                          FA_RET_TYPES.ret_struct; -- used in fagpsa

   fail                         number;
   -- bug# 4510549
   -- Bug# 6937117
   cursor c_assets is
       SELECT   /*+ ORDERED index ( RET FA_RETIREMENTS_N3 ) index( FAB FA_BOOKS_N5 ) use_nl ( RET FAB ) */
                 RET.RETIREMENT_ID
                ,RET.ASSET_ID
		,FAA.ASSET_NUMBER
       FROM     FA_RETIREMENTS          RET,
                FA_BOOKS                FAB,
                FA_METHODS              M,
		FA_ADDITIONS_B          FAA
       WHERE    RET.BOOK_TYPE_CODE = p_book_type_code
       AND      RET.STATUS in ('PENDING', 'REINSTATE', 'PARTIAL')
       AND      M.METHOD_CODE(+) =      RET.STL_METHOD_CODE
       AND      M.LIFE_IN_MONTHS(+) =   RET.STL_LIFE_IN_MONTHS
       AND      FAB.RETIREMENT_ID=      RET.RETIREMENT_ID
       AND      FAB.BOOK_TYPE_CODE=     RET.BOOK_TYPE_CODE
       AND      FAB.ASSET_ID=           RET.ASSET_ID
       AND      RET.RETIREMENT_ID > px_max_retirement_id
       AND      MOD(nvl(FAB.GROUP_ASSET_ID,RET.RETIREMENT_ID), p_total_requests) = (p_request_number - 1)
       AND      FAA.ASSET_ID = FAB.ASSET_ID
       ORDER BY RET.RETIREMENT_ID;

   done_exc      EXCEPTION;
   gainloss_err  EXCEPTION;
   ret_err       EXCEPTION;

BEGIN

   px_max_retirement_id := nvl(px_max_retirement_id, 0);
   x_success_count := 0;
   x_failure_count := 0;

   if p_parent_request_id = -4882887 then
      g_run_mode := 'UPGRADE';
   end if;

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise gainloss_err;
      end if;
   end if;

   if g_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => '+++ Do_Calc_GainLoss: Step 1',
               value   => '', p_log_level_rec => g_log_level_rec);
   end if;

   -- call the book controls cache
   if not fa_cache_pkg.fazcbc(X_book => p_book_type_code, p_log_level_rec => g_log_level_rec) then
      raise gainloss_err;
   end if;

   l_batch_size := nvl(fa_cache_pkg.fa_batch_size, 200);

   if g_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => '+++ Do_Calc_GainLoss: Step 2',
               value   => '', p_log_level_rec => g_log_level_rec);
   end if;

   if (TRUE) then

      OPEN c_assets;

      FETCH c_assets BULK COLLECT INTO
            l_retirement_id,
            l_asset_id,
	    l_asset_number  -- Bug# 6937117
            LIMIT l_batch_size;

      CLOSE c_assets;

      if l_retirement_id.count = 0 then
         raise done_exc;
      end if;

      for l_loop_count in 1..l_retirement_id.count loop

         -- clear the debug stack for each asset
         FA_DEBUG_PKG.Initialize;
         -- reset the message level to prevent bogus errors
         FA_SRVR_MSG.Set_Message_Level(message_level => 10, p_log_level_rec => g_log_level_rec);

         BEGIN
            FA_GAINLOSS_PKG.Do_Calc_GainLoss_Asset
              (p_retirement_id => l_retirement_id(l_loop_count),
               x_return_status => l_return_status,
               p_log_level_rec => g_log_level_rec
              );

            if (l_return_status <> 0) then
               raise gainloss_err;
            end if;

            x_success_count := x_success_count + 1;

	   --fix for bug no.3883501.success count is displayed incorrectly after 3087644
           --x_success_count := x_success_count + 1;

	   --bug 3087644 fix starts
            fa_srvr_msg.add_message(
                calling_fn => NULL,
                  name       =>'FA_RET_STATUS_SUCCEED',
                  token1     => 'RETID',
                  value1     => l_retirement_id(l_loop_count),
                  token2     => 'ASSET',
                  value2     => l_asset_number(l_loop_count),
                   p_log_level_rec => g_log_level_rec);

            fa_srvr_msg.add_message(
                calling_fn => NULL,
                  name       => 'FA_ASSET_ID',
                  token1     => 'ASSET_ID',
                  value1     => l_asset_id(l_loop_count),
                   p_log_level_rec => g_log_level_rec);
--bug 3087644 fix ends.
            if (g_log_level_rec.statement_level) then
                  fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
            end if;

         EXCEPTION
            when gainloss_err then
               FND_CONCURRENT.AF_ROLLBACK;
               if (g_log_level_rec.statement_level) then
                  fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
               end if;
               x_failure_count := x_failure_count + 1;
            --for bug no.3883501.modified the message name to FA_RET_STATUS_FAIL
            fa_srvr_msg.add_message(
                calling_fn => NULL,
                  name       =>'FA_RET_STATUS_FAIL',
                  token1     => 'RETID',
                  value1     => l_retirement_id(l_loop_count),
                  token2     => 'ASSET',
                  value2     => l_asset_number(l_loop_count),
                   p_log_level_rec => g_log_level_rec); --Bug# 6937117

            fa_srvr_msg.add_message(
                calling_fn => NULL,
                  name       => 'FA_ASSET_ID',
                  token1     => 'ASSET_ID',
                  value1     => l_asset_id(l_loop_count),
                   p_log_level_rec => g_log_level_rec);

            when others then
               FND_CONCURRENT.AF_ROLLBACK;
               if (g_log_level_rec.statement_level) then
                  fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
               end if;
               x_failure_count := x_failure_count + 1;
            --for bug no. 3883501.modifying the value2 to display the asset number
               fa_srvr_msg.add_message(
                  calling_fn => l_calling_fn,
                  name       => 'FA_RET_STATUS_FAIL',
                  token1     => 'RETID',
                  value1     => l_retirement_id(l_loop_count),
                  token2     => 'ASSET',
                  value2     => l_asset_number(l_loop_count),
                   p_log_level_rec => g_log_level_rec); -- Bug# 6937117

         END;

         -- FND_CONCURRENT.AF_COMMIT each record
         FND_CONCURRENT.AF_COMMIT;

      end loop;  -- main bulk fetch loop

      px_max_retirement_id := l_retirement_id(l_retirement_id.count);

   end if;

   x_return_status :=  0;

EXCEPTION
   when done_exc then
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;

      x_return_status :=  0;

   when gainloss_err then
      FND_CONCURRENT.AF_ROLLBACK;
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      if (g_log_level_rec.statement_level) then
         FA_DEBUG_PKG.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;
      x_return_status :=  2;

   when others then
      FND_CONCURRENT.AF_ROLLBACK;
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;

      x_return_status :=  2;

END Do_Calc_GainLoss;


PROCEDURE Do_Calc_GainLoss_Asset(
             p_retirement_id      in         NUMBER,
             x_return_status      out NOCOPY NUMBER,
             p_log_level_rec       IN     fa_api_types.log_level_rec_type
default null) IS

   l_count                 number := 0;
   l_user_id               number;
   l_sysdate               date;

   -- Local record types
   l_sob_tbl               FA_CACHE_PKG.fazcrsob_sob_tbl_type;
   l_asset_hdr_rec         FA_API_TYPES.asset_hdr_rec_type;
   l_trans_rec             FA_API_TYPES.trans_rec_type;
   l_asset_desc_rec        FA_API_TYPES.asset_desc_rec_type;
   l_asset_type_rec        FA_API_TYPES.asset_type_rec_type;
   l_asset_retire_rec      FA_API_TYPES.asset_retire_rec_type;
   lv_asset_retire_rec     FA_API_TYPES.asset_retire_rec_type;
   l_period_rec            FA_API_TYPES.period_rec_type;

   l_trx_type_code         varchar2(30);

   -- added for R12
   l_primary_sob_id        NUMBER;
   l_thid                  NUMBER;
   l_trx_date_entered      DATE;
   l_event_type_code       VARCHAR2(30);
   l_asset_type            VARCHAR2(15);
   l_event_id              NUMBER;

   --- Variable for retirement struct
   ret                     FA_RET_TYPES.ret_struct;

   gainloss_err            EXCEPTION;

   l_calling_fn            varchar2(50) := 'FA_GAINLOSS_PKG.do_calc_gainloss_asset';
   l_temp_calling_fn       varchar2(50);

BEGIN

   savepoint Do_Calc_GainLoss_Asset;

   l_asset_retire_rec.retirement_id := p_retirement_id;

   l_user_id := FND_GLOBAL.USER_ID;

   l_sysdate := SYSDATE;

   if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => '+++ Step 1 +++',
               value   => '', p_log_level_rec => p_log_level_rec);
   end if;

   -- pop asset_retire_rec to get the rowid of retirement
   if not FA_UTIL_PVT.get_asset_retire_rec
          (px_asset_retire_rec => l_asset_retire_rec,
           p_mrc_sob_type_code => 'P',
           p_set_of_books_id => null
          , p_log_level_rec => p_log_level_rec) then
              raise gainloss_err;
   end if;

   l_asset_hdr_rec.asset_id       := l_asset_retire_rec.detail_info.asset_id;
   l_asset_hdr_rec.book_type_code := l_asset_retire_rec.detail_info.book_type_code;

   if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => '+++ Step 2 +++',
               value   => '', p_log_level_rec => p_log_level_rec);
   end if;

   if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'l_asset_hdr_rec.asset_id',
               value   => l_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
   end if;

   if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'l_asset_hdr_rec.book_type_code',
               value   => l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
   end if;

   -- call the book controls cache
   if not fa_cache_pkg.fazcbc(X_book => l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec) then
      raise gainloss_err;
   end if;

   -- CHECK: Would asset_number be really necessary for processing fagpsa ?
   -- pop asset_desc_rec to get asset_number
   if not FA_UTIL_PVT.get_asset_desc_rec
          (p_asset_hdr_rec      => l_asset_hdr_rec
          ,px_asset_desc_rec    => l_asset_desc_rec
          , p_log_level_rec => p_log_level_rec) then
              raise gainloss_err;
   end if;

   -- pop current period_rec info
   if not FA_UTIL_PVT.get_period_rec
          (p_book           => l_asset_hdr_rec.book_type_code
          ,p_effective_date => NULL
          ,x_period_rec     => l_period_rec
          , p_log_level_rec => p_log_level_rec) then
              raise gainloss_err;
   end if;

   if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'current_period: l_period_rec.period_name',
               value   => l_period_rec.period_name, p_log_level_rec => p_log_level_rec);
   end if;

   /***********
   * Validation
   ************/
   /*
   Fix for Bug 1346402. Since trx approval allows gain loss to
   be run although deprn_status is E, need to check if asset
   has already depreciated in the current period. If so
   do not process retirement or reinstatement - snarayan
   */
   l_count := 0;
   begin
     select  count(*)
     into    l_count
     from    fa_deprn_summary
     where   book_type_code = l_asset_hdr_rec.book_type_code
       and   asset_id = l_asset_hdr_rec.asset_id
       and   period_counter = l_period_rec.period_counter;

   exception
     /* continue if no current period DS rows */
     when others then
        null;
   end;

   if (l_count <> 0) then
         fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
   end if;

   if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'Passed basic validation',
               value   => '', p_log_level_rec => p_log_level_rec);
   end if;


   /***********************
   * Process Primary Book
   ************************/
   if l_asset_retire_rec.status in ('PENDING', 'REINSTATE') then

      ret.mrc_sob_type_code := 'P'; -- Primary
      ret.status := l_asset_retire_rec.status;
      ret.retirement_id := l_asset_retire_rec.retirement_id;
      ret.asset_id := l_asset_retire_rec.detail_info.asset_id;
      ret.book := l_asset_retire_rec.detail_info.book_type_code;

      /*
        New Fix for Bug 2937365, 3033462:
          The original solution provided through the fix on Bug 2937365
          caused a problem described in Bug 3033462.
          For full retirement transactions,
          instead of nulling out units_retired column of
          fa_retirements table directly as a solution,
          we will null out ret.units_retired variable
          to make sure that retirement routines process full retirement transactions
          correctly.
          (Null value of ret.units_retired is considered full retirement inside the code)
      */
      begin

        select  transaction_type_code
        into    l_trx_type_code
        from    fa_transaction_headers
        where   transaction_header_id=
          (select transaction_header_id_in
           from fa_retirements
           where retirement_id=p_retirement_id);

      exception
       when others then
          null;
      end;

      if (l_asset_retire_rec.status = 'PENDING' and l_trx_type_code='FULL RETIREMENT') then
        ret.units_retired := null;
      else
        ret.units_retired := l_asset_retire_rec.units_retired;
      end if;

      ret.stl_life := l_asset_retire_rec.detail_info.stl_life_in_months;
      ret.itc_recapid := nvl(l_asset_retire_rec.detail_info.itc_recapture_id,0);
      ret.asset_number := l_asset_desc_rec.asset_number;
      ret.date_retired := l_asset_retire_rec.date_retired;
      ret.cost_retired := l_asset_retire_rec.cost_retired;
      ret.proceeds_of_sale := l_asset_retire_rec.proceeds_of_sale;
      ret.cost_of_removal := l_asset_retire_rec.cost_of_removal;
      ret.retirement_type_code := l_asset_retire_rec.retirement_type_code;

      ret.th_id_in := l_asset_retire_rec.detail_info.transaction_header_id_in;
      ret.stl_method_code := l_asset_retire_rec.detail_info.stl_method_code;

      -- ++++++ Added for Group Asset +++++
      ret.recognize_gain_loss    := l_asset_retire_rec.recognize_gain_loss;
      ret.recapture_reserve_flag := l_asset_retire_rec.recapture_reserve_flag;
      ret.limit_proceeds_flag    := l_asset_retire_rec.limit_proceeds_flag;
      ret.terminal_gain_loss     := l_asset_retire_rec.terminal_gain_loss;
      ret.reduction_rate         := l_asset_retire_rec.reduction_rate;
      ret.eofy_reserve           := l_asset_retire_rec.eofy_reserve;
      ret.recapture_amount       := l_asset_retire_rec.detail_info.recapture_amount;
      ret.reserve_retired        := l_asset_retire_rec.reserve_retired;

      -- UPGRADE: refer to bug#2363878
      -- Replace the following sql with a new component of retire struct
      -- ret.date_effective := l_asset_retire_rec.detail_info.date_effective;
      select date_effective
        into ret.date_effective
      from fa_retirements
      where retirement_id = l_asset_retire_rec.retirement_id;

      ret.prorate_convention := l_asset_retire_rec.retirement_prorate_convention;

      -- from primary book
      if fa_cache_pkg.fazcbc_record.deprn_allocation_code = 'E' then
           ret.dpr_evenly := 1;
      else
           ret.dpr_evenly := 0;
      end if;

      if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'l_asset_retire_rec.cost_retired',
               value   => l_asset_retire_rec.cost_retired, p_log_level_rec => p_log_level_rec);
      end if;

      ret.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

      -- Call fagpsa to process a retirement
      if not FA_GAINLOSS_PRO_PKG.fagpsa
             (ret,
              l_sysdate,
              l_period_rec.period_name,
              l_period_rec.period_counter,
              l_user_id, p_log_level_rec => p_log_level_rec) then
                           raise gainloss_err;
      else
         /*
          * Code hook for IAC
          * Call IAC hook if IAC is enabled.
          */
         if (FA_IGI_EXT_PKG.IAC_Enabled  and
             G_release = 11)then

            if not FA_IGI_EXT_PKG.Do_Gain_Loss(
                         p_retirement_id    => ret.retirement_id,
                         p_asset_id         => ret.asset_id,
                         p_book_type_code   => ret.book,
                         p_event_id         => l_trans_rec.event_id,
                         p_calling_function => l_calling_fn) then

                   fa_srvr_msg.add_message(
                      calling_fn => 'l_calling_fn'||'(Calling IAC)',
                      name       => 'FA_RET_STATUS_FAIL',
                      token1     => 'RETID',
                      value1     => ret.retirement_id,
                      token2     => 'ASSET',
                      value2     => ret.asset_number ,
                   p_log_level_rec => p_log_level_rec);
                   raise gainloss_err;
            end if;

         end if; -- IAC hook

	 if cse_fa_integration_grp.is_oat_enabled then
            if l_asset_retire_rec.status = 'PENDING' then
               if not cse_fa_integration_grp.retire(
                    p_asset_id         => ret.asset_id,
                    p_book_type_code   => ret.book,
                    p_retirement_id    => ret.retirement_id,
                    p_retirement_date  => l_asset_retire_rec.date_retired,
                    p_retirement_units => l_asset_retire_rec.units_retired) then
                  raise gainloss_err;
               end if;
            elsif l_asset_retire_rec.status = 'REINSTATE' then
               if not cse_fa_integration_grp.reinstate(
                    p_asset_id         => ret.asset_id,
                    p_book_type_code   => ret.book,
                    p_retirement_id    => ret.retirement_id,
                    p_reinstatement_date  => l_asset_retire_rec.date_retired,
                    p_reinstatement_units => l_asset_retire_rec.units_retired) then
                 raise gainloss_err;
               end if;
            end if;
         end if;

      end if; -- fagpsa

      -- code fix for bug no.3641602.Call the book controls cache again
      if not fa_cache_pkg.fazcbc(X_book => l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec) then
         raise gainloss_err;
      end if;

      -- SLA: store the ledger id for future use
      l_primary_sob_id := fa_cache_pkg.fazcbc_record.set_of_books_id;


      /*******************************
      * MRC LOOP for Reporting books
      ********************************/
      -- if this is a primary book, process reporting books(sobs)
      if fa_cache_pkg.fazcbc_record.mc_source_flag = 'Y' then

          -- call the sob cache to get the table of sob_ids
          if not FA_CACHE_PKG.fazcrsob
                 (x_book_type_code => l_asset_hdr_rec.book_type_code,
                  x_sob_tbl        => l_sob_tbl, p_log_level_rec => p_log_level_rec) then
             raise gainloss_err;
          end if;

          -- loop through each book starting with the primary and
          -- call sub routine for each
          for l_sob_index in 1..l_sob_tbl.count loop

            if p_log_level_rec.statement_level then
                 fa_debug_pkg.add
                 (fname   => l_calling_fn,
                  element => '+++ Step 2: in Reporting book loop: Set_of_books_id',
                  value   => l_sob_tbl(l_sob_index));
            end if;

            if not fa_cache_pkg.fazcbcs(x_book => l_asset_hdr_rec.book_type_code,
                                        x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                                        p_log_level_rec => p_log_level_rec) then
                     raise gainloss_err;
            end if;

            lv_asset_retire_rec.retirement_id := p_retirement_id;

            -- pop asset_retire_rec to get the rowid of retirement
            if not FA_UTIL_PVT.get_asset_retire_rec
                  (px_asset_retire_rec => lv_asset_retire_rec,
                   p_mrc_sob_type_code => 'R',
                   p_set_of_books_id => l_sob_tbl(l_sob_index)
                   , p_log_level_rec => p_log_level_rec) then
                       raise gainloss_err;
            end if;

            -- set up the local asset_header and sob_id
            -- lv_asset_hdr_rec    := l_asset_hdr_rec;
            -- lv_asset_hdr_rec.set_of_books_id := l_sob_tbl(l_sob_index);

            if lv_asset_retire_rec.status in ('PENDING', 'REINSTATE') then

               ret.mrc_sob_type_code := 'R'; -- Reporting
               ret.set_of_books_id := l_sob_tbl(l_sob_index);
               ret.status := lv_asset_retire_rec.status;
               ret.retirement_id := lv_asset_retire_rec.retirement_id;
               ret.asset_id := lv_asset_retire_rec.detail_info.asset_id;
               ret.book := lv_asset_retire_rec.detail_info.book_type_code;
               --fix for bug# 5086360
	       if (lv_asset_retire_rec.status = 'PENDING' and l_trx_type_code='FULL RETIREMENT') then
	           ret.units_retired := null;
	       else
	           ret.units_retired := lv_asset_retire_rec.units_retired;
               end if;
	       --ret.units_retired := lv_asset_retire_rec.units_retired; --bug# 5086360
               ret.stl_life := lv_asset_retire_rec.detail_info.stl_life_in_months;
               ret.itc_recapid := nvl(lv_asset_retire_rec.detail_info.itc_recapture_id,0);
               -- asset_number should be the same as that for the primary book
               ret.asset_number := l_asset_desc_rec.asset_number;
               ret.date_retired := lv_asset_retire_rec.date_retired;
               ret.cost_retired := lv_asset_retire_rec.cost_retired;
               ret.reserve_retired := lv_asset_retire_rec.reserve_retired; --Bug 9103418
               ret.proceeds_of_sale := lv_asset_retire_rec.proceeds_of_sale;
               ret.cost_of_removal := lv_asset_retire_rec.cost_of_removal;
               ret.retirement_type_code := lv_asset_retire_rec.retirement_type_code;

               ret.th_id_in := lv_asset_retire_rec.detail_info.transaction_header_id_in;
               ret.stl_method_code := lv_asset_retire_rec.detail_info.stl_method_code;

               -- UPGRADE: refer to bug#2363878
               -- Replace the following sql with a new component of retire struct
               -- ret.date_effective := lv_asset_retire_rec.detail_info.date_effective;
               select date_effective
                 into ret.date_effective
               from fa_mc_retirements
               where retirement_id = lv_asset_retire_rec.retirement_id
                 and  set_of_books_id = l_sob_tbl(l_sob_index);

               ret.prorate_convention := lv_asset_retire_rec.retirement_prorate_convention;
               -- from reporting book
               if fa_cache_pkg.fazcbcs_record.deprn_allocation_code = 'E' then
                    ret.dpr_evenly := 1;
               else
                    ret.dpr_evenly := 0;
               end if;

               if p_log_level_rec.statement_level then
                 fa_debug_pkg.add
                 (fname   => l_calling_fn,
                  element => 'lv_asset_retire_rec.cost_retired',
                  value   => lv_asset_retire_rec.cost_retired, p_log_level_rec => p_log_level_rec);
               end if;


               -- Call fagpsa to process a retirement
               if not FA_GAINLOSS_PRO_PKG.fagpsa
                        (ret,
                         l_sysdate,
                         l_period_rec.period_name,
                         l_period_rec.period_counter,
                         l_user_id, p_log_level_rec => p_log_level_rec) then
                                      raise gainloss_err;
               end if;


            end if; -- if trx in reporting is either retirement or reinstatement

          end loop; -- loop through reporting books

         --for bug no.3831503
         if not fa_cache_pkg.fazcbc(X_book => l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec) then
           raise gainloss_err;
         end if;
      end if; -- if this is a primary book

      if (g_run_mode <> 'UPGRADE' and
          G_release <> 11)  then

         if p_log_level_rec.statement_level then
            fa_debug_pkg.add
               (fname   => l_calling_fn,
                element => 'getting asset type for asset ',
                value   => l_asset_hdr_rec.asset_id,
                p_log_level_rec => p_log_level_rec);
         end if;

         select asset_type
           into l_asset_type
           from fa_additions_b
          where asset_id = l_asset_hdr_rec.asset_id;

         if p_log_level_rec.statement_level then
            fa_debug_pkg.add
               (fname   => l_calling_fn,
                element => 'setting up parameters for event update, ret_status',
                value   => l_asset_retire_rec.status,
                p_log_level_rec => p_log_level_rec);
         end if;

         if (l_asset_retire_rec.status = 'PENDING') then
            l_thid            := l_asset_retire_rec.detail_info.transaction_header_id_in;
            l_event_type_code := 'RETIREMENTS';
         else
            select transaction_header_id_out
              into l_thid
              from fa_retirements
             where retirement_id = l_asset_retire_rec.retirement_id;

            l_event_type_code := 'REINSTATEMENTS';
         end if;

         if (l_asset_type = 'CIP') then
            l_event_type_code := 'CIP_' || l_event_type_code;
         end if;

         select event_id,
                transaction_date_entered
           into l_event_id,
                L_trx_date_entered
           from fa_transaction_headers
          where transaction_header_id = l_thid;


         if (l_event_id is null) then

            l_asset_type_rec.asset_type          := l_asset_type;
            l_trans_rec.transaction_header_id    := l_thid;
            l_trans_rec.transaction_date_entered := l_trx_date_entered;

            if (l_asset_retire_rec.status = 'PENDING') then
               l_temp_calling_fn := 'FA_RETIREMENT_PUB.do_all_books_retirement';
            else
               l_temp_calling_fn := 'FA_RETIREMENT_PUB.do_sub_regular_reinstatement';
            end if;

            if not fa_xla_events_pvt.create_transaction_event
               (p_asset_hdr_rec => l_asset_hdr_rec,
                p_asset_type_rec=> l_asset_type_rec,
                px_trans_rec    => l_trans_rec,
                p_event_status  => FA_XLA_EVENTS_PVT.C_EVENT_UNPROCESSED,
                p_calling_fn    => l_temp_calling_fn
                ,p_log_level_rec => p_log_level_rec) then
                raise gainloss_err;
            end if;

            update fa_transaction_headers
               set event_id = l_trans_rec.event_id
             where transaction_header_id = l_thid;

         else

            if p_log_level_rec.statement_level then
               fa_debug_pkg.add
               (fname   => l_calling_fn,
                element => 'calling fa_xla_events_pvt.update_transaction_event with thid: ',
                value   => l_thid);
            end if;

            -- Bug 7292561: Changed the Event_date to match the event_date used
            -- in create_transaction_event
            if not fa_xla_events_pvt.update_transaction_event
                  (p_ledger_id              => l_primary_sob_id,
                   p_transaction_header_id  => l_thid,
                   p_book_type_code         => l_asset_hdr_rec.book_type_code,
                   p_event_type_code        => l_event_type_code,
                   p_event_date             => greatest(l_trx_date_entered,
                                                          l_period_rec.calendar_period_open_date),
                   p_event_status_code      => FA_XLA_EVENTS_PVT.C_EVENT_UNPROCESSED,
                   p_calling_fn             => l_calling_fn,
                   p_log_level_rec => p_log_level_rec) then
               raise gainloss_err;
            end if;

            --Bug6391045
            --Assigning event_id to l_trans_rec so that it can be passed to the IAC hook
	    l_trans_rec.event_id := l_event_id;


         end if; -- null event


         --Bug6391045
         if (FA_IGI_EXT_PKG.IAC_Enabled  and
            G_release <> 11) then

            if not FA_IGI_EXT_PKG.Do_Gain_Loss(
				 p_retirement_id    => ret.retirement_id,
				 p_asset_id         => ret.asset_id,
				 p_book_type_code   => ret.book,
				 p_event_id         => l_trans_rec.event_id,
				 p_calling_function => l_calling_fn) then

			   fa_srvr_msg.add_message(
			      calling_fn => 'l_calling_fn'||'(Calling IAC)',
			      name       => 'FA_RET_STATUS_FAIL',
			      token1     => 'RETID',
			      value1     => ret.retirement_id,
			      token2     => 'ASSET',
			      value2     => ret.asset_number );
			   raise gainloss_err;
            end if;

         end if; -- IAC hook

      end if;  -- upgrade

   end if; -- if trx in primary is either retirement or reinstatement


   if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'Process status for retirement_id:'||p_retirement_id,
               value   => 'Success', p_log_level_rec => p_log_level_rec);
   end if;

   x_return_status :=  0;

EXCEPTION

   when gainloss_err then
      ROLLBACK to Do_Calc_GainLoss_Asset;
      if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'RETIREMENT_ID',
               value   => p_retirement_id, p_log_level_rec => p_log_level_rec);
      end if;
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      if (g_log_level_rec.statement_level) then
         FA_DEBUG_PKG.dump_debug_messages(max_mesgs => 0, p_log_level_rec => p_log_level_rec);
      end if;
      x_return_status :=  2;

   when others then
      ROLLBACK to Do_Calc_GainLoss_Asset;
      if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'RETIREMENT_ID',
               value   => p_retirement_id, p_log_level_rec => p_log_level_rec);
      end if;
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      x_return_status :=  2;

END Do_Calc_GainLoss_Asset;

END FA_GAINLOSS_PKG;

/
