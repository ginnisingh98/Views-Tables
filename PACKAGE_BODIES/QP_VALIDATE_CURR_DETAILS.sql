--------------------------------------------------------
--  DDL for Package Body QP_VALIDATE_CURR_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_VALIDATE_CURR_DETAILS" AS
/* $Header: QPXLCDTB.pls 120.3 2006/01/03 04:18:30 srashmi noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Validate_Curr_Details';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
,   p_old_CURR_DETAILS_rec          IN  QP_Currency_PUB.Curr_Details_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_DETAILS_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_dummy_c                     VARCHAR2(1);
l_base_currency_code_s        QP_CURRENCY_LISTS_B.base_currency_code%TYPE;
l_default_start_date_d        DATE := to_date('01/01/1951','mm/dd/yyyy');
l_default_end_date_d          DATE := to_date('12/31/9999','mm/dd/yyyy');
l_context_flag                VARCHAR2(1);
l_attribute_flag              VARCHAR2(1);
l_value_flag                  VARCHAR2(1);
l_datatype                    VARCHAR2(1);
l_flexfield_name              VARCHAR2(30);
l_precedence                  NUMBER;
l_error_code                  NUMBER;
l_org_id                      PLS_INTEGER;
l_context_type                VARCHAR2(30);
l_sourcing_enabled            VARCHAR2(1);
l_sourcing_status             VARCHAR2(1);
l_sourcing_method             VARCHAR2(30);

l_pte_code                    VARCHAR2(30);
l_ss_code                     VARCHAR2(30);
l_fna_name                    VARCHAR2(4000);
l_fna_desc                    VARCHAR2(489);
l_fna_valid                   BOOLEAN;

CURSOR CURSOR_OVERLAP_CHECK(in_to_currency_code_s     QP_CURRENCY_DETAILS.to_currency_code%TYPE,
			   in_currency_header_id_n   QP_CURRENCY_DETAILS.currency_header_id%TYPE,
			   in_currency_detail_id_n   QP_CURRENCY_DETAILS.currency_detail_id%TYPE,
			   in_curr_attribute_type    QP_CURRENCY_DETAILS.curr_attribute_type%TYPE,
			   in_curr_attribute_context QP_CURRENCY_DETAILS.curr_attribute_context%TYPE,
			   in_curr_attribute         QP_CURRENCY_DETAILS.curr_attribute%TYPE,
			   in_curr_attribute_value   QP_CURRENCY_DETAILS.curr_attribute_value%TYPE
			   )
is
SELECT
trunc(start_date_active) start_date_active,
trunc(end_date_active) end_date_active
FROM QP_CURRENCY_DETAILS
WHERE to_currency_code = in_to_currency_code_s and
      currency_header_id = in_currency_header_id_n and
      currency_detail_id <> nvl(in_currency_detail_id_n, -99999) and
      nvl(curr_attribute_type, '~EQUAL~') = nvl(in_curr_attribute_type, '~EQUAL~') and
      nvl(curr_attribute_context, '~EQUAL~') = nvl(in_curr_attribute_context, '~EQUAL~') and
      nvl(curr_attribute, '~EQUAL~') = nvl(in_curr_attribute, '~EQUAL~') and
      nvl(curr_attribute_value, '~EQUAL~') = nvl(in_curr_attribute_value, '~EQUAL~');

CURSOR CURSOR_PRECEDENCE_UNIQUENESS
			  (in_to_currency_code_s     QP_CURRENCY_DETAILS.to_currency_code%TYPE,
			   in_currency_header_id_n   QP_CURRENCY_DETAILS.currency_header_id%TYPE,
			   in_currency_detail_id_n   QP_CURRENCY_DETAILS.currency_detail_id%TYPE,
			   in_precedence             QP_CURRENCY_DETAILS.precedence%TYPE
			   )
is
SELECT
trunc(start_date_active) start_date_active,
trunc(end_date_active) end_date_active
FROM QP_CURRENCY_DETAILS
WHERE to_currency_code = in_to_currency_code_s and
      currency_header_id = in_currency_header_id_n and
      currency_detail_id <> nvl(in_currency_detail_id_n, -99999) and
      nvl(precedence, -1) = in_precedence;

BEGIN

    -- oe_debug_pub.add('Inside Details Entity L package');
    --  Check required attributes.

    IF  p_CURR_DETAILS_rec.currency_detail_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;
        -- oe_debug_pub.add('ERROR: currency_detail_id is NULL');

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency_detail_id');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    --
    --  Check rest of required attributes here.
    --
    -- Below validations Added by Sunil Pandey

    --   End Date must be after the Start Date

      -- oe_debug_pub.add('VALIDATING start date after end date');
      IF  nvl( p_CURR_DETAILS_rec.start_date_active,l_default_start_date_d) >
          nvl( p_CURR_DETAILS_rec.end_date_active,l_default_end_date_d)
      THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_STRT_DATE_BFR_END_DATE');
        OE_MSG_PUB.Add;
        -- oe_debug_pub.add(' Start_date End_Date Check; G_MSG_CONTEXT_COUNT: '||OE_MSG_PUB.G_MSG_CONTEXT_COUNT);
        -- oe_debug_pub.add(' Start_date End_Date Check; G_MSG_COUNT: '||OE_MSG_PUB.G_MSG_COUNT);
        -- oe_debug_pub.add('ERROR: start_date is after end_date');
        -- oe_debug_pub.add('.     start_date: '||NVL(p_CURR_DETAILS_rec.start_date_active, sysdate));
        -- oe_debug_pub.add('.     end_date: '||NVL(p_CURR_DETAILS_rec.end_date_active, sysdate));
        -- raise FND_API.G_EXC_ERROR;

      ELSE
        -- Validate that only one active detail record exist at any point of time
        BEGIN
          -- oe_debug_pub.add('VALIDATE Uniqueness of to_currency_code');
          For detail_rec in CURSOR_OVERLAP_CHECK
   			   (p_CURR_DETAILS_rec.to_currency_code,
   			    p_CURR_DETAILS_rec.currency_header_id,
   			    p_CURR_DETAILS_rec.currency_detail_id,
			    p_CURR_DETAILS_rec.curr_attribute_type,
			    p_CURR_DETAILS_rec.curr_attribute_context,
			    p_CURR_DETAILS_rec.curr_attribute,
			    p_CURR_DETAILS_rec.curr_attribute_value)
          LOOP
             If  (
   	       (nvl(trunc(p_CURR_DETAILS_rec.start_date_active), l_default_start_date_d) between
   		  nvl(detail_rec.start_date_active, l_default_start_date_d) and
   		  nvl(detail_rec.end_date_active,l_default_end_date_d)) OR

   	       (nvl(trunc(p_CURR_DETAILS_rec.end_date_active), l_default_end_date_d) between
   		  nvl(detail_rec.start_date_active, l_default_start_date_d) and
   		  nvl(detail_rec.end_date_active,l_default_end_date_d)) OR

   	       (nvl(trunc(p_CURR_DETAILS_rec.start_date_active), l_default_start_date_d) <=
   		  nvl(detail_rec.start_date_active, l_default_start_date_d) and
   	        nvl(trunc(p_CURR_DETAILS_rec.end_date_active), l_default_end_date_d) >=
   		  nvl(detail_rec.end_date_active, l_default_end_date_d))
                 )
   	  then

                l_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('QP','QP_OVERLAP_NOT_ALLWD'); -- CHANGE MESG_CODE
                FND_MESSAGE.SET_TOKEN('CURRENCY_CODE',p_CURR_DETAILS_rec.to_currency_code);
                OE_MSG_PUB.Add;
                -- oe_debug_pub.add('ERROR: Multiple record(s) are active for the to_currency_code: '||p_CURR_DETAILS_rec.to_currency_code);
                -- oe_debug_pub.add('.     Form record start_date: '||NVL(p_CURR_DETAILS_rec.start_date_active, l_default_start_date_d));
                -- oe_debug_pub.add('.     Form record end_date: '||NVL(p_CURR_DETAILS_rec.end_date_active, l_default_end_date_d));
                -- oe_debug_pub.add('.     Existing record start_date: '||NVL(detail_rec.start_date_active, l_default_start_date_d));
                -- oe_debug_pub.add('.     Existing record end_date: '||NVL(detail_rec.end_date_active, l_default_end_date_d));
		exit;  -- Exit the loop

             End if;
          END LOOP;

        END;
      END IF;

      -- Validate detail records' to_currency_code
      BEGIN
        -- oe_debug_pub.add('VALIDATE Details to_currency_code');

        SELECT 'X'
        INTO   l_dummy_c
        FROM   fnd_currencies_vl
        WHERE  enabled_flag = 'Y'
        and    currency_flag = 'Y'
        and    currency_code = p_CURR_DETAILS_rec.to_currency_code
        and    trunc(sysdate) between nvl(start_date_active,trunc(sysdate))
        and    nvl(end_date_active,trunc(sysdate));

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('QP','QP_INVALID_CURRENCY');
        OE_MSG_PUB.Add;
        -- oe_debug_pub.add('ERROR: Invalid To_Currency_Code');

      END;

      -- Validate detail records' price_formula
      IF  (p_CURR_DETAILS_rec.price_formula_id IS NOT NULL and
	   p_CURR_DETAILS_rec.price_formula_id <> FND_API.G_MISS_NUM)
      THEN
        BEGIN
          oe_debug_pub.add('VALIDATE Details price_formula');

          SELECT 'X'
          INTO l_dummy_c
          FROM qp_price_formulas_vl fh
          WHERE trunc(sysdate) between nvl(fh.start_date_active, trunc(sysdate))
          and nvl(fh.end_date_active, trunc(sysdate))
          and fh.price_formula_id = p_CURR_DETAILS_rec.price_formula_id
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
          oe_debug_pub.add('ERROR: Invalid price_formula_id');

        END;

        BEGIN
          oe_debug_pub.add('VALIDATE - Details price_formula does not have line of type MV');

          SELECT 'X'
          INTO l_dummy_c
          FROM qp_price_formulas_vl fh
          WHERE trunc(sysdate) between nvl(fh.start_date_active, trunc(sysdate))
          and nvl(fh.end_date_active, trunc(sysdate))
          and fh.price_formula_id = p_CURR_DETAILS_rec.price_formula_id
          and  not exists (Select 'x'
                           From qp_price_formula_lines fl
                           Where fl.price_formula_id = fh.price_formula_id
                           and fl.PRICE_FORMULA_LINE_TYPE_CODE = 'MV'
                           and trunc(sysdate) between nvl(fl.start_date_active, trunc(sysdate))
			       and nvl(fl.end_date_active, trunc(sysdate)));

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('QP','QP_INVALID_FORMULA_FOR_PL');
          OE_MSG_PUB.Add;
          oe_debug_pub.add('ERROR: price_formula_id has MV as line type');

        END;
      END IF;

      /*
      -- Validate detail records' conditional columns
      -- Markup value or formula should be present if operator is present
      IF ((p_CURR_DETAILS_rec.markup_operator IS NOT NULL and
	   p_CURR_DETAILS_rec.markup_operator <> FND_API.G_MISS_CHAR) AND
	  (p_CURR_DETAILS_rec.markup_formula_id IS NULL AND
	   p_CURR_DETAILS_rec.markup_value IS NULL)
         )
      THEN
         -- oe_debug_pub.add('ERROR: Markup Formula or Value should be provided if Markup Operator is present');
         l_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('QP','Enter_Markup_FML_OR_Value');  -- CHANGE MESG_CODE
         OE_MSG_PUB.Add;
      END IF;

      -- Markup Operator should be present if either value or formula is present
      IF ((p_CURR_DETAILS_rec.markup_operator IS NULL) AND
	  (p_CURR_DETAILS_rec.markup_formula_id IS NOT NULL OR
	   p_CURR_DETAILS_rec.markup_value IS NOT NULL)
         )
      THEN
         -- oe_debug_pub.add('ERROR: Markup Formula or Value can be provided only if Markup Operator is present');
         l_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('QP','First_Enter_Markup_OPRTR'); -- CHANGE MESG_CODE
         OE_MSG_PUB.Add;
      END IF;
      */

      -- Validate detail records' markup_formula
      IF  p_CURR_DETAILS_rec.markup_formula_id IS NOT NULL THEN
        BEGIN
          -- oe_debug_pub.add('VALIDATE Details markup_formula');

	  /*
          SELECT 'X'
          INTO l_dummy_c
          FROM qp_price_formulas_vl
          WHERE trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
          and nvl(end_date_active, trunc(sysdate))
          and price_formula_id = p_CURR_DETAILS_rec.markup_formula_id;
	  */

	  -- Only those formulas which do not have a line component of type_code = 'PLL' can
	  -- be attached to a multi-currency list
          SELECT 'X'
          INTO l_dummy_c
          FROM qp_price_formulas_vl fh
          WHERE trunc(sysdate) between nvl(fh.start_date_active, trunc(sysdate))
	  and nvl(fh.end_date_active, trunc(sysdate))
          and fh.price_formula_id = p_CURR_DETAILS_rec.markup_formula_id
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
          -- oe_debug_pub.add('ERROR: Invalid markup_formula_id');

        END;
      END IF;

      /*
      -- Validate detail records' conversion_method
      IF  p_CURR_DETAILS_rec.conversion_method IS NOT NULL THEN
        BEGIN
          -- oe_debug_pub.add('VALIDATE Details conversion_method');

          SELECT 'X'
          INTO l_dummy_c
          FROM qp_lookups
          WHERE lookup_type = 'CONVERSION_METHOD'
          and lookup_code = p_CURR_DETAILS_rec.conversion_method;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('QP','Invalid_Conversion_Method'); -- CHANGE MESG_CODE
          OE_MSG_PUB.Add;

        END;
      END IF;
      */

      -- Validate detail records' conversion_type
      IF  p_CURR_DETAILS_rec.conversion_type IS NOT NULL THEN
        BEGIN
          -- oe_debug_pub.add('VALIDATE Details conversion_type');

	  -- Check if the conversion_type exists in GL
          SELECT 'X'
          INTO l_dummy_c
          FROM gl_daily_conversion_types
          WHERE conversion_type = p_CURR_DETAILS_rec.conversion_type and
		conversion_type <> 'User';

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  Begin
	     -- If conversion_type is not in GL, then check if it is defined as lookup_code
             SELECT 'X'
             INTO l_dummy_c
             FROM qp_lookups
             WHERE lookup_type = 'CONVERSION_METHOD'
             and lookup_code = p_CURR_DETAILS_rec.conversion_type
	     and enabled_flag = 'Y' and
	     trunc(sysdate) between
	     nvl(start_date_active, trunc(sysdate)) and nvl(end_date_active, trunc(sysdate));

	  EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	  -- If not found in either GL or lookup_code then raise error

             l_return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('QP','QP_INVALID_CONV_TYPE'); -- CHANGE MESG_CODE
             FND_MESSAGE.SET_TOKEN('CONVERSION_TYPE',p_CURR_DETAILS_rec.conversion_type);
             OE_MSG_PUB.Add;
             -- oe_debug_pub.add('ERROR: Invalid Conversion_Type passed');
	  End;
        END;
      END IF;

      -- Validate detail records' conversion_date_type
      IF  p_CURR_DETAILS_rec.conversion_date_type IS NOT NULL THEN
        BEGIN
          -- oe_debug_pub.add('VALIDATE Details conversion_date_type');

          SELECT 'X'
          INTO l_dummy_c
          FROM qp_lookups
          WHERE lookup_type = 'CONVERSION_DATE_TYPE'
          and lookup_code = p_CURR_DETAILS_rec.conversion_date_type
	  and enabled_flag = 'Y' and
	  trunc(sysdate) between
	  nvl(start_date_active, trunc(sysdate)) and nvl(end_date_active, trunc(sysdate));

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('QP','QP_INVALID_CONV_DT_TYPE'); -- CHANGE MESG_CODE
          FND_MESSAGE.SET_TOKEN('CONVERSION_DATE_TYPE',p_CURR_DETAILS_rec.conversion_date_type);
          OE_MSG_PUB.Add;
          -- oe_debug_pub.add('ERROR: Invalid conversion_date_type');

        END;
      END IF;

      -- Validate detail records' markup_operator
      IF  p_CURR_DETAILS_rec.markup_operator IS NOT NULL THEN
        BEGIN
          -- oe_debug_pub.add('VALIDATE Details markup_operator');

          SELECT 'X'
          INTO l_dummy_c
          FROM qp_lookups
          WHERE lookup_type = 'MARKUP_OPERATOR'
          and lookup_code = p_CURR_DETAILS_rec.markup_operator
	  and enabled_flag = 'Y' and
	  trunc(sysdate) between
	  nvl(start_date_active, trunc(sysdate)) and nvl(end_date_active, trunc(sysdate));

          -- Validate detail records' conditional columns
          -- Markup value or formula should be present if operator is present
          IF ((p_CURR_DETAILS_rec.markup_formula_id IS NULL AND
	       p_CURR_DETAILS_rec.markup_value IS NULL)
             )
          THEN
             -- oe_debug_pub.add('ERROR: Markup Formula or Value should be provided if Markup Operator is present');
             l_return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('QP','QP_FRML_OR_VAL_REQD');  -- CHANGE MESG_CODE
             OE_MSG_PUB.Add;
          END IF;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('QP','QP_INVALID_MARKUP_OPRTR');
          FND_MESSAGE.SET_TOKEN('MARKUP_OPERATOR',p_CURR_DETAILS_rec.markup_operator);
          OE_MSG_PUB.Add;
          -- oe_debug_pub.add('ERROR: Invalid markup_operator');

        END;
      ELSE

        -- Markup Operator should be present if either value or formula is present
        IF ((p_CURR_DETAILS_rec.markup_formula_id IS NOT NULL OR
	     p_CURR_DETAILS_rec.markup_value IS NOT NULL)
           )
        THEN
           -- oe_debug_pub.add('ERROR: Markup Formula or Value can be provided only if Markup Operator is present');
           l_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.SET_NAME('QP','QP_MARKUP_OPRTR_REQD'); -- CHANGE MESG_CODE
           OE_MSG_PUB.Add;
        END IF;
      END IF;

     -- Below statements Validate detail records' conditionally required columns
     BEGIN
       -- oe_debug_pub.add('Validate Detail Record''s conditional columns for to_currency_code: '||p_CURR_DETAILS_rec.to_currency_code);
       -- oe_debug_pub.add('Detail record''s hdr_id: '||p_CURR_DETAILS_rec.currency_header_id);
       -- Get the header's base currency code
       Begin
           SELECT base_currency_code
	   INTO l_base_currency_code_s
	   FROM QP_CURRENCY_LISTS_B
	   WHERE currency_header_id = p_CURR_DETAILS_rec.currency_header_id;
       Exception
       When NO_DATA_FOUND THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency_header_id');
          OE_MSG_PUB.Add;
       END;

       -- oe_debug_pub.add('Header Currency Code: '||l_base_currency_code_s);
       -- --oe_debug_pub.add('Conversion Method: '||p_CURR_DETAILS_rec.CONVERSION_METHOD);

       IF  (p_CURR_DETAILS_rec.to_currency_code = l_base_currency_code_s)
       then

          -- oe_debug_pub.add('ERROR: To_Currency_Code can not be same as Base_Currency_Code');
          l_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('QP','QP_TO_DIFFERENT_FROM_BASE'); -- CHANGE MESG_CODE
          OE_MSG_PUB.Add;

	  /* This validation is obsolete now
	  If  (--p_CURR_DETAILS_rec.CONVERSION_METHOD is NOT NULL OR
	       p_CURR_DETAILS_rec.FIXED_VALUE is NOT NULL OR
	       p_CURR_DETAILS_rec.PRICE_FORMULA_id is NOT NULL OR
	       p_CURR_DETAILS_rec.CONVERSION_TYPE is NOT NULL OR
	       p_CURR_DETAILS_rec.CONVERSION_DATE_TYPE is NOT NULL OR
	       p_CURR_DETAILS_rec.CONVERSION_DATE is NOT NULL OR
	       p_CURR_DETAILS_rec.START_DATE_ACTIVE is NOT NULL OR
	       p_CURR_DETAILS_rec.END_DATE_ACTIVE is NOT NULL )
          then

             -- oe_debug_pub.add('ERROR: Value is not allowed in the following fields when to_currency is same as base_currency: FIXED_VALUE, PRICE_FORMULA_id, CONVERSION_TYPE, CONVERSION_DATE_TYPE, CONVERSION_DATE, START_DATE_ACTIVE, END_DATE_ACTIVE');
             l_return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('QP','QP_VALUE_NOT_ALLWD_CURR'); -- CHANGE MESG_CODE
             OE_MSG_PUB.Add;
          End if;
	  */

       ELSE -- to_currency_code is different from base_currency_code

           --IF  (p_CURR_DETAILS_rec.CONVERSION_METHOD is NULL)
           IF  (p_CURR_DETAILS_rec.CONVERSION_TYPE is NULL)
           THEN

              -- oe_debug_pub.add('ERROR: CONVERSION_TYPE is required when to_currency_code is different from base_currency_code');
              l_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('QP','QP_CONV_TYPE_REQD'); -- CHANGE MESG_CODE
              OE_MSG_PUB.Add;

           ELSIF  (p_CURR_DETAILS_rec.CONVERSION_TYPE = 'TRANSACTION')
           THEN
               If (p_CURR_DETAILS_rec.FIXED_VALUE is NOT NULL OR
                   p_CURR_DETAILS_rec.PRICE_FORMULA_id is not NULL OR
                   p_CURR_DETAILS_rec.CONVERSION_DATE_TYPE is not NULL OR
                   p_CURR_DETAILS_rec.CONVERSION_DATE is not NULL)
               then
                  -- oe_debug_pub.add('ERROR: Value is not allowed in the following fields when Conversion_Type = ''TRANSACTION'': FIXED_VALUE, PRICE_FORMULA_id, CONVERSION_DATE_TYPE, CONVERSION_DATE');
                  l_return_status := FND_API.G_RET_STS_ERROR;
                  FND_MESSAGE.SET_NAME('QP','QP_VALUE_NOT_ALLWD_TXN'); -- CHANGE MESG_CODE
                  OE_MSG_PUB.Add;
               End If;

           ELSIF  (p_CURR_DETAILS_rec.CONVERSION_TYPE = 'FIXED')
           THEN
               If (p_CURR_DETAILS_rec.FIXED_VALUE is NULL)
               then
                  -- oe_debug_pub.add('ERROR: FIXED_VALUE is required ehen Conversion_Type is ''FIXED''');
                  l_return_status := FND_API.G_RET_STS_ERROR;
                  FND_MESSAGE.SET_NAME('QP','QP_FIXED_VALUE_REQD'); -- CHANGE MESG_CODE
                  OE_MSG_PUB.Add;
               End If;

               If (p_CURR_DETAILS_rec.PRICE_FORMULA_id is not NULL OR
                   -- p_CURR_DETAILS_rec.CONVERSION_TYPE is not NULL OR
                   p_CURR_DETAILS_rec.CONVERSION_DATE_TYPE is not NULL OR
                   p_CURR_DETAILS_rec.CONVERSION_DATE is not NULL)
               then
                  -- oe_debug_pub.add('ERROR: Value is not allowed in the following fields when Conversion_Type = ''FIXED'': PRICE_FORMULA_id, CONVERSION_DATE_TYPE, CONVERSION_DATE');
                  l_return_status := FND_API.G_RET_STS_ERROR;
                  FND_MESSAGE.SET_NAME('QP','QP_VALUE_NOT_ALLWD_FIXED'); -- CHANGE MESG_CODE
                  OE_MSG_PUB.Add;
               End If;
           -- ELSIF (p_CURR_DETAILS_rec.CONVERSION_METHOD = 'GL')
           ELSIF (p_CURR_DETAILS_rec.CONVERSION_TYPE NOT IN ('FIXED', 'FORMULA', 'TRANSACTION'))
           THEN
               --If (p_CURR_DETAILS_rec.CONVERSION_TYPE is NULL OR
               If (p_CURR_DETAILS_rec.CONVERSION_DATE_TYPE is NULL)
               then
                  -- oe_debug_pub.add('ERROR: CONVERSION_DATE_TYPE is required when Conversion_Type is Not ''FIXED'' or ''FORMULA'' or ''TRANSACTION''');
                  l_return_status := FND_API.G_RET_STS_ERROR;
                  FND_MESSAGE.SET_NAME('QP','QP_CONV_DT_TYPE_REQD'); -- CHANGE MESG_CODE
                  OE_MSG_PUB.Add;
               End If;

    	       If (p_CURR_DETAILS_rec.PRICE_FORMULA_id is not NULL  OR
    	           p_CURR_DETAILS_rec.FIXED_VALUE is not NULL)
    	       then
                  -- oe_debug_pub.add('ERROR: Value is not allowed in the following fields when Conversion_Type is Not ''FIXED'' or ''FORMULA'': PRICE_FORMULA_id, FIXED_VALUE');
                  l_return_status := FND_API.G_RET_STS_ERROR;
                  FND_MESSAGE.SET_NAME('QP','QP_VALUE_NOT_ALLWD_GL'); -- CHANGE MESG_CODE
                  OE_MSG_PUB.Add;
    	       End If;

    	       if (p_CURR_DETAILS_rec.CONVERSION_DATE_TYPE = 'FIXED')
    	       then
                  if (p_CURR_DETAILS_rec.CONVERSION_DATE is NULL) then
                     -- oe_debug_pub.add('ERROR: CONVERSION_DATE is required when CONVERSION_TYPE is Not (''FIXED'' or ''FORMULA'' or ''TRANSACTION'') and CONVERSION_DATE_TYPE = ''FIXED''');
                     l_return_status := FND_API.G_RET_STS_ERROR;
                     FND_MESSAGE.SET_NAME('QP','QP_CONV_DT_REQUIRED'); -- CHANGE MESG_CODE
                     OE_MSG_PUB.Add;
                  End if;
    	       Else
                  if (p_CURR_DETAILS_rec.CONVERSION_DATE is NOT NULL) then
                     -- oe_debug_pub.add('ERROR: CONVERSION_DATE is allowed only when CONVERSION_TYPE is Not (''FIXED'' or ''FORMULA'' or ''TRANSACTION'') and CONVERSION_DATE_TYPE <> ''FIXED''');
                     l_return_status := FND_API.G_RET_STS_ERROR;
                     FND_MESSAGE.SET_NAME('QP','QP_CONV_DT_NOT_ALLWD'); -- CHANGE MESG_CODE
                     OE_MSG_PUB.Add;
                  End if;

    	       End if;
           ELSIF (p_CURR_DETAILS_rec.CONVERSION_TYPE = 'FORMULA')
           THEN
    	       If p_CURR_DETAILS_rec.PRICE_FORMULA_id is NULL then
                  -- oe_debug_pub.add('ERROR: PRICE_FORMULA_id is required for Conversion_Type = ''FORMULA''');
                  l_return_status := FND_API.G_RET_STS_ERROR;
                  FND_MESSAGE.SET_NAME('QP','QP_PRICE_FORMULA_REQD'); -- CHANGE MESG_CODE
                  OE_MSG_PUB.Add;
    	       End If;

    	       If (p_CURR_DETAILS_rec.FIXED_VALUE is not NULL OR
    	           p_CURR_DETAILS_rec.CONVERSION_DATE_TYPE is not NULL OR
    	           p_CURR_DETAILS_rec.CONVERSION_DATE is not NULL)
    	       then
                  -- oe_debug_pub.add('ERROR: Value is not allowed in the following fields when Conversion_Type = ''FORMULA'': FIXED_VALUE, CONVERSION_DATE_TYPE, CONVERSION_DATE');
                  -- oe_debug_pub.add('.     FIXED VALUE: '||p_CURR_DETAILS_rec.FIXED_VALUE);
                  l_return_status := FND_API.G_RET_STS_ERROR;
                  FND_MESSAGE.SET_NAME('QP','QP_FVAL_OR_CONV_NOT_ALLWD'); -- CHANGE MESG_CODE
                  OE_MSG_PUB.Add;
    	       End If;
           END IF; -- Conversion_Type
       END IF; -- to_currency_code = base_currency_code


      -- Validate detail records' CURR_ATTRIBUTE_TYPE
      IF  p_CURR_DETAILS_rec.curr_attribute_type IS NOT NULL THEN
        BEGIN
          -- oe_debug_pub.add('VALIDATE Details curr_attribute_type');

          SELECT 'X'
          INTO l_dummy_c
          FROM qp_lookups
          WHERE lookup_type = 'MULTI_CURR_ATTRIBUTE_TYPE'
          and lookup_code = p_CURR_DETAILS_rec.curr_attribute_type
	  and enabled_flag = 'Y' and
	  trunc(sysdate) between
	  nvl(start_date_active, trunc(sysdate)) and nvl(end_date_active, trunc(sysdate));

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CURRENCY ATTRIBUTE TYPE');
          OE_MSG_PUB.Add;
          -- oe_debug_pub.add('ERROR: Invalid curr_attribute_type');

        END;
      END IF;


      -- Validate that either all the curr_attribute fields are NULL or all are not NOT NULL
      IF ( p_CURR_DETAILS_rec.curr_attribute_type IS NOT NULL AND
	   p_CURR_DETAILS_rec.curr_attribute_context IS NOT NULL AND
	   p_CURR_DETAILS_rec.curr_attribute IS NOT NULL AND
	   p_CURR_DETAILS_rec.curr_attribute_value IS NOT NULL )
      THEN
	 -- The below logic validates the Currency Context, Attribute, and Value passed

	 If p_CURR_DETAILS_rec.curr_attribute_type = 'QUALIFIER' then
	    l_flexfield_name :=  'QP_ATTR_DEFNS_QUALIFIER';
	 Else
	    l_flexfield_name :=  'QP_ATTR_DEFNS_PRICING';
	 End if;

         QP_UTIL.validate_qp_flexfield(flexfield_name        => l_flexfield_name
                                      ,context               => p_CURR_DETAILS_rec.curr_attribute_context
                                      ,attribute             => p_CURR_DETAILS_rec.curr_attribute
                                      ,value                 => p_CURR_DETAILS_rec.curr_attribute_value
                                      ,application_short_name=> 'QP'
                                      ,context_flag          =>l_context_flag
                                      ,attribute_flag        =>l_attribute_flag
                                      ,value_flag            =>l_value_flag
                                      ,datatype              =>l_datatype
                                      ,precedence            =>l_precedence
                                      ,error_code            =>l_error_code
                                      );

         If (l_context_flag = 'N'  AND l_error_code = 7)       --  invalid context
         Then
            l_return_status := FND_API.G_RET_STS_ERROR;

	    If p_CURR_DETAILS_rec.curr_attribute_type = 'PRODUCT' then
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_CONTEXT'  );
	    ElsIf p_CURR_DETAILS_rec.curr_attribute_type = 'PRICING' then
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_PRICING_CONTEXT'  );
	    ElsIf p_CURR_DETAILS_rec.curr_attribute_type = 'QUALIFIER' then
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','QUALIFIER ATTRIBUTE CONTEXT');
            Else
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CURRENCY ATTRIBUTE CONTEXT');
            End if;

            OE_MSG_PUB.Add;
         End If;

         If (l_attribute_flag = 'N'  AND l_error_code = 8)       --  invalid attribute
         Then
            l_return_status := FND_API.G_RET_STS_ERROR;

	    If p_CURR_DETAILS_rec.curr_attribute_type = 'PRODUCT' then
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_ATTR'  );
	    ElsIf p_CURR_DETAILS_rec.curr_attribute_type = 'PRICING' then
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_PRICING_ATTR'  );
	    ElsIf p_CURR_DETAILS_rec.curr_attribute_type = 'QUALIFIER' then
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','QUALIFIER ATTRIBUTE');
            Else
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CURRENCY ATTRIBUTE');
            End if;

            OE_MSG_PUB.Add;
         End If;

         If (l_value_flag = 'N'  AND l_error_code = 9)       --  invalid value
         Then
            l_return_status := FND_API.G_RET_STS_ERROR;

	    If p_CURR_DETAILS_rec.curr_attribute_type = 'PRODUCT' then
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_VALUE'  );
	    ElsIf p_CURR_DETAILS_rec.curr_attribute_type = 'PRICING' then
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE'  );
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','PRICING ATTRIBUTE VALUE');
	    ElsIf p_CURR_DETAILS_rec.curr_attribute_type = 'QUALIFIER' then
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE'  );
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','QUALIFIER ATTRIBUTE VALUE');
            Else
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ATTRIBUTE VALUE');
            End if;

            OE_MSG_PUB.Add;
         End If;


	 -- Precedence should be NOT NULL
	 If p_CURR_DETAILS_rec.precedence IS NULL
	 then
            l_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP','QP_PRECEDENCE_REQD'); -- CHANGE MESG_CODE
            OE_MSG_PUB.Add;
            -- oe_debug_pub.add('ERROR: Precedence is required when Attribute type is not NULL');
	 End If;  -- precedence is null

	 -- Validate the Inventory_item_id/category_id if the type is PRODUCT and attribute
	 -- is PA1/PA2
	 IF p_CURR_DETAILS_rec.curr_attribute_context = 'ITEM' AND
	    p_CURR_DETAILS_rec.curr_attribute_type = 'PRODUCT'
	 THEN
            IF p_CURR_DETAILS_rec.curr_attribute = 'PRICING_ATTRIBUTE1' -- Item Number
            THEN
               l_org_id := QP_UTIL.Get_Item_Validation_Org;

     	       BEGIN
     	          SELECT 'X'
                  INTO l_dummy_c
	          FROM mtl_system_items_kfv
                  WHERE  inventory_item_id = to_number(p_CURR_DETAILS_rec.curr_attribute_value) and
                         organization_id = l_org_id;

               EXCEPTION
	             WHEN NO_DATA_FOUND THEN
                  l_return_status := FND_API.G_RET_STS_ERROR;

                  FND_MESSAGE.SET_NAME('QP','QP_INVALID_ITEM');
                  FND_MESSAGE.SET_TOKEN('ITEM_ID',p_CURR_DETAILS_rec.curr_attribute_value);
                  OE_MSG_PUB.Add;
                  --** oe_debug_pub.add('ERROR: Invalid Inventory_Item_id provided');

               END;

	    END IF;  --Item Number

            IF p_CURR_DETAILS_rec.curr_attribute = 'PRICING_ATTRIBUTE2'  -- Item Category
            THEN

     	     /*  BEGIN
     	          SELECT 'X'
                  INTO l_dummy_c
                  FROM qp_item_categories_v
                  WHERE  category_id = to_number(p_CURR_DETAILS_rec.curr_attribute_value) and
                         ROWNUM = 1;

               EXCEPTION
	             WHEN NO_DATA_FOUND THEN
                  l_return_status := FND_API.G_RET_STS_ERROR;

                  FND_MESSAGE.SET_NAME('QP','QP_INVALID_ITEM_CATEGORY');
                  FND_MESSAGE.SET_TOKEN('CATEGORY_ID',p_CURR_DETAILS_rec.curr_attribute_value);
                  OE_MSG_PUB.Add;
                  --** oe_debug_pub.add('ERROR: Invalid Category_id provided');

               END;*/

               -- Functional Area validation for Hierarchical Categories (sfiresto)
               BEGIN

                 l_pte_code := fnd_profile.value('QP_PRICING_TRANSACTION_ENTITY');
                 l_ss_code := fnd_profile.value('QP_SOURCE_SYSTEM_CODE');

                 QP_UTIL.Get_Item_Cat_Info(
                    p_CURR_DETAILS_rec.curr_attribute_value,
                    l_pte_code,
                    l_ss_code,
                    l_fna_name,
                    l_fna_desc,
                    l_fna_valid);

                 IF NOT l_fna_valid THEN

                   l_return_status := FND_API.G_RET_STS_ERROR;

                   FND_MESSAGE.set_name('QP', 'QP_INVALID_CAT_FUNC_PTE');
                   FND_MESSAGE.set_token('CATID', p_CURR_DETAILS_rec.curr_attribute_value);
                   FND_MESSAGE.set_token('PTE', l_pte_code);
                   FND_MESSAGE.set_token('SS', l_ss_code);
                   OE_MSG_PUB.Add;

                 END IF;

               END;

            END IF;  -- Item Category
	 END IF; -- curr_attribute_context = 'ITEM'

      ELSIF ( p_CURR_DETAILS_rec.curr_attribute_type IS NOT NULL OR
	      p_CURR_DETAILS_rec.curr_attribute_context IS NOT NULL OR
	      p_CURR_DETAILS_rec.curr_attribute IS NOT NULL OR
	      p_CURR_DETAILS_rec.curr_attribute_value IS NOT NULL )
      THEN
      -- This elsif checks if any of the curr_attribute is not NULL. Since the above test failed
      -- so at least one of these attributes is NULL.
         l_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('QP','QP_CURR_ATTRS_REQD_OR_NULL'); -- CHANGE MESG_CODE
         OE_MSG_PUB.Add;
         -- oe_debug_pub.add('ERROR: All of the following fields should either be NULL or NOT NULL: CURR_ATTRIBUTE_TYPE, CURR_ATTRIBUTE_CONTEXT, CURR_ATTRIBUTE, CURR_ATTRIBUTE_VALUE');

      END IF;

      -- Validate correctness and uniqueness of precedence
      IF p_CURR_DETAILS_rec.precedence is NOT NULL then
	 -- Validate that the prcedence is an integer
	 If ( (instr(to_char(p_CURR_DETAILS_rec.precedence), '.', 1) <> 0) OR
              (p_CURR_DETAILS_rec.precedence < 0) )
         then
            l_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP','QP_INTEGER_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ENTITY','PRECEDENCE');
            OE_MSG_PUB.Add;
            -- oe_debug_pub.add('ERROR: Precedence should be a positive integer value');
	 Else
           -- Validate that only one active detail record exist at any point of time
           BEGIN
                 -- oe_debug_pub.add('VALIDATE Uniqueness of to_currency_code');
                 For detail_rec in CURSOR_PRECEDENCE_UNIQUENESS
   			          (p_CURR_DETAILS_rec.to_currency_code,
   			           p_CURR_DETAILS_rec.currency_header_id,
   			           p_CURR_DETAILS_rec.currency_detail_id,
			           p_CURR_DETAILS_rec.precedence)
                 LOOP
                    If  (
   	              (nvl(trunc(p_CURR_DETAILS_rec.start_date_active), l_default_start_date_d) between
   		         nvl(detail_rec.start_date_active, l_default_start_date_d) and
   		         nvl(detail_rec.end_date_active,l_default_end_date_d)) OR

   	              (nvl(trunc(p_CURR_DETAILS_rec.end_date_active), l_default_end_date_d) between
   		         nvl(detail_rec.start_date_active, l_default_start_date_d) and
   		         nvl(detail_rec.end_date_active,l_default_end_date_d)) OR

   	              (nvl(trunc(p_CURR_DETAILS_rec.start_date_active), l_default_start_date_d) <=
   		         nvl(detail_rec.start_date_active, l_default_start_date_d) and
   	               nvl(trunc(p_CURR_DETAILS_rec.end_date_active), l_default_end_date_d) >=
   		         nvl(detail_rec.end_date_active, l_default_end_date_d))
                        )
                    then

                       l_return_status := FND_API.G_RET_STS_ERROR;
                       FND_MESSAGE.SET_NAME('QP','QP_UNIQUE_PRECEDENCE'); -- CHANGE MESG_CODE
                       OE_MSG_PUB.Add;
                       -- oe_debug_pub.add('ERROR: Precedence should be unique for a to_currency_code within a given period');
		       exit;  -- Exit the loop
                    End if;  -- date check
                 END LOOP;

           END;

	 End If;  -- precedence is an integer

      END IF;  -- precedence is not NULL

                 oe_debug_pub.add('ENTITY - before rounding_factor');
      IF  p_CURR_DETAILS_rec.rounding_factor IS NOT NULL AND
          p_CURR_DETAILS_rec.to_currency_code IS NOT NULL THEN
             IF NOT QP_Validate.Rounding_Factor(p_CURR_DETAILS_rec.rounding_factor,
                                                p_CURR_DETAILS_rec.to_currency_code) THEN
                 oe_debug_pub.add('ENTITY rounding_factor error occured');
                 l_return_status := FND_API.G_RET_STS_ERROR;
             END IF;
      END IF;

                 oe_debug_pub.add('ENTITY - before selling rounding_factor');
      IF  p_CURR_DETAILS_rec.selling_rounding_factor IS NOT NULL AND
          p_CURR_DETAILS_rec.to_currency_code IS NOT NULL THEN
             IF NOT QP_Validate.Rounding_Factor(p_CURR_DETAILS_rec.selling_rounding_factor,
                                                p_CURR_DETAILS_rec.to_currency_code) THEN
                 oe_debug_pub.add('ENTITY selling_rounding_factor error occured');
                 l_return_status := FND_API.G_RET_STS_ERROR;
             END IF;
      END IF;

      -- Bug 2293974 - rounding factor is mandatory
      If (p_CURR_DETAILS_rec.selling_rounding_factor is NULL  or
          p_CURR_DETAILS_rec.selling_rounding_factor = FND_API.G_MISS_NUM )
      then
          l_return_status := FND_API.G_RET_STS_ERROR;

          FND_MESSAGE.SET_NAME('QP','QP_RNDG_FACTOR_REQD');
          oe_msg_pub.add;

      end if;

     END;
     -- Above statements Validate detail records' conditionally required columns

     -- oe_debug_pub.add('G_MSG_CONTEXT_COUNT: '||OE_MSG_PUB.G_MSG_CONTEXT_COUNT);
     -- oe_debug_pub.add('Coming Out of CDT L package');
    -- Above validations Added by Sunil Pandey


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
    --Raise a warning if the Pricing/Product Attribute being used in setup
    --has a sourcing method of 'ATTRIBUTE MAPPING' but is not sourcing-enabled
    --or if its sourcing_status is not 'Y', i.e., the build sourcing conc.
    --program has to be run.

    oe_debug_pub.add('Here 0000');
  IF qp_util.attrmgr_installed = 'Y' THEN
    oe_debug_pub.add('Here 1111');
    IF p_CURR_DETAILS_rec.curr_attribute_context IS NOT NULL AND
       p_CURR_DETAILS_rec.curr_attribute IS NOT NULL
    THEN
    oe_debug_pub.add('Here 2222');
      If p_CURR_DETAILS_rec.curr_attribute_type = 'QUALIFIER' then
         QP_UTIL.Get_Context_Type('QP_ATTR_DEFNS_QUALIFIER',
                                  p_CURR_DETAILS_rec.curr_attribute_context,
                                  l_context_type,
                                  l_error_code);
      else
         QP_UTIL.Get_Context_Type('QP_ATTR_DEFNS_PRICING',
                                  p_CURR_DETAILS_rec.curr_attribute_context,
                                  l_context_type,
                                  l_error_code);
      End if;

      IF l_error_code = 0 THEN --successfully returned context_type

    oe_debug_pub.add('Here 3333');
    oe_debug_pub.add('l_context_type = ' || l_context_type);
    oe_debug_pub.add('p_CURR_DETAILS_rec.curr_attribute_context = ' || p_CURR_DETAILS_rec.curr_attribute_context);
    oe_debug_pub.add('p_CURR_DETAILS_rec.curr_attribute = ' || p_CURR_DETAILS_rec.curr_attribute);
        QP_UTIL.Get_Sourcing_Info(l_context_type,
                                  p_CURR_DETAILS_rec.curr_attribute_context,
                                  p_CURR_DETAILS_rec.curr_attribute,
                                  l_sourcing_enabled,
                                  l_sourcing_status,
                                  l_sourcing_method);

    oe_debug_pub.add('l_sourcing_method = ' || l_sourcing_method);
        IF l_sourcing_method = 'ATTRIBUTE MAPPING' THEN

    oe_debug_pub.add('Here 4444');
          IF l_sourcing_enabled <> 'Y' THEN

    oe_debug_pub.add('Here 5555');
            FND_MESSAGE.SET_NAME('QP','QP_ENABLE_SOURCING');
            FND_MESSAGE.SET_TOKEN('CONTEXT',
                                  p_CURR_DETAILS_rec.curr_attribute_context);
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                  p_CURR_DETAILS_rec.curr_attribute);
            OE_MSG_PUB.Add;

          END IF;

          IF l_sourcing_status <> 'Y' THEN

    oe_debug_pub.add('Here 6666');
            FND_MESSAGE.SET_NAME('QP','QP_BUILD_SOURCING_RULES');
            FND_MESSAGE.SET_TOKEN('CONTEXT',
                                  p_CURR_DETAILS_rec.curr_attribute_context);
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                  p_CURR_DETAILS_rec.curr_attribute);
            OE_MSG_PUB.Add;

          END IF;

        END IF; --If sourcing_method = 'ATTRIBUTE MAPPING'

      END IF; --l_error_code = 0

    END IF;--If curr_attribute_context and curr_attribute are NOT NULL

  END IF; --qp_util.attrmgr_installed = 'Y'


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
,   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
,   p_old_CURR_DETAILS_rec          IN  QP_Currency_PUB.Curr_Details_Rec_Type :=
                                        QP_Currency_PUB.G_MISS_CURR_DETAILS_REC
)
IS
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate CURR_DETAILS attributes

    IF  p_CURR_DETAILS_rec.conversion_date IS NOT NULL AND
        (   p_CURR_DETAILS_rec.conversion_date <>
            p_old_CURR_DETAILS_rec.conversion_date OR
            p_old_CURR_DETAILS_rec.conversion_date IS NULL )
    THEN
        IF NOT QP_Validate.Conversion_Date(p_CURR_DETAILS_rec.conversion_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.conversion_date_type IS NOT NULL AND
        (   p_CURR_DETAILS_rec.conversion_date_type <>
            p_old_CURR_DETAILS_rec.conversion_date_type OR
            p_old_CURR_DETAILS_rec.conversion_date_type IS NULL )
    THEN
        IF NOT QP_Validate.Conversion_Date_Type(p_CURR_DETAILS_rec.conversion_date_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    /*
    IF  p_CURR_DETAILS_rec.conversion_method IS NOT NULL AND
        (   p_CURR_DETAILS_rec.conversion_method <>
            p_old_CURR_DETAILS_rec.conversion_method OR
            p_old_CURR_DETAILS_rec.conversion_method IS NULL )
    THEN
        IF NOT QP_Validate.Conversion_Method(p_CURR_DETAILS_rec.conversion_method) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    */

    IF  p_CURR_DETAILS_rec.conversion_type IS NOT NULL AND
        (   p_CURR_DETAILS_rec.conversion_type <>
            p_old_CURR_DETAILS_rec.conversion_type OR
            p_old_CURR_DETAILS_rec.conversion_type IS NULL )
    THEN
        IF NOT QP_Validate.Conversion_Type(p_CURR_DETAILS_rec.conversion_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.created_by IS NOT NULL AND
        (   p_CURR_DETAILS_rec.created_by <>
            p_old_CURR_DETAILS_rec.created_by OR
            p_old_CURR_DETAILS_rec.created_by IS NULL )
    THEN
        IF NOT QP_Validate.Created_By(p_CURR_DETAILS_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.creation_date IS NOT NULL AND
        (   p_CURR_DETAILS_rec.creation_date <>
            p_old_CURR_DETAILS_rec.creation_date OR
            p_old_CURR_DETAILS_rec.creation_date IS NULL )
    THEN
        IF NOT QP_Validate.Creation_Date(p_CURR_DETAILS_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.currency_detail_id IS NOT NULL AND
        (   p_CURR_DETAILS_rec.currency_detail_id <>
            p_old_CURR_DETAILS_rec.currency_detail_id OR
            p_old_CURR_DETAILS_rec.currency_detail_id IS NULL )
    THEN
        IF NOT QP_Validate.Currency_Detail(p_CURR_DETAILS_rec.currency_detail_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.currency_header_id IS NOT NULL AND
        (   p_CURR_DETAILS_rec.currency_header_id <>
            p_old_CURR_DETAILS_rec.currency_header_id OR
            p_old_CURR_DETAILS_rec.currency_header_id IS NULL )
    THEN
        IF NOT QP_Validate.Currency_Header(p_CURR_DETAILS_rec.currency_header_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.end_date_active IS NOT NULL AND
        (   p_CURR_DETAILS_rec.end_date_active <>
            p_old_CURR_DETAILS_rec.end_date_active OR
            p_old_CURR_DETAILS_rec.end_date_active IS NULL )
    THEN
        IF NOT QP_Validate.End_Date_Active(p_CURR_DETAILS_rec.end_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.fixed_value IS NOT NULL AND
        (   p_CURR_DETAILS_rec.fixed_value <>
            p_old_CURR_DETAILS_rec.fixed_value OR
            p_old_CURR_DETAILS_rec.fixed_value IS NULL )
    THEN
        IF NOT QP_Validate.Fixed_Value(p_CURR_DETAILS_rec.fixed_value) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.last_updated_by IS NOT NULL AND
        (   p_CURR_DETAILS_rec.last_updated_by <>
            p_old_CURR_DETAILS_rec.last_updated_by OR
            p_old_CURR_DETAILS_rec.last_updated_by IS NULL )
    THEN
        IF NOT QP_Validate.Last_Updated_By(p_CURR_DETAILS_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.last_update_date IS NOT NULL AND
        (   p_CURR_DETAILS_rec.last_update_date <>
            p_old_CURR_DETAILS_rec.last_update_date OR
            p_old_CURR_DETAILS_rec.last_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Date(p_CURR_DETAILS_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.last_update_login IS NOT NULL AND
        (   p_CURR_DETAILS_rec.last_update_login <>
            p_old_CURR_DETAILS_rec.last_update_login OR
            p_old_CURR_DETAILS_rec.last_update_login IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Login(p_CURR_DETAILS_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.markup_formula_id IS NOT NULL AND
        (   p_CURR_DETAILS_rec.markup_formula_id <>
            p_old_CURR_DETAILS_rec.markup_formula_id OR
            p_old_CURR_DETAILS_rec.markup_formula_id IS NULL )
    THEN
        IF NOT QP_Validate.Markup_Formula(p_CURR_DETAILS_rec.markup_formula_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.markup_operator IS NOT NULL AND
        (   p_CURR_DETAILS_rec.markup_operator <>
            p_old_CURR_DETAILS_rec.markup_operator OR
            p_old_CURR_DETAILS_rec.markup_operator IS NULL )
    THEN
        IF NOT QP_Validate.Markup_Operator(p_CURR_DETAILS_rec.markup_operator) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.markup_value IS NOT NULL AND
        (   p_CURR_DETAILS_rec.markup_value <>
            p_old_CURR_DETAILS_rec.markup_value OR
            p_old_CURR_DETAILS_rec.markup_value IS NULL )
    THEN
        IF NOT QP_Validate.Markup_Value(p_CURR_DETAILS_rec.markup_value) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.price_formula_id IS NOT NULL AND
        (   p_CURR_DETAILS_rec.price_formula_id <>
            p_old_CURR_DETAILS_rec.price_formula_id OR
            p_old_CURR_DETAILS_rec.price_formula_id IS NULL )
    THEN
        IF NOT QP_Validate.Price_Formula(p_CURR_DETAILS_rec.price_formula_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.program_application_id IS NOT NULL AND
        (   p_CURR_DETAILS_rec.program_application_id <>
            p_old_CURR_DETAILS_rec.program_application_id OR
            p_old_CURR_DETAILS_rec.program_application_id IS NULL )
    THEN
        IF NOT QP_Validate.Program_Application(p_CURR_DETAILS_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.program_id IS NOT NULL AND
        (   p_CURR_DETAILS_rec.program_id <>
            p_old_CURR_DETAILS_rec.program_id OR
            p_old_CURR_DETAILS_rec.program_id IS NULL )
    THEN
        IF NOT QP_Validate.Program(p_CURR_DETAILS_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.program_update_date IS NOT NULL AND
        (   p_CURR_DETAILS_rec.program_update_date <>
            p_old_CURR_DETAILS_rec.program_update_date OR
            p_old_CURR_DETAILS_rec.program_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Program_Update_Date(p_CURR_DETAILS_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.request_id IS NOT NULL AND
        (   p_CURR_DETAILS_rec.request_id <>
            p_old_CURR_DETAILS_rec.request_id OR
            p_old_CURR_DETAILS_rec.request_id IS NULL )
    THEN
        IF NOT QP_Validate.Request(p_CURR_DETAILS_rec.request_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.rounding_factor IS NOT NULL AND
        (   p_CURR_DETAILS_rec.rounding_factor <>
            p_old_CURR_DETAILS_rec.rounding_factor OR
            p_old_CURR_DETAILS_rec.rounding_factor IS NULL )
    THEN
        IF NOT QP_Validate.Rounding_Factor(p_CURR_DETAILS_rec.rounding_factor) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.selling_rounding_factor IS NOT NULL AND
        (   p_CURR_DETAILS_rec.selling_rounding_factor <>
            p_old_CURR_DETAILS_rec.selling_rounding_factor OR
            p_old_CURR_DETAILS_rec.selling_rounding_factor IS NULL )
    THEN
        IF NOT QP_Validate.Rounding_Factor(p_CURR_DETAILS_rec.selling_rounding_factor) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.start_date_active IS NOT NULL AND
        (   p_CURR_DETAILS_rec.start_date_active <>
            p_old_CURR_DETAILS_rec.start_date_active OR
            p_old_CURR_DETAILS_rec.start_date_active IS NULL )
    THEN
        IF NOT QP_Validate.Start_Date_Active(p_CURR_DETAILS_rec.start_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.to_currency_code IS NOT NULL AND
        (   p_CURR_DETAILS_rec.to_currency_code <>
            p_old_CURR_DETAILS_rec.to_currency_code OR
            p_old_CURR_DETAILS_rec.to_currency_code IS NULL )
    THEN
        IF NOT QP_Validate.To_Currency(p_CURR_DETAILS_rec.to_currency_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.curr_attribute_type IS NOT NULL AND
        (   p_CURR_DETAILS_rec.curr_attribute_type <>
            p_old_CURR_DETAILS_rec.curr_attribute_type OR
            p_old_CURR_DETAILS_rec.curr_attribute_type IS NULL )
    THEN
        IF NOT QP_Validate.Curr_Attribute_Type(p_CURR_DETAILS_rec.curr_attribute_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.curr_attribute_context IS NOT NULL AND
        (   p_CURR_DETAILS_rec.curr_attribute_context <>
            p_old_CURR_DETAILS_rec.curr_attribute_context OR
            p_old_CURR_DETAILS_rec.curr_attribute_context IS NULL )
    THEN
        IF NOT QP_Validate.Curr_Attribute_Context(p_CURR_DETAILS_rec.curr_attribute_context) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.curr_attribute IS NOT NULL AND
        (   p_CURR_DETAILS_rec.curr_attribute <>
            p_old_CURR_DETAILS_rec.curr_attribute OR
            p_old_CURR_DETAILS_rec.curr_attribute IS NULL )
    THEN
        IF NOT QP_Validate.Curr_Attribute(p_CURR_DETAILS_rec.curr_attribute) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.curr_attribute_value IS NOT NULL AND
        (   p_CURR_DETAILS_rec.curr_attribute_value <>
            p_old_CURR_DETAILS_rec.curr_attribute_value OR
            p_old_CURR_DETAILS_rec.curr_attribute_value IS NULL )
    THEN
        IF NOT QP_Validate.Curr_Attribute_Value(p_CURR_DETAILS_rec.curr_attribute_value) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_CURR_DETAILS_rec.precedence IS NOT NULL AND
        (   p_CURR_DETAILS_rec.precedence <>
            p_old_CURR_DETAILS_rec.precedence OR
            p_old_CURR_DETAILS_rec.precedence IS NULL )
    THEN
        IF NOT QP_Validate.Precedence(p_CURR_DETAILS_rec.precedence) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  (p_CURR_DETAILS_rec.attribute1 IS NOT NULL AND
        (   p_CURR_DETAILS_rec.attribute1 <>
            p_old_CURR_DETAILS_rec.attribute1 OR
            p_old_CURR_DETAILS_rec.attribute1 IS NULL ))
    OR  (p_CURR_DETAILS_rec.attribute10 IS NOT NULL AND
        (   p_CURR_DETAILS_rec.attribute10 <>
            p_old_CURR_DETAILS_rec.attribute10 OR
            p_old_CURR_DETAILS_rec.attribute10 IS NULL ))
    OR  (p_CURR_DETAILS_rec.attribute11 IS NOT NULL AND
        (   p_CURR_DETAILS_rec.attribute11 <>
            p_old_CURR_DETAILS_rec.attribute11 OR
            p_old_CURR_DETAILS_rec.attribute11 IS NULL ))
    OR  (p_CURR_DETAILS_rec.attribute12 IS NOT NULL AND
        (   p_CURR_DETAILS_rec.attribute12 <>
            p_old_CURR_DETAILS_rec.attribute12 OR
            p_old_CURR_DETAILS_rec.attribute12 IS NULL ))
    OR  (p_CURR_DETAILS_rec.attribute13 IS NOT NULL AND
        (   p_CURR_DETAILS_rec.attribute13 <>
            p_old_CURR_DETAILS_rec.attribute13 OR
            p_old_CURR_DETAILS_rec.attribute13 IS NULL ))
    OR  (p_CURR_DETAILS_rec.attribute14 IS NOT NULL AND
        (   p_CURR_DETAILS_rec.attribute14 <>
            p_old_CURR_DETAILS_rec.attribute14 OR
            p_old_CURR_DETAILS_rec.attribute14 IS NULL ))
    OR  (p_CURR_DETAILS_rec.attribute15 IS NOT NULL AND
        (   p_CURR_DETAILS_rec.attribute15 <>
            p_old_CURR_DETAILS_rec.attribute15 OR
            p_old_CURR_DETAILS_rec.attribute15 IS NULL ))
    OR  (p_CURR_DETAILS_rec.attribute2 IS NOT NULL AND
        (   p_CURR_DETAILS_rec.attribute2 <>
            p_old_CURR_DETAILS_rec.attribute2 OR
            p_old_CURR_DETAILS_rec.attribute2 IS NULL ))
    OR  (p_CURR_DETAILS_rec.attribute3 IS NOT NULL AND
        (   p_CURR_DETAILS_rec.attribute3 <>
            p_old_CURR_DETAILS_rec.attribute3 OR
            p_old_CURR_DETAILS_rec.attribute3 IS NULL ))
    OR  (p_CURR_DETAILS_rec.attribute4 IS NOT NULL AND
        (   p_CURR_DETAILS_rec.attribute4 <>
            p_old_CURR_DETAILS_rec.attribute4 OR
            p_old_CURR_DETAILS_rec.attribute4 IS NULL ))
    OR  (p_CURR_DETAILS_rec.attribute5 IS NOT NULL AND
        (   p_CURR_DETAILS_rec.attribute5 <>
            p_old_CURR_DETAILS_rec.attribute5 OR
            p_old_CURR_DETAILS_rec.attribute5 IS NULL ))
    OR  (p_CURR_DETAILS_rec.attribute6 IS NOT NULL AND
        (   p_CURR_DETAILS_rec.attribute6 <>
            p_old_CURR_DETAILS_rec.attribute6 OR
            p_old_CURR_DETAILS_rec.attribute6 IS NULL ))
    OR  (p_CURR_DETAILS_rec.attribute7 IS NOT NULL AND
        (   p_CURR_DETAILS_rec.attribute7 <>
            p_old_CURR_DETAILS_rec.attribute7 OR
            p_old_CURR_DETAILS_rec.attribute7 IS NULL ))
    OR  (p_CURR_DETAILS_rec.attribute8 IS NOT NULL AND
        (   p_CURR_DETAILS_rec.attribute8 <>
            p_old_CURR_DETAILS_rec.attribute8 OR
            p_old_CURR_DETAILS_rec.attribute8 IS NULL ))
    OR  (p_CURR_DETAILS_rec.attribute9 IS NOT NULL AND
        (   p_CURR_DETAILS_rec.attribute9 <>
            p_old_CURR_DETAILS_rec.attribute9 OR
            p_old_CURR_DETAILS_rec.attribute9 IS NULL ))
    OR  (p_CURR_DETAILS_rec.context IS NOT NULL AND
        (   p_CURR_DETAILS_rec.context <>
            p_old_CURR_DETAILS_rec.context OR
            p_old_CURR_DETAILS_rec.context IS NULL ))
    THEN

    --  These calls are temporarily commented out

/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_CURR_DETAILS_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_CURR_DETAILS_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_CURR_DETAILS_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_CURR_DETAILS_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_CURR_DETAILS_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_CURR_DETAILS_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_CURR_DETAILS_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_CURR_DETAILS_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_CURR_DETAILS_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_CURR_DETAILS_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_CURR_DETAILS_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_CURR_DETAILS_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_CURR_DETAILS_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_CURR_DETAILS_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_CURR_DETAILS_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'CONTEXT'
        ,   column_value                  => p_CURR_DETAILS_rec.context
        );
*/

        --  Validate descriptive flexfield.

        IF NOT QP_Validate.Desc_Flex( 'CURR_DETAILS' ) THEN
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
,   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
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

END QP_Validate_Curr_Details;

/
