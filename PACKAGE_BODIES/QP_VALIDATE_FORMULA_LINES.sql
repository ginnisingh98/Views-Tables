--------------------------------------------------------
--  DDL for Package Body QP_VALIDATE_FORMULA_LINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_VALIDATE_FORMULA_LINES" AS
/* $Header: QPXLPFLB.pls 120.1 2005/06/08 23:46:11 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Validate_Formula_Lines';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_FORMULA_LINES_rec             IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type
,   p_old_FORMULA_LINES_rec         IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_LINES_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_count                       NUMBER := 0;
l_qp_status                   VARCHAR2(1);

BEGIN

oe_debug_pub.add('Entering proc Entity of Formula Lines Validation Pkg');

    -- Check if only Basic Pricing installed. If so then Formula Line types
    -- 'PLL', 'FUNC' and 'LP' are not allowed. They are permitted only when
    -- Advanced Pricing is installed.

    l_qp_status := QP_UTIL.get_qp_status;

    IF  l_qp_status = 'S' AND
        p_FORMULA_LINES_rec.formula_line_type_code IN ('PLL', 'FUNC', 'LP')
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MESSAGE.SET_NAME('QP', 'QP_BASIC_PRICING_UNAVAILABLE');
        OE_MSG_PUB.Add;
	   RAISE FND_API.G_EXC_ERROR;

    END IF;


    --  Check required attributes.

    IF  p_FORMULA_LINES_rec.price_formula_line_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_formula_line');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    --
    --  Check rest of required attributes here.
    --

    IF  p_FORMULA_LINES_rec.price_formula_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_formula');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_FORMULA_LINES_rec.formula_line_type_code IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_formula_line_type');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_FORMULA_LINES_rec.step_number IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','step_number');
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

    IF  p_FORMULA_LINES_rec.formula_line_type_code = 'NUM' THEN
                             -- Formula Line Type is Numeric Constant
        IF p_FORMULA_LINES_rec.numeric_constant IS NULL THEN
           l_return_status := FND_API.G_RET_STS_ERROR;

           IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
           THEN

               FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','numeric_constant');
               OE_MSG_PUB.Add;

           END IF;

	   END IF;

    ELSIF  p_FORMULA_LINES_rec.formula_line_type_code = 'PLL' THEN
                             -- Formula Line Type is Price List Line
        IF p_FORMULA_LINES_rec.price_list_line_id IS NULL THEN
           l_return_status := FND_API.G_RET_STS_ERROR;

           IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
           THEN

               FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_list_line');
               OE_MSG_PUB.Add;

           END IF;

	   END IF;

    ELSIF  p_FORMULA_LINES_rec.formula_line_type_code = 'ML' THEN
                             -- Formula Line Type is Factor(Modifier) List
      /*IF p_FORMULA_LINES_rec.price_modifier_list_id IS NULL THEN
           l_return_status := FND_API.G_RET_STS_ERROR;

           IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
           THEN

               FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_modifier_list');
               OE_MSG_PUB.Add;

           END IF;

	   END IF;*/
	   NULL;

    ELSIF  p_FORMULA_LINES_rec.formula_line_type_code = 'PRA' THEN
                             -- Formula Line Type is Pricing Attribute
        IF p_FORMULA_LINES_rec.pricing_attribute_context IS NULL THEN
           l_return_status := FND_API.G_RET_STS_ERROR;

           IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
           THEN

               FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute_context');
               OE_MSG_PUB.Add;

           END IF;

	   END IF;

        IF p_FORMULA_LINES_rec.pricing_attribute IS NULL THEN
           l_return_status := FND_API.G_RET_STS_ERROR;

           IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
           THEN

               FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pricing_attribute');
               OE_MSG_PUB.Add;

           END IF;

	   END IF;

    -- mkarya for bug 1906545, new formula_line_type_code 'MV' has been added
    ELSIF  p_FORMULA_LINES_rec.formula_line_type_code NOT IN ('FUNC','LP','MV') THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_FORMULA_LINE_TYPE');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    --
    --  Check for duplicates here.
    --

    IF  p_FORMULA_LINES_rec.step_number IS NOT NULL AND
        (   p_FORMULA_LINES_rec.step_number <>
            p_old_FORMULA_LINES_rec.step_number OR
            p_old_FORMULA_LINES_rec.step_number IS NULL ) THEN

        SELECT count(*)
        INTO   l_count
        FROM   qp_price_formula_lines
        WHERE  step_number = p_FORMULA_LINES_rec.step_number
	   AND    price_formula_id = p_FORMULA_LINES_rec.price_formula_id;

        IF l_count > 0
        THEN

            l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

                FND_MESSAGE.SET_NAME('QP','QP_DUPLICATE_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','step_number');
                OE_MSG_PUB.Add;

            END IF;

        END IF;

    END IF; -- Check if modified or newly added step number already exists


