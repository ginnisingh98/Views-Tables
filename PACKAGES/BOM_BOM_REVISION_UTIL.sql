--------------------------------------------------------
--  DDL for Package BOM_BOM_REVISION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_BOM_REVISION_UTIL" AUTHID CURRENT_USER AS
/* $Header: BOMUREVS.pls 115.3 2002/11/13 20:57:47 rfarook ship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      ENGUCMPS.pls
--
--  DESCRIPTION
--
--      Spec of package  Bom_Bom_Revision_Util
--
--  NOTES
--
--  HISTORY
--
--  30-JUL-99 Rahul Chitko      Initial Creation
--
****************************************************************************/

PROCEDURE Perform_Writes
(  p_bom_revision_rec           IN  Bom_Bo_Pub.Bom_Revision_Rec_Type
 , p_bom_rev_Unexp_Rec     	IN  Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl     	IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status      	IN OUT NOCOPY VARCHAR2
);

PROCEDURE Query_Row
(  p_revision			IN  VARCHAR2
 , p_assembly_item_id		IN  NUMBER
 , p_organization_id		IN  NUMBER
 , x_bom_revision_rec		IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Rec_Type
 , x_bom_rev_unexp_rec		IN OUT NOCOPY Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
 , x_return_status		IN OUT NOCOPY VARCHAR
);

END Bom_Bom_Revision_Util;

 

/
