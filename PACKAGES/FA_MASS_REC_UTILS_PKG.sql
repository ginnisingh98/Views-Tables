--------------------------------------------------------
--  DDL for Package FA_MASS_REC_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MASS_REC_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: FAXMRUTS.pls 120.2.12010000.2 2009/07/19 14:06:31 glchen ship $ */

-- Mass reclass record from fa_mass_reclass table.
TYPE mass_reclass_rec IS RECORD (
	mass_reclass_id		NUMBER(15),
	book_type_code		VARCHAR2(15),	-- corporate book selected by user
	trans_date_entered 	DATE,
	conc_request_id		NUMBER(15),
	status			VARCHAR2(10),
	asset_type		VARCHAR2(11),
	location_id		NUMBER(15),
	employee_id		NUMBER(15),
	asset_key_id		NUMBER(15),
	from_cost		NUMBER,
	to_cost			NUMBER,
	from_asset_number	VARCHAR2(15),
	to_asset_number		VARCHAR2(15),
	from_dpis		DATE,
	to_dpis			DATE,
	from_category_id	NUMBER(15),
	to_category_id		NUMBER(15),
	segment1_low		VARCHAR2(25),
	segment2_low		VARCHAR2(25),
	segment3_low		VARCHAR2(25),
	segment4_low		VARCHAR2(25),
	segment5_low		VARCHAR2(25),
	segment6_low		VARCHAR2(25),
	segment7_low		VARCHAR2(25),
	segment8_low		VARCHAR2(25),
	segment9_low		VARCHAR2(25),
	segment10_low		VARCHAR2(25),
	segment11_low		VARCHAR2(25),
	segment12_low		VARCHAR2(25),
	segment13_low		VARCHAR2(25),
	segment14_low		VARCHAR2(25),
	segment15_low		VARCHAR2(25),
	segment16_low		VARCHAR2(25),
	segment17_low		VARCHAR2(25),
	segment18_low		VARCHAR2(25),
	segment19_low		VARCHAR2(25),
	segment20_low		VARCHAR2(25),
	segment21_low		VARCHAR2(25),
	segment22_low		VARCHAR2(25),
	segment23_low		VARCHAR2(25),
	segment24_low		VARCHAR2(25),
	segment25_low		VARCHAR2(25),
	segment26_low		VARCHAR2(25),
	segment27_low		VARCHAR2(25),
	segment28_low		VARCHAR2(25),
	segment29_low		VARCHAR2(25),
	segment30_low		VARCHAR2(25),
	segment1_high		VARCHAR2(25),
	segment2_high		VARCHAR2(25),
	segment3_high		VARCHAR2(25),
	segment4_high		VARCHAR2(25),
	segment5_high		VARCHAR2(25),
	segment6_high		VARCHAR2(25),
	segment7_high		VARCHAR2(25),
	segment8_high		VARCHAR2(25),
	segment9_high		VARCHAR2(25),
	segment10_high		VARCHAR2(25),
	segment11_high		VARCHAR2(25),
	segment12_high		VARCHAR2(25),
	segment13_high		VARCHAR2(25),
	segment14_high		VARCHAR2(25),
	segment15_high		VARCHAR2(25),
	segment16_high		VARCHAR2(25),
	segment17_high		VARCHAR2(25),
	segment18_high		VARCHAR2(25),
	segment19_high		VARCHAR2(25),
	segment20_high		VARCHAR2(25),
	segment21_high		VARCHAR2(25),
	segment22_high		VARCHAR2(25),
	segment23_high		VARCHAR2(25),
	segment24_high		VARCHAR2(25),
	segment25_high		VARCHAR2(25),
	segment26_high		VARCHAR2(25),
	segment27_high		VARCHAR2(25),
	segment28_high		VARCHAR2(25),
	segment29_high		VARCHAR2(25),
	segment30_high		VARCHAR2(25),
	fully_rsvd_flag		VARCHAR2(3),
	copy_cat_desc_flag	VARCHAR2(3),
	redefault_flag		VARCHAR2(3),
	amortize_flag		VARCHAR2(3),
	created_by		NUMBER(15),
	creation_date		DATE,
	last_updated_by    	NUMBER(15),
        last_update_login 	NUMBER(15),
        last_update_date	DATE
	);

