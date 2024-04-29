--------------------------------------------------------
--  DDL for Package WMS_YMS_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_YMS_INTEGRATION_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSYMSIS.pls 120.0.12010000.2 2014/01/22 22:51:05 abasheer noship $ */

TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

PROCEDURE DEBUG(p_message IN VARCHAR2,
                p_module  IN VARCHAR2 DEFAULT 'WMS_YMS_INTEGRATION_PVT',
                p_level   IN VARCHAR2 DEFAULT 9);

/*
** -------------------------------------------------------------------------
** Procedure    :get_item_cost
** Description  :Called by Other products to get the item cost
**  Caller will pass in the inventory_item_id, organization_id and document details
**  First we will call the YMS_CUSTOM_PUB.get_item_cost to see if custom API
**  is written to return the unit cost of the item in given document.
**  If Custom API returns a non-zero value, we take that cost and return to caller
**  Else
        If org is Standard Cost enabled org then call the CST API with just item and org.
        Else
            If the org is not costing enabled then passing the default org cost group to get item cost in that cost group.
            If the costing API still returns 0 cost then call it with cost_type_id 3 i.e, Average
    End If;
    Return the computed cost of the item to the caller.
** --------------------------------------------------------------------------
*/
PROCEDURE get_item_cost(
    p_inventory_item_id     IN  NUMBER
    , p_organization_id     IN  NUMBER
    , p_document_type       IN  VARCHAR2
    , p_document_number     IN  VARCHAR2
    , p_document_reference_id   IN NUMBER
    , x_item_cost           OUT NOCOPY NUMBER
    , x_item_cost_curr_code OUT NOCOPY VARCHAR2
    , x_return_status       OUT NOCOPY VARCHAR2
    , x_msg_count           OUT NOCOPY NUMBER
    , x_msg_data            OUT NOCOPY VARCHAR2
);


/*
** -------------------------------------------------------------------------
** Function     :get_yard_org_id
** Description  :Called by caller with inv_org_id as input
**      This API returns the yard_org_id for the corresponding INV org.
**      If no relevant Yard is attached to the INV org we return -999
** --------------------------------------------------------------------------
*/
FUNCTION get_yard_org_id (
    p_inv_org_id    IN NUMBER)
RETURN NUMBER;

/*
** ---------------------------------------------------------------------------
** To prevent requery of database as much as possible within the same session,
** the following global variables are cached and used suitably:
**
** g_wms_installation_status :
** 	If 'I', indicates product YMS is installed
** g_organization_id:
**	The last organization that was checked if YMS enabled
** g_wms_enabled_flag :
**	Indicates if the last organization checked is YMS enabled or not
** ---------------------------------------------------------------------------
*/
g_yms_installation_status   VARCHAR2(10);
g_organization_id           NUMBER;
g_yms_enabled_flag          VARCHAR2(1);

/*
** ---------------------------------------------------------------------------
** Function:    check_yms_install
** Description: Checks to see if YMS is installed
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
**      p_organization_id
**	       -specific organization to be checked if YMS enabled.
**
**	       -if NULL, the check is just made at site level
**              and not for any specific organization.This is more relaxed than
**              passing a specific organization.
** Returns:
**      TRUE if YMS installed, else FALSE
**
**      Please use return value to determine if YMS is installed or not.
**      Do not use x_return_status for this purpose as
**      . x_return_status could be success and yet YMS not be installed.
**      . x_return_status is set to error when an error(such as SQL error)
**        occurs.
** --------------------------------------------------------------------------
*/

/*#
 * This routine can be used to check if Warehouse Management System is installed
 * and if an organization is WMS enabled.
 * x_return_status return variable holding the status of the procedure call
 * x_msg_count return variable holding the number of error messages returned
 * x_msg_data return variable holding the error message
 * p_organization_id specific organization to be checked if WMS enabled. if NULL, the check is just made at site level
 * if wms is installed or if the organization is wms enabled
*/
FUNCTION check_yms_install (
  x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
, p_organization_id     IN  NUMBER)
RETURN BOOLEAN;


TYPE yms_ycd_record IS RECORD(
    equipment_id        NUMBER,
    document_type       VARCHAR2(60),    --'RMA', 'DELIVERY','INT SHIPMENT','INT ORDER','ASN','PO' etc
    document_header_id  NUMBER           -- RMA header_id, Delivery_id, shipment_id (RSH id) etc
);

TYPE yms_eqp_contents_tbl_type IS TABLE OF yms_ycd_record INDEX BY BINARY_INTEGER;

