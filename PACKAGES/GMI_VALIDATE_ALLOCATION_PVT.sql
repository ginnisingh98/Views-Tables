--------------------------------------------------------
--  DDL for Package GMI_VALIDATE_ALLOCATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_VALIDATE_ALLOCATION_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMIVALVS.pls 120.0 2005/05/25 16:08:26 appldev noship $
 +=========================================================================+
 |                Copyright (c) 1999 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |     GMIVALVS.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private procedures to validate the inputs     |
 |     supplied to the auto allocation package.                            |
 |                                                                         |
 | HISTORY                                                                 |
 |     15-DEC-1999  K.Y.Hunt                                               |
 +=========================================================================+
  API Name  : GMI_VALIDATE_ALLOCATION_PVT
  Type      : Private
  Function  : This package contains private procedures validating input
              data supplied to the OPM auto allocation engine.
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes

*/

PROCEDURE VALIDATE_INPUT_PARMS
( p_allocation_rec     IN  GMI_AUTO_ALLOCATE_PUB.gmi_allocation_rec
, x_ic_item_mst_rec    OUT NOCOPY ic_item_mst%ROWTYPE
, x_ic_whse_mst_rec    OUT NOCOPY ic_whse_mst%ROWTYPE
, x_allocation_rec     OUT NOCOPY GMI_AUTO_ALLOCATE_PUB.gmi_allocation_rec
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
);

FUNCTION VALIDATE_WHO
( p_user_id            IN  FND_USER.USER_ID%TYPE
, p_user_name          IN  FND_USER.USER_NAME%TYPE
)
RETURN BOOLEAN;
END GMI_VALIDATE_ALLOCATION_PVT;

 

/
