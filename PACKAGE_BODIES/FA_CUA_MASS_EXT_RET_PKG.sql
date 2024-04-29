--------------------------------------------------------
--  DDL for Package Body FA_CUA_MASS_EXT_RET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CUA_MASS_EXT_RET_PKG" AS
/* $Header: FACXTREMB.pls 120.22.12010000.5 2010/03/21 19:39:41 glchen ship $

/* Global Variables holding Mass External Retirements Information */
  G_Mass_External_Retire_Id      fa_mass_Ext_retirements.Mass_External_Retire_Id%TYPE;
  G_Book_Type_Code               fa_mass_Ext_retirements.Book_Type_Code%TYPE;
  G_Batch_Name		  	 fa_mass_Ext_retirements.Batch_Name%TYPE;
  G_Asset_Id                     fa_mass_Ext_retirements.Asset_Id%TYPE;
  G_Transaction_Name             fa_mass_Ext_retirements.Transaction_Name%TYPE;
  G_Date_Retired                 fa_mass_Ext_retirements.Date_Retired%TYPE;
  G_Cost_Retired                 fa_mass_Ext_retirements.Cost_Retired%TYPE;
  G_Retirement_Prorate_Conv      fa_mass_Ext_retirements.Retirement_Prorate_Convention%TYPE;
  G_Units                        fa_mass_Ext_retirements.Units%TYPE;
  G_Cost_Of_Removal              fa_mass_Ext_retirements.Cost_Of_Removal%TYPE;
  G_Proceeds_Of_Sale             fa_mass_Ext_retirements.Proceeds_Of_Sale%TYPE;
  G_Retirement_Type_Code         fa_mass_Ext_retirements.Retirement_Type_Code%TYPE;
  G_Reference_Num                fa_mass_Ext_retirements.Reference_Num%TYPE;
  G_Sold_To                      fa_mass_Ext_retirements.Sold_To%TYPE;
  G_Trade_In_Asset_Id            fa_mass_Ext_retirements.Trade_In_Asset_Id%TYPE;
  G_Stl_Method_Code              fa_mass_Ext_retirements.Stl_Method_Code%TYPE;
  G_Stl_Life_In_Months           fa_mass_Ext_retirements.Stl_Life_In_Months%TYPE;
  G_Stl_Deprn_Amount             fa_mass_Ext_retirements.Stl_Deprn_Amount%TYPE;
  G_Itc_Recaptured               fa_retirements.Itc_Recaptured%TYPE;
  G_Itc_Recapture_Id             fa_retirements.Itc_Recapture_Id%TYPE;
  G_Current_Units                fa_asset_history.Units%TYPE;
  G_Asset_Number		            fa_additions_b.asset_number%TYPE;
  G_period_counter_fully_retired Number;
/* Bug 8483118(R12) and 8206076(11i) - Start */
  G_Recognize_Gain_Loss          fa_retirements.recognize_gain_loss%Type;
  G_Recapture_Reserve_Flag       fa_retirements.recapture_reserve_flag%Type;
  G_Limit_Proceeds_Flag          fa_retirements.limit_proceeds_flag%Type;
  G_Terminal_Gain_Loss           fa_retirements.terminal_gain_loss%Type;
/* Bug 8483118(R12) and 8206076(11i) - End */
  G_Last_Update_Login            NUMBER(15) := FND_GLOBAL.LOGIN_ID;
  G_Precision                    NUMBER;
  G_Ext_Precision                NUMBER;
  G_Min_Acct_Unit                NUMBER;
  G_Today_Datetime               DATE := SYSDATE;
  G_Currency_Code                gl_sets_of_books.currency_code%TYPE;
  G_Set_of_Books_ID		         fa_book_controls.set_of_books_id%TYPE;
  G_calc_gain_loss_flag	 	varchar2(50) :=  FND_API.G_FALSE;
  G_Distribution_id		 fa_distribution_history.distribution_id%TYPE;
-- bug 1857395
  G_Code_Combination_Id		 fa_mass_Ext_retirements.Code_Combination_Id%TYPE;
 G_Location_Id			 fa_mass_Ext_retirements.Location_Id%TYPE;
 G_Assigned_To			 fa_mass_Ext_retirements.Assigned_To%TYPE;
  G_Recursion_Level              VARCHAR2(1);
  G_Created_By                   NUMBER(15) := FND_GLOBAL.USER_ID;
  G_Creation_Date                DATE       := SYSDATE;
  G_Varchar2_Dummy               VARCHAR2(80);
  G_Number_Dummy                 NUMBER(15);
  G_Date_Dummy			 Date;
  G_Date_Effective		 Date;
  G_Transaction_Header_Id_In	 Number;
  G_Transaction_Header_Id_Out	 Number;
  G_ah_transaction_header_id 	 Number;
  G_category_id			 Number;
  G_Book_Header_Id		 Number;
  G_Transaction_Units		 Number;
  G_Calling_Interface		 VARCHAR2(30) := 'FAMPRET';
--

  G_Subroutine_Fail		EXCEPTION;
/* Start Bug 1300585 */
  G_TH_Attribute_Category        fa_mass_Ext_retirements.TH_Attribute_Category%TYPE;
  G_TH_Attribute1                fa_mass_Ext_retirements.TH_Attribute1%TYPE;
  G_TH_Attribute2                fa_mass_Ext_retirements.TH_Attribute2%TYPE;
  G_TH_Attribute3                fa_mass_Ext_retirements.TH_Attribute3%TYPE;
  G_TH_Attribute4                fa_mass_Ext_retirements.TH_Attribute4%TYPE;
  G_TH_Attribute5                fa_mass_Ext_retirements.TH_Attribute5%TYPE;
  G_TH_Attribute6                fa_mass_Ext_retirements.TH_Attribute6%TYPE;
  G_TH_Attribute7                fa_mass_Ext_retirements.TH_Attribute7%TYPE;
  G_TH_Attribute8                fa_mass_Ext_retirements.TH_Attribute8%TYPE;
  G_TH_Attribute9                fa_mass_Ext_retirements.TH_Attribute9%TYPE;
  G_TH_Attribute10               fa_mass_Ext_retirements.TH_Attribute10%TYPE;
  G_TH_Attribute11               fa_mass_Ext_retirements.TH_Attribute11%TYPE;
  G_TH_Attribute12               fa_mass_Ext_retirements.TH_Attribute12%TYPE;
  G_TH_Attribute13               fa_mass_Ext_retirements.TH_Attribute13%TYPE;
  G_TH_Attribute14               fa_mass_Ext_retirements.TH_Attribute14%TYPE;
  G_TH_Attribute15               fa_mass_Ext_retirements.TH_Attribute15%TYPE;
  G_Attribute_Category           fa_mass_Ext_retirements.Attribute_Category%TYPE;
  G_Attribute1                   fa_mass_Ext_retirements.Attribute1%TYPE;
  G_Attribute2                   fa_mass_Ext_retirements.Attribute2%TYPE;
  G_Attribute3                   fa_mass_Ext_retirements.Attribute3%TYPE;
  G_Attribute4                   fa_mass_Ext_retirements.Attribute4%TYPE;
  G_Attribute5                   fa_mass_Ext_retirements.Attribute5%TYPE;
  G_Attribute6                   fa_mass_Ext_retirements.Attribute6%TYPE;
  G_Attribute7                   fa_mass_Ext_retirements.Attribute7%TYPE;
  G_Attribute8                   fa_mass_Ext_retirements.Attribute8%TYPE;
  G_Attribute9                   fa_mass_Ext_retirements.Attribute9%TYPE;
  G_Attribute10                  fa_mass_Ext_retirements.Attribute10%TYPE;
  G_Attribute11                  fa_mass_Ext_retirements.Attribute11%TYPE;
  G_Attribute12                  fa_mass_Ext_retirements.Attribute12%TYPE;
  G_Attribute13                  fa_mass_Ext_retirements.Attribute13%TYPE;
  G_Attribute14                  fa_mass_Ext_retirements.Attribute14%TYPE;
  G_Attribute15                  fa_mass_Ext_retirements.Attribute15%TYPE;

/* End of bug 1300585*/

  G_fatal_error  boolean  := FALSE;
  G_failure_count number := 0;
  G_success_count NUMBER := 0;

   g_prev_asset_id		number := 0;
   g_prev_batch_name 		varchar2(30) := 'ZZZZZZZZZZZZZZZZ';
   g_num_of_distributions 	number;
   g_i				number;

  G_test_num_of_distributions    	NUMBER;
  G_test_ident_distributions		NUMBER;
  G_single_dist_array 			VARCHAR2(10);

  g_log_level_rec fa_api_types.log_level_rec_type;

