--------------------------------------------------------
--  DDL for Package Body QP_VALIDATE_PRICE_LIST_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_VALIDATE_PRICE_LIST_LINE" AS
/* $Header: QPXLPLLB.pls 120.5.12010000.2 2009/11/30 04:02:48 jputta ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Validate_Price_List_Line';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  QP_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_dummy_1                     VARCHAR2(1);
l_valid                       Number;
l_uom_code                    VARCHAR2(3);
l_hdr_start_date 			  DATE; -- 5040708
l_hdr_end_date 			  	  DATE; -- 5040708
BEGIN

    --  Check required attributes.

    IF  p_PRICE_LIST_LINE_rec.list_line_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_line_id');
            oe_msg_pub.Add;

        END IF;

    END IF;



    --  Check rest of required attributes here.
    --


    --  Return Error if a required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --
    --  Check conditionally required attributes here.
    --

	-- begin bug 5040708
	SELECT start_date_active, end_date_active INTO l_hdr_start_date, l_hdr_end_date FROM QP_LIST_HEADERS_ALL_B b
	WHERE b.list_header_id = p_PRICE_LIST_LINE_rec.list_header_id;

	-- validate PLL start date falls within PLH dates
/* bug 5111502
	IF (p_PRICE_LIST_LINE_rec.start_date_active IS NULL OR p_PRICE_LIST_LINE_rec.start_date_active=Fnd_Api.G_MISS_DATE)
	AND (l_hdr_start_date IS NOT NULL AND l_hdr_start_date <> Fnd_Api.G_MISS_DATE) THEN
		l_return_status := Fnd_Api.G_RET_STS_ERROR;
		Fnd_Message.SET_NAME('QP', 'QP_PLL_START_DATE_NOT_WITHIN');
	  	Oe_Msg_Pub.ADD;
       	RAISE Fnd_Api.G_EXC_ERROR;
	END IF;
*/
	IF (p_PRICE_LIST_LINE_rec.start_date_active IS NOT NULL AND p_PRICE_LIST_LINE_rec.start_date_active <> Fnd_Api.G_MISS_DATE)
	AND (l_hdr_start_date IS NOT NULL AND l_hdr_start_date <> Fnd_Api.G_MISS_DATE) THEN

		IF (l_hdr_end_date IS NULL OR l_hdr_end_date = Fnd_Api.G_MISS_DATE) THEN -- Hdr end date is null
			IF (p_PRICE_LIST_LINE_rec.start_date_active < l_hdr_start_date) THEN
       	  	 	l_return_status := Fnd_Api.G_RET_STS_ERROR;
	  		 	Fnd_Message.SET_NAME('QP', 'QP_PLL_START_DATE_NOT_WITHIN');
	  		 	Oe_Msg_Pub.ADD;
       		 	RAISE Fnd_Api.G_EXC_ERROR;
			END IF;
		ELSE -- PLH end date not null
			IF ((p_PRICE_LIST_LINE_rec.start_date_active < l_hdr_start_date) OR
			(p_PRICE_LIST_LINE_rec.start_date_active  > l_hdr_end_date)) THEN
				l_return_status := Fnd_Api.G_RET_STS_ERROR;
	  		 	Fnd_Message.SET_NAME('QP', 'QP_PLL_START_DATE_NOT_WITHIN');
	  		 	Oe_Msg_Pub.ADD;
       		 	RAISE Fnd_Api.G_EXC_ERROR;

			END IF;
		END IF; -- IF (l_hdr_end_date IS NULL OR...

	END IF; -- end PLL start date not null and PLH start date not null

	-- validate PLL end date falls within PLH dates
/* bug 5111502
	IF (p_PRICE_LIST_LINE_rec.end_date_active IS NULL OR p_PRICE_LIST_LINE_rec.end_date_active = Fnd_Api.G_MISS_DATE)
	AND (l_hdr_end_date IS NOT NULL AND l_hdr_end_date <> Fnd_Api.G_MISS_DATE) THEN
		l_return_status := Fnd_Api.G_RET_STS_ERROR;
		Fnd_Message.SET_NAME('QP', 'QP_PLL_END_DATE_NOT_WITHIN');
	  	Oe_Msg_Pub.ADD;
       	RAISE Fnd_Api.G_EXC_ERROR;
	END IF;
*/
	IF (p_PRICE_LIST_LINE_rec.end_date_active IS NOT NULL AND p_PRICE_LIST_LINE_rec.end_date_active <> Fnd_Api.G_MISS_DATE)
	AND (l_hdr_end_date IS NOT NULL AND l_hdr_end_date <> Fnd_Api.G_MISS_DATE) THEN
		IF ((p_PRICE_LIST_LINE_rec.end_date_active < l_hdr_start_date) OR
		(p_PRICE_LIST_LINE_rec.end_date_active  > l_hdr_end_date)) THEN
			l_return_status := Fnd_Api.G_RET_STS_ERROR;
	  		Fnd_Message.SET_NAME('QP', 'QP_PLL_END_DATE_NOT_WITHIN');
	  		Oe_Msg_Pub.ADD;
       		RAISE Fnd_Api.G_EXC_ERROR;
		END IF;
	END IF; -- end PLL end date not null and PLH end date not null
	-- end bug 5040708
/* 4936019
    -- block pricing
    -- check when changing BLOCK price break to UNIT price break
    -- select how many child price break lines already have BLOCK application method
    IF (p_PRICE_LIST_LINE_rec.arithmetic_operator = 'UNIT_PRICE') THEN
      SELECT count(*)
      INTO l_dummy_1
      FROM qp_price_breaks_v
      WHERE parent_list_line_id = p_PRICE_LIST_LINE_rec.list_line_id
        AND arithmetic_operator = 'BLOCK_PRICE';

      -- if any price breaks are BLOCK, prohibit changing parent line from BLOCK to UNIT!
      IF (TO_NUMBER(l_dummy_1) > 0) THEN
        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('QP','QP_CANNOT_CHANGE_APPL_METH');
          oe_msg_pub.Add;
        END IF;
        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF; -- if (to_number...)
    END IF; -- if (p_price_list_line...)

    -- block pricing
    -- check when changing block RANGE break to block POINT break
    -- select child price break lines are UNIT or have non-null recurring values
    IF (p_PRICE_LIST_LINE_rec.arithmetic_operator = 'BLOCK_PRICE' AND
        p_PRICE_LIST_LINE_rec.price_break_type_code = 'POINT')
    THEN
      SELECT count(*)
      INTO l_dummy_1
      FROM qp_price_breaks_v
      WHERE parent_list_line_id = p_PRICE_LIST_LINE_rec.list_line_id
        AND (arithmetic_operator = 'UNIT_PRICE' OR recurring_value IS NOT NULL);

      -- if any price breaks found, prohibit changing parent line from RANGE to POINT!
      IF (TO_NUMBER(l_dummy_1) > 0) THEN
        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('QP','QP_CANNOT_CHANGE_BREAK_TYPE');
          oe_msg_pub.Add;
        END IF;
        l_return_status := FND_API.G_RET_STS_ERROR;
      END IF; -- if (to_number...)
    END IF; -- if (p_price_list_line...)

    --
    -- return error for invalid conditionally required attributes
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
*/
    --
    --  Validate attribute dependencies here.
    --
        IF NOT QP_Validate.Start_Date_Active(p_PRICE_LIST_LINE_rec.start_date_active, p_PRICE_LIST_LINE_rec.end_date_active) THEN

            l_return_status := FND_API.G_RET_STS_ERROR;

            /*

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
            THEN

              FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_line_id');
              oe_msg_pub.Add;

            END IF;
            */

       END IF;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

     END IF;

    -- mkarya for bug 1906545, static formula attached should not has a line as 'MV'
    IF  p_PRICE_LIST_LINE_rec.generate_using_formula_id IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.generate_using_formula_id <>
            p_old_PRICE_LIST_LINE_rec.generate_using_formula_id OR
            p_old_PRICE_LIST_LINE_rec.generate_using_formula_id IS NULL )
    THEN
        BEGIN
          select 'X'
          into   l_dummy_1
          from   qp_price_formulas_b
          where  price_formula_id = p_PRICE_LIST_LINE_rec.generate_using_formula_id
            and    not exists (select price_formula_line_type_code
                               from   qp_price_formula_lines
                               where  price_formula_id = p_PRICE_LIST_LINE_rec.generate_using_formula_id
                               and    price_formula_line_type_code = 'MV' );
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             l_return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('QP','QP_INVALID_FORMULA_FOR_PL');
             OE_MSG_PUB.Add;
        END;

    END IF;

    -- mkarya for bug 1906545, dynamic formula attached should not has a line as 'MV'
    IF  p_PRICE_LIST_LINE_rec.price_by_formula_id IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.price_by_formula_id <>
            p_old_PRICE_LIST_LINE_rec.price_by_formula_id OR
            p_old_PRICE_LIST_LINE_rec.price_by_formula_id IS NULL )
    THEN
        BEGIN
          select 'X'
          into   l_dummy_1
          from   qp_price_formulas_b
          where  price_formula_id = p_PRICE_LIST_LINE_rec.price_by_formula_id
            and    not exists (select price_formula_line_type_code
                               from   qp_price_formula_lines
                               where  price_formula_id = p_PRICE_LIST_LINE_rec.price_by_formula_id
                               and    price_formula_line_type_code = 'MV' );
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             l_return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('QP','QP_INVALID_FORMULA_FOR_PL');
             OE_MSG_PUB.Add;
        END;
    END IF;



   /* Added for bug2002487 */

    IF  p_PRICE_LIST_LINE_rec.list_line_type_code='PLL'
      and p_PRICE_LIST_LINE_rec.operand IS NULL
      and p_PRICE_LIST_LINE_rec.price_by_formula_id IS NULL
      and p_PRICE_LIST_LINE_rec.generate_using_formula_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;
	if  p_PRICE_LIST_LINE_rec.arithmetic_operator = 'UNIT_PRICE' then -- Added by DKC for ER # 6111123
		IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
		THEN

		    FND_MESSAGE.SET_NAME('QP','QP_OPERAND_FORMULA');
		    oe_msg_pub.Add;
		    l_return_status := FND_API.G_RET_STS_ERROR;

		END IF;
	else --- This validation works only for only PRICE breaks lines as the arithmetic operator couldnt be block price for PLL. changes for ER # 6111123
		IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
		THEN
		     FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
		      FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Price');
		      oe_msg_pub.Add;
		      l_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	end if;
	-- end of changes for ER # 6111123
    END IF;

    -- block pricing
    IF NOT QP_Validate.Recurring_Value(p_PRICE_LIST_LINE_rec.recurring_value)
    THEN
      l_return_status := FND_API.G_RET_STS_ERROR;

      IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
      THEN
        FND_MESSAGE.SET_NAME('QP','QP_INVALID_RECURRING_VALUE');
        oe_msg_pub.Add;
      END IF;
    END IF;

    -- OKS proration
    IF  QP_CODE_CONTROL.CODE_RELEASE_LEVEL < '110510' or
	nvl(fnd_profile.value('QP_BREAK_UOM_PRORATION'),'N') = 'N'
       OR p_PRICE_LIST_LINE_rec.list_line_type_code <> 'PBH'
	  OR p_PRICE_LIST_LINE_rec.arithmetic_operator <> 'UNIT_PRICE' THEN

       IF p_PRICE_LIST_LINE_rec.break_uom_code is not null
	  OR p_PRICE_LIST_LINE_rec.break_uom_context is not null
            OR p_PRICE_LIST_LINE_rec.break_uom_attribute is not null
       THEN

	  l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_BREAK_UOM_NOT_ALLOWED');
            oe_msg_pub.Add;
            l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

       END IF;
    END IF;

    IF p_PRICE_LIST_LINE_rec.break_uom_code is not null
	  OR p_PRICE_LIST_LINE_rec.break_uom_context is not null
	  OR p_PRICE_LIST_LINE_rec.break_uom_attribute is not null
    THEN

       IF p_PRICE_LIST_LINE_rec.break_uom_code is  null
	  OR p_PRICE_LIST_LINE_rec.break_uom_context is  null
          OR p_PRICE_LIST_LINE_rec.break_uom_attribute is null
       THEN
	  l_return_status := FND_API.G_RET_STS_ERROR;

          IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
          THEN
            FND_MESSAGE.SET_NAME('QP','QP_BREAK_UOM_FLDS_NOT_ALLOWED');
            oe_msg_pub.Add;
            l_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

      END IF;
    END IF;

    IF p_PRICE_LIST_LINE_rec.break_uom_code IS NOT NULL THEN
       Begin
	   SELECT uom_code
	     INTO l_uom_code
	     FROM mtl_units_of_measure_vl
	     WHERE uom_code = p_PRICE_LIST_LINE_rec.break_uom_code
	     AND rownum<2;
	Exception
	   when no_data_found then
	      l_return_status := FND_API.G_RET_STS_ERROR;

	      IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
	      THEN
		 FND_MESSAGE.SET_NAME('QP','QP_INVALID_BREAK_UOM_CODE');
		 oe_msg_pub.Add;
		 l_return_status := FND_API.G_RET_STS_ERROR;
       	      END IF;
	END;
    END IF;

    --END OKS changes

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

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;

