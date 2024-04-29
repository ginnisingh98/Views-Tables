--------------------------------------------------------
--  DDL for Package Body QP_VALIDATE_FNA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_VALIDATE_FNA" AS
/* $Header: QPXLFNAB.pls 120.2 2005/08/18 15:46:23 sfiresto noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Validate_Fna';

FUNCTION Check_Duplicate_Fnarea(p_pte_ss_fnarea_id varchar2,
                                p_fnarea_id       varchar2,
                                p_pte_ss_id       varchar2) RETURN BOOLEAN IS

CURSOR c_duplicate(c_p_pte_ss_fnarea_id varchar2,
                   c_p_fnarea_id       varchar2,
                   c_p_pte_ss_id       varchar2) IS
          SELECT 'DUPLICATE'
          FROM qp_sourcesystem_fnarea_map
          WHERE functional_area_id = c_p_fnarea_id
            AND pte_source_system_id = c_p_pte_ss_id
            AND pte_sourcesystem_fnarea_id <> c_p_pte_ss_fnarea_id;

l_status VARCHAR2(10);
BEGIN

  OPEN c_duplicate(p_pte_ss_fnarea_id, p_fnarea_id, p_pte_ss_id);
  FETCH c_duplicate INTO l_status;
  CLOSE c_duplicate;

  if l_status = 'DUPLICATE' then
    RETURN TRUE;
  else
    RETURN FALSE;
  end if;

END Check_Duplicate_Fnarea;

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_FNA_rec                       IN  QP_Attr_Map_PUB.Fna_Rec_Type
,   p_old_FNA_rec                   IN  QP_Attr_Map_PUB.Fna_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_FNA_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_fnarea                      VARCHAR2(80);
l_pte                         VARCHAR2(30);
l_ss                          VARCHAR2(30);
l_seed_err                    BOOLEAN := FALSE;
l_valid                       VARCHAR2(10);
BEGIN

    --  Check required attributes.

    IF  p_FNA_rec.pte_sourcesystem_fnarea_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','PTE_SOURCESYSTEM_FNAREA_ID');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    --
    --  Check rest of required attributes here.
    --

    IF  p_FNA_rec.pte_source_system_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','PTE_SOURCE_SYSTEM_ID');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_FNA_rec.functional_area_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','FUNCTIONAL_AREA_ID');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

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

    --
    --  Other Validations
    --

    -- Check for invalid functional area ID
    BEGIN
      SELECT  'VALID'
      INTO     l_valid
      FROM     mtl_default_category_sets
      WHERE    functional_area_id = p_fna_rec.functional_area_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
          select pte_code, application_short_name
          into l_pte, l_ss
          from qp_pte_source_systems
          where pte_source_system_id = p_FNA_rec.pte_source_system_id;

          FND_MESSAGE.SET_NAME('QP','QP_INVALID_FUNC_AREA');
          FND_MESSAGE.SET_TOKEN('FNID', p_FNA_rec.functional_area_id);
          FND_MESSAGE.SET_TOKEN('PTE', l_pte);
          FND_MESSAGE.SET_TOKEN('SS', l_ss);
          OE_MSG_PUB.Add;
        END IF;
    END;


    -- Check for duplicate functional areas
    IF Check_Duplicate_Fnarea(p_FNA_rec.pte_sourcesystem_fnarea_id,
                              p_FNA_rec.functional_area_id,
                              p_FNA_rec.pte_source_system_id) THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
          select pte_code, application_short_name
          into l_pte, l_ss
          from qp_pte_source_systems
          where pte_source_system_id = p_FNA_rec.pte_source_system_id;

          select functional_area_desc
          into l_fnarea
          from mtl_default_category_sets_fk_v
          where functional_area_id = p_FNA_rec.functional_area_id;

          FND_MESSAGE.SET_NAME('QP','QP_DUP_FUNC_AREA_WITHIN_PTE');
          FND_MESSAGE.SET_TOKEN('FNAREA', l_fnarea);
          FND_MESSAGE.SET_TOKEN('PTE', l_pte);
          FND_MESSAGE.SET_TOKEN('SS', l_ss);
          OE_MSG_PUB.Add;
        END IF;

    END IF;

    -- Check if not SEED DATAMERGE user
    IF NOT QP_UTIL.is_seed_user THEN
      -- Creation of seeded functional area mapping is not allowed
      IF p_FNA_rec.seeded_flag = 'Y' AND p_FNA_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN
        l_seed_err := TRUE;
      ELSIF p_FNA_rec.OPERATION = QP_GLOBALS.G_OPR_UPDATE THEN

        -- In a seeded mapping, no attributes can be changed EXCEPT disabled_flag
        IF p_old_FNA_rec.seeded_flag = 'Y' AND
           (p_FNA_rec.PTE_SOURCESYSTEM_FNAREA_ID <> p_old_FNA_rec.PTE_SOURCESYSTEM_FNAREA_ID OR
            p_FNA_rec.PTE_SOURCE_SYSTEM_ID <> p_old_FNA_rec.PTE_SOURCE_SYSTEM_ID OR
            p_FNA_rec.FUNCTIONAL_AREA_ID <> p_old_FNA_rec.FUNCTIONAL_AREA_ID OR
            p_FNA_rec.SEEDED_FLAG <> p_old_FNA_rec.SEEDED_FLAG OR
            p_FNA_rec.CONTEXT <> p_old_FNA_rec.CONTEXT OR
            p_FNA_rec.ATTRIBUTE1 <> p_old_FNA_rec.ATTRIBUTE1 OR
            p_FNA_rec.ATTRIBUTE2 <> p_old_FNA_rec.ATTRIBUTE2 OR
            p_FNA_rec.ATTRIBUTE3 <> p_old_FNA_rec.ATTRIBUTE3 OR
            p_FNA_rec.ATTRIBUTE4 <> p_old_FNA_rec.ATTRIBUTE4 OR
            p_FNA_rec.ATTRIBUTE5 <> p_old_FNA_rec.ATTRIBUTE5 OR
            p_FNA_rec.ATTRIBUTE6 <> p_old_FNA_rec.ATTRIBUTE6 OR
            p_FNA_rec.ATTRIBUTE7 <> p_old_FNA_rec.ATTRIBUTE7 OR
            p_FNA_rec.ATTRIBUTE8 <> p_old_FNA_rec.ATTRIBUTE8 OR
            p_FNA_rec.ATTRIBUTE9 <> p_old_FNA_rec.ATTRIBUTE9 OR
            p_FNA_rec.ATTRIBUTE10 <> p_old_FNA_rec.ATTRIBUTE10 OR
            p_FNA_rec.ATTRIBUTE11 <> p_old_FNA_rec.ATTRIBUTE11 OR
            p_FNA_rec.ATTRIBUTE12 <> p_old_FNA_rec.ATTRIBUTE12 OR
            p_FNA_rec.ATTRIBUTE13 <> p_old_FNA_rec.ATTRIBUTE13 OR
            p_FNA_rec.ATTRIBUTE14 <> p_old_FNA_rec.ATTRIBUTE14 OR
            p_FNA_rec.ATTRIBUTE15 <> p_old_FNA_rec.ATTRIBUTE15 OR
            p_FNA_rec.CREATED_BY <> p_old_FNA_rec.CREATED_BY OR
            p_FNA_rec.CREATION_DATE <> p_old_FNA_rec.CREATION_DATE) THEN
          l_seed_err := TRUE;

        -- Non-seeded mappings cannot be made seeded
        ELSIF p_old_FNA_rec.seeded_flag <> 'Y' AND p_FNA_rec.seeded_flag = 'Y' THEN
          l_seed_err := TRUE;
        END IF;
      END IF;


      IF l_seed_err AND OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('QP','QP_CANNOT_SEED_FUNC_AREAS');
        OE_MSG_PUB.Add;
      END IF;
    END IF;




        IF l_return_status = FND_API.G_RET_STS_ERROR THEN

           RAISE FND_API.G_EXC_ERROR;

        END IF;

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
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_FNA_rec                       IN  QP_Attr_Map_PUB.Fna_Rec_Type
,   p_old_FNA_rec                   IN  QP_Attr_Map_PUB.Fna_Rec_Type :=
                                        QP_Attr_Map_PUB.G_MISS_FNA_REC
)
IS
l_pte VARCHAR2(30);
l_ss  VARCHAR2(30);
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate FNA attributes

    IF  p_FNA_rec.created_by IS NOT NULL AND
        (   p_FNA_rec.created_by <>
            p_old_FNA_rec.created_by OR
            p_old_FNA_rec.created_by IS NULL )
    THEN
        IF NOT QP_Validate.Created_By(p_FNA_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FNA_rec.creation_date IS NOT NULL AND
        (   p_FNA_rec.creation_date <>
            p_old_FNA_rec.creation_date OR
            p_old_FNA_rec.creation_date IS NULL )
    THEN
        IF NOT QP_Validate.Creation_Date(p_FNA_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FNA_rec.enabled_flag IS NOT NULL AND
        (   p_FNA_rec.enabled_flag <>
            p_old_FNA_rec.enabled_flag OR
            p_old_FNA_rec.enabled_flag IS NULL )
    THEN
        IF NOT QP_Validate.Enabled(p_FNA_rec.enabled_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FNA_rec.functional_area_id IS NOT NULL AND
        (   p_FNA_rec.functional_area_id <>
            p_old_FNA_rec.functional_area_id OR
            p_old_FNA_rec.functional_area_id IS NULL )
    THEN
        IF NOT QP_Validate.Functional_Area(p_FNA_rec.functional_area_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FNA_rec.last_updated_by IS NOT NULL AND
        (   p_FNA_rec.last_updated_by <>
            p_old_FNA_rec.last_updated_by OR
            p_old_FNA_rec.last_updated_by IS NULL )
    THEN
        IF NOT QP_Validate.Last_Updated_By(p_FNA_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FNA_rec.last_update_date IS NOT NULL AND
        (   p_FNA_rec.last_update_date <>
            p_old_FNA_rec.last_update_date OR
            p_old_FNA_rec.last_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Date(p_FNA_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FNA_rec.last_update_login IS NOT NULL AND
        (   p_FNA_rec.last_update_login <>
            p_old_FNA_rec.last_update_login OR
            p_old_FNA_rec.last_update_login IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Login(p_FNA_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FNA_rec.program_application_id IS NOT NULL AND
        (   p_FNA_rec.program_application_id <>
            p_old_FNA_rec.program_application_id OR
            p_old_FNA_rec.program_application_id IS NULL )
    THEN
        IF NOT QP_Validate.Program_Application(p_FNA_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FNA_rec.program_id IS NOT NULL AND
        (   p_FNA_rec.program_id <>
            p_old_FNA_rec.program_id OR
            p_old_FNA_rec.program_id IS NULL )
    THEN
        IF NOT QP_Validate.Program(p_FNA_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FNA_rec.program_update_date IS NOT NULL AND
        (   p_FNA_rec.program_update_date <>
            p_old_FNA_rec.program_update_date OR
            p_old_FNA_rec.program_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Program_Update_Date(p_FNA_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FNA_rec.pte_sourcesystem_fnarea_id IS NOT NULL AND
        (   p_FNA_rec.pte_sourcesystem_fnarea_id <>
            p_old_FNA_rec.pte_sourcesystem_fnarea_id OR
            p_old_FNA_rec.pte_sourcesystem_fnarea_id IS NULL )
    THEN
        IF NOT QP_Validate.Pte_Sourcesystem_Fnarea(p_FNA_rec.pte_sourcesystem_fnarea_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FNA_rec.pte_source_system_id IS NOT NULL AND
        (   p_FNA_rec.pte_source_system_id <>
            p_old_FNA_rec.pte_source_system_id OR
            p_old_FNA_rec.pte_source_system_id IS NULL )
    THEN
        IF NOT QP_Validate.Pte_Source_System(p_FNA_rec.pte_source_system_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FNA_rec.request_id IS NOT NULL AND
        (   p_FNA_rec.request_id <>
            p_old_FNA_rec.request_id OR
            p_old_FNA_rec.request_id IS NULL )
    THEN
        IF NOT QP_Validate.Request(p_FNA_rec.request_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FNA_rec.seeded_flag IS NOT NULL AND
        (   p_FNA_rec.seeded_flag <>
            p_old_FNA_rec.seeded_flag OR
            p_old_FNA_rec.seeded_flag IS NULL )
    THEN
        IF NOT QP_Validate.Seeded(p_FNA_rec.seeded_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  (p_FNA_rec.attribute1 IS NOT NULL AND
        (   p_FNA_rec.attribute1 <>
            p_old_FNA_rec.attribute1 OR
            p_old_FNA_rec.attribute1 IS NULL ))
    OR  (p_FNA_rec.attribute10 IS NOT NULL AND
        (   p_FNA_rec.attribute10 <>
            p_old_FNA_rec.attribute10 OR
            p_old_FNA_rec.attribute10 IS NULL ))
    OR  (p_FNA_rec.attribute11 IS NOT NULL AND
        (   p_FNA_rec.attribute11 <>
            p_old_FNA_rec.attribute11 OR
            p_old_FNA_rec.attribute11 IS NULL ))
    OR  (p_FNA_rec.attribute12 IS NOT NULL AND
        (   p_FNA_rec.attribute12 <>
            p_old_FNA_rec.attribute12 OR
            p_old_FNA_rec.attribute12 IS NULL ))
    OR  (p_FNA_rec.attribute13 IS NOT NULL AND
        (   p_FNA_rec.attribute13 <>
            p_old_FNA_rec.attribute13 OR
            p_old_FNA_rec.attribute13 IS NULL ))
    OR  (p_FNA_rec.attribute14 IS NOT NULL AND
        (   p_FNA_rec.attribute14 <>
            p_old_FNA_rec.attribute14 OR
            p_old_FNA_rec.attribute14 IS NULL ))
    OR  (p_FNA_rec.attribute15 IS NOT NULL AND
        (   p_FNA_rec.attribute15 <>
            p_old_FNA_rec.attribute15 OR
            p_old_FNA_rec.attribute15 IS NULL ))
    OR  (p_FNA_rec.attribute2 IS NOT NULL AND
        (   p_FNA_rec.attribute2 <>
            p_old_FNA_rec.attribute2 OR
            p_old_FNA_rec.attribute2 IS NULL ))
    OR  (p_FNA_rec.attribute3 IS NOT NULL AND
        (   p_FNA_rec.attribute3 <>
            p_old_FNA_rec.attribute3 OR
            p_old_FNA_rec.attribute3 IS NULL ))
    OR  (p_FNA_rec.attribute4 IS NOT NULL AND
        (   p_FNA_rec.attribute4 <>
            p_old_FNA_rec.attribute4 OR
            p_old_FNA_rec.attribute4 IS NULL ))
    OR  (p_FNA_rec.attribute5 IS NOT NULL AND
        (   p_FNA_rec.attribute5 <>
            p_old_FNA_rec.attribute5 OR
            p_old_FNA_rec.attribute5 IS NULL ))
    OR  (p_FNA_rec.attribute6 IS NOT NULL AND
        (   p_FNA_rec.attribute6 <>
            p_old_FNA_rec.attribute6 OR
            p_old_FNA_rec.attribute6 IS NULL ))
    OR  (p_FNA_rec.attribute7 IS NOT NULL AND
        (   p_FNA_rec.attribute7 <>
            p_old_FNA_rec.attribute7 OR
            p_old_FNA_rec.attribute7 IS NULL ))
    OR  (p_FNA_rec.attribute8 IS NOT NULL AND
        (   p_FNA_rec.attribute8 <>
            p_old_FNA_rec.attribute8 OR
            p_old_FNA_rec.attribute8 IS NULL ))
    OR  (p_FNA_rec.attribute9 IS NOT NULL AND
        (   p_FNA_rec.attribute9 <>
            p_old_FNA_rec.attribute9 OR
            p_old_FNA_rec.attribute9 IS NULL ))
    OR  (p_FNA_rec.context IS NOT NULL AND
        (   p_FNA_rec.context <>
            p_old_FNA_rec.context OR
            p_old_FNA_rec.context IS NULL ))
    THEN

    --  These calls are temporarily commented out

/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_FNA_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_FNA_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_FNA_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_FNA_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_FNA_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_FNA_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_FNA_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_FNA_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_FNA_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_FNA_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_FNA_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_FNA_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_FNA_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_FNA_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_FNA_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'CONTEXT'
        ,   column_value                  => p_FNA_rec.context
        );
*/

        --  Validate descriptive flexfield.

        IF NOT QP_Validate.Desc_Flex( 'FNA' ) THEN
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
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_FNA_rec                       IN  QP_Attr_Map_PUB.Fna_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_fnarea                      VARCHAR2(80);
l_pte                         VARCHAR2(30);
l_ss                          VARCHAR2(30);
BEGIN

    --  Validate entity delete.

    IF p_FNA_rec.seeded_flag = 'Y' THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

        select pte_code, application_short_name
        into l_pte, l_ss
        from qp_pte_source_systems
        where pte_source_system_id = p_FNA_rec.pte_source_system_id;

        select functional_area_desc
        into l_fnarea
        from mtl_default_category_sets_fk_v
        where functional_area_id = p_FNA_rec.functional_area_id;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

          FND_MESSAGE.SET_NAME('QP', 'QP_DEL_FUNC_AREA_NOT_ALLOW');
          FND_MESSAGE.SET_TOKEN('FNAREA', l_fnarea);
          FND_MESSAGE.SET_TOKEN('PTE', l_pte);
          FND_MESSAGE.SET_TOKEN('SS', l_ss);
          OE_MSG_PUB.Add;
        END IF;
    END IF;

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

END QP_Validate_Fna;

/
