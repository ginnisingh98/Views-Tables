--------------------------------------------------------
--  DDL for Package GMI_SUMM_INV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_SUMM_INV_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMIVBUSS.pls 115.6 2002/11/05 15:01:36 jdiiorio ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |     GMIVBUSS.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private definitions For Business Layer        |
 |     Logic For IC_SUMM_INV                                               |
 |                                                                         |
 | HISTORY                                                                 |
 |     12-JAN-2000  H.Verdding                                             |
 |     05-NOV-2002  J.DiIorio BUG#2643440 11.5.1J - added nocopy           |
 +=========================================================================+
  API Name  : GMI_SUMM_INV_PVT
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

PROCEDURE PENDING
(
 p_tran_rec        IN  GMI_TRANS_ENGINE_PUB.ictran_rec,
 x_return_status   OUT NOCOPY VARCHAR2
);

PROCEDURE COMPLETED
(
 p_tran_rec        IN  GMI_TRANS_ENGINE_PUB.ictran_rec,
 x_return_status   OUT NOCOPY VARCHAR2
);

END GMI_SUMM_INV_PVT;

 

/
