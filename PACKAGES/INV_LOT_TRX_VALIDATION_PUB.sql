--------------------------------------------------------
--  DDL for Package INV_LOT_TRX_VALIDATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LOT_TRX_VALIDATION_PUB" AUTHID CURRENT_USER AS
/* $Header: INVPLTVS.pls 120.6.12010000.2 2012/07/11 09:16:54 rdudani ship $ */

-- Global constant holding the package name
   G_PKG_NAME		CONSTANT VARCHAR2(30) := 'INV_LOT_TRX_VALIDATION_PUB';

   TYPE NUMBER_TABLE     IS TABLE of NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
   TYPE LOT_NUMBER_TABLE IS TABLE of VARCHAR2(80);
   --Tables added to support Lot Serialized Items in Lot Transactions(Split/Merge/Translate).
   TYPE SERIAL_NUMBER_TABLE IS TABLE OF MTL_SERIAL_NUMBERS.SERIAL_NUMBER%TYPE
     INDEX BY MTL_SERIAL_NUMBERS.SERIAL_NUMBER%TYPE;
   TYPE PARENT_LOT_TABLE IS TABLE OF MTL_LOT_NUMBERS.LOT_NUMBER%TYPE
     INDEX BY MTL_SERIAL_NUMBERS.SERIAL_NUMBER%TYPE;
   TYPE PARENT_LOC_TABLE IS TABLE OF MTL_ITEM_LOCATIONS.INVENTORY_LOCATION_ID%TYPE
     INDEX BY MTL_SERIAL_NUMBERS.SERIAL_NUMBER%TYPE;
   TYPE PARENT_SUB_TABLE IS TABLE OF  MTL_ITEM_LOCATIONS.SUBINVENTORY_CODE%TYPE
     INDEX BY MTL_SERIAL_NUMBERS.SERIAL_NUMBER%TYPE;


   TYPE SUB_CODE_TABLE   IS TABLE of Varchar2(30);
   TYPE REVISION_TABLE   IS TABLE of VARCHAR2(10);
   TYPE UOM_TABLE        IS TABLE OF VARCHAR2(3);
   TYPE DATE_TABLE is Table of Date;
   --Global table to hold attributes for Serialized Lot Items
   g_lot_ser_attributes_tbl INV_LOT_SEL_ATTR.lot_sel_attributes_tbl_type;
   g_lot_attributes_tbl INV_LOT_SEL_ATTR.lot_sel_attributes_tbl_type;


--********************************************************************************************
-- Procedure
--	Validate_Lots
-- Description:
--    This procedure will validate the records for lot transactions,
--    i.e., lot split, lot merge and lot translate.
--    It will validate that for lot trx, all records will have the same
--    organization and items. It will also validate that for lot
--    split, there is only one parent record and at least two resultant records.
--    For lot merge, it will have at least 2 parent records and 1 resultant records.
--    For lot translate, it will only have one parent record and 1 resultant records.
--    It will then call validate_start_lot to validate if the starting lot number is
--    a valid lot and validate_result_lot to validate the lot uniqueness of the
--    resultant lots.
-- Input Parameters:
--    p_transaction_type_id  - The transaction type for the lot transactions
--      Lot Split - 81
--      Lot Merge - 82
--      Lot Translate - 83
--    p_st_org_id_tbl - the starting lot organization IDs. This is an array of the
--      of the organization ids for the starting lots.
--    p_rs_org_id_tbl -- this is an array of the organization ids for the resulting lots.
--    p_st_item_id_tbl -- this is an array of the inventory item ids for the starting lots.
--    p_rs_item_id_tbl -- this is an array of the inventory item ids for the resulting lots.
--    p_st_lot_num_tbl -- this is an array of starting lot numbers
--    p_rs_lot_num_tbl -- this is an array of resulting lot numbers
--
--  Output Parameters:
--    x_return_status -- return status, S- success, E - error, U- unexpected error
--    x_msg_count     -- number of error message in the message stack.
--    x_msg_data      -- the error message on the top of the message stack.
--    x_validation_status -- 'Y' if validation is successfull, 'N' if not successfull.
--
--  Dependency:
--    None.
--
--  Called By:
--    INV_LOT_TRX_VALIDATION_PVT (INVVLTVB.pls)
--************************************************************************************************
   Procedure Validate_Lots(
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	x_validation_status	OUT NOCOPY VARCHAR2,
	p_transaction_Type_id	IN  NUMBER,
	p_st_org_id_tbl		IN  NUMBER_TABLE,
	p_rs_org_id_tbl		IN  NUMBER_TABLE,
	p_st_item_id_tbl	IN  NUMBER_TABLE,
	p_rs_item_id_tbl	IN  NUMBER_TABLE,
	p_st_lot_num_tbl	IN  LOT_NUMBER_TABLE,
        p_rs_lot_num_tbl	IN  LOT_NUMBER_TABLE,
	p_st_revision_tbl	IN  REVISION_TABLE,
	p_rs_revision_tbl	IN  REVISION_TABLE,
	p_st_quantity_tbl	IN  NUMBER_TABLE,
	p_rs_quantity_tbl	IN  NUMBER_TABLE,
	p_st_lot_exp_tbl 	IN  DATE_TABLE,
	p_rs_lot_exp_tbl	IN  DATE_TABLE
   );

  --********************************************************************************************
