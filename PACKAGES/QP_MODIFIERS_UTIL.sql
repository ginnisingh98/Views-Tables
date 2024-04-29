--------------------------------------------------------
--  DDL for Package QP_MODIFIERS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_MODIFIERS_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXUMLLS.pls 120.2.12010000.1 2008/07/28 11:56:42 appldev ship $ */

--  Attributes global constants

G_ARITHMETIC_OPERATOR         CONSTANT NUMBER := 1;
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
G_AUTOMATIC                   CONSTANT NUMBER := 17;
--G_BASE_QTY                    CONSTANT NUMBER := 18;
--G_BASE_UOM                    CONSTANT NUMBER := 19;
G_COMMENTS                    CONSTANT NUMBER := 20;
G_CONTEXT                     CONSTANT NUMBER := 21;
G_CREATED_BY                  CONSTANT NUMBER := 22;
G_CREATION_DATE               CONSTANT NUMBER := 23;
G_EFFECTIVE_PERIOD_UOM        CONSTANT NUMBER := 24;
G_END_DATE_ACTIVE             CONSTANT NUMBER := 25;
G_ESTIM_ACCRUAL_RATE          CONSTANT NUMBER := 26;
G_GENERATE_USING_FORMULA      CONSTANT NUMBER := 27;
G_INVENTORY_ITEM              CONSTANT NUMBER := 28;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 29;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 30;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 31;
G_LIST_HEADER                 CONSTANT NUMBER := 32;
G_LIST_LINE                   CONSTANT NUMBER := 33;
G_LIST_LINE_TYPE              CONSTANT NUMBER := 34;
G_LIST_PRICE                  CONSTANT NUMBER := 35;
G_MODIFIER_LEVEL              CONSTANT NUMBER := 36;
G_NUMBER_EFFECTIVE_PERIODS    CONSTANT NUMBER := 37;
G_OPERAND                     CONSTANT NUMBER := 38;
G_ORGANIZATION                CONSTANT NUMBER := 39;
G_OVERRIDE                    CONSTANT NUMBER := 40;
G_PERCENT_PRICE               CONSTANT NUMBER := 41;
G_PRICE_BREAK_TYPE            CONSTANT NUMBER := 42;
G_PRICE_BY_FORMULA            CONSTANT NUMBER := 43;
G_PRIMARY_UOM                 CONSTANT NUMBER := 44;
G_PRINT_ON_INVOICE            CONSTANT NUMBER := 45;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 46;
G_PROGRAM                     CONSTANT NUMBER := 47;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 48;
G_REBATE_TRANSACTION_TYPE     CONSTANT NUMBER := 49;
G_RELATED_ITEM                CONSTANT NUMBER := 50;
G_RELATIONSHIP_TYPE           CONSTANT NUMBER := 51;
G_REPRICE                     CONSTANT NUMBER := 52;
G_REQUEST                     CONSTANT NUMBER := 53;
G_REVISION                    CONSTANT NUMBER := 54;
G_REVISION_DATE               CONSTANT NUMBER := 55;
G_REVISION_REASON             CONSTANT NUMBER := 56;
G_START_DATE_ACTIVE           CONSTANT NUMBER := 57;
G_SUBSTITUTION_ATTRIBUTE      CONSTANT NUMBER := 58;
G_SUBSTITUTION_CONTEXT        CONSTANT NUMBER := 59;
G_SUBSTITUTION_VALUE          CONSTANT NUMBER := 60;
G_ACCRUAL_FLAG		          CONSTANT NUMBER := 61;
G_PRICING_GROUP_SEQUENCE      CONSTANT NUMBER := 62;
G_INCOMPATIBILITY_GRP_CODE    CONSTANT NUMBER := 63;
G_LIST_LINE_NO                CONSTANT NUMBER := 64;
G_PRICING_PHASE			CONSTANT NUMBER := 65;
G_PRODUCT_PRECEDENCE          CONSTANT NUMBER := 66;
G_EXPIRATION_PERIOD_START_DATE  CONSTANT NUMBER := 67;
G_NUMBER_EXPIRATION_PERIODS   CONSTANT NUMBER := 68;
G_EXPIRATION_PERIOD_UOM       CONSTANT NUMBER := 69;
G_EXPIRATION_DATE             CONSTANT NUMBER := 70;
G_ESTIM_GL_VALUE              CONSTANT NUMBER := 71;
G_BENEFIT_PRICE_LIST_LINE     CONSTANT NUMBER := 72;
--G_RECURRING_FLAG              CONSTANT NUMBER := 73;
G_BENEFIT_LIMIT               CONSTANT NUMBER := 74;
G_CHARGE_TYPE                 CONSTANT NUMBER := 75;
G_CHARGE_SUBTYPE              CONSTANT NUMBER := 76;
G_BENEFIT_QTY                 CONSTANT NUMBER := 77;
G_BENEFIT_UOM                 CONSTANT NUMBER := 78;
G_ACCRUAL_CONVERSION_RATE     CONSTANT NUMBER := 79;
G_PRORATION_TYPE              CONSTANT NUMBER := 80;
G_INCLUDE_ON_RETURNS_FLAG     CONSTANT NUMBER := 81;
G_FROM_RLTD_MODIFIER          CONSTANT NUMBER := 82;
G_TO_RLTD_MODIFIER            CONSTANT NUMBER := 83;
G_RLTD_MODIFIER_GRP_NO        CONSTANT NUMBER := 84;
G_RLTD_MODIFIER_GRP_TYPE      CONSTANT NUMBER := 85;
G_RLTD_MODIFIER_ID            CONSTANT NUMBER := 90;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 89;
G_QUALIFICATION_IND           CONSTANT NUMBER := 87;
G_NET_AMOUNT                  CONSTANT NUMBER := 86;
G_ACCUM_ATTRIBUTE             CONSTANT NUMBER := 88;
G_CONTINUOUS_PRICE_BREAK_FLAG CONSTANT NUMBER := 89; --Continuous Price Breaks

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
,   p_old_MODIFIERS_rec             IN  QP_Modifiers_PUB.Modifiers_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIERS_REC
,   x_MODIFIERS_rec                 OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifiers_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
,   p_old_MODIFIERS_rec             IN  QP_Modifiers_PUB.Modifiers_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIERS_REC
,   x_MODIFIERS_rec                 OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifiers_Rec_Type
);

