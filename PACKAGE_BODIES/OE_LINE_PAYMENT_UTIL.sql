--------------------------------------------------------
--  DDL for Package Body OE_LINE_PAYMENT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LINE_PAYMENT_UTIL" AS
/* $Header: OEXULPMB.pls 120.16.12010000.4 2009/12/08 13:41:22 msundara ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Line_Payment_Util';
g_fmt_mask                    VARCHAR2(500); --bug 3560198

--3382262
Procedure Delete_Payment_at_line(p_header_id in number := null,
                                 p_line_id in number,
                                 p_payment_number in number := null,
                                 p_payment_type_code in varchar2 := null,
                                 p_del_commitment in number := 0,
                                   x_return_status out nocopy varchar2,
                                   x_msg_count out nocopy number,
                                   x_msg_data out nocopy varchar2);
--3382262

FUNCTION G_MISS_OE_AK_LPAYMENT_REC
RETURN OE_AK_LINE_PAYMENTS_V%ROWTYPE IS
l_rowtype_rec				OE_AK_LINE_PAYMENTS_V%ROWTYPE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_rowtype_rec.ATTRIBUTE1                     := FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE2                     := FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE3                     := FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE4                     := FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE5                     := FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE6                     := FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE7                     := FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE8                     := FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE9                     := FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE10                    := FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE11                    := FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE12                    := FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE13                    := FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE14                    := FND_API.G_MISS_CHAR;
    l_rowtype_rec.ATTRIBUTE15                    := FND_API.G_MISS_CHAR;
    l_rowtype_rec.CONTEXT                        := FND_API.G_MISS_CHAR;
    l_rowtype_rec.CREATED_BY                     := FND_API.G_MISS_NUM;
    l_rowtype_rec.CREATION_DATE                  := FND_API.G_MISS_DATE;
    l_rowtype_rec.LAST_UPDATED_BY                := FND_API.G_MISS_NUM;
    l_rowtype_rec.LAST_UPDATE_DATE               := FND_API.G_MISS_DATE;
    l_rowtype_rec.LAST_UPDATE_LOGIN              := FND_API.G_MISS_NUM;
    l_rowtype_rec.CHECK_NUMBER                   := FND_API.G_MISS_CHAR;
    l_rowtype_rec.CREDIT_CARD_APPROVAL_CODE      := FND_API.G_MISS_CHAR;
    l_rowtype_rec.CREDIT_CARD_APPROVAL_DATE      := FND_API.G_MISS_DATE;
    l_rowtype_rec.CREDIT_CARD_CODE               := FND_API.G_MISS_CHAR;
    l_rowtype_rec.CREDIT_CARD_EXPIRATION_DATE    := FND_API.G_MISS_DATE;
    l_rowtype_rec.CREDIT_CARD_HOLDER_NAME        := FND_API.G_MISS_CHAR;
    l_rowtype_rec.CREDIT_CARD_NUMBER             := FND_API.G_MISS_CHAR;
    l_rowtype_rec.PAYMENT_LEVEL_CODE             := FND_API.G_MISS_CHAR;
    l_rowtype_rec.COMMITMENT_APPLIED_AMOUNT      := FND_API.G_MISS_NUM;
    l_rowtype_rec.COMMITMENT_INTERFACED_AMOUNT   := FND_API.G_MISS_NUM;
    l_rowtype_rec.PAYMENT_NUMBER                 := FND_API.G_MISS_NUM;
    l_rowtype_rec.HEADER_ID                      := FND_API.G_MISS_NUM;
    l_rowtype_rec.LINE_ID                        := FND_API.G_MISS_NUM;
    l_rowtype_rec.PAYMENT_AMOUNT                 := FND_API.G_MISS_NUM;
    l_rowtype_rec.PAYMENT_COLLECTION_EVENT       := FND_API.G_MISS_CHAR;
    l_rowtype_rec.PAYMENT_TRX_ID                 := FND_API.G_MISS_NUM;
    l_rowtype_rec.PAYMENT_TYPE_CODE              := FND_API.G_MISS_CHAR;
    l_rowtype_rec.PAYMENT_SET_ID                 := FND_API.G_MISS_NUM;
    l_rowtype_rec.PREPAID_AMOUNT                 := FND_API.G_MISS_NUM;
    l_rowtype_rec.PROGRAM_APPLICATION_ID         := FND_API.G_MISS_NUM;
    l_rowtype_rec.PROGRAM_ID                     := FND_API.G_MISS_NUM;
    l_rowtype_rec.PROGRAM_UPDATE_DATE            := FND_API.G_MISS_DATE;
    l_rowtype_rec.RECEIPT_METHOD_ID              := FND_API.G_MISS_NUM;
    l_rowtype_rec.REQUEST_ID                     := FND_API.G_MISS_NUM;
    l_rowtype_rec.TANGIBLE_ID                    := FND_API.G_MISS_CHAR;
    l_rowtype_rec.RETURN_STATUS                  := FND_API.G_MISS_CHAR;
    l_rowtype_rec.DB_FLAG                        := FND_API.G_MISS_CHAR;
    l_rowtype_rec.OPERATION                      := FND_API.G_MISS_CHAR;

    RETURN l_rowtype_rec;

END G_MISS_OE_AK_LPAYMENT_REC;

PROCEDURE API_Rec_To_Rowtype_Rec
(   p_Line_Payment_rec            IN  OE_Order_PUB.LINE_PAYMENT_Rec_Type
,   x_rowtype_rec                  IN OUT NOCOPY OE_AK_LINE_PAYMENTS_V%ROWTYPE
) IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    x_rowtype_rec.ATTRIBUTE1       := p_line_Payment_rec.ATTRIBUTE1;
    x_rowtype_rec.ATTRIBUTE2       := p_line_Payment_rec.ATTRIBUTE2;
    x_rowtype_rec.ATTRIBUTE3       := p_line_Payment_rec.ATTRIBUTE3;
    x_rowtype_rec.ATTRIBUTE4       := p_line_Payment_rec.ATTRIBUTE4;
    x_rowtype_rec.ATTRIBUTE5       := p_line_Payment_rec.ATTRIBUTE5;
    x_rowtype_rec.ATTRIBUTE6       := p_line_Payment_rec.ATTRIBUTE6;
    x_rowtype_rec.ATTRIBUTE7       := p_line_Payment_rec.ATTRIBUTE7;
    x_rowtype_rec.ATTRIBUTE8       := p_line_Payment_rec.ATTRIBUTE8;
    x_rowtype_rec.ATTRIBUTE9       := p_line_Payment_rec.ATTRIBUTE9;
    x_rowtype_rec.ATTRIBUTE10       := p_line_Payment_rec.ATTRIBUTE10;
    x_rowtype_rec.ATTRIBUTE11       := p_line_Payment_rec.ATTRIBUTE11;
    x_rowtype_rec.ATTRIBUTE12       := p_line_Payment_rec.ATTRIBUTE12;
    x_rowtype_rec.ATTRIBUTE13       := p_line_Payment_rec.ATTRIBUTE13;
    x_rowtype_rec.ATTRIBUTE14       := p_line_Payment_rec.ATTRIBUTE14;
    x_rowtype_rec.ATTRIBUTE15       := p_line_Payment_rec.ATTRIBUTE15;
    x_rowtype_rec.CONTEXT                        := p_line_Payment_rec.CONTEXT;
    x_rowtype_rec.CREATED_BY                     := p_line_Payment_rec.CREATED_BY;
    x_rowtype_rec.CREATION_DATE                  := p_line_Payment_rec.CREATION_DATE;
    x_rowtype_rec.LAST_UPDATED_BY                := p_line_Payment_rec.LAST_UPDATED_BY;
    x_rowtype_rec.LAST_UPDATE_DATE               := p_line_Payment_rec.LAST_UPDATE_DATE;
    x_rowtype_rec.LAST_UPDATE_LOGIN              := p_line_Payment_rec.LAST_UPDATE_LOGIN;
    x_rowtype_rec.CHECK_NUMBER                   := p_line_Payment_rec.CHECK_NUMBER;
    x_rowtype_rec.CREDIT_CARD_APPROVAL_CODE      := p_line_Payment_rec.CREDIT_CARD_APPROVAL_CODE;
    x_rowtype_rec.CREDIT_CARD_APPROVAL_DATE      := p_line_Payment_rec.CREDIT_CARD_APPROVAL_DATE;
    x_rowtype_rec.CREDIT_CARD_CODE               := p_line_Payment_rec.CREDIT_CARD_CODE;
    x_rowtype_rec.CREDIT_CARD_EXPIRATION_DATE    := p_line_Payment_rec.CREDIT_CARD_EXPIRATION_DATE;
    x_rowtype_rec.CREDIT_CARD_HOLDER_NAME        := p_line_Payment_rec.CREDIT_CARD_HOLDER_NAME;
    x_rowtype_rec.CREDIT_CARD_NUMBER             := p_line_Payment_rec.CREDIT_CARD_NUMBER;
    x_rowtype_rec.PAYMENT_LEVEL_CODE             := p_line_Payment_rec.PAYMENT_LEVEL_CODE;
    x_rowtype_rec.COMMITMENT_APPLIED_AMOUNT      := p_line_Payment_rec.COMMITMENT_APPLIED_AMOUNT;
    x_rowtype_rec.COMMITMENT_INTERFACED_AMOUNT   := p_line_Payment_rec.COMMITMENT_INTERFACED_AMOUNT;
    x_rowtype_rec.PAYMENT_NUMBER                 := p_line_Payment_rec.PAYMENT_NUMBER;
    x_rowtype_rec.HEADER_ID                      := p_line_Payment_rec.HEADER_ID;
    x_rowtype_rec.LINE_ID                        := p_line_Payment_rec.LINE_ID;
    x_rowtype_rec.PAYMENT_AMOUNT                 := p_line_Payment_rec.PAYMENT_AMOUNT;
    x_rowtype_rec.PAYMENT_COLLECTION_EVENT       := p_line_Payment_rec.PAYMENT_COLLECTION_EVENT;
    x_rowtype_rec.PAYMENT_TRX_ID                 := p_line_Payment_rec.PAYMENT_TRX_ID;
    x_rowtype_rec.PAYMENT_TYPE_CODE              := p_line_Payment_rec.PAYMENT_TYPE_CODE;
    x_rowtype_rec.PAYMENT_SET_ID                 := p_line_Payment_rec.PAYMENT_SET_ID;
    x_rowtype_rec.PREPAID_AMOUNT                 := p_line_Payment_rec.PREPAID_AMOUNT;
    x_rowtype_rec.PROGRAM_APPLICATION_ID         := p_line_Payment_rec.PROGRAM_APPLICATION_ID;
    x_rowtype_rec.PROGRAM_ID                     := p_line_Payment_rec.PROGRAM_ID;
    x_rowtype_rec.PROGRAM_UPDATE_DATE            := p_line_Payment_rec.PROGRAM_UPDATE_DATE;
    x_rowtype_rec.RECEIPT_METHOD_ID              := p_line_Payment_rec.RECEIPT_METHOD_ID;
    x_rowtype_rec.REQUEST_ID                     := p_line_Payment_rec.REQUEST_ID;
    x_rowtype_rec.TANGIBLE_ID                    := p_line_Payment_rec.TANGIBLE_ID;
    x_rowtype_rec.RETURN_STATUS                  := p_line_Payment_rec.RETURN_STATUS;
    x_rowtype_rec.DB_FLAG                        := p_line_Payment_rec.DB_FLAG;
    x_rowtype_rec.OPERATION                      := p_line_Payment_rec.OPERATION;

END API_Rec_To_RowType_Rec;


PROCEDURE Rowtype_Rec_To_API_Rec
(   p_record                        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE
,   x_api_rec                     IN OUT NOCOPY OE_Order_PUB.Line_Payment_Rec_Type
) IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    x_api_rec.ATTRIBUTE1       := p_record.ATTRIBUTE1;
    x_api_rec.ATTRIBUTE2       := p_record.ATTRIBUTE2;
    x_api_rec.ATTRIBUTE3       := p_record.ATTRIBUTE3;
    x_api_rec.ATTRIBUTE4       := p_record.ATTRIBUTE4;
    x_api_rec.ATTRIBUTE5       := p_record.ATTRIBUTE5;
    x_api_rec.ATTRIBUTE6       := p_record.ATTRIBUTE6;
    x_api_rec.ATTRIBUTE7       := p_record.ATTRIBUTE7;
    x_api_rec.ATTRIBUTE8       := p_record.ATTRIBUTE8;
    x_api_rec.ATTRIBUTE9       := p_record.ATTRIBUTE9;
    x_api_rec.ATTRIBUTE10       := p_record.ATTRIBUTE10;
    x_api_rec.ATTRIBUTE11       := p_record.ATTRIBUTE11;
    x_api_rec.ATTRIBUTE12       := p_record.ATTRIBUTE12;
    x_api_rec.ATTRIBUTE13       := p_record.ATTRIBUTE13;
    x_api_rec.ATTRIBUTE14       := p_record.ATTRIBUTE14;
    x_api_rec.ATTRIBUTE15       := p_record.ATTRIBUTE15;
    x_api_rec.CONTEXT                        := p_record.CONTEXT;
    x_api_rec.CREATED_BY                     := p_record.CREATED_BY;
    x_api_rec.CREATION_DATE                  := p_record.CREATION_DATE;
    x_api_rec.LAST_UPDATED_BY                := p_record.LAST_UPDATED_BY;
    x_api_rec.LAST_UPDATE_DATE               := p_record.LAST_UPDATE_DATE;
    x_api_rec.LAST_UPDATE_LOGIN              := p_record.LAST_UPDATE_LOGIN;
    x_api_rec.CHECK_NUMBER                   := p_record.CHECK_NUMBER;
    x_api_rec.CREDIT_CARD_APPROVAL_CODE      := p_record.CREDIT_CARD_APPROVAL_CODE;
    x_api_rec.CREDIT_CARD_APPROVAL_DATE      := p_record.CREDIT_CARD_APPROVAL_DATE;
    x_api_rec.CREDIT_CARD_CODE               := p_record.CREDIT_CARD_CODE;
    x_api_rec.CREDIT_CARD_EXPIRATION_DATE    := p_record.CREDIT_CARD_EXPIRATION_DATE;
    x_api_rec.CREDIT_CARD_HOLDER_NAME        := p_record.CREDIT_CARD_HOLDER_NAME;
    x_api_rec.CREDIT_CARD_NUMBER             := p_record.CREDIT_CARD_NUMBER;
    x_api_rec.PAYMENT_LEVEL_CODE             := p_record.PAYMENT_LEVEL_CODE;
    x_api_rec.COMMITMENT_APPLIED_AMOUNT      := p_record.COMMITMENT_APPLIED_AMOUNT;
    x_api_rec.COMMITMENT_INTERFACED_AMOUNT   := p_record.COMMITMENT_INTERFACED_AMOUNT;
    x_api_rec.PAYMENT_NUMBER                 := p_record.PAYMENT_NUMBER;
    x_api_rec.HEADER_ID                      := p_record.HEADER_ID;
    x_api_rec.LINE_ID                        := p_record.LINE_ID;
    x_api_rec.PAYMENT_AMOUNT                 := p_record.PAYMENT_AMOUNT;
    x_api_rec.PAYMENT_COLLECTION_EVENT       := p_record.PAYMENT_COLLECTION_EVENT;
    x_api_rec.PAYMENT_TRX_ID                 := p_record.PAYMENT_TRX_ID;
    x_api_rec.PAYMENT_TYPE_CODE              := p_record.PAYMENT_TYPE_CODE;
    x_api_rec.PAYMENT_SET_ID                 := p_record.PAYMENT_SET_ID;
    x_api_rec.PREPAID_AMOUNT                 := p_record.PREPAID_AMOUNT;
    x_api_rec.PROGRAM_APPLICATION_ID         := p_record.PROGRAM_APPLICATION_ID;
    x_api_rec.PROGRAM_ID                     := p_record.PROGRAM_ID;
    x_api_rec.PROGRAM_UPDATE_DATE            := p_record.PROGRAM_UPDATE_DATE;
    x_api_rec.RECEIPT_METHOD_ID              := p_record.RECEIPT_METHOD_ID;
    x_api_rec.REQUEST_ID                     := p_record.REQUEST_ID;
    x_api_rec.TANGIBLE_ID                    := p_record.TANGIBLE_ID;
    x_api_rec.RETURN_STATUS                  := p_record.RETURN_STATUS;
    x_api_rec.DB_FLAG                        := p_record.DB_FLAG;

END Rowtype_Rec_To_API_Rec;

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_Line_Payment_rec    IN OUT NOCOPY  OE_AK_LINE_PAYMENTS_V%ROWTYPE
,   p_old_Line_Payment_rec        IN  OE_AK_LINE_PAYMENTS_V%ROWTYPE :=
								G_MISS_OE_AK_LPayment_REC
,   p_x_instrument_id	    IN NUMBER DEFAULT NULL --R12 CC Encryption
,   p_old_instrument_id	    IN NUMBER DEFAULT NULL
)
IS
l_index			NUMBER :=0;
l_src_attr_tbl		OE_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl		OE_GLOBALS.NUMBER_Tbl_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    --  Load out record



    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute1,p_old_Line_Payment_rec.attribute1)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute2,p_old_Line_Payment_rec.attribute2)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute3,p_old_Line_Payment_rec.attribute3)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute4,p_old_Line_Payment_rec.attribute4)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute5,p_old_Line_Payment_rec.attribute5)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute6,p_old_Line_Payment_rec.attribute6)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute7,p_old_Line_Payment_rec.attribute7)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute8,p_old_Line_Payment_rec.attribute8)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute9,p_old_Line_Payment_rec.attribute9)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute10,p_old_Line_Payment_rec.attribute10)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute11,p_old_Line_Payment_rec.attribute11)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute12,p_old_Line_Payment_rec.attribute12)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute13,p_old_Line_Payment_rec.attribute13)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute14,p_old_Line_Payment_rec.attribute14)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute15,p_old_Line_Payment_rec.attribute15)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.context,p_old_Line_Payment_rec.context)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_CONTEXT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.created_by,p_old_Line_Payment_rec.created_by)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_CREATED_BY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.creation_date,p_old_Line_Payment_rec.creation_date)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.last_updated_by,p_old_Line_Payment_rec.last_updated_by)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.last_update_date,p_old_Line_Payment_rec.last_update_date)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.last_update_login,p_old_Line_Payment_rec.last_update_login)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.check_number,p_old_Line_Payment_rec.check_number)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_CHECK_NUMBER;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.credit_card_approval_code,p_old_Line_Payment_rec.credit_card_approval_code)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_CODE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.credit_card_approval_date,p_old_Line_Payment_rec.credit_card_approval_date)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.credit_card_code,p_old_Line_Payment_rec.credit_card_code)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_CODE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.credit_card_expiration_date,p_old_Line_Payment_rec.credit_card_expiration_date)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_EXPIRATION_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.credit_card_holder_name,p_old_Line_Payment_rec.credit_card_holder_name)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_HOLDER_NAME;
        END IF;

	--R12 CC Encryption
	--Since the credit card numbers are encrypted, passing both the credit card
	--numbers as well as instrument ids to determine if both the old and new
	--values point to the same credit card number.

	IF NOT OE_GLOBALS.Is_Same_Credit_Card(p_old_Line_Payment_rec.credit_card_number,
                            p_x_Line_Payment_rec.credit_card_number,p_old_instrument_id,
			    p_x_instrument_id)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_NUMBER;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.payment_level_code,p_old_Line_Payment_rec.payment_level_code)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_PAYMENT_LEVEL_CODE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.commitment_applied_amount,p_old_Line_Payment_rec.commitment_applied_amount)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_COMMITMENT_APPLIED_AMOUNT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.commitment_interfaced_amount,p_old_Line_Payment_rec.commitment_interfaced_amount)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_COMMITMENT_INTERFACED_AMOUNT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.payment_number,p_old_Line_Payment_rec.payment_number)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_PAYMENT_NUMBER;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.header_id,p_old_Line_Payment_rec.header_id)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_HEADER;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.line_id,p_old_Line_Payment_rec.line_id)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_LINE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.payment_amount,p_old_Line_Payment_rec.payment_amount)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_PAYMENT_AMOUNT;
        END IF;


        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.payment_collection_event,p_old_Line_Payment_rec.payment_collection_event)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_PAYMENT_COLLECTION_EVENT;
        END IF;
        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.payment_trx_id,p_old_Line_Payment_rec.payment_trx_id)
        THEN
           l_index := l_index + 1;
         l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_PAYMENT_TRX_ID;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.payment_type_code,p_old_Line_Payment_rec.payment_type_code)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_PAYMENT_TYPE_CODE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.payment_set_id,p_old_Line_Payment_rec.payment_set_id)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_PAYMENT_SET_ID;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.prepaid_amount,p_old_Line_Payment_rec.prepaid_amount)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_PREPAID_AMOUNT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.program_application_id,p_old_Line_Payment_rec.program_application_id)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_PROGRAM_APPLICATION_ID;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.program_id,p_old_Line_Payment_rec.program_id)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_PROGRAM_ID;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.program_update_date,p_old_Line_Payment_rec.program_update_date)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.receipt_method_id,p_old_Line_Payment_rec.receipt_method_id)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_RECEIPT_METHOD_ID;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.request_id,p_old_Line_Payment_rec.request_id)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_REQUEST_ID;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.tangible_id,p_old_Line_Payment_rec.tangible_id)
        THEN
           l_index := l_index + 1;
           l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_TANGIBLE_ID;
        END IF;

    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_CHECK_NUMBER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_CHECK_NUMBER;
    ELSIF p_attr_id = G_CREDIT_CARD_APPROVAL_CODE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_CODE;
    ELSIF p_attr_id = G_CREDIT_CARD_APPROVAL_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_DATE;
    ELSIF p_attr_id = G_CREDIT_CARD_CODE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_CODE;
    ELSIF p_attr_id = G_CREDIT_CARD_EXPIRATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_EXPIRATION_DATE;
    ELSIF p_attr_id = G_CREDIT_CARD_HOLDER_NAME THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_HOLDER_NAME;
    ELSIF p_attr_id = G_CREDIT_CARD_NUMBER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_NUMBER;
    ELSIF p_attr_id = G_PAYMENT_LEVEL_CODE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_PAYMENT_LEVEL_CODE;
    ELSIF p_attr_id = G_COMMITMENT_APPLIED_AMOUNT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_COMMITMENT_APPLIED_AMOUNT;
    ELSIF p_attr_id = G_COMMITMENT_INTERFACED_AMOUNT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_COMMITMENT_INTERFACED_AMOUNT;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_PAYMENT_NUMBER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_PAYMENT_NUMBER;
    ELSIF p_attr_id = G_HEADER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_HEADER;
    ELSIF p_attr_id = G_LINE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_LINE;
    ELSIF p_attr_id = G_PAYMENT_AMOUNT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_PAYMENT_AMOUNT;
    ELSIF p_attr_id = G_PAYMENT_COLLECTION_EVENT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_PAYMENT_COLLECTION_EVENT;
    ELSIF p_attr_id = G_PAYMENT_TRX_ID THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_PAYMENT_TRX_ID;
    ELSIF p_attr_id = G_PAYMENT_TYPE_CODE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_PAYMENT_TYPE_CODE;
    ELSIF p_attr_id = G_PAYMENT_SET_ID THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_PAYMENT_SET_ID;
    ELSIF p_attr_id = G_PREPAID_AMOUNT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_PREPAID_AMOUNT;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION_ID THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_PROGRAM_APPLICATION_ID;
    ELSIF p_attr_id = G_PROGRAM_ID THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_PROGRAM_ID;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_RECEIPT_METHOD_ID THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_RECEIPT_METHOD_ID;
    ELSIF p_attr_id = G_REQUEST_ID THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_REQUEST_ID;
    ELSIF p_attr_id = G_TANGIBLE_ID THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := OE_LINE_PAYMENT_UTIL.G_TANGIBLE_ID;
    END IF;

    If l_src_attr_tbl.COUNT <> 0 THEN

        OE_Dependencies.Mark_Dependent
        (p_entity_code     => OE_GLOBALS.G_ENTITY_LINE_PAYMENT,
        p_source_attr_tbl => l_src_attr_tbl,
        p_dep_attr_tbl    => l_dep_attr_tbl);

        FOR I IN 1..l_dep_attr_tbl.COUNT LOOP
            IF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE1 THEN
                p_x_Line_PAYMENT_rec.ATTRIBUTE1 := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE2 THEN
                p_x_Line_PAYMENT_rec.ATTRIBUTE2 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE3 THEN
                p_x_Line_PAYMENT_rec.ATTRIBUTE3 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE4 THEN
                p_x_Line_PAYMENT_rec.ATTRIBUTE4 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE5 THEN
                p_x_Line_PAYMENT_rec.ATTRIBUTE5 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE6 THEN
                p_x_Line_PAYMENT_rec.ATTRIBUTE6 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE7 THEN
                p_x_Line_PAYMENT_rec.ATTRIBUTE7 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE8 THEN
                p_x_Line_PAYMENT_rec.ATTRIBUTE8 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE9 THEN
                p_x_Line_PAYMENT_rec.ATTRIBUTE9 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE10 THEN
                p_x_Line_PAYMENT_rec.ATTRIBUTE10 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE11 THEN
                p_x_Line_PAYMENT_rec.ATTRIBUTE11 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE12 THEN
                p_x_Line_PAYMENT_rec.ATTRIBUTE12 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE13 THEN
                p_x_Line_PAYMENT_rec.ATTRIBUTE13 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE14 THEN
                p_x_Line_PAYMENT_rec.ATTRIBUTE14 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_ATTRIBUTE15 THEN
                p_x_Line_PAYMENT_rec.ATTRIBUTE15 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_CONTEXT THEN
                p_x_Line_PAYMENT_rec.CONTEXT := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_CREATED_BY THEN
                p_x_Line_PAYMENT_rec.CREATED_BY := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_CREATION_DATE THEN
                p_x_Line_PAYMENT_rec.CREATION_DATE := FND_API.G_MISS_DATE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_LAST_UPDATED_BY THEN
                p_x_Line_PAYMENT_rec.LAST_UPDATED_BY := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_LAST_UPDATE_DATE THEN
                p_x_Line_PAYMENT_rec.LAST_UPDATE_DATE := FND_API.G_MISS_DATE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_LAST_UPDATE_LOGIN THEN
                p_x_Line_PAYMENT_rec.LAST_UPDATE_LOGIN := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_CHECK_NUMBER THEN
                p_x_Line_PAYMENT_rec.CHECK_NUMBER := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_CODE THEN
		--R12 CC Encryption
		--Added the additional conditional before clearing credit
		--card attributes as the dependent attributes were cleared out
		--when the change attributes was called for multiple attributes
		--in a single call
		IF (OE_GLOBALS.Equal(p_x_Line_PAYMENT_rec.CREDIT_CARD_APPROVAL_CODE, p_old_Line_Payment_rec.CREDIT_CARD_APPROVAL_CODE)
	        AND (p_old_Line_Payment_rec.header_id IS NOT NULL OR
		p_x_Line_PAYMENT_rec.CREDIT_CARD_APPROVAL_CODE IS NOT NULL)
	        ) -- AND condition added to fix 3098878
	        THEN
			p_x_Line_PAYMENT_rec.CREDIT_CARD_APPROVAL_CODE := FND_API.G_MISS_CHAR;
		END IF;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_DATE THEN
		IF (OE_GLOBALS.Equal(p_x_Line_PAYMENT_rec.CREDIT_CARD_APPROVAL_DATE, p_old_Line_Payment_rec.CREDIT_CARD_APPROVAL_DATE)
	        AND (p_old_Line_Payment_rec.header_id IS NOT NULL OR
		p_x_Line_PAYMENT_rec.CREDIT_CARD_APPROVAL_DATE IS NOT NULL)
	        ) -- AND condition added to fix 3098878
	        THEN
	                p_x_Line_PAYMENT_rec.CREDIT_CARD_APPROVAL_DATE := FND_API.G_MISS_DATE;
		END IF;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_CODE THEN
		IF (OE_GLOBALS.Equal(p_x_Line_PAYMENT_rec.CREDIT_CARD_CODE, p_old_Line_Payment_rec.CREDIT_CARD_CODE)
	        AND (p_old_Line_Payment_rec.header_id IS NOT NULL OR
		p_x_Line_PAYMENT_rec.CREDIT_CARD_CODE IS NOT NULL)
	        ) -- AND condition added to fix 3098878
	        THEN
	                p_x_Line_PAYMENT_rec.CREDIT_CARD_CODE := FND_API.G_MISS_CHAR;
		END IF;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_EXPIRATION_DATE THEN
		--IF l_debug_level > 0 THEN
			--oe_debug_pub.add('Old exp date'||p_old_Line_Payment_rec.credit_card_expiration_date);
			--oe_debug_pub.add('New exp date'||p_x_Line_PAYMENT_rec.CREDIT_CARD_EXPIRATION_DATE);
		--END IF;
		IF (OE_GLOBALS.Equal(p_x_Line_PAYMENT_rec.CREDIT_CARD_EXPIRATION_DATE, p_old_Line_Payment_rec.CREDIT_CARD_EXPIRATION_DATE)
	        AND (p_old_Line_Payment_rec.header_id IS NOT NULL OR
		p_x_Line_PAYMENT_rec.CREDIT_CARD_EXPIRATION_DATE IS NOT NULL)
	        ) -- AND condition added to fix 3098878
	        THEN
			p_x_Line_PAYMENT_rec.CREDIT_CARD_EXPIRATION_DATE := FND_API.G_MISS_DATE;
		END IF;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_HOLDER_NAME THEN
		--IF l_debug_level > 0 THEN
			--oe_debug_pub.add('Old holder name'||p_old_Line_Payment_rec.CREDIT_CARD_HOLDER_NAME);
			--oe_debug_pub.add('New holder name'||p_x_Line_PAYMENT_rec.CREDIT_CARD_HOLDER_NAME);
		--END IF;
		IF (OE_GLOBALS.Equal(p_x_Line_PAYMENT_rec.CREDIT_CARD_HOLDER_NAME, p_old_Line_Payment_rec.CREDIT_CARD_HOLDER_NAME)
	        AND (p_old_Line_Payment_rec.header_id IS NOT NULL OR
		p_x_Line_PAYMENT_rec.CREDIT_CARD_HOLDER_NAME IS NOT NULL)
	        ) -- AND condition added to fix 3098878
	        THEN
			p_x_Line_PAYMENT_rec.CREDIT_CARD_HOLDER_NAME := FND_API.G_MISS_CHAR;
		END IF;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_NUMBER THEN
		IF (OE_GLOBALS.Is_Same_Credit_Card(p_old_Line_Payment_rec.CREDIT_CARD_NUMBER,
		p_x_Line_PAYMENT_rec.CREDIT_CARD_NUMBER,p_old_instrument_id,
		p_x_instrument_id)
	        AND (p_old_Line_Payment_rec.header_id IS NOT NULL OR
		p_x_Line_PAYMENT_rec.CREDIT_CARD_NUMBER IS NOT NULL)
	        ) -- AND condition added to fix 3098878
	        THEN
			p_x_Line_PAYMENT_rec.CREDIT_CARD_NUMBER := FND_API.G_MISS_CHAR;
		END IF;
		--R12 CC Encryption
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_PAYMENT_LEVEL_CODE THEN
                p_x_Line_PAYMENT_rec.PAYMENT_LEVEL_CODE := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_COMMITMENT_APPLIED_AMOUNT THEN
                p_x_Line_PAYMENT_rec.COMMITMENT_APPLIED_AMOUNT := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_COMMITMENT_INTERFACED_AMOUNT THEN
                p_x_Line_PAYMENT_rec.COMMITMENT_INTERFACED_AMOUNT := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_PAYMENT_NUMBER THEN
                p_x_Line_PAYMENT_rec.PAYMENT_NUMBER := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_HEADER THEN
                p_x_Line_PAYMENT_rec.HEADER_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_LINE THEN
                p_x_Line_PAYMENT_rec.LINE_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_PAYMENT_AMOUNT THEN
                p_x_Line_PAYMENT_rec.PAYMENT_AMOUNT := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_PAYMENT_COLLECTION_EVENT THEN
                p_x_Line_PAYMENT_rec.PAYMENT_COLLECTION_EVENT := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_PAYMENT_TRX_ID THEN
                p_x_Line_PAYMENT_rec.PAYMENT_TRX_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_PAYMENT_TYPE_CODE THEN
                p_x_Line_PAYMENT_rec.PAYMENT_TYPE_CODE := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_PAYMENT_SET_ID THEN
                p_x_Line_PAYMENT_rec.PAYMENT_SET_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_PREPAID_AMOUNT THEN
                p_x_Line_PAYMENT_rec.PREPAID_AMOUNT := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_PROGRAM_APPLICATION_ID THEN
                p_x_Line_PAYMENT_rec.PROGRAM_APPLICATION_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_PROGRAM_ID THEN
                p_x_Line_PAYMENT_rec.PROGRAM_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_PROGRAM_UPDATE_DATE THEN
                p_x_Line_PAYMENT_rec.PROGRAM_UPDATE_DATE := FND_API.G_MISS_DATE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_RECEIPT_METHOD_ID THEN
                p_x_Line_PAYMENT_rec.RECEIPT_METHOD_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_REQUEST_ID THEN
                p_x_Line_PAYMENT_rec.REQUEST_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_PAYMENT_UTIL.G_TANGIBLE_ID THEN
                p_x_Line_PAYMENT_rec.TANGIBLE_ID := FND_API.G_MISS_CHAR;
    	    END IF;
        END LOOP;
    END IF;
END Clear_Dependent_Attr;

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_Line_Payment_rec   IN OUT NOCOPY OE_Order_PUB.Line_Payment_Rec_Type
,   p_old_Line_Payment_rec        IN  OE_Order_PUB.Line_Payment_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_REC
)
IS
l_Line_Payment_rec		OE_AK_LINE_PAYMENTS_V%ROWTYPE;
l_old_Line_Payment_rec		OE_AK_LINE_PAYMENTS_V%ROWTYPE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	API_Rec_To_Rowtype_Rec(p_x_Line_Payment_rec, l_Line_Payment_rec);
	API_Rec_To_Rowtype_Rec(p_old_Line_Payment_rec, l_old_Line_Payment_rec);

	--R12 CC Encryption
	--Need to pass the instrument id for credit card comparison
	--as the card numbers are encrypted.
	Clear_Dependent_Attr
		(p_attr_id			=> p_attr_id
		,p_x_Line_Payment_rec 	=> l_Line_Payment_rec
		,p_old_Line_Payment_rec	=> l_old_Line_Payment_rec
		,p_old_instrument_id	=> p_old_Line_Payment_rec.cc_instrument_id  --R12 CC Encryption
		,p_x_instrument_id	=> p_x_Line_Payment_rec.cc_instrument_id
		);

	Rowtype_Rec_To_API_Rec(l_Line_Payment_rec,p_x_Line_Payment_rec);

END Clear_Dependent_Attr;

--ER#7479609 start
Procedure Delete_Line_PaymentType_Hold
(
   p_header_id       IN   NUMBER
,  p_line_id   	     IN   NUMBER
,  p_payment_number  IN  NUMBER
,  x_msg_count       OUT  NOCOPY NUMBER
,  x_msg_data        OUT  NOCOPY VARCHAR2
,  x_return_status   OUT  NOCOPY VARCHAR2
) IS

CURSOR line_paytype_hold IS
Select OH.Order_hold_id,NVL(OH.hold_release_id,0)
FROM OE_HOLD_SOURCES HS,OE_ORDER_HOLDS OH,OE_PAYMENTS OP
WHERE HS.hold_source_id=OH.hold_source_id
  AND OH.header_id=OP.header_id
  AND OH.line_id=OP.line_id
  AND OP.payment_number=p_payment_number
  AND ((HS.hold_entity_code= 'P' AND HS.hold_entity_id=OP.payment_type_code)
      OR (HS.hold_entity_code2 = 'P' AND HS.hold_entity_id2=OP.payment_type_code))
  AND OH.header_id=p_header_id
  AND OH.line_id=p_line_id;

l_order_hold_id  OE_ORDER_HOLDS.ORDER_HOLD_ID%TYPE;
l_hold_release_id  OE_ORDER_HOLDS.HOLD_RELEASE_ID%TYPE;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Entering Delete_Line_PaymentType_Hold' , 3 ) ;
  END IF;

    OPEN line_paytype_hold;

    LOOP
      FETCH line_paytype_hold INTO l_order_hold_id,l_hold_release_id;
      IF (line_paytype_hold%notfound) THEN
        EXIT;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'DELETING LINE PAYMENT TYPE HOLD' ) ;
      END IF;

      DELETE FROM OE_ORDER_HOLDS
       WHERE order_hold_id = l_order_hold_id;

      DELETE FROM OE_HOLD_RELEASES
       WHERE HOLD_RELEASE_ID = l_hold_release_id
         AND ORDER_HOLD_ID   = l_order_hold_id;
    END LOOP;

    CLOSE line_paytype_hold;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Exiting Delete_Line_PaymentType_Hold' , 3 ) ;
  END IF;

EXCEPTION
    	WHEN FND_API.G_EXC_ERROR THEN
    		IF (line_paytype_hold%isopen) THEN
    			CLOSE line_paytype_hold;
    		END IF;

        	x_return_status := FND_API.G_RET_STS_ERROR;
        	FND_MSG_PUB.Count_And_Get
		(   p_count 	=>	x_msg_count
		,   p_data	=>	x_msg_data
	  	);
    	WHEN OTHERS THEN
    		IF (line_paytype_hold%isopen) THEN
    			CLOSE line_paytype_hold;
    		END IF;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        	FND_MSG_PUB.Count_And_Get
		(   p_count 	=>	x_msg_count
		,   p_data	=>	x_msg_data
	  	);

END Delete_Line_PaymentType_Hold;
--ER#7479609 end


--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_x_Line_Payment_rec            IN OUT NOCOPY OE_Order_PUB.Line_Payment_Rec_Type
,   p_old_Line_Payment_rec        IN  OE_Order_PUB.Line_Payment_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_Payment_REC
)
IS
l_return_status                   Varchar2(10);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_payments_update_flag VARCHAR2(1) := 'N';
--bug3625027 start
l_invoke_credit_checking VARCHAR2(1) := 'N';
l_booked_flag VARCHAR2(1) :='N';
l_cc_flag_old VARCHAR2(1);
l_cc_flag_new VARCHAR2(1);
--bug3625027 end
l_calculate_commitment_flag     VARCHAR2(1) := 'N';
l_msg_count number := 0;
l_msg_data varchar2(2000) := null;
l_delete_pmt_hold		VARCHAR2(1) := 'N';

BEGIN

    --  Load out record


    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute1,p_old_Line_Payment_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute2,p_old_Line_Payment_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute3,p_old_Line_Payment_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute4,p_old_Line_Payment_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute5,p_old_Line_Payment_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute6,p_old_Line_Payment_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute7,p_old_Line_Payment_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute8,p_old_Line_Payment_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute9,p_old_Line_Payment_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute10,p_old_Line_Payment_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute11,p_old_Line_Payment_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute12,p_old_Line_Payment_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute13,p_old_Line_Payment_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute14,p_old_Line_Payment_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.attribute15,p_old_Line_Payment_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.context,p_old_Line_Payment_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.created_by,p_old_Line_Payment_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.creation_date,p_old_Line_Payment_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.last_updated_by,p_old_Line_Payment_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.last_update_date,p_old_Line_Payment_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.last_update_login,p_old_Line_Payment_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.check_number,p_old_Line_Payment_rec.check_number)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.credit_card_approval_code,p_old_Line_Payment_rec.credit_card_approval_code)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.credit_card_approval_date,p_old_Line_Payment_rec.credit_card_approval_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.credit_card_code,p_old_Line_Payment_rec.credit_card_code)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.credit_card_expiration_date,p_old_Line_Payment_rec.credit_card_expiration_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.credit_card_holder_name,p_old_Line_Payment_rec.credit_card_holder_name)
    THEN
        NULL;
    END IF;

    --R12 CC Encryption
    --Since the credit card numbers are encrypted, passing both the credit card
    --numbers as well as instrument ids to determine if both the old and new
    --values point to the same credit card number.
    IF l_debug_level > 0 THEN
	--oe_debug_pub.add('Old cc number'||p_old_Line_Payment_rec.credit_card_number);
	--oe_debug_pub.add('New cc number'||p_x_Line_Payment_rec.credit_card_number);
	oe_debug_pub.add('Old instr id'||p_old_Line_Payment_rec.cc_instrument_id);
	oe_debug_pub.add('New instr id'||p_x_Line_Payment_rec.cc_instrument_id);
    END IF;

    IF NOT OE_GLOBALS.Is_Same_Credit_Card(p_old_Line_Payment_rec.credit_card_number,
	    p_x_Line_Payment_rec.credit_card_number,
	    p_old_Line_Payment_rec.cc_instrument_id,
	    p_x_Line_Payment_rec.cc_instrument_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.payment_level_code,p_old_Line_Payment_rec.payment_level_code)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.commitment_applied_amount,p_old_Line_Payment_rec.commitment_applied_amount)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.commitment_interfaced_amount,p_old_Line_Payment_rec.commitment_interfaced_amount)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.payment_number,p_old_Line_Payment_rec.payment_number)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.header_id,p_old_Line_Payment_rec.header_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.line_id,p_old_Line_Payment_rec.line_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.payment_amount,p_old_Line_Payment_rec.payment_amount)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.payment_collection_event,p_old_Line_Payment_rec.payment_collection_event)
    THEN
          NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.defer_payment_processing_flag,p_old_Line_Payment_rec.defer_payment_processing_flag)
    THEN
          NULL;
    END IF;

    -- R12 CC Encryption
    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.trxn_extension_id,p_old_Line_Payment_rec.trxn_extension_id)
    THEN
          NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.instrument_security_code,p_old_Line_Payment_rec.instrument_security_code)
    THEN
        NULL;
    END IF;

    -- R12 CC Encryption


    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.payment_trx_id,p_old_Line_Payment_rec.payment_trx_id)
    THEN
           IF p_x_Line_Payment_rec.payment_type_code = 'COMMITMENT'
             AND OE_Commitment_Pvt.Do_Commitment_Sequencing
             AND NOT OE_GLOBALS.G_UI_FLAG THEN
             -- only need to log delayed request when this is not from UI.
             l_calculate_commitment_flag := 'Y';
          END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.payment_type_code,p_old_Line_Payment_rec.payment_type_code)
    THEN
        l_payments_update_flag := 'Y';

        IF p_old_Line_Payment_rec.payment_type_code = 'CREDIT_CARD'
          AND p_x_Line_Payment_rec.operation = 'UPDATE' THEN
          l_delete_pmt_hold := 'Y';
        END IF;

	--bug3625027 start
	BEGIN
	        -- use order_header cache instead of sql : bug 4200055
		if ( OE_Order_Cache.g_header_rec.header_id <> FND_API.G_MISS_NUM
		     and OE_Order_Cache.g_header_rec.header_id IS NOT NULL
		     and OE_Order_Cache.g_header_rec.header_id = p_x_Line_Payment_rec.header_id ) then
            		l_booked_flag := OE_Order_Cache.g_header_rec.booked_flag ;
                else
                     OE_ORDER_CACHE.Load_Order_Header(p_x_Line_Payment_rec.header_id);
                     l_booked_flag := OE_Order_Cache.g_header_rec.booked_flag ;
                end if ;
	   /*SELECT booked_flag INTO l_booked_flag
	   FROM oe_order_headers_all
	   WHERE header_id=p_x_Line_Payment_rec.header_id; */
	      -- end bug 4200055

	   IF p_old_Line_Payment_rec.payment_type_code IS NOT NULL THEN
	      SELECT credit_check_flag INTO l_cc_flag_old
	      FROM oe_payment_types_vl
	      WHERE payment_type_code=p_old_Line_Payment_rec.payment_type_code;
	   END IF;

	   SELECT credit_check_flag INTO l_cc_flag_new
	   FROM oe_payment_types_vl
	   WHERE payment_type_code=p_x_Line_Payment_rec.payment_type_code;

	   IF l_booked_flag = 'Y' AND
	      NOT OE_GLOBALS.Equal(l_cc_flag_old,l_cc_flag_new) THEN

	        IF( l_debug_level > 0) THEN
		      oe_debug_pub.add('l_invoke_credit_checking is: '||l_invoke_credit_checking, 3);
		END IF;

                l_invoke_credit_checking := 'Y';

	   END IF;

       EXCEPTION
	  WHEN no_data_found THEN
	     null;
	  WHEN others THEN
	     null;
       END;
	--bug3625027 end

       IF p_x_Line_Payment_rec.payment_type_code <> 'COMMITMENT' AND
          p_old_Line_Payment_rec.payment_type_code = 'COMMITMENT' THEN
          Delete_Payment_at_line(p_line_id => p_x_Line_Payment_rec.line_id,
                           p_payment_number => p_x_Line_Payment_rec.payment_number,
                           p_payment_type_code => 'COMMITMENT',
                           p_del_commitment => 1,
                                   x_return_status => l_return_status,
                                   x_msg_count => l_msg_count,
                                   x_msg_data => l_msg_data);

       END IF;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.payment_set_id,p_old_Line_Payment_rec.payment_set_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.prepaid_amount,p_old_Line_Payment_rec.prepaid_amount)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.program_application_id,p_old_Line_Payment_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.program_id,p_old_Line_Payment_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.program_update_date,p_old_Line_Payment_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.receipt_method_id,p_old_Line_Payment_rec.receipt_method_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.request_id,p_old_Line_Payment_rec.request_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.tangible_id,p_old_Line_Payment_rec.tangible_id)
    THEN
        NULL;
    END IF;

    IF l_payments_update_flag = 'Y' and
       OE_PrePayment_UTIL.IS_MULTIPLE_PAYMENTS_ENABLED = TRUE then

       oe_debug_pub.add('logging synch from ULPMB.pls payment delayed request', 1);

       oe_debug_pub.add('line_id is: ' || p_x_Line_Payment_rec.line_id);

       OE_delayed_requests_Pvt.log_request
		(p_entity_code            => OE_GLOBALS.G_ENTITY_LINE_PAYMENT,
		p_entity_id              => p_x_Line_Payment_rec.line_id,
		p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
		p_requesting_entity_id   => p_x_Line_Payment_rec.line_id,
		p_request_type           => OE_GLOBALS.G_UPDATE_HDR_PAYMENT,
                p_param1                 => 'UPDATE_LINE',
                p_param2                 => p_x_Line_Payment_rec.header_id,
		x_return_status          => l_return_status);

     END IF;

     IF l_calculate_commitment_flag = 'Y' THEN
       IF l_debug_level > 0 then
          oe_debug_pub.add('OEXULPMB: Logging delayed request for Commitment.', 1);
       END IF;

       OE_Delayed_Requests_Pvt.Log_Request(
           p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
           p_entity_id              => p_x_Line_Payment_rec.line_id,
           p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
           p_requesting_entity_id   => p_x_Line_Payment_rec.line_id,
           p_request_type           => OE_GLOBALS.G_CALCULATE_COMMITMENT,
           x_return_status          => l_return_status);
     END IF;

