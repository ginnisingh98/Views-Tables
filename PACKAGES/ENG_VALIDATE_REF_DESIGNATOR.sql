--------------------------------------------------------
--  DDL for Package ENG_VALIDATE_REF_DESIGNATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_VALIDATE_REF_DESIGNATOR" AUTHID CURRENT_USER AS
/* $Header: ENGLRFDS.pls 115.8 2002/12/12 17:03:23 akumar ship $ */

--  Procedure Entity

PROCEDURE Check_Entity
(   x_return_status		OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_ref_designator_rec	IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
,   p_Ref_Desg_Unexp_Rec	IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
);

--  Procedure Attributes

PROCEDURE Check_Attributes
(   x_return_status		OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_ref_designator_rec	IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
);

--  Procedure Entity_Delete

PROCEDURE Check_Entity_Delete
(   x_return_status		OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_ref_designator_rec        IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
,   p_Ref_Desg_Unexp_Rec	IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
);

PROCEDURE Check_Existence
(  p_ref_designator_rec		IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
 , p_ref_desg_unexp_rec		IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
 , x_old_ref_designator_rec	IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Rec_Type
 , x_old_ref_desg_unexp_rec	IN OUT NOCOPY Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status		OUT NOCOPY VARCHAR2
);

PROCEDURE Check_Lineage
(  p_ref_designator_rec		IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
 , p_ref_desg_unexp_rec		IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status		OUT NOCOPY VARCHAR2
);

PROCEDURE CHECK_ACCESS
(  p_ref_designator_rec IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
 , p_ref_desg_unexp_rec IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl     OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status      OUT NOCOPY VARCHAR2
);

END ENG_Validate_Ref_Designator;

 

/
