--------------------------------------------------------
--  DDL for Package ENG_VALIDATE_ECO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_VALIDATE_ECO" AUTHID CURRENT_USER AS
/* $Header: ENGLECOS.pls 120.2 2007/06/01 09:13:10 pguharay ship $ */

-- PROCEDURE Check_Delete

PROCEDURE Check_Delete
( p_eco_rec             IN  ENG_ECO_PUB.Eco_Rec_Type
, p_Unexp_ECO_rec       IN  ENG_Eco_PUB.Eco_Unexposed_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_Mesg_Token_Tbl      OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
);

--  Procedure Entity

PROCEDURE Check_Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_err_text			    OUT NOCOPY	VARCHAR2
,   x_Mesg_Token_Tbl		    OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_Unexp_ECO_rec		    IN  ENG_Eco_PUB.Eco_Unexposed_Rec_Type
,   p_old_ECO_rec                   IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_old_Unexp_ECO_rec		    IN  ENG_Eco_PUB.Eco_Unexposed_Rec_Type
,   p_control_rec		    IN  BOM_BO_PUB.Control_Rec_Type :=
					BOM_BO_PUB.G_DEFAULT_CONTROL_REC
);

--  Procedure Check_Attributes

PROCEDURE Check_Attributes
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_err_text			    OUT NOCOPY	VARCHAR2
,   x_Mesg_Token_Tbl		    OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_Unexp_ECO_rec		    IN  ENG_Eco_PUB.Eco_Unexposed_Rec_Type
,   p_old_ECO_rec                   IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_old_Unexp_ECO_rec		    IN  ENG_Eco_PUB.Eco_Unexposed_Rec_Type
,   p_change_line_tbl               IN  ENG_Eco_PUB.Change_Line_Tbl_Type --Bug 2908248
,   p_revised_item_tbl              IN  ENG_Eco_PUB.Revised_Item_Tbl_Type --Bug 2908248

);

-- Procedure Check_Required

PROCEDURE Conditionally_Required
(   x_return_status		   OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		    OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_ECO_rec			   IN  ENG_ECO_PUB.Eco_Rec_Type
,   p_Unexp_ECO_rec		    IN  ENG_Eco_PUB.Eco_Unexposed_Rec_Type
,   p_old_ECO_rec                   IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_old_Unexp_ECO_rec		    IN  ENG_Eco_PUB.Eco_Unexposed_Rec_Type
);

PROCEDURE Check_Access
(  p_change_notice      IN  VARCHAR2
 , p_organization_id    IN  NUMBER
 , p_change_type_code	IN  VARCHAR2 := NULL
 , p_change_order_type_id IN NUMBER := NULL
 , p_Mesg_Token_Tbl     IN  Error_Handler.Mesg_Token_Tbl_Type :=
                                Error_Handler.G_MISS_MESG_TOKEN_TBL
 , x_Mesg_Token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status      OUT NOCOPY VARCHAR2
 , p_check_scheduled_status IN BOOLEAN DEFAULT TRUE -- Added for Bug 5756870
 , p_status_check_required IN BOOLEAN DEFAULT TRUE -- Added for enhancement 5414834
);

PROCEDURE Check_Existence
(  p_change_notice      IN  VARCHAR2
 , p_organization_id    IN  NUMBER
 , p_organization_code  IN  VARCHAR2
 , p_calling_entity     IN  VARCHAR2
 , p_transaction_type   IN  VARCHAR2
 , x_eco_rec            OUT NOCOPY Eng_Eco_Pub.Eco_Rec_Type
 , x_eco_unexp_rec      OUT NOCOPY Eng_Eco_Pub.Eco_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl     OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status      OUT NOCOPY VARCHAR2
);

END ENG_Validate_Eco;

/
