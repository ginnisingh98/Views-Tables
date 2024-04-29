--------------------------------------------------------
--  DDL for Package WMS_CONTAINER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_CONTAINER_PUB" AUTHID CURRENT_USER AS
/* $Header: WMSCONTS.pls 120.6.12010000.3 2009/11/26 09:44:49 abasheer ship $ */
/*#
* This object handles the creation and updating license plate numbers
* @rep:scope public
* @rep:product WMS
* @rep:lifecycle active
* @rep:displayname License Plate Number APIs for WMS
* @rep:category BUSINESS_ENTITY WMS_CONTAINER
*/

/* Defined ROW Type variable for WMS_LICENSE_PLATE_NUMBERS entity */


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
 *  Global data structures
 *----------------------------------------------------------------*/

SUBTYPE LPN IS WMS_LICENSE_PLATE_NUMBERS%ROWTYPE;

TYPE ChangeWeightVolumeRecType is RECORD
        (       lpn_id                                          NUMBER,
                gross_weight_change             NUMBER,
                content_volume_change   NUMBER  );

TYPE ChangedWtVolTabType IS TABLE OF ChangeWeightVolumeRecType
        INDEX BY BINARY_INTEGER;

G_LPN_WT_VOL_CHANGES ChangedWtVolTabType;


/*#
* This api is used to generate LPN numbers, either individually or in a sequence.
*
* @ param p_api_version API version number (current version is 1.0)
* @ paraminfo {@rep:required}
* @ param p_init_msg_list  default FND_API.G_FALSE) Valid values: FND_API.G_FALSE or FND_API.G_TRUE. if set to FND_API.G_TRUE initialize error message list if set to FND_API.G_FALSE - not initialize error message list
* @ paraminfo {@rep:required}
* @ param p_commit         default FND_API.G_FALSE whether or not to commit the changes to database
* @ paraminfo {@rep:required}
* @ param p_validation_level determines if full validation or no validation will be performed defaults to FND_API.G_VALID_LEVEL_FULL; FND_API.G_VALID_LEVEL_NONE is the other value
* @ paraminfo {@rep:required}
* @ param p_organization_id Organization Id
* @ paraminfo {@rep:required}
* @ param p_container_item_id Container Item Id - Defaults to NULL
* @ paraminfo {@rep:optional}
* @ param p_revision              Revision - Defaults to NULL
* @ paraminfo {@rep:optional}
* @ param p_lot_number            Lot Number - Defaults to NULL
* @ paraminfo {@rep:optional}
* @ param p_from_serial_number    Starting Serial Number   - Defaults to NULL
* @ paraminfo {@rep:optional}
* @ param p_to_serial_number      Ending Serial Number     - Defaults to NULL
* @ paraminfo {@rep:optional}
* @ param p_subinventory          Subinventory - Defaults to NULL
* @ paraminfo {@rep:optional}
* @ param p_locator_id            Locator Id - Defaults to NULL
* @ paraminfo {@rep:optional}
* @ param p_lpn_prefix            Prefix Value of an LPN - Defaults to NULL
* @ paraminfo {@rep:optional}
* @ param p_lpn_suffix            Suffix Value of an LPN - Defaults to NULL
* @ paraminfo {@rep:optional}
* @ param p_starting_num          Starting Number of an LPN - Defaults to NULL
* @ paraminfo {@rep:optional}
* @ param p_quantity              No of LPNs to be generated - Default Value is 1
* @ paraminfo {@rep:required}
* @ param p_source                LPN Context 1=INV, 2=WIP, 3=REC, etc.. Defaults to 5. Indicates the source where the LPN is generated
* @ paraminfo {@rep:required}
* @ param p_cost_group_id         Cost Group Id - Defaults to NULL
* @ paraminfo {@rep:optional}
* @ param p_source_type_id        Source type ID for the source transaction
* @ paraminfo {@rep:optional}
* @ param p_source_header_id      Source header ID for the source transaction
* @ paraminfo {@rep:optional}
* @ param p_source_name           Source name for the source transaction
* @ paraminfo {@rep:optional}
* @ param p_source_line_id        Source line ID for the source transaction
* @ paraminfo {@rep:optional}
* @ param p_source_line_detail_id Source line detail ID for the source transaction
* @ paraminfo {@rep:optional}
* @ param p_total_length          Specify the total length of LPN, pad with 0 numeric portion of LPN
* @ paraminfo {@rep:optional}
* @ param p_ucc_128_suffix_flag   Use a UCC128 suffix on LPNs or not 'Y'/'N'
* @ paraminfo {@rep:optional}
* @ param x_return_status if the Generate_LPN API succeeds, the value is fnd_api.g_ret_sts_success; if there is an expected error, the value is fnd_api.g_ret_sts_error; if there is an unexpected error, the value is fnd_api.g_ret_sts_unexp_error;
* @ paraminfo {@rep:required}
* @ param x_msg_count  if there is one or more errors, the number of error messages in the buffer
* @ paraminfo {@rep:required}
* @ param x_msg_data   if there is one and only one error, the error message
* @ paraminfo {@rep:required}
* @ param p_lpn_id_out Outputs the generated LPN ID if only one LPN is requested to be generated
* @ paraminfo {@rep:required}
* @ param p_lpn_out    Outputs the generated license plate number if only one LPN is requested to be generated
* @ paraminfo {@rep:required}
* @ param p_process_id Process ID to identify the LPN's generated in the table WMS_LPN_PROCESS_TEMP
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Generate License Plate Numbers
* @rep:businessevent Generate_LPN
*/
PROCEDURE Generate_LPN (
  p_api_version            IN         NUMBER
, p_init_msg_list          IN         VARCHAR2 := fnd_api.g_false
, p_commit                 IN         VARCHAR2 := fnd_api.g_false
, p_validation_level       IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
, p_organization_id        IN         NUMBER
, p_container_item_id      IN         NUMBER   := NULL
, p_revision               IN         VARCHAR2 := NULL
, p_lot_number             IN         VARCHAR2 := NULL
, p_from_serial_number     IN         VARCHAR2 := NULL
, p_to_serial_number       IN         VARCHAR2 := NULL
, p_subinventory           IN         VARCHAR2 := NULL
, p_locator_id             IN         NUMBER   := NULL
, p_lpn_prefix             IN         VARCHAR2 := NULL
, p_lpn_suffix             IN         VARCHAR2 := NULL
, p_starting_num           IN         NUMBER   := NULL
, p_quantity               IN         NUMBER   := 1
, p_source                 IN         NUMBER   := LPN_CONTEXT_PREGENERATED
, p_cost_group_id          IN         NUMBER   := NULL
, p_source_type_id         IN         NUMBER   := NULL
, p_source_header_id       IN         NUMBER   := NULL
, p_source_name            IN         VARCHAR2 := NULL
, p_source_line_id         IN         NUMBER   := NULL
, p_source_line_detail_id  IN         NUMBER   := NULL
, p_total_length           IN         NUMBER   := NULL
, p_ucc_128_suffix_flag    IN         VARCHAR2 := NULL
, p_lpn_id_out             OUT NOCOPY NUMBER
, p_lpn_out                OUT NOCOPY VARCHAR2
, p_process_id             OUT NOCOPY NUMBER
);

