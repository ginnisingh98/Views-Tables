--------------------------------------------------------
--  DDL for Package ENG_DEFAULT_REF_DESIGNATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_DEFAULT_REF_DESIGNATOR" AUTHID CURRENT_USER AS
/* $Header: ENGDRFDS.pls 115.6 2002/12/12 16:25:51 akumar ship $ */

--  Procedure Attributes

PROCEDURE Attribute_Defaulting
(   p_ref_designator_rec	IN  Bom_Bo_Pub.Ref_Designator_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_REF_DESIGNATOR_REC
,   p_ref_desg_unexp_rec	IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
,   x_ref_designator_rec	IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Rec_Type
,   x_Ref_Desg_Unexp_Rec	IN OUT NOCOPY Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
,   x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_Return_Status		OUT NOCOPY VARCHAR2
);

PROCEDURE Populate_Null_Columns
(   p_ref_designator_rec        IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
,   p_ref_desg_unexp_rec        IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
,   p_old_Ref_Designator_Rec    IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
,   p_old_ref_desg_unexp_rec    IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
,   x_Ref_Designator_Rec        IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Rec_Type
,   x_ref_desg_unexp_rec        IN OUT NOCOPY Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
);

END ENG_Default_Ref_Designator;

 

/
