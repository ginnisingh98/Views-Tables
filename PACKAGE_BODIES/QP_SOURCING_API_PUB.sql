--------------------------------------------------------
--  DDL for Package Body QP_SOURCING_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_SOURCING_API_PUB" AS
/* $Header: QPXPSAPB.pls 120.8 2006/03/14 15:32:07 jhkuo ship $ */

l_debug VARCHAR2(3);
G_GSA_INDICATOR_FLAGS  QP_PREQ_GRP.FLAG_TYPE;

Procedure Get_Customer_Info(p_cust_id NUMBER)
IS

--TYPE t_cursor IS REF CURSOR;

l_account_type_id      VARCHAR2(30);
v_count                NUMBER := 1;
--l_acct_type_cursor     t_cursor;
l_realted_cust_id      VARCHAR2(30);
--l_related_cust_cursor  t_cursor;
--
CURSOR l_acct_type_cursor (cust_id_in number) is
    SELECT distinct profile_class_id
    FROM   HZ_CUSTOMER_PROFILES
    WHERE  cust_account_id = cust_id_in;
CURSOR   l_related_cust_cursor(cust_id_in number) is
    SELECT RELATED_CUST_ACCOUNT_ID
    FROM  HZ_CUST_ACCT_RELATE
    WHERE  cust_account_id = cust_id_in;

NUMERIC_OVERFLOW EXCEPTION;
NUMERIC_OR_VALUE EXCEPTION;
PRAGMA EXCEPTION_INIT(NUMERIC_OVERFLOW, -1426);
PRAGMA EXCEPTION_INIT(NUMERIC_OR_VALUE, -6502);

BEGIN

	if qp_preq_grp.g_new_pricing_call = qp_preq_grp.g_yes then

    G_Customer_Info.customer_id := p_cust_id;

--  Getting info from HZ_CUST_ACCOUNTS
    BEGIN
    	SELECT customer_class_code, sales_channel_code
    	INTO   G_Customer_Info.customer_class_code, G_Customer_Info.sales_channel_code
	FROM   hz_cust_accounts
    	WHERE  cust_account_id = p_cust_id;

	EXCEPTION
		WHEN no_data_found THEN
			G_Customer_Info.customer_class_code := null;
			G_Customer_Info.sales_channel_code := null;

    END;

-- Getting GSA info

    BEGIN
        SELECT NVL(gsa_indicator,'N')
        INTO G_Customer_Info.gsa_indicator
        FROM hz_cust_site_uses hsu
        WHERE site_use_id = OE_ORDER_PUB.G_HDR.invoice_to_org_id
        --added for moac
        and hsu.org_id = QP_ATTR_MAPPING_PUB.G_ORG_ID;
/*
        AND  NVL(hsu.org_id,
         NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1 ,1), ' ',NULL,
              SUBSTRB(USERENV('CLIENT_INFO'), 1,10))),-99)) =
         NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ',NULL,
         SUBSTRB(USERENV('CLIENT_INFO'),1,10))), -99);
*/

        EXCEPTION

        WHEN NO_DATA_FOUND THEN
             G_Customer_Info.gsa_indicator := 'N';

    END;

    IF G_Customer_Info.gsa_indicator = 'N' THEN

        BEGIN

          BEGIN
            G_Customer_Info.gsa_indicator := G_GSA_INDICATOR_FLAGS(p_cust_id);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              G_Customer_Info.gsa_indicator := null;
          END;

          IF( G_Customer_Info.gsa_indicator is null) THEN
           SELECT NVL(gsa_indicator_flag,'N')
           into G_Customer_Info.gsa_indicator
           from hz_parties hp,hz_cust_accounts hca
           where hp.party_id = hca.party_id
           and hca.cust_account_id = p_cust_id ;

           G_GSA_INDICATOR_FLAGS(p_cust_id) := G_Customer_Info.gsa_indicator;
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            G_Customer_Info.gsa_indicator := null;
          WHEN NUMERIC_OVERFLOW THEN
            G_Customer_Info.gsa_indicator := null;
          WHEN NUMERIC_OR_VALUE THEN
            G_Customer_Info.gsa_indicator := null;

        END;

    END IF;


--  Getting Account Types

/*
    OPEN l_acct_type_cursor FOR
    SELECT distinct customer_profile_class_id
    FROM   AR_CUSTOMER_PROFILES
    WHERE  customer_id = p_cust_id;
*/
    OPEN l_acct_type_cursor(p_cust_id);
    LOOP

	FETCH l_acct_type_cursor INTO l_account_type_id;
	EXIT WHEN l_acct_type_cursor%NOTFOUND;

	G_Customer_Info.account_types(v_count) := l_account_type_id;
        v_count := v_count + 1;

    END LOOP;

    CLOSE l_acct_type_cursor;

--  Get Customer Relationships

    v_count := 1;

/*
    OPEN   l_related_cust_cursor FOR
    SELECT RELATED_CUSTOMER_ID
    FROM   RA_CUSTOMER_RELATIONSHIPS
    WHERE  customer_id = p_cust_id;
*/

    OPEN l_related_cust_cursor(p_cust_id);
    LOOP

	FETCH l_related_cust_cursor INTO l_realted_cust_id;
	EXIT WHEN l_related_cust_cursor%NOTFOUND;

	G_Customer_Info.customer_relationships(v_count) := l_realted_cust_id;
        v_count := v_count + 1;

    END LOOP;

    CLOSE l_related_cust_cursor;

	end if;

END;


FUNCTION Get_GSA (p_cust_id NUMBER) RETURN VARCHAR2
IS

BEGIN

	get_customer_info(p_cust_id);
	return g_customer_info.gsa_indicator;

/*
	if G_Customer_Info.customer_id = p_cust_id then
		return G_Customer_Info.gsa_indicator;
	else
		Get_Customer_Info(p_cust_id);
		return G_Customer_Info.gsa_indicator;
	end if;
*/

END;

FUNCTION Get_Customer_Item_Id (p_item_type VARCHAR2, p_ordered_item_id NUMBER) RETURN NUMBER
IS

BEGIN

	if p_item_type = 'CUST' then
		return p_ordered_item_id;
	else
		return NULL;
	end if;

END;

FUNCTION Get_Sales_Channel (p_cust_id IN NUMBER) RETURN VARCHAR2
IS

BEGIN

	get_customer_info(p_cust_id);
	return g_customer_info.sales_channel_code;

/*
	if G_Customer_Info.customer_id = p_cust_id then
		return G_Customer_Info.sales_channel_code;
	else
		Get_Customer_Info(p_cust_id);
		return G_Customer_Info.sales_channel_code;
	end if;
*/

END Get_Sales_Channel;

FUNCTION Get_Site_Use (p_invoice_to_org_id IN NUMBER, p_ship_to_org_id IN NUMBER) RETURN QP_Attr_Mapping_PUB.t_MultiRecord
IS

x_site_use_info	QP_Attr_Mapping_PUB.t_MultiRecord;

BEGIN

	IF p_ship_to_org_id is not null THEN
	   IF p_invoice_to_org_id is not null THEN
		 IF p_ship_to_org_id = p_invoice_to_org_id THEN
		    x_site_use_info(1) := p_ship_to_org_id;
		 ELSE
		    x_site_use_info(1) := p_ship_to_org_id;
		    x_site_use_info(2) := p_invoice_to_org_id;
		 END IF;
        ELSE
		 x_site_use_info(1) := p_ship_to_org_id;
	   END IF;
	ELSE IF p_invoice_to_org_id is not null THEN
		   x_site_use_info(1) := p_invoice_to_org_id;
		END IF;
	END IF;

	RETURN x_site_use_info;

END Get_Site_Use;

