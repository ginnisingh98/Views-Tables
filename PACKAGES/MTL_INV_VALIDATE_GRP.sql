--------------------------------------------------------
--  DDL for Package MTL_INV_VALIDATE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_INV_VALIDATE_GRP" AUTHID CURRENT_USER AS
/* $Header: INVGIVVS.pls 120.2 2005/06/22 09:56:00 appldev ship $ */

-- computes date which corresponds to offset from a given date
--Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data x_result_date
--OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
procedure Get_Offset_Date(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_start_date IN DATE,
  p_offset_days IN NUMBER,
  p_calendar_code IN VARCHAR2,
  p_exception_set_id IN NUMBER,
  x_result_date OUT NOCOPY DATE);

  --
  -- Derive Count Uom
  PROCEDURE Get_CountUom(
  p_uom_code IN VARCHAR2 )
;
  --
  -- Dervies Item and SKU information from the given Count List Sequence
  PROCEDURE Get_Item_SKU(
  p_cycle_count_entry_rec IN  MTL_CYCLE_COUNT_ENTRIES%ROWTYPE )
;
  --
  -- Get the STOCK_LOCATOR_CONTROL_CODE from the given ORG_ID
  PROCEDURE Get_StockLocatorControlCode(
  p_organization_id IN NUMBER )
;
  --
  -- Validates the adjustment account
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data
  --OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Validate_AdjustAccount(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_adjustaccount_rec IN MTL_CCEOI_VAR_PVT.ADJUSTACCOUNT_REC_TYPE )
;
  --
  -- Validates the count date
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data ,x_errorcode
  --OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Validate_CountDate(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_count_date IN DATE )
;
  --
  -- Validate count header
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data ,x_errorcode
  --OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Validate_CountHeader(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY VARCHAR2 ,
  p_cycle_count_header_id IN NUMBER DEFAULT NULL,
  p_cycle_count_header_name IN VARCHAR2 DEFAULT NULL)
;
  --
  -- Validate count_list_sequence
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data ,x_errorcode
  --OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Validate_CountListSequence(
  p_api_version  NUMBER ,
  p_init_msg_list  VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit  VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY number ,
  p_cycle_count_header_id IN number ,
  p_cycle_count_entry_id IN number ,
  p_count_list_sequence IN number ,
  p_organization_id IN NUMBER )
;
  --
  -- Validate the count quantity (if negative)
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data ,x_errorcode
  --OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Validate_CountQuantity(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_count_quantity IN NUMBER )
;
  --
  -- Validates Control information this item
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data ,x_errorcode
  --OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Validate_Ctrol(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_inventory_item_id IN NUMBER ,
  p_organization_id IN NUMBER ,
  p_locator_rec IN MTL_CCEOI_VAR_PVT.INV_LOCATOR_REC_TYPE ,
  p_lot_number IN VARCHAR2 ,
  p_revision IN VARCHAR2 ,
  p_serial_number IN VARCHAR2 ,
  p_locator_control IN NUMBER )
;
  --
  -- Validates Count UOM or/and Unit of Measure
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data ,x_errorcode
  --OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Validate_CountUOM(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_count_uom IN VARCHAR2 DEFAULT NULL,
  p_count_unit_of_measure IN VARCHAR2 DEFAULT NULL,
  p_organization_id IN NUMBER ,
  p_inventory_item_id IN NUMBER )
;
  --
  --
  -- Validates Item information
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data ,x_errorcode
  --OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Validate_Item(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  P_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_inventory_item_rec IN MTL_CCEOI_VAR_PVT.INV_ITEM_REC_TYPE ,
  p_organization_id IN NUMBER ,
  p_cycle_count_header_id IN NUMBER DEFAULT NULL)
;
  --
  -- Validates locator information
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data ,x_errorcode
  --OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Validate_Locator(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_locator_rec IN MTL_CCEOI_VAR_PVT.INV_LOCATOR_REC_TYPE ,
  p_organization_id IN NUMBER ,
  P_subinventory IN VARCHAR2 ,
  p_inventory_item_id IN NUMBER ,
  p_locator_control IN NUMBER ,
  p_control_level IN NUMBER ,
  p_restrict_control IN NUMBER,
  p_simulate IN VARCHAR2 DEFAULT FND_API.G_FALSE)