-- Procedure
--	Validate_Serials
-- Description:
--    This procedure will validate the records for lot transactions,
--    i.e., lot split, lot merge and lot translate for Serialized Lot Items
--    It validates wether the source serials match with the resulting serials. Also
--    checks if the serials are available by checking their group mark Id.
--    In case of lot translate transactions if the Items have changed then
--    INV_SERIAL_NUMBER_PUB.validate_serials is called to check for uniqueness and
--    create new serials if required.
-- Input Parameters:
--      p_transaction_type_id  - The transaction type for the lot transactions
--      Lot Split - 81
--      Lot Merge - 82
--      Lot Translate - 83
--     p_st_org_id_tbl - the starting lot organization IDs. This is an array of the
--      of the organization ids for the starting lots.
--    p_rs_org_id_tbl --  this is an array of the organization ids for the resulting lots.
--    p_st_item_id_tbl -- this is an array of the inventory item ids for the starting lots.
--    p_rs_item_id_tbl -- this is an array of the inventory item ids for the resulting lots.
--    p_st_lot_num_tbl -- this is an array of starting lot numbers
--    p_rs_lot_num_tbl -- this is an array of resulting lot numbers
--    p_st_ser_grp_mark_id_tbl -- this is an array of GM IDs for the starting serials.
--  Output Parameters:
--    x_return_status -- return status, S- success, E - error, U- unexpected error
--    x_msg_count     -- number of error message in the message stack.
--    x_msg_data      -- the error message on the top of the message stack.
--    x_validation_status -- 'Y' if validation is successfull, 'N' if not successfull.
--
--  Dependency:
--    None.
--
--  Called By:
--    INV_LOT_TRX_VALIDATION_PVT (INVVLTVB.pls)
--************************************************************************************************


   PROCEDURE validate_serials (
     x_return_status            OUT NOCOPY      VARCHAR2
   , x_msg_count                OUT NOCOPY      NUMBER
   , x_msg_data                 OUT NOCOPY      VARCHAR2
   , x_validation_status        OUT NOCOPY      VARCHAR2
   , p_transaction_type_id      IN              NUMBER
   , p_st_org_id_tbl            IN              number_table
   , p_rs_org_id_tbl            IN              number_table
   , p_st_item_id_tbl           IN              number_table
   , p_rs_item_id_tbl           IN              number_table
   , p_rs_lot_num_tbl           IN              lot_number_table
   , p_st_quantity_tbl          IN              number_table
   , p_st_sub_code_tbl          IN              sub_code_table
   , p_st_locator_id_tbl        IN              number_table
   , p_st_ser_number_tbl        IN              serial_number_table
   , p_st_ser_parent_lot_tbl    IN              parent_lot_table
   , p_rs_ser_number_tbl        IN              serial_number_table
   , p_st_ser_status_tbl        IN              number_table
   , p_st_ser_grp_mark_id_tbl   IN              number_table
   , p_st_ser_parent_sub_tbl    IN              parent_sub_table
   , p_st_ser_parent_loc_tbl    IN              parent_loc_table
   );


