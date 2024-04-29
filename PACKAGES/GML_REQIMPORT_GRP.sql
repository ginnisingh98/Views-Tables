--------------------------------------------------------
--  DDL for Package GML_REQIMPORT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_REQIMPORT_GRP" AUTHID CURRENT_USER AS
/* $Header: GMLGREQS.pls 115.1 2003/08/29 17:50:26 pbamb noship $*/

/*+=========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMLGREQS.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GML_ReqImport_GRP                                                     |
 |                                                                          |
 | TYPE                                                                     |
 |   Group                                                                  |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains the group API for Req Import validations for    |
 |    Process Requisitions						    |
 |                                                                          |
 | CONTENTS                                                                 |
 |   Validate_Requisition_Grp                                               |
 |                                                                          |
 | HISTORY                                                                  |
 |    Created - Preetam Bamb                                                |
 |                                                                          |
 |                                                                          |
 +==========================================================================+
*/


/* Function Declaration */
PROCEDURE Validate_Requisition_Grp
( p_api_version         IN               NUMBER
, p_init_msg_list    	IN  VARCHAR2 :=  FND_API.G_FALSE
, p_validation_level 	IN  NUMBER   :=  FND_API.G_VALID_LEVEL_FULL
, p_commit           	IN  VARCHAR2 :=  FND_API.G_FALSE
, p_request_id		IN 		 NUMBER
, x_return_status       OUT NOCOPY       VARCHAR2
, x_msg_count           OUT NOCOPY       NUMBER
, x_msg_data            OUT NOCOPY       VARCHAR2
);

G_PKG_NAME VARCHAR2(50) := 'GML_ReqImport_GRP';
G_OPM_INSTALLED VARCHAR2(5) := NULL;

END GML_ReqImport_GRP;

 

/