--bug3625027 start
     IF l_invoke_credit_checking = 'Y'
        AND  OE_PrePayment_UTIL.IS_MULTIPLE_PAYMENTS_ENABLED = TRUE THEN
        IF( l_debug_level > 0) THEN
            oe_debug_pub.add('pviprana: logging a new payment delayed request for processing the payment', 1);
            oe_debug_pub.add('line_id is: ' || p_x_Line_Payment_rec.line_id);
	END IF;
	OE_delayed_requests_Pvt.log_request
		   (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE_PAYMENT,
		    p_entity_id              => p_x_Line_Payment_rec.header_id,
		    p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
		    p_requesting_entity_id   => p_x_Line_Payment_rec.line_id,
		    p_request_type           => OE_GLOBALS.G_PROCESS_PAYMENT,
		    p_param1                 => p_x_Line_Payment_rec.line_id,
		    x_return_status          => l_return_status);
     END IF;
--bug3625027 end

     IF l_delete_pmt_hold = 'Y' THEN
       IF l_debug_level > 0 then
          oe_debug_pub.add('OEXULPMB: Logging delayed request for Delete_Payment_Hold.', 3);
       END IF;

       OE_delayed_requests_Pvt.log_request
		(p_entity_code            => OE_GLOBALS.G_ENTITY_LINE_PAYMENT,
		p_entity_id              => p_x_Line_Payment_rec.line_id,
		p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
		p_requesting_entity_id   => p_x_Line_Payment_rec.line_id,
		p_request_type           => OE_GLOBALS.G_DELETE_PAYMENT_HOLD,
                p_param1                 => 'VERIFY_PAYMENT',
                p_param2                 => p_x_Line_Payment_rec.header_id,
		x_return_status          => l_return_status);
     END IF;


     oe_debug_pub.add('OEXULPMB.pls : exiting apply attribute changes');