;
  --
  --
  -- Validate the primary uom quantity
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data ,x_errorcode
  --OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Validate_PrimaryUomQuantity(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_primary_uom_quantity IN NUMBER ,
  p_primary_uom_code IN VARCHAR2 )
;
  --
  -- Validates subinventory
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data ,x_errorcode
  --OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Validate_Subinv(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_subinventory IN VARCHAR2 ,
  p_organization_id IN NUMBER ,
  p_orientation_code IN NUMBER DEFAULT MTL_CCEOI_VAR_PVT.G_ORIENTATION_CODE,
  p_cycle_count_header_id IN NUMBER DEFAULT MTL_CCEOI_VAR_PVT.G_CC_HEADER_ID)
;
  --
  -- Is the item under Locator control
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data ,x_locator_control
  --x_level OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Locator_Control(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_org_control IN NUMBER ,
  p_sub_control IN NUMBER ,
  p_item_control IN NUMBER DEFAULT NULL,
  p_restrict_flag IN NUMBER DEFAULT NULL,
  p_neg_flag IN NUMBER DEFAULT NULL,
  p_action IN NUMBER DEFAULT NULL,
  x_locator_control OUT NOCOPY NUMBER ,
  x_level OUT NOCOPY NUMBER )
;
  --
  -- .
  FUNCTION No_Neg_Balance(
  restrict_flag IN NUMBER ,
  neg_flag IN NUMBER DEFAULT 38,
  action IN NUMBER DEFAULT 38)
RETURN VARCHAR2;
  --

  -- BEGIN INVCONV
  PROCEDURE validate_secondarycountuom (
     p_api_version                 IN         NUMBER
   , p_init_msg_list               IN         VARCHAR2 DEFAULT fnd_api.g_false
   , p_commit                      IN         VARCHAR2 DEFAULT fnd_api.g_false
   , p_validation_level            IN         NUMBER DEFAULT fnd_api.g_valid_level_full
   , x_return_status               OUT NOCOPY VARCHAR2
   , x_msg_count                   OUT NOCOPY NUMBER
   , x_msg_data                    OUT NOCOPY VARCHAR2
   , x_errorcode                   OUT NOCOPY NUMBER
   , p_organization_id             IN         NUMBER
   , p_inventory_item_id           IN         NUMBER
   , p_secondary_uom               IN         VARCHAR2
   , p_secondary_unit_of_measure   IN         VARCHAR2
   , p_tracking_quantity_ind       IN         VARCHAR2);

  PROCEDURE validate_secondarycountqty (
     p_api_version                 IN         NUMBER
   , p_init_msg_list               IN         VARCHAR2 DEFAULT fnd_api.g_false
   , p_commit                      IN         VARCHAR2 DEFAULT fnd_api.g_false
   , p_validation_level            IN         NUMBER DEFAULT fnd_api.g_valid_level_full
   , p_precision                   IN         NUMBER DEFAULT 5
   , x_return_status               OUT NOCOPY VARCHAR2
   , x_msg_count                   OUT NOCOPY NUMBER
   , x_msg_data                    OUT NOCOPY VARCHAR2
   , x_errorcode                   OUT NOCOPY NUMBER
   , p_organization_id             IN         NUMBER
   , p_inventory_item_id           IN         NUMBER
   , p_lot_number                  IN         VARCHAR2
   , p_count_uom                   IN         VARCHAR2
   , p_count_quantity              IN         NUMBER
   , p_secondary_uom               IN         VARCHAR2
   , p_secondary_quantity          IN         VARCHAR2
   , p_tracking_quantity_ind       IN         VARCHAR2
   , p_secondary_default_ind       IN         VARCHAR2);

  -- END INVCONV

END MTL_INV_VALIDATE_GRP;

 

/
