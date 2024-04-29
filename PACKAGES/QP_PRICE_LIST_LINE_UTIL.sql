--------------------------------------------------------
--  DDL for Package QP_PRICE_LIST_LINE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PRICE_LIST_LINE_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXUPLLS.pls 120.3.12010000.1 2008/07/28 11:57:13 appldev ship $ */

--  Attributes global constants

G_ACCRUAL_QTY                 CONSTANT NUMBER := 1;
G_ACCRUAL_TYPE                CONSTANT NUMBER := 2;
G_ACCRUAL_UOM                 CONSTANT NUMBER := 3;
G_ACCUM_TO_ACCR_CONV_RATE     CONSTANT NUMBER := 4;
G_ARITHMETIC_OPERATOR         CONSTANT NUMBER := 5;
G_ATTRIBUTE1                  CONSTANT NUMBER := 6;
G_ATTRIBUTE10                 CONSTANT NUMBER := 7;
G_ATTRIBUTE11                 CONSTANT NUMBER := 8;
G_ATTRIBUTE12                 CONSTANT NUMBER := 9;
G_ATTRIBUTE13                 CONSTANT NUMBER := 10;
G_ATTRIBUTE14                 CONSTANT NUMBER := 11;
G_ATTRIBUTE15                 CONSTANT NUMBER := 12;
G_ATTRIBUTE2                  CONSTANT NUMBER := 13;
G_ATTRIBUTE3                  CONSTANT NUMBER := 14;
G_ATTRIBUTE4                  CONSTANT NUMBER := 15;
G_ATTRIBUTE5                  CONSTANT NUMBER := 16;
G_ATTRIBUTE6                  CONSTANT NUMBER := 17;
G_ATTRIBUTE7                  CONSTANT NUMBER := 18;
G_ATTRIBUTE8                  CONSTANT NUMBER := 19;
G_ATTRIBUTE9                  CONSTANT NUMBER := 20;
G_AUTOMATIC                   CONSTANT NUMBER := 21;
G_BASE_QTY                    CONSTANT NUMBER := 22;
G_BASE_UOM                    CONSTANT NUMBER := 23;
G_COMMENTS                    CONSTANT NUMBER := 24;
G_CONTEXT                     CONSTANT NUMBER := 25;
G_CREATED_BY                  CONSTANT NUMBER := 26;
G_CREATION_DATE               CONSTANT NUMBER := 27;
G_EFFECTIVE_PERIOD_UOM        CONSTANT NUMBER := 28;
G_END_DATE_ACTIVE             CONSTANT NUMBER := 29;
G_ESTIM_ACCRUAL_RATE          CONSTANT NUMBER := 30;
G_GENERATE_USING_FORMULA      CONSTANT NUMBER := 31;
G_GL_CLASS                    CONSTANT NUMBER := 32;
G_INVENTORY_ITEM              CONSTANT NUMBER := 33;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 34;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 35;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 36;
G_LIST_HEADER                 CONSTANT NUMBER := 37;
G_LIST_LINE                   CONSTANT NUMBER := 38;
G_LIST_LINE_TYPE              CONSTANT NUMBER := 39;
G_LIST_PRICE                  CONSTANT NUMBER := 40;
G_LIST_PRICE_UOM              CONSTANT NUMBER := 41;
G_MODIFIER_LEVEL              CONSTANT NUMBER := 42;
G_NEW_PRICE                   CONSTANT NUMBER := 43;
G_NUMBER_EFFECTIVE_PERIODS    CONSTANT NUMBER := 44;
G_OPERAND                     CONSTANT NUMBER := 45;
G_ORGANIZATION                CONSTANT NUMBER := 46;
G_OVERRIDE                    CONSTANT NUMBER := 47;
G_PERCENT_PRICE               CONSTANT NUMBER := 48;
G_PRICE_BREAK_TYPE            CONSTANT NUMBER := 49;
G_PRICE_BY_FORMULA            CONSTANT NUMBER := 50;
G_PRIMARY_UOM                 CONSTANT NUMBER := 51;
G_PRINT_ON_INVOICE            CONSTANT NUMBER := 52;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 53;
G_PROGRAM                     CONSTANT NUMBER := 54;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 55;
G_REBATE_SUBTYPE              CONSTANT NUMBER := 56;
G_REBATE_TRANSACTION_TYPE     CONSTANT NUMBER := 57;
G_RELATED_ITEM                CONSTANT NUMBER := 58;
G_RELATIONSHIP_TYPE           CONSTANT NUMBER := 59;
G_REPRICE                     CONSTANT NUMBER := 60;
G_REQUEST                     CONSTANT NUMBER := 61;
G_REVISION                    CONSTANT NUMBER := 62;
G_REVISION_DATE               CONSTANT NUMBER := 63;
G_REVISION_REASON             CONSTANT NUMBER := 64;
G_START_DATE_ACTIVE           CONSTANT NUMBER := 65;
G_SUBSTITUTION_ATTRIBUTE      CONSTANT NUMBER := 66;
G_SUBSTITUTION_CONTEXT        CONSTANT NUMBER := 67;
G_SUBSTITUTION_VALUE          CONSTANT NUMBER := 68;
G_FROM_RLTD_MODIFIER          CONSTANT NUMBER := 69;
G_RLTD_MODIFIER_GROUP_NO      CONSTANT NUMBER := 70;
G_PRODUCT_PRECEDENCE          CONSTANT NUMBER := 71;
G_QUALIFICATION_IND           CONSTANT NUMBER := 72;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 73;
G_RECURRING_VALUE             CONSTANT NUMBER := 74; -- block pricing
G_CUSTOMER_ITEM_ID            CONSTANT NUMBER := 75;
G_BREAK_UOM_CODE              CONSTANT NUMBER := 76; -- OKS proration
G_BREAK_UOM_CONTEXT           CONSTANT NUMBER := 77; -- OKS PRORATION
G_BREAK_UOM_ATTRIBUTE         CONSTANT NUMBER := 78; -- OKS proration
G_CONTINUOUS_PRICE_BREAK_FLAG CONSTANT NUMBER := 79; -- Continuous Price Breaks

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  QP_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
,   x_PRICE_LIST_LINE_rec           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  QP_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
,   x_PRICE_LIST_LINE_rec           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Rec_Type
);

