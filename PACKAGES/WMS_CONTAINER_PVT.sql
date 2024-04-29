--------------------------------------------------------
--  DDL for Package WMS_CONTAINER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_CONTAINER_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSVCNTS.pls 120.7.12010000.2 2009/11/26 08:37:32 abasheer ship $ */

/*----------------------------------------------------------------*
 *  Global constants representing all possible LPN context values
 *----------------------------------------------------------------*/
-- Resides in Inventory
LPN_CONTEXT_INV CONSTANT NUMBER := 1;
-- Resides in WIP
LPN_CONTEXT_WIP CONSTANT NUMBER := 2;
-- Resides in Receiving
LPN_CONTEXT_RCV CONSTANT NUMBER := 3;
-- Issued out of Stores
LPN_CONTEXT_STORES CONSTANT NUMBER := 4;
-- Pre-generated
LPN_CONTEXT_PREGENERATED CONSTANT NUMBER := 5;
-- Resides in intransit
LPN_CONTEXT_INTRANSIT CONSTANT NUMBER := 6;
-- Resides at vendor site
LPN_CONTEXT_VENDOR  CONSTANT NUMBER := 7;
-- Packing context, used as a temporary context value
-- when the user wants to reassociate the LPN with a
-- different license plate number and/or container item ID
LPN_CONTEXT_PACKING CONSTANT NUMBER := 8;
-- Loaded for shipment
LPN_LOADED_FOR_SHIPMENT CONSTANT NUMBER := 9;
-- Prepack of WIP
LPN_PREPACK_FOR_WIP CONSTANT NUMBER := 10;
-- LPN Picked
LPN_CONTEXT_PICKED CONSTANT NUMBER := 11;
-- Temporary context for staged (picked) LPNs
LPN_LOADED_IN_STAGE CONSTANT NUMBER := 12;

/*----------------------------------------------------------------*
 *  Data Types used by container pvt apis
 *----------------------------------------------------------------*/
TYPE LPNBulkRecType is RECORD (
  LPN_ID                  WMS_Data_Type_Definitions_PUB.NumberTableType
, LICENSE_PLATE_NUMBER    WMS_Data_Type_Definitions_PUB.Varchar2_30_TableType
, PARENT_LPN_ID           WMS_Data_Type_Definitions_PUB.NumberTableType
, OUTERMOST_LPN_ID        WMS_Data_Type_Definitions_PUB.NumberTableType
, LPN_CONTEXT             WMS_Data_Type_Definitions_PUB.NumberTableType

, ORGANIZATION_ID         WMS_Data_Type_Definitions_PUB.NumberTableType
, SUBINVENTORY_CODE       WMS_Data_Type_Definitions_PUB.Varchar2_10_TableType
, LOCATOR_ID              WMS_Data_Type_Definitions_PUB.NumberTableType

, INVENTORY_ITEM_ID       WMS_Data_Type_Definitions_PUB.NumberTableType
, REVISION                WMS_Data_Type_Definitions_PUB.Varchar2_3_TableType
, LOT_NUMBER              WMS_Data_Type_Definitions_PUB.Varchar2_30_TableType
, SERIAL_NUMBER           WMS_Data_Type_Definitions_PUB.Varchar2_30_TableType
, COST_GROUP_ID           WMS_Data_Type_Definitions_PUB.NumberTableType

, TARE_WEIGHT_UOM_CODE    WMS_Data_Type_Definitions_PUB.Varchar2_3_TableType
, TARE_WEIGHT             WMS_Data_Type_Definitions_PUB.NumberTableType
, GROSS_WEIGHT_UOM_CODE   WMS_Data_Type_Definitions_PUB.Varchar2_3_TableType
, GROSS_WEIGHT            WMS_Data_Type_Definitions_PUB.NumberTableType
, CONTAINER_VOLUME_UOM    WMS_Data_Type_Definitions_PUB.Varchar2_3_TableType
, CONTAINER_VOLUME        WMS_Data_Type_Definitions_PUB.NumberTableType
, CONTENT_VOLUME_UOM_CODE WMS_Data_Type_Definitions_PUB.Varchar2_3_TableType
, CONTENT_VOLUME          WMS_Data_Type_Definitions_PUB.NumberTableType

, SOURCE_TYPE_ID          WMS_Data_Type_Definitions_PUB.NumberTableType
, SOURCE_HEADER_ID        WMS_Data_Type_Definitions_PUB.NumberTableType
, SOURCE_LINE_ID          WMS_Data_Type_Definitions_PUB.NumberTableType
, SOURCE_LINE_DETAIL_ID   WMS_Data_Type_Definitions_PUB.NumberTableType
, SOURCE_NAME             WMS_Data_Type_Definitions_PUB.Varchar2_30_TableType
, SOURCE_TRANSACTION_ID   WMS_Data_Type_Definitions_PUB.NumberTableType
, REFERENCE_ID            WMS_Data_Type_Definitions_PUB.NumberTableType

, ATTRIBUTE_CATEGORY      WMS_Data_Type_Definitions_PUB.Varchar2_30_TableType
, ATTRIBUTE1              WMS_Data_Type_Definitions_PUB.Varchar2_150_TableType
, ATTRIBUTE2              WMS_Data_Type_Definitions_PUB.Varchar2_150_TableType
, ATTRIBUTE3              WMS_Data_Type_Definitions_PUB.Varchar2_150_TableType
, ATTRIBUTE4              WMS_Data_Type_Definitions_PUB.Varchar2_150_TableType
, ATTRIBUTE5              WMS_Data_Type_Definitions_PUB.Varchar2_150_TableType
, ATTRIBUTE6              WMS_Data_Type_Definitions_PUB.Varchar2_150_TableType
, ATTRIBUTE7              WMS_Data_Type_Definitions_PUB.Varchar2_150_TableType
, ATTRIBUTE8              WMS_Data_Type_Definitions_PUB.Varchar2_150_TableType
, ATTRIBUTE9              WMS_Data_Type_Definitions_PUB.Varchar2_150_TableType
, ATTRIBUTE10             WMS_Data_Type_Definitions_PUB.Varchar2_150_TableType
, ATTRIBUTE11             WMS_Data_Type_Definitions_PUB.Varchar2_150_TableType
, ATTRIBUTE12             WMS_Data_Type_Definitions_PUB.Varchar2_150_TableType
, ATTRIBUTE13             WMS_Data_Type_Definitions_PUB.Varchar2_150_TableType
, ATTRIBUTE14             WMS_Data_Type_Definitions_PUB.Varchar2_150_TableType
, ATTRIBUTE15             WMS_Data_Type_Definitions_PUB.Varchar2_150_TableType
);

/*---------------------------------------------------------------------*/
-- Name
--   FUNCTION Convert_UOM
/*---------------------------------------------------------------------*/
-- Purpose
--    This api converts a quantity from UOM to another using a caching
--    mechanism to store uom conversions.  This can be useful if many
--    conversions are done on the same item and uom pairs.
--
--    Cached conversions will be purged when table gets large
--
--    Not intended for general use
--
-- Input Parameters
--   p_inventory_item_id: Item id for item specific conversions
--   p_fm_quantity      : Quantity to be converted into to uom
--   p_fm_uom           :
--   p_to_uom           :
--   p_mode             : Used if user wishes a retun value different from the default
--     Default (null)      - throw and exception with a message when no conversion is found
--     NO_CONV_RETURN_NULL - return null when no conversion is found
--
-- Returns:
--    quantity in p_to_uom
--

-- p_mode options
-- NO_CONV_RETURN_NULL ruturns null if no conversion can be found
-- NO_CONV_RETURN_NULL ruturns zero if no conversion can be found

G_NO_CONV_RETURN_NULL CONSTANT VARCHAR2(30) := 'NO_CONV_RETURN_NULL';
G_NO_CONV_RETURN_ZERO CONSTANT VARCHAR2(30) := 'NO_CONV_RETURN_ZERO';

FUNCTION Convert_UOM (
  p_inventory_item_id IN NUMBER
, p_fm_quantity       IN NUMBER
, p_fm_uom            IN VARCHAR2
, p_to_uom            IN VARCHAR2
, p_mode              IN VARCHAR2 := null
) RETURN NUMBER;

/*---------------------------------------------------------------------*/
-- Name
--   FUNCTION To_DeliveryDetailsRecType
/*---------------------------------------------------------------------*/
-- Purpose
--    This api takes in a LPN record type and translates it's attributes
--    into a shipping WMS_Data_Type_Definitions_PUB.LPNRecordType type for
--    use in their APIs
--
--    Not intended for general use
--
--    The API converts the following LPN attrubtues to the shipping rec type:
--    *lpn_id
--    *license_plate_number
--    *inventory_item_id
--
--    *organization_id
--    *subinventory_code
--    *locator_id
--
--    *tare_weight
--    *tare_weight_uom_code
--    *gross_weight
--    *gross_weight_uom_code
--
--    *container_volume
--    *container_volume_uom
--    *content_volume
--    *content_volume_uom_code
--
-- Input Parameters
--   p_lpn_record LPN rec type with values to be converted to WSH rec type
--
-- Returns:
--    WMS_Data_Type_Definitions_PUB.LPNRecordType with shipping field
--    values populated that correspond the above LPN attributes
--

FUNCTION To_DeliveryDetailsRecType (
  p_lpn_record IN WMS_Data_Type_Definitions_PUB.LPNRecordType
)
RETURN WSH_Glbl_Var_Strct_GRP.Delivery_Details_Rec_Type;