--ER#7479609 start
    IF NOT OE_GLOBALS.Equal(p_x_Line_Payment_rec.payment_type_code,p_old_Line_Payment_rec.payment_type_code)
    THEN
		oe_debug_pub.add('logging Delayed request for evaluation of payments hold', 1);

                OE_delayed_requests_Pvt.log_request
                 (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE_PAYMENT,
                  p_entity_id              => p_x_Line_Payment_rec.line_id,
                  p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                  p_requesting_entity_id   => p_x_Line_Payment_rec.line_id,
                  p_request_type           => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                  p_request_unique_key1    => 'PAYMENT_TYPE',
                  p_param1                 => 'P',
                  p_param2                 => p_x_Line_Payment_rec.payment_type_code,
                  x_return_status          => l_return_status);
    END IF;
--ER#7479609 end
END Apply_Attribute_Changes;

--  Procedure Complete_Record

PROCEDURE Complete_Record
(   p_x_Line_Payment_rec     IN OUT NOCOPY OE_Order_PUB.Line_Payment_Rec_Type
,   p_old_Line_Payment_rec        IN  OE_Order_PUB.Line_Payment_Rec_Type
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_x_Line_Payment_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute1 := p_old_Line_Payment_rec.attribute1;
    END IF;

    IF p_x_Line_Payment_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute2 := p_old_Line_Payment_rec.attribute2;
    END IF;

    IF p_x_Line_Payment_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute3 := p_old_Line_Payment_rec.attribute3;
    END IF;

    IF p_x_Line_Payment_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute4 := p_old_Line_Payment_rec.attribute4;
    END IF;

    IF p_x_Line_Payment_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute5 := p_old_Line_Payment_rec.attribute5;
    END IF;

    IF p_x_Line_Payment_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute6 := p_old_Line_Payment_rec.attribute6;
    END IF;

    IF p_x_Line_Payment_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute7 := p_old_Line_Payment_rec.attribute7;
    END IF;

    IF p_x_Line_Payment_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute8 := p_old_Line_Payment_rec.attribute8;
    END IF;

    IF p_x_Line_Payment_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute9 := p_old_Line_Payment_rec.attribute9;
    END IF;

    IF p_x_Line_Payment_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute10 := p_old_Line_Payment_rec.attribute10;
    END IF;

    IF p_x_Line_Payment_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute11 := p_old_Line_Payment_rec.attribute11;
    END IF;

    IF p_x_Line_Payment_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute12 := p_old_Line_Payment_rec.attribute12;
    END IF;

    IF p_x_Line_Payment_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute13 := p_old_Line_Payment_rec.attribute13;
    END IF;

    IF p_x_Line_Payment_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute14 := p_old_Line_Payment_rec.attribute14;
    END IF;

    IF p_x_Line_Payment_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute15 := p_old_Line_Payment_rec.attribute15;
    END IF;

    IF p_x_Line_Payment_rec.context = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.context := p_old_Line_Payment_rec.context;
    END IF;

    IF p_x_Line_Payment_rec.created_by = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.created_by := p_old_Line_Payment_rec.created_by;
    END IF;

    IF p_x_Line_Payment_rec.creation_date = FND_API.G_MISS_DATE THEN
        p_x_Line_Payment_rec.creation_date := p_old_Line_Payment_rec.creation_date;
    END IF;

    IF p_x_Line_Payment_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.last_updated_by := p_old_Line_Payment_rec.last_updated_by;
    END IF;

    IF p_x_Line_Payment_rec.last_update_date = FND_API.G_MISS_DATE THEN
        p_x_Line_Payment_rec.last_update_date := p_old_Line_Payment_rec.last_update_date;
    END IF;

    IF p_x_Line_Payment_rec.last_update_login = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.last_update_login := p_old_Line_Payment_rec.last_update_login;
    END IF;

    IF p_x_Line_Payment_rec.check_number = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.check_number := p_old_Line_Payment_rec.check_number;
    END IF;

    IF p_x_Line_Payment_rec.credit_card_approval_code = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.credit_card_approval_code := p_old_Line_Payment_rec.credit_card_approval_code;
    END IF;

    IF p_x_Line_Payment_rec.credit_card_approval_date = FND_API.G_MISS_DATE THEN
        p_x_Line_Payment_rec.credit_card_approval_date := p_old_Line_Payment_rec.credit_card_approval_date;
    END IF;

    IF p_x_Line_Payment_rec.credit_card_code = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.credit_card_code := p_old_Line_Payment_rec.credit_card_code;
    END IF;

    IF p_x_Line_Payment_rec.credit_card_expiration_date = FND_API.G_MISS_DATE THEN
        p_x_Line_Payment_rec.credit_card_expiration_date := p_old_Line_Payment_rec.credit_card_expiration_date;
    END IF;

    IF p_x_Line_Payment_rec.credit_card_holder_name = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.credit_card_holder_name := p_old_Line_Payment_rec.credit_card_holder_name;
    END IF;

    IF p_x_Line_Payment_rec.credit_card_number = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.credit_card_number := p_old_Line_Payment_rec.credit_card_number;
    END IF;

    IF p_x_Line_Payment_rec.payment_level_code = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.payment_level_code := p_old_Line_Payment_rec.payment_level_code;
    END IF;

    IF p_x_Line_Payment_rec.commitment_applied_amount = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.commitment_applied_amount := p_old_Line_Payment_rec.commitment_applied_amount;
    END IF;

    IF p_x_Line_Payment_rec.commitment_interfaced_amount = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.commitment_interfaced_amount := p_old_Line_Payment_rec.commitment_interfaced_amount;
    END IF;

    IF p_x_Line_Payment_rec.payment_number = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.payment_number := p_old_Line_Payment_rec.payment_number;
    END IF;

    IF p_x_Line_Payment_rec.header_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.header_id := p_old_Line_Payment_rec.header_id;
    END IF;

    IF p_x_Line_Payment_rec.line_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.line_id := p_old_Line_Payment_rec.line_id;
    END IF;

    IF p_x_Line_Payment_rec.payment_amount = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.payment_amount := p_old_Line_Payment_rec.payment_amount;
    END IF;

    IF p_x_Line_Payment_rec.payment_collection_event = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.payment_collection_event := p_old_Line_Payment_rec.payment_collection_event;
    END IF;

    IF p_x_Line_Payment_rec.defer_payment_processing_flag = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.defer_payment_processing_flag := p_old_Line_Payment_rec.defer_payment_processing_flag;
    END IF;

    IF p_x_Line_Payment_rec.payment_trx_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.payment_trx_id := p_old_Line_Payment_rec.payment_trx_id;
    END IF;

    IF p_x_Line_Payment_rec.payment_type_code = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.payment_type_code := p_old_Line_Payment_rec.payment_type_code;
    END IF;

    IF p_x_Line_Payment_rec.payment_set_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.payment_set_id := p_old_Line_Payment_rec.payment_set_id;
    END IF;

    IF p_x_Line_Payment_rec.prepaid_amount = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.prepaid_amount := p_old_Line_Payment_rec.prepaid_amount;
    END IF;

    IF p_x_Line_Payment_rec.program_application_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.program_application_id := p_old_Line_Payment_rec.program_application_id;
    END IF;

    IF p_x_Line_Payment_rec.program_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.program_id := p_old_Line_Payment_rec.program_id;
    END IF;

    IF p_x_Line_Payment_rec.program_update_date = FND_API.G_MISS_DATE THEN
        p_x_Line_Payment_rec.program_update_date := p_old_Line_Payment_rec.program_update_date;
    END IF;

    IF p_x_Line_Payment_rec.receipt_method_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.receipt_method_id := p_old_Line_Payment_rec.receipt_method_id;
    END IF;

    IF p_x_Line_Payment_rec.request_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.request_id := p_old_Line_Payment_rec.request_id;
    END IF;

    IF p_x_Line_Payment_rec.tangible_id = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.tangible_id := p_old_Line_Payment_rec.tangible_id;
    END IF;

    IF p_x_Line_Payment_rec.trxn_extension_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.trxn_extension_id := p_old_Line_Payment_rec.trxn_extension_id;
    END IF;

    -- R12 CC Encryption
    IF p_x_Line_Payment_rec.trxn_extension_id = FND_API.G_MISS_NUM THEN
	p_x_Line_Payment_rec.trxn_extension_id := p_old_Line_Payment_rec.trxn_extension_id;
    END IF;

    IF p_x_Line_Payment_rec.instrument_security_code = FND_API.G_MISS_CHAR THEN
	p_x_Line_Payment_rec.instrument_security_code := p_old_Line_Payment_rec.instrument_security_code;
    END IF;

    -- R12 CC Encryption

END Complete_Record;

--  Procedure Convert_Miss_To_Null

PROCEDURE Convert_Miss_To_Null
(   p_x_Line_Payment_rec  IN OUT NOCOPY  OE_Order_PUB.Line_Payment_Rec_Type
)
IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_x_Line_Payment_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute1 := NULL;
    END IF;

    IF p_x_Line_Payment_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute2 := NULL;
    END IF;

    IF p_x_Line_Payment_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute3 := NULL;
    END IF;

    IF p_x_Line_Payment_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute4 := NULL;
    END IF;

    IF p_x_Line_Payment_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute5 := NULL;
    END IF;

    IF p_x_Line_Payment_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute6 := NULL;
    END IF;

    IF p_x_Line_Payment_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute7 := NULL;
    END IF;

    IF p_x_Line_Payment_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute8 := NULL;
    END IF;

    IF p_x_Line_Payment_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute9 := NULL;
    END IF;

    IF p_x_Line_Payment_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute10 := NULL;
    END IF;

    IF p_x_Line_Payment_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute11 := NULL;
    END IF;

    IF p_x_Line_Payment_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute12 := NULL;
    END IF;

    IF p_x_Line_Payment_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute13 := NULL;
    END IF;

    IF p_x_Line_Payment_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute14 := NULL;
    END IF;

    IF p_x_Line_Payment_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.attribute15 := NULL;
    END IF;

    IF p_x_Line_Payment_rec.context = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.context := NULL;
    END IF;

    IF p_x_Line_Payment_rec.created_by = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.created_by := NULL;
    END IF;

    IF p_x_Line_Payment_rec.creation_date = FND_API.G_MISS_DATE THEN
        p_x_Line_Payment_rec.creation_date := NULL;
    END IF;

    IF p_x_Line_Payment_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.last_updated_by := NULL;
    END IF;

    IF p_x_Line_Payment_rec.last_update_date = FND_API.G_MISS_DATE THEN
        p_x_Line_Payment_rec.last_update_date := NULL;
    END IF;

    IF p_x_Line_Payment_rec.last_update_login = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.last_update_login := NULL;
    END IF;

    IF p_x_Line_Payment_rec.check_number = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.check_number := NULL;
    END IF;

    IF p_x_Line_Payment_rec.credit_card_approval_code = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.credit_card_approval_code := NULL;
    END IF;

    IF p_x_Line_Payment_rec.credit_card_approval_date = FND_API.G_MISS_DATE THEN
        p_x_Line_Payment_rec.credit_card_approval_date := NULL;
    END IF;

    IF p_x_Line_Payment_rec.credit_card_code = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.credit_card_code := NULL;
    END IF;

    IF p_x_Line_Payment_rec.credit_card_expiration_date = FND_API.G_MISS_DATE THEN
        p_x_Line_Payment_rec.credit_card_expiration_date := NULL;
    END IF;

    IF p_x_Line_Payment_rec.credit_card_holder_name = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.credit_card_holder_name := NULL;
    END IF;

    IF p_x_Line_Payment_rec.credit_card_number = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.credit_card_number := NULL;
    END IF;

    IF p_x_Line_Payment_rec.payment_level_code = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.payment_level_code := NULL;
    END IF;

    IF p_x_Line_Payment_rec.commitment_applied_amount = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.commitment_applied_amount := NULL;
    END IF;

    IF p_x_Line_Payment_rec.commitment_interfaced_amount = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.commitment_interfaced_amount := NULL;
    END IF;

    IF p_x_Line_Payment_rec.payment_number = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.payment_number := NULL;
    END IF;

    IF p_x_Line_Payment_rec.header_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.header_id := NULL;
    END IF;

    IF p_x_Line_Payment_rec.line_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.line_id := NULL;
    END IF;

    IF p_x_Line_Payment_rec.payment_amount = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.payment_amount := NULL;
    END IF;

    IF p_x_Line_Payment_rec.payment_collection_event = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.payment_collection_event := NULL;
    END IF;

    IF p_x_Line_Payment_rec.defer_payment_processing_flag = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.defer_payment_processing_flag := NULL;
    END IF;

    IF p_x_Line_Payment_rec.payment_trx_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.payment_trx_id := NULL;
    END IF;

    IF p_x_Line_Payment_rec.payment_type_code = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.payment_type_code := NULL;
    END IF;

    IF p_x_Line_Payment_rec.payment_set_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.payment_set_id := NULL;
    END IF;

    IF p_x_Line_Payment_rec.prepaid_amount = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.prepaid_amount := NULL;
    END IF;

    IF p_x_Line_Payment_rec.program_application_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.program_application_id := NULL;
    END IF;

    IF p_x_Line_Payment_rec.program_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.program_id := NULL;
    END IF;

    IF p_x_Line_Payment_rec.program_update_date = FND_API.G_MISS_DATE THEN
        p_x_Line_Payment_rec.program_update_date := NULL;
    END IF;

    IF p_x_Line_Payment_rec.receipt_method_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.receipt_method_id := NULL;
    END IF;

    IF p_x_Line_Payment_rec.request_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.request_id := NULL;
    END IF;

    IF p_x_Line_Payment_rec.tangible_id = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.tangible_id := NULL;
    END IF;
    -- R12 CC Encryption
    IF p_x_Line_Payment_rec.trxn_extension_id = FND_API.G_MISS_NUM THEN
        p_x_Line_Payment_rec.trxn_extension_id := NULL;
    END IF;

    IF p_x_Line_Payment_rec.instrument_security_code = FND_API.G_MISS_CHAR THEN
        p_x_Line_Payment_rec.instrument_security_code := NULL;
    END IF;

    -- R12 CC Encryption

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Line_Payment_rec            IN OUT NOCOPY OE_Order_PUB.Line_Payment_Rec_Type
)
IS
    l_lock_control   NUMBER;
 --added for notification framework
      l_index    NUMBER;
      l_return_status VARCHAR2(1);


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    SELECT lock_control
    INTO   l_lock_control
    FROM   OE_PAYMENTS
    WHERE  payment_number = p_Line_Payment_rec.payment_number
    AND    header_id = p_Line_Payment_rec.header_id
    AND    line_id = p_Line_Payment_rec.line_id;

    l_lock_control := l_lock_control + 1;

   --calling notification framework to update global picture
   --check code release level first. Notification framework is at Pack H level
    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'JFC: payment_number' || P_LINE_Payment_REC.payment_number ) ;
       END IF;
