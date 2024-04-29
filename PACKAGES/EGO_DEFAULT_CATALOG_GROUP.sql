--------------------------------------------------------
--  DDL for Package EGO_DEFAULT_CATALOG_GROUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_DEFAULT_CATALOG_GROUP" AUTHID CURRENT_USER AS
/* $Header: EGODCAGS.pls 120.1 2005/06/29 00:10:09 lkapoor noship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EGODCAGS.pls
--
--  DESCRIPTION
--
--      Spec of package EGO_Default_Catalog_Group
--
--  NOTES
--
--  HISTORY
--  20-SEP-2002 Rahul Chitko    Initial Creation
--
****************************************************************************/

        PROCEDURE Attribute_Defaulting
	(  x_mesg_token_tbl     OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status      OUT NOCOPY VARCHAR2
         );

        PROCEDURE Populate_Null_Columns;

END EGO_Default_Catalog_Group;

 

/
