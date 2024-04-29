--------------------------------------------------------
--  DDL for Package GMI_MOVE_ORDER_HEADER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_MOVE_ORDER_HEADER_PUB" AUTHID CURRENT_USER AS
/*  $Header: GMIPMOHS.pls 115.10 2003/04/18 18:47:46 pupakare ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIPMOHS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public procedures relating to GMI             |
 |     Move Order Header.                                                  |
 |                                                                         |
 | - Process_Move_Order_Header                                             |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     26-Apr-2000  odaboval        Created                                |
 |   								            |
 +=========================================================================+
  API Name  : GMI_Move_Order_Header_PUB
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0
*/

-- HW OPM Added NOCOPY to x_mo_hdr_rec
PROCEDURE Process_Move_Order_Header
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_validation_flag               IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
   , p_commit                        IN  VARCHAR2 DEFAULT FND_API.G_FALSE
   , p_mo_hdr_rec                    IN  GMI_Move_Order_Global.MO_HDR_REC
   , x_mo_hdr_rec                    OUT  NOCOPY GMI_Move_Order_Global.MO_HDR_REC
   , x_return_status                 OUT  NOCOPY VARCHAR2
   , x_msg_count                     OUT  NOCOPY NUMBER
   , x_msg_data                      OUT  NOCOPY VARCHAR2
   );

END GMI_Move_Order_Header_PUB;

 

/