/*---------------------------------------------------------------------*/
-- Name
--   PROCEDURE Create_LPNs
/*---------------------------------------------------------------------*/
-- Purpose
--    This api takes in a brand new container names (License Plate Numbers) and will
--    create an entry for it in the WMS_LICENSE_PLATE_NUMBERS table returning to the
--    caller a uniquely generated LPN_IDs for each
--
--    Caller should add each License Plate Number to the p_lpn_table and any attributes
--    valid attributes listed below.
--
--    The table will be returned with the p_lpn_table.lpn_id field populated for each
--    License Plate Number created in WMS_LICENSE_PLATE_NUMBERS
--
-- Input Parameters
--   p_api_version (required) API version number (current version is 1.0)
--   p_init_msg_list (required)
--     Valid values: FND_API.G_FALSE or FND_API.G_TRUE
--       if set to FND_API.G_TRUE  - initialize error message list
--       if set to FND_API.G_FALSE - not initialize error message list
--   p_commit (required) whether or not to commit the changes to database
--     Valid values: FND_API.G_FALSE or FND_API.G_TRUE
--   p_caller (required) VARCHAR2 Code of calling API/Product/Flow
--
-- IN OUT Parameters
--   p_lpn_table  Table of LPNs to be created The API will create LPN IDs for
--                each record in the table and insert them into WMS_License_Plate_Numbers
--                LPN record type is a generic LPN record type and not all attributes listed
--                are allowed while creating LPNs.
--
--   The Following is list of LPN record type fields that are used:
--     license_plate_number  License Plate Number Identifier - Required Value
--     lpn_context           LPN Context.  1. INV, 2. WIP, or 2. REC, etc..
--                                        - Defaults to 5 (Pregenerated).
--     organization_id       Organization Id - Required Value
--     subinventory          Subinventory
--     locator_id            Locator ID
--     inventory_item_id     ID of Container Item
--     revision              Container Item Revision
--     lot_number            Container Item Lot Number
--     serial_number         Container Item Serial Number
--     cost_group_id         Container Item Cost Group Id
--     source_type_id        Source type ID for the source transaction
--     source_header_id      Source header ID for the source transaction
--     source_name           Source name for the source transaction
--     source_line_id        Source line ID for the source transaction
--     source_line_detail_id Source line detail ID for the source transaction
--     source_transaction_id The transaction identifier that created this LPN
--                           used for LPN historical and auditing purposes
--
-- Output Parameters
--   x_return_status
--     if the Create_LPN API succeeds, the value is fnd_api.g_ret_sts_success;
--     if there is an expected error, the value is fnd_api.g_ret_sts_error;
--     if there is an unexpected error, the value is fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--     if there is one or more errors, the number of error messages in the buffer
--   x_msg_data
--     if there is one and only one error, the error message
--
PROCEDURE Create_LPNs (
  p_api_version   IN            NUMBER
, p_init_msg_list IN            VARCHAR2
, p_commit        IN            VARCHAR2
, x_return_status OUT    NOCOPY VARCHAR2
, x_msg_count     OUT    NOCOPY NUMBER
, x_msg_data      OUT    NOCOPY VARCHAR2
, p_caller        IN            VARCHAR2
, p_lpn_table     IN OUT NOCOPY WMS_Data_Type_Definitions_PUB.LPNTableType
);

/*---------------------------------------------------------------------*/
-- Name
--   PROCEDURE Auto_Create_LPNs
/*---------------------------------------------------------------------*/
-- Purpose
--   This api is used to mass generate LPN numbers, either individually or in a sequence
--
-- Input Parameters
--   p_api_version (required) API version number (current version is 1.0)
--   p_init_msg_list (required)
--     Valid values: FND_API.G_FALSE or FND_API.G_TRUE
--       if set to FND_API.G_TRUE  - initialize error message list
--       if set to FND_API.G_FALSE - not initialize error message list
--   p_commit (required) whether or not to commit the changes to database
--     Valid values: FND_API.G_FALSE or FND_API.G_TRUE
--   p_caller (required) VARCHAR2 Code of calling API/Product/Flow
--   p_lpn_attributes Record of atrributes to be added to each LPN created aand inserted into
--                    WMS_License_Plate_Numbers.  LPN record type is a generic LPN record type
--                    and not all attributes listed are allowed while creating LPNs.
--
--   The Following is list of LPN record type fields that are used:
--     lpn_context           LPN Context
--     organization_id       Organization Id
--     subinventory          Subinventory
--     locator_id            Locator Id
--     inventory_item_id     ID of Container Item
--     revision              Container Item Revision
--     lot_number            Container Item Lot Number
--     serial_number         Container Item Serial Number
--     cost_group_id         Container Item Cost Group Id
--     source_type_id        Source type ID for the source transaction
--     source_header_id      Source header ID for the source transaction
--     source_name           Source name for the source transaction
--     source_line_id        Source line ID for the source transaction
--     source_line_detail_id Source line detail ID for the source transaction
--     source_transaction_id The transaction identifier that created this LPN
--                           used for LPN historical and auditing purposes
--
--   p_serial_ranges If item is serial controlled, this table can be used to
--                   determine the serials that should be assigned to the new LPNs
--                   the quantity of serial numbers given will overide the quantity
--                   given in the p_quantity parameter.  Currently only a single serial
--                   range is supported.
--
-- Output Parameters
--   x_return_status
--     if the Create_LPN API succeeds, the value is fnd_api.g_ret_sts_success;
--     if there is an expected error, the value is fnd_api.g_ret_sts_error;
--     if there is an unexpected error, the value is fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--     if there is one or more errors, the number of error messages in the buffer
--   x_msg_data
--     if there is one and only one error, the error message
--   x_created_lpns
--     table of LPN records which have been generated
--
PROCEDURE Auto_Create_LPNs (
  p_api_version         IN         NUMBER
, p_init_msg_list       IN         VARCHAR2
, p_commit              IN         VARCHAR2
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
, p_caller              IN         VARCHAR2
, p_quantity            IN         NUMBER
, p_lpn_prefix          IN         VARCHAR2
, p_lpn_suffix          IN         VARCHAR2
, p_starting_number     IN         NUMBER
, p_total_lpn_length    IN         NUMBER
, p_ucc_128_suffix_flag IN         VARCHAR2
, p_lpn_attributes      IN         WMS_Data_Type_Definitions_PUB.LPNRecordType
, p_serial_ranges       IN         WMS_Data_Type_Definitions_PUB.SerialRangeTableType
, x_created_lpns        OUT NOCOPY WMS_Data_Type_Definitions_PUB.LPNTableType
);


------------------------
-- Added for LSP Project, bug 9087971
------------------------
/*---------------------------------------------------------------------*/
-- Name
--   PROCEDURE Auto_Create_LPNs
/*---------------------------------------------------------------------*/
-- Purpose
--   This api is used to mass generate LPN numbers, either individually or in a sequence
--   This is overloaded by adding the additional paramater as p_client_code for LSP Project
--
-- Input Parameters
--   p_api_version (required) API version number (current version is 1.0)
--   p_init_msg_list (required)
--     Valid values: FND_API.G_FALSE or FND_API.G_TRUE
--       if set to FND_API.G_TRUE  - initialize error message list
--       if set to FND_API.G_FALSE - not initialize error message list
--   p_commit (required) whether or not to commit the changes to database
--     Valid values: FND_API.G_FALSE or FND_API.G_TRUE
--   p_caller (required) VARCHAR2 Code of calling API/Product/Flow
--   p_lpn_attributes Record of atrributes to be added to each LPN created aand inserted into
--                    WMS_License_Plate_Numbers.  LPN record type is a generic LPN record type
--                    and not all attributes listed are allowed while creating LPNs.
--   p_client_code		  Client Code of the item
--
--   The Following is list of LPN record type fields that are used:
--     lpn_context           LPN Context
--     organization_id       Organization Id
--     subinventory          Subinventory
--     locator_id            Locator Id
--     inventory_item_id     ID of Container Item
--     revision              Container Item Revision
--     lot_number            Container Item Lot Number
--     serial_number         Container Item Serial Number
--     cost_group_id         Container Item Cost Group Id
--     source_type_id        Source type ID for the source transaction
--     source_header_id      Source header ID for the source transaction
--     source_name           Source name for the source transaction
--     source_line_id        Source line ID for the source transaction
--     source_line_detail_id Source line detail ID for the source transaction
--     source_transaction_id The transaction identifier that created this LPN
--                           used for LPN historical and auditing purposes
--
--   p_serial_ranges If item is serial controlled, this table can be used to
--                   determine the serials that should be assigned to the new LPNs
--                   the quantity of serial numbers given will overide the quantity
--                   given in the p_quantity parameter.  Currently only a single serial
--                   range is supported.
--
-- Output Parameters
--   x_return_status
--     if the Create_LPN API succeeds, the value is fnd_api.g_ret_sts_success;
--     if there is an expected error, the value is fnd_api.g_ret_sts_error;
--     if there is an unexpected error, the value is fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--     if there is one or more errors, the number of error messages in the buffer
--   x_msg_data
--     if there is one and only one error, the error message
--   x_created_lpns
--     table of LPN records which have been generated
--
PROCEDURE Auto_Create_LPNs (
  p_api_version         IN         NUMBER
, p_init_msg_list       IN         VARCHAR2
, p_commit              IN         VARCHAR2
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
, p_caller              IN         VARCHAR2
, p_quantity            IN         NUMBER
, p_lpn_prefix          IN         VARCHAR2
, p_lpn_suffix          IN         VARCHAR2
, p_starting_number     IN         NUMBER
, p_total_lpn_length    IN         NUMBER
, p_ucc_128_suffix_flag IN         VARCHAR2
, p_lpn_attributes      IN         WMS_Data_Type_Definitions_PUB.LPNRecordType
, p_serial_ranges       IN         WMS_Data_Type_Definitions_PUB.SerialRangeTableType
, x_created_lpns        OUT NOCOPY WMS_Data_Type_Definitions_PUB.LPNTableType
, p_client_code		IN         VARCHAR2   -- Adding for LSP, bug 9087971
);


