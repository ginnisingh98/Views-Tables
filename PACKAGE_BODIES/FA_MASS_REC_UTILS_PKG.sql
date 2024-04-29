--------------------------------------------------------
--  DDL for Package Body FA_MASS_REC_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASS_REC_UTILS_PKG" AS
/* $Header: FAXMRUTB.pls 120.3.12010000.2 2009/07/19 14:06:03 glchen ship $ */


/*====================================================================================+
|   PROCEDURE Convert_Formats                                                         |
+=====================================================================================*/

PROCEDURE Convert_Formats(
	X_Life_In_Months	IN	NUMBER := NULL,
	X_Basic_Rate		IN	NUMBER := NULL,
	X_Adjusted_Rate		IN	NUMBER := NULL,
	X_Allowed_Deprn_Limit	IN	NUMBER := NULL,
	X_Percent_Salvage_Val	IN	NUMBER := NULL,
	X_Life		 OUT NOCOPY VARCHAR2,
	X_Basic_Rate_Pct OUT NOCOPY NUMBER,
	X_Adjusted_Rate_Pct OUT NOCOPY NUMBER,
	X_Deprn_Limit_Pct OUT NOCOPY NUMBER,
	X_Salvage_Val_Pct OUT NOCOPY NUMBER
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
BEGIN
    IF X_Life_In_Months IS NOT NULL THEN
	X_Life := lpad(to_char(trunc(X_Life_In_Months/12)), 3)||'.'||
		  substr(to_char(mod(X_Life_In_Months, 12), '00'), 2, 2);
	-- Need to get the substring from the second position, since
	-- to_char conversion with the format, always attaches extra space
	-- at the beginning of the string.
    ELSE
	X_Life := NULL;
    END IF;

    IF X_Basic_Rate IS NOT NULL THEN
	X_Basic_Rate_Pct := round(X_Basic_Rate*100, 2);
    /* May use the following format in report output:
	substr(to_char(round(X_Basic_Rate*100, 2), '999.99'), 2, 6) or
	lpad(to_char(round(X_Basic_Rate*100, 2)), 6) */
    ELSE
	X_Basic_Rate_Pct := NULL;
    END IF;

    IF X_Adjusted_Rate IS NOT NULL THEN
	X_Adjusted_Rate_Pct := round(X_Adjusted_Rate*100, 2);
    ELSE
	X_Adjusted_Rate_Pct := NULL;
    END IF;

    IF X_Allowed_Deprn_Limit IS NOT NULL THEN
	X_Deprn_Limit_Pct := round(X_Allowed_Deprn_limit*100, 2);
    ELSE
	X_Deprn_Limit_Pct := NULL;
    END IF;

    IF X_Percent_Salvage_Val IS NOT NULL THEN
	X_Salvage_Val_Pct := round(X_Percent_Salvage_Val*100, 2);
    ELSE
	X_Salvage_Val_Pct := NULL;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
	FA_SRVR_MSG.Add_SQL_Error(
                CALLING_FN => 'FA_MASS_REC_UTILS_PKG.Convert_Formats',  p_log_level_rec => p_log_level_rec);
	raise;  -- raise the exception.
END Convert_Formats;


/*====================================================================================+
|   PROCEDURE Load_Conversion_Table                                                   |
+=====================================================================================*/

PROCEDURE Load_Conversion_Table (p_log_level_rec        IN
FA_API_TYPES.log_level_rec_type) IS
    load_exc 		EXCEPTION;
    h_life_in_months	NUMBER(4);
    h_basic_rate	NUMBER;
    h_adjusted_rate	NUMBER;
    h_allowed_deprn_limit NUMBER;
    h_percent_salvage_val NUMBER;
BEGIN
    IF (FA_LOAD_TBL_PKG.g_deprn_count = 0) THEN
    -- deprn_table is not loaded.  deprn_table has to be loaded first.
	raise load_exc;
    END IF;

    -- Initialize conversion_table.
    conv_tbl.delete;

    FOR i IN FA_LOAD_TBL_PKG.deprn_table.FIRST .. FA_LOAD_TBL_PKG.deprn_table.LAST
    LOOP
	IF FA_LOAD_TBL_PKG.deprn_table.exists(i) THEN
	-- Load into exactly same matching index postion.
	    conv_tbl(i).book_type_code := FA_LOAD_TBL_PKG.deprn_table(i).book_type_code;
	    conv_tbl(i).start_dpis := FA_LOAD_TBL_PKG.deprn_table(i).start_dpis;
	    conv_tbl(i).end_dpis := FA_LOAD_TBL_PKG.deprn_table(i).end_dpis;
	    h_life_in_months := FA_LOAD_TBL_PKG.deprn_table(i).life_in_months;
	    h_basic_rate := FA_LOAD_TBL_PKG.deprn_table(i).basic_rate;
	    h_adjusted_rate := FA_LOAD_TBL_PKG.deprn_table(i).adjusted_rate;
	    h_allowed_deprn_limit := FA_LOAD_TBL_PKG.deprn_table(i).allow_deprn_limit;
	    h_percent_salvage_val := FA_LOAD_TBL_PKG.deprn_table(i).percent_salvage_value;
	    Convert_Formats(
		X_Life_In_Months        => h_life_in_months,
        	X_Basic_Rate            => h_basic_rate,
        	X_Adjusted_Rate         => h_adjusted_rate,
        	X_Allowed_Deprn_Limit   => h_allowed_deprn_limit,
        	X_Percent_Salvage_Val   => h_percent_salvage_val,
        	X_Life                  => conv_tbl(i).life,
        	X_Basic_Rate_Pct        => conv_tbl(i).basic_rate_pct,
        	X_Adjusted_Rate_Pct     => conv_tbl(i).adjusted_rate_pct,
       	 	X_Deprn_Limit_Pct       => conv_tbl(i).deprn_limit_pct,
        	X_Salvage_Val_Pct       => conv_tbl(i).salvage_val_pct,
                p_Log_level_rec         => p_log_level_rec);
	END IF;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
	FA_SRVR_MSG.Add_SQL_Error(
                CALLING_FN => 'FA_MASS_REC_UTILS_PKG.Load_Conversion_Table',  p_log_level_rec => p_log_level_rec);
	raise;
END Load_Conversion_Table;


/*====================================================================================+
|   PROCEDURE Insert_Itf                                                              |
+=====================================================================================*/

PROCEDURE Insert_Itf(
	X_Report_Type		IN	VARCHAR2,
        X_Request_Id            IN      NUMBER,
	X_Mass_Reclass_Id	IN	NUMBER,
        X_Asset_Rec             IN      ASSET_REC,
        X_New_Category          IN      VARCHAR2 := NULL,
        X_Last_Update_Date      IN      DATE,
        X_Last_Updated_By       IN      NUMBER,
        X_Created_By            IN      NUMBER,
        X_Creation_Date         IN      DATE,
        X_Last_Update_Login     IN      NUMBER
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    -- cursor to fetch the meaning for depreciate flag.
    CURSOR get_deprn_flag IS
	SELECT nvl(meaning, X_Asset_Rec.depreciate_flag)
	FROM fa_lookups
	WHERE lookup_code = X_Asset_Rec.depreciate_flag
	AND lookup_type = 'YESNO';
    h_deprn_flag_mean	VARCHAR2(80);
BEGIN
    -- Insert the meaning, not the lookup code for the depreciate flag.
    OPEN get_deprn_flag;
    FETCH get_deprn_flag INTO h_deprn_flag_mean;
    CLOSE get_deprn_flag;

    IF (X_Report_Type = 'PREVIEW') THEN
        INSERT INTO fa_mass_reclass_itf (
		request_id, mass_reclass_id,
		asset_id, asset_number,
		description, book,
		old_category, new_category,
		convention, ceiling, method,
		life, basic_rate, adjusted_rate,
		bonus_rule, production_capacity, unit_of_measure,
		depreciate_flag, deprn_limit_percentage,
		deprn_limit_amount, salvage_val_percentage,
		cost_acct, deprn_reserve_acct,
		last_update_date, last_updated_by, created_by,
		creation_date, last_update_login
    		)
    	VALUES (
		X_Request_Id, X_Mass_Reclass_Id,
		X_Asset_Rec.asset_id, X_Asset_Rec.asset_number,
		X_Asset_Rec.description, X_Asset_Rec.book_type_code,
		X_Asset_Rec.category, X_New_Category,
		X_Asset_Rec.convention, X_Asset_Rec.ceiling, X_Asset_Rec.method,
		fnd_number.canonical_to_number(X_Asset_Rec.life),
		X_Asset_Rec.basic_rate_pct, X_Asset_Rec.adjusted_rate_pct,
		X_Asset_Rec.bonus_rule, X_Asset_Rec.capacity, X_Asset_Rec.unit_of_measure,
		h_deprn_flag_mean, X_Asset_Rec.deprn_limit_pct,
		X_Asset_Rec.deprn_limit_amt, X_Asset_Rec.salvage_val_pct,
		X_Asset_Rec.cost_acct, X_Asset_Rec.deprn_rsv_acct,
		X_Last_Update_Date, X_Last_Updated_By, X_Created_By,
		X_Creation_Date, X_Last_Update_Login
    		);
    ELSIF (X_Report_Type = 'REVIEW') THEN
        INSERT INTO fa_mass_reclass_itf (
		request_id, mass_reclass_id,
		asset_id, asset_number,
		description, book,
		old_category, new_category,
		convention, ceiling, method,
		life, basic_rate, adjusted_rate,
		bonus_rule, production_capacity, unit_of_measure,
		depreciate_flag, deprn_limit_percentage,
		deprn_limit_amount, salvage_val_percentage,
		cost_acct, deprn_reserve_acct,
		last_update_date, last_updated_by, created_by,
		creation_date, last_update_login
    		)
    	VALUES (
		X_Request_Id, X_Mass_Reclass_Id,
		X_Asset_Rec.asset_id, X_Asset_Rec.asset_number,
		X_Asset_Rec.description, X_Asset_Rec.book_type_code,
		NULL, X_Asset_Rec.category,
		X_Asset_Rec.convention, X_Asset_Rec.ceiling, X_Asset_Rec.method,
		fnd_number.canonical_to_number(X_Asset_Rec.life),
		X_Asset_Rec.basic_rate_pct, X_Asset_Rec.adjusted_rate_pct,
		X_Asset_Rec.bonus_rule, X_Asset_Rec.capacity, X_Asset_Rec.unit_of_measure,
		h_deprn_flag_mean, X_Asset_Rec.deprn_limit_pct,
		X_Asset_Rec.deprn_limit_amt, X_Asset_Rec.salvage_val_pct,
		X_Asset_Rec.cost_acct, X_Asset_Rec.deprn_rsv_acct,
		X_Last_Update_Date, X_Last_Updated_By, X_Created_By,
		X_Creation_Date, X_Last_Update_Login
    		);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
	FA_SRVR_MSG.Add_Message(
                CALLING_FN => 'FA_MASS_REC_UTILS_PKG.Insert_Itf',
                NAME => 'FA_SHARED_INSERT_FAILED',
                TOKEN1 => 'FAILED',
                VALUE1 => 'FA_MASS_RECLASS_ITF',  p_log_level_rec => p_log_level_rec);
	FA_SRVR_MSG.Add_SQL_Error(
                CALLING_FN => 'FA_MASS_REC_UTILS_PKG.Insert_Itf',  p_log_level_rec => p_log_level_rec);
	raise;
END Insert_Itf;


/*====================================================================================+
|   PROCEDURE Get_Selection_Criteria                                                  |
+=====================================================================================*/

PROCEDURE Get_Selection_Criteria(
	X_Mass_Reclass_ID	IN	NUMBER,
	X_Book_Type_Code OUT NOCOPY VARCHAR2,
	X_Asset_Type	 OUT NOCOPY VARCHAR2,
	X_Fully_Rsvd	 OUT NOCOPY VARCHAR2,
	X_From_Cost	 OUT NOCOPY NUMBER,
	X_To_Cost	 OUT NOCOPY NUMBER,
	X_From_Asset	 OUT NOCOPY VARCHAR2,
	X_To_Asset	 OUT NOCOPY VARCHAR2,
	X_From_Dpis	 OUT NOCOPY DATE,
	X_To_Dpis	 OUT NOCOPY DATE,
	X_Location	 OUT NOCOPY VARCHAR2,
	X_Employee_Name	 OUT NOCOPY VARCHAR2,
	X_Employee_Number OUT NOCOPY VARCHAR2,
	X_Old_Category	 OUT NOCOPY VARCHAR2,
	X_New_Category	 OUT NOCOPY VARCHAR2,
	X_Asset_Key	 OUT NOCOPY VARCHAR2,
	X_From_Exp_Acct	 OUT NOCOPY VARCHAR2,
	X_To_Exp_Acct	 OUT NOCOPY VARCHAR2
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

    mr_rec		mass_reclass_rec;
    precis		NUMBER;

    -- cursor to get mass reclass record.
    CURSOR mass_reclass IS
        SELECT 	mr.book_type_code, mr.asset_type,
		mr.include_fully_rsvd_flag,
		mr.from_cost, mr.to_cost,
		mr.from_asset_number, mr.to_asset_number,
		mr.from_date_placed_in_service, mr.to_date_placed_in_service,
		mr.location_id, mr.employee_id,
		mr.from_category_id, mr.to_category_id, mr.asset_key_id,
		mr.segment1_low, mr.segment2_low, mr.segment3_low,
		mr.segment4_low, mr.segment5_low, mr.segment6_low,
		mr.segment7_low, mr.segment8_low, mr.segment9_low,
		mr.segment10_low, mr.segment11_low, mr.segment12_low,
		mr.segment13_low, mr.segment14_low, mr.segment15_low,
		mr.segment16_low, mr.segment17_low, mr.segment18_low,
		mr.segment19_low, mr.segment20_low, mr.segment21_low,
		mr.segment22_low, mr.segment23_low, mr.segment24_low,
		mr.segment25_low, mr.segment26_low, mr.segment27_low,
		mr.segment28_low, mr.segment29_low, mr.segment30_low,
		mr.segment1_high, mr.segment2_high, mr.segment3_high,
		mr.segment4_high, mr.segment5_high, mr.segment6_high,
		mr.segment7_high, mr.segment8_high, mr.segment9_high,
		mr.segment10_high, mr.segment11_high, mr.segment12_high,
		mr.segment13_high, mr.segment14_high, mr.segment15_high,
		mr.segment16_high, mr.segment17_high, mr.segment18_high,
		mr.segment19_high, mr.segment20_high, mr.segment21_high,
		mr.segment22_high, mr.segment23_high, mr.segment24_high,
		mr.segment25_high, mr.segment26_high, mr.segment27_high,
		mr.segment28_high, mr.segment29_high, mr.segment30_high
        FROM	fa_mass_reclass mr
    	WHERE	mr.mass_reclass_id = X_Mass_Reclass_Id;

    -- cursor to get precision.
    CURSOR get_precision IS
        SELECT 	curr.precision
    	FROM 	fnd_currencies curr, gl_sets_of_books sob,
       		fa_book_controls bc
    	WHERE 	curr.currency_code = sob.currency_code
    	AND  	sob.set_of_books_id = bc.set_of_books_id
    	AND 	bc.book_type_code = mr_rec.book_type_code;

    -- cursor to get flex structures.
    CURSOR get_flex_structs IS
	SELECT 	category_flex_structure, location_flex_structure,
		asset_key_flex_structure
	FROM 	fa_system_controls;

    -- cursor to get employee.
    CURSOR get_employee IS
	SELECT 	name, employee_number
	FROM	fa_employees
	WHERE	employee_id = mr_rec.employee_id;

    -- cursor to get accounting flexfield structure
    CURSOR get_acct_flex_struct IS
        SELECT accounting_flex_structure FROM fa_book_controls
        WHERE book_type_code = mr_rec.book_type_code;

    -- cursor to get gl_code_combinations table id
    CURSOR get_gl_table_id IS
        SELECT  table_id FROM fnd_tables
        WHERE   table_name = 'GL_CODE_COMBINATIONS' AND application_id = 101;

    h_acct_flex_struct		NUMBER;
    -- cursor to get the delimiter value between accounting flexfield segments
    CURSOR get_delim IS
        SELECT  s.concatenated_segment_delimiter
        FROM    fnd_id_flex_structures s, fnd_application a
        WHERE   s.application_id = a.application_id
        AND     s.id_flex_code = 'GL#'
        AND     s.id_flex_num = h_acct_flex_struct
        AND     a.application_short_name = 'SQLGL';

    h_table_id          	NUMBER;
    -- cursor to figure out number of segments used for the accounting flexfield
    CURSOR segcolumns IS
        SELECT  distinct g.application_column_name, g.segment_num
        FROM    fnd_columns c, fnd_id_flex_segments g
        WHERE   g.application_id = 101
        AND     g.id_flex_code = 'GL#'
        AND     g.id_flex_num = h_acct_flex_struct
        AND     g.enabled_flag = 'Y'
        AND     c.application_id = 101
        AND     c.table_id = h_table_id
        AND     c.column_name = g.application_column_name;
    h_asset_type		VARCHAR2(11) := NULL;
    h_fully_rsvd		VARCHAR2(3) := NULL;
    -- cursors to get meanings for asset type and fully reserved flag.
    CURSOR get_asset_type_mean IS
	SELECT nvl(meaning, h_asset_type)
	FROM fa_lookups
	WHERE lookup_code = h_asset_type
	AND lookup_type = 'ASSET TYPE';
    CURSOR get_fully_rsvd_mean IS
	SELECT nvl(meaning, h_fully_rsvd)
	FROM fa_lookups
	WHERE lookup_code = h_fully_rsvd
	AND lookup_type = 'YESNO';

    delim               	VARCHAR2(1);
    col_name            	VARCHAR2(25);
    v_return            	INTEGER;
    num_segs            	NUMBER := 0;
    segarr         		FA_RX_SHARED_PKG.Seg_Array;
    h_cat_flex_struct		NUMBER;
    h_loc_flex_struct		NUMBER;
    h_key_flex_struct		NUMBER;
    -- from/to expense accounts in concatenated strings
    from_acct_concat    	VARCHAR2(780) := '';
    to_acct_concat      	VARCHAR2(780) := '';
BEGIN
    -- Get mass reclass record.
    OPEN mass_reclass;
    FETCH 	mass_reclass
    INTO	mr_rec.book_type_code, h_asset_type,
		h_fully_rsvd,
		mr_rec.from_cost, mr_rec.to_cost,
		X_From_Asset, X_To_Asset,
		X_From_Dpis, X_To_Dpis,
		mr_rec.location_id, mr_rec.employee_id,
		mr_rec.from_category_id, mr_rec.to_category_id, mr_rec.asset_key_id,
		mr_rec.segment1_low, mr_rec.segment2_low, mr_rec.segment3_low,
		mr_rec.segment4_low, mr_rec.segment5_low, mr_rec.segment6_low,
		mr_rec.segment7_low, mr_rec.segment8_low, mr_rec.segment9_low,
		mr_rec.segment10_low, mr_rec.segment11_low, mr_rec.segment12_low,
		mr_rec.segment13_low, mr_rec.segment14_low, mr_rec.segment15_low,
		mr_rec.segment16_low, mr_rec.segment17_low, mr_rec.segment18_low,
		mr_rec.segment19_low, mr_rec.segment20_low, mr_rec.segment21_low,
		mr_rec.segment22_low, mr_rec.segment23_low, mr_rec.segment24_low,
		mr_rec.segment25_low, mr_rec.segment26_low, mr_rec.segment27_low,
		mr_rec.segment28_low, mr_rec.segment29_low, mr_rec.segment30_low,
		mr_rec.segment1_high, mr_rec.segment2_high, mr_rec.segment3_high,
		mr_rec.segment4_high, mr_rec.segment5_high, mr_rec.segment6_high,
		mr_rec.segment7_high, mr_rec.segment8_high, mr_rec.segment9_high,
		mr_rec.segment10_high, mr_rec.segment11_high, mr_rec.segment12_high,
		mr_rec.segment13_high, mr_rec.segment14_high, mr_rec.segment15_high,
		mr_rec.segment16_high, mr_rec.segment17_high, mr_rec.segment18_high,
		mr_rec.segment19_high, mr_rec.segment20_high, mr_rec.segment21_high,
		mr_rec.segment22_high, mr_rec.segment23_high, mr_rec.segment24_high,
		mr_rec.segment25_high, mr_rec.segment26_high, mr_rec.segment27_high,
		mr_rec.segment28_high, mr_rec.segment29_high, mr_rec.segment30_high;
    CLOSE mass_reclass;

    -- Get meanings for asset type and fully reserved flag.
    OPEN get_asset_type_mean;
    FETCH get_asset_type_mean INTO X_Asset_Type;
    CLOSE get_asset_type_mean;

    OPEN get_fully_rsvd_mean;
    FETCH get_fully_rsvd_mean INTO X_Fully_Rsvd;
    CLOSE get_fully_rsvd_mean;

    -- Get precision.
    OPEN get_precision;
    FETCH get_precision INTO precis;
    IF get_precision%NOTFOUND THEN
	precis := 2;
    END IF;
    CLOSE get_precision;

    -- Get flex structures
    OPEN get_flex_structs;
    FETCH get_flex_structs
    INTO h_cat_flex_struct, h_loc_flex_struct, h_key_flex_struct;
    CLOSE get_flex_structs;

    -- Get old and new category.
    IF mr_rec.from_category_id IS NOT NULL THEN
     	FA_RX_SHARED_PKG.Concat_Category (
           struct_id => h_cat_flex_struct,
           ccid => mr_rec.from_category_id,
           concat_string => X_Old_Category,
           segarray => segarr);
    ELSE
	X_Old_Category := NULL;
    END IF;

    FA_RX_SHARED_PKG.Concat_Category (
           struct_id => h_cat_flex_struct,
           ccid => mr_rec.to_category_id,
           concat_string => X_New_Category,
           segarray => segarr);

    -- Get location in concatenated string.
    IF mr_rec.location_id IS NOT NULL THEN
    	FA_RX_SHARED_PKG.Concat_Location (
           struct_id => h_loc_flex_struct,
           ccid => mr_rec.location_id,
           concat_string => X_Location,
           segarray => segarr);
    ELSE
	X_Location := NULL;
    END IF;

    -- Get asset key.
    IF mr_rec.asset_key_id IS NOT NULL THEN
    	FA_RX_SHARED_PKG.Concat_Asset_Key (
           struct_id => h_key_flex_struct,
           ccid => mr_rec.asset_key_id,
           concat_string => X_Asset_Key,
           segarray => segarr);
    ELSE
	X_Asset_Key := NULL;
    END IF;

    -- Get employee information.
    IF mr_rec.employee_id IS NOT NULL THEN
    	OPEN get_employee;
    	FETCH get_employee INTO X_Employee_Name, X_Employee_Number;
    	CLOSE get_employee;
    ELSE
	X_Employee_Name := NULL;
	X_Employee_Number := NULL;
    END IF;

    -- Get accounting flexfield structure for expense account selection
    -- criteria report output.
    OPEN get_acct_flex_struct;
    FETCH get_acct_flex_struct INTO h_acct_flex_struct;
    CLOSE get_acct_flex_struct;

    OPEN get_gl_table_id;
    FETCH get_gl_table_id INTO h_table_id;
    CLOSE get_gl_table_id;

    OPEN get_delim;
    FETCH get_delim INTO delim;
    CLOSE get_delim;

    -- Get number of segments for the accounting flexfield structure.
    -- (Number of segments in use varies among books.)
    OPEN segcolumns;
    LOOP
        FETCH segcolumns INTO col_name, v_return;
        IF (segcolumns%NOTFOUND) THEN EXIT; END IF;
        num_segs := num_segs + 1;
    END LOOP;

    -- Get low segment values.
    segarr(1) := mr_rec.segment1_low;
    segarr(2) := mr_rec.segment2_low;
    segarr(3) := mr_rec.segment3_low;
    segarr(4) := mr_rec.segment4_low;
    segarr(5) := mr_rec.segment5_low;
    segarr(6) := mr_rec.segment6_low;
    segarr(7) := mr_rec.segment7_low;
    segarr(8) := mr_rec.segment8_low;
    segarr(9) := mr_rec.segment9_low;
    segarr(10) := mr_rec.segment10_low;
    segarr(11) := mr_rec.segment11_low;
    segarr(12) := mr_rec.segment12_low;
    segarr(13) := mr_rec.segment13_low;
    segarr(14) := mr_rec.segment14_low;
    segarr(15) := mr_rec.segment15_low;
    segarr(16) := mr_rec.segment16_low;
    segarr(17) := mr_rec.segment17_low;
    segarr(18) := mr_rec.segment18_low;
    segarr(19) := mr_rec.segment19_low;
    segarr(20) := mr_rec.segment20_low;
    segarr(21) := mr_rec.segment21_low;
    segarr(22) := mr_rec.segment22_low;
    segarr(23) := mr_rec.segment23_low;
    segarr(24) := mr_rec.segment24_low;
    segarr(25) := mr_rec.segment25_low;
    segarr(26) := mr_rec.segment26_low;
    segarr(27) := mr_rec.segment27_low;
    segarr(28) := mr_rec.segment28_low;
    segarr(29) := mr_rec.segment29_low;
    segarr(30) := mr_rec.segment30_low;

    -- Get From Expense Account in concatenated string.
    FOR seg_ctr IN 1 .. num_segs-1 LOOP
        from_acct_concat := from_acct_concat || segarr(seg_ctr) || delim;
    END LOOP;
    from_acct_concat := from_acct_concat || segarr(num_segs);

    -- Get high segment values.
    segarr(1) := mr_rec.segment1_high;
    segarr(2) := mr_rec.segment2_high;
    segarr(3) := mr_rec.segment3_high;
    segarr(4) := mr_rec.segment4_high;
    segarr(5) := mr_rec.segment5_high;
    segarr(6) := mr_rec.segment6_high;
    segarr(7) := mr_rec.segment7_high;
    segarr(8) := mr_rec.segment8_high;
    segarr(9) := mr_rec.segment9_high;
    segarr(10) := mr_rec.segment10_high;
    segarr(11) := mr_rec.segment11_high;
    segarr(12) := mr_rec.segment12_high;
    segarr(13) := mr_rec.segment13_high;
    segarr(14) := mr_rec.segment14_high;
    segarr(15) := mr_rec.segment15_high;
    segarr(16) := mr_rec.segment16_high;
    segarr(17) := mr_rec.segment17_high;
    segarr(18) := mr_rec.segment18_high;
    segarr(19) := mr_rec.segment19_high;
    segarr(20) := mr_rec.segment20_high;
    segarr(21) := mr_rec.segment21_high;
    segarr(22) := mr_rec.segment22_high;
    segarr(23) := mr_rec.segment23_high;
    segarr(24) := mr_rec.segment24_high;
    segarr(25) := mr_rec.segment25_high;
    segarr(26) := mr_rec.segment26_high;
    segarr(27) := mr_rec.segment27_high;
    segarr(28) := mr_rec.segment28_high;
    segarr(29) := mr_rec.segment29_high;
    segarr(30) := mr_rec.segment30_high;

    -- Get To Expense Account in concatenated string.
    FOR seg_ctr IN 1 .. num_segs-1 LOOP
        to_acct_concat := to_acct_concat || segarr(seg_ctr) || delim;
    END LOOP;
    to_acct_concat := to_acct_concat || segarr(num_segs);

    X_Book_Type_Code := mr_rec.book_type_code;
    IF mr_rec.from_cost IS NOT NULL THEN
    	X_From_Cost := round(mr_rec.from_cost, precis);
    ELSE
	X_From_Cost := NULL;
    END IF;
    IF mr_rec.to_cost IS NOT NULL THEN
    	X_To_Cost := round(mr_rec.to_cost, precis);
    ELSE
	X_To_Cost := NULL;
    END IF;
    X_From_Exp_Acct := from_acct_concat;
    X_To_Exp_Acct := to_acct_concat;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	X_Book_Type_Code := NULL;
	X_Asset_Type := NULL;
	X_Fully_Rsvd := NULL;
	X_From_Cost := NULL;
	X_To_Cost := NULL;
	X_From_Asset := NULL;
	X_To_Asset := NULL;
	X_From_Dpis := NULL;
	X_To_Dpis := NULL;
	X_Location := NULL;
	X_Employee_Name	:= NULL;
	X_Employee_Number := NULL;
	X_Old_Category := NULL;
	X_New_Category := NULL;
	X_Asset_Key := NULL;
	X_From_Exp_Acct	:= NULL;
	X_To_Exp_Acct := NULL;
END Get_Selection_Criteria;


/*====================================================================================+
|   PROCEDURE Compare_Cat_Major_Segs                                                  |
+=====================================================================================*/

PROCEDURE Compare_Cat_Major_Segs(
        X_Category_Id1          IN      NUMBER,
        X_Category_Id2          IN      NUMBER,
        X_Same_Values           OUT NOCOPY     VARCHAR2,
	X_Return_Status	 OUT NOCOPY BOOLEAN
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
        CURSOR get_cat_flex_struct IS
            SELECT category_flex_structure
            FROM FA_SYSTEM_CONTROLS;
        l_cat_flex_struct       NUMBER;
        l_gsval                 BOOLEAN;
        l_bal_segnum            NUMBER;
        l_numof_segs            NUMBER;
        l_all_segs_old          FND_FLEX_EXT.SegmentArray;
        l_all_segs_new          FND_FLEX_EXT.SegmentArray;
        l_old_bal_seg           VARCHAR2(50);
        l_new_bal_seg           VARCHAR2(50);
	compare_failure		EXCEPTION;
BEGIN
    -- Get major category segment values.
    OPEN get_cat_flex_struct;
    FETCH get_cat_flex_struct INTO l_cat_flex_struct;
    CLOSE get_cat_flex_struct;

    -- Get the segment number for the major category.
    l_gsval :=  FND_FLEX_APIS.Get_Qualifier_Segnum (
                        appl_id         => 140 ,
                        key_flex_code   => 'CAT#',
                        structure_number => l_cat_flex_struct,
                        flex_qual_name  => 'BASED_CATEGORY',
                        segment_number  => l_bal_segnum);

    IF NOT l_gsval THEN
	raise compare_failure;
    END IF;

    -- Get the segment values for the old category.
    l_gsval := FND_FLEX_EXT.Get_Segments(
                        application_short_name  => 'OFA',
                        key_flex_code   => 'CAT#',
                        structure_number => l_cat_flex_struct,
                        combination_id  => X_Category_Id1,
                        n_segments      => l_numof_segs,
                        segments        => l_all_segs_old);

    IF NOT l_gsval THEN
	raise compare_failure;
    END IF;

    -- Get the old major category segment value.
    l_old_bal_seg := l_all_segs_old(l_bal_segnum);

    -- Get the segment values for the new category.
    l_gsval := FND_FLEX_EXT.Get_Segments(
                        application_short_name  => 'OFA',
                        key_flex_code   => 'CAT#',
                        structure_number => l_cat_flex_struct,
                        combination_id  => X_Category_Id2,
                        n_segments      => l_numof_segs,
                        segments        => l_all_segs_new);

    IF NOT l_gsval THEN
	raise compare_failure;
    END IF;

    -- Get the new major category segment value.
    l_new_bal_seg := l_all_segs_new(l_bal_segnum);

    -- Update only the necessary columns.
    IF (l_old_bal_seg = l_new_bal_seg) THEN
	X_Same_Values := 'YES';
    ELSE
	X_Same_Values := 'NO';
    END IF;

    X_Return_Status := TRUE;

EXCEPTION
    WHEN compare_failure THEN
  	X_Same_Values := 'NO';
	X_Return_Status := FALSE;
        FA_SRVR_MSG.Add_Message(
            CALLING_FN => 'FA_MASS_REC_UTILS_PKG.Compare_Cat_Major_Segs',
            NAME => 'FA_REC_GET_CATSEG_FAILED',  p_log_level_rec => p_log_level_rec);
            -- Message: 'Failed to get category segments.'
	raise;
    WHEN OTHERS THEN
	X_Same_Values := 'NO';
	X_Return_Status := FALSE;
	FA_SRVR_MSG.Add_SQL_Error(
	    CALLING_FN => 'FA_MASS_REC_UTILS_PKG.Compare_Cat_Major_Segs',  p_log_level_rec => p_log_level_rec);
	raise;
END Compare_Cat_Major_Segs;


END FA_MASS_REC_UTILS_PKG;

/
