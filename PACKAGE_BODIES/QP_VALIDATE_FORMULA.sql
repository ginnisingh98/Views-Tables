--------------------------------------------------------
--  DDL for Package Body QP_VALIDATE_FORMULA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_VALIDATE_FORMULA" AS
/* $Header: QPXLPRFB.pls 120.1 2005/06/08 06:08:44 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Validate_Formula';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_FORMULA_rec                   IN  QP_Price_Formula_PUB.Formula_Rec_Type
,   p_old_FORMULA_rec               IN  QP_Price_Formula_PUB.Formula_Rec_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_count                       NUMBER := 0;
l_cursor                      INTEGER;
l_check_formula               VARCHAR2(1);                             --sfiresto
l_dummy_operand_tbl           QP_FORMULA_RULES_PVT.t_Operand_Tbl_Type; --sfiresto
l_dummy_number                NUMBER;                                  --sfiresto

BEGIN

oe_debug_pub.add('Entering proc Entity in Formula Validation Pkg');
    --  Check required attributes.

    IF  p_FORMULA_rec.price_formula_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_formula');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    --
    --  Check rest of required attributes here.
    --

    IF  p_FORMULA_rec.name IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','name');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_FORMULA_rec.formula IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','formula');
            OE_MSG_PUB.Add;

        END IF;

    END IF;


    --  Return Error if a required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Give warning message that dynamic formula package generater must be run if it is a new Formula

    IF  (p_FORMULA_rec.operation = QP_GLOBALS.G_OPR_CREATE) or
        (p_FORMULA_rec.operation = QP_GLOBALS.G_OPR_UPDATE)
    THEN

      --sfiresto (Check dynamic formula package for formulas, not database)

      QP_BUILD_FORMULA_RULES.Get_Formula_Values( p_FORMULA_rec.formula,
                                                 l_dummy_operand_tbl,
                                                 'S',
                                                 l_dummy_number,
                                                 l_check_formula);
      IF l_check_formula <> 'T' THEN
        FND_MESSAGE.SET_NAME('QP', 'QP_BUILD_FORMULA_PACKAGE');
        FND_MESSAGE.SET_TOKEN('PROGRAM_NAME', 'Build Formula Package');
        OE_MSG_PUB.Add;
      END IF;

    END IF;

    --
    --  Check if Formula is a valid arithmetic expression
    --

    BEGIN

    EXECUTE IMMEDIATE 'SELECT ' || p_FORMULA_rec.formula || ' FROM DUAL ';
				 --Raises an exception if expression not valid
    EXCEPTION

       WHEN OTHERS THEN
         l_return_status := FND_API.G_RET_STS_ERROR;

         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
         THEN

             FND_MESSAGE.SET_NAME('QP','QP_INVALID_FORMULA');
             OE_MSG_PUB.Add;

         END IF;
    END;

    --
    --  Check conditionally required attributes here.
    --

    --
    --  Check for duplicates here.
    --

    IF  p_FORMULA_rec.name IS NOT NULL AND
        (   p_FORMULA_rec.name <>
            p_old_FORMULA_rec.name OR
            p_old_FORMULA_rec.name IS NULL ) THEN

        SELECT count(*)
        INTO   l_count
        FROM   qp_price_formulas_vl
        WHERE  name = p_FORMULA_rec.name;

        IF l_count > 0
        THEN

            l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

                FND_MESSAGE.SET_NAME('QP','QP_DUPLICATE_ATTRIBUTE');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','name');
                OE_MSG_PUB.Add;

            END IF;

        END IF;

    END IF; -- if 'name' column is modified or entered

    --
    --  Validate attribute dependencies here.
    --

    IF  nvl(p_FORMULA_rec.start_date_active,
		  TO_DATE('01-01-1951', 'MM-DD-YYYY')) >
        nvl(p_FORMULA_rec.end_date_active,
		  TO_DATE('12-31-9999', 'MM-DD-YYYY'))
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_STRT_DATE_BFR_END_DATE');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    --  Return Error if dependent attribute is invalid.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;


    --  Done validating entity

    x_return_status := l_return_status;

oe_debug_pub.add('Leaving proc Entity in Formula Validation Pkg');
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
,   p_FORMULA_rec                   IN  QP_Price_Formula_PUB.Formula_Rec_Type
,   p_old_FORMULA_rec               IN  QP_Price_Formula_PUB.Formula_Rec_Type :=
                                        QP_Price_Formula_PUB.G_MISS_FORMULA_REC
)
IS
BEGIN

oe_debug_pub.add('Entering proc Attributes in Formula Validation Pkg');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate FORMULA attributes

    IF  p_FORMULA_rec.created_by IS NOT NULL AND
        (   p_FORMULA_rec.created_by <>
            p_old_FORMULA_rec.created_by OR
            p_old_FORMULA_rec.created_by IS NULL )
    THEN
        IF NOT QP_Validate.Created_By(p_FORMULA_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_rec.creation_date IS NOT NULL AND
        (   p_FORMULA_rec.creation_date <>
            p_old_FORMULA_rec.creation_date OR
            p_old_FORMULA_rec.creation_date IS NULL )
    THEN
        IF NOT QP_Validate.Creation_Date(p_FORMULA_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_rec.description IS NOT NULL AND
        (   p_FORMULA_rec.description <>
            p_old_FORMULA_rec.description OR
            p_old_FORMULA_rec.description IS NULL )
    THEN
        IF NOT QP_Validate.Description(p_FORMULA_rec.description) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_rec.end_date_active IS NOT NULL AND
        (   p_FORMULA_rec.end_date_active <>
            p_old_FORMULA_rec.end_date_active OR
            p_old_FORMULA_rec.end_date_active IS NULL )
    THEN
        IF NOT QP_Validate.End_Date_Active(p_FORMULA_rec.end_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_rec.formula IS NOT NULL AND
        (   p_FORMULA_rec.formula <>
            p_old_FORMULA_rec.formula OR
            p_old_FORMULA_rec.formula IS NULL )
    THEN
        IF NOT QP_Validate.Formula(p_FORMULA_rec.formula) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_rec.last_updated_by IS NOT NULL AND
        (   p_FORMULA_rec.last_updated_by <>
            p_old_FORMULA_rec.last_updated_by OR
            p_old_FORMULA_rec.last_updated_by IS NULL )
    THEN
        IF NOT QP_Validate.Last_Updated_By(p_FORMULA_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_rec.last_update_date IS NOT NULL AND
        (   p_FORMULA_rec.last_update_date <>
            p_old_FORMULA_rec.last_update_date OR
            p_old_FORMULA_rec.last_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Date(p_FORMULA_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_rec.last_update_login IS NOT NULL AND
        (   p_FORMULA_rec.last_update_login <>
            p_old_FORMULA_rec.last_update_login OR
            p_old_FORMULA_rec.last_update_login IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Login(p_FORMULA_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_rec.name IS NOT NULL AND
        (   p_FORMULA_rec.name <>
            p_old_FORMULA_rec.name OR
            p_old_FORMULA_rec.name IS NULL )
    THEN
        IF NOT QP_Validate.Name(p_FORMULA_rec.name) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_rec.price_formula_id IS NOT NULL AND
        (   p_FORMULA_rec.price_formula_id <>
            p_old_FORMULA_rec.price_formula_id OR
            p_old_FORMULA_rec.price_formula_id IS NULL )
    THEN
        IF NOT QP_Validate.Price_Formula(p_FORMULA_rec.price_formula_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_FORMULA_rec.start_date_active IS NOT NULL AND
        (   p_FORMULA_rec.start_date_active <>
            p_old_FORMULA_rec.start_date_active OR
            p_old_FORMULA_rec.start_date_active IS NULL )
    THEN
        IF NOT QP_Validate.Start_Date_Active(p_FORMULA_rec.start_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  (p_FORMULA_rec.attribute1 IS NOT NULL AND
        (   p_FORMULA_rec.attribute1 <>
            p_old_FORMULA_rec.attribute1 OR
            p_old_FORMULA_rec.attribute1 IS NULL ))
    OR  (p_FORMULA_rec.attribute10 IS NOT NULL AND
        (   p_FORMULA_rec.attribute10 <>
            p_old_FORMULA_rec.attribute10 OR
            p_old_FORMULA_rec.attribute10 IS NULL ))
    OR  (p_FORMULA_rec.attribute11 IS NOT NULL AND
        (   p_FORMULA_rec.attribute11 <>
            p_old_FORMULA_rec.attribute11 OR
            p_old_FORMULA_rec.attribute11 IS NULL ))
    OR  (p_FORMULA_rec.attribute12 IS NOT NULL AND
        (   p_FORMULA_rec.attribute12 <>
            p_old_FORMULA_rec.attribute12 OR
            p_old_FORMULA_rec.attribute12 IS NULL ))
    OR  (p_FORMULA_rec.attribute13 IS NOT NULL AND
        (   p_FORMULA_rec.attribute13 <>
            p_old_FORMULA_rec.attribute13 OR
            p_old_FORMULA_rec.attribute13 IS NULL ))
    OR  (p_FORMULA_rec.attribute14 IS NOT NULL AND
        (   p_FORMULA_rec.attribute14 <>
            p_old_FORMULA_rec.attribute14 OR
            p_old_FORMULA_rec.attribute14 IS NULL ))
    OR  (p_FORMULA_rec.attribute15 IS NOT NULL AND
        (   p_FORMULA_rec.attribute15 <>
            p_old_FORMULA_rec.attribute15 OR
            p_old_FORMULA_rec.attribute15 IS NULL ))
    OR  (p_FORMULA_rec.attribute2 IS NOT NULL AND
        (   p_FORMULA_rec.attribute2 <>
            p_old_FORMULA_rec.attribute2 OR
            p_old_FORMULA_rec.attribute2 IS NULL ))
    OR  (p_FORMULA_rec.attribute3 IS NOT NULL AND
        (   p_FORMULA_rec.attribute3 <>
            p_old_FORMULA_rec.attribute3 OR
            p_old_FORMULA_rec.attribute3 IS NULL ))
    OR  (p_FORMULA_rec.attribute4 IS NOT NULL AND
        (   p_FORMULA_rec.attribute4 <>
            p_old_FORMULA_rec.attribute4 OR
            p_old_FORMULA_rec.attribute4 IS NULL ))
    OR  (p_FORMULA_rec.attribute5 IS NOT NULL AND
        (   p_FORMULA_rec.attribute5 <>
            p_old_FORMULA_rec.attribute5 OR
            p_old_FORMULA_rec.attribute5 IS NULL ))
    OR  (p_FORMULA_rec.attribute6 IS NOT NULL AND
        (   p_FORMULA_rec.attribute6 <>
            p_old_FORMULA_rec.attribute6 OR
            p_old_FORMULA_rec.attribute6 IS NULL ))
    OR  (p_FORMULA_rec.attribute7 IS NOT NULL AND
        (   p_FORMULA_rec.attribute7 <>
            p_old_FORMULA_rec.attribute7 OR
            p_old_FORMULA_rec.attribute7 IS NULL ))
    OR  (p_FORMULA_rec.attribute8 IS NOT NULL AND
        (   p_FORMULA_rec.attribute8 <>
            p_old_FORMULA_rec.attribute8 OR
            p_old_FORMULA_rec.attribute8 IS NULL ))
    OR  (p_FORMULA_rec.attribute9 IS NOT NULL AND
        (   p_FORMULA_rec.attribute9 <>
            p_old_FORMULA_rec.attribute9 OR
            p_old_FORMULA_rec.attribute9 IS NULL ))
    OR  (p_FORMULA_rec.context IS NOT NULL AND
        (   p_FORMULA_rec.context <>
            p_old_FORMULA_rec.context OR
            p_old_FORMULA_rec.context IS NULL ))
    THEN

    --  These calls are temporarily commented out

/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_FORMULA_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_FORMULA_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_FORMULA_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_FORMULA_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_FORMULA_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_FORMULA_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_FORMULA_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_FORMULA_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_FORMULA_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_FORMULA_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_FORMULA_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_FORMULA_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_FORMULA_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_FORMULA_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_FORMULA_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'CONTEXT'
        ,   column_value                  => p_FORMULA_rec.context
        );
*/

        --  Validate descriptive flexfield.

        IF NOT QP_Validate.Desc_Flex( 'FORMULA' ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;

    --  Done validating attributes

oe_debug_pub.add('Leaving proc Attributes in Formula Validation Pkg');
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
,   p_FORMULA_rec                   IN  QP_Price_Formula_PUB.Formula_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

oe_debug_pub.add('Entering proc Entity_Delete in Formula Validation Pkg');
    --  Validate entity delete.

    NULL;

    --  Done.

    x_return_status := l_return_status;

oe_debug_pub.add('Leaving proc Entity_Delete in Formula Validation Pkg');
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

END QP_Validate_Formula;

/
