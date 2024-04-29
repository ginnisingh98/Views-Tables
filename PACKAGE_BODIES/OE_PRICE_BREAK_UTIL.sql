--------------------------------------------------------
--  DDL for Package Body OE_PRICE_BREAK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PRICE_BREAK_UTIL" AS
/* $Header: OEXUDPBB.pls 115.0 99/07/15 19:27:17 porting shi $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Price_Break_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
,   p_old_Price_Break_rec           IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_PRICE_BREAK_REC
,   x_Price_Break_rec               OUT OE_Pricing_Cont_PUB.Price_Break_Rec_Type
)
IS
BEGIN

    --  Load out record

    x_Price_Break_rec := p_Price_Break_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.amount,p_old_Price_Break_rec.amount)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute1,p_old_Price_Break_rec.attribute1)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute10,p_old_Price_Break_rec.attribute10)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute11,p_old_Price_Break_rec.attribute11)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute12,p_old_Price_Break_rec.attribute12)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute13,p_old_Price_Break_rec.attribute13)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute14,p_old_Price_Break_rec.attribute14)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute15,p_old_Price_Break_rec.attribute15)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute2,p_old_Price_Break_rec.attribute2)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute3,p_old_Price_Break_rec.attribute3)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute4,p_old_Price_Break_rec.attribute4)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute5,p_old_Price_Break_rec.attribute5)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute6,p_old_Price_Break_rec.attribute6)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute7,p_old_Price_Break_rec.attribute7)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute8,p_old_Price_Break_rec.attribute8)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute9,p_old_Price_Break_rec.attribute9)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.context,p_old_Price_Break_rec.context)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.created_by,p_old_Price_Break_rec.created_by)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.creation_date,p_old_Price_Break_rec.creation_date)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.discount_line_id,p_old_Price_Break_rec.discount_line_id)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.end_date_active,p_old_Price_Break_rec.end_date_active)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.last_updated_by,p_old_Price_Break_rec.last_updated_by)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.last_update_date,p_old_Price_Break_rec.last_update_date)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.last_update_login,p_old_Price_Break_rec.last_update_login)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.method_type_code,p_old_Price_Break_rec.method_type_code)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.percent,p_old_Price_Break_rec.percent)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.price,p_old_Price_Break_rec.price)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.price_break_high,p_old_Price_Break_rec.price_break_high)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.price_break_low,p_old_Price_Break_rec.price_break_low)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.program_application_id,p_old_Price_Break_rec.program_application_id)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.program_id,p_old_Price_Break_rec.program_id)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.program_update_date,p_old_Price_Break_rec.program_update_date)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.request_id,p_old_Price_Break_rec.request_id)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.start_date_active,p_old_Price_Break_rec.start_date_active)
        THEN
            NULL;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.unit_code,p_old_Price_Break_rec.unit_code)
        THEN
            NULL;
        END IF;

    ELSIF p_attr_id = G_AMOUNT THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        NULL;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        NULL;
    ELSIF p_attr_id = G_CONTEXT THEN
        NULL;
    ELSIF p_attr_id = G_CREATED_BY THEN
        NULL;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        NULL;
    ELSIF p_attr_id = G_DISCOUNT_LINE THEN
        NULL;
    ELSIF p_attr_id = G_END_DATE_ACTIVE THEN
        NULL;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        NULL;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        NULL;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        NULL;
    ELSIF p_attr_id = G_METHOD_TYPE THEN
        NULL;
    ELSIF p_attr_id = G_PERCENT THEN
        NULL;
    ELSIF p_attr_id = G_PRICE THEN
        NULL;
    ELSIF p_attr_id = G_PRICE_BREAK_HIGH THEN
        NULL;
    ELSIF p_attr_id = G_PRICE_BREAK_LOW THEN
        NULL;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        NULL;
    ELSIF p_attr_id = G_PROGRAM THEN
        NULL;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        NULL;
    ELSIF p_attr_id = G_REQUEST THEN
        NULL;
    ELSIF p_attr_id = G_START_DATE_ACTIVE THEN
        NULL;
    ELSIF p_attr_id = G_UNIT THEN
        NULL;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
,   p_old_Price_Break_rec           IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_PRICE_BREAK_REC
,   x_Price_Break_rec               OUT OE_Pricing_Cont_PUB.Price_Break_Rec_Type
)
IS
BEGIN

    --  Load out record

    x_Price_Break_rec := p_Price_Break_rec;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.amount,p_old_Price_Break_rec.amount)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute1,p_old_Price_Break_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute10,p_old_Price_Break_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute11,p_old_Price_Break_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute12,p_old_Price_Break_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute13,p_old_Price_Break_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute14,p_old_Price_Break_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute15,p_old_Price_Break_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute2,p_old_Price_Break_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute3,p_old_Price_Break_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute4,p_old_Price_Break_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute5,p_old_Price_Break_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute6,p_old_Price_Break_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute7,p_old_Price_Break_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute8,p_old_Price_Break_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.attribute9,p_old_Price_Break_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.context,p_old_Price_Break_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.created_by,p_old_Price_Break_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.creation_date,p_old_Price_Break_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.discount_line_id,p_old_Price_Break_rec.discount_line_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.end_date_active,p_old_Price_Break_rec.end_date_active)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.last_updated_by,p_old_Price_Break_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.last_update_date,p_old_Price_Break_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.last_update_login,p_old_Price_Break_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.method_type_code,p_old_Price_Break_rec.method_type_code)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.percent,p_old_Price_Break_rec.percent)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.price,p_old_Price_Break_rec.price)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.price_break_high,p_old_Price_Break_rec.price_break_high)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.price_break_low,p_old_Price_Break_rec.price_break_low)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.program_application_id,p_old_Price_Break_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.program_id,p_old_Price_Break_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.program_update_date,p_old_Price_Break_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.request_id,p_old_Price_Break_rec.request_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.start_date_active,p_old_Price_Break_rec.start_date_active)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_Price_Break_rec.unit_code,p_old_Price_Break_rec.unit_code)
    THEN
        NULL;
    END IF;

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
,   p_old_Price_Break_rec           IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
) RETURN OE_Pricing_Cont_PUB.Price_Break_Rec_Type
IS
l_Price_Break_rec             OE_Pricing_Cont_PUB.Price_Break_Rec_Type := p_Price_Break_rec;
BEGIN

    IF l_Price_Break_rec.amount = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.amount := p_old_Price_Break_rec.amount;
    END IF;

    IF l_Price_Break_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute1 := p_old_Price_Break_rec.attribute1;
    END IF;

    IF l_Price_Break_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute10 := p_old_Price_Break_rec.attribute10;
    END IF;

    IF l_Price_Break_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute11 := p_old_Price_Break_rec.attribute11;
    END IF;

    IF l_Price_Break_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute12 := p_old_Price_Break_rec.attribute12;
    END IF;

    IF l_Price_Break_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute13 := p_old_Price_Break_rec.attribute13;
    END IF;

    IF l_Price_Break_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute14 := p_old_Price_Break_rec.attribute14;
    END IF;

    IF l_Price_Break_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute15 := p_old_Price_Break_rec.attribute15;
    END IF;

    IF l_Price_Break_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute2 := p_old_Price_Break_rec.attribute2;
    END IF;

    IF l_Price_Break_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute3 := p_old_Price_Break_rec.attribute3;
    END IF;

    IF l_Price_Break_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute4 := p_old_Price_Break_rec.attribute4;
    END IF;

    IF l_Price_Break_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute5 := p_old_Price_Break_rec.attribute5;
    END IF;

    IF l_Price_Break_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute6 := p_old_Price_Break_rec.attribute6;
    END IF;

    IF l_Price_Break_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute7 := p_old_Price_Break_rec.attribute7;
    END IF;

    IF l_Price_Break_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute8 := p_old_Price_Break_rec.attribute8;
    END IF;

    IF l_Price_Break_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute9 := p_old_Price_Break_rec.attribute9;
    END IF;

    IF l_Price_Break_rec.context = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.context := p_old_Price_Break_rec.context;
    END IF;

    IF l_Price_Break_rec.created_by = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.created_by := p_old_Price_Break_rec.created_by;
    END IF;

    IF l_Price_Break_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_Price_Break_rec.creation_date := p_old_Price_Break_rec.creation_date;
    END IF;

    IF l_Price_Break_rec.discount_line_id = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.discount_line_id := p_old_Price_Break_rec.discount_line_id;
    END IF;

    IF l_Price_Break_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_Price_Break_rec.end_date_active := p_old_Price_Break_rec.end_date_active;
    END IF;

    IF l_Price_Break_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.last_updated_by := p_old_Price_Break_rec.last_updated_by;
    END IF;

    IF l_Price_Break_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_Price_Break_rec.last_update_date := p_old_Price_Break_rec.last_update_date;
    END IF;

    IF l_Price_Break_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.last_update_login := p_old_Price_Break_rec.last_update_login;
    END IF;

    IF l_Price_Break_rec.method_type_code = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.method_type_code := p_old_Price_Break_rec.method_type_code;
    END IF;

    IF l_Price_Break_rec.percent = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.percent := p_old_Price_Break_rec.percent;
    END IF;

    IF l_Price_Break_rec.price = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.price := p_old_Price_Break_rec.price;
    END IF;

    IF l_Price_Break_rec.price_break_high = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.price_break_high := p_old_Price_Break_rec.price_break_high;
    END IF;

    IF l_Price_Break_rec.price_break_low = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.price_break_low := p_old_Price_Break_rec.price_break_low;
    END IF;

    IF l_Price_Break_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.program_application_id := p_old_Price_Break_rec.program_application_id;
    END IF;

    IF l_Price_Break_rec.program_id = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.program_id := p_old_Price_Break_rec.program_id;
    END IF;

    IF l_Price_Break_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_Price_Break_rec.program_update_date := p_old_Price_Break_rec.program_update_date;
    END IF;

    IF l_Price_Break_rec.request_id = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.request_id := p_old_Price_Break_rec.request_id;
    END IF;

    IF l_Price_Break_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_Price_Break_rec.start_date_active := p_old_Price_Break_rec.start_date_active;
    END IF;

    IF l_Price_Break_rec.unit_code = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.unit_code := p_old_Price_Break_rec.unit_code;
    END IF;

    RETURN l_Price_Break_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
) RETURN OE_Pricing_Cont_PUB.Price_Break_Rec_Type
IS
l_Price_Break_rec             OE_Pricing_Cont_PUB.Price_Break_Rec_Type := p_Price_Break_rec;
BEGIN

    IF l_Price_Break_rec.amount = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.amount := NULL;
    END IF;

    IF l_Price_Break_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute1 := NULL;
    END IF;

    IF l_Price_Break_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute10 := NULL;
    END IF;

    IF l_Price_Break_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute11 := NULL;
    END IF;

    IF l_Price_Break_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute12 := NULL;
    END IF;

    IF l_Price_Break_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute13 := NULL;
    END IF;

    IF l_Price_Break_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute14 := NULL;
    END IF;

    IF l_Price_Break_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute15 := NULL;
    END IF;

    IF l_Price_Break_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute2 := NULL;
    END IF;

    IF l_Price_Break_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute3 := NULL;
    END IF;

    IF l_Price_Break_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute4 := NULL;
    END IF;

    IF l_Price_Break_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute5 := NULL;
    END IF;

    IF l_Price_Break_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute6 := NULL;
    END IF;

    IF l_Price_Break_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute7 := NULL;
    END IF;

    IF l_Price_Break_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute8 := NULL;
    END IF;

    IF l_Price_Break_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.attribute9 := NULL;
    END IF;

    IF l_Price_Break_rec.context = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.context := NULL;
    END IF;

    IF l_Price_Break_rec.created_by = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.created_by := NULL;
    END IF;

    IF l_Price_Break_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_Price_Break_rec.creation_date := NULL;
    END IF;

    IF l_Price_Break_rec.discount_line_id = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.discount_line_id := NULL;
    END IF;

    IF l_Price_Break_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_Price_Break_rec.end_date_active := NULL;
    END IF;

    IF l_Price_Break_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.last_updated_by := NULL;
    END IF;

    IF l_Price_Break_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_Price_Break_rec.last_update_date := NULL;
    END IF;

    IF l_Price_Break_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.last_update_login := NULL;
    END IF;

    IF l_Price_Break_rec.method_type_code = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.method_type_code := NULL;
    END IF;

    IF l_Price_Break_rec.percent = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.percent := NULL;
    END IF;

    IF l_Price_Break_rec.price = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.price := NULL;
    END IF;

    IF l_Price_Break_rec.price_break_high = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.price_break_high := NULL;
    END IF;

    IF l_Price_Break_rec.price_break_low = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.price_break_low := NULL;
    END IF;

    IF l_Price_Break_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.program_application_id := NULL;
    END IF;

    IF l_Price_Break_rec.program_id = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.program_id := NULL;
    END IF;

    IF l_Price_Break_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_Price_Break_rec.program_update_date := NULL;
    END IF;

    IF l_Price_Break_rec.request_id = FND_API.G_MISS_NUM THEN
        l_Price_Break_rec.request_id := NULL;
    END IF;

    IF l_Price_Break_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_Price_Break_rec.start_date_active := NULL;
    END IF;

    IF l_Price_Break_rec.unit_code = FND_API.G_MISS_CHAR THEN
        l_Price_Break_rec.unit_code := NULL;
    END IF;

    RETURN l_Price_Break_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
)
IS
BEGIN

    UPDATE  OE_PRICE_BREAK_LINES
    SET     AMOUNT                         = p_Price_Break_rec.amount
    ,       ATTRIBUTE1                     = p_Price_Break_rec.attribute1
    ,       ATTRIBUTE10                    = p_Price_Break_rec.attribute10
    ,       ATTRIBUTE11                    = p_Price_Break_rec.attribute11
    ,       ATTRIBUTE12                    = p_Price_Break_rec.attribute12
    ,       ATTRIBUTE13                    = p_Price_Break_rec.attribute13
    ,       ATTRIBUTE14                    = p_Price_Break_rec.attribute14
    ,       ATTRIBUTE15                    = p_Price_Break_rec.attribute15
    ,       ATTRIBUTE2                     = p_Price_Break_rec.attribute2
    ,       ATTRIBUTE3                     = p_Price_Break_rec.attribute3
    ,       ATTRIBUTE4                     = p_Price_Break_rec.attribute4
    ,       ATTRIBUTE5                     = p_Price_Break_rec.attribute5
    ,       ATTRIBUTE6                     = p_Price_Break_rec.attribute6
    ,       ATTRIBUTE7                     = p_Price_Break_rec.attribute7
    ,       ATTRIBUTE8                     = p_Price_Break_rec.attribute8
    ,       ATTRIBUTE9                     = p_Price_Break_rec.attribute9
    ,       CONTEXT                        = p_Price_Break_rec.context
    ,       CREATED_BY                     = p_Price_Break_rec.created_by
    ,       CREATION_DATE                  = p_Price_Break_rec.creation_date
    ,       DISCOUNT_LINE_ID               = p_Price_Break_rec.discount_line_id
    ,       END_DATE_ACTIVE                = p_Price_Break_rec.end_date_active
    ,       LAST_UPDATED_BY                = p_Price_Break_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_Price_Break_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_Price_Break_rec.last_update_login
    ,       METHOD_TYPE_CODE               = p_Price_Break_rec.method_type_code
    ,       PERCENT                        = p_Price_Break_rec.percent
    ,       PRICE                          = p_Price_Break_rec.price
    ,       PRICE_BREAK_LINES_HIGH_RANGE   = p_Price_Break_rec.price_break_high
    ,       PRICE_BREAK_LINES_LOW_RANGE    = p_Price_Break_rec.price_break_low
    ,       PROGRAM_APPLICATION_ID         = p_Price_Break_rec.program_application_id
    ,       PROGRAM_ID                     = p_Price_Break_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_Price_Break_rec.program_update_date
    ,       REQUEST_ID                     = p_Price_Break_rec.request_id
    ,       START_DATE_ACTIVE              = p_Price_Break_rec.start_date_active
    ,       UNIT_CODE                      = p_Price_Break_rec.unit_code
    WHERE   DISCOUNT_LINE_ID = p_Price_Break_rec.discount_line_id
    AND     METHOD_TYPE_CODE = p_Price_Break_rec.method_type_code
    AND     PRICE_BREAK_LINES_HIGH_RANGE = p_Price_Break_rec.price_break_high
    AND     PRICE_BREAK_LINES_LOW_RANGE = p_Price_Break_rec.price_break_low
    ;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row;

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
)
IS
BEGIN

    INSERT  INTO OE_PRICE_BREAK_LINES
    (       AMOUNT
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DISCOUNT_LINE_ID
    ,       END_DATE_ACTIVE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       METHOD_TYPE_CODE
    ,       PERCENT
    ,       PRICE
    ,       PRICE_BREAK_LINES_HIGH_RANGE
    ,       PRICE_BREAK_LINES_LOW_RANGE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       START_DATE_ACTIVE
    ,       UNIT_CODE
    )
    VALUES
    (       p_Price_Break_rec.amount
    ,       p_Price_Break_rec.attribute1
    ,       p_Price_Break_rec.attribute10
    ,       p_Price_Break_rec.attribute11
    ,       p_Price_Break_rec.attribute12
    ,       p_Price_Break_rec.attribute13
    ,       p_Price_Break_rec.attribute14
    ,       p_Price_Break_rec.attribute15
    ,       p_Price_Break_rec.attribute2
    ,       p_Price_Break_rec.attribute3
    ,       p_Price_Break_rec.attribute4
    ,       p_Price_Break_rec.attribute5
    ,       p_Price_Break_rec.attribute6
    ,       p_Price_Break_rec.attribute7
    ,       p_Price_Break_rec.attribute8
    ,       p_Price_Break_rec.attribute9
    ,       p_Price_Break_rec.context
    ,       p_Price_Break_rec.created_by
    ,       p_Price_Break_rec.creation_date
    ,       p_Price_Break_rec.discount_line_id
    ,       p_Price_Break_rec.end_date_active
    ,       p_Price_Break_rec.last_updated_by
    ,       p_Price_Break_rec.last_update_date
    ,       p_Price_Break_rec.last_update_login
    ,       p_Price_Break_rec.method_type_code
    ,       p_Price_Break_rec.percent
    ,       p_Price_Break_rec.price
    ,       p_Price_Break_rec.price_break_high
    ,       p_Price_Break_rec.price_break_low
    ,       p_Price_Break_rec.program_application_id
    ,       p_Price_Break_rec.program_id
    ,       p_Price_Break_rec.program_update_date
    ,       p_Price_Break_rec.request_id
    ,       p_Price_Break_rec.start_date_active
    ,       p_Price_Break_rec.unit_code
    );

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_discount_line_id              IN  NUMBER
,   p_method_type_code              IN  VARCHAR2
,   p_price_break_high              IN  NUMBER
,   p_price_break_low               IN  NUMBER
)
IS
BEGIN

    DELETE  FROM OE_PRICE_BREAK_LINES
    WHERE   DISCOUNT_LINE_ID = p_discount_line_id
    AND     METHOD_TYPE_CODE = p_method_type_code
    AND     PRICE_BREAK_LINES_HIGH_RANGE = p_price_break_high
    AND     PRICE_BREAK_LINES_LOW_RANGE = p_price_break_low
    ;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

--  Function Query_Row

FUNCTION Query_Row
(   p_discount_line_id              IN  NUMBER
,   p_method_type_code              IN  VARCHAR2
,   p_price_break_high              IN  NUMBER
,   p_price_break_low               IN  NUMBER
) RETURN OE_Pricing_Cont_PUB.Price_Break_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_discount_line_id            => p_discount_line_id
        ,   p_method_type_code            => p_method_type_code
        ,   p_price_break_high            => p_price_break_high
        ,   p_price_break_low             => p_price_break_low
        )(1);

END Query_Row;

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
) RETURN OE_Pricing_Cont_PUB.Price_Break_Tbl_Type
IS
l_Price_Break_rec             OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_Price_Break_tbl             OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;

CURSOR l_Price_Break_csr IS
    SELECT  AMOUNT
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DISCOUNT_LINE_ID
    ,       END_DATE_ACTIVE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       METHOD_TYPE_CODE
    ,       PERCENT
    ,       PRICE
    ,       PRICE_BREAK_LINES_HIGH_RANGE
    ,       PRICE_BREAK_LINES_LOW_RANGE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       START_DATE_ACTIVE
    ,       UNIT_CODE
    FROM    OE_PRICE_BREAK_LINES
    WHERE ( DISCOUNT_LINE_ID = p_discount_line_id
    AND     METHOD_TYPE_CODE = p_method_type_code
    AND     PRICE_BREAK_LINES_HIGH_RANGE = p_price_break_high
    AND     PRICE_BREAK_LINES_LOW_RANGE = p_price_break_low
    )
    OR (    DISCOUNT_LINE_ID = p_discount_line_id
    );

BEGIN

    IF
    (p_discount_line_id IS NOT NULL
     AND
     p_discount_line_id <> FND_API.G_MISS_NUM)
    AND
    (p_method_type_code IS NOT NULL
     AND
     p_method_type_code <> FND_API.G_MISS_CHAR)
    AND
    (p_price_break_high IS NOT NULL
     AND
     p_price_break_high <> FND_API.G_MISS_NUM)
    AND
    (p_price_break_low IS NOT NULL
     AND
     p_price_break_low <> FND_API.G_MISS_NUM)
    THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: discount_line_id = '||
                     p_discount_line_id ||
                    ', method_type_code = '|| p_method_type_code ||
                    ', price_break_high = '|| p_price_break_high ||
                    ', price_break_low = '|| p_price_break_low ||
                    ', discount_line_id = '|| p_discount_line_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Loop over fetched records

    FOR l_implicit_rec IN l_Price_Break_csr LOOP

        l_Price_Break_rec.amount       := l_implicit_rec.AMOUNT;
        l_Price_Break_rec.attribute1   := l_implicit_rec.ATTRIBUTE1;
        l_Price_Break_rec.attribute10  := l_implicit_rec.ATTRIBUTE10;
        l_Price_Break_rec.attribute11  := l_implicit_rec.ATTRIBUTE11;
        l_Price_Break_rec.attribute12  := l_implicit_rec.ATTRIBUTE12;
        l_Price_Break_rec.attribute13  := l_implicit_rec.ATTRIBUTE13;
        l_Price_Break_rec.attribute14  := l_implicit_rec.ATTRIBUTE14;
        l_Price_Break_rec.attribute15  := l_implicit_rec.ATTRIBUTE15;
        l_Price_Break_rec.attribute2   := l_implicit_rec.ATTRIBUTE2;
        l_Price_Break_rec.attribute3   := l_implicit_rec.ATTRIBUTE3;
        l_Price_Break_rec.attribute4   := l_implicit_rec.ATTRIBUTE4;
        l_Price_Break_rec.attribute5   := l_implicit_rec.ATTRIBUTE5;
        l_Price_Break_rec.attribute6   := l_implicit_rec.ATTRIBUTE6;
        l_Price_Break_rec.attribute7   := l_implicit_rec.ATTRIBUTE7;
        l_Price_Break_rec.attribute8   := l_implicit_rec.ATTRIBUTE8;
        l_Price_Break_rec.attribute9   := l_implicit_rec.ATTRIBUTE9;
        l_Price_Break_rec.context      := l_implicit_rec.CONTEXT;
        l_Price_Break_rec.created_by   := l_implicit_rec.CREATED_BY;
        l_Price_Break_rec.creation_date := l_implicit_rec.CREATION_DATE;
        l_Price_Break_rec.discount_line_id := l_implicit_rec.DISCOUNT_LINE_ID;
        l_Price_Break_rec.end_date_active := l_implicit_rec.END_DATE_ACTIVE;
        l_Price_Break_rec.last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        l_Price_Break_rec.last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        l_Price_Break_rec.last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_Price_Break_rec.method_type_code := l_implicit_rec.METHOD_TYPE_CODE;
        l_Price_Break_rec.percent      := l_implicit_rec.PERCENT;
        l_Price_Break_rec.price        := l_implicit_rec.PRICE;
        l_Price_Break_rec.price_break_high := l_implicit_rec.PRICE_BREAK_LINES_HIGH_RANGE;
        l_Price_Break_rec.price_break_low := l_implicit_rec.PRICE_BREAK_LINES_LOW_RANGE;
        l_Price_Break_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_Price_Break_rec.program_id   := l_implicit_rec.PROGRAM_ID;
        l_Price_Break_rec.program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_Price_Break_rec.request_id   := l_implicit_rec.REQUEST_ID;
        l_Price_Break_rec.start_date_active := l_implicit_rec.START_DATE_ACTIVE;
        l_Price_Break_rec.unit_code    := l_implicit_rec.UNIT_CODE;

        l_Price_Break_tbl(l_Price_Break_tbl.COUNT + 1) := l_Price_Break_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_discount_line_id IS NOT NULL
     AND
     p_discount_line_id <> FND_API.G_MISS_NUM)
    AND
    (p_method_type_code IS NOT NULL
     AND
     p_method_type_code <> FND_API.G_MISS_CHAR)
    AND
    (p_price_break_high IS NOT NULL
     AND
     p_price_break_high <> FND_API.G_MISS_NUM)
    AND
    (p_price_break_low IS NOT NULL
     AND
     p_price_break_low <> FND_API.G_MISS_NUM)
    AND
    (l_Price_Break_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

    RETURN l_Price_Break_tbl;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Rows'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Rows;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT VARCHAR2
,   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
,   x_Price_Break_rec               OUT OE_Pricing_Cont_PUB.Price_Break_Rec_Type
)
IS
l_Price_Break_rec             OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
BEGIN

    SELECT  AMOUNT
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       DISCOUNT_LINE_ID
    ,       END_DATE_ACTIVE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       METHOD_TYPE_CODE
    ,       PERCENT
    ,       PRICE
    ,       PRICE_BREAK_LINES_HIGH_RANGE
    ,       PRICE_BREAK_LINES_LOW_RANGE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       START_DATE_ACTIVE
    ,       UNIT_CODE
    INTO    l_Price_Break_rec.amount
    ,       l_Price_Break_rec.attribute1
    ,       l_Price_Break_rec.attribute10
    ,       l_Price_Break_rec.attribute11
    ,       l_Price_Break_rec.attribute12
    ,       l_Price_Break_rec.attribute13
    ,       l_Price_Break_rec.attribute14
    ,       l_Price_Break_rec.attribute15
    ,       l_Price_Break_rec.attribute2
    ,       l_Price_Break_rec.attribute3
    ,       l_Price_Break_rec.attribute4
    ,       l_Price_Break_rec.attribute5
    ,       l_Price_Break_rec.attribute6
    ,       l_Price_Break_rec.attribute7
    ,       l_Price_Break_rec.attribute8
    ,       l_Price_Break_rec.attribute9
    ,       l_Price_Break_rec.context
    ,       l_Price_Break_rec.created_by
    ,       l_Price_Break_rec.creation_date
    ,       l_Price_Break_rec.discount_line_id
    ,       l_Price_Break_rec.end_date_active
    ,       l_Price_Break_rec.last_updated_by
    ,       l_Price_Break_rec.last_update_date
    ,       l_Price_Break_rec.last_update_login
    ,       l_Price_Break_rec.method_type_code
    ,       l_Price_Break_rec.percent
    ,       l_Price_Break_rec.price
    ,       l_Price_Break_rec.price_break_high
    ,       l_Price_Break_rec.price_break_low
    ,       l_Price_Break_rec.program_application_id
    ,       l_Price_Break_rec.program_id
    ,       l_Price_Break_rec.program_update_date
    ,       l_Price_Break_rec.request_id
    ,       l_Price_Break_rec.start_date_active
    ,       l_Price_Break_rec.unit_code
    FROM    OE_PRICE_BREAK_LINES
    WHERE   DISCOUNT_LINE_ID = p_Price_Break_rec.discount_line_id
    AND     METHOD_TYPE_CODE = p_Price_Break_rec.method_type_code
    AND     PRICE_BREAK_LINES_HIGH_RANGE = p_Price_Break_rec.price_break_high
    AND     PRICE_BREAK_LINES_LOW_RANGE = p_Price_Break_rec.price_break_low
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  (   (l_Price_Break_rec.amount =
             p_Price_Break_rec.amount) OR
            ((p_Price_Break_rec.amount = FND_API.G_MISS_NUM) OR
            (   (l_Price_Break_rec.amount IS NULL) AND
                (p_Price_Break_rec.amount IS NULL))))
    AND (   (l_Price_Break_rec.attribute1 =
             p_Price_Break_rec.attribute1) OR
            ((p_Price_Break_rec.attribute1 = FND_API.G_MISS_CHAR) OR
            (   (l_Price_Break_rec.attribute1 IS NULL) AND
                (p_Price_Break_rec.attribute1 IS NULL))))
    AND (   (l_Price_Break_rec.attribute10 =
             p_Price_Break_rec.attribute10) OR
            ((p_Price_Break_rec.attribute10 = FND_API.G_MISS_CHAR) OR
            (   (l_Price_Break_rec.attribute10 IS NULL) AND
                (p_Price_Break_rec.attribute10 IS NULL))))
    AND (   (l_Price_Break_rec.attribute11 =
             p_Price_Break_rec.attribute11) OR
            ((p_Price_Break_rec.attribute11 = FND_API.G_MISS_CHAR) OR
            (   (l_Price_Break_rec.attribute11 IS NULL) AND
                (p_Price_Break_rec.attribute11 IS NULL))))
    AND (   (l_Price_Break_rec.attribute12 =
             p_Price_Break_rec.attribute12) OR
            ((p_Price_Break_rec.attribute12 = FND_API.G_MISS_CHAR) OR
            (   (l_Price_Break_rec.attribute12 IS NULL) AND
                (p_Price_Break_rec.attribute12 IS NULL))))
    AND (   (l_Price_Break_rec.attribute13 =
             p_Price_Break_rec.attribute13) OR
            ((p_Price_Break_rec.attribute13 = FND_API.G_MISS_CHAR) OR
            (   (l_Price_Break_rec.attribute13 IS NULL) AND
                (p_Price_Break_rec.attribute13 IS NULL))))
    AND (   (l_Price_Break_rec.attribute14 =
             p_Price_Break_rec.attribute14) OR
            ((p_Price_Break_rec.attribute14 = FND_API.G_MISS_CHAR) OR
            (   (l_Price_Break_rec.attribute14 IS NULL) AND
                (p_Price_Break_rec.attribute14 IS NULL))))
    AND (   (l_Price_Break_rec.attribute15 =
             p_Price_Break_rec.attribute15) OR
            ((p_Price_Break_rec.attribute15 = FND_API.G_MISS_CHAR) OR
            (   (l_Price_Break_rec.attribute15 IS NULL) AND
                (p_Price_Break_rec.attribute15 IS NULL))))
    AND (   (l_Price_Break_rec.attribute2 =
             p_Price_Break_rec.attribute2) OR
            ((p_Price_Break_rec.attribute2 = FND_API.G_MISS_CHAR) OR
            (   (l_Price_Break_rec.attribute2 IS NULL) AND
                (p_Price_Break_rec.attribute2 IS NULL))))
    AND (   (l_Price_Break_rec.attribute3 =
             p_Price_Break_rec.attribute3) OR
            ((p_Price_Break_rec.attribute3 = FND_API.G_MISS_CHAR) OR
            (   (l_Price_Break_rec.attribute3 IS NULL) AND
                (p_Price_Break_rec.attribute3 IS NULL))))
    AND (   (l_Price_Break_rec.attribute4 =
             p_Price_Break_rec.attribute4) OR
            ((p_Price_Break_rec.attribute4 = FND_API.G_MISS_CHAR) OR
            (   (l_Price_Break_rec.attribute4 IS NULL) AND
                (p_Price_Break_rec.attribute4 IS NULL))))
    AND (   (l_Price_Break_rec.attribute5 =
             p_Price_Break_rec.attribute5) OR
            ((p_Price_Break_rec.attribute5 = FND_API.G_MISS_CHAR) OR
            (   (l_Price_Break_rec.attribute5 IS NULL) AND
                (p_Price_Break_rec.attribute5 IS NULL))))
    AND (   (l_Price_Break_rec.attribute6 =
             p_Price_Break_rec.attribute6) OR
            ((p_Price_Break_rec.attribute6 = FND_API.G_MISS_CHAR) OR
            (   (l_Price_Break_rec.attribute6 IS NULL) AND
                (p_Price_Break_rec.attribute6 IS NULL))))
    AND (   (l_Price_Break_rec.attribute7 =
             p_Price_Break_rec.attribute7) OR
            ((p_Price_Break_rec.attribute7 = FND_API.G_MISS_CHAR) OR
            (   (l_Price_Break_rec.attribute7 IS NULL) AND
                (p_Price_Break_rec.attribute7 IS NULL))))
    AND (   (l_Price_Break_rec.attribute8 =
             p_Price_Break_rec.attribute8) OR
            ((p_Price_Break_rec.attribute8 = FND_API.G_MISS_CHAR) OR
            (   (l_Price_Break_rec.attribute8 IS NULL) AND
                (p_Price_Break_rec.attribute8 IS NULL))))
    AND (   (l_Price_Break_rec.attribute9 =
             p_Price_Break_rec.attribute9) OR
            ((p_Price_Break_rec.attribute9 = FND_API.G_MISS_CHAR) OR
            (   (l_Price_Break_rec.attribute9 IS NULL) AND
                (p_Price_Break_rec.attribute9 IS NULL))))
    AND (   (l_Price_Break_rec.context =
             p_Price_Break_rec.context) OR
            ((p_Price_Break_rec.context = FND_API.G_MISS_CHAR) OR
            (   (l_Price_Break_rec.context IS NULL) AND
                (p_Price_Break_rec.context IS NULL))))
    AND (   (l_Price_Break_rec.created_by =
             p_Price_Break_rec.created_by) OR
            ((p_Price_Break_rec.created_by = FND_API.G_MISS_NUM) OR
            (   (l_Price_Break_rec.created_by IS NULL) AND
                (p_Price_Break_rec.created_by IS NULL))))
    AND (   (l_Price_Break_rec.creation_date =
             p_Price_Break_rec.creation_date) OR
            ((p_Price_Break_rec.creation_date = FND_API.G_MISS_DATE) OR
            (   (l_Price_Break_rec.creation_date IS NULL) AND
                (p_Price_Break_rec.creation_date IS NULL))))
    AND (   (l_Price_Break_rec.discount_line_id =
             p_Price_Break_rec.discount_line_id) OR
            ((p_Price_Break_rec.discount_line_id = FND_API.G_MISS_NUM) OR
            (   (l_Price_Break_rec.discount_line_id IS NULL) AND
                (p_Price_Break_rec.discount_line_id IS NULL))))
    AND (   (l_Price_Break_rec.end_date_active =
             p_Price_Break_rec.end_date_active) OR
            ((p_Price_Break_rec.end_date_active = FND_API.G_MISS_DATE) OR
            (   (l_Price_Break_rec.end_date_active IS NULL) AND
                (p_Price_Break_rec.end_date_active IS NULL))))
    AND (   (l_Price_Break_rec.last_updated_by =
             p_Price_Break_rec.last_updated_by) OR
            ((p_Price_Break_rec.last_updated_by = FND_API.G_MISS_NUM) OR
            (   (l_Price_Break_rec.last_updated_by IS NULL) AND
                (p_Price_Break_rec.last_updated_by IS NULL))))
    AND (   (l_Price_Break_rec.last_update_date =
             p_Price_Break_rec.last_update_date) OR
            ((p_Price_Break_rec.last_update_date = FND_API.G_MISS_DATE) OR
            (   (l_Price_Break_rec.last_update_date IS NULL) AND
                (p_Price_Break_rec.last_update_date IS NULL))))
    AND (   (l_Price_Break_rec.last_update_login =
             p_Price_Break_rec.last_update_login) OR
            ((p_Price_Break_rec.last_update_login = FND_API.G_MISS_NUM) OR
            (   (l_Price_Break_rec.last_update_login IS NULL) AND
                (p_Price_Break_rec.last_update_login IS NULL))))
    AND (   (l_Price_Break_rec.method_type_code =
             p_Price_Break_rec.method_type_code) OR
            ((p_Price_Break_rec.method_type_code = FND_API.G_MISS_CHAR) OR
            (   (l_Price_Break_rec.method_type_code IS NULL) AND
                (p_Price_Break_rec.method_type_code IS NULL))))
    AND (   (l_Price_Break_rec.percent =
             p_Price_Break_rec.percent) OR
            ((p_Price_Break_rec.percent = FND_API.G_MISS_NUM) OR
            (   (l_Price_Break_rec.percent IS NULL) AND
                (p_Price_Break_rec.percent IS NULL))))
    AND (   (l_Price_Break_rec.price =
             p_Price_Break_rec.price) OR
            ((p_Price_Break_rec.price = FND_API.G_MISS_NUM) OR
            (   (l_Price_Break_rec.price IS NULL) AND
                (p_Price_Break_rec.price IS NULL))))
    AND (   (l_Price_Break_rec.price_break_high =
             p_Price_Break_rec.price_break_high) OR
            ((p_Price_Break_rec.price_break_high = FND_API.G_MISS_NUM) OR
            (   (l_Price_Break_rec.price_break_high IS NULL) AND
                (p_Price_Break_rec.price_break_high IS NULL))))
    AND (   (l_Price_Break_rec.price_break_low =
             p_Price_Break_rec.price_break_low) OR
            ((p_Price_Break_rec.price_break_low = FND_API.G_MISS_NUM) OR
            (   (l_Price_Break_rec.price_break_low IS NULL) AND
                (p_Price_Break_rec.price_break_low IS NULL))))
    AND (   (l_Price_Break_rec.program_application_id =
             p_Price_Break_rec.program_application_id) OR
            ((p_Price_Break_rec.program_application_id = FND_API.G_MISS_NUM) OR
            (   (l_Price_Break_rec.program_application_id IS NULL) AND
                (p_Price_Break_rec.program_application_id IS NULL))))
    AND (   (l_Price_Break_rec.program_id =
             p_Price_Break_rec.program_id) OR
            ((p_Price_Break_rec.program_id = FND_API.G_MISS_NUM) OR
            (   (l_Price_Break_rec.program_id IS NULL) AND
                (p_Price_Break_rec.program_id IS NULL))))
    AND (   (l_Price_Break_rec.program_update_date =
             p_Price_Break_rec.program_update_date) OR
            ((p_Price_Break_rec.program_update_date = FND_API.G_MISS_DATE) OR
            (   (l_Price_Break_rec.program_update_date IS NULL) AND
                (p_Price_Break_rec.program_update_date IS NULL))))
    AND (   (l_Price_Break_rec.request_id =
             p_Price_Break_rec.request_id) OR
            ((p_Price_Break_rec.request_id = FND_API.G_MISS_NUM) OR
            (   (l_Price_Break_rec.request_id IS NULL) AND
                (p_Price_Break_rec.request_id IS NULL))))
    AND (   (l_Price_Break_rec.start_date_active =
             p_Price_Break_rec.start_date_active) OR
            ((p_Price_Break_rec.start_date_active = FND_API.G_MISS_DATE) OR
            (   (l_Price_Break_rec.start_date_active IS NULL) AND
                (p_Price_Break_rec.start_date_active IS NULL))))
    AND (   (l_Price_Break_rec.unit_code =
             p_Price_Break_rec.unit_code) OR
            ((p_Price_Break_rec.unit_code = FND_API.G_MISS_CHAR) OR
            (   (l_Price_Break_rec.unit_code IS NULL) AND
                (p_Price_Break_rec.unit_code IS NULL))))
    THEN

        --  Row has not changed. Set out parameter.

        x_Price_Break_rec              := l_Price_Break_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_Price_Break_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Price_Break_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Price_Break_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Price_Break_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_Price_Break_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;

--  Function Get_Values

FUNCTION Get_Values
(   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
,   p_old_Price_Break_rec           IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_PRICE_BREAK_REC
) RETURN OE_Pricing_Cont_PUB.Price_Break_Val_Rec_Type
IS
l_Price_Break_val_rec         OE_Pricing_Cont_PUB.Price_Break_Val_Rec_Type;
BEGIN
/*
    IF p_Price_Break_rec.discount_line_id IS NOT NULL AND
        p_Price_Break_rec.discount_line_id <> FND_API.G_MISS_NUM AND
        NOT OE_GLOBALS.Equal(p_Price_Break_rec.discount_line_id,
        p_old_Price_Break_rec.discount_line_id)
    THEN
        l_Price_Break_val_rec.discount_line := OE_Id_To_Value.Discount_Line
        (   p_discount_line_id            => p_Price_Break_rec.discount_line_id
        );
    END IF;
*/
    IF p_Price_Break_rec.method_type_code IS NOT NULL AND
        p_Price_Break_rec.method_type_code <> FND_API.G_MISS_CHAR AND
        NOT OE_GLOBALS.Equal(p_Price_Break_rec.method_type_code,
        p_old_Price_Break_rec.method_type_code)
    THEN
        l_Price_Break_val_rec.method_type := OE_Id_To_Value.Method_Type
        (   p_method_type_code            => p_Price_Break_rec.method_type_code
        );
    END IF;

    IF p_Price_Break_rec.unit_code IS NOT NULL AND
        p_Price_Break_rec.unit_code <> FND_API.G_MISS_CHAR AND
        NOT OE_GLOBALS.Equal(p_Price_Break_rec.unit_code,
        p_old_Price_Break_rec.unit_code)
    THEN
        l_Price_Break_val_rec.unit := OE_Id_To_Value.Unit
        (   p_unit_code                   => p_Price_Break_rec.unit_code
        );
    END IF;

    RETURN l_Price_Break_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