/*---------------------------------------------------------------------*/
-- Name
--   PROCEDURE Modify_LPNs
/*---------------------------------------------------------------------*/
-- Purpose
--   This api is used to mass generate LPN numbers, either individually or in a sequence
--
-- Input Parameters
--   p_api_version (required) API version number (current version is 1.0)
--   p_init_msg_list (required)
--     Valid values: FND_API.G_FALSE or FND_API.G_TRUE
--       if set to FND_API.G_TRUE  - initialize error message list
--       if set to FND_API.G_FALSE - not initialize error message list
--   p_commit (required) whether or not to commit the changes to database
--     Valid values: FND_API.G_FALSE or FND_API.G_TRUE
--   p_caller (required) VARCHAR2 Code of calling API/Product/Flow
--   p_lpn_table  Table of LPN records to be modified.
--                WMS_License_Plate_Numbers.  LPN record type is a generic LPN record type
--                    and not all attributes listed are allowed while creating LPNs.
--
--   The Following is list of LPN record type fields that are used:
--     lpn_id                  *required* to identify LPN to be updated.  Cannot be modified.
--     lpn_context             LPN Context
--     organization_id         Organization Id - Required Value
--     subinventory            Subinventory - Defaults to NULL
--     locator_id              Locator Id - Defaults to NULL
--     inventory_item_id       ID of Container Item
--     revision                Container Item Revision
--     lot_number              Container Item Lot Number
--     serial_number           Container Item Serial Number
--     cost_group_id           Container Item Cost Group Id
--     tare_weight_uom_code    UOM of container weight
--     tare_weight             weight of container item
--     gross_weight_uom_code   UOM of content weight + container weight
--     gross_weight            weight of contents + container weight
--     container_volume_uom    UOM of container volume
--     container_volume        volume of container item
--     content_volume_uom_code UOM of content volume
--     content_volume          volume of LPN's contents
--     source_type_id          Source type ID for the source transaction
--     source_header_id        Source header ID for the source transaction
--     source_name             Source name for the source transaction
--     source_line_id          Source line ID for the source transaction
--     source_line_detail_id   Source line detail ID for the source transaction
--     source_transaction_id   The transaction identifier that created this LPN
--                             used for LPN historical and auditing purposes
--
-- Output Parameters
--   x_return_status
--     if the Create_LPN API succeeds, the value is fnd_api.g_ret_sts_success;
--     if there is an expected error, the value is fnd_api.g_ret_sts_error;
--     if there is an unexpected error, the value is fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--     if there is one or more errors, the number of error messages in the buffer
--   x_msg_data
--     if there is one and only one error, the error message
--
PROCEDURE Modify_LPNs (
  p_api_version   IN         NUMBER
, p_init_msg_list IN         VARCHAR2
, p_commit        IN         VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count     OUT NOCOPY NUMBER
, x_msg_data      OUT NOCOPY VARCHAR2
, p_caller        IN         VARCHAR2
, p_lpn_table     IN         WMS_Data_Type_Definitions_PUB.LPNTableType
);

/*---------------------------------------------------------------------*/
-- Name
--   PROCEDURE Generate_LPN_CP
/* --------------------------------------------------------------------*/
--
-- Purpose
--   Generate LPN numbers Concurrent Program.
--
-- Input Parameters
--   p_api_version
--      API version number (current version is 1.0)
--   p_init_msg_list (optional, default FND_API.G_FALSE)
--      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
--                           if set to FND_API.G_TRUE
--                                   initialize error message list
--                           if set to FND_API.G_FALSE - not initialize error
--                                   message list
--   p_commit (optional, default FND_API.G_FALSE)
--    whether or not to commit the changes to database
--   p_organization_id      Organization Id - Required Value
--   p_container_item_id  Container Item Id - Defaults to NULL
--   p_revision             Revision - Defaults to NULL
--   p_lot_number   Lot Number - Defaults to NULL
--   p_from_serial_number       Starting Serial Number   - Defaults to NULL
--   p_to_serial_number         Ending Serial Number     - Defaults to NULL
--   p_subinventory   Subinventory - Defaults to NULL
--   p_locator_id   Locator Id - Defaults to NULL
--   p_lpn_prefix   Prefix Value of an LPN - Defaults to NULL
--   p_lpn_suffix               Suffix Value of an LPN - Defaults to NULL
--   p_starting_num   Starting Number of an LPN - Defaults to NULL
--   p_quantity           No of LPNs to be generated - Default Value is 1
--   p_source                   LPN Context.  1. INV, 2. WIP, or 2. REC, etc..
--                                      - Defaults to 1.
--                              Indicates the source where the LPN is generated
--   p_cost_group_id            Cost Group Id - Defaults to NULL
--   p_source_type_id           Source type ID for the source transaction
--   p_source_header_id         Source header ID for the source transaction
--   p_source_name              Source name for the source transaction
--   p_source_line_id           Source line ID for the source transaction
--   p_source_line_detail_id    Source line detail ID for the source transaction
--
--
-- Output Parameters
--
--   p_lpn_id_out - Outputs the generated LPN ID
--                  if only one LPN is requested to be generated
--   p_lpn_out    - Outputs the generated license plate number
--                  if only one LPN is requested to be generated
--   p_process_id - Process ID to identify the LPN's generated in the
--                  table WMS_LPN_PROCESS_TEMP

PROCEDURE Generate_LPN_CP(
  errbuf                 OUT NOCOPY VARCHAR2
, retcode                OUT NOCOPY NUMBER
, p_api_version          IN         NUMBER
, p_organization_id      IN         NUMBER
, p_container_item_id    IN         NUMBER   := NULL
, p_revision             IN         VARCHAR2 := NULL
, p_lot_number           IN         VARCHAR2 := NULL
, p_from_serial_number   IN         VARCHAR2 := NULL
, p_to_serial_number     IN         VARCHAR2 := NULL
, p_subinventory         IN         VARCHAR2 := NULL
, p_locator_id           IN         NUMBER   := NULL
, p_org_parameters       IN         NUMBER   := NULL
, p_parm_dummy_1         IN         VARCHAR2 := NULL
, p_total_length         IN         NUMBER   := NULL
, p_lpn_prefix           IN         VARCHAR2 := NULL
, p_starting_num         IN         NUMBER   := NULL
, p_ucc_128_suffix_flag  IN         NUMBER   := 2
, p_parm_dummy_2         IN         VARCHAR2 := NULL
, p_lpn_suffix           IN         VARCHAR2 := NULL
, p_quantity             IN         NUMBER   := 1
, p_source               IN         NUMBER   := LPN_CONTEXT_PREGENERATED
, p_cost_group_id        IN         NUMBER   := NULL
);


------------------------
-- Added for LSP Project, bug 9087971
------------------------
/*---------------------------------------------------------------------*/
-- Name
--   PROCEDURE Generate_LPN_CP
/* --------------------------------------------------------------------*/
--
-- Purpose
--   Generate LPN numbers Concurrent Program.
--   This is overloaded by adding the additional paramater as p_client_code for LSP Project
--
-- Input Parameters
--   p_api_version
--      API version number (current version is 1.0)
--   p_init_msg_list (optional, default FND_API.G_FALSE)
--      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
--                           if set to FND_API.G_TRUE
--                                   initialize error message list
--                           if set to FND_API.G_FALSE - not initialize error
--                                   message list
--   p_commit (optional, default FND_API.G_FALSE)
--    whether or not to commit the changes to database
--   p_organization_id      Organization Id - Required Value
--   p_container_item_id  Container Item Id - Defaults to NULL
--   p_revision             Revision - Defaults to NULL
--   p_lot_number   Lot Number - Defaults to NULL
--   p_from_serial_number       Starting Serial Number   - Defaults to NULL
--   p_to_serial_number         Ending Serial Number     - Defaults to NULL
--   p_subinventory   Subinventory - Defaults to NULL
--   p_locator_id   Locator Id - Defaults to NULL
--   p_lpn_prefix   Prefix Value of an LPN - Defaults to NULL
--   p_lpn_suffix               Suffix Value of an LPN - Defaults to NULL
--   p_starting_num   Starting Number of an LPN - Defaults to NULL
--   p_quantity           No of LPNs to be generated - Default Value is 1
--   p_source                   LPN Context.  1. INV, 2. WIP, or 2. REC, etc..
--                                      - Defaults to 1.
--                              Indicates the source where the LPN is generated
--   p_cost_group_id            Cost Group Id - Defaults to NULL
--   p_source_type_id           Source type ID for the source transaction
--   p_source_header_id         Source header ID for the source transaction
--   p_source_name              Source name for the source transaction
--   p_source_line_id           Source line ID for the source transaction
--   p_source_line_detail_id    Source line detail ID for the source transaction
--   p_client_code		  Client Code of the item
--
--
-- Output Parameters
--
--   p_lpn_id_out - Outputs the generated LPN ID
--                  if only one LPN is requested to be generated
--   p_lpn_out    - Outputs the generated license plate number
--                  if only one LPN is requested to be generated
--   p_process_id - Process ID to identify the LPN's generated in the
--                  table WMS_LPN_PROCESS_TEMP
PROCEDURE Generate_LPN_CP (
  errbuf                OUT NOCOPY VARCHAR2
, retcode               OUT NOCOPY NUMBER
, p_api_version         IN         NUMBER
, p_organization_id     IN         NUMBER
, p_container_item_id   IN         NUMBER   := NULL
, p_revision            IN         VARCHAR2 := NULL
, p_lot_number          IN         VARCHAR2 := NULL
, p_from_serial_number  IN         VARCHAR2 := NULL
, p_to_serial_number    IN         VARCHAR2 := NULL
, p_subinventory        IN         VARCHAR2 := NULL
, p_locator_id          IN         NUMBER   := NULL
, p_org_parameters      IN         NUMBER
, p_parm_dummy_1        IN         VARCHAR2
, p_total_length        IN         NUMBER
, p_lpn_prefix          IN         VARCHAR2 := NULL
, p_starting_num        IN         NUMBER   := NULL
, p_ucc_128_suffix_flag IN         NUMBER
, p_parm_dummy_2        IN         VARCHAR2
, p_lpn_suffix          IN         VARCHAR2 := NULL
, p_quantity            IN         NUMBER   := 1
, p_source              IN         NUMBER   := LPN_CONTEXT_PREGENERATED
, p_cost_group_id       IN         NUMBER   := NULL
, p_client_code		IN         VARCHAR2  -- Adding for LSP, bug 9087971
);



