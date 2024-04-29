--------------------------------------------------------
--  DDL for Package AHL_OSP_SHIPMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_OSP_SHIPMENT_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPOSHS.pls 120.3 2008/02/05 16:07:36 mpothuku ship $ */
/*#
 * This package Contains Record types and public procedures to process shipment headers, and lines that are related to OSP Orders.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Process OSP Shipment
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_OSP_ORDER
 */
--Added by mpothuku on 09-Jul-2007 to fix the OGMA Part Number Change ER
------------------------------------------------------------------------------------
-- Define Record Types for record structures needed for the Serial Number Change API --
------------------------------------------------------------------------------------

TYPE Sernum_Change_Rec_Type IS RECORD (
          ITEM_NUMBER               VARCHAR2(40)     ,
          NEW_ITEM_NUMBER           VARCHAR2(40)     ,
          NEW_LOT_NUMBER            VARCHAR2(30)     ,
          NEW_ITEM_REV_NUMBER       VARCHAR2(3)      ,
          OSP_LINE_ID               NUMBER           ,
          INSTANCE_ID               NUMBER           ,
          CURRENT_SERIAL_NUMBER     VARCHAR2(30)     ,
          CURRENT_SERAIL_TAG        VARCHAR2(80)     ,
          NEW_SERIAL_NUMBER         VARCHAR2(30)     ,
          NEW_SERIAL_TAG_CODE       VARCHAR2(30)     ,
          NEW_SERIAL_TAG_MEAN       VARCHAR2(80)
          );
--mpothuku End

----------------------------------------------
-- Define Table Type for records structures --
----------------------------------------------
TYPE Sernum_Change_Tbl_Type IS TABLE OF Sernum_Change_Rec_Type INDEX BY BINARY_INTEGER;

---------------------------------
-- Define Record Type for Node --
---------------------------------

TYPE Ship_Header_Rec_Type IS RECORD
(   header_id                     NUMBER
,   order_number                  NUMBER
,   booked_flag                   VARCHAR2(1)
,   cancelled_flag                VARCHAR2(1)
,   open_flag                     VARCHAR2(1)
,   price_list                    VARCHAR2(240)
,   price_list_id                 NUMBER
,   ship_from_org                 VARCHAR2(240)
,   ship_from_org_id              NUMBER
,   ship_to_contact               VARCHAR2(240)
,   ship_to_contact_id            NUMBER
,   ship_to_org	                  VARCHAR2(240)
,   ship_to_org_id                NUMBER
,   sold_to_custom_number         VARCHAR2(50)
,   sold_to_org_id                NUMBER
,   fob_point                	  VARCHAR2(240)
,   fob_point_code                VARCHAR2(30)
,   freight_carrier          	  VARCHAR2(240)
,   freight_carrier_code          VARCHAR2(30)
,   freight_terms            	  VARCHAR2(240)
,   freight_terms_code            VARCHAR2(30)
,   shipment_priority_code        VARCHAR2(30)
,   shipment_priority             VARCHAR2(240)
,   shipping_method_code          VARCHAR2(30)
,   shipping_method               VARCHAR2(240)
,   osp_order_id                  NUMBER
,   osp_order_number		  VARCHAR2(50)
,   payment_term_id               NUMBER
,   payment_term     		  VARCHAR2(240)
,   tax_exempt_flag               VARCHAR2(30)
,   tax_exempt_number             VARCHAR2(80)
,   tax_exempt_reason_code        VARCHAR2(30)
,   tax_exempt_reason             VARCHAR2(240)
,   shipping_instructions	  VARCHAR2(2000)
,   packing_instructions          VARCHAR2(2000)
,   operation                     VARCHAR2(30)
);

--  Line record type

