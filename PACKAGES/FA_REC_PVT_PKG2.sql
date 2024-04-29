--------------------------------------------------------
--  DDL for Package FA_REC_PVT_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_REC_PVT_PKG2" AUTHID CURRENT_USER AS
/* $Header: FAXVRC2S.pls 120.2.12010000.2 2009/07/19 11:14:47 glchen ship $ */

/*=====================================================================================+
|
|   Name:          Validate_Redefault
|
|   Description:   Checks if depreciation rules can be redefaulted from the new
|		   category.  Calls other child modules to perform the validation.
|
|   Parameters:	   p_asset_id - Asset ID.
|                  p_new_category_id - New category to change to.
|		   p_book_type_code - Book(corporate or tax) the asset belongs to.
|   		   p_amortize_flag - Indicates whether to amortize the adjustment
|		   	or not.
|		   p_mr_req_id - Mass request ID.  -1 by default for single transaction.
|		   x_rule_change_exists - OUT NOCOPY value.  Indicates whether
|			depreciation rule change exists from redefaulting the rules
|			from the new category.
|		   x_old_rules - OUT NOCOPY value.  Current depreciation rules record.
|		   x_new_rules - OUT NOCOPY value.  New depreciation rules record from
|			the new category.
|		   x_use_rules - OUT NOCOPY value.  Indicates whether to use the
|			old and new rules record or not. Providing this value,
|			since PL/SQL record cannot be compared against NULL.
|		   x_prorate_date - OUT NOCOPY value.  New prorate date from the new
|			prorate convention.
|		   -- Next two arguments to implement short tax years.
|		   x_rate_source_rule - OUT NOCOPY value.  Identifies depreciation
|			rate source.
|		   x_deprn_basis_rule - OUT NOCOPY value.  Depreciable basis --
|			cost or NBV.
|
|   Returns:       TRUE or FALSE (BOOLEAN)
|                  TRUE - Validation sucess.
|                  FALSE - Validation failed.
|
|   Notes:         Called from Redefault_Asset.
|
+====================================================================================*/

FUNCTION Validate_Redefault(
        p_asset_id              IN      NUMBER,
        p_new_category_id       IN      NUMBER,
	p_book_type_code	IN	VARCHAR2,
	p_amortize_flag		IN	VARCHAR2 := 'NO',
	p_mr_req_id		IN	NUMBER := -1,
	x_rule_change_exists OUT NOCOPY BOOLEAN,
	x_old_rules	 OUT NOCOPY FA_LOAD_TBL_PKG.asset_deprn_info,
        x_new_rules             OUT NOCOPY  	FA_LOAD_TBL_PKG.asset_deprn_info,
        x_use_rules          OUT NOCOPY  	BOOLEAN,
	x_prorate_date	 OUT NOCOPY DATE,
        x_rate_source_rule      OUT NOCOPY     VARCHAR2,
        x_deprn_basis_rule      OUT NOCOPY     VARCHAR2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)       RETURN BOOLEAN;


/*=====================================================================================+
|
|   Name:          Validate_Adjustment
|
|   Description:   Function to validate an adjustment transaction.
|
|   Parameters:	   p_asset_id - Asset ID.
|		   p_book_type_code - Book(corporate or tax) the asset belongs to.
|   		   p_amortize_flag - Indicates whether to amortize the adjustment
|		   	or not.
|		   p_mr_req_id - Mass request ID.  -1 by default for single transaction.
|
|   Returns:       TRUE or FALSE (BOOLEAN)
|                  TRUE - Validation sucess.
|                  FALSE - Validation failed.
|
|   Notes:         Called from Validate_Redefault.
|
+====================================================================================*/

FUNCTION Validate_Adjustment(
        p_asset_id              IN      NUMBER,
	p_book_type_code	IN	VARCHAR2,
	p_amortize_flag		IN	VARCHAR2,
	p_mr_req_id		IN	NUMBER := -1
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)       RETURN BOOLEAN;

END FA_REC_PVT_PKG2;

/