FUNCTION Get_Item_Category (p_inventory_item_id IN NUMBER) RETURN QP_Attr_Mapping_PUB.t_MultiRecord
IS
   x_category_ids     QP_Attr_Mapping_PUB.t_MultiRecord;
BEGIN
   -- Exploded Category Ids to be picked in case on PLM and Sales n marketing.
   x_category_ids := QP_CATEGORY_MAPPING_RULE.Get_Item_category(p_inventory_item_id);
   RETURN(x_category_ids);

END Get_Item_Category;

/* Added Sourcing API Get_Agreement_Revisions for Bug 2293711*/
FUNCTION Get_Agreement_Revisions (p_agreement_id IN NUMBER) RETURN

QP_Attr_Mapping_PUB.t_MultiRecord
IS

--TYPE t_cursor IS REF CURSOR;

x_agreement_ids     QP_Attr_Mapping_PUB.t_MultiRecord;
l_agreement_id      VARCHAR2(30);
v_count            NUMBER := 1;
--l_agreement_cursor  t_cursor;
l_name varchar2(240);
--
CURSOR l_agreement_cursor(name_in varchar2) is
    SELECT agreement_id
    FROM   oe_agreements_vl
    WHERE  name = name_in;
--
BEGIN

select name into l_name
from oe_agreements_vl
WHERE agreement_id = p_agreement_id
AND ROWNUM=1;

/*
    OPEN l_agreement_cursor FOR
    SELECT agreement_id
    FROM   oe_agreements_vl
    WHERE  name = l_name;
*/

    OPEN l_agreement_cursor(l_name);
    LOOP

        FETCH l_agreement_cursor INTO l_agreement_id;
        EXIT WHEN l_agreement_cursor%NOTFOUND;

        x_agreement_ids(v_count) := l_agreement_id;
        v_count := v_count + 1;

    END LOOP;

    CLOSE l_agreement_cursor;

    RETURN x_agreement_ids;

exception
when no_data_found then
RETURN x_agreement_ids;

END Get_Agreement_Revisions;


PROCEDURE Get_Item_Segments_All(p_inventory_item_id IN NUMBER)
IS

l_org_id           NUMBER := QP_UTIL.Get_Item_Validation_Org;

BEGIN

	G_Item_Segments.inventory_item_id := p_inventory_item_id;

	SELECT 	segment1,segment2,segment3,segment4,segment5,
		segment6,segment7,segment8,segment9,segment10,
	  	segment11,segment12,segment13,segment14,segment15,
		segment16,segment17,segment18,segment19,segment20
	INTO  	G_Item_Segments.segment1,G_Item_Segments.segment2,G_Item_Segments.segment3,
	  	G_Item_Segments.segment4,G_Item_Segments.segment5,G_Item_Segments.segment6,
	  	G_Item_Segments.segment7,G_Item_Segments.segment8,G_Item_Segments.segment9,
	  	G_Item_Segments.segment10,G_Item_Segments.segment11,G_Item_Segments.segment12,
	  	G_Item_Segments.segment13,G_Item_Segments.segment14,G_Item_Segments.segment15,
	  	G_Item_Segments.segment16,G_Item_Segments.segment17,G_Item_Segments.segment18,
		G_Item_Segments.segment19,G_Item_Segments.segment20
	FROM   	mtl_system_items
	WHERE  	inventory_item_id = p_inventory_item_id
	AND    	organization_id = l_org_id;

END;

FUNCTION Get_Item_Segment(p_inventory_item_id IN NUMBER, p_seg_num NUMBER) RETURN VARCHAR2
IS

l_segment_name	VARCHAR2(30);

BEGIN
        -- Added for 2623767
	IF p_inventory_item_id IS NULL THEN
           RETURN NULL;
	END IF;


	IF (p_inventory_item_id <>  G_Item_Segments.inventory_item_id)
		 OR G_Item_Segments.inventory_item_id IS NULL THEN   -- Added for 2512883

		Get_Item_Segments_All(p_inventory_item_id);
	END IF;

	IF p_seg_num = 1 THEN
		RETURN G_Item_Segments.segment1;
	ELSIF p_seg_num = 2 THEN
		RETURN G_Item_Segments.segment2;
	ELSIF p_seg_num = 3 THEN
		RETURN G_Item_Segments.segment3;
	ELSIF p_seg_num = 4 THEN
		RETURN G_Item_Segments.segment4;
	ELSIF p_seg_num = 5 THEN
		RETURN G_Item_Segments.segment5;
	ELSIF p_seg_num = 6 THEN
		RETURN G_Item_Segments.segment6;
	ELSIF p_seg_num = 7 THEN
		RETURN G_Item_Segments.segment7;
	ELSIF p_seg_num = 8 THEN
		RETURN G_Item_Segments.segment8;
	ELSIF p_seg_num = 9 THEN
		RETURN G_Item_Segments.segment9;
	ELSIF p_seg_num = 10 THEN
		RETURN G_Item_Segments.segment10;
	ELSIF p_seg_num = 11 THEN
		RETURN G_Item_Segments.segment11;
	ELSIF p_seg_num = 12 THEN
		RETURN G_Item_Segments.segment12;
	ELSIF p_seg_num = 13 THEN
		RETURN G_Item_Segments.segment13;
	ELSIF p_seg_num = 14 THEN
		RETURN G_Item_Segments.segment14;
	ELSIF p_seg_num = 15 THEN
		RETURN G_Item_Segments.segment15;
	ELSIF p_seg_num = 16 THEN
		RETURN G_Item_Segments.segment16;
	ELSIF p_seg_num = 17 THEN
		RETURN G_Item_Segments.segment17;
	ELSIF p_seg_num = 18 THEN
		RETURN G_Item_Segments.segment18;
	ELSIF p_seg_num = 19 THEN
		RETURN G_Item_Segments.segment19;
	ELSIF p_seg_num = 20 THEN
		RETURN G_Item_Segments.segment20;
	END IF;
END;


FUNCTION Get_Customer_Class(p_cust_id IN NUMBER) RETURN VARCHAR2
IS

BEGIN

	get_customer_info(p_cust_id);
	return g_customer_info.customer_class_code;

	/*
	if G_Customer_Info.customer_id = p_cust_id then
		return G_Customer_Info.customer_class_code;
	else
		Get_Customer_Info(p_cust_id);
		return G_Customer_Info.customer_class_code;
	end if;
	*/

END Get_Customer_Class;

PROCEDURE Get_Order_AMT_and_QTY (p_header_id IN NUMBER)
IS

orders_total_amt      NUMBER := 0;
orders_total_qty      NUMBER := 0;
returns_total_amt     NUMBER := 0;
returns_total_qty     NUMBER := 0;