/*---------------------------------------------------------------------*/
-- Name
--   PROCEDURE Generate_LPN
/* --------------------------------------------------------------------*/
--
-- Purpose
--   Generate LPN numbers, either individually or in a sequence.
--
-- Input Parameters
--   p_api_version
--      API version number (current version is 1.0)
--   p_init_msg_list (optional, default FND_API.G_FALSE)
--      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
--                           if set to FND_API.G_TRUE
--                                   initialize error message list
--                           if set to FND_API.G_FALSE - not initialize error
--                                   message list
--   p_commit (optional, default FND_API.G_FALSE)
--    whether or not to commit the changes to database
--   p_validation_level         (optional), determines if full validation or
--                              no validation will be performed
--                              defaults to FND_API.G_VALID_LEVEL_FULL
--                              FND_API.G_VALID_LEVEL_NONE is the other value
--   p_organization_id      Organization Id - Required Value
--   p_container_item_id  Container Item Id - Defaults to NULL
--   p_revision             Revision - Defaults to NULL
--   p_lot_number   Lot Number - Defaults to NULL
--   p_from_serial_number       Starting Serial Number   - Defaults to NULL
--   p_to_serial_number         Ending Serial Number     - Defaults to NULL
--   p_subinventory   Subinventory - Defaults to NULL
--   p_locator_id   Locator Id - Defaults to NULL
--   p_lpn_prefix   Prefix Value of an LPN - Defaults to NULL
--   p_lpn_suffix               Suffix Value of an LPN - Defaults to NULL
--   p_starting_num   Starting Number of an LPN - Defaults to NULL
--   p_quantity           No of LPNs to be generated - Default Value is 1
--   p_source                   LPN Context.  1. INV, 2. WIP, or 2. REC, etc..
--                                      - Defaults to 5 (Pregenerated).
--                              Indicates the source where the LPN is generated
--   p_cost_group_id            Cost Group Id - Defaults to NULL
--   p_source_type_id           Source type ID for the source transaction
--   p_source_header_id         Source header ID for the source transaction
--   p_source_name              Source name for the source transaction
--   p_source_line_id           Source line ID for the source transaction
--   p_source_line_detail_id    Source line detail ID for the source transaction
--
--
-- Output Parameters
--   x_return_status
--       if the Generate_LPN API succeeds, the value is
--    fnd_api.g_ret_sts_success;
--       if there is an expected error, the value is
--    fnd_api.g_ret_sts_error;
--       if there is an unexpected error, the value is
--    fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--       if there is one or more errors, the number of error messages
--           in the buffer
--   x_msg_data
--       if there is one and only one error, the error message
--   (See fnd_api package for more details about the above output parameters)
--
--   p_lpn_id_out - Outputs the generated LPN ID
--                  if only one LPN is requested to be generated
--   p_lpn_out    - Outputs the generated license plate number
--                  if only one LPN is requested to be generated
--   p_process_id - Process ID to identify the LPN's generated in the
--                  table WMS_LPN_PROCESS_TEMP

PROCEDURE Generate_LPN (
  p_api_version           IN         NUMBER
, p_init_msg_list         IN         VARCHAR2 := fnd_api.g_false
, p_commit                IN         VARCHAR2 := fnd_api.g_false
, p_validation_level      IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, p_organization_id       IN         NUMBER
, p_container_item_id     IN         NUMBER   := NULL
, p_revision              IN         VARCHAR2 := NULL
, p_lot_number            IN         VARCHAR2 := NULL
, p_from_serial_number    IN         VARCHAR2 := NULL
, p_to_serial_number      IN         VARCHAR2 := NULL
, p_subinventory          IN         VARCHAR2 := NULL
, p_locator_id            IN         NUMBER   := NULL
, p_lpn_prefix            IN         VARCHAR2 := NULL
, p_lpn_suffix            IN         VARCHAR2 := NULL
, p_starting_num          IN         NUMBER   := NULL
, p_quantity              IN         NUMBER   := 1
, p_source                IN         NUMBER   := LPN_CONTEXT_PREGENERATED
, p_cost_group_id         IN         NUMBER   := NULL
, p_source_type_id        IN         NUMBER   := NULL
, p_source_header_id      IN         NUMBER   := NULL
, p_source_name           IN         VARCHAR2 := NULL
, p_source_line_id        IN         NUMBER   := NULL
, p_source_line_detail_id IN         NUMBER   := NULL
, p_lpn_id_out            OUT NOCOPY NUMBER
, p_lpn_out               OUT NOCOPY VARCHAR2
, p_process_id            OUT NOCOPY NUMBER
, p_total_length          IN         NUMBER   := NULL
, p_ucc_128_suffix_flag   IN         NUMBER   := 2      -- 1='Y', 2= 'N'
);


------------------------
-- Added for LSP Project, bug 9087971
------------------------
/*---------------------------------------------------------------------*/
-- Name
--   PROCEDURE Generate_LPN
/* --------------------------------------------------------------------*/
--
-- Purpose
--   Generate LPN numbers, either individually or in a sequence.
--   This is overloaded by adding the additional paramater as p_client_code for LSP Project
--
-- Input Parameters
--   p_api_version
--      API version number (current version is 1.0)
--   p_init_msg_list (optional, default FND_API.G_FALSE)
--      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
--                           if set to FND_API.G_TRUE
--                                   initialize error message list
--                           if set to FND_API.G_FALSE - not initialize error
--                                   message list
--   p_commit (optional, default FND_API.G_FALSE)
--    whether or not to commit the changes to database
--   p_validation_level         (optional), determines if full validation or
--                              no validation will be performed
--                              defaults to FND_API.G_VALID_LEVEL_FULL
--                              FND_API.G_VALID_LEVEL_NONE is the other value
--   p_organization_id      Organization Id - Required Value
--   p_container_item_id  Container Item Id - Defaults to NULL
--   p_revision             Revision - Defaults to NULL
--   p_lot_number   Lot Number - Defaults to NULL
--   p_from_serial_number       Starting Serial Number   - Defaults to NULL
--   p_to_serial_number         Ending Serial Number     - Defaults to NULL
--   p_subinventory   Subinventory - Defaults to NULL
--   p_locator_id   Locator Id - Defaults to NULL
--   p_lpn_prefix   Prefix Value of an LPN - Defaults to NULL
--   p_lpn_suffix               Suffix Value of an LPN - Defaults to NULL
--   p_starting_num   Starting Number of an LPN - Defaults to NULL
--   p_quantity           No of LPNs to be generated - Default Value is 1
--   p_source                   LPN Context.  1. INV, 2. WIP, or 2. REC, etc..
--                                      - Defaults to 5 (Pregenerated).
--                              Indicates the source where the LPN is generated
--   p_cost_group_id            Cost Group Id - Defaults to NULL
--   p_source_type_id           Source type ID for the source transaction
--   p_source_header_id         Source header ID for the source transaction
--   p_source_name              Source name for the source transaction
--   p_source_line_id           Source line ID for the source transaction
--   p_source_line_detail_id    Source line detail ID for the source transaction
--   p_client_code		  Client Code of the item
--
--
-- Output Parameters
--   x_return_status
--       if the Generate_LPN API succeeds, the value is
--    fnd_api.g_ret_sts_success;
--       if there is an expected error, the value is
--    fnd_api.g_ret_sts_error;
--       if there is an unexpected error, the value is
--    fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--       if there is one or more errors, the number of error messages
--           in the buffer
--   x_msg_data
--       if there is one and only one error, the error message
--   (See fnd_api package for more details about the above output parameters)
--
--   p_lpn_id_out - Outputs the generated LPN ID
--                  if only one LPN is requested to be generated
--   p_lpn_out    - Outputs the generated license plate number
--                  if only one LPN is requested to be generated
--   p_process_id - Process ID to identify the LPN's generated in the
--                  table WMS_LPN_PROCESS_TEMP

PROCEDURE Generate_LPN (
  p_api_version           IN         NUMBER
, p_init_msg_list         IN         VARCHAR2 := fnd_api.g_false
, p_commit                IN         VARCHAR2 := fnd_api.g_false
, p_validation_level      IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, p_organization_id       IN         NUMBER
, p_container_item_id     IN         NUMBER   := NULL
, p_revision              IN         VARCHAR2 := NULL
, p_lot_number            IN         VARCHAR2 := NULL
, p_from_serial_number    IN         VARCHAR2 := NULL
, p_to_serial_number      IN         VARCHAR2 := NULL
, p_subinventory          IN         VARCHAR2 := NULL
, p_locator_id            IN         NUMBER   := NULL
, p_lpn_prefix            IN         VARCHAR2 := NULL
, p_lpn_suffix            IN         VARCHAR2 := NULL
, p_starting_num          IN         NUMBER   := NULL
, p_quantity              IN         NUMBER   := 1
, p_source                IN         NUMBER   := LPN_CONTEXT_PREGENERATED
, p_cost_group_id         IN         NUMBER   := NULL
, p_source_type_id        IN         NUMBER   := NULL
, p_source_header_id      IN         NUMBER   := NULL
, p_source_name           IN         VARCHAR2 := NULL
, p_source_line_id        IN         NUMBER   := NULL
, p_source_line_detail_id IN         NUMBER   := NULL
, p_lpn_id_out            OUT NOCOPY NUMBER
, p_lpn_out               OUT NOCOPY VARCHAR2
, p_process_id            OUT NOCOPY NUMBER
, p_total_length          IN         NUMBER   := NULL
, p_ucc_128_suffix_flag   IN         NUMBER   := 2
, p_client_code		IN         VARCHAR2  -- Adding for LSP, bug 9087971
);



/*---------------------------------------------------------------------*/
-- Name
--   PROCEDURE Associate_LPN
/*---------------------------------------------------------------------*/
-- Purpose
--    Associate an LPN to a specific instance of a container
--
-- Input Parameters
--   p_api_version
--      API version number (current version is 1.0)
--   p_init_msg_list (optional, default FND_API.G_FALSE)
--      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
--                           if set to FND_API.G_TRUE
--                                   initialize error message list
--                           if set to FND_API.G_FALSE - not initialize error
--                                   message list
--   p_commit (optional, default FND_API.G_FALSE)
--    whether or not to commit the changes to database
--   p_validation_level         (optional), determines if full validation or
--                              no validation will be performed
--                              defaults to FND_API.G_VALID_LEVEL_FULL
--                              FND_API.G_VALID_LEVEL_NONE is the other value
--   p_lpn_id           License Plate Number Identifier - Required Value
--   p_container_item_id  Container Item Id - Required Value
--   p_lot_number   Lot Number - Defaults to NULL
--   p_revision             Revision - Defaults to NULL
--   p_serial_number    Serial Number - Defaults to NULL
--   p_organization_id          Organization Id - Required Value
--   p_subinventory   Subinventory - Defaults to NULL
--   p_locator_id   Locator Id - Defaults to NULL
--   p_cost_group_id            Cost Group Id - Defaults to NULL
--   p_source_type_id           Source type ID for the source transaction
--   p_source_header_id         Source header ID for the source transaction
--   p_source_name              Source name for the source transaction
--   p_source_line_id           Source line ID for the source transaction
--   p_source_line_detail_id    Source line detail ID for the source transaction
--
--
-- Output Parameters
--   x_return_status
--       if the Associate_LPN API succeeds, the value is
--    fnd_api.g_ret_sts_success;
--       if there is an expected error, the value is
--    fnd_api.g_ret_sts_error;
--       if there is an unexpected error, the value is
--    fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--       if there is one or more errors, the number of error messages
--           in the buffer
--   x_msg_data
--       if there is one and only one error, the error message

