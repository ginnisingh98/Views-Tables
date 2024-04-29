--------------------------------------------------------
--  DDL for Package GMI_TRAN_PND_DB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_TRAN_PND_DB_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMIVPNDS.pls 115.5 2002/10/30 18:30:27 jdiiorio ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |     GMIVPNDS.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private definitions For DML Actions           |
 |     For IC_TRAN_PND                                                     |
 |                                                                         |
 | HISTORY                                                                 |
 |     12-JAN-2000  H.Verdding                                             |
 |     30-OCT-2002  J.DiIorio Bug#2643440 11.5.1J - added nocopy and       |
 |                  changed out to in out.                                 |
 +=========================================================================+
  API Name  : GMI_TRAN_PND_DB_PVT
  Type      : Public
  Function  : This package contains public procedures used to create
              inventory transactions.
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes

*/

/*  Define Procedures And Functions :   */

FUNCTION INSERT_IC_TRAN_PND
(
 p_tran_row           IN IC_TRAN_PND%ROWTYPE,
 x_tran_row           IN OUT NOCOPY IC_TRAN_PND%ROWTYPE
)
RETURN BOOLEAN;

FUNCTION FETCH_IC_TRAN_PND
(
 p_tran_rec           IN   GMI_TRANS_ENGINE_PUB.ictran_rec,
 x_tran_fetch_rec     IN OUT NOCOPY GMI_TRANS_ENGINE_PUB.ictran_rec
)
RETURN BOOLEAN;

FUNCTION DELETE_IC_TRAN_PND
(
 p_tran_row           IN   IC_TRAN_PND%ROWTYPE
)
RETURN BOOLEAN;

FUNCTION UPDATE_IC_TRAN_PND
(
 p_tran_row           IN   IC_TRAN_PND%ROWTYPE
)
RETURN BOOLEAN;

END GMI_TRAN_PND_DB_PVT;

 

/
