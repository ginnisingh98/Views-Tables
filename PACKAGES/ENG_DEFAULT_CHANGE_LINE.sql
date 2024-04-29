--------------------------------------------------------
--  DDL for Package ENG_DEFAULT_CHANGE_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_DEFAULT_CHANGE_LINE" AUTHID CURRENT_USER AS
/* $Header: ENGDCHLS.pls 120.2 2006/03/27 06:57:28 sdarbha noship $ */


/****************************************************************************
*  ATTRIBUTE DEFAULTING
*****************************************************************************/
    --
    -- Attribute Defualting for Change Line Record
    --
    PROCEDURE Attribute_Defaulting
    (  p_change_line_rec        IN  Eng_Eco_Pub.Change_Line_Rec_Type
     , p_change_line_unexp_rec  IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
     , x_change_line_rec        IN OUT NOCOPY Eng_Eco_Pub.Change_Line_Rec_Type
     , x_change_line_unexp_rec  IN OUT NOCOPY Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
     , x_mesg_token_tbl         OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status          OUT NOCOPY VARCHAR2
    ) ;


/****************************************************************************
*  POPULATE NULL COLUMNS
*****************************************************************************/
    --
    -- Populate NULL Columns for Change Line Record
    --
    PROCEDURE Populate_Null_Columns
    (  p_change_line_rec           IN  Eng_Eco_Pub.Change_Line_Rec_Type
     , p_change_line_unexp_rec     IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
     , p_old_change_line_rec       IN  Eng_Eco_Pub.Change_Line_Rec_Type
     , p_old_change_line_unexp_rec IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
     , x_change_line_rec           IN OUT NOCOPY Eng_Eco_Pub.Change_Line_Rec_Type
     , x_change_line_unexp_rec     IN OUT NOCOPY Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
    ) ;


/****************************************************************************
*  ENTITY LEVEL DEFAULTING
*****************************************************************************/
    --
    -- Entity Level Defaulting Change Line Record
    --
    PROCEDURE Entity_Defaulting
    (  p_change_line_rec           IN  Eng_Eco_Pub.Change_Line_Rec_Type
     , p_change_line_unexp_rec     IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
     , p_old_change_line_rec       IN  Eng_Eco_Pub.Change_Line_Rec_Type
     , p_old_change_line_unexp_rec IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
     , x_change_line_rec           IN OUT NOCOPY Eng_Eco_Pub.Change_Line_Rec_Type
     , x_change_line_unexp_rec     IN OUT NOCOPY Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
     , x_mesg_token_tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     , x_return_status             OUT NOCOPY VARCHAR2
    ) ;


END ENG_Default_Change_Line ;

 

/
