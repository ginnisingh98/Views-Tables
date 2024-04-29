--------------------------------------------------------
--  DDL for Package ENG_VALIDATE_CHANGE_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_VALIDATE_CHANGE_LINE" AUTHID CURRENT_USER AS
/* $Header: ENGLCHLS.pls 115.4 2003/02/10 21:34:36 bbontemp noship $ */


/****************************************************************************
*  CHECK EXISTENCE
*****************************************************************************/

-- Check_Existence
PROCEDURE Check_Existence
(  p_change_line_rec             IN  Eng_Eco_Pub.Change_Line_Rec_Type
 , p_change_line_unexp_rec       IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , x_old_change_line_rec         IN OUT NOCOPY Eng_Eco_Pub.Change_Line_Rec_Type
 , x_old_change_line_unexp_rec   IN OUT NOCOPY Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , x_mesg_token_tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status               OUT NOCOPY VARCHAR2
) ;


/****************************************************************************
*  CHECK REQUIRED
*****************************************************************************/

-- Check_Required
PROCEDURE Check_Required
( p_change_line_rec     IN  Eng_Eco_Pub.Change_Line_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_mesg_token_tbl      OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) ;


/****************************************************************************
*  CHECK ATTRIBUTES
*****************************************************************************/

-- Check_Attributes
PROCEDURE Check_Attributes
(  p_change_line_rec             IN  Eng_Eco_Pub.Change_Line_Rec_Type
 , p_change_line_unexp_rec       IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , p_old_change_line_rec         IN  Eng_Eco_Pub.Change_Line_Rec_Type
 , p_old_change_line_unexp_rec   IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , x_mesg_token_tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status               OUT NOCOPY VARCHAR2
) ;

/****************************************************************************
*  CHECK CONDITIONALLY REQUIRED
*****************************************************************************/

-- Check_Conditionally_Required
PROCEDURE Check_Conditionally_Required
( p_change_line_rec       IN  Eng_Eco_Pub.Change_Line_Rec_Type
, p_change_line_unexp_rec IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
, x_return_status         OUT NOCOPY VARCHAR2
, x_mesg_token_tbl        OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) ;


/****************************************************************************
*  CHECK ENTITY ATTRIBUTES
*****************************************************************************/

-- Check_Entity
PROCEDURE Check_Entity
(  p_change_line_rec           IN  Eng_Eco_Pub.Change_Line_Rec_Type
 , p_change_line_unexp_rec     IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , p_old_change_line_rec       IN  Eng_Eco_Pub.Change_Line_Rec_Type
 , p_old_change_line_unexp_rec IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , x_mesg_token_tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status             OUT NOCOPY VARCHAR2
) ;

-- Check_Entity Delete
PROCEDURE Check_Entity_Delete
(  p_change_line_rec          IN  Eng_Eco_Pub.Change_Line_Rec_Type
 , p_change_line_unexp_rec    IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , x_mesg_token_tbl           OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status            OUT NOCOPY VARCHAR2
) ;


/****************************************************************************
* CHECK_ACCESS
*****************************************************************************/
PROCEDURE Check_Access
(  p_change_notice              IN  VARCHAR2
 , p_organization_id            IN  NUMBER
 , p_item_revision              IN  VARCHAR2
 , p_item_name                  IN  VARCHAR2
 , p_item_id                    IN  NUMBER
 , p_item_revision_id           IN  NUMBER
 , p_Mesg_Token_Tbl             IN  Error_Handler.Mesg_Token_Tbl_Type :=
                                    Error_Handler.G_MISS_MESG_TOKEN_TBL
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              OUT NOCOPY VARCHAR2
) ;

PROCEDURE Check_Access
(  p_change_line_rec           IN  Eng_Eco_Pub.Change_Line_Rec_Type
 , p_change_line_unexp_rec     IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , p_Mesg_Token_Tbl             IN  Error_Handler.Mesg_Token_Tbl_Type :=
                                    Error_Handler.G_MISS_MESG_TOKEN_TBL
 , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              OUT NOCOPY VARCHAR2
) ;

END ENG_Validate_Change_Line ;

 

/