BEGIN

        l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
	if qp_preq_grp.g_new_pricing_call = qp_preq_grp.g_yes then
  --Bug 2718722, Added exception handling and replaced pricing_quantity by ordered_quantity
	If QP_UTIL_PUB.HVOP_Pricing_On = 'Y' Then

	For i in QP_BULK_PREQ_GRP.G_Line_Rec.header_id.first..QP_BULK_PREQ_GRP.G_Line_Rec.header_id.last
	Loop
		If QP_BULK_PREQ_GRP.G_Line_Rec.header_id(i) = p_header_id
		   AND
		   NVL(QP_BULK_PREQ_GRP.G_Line_Rec.cancelled_flag(i),'N')='N'

		Then
			If NVL(QP_BULK_PREQ_GRP.G_Line_Rec.line_category_code(i),'N')<>'RETURN' --order
			Then
			orders_total_amt := orders_total_amt + nvl(QP_BULK_PREQ_GRP.G_Line_Rec.ordered_quantity(i),0)*(QP_BULK_PREQ_GRP.G_Line_Rec.unit_list_price(i));
			orders_total_qty := orders_total_qty + nvl(QP_BULK_PREQ_GRP.G_Line_Rec.ordered_quantity(i),0);
			Else --return
			returns_total_amt := returns_total_amt + nvl(QP_BULK_PREQ_GRP.G_Line_Rec.ordered_quantity(i),0)*(QP_BULK_PREQ_GRP.G_Line_Rec.unit_list_price(i));
                        returns_total_qty := returns_total_qty + nvl(QP_BULK_PREQ_GRP.G_Line_Rec.ordered_quantity(i),0);
			End If; --order/return
		End If;

	End Loop;

  Else -- Non -HVOP

  /* The next two SQLs clubbed together to fix Bug. 3607932
  Begin
  SELECT SUM(nvl(ordered_quantity,0)*(unit_list_price)),
	 SUM(nvl(ordered_quantity,0))
  INTO  orders_total_amt, orders_total_qty
  FROM oe_order_lines
  WHERE header_id=p_header_id
  AND (cancelled_flag='N' OR cancelled_flag IS NULL)
  AND (line_category_code<>'RETURN' OR line_category_code IS NULL)
  GROUP BY header_id;

  EXCEPTION
        WHEN no_data_found THEN
  IF l_debug = FND_API.G_TRUE THEN
                OE_debug_pub.add('No ORDER Line Found');
  END IF;

  End;

  Begin
  SELECT SUM(nvl(ordered_quantity,0)*(unit_list_price)),
	 SUM(nvl(ordered_quantity,0))
  INTO  returns_total_amt, returns_total_qty
  FROM oe_order_lines
  WHERE header_id=p_header_id
  AND (cancelled_flag='N' OR cancelled_flag IS NULL)
  AND line_category_code='RETURN'
  GROUP BY header_id;

  EXCEPTION
	WHEN no_data_found THEN
  IF l_debug = FND_API.G_TRUE THEN
		OE_debug_pub.add('From NO Data Found');
  END IF;
  End;
  */

  Begin
  SELECT  nvl(sum(decode(line_category_code,'RETURN',
                  nvl(ordered_quantity,0)*(unit_list_price),0)),0),
          nvl(sum(decode(line_category_code,'RETURN',0,
                  nvl(ordered_quantity,0)*(unit_list_price))),0),
          nvl(sum(decode(line_category_code,'RETURN',
                  nvl(ordered_quantity,0),0)),0),
          nvl(sum(decode(line_category_code,'RETURN',0,
                  nvl(ordered_quantity,0))),0)
  INTO  returns_total_amt,
        orders_total_amt,
        returns_total_qty,
        orders_total_qty
  FROM oe_order_lines
  WHERE header_id=p_header_id
  AND (cancelled_flag='N' OR cancelled_flag IS NULL)
  AND charge_periodicity_code is null;     --  added for recurring charges Bug 4465168

  EXCEPTION
	WHEN no_data_found THEN
  IF l_debug = FND_API.G_TRUE THEN
		OE_debug_pub.add('From NO Data Found');
  END IF;
  End;

  End If; --HVOP_Pricing_On
  G_Order_Info.header_id := p_header_id;
  G_Order_Info.order_amount := QP_NUMBER.NUMBER_TO_CANONICAL(NVL(orders_total_amt,0)-NVL(returns_total_amt,0));
  G_Order_Info.order_quantity := QP_NUMBER.NUMBER_TO_CANONICAL(NVL(orders_total_qty,0)-NVL(returns_total_qty,0));

end if; --new pricing call
END;

FUNCTION Get_Order_Qty (p_header_id IN NUMBER) RETURN VARCHAR2
IS

BEGIN

	get_order_amt_and_qty(p_header_id);
	return g_order_info.order_quantity;

END Get_Order_Qty;


FUNCTION Get_Order_Amount(p_header_id IN NUMBER) RETURN VARCHAR2
IS

BEGIN

	get_order_amt_and_qty(p_header_id);
	return g_order_info.order_amount;

END Get_Order_Amount;


FUNCTION Get_Account_Type (p_cust_id IN NUMBER) RETURN QP_Attr_Mapping_PUB.t_MultiRecord
IS

BEGIN

	get_customer_info(p_cust_id);
	return g_customer_info.account_types;

END Get_Account_Type;


FUNCTION Get_Agreement_Type (p_agreement_id IN VARCHAR2) RETURN VARCHAR2
IS

BEGIN

    IF p_agreement_id = G_Agreement_Info.agreement_id THEN

	RETURN G_Agreement_Info.agreement_type_code;

    ELSE

	G_Agreement_Info.agreement_id := p_agreement_id;
        G_Agreement_Info.agreement_type_code := NULL; -- bug#3276930

    	SELECT agreement_type_code
    	INTO   G_Agreement_Info.agreement_type_code
    	FROM   oe_agreements
    	WHERE  agreement_id = p_agreement_id;

    	RETURN G_Agreement_Info.agreement_type_code;

    END IF;

END Get_Agreement_Type;

FUNCTION Get_Model_Id (p_top_model_line_id IN NUMBER) RETURN NUMBER
IS

BEGIN
/* Changed the IF condition for bug#2639759 */
    IF (p_top_model_line_id = G_TOP_MODEL_LINE_ID
        AND G_MODEL_ID IS NOT NULL) THEN

	RETURN G_MODEL_ID;

    ELSE

	G_MODEL_ID := NULL;

	If QP_UTIL_PUB.HVOP_Pricing_On = 'Y' Then --hvop

	For i in QP_BULK_PREQ_GRP.G_Line_Rec.line_id.first..QP_BULK_PREQ_GRP.G_Line_Rec.line_id.last
	Loop
		If QP_BULK_PREQ_GRP.G_Line_Rec.line_id(i) = p_top_model_line_id Then
			G_MODEL_ID := QP_BULK_PREQ_GRP.G_Line_Rec.inventory_item_id(i);
			Exit;

		End If;
	End Loop;

	Else --non hvop

    	SELECT inventory_item_id
    	INTO   G_MODEL_ID
    	FROM   oe_order_lines_all
    	WHERE  line_id = p_top_model_line_id;

	End If; --hvop

	if (G_MODEL_ID is not null) then
		G_TOP_MODEL_LINE_ID := p_top_model_line_id;
	end if;
    	RETURN G_MODEL_ID;

    END IF;

END Get_Model_Id;

FUNCTION Get_Customer_Relationship (p_cust_id IN NUMBER) RETURN QP_Attr_Mapping_PUB.t_MultiRecord
IS

BEGIN

	get_customer_info(p_cust_id);
	return g_customer_info.customer_relationships;

END Get_Customer_Relationship;

FUNCTION Get_Period1_Item_Quantity(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER, p_ordered_uom VARCHAR2) RETURN VARCHAR2
IS

x_item_quantity	NUMBER;
l_puom		VARCHAR2(240);
x_Conv_quantity	NUMBER;
--l_inv_precision NUMBER := FND_PROFILE.Value('QP_INV_DECIMAL_PRECISION');
l_inv_precision NUMBER := 40;

BEGIN

--    l_ordered_uom := OE_ORDER_PUB.G_LINE.order_quantity_uom;
    oe_debug_pub.add('Inv Precision: ' || l_inv_precision);

    BEGIN

    SELECT period1_ordered_quantity, primary_uom_code
    INTO   x_item_quantity, l_puom
    FROM   oe_item_cust_vols
    WHERE  sold_to_org_id = p_cust_id
    AND    inventory_item_id = p_inventory_item_id;

    EXCEPTION
        WHEN no_data_found THEN
            if ( (p_cust_id is not null) and (p_inventory_item_id is not null) ) THEN
                return 0;
            end if;
    END;

    x_Conv_quantity := QP_NUMBER.NUMBER_TO_CANONICAL(inv_convert.inv_um_convert(p_inventory_item_id,
								     l_inv_precision,
								     x_item_quantity,
								     l_puom,
								     p_ordered_uom,
								     NULL,NULL) );

	If x_Conv_quantity = -99999 then
		Return Null;
	Else
		Return x_Conv_quantity;
	end if;

