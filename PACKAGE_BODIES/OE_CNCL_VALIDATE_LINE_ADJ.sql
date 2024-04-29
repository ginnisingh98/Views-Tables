--------------------------------------------------------
--  DDL for Package Body OE_CNCL_VALIDATE_LINE_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CNCL_VALIDATE_LINE_ADJ" AS
/* $Header: OEXVCLAB.pls 120.0 2005/06/01 01:09:59 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_CNCL_Validate_Line_Adj';

--  Procedure Entity


PROCEDURE Entity
(   x_return_status               OUT NOCOPY VARCHAR2  /* file.sql.39 change */
,   p_Line_Adj_rec                IN  OE_Order_PUB.Line_Adj_Rec_Type
)
IS
   l_return_status	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_price_adj_error	VARCHAR2(30):= NULL;
   l_tmp_string	VARCHAR2(30):= NULL;
   l_agr_type_code	VARCHAR2(30):= NULL;
   l_attribute_name	VARCHAR2(50):= NULL;
   l_agreement_id	NUMBER      ;
    -- This change is required since we are dropping the profile SO_ORGANIZATION    -- _ID. Change made by Esha.
   l_organization_id NUMBER := To_number(OE_Sys_Parameters.VALUE
						 ('MASTER_ORGANIZATION_ID'));
  /* l_organization_id	NUMBER	    := To_number(FND_PROFILE.VALUE
						 ('SO_ORGANIZATION_ID'));*/
  BEGIN

    --  Check required attributes.

/*    IF  p_Line_Adj_rec.price_adjustment_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_adjustment');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    -- Check the header_id on the record.

    IF  p_Line_Adj_rec.header_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                     OE_Order_UTIL.Get_Attribute_Name('HEADER_ID'));
            OE_MSG_PUB.Add;

        END IF;

    END IF;
*/

    IF p_Line_adj_rec.list_line_type_code not in ('COST','TAX')and
		p_Line_adj_rec.list_header_id is null
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','List_header');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    IF p_Line_adj_rec.list_header_id is not null and
		p_Line_adj_rec.list_line_id IS NULL THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','List_Line');
            OE_MSG_PUB.Add;

        END IF;

    END IF;


    IF p_Line_adj_rec.list_header_id is not null and
		p_Line_adj_rec.list_line_type_code IS NULL THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','List_line_type_code');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    IF p_Line_adj_rec.list_line_type_code in ('COST','TAX')
         --and p_Line_adj_rec.line_id is null
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                     OE_Order_UTIL.Get_Attribute_Name('LINE_ID'));
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    --
    --  Check rest of required attributes here.
    --

    --  Return Error if a required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

       RAISE FND_API.G_EXC_ERROR;

     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;



    --
    --  Check conditionally required attributes here.
    --

    /* Added Validation check for the AETC flexfield */

    IF p_Line_adj_rec.ac_attribute1 IS NOT NULL OR
	  p_Line_adj_rec.ac_attribute2 IS NOT NULL OR
	  p_Line_adj_rec.ac_attribute3 IS NOT NULL OR
	  p_Line_adj_rec.ac_attribute4 IS NOT NULL OR
	  p_Line_adj_rec.ac_attribute5 IS NOT NULL OR
	  p_Line_adj_rec.ac_attribute6 IS NOT NULL
    THEN
	   l_attribute_name := NULL;
        IF p_Line_adj_rec.ac_attribute4 IS NULL THEN
		  l_attribute_name := 'AETC Number';
	   END IF;
        IF p_Line_adj_rec.ac_attribute5 IS NULL THEN
		  l_attribute_name := 'AETC Responsibility Code';
	   END IF;
        IF p_Line_adj_rec.ac_attribute6 IS NULL THEN
		  l_attribute_name := 'AETC Reason Code';
	   END IF;
	   IF l_attribute_name IS NOT NULL THEN
            l_return_status := FND_API.G_RET_STS_ERROR;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

                FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',l_attribute_name);
                OE_MSG_PUB.Add;

            END IF;
	   END IF;

    END IF;


    IF upper(p_Line_adj_rec.updated_flag) ='Y'  and
	p_Line_adj_rec.change_reason_code is null THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','change_reason_code');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    IF p_Line_adj_rec.list_line_type_code = 'FREIGHT_CHARGE' and
	  p_Line_adj_rec.charge_type_code IS NULL THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				 OE_Order_UTIL.Get_Attribute_Name('CHARGE_TYPE_CODE'));
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    IF p_Line_adj_rec.list_line_type_code = 'TAX' and
	  p_Line_adj_rec.tax_code IS NULL THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				 OE_Order_UTIL.Get_Attribute_Name('TAX_CODE'));
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    IF p_Line_adj_rec.list_line_type_code = 'COST' and
	  p_Line_adj_rec.cost_id IS NULL THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				 OE_Order_UTIL.Get_Attribute_Name('COST_ID'));
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    IF p_Line_adj_rec.list_line_type_code in ('COST','TAX','FREIGHT_CHARGE') AND
		p_Line_adj_rec.adjusted_amount IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                     OE_Order_UTIL.Get_Attribute_Name('ADJUSTED_AMOUNT'));
            OE_MSG_PUB.Add;

        END IF;
    END IF;

    IF p_Line_adj_rec.list_line_type_code in ('TAX','FREIGHT_CHARGE') AND
		p_Line_adj_rec.operand IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                     OE_Order_UTIL.Get_Attribute_Name('OPERAND'));
            OE_MSG_PUB.Add;

        END IF;
    END IF;


