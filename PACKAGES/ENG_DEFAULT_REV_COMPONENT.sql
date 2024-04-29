--------------------------------------------------------
--  DDL for Package ENG_DEFAULT_REV_COMPONENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_DEFAULT_REV_COMPONENT" AUTHID CURRENT_USER AS
/* $Header: ENGDCMPS.pls 115.6 2002/12/12 16:20:29 akumar ship $ */

--  Procedure Attributes

PROCEDURE Attribute_Defaulting
(   p_rev_component_rec         IN  Bom_Bo_Pub.Rev_Component_Rec_Type
,   p_Rev_Comp_Unexp_Rec        IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
,   x_rev_component_rec         IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
,   x_Rev_Comp_Unexp_Rec        IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_Return_Status             OUT NOCOPY VARCHAR2
);

PROCEDURE Populate_Null_Columns
( p_rev_component_rec           IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_old_rev_component_rec       IN  Bom_Bo_Pub.Rev_Component_Rec_Type
, p_Rev_Comp_Unexp_Rec          IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
, p_Old_Rev_Comp_Unexp_Rec      IN  Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
, x_Rev_Component_Rec           IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
, x_Rev_Comp_Unexp_Rec          IN OUT NOCOPY Bom_Bo_Pub.Rev_Comp_Unexposed_Rec_Type
);

PROCEDURE Entity_Defaulting
(   p_rev_component_rec             IN  Bom_Bo_Pub.Rev_Component_Rec_Type
,   p_old_rev_component_rec         IN  Bom_Bo_Pub.Rev_Component_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_REV_COMPONENT_REC
,   x_rev_component_rec             IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Rec_Type
);

END ENG_Default_Rev_Component;

 

/