END Get_Period1_Item_Quantity;

FUNCTION Get_Period1_Item_Quantity(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER) RETURN VARCHAR2
IS

x_return number;

BEGIN

   x_return := Get_Period1_Item_Quantity(p_cust_id , p_inventory_item_id , OE_ORDER_PUB.G_LINE.order_quantity_uom);

   return x_return;

END;

FUNCTION Get_Period2_Item_Quantity(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER, p_ordered_uom VARCHAR2) RETURN VARCHAR2
IS

x_item_quantity	NUMBER;
l_puom		VARCHAR2(240);
x_Conv_quantity	NUMBER;
--l_inv_precision NUMBER := FND_PROFILE.Value('QP_INV_DECIMAL_PRECISION');
l_inv_precision NUMBER := 40;

BEGIN

    BEGIN

    SELECT period2_ordered_quantity, primary_uom_code
    INTO   x_item_quantity, l_puom
    FROM   oe_item_cust_vols
    WHERE  sold_to_org_id = p_cust_id
    AND    inventory_item_id = p_inventory_item_id;

    EXCEPTION
        WHEN no_data_found THEN
            if ( (p_cust_id is not null) and (p_inventory_item_id is not null) ) THEN
                return 0;
            end if;

    END;

    x_Conv_quantity := QP_NUMBER.NUMBER_TO_CANONICAL(inv_convert.inv_um_convert(p_inventory_item_id,
								     l_inv_precision,
								     x_item_quantity,
								     l_puom,
								     p_ordered_uom,
								     NULL,NULL) );
	If x_Conv_quantity = -99999 then
		Return Null;
	Else
		Return x_Conv_quantity;
	end if;

END Get_Period2_Item_Quantity;

FUNCTION Get_Period2_Item_Quantity(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER) RETURN VARCHAR2
IS

x_return number;

BEGIN

   x_return := Get_Period2_Item_Quantity(p_cust_id , p_inventory_item_id , OE_ORDER_PUB.G_LINE.order_quantity_uom);

   return x_return;

END;

FUNCTION Get_Period3_Item_Quantity(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER, p_ordered_uom VARCHAR2) RETURN VARCHAR2
IS

x_item_quantity	NUMBER;
l_puom		VARCHAR2(240);
x_Conv_quantity	NUMBER;
--l_inv_precision NUMBER := FND_PROFILE.Value('QP_INV_DECIMAL_PRECISION');
l_inv_precision NUMBER := 40;

BEGIN

    BEGIN

    SELECT period3_ordered_quantity, primary_uom_code
    INTO   x_item_quantity, l_puom
    FROM   oe_item_cust_vols
    WHERE  sold_to_org_id = p_cust_id
    AND    inventory_item_id = p_inventory_item_id;

    EXCEPTION
        WHEN no_data_found THEN
            if ( (p_cust_id is not null) and (p_inventory_item_id is not null) ) THEN
                return 0;
            end if;

    END;

    x_Conv_quantity := QP_NUMBER.NUMBER_TO_CANONICAL(inv_convert.inv_um_convert(p_inventory_item_id,
								     l_inv_precision,
								     x_item_quantity,
								     l_puom,
								     p_ordered_uom,
								     NULL,NULL) );
	If x_Conv_quantity = -99999 then
		Return Null;
	Else
		Return x_Conv_quantity;
	end if;

END Get_Period3_Item_Quantity;

FUNCTION Get_Period3_Item_Quantity(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER) RETURN VARCHAR2
IS

x_return number;

BEGIN

   x_return := Get_Period3_Item_Quantity(p_cust_id , p_inventory_item_id , OE_ORDER_PUB.G_LINE.order_quantity_uom);

   return x_return;

END;

FUNCTION Get_Period1_Item_Amount(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER, p_currency_code VARCHAR2, p_conversion_rate_date DATE, p_pricing_date DATE, p_conversion_rate NUMBER, p_conversion_type_code VARCHAR2) RETURN VARCHAR2
IS

x_amount	NUMBER;
l_sob_id	NUMBER;
l_coa_id	NUMBER;
l_sob_name	VARCHAR2(240);
l_err_buff	VARCHAR2(2000);
l_sob_currency	VARCHAR2(30);

BEGIN

    BEGIN

    SELECT period1_total_amount
    INTO   x_amount
    FROM   oe_item_cust_vols
    WHERE  sold_to_org_id = p_cust_id
    AND    inventory_item_id = p_inventory_item_id;

    EXCEPTION
        WHEN no_data_found THEN
            if ( (p_cust_id is not null) and (p_inventory_item_id is not null) ) THEN
                return 0;
            end if;
    END;

    l_sob_id := FND_PROFILE.Value('OE_SET_OF_BOOKS_ID');

--    gl_info.gl_get_set_of_books_info(l_sob_id,l_coa_id,l_sob_name,l_sob_currency, l_err_buff);
-- Replaced with following select statement per bug 4537515 (sfiresto)
    BEGIN
       SELECT name, chart_of_accounts_id, currency_code
       INTO l_sob_name, l_coa_id, l_sob_currency
       FROM gl_ledgers_public_v
       WHERE ledger_id = l_sob_id;
    EXCEPTION
       WHEN others THEN
         l_err_buff := sqlerrm;
    END;

    --dbms_output.put_line('SOB Currency: ' || l_sob_currency);

    If l_sob_currency <> p_currency_code Then

    x_amount := QP_Cross_Order_Volume_Load.convert_to_base_curr(
    		p_trans_amount => x_amount,
		p_From_currency => l_sob_currency,
		p_to_currency  => p_currency_code,
		p_conversion_date => nvl( p_conversion_rate_date, p_pricing_date),
		p_conversion_rate => p_conversion_rate,
		p_conversion_type => p_conversion_type_code
		);
    End If;
    /*
    x_amount := gl_currency_api.convert_amount(l_sob_currency,
					       oe_order_pub.g_hdr.transactional_curr_code,
					       oe_order_pub.g_hdr.conversion_rate_date,
					       oe_order_pub.g_hdr.conversion_type_code,
					       x_amount);
	*/

    RETURN QP_NUMBER.NUMBER_TO_CANONICAL(x_amount);

END Get_Period1_Item_Amount;

FUNCTION Get_Period1_Item_Amount(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER) RETURN VARCHAR2
IS

x_return number;

BEGIN

     x_return := Get_Period1_Item_Amount(p_cust_id,
					p_inventory_item_id,
					oe_order_pub.g_hdr.transactional_curr_code,
					oe_order_pub.g_hdr.conversion_rate_date,
					oe_order_pub.g_hdr.Pricing_date,
					oe_order_pub.g_hdr.conversion_rate,
					oe_order_pub.g_hdr.conversion_type_code);

     return x_return;

END;

FUNCTION Get_Period2_Item_Amount(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER, p_currency_code VARCHAR2, p_conversion_rate_date DATE, p_pricing_date DATE, p_conversion_rate NUMBER, p_conversion_type_code VARCHAR2) RETURN VARCHAR2
IS

x_amount	NUMBER;
l_sob_id	NUMBER;
l_coa_id	NUMBER;
l_sob_name	VARCHAR2(240);
l_err_buff	VARCHAR2(2000);
l_sob_currency	VARCHAR2(30);

BEGIN

    BEGIN

    SELECT period2_total_amount
    INTO   x_amount
    FROM   oe_item_cust_vols
    WHERE  sold_to_org_id = p_cust_id
    AND    inventory_item_id = p_inventory_item_id;

    EXCEPTION
        WHEN no_data_found THEN
            if ( (p_cust_id is not null) and (p_inventory_item_id is not null) ) THEN
                return 0;
            end if;

    END;

    l_sob_id := FND_PROFILE.Value('OE_SET_OF_BOOKS_ID');