-- Sasi: this should be added by Renga
  /*     OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_Line_pmt_rec =>p_line_Payment_rec,
                    p_line_pmt_id => p_line_Payment_rec.payment_number,
                    x_index => l_index,
                    x_return_status => l_return_status); */
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_LINE_PAYMENT_UTIL.UPDATE_ROW IS: ' || L_RETURN_STATUS ) ;
       END IF;
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EXITING OE_LINE_PAYMENT_UTIL.UPDATE_ROW' , 1 ) ;
          END IF;
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_LINE_PAYMENT_UTIL.UPDATE_ROW' ) ;
          END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'EXITING OE_LINE_PAYMENT_UTIL.UPDATE_ROW' , 1 ) ;
         END IF;
	 RAISE FND_API.G_EXC_ERROR;
       END IF;
   END IF; /*code_release_level*/
    -- notification framework end

    UPDATE  OE_PAYMENTS
    SET     ATTRIBUTE1                     = p_Line_Payment_rec.attribute1
    ,       ATTRIBUTE2                     = p_Line_Payment_rec.attribute2
    ,       ATTRIBUTE3                     = p_Line_Payment_rec.attribute3
    ,       ATTRIBUTE4                     = p_Line_Payment_rec.attribute4
    ,       ATTRIBUTE5                     = p_Line_Payment_rec.attribute5
    ,       ATTRIBUTE6                     = p_Line_Payment_rec.attribute6
    ,       ATTRIBUTE7                     = p_Line_Payment_rec.attribute7
    ,       ATTRIBUTE8                     = p_Line_Payment_rec.attribute8
    ,       ATTRIBUTE9                     = p_Line_Payment_rec.attribute9
    ,       ATTRIBUTE10                    = p_Line_Payment_rec.attribute10
    ,       ATTRIBUTE11                    = p_Line_Payment_rec.attribute11
    ,       ATTRIBUTE12                    = p_Line_Payment_rec.attribute12
    ,       ATTRIBUTE13                    = p_Line_Payment_rec.attribute13
    ,       ATTRIBUTE14                    = p_Line_Payment_rec.attribute14
    ,       ATTRIBUTE15                    = p_Line_Payment_rec.attribute15
    ,       CONTEXT                        = p_Line_Payment_rec.context
    ,       CREATED_BY                     = p_Line_Payment_rec.created_by
    ,       CREATION_DATE                  = p_Line_Payment_rec.creation_date
    ,       LAST_UPDATED_BY                = p_Line_Payment_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_Line_Payment_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_Line_Payment_rec.last_update_login
    ,       CHECK_NUMBER                   = p_Line_Payment_rec.check_number
    /*,       CREDIT_CARD_APPROVAL_CODE      = p_Line_Payment_rec.credit_card_approval_code --R12 CC Encryption
    ,       CREDIT_CARD_APPROVAL_DATE      = p_Line_Payment_rec.credit_card_approval_date
    ,       CREDIT_CARD_CODE               = p_Line_Payment_rec.credit_card_code
    ,       CREDIT_CARD_EXPIRATION_DATE    = p_Line_Payment_rec.credit_card_expiration_date
    ,       CREDIT_CARD_HOLDER_NAME        = p_Line_Payment_rec.credit_card_holder_name
    ,       CREDIT_CARD_NUMBER             = p_Line_Payment_rec.credit_card_number*/
    ,       PAYMENT_LEVEL_CODE             = p_Line_Payment_rec.payment_level_code
    ,       COMMITMENT_APPLIED_AMOUNT      = p_Line_Payment_rec.commitment_applied_amount
    ,       COMMITMENT_INTERFACED_AMOUNT   = p_Line_Payment_rec.commitment_interfaced_amount
    ,       PAYMENT_NUMBER                     = p_Line_Payment_rec.payment_number
    ,       HEADER_ID                      = p_Line_Payment_rec.header_id
    ,       LINE_ID                        = p_Line_Payment_rec.line_id
    ,       PAYMENT_AMOUNT                 = p_Line_Payment_rec.payment_amount
    ,       PAYMENT_COLLECTION_EVENT       = p_Line_Payment_rec.payment_collection_event
    ,       PAYMENT_TRX_ID                 = p_Line_Payment_rec.payment_trx_id
    ,       PAYMENT_TYPE_CODE              = p_Line_Payment_rec.payment_type_code
    ,       PAYMENT_SET_ID                 = p_Line_Payment_rec.payment_set_id
    ,       PREPAID_AMOUNT                 = p_Line_Payment_rec.prepaid_amount
    ,       PROGRAM_APPLICATION_ID         = p_Line_Payment_rec.program_application_id
    ,       PROGRAM_ID                     = p_Line_Payment_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_Line_Payment_rec.program_update_date
    ,       RECEIPT_METHOD_ID              = p_Line_Payment_rec.receipt_method_id
    ,       REQUEST_ID                     = p_Line_Payment_rec.request_id
    --,       TANGIBLE_ID                    = p_Line_Payment_rec.tangible_id --R12 CC Encryption
    ,       DEFER_PAYMENT_PROCESSING_FLAG  = p_Line_Payment_rec.defer_payment_processing_flag
    ,       TRXN_EXTENSION_ID              = p_Line_Payment_rec.trxn_extension_id
    ,       LOCK_CONTROL                   = l_lock_control
    WHERE   PAYMENT_NUMBER = p_Line_Payment_rec.payment_number
    AND     HEADER_ID = p_Line_Payment_rec.header_id
    AND     LINE_ID = p_Line_Payment_rec.line_id
    ;

    p_Line_Payment_rec.lock_control :=   l_lock_control;

EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row;

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Line_Payment_rec       IN OUT NOCOPY  OE_Order_PUB.Line_Payment_Rec_Type
)
IS
    l_lock_control   NUMBER:= 1;
    l_index          NUMBER;
    l_return_status VARCHAR2(1);
    l_transaction_phase_code VARCHAR2(30);
    --
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    --
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_LINE_PAYMENT_UTIL.INSERT_ROW' , 1 ) ;
   END IF;

    -- QUOTING change
    -- No need to insert commitment for orders in negotiation phase
    IF p_line_Payment_rec.payment_type_code = 'COMMITMENT' THEN
      BEGIN
        SELECT   l.transaction_phase_code
        INTO     l_transaction_phase_code
        FROM     oe_order_lines_all l
        WHERE    l.line_id = p_line_Payment_rec.line_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
                null;
      END;

      if l_debug_level > 0 then
        oe_debug_pub.add('trxn phase :'||l_transaction_phase_code);
      end if;
      IF nvl(l_transaction_phase_code, 'F') = 'N' THEN
        RETURN;
      END IF;
   END IF;


    INSERT  INTO OE_PAYMENTS
    (       ATTRIBUTE1
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       CHECK_NUMBER
    /*,       CREDIT_CARD_APPROVAL_CODE  --R12 CC Encryption
    ,       CREDIT_CARD_APPROVAL_DATE
    ,       CREDIT_CARD_CODE
    ,       CREDIT_CARD_EXPIRATION_DATE
    ,       CREDIT_CARD_HOLDER_NAME
    ,       CREDIT_CARD_NUMBER*/  --R12 CC Encryption
    ,       PAYMENT_LEVEL_CODE
    ,       COMMITMENT_APPLIED_AMOUNT
    ,       COMMITMENT_INTERFACED_AMOUNT
    ,       PAYMENT_NUMBER
    ,       HEADER_ID
    ,       LINE_ID
    ,       PAYMENT_AMOUNT
    ,       PAYMENT_COLLECTION_EVENT
    ,       PAYMENT_TRX_ID
    ,       PAYMENT_TYPE_CODE
    ,       PAYMENT_SET_ID
    ,       PREPAID_AMOUNT
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       RECEIPT_METHOD_ID
    ,       REQUEST_ID
    --,       TANGIBLE_ID --R12 CC Encryption
    ,       DEFER_PAYMENT_PROCESSING_FLAG
    ,       TRXN_EXTENSION_ID
    ,       LOCK_CONTROL
    ,       ORIG_SYS_PAYMENT_REF  --5892425
    )
    VALUES
    (       p_Line_Payment_rec.attribute1
    ,       p_Line_Payment_rec.attribute2
    ,       p_Line_Payment_rec.attribute3
    ,       p_Line_Payment_rec.attribute4
    ,       p_Line_Payment_rec.attribute5
    ,       p_Line_Payment_rec.attribute6
    ,       p_Line_Payment_rec.attribute7
    ,       p_Line_Payment_rec.attribute8
    ,       p_Line_Payment_rec.attribute9
    ,       p_Line_Payment_rec.attribute10
    ,       p_Line_Payment_rec.attribute11
    ,       p_Line_Payment_rec.attribute12
    ,       p_Line_Payment_rec.attribute13
    ,       p_Line_Payment_rec.attribute14
    ,       p_Line_Payment_rec.attribute15
    ,       p_Line_Payment_rec.context
    ,       p_Line_Payment_rec.created_by
    ,       p_Line_Payment_rec.creation_date
    ,       p_Line_Payment_rec.last_updated_by
    ,       p_Line_Payment_rec.last_update_date
    ,       p_Line_Payment_rec.last_update_login
    ,       p_Line_Payment_rec.check_number
    /*,       p_Line_Payment_rec.credit_card_approval_code --R12 CC Encryption
    ,       p_Line_Payment_rec.credit_card_approval_date
    ,       p_Line_Payment_rec.credit_card_code
    ,       p_Line_Payment_rec.credit_card_expiration_date
    ,       p_Line_Payment_rec.credit_card_holder_name
    ,       p_Line_Payment_rec.credit_card_number*/  --R12 CC Encryption
    ,       p_Line_Payment_rec.payment_level_code
    ,       p_Line_Payment_rec.commitment_applied_amount
    ,       p_Line_Payment_rec.commitment_interfaced_amount
    ,       p_Line_Payment_rec.payment_number
    ,       p_Line_Payment_rec.header_id
    ,       p_Line_Payment_rec.line_id
    ,       p_Line_Payment_rec.payment_amount
    ,       p_Line_Payment_rec.payment_collection_event
    ,       p_Line_Payment_rec.payment_trx_id
    ,       p_Line_Payment_rec.payment_type_code
    ,       p_Line_Payment_rec.payment_set_id
    ,       p_Line_Payment_rec.prepaid_amount
    ,       p_Line_Payment_rec.program_application_id
    ,       p_Line_Payment_rec.program_id
    ,       p_Line_Payment_rec.program_update_date
    ,       p_Line_Payment_rec.receipt_method_id
    ,       p_Line_Payment_rec.request_id
    --,       p_Line_Payment_rec.tangible_id --R12 CC Encryption
    ,       p_Line_Payment_rec.defer_payment_processing_flag
    ,       p_Line_Payment_rec.trxn_extension_id
    ,       l_lock_control
    ,       p_Line_Payment_rec.ORIG_SYS_PAYMENT_REF  --5892425
    );

    p_Line_Payment_rec.lock_control :=   l_lock_control;

    --calling notification framework to update global picture
  --check code release level first. Notification framework is at Pack H level
   IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
