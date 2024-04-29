--------------------------------------------------------
--  DDL for Package GMI_ALLOCATION_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_ALLOCATION_RULES_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMIVALRS.pls 120.0 2005/05/25 16:05:39 appldev noship $
 +=========================================================================+
 |                Copyright (c) 1998 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |     GMIVALRS.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private procedures to retrieve the rules      |
 |     established for auto-allocation.                                    |
 |                                                                         |
 | HISTORY                                                                 |
 |     15-DEC-1999  K.Y.Hunt                                               |
 +=========================================================================+
  API Name  : GMI_ALLOCATION_RULES_PVT
  Type      : Private
  Function  : This package contains private procedures controling auto-
              allocation of OPM inventory against order/shipment lines.
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes
*/


-- HW BUG#:2643440, removed intitalization of G_MISS_XXX
-- from p_co_code,p_cust_no, p_alloc_class,p_of_cust_id,
-- p_ship_to_org_id,p_org_id.
PROCEDURE GET_ALLOCATION_PARMS
( p_co_code            IN  OP_CUST_MST.CO_CODE%TYPE default NULL
, p_cust_no            IN  OP_CUST_MST.CUST_NO%TYPE default NULL
, p_alloc_class        IN  IC_ITEM_MST.ALLOC_CLASS%TYPE default NULL
, p_of_cust_id         IN  NUMBER default NULL
, p_ship_to_org_id     IN  NUMBER default NULL
, p_org_id             IN  NUMBER default NULL
, x_return_status      OUT NOCOPY VARCHAR2
, x_op_alot_prm        OUT NOCOPY op_alot_prm%ROWTYPE
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
);

PROCEDURE GET_DEFAULT_PARMS
( x_op_alot_prm        OUT NOCOPY op_alot_prm%ROWTYPE);

END GMI_ALLOCATION_RULES_PVT;

 

/
