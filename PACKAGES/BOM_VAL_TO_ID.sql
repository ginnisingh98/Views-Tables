--------------------------------------------------------
--  DDL for Package BOM_VAL_TO_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_VAL_TO_ID" AUTHID CURRENT_USER AS
/* $Header: BOMSVIDS.pls 120.0.12010000.2 2010/01/20 19:36:05 umajumde ship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMSVIDS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_Val_To_Id
--
--  NOTES
--
--  HISTORY
--
--  01-JUL-99	Rahul Chitko	Initial Creation
--
-- 07-MAY-2001  Refai Farook    EAM related changes
--
--  21-AUG-01   Refai Farook    One To Many support changes
--
****************************************************************************/

--Bug 8850425 begin
FUNCTION Comp_Operation_Seq_Id(  p_component_sequence_id   IN NUMBER
                                , p_operation_sequence_number IN NUMBER
                                ) RETURN NUMBER;
--Bug 8850425 end

FUNCTION Organization
	 (  p_organization	IN  VARCHAR2
	  , x_err_text		IN OUT NOCOPY VARCHAR2) RETURN NUMBER;

FUNCTION Bill_Sequence_Id
	 (  p_assembly_item_id		IN  NUMBER
	  , p_alternate_bom_code	IN  VARCHAR2
	  , p_organization_id		IN  NUMBER
	  , x_err_text			IN OUT NOCOPY VARCHAR2
	  ) RETURN NUMBER;

PROCEDURE Bom_Header_UUI_To_UI
	(  p_bom_header_Rec	  IN  Bom_Bo_Pub.Bom_Head_Rec_Type
	 , p_bom_header_unexp_Rec IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
	 , x_bom_header_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
	 , x_Mesg_Token_Tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
	 , x_Return_Status        IN OUT NOCOPY VARCHAR2
	);

PROCEDURE Bom_Header_VID
(  x_Return_Status       IN OUT NOCOPY VARCHAR2
 , x_Mesg_Token_Tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , p_bom_head_unexp_rec  IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
 , x_bom_head_unexp_rec  IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
 , p_bom_header_Rec	 IN  Bom_Bo_Pub.Bom_Head_Rec_Type
);

PROCEDURE Bom_Revision_UUI_To_UI2
(  p_bom_revision_rec	IN  Bom_Bo_Pub.Bom_Revision_Rec_Type
, p_bom_rev_unexp_rec	IN  Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
, x_bom_rev_unexp_rec	IN OUT NOCOPY Bom_Bo_Pub.Bom_Rev_Unexposed_Rec_Type
, x_mesg_token_tbl  	IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_return_status 	IN OUT NOCOPY VARCHAR2
);


PROCEDURE Rev_Component_VID
(  x_Return_Status        IN OUT NOCOPY Varchar2
,  x_Mesg_Token_Tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,  p_Rev_Comp_Unexp_Rec    IN Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
,  x_Rev_Comp_Unexp_Rec   IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
,  p_Rev_Component_Rec     IN Bom_Bo_Pub.Rev_Component_Rec_Type
);

-- Called by the BOM Business Object.
PROCEDURE Bom_Component_VID
(  x_return_status	IN OUT NOCOPY VARCHAR2
 , x_mesg_token_tbl	IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_bom_comp_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
 , p_bom_component_rec	IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
 , p_bom_comp_unexp_rec	IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
);


PROCEDURE Rev_Component_UUI_To_UI
        (  p_rev_component_Rec  IN  Bom_Bo_Pub.Rev_Component_Rec_Type
         , p_rev_comp_unexp_Rec IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
         , x_rev_comp_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_Return_Status      IN OUT NOCOPY VARCHAR2
        );

-- Called by the BOM Business Object.
PROCEDURE Bom_Component_UUI_To_UI
        (  p_bom_component_Rec  IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
         , p_bom_comp_unexp_Rec IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
         , x_bom_comp_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_Return_Status      IN OUT NOCOPY VARCHAR2
        );

PROCEDURE Rev_Component_UUI_to_UI2
        (  p_rev_component_rec  IN  Bom_Bo_Pub.Rev_Component_Rec_Type
         , p_rev_comp_unexp_rec IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
         , x_rev_comp_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_other_message      IN OUT NOCOPY VARCHAR2
         , x_other_token_tbl    IN OUT NOCOPY Error_Handler.Token_Tbl_Type
         , x_Return_Status      IN OUT NOCOPY VARCHAR2
        );

-- Called by the BOM Business Object.
PROCEDURE Bom_Component_UUI_to_UI2
        (  p_Bom_component_rec  IN  Bom_Bo_Pub.Bom_Comps_Rec_Type
         , p_Bom_comp_unexp_rec IN  Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
         , x_Bom_comp_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Unexposed_Rec_Type
         , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_other_message      IN OUT NOCOPY VARCHAR2
         , x_other_token_tbl    IN OUT NOCOPY Error_Handler.Token_Tbl_Type
         , x_Return_Status      IN OUT NOCOPY VARCHAR2
        );


