--------------------------------------------------------
--  DDL for Package ENG_CHANGE_LINE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_CHANGE_LINE_UTIL" AUTHID CURRENT_USER AS
/* $Header: ENGUCHLS.pls 120.4 2007/08/14 06:24:50 prgopala ship $ */



/****************************************************************************
*  QUERY ROW
*****************************************************************************/

PROCEDURE Query_Row
( p_line_sequence_number  IN  NUMBER
, p_organization_id       IN  NUMBER
, p_change_notice         IN  VARCHAR2
, p_change_line_name      IN  VARCHAR2
, p_mesg_token_tbl        IN  Error_Handler.Mesg_Token_Tbl_Type
, x_change_line_rec       OUT NOCOPY Eng_Eco_Pub.Change_Line_Rec_Type
, x_change_line_unexp_rec OUT NOCOPY Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
, x_mesg_token_tbl        OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_return_status         OUT NOCOPY VARCHAR2
);



/****************************************************************************
*  PERFORM WRITE
*****************************************************************************/

PROCEDURE Perform_Writes
(  p_change_line_rec             IN  Eng_Eco_Pub.Change_Line_Rec_Type
 , p_change_line_unexp_rec       IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , x_mesg_token_tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status               OUT NOCOPY VARCHAR2
) ;


/****************************************************************************
*  OTHERS
*****************************************************************************/

PROCEDURE Insert_Row
(  p_change_line_rec             IN  Eng_Eco_Pub.Change_Line_Rec_Type
 , p_change_line_unexp_rec       IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , x_mesg_token_tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status               OUT NOCOPY VARCHAR2
) ;


PROCEDURE Update_Row
(  p_change_line_rec             IN  Eng_Eco_Pub.Change_Line_Rec_Type
 , p_change_line_unexp_rec       IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , x_mesg_token_tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status               OUT NOCOPY VARCHAR2
) ;


PROCEDURE Delete_Row
(  p_change_line_rec             IN  Eng_Eco_Pub.Change_Line_Rec_Type
 , p_change_line_unexp_rec       IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , x_mesg_token_tbl              OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status               OUT NOCOPY VARCHAR2
) ;

PROCEDURE Change_Subjects
(
  p_change_line_rec            IN     Eng_Eco_Pub.Change_Line_Rec_Type
, p_change_line_unexp_rec      IN     Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
, x_change_subject_unexp_rec   IN OUT NOCOPY Eng_Eco_Pub.Change_Subject_Unexp_Rec_Type
, x_mesg_token_tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type -- 4033384
, x_return_status              IN OUT NOCOPY VARCHAR2
);

-- ****************************************************************** --
--  API name    : Get_Concatenated_Subjects                           --
--  Type        : Public                                              --
--  Pre-reqs    : None.                                               --
--  Function    : Gets the concatenated subject value for display     --
--  Parameters  :                                                     --
--       IN     :                                                     --
--                p_change_id            NUMBER   Required            --
--                p_change_line_id       NUMBER                       --
--                p_subject_id           NUMBER                       --
--  Version     :                                                     --
--                Current version       1.0                           --
--                Initial version       1.0                           --
--                                                                    --
--  Notes       : None                                                --
-- ****************************************************************** --
FUNCTION Get_Concatenated_Subjects (
    p_change_id     NUMBER
  , p_change_line_id    NUMBER
  , p_subject_id    NUMBER
) RETURN VARCHAR2;

-- Fix to bug no: 6038875
FUNCTION Get_Concatenated_Subjects_URL (
    p_change_id            IN NUMBER
  , p_change_line_id       IN NUMBER
) RETURN VARCHAR2;

END ENG_Change_Line_Util ;


/
