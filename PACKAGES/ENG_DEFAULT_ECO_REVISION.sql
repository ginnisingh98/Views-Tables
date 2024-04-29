--------------------------------------------------------
--  DDL for Package ENG_DEFAULT_ECO_REVISION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_DEFAULT_ECO_REVISION" AUTHID CURRENT_USER AS
/* $Header: ENGDREVS.pls 115.10 2002/11/24 12:10:21 bbontemp ship $ */

--  Procedure Attributes

PROCEDURE Attribute_Defaulting
(   p_eco_revision_rec  IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
,   p_Eco_Rev_Unexp_Rec IN  Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
,   x_eco_revision_rec  IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Rec_Type
,   x_Eco_Rev_Unexp_Rec IN OUT NOCOPY Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
,   x_Mesg_Token_Tbl    OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_Return_Status     OUT NOCOPY VARCHAR2
);

PROCEDURE Populate_Null_Columns
(   p_eco_revision_rec          IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
,   p_old_eco_revision_rec      IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
,   p_Eco_Rev_Unexp_Rec         IN  Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
,   p_Old_Eco_Rev_Unexp_Rec     IN  Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
,   x_Eco_Revision_Rec          IN OUT NOCOPY Eng_Eco_Pub.Eco_Revision_Rec_Type
,   x_Eco_Rev_Unexp_Rec         IN OUT NOCOPY Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
);


END ENG_Default_Eco_Revision;

 

/
