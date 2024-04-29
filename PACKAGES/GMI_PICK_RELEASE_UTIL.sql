--------------------------------------------------------
--  DDL for Package GMI_PICK_RELEASE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_PICK_RELEASE_UTIL" AUTHID CURRENT_USER AS
/*  $Header: GMIUPKRS.pls 115.9 2004/01/12 21:34:28 lswamy ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIUPKRS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains Utilities procedures relating to GMI          |
 |     Pick Release process.                                               |
 |                                                                         |
 | - Get_Delivery_Details                                                  |
 | - Create_Pick_Slip_and_Print                                            |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     04-May-2000  odaboval        Created                                |
 |   								            |
 +=========================================================================+
  API Name  : GMI_Pick_Release_Util
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

*/


PROCEDURE Get_Delivery_Details
   ( p_mo_line_id                    IN  NUMBER
   , x_inv_delivery_details          OUT NOCOPY WSH_INV_DELIVERY_DETAILS_V%ROWTYPE
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

-- Bug3294071 Getting Rid of this one.
/* The following procedure is created for enhancement 1928979 */
/* PROCEDURE Create_Pick_Slip_and_Print
   ( p_mo_line_rec                   IN  GMI_Move_Order_Global.mo_line_rec
   , p_inv_delivery_details          IN  WSH_INV_DELIVERY_DETAILS_V%ROWTYPE
   , p_pick_slip_mode                IN  VARCHAR2
   , p_grouping_rule_id              IN  NUMBER
   , p_allow_partial_pick            IN  VARCHAR2 DEFAULT FND_API.G_TRUE
   , p_pick_slip_number              OUT NOCOPY NUMBER
   , p_sub_code                      IN  VARCHAR2
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   ) ; */

/* The following procedure is created for enhancement 1928979 */
PROCEDURE Create_Manual_Alloc_Pickslip
   ( p_organization_id       IN NUMBER
   , p_line_id               IN NUMBER
   , x_return_status        OUT NOCOPY VARCHAR2
   , x_msg_count            OUT NOCOPY NUMBER
   , x_msg_data             OUT NOCOPY VARCHAR2
   , x_pick_slip_number     OUT NOCOPY NUMBER
   );

PROCEDURE Create_Pick_Slip_and_Print
   ( p_mo_line_rec                   IN  GMI_Move_Order_Global.mo_line_rec
   , p_inv_delivery_details          IN  WSH_INV_DELIVERY_DETAILS_V%ROWTYPE
   , p_pick_slip_mode                IN  VARCHAR2
   , p_grouping_rule_id              IN  NUMBER
   , p_allow_partial_pick            IN  VARCHAR2 DEFAULT FND_API.G_TRUE
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

-- Bug3294071 (following procedure added)
PROCEDURE UPDATE_TXN_WITH_PICK_SLIP
   (   p_mo_line_rec                   IN  GMI_Move_Order_Global.mo_line_rec
     , p_pick_slip_number              IN  NUMBER
     , x_return_status                 OUT NOCOPY VARCHAR2
     , x_msg_count                     OUT NOCOPY NUMBER
     , x_msg_data                      OUT NOCOPY VARCHAR2
   );

END GMI_Pick_Release_Util;

 

/
