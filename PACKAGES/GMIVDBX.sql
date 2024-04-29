--------------------------------------------------------
--  DDL for Package GMIVDBX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMIVDBX" AUTHID CURRENT_USER AS
/* $Header: GMIVDBXS.pls 120.0 2005/05/25 16:02:42 appldev noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIVDBXS.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMIVDBX                                                               |
 |                                                                          |
 | TYPE                                                                     |
 |   Private                                                                |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains the private database insert routines            |
 |    for Process / Discrete Transfer only.                                 |
 |                                                                          |
 | CONTENTS                                                                 |
 |   header_insert                                                          |
 |   line_insert                                                            |
 |   lot_insert                                                             |
 |   get_doc_no                                                             |
 |      This will get the doc no from sy_docs_mst and commit the no so that |
 |      there is no lock on the table.                                      |
 |      It is a AUTONOMOUS_TRANSACTION. which will commit before the main   |
 |      transaction completes.                                              |
 |                                                                          |
 |                                                                          |
 |                                                                          |
 | HISTORY                                                                  |
 |    Created - Jalaj Srivastava                                            |
 |                                                                          |
 |                                                                          |
 +==========================================================================+
*/


/* Procedure Declaration */
PROCEDURE header_insert
( p_api_version          IN               NUMBER
, p_init_msg_list        IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status        OUT NOCOPY       VARCHAR2
, x_msg_count            OUT NOCOPY       NUMBER
, x_msg_data             OUT NOCOPY       VARCHAR2
, p_hdr_rec              IN               GMIVDX.hdr_type
, x_hdr_row              OUT NOCOPY       gmi_discrete_transfers%ROWTYPE
);

PROCEDURE line_insert
( p_api_version          IN               NUMBER
, p_init_msg_list        IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status        OUT NOCOPY       VARCHAR2
, x_msg_count            OUT NOCOPY       NUMBER
, x_msg_data             OUT NOCOPY       VARCHAR2
, p_hdr_row              IN               gmi_discrete_transfers%ROWTYPE
, p_line_rec             IN               GMIVDX.line_type
, x_line_row             OUT NOCOPY       gmi_discrete_transfer_lines%ROWTYPE
);


PROCEDURE lot_insert
( p_api_version          IN               NUMBER
, p_init_msg_list        IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit               IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level     IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status        OUT NOCOPY       VARCHAR2
, x_msg_count            OUT NOCOPY       NUMBER
, x_msg_data             OUT NOCOPY       VARCHAR2
, p_line_row             IN               gmi_discrete_transfer_lines%ROWTYPE
, p_lot_rec              IN               GMIVDX.lot_type
, x_lot_row              OUT NOCOPY       gmi_discrete_transfer_lots%ROWTYPE
);

FUNCTION get_doc_no
( x_return_status        OUT NOCOPY       VARCHAR2
, x_msg_count            OUT NOCOPY       NUMBER
, x_msg_data             OUT NOCOPY       VARCHAR2
, p_doc_type  		 IN               sy_docs_seq.doc_type%TYPE
, p_orgn_code 		 IN               sy_docs_seq.orgn_code%TYPE
) RETURN VARCHAR2;

END GMIVDBX;

 

/