--********************************************************************************************
-- Procedure
--	Validate_Start_Lots
-- Description:
--    This procedure will validate the parent lot records for lot transactions,
--    i.e., lot split, lot merge and lot translate.
--    For lot split, it will validate if the lot is enabled for lot split transactions and
--        the lot is valid.
--    For lot merge, it will validate if the lot is enabled for lot merge transactions
--         and the lot is valid.
--    For Lot translate, it will validate if the item is lot control and the lot is valid.
--
-- Input Parameters:
--    p_transaction_type_id  - The transaction type for the lot transactions
--      Lot Split - 81
--      Lot Merge - 82
--      Lot Translate - 83
--    p_lot_number - the starting lot number
--    p_inventory_item_id -- inventory item id for the staring lot
--    p_organization_id -- organization_id for the starting lot.
--
--  Output Parameters:
--    x_return_status -- return status, S- success, E - error, U- unexpected error
--    x_msg_count     -- number of error message in the message stack.
--    x_msg_data      -- the error message on the top of the message stack.
--    x_validation_status -- 'Y' if validation is successfull, 'N' if not successfull.
--
--  Dependency:
--    None.
--
--  Called By:
--    This procedure will be called by procedure Validate_Lot above.
--    For lot merge transactions, this will be called for each of the lots to be merged.
--
--************************************************************************************************

   Procedure Validate_Start_Lot(
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	x_validation_status	OUT NOCOPY VARCHAR2,
	p_transaction_type_id	IN NUMBER,
	p_lot_number		IN VARCHAR2,
	p_inventory_item_id	IN NUMBER,
	p_organization_id	IN NUMBER
   );

--********************************************************************************************
-- Procedure
--	Validate_Result_Lots
-- Description:
--    This procedure will validate the resultant lot records for lot transactions,
--    i.e., lot split, lot merge and lot translate.
--    It will validate for lot uniqueness of the resultant lots for lot split and translate.
--    It will validate if the resultant lot number is not one of the starting lot numbers
--      for lot merge.
--
-- Input Parameters:
--    p_transaction_type_id  - The transaction type for the lot transactions
--      Lot Split - 81
--      Lot Merge - 82
--      Lot Translate - 83
--    p_st_lot_num_tbl -- array of starting lot numbers
--    p_rs_lot_num_tbl -- array of resultant lot numbers
--    p_inventory_item_id -- inventory item id for the resultant lot
--    p_organization_id -- organization_id for the resultant lot.
--
--  Output Parameters:
--    x_return_status -- return status, S- success, E - error, U- unexpected error
--    x_msg_count     -- number of error message in the message stack.
--    x_msg_data      -- the error message on the top of the message stack.
--    x_validation_status -- 'Y' if validation is successfull, 'N' if not successfull.
--
--  Dependency:
--    None.
--
--  Called By:
--    This procedure will be called by procedure Validate_Lot above.
--    For lot split transactions, this will be called for each resultant lots.
--
--************************************************************************************************

   Procedure Validate_Result_Lot(
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	x_validation_status	OUT NOCOPY VARCHAR2,
        p_transaction_type_id	IN NUMBER,
	p_st_lot_num_tbl	IN LOT_NUMBER_TABLE,
	p_rs_lot_num_tbl	IN LOT_NUMBER_TABLE,
	p_inventory_item_id	IN NUMBER,
	p_organization_id	IN NUMBER
   );

--********************************************************************************************
-- Procedure
--	Validate_Lot_Translate
-- Description:
--    This procedure will validate for lot translate, that either the lot number is changed
--     or the item is changed.
--
-- Input Parameters:
--    p_start_lot_number -- the starting lot number
--    p_start_inv_item_id -- the starting inventory item id.
--    p_result_lot_number -- the resultant lot number
--    p_result_inv_item_id -- the resulting  inventory item id.
--
--  Output Parameters:
--    x_return_status -- return status, S- success, E - error, U- unexpected error
--    x_msg_count     -- number of error message in the message stack.
--    x_msg_data      -- the error message on the top of the message stack.
--    x_validation_status -- 'Y' if validation is successfull, 'N' if not successfull.
--
--  Dependency:
--    None.
--
--  Called By:
--    This procedure will be called by procedure Validate_Lot above.
--
--************************************************************************************************

   Procedure Validate_Lot_Translate(
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	x_validation_status	OUT NOCOPY VARCHAR2,
        p_start_lot_number	IN VARCHAR2,
	p_start_inv_item_id	IN NUMBER,
	p_result_lot_number	IN VARCHAR2,
	p_result_inv_item_id	IN NUMBER
   );


