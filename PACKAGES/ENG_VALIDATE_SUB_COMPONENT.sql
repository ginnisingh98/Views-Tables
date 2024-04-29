--------------------------------------------------------
--  DDL for Package ENG_VALIDATE_SUB_COMPONENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_VALIDATE_SUB_COMPONENT" AUTHID CURRENT_USER AS
/* $Header: ENGLSBCS.pls 115.9 2002/12/12 17:13:52 akumar ship $ */

PROCEDURE CHECK_REQUIRED(  x_return_status      OUT NOCOPY VARCHAR2
                         , p_sub_component_rec   IN
                           Bom_Bo_Pub.Sub_Component_Rec_Type
                         , x_Mesg_Token_tbl     OUT NOCOPY
                           Error_Handler.Mesg_Token_Tbl_Type
                         );

--  Procedure Entity

PROCEDURE Check_Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		    OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_sub_component_rec             IN  Bom_Bo_Pub.Sub_Component_Rec_Type
,   p_Sub_Comp_Unexp_Rec	    IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
);

--  Procedure Attributes

PROCEDURE Check_Attributes
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		    OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_sub_component_rec             IN  Bom_Bo_Pub.Sub_Component_Rec_Type
);

--  Procedure Entity_Delete

PROCEDURE Check_Entity_Delete
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		    OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_sub_component_rec             IN  Bom_Bo_Pub.Sub_Component_Rec_Type
,   p_Sub_Comp_Unexp_Rec	    IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
);

PROCEDURE Check_Existence
(  p_sub_component_rec		IN  Bom_Bo_Pub.Sub_Component_Rec_Type
 , p_sub_comp_unexp_rec		IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
 , x_old_sub_component_rec	IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Rec_Type
 , x_old_sub_comp_unexp_rec	IN OUT NOCOPY Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status		OUT NOCOPY VARCHAR2
);

PROCEDURE Check_Lineage
(  p_sub_component_rec          IN  Bom_Bo_Pub.Sub_Component_Rec_Type
 , p_sub_comp_unexp_rec         IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              OUT NOCOPY VARCHAR2
);

PROCEDURE Check_Access
(  p_sub_component_rec          IN  Bom_Bo_Pub.Sub_Component_Rec_Type
 , p_sub_comp_unexp_rec         IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              OUT NOCOPY VARCHAR2
);

END ENG_Validate_Sub_Component;

 

/
