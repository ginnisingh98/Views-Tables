--------------------------------------------------------
--  DDL for Package MTL_CCEOI_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_CCEOI_PROCESS_PVT" AUTHID CURRENT_USER AS
/* $Header: INVVCCPS.pls 120.2 2005/06/22 09:52:32 appldev ship $ */
  --
  -- Calculates adjustments for Step 4
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data x_errorcode OUT
  --parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
  PROCEDURE Calculate_Adjustment(
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
  p_lpn_id IN NUMBER DEFAULT NULL,
  p_subinventory IN VARCHAR2 ,
  p_count_quantity IN NUMBER ,
  p_revision IN VARCHAR2 DEFAULT NULL,
  p_locator_id IN NUMBER DEFAULT NULL,
  p_lot_number IN VARCHAR2 DEFAULT NULL,
  p_serial_number IN VARCHAR2 DEFAULT NULL,
  p_serial_number_control_code IN NUMBER ,
  p_serial_count_option IN NUMBER ,
  p_system_quantity IN NUMBER DEFAULT NULL,
  p_secondary_system_quantity IN NUMBER DEFAULT NULL) -- INVCONV
;
  --
  -- Deletes entries in the interface tables
  PROCEDURE Delete_CCIEntry(
  p_cc_entry_interface_id IN NUMBER )
;
  --
  -- Delete records from the cycle count interface error table
  PROCEDURE Delete_CCEOIError(
  p_cc_entry_interface_id IN NUMBER )
;
  --
  -- Insert the record into the application tables
  PROCEDURE Insert_CCEntry(
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE )
;
  --
  -- Insert the given record into MTL_CC_ENTRIES_INTERFACE
  --Added NOCOPY hint to x_return_status OUT
  --parameter to comply with GSCC File.Sql.39 standard. Bug:4410902
  PROCEDURE Insert_CCIEntry(
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE ,
  x_return_status OUT NOCOPY VARCHAR2 )
;
  --
  -- Insert record into Cycle Count Interface error table
  PROCEDURE Insert_CCEOIError(
  p_cc_entry_interface_id IN NUMBER ,
  p_error_column_name IN VARCHAR2 ,
  p_error_table_name IN VARCHAR2 ,
  p_message_name IN VARCHAR2 )
;
  --
  -- Set the export flag in the table MTL_CYCLE_COUNT_ENTRIES
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data OUT
  --parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
  PROCEDURE Set_CCExport(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_cycle_count_entry_id IN NUMBER ,
  p_export_flag IN NUMBER )
;
  --
  -- Set the Flags in the interface table.
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data OUT
  --parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
  PROCEDURE Set_CCEOIFlags(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_cc_entry_interface_id IN NUMBER ,
  p_flags IN VARCHAR2 )
;
  --
  -- Validates the cycle count header
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data ,x_errorcode OUT
  --parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
  PROCEDURE Validate_CHeader(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_cycle_count_header_id IN NUMBER ,
  p_cycle_count_header_name IN VARCHAR2 DEFAULT NULL)
;
  --
  -- Validate the count list sequence of the cycle count entry
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data ,x_errorcode OUT
  --parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
  PROCEDURE Validate_CountListSeq(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_cycle_count_header_id IN NUMBER ,
  p_cycle_count_entry_id IN NUMBER ,
  p_count_list_sequence IN NUMBER ,
  p_organization_id IN NUMBER )
;
  --
  -- validate item and sku information
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data ,x_errorcode OUT
  --parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
  PROCEDURE Validate_ItemSKU(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_cycle_count_header_id IN NUMBER ,
  p_inventory_item_rec IN MTL_CCEOI_VAR_PVT.Inv_Item_rec_type ,
  p_sku_rec IN MTL_CCEOI_VAR_PVT.Inv_SKU_Rec_Type ,
  p_subinventory IN VARCHAR2 ,
  p_locator_rec IN MTL_CCEOI_VAR_PVT.INV_LOCATOR_REC_TYPE ,
  p_organization_id IN number,
  p_simulate IN VARCHAR2 DEFAULT FND_API.G_FALSE)
;
  --
  -- Validate the UOM and quantity information
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data ,x_errorcode OUT
  --parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
  PROCEDURE Validate_UOMQuantity(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_primary_uom_quantity IN NUMBER DEFAULT NULL,
  p_count_uom IN VARCHAR2 DEFAULT NULL,
  p_count_unit_of_measure IN VARCHAR2 DEFAULT NULL,
  p_organization_id IN NUMBER ,
  p_lpn_id IN NUMBER DEFAULT NULL,
  p_inventory_item_id IN NUMBER ,
  p_count_quantity IN NUMBER ,
  p_serial_number IN VARCHAR2 DEFAULT NULL,
  p_subinventory IN VARCHAR2,
  p_revision IN VARCHAR2 DEFAULT NULL,
  p_lot_number IN VARCHAR2 ,
  p_system_quantity IN NUMBER,
  p_secondary_system_quantity IN NUMBER) -- INVCONV
;
  --
  -- Validate count date and counter
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data ,x_errorcode OUT
  --parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
  PROCEDURE Validate_CDate_Counter(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_employee_id IN NUMBER ,
  p_employee_name IN VARCHAR2 DEFAULT NULL,
  p_count_date IN DATE )
;
  --
  -- Processed the interface record
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data ,x_errorcode OUT
  --parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
  PROCEDURE Process_Data(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_simulate IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE )
;
  --
  -- updates CC entry record information
  PROCEDURE Update_CCEntry(
  p_cycle_count_entry_id IN NUMBER );

  -- updates interface record information
  --Added NOCOPY hint to x_return_status OUT
  --parameter to comply with GSCC File.Sql.39 standard. Bug:4410902
  PROCEDURE Update_CCIEntry(
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE ,
  x_return_status OUT NOCOPY VARCHAR2 );
  --
  FUNCTION check_serial_location(P_issue_receipt IN VARCHAR2,
				 p_simulate IN VARCHAR2 DEFAULT FND_API.G_FALSE ) return BOOLEAN;

  -- resets all global variables to null to prevent their accidental reuse
  -- on next call of the public api in the same session
  PROCEDURE Reset_Global_Vars;

 PROCEDURE DELETE_RESERVATION (
  p_subinventory IN VARCHAR2 ,
  p_lot_number IN VARCHAR2 ,
  p_revision IN VARCHAR2 );

 -- BEGIN INVCONV
 PROCEDURE validate_secondaryuomqty (
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
   , p_lpn_id                      IN         NUMBER DEFAULT NULL
   , p_serial_number               IN         VARCHAR2 DEFAULT NULL
   , p_subinventory                IN         VARCHAR2
   , p_revision                    IN         VARCHAR2 DEFAULT NULL
   , p_lot_number                  IN         VARCHAR2
   , p_secondary_uom               IN         VARCHAR2
   , p_secondary_unit_of_measure   IN         VARCHAR2
   , p_secondary_count_quantity    IN         NUMBER
   , p_secondary_system_quantity   IN         NUMBER
   , p_tracking_quantity_ind       IN         VARCHAR2
   , p_secondary_default_ind       IN         VARCHAR2);
 -- END INVCONV

END MTL_CCEOI_PROCESS_PVT;

 

/
