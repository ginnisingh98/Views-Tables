--------------------------------------------------------
--  DDL for Package OE_PRICE_BREAK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PRICE_BREAK_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUDPBS.pls 115.0 99/07/15 19:27:22 porting shi $ */

--  Attributes global constants

G_AMOUNT                      CONSTANT NUMBER := 1;
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
G_CONTEXT                     CONSTANT NUMBER := 17;
G_CREATED_BY                  CONSTANT NUMBER := 18;
G_CREATION_DATE               CONSTANT NUMBER := 19;
G_DISCOUNT_LINE               CONSTANT NUMBER := 20;
G_END_DATE_ACTIVE             CONSTANT NUMBER := 21;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 22;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 23;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 24;
G_METHOD_TYPE                 CONSTANT NUMBER := 25;
G_PERCENT                     CONSTANT NUMBER := 26;
G_PRICE                       CONSTANT NUMBER := 27;
G_PRICE_BREAK_HIGH            CONSTANT NUMBER := 28;
G_PRICE_BREAK_LOW             CONSTANT NUMBER := 29;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 30;
G_PROGRAM                     CONSTANT NUMBER := 31;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 32;
G_REQUEST                     CONSTANT NUMBER := 33;
G_START_DATE_ACTIVE           CONSTANT NUMBER := 34;
G_UNIT                        CONSTANT NUMBER := 35;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 36;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
,   p_old_Price_Break_rec           IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_PRICE_BREAK_REC
,   x_Price_Break_rec               OUT OE_Pricing_Cont_PUB.Price_Break_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
,   p_old_Price_Break_rec           IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_PRICE_BREAK_REC
,   x_Price_Break_rec               OUT OE_Pricing_Cont_PUB.Price_Break_Rec_Type
);

--  Function Complete_Record

FUNCTION Complete_Record
(   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
,   p_old_Price_Break_rec           IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
) RETURN OE_Pricing_Cont_PUB.Price_Break_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
) RETURN OE_Pricing_Cont_PUB.Price_Break_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_discount_line_id              IN  NUMBER
,   p_method_type_code              IN  VARCHAR2
,   p_price_break_high              IN  NUMBER
,   p_price_break_low               IN  NUMBER
);

--  Function Query_Row

FUNCTION Query_Row
(   p_discount_line_id              IN  NUMBER
,   p_method_type_code              IN  VARCHAR2
,   p_price_break_high              IN  NUMBER
,   p_price_break_low               IN  NUMBER
) RETURN OE_Pricing_Cont_PUB.Price_Break_Rec_Type;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_discount_line_id              IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_method_type_code              IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   p_price_break_high              IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_price_break_low               IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT VARCHAR2
,   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
,   x_Price_Break_rec               OUT OE_Pricing_Cont_PUB.Price_Break_Rec_Type
);

--  Function Get_Values

FUNCTION Get_Values
(   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
,   p_old_Price_Break_rec           IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_PRICE_BREAK_REC
) RETURN OE_Pricing_Cont_PUB.Price_Break_Val_Rec_Type;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
,   p_Price_Break_val_rec           IN  OE_Pricing_Cont_PUB.Price_Break_Val_Rec_Type
) RETURN OE_Pricing_Cont_PUB.Price_Break_Rec_Type;

END OE_Price_Break_Util;

 

/