--    gl_info.gl_get_set_of_books_info(l_sob_id,l_coa_id,l_sob_name,l_sob_currency,l_err_buff);
-- Replaced with following select statement per bug 4537515 (sfiresto)
    BEGIN
       SELECT name, chart_of_accounts_id, currency_code
       INTO l_sob_name, l_coa_id, l_sob_currency
       FROM gl_ledgers_public_v
       WHERE ledger_id = l_sob_id;
    EXCEPTION
       WHEN others THEN
         l_err_buff := sqlerrm;
    END;

    If l_sob_currency <> p_currency_code Then

    	x_amount := QP_Cross_Order_Volume_Load.convert_to_base_curr(
    		p_trans_amount => x_amount,
		p_From_currency => l_sob_currency,
		p_to_currency  => p_currency_code,
		p_conversion_date => nvl(p_conversion_rate_date, p_pricing_date),
		p_conversion_rate => p_conversion_rate,
		p_conversion_type => p_conversion_type_code
		);
    End If;

    /*
    x_amount := gl_currency_api.convert_amount(l_sob_currency,
					       oe_order_pub.g_hdr.transactional_curr_code,
					       oe_order_pub.g_hdr.conversion_rate_date,
					       oe_order_pub.g_hdr.conversion_type_code,
					       x_amount);

    */
    RETURN QP_NUMBER.NUMBER_TO_CANONICAL(x_amount);

END Get_Period2_Item_Amount;

FUNCTION Get_Period2_Item_Amount(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER) RETURN VARCHAR2
IS

x_return number;

BEGIN

     x_return := Get_Period2_Item_Amount(p_cust_id,
					p_inventory_item_id,
					oe_order_pub.g_hdr.transactional_curr_code,
					oe_order_pub.g_hdr.conversion_rate_date,
					oe_order_pub.g_hdr.Pricing_date,
					oe_order_pub.g_hdr.conversion_rate,
					oe_order_pub.g_hdr.conversion_type_code);

     return x_return;

END;

FUNCTION Get_Period3_Item_Amount(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER, p_currency_code VARCHAR2, p_conversion_rate_date DATE, p_pricing_date DATE, p_conversion_rate NUMBER, p_conversion_type_code VARCHAR2) RETURN VARCHAR2
IS

x_amount	NUMBER;
l_sob_id	NUMBER;
l_coa_id	NUMBER;
l_sob_name	VARCHAR2(240);
l_err_buff	VARCHAR2(2000);
l_sob_currency	VARCHAR2(30);

BEGIN

    BEGIN

    SELECT period3_total_amount
    INTO   x_amount
    FROM   oe_item_cust_vols
    WHERE  sold_to_org_id = p_cust_id
    AND    inventory_item_id = p_inventory_item_id;

    EXCEPTION
        WHEN no_data_found THEN
            if ( (p_cust_id is not null) and (p_inventory_item_id is not null) ) THEN
                return 0;
            end if;
    END;

    l_sob_id := FND_PROFILE.Value('OE_SET_OF_BOOKS_ID');

--    gl_info.gl_get_set_of_books_info(l_sob_id,l_coa_id,l_sob_name,l_sob_currency, l_err_buff);
-- Replaced with following select statement per bug 4537515 (sfiresto)
    BEGIN
       SELECT name, chart_of_accounts_id, currency_code
       INTO l_sob_name, l_coa_id, l_sob_currency
       FROM gl_ledgers_public_v
       WHERE ledger_id = l_sob_id;
    EXCEPTION
       WHEN others THEN
         l_err_buff := sqlerrm;
    END;

    If l_sob_currency <> p_currency_code Then

    x_amount := QP_Cross_Order_Volume_Load.convert_to_base_curr(
    		p_trans_amount => x_amount,
		p_From_currency => l_sob_currency,
		p_to_currency  => p_currency_code,
		p_conversion_date => nvl(p_conversion_rate_date, p_pricing_date),
		p_conversion_rate => p_conversion_rate,
		p_conversion_type => p_conversion_type_code
		);
    End If;


/* Old Code
    If l_sob_currency <> oe_order_pub.g_hdr.transactional_curr_code Then

    x_amount := QP_Cross_Order_Volume_Load.convert_to_base_curr(
    		p_trans_amount => x_amount,
		p_From_currency => l_sob_currency,
		p_to_currency  => oe_order_pub.g_hdr.transactional_curr_code,
		p_conversion_date => nvl(oe_order_pub.g_hdr.conversion_rate_date,
						oe_order_pub.g_hdr.Pricing_date),
		p_conversion_rate => oe_order_pub.g_hdr.conversion_rate,
		p_conversion_type => oe_order_pub.g_hdr.conversion_type_code
		);
    End If;
*/

    RETURN QP_NUMBER.NUMBER_TO_CANONICAL(x_amount);

END Get_Period3_Item_Amount;

FUNCTION Get_Period3_Item_Amount(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER) RETURN VARCHAR2
IS

x_return number;

BEGIN

     x_return := Get_Period3_Item_Amount(p_cust_id,
					p_inventory_item_id,
					oe_order_pub.g_hdr.transactional_curr_code,
					oe_order_pub.g_hdr.conversion_rate_date,
					oe_order_pub.g_hdr.Pricing_date,
					oe_order_pub.g_hdr.conversion_rate,
					oe_order_pub.g_hdr.conversion_type_code);

     return x_return;

END;


FUNCTION Get_Period1_Order_Amount(p_cust_id IN NUMBER, p_currency_code VARCHAR2, p_conversion_rate_date DATE, p_pricing_date DATE, p_conversion_rate NUMBER, p_conversion_type_code VARCHAR2) RETURN VARCHAR2
IS

x_total_amount	NUMBER;
l_sob_id	NUMBER;
l_coa_id	NUMBER;
l_sob_name	VARCHAR2(240);
l_err_buff	VARCHAR2(2000);
l_sob_currency	VARCHAR2(30);

BEGIN

	if qp_preq_grp.g_new_pricing_call = qp_preq_grp.g_yes then

    BEGIN

    SELECT period1_total_amount
    INTO   x_total_amount
    FROM   oe_cust_total_amts
    WHERE  sold_to_org_id = p_cust_id;

    EXCEPTION
        WHEN no_data_found THEN
            if (p_cust_id is not null) THEN
                return 0;
            end if;
    END;

    l_sob_id := FND_PROFILE.Value('OE_SET_OF_BOOKS_ID');

--    gl_info.gl_get_set_of_books_info(l_sob_id,l_coa_id,l_sob_name,l_sob_currency,l_err_buff);
-- Replaced with following select statement per bug 4537515 (sfiresto)
    BEGIN
       SELECT name, chart_of_accounts_id, currency_code
       INTO l_sob_name, l_coa_id, l_sob_currency
       FROM gl_ledgers_public_v
       WHERE ledger_id = l_sob_id;
    EXCEPTION
       WHEN others THEN
         l_err_buff := sqlerrm;
    END;

    If l_sob_currency <> p_currency_code Then

    x_total_amount := QP_Cross_Order_Volume_Load.convert_to_base_curr(
    		p_trans_amount => x_total_amount,
		p_From_currency => l_sob_currency,
		p_to_currency  => p_currency_code,
		p_conversion_date => nvl(p_conversion_rate_date, p_pricing_date),
		p_conversion_rate => p_conversion_rate,
		p_conversion_type => p_conversion_type_code
		);
    End If;
    /*
    x_total_amount := gl_currency_api.convert_amount(l_sob_currency,
					       oe_order_pub.g_hdr.transactional_curr_code,
					       oe_order_pub.g_hdr.conversion_rate_date,
					       oe_order_pub.g_hdr.conversion_type_code,
					       x_total_amount) ;
						  --+ G_Order_Info.order_amount;
*/

		g_order_info.period1_total_amount := qp_number.number_to_canonical(x_total_amount);
	end if;

	return g_order_info.period1_total_amount;


