--------------------------------------------------------
--  DDL for Package QP_QUALIFIER_RULES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_QUALIFIER_RULES_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXUQPRS.pls 120.1 2005/06/13 05:00:44 appldev  $ */

--  Attributes global constants

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
G_CONTEXT                     CONSTANT NUMBER := 16;
G_CREATED_BY                  CONSTANT NUMBER := 17;
G_CREATION_DATE               CONSTANT NUMBER := 18;
G_DESCRIPTION                 CONSTANT NUMBER := 19;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 20;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 21;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 22;
G_NAME                        CONSTANT NUMBER := 23;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 24;
G_PROGRAM                     CONSTANT NUMBER := 25;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 26;
G_QUALIFIER_RULE              CONSTANT NUMBER := 27;
G_REQUEST                     CONSTANT NUMBER := 28;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 29;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   p_old_QUALIFIER_RULES_rec       IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIER_RULES_REC
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   p_old_QUALIFIER_RULES_rec       IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIER_RULES_REC
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
);

--  Function Complete_Record

FUNCTION Complete_Record
(   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   p_old_QUALIFIER_RULES_rec       IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
) RETURN QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
) RETURN QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_qualifier_rule_id             IN  NUMBER
);

--  Function Query_Row

FUNCTION Query_Row
(   p_qualifier_rule_id             IN  NUMBER
) RETURN QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   x_QUALIFIER_RULES_rec           OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
);

--  Function Get_Values

FUNCTION Get_Values
(   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   p_old_QUALIFIER_RULES_rec       IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIER_RULES_REC
) RETURN QP_Qualifier_Rules_PUB.Qualifier_Rules_Val_Rec_Type;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_QUALIFIER_RULES_rec           IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type
,   p_QUALIFIER_RULES_val_rec       IN  QP_Qualifier_Rules_PUB.Qualifier_Rules_Val_Rec_Type
) RETURN QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type;

END QP_Qualifier_Rules_Util;

 

/
