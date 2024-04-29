--------------------------------------------------------
--  DDL for Package Body QP_VALIDATE_SOU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_VALIDATE_SOU" AS
/* $Header: QPXLSOUB.pls 120.1 2005/06/08 21:26:26 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Validate_Sou';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
,   p_old_SOU_rec                   IN  QP_Attr_Map_PUB.Sou_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SOU_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    --  Check required attributes.

    IF  p_SOU_rec.attribute_sourcing_id IS NULL
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
,   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
,   p_old_SOU_rec                   IN  QP_Attr_Map_PUB.Sou_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_SOU_REC
)
IS
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate SOU attributes

    IF  p_SOU_rec.attribute_sourcing_id IS NOT NULL AND
        (   p_SOU_rec.attribute_sourcing_id <>
            p_old_SOU_rec.attribute_sourcing_id OR
            p_old_SOU_rec.attribute_sourcing_id IS NULL )
    THEN
        IF NOT QP_Validate.Attribute_Sourcing(p_SOU_rec.attribute_sourcing_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SOU_rec.attribute_sourcing_level IS NOT NULL AND
        (   p_SOU_rec.attribute_sourcing_level <>
            p_old_SOU_rec.attribute_sourcing_level OR
            p_old_SOU_rec.attribute_sourcing_level IS NULL )
    THEN
        IF NOT QP_Validate.Attribute_Sourcing_Level(p_SOU_rec.attribute_sourcing_level) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SOU_rec.application_id IS NOT NULL AND
        (   p_SOU_rec.application_id <>
            p_old_SOU_rec.application_id OR
            p_old_SOU_rec.application_id IS NULL )
    THEN
        IF NOT QP_Validate.application_id(p_SOU_rec.application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SOU_rec.created_by IS NOT NULL AND
        (   p_SOU_rec.created_by <>
            p_old_SOU_rec.created_by OR
            p_old_SOU_rec.created_by IS NULL )
    THEN
        IF NOT QP_Validate.Created_By(p_SOU_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SOU_rec.creation_date IS NOT NULL AND
        (   p_SOU_rec.creation_date <>
            p_old_SOU_rec.creation_date OR
            p_old_SOU_rec.creation_date IS NULL )
    THEN
        IF NOT QP_Validate.Creation_Date(p_SOU_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SOU_rec.enabled_flag IS NOT NULL AND
        (   p_SOU_rec.enabled_flag <>
            p_old_SOU_rec.enabled_flag OR
            p_old_SOU_rec.enabled_flag IS NULL )
    THEN
        IF NOT QP_Validate.Enabled(p_SOU_rec.enabled_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SOU_rec.last_updated_by IS NOT NULL AND
        (   p_SOU_rec.last_updated_by <>
            p_old_SOU_rec.last_updated_by OR
            p_old_SOU_rec.last_updated_by IS NULL )
    THEN
        IF NOT QP_Validate.Last_Updated_By(p_SOU_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SOU_rec.last_update_date IS NOT NULL AND
        (   p_SOU_rec.last_update_date <>
            p_old_SOU_rec.last_update_date OR
            p_old_SOU_rec.last_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Date(p_SOU_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SOU_rec.last_update_login IS NOT NULL AND
        (   p_SOU_rec.last_update_login <>
            p_old_SOU_rec.last_update_login OR
            p_old_SOU_rec.last_update_login IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Login(p_SOU_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SOU_rec.program_application_id IS NOT NULL AND
        (   p_SOU_rec.program_application_id <>
            p_old_SOU_rec.program_application_id OR
            p_old_SOU_rec.program_application_id IS NULL )
    THEN
        IF NOT QP_Validate.Program_Application(p_SOU_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SOU_rec.program_id IS NOT NULL AND
        (   p_SOU_rec.program_id <>
            p_old_SOU_rec.program_id OR
            p_old_SOU_rec.program_id IS NULL )
    THEN
        IF NOT QP_Validate.Program(p_SOU_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SOU_rec.program_update_date IS NOT NULL AND
        (   p_SOU_rec.program_update_date <>
            p_old_SOU_rec.program_update_date OR
            p_old_SOU_rec.program_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Program_Update_Date(p_SOU_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SOU_rec.request_type_code IS NOT NULL AND
        (   p_SOU_rec.request_type_code <>
            p_old_SOU_rec.request_type_code OR
            p_old_SOU_rec.request_type_code IS NULL )
    THEN
        IF NOT QP_Validate.Request_Type(p_SOU_rec.request_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SOU_rec.seeded_flag IS NOT NULL AND
        (   p_SOU_rec.seeded_flag <>
            p_old_SOU_rec.seeded_flag OR
            p_old_SOU_rec.seeded_flag IS NULL )
    THEN
        IF NOT QP_Validate.Seeded(p_SOU_rec.seeded_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SOU_rec.seeded_sourcing_type IS NOT NULL AND
        (   p_SOU_rec.seeded_sourcing_type <>
            p_old_SOU_rec.seeded_sourcing_type OR
            p_old_SOU_rec.seeded_sourcing_type IS NULL )
    THEN
        IF NOT QP_Validate.Seeded_Sourcing_Type(p_SOU_rec.seeded_sourcing_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SOU_rec.seeded_value_string IS NOT NULL AND
        (   p_SOU_rec.seeded_value_string <>
            p_old_SOU_rec.seeded_value_string OR
            p_old_SOU_rec.seeded_value_string IS NULL )
    THEN
        IF NOT QP_Validate.Seeded_Value_String(p_SOU_rec.seeded_value_string) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SOU_rec.segment_id IS NOT NULL AND
        (   p_SOU_rec.segment_id <>
            p_old_SOU_rec.segment_id OR
            p_old_SOU_rec.segment_id IS NULL )
    THEN
        IF NOT QP_Validate.Segment(p_SOU_rec.segment_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SOU_rec.user_sourcing_type IS NOT NULL AND
        (   p_SOU_rec.user_sourcing_type <>
            p_old_SOU_rec.user_sourcing_type OR
            p_old_SOU_rec.user_sourcing_type IS NULL )
    THEN
        IF NOT QP_Validate.User_Sourcing_Type(p_SOU_rec.user_sourcing_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SOU_rec.user_value_string IS NOT NULL AND
        (   p_SOU_rec.user_value_string <>
            p_old_SOU_rec.user_value_string OR
            p_old_SOU_rec.user_value_string IS NULL )
    THEN
        IF NOT QP_Validate.User_Value_String(p_SOU_rec.user_value_string) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  (p_SOU_rec.attribute1 IS NOT NULL AND
        (   p_SOU_rec.attribute1 <>
            p_old_SOU_rec.attribute1 OR
            p_old_SOU_rec.attribute1 IS NULL ))
    OR  (p_SOU_rec.attribute10 IS NOT NULL AND
        (   p_SOU_rec.attribute10 <>
            p_old_SOU_rec.attribute10 OR
            p_old_SOU_rec.attribute10 IS NULL ))
    OR  (p_SOU_rec.attribute11 IS NOT NULL AND
        (   p_SOU_rec.attribute11 <>
            p_old_SOU_rec.attribute11 OR
            p_old_SOU_rec.attribute11 IS NULL ))
    OR  (p_SOU_rec.attribute12 IS NOT NULL AND
        (   p_SOU_rec.attribute12 <>
            p_old_SOU_rec.attribute12 OR
            p_old_SOU_rec.attribute12 IS NULL ))
    OR  (p_SOU_rec.attribute13 IS NOT NULL AND
        (   p_SOU_rec.attribute13 <>
            p_old_SOU_rec.attribute13 OR
            p_old_SOU_rec.attribute13 IS NULL ))
    OR  (p_SOU_rec.attribute14 IS NOT NULL AND
        (   p_SOU_rec.attribute14 <>
            p_old_SOU_rec.attribute14 OR
            p_old_SOU_rec.attribute14 IS NULL ))
    OR  (p_SOU_rec.attribute15 IS NOT NULL AND
        (   p_SOU_rec.attribute15 <>
            p_old_SOU_rec.attribute15 OR
            p_old_SOU_rec.attribute15 IS NULL ))
    OR  (p_SOU_rec.attribute2 IS NOT NULL AND
        (   p_SOU_rec.attribute2 <>
            p_old_SOU_rec.attribute2 OR
            p_old_SOU_rec.attribute2 IS NULL ))
    OR  (p_SOU_rec.attribute3 IS NOT NULL AND
        (   p_SOU_rec.attribute3 <>
            p_old_SOU_rec.attribute3 OR
            p_old_SOU_rec.attribute3 IS NULL ))
    OR  (p_SOU_rec.attribute4 IS NOT NULL AND
        (   p_SOU_rec.attribute4 <>
            p_old_SOU_rec.attribute4 OR
            p_old_SOU_rec.attribute4 IS NULL ))
    OR  (p_SOU_rec.attribute5 IS NOT NULL AND
        (   p_SOU_rec.attribute5 <>
            p_old_SOU_rec.attribute5 OR
            p_old_SOU_rec.attribute5 IS NULL ))
    OR  (p_SOU_rec.attribute6 IS NOT NULL AND
        (   p_SOU_rec.attribute6 <>
            p_old_SOU_rec.attribute6 OR
            p_old_SOU_rec.attribute6 IS NULL ))
    OR  (p_SOU_rec.attribute7 IS NOT NULL AND
        (   p_SOU_rec.attribute7 <>
            p_old_SOU_rec.attribute7 OR
            p_old_SOU_rec.attribute7 IS NULL ))
    OR  (p_SOU_rec.attribute8 IS NOT NULL AND
        (   p_SOU_rec.attribute8 <>
            p_old_SOU_rec.attribute8 OR
            p_old_SOU_rec.attribute8 IS NULL ))
    OR  (p_SOU_rec.attribute9 IS NOT NULL AND
        (   p_SOU_rec.attribute9 <>
            p_old_SOU_rec.attribute9 OR
            p_old_SOU_rec.attribute9 IS NULL ))
    OR  (p_SOU_rec.context IS NOT NULL AND
        (   p_SOU_rec.context <>
            p_old_SOU_rec.context OR
            p_old_SOU_rec.context IS NULL ))
    THEN

    --  These calls are temporarily commented out

/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_SOU_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_SOU_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_SOU_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_SOU_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_SOU_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_SOU_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_SOU_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_SOU_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_SOU_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_SOU_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_SOU_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_SOU_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_SOU_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_SOU_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_SOU_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'CONTEXT'
        ,   column_value                  => p_SOU_rec.context
        );
*/

        --  Validate descriptive flexfield.

        IF NOT QP_Validate.Desc_Flex( 'SOU' ) THEN
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
,   p_SOU_rec                       IN  QP_Attr_Map_PUB.Sou_Rec_Type
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

END QP_Validate_Sou;

/