END Get_Period1_Order_Amount;

FUNCTION Get_Period1_Order_Amount(p_cust_id IN NUMBER) RETURN VARCHAR2
IS

x_return number;

BEGIN

    x_return := Get_Period1_Order_Amount(p_cust_id, oe_order_pub.g_hdr.transactional_curr_code, oe_order_pub.g_hdr.conversion_rate_date, oe_order_pub.g_hdr.Pricing_date, oe_order_pub.g_hdr.conversion_rate, oe_order_pub.g_hdr.conversion_type_code);

    return x_return;

END;

FUNCTION Get_Period2_Order_Amount(p_cust_id IN NUMBER, p_currency_code VARCHAR2, p_conversion_rate_date DATE, p_pricing_date DATE, p_conversion_rate NUMBER, p_conversion_type_code VARCHAR2) RETURN VARCHAR2
IS

x_total_amount	NUMBER;
l_sob_id	NUMBER;
l_coa_id	NUMBER;
l_sob_name	VARCHAR2(240);
l_err_buff	VARCHAR2(2000);
l_sob_currency	VARCHAR2(30);

BEGIN

	if qp_preq_grp.g_new_pricing_call = qp_preq_grp.g_yes then

    BEGIN

    SELECT period2_total_amount
    INTO   x_total_amount
    FROM   oe_cust_total_amts
    WHERE  sold_to_org_id = p_cust_id;

    EXCEPTION
        WHEN no_data_found THEN
            if (p_cust_id is not null) THEN
                return 0;
            end if;
    END;

    l_sob_id := FND_PROFILE.Value('OE_SET_OF_BOOKS_ID');

--    gl_info.gl_get_set_of_books_info(l_sob_id,l_coa_id,l_sob_name,l_sob_currency,l_err_buff);
-- Replaced with following select statement per bug 4537515 (sfiresto)
    BEGIN
       SELECT name, chart_of_accounts_id, currency_code
       INTO l_sob_name, l_coa_id, l_sob_currency
       FROM gl_ledgers_public_v
       WHERE ledger_id = l_sob_id;
    EXCEPTION
       WHEN others THEN
         l_err_buff := sqlerrm;
    END;

    If l_sob_currency <> p_currency_code Then

    x_total_amount := QP_Cross_Order_Volume_Load.convert_to_base_curr(
    		p_trans_amount => x_total_amount,
		p_From_currency => l_sob_currency,
		p_to_currency  => p_currency_code,
		p_conversion_date => nvl(p_conversion_rate_date, p_pricing_date),
		p_conversion_rate => p_conversion_rate,
		p_conversion_type => p_conversion_type_code
		);
    End If;
    /*
    x_total_amount := gl_currency_api.convert_amount( l_sob_currency,
					       oe_order_pub.g_hdr.transactional_curr_code,
					       oe_order_pub.g_hdr.conversion_rate_date,
					       oe_order_pub.g_hdr.conversion_type_code,
					       x_total_amount) ;
						  --+ G_Order_Info.order_amount;
*/

		g_order_info.period2_total_amount := qp_number.number_to_canonical(x_total_amount);
	end if;

	return g_order_info.period2_total_amount;

END Get_Period2_Order_Amount;

FUNCTION Get_Period2_Order_Amount(p_cust_id IN NUMBER) RETURN VARCHAR2
IS

x_return number;

BEGIN

    x_return := Get_Period2_Order_Amount(p_cust_id, oe_order_pub.g_hdr.transactional_curr_code, oe_order_pub.g_hdr.conversion_rate_date, oe_order_pub.g_hdr.Pricing_date, oe_order_pub.g_hdr.conversion_rate, oe_order_pub.g_hdr.conversion_type_code);

    return x_return;

END;

FUNCTION Get_Period3_Order_Amount(p_cust_id IN NUMBER, p_currency_code VARCHAR2, p_conversion_rate_date DATE, p_pricing_date DATE, p_conversion_rate NUMBER, p_conversion_type_code VARCHAR2) RETURN VARCHAR2
IS

x_total_amount	NUMBER;
l_sob_id	NUMBER;
l_coa_id	NUMBER;
l_sob_name	VARCHAR2(240);
l_err_buff	VARCHAR2(2000);
l_sob_currency	VARCHAR2(30);

BEGIN

	if qp_preq_grp.g_new_pricing_call = qp_preq_grp.g_yes then

    BEGIN

    SELECT period3_total_amount
    INTO   x_total_amount
    FROM   oe_cust_total_amts
    WHERE  sold_to_org_id = p_cust_id;

    EXCEPTION
        WHEN no_data_found THEN
            if (p_cust_id is not null) THEN
                return 0;
            end if;
    END;

    l_sob_id := FND_PROFILE.Value('OE_SET_OF_BOOKS_ID');

--    gl_info.gl_get_set_of_books_info(l_sob_id,l_coa_id,l_sob_name,l_sob_currency,l_err_buff);
-- Replaced with following select statement per bug 4537515 (sfiresto)
    BEGIN
       SELECT name, chart_of_accounts_id, currency_code
       INTO l_sob_name, l_coa_id, l_sob_currency
       FROM gl_ledgers_public_v
       WHERE ledger_id = l_sob_id;
    EXCEPTION
       WHEN others THEN
         l_err_buff := sqlerrm;
    END;

    If l_sob_currency <> p_currency_code Then

    x_total_amount := QP_Cross_Order_Volume_Load.convert_to_base_curr(
    		p_trans_amount => x_total_amount,
		p_From_currency => l_sob_currency,
		p_to_currency  => p_currency_code,
		p_conversion_date => nvl(p_conversion_rate_date, p_pricing_date),
		p_conversion_rate => p_conversion_rate,
		p_conversion_type => p_conversion_type_code
		);
    End If;
    /*
    x_total_amount := gl_currency_api.convert_amount(l_sob_currency,
					       oe_order_pub.g_hdr.transactional_curr_code,
					       oe_order_pub.g_hdr.conversion_rate_date,
					       oe_order_pub.g_hdr.conversion_type_code,
					       x_total_amount) ;
						  --+ G_Order_Info.order_amount;

    */

		g_order_info.period3_total_amount := qp_number.number_to_canonical(x_total_amount);
	end if;

	return g_order_info.period3_total_amount;

END Get_Period3_Order_Amount;

FUNCTION Get_Period3_Order_Amount(p_cust_id IN NUMBER) RETURN VARCHAR2
IS

x_return number;

BEGIN

    x_return := Get_Period3_Order_Amount(p_cust_id, oe_order_pub.g_hdr.transactional_curr_code, oe_order_pub.g_hdr.conversion_rate_date, oe_order_pub.g_hdr.Pricing_date, oe_order_pub.g_hdr.conversion_rate, oe_order_pub.g_hdr.conversion_type_code);

    return x_return;

END;

/* Begin of getting TCA attributes */

FUNCTION GET_PARTY_ID (p_sold_to_org_id IN NUMBER) RETURN NUMBER IS

l_party_id NUMBER;

CURSOR get_party_id_cur(l_sold_to_org_id NUMBER) IS
 SELECT party_id
 FROM   hz_cust_accounts
 WHERE  cust_account_id = l_sold_to_org_id;

BEGIN
  OPEN get_party_id_cur(p_sold_to_org_id);
  FETCH get_party_id_cur INTO l_party_id;
  CLOSE get_party_id_cur;
  RETURN l_party_id;


EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END GET_PARTY_ID;