/*      OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_old_lin_pmt_rec => NULL,
                    p_lin_pmt_rec =>p_line_Payment_rec,
                    p_lin_pmt_id => p_line_Payment_rec.payment_number,
                    x_index => l_index,
                    x_return_status => l_return_status); */
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_LINE_PAYMENT_UTIL.INSERT_ROW IS: ' || L_RETURN_STATUS ) ;
       END IF;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RETURNED INDEX IS: ' || L_INDEX , 1 ) ;
       END IF;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING OE_LINE_PAYMENT_UTIL.INSERT_ROW' , 1 ) ;
        END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_LINE_PAYMENT_UTIL.INSERT_ROW' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING OE_LINE_PAYMENT_UTIL.INSERT_ROW' , 1 ) ;
        END IF;
	RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF; /*code_release_level*/
 -- notification framework end

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_LINE_PAYMENT_UTIL.INSERT_ROW' , 1 ) ;
    END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_payment_number              IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_line_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header_id                   IN  NUMBER :=
                                        FND_API.G_MISS_NUM
)
IS
l_return_status		VARCHAR2(30);
p_payment_type_code     VARCHAR2(30) := NULL;
del_commitment number := 0;
l_msg_count number := 0;
l_msg_data varchar2(2000) := null;
--R12 CC Encryption
l_trxn_extension_id  NUMBER;
l_invoice_to_org_id  NUMBER;
l_payment_type_code VARCHAR2(80);
--R12 CC Encryption

CURSOR payment IS
	SELECT payment_number, payment_type_code,trxn_extension_id
	FROM OE_PAYMENTS
	WHERE   LINE_ID = p_line_id
        AND     HEADER_ID = p_header_id;
 -- added for notification framework
        l_new_line_Payment_rec     OE_Order_PUB.Line_Payment_Rec_Type;
        l_index           NUMBER;
        --
        l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
        --
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_LINE_PAYMENT_UTIL.DELETE_ROW' , 1 ) ;
  END IF;

  IF p_line_id <> FND_API.G_MISS_NUM AND
     nvl(p_payment_number, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
  THEN
    FOR l_pmt IN payment LOOP

    --added notification framework
   --check code release level first. Notification framework is at Pack H level
      IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
      /* Set the operation on the record so that globals are updated as well */
        l_new_line_Payment_rec.operation := OE_GLOBALS.G_OPR_DELETE;
        l_new_line_Payment_rec.payment_number := l_pmt.payment_number;
        --R12 CC Encryption
        l_payment_type_code := l_pmt.payment_type_code;
        l_trxn_extension_id := l_pmt.trxn_extension_id;
        --R12 CC Encryption
        if l_pmt.payment_type_code = 'COMMITMENT' then
           del_commitment := 1;
        end if;

	--R12 CC Encryption
	--Calling delete API of Oracle Payments only if the payment
	--type is credit card ach or direct debit.
	IF l_payment_type_code in ('CREDIT_CARD','ACH','DIRECT_DEBIT') THEN
		select invoice_to_org_id into l_invoice_to_org_id  --Verify
		from oe_order_lines_all where
		header_id = p_header_id
		and line_id = p_line_id;
		IF l_debug_level  > 0 THEN
			oe_debug_pub.add('Deleting trxn id...'||l_trxn_extension_id);
			oe_debug_pub.add('Invoice to org.'||l_invoice_to_org_id);
		END IF;

		OE_PAYMENT_TRXN_UTIL.Delete_Payment_Trxn
		(p_header_id     => p_header_id,
		 p_line_id       => p_line_id,
		 p_payment_number=> l_pmt.payment_number,
		 P_site_use_id	 => l_invoice_to_org_id,
		 p_trxn_extension_id	=> l_trxn_extension_id,
		 x_return_status    =>l_return_status,
		 x_msg_count        => l_msg_count,
		 x_msg_data        => l_msg_data);

		    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			  IF l_debug_level  > 0 THEN
			      oe_debug_pub.add(  'Delete Payment at OE_LINE_Payment_UTIL.DELETE_ROW - UNEXPECTED ERROR' ) ;
			      oe_debug_pub.add('Error message'||sqlerrm);
			      oe_debug_pub.add('Msg data'||l_msg_data);
			  END IF;
			  IF l_debug_level  > 0 THEN
			      oe_debug_pub.add(  'EXITING OE_LINE_Payment_UTIL.DELETE_ROW' , 1 ) ;
			  END IF;
			  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
			  IF l_debug_level  > 0 THEN
			      oe_debug_pub.add(  'Delete Payment at OE_LINE_Payment_UTIL.DELETE_ROW' ) ;
			      oe_debug_pub.add('Error message'||sqlerrm);
			      oe_debug_pub.add('Msg data'||l_msg_data);
			  END IF;
			  IF l_debug_level  > 0 THEN
			      oe_debug_pub.add(  'EXITING OE_LINE_Payment_UTIL.DELETE_ROW' , 1 ) ;
			  END IF;
			  RAISE FND_API.G_EXC_ERROR;
		    END IF;
	END IF;
	--R12 CC Encryption


        /*OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_lin_pmt_rec =>l_new_line_Payment_rec,
                    p_lin_pmt_id => l_pmt.payment_number,
                    x_index => l_index,
                    x_return_status => l_return_status);
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_LINE_PAYMENT_UTIL.DELETE_ROW IS: ' || L_RETURN_STATUS ) ;
         END IF;
         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
           END IF;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'EXITING OE_LINE_PAYMENT_UTIL.DELETE_ROW' , 1 ) ;
           END IF;
 	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_LINE_PAYMENT_UTIL.DELETE_ROW' ) ;
           END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'EXITING OE_LINE_PAYMENT_UTIL.DELETE_ROW' , 1 ) ;
            END IF;
	    RAISE FND_API.G_EXC_ERROR;
         END IF;*/
       END IF; /*code_release_level*/
     -- notification framework end

    END LOOP;


      OE_Delayed_Requests_Pvt.Delete_Reqs_for_deleted_entity(
        p_entity_code  => OE_GLOBALS.G_ENTITY_LINE_PAYMENT,
        p_entity_id     => p_line_id,
        x_return_status => l_return_status
        );
    DELETE  FROM OE_PAYMENTS
    WHERE   LINE_ID = p_line_id
    AND     HEADER_ID = p_header_id;

--3382262
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('1: after executing delete statement against oe_payments - before delete_payment_at_line');
    END IF;


    Delete_Payment_at_line(p_line_id => p_line_id,
                           p_del_commitment => del_commitment,
                           x_return_status => l_return_status,
                           x_msg_count => l_msg_count,
                           x_msg_data => l_msg_data);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'Delete Payment at Line - UNEXPECTED ERROR' ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EXITING OE_LINE_Payment_UTIL.DELETE_ROW' , 1 ) ;
          END IF;
    	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'Delete Payment at Line - OE_LINE_Payment_UTIL.DELETE_ROW' ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EXITING OE_LINE_Payment_UTIL.DELETE_ROW' , 1 ) ;
          END IF;
	  RAISE FND_API.G_EXC_ERROR;
    END IF;
--3382262

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'Releasing line level authorization hold.' , 3 ) ;
    END IF;
    OE_Verify_Payment_PUB.Release_Verify_Line_Hold
                                 ( p_header_id     => p_header_id
                                 , p_line_id       => p_line_id
                                 , p_epayment_hold => 'Y'
                                 , p_msg_count     => l_msg_count
                                 , p_msg_data      => l_msg_data
                                 , p_return_status => l_return_status
                                 );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

  ELSIF p_line_id <> FND_API.G_MISS_NUM AND
        p_payment_number <> FND_API.G_MISS_NUM THEN
     --added notification framework
   --check code release level first. Notification framework is at Pack H level
     IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
      /* Set the operation on the record so that globals are updated as well */
        l_new_line_Payment_rec.operation := OE_GLOBALS.G_OPR_DELETE;
        l_new_line_Payment_rec.payment_number := p_payment_number;
        l_new_line_Payment_rec.line_id := p_line_id;
/*       OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_Lin_pmt_rec =>l_new_line_Payment_rec,
                    p_lin_pmt_id => p_payment_number,
                    x_index => l_index,
                    x_return_status => l_return_status); */
--ER#7479609 start
	Delete_Line_PaymentType_Hold
	(
	   p_header_id      => p_header_id
	,  p_line_id   	     => p_line_id
	,  p_payment_number  => p_payment_number
	,  x_msg_count        => l_msg_count
	,  x_msg_data        => l_msg_data
	,  x_return_status   => l_return_status
	);
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
--ER#7479609 end

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_LINE_PAYMENT_UTIL.DELETE_ROW IS: ' || L_RETURN_STATUS ) ;
       END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EXITING OE_LINE_PAYMENT_UTIL.DELETE_ROW' , 1 ) ;
          END IF;
    	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_LINE_PAYMENT_UTIL.DELETE_ROW' ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EXITING OE_LINE_PAYMENT_UTIL.DELETE_ROW' , 1 ) ;
          END IF;
	  RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF; /*code_release_level*/
    -- notification framework end

     OE_Delayed_Requests_Pvt.Delete_Reqs_for_deleted_entity(
        p_entity_code  => OE_GLOBALS.G_ENTITY_LINE_Payment,
        p_entity_id     => p_line_id,
        x_return_status => l_return_status
        );

    Begin
       select payment_type_code,trxn_extension_id into p_payment_type_code,l_trxn_extension_id
       from oe_payments
       where payment_number = p_payment_number
       and line_id = p_line_id
       and header_id = p_header_id;

    Exception
       when no_data_found then

        Begin
          select payment_type_code,trxn_extension_id into p_payment_type_code,l_trxn_extension_id --R12 CC Encryption
          from oe_payments
          where line_id = p_line_id
          and payment_number is null
          and header_id = p_header_id;

        Exception
          when no_data_found then

           oe_debug_pub.add('ULPMB.pls: delete_row - could not find the row');
           Raise;
          when too_many_rows then
           oe_debug_pub.add('ULPMB.pls : delete row - too many rows - should not happen');
           Raise;
        End;

    END;

    if p_payment_type_code = 'COMMITMENT' then
       del_commitment := 1;
    end if;
    --R12 CC Encryption
    --Calling delete API of Oracle Payments only if the payment
    --type is credit card ach or direct debit.
    IF p_payment_type_code in ('CREDIT_CARD','ACH','DIRECT_DEBIT') THEN
	       select invoice_to_org_id into l_invoice_to_org_id
	       from oe_order_lines_all where header_id = p_header_id
	       and line_id = p_line_id;
		IF l_debug_level  > 0 THEN
			oe_debug_pub.add('Deleting trxn id...'||l_trxn_extension_id);
			oe_debug_pub.add('Invoice to org.'||l_invoice_to_org_id);
		END IF;

		OE_PAYMENT_TRXN_UTIL.Delete_Payment_Trxn
		(p_header_id     => p_header_id,
		 p_line_id       => p_line_id,
		 p_payment_number=> p_payment_number,
		 P_site_use_id	 => l_invoice_to_org_id,
		 p_trxn_extension_id	=> l_trxn_extension_id,
		 x_return_status    =>l_return_status,
		 x_msg_count        => l_msg_count,
		 x_msg_data        => l_msg_data);


	    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		  IF l_debug_level  > 0 THEN
		      oe_debug_pub.add(  '2:Delete Payment OE_LINE_Payment_UTIL.DELETE_ROW - UNEXPECTED ERROR' ) ;
		  END IF;
		  IF l_debug_level  > 0 THEN
		      oe_debug_pub.add(  'EXITING OE_LINE_Payment_UTIL.DELETE_ROW' , 1 ) ;
		  END IF;
		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		  IF l_debug_level  > 0 THEN
		      oe_debug_pub.add(  '2:Delete Payment OE_LINE_Payment_UTIL.DELETE_ROW' ) ;
		  END IF;
		  IF l_debug_level  > 0 THEN
		      oe_debug_pub.add(  'EXITING OE_LINE_Payment_UTIL.DELETE_ROW' , 1 ) ;
		  END IF;
		  RAISE FND_API.G_EXC_ERROR;
	    END IF;
    END IF;
    --R12 CC Encryption

    DELETE  FROM OE_PAYMENTS
    WHERE   PAYMENT_NUMBER = p_payment_number
    AND     LINE_ID = p_line_id
    AND     HEADER_ID = p_header_id
    ;

    --3382262
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('2: after executing delete statement against oe_payments - before delete_payment_at_line');
    END IF;


    Delete_Payment_at_line(p_line_id => p_line_id,
                           p_payment_number => p_payment_number,
                           p_payment_type_code => p_payment_type_code,
                           p_del_commitment => del_commitment,
                                   x_return_status => l_return_status,
                                   x_msg_count => l_msg_count,
                                   x_msg_data => l_msg_data);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'Delete Payment at Line - UNEXPECTED ERROR' ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EXITING OE_LINE_Payment_UTIL.DELETE_ROW' , 1 ) ;
          END IF;
    	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'Delete Payment at Line - OE_LINE_Payment_UTIL.DELETE_ROW' ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EXITING OE_LINE_Payment_UTIL.DELETE_ROW' , 1 ) ;
          END IF;
	  RAISE FND_API.G_EXC_ERROR;
    END IF;
--3382262

    IF p_payment_type_code = 'CREDIT_CARD' THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Releasing line level authorization hold.' , 3 ) ;
      END IF;
      OE_Verify_Payment_PUB.Release_Verify_Line_Hold
                                 ( p_header_id     => p_header_id
                                 , p_line_id       => p_line_id
                                 , p_epayment_hold => 'Y'
                                 , p_msg_count     => l_msg_count
                                 , p_msg_data      => l_msg_data
                                 , p_return_status => l_return_status
                                 );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

  END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

--  Procedure Query_Row
PROCEDURE Query_Row
(   p_payment_number               IN  NUMBER,
    p_line_id                      IN  NUMBER,
    p_header_id                    IN  NUMBER :=
                                        FND_API.G_MISS_NUM,
   x_Line_Payment_rec  IN OUT NOCOPY OE_Order_PUB.Line_Payment_Rec_Type
)
IS
x_Line_Payment_tbl OE_Order_PUB.Line_Payment_Tbl_Type;
CURSOR l_Line_Payment_csr IS
    SELECT  ATTRIBUTE1
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       CHECK_NUMBER  --R12 CC Encryption Verify
    ,       CREDIT_CARD_APPROVAL_CODE
    ,       CREDIT_CARD_APPROVAL_DATE
    ,       CREDIT_CARD_CODE
    ,       CREDIT_CARD_EXPIRATION_DATE
    ,       CREDIT_CARD_HOLDER_NAME
    ,       CREDIT_CARD_NUMBER --R12 CC Encryption Verify
    ,       PAYMENT_LEVEL_CODE
    ,       COMMITMENT_APPLIED_AMOUNT
    ,       COMMITMENT_INTERFACED_AMOUNT
    ,       HEADER_ID
    ,       LINE_ID
    ,       PAYMENT_AMOUNT
    ,       PAYMENT_COLLECTION_EVENT
    ,       PAYMENT_TRX_ID
    ,       PAYMENT_TYPE_CODE
    ,       PAYMENT_SET_ID
    ,       PREPAID_AMOUNT
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       RECEIPT_METHOD_ID
    ,       REQUEST_ID
    ,       TANGIBLE_ID --R12 CC Encryption Verify
    ,       LOCK_CONTROL
    ,       PAYMENT_NUMBER
    ,       DEFER_PAYMENT_PROCESSING_FLAG
    ,       TRXN_EXTENSION_ID
    FROM    OE_PAYMENTS
    WHERE ( PAYMENT_NUMBER = p_payment_number
    AND LINE_ID = p_line_id
    AND HEADER_ID = p_header_id
    );

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
--R12 CC Encryption Verify
x_bank_account_number VARCHAR2(100); --bug 5170754
x_check_number        varchar2(100);
l_return_status      VARCHAR2(30) := NULL ;
l_msg_count          NUMBER := 0 ;
l_msg_data           VARCHAR2(2000) := NULL ;

--R12 CC Encryption

