--------------------------------------------------------
--  DDL for Package INV_ITEM_INQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ITEM_INQ" AUTHID CURRENT_USER AS
/* $Header: INVIQWMS.pls 120.0 2005/05/25 06:32:00 appldev noship $ */


TYPE t_genref IS REF CURSOR;

FUNCTION get_status_code (
        p_status_id mtl_material_statuses_vl.status_id%TYPE
        ) RETURN VARCHAR2 ;

PROCEDURE INV_ITEM_INQUIRIES (
               x_item_inquiries         OUT NOCOPY t_genref,
               p_Organization_Id        IN  NUMBER,
               p_Inventory_Item_Id      IN  NUMBER    DEFAULT NULL,
               p_Revision               IN  VARCHAR2  DEFAULT NULL,
               p_Lot_Number             IN  VARCHAR2  DEFAULT NULL,
               p_Subinventory_Code      IN  VARCHAR2  DEFAULT NULL,
               p_Locator_Id             IN  NUMBER    DEFAULT NULL,
               x_Status                 OUT NOCOPY VARCHAR2,
               x_Message                OUT NOCOPY VARCHAR2);

PROCEDURE WMS_LOOSE_ITEM_INQUIRIES (
          x_item_inquiries    OUT NOCOPY t_genref,
          p_organization_id   IN  NUMBER,
          p_inventory_item_id IN  NUMBER  DEFAULT NULL,
          p_revision    IN  VARCHAR2  DEFAULT NULL,
          p_lot_number     IN  VARCHAR2  DEFAULT NULL,
          p_subinventory_code      IN  VARCHAR2 DEFAULT NULL,
          p_locator_id     IN  NUMBER   DEFAULT NULL,
               p_cost_Group_id          IN  NUMBER   DEFAULT NULL,
          x_status         OUT NOCOPY VARCHAR2,
          x_message     OUT NOCOPY VARCHAR2);

PROCEDURE INV_SERIAL_INQUIRIES (
               x_serial_inquiries       OUT NOCOPY t_genref,
               p_Organization_Id        IN  NUMBER,
               p_Serial_Number          IN  VARCHAR2  DEFAULT NULL,
               p_Inventory_Item_Id      IN  NUMBER    DEFAULT NULL,
               p_Revision               IN  VARCHAR2  DEFAULT NULL,
               p_Lot_Number             IN  VARCHAR2  DEFAULT NULL,
               p_Subinventory_Code      IN  VARCHAR2  DEFAULT NULL,
               p_Locator_Id             IN  NUMBER    DEFAULT NULL,
               x_Status                 OUT NOCOPY VARCHAR2,
               x_Message                OUT NOCOPY VARCHAR2);

PROCEDURE WMS_LOOSE_SERIAL_INQUIRIES (
               x_serial_inquiries       OUT NOCOPY t_genref,
               p_Organization_Id        IN NUMBER,
               p_Serial_Number          IN VARCHAR2  DEFAULT NULL,
               p_Inventory_Item_Id      IN NUMBER    DEFAULT NULL,
               p_Revision               IN VARCHAR2  DEFAULT NULL,
               p_Lot_Number             IN VARCHAR2  DEFAULT NULL,
               p_Subinventory_Code      IN VARCHAR2  DEFAULT NULL,
               p_Locator_Id             IN NUMBER    DEFAULT NULL,
               p_cost_Group_id          IN NUMBER    DEFAULT NULL,
               x_Status                OUT NOCOPY VARCHAR2,
               x_Message               OUT NOCOPY VARCHAR2);


-- Added an extra parameter p_lpn_context_id as part of Bug 2091699 and defaulting it
PROCEDURE LOT_ATTRIBUTES(
   x_lot_attributes OUT NOCOPY t_genref,
   p_lot_number     IN  VARCHAR2,
   p_organization_id IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_lpn_context_id IN NUMBER DEFAULT 0);    -- Bug 2091699

-- Added an extra parameter p_lpn_context_id as part of Bug 2091699 and defaulting it
PROCEDURE SERIAL_ATTRIBUTES(
   x_serial_attributes OUT NOCOPY t_genref,
   p_serial_number IN VARCHAR2,
   p_organization_id IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_lpn_context_id IN NUMBER DEFAULT 0);

PROCEDURE GET_SERIAL_NUMBER(
   x_serialLOV OUT NOCOPY t_genref,
   p_organization_id IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_serial_number IN VARCHAR2);

