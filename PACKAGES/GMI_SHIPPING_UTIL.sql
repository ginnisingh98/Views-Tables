--------------------------------------------------------
--  DDL for Package GMI_SHIPPING_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_SHIPPING_UTIL" AUTHID CURRENT_USER AS
/*  $Header: GMIUSHPS.pls 115.25 2004/02/20 01:42:37 hwahdani ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIUSHPS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private utilities  relating to OPM            |
 |     shipping.                                                           |
 |                                                                         |
 +=========================================================================+
*/

 /* NC - 11/02/01 Temperary declaration of this record type. Should be
       deleted when OM changes are incorporated */

TYPE SplitDetailRecType IS RECORD (
       delivery_detail_id       WSH_DELIVERY_DETAILS.delivery_detail_id%TYPE,
       requested_quantity       WSH_DELIVERY_DETAILS.requested_quantity%TYPE,
       picked_quantity          WSH_DELIVERY_DETAILS.picked_quantity%TYPE,
       shipped_quantity         WSH_DELIVERY_DETAILS.shipped_quantity%TYPE,
       cycle_count_quantity     WSH_DELIVERY_DETAILS.cycle_count_quantity%TYPE,
       requested_quantity_uom   WSH_DELIVERY_DETAILS.requested_quantity_uom%TYPE,
       requested_quantity2      WSH_DELIVERY_DETAILS.requested_quantity2%TYPE,
       picked_quantity2         WSH_DELIVERY_DETAILS.picked_quantity2%TYPE,
       shipped_quantity2        WSH_DELIVERY_DETAILS.shipped_quantity2%TYPE,
       cycle_count_quantity2    WSH_DELIVERY_DETAILS.cycle_count_quantity2%TYPE,
       requested_quantity_uom2  WSH_DELIVERY_DETAILS.requested_quantity_uom2%TYPE,
       organization_id          WSH_DELIVERY_DETAILS.organization_id%TYPE,
       inventory_item_id        WSH_DELIVERY_DETAILS.inventory_item_id%TYPE,
       subinventory             WSH_DELIVERY_DETAILS.subinventory%TYPE,
       lot_number               WSH_DELIVERY_DETAILS.lot_number%TYPE,
       sublot_number            WSH_DELIVERY_DETAILS.sublot_number%TYPE,
       locator_id               WSH_DELIVERY_DETAILS.locator_id%TYPE,
       source_line_id           WSH_DELIVERY_DETAILS.source_line_id%TYPE,
       net_weight               WSH_DELIVERY_DETAILS.net_weight%TYPE,
       cancelled_quantity       WSH_DELIVERY_DETAILS.cancelled_quantity%TYPE,
       cancelled_quantity2      WSH_DELIVERY_DETAILS.cancelled_quantity2%TYPE,
       serial_number            WSH_DELIVERY_DETAILS.serial_number%TYPE,
       to_serial_number         WSH_DELIVERY_DETAILS.to_serial_number%TYPE,
       transaction_temp_id      WSH_DELIVERY_DETAILS.transaction_temp_id%TYPE,
       container_flag           WSH_DELIVERY_DETAILS.container_flag%TYPE,
       released_status          WSH_DELIVERY_DETAILS.released_status%TYPE,
       delivery_id              WSH_DELIVERY_ASSIGNMENTS.delivery_id%TYPE,
       parent_delivery_detail_id  WSH_DELIVERY_ASSIGNMENTS.parent_delivery_detail_id%TYPE
);
PROCEDURE GMI_CREATE_BACKORDER_TXN
   ( p_shipping_line                 IN  wsh_delivery_details%ROWTYPE
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

PROCEDURE GMI_UPDATE_SHIPMENT_TXN
   ( p_shipping_line                 IN  wsh_delivery_details%ROWTYPE
   , p_actual_ship_date              IN  Date
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

PROCEDURE GMI_APPLY_BACKORDER_UPDATES
   ( p_original_source_line_id       IN  NUMBER
   , p_source_line_id                IN  NUMBER
   , p_action_flag                   IN  VARCHAR2
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

/* NC 23-AUG-01 Added the following two procedure headers BUG#1675561 */
PROCEDURE UPDATE_OPM_TRANSACTION
   ( p_old_delivery_detail_id  IN NUMBER,
     p_lot_number              IN VARCHAR2,
     p_sublot_number           IN VARCHAR2,
     p_organization_id         IN NUMBER,
     p_inventory_item_id       IN NUMBER,
     p_old_source_line_id      IN NUMBER,
     p_locator_id              IN NUMBER,
     p_new_delivery_detail_id  IN NUMBER,
     p_old_req_quantity        IN NUMBER,
     p_old_req_quantity2       IN NUMBER,
     p_req_quantity            IN NUMBER,
     p_req_quantity2           IN NUMBER DEFAULT NULL,
     x_return_status           OUT NOCOPY VARCHAR2,
     x_msg_count               OUT NOCOPY NUMBER,
     x_msg_data                OUT NOCOPY VARCHAR2 );

PROCEDURE UPDATE_OPM_IC_TRAN_PND
 (
    p_delivery_detail_id IN NUMBER,
    p_trans_id           IN NUMBER,
    p_staged_flag        IN NUMBER
 );

PROCEDURE PRINT_DEBUG
   ( p_tran_rec         IN  GMI_TRANS_ENGINE_PUB.ictran_rec
   , p_routine          IN  VARCHAR2
   );

PROCEDURE create_rcv_transaction
   ( p_shipping_line                 IN  wsh_delivery_details%ROWTYPE
   , p_trip_stop_rec                 IN  wsh_trip_stops%ROWTYPE
   , p_group_id                      IN  NUMBER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

PROCEDURE process_OPM_orders(
      p_stop_id           IN NUMBER
    , x_return_status OUT NOCOPY VARCHAR2
    ) ;


PROCEDURE MATCH_LINES ;

PROCEDURE unreserve_inv
( p_trans_id            IN NUMBER
, x_return_status       OUT NOCOPY VARCHAR2
);

PROCEDURE split_opm_trans
   ( p_old_delivery_detail_id  IN  NUMBER,
     p_released_status         IN  VARCHAR2,
     p_lot_number              IN  VARCHAR2,
     p_sublot_number           IN  VARCHAR2,
     p_organization_id         IN  NUMBER,
     p_inventory_item_id       IN  NUMBER,
     p_old_source_line_id      IN  NUMBER,
     p_locator_id              IN  NUMBER,
     p_old_req_quantity        IN  NUMBER,
     p_old_req_quantity2       IN  NUMBER,
     p_new_delivery_detail_id  IN  NUMBER,
     p_qty_to_split            IN  NUMBER,
     p_qty2_to_split           IN  NUMBER,
     x_return_status           OUT NOCOPY VARCHAR2,
     x_msg_count               OUT NOCOPY NUMBER,
     x_msg_data                OUT NOCOPY VARCHAR2
     );

PROCEDURE split_trans
   ( p_old_delivery_detail_id  IN  NUMBER,
     p_new_delivery_detail_id  IN  NUMBER,
     p_old_source_line_id      IN  NUMBER,
     p_new_source_line_id      IN  NUMBER,
     p_qty_to_split            IN  NUMBER,
     p_qty2_to_split           IN  NUMBER,
     x_return_status           OUT NOCOPY VARCHAR2,
     x_msg_count               OUT NOCOPY NUMBER,
     x_msg_data                OUT NOCOPY VARCHAR2
     );
procedure check_non_ctl
  ( p_delivery_detail_id IN NUMBER
   ,p_shipped_quantity   IN NUMBER
   ,p_shipped_quantity2  IN NUMBER
   ,x_return_status      OUT NOCOPY VARCHAR2
  );

-- HW 3157172
-- Added this procedure to replace the call to GMI_SHIPPING_UTIl.unreserve_inv
-- This procedure will be called from WSHDDACB.pls in WSH.J
-- This procedure was in place in the package body but was never
-- in use till 11.5.10
-- HW 12345 added p_consolidate_bo_lines for 11510
Procedure unreserve_delivery_detail
        ( p_delivery_detail_id     IN NUMBER
        , p_quantity_to_unreserve  IN NUMBER
        , p_quantity_to_unreserve2 IN NUMBER default NULL
        , p_unreserve_mode         IN VARCHAR2
        , x_return_status          OUT NOCOPY VARCHAR2
   );

-- HW 3388186
-- This procedure is introduced because of WSH Consolidate backorder Line Project in 11510
-- p_cons_dd_id Consolidated delivery_detail_id
-- p_old_dd_ids Old delivery_detail_ids that were consolidated

-- This procedure will pass old delivery detail_ids and the new condsolidated
-- delivery_detail_ids to update the inventory transactions
-- with new delivery_detail_id
-- This procedure is called from WSHDDSPB.pls (11510), procedure: Backorder
-- This procedure will be called when Consolidated Backorder Line
-- is checked in Global Parameter under Shipping > Setup and
-- Action is Cycle Count All
PROCEDURE UPDATE_NEW_LINE_DETAIL_ID
  ( p_cons_dd_id       IN NUMBER
  , p_old_dd_ids       IN     WSH_UTIL_CORE.Id_Tab_Type
  , x_return_status    OUT NOCOPY VARCHAR2
 );

END GMI_Shipping_Util;

 

/