PROCEDURE Mass_Ext_Retire (P_BOOK_TYPE_CODE     IN             VARCHAR2,
                           PX_BATCH_NAME        IN OUT  NOCOPY VARCHAR2,
                           P_PARENT_REQUEST_ID  IN             NUMBER,
                           P_TOTAL_REQUESTS     IN             NUMBER,
                           P_REQUEST_NUMBER     IN             NUMBER,
                           PX_MAX_MASS_EXT_RETIRE_ID    IN OUT  NOCOPY NUMBER,
                           X_SUCCESS_COUNT         OUT  NOCOPY NUMBER,
                           X_FAILURE_COUNT         OUT  NOCOPY NUMBER,
                           X_RETURN_STATUS         OUT  NOCOPY NUMBER) IS

  CURSOR mass_external_retirement IS
    SELECT   mer.Mass_External_Retire_Id,
             mer.Book_Type_Code,
	     mer.Batch_Name,
             mer.Asset_Id,
             Mer.Transaction_Name,
             mer.Date_Retired,
             mer.Cost_Retired,
             mer.Retirement_Prorate_Convention,
             mer.Units,
             nvl(mer.Cost_Of_Removal,0),
             nvl(mer.Proceeds_Of_Sale,0),
             mer.Retirement_Type_Code,
             mer.Reference_Num,
             mer.Sold_To,
             mer.Trade_In_Asset_Id,
	     mer.calc_gain_loss_flag,
             mer.Stl_Method_Code,
             mer.Stl_Life_In_Months,
             mer.Stl_Deprn_Amount,
             mer.Last_Update_Login,
             sysdate,
             sob.currency_code,
	     fbc.set_of_books_id,
	     ad.current_units,
	     ad.asset_number,
	     bks.period_counter_fully_retired,
	     mer.distribution_id,
	     mer.code_combination_id,
	     mer.location_id,
	     mer.assigned_to,
             mer.th_attribute_category,
             mer.th_attribute1,
             mer.th_attribute2,
             mer.th_attribute3,
             mer.th_attribute4,
             mer.th_attribute5,
             mer.th_attribute6,
             mer.th_attribute7,
             mer.th_attribute8,
             mer.th_attribute9,
             mer.th_attribute10,
             mer.th_attribute11,
             mer.th_attribute12,
             mer.th_attribute13,
             mer.th_attribute14,
             mer.th_attribute15,
             mer.attribute_category,
             mer.attribute1,
             mer.attribute2,
             mer.attribute3,
             mer.attribute4,
             mer.attribute5,
             mer.attribute6,
             mer.attribute7,
             mer.attribute8,
             mer.attribute9,
             mer.attribute10,
             mer.attribute11,
             mer.attribute12,
             mer.attribute13,
             mer.attribute14,
             mer.attribute15,
             mer.recognize_gain_loss,/*Bug 8647381 *//* Bug 8483118(R12) and 8206076(11i) - Start */
	     bks.recapture_reserve_flag,
	     bks.limit_proceeds_flag,
	     bks.terminal_gain_loss /* Bug 8483118(R12) and 8206076(11i) - End */
    FROM fa_mass_Ext_retirements mer,
	 fa_books bks,
	 fa_additions_b ad,
         fa_book_controls fbc,
         gl_sets_of_books sob
    WHERE mer.review_status = 'POST'
       AND mer.book_type_code     = fbc.book_type_code
       AND fbc.set_of_books_id    = sob.set_of_books_id
       AND mer.batch_name	  = nvl(px_batch_name,mer.batch_name)
       AND mer.book_type_code = P_Book_Type_Code
       AND bks.book_type_code = mer.book_type_code
       AND bks.asset_id       = mer.asset_id
       AND bks.date_ineffective is null
       AND ad.asset_id 		  = mer.asset_id
       and mer.mass_external_retire_id > px_max_mass_ext_retire_id
       and MOD(nvl(bks.group_asset_id,mer.asset_id), p_total_requests) = (p_request_number - 1)
       order by mer.batch_name, mer.mass_external_retire_id;

   -- used for bulk fetching
   l_batch_size                 number;

   -- index for For..loops
   i 				number := 0;
   j				number := 0;
   k				number := 0;
   -- main cursor
   -- type for table variable
   type num_tbl_type  is table of number        index by binary_integer;
   type char_tbl_type is table of varchar2(150) index by binary_integer;
   type date_tbl_type is table of date          index by binary_integer;

-- api declaration
-- variables and structs used for api call
--   l_debug_flag                   VARCHAR2(3) := 'YES';
   l_debug_flag                   VARCHAR2(3) := 'NO';
   l_api_version                  NUMBER      := 1;  -- 1.0
   l_init_msg_list                VARCHAR2(50) := FND_API.G_FALSE; -- 1
   l_commit                       VARCHAR2(1) := FND_API.G_FALSE;
   l_validation_level             NUMBER      := FND_API.G_VALID_LEVEL_FULL;
   l_return_status                VARCHAR2(10);
   l_msg_count                    NUMBER;
--   l_msg_data                   VARCHAR2(4000);
   l_calling_fn                   VARCHAR2(100) := 'fa_cua_mass_ext_ret_pkg';
   l_trans_rec              fa_api_types.trans_rec_type;
   l_dist_trans_rec         fa_api_types.trans_rec_type;
   l_asset_hdr_rec          fa_api_types.asset_hdr_rec_type;
   l_asset_retire_rec       fa_api_types.asset_retire_rec_type;
   l_asset_dist_rec         fa_api_types.asset_dist_rec_type;
   l_asset_dist_tbl         fa_api_types.asset_dist_tbl_type;
   l_subcomp_rec            fa_api_types.subcomp_rec_type;
   l_subcomp_tbl            fa_api_types.subcomp_tbl_type;
   l_inv_rec                fa_api_types.inv_rec_type;
   l_inv_tbl                fa_api_types.inv_tbl_type;
-- end api declaration

  l_Mass_External_Retire_Id		num_tbl_type;
  L_Book_Type_Code  			char_tbl_type;
  L_Batch_Name				char_tbl_type;
  L_Asset_Id  				num_tbl_type;
  L_Transaction_Name 			char_tbl_type;
  L_Date_Retired 			date_tbl_type;
  L_Cost_Retired  			num_tbl_type;
  L_Retirement_Prorate_Conv 		char_tbl_type;
  L_Units  				num_tbl_type;
  L_Cost_Of_Removal  			num_tbl_type;
  L_Proceeds_Of_Sale 			num_tbl_type;
  L_Retirement_Type_Code  		char_tbl_type;
  L_Reference_Num  			char_tbl_type;
  L_Sold_To 				char_tbl_type;
  L_Trade_In_Asset_Id  			num_tbl_type;
  L_Calc_Gain_Loss_Flag			char_tbl_type;
  L_Stl_Method_Code  			char_tbl_type;
  L_Stl_Life_In_Months     		num_tbl_type;
  L_Stl_Deprn_Amount     		num_tbl_type;
  L_Last_Update_Login     		num_tbl_type;
  L_Today_Datetime     			date_tbl_type;
  L_Currency_Code      			char_tbl_type;
  L_Set_of_Books_Id			num_tbl_type;
  L_Current_Units			num_tbl_type;
  L_Asset_Number			char_tbl_type;
  L_Period_Counter_Fully_Retired        num_tbl_type;
/* Bug 8483118(R12) and 8206076(11i) - Start */
  L_Recognize_Gain_Loss			char_tbl_type;
  L_Recapture_Reserve_Flag		char_tbl_type;
  L_Limit_Proceeds_Flag			char_tbl_type;
  L_Terminal_Gain_Loss			char_tbl_type;