--********************************************************************************************
-- Procedure
--	Validate_Lpn_Info
-- Description:
--    Perform basic validations for the LPNs present in the Lot transactions.
--
--
-- Input Parameters:
--    p_st_lpn_id_tbl -- the starting lpn ids
--    p_rs_lpn_id_tbl -- the resulting lpn ids
--
--  Output Parameters:
--    x_return_status -- return status, S- success, E - error, U- unexpected error
--    x_msg_count     -- number of error message in the message stack.
--    x_msg_data      -- the error message on the top of the message stack.
--    x_validation_status -- 'Y' if validation is successfull, 'N' if not successfull.
--
--  Dependency:
--    None.
--
--  Called By:
--    This procedure will be called by procedure validate_lot_split_trx,validate_lot_merge_trx
--    and  validate_lot_translate_trx.
--************************************************************************************************


   PROCEDURE validate_lpn_info (
     x_return_status            OUT NOCOPY      VARCHAR2
   , x_msg_count                OUT NOCOPY      NUMBER
   , x_msg_data                 OUT NOCOPY      VARCHAR2
   , x_validation_status        OUT NOCOPY      VARCHAR2
   , p_st_lpn_id_tbl            IN              number_table
   , p_rs_lpn_id_tbl            IN              number_table
   , p_st_org_id_tbl            IN              number_table
   , p_rs_org_id_tbl            IN              number_table
   , p_rs_sub_code_tbl          IN              sub_code_table
   , p_rs_locator_id_tbl        IN              number_table
   );


--********************************************************************************************
-- Procedure
--	Validate_Material_Status
-- Description:
--    This procedure will validate if the lot split, lot merge or lot translate
--      are enabled for the item, subinventory, locator and lot based on the status
--      of the subinventory, locator, and lot.
--
-- Input Parameters:
--    p_transaction_type_id  - The transaction type for the lot transactions
--      Lot Split - 81
--      Lot Merge - 82
--      Lot Translate - 83
--    p_lot_number - the starting lot number
--    p_inventory_item_id -- inventory item id for the staring lot
--    p_organization_id -- organization_id for the starting lot.
--    p_subinventory_code -- the subinventory where the lot resides
--    p_locator_id -- the locator where the lot resides
--    p_status_id -- the status of the lot number
--
--  Output Parameters:
--    x_return_status -- return status, S- success, E - error, U- unexpected error
--    x_msg_count     -- number of error message in the message stack.
--    x_msg_data      -- the error message on the top of the message stack.
--    x_validation_status -- 'Y' if validation is successfull, 'N' if not successfull.
--
--  Dependency:
--    INV_MATERIAL_STATUS_GROUP (INVMSGRB.pls and INVMSGRS.pls).
--
--  Called By:
--    This procedure will be called by INV_LOT_TRX_VALIDATION_PVT (INVVLTVB.pls)
--
--************************************************************************************************

   Procedure Validate_Material_Status(
      x_return_status		OUT NOCOPY VARCHAR2,
      x_msg_count		OUT NOCOPY NUMBER,
      x_msg_data		OUT NOCOPY VARCHAR2,
      x_validation_status	OUT NOCOPY VARCHAR2,
      p_transaction_type_id 	IN NUMBER,
      p_organization_id		IN NUMBER,
      p_inventory_item_id	IN NUMBER,
      p_lot_number		IN VARCHAR2,
      p_subinventory_code	IN VARCHAR2,
      p_locator_id		IN NUMBER,
      p_status_id		IN NUMBER,
      p_lpn_id      IN NUMBER DEFAULT NULL              -- bug 14269152
   );

