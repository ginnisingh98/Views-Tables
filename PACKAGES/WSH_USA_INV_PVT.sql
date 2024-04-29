--------------------------------------------------------
--  DDL for Package WSH_USA_INV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_USA_INV_PVT" AUTHID CURRENT_USER as
/* $Header: WSHUSAIS.pls 120.6.12010000.2 2010/09/15 05:11:35 brana ship $ */

G_PACKAGE_NAME               CONSTANT        VARCHAR2(50) := 'WSH_USA_INV_PVT';

-- Variables used to store the Previous Ship Set / SMC record information during Backorder
g_ss_smc_found          BOOLEAN := FALSE;
g_move_order_line_id    NUMBER;
g_ship_set_id           NUMBER;
g_ship_model_id         NUMBER;
g_backordered_item          VARCHAR2(2000);
g_top_model_item        VARCHAR2(2000);
g_ship_set_name         VARCHAR2(30);
g_delivery_detail_id    NUMBER;


--  This record type contains inventory level information for a delivery detail
TYPE DeliveryDetailInvRecType IS RECORD
                (delivery_detail_id                             NUMBER       ,
                 released_status                                VARCHAR2(1)  ,
                 move_order_line_id                             NUMBER       ,
                 organization_id                                NUMBER       ,
                 inventory_item_id                              NUMBER       ,
                 subinventory                                   VARCHAR2(10) ,
                 revision                                       VARCHAR2(3)  ,
                 lot_number             WSH_DELIVERY_DETAILS.LOT_NUMBER%TYPE ,
                 locator_id                                     NUMBER        ,
		 lpn_id                                         NUMBER
                 );

  TYPE Back_Det_Rec IS RECORD (
        DELIVERY_DETAIL_ID            NUMBER,
        DELIVERY_ID                   NUMBER,
        CONTAINER_ID                  NUMBER,
        ORGANIZATION_ID               NUMBER,
        LINE_DIRECTION                VARCHAR2(10),
        GROSS_WEIGHT                  NUMBER,
        NET_WEIGHT                    NUMBER,
        VOLUME                        NUMBER,
        PLANNED_FLAG                  VARCHAR2(1),
        DEL_BATCH_ID                  NUMBER
        );

   TYPE Back_Det_Rec_Tbl IS TABLE OF Back_Det_Rec INDEX BY BINARY_INTEGER;

/**
   Procedure handles unassigning of delivery detail from delivery/container
   This procedure is called after detail is set to Backordered status to handle
   Wt/Vol adjustments as well as any other processing logic.
   The backordered delivery detail is unassigned from the delivery
   if the delivery is not planned
   The backordered delivery detail is unpacked if the org is wms enabled
   or if the org is not wms enabled and the delivery is not planned.
   Parameters :
   p_backorder_rec_tbl    - Input Table of Records with the following record structure:
     delivery_detail_id   - Delivery Detail which is getting backordered
     delivery_id          - Delivery of the backordered detail
     container_id         - Immediate Parent Container of the backordered detail
     organization_id      - Delivery Detail's Organization
     line_direction       - Line Direction
     planned_flag         - Delivery is Planned or not (Y/N)
     gross_weight         - Detail's Gross Weight
     net_weight           - Detail's Net Weight
     volume               - Detail's Volume
     del_batch_id         - Delivery's Pick Release Batch Id (whether created during Pick Release process)
   x_return_status        - Return Status (Success/Unexpected Error)
*/
PROCEDURE Unassign_Backordered_Details (
                                         p_backorder_rec_tbl    IN Back_Det_Rec_Tbl,
                                         p_org_info_tbl         IN WSH_PICK_LIST.Org_Params_Rec_Tbl,
                                         x_return_status        OUT NOCOPY VARCHAR2
                                       );

-- This procedure returns the total reservations that exist on a source_line_id in an organization

