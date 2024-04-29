--------------------------------------------------------
--  DDL for Package BOM_VALIDATE_BOM_REVISION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_VALIDATE_BOM_REVISION" AUTHID CURRENT_USER AS
/* $Header: BOMLREVS.pls 115.3 2002/11/13 20:54:56 rfarook ship $ */
/*************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMLCMPS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Validate_Bom_Revision
--
--  NOTES
--
--  HISTORY
--
--  30-JUL-99 Rahul Chitko      Initial Creation
--
**************************************************************************/

PROCEDURE Check_Entity
( x_return_status              IN OUT NOCOPY VARCHAR2
, x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, p_bom_revision_rec           IN  Bom_Bo_Pub.Bom_Revision_Rec_Type
, p_bom_rev_Unexp_Rec          IN  Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
, p_old_bom_revision_Rec       IN  Bom_Bo_Pub.Bom_Revision_Rec_Type
, p_old_bom_Rev_Unexp_Rec      IN  Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
);

PROCEDURE Check_Required
( x_return_status              IN OUT NOCOPY VARCHAR2
, x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, p_bom_revision_rec           IN  Bom_Bo_Pub.Bom_Revision_Rec_Type
);

PROCEDURE Check_Existence
(  p_bom_revision_rec          IN  Bom_Bo_Pub.Bom_revision_Rec_Type
 , p_bom_rev_unexp_rec         IN  Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
 , x_old_bom_revision_rec      IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Rec_Type
 , x_old_bom_rev_unexp_rec     IN OUT NOCOPY Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status             IN OUT NOCOPY VARCHAR2
);


END Bom_Validate_Bom_Revision;

 

/
