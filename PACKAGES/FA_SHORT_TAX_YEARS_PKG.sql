--------------------------------------------------------
--  DDL for Package FA_SHORT_TAX_YEARS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_SHORT_TAX_YEARS_PKG" AUTHID CURRENT_USER AS
/* $Header: FAXSTYS.pls 120.4.12010000.2 2009/07/19 11:10:56 glchen ship $ */


/*=====================================================================================+
|
|   Name:          Calculate_Short_Tax_Vals
|
|   Description:   This module calculates remaining life values.
|		   These values are mainly used for assets added in
|		   short tax years that use formula-based depreciation methods.
|		   However, in general it is used for any asset that uses a
|		   formula-based method.
|
|   Parameters:    X_Asset_Id - Asset ID.
|		   X_Book_Type_Code - Book the asset belongs to.
|        	   X_Short_Fiscal_Year_Flag - Short fiscal year flag in
|                       FA_BOOKS.
|        	   X_Deprn_Start_Date - Deprn_Start_Date(in DATE format.)
|        	   X_Conversion_Date - Conversion date in FA_BOOKS
|			(in DATE format.)
|        	   X_Curr_Fy_Start_Date - Current fiscal year start date
|			(in DATE format.)
|        	   X_Curr_Fy_End_Date - Current fiscal year end date(in DATE
|                       format.)
|        	   C_Deprn_Start_Date - Deprn_Start_Date(in VARCHAR2 format.)
|        	   C_Conversion_Date - Conversion date in FA_BOOKS
|			(in VARCHAR2 format.)
|        	   C_Curr_Fy_Start_Date - Current fiscal year start date
|			(in VARCHAR2 format.)
|        	   C_Curr_Fy_End_Date - Current fiscal year end date
|			(in VARCHAR2 format.)
|        	   X_Life_In_Months - Life in months.
|        	   X_Rate_Source_Rule - Rate source rule of the depreciation
|                       method for the asset.
|        	   X_Remaining_Life1 - OUT NOCOPY parameter. New remaining_life1 value
|			in FA_BOOKS.
|        	   X_Remaining_Life2 - OUT NOCOPY parameter. New remaining_life2 value
|			in FA_BOOKS.
|        	   X_Success - OUT NOCOPY parameter.  Indicates whether the procedure
|			completed successfully or not.
|			YES - If successful.
|			No - If failed.
|
|   Returns:
|
|   Notes:         1. Calling modules: depreciation, addition engines, mass
|                     additions, adjustment/reclass - redefault engines, and
|		      mass change program.
|		   2. 1) If the calling module is a PL/SQL program, the date
|                        values should be passed in DATE types into the
|		         following arguments:
|		      	 X_Prorate_Date, X_Original_Fyend, X_Curr_Fy_Start_Date,
|                        and X_Curr_Fy_End_Date.  (Values are not required for
|		         C_Deprn_Start_Date .. C_Curr_Fy_End_Date in this case.)
|		      2) If the calling module is a Pro*C program, the date
|                        values should be passed in VARCHAR2 types with
|		         appropriate format masks (DD-MM-YYYY) into the
|		         following arguments:
|		     C_Deprn_Start_Date, C_Original_Fyend, C_Curr_Fy_Start_Date,
|                        and C_Curr_Fy_End_Date.  (Values are not required for
|		         X_Deprn_Start_Date .. X_Curr_Fy_End_Date in this case.)
|
+====================================================================================*/

PROCEDURE Calculate_Short_Tax_Vals (
        X_Asset_Id              IN      NUMBER,
        X_Book_Type_Code        IN      VARCHAR2,
        X_Short_Fiscal_Year_Flag IN     VARCHAR2,
	X_Date_Placed_In_Service IN	DATE := NULL,
        X_Deprn_Start_Date      IN      DATE := NULL,
        X_Prorate_Date          IN      DATE := NULL,
        X_Conversion_Date       IN      DATE := NULL,
	X_Orig_Deprn_Start_Date IN	DATE := NULL,
        X_Curr_Fy_Start_Date    IN      DATE := NULL,
        X_Curr_Fy_End_Date      IN      DATE := NULL,
	C_Date_Placed_In_Service IN	VARCHAR2 := NULL,
        C_Deprn_Start_Date       IN      VARCHAR2 := NULL,
        C_Prorate_Date          IN      VARCHAR2 := NULL,
        C_Conversion_Date       IN      VARCHAR2 := NULL,
	C_Orig_Deprn_Start_Date	IN	VARCHAR2 := NULL,
        C_Curr_Fy_Start_Date    IN      VARCHAR2 := NULL,
        C_Curr_Fy_End_Date      IN      VARCHAR2 := NULL,
        X_Life_In_Months        IN      NUMBER,
        X_Rate_Source_Rule      IN      VARCHAR2,
	X_Fiscal_Year		IN	NUMBER,
	X_Method_Code		IN	VARCHAR2,
	X_Current_Period	IN	NUMBER,
        X_Remaining_Life1       OUT NOCOPY NUMBER,
        X_Remaining_Life2       OUT NOCOPY NUMBER,
        X_Success               OUT NOCOPY VARCHAR2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);


END FA_SHORT_TAX_YEARS_PKG;

/
