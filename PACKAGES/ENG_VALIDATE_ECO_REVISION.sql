--------------------------------------------------------
--  DDL for Package ENG_VALIDATE_ECO_REVISION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_VALIDATE_ECO_REVISION" AUTHID CURRENT_USER AS
/* $Header: ENGLREVS.pls 115.11 2002/12/12 17:01:00 akumar ship $ */

--  Procedure Entity

PROCEDURE Check_Entity
(   x_return_status		OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_eco_revision_rec		IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
,   p_Eco_Rev_Unexp_Rec		IN  ENG_Eco_PUB.Eco_Rev_Unexposed_Rec_Type
);

--  Procedure Attributes

PROCEDURE Check_Attributes
(   x_return_status		OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_eco_revision_rec		IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
);

--  Procedure Entity_Delete

PROCEDURE Check_Entity_Delete
(   x_return_status             OUT NOCOPY VARCHAR2
,   x_Mesg_Token_Tbl		OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   p_eco_revision_rec          IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
,   p_Eco_Rev_Unexp_Rec		IN  Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
);

PROCEDURE Check_Existence
(  p_eco_revision_rec           IN  Eng_Eco_Pub.Eco_Revision_Rec_Type
 , p_eco_rev_unexp_rec          IN  Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
 , x_old_eco_revision_rec       IN OUT NOCOPY Eng_Eco_Pub.Eco_Revision_Rec_Type
 , x_old_eco_rev_unexp_rec      IN OUT NOCOPY Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status              OUT NOCOPY VARCHAR2
);

PROCEDURE Check_Access
(  p_revision           IN  VARCHAR2
 , p_change_notice      IN  VARCHAR2
 , p_organization_id    IN  NUMBER
 , x_Mesg_Token_Tbl     OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status      OUT NOCOPY VARCHAR2
);

PROCEDURE Check_Required
(  x_return_status      OUT NOCOPY VARCHAR2
 , p_eco_revision_rec   IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
 , x_mesg_token_tbl     OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
);

END ENG_Validate_Eco_Revision;

 

/
