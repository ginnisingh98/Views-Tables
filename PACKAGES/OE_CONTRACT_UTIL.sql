--------------------------------------------------------
--  DDL for Package OE_CONTRACT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CONTRACT_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUPCTS.pls 115.0 99/07/15 19:27:52 porting shi $ */

--  Attributes global constants

G_AGREEMENT                   CONSTANT NUMBER := 1;
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
G_DISCOUNT                    CONSTANT NUMBER := 20;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 21;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 22;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 23;
G_PRICE_LIST                  CONSTANT NUMBER := 24;
G_PRICING_CONTRACT            CONSTANT NUMBER := 25;
G_MAX_ATTR_ID                 CONSTANT NUMBER := 26;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
,   p_old_Contract_rec              IN  OE_Pricing_Cont_PUB.Contract_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_CONTRACT_REC
,   x_Contract_rec                  OUT OE_Pricing_Cont_PUB.Contract_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
,   p_old_Contract_rec              IN  OE_Pricing_Cont_PUB.Contract_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_CONTRACT_REC
,   x_Contract_rec                  OUT OE_Pricing_Cont_PUB.Contract_Rec_Type
);

--  Function Complete_Record

FUNCTION Complete_Record
(   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
,   p_old_Contract_rec              IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
) RETURN OE_Pricing_Cont_PUB.Contract_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
) RETURN OE_Pricing_Cont_PUB.Contract_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_pricing_contract_id           IN  NUMBER
);

--  Function Query_Row

FUNCTION Query_Row
(   p_pricing_contract_id           IN  NUMBER
) RETURN OE_Pricing_Cont_PUB.Contract_Rec_Type;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT VARCHAR2
,   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
,   x_Contract_rec                  OUT OE_Pricing_Cont_PUB.Contract_Rec_Type
);

--  Function Get_Values

FUNCTION Get_Values
(   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
,   p_old_Contract_rec              IN  OE_Pricing_Cont_PUB.Contract_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_CONTRACT_REC
) RETURN OE_Pricing_Cont_PUB.Contract_Val_Rec_Type;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
,   p_Contract_val_rec              IN  OE_Pricing_Cont_PUB.Contract_Val_Rec_Type
) RETURN OE_Pricing_Cont_PUB.Contract_Rec_Type;

END OE_Contract_Util;

 

/