FUNCTION GET_SHIP_TO_PARTY_SITE_ID(p_ship_to_org_id IN NUMBER) RETURN NUMBER IS

l_ship_to_party_site_id NUMBER;

CURSOR get_ship_to_site_id_cur (l_ship_to_org_id NUMBER) IS
 SELECT a.party_site_id
 FROM   hz_cust_acct_sites a,
        hz_cust_site_uses b
 WHERE  a.cust_acct_site_id = b.cust_acct_site_id
 AND    b.site_use_id       = l_ship_to_org_id
 AND    b.site_use_code     = 'SHIP_TO';

BEGIN
  OPEN get_ship_to_site_id_cur (p_ship_to_org_id);
  FETCH get_ship_to_site_id_cur INTO l_ship_to_party_site_id;
  CLOSE get_ship_to_site_id_cur;

  RETURN l_ship_to_party_site_id;

EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END GET_SHIP_TO_PARTY_SITE_ID;


FUNCTION GET_INVOICE_TO_PARTY_SITE_ID(p_invoice_to_org_id IN NUMBER) RETURN NUMBER IS

l_bill_to_party_site_id NUMBER;

CURSOR get_bill_to_site_id_cur (l_bill_to_org_id NUMBER) IS
 SELECT a.party_site_id
 FROM   hz_cust_acct_sites a,
        hz_cust_site_uses b
 WHERE  a.cust_acct_site_id = b.cust_acct_site_id
 AND    b.site_use_id       = l_bill_to_org_id
 AND    b.site_use_code     = 'BILL_TO';

BEGIN
  OPEN get_bill_to_site_id_cur (p_invoice_to_org_id);
  FETCH get_bill_to_site_id_cur INTO l_bill_to_party_site_id;
  CLOSE get_bill_to_site_id_cur;

  RETURN l_bill_to_party_site_id;

EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END GET_INVOICE_TO_PARTY_SITE_ID;

/* End of getting TCA attributes */

FUNCTION Get_Line_Weight_Or_Volume
(   p_uom_class      IN  VARCHAR2,
    p_inventory_item_id	 IN NUMBER,
    p_ordered_quantity IN NUMBER,
    p_order_quantity_uom IN VARCHAR2
)
RETURN VARCHAR2
IS
    l_uom_code            VARCHAR2(3);
    l_uom_rate            NUMBER;
BEGIN

    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF p_uom_class NOT IN ('Weight','Volume')
    THEN
           IF l_debug = FND_API.G_TRUE THEN
           oe_debug_pub.add('Invalide parameter' || p_uom_class);
           END IF;
        RETURN NULL;
    END IF;

    IF p_uom_class = 'Weight' THEN
           l_uom_code := FND_PROFILE.VALUE('QP_LINE_WEIGHT_UOM_CODE');
    ELSE
           l_uom_code := FND_PROFILE.VALUE('QP_LINE_VOLUME_UOM_CODE');
    END IF;

    IF l_uom_code IS NULL THEN
           IF l_debug = FND_API.G_TRUE THEN
           oe_debug_pub.add('No value set in the Profile Options.');
           END IF;
           RETURN NULL;
    END IF;

    INV_CONVERT.INV_UM_CONVERSION(p_order_quantity_uom, l_uom_code, p_inventory_item_id, l_uom_rate);

    IF l_uom_rate > 0 THEN
          RETURN QP_NUMBER.NUMBER_TO_CANONICAL(TRUNC(l_uom_rate * p_ordered_quantity, 2));
    ELSE
           IF l_debug = FND_API.G_TRUE THEN
           oe_debug_pub.add('No conversion information is available for converting from ' || p_order_quantity_uom || ' TO ' || l_uom_code);
           END IF;
        RETURN NULL;
    END IF;

END Get_Line_Weight_Or_Volume;


FUNCTION Get_Order_Weight_Or_Volume
(   p_uom_class      IN  VARCHAR2,
    p_header_id	 IN NUMBER
)
RETURN VARCHAR2
IS

--  TYPE t_cursor IS REF CURSOR;
    l_uom_code            VARCHAR2(3);
    l_uom_rate            NUMBER;
    l_order_total           NUMBER := 0;
    --l_lines_cursor	  t_cursor;
    l_ordered_quantity    NUMBER;
    l_ordered_quantity_uom VARCHAR2(30);
    l_inventory_item_id   NUMBER;
    --
    CURSOR l_lines_cursor(header_id_in number) is
      SELECT ordered_quantity,order_quantity_uom,inventory_item_id
      FROM   oe_order_lines_all
      WHERE  header_id = header_id_in;

BEGIN

    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
if qp_preq_grp.g_new_pricing_call = qp_preq_grp.g_yes then

    IF p_uom_class NOT IN ('Weight','Volume')
    THEN
           IF l_debug = FND_API.G_TRUE THEN
           oe_debug_pub.add('Invalid parameter' || p_uom_class);
           END IF;
        RETURN NULL;
    END IF;

    IF p_uom_class = 'Weight' THEN
           l_uom_code := FND_PROFILE.VALUE('QP_LINE_WEIGHT_UOM_CODE');
    ELSE
           l_uom_code := FND_PROFILE.VALUE('QP_LINE_VOLUME_UOM_CODE');
    END IF;

    IF l_uom_code IS NULL THEN
           IF l_debug = FND_API.G_TRUE THEN
           oe_debug_pub.add('No value set in the Profile Options.');
           END IF;
           RETURN NULL;
    END IF;

    If QP_Util_PUB.HVOP_Pricing_On = 'Y' Then
	For i in QP_BULK_PREQ_GRP.G_Line_Rec.header_id.first..QP_BULK_PREQ_GRP.G_Line_Rec.header_id.last
        Loop
		If QP_BULK_PREQ_GRP.G_Line_Rec.header_id(i) = p_header_id Then
			l_ordered_quantity := QP_BULK_PREQ_GRP.G_Line_Rec.ordered_quantity(i);
			l_ordered_quantity_uom := QP_BULK_PREQ_GRP.G_Line_Rec.order_quantity_uom(i);
			l_inventory_item_id := QP_BULK_PREQ_GRP.G_Line_Rec.inventory_item_id(i);

			INV_CONVERT.INV_UM_CONVERSION(l_ordered_quantity_uom, l_uom_code, l_inventory_item_id, l_uom_rate);

        		IF l_uom_rate > 0 THEN
                		l_order_total := l_order_total +
						QP_NUMBER.NUMBER_TO_CANONICAL(TRUNC(l_uom_rate * l_ordered_quantity, 2));
       			ELSE
            			IF l_debug = FND_API.G_TRUE THEN
                			oe_debug_pub.add('No conversion information is available for converting from ' || l_ordered_quantity_uom || 'TO ' || l_uom_code);
            			END IF;
                	RETURN NULL;

        		END IF;
		End If;
    	END Loop;
   Else -- Non HVOP

    OPEN l_lines_cursor(p_header_id);

    LOOP

        FETCH l_lines_cursor INTO
	l_ordered_quantity,
	l_ordered_quantity_uom,
	l_inventory_item_id;
        EXIT WHEN l_lines_cursor%NOTFOUND;



    	INV_CONVERT.INV_UM_CONVERSION(l_ordered_quantity_uom, l_uom_code, l_inventory_item_id, l_uom_rate);

    	IF l_uom_rate > 0 THEN
          	l_order_total := (l_order_total + TRUNC(l_uom_rate * l_ordered_quantity, 2));
    	ELSE
            IF l_debug = FND_API.G_TRUE THEN
           	oe_debug_pub.add('No conversion information is available for converting from ' || l_ordered_quantity_uom || ' TO ' || l_uom_code);
            END IF;
        	--RETURN NULL;
    	END IF;

    END LOOP;
    CLOSE l_lines_cursor;
   End If; -- HVOP

	g_order_info.order_total := l_order_total;
