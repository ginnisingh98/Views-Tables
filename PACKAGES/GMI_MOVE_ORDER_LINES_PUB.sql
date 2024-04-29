--------------------------------------------------------
--  DDL for Package GMI_MOVE_ORDER_LINES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_MOVE_ORDER_LINES_PUB" AUTHID CURRENT_USER AS
/*  $Header: GMIPMOLS.pls 115.11 2003/04/22 13:08:02 hwahdani ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIPMOLS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public procedures relating to GMI             |
 |     Move Order line.                                                   |
 |                                                                         |
 | - Process_Move_Order_line                                              |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     26-Apr-2000  odaboval        Created                                |
 |   								            |
 +=========================================================================+
  API Name  : GMI_Move_Order_lines_PUB
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

*/

-- HW OPM changes for NOCOPY
-- Added NOCOPY for x_mo_line_tbl
PROCEDURE Process_Move_Order_lines
  (
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_validation_flag           IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
   , p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE
   , p_mo_line_tbl               IN  GMI_Move_Order_GLOBAL.mo_line_tbl
   , x_mo_line_tbl               OUT NOCOPY GMI_Move_Order_GLOBAL.mo_line_tbl
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   );

END GMI_Move_Order_lines_PUB;

 

/
