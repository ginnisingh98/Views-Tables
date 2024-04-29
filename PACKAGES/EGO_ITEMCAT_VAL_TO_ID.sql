--------------------------------------------------------
--  DDL for Package EGO_ITEMCAT_VAL_TO_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEMCAT_VAL_TO_ID" AUTHID CURRENT_USER AS
/* $Header: EGOSVIDS.pls 120.1 2005/06/02 05:41:32 lkapoor noship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EGOSVIDS.pls
--
--  DESCRIPTION
--
--      Spec of package EGO_ItemCat_Val_To_Id
--	Shared value-to-Id conversion package
--  NOTES
--
--  HISTORY
--
--  20-SEP-2002	Rahul Chitko	Initial Creation
--  10-OCT-2002 Refai Farook    Added the procedure Get_Catalog_Group_Id
****************************************************************************/

	PROCEDURE EGO_ItemCatalog_UUI_To_UI
        (  x_Mesg_Token_Tbl          OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_Return_Status           OUT NOCOPY VARCHAR2
        );


	PROCEDURE EGO_ItemCatalog_VID
        (  x_Return_Status              OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        );

	/* This procedure will be used by entity validation procedure to
	   perform duplicate check */

        FUNCTION Get_Catalog_Group_Id
                 (  p_catalog_group_name        IN VARCHAR2
                  , p_operation                 IN VARCHAR2
                 )
        RETURN NUMBER;


END EGO_ItemCat_Val_To_Id;

 

/
