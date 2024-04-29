--------------------------------------------------------
--  DDL for Package Body QP_VALIDATE_PLL_PRICING_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_VALIDATE_PLL_PRICING_ATTR" AS
/* $Header: QPXLPLAB.pls 120.9.12010000.6 2009/12/15 09:14:20 kdurgasi ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'Qp_Validate_pll_pricing_attr';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICING_ATTR_rec              IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec          IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_revision VARCHAR2(30);
l_start_date_active DATE;
l_end_date_active DATE;
l_list_header_id NUMBER;
l_comparison_operator_code VARCHAR2(30);
l_error_code NUMBER;
l_precedence NUMBER;
l_datatype FND_FLEX_VALUE_SETS.Format_type%TYPE;
l_value_error                 VARCHAR2(1);
l_context_error               VARCHAR2(1);
l_attribute_error             VARCHAR2(1);
l_x_rows NUMBER := 0;
l_count  NUMBER := 0;
l_primary_uom_flag            VARCHAR2(1);
l_from_rltd_modifier_id  NUMBER;

l_context_type                VARCHAR2(30);
l_sourcing_enabled            VARCHAR2(1);
l_sourcing_status             VARCHAR2(1);
l_sourcing_method             VARCHAR2(30);

-- Modified by rassharm for Bug No 5457704
l_edate                       DATE;
l_sdate                       DATE;
l_min_date                    DATE;
l_max_date                    DATE;

l_pte_code                    VARCHAR2(30);
l_ss_code                     VARCHAR2(30);
l_fna_name                    VARCHAR2(4000);
l_fna_desc                    VARCHAR2(489);
l_fna_valid                   BOOLEAN;

l_dummy	varchar2(30);
l_continuous_price_break_flag     VARCHAR2(1); --Continuous Price Breaks
--start 8359896 smbalara
l_x_revision BOOLEAN;
l_x_effdates BOOLEAN;
l_x_dup_sdate DATE;
l_x_dup_edate DATE;
--end 8359896
BEGIN

    --  Check required attributes.

    IF  p_PRICING_ATTR_rec.pricing_attribute_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Pricing Attribute Id');
            oe_msg_pub.Add;

        END IF;

    END IF;

--5286339

 IF p_PRICING_ATTR_rec.operation = QP_GLOBALS.G_OPR_UPDATE
    THEN

    IF  nvl(p_old_PRICING_ATTR_rec.PRODUCT_ATTRIBUTE_CONTEXT,'X') <>
       nvl(p_PRICING_ATTR_rec.PRODUCT_ATTRIBUTE_CONTEXT,'X')
         THEN
       l_return_status := FND_API.G_RET_STS_ERROR;

       FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_ATTRIBUTE');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','product_attribute_context');
       OE_MSG_PUB.Add;

    END IF;

   IF  nvl(p_old_PRICING_ATTR_rec.PRODUCT_ATTRIBUTE,'X') <>
       nvl(p_PRICING_ATTR_rec.PRODUCT_ATTRIBUTE,'X')
         THEN
       l_return_status := FND_API.G_RET_STS_ERROR;

       FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_ATTRIBUTE');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','product_attribute');
       OE_MSG_PUB.Add;

   END IF;

   IF  nvl(p_old_PRICING_ATTR_rec.PRODUCT_ATTR_VALUE,9999999) <>
       nvl(p_PRICING_ATTR_rec.PRODUCT_ATTR_VALUE,9999999)
         THEN
       l_return_status := FND_API.G_RET_STS_ERROR;

       FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_ATTRIBUTE');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','product_attr_value');
       OE_MSG_PUB.Add;

   END IF;

  END IF;

--5286339

    IF p_PRICING_ATTR_rec.list_line_id IS NULL
    THEN
	 l_return_status := FND_API.G_RET_STS_ERROR;

	 IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
	 THEN
	   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','List Line Id');
	   oe_msg_pub.Add;
      END IF;
    END IF;

/*    IF p_PRICING_ATTR_rec.list_header_id IS NULL
    THEN
	 l_return_status := FND_API.G_RET_STS_ERROR;

	 IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
	 THEN
	   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','List Header Id');
	   oe_msg_pub.Add;
      END IF;
    END IF;
*/
    IF p_PRICING_ATTR_rec.pricing_phase_id IS NULL
    THEN
	 l_return_status := FND_API.G_RET_STS_ERROR;

	 IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
	 THEN
	   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Pricing Phase Id');
	   oe_msg_pub.Add;
      END IF;
    END IF;

    IF p_PRICING_ATTR_rec.excluder_flag IS NULL
    THEN
	 l_return_status := FND_API.G_RET_STS_ERROR;

	 IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
	 THEN
	   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('EXCLUDER_FLAG'));  -- Fix For Bug-1974413
	   oe_msg_pub.Add;
      END IF;
    ELSE

      IF (p_PRICING_ATTR_rec.excluder_flag not in ( 'Y', 'y', 'N', 'n' ) )
      THEN
	   l_return_status := FND_API.G_RET_STS_ERROR;
	   IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
	   THEN
		FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Excluder Flag');
		oe_msg_pub.Add;
        END IF;
      END IF;
    END IF;

    IF p_PRICING_ATTR_rec.product_attribute_context IS NULL
    THEN
	 l_return_status := FND_API.G_RET_STS_ERROR;

	 IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
	 THEN
	   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRODUCT_ATTRIBUTE_CONTEXT')); --Fix For Bug-1974413
	   oe_msg_pub.Add;
      END IF;
    END IF;

    IF p_PRICING_ATTR_rec.product_attribute IS NULL
    THEN
	 l_return_status := FND_API.G_RET_STS_ERROR;

	 IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
	 THEN
	   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRODUCT_ATTRIBUTE')); -- Fix For Bug-1974413
	   oe_msg_pub.Add;
      END IF;
    END IF;

    IF p_PRICING_ATTR_rec.product_attr_value IS NULL
    THEN
	 l_return_status := FND_API.G_RET_STS_ERROR;

	 IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
	 THEN
	   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRODUCT_ATTR_VALUE'));  -- Fix For Bug-1974413
	   oe_msg_pub.Add;
      END IF;
    END IF;

    IF p_PRICING_ATTR_rec.product_attribute_datatype IS NULL
    THEN
	 l_return_status := FND_API.G_RET_STS_ERROR;

	 IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
	 THEN
	   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Product Attribute Datatype');
	   oe_msg_pub.Add;
      END IF;
    END IF;

    IF p_PRICING_ATTR_rec.product_uom_code IS NULL
    THEN
	 l_return_status := FND_API.G_RET_STS_ERROR;

	 IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
	 THEN
	   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRODUCT_UOM_CODE'));  -- Fix For Bug-1974413
	   oe_msg_pub.Add;
      END IF;
    END IF;

    IF p_PRICING_ATTR_rec.attribute_grouping_no IS NULL
    THEN
	 l_return_status := FND_API.G_RET_STS_ERROR;

	 IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
	 THEN
	   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('ATTRIBUTE_GROUPING_NO')); -- Fix For Bug-1974413
	   oe_msg_pub.Add;
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
   OE_Debug_Pub.add ( 'Geresh :: Price Line ID Check '|| p_PRICING_ATTR_rec.list_line_id ) ;

    -- Functional Area Validation for Hierarchical Categories (sfiresto)
    IF p_PRICING_ATTR_rec.product_attribute_context = 'ITEM' AND
       p_PRICING_ATTR_rec.product_attribute = 'PRICING_ATTRIBUTE2' THEN
        BEGIN

          SELECT pte_code, source_system_code
          INTO l_pte_code, l_ss_code
          FROM qp_list_headers_b
          WHERE list_header_id = p_PRICING_ATTR_rec.list_header_id;

          QP_UTIL.Get_Item_Cat_Info(
             p_PRICING_ATTR_rec.product_attr_value,
             l_pte_code,
             l_ss_code,
             l_fna_name,
             l_fna_desc,
             l_fna_valid);

          IF NOT l_fna_valid THEN

            l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
              FND_MESSAGE.set_name('QP', 'QP_INVALID_CAT_FUNC_PTE');
              FND_MESSAGE.set_token('CATID', p_PRICING_ATTR_REC.product_attr_value);
              FND_MESSAGE.set_token('PTE', l_pte_code);
              FND_MESSAGE.set_token('SS', l_ss_code);
              OE_MSG_PUB.Add;
            END IF;

            RAISE FND_API.G_EXC_ERROR;

          END IF;

        END;
    END IF;

    /* Duplicate Check */

    BEGIN
	 SELECT primary_uom_flag
	 INTO   l_primary_uom_flag
	 FROM   qp_list_lines
	 WHERE  list_line_id = p_PRICING_ATTR_rec.list_line_id;

    EXCEPTION
	 WHEN OTHERS THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
    END;

