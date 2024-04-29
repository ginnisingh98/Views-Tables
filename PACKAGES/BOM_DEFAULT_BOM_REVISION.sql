--------------------------------------------------------
--  DDL for Package BOM_DEFAULT_BOM_REVISION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_DEFAULT_BOM_REVISION" AUTHID CURRENT_USER AS
/* $Header: BOMDREVS.pls 115.3 2002/11/13 20:47:17 rfarook ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMDREVS.pls
--
--  DESCRIPTION
--
--      Spec of package Bom_Default_Bom_Revision
--
--  NOTES
--
--  HISTORY
--
--  29-JUL-99   Rahul Chitko    Initial Creation
--
***************************************************************************/

        PROCEDURE Populate_Null_Columns
        ( p_bom_revision_rec	   IN  Bom_Bo_Pub.Bom_Revision_Rec_Type
        , p_old_bom_revision_rec   IN  Bom_Bo_Pub.Bom_Revision_Rec_Type
        , p_bom_rev_unexp_rec	   IN  Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
        , p_Old_bom_rev_unexp_rec  IN  Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
        , x_bom_revision_rec	   IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Rec_Type
        , x_bom_rev_unexp_rec	   IN OUT NOCOPY Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
        );



END Bom_Default_Bom_Revision;

 

/