--********************************************************************************************
-- Procedure
--	Validate_Cost_Groups
-- Description:
--    This procedure will validate cost group of the parent lots.
--    If the cost group of the parent lots are not populated, this procedure will call the
--       cost group engine to get the cost group of the lot.
--    This procedure will also return the cost group of the resultant lots.
--    Resultan lots will have the same cost group as the parent lots.
--    For lot merge, this procedure will check, if all the parent lots have the same cost groups.
--    If any of the parent lots have different cost groups, it will throw an error.
--
--    If the user populate the parent cost groups, it will check if the cost group is the same
--       as the one from the cost group engine. If they are different, this procedure also
--       returns error.
--
-- Input Parameters:
--    p_transaction_type_id  - The transaction type for the lot transactions
--      Lot Split - 81
--      Lot Merge - 82
--      Lot Translate - 83
--    p_transaction_Action_id - the transaction action id for lot transactions
--      Lot Split - 40
--      Lot Merge - 41
--      Lot Translate - 42
--    p_st_org_id_tbl  -- array of starting lot organization id.
--    p_st_item_id_tbl -- array of starting lot inventory item id
--    p_st_sub_code_tbl -- array of subinventory code for the starting lot.
--    p_st_loc_id_tbl -- array of locator id for the starting lot
--    p_st_lot_num_tbl -- array of staring lot numbers
--    p_st_cost_group_tbl -- array of cost group for starting lot.
--    p_st_revision_tbl -- array of revision for the starting lots.
--    p_st_lpn_id_tbl -- array of the lpn id for the starting lots.
--    p_rs_org_id_tbl  -- array of resultant lot organization id.
--    p_rs_item_id_tbl -- array of resultant lot inventory item id
--    p_rs_sub_code_tbl -- array of subinventory code for the resultant lot.
--    p_rs_loc_id_tbl -- array of locator id for the resultant lot
--    p_rs_lot_num_tbl -- array of resultant lot numbers
--    p_rs_cost_group_tbl -- array of cost group for resultant lot.
--    p_rs_revision_tbl -- array of revision for the resultant lots.
--
--  Output Parameters:
--    x_return_status -- return status, S- success, E - error, U- unexpected error
--    x_msg_count     -- number of error message in the message stack.
--    x_msg_data      -- the error message on the top of the message stack.
--    x_validation_status -- 'Y' if validation is successfull, 'N' if not successfull.
--
--  Dependency:
--    INV_COST_GROUP_UPDATE (INVCGUPB.pls and INVCGUPS.pls).
--
--  Called By:
--    This procedure will be called by INV_LOT_TRX_VALIDATION_PVT (INVVLTVB.pls)
--
--************************************************************************************************

  Procedure Validate_Cost_Groups(
	x_rs_cost_group_tbl	IN OUT NOCOPY NUMBER_TABLE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	x_validation_status	OUT NOCOPY VARCHAR2,
	p_transaction_type_id	IN NUMBER,
	p_transaction_action_id	IN NUMBER,
	p_st_org_id_tbl		IN NUMBER_TABLE,
	p_st_item_id_tbl	IN NUMBER_TABLE,
	p_st_sub_code_tbl	IN SUB_CODE_TABLE,
	p_st_loc_id_tbl		IN NUMBER_TABLE,
        p_st_lot_num_tbl        IN LOT_NUMBER_TABLE,
	p_st_cost_group_tbl	IN NUMBER_TABLE,
	p_st_revision_tbl	IN REVISION_TABLE,
	p_st_lpn_id_tbl		IN NUMBER_TABLE,
	p_rs_org_id_tbl		IN NUMBER_TABLE,
	p_rs_item_id_tbl	IN NUMBER_TABLE,
	p_rs_sub_code_tbl	IN SUB_CODE_TABLE,
	p_rs_loc_id_tbl		IN NUMBER_TABLE,
	p_rs_lot_num_tbl	IN LOT_NUMBER_TABLE,
	p_rs_revision_tbl	IN REVISION_TABLE,
	p_rs_lpn_id_tbl		IN NUMBER_TABLE
   );

--********************************************************************************************
-- Procedure
--	Validate_Quantity
-- Description:
--    This procedure will validate the quantity for lot split, merge or translate.
--    For lot split, it will validate if the parent lot quantity is the same as the total quantity
--        of the resultant lot
--    For lot merge, it will validate if the total qty of the parent lots match the quantity of the
--        resultant lot.
--    For Lot translate, it will validate if qty of the parent lot = qty of the resultant lot.
--
--    All qty is converted to the primary_qty (qty with primary unit of measure).

--    CHANGES FOR OSFM SUPPORT TO SERIALIZED LOT ITEMS :-
--    p_st_ser_number_tbl.COUNT should be equal to the starting lot quantity.
--    p_rs_ser_number_tbl.COUNT should equal the resulting lot quantity.
--    Individual lot quantity should match with the number of serials for that Lot.
--    The quantity in primary unit of measure should not be fractional.
--    Get the immediated LPN quantity ny passing the appropriate value for is_serial_control
--    Call the get_immediate_LPN_quantity for lot-merge transactions also.