/* Modified by rassharm for Bug No 5457704 to include effective dates check for primary UOM */

    select start_date_active, end_date_active , revision, list_header_id
    into l_start_date_active, l_end_date_active, l_revision, l_list_header_id
    from qp_list_lines
    where list_line_id = p_PRICING_ATTR_rec.list_line_id;


IF l_primary_uom_flag = 'Y'  AND p_PRICING_ATTR_rec.product_attribute <> 'PRICING_ATTRIBUTE3' THEN
	l_count:=0;
	for c1 in
	(
	select  b.list_line_id col2
	from    qp_pricing_attributes b, qp_list_lines c
	where 	b.list_line_id <> p_PRICING_ATTR_rec.list_line_id
	and     b.list_line_id=c.list_line_id
	and     c.primary_uom_flag='Y'
	and     b.product_attribute_context = p_PRICING_ATTR_rec.product_attribute_context
	and     b.product_attribute = p_PRICING_ATTR_rec.product_attribute
	and     b.product_attr_value = p_PRICING_ATTR_rec.product_attr_value
	and     b.list_header_id = p_PRICING_ATTR_rec.list_header_id
	AND     b.product_uom_code <> p_PRICING_ATTR_rec.product_uom_code  -- for bug 7135111
	)
	Loop
	/*----------------------------------------------*/
	l_min_date := to_date('01/01/1900', 'MM/DD/YYYY');
	l_max_date := to_date('12/31/9999', 'MM/DD/YYYY');
	/*--------------------------------------------*/
	begin
		SELECT  start_date_active, end_date_active
		into  l_sdate, l_edate
		from qp_list_lines
		where list_line_id = c1.col2;

		exception
		when no_data_found then
		null;
	end;


	IF ( nvl(l_Start_Date_Active, l_min_date) <= nvl(l_sdate, l_min_date))
	THEN
		l_min_date := nvl(l_Start_Date_Active, l_min_date);
	ELSE
		l_min_date := nvl(l_sdate, l_min_date);
	END IF;

	IF ( nvl(l_End_Date_Active, l_max_date) >= nvl(l_edate, l_max_date))
	THEN
		l_max_date := nvl(l_End_Date_Active, l_max_date);
	ELSE
		l_max_date := nvl(l_edate, l_max_date);
	END IF;


	if ( trunc(nvl(l_sdate, l_min_date)) between
	trunc(nvl(l_Start_Date_Active, l_min_date))
	and trunc(nvl(l_End_Date_Active, l_max_date)) )
	OR
	( trunc(nvl(l_edate, l_max_date)) between
	trunc(nvl(l_Start_Date_Active, l_min_date))
	and trunc(nvl(l_End_Date_Active, l_max_date)) )

	OR
	( trunc(nvl(l_sdate, l_min_date)) <=
	   nvl(l_Start_Date_Active,l_min_date)
	AND
	trunc(nvl(l_edate, l_max_date)) >=
	   nvl(l_End_Date_Active,l_max_date) )

	THEN
		l_count:=1;
		oe_debug_pub.add('Dates Overlapping' );
		oe_debug_pub.add('Product and UOM match hence check for Pricing attributes' );
		exit;
	end if;

	end loop;

	IF l_count > 0 THEN
		--Add check for Pricing attributes 8359896
		select start_date_active, end_date_active , revision, list_header_id
		into l_start_date_active, l_end_date_active, l_revision, l_list_header_id
		from qp_list_lines
		where list_line_id = p_PRICING_ATTR_rec.list_line_id;

		OE_Debug_Pub.add ( 'smbalara :: Value Set 1' || l_start_date_active || l_end_date_active );

		OE_Debug_Pub.add ( 'smbalara :: Value Set 2' || l_revision );

		if NOT( Qp_Validate_pll_pricing_attr.Check_Dup_Pra (l_start_date_active,
			 l_end_date_active,
			 l_revision,
			 p_PRICING_ATTR_rec.list_line_id ,
			 l_list_header_id ,
			 l_x_rows,
			 l_x_revision,
			 l_x_effdates,
			 l_x_dup_sdate,
			 l_x_dup_edate )
		) then

			OE_Debug_Pub.add ( 'smbalara :: l_x_rows ' || l_x_rows );
			if l_x_rows > 0 THEN
				OE_Debug_Pub.add ( 'smbalara :: PA match hence duplicate lines');
				IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
				THEN
					l_return_status := FND_API.G_RET_STS_ERROR;
					FND_MESSAGE.SET_NAME('QP','QP_DUP_PRICING_ATTR');
					OE_MSG_PUB.Add;
				end if;
			END If;
		ELSE
		--End check for Pricing attributes 8359896
			OE_Debug_Pub.add ( 'smbalara :: Only one primary uom allowed');
			l_return_status :=  FND_API.G_RET_STS_ERROR;
			IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
			   FND_MESSAGE.SET_NAME('QP','QP_UNIQUE_PRIMARY_UOM');
			   OE_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;
			END IF;
		END IF;--end if of Check_Dup_Pra
	END IF;--end if of l_count>0
END IF;--end if of Primary UOM

 /* End changes rassharm */


   /*  (sfiresto) Moving Item validation and UOM validtion code from Attributes procedure to Entity
    *  procedure for bug 4753707.
    */

--fix for bug 5390181
l_return_status := QP_UTIL.Validate_Item(p_PRICING_ATTR_rec.product_attribute_context,
                      p_PRICING_ATTR_rec.product_attribute,
                      p_PRICING_ATTR_rec.product_attr_value);


if (p_PRICING_ATTR_rec.product_attribute_context = 'ITEM') THEN
        if (p_PRICING_ATTR_rec.product_attribute = 'PRICING_ATTRIBUTE1') THEN
			begin
				/** 9210809 **/
			IF(fnd_global.resp_appl_id not in (178,201)) THEN
			      SELECT 'VALID' INTO l_dummy
				  FROM mtl_system_items_b
			      where inventory_item_id =
						p_PRICING_ATTR_rec.product_attr_value
				     AND NVL( CUSTOMER_ORDER_FLAG, 'Y' ) = 'Y'
					 and organization_id =
						fnd_profile.value('QP_ORGANIZATION_ID');
			ELSE
				SELECT 'VALID' INTO l_dummy
				  FROM mtl_system_items_b
			      where inventory_item_id =
						p_PRICING_ATTR_rec.product_attr_value
				     AND NVL(PURCHASING_ENABLED_FLAG,'N') = 'Y'
					 and organization_id =
						fnd_profile.value('QP_ORGANIZATION_ID');
			END IF;
			/** 9210809 **/

			exception
			  WHEN NO_DATA_FOUND THEN

	                    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                            THEN
                              FND_MESSAGE.SET_NAME('QP','QP_ITEM_NOT_VALID');
                              FND_MESSAGE.SET_TOKEN('ITEM_ID', p_PRICING_ATTR_rec.product_attr_value);
                              OE_MSG_PUB.Add;
                            END IF;
                            RAISE FND_API.G_EXC_ERROR;

		 	  when others then
			   null;
			end;
		end if;
end if;
-- inserted for validation with the mtl_system_items_b



