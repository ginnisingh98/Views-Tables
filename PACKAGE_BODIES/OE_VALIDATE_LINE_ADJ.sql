--------------------------------------------------------
--  DDL for Package Body OE_VALIDATE_LINE_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VALIDATE_LINE_ADJ" AS
/* $Header: OEXLLADB.pls 120.2 2005/12/29 04:29:50 ppnair noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Validate_Line_Adj';

--  Procedure Entity


PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Line_Adj_rec                  IN  OE_Order_PUB.Line_Adj_Rec_Type
,   p_old_Line_Adj_rec              IN  OE_Order_PUB.Line_Adj_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_REC
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
  stmt Number;
  BEGIN

   stmt:=1;
   Oe_debug_pub.add('Entering OE_Validate_Line_Adj.Entity');
    --  Check required attributes.

    IF  p_Line_Adj_rec.price_adjustment_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            oe_debug_pub.add(' Required price_adjustment');
            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_adjustment');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

     stmt:=2;
    -- Check the header_id on the record.

    IF  p_Line_Adj_rec.header_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
             oe_debug_pub.add(' Required Header Id');
            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                     OE_Order_UTIL.Get_Attribute_Name('HEADER_ID'));
            OE_MSG_PUB.Add;

        END IF;

    END IF;
     stmt:=3;
    IF p_Line_adj_rec.list_line_type_code not in ('COST','TAX')and
		p_Line_adj_rec.list_header_id is null
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
             oe_debug_pub.add(' Required List Header');
            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','List_header');
            OE_MSG_PUB.Add;

        END IF;

    END IF;
     stmt:=4;
    IF p_Line_adj_rec.list_header_id is not null and
		p_Line_adj_rec.list_line_id IS NULL THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
             oe_debug_pub.add(' Required list line');
            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','List_Line');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

     stmt:=5;
    IF p_Line_adj_rec.list_header_id is not null and
		p_Line_adj_rec.list_line_type_code IS NULL THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
             oe_debug_pub.add(' Required list line type code');
            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','List_line_type_code');
            OE_MSG_PUB.Add;

        END IF;

    END IF;
     stmt:=6;
    IF p_Line_adj_rec.list_line_type_code in ('COST','TAX')and
		p_Line_adj_rec.line_id is null
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
             oe_debug_pub.add(' Required line id');
            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                     OE_Order_UTIL.Get_Attribute_Name('LINE_ID'));
            OE_MSG_PUB.Add;

        END IF;

    END IF;
      stmt:=7;
    --
    --  Check rest of required attributes here.
    --

    --  Return Error if a required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

       RAISE FND_API.G_EXC_ERROR;

     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


     stmt:=8;
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
                 oe_debug_pub.add(' Required:'||l_attribute_name);
                FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',l_attribute_name);
                OE_MSG_PUB.Add;

            END IF;
	   END IF;

    END IF;

     stmt:=9;
    -- bug 1999869, check for reason code only for applied adjs.
/*    IF upper(p_Line_adj_rec.updated_flag) ='Y'  and
       upper(p_line_adj_rec.applied_flag) = 'Y'  and
	p_Line_adj_rec.change_reason_code is null THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
             oe_debug_pub.add(' Required: change_reason_code');
            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','change_reason_code');
            OE_MSG_PUB.Add;

        END IF;

    END IF; */

     stmt:=10;
    IF p_Line_adj_rec.list_line_type_code = 'FREIGHT_CHARGE' and
	  p_Line_adj_rec.charge_type_code IS NULL THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            oe_debug_pub.add(' Required: CHARGE_TYPE_CODE');
            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				 OE_Order_UTIL.Get_Attribute_Name('CHARGE_TYPE_CODE'));
            OE_MSG_PUB.Add;

        END IF;

    END IF;
     stmt:=11;
    IF p_Line_adj_rec.list_line_type_code = 'TAX' and
    -- eBTax changes
    -- At least one out of tax_code (for historical trx) and tax_Rate_id (for new
    -- transactions ) should be populated when line is of type tax
         (
	  p_Line_adj_rec.tax_code IS NULL
	  AND
	  p_Line_adj_rec.tax_rate_id IS NULL
	 )
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
             oe_debug_pub.add(' Required: tax code or tax_rate_id');
            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
          -- eBTax Changes
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				 OE_Order_UTIL.Get_Attribute_Name('TAX_RATE_ID'));

            OE_MSG_PUB.Add;

        END IF;

    END IF;
     stmt:=12;
    IF p_Line_adj_rec.list_line_type_code = 'COST' and
	  p_Line_adj_rec.cost_id IS NULL THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
             oe_debug_pub.add(' Required: cost id');
            FND_MESSAGE.SET_NAME('ONT','OE_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				 OE_Order_UTIL.Get_Attribute_Name('COST_ID'));
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    stmt:=13;
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

    stmt:=14;
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
 stmt:=15;

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
       AND    nvl(trunc(oeordl.pricing_date), sysdate)
              BETWEEN nvl(sodsc.start_date_active,
			  nvl(trunc(oeordl.pricing_date), sysdate))
              AND
              Nvl(sodsc.end_date_active, nvl(trunc(oeordl.pricing_date),
					     sysdate) )
       AND    sodls.discount_id(+) = sodsc.discount_id
       AND    nvl(trunc(oeordl.pricing_date), sysdate) between
              Nvl(sodls.start_date_active(+), nvl(trunc(oeordl.pricing_date),
						  sysdate) )
              AND
              Nvl(sodls.end_date_active(+), nvl(trunc(oeordl.pricing_date),
						sysdate) )
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
      AND    nvl(trunc(oeordl.pricing_date), sysdate)
             BETWEEN
             NVL( sopbl.start_date_active(+), nvl(trunc(oeordl.pricing_date),
						  sysdate) )
             AND
             NVL( sopbl.end_date_active(+), nvl(trunc(oeordl.pricing_date),
						sysdate) )
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
		AND    nvl(trunc(oeordl.pricing_date), sysdate)
		       BETWEEN NVL( sodcs.start_date_active,
				    nvl(trunc(oeordl.pricing_date), sysdate) )
		       AND
		       NVL(sodcs.end_date_active,
			   nvl(trunc(oeordl.pricing_date), sysdate))
		)
	     OR
	     EXISTS (SELECT NULL
		     FROM   oe_discount_customers oecst,
		            hz_cust_accounsts hzcst
		     WHERE  oecst.discount_id = sodsc.discount_id
		     AND    hzcst.cust_account_id =  oeordh.sold_to_org_id
		     AND    hzcst.customer_class_code =
		                            oecst.customer_class_code
		     AND    oecst.sold_to_org_id IS NULL
		     AND    oecst.site_use_id IS NULL
		     AND    nvl(trunc(oeordl.pricing_date), sysdate)
		            BETWEEN NVL(oecst.start_date_active,
					Nvl(trunc(oeordl.pricing_date),
					    Sysdate) )
		            AND
		            NVL(oecst.end_date_active,
				nvl(trunc(oeordl.pricing_date), sysdate)))
	      )
	    )
	);

 stmt:=16;

    -- The price adjustment check above failed

    IF l_price_adj_error = 'IMP_DISCOUNT'
      THEN

       l_return_status := FND_API.G_RET_STS_ERROR;

       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
	 THEN
           oe_debug_pub.add(' Required: IMP_DISCOUN');
	  FND_MESSAGE.SET_NAME('OE', 'IMP_DISCOUNT');
	  OE_MSG_PUB.Add;

       END IF;

       RAISE FND_API.G_EXC_ERROR;

    END IF;
