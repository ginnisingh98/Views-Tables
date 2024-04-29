--------------------------------------------------------
--  DDL for Package QP_PRICING_ATTR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PRICING_ATTR_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXUPRAS.pls 120.1.12010000.1 2008/07/28 11:57:23 appldev ship $ */

--  Attributes global constants

G_ACCUMULATE                  CONSTANT NUMBER := 1;
G_ATTRIBUTE1                  CONSTANT NUMBER := 2;
G_ATTRIBUTE10                 CONSTANT NUMBER := 3;
G_ATTRIBUTE11                 CONSTANT NUMBER := 4;
G_ATTRIBUTE12                 CONSTANT NUMBER := 5;
G_ATTRIBUTE13                 CONSTANT NUMBER := 6;
G_ATTRIBUTE14                 CONSTANT NUMBER := 7;
G_ATTRIBUTE15                 CONSTANT NUMBER := 8;
G_ATTRIBUTE2                  CONSTANT NUMBER := 9;
G_ATTRIBUTE3                  CONSTANT NUMBER := 10;
G_ATTRIBUTE4                  CONSTANT NUMBER := 11;
G_ATTRIBUTE5                  CONSTANT NUMBER := 12;
G_ATTRIBUTE6                  CONSTANT NUMBER := 13;
G_ATTRIBUTE7                  CONSTANT NUMBER := 14;
G_ATTRIBUTE8                  CONSTANT NUMBER := 15;
G_ATTRIBUTE9                  CONSTANT NUMBER := 16;
G_ATTRIBUTE_GROUPING_NO       CONSTANT NUMBER := 17;
G_CONTEXT                     CONSTANT NUMBER := 18;
G_CREATED_BY                  CONSTANT NUMBER := 19;
G_CREATION_DATE               CONSTANT NUMBER := 20;
G_EXCLUDER                    CONSTANT NUMBER := 21;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 22;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 23;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 24;
G_LIST_LINE                   CONSTANT NUMBER := 25;
G_PRICING_ATTRIBUTE           CONSTANT NUMBER := 26;
G_PRICING_ATTRIBUTE_CONTEXT   CONSTANT NUMBER := 27;
--G_PRICING_ATTRIBUTE           CONSTANT NUMBER := 28;
G_PRICING_ATTR_VALUE_FROM     CONSTANT NUMBER := 29;
G_PRICING_ATTR_VALUE_TO       CONSTANT NUMBER := 30;
G_PRODUCT_ATTRIBUTE           CONSTANT NUMBER := 31;
G_PRODUCT_ATTRIBUTE_CONTEXT   CONSTANT NUMBER := 32;
G_PRODUCT_ATTR_VALUE          CONSTANT NUMBER := 33;
G_PRODUCT_UOM                 CONSTANT NUMBER := 34;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 35;
G_PROGRAM                     CONSTANT NUMBER := 36;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 37;
G_REQUEST                     CONSTANT NUMBER := 38;
G_PRODUCT_ATTRIBUTE_DATATYPE  CONSTANT NUMBER := 39;
G_PRICING_ATTRIBUTE_DATATYPE  CONSTANT NUMBER := 40;
G_COMPARISON_OPERATOR         CONSTANT NUMBER := 41;
G_LIST_HEADER         		CONSTANT NUMBER := 42;
G_PRICING_PHASE         		CONSTANT NUMBER := 43;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 44;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec          IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_PRICING_ATTR_REC
,   x_PRICING_ATTR_rec              OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Pricing_Attr_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec          IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_PRICING_ATTR_REC
,   x_PRICING_ATTR_rec              OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Pricing_Attr_Rec_Type
);

--  Function Complete_Record

FUNCTION Complete_Record
(   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec          IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
) RETURN QP_Modifiers_PUB.Pricing_Attr_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
) RETURN QP_Modifiers_PUB.Pricing_Attr_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_pricing_attribute_id          IN  NUMBER
);

--  Function Query_Row

FUNCTION Query_Row
(   p_pricing_attribute_id          IN  NUMBER
) RETURN QP_Modifiers_PUB.Pricing_Attr_Rec_Type;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_pricing_attribute_id          IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_list_line_id                  IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
,   x_PRICING_ATTR_rec              OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Pricing_Attr_Rec_Type
);

--  Function Get_Values

FUNCTION Get_Values
(   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec          IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_PRICING_ATTR_REC
) RETURN QP_Modifiers_PUB.Pricing_Attr_Val_Rec_Type;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
,   p_PRICING_ATTR_val_rec          IN  QP_Modifiers_PUB.Pricing_Attr_Val_Rec_Type
) RETURN QP_Modifiers_PUB.Pricing_Attr_Rec_Type;

Procedure Pre_Write_Process
(   p_PRICING_ATTR_rec                      IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec                  IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type :=
						QP_Modifiers_PUB.G_MISS_Pricing_Attr_REC
,   x_PRICING_ATTR_rec                      OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Pricing_Attr_Rec_Type
);

END QP_Pricing_Attr_Util;

/
