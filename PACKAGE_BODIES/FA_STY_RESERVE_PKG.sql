--------------------------------------------------------
--  DDL for Package Body FA_STY_RESERVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_STY_RESERVE_PKG" as
/* $Header: faxstupb.pls 120.3.12010000.2 2009/07/19 13:05:43 glchen ship $   */

g_log_level_rec fa_api_types.log_level_rec_type;

PROCEDURE faxstur(
		errbuf		 OUT NOCOPY VARCHAR2,
		retcode		 OUT NOCOPY NUMBER,
		p_book_type_code	IN	VARCHAR2) IS

   l_asset_id		NUMBER;
   l_count		NUMBER := 0;
   l_rsv		NUMBER;
   l_ytd_deprn  	NUMBER;
   l_pc			NUMBER;
   l_deprn_basis_rule   VARCHAR2(4);
   l_status		BOOLEAN;
   p_msg_count     	NUMBER := 0;
   p_msg_data      	VARCHAR2(512);
   l_rec_cost		NUMBER;
   l_old_dpis		DATE;
   l_new_dpis		DATE;
   l_update_dpis	VARCHAR2(1);
   l_prorate_date	DATE;
   l_old_conv_code	VARCHAR2(10);
   l_new_conv_code	VARCHAR2(10);
   l_old_method_code	VARCHAR2(12);
   l_new_method_code	VARCHAR2(12);
   l_old_life_in_months	NUMBER;
   l_new_life_in_months NUMBER;
   l_orig_deprn_start_date DATE;
   l_request_id		NUMBER;
   l_trx_approval	BOOLEAN;
   l_rowid		rowid;

   faxstur_err		EXCEPTION;
   prorate_date_err	EXCEPTION;

   CURSOR assets IS
	SELECT 	ad.asset_id,
		st.deprn_reserve,
		nvl(st.ytd_deprn,0),
		dp.period_counter - 1,
		mt.deprn_basis_rule,
		bk.recoverable_cost,
		bk.date_placed_in_service,
		st.date_placed_in_service,
		bk.prorate_convention_code,
		st.prorate_convention_code,
		bk.deprn_method_code,
		st.deprn_method_code,
		bk.life_in_months,
		st.life_in_months,
		nvl(st.original_deprn_start_date, bk.original_deprn_start_date),
		bk.rowid
	FROM
		fa_books bk,
		fa_methods mt,
		fa_deprn_periods dp,
		fa_book_controls bc,
		fa_transaction_headers th,
		fa_short_tax_reserves st,
		fa_additions ad
	WHERE
		ad.asset_number = st.asset_number
	AND	ad.asset_id = th.asset_id
	AND	bc.book_type_code = p_book_type_code
	AND	bk.book_type_code = bc.book_type_code
	AND     st.tax_book = bk.book_type_code
	AND     bk.short_fiscal_year_flag = 'YES'
	AND	bk.conversion_date is not null
	AND     th.book_type_code = p_book_type_code
	AND     th.asset_id = bk.asset_id
	AND 	th.date_effective between dp.period_open_date and
				nvl(dp.period_close_date, sysdate)
	AND 	th.transaction_type_code = 'ADDITION'
	AND	th.transaction_header_id = bk.transaction_header_id_in
	AND 	bk.date_ineffective is null
	AND	dp.period_close_date is null
	AND     dp.book_type_code = th.book_type_code
	AND	bk.deprn_method_code = mt.method_code
	AND	bk.life_in_months = mt.life_in_months;

   CURSOR get_prorate_date IS
        SELECT   CONV.PRORATE_DATE
        FROM
		 FA_FISCAL_YEAR 	 FY,
		 FA_DEPRN_PERIODS	 DP,
                 FA_CALENDAR_PERIODS     CP,
                 FA_BOOK_CONTROLS        BC,
                 FA_CONVENTIONS          CONV
	WHERE
		 BC.BOOK_TYPE_CODE	       = p_book_type_code
        AND      CONV.PRORATE_CONVENTION_CODE    = l_new_conv_code
        AND      l_new_dpis  >= CONV.START_DATE
        AND      l_new_dpis <= CONV.END_DATE
        AND      CP.CALENDAR_TYPE                = BC.PRORATE_CALENDAR
        AND      CONV.PRORATE_DATE               >= CP.START_DATE
        AND      CONV.PRORATE_DATE               <= CP.END_DATE
	AND      FY.FISCAL_YEAR_NAME = BC.FISCAL_YEAR_NAME
	AND      FY.FISCAL_YEAR = BC.CURRENT_FISCAL_YEAR
	AND      CONV.PRORATE_DATE <= FY.END_DATE
	AND	 DP.BOOK_TYPE_CODE = p_book_type_code
	AND 	 DP.PERIOD_CLOSE_DATE is NULL
	AND      l_new_dpis <= DP.CALENDAR_PERIOD_CLOSE_DATE;

   CURSOR check_method IS
	SELECT 	DEPRN_BASIS_RULE
	FROM	FA_METHODS
	WHERE 	method_code = nvl(l_new_method_code,
				  l_old_method_code)
	AND	life_in_months = nvl(l_new_life_in_months,
				     l_old_life_in_months);