BEGIN
    --  Loop over fetched records

    FOR l_implicit_rec IN l_Line_Payment_csr LOOP

        x_Line_Payment_rec.attribute1 := l_implicit_rec.ATTRIBUTE1;
        x_Line_Payment_rec.attribute2 := l_implicit_rec.ATTRIBUTE2;
        x_Line_Payment_rec.attribute3 := l_implicit_rec.ATTRIBUTE3;
        x_Line_Payment_rec.attribute4 := l_implicit_rec.ATTRIBUTE4;
        x_Line_Payment_rec.attribute5 := l_implicit_rec.ATTRIBUTE5;
        x_Line_Payment_rec.attribute6 := l_implicit_rec.ATTRIBUTE6;
        x_Line_Payment_rec.attribute7 := l_implicit_rec.ATTRIBUTE7;
        x_Line_Payment_rec.attribute8 := l_implicit_rec.ATTRIBUTE8;
        x_Line_Payment_rec.attribute9 := l_implicit_rec.ATTRIBUTE9;
        x_Line_Payment_rec.attribute10 := l_implicit_rec.ATTRIBUTE10;
        x_Line_Payment_rec.attribute11 := l_implicit_rec.ATTRIBUTE11;
        x_Line_Payment_rec.attribute12 := l_implicit_rec.ATTRIBUTE12;
        x_Line_Payment_rec.attribute13 := l_implicit_rec.ATTRIBUTE13;
        x_Line_Payment_rec.attribute14 := l_implicit_rec.ATTRIBUTE14;
        x_Line_Payment_rec.attribute15 := l_implicit_rec.ATTRIBUTE15;
        x_Line_Payment_rec.context   := l_implicit_rec.CONTEXT;
        x_Line_Payment_rec.created_by := l_implicit_rec.CREATED_BY;
        x_Line_Payment_rec.creation_date := l_implicit_rec.CREATION_DATE;
        x_Line_Payment_rec.last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        x_Line_Payment_rec.last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        x_Line_Payment_rec.last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
	--R12 CC Encryption Verify
        x_Line_Payment_rec.check_number := l_implicit_rec.CHECK_NUMBER;
        x_Line_Payment_rec.credit_card_approval_code := l_implicit_rec.CREDIT_CARD_APPROVAL_CODE;
        x_Line_Payment_rec.credit_card_approval_date := l_implicit_rec.CREDIT_CARD_APPROVAL_DATE;
        x_Line_Payment_rec.credit_card_code := l_implicit_rec.CREDIT_CARD_CODE;
        x_Line_Payment_rec.credit_card_expiration_date := l_implicit_rec.CREDIT_CARD_EXPIRATION_DATE;
        x_Line_Payment_rec.credit_card_holder_name := l_implicit_rec.CREDIT_CARD_HOLDER_NAME;
        x_Line_Payment_rec.credit_card_number := l_implicit_rec.CREDIT_CARD_NUMBER;
	--R12 CC Encryption Verify
        x_Line_Payment_rec.payment_level_code := l_implicit_rec.PAYMENT_LEVEL_CODE;
        x_Line_Payment_rec.commitment_applied_amount := l_implicit_rec.COMMITMENT_APPLIED_AMOUNT;
        x_Line_Payment_rec.commitment_interfaced_amount := l_implicit_rec.COMMITMENT_INTERFACED_AMOUNT;
        x_Line_Payment_rec.header_id := l_implicit_rec.HEADER_ID;
        x_Line_Payment_rec.line_id   := l_implicit_rec.LINE_ID;
        x_Line_Payment_rec.payment_amount := l_implicit_rec.PAYMENT_AMOUNT;
        x_Line_Payment_rec.payment_collection_event := l_implicit_rec.PAYMENT_COLLECTION_EVENT;
        x_Line_Payment_rec.payment_trx_id := l_implicit_rec.PAYMENT_TRX_ID;
        x_Line_Payment_rec.payment_type_code := l_implicit_rec.PAYMENT_TYPE_CODE;
        x_Line_Payment_rec.payment_set_id := l_implicit_rec.PAYMENT_SET_ID;
        x_Line_Payment_rec.prepaid_amount := l_implicit_rec.PREPAID_AMOUNT;
        x_Line_Payment_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        x_Line_Payment_rec.program_id := l_implicit_rec.PROGRAM_ID;
        x_Line_Payment_rec.program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        x_Line_Payment_rec.receipt_method_id := l_implicit_rec.RECEIPT_METHOD_ID;
        x_Line_Payment_rec.request_id := l_implicit_rec.REQUEST_ID;
        x_Line_Payment_rec.tangible_id := l_implicit_rec.TANGIBLE_ID; --R12 CC Encryption Verify
        x_Line_Payment_rec.lock_control   := l_implicit_rec.LOCK_CONTROL;
        x_Line_Payment_rec.payment_number   := l_implicit_rec.PAYMENT_NUMBER;
        x_Line_Payment_rec.defer_payment_processing_flag := l_implicit_rec.defer_payment_processing_flag;
	--R12 CC Encryption
	x_Line_Payment_rec.trxn_extension_id := l_implicit_rec.trxn_extension_id;
	--Populating the header payment record by querying the Payments tables
	--as they are no longer stored in OM tables
	IF l_implicit_rec.trxn_extension_id is not null then
		OE_Payment_Trxn_Util.Get_Payment_Trxn_Info(p_header_id => p_header_id,
		 P_trxn_extension_id => x_Line_Payment_rec.trxn_extension_id,
		 P_payment_type_code => x_Line_Payment_rec.payment_type_code ,
		 X_credit_card_number => x_Line_Payment_rec.credit_card_number,
		 X_credit_card_holder_name => x_Line_Payment_rec.credit_card_holder_name,
		 X_credit_card_expiration_date => x_Line_Payment_rec.credit_card_expiration_date,
		 X_credit_card_code => x_Line_Payment_rec.credit_card_code,
		 X_credit_card_approval_code => x_Line_Payment_rec.credit_card_approval_code,
		 X_credit_card_approval_date => x_Line_Payment_rec.credit_card_approval_date,
		 X_bank_account_number => X_bank_account_number,
		 --X_check_number => X_check_number	,
		 X_instrument_security_code => x_Line_Payment_rec.instrument_security_code,
		 X_instrument_id => x_Line_Payment_rec.cc_instrument_id,
		 X_instrument_assignment_id => x_Line_Payment_rec.cc_instrument_assignment_id,
		 X_return_status => l_return_status,
		 X_msg_count => l_msg_count,
		 X_msg_data => l_msg_data);
	END IF;
	--R12 CC Encryption
        x_Line_Payment_tbl(x_Line_Payment_tbl.COUNT + 1) := x_Line_Payment_rec;

    END LOOP;

    --  Return fetched table

        x_Line_Payment_rec := x_Line_Payment_tbl(1);

    --  PK sent and no rows found

    IF
    (p_payment_number IS NOT NULL
     AND
     p_payment_number <> FND_API.G_MISS_NUM)
    AND
    (p_line_id IS NOT NULL
     AND
     p_line_id <> FND_API.G_MISS_NUM)
    AND
    (x_Line_Payment_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Row;



--  Procedure Query_Rows

--

Procedure Query_Rows
(   p_payment_number               IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_line_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header_id                   IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,  x_line_Payment_tbl   IN OUT NOCOPY OE_Order_PUB.Line_Payment_Tbl_Type
)
IS
l_Line_Payment_rec          OE_Order_PUB.Line_Payment_Rec_Type;

CURSOR l_Line_Payment_csr IS
    SELECT  ATTRIBUTE1
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       CHECK_NUMBER  --R12 CC Encryption Verify
    ,       CREDIT_CARD_APPROVAL_CODE
    ,       CREDIT_CARD_APPROVAL_DATE
    ,       CREDIT_CARD_CODE
    ,       CREDIT_CARD_EXPIRATION_DATE
    ,       CREDIT_CARD_HOLDER_NAME
    ,       CREDIT_CARD_NUMBER --R12 CC Encryption Verify
    ,       PAYMENT_LEVEL_CODE
    ,       COMMITMENT_APPLIED_AMOUNT
    ,       COMMITMENT_INTERFACED_AMOUNT
    ,       HEADER_ID
    ,       LINE_ID
    ,       PAYMENT_AMOUNT
    ,       PAYMENT_COLLECTION_EVENT
    ,       PAYMENT_TRX_ID
    ,       PAYMENT_TYPE_CODE
    ,       PAYMENT_SET_ID
    ,       PREPAID_AMOUNT
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       RECEIPT_METHOD_ID
    ,       REQUEST_ID
    ,       TANGIBLE_ID --R12 CC Encryption Verify
    ,       LOCK_CONTROL
    ,       PAYMENT_NUMBER
    ,       DEFER_PAYMENT_PROCESSING_FLAG
    ,       TRXN_EXTENSION_ID
    FROM    OE_PAYMENTS
    WHERE   LINE_ID = p_line_id
    AND     HEADER_ID = p_header_id
	;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
--R12 CC Encryption Verify
x_bank_account_number VARCHAR2(100); --bug 5170754
x_check_number        varchar2(100);
l_return_status      VARCHAR2(30) := NULL ;
l_msg_count          NUMBER := 0 ;
l_msg_data           VARCHAR2(2000) := NULL ;

--R12 CC Encryption

BEGIN

    --  Loop over fetched records

    FOR l_implicit_rec IN l_Line_Payment_csr LOOP

        l_Line_Payment_rec.attribute1 := l_implicit_rec.ATTRIBUTE1;
        l_Line_Payment_rec.attribute2 := l_implicit_rec.ATTRIBUTE2;
        l_Line_Payment_rec.attribute3 := l_implicit_rec.ATTRIBUTE3;
        l_Line_Payment_rec.attribute4 := l_implicit_rec.ATTRIBUTE4;
        l_Line_Payment_rec.attribute5 := l_implicit_rec.ATTRIBUTE5;
        l_Line_Payment_rec.attribute6 := l_implicit_rec.ATTRIBUTE6;
        l_Line_Payment_rec.attribute7 := l_implicit_rec.ATTRIBUTE7;
        l_Line_Payment_rec.attribute8 := l_implicit_rec.ATTRIBUTE8;
        l_Line_Payment_rec.attribute9 := l_implicit_rec.ATTRIBUTE9;
        l_Line_Payment_rec.attribute10 := l_implicit_rec.ATTRIBUTE10;
        l_Line_Payment_rec.attribute11 := l_implicit_rec.ATTRIBUTE11;
        l_Line_Payment_rec.attribute12 := l_implicit_rec.ATTRIBUTE12;
        l_Line_Payment_rec.attribute13 := l_implicit_rec.ATTRIBUTE13;
        l_Line_Payment_rec.attribute14 := l_implicit_rec.ATTRIBUTE14;
        l_Line_Payment_rec.attribute15 := l_implicit_rec.ATTRIBUTE15;
        l_Line_Payment_rec.context   := l_implicit_rec.CONTEXT;
        l_Line_Payment_rec.created_by := l_implicit_rec.CREATED_BY;
        l_Line_Payment_rec.creation_date := l_implicit_rec.CREATION_DATE;
        l_Line_Payment_rec.last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        l_Line_Payment_rec.last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        l_Line_Payment_rec.last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_Line_Payment_rec.check_number := l_implicit_rec.CHECK_NUMBER; --R12 CC Encryption Verify
        l_Line_Payment_rec.credit_card_approval_code := l_implicit_rec.CREDIT_CARD_APPROVAL_CODE;
        l_Line_Payment_rec.credit_card_approval_date := l_implicit_rec.CREDIT_CARD_APPROVAL_DATE;
        l_Line_Payment_rec.credit_card_code := l_implicit_rec.CREDIT_CARD_CODE;
        l_Line_Payment_rec.credit_card_expiration_date := l_implicit_rec.CREDIT_CARD_EXPIRATION_DATE;
        l_Line_Payment_rec.credit_card_holder_name := l_implicit_rec.CREDIT_CARD_HOLDER_NAME;
        l_Line_Payment_rec.credit_card_number := l_implicit_rec.CREDIT_CARD_NUMBER; --R12 CC Encryption Verify
        l_Line_Payment_rec.payment_level_code := l_implicit_rec.PAYMENT_LEVEL_CODE;
        l_Line_Payment_rec.commitment_applied_amount := l_implicit_rec.COMMITMENT_APPLIED_AMOUNT;
        l_Line_Payment_rec.commitment_interfaced_amount := l_implicit_rec.COMMITMENT_INTERFACED_AMOUNT;
        l_Line_Payment_rec.header_id := l_implicit_rec.HEADER_ID;
        l_Line_Payment_rec.line_id   := l_implicit_rec.LINE_ID;
        l_Line_Payment_rec.payment_amount := l_implicit_rec.PAYMENT_AMOUNT;
        l_Line_Payment_rec.payment_collection_event := l_implicit_rec.PAYMENT_COLLECTION_EVENT;
        l_Line_Payment_rec.payment_trx_id := l_implicit_rec.PAYMENT_TRX_ID;
        l_Line_Payment_rec.payment_type_code := l_implicit_rec.PAYMENT_TYPE_CODE;
        l_Line_Payment_rec.payment_set_id := l_implicit_rec.PAYMENT_SET_ID;
        l_Line_Payment_rec.prepaid_amount := l_implicit_rec.PREPAID_AMOUNT;
        l_Line_Payment_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_Line_Payment_rec.program_id := l_implicit_rec.PROGRAM_ID;
        l_Line_Payment_rec.program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_Line_Payment_rec.receipt_method_id := l_implicit_rec.RECEIPT_METHOD_ID;
        l_Line_Payment_rec.request_id := l_implicit_rec.REQUEST_ID;
        l_Line_Payment_rec.tangible_id := l_implicit_rec.TANGIBLE_ID; --R12 CC Encryption Verify
        l_Line_Payment_rec.lock_control   := l_implicit_rec.LOCK_CONTROL;
        l_Line_Payment_rec.payment_number   := l_implicit_rec.PAYMENT_NUMBER;
        l_Line_Payment_rec.defer_payment_processing_flag := l_implicit_rec.DEFER_PAYMENT_PROCESSING_FLAG;
	--R12 CC Encryption
	l_Line_Payment_rec.trxn_extension_id := l_implicit_rec.trxn_extension_id;
	--Populating the header payment record by querying the Payments tables
	--as they are no longer stored in OM tables
	IF l_implicit_rec.trxn_extension_id is not null then
		OE_Payment_Trxn_Util.Get_Payment_Trxn_Info(p_header_id => p_header_id,
		 P_trxn_extension_id => l_Line_Payment_rec.trxn_extension_id,
		 P_payment_type_code => l_Line_Payment_rec.payment_type_code ,
		 X_credit_card_number => l_Line_Payment_rec.credit_card_number,
		 X_credit_card_holder_name => l_Line_Payment_rec.credit_card_holder_name,
		 X_credit_card_expiration_date => l_Line_Payment_rec.credit_card_expiration_date,
		 X_credit_card_code => l_Line_Payment_rec.credit_card_code,
		 X_credit_card_approval_code => l_Line_Payment_rec.credit_card_approval_code,
		 X_credit_card_approval_date => l_Line_Payment_rec.credit_card_approval_date,
		 X_bank_account_number => X_bank_account_number,
		 --X_check_number => X_check_number	,
		 X_instrument_id => l_Line_Payment_rec.cc_instrument_id,
		 X_instrument_assignment_id => l_Line_Payment_rec.cc_instrument_assignment_id,
		 X_instrument_security_code => l_Line_Payment_rec.instrument_security_code,
		 X_return_status => l_return_status,
		 X_msg_count => l_msg_count,
		 X_msg_data => l_msg_data);
	END IF;
	--R12 CC Encryption
        x_Line_Payment_tbl(x_Line_Payment_tbl.COUNT + 1) := l_Line_Payment_rec;

    END LOOP;

    --  Return fetched table


EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Rows'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Rows;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_x_Line_Payment_rec IN OUT NOCOPY  OE_Order_PUB.Line_Payment_Rec_Type
,   p_payment_number               IN  NUMBER
                                        := FND_API.G_MISS_NUM
,   p_line_id                      IN  NUMBER
                                        := FND_API.G_MISS_NUM
)
IS
l_payment_number	      NUMBER;
l_line_id       	      NUMBER;
l_header_id       	      NUMBER;
l_Line_Payment_rec          OE_Order_PUB.Line_Payment_Rec_Type;
l_lock_control                NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_LINE_PAYMENT_UTIL.LOCK_ROW' , 1 ) ;
    END IF;

    SAVEPOINT Lock_Row;

    l_lock_control := NULL;

    l_header_id := p_x_line_Payment_rec.header_id;
    -- Retrieve the primary key.
    IF p_payment_number <> FND_API.G_MISS_NUM AND
       p_line_id <> FND_API.G_MISS_NUM THEN
        l_payment_number := p_payment_number;
        l_line_id := p_line_id;
    ELSE
        l_payment_number := p_x_line_Payment_rec.payment_number;
        l_line_id := p_x_line_Payment_rec.line_id;
        l_lock_control    := p_x_line_Payment_rec.lock_control;
    END IF;

   SELECT  payment_number
    INTO   l_payment_number
    FROM   oe_payments
    WHERE  payment_number = l_payment_number
    AND    line_id = l_line_id
    AND    header_id = l_header_id
    FOR UPDATE NOWAIT;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SELECTED FOR UPDATE' , 1 ) ;
    END IF;

    OE_Line_Payment_Util.Query_Row
	(p_payment_number    => l_payment_number
	,p_line_id           => l_line_id
        ,p_header_id	     => l_header_id
	,x_line_Payment_rec => p_x_line_Payment_rec );


    -- If lock_control is null / missing, then return the locked record.

    IF l_lock_control is null OR
       l_lock_control <> FND_API.G_MISS_NUM THEN

        --  Set return status
        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        p_x_line_Payment_rec.return_status       := FND_API.G_RET_STS_SUCCESS;

        RETURN;

    END IF;

    --  Row locked. If the whole record is passed, then
    --  Compare IN attributes to DB attributes.

    IF  OE_GLOBALS.Equal(p_x_Line_Payment_rec.lock_control,
                         l_lock_control)
    THEN

        --  Row has not changed. Set out parameter.

        p_x_Line_Payment_rec           := l_Line_Payment_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        p_x_Line_Payment_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_Line_Payment_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            -- Release the lock
	    ROLLBACK TO Lock_Row;

            FND_MESSAGE.SET_NAME('ONT','OE_LOCK_ROW_CHANGED');
            oe_msg_pub.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_Line_Payment_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_LOCK_ROW_DELETED');
            oe_msg_pub.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_Line_Payment_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_LOCK_ROW_ALREADY_LOCKED');
            oe_msg_pub.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        p_x_Line_Payment_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;

PROCEDURE Lock_Rows
(   p_payment_number       IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_line_id              IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header_id            IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_line_Payment_tbl     OUT NOCOPY OE_Order_PUB.line_Payment_Tbl_Type
,   x_return_status        OUT NOCOPY VARCHAR2
 )
IS
  CURSOR lock_lin_Payments(p_line_id  NUMBER) IS
  SELECT payment_number
  FROM   oe_payments
  WHERE  line_id = p_line_id
  AND    header_id = p_header_id
    FOR UPDATE NOWAIT;

  l_payment_number    NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_HEADER_PaymentS_UTIL.LOCK_ROWS' , 1 ) ;
    END IF;
/*
    IF (p_payment_number IS NOT NULL AND
        p_payment_number <> FND_API.G_MISS_NUM) AND
       (p_line_id IS NOT NULL AND
        p_line_id <> FND_API.G_MISS_NUM)
    THEN
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
          , 'Lock Rows'
          , 'Keys are mutually exclusive: payment_number = '||
             p_payment_number || ', line_id = '|| p_line_id );
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
*/
   IF p_payment_number <> FND_API.G_MISS_NUM AND
      p_line_id <> FND_API.G_MISS_NUM THEN

     SELECT payment_number
     INTO   l_payment_number
     FROM   OE_PAYMENTS
     WHERE  payment_number   = p_payment_number
     AND    line_id = p_line_id
     AND    header_id = p_header_id
     FOR UPDATE NOWAIT;

   ELSE

   BEGIN

     IF p_line_id <> FND_API.G_MISS_NUM THEN

       SAVEPOINT LOCK_ROWS;
       OPEN lock_lin_Payments(p_line_id);

       LOOP
         FETCH lock_lin_Payments INTO l_payment_number;
         EXIT WHEN lock_lin_Payments%NOTFOUND;
       END LOOP;

       CLOSE lock_lin_Payments;

     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK TO LOCK_ROWS;

       IF lock_lin_Payments%ISOPEN THEN
         CLOSE lock_lin_Payments;
       END IF;

       RAISE;
   END;

   END IF;
   -- locked all

   OE_Line_Payment_Util.Query_Rows
     (p_payment_number         => p_payment_number
     ,p_line_id                => p_line_id
     ,p_header_id              => p_header_id
     ,x_line_Payment_tbl       => x_line_Payment_tbl
     );

   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING OE_LINE_PAYMENTS_UTIL.LOCK_ROWS' , 1 ) ;
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN

     x_return_status                := FND_API.G_RET_STS_ERROR;

     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
     THEN
       fnd_message.set_name('ONT','OE_LOCK_ROW_DELETED');
       OE_MSG_PUB.Add;
     END IF;

    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

      x_return_status                := FND_API.G_RET_STS_ERROR;
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
        fnd_message.set_name('ONT','OE_LOCK_ROW_ALREADY_LOCKED');
        OE_MSG_PUB.Add;
      END IF;

    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
         ,   'Lock_Rows'
        );
      END IF;