end if; --g_new_pricing_call

	return QP_NUMBER.NUMBER_TO_CANONICAL(g_order_info.order_total); -- bug 3191779

END Get_Order_Weight_Or_Volume;

FUNCTION Get_Shippable_Flag(p_header_id IN NUMBER) RETURN VARCHAR2
IS

l_shippable_flag  VARCHAR2(1);
x_count 	  NUMBER;

BEGIN

	if qp_preq_grp.g_new_pricing_call = qp_preq_grp.g_yes then

    l_shippable_flag := 'N';

	begin

    If QP_Util_PUB.HVOP_Pricing_On = 'Y' Then --HVOP
    	For i in QP_BULK_PREQ_GRP.G_Line_Rec.line_id.first..QP_BULK_PREQ_GRP.G_Line_Rec.line_id.last
	Loop
		If QP_BULK_PREQ_GRP.G_Line_Rec.shippable_flag(i) = 'Y' Then
			x_count := 1;
			Exit;
		End If;
	End Loop;
    Else  --Non HVOP
    SELECT count(*)
    INTO  x_count
    FROM  oe_order_lines_all
    WHERE shippable_flag = 'Y'
    AND   header_id = p_header_id
    AND   rownum < 2;

    End If; --HVOP

    IF x_count > 0 THEN
       l_shippable_flag := 'Y';
    END IF;

    EXCEPTION
	WHEN no_data_found THEN
	     l_shippable_flag := 'N';

	end;

	g_order_info.shippable_flag := l_shippable_flag;
	end if;

	return g_order_info.shippable_flag;

END Get_Shippable_Flag;

FUNCTION Get_Item_Quantity
(   p_ordered_qty IN NUMBER,
    p_pricing_qty IN NUMBER
)
RETURN VARCHAR2
IS

BEGIN

  RETURN QP_NUMBER.NUMBER_TO_CANONICAL(NVL(p_pricing_qty,p_ordered_qty));

END Get_Item_Quantity;

FUNCTION Get_Item_Amount
(   p_ordered_qty IN NUMBER,
    p_pricing_qty IN NUMBER
)
RETURN VARCHAR2
IS

x_return NUMBER;

BEGIN

  x_return := QP_NUMBER.NUMBER_TO_CANONICAL(NVL(p_pricing_qty,p_ordered_qty) * NVL(OE_ORDER_PUB.G_LINE.UNIT_LIST_PRICE_PER_PQTY, OE_ORDER_PUB.G_LINE.UNIT_LIST_PRICE));

  IF (OE_ORDER_PUB.G_LINE.UNIT_LIST_PRICE_PER_PQTY IS NULL) AND (OE_ORDER_PUB.G_LINE.UNIT_LIST_PRICE is NULL) THEN
     x_return := 0;
  END IF;

  RETURN x_return;

END Get_Item_Amount;


Procedure Get_Customer_Info(p_cust_id NUMBER, invoice_to_org_id NUMBER)
IS

--TYPE t_cursor IS REF CURSOR;

l_account_type_id      VARCHAR2(30);
v_count                NUMBER := 1;
--l_acct_type_cursor     t_cursor;
l_realted_cust_id      VARCHAR2(30);
--l_related_cust_cursor  t_cursor;
--
CURSOR l_acct_type_cursor (cust_id_in number) is
    SELECT distinct profile_class_id
    FROM   HZ_CUSTOMER_PROFILES
    WHERE  cust_account_id = cust_id_in;
CURSOR   l_related_cust_cursor(cust_id_in number) is
    SELECT RELATED_CUST_ACCOUNT_ID
    FROM   HZ_CUST_ACCT_RELATE
    WHERE  cust_account_id = cust_id_in;

BEGIN

	if qp_preq_grp.g_new_pricing_call = qp_preq_grp.g_yes then

    G_Customer_Info.customer_id := p_cust_id;

--  Getting info from HZ_CUST_ACCOUNTS

    BEGIN
    	SELECT customer_class_code, sales_channel_code
    	INTO   G_Customer_Info.customer_class_code, G_Customer_Info.sales_channel_code
	FROM   hz_cust_accounts
    	WHERE  cust_account_id = p_cust_id;

	EXCEPTION
		WHEN no_data_found THEN
			G_Customer_Info.customer_class_code := null;
			G_Customer_Info.sales_channel_code := null;

    END;

-- Getting GSA info

    BEGIN
        SELECT NVL(gsa_indicator,'N')
        INTO G_Customer_Info.gsa_indicator
        FROM hz_cust_site_uses hsu
        WHERE site_use_id = invoice_to_org_id
        --added for moac
        and hsu.org_id = QP_ATTR_MAPPING_PUB.G_ORG_ID;
/*
        AND  NVL(hsu.org_id,
         NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1 ,1), ' ',NULL,
              SUBSTRB(USERENV('CLIENT_INFO'), 1,10))),-99)) =
         NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ',NULL,
         SUBSTRB(USERENV('CLIENT_INFO'),1,10))), -99);
*/

        EXCEPTION

        WHEN NO_DATA_FOUND THEN
             G_Customer_Info.gsa_indicator := 'N';

    END;

    IF G_Customer_Info.gsa_indicator = 'N' THEN

        BEGIN

           SELECT NVL(gsa_indicator_flag,'N')
           into G_Customer_Info.gsa_indicator
           from hz_parties hp,hz_cust_accounts hca
           where hp.party_id = hca.party_id
           and hca.cust_account_id = p_cust_id ;

           EXCEPTION

           WHEN NO_DATA_FOUND THEN
             G_Customer_Info.gsa_indicator := null;

        END;

    END IF;


--  Getting Account Types

/*
    OPEN l_acct_type_cursor FOR
    SELECT distinct customer_profile_class_id
    FROM   AR_CUSTOMER_PROFILES
    WHERE  customer_id = p_cust_id;
*/
    OPEN l_acct_type_cursor(p_cust_id);
    LOOP

	FETCH l_acct_type_cursor INTO l_account_type_id;
	EXIT WHEN l_acct_type_cursor%NOTFOUND;

	G_Customer_Info.account_types(v_count) := l_account_type_id;
        v_count := v_count + 1;

    END LOOP;

    CLOSE l_acct_type_cursor;

--  Get Customer Relationships

    v_count := 1;

/*
    OPEN   l_related_cust_cursor FOR
    SELECT RELATED_CUSTOMER_ID
    FROM   RA_CUSTOMER_RELATIONSHIPS
    WHERE  customer_id = p_cust_id;
*/

    OPEN l_related_cust_cursor(p_cust_id);
    LOOP

	FETCH l_related_cust_cursor INTO l_realted_cust_id;
	EXIT WHEN l_related_cust_cursor%NOTFOUND;

	G_Customer_Info.customer_relationships(v_count) := l_realted_cust_id;
        v_count := v_count + 1;

    END LOOP;

    CLOSE l_related_cust_cursor;

	end if;

END;

FUNCTION Get_Item_Amount
(   p_ordered_qty IN NUMBER,
    p_pricing_qty IN NUMBER,
    p_UNIT_LIST_PRICE_PER_PQTY IN NUMBER,
    p_unit_list_price IN NUMBER
)
RETURN VARCHAR2
IS

x_return NUMBER;

BEGIN

  x_return := QP_NUMBER.NUMBER_TO_CANONICAL(NVL(p_pricing_qty,p_ordered_qty) * NVL(p_UNIT_LIST_PRICE_PER_PQTY, p_UNIT_LIST_PRICE));

  IF (p_UNIT_LIST_PRICE_PER_PQTY IS NULL) AND (p_UNIT_LIST_PRICE is NULL) THEN
     x_return := 0;
  END IF;

  RETURN x_return;
END;

END QP_SOURCING_API_PUB;

/
