--------------------------------------------------------
--  DDL for Package Body QP_VALIDATE_CURR_LISTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_VALIDATE_CURR_LISTS" AS
/* $Header: QPXLCURB.pls 120.1 2005/06/08 22:08:46 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Validate_Curr_Lists';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type
,   p_old_CURR_LISTS_rec            IN  QP_Currency_PUB.Curr_Lists_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_LISTS_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_dummy_c                     VARCHAR2(1);
BEGIN

    -- oe_debug_pub.add('VALIDATIONS: Inside Header L Package');

    --  Check required attributes.

    IF  p_CURR_LISTS_rec.currency_header_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency_header_id');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    --
    --  Check rest of required attributes here.
    --
    -- Below validations Added by Sunil Pandey
    -- Validate Header records' base_currency_code
    BEGIN
        -- oe_debug_pub.add('VALIDATE Header records base_currency_code');

        SELECT 'X'
        INTO   l_dummy_c
        FROM   fnd_currencies_vl
        WHERE  enabled_flag = 'Y'
        and    currency_flag = 'Y'
        and    currency_code = p_CURR_LISTS_rec.base_currency_code
        and    trunc(sysdate) between nvl(start_date_active,trunc(sysdate))
        and    nvl(end_date_active,trunc(sysdate));

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('QP','QP_INVALID_CURRENCY');
        OE_MSG_PUB.Add;

    END;

    -- Validate header records' base_markup_operator
    IF (p_CURR_LISTS_rec.base_markup_operator IS NOT NULL and
	p_CURR_LISTS_rec.base_markup_operator <> FND_API.G_MISS_CHAR)
    THEN
       BEGIN
          -- oe_debug_pub.add('VALIDATE Headers base_markup_operator');

          SELECT 'X'
          INTO l_dummy_c
          FROM qp_lookups
          WHERE lookup_type = 'MARKUP_OPERATOR' and
          lookup_code = p_CURR_LISTS_rec.base_markup_operator and
	  enabled_flag = 'Y' and
	  trunc(sysdate) between
	  nvl(start_date_active, trunc(sysdate)) and nvl(end_date_active, trunc(sysdate));

       EXCEPTION
       WHEN NO_DATA_FOUND THEN
          -- oe_debug_pub.add('ERROR: Base Markup_Operator is Invalid');
          l_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('QP','QP_INVALID_MARKUP_OPRTR'); -- CHANGE MESG_CODE
          FND_MESSAGE.SET_TOKEN('MARKUP_OPERATOR',p_CURR_LISTS_rec.base_markup_operator);
          OE_MSG_PUB.Add;

       END;
    END IF;

    -- Validate header records' base_markup_formula
    IF (p_CURR_LISTS_rec.base_markup_formula_id IS NOT NULL and
	p_CURR_LISTS_rec.base_markup_formula_id <> FND_API.G_MISS_NUM)
    THEN
       BEGIN
          -- oe_debug_pub.add('VALIDATE Headers base_markup_formula');

	  /*
          SELECT 'X'
          INTO l_dummy_c
          FROM qp_price_formulas_vl
          WHERE trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
          and nvl(end_date_active, trunc(sysdate))
          and price_formula_id = p_CURR_LISTS_rec.base_markup_formula_id;
	  */

	  -- Only those formulas which do not have a line component of type_code = 'PLL' can
	  -- be attached to a multi-currency list
          SELECT 'X'
          INTO l_dummy_c
          FROM qp_price_formulas_vl fh
          WHERE trunc(sysdate) between nvl(fh.start_date_active, trunc(sysdate))
	  and nvl(fh.end_date_active, trunc(sysdate))
          and fh.price_formula_id = p_CURR_LISTS_rec.base_markup_formula_id
          and  not exists (Select 'x'
                           From qp_price_formula_lines fl
                           Where fl.price_formula_id = fh.price_formula_id
                           and fl.PRICE_FORMULA_LINE_TYPE_CODE = 'PLL'
                           and trunc(sysdate) between nvl(fl.start_date_active, trunc(sysdate))
			       and nvl(fl.end_date_active, trunc(sysdate)));

       EXCEPTION
       WHEN NO_DATA_FOUND THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('QP','QP_FORMULA_NOT_FOUND');
          OE_MSG_PUB.Add;

       END;
    END IF;

    -- Validate header records' conditional columns
    -- Markup value or formula should be present if operator is present
    IF ((p_CURR_LISTS_rec.base_markup_operator IS NOT NULL and
	 p_CURR_LISTS_rec.base_markup_operator <> FND_API.G_MISS_CHAR) AND
	(p_CURR_LISTS_rec.base_markup_formula_id IS NULL AND
	 p_CURR_LISTS_rec.base_markup_value IS NULL)
       )
    THEN
       -- oe_debug_pub.add('ERROR: Markup Formula or Value should be provided if Markup Operator is present');
       l_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('QP','QP_FRML_OR_VAL_REQD');  -- CHANGE MESG_CODE
       OE_MSG_PUB.Add;
    END IF;

    -- Markup Operator should be present if either value or formula is present
    IF ((p_CURR_LISTS_rec.base_markup_operator IS NULL) AND
	(p_CURR_LISTS_rec.base_markup_formula_id IS NOT NULL OR
	 p_CURR_LISTS_rec.base_markup_value IS NOT NULL)
       )
    THEN
       -- oe_debug_pub.add('ERROR: Markup Formula or Value can be provided only if Markup Operator is present');
       l_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('QP','QP_MARKUP_OPRTR_REQD'); -- CHANGE MESG_CODE
       OE_MSG_PUB.Add;
    END IF;

    -- Validate rounding factor precision
    IF  p_CURR_LISTS_rec.base_rounding_factor IS NOT NULL AND
        p_CURR_LISTS_rec.base_currency_code IS NOT NULL THEN
           IF NOT QP_Validate.Rounding_Factor(p_CURR_LISTS_rec.base_rounding_factor,
                                              p_CURR_LISTS_rec.base_currency_code) THEN
               oe_debug_pub.add('QPXLCURB.ENTITY base rounding_factor error occured');
               l_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
    END IF;
   -- Bug 2293974 - rounding factor is mandatory
     If (p_CURR_LISTS_rec.base_rounding_factor is NULL  or
         p_CURR_LISTS_rec.base_rounding_factor = FND_API.G_MISS_NUM )
     then
         l_return_status := FND_API.G_RET_STS_ERROR;

         FND_MESSAGE.SET_NAME('QP','QP_RNDG_FACTOR_REQD');
         oe_msg_pub.add;

     end if;
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
,   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type
,   p_old_CURR_LISTS_rec            IN  QP_Currency_PUB.Curr_Lists_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_LISTS_REC
)
IS
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate CURR_LISTS attributes

    IF  p_CURR_LISTS_rec.base_currency_code IS NOT NULL AND
        (   p_CURR_LISTS_rec.base_currency_code <>
            p_old_CURR_LISTS_rec.base_currency_code OR
            p_old_CURR_LISTS_rec.base_currency_code IS NULL )
    THEN
        IF NOT QP_Validate.Base_Currency(p_CURR_LISTS_rec.base_currency_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_LISTS_rec.created_by IS NOT NULL AND
        (   p_CURR_LISTS_rec.created_by <>
            p_old_CURR_LISTS_rec.created_by OR
            p_old_CURR_LISTS_rec.created_by IS NULL )
    THEN
        IF NOT QP_Validate.Created_By(p_CURR_LISTS_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_LISTS_rec.creation_date IS NOT NULL AND
        (   p_CURR_LISTS_rec.creation_date <>
            p_old_CURR_LISTS_rec.creation_date OR
            p_old_CURR_LISTS_rec.creation_date IS NULL )
    THEN
        IF NOT QP_Validate.Creation_Date(p_CURR_LISTS_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_LISTS_rec.currency_header_id IS NOT NULL AND
        (   p_CURR_LISTS_rec.currency_header_id <>
            p_old_CURR_LISTS_rec.currency_header_id OR
            p_old_CURR_LISTS_rec.currency_header_id IS NULL )
    THEN
        IF NOT QP_Validate.Currency_Header(p_CURR_LISTS_rec.currency_header_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_LISTS_rec.description IS NOT NULL AND
        (   p_CURR_LISTS_rec.description <>
            p_old_CURR_LISTS_rec.description OR
            p_old_CURR_LISTS_rec.description IS NULL )
    THEN
        IF NOT QP_Validate.Description(p_CURR_LISTS_rec.description) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_LISTS_rec.last_updated_by IS NOT NULL AND
        (   p_CURR_LISTS_rec.last_updated_by <>
            p_old_CURR_LISTS_rec.last_updated_by OR
            p_old_CURR_LISTS_rec.last_updated_by IS NULL )
    THEN
        IF NOT QP_Validate.Last_Updated_By(p_CURR_LISTS_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_LISTS_rec.last_update_date IS NOT NULL AND
        (   p_CURR_LISTS_rec.last_update_date <>
            p_old_CURR_LISTS_rec.last_update_date OR
            p_old_CURR_LISTS_rec.last_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Date(p_CURR_LISTS_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_LISTS_rec.last_update_login IS NOT NULL AND
        (   p_CURR_LISTS_rec.last_update_login <>
            p_old_CURR_LISTS_rec.last_update_login OR
            p_old_CURR_LISTS_rec.last_update_login IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Login(p_CURR_LISTS_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_LISTS_rec.name IS NOT NULL AND
        (   p_CURR_LISTS_rec.name <>
            p_old_CURR_LISTS_rec.name OR
            p_old_CURR_LISTS_rec.name IS NULL )
    THEN
        IF NOT QP_Validate.Name(p_CURR_LISTS_rec.name) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_LISTS_rec.program_application_id IS NOT NULL AND
        (   p_CURR_LISTS_rec.program_application_id <>
            p_old_CURR_LISTS_rec.program_application_id OR
            p_old_CURR_LISTS_rec.program_application_id IS NULL )
    THEN
        IF NOT QP_Validate.Program_Application(p_CURR_LISTS_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_LISTS_rec.program_id IS NOT NULL AND
        (   p_CURR_LISTS_rec.program_id <>
            p_old_CURR_LISTS_rec.program_id OR
            p_old_CURR_LISTS_rec.program_id IS NULL )
    THEN
        IF NOT QP_Validate.Program(p_CURR_LISTS_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_LISTS_rec.program_update_date IS NOT NULL AND
        (   p_CURR_LISTS_rec.program_update_date <>
            p_old_CURR_LISTS_rec.program_update_date OR
            p_old_CURR_LISTS_rec.program_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Program_Update_Date(p_CURR_LISTS_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_LISTS_rec.request_id IS NOT NULL AND
        (   p_CURR_LISTS_rec.request_id <>
            p_old_CURR_LISTS_rec.request_id OR
            p_old_CURR_LISTS_rec.request_id IS NULL )
    THEN
        IF NOT QP_Validate.Request(p_CURR_LISTS_rec.request_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_LISTS_rec.base_rounding_factor IS NOT NULL AND
        (   p_CURR_LISTS_rec.base_rounding_factor <>
            p_old_CURR_LISTS_rec.base_rounding_factor OR
            p_old_CURR_LISTS_rec.base_rounding_factor IS NULL )
    THEN
        IF NOT QP_Validate.base_rounding_factor(p_CURR_LISTS_rec.base_rounding_factor) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_LISTS_rec.base_markup_operator IS NOT NULL AND
        (   p_CURR_LISTS_rec.base_markup_operator <>
            p_old_CURR_LISTS_rec.base_markup_operator OR
            p_old_CURR_LISTS_rec.base_markup_operator IS NULL )
    THEN
        -- oe_debug_pub.add('ERROR: in Attributes procedure of L package for base_markup_operator');
        IF NOT QP_Validate.base_markup_operator(p_CURR_LISTS_rec.base_markup_operator) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_LISTS_rec.base_markup_value IS NOT NULL AND
        (   p_CURR_LISTS_rec.base_markup_value <>
            p_old_CURR_LISTS_rec.base_markup_value OR
            p_old_CURR_LISTS_rec.base_markup_value IS NULL )
    THEN
        IF NOT QP_Validate.base_markup_value(p_CURR_LISTS_rec.base_markup_value) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_LISTS_rec.base_markup_formula_id IS NOT NULL AND
        (   p_CURR_LISTS_rec.base_markup_formula_id <>
            p_old_CURR_LISTS_rec.base_markup_formula_id OR
            p_old_CURR_LISTS_rec.base_markup_formula_id IS NULL )
    THEN
        IF NOT QP_Validate.base_markup_formula(p_CURR_LISTS_rec.base_markup_formula_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;





/* Commented by Sunil
    IF  p_CURR_LISTS_rec.row_id IS NOT NULL AND
        (   p_CURR_LISTS_rec.row_id <>
            p_old_CURR_LISTS_rec.row_id OR
            p_old_CURR_LISTS_rec.row_id IS NULL )
    THEN
        IF NOT QP_Validate.Row(p_CURR_LISTS_rec.row_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
   Commented by Sunil */

    IF  (p_CURR_LISTS_rec.attribute1 IS NOT NULL AND
        (   p_CURR_LISTS_rec.attribute1 <>
            p_old_CURR_LISTS_rec.attribute1 OR
            p_old_CURR_LISTS_rec.attribute1 IS NULL ))
    OR  (p_CURR_LISTS_rec.attribute10 IS NOT NULL AND
        (   p_CURR_LISTS_rec.attribute10 <>
            p_old_CURR_LISTS_rec.attribute10 OR
            p_old_CURR_LISTS_rec.attribute10 IS NULL ))
    OR  (p_CURR_LISTS_rec.attribute11 IS NOT NULL AND
        (   p_CURR_LISTS_rec.attribute11 <>
            p_old_CURR_LISTS_rec.attribute11 OR
            p_old_CURR_LISTS_rec.attribute11 IS NULL ))
    OR  (p_CURR_LISTS_rec.attribute12 IS NOT NULL AND
        (   p_CURR_LISTS_rec.attribute12 <>
            p_old_CURR_LISTS_rec.attribute12 OR
            p_old_CURR_LISTS_rec.attribute12 IS NULL ))
    OR  (p_CURR_LISTS_rec.attribute13 IS NOT NULL AND
        (   p_CURR_LISTS_rec.attribute13 <>
            p_old_CURR_LISTS_rec.attribute13 OR
            p_old_CURR_LISTS_rec.attribute13 IS NULL ))
    OR  (p_CURR_LISTS_rec.attribute14 IS NOT NULL AND
        (   p_CURR_LISTS_rec.attribute14 <>
            p_old_CURR_LISTS_rec.attribute14 OR
            p_old_CURR_LISTS_rec.attribute14 IS NULL ))
    OR  (p_CURR_LISTS_rec.attribute15 IS NOT NULL AND
        (   p_CURR_LISTS_rec.attribute15 <>
            p_old_CURR_LISTS_rec.attribute15 OR
            p_old_CURR_LISTS_rec.attribute15 IS NULL ))
    OR  (p_CURR_LISTS_rec.attribute2 IS NOT NULL AND
        (   p_CURR_LISTS_rec.attribute2 <>
            p_old_CURR_LISTS_rec.attribute2 OR
            p_old_CURR_LISTS_rec.attribute2 IS NULL ))
    OR  (p_CURR_LISTS_rec.attribute3 IS NOT NULL AND
        (   p_CURR_LISTS_rec.attribute3 <>
            p_old_CURR_LISTS_rec.attribute3 OR
            p_old_CURR_LISTS_rec.attribute3 IS NULL ))
    OR  (p_CURR_LISTS_rec.attribute4 IS NOT NULL AND
        (   p_CURR_LISTS_rec.attribute4 <>
            p_old_CURR_LISTS_rec.attribute4 OR
            p_old_CURR_LISTS_rec.attribute4 IS NULL ))
    OR  (p_CURR_LISTS_rec.attribute5 IS NOT NULL AND
        (   p_CURR_LISTS_rec.attribute5 <>
            p_old_CURR_LISTS_rec.attribute5 OR
            p_old_CURR_LISTS_rec.attribute5 IS NULL ))
    OR  (p_CURR_LISTS_rec.attribute6 IS NOT NULL AND
        (   p_CURR_LISTS_rec.attribute6 <>
            p_old_CURR_LISTS_rec.attribute6 OR
            p_old_CURR_LISTS_rec.attribute6 IS NULL ))
    OR  (p_CURR_LISTS_rec.attribute7 IS NOT NULL AND
        (   p_CURR_LISTS_rec.attribute7 <>
            p_old_CURR_LISTS_rec.attribute7 OR
            p_old_CURR_LISTS_rec.attribute7 IS NULL ))
    OR  (p_CURR_LISTS_rec.attribute8 IS NOT NULL AND
        (   p_CURR_LISTS_rec.attribute8 <>
            p_old_CURR_LISTS_rec.attribute8 OR
            p_old_CURR_LISTS_rec.attribute8 IS NULL ))
    OR  (p_CURR_LISTS_rec.attribute9 IS NOT NULL AND
        (   p_CURR_LISTS_rec.attribute9 <>
            p_old_CURR_LISTS_rec.attribute9 OR
            p_old_CURR_LISTS_rec.attribute9 IS NULL ))
    OR  (p_CURR_LISTS_rec.context IS NOT NULL AND
        (   p_CURR_LISTS_rec.context <>
            p_old_CURR_LISTS_rec.context OR
            p_old_CURR_LISTS_rec.context IS NULL ))
    THEN

    --  These calls are temporarily commented out

/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_CURR_LISTS_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_CURR_LISTS_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_CURR_LISTS_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_CURR_LISTS_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_CURR_LISTS_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_CURR_LISTS_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_CURR_LISTS_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_CURR_LISTS_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_CURR_LISTS_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_CURR_LISTS_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_CURR_LISTS_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_CURR_LISTS_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_CURR_LISTS_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_CURR_LISTS_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_CURR_LISTS_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'CONTEXT'
        ,   column_value                  => p_CURR_LISTS_rec.context
        );
*/

        --  Validate descriptive flexfield.

        IF NOT QP_Validate.Desc_Flex( 'CURR_LISTS' ) THEN
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
,   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type
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

END QP_Validate_Curr_Lists;

/
