--------------------------------------------------------
--  DDL for Package GMIPDX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMIPDX" AUTHID CURRENT_USER AS
/* $Header: GMIPDXS.pls 120.0 2005/05/26 00:14:02 appldev noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIPDXS.pls                                                           |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMIPDX                                                                |
 |                                                                          |
 | TYPE                                                                     |
 |   Public                                                                 |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains the public API for Process / Discrete Transfer  |
 |                                                                          |
 | CONTENTS                                                                 |
 |    Create_transfer_pub                                                   |
 |                                                                          |
 | HISTORY                                                                  |
 |    Created - Jalaj Srivastava                                            |
 |                                                                          |
 |                                                                          |
 +==========================================================================+
*/


/* Function Declaration */
PROCEDURE Create_transfer_pub
( p_api_version          IN               NUMBER
, p_init_msg_list        IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status        OUT NOCOPY       VARCHAR2
, x_msg_count            OUT NOCOPY       NUMBER
, x_msg_data             OUT NOCOPY       VARCHAR2
, p_hdr_rec              IN               GMIVDX.hdr_type
, p_line_rec_tbl         IN               GMIVDX.line_type_tbl
, p_lot_rec_tbl          IN               GMIVDX.lot_type_tbl
, x_hdr_row              OUT NOCOPY       gmi_discrete_transfers%ROWTYPE
, x_line_row_tbl         OUT NOCOPY       GMIVDX.line_row_tbl
, x_lot_row_tbl          OUT NOCOPY       GMIVDX.lot_row_tbl
);

END GMIPDX;

 

/
