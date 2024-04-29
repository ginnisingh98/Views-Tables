--------------------------------------------------------
--  DDL for Package EGO_CATALOG_GROUP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_CATALOG_GROUP_UTIL" AUTHID CURRENT_USER AS
/* $Header: EGOUCAGS.pls 120.1 2005/06/29 00:24:35 lkapoor noship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EGOUCAGS.pls
--
--  DESCRIPTION
--
--      Spec of package EGO_Catalog_Group_Util
--
--  NOTES
--
--  HISTORY
--  20-SEP-2002	Rahul Chitko	Initial Creation
--
****************************************************************************/

PROCEDURE Query_Row
(  x_mesg_token_tbl	OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_status       OUT NOCOPY VARCHAR2
);

PROCEDURE Perform_Writes
( x_mesg_token_tbl     OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_return_status      OUT NOCOPY VARCHAR2
);

END EGO_Catalog_Group_Util;

 

/
