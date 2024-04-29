--------------------------------------------------------
--  DDL for Package Body FA_RETIRE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RETIRE_PKG" as
/* $Header: faxretb.pls 120.10.12010000.2 2009/07/19 10:01:36 glchen ship $ */

  g_print_debug boolean := fa_cache_pkg.fa_print_debug;

  PROCEDURE Initialize(X_Book_Type_Code			VARCHAR2,
		       X_Asset_Id			NUMBER,
		       X_Cost			 OUT NOCOPY NUMBER,
		       X_Current_Units		 OUT NOCOPY NUMBER,
		       X_Date_Retired		 OUT NOCOPY DATE,
		       X_Current_Fiscal_Year		IN OUT NOCOPY NUMBER,
		       X_Book_Class			IN OUT NOCOPY VARCHAR2,
		       X_FY_Start_Date		 OUT NOCOPY DATE,
		       X_FY_End_Date		 OUT NOCOPY DATE,
		       X_Current_Period_Counter	 OUT NOCOPY NUMBER,
		       X_Asset_Added_PC		 OUT NOCOPY NUMBER,
		       X_Calendar_Period_Close_Date OUT NOCOPY DATE,
		       X_Max_Transaction_Date_Entered OUT NOCOPY DATE,
		       X_Asset_Type			IN OUT NOCOPY VARCHAR2,
		       X_Ret_Prorate_Convention 	IN OUT NOCOPY VARCHAR2,
		       X_Use_STL_Retirements_Flag	IN OUT NOCOPY VARCHAR2,
		       X_STL_Method_Code		IN OUT NOCOPY VARCHAR2,
		       X_STL_Life_In_Months	 OUT NOCOPY NUMBER,
		       X_Calling_Fn			VARCHAR2,
             p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  LV_Fiscal_Year_Name	VARCHAR2(30);
  LV_Count		NUMBER;
  LV_Category_Id		NUMBER;
  LV_Date_Placed_In_Service	DATE;
  LV_PC_Fully_Retired	NUMBER;
  LV_Unit_Adjustment_Flag	VARCHAR2(3);
  LV_Message		VARCHAR2(50);
  Validation_Error	EXCEPTION;
  BEGIN
     -- check if there is an add-to-asset transaction pending
     SELECT count(*)
     INTO LV_Count
     FROM FA_MASS_ADDITIONS
     WHERE BOOK_TYPE_CODE = X_Book_Type_Code
     AND ADD_TO_ASSET_ID = X_Asset_Id
     AND POSTING_STATUS NOT IN ('POSTED','MERGED','SPLIT','DELETE');
     --
     if (LV_Count <> 0) then
	     	Lv_Message := 'FA_RET_CANT_RET_INCOMPLETE_ASS';
	     	raise Validation_Error;
     end if;
     --  check if another retirement/reinstatement already pending
     SELECT count(*)
     INTO LV_Count
     FROM FA_RETIREMENTS
     WHERE ASSET_ID = X_Asset_Id
     AND BOOK_TYPE_CODE = X_Book_Type_Code
     AND STATUS IN ('PENDING','REINSTATE');
     --
     if (LV_Count <> 0) then
		Lv_Message := 'FA_RET_PENDING_RETIREMENTS';
		raise Validation_Error;
     end if;
     --
     SELECT
	     bk.cost,
	     bk.date_placed_in_service,
 	     bk.period_counter_fully_retired,
	     ah.units,
	     ah.category_id,
	     ah.asset_type,
	     greatest(least(dp.calendar_period_close_date, sysdate),
		     dp.calendar_period_open_date),
	     dp.period_counter,
	     dp.calendar_period_close_date,
	     ad.unit_adjustment_flag
     INTO
	     X_Cost,
	     LV_Date_Placed_In_Service,
	     LV_PC_Fully_Retired,
	     X_Current_Units,
	     LV_Category_Id,
	     X_Asset_Type,
	     X_Date_Retired,
	     X_Current_Period_Counter,
	     X_Calendar_Period_Close_Date,
	     LV_Unit_Adjustment_Flag
     FROM
	     fa_books bk,
	     fa_asset_history ah,
	     fa_deprn_periods dp,
	     fa_additions ad
     WHERE
	     bk.book_type_code = X_Book_Type_Code and
	     bk.asset_id = X_Asset_Id and
	     bk.date_ineffective is null
     and
	     ah.asset_id = X_Asset_Id and
	     ah.date_ineffective is null
     and
	     dp.book_type_code = X_Book_Type_Code and
	     dp.period_close_Date is null
     and
	     ad.asset_id = X_Asset_Id;
     --
     if (LV_PC_Fully_Retired is not null) then
  	Lv_Message := 'FA_SHARED_RETIRED_ASSET';
	raise Validation_Error;
     end if;
     --
     if (LV_Unit_Adjustment_Flag = 'YES') then
	Lv_Message := 'FA_RET_CHANGE_UNITS_TFR_FORM';
	raise Validation_Error;
     end if;
     --
     SELECT current_fiscal_year,book_class,fiscal_year_name
     INTO X_Current_Fiscal_Year,X_Book_Class,LV_Fiscal_Year_Name
     FROM fa_book_controls
     WHERE book_type_code = X_Book_Type_Code;
     --
     SELECT start_date, end_date
     INTO X_FY_Start_Date, X_FY_End_Date
     FROM FA_FISCAL_YEAR
     WHERE Fiscal_Year = X_Current_Fiscal_Year
     AND Fiscal_Year_Name = LV_Fiscal_Year_Name;
     -- Check when asset was added
     SELECT dp.period_counter
     INTO X_Asset_Added_PC
     FROM FA_TRANSACTION_HEADERS TH,
     FA_DEPRN_PERIODS DP
     WHERE  TH.ASSET_ID = X_ASSET_ID
     AND    TH.BOOK_TYPE_CODE = X_BOOK_TYPE_CODE
     AND    TH.TRANSACTION_TYPE_CODE||'' =
	     DECODE(X_Book_Class,'CORPORATE','TRANSFER IN', 'ADDITION')
     AND    TH.DATE_EFFECTIVE BETWEEN DP.PERIOD_OPEN_DATE
     AND    NVL(DP.PERIOD_CLOSE_DATE, SYSDATE)
     AND    DP.BOOK_TYPE_CODE = X_BOOK_TYPE_CODE;
     --

     -- commenting for bug 3768867
     /*SELECT max(transaction_date_entered)
     INTO X_Max_Transaction_Date_Entered
     FROM fa_transaction_headers
     WHERE asset_id = X_Asset_Id
     and book_type_code = X_Book_Type_Code
     and transaction_type_code not in ('REINSTATEMENT','FULL RETIREMENT')
     and transaction_type_code not like '%/VOID';*/  -- bug2107509

     -- adding for bug 3768867
   if not FA_UTIL_PVT.get_latest_trans_date
           (p_calling_fn        => 'fa_retire_pkg.initialize'
           ,p_asset_id          => X_Asset_Id
           ,p_book              => X_Book_Type_Code
           ,x_latest_trans_date => X_Max_Transaction_Date_Entered
  	   ,p_log_level_rec => p_log_level_rec) then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

     --
     SELECT retirement_prorate_convention,
	     use_stl_retirements_flag,
	     stl_method_code,
	     stl_life_in_months
     INTO	X_Ret_Prorate_Convention,
	     X_Use_STL_Retirements_Flag,
	     X_STL_Method_Code,
	     X_STL_Life_In_Months
     FROM	fa_category_book_defaults
     WHERE	book_type_code = X_Book_Type_Code
     and	category_id = LV_Category_Id
     and 	LV_Date_Placed_In_Service between start_dpis and
		     nvl(end_dpis,LV_Date_Placed_In_Service);
     --
     if (X_Use_STL_Retirements_Flag = 'NO') then
	X_STL_Method_Code := NULL;
	X_STL_Life_In_Months := NULL;
     end if;
  EXCEPTION
	WHEN Validation_Error THEN
		FA_STANDARD_PKG.RAISE_ERROR
			(Called_Fn => 'FA_RETIRE_PKG.Initialize',
			Calling_Fn => X_Calling_Fn,
			Name => LV_Message
			,p_log_level_rec => p_log_level_rec);
	WHEN Others THEN
		FA_STANDARD_PKG.RAISE_ERROR
			(Called_Fn => 'FA_RETIRE_PKG.Initialize',
			Calling_Fn => X_Calling_Fn
			,p_log_level_rec => p_log_level_rec);
  END Initialize;
--
END FA_RETIRE_PKG;

/