END Lock_Rows;


--  Function Get_Values

FUNCTION Get_Values
(   p_Line_Payment_rec          IN        OE_Order_PUB.Line_Payment_Rec_Type
,   p_old_Line_Payment_rec        IN  OE_Order_PUB.Line_Payment_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_REC
)RETURN OE_Order_PUB.Line_Payment_Val_Rec_Type
IS
l_Line_Payment_val_rec      OE_Order_PUB.Line_Payment_Val_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF (p_Line_Payment_rec.payment_collection_event IS NULL OR
        p_Line_Payment_rec.payment_collection_event <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_Line_Payment_rec.payment_collection_event,
        p_old_Line_Payment_rec.payment_collection_event)
    THEN
        l_Line_Payment_val_rec.payment_collection_event_name := OE_Id_To_Value.payment_collection_event_name
        (   p_payment_collection_event        => p_Line_Payment_rec.payment_collection_event
        );
    END IF;

    IF (p_Line_Payment_rec.receipt_method_id IS NULL OR
        p_Line_Payment_rec.receipt_method_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_Line_Payment_rec.receipt_method_id,
        p_old_Line_Payment_rec.receipt_method_id)
    THEN
        l_Line_Payment_val_rec.receipt_method := OE_Id_To_Value.Receipt_Method
        (   p_receipt_method                => p_Line_Payment_rec.receipt_method_id
        );
    END IF;

    IF (p_Line_Payment_rec.payment_type_code IS NULL OR
        p_Line_Payment_rec.payment_type_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_Line_Payment_rec.payment_type_code,
        p_old_Line_Payment_rec.payment_type_code)
    THEN
        l_Line_Payment_val_rec.payment_type := OE_Id_To_Value.payment_type
        (   p_payment_type_code => p_Line_Payment_rec.payment_type_code
        );
    END IF;

    RETURN l_Line_Payment_val_rec;

END Get_Values;

--  Procedure Get_Ids

PROCEDURE Get_Ids
(   p_x_Line_Payment_rec IN OUT NOCOPY  OE_Order_PUB.Line_Payment_Rec_Type
,   p_Line_Payment_val_rec        IN  OE_Order_PUB.Line_Payment_Val_Rec_Type
)
IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    --  initialize  return_status.

    p_x_Line_Payment_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_Line_Payment_rec.



    IF  p_Line_Payment_val_rec.payment_collection_event_name <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_Line_Payment_rec.payment_collection_event  <> FND_API.G_MISS_CHAR THEN

            IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','payment_collection_event_name');
                oe_msg_pub.Add;

            END IF;

        ELSE

            p_x_Line_Payment_rec.payment_collection_event := OE_Value_To_Id.payment_collection_event_name
            (   p_payment_collection_event     => p_Line_Payment_val_rec.payment_collection_event_name
            );

            IF p_x_Line_Payment_rec.payment_collection_event = FND_API.G_MISS_CHAR THEN
               p_x_Line_Payment_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Line_Payment_val_rec.payment_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_Line_Payment_rec.payment_type_code <> FND_API.G_MISS_CHAR THEN


            IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','payment_type');
                oe_msg_pub.Add;

            END IF;

        ELSE

            p_x_Line_Payment_rec.payment_type_code := OE_Value_To_Id.payment_type
            (   p_payment_type => p_Line_Payment_val_rec.payment_type
            );

            IF p_x_Line_Payment_rec.payment_type_code = FND_API.G_MISS_CHAR THEN
                p_x_Line_Payment_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    IF  p_Line_Payment_val_rec.receipt_method <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_Line_Payment_rec.receipt_method_id <> FND_API.G_MISS_NUM THEN


            IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Receipt_Method');
                oe_msg_pub.Add;

            END IF;

        ELSE

            p_x_Line_Payment_rec.receipt_method_id := OE_Value_To_Id.Receipt_Method
            (   p_receipt_method => p_Line_Payment_val_rec.receipt_method
            );

            IF p_x_Line_Payment_rec.receipt_method_id = FND_API.G_MISS_NUM THEN
                p_x_Line_Payment_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;



END Get_Ids;

PROCEDURE Pre_Write_Process
  ( p_x_line_Payment_rec IN OUT NOCOPY OE_ORDER_PUB.line_Payment_rec_type,
    p_old_line_Payment_rec IN OE_ORDER_PUB.line_Payment_rec_type := OE_ORDER_PUB.G_MISS_LINE_PAYMENT_REC )
    IS
l_return_status varchar2(30);
l_ordered_date DATE;
l_transactional_curr_code VARCHAR2(30);
l_invoice_to_org_id NUMBER;
l_bank_acct_id                 NUMBER;
l_bank_acct_uses_id            NUMBER;
l_hdr_inv_to_cust_id           NUMBER;
l_trx_date		       DATE;
--bug 3560198
l_currency_code         varchar2(30) := 'USD';
l_precision             NUMBER;
l_ext_precision         NUMBER;
l_min_acct_unit         NUMBER;
l_commitment_bal        NUMBER;
l_class                 VARCHAR2(30);
l_so_source_code        VARCHAR2(30);
l_oe_installed_flag     VARCHAR2(30);
-- QUOTING change
l_transaction_phase_code          VARCHAR2(30);
--
l_new_commitment_bal    NUMBER;
l_commitment            VARCHAR2(20);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
--R12 CC Encryption
l_order_source_doc_id NUMBER;
l_trxn_extension_id NUMBER;
l_msg_count	    NUMBER;
l_msg_data	    VARCHAR2(2000);
l_update_card_flag	       	VARCHAR2(1) := 'N';

-- bug 5204275
l_is_split_payment	VARCHAR2(1) := 'N';