PROCEDURE Associate_LPN(
  p_api_version           IN         NUMBER
, p_init_msg_list         IN         VARCHAR2 := fnd_api.g_false
, p_commit                IN         VARCHAR2 := fnd_api.g_false
, p_validation_level      IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, p_lpn_id                IN         NUMBER
, p_container_item_id     IN         NUMBER
, p_lot_number            IN         VARCHAR2 := NULL
, p_revision              IN         VARCHAR2 := NULL
, p_serial_number         IN         VARCHAR2 := NULL
, p_organization_id       IN         NUMBER
, p_subinventory          IN         VARCHAR2 := NULL
, p_locator_id            IN         NUMBER   := NULL
, p_cost_group_id         IN         NUMBER   := NULL
, p_source_type_id        IN         NUMBER   := NULL
, p_source_header_id      IN         NUMBER   := NULL
, p_source_name           IN         VARCHAR2 := NULL
, p_source_line_id        IN         NUMBER   := NULL
, p_source_line_detail_id IN         NUMBER   := NULL
);

/*---------------------------------------------------------------------*/
-- Name
--   PROCEDURE Create_LPN
/*---------------------------------------------------------------------*/
-- Purpose
--    Associate an LPN to a specific instance of a container in which
--    the LPN is already existing.  It will create an associated LPN ID
--    and store the record in the WMS_LICENSE_PLATE_NUMBERS table
--
-- Input Parameters
--   p_api_version
--      API version number (current version is 1.0)
--   p_init_msg_list (optional, default FND_API.G_FALSE)
--      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
--                           if set to FND_API.G_TRUE
--                                   initialize error message list
--                           if set to FND_API.G_FALSE - not initialize error
--                                   message list
--   p_commit (optional, default FND_API.G_FALSE)
--    whether or not to commit the changes to database
--   p_validation_level         (optional), determines if full validation or
--                              no validation will be performed
--                              defaults to FND_API.G_VALID_LEVEL_FULL
--                              FND_API.G_VALID_LEVEL_NONE is the other value
--   p_lpn            License Plate Number Identifier - Required Value
--   p_organization_id          Organization Id - Required Value
--   p_container_item_id  Container Item Id - Defaults to NULL
--   p_revision             Revision - Defaults to NULL
--   p_lot_number   Lot Number - Defaults to NULL
--   p_serial_number    Serial Number - Defaults to NULL
--   p_subinventory   Subinventory - Defaults to NULL
--   p_locator_id   Locator Id - Defaults to NULL
--   p_source                   LPN Context.  1. INV, 2. WIP, or 2. REC, etc..
--                                      - Defaults to 5 (Pregenerated).
--   p_cost_group_id            Cost Group Id - Defaults to NULL
--   p_parent_lpn_id            Parent LPN Id - Defaults to NULL
--   p_source_type_id           Source type ID for the source transaction
--   p_source_header_id         Source header ID for the source transaction
--   p_source_name              Source name for the source transaction
--   p_source_line_id           Source line ID for the source transaction
--   p_source_line_detail_id    Source line detail ID for the source transaction
--
--
-- Output Parameters
--   x_return_status
--       if the Create_LPN API succeeds, the value is
--    fnd_api.g_ret_sts_success;
--       if there is an expected error, the value is
--    fnd_api.g_ret_sts_error;
--       if there is an unexpected error, the value is
--    fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--       if there is one or more errors, the number of error messages
--           in the buffer
--   x_msg_data
--       if there is one and only one error, the error message
--   x_lpn_id                The LPN ID for the new LPN record entry
--

PROCEDURE Create_LPN (
  p_api_version           IN         NUMBER
, p_init_msg_list         IN         VARCHAR2 := fnd_api.g_false
, p_commit                IN         VARCHAR2 := fnd_api.g_false
, p_validation_level      IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, p_lpn                   IN         VARCHAR2
, p_organization_id       IN         NUMBER
, p_container_item_id     IN         NUMBER   := NULL
, p_lot_number            IN         VARCHAR2 := NULL
, p_revision              IN         VARCHAR2 := NULL
, p_serial_number         IN         VARCHAR2 := NULL
, p_subinventory          IN         VARCHAR2 := NULL
, p_locator_id            IN         NUMBER   := NULL
, p_source                IN         NUMBER   := LPN_CONTEXT_PREGENERATED
, p_cost_group_id         IN         NUMBER   := NULL
, p_parent_lpn_id         IN         NUMBER   := NULL
, p_source_type_id        IN         NUMBER   := NULL
, p_source_header_id      IN         NUMBER   := NULL
, p_source_name           IN         VARCHAR2 := NULL
, p_source_line_id        IN         NUMBER   := NULL
, p_source_line_detail_id IN         NUMBER   := NULL
, x_lpn_id                OUT NOCOPY NUMBER
);

/*---------------------------------------------------------------------*/
-- Name
--   PROCEDURE Modify_LPN and Modify_LPN_Wrapper
/*---------------------------------------------------------------------*/
-- Purpose
--     Used to update the attributes of a specific container instance (LPN).
--     Modify_LPN_Wrapper just calls Modify_LPN but it doesn't take in a
--     record type as an input.  This is used for the java calls to this
--     procedure in the mobile transactions.
--        Fields that can be modified include:
--            *  all the gross weight and content volume related fields
--            *  status_id, lpn_context, sealed_status
--            *  org, sub, and loc information
--            *  All of the extra Attribute related columns for future usages
--
-- Input Parameters
--   p_api_version
--      API version number (current version is 1.0)
--   p_init_msg_list (optional, default FND_API.G_FALSE)
--      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
--                           if set to FND_API.G_TRUE
--                                   initialize error message list
--                           if set to FND_API.G_FALSE - not initialize error
--                                   message list
--   p_commit (optional, default FND_API.G_FALSE)
--      whether or not to commit the changes to database
--   p_validation_level         (optional), determines if full validation or
--                              no validation will be performed
--                              defaults to FND_API.G_VALID_LEVEL_FULL
--                              FND_API.G_VALID_LEVEL_NONE is the other value
--   p_lpn    WMS_LICENSE_PLATE_NUMBERS%ROWTYPE - Required Value
--                       Stores the information for the fields of the LPN record that
--                       the user desires to modify
--   p_source_type_id           Source type ID for the source transaction
--   p_source_header_id         Source header ID for the source transaction
--   p_source_name              Source name for the source transaction
--   p_source_line_id           Source line ID for the source transaction
--   p_source_line_detail_id    Source line detail ID for the source transaction
--
--
-- Output Parameters
--   x_return_status
--       if the Modify_LPN API succeeds, the value is
--    fnd_api.g_ret_sts_success;
--       if there is an expected error, the value is
--    fnd_api.g_ret_sts_error;
--       if there is an unexpected error, the value is
--    fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--       if there is one or more errors, the number of error messages
--           in the buffer
--   x_msg_data
--       if there is one and only one error, the error message

PROCEDURE Modify_LPN (
  p_api_version           IN         NUMBER
, p_init_msg_list         IN         VARCHAR2 := fnd_api.g_false
, p_commit                IN         VARCHAR2 := fnd_api.g_false
, p_validation_level      IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, p_lpn                   IN         WMS_CONTAINER_PUB.LPN
, p_caller                IN         VARCHAR2 := NULL
);

PROCEDURE Modify_LPN_Wrapper(
  p_api_version           IN         NUMBER
, p_init_msg_list         IN         VARCHAR2 := fnd_api.g_false
, p_commit                IN         VARCHAR2 := fnd_api.g_false
, p_validation_level      IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, p_lpn_id                IN         NUMBER
, p_license_plate_number  IN         VARCHAR2 := NULL
, p_inventory_item_id     IN         NUMBER   := NULL
, p_weight_uom_code       IN         VARCHAR2 := NULL
, p_gross_weight          IN         NUMBER   := NULL
, p_volume_uom_code       IN         VARCHAR2 := NULL
, p_content_volume        IN         NUMBER   := NULL
, p_status_id             IN         NUMBER   := NULL
, p_lpn_context           IN         NUMBER   := NULL
, p_sealed_status         IN         NUMBER   := NULL
, p_organization_id       IN         NUMBER   := NULL
, p_subinventory          IN         VARCHAR  := NULL
, p_locator_id            IN         NUMBER   := NULL
, p_source_type_id        IN         NUMBER   := NULL
, p_source_header_id      IN         NUMBER   := NULL
, p_source_name           IN         VARCHAR2 := NULL
, p_source_line_id        IN         NUMBER   := NULL
, p_source_line_detail_id IN         NUMBER   := NULL
, p_caller                IN         VARCHAR2 := NULL
);

