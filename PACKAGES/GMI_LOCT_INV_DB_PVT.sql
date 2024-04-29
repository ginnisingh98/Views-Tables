--------------------------------------------------------
--  DDL for Package GMI_LOCT_INV_DB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_LOCT_INV_DB_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMIVLOCS.pls 115.6 2003/03/27 05:01:37 gmangari ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |     GMIVLOCS.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private definitions For DML Actions           |
 |     For IC_LOCT_INV                                                     |
 |                                                                         |
 | HISTORY                                                                 |
 |     12-JAN-2000  H.Verdding                                             |
 +=========================================================================+
  API Name  : GMI_LOCT_INV_DB_PVT
  Type      : Public
  Function  : This package contains private procedures used to create
              IC_LOCT_INV transactions
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes
*/


/*  Define Procedures And Functions :   */

FUNCTION UPDATE_IC_LOCT_INV
(
  p_loct_inv       IN IC_LOCT_INV%ROWTYPE,
  p_status_updated IN NUMBER,
  p_qty_updated    IN NUMBER
)
RETURN BOOLEAN;

FUNCTION INSERT_IC_LOCT_INV
(
   p_loct_inv IN IC_LOCT_INV%ROWTYPE
)
RETURN BOOLEAN;

END GMI_LOCT_INV_DB_PVT;

 

/
