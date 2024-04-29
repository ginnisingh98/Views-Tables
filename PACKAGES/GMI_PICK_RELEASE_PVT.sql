--------------------------------------------------------
--  DDL for Package GMI_PICK_RELEASE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_PICK_RELEASE_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMIVPKRS.pls 120.0 2005/05/26 00:17:18 appldev noship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIVPKRS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public procedures relating to GMI             |
 |     Pick Release process.                                               |
 |                                                                         |
 | - Process_Line                                                          |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     03-May-2000  odaboval        Created                                |
 |   								            |
 +=========================================================================+
  API Name  : GMI_Pick_Release_PVT
  Type      : Global
 -
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

*/


PROCEDURE Process_Line
  (
     p_api_version                   IN  NUMBER
   , p_validation_flag               IN  VARCHAR2 DEFAULT FND_API.G_TRUE
   , p_commit                        IN  VARCHAR2 DEFAULT FND_API.G_FALSE
   , p_mo_hdr_rec                    IN  GMI_Move_Order_Global.mo_hdr_rec
   , p_mo_line_rec                   IN  GMI_Move_Order_Global.mo_line_rec
   , p_grouping_rule_id              IN  NUMBER
   , p_print_mode                    IN  VARCHAR2
   , p_allow_partial_pick            IN  VARCHAR2 DEFAULT FND_API.G_TRUE
   , p_allow_delete                  IN  VARCHAR2 DEFAULT NULL
   , x_detail_rec_count              OUT NOCOPY NUMBER
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   );

END GMI_Pick_Release_PVT;

 

/
