--------------------------------------------------------
--  DDL for Package Body QP_VALIDATE_CON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_VALIDATE_CON" AS
/* $Header: QPXLCONB.pls 120.1 2005/06/08 22:00:52 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Validate_Con';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CON_rec                       IN  QP_Attributes_PUB.Con_Rec_Type
,   p_old_CON_rec                   IN  QP_Attributes_PUB.Con_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_CON_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    --  Check required attributes.

    IF  p_CON_rec.prc_context_id IS NULL
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

    /*
    if p_CON_rec.prc_context_code is not null
       and p_CON_rec.prc_context_code <> FND_API.G_MISS_CHAR
       and substr(p_CON_rec.prc_context_code,1,3) <> 'QP_' then

    oe_debug_pub.add('Total old values' || p_CON_rec.prc_context_code);
       l_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('QP','QP_WRONG_CONTEXT_CODE');
       OE_MSG_PUB.Add;
    end if;
    */

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
,   p_CON_rec                       IN  QP_Attributes_PUB.Con_Rec_Type
,   p_old_CON_rec                   IN  QP_Attributes_PUB.Con_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_CON_REC
)
IS
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate CON attributes

    IF  p_CON_rec.created_by IS NOT NULL AND
        (   p_CON_rec.created_by <>
            p_old_CON_rec.created_by OR
            p_old_CON_rec.created_by IS NULL )
    THEN
        IF NOT QP_Validate.Created_By(p_CON_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CON_rec.creation_date IS NOT NULL AND
        (   p_CON_rec.creation_date <>
            p_old_CON_rec.creation_date OR
            p_old_CON_rec.creation_date IS NULL )
    THEN
        IF NOT QP_Validate.Creation_Date(p_CON_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CON_rec.enabled_flag IS NOT NULL AND
        (   p_CON_rec.enabled_flag <>
            p_old_CON_rec.enabled_flag OR
            p_old_CON_rec.enabled_flag IS NULL )
    THEN
        IF NOT QP_Validate.Enabled(p_CON_rec.enabled_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CON_rec.last_updated_by IS NOT NULL AND
        (   p_CON_rec.last_updated_by <>
            p_old_CON_rec.last_updated_by OR
            p_old_CON_rec.last_updated_by IS NULL )
    THEN
        IF NOT QP_Validate.Last_Updated_By(p_CON_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CON_rec.last_update_date IS NOT NULL AND
        (   p_CON_rec.last_update_date <>
            p_old_CON_rec.last_update_date OR
            p_old_CON_rec.last_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Date(p_CON_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CON_rec.last_update_login IS NOT NULL AND
        (   p_CON_rec.last_update_login <>
            p_old_CON_rec.last_update_login OR
            p_old_CON_rec.last_update_login IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Login(p_CON_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CON_rec.prc_context_code IS NOT NULL AND
        (   p_CON_rec.prc_context_code <>
            p_old_CON_rec.prc_context_code OR
            p_old_CON_rec.prc_context_code IS NULL )
    THEN
        IF NOT QP_Validate.Prc_Context_code(p_CON_rec.prc_context_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CON_rec.prc_context_id IS NOT NULL AND
        (   p_CON_rec.prc_context_id <>
            p_old_CON_rec.prc_context_id OR
            p_old_CON_rec.prc_context_id IS NULL )
    THEN
        IF NOT QP_Validate.Prc_Context(p_CON_rec.prc_context_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CON_rec.prc_context_type IS NOT NULL AND
        (   p_CON_rec.prc_context_type <>
            p_old_CON_rec.prc_context_type OR
            p_old_CON_rec.prc_context_type IS NULL )
    THEN
        IF NOT QP_Validate.Prc_Context_Type(p_CON_rec.prc_context_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CON_rec.program_application_id IS NOT NULL AND
        (   p_CON_rec.program_application_id <>
            p_old_CON_rec.program_application_id OR
            p_old_CON_rec.program_application_id IS NULL )
    THEN
        IF NOT QP_Validate.Program_Application(p_CON_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CON_rec.program_id IS NOT NULL AND
        (   p_CON_rec.program_id <>
            p_old_CON_rec.program_id OR
            p_old_CON_rec.program_id IS NULL )
    THEN
        IF NOT QP_Validate.Program(p_CON_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CON_rec.program_update_date IS NOT NULL AND
        (   p_CON_rec.program_update_date <>
            p_old_CON_rec.program_update_date OR
            p_old_CON_rec.program_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Program_Update_Date(p_CON_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CON_rec.seeded_description IS NOT NULL AND
        (   p_CON_rec.seeded_description <>
            p_old_CON_rec.seeded_description OR
            p_old_CON_rec.seeded_description IS NULL )
    THEN
        IF NOT QP_Validate.Seeded_Description(p_CON_rec.seeded_description) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CON_rec.seeded_flag IS NOT NULL AND
        (   p_CON_rec.seeded_flag <>
            p_old_CON_rec.seeded_flag OR
            p_old_CON_rec.seeded_flag IS NULL )
    THEN
        IF NOT QP_Validate.Seeded(p_CON_rec.seeded_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CON_rec.seeded_prc_context_name IS NOT NULL AND
        (   p_CON_rec.seeded_prc_context_name <>
            p_old_CON_rec.seeded_prc_context_name OR
            p_old_CON_rec.seeded_prc_context_name IS NULL )
    THEN
        IF NOT QP_Validate.Seeded_Prc_Context_Name(p_CON_rec.seeded_prc_context_name) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CON_rec.user_description IS NOT NULL AND
        (   p_CON_rec.user_description <>
            p_old_CON_rec.user_description OR
            p_old_CON_rec.user_description IS NULL )
    THEN
        IF NOT QP_Validate.User_Description(p_CON_rec.user_description) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CON_rec.user_prc_context_name IS NOT NULL AND
        (   p_CON_rec.user_prc_context_name <>
            p_old_CON_rec.user_prc_context_name OR
            p_old_CON_rec.user_prc_context_name IS NULL )
    THEN
        IF NOT QP_Validate.User_Prc_Context_Name(p_CON_rec.user_prc_context_name) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  (p_CON_rec.attribute1 IS NOT NULL AND
        (   p_CON_rec.attribute1 <>
            p_old_CON_rec.attribute1 OR
            p_old_CON_rec.attribute1 IS NULL ))
    OR  (p_CON_rec.attribute10 IS NOT NULL AND
        (   p_CON_rec.attribute10 <>
            p_old_CON_rec.attribute10 OR
            p_old_CON_rec.attribute10 IS NULL ))
    OR  (p_CON_rec.attribute11 IS NOT NULL AND
        (   p_CON_rec.attribute11 <>
            p_old_CON_rec.attribute11 OR
            p_old_CON_rec.attribute11 IS NULL ))
    OR  (p_CON_rec.attribute12 IS NOT NULL AND
        (   p_CON_rec.attribute12 <>
            p_old_CON_rec.attribute12 OR
            p_old_CON_rec.attribute12 IS NULL ))
    OR  (p_CON_rec.attribute13 IS NOT NULL AND
        (   p_CON_rec.attribute13 <>
            p_old_CON_rec.attribute13 OR
            p_old_CON_rec.attribute13 IS NULL ))
    OR  (p_CON_rec.attribute14 IS NOT NULL AND
        (   p_CON_rec.attribute14 <>
            p_old_CON_rec.attribute14 OR
            p_old_CON_rec.attribute14 IS NULL ))
    OR  (p_CON_rec.attribute15 IS NOT NULL AND
        (   p_CON_rec.attribute15 <>
            p_old_CON_rec.attribute15 OR
            p_old_CON_rec.attribute15 IS NULL ))
    OR  (p_CON_rec.attribute2 IS NOT NULL AND
        (   p_CON_rec.attribute2 <>
            p_old_CON_rec.attribute2 OR
            p_old_CON_rec.attribute2 IS NULL ))
    OR  (p_CON_rec.attribute3 IS NOT NULL AND
        (   p_CON_rec.attribute3 <>
            p_old_CON_rec.attribute3 OR
            p_old_CON_rec.attribute3 IS NULL ))
    OR  (p_CON_rec.attribute4 IS NOT NULL AND
        (   p_CON_rec.attribute4 <>
            p_old_CON_rec.attribute4 OR
            p_old_CON_rec.attribute4 IS NULL ))
    OR  (p_CON_rec.attribute5 IS NOT NULL AND
        (   p_CON_rec.attribute5 <>
            p_old_CON_rec.attribute5 OR
            p_old_CON_rec.attribute5 IS NULL ))
    OR  (p_CON_rec.attribute6 IS NOT NULL AND
        (   p_CON_rec.attribute6 <>
            p_old_CON_rec.attribute6 OR
            p_old_CON_rec.attribute6 IS NULL ))
    OR  (p_CON_rec.attribute7 IS NOT NULL AND
        (   p_CON_rec.attribute7 <>
            p_old_CON_rec.attribute7 OR
            p_old_CON_rec.attribute7 IS NULL ))
    OR  (p_CON_rec.attribute8 IS NOT NULL AND
        (   p_CON_rec.attribute8 <>
            p_old_CON_rec.attribute8 OR
            p_old_CON_rec.attribute8 IS NULL ))
    OR  (p_CON_rec.attribute9 IS NOT NULL AND
        (   p_CON_rec.attribute9 <>
            p_old_CON_rec.attribute9 OR
            p_old_CON_rec.attribute9 IS NULL ))
    OR  (p_CON_rec.context IS NOT NULL AND
        (   p_CON_rec.context <>
            p_old_CON_rec.context OR
            p_old_CON_rec.context IS NULL ))
    THEN

    --  These calls are temporarily commented out

/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_CON_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_CON_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_CON_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_CON_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_CON_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_CON_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_CON_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_CON_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_CON_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_CON_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_CON_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_CON_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_CON_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_CON_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_CON_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'CONTEXT'
        ,   column_value                  => p_CON_rec.context
        );
*/

        --  Validate descriptive flexfield.

        IF NOT QP_Validate.Desc_Flex( 'CON' ) THEN
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
,   p_CON_rec                       IN  QP_Attributes_PUB.Con_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
dummy                         varchar2(1);
BEGIN

    --  Validate entity delete.

    NULL;
/*
    begin
      select 's'
      into dummy
      from qp_segments_b
      where segment_id = p_CON_rec.prc_context_id and
            rownum = 1;
       l_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('QP','QP_CANNOT_DELETE_CONTEXT');
       OE_MSG_PUB.Add;

       raise fnd_api.g_exc_error;
   exception
     when no_data_found then
       l_return_status := FND_API.G_RET_STS_SUCCESS;
   end;
*/
   x_return_status := l_return_status;

    --  Done.

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

END QP_Validate_Con;

/