PROCEDURE Get_Serial_Number_Inq(
   x_serialLOV OUT NOCOPY t_genref,
   p_organization_id IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_serial_number in VARCHAR2);

PROCEDURE Get_Serial_Number_RcptTrx(
        x_serialLOV OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_inventory_item_id IN NUMBER,
        p_serial_number in VARCHAR2,
   p_transactiontypeid in NUMBER);



PROCEDURE get_pup_SERIAL_NUMBER(
   x_serialLOV OUT NOCOPY t_genref,
   p_organization_id IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_serial_number IN VARCHAR2,
   p_txn_type_id    IN   NUMBER   := 0,
   p_wms_installed  IN   VARCHAR2 :='TRUE');


PROCEDURE get_serial_lov(x_serial_number OUT NOCOPY t_genref,
          p_organization_id IN NUMBER,
          p_item_id IN VARCHAR2,
          p_serial IN VARCHAR2);


PROCEDURE SELECT_SERIAL_NUMBER(
   x_serial_numbers OUT NOCOPY t_genref,
   p_organization_id IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_revision IN VARCHAR2,
   p_subinventory_code IN VARCHAR2,
   p_locator_id IN NUMBER,
   p_cost_Group_id IN NUMBER,
   p_lot_number IN VARCHAR2);

-- Added by Amy (qxliu) Sept. 20, 2001
-- Overloaded procedure to find serial numbers in a LPN
-- Added an extra parameter p_lpn_context_id as part of Bug 2091699 and defaulting it
PROCEDURE SELECT_SERIAL_NUMBER(
        x_serial_numbers OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_inventory_item_id IN NUMBER,
        p_lot_number IN VARCHAR2,
        p_lpn_id IN NUMBER,
        p_lpn_context_id IN NUMBER DEFAULT 0,
        p_revision IN VARCHAR2);

PROCEDURE GET_LPN_CONTENTS(
   x_lpn_contents    OUT NOCOPY t_genref,
   p_parent_lpn_id      IN  NUMBER);

PROCEDURE GET_LPN_FOR_ITEM(
   x_lpn_for_item    OUT NOCOPY t_genref
,  p_organization_id IN  NUMBER
,  p_inventory_item_id  IN  NUMBER
,  p_subinventory_code  IN  VARCHAR2
,  p_locator_id      IN  NUMBER
,  p_lot_number      IN  VARCHAR2
,  p_serial_number      IN  VARCHAR2
,  p_revision     IN  VARCHAR2
,  p_cost_group_id      IN  NUMBER);


FUNCTION GET_AVAILABLE_QTY (
               p_Organization_Id        IN  NUMBER,
               p_Inventory_Item_Id      IN  NUMBER,
               p_Revision               IN  VARCHAR2,
               p_Subinventory_Code      IN  VARCHAR2,
               p_Locator_Id             IN  NUMBER,
               p_Lot_Number             IN  VARCHAR2,
               p_cost_group_id          IN  NUMBER,
               p_revision_control   IN VARCHAR2 ,
               p_lot_control     IN VARCHAR2,
               p_serial_control     IN VARCHAR2)RETURN NUMBER;

FUNCTION GET_PACKED_QUANTITY (
               p_Organization_Id        IN  NUMBER,
               p_Inventory_Item_Id      IN  NUMBER,
               p_Revision               IN  VARCHAR2,
               p_Subinventory_Code      IN  VARCHAR2,
               p_Locator_Id             IN  NUMBER,
               p_Lot_Number             IN  VARCHAR2,
          p_cost_group          IN  NUMBER) RETURN NUMBER;

FUNCTION GET_LOOSE_QUANTITY (
               p_Organization_Id        IN  NUMBER,
               p_Inventory_Item_Id      IN  NUMBER,
               p_Revision               IN  VARCHAR2,
               p_Subinventory_Code      IN  VARCHAR2,
               p_Locator_Id             IN  NUMBER,
               p_Lot_Number             IN  VARCHAR2,
          p_cost_group          IN  NUMBER) RETURN NUMBER;

-- INVCONV start

