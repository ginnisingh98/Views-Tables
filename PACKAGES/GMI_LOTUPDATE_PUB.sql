--------------------------------------------------------
--  DDL for Package GMI_LOTUPDATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_LOTUPDATE_PUB" AUTHID CURRENT_USER AS
/* $Header: GMIPLALS.pls 120.0 2005/05/25 15:55:45 appldev noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIPLALS.pls                                                          |
 |                                                                          |
 | TYPE                                                                     |
 |   Public                                                                 |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMIPLALS                                                              |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains the public APIs for updating the descriptive    |
 |    columns in lot master                                                 |
 |                                                                          |
 | Contents                                                                 |
 |    update_lot_dff , update_lot                                                       |
 |                                                                          |
 | HISTORY                                                                  |
 |    Created - Jatinder Gogna - 2/5/04                                     |
 |                                                                          |
 |                                                                          |
 +==========================================================================+
*/

PROCEDURE update_lot_dff
( p_api_version                 IN               NUMBER
, p_init_msg_list               IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit                      IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level            IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status               OUT NOCOPY       VARCHAR2
, x_msg_count                   OUT NOCOPY       NUMBER
, x_msg_data                    OUT NOCOPY       VARCHAR2
, p_lot_rec                     IN               ic_lots_mst%ROWTYPE
);


PROCEDURE update_lot
( p_api_version                 IN               NUMBER
, p_init_msg_list               IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit                      IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level            IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status               OUT NOCOPY       VARCHAR2
, x_msg_count                   OUT NOCOPY       NUMBER
, x_msg_data                    OUT NOCOPY       VARCHAR2
, p_lot_rec                     IN              ic_lots_mst%ROWTYPE
);

END GMI_LotUpdate_PUB;

 

/
