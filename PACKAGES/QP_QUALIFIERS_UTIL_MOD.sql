--------------------------------------------------------
--  DDL for Package QP_QUALIFIERS_UTIL_MOD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_QUALIFIERS_UTIL_MOD" AUTHID CURRENT_USER AS
/* $Header: QPXUQRSS.pls 120.0 2005/06/02 00:42:19 appldev noship $ */

--  Attributes global constants
/*
G_ATTRIBUTE1                  CONSTANT NUMBER := 1;
G_ATTRIBUTE10                 CONSTANT NUMBER := 2;
G_ATTRIBUTE11                 CONSTANT NUMBER := 3;
G_ATTRIBUTE12                 CONSTANT NUMBER := 4;
G_ATTRIBUTE13                 CONSTANT NUMBER := 5;
G_ATTRIBUTE14                 CONSTANT NUMBER := 6;
G_ATTRIBUTE15                 CONSTANT NUMBER := 7;
G_ATTRIBUTE2                  CONSTANT NUMBER := 8;
G_ATTRIBUTE3                  CONSTANT NUMBER := 9;
G_ATTRIBUTE4                  CONSTANT NUMBER := 10;
G_ATTRIBUTE5                  CONSTANT NUMBER := 11;
G_ATTRIBUTE6                  CONSTANT NUMBER := 12;
G_ATTRIBUTE7                  CONSTANT NUMBER := 13;
G_ATTRIBUTE8                  CONSTANT NUMBER := 14;
G_ATTRIBUTE9                  CONSTANT NUMBER := 15;
G_COMPARISON_OPERATOR         CONSTANT NUMBER := 16;
G_CONTEXT                     CONSTANT NUMBER := 17;
G_CREATED_BY                  CONSTANT NUMBER := 18;
G_CREATED_FROM_RULE           CONSTANT NUMBER := 19;
G_CREATION_DATE               CONSTANT NUMBER := 20;
G_END_DATE_ACTIVE             CONSTANT NUMBER := 21;
G_EXCLUDER                    CONSTANT NUMBER := 22;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 23;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 24;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 25;
G_LIST_HEADER                 CONSTANT NUMBER := 26;
G_LIST_LINE                   CONSTANT NUMBER := 27;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 28;
G_PROGRAM                     CONSTANT NUMBER := 29;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 30;
G_QUALIFIER_ATTRIBUTE         CONSTANT NUMBER := 31;
G_QUALIFIER_ATTR_VALUE        CONSTANT NUMBER := 32;
G_QUALIFIER_CONTEXT           CONSTANT NUMBER := 33;
G_QUALIFIER_GROUPING_NO       CONSTANT NUMBER := 34;
G_QUALIFIER                   CONSTANT NUMBER := 35;
G_QUALIFIER_RULE              CONSTANT NUMBER := 36;
G_REQUEST                     CONSTANT NUMBER := 37;
G_START_DATE_ACTIVE           CONSTANT NUMBER := 38;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 39;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_QUALIFIERS_rec                IN  QP_Modifiers_PUB.Qualifiers_Rec_Type
,   p_old_QUALIFIERS_rec            IN  QP_Modifiers_PUB.Qualifiers_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_QUALIFIERS_REC
,   x_QUALIFIERS_rec                OUT QP_Modifiers_PUB.Qualifiers_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_QUALIFIERS_rec                IN  QP_Modifiers_PUB.Qualifiers_Rec_Type
,   p_old_QUALIFIERS_rec            IN  QP_Modifiers_PUB.Qualifiers_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_QUALIFIERS_REC
,   x_QUALIFIERS_rec                OUT QP_Modifiers_PUB.Qualifiers_Rec_Type
);

--  Function Complete_Record

FUNCTION Complete_Record
(   p_QUALIFIERS_rec                IN  QP_Modifiers_PUB.Qualifiers_Rec_Type
,   p_old_QUALIFIERS_rec            IN  QP_Modifiers_PUB.Qualifiers_Rec_Type
) RETURN QP_Modifiers_PUB.Qualifiers_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_QUALIFIERS_rec                IN  QP_Modifiers_PUB.Qualifiers_Rec_Type
) RETURN QP_Modifiers_PUB.Qualifiers_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_QUALIFIERS_rec                IN  QP_Modifiers_PUB.Qualifiers_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_QUALIFIERS_rec                IN  QP_Modifiers_PUB.Qualifiers_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_qualifier_id                  IN  NUMBER
);

--  Function Query_Row

FUNCTION Query_Row
(   p_qualifier_id                  IN  NUMBER
) RETURN QP_Modifiers_PUB.Qualifiers_Rec_Type;

--  Function Query_Rows

--
*/
FUNCTION Query_Rows
(   p_qualifier_id                  IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_list_header_id                IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;

--  Procedure       lock_Row
--
/*
PROCEDURE Lock_Row
(   x_return_status                 OUT VARCHAR2
,   p_QUALIFIERS_rec                IN  QP_Modifiers_PUB.Qualifiers_Rec_Type
,   x_QUALIFIERS_rec                OUT QP_Modifiers_PUB.Qualifiers_Rec_Type
);

--  Function Get_Values

FUNCTION Get_Values
(   p_QUALIFIERS_rec                IN  QP_Modifiers_PUB.Qualifiers_Rec_Type
,   p_old_QUALIFIERS_rec            IN  QP_Modifiers_PUB.Qualifiers_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_QUALIFIERS_REC
) RETURN QP_Modifiers_PUB.Qualifiers_Val_Rec_Type;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_QUALIFIERS_rec                IN  QP_Modifiers_PUB.Qualifiers_Rec_Type
,   p_QUALIFIERS_val_rec            IN  QP_Modifiers_PUB.Qualifiers_Val_Rec_Type
) RETURN QP_Modifiers_PUB.Qualifiers_Rec_Type;
*/
END QP_Qualifiers_Util_Mod;

 

/
