--------------------------------------------------------
--  DDL for Package GMIVLOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMIVLOT" AUTHID CURRENT_USER AS
/*  $Header: GMIVLOTS.pls 115.9 2002/11/11 20:24:21 jdiiorio ship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIVLOTS.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMIVLOT                                                               |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains private code for the 'Create Lot' Inventory API |
 |                                                                          |
 | CONTENTS                                                                 |
 |    Validate_Lot                                                          |
 |                                                                          |
 | HISTORY                                                                  |
 |    13/May/2000  P.J.Schofield Bug 1294915 Major restructuring for        |
 |                 performance reasons                                      |
 |    11/Nov/2002  J. DiIorio    Bug 2643440 11.5.1J - added nocopy.        |
 |                                                                          |
 +==========================================================================+
*/

PROCEDURE Validate_Lot
( p_api_version      IN  NUMBER
, p_validation_level IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL
, p_lot_rec          IN  GMIGAPI.lot_rec_typ
, p_ic_item_mst_row     IN  ic_item_mst%ROWTYPE
, p_ic_item_cpg_row     IN  ic_item_cpg%ROWTYPE
, x_ic_lots_mst_row  OUT NOCOPY ic_lots_mst%ROWTYPE
, x_ic_lots_cpg_row  OUT NOCOPY ic_lots_cpg%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
);

END GMIVLOT;

 

/
