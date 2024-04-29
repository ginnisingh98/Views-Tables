--------------------------------------------------------
--  DDL for Package Body QP_VALIDATE_SEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_VALIDATE_SEG" AS
/* $Header: QPXLSEGB.pls 120.2 2005/08/03 07:36:49 srashmi noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Validate_Seg';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
,   p_old_SEG_rec                   IN  QP_Attributes_PUB.Seg_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_SEG_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    --  Check required attributes.

    IF  p_SEG_rec.segment_id IS NULL
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
,   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
,   p_old_SEG_rec                   IN  QP_Attributes_PUB.Seg_Rec_Type :=
                                        QP_Attributes_PUB.G_MISS_SEG_REC
)
IS
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate SEG attributes

    IF  p_SEG_rec.availability_in_basic IS NOT NULL AND
        (   p_SEG_rec.availability_in_basic <>
            p_old_SEG_rec.availability_in_basic OR
            p_old_SEG_rec.availability_in_basic IS NULL )
    THEN
        IF NOT QP_Validate.Availability_In_Basic(p_SEG_rec.availability_in_basic) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SEG_rec.created_by IS NOT NULL AND
        (   p_SEG_rec.created_by <>
            p_old_SEG_rec.created_by OR
            p_old_SEG_rec.created_by IS NULL )
    THEN
        IF NOT QP_Validate.Created_By(p_SEG_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SEG_rec.creation_date IS NOT NULL AND
        (   p_SEG_rec.creation_date <>
            p_old_SEG_rec.creation_date OR
            p_old_SEG_rec.creation_date IS NULL )
    THEN
        IF NOT QP_Validate.Creation_Date(p_SEG_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SEG_rec.last_updated_by IS NOT NULL AND
        (   p_SEG_rec.last_updated_by <>
            p_old_SEG_rec.last_updated_by OR
            p_old_SEG_rec.last_updated_by IS NULL )
    THEN
        IF NOT QP_Validate.Last_Updated_By(p_SEG_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SEG_rec.last_update_date IS NOT NULL AND
        (   p_SEG_rec.last_update_date <>
            p_old_SEG_rec.last_update_date OR
            p_old_SEG_rec.last_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Date(p_SEG_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SEG_rec.last_update_login IS NOT NULL AND
        (   p_SEG_rec.last_update_login <>
            p_old_SEG_rec.last_update_login OR
            p_old_SEG_rec.last_update_login IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Login(p_SEG_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SEG_rec.prc_context_id IS NOT NULL AND
        (   p_SEG_rec.prc_context_id <>
            p_old_SEG_rec.prc_context_id OR
            p_old_SEG_rec.prc_context_id IS NULL )
    THEN
        IF NOT QP_Validate.Prc_Context(p_SEG_rec.prc_context_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SEG_rec.program_application_id IS NOT NULL AND
        (   p_SEG_rec.program_application_id <>
            p_old_SEG_rec.program_application_id OR
            p_old_SEG_rec.program_application_id IS NULL )
    THEN
        IF NOT QP_Validate.Program_Application(p_SEG_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SEG_rec.program_id IS NOT NULL AND
        (   p_SEG_rec.program_id <>
            p_old_SEG_rec.program_id OR
            p_old_SEG_rec.program_id IS NULL )
    THEN
        IF NOT QP_Validate.Program(p_SEG_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SEG_rec.program_update_date IS NOT NULL AND
        (   p_SEG_rec.program_update_date <>
            p_old_SEG_rec.program_update_date OR
            p_old_SEG_rec.program_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Program_Update_Date(p_SEG_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SEG_rec.seeded_flag IS NOT NULL AND
        (   p_SEG_rec.seeded_flag <>
            p_old_SEG_rec.seeded_flag OR
            p_old_SEG_rec.seeded_flag IS NULL )
    THEN
        IF NOT QP_Validate.Seeded(p_SEG_rec.seeded_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SEG_rec.seeded_format_type IS NOT NULL AND
        (   p_SEG_rec.seeded_format_type <>
            p_old_SEG_rec.seeded_format_type OR
            p_old_SEG_rec.seeded_format_type IS NULL )
    THEN
        IF NOT QP_Validate.Seeded_Format_Type(p_SEG_rec.seeded_format_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SEG_rec.seeded_precedence IS NOT NULL AND
        (   p_SEG_rec.seeded_precedence <>
            p_old_SEG_rec.seeded_precedence OR
            p_old_SEG_rec.seeded_precedence IS NULL )
    THEN
        IF NOT QP_Validate.Seeded_Precedence(p_SEG_rec.seeded_precedence) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SEG_rec.seeded_segment_name IS NOT NULL AND
        (   p_SEG_rec.seeded_segment_name <>
            p_old_SEG_rec.seeded_segment_name OR
            p_old_SEG_rec.seeded_segment_name IS NULL )
    THEN
        IF NOT QP_Validate.Seeded_Segment_Name(p_SEG_rec.seeded_segment_name) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SEG_rec.seeded_valueset_id IS NOT NULL AND
        (   p_SEG_rec.seeded_valueset_id <>
            p_old_SEG_rec.seeded_valueset_id OR
            p_old_SEG_rec.seeded_valueset_id IS NULL )
    THEN
        IF NOT QP_Validate.Seeded_Valueset(p_SEG_rec.seeded_valueset_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SEG_rec.segment_code IS NOT NULL AND
        (   p_SEG_rec.segment_code <>
            p_old_SEG_rec.segment_code OR
            p_old_SEG_rec.segment_code IS NULL )
    THEN
        IF NOT QP_Validate.Segment_code(p_SEG_rec.segment_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SEG_rec.segment_id IS NOT NULL AND
        (   p_SEG_rec.segment_id <>
            p_old_SEG_rec.segment_id OR
            p_old_SEG_rec.segment_id IS NULL )
    THEN
        IF NOT QP_Validate.Segment(p_SEG_rec.segment_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    -- Added Application_Id : Abhijit
    IF  p_SEG_rec.application_id IS NOT NULL AND
        (   p_SEG_rec.application_id <>
            p_old_SEG_rec.application_id OR
            p_old_SEG_rec.application_id IS NULL )
    THEN
        IF NOT QP_Validate.application_id(p_SEG_rec.application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SEG_rec.segment_mapping_column IS NOT NULL AND
        (   p_SEG_rec.segment_mapping_column <>
            p_old_SEG_rec.segment_mapping_column OR
            p_old_SEG_rec.segment_mapping_column IS NULL )
    THEN
        IF NOT QP_Validate.Segment_Mapping_Column(p_SEG_rec.segment_mapping_column) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SEG_rec.user_format_type IS NOT NULL AND
        (   p_SEG_rec.user_format_type <>
            p_old_SEG_rec.user_format_type OR
            p_old_SEG_rec.user_format_type IS NULL )
    THEN
        IF NOT QP_Validate.User_Format_Type(p_SEG_rec.user_format_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SEG_rec.user_precedence IS NOT NULL AND
        (   p_SEG_rec.user_precedence <>
            p_old_SEG_rec.user_precedence OR
            p_old_SEG_rec.user_precedence IS NULL )
    THEN
        IF NOT QP_Validate.User_Precedence(p_SEG_rec.user_precedence) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SEG_rec.user_segment_name IS NOT NULL AND
        (   p_SEG_rec.user_segment_name <>
            p_old_SEG_rec.user_segment_name OR
            p_old_SEG_rec.user_segment_name IS NULL )
    THEN
        IF NOT QP_Validate.User_Segment_Name(p_SEG_rec.user_segment_name) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SEG_rec.user_valueset_id IS NOT NULL AND
        (   p_SEG_rec.user_valueset_id <>
            p_old_SEG_rec.user_valueset_id OR
            p_old_SEG_rec.user_valueset_id IS NULL )
    THEN
        IF NOT QP_Validate.User_Valueset(p_SEG_rec.user_valueset_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_SEG_rec.seeded_description IS NOT NULL AND
        (   p_SEG_rec.seeded_description <>
            p_old_SEG_rec.seeded_description OR
            p_old_SEG_rec.seeded_description IS NULL )
    THEN
             IF NOT QP_Validate.Seeded_Description_Seg(p_SEG_rec.seeded_description)  THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
             END IF;
    END IF;

    IF  p_SEG_rec.user_description IS NOT NULL AND
        (   p_SEG_rec.user_description <>
            p_old_SEG_rec.user_description OR
            p_old_SEG_rec.user_description IS NULL )
   THEN
             IF NOT QP_Validate.User_Description_Seg(p_SEG_rec.user_description)
             THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
             END IF;
   END IF;

    IF  p_SEG_rec.required_flag IS NOT NULL AND
        (   p_SEG_rec.required_flag <>
            p_old_SEG_rec.required_flag OR
            p_old_SEG_rec.required_flag IS NULL )
    THEN
        IF NOT QP_Validate.required_flag(p_SEG_rec.required_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
 -- Added for TCA
    IF  p_SEG_rec.party_hierarchy_enabled_flag IS NOT NULL AND
        (   p_SEG_rec.party_hierarchy_enabled_flag <>
            p_old_SEG_rec.party_hierarchy_enabled_flag OR
            p_old_SEG_rec.party_hierarchy_enabled_flag IS NULL )
    THEN
        IF NOT QP_Validate.party_hierarchy_enabled_flag(p_SEG_rec.party_hierarchy_enabled_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  (p_SEG_rec.attribute1 IS NOT NULL AND
        (   p_SEG_rec.attribute1 <>
            p_old_SEG_rec.attribute1 OR
            p_old_SEG_rec.attribute1 IS NULL ))
    OR  (p_SEG_rec.attribute10 IS NOT NULL AND
        (   p_SEG_rec.attribute10 <>
            p_old_SEG_rec.attribute10 OR
            p_old_SEG_rec.attribute10 IS NULL ))
    OR  (p_SEG_rec.attribute11 IS NOT NULL AND
        (   p_SEG_rec.attribute11 <>
            p_old_SEG_rec.attribute11 OR
            p_old_SEG_rec.attribute11 IS NULL ))
    OR  (p_SEG_rec.attribute12 IS NOT NULL AND
        (   p_SEG_rec.attribute12 <>
            p_old_SEG_rec.attribute12 OR
            p_old_SEG_rec.attribute12 IS NULL ))
    OR  (p_SEG_rec.attribute13 IS NOT NULL AND
        (   p_SEG_rec.attribute13 <>
            p_old_SEG_rec.attribute13 OR
            p_old_SEG_rec.attribute13 IS NULL ))
    OR  (p_SEG_rec.attribute14 IS NOT NULL AND
        (   p_SEG_rec.attribute14 <>
            p_old_SEG_rec.attribute14 OR
            p_old_SEG_rec.attribute14 IS NULL ))
    OR  (p_SEG_rec.attribute15 IS NOT NULL AND
        (   p_SEG_rec.attribute15 <>
            p_old_SEG_rec.attribute15 OR
            p_old_SEG_rec.attribute15 IS NULL ))
    OR  (p_SEG_rec.attribute2 IS NOT NULL AND
        (   p_SEG_rec.attribute2 <>
            p_old_SEG_rec.attribute2 OR
            p_old_SEG_rec.attribute2 IS NULL ))
    OR  (p_SEG_rec.attribute3 IS NOT NULL AND
        (   p_SEG_rec.attribute3 <>
            p_old_SEG_rec.attribute3 OR
            p_old_SEG_rec.attribute3 IS NULL ))
    OR  (p_SEG_rec.attribute4 IS NOT NULL AND
        (   p_SEG_rec.attribute4 <>
            p_old_SEG_rec.attribute4 OR
            p_old_SEG_rec.attribute4 IS NULL ))
    OR  (p_SEG_rec.attribute5 IS NOT NULL AND
        (   p_SEG_rec.attribute5 <>
            p_old_SEG_rec.attribute5 OR
            p_old_SEG_rec.attribute5 IS NULL ))
    OR  (p_SEG_rec.attribute6 IS NOT NULL AND
        (   p_SEG_rec.attribute6 <>
            p_old_SEG_rec.attribute6 OR
            p_old_SEG_rec.attribute6 IS NULL ))
    OR  (p_SEG_rec.attribute7 IS NOT NULL AND
        (   p_SEG_rec.attribute7 <>
            p_old_SEG_rec.attribute7 OR
            p_old_SEG_rec.attribute7 IS NULL ))
    OR  (p_SEG_rec.attribute8 IS NOT NULL AND
        (   p_SEG_rec.attribute8 <>
            p_old_SEG_rec.attribute8 OR
            p_old_SEG_rec.attribute8 IS NULL ))
    OR  (p_SEG_rec.attribute9 IS NOT NULL AND
        (   p_SEG_rec.attribute9 <>
            p_old_SEG_rec.attribute9 OR
            p_old_SEG_rec.attribute9 IS NULL ))
    OR  (p_SEG_rec.context IS NOT NULL AND
        (   p_SEG_rec.context <>
            p_old_SEG_rec.context OR
            p_old_SEG_rec.context IS NULL ))
    THEN

    --  These calls are temporarily commented out

/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_SEG_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_SEG_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_SEG_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_SEG_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_SEG_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_SEG_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_SEG_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_SEG_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_SEG_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_SEG_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_SEG_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_SEG_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_SEG_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_SEG_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_SEG_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'CONTEXT'
        ,   column_value                  => p_SEG_rec.context
        );
*/

        --  Validate descriptive flexfield.

        IF NOT QP_Validate.Desc_Flex( 'SEG' ) THEN
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
,   p_SEG_rec                       IN  QP_Attributes_PUB.Seg_Rec_Type
)
IS
l_context_code      varchar2(30);
is_attribute_used   varchar2(1) := 'N';
l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN
    --  Validate entity delete.
  begin
    select prc_context_code
    into l_context_code
    from qp_prc_contexts_b
    where prc_context_id = p_SEG_rec.prc_context_id;
  exception
    when no_data_found then
      x_return_status := l_return_status;
      return;
  end;
  --
  if is_attribute_used = 'N' then
   if  l_context_code is not null and p_SEG_rec.segment_mapping_column is not null then
    begin
        SELECT 'Y' into is_attribute_used
      from qp_pricing_attributes
      where product_attribute_context = l_context_code and
            product_attribute = p_SEG_rec.segment_mapping_column and
            product_attribute_context is not null and
            product_attribute is not null and
            rownum =1
      UNION
         SELECT 'Y'
        from qp_pricing_attributes
        where  pricing_attribute_context = l_context_code and
               pricing_attribute = p_SEG_rec.segment_mapping_column and
               pricing_attribute_context is not null and
               pricing_attribute is not null and
               rownum = 1;
    exception
      when no_data_found then
        null;
    end;
   end if;
  end if;
  --
  if is_attribute_used = 'N' then
    begin
      select 'Y'
      into is_attribute_used
      from qp_qualifiers
      where qualifier_context = l_context_code and
            qualifier_attribute = p_SEG_rec.segment_mapping_column and
            rownum = 1;
    exception
      when no_data_found then
        null;
    end;
  end if;
  --
  if is_attribute_used = 'N' then
    begin
      select 'Y'
      into is_attribute_used
      from qp_limits
      where (nvl(multival_attr1_context,'x') = nvl(l_context_code,'y') and
             nvl(multival_attribute1,'x') = nvl(p_SEG_rec.segment_mapping_column,'y')) or
            (nvl(multival_attr2_context,'x') = nvl(l_context_code,'y') and
            nvl(multival_attribute2,'x') = nvl(p_SEG_rec.segment_mapping_column,'y')) and
            rownum = 1;
    exception
      when no_data_found then
        null;
    end;
  end if;
  --
  if is_attribute_used = 'N' then
    begin
      select 'Y'
      into is_attribute_used
      from qp_limit_attributes
      where limit_attribute_context = l_context_code and
            limit_attribute = p_SEG_rec.segment_mapping_column and
            rownum = 1;
    exception
      when no_data_found then
        null;
    end;
  end if;
  --
  if is_attribute_used = 'Y' then
    l_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('QP','QP_CANNOT_DELETE_SEGMENT');
    OE_MSG_PUB.Add;
    raise fnd_api.g_exc_error;
  end if;
  --
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

END QP_Validate_Seg;

/