-- Start of comments
-- API name  : PackUnpack_Container
-- Type      : Private
-- Function  : Allows the caller to pack or unpack contents from a container instance or LPN.
--             This API does not update onhand, so should not be used directly for packing
--             items in inventory.  For inventory packs the transaction manager should be used.
-- Pre-reqs  : None.
-- Parameters:
-- IN        :
--   p_api_version
--      API version number (current version is 1.0)
--   p_init_msg_list (optional, default FND_API.G_FALSE)
--      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
--                           if set to FND_API.G_TRUE
--                                   initialize error message list
--                           if set to FND_API.G_FALSE - not initialize error
--                                   message list
--   p_commit (optional, default FND_API.G_FALSE)
--                whether or not to commit the changes to database
--   p_validation_level         (optional), determines if full validation or
--                              no validation will be performed
--                              defaults to FND_API.G_VALID_LEVEL_FULL
--                              FND_API.G_VALID_LEVEL_NONE is the other value
--   p_lpn_id             Parent License Plate Number Identifier - Required Value
--   p_content_lpn_id           Content LPN ID
--   p_content_item_id          Content Item ID          - Defaults to NULL
--   p_content_item_desc   Content Item Description - Defaults to NULL
--   p_revision              Revision                 - Defaults to NULL
--   p_lot_number    Lot Number               - Defaults to NULL
--   p_from_serial_number       Starting Serial Number   - Defaults to NULL
--   p_to_serial_number         Ending Serial Number     - Defaults to NULL
--   p_quantity              Content Quantity         - Defaults to NULL
--                                This value is not required if you are
--                                packing or unpacking an LPN or if you are
--                                packing or unpacking serialized items
--   p_uom        Content Qty UOM          - Defaults to NULL
--   p_organization_id          Organization ID          - Required Value
--   p_subinventory     Subinventory             - Defaults to NULL
--                              Value is the source subinventory if pack,
--                              destination subinventory if unpack operation
--   p_locator_id    Locator Id               - Defaults to NULL
--                              Value is the source locator if pack,
--                              destination locator if unpack operation
--   p_enforce_wv_constraints   Weight and Volume Enforcement Flag
--                                  Defaults to 2 (= No), 1 = Yes
--   p_operation                Type of opertaion, Pack/Unpack - Required Value
--                              1 = Pack      : Add the quantity to the existing amount
--                              2 = Unpack    : Subtract quantity from the existing amount
--                              3 = Adjust    : Change quantity to the given amount
--                              4 = Unpack All: Unpack all contents and unnest all child lpns
--   p_cost_group_id            Cost Group Id - Defaults to NULL
--   p_source_type_id           Source type ID for the source transaction
--   p_source_header_id         Source header ID for the source transaction
--   p_source_name              Source name for the source transaction
--   p_source_line_id           Source line ID for the source transaction
--   p_source_line_detail_id    Source line detail ID for the source transaction
--   p_unpack_all               Parameter signifying if all of the contents
--                              in the LPN should be unpacked
--                                  1 = Yes, 2 = No   Defaults to 2 = No
--   p_auto_unnest_empty_lpns   Parameter signifies if lpns that are empty after
--                              unpacking should be unnested from it's parent LPN (if any)
--                              and made defined but not used.
--                                  1 = Yes, 2 = No   Defaults to 1 = Yes
--   p_ignore_item_controls     Parameter signifies for unpack operations, if this is set to
--                              set to 1 (yes), unpacking will allow user to unpack from WLC
--                              row with null lots even if a value is passed to p_lot_number
--                              similarly, it will igonore errors if a serial within the passed
--                              in serial range was not found within the lpn in MSN
--                                  1 = Yes, 2 = No   Defaults to 2 = No
-- OUT     :
--   x_return_status
--       if the PackUnpack_Container API succeeds, the value is
--    fnd_api.g_ret_sts_success;
--       if there is an expected error, the value is
--    fnd_api.g_ret_sts_error;
--       if there is an unexpected error, the value is
--    fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--       if there is one or more errors, the number of error messages
--           in the buffer
--   x_msg_data
--       if there is one and only one error, the error message
-- Version  : 1.0
-- End of comments

PROCEDURE PackUnpack_Container(
  p_api_version            IN         NUMBER
, p_init_msg_list          IN         VARCHAR2 := fnd_api.g_false
, p_commit                 IN         VARCHAR2 := fnd_api.g_false
, p_validation_level       IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
, p_lpn_id                 IN         NUMBER
, p_content_lpn_id         IN         NUMBER   := NULL
, p_content_item_id        IN         NUMBER   := NULL
, p_content_item_desc      IN         VARCHAR2 := NULL
, p_revision               IN         VARCHAR2 := NULL
, p_lot_number             IN         VARCHAR2 := NULL
, p_from_serial_number     IN         VARCHAR2 := NULL
, p_to_serial_number       IN         VARCHAR2 := NULL
, p_quantity               IN         NUMBER   := 1
, p_uom                    IN         VARCHAR2 := NULL
, p_sec_quantity           IN         NUMBER   := NULL   -- INVCONV kkillams
, p_sec_uom                IN         VARCHAR2 := NULL   -- INVCONV kkillams
, p_organization_id        IN         NUMBER
, p_subinventory           IN         VARCHAR2 := NULL
, p_locator_id             IN         NUMBER   := NULL
, p_enforce_wv_constraints IN         NUMBER   := 2
, p_operation              IN         NUMBER
, p_cost_group_id          IN         NUMBER   := NULL
, p_source_type_id         IN         NUMBER   := NULL
, p_source_header_id       IN         NUMBER   := NULL
, p_source_name            IN         VARCHAR2 := NULL
, p_source_line_id         IN         NUMBER   := NULL
, p_source_line_detail_id  IN         NUMBER   := NULL
, p_unpack_all             IN         NUMBER   := 2
, p_auto_unnest_empty_lpns IN         NUMBER   := 1
, p_ignore_item_controls   IN         NUMBER   := 2
, p_primary_quantity       IN         NUMBER   := NULL
, p_caller                 IN         VARCHAR2 := NULL
, p_source_transaction_id  IN         NUMBER   := NULL
);

/*---------------------------------------------------------------------*/
-- Name
--   PROCEDURE Validate_Update_Wt_Volume
/*---------------------------------------------------------------------*/
-- Purpose
--     Calculates the gross weight and (occupied) volume of a
--      container, every time content is packed into or unpacked
--      from the container.  Also validates that the
--      weight and volume capacity constraints are not
--      violated for a container or any of
--      its parent or nested containers.
--
-- Input Parameters
--   p_api_version
--      API version number (current version is 1.0)
--   p_init_msg_list (optional, default FND_API.G_FALSE)
--      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
--                           if set to FND_API.G_TRUE
--                                   initialize error message list
--                           if set to FND_API.G_FALSE - not initialize error
--                                   message list
--   p_commit (optional, default FND_API.G_FALSE)
--         whether or not to commit the changes to database
--   p_lpn_id            License Plate Number Identifier - Required Value
--   p_content_lpn_id          Content LPN Id   - Defaults to NULL
--   p_content_item_id           Content Item Id  - Defaults to NULL
--   p_quantity            Content Quantity - Defaults to NULL
--   p_uom       Content Qty UOM  - Defaults to NULL
--   p_organization_id           Organization Id  - Defaults to NULL
--   p_enforce_wv_constraints    Weight and Volume Enforcement Flag - Defaults to 2 (= No)
--   p_operation     Type of operation - Required Value
--                                              - Valid Values are 1. Pack  2.Unpack
--   p_action            Action Type - Required Value
--                                        - Valid Values are
--              1. Validate, 2. Update, 3. Validate and Update
-- Output Parameters
--   x_return_status
--       if the Validate_Update_Wt_Volume API succeeds, the value is
--    fnd_api.g_ret_sts_success;
--       if there is an expected error, the value is
--    fnd_api.g_ret_sts_error;
--       if there is an unexpected error, the value is
--    fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--       if there is one or more errors, the number of error messages
--           in the buffer
--   x_msg_data
--       if there is one and only one error, the error message
--   x_valid_operation
--       if the operation to be validated is valid, then this will have a value of 1.
--           otherwise the operation is invalid and this will have a value of 2.
--

PROCEDURE Validate_Update_Wt_Volume(
  p_api_version            IN         NUMBER
, p_init_msg_list          IN         VARCHAR2 := fnd_api.g_false
, p_commit                 IN         VARCHAR2 := fnd_api.g_false
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
, p_lpn_id                 IN         NUMBER
, p_content_lpn_id         IN         VARCHAR2 := NULL
, p_content_item_id        IN         NUMBER   := NULL
, p_quantity               IN         NUMBER   := NULL
, p_uom                    IN         VARCHAR2 := NULL
, p_organization_id        IN         NUMBER   := NULL
, p_enforce_wv_constraints IN         NUMBER   := 2
, p_operation              IN         NUMBER
, p_action                 IN         NUMBER
, x_valid_operation        OUT NOCOPY NUMBER
);

/*---------------------------------------------------------------------*/
-- Name
--   PROCEDURE Container_Required_Qty
/*---------------------------------------------------------------------*/
-- Purpose
--    Calculates the quantity of containers required to store
--    (source) the inventory item  or container specified.
--    If the destination container given, it will be calculated for
--    the given container item or it will be calculated as per the
--    item/container relationship definitions.
--
-- Input Parameters
--   p_api_version
--      API version number (current version is 1.0)
--   p_init_msg_list (optional, default FND_API.G_FALSE)
--      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
--                           if set to FND_API.G_TRUE
--                                   initialize error message list
--                           if set to FND_API.G_FALSE - not initialize error
--                                   message list
--   p_commit (optional, default FND_API.G_FALSE)
--      whether or not to commit the changes to database
--   p_source_item_id         Source Item id (can also be a container Item) - Required Value
--   p_source_qty   Source Item Qty        - Required Value
--   p_source_qty_uom         UOM of Source Item Qty - Required Value
--   p_qty_per_container  Qty per each container - Defaults to NULL
--   p_qty_per_container_uom  UOM of Qty per each container - Defaults to NULL
--   p_organization_id          Organization Id - Defaults to NULL
--   p_dest_cont_item_id        Destination container item id - IN OUT parameter
--
--
-- Output Parameters
--   x_return_status
--       if the Container_Required_Qty API succeeds, the value is
--    fnd_api.g_ret_sts_success;
--       if there is an expected error, the value is
--    fnd_api.g_ret_sts_error;
--       if there is an unexpected error, the value is
--    fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--       if there is one or more errors, the number of error messages
--           in the buffer
--   x_msg_data
--       if there is one and only one error, the error message
--   p_dest_cont_item_id        Destination container item id - IN OUT parameter
--   p_qty_required   Required Container Quantity

PROCEDURE Container_Required_Qty(
  p_api_version       IN            NUMBER
, p_init_msg_list     IN            VARCHAR2 := fnd_api.g_false
, p_commit            IN            VARCHAR2 := fnd_api.g_false
, x_return_status     OUT    NOCOPY VARCHAR2
, x_msg_count         OUT    NOCOPY NUMBER
, x_msg_data          OUT    NOCOPY VARCHAR2
, p_source_item_id    IN            NUMBER
, p_source_qty        IN            NUMBER
, p_source_qty_uom    IN            VARCHAR2
, p_qty_per_cont      IN            NUMBER   := NULL
, p_qty_per_cont_uom  IN            VARCHAR2 := NULL
, p_organization_id   IN            NUMBER
, p_dest_cont_item_id IN OUT NOCOPY NUMBER
, p_qty_required      OUT    NOCOPY NUMBER
);

