--------------------------------------------------------
--  DDL for Package GMI_MOVE_ORDER_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_MOVE_ORDER_LINES_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMIVMOLS.pls 115.9 2003/04/22 14:13:05 hwahdani ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIVMOLS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private routines For GMI Move Order lines     |
 |                                                                         |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-MAY-2000  hverddin        Created                                |
 |     Dec. 5th, 2002 HW added NOCOPY to OUT parameters                    |
 +=========================================================================+
  API Name  : GMI_Move_Order_Lines_PVT
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0


*/

PROCEDURE Process_Move_Order_lines
  (
     p_api_version_number      IN  NUMBER
   , p_init_msg_lst            IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_validation_flag         IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
   , p_commit                  IN  VARCHAR2 DEFAULT FND_API.G_FALSE
   , p_mo_line_tbl             IN  GMI_Move_Order_GLOBAL.mo_line_tbl
   , x_mo_line_tbl             OUT NOCOPY GMI_Move_Order_GLOBAL.mo_line_tbl
   , x_return_status           OUT NOCOPY VARCHAR2
   , x_msg_count               OUT NOCOPY NUMBER
   , x_msg_data                OUT NOCOPY VARCHAR2
   );


FUNCTION check_required
(
  p_mo_line_rec                 IN GMI_MOVE_ORDER_GLOBAL.mo_line_rec
)
RETURN BOOLEAN;

END GMI_Move_Order_Lines_PVT;

 

/