--  Function Complete_Record

FUNCTION Complete_Record
(   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
) RETURN QP_Price_List_PUB.Price_List_Line_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
) RETURN QP_Price_List_PUB.Price_List_Line_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_list_line_id                  IN  NUMBER
);

--  Function Query_Row

FUNCTION Query_Row
(   p_list_line_id                  IN  NUMBER
) RETURN QP_Price_List_PUB.Price_List_Line_Rec_Type;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_list_line_id                  IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_list_header_id                IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN QP_Price_List_PUB.Price_List_Line_Tbl_Type;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
,   x_PRICE_LIST_LINE_rec           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Rec_Type
);

--  Function Get_Values

FUNCTION Get_Values
(   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  QP_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
) RETURN QP_Price_List_PUB.Price_List_Line_Val_Rec_Type;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
,   p_PRICE_LIST_LINE_val_rec       IN  QP_Price_List_PUB.Price_List_Line_Val_Rec_Type
) RETURN QP_Price_List_PUB.Price_List_Line_Rec_Type;

Procedure Print_Price_List_Line
        (p_PRICE_LIST_LINE_rec IN QP_PRICE_LIST_PUB.PRICE_LIST_LINE_REC_TYPE,
         p_counter IN NUMBER);

FUNCTION get_qualifier_attr_value(p_qual_attr_value in varchar2)
return varchar2;

FUNCTION Get_Context(p_FlexField_Name  IN VARCHAR2
				  ,p_context    IN VARCHAR2)RETURN VARCHAR2;


FUNCTION Get_Attribute_Code(p_FlexField_Name IN VARCHAR2
                           ,p_Context_Name   IN VARCHAR2
                           ,p_attribute      IN VARCHAR2
		           ) return VARCHAR2;


FUNCTION Get_Item_Validate_Org_Value(p_pricing_attribute       IN VARCHAR2
					   ,p_attr_value IN VARCHAR2
					   ) RETURN VARCHAR2;

FUNCTION Get_Attribute_Value(p_FlexField_Name       IN VARCHAR2
                            ,p_Context_Name         IN VARCHAR2
				        ,p_segment_name         IN VARCHAR2
					   ,p_attr_value IN VARCHAR2
					   ) RETURN VARCHAR2;

FUNCTION Get_Product_Value(p_FlexField_Name       IN VARCHAR2
                            ,p_Context_Name         IN VARCHAR2
				        ,p_attribute_name         IN VARCHAR2
					   ,p_attr_value IN VARCHAR2
					   ) RETURN VARCHAR2;

FUNCTION Get_Segment_Name(p_FlexField_Name IN VARCHAR2
                           ,p_Context_Name   IN VARCHAR2
                           ,p_attribute      IN VARCHAR2
		           ) return VARCHAR2;

FUNCTION Get_Product_Id(p_FlexField_Name IN VARCHAR2
                           ,p_Context_Name   IN VARCHAR2
                           ,p_attribute      IN VARCHAR2
                           ,p_attr_value IN VARCHAR2) RETURN NUMBER;


END QP_Price_List_Line_Util;

/