-- HW OPMCONV - Need to get Qty2 reserved.
-- Added x_total_rsv2 and added NOCOPY To x_total_rsv and x_total_rsv2
--
PROCEDURE Get_total_reserved_quantity (p_source_code  IN VARCHAR2 ,
                                p_source_header_id   IN NUMBER ,
                                p_source_line_id     IN NUMBER ,
                                p_organization_id    IN NUMBER ,
                                x_total_rsv          IN OUT NOCOPY NUMBER ,
                                x_total_rsv2         IN OUT NOCOPY NUMBER ,
                                x_return_status      IN OUT NOCOPY VARCHAR2);


-- This is a wrapper on inv_reservation_pub.query_reservation
-- X-dock add new parameter p_delivery_detail_id as reservations for
-- X-dock lines will be on the basis of delivery detail id
PROCEDURE  query_reservations  (
 p_source_code                   IN  VARCHAR2,
 p_source_header_id              IN  NUMBER,
 p_source_line_id                IN  NUMBER,
 p_organization_id               IN  NUMBER,
 p_lock_records                  IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
 p_cancel_order_mode             IN  NUMBER   DEFAULT INV_RESERVATION_GLOBAL.G_CANCEL_ORDER_NO,
 p_direction_flag                IN  VARCHAR2 DEFAULT 'U',
 p_delivery_detail_id            IN  NUMBER,
 x_mtl_reservation_tbl           OUT NOCOPY  INV_RESERVATION_GLOBAL.MTL_RESERVATION_TBL_TYPE,
 x_mtl_reservation_tbl_count     OUT NOCOPY  NUMBER,
 x_return_status                 OUT NOCOPY  VARCHAR2);

-- This is a wrapper on private delete_reservation
PROCEDURE  delete_reservation (
 p_query_input                   IN  inv_reservation_global.mtl_reservation_rec_type,
 x_return_status                 OUT NOCOPY  VARCHAR2);

-- This is a wrapper on inv_reservation_pub.create_reservation
-- HW OPMCONV Pass Qty2 in order to call the correct INV_create_reservation
PROCEDURE  create_reservation (
 p_query_input                   IN  inv_reservation_global.mtl_reservation_rec_type,
 p_qty2                          IN  NUMBER default NULL,
 x_reservation_id                OUT NOCOPY  NUMBER,
 x_qty_reserved                  OUT NOCOPY  NUMBER,
 x_return_status                 OUT NOCOPY  VARCHAR2);

-- This is a wrapper on inv_reservation_pub.update_reservation
PROCEDURE  update_reservation (
 p_query_input                   IN  inv_reservation_global.mtl_reservation_rec_type,
 p_new_resv_rec                  IN inv_reservation_global.mtl_reservation_rec_type,
 x_return_status                 OUT NOCOPY  VARCHAR2);

FUNCTION  check_allocations (
 p_move_order_line_id            IN  NUMBER) RETURN BOOLEAN;

-- This procedure takes care that staged reservations get reduced by the cancellation quantity from
-- appropriate inventory controls when some quantity from a staged delivery line is reduced
-- HW OPMCONV - Pass Qty2
PROCEDURE  cancel_staged_reservation  (
 p_source_code                   IN  VARCHAR2,
 p_source_header_id              IN  NUMBER,
 p_source_line_id                IN  NUMBER,
 p_delivery_detail_split_rec     IN  DeliveryDetailInvRecType,
 p_cancellation_quantity         IN  NUMBER,
 p_cancellation_quantity2        IN  NUMBER,
 x_return_status                 OUT NOCOPY  VARCHAR2);


-- This procedure takes care that non staged reservations get reduced by the cancellation quantity
-- when some quantity from one or more non staged delivery line is reduced
PROCEDURE  cancel_nonstaged_reservation  (
 p_source_code                   IN  VARCHAR2,
 p_source_header_id              IN  NUMBER,
 p_source_line_id                IN  NUMBER,
 p_delivery_detail_id            IN  NUMBER, --Bug3012297
 p_organization_id               IN  NUMBER,
 p_cancellation_quantity         IN  NUMBER,
 p_cancellation_quantity2        IN  NUMBER,
 x_return_status                 OUT NOCOPY  VARCHAR2);


