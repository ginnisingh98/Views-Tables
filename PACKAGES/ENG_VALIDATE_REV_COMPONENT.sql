--------------------------------------------------------
--  DDL for Package ENG_VALIDATE_REV_COMPONENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_VALIDATE_REV_COMPONENT" AUTHID CURRENT_USER AS
/* $Header: ENGLCMPS.pls 115.11 2002/12/12 16:46:14 akumar ship $ */

--  Procedure Entity

PROCEDURE Check_Entity
( x_return_status		OUT NOCOPY VARCHAR2
, x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, p_rev_component_rec		IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_Rev_Comp_Unexp_Rec		IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
, p_Old_Rev_Component_Rec	IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_Old_Rev_Comp_Unexp_Rec	IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
);

--  Procedure Attributes

PROCEDURE Check_Attributes
( x_return_status		OUT NOCOPY VARCHAR2
, x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, p_rev_component_rec		IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_Rev_Comp_Unexp_Rec		IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
);

--  Procedure Entity_Delete

PROCEDURE Check_Entity_Delete
( x_return_status		OUT NOCOPY VARCHAR2
, x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, p_rev_component_rec		IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_Rev_Comp_Unexp_Rec		IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
);

PROCEDURE Check_Required
( x_return_status		OUT NOCOPY VARCHAR2
, x_Mesg_Token_Tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, p_rev_component_rec           IN  Bom_Bo_Pub.Rev_Component_Rec_Type
);

PROCEDURE Check_Existence
(  p_rev_component_rec		IN  Bom_Bo_Pub.Rev_Component_Rec_Type
 , p_rev_comp_unexp_rec		IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
 , x_old_rev_component_rec	IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
 , x_old_rev_comp_unexp_rec	IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status		OUT NOCOPY VARCHAR2
);

PROCEDURE Check_Lineage
(  p_rev_component_rec          IN  Bom_Bo_Pub.Rev_Component_Rec_Type
 , p_rev_comp_unexp_rec         IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              OUT NOCOPY VARCHAR2
);

PROCEDURE Check_Access
(  p_revised_item_name          IN  VARCHAR2
 , p_revised_item_id            IN  NUMBER
 , p_organization_id            IN  NUMBER
 , p_change_notice              IN  VARCHAR2
 , p_new_item_revision          IN  VARCHAR2
 , p_effectivity_date           IN  DATE
 , p_component_item_id          IN  NUMBER
 , p_operation_seq_num          IN  NUMBER
 , p_bill_sequence_id           IN  NUMBER
 , p_component_name             IN  VARCHAR2
 , p_Mesg_Token_Tbl             IN  Error_Handler.Mesg_Token_Tbl_Type :=
                                    Error_Handler.G_MISS_MESG_TOKEN_TBL
 , p_entity_processed           IN  VARCHAR2 := 'RC'
 , p_rfd_sbc_name               IN  VARCHAR2 := NULL
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              OUT NOCOPY VARCHAR2
);

END ENG_Validate_Rev_Component;

 

/
