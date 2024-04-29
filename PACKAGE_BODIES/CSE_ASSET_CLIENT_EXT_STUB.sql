--------------------------------------------------------
--  DDL for Package Body CSE_ASSET_CLIENT_EXT_STUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_ASSET_CLIENT_EXT_STUB" AS
-- $Header: CSEFASTB.pls 120.2.12010000.1 2008/07/30 05:17:34 appldev ship $

l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('CSE_DEBUG_OPTION'),'N');

-----------------------------------------------------------------------------
--      PLEASE set x_hook_used to 1 if you are deriving the value
--      By default x_hook_used to 0.
-----------------------------------------------------------------------------

PROCEDURE get_asset_name(
	p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
	x_asset_name            OUT NOCOPY       VARCHAR2,
	x_hook_used             OUT NOCOPY       NUMBER,
	x_error_msg             OUT NOCOPY       VARCHAR2)
	IS
	BEGIN
	x_hook_used := 0 ;
	-- Please set the X_HOOK_USED to 1 if you are deriving the value
	x_error_msg := null ;

	-- Please add your code here if you want to override the default
	-- functionality of deriving asset name.
	NULL ;
END get_asset_name;

---------------------------------------------------------------------------

PROCEDURE get_asset_description(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_description           OUT NOCOPY       VARCHAR2
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2)
IS
BEGIN
   x_hook_used := 0 ;
   --  PLEASE set the X_HOOK_USED to 1 if you are deriving the value
   x_error_msg := null ;

-- Please add your code here if you want to override the default
--   functionality of deriving asset description.
NULL ;
END get_asset_description ;

---------------------------------------------------------------------------

PROCEDURE get_asset_category(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2)
IS
BEGIN
   x_hook_used := 0 ;
   -- PLEASE set the X_HOOK_USED to 1 if you are deriving the value
   x_error_msg := null ;

-- Please add your code here if you want to override the default
-- functionality of deriving Asset Category

NULL ;
END get_asset_category ;

---------------------------------------------------------------------------+

PROCEDURE get_book_type(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2)
IS
BEGIN
   x_hook_used := 0 ;
   -- PLEASE set the X_HOOK_USED to 1 if you are deriving the value
   x_error_msg := null ;

-- Please add your code here if you want to override the default
-- functionality of deriving FA book type code .
NULL ;
END get_book_type ;

---------------------------------------------------------------------------

PROCEDURE get_date_place_in_service(
    p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_in_service_date       OUT NOCOPY       DATE
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2)
IS
BEGIN
   x_hook_used := 0 ;
   -- PLEASE set the X_HOOK_USED to 1 if you are deriving the value
   x_error_msg := null ;

-- Please add your code here if you want to override the default
--   functionality of deriving Date Placed In Service.
NULL ;
END get_date_place_in_service ;

---------------------------------------------------------------------------

PROCEDURE get_asset_key(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_asset_key_ccid        OUT NOCOPY       NUMBER
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2)
IS
BEGIN
   x_hook_used := 0 ;
   -- PLEASE set the X_HOOK_USED to 1 if you are deriving the value
   x_error_msg := null ;

-- Please add your code here if you want to override the default
-- functionality of deriving asset key.
NULL ;
END get_asset_key ;

---------------------------------------------------------------------------

PROCEDURE get_asset_location(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2)
IS
BEGIN
   x_hook_used := 0 ;
   -- PLEASE set the X_HOOK_USED to 1 if you are deriving the value
   x_error_msg := null ;

-- Please add your code here if you want to override the default
-- functionality of deriving asset location.
NULL ;
END get_asset_location ;

---------------------------------------------------------------------------

PROCEDURE get_deprn_expense_ccid(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_deprn_expense_ccid    OUT NOCOPY       NUMBER
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2)
IS
BEGIN
   x_hook_used := 0 ;
   -- PLEASE set the X_HOOK_USED to 1 if you are deriving the value
   x_error_msg := null ;

-- Please add your code here if you want to override the default
-- functionality of deriving Depreciation Expense CCID.
NULL ;
END get_deprn_expense_ccid ;

--------------------------------------------------------------------------

PROCEDURE get_search_method(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_search_method         OUT NOCOPY       VARCHAR2
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2)
IS
BEGIN
   x_hook_used := 0 ;
   -- PLEASE set the X_HOOK_USED to 1 if you are deriving the value
   x_error_msg := null ;

-- Please add your code here if you want to override the default
-- functionality of deriving search method .
NULL ;
END get_search_method ;

---------------------------------------------------------------------------

PROCEDURE get_tag_number(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_tag_number         OUT NOCOPY       VARCHAR2
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2)
IS
BEGIN
   x_hook_used := 0 ;
   -- PLEASE set the X_HOOK_USED to 1 if you are deriving the value
   x_error_msg := null ;

-- Please add your code here if you want to override the default
--   functionality of deriving tag number.
NULL ;
END get_tag_number ;

---------------------------------------------------------------------------

