--------------------------------------------------------
--  DDL for Package OE_LINE_PAYMENT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_LINE_PAYMENT_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXULPMS.pls 120.2.12010000.1 2008/07/25 07:56:40 appldev ship $ */

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
G_HEADER                      CONSTANT NUMBER := 19;
G_LAST_UPDATED_BY             CONSTANT NUMBER := 20;
G_LAST_UPDATE_DATE            CONSTANT NUMBER := 21;
G_LAST_UPDATE_LOGIN           CONSTANT NUMBER := 22;
G_LINE                        CONSTANT NUMBER := 23;
G_CHECK_NUMBER                CONSTANT NUMBER := 24;
G_CREDIT_CARD_APPROVAL_CODE   CONSTANT NUMBER := 25;
G_CREDIT_CARD_APPROVAL_DATE   CONSTANT NUMBER := 26;
G_CREDIT_CARD_CODE            CONSTANT NUMBER := 27;
G_CREDIT_CARD_EXPIRATION_DATE CONSTANT NUMBER := 28;
G_CREDIT_CARD_HOLDER_NAME     CONSTANT NUMBER := 29;
G_CREDIT_CARD_NUMBER          CONSTANT NUMBER := 30;
G_PAYMENT_LEVEL_CODE          CONSTANT NUMBER := 31;
G_COMMITMENT_APPLIED_AMOUNT   CONSTANT NUMBER := 32;
G_COMMITMENT_INTERFACED_AMOUNT CONSTANT NUMBER := 33;
G_PAYMENT_AMOUNT              CONSTANT NUMBER := 34;
G_PAYMENT_COLLECTION_EVENT    CONSTANT NUMBER := 35;
G_PAYMENT_TRX_ID              CONSTANT NUMBER := 36;
G_PAYMENT_TYPE_CODE           CONSTANT NUMBER := 37;
G_PAYMENT_SET_ID              CONSTANT NUMBER := 38;
G_PREPAID_AMOUNT              CONSTANT NUMBER := 39;
G_PROGRAM_APPLICATION_ID      CONSTANT NUMBER := 40;
G_PROGRAM_ID                  CONSTANT NUMBER := 41;
G_PROGRAM_UPDATE_DATE         CONSTANT NUMBER := 42;
G_RECEIPT_METHOD_ID           CONSTANT NUMBER := 43;
G_REQUEST_ID                  CONSTANT NUMBER := 44;
G_TANGIBLE_ID                 CONSTANT NUMBER := 45;
G_PAYMENT_NUMBER              CONSTANT NUMBER := 46;
G_LOCK_CONTROL                CONSTANT NUMBER := 47;
G_DEFER_PROCESSING_FLAG       CONSTANT NUMBER := 48;
--R12 CC Encryption
G_TRXN_EXTENSION_ID           CONSTANT NUMBER := 49;
G_INSTRUMENT_SECURITY_CODE    CONSTANT NUMBER := 50;
G_CC_INSTRUMENT_ID	      CONSTANT NUMBER := 51;
G_CC_INSTRUMENT_ASSIGNMENT_ID CONSTANT NUMBER := 52;
--R12 CC Encryption
G_MAX_ATTR_ID                 CONSTANT NUMBER := 53;

FUNCTION G_MISS_OE_AK_LPAYMENT_REC
RETURN OE_AK_LINE_PAYMENTS_V%ROWTYPE;

PROCEDURE API_Rec_To_Rowtype_Rec
(   p_LINE_PAYMENT_rec       IN  OE_Order_PUB.LINE_PAYMENT_Rec_Type
,   x_rowtype_rec         IN OUT NOCOPY OE_AK_LINE_PAYMENTS_V%ROWTYPE
);

PROCEDURE Rowtype_Rec_To_API_Rec
(   p_record               IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
,   x_api_rec              IN OUT NOCOPY OE_Order_PUB.LINE_PAYMENT_Rec_Type
);

-- Procedure Clear_Dependent_Attr: Overloaded for VIEW%ROWTYPE parameters

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_Line_Payment_rec     IN OUT NOCOPY  OE_AK_LINE_PAYMENTS_V%ROWTYPE
,   p_old_Line_Payment_rec        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
								:= G_MISS_OE_AK_LPAYMENT_REC
