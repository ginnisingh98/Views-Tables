--------------------------------------------------------
--  DDL for Package GMI_RESERVATION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_RESERVATION_UTIL" AUTHID CURRENT_USER AS
/*  $Header: GMIURSVS.pls 115.35 2004/02/16 19:48:45 pkanetka ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIURSVS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private utilities  relating to OPM            |
 |     reservation.                                                        |
 |                                                                         |
 | - Check_Missing                                                         |
 | - Validation_for_Query                                                  |
 | - Validation_Before_Allocate                                            |
 | - Get_Default_Lot                                                       |
 | - Create_Default_Lot                                                    |
 | - Get_Allocation                                                        |
 | - Get_OPMUOM_from_AppsUOM                                               |
 | - Get_AppsUOM_from_OPMUOM                                               |
 | - Get_Org_from_SO_Line                                                  |
 | - Get_OPM_item_from_Apps                                                |
 | - Reallocate                                                            |
 | - Transfer_Msg_Stack	moved to OE_MSG_PUB OEXUMSGS,B.pls          |
 | - Get_DefaultLot_from_ItemCtl                                           |
 | - PrintLn                                                               |
 | - Validation_ictran_rec                                                 |
 | - Set_Pick_Lots                                                         |
 | - Create_Empty_Default_Lot                                              |
 | - Default_Lot_Exist                                                     |
 |                                                                         |
 | HISTORY                                                                 |
 |     07-MAR-2000  odaboval Created                                       |
 |     27-APR-2000  mpetrosi Removed Transfer_Msg_Stack to OE_MSG_PUB      |
 |     13-SEP-2002  HW - BUG#:2536589 Added 2 new procedures for Bill-Only |
 |                       functionality. Update_opm_trxns and find_lot_id   |
 |     Oct, 2002    HW added new procedures to support WSH.H Harmonization |
 |                  projects. Validate_lot_number and line_allocated       |
 |     Nov, 2002    HW BUG#:2654963 Added p_delivery_detail_id to proc     |
 |                  line_allocated                                         |
 |     Nov, 2002     HW bug#2677054 - WSH.I project                        |
 +=========================================================================+
  API Name  : GMI_Reservation_Util
  Type      : Private
  Function  : This package contains Private Utilities procedures used to
              OPM reservation process.
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

*/

/*
================================================================================
  Define the ic_tran_pnd record and table and global memory table
================================================================================
*/
G_DEFAULT_LOCT  CONSTANT  VARCHAR2(16):= FND_PROFILE.VALUE('IC$DEFAULT_LOCT');

/*  SUBTYPE transaction_record IS ic_tran_pnd%ROWTYPE;  */

TYPE ic_item_mst_rec IS RECORD
   ( item_id           ic_item_mst.item_id%TYPE
   , inventory_item_id mtl_system_items.inventory_item_id%TYPE
   , item_no           ic_item_mst.item_no%TYPE
   , whse_item_id      ic_item_mst.whse_item_id%TYPE
   , item_um           ic_item_mst.item_um%TYPE
   , item_um2          ic_item_mst.item_um2%TYPE
   , dualum_ind        ic_item_mst.dualum_ind%TYPE
   , alloc_class       ic_item_mst.alloc_class%TYPE
   , noninv_ind        ic_item_mst.noninv_ind%TYPE
   , deviation_lo      ic_item_mst.deviation_lo%TYPE
   , deviation_hi      ic_item_mst.deviation_lo%TYPE
   , grade_ctl         ic_item_mst.grade_ctl%TYPE
   , inactive_ind      ic_item_mst.inactive_ind%TYPE
   , lot_ctl           ic_item_mst.lot_ctl%TYPE
   , lot_indivisible   ic_item_mst.lot_indivisible%TYPE
   , loct_ctl          ic_item_mst.loct_ctl%TYPE);


TYPE l_ic_tran_rec_tbl IS TABLE OF GMI_TRANS_ENGINE_PUB.ictran_rec
                     INDEX BY BINARY_INTEGER;

ic_tran_rec_tbl l_ic_tran_rec_tbl;


