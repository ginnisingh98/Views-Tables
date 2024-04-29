--------------------------------------------------------
--  DDL for Package EGO_VALIDATE_CATALOG_GROUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_VALIDATE_CATALOG_GROUP" AUTHID CURRENT_USER AS
/* $Header: EGOLCAGS.pls 120.1 2005/06/02 05:39:51 lkapoor noship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMLBOMS.pls
--
--  DESCRIPTION
--
--      Spec of package EGO_Validate_Catalog_Group
--
--  NOTES
--
--  HISTORY
--
--  01-JUL-99   Rahul Chitko    Initial Creation
--
****************************************************************************/

	PROCEDURE Check_Existence
	(  x_Mesg_Token_Tbl	    OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , x_return_status	    OUT NOCOPY VARCHAR2
	);

	PROCEDURE Check_Access
        (  x_mesg_token_tbl        OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status         OUT NOCOPY VARCHAR2
        );

        PROCEDURE Check_Attributes
        (  x_return_status           OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl          OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        );

	PROCEDURE Check_Required
        (  x_return_status      OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl     OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         );

        PROCEDURE Check_Entity
        (  x_mesg_token_tbl     OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_status      OUT NOCOPY VARCHAR2
         );

	PROCEDURE Check_Entity_Delete
        ( x_return_status 	OUT NOCOPY VARCHAR2
        , x_Mesg_Token_Tbl      OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 );

END EGO_Validate_Catalog_Group;

 

/
