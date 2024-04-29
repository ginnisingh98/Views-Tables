--------------------------------------------------------
--  DDL for Package Body QP_VALIDATE_LIMIT_BALANCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_VALIDATE_LIMIT_BALANCES" AS
/* $Header: QPXLLMBB.pls 120.1 2005/06/08 04:12:10 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Validate_Limit_Balances';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMIT_BALANCES_rec            IN  QP_Limits_PUB.Limit_Balances_Rec_Type
,   p_old_LIMIT_BALANCES_rec        IN  QP_Limits_PUB.Limit_Balances_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_BALANCES_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    --  Check required attributes.

    IF  p_LIMIT_BALANCES_rec.limit_balance_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','attribute1');
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
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMIT_BALANCES_rec            IN  QP_Limits_PUB.Limit_Balances_Rec_Type
,   p_old_LIMIT_BALANCES_rec        IN  QP_Limits_PUB.Limit_Balances_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMIT_BALANCES_REC
)
IS
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate LIMIT_BALANCES attributes

    IF  p_LIMIT_BALANCES_rec.available_amount IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.available_amount <>
            p_old_LIMIT_BALANCES_rec.available_amount OR
            p_old_LIMIT_BALANCES_rec.available_amount IS NULL )
    THEN
        IF NOT QP_Validate.Available_Amount(p_LIMIT_BALANCES_rec.available_amount) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.consumed_amount IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.consumed_amount <>
            p_old_LIMIT_BALANCES_rec.consumed_amount OR
            p_old_LIMIT_BALANCES_rec.consumed_amount IS NULL )
    THEN
        IF NOT QP_Validate.Consumed_Amount(p_LIMIT_BALANCES_rec.consumed_amount) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.created_by IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.created_by <>
            p_old_LIMIT_BALANCES_rec.created_by OR
            p_old_LIMIT_BALANCES_rec.created_by IS NULL )
    THEN
        IF NOT QP_Validate.Created_By(p_LIMIT_BALANCES_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.creation_date IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.creation_date <>
            p_old_LIMIT_BALANCES_rec.creation_date OR
            p_old_LIMIT_BALANCES_rec.creation_date IS NULL )
    THEN
        IF NOT QP_Validate.Creation_Date(p_LIMIT_BALANCES_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.last_updated_by IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.last_updated_by <>
            p_old_LIMIT_BALANCES_rec.last_updated_by OR
            p_old_LIMIT_BALANCES_rec.last_updated_by IS NULL )
    THEN
        IF NOT QP_Validate.Last_Updated_By(p_LIMIT_BALANCES_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.last_update_date IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.last_update_date <>
            p_old_LIMIT_BALANCES_rec.last_update_date OR
            p_old_LIMIT_BALANCES_rec.last_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Date(p_LIMIT_BALANCES_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.last_update_login IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.last_update_login <>
            p_old_LIMIT_BALANCES_rec.last_update_login OR
            p_old_LIMIT_BALANCES_rec.last_update_login IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Login(p_LIMIT_BALANCES_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.limit_balance_id IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.limit_balance_id <>
            p_old_LIMIT_BALANCES_rec.limit_balance_id OR
            p_old_LIMIT_BALANCES_rec.limit_balance_id IS NULL )
    THEN
        IF NOT QP_Validate.Limit_Balance(p_LIMIT_BALANCES_rec.limit_balance_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.limit_id IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.limit_id <>
            p_old_LIMIT_BALANCES_rec.limit_id OR
            p_old_LIMIT_BALANCES_rec.limit_id IS NULL )
    THEN
        IF NOT QP_Validate.Limit(p_LIMIT_BALANCES_rec.limit_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.multival_attr1_type IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.multival_attr1_type <>
            p_old_LIMIT_BALANCES_rec.multival_attr1_type OR
            p_old_LIMIT_BALANCES_rec.multival_attr1_type IS NULL )
    THEN
        IF NOT QP_Validate.Multival_Attr1_Type(p_LIMIT_BALANCES_rec.multival_attr1_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.multival_attr1_context IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.multival_attr1_context <>
            p_old_LIMIT_BALANCES_rec.multival_attr1_context OR
            p_old_LIMIT_BALANCES_rec.multival_attr1_context IS NULL )
    THEN
        IF NOT QP_Validate.Multival_Attr1_Context(p_LIMIT_BALANCES_rec.multival_attr1_context) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.multival_attribute1 IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.multival_attribute1 <>
            p_old_LIMIT_BALANCES_rec.multival_attribute1 OR
            p_old_LIMIT_BALANCES_rec.multival_attribute1 IS NULL )
    THEN
        IF NOT QP_Validate.Multival_Attribute1(p_LIMIT_BALANCES_rec.multival_attribute1) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.multival_attr1_value IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.multival_attr1_value <>
            p_old_LIMIT_BALANCES_rec.multival_attr1_value OR
            p_old_LIMIT_BALANCES_rec.multival_attr1_value IS NULL )
    THEN
        IF NOT QP_Validate.Multival_Attr1_Value(p_LIMIT_BALANCES_rec.multival_attr1_value) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.multival_attr1_datatype IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.multival_attr1_datatype <>
            p_old_LIMIT_BALANCES_rec.multival_attr1_datatype OR
            p_old_LIMIT_BALANCES_rec.multival_attr1_datatype IS NULL )
    THEN
        IF NOT QP_Validate.Multival_Attr1_Datatype(p_LIMIT_BALANCES_rec.multival_attr1_datatype) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.multival_attr2_type IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.multival_attr2_type <>
            p_old_LIMIT_BALANCES_rec.multival_attr2_type OR
            p_old_LIMIT_BALANCES_rec.multival_attr2_type IS NULL )
    THEN
        IF NOT QP_Validate.Multival_Attr2_Type(p_LIMIT_BALANCES_rec.multival_attr2_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.multival_attr2_context IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.multival_attr2_context <>
            p_old_LIMIT_BALANCES_rec.multival_attr2_context OR
            p_old_LIMIT_BALANCES_rec.multival_attr2_context IS NULL )
    THEN
        IF NOT QP_Validate.Multival_Attr2_Context(p_LIMIT_BALANCES_rec.multival_attr2_context) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.multival_attribute2 IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.multival_attribute2 <>
            p_old_LIMIT_BALANCES_rec.multival_attribute2 OR
            p_old_LIMIT_BALANCES_rec.multival_attribute2 IS NULL )
    THEN
        IF NOT QP_Validate.Multival_Attribute2(p_LIMIT_BALANCES_rec.multival_attribute2) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.multival_attr2_value IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.multival_attr2_value <>
            p_old_LIMIT_BALANCES_rec.multival_attr2_value OR
            p_old_LIMIT_BALANCES_rec.multival_attr2_value IS NULL )
    THEN
        IF NOT QP_Validate.Multival_Attr2_Value(p_LIMIT_BALANCES_rec.multival_attr2_value) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.multival_attr2_datatype IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.multival_attr2_datatype <>
            p_old_LIMIT_BALANCES_rec.multival_attr2_datatype OR
            p_old_LIMIT_BALANCES_rec.multival_attr2_datatype IS NULL )
    THEN
        IF NOT QP_Validate.Multival_Attr2_Datatype(p_LIMIT_BALANCES_rec.multival_attr2_datatype) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.organization_attr_context IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.organization_attr_context <>
            p_old_LIMIT_BALANCES_rec.organization_attr_context OR
            p_old_LIMIT_BALANCES_rec.organization_attr_context IS NULL )
    THEN
        IF NOT QP_Validate.Organization_Attr_Context(p_LIMIT_BALANCES_rec.organization_attr_context) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.organization_attribute IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.organization_attribute <>
            p_old_LIMIT_BALANCES_rec.organization_attribute OR
            p_old_LIMIT_BALANCES_rec.organization_attribute IS NULL )
    THEN
        IF NOT QP_Validate.Organization_Attribute(p_LIMIT_BALANCES_rec.organization_attribute) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.organization_attr_value IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.organization_attr_value <>
            p_old_LIMIT_BALANCES_rec.organization_attr_value OR
            p_old_LIMIT_BALANCES_rec.organization_attr_value IS NULL )
    THEN
        IF NOT QP_Validate.Organization_Attr_Value(p_LIMIT_BALANCES_rec.organization_attr_value) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.program_application_id IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.program_application_id <>
            p_old_LIMIT_BALANCES_rec.program_application_id OR
            p_old_LIMIT_BALANCES_rec.program_application_id IS NULL )
    THEN
        IF NOT QP_Validate.Program_Application(p_LIMIT_BALANCES_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.program_id IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.program_id <>
            p_old_LIMIT_BALANCES_rec.program_id OR
            p_old_LIMIT_BALANCES_rec.program_id IS NULL )
    THEN
        IF NOT QP_Validate.Program(p_LIMIT_BALANCES_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.program_update_date IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.program_update_date <>
            p_old_LIMIT_BALANCES_rec.program_update_date OR
            p_old_LIMIT_BALANCES_rec.program_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Program_Update_Date(p_LIMIT_BALANCES_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.request_id IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.request_id <>
            p_old_LIMIT_BALANCES_rec.request_id OR
            p_old_LIMIT_BALANCES_rec.request_id IS NULL )
    THEN
        IF NOT QP_Validate.Request(p_LIMIT_BALANCES_rec.request_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMIT_BALANCES_rec.reserved_amount IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.reserved_amount <>
            p_old_LIMIT_BALANCES_rec.reserved_amount OR
            p_old_LIMIT_BALANCES_rec.reserved_amount IS NULL )
    THEN
        IF NOT QP_Validate.Reserved_Amount(p_LIMIT_BALANCES_rec.reserved_amount) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  (p_LIMIT_BALANCES_rec.attribute1 IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.attribute1 <>
            p_old_LIMIT_BALANCES_rec.attribute1 OR
            p_old_LIMIT_BALANCES_rec.attribute1 IS NULL ))
    OR  (p_LIMIT_BALANCES_rec.attribute10 IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.attribute10 <>
            p_old_LIMIT_BALANCES_rec.attribute10 OR
            p_old_LIMIT_BALANCES_rec.attribute10 IS NULL ))
    OR  (p_LIMIT_BALANCES_rec.attribute11 IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.attribute11 <>
            p_old_LIMIT_BALANCES_rec.attribute11 OR
            p_old_LIMIT_BALANCES_rec.attribute11 IS NULL ))
    OR  (p_LIMIT_BALANCES_rec.attribute12 IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.attribute12 <>
            p_old_LIMIT_BALANCES_rec.attribute12 OR
            p_old_LIMIT_BALANCES_rec.attribute12 IS NULL ))
    OR  (p_LIMIT_BALANCES_rec.attribute13 IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.attribute13 <>
            p_old_LIMIT_BALANCES_rec.attribute13 OR
            p_old_LIMIT_BALANCES_rec.attribute13 IS NULL ))
    OR  (p_LIMIT_BALANCES_rec.attribute14 IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.attribute14 <>
            p_old_LIMIT_BALANCES_rec.attribute14 OR
            p_old_LIMIT_BALANCES_rec.attribute14 IS NULL ))
    OR  (p_LIMIT_BALANCES_rec.attribute15 IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.attribute15 <>
            p_old_LIMIT_BALANCES_rec.attribute15 OR
            p_old_LIMIT_BALANCES_rec.attribute15 IS NULL ))
    OR  (p_LIMIT_BALANCES_rec.attribute2 IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.attribute2 <>
            p_old_LIMIT_BALANCES_rec.attribute2 OR
            p_old_LIMIT_BALANCES_rec.attribute2 IS NULL ))
    OR  (p_LIMIT_BALANCES_rec.attribute3 IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.attribute3 <>
            p_old_LIMIT_BALANCES_rec.attribute3 OR
            p_old_LIMIT_BALANCES_rec.attribute3 IS NULL ))
    OR  (p_LIMIT_BALANCES_rec.attribute4 IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.attribute4 <>
            p_old_LIMIT_BALANCES_rec.attribute4 OR
            p_old_LIMIT_BALANCES_rec.attribute4 IS NULL ))
    OR  (p_LIMIT_BALANCES_rec.attribute5 IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.attribute5 <>
            p_old_LIMIT_BALANCES_rec.attribute5 OR
            p_old_LIMIT_BALANCES_rec.attribute5 IS NULL ))
    OR  (p_LIMIT_BALANCES_rec.attribute6 IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.attribute6 <>
            p_old_LIMIT_BALANCES_rec.attribute6 OR
            p_old_LIMIT_BALANCES_rec.attribute6 IS NULL ))
    OR  (p_LIMIT_BALANCES_rec.attribute7 IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.attribute7 <>
            p_old_LIMIT_BALANCES_rec.attribute7 OR
            p_old_LIMIT_BALANCES_rec.attribute7 IS NULL ))
    OR  (p_LIMIT_BALANCES_rec.attribute8 IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.attribute8 <>
            p_old_LIMIT_BALANCES_rec.attribute8 OR
            p_old_LIMIT_BALANCES_rec.attribute8 IS NULL ))
    OR  (p_LIMIT_BALANCES_rec.attribute9 IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.attribute9 <>
            p_old_LIMIT_BALANCES_rec.attribute9 OR
            p_old_LIMIT_BALANCES_rec.attribute9 IS NULL ))
    OR  (p_LIMIT_BALANCES_rec.context IS NOT NULL AND
        (   p_LIMIT_BALANCES_rec.context <>
            p_old_LIMIT_BALANCES_rec.context OR
            p_old_LIMIT_BALANCES_rec.context IS NULL ))
    THEN

    --  These calls are temporarily commented out

/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_LIMIT_BALANCES_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_LIMIT_BALANCES_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_LIMIT_BALANCES_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_LIMIT_BALANCES_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_LIMIT_BALANCES_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_LIMIT_BALANCES_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_LIMIT_BALANCES_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_LIMIT_BALANCES_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_LIMIT_BALANCES_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_LIMIT_BALANCES_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_LIMIT_BALANCES_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_LIMIT_BALANCES_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_LIMIT_BALANCES_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_LIMIT_BALANCES_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_LIMIT_BALANCES_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'CONTEXT'
        ,   column_value                  => p_LIMIT_BALANCES_rec.context
        );
*/

        --  Validate descriptive flexfield.

        IF NOT QP_Validate.Desc_Flex( 'LIMIT_BALANCES' ) THEN
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
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMIT_BALANCES_rec            IN  QP_Limits_PUB.Limit_Balances_Rec_Type
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

END QP_Validate_Limit_Balances;

/