/*---------------------------------------------------------------------*/
-- Name
--   PROCEDURE Prepack_LPN_CP
/*---------------------------------------------------------------------*/
-- Purpose
--   Allows the packing of items that are not yet in inventory.  LPN's are
--   pre-generated and associated with contents at the release of a WIP job.
--   The LPN's generated will have a state of "Resides in WIP" so that their
--   contents are not included in on hand inventory
--
--
-- Input Parameters
--   p_api_version
--      API version number (current version is 1.0)
--   p_init_msg_list (optional, default FND_API.G_FALSE)
--      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
--                           if set to FND_API.G_TRUE
--                                   initialize error message list
--                           if set to FND_API.G_FALSE - do not initialize error
--                                   message list
--   p_commit (optional, default FND_API.G_FALSE)
--      whether or not to commit the changes to database
--   p_organization_id          Organization of the LPN          - Required
--   p_subinventory   Subinventory - Defaults to NULL
--   p_locator_id   Locator Id - Defaults to NULL
--   p_inventory_item_id        Inventory ID number              - Required
--   p_revision                 Revision of the inventory item
--   p_lot_number               Lot number of the inventory item
--   p_quantity                 Quantity of item to be prepacked - Required
--   p_uom                      UOM of the quantity prepacked    - Required
--   p_source                   Source of information (WIP/REC)
--   p_serial_number_from       Starting serial number for inventory item
--   p_serial_number_to         Ending serial number for inventory item
--   p_container_item_id        Inventory item ID for a container item
--   p_cont_revision    Revision of the container item
--   p_cont_lot_number    Lot Number of the container item
--   p_cont_serial_number_from  From serial number of the container item
--   p_cont_serial_number_to    To serial number of the container item
--   p_lpn_sealed_flag          Flag to tell if LPN should be sealed or not
--   p_print_label              Should labels be printed afterwards
--   p_print_content_report     Should content reports be generated afterwards
--
--
-- Output Parameters
--   ERRBUF                 Concurrent program error buffer
--   RETCODE                Concurrent program return code
--   x_return_status
--       if the Prepack_LPN API succeeds, the value is
--    fnd_api.g_ret_sts_success;
--       if there is an expected error, the value is
--    fnd_api.g_ret_sts_error;
--       if there is an unexpected error, the value is
--    fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--       if there is one or more errors, the number of error messages
--           in the buffer
--   x_msg_data
--       if there is one and only one error, the error message
--

PROCEDURE Prepack_LPN_CP(
   ERRBUF                    OUT NOCOPY VARCHAR2
,  RETCODE                   OUT NOCOPY NUMBER
,  p_api_version             IN         NUMBER
,  p_organization_id         IN         NUMBER
,  p_subinventory            IN         VARCHAR2 := NULL
,  p_locator_id              IN         NUMBER   := NULL
,  p_inventory_item_id       IN         NUMBER
,  p_revision                IN         VARCHAR2 := NULL
,  p_lot_number              IN         VARCHAR2 := NULL
,  p_quantity                IN         NUMBER
,  p_uom                     IN         VARCHAR2
,  p_source                  IN         NUMBER
,  p_serial_number_from      IN         VARCHAR2 := NULL
,  p_serial_number_to        IN         VARCHAR2 := NULL
,  p_container_item_id       IN         NUMBER   := NULL
,  p_cont_revision           IN         VARCHAR2 := NULL
,  p_cont_lot_number         IN         VARCHAR2 := NULL
,  p_cont_serial_number_from IN         VARCHAR2 := NULL
,  p_cont_serial_number_to   IN         VARCHAR2 := NULL
,  p_lpn_sealed_flag         IN         NUMBER   := NULL
,  p_print_label             IN         NUMBER   := NULL
,  p_print_content_report    IN         NUMBER   := NULL
,  p_packaging_level         IN         NUMBER   := -1
,  p_sec_quantity            IN         NUMBER   := NULL  --INVCONV kkillams
,  p_sec_uom                 IN         VARCHAR2 := NULL  --INVCONV kkillams
);

/*---------------------------------------------------------------------*/
-- Name
--   PROCEDURE Prepack_LPN
/*---------------------------------------------------------------------*/
-- Purpose
--   Allows the packing of items that are not yet in inventory.  LPN's are
--   pre-generated and associated with contents at the release of a WIP job.
--   The LPN's generated will have a state of "Resides in WIP" so that their
--   contents are not included in on hand inventory
--
--
-- Input Parameters
--   p_api_version
--      API version number (current version is 1.0)
--   p_init_msg_list (optional, default FND_API.G_FALSE)
--      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
--                           if set to FND_API.G_TRUE
--                                   initialize error message list
--                           if set to FND_API.G_FALSE - do not initialize error
--                                   message list
--   p_commit (optional, default FND_API.G_FALSE)
--      whether or not to commit the changes to database
--   p_organization_id          Organization of the LPN          - Required
--   p_subinventory   Subinventory - Defaults to NULL
--   p_locator_id   Locator Id - Defaults to NULL
--   p_inventory_item_id        Inventory ID number              - Required
--   p_revision                 Revision of the inventory item
--   p_lot_number               Lot number of the inventory item
--   p_quantity                 Quantity of item to be prepacked - Required
--   p_uom                      UOM of the quantity prepacked    - Required
--   p_source                   Source of information (WIP/REC)
--   p_serial_number_from       Starting serial number for inventory item
--   p_serial_number_to         Ending serial number for inventory item
--   p_container_item_id        Inventory item ID for a container item
--   p_cont_revision    Revision of the container item
--   p_cont_lot_number    Lot Number of the container item
--   p_cont_serial_number_from  From serial number of the container item
--   p_cont_serial_number_to    To serial number of the container item
--   p_lpn_sealed_flag          Flag to tell if LPN should be sealed or not
--   p_print_label              Should labels be printed afterwards
--   p_print_content_report     Should content reports be generated afterwards
--
--
-- Output Parameters
--   x_return_status
--       if the Prepack_LPN API succeeds, the value is
--    fnd_api.g_ret_sts_success;
--       if there is an expected error, the value is
--    fnd_api.g_ret_sts_error;
--       if there is an unexpected error, the value is
--    fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--       if there is one or more errors, the number of error messages
--           in the buffer
--   x_msg_data
--       if there is one and only one error, the error message
--

PROCEDURE Prepack_LPN(
  p_api_version             IN         NUMBER
, p_init_msg_list           IN         VARCHAR2 := fnd_api.g_false
, p_commit                  IN         VARCHAR2 := fnd_api.g_false
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_organization_id         IN         NUMBER
, p_subinventory            IN         VARCHAR2 := NULL
, p_locator_id              IN         NUMBER   := NULL
, p_inventory_item_id       IN         NUMBER
, p_revision                IN         VARCHAR2 := NULL
, p_lot_number              IN         VARCHAR2 := NULL
, p_quantity                IN         NUMBER
, p_uom                     IN         VARCHAR2
, p_source                  IN         NUMBER
, p_serial_number_from      IN         VARCHAR2 := NULL
, p_serial_number_to        IN         VARCHAR2 := NULL
, p_container_item_id       IN         NUMBER   := NULL
, p_cont_revision           IN         VARCHAR2 := NULL
, p_cont_lot_number         IN         VARCHAR2 := NULL
, p_cont_serial_number_from IN         VARCHAR2 := NULL
, p_cont_serial_number_to   IN         VARCHAR2 := NULL
, p_lpn_sealed_flag         IN         NUMBER   := NULL
, p_print_label             IN         NUMBER   := NULL
, p_print_content_report    IN         NUMBER   := NULL
, p_packaging_level         IN         NUMBER   := -1
, p_sec_quantity            IN         NUMBER   := NULL  --INVCONV kkillams
, p_sec_uom                 IN         VARCHAR2 := NULL  --INVCONV kkillams
);

-- Start of comments
-- API name  : Pack_Prepack_Container
-- Type      : Private
-- Function  : Allows the caller to define the lot and serials of of the items that were originally
--             prepacked
-- Pre-reqs  : None.
-- Parameters:
-- IN        :
--   p_api_version
--      API version number (current version is 1.0)
--   p_init_msg_list (optional, default FND_API.G_FALSE)
--      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
--                           if set to FND_API.G_TRUE
--                                   initialize error message list
--                           if set to FND_API.G_FALSE - not initialize error
--                                   message list
--   p_commit (optional, default FND_API.G_FALSE)
--                whether or not to commit the changes to database
--   p_validation_level         (optional), determines if full validation or
--                              no validation will be performed
--                              defaults to FND_API.G_VALID_LEVEL_FULL
--                              FND_API.G_VALID_LEVEL_NONE is the other value
--   p_lpn_id             Parent License Plate Number Identifier - Required Value
--   p_content_item_id          Content Item ID          - Defaults to NULL
--   p_revision              Revision                 - Defaults to NULL
--   p_lot_number    Lot Number               - Defaults to NULL
--   p_from_serial_number       Starting Serial Number   - Defaults to NULL
--   p_to_serial_number         Ending Serial Number     - Defaults to NULL
--   p_quantity              Content Quantity         - Defaults to NULL
--   p_uom        Content Qty UOM          - Defaults to NULL
--   p_organization_id          Organization ID          - Required Value
--   p_operation                Type of opertaion, Pack/Unpack      - Required Value
--                                  1 = Pack, 2 = Unpack
--   p_source_type_id           Source type ID for the source transaction
-- OUT     :
--   x_return_status
--       if the PackUnpack_Container API succeeds, the value is
--    fnd_api.g_ret_sts_success;
--       if there is an expected error, the value is
--    fnd_api.g_ret_sts_error;
--       if there is an unexpected error, the value is
--    fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--       if there is one or more errors, the number of error messages
--           in the buffer
--   x_msg_data
--       if there is one and only one error, the error message
-- Version  : 1.0
-- End of comments

PROCEDURE Pack_Prepack_Container(
  p_api_version        IN         NUMBER
, p_init_msg_list      IN         VARCHAR2 := fnd_api.g_false
, p_commit             IN         VARCHAR2 := fnd_api.g_false
, p_validation_level   IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
, p_lpn_id             IN         NUMBER
, p_content_item_id    IN         NUMBER   := NULL
, p_revision           IN         VARCHAR2 := NULL
, p_lot_number         IN         VARCHAR2 := NULL
, p_from_serial_number IN         VARCHAR2 := NULL
, p_to_serial_number   IN         VARCHAR2 := NULL
, p_quantity           IN         NUMBER   := 1
, p_uom                IN         VARCHAR2 := NULL
, p_organization_id    IN         NUMBER
, p_operation          IN         NUMBER
, p_source_type_id     IN         NUMBER   := NULL
);

