--------------------------------------------------------
--  DDL for Package ENG_ECO_REVISION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_ECO_REVISION_UTIL" AUTHID CURRENT_USER AS
/* $Header: ENGUREVS.pls 115.12 2002/12/12 18:11:40 akumar ship $ */

--  Attributes global constants

G_ATTRIBUTE11                 CONSTANT NUMBER := 1;
G_ATTRIBUTE12                 CONSTANT NUMBER := 2;
G_ATTRIBUTE13                 CONSTANT NUMBER := 3;
G_ATTRIBUTE14                 CONSTANT NUMBER := 4;
G_ATTRIBUTE15                 CONSTANT NUMBER := 5;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 6;
G_PROGRAM                     CONSTANT NUMBER := 7;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 8;
G_REQUEST                     CONSTANT NUMBER := 9;
G_REVISION                    CONSTANT NUMBER := 10;
G_CHANGE_NOTICE               CONSTANT NUMBER := 11;
G_ORGANIZATION                CONSTANT NUMBER := 12;
G_REV                         CONSTANT NUMBER := 13;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 14;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 15;
G_CREATION_DATE               CONSTANT NUMBER := 16;
G_CREATED_BY                  CONSTANT NUMBER := 17;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 18;
G_COMMENTS                    CONSTANT NUMBER := 19;
G_ATTRIBUTE_CATEGORY          CONSTANT NUMBER := 20;
G_ATTRIBUTE1                  CONSTANT NUMBER := 21;
G_ATTRIBUTE2                  CONSTANT NUMBER := 22;
G_ATTRIBUTE3                  CONSTANT NUMBER := 23;
G_ATTRIBUTE4                  CONSTANT NUMBER := 24;
G_ATTRIBUTE5                  CONSTANT NUMBER := 25;
G_ATTRIBUTE6                  CONSTANT NUMBER := 26;
G_ATTRIBUTE7                  CONSTANT NUMBER := 27;
G_ATTRIBUTE8                  CONSTANT NUMBER := 28;
G_ATTRIBUTE9                  CONSTANT NUMBER := 29;
G_ATTRIBUTE10                 CONSTANT NUMBER := 30;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 31;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := NULL ---FND_API.G_MISS_NUM
,   p_eco_revision_rec              IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
,   p_old_eco_revision_rec          IN  ENG_Eco_PUB.Eco_Revision_Rec_Type :=
                                        ENG_Eco_PUB.G_MISS_ECO_REVISION_REC
,   x_eco_revision_rec              IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_eco_revision_rec              IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
,   p_old_eco_revision_rec          IN  ENG_Eco_PUB.Eco_Revision_Rec_Type :=
                                        ENG_Eco_PUB.G_MISS_ECO_REVISION_REC
,   x_eco_revision_rec              IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Rec_Type
);

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_eco_revision_rec              IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
) RETURN ENG_Eco_PUB.Eco_Revision_Rec_Type;

--  Function Query_Row

PROCEDURE Query_Row
(   p_Change_Notice	IN  VARCHAR2
 ,  p_Organization_Id	IN  NUMBER
 ,  p_Revision		IN  VARCHAR2
 ,  x_Eco_Revision_Rec	OUT NOCOPY Eng_Eco_Pub.Eco_Revision_Rec_Type
 ,  x_Eco_Rev_Unexp_Rec	OUT NOCOPY Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
 ,  x_Return_Status	OUT NOCOPY VARCHAR2
);

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_eco_revision_rec              IN  ENG_Eco_PUB.Eco_Revision_Rec_Type
,   x_eco_revision_rec              IN OUT NOCOPY  ENG_Eco_PUB.Eco_Revision_Rec_Type
 ,  x_err_text                      OUT NOCOPY VARCHAR2
);

PROCEDURE Perform_Writes
(  p_eco_revision_rec   IN  Eng_Eco_Pub.Eco_Revision_Rec_Type
 , p_eco_rev_unexp_rec  IN  Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type
 , p_control_rec	IN  BOM_BO_PUB.Control_Rec_Type
			    := BOM_BO_PUB.G_DEFAULT_CONTROL_REC
 , x_Mesg_Token_Tbl     OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_Return_Status      OUT NOCOPY VARCHAR2
);


END ENG_Eco_Revision_Util;

 

/
