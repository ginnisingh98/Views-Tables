--------------------------------------------------------
--  DDL for Package GMI_LOCT_INV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_LOCT_INV_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMIVBULS.pls 115.6 2002/10/28 15:35:38 jdiiorio ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |     GMIVBULS.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private definitions For Business Layer        |
 |     Logic For IC_LOCT_INV                                               |
 |                                                                         |
 | HISTORY                                                                 |
 |     12-JAN-2000  H.Verdding                                             |
 |     28-OCT-2002  J.DiIorio 11.5.1J Bug#2643440 - added nocopy.          |
 +=========================================================================+
  API Name  : GMI_LOCT_INV_PVT
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

/* Define Procedures And Functions :  */

PROCEDURE UPDATING_IC_LOCT_INV
(
 p_tran_rec           IN  GMI_TRANS_ENGINE_PUB.ictran_rec,
 x_return_status      OUT NOCOPY VARCHAR2
);


END GMI_LOCT_INV_PVT;

 

/