END Entity;

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  QP_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
)
IS
  l_dummy_1    varchar2(1);
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate PRICE_LIST_LINE attributes

/*
    IF  p_PRICE_LIST_LINE_rec.accrual_qty IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.accrual_qty <>
            p_old_PRICE_LIST_LINE_rec.accrual_qty OR
            p_old_PRICE_LIST_LINE_rec.accrual_qty IS NULL )
    THEN
        IF NOT QP_Validate.Accrual_Qty(p_PRICE_LIST_LINE_rec.accrual_qty) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    IF  p_PRICE_LIST_LINE_rec.accrual_uom_code IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.accrual_uom_code <>
            p_old_PRICE_LIST_LINE_rec.accrual_uom_code OR
            p_old_PRICE_LIST_LINE_rec.accrual_uom_code IS NULL )
    THEN
        IF NOT QP_Validate.Accrual_Uom(p_PRICE_LIST_LINE_rec.accrual_uom_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

*/


    /* changes to fix bug # 1688666 */

       IF FND_PROFILE.VALUE('QP_NEGATIVE_PRICING') = 'N' AND p_PRICE_LIST_LINE_rec.operand < 0 THEN
            FND_MESSAGE.SET_NAME('QP','SO_PR_NEGATIVE_LIST_PRICE');
            OE_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;


    IF  p_PRICE_LIST_LINE_rec.arithmetic_operator IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.arithmetic_operator <>
            p_old_PRICE_LIST_LINE_rec.arithmetic_operator OR
            p_old_PRICE_LIST_LINE_rec.arithmetic_operator IS NULL )
    THEN
        IF NOT QP_Validate.Arithmetic_Operator(p_PRICE_LIST_LINE_rec.arithmetic_operator) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_rec.automatic_flag IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.automatic_flag <>
            p_old_PRICE_LIST_LINE_rec.automatic_flag OR
            p_old_PRICE_LIST_LINE_rec.automatic_flag IS NULL )
    THEN
        IF NOT QP_Validate.Automatic(p_PRICE_LIST_LINE_rec.automatic_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    /*

    IF  p_PRICE_LIST_LINE_rec.base_qty IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.base_qty <>
            p_old_PRICE_LIST_LINE_rec.base_qty OR
            p_old_PRICE_LIST_LINE_rec.base_qty IS NULL )
    THEN
        IF NOT QP_Validate.Base_Qty(p_PRICE_LIST_LINE_rec.base_qty) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    */

    /*
    IF  p_PRICE_LIST_LINE_rec.base_uom_code IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.base_uom_code <>
            p_old_PRICE_LIST_LINE_rec.base_uom_code OR
            p_old_PRICE_LIST_LINE_rec.base_uom_code IS NULL )
    THEN
        IF NOT QP_Validate.Base_Uom(p_PRICE_LIST_LINE_rec.base_uom_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    */

    IF  p_PRICE_LIST_LINE_rec.comments IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.comments <>
            p_old_PRICE_LIST_LINE_rec.comments OR
            p_old_PRICE_LIST_LINE_rec.comments IS NULL )
    THEN
        IF NOT QP_Validate.Comments(p_PRICE_LIST_LINE_rec.comments) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.created_by IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.created_by <>
            p_old_PRICE_LIST_LINE_rec.created_by OR
            p_old_PRICE_LIST_LINE_rec.created_by IS NULL )
    THEN
        IF NOT QP_Validate.Created_By(p_PRICE_LIST_LINE_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.creation_date IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.creation_date <>
            p_old_PRICE_LIST_LINE_rec.creation_date OR
            p_old_PRICE_LIST_LINE_rec.creation_date IS NULL )
    THEN
        IF NOT QP_Validate.Creation_Date(p_PRICE_LIST_LINE_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.effective_period_uom IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.effective_period_uom <>
            p_old_PRICE_LIST_LINE_rec.effective_period_uom OR
            p_old_PRICE_LIST_LINE_rec.effective_period_uom IS NULL )
    THEN
        IF NOT QP_Validate.Effective_Period_Uom(p_PRICE_LIST_LINE_rec.effective_period_uom) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.end_date_active IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.end_date_active <>
            p_old_PRICE_LIST_LINE_rec.end_date_active OR
            p_old_PRICE_LIST_LINE_rec.end_date_active IS NULL )
    THEN
        IF NOT QP_Validate.End_Date_Active(p_PRICE_LIST_LINE_rec.end_date_active, p_PRICE_LIST_LINE_rec.start_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.estim_accrual_rate IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.estim_accrual_rate <>
            p_old_PRICE_LIST_LINE_rec.estim_accrual_rate OR
            p_old_PRICE_LIST_LINE_rec.estim_accrual_rate IS NULL )
    THEN
        IF NOT QP_Validate.Estim_Accrual_Rate(p_PRICE_LIST_LINE_rec.estim_accrual_rate) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.generate_using_formula_id IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.generate_using_formula_id <>
            p_old_PRICE_LIST_LINE_rec.generate_using_formula_id OR
            p_old_PRICE_LIST_LINE_rec.generate_using_formula_id IS NULL )
    THEN
        IF NOT QP_Validate.Generate_Using_Formula(p_PRICE_LIST_LINE_rec.generate_using_formula_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.inventory_item_id IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.inventory_item_id <>
            p_old_PRICE_LIST_LINE_rec.inventory_item_id OR
            p_old_PRICE_LIST_LINE_rec.inventory_item_id IS NULL )
    THEN
        IF NOT QP_Validate.Inventory_Item(p_PRICE_LIST_LINE_rec.inventory_item_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.last_updated_by IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.last_updated_by <>
            p_old_PRICE_LIST_LINE_rec.last_updated_by OR
            p_old_PRICE_LIST_LINE_rec.last_updated_by IS NULL )
    THEN
        IF NOT QP_Validate.Last_Updated_By(p_PRICE_LIST_LINE_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.last_update_date IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.last_update_date <>
            p_old_PRICE_LIST_LINE_rec.last_update_date OR
            p_old_PRICE_LIST_LINE_rec.last_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Date(p_PRICE_LIST_LINE_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.last_update_login IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.last_update_login <>
            p_old_PRICE_LIST_LINE_rec.last_update_login OR
            p_old_PRICE_LIST_LINE_rec.last_update_login IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Login(p_PRICE_LIST_LINE_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.list_header_id IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.list_header_id <>
            p_old_PRICE_LIST_LINE_rec.list_header_id OR
            p_old_PRICE_LIST_LINE_rec.list_header_id IS NULL )
    THEN
        IF NOT QP_Validate.List_Header(p_PRICE_LIST_LINE_rec.list_header_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.list_line_id IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.list_line_id <>
            p_old_PRICE_LIST_LINE_rec.list_line_id OR
            p_old_PRICE_LIST_LINE_rec.list_line_id IS NULL )
    THEN
        IF NOT QP_Validate.List_Line(p_PRICE_LIST_LINE_rec.list_line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.list_line_type_code IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.list_line_type_code <>
            p_old_PRICE_LIST_LINE_rec.list_line_type_code OR
            p_old_PRICE_LIST_LINE_rec.list_line_type_code IS NULL )
    THEN
        IF NOT QP_Validate.List_Line_Type(p_PRICE_LIST_LINE_rec.list_line_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.list_price IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.list_price <>
            p_old_PRICE_LIST_LINE_rec.list_price OR
            p_old_PRICE_LIST_LINE_rec.list_price IS NULL )
    THEN
        IF NOT QP_Validate.List_Price(p_PRICE_LIST_LINE_rec.list_price) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.from_rltd_modifier_id IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.from_rltd_modifier_id <>
            p_old_PRICE_LIST_LINE_rec.from_rltd_modifier_id OR
            p_old_PRICE_LIST_LINE_rec.from_rltd_modifier_id IS NULL )
    THEN
        /*
        IF NOT QP_Validate.From_Rltd_Modifier_Id(p_PRICE_LIST_LINE_rec.from_rltd_modifier_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        */
        NULL;

    END IF;

    IF  p_PRICE_LIST_LINE_rec.rltd_modifier_group_no IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.rltd_modifier_group_no <>
            p_old_PRICE_LIST_LINE_rec.rltd_modifier_group_no OR
            p_old_PRICE_LIST_LINE_rec.rltd_modifier_group_no IS NULL )
    THEN
        /*
        IF NOT QP_Validate.Rltd_Modifier_Group_No(p_PRICE_LIST_LINE_rec.rltd_modifier_group_no) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        */

        NULL;

    END IF;

    IF  p_PRICE_LIST_LINE_rec.product_precedence IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.product_precedence <>
            p_old_PRICE_LIST_LINE_rec.product_precedence OR
            p_old_PRICE_LIST_LINE_rec.product_precedence IS NULL )
    THEN
        /*
        IF NOT QP_Validate.Product_Precedence(p_PRICE_LIST_LINE_rec.product_precedence) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        */
        NULL;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.modifier_level_code IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.modifier_level_code <>
            p_old_PRICE_LIST_LINE_rec.modifier_level_code OR
            p_old_PRICE_LIST_LINE_rec.modifier_level_code IS NULL )
    THEN
        IF NOT QP_Validate.Modifier_Level(p_PRICE_LIST_LINE_rec.modifier_level_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.number_effective_periods IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.number_effective_periods <>
            p_old_PRICE_LIST_LINE_rec.number_effective_periods OR
            p_old_PRICE_LIST_LINE_rec.number_effective_periods IS NULL )
    THEN
        IF NOT QP_Validate.Number_Effective_Periods(p_PRICE_LIST_LINE_rec.number_effective_periods) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.operand IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.operand <>
            p_old_PRICE_LIST_LINE_rec.operand OR
            p_old_PRICE_LIST_LINE_rec.operand IS NULL )
    THEN
        IF NOT QP_Validate.Operand(p_PRICE_LIST_LINE_rec.operand) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.organization_id IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.organization_id <>
            p_old_PRICE_LIST_LINE_rec.organization_id OR
            p_old_PRICE_LIST_LINE_rec.organization_id IS NULL )
    THEN
        IF NOT QP_Validate.Organization(p_PRICE_LIST_LINE_rec.organization_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.override_flag IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.override_flag <>
            p_old_PRICE_LIST_LINE_rec.override_flag OR
            p_old_PRICE_LIST_LINE_rec.override_flag IS NULL )
    THEN
        IF NOT QP_Validate.Override(p_PRICE_LIST_LINE_rec.override_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.percent_price IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.percent_price <>
            p_old_PRICE_LIST_LINE_rec.percent_price OR
            p_old_PRICE_LIST_LINE_rec.percent_price IS NULL )
    THEN
        IF NOT QP_Validate.Percent_Price(p_PRICE_LIST_LINE_rec.percent_price) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.price_break_type_code IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.price_break_type_code <>
            p_old_PRICE_LIST_LINE_rec.price_break_type_code OR
            p_old_PRICE_LIST_LINE_rec.price_break_type_code IS NULL )
    THEN
        IF NOT QP_Validate.Price_Break_Type(p_PRICE_LIST_LINE_rec.price_break_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.price_by_formula_id IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.price_by_formula_id <>
            p_old_PRICE_LIST_LINE_rec.price_by_formula_id OR
            p_old_PRICE_LIST_LINE_rec.price_by_formula_id IS NULL )
    THEN
        IF NOT QP_Validate.Price_By_Formula(p_PRICE_LIST_LINE_rec.price_by_formula_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.primary_uom_flag IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.primary_uom_flag <>
            p_old_PRICE_LIST_LINE_rec.primary_uom_flag OR
            p_old_PRICE_LIST_LINE_rec.primary_uom_flag IS NULL )
    THEN
        IF NOT QP_Validate.Primary_Uom(p_PRICE_LIST_LINE_rec.primary_uom_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.print_on_invoice_flag IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.print_on_invoice_flag <>
            p_old_PRICE_LIST_LINE_rec.print_on_invoice_flag OR
            p_old_PRICE_LIST_LINE_rec.print_on_invoice_flag IS NULL )
    THEN
        IF NOT QP_Validate.Print_On_Invoice(p_PRICE_LIST_LINE_rec.print_on_invoice_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.program_application_id IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.program_application_id <>
            p_old_PRICE_LIST_LINE_rec.program_application_id OR
            p_old_PRICE_LIST_LINE_rec.program_application_id IS NULL )
    THEN
        IF NOT QP_Validate.Program_Application(p_PRICE_LIST_LINE_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.program_id IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.program_id <>
            p_old_PRICE_LIST_LINE_rec.program_id OR
            p_old_PRICE_LIST_LINE_rec.program_id IS NULL )
    THEN
        IF NOT QP_Validate.Program(p_PRICE_LIST_LINE_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.program_update_date IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.program_update_date <>
            p_old_PRICE_LIST_LINE_rec.program_update_date OR
            p_old_PRICE_LIST_LINE_rec.program_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Program_Update_Date(p_PRICE_LIST_LINE_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.rebate_trxn_type_code IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.rebate_trxn_type_code <>
            p_old_PRICE_LIST_LINE_rec.rebate_trxn_type_code OR
            p_old_PRICE_LIST_LINE_rec.rebate_trxn_type_code IS NULL )
    THEN
        IF NOT QP_Validate.Rebate_Transaction_Type(p_PRICE_LIST_LINE_rec.rebate_trxn_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    -- block pricing
    IF p_PRICE_LIST_LINE_rec.recurring_value IS NOT NULL AND
       (p_PRICE_LIST_LINE_rec.recurring_value <> p_old_PRICE_LIST_LINE_rec.recurring_value OR
        p_old_PRICE_LIST_LINE_rec.recurring_value IS NULL)
    THEN
      IF NOT QP_Validate.recurring_value(p_PRICE_LIST_LINE_rec.recurring_value) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.related_item_id IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.related_item_id <>
            p_old_PRICE_LIST_LINE_rec.related_item_id OR
            p_old_PRICE_LIST_LINE_rec.related_item_id IS NULL )
    THEN
        IF NOT QP_Validate.Related_Item(p_PRICE_LIST_LINE_rec.related_item_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.relationship_type_id IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.relationship_type_id <>
            p_old_PRICE_LIST_LINE_rec.relationship_type_id OR
            p_old_PRICE_LIST_LINE_rec.relationship_type_id IS NULL )
    THEN
        IF NOT QP_Validate.Relationship_Type(p_PRICE_LIST_LINE_rec.relationship_type_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.reprice_flag IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.reprice_flag <>
            p_old_PRICE_LIST_LINE_rec.reprice_flag OR
            p_old_PRICE_LIST_LINE_rec.reprice_flag IS NULL )
    THEN
        IF NOT QP_Validate.Reprice(p_PRICE_LIST_LINE_rec.reprice_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.request_id IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.request_id <>
            p_old_PRICE_LIST_LINE_rec.request_id OR
            p_old_PRICE_LIST_LINE_rec.request_id IS NULL )
    THEN
        IF NOT QP_Validate.Request(p_PRICE_LIST_LINE_rec.request_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.revision IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.revision <>
            p_old_PRICE_LIST_LINE_rec.revision OR
            p_old_PRICE_LIST_LINE_rec.revision IS NULL )
    THEN
        IF NOT QP_Validate.Revision(p_PRICE_LIST_LINE_rec.revision) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.revision_date IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.revision_date <>
            p_old_PRICE_LIST_LINE_rec.revision_date OR
            p_old_PRICE_LIST_LINE_rec.revision_date IS NULL )
    THEN
        IF NOT QP_Validate.Revision_Date(p_PRICE_LIST_LINE_rec.revision_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.revision_reason_code IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.revision_reason_code <>
            p_old_PRICE_LIST_LINE_rec.revision_reason_code OR
            p_old_PRICE_LIST_LINE_rec.revision_reason_code IS NULL )
    THEN
        IF NOT QP_Validate.Revision_Reason(p_PRICE_LIST_LINE_rec.revision_reason_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.start_date_active IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.start_date_active <>
            p_old_PRICE_LIST_LINE_rec.start_date_active OR
            p_old_PRICE_LIST_LINE_rec.start_date_active IS NULL )
    THEN
        IF NOT QP_Validate.Start_Date_Active(p_PRICE_LIST_LINE_rec.start_date_active, p_PRICE_LIST_LINE_rec.end_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.substitution_attribute IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.substitution_attribute <>
            p_old_PRICE_LIST_LINE_rec.substitution_attribute OR
            p_old_PRICE_LIST_LINE_rec.substitution_attribute IS NULL )
    THEN
        IF NOT QP_Validate.Substitution_Attribute(p_PRICE_LIST_LINE_rec.substitution_attribute) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.substitution_context IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.substitution_context <>
            p_old_PRICE_LIST_LINE_rec.substitution_context OR
            p_old_PRICE_LIST_LINE_rec.substitution_context IS NULL )
    THEN
        IF NOT QP_Validate.Substitution_Context(p_PRICE_LIST_LINE_rec.substitution_context) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.substitution_value IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.substitution_value <>
            p_old_PRICE_LIST_LINE_rec.substitution_value OR
            p_old_PRICE_LIST_LINE_rec.substitution_value IS NULL )
    THEN
        IF NOT QP_Validate.Substitution_Value(p_PRICE_LIST_LINE_rec.substitution_value) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    -- Blanket Pricing
    IF p_PRICE_LIST_LINE_rec.CUSTOMER_ITEM_ID IS NOT NULL AND
       (    p_PRICE_LIST_LINE_rec.CUSTOMER_ITEM_ID <>
            p_old_PRICE_LIST_LINE_rec.CUSTOMER_ITEM_ID OR
            p_old_PRICE_LIST_LINE_rec.CUSTOMER_ITEM_ID IS NULL)
    THEN
        IF NOT QP_Validate.customer_item_id(p_PRICE_LIST_LINE_rec.CUSTOMER_ITEM_ID) THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
     -- OKS proration
    IF  p_PRICE_LIST_LINE_rec.break_uom_code IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.break_uom_code <>
            p_old_PRICE_LIST_LINE_rec.break_uom_code OR
            p_old_PRICE_LIST_LINE_rec.break_uom_code IS NULL )
    THEN
        IF NOT QP_Validate.Break_UOM_Code(p_PRICE_LIST_LINE_rec.break_uom_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.break_uom_context IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.break_uom_context <>
            p_old_PRICE_LIST_LINE_rec.break_uom_context OR
            p_old_PRICE_LIST_LINE_rec.break_uom_context IS NULL )
    THEN
        IF NOT QP_Validate.Break_UOM_Context(p_PRICE_LIST_LINE_rec.break_uom_context) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_LINE_rec.break_uom_attribute IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.break_uom_attribute <>
            p_old_PRICE_LIST_LINE_rec.break_uom_attribute OR
            p_old_PRICE_LIST_LINE_rec.break_uom_attribute IS NULL )
    THEN
        IF NOT QP_Validate.Break_UOM_Attribute(p_PRICE_LIST_LINE_rec.break_uom_attribute) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  (p_PRICE_LIST_LINE_rec.attribute1 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute1 <>
            p_old_PRICE_LIST_LINE_rec.attribute1 OR
            p_old_PRICE_LIST_LINE_rec.attribute1 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute10 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute10 <>
            p_old_PRICE_LIST_LINE_rec.attribute10 OR
            p_old_PRICE_LIST_LINE_rec.attribute10 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute11 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute11 <>
            p_old_PRICE_LIST_LINE_rec.attribute11 OR
            p_old_PRICE_LIST_LINE_rec.attribute11 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute12 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute12 <>
            p_old_PRICE_LIST_LINE_rec.attribute12 OR
            p_old_PRICE_LIST_LINE_rec.attribute12 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute13 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute13 <>
            p_old_PRICE_LIST_LINE_rec.attribute13 OR
            p_old_PRICE_LIST_LINE_rec.attribute13 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute14 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute14 <>
            p_old_PRICE_LIST_LINE_rec.attribute14 OR
            p_old_PRICE_LIST_LINE_rec.attribute14 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute15 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute15 <>
            p_old_PRICE_LIST_LINE_rec.attribute15 OR
            p_old_PRICE_LIST_LINE_rec.attribute15 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute2 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute2 <>
            p_old_PRICE_LIST_LINE_rec.attribute2 OR
            p_old_PRICE_LIST_LINE_rec.attribute2 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute3 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute3 <>
            p_old_PRICE_LIST_LINE_rec.attribute3 OR
            p_old_PRICE_LIST_LINE_rec.attribute3 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute4 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute4 <>
            p_old_PRICE_LIST_LINE_rec.attribute4 OR
            p_old_PRICE_LIST_LINE_rec.attribute4 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute5 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute5 <>
            p_old_PRICE_LIST_LINE_rec.attribute5 OR
            p_old_PRICE_LIST_LINE_rec.attribute5 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute6 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute6 <>
            p_old_PRICE_LIST_LINE_rec.attribute6 OR
            p_old_PRICE_LIST_LINE_rec.attribute6 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute7 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute7 <>
            p_old_PRICE_LIST_LINE_rec.attribute7 OR
            p_old_PRICE_LIST_LINE_rec.attribute7 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute8 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute8 <>
            p_old_PRICE_LIST_LINE_rec.attribute8 OR
            p_old_PRICE_LIST_LINE_rec.attribute8 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.attribute9 IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.attribute9 <>
            p_old_PRICE_LIST_LINE_rec.attribute9 OR
            p_old_PRICE_LIST_LINE_rec.attribute9 IS NULL ))
    OR  (p_PRICE_LIST_LINE_rec.context IS NOT NULL AND
        (   p_PRICE_LIST_LINE_rec.context <>
            p_old_PRICE_LIST_LINE_rec.context OR
            p_old_PRICE_LIST_LINE_rec.context IS NULL ))
    THEN

    --  These calls are temporarily commented out

/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'CONTEXT'
        ,   column_value                  => p_PRICE_LIST_LINE_rec.context
        );
*/

        --  Validate descriptive flexfield.

        IF NOT QP_Validate.Desc_Flex( 'PRICE_LIST_LINE' ) THEN
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

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attributes'
            );
        END IF;

END Attributes;

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
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

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity_Delete'
            );
        END IF;

END Entity_Delete;

END QP_Validate_Price_List_Line;

/