-- Input Parameters:
--    p_transaction_type_id  - The transaction type for the lot transactions
--      Lot Split - 81
--      Lot Merge - 82
--      Lot Translate - 83
--    p_st_org_id_tbl  -- array of starting lot organization id.
--    p_st_item_id_tbl -- array of starting lot inventory item id
--    p_st_sub_code_tbl -- array of subinventory code for the starting lot.
--    p_st_loc_id_tbl -- array of locator id for the starting lot
--    p_st_lot_num_tbl -- array of staring lot numbers
--    p_st_cost_group_tbl -- array of cost group for starting lot.
--    p_st_revision_tbl -- array of revision for the starting lots.
--    p_st_lpn_id_tbl -- array of the lpn id for the starting lots.
--    p_st_quantity_tbl -- array of the quantity for starting lots.
--    p_st_uom_tbl -- array of the quantity for the starting lots.
--    p_rs_org_id_tbl  -- array of resultant lot organization id.
--    p_rs_item_id_tbl -- array of resultant lot inventory item id
--    p_rs_sub_code_tbl -- array of subinventory code for the resultant lot.
--    p_rs_loc_id_tbl -- array of locator id for the resultant lot
--    p_rs_lot_num_tbl -- array of resultant lot numbers
--    p_rs_cost_group_tbl -- array of cost group for resultant lot.
--    p_rs_quantity_tbl -- array of the quantity for resultant lots.
--    p_rs_uom_tbl -- array of the quantity for the resultant lots.
--
--  Output Parameters:
--    x_return_status -- return status, S- success, E - error, U- unexpected error
--    x_msg_count     -- number of error message in the message stack.
--    x_msg_data      -- the error message on the top of the message stack.
--    x_validation_status -- 'Y' if validation is successfull, 'N' if not successfull.
--
--  Dependency:
--    INV_UM_CONVERT (INVUMCNB.pls and INVUMCNS.pls).
--    INV_TXN_VALIDATIONS (INVMWAVB.pls and INVMWAVS.pls).
--
--  Called By:
--    This procedure will be called by INV_LOT_TRX_VALIDATION_PVT (INVVLTVB.pls )
--
--************************************************************************************************

   Procedure Validate_Quantity(
	x_return_status		  OUT NOCOPY VARCHAR2,
	x_msg_count		      OUT NOCOPY NUMBER,
	x_msg_data	        OUT NOCOPY VARCHAR2,
	x_validation_status	OUT NOCOPY VARCHAR2,
	p_transaction_type_id	IN NUMBER,
	p_st_org_id_tbl		IN NUMBER_TABLE,
	p_st_item_id_tbl	IN NUMBER_TABLE,
	p_st_sub_code_tbl	IN SUB_CODE_TABLE,
	p_st_loc_id_tbl		IN NUMBER_TABLE,
  p_st_lot_num_tbl        IN LOT_NUMBER_TABLE,
	p_st_cost_group_tbl	IN NUMBER_TABLE,
	p_st_revision_tbl	IN REVISION_TABLE,
	p_st_lpn_id_Tbl		IN NUMBER_TABLE,
	p_st_quantity_tbl	IN NUMBER_TABLE,
	p_st_uom_tbl		IN UOM_TABLE,
  --Added the following two tables for validations relevant to serials.
  p_st_ser_number_tbl     IN SERIAL_NUMBER_TABLE,
  p_st_ser_parent_lot_tbl IN PARENT_LOT_TABLE,
	p_rs_org_id_tbl		IN NUMBER_TABLE,
	p_rs_item_id_tbl	IN NUMBER_TABLE,
	p_rs_sub_code_tbl	IN SUB_CODE_TABLE,
	p_rs_loc_id_tbl		IN NUMBER_TABLE,
	p_rs_lot_num_tbl	IN LOT_NUMBER_TABLE,
	p_rs_cost_group_tbl	IN NUMBER_TABLE,
	p_rs_revision_tbl	IN REVISION_TABLE,
	p_rs_lpn_id_tbl		IN NUMBER_TABLE,
	p_rs_quantity_tbl	IN NUMBER_TABLE,
	p_rs_uom_tbl		IN UOM_TABLE,
  p_rs_ser_number_tbl       IN SERIAL_NUMBER_TABLE,
  p_rs_ser_parent_lot_tbl   IN parent_lot_table
  );