/* Bug 8483118(R12) and 8206076(11i) - Start */
  L_Distribution_Id     		num_tbl_type;
  L_Code_combination_id     		num_tbl_type;
  L_location_id     			num_tbl_type;
  L_assigned_to     			num_tbl_type;
  L_TH_Attribute_Category     		char_tbl_type;
  L_TH_Attribute1     	char_tbl_type;
  L_TH_Attribute2     	char_tbl_type;
  L_TH_Attribute3     	char_tbl_type;
  L_TH_Attribute4     	char_tbl_type;
  L_TH_Attribute5     	char_tbl_type;
  L_TH_Attribute6     	char_tbl_type;
  L_TH_Attribute7     	char_tbl_type;
  L_TH_Attribute8     	char_tbl_type;
  L_TH_Attribute9     	char_tbl_type;
  L_TH_Attribute10     	char_tbl_type;
  L_TH_Attribute11     	char_tbl_type;
  L_TH_Attribute12     	char_tbl_type;
  L_TH_Attribute13     	char_tbl_type;
  L_TH_Attribute14     	char_tbl_type;
  L_TH_Attribute15     	char_tbl_type;
  L_Attribute_Category  char_tbl_type;
  L_Attribute1     	char_tbl_type;
  L_Attribute2     	char_tbl_type;
  L_Attribute3     	char_tbl_type;
  L_Attribute4     	char_tbl_type;
  L_Attribute5     	char_tbl_type;
  L_Attribute6     	char_tbl_type;
  L_Attribute7     	char_tbl_type;
  L_Attribute8     	char_tbl_type;
  L_Attribute9     	char_tbl_type;
  L_Attribute10     	char_tbl_type;
  L_Attribute11     	char_tbl_type;
  L_Attribute12     	char_tbl_type;
  L_Attribute13     	char_tbl_type;
  L_Attribute14     	char_tbl_type;
  L_Attribute15	  	char_tbl_type;

 /** commented out for bugfix 2036777
    Cursor Source_Lines_C Is
   Select ext.*
   from fa_ext_inv_retirements ext  ,
   fa_asset_invoices ai
   where ext.mass_external_retire_id = L_Mass_External_Retire_ID
   and ext.source_line_id = ai.source_line_id
   and ai.date_ineffective is null
   and ai.asset_id = G_Asset_Id;
  Source_Lines Source_Lines_C%ROWTYPE;
**/

  -- added for bugfix 2036777
  -- modified after 2036777, added fa_ai, so only invoices belonging
  -- to current asset are treated.
  Cursor Source_Lines_C Is
   select ext.*, ext.ROWID row_id
   from fa_ext_inv_retirements ext,
	fa_asset_invoices ai
   where ext.mass_external_retire_id = G_Mass_External_Retire_ID
   and   ext.source_line_id = ai.source_line_id
   and   ai.asset_id = g_asset_id
   and   ext.source_line_id_retired is null;

  Source_Lines	Source_Lines_C%ROWTYPE;

  -- added for bugfix 2036777
  Cursor C3(p_src_line_id number) IS
  select b.source_line_id
  from fa_asset_invoices b
  where b.source_line_id in (
        select a.source_line_id
        from fa_asset_invoices a
        start with a.source_Line_id = p_src_line_id
        connect by prior a.invoice_transaction_id_out = a.invoice_transaction_id_in )
  and b.date_ineffective is null;

  C3_lines C3%ROWTYPE;


  Cursor c_ret_type IS
    select 'Y'
    from fa_lookups
    where lookup_type = 'RETIREMENT'
    and enabled_flag = 'Y'
    and nvl(end_date_active,sysdate+1) > sysdate
    and lookup_code = G_retirement_type_code;

  Cursor c_dh IS
	select 	rowid,
		distribution_id,
		book_type_code,
		asset_id,
		units_assigned,
		date_effective,
		code_combination_id,
		location_id,
		transaction_header_id_in,
		last_update_date,
		last_updated_by,
		date_ineffective,
		assigned_to,
		transaction_header_id_out,
		transaction_units,
		retirement_id,
		last_update_login
	from fa_distribution_history
	where asset_id = G_asset_id
	and   code_combination_id = G_Code_Combination_id
	and   location_id	   = G_Location_id
	and   nvl(assigned_to,0)   = nvl(G_Assigned_To,0)
	and   date_ineffective is null;
  dhrec	c_dh%ROWTYPE;

  Cursor c_currency_info IS
    select
         fc.precision
    from gl_sets_of_books sob,
         fa_book_controls fbc,
         fnd_currencies fc
    where fc.currency_code = sob.currency_code
    and fc.enabled_flag = 'Y'
    and fbc.book_type_code = p_book_type_code
    and fbc.set_of_books_id = sob.set_of_books_id;

  Cursor c_dhident is
		select nvl(count(*),0)
		into g_test_ident_distributions
		from fa_mass_ext_retirements
		where batch_name = G_batch_name
		and   review_status = 'POST'
		and   asset_id   = g_asset_id
		group by code_combination_id, location_id, assigned_to
		having count(*) > 1;

--  loop_count number:= 0;
  lv_sl_cost_retired	   	number;
  lv_src_line_id	      	number;
  lv_src_line_cost      	number;
  lv_sl_count		      	number := 0;
  lv_sl_count2		      	number := 0;
  lv_new_inv_txn_id	   	number;
  l_src_line_inv_txn_id		number;
  lv_it_rowid		      	rowid;
  lv_ret_id			number;

  -- variables for validation
  lv_cost			number;
  lv_current_units		number;
  lv_date_retired		date;
  lv_current_fiscal_year	number;
  lv_book_class			varchar2(15);
  lv_fy_start_date		date;
  lv_fy_end_date		date;
  lv_current_period_counter	number;
  lv_asset_added_pc		number;
  lv_cal_per_close_date		date;
  lv_max_txn_date_entered	date;
  lv_asset_type			varchar2(11);
  lv_ret_prorate_convention	varchar2(10);
  lv_use_stl_ret_flag		varchar2(3);
  lv_stl_method_code		varchar2(4);
  lv_stl_life_in_months		number;
  lv_val_count			number;
  lv_message			varchar2(50);
  l_pcfr			number;
  Validation_Error		exception;
  Fully_Reserved_Error		exception;
  Duplicate_Req			exception;
  lv_app				varchar2(3);
  lv_dummy_var VARCHAR2(1);

  -- added by msiddiqu  feb-24-2001
  l_count number := 0;
  l_error_status varchar2(30):= null;
  pending_batch    exception;
  v_dummy_bool boolean:= FALSE;

  -- partial unit retirement extension
  p_event 	varchar2(30) := 'INSERT';
  h_return_status 	BOOLEAN;
  h_status 		BOOLEAN;
  p_ah_rowid		rowid;
  temp_ret_cost		number;
-- mrcapi variables.
  x_msg_data		varchar2(4000);
  MRCAPI_ERROR		exception;
  CIPTAX_ERROR		exception;
  DONE_EXC		exception;
  INIT_PROBLEM		exception;
  l_mrc_thid		number;
  l_source_line_id_new number(15);

--
   l_token                        varchar2(40);
   l_value                        varchar2(40);
   l_string		  	  varchar2(512);

g_num_of_identical 	number := 0;
-- variables for multidist occurences.
   num_dist 		number := 0;

l_tot_units number;
dist_i      number;

BEGIN -- Mass_Ext_Retire

-- New api house keeping

   px_max_mass_ext_retire_id := nvl(px_max_mass_ext_retire_id, 0);
   G_success_count := 0;
   G_failure_count := 0;
   x_success_count := 0;
   x_failure_count := 0;
   x_return_status := 0;


   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise  init_problem;
      end if;
   end if;

   -- get book information
   if not fa_cache_pkg.fazcbc(X_book => p_book_type_code, p_log_level_rec => g_log_level_rec) then
      raise init_problem;
   end if;

   l_batch_size  := nvl(fa_cache_pkg.fa_batch_size, 200);

   -- clear the debug stack initially and later for each asset
   FA_DEBUG_PKG.Initialize;
   -- reset the message level to prevent bogus errors
   FA_SRVR_MSG.Set_Message_Level(message_level => 10, p_log_level_rec => g_log_level_rec);

g_i := 0;
      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'px_max_mass_ext_retire_id', px_max_mass_ext_retire_id, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'p_book', p_book_type_code, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'p_parent_request_id', p_parent_request_id, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'p_total_requests', p_total_requests, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'p_request_number', p_request_number, p_log_level_rec => g_log_level_rec);

      end if;

--      if (g_log_level_rec.statement_level) then
--         fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
--      end if;


-- Initial outfile heading