--  Function Complete_Record

FUNCTION Complete_Record
(   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
,   p_old_MODIFIERS_rec             IN  QP_Modifiers_PUB.Modifiers_Rec_Type
) RETURN QP_Modifiers_PUB.Modifiers_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
) RETURN QP_Modifiers_PUB.Modifiers_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_list_line_id                  IN  NUMBER
);

--  Function Query_Row

FUNCTION Query_Row
(   p_list_line_id                  IN  NUMBER
) RETURN QP_Modifiers_PUB.Modifiers_Rec_Type;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_list_line_id                  IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_list_header_id                IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN QP_Modifiers_PUB.Modifiers_Tbl_Type;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
,   x_MODIFIERS_rec                 OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.Modifiers_Rec_Type
);

--  Function Get_Values

FUNCTION Get_Values
(   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
,   p_old_MODIFIERS_rec             IN  QP_Modifiers_PUB.Modifiers_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIERS_REC
) RETURN QP_Modifiers_PUB.Modifiers_Val_Rec_Type;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
,   p_MODIFIERS_val_rec             IN  QP_Modifiers_PUB.Modifiers_Val_Rec_Type
) RETURN QP_Modifiers_PUB.Modifiers_Rec_Type;



Procedure Pre_Write_Process
(   p_MODIFIERS_rec                      IN  QP_Modifiers_PUB.MODIFIERS_rec_Type
,   p_old_MODIFIERS_rec                  IN  QP_Modifiers_PUB.MODIFIERS_rec_Type
		:= QP_Modifiers_PUB.G_MISS_MODIFIERS_rec
,   x_MODIFIERS_rec                      OUT NOCOPY /* file.sql.39 change */ QP_Modifiers_PUB.MODIFIERS_rec_Type
					);
------------------fix for bug 3756625
Procedure Log_Update_Phases_DL
( p_MODIFIERS_rec               IN QP_Modifiers_PUB.MODIFIERS_rec_Type
 ,x_return_status               OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

END QP_Modifiers_Util;

/
