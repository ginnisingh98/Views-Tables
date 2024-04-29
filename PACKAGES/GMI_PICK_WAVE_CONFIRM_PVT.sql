--------------------------------------------------------
--  DDL for Package GMI_PICK_WAVE_CONFIRM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_PICK_WAVE_CONFIRM_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMIVPWCS.pls 115.12 2003/04/22 14:15:36 hwahdani ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIVPWCS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private routines For Pick Wave Confirmation   |
 |                                                                         |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-MAY-2000  hverddin        Created                                |
 |     HW BUG#:2296620 Added a new procedure called CHECK_SHIP_SET and     |
 |                     added a new parameter to PICK_CONFIRM called        |
 |                     p_manual_pick for ship sets functionality           |
 |   							                                    |
 +=========================================================================+
  API Name  : GMI_PICK_WAVE_CONFIRM_PVT
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

*/

 /* Following procedure added for Enhancement 2320442 - Lakshmi Swamy */

PROCEDURE BALANCE_NONCTL_INV_TRAN
 (
   p_mo_line_rec                  IN GMI_MOVE_ORDER_GLOBAL.mo_line_rec
 , p_commit                       IN VARCHAR2 DEFAULT FND_API.G_FALSE
 , p_item_id                      IN NUMBER
 , p_whse_code                    IN VARCHAR2
 , p_requested_qty                IN NUMBER
 , p_requested_qty2               IN NUMBER
 , p_delivery_detail_id           IN NUMBER
 , x_available_qty               OUT NOCOPY NUMBER
 , x_available_qty2              OUT NOCOPY NUMBER
 , x_tran_row                    OUT NOCOPY IC_TRAN_PND%ROWTYPE
 , x_return_status               OUT NOCOPY VARCHAR2
 , x_msg_count                   OUT NOCOPY NUMBER
 , x_msg_data                    OUT NOCOPY VARCHAR2
 );

-- HW OPM changes for NOCOPY
-- Added NOCOPY to x_mo_line_tbl

PROCEDURE PICK_CONFIRM
  (
     p_api_version_number      IN  NUMBER
   , p_init_msg_lst            IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_validation_flag         IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
   , p_commit                  IN  VARCHAR2 DEFAULT FND_API.G_FALSE
   , p_delivery_detail_id      IN  NUMBER DEFAULT NULL
   , p_mo_line_tbl             IN  GMI_Move_Order_GLOBAL.mo_line_tbl
   , x_mo_line_tbl             OUT  NOCOPY GMI_Move_Order_GLOBAL.mo_line_tbl
   , x_return_status           OUT  NOCOPY VARCHAR2
   , x_msg_count               OUT  NOCOPY NUMBER
   , x_msg_data                OUT  NOCOPY VARCHAR2
   , p_manual_pick             IN VARCHAR2 DEFAULT NULL
   );


FUNCTION check_required
(
  p_mo_line_rec                 IN GMI_MOVE_ORDER_GLOBAL.mo_line_rec
)
RETURN BOOLEAN;


PROCEDURE GET_OPM_CONVERTED_QTY
(
   p_opm_item_id       IN  NUMBER,
   p_apps_from_uom     IN  VARCHAR2,
   p_apps_to_uom       IN  VARCHAR2,
   p_opm_lot_id        IN  NUMBER,
   p_original_qty      IN  NUMBER,
   x_converted_qty     OUT NOCOPY NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
);
PROCEDURE Check_Shipping_Tolerances
( x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  x_allowed             OUT NOCOPY VARCHAR2,
  x_max_quantity        OUT NOCOPY NUMBER,
  x_max_quantity2       OUT NOCOPY NUMBER,
  p_line_id             IN  NUMBER,
  p_quantity            IN  NUMBER,
  p_quantity2           IN  NUMBER
) ;

--HW BUG#:2296620
PROCEDURE CHECK_SHIP_SET
(
  p_ship_set_id                 IN NUMBER,
  p_manual_pick                 IN VARCHAR2,
  x_return_status               OUT NOCOPY VARCHAR2
) ;

PROCEDURE FORM_PICK_CONFIRM
 (
   p_api_version_number          IN  NUMBER
 , p_init_msg_lst                IN  VARCHAR2 DEFAULT fnd_api.g_false
 , p_validation_flag             IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
 , p_commit                      IN  VARCHAR2 DEFAULT FND_API.G_FALSE
 , p_mo_line_tbl                 IN  GMI_Move_Order_Global.MO_LINE_TBL
 , x_mo_line_tbl                 OUT NOCOPY GMI_Move_Order_Global.MO_LINE_TBL
 , x_return_status               OUT NOCOPY VARCHAR2
 , x_msg_count                   OUT NOCOPY NUMBER
 , x_msg_data                    OUT NOCOPY VARCHAR2
 , p_manual_pick             IN VARCHAR2 DEFAULT NULL
 ) ;

END GMI_PICK_WAVE_CONFIRM_PVT;

 

/