BEGIN

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise faxstur_err;
      end if;
   end if;

   -- Initialize server message stack
   FA_SRVR_MSG.Init_Server_Message;
   FA_DEBUG_PKG.Initialize;

   /*=========================================================================
      Get transaction approval and lock the book.
   ==========================================================================*/
    l_request_id := fnd_global.conc_request_id;
    IF NOT FA_BEGIN_MASS_TRX_PKG.faxbmt(
                        X_book          => p_book_type_code,
                        X_request_id    => l_request_id,
                        X_result        => l_trx_approval, p_log_level_rec => g_log_level_rec) THEN
        RAISE faxstur_err;
    END IF;

    IF NOT l_trx_approval THEN
    -- Transaction was not approved.
       fa_srvr_msg.add_message(
               calling_fn => 'fa_deprn_rollback_pkg.do_rollback',
               name       => 'FA_TRXAPP_LOCK_FAILED',
               token1     => 'BOOK',
               value1     => p_book_type_code,  p_log_level_rec => g_log_level_rec);
        RAISE faxstur_err ;
    END IF;

    -- Commit the change made to fa_book_controls table to lock the book.
    FND_CONCURRENT.AF_COMMIT;

   OPEN assets;
   LOOP
      FETCH assets INTO l_asset_id,
			l_rsv,
			l_ytd_deprn,
			l_pc,
			l_deprn_basis_rule,
			l_rec_cost,
			l_old_dpis,
			l_new_dpis,
			l_old_conv_code,
			l_new_conv_code,
			l_old_method_code,
			l_new_method_code,
			l_old_life_in_months,
			l_new_life_in_months,
			l_orig_deprn_start_date,
			l_rowid;

      IF (assets%NOTFOUND) THEN
	 EXIT;
      END IF;

      if (g_log_level_rec.statement_level) then
              fa_debug_pkg.add('faxstur','Processing asset_id: ',
                                l_asset_id, p_log_level_rec => g_log_level_rec);
	      fa_debug_pkg.add('faxstur','Old Date Placed In Service:',
				l_old_dpis, p_log_level_rec => g_log_level_rec);
              fa_debug_pkg.add('faxstur','New Date Placed In Service: ',
                                l_new_dpis, p_log_level_rec => g_log_level_rec);
              fa_debug_pkg.add('faxstur','Old Prorate Convention: ',
                                l_old_conv_code, p_log_level_rec => g_log_level_rec);
              fa_debug_pkg.add('faxstur','New Prorate Convention: ',
                                l_new_conv_code, p_log_level_rec => g_log_level_rec);
              fa_debug_pkg.add('faxstur','Old life_in_months: ',
                                l_old_life_in_months, p_log_level_rec => g_log_level_rec);
              fa_debug_pkg.add('faxstur','New life_in_months: ',
                                l_new_life_in_months, p_log_level_rec => g_log_level_rec);
              fa_debug_pkg.add('faxstur','l_orig_deprn_start_date: ',
                                l_orig_deprn_start_date, p_log_level_rec => g_log_level_rec);
      end if;

      l_update_dpis := 'N';
      if ((l_new_dpis is not null and
		(l_new_dpis <> l_old_dpis)) OR
	 (l_new_conv_code is not null and
		(l_new_conv_code <> l_old_conv_code))) then
	l_update_dpis := 'Y';
	open get_prorate_date;
        fetch get_prorate_date into l_prorate_date;
	if (get_prorate_date%NOTFOUND) then
           fa_srvr_msg.add_message(
                        calling_fn => 'fa_sty_reserve_pkg.faxstur',
                        name       => 'FA_MASSCHG_PRORATE_DATE',  p_log_level_rec => g_log_level_rec);
	   raise faxstur_err;
	end if;
	close get_prorate_date;
      end if;

      if ((l_new_method_code is not null and
		(l_new_method_code <> l_old_method_code)) OR
	 (l_new_life_in_months is not null and
		(l_new_life_in_months <> l_old_life_in_months))) then
	  open check_method;
	  fetch check_method into l_deprn_basis_rule;
	  if (check_method%NOTFOUND) then
             fa_srvr_msg.add_message(
                        calling_fn => 'fa_sty_reserve_pkg.faxstur',
                        name       => 'FA_CACHE_GET_METHOD_INFO',  p_log_level_rec => g_log_level_rec);
	     raise faxstur_err;
	  end if;
	  close check_method;
      end if;


      UPDATE 	fa_books
      SET 	annual_deprn_rounding_flag = 'RES',
		adjusted_cost = decode(l_deprn_basis_rule,
			  'NBV', recoverable_cost - (l_rsv - l_ytd_deprn),
			  recoverable_cost),
		date_placed_in_service = decode(l_update_dpis,
						'Y', l_new_dpis,
						date_placed_in_service),
		prorate_date = decode(l_update_dpis,
				      'Y', l_prorate_date,
				      prorate_date),
		prorate_convention_code = nvl(l_new_conv_code, l_old_conv_code),
		original_deprn_start_date = l_orig_deprn_start_date,
		deprn_method_code = nvl(l_new_method_code, l_old_method_code),
		life_in_months = nvl(l_new_life_in_months, l_old_life_in_months)
      WHERE     rowid = l_rowid;

      UPDATE fa_deprn_summary
      SET    deprn_reserve = l_rsv,
	     ytd_deprn = l_ytd_deprn,
	     adjusted_cost = l_rec_cost - (l_rsv - l_ytd_deprn)
      WHERE  asset_id = l_asset_id
      AND    book_type_code = p_book_type_code
      AND    period_counter = l_pc
      AND    deprn_source_code = 'BOOKS';

      l_status := FA_INS_DETAIL_PKG.faxindd(
			X_book_type_code	=>p_book_type_code,
			X_asset_id		=>l_asset_id,
                        X_mrc_sob_type_code     =>'P',
                        X_set_of_books_id       =>null,
                        p_log_level_rec => g_log_level_rec);
      if (not l_status) then
	   RAISE faxstur_err;
      end if;
      l_count := l_count + 1;
   END LOOP;

   /*=========================================================================
      End mass transaction and unlock the book.
   ==========================================================================*/

   IF NOT FA_BEGIN_MASS_TRX_PKG.faxemt(
                X_book          => p_book_type_code,
                X_request_id    => l_request_id, p_log_level_rec => g_log_level_rec) THEN
        FA_SRVR_MSG.Add_Message(
                        CALLING_FN => 'fa_sty_reserve_pkg.faxstur',  p_log_level_rec => g_log_level_rec);
   END IF;

   FND_CONCURRENT.AF_COMMIT;

   fa_srvr_msg.add_message(
              calling_fn => 'fa_sty_reserve_pkg.faxstur',
              name       => 'FA_SHARED_NUMBER_PROCESSED',
              token1     => 'NUMBER',
              value1     => to_char(l_count),  p_log_level_rec => g_log_level_rec);

   fa_srvr_msg.add_message(
                calling_fn => 'fa_sty_reserve_pkg.faxstur',
                name       => 'FA_SHARED_END_SUCCESS',
                token1     => 'PROGRAM',
                value1     => 'FAUPST',  p_log_level_rec => g_log_level_rec);

   -- Dump Debug messages when run in debug mode to log file
   IF (g_log_level_rec.statement_level) THEN
       FA_DEBUG_PKG.Write_Debug_Log;
   END IF;

   -- write messages to log file
   FND_MSG_PUB.Count_And_Get(
             p_count                => p_msg_count,
             p_data                 => p_msg_data);
   fa_srvr_msg.Write_Msg_Log(p_msg_count, p_msg_data, p_log_level_rec => g_log_level_rec);

   -- return success to concurrent manager
   retcode := 0;

