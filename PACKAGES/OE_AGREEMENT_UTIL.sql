--------------------------------------------------------
--  DDL for Package OE_AGREEMENT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_AGREEMENT_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUAGRS.pls 120.2 2005/12/14 16:15:04 shulin noship $ */

--  Attributes global constants

G_ACCOUNTING_RULE             CONSTANT NUMBER := 1;
G_AGREEMENT_CONTACT           CONSTANT NUMBER := 2;
G_AGREEMENT                   CONSTANT NUMBER := 3;
G_AGREEMENT_NUM               CONSTANT NUMBER := 4;
G_AGREEMENT_TYPE              CONSTANT NUMBER := 5;
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
G_CONTEXT                     CONSTANT NUMBER := 21;
G_CREATED_BY                  CONSTANT NUMBER := 22;
G_CREATION_DATE               CONSTANT NUMBER := 23;
G_CUSTOMER                    CONSTANT NUMBER := 24;
G_END_DATE_ACTIVE             CONSTANT NUMBER := 25;
G_FREIGHT_TERMS               CONSTANT NUMBER := 26;
G_INVOICE_CONTACT             CONSTANT NUMBER := 27;
G_INVOICE_TO_SITE_USE         CONSTANT NUMBER := 28;
G_INVOICING_RULE              CONSTANT NUMBER := 29;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 30;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 31;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 32;
G_NAME                        CONSTANT NUMBER := 33;
G_OVERRIDE_ARULE              CONSTANT NUMBER := 34;
G_OVERRIDE_IRULE              CONSTANT NUMBER := 35;
G_PRICE_LIST                  CONSTANT NUMBER := 36;
G_PURCHASE_ORDER_NUM          CONSTANT NUMBER := 37;
G_REVISION                    CONSTANT NUMBER := 38;
G_REVISION_DATE               CONSTANT NUMBER := 39;
G_REVISION_REASON             CONSTANT NUMBER := 40;
G_SALESREP                    CONSTANT NUMBER := 41;
G_SHIP_METHOD                 CONSTANT NUMBER := 42;
G_SIGNATURE_DATE              CONSTANT NUMBER := 43;
G_START_DATE_ACTIVE           CONSTANT NUMBER := 44;
G_TERM                        CONSTANT NUMBER := 45;
G_AGREEMENT_SOURCE            CONSTANT NUMBER := 46; --added by rchellam for OKC
G_ORIG_SYSTEM_AGR             CONSTANT NUMBER := 47; --added by rchellam for OKC
G_MAX_ATTR_ID                 CONSTANT NUMBER := 48;
G_INVOICE_TO_CUSTOMER_ID      CONSTANT NUMBER := 49; -- Added for bug#4029589

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN            NUMBER := FND_API.G_MISS_NUM
,   p_Agreement_rec                 IN            OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   p_old_Agreement_rec             IN            OE_Pricing_Cont_PUB.Agreement_Rec_Type :=
                                                  OE_Pricing_Cont_PUB.G_MISS_AGREEMENT_REC
,   x_Agreement_rec                 OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Agreement_Rec_Type
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_Agreement_rec                 IN            OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   p_old_Agreement_rec             IN            OE_Pricing_Cont_PUB.Agreement_Rec_Type :=
                                                  OE_Pricing_Cont_PUB.G_MISS_AGREEMENT_REC
,   x_Agreement_rec                 OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Agreement_Rec_Type
);

--  Function Complete_Record

FUNCTION Complete_Record
(   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   p_old_Agreement_rec             IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
) RETURN OE_Pricing_Cont_PUB.Agreement_Rec_Type;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
) RETURN OE_Pricing_Cont_PUB.Agreement_Rec_Type;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
);

--  Procedure Delete_Row

-- Added x_return_status for bug 2321498
PROCEDURE Delete_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_agreement_id                  IN         NUMBER
,   p_Price_List_Exists_Flag        IN         BOOLEAN
,   p_Agreement_Delete_Flag         IN         BOOLEAN
,   p_Agreement_Lines_Delete_Flag   IN         BOOLEAN
);

--  Function Query_Row

FUNCTION Query_Row
(   p_agreement_id                  IN  NUMBER
) RETURN OE_Pricing_Cont_PUB.Agreement_Rec_Type;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_agreement_id                  IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_pricing_contract_id           IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN OE_Pricing_Cont_PUB.Agreement_Tbl_Type;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Agreement_rec                 IN             OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   x_Agreement_rec                 OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Agreement_Rec_Type
);

--  Function Get_Values

FUNCTION Get_Values
(   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   p_old_Agreement_rec             IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_AGREEMENT_REC
) RETURN OE_Pricing_Cont_PUB.Agreement_Val_Rec_Type;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   p_Agreement_val_rec             IN  OE_Pricing_Cont_PUB.Agreement_Val_Rec_Type
) RETURN OE_Pricing_Cont_PUB.Agreement_Rec_Type;

END OE_Agreement_Util;

 

/
