--------------------------------------------------------
--  DDL for Package BOM_VALIDATE_COMP_OPERATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_VALIDATE_COMP_OPERATION" AUTHID CURRENT_USER AS
/* $Header: BOMLCOPS.pls 115.3 2002/11/13 20:54:40 rfarook ship $ */
/*****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMLCOPS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Validate_Comp_Operation
--
--  NOTES
--
--  HISTORY
--
--  29-AUG-2001		Refai Farook	Initial Creation
--
*****************************************************************************/

FUNCTION Check_Overlap_Dates
                ( p_Effectivity_Date DATE,
                  p_Disable_Date     DATE,
                  p_Component_Item_Id   NUMBER,
                  p_Bill_Sequence_Id NUMBER,
                  p_component_sequence_id   IN NUMBER := NULL,
                  p_comp_operation_seq_id   IN NUMBER := NULL,
                  p_Rowid            VARCHAR2 := NULL,
                  p_Operation_Seq_Num NUMBER,
                  p_entity           VARCHAR2 := 'COPS')
RETURN BOOLEAN;

FUNCTION Check_Overlap_Numbers
                 (  p_From_End_Item_Number VARCHAR2
                  , p_To_End_Item_Number VARCHAR2
                  , p_Component_Item_Id   NUMBER
                  , p_Bill_Sequence_Id NUMBER
                  , p_component_sequence_id   IN NUMBER := NULL
                  , p_comp_operation_seq_id   IN NUMBER := NULL
                  , p_Rowid            VARCHAR2 := NULL
                  , p_Operation_Seq_Num NUMBER
                  , p_entity           VARCHAR2 := 'COPS')
RETURN BOOLEAN;

PROCEDURE Check_Entity
(   x_return_status		IN OUT NOCOPY  VARCHAR2
,   x_Mesg_Token_Tbl		IN OUT NOCOPY  Error_Handler.Mesg_Token_Tbl_Type
,   p_bom_comp_ops_rec	         IN  Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
,   p_bom_comp_ops_unexp_rec	 IN  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
);

PROCEDURE Check_Attributes
(   x_return_status             IN OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl            IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_bom_comp_ops_rec           IN Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
,   p_bom_comp_ops_unexp_rec     IN Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
);

PROCEDURE Check_Existence
(  p_bom_comp_ops_rec            IN  Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
 , p_bom_comp_ops_unexp_rec      IN  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
 , x_old_bom_comp_ops_rec        IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
 , x_old_bom_comp_ops_unexp_rec  IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
 , x_Mesg_Token_Tbl              IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status               IN OUT NOCOPY VARCHAR2
);

PROCEDURE Check_Lineage
(  p_bom_comp_ops_rec		IN  Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
 , p_bom_comp_ops_unexp_rec	IN  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
 , x_Mesg_Token_Tbl		IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status		IN OUT NOCOPY VARCHAR2
);

END BOM_Validate_Comp_Operation;

 

/
