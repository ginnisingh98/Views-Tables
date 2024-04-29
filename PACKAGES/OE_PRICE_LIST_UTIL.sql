--------------------------------------------------------
--  DDL for Package OE_PRICE_LIST_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PRICE_LIST_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUPRHS.pls 120.3 2006/03/27 12:59:05 rnayani noship $ */

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
G_CREATED_BY                  CONSTANT NUMBER := 18;
G_CREATION_DATE               CONSTANT NUMBER := 19;
G_CURRENCY                    CONSTANT NUMBER := 20;
G_DESCRIPTION                 CONSTANT NUMBER := 21;
G_END_DATE_ACTIVE             CONSTANT NUMBER := 22;
G_FREIGHT_TERMS               CONSTANT NUMBER := 23;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 24;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 25;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 26;
G_NAME                        CONSTANT NUMBER := 27;
G_PRICE_LIST                  CONSTANT NUMBER := 28;
G_PROGRAM_APPLICATION         CONSTANT NUMBER := 29;
G_PROGRAM                     CONSTANT NUMBER := 30;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 31;
G_REQUEST                     CONSTANT NUMBER := 32;
G_ROUNDING_FACTOR             CONSTANT NUMBER := 33;
G_SECONDARY_PRICE_LIST        CONSTANT NUMBER := 34;
G_SHIP_METHOD                 CONSTANT NUMBER := 35;
G_START_DATE_ACTIVE           CONSTANT NUMBER := 36;
G_TERMS                       CONSTANT NUMBER := 37;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 38;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type
,   p_old_PRICE_LIST_rec            IN  OE_Price_List_PUB.Price_List_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type
,   p_old_PRICE_LIST_rec            IN  OE_Price_List_PUB.Price_List_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Rec_Type
);

--  Function Complete_Record

FUNCTION Complete_Record
(   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type
,   p_old_PRICE_LIST_rec            IN  OE_Price_List_PUB.Price_List_Rec_Type
) RETURN OE_Price_List_PUB.Price_List_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type
) RETURN OE_Price_List_PUB.Price_List_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_name                          IN  VARCHAR2
,   p_price_list_id                 IN  NUMBER
);

--  Function Query_Row

FUNCTION Query_Row
(   p_name                          IN  VARCHAR2
,   p_price_list_id                 IN  NUMBER
) RETURN OE_Price_List_PUB.Price_List_Rec_Type;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Rec_Type
);

--  Function Get_Values

FUNCTION Get_Values
(   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type
,   p_old_PRICE_LIST_rec            IN  OE_Price_List_PUB.Price_List_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_REC
) RETURN OE_Price_List_PUB.Price_List_Val_Rec_Type;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type
,   p_PRICE_LIST_val_rec            IN  OE_Price_List_PUB.Price_List_Val_Rec_Type
) RETURN OE_Price_List_PUB.Price_List_Rec_Type;

--  Function Get_Ids

END OE_Price_List_Util;

 

/
