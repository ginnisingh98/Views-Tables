--------------------------------------------------------
--  DDL for Package GMI_SUMM_INV_DB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_SUMM_INV_DB_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMIVSUMS.pls 115.4 2000/11/28 08:58:26 pkm ship      $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |     GMIVSUMS.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private definitions For DML Actions           |
 |     For IC_SUMM_INV                                                     |
 |                                                                         |
 | HISTORY                                                                 |
 |     12-JAN-2000  H.Verdding                                             |
 +=========================================================================+
  API Name  : GMI_SUMM_INV_DB_PVT
  Type      : Public
  Function  : This package contains private procedures used to create
              IC_SUMM_INV transactions
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes
*/


/*  Define Procedures And Functions :  */

FUNCTION UPDATE_IC_SUMM_INV
(
p_summ_inv IN IC_SUMM_INV%ROWTYPE
)
RETURN BOOLEAN;

FUNCTION INSERT_IC_SUMM_INV
(
p_summ_inv IN IC_SUMM_INV%ROWTYPE
)
RETURN BOOLEAN;

/*  Should This be In HERE    */

FUNCTION GET_LOT_ATTRIBUTES
(
p_lot_status IN  VARCHAR2,
x_lots_sts   OUT IC_LOTS_STS%ROWTYPE
)
RETURN BOOLEAN;


END GMI_SUMM_INV_DB_PVT;

 

/
