--------------------------------------------------------
--  DDL for Package GMI_PICK_RELEASE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_PICK_RELEASE_PUB" AUTHID CURRENT_USER AS
/*  $Header: GMIPPKRS.pls 115.7 2002/12/03 21:42:17 jdiiorio ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIPPKRS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public procedures relating to GMI             |
 |     Pick Release process.                                               |
 |                                                                         |
 | - Auto_Detail                                                           |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     27-Apr-2000  odaboval        Created                                |
 |   								            |
 +=========================================================================+
  API Name  : GMI_Pick_Release_PUB
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

*/


PROCEDURE Auto_Detail
  (
     p_api_version                   IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_validation_flag               IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
   , p_commit                        IN  VARCHAR2 DEFAULT FND_API.G_FALSE
   , p_mo_hdr_rec                    IN  GMI_Move_Order_Global.mo_hdr_rec
   , p_mo_line_tbl                   IN  GMI_Move_Order_Global.mo_line_tbl
   , p_grouping_rule_id              IN  NUMBER DEFAULT NULL
   , p_allow_delete                  IN  VARCHAR2 DEFAULT NULL
   , x_pick_release_status           OUT NOCOPY INV_Pick_Release_PUB.INV_Release_Status_Tbl_Type
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

END GMI_Pick_Release_PUB;

 

/