/*

    --
    --  Validate the price adjustment
    --

    -- Selecting the agreement_type_code from so_agreements
    -- At this point the agreement_id on line should either be
    -- valid/active or null.

    -- The following code is not joined to the discount select
    -- because there might be no rows in so_agreements table
    -- (a cartesian product of NO_ROWS with any table
    --  results in NO_ROWS)

    BEGIN

      SELECT  soagr.agreement_type_code
	 INTO  l_agr_type_code
	 FROM  oe_agreements soagr,
	       oe_order_lines oeordl
	 WHERE soarg.agreement_id = oeordl.agreement_id
	 AND   oeordl.line_id = p_line_adj_rec.line_id;

    EXCEPTION
       WHEN NO_DATA_FOUND
	 THEN
	 l_agr_type_code := NULL;

    END;

-- Changed site_use_id to site_org_id
-- site_use_id :: site_org_id

    SELECT  'IMP_DISCOUNT'
      INTO  l_price_adj_error
      FROM  DUAL
      WHERE NOT EXISTS
      (SELECT NULL
       FROM  oe_discounts sodsc,
	     oe_discount_lines sodls,
             oe_price_break_lines sopbl,
             oe_order_lines oeordl,
             o_order_header oeordh
       WHERE NVL(decode(sign(p_line_adj_rec.discount_line_id), -1, null,
			p_line_adj_rec.discount_line_id), -99)=
	           NVL(sodls.discount_line_id(+),-99)
       AND p_line_adj_rec.discount_id = sodsc.discount_id
       AND ((p_percent =
	     nvl(sodsc.amount / oeordl.unit_list_price * 100,
		 nvl(sodsc.percent,
		     nvl((oeordl.unit_list_price - sodls.price ) /
			 oeordl.unit_list_price * 100,
			 nvl(sodls.amount / oeordl.unit_list_price * 100,
			     nvl(sodls.percent,
				 nvl((oeordl.unit_list_price - sopbl.price ) /
				     oeordl.unit_list_price * 100,
				     nvl(sopbl.amount / oeordl.unit_list_price
					 * 100,
					 nvl( sopbl.percent, 0 )))))))))
	    OR
	    (sodsc.override_allowed_flag = 'Y'))
       AND    oeordl.line_id = p_line_adj_rec.line_id
       AND    oeordl.header_id = oeordh.header_id
       AND    sodsc.price_list_id = oeordl.price_list_id
       AND    sodsc.discount_type_code = 'LINE_ITEM'
       AND    sodls.discount_id(+) = sodsc.discount_id
       AND    NVL(sodls.entity_value, 'X' ) =
                  DECODE(sodls.entity_id,
			 1007, TO_CHAR(oeordh.order_type_id),
			 1001, TO_CHAR(oeordl.inventory_item_id),
			 1005, l_agr_type_code,
			 1006, TO_CHAR(oeordl.agreement_id),
			 1010, oeordl.pricing_attribute1,
			 1011, oeordl.pricing_attribute2,
			 1012, oeordl.pricing_attribute3,
			 1013, oeordl.pricing_attribute4,
			 1014, oeordl.pricing_attribute5,
			 1015, oeordl.pricing_attribute6,
			 1016, oeordl.pricing_attribute7,
			 1017, oeordl.pricing_attribute8,
			 1018, oeordl.pricing_attribute9,
			 1019, oeordl.pricing_attribute10,
			 1020, oeordl.pricing_attribute11,
			 1021, oeordl.pricing_attribute12,
			 1022, oeordl.pricing_attribute13,
			 1023, oeordl.pricing_attribute14,
			 1024, oeordl.pricing_attribute15,
			 1045, sodls.entity_value,
			 'X' )
      AND    decode (sodls.ENTITY_ID,
		     1045, oe_adj_privilege.check_item_category
		                            (oeordl.inventory_item_id,
					     SODLS.ENTITY_VALUE,
					     l_organization_id)
		     ,'Y') = 'Y'
      AND    sopbl.discount_line_id(+) = sodls.discount_line_id

      AND    DECODE( sopbl.method_type_code,
		     'UNITS', oeordl.quantity_ordered,
		     'DOLLARS', oeordl.quantity_ordered *
		     oeordl.unit_list_price, 0 )
             BETWEEN NVL( sopbl.price_break_lines_low_range,
			  DECODE( sopbl.method_type_code,
				  'UNITS', oeordl.quantity_ordered,
				  'DOLLARS', oeordl.quantity_ordered *
				  oeordl.unit_list_price, 0 ))
      AND     NVL( sopbl.price_break_lines_high_range,
		   DECODE( sopbl.method_type_code,
			   'UNITS', oeordl.quantity_ordered,
			   'DOLLARS', oeordl.quantity_ordered *
			   oeordl.unit_list_price, 0 ))
      AND  (NOT EXISTS
	    (SELECT NULL
	     FROM   oe_discount_customers sodcs
	     WHERE  sodcs.discount_id = sodsc.discount_id )
	    OR
	    (EXISTS
	       (SELECT NULL
		FROM   oe_discount_customers sodcs
		WHERE  sodcs.discount_id = sodsc.discount_id
		AND    (sodcs.sold_to_org_id = oeordh.sold_to_org_id
			OR
			(sodcs.sold_to_org_id IS NULL
			 AND
			 sodcs.customer_class_code IS NULL))
		AND   (Nvl(sodcs.site_use_id, oeordh.ship_to_org_id)=
		       oeordh.ship_to_org_id
		       OR
		       NVL(sodcs.site_use_id, oeordh.invoice_to_org_id)=
		       oeordh.invoice_to_org_id )

		)
	     OR
	     EXISTS (SELECT NULL
                     FROM   oe_discount_customers oecst,
                            HZ_CUST_ACCOUNTS CUST_ACCT
   -- Replaced ra_customers with hz_cust_accounts to fix the bug 1888440
                     WHERE  oecst.discount_id = sodsc.discount_id
                     AND    CUST_ACCT.CUST_ACCOUNT_ID =  oeordh.sold_to_org_id
                     AND    CUST_ACCT.CUSTOMER_CLASS_CODE =
                                            oecst.customer_class_code
                     AND    oecst.sold_to_org_id IS NULL
                     AND    oecst.site_use_id IS NULL

	      )
	    )
	);



    -- The price adjustment check above failed

    IF l_price_adj_error = 'IMP_DISCOUNT'
      THEN

       l_return_status := FND_API.G_RET_STS_ERROR;

       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
	 THEN

	  FND_MESSAGE.SET_NAME('OE', 'IMP_DISCOUNT');
	  OE_MSG_PUB.Add;

       END IF;

       RAISE FND_API.G_EXC_ERROR;

    END IF;
*/

     oe_debug_pub.add('line_type_code ' || p_Line_Adj_rec.list_line_type_code, 2);
     oe_debug_pub.add('charge_type_code ' || p_Line_Adj_rec.charge_type_code, 2);
     oe_debug_pub.add('charge_type_code ' || p_Line_Adj_rec.charge_subtype_code, 2);

    --
    --  Validate attribute dependencies here.
    --

    IF p_Line_adj_rec.list_line_type_code = 'FREIGHT_CHARGE' AND
	  p_Line_adj_rec.charge_type_code IS NOT NULL AND
	  p_Line_adj_rec.charge_subtype_code IS NOT NULL
     THEN
     oe_debug_pub.add('charge_type_code ' || p_Line_Adj_rec.charge_type_code, 2);
     oe_debug_pub.add('charge_type_code ' || p_Line_Adj_rec.charge_subtype_code, 2);

       BEGIN
                SELECT 'VALID'
                INTO l_tmp_string
                FROM QP_LOOKUPS
                WHERE LOOKUP_TYPE = p_Line_Adj_rec.charge_type_code
                AND LOOKUP_CODE = p_Line_Adj_rec.charge_subtype_code
                --AND ENABLED_FLAG = 'Y'
                AND ROWNUM =1;
       EXCEPTION

          WHEN NO_DATA_FOUND THEN
             l_return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                    OE_Order_Util.Get_Attribute_Name('CHARGE_SUBTYPE_CODE'));
             OE_MSG_PUB.Add;

          WHEN OTHERS THEN
             IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
             THEN
                 OE_MSG_PUB.Add_Exc_Msg
                 ( G_PKG_NAME ,
                   'Record - Charge Type/Subtype validation'
                 );
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END;
    END IF;

    IF (p_Line_adj_rec.list_line_type_code in ('COST','TAX')and
	  p_Line_adj_rec.arithmetic_operator <> 'AMT') OR
       (p_Line_adj_rec.list_line_type_code = 'FREIGHT_CHARGE' and
	  p_Line_adj_rec.arithmetic_operator NOT IN ('AMT','LUMPSUM','%'))
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                    OE_Order_Util.Get_Attribute_Name('ARITHMETIC_OPERATOR'));
            OE_MSG_PUB.Add;

        END IF;

    END IF;


    --  Validate that the total percentage on the header has not exceeded
    /*
    --  100%. LOG A DELAYED REQUEST TO EXECUTE LATER.
    oe_delayed_requests_pvt.
      log_request(p_entity_code		=> OE_GLOBALS.G_ENTITY_LINE_ADJ,
		  p_entity_id		=> p_line_adj_rec.line_id,
	          p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE_ADJ,
	          p_requesting_entity_id   => p_line_adj_rec.price_adjustment_id,
		  p_request_type	=> OE_GLOBALS.G_CHECK_PERCENTAGE,
		  p_param1		=> p_line_adj_rec.header_id,
		  x_return_status	=> l_return_status);

  */

    -- Return

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
(   x_return_status              OUT NOCOPY VARCHAR2  /* file.sql.39 change */
,   p_Line_Adj_rec               IN  OE_Order_PUB.Line_Adj_Rec_Type
)
IS
BEGIN
   oe_debug_pub.add('Entering OE_CNCL_Validate_Line_Adjs');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate Line_Adj attributes

