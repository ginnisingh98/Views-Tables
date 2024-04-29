--------------------------------------------------------
--  DDL for Package GML_GME_API_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_GME_API_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMLFGMES.pls 115.2 2004/02/23 20:46:08 lgao noship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIURSVS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private utilities  relating to OPM            |
 |     reservation.                                                        |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     Aug-18-2003  Liping Gao Created                                     |
 +=========================================================================+
  API Name  : GML_GME_API_PVT
  Type      : Private
  Function  : This package contains Private API procedures used to
              OPM reservation for a batch.
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

*/

 G_NOT_TO_DELETE    Number(5) := 0;    -- For lot status not orderable only
 G_NOT_TO_NOTIFY    Number(5) := 0;    -- For lot status not orderable only

 PROCEDURE process_om_reservations
 (
    P_from_batch_id          IN  NUMBER default null
  , P_batch_line_rec         IN  GML_BATCH_OM_UTIL.batch_line_rec
  , P_Gme_trans_row          IN  ic_tran_pnd%rowtype
  , P_batch_action           IN  VARCHAR2
  , x_return_status          OUT NOCOPY VARCHAR2
 );
END GML_GME_API_PVT;

 

/