EXCEPTION
   when faxstur_err then
	FND_CONCURRENT.AF_ROLLBACK;
        /* Unlock the book if transaction was approved and commit the change. */
        IF l_trx_approval THEN
            IF NOT FA_BEGIN_MASS_TRX_PKG.faxemt(
                        X_book          => p_book_type_code,
                        X_request_id    => l_request_id, p_log_level_rec => g_log_level_rec) THEN
		FA_SRVR_MSG.Add_Message(
                        CALLING_FN => 'fa_sty_reserve_pkg.faxstur',  p_log_level_rec => g_log_level_rec);
            END IF;
        END IF;

        fa_srvr_msg.add_message(
                        calling_fn => 'fa_sty_reserve_pkg.faxstur',
                        name       => 'FA_SHARED_END_WITH_ERROR',
                        token1     => 'PROGRAM',
                        value1     => 'FAUPSTR',  p_log_level_rec => g_log_level_rec);

   	-- Dump Debug messages when run in debug mode to log file
   	IF (g_log_level_rec.statement_level) THEN
       	   FA_DEBUG_PKG.Write_Debug_Log;
   	END IF;

   	-- write messages to log file
   	FND_MSG_PUB.Count_And_Get(
             p_count                => p_msg_count,
             p_data                 => p_msg_data);
   	fa_srvr_msg.Write_Msg_Log(p_msg_count, p_msg_data, p_log_level_rec => g_log_level_rec);
        retcode := 2;

   when others then
	FND_CONCURRENT.AF_ROLLBACK;
        /* Unlock the book if transaction was approved and commit the change. */
        IF l_trx_approval THEN
            IF NOT FA_BEGIN_MASS_TRX_PKG.faxemt(
                        X_book          => p_book_type_code,
                        X_request_id    => l_request_id, p_log_level_rec => g_log_level_rec) THEN
                FA_SRVR_MSG.Add_Message(
                        CALLING_FN => 'fa_sty_reserve_pkg.faxstur',  p_log_level_rec => g_log_level_rec);
            END IF;
        END IF;

        FA_SRVR_MSG.ADD_SQL_ERROR(
                   CALLING_FN => 'FA_STY_RESERVE_PKG.faxstur',  p_log_level_rec => g_log_level_rec);

        fa_srvr_msg.add_message(
                        calling_fn => 'fa_sty_reserve_pkg.faxstur',
                        name       => 'FA_SHARED_END_WITH_ERROR',
                        token1     => 'PROGRAM',
                        value1     => 'FAUPSTR',  p_log_level_rec => g_log_level_rec);

        -- Dump Debug messages when run in debug mode to log file
        IF (g_log_level_rec.statement_level) THEN
           FA_DEBUG_PKG.Write_Debug_Log;
        END IF;

        -- write messages to log file
        FND_MSG_PUB.Count_And_Get(
             p_count                => p_msg_count,
             p_data                 => p_msg_data);
        fa_srvr_msg.Write_Msg_Log(p_msg_count, p_msg_data, p_log_level_rec => g_log_level_rec);

        retcode := 2;
END faxstur;

END FA_STY_RESERVE_PKG;

/