--  Begin fix for bug#4039819
    if (p_PRICING_ATTR_rec.product_attribute_context = 'ITEM') THEN
        if (p_PRICING_ATTR_rec.product_attribute = 'PRICING_ATTRIBUTE1') THEN
        begin
		select 'VALID' INTO l_dummy
		from mtl_item_uoms_view
		where uom_code = p_PRICING_ATTR_rec.product_uom_code
		and organization_id = fnd_profile.value('QP_ORGANIZATION_ID')
		and inventory_item_id = p_PRICING_ATTR_rec.product_attr_value
                and rownum = 1;
	exception
		WHEN NO_DATA_FOUND THEN
                   IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
		     FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_UOM');
		     OE_MSG_PUB.Add;
		   END IF;
                   RAISE FND_API.G_EXC_ERROR;

                WHEN OTHERS THEN
		   null;
	end;
	-- Bug 6891094 :UOM validity check to be done only for new list lines and lines in which the UOM is updated.
	elsif (p_PRICING_ATTR_rec.product_attribute = 'PRICING_ATTRIBUTE2') THEN
		IF p_PRICING_ATTR_rec.product_uom_code IS NOT NULL AND
		( p_PRICING_ATTR_rec.product_uom_code <> p_old_PRICING_ATTR_rec.product_uom_code
		OR
		p_old_PRICING_ATTR_rec.product_uom_code IS NULL ) THEN
			IF NOT QP_VALIDATE.Product_Uom(p_pricing_attr_rec.product_uom_code,
							to_number(p_PRICING_ATTR_rec.product_attr_value),
							p_PRICING_ATTR_rec.list_header_id) THEN
				IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
					FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_UOM');
					OE_MSG_PUB.Add;
				END IF;
				RAISE FND_API.G_EXC_ERROR;
			END IF;
		END IF;
        -- End changes for bug 6891094
	/*
	 * Commented out for bug 4753707
         *
	      begin
		SELECT 'VALID' INTO l_dummy
		FROM MTL_UNITS_OF_MEASURE_VL MTLUOM2
		WHERE
		  EXISTS
		    (
		    SELECT /*+no_unnest*--/ 1
		    FROM MTL_SYSTEM_ITEMS_B MTLITM1,
			 MTL_UOM_CONVERSIONS MTLUCV
		    WHERE MTLUOM2.UOM_CODE = MTLUCV.UOM_CODE
                        AND MTLUOM2.UOM_CODE = p_PRICING_ATTR_rec.product_uom_code
			AND MTLITM1.organization_id = fnd_profile.value('QP_ORGANIZATION_ID')
			AND MTLITM1.inventory_item_id in
			(
		 	 SELECT inventory_item_id FROM mtl_item_categories
		 	 WHERE category_id = to_number(p_PRICING_ATTR_rec.product_attr_value)
		 	 AND organization_id = fnd_profile.value('QP_ORGANIZATION_ID')
			)
			AND NVL( MTLUCV.DISABLE_DATE, TRUNC(SYSDATE)+1 ) > TRUNC(SYSDATE)
			AND
			(
			    (
				MTLITM1.ALLOWED_UNITS_LOOKUP_CODE IN (1, 3)
				AND MTLUCV.INVENTORY_ITEM_ID = MTLITM1.INVENTORY_ITEM_ID
				OR
				(
				    MTLUCV.INVENTORY_ITEM_ID = 0
				    AND MTLUOM2.BASE_UOM_FLAG = 'Y'
				    AND MTLUOM2.UOM_CLASS = MTLUCV.UOM_CLASS
				    AND MTLUCV.UOM_CLASS IN
				    (
				    SELECT MTLPRI1.UOM_CLASS
				    FROM MTL_UNITS_OF_MEASURE MTLPRI1
				    WHERE MTLPRI1.UOM_CODE = MTLITM1.PRIMARY_UOM_CODE
				    )
				)
				OR
				(
				    MTLUCV.INVENTORY_ITEM_ID = 0
				    AND MTLUCV.UOM_CODE IN
				    (
				    SELECT MTLUCC1.TO_UOM_CODE
				    FROM MTL_UOM_CLASS_CONVERSIONS MTLUCC1
				    WHERE MTLUCC1.INVENTORY_ITEM_ID = MTLITM1.INVENTORY_ITEM_ID
				    AND NVL(MTLUCC1.DISABLE_DATE, TRUNC(SYSDATE)+1) > TRUNC(SYSDATE)
				    )
				)
			    )
			    OR
			    (
				MTLITM1.ALLOWED_UNITS_LOOKUP_CODE IN (2, 3)
				AND MTLUCV.INVENTORY_ITEM_ID = 0
				AND
				(
				    MTLUCV.UOM_CLASS IN
				    (
				    SELECT MTLUCC.TO_UOM_CLASS
				    FROM MTL_UOM_CLASS_CONVERSIONS MTLUCC
				    WHERE MTLUCC.INVENTORY_ITEM_ID = MTLITM1.INVENTORY_ITEM_ID
				    AND NVL(MTLUCC.DISABLE_DATE, TRUNC(SYSDATE)+1) > TRUNC(SYSDATE)
				    )
				    OR MTLUCV.UOM_CLASS =
				    (
				    SELECT MTLPRI.UOM_CLASS
				    FROM MTL_UNITS_OF_MEASURE MTLPRI
				    WHERE MTLPRI.UOM_CODE = MTLITM1.PRIMARY_UOM_CODE
				    )
				)
			    )
			)
		    )
                    and rownum = 1;
	exception
		WHEN NO_DATA_FOUND THEN
		   x_return_status := FND_API.G_RET_STS_ERROR;
		   FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_UOM');
		   OE_MSG_PUB.Add;
                WHEN OTHERS THEN
		   null;
	end;
	 *
	 */
	else
	begin
		select 'VALID' INTO l_dummy
		from MTL_UNITS_OF_MEASURE_VL
		where uom_code = p_PRICING_ATTR_rec.product_uom_code
		and rownum = 1;
	exception
		WHEN NO_DATA_FOUND THEN
                   IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
                     FND_MESSAGE.SET_NAME('QP','QP_INVALID_PROD_UOM');
                     OE_MSG_PUB.Add;
		   END IF;
                   RAISE FND_API.G_EXC_ERROR;

                WHEN OTHERS THEN
		   null;
	end;
	end if;
    end if;
--  End fix for bug#4039819
   /* (sfiresto) end movement of code from Attributes procedure to Entity procedure


/* modified IF condition by dhgupta for bug 1828734 */
/*
    IF l_primary_uom_flag = 'Y'  AND p_PRICING_ATTR_rec.product_attribute <> 'PRICING_ATTRIBUTE3'THEN

       BEGIN
         SELECT count(*)
	    INTO   l_count
         FROM   qp_list_lines l, qp_pricing_attributes a
         WHERE  l.list_line_id = a.list_line_id
	    AND    a.list_header_id = p_PRICING_ATTR_rec.list_header_id
         AND    a.product_attribute_context =
			    p_PRICING_ATTR_rec.product_attribute_context
         AND    a.product_attribute = p_PRICING_ATTR_rec.product_attribute
         AND    a.product_attr_value = p_PRICING_ATTR_rec.product_attr_value
	    AND    a.product_uom_code <> p_PRICING_ATTR_rec.product_uom_code
         AND    l.primary_uom_flag = 'Y';

	  EXCEPTION
         WHEN NO_DATA_FOUND THEN
		 l_count := 0;
       END;

       IF l_count > 0 THEN
		l_return_status :=  FND_API.G_RET_STS_ERROR;
		IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
		   FND_MESSAGE.SET_NAME('QP','QP_UNIQUE_PRIMARY_UOM');
		   OE_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
	  END IF;

    END IF;

    select start_date_active, end_date_active , revision, list_header_id
    into l_start_date_active, l_end_date_active, l_revision, l_list_header_id
    from qp_list_lines
    where list_line_id = p_PRICING_ATTR_rec.list_line_id;
*/
   OE_Debug_Pub.add ( 'Geresh :: Value Set 1' || l_start_date_active || l_end_date_active );

   OE_Debug_Pub.add ( 'Geresh :: Value Set 2' || l_revision );
/*
   if NOT( QP_CHECK_DUP_PRA.Check_Dup_Pra (
						l_start_date_active,
						l_end_date_active,
						l_revision,
            				p_PRICING_ATTR_rec.list_line_id ,
            				l_list_header_id ,
						l_x_rows )
		)   then

   OE_Debug_Pub.add ( 'Geresh :: Result ' || l_x_rows );
	if l_x_rows > 0 THEN

          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        	THEN
        		l_return_status := FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('QP','QP_DUP_PRICING_ATTR');
			OE_MSG_PUB.Add;
		end if;
	end if;


   end if;
*/
oe_debug_pub.add('G_CHECK_DUP_PRICELIST_LINES is '|| QP_GLOBALS.G_CHECK_DUP_PRICELIST_LINES); -- 5018856, 5024919
IF (QP_GLOBALS.G_CHECK_DUP_PRICELIST_LINES <> 'N' or QP_GLOBALS.G_CHECK_DUP_PRICELIST_LINES IS NULL)
THEN --5018856 , 5024919 only log request if not N or null
   oe_debug_pub.add('about to log a request to check duplicate list lines ');

   QP_DELAYED_REQUESTS_PVT.Log_Request
    ( p_entity_code		=> QP_GLOBALS.G_ENTITY_ALL
,     p_entity_id		=> p_PRICING_ATTR_rec.list_line_id
,   p_requesting_entity_code	=> QP_GLOBALS.G_ENTITY_PRICING_ATTR
,   p_requesting_entity_id	=> p_PRICING_ATTR_rec.pricing_attribute_id
,   p_request_type		=> QP_GLOBALS.G_DUPLICATE_LIST_LINES
,   p_param1			=> l_list_header_id
,   p_param2			=> fnd_date.date_to_canonical(l_start_date_active) 	--2739511
,   p_param3			=> fnd_date.date_to_canonical(l_end_date_active)	--2739511
,   p_param4			=> l_revision
,   x_return_status		=> l_return_status
);

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

	  oe_debug_pub.add('failed in logging a delayed request ');

        RAISE FND_API.G_EXC_ERROR;

    END IF;

  oe_debug_pub.add('after logging delayed request ');