PROCEDURE  GET_PACKED_QTY(p_organization_id IN NUMBER,
         p_inventory_item_id IN NUMBER,
         p_revision IN VARCHAR2,
         p_subinventory_code IN VARCHAR2,
         p_locator_id       IN NUMBER,
         p_lot_number       IN VARCHAR2,
         p_cost_Group     IN NUMBER,
         x_packed_qty       OUT NOCOPY NUMBER,
         x_sec_packed_qty       OUT NOCOPY NUMBER);


PROCEDURE GET_LOOSE_QTY(p_organization_id IN NUMBER,
                        p_inventory_item_id IN NUMBER,
                        p_revision IN VARCHAR2,
                        p_subinventory_code IN VARCHAR2,
                        p_locator_id        IN NUMBER,
                        p_lot_number        IN VARCHAR2,
                        p_cost_Group        IN NUMBER,
                        x_loose_qty       OUT NOCOPY NUMBER,
                        x_sec_loose_qty       OUT NOCOPY NUMBER);

PROCEDURE  GET_PACKED_LOOSE_QTY(p_organization_id IN NUMBER,
         p_inventory_item_id IN NUMBER,
         p_revision IN VARCHAR2,
         p_subinventory_code IN VARCHAR2,
         p_locator_id       IN NUMBER,
         p_lot_number       IN VARCHAR2,
         p_cost_Group     IN NUMBER,
         x_packed_qty       OUT NOCOPY NUMBER,
         x_loose_qty       OUT NOCOPY NUMBER,
         x_sec_packed_qty       OUT NOCOPY NUMBER,
         x_sec_loose_qty       OUT NOCOPY NUMBER);

-- INVCONV end

--UPDATE_QUANTITY
--  Used to update the quantity tree.  This is a wrapper procedure
-- for the INV_QUANITY_TREE_PUB.update_quantities procedure.  This
-- procedure should only be used for inventory transactions (not
-- reservations).  Also, if you are transacting against an already
-- existing reservation, please use the API in INV_QUANITY_TREE_PUB.a
--
-- Please Note: Calling this function will NOT update any inventory
-- tables. You must update the tables yourself.
--
-- Please pass 1 for p_containerized if quantity being transacted is
-- inside a container; 0 otherwise.
--
-- X_qoh is the quantity on hand for the item in the location you pass in;
-- X_att is the available quantity (Onhand - reservations - suggestions)

PROCEDURE UPDATE_QUANTITY(
     p_organization_id          IN  NUMBER
   , p_inventory_item_id        IN  NUMBER
   , p_revision                 IN  VARCHAR2 DEFAULT NULL
   , p_lot_number               IN  VARCHAR2 DEFAULT NULL
   , p_subinventory_code        IN  VARCHAR2 DEFAULT NULL
   , p_locator_id               IN  NUMBER   DEFAULT NULL
   , p_cost_group_id            IN  NUMBER DEFAULT NULL
   , p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
   , p_primary_quantity         IN  NUMBER
   , p_containerized            IN  NUMBER
   , x_qoh                      OUT NOCOPY NUMBER
   , x_att                      OUT NOCOPY NUMBER
   , x_return_status            OUT NOCOPY VARCHAR2
   , x_msg_count                OUT NOCOPY NUMBER
   , x_msg_data                 OUT NOCOPY VARCHAR2
   );

--Overloaded procedure (for filtering on project and task)
PROCEDURE INV_ITEM_INQUIRIES (
               x_item_inquiries         OUT NOCOPY t_genref,
               p_Organization_Id        IN  NUMBER,
               p_Inventory_Item_Id      IN  NUMBER    DEFAULT NULL,
               p_Revision               IN  VARCHAR2  DEFAULT NULL,
               p_Lot_Number             IN  VARCHAR2  DEFAULT NULL,
               p_Subinventory_Code      IN  VARCHAR2  DEFAULT NULL,
               p_Locator_Id             IN  NUMBER    DEFAULT NULL,
               p_project_id             IN  NUMBER    DEFAULT NULL,
               p_task_id                IN  NUMBER    DEFAULT NULL,
               x_Status                 OUT NOCOPY VARCHAR2,
               x_Message                OUT NOCOPY VARCHAR2);

