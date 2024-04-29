--------------------------------------------------------
--  DDL for Package GMI_MOVE_ORDER_HEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_MOVE_ORDER_HEADER_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMIVMOHS.pls 115.9 2003/04/22 14:05:48 hwahdani ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIVMOHS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private routine relating to GMI               |
 |     Move Order Header.                                                  |
 |                                                                         |
 | - Process_Move_Order_Header                                             |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-MAY-2000  Hverddin        Created                                |
 |   								                               |
 +=========================================================================+
  API Name  : GMI_Move_Order_header_PVT
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0
*/

-- HW OPM changes for NOCOPY
-- Added NOCOPY to x_mo_hdr_rec
PROCEDURE Process_Move_Order_Header
  (
     p_api_version_number       IN  NUMBER
   , p_init_msg_lst             IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_validation_flag          IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
   , p_commit                   IN  VARCHAR2 DEFAULT FND_API.G_FALSE
   , p_mo_hdr_rec               IN  GMI_Move_Order_Global.MO_HDR_REC
   , x_mo_hdr_rec               OUT NOCOPY GMI_Move_Order_Global.MO_HDR_REC
   , x_return_status            OUT NOCOPY VARCHAR2
   , x_msg_count                OUT NOCOPY NUMBER
   , x_msg_data                 OUT NOCOPY VARCHAR2
   );


FUNCTION check_required
  (
    p_mo_hdr_rec			  IN  GMI_Move_Order_Global.MO_HDR_REC
  ) RETURN BOOLEAN;

END GMI_Move_Order_header_PVT;

 

/