-- Asset record for the asset to be reclassified.
TYPE asset_rec IS RECORD (
        asset_id                NUMBER(15),
        asset_number            VARCHAR2(15),
	description		VARCHAR2(80),
	book_type_code		VARCHAR2(15), 	-- corporate/tax book for asset
	-- The following fields may be used to load either the old or new
	-- depreciation rules for the asset.
	category_id		NUMBER(15), 	-- current category in database
	category		VARCHAR2(210), 	-- in concatenated string
	convention		VARCHAR2(10),  	-- prorate convention
	ceiling			VARCHAR2(30),
	method			VARCHAR2(12),
	life_in_months		NUMBER(4),
	life			VARCHAR2(6),   	-- New life year.mo
	basic_rate		NUMBER,
	basic_rate_pct		NUMBER,		-- in percentage(rounded)
	adjusted_rate		NUMBER,
	adjusted_rate_pct	NUMBER,		-- in percentage(rounded)
	bonus_rule		VARCHAR2(30),
	capacity		NUMBER,
	unit_of_measure		VARCHAR2(25),
	depreciate_flag		VARCHAR2(3),
	allowed_deprn_limit	NUMBER,
	deprn_limit_pct		NUMBER,		-- in percentage(rounded)
	deprn_limit_amt		NUMBER,
	percent_salvage_val	NUMBER,
	salvage_val_pct		NUMBER,			-- in percentage(rounded)
	cost_acct_ccid		NUMBER(15) := NULL,
	cost_acct		VARCHAR2(780) := NULL, 	-- in concatenated string
	deprn_rsv_acct_ccid	NUMBER(15) := NULL,
	deprn_rsv_acct		VARCHAR2(780) := NULL  	-- in concatenated string
	);

-- Table of asset records.
TYPE asset_table IS TABLE OF asset_rec
	INDEX BY BINARY_INTEGER;

-- Conversion table: A table that caches certain depreciation rules data in
-- converted formats for the records in the table,
-- FA_LOAD_TBL_PKG.asset_deprn_info_tbl.
TYPE conversion_rec IS RECORD (
	book_type_code		VARCHAR2(15) := NULL,
	start_dpis		DATE := NULL,
	end_dpis		DATE := NULL,
	life			VARCHAR2(6),	-- New life year.mo
	basic_rate_pct		NUMBER,	    	-- in percentage
	adjusted_rate_pct	NUMBER,	    	-- in percentage
	deprn_limit_pct		NUMBER,	    	-- in percentage
	salvage_val_pct		NUMBER	    	-- in percentage
	);

TYPE conversion_table IS TABLE OF conversion_rec
	INDEX BY BINARY_INTEGER;

-- Global conversion table.
conv_tbl	conversion_table;


/*=====================================================================================+
|
|   Name:          Convert_Formats
|
|   Description:   Procedure to convert life, basic_rate, adjusted_rate,
|		   deprn_limit_pct, salvage_val_pct in proper formats.
|		   If the IN parameter value is NULL, the corresponding OUT NOCOPY parameter
|		   value is NULL
|
|   Parameters:    X_Life_In_Months -- Life in months.
|		   X_Basic_Rate	-- Basic rate(max value: 1)
|		   X_Adjusted_Rate -- Adjusted rate(max value: 1)
|		   X_Allowed_Deprn_Limit -- Allowed depreciation limit(max value: 1)
|		   X_Percent_Salvage_Val -- Percent salvage value(max value: 1)
|		   X_Life -- OUT parameter(in year.mo format)
|		   X_Basic_Rate_Pct -- OUT parameter(max value: 100.00)
|		   X_Adjusted_Rate_Pct -- OUT parameter(max value: 100.00)
|		   X_Deprn_Limit_Pct -- OUT parameter(max value: 100.00)
|		   X_Salvage_Val_Pct -- OUT parameter(max value: 100.00)
|
|   Returns:
|
|   Notes:
|
+======================================================================================*/

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
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);


