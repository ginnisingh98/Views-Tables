--------------------------------------------------------
--  DDL for Package FA_REC_PVT_PKG3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_REC_PVT_PKG3" AUTHID CURRENT_USER AS
/* $Header: FAXVRC3S.pls 120.2.12010000.2 2009/07/19 11:15:45 glchen ship $ */

/*=====================================================================================+
|
|   Name:          Validate_Rule_Changes
|
|   Description:   Checks if change can be made on each depreciation rule.
|
|   Parameters:    p_asset_id - Asset ID.
|                  p_new_category_id - New category to change to.
|                  p_book_type_code - Book(corporate or tax) the asset belongs to.
|   		   p_amortize_flag - Indicates whether to amortize the adjustment
|                       or not.
|		   p_old_rules - Current depreciation rules record from books row.
|                  p_new_rules - New depreciation rules record from the new
|                       category.
|		   x_prorate_date - OUT NOCOPY value.  New prorate date from the new
|			prorate convention.
|                  -- Next two arguments to implement short tax years.
|                  x_rate_source_rule - OUT NOCOPY value.  Identifies depreciation
|                       rate source.
|                  x_deprn_basis_rule - OUT NOCOPY value.  Depreciable basis --
|                       cost or NBV.
|
|   Returns:       TRUE or FALSE (BOOLEAN)
|                  TRUE - Validation sucess.
|                  FALSE - Validation failed.
|
|   Notes:         Called from Validate_Redefault.
|
+====================================================================================*/

FUNCTION Validate_Rule_Changes(
	p_asset_id              IN	NUMBER,
	p_new_category_id       IN	NUMBER,
	p_book_type_code        IN	VARCHAR2,
	p_amortize_flag         IN	VARCHAR2,
	p_old_rules             IN 	FA_LOAD_TBL_PKG.asset_deprn_info,
	p_new_rules             IN 	FA_LOAD_TBL_PKG.asset_deprn_info,
	x_prorate_date	 OUT NOCOPY DATE,
        x_rate_source_rule      OUT NOCOPY     VARCHAR2,
        x_deprn_basis_rule      OUT NOCOPY     VARCHAR2
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)	RETURN BOOLEAN;


/*=====================================================================================+
|
|   Name:          Validate_Ceiling
|
|   Description:   Validates new depreciation ceiling.
|
|   Parameters:    p_asset_id - Asset ID.
|                  p_book_type_code - Book(corporate or tax) the asset belongs to.
|		   p_old_ceiling_name - Current ceiling name.
|		   p_new_ceiling_name - New ceiling name.
|
|   Returns:       TRUE or FALSE (BOOLEAN)
|                  TRUE - Validation sucess.
|                  FALSE - Validation failed.
|
|   Notes:         Called from Validate_Rule_Changes.
|
+====================================================================================*/

FUNCTION Validate_Ceiling(
	p_asset_id              IN	NUMBER,
	p_book_type_code        IN	VARCHAR2,
	p_old_ceiling_name	IN	VARCHAR2,
	p_new_ceiling_name	IN	VARCHAR2
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)	RETURN BOOLEAN;


/*=====================================================================================+
|
|   Name:          Validate_Deprn_Flag
|
|   Description:   Validates new depreciation flag.
|
|   Parameters:	   p_old_rules - Current asset depreciation rules.
|		   p_new_rules - New asset depreciation rules.
|
|   Returns:       TRUE or FALSE (BOOLEAN)
|                  TRUE - Validation sucess.
|                  FALSE - Validation failed.
|
|   Notes:         Called from Validate_Rule_Changes.
|
+====================================================================================*/

FUNCTION Validate_Deprn_Flag(
	p_old_rules		IN	FA_LOAD_TBL_PKG.asset_deprn_info,
	p_new_rules		IN	FA_LOAD_TBL_PKG.asset_deprn_info
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)       RETURN BOOLEAN;


/*=====================================================================================+
|
|   Name:          Validate_Convention
|
|   Description:   Validates new prorate convention.
|
|   Parameters:    p_asset_id - Asset ID.
|                  p_book_type_code - Book(corporate or tax) the asset belongs to.
|		   p_date_placed_in_service - Date placed in service.
|		   p_old_conv - Current prorate convention.
|		   p_new_conv - New prorate convention.
|		   p_amortize_flag - Indicates whether to amortize the adjustment
|			or not.
|		   x_prorate_date - OUT NOCOPY value.  New prorate date from the new
|			prorate convention.
|
|   Returns:       TRUE or FALSE (BOOLEAN)
|                  TRUE - Validation sucess.
|                  FALSE - Validation failed.
|
|   Notes:         Called from Validate_Rule_Changes.
|
+====================================================================================*/

FUNCTION Validate_Convention(
        p_asset_id              IN      NUMBER,
        p_book_type_code        IN      VARCHAR2,
	p_date_placed_in_service IN	DATE,
	p_old_conv		IN	VARCHAR2,
	p_new_conv		IN	VARCHAR2,
	p_amortize_flag		IN	VARCHAR2,
	x_prorate_date	 OUT NOCOPY DATE
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)       RETURN BOOLEAN;


/*=====================================================================================+
|
|   Name:          Validate_Deprn_Method
|
|   Description:   Validates new depreciation method.
|
|   Parameters:    p_asset_id - Asset ID.
|                  p_book_type_code - Book(corporate or tax) the asset belongs to.
|		   p_old_deprn_method - Current depreciation method.
|		   p_new_deprn_method - New depreciation method.
|		   p_new_category_id - New category to change to.
|                  -- Next two arguments to implement short tax years.
|                  x_rate_source_rule - OUT NOCOPY value.  Identifies depreciation
|                       rate source.
|                  x_deprn_basis_rule - OUT NOCOPY value.  Depreciable basis --
|                       cost or NBV.
|
|   Returns:       TRUE or FALSE (BOOLEAN)
|                  TRUE - Validation sucess.
|                  FALSE - Validation failed.
|
|   Notes:         Called from Validate_Rule_Changes.
|
+====================================================================================*/

FUNCTION Validate_Deprn_Method(
        p_asset_id              IN      NUMBER,
        p_book_type_code        IN      VARCHAR2,
	p_old_deprn_method	IN	VARCHAR2,
	p_new_deprn_method	IN	VARCHAR2,
	p_new_category_id	IN	NUMBER,
        x_rate_source_rule      OUT NOCOPY     VARCHAR2,
        x_deprn_basis_rule      OUT NOCOPY     VARCHAR2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)       RETURN BOOLEAN;


/*=====================================================================================+
|
|   Name:          Validate_Life_Rates
|
|   Description:   Ensure that new life and rate values exist in the tables
|		   for the new depreciation method.
|
|   Parameters:    p_deprn_method - New depreciation method.
|		   p_basic_rate - New basic rate.
|		   p_adjusted_rate - New adjusted rate.
|		   p_life_in_months - New life.
|
|   Returns:       TRUE or FALSE (BOOLEAN)
|                  TRUE - Validation sucess.
|                  FALSE - Validation failed.
|
|   Notes:         Called from Validate_Rule_Changes.
|
+====================================================================================*/

FUNCTION Validate_Life_Rates(
	p_deprn_method		IN	VARCHAR2,
	p_basic_rate		IN	NUMBER,
	p_adjusted_rate		IN	NUMBER,
	p_life_in_months	IN	NUMBER
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)	RETURN BOOLEAN;


END FA_REC_PVT_PKG3;

/
