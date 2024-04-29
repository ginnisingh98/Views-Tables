--------------------------------------------------------
--  DDL for Package GMIVXFR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMIVXFR" AUTHID CURRENT_USER AS
/* $Header: GMIVXFRS.pls 115.5 2000/11/28 08:58:29 pkm ship      $
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
 |    This package contains private code for the 'Transfers' Inventory API  |
 |                                                                          |
 | CONTENTS                                                                 |
 |    Validate_Transfer                                                     |
 |                                                                          |
 | HISTORY                                                                  |
 |    13/May/2000  P.J.Schofield Bug 1294915 Major restructuring for        |
 |                 performance reasons                                      |
 |                                                                          |
 +==========================================================================+
*/

PROCEDURE Validate_Transfer
( p_api_version      IN  NUMBER
, p_validation_level IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL
, p_xfer_rec         IN  GMIGAPI.xfer_rec_typ
, p_ic_xfer_mst_row  IN  ic_xfer_mst%ROWTYPE
, p_ic_item_mst_row  IN  ic_item_mst%ROWTYPE
, p_ic_item_cpg_row  IN  ic_item_cpg%ROWTYPE
, p_ic_lots_mst_row  IN  ic_lots_mst%ROWTYPE
, p_ic_lots_cpg_row  IN  ic_lots_cpg%ROWTYPE
, x_ic_xfer_mst_row  IN  ic_xfer_mst%ROWTYPE
, x_return_status    OUT VARCHAR2
, x_msg_count        OUT NUMBER
, x_msg_data         OUT VARCHAR2
);

END GMIVXFR;

 

/