BEGIN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add(  'entering oe_line_payment_util.Pre_Write_Process. payment_type_code'||p_x_line_Payment_rec.payment_type_code);
  END IF;


  --bug 3560198
  IF p_x_line_Payment_rec.payment_type_code = 'COMMITMENT' THEN
     IF l_debug_level > 0 THEN
        oe_debug_pub.add('To log commitment balance message');
     END IF;
     BEGIN
                 -- QUOTING change
        SELECT   l.transaction_phase_code
        INTO
                 l_transaction_phase_code
        FROM     oe_order_lines_all l
        WHERE    l.line_id = p_x_line_Payment_rec.line_id;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
                 RETURN;
     END;
     -- QUOTING change
     -- No need to calculate commitment for orders in negotiation phase
     if l_debug_level > 0 then
        oe_debug_pub.add('trxn phase :'||l_transaction_phase_code);
     end if;
     IF l_transaction_phase_code = 'N' THEN
        RETURN;
     END IF;
     -- build currency format.
     IF g_fmt_mask IS NULL THEN
       BEGIN
         SELECT nvl(transactional_curr_code,'USD')
         INTO   l_currency_code from oe_order_headers
         WHERE  header_id=p_x_line_Payment_rec.header_id;

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
           l_currency_code := 'USD';
       END ;

       FND_CURRENCY.Get_Info(l_currency_code,  -- IN variable
                   l_precision,
                   l_ext_precision,
                   l_min_acct_unit);

       FND_CURRENCY.Build_Format_Mask(G_Fmt_mask, 20, l_precision,
                                          l_min_acct_unit, TRUE
                                         );
     END IF;

     IF l_debug_level > 0 THEN
        oe_debug_pub.add('payment_trx_id : '||p_x_line_Payment_rec.payment_trx_id);
     END IF;
     IF p_x_line_Payment_rec.payment_trx_id IS NOT NULL THEN
        l_class := NULL;
        l_so_source_code := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
        l_oe_installed_flag := 'I';
        l_commitment_bal := ARP_BAL_UTIL.GET_COMMITMENT_BALANCE(
                             p_x_line_Payment_rec.payment_trx_id
                            ,l_class
                            ,l_so_source_code
                            ,l_oe_installed_flag );
     END IF;
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'COMMITMENT BALANCE IS: '||L_COMMITMENT_BAL ) ;
     END IF;
     IF p_x_line_Payment_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
        l_new_commitment_bal := l_commitment_bal - p_x_line_Payment_rec.commitment_applied_amount;
     ELSIF p_x_line_Payment_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
        l_new_commitment_bal := l_commitment_bal + p_old_line_Payment_rec.commitment_applied_amount - p_x_line_Payment_rec.commitment_applied_amount;
     END IF;
     IF l_debug_level > 0 THEN
        oe_debug_pub.add('l_new_commitment_bal : '||l_new_commitment_bal);
     END IF;
     -- Added if condition of the Bug #3742103
     IF l_new_commitment_bal IS NOT NULL THEN
        FND_MESSAGE.Set_Name('ONT','OE_COM_BALANCE');
        FND_MESSAGE.Set_Token('COMMITMENT',l_commitment);
        FND_Message.Set_Token('BALANCE',to_char(l_new_commitment_bal, g_fmt_mask));
        OE_MSG_PUB.ADD;
     END IF;
     -- End of Bug #3742103
  END IF;
  --bug 3560198

  --R12 CC Encryption
  --Querying the invoice to org id before checking the payment type
  --as it is needed for both credit card and check payments.
  Select INVOICE_TO_ORG_ID into l_invoice_to_org_id
  from oe_order_lines_all where header_id = p_x_line_Payment_rec.header_id
  and line_id = p_x_line_payment_rec.line_id;
  --Not taking it from the cache as the invoice to org id might change
  --in the line level as well.
  --  l_invoice_to_org_id := OE_Order_Cache.g_line_rec.invoice_to_org_id;


  BEGIN
    SELECT 'Y'
    INTO   l_is_split_payment
    FROM   oe_payments
    WHERE  header_id = p_x_line_Payment_rec.header_id
    AND    line_id = p_x_line_Payment_rec.line_id
    AND    payment_type_code IS NULL
    AND    credit_card_approval_code = 'CVV2_REQUIRED';
  EXCEPTION WHEN NO_DATA_FOUND THEN
    null;
  END;


  --For these payment type codes, the logic would be handled by calling
  --the appropriate Payments API to create, update or copy
  IF p_x_line_Payment_rec.payment_type_code IN
  ('CREDIT_CARD','ACH','DIRECT_DEBIT')
    OR (l_is_split_payment = 'Y' AND p_x_line_Payment_rec.payment_type_code IS NULL) THEN

	--Verify
       /** comment out this sql stmt to fetch these data from cache.
	select ordered_date, transactional_curr_code, invoice_to_org_id
	into l_ordered_date, l_transactional_curr_code, l_invoice_to_org_id
	from oe_order_headers
	where header_id=p_x_line_Payment_rec.header_id;
        **/

        oe_order_cache.load_order_header(p_x_line_Payment_rec.header_id);
        l_ordered_date := OE_Order_Cache.g_header_rec.ordered_date;
        l_transactional_curr_code := OE_Order_Cache.g_header_rec.transactional_curr_code;

	IF l_debug_level > 0 THEN
	   oe_debug_pub.add(  'l_transactional_curr_code:'||l_transactional_curr_code||':l_invoice_to_org_id:'||l_invoice_to_org_id);
	END IF;

	BEGIN
	   SELECT customer_id
	   INTO   l_hdr_inv_to_cust_id
	   FROM   oe_invoice_to_orgs_v
	   WHERE  organization_id = l_invoice_to_org_id;
	EXCEPTION
	    WHEN OTHERS THEN
	      IF l_debug_level  > 0 THEN
		 oe_debug_pub.add(  'IN OTHERS EXCEPTION ( OE_INVOICE_TO_ORGS_V ) '||SQLERRM , 1 ) ;
	      END IF;
	END;
       IF l_debug_level  > 0 THEN
	 oe_debug_pub.add('invoice to cust id : ' || l_hdr_inv_to_cust_id );
	 --oe_debug_pub.add('cc number : ' || p_x_line_Payment_rec.credit_card_number );
	 --oe_debug_pub.add('cc name : ' || p_x_line_Payment_rec.credit_card_holder_name );
	 --oe_debug_pub.add('exp date : ' || to_char(p_x_line_Payment_rec.credit_card_expiration_date, 'DD-MON-YYYY') );
	 oe_debug_pub.add('instr id...'||p_x_line_Payment_rec.cc_instrument_id);
	 oe_debug_pub.add('instr assgn id'||p_x_line_Payment_rec.cc_instrument_assignment_id);
       END IF;

	Select SOURCE_DOCUMENT_TYPE_ID
	Into l_order_source_doc_id
	From oe_order_lines_all
	Where line_id = p_x_line_payment_rec.line_id;

	-- To make sure this is coming from external caller,
	-- not from a copied order, need to check for source
	-- document type id, which is 2 for a copy order.
	IF p_x_line_payment_rec.trxn_extension_id IS NOT NULL
	AND (p_x_line_payment_rec.operation = OE_GLOBALS.G_OPR_CREATE)
	AND nvl(l_order_source_doc_id, -99) <> 2 THEN

            IF l_debug_level  > 0 THEN
		oe_debug_pub.add('Before calling copy payment trxn...');
	    END IF;

	    --For orders coming from outside of Order Management through Process Order API,
	    --we need to call Oracle Payments Copy Transaction API to get a new transaction
	    --extension id
	    BEGIN
		OE_PAYMENT_TRXN_UTIL.Copy_Payment_TRXN
		(P_header_id		=> p_x_line_Payment_rec.header_id,
		 P_line_id		=> p_x_line_payment_rec.line_id,
		 p_cust_id		=> l_hdr_inv_to_cust_id,
		 P_site_use_id		=> l_invoice_to_org_id,
		 p_trxn_extension_id	=> p_x_line_payment_rec.trxn_extension_id,
		 x_trxn_extension_id	=> l_trxn_extension_id,
		 X_return_status		=> l_return_status,
		 X_msg_count		=> l_msg_count,
		 X_msg_data		=> l_msg_data);

		 p_x_line_payment_rec.trxn_extension_id := l_trxn_extension_id;
	    EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			l_return_status := FND_API.G_RET_STS_ERROR;
			RAISE FND_API.G_EXC_ERROR;

		WHEN OTHERS THEN
			IF l_debug_level>0 THEN
				oe_debug_pub.add('After call to copy payment trxn - exception'||sqlerrm);
			END IF;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    END;
	ELSIF p_x_line_payment_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
		IF  p_x_line_payment_rec.trxn_extension_id IS NOT NULL
		AND p_x_line_payment_rec.trxn_extension_id <> FND_API.G_MISS_NUM
		AND ((p_x_line_Payment_rec.payment_type_code = 'CREDIT_CARD'
		AND OE_GLOBALS.Is_Same_Credit_Card(p_old_line_Payment_rec.credit_card_number,
                            p_x_line_Payment_rec.credit_card_number,
			    p_old_line_Payment_rec.cc_instrument_id,
			    p_x_line_Payment_rec.cc_instrument_id)
		AND  p_x_line_Payment_rec.credit_card_holder_name = p_old_line_Payment_rec.credit_card_holder_name
		AND  p_x_line_Payment_rec.credit_card_expiration_date = p_old_line_Payment_rec.credit_card_expiration_date
		AND p_x_line_Payment_rec.instrument_security_code = p_old_line_payment_rec.instrument_security_code)
		OR (p_x_line_Payment_rec.payment_type_code IN ('ACH','DIRECT_DEBIT')
		AND p_x_line_Payment_rec.payment_trx_id = p_old_line_Payment_rec.payment_trx_id)
		OR (p_x_line_Payment_rec.payment_type_code IN ('CASH','WIRE_TRANSFER')))
		THEN
			--<no operation is needed if payment information did not change>
			IF l_debug_level  > 0 THEN
				oe_debug_pub.add('No change to payments attributes...');
			END IF;
			NULL;
		--While changing the payment type from cash, check etc to
		--credit card payment type, the operation would be update but the
		--transaction extension id would be null.
		ELSIF p_x_line_payment_rec.trxn_extension_id IS NULL OR
		p_x_line_payment_rec.trxn_extension_id = FND_API.G_MISS_NUM THEN

			IF l_debug_level > 0 THEN
			   oe_debug_pub.add(  'Inside trxn extension id creation part....');
			   oe_debug_pub.add('  Operation is UPDATE and Trxn extension id is null...');
			   oe_debug_pub.add('  Creating a new trxn extension id ');
			END IF;


			/*l_trx_date := nvl(l_ordered_date, sysdate)
			    - nvl( to_number(fnd_profile.value('ONT_DAYS_TO_BACKDATE_BANK_ACCT')), 0);*/
			IF p_x_line_Payment_rec.payment_type_code = 'CREDIT_CARD'
                          -- 5204275
                          OR (l_is_split_payment = 'Y'
                              AND p_x_line_Payment_rec.payment_type_code IS NULL)
                        THEN
				IF OE_Payment_Trxn_Util.g_CC_Security_Code_Use  IS NULL THEN
					OE_Payment_Trxn_Util.g_CC_Security_Code_Use := OE_Payment_Trxn_Util.Get_CC_Security_Code_Use;
				END IF;

				IF OE_Payment_Trxn_Util.g_CC_Security_Code_Use  = 'REQUIRED' AND
				p_x_line_Payment_rec.instrument_security_code IS NULL THEN
					FND_MESSAGE.SET_NAME('ONT','OE_CC_SECURITY_CODE_REQD');
					OE_Msg_Pub.Add;
					RAISE FND_API.G_EXC_ERROR;
				END IF;
			END IF;

			IF NOT OE_GLOBALS.Is_Same_Credit_Card(p_old_line_Payment_rec.credit_card_number,
			    p_x_line_Payment_rec.credit_card_number,
			    p_old_line_Payment_rec.cc_instrument_id,
			    p_x_line_Payment_rec.cc_instrument_id)
			OR NOT OE_GLOBALS.Equal(p_x_line_Payment_rec.credit_card_code,
			p_old_line_Payment_rec.credit_card_code) THEN
				IF NOT OE_GLOBALS.Equal(p_x_line_Payment_rec.credit_card_holder_name,
				p_old_line_Payment_rec.credit_card_holder_name)
				OR NOT OE_GLOBALS.Equal(p_x_line_Payment_rec.credit_card_expiration_date,
				p_old_line_Payment_rec.credit_card_expiration_date)  THEN
					l_update_card_flag := 'Y';
				ELSE
					l_update_card_flag := 'N';
				END IF;
			ELSIF NOT OE_GLOBALS.Equal(p_x_line_Payment_rec.credit_card_holder_name,
			p_old_line_Payment_rec.credit_card_holder_name)
			OR NOT OE_GLOBALS.Equal(p_x_line_Payment_rec.credit_card_expiration_date,
			p_old_line_Payment_rec.credit_card_expiration_date)  THEN
				l_update_card_flag := 'Y';
			END IF;

			IF l_debug_level > 0 THEN
			   oe_debug_pub.add(  'Before calling create payment trxn....');
			   oe_debug_pub.add('Update card flag..'||l_update_card_flag);
			END IF;

        		BEGIN
				OE_PAYMENT_TRXN_UTIL.Create_Payment_TRXN
				(p_header_id		=> p_x_line_Payment_rec.header_id,
				 p_line_id		=> p_x_line_payment_rec.line_id,
				 p_cust_id		=> l_hdr_inv_to_cust_id,
				 P_site_use_id		=> l_invoice_to_org_id,
				 P_payment_trx_id	=> p_x_line_payment_rec.payment_trx_id,
				 p_payment_number	=> p_x_line_payment_rec.payment_number,
				 P_payment_type_code	=> p_x_line_payment_rec.payment_type_code,
				 P_card_number		=> p_x_line_payment_rec.credit_card_number,
				 p_card_code		=> p_x_line_payment_rec.credit_card_code,
				 P_card_holder_name	=> p_x_line_payment_rec.credit_card_holder_name,
				 P_exp_date		=> p_x_line_payment_rec.credit_card_expiration_date,
				 p_receipt_method_id	=> p_x_line_payment_rec.receipt_method_id,
				 p_instrument_security_code=>p_x_line_payment_rec.instrument_security_code,
				 p_update_card_flag	=> l_update_card_flag,
				 p_instrument_id	=> p_x_line_payment_rec.cc_instrument_id,
				 p_instrument_assignment_id => p_x_line_payment_rec.cc_instrument_assignment_id,
				 p_x_trxn_extension_id	=> p_x_line_payment_rec.trxn_extension_id,
				 X_return_status	=> l_return_status,
				 X_msg_count		=> l_msg_count,
				 X_msg_data		=> l_msg_data);

				 --p_x_line_payment_rec.trxn_extension_id := l_trxn_extension_id;
				 IF l_debug_level>0 THEN
					 oe_debug_pub.add('New trxn extension id after calling Create_Payment_TRXN:'||l_trxn_extension_id);
				 END IF;
			  EXCEPTION
				  WHEN FND_API.G_EXC_ERROR THEN
					OE_MSG_PUB.Count_And_Get
					    ( p_count => l_msg_count,
					      p_data  => l_msg_data
					    );
					l_return_status := FND_API.G_RET_STS_ERROR;
					RAISE FND_API.G_EXC_ERROR;

				  WHEN OTHERS THEN
					     OE_MSG_PUB.Count_And_Get
					     ( p_count => l_msg_count,
					       p_data  => l_msg_data
					     );
					      FND_MESSAGE.SET_NAME('ONT','OE_VPM_CC_ACCT_NOT_SET');
					      OE_MSG_PUB.ADD;
					      IF l_debug_level  > 0 THEN
						 oe_debug_pub.add(  'OEXUHPMB: ERROR IN CREATE PAYMENT trxn...'||sqlerrm) ;
						 oe_debug_pub.add('Error messsge ksurendr'||l_return_status);
					      END IF;
					      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			   END;
		--Trxn extension id exists and an update to some of the
		--attributes of the payment transaction has occured. So
		--need to call Update_Payment_Trxn API.
		ELSE
			BEGIN

				-- validate cc security code
				/*IF p_x_line_Payment_rec.payment_type_code = 'CREDIT_CARD' THEN
					IF OE_Payment_Trxn_Util.g_CC_Security_Code_Use  IS NULL THEN
						OE_Payment_Trxn_Util.g_CC_Security_Code_Use := OE_Payment_Trxn_Util.Get_CC_Security_Code_Use;
					END IF;
					IF OE_Payment_Trxn_Util.g_CC_Security_Code_Use  = 'REQUIRED'
					AND p_x_line_Payment_rec.instrument_security_code IS NULL THEN
						FND_MESSAGE.SET_NAME('ONT','OE_CC_SECURITY_CODE_REQD');
						OE_Msg_Pub.Add;
						RAISE FND_API.G_EXC_ERROR;
					END IF;
				END IF;*/
				IF l_debug_level  > 0 THEN
					oe_debug_pub.add('Verifying whether to call update card API...');
				END IF;

				--R12 CC Encryption
				--Since the credit card numbers are encrypted, passing both the credit card
				--numbers as well as instrument ids to determine if both the old and new
				--values point to the same credit card number.
				IF NOT OE_GLOBALS.Is_Same_Credit_Card(p_old_line_Payment_rec.credit_card_number,
				    p_x_line_Payment_rec.credit_card_number,
				    p_old_line_Payment_rec.cc_instrument_id,
				    p_x_line_Payment_rec.cc_instrument_id)
				OR NOT OE_GLOBALS.Equal(p_x_line_Payment_rec.credit_card_code,
				p_old_line_Payment_rec.credit_card_code) THEN
					IF NOT OE_GLOBALS.Equal(p_x_line_Payment_rec.credit_card_holder_name,
					p_old_line_Payment_rec.credit_card_holder_name)
					OR NOT OE_GLOBALS.Equal(p_x_line_Payment_rec.credit_card_expiration_date,
					p_old_line_Payment_rec.credit_card_expiration_date)  THEN
						l_update_card_flag := 'Y';
					ELSE
						l_update_card_flag := 'N';
					END IF;
				ELSIF NOT OE_GLOBALS.Equal(p_x_line_Payment_rec.credit_card_holder_name,
				p_old_line_Payment_rec.credit_card_holder_name)
				OR NOT OE_GLOBALS.Equal(p_x_line_Payment_rec.credit_card_expiration_date,
				p_old_line_Payment_rec.credit_card_expiration_date)  THEN
					l_update_card_flag := 'Y';
				END IF;
				IF l_debug_level  > 0 THEN
					oe_debug_pub.add('Before calling update payment trxn...');
					oe_debug_pub.add('Update card flag...'||l_update_card_flag);
				END IF;

				--<payment transaction id already exists,  need  to update the IBY transaction
				--extenstion table>
				OE_PAYMENT_TRXN_UTIL.Update_Payment_TRXN
				(P_header_id		=> p_x_line_Payment_rec.header_id,
				p_line_id		=> p_x_line_Payment_rec.line_id,
				p_cust_id		=> l_hdr_inv_to_cust_id,
				P_site_use_id		=> l_invoice_to_org_id,
				P_payment_trx_id	=> p_x_line_payment_rec.payment_trx_id,
				p_payment_number	=> p_x_line_payment_rec.payment_number,
				P_payment_type_code	=> p_x_line_payment_rec.payment_type_code,
				p_card_number		=> p_x_line_payment_rec.credit_card_number,
				p_card_code		=> p_x_line_payment_rec.credit_card_code,
				p_card_holder_name	=> p_x_line_payment_rec.credit_card_holder_name,
				p_exp_date		=> p_x_line_payment_rec.credit_card_expiration_date,
				p_receipt_method_id	=> p_x_line_payment_rec.receipt_method_id,
				p_instrument_security_code => p_x_line_payment_rec.instrument_security_code,
				p_trxn_extension_id	=> p_x_line_payment_rec.trxn_extension_id,
				p_update_card_flag	=> l_update_card_flag,
				p_instrument_id	=> p_x_line_payment_rec.cc_instrument_id,
				p_instrument_assignment_id => p_x_line_payment_rec.cc_instrument_assignment_id,
				X_return_status		=> l_return_status,
				X_msg_count		=> l_msg_count,
				X_msg_data		=> l_msg_data);


				IF l_debug_level > 0 THEN
					oe_debug_pub.add('trxn extension id after calling Update_Payment_TRXN:'||p_x_line_payment_rec.trxn_extension_id);
					oe_debug_pub.add(  'id already derived for this credit card');
				END IF;
			EXCEPTION
		        WHEN FND_API.G_EXC_ERROR THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Update_Payment_TRXN  error....exc');
					oe_debug_pub.add('After call to Update_Payment_TRXN'||l_return_status);
					oe_debug_pub.add('Error'||sqlerrm);
				END IF;
				l_return_status := FND_API.G_RET_STS_ERROR;
				OE_MSG_PUB.Count_And_Get
				    ( p_count => l_msg_count,
				      p_data  => l_msg_data
				    );
				RAISE FND_API.G_EXC_ERROR;

		        WHEN OTHERS THEN
				IF l_debug_level  > 0 THEN
					oe_debug_pub.add('After call to Update_Payment_TRXN --> Unexpected error');
					oe_debug_pub.add('Error message '||sqlerrm);
				END IF;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END;
		END IF;
	--Operation is Create. Hence need to create a new Trxn extension id
	--by calling the Create_trxn_extension API.
	ELSIF p_x_line_payment_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN --not a copy order Verify

		IF l_debug_level > 0 THEN
		   oe_debug_pub.add(  'Inside trxn extension id creation part....');
		END IF;


		/*l_trx_date := nvl(l_ordered_date, sysdate)
                    - nvl( to_number(fnd_profile.value('ONT_DAYS_TO_BACKDATE_BANK_ACCT')), 0);*/
		IF p_x_line_Payment_rec.payment_type_code = 'CREDIT_CARD' THEN
			IF OE_Payment_Trxn_Util.g_CC_Security_Code_Use  IS NULL THEN
				OE_Payment_Trxn_Util.g_CC_Security_Code_Use := OE_Payment_Trxn_Util.Get_CC_Security_Code_Use;
			END IF;

			IF OE_Payment_Trxn_Util.g_CC_Security_Code_Use  = 'REQUIRED' AND
			p_x_line_Payment_rec.instrument_security_code IS NULL THEN
				FND_MESSAGE.SET_NAME('ONT','OE_CC_SECURITY_CODE_REQD');
				OE_Msg_Pub.Add;
				RAISE FND_API.G_EXC_ERROR;
			END IF;
		END IF;

		IF NOT OE_GLOBALS.Is_Same_Credit_Card(p_old_line_Payment_rec.credit_card_number,
		    p_x_line_Payment_rec.credit_card_number,
		    p_old_line_Payment_rec.cc_instrument_id,
		    p_x_line_Payment_rec.cc_instrument_id)
		OR NOT OE_GLOBALS.Equal(p_x_line_Payment_rec.credit_card_code,
		p_old_line_Payment_rec.credit_card_code) THEN
			IF NOT OE_GLOBALS.Equal(p_x_line_Payment_rec.credit_card_holder_name,
			p_old_line_Payment_rec.credit_card_holder_name)
			OR NOT OE_GLOBALS.Equal(p_x_line_Payment_rec.credit_card_expiration_date,
			p_old_line_Payment_rec.credit_card_expiration_date)  THEN
				l_update_card_flag := 'Y';
			ELSE
				l_update_card_flag := 'N';
			END IF;
		ELSIF NOT OE_GLOBALS.Equal(p_x_line_Payment_rec.credit_card_holder_name,
		p_old_line_Payment_rec.credit_card_holder_name)
		OR NOT OE_GLOBALS.Equal(p_x_line_Payment_rec.credit_card_expiration_date,
		p_old_line_Payment_rec.credit_card_expiration_date)  THEN
			l_update_card_flag := 'Y';
		END IF;

		IF l_debug_level > 0 THEN
		   oe_debug_pub.add(  'Before calling create payment trxn....');
		   oe_debug_pub.add('Update card flag..'||l_update_card_flag);
		END IF;

               --Begin
	       --IF p_x_line_payment_rec.trxn_extension_id IS NULL THEN

		  BEGIN
			OE_PAYMENT_TRXN_UTIL.Create_Payment_TRXN
			(p_header_id		=> p_x_line_Payment_rec.header_id,
			 p_line_id		=> p_x_line_payment_rec.line_id,
			 p_cust_id		=> l_hdr_inv_to_cust_id,
			 P_site_use_id		=> l_invoice_to_org_id,
			 P_payment_trx_id	=> p_x_line_payment_rec.payment_trx_id,
			 p_payment_number	=> p_x_line_payment_rec.payment_number,
			 P_payment_type_code	=> p_x_line_payment_rec.payment_type_code,
			 P_card_number		=> p_x_line_payment_rec.credit_card_number,
			 p_card_code		=> p_x_line_payment_rec.credit_card_code,
			 P_card_holder_name	=> p_x_line_payment_rec.credit_card_holder_name,
			 P_exp_date		=> p_x_line_payment_rec.credit_card_expiration_date,
			 p_receipt_method_id	=> p_x_line_payment_rec.receipt_method_id,
			 p_instrument_security_code=>p_x_line_payment_rec.instrument_security_code,
			 p_update_card_flag	=> l_update_card_flag,
			 p_instrument_id	=> p_x_line_payment_rec.cc_instrument_id,
			 p_instrument_assignment_id => p_x_line_payment_rec.cc_instrument_assignment_id,
			 p_x_trxn_extension_id	=> p_x_line_payment_rec.trxn_extension_id,
			 X_return_status	=> l_return_status,
			 X_msg_count		=> l_msg_count,
			 X_msg_data		=> l_msg_data);

			 --p_x_line_payment_rec.trxn_extension_id := l_trxn_extension_id;
			 IF l_debug_level>0 THEN
				 oe_debug_pub.add('New trxn extension id after calling Create_Payment_TRXN:'||l_trxn_extension_id);
			 END IF;
		    Exception
		    WHEN FND_API.G_EXC_ERROR THEN
			OE_MSG_PUB.Count_And_Get
			    ( p_count => l_msg_count,
			      p_data  => l_msg_data
			    );
			l_return_status := FND_API.G_RET_STS_ERROR;
			RAISE FND_API.G_EXC_ERROR;

		    WHEN OTHERS THEN
			     OE_MSG_PUB.Count_And_Get
			     ( p_count => l_msg_count,
			       p_data  => l_msg_data
			     );
			      FND_MESSAGE.SET_NAME('ONT','OE_VPM_CC_ACCT_NOT_SET');
			      OE_MSG_PUB.ADD;
			      IF l_debug_level  > 0 THEN
				 oe_debug_pub.add(  'OEXUHPMB: ERROR IN CREATE PAYMENT trxn...'||sqlerrm) ;
				 oe_debug_pub.add('Error messsge ksurendr'||l_return_status);
			      END IF;
			      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		     end;
	END IF; --Operation
  ELSIF p_x_line_payment_rec.payment_type_code IN ('CHECK','CASH') AND
  p_x_line_payment_rec.operation = OE_GLOBALS.G_OPR_UPDATE
  AND p_old_line_Payment_rec.trxn_extension_id IS NOT NULL THEN

	--For update operation, the trxn extension id of the original
	--transaction needs to be deleted if it already exists as
	--there is no trxn extension id for check payments.
	IF l_debug_level > 0 THEN
		oe_debug_pub.add(' Before calling delete payment trxn....');
		oe_debug_pub.add(' Trxn extension to delete'||p_old_line_Payment_rec.trxn_extension_id);
		oe_debug_pub.add(' Header id '||p_x_line_payment_rec.line_id);
	END IF;

	OE_PAYMENT_TRXN_UTIL.Delete_Payment_Trxn
	(p_header_id => p_x_line_payment_rec.header_id,
	 p_line_id   => p_x_line_payment_rec.line_id,
	 p_payment_number =>  p_x_line_payment_rec.payment_number,
	 x_return_status  =>  l_return_status,
	 x_msg_count      =>  l_msg_count,
	 x_msg_data       =>  l_msg_data,
	 p_trxn_extension_id => p_old_line_Payment_rec.trxn_extension_id,
	 P_site_use_id	    => l_invoice_to_org_id
	 );

	IF l_return_status = FND_API.G_RET_STS_ERROR  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Successful deletion of trxn extension');
		oe_debug_pub.add('Return status after delete trxn in pre write process '|| l_return_status);
		oe_debug_pub.add('msg data'||l_msg_data);
	END IF;

	--Setting the trxn extension id as null as for transactions
	--coming from sales order others tab, the trxn extension id would
	--be updated in oe_payments table during updation.
	p_x_line_payment_rec.trxn_extension_id := null;
  END IF; --Payment type condtion
--R12 CC Encryption
EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
         IF L_DEBUG_LEVEL > 0 THEN
            Oe_debug_pub.add('OEXULPMB.pls - pre_write_process error ');
         END if;
	p_x_line_payment_rec.return_status := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF L_DEBUG_LEVEL > 0 THEN
            Oe_debug_pub.add('OEXULPMB.pls - pre_write_process unexpected error ');
         END if;
	p_x_line_payment_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     WHEN OTHERS THEN
         if l_debug_level > 0 then
            oe_debug_pub.add('OEXULPMB.pls - pre_write_process unexpected error ');
         end if;
 	p_x_line_payment_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pre_Write_Process;

--3382262
Procedure Delete_Payment_at_line(p_header_id in number := null,
                                   p_line_id in number,
                                   p_payment_number in number := null,
                                   p_payment_type_code in varchar2 := null,
                                   p_del_commitment in number := 0,
                                   x_return_status out nocopy varchar2,
                                   x_msg_count out nocopy number,
                                   x_msg_data out nocopy varchar2) is
p_count number := -1;
p_x_line_rec OE_ORDER_PUB.Line_Rec_Type;
l_old_line_rec OE_ORDER_PUB.Line_Rec_Type;
l_line_rec OE_ORDER_PUB.Line_Rec_Type;
l_return_status varchar2(30) := NULL;
l_payment_type_code varchar2(30) := null;
l_upd_commitment number := 0;
l_upd_payment number := 0;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

Begin


 IF p_payment_number is not null or p_payment_type_code is not null then

    IF p_payment_type_code = 'COMMITMENT' then
       l_upd_commitment := 1;
    ELSE
       l_upd_payment := 1;
    END IF;

 END IF;

  IF p_del_commitment = 1 then

    l_upd_commitment := 1;

  END IF;



 -- Set up the Line record
 OE_Line_Util.Lock_Row
                (p_line_id                    => p_line_id
                ,p_x_line_rec         => l_old_line_rec
                ,x_return_status                => l_return_status
                );
 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
 ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 l_line_rec := l_old_line_rec;

 if l_debug_level > 0 then
    oe_debug_pub.add('before updating oe_order_headers_all ');
 end if;

 if l_upd_commitment = 1 and l_upd_payment = 1 then

    if l_debug_level > 0 then
      oe_debug_pub.add('update commitment and payment type ');
    end if;

    update oe_order_lines_all
    set payment_type_code = null,
          commitment_id     = null
    where line_id = p_line_id;

 elsif l_upd_payment = 1 then

    if l_debug_level > 0 then
     oe_debug_pub.add('update payment type ');
    end if;

      update oe_order_lines_all
      set payment_type_code = null
      where line_id = p_line_id;

 elsif l_upd_commitment = 1 then

    if l_debug_level > 0 then
     oe_debug_pub.add('update commitment ');
    end if;

      update oe_order_lines_all
      set commitment_id = null
      where line_id = p_line_id;
 end if;

Exception

WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Payment_at_Line'
            );
      END IF;

END Delete_Payment_at_line;
--3382262



END OE_Line_Payment_Util;

/