/**** bug 4049775  ******************************************************/
 IF p_FORMULA_LINES_rec.pricing_attribute_context IS NOT NULL AND p_FORMULA_LINES_rec.pricing_attribute IS NOT NULL THEN
       DECLARE
	l_type VARCHAR2(1);
       BEGIN
	select user_format_type into l_type
	from qp_segments_b b, qp_prc_contexts_b c
	where c.prc_context_code=p_FORMULA_LINES_rec.pricing_attribute_context
	and b.SEGMENT_MAPPING_COLUMN = p_FORMULA_LINES_rec.pricing_attribute
	and b.prc_context_id = c.prc_context_id;

        IF l_type <> 'N' THEN

	     l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

                FND_MESSAGE.SET_NAME('QP','QP_INVALID_NUM_ATTRIBUTE');
                OE_MSG_PUB.Add;

            END IF;

        END IF;
       END;
    END IF;

    --  Return Error if a required attribute is missing or invalid.
    --  or if duplicates exist

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --
    --  Validate attribute dependencies here.
    --


    --  Done validating entity

    x_return_status := l_return_status;




oe_debug_pub.add('Leaving proc Entity of Formula Lines Validation Pkg');
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
,   p_FORMULA_LINES_rec             IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type
,   p_old_FORMULA_LINES_rec         IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_LINES_REC
)
IS
BEGIN

