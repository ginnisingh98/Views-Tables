--------------------------------------------------------
--  DDL for Package GMIVITM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMIVITM" AUTHID CURRENT_USER AS
/* $Header: GMIVITMS.pls 115.9 2002/11/11 21:13:11 jdiiorio ship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIVITMS.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMIVITM                                                               |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains all validation for item creation                |
 |                                                                          |
 | CONTENTS                                                                 |
 |    validate_item                                                         |
 | HISTORY                                                                  |
 |    Joe DiIorio 11/11/02 Bug#2643440 - added nocopy.                      |
 +==========================================================================+
*/
PROCEDURE Validate_item
( p_api_version      IN NUMBER
, p_validation_level IN VARCHAR2 :=FND_API.G_VALID_LEVEL_FULL
, p_item_rec         IN GMIGAPI.item_rec_typ
, x_ic_item_mst_row  OUT NOCOPY ic_item_mst%ROWTYPE
, x_ic_item_cpg_row  OUT NOCOPY ic_item_cpg%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
);

END GMIVITM;

 

/
