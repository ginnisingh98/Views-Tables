--------------------------------------------------------
--  DDL for Package GME_MAKE_TO_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_MAKE_TO_ORDER_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMECRBTS.pls 120.0 2007/12/24 19:45:25 srpuri noship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMECRBTS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private utilities  relating to OPM            |
 |     reservation.                                                        |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     Dec,2007  Srinivasulu Created                                   |
 +=========================================================================+
  API Name  : GME_MAKE_TO_ORDER_PVT
  Type      : Private
  Function  : This package contains Private Utilities procedures used to
              Create OPM batches and reservations for Sales Orders
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

*/

G_PKG_NAME  CONSTANT  VARCHAR2(30):='GME_MAKE_TO_ORDER_PVT';

PROCEDURE Create_batch_for_order_line(
--                        errbuf          OUT NOCOPY VARCHAR2
--			  retcode         OUT NOCOPY VARCHAR2
			  p_api_version   IN  NUMBER   := 1.0
			 ,p_init_msg_list IN  VARCHAR2 := fnd_api.g_false
			 ,p_commit        IN  VARCHAR2 := fnd_api.g_false
			 ,p_so_line_id    IN  NUMBER);


PROCEDURE Copy_attachments ( p_so_category_id IN NUMBER
                           , p_so_line_id     IN NUMBER
                           , p_batch_category_id IN NUMBER
                           , p_batch_id       IN NUMBER
                           , x_return_status OUT NOCOPY VARCHAR2);


FUNCTION line_qualifies_for_MTO (
   p_line_id IN NUMBER
)
   RETURN BOOLEAN;

PROCEDURE retrieve_rule
 (
    p_mto_assignments_rec    IN    GME_MTO_RULE_ASSIGNMENTS%ROWTYPE
  , x_mto_rules_rec          OUT   NOCOPY GME_MTO_RULES%ROWTYPE
  , x_mto_assignments_rec    OUT   NOCOPY GME_MTO_RULE_ASSIGNMENTS%ROWTYPE
  , x_return_status          OUT   NOCOPY VARCHAR2
  , x_msg_count              OUT   NOCOPY NUMBER
  , x_msg_data               OUT   NOCOPY VARCHAR2);
END GME_MAKE_TO_ORDER_PVT;

/