END IF;-- end IF QP_GLOBALS.G_CHECK_DUP_PRICELIST_LINES <> 'N' or null-- 5108856

  IF (p_Pricing_Attr_rec.pricing_attribute_context IS NOT NULL
    OR p_Pricing_Attr_rec.pricing_attribute IS NOT NULL
    OR p_Pricing_Attr_rec.pricing_attr_value_from IS NOT NULL
    OR p_Pricing_Attr_rec.pricing_attr_value_to IS NOT NULL)
  THEN
    IF (p_Pricing_Attr_rec.pricing_attribute_context IS NULL
	 OR p_Pricing_Attr_rec.pricing_attribute IS NULL
	 OR p_Pricing_Attr_rec.comparison_operator_code IS NULL)
    THEN

	 l_return_status := FND_API.G_RET_STS_ERROR;
	 IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
	 THEN
	   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRICING_ATTRIBUTE_CONTEXT')||'/'||
                                            QP_PRC_UTIL.Get_Attribute_Name('PRICING_ATTRIBUTE')||'/'||
                                            QP_PRC_UTIL.Get_Attribute_Name('COMPARISON_OPERATOR_CODE')); -- Fix For Bug-1974413
	   OE_MSG_PUB.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    ELSE

	 IF   ( p_Pricing_Attr_rec.comparison_operator_code = 'BETWEEN'
	   AND  p_Pricing_Attr_rec.pricing_attribute_datatype is NULL ) THEN

		l_return_status := FND_API.G_RET_STS_ERROR;
     	 IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
     	  THEN
	     	FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
	          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Enter Required Values');
	          OE_MSG_PUB.Add;
            END IF;
		  RAISE FND_API.G_EXC_ERROR;
      END IF;

       QP_UTIL.validate_qp_flexfield(flexfield_name       =>'QP_ATTR_DEFNS_PRICING'
						 ,context                   =>p_Pricing_Attr_rec.pricing_attribute_context
						 ,attribute                 =>p_Pricing_Attr_rec.pricing_attribute
						 ,value                =>p_Pricing_Attr_rec.pricing_attr_value_from
                               ,application_short_name         => 'QP'
						 ,context_flag                   =>l_context_error
						 ,attribute_flag                 =>l_attribute_error
						 ,value_flag                     =>l_value_error
						 ,datatype                       =>l_datatype
						 ,precedence                      =>l_precedence
						 ,error_code                     =>l_error_code
						 );

       If (l_context_error = 'N'  AND l_error_code = 7)       --  invalid context
	  Then
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
               --FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRICING_ATTRIBUTE_CONTEXT')); --Fix For Bug-1974413

               OE_MSG_PUB.Add;
            END IF;

           RAISE FND_API.G_EXC_ERROR;

       End If;


       --dbms_output.put_line('for context '||l_return_status);

        --dbms_output.put_line('for context ,attribute,value,datatype,precedence');



       If l_attribute_error = 'N'   AND l_error_code = 8    --  invalid Attribute
	  Then
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE',' Attribute');
               OE_MSG_PUB.Add;
            END IF;

		  RAISE FND_API.G_EXC_ERROR;

       End If;


       --dbms_output.put_line('for attributr '||l_return_status);
       oe_debug_pub.add('for context '||l_return_status);


      --- validate qualifier_attr_value only if comparison operator is
	 --  '='

       IF p_Pricing_Attr_rec.comparison_operator_code = '=' Then

       If l_value_error = 'N'  AND l_error_code = 9      --  invalid value
	  Then
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE',' Value From ');
               --OE_MSG_PUB.Add;
               OE_MSG_PUB.Add;
            END IF;
		  RAISE FND_API.G_EXC_ERROR;
       End If;
       END IF;


       --dbms_output.put_line('for value,'||l_return_status);
       oe_debug_pub.add('for value,'||l_return_status);

      --dbms_output.put_line('org precede '||p_QUALIFIERS_rec.qualifier_precedence);
      --dbms_output.put_line('n precede '||l_precedence);

        --dbms_output.put_line('for precedence'||l_return_status);

       If p_Pricing_Attr_rec.pricing_attribute_datatype <> l_datatype   ---  invalid  datatype
	  Then
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
               --FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Pricing Attribute Datatype ');
               OE_MSG_PUB.Add;
            END IF;
		  RAISE FND_API.G_EXC_ERROR;

       End If;

       IF p_Pricing_Attr_rec.pricing_attribute_context = 'VOLUME' AND
	     p_Pricing_Attr_rec.pricing_attribute = 'PRICING_ATTRIBUTE12'
		   --When Pricing Context is 'Volume' and Attribute is 'Item Amount'
       THEN
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
              FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Pricing Attribute');
              OE_MSG_PUB.Add;
            END IF;

		  RAISE FND_API.G_EXC_ERROR;

       END IF;


       --dbms_output.put_line('for datatype,'||l_return_status);
        oe_debug_pub.add('qualifier datatype,'||l_return_status);



   --validation for canonical form

     l_error_code:=QP_UTIL.validate_num_date(p_Pricing_Attr_rec.pricing_attribute_datatype, p_Pricing_Attr_rec.pricing_attr_value_from);
	IF l_error_code  <> 0  THEN

		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Value From ');
               OE_MSG_PUB.Add;
            END IF;
		  RAISE FND_API.G_EXC_ERROR;

     END IF;
     --dbms_output.put_line('for cano of value from ,'||l_return_status);

   -- End of validation for canonical form on value from

   -- Validation for Value_To

	 IF p_Pricing_Attr_rec.pricing_attribute_context IS NOT NULL AND
	    p_Pricing_Attr_rec.pricing_attribute IS NOT NULL AND
		  UPPER(p_Pricing_Attr_rec.comparison_operator_code) = 'BETWEEN' AND
		    (p_Pricing_Attr_rec.pricing_attr_value_to IS NULL OR
			p_Pricing_Attr_rec.pricing_attr_value_from IS NULL)
      THEN
		 l_return_status := FND_API.G_RET_STS_ERROR;

		 IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
		 THEN
		   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
		   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRICING_ATTR_VALUE_TO')||'/'||
                                             QP_PRC_UTIL.Get_Attribute_Name('PRICING_ATTR_VALUE_FROM'));  -- Fix For Bug-1974413
		   OE_MSG_PUB.Add;
           END IF;
		  RAISE FND_API.G_EXC_ERROR;
      END IF;

/* Added validation by dhgupta for bug # 1824227 */

         IF p_Pricing_Attr_rec.pricing_attribute_context IS NOT NULL AND
            p_Pricing_Attr_rec.pricing_attribute IS NOT NULL AND
                  UPPER(p_Pricing_Attr_rec.comparison_operator_code) <> 'BETWEEN' AND
                        p_Pricing_Attr_rec.pricing_attr_value_from IS NULL
      THEN
                 l_return_status := FND_API.G_RET_STS_ERROR;

                 IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                 THEN
                   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
                   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRICING_ATTR_VALUE_FROM')); --Fix For Bug-1974413
                   OE_MSG_PUB.Add;
           END IF;
                  RAISE FND_API.G_EXC_ERROR;
      END IF;

/* end changes for bug # 1824227 */



	 l_error_code:=QP_UTIL.validate_num_date(p_Pricing_Attr_rec.pricing_attribute_datatype, p_Pricing_Attr_rec.pricing_attr_value_to);

	 IF l_error_code  <> 0  THEN
	   l_return_status := FND_API.G_RET_STS_ERROR;

	   IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
		FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Value To ');
		OE_MSG_PUB.Add;
        END IF;
		  RAISE FND_API.G_EXC_ERROR;
      END IF;
	 --here
    END IF;
  END IF;

  IF    ( p_Pricing_Attr_rec.pricing_attribute_context is not null
	or   p_Pricing_Attr_rec.pricing_attribute is not null ) then

    --
    --  Validate attribute dependencies here.
    --

    IF p_Pricing_Attr_rec.comparison_operator_code is null then

		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
               --FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('COMPARISON_OPERATOR_CODE')); --Fix For Bug-1974413
               OE_MSG_PUB.Add;
            END IF;

		  RAISE FND_API.G_EXC_ERROR;
    ELSE


      SELECT  lookup_code
	 INTO    l_comparison_operator_code
	 FROM    QP_LOOKUPS
      WHERE   LOOKUP_TYPE = 'COMPARISON_OPERATOR'
	 AND     LOOKUP_CODE = UPPER(p_Pricing_Attr_rec.comparison_operator_code);

      If SQL%NOTFOUND
	 Then

		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
               --FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('COMPARISON_OPERATOR_CODE')); -- Fix For Bug-1974413
               OE_MSG_PUB.Add;
            END IF;

            RAISE FND_API.G_EXC_ERROR;

       End If;

    END IF; /* comparison_operator_code is null */

  END IF; /* context or atttribute is not null */


    --dbms_output.put_line('entity validation for compa2 '||l_return_status);
    oe_debug_pub.add('entity validation for compa2 '||l_return_status);



     --Validate Qualifier_Context , Qualifier_attribute ,Qualifier_Attr Value
	--qualifier_datatype,qualifier_precedence


      --dbms_output.put_line('for context ,attribute,value,datatype,precedence');