TYPE Ship_Line_Rec_Type IS RECORD
(   line_id                       NUMBER
,   line_number                   NUMBER
,   header_id                     NUMBER
,   order_type                    VARCHAR2(240)
,   line_type_id                  NUMBER
,   line_type                     VARCHAR2(240)
,   job_number                    VARCHAR2(30)
,   project_id                    NUMBER
,   project                       VARCHAR2(240)
,   task_id                       NUMBER
,   task                          VARCHAR2(240)
,   operation                     VARCHAR2(30)
,   inventory_item_id             NUMBER
,   inventory_org_id              NUMBER
,   inventory_item                VARCHAR2(240)
,   LOT_NUMBER                    mtl_lot_numbers.lot_number%TYPE
,   INVENTORY_ITEM_UOM            VARCHAR2(3)
,   INVENTORY_ITEM_QUANTITY       NUMBER
,   serial_number                 VARCHAR2(30)
,   csi_item_instance_id          NUMBER
,   ordered_quantity              NUMBER
,   order_quantity_uom            VARCHAR2(3)
,   return_reason_code		  VARCHAR2(30)
,   return_reason                 VARCHAR2(240)
,   schedule_ship_date            DATE
,   packing_instructions          VARCHAR2(2000)
,   ship_from_org                 VARCHAR2(240)
,   ship_from_org_id              NUMBER
,   fob_point                	  VARCHAR2(240)
,   fob_point_code                VARCHAR2(30)
,   freight_carrier          	  VARCHAR2(240)
,   freight_carrier_code          VARCHAR2(30)
,   freight_terms            	  VARCHAR2(240)
,   freight_terms_code            VARCHAR2(30)
,   shipment_priority_code        VARCHAR2(30)
,   shipment_priority             VARCHAR2(240)
,   shipping_method_code          VARCHAR2(30)
,   shipping_method               VARCHAR2(240)
,   subinventory                  VARCHAR2(10)
,   osp_order_id                  NUMBER
,   osp_order_number		  VARCHAR2(50)
,   osp_line_id                   NUMBER
,   osp_line_number		  VARCHAR2(50)
,   instance_id                   NUMBER
,   osp_line_flag                 VARCHAR2(30) -- Possible values Y or N used to check if this line
-- corresponds to a line in OSP order.
);

TYPE Ship_Line_Tbl_Type IS TABLE OF Ship_Line_Rec_Type
    INDEX BY BINARY_INTEGER;

TYPE Ship_ID_Tbl_Type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : Process_Order
--  Type              : Public
--  Function          : For one Shipment Header and a set of Shipment
-- Lines, call 1) SO API 2) Update IB with IB trxns.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Default  1.0
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT NOCOPY     VARCHAR2             Required
--      x_msg_count                     OUT NOCOPY     NUMBER               Required
--      x_msg_data                      OUT NOCOPY     VARCHAR2             Required
--
--  Process Order Parameters:
--       p_x_Header_rec          IN OUT NOCOPY  Ship_Header_rec_type    Required
--         All parameters for SO Shipment Header
--       p_x_Lines_tbl        IN OUT NOCOPY  ship_line_tbl_type   Required
--         List of all parameters for shipment lines
--
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.
/*#
 * This procedure is used to process a Shipment order related to an OSP Order.
 * @param p_api_version API Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction or not, default value FND_API.G_FALSE
 * @param p_validation_level validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_module_type Module type of the caller
 * @param p_x_header_rec Contains the attributes of the Shipment header, of type AHL_OSP_SHIPMENT_PUB.Ship_Header_Rec_Type
 * @param p_x_lines_tbl Table of Shipment line records, of type AHL_OSP_SHIPMENT_PUB.Ship_Line_Tbl_Type
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Shipment Order
 */
PROCEDURE Process_Order (
    p_api_version           IN        NUMBER    := 1.0,
    p_init_msg_list         IN        VARCHAR2  := FND_API.G_TRUE,
    p_commit                IN        VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN        NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN        VARCHAR2  := NULL,
    p_x_header_rec         IN OUT NOCOPY   AHL_OSP_SHIPMENT_PUB.Ship_Header_Rec_Type,
    p_x_lines_tbl 	   IN OUT NOCOPY   AHL_OSP_SHIPMENT_PUB.Ship_Line_Tbl_Type,
    x_return_status         OUT NOCOPY           VARCHAR2,
    x_msg_count             OUT NOCOPY           NUMBER,
    x_msg_data              OUT NOCOPY           VARCHAR2);


-------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : Book_Order
--  Type              : Public
--  Function          : For one Shipment Header, book the order
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Default  1.0
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT NOCOPY     VARCHAR2             Required
--      x_msg_count                     OUT NOCOPY     NUMBER               Required
--      x_msg_data                      OUT NOCOPY     VARCHAR2             Required
--
--  Delete_Cancel_Order Parameters:
--       p_oe_header_tbl          IN NUMBER
--         The table of header_id for the Shipment Header
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.
/*#
 * This procedure is used to book one or more shipment orders.
 * @param p_api_version API Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction or not, default value FND_API.G_FALSE
 * @param p_validation_level validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_oe_header_tbl Contains the ids of the shipment headers
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Book Shipment Orders
 */
PROCEDURE Book_Order (
    p_api_version           IN        NUMBER    := 1.0,
    p_init_msg_list         IN        VARCHAR2  := FND_API.G_TRUE,
    p_commit                IN        VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN        NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_oe_header_tbl          IN        Ship_ID_Tbl_Type,
    x_return_status         OUT NOCOPY           VARCHAR2,
    x_msg_count             OUT NOCOPY           NUMBER,
    x_msg_data              OUT NOCOPY           VARCHAR2);

