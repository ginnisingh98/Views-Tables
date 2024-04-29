--------------------------------------------------------
--  DDL for Package Body OE_DEFAULT_PRICE_BREAK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEFAULT_PRICE_BREAK" AS
/* $Header: OEXDDPBB.pls 115.0 99/07/15 19:20:41 porting shi $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Default_Price_Break';

--  Package global used within the package.

g_Price_Break_rec             OE_Pricing_Cont_PUB.Price_Break_Rec_Type;

--  Get functions.

FUNCTION Get_Amount
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Amount;

FUNCTION Get_Discount_Line
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Discount_Line;

FUNCTION Get_End_Date_Active
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_End_Date_Active;

FUNCTION Get_Method_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Method_Type;

FUNCTION Get_Percent
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Percent;

FUNCTION Get_Price
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Price;

FUNCTION Get_Price_Break_High
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Price_Break_High;

FUNCTION Get_Price_Break_Low
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Price_Break_Low;

FUNCTION Get_Start_Date_Active
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_Start_Date_Active;

FUNCTION Get_Unit
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Unit;

PROCEDURE Get_Flex_Price_Break
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_Price_Break_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_Price_Break_rec.attribute1   := NULL;
    END IF;

    IF g_Price_Break_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_Price_Break_rec.attribute10  := NULL;
    END IF;

    IF g_Price_Break_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_Price_Break_rec.attribute11  := NULL;
    END IF;

    IF g_Price_Break_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_Price_Break_rec.attribute12  := NULL;
    END IF;

    IF g_Price_Break_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_Price_Break_rec.attribute13  := NULL;
    END IF;

    IF g_Price_Break_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_Price_Break_rec.attribute14  := NULL;
    END IF;

    IF g_Price_Break_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_Price_Break_rec.attribute15  := NULL;
    END IF;

    IF g_Price_Break_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_Price_Break_rec.attribute2   := NULL;
    END IF;

    IF g_Price_Break_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_Price_Break_rec.attribute3   := NULL;
    END IF;

    IF g_Price_Break_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_Price_Break_rec.attribute4   := NULL;
    END IF;

    IF g_Price_Break_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_Price_Break_rec.attribute5   := NULL;
    END IF;

    IF g_Price_Break_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_Price_Break_rec.attribute6   := NULL;
    END IF;

    IF g_Price_Break_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_Price_Break_rec.attribute7   := NULL;
    END IF;

    IF g_Price_Break_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_Price_Break_rec.attribute8   := NULL;
    END IF;

    IF g_Price_Break_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_Price_Break_rec.attribute9   := NULL;
    END IF;

    IF g_Price_Break_rec.context = FND_API.G_MISS_CHAR THEN
        g_Price_Break_rec.context      := NULL;
    END IF;

END Get_Flex_Price_Break;

--  Procedure Attributes

PROCEDURE Attributes
(   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_PRICE_BREAK_REC
,   p_iteration                     IN  NUMBER := 1
,   x_Price_Break_rec               OUT OE_Pricing_Cont_PUB.Price_Break_Rec_Type
)
IS
BEGIN

    --  Check number of iterations.

    IF p_iteration > OE_GLOBALS.G_MAX_DEF_ITERATIONS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_DEF_MAX_ITERATION');
            OE_MSG_PUB.Add;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Initialize g_Price_Break_rec

    g_Price_Break_rec := p_Price_Break_rec;

    --  Default missing attributes.

    IF g_Price_Break_rec.amount = FND_API.G_MISS_NUM THEN

        g_Price_Break_rec.amount := Get_Amount;

        IF g_Price_Break_rec.amount IS NOT NULL THEN

            IF OE_Validate_Attr.Amount(g_Price_Break_rec.amount)
            THEN
                OE_Price_Break_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_Break_Util.G_AMOUNT
                ,   p_Price_Break_rec             => g_Price_Break_rec
                ,   x_Price_Break_rec             => g_Price_Break_rec
                );
            ELSE
                g_Price_Break_rec.amount := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Price_Break_rec.discount_line_id = FND_API.G_MISS_NUM THEN

        g_Price_Break_rec.discount_line_id := Get_Discount_Line;

        IF g_Price_Break_rec.discount_line_id IS NOT NULL THEN

            IF OE_Validate_Attr.Discount_Line(g_Price_Break_rec.discount_line_id)
            THEN
                OE_Price_Break_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_Break_Util.G_DISCOUNT_LINE
                ,   p_Price_Break_rec             => g_Price_Break_rec
                ,   x_Price_Break_rec             => g_Price_Break_rec
                );
            ELSE
                g_Price_Break_rec.discount_line_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Price_Break_rec.end_date_active = FND_API.G_MISS_DATE THEN

        g_Price_Break_rec.end_date_active := Get_End_Date_Active;

        IF g_Price_Break_rec.end_date_active IS NOT NULL THEN

            IF OE_Validate_Attr.End_Date_Active(g_Price_Break_rec.end_date_active)
            THEN
                OE_Price_Break_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_Break_Util.G_END_DATE_ACTIVE
                ,   p_Price_Break_rec             => g_Price_Break_rec
                ,   x_Price_Break_rec             => g_Price_Break_rec
                );
            ELSE
                g_Price_Break_rec.end_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Price_Break_rec.method_type_code = FND_API.G_MISS_CHAR THEN

        g_Price_Break_rec.method_type_code := Get_Method_Type;

        IF g_Price_Break_rec.method_type_code IS NOT NULL THEN

            IF OE_Validate_Attr.Method_Type(g_Price_Break_rec.method_type_code)
            THEN
                OE_Price_Break_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_Break_Util.G_METHOD_TYPE
                ,   p_Price_Break_rec             => g_Price_Break_rec
                ,   x_Price_Break_rec             => g_Price_Break_rec
                );
            ELSE
                g_Price_Break_rec.method_type_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Price_Break_rec.percent = FND_API.G_MISS_NUM THEN

        g_Price_Break_rec.percent := Get_Percent;

        IF g_Price_Break_rec.percent IS NOT NULL THEN

            IF OE_Validate_Attr.Percent(g_Price_Break_rec.percent)
            THEN
                OE_Price_Break_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_Break_Util.G_PERCENT
                ,   p_Price_Break_rec             => g_Price_Break_rec
                ,   x_Price_Break_rec             => g_Price_Break_rec
                );
            ELSE
                g_Price_Break_rec.percent := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Price_Break_rec.price = FND_API.G_MISS_NUM THEN

        g_Price_Break_rec.price := Get_Price;

        IF g_Price_Break_rec.price IS NOT NULL THEN

            IF OE_Validate_Attr.Price(g_Price_Break_rec.price)
            THEN
                OE_Price_Break_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_Break_Util.G_PRICE
                ,   p_Price_Break_rec             => g_Price_Break_rec
                ,   x_Price_Break_rec             => g_Price_Break_rec
                );
            ELSE
                g_Price_Break_rec.price := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Price_Break_rec.price_break_high = FND_API.G_MISS_NUM THEN

        g_Price_Break_rec.price_break_high := Get_Price_Break_High;

        IF g_Price_Break_rec.price_break_high IS NOT NULL THEN

            IF OE_Validate_Attr.Price_Break_High(g_Price_Break_rec.price_break_high)
            THEN
                OE_Price_Break_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_Break_Util.G_PRICE_BREAK_HIGH
                ,   p_Price_Break_rec             => g_Price_Break_rec
                ,   x_Price_Break_rec             => g_Price_Break_rec
                );
            ELSE
                g_Price_Break_rec.price_break_high := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Price_Break_rec.price_break_low = FND_API.G_MISS_NUM THEN

        g_Price_Break_rec.price_break_low := Get_Price_Break_Low;

        IF g_Price_Break_rec.price_break_low IS NOT NULL THEN

            IF OE_Validate_Attr.Price_Break_Low(g_Price_Break_rec.price_break_low)
            THEN
                OE_Price_Break_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_Break_Util.G_PRICE_BREAK_LOW
                ,   p_Price_Break_rec             => g_Price_Break_rec
                ,   x_Price_Break_rec             => g_Price_Break_rec
                );
            ELSE
                g_Price_Break_rec.price_break_low := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Price_Break_rec.start_date_active = FND_API.G_MISS_DATE THEN

        g_Price_Break_rec.start_date_active := Get_Start_Date_Active;

        IF g_Price_Break_rec.start_date_active IS NOT NULL THEN

            IF OE_Validate_Attr.Start_Date_Active(g_Price_Break_rec.start_date_active)
            THEN
                OE_Price_Break_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_Break_Util.G_START_DATE_ACTIVE
                ,   p_Price_Break_rec             => g_Price_Break_rec
                ,   x_Price_Break_rec             => g_Price_Break_rec
                );
            ELSE
                g_Price_Break_rec.start_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Price_Break_rec.unit_code = FND_API.G_MISS_CHAR THEN

        g_Price_Break_rec.unit_code := Get_Unit;

        IF g_Price_Break_rec.unit_code IS NOT NULL THEN

            IF OE_Validate_Attr.Unit(g_Price_Break_rec.unit_code)
            THEN
                OE_Price_Break_Util.Clear_Dependent_Attr
                (   p_attr_id                     => OE_Price_Break_Util.G_UNIT
                ,   p_Price_Break_rec             => g_Price_Break_rec
                ,   x_Price_Break_rec             => g_Price_Break_rec
                );
            ELSE
                g_Price_Break_rec.unit_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_Price_Break_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Price_Break;

    END IF;

    IF g_Price_Break_rec.created_by = FND_API.G_MISS_NUM THEN

        g_Price_Break_rec.created_by := NULL;

    END IF;

    IF g_Price_Break_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_Price_Break_rec.creation_date := NULL;

    END IF;

    IF g_Price_Break_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_Price_Break_rec.last_updated_by := NULL;

    END IF;

    IF g_Price_Break_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_Price_Break_rec.last_update_date := NULL;

    END IF;

    IF g_Price_Break_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_Price_Break_rec.last_update_login := NULL;

    END IF;

    IF g_Price_Break_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_Price_Break_rec.program_application_id := NULL;

    END IF;

    IF g_Price_Break_rec.program_id = FND_API.G_MISS_NUM THEN

        g_Price_Break_rec.program_id := NULL;

    END IF;

    IF g_Price_Break_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_Price_Break_rec.program_update_date := NULL;

    END IF;

    IF g_Price_Break_rec.request_id = FND_API.G_MISS_NUM THEN

        g_Price_Break_rec.request_id := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_Price_Break_rec.amount = FND_API.G_MISS_NUM
    OR  g_Price_Break_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.context = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.created_by = FND_API.G_MISS_NUM
    OR  g_Price_Break_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_Price_Break_rec.discount_line_id = FND_API.G_MISS_NUM
    OR  g_Price_Break_rec.end_date_active = FND_API.G_MISS_DATE
    OR  g_Price_Break_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_Price_Break_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_Price_Break_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_Price_Break_rec.method_type_code = FND_API.G_MISS_CHAR
    OR  g_Price_Break_rec.percent = FND_API.G_MISS_NUM
    OR  g_Price_Break_rec.price = FND_API.G_MISS_NUM
    OR  g_Price_Break_rec.price_break_high = FND_API.G_MISS_NUM
    OR  g_Price_Break_rec.price_break_low = FND_API.G_MISS_NUM
    OR  g_Price_Break_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_Price_Break_rec.program_id = FND_API.G_MISS_NUM
    OR  g_Price_Break_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_Price_Break_rec.request_id = FND_API.G_MISS_NUM
    OR  g_Price_Break_rec.start_date_active = FND_API.G_MISS_DATE
    OR  g_Price_Break_rec.unit_code = FND_API.G_MISS_CHAR
    THEN

        OE_Default_Price_Break.Attributes
        (   p_Price_Break_rec             => g_Price_Break_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_Price_Break_rec             => x_Price_Break_rec
        );

    ELSE

        --  Done defaulting attributes

        x_Price_Break_rec := g_Price_Break_rec;

    END IF;

END Attributes;

END OE_Default_Price_Break;

/