--Overloaded procedure (for filtering on project and task)
PROCEDURE WMS_LOOSE_ITEM_INQUIRIES (
          x_item_inquiries    OUT NOCOPY t_genref,
          p_organization_id   IN  NUMBER,
          p_inventory_item_id IN  NUMBER   DEFAULT NULL,
          p_revision          IN  VARCHAR2 DEFAULT NULL,
          p_lot_number        IN  VARCHAR2 DEFAULT NULL,
          p_subinventory_code IN  VARCHAR2 DEFAULT NULL,
          p_locator_id        IN  NUMBER   DEFAULT NULL,
          p_cost_Group_id     IN  NUMBER   DEFAULT NULL,
          p_project_id        IN  NUMBER   DEFAULT NULL,
          p_task_id           IN  NUMBER   DEFAULT NULL,
          x_status            OUT NOCOPY VARCHAR2,
          x_message           OUT NOCOPY VARCHAR2);

--Overloaded procedure (for filtering on project, task and unit number)
PROCEDURE INV_SERIAL_INQUIRIES (
               x_serial_inquiries       OUT NOCOPY t_genref,
               p_Organization_Id        IN  NUMBER,
               p_Serial_Number          IN  VARCHAR2  DEFAULT NULL,
               p_Inventory_Item_Id      IN  NUMBER    DEFAULT NULL,
               p_Revision               IN  VARCHAR2  DEFAULT NULL,
               p_Lot_Number             IN  VARCHAR2  DEFAULT NULL,
               p_Subinventory_Code      IN  VARCHAR2  DEFAULT NULL,
               p_Locator_Id             IN  NUMBER    DEFAULT NULL,
               p_project_id             IN  NUMBER    DEFAULT NULL,
               p_task_id                IN  NUMBER    DEFAULT NULL,
               p_unit_number            IN  VARCHAR2  DEFAULT NULL,
               x_Status                 OUT NOCOPY VARCHAR2,
               x_Message                OUT NOCOPY VARCHAR2);


--Overloaded procedure (for filtering on project and task)
PROCEDURE WMS_LOOSE_SERIAL_INQUIRIES (
               x_serial_inquiries       OUT NOCOPY t_genref,
               p_Organization_Id        IN NUMBER,
               p_Serial_Number          IN VARCHAR2  DEFAULT NULL,
               p_Inventory_Item_Id      IN NUMBER    DEFAULT NULL,
               p_Revision               IN VARCHAR2  DEFAULT NULL,
               p_Lot_Number             IN VARCHAR2  DEFAULT NULL,
               p_Subinventory_Code      IN VARCHAR2  DEFAULT NULL,
               p_Locator_Id             IN NUMBER    DEFAULT NULL,
               p_cost_Group_id          IN NUMBER    DEFAULT NULL,
               p_project_id             IN  NUMBER   DEFAULT NULL,
               p_task_id                IN  NUMBER   DEFAULT NULL,
               p_unit_number            IN  VARCHAR2 DEFAULT NULL,
               x_Status                 OUT NOCOPY VARCHAR2,
               x_Message                OUT NOCOPY VARCHAR2);

--Procedure to fetch Unit Numbers for the item
PROCEDURE GET_UNIT_NUMBERS (
               x_unit_numbers           OUT NOCOPY t_genref,
               p_organization_id        IN NUMBER,
                                                         p_inventory_item_id      IN NUMBER,
               p_restrict_unit_numbers  IN VARCHAR2);

/****************************************************************************
* Overloaded procedure to find serial numbers given a unit # and even serial #
* This procedure would be used when the ItemOnhandPage displays data for a
* Unit Number and/or a Serial Number
****************************************************************************/
PROCEDURE SELECT_SERIAL_NUMBER(
        x_serial_numbers OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_inventory_item_id IN NUMBER,
        p_revision IN VARCHAR2,
        p_subinventory_code IN VARCHAR2,
        p_locator_id IN NUMBER,
        p_cost_Group_id IN NUMBER,
        p_lot_number IN VARCHAR2,
        p_unit_number IN VARCHAR := NULL,
        p_serial_number IN VARCHAR2 := NULL);

--Item Inquiry based on project, task and unit number for MSCA orgs
PROCEDURE INV_UNIT_NUMBER_INQUIRIES (
               x_unit_inquiries       OUT NOCOPY t_genref,
               p_Organization_Id        IN  NUMBER,
               p_unit_number            IN  VARCHAR2  DEFAULT NULL,
               p_Inventory_Item_Id      IN  NUMBER    DEFAULT NULL,
               p_Revision               IN  VARCHAR2  DEFAULT NULL,
               p_Lot_Number             IN  VARCHAR2  DEFAULT NULL,
               p_Subinventory_Code      IN  VARCHAR2  DEFAULT NULL,
               p_Locator_Id             IN  NUMBER    DEFAULT NULL,
               p_project_id             IN  NUMBER    DEFAULT NULL,
               p_task_id                IN  NUMBER    DEFAULT NULL,
               x_Status                 OUT NOCOPY VARCHAR2,
               x_Message                OUT NOCOPY VARCHAR2);

