--------------------------------------------------------
--  DDL for Package GMI_PICK_WAVE_CONFIRM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_PICK_WAVE_CONFIRM_PUB" AUTHID CURRENT_USER AS
/*  $Header: GMIPPWCS.pls 115.10 2003/04/22 13:21:29 hwahdani ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIPPWCS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public procedures relating to GMI             |
 |     Pick Wave Confirmation Logic                                        |
 |                                                                         |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     22-May-2000  hverddin        Created                                |
 |     HW BUG#:2296620 Added a new parameter to PICK_CONFIRM called        |
 |                     p_manual_pick for ship sets functionality           |
 +=========================================================================+
  API Name  : GMI_PICK_WAVE_CONFIRM_PUB
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

*/

-- HW BUG#:2296620 Added a new parameter p_manual_pick for ship sets functionality
-- HW OPM changes for NOCOPY
-- Added NOCOPY to x_mo_line_tbl
PROCEDURE Pick_Confirm
  (
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_validation_flag           IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
   , p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE
   , p_mo_line_tbl               IN  GMI_Move_Order_GLOBAL.mo_line_tbl
   , x_mo_line_tbl               OUT  NOCOPY GMI_Move_Order_GLOBAL.mo_line_tbl
   , x_return_status             OUT  NOCOPY VARCHAR2
   , x_msg_count                 OUT  NOCOPY NUMBER
   , x_msg_data                  OUT  NOCOPY VARCHAR2
   , p_manual_pick               IN VARCHAR2 DEFAULT NULL
   );

END GMI_PICK_WAVE_CONFIRM_PUB;

 

/