--   if (p_mode = 1 and px_max_asset_id = 0) or
--       (p_loop_count = 0 and px_max_asset_id = 0) then

   if (px_max_mass_ext_retire_id = 0) then

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('FACXTREMB.pls',
	 'FND_FILE init: BOOK ',
	 P_BOOK_TYPE_CODE, p_log_level_rec => g_log_level_rec);
      End if;

      FND_FILE.put(FND_FILE.output,'');
      FND_FILE.new_line(FND_FILE.output,1);

      -- dump out the headings
      fnd_message.set_name('OFA', 'FA_POST_MASSRET_REPORT_COLUMN');
      l_string := fnd_message.get;

      FND_FILE.put(FND_FILE.output,l_string);
      FND_FILE.new_line(FND_FILE.output,1);

      fnd_message.set_name('OFA', 'FA_POST_MASSRET_REPORT_LINE');
      l_string := fnd_message.get;
      FND_FILE.put(FND_FILE.output,l_string);
      FND_FILE.new_line(FND_FILE.output,1);

   end if;
   if (g_log_level_rec.statement_level) then
       fa_debug_pkg.add('FACXTREMB.pls',
	 'Before CRL test ',
	 '', p_log_level_rec => g_log_level_rec);
   End if;

    -- Call Hierarchy batch if CRL enabled

   if (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then
      -- returns true if batch is pending

      if fa_cua_hr_retirements_pkg.check_pending_batch
                         ( x_calling_function => 'CUA_EXT_RETIREMENTS'
                         , x_book_type_code     => P_Book_Type_Code
                         , x_event_code         => null
                         , x_asset_id           => null
                         , x_node_id            => null
                         , x_category_id        => null
                         , x_attribute          => null
                         , x_conc_request_id    => null
                         , x_status             => l_error_status , p_log_level_rec => g_log_level_rec) then

           -- there exists a pending batch
         if ( substr(l_error_status, 1, 3) = 'CUA') then
                   lv_app := 'CUA';
         end if;
         x_return_status := 2;
         lv_message := l_error_status;
         raise PENDING_BATCH;
      end if;
   end if;


   if (g_log_level_rec.statement_level) then
       fa_debug_pkg.add('FACXTREMB.pls',
	 'Before mass ext mainselect ',
	 '', p_log_level_rec => g_log_level_rec);
   End if;

   OPEN mass_external_retirement;

   FETCH mass_external_retirement BULK COLLECT INTO
 	  L_Mass_External_Retire_Id		,
	  L_Book_Type_Code  			,
	  L_Batch_Name				,
	  L_Asset_Id  				,
	  L_Transaction_Name 			,
	  L_Date_Retired 			,
	  L_Cost_Retired  			,
	  L_Retirement_Prorate_Conv 		,
	  L_Units  				,
	  L_Cost_Of_Removal  			,
	  L_Proceeds_Of_Sale 			,
	  L_Retirement_Type_Code  		,
	  L_Reference_Num  			,
	  L_Sold_To 				,
	  L_Trade_In_Asset_Id  			,
	  L_Calc_Gain_Loss_Flag			,
	  L_Stl_Method_Code  			,
	  L_Stl_Life_In_Months     		,
	  L_Stl_Deprn_Amount     		,
	  L_Last_Update_Login     		,
	  L_Today_Datetime     			,
	  L_Currency_Code      			,
	  L_Set_of_Books_Id			,
	  L_Current_Units			,
	  L_Asset_Number			,
	  L_Period_Counter_Fully_Retired	,
   	  L_Distribution_Id     		,
	  L_Code_combination_id     		,
	  L_location_id     			,
	  L_assigned_to     			,
	  L_TH_Attribute_Category     		,
	  L_TH_Attribute1     	,
	  L_TH_Attribute2     	,
	  L_TH_Attribute3     	,
	  L_TH_Attribute4     	,
	  L_TH_Attribute5     	,
	  L_TH_Attribute6     	,
	  L_TH_Attribute7     	,
	  L_TH_Attribute8     	,
	  L_TH_Attribute9     	,
	  L_TH_Attribute10     	,
	  L_TH_Attribute11     	,
	  L_TH_Attribute12     	,
	  L_TH_Attribute13     	,
	  L_TH_Attribute14     	,
	  L_TH_Attribute15     	,
	  L_Attribute_Category  ,
	  L_Attribute1     	,
	  L_Attribute2     	,
	  L_Attribute3     	,
	  L_Attribute4     	,
	  L_Attribute5     	,
	  L_Attribute6     	,
	  L_Attribute7     	,
	  L_Attribute8     	,
	  L_Attribute9     	,
	  L_Attribute10     	,
	  L_Attribute11     	,
	  L_Attribute12     	,
	  L_Attribute13     	,
	  L_Attribute14     	,
	  L_Attribute15	  	,               /* Bug 8483118(R12) and 8206076(11i) - Start */
	  L_Recognize_Gain_Loss                 ,
	  L_Recapture_Reserve_Flag              ,
	  L_Limit_Proceeds_Flag                 ,
	  L_Terminal_Gain_Loss                  /* Bug 8483118(R12) and 8206076(11i) - End */
   LIMIT l_batch_size;
   Close Mass_external_retirement;

   IF (g_log_level_rec.statement_level) then
      fa_debug_pkg.add('FACXTREMB.pls',
      'Before for loop, number of loops ',
       l_asset_id.count, p_log_level_rec => g_log_level_rec);
   END IF;


   if l_asset_id.count = 0 then
	raise done_exc;
   end if;

     -- clear the debug stack for each asset
     FA_DEBUG_PKG.Initialize;
     -- reset the message level to prevent bogus errors
     FA_SRVR_MSG.Set_Message_Level(message_level => 10, p_log_level_rec => g_log_level_rec);

   For i in 1..l_asset_id.count loop  -- mass_external_retirement
-- assign bulk to variables.

-- Print asset_number to logfile
     fa_srvr_msg.add_message(
        calling_fn => NULL,
        name       => 'FA_SHARED_ASSET_NUMBER',
        token1     => 'NUMBER',
        value1     => l_asset_number(i) , p_log_level_rec => g_log_level_rec);
     fa_srvr_msg.add_message(
        calling_fn => NULL,
        name       => 'FA_SHARED_ASSET_NUMBER',
        token1     => 'NUMBER',
        value1     => l_mass_external_retire_id(i), p_log_level_rec =>
g_log_level_rec );

     g_mass_external_retire_id := l_Mass_External_Retire_Id(i);
     g_book_type_code 	:= L_Book_Type_Code(i);
     g_batch_name	:= L_Batch_Name(i);
     g_asset_id 		:= L_Asset_Id(i);
     g_transaction_name	:= L_Transaction_Name(i);
     g_date_retired	:= L_Date_Retired(i);
     g_cost_retired	:= L_Cost_Retired(i);
     g_retirement_prorate_conv := L_Retirement_Prorate_Conv(i);
     g_units 		:= L_Units(i);
     g_cost_of_removal	:= L_Cost_Of_Removal(i);
     g_proceeds_of_sale	:= L_Proceeds_Of_Sale(i);
     g_retirement_type_code := L_Retirement_Type_Code(i);
     g_reference_num	:= L_Reference_Num(i);
     g_sold_to		:=  L_Sold_To(i);
     g_trade_in_asset_id	:= L_Trade_In_Asset_Id(i);
     g_calc_gain_loss_flag := L_Calc_Gain_Loss_Flag(i);
     g_stl_method_code	:= L_Stl_Method_Code(i);
     g_stl_life_in_months	:= L_Stl_Life_In_Months(i);
     g_stl_deprn_amount	:= L_Stl_Deprn_Amount(i);
     g_last_update_login	:= L_Last_Update_Login(i);
     g_today_datetime	:= L_Today_Datetime(i);
     g_currency_code	:=  L_Currency_Code(i);
     g_set_of_books_id	:= L_Set_of_Books_Id(i);
     g_current_units	:= L_Current_Units(i);
     g_asset_number	:= L_Asset_Number(i);
     g_period_counter_fully_retired := L_Period_Counter_Fully_Retired(i);
/* 8483118(R12) and 8206076(11i) - Start */
     g_recognize_gain_loss          := L_Recognize_Gain_Loss(i);
     g_recapture_reserve_flag       := L_Recapture_Reserve_Flag(i);
     g_limit_proceeds_flag          := L_Limit_Proceeds_Flag(i);
     g_terminal_gain_loss           := L_Terminal_Gain_Loss(i);
/* 8483118(R12) and 8206076(11i) - End */
     g_distribution_id  := L_Distribution_Id(i);
     g_code_combination_id := L_Code_combination_id(i);
     g_location_id		:= L_location_id(i);
     g_assigned_to		:= L_assigned_to(i);
     g_th_attribute_category := L_TH_Attribute_Category(i);
     g_th_attribute1 	:= L_TH_Attribute1(i);
     g_th_attribute2 	:=  L_TH_Attribute2(i);
     g_th_attribute3 	:=  L_TH_Attribute3(i);
     g_th_attribute4 	:=  L_TH_Attribute4(i);
     g_th_attribute5 	:=  L_TH_Attribute5(i);
     g_th_attribute6 	:=  L_TH_Attribute6(i);
     g_th_attribute7 	:=  L_TH_Attribute7(i);
     g_th_attribute8 	:=  L_TH_Attribute8(i);
     g_th_attribute9 	:=  L_TH_Attribute9(i);
     g_th_attribute10 	:=  L_TH_Attribute10(i);
     g_th_attribute11 	:=  L_TH_Attribute11(i);
     g_th_attribute12 	:=  L_TH_Attribute12(i);
     g_th_attribute13 	:=  L_TH_Attribute13(i);
     g_th_attribute14 	:=  L_TH_Attribute14(i);
     g_th_attribute15 	:=  L_TH_Attribute15(i);
     g_attribute_category 	:=  L_Attribute_Category(i);
     g_attribute1 	:=  L_Attribute1(i);
     g_attribute2 	:=  L_Attribute2(i);
     g_attribute3 	:=  L_Attribute3(i);
     g_attribute4 	:=  L_Attribute4(i);
     g_attribute5 	:=  L_Attribute5(i);
     g_attribute6 	:=  L_Attribute6(i);
     g_attribute7 	:=  L_Attribute7(i);
     g_attribute8 	:=  L_Attribute8(i);
     g_attribute9 	:=  L_Attribute9(i);
     g_attribute10 	:=  L_Attribute10(i);
     g_attribute11 	:=  L_Attribute11(i);
     g_attribute12 	:=  L_Attribute12(i);
     g_attribute13 	:=  L_Attribute13(i);
     g_attribute14 	:=  L_Attribute14(i);
     g_attribute15 	:=  L_Attribute15(i);

   IF (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('FACXTREMB.pls',
	       'Before Validation subblock: asset_id',
	        g_asset_id, p_log_level_rec => g_log_level_rec);
   END IF;

-- test if muliple partial unit retirements with same batch and asset.
-- declare:



   Begin
--  validation subblock to stay in loop if failure

      if (g_asset_id <> g_prev_asset_id or
		g_batch_name <> g_prev_batch_name) then





	select count(*)
	into g_num_of_distributions
	from fa_mass_ext_retirements
	where batch_name = G_batch_name
	and   review_status = 'POST'
	and   asset_id   = g_asset_id
	and   code_combination_id is not null
	and   mass_external_retire_id <> g_mass_external_retire_id;


	IF (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('FACXTREMB.pls',
	       'g_num_of_distributiosn:',
	        g_num_of_distributions , p_log_level_rec => g_log_level_rec);

	end if;

	g_single_dist_array := 'NO';

       	select count(*)
	into g_num_of_identical
	from fa_mass_ext_retirements
	where batch_name = G_batch_name
	and   review_status = 'POST'
	and   asset_id   = g_asset_id
	and   code_combination_id is not null;

	if g_num_of_identical > 0 then
-- note, make this select fault tolerant, i.e. explicit cursor.

		open c_dhident;
		fetch c_dhident into g_test_ident_distributions;
		close c_dhident;

		if g_test_ident_distributions > 0 then
			g_single_dist_array := 'YES';
		end if;

	IF (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('FACXTREMB.pls',
	       'g_single_dist_array:',
	        g_single_dist_array , p_log_level_rec => g_log_level_rec);
	end if;


	end if;
-- end test

-- Deleting table only when changing asset, also when changing batch...?
        l_asset_dist_tbl.delete;

	IF (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('FACXTREMB.pls',
	       'Number of distributions:',
	        g_num_of_distributions, p_log_level_rec => g_log_level_rec);
               fa_debug_pkg.add('FACXTREMB.pls',
	       'test ident distributions:',
	        g_test_ident_distributions, p_log_level_rec => g_log_level_rec);

   	END IF;

      end if;

      if(nvl(g_period_counter_fully_retired,0) > 0)  then
	    lv_app:= 'OFA';
	    lv_message := 'FA_REC_RETIRED';
	    raise Fully_Reserved_Error;
      end if;


-- bug 1857395
-- While ccid and location_id are mandatory in fa_distribution_history;
-- if any of these two are entered; both must be.

      If nvl(G_Distribution_Id,0) = 0  then
	   If (nvl(G_Code_Combination_Id,0) <> 0
		and nvl(G_Location_Id,0) <> 0 ) then

-- Derive distribution_id,

		open c_dh;
		fetch c_dh into dhrec;

		If c_dh%NOTFOUND then
		   close c_dh;

		   lv_app:= 'CUA';
		   lv_message := 'CUA_MAP_DISTRIBUTION';
		   raise validation_error;
		end if;
		close c_dh;
-- Perform distribution validation here.

 		if dhrec.units_assigned < g_units then
		    lv_app:= 'OFA';
		    lv_message := 'FA_RET_UNITS_TOO_BIG';
		     raise validation_error;
		end if;
		if dhrec.date_ineffective is not null then
		    lv_app:= 'OFA';
		    lv_message := 'FA_RBL_DIST';
		    raise validation_error;
		end if;
 		if  g_units < 1 then
		    lv_app:= 'OFA';
		    lv_message := 'FA_TFR_NONZERO';
		    raise validation_error;
		end if;

	        g_distribution_id  := dhrec.distribution_id;

-- bug 1857395 - validation.
	      elsif 	(nvl(G_Code_Combination_Id,0) <> 0
			and nvl(G_Location_Id,0) = 0 )  then
			     lv_app:= 'CUA';
			     lv_message := 'CUA_INVALID_LOCATION';
			     raise validation_error;

	      elsif	(nvl(G_Code_Combination_Id,0) = 0
			and nvl(G_Location_Id,0) <> 0 ) then
			     lv_app:= 'CUA';
			     lv_message := 'CUA_INVALID_EXPENSE_ACCOUNT';
			     raise validation_error;
	      else
		 null;
	      end if;

       end if; -- if distribution_id null

	IF (g_log_level_rec.statement_level) then
       fa_debug_pkg.add('FACXTREMB.pls',
      'Before validate call mass_ext_ret_id ',
       g_mass_external_retire_id, p_log_level_rec => g_log_level_rec);
   END IF;

-- modified and added additional logic for bugfix 2036777

   IF (g_log_level_rec.statement_level) then
      fa_debug_pkg.add('FACXTREMB.pls',
      'Before source line retirement loop: lv_new_inv_txn_id',
      lv_new_inv_txn_id, p_log_level_rec => g_log_level_rec);
   END IF;


    k := 0;
    l_inv_tbl.delete;
    For Source_lines_rec in Source_lines_C Loop

       IF (g_log_level_rec.statement_level) then
           fa_debug_pkg.add('FACXTREMB.pls',
          'In source line retirement loop:',
	   source_lines_rec.source_line_id, p_log_level_rec => g_log_level_rec);
       END IF;

       k := k +1;

       OPEN C3( Source_lines_rec.source_line_id);
       FETCH C3 into C3_lines;
       if C3%NOTFOUND then
          lv_app:= 'CUA';
	  lv_message := 'CUA_INVALID_SOURCE_LINE_ID';
          CLOSE C3;
	  raise validation_error;
        end if;
        CLOSE C3;

-- Populate inv_rec here...

-- ***** Invoice Info ***** --

      IF (g_log_level_rec.statement_level) then
          fa_debug_pkg.add('FACXTREMB.pls',
          'In source line loop 2: c3_lines.slid',
          c3_lines.source_line_id, p_log_level_rec => g_log_level_rec);
      END IF;
-- Use  C3_lines.Source_Line_ID, due to bug 2036777
--      l_inv_rec.source_line_id := source_lines_rec.source_line_id;

     l_inv_rec.source_line_id := C3_lines.source_line_id;
     If source_lines_rec.cost_retired > 0 then
        l_inv_rec.fixed_assets_cost := source_lines_rec.cost_retired * -1;
     else
        l_inv_rec.fixed_assets_cost := source_lines_rec.cost_retired;
     end if;
     l_inv_rec.inv_indicator := k;

     update fa_ext_inv_retirements
     set source_line_id_retired = l_inv_rec.source_line_id
     where source_line_id = l_inv_rec.source_line_id;

     l_inv_tbl(k) := l_inv_rec;

   end loop;

   IF (g_log_level_rec.statement_level) then
       fa_debug_pkg.add('FACXTREMB.pls',
       'Before loading arrays: Transaction_name ',
       g_transaction_name, p_log_level_rec => g_log_level_rec);
   END IF;

-- Load array structures before calling do_retirement
   -- ***** Asset Transaction Info ***** --
-- activate when mass_transaction_id exists in trans_rec.
-- mass_transaction_id only populated where we have a prim-foreign key relation
   IF (g_log_level_rec.statement_level) then
      fa_debug_pkg.add('FACXTREMB.pls',
      'Loading arrays: g_Batch_name ',
      g_batch_name, p_log_level_rec => g_log_level_rec);
   END IF;



   if substr(g_batch_name,1,8) = 'MASSRET-' then
      l_trans_rec.mass_transaction_id := to_number(substr(g_batch_name,9,30));
   end if;

    IF (g_log_level_rec.statement_level) then
      fa_debug_pkg.add('FACXTREMB.pls',
      'Loading arrays: Mass trx id ',
      l_trans_rec.mass_transaction_id, p_log_level_rec => g_log_level_rec);
    END IF;

   l_trans_rec.transaction_header_id := ''; -- will get assigned in do_retirement
   l_trans_rec.transaction_type_code := '';			 -- " --
   l_trans_rec.transaction_date_entered := g_date_retired;
   l_trans_rec.transaction_name := g_transaction_name;
   l_trans_rec.source_transaction_header_id :=  '';		 -- " --
   l_trans_rec.mass_reference_id := P_PARENT_REQUEST_ID;
   l_trans_rec.transaction_subtype := '';  -- will get assigned in do_retirem
   l_trans_rec.transaction_key := '';   			 -- " --
   l_trans_rec.amortization_start_date := '';			 -- " --
   l_trans_rec.calling_interface := g_calling_interface;
   l_trans_rec.desc_flex.attribute1 := g_th_attribute1;
   l_trans_rec.desc_flex.attribute2 := g_th_attribute2;
   l_trans_rec.desc_flex.attribute3 := g_th_attribute3;
   l_trans_rec.desc_flex.attribute4 := g_th_attribute4;
   l_trans_rec.desc_flex.attribute5 := g_th_attribute5;
   l_trans_rec.desc_flex.attribute6 := g_th_attribute6;
   l_trans_rec.desc_flex.attribute7 := g_th_attribute7;
   l_trans_rec.desc_flex.attribute8 := g_th_attribute8;
   l_trans_rec.desc_flex.attribute9 := g_th_attribute9;
   l_trans_rec.desc_flex.attribute10 := g_th_attribute10;
   l_trans_rec.desc_flex.attribute11 := g_th_attribute11;
   l_trans_rec.desc_flex.attribute12 := g_th_attribute12;
   l_trans_rec.desc_flex.attribute13 := g_th_attribute13;
   l_trans_rec.desc_flex.attribute14 := g_th_attribute14;
   l_trans_rec.desc_flex.attribute15 := g_th_attribute15;
   l_trans_rec.desc_flex.attribute_category_code :=
      g_th_attribute_category;
   l_trans_rec.who_info.last_update_date := G_Today_Datetime;
   l_trans_rec.who_info.last_updated_by :=  G_Created_By;
   l_trans_rec.who_info.created_by := G_created_by;
   l_trans_rec.who_info.creation_date := G_Today_Datetime;
   l_trans_rec.who_info.last_update_login := G_last_update_login;

   -- ***** Distribution Transaction Info ***** --

   l_dist_trans_rec.transaction_header_id := ''; -- get assigned in do_retirem.
   l_dist_trans_rec.transaction_date_entered := g_date_retired;
   l_dist_trans_rec.transaction_name := g_transaction_name;
   l_dist_trans_rec.calling_interface := g_calling_interface;
-- No dist desc flex
   l_dist_trans_rec.desc_flex.attribute1 := g_th_attribute1;
   l_dist_trans_rec.desc_flex.attribute2 := g_th_attribute2;
   l_dist_trans_rec.desc_flex.attribute3 := g_th_attribute3;
   l_dist_trans_rec.desc_flex.attribute4 := g_th_attribute4;
   l_dist_trans_rec.desc_flex.attribute5 := g_th_attribute5;
   l_dist_trans_rec.desc_flex.attribute6 := g_th_attribute6;
   l_dist_trans_rec.desc_flex.attribute7 := g_th_attribute7;
   l_dist_trans_rec.desc_flex.attribute8 := g_th_attribute8;
   l_dist_trans_rec.desc_flex.attribute9 := g_th_attribute9;
   l_dist_trans_rec.desc_flex.attribute10 := g_th_attribute10;
   l_dist_trans_rec.desc_flex.attribute11 := g_th_attribute11;
   l_dist_trans_rec.desc_flex.attribute12 := g_th_attribute12;
   l_dist_trans_rec.desc_flex.attribute13 := g_th_attribute13;
   l_dist_trans_rec.desc_flex.attribute14 := g_th_attribute14;
   l_dist_trans_rec.desc_flex.attribute15 := g_th_attribute15;
   l_dist_trans_rec.desc_flex.attribute_category_code := g_th_attribute_category;
--
   l_dist_trans_rec.who_info.last_update_date := G_Today_Datetime;
   l_dist_trans_rec.who_info.last_updated_by :=  G_Created_By;
   l_dist_trans_rec.who_info.created_by := G_created_by;
   l_dist_trans_rec.who_info.creation_date := G_Today_Datetime;
   l_dist_trans_rec.who_info.last_update_login := G_last_update_login;

   -- ***** Asset Header Info ***** --
   l_asset_hdr_rec.asset_id        := G_asset_id;
   l_asset_hdr_rec.book_type_code  := G_book_type_code;

   -- Derive set of books id for primary book
   l_asset_hdr_rec.set_of_books_id := G_set_of_books_id;

   IF (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('FACXTREMB.pls',
	       'Before loading Retirement1 arrays: cost_retired ',
	       g_cost_retired, p_log_level_rec => g_log_level_rec);
               fa_debug_pkg.add('FACXTREMB.pls',
	       'Before loading Retirement1 arrays: units_retired ',
	       g_units, p_log_level_rec => g_log_level_rec);
   END IF;

   -- ***** Asset Retirement Info ***** --
   l_asset_retire_rec.retirement_id := '';
   l_asset_retire_rec.date_retired := g_date_retired;
   l_asset_retire_rec.units_retired := g_units;
   l_asset_retire_rec.cost_retired := g_cost_retired;
   l_asset_retire_rec.proceeds_of_sale := g_proceeds_of_sale;
   l_asset_retire_rec.cost_of_removal := g_cost_of_removal;
   l_asset_retire_rec.retirement_type_code := g_retirement_type_code;
   l_asset_retire_rec.retirement_prorate_convention := g_retirement_prorate_conv;
   l_asset_retire_rec.detail_info.stl_method_code := g_stl_method_code;
   l_asset_retire_rec.detail_info.stl_life_in_months := g_stl_life_in_months;
   l_asset_retire_rec.sold_to := g_sold_to;
   l_asset_retire_rec.trade_in_asset_id := g_trade_in_asset_id;
   l_asset_retire_rec.status := 'PENDING';
   l_asset_retire_rec.reference_num := g_reference_num;
-- this parameter gives an option to run gain/loss right after the transaction.
-- retirement api is using fnd_api.g_true/g_false
-- converting potential Y and N to fnd_api.g_true/g_false.
--
   if g_calc_gain_loss_flag in ('Y','YES') then
      g_calc_gain_loss_flag := fnd_api.g_true;
   elsif g_calc_gain_loss_flag in ('N','NO') then
      g_calc_gain_loss_flag := fnd_api.g_false;
   end if;
   l_asset_retire_rec.calculate_gain_loss := g_calc_gain_loss_flag;
   l_asset_retire_rec.desc_flex.attribute1 := g_attribute1;
   l_asset_retire_rec.desc_flex.attribute2 := g_attribute2;
   l_asset_retire_rec.desc_flex.attribute3 := g_attribute3;
   l_asset_retire_rec.desc_flex.attribute4 := g_attribute4;
   l_asset_retire_rec.desc_flex.attribute5 := g_attribute5;
   l_asset_retire_rec.desc_flex.attribute6 := g_attribute6;
   l_asset_retire_rec.desc_flex.attribute7 := g_attribute7;
   L_asset_retire_rec.desc_flex.attribute8 := g_attribute8;
   l_asset_retire_rec.desc_flex.attribute9 := g_attribute9;
   l_asset_retire_rec.desc_flex.attribute10 := g_attribute10;
   l_asset_retire_rec.desc_flex.attribute11 := g_attribute11;
   l_asset_retire_rec.desc_flex.attribute12 := g_attribute12;
   l_asset_retire_rec.desc_flex.attribute13 := g_attribute13;
   l_asset_retire_rec.desc_flex.attribute14 := g_attribute14;
   l_asset_retire_rec.desc_flex.attribute15 := g_attribute15;
   l_asset_retire_rec.desc_flex.attribute_category_code :=
      g_attribute_category;
/* Bug 8483118(R12) and 8206076(11i) - Start */
   l_asset_retire_rec.recognize_gain_loss    := g_recognize_gain_loss;
   l_asset_retire_rec.recapture_reserve_flag := g_recapture_reserve_flag;
   l_asset_retire_rec.limit_proceeds_flag    := g_limit_proceeds_flag;
   l_asset_retire_rec.terminal_gain_loss     := g_terminal_gain_loss;
/* Bug 8483118(R12) and 8206076(11i) - End */

   IF (g_log_level_rec.statement_level) then
      fa_debug_pkg.add('FACXTREMB.pls',
      'Before loading dist arrays g_units',
      g_units, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add('FACXTREMB.pls',
      'Before loading dist arrays g_current_units',
      g_current_units, p_log_level_rec => g_log_level_rec);
   END IF;


-- The dist info should only be loaded when partial unit retirement.

   if ( nvl(G_Units,0) <> 0 and G_Units < G_current_units) then
   -- ***** Asset Distribution Info ***** --
        IF (g_log_level_rec.statement_level) then
             fa_debug_pkg.add('FACXTREMB.pls',
              'Before loading dist arrays inside if',
              g_current_units, p_log_level_rec => g_log_level_rec);
        END IF;



	if (g_asset_id <> g_prev_asset_id or g_batch_name <> g_prev_batch_name) OR
	(	g_single_dist_array = 'YES' ) then
	   num_dist := 1;
	else
	   num_dist := num_dist + 1;
	end if;


        l_asset_dist_rec.units_assigned    := NULL;

        if g_units >= 0 then
          l_asset_dist_rec.transaction_units := g_units * -1;
        else
          l_asset_dist_rec.transaction_units := g_units;
        end if;
        l_asset_dist_rec.assigned_to       := g_assigned_to;
        l_asset_dist_rec.expense_ccid      := g_code_combination_id;
        l_asset_dist_rec.location_ccid     := g_location_id;
-- fails if distribution_id is null.
        l_asset_dist_rec.distribution_id   := g_distribution_id;
        l_asset_dist_tbl(num_dist)   	   := l_asset_dist_rec;

      IF (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('FACXTREMB.pls',
         'Before loading dist arrays inside if',
    	num_dist, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add('FACXTREMB.pls',
         'Before loading dist arrays inside if',
    	g_distribution_id, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add('FACXTREMB.pls',
         'Before loading dist arrays inside if',
    	g_location_id, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add('FACXTREMB.pls',
         'Before loading dist arrays inside if',
    	g_code_combination_id, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add('FACXTREMB.pls',
         'Before loading dist arrays inside if',
    	l_asset_dist_rec.transaction_units, p_log_level_rec => g_log_level_rec);
      END IF;

   end if;

   l_tot_units := 0;
   for dist_i in 1 .. l_asset_dist_tbl.COUNT loop

         l_tot_units := l_tot_units + abs(l_asset_dist_tbl(dist_i).transaction_units);
         l_asset_retire_rec.units_retired := l_tot_units;

   end loop;

   if l_tot_units = g_current_units then
       l_asset_retire_rec.units_retired := l_tot_units;
       l_asset_dist_tbl.delete;
   end if;


   l_subcomp_tbl.delete;

-- l_init_msg_list should be set to false
   -- Call Public Retirement API

   if (g_num_of_distributions = 0)  OR (g_single_dist_array = 'YES') then

      IF (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('FACXTREMB.pls',
         'Before do_retirement call ',
         G_Asset_Number, p_log_level_rec => g_log_level_rec);
      END IF;


      fa_retirement_pub.do_retirement
        (p_api_version               => l_api_version,
         p_init_msg_list             => l_init_msg_list,
         p_commit                    => l_commit,
         p_validation_level          => l_validation_level,
         p_calling_fn                => l_calling_fn,
         x_return_status             => l_return_status,
         x_msg_count                 => l_msg_count,
         x_msg_data                  => x_msg_data,
         px_trans_rec                => l_trans_rec,
         px_dist_trans_rec           => l_dist_trans_rec,
         px_asset_hdr_rec            => l_asset_hdr_rec,
         px_asset_retire_rec         => l_asset_retire_rec,
         p_asset_dist_tbl            => l_asset_dist_tbl,
         p_subcomp_tbl               => l_subcomp_tbl,
         p_inv_tbl                   => l_inv_tbl);

      IF (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('FACXTREMB.pls',
         'After do_retirement call, status',
          l_return_status, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add('FACXTREMB.pls',
	 'After do_retirement call, msg_count',
	  l_msg_count, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add('FACXTREMB.pls',
	 'After do_retirement call, x_msg_data',
	  x_msg_data, p_log_level_rec => g_log_level_rec);

      END IF;


     if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
	  raise G_Subroutine_Fail;
     else
         G_success_count := G_success_count + 1;
         x_success_count := x_success_count + 1;
     end if;
     if (g_single_dist_array = 'YES') then
	l_asset_dist_tbl.delete;
     end if;

-- test
-- probably not necessary to reduce	if  g_test_ident_distributions
   elsif g_num_of_distributions > 0 then
         g_num_of_distributions := g_num_of_distributions - 1;
         G_success_count := G_success_count + 1;
         x_success_count := x_success_count + 1;

      IF (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('FACXTREMB.pls',
         'Skipped do_retirement call ',
         g_num_of_distributions, p_log_level_rec => g_log_level_rec);
      END IF;

   end if; -- num_of_distribution

   UPDATE fa_mass_Ext_retirements
   SET review_status = 'POSTED',
     --   bugfix 2442439 retirement_id = lv_ret_id
          retirement_id = l_asset_retire_rec.retirement_id,
          last_update_date  = sysdate,
          last_updated_by   = fnd_global.user_id,
          last_update_login = fnd_global.login_id
   WHERE mass_external_retire_id = G_Mass_External_Retire_Id;

   Commit;

   write_message
       	(p_asset_number    => g_asset_number,
	       p_book_type_code  => g_book_type_code,
	       p_mass_external_retire_id => g_mass_external_retire_id,
          p_message         => 'FA_MCP_RETIRE_SUCCESS',
          p_token           => '',
          p_value           => '',
       	 p_app_short_name  => 'OFA',
      	 p_db_error 	    => '',
          p_mode            => 'S');

Exception
 WHEN G_Subroutine_Fail THEN

      if (g_log_level_rec.statement_level) then
        fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;

      UPDATE fa_mass_Ext_retirements
      SET review_status = 'ERROR',
          last_update_date  = sysdate,
          last_updated_by   = fnd_global.user_id,
          last_update_login = fnd_global.login_id
      WHERE mass_external_retire_id = G_Mass_External_Retire_Id;

      -- non-fatal
      write_message(
             p_asset_number    => g_asset_number,
	     p_book_type_code  => g_book_type_code,
	     p_mass_external_retire_id => g_mass_external_retire_id,
	     p_message         => 'FA_POST_MASSRET_FAILURE',
	     p_token           => '',
	     p_value           => '',
             p_app_short_name  => 'OFA',
             p_db_error 	    => '',
	     p_mode            => 'W');

      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
--    x_return_status :=  FND_API.G_RET_STS_ERROR;

       FND_CONCURRENT.AF_COMMIT;
       x_return_status := 1;

 WHEN Validation_Error THEN

      FND_CONCURRENT.AF_ROLLBACK;
      if(g_log_level_rec.statement_level) then
        fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;

      UPDATE fa_mass_Ext_retirements
      SET review_status = 'ERROR',
          last_update_date  = sysdate,
          last_updated_by   = fnd_global.user_id,
          last_update_login = fnd_global.login_id
      WHERE mass_external_retire_id = G_Mass_External_Retire_Id;


      if lv_message = '' then
        write_message(
          p_asset_number    => g_asset_number,
          p_book_type_code  => g_book_type_code,
          p_mass_external_retire_id => g_mass_external_retire_id,
          p_message         => 'FA_POST_MASSRET_FAILURE',
          p_token           => '',
          p_value           => '',
          p_app_short_name  => 'OFA',
          p_db_error 	    => '',
          p_mode            => 'W');

      else
        write_message(
          p_asset_number    => g_asset_number,
          p_book_type_code  => g_book_type_code,
          p_mass_external_retire_id => g_mass_external_retire_id,
          p_message         => lv_message,
	  p_token           => '',
          p_value           => '',
          p_app_short_name  => lv_app,
          p_db_error 	    => '',
          p_mode            => 'W');

      end if;
        FND_CONCURRENT.AF_COMMIT;
        x_return_status := 1;

 WHEN Fully_Reserved_Error THEN

      FND_CONCURRENT.AF_ROLLBACK;
      if(g_log_level_rec.statement_level) then
        fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;

      UPDATE fa_mass_Ext_retirements
      SET review_status = 'ERROR',
          last_update_date  = sysdate,
          last_updated_by   = fnd_global.user_id,
          last_update_login = fnd_global.login_id
      WHERE mass_external_retire_id = G_Mass_External_Retire_Id;

      write_message(
        p_asset_number    => g_asset_number,
        p_book_type_code  => g_book_type_code,
        p_mass_external_retire_id => g_mass_external_retire_id,
        p_message         => 'FA_REC_RETIRED',
        p_token           => '',
        p_value           => '',
        p_app_short_name  => 'OFA',
        p_db_error 	    => '',
        p_mode            => 'W');

        FND_CONCURRENT.AF_COMMIT;
        x_return_status := 1;


   WHEN OTHERS THEN

        FND_CONCURRENT.AF_COMMIT;

        if(g_log_level_rec.statement_level) then
          fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
        end if;

        UPDATE fa_mass_Ext_retirements
        SET review_status = 'ERROR',
            last_update_date  = sysdate,
            last_updated_by   = fnd_global.user_id,
            last_update_login = fnd_global.login_id
        WHERE mass_external_retire_id = G_Mass_External_Retire_Id;

        write_message(
          p_asset_number    => g_asset_number,
          p_book_type_code  => g_book_type_code,
          p_mass_external_retire_id => g_mass_external_retire_id,
          p_message         => '',
          p_token           => '',
          p_value           => '',
          p_app_short_name  => lv_message,
          p_db_error 	    => SQLCODE,
          p_mode            => 'W');

        FND_CONCURRENT.AF_COMMIT;
        x_return_status := 1;

    End; /* validation subblock ends */

    g_prev_asset_id := g_asset_id;
    g_prev_batch_name	:= g_batch_name;
  END LOOP; -- mass_external_retirement

  -- set the max id

  px_max_mass_ext_retire_id := l_mass_external_retire_id
                                 (l_mass_external_retire_id.count);
  px_batch_name   := l_batch_name(l_batch_name.count);

  x_failure_count := G_failure_count;
  x_success_count := G_success_count;
  x_return_status := 0;



  if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'px_max_mass_ext_retire_id', px_max_mass_ext_retire_id, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'End of Mass External Retirement session',				x_return_status, p_log_level_rec => g_log_level_rec);
  end if;

  if (g_log_level_rec.statement_level) then
      fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
  end if;


EXCEPTION -- Mass_Ext_Retire

  WHEN done_exc then
        x_success_count := G_success_count;
        x_failure_count := G_failure_count;
	x_return_status := 0;
        FND_CONCURRENT.AF_COMMIT;

        if (g_log_level_rec.statement_level) then
           fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
        end if;

  -- msiddiqu  Feb-24-2001
  WHEN pending_batch THEN

    FND_CONCURRENT.AF_COMMIT;

    UPDATE fa_mass_Ext_retirements
    SET review_status = 'ERROR',
        last_update_date  = sysdate,
        last_updated_by   = fnd_global.user_id,
        last_update_login = fnd_global.login_id
    WHERE batch_name  = nvl(px_batch_name,batch_name)
    AND   book_type_code   = p_book_type_code;

    write_message(
      p_asset_number    => g_asset_number,
      p_book_type_code  => g_book_type_code,
      p_mass_external_retire_id => g_mass_external_retire_id,
      p_message         => lv_message,
      p_token           => '',
      p_value           => '',
      p_app_short_name  => lv_app,
      p_db_error 	=> '',
      p_mode            => 'W');

      x_success_count := G_success_count;
      x_failure_count := G_failure_count;

  -- end of modification msiddiqu  Feb-24-2001
     FND_CONCURRENT.AF_COMMIT;
     x_return_status := 2;

     if (g_log_level_rec.statement_level) then
        fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
     end if;


  WHEN Init_problem THEN

    FND_CONCURRENT.AF_COMMIT;

    write_message(
      p_asset_number    => g_asset_number,
      p_book_type_code  => g_book_type_code,
      p_mass_external_retire_id => g_mass_external_retire_id,
      p_message         => '',
      p_token           => '',
      p_value           => '',
      p_app_short_name  => 'When Init_problem Exception in Mass_Ext_Retire',
      p_db_error 	      => '',
      p_mode            => 'F');

      x_success_count := G_success_count;
      x_failure_count := G_failure_count;

      x_return_status := 2;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;


  WHEN Others THEN

   FND_CONCURRENT.AF_COMMIT;

    write_message(
      p_asset_number    => g_asset_number,
      p_book_type_code  => g_book_type_code,
      p_mass_external_retire_id => g_mass_external_retire_id,
      p_message         => '',
      p_token           => '',
      p_value           => '',
      p_app_short_name  => 'When Others Exception in Mass_Ext_Retire',
      p_db_error 	=> '',
      p_mode            => 'F');

      x_success_count := G_success_count;
      x_failure_count := G_failure_count;

      x_return_status := 2;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
      end if;


END Mass_Ext_Retire;

------------------------------------------------------------------------------
PROCEDURE Purge(ERRBUF   OUT NOCOPY VARCHAR2,
                RETCODE  OUT NOCOPY VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS

Cursor Assets_C is
  select Mass_External_Retire_ID
  from fa_mass_ext_retirements
  where review_status in ('DELETE','POSTED')
  for update nowait;

LV_Mass_External_Retire_ID	NUMBER;
LV_Inv_Count	NUMBER;

BEGIN
	Open Assets_C;

	Loop
		Fetch Assets_C into LV_Mass_External_Retire_ID;
		Exit when Assets_C%NOTFOUND;

		Select count(*) into LV_Inv_Count
		from fa_ext_inv_retirements
		where mass_external_retire_id = LV_Mass_External_Retire_ID;

		if LV_Inv_Count > 0 then
			Delete from fa_ext_inv_retirements
			where mass_external_retire_id = LV_Mass_External_Retire_ID;
		end if;

		Delete from fa_mass_ext_retirements
		where mass_external_retire_id = LV_Mass_External_Retire_ID;

	End Loop;

	Close Assets_C;

EXCEPTION
	When NO_DATA_FOUND Then
		Return;
  	WHEN OTHERS THEN
    		errbuf :=  substr(SQLERRM(SQLCODE), 1,200);
    		retcode := SQLCODE;
    		return;
END Purge;


----------------------------------
-- this is used to maintaint the old execution report seperately
-- from the log.  Only the main message will be dumped to out file.
-- all messaging and debug will be demped to the log file

PROCEDURE write_message(
          p_asset_number  			   in varchar2,
          p_book_type_code 		   in varchar2,
          p_mass_external_retire_id	in number,
          p_message         		   in varchar2,
          p_token           		   in varchar2,
          p_value           		   in varchar2,
          p_app_short_name          in varchar2,
          p_db_error                in number,
          p_mode            		   in varchar2 ) IS

l_book_type_code 			varchar2(30);
l_asset_number 			varchar2(15);
l_mass_external_retire_id         	varchar2(20);
l_mesg         			varchar2(512);
l_string       			varchar2(512);
l_calling_fn   			varchar2(40);

BEGIN

if p_mode = 'S' then
   -- first dump the message to the output file
   -- set/translate/retrieve the mesg from fnd


   FND_MESSAGE.SET_NAME(p_app_short_name, p_message);
   l_mesg := substrb(FND_MESSAGE.GET,1,100);
   l_asset_number := rpad(p_asset_number, 15);
   l_mass_external_retire_id  := rpad(to_char(p_mass_external_retire_id), 18);

   l_string := l_mass_external_retire_id || ' ' || l_asset_number || ' ' ||
		l_mesg;



   FND_FILE.put(FND_FILE.output,l_string);
   FND_FILE.new_line(FND_FILE.output,1);

else
   G_failure_count := G_failure_count + 1;

-- only pass calling_fn for failures
   if p_mode = 'F' then
--      l_calling_fn  := 'fa_cua_mass_ret_pkg';
      G_fatal_error := TRUE;
   end if;

-- ex. x_app_name = CUA
--     x_app_error = The message name.
   IF ( p_app_short_name is not null and
        p_message is not null) then
	  FND_MESSAGE.SET_NAME(p_app_short_name, p_message);
	  if p_token is not null then
            fnd_message.set_token(p_token, p_value);
   	  end if;
          l_mesg := substrb(FND_MESSAGE.GET,1,100);
   ELSIF p_db_error is not null then
      l_mesg := substrb(SQLERRM(p_db_error),1,100);
   ELSE
      l_mesg := substrb(p_app_short_name,1,100);
   END IF;

   -- first dump the message to the output file
   -- set/translate/retrieve the mesg from fnd

   l_asset_number := rpad(p_asset_number, 15);
   l_book_type_code := rpad(p_book_type_code,15);
   l_mass_external_retire_id  := rpad(to_char(p_mass_external_retire_id), 18);

   l_string := l_mass_external_retire_id||' '||l_asset_number||' '||l_mesg;

   FND_FILE.put(FND_FILE.output,l_string);
   FND_FILE.new_line(FND_FILE.output,1);

-- Asset number now printed in beginning of main loop
-- 1/ Print asset_number to logfile
--   if l_asset_number is not null then
--     fa_srvr_msg.add_message(
--        calling_fn => l_calling_fn,
--        name       => 'FA_SHARED_ASSET_NUMBER',
--        token1     => 'NUMBER',
--        value1     => l_asset_number, p_log_level_rec => p_log_level_rec);
--   end if;

-- 2/ Print message
   if p_message is not null then
      fa_srvr_msg.add_message
         (calling_fn => l_calling_fn,
          name       => p_message,
          token1     => p_token,
          value1     => p_value, p_log_level_rec => g_log_level_rec);
   end if;
end if;

EXCEPTION
   when others then
       raise;
END ;

END FA_CUA_MASS_EXT_RET_PKG;

/
