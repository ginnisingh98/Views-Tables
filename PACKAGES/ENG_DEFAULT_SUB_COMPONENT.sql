--------------------------------------------------------
--  DDL for Package ENG_DEFAULT_SUB_COMPONENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_DEFAULT_SUB_COMPONENT" AUTHID CURRENT_USER AS
/* $Header: ENGDSBCS.pls 115.6 2002/12/12 16:28:10 akumar ship $ */

--  Procedure Attributes

PROCEDURE Attribute_Defaulting
(   p_sub_component_rec             IN  Bom_Bo_Pub.Sub_Component_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_SUB_COMPONENT_REC
,   p_Sub_Comp_Unexp_Rec	    IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
,   x_sub_component_rec             IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Rec_Type
,   x_Sub_Comp_Unexp_Rec	    IN OUT NOCOPY Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
,   x_Mesg_Token_Tbl		    OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status		    OUT NOCOPY VARCHAR2
);

PROCEDURE Populate_Null_Columns
( p_sub_component_rec           IN  Bom_Bo_Pub.Sub_Component_Rec_Type
, p_old_sub_component_rec       IN  Bom_Bo_Pub.Sub_Component_Rec_Type
, p_sub_Comp_Unexp_Rec          IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
, p_Old_sub_Comp_Unexp_Rec      IN  Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
, x_sub_Component_Rec           IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Rec_Type
, x_sub_Comp_Unexp_Rec          IN OUT NOCOPY Bom_Bo_Pub.Sub_Comp_Unexposed_Rec_Type
);

PROCEDURE Entity_Defaulting
(   p_sub_component_rec             IN  Bom_Bo_Pub.Sub_Component_Rec_Type
,   p_old_sub_component_rec         IN  Bom_Bo_Pub.Sub_Component_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_Sub_COMPONENT_REC
,   x_sub_component_rec             IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Rec_Type
);

END ENG_Default_Sub_Component;

 

/