/*  IF    ( p_Pricing_Attr_rec.pricing_attribute_context is not null
	or   p_Pricing_Attr_rec.pricing_attribute is not null
	or   p_Pricing_Attr_rec.pricing_attr_value_from is not null
	or   p_Pricing_Attr_rec.pricing_attr_value_to is not null) then

       QP_UTIL.validate_qp_flexfield(flexfield_name       =>'QP_ATTR_DEFNS_PRICING'
						 ,context                   =>p_Pricing_Attr_rec.pricing_attribute_context
						 ,attribute                 =>p_Pricing_Attr_rec.pricing_attribute
						 ,value                =>p_Pricing_Attr_rec.pricing_attr_value_from
                               ,application_short_name         => 'QP'
						 ,context_flag                   =>l_context_error
						 ,attribute_flag                 =>l_attribute_error
						 ,value_flag                     =>l_value_error
						 ,datatype                       =>l_datatype
						 ,precedence                      =>l_precedence
						 ,error_code                     =>l_error_code
						 );

       If (l_context_error = 'N'  AND l_error_code = 7)       --  invalid context
	  Then
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
               --FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_name('PRICING_ATTRIBUTE_CONTEXT')); --Fix For Bug-1974413
               OE_MSG_PUB.Add;
            END IF;

           RAISE FND_API.G_EXC_ERROR;

       End If;


       --dbms_output.put_line('for context '||l_return_status);

        --dbms_output.put_line('for context ,attribute,value,datatype,precedence');



       If l_attribute_error = 'N'   AND l_error_code = 8    --  invalid Attribute
	  Then
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE',' Attribute');
               OE_MSG_PUB.Add;
            END IF;

		  RAISE FND_API.G_EXC_ERROR;

       End If;


       --dbms_output.put_line('for attributr '||l_return_status);
       oe_debug_pub.add('for context '||l_return_status);


      --- validate qualifier_attr_value only if comparison operator is
	 --  '='

       IF p_Pricing_Attr_rec.comparison_operator_code = '=' Then

       If l_value_error = 'N'  AND l_error_code = 9      --  invalid value
	  Then
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE',' Value From ');
               --OE_MSG_PUB.Add;
               OE_MSG_PUB.Add;
            END IF;
		  RAISE FND_API.G_EXC_ERROR;
       End If;
       END IF;


       --dbms_output.put_line('for value,'||l_return_status);
       oe_debug_pub.add('for value,'||l_return_status);

      --dbms_output.put_line('org precede '||p_QUALIFIERS_rec.qualifier_precedence);
      --dbms_output.put_line('n precede '||l_precedence);

        --dbms_output.put_line('for precedence'||l_return_status);

       If p_Pricing_Attr_rec.pricing_attribute_datatype <> l_datatype   ---  invalid  datatype
	  Then
		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
               --FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Pricing Attribute Datatype ');
               OE_MSG_PUB.Add;
            END IF;
		  RAISE FND_API.G_EXC_ERROR;

       End If;



       --dbms_output.put_line('for datatype,'||l_return_status);
        oe_debug_pub.add('qualifier datatype,'||l_return_status);



   --validation for canonical form

     l_error_code:=QP_UTIL.validate_num_date(p_Pricing_Attr_rec.pricing_attribute_datatype, p_Pricing_Attr_rec.pricing_attr_value_from);
	IF l_error_code  <> 0  THEN

		  l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Value From ');
               OE_MSG_PUB.Add;
            END IF;
		  RAISE FND_API.G_EXC_ERROR;

     END IF;
     --dbms_output.put_line('for cano of value from ,'||l_return_status);

   -- End of validation for canonical form on value from

   -- Validation for Value_To

	 IF p_Pricing_Attr_rec.pricing_attribute_context IS NOT NULL AND
	    p_Pricing_Attr_rec.pricing_attribute IS NOT NULL AND
		  UPPER(p_Pricing_Attr_rec.comparison_operator_code) = 'BETWEEN' AND
		    (p_Pricing_Attr_rec.pricing_attr_value_to IS NULL AND
			p_Pricing_Attr_rec.pricing_attr_value_from IS NULL)
      THEN
		 l_return_status := FND_API.G_RET_STS_ERROR;

		 IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
		 THEN
		   FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED'  );
		   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('PRICING_ATTR_VALUE_TO')||'/'||
                                                  QP_PRC_UTIL.Get_Attribute_Name('PRICING_ATTR_VALUE_FROM')); --Fix For Bug-1974413
		   OE_MSG_PUB.Add;
           END IF;
		  RAISE FND_API.G_EXC_ERROR;
      END IF;

	 l_error_code:=QP_UTIL.validate_num_date(p_Pricing_Attr_rec.pricing_attribute_datatype, p_Pricing_Attr_rec.pricing_attr_value_to);

	 IF l_error_code  <> 0  THEN
	   l_return_status := FND_API.G_RET_STS_ERROR;

	   IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
		FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Value To ');
		OE_MSG_PUB.Add;
        END IF;
		  RAISE FND_API.G_EXC_ERROR;
      END IF;

end if;
*/
/* if context, attribute, value_from or value_to is not null */

	 -- End of validation for canonical form on value to

   OE_Debug_Pub.add ( 'before logging delayed request for Price Break Child Line ');

   /* First Delayed Request to ensure that only one price break pricing attribute
	 is allowed for a given Price Break Header.
	 Second Delayed Request to prevent overlapping Price Break Ranges for a given
	 Price Break Header */

	 BEGIN
	   select from_rltd_modifier_id
	   into   l_from_rltd_modifier_id
	   from   qp_rltd_modifiers
	   where  to_rltd_modifier_id = p_Pricing_Attr_rec.list_line_id;
	 EXCEPTION
	   WHEN OTHERS THEN
		l_from_rltd_modifier_id := NULL;
	 END;

	 --Added to check whether the PBH is for continuous or
	 --non-continuous price breaks
	 BEGIN
	   select continuous_price_break_flag
	   into   l_continuous_price_break_flag
	   from   qp_list_lines
	   where  list_line_id = l_from_rltd_modifier_id;
	 EXCEPTION
	   WHEN OTHERS THEN
	      l_continuous_price_break_flag := NULL;
	 END;

	 IF p_Pricing_Attr_rec.pricing_attribute_context = 'VOLUME' AND
	    l_from_rltd_modifier_id IS NOT NULL
	 THEN
   OE_Debug_Pub.add ( 'Logging delayed request for Price Break Child Line ');
        QP_DELAYED_REQUESTS_PVT.Log_Request
         (p_entity_code		=> QP_GLOBALS.G_ENTITY_ALL,
	     p_entity_id		=> p_PRICING_ATTR_rec.list_line_id,
	     p_requesting_entity_code	=> QP_GLOBALS.G_ENTITY_PRICING_ATTR,
          p_requesting_entity_id	=> p_PRICING_ATTR_rec.list_line_id,
	     p_request_type		=> QP_GLOBALS.G_MULTIPLE_PRICE_BREAK_ATTRS,
	     p_param1			=> l_from_rltd_modifier_id,
	     x_return_status	=> l_return_status
	    );

        QP_DELAYED_REQUESTS_PVT.Log_Request
         (p_entity_code		=> QP_GLOBALS.G_ENTITY_ALL,
	     p_entity_id		=> p_PRICING_ATTR_rec.list_line_id,
	     p_requesting_entity_code	=> QP_GLOBALS.G_ENTITY_PRICING_ATTR,
          p_requesting_entity_id	=> p_PRICING_ATTR_rec.list_line_id,
	     p_request_type		=> QP_GLOBALS.G_OVERLAPPING_PRICE_BREAKS,
	     p_param1			=> l_from_rltd_modifier_id,
	     p_param2			=> l_continuous_price_break_flag,
	     					--Added the param to call the validation
						--function depending upon the break type
	     x_return_status	=> l_return_status
	    );

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	      oe_debug_pub.add('failed in logging a delayed request ');
           RAISE FND_API.G_EXC_ERROR;
        END IF;


	 END IF; --IF Price Break Child Lines


    --Raise a warning if the Pricing/Product Attribute being used in setup
    --has a sourcing method of 'ATTRIBUTE MAPPING' but is not sourcing-enabled
    --or if its sourcing_status is not 'Y', i.e., the build sourcing conc.
    --program has to be run.

    IF QP_UTIL.Attrmgr_Installed = 'Y' THEN

      IF p_Pricing_Attr_rec.pricing_attribute_context IS NOT NULL AND
         p_Pricing_Attr_rec.pricing_attribute IS NOT NULL
      THEN
        QP_UTIL.Get_Context_Type('QP_ATTR_DEFNS_PRICING',
                                 p_Pricing_Attr_rec.pricing_attribute_context,
                                 l_context_type,
                                 l_error_code);

        IF l_error_code = 0 THEN --successfully returned context_type

          QP_UTIL.Get_Sourcing_Info(l_context_type,
                                  p_Pricing_Attr_rec.pricing_attribute_context,
                                  p_Pricing_Attr_rec.pricing_attribute,
                                  l_sourcing_enabled,
                                  l_sourcing_status,
                                  l_sourcing_method);

          IF l_sourcing_method = 'ATTRIBUTE MAPPING' THEN

            IF l_sourcing_enabled <> 'Y' THEN

              FND_MESSAGE.SET_NAME('QP','QP_ENABLE_SOURCING');
              FND_MESSAGE.SET_TOKEN('CONTEXT',
                                  p_Pricing_Attr_rec.pricing_attribute_context);
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                  p_Pricing_Attr_rec.pricing_attribute);
              OE_MSG_PUB.Add;

            END IF;

            IF l_sourcing_status <> 'Y' THEN

              FND_MESSAGE.SET_NAME('QP','QP_BUILD_SOURCING_RULES');
              FND_MESSAGE.SET_TOKEN('CONTEXT',
                                  p_Pricing_Attr_rec.pricing_attribute_context);
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                  p_Pricing_Attr_rec.pricing_attribute);
              OE_MSG_PUB.Add;

            END IF;

          END IF; --If sourcing_method = 'ATTRIBUTE MAPPING'

        END IF; --l_error_code = 0

      END IF;--If pricing_attribute_context and pricing_attribute are NOT NULL

    END IF; --If QP_UTIL.Attrmgr_Installed = 'Y'

    --  Done validating entity

    x_return_status := l_return_status;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

         x_return_status := FND_API.G_RET_STS_ERROR;

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
,   p_PRICING_ATTR_rec              IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type
,   p_old_PRICING_ATTR_rec          IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_REC
)
IS
l_pte_code varchar2(30);
l_ss_code varchar2(30);
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate PRICING_ATTR attributes

    IF  p_PRICING_ATTR_rec.accumulate_flag IS NOT NULL AND
        (   p_PRICING_ATTR_rec.accumulate_flag <>
            p_old_PRICING_ATTR_rec.accumulate_flag OR
            p_old_PRICING_ATTR_rec.accumulate_flag IS NULL )
    THEN
        IF NOT QP_Validate.Accumulate(p_PRICING_ATTR_rec.accumulate_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.attribute_grouping_no IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute_grouping_no <>
            p_old_PRICING_ATTR_rec.attribute_grouping_no OR
            p_old_PRICING_ATTR_rec.attribute_grouping_no IS NULL )
    THEN
        IF NOT QP_Validate.Attribute_Grouping_No(p_PRICING_ATTR_rec.attribute_grouping_no) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.created_by IS NOT NULL AND
        (   p_PRICING_ATTR_rec.created_by <>
            p_old_PRICING_ATTR_rec.created_by OR
            p_old_PRICING_ATTR_rec.created_by IS NULL )
    THEN
        IF NOT QP_Validate.Created_By(p_PRICING_ATTR_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.creation_date IS NOT NULL AND
        (   p_PRICING_ATTR_rec.creation_date <>
            p_old_PRICING_ATTR_rec.creation_date OR
            p_old_PRICING_ATTR_rec.creation_date IS NULL )
    THEN
        IF NOT QP_Validate.Creation_Date(p_PRICING_ATTR_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.excluder_flag IS NOT NULL AND
        (   p_PRICING_ATTR_rec.excluder_flag <>
            p_old_PRICING_ATTR_rec.excluder_flag OR
            p_old_PRICING_ATTR_rec.excluder_flag IS NULL )
    THEN
        IF NOT QP_Validate.Excluder(p_PRICING_ATTR_rec.excluder_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.last_updated_by IS NOT NULL AND
        (   p_PRICING_ATTR_rec.last_updated_by <>
            p_old_PRICING_ATTR_rec.last_updated_by OR
            p_old_PRICING_ATTR_rec.last_updated_by IS NULL )
    THEN
        IF NOT QP_Validate.Last_Updated_By(p_PRICING_ATTR_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.last_update_date IS NOT NULL AND
        (   p_PRICING_ATTR_rec.last_update_date <>
            p_old_PRICING_ATTR_rec.last_update_date OR
            p_old_PRICING_ATTR_rec.last_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Date(p_PRICING_ATTR_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.last_update_login IS NOT NULL AND
        (   p_PRICING_ATTR_rec.last_update_login <>
            p_old_PRICING_ATTR_rec.last_update_login OR
            p_old_PRICING_ATTR_rec.last_update_login IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Login(p_PRICING_ATTR_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.list_line_id IS NOT NULL AND
        (   p_PRICING_ATTR_rec.list_line_id <>
            p_old_PRICING_ATTR_rec.list_line_id OR
            p_old_PRICING_ATTR_rec.list_line_id IS NULL )
    THEN
        IF NOT QP_Validate.List_Line(p_PRICING_ATTR_rec.list_line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.pricing_attribute IS NOT NULL AND
        (   p_PRICING_ATTR_rec.pricing_attribute <>
            p_old_PRICING_ATTR_rec.pricing_attribute OR
            p_old_PRICING_ATTR_rec.pricing_attribute IS NULL )
    THEN
        IF NOT QP_Validate.Pricing_Attribute(p_PRICING_ATTR_rec.pricing_attribute) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.pricing_attribute_context IS NOT NULL AND
        (   p_PRICING_ATTR_rec.pricing_attribute_context <>
            p_old_PRICING_ATTR_rec.pricing_attribute_context OR
            p_old_PRICING_ATTR_rec.pricing_attribute_context IS NULL )
    THEN
        IF NOT QP_Validate.Pricing_Attribute_Context(p_PRICING_ATTR_rec.pricing_attribute_context) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.pricing_attribute_id IS NOT NULL AND
        (   p_PRICING_ATTR_rec.pricing_attribute_id <>
            p_old_PRICING_ATTR_rec.pricing_attribute_id OR
            p_old_PRICING_ATTR_rec.pricing_attribute_id IS NULL )
    THEN
        IF NOT QP_Validate.Pricing_Attribute(p_PRICING_ATTR_rec.pricing_attribute_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.from_rltd_modifier_id IS NOT NULL AND
        (   p_PRICING_ATTR_rec.from_rltd_modifier_id <>
            p_old_PRICING_ATTR_rec.from_rltd_modifier_id OR
            p_old_PRICING_ATTR_rec.from_rltd_modifier_id IS NULL )
    THEN
        /*
        IF NOT QP_Validate.From_Rltd_Modifier_Id(p_PRICING_ATTR_rec.from_rltd_modifier_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        */
        NULL;

    END IF;

    IF  p_PRICING_ATTR_rec.pricing_attr_value_from IS NOT NULL AND
        (   p_PRICING_ATTR_rec.pricing_attr_value_from <>
            p_old_PRICING_ATTR_rec.pricing_attr_value_from OR
            p_old_PRICING_ATTR_rec.pricing_attr_value_from IS NULL )
    THEN
        IF NOT QP_Validate.Pricing_Attr_Value_From(p_PRICING_ATTR_rec.pricing_attr_value_from) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.pricing_attr_value_to IS NOT NULL AND
        (   p_PRICING_ATTR_rec.pricing_attr_value_to <>
            p_old_PRICING_ATTR_rec.pricing_attr_value_to OR
            p_old_PRICING_ATTR_rec.pricing_attr_value_to IS NULL )
    THEN
        IF NOT QP_Validate.Pricing_Attr_Value_To(p_PRICING_ATTR_rec.pricing_attr_value_to) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.product_attribute IS NOT NULL AND
        (   p_PRICING_ATTR_rec.product_attribute <>
            p_old_PRICING_ATTR_rec.product_attribute OR
            p_old_PRICING_ATTR_rec.product_attribute IS NULL )
    THEN
        IF NOT QP_Validate.Product_Attribute(p_PRICING_ATTR_rec.product_attribute) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.product_attribute_context IS NOT NULL AND
        (   p_PRICING_ATTR_rec.product_attribute_context <>
            p_old_PRICING_ATTR_rec.product_attribute_context OR
            p_old_PRICING_ATTR_rec.product_attribute_context IS NULL )
    THEN
        IF NOT QP_Validate.Product_Attribute_Context(p_PRICING_ATTR_rec.product_attribute_context) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.product_attr_value IS NOT NULL AND
        (   p_PRICING_ATTR_rec.product_attr_value <>
            p_old_PRICING_ATTR_rec.product_attr_value OR
            p_old_PRICING_ATTR_rec.product_attr_value IS NULL )
    THEN
        IF NOT QP_Validate.Product_Attr_Value(p_PRICING_ATTR_rec.product_attr_value) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.product_uom_code IS NOT NULL AND
        (   p_PRICING_ATTR_rec.product_uom_code <>
            p_old_PRICING_ATTR_rec.product_uom_code OR
            p_old_PRICING_ATTR_rec.product_uom_code IS NULL )
    THEN
        IF NOT QP_Validate.Product_Uom(p_PRICING_ATTR_rec.product_uom_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.program_application_id IS NOT NULL AND
        (   p_PRICING_ATTR_rec.program_application_id <>
            p_old_PRICING_ATTR_rec.program_application_id OR
            p_old_PRICING_ATTR_rec.program_application_id IS NULL )
    THEN
        IF NOT QP_Validate.Program_Application(p_PRICING_ATTR_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.program_id IS NOT NULL AND
        (   p_PRICING_ATTR_rec.program_id <>
            p_old_PRICING_ATTR_rec.program_id OR
            p_old_PRICING_ATTR_rec.program_id IS NULL )
    THEN
        IF NOT QP_Validate.Program(p_PRICING_ATTR_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.program_update_date IS NOT NULL AND
        (   p_PRICING_ATTR_rec.program_update_date <>
            p_old_PRICING_ATTR_rec.program_update_date OR
            p_old_PRICING_ATTR_rec.program_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Program_Update_Date(p_PRICING_ATTR_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.request_id IS NOT NULL AND
        (   p_PRICING_ATTR_rec.request_id <>
            p_old_PRICING_ATTR_rec.request_id OR
            p_old_PRICING_ATTR_rec.request_id IS NULL )
    THEN
        IF NOT QP_Validate.Request(p_PRICING_ATTR_rec.request_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.comparison_operator_code IS NOT NULL AND
	   (   p_PRICING_ATTR_rec.comparison_operator_code <>
		  p_old_PRICING_ATTR_rec.comparison_operator_code OR
		  p_old_PRICING_ATTR_rec.comparison_operator_code IS NULL )
    THEN
	   IF NOT QP_Validate.comparison_operator(p_PRICING_ATTR_rec.comparison_operator_code) THEN
		  x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.pricing_attribute_datatype IS NOT NULL AND
	   (   p_PRICING_ATTR_rec.pricing_attribute_datatype <>
		  p_old_PRICING_ATTR_rec.pricing_attribute_datatype OR
		  p_old_PRICING_ATTR_rec.pricing_attribute_datatype IS NULL )
    THEN
	   IF NOT QP_Validate.Pricing_Attribute_Datatype(p_PRICING_ATTR_rec.pricing_attribute_datatype) THEN
		  x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICING_ATTR_rec.product_attribute_datatype IS NOT NULL AND
	   (   p_PRICING_ATTR_rec.product_attribute_datatype <>
		  p_old_PRICING_ATTR_rec.product_attribute_datatype OR
		  p_old_PRICING_ATTR_rec.product_attribute_datatype IS NULL )
    THEN
	   IF NOT QP_Validate.product_attribute_datatype(p_PRICING_ATTR_rec.product_attribute_datatype) THEN
		  x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    IF  (p_PRICING_ATTR_rec.attribute1 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute1 <>
            p_old_PRICING_ATTR_rec.attribute1 OR
            p_old_PRICING_ATTR_rec.attribute1 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute10 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute10 <>
            p_old_PRICING_ATTR_rec.attribute10 OR
            p_old_PRICING_ATTR_rec.attribute10 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute11 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute11 <>
            p_old_PRICING_ATTR_rec.attribute11 OR
            p_old_PRICING_ATTR_rec.attribute11 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute12 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute12 <>
            p_old_PRICING_ATTR_rec.attribute12 OR
            p_old_PRICING_ATTR_rec.attribute12 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute13 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute13 <>
            p_old_PRICING_ATTR_rec.attribute13 OR
            p_old_PRICING_ATTR_rec.attribute13 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute14 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute14 <>
            p_old_PRICING_ATTR_rec.attribute14 OR
            p_old_PRICING_ATTR_rec.attribute14 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute15 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute15 <>
            p_old_PRICING_ATTR_rec.attribute15 OR
            p_old_PRICING_ATTR_rec.attribute15 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute2 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute2 <>
            p_old_PRICING_ATTR_rec.attribute2 OR
            p_old_PRICING_ATTR_rec.attribute2 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute3 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute3 <>
            p_old_PRICING_ATTR_rec.attribute3 OR
            p_old_PRICING_ATTR_rec.attribute3 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute4 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute4 <>
            p_old_PRICING_ATTR_rec.attribute4 OR
            p_old_PRICING_ATTR_rec.attribute4 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute5 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute5 <>
            p_old_PRICING_ATTR_rec.attribute5 OR
            p_old_PRICING_ATTR_rec.attribute5 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute6 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute6 <>
            p_old_PRICING_ATTR_rec.attribute6 OR
            p_old_PRICING_ATTR_rec.attribute6 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute7 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute7 <>
            p_old_PRICING_ATTR_rec.attribute7 OR
            p_old_PRICING_ATTR_rec.attribute7 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute8 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute8 <>
            p_old_PRICING_ATTR_rec.attribute8 OR
            p_old_PRICING_ATTR_rec.attribute8 IS NULL ))
    OR  (p_PRICING_ATTR_rec.attribute9 IS NOT NULL AND
        (   p_PRICING_ATTR_rec.attribute9 <>
            p_old_PRICING_ATTR_rec.attribute9 OR
            p_old_PRICING_ATTR_rec.attribute9 IS NULL ))
    OR  (p_PRICING_ATTR_rec.context IS NOT NULL AND
        (   p_PRICING_ATTR_rec.context <>
            p_old_PRICING_ATTR_rec.context OR
            p_old_PRICING_ATTR_rec.context IS NULL ))
    THEN

    --  These calls are temporarily commented out

/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_PRICING_ATTR_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'CONTEXT'
        ,   column_value                  => p_PRICING_ATTR_rec.context
        );
*/

        --  Validate descriptive flexfield.

        IF NOT QP_Validate.Desc_Flex( 'PRICING_ATTR' ) THEN
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
,   p_PRICING_ATTR_rec              IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type
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


/* Start Procedure */

FUNCTION Check_Dup_Pra (   p_Start_Date_Active IN DATE
  				   , p_End_Date_Active IN DATE
					   , p_Revision IN VARCHAR2
					   , p_List_Line_ID IN NUMBER
					   , p_List_Header_ID IN NUMBER
					   , p_x_rows OUT NOCOPY NUMBER
					   , p_x_revision OUT NOCOPY BOOLEAN
					   , p_x_effdates OUT NOCOPY BOOLEAN
					   , p_x_dup_sdate OUT NOCOPY DATE
					   , p_x_dup_edate OUT NOCOPY DATE
					 )
RETURN BOOLEAN
is
        l_attr_lines_count NUMBER;

CURSOR get_rec(l_List_Line_ID NUMBER ) is
select a.list_line_id col1, b.list_line_id col2
from qp_pricing_attributes a, qp_pricing_attributes b
where 	a.list_line_id = l_List_Line_ID
and b.list_line_id <> l_List_Line_ID
and not exists (select Null
                from    qp_rltd_modifiers qrm
                Where   qrm.to_rltd_modifier_id = b.list_line_id
                and     qrm.rltd_modifier_grp_type = 'PRICE BREAK')
and b.product_attribute_context = a.product_attribute_context
and b.product_attribute = a.product_attribute
and b.product_attr_value = a.product_attr_value
and b.product_uom_code = a.product_uom_code   --2943344
--BEGIN Bug No. 9158257
AND (
	(b.pricing_attribute_context = a.pricing_attribute_context
	   AND b.pricing_attribute = a.pricing_attribute
	   AND  nvl(b.pricing_attr_value_from,0) = nvl(a.pricing_attr_value_from,0)
	   AND nvl(b.pricing_attr_value_to,0) = nvl(a.pricing_attr_value_to,0)
	   AND b.comparison_operator_code = a.comparison_operator_code
        )
        OR ( a.pricing_attribute_context IS NULL
	     AND b.pricing_attribute_context IS NULL
        )
)
--END Bug No. 9158257
and b.list_header_id = p_List_Header_Id
and a.list_header_id = p_List_Header_Id
group by a.list_line_id, b.list_line_id
having count(b.list_line_id ) = l_attr_lines_count
and count(b.list_line_id) = ( select count(*) from qp_pricing_attributes where list_line_id = b.list_line_id); --2326820



l_count varchar2(2);
l_min_date date := to_date('01/01/1900', 'MM/DD/YYYY');
l_max_date date := to_date('12/31/9999', 'MM/DD/YYYY');
l_sdate DATE := NULL;
l_edate DATE := NULL;
BEGIN

     select count(*)
     Into l_attr_lines_count
     from qp_pricing_attributes
     where list_line_id = p_List_Line_ID;

    for rec in get_rec(p_List_Line_ID)
    loop

/*---------------- Bug 1951884-----------------*/
l_min_date := to_date('01/01/1900', 'MM/DD/YYYY');
l_max_date := to_date('12/31/9999', 'MM/DD/YYYY');
/*--------------------------------------------*/
	begin
	    SELECT revision, start_date_active, end_date_active
	    into l_count, l_sdate, l_edate
	    from qp_list_lines
	    where list_line_id = rec.col2;

	    exception
	    when no_data_found then null;
     end;

	    if l_count = p_Revision then
		p_x_revision := FALSE;
	     RETURN FALSE;

	    END IF;


      IF ( nvl(p_Start_Date_Active, l_min_date) <= nvl(l_sdate, l_min_date))
        THEN
            l_min_date := nvl(p_Start_Date_Active, l_min_date);
        ELSE
            l_min_date := nvl(l_sdate, l_min_date);
      END IF;

     IF ( nvl(p_End_Date_Active, l_max_date) >= nvl(l_edate, l_max_date))
        THEN
            l_max_date := nvl(p_End_Date_Active, l_max_date);
        ELSE
            l_max_date := nvl(l_edate, l_max_date);
      END IF;



       if ( trunc(nvl(l_sdate, l_min_date)) between
             trunc(nvl(p_Start_Date_Active, l_min_date))
		and trunc(nvl(p_End_Date_Active, l_max_date)) )
	  OR
          ( trunc(nvl(l_edate, l_max_date)) between
             trunc(nvl(p_Start_Date_Active, l_min_date))
	     and trunc(nvl(p_End_Date_Active, l_max_date)) )

          OR
          ( trunc(nvl(l_sdate, l_min_date)) <=
                   nvl(p_Start_Date_Active,l_min_date)
            AND
            trunc(nvl(l_edate, l_max_date)) >=
                   nvl(p_End_Date_Active,l_max_date) )

       THEN
         p_x_dup_sdate := l_sdate;
         p_x_dup_edate := l_edate;

         oe_debug_pub.add('Dates Overlapping' );
         p_x_effdates := FALSE;
         RETURN FALSE;
       end if;

    end loop;


    p_x_rows := sql%rowcount;
    RETURN TRUE;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_x_rows := sql%rowcount;
		p_x_revision := TRUE;
		p_x_effdates := TRUE;
	 RETURN TRUE;

    WHEN OTHERS THEN
       p_x_rows := sql%rowcount;
		p_x_revision := FALSE;
		p_x_effdates := FALSE;
	  RETURN FALSE;

END Check_Dup_Pra;


/* End ------------- */







/* New Code Jan18 */
FUNCTION Check_Line_Revision(   p_Revision IN VARCHAR2
					   , p_List_Line_ID IN NUMBER
					   , p_List_Header_ID IN NUMBER
					   , p_x_rows OUT NOCOPY /* file.sql.39 change */ NUMBER
					 )
RETURN BOOLEAN
IS
 l_dummy VARCHAR2(20);
 l_dummy1 VARCHAR2(20);
BEGIN

select a.list_line_id, b.list_line_id
into l_dummy, l_dummy1
from qp_pricing_attributes a, qp_pricing_attributes b, qp_list_lines c
where 	a.list_line_id = p_List_Line_ID
and b.list_line_id <> p_List_Line_ID
and b.product_attribute_context = a.product_attribute_context
and b.product_attribute = a.product_attribute
and b.product_attr_value = a.product_attr_value
-- and nvl(b.product_attribute_context,' ') = nvl(a.product_attribute_context,' ') ** bug 2813068 **
-- and nvl(b.product_attribute,' ') = nvl(a.product_attribute,' ') ** bug 2813068 **
-- and nvl(b.product_attr_value,' ') = nvl(a.product_attr_value,' ') ** bug 2813068 **
and nvl(b.product_uom_code,' ') = nvl(a.product_uom_code,' ')
and nvl(b.pricing_attribute_context,' ') = nvl(a.pricing_attribute_context,' ')
and nvl(b.pricing_attribute,' ') = nvl(a.pricing_attribute,' ' )
and nvl(b.pricing_attr_value_from,' ') = nvl(a.pricing_attr_value_from,' ')
and nvl(b.pricing_attr_value_to,' ') = nvl(a.pricing_attr_value_to,' ')
and b.comparison_operator_code = a.comparison_operator_code                 --Added for 2128739
and a.list_line_id = c.list_line_id
and nvl(c.revision,' ') = nvl(p_Revision,' ')
group by a.list_line_id, b.list_line_id
having count(b.list_line_id) = ( select count(*)
					     from qp_pricing_attributes
						where list_line_id = b.list_line_id)  ;


    p_x_rows := sql%rowcount;

    if p_x_rows <> 0 then
	  RETURN FALSE;
    else
	  RETURN TRUE;
    end if;


	EXCEPTION
	WHEN NO_DATA_FOUND THEN
    p_x_rows := sql%rowcount;
	   RETURN TRUE;


	WHEN OTHERS THEN
    p_x_rows := sql%rowcount;
	  RETURN FALSE;



END  Check_Line_Revision;


FUNCTION Check_Line_EffDates( p_Start_Date_Active IN DATE
  					   , p_End_Date_Active IN DATE
					   , p_Revision IN VARCHAR2
					   , p_List_Line_ID IN NUMBER
					   , p_List_Header_ID IN NUMBER
					   , p_x_rows OUT NOCOPY /* file.sql.39 change */ NUMBER
					 )
RETURN BOOLEAN
IS
l_dummy VARCHAR2(20);
l_dummy1 VARCHAR2(20);
BEGIN

select a.list_line_id, b.list_line_id
into l_dummy, l_dummy1
from qp_pricing_attributes a, qp_pricing_attributes b, qp_list_lines c
where 	a.list_line_id = p_List_Line_ID
and b.list_line_id <> p_List_Line_ID
and b.product_attribute_context = a.product_attribute_context
and b.product_attribute = a.product_attribute
and b.product_attr_value = a.product_attr_value
-- and nvl(b.product_attribute_context,' ') = nvl(a.product_attribute_context,' ') ** bug 2813068 **
-- and nvl(b.product_attribute,' ') = nvl(a.product_attribute,' ') ** bug 2813068 **
-- and nvl(b.product_attr_value,' ') = nvl(a.product_attr_value,' ') ** bug 2813068 **
and nvl(b.product_uom_code,' ') = nvl(a.product_uom_code,' ')
and nvl(b.pricing_attribute_context,' ') = nvl(a.pricing_attribute_context,' ')
and nvl(b.pricing_attribute,' ') = nvl(a.pricing_attribute,' ' )
and nvl(b.pricing_attr_value_from,' ') = nvl(a.pricing_attr_value_from,' ')
and nvl(b.pricing_attr_value_to,' ') = nvl(a.pricing_attr_value_to,' ')
and b.comparison_operator_code = a.comparison_operator_code                 --Added for 2128739
and a.list_line_id = c.list_line_id
and ( nvl(trunc(start_date_active),sysdate)  BETWEEN  nvl(to_date(to_char(p_Start_Date_Active,'DD/MM/YYYY'),'DD/MM/YYYY'), sysdate)
and nvl(to_date(to_char(p_End_Date_Active,'DD/MM/YYYY'),'DD/MM/YYYY'), sysdate) OR
     nvl(trunc(end_date_active),sysdate) BETWEEN nvl(to_date(to_char(p_Start_Date_Active,'DD/MM/YYYY'),'DD/MM/YYYY'),sysdate )
			and nvl(to_date(to_char(p_End_Date_Active,'DD/MM/YYYY'),'DD/MM/YYYY'), sysdate ) )
group by a.list_line_id, b.list_line_id
having count(b.list_line_id) = ( select count(*)
					     from qp_pricing_attributes
						where list_line_id = b.list_line_id)  ;



    p_x_rows := sql%rowcount;

    if p_x_rows <> 0 then
	  RETURN FALSE;
    else
	  RETURN TRUE;
    end if;


	EXCEPTION
	WHEN NO_DATA_FOUND THEN
    p_x_rows := sql%rowcount;
	   RETURN TRUE;


	WHEN OTHERS THEN
    p_x_rows := sql%rowcount;
	  RETURN FALSE;



END Check_Line_EffDates;


END QP_Validate_pll_pricing_attr;

/