/*    IF  p_Line_Adj_rec.price_adjustment_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.Price_Adjustment(p_Line_Adj_rec.price_adjustment_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
*/

    IF  p_Line_Adj_rec.creation_date IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.Creation_Date(p_Line_Adj_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.created_by IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.Created_By(p_Line_Adj_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.last_update_date IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.Last_Update_Date(p_Line_Adj_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.last_updated_by IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.Last_Updated_By(p_Line_Adj_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.last_update_login IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.Last_Update_Login(p_Line_Adj_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.program_application_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.Program_Application(p_Line_Adj_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.program_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.Program(p_Line_Adj_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.program_update_date IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.Program_Update_Date(p_Line_Adj_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.request_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.Request(p_Line_Adj_rec.request_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

/*    IF  p_Line_Adj_rec.header_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.Header(p_Line_Adj_rec.header_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
*/

    IF  p_Line_Adj_rec.discount_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.Discount(p_Line_Adj_rec.discount_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.discount_line_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.Discount_Line(p_Line_Adj_rec.discount_line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.automatic_flag IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.Automatic(p_Line_Adj_rec.automatic_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.percent IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.Percent(p_Line_Adj_rec.percent) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

/*    IF  p_Line_Adj_rec.line_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.Line(p_Line_Adj_rec.line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
*/

    IF  p_Line_Adj_rec.list_line_no IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.List_Line_No(p_Line_Adj_rec.list_line_no) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.source_system_code IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.source_system_code(p_Line_Adj_rec.source_system_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.benefit_qty IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.benefit_qty(p_Line_Adj_rec.benefit_qty) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.benefit_uom_code IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.benefit_uom_code(p_Line_Adj_rec.benefit_uom_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.print_on_invoice_flag IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.print_on_invoice_flag(p_Line_Adj_rec.print_on_invoice_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.expiration_date IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.expiration_date(p_Line_Adj_rec.expiration_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.rebate_transaction_type_code IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.rebate_transaction_type_code(p_Line_Adj_rec.rebate_transaction_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    IF  p_Line_Adj_rec.rebate_transaction_reference IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.rebate_transaction_reference(p_Line_Adj_rec.rebate_transaction_reference) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.rebate_payment_system_code IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.rebate_payment_system_code(p_Line_Adj_rec.rebate_payment_system_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.Redeemed_Date IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.Redeemed_Date(p_Line_Adj_rec.Redeemed_Date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.redeemed_flag IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.Redeemed_Flag(p_Line_Adj_rec.redeemed_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.accrual_flag IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.Accrual_Flag(p_Line_Adj_rec.accrual_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.list_header_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.list_header_id(p_Line_Adj_rec.list_header_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.list_line_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.list_line_id(p_Line_Adj_rec.list_line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.list_line_type_code IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.list_line_type_code(p_Line_Adj_rec.list_line_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.modified_from IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.modified_from(p_Line_Adj_rec.modified_from) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.modified_to IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.modified_to(p_Line_Adj_rec.modified_to) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.updated_flag IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.updated_flag(p_Line_Adj_rec.updated_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.update_allowed IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.update_allowed(p_Line_Adj_rec.update_allowed) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.applied_flag IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.applied_flag(p_Line_Adj_rec.applied_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.change_reason_code IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.change_reason_code(p_Line_Adj_rec.change_reason_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.change_reason_text IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.change_reason_text(p_Line_Adj_rec.change_reason_text) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.adjusted_amount IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.Adjusted_Amount(p_Line_Adj_rec.adjusted_amount)
	   THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.pricing_phase_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.Pricing_Phase_id(p_Line_Adj_rec.pricing_phase_id) 	   THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.operand IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.operand(p_Line_Adj_rec.operand) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.arithmetic_operator IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.arithmetic_operator(p_Line_Adj_rec.arithmetic_operator) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.range_break_quantity IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.range_break_quantity(p_Line_Adj_rec.range_break_quantity) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.accrual_conversion_rate IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.accrual_conversion_rate(p_Line_Adj_rec.accrual_conversion_rate) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.pricing_group_sequence IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.pricing_group_sequence(p_Line_Adj_rec.pricing_group_sequence) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.modifier_level_code IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.modifier_level_code(p_Line_Adj_rec.modifier_level_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.price_break_type_code IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.price_break_type_code(p_Line_Adj_rec.price_break_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.substitution_attribute IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.substitution_attribute(p_Line_Adj_rec.substitution_attribute) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.proration_type_code IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate_Adj.proration_type_code(p_Line_Adj_rec.proration_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.credit_or_charge_flag IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.credit_or_charge_flag(p_Line_Adj_rec.credit_or_charge_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.cost_id IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.cost_id(p_Line_Adj_rec.cost_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.charge_type_code IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.charge_type_code(p_Line_Adj_rec.charge_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.charge_subtype_code IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.charge_subtype_code(p_Line_Adj_rec.charge_subtype_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.estimated_flag IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.estimated(p_Line_Adj_rec.estimated_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.invoiced_flag IS NOT NULL
    THEN
        IF NOT OE_CNCL_Validate.invoiced(p_Line_Adj_rec.invoiced_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF   p_Line_Adj_rec.context IS NOT NULL
    OR   p_Line_Adj_rec.attribute1 IS NOT NULL
    OR   p_Line_Adj_rec.attribute2 IS NOT NULL
    OR   p_Line_Adj_rec.attribute3 IS NOT NULL
    OR   p_Line_Adj_rec.attribute4 IS NOT NULL
    OR   p_Line_Adj_rec.attribute5 IS NOT NULL
    OR   p_Line_Adj_rec.attribute6 IS NOT NULL
    OR   p_Line_Adj_rec.attribute7 IS NOT NULL
    OR   p_Line_Adj_rec.attribute8 IS NOT NULL
    OR   p_Line_Adj_rec.attribute9 IS NOT NULL
    OR   p_Line_Adj_rec.attribute10 IS NOT NULL
    OR   p_Line_Adj_rec.attribute11 IS NOT NULL
    OR   p_Line_Adj_rec.attribute12 IS NOT NULL
    OR   p_Line_Adj_rec.attribute13 IS NOT NULL
    OR   p_Line_Adj_rec.attribute14 IS NOT NULL
    OR   p_Line_Adj_rec.attribute15 IS NOT NULL
    THEN

         oe_debug_pub.add('Before calling Line Adjustment Price_Adj_Desc_Flex');
         IF NOT OE_CNCL_Validate_Adj.Price_Adj_Desc_Flex
          (p_context            => p_Line_Adj_rec.context
          ,p_attribute1         => p_Line_Adj_rec.attribute1
          ,p_attribute2         => p_Line_Adj_rec.attribute2
          ,p_attribute3         => p_Line_Adj_rec.attribute3
          ,p_attribute4         => p_Line_Adj_rec.attribute4
          ,p_attribute5         => p_Line_Adj_rec.attribute5
          ,p_attribute6         => p_Line_Adj_rec.attribute6
          ,p_attribute7         => p_Line_Adj_rec.attribute7
          ,p_attribute8         => p_Line_Adj_rec.attribute8
          ,p_attribute9         => p_Line_Adj_rec.attribute9
          ,p_attribute10        => p_Line_Adj_rec.attribute10
          ,p_attribute11        => p_Line_Adj_rec.attribute11
          ,p_attribute12        => p_Line_Adj_rec.attribute12
          ,p_attribute13        => p_Line_Adj_rec.attribute13
          ,p_attribute14        => p_Line_Adj_rec.attribute14
          ,p_attribute15        => p_Line_Adj_rec.attribute15) THEN


                x_return_status := FND_API.G_RET_STS_ERROR;

         END IF;

         oe_debug_pub.add('After Line Adjustment desc_flex  ' || x_return_status);



    END IF;

    --  Done validating attributes
   oe_debug_pub.add('Exiting OE_CNCL_Validate_Line_Adjs');
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


END OE_CNCL_Validate_Line_Adj;

/