--Item Inquiry based on project, task and unit number for WMS orgs
PROCEDURE WMS_UNIT_NUMBER_INQUIRIES (
               x_unit_inquiries         OUT NOCOPY t_genref,
               p_Organization_Id        IN  NUMBER,
               p_unit_number            IN  VARCHAR2 DEFAULT NULL,
               p_Inventory_Item_Id      IN  NUMBER   DEFAULT NULL,
               p_Revision               IN  VARCHAR2 DEFAULT NULL,
               p_Lot_Number             IN  VARCHAR2 DEFAULT NULL,
               p_Subinventory_Code      IN  VARCHAR2 DEFAULT NULL,
               p_Locator_Id             IN  NUMBER   DEFAULT NULL,
               p_cost_Group_id          IN  NUMBER   DEFAULT NULL,
               p_project_id             IN  NUMBER   DEFAULT NULL,
               p_task_id                IN  NUMBER   DEFAULT NULL,
               x_Status                 OUT NOCOPY VARCHAR2,
               x_Message                OUT NOCOPY VARCHAR2);

--changes for walkup loc project
/******************************************
 * Obtain onhand information
 *  WMS org, provide cost group information
 *       query wms related information
 *****************************************/
/* THIS PROCEDURE IS NOT BEING USED ANYWHERE */
PROCEDURE WMS_LOOSE_ITEM_INQUIRIES  (
               x_item_inquiries          OUT NOCOPY t_genref,
               p_Organization_Id         IN NUMBER,
               p_Inventory_Item_Id       IN NUMBER   DEFAULT NULL,
               p_Subinventory_Code       IN VARCHAR2 DEFAULT NULL,
               p_Locator_Id              IN NUMBER DEFAULT NULL,
               x_Status                 OUT NOCOPY VARCHAR2,
               x_Message                OUT NOCOPY VARCHAR2);


-- INVCONV start
PROCEDURE GET_AVAILABLE_QTIES (p_organization_id     IN NUMBER,
                                p_inventory_item_id   IN NUMBER,
                                p_revision            IN VARCHAR2,
                                p_subinventory_code   IN VARCHAR2,
                                p_locator_id          IN NUMBER,
                                p_lot_number          IN VARCHAR2,
                                p_cost_group_id       IN NUMBER,
                                p_revision_control IN VARCHAR2,
                                p_lot_control      IN VARCHAR2,
                                p_serial_control   IN VARCHAR2,
                                x_available_qty    OUT NOCOPY NUMBER,
                                x_sec_available_qty OUT NOCOPY NUMBER);
-- INVCONV end




  -- INVCONV, NSRIVAST, START
  /*
   * Overloaded procedure that calls the the update_quantity procedure
   * with secondary quantity.
   */

PROCEDURE UPDATE_QUANTITY (
     p_organization_id          IN  NUMBER
   , p_inventory_item_id        IN  NUMBER
   , p_revision                 IN  VARCHAR2 DEFAULT NULL
   , p_lot_number               IN  VARCHAR2 DEFAULT NULL
   , p_subinventory_code        IN  VARCHAR2 DEFAULT NULL
   , p_locator_id               IN  NUMBER   DEFAULT NULL
   , p_cost_group_id            IN  NUMBER DEFAULT NULL
   , p_transfer_subinventory_code IN  VARCHAR2 DEFAULT NULL
   , p_primary_quantity         IN  NUMBER
   , p_containerized            IN  NUMBER
   , p_secondary_quntity        IN  NUMBER            -- INVCONV, NSRIVAST,
   , x_qoh                      OUT NOCOPY NUMBER
   , x_att                      OUT NOCOPY NUMBER
   , x_return_status            OUT NOCOPY VARCHAR2
   , x_msg_count                OUT NOCOPY NUMBER
   , x_msg_data                 OUT NOCOPY VARCHAR2
   ) ;



END inv_ITEM_INQ;

 

/