-- Start of comments
-- API name  : Explode_LPN
-- Type      : Private
-- Function  : API returns a PL/SQL table of a containers contents.
--             User will pass in the LPN of
--             the container to be exploded and the level to explode to.
-- Pre-reqs  : None.
-- Parameters:
-- IN        :
--   p_api_version
--      API version number (current version is 1.0)
--   p_init_msg_list (optional, default FND_API.G_FALSE)
--      Valid values: FND_API.G_FALSE or FND_API.G_TRUE.
--                           if set to FND_API.G_TRUE
--                                   initialize error message list
--                           if set to FND_API.G_FALSE - not initialize error
--                                   message list
--   p_commit (optional, default FND_API.G_FALSE)
--      whether or not to commit the changes to database
--   p_lpn_id           License Plate Number Identifier - Required Value
--   p_explosion_level        Explosion Level - Defaults to 0 (Explode to all levels)
--
-- OUT       :
--   x_return_status
--       if the Explode_LPN API succeeds, the value is
--    fnd_api.g_ret_sts_success;
--       if there is an expected error, the value is
--    fnd_api.g_ret_sts_error;
--       if there is an unexpected error, the value is
--    fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--       if there is one or more errors, the number of error messages
--           in the buffer
--   x_msg_data
--       if there is one and only one error, the error message
-- Version  : 1.0
-- End of comments

PROCEDURE Explode_LPN (
  p_api_version     IN         NUMBER
, p_init_msg_list   IN         VARCHAR2 := fnd_api.g_false
, p_commit          IN         VARCHAR2 := fnd_api.g_false
, x_return_status   OUT NOCOPY VARCHAR2
, x_msg_count       OUT NOCOPY NUMBER
, x_msg_data        OUT NOCOPY VARCHAR2
, p_lpn_id          IN         NUMBER
, p_explosion_level IN         NUMBER   := 0
, x_content_tbl     OUT NOCOPY WMS_CONTAINER_PUB.WMS_Container_Tbl_Type
);

/*---------------------------------------------------------------------*/
-- Name
--   FUNCTION Validate_LPN
/*---------------------------------------------------------------------*/
-- Purpose
--    This Function returns a row of WMS_Licese_Plate_Numbers entity
--
-- Input Parameters
--    p_lpn   License_Plate_Number entity Row type variable
-- Output Value - 1. Success  0. Failure
-- Version  : 1.0
-- End of comments

-- Constant Return Values for Validation APIs
T CONSTANT NUMBER := 1;
F CONSTANT NUMBER := 0;

FUNCTION Validate_LPN (
  p_lpn  IN OUT NOCOPY WMS_CONTAINER_PUB.LPN
, p_lock IN            NUMBER := 2
) RETURN NUMBER;


-- Constant validation types supported buy Validate_LPN
-- G_RECONFIGURE_LPN will validate the existance of given lpn
-- Validatoin will pass if there are no pending transactions in MMTT
-- or reservations for this lpn or any of it's child LPNs
G_RECONFIGURE_LPN CONSTANT VARCHAR2(30)  := 'Reconfigure_LPN';

-- G_NO_ONHAND_EXISTS will validate the existance of contents given lpn
-- Validatoin will pass if there are no onhand quantity in
-- MTL_ONHAND_QUANTITIES_DETIAL or MTL_SERIAL_NUMBERS
-- associated to this lpn
G_NO_ONHAND_EXISTS CONSTANT VARCHAR2(30) := 'No_Onhand_Exists';

-- Start of comments
--  API name: Validate_LPN
--  Type    : Private
--  Pre-reqs: None.
--  Function: Returns 1 if the lpn is valid for the given type
--                    0 otherwise
--  Parameters:
--  IN: p_organization_id   IN NUMBER   Required
--        Item organization id. Part of the unique key
--        that uniquely identifies an item record.
--      p_lpn_id            IN NUMBER   Required
--        Corresponds to the column lpn_id of the LPN to validate
--      p_validation_type   IN VARCHAR2 Required
--        The UOM in which secondary quantity should be calculated from
--        If no UOM is passes, API will use the primary UOM
--  Version : Current version 1.0
-- End of comments

FUNCTION Validate_LPN (
  p_organization_id IN NUMBER
, p_lpn_id          IN NUMBER
, p_validation_type IN VARCHAR2
) RETURN NUMBER;

-- Start of comments
--  API name: Merge_Up_LPN
--  Type    : Private
--  Pre-reqs: None.
--  Function: Creates and executes transactions in MTL_MATERIAL_TRANSACTIONS_TEMP
--            to consolidate contents of a nested LPN structure into the outermost
--            LPN
--  Example: Before Merge Up
--
--             Item A Qty 3                 Item A Qty 2
--             Item B Qty 4                 Item C Qty 5
--            -------------- Item C Qty 2  --------------
--                LPN3       Item D Qty 3       LPN2
--           ----------------------------------------------
--                                LPN 1
--           After Merge Up
--
--            Item A Qty 5
--            Item B Qty 4
--            Item C Qty 7
--            Item D Qty 3      Empty          Empty
--           -------------- -------------- --------------
--               LPN 1          LPN 2          LPN 3
--  Parameters:
--  IN: p_organization_id   IN NUMBER   Required
--        LPN organization id. Part of the unique key
--        that uniquely identifies an LPN record.
--      p_outermost_lpn_id  IN NUMBER   Required
--        Corresponds to the column lpn_id of the LPN to validate
--        This LPN must be the outermost LPN, i.e. cannot have any
--        parent LPN (nested)
--  Version : Current version 1.0
-- End of comments

PROCEDURE Merge_Up_LPN (
  p_api_version             IN         NUMBER
, p_init_msg_list           IN         VARCHAR2 := fnd_api.g_false
, p_commit                  IN         VARCHAR2 := fnd_api.g_false
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_organization_id         IN         NUMBER
, p_outermost_lpn_id        IN         NUMBER
);

-- Start of comments
--  API name: Break_Down_LPN
--  Type    : Private
--  Pre-reqs: None.
--  Function: Creates and executes transactions in MTL_MATERIAL_TRANSACTIONS_TEMP
--            to unnest LPN structure but leaving all contents in their original
--            LPNs
--  Example: Before Break Down
--
--             Item A Qty 3                 Item A Qty 2
--             Item B Qty 4                 Item C Qty 5
--            -------------- Item C Qty 2  --------------
--                LPN3       Item D Qty 3       LPN2
--           ----------------------------------------------
--                                LPN 1
--           After Break Down
--
--            Item C Qty 2   Item A Qty 2   Item A Qty 3
--            Item D Qty 3   Item C Qty 5   Item B Qty 4
--           -------------- -------------- --------------
--               LPN 1          LPN 2          LPN 3
--  Parameters:
--  IN: p_organization_id   IN NUMBER   Required
--        LPN organization id. Part of the unique key
--        that uniquely identifies an LPN record.
--      p_outermost_lpn_id  IN NUMBER   Required
--        Corresponds to the column lpn_id of the LPN to validate
--        This LPN must be the outermost LPN, i.e. cannot have any
--        parent LPN (nested)
--  Version : Current version 1.0
-- End of comments

PROCEDURE Break_Down_LPN (
  p_api_version             IN         NUMBER
, p_init_msg_list           IN         VARCHAR2 := fnd_api.g_false
, p_commit                  IN         VARCHAR2 := fnd_api.g_false
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_organization_id         IN         NUMBER
, p_outermost_lpn_id        IN         NUMBER
);

-- Start of comments
--  API name: Initialize_LPN
--  Type    : Private
--  Pre-reqs: None.
--  Function: Clears LPN of all contents and resets LPN to defined but not used
--            (pregenerated) status, clearing subinventory and location information.
--            If LPN is nested, all nested lpns will also be initialized
--            API will only remove information from
--  Parameters:
--  IN: p_organization_id  IN NUMBER   Required
--        LPN organization id. Part of the unique key
--        that uniquely identifies an LPN record.
--      p_outermost_lpn_id IN NUMBER   Required
--        Corresponds to the column lpn_id of the LPN to Initialize
--        This LPN must be the outermost LPN, i.e. cannot have any
--        parent LPN (nested)
--  Version : Current version 1.0
-- End of comments

PROCEDURE Initialize_LPN (
  p_api_version             IN         NUMBER
, p_init_msg_list           IN         VARCHAR2 := fnd_api.g_false
, p_commit                  IN         VARCHAR2 := fnd_api.g_false
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_organization_id         IN         NUMBER
, p_outermost_lpn_id        IN         NUMBER
);

/*---------------------------------------------------------------------*/
-- Name
--   PROCEDURE plan_delivery
/*---------------------------------------------------------------------*/
-- Purpose
-- Informs shipping at the time of a packing operation to inform shipping
-- of the packing event.
--
-- Input Parameters
--   p_lpn_id  The LPN which is being split or consolidated.
-- Output Parameters
--   x_return_status
--       if the plan_delivery API succeeds, the value is
--              fnd_api.g_ret_sts_success;
--       if there is an expected error, the value is
--              fnd_api.g_ret_sts_error;
--       if there is an unexpected error, the value is
--              fnd_api.g_ret_sts_unexp_error;
--   x_msg_count
--       if there is one or more errors, the number of error messages
--           in the buffer
--   x_msg_data
--       if there is one and only one error, the error message
--
PROCEDURE plan_delivery(p_lpn_id        IN NUMBER,
                        x_return_status OUT nocopy VARCHAR2,
                        x_msg_data      OUT nocopy VARCHAR2,
                        x_msg_count     OUT nocopy NUMBER);

-------------------------------------------------
-- Added for LSP Project, bug 9087971
-- NAME
-- PROCEDURE get_item_from_lpn
-------------------------------------------------
-- Purpose
-- 		Following procedure will get the concatenated item segments from the given LPN.
--
-- Input Parameters
--    p_org			Organization ID
--	p_lpn_id		LPN ID
--	p_lpn_context	Context of the LPN
--
-- Output Parameters
--	x_item		Item name
PROCEDURE get_item_from_lpn
  (
    p_org         IN NUMBER,
    p_lpn_id      IN NUMBER,
    p_lpn_context IN NUMBER,
    x_item OUT NOCOPY VARCHAR2 );

END WMS_CONTAINER_PVT;


/
