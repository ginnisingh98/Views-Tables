--------------------------------------------------------
--  DDL for Package OE_PRICE_LIST_LINE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PRICE_LIST_LINE_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUPRLS.pls 120.1 2005/06/15 03:35:36 appldev  $ */

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
G_COMMENTS                    CONSTANT NUMBER := 16;
G_CONTEXT                     CONSTANT NUMBER := 17;
G_CREATED_BY                  CONSTANT NUMBER := 19;
G_CREATION_DATE               CONSTANT NUMBER := 20;
G_CUSTOMER_ITEM               CONSTANT NUMBER := 21;
G_END_DATE_ACTIVE             CONSTANT NUMBER := 22;
G_INVENTORY_ITEM              CONSTANT NUMBER := 23;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 24;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 25;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 26;
G_LIST_PRICE                  CONSTANT NUMBER := 27;
G_METHOD                      CONSTANT NUMBER := 28;
G_PRICE_LIST                  CONSTANT NUMBER := 29;
G_PRICE_LIST_LINE             CONSTANT NUMBER := 30;
G_PRICING_ATTRIBUTE1          CONSTANT NUMBER := 31;
G_PRICING_ATTRIBUTE10         CONSTANT NUMBER := 32;
G_PRICING_ATTRIBUTE11         CONSTANT NUMBER := 33;
G_PRICING_ATTRIBUTE12         CONSTANT NUMBER := 34;
G_PRICING_ATTRIBUTE13         CONSTANT NUMBER := 35;
G_PRICING_ATTRIBUTE14         CONSTANT NUMBER := 36;
G_PRICING_ATTRIBUTE15         CONSTANT NUMBER := 37;
G_PRICING_ATTRIBUTE2          CONSTANT NUMBER := 38;
G_PRICING_ATTRIBUTE3          CONSTANT NUMBER := 39;
G_PRICING_ATTRIBUTE4          CONSTANT NUMBER := 40;
G_PRICING_ATTRIBUTE5          CONSTANT NUMBER := 41;
G_PRICING_ATTRIBUTE6          CONSTANT NUMBER := 42;
G_PRICING_ATTRIBUTE7          CONSTANT NUMBER := 43;
G_PRICING_ATTRIBUTE8          CONSTANT NUMBER := 44;
G_PRICING_ATTRIBUTE9          CONSTANT NUMBER := 45;
G_PRICING_CONTEXT             CONSTANT NUMBER := 46;
G_PRICING_RULE                CONSTANT NUMBER := 47;
G_PRIMARY                     CONSTANT NUMBER := 48;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 49;
G_PROGRAM                     CONSTANT NUMBER := 50;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 51;
G_REPRICE                     CONSTANT NUMBER := 52;
G_REQUEST                     CONSTANT NUMBER := 53;
G_REVISION                    CONSTANT NUMBER := 54;
G_REVISION_DATE               CONSTANT NUMBER := 55;
G_REVISION_REASON             CONSTANT NUMBER := 56;
G_START_DATE_ACTIVE           CONSTANT NUMBER := 57;
G_UNIT                        CONSTANT NUMBER := 58;
G_LIST_LINE_TYPE_CODE         CONSTANT NUMBER := 59;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 60;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  OE_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
,   x_PRICE_LIST_LINE_rec           OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  OE_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
,   x_PRICE_LIST_LINE_rec           OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Rec_Type
);

--  Function Complete_Record

FUNCTION Complete_Record
(   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
) RETURN OE_Price_List_PUB.Price_List_Line_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
) RETURN OE_Price_List_PUB.Price_List_Line_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_price_list_line_id            IN  NUMBER
);

--  Function Query_Row

FUNCTION Query_Row
(   p_price_list_Line_id            IN  NUMBER
,   p_price_list_id            IN  NUMBER
) RETURN OE_Price_List_PUB.Price_List_Line_Rec_Type;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_price_list_line_id            IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_price_list_id                 IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN OE_Price_List_PUB.Price_List_Line_Tbl_Type;


PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
,   x_PRICE_LIST_LINE_rec           OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Rec_Type
);

--  Function Get_Values

FUNCTION Get_Values
(   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  OE_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
) RETURN OE_Price_List_PUB.Price_List_Line_Val_Rec_Type;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_PRICE_LIST_LINE_rec           IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
,   p_PRICE_LIST_LINE_val_rec       IN  OE_Price_List_PUB.Price_List_Line_Val_Rec_Type
) RETURN OE_Price_List_PUB.Price_List_Line_Rec_Type;

PROCEDURE maintain_pricing_attributes
(	p_PRICE_LIST_LINE_rec 	in OE_PRICE_LIST_PUB.Price_List_Line_Rec_Type,
	operation 		in varchar2,
	x_return_status 	out NOCOPY /* file.sql.39 change */ varchar2);

PROCEDURE lock_pricing_attributes( p_list_line_id in number,
                                   x_return_status out NOCOPY /* file.sql.39 change */ varchar2);

FUNCTION Query_Pricing_Attributes
(   p_pricing_attribute_id          IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_list_line_id                  IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN OE_Price_List_PUB.Pricing_Attr_Tbl_Type;


END OE_Price_List_Line_Util;

 

/
