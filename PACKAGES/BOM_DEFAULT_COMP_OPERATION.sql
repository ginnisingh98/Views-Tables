--------------------------------------------------------
--  DDL for Package BOM_DEFAULT_COMP_OPERATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_DEFAULT_COMP_OPERATION" AUTHID CURRENT_USER AS
/* $Header: BOMDCOPS.pls 115.3 2002/11/13 20:53:27 rfarook ship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMDCOPS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Default_Comp_Operation
--
--  NOTES
--
--  HISTORY
--
-- 27-AUG-2001	Refai Farook	Initial Creation
--
****************************************************************************/
--  Procedure Attributes

PROCEDURE Attribute_Defaulting
(   p_bom_comp_ops_rec             IN  Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_BOM_COMP_OPS_REC
,   p_bom_comp_ops_unexp_rec       IN  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
,   x_bom_comp_ops_rec             IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
,   x_bom_comp_ops_unexp_rec       IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
,   x_Mesg_Token_Tbl	           IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status		   IN OUT NOCOPY VARCHAR2
);

PROCEDURE Populate_Null_Columns
( p_bom_comp_ops_rec                IN  Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
, p_old_bom_comp_ops_rec            IN  Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
, p_bom_comp_ops_unexp_rec          IN  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
, p_old_bom_comp_ops_unexp_rec      IN  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
, x_bom_comp_ops_rec                IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
, x_bom_comp_ops_unexp_rec          IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
);

END BOM_Default_Comp_Operation;

 

/