/*=====================================================================================+
|
|   Name:          Load_Conversion_Table
|
|   Description:   Procedure to load(cache) the global conversion table.  This
|		   procedure first deletes all the existing records in the table
|		   before loading new data.  It then inserts a record with converted
|		   formats for each record in FA_LOAD_TBL_PKG.deprn_table.  The index
|		   position of the corresponding record in conv_tbl matches that of
|		   deprn_table record.
|
|   Parameters:
|
|   Returns:
|
|   Notes:	   1. FA_LOAD_TBL_PKG.deprn_table must be properly loaded first.
|		   2. This procedure implicitly re-initializes conv_tbl before
|		      loading new records.
|
+======================================================================================*/

PROCEDURE Load_Conversion_Table(p_log_level_rec        IN
FA_API_TYPES.log_level_rec_type);


/*=====================================================================================+
|
|   Name:          Insert_Itf
|
|   Description:   Proecedure to insert an asset record into the interface table,
|		   fa_mass_reclass_itf, for report exchange.
|
|   Parameters:    X_Report_Type -- PREVIEW or REVIEW
|	   	   X_Request_Id -- Concurrent request id.
|		   X_Mass_Reclass_Id -- Mass reclass id.
|	 	   X_Asset_Rec -- Asset record with all the information.
|		   X_New_Category -- New category in a concatenated string.
|		   	This parameter is used only for preview report.
|		   X_Last_Update_Date .. X_Last_Update_Login
|			-- Standard who columns
|
|   Returns:
|
|   Notes:	   For preview report, X_Asset_Rec should store the old(current)
|		   category information in category fields.
|
+=====================================================================================*/

PROCEDURE Insert_Itf(
 	X_Report_Type		IN	VARCHAR2,
	X_Request_Id		IN	NUMBER,
	X_Mass_Reclass_Id	IN	NUMBER,
	X_Asset_Rec		IN	ASSET_REC,
	X_New_Category		IN	VARCHAR2 := NULL,
	X_Last_Update_Date	IN	DATE,
	X_Last_Updated_By	IN	NUMBER,
	X_Created_By		IN	NUMBER,
	X_Creation_Date		IN	DATE,
	X_Last_Update_Login	IN	NUMBER
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);


/*=====================================================================================+
|
|   Name:          Get_Selection_Criteria
|
|   Description:   Proecedure to retrieve mass reclass asset selection criteria
|		   based on a mass reclass id.
|
|   Parameters:    X_Mass_Reclass_ID -- Mass reclass id.
|		   X_Book_Type_Code -- Book.
|		   X_Asset_Type -- Asset type.
|		   X_Fully_Rsvd -- YES or NO.
|		   X_From_Cost -- From cost rounded to precision.
|		   X_To_Cost -- To cost rounded to precision.
|		   X_From_Asset -- From asset number.
|		   X_To_Asset -- To asset number.
|		   X_From_Dpis -- From date placed in service.
|		   X_To_Dpis -- To date placed in service.
|		   X_Location -- Location in concatenated string format.
|		   X_Employee_Name -- Employee name.
|		   X_Employee_Number -- Employee number.
|		   X_Old_Category -- Old category in concatenated string format.
|		   X_New_Category -- New category in concatenated string format.
|		   X_Asset_Key -- Asset key in concatenated string format.
|		   X_From_Exp_Acct -- From expense account in concatenated
|			string format.
|		   X_To_Exp_Acct -- To expense accoutn in concatenated string
|			format.
|
|   Returns:
|
|   Notes:	   This function is used by Preview and Review reports(report 2.5.)
|
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
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);


/*=====================================================================================+
|
|   Name:          Compare_Cat_Major_Segs
|
|   Description:   Proecedure to compare major segment values of two categories.
|
|   Parameters:    X_Category_Id1 -- First category id for comparison
|		   X_Category_Id2 -- Second category id for comparison
|		   X_Same_Values -- YES, if balancing segment values are the same.
|				    NO, if they are different.
|		   X_Return_Status -- TRUE or FALSE.  Completion success or error.
|
|   Returns:
|
|   Notes: 	   Used in Mass Reclass form.
|
+=====================================================================================*/

PROCEDURE Compare_Cat_Major_Segs(
	X_Category_Id1		IN	NUMBER,
	X_Category_Id2		IN	NUMBER,
	X_Same_Values	 OUT NOCOPY VARCHAR2,
	X_Return_Status	 OUT NOCOPY BOOLEAN, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);


END FA_MASS_REC_UTILS_PKG;

/
