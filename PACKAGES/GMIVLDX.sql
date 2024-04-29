--------------------------------------------------------
--  DDL for Package GMIVLDX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMIVLDX" AUTHID CURRENT_USER AS
/* $Header: GMIVLDXS.pls 120.0 2005/05/25 15:46:06 appldev noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIVLDXS.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMIVLDX                                                               |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains the private APIs for                            |
 |    creating lots in OPM for Process / Discrete Transfer                  |
 |                                                                          |
 | CONTENTS                                                                 |
 |    create_lot_in_opm                                                     |
 |    verify_lot_uniqueness_in_odm                                          |
 |                                                                          |
 | HISTORY                                                                  |
 |    Created - Jalaj Srivastava                                            |
 |                                                                          |
 |                                                                          |
 +==========================================================================+
*/


PROCEDURE create_lot_in_opm
( p_api_version          IN              NUMBER
, p_init_msg_list        IN              VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN              VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN              NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status        OUT NOCOPY      VARCHAR2
, x_msg_count            OUT NOCOPY      NUMBER
, x_msg_data             OUT NOCOPY      VARCHAR2
, p_hdr_rec              IN              GMIVDX.hdr_type
, p_line_rec             IN              GMIVDX.line_type
, p_lot_rec              IN              GMIVDX.lot_type
, x_ic_lots_mst_row      OUT NOCOPY      ic_lots_mst%ROWTYPE
);


PROCEDURE verify_lot_uniqueness_in_odm
( p_api_version          IN              NUMBER
, p_init_msg_list        IN              VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN              VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN              NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status        OUT NOCOPY      VARCHAR2
, x_msg_count            OUT NOCOPY      NUMBER
, x_msg_data             OUT NOCOPY      VARCHAR2
, p_odm_item_id          IN              gmi_discrete_transfer_lines.odm_item_id%TYPE
, p_odm_lot_number       IN              gmi_discrete_transfer_lines.odm_lot_number%TYPE
);



END GMIVLDX;

 

/