--********************************************************************************************
-- Procedure
--	Validate_Attributes
-- Description:
--    This procedure will validate the attributes of the resultant lots.
--    If the attributes of the resultant lots is not populated, and if the parent lot
--     has attributes, the resultant lot attributes will be derived from the parent lot.
--    If the parent lot does not have attributes, the resultant lot attributes will be
--    derived from default lot attributes.
--    THe procedure will then validate the lot attributes against the value set of
--    each segment in the attributes by calling descriptive flexfield validation APIs.
--
-- Input Parameters:
--    p_lot_number - the starting lot number
--    p_inventory_item_id -- inventory item id for the staring lot
--    p_organization_id -- organization_id for the starting lot.
--    p_parent_lot_attr_tbl -- the lot attributes data for the parent lot
--    p_result_lot_attr_tbl -- the lot attributes data for the resultant lot.
--
--  Output Parameters:
--    x_return_status -- return status, S- success, E - error, U- unexpected error
--    x_msg_count     -- number of error message in the message stack.
--    x_msg_data      -- the error message on the top of the message stack.
--    x_validation_status -- 'Y' if validation is successfull, 'N' if not successfull.
--
--  Dependency:
--    None.
--
--  Called By:
--    This procedure will be called by INV_LOT_TRX_VALIDATION_PVT (INVVLTVB.pls).
--
--************************************************************************************************

   Procedure validate_attributes
     (
      x_return_status		OUT NOCOPY VARCHAR2,
      x_msg_count		OUT NOCOPY NUMBER,
      x_msg_data		OUT NOCOPY VARCHAR2,
      x_validation_status	OUT NOCOPY VARCHAR2,
      x_lot_attr_tbl		OUT NOCOPY Inv_Lot_Sel_Attr.Lot_Sel_Attributes_Tbl_Type,
      p_lot_number		IN  VARCHAR2,
      p_organization_id	IN  NUMBER,
      p_inventory_item_id	IN  NUMBER,
      p_parent_lot_attr_tbl	IN  inv_lot_sel_attr.lot_sel_attributes_tbl_type,
      p_result_lot_attr_tbl	IN
      inv_lot_sel_attr.lot_sel_attributes_tbl_type,
      p_transaction_type_id   IN NUMBER
      );


   --********************************************************************************************
-- Procedure
--	Validate_Serial_Attributes
-- Description:
--    This procedure will validate the attributes of the resulting serials.
--    If the attributes of the resultant serials is not populated, then we DO NOT
--    derive the attribute from the parent serial.
--    If the resulting serial does not have attributes, the resultant serial attributes will be
--    derived from default serial attributes.
--    THe procedure will then validate the serial attributes against the value set of
--    each segment in the attributes by calling descriptive flexfield validation APIs.
--
-- Input Parameters:
--    p_ser_number  - the serial number
--    p_inventory_item_id -- inventory item id for the staring lot
--    p_organization_id -- organization_id for the starting lot.
--    p_result_ser_attr_tbl -- the serial attributes data for the resultant serial.
--
--  Output Parameters:
--    x_return_status -- return status, S- success, E - error, U- unexpected error
--    x_msg_count     -- number of error message in the message stack.
--    x_msg_data      -- the error message on the top of the message stack.
--    x_validation_status -- 'Y' if validation is successfull, 'N' if not successfull.
--    x_ser_attr_tbl  -- populated and validated attributes.
--  Dependency:
--    None.
--
--  Called By:
--    This procedure will be called by INV_TXN_MANAGER_GRP (INVTXGGB.pls)
--
--************************************************************************************************

     PROCEDURE validate_serial_attributes (
    x_return_status         OUT NOCOPY      VARCHAR2
  , x_msg_count             OUT NOCOPY      NUMBER
  , x_msg_data              OUT NOCOPY      VARCHAR2
  , x_validation_status     OUT NOCOPY      VARCHAR2
  , x_ser_attr_tbl          OUT NOCOPY      inv_lot_sel_attr.lot_sel_attributes_tbl_type
  , p_ser_number            IN              VARCHAR2
  , p_organization_id       IN              NUMBER
  , p_inventory_item_id     IN              NUMBER
  , p_result_ser_attr_tbl   IN              inv_lot_sel_attr.lot_sel_attributes_tbl_type
  );