PROCEDURE Sub_Component_UUI_To_UI
(  p_sub_component_rec  IN  Bom_Bo_Pub.Sub_Component_Rec_Type
, p_sub_comp_unexp_rec IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
, x_sub_Comp_unexp_Rec IN OUT NOCOPY Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
, x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_Return_Status      IN OUT NOCOPY VARCHAR2
);

PROCEDURE Sub_Component_UUI_To_UI2
(  p_sub_component_rec  IN  Bom_Bo_Pub.Sub_Component_Rec_Type
 , p_sub_comp_unexp_rec IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
 , x_sub_Comp_unexp_Rec IN OUT NOCOPY Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_other_message      IN OUT NOCOPY VARCHAR2
 , x_other_token_tbl    IN OUT NOCOPY Error_Handler.Token_Tbl_Type
 , x_Return_Status      IN OUT NOCOPY VARCHAR2
);

-- Procedure called by BOM Business Object
PROCEDURE Sub_Component_UUI_To_UI
(  p_bom_sub_component_rec IN  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
, p_bom_sub_comp_unexp_rec IN  Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
, x_bom_sub_Comp_unexp_Rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
, x_Mesg_Token_Tbl     	   IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_Return_Status      	   IN OUT NOCOPY VARCHAR2
);

PROCEDURE Sub_Component_UUI_To_UI2
(  p_bom_sub_component_rec  IN  Bom_Bo_Pub.Bom_Sub_Component_Rec_Type
 , p_bom_sub_comp_unexp_rec IN  Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
 , x_bom_sub_Comp_unexp_Rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Comp_Unexp_Rec_Type
 , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_other_message      IN OUT NOCOPY VARCHAR2
 , x_other_token_tbl    IN OUT NOCOPY Error_Handler.Token_Tbl_Type
 , x_Return_Status      IN OUT NOCOPY VARCHAR2
);

PROCEDURE Ref_Designator_UUI_To_UI
(  p_ref_designator_rec IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
, p_ref_desg_unexp_rec IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
, x_ref_desg_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
, x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_Return_Status      IN OUT NOCOPY VARCHAR2
);


PROCEDURE Ref_Designator_UUI_To_UI2
(  p_ref_designator_rec IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
, p_ref_desg_unexp_rec IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
, x_ref_desg_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
, x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_other_message      IN OUT NOCOPY VARCHAR2
, x_other_token_tbl    IN OUT NOCOPY Error_Handler.Token_Tbl_Type
, x_Return_Status      IN OUT NOCOPY VARCHAR2
);

--Procedures called by the BOM Business Object
PROCEDURE Ref_Designator_UUI_To_UI
(  p_bom_ref_designator_rec IN Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
, p_bom_ref_desg_unexp_rec IN  Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
, x_bom_ref_desg_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
, x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_Return_Status      IN OUT NOCOPY VARCHAR2
);

PROCEDURE Ref_Designator_UUI_To_UI2
(  p_Bom_ref_designator_rec IN  Bom_Bo_Pub.Bom_Ref_Designator_Rec_Type
, p_Bom_ref_desg_unexp_rec IN  Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
, x_Bom_ref_desg_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Desg_Unexp_Rec_Type
, x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_other_message      IN OUT NOCOPY VARCHAR2
, x_other_token_tbl    IN OUT NOCOPY Error_Handler.Token_Tbl_Type
, x_Return_Status      IN OUT NOCOPY VARCHAR2
);

--Procedures called by the BOM Business Object
        PROCEDURE Bom_Comp_Operation_UUI_To_UI
        (  p_bom_comp_ops_rec         IN  Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
         , p_bom_comp_ops_unexp_rec    IN  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
         , x_bom_comp_ops_unexp_rec  IN OUT NOCOPY  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
         , x_Mesg_Token_Tbl          IN OUT NOCOPY  Error_Handler.Mesg_Token_Tbl_Type
         , x_Return_Status           IN OUT NOCOPY  VARCHAR2
        );

        PROCEDURE Bom_Comp_Operation_UUI_To_UI2
        (  p_bom_comp_ops_rec       IN  Bom_Bo_Pub.Bom_Comp_Ops_Rec_Type
         , p_bom_comp_ops_unexp_rec IN  Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
         , x_bom_comp_ops_unexp_rec IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Unexp_Rec_Type
         , x_Mesg_Token_Tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_other_message          IN OUT NOCOPY VARCHAR2
         , x_other_token_tbl        IN OUT NOCOPY Error_Handler.Token_Tbl_Type
         , x_Return_Status          IN OUT NOCOPY VARCHAR2
        );


END BOM_Val_To_Id;

/
