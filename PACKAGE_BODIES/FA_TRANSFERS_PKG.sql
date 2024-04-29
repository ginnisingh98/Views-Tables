--------------------------------------------------------
--  DDL for Package Body FA_TRANSFERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_TRANSFERS_PKG" as
/* $Header: faxtfrb.pls 120.7.12010000.2 2009/07/19 13:08:36 glchen ship $ */

  PROCEDURE INITIALIZE(X_Asset_Id			NUMBER,
			X_Book_Type_Code		IN OUT NOCOPY VARCHAR2,
			X_From_Block			VARCHAR2,
			X_Transaction_Date_Entered 	IN OUT NOCOPY DATE,
			X_Acct_Flex_Num			IN OUT NOCOPY NUMBER,
			X_Calendar_Period_Open_Date	IN OUT NOCOPY DATE,
			X_Calendar_Period_Close_Date	IN OUT NOCOPY DATE,
			X_Transfer_In_PC		IN OUT NOCOPY NUMBER,
			X_Current_PC			IN OUT NOCOPY NUMBER,
			X_FY_Start_Date			IN OUT NOCOPY DATE,
			X_FY_End_Date			IN OUT NOCOPY DATE,
			X_Max_Transaction_Date		IN OUT NOCOPY DATE,
			X_Just_Added_To_Tax_Book	IN OUT NOCOPY VARCHAR2,
			X_Asset_Type			IN OUT NOCOPY VARCHAR2,
			X_Category_Id			IN OUT NOCOPY NUMBER,
			X_Calling_Fn			VARCHAR2
			, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  Lv_Count	Number;
  Lv_Fiscal_Year	Number(4);
  Lv_Fiscal_Year_Name 	Varchar2(30);
  Lv_AH_Units	Number;
  Lv_DH_Units	Number;
  Lv_Message	Varchar2(30);
  Validation_Error	Exception;
  BEGIN
	if (X_From_Block = 'ASSETS_FDR' or X_From_Block = 'ASSET') then
	  begin
	    select bc.book_type_code
	    into X_Book_Type_Code
	    from fa_book_controls bc,
		 fa_books bk
	    where bk.asset_id = X_Asset_Id
	    and   bk.book_type_code = bc.book_type_code
	    and   bk.date_ineffective is null
	    and   nvl(bc.date_ineffective, sysdate+1) > sysdate
	    and bc.book_class = 'CORPORATE';
  	  exception
	    when no_data_found then
		lv_message := 'FA_TFR_ADD_ASSET_TO_BOOK';
		raise validation_error;
	    when others then raise;
	  end;
	  --
	  select greatest(calendar_period_open_date,
			 least(sysdate, calendar_period_close_date)),
		 calendar_period_open_date,
		 calendar_period_close_date,
		 period_counter
	  into X_Transaction_Date_Entered,
	       X_Calendar_Period_Open_Date,
	       X_Calendar_Period_Close_Date,
	       X_Current_PC
	  from fa_deprn_periods
	  where book_type_code = X_Book_Type_Code
	  and period_close_date is null;
	  --
	  select dp.period_counter
	  into X_Transfer_In_PC
	  from fa_deprn_periods dp, fa_transaction_headers th
	  where th.asset_id = X_Asset_Id
	  and th.book_type_code = X_Book_Type_Code
	  and th.transaction_type_code = 'TRANSFER IN'
	  and dp.book_type_code = X_Book_Type_Code
	  and th.date_effective between dp.period_open_date
			 and nvl(dp.period_close_date, sysdate);
	  --
	  select fiscal_year_name, current_fiscal_year
	  into lv_fiscal_year_name, lv_fiscal_year
	  from fa_book_controls
	  where book_type_code = X_Book_Type_Code;
	  --
	  if X_Transfer_In_PC < X_Current_PC then
	     -- used for trans_date_entered validation only
	     select start_date, end_date
	     into X_FY_Start_Date, X_FY_End_Date
	     from fa_fiscal_year
	     where fiscal_year = lv_fiscal_year
	     and fiscal_year_name = lv_fiscal_year_name;
	     --

/*	     select max(transaction_date_entered)
	     into X_Max_Transaction_Date
	     from fa_transaction_headers
	     where asset_id = X_Asset_Id
	     and book_type_code = X_Book_Type_Code; */

             if not FA_UTIL_PVT.get_latest_trans_date
                (p_calling_fn        => 'fa_transfers_pkg.initialize'
                 ,p_asset_id          => X_Asset_Id
                 ,p_book              => X_Book_Type_Code
                 ,x_latest_trans_date => X_Max_Transaction_Date, p_log_level_rec => p_log_level_rec) then

                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
             end if;

	   end if; /* if X_Transfer_In_PC < X_Current_PC */
	end if; /* if X_From_Block = ASSET or ASSETS_FDR */
	--
	if X_From_Block <> 'FA_BOOKS' /* no asset_id yet for tfr in */ then
	   -- make sure units are in sync
	   select units into lv_ah_units
	   from fa_asset_history
	   where asset_id = X_Asset_Id
	   and date_ineffective is null;
	   --
	   select sum(units_assigned - nvl(transaction_units, 0))
	   into lv_dh_units
	   from fa_distribution_history
	   where asset_id = X_Asset_Id
	   and book_type_code = X_Book_Type_Code
	   and date_ineffective is null;
	   --
	   if lv_ah_units <> lv_dh_units then
		--units are out of sync.  Don't allow this transaction
		lv_message := 'FA_UNITS_DIFFERENT';
		raise validation_error;
	   end if;
	   --
	   select count(*)
	   into lv_count
	   from fa_books bk, fa_book_controls bc
	   where bk.asset_id = X_Asset_Id
	   and bk.date_ineffective is null
	   and bk.book_type_code = bc.book_type_code
	   and bc.book_class = 'BUDGET'
	   and nvl(bc.date_ineffective, sysdate+1) > sysdate;
	   --
	   -- can't be in Budget book.  error.
	   if lv_count > 0 then
		lv_message := 'FA_CANT_TRANSACT';
		raise validation_error;
	   end if;
	   -- Pending Retirements?
	   select count(*)
	   into lv_count
	   from fa_retirements
	   where asset_id = X_Asset_Id
	   and book_type_code = X_Book_Type_Code
	   and status in ('PENDING','REINSTATE');
	   --
	   if lv_count > 0 then
		lv_message := 'FA_RET_PENDING_RETIREMENTS';
		raise validation_error;
	   end if;
	   -- Asset already fully retired?
	   select count(*)
	   into lv_count
	   from fa_books
	   where asset_id = X_Asset_Id
	   and book_type_code = X_Book_Type_Code
	   and date_ineffective is null
	   and period_counter_fully_retired is not null;
	   --
	   if lv_count > 0 then
		lv_message := 'FA_SHARED_RETIRED_ASSET';
		raise validation_error;
	   end if;
	   --
	   -- if asset in (CIP) ADDITION period in assoc TAX books, update
	   -- distributions in those books
	   -- do this in the form, using INS_DETAIL
	   select count(1)
	   into lv_count
	   from fa_transaction_headers th,
		fa_deprn_periods dp,
		fa_book_controls bc
	   where bc.book_class <> 'CORPORATE'
	   and bc.distribution_source_book = X_Book_Type_Code
	   and th.book_type_code = bc.book_type_code
	   and th.asset_id = X_Asset_Id
	   and th.transaction_type_code||'' in ('ADDITION','CIP ADDITION')
	   and dp.book_type_code = bc.book_type_code
	   and dp.period_close_date is null
	   and th.date_effective >= dp.period_open_date
           and bc.date_ineffective is null;
	   --
	   if lv_count > 0 then
		   X_Just_Added_To_Tax_Book := 'TRUE';
	   end if;
	   --
	   -- used in Transfers user exit
	   select asset_type, category_id
	   into X_Asset_Type, X_Category_Id
	   from fa_asset_history
	   where asset_id = X_Asset_Id
	   and date_ineffective is null;
	end if; /* if X_From_Block <> 'BOOKS' */
	--
	select accounting_flex_structure
	into X_Acct_Flex_Num
	from fa_book_controls
	where book_type_code = X_Book_Type_Code;
  EXCEPTION
	WHEN Validation_Error THEN
		FA_STANDARD_PKG.RAISE_ERROR
			(Called_Fn => 'FA_TRANSFER_PKG.Initialize',
			Calling_Fn => X_Calling_Fn,
			Name => LV_Message, p_log_level_rec => p_log_level_rec);
	WHEN Others THEN
		FA_STANDARD_PKG.RAISE_ERROR
			(Called_Fn => 'FA_TRANSFER_PKG.Initialize',
			Calling_Fn => X_Calling_Fn, p_log_level_rec => p_log_level_rec);
  END Initialize;

END FA_TRANSFERS_PKG;

/