/*
** -------------------------------------------------------------------------
** Procedure    :update_yms_content_docs
** Description  :Called by Other products to update YCD data for given equipment
**      Valid callers are 'WSH', 'RCV', 'OM', Others
**      Caller passed in the list of equipment/document combinations for update
**      We will in turn call the YMS_TRANSACTION_PVT.update_yms_content_docs
**      which will do the core processing.
** --------------------------------------------------------------------------
*/
PROCEDURE update_yms_content_docs(
    p_yms_eqp_contents_tbl  IN  WMS_YMS_INTEGRATION_PVT.yms_eqp_contents_tbl_type   --List of records for each equipment/document combination.
    ,  p_caller             IN  VARCHAR2    --eg: WSH , RCV, OM   etc
    , x_return_status       OUT NOCOPY VARCHAR2
    , x_msg_count           OUT NOCOPY NUMBER
    , x_msg_data            OUT NOCOPY VARCHAR2
);

/*
** -------------------------------------------------------------------------
** Procedure    :get_equipment_details
** Description  :Required by WSH to get the equipment detials
**      Caller calls with a equipment_id
**      For the given equipment we return various values from yms_equipment_details_v
** --------------------------------------------------------------------------
*/
PROCEDURE get_equipment_details (
    p_equipment_id          IN  NUMBER,
    x_equipment_number      OUT NOCOPY VARCHAR2,
    x_trailer_scac_code     OUT NOCOPY VARCHAR2,
    x_eqp_status_id         OUT NOCOPY NUMBER,
    x_equipment_status      OUT NOCOPY VARCHAR2,
    x_carrier_scac          OUT NOCOPY VARCHAR2,
    x_inv_dock_door_id      OUT NOCOPY NUMBER,
    x_inv_dock_door         OUT NOCOPY VARCHAR2
);

/*
** -------------------------------------------------------------------------
** Procedure    :get_equipment_at_dock
** Description  :Caller by WSH to get the equipment at given dock door.
**       We query yms_equipment_details_v to find equipment_id at give
**       dock door and return it.
** --------------------------------------------------------------------------
*/
PROCEDURE get_equipment_at_dock (
    p_organization_id       IN  NUMBER,
    p_dock_door_id          IN  NUMBER,
    x_equipment_id          OUT NOCOPY NUMBER
);

/*
** -------------------------------------------------------------------------
** Procedure    :update_shipment_number
** Description  :Called by WSH for a given equipment
**  We will update the yms_equipment details with the passed in shipment_number
** --------------------------------------------------------------------------
*/
PROCEDURE update_shipment_number(
    p_equipment_id          IN  NUMBER,
    p_shipment_number       IN  VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
);

/*
** -------------------------------------------------------------------------
** Procedure    :update_rsl_yms_equipment
** Description  :Called by INV code for a given equipment
**  We will call RCV api to update the equipment id in shipment line
** --------------------------------------------------------------------------
*/
PROCEDURE update_rsl_yms_equipment (
    p_shipment_header_id IN  NUMBER
  , p_equipment_id       IN NUMBER
  , p_shipment_line_id   IN NUMBER DEFAULT NULL
  , x_return_status      OUT NOCOPY VARCHAR2
  , x_msg_data           OUT NOCOPY VARCHAR2
);

/*
** -------------------------------------------------------------------------
** Procedure    :update_oe_yms_equipment
** Description  :Called by INV code for a given equipment
**  We will call OE api to update the equipment id in order line for RMA
** --------------------------------------------------------------------------
*/
PROCEDURE update_oe_yms_equipment (
    p_header_id     IN  NUMBER DEFAULT NULL
  , p_line_id       IN NUMBER DEFAULT NULL
  , p_equipment_id  IN NUMBER
  , x_return_status OUT NOCOPY VARCHAR2
  , x_return_msg      OUT NOCOPY VARCHAR2
);

/*
** -------------------------------------------------------------------------
** Procedure    :update_wsh_yms_equipment
** Description  :Called by WMS code for a given equipment
**  We will call WSH apis to update the equipment id in delivery or delivery details
** --------------------------------------------------------------------------
*/
PROCEDURE update_wsh_yms_equipment (
    p_action_code             IN VARCHAR2
  , p_caller                  IN VARCHAR2
  , p_equipment_id            IN VARCHAR2
  , p_delivery_id_tab         IN  WMS_YMS_INTEGRATION_PVT.num_tbl_type
  , p_delivery_detail_id_tab  IN  WMS_YMS_INTEGRATION_PVT.num_tbl_type
  , p_org_id_tab              IN  WMS_YMS_INTEGRATION_PVT.num_tbl_type
  , x_return_status           OUT NOCOPY VARCHAR2
  , x_msg_data                OUT NOCOPY VARCHAR2
  , x_msg_count               OUT NOCOPY NUMBER
);

END WMS_YMS_INTEGRATION_PVT;

/