-- This procedure takes care that reservations get updated/transferred by the split quantity
-- when an order line gets split.
-- Bug 2540015: Added p_move_order_line_status. Expected values are 'TRANSFER', 'CANCEL'
-- Added parameter p_shipped_flag for bug 10105817
PROCEDURE  split_reservation  (
 p_delivery_detail_split_rec     IN  DeliveryDetailInvRecType,
 p_source_code                   IN  VARCHAR2,
 p_source_header_id              IN  NUMBER,
 p_original_source_line_id       IN  NUMBER,
 p_split_source_line_id          IN  NUMBER,
 p_split_quantity                IN  NUMBER,   --  Pass p_changed_attrinute.ordered_quantity
 p_split_quantity2               IN  NUMBER,
 p_move_order_line_status        IN  VARCHAR2,
 p_direction_flag                IN VARCHAR2 default 'U',
 p_shipped_flag                  IN VARCHAR2 default 'N',
 x_return_status                 OUT NOCOPY  VARCHAR2);


PROCEDURE  update_serial_numbers(
           p_delivery_detail_id         IN    NUMBER,
           p_serial_number              IN    VARCHAR2,
           p_transaction_temp_id        IN    NUMBER,
           x_return_status              OUT NOCOPY    VARCHAR2);


PROCEDURE  update_inventory_info(
  p_Changed_Attributes                  IN       WSH_INTERFACE.ChangedAttributeTabType,
  x_return_status                       OUT NOCOPY       VARCHAR2);

-- HW OPMCONV Make get_detailed a procedure to pass Qty2

-- PROCEDURE get_detailed_quantity
-- Parameters:	p_mo_line_id     - Move order line id
-- 		x_detailed_qty   - Primary Qty
--              x_detailed_qty2  - Secondary Qty
--              x_return_status  - Return Status

-- Description: This procedure was originally a function but because of
-- OPM Convergence project, it was converted to a procedure to return
-- Qty1 and Qty2.
-- This procedure checks if Qtys are detailed in mtl_material_transactions_temp
-- for a specific move order line id
--
PROCEDURE  get_detailed_quantity(
           p_mo_line_id              IN          NUMBER,
           x_detailed_qty            OUT NOCOPY  NUMBER,
           x_detailed_qty2           OUT NOCOPY  NUMBER,
           x_return_status           OUT NOCOPY  VARCHAR2);

--X-dock

-- Function: Based on Move Order Line id, determine the move order type
--           Return 'Y' if the MO type = PUTAWAY (for X-dock scenario)
-- Parameters : p_move_order_line_id - Move Order Line id
--
FUNCTION is_mo_type_putaway (p_move_order_line_id IN NUMBER) RETURN VARCHAR2;

-- PROCEDURE get_putaway_detail_id
-- Parameters : p_detail_id - Delivery detail id
--              p_released_status - Released Status
--              p_move_order_line_id - Move Order Line id
--              x_return_status      - Return Status
--              x_detail_id          - Output delivery detail id
-- Description : This procedure checks for move_order_type associated
--               with move order line id and returns delivery_detail_id
--               if the move_order_type is PUTAWAY and null if
--               move order type is not PUTAWAY (eg. PICK_WAVE)
--
PROCEDURE  get_putaway_detail_id(
           p_detail_id               IN          NUMBER,
           p_released_status         IN          VARCHAR2,
           p_move_order_line_id      IN          NUMBER,
           x_detail_id               OUT NOCOPY  NUMBER,
           x_return_status           OUT NOCOPY  VARCHAR2);

END WSH_USA_INV_PVT;

/