,   p_Price_Break_val_rec           IN  OE_Pricing_Cont_PUB.Price_Break_Val_Rec_Type
) RETURN OE_Pricing_Cont_PUB.Price_Break_Rec_Type
IS
l_Price_Break_rec             OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_Price_Break_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_Price_Break_rec.

    l_Price_Break_rec := p_Price_Break_rec;
/*
    IF  p_Price_Break_val_rec.discount_line <> FND_API.G_MISS_CHAR
    THEN

        IF p_Price_Break_rec.discount_line_id <> FND_API.G_MISS_NUM THEN

            l_Price_Break_rec.discount_line_id := p_Price_Break_rec.discount_line_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','discount_line');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Price_Break_rec.discount_line_id := OE_Value_To_Id.discount_line
            (   p_discount_line               => p_Price_Break_val_rec.discount_line
            );

            IF l_Price_Break_rec.discount_line_id = FND_API.G_MISS_NUM THEN
                l_Price_Break_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;
*/
    IF  p_Price_Break_val_rec.method_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_Price_Break_rec.method_type_code <> FND_API.G_MISS_CHAR THEN

            l_Price_Break_rec.method_type_code := p_Price_Break_rec.method_type_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','method_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Price_Break_rec.method_type_code := OE_Value_To_Id.method_type
            (   p_method_type                 => p_Price_Break_val_rec.method_type
            );

            IF l_Price_Break_rec.method_type_code = FND_API.G_MISS_CHAR THEN
                l_Price_Break_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Price_Break_val_rec.unit <> FND_API.G_MISS_CHAR
    THEN

        IF p_Price_Break_rec.unit_code <> FND_API.G_MISS_CHAR THEN

            l_Price_Break_rec.unit_code := p_Price_Break_rec.unit_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','unit');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_Price_Break_rec.unit_code := OE_Value_To_Id.unit
            (   p_unit                        => p_Price_Break_val_rec.unit
            );

            IF l_Price_Break_rec.unit_code = FND_API.G_MISS_CHAR THEN
                l_Price_Break_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    RETURN l_Price_Break_rec;

END Get_Ids;

END OE_Price_Break_Util;

/