PROCEDURE Check_Missing
   ( p_event                         IN  VARCHAR2
   , p_rec_to_check                  IN  INV_Reservation_Global.mtl_reservation_rec_type
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

PROCEDURE Validation_for_Query
   ( p_query_input                   IN  inv_reservation_global.mtl_reservation_rec_type
   , x_opm_um                        OUT NOCOPY VARCHAR2
   , x_apps_um                       OUT NOCOPY VARCHAR2
   , x_ic_item_mst_rec               OUT NOCOPY GMI_Reservation_Util.ic_item_mst_rec
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , x_error_code                    OUT NOCOPY NUMBER /* Bug 2168710 - Added parameter */
   );

PROCEDURE Validation_before_Allocate
   ( p_mtl_rsv_rec       IN  INV_Reservation_Global.mtl_reservation_rec_type
   , x_allocation_rec    OUT NOCOPY GMI_Auto_Allocate_PUB.gmi_allocation_rec
   , x_ic_item_mst_rec   OUT NOCOPY GMI_Reservation_Util.ic_item_mst_rec
   , x_orgn_code         OUT NOCOPY VARCHAR2
   , x_return_status     OUT NOCOPY VARCHAR2
   , x_msg_count         OUT NOCOPY NUMBER
   , x_msg_data          OUT NOCOPY VARCHAR2
   );

PROCEDURE Get_Default_Lot
   ( x_ic_tran_pnd_index             OUT NOCOPY BINARY_INTEGER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

PROCEDURE Create_Default_Lot
   ( p_allocation_rec                IN  GMI_AUTO_ALLOCATE_PUB.gmi_allocation_rec
   , p_ic_item_mst_rec               IN  GMI_Reservation_Util.ic_item_mst_rec
   , p_orgn_code                     IN  VARCHAR2
   , p_trans_id                      IN  NUMBER DEFAULT NULL
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

PROCEDURE Get_Allocation
   ( p_trans_id                      IN  NUMBER
   , x_ic_tran_pnd_index             OUT NOCOPY BINARY_INTEGER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

PROCEDURE Get_OPMUOM_from_AppsUOM(
     p_Apps_UOM                      IN  VARCHAR2
   , x_OPM_UOM                       OUT NOCOPY VARCHAR2
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

PROCEDURE Get_AppsUOM_from_OPMUOM(
     p_OPM_UOM                       IN  VARCHAR2
   , x_Apps_UOM                      OUT NOCOPY VARCHAR2
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

PROCEDURE Get_Org_from_SO_Line
   ( p_oe_line_id                    IN  NUMBER
   , x_organization_id               OUT NOCOPY NUMBER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

PROCEDURE Get_OPM_item_from_Apps
   ( p_organization_id               IN  NUMBER
   , p_inventory_item_id             IN  NUMBER
   , x_ic_item_mst_rec               OUT NOCOPY GMI_Reservation_Util.ic_item_mst_rec
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

PROCEDURE Reallocate
   ( p_query_input                   IN  inv_reservation_global.mtl_reservation_rec_type
   , x_allocated_trans               OUT NOCOPY NUMBER
   , x_allocated_qty                 OUT NOCOPY NUMBER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

PROCEDURE Get_DefaultLot_from_ItemCtl
   ( p_organization_id               IN  NUMBER
   , p_inventory_item_id             IN  NUMBER
   , x_default_lot_index             OUT NOCOPY NUMBER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

PROCEDURE PrintLn
   ( p_msg                           IN  VARCHAR2
   , p_file_name                     IN  VARCHAR2 DEFAULT '0'
   );

PROCEDURE Validation_ictran_rec
   ( p_ic_tran_rec                   IN  GMI_TRANS_ENGINE_PUB.ictran_rec
   , x_ic_tran_rec                   OUT NOCOPY GMI_TRANS_ENGINE_PUB.ictran_rec
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

PROCEDURE Set_Pick_Lots
   ( p_ic_tran_rec                   IN OUT NOCOPY GMI_TRANS_ENGINE_PUB.ictran_rec
   , p_mo_line_id                    IN NUMBER
   , p_commit			     IN VARCHAR2 DEFAULT FND_API.G_TRUE
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

PROCEDURE Create_Empty_Default_Lot
   ( p_ic_tran_rec                   IN  GMI_TRANS_ENGINE_PUB.ictran_rec
   , p_organization_id               IN  NUMBER
   , x_default_lot_index             OUT NOCOPY BINARY_INTEGER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

PROCEDURE Default_Lot_Exist
   ( p_line_id                       IN  NUMBER
   , p_item_id                       IN  NUMBER
   , x_trans_id                      OUT NOCOPY NUMBER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

Procedure create_dflt_lot_from_scratch
   ( p_whse_code                     IN VARCHAR2
   , p_line_id                       IN NUMBER
   , p_item_id                       IN NUMBER
   , p_qty1                          IN NUMBER
   , p_qty2                          IN NUMBER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

Procedure create_transaction_for_rcv
   ( p_whse_code                     IN VARCHAR2
   , p_transaction_id                IN NUMBER
   , p_line_id                       IN NUMBER
   , p_item_id                       IN NUMBER
   , p_lot_id                        IN NUMBER
   , p_location                      IN VARCHAR2
   , p_qty1                          IN NUMBER
   , p_qty2                          IN NUMBER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) ;

PROCEDURE balance_default_lot
   ( p_ic_default_rec                IN  GMI_TRANS_ENGINE_PUB.ictran_rec
   , p_opm_item_id                   IN  NUMBER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

Procedure get_OPM_account ( v_dest_org_id    IN NUMBER,
                           v_apps_item_id    IN NUMBER,
                           v_vendor_site_id  IN number,
                           x_cc_id           OUT NOCOPY NUMBER,
                           x_ac_id           OUT NOCOPY NUMBER) ;

Procedure check_OPM_trans_for_so_line
        ( p_so_line_id                IN NUMBER,
          p_new_delivery_detail_id    IN NUMBER,
          x_return_status             OUT NOCOPY VARCHAR2) ;

FUNCTION Get_Opm_converted_qty
(
   p_apps_item_id      IN NUMBER,
   p_organization_id   IN NUMBER,
   p_apps_from_uom     IN VARCHAR2,
   p_apps_to_uom       IN VARCHAR2,
   p_original_qty      IN  NUMBER,
   p_lot_id            IN  NUMBER DEFAULT 0
) RETURN NUMBER;

Procedure query_staged_flag
 ( x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   x_staged_flag       OUT NOCOPY VARCHAR2,
   p_reservation_id    IN NUMBER);

Procedure find_default_lot
 ( x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   x_reservation_id    OUT NOCOPY VARCHAR2,
   p_line_id           IN NUMBER) ;
procedure check_lot_loct_ctl (
    p_inventory_item_id             IN NUMBER
   ,p_mtl_organization_id           IN NUMBER
   ,x_ctl_ind                       OUT NOCOPY VARCHAR2) ;

PROCEDURE split_trans_from_om
   ( p_old_source_line_id      IN  NUMBER,
     p_new_source_line_id      IN  NUMBER,
     p_qty_to_split            IN  NUMBER,
     p_qty2_to_split           IN  NUMBER,
     x_return_status           OUT NOCOPY VARCHAR2,
     x_msg_count               OUT NOCOPY NUMBER,
     x_msg_data                OUT NOCOPY VARCHAR2);


-- HW OPM BUG#:2536589 New procedure
PROCEDURE update_opm_trxns(
     p_trans_id                IN NUMBER,
     p_inventory_item_id       IN NUMBER,
     p_organization_id         IN NUMBER,
     x_return_status           OUT NOCOPY VARCHAR2,
     x_msg_count               OUT NOCOPY NUMBER,
     x_msg_data                OUT NOCOPY VARCHAR2);
-- HW OPM BUG#:2536589 New procedure
PROCEDURE find_lot_id (
     p_trans_id                IN NUMBER,
     x_return_status           OUT NOCOPY VARCHAR2,
     x_msg_count               OUT NOCOPY NUMBER,
     x_msg_data                OUT NOCOPY VARCHAR2);

-- HW OPM -added for Harmonization project for WSH.I
PROCEDURE validate_lot_number (
   p_inventory_item_id                   IN NUMBER,
   p_organization_id           IN NUMBER,
   p_lot_number                IN VARCHAR2,
   x_return_status             OUT NOCOPY VARCHAR2);


-- HW BUG#:2654963 Added p_delivery_detail_id
PROCEDURE line_allocated (
   p_inventory_item_id      IN NUMBER,
   p_organization_id        IN NUMBER,
   p_line_id                IN NUMBER,
   p_delivery_detail_id     IN NUMBER DEFAULT NULL,
   check_status             OUT NOCOPY NUMBER,
   x_return_status          OUT NOCOPY VARCHAR2);

-- HW Added for bug#2677054 - WSH.I project
   PROCEDURE is_line_allocated (
   p_inventory_item_id      IN NUMBER,
   p_organization_id        IN NUMBER,
   p_delivery_detail_id     IN NUMBER DEFAULT NULL,
   check_status             OUT NOCOPY NUMBER,
   x_return_status          OUT NOCOPY VARCHAR2);

-- PK Added for Bug 3055126 - 11.5.10 WSH.J
PROCEDURE validate_opm_quantities(
   p_inventory_item_id IN NUMBER,
   p_organization_id   IN NUMBER,
   p_quantity          IN OUT NOCOPY NUMBER,
   p_quantity2         IN OUT NOCOPY NUMBER,
   p_lot_number        IN VARCHAR2,
   p_sublot_number     IN VARCHAR2,
   x_check_status      OUT NOCOPY NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2);

END GMI_Reservation_Util;


 

/