-------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : Delete_Cancel_Order
--  Type              : Public
--  Function          : For one Shipment Header and a set of Shipment
-- Lines, Cancel if booked, delete if possible
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Default  1.0
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT NOCOPY     VARCHAR2             Required
--      x_msg_count                     OUT NOCOPY     NUMBER               Required
--      x_msg_data                      OUT NOCOPY     VARCHAR2             Required
--
--  Delete_Cancel_Order Parameters:
--       p_oe_header_id          IN NUMBER
--         The header_id for the Shipment Header
--       p_oe_lines_tbl        IN   ship_id_tbl_type
--         All shipment line ids for delete or cancel
--       p_cancel_flag         IN VARCHAR2
--         If true, only do cancels, no deletes.
--
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.
/*#
 * This procedure is used to Delete or Cancel Shipment Order and lines
 * @param p_api_version API Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction or not, default value FND_API.G_FALSE
 * @param p_validation_level validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_oe_header_id The id of the shipment header
 * @param p_oe_lines_tbl Contains shipment line ids for delete or cancel
 * @param p_cancel_flag If true, Cancels otherwise Deletes
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete or Cancel Shipment Order
 */
PROCEDURE Delete_Cancel_Order (
    p_api_version           IN        NUMBER    := 1.0,
    p_init_msg_list         IN        VARCHAR2  := FND_API.G_TRUE,
    p_commit                IN        VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN        NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_oe_header_id          IN        NUMBER,
    p_oe_lines_tbl 	    IN        SHIP_ID_TBL_TYPE,
    p_cancel_flag           IN        VARCHAR2  := FND_API.G_FALSE,
    x_return_status         OUT NOCOPY           VARCHAR2,
    x_msg_count             OUT NOCOPY            NUMBER,
    x_msg_data              OUT NOCOPY            VARCHAR2);


---------------------------------------------------------------------
-- FUNCTION
--    Is_Order_Header_Closed
--
-- PURPOSE
--    This function checks if the shipment header is closed.
--
-- NOTES
--    1. It will return FND_API.g_true/g_false.
--    2. Exception encountered will be raised to the caller.
---------------------------------------------------------------------
FUNCTION Is_Order_Header_Closed(
   p_oe_header_id IN NUMBER
)
RETURN VARCHAR2;  -- FND_API.g_true/g_false

-------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : Convert_SubTxn_Type
--  Type              : Public
--  Function          : API to delete OSP shipment return lines and change IB transaction
--                      sub types for ship-only lines while converting an OSP Order from
--                      Exchange to Service type or vice versa.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Default  1.0
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--  Standard OUT Parameters :
--      x_return_status                 OUT NOCOPY     VARCHAR2             Required
--      x_msg_count                     OUT NOCOPY     NUMBER               Required
--      x_msg_data                      OUT NOCOPY     VARCHAR2             Required
--
--  Convert_SubTxn_Type Parameters:
--       p_osp_order_id          IN NUMBER
--         The header_id for the OSP Order that is going through a type change
--       p_old_order_type_code   IN VARCHAR2(30)
--         The old type of the OSP Order. Can be SERVICE or EXCHANGE only
--       p_new_order_type_code   IN VARCHAR2(30)
--         The new type of the OSP Order. Can be EXCHANGE or SERVICE only.
--
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.

PROCEDURE Convert_SubTxn_Type (
    p_api_version           IN        NUMBER    := 1.0,
    p_init_msg_list         IN        VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN        VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN        NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_default               IN        VARCHAR2  := FND_API.G_TRUE,
    p_module_type           IN        VARCHAR2  := NULL,
    p_osp_order_id          IN        NUMBER,
    p_old_order_type_code   IN        VARCHAR2,
    p_new_order_type_code   IN        VARCHAR2,
    x_return_status         OUT NOCOPY           VARCHAR2,
    x_msg_count             OUT NOCOPY           NUMBER,
    x_msg_data              OUT NOCOPY           VARCHAR2);


PROCEDURE Handle_Vendor_Change (
    p_api_version           IN        NUMBER    := 1.0,
    p_init_msg_list         IN        VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN        VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN        NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_default               IN        VARCHAR2  := FND_API.G_TRUE,
    p_module_type           IN        VARCHAR2  := NULL,
    p_osp_order_id          IN        NUMBER,
    p_vendor_id             IN        NUMBER,
    p_vendor_loc_id         IN        NUMBER,
    x_return_status         OUT NOCOPY           VARCHAR2,
    x_msg_count             OUT NOCOPY           NUMBER,
    x_msg_data              OUT NOCOPY           VARCHAR2);