*/


    --
    --  Validate attribute dependencies here.
    --

    IF p_Line_adj_rec.list_line_type_code = 'FREIGHT_CHARGE' AND
	  p_Line_adj_rec.charge_type_code IS NOT NULL AND
	  p_Line_adj_rec.charge_subtype_code IS NOT NULL AND
       ((NOT OE_GLOBALS.EQUAL(p_Line_adj_rec.charge_type_code,
                             p_Old_Line_adj_rec.charge_type_code)) OR
       (NOT OE_GLOBALS.EQUAL(p_Line_adj_rec.charge_subtype_code,
                             p_Old_Line_adj_rec.charge_subtype_code)))
     THEN

       BEGIN
                SELECT 'VALID'
                INTO l_tmp_string
                FROM QP_LOOKUPS
                WHERE LOOKUP_TYPE = p_Line_Adj_rec.charge_type_code
                AND LOOKUP_CODE = p_Line_Adj_rec.charge_subtype_code
                AND TRUNC(sysdate) BETWEEN TRUNC(NVL(START_DATE_ACTIVE,sysdate))
                    AND TRUNC(NVL(END_DATE_ACTIVE,sysdate))
                AND ENABLED_FLAG = 'Y';
       EXCEPTION

          WHEN NO_DATA_FOUND THEN
             l_return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                    OE_Order_Util.Get_Attribute_Name('CHARGE_SUBTYPE_CODE'));
             oe_debug_pub.add('  Required CHARGE_SUBTYPE_CODE');
             OE_MSG_PUB.Add;

          WHEN OTHERS THEN
             IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
             THEN
                 OE_MSG_PUB.Add_Exc_Msg
                 ( G_PKG_NAME ,
                   'Record - Charge Type/Subtype validation'
                 );
             END IF;
             oe_debug_pub.add(' Failed:Record - Charge Type/Subtype validation');
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
            oe_debug_pub.add(' Error ARITHMETIC_OPERATOR');
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
    oe_debug_pub.add('Leaving oe_validate_line_adj.entity');
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
,   p_Line_Adj_rec                  IN  OE_Order_PUB.Line_Adj_Rec_Type
,   p_old_Line_Adj_rec              IN  OE_Order_PUB.Line_Adj_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_REC
)
IS
BEGIN
    oe_debug_pub.add('Entering OE_VALIDATE_LINE_ADJ.ATTRIBUTES');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate Line_Adj attributes

    IF  p_Line_Adj_rec.price_adjustment_id IS NOT NULL AND
        (   p_Line_Adj_rec.price_adjustment_id <>
            p_old_Line_Adj_rec.price_adjustment_id OR
            p_old_Line_Adj_rec.price_adjustment_id IS NULL )
    THEN
        IF NOT OE_Validate_adj.Price_Adjustment(p_Line_Adj_rec.price_adjustment_id) THEN
            oe_debug_pub.add(' Error price_adjustment_id');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.creation_date IS NOT NULL AND
        (   p_Line_Adj_rec.creation_date <>
            p_old_Line_Adj_rec.creation_date OR
            p_old_Line_Adj_rec.creation_date IS NULL )
    THEN
        IF NOT OE_Validate_adj.Creation_Date(p_Line_Adj_rec.creation_date) THEN
            oe_debug_pub.add(' Error creation_date');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.created_by IS NOT NULL AND
        (   p_Line_Adj_rec.created_by <>
            p_old_Line_Adj_rec.created_by OR
            p_old_Line_Adj_rec.created_by IS NULL )
    THEN
        IF NOT OE_Validate_adj.Created_By(p_Line_Adj_rec.created_by) THEN
             oe_debug_pub.add(' Error created_by');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.last_update_date IS NOT NULL AND
        (   p_Line_Adj_rec.last_update_date <>
            p_old_Line_Adj_rec.last_update_date OR
            p_old_Line_Adj_rec.last_update_date IS NULL )
    THEN
        IF NOT OE_Validate_adj.Last_Update_Date(p_Line_Adj_rec.last_update_date) THEN
             oe_debug_pub.add(' Error last_update_date');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.last_updated_by IS NOT NULL AND
        (   p_Line_Adj_rec.last_updated_by <>
            p_old_Line_Adj_rec.last_updated_by OR
            p_old_Line_Adj_rec.last_updated_by IS NULL )
    THEN
        IF NOT OE_Validate_adj.Last_Updated_By(p_Line_Adj_rec.last_updated_by) THEN
            oe_debug_pub.add(' Error last_updated_by');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.last_update_login IS NOT NULL AND
        (   p_Line_Adj_rec.last_update_login <>
            p_old_Line_Adj_rec.last_update_login OR
            p_old_Line_Adj_rec.last_update_login IS NULL )
    THEN
        IF NOT OE_Validate_adj.Last_Update_Login(p_Line_Adj_rec.last_update_login) THEN
            oe_debug_pub.add(' Error last_update_login');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.program_application_id IS NOT NULL AND
        (   p_Line_Adj_rec.program_application_id <>
            p_old_Line_Adj_rec.program_application_id OR
            p_old_Line_Adj_rec.program_application_id IS NULL )
    THEN
        IF NOT OE_Validate_adj.Program_Application(p_Line_Adj_rec.program_application_id) THEN
             oe_debug_pub.add(' Error program_application_id');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.program_id IS NOT NULL AND
        (   p_Line_Adj_rec.program_id <>
            p_old_Line_Adj_rec.program_id OR
            p_old_Line_Adj_rec.program_id IS NULL )
    THEN
        IF NOT OE_Validate_adj.Program(p_Line_Adj_rec.program_id) THEN
 oe_debug_pub.add(' Error program id');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.program_update_date IS NOT NULL AND
        (   p_Line_Adj_rec.program_update_date <>
            p_old_Line_Adj_rec.program_update_date OR
            p_old_Line_Adj_rec.program_update_date IS NULL )
    THEN
        IF NOT OE_Validate_adj.Program_Update_Date(p_Line_Adj_rec.program_update_date) THEN
             oe_debug_pub.add(' Error program_update_date');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.request_id IS NOT NULL AND
        (   p_Line_Adj_rec.request_id <>
            p_old_Line_Adj_rec.request_id OR
            p_old_Line_Adj_rec.request_id IS NULL )
    THEN
        IF NOT OE_Validate_adj.Request(p_Line_Adj_rec.request_id) THEN
            oe_debug_pub.add(' Error request id');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.header_id IS NOT NULL AND
        (   p_Line_Adj_rec.header_id <>
            p_old_Line_Adj_rec.header_id OR
            p_old_Line_Adj_rec.header_id IS NULL )
    THEN
        IF NOT OE_Validate_adj.Header(p_Line_Adj_rec.header_id) THEN
            oe_debug_pub.add(' Error header_id');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.discount_id IS NOT NULL AND
        (   p_Line_Adj_rec.discount_id <>
            p_old_Line_Adj_rec.discount_id OR
            p_old_Line_Adj_rec.discount_id IS NULL )
    THEN
        IF NOT OE_Validate_adj.Discount(p_Line_Adj_rec.discount_id) THEN
             oe_debug_pub.add(' Error discount_id');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.discount_line_id IS NOT NULL AND
        (   p_Line_Adj_rec.discount_line_id <>
            p_old_Line_Adj_rec.discount_line_id OR
            p_old_Line_Adj_rec.discount_line_id IS NULL )
    THEN
        IF NOT OE_Validate_adj.Discount_Line(p_Line_Adj_rec.discount_line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    oe_debug_pub.add(' LLADB half way');
    IF  p_Line_Adj_rec.automatic_flag IS NOT NULL AND
        (   p_Line_Adj_rec.automatic_flag <>
            p_old_Line_Adj_rec.automatic_flag OR
            p_old_Line_Adj_rec.automatic_flag IS NULL )
    THEN
        IF NOT OE_Validate_adj.Automatic(p_Line_Adj_rec.automatic_flag) THEN
            oe_debug_pub.add(' Error automatic_flag');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.percent IS NOT NULL AND
        (   p_Line_Adj_rec.percent <>
            p_old_Line_Adj_rec.percent OR
            p_old_Line_Adj_rec.percent IS NULL )
    THEN
        IF NOT OE_Validate_adj.Percent(p_Line_Adj_rec.percent) THEN
            oe_debug_pub.add(' Error percent');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.line_id IS NOT NULL AND
        (   p_Line_Adj_rec.line_id <>
            p_old_Line_Adj_rec.line_id OR
            p_old_Line_Adj_rec.line_id IS NULL )
    THEN
        IF NOT OE_Validate_adj.Line(p_Line_Adj_rec.line_id) THEN
            oe_debug_pub.add(' Error line_id');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.list_line_no IS NOT NULL AND
        (   p_Line_Adj_rec.list_line_no <>
            p_old_Line_Adj_rec.list_line_no OR
            p_old_Line_Adj_rec.list_line_no IS NULL )
    THEN
        IF NOT oe_validate_adj.List_Line_No(p_Line_Adj_rec.list_line_no) THEN
             oe_debug_pub.add(' Error list_line_no');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.source_system_code IS NOT NULL AND
        (   p_Line_Adj_rec.source_system_code <>
            p_old_Line_Adj_rec.source_system_code OR
            p_old_Line_Adj_rec.source_system_code IS NULL )
    THEN
        IF NOT oe_validate_adj.source_system_code(p_Line_Adj_rec.source_system_code) THEN
            oe_debug_pub.add(' Error source_system_code');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.benefit_qty IS NOT NULL AND
        (   p_Line_Adj_rec.benefit_qty <>
            p_old_Line_Adj_rec.benefit_qty OR
            p_old_Line_Adj_rec.benefit_qty IS NULL )
    THEN
        IF NOT oe_validate_adj.benefit_qty(p_Line_Adj_rec.benefit_qty) THEN
            oe_debug_pub.add(' Error benefit_qty');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.benefit_uom_code IS NOT NULL AND
        (   p_Line_Adj_rec.benefit_uom_code <>
            p_old_Line_Adj_rec.benefit_uom_code OR
            p_old_Line_Adj_rec.benefit_uom_code IS NULL )
    THEN
        IF NOT oe_validate_adj.benefit_uom_code(p_Line_Adj_rec.benefit_uom_code) THEN
            oe_debug_pub.add(' Error benefit_uom_code');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.print_on_invoice_flag IS NOT NULL AND
        (   p_Line_Adj_rec.print_on_invoice_flag <>
            p_old_Line_Adj_rec.print_on_invoice_flag OR
            p_old_Line_Adj_rec.print_on_invoice_flag IS NULL )
    THEN
        IF NOT oe_validate_adj.print_on_invoice_flag(p_Line_Adj_rec.print_on_invoice_flag) THEN
            oe_debug_pub.add(' Error print_on_invoice_flag');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.expiration_date IS NOT NULL AND
        (   p_Line_Adj_rec.expiration_date <>
            p_old_Line_Adj_rec.expiration_date OR
            p_old_Line_Adj_rec.expiration_date IS NULL )
    THEN
        IF NOT oe_validate_adj.expiration_date(p_Line_Adj_rec.expiration_date) THEN
            oe_debug_pub.add(' Error expiration_date');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.rebate_transaction_type_code IS NOT NULL AND
        (   p_Line_Adj_rec.rebate_transaction_type_code <>
            p_old_Line_Adj_rec.rebate_transaction_type_code OR
            p_old_Line_Adj_rec.rebate_transaction_type_code IS NULL )
    THEN
        IF NOT oe_validate_adj.rebate_transaction_type_code(p_Line_Adj_rec.rebate_transaction_type_code) THEN
 oe_debug_pub.add(' Error rebate_transaction_type_code');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    IF  p_Line_Adj_rec.rebate_transaction_reference IS NOT NULL AND
        (   p_Line_Adj_rec.rebate_transaction_reference <>
            p_old_Line_Adj_rec.rebate_transaction_reference OR
            p_old_Line_Adj_rec.rebate_transaction_reference IS NULL )
    THEN
        IF NOT oe_validate_adj.rebate_transaction_reference(p_Line_Adj_rec.rebate_transaction_reference) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.rebate_payment_system_code IS NOT NULL AND
        (   p_Line_Adj_rec.rebate_payment_system_code <>
            p_old_Line_Adj_rec.rebate_payment_system_code OR
            p_old_Line_Adj_rec.rebate_payment_system_code IS NULL )
    THEN
        IF NOT oe_validate_adj.rebate_payment_system_code(p_Line_Adj_rec.rebate_payment_system_code) THEN
            oe_debug_pub.add(' Error ebate_payment_system_code');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.Redeemed_Date IS NOT NULL AND
        (   p_Line_Adj_rec.Redeemed_Date <>
            p_old_Line_Adj_rec.Redeemed_Date OR
            p_old_Line_Adj_rec.Redeemed_Date IS NULL )
    THEN
        IF NOT oe_validate_adj.Redeemed_Date(p_Line_Adj_rec.Redeemed_Date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.redeemed_flag IS NOT NULL AND
        (   p_Line_Adj_rec.redeemed_flag <>
            p_old_Line_Adj_rec.redeemed_flag OR
            p_old_Line_Adj_rec.redeemed_flag IS NULL )
    THEN
        IF NOT oe_validate_adj.Redeemed_Flag(p_Line_Adj_rec.redeemed_flag) THEN
oe_debug_pub.add(' Error redeemed_flag');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.accrual_flag IS NOT NULL AND
        (   p_Line_Adj_rec.accrual_flag <>
            p_old_Line_Adj_rec.accrual_flag OR
            p_old_Line_Adj_rec.accrual_flag IS NULL )
    THEN
        IF NOT oe_validate_adj.Accrual_Flag(p_Line_Adj_rec.accrual_flag) THEN
oe_debug_pub.add(' Error accrual_flag');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.list_header_id IS NOT NULL AND
        (   p_Line_Adj_rec.list_header_id <>
            p_old_Line_Adj_rec.list_header_id OR
            p_old_Line_Adj_rec.list_header_id IS NULL )
    THEN
        IF NOT OE_Validate_adj.list_header_id(p_Line_Adj_rec.list_header_id) THEN
oe_debug_pub.add(' Error list_header_id');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.list_line_id IS NOT NULL AND
        (   p_Line_Adj_rec.list_line_id <>
            p_old_Line_Adj_rec.list_line_id OR
            p_old_Line_Adj_rec.list_line_id IS NULL )
    THEN
        IF NOT OE_Validate_adj.list_line_id(p_Line_Adj_rec.list_line_id) THEN
oe_debug_pub.add(' Error list_line_id');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.list_line_type_code IS NOT NULL AND
        (   p_Line_Adj_rec.list_line_type_code <>
            p_old_Line_Adj_rec.list_line_type_code OR
            p_old_Line_Adj_rec.list_line_type_code IS NULL )
    THEN
        IF NOT OE_Validate_adj.list_line_type_code(p_Line_Adj_rec.list_line_type_code) THEN
oe_debug_pub.add(' Error list_line_type_code');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.modified_from IS NOT NULL AND
        (   p_Line_Adj_rec.modified_from <>
            p_old_Line_Adj_rec.modified_from OR
            p_old_Line_Adj_rec.modified_from IS NULL )
    THEN
        IF NOT OE_Validate_adj.modified_from(p_Line_Adj_rec.modified_from) THEN
oe_debug_pub.add(' Error modified_from');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.modified_to IS NOT NULL AND
        (   p_Line_Adj_rec.modified_to <>
            p_old_Line_Adj_rec.modified_to OR
            p_old_Line_Adj_rec.modified_to IS NULL )
    THEN
        IF NOT OE_Validate_adj.modified_to(p_Line_Adj_rec.modified_to) THEN
oe_debug_pub.add(' Error Modified to');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.updated_flag IS NOT NULL AND
        (   p_Line_Adj_rec.updated_flag <>
            p_old_Line_Adj_rec.updated_flag OR
            p_old_Line_Adj_rec.updated_flag IS NULL )
    THEN
        IF NOT OE_Validate_adj.updated_flag(p_Line_Adj_rec.updated_flag) THEN
oe_debug_pub.add(' Error updated_flag');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.update_allowed IS NOT NULL AND
        (   p_Line_Adj_rec.update_allowed <>
            p_old_Line_Adj_rec.update_allowed OR
            p_old_Line_Adj_rec.update_allowed IS NULL )
    THEN
        IF NOT OE_Validate_adj.update_allowed(p_Line_Adj_rec.update_allowed) THEN
oe_debug_pub.add(' Erro update_allowed');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.applied_flag IS NOT NULL AND
        (   p_Line_Adj_rec.applied_flag <>
            p_old_Line_Adj_rec.applied_flag OR
            p_old_Line_Adj_rec.applied_flag IS NULL )
    THEN
        IF NOT OE_Validate_adj.applied_flag(p_Line_Adj_rec.applied_flag) THEN
oe_debug_pub.add(' Error Applied flag');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.applied_flag IS NOT NULL AND
        (   p_Line_Adj_rec.applied_flag <>
            p_old_Line_Adj_rec.applied_flag OR
            p_old_Line_Adj_rec.applied_flag IS NULL )
    THEN
        IF NOT OE_Validate_adj.applied_flag(p_Line_Adj_rec.applied_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.change_reason_code IS NOT NULL AND
        (   p_Line_Adj_rec.change_reason_code <>
            p_old_Line_Adj_rec.change_reason_code OR
            p_old_Line_Adj_rec.change_reason_code IS NULL )
    THEN
        IF NOT OE_Validate_adj.change_reason_code(p_Line_Adj_rec.change_reason_code) THEN
oe_debug_pub.add(' Error change_reason_code');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.change_reason_text IS NOT NULL AND
        (   p_Line_Adj_rec.change_reason_text <>
            p_old_Line_Adj_rec.change_reason_text OR
            p_old_Line_Adj_rec.change_reason_text IS NULL )
    THEN
        IF NOT OE_Validate_adj.change_reason_text(p_Line_Adj_rec.change_reason_text) THEN
oe_debug_pub.add(' Error change reason code');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.adjusted_amount IS NOT NULL AND
        (   p_Line_Adj_rec.adjusted_amount <>
            p_old_Line_Adj_rec.adjusted_amount OR
            p_old_Line_Adj_rec.adjusted_amount IS NULL )
    THEN
        IF NOT OE_Validate_adj.Adjusted_Amount(p_Line_Adj_rec.adjusted_amount)
	   THEN
oe_debug_pub.add(' Error adjusted_amount');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.pricing_phase_id IS NOT NULL AND
        (   p_Line_Adj_rec.pricing_phase_id <>
            p_old_Line_Adj_rec.pricing_phase_id OR
            p_old_Line_Adj_rec.pricing_phase_id IS NULL )
    THEN
        IF NOT OE_Validate_adj.Pricing_Phase_id(p_Line_Adj_rec.pricing_phase_id) 	   THEN
oe_debug_pub.add(' Error Pricing phase id');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.operand IS NOT NULL AND
        (   p_Line_Adj_rec.operand <>
            p_old_Line_Adj_rec.operand OR
            p_old_Line_Adj_rec.operand IS NULL )
    THEN
        IF NOT OE_Validate_adj.operand(p_Line_Adj_rec.operand) THEN
oe_debug_pub.add(' Error Operand');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.arithmetic_operator IS NOT NULL AND
        (   p_Line_Adj_rec.arithmetic_operator <>
            p_old_Line_Adj_rec.arithmetic_operator OR
            p_old_Line_Adj_rec.arithmetic_operator IS NULL )
    THEN
        IF NOT OE_Validate_adj.arithmetic_operator(p_Line_Adj_rec.arithmetic_operator) THEN
oe_debug_pub.add(' Err arithmetic ope');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.range_break_quantity IS NOT NULL AND
        (   p_Line_Adj_rec.range_break_quantity <>
            p_old_Line_Adj_rec.range_break_quantity OR
            p_old_Line_Adj_rec.range_break_quantity IS NULL )
    THEN
        IF NOT OE_Validate_adj.range_break_quantity(p_Line_Adj_rec.range_break_quantity) THEN
oe_debug_pub.add(' Err range_break_quanti');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.accrual_conversion_rate IS NOT NULL AND
        (   p_Line_Adj_rec.accrual_conversion_rate <>
            p_old_Line_Adj_rec.accrual_conversion_rate OR
            p_old_Line_Adj_rec.accrual_conversion_rate IS NULL )
    THEN
        IF NOT OE_Validate_adj.accrual_conversion_rate(p_Line_Adj_rec.accrual_conversion_rate) THEN
oe_debug_pub.add(' Erro accrual_conversion');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.pricing_group_sequence IS NOT NULL AND
        (   p_Line_Adj_rec.pricing_group_sequence <>
            p_old_Line_Adj_rec.pricing_group_sequence OR
            p_old_Line_Adj_rec.pricing_group_sequence IS NULL )
    THEN
        IF NOT OE_Validate_adj.pricing_group_sequence(p_Line_Adj_rec.pricing_group_sequence) THEN
oe_debug_pub.add(' Error pricing_group_sequence');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.modifier_level_code IS NOT NULL AND
        (   p_Line_Adj_rec.modifier_level_code <>
            p_old_Line_Adj_rec.modifier_level_code OR
            p_old_Line_Adj_rec.modifier_level_code IS NULL )
    THEN
        IF NOT OE_Validate_adj.modifier_level_code(p_Line_Adj_rec.modifier_level_code) THEN
oe_debug_pub.add(' Error modifier_level_code');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.price_break_type_code IS NOT NULL AND
        (   p_Line_Adj_rec.price_break_type_code <>
            p_old_Line_Adj_rec.price_break_type_code OR
            p_old_Line_Adj_rec.price_break_type_code IS NULL )
    THEN
        IF NOT OE_Validate_adj.price_break_type_code(p_Line_Adj_rec.price_break_type_code) THEN
oe_debug_pub.add(' Erro price break type code');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.substitution_attribute IS NOT NULL AND
        (   p_Line_Adj_rec.substitution_attribute <>
            p_old_Line_Adj_rec.substitution_attribute OR
            p_old_Line_Adj_rec.substitution_attribute IS NULL )
    THEN
        IF NOT OE_Validate_adj.substitution_attribute(p_Line_Adj_rec.substitution_attribute) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.proration_type_code IS NOT NULL AND
        (   p_Line_Adj_rec.proration_type_code <>
            p_old_Line_Adj_rec.proration_type_code OR
            p_old_Line_Adj_rec.proration_type_code IS NULL )
    THEN
        IF NOT OE_Validate_adj.proration_type_code(p_Line_Adj_rec.proration_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.credit_or_charge_flag IS NOT NULL AND
        (   p_Line_Adj_rec.credit_or_charge_flag <>
            p_old_Line_Adj_rec.credit_or_charge_flag OR
            p_old_Line_Adj_rec.credit_or_charge_flag IS NULL )
    THEN
        IF NOT OE_Validate.credit_or_charge_flag(p_Line_Adj_rec.credit_or_charge_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.cost_id IS NOT NULL AND
        (   p_Line_Adj_rec.cost_id <>
            p_old_Line_Adj_rec.cost_id OR
            p_old_Line_Adj_rec.cost_id IS NULL )
    THEN
        IF NOT OE_Validate.cost_id(p_Line_Adj_rec.cost_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.charge_type_code IS NOT NULL AND
        (   p_Line_Adj_rec.charge_type_code <>
            p_old_Line_Adj_rec.charge_type_code OR
            p_old_Line_Adj_rec.charge_type_code IS NULL )
    THEN
        IF NOT OE_Validate.charge_type_code(p_Line_Adj_rec.charge_type_code) THEN
oe_debug_pub.add(' Error charge_type_Code');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.charge_subtype_code IS NOT NULL AND
        (   p_Line_Adj_rec.charge_subtype_code <>
            p_old_Line_Adj_rec.charge_subtype_code OR
            p_old_Line_Adj_rec.charge_subtype_code IS NULL )
    THEN
        IF NOT OE_Validate.charge_subtype_code(p_Line_Adj_rec.charge_subtype_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Line_Adj_rec.estimated_flag IS NOT NULL AND
        (   p_Line_Adj_rec.estimated_flag <>
            p_old_Line_Adj_rec.estimated_flag OR
            p_old_Line_Adj_rec.estimated_flag IS NULL )
    THEN
        IF NOT OE_Validate.estimated(p_Line_Adj_rec.estimated_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    -- eBTax Changes
    IF  p_line_adj_rec.tax_rate_id IS NOT NULL AND
        (   p_line_adj_rec.tax_rate_id <>
            p_old_line_adj_rec.tax_rate_id OR
            p_old_line_adj_rec.tax_rate_id IS NULL )
    THEN
        IF NOT OE_Validate.tax_rate_id(p_line_adj_rec.tax_rate_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
    -- end eBTax changes


    IF  p_Line_Adj_rec.invoiced_flag IS NOT NULL AND
        (   p_Line_Adj_rec.invoiced_flag <>
            p_old_Line_Adj_rec.invoiced_flag OR
            p_old_Line_Adj_rec.invoiced_flag IS NULL )
    THEN
        IF NOT OE_Validate.invoiced(p_Line_Adj_rec.invoiced_flag) THEN
oe_debug_pub.add(' Error invoiced flag');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
 if OE_GLOBALS.g_validate_desc_flex ='Y' then --bug4343612
     oe_debug_pub.add('Validation of desc flex is set to Y in OE_Validate_Line_Adj.attributes ',1);
    IF  (p_Line_Adj_rec.context IS NOT NULL AND
        (   p_Line_Adj_rec.context <>
            p_old_Line_Adj_rec.context OR
            p_old_Line_Adj_rec.context IS NULL ))
    OR  (p_Line_Adj_rec.attribute1 IS NOT NULL AND
        (   p_Line_Adj_rec.attribute1 <>
            p_old_Line_Adj_rec.attribute1 OR
            p_old_Line_Adj_rec.attribute1 IS NULL ))
    OR  (p_Line_Adj_rec.attribute2 IS NOT NULL AND
        (   p_Line_Adj_rec.attribute2 <>
            p_old_Line_Adj_rec.attribute2 OR
            p_old_Line_Adj_rec.attribute2 IS NULL ))
    OR  (p_Line_Adj_rec.attribute3 IS NOT NULL AND
        (   p_Line_Adj_rec.attribute3 <>
            p_old_Line_Adj_rec.attribute3 OR
            p_old_Line_Adj_rec.attribute3 IS NULL ))
    OR  (p_Line_Adj_rec.attribute4 IS NOT NULL AND
        (   p_Line_Adj_rec.attribute4 <>
            p_old_Line_Adj_rec.attribute4 OR
            p_old_Line_Adj_rec.attribute4 IS NULL ))
    OR  (p_Line_Adj_rec.attribute5 IS NOT NULL AND
        (   p_Line_Adj_rec.attribute5 <>
            p_old_Line_Adj_rec.attribute5 OR
            p_old_Line_Adj_rec.attribute5 IS NULL ))
    OR  (p_Line_Adj_rec.attribute6 IS NOT NULL AND
        (   p_Line_Adj_rec.attribute6 <>
            p_old_Line_Adj_rec.attribute6 OR
            p_old_Line_Adj_rec.attribute6 IS NULL ))
    OR  (p_Line_Adj_rec.attribute7 IS NOT NULL AND
        (   p_Line_Adj_rec.attribute7 <>
            p_old_Line_Adj_rec.attribute7 OR
            p_old_Line_Adj_rec.attribute7 IS NULL ))
    OR  (p_Line_Adj_rec.attribute8 IS NOT NULL AND
        (   p_Line_Adj_rec.attribute8 <>
            p_old_Line_Adj_rec.attribute8 OR
            p_old_Line_Adj_rec.attribute8 IS NULL ))
    OR  (p_Line_Adj_rec.attribute9 IS NOT NULL AND
        (   p_Line_Adj_rec.attribute9 <>
            p_old_Line_Adj_rec.attribute9 OR
            p_old_Line_Adj_rec.attribute9 IS NULL ))
    OR  (p_Line_Adj_rec.attribute10 IS NOT NULL AND
        (   p_Line_Adj_rec.attribute10 <>
            p_old_Line_Adj_rec.attribute10 OR
            p_old_Line_Adj_rec.attribute10 IS NULL ))
    OR  (p_Line_Adj_rec.attribute11 IS NOT NULL AND
        (   p_Line_Adj_rec.attribute11 <>
            p_old_Line_Adj_rec.attribute11 OR
            p_old_Line_Adj_rec.attribute11 IS NULL ))
    OR  (p_Line_Adj_rec.attribute12 IS NOT NULL AND
        (   p_Line_Adj_rec.attribute12 <>
            p_old_Line_Adj_rec.attribute12 OR
            p_old_Line_Adj_rec.attribute12 IS NULL ))
    OR  (p_Line_Adj_rec.attribute13 IS NOT NULL AND
        (   p_Line_Adj_rec.attribute13 <>
            p_old_Line_Adj_rec.attribute13 OR
            p_old_Line_Adj_rec.attribute13 IS NULL ))
    OR  (p_Line_Adj_rec.attribute14 IS NOT NULL AND
        (   p_Line_Adj_rec.attribute14 <>
            p_old_Line_Adj_rec.attribute14 OR
            p_old_Line_Adj_rec.attribute14 IS NULL ))
    OR  (p_Line_Adj_rec.attribute15 IS NOT NULL AND
        (   p_Line_Adj_rec.attribute15 <>
            p_old_Line_Adj_rec.attribute15 OR
            p_old_Line_Adj_rec.attribute15 IS NULL ))
    THEN

         oe_debug_pub.add('Before calling Line Adjustment Price_Adj_Desc_Flex');
         IF NOT OE_VALIDATE_adj.Price_Adj_Desc_Flex
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
        oe_debug_pub.add('Leaving OE_VALIDATE_LINE_ADJ.ATTRIBUTES without errors');
    --  Done validating attributes
    end if ; /*    if OE_GLOBALS.g_validate_desc_flex ='Y' then bug4343612 */
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
,   p_Line_Adj_rec                  IN  OE_Order_PUB.Line_Adj_Rec_Type
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

END OE_Validate_Line_Adj;

/
