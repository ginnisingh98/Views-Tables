--------------------------------------------------------
--  DDL for Package Body OE_VALIDATE_PRICE_BREAK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VALIDATE_PRICE_BREAK" AS
/* $Header: OEXLDPBB.pls 115.0 99/07/15 19:24:07 porting shi $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Validate_Price_Break';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT VARCHAR2
,   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
,   p_old_Price_Break_rec           IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_PRICE_BREAK_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    --  Check required attributes.

    IF  p_Price_Break_rec.discount_line_id IS NULL
    OR  p_Price_Break_rec.method_type_code IS NULL
    OR  p_Price_Break_rec.price_break_high IS NULL
    OR  p_Price_Break_rec.price_break_low IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('OE','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','amount');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    --
    --  Check rest of required attributes here.
    --


    --  Return Error if a required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --
    --  Check conditionally required attributes here.
    --


    --
    --  Validate attribute dependencies here.
    --


    --  Done validating entity

    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;

END Entity;

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT VARCHAR2
,   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
,   p_old_Price_Break_rec           IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_PRICE_BREAK_REC
)
IS
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate Price_Break attributes

    IF  p_Price_Break_rec.amount IS NOT NULL AND
        (   p_Price_Break_rec.amount <>
            p_old_Price_Break_rec.amount OR
            p_old_Price_Break_rec.amount IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Amount(p_Price_Break_rec.amount) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Price_Break_rec.created_by IS NOT NULL AND
        (   p_Price_Break_rec.created_by <>
            p_old_Price_Break_rec.created_by OR
            p_old_Price_Break_rec.created_by IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Created_By(p_Price_Break_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Price_Break_rec.creation_date IS NOT NULL AND
        (   p_Price_Break_rec.creation_date <>
            p_old_Price_Break_rec.creation_date OR
            p_old_Price_Break_rec.creation_date IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Creation_Date(p_Price_Break_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Price_Break_rec.discount_line_id IS NOT NULL AND
        (   p_Price_Break_rec.discount_line_id <>
            p_old_Price_Break_rec.discount_line_id OR
            p_old_Price_Break_rec.discount_line_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Discount_Line(p_Price_Break_rec.discount_line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Price_Break_rec.end_date_active IS NOT NULL AND
        (   p_Price_Break_rec.end_date_active <>
            p_old_Price_Break_rec.end_date_active OR
            p_old_Price_Break_rec.end_date_active IS NULL )
    THEN
        IF NOT OE_Validate_Attr.End_Date_Active(p_Price_Break_rec.end_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Price_Break_rec.last_updated_by IS NOT NULL AND
        (   p_Price_Break_rec.last_updated_by <>
            p_old_Price_Break_rec.last_updated_by OR
            p_old_Price_Break_rec.last_updated_by IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Last_Updated_By(p_Price_Break_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Price_Break_rec.last_update_date IS NOT NULL AND
        (   p_Price_Break_rec.last_update_date <>
            p_old_Price_Break_rec.last_update_date OR
            p_old_Price_Break_rec.last_update_date IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Last_Update_Date(p_Price_Break_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Price_Break_rec.last_update_login IS NOT NULL AND
        (   p_Price_Break_rec.last_update_login <>
            p_old_Price_Break_rec.last_update_login OR
            p_old_Price_Break_rec.last_update_login IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Last_Update_Login(p_Price_Break_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Price_Break_rec.method_type_code IS NOT NULL AND
        (   p_Price_Break_rec.method_type_code <>
            p_old_Price_Break_rec.method_type_code OR
            p_old_Price_Break_rec.method_type_code IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Method_Type(p_Price_Break_rec.method_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Price_Break_rec.percent IS NOT NULL AND
        (   p_Price_Break_rec.percent <>
            p_old_Price_Break_rec.percent OR
            p_old_Price_Break_rec.percent IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Percent(p_Price_Break_rec.percent) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Price_Break_rec.price IS NOT NULL AND
        (   p_Price_Break_rec.price <>
            p_old_Price_Break_rec.price OR
            p_old_Price_Break_rec.price IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Price(p_Price_Break_rec.price) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Price_Break_rec.price_break_high IS NOT NULL AND
        (   p_Price_Break_rec.price_break_high <>
            p_old_Price_Break_rec.price_break_high OR
            p_old_Price_Break_rec.price_break_high IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Price_Break_High(p_Price_Break_rec.price_break_high) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Price_Break_rec.price_break_low IS NOT NULL AND
        (   p_Price_Break_rec.price_break_low <>
            p_old_Price_Break_rec.price_break_low OR
            p_old_Price_Break_rec.price_break_low IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Price_Break_Low(p_Price_Break_rec.price_break_low) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Price_Break_rec.program_application_id IS NOT NULL AND
        (   p_Price_Break_rec.program_application_id <>
            p_old_Price_Break_rec.program_application_id OR
            p_old_Price_Break_rec.program_application_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Program_Application(p_Price_Break_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Price_Break_rec.program_id IS NOT NULL AND
        (   p_Price_Break_rec.program_id <>
            p_old_Price_Break_rec.program_id OR
            p_old_Price_Break_rec.program_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Program(p_Price_Break_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Price_Break_rec.program_update_date IS NOT NULL AND
        (   p_Price_Break_rec.program_update_date <>
            p_old_Price_Break_rec.program_update_date OR
            p_old_Price_Break_rec.program_update_date IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Program_Update_Date(p_Price_Break_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Price_Break_rec.request_id IS NOT NULL AND
        (   p_Price_Break_rec.request_id <>
            p_old_Price_Break_rec.request_id OR
            p_old_Price_Break_rec.request_id IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Request(p_Price_Break_rec.request_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Price_Break_rec.start_date_active IS NOT NULL AND
        (   p_Price_Break_rec.start_date_active <>
            p_old_Price_Break_rec.start_date_active OR
            p_old_Price_Break_rec.start_date_active IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Start_Date_Active(p_Price_Break_rec.start_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Price_Break_rec.unit_code IS NOT NULL AND
        (   p_Price_Break_rec.unit_code <>
            p_old_Price_Break_rec.unit_code OR
            p_old_Price_Break_rec.unit_code IS NULL )
    THEN
        IF NOT OE_Validate_Attr.Unit(p_Price_Break_rec.unit_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  (p_Price_Break_rec.attribute1 IS NOT NULL AND
        (   p_Price_Break_rec.attribute1 <>
            p_old_Price_Break_rec.attribute1 OR
            p_old_Price_Break_rec.attribute1 IS NULL ))
    OR  (p_Price_Break_rec.attribute10 IS NOT NULL AND
        (   p_Price_Break_rec.attribute10 <>
            p_old_Price_Break_rec.attribute10 OR
            p_old_Price_Break_rec.attribute10 IS NULL ))
    OR  (p_Price_Break_rec.attribute11 IS NOT NULL AND
        (   p_Price_Break_rec.attribute11 <>
            p_old_Price_Break_rec.attribute11 OR
            p_old_Price_Break_rec.attribute11 IS NULL ))
    OR  (p_Price_Break_rec.attribute12 IS NOT NULL AND
        (   p_Price_Break_rec.attribute12 <>
            p_old_Price_Break_rec.attribute12 OR
            p_old_Price_Break_rec.attribute12 IS NULL ))
    OR  (p_Price_Break_rec.attribute13 IS NOT NULL AND
        (   p_Price_Break_rec.attribute13 <>
            p_old_Price_Break_rec.attribute13 OR
            p_old_Price_Break_rec.attribute13 IS NULL ))
    OR  (p_Price_Break_rec.attribute14 IS NOT NULL AND
        (   p_Price_Break_rec.attribute14 <>
            p_old_Price_Break_rec.attribute14 OR
            p_old_Price_Break_rec.attribute14 IS NULL ))
    OR  (p_Price_Break_rec.attribute15 IS NOT NULL AND
        (   p_Price_Break_rec.attribute15 <>
            p_old_Price_Break_rec.attribute15 OR
            p_old_Price_Break_rec.attribute15 IS NULL ))
    OR  (p_Price_Break_rec.attribute2 IS NOT NULL AND
        (   p_Price_Break_rec.attribute2 <>
            p_old_Price_Break_rec.attribute2 OR
            p_old_Price_Break_rec.attribute2 IS NULL ))
    OR  (p_Price_Break_rec.attribute3 IS NOT NULL AND
        (   p_Price_Break_rec.attribute3 <>
            p_old_Price_Break_rec.attribute3 OR
            p_old_Price_Break_rec.attribute3 IS NULL ))
    OR  (p_Price_Break_rec.attribute4 IS NOT NULL AND
        (   p_Price_Break_rec.attribute4 <>
            p_old_Price_Break_rec.attribute4 OR
            p_old_Price_Break_rec.attribute4 IS NULL ))
    OR  (p_Price_Break_rec.attribute5 IS NOT NULL AND
        (   p_Price_Break_rec.attribute5 <>
            p_old_Price_Break_rec.attribute5 OR
            p_old_Price_Break_rec.attribute5 IS NULL ))
    OR  (p_Price_Break_rec.attribute6 IS NOT NULL AND
        (   p_Price_Break_rec.attribute6 <>
            p_old_Price_Break_rec.attribute6 OR
            p_old_Price_Break_rec.attribute6 IS NULL ))
    OR  (p_Price_Break_rec.attribute7 IS NOT NULL AND
        (   p_Price_Break_rec.attribute7 <>
            p_old_Price_Break_rec.attribute7 OR
            p_old_Price_Break_rec.attribute7 IS NULL ))
    OR  (p_Price_Break_rec.attribute8 IS NOT NULL AND
        (   p_Price_Break_rec.attribute8 <>
            p_old_Price_Break_rec.attribute8 OR
            p_old_Price_Break_rec.attribute8 IS NULL ))
    OR  (p_Price_Break_rec.attribute9 IS NOT NULL AND
        (   p_Price_Break_rec.attribute9 <>
            p_old_Price_Break_rec.attribute9 OR
            p_old_Price_Break_rec.attribute9 IS NULL ))
    OR  (p_Price_Break_rec.context IS NOT NULL AND
        (   p_Price_Break_rec.context <>
            p_old_Price_Break_rec.context OR
            p_old_Price_Break_rec.context IS NULL ))
    THEN

    --  These calls are temporarily commented out

/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_Price_Break_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_Price_Break_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_Price_Break_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_Price_Break_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_Price_Break_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_Price_Break_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_Price_Break_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_Price_Break_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_Price_Break_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_Price_Break_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_Price_Break_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_Price_Break_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_Price_Break_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_Price_Break_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_Price_Break_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'CONTEXT'
        ,   column_value                  => p_Price_Break_rec.context
        );
*/

        --  Validate descriptive flexfield.

        IF NOT OE_Validate_Attr.Desc_Flex( 'PRICE_BREAK' ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;

    --  Done validating attributes

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attributes'
            );
        END IF;

END Attributes;

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT VARCHAR2
,   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    --  Validate entity delete.

    NULL;

    --  Done.

    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity_Delete'
            );
        END IF;

END Entity_Delete;

END OE_Validate_Price_Break;

/