-- Overleaded the procedure for the WMS specific changes for LSP, bug 9087971

PROCEDURE Generate_LPN (
  p_api_version            IN         NUMBER
, p_init_msg_list          IN         VARCHAR2 := fnd_api.g_false
, p_commit                 IN         VARCHAR2 := fnd_api.g_false
, p_validation_level       IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
, p_organization_id        IN         NUMBER
, p_container_item_id      IN         NUMBER   := NULL
, p_revision               IN         VARCHAR2 := NULL
, p_lot_number             IN         VARCHAR2 := NULL
, p_from_serial_number     IN         VARCHAR2 := NULL
, p_to_serial_number       IN         VARCHAR2 := NULL
, p_subinventory           IN         VARCHAR2 := NULL
, p_locator_id             IN         NUMBER   := NULL
, p_lpn_prefix             IN         VARCHAR2 := NULL
, p_lpn_suffix             IN         VARCHAR2 := NULL
, p_starting_num           IN         NUMBER   := NULL
, p_quantity               IN         NUMBER   := 1
, p_source                 IN         NUMBER   := LPN_CONTEXT_PREGENERATED
, p_cost_group_id          IN         NUMBER   := NULL
, p_source_type_id         IN         NUMBER   := NULL
, p_source_header_id       IN         NUMBER   := NULL
, p_source_name            IN         VARCHAR2 := NULL
, p_source_line_id         IN         NUMBER   := NULL
, p_source_line_detail_id  IN         NUMBER   := NULL
, p_total_length           IN         NUMBER   := NULL
, p_ucc_128_suffix_flag    IN         VARCHAR2 := NULL
, p_lpn_id_out             OUT NOCOPY NUMBER
, p_lpn_out                OUT NOCOPY VARCHAR2
, p_process_id             OUT NOCOPY NUMBER
, p_client_code	           IN         VARCHAR2 -- Adding for LSP, bug 9087971

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
--              whether or not to commit the changes to database
--   p_validation_level         (optional), determines if full validation or
--                              no validation will be performed
--                              defaults to FND_API.G_VALID_LEVEL_FULL
--                              FND_API.G_VALID_LEVEL_NONE is the other value
--   p_lpn_id                   License Plate Number Identifier - Required Value
--   p_container_item_id        Container Item Id - Required Value
--   p_lot_number               Lot Number - Defaults to NULL
--   p_revision                 Revision - Defaults to NULL
--   p_serial_number            Serial Number - Defaults to NULL
--   p_organization_id          Organization Id - Required Value
--   p_subinventory             Subinventory - Defaults to NULL
--   p_locator_id               Locator Id - Defaults to NULL
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
/***********************************************************************/
/* WARNING Starting with patch set 11i.X This API will become obsolete */
/* Patch set J is the last patch set in which this API will exist in   */
/* this package all references will need to be removed by X            */
/***********************************************************************/

PROCEDURE Associate_LPN
(  p_api_version            IN      NUMBER                          ,
   p_init_msg_list          IN      VARCHAR2 := fnd_api.g_false     ,
   p_commit                 IN      VARCHAR2 := fnd_api.g_false     ,
   p_validation_level       IN      NUMBER   := fnd_api.g_valid_level_full  ,
   x_return_status          OUT     NOCOPY VARCHAR2                        ,
   x_msg_count              OUT     NOCOPY NUMBER                          ,
   x_msg_data               OUT     NOCOPY VARCHAR2                        ,
   p_lpn_id                 IN      NUMBER                          ,
   p_container_item_id      IN      NUMBER                          ,
   p_lot_number             IN      VARCHAR2 := NULL                ,
   p_revision               IN      VARCHAR2 := NULL                ,
   p_serial_number          IN      VARCHAR2 := NULL                ,
   p_organization_id        IN      NUMBER                          ,
   p_subinventory           IN      VARCHAR2 := NULL                ,
   p_locator_id             IN      NUMBER   := NULL                ,
   p_cost_group_id          IN      NUMBER   := NULL                ,
   p_source_type_id         IN      NUMBER   := NULL                ,
   p_source_header_id       IN      NUMBER   := NULL                ,
   p_source_name            IN      VARCHAR2 := NULL                ,
   p_source_line_id         IN      NUMBER   := NULL                ,
   p_source_line_detail_id  IN      NUMBER   := NULL
);

/*#
* This api takes in a brand new container name (License Plate Number) and will create an entry for it in
* the WMS_LICENSE_PLATE_NUMBERS table returning to the caller a uniquely generated LPN_ID.
*
* @ param p_api_version API version number (current version is 1.0)
* @ paraminfo {@rep:required}
* @ param p_init_msg_list   default FND_API.G_FALSE Valid values: FND_API.G_FALSE or FND_API.G_TRUE. if set to FND_API.G_TRUE initialize error message list if set to FND_API.G_FALSE - not initialize error message list
* @ paraminfo {@rep:required}
* @ param p_commit          default FND_API.G_FALSE whether or not to commit the changes to database
* @ paraminfo {@rep:required}
* @ param p_validation_level determines if full validation or no validation will be performed defaults to FND_API.G_VALID_LEVEL_FULL FND_API.G_VALID_LEVEL_NONE is the other value
* @ paraminfo {@rep:required}
* @ param p_lpn License Plate Number Identifier - Required Value
* @ paraminfo {@rep:required}
* @ param p_organization_id Organization Id - Required Value
* @ paraminfo {@rep:required}
* @ param p_container_item_id   Container Item Id - Defaults to NULL
* @ paraminfo {@rep:optional}
* @ param p_revision Revision - Defaults to NULL
* @ paraminfo {@rep:optional}
* @ param p_lot_number Lot Number - Defaults to NULL
* @ paraminfo {@rep:optional}
* @ param p_serial_number Serial Number - Defaults to NULL
* @ paraminfo {@rep:optional}
* @ param p_subinventory Subinventory - Defaults to NULL
* @ paraminfo {@rep:optional}
* @ param p_locator_id Locator Id - Defaults to NULL
* @ paraminfo {@rep:optional}
* @ param p_source LPN Context. 1=INV, 2=WIP, or =REC, etc..Defaults to 5.
* @ paraminfo {@rep:required}
* @ param p_cost_group_id Cost Group Id - Defaults to NULL
* @ paraminfo {@rep:optional}
* @ param p_parent_lpn_id Parent LPN Id - Defaults to NULL
* @ paraminfo {@rep:optional}
* @ param p_source_type_id Source type ID for the source transaction
* @ paraminfo {@rep:optional}
* @ param p_source_header_id Source header ID for the source transaction
* @ paraminfo {@rep:optional}
* @ param p_source_name Source name for the source transaction
* @ paraminfo {@rep:optional}
* @ param p_source_line_id Source line ID for the source transaction
* @ paraminfo {@rep:optional}
* @ param p_source_line_detail_id Source line detail ID for the source transaction
* @ paraminfo {@rep:optional}
* @ param x_return_status if the Create_LPN API succeeds, the value is fnd_api.g_ret_sts_success; if there is an expected error, the value is fnd_api.g_ret_sts_error; if there is an unexpected error, the value is fnd_api.g_ret_sts_unexp_error;
* @ paraminfo {@rep:required}
* @ param x_msg_count if there is one or more errors, the number of error messages in the buffer
* @ paraminfo {@rep:required}
* @ param x_msg_data if there is one and only one error, the error message
* @ paraminfo {@rep:required}
* @ param x_lpn_id The LPN ID for the new LPN record entry
* @ paraminfo {@rep:required}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Create License Plate Numbers
* @rep:businessevent Create_LPN
*/
PROCEDURE Create_LPN (
  p_api_version            IN         NUMBER
, p_init_msg_list          IN         VARCHAR2 := fnd_api.g_false
, p_commit                 IN         VARCHAR2 := fnd_api.g_false
, p_validation_level       IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
, p_lpn                    IN         VARCHAR2
, p_organization_id        IN         NUMBER
, p_container_item_id      IN         NUMBER   := NULL
, p_lot_number             IN         VARCHAR2 := NULL
, p_revision               IN         VARCHAR2 := NULL
, p_serial_number          IN         VARCHAR2 := NULL
, p_subinventory           IN         VARCHAR2 := NULL
, p_locator_id             IN         NUMBER   := NULL
, p_source                 IN         NUMBER   := LPN_CONTEXT_PREGENERATED
, p_cost_group_id          IN         NUMBER   := NULL
, p_parent_lpn_id          IN         NUMBER   := NULL
, p_source_type_id         IN         NUMBER   := NULL
, p_source_header_id       IN         NUMBER   := NULL
, p_source_name            IN         VARCHAR2 := NULL
, p_source_line_id         IN         NUMBER   := NULL
, p_source_line_detail_id  IN         NUMBER   := NULL
, x_lpn_id                 OUT NOCOPY NUMBER
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
--   p_lpn              WMS_LICENSE_PLATE_NUMBERS%ROWTYPE - Required Value
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

PROCEDURE Modify_LPN
(  p_api_version            IN      NUMBER                          ,
   p_init_msg_list          IN      VARCHAR2 := fnd_api.g_false     ,
   p_commit                 IN      VARCHAR2 := fnd_api.g_false     ,
   p_validation_level       IN      NUMBER   := fnd_api.g_valid_level_full  ,
   x_return_status          OUT     NOCOPY VARCHAR2                        ,
   x_msg_count              OUT     NOCOPY NUMBER                          ,
   x_msg_data               OUT     NOCOPY VARCHAR2                        ,
   p_lpn                    IN      LPN                             ,
   p_source_type_id         IN      NUMBER   := NULL                ,
   p_source_header_id       IN      NUMBER   := NULL                ,
   p_source_name            IN      VARCHAR2 := NULL                ,
   p_source_line_id         IN      NUMBER   := NULL                ,
   p_source_line_detail_id  IN      NUMBER   := NULL
);

/***********************************************************************/
/* WARNING Starting with patch set 11i.X This API will become obsolete */
/* Patch set J is the last patch set in which this API will exist in   */
/* this package all references will need to be removed by X            */
/***********************************************************************/

PROCEDURE Modify_LPN_Wrapper
(  p_api_version            IN      NUMBER                             ,
   p_init_msg_list          IN      VARCHAR2 := fnd_api.g_false        ,
   p_commit                 IN      VARCHAR2 := fnd_api.g_false        ,
   p_validation_level       IN      NUMBER   := fnd_api.g_valid_level_full  ,
   x_return_status          OUT     NOCOPY VARCHAR2                           ,
   x_msg_count              OUT     NOCOPY NUMBER                             ,
   x_msg_data               OUT     NOCOPY VARCHAR2                           ,
   p_lpn_id                 IN      NUMBER                             ,
   p_license_plate_number   IN      VARCHAR2 := NULL                   ,
   p_inventory_item_id      IN      NUMBER   := NULL                   ,
   p_weight_uom_code        IN      VARCHAR2 := NULL                   ,
   p_gross_weight           IN      NUMBER   := NULL                   ,
   p_volume_uom_code        IN      VARCHAR2 := NULL                   ,
   p_content_volume         IN      NUMBER   := NULL                   ,
   p_status_id              IN      NUMBER   := NULL                   ,
   p_lpn_context            IN      NUMBER   := NULL                   ,
   p_sealed_status          IN      NUMBER   := NULL                   ,
   p_organization_id        IN      NUMBER   := NULL                   ,
   p_subinventory           IN      VARCHAR  := NULL                   ,
   p_locator_id             IN      NUMBER   := NULL                   ,
   p_source_type_id         IN      NUMBER   := NULL                   ,
   p_source_header_id       IN      NUMBER   := NULL                   ,
   p_source_name            IN      VARCHAR2 := NULL                   ,
   p_source_line_id         IN      NUMBER   := NULL                   ,
   p_source_line_detail_id  IN      NUMBER   := NULL
  );

/*---------------------------------------------------------------------*/
-- Name
--   PROCEDURE PackUnpack_Container
/*---------------------------------------------------------------------*/
-- Purpose
--     Allows the caller to pack or unpack contents from a container instance or LPN.
--               This API does not update onhand, so should not be used directly for packing
--               items in inventory.  For inventory packs the transaction manager should be used.
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
--                whether or not to commit the changes to database
--   p_validation_level         (optional), determines if full validation or
--                              no validation will be performed
--                              defaults to FND_API.G_VALID_LEVEL_FULL
--                              FND_API.G_VALID_LEVEL_NONE is the other value
--   p_lpn_id                   Parent License Plate Number Identifier - Required Value
--   p_content_lpn_id           Content LPN ID
--   p_content_item_id          Content Item ID          - Defaults to NULL
--   p_content_item_desc        Content Item Description - Defaults to NULL
--   p_revision                 Revision                 - Defaults to NULL
--   p_lot_number               Lot Number               - Defaults to NULL
--   p_from_serial_number       Starting Serial Number   - Defaults to NULL
--   p_to_serial_number         Ending Serial Number     - Defaults to NULL
--   p_quantity                 Content Quantity         - Defaults to NULL
--                                This value is not required if you are
--                                packing or unpacking an LPN or if you are
--                                packing or unpacking serialized items
--   p_uom                      Content Qty UOM          - Defaults to NULL
--   p_organization_id          Organization ID          - Required Value
--   p_subinventory             Subinventory             - Defaults to NULL
--                              Value is the source subinventory if pack,
--                              destination subinventory if unpack operation
--   p_locator_id               Locator Id               - Defaults to NULL
--                              Value is the source locator if pack,
--                              destination locator if unpack operation
--   p_enforce_wv_constraints   Weight and Volume Enforcement Flag
--                                  Defaults to 2 (= No), 1 = Yes
--
--   p_operation                Type of opertaion, Pack/Unpack      - Required Value
--                                  1 = Pack, 2 = Unpack
--   p_cost_group_id            Cost Group Id - Defaults to NULL
--   p_source_type_id           Source type ID for the source transaction
--   p_source_header_id         Source header ID for the source transaction
--   p_source_name              Source name for the source transaction
--   p_source_line_id           Source line ID for the source transaction
--   p_source_line_detail_id    Source line detail ID for the source transaction
--   p_homogeneous_container    Parameter signifying if different mixed
--                              items can be packed in the same container
--                                  1 = Yes, 2 = No   Defaults to 2 = No
--   p_match_locations          Parameter signifying if all of the items
--                              should be in the same location when packing
--                                  1 = Yes, 2 = No   Defaults to 2 = No
--   p_match_lpn_context        Parameter signifying if all of the LPNs
--                              should have the same LPN context when packing
--                                  1 = Yes, 2 = No   Defaults to 2 = No
--   p_match_lot                Parameter signifying if all of the items
--                              should have the same lot number when packing
--                                  1 = Yes, 2 = No   Defaults to 2 = No
--   p_match_cost_groups        Parameter signifying if all of the items
--                              should have the same cost group when packing
--                                  1 = Yes, 2 = No   Defaults to 2 = No
--   p_match_mtl_status         Parameter signifying if all of the items
--                              should have the same material status when packing
--                                  1 = Yes, 2 = No   Defaults to 2 = No
--   p_unpack_all               Parameter signifying if all of the contents
--                              in the LPN should be unpacked
--                                  1 = Yes, 2 = No   Defaults to 2 = No
--   p_trx_action_id            transaction header ID for the transaction
--        p_concurrent_pack     flag to indicate if a autonomous commit should be done
--                                                              for updating weight and volume of lpn.  This allows for
--                                                              multiple users to pack/unpack the same lpn at the same time
--                                                                              0 = non autonomous (default) 1 = autonomous
--
-- Output Parameters
--   x_return_status
--       if the PackUnpack_Container API succeeds, the value is
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
/***********************************************************************/
/* WARNING Starting with patch set 11i.X This API will become obsolete */
/* Patch set J is the last patch set in which this API will exist in   */
/* this package all references will need to be removed by X            */
/***********************************************************************/

  PROCEDURE PackUnpack_Container (
    p_api_version              IN         NUMBER
  , p_init_msg_list            IN         VARCHAR2 := fnd_api.g_false
  , p_commit                   IN         VARCHAR2 := fnd_api.g_false
  , p_validation_level         IN         NUMBER   := fnd_api.g_valid_level_full
  , x_return_status            OUT NOCOPY VARCHAR2
  , x_msg_count                OUT NOCOPY NUMBER
  , x_msg_data                 OUT NOCOPY VARCHAR2
  , p_lpn_id                   IN         NUMBER
  , p_content_lpn_id           IN         NUMBER   := NULL
  , p_content_item_id          IN         NUMBER   := NULL
  , p_content_item_desc        IN         VARCHAR2 := NULL
  , p_revision                 IN         VARCHAR2 := NULL
  , p_lot_number               IN         VARCHAR2 := NULL
  , p_from_serial_number       IN         VARCHAR2 := NULL
  , p_to_serial_number         IN         VARCHAR2 := NULL
  , p_quantity                 IN         NUMBER   := 1
  , p_uom                      IN         VARCHAR2 := NULL
  , p_sec_quantity             IN         NUMBER   := NULL --INVCONV kkillams
  , p_sec_uom                  IN         VARCHAR2 := NULL --INVCONV kkillams
  , p_organization_id          IN         NUMBER
  , p_subinventory             IN         VARCHAR2 := NULL
  , p_locator_id               IN         NUMBER   := NULL
  , p_enforce_wv_constraints   IN         NUMBER   := 2
  , p_operation                IN         NUMBER
  , p_cost_group_id            IN         NUMBER   := NULL
  , p_source_type_id           IN         NUMBER   := NULL
  , p_source_header_id         IN         NUMBER   := NULL
  , p_source_name              IN         VARCHAR2 := NULL
  , p_source_line_id           IN         NUMBER   := NULL
  , p_source_line_detail_id    IN         NUMBER   := NULL
  , p_homogeneous_container    IN         NUMBER   := 2
  , p_match_locations          IN         NUMBER   := 2
  , p_match_lpn_context        IN         NUMBER   := 2
  , p_match_lot                IN         NUMBER   := 2
  , p_match_cost_groups        IN         NUMBER   := 2
  , p_match_mtl_status         IN         NUMBER   := 2
  , p_unpack_all               IN         NUMBER   := 2
  , p_trx_action_id            IN         NUMBER   := NULL
  , p_concurrent_pack          IN         NUMBER   := 0
  , p_ignore_item_controls     IN         NUMBER   := 2
);

/***********************************************************************/
/* WARNING Starting with patch set 11i.X This API will become obsolete */
/* Patch set J is the last patch set in which this API will exist in   */
/* this package all references will need to be removed by X            */
/***********************************************************************/

PROCEDURE pack_prepack_container
  (  p_api_version            IN      NUMBER                        ,
     p_init_msg_list          IN      VARCHAR2 := fnd_api.g_false   ,
     p_commit                 IN      VARCHAR2 := fnd_api.g_false   ,
     p_validation_level       IN      NUMBER   := fnd_api.g_valid_level_full  ,
     x_return_status          OUT     NOCOPY VARCHAR2                      ,
     x_msg_count              OUT     NOCOPY NUMBER                        ,
     x_msg_data               OUT     NOCOPY VARCHAR2                      ,
     p_lpn_id                 IN      NUMBER                        ,
     p_content_item_id        IN      NUMBER   := NULL              ,
     p_revision               IN      VARCHAR2 := NULL              ,
     p_lot_number             IN      VARCHAR2 := NULL              ,
     p_from_serial_number     IN      VARCHAR2 := NULL              ,
     p_to_serial_number       IN      VARCHAR2 := NULL              ,
     p_quantity               IN      NUMBER   := 1                 ,
     p_uom                    IN      VARCHAR2 := NULL              ,
     p_organization_id        IN      NUMBER                        ,
     p_operation              IN      NUMBER                        ,
     p_source_type_id         IN      NUMBER   := NULL
  );


/*---------------------------------------------------------------------*/
-- Name
--   PROCEDURE Explode_LPN
/*---------------------------------------------------------------------*/
-- Purpose
--    API returns a PL/SQL table of a containers contents.
--    User will pass in the LPN of
--    the container to be exploded and the level to explode to.
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
--   p_lpn_id                 License Plate Number Identifier - Required Value
--   p_explosion_level        Explosion Level - Defaults to 0 (Explode to all levels)
--
--
-- Output Parameters
--   x_return_status
--       if the Explode_LPN API succeeds, the value is
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

-- This is the contents of exploded table type
/***********************************************************************/
/* WARNING Starting with patch set 11i.X This API will become obsolete */
/* Patch set J is the last patch set in which this API will exist in   */
/* this package all references will need to be removed by X            */
/***********************************************************************/

TYPE WMS_Container_Content_Rec_Type is RECORD
(  parent_lpn_id        NUMBER          ,
   content_lpn_id       NUMBER          ,
   content_item_id      NUMBER          ,
   content_description  VARCHAR2(240)   ,
   content_type         VARCHAR2(1)     ,
   organization_id      NUMBER          ,
   revision             VARCHAR2(3)     ,
   lot_number           VARCHAR2(80)    , -- nsinghi bug#5764384. Changed size from 30 to 80
   serial_number        VARCHAR2(30)    ,
   quantity             NUMBER          ,
   sec_quantity         NUMBER          , --INVCONV kkillams
   uom                  VARCHAR2(3)     ,
   sec_uom              VARCHAR2(3)     , --INVCONV kkillams
   cost_group_id        NUMBER
);

TYPE WMS_Container_Tbl_Type is TABLE OF WMS_Container_Content_Rec_Type
INDEX BY BINARY_INTEGER;

PROCEDURE Explode_LPN
(  p_api_version        IN      NUMBER                         ,
   p_init_msg_list      IN      VARCHAR2 := fnd_api.g_false    ,
   p_commit             IN      VARCHAR2 := fnd_api.g_false    ,
   x_return_status      OUT     NOCOPY VARCHAR2                       ,
   x_msg_count          OUT     NOCOPY NUMBER                         ,
   x_msg_data           OUT     NOCOPY VARCHAR2                       ,
   p_lpn_id             IN      NUMBER                         ,
   p_explosion_level    IN      NUMBER   := 0                  ,
   x_content_tbl        OUT     NOCOPY WMS_Container_Tbl_Type
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

/*-- Constant Return Values for Validation APIs */
T CONSTANT NUMBER := 1;
F CONSTANT NUMBER := 0;

FUNCTION Validate_LPN(
  p_lpn IN OUT nocopy LPN
, p_lock IN NUMBER := 2 )
RETURN NUMBER;


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
--   p_source_item_id           Source Item id (can also be a container Item) - Required Value
--   p_source_qty               Source Item Qty        - Required Value
--   p_source_qty_uom           UOM of Source Item Qty - Required Value
--   p_qty_per_container        Qty per each container - Defaults to NULL
--   p_qty_per_container_uom    UOM of Qty per each container - Defaults to NULL
--   p_organization_id          Organization Id - Defaults to NULL
--   p_dest_cont_item_id        Destination container item id - IN OUT parameter
--
--
-- Output Parameters
--   x_return_status
--       if the Container_Required_Qty API succeeds, the value is
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
--   p_dest_cont_item_id        Destination container item id - IN OUT parameter
--   p_qty_required             Required Container Quantity
/***********************************************************************/
/* WARNING Starting with patch set 11i.X This API will become obsolete */
/* Patch set J is the last patch set in which this API will exist in   */
/* this package all references will need to be removed by X            */
/***********************************************************************/

PROCEDURE Container_Required_Qty
(  p_api_version           IN     NUMBER                          ,
   p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false     ,
   p_commit                IN     VARCHAR2 := fnd_api.g_false     ,
   x_return_status         OUT    NOCOPY VARCHAR2                        ,
   x_msg_count             OUT    NOCOPY NUMBER                          ,
   x_msg_data              OUT    NOCOPY VARCHAR2                        ,
   p_source_item_id        IN     NUMBER                          ,
   p_source_qty            IN     NUMBER                          ,
   p_source_qty_uom        IN     VARCHAR2                        ,
   p_qty_per_cont          IN     NUMBER   := NULL                ,
   p_qty_per_cont_uom      IN     VARCHAR2 := NULL                ,
   p_organization_id       IN     NUMBER                          ,
   p_dest_cont_item_id     IN OUT NOCOPY NUMBER                          ,
   p_qty_required          OUT    NOCOPY NUMBER
);

TYPE LPN_Table_Type IS TABLE OF WMS_LICENSE_PLATE_NUMBERS%ROWTYPE
  INDEX BY BINARY_INTEGER;


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
--   p_subinventory             Subinventory - Defaults to NULL
--   p_locator_id               Locator Id - Defaults to NULL
--   p_inventory_item_id        Inventory ID number              - Required
--   p_revision                 Revision of the inventory item
--   p_lot_number               Lot number of the inventory item
--   p_quantity                 Quantity of item to be prepacked - Required
--   p_uom                      UOM of the quantity prepacked    - Required
--   p_source                   Source of information (WIP/REC)
--   p_serial_number_from       Starting serial number for inventory item
--   p_serial_number_to         Ending serial number for inventory item
--   p_container_item_id        Inventory item ID for a container item
--   p_cont_revision            Revision of the container item
--   p_cont_lot_number          Lot Number of the container item
--   p_cont_serial_number_from  From serial number of the container item
--   p_cont_serial_number_to    To serial number of the container item
--   p_lpn_sealed_flag          Flag to tell if LPN should be sealed or not
--   p_print_label              Should labels be printed afterwards
--   p_print_content_report     Should content reports be generated afterwards
--
--
-- Output Parameters
--   ERRBUF                     Concurrent program error buffer
--   RETCODE                    Concurrent program return code
--   x_return_status
--       if the Prepack_LPN API succeeds, the value is
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
/***********************************************************************/
/* WARNING Starting with patch set 11i.X This API will become obsolete */
/* Patch set J is the last patch set in which this API will exist in   */
/* this package all references will need to be removed by X            */
/***********************************************************************/

PROCEDURE Prepack_LPN_CP
(  ERRBUF                     OUT     NOCOPY VARCHAR2                           ,
   RETCODE                    OUT     NOCOPY NUMBER                             ,
   p_api_version              IN      NUMBER                            ,
   p_organization_id          IN      NUMBER                           ,
   p_subinventory             IN      VARCHAR2 := NULL                 ,
   p_locator_id               IN      NUMBER   := NULL                 ,
   p_inventory_item_id        IN      NUMBER                           ,
   p_revision                 IN      VARCHAR2 := NULL                 ,
   p_lot_number               IN      VARCHAR2 := NULL                 ,
   p_quantity                 IN      NUMBER                           ,
   p_uom                      IN      VARCHAR2                         ,
   p_source                   IN      NUMBER                           ,
   p_serial_number_from       IN      VARCHAR2 := NULL                 ,
   p_serial_number_to         IN      VARCHAR2 := NULL                 ,
   p_container_item_id        IN      NUMBER   := NULL                 ,
   p_cont_revision            IN      VARCHAR2 := NULL                 ,
   p_cont_lot_number          IN      VARCHAR2 := NULL                 ,
   p_cont_serial_number_from  IN      VARCHAR2 := NULL                 ,
   p_cont_serial_number_to    IN      VARCHAR2 := NULL                 ,
   p_lpn_sealed_flag          IN      NUMBER   := fnd_api.g_miss_num   ,
   p_print_label              IN      NUMBER   := fnd_api.g_miss_num   ,
   p_print_content_report     IN      NUMBER   := fnd_api.g_miss_num
);

TYPE Transaction_History IS TABLE OF WMS_LPN_HISTORIES.lpn_history_id%TYPE
  INDEX BY BINARY_INTEGER;

/*---------------------------------------------------------------------*/
-- Name
--   PROCEDURE lpn_pack_complete
/*---------------------------------------------------------------------*/
-- Purpose
--   commit or revert changes made by autonomous pack/unpack
--
-- Input Parameters
--   p_revert        The process ID for the prepack transaction
--                                                      0 = complete 1 = revert changes
--
-- Output Parameters
--   None
--
/***********************************************************************/
/* WARNING Starting with patch set 11i.X This API will become obsolete */
/* Patch set J is the last patch set in which this API will exist in   */
/* this package all references will need to be removed by X            */
/***********************************************************************/

FUNCTION lpn_pack_complete( p_revert NUMBER := 0 )RETURN BOOLEAN;

-- Start of comments
--  API name: Merge_Up_LPN
--  Type    : Public
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
--  Type    : Public
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
--  Type    : Public
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

 -- For LPN reuse ER : 6845650
PROCEDURE REUSE_LPNS (
                 p_api_version              IN         NUMBER
               , p_init_msg_list            IN         VARCHAR2 := fnd_api.g_false
               , p_commit                   IN         VARCHAR2 := fnd_api.g_false
               , p_validation_level         IN         NUMBER   := fnd_api.g_valid_level_full
               , x_return_status            OUT NOCOPY VARCHAR2
               , x_msg_count                OUT NOCOPY NUMBER
               , x_msg_data                 OUT NOCOPY VARCHAR2
               , p_lpn_id                   IN         NUMBER
               , p_clear_attributes         IN         VARCHAR2
               , p_new_org_id               IN         NUMBER
               , p_unpack_inner_lpns        IN         VARCHAR2
               , p_clear_containter_item_id IN         VARCHAR2
               );

END WMS_CONTAINER_PUB;

/