oe_debug_pub.add('Entering proc Attributes of Formula Lines Validation Pkg');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate FORMULA_LINES attributes

    IF  p_FORMULA_LINES_rec.created_by IS NOT NULL AND
        (   p_FORMULA_LINES_rec.created_by <>
            p_old_FORMULA_LINES_rec.created_by OR
            p_old_FORMULA_LINES_rec.created_by IS NULL )
    THEN
        IF NOT QP_Validate.Created_By(p_FORMULA_LINES_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_LINES_rec.creation_date IS NOT NULL AND
        (   p_FORMULA_LINES_rec.creation_date <>
            p_old_FORMULA_LINES_rec.creation_date OR
            p_old_FORMULA_LINES_rec.creation_date IS NULL )
    THEN
        IF NOT QP_Validate.Creation_Date(p_FORMULA_LINES_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_LINES_rec.end_date_active IS NOT NULL AND
        (   p_FORMULA_LINES_rec.end_date_active <>
            p_old_FORMULA_LINES_rec.end_date_active OR
            p_old_FORMULA_LINES_rec.end_date_active IS NULL )
    THEN
        IF NOT QP_Validate.End_Date_Active(p_FORMULA_LINES_rec.end_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_LINES_rec.last_updated_by IS NOT NULL AND
        (   p_FORMULA_LINES_rec.last_updated_by <>
            p_old_FORMULA_LINES_rec.last_updated_by OR
            p_old_FORMULA_LINES_rec.last_updated_by IS NULL )
    THEN
        IF NOT QP_Validate.Last_Updated_By(p_FORMULA_LINES_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_LINES_rec.last_update_date IS NOT NULL AND
        (   p_FORMULA_LINES_rec.last_update_date <>
            p_old_FORMULA_LINES_rec.last_update_date OR
            p_old_FORMULA_LINES_rec.last_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Date(p_FORMULA_LINES_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_LINES_rec.last_update_login IS NOT NULL AND
        (   p_FORMULA_LINES_rec.last_update_login <>
            p_old_FORMULA_LINES_rec.last_update_login OR
            p_old_FORMULA_LINES_rec.last_update_login IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Login(p_FORMULA_LINES_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_LINES_rec.numeric_constant IS NOT NULL AND
        (   p_FORMULA_LINES_rec.numeric_constant <>
            p_old_FORMULA_LINES_rec.numeric_constant OR
            p_old_FORMULA_LINES_rec.numeric_constant IS NULL )
    THEN
        IF NOT QP_Validate.Numeric_Constant(p_FORMULA_LINES_rec.numeric_constant) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    --POSCO change.
    IF  p_FORMULA_LINES_rec.reqd_flag IS NOT NULL AND
        (   p_FORMULA_LINES_rec.reqd_flag <>
            p_old_FORMULA_LINES_rec.reqd_flag OR
            p_old_FORMULA_LINES_rec.reqd_flag IS NULL )
    THEN
        IF NOT QP_Validate.Reqd_Flag(p_FORMULA_LINES_rec.reqd_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_LINES_rec.price_formula_id IS NOT NULL AND
        (   p_FORMULA_LINES_rec.price_formula_id <>
            p_old_FORMULA_LINES_rec.price_formula_id OR
            p_old_FORMULA_LINES_rec.price_formula_id IS NULL )
    THEN
        IF NOT QP_Validate.Price_Formula(p_FORMULA_LINES_rec.price_formula_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_LINES_rec.price_formula_line_id IS NOT NULL AND
        (   p_FORMULA_LINES_rec.price_formula_line_id <>
            p_old_FORMULA_LINES_rec.price_formula_line_id OR
            p_old_FORMULA_LINES_rec.price_formula_line_id IS NULL )
    THEN
        IF NOT QP_Validate.Price_Formula_Line(p_FORMULA_LINES_rec.price_formula_line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_LINES_rec.formula_line_type_code IS NOT NULL AND
        (   p_FORMULA_LINES_rec.formula_line_type_code <>
            p_old_FORMULA_LINES_rec.formula_line_type_code OR
            p_old_FORMULA_LINES_rec.formula_line_type_code IS NULL )
    THEN
        IF NOT QP_Validate.Price_Formula_Line_Type(p_FORMULA_LINES_rec.formula_line_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_LINES_rec.price_list_line_id IS NOT NULL AND
        (   p_FORMULA_LINES_rec.price_list_line_id <>
            p_old_FORMULA_LINES_rec.price_list_line_id OR
            p_old_FORMULA_LINES_rec.price_list_line_id IS NULL )
    THEN
        IF NOT QP_Validate.Price_List_Line(p_FORMULA_LINES_rec.price_list_line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_LINES_rec.price_modifier_list_id IS NOT NULL AND
        (   p_FORMULA_LINES_rec.price_modifier_list_id <>
            p_old_FORMULA_LINES_rec.price_modifier_list_id OR
            p_old_FORMULA_LINES_rec.price_modifier_list_id IS NULL )
    THEN
        IF NOT QP_Validate.Price_Modifier_List(p_FORMULA_LINES_rec.price_modifier_list_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_LINES_rec.pricing_attribute IS NOT NULL AND
        (   p_FORMULA_LINES_rec.pricing_attribute <>
            p_old_FORMULA_LINES_rec.pricing_attribute OR
            p_old_FORMULA_LINES_rec.pricing_attribute IS NULL )
    THEN
        IF NOT QP_Validate.Pricing_Attribute(p_FORMULA_LINES_rec.pricing_attribute) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_LINES_rec.pricing_attribute_context IS NOT NULL AND
        (   p_FORMULA_LINES_rec.pricing_attribute_context <>
            p_old_FORMULA_LINES_rec.pricing_attribute_context OR
            p_old_FORMULA_LINES_rec.pricing_attribute_context IS NULL )
    THEN
        IF NOT QP_Validate.Pricing_Attribute_Context(p_FORMULA_LINES_rec.pricing_attribute_context) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_LINES_rec.start_date_active IS NOT NULL AND
        (   p_FORMULA_LINES_rec.start_date_active <>
            p_old_FORMULA_LINES_rec.start_date_active OR
            p_old_FORMULA_LINES_rec.start_date_active IS NULL )
    THEN
        IF NOT QP_Validate.Start_Date_Active(p_FORMULA_LINES_rec.start_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_LINES_rec.step_number IS NOT NULL AND
        (   p_FORMULA_LINES_rec.step_number <>
            p_old_FORMULA_LINES_rec.step_number OR
            p_old_FORMULA_LINES_rec.step_number IS NULL )
    THEN
        IF NOT QP_Validate.Step_Number(p_FORMULA_LINES_rec.step_number) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  (p_FORMULA_LINES_rec.attribute1 IS NOT NULL AND
        (   p_FORMULA_LINES_rec.attribute1 <>
            p_old_FORMULA_LINES_rec.attribute1 OR
            p_old_FORMULA_LINES_rec.attribute1 IS NULL ))
    OR  (p_FORMULA_LINES_rec.attribute10 IS NOT NULL AND
        (   p_FORMULA_LINES_rec.attribute10 <>
            p_old_FORMULA_LINES_rec.attribute10 OR
            p_old_FORMULA_LINES_rec.attribute10 IS NULL ))
    OR  (p_FORMULA_LINES_rec.attribute11 IS NOT NULL AND
        (   p_FORMULA_LINES_rec.attribute11 <>
            p_old_FORMULA_LINES_rec.attribute11 OR
            p_old_FORMULA_LINES_rec.attribute11 IS NULL ))
    OR  (p_FORMULA_LINES_rec.attribute12 IS NOT NULL AND
        (   p_FORMULA_LINES_rec.attribute12 <>
            p_old_FORMULA_LINES_rec.attribute12 OR
            p_old_FORMULA_LINES_rec.attribute12 IS NULL ))
    OR  (p_FORMULA_LINES_rec.attribute13 IS NOT NULL AND
        (   p_FORMULA_LINES_rec.attribute13 <>
            p_old_FORMULA_LINES_rec.attribute13 OR
            p_old_FORMULA_LINES_rec.attribute13 IS NULL ))
    OR  (p_FORMULA_LINES_rec.attribute14 IS NOT NULL AND
        (   p_FORMULA_LINES_rec.attribute14 <>
            p_old_FORMULA_LINES_rec.attribute14 OR
            p_old_FORMULA_LINES_rec.attribute14 IS NULL ))
    OR  (p_FORMULA_LINES_rec.attribute15 IS NOT NULL AND
        (   p_FORMULA_LINES_rec.attribute15 <>
            p_old_FORMULA_LINES_rec.attribute15 OR
            p_old_FORMULA_LINES_rec.attribute15 IS NULL ))
    OR  (p_FORMULA_LINES_rec.attribute2 IS NOT NULL AND
        (   p_FORMULA_LINES_rec.attribute2 <>
            p_old_FORMULA_LINES_rec.attribute2 OR
            p_old_FORMULA_LINES_rec.attribute2 IS NULL ))
    OR  (p_FORMULA_LINES_rec.attribute3 IS NOT NULL AND
        (   p_FORMULA_LINES_rec.attribute3 <>
            p_old_FORMULA_LINES_rec.attribute3 OR
            p_old_FORMULA_LINES_rec.attribute3 IS NULL ))
    OR  (p_FORMULA_LINES_rec.attribute4 IS NOT NULL AND
        (   p_FORMULA_LINES_rec.attribute4 <>
            p_old_FORMULA_LINES_rec.attribute4 OR
            p_old_FORMULA_LINES_rec.attribute4 IS NULL ))
    OR  (p_FORMULA_LINES_rec.attribute5 IS NOT NULL AND
        (   p_FORMULA_LINES_rec.attribute5 <>
            p_old_FORMULA_LINES_rec.attribute5 OR
            p_old_FORMULA_LINES_rec.attribute5 IS NULL ))
    OR  (p_FORMULA_LINES_rec.attribute6 IS NOT NULL AND
        (   p_FORMULA_LINES_rec.attribute6 <>
            p_old_FORMULA_LINES_rec.attribute6 OR
            p_old_FORMULA_LINES_rec.attribute6 IS NULL ))
    OR  (p_FORMULA_LINES_rec.attribute7 IS NOT NULL AND
        (   p_FORMULA_LINES_rec.attribute7 <>
            p_old_FORMULA_LINES_rec.attribute7 OR
            p_old_FORMULA_LINES_rec.attribute7 IS NULL ))
    OR  (p_FORMULA_LINES_rec.attribute8 IS NOT NULL AND
        (   p_FORMULA_LINES_rec.attribute8 <>
            p_old_FORMULA_LINES_rec.attribute8 OR
            p_old_FORMULA_LINES_rec.attribute8 IS NULL ))
    OR  (p_FORMULA_LINES_rec.attribute9 IS NOT NULL AND
        (   p_FORMULA_LINES_rec.attribute9 <>
            p_old_FORMULA_LINES_rec.attribute9 OR
            p_old_FORMULA_LINES_rec.attribute9 IS NULL ))
    OR  (p_FORMULA_LINES_rec.context IS NOT NULL AND
        (   p_FORMULA_LINES_rec.context <>
            p_old_FORMULA_LINES_rec.context OR
            p_old_FORMULA_LINES_rec.context IS NULL ))
    THEN

    --  These calls are temporarily commented out

/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_FORMULA_LINES_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_FORMULA_LINES_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_FORMULA_LINES_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_FORMULA_LINES_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_FORMULA_LINES_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_FORMULA_LINES_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_FORMULA_LINES_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_FORMULA_LINES_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_FORMULA_LINES_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_FORMULA_LINES_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_FORMULA_LINES_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_FORMULA_LINES_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_FORMULA_LINES_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_FORMULA_LINES_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_FORMULA_LINES_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'CONTEXT'
        ,   column_value                  => p_FORMULA_LINES_rec.context
        );
*/

        --  Validate descriptive flexfield.

        IF NOT QP_Validate.Desc_Flex( 'FORMULA_LINES' ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;

    --  Done validating attributes

oe_debug_pub.add('Leaving proc Attributes of Formula Lines Validation Pkg');
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
,   p_FORMULA_LINES_rec             IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

oe_debug_pub.add('Entering proc Entity_Delete of Formula Lines Validation Pkg');
    --  Validate entity delete.

    NULL;

    --  Done.

    x_return_status := l_return_status;

oe_debug_pub.add('Leaving proc Entity_Delete of Formula Lines Validation Pkg');
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

END QP_Validate_Formula_Lines;

/