--Added by mpothuku on 01-Jun-2007 to support the part number and serial number change for osp lines
----------------------------------------------------------------------------------------------------
-- FUNCTION
--    Is_part_chg_valid_for_ospline
--
-- PURPOSE
--    This function checks that the osp line is valid for part number/serial number change.
--
-- NOTES
--    It returns 'N' if
--       1. There is no ship line for the osp line
--       2. Item is not IB tracked
--       3. Line status is PO Deleted/PO Cancelled/Req Deleted/Req Cancelled
--       4. Item is not shipped
--       5. Item has already been received
--       6. Part Number change has already been formed for the osp line.
--    Otherwise it will return 'Y'
-----------------------------------------------------------------------------------------------------

FUNCTION Is_part_chg_valid_for_ospline(p_osp_order_line_id IN NUMBER)
RETURN VARCHAR2;

-------------------------------------------------------------
-- Start of Comments --
--  Procedure name    :
--  Type              : Public
--  Function          : API to delete or cancel OSP shipment return lines and/or the IB installation
--                      details before the part number/serial number change is performed from production
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Default  1.0
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--  Standard OUT Parameters :
--      x_return_status                 OUT NOCOPY     VARCHAR2             Required
--      x_msg_count                     OUT NOCOPY     NUMBER               Required
--      x_msg_data                      OUT NOCOPY     VARCHAR2             Required
--
--  Process_Osp_SerialNum_Change Parameters:
--       p_osp_order_line_id          IN NUMBER
--         The osp_line_id for of OSP Order for which the part number/serial number change
--       p_inv_item_id                IN NUMBER
--         The inv_item_id chosen by the user to replace the existint item.
--       p_serial_number              IN VARCHAR2
--         The serial_number chosen by the user to replace the existint serial.
--
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.

PROCEDURE Process_Osp_SerialNum_Change(
    p_api_version           IN        NUMBER    := 1.0,
    p_init_msg_list         IN        VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN        VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN        NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN        VARCHAR2  := NULL,
    p_serialnum_change_rec  IN        Sernum_Change_Rec_Type,
    x_return_status         OUT NOCOPY           VARCHAR2,
    x_msg_count             OUT NOCOPY           NUMBER,
    x_msg_data              OUT NOCOPY           VARCHAR2
    );

--Added by mpothuku on 05-Feb-2007 to implement the Osp Receiving ER
-------------------------------------------------------------
-- Start of Comments --
--  Procedure name    :
--  Type              : Public
--  Function          : Create IB Sub transaction for a order line based on osp_order_type and
--                      line type.
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Default  1.0
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--  Standard OUT Parameters :
--      x_return_status                 OUT NOCOPY     VARCHAR2             Required
--      x_msg_count                     OUT NOCOPY     NUMBER               Required
--      x_msg_data                      OUT NOCOPY     VARCHAR2             Required
--
--  Create_IB_Transaction Parameters:
--       p_OSP_order_type          IN VARCHAR2
--         The osp order type to create the transaction as per the profile setup.
--       p_oe_line_type            IN VARCHAR2
--         The shipment line type
--       p_oe_line_id              IN NUMBER
--         The shipment line id corresponding to which the transaction is to be created.
--       p_csi_instance_id         IN NUMBER
--          The instance id corresponding to which the transaction is to be created.
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.
PROCEDURE Create_IB_Transaction(
    p_init_msg_list          IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level       IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status          OUT NOCOPY            VARCHAR2,
    x_msg_count              OUT NOCOPY            NUMBER,
    x_msg_data               OUT NOCOPY            VARCHAR2,
    p_OSP_order_type         IN            VARCHAR2,
    p_oe_line_type           IN            VARCHAR2,
    p_oe_line_id             IN            NUMBER,
    p_csi_instance_id        IN            NUMBER);

-------------------------------------------------------------
-- Start of Comments --
--  Procedure name    :
--  Type              : Public
--  Function          : Delete IB sub transaction for a shipment line.
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Default  1.0
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--  Standard OUT Parameters :
--      x_return_status                 OUT NOCOPY     VARCHAR2             Required
--      x_msg_count                     OUT NOCOPY     NUMBER               Required
--      x_msg_data                      OUT NOCOPY     VARCHAR2             Required
--
--  Create_IB_Transaction Parameters:
--       p_oe_line_id              IN NUMBER
--         The shipment line id corresponding to which the transaction is to be deleted.
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.
PROCEDURE Delete_IB_Transaction(
    p_init_msg_list          IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level       IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status          OUT NOCOPY            VARCHAR2,
    x_msg_count              OUT NOCOPY            NUMBER,
    x_msg_data               OUT NOCOPY            VARCHAR2,
    p_oe_line_id             IN            NUMBER);

--mpothuku End

End AHL_OSP_SHIPMENT_PUB;

/