--************************************************************************************************
-- Procedure
--      Validate_Organization
--
-- Description:
--      This procedure will validate the organization, checks if the Organization chosen
--      has a open period and also check if the acct_period_id pass is valid.
--
-- Input Parameters:
--      p_organization_id -- organization_Id of the starting lot.
--      p_period_id       -- account period id of the organization.
--
-- Output Parameters:
--      x_return_status -- return status, S- success, E - error, U- unexpected error
--      x_msg_count     -- number of error message in the message stack.
--      x_msg_data      -- the error message on the top of the message stack.
--      x_validation_status -- 'Y' if validation is successfull, 'N' if not successfull.
--
-- Dependency:
--      INV_INV_LOVS (INVINVLS.pls and INVINVLB.pls)
--      INVTTMTX (INVTTMTS.pls and INVTTMTB.pls)
--
-- Called By:
--      This procedure will be called by INV_LOT_TRX_VALIDATION_PVT (INVVLTVB.pls)

--************************************************************************************************

   Procedure Validate_Organization(
        x_return_status     	OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_validation_status     OUT NOCOPY VARCHAR2,
        p_organization_id       IN  NUMBER,
        p_period_tbl             IN  NUMBER_TABLE
				   );

   PROCEDURE compute_lot_expiration
     (
      x_return_status			OUT NOCOPY VARCHAR2,
      x_msg_count			OUT NOCOPY NUMBER,
      x_msg_data			OUT NOCOPY VARCHAR2,
      p_parent_id			IN NUMBER,
      p_transaction_type_id             IN NUMBER,
      p_item_id                        IN NUMBER,
      p_organization_id                IN NUMBER,
      p_st_lot_num	IN VARCHAR2,
      p_rs_lot_num_tbl	IN LOT_NUMBER_TABLE,
      p_rs_lot_exp_tbl	IN OUT NOCOPY date_table
      );

   procedure get_org_info
     (
      x_wms_installed   OUT NOCOPY VARCHAR2,
      x_wsm_enabled     OUT  NOCOPY VARCHAR2,
      x_wms_enabled	 OUT  NOCOPY VARCHAR2,
      x_return_status	 OUT  NOCOPY VARCHAR2,
      x_msg_count 	 OUT  NOCOPY NUMBER,
      x_msg_data	 OUT NOCOPY  VARCHAR2,
      p_organization_id IN NUMBER
      );
   --************************************************************************************************
-- Procedure
--      Update_Item_serial
--
-- Description:
--      This API is for the requirement from OSFM.
--      This procedure can possibly update the inventory_item_id (assembly), job number (Lot),
--      operation seq# and intraoperation step for the serial number passed.
--
-- Input Parameters:
--      p_org_id         -- Organization Id for the Serial
--      p_item_id        -- Current Item Id (assembly)
--      p_to_item_id     -- New Inventory Item Id (Can be NULL)
--      p_wip_entity_id  -- Current Job (Lot)
--      p_to_wip_entity_id -- New Job (Lot)
--      p_to_operation_sequence    -- New operation sequence
--      p_intraoperation_step_type -- New intraoperation step type
--
--
-- Output Parameters:
--      x_return_status -- return status, S- success, E - error, U- unexpected error
--      x_msg_count     -- number of error message in the message stack.
--      x_msg_data      -- the error message on the top of the message stack.
--      x_validation_status -- 'Y' if validation is successfull, 'N' if not successfull.
--
-- Dependency:
--
-- Called By:
--      This procedure will be called by OSFM from their forms.

--************************************************************************************************

   PROCEDURE update_item_serial (
                               x_msg_count         OUT NOCOPY VARCHAR2
                              ,x_return_status     OUT NOCOPY VARCHAR2
                              ,x_msg_data          OUT NOCOPY VARCHAR2
                              ,x_validation_status OUT NOCOPY VARCHAR2
                              ,p_org_id         IN NUMBER
                              ,p_item_id        IN NUMBER
                              ,p_to_item_id     IN NUMBER DEFAULT NULL
                              ,p_wip_entity_id  IN NUMBER
                              ,p_to_wip_entity_id         IN NUMBER DEFAULT NULL
                              ,p_to_operation_sequence    IN NUMBER DEFAULT NULL
                              ,p_intraoperation_step_type IN NUMBER DEFAULT  NULL
                              );
END INV_LOT_TRX_VALIDATION_PUB;

/
