--------------------------------------------------------
--  DDL for Package ENG_REF_DESIGNATOR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_REF_DESIGNATOR_UTIL" AUTHID CURRENT_USER AS
/* $Header: ENGURFDS.pls 115.7 2002/12/12 18:20:20 akumar ship $ */

--  Attributes global constants

G_REF_DESIGNATOR              CONSTANT NUMBER := 1;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 2;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 3;
G_CREATION_DATE               CONSTANT NUMBER := 4;
G_CREATED_BY                  CONSTANT NUMBER := 5;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 6;
G_REF_DESIGNATOR_COMMENT      CONSTANT NUMBER := 7;
G_CHANGE_NOTICE               CONSTANT NUMBER := 8;
G_COMPONENT_SEQUENCE          CONSTANT NUMBER := 9;
G_ACD_TYPE                    CONSTANT NUMBER := 10;
G_REQUEST                     CONSTANT NUMBER := 11;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 12;
G_PROGRAM                     CONSTANT NUMBER := 13;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 14;
G_ATTRIBUTE_CATEGORY          CONSTANT NUMBER := 15;
G_ATTRIBUTE1                  CONSTANT NUMBER := 16;
G_ATTRIBUTE2                  CONSTANT NUMBER := 17;
G_ATTRIBUTE3                  CONSTANT NUMBER := 18;
G_ATTRIBUTE4                  CONSTANT NUMBER := 19;
G_ATTRIBUTE5                  CONSTANT NUMBER := 20;
G_ATTRIBUTE6                  CONSTANT NUMBER := 21;
G_ATTRIBUTE7                  CONSTANT NUMBER := 22;
G_ATTRIBUTE8                  CONSTANT NUMBER := 23;
G_ATTRIBUTE9                  CONSTANT NUMBER := 24;
G_ATTRIBUTE10                 CONSTANT NUMBER := 25;
G_ATTRIBUTE11                 CONSTANT NUMBER := 26;
G_ATTRIBUTE12                 CONSTANT NUMBER := 27;
G_ATTRIBUTE13                 CONSTANT NUMBER := 28;
G_ATTRIBUTE14                 CONSTANT NUMBER := 29;
G_ATTRIBUTE15                 CONSTANT NUMBER := 30;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 31;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER :=NULL -- FND_API.G_MISS_NUM
,   p_ref_designator_rec            IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
,   p_old_ref_designator_rec        IN  Bom_Bo_Pub.Ref_Designator_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_REF_DESIGNATOR_REC
,   x_ref_designator_rec            IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_ref_designator_rec            IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
,   p_old_ref_designator_rec        IN  Bom_Bo_Pub.Ref_Designator_Rec_Type :=
                                        Bom_Bo_Pub.G_MISS_REF_DESIGNATOR_REC
,   x_ref_designator_rec            IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Rec_Type
);

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_ref_designator_rec            IN  Bom_Bo_Pub.Ref_Designator_Rec_Type
) RETURN Bom_Bo_Pub.Ref_Designator_Rec_Type;

--  Function Query_Row

PROCEDURE Query_Row
(   p_ref_designator            IN  VARCHAR2
,   p_component_sequence_id     IN  NUMBER
,   p_acd_type                  IN  NUMBER
,   x_Ref_Designator_Rec	OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Rec_Type
,   x_Ref_Desg_Unexp_Rec	OUT NOCOPY Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
,   x_Return_Status		OUT NOCOPY VARCHAR2
);

PROCEDURE Perform_Writes
(  p_ref_designator_rec         IN  Bom_Bo_Pub.Ref_Designator_rec_Type
 , p_ref_desg_unexp_rec         IN  Bom_Bo_Pub.Ref_Desg_Unexposed_Rec_Type
 , x_mesg_token_tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status              OUT NOCOPY VARCHAR2
);

END ENG_Ref_Designator_Util;

 

/