,   p_x_instrument_id	     IN NUMBER DEFAULT NULL --R12 CC Encryption
,   p_old_instrument_id	     IN NUMBER DEFAULT NULL
);

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_Line_Payment_rec  IN OUT NOCOPY OE_Order_PUB.Line_Payment_Rec_Type
,   p_old_Line_Payment_rec        IN  OE_Order_PUB.Line_Payment_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_REC
);

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_x_Line_Payment_rec IN OUT NOCOPY  OE_Order_PUB.Line_Payment_Rec_Type
,   p_old_Line_Payment_rec        IN  OE_Order_PUB.Line_Payment_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_REC
);

--  Function Complete_Record

PROCEDURE Complete_Record
(   p_x_Line_Payment_rec  IN OUT NOCOPY  OE_Order_PUB.Line_Payment_Rec_Type
,   p_old_Line_Payment_rec        IN  OE_Order_PUB.Line_Payment_Rec_Type
) ;

--  Function Convert_Miss_To_Null

PROCEDURE Convert_Miss_To_Null
(   p_x_Line_Payment_rec IN OUT NOCOPY OE_Order_PUB.Line_Payment_Rec_Type
) ;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Line_Payment_rec       IN OUT NOCOPY   OE_Order_PUB.Line_Payment_Rec_Type
);

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Line_Payment_rec       IN OUT NOCOPY   OE_Order_PUB.Line_Payment_Rec_Type
);

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_payment_number               IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_line_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
);

--  Function Query_Row

PROCEDURE Query_Row
(   p_payment_number               IN  NUMBER,
    p_line_id                      IN  NUMBER,
    p_header_id                    IN  NUMBER :=
                                         FND_API.G_MISS_NUM,
    x_Line_Payment_Rec      IN OUT NOCOPY OE_Order_PUB.Line_Payment_Rec_Type
) ;

--  Function Query_Rows

--

PROCEDURE Query_Rows
(   p_payment_number                IN  NUMBER :=
                                    FND_API.G_MISS_NUM
,   p_line_id                       IN  NUMBER :=
                                    FND_API.G_MISS_NUM
,   p_header_id                     IN  NUMBER :=
                                    FND_API.G_MISS_NUM
,   x_Line_Payment_tbl   IN OUT NOCOPY OE_Order_PUB.Line_Payment_tbl_Type

);

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2

,  p_x_Line_Payment_rec  IN OUT NOCOPY  OE_Order_PUB.Line_Payment_Rec_Type
,   p_payment_number               IN NUMBER
                                    := FND_API.G_MISS_NUM
,   p_line_id                      IN NUMBER
                                    := FND_API.G_MISS_NUM
);

PROCEDURE Lock_Rows
(   p_payment_number       IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_line_id             IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header_id           IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_Line_Payment_tbl    OUT NOCOPY OE_Order_PUB.Line_Payment_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

 );

--  Function Get_Values

FUNCTION Get_Values
(   p_Line_Payment_rec            IN  OE_Order_PUB.Line_Payment_Rec_Type
,   p_old_Line_Payment_rec        IN  OE_Order_PUB.Line_Payment_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_REC
) RETURN OE_Order_PUB.Line_Payment_Val_Rec_Type;

--  Function Get_Ids

PROCEDURE Get_Ids
(   p_x_Line_Payment_rec  IN OUT NOCOPY  OE_Order_PUB.Line_Payment_Rec_Type
,   p_Line_Payment_val_rec   IN  OE_Order_PUB.Line_Payment_Val_Rec_Type
) ;

PROCEDURE Pre_Write_Process
  ( p_x_Line_Payment_rec IN OUT NOCOPY OE_ORDER_PUB.Line_Payment_rec_type,
    p_old_Line_Payment_rec IN OE_ORDER_PUB.Line_Payment_rec_type := OE_ORDER_PUB.G_MISS_LINE_PAYMENT_REC );

END OE_Line_Payment_Util;

/