PROCEDURE get_model_number(
   p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_model_number         OUT NOCOPY       VARCHAR2
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2)
IS
BEGIN
   x_hook_used := 0 ;
   -- PLEASE set the X_HOOK_USED to 1 if you are deriving the value
   x_error_msg := null ;

-- Please add your code here if you want to override the default
-- functionality of deriving model number.
NULL ;
END get_model_number ;

---------------------------------------------------------------------------

PROCEDURE get_manufacturer(
   p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_manufacturer_name     OUT NOCOPY       VARCHAR2
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2)
IS
BEGIN
   x_hook_used := 0 ;
   -- PLEASE set the X_HOOK_USED to 1 if you are deriving the value
   x_error_msg := null ;

-- Please add your code here if you want to override the default
-- functionality of deriving manufacturer name.
NULL ;
END get_manufacturer ;

---------------------------------------------------------------------------

PROCEDURE get_employee(
   p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_employee_id           OUT NOCOPY       NUMBER
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2)
IS
BEGIN
   x_hook_used := 0 ;
   -- PLEASE set the X_HOOK_USED to 1 if you are deriving the value
   x_error_msg := null ;

-- Please add your code here if you want to override the default
--   functionality of deriving Employee ID.
NULL ;
END get_employee ;

---------------------------------------------------------------------------

PROCEDURE get_payables_ccid(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_payables_ccid         OUT NOCOPY       NUMBER
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2)
IS
BEGIN
   x_hook_used := 0 ;
   -- PLEASE set the X_HOOK_USED to 1 if you are deriving the value
   x_error_msg := null ;

-- Please add your code here if you want to override the default
--   functionality of deriving Payables CCID.
NULL ;
END get_payables_ccid ;

--------------------------------------------------------------------------

PROCEDURE get_txn_class_flag(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, p_txn_class             IN        VARCHAR2
, x_process_flag          OUT NOCOPY       VARCHAR2
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2)
IS
BEGIN

   x_hook_used := 0 ;
    -- PLEASE set the X_HOOK_USED to 1 if you are deriving the value
   x_error_msg := null ;

-- Please add your code here if you want to override the default
--   functionality of deriving Transaction Class Flag.
END get_txn_class_flag ;


---------------------------------------------------------------------------

PROCEDURE get_catchup_flag(
  p_asset_number          IN        VARCHAR2,
  p_instance_asset_id     IN        NUMBER,
  x_catchup_flag          OUT NOCOPY       VARCHAR2,
  x_hook_used             OUT NOCOPY       NUMBER,
  x_error_msg             OUT NOCOPY       VARCHAR2)
IS
BEGIN
   x_hook_used := 0 ;
   -- PLEASE set the X_HOOK_USED to 1 if you are deriving the value
   x_error_msg := null ;

-- Please add your code here if you want to override the default
--   functionality of deriving Depreciation Catchup Flag.

END get_catchup_flag ;

---------------------------------------------------------------------------
PROCEDURE get_inv_depr_acct(
  p_mtl_transaction_id    IN        NUMBER
, x_dummy_acct_id         OUT NOCOPY       NUMBER
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2)
IS
BEGIN

   x_hook_used := 0 ;
   -- PLEASE set the X_HOOK_USED to 1 if you are deriving the value
   x_error_msg := null ;

-- Please add your code here if you want to override the default
--  functionality of deriving the dummy inventory acct for depreciable items.
END get_inv_depr_acct ;
---------------------------------------------------------------------------
PROCEDURE get_inventory_item(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2)
IS
BEGIN

   x_hook_used := 0 ;
    -- PLEASE set the X_HOOK_USED to 1 if you are deriving the value
   x_error_msg := null ;

-- Please add your code here if you want to override the default
--   functionality of maintaining/creating Fixed Asset using Inventory Item.
--  By default Fixed Asset NOT will be created based on Inventory Item.
-- If you want to create Fixed Asset based on Inventory Item, please set the
--  x_inventory_item_id to the Inventory_item_id, which you can get from CSI_TRANSACTION_ID

END get_inventory_item ;

---------------------------------------------------------------------------
PROCEDURE get_non_mtl_retire_flag(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, p_asset_id              IN        NUMBER
, x_retire_flag           OUT NOCOPY       VARCHAR2
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2)
IS
BEGIN

   x_hook_used := 0 ;
   -- PLEASE set the X_HOOK_USED to 1 if you are deriving the value
   x_error_msg := null ;

-- Please add your code here if you want to override the default
--   functionality of Retiring Non Material Costs.

END get_non_mtl_retire_flag ;

---------------------------------------------------------------------------
PROCEDURE get_product_code(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_product_code          OUT NOCOPY       VARCHAR2
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2)
IS
BEGIN

   x_hook_used := 0 ;
   -- PLEASE set the X_HOOK_USED to 1 if you are deriving the value
   x_error_msg := null ;

-- Please add your code here if you want to override the default
--   functionality of deriving Product Code which will be used
--   in grouping the asset

END get_product_code ;

---------------------------------------------------------------------------
END CSE_ASSET_CLIENT_EXT_STUB ;

/
