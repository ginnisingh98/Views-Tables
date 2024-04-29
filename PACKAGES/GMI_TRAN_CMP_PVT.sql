--------------------------------------------------------
--  DDL for Package GMI_TRAN_CMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_TRAN_CMP_PVT" AUTHID CURRENT_USER AS
/* $Header: GMIVCMPS.pls 115.9 2002/10/29 18:27:32 jdiiorio ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |     GMIVCMPS.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private definitions For DML Actions           |
 |     For IC_TRAN_CMP                                                     |
 |                                                                         |
 | HISTORY                                                                 |
 |     26-May-2000 P.J.Schofield                                           |
 |                 Cloaned from GMICPNDS.pls                               |
 |     29-Oct-2002 J.DiIorio                                               |
 |                 Bug#2643440 - 11.5.1J - Added nocopy.                   |
 +=========================================================================+
  API Name  : GMI_TRAN_CMP_PVT
  Type      : Public
  Function  : This package contains public procedures used to create
              inventory transactions in IC_TRAN_CMP.
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes

*/

/*  Define Procedures And Functions :  */

FUNCTION INSERT_IC_TRAN_CMP
(
 p_tran_row           IN  IC_TRAN_CMP%ROWTYPE,
 x_tran_row           OUT NOCOPY IC_TRAN_CMP%ROWTYPE
)
RETURN BOOLEAN;

FUNCTION FETCH_IC_TRAN_CMP
(
 p_tran_rec           IN   GMI_TRANS_ENGINE_PUB.ictran_rec,
 x_tran_fetch_rec     OUT  NOCOPY GMI_TRANS_ENGINE_PUB.ictran_rec
)
RETURN BOOLEAN;

END GMI_TRAN_CMP_PVT;

 

/
