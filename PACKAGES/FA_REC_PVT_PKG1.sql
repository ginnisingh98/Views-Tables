--------------------------------------------------------
--  DDL for Package FA_REC_PVT_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_REC_PVT_PKG1" AUTHID CURRENT_USER AS
/* $Header: FAXVRC1S.pls 120.3.12010000.2 2009/07/19 11:13:52 glchen ship $ */

/*=====================================================================================+
|
|   Name:          Validate_Reclass_Basic
|
|   Description:   Checks if basic reclass transaction -- change of category and
|		   account informaion only(no depreciation rule redefaulting) --
|		   can be performed.  Calls other child modules to perform
|		   the validation.
|
|   Parameters:    p_asset_id - Asset ID.
|		   p_old_category_id - Category to change from.
|		   p_new_category_id - New category to change to.
|		   p_mr_req_id - Mass request id.
|		   x_old_cat_type - Current category type.
|
|   Returns:	   TRUE or FALSE (BOOLEAN)
|		   TRUE - Validation sucess.
|		   FALSE - Validation failed.
|
|   Notes:         Called from FA_REC_PUB_PKG.Reclass_Asset(Reclass Public API.)
|
+====================================================================================*/

FUNCTION Validate_Reclass_Basic(
	p_asset_id		IN	NUMBER,
	p_old_category_id	IN	NUMBER,
	p_new_category_id	IN	NUMBER,
	p_mr_req_id		IN	NUMBER,
	x_old_cat_type		IN OUT NOCOPY VARCHAR2
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)	RETURN BOOLEAN;


/*=====================================================================================+
|
|   Name:          Check_Retirements
|
|   Description:   Function to check whether the asset is fully retired in any
|		   book or if there is any pending retirement for the asset.
|
|   Parameters:    p_asset_id - Asset ID.
|
|   Returns:	   TRUE or FALSE (BOOLEAN)
|		   TRUE - Validation sucess.
|		   FALSE - Validation failed.
|
|   Notes:         Called from Validate_Reclass_Basic().
|
+====================================================================================*/

FUNCTION Check_Retirements(
	p_asset_id		IN	NUMBER
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)	RETURN BOOLEAN;


/*=====================================================================================+
|
|   Name:          Validate_Category_Change
|
|   Description:   Function to validate category change.
|
|   Parameters:    p_asset_id - Asset ID.
|		   p_old_category_id - Category to change from.
|		   p_new_category_id - New category to change to.
|		   p_mr_req_id - Mass reqeust id.
|		   x_old_cat_type - Current category type.
|
|   Returns:	   TRUE or FALSE (BOOLEAN)
|		   TRUE - Validation sucess.
|		   FALSE - Validation failed.
|
|   Notes:         Called from Validate_Reclass_Basic().
|
+====================================================================================*/

FUNCTION Validate_Category_Change(
	p_asset_id		IN	NUMBER,
	p_old_category_id	IN	NUMBER,
	p_new_category_id	IN	NUMBER,
	p_mr_req_id		IN	NUMBER,
	x_old_cat_type		IN OUT NOCOPY VARCHAR2
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)	RETURN BOOLEAN;


/*=====================================================================================+
 |
 |   Name:          Check_Trans_Date
 |
 |   Description:   Check the transaction_date_entered value that will be
 |                  inserted into FA_TRANSACTION_HEADERS table.  No other transaction
 |                  should follow between the transaction_date_entered and the current
 |                  date.
 |
 |   Parameters:    p_asset_id - Asset ID.
 |                  p_book_type_code - Book the asset belongs to.
 |                  p_trans_date - Transaction date entered.
 |
 |   Returns:       TRUE or FALSE (BOOLEAN)
 |                  TRUE - Operation sucess.
 |                  FALSE - Operation failed.
 |
 |   Notes:         Called from Set_Redef_Transaction and
 |
 +====================================================================================*/

FUNCTION Check_Trans_Date(
        p_asset_id              IN      NUMBER,
        p_book_type_code        IN      VARCHAR2,
        p_trans_date            IN      DATE
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

END FA_REC_PVT_PKG1;

/
