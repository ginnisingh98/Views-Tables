--------------------------------------------------------
--  DDL for Package Body OE_ORDER_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_CACHE" AS
/* $Header: OEXUCCHB.pls 120.13.12010000.1 2008/07/25 07:54:59 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME      CONSTANT    VARCHAR2(30):='OE_Order_Cache';


--  Procedures that load cached entities.

PROCEDURE Enforce_List_Price
(   p_header_id	number
,	p_Line_Type_id		Number
)
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.Enforce_List_price', 1);
  end if;

    IF p_Line_Type_id IS NOT NULL THEN

		IF 	g_Enforce_list_price_rec.Line_Type_id = FND_API.G_MISS_NUM OR
	   		g_Enforce_list_price_rec.Line_Type_id <> p_Line_Type_id THEN

	    	SELECT
	    		    p_Line_Type_id
	    	,		nvl(enforce_line_prices_flag,'N')
	    	INTO
	    			g_Enforce_list_price_rec.Line_Type_id
	    		,	g_Enforce_list_price_rec.enforce_line_prices_flag
	    	from	oe_line_types_v
		    WHERE   LINE_TYPE_ID = p_Line_Type_id;

		END IF;

    END IF;

    IF 	p_header_id IS NOT NULL  and
		g_Enforce_list_price_rec.enforce_line_prices_flag <> 'Y' THEN

		IF 	g_Enforce_list_price_rec.header_id = FND_API.G_MISS_NUM OR
	   		g_Enforce_list_price_rec.header_id <> p_header_id
	   	THEN

	    	SELECT  /*MOAC_SQL_CHANGES*/
	    			    p_header_id
	    		,		nvl(oot.enforce_line_prices_flag,'N')
	    	INTO
	    			g_Enforce_list_price_rec.header_id
	    		,	g_Enforce_list_price_rec.enforce_line_prices_flag
	    	from oe_Order_types_v oot,oe_order_headers_all ooh
			where oot.order_type_id= ooh.order_type_id and
			ooh.header_id = p_header_id and ooh.org_id=oot.org_id;

		END IF;

    END IF;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_ORDER_CACHE.Enforce_List_price', 1);
  end if;

EXCEPTION

    When no_data_found then
	g_Enforce_list_price_rec.enforce_line_prices_flag :='N';

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Enforce_List_price'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Enforce_List_price;

FUNCTION Load_Order_Type
(   p_key	IN NUMBER )
RETURN Order_Type_Rec_Type
IS
BEGIN
    Load_Order_Type(p_key);

    RETURN g_order_type_rec;
END Load_Order_Type;

PROCEDURE Load_Order_Type
(   p_key   IN NUMBER )
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.LOAD_ORDER_TYPE', 1);
  end if;

    IF 	p_key IS NOT NULL THEN

		IF 	g_order_type_rec.order_type_id = FND_API.G_MISS_NUM OR
	   		g_order_type_rec.order_type_id <> p_key THEN

                oe_debug_pub.add('Loading order Type');
	    	SELECT  ORDER_TYPE_ID
	    	,         NAME
	    	,	    INVOICING_RULE_ID
	    	,	    ACCOUNTING_RULE_ID
	    	,	    PRICE_LIST_ID
	    	,	    SHIPMENT_PRIORITY_CODE
	    	,	    fob_point_code FOB_POINT_CODE
	    	,	    FREIGHT_TERMS_CODE
	    	,	    warehouse_id SHIP_FROM_ORG_ID
	    	,	    AGREEMENT_TYPE_CODE
	    	,	    shipping_method_code SHIPPING_METHOD_CODE
	    	,	    AGREEMENT_REQUIRED_FLAG
	    	,	    PO_REQUIRED_FLAG
	    	,		enforce_line_prices_flag
            ,       auto_scheduling_flag
                -- QUOTING changes
	    	,	    quote_num_as_ord_num_flag
                ,   invoice_source_id
                ,   non_delivery_invoice_source_id
		,   cust_trx_type_id
		 --added for bug 4200055
		,           start_date_active
		,           end_date_active
	  	,           tax_calculation_event_code
	    	INTO    g_order_type_rec.order_type_id
	    	,       g_order_type_rec.name
	    	,	    g_order_type_rec.invoicing_rule_id
	    	,	    g_order_type_rec.accounting_rule_id
	    	,	    g_order_type_rec.price_list_id
	    	,	    g_order_type_rec.shipment_priority_code
	    	,	    g_order_type_rec.fob_point_code
	    	,	    g_order_type_rec.freight_terms_code
	    	,	    g_order_type_rec.ship_from_org_id
	    	,	    g_order_type_rec.agreement_type_code
	    	,	    g_order_type_rec.shipping_method_code
	    	,	    g_order_type_rec.agreement_required_flag
	    	,	    g_order_type_rec.require_po_flag
	    	,	    g_order_type_rec.enforce_line_prices_flag
            ,       g_order_type_rec.auto_scheduling_flag
                -- QUOTING changes
	    	,	    g_order_type_rec.quote_num_as_ord_num_flag
                ,           g_order_type_rec.invoice_source_id
                ,     g_order_type_rec.non_delivery_invoice_source_id
                ,     g_order_type_rec.cust_trx_type_id
		-- added for bug 4200055
	        ,           g_order_type_rec.start_date_active
                ,           g_order_type_rec.end_date_active
		,           g_order_type_rec.tax_calculation_event_code
	    	FROM    OE_ORDER_TYPES_V
	    	WHERE   ORDER_TYPE_ID = p_key;

		END IF;

    END IF;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_ORDER_TYPE', 1);
  end if;

EXCEPTION

      WHEN NO_DATA_FOUND THEN
		   RAISE NO_DATA_FOUND  ;


    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Load_Order_Type'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_Order_Type;

------------------------------------------------------------
-- Bug 1929163: overload load_line_type so that it can be accessed
-- both as a function and as a procedure
------------------------------------------------------------
FUNCTION Load_Line_Type
(   p_key       IN NUMBER )
RETURN Line_Type_Rec_Type
IS
BEGIN

     Load_Line_Type(p_key);

     RETURN g_line_type_rec;

END Load_Line_Type;

PROCEDURE Load_Line_Type
(   p_key	IN NUMBER )
IS
l_calculate_tax_flag varchar2(1) := NULL;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.LOAD_LINE_TYPE', 1);
  end if;

    IF 	p_key IS NOT NULL THEN

  if l_debug_level > 0 then
    oe_debug_pub.add('p_key is not null', 1);
  end if;
		IF 	g_line_type_rec.line_type_id = FND_API.G_MISS_NUM OR
	   		g_line_type_rec.line_type_id <> p_key THEN

  if l_debug_level > 0 then
    oe_debug_pub.add('before selecting line_type info : ' || g_line_type_rec.calculate_tax_flag, 1);
  end if;
	    	SELECT  LINE_TYPE_ID
	    	,         NAME
	    	,         CUST_TRX_TYPE_ID
	    	,	    INVOICING_RULE_ID
	    	,	    ACCOUNTING_RULE_ID
	    	,	    PRICE_LIST_ID
	    	,	    SHIPMENT_PRIORITY_CODE
	    	,	    fob_point_code FOB_POINT_CODE
	    	,	    FREIGHT_TERMS_CODE
	    	,	    warehouse_id SHIP_FROM_ORG_ID
	    	,	    AGREEMENT_TYPE_CODE
	    	,	    shipping_method_code SHIPPING_METHOD_CODE
	    	,	    AGREEMENT_REQUIRED_FLAG
	    	,	    enforce_line_prices_flag
                ,           order_category_code
                ,           ship_source_type_code
                ,           invoice_source_id
                ,           non_delivery_invoice_source_id
		--added for bug 4200055
		,           start_date_active
		,           end_date_active
		,           tax_calculation_event_code
	    	INTO    g_line_type_rec.line_type_id
	    	,       g_line_type_rec.name
	    	,       g_line_type_rec.cust_trx_type_id
	    	,	    g_line_type_rec.invoicing_rule_id
	    	,	    g_line_type_rec.accounting_rule_id
	    	,	    g_line_type_rec.price_list_id
	    	,	    g_line_type_rec.shipment_priority_code
	    	,	    g_line_type_rec.fob_point_code
	    	,	    g_line_type_rec.freight_terms_code
	    	,	    g_line_type_rec.ship_from_org_id
	    	,	    g_line_type_rec.agreement_type_code
	    	,	    g_line_type_rec.shipping_method_code
	    	,	    g_line_type_rec.agreement_required_flag
	    	,	    g_line_type_rec.enforce_line_prices_flag
                ,           g_line_type_rec.order_category_code
                ,           g_line_type_rec.ship_source_type_code
                ,           g_line_type_rec.invoice_source_id
                ,           g_line_type_rec.non_delivery_invoice_source_id
		-- added for bug 4200055
	        ,           g_line_type_rec.start_date_active
	        ,           g_line_type_rec.end_date_active
		,           g_line_type_rec.tax_calculation_event_code
	    	FROM    OE_LINE_TYPES_V
	    	WHERE   LINE_TYPE_ID = p_key;

  if l_debug_level > 0 then
    oe_debug_pub.add('after selecting line_type info : ' || g_line_type_rec.calculate_tax_flag, 1);
  end if;
                IF g_line_type_rec.cust_trx_type_id IS NOT NULL
                THEN

                  SELECT tax_calculation_flag
                  INTO l_calculate_tax_flag
                  FROM RA_CUST_TRX_TYPES
                  WHERE CUST_TRX_TYPE_ID = g_line_type_rec.cust_trx_type_id;

  if l_debug_level > 0 then
    oe_debug_pub.add('after selecting tax_flag info : ' || l_calculate_tax_flag, 1);
  end if;
                END IF;

                g_line_type_rec.calculate_tax_flag := l_calculate_tax_flag;

  if l_debug_level > 0 then
    oe_debug_pub.add('tax_flag  : ' || g_line_type_rec.calculate_tax_flag, 1);
  end if;

		END IF;

    END IF;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_LINE_TYPE', 1);
  end if;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

		 RAISE NO_DATA_FOUND ;

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Load_Line_Type'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Load_Line_Type;


FUNCTION Load_Agreement
(   p_key	IN NUMBER )
RETURN Agreement_Rec_Type
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.LOAD_AGREEMENT', 1);
  end if;

    IF 	p_key IS NOT NULL THEN

		IF 	g_agreement_rec.agreement_id = FND_API.G_MISS_NUM OR
			g_agreement_rec.agreement_id <> p_key THEN

	    	SELECT  AGREEMENT_ID
	    	,	    INVOICING_RULE_ID
	    	,	    ACCOUNTING_RULE_ID
	    	,	    PRICE_LIST_ID
	    	,	    CUST_PO_NUMBER
	    	,	    PAYMENT_TERM_ID
	    	,	    INVOICE_TO_ORG_ID
	    	,	    INVOICE_TO_CONTACT_ID
	    	,	    AGREEMENT_TYPE_CODE
	    	,	    DECODE(SOLD_TO_ORG_ID,-1,NULL,SOLD_TO_ORG_ID)
	    	INTO    g_agreement_rec.agreement_id
	    	,	    g_agreement_rec.invoicing_rule_id
	    	,	    g_agreement_rec.accounting_rule_id
	    	,	    g_agreement_rec.price_list_id
	    	,	    g_agreement_rec.cust_po_number
	    	,	    g_agreement_rec.payment_term_id
	    	,	    g_agreement_rec.invoice_to_org_id
	    	,	    g_agreement_rec.invoice_to_contact_id
	    	,	    g_agreement_rec.agreement_type_code
	    	,	    g_agreement_rec.sold_to_org_id
	    	FROM    OE_AGREEMENTS_V
	    	WHERE   AGREEMENT_ID = p_key;
	    	NULL;

		END IF;

    END IF;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_AGREEMENT', 1);
  end if;

    RETURN g_agreement_rec;

EXCEPTION

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Load_Agreement'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_Agreement;

FUNCTION Load_Ship_To_Org
(   p_key	IN NUMBER )
RETURN Ship_To_Org_Rec_Type
IS
l_bill_to_site_use_id	NUMBER := NULL;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.LOAD_SHIP_TO_ORG', 1);
  end if;

    IF 	p_key IS NOT NULL THEN

		IF 	g_ship_to_rec.org_id = FND_API.G_MISS_NUM OR
           	g_ship_to_rec.org_id <> p_key THEN

	    	SELECT  ORGANIZATION_ID
	    	,	    PRICE_LIST_ID
	    	,	    FOB_POINT_CODE
	    	,	    FREIGHT_TERMS_CODE
	    	,	    SOLD_FROM_ORG_ID
	    	,	    SHIP_FROM_ORG_ID
	    	,	    CONTACT_ID
	    	,	    SHIP_PARTIAL_ALLOWED
	    	,	    SHIPPING_METHOD_CODE
	    	,	    BILL_TO_SITE_USE_ID
	    	INTO    g_ship_to_rec.org_id
	    	,	    g_ship_to_rec.price_list_id
	    	,	    g_ship_to_rec.fob_point_code
	    	,	    g_ship_to_rec.freight_terms_code
	    	,	    g_ship_to_rec.sold_from_org_id
	    	,	    g_ship_to_rec.ship_from_org_id
	    	,	    g_ship_to_rec.contact_id
	    	,	    g_ship_to_rec.ship_partial_allowed
	    	,	    g_ship_to_rec.shipping_method_code
	    	,	    l_bill_to_site_use_id
	    	FROM    OE_SHIP_TO_ORGS_V
	    	WHERE   ORGANIZATION_ID = p_key;

	    --  Fetch Invoice to org id.

	    	IF 	l_bill_to_site_use_id IS NOT NULL THEN

	    		BEGIN

					SELECT	ORGANIZATION_ID
					INTO	g_ship_to_rec.invoice_to_org_id
					FROM	OE_INVOICE_TO_ORGS_V
					WHERE	SITE_USE_ID = l_bill_to_site_use_id;

	    		EXCEPTION

					WHEN NO_DATA_FOUND THEN
-- Kris - is this right??
		   		 	g_ship_to_rec.invoice_to_org_id := NULL;

					WHEN OTHERS THEN

		    			IF OE_MSG_PUB.Check_Msg_Level
							(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		    			THEN
							OE_MSG_PUB.Add_Exc_Msg
							(   G_PKG_NAME
							,   'Load_Ship_To_Org - Fetch Bill to Site'
							);
		    			END IF;

		    			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	    		END;  -- Fetching Bill To Site

	    	END IF;

	    --	Fetch payment term

	    	BEGIN

				SELECT  STANDARD_TERMS
				INTO    g_ship_to_rec.payment_term_id
				FROM    HZ_CUSTOMER_PROFILES
				WHERE   SITE_USE_ID = p_key;

	    	EXCEPTION

				WHEN NO_DATA_FOUND THEN

		    		g_ship_to_rec.payment_term_id := NULL;

				WHEN OTHERS THEN

		    		IF OE_MSG_PUB.Check_Msg_Level
						(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		    		THEN
						OE_MSG_PUB.Add_Exc_Msg
						(   G_PKG_NAME
						,   'Load_Ship_To_Org - Fetch Payment Terms'
						);
		    		END IF;

		    		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	    	END; -- Begin fetching payment terms.

		END IF;

    END IF;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_SHIP_TO_ORG', 1);
  end if;

    RETURN g_ship_to_rec;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	RAISE;

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Load_Ship_To_Org'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_Ship_To_Org;

FUNCTION Load_Invoice_To_Org
(   p_key	IN NUMBER )
RETURN Invoice_to_Org_Rec_Type
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.LOAD_INVOICE_TO_ORG', 1);
  end if;

    IF 	p_key IS NOT NULL THEN

		IF 	g_invoice_to_rec.org_id = FND_API.G_MISS_NUM OR
       		g_invoice_to_rec.org_id <> p_key THEN

	    	oe_debug_pub.add('Loading Invoice to Org Cache');
                SELECT  ORGANIZATION_ID
	    	,	    PRICE_LIST_ID
	    	,	    FOB_POINT_CODE
	    	,	    FREIGHT_TERMS_CODE
	    	,	    CONTACT_ID
	    	,	    SHIP_PARTIAL_ALLOWED
	    	,	    SHIPPING_METHOD_CODE
                 --added for bug 4200055
                ,           STATUS
                ,           ADDRESS_STATUS
                ,           START_DATE_ACTIVE
                ,           END_DATE_ACTIVE
	    	INTO    g_invoice_to_rec.org_id
	    	,	    g_invoice_to_rec.price_list_id
	    	,	    g_invoice_to_rec.fob_point_code
	    	,	    g_invoice_to_rec.freight_terms_code
	    	,	    g_invoice_to_rec.contact_id
	    	,	    g_invoice_to_rec.ship_partial_allowed
	    	,	    g_invoice_to_rec.shipping_method_code
                 --added for bug 4200055
                ,           g_invoice_to_rec.status
                ,           g_invoice_to_rec.address_status
                ,           g_invoice_to_rec.start_date_active
                ,           g_invoice_to_rec.end_date_active
	    	FROM    OE_INVOICE_TO_ORGS_V
	    	WHERE   ORGANIZATION_ID = p_key;

	    --	Fetch payment term

	    	BEGIN

				SELECT  STANDARD_TERMS
				INTO    g_invoice_to_rec.payment_term_id
				FROM    HZ_CUSTOMER_PROFILES
				WHERE   SITE_USE_ID = p_key;

	    	EXCEPTION

				WHEN NO_DATA_FOUND THEN

		    		g_invoice_to_rec.payment_term_id := NULL;

				WHEN OTHERS THEN

		    		IF OE_MSG_PUB.Check_Msg_Level
						(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		    		THEN
						OE_MSG_PUB.Add_Exc_Msg
						(   G_PKG_NAME
						,   'Load_Invoice_To_Org - Fetch Payment Terms'
						);
		    		END IF;

		    		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	    	END; -- Begin fetching payment terms.

		END IF;

    END IF;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_INVOICE_TO_ORG', 1);
  end if;

    RETURN g_invoice_to_rec;

EXCEPTION
    WHEN NO_DATA_FOUND THEN

           RAISE NO_DATA_FOUND  ;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	RAISE;

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Load_Invoice_To_Org'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_Invoice_To_Org;

FUNCTION Load_Deliver_To_Org
(   p_key	IN NUMBER )
RETURN Deliver_To_Org_Rec_Type
IS
	l_bill_to_site_use_id	NUMBER := NULL;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.LOAD_DELIVER_TO_ORG', 1);
  end if;

    IF 	p_key IS NOT NULL THEN

		IF 	g_deliver_to_rec.org_id = FND_API.G_MISS_NUM OR
        	g_deliver_to_rec.org_id <> p_key THEN

	    	SELECT  ORGANIZATION_ID
	    	,	    PRICE_LIST_ID
	    	,	    FOB_POINT_CODE
	    	,	    FREIGHT_TERMS_CODE
	    	,	    SOLD_FROM_ORG_ID
	    	,	    SHIP_FROM_ORG_ID
	    	,	    CONTACT_ID
	    	,	    SHIP_PARTIAL_ALLOWED
	    	,	    SHIPPING_METHOD_CODE
	    	,	    BILL_TO_SITE_USE_ID
	    	INTO    g_deliver_to_rec.org_id
	    	,	    g_deliver_to_rec.price_list_id
	    	,	    g_deliver_to_rec.fob_point_code
	    	,	    g_deliver_to_rec.freight_terms_code
	    	,	    g_deliver_to_rec.sold_from_org_id
	    	,	    g_deliver_to_rec.ship_from_org_id
	    	,	    g_deliver_to_rec.contact_id
	    	,	    g_deliver_to_rec.ship_partial_allowed
	    	,	    g_deliver_to_rec.shipping_method_code
	    	,	    l_bill_to_site_use_id
	    	FROM    OE_DELIVER_TO_ORGS_V
	    	WHERE   ORGANIZATION_ID = p_key;

	    --  Fetch Invoice to org id.

	    	IF l_bill_to_site_use_id IS NOT NULL THEN

				SELECT	ORGANIZATION_ID
				INTO	g_deliver_to_rec.invoice_to_org_id
				FROM	OE_INVOICE_TO_ORGS_V
				WHERE	SITE_USE_ID = l_bill_to_site_use_id;

	    	END IF;

		END IF;

    END IF;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_DELIVER_TO_ORG', 1);
  end if;

    RETURN g_deliver_to_rec;

EXCEPTION

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Load_Deliver_To_Org'
	    );
    	END IF;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_Deliver_To_Org;

FUNCTION Load_Sold_To_Org
(   p_key	IN NUMBER )
RETURN Sold_To_Org_Rec_Type
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_current_org_id NUMBER ;  -- MOAC Changes
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.LOAD_SOLD_TO_ORG', 1);
  end if;
    --MOAC Changes
    --The Sold_To_Org_Cache was selecting  oe_sold_to_orgs_v.organization_id into g_sold_to_rec.org_id.
    --To have a code consistency added a new column "sold_to_org_id" in "Sold_To_Org_Rec_Type".
    --Now oe_sold_to_orgs_v.organization_id is selected into g_sold_to_rec.sold_to_org_id and
    --the OU in g_sold_to_rec.org_id

    l_current_org_id := MO_Global.Get_Current_Org_Id() ;

    IF 	p_key IS NOT NULL THEN

		IF g_sold_to_rec.sold_to_org_id = FND_API.G_MISS_NUM OR
        	   g_sold_to_rec.sold_to_org_id <> p_key OR
		   g_sold_to_rec.org_id <> l_current_org_id THEN

	    	SELECT  ORGANIZATION_ID
	    	,	    PRICE_LIST_ID
	    	,	    FOB_POINT_CODE
	    	,	    FREIGHT_TERMS_CODE
	    	,	    SHIP_PARTIAL_ALLOWED
	    	,	    SHIPPING_METHOD_CODE
	    	,	    ORDER_TYPE_ID
	    	INTO    g_sold_to_rec.sold_to_org_id  --MOAC Changes
	    	,	    g_sold_to_rec.price_list_id
	    	,	    g_sold_to_rec.fob_point_code
	    	,	    g_sold_to_rec.freight_terms_code
	    	,	    g_sold_to_rec.ship_partial_allowed
	    	,	    g_sold_to_rec.shipping_method_code
	    	,	    g_sold_to_rec.order_type_id
	    	FROM    OE_SOLD_TO_ORGS_V
	    	WHERE   ORGANIZATION_ID = p_key;

		 g_sold_to_rec.org_id := l_current_org_id ; -- MOAC Changes

	    --  Fetch Invoice to org.

	    	BEGIN

				SELECT /*MOAC_SQL_CHANGES*/ INV.ORGANIZATION_ID
				INTO    g_sold_to_rec.invoice_to_org_id
				FROM    OE_INVOICE_TO_ORGS_V	INV
					,HZ_CUST_ACCT_SITES_ALL	ADDR
				WHERE   ADDR.CUST_ACCOUNT_ID = p_key
				AND	    ADDR.BILL_TO_FLAG = 'P'
				AND	    ADDR.STATUS = 'A'
				AND	    INV.ADDRESS_ID = ADDR.CUST_ACCT_SITE_ID
	        	AND	    INV.PRIMARY_FLAG = 'Y'
				AND	    INV.STATUS = 'A' and inv.org_id=addr.org_id
				 and INV.address_status='A'; --2752321

	    	EXCEPTION

				WHEN NO_DATA_FOUND THEN

		    		g_sold_to_rec.invoice_to_org_id := NULL;

				WHEN OTHERS THEN

		    		IF OE_MSG_PUB.Check_Msg_Level
						(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		    		THEN
						OE_MSG_PUB.Add_Exc_Msg
						(   G_PKG_NAME
						,   'Load_Sold_To_Org - Fetch Invoice To'
						);
		    		END IF;

		    		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	    	END; -- Begin fetching Invoice to.

	    --  Fetch Ship to org.

	    	BEGIN

				SELECT /*MOAC_SQL_CHANGES*/ SHIP.ORGANIZATION_ID
				INTO    g_sold_to_rec.ship_to_org_id
				FROM    OE_SHIP_TO_ORGS_V		SHIP
				,       HZ_CUST_ACCT_SITES_ALL		ADDR
				WHERE   ADDR.CUST_ACCOUNT_ID = p_key
				AND	ADDR.SHIP_TO_FLAG = 'P'
	        	AND	ADDR.STATUS = 'A'
				AND	SHIP.ADDRESS_ID = ADDR.CUST_ACCT_SITE_ID
				AND	SHIP.PRIMARY_FLAG = 'Y'
	        	AND	SHIP.STATUS = 'A' and ship.org_id=addr.org_id
			        and ship.address_status='A'; --2752321

	    	EXCEPTION

				WHEN NO_DATA_FOUND THEN

		    		g_sold_to_rec.ship_to_org_id := NULL;

				WHEN OTHERS THEN

		    		IF OE_MSG_PUB.Check_Msg_Level
						(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		    		THEN
						OE_MSG_PUB.Add_Exc_Msg
						(   G_PKG_NAME
						,   'Load_Sold_To_Org - Fetch Ship To'
						);
		    		END IF;

		    		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	    	END; -- Begin fetching Ship to.

	    --	Fetch Deliver to org

	    	BEGIN

				SELECT /*MOAC_SQL_CHANGES*/ DEL.ORGANIZATION_ID
				INTO    g_sold_to_rec.deliver_to_org_id
				FROM    OE_DELIVER_TO_ORGS_V	DEL
					,HZ_CUST_ACCT_SITES_ALL		ADDR
				WHERE   ADDR.CUST_ACCOUNT_ID = p_key
				AND		ADDR.SHIP_TO_FLAG = 'P'
	        	AND		ADDR.STATUS = 'A'
				AND     DEL.ADDRESS_ID = ADDR.CUST_ACCT_SITE_ID
				AND     DEL.PRIMARY_FLAG = 'Y' and del.organization_id=addr.org_id
	        	AND     DEL.STATUS = 'A'
			 and DEL.address_status='A'; --2752321

	    	EXCEPTION

				WHEN NO_DATA_FOUND THEN

		    		g_sold_to_rec.deliver_to_org_id := NULL;

				WHEN OTHERS THEN

		    		IF OE_MSG_PUB.Check_Msg_Level
						(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		    		THEN
						OE_MSG_PUB.Add_Exc_Msg
						(   G_PKG_NAME
						,   'Load_Sold_To_Org - Fetch Deliver To'
						);
		    		END IF;

		    		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	    	END; -- Begin fetching Deliver to.

	    --	Fetch payment term

	    	BEGIN

				SELECT  STANDARD_TERMS
				INTO    g_sold_to_rec.payment_term_id
				FROM    HZ_CUSTOMER_PROFILES
				WHERE   CUST_ACCOUNT_ID = p_key
		  		AND   SITE_USE_ID IS NULL;

	    	EXCEPTION

				WHEN NO_DATA_FOUND THEN

		    		g_sold_to_rec.payment_term_id := NULL;

				WHEN OTHERS THEN

		    		IF OE_MSG_PUB.Check_Msg_Level
						(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		    		THEN
						OE_MSG_PUB.Add_Exc_Msg
						(   G_PKG_NAME
						,   'Load_Sold_To_Org - Fetch Payment Term'
						);
		    		END IF;

		    		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	    	END; -- Begin fetching Payment Term.

		END IF;

    END IF;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_SOLD_TO_ORG', 1);
  end if;

    RETURN g_sold_to_rec;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	RAISE;

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Load_Sold_To_Org'
	    );
    	END IF;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_Sold_To_Org;

FUNCTION Load_Price_List
(   p_key	IN NUMBER )
RETURN Price_List_Rec_Type
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.LOAD_PRICE_LIST', 1);
  end if;
    IF 	p_key IS NOT NULL THEN

		IF 	g_price_list_rec.price_list_id = FND_API.G_MISS_NUM OR
        	g_price_list_rec.price_list_id <> p_key THEN

	    	SELECT  list_header_id
--	    	,	    PAYMENT_TERM_ID
	    	,	    TERMS_ID
	    	,	    SHIP_METHOD_CODE
	    	,	    FREIGHT_TERMS_CODE
	    	,	    CURRENCY_CODE
		-- added for bug 4200055
		, 	    NAME
		,	    LIST_TYPE_CODE
		,	    ACTIVE_FLAG
		,	    START_DATE_ACTIVE
		,	    END_DATE_ACTIVE
	    	INTO    g_price_list_rec.price_list_id
	    	,	    g_price_list_rec.payment_term_id
	    	,	    g_price_list_rec.ship_method_code
	    	,	    g_price_list_rec.freight_terms_code
	    	,	    g_price_list_rec.currency_code
		--added for bug 4200055
		,	    g_price_list_rec.name
		,           g_price_list_rec.list_type_code
		,           g_price_list_rec.active_flag
		,           g_price_list_rec.start_date_active
		,           g_price_list_rec.end_date_active
	    --	FROM    qp_list_headers_b
	        FROM    qp_list_headers_vl
	    	WHERE   list_header_id = p_key
			and list_type_code in ('PRL', 'AGR');

		END IF;

    END IF;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_PRICE_LIST', 1);
  end if;

    RETURN g_price_list_rec;

EXCEPTION
    WHEN NO_DATA_FOUND THEN

	   RAISE NO_DATA_FOUND  ;

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Load_Price_List'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_Price_List;

FUNCTION Load_Set_Of_Books
RETURN Set_Of_Books_Rec_Type
IS
	l_set_of_books_id   NUMBER := NULL;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.LOAD_SET_OF_BOOKS', 1);
  end if;

    --	Get set_of_books_id from profile option.

    --l_set_of_books_id := FND_PROFILE.VALUE('OE_SET_OF_BOOKS_ID');
	l_set_of_books_id := OE_Sys_Parameters.VALUE('SET_OF_BOOKS_ID');


    IF 	l_set_of_books_id IS NOT NULL THEN

                -- Fix Bug 1910409: if operating unit changes, l_set_of_books
                -- would change therefore compare cached set of books to
                -- l_set_of_books and re-set the cache if changed.
		IF 	g_set_of_books_rec.set_of_books_id = FND_API.G_MISS_NUM
                        OR (l_set_of_books_id <> g_set_of_books_rec.set_of_books_id)
                THEN

	    	SELECT  SET_OF_BOOKS_ID
	    	,	    CURRENCY_CODE
	    	INTO    g_set_of_books_rec.set_of_books_id
	    	,	    g_set_of_books_rec.currency_code
	    	FROM    OE_GL_SETS_OF_BOOKS_V
	    	WHERE   SET_OF_BOOKS_ID = l_set_of_books_id;

		END IF;

    END IF;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_SET_OF_BOOKS', 1);
  end if;

    RETURN g_set_of_books_rec;

EXCEPTION

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Load_Set_Of_Books'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_Set_Of_Books;


FUNCTION Load_Item_Cost
(   p_key1	IN NUMBER
,   p_key2	IN NUMBER )
RETURN Item_Cost_Rec_Type
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.LOAD_ITEM_COST', 1);
  end if;

    IF 	p_key1 IS NOT NULL THEN

		IF 	g_item_cost_rec.inventory_item_id = FND_API.G_MISS_NUM OR
        	g_item_cost_rec.inventory_item_id <> p_key1 THEN

	    	SELECT  INVENTORY_ITEM_ID
	    	,	    ORGANIZATION_ID
	    	,	    MATERIAL_COST
	    	,	    MATERIAL_OVERHEAD_COST
	    	,	    RESOURCE_COST
	    	,	    OUTSIDE_PROCESSING_COST
            ,       OVERHEAD_COST
	    	INTO    g_item_cost_rec.inventory_item_id
	    	,	    g_item_cost_rec.organization_id
	    	,	    g_item_cost_rec.material_cost
	    	,	    g_item_cost_rec.material_overhead_cost
	    	,	    g_item_cost_rec.resource_cost
            ,       g_item_cost_rec.outside_processing_cost
            ,       g_item_cost_rec.overhead_cost
	    	FROM    CST_ITEM_COSTS
	    	WHERE   INVENTORY_ITEM_ID = p_key1
	    	AND	    ORGANIZATION_ID = p_key2;

		END IF;

    END IF;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_ITEM_COST', 1);
  end if;

    RETURN g_item_cost_rec;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
		RETURN g_item_cost_rec;

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Load_Item_Cost'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_Item_Cost;


------------------------------------------------------------
-- Bug 1929163: overload load_order_header so that it can
-- be accessed both as a function and as a procedure
------------------------------------------------------------
FUNCTION Load_Order_Header
(   p_key	IN NUMBER )
RETURN OE_Order_PUB.Header_Rec_Type
IS
BEGIN

    Load_Order_Header(p_key);

    RETURN OE_ORDER_CACHE.g_header_rec;

END Load_Order_Header;

PROCEDURE Load_Order_Header
(   p_key	IN NUMBER )
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.LOAD_ORDER_HEADER', 1);
  end if;

    IF 	p_key IS NOT NULL THEN

		IF 	g_header_rec.header_id = FND_API.G_MISS_NUM OR
        	     nvl(g_header_rec.header_id,0) <> p_key THEN

	    	 OE_HEADER_UTIL.Query_Row(p_header_id => p_key,
							 x_header_rec =>  g_header_rec);

		END IF;

    END IF;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_ORDER_HEADER', 1);
  end if;

--add bug 4200055
EXCEPTION

    WHEN NO_DATA_FOUND THEN

	   RAISE NO_DATA_FOUND;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Load_Order_Header'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_Order_Header;


FUNCTION load_header_discount
( p_hdr_adj_rec	IN oe_order_pub.header_adj_rec_type)
RETURN OE_ORDER_PUB.Header_ADJ_REC_TYPE
IS
	l_header_adj_rec		OE_ORDER_PUB.header_adj_rec_type;
	l_discount_id			NUMBER := p_hdr_adj_rec.discount_id;
	l_discount_line_id		NUMBER := p_hdr_adj_rec.discount_line_id;
	l_adj_id				NUMBER := p_hdr_adj_rec.price_adjustment_id;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
   oe_debug_pub.add('Entering OE_ORDER_CACHE.LOAD_HEADER_DISCOUNT', 1);
  end if;

   IF 	(l_adj_id IS NOT NULL) THEN

		IF 	(g_hdr_discount_rec.price_adjustment_id <> l_adj_id
	  		OR g_hdr_discount_rec.discount_id <> l_discount_id
	  		OR g_hdr_discount_rec.discount_line_id <> l_discount_line_id)
		THEN

	 --oe_debug_pub.add('Load_header_discount. Discount_id = ' ||
	 --		  To_char(l_discount_id) ||
	 --		  ' discount_line_id = ' ||
	 --		  To_char(l_discount_line_id), 2);

	 -- The discount is uniquely identified by discount_line
	 		IF l_discount_line_id <> -1
	   		THEN

	    		SELECT 	NVL( Nvl(sodsc.percent, sodls.percent), 0),
	           			sodsc.discount_id,
	           			NVL(sodls.discount_line_id, -1),
	           			sodsc.name,
	           			l_adj_id
	      		INTO 	g_hdr_discount_rec.percent,
	           			g_hdr_discount_rec.discount_id,
	           			g_hdr_discount_rec.discount_line_id,
	           			g_hdr_discount_rec.adjustment_name,
	           			g_hdr_discount_rec.price_adjustment_id
	      		FROM 	oe_discounts sodsc,
	           			oe_discount_lines sodls
	      		WHERE 	sodls.discount_line_id = l_discount_line_id
	      		AND   	sodls.discount_id = sodsc.discount_id;


	  -- discount is uniquely identified by discount
	  		ELSE

	    		SELECT  	Nvl(sodsc.percent, 0),
	            			sodsc.discount_id,
	            			-1,
	            			sodsc.name,
	            			l_adj_id
	      		INTO  		g_hdr_discount_rec.percent,
	            			g_hdr_discount_rec.discount_id,
	            			g_hdr_discount_rec.discount_line_id,
	            			g_hdr_discount_rec.adjustment_name,
	            			g_hdr_discount_rec.price_adjustment_id
	      		FROM  		oe_discounts sodsc
	      		WHERE 		l_discount_id = sodsc.discount_id;

	 		END IF;

      	END IF;

      -- Write the values to the header adj_record
      	l_header_adj_rec.percent		:= g_hdr_discount_rec.percent;
      	l_header_adj_rec.discount_id	:= g_hdr_discount_rec.discount_id;
      	l_header_adj_rec.discount_line_id	:= g_hdr_discount_rec.discount_line_id;
   END IF;

  if l_debug_level > 0 then
   oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_HEADER_DISCOUNT', 1);
  end if;

   RETURN l_header_adj_rec;

EXCEPTION

   WHEN OTHERS THEN

      IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 OE_MSG_PUB.Add_Exc_Msg
	   (	G_PKG_NAME  	    ,
    	        'Load_header_discount'
	    );
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END load_header_discount;



FUNCTION load_line_discount
( p_line_adj_rec	IN oe_order_pub.line_adj_rec_type)
RETURN OE_ORDER_PUB.Line_adj_REC_TYPE
IS
	l_line_adj_rec		OE_ORDER_PUB.Line_adj_rec_type;
	l_discount_id		NUMBER := p_line_adj_rec.discount_id;
	l_discount_line_id	NUMBER := p_line_adj_rec.discount_line_id;
	l_line_id			NUMBER := p_line_adj_rec.line_id;
	l_adj_id			NUMBER := p_line_adj_rec.price_adjustment_id;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
	oe_debug_pub.add('Entering OE_ORDER_CACHE.LOAD_LINE_DISCOUNT', 1);
  end if;

	IF (l_adj_id IS NOT NULL) THEN

		IF (g_line_discount_rec.price_adjustment_id <> l_adj_id
		OR g_line_discount_rec.discount_line_id <> l_discount_line_id
		OR g_line_discount_rec.discount_id <> l_discount_id)
		THEN

--	 oe_debug_pub.add('OEXUCCHB Before Load_line. Discount_id = ' ||
--	 		  To_char(l_discount_id) ||
--	 		  ' discount_line_id = ' ||
--	 		  To_char(l_discount_line_id) ||
--	 		  ' line_id = ' ||
--	 		  To_char(l_line_id) ||
--			  ' percent = ' ||
--			  To_char(l_line_adj_rec.percent), 2);

	 -- The discount is based on a discount_line
		IF l_discount_line_id <> -1
		THEN

	    	SELECT 	(nvl(sodsc.amount / oeorln.UNIT_LIST_PRICE * 100,
		   			nvl(sodsc.percent,
		       		nvl((oeorln.UNIT_LIST_PRICE - sodls.price ) /
			   		oeorln.UNIT_LIST_PRICE * 100,
			 		nvl(sodls.amount / oeorln.UNIT_LIST_PRICE * 100,
			   		nvl(sodls.percent,
			     	nvl((oeorln.UNIT_LIST_PRICE - sopbl.price ) /
				 	oeorln.UNIT_LIST_PRICE * 100,
			      	nvl(sopbl.amount / oeorln.UNIT_LIST_PRICE * 100,
					nvl( sopbl.percent, 0 ))))))))),
	           		sodsc.discount_id,
	           		Nvl(sodls.discount_line_id, -1),
	           		sodsc.name,
	           		l_adj_id
	      	INTO 	g_line_discount_rec.percent,
	           		g_line_discount_rec.discount_id,
	           		g_line_discount_rec.discount_line_id,
	           		g_line_discount_rec.adjustment_name,
	           		g_line_discount_rec.price_adjustment_id
	      	FROM 	oe_discounts sodsc,
	           		oe_discount_lines sodls,
	           		oe_price_break_lines sopbl,
	           		oe_order_lines oeorln
	      	WHERE 	sodls.discount_line_id = l_discount_line_id
	      	AND   	sodls.discount_id = sodsc.discount_id
	      	AND   	sopbl.discount_line_id(+) = sodls.discount_line_id
	      	AND   	oeorln.line_id = l_line_id;

	  -- The discount is based on a discount
	  	ELSE

	    	SELECT 	Nvl(nvl(sodsc.amount / oeorln.UNIT_LIST_PRICE * 100,
		       		sodsc.percent), 0),
	           		sodsc.discount_id,
	           		-1,
	           		sodsc.name,
	           		l_adj_id
	      	INTO 	g_line_discount_rec.percent,
	           		g_line_discount_rec.discount_id,
	           		g_line_discount_rec.discount_line_id,
	           		g_line_discount_rec.adjustment_name,
	           		g_line_discount_rec.price_adjustment_id
	      	FROM 	oe_discounts sodsc,
	           		oe_order_lines oeorln
	      	WHERE 	sodsc.discount_id = l_discount_id
	      	AND   	oeorln.line_id = l_line_id;

	 	END IF;

	END IF;

      -- Write the values to the line adj_record
	l_line_adj_rec.discount_id	:= g_line_discount_rec.discount_id;
	l_line_adj_rec.discount_line_id	:= g_line_discount_rec.discount_line_id;
	l_line_adj_rec.percent		:= g_line_discount_rec.percent;

--      	 oe_debug_pub.add('OEXUCCHB After load_line. Discount_id = ' ||
--	 		  To_char(l_line_adj_rec.discount_id) ||
--	 		  ' discount_line_id = ' ||
--	 		  To_char(l_discount_line_id) ||
--	 		  ' line_id = ' ||
--	 		  To_char(l_line_id) ||
--			  ' percent = ' ||
--			  To_char(l_line_adj_rec.percent), 2);

	END IF;

  if l_debug_level > 0 then
	oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_LINE_DISCOUNT', 1);
  end if;
	RETURN l_line_adj_rec;

EXCEPTION

	WHEN OTHERS THEN

		IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			OE_MSG_PUB.Add_Exc_Msg
	   		(	G_PKG_NAME  	    ,
         	'Load_Line_Discount'
	    	);
		END IF;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END load_line_discount;

------------------------------------------------------------
-- Bug 1929163: overload load_top_model_line so that it can be accessed
-- both as a function and as a procedure
------------------------------------------------------------
FUNCTION Load_Top_Model_Line
(   p_key       IN NUMBER )
RETURN OE_ORDER_PUB.Line_Rec_Type
IS
BEGIN

    Load_Top_Model_Line(p_key);

    RETURN OE_ORDER_CACHE.g_top_model_line_rec;

END Load_Top_Model_Line;

PROCEDURE Load_Top_Model_Line
(   p_key	IN NUMBER )
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.LOAD_TOP_MODEL_LINE', 1);
  end if;
    IF 	p_key IS NOT NULL THEN

      	IF 	nvl(g_top_model_line_rec.line_id,0) <> p_key
      	THEN
              if l_debug_level > 0 then
         	oe_debug_pub.add('no cached model record', 3);
              end if;
         	 OE_Line_Util.Query_Row(p_line_id => p_key,
		      				x_line_rec => g_top_model_line_rec);
      	ELSE
              if l_debug_level > 0 then
         	oe_debug_pub.add('returning cached model record: '|| p_key, 3);
              end if;
      	END IF;

      if l_debug_level > 0 then
      	oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_TOP_MODEL_LINE', 3);
      end if;

    END IF;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_TOP_MODEL_LINE', 1);
  end if;

-- add bug 4200055
EXCEPTION

    WHEN NO_DATA_FOUND THEN

	   RAISE NO_DATA_FOUND;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Load_Top_Model_Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_Top_Model_Line;

------------------------------------------------------------
-- Bug 1929163: overload load_item so that it can be accessed
-- both as a function and as a procedure
------------------------------------------------------------
FUNCTION Load_Item
(   p_key1	IN NUMBER
,   p_key2	IN NUMBER := FND_API.G_MISS_NUM
,   p_key3      IN NUMBER DEFAULT NULL
 )
RETURN Item_Rec_Type
IS
BEGIN

      Load_Item(p_key1, p_key2,p_key3);

      RETURN g_item_rec;

END Load_Item;

PROCEDURE Load_Item
(   p_key1	IN NUMBER
,   p_key2	IN NUMBER := FND_API.G_MISS_NUM
,   p_key3      IN NUMBER DEFAULT NULL
 )
IS
	l_key2	NUMBER;
      --INVCONV start --OPM 02/JUN/00 BEGIN
     --===================
/*     CURSOR c_opm_item ( discrete_org_id  IN NUMBER
                       , discrete_item_id IN NUMBER) IS
       SELECT item_id
            , item_um
            , item_um2
            , dualum_ind
            , grade_ctl
       FROM  ic_item_mst
       WHERE delete_mark = 0
       AND   item_no in (SELECT segment1
         	FROM mtl_system_items
     	WHERE organization_id   = discrete_org_id
          AND   inventory_item_id = discrete_item_id);
     --OPM 02/JUN/00 END
     --=================
*/
--INVCONV end


	l_inventory_changed VARCHAR2(1) := 'N';
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.Load_Item'||p_key3, 1);
  end if;

    -- Always store validation_org in l_key2.
    l_key2 := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID',p_key3);

  if l_debug_level > 0 then
    OE_DEBUG_PUB.ADD('p_key1 is' || p_key1, 3);
    OE_DEBUG_PUB.ADD('prev item: ' || g_item_rec.inventory_item_id, 3);
    OE_DEBUG_PUB.ADD('l_key2 (Master organizion_id) is' || l_key2, 3);
    OE_DEBUG_PUB.ADD('p_key2 (ship_from_org_id) is' || p_key2, 3);
  end if;

    IF 	p_key1 IS NOT NULL THEN

		IF 	g_item_rec.inventory_item_id = FND_API.G_MISS_NUM OR
           	g_item_rec.inventory_item_id <> p_key1 THEN

          if l_debug_level > 0 then
            OE_DEBUG_PUB.ADD('querying item from mtl_system_items', 3);
          end if;

	    /* Always load values based on the validation org
	    for the below attributes. In future please add here for the columns
	    which need to get loaded based on validation org */
	    /* Shippable_item_flag will be loaded into cache here and
	    later the same will be reloaded based on the ship_from_org_id.
	    This is because shippable_flag_item need to be loaded based on
	    the validation_org if ship_from_org is null*/

	    	SELECT  INVENTORY_ITEM_ID
	    	       ,ORGANIZATION_ID
	    	       ,INVOICING_RULE_ID
	    	       ,ACCOUNTING_RULE_ID
	     	  ,DEFAULT_SHIPPING_ORG
                 ,SHIP_MODEL_COMPLETE_FLAG
                 ,BUILD_IN_WIP_FLAG
                 ,BOM_ITEM_TYPE
                 ,REPLENISH_TO_ORDER_FLAG
	    	       ,PRIMARY_UOM_CODE
                 ,PICK_COMPONENTS_FLAG
                 ,SHIPPABLE_ITEM_FLAG
                 ,SERVICE_ITEM_FLAG
                -- Pack J catchweight
                   ,ONT_PRICING_QTY_SOURCE -- INVCONV
                 ,TRACKING_QUANTITY_IND
                 ,SECONDARY_UOM_CODE
		-- bug 4171642 FP
                 ,ORGANIZATION_ID
                 ,CUSTOMER_ORDER_ENABLED_FLAG
                 ,INTERNAL_ORDER_ENABLED_FLAG
                 ,RETURNABLE_FLAG
                 ,RESTRICT_SUBINVENTORIES_CODE
		-- bug 4171642
                 -- INVCONV start
                 ,SECONDARY_DEFAULT_IND
                 ,LOT_DIVISIBLE_FLAG
                 ,GRADE_CONTROL_FLAG,
                 LOT_CONTROL_CODE
	    	INTO    g_item_rec.inventory_item_id
	    	       ,g_item_rec.organization_id
	    	       ,g_item_rec.invoicing_rule_id
	    	       ,g_item_rec.accounting_rule_id
	    	       ,g_item_rec.default_shipping_org
                 ,g_item_rec.ship_model_complete_flag
                 ,g_item_rec.build_in_wip_flag
	    	       ,g_item_rec.bom_item_type
                 ,g_item_rec.replenish_to_order_flag
	    	       ,g_item_rec.primary_uom_code
                 ,g_item_rec.pick_components_flag
                 ,g_item_rec.shippable_item_flag
                 ,g_item_rec.service_item_flag
                -- Pack J catchweight
                 ,g_item_rec.ont_pricing_qty_source
                 ,g_item_rec.tracking_quantity_ind
                 ,g_item_rec.secondary_uom_code
		-- 4171642 FP
                 ,g_item_rec.master_org_id
                 ,g_item_rec.customer_order_enabled_flag
                 ,g_item_rec.internal_order_enabled_flag
                 ,g_item_rec.returnable_flag
                 ,g_item_rec.restrict_subinventories_code
		-- 4171642
                      -- INVCONV start
                 ,g_item_rec.secondary_default_ind
                 ,g_item_rec.lot_divisible_flag
                 ,g_item_rec.grade_control_flag
                 ,g_item_rec.lot_control_code
	    	FROM   MTL_SYSTEM_ITEMS
	    	WHERE  INVENTORY_ITEM_ID = p_key1
	    	AND	    ORGANIZATION_ID = l_key2;

          -- Since inventory is change, load shippable_item_flag.
	     l_inventory_changed  := 'Y';
	-- INVCONV start remove opm
	     -- OPM 02/JUN/00 - OPM item master characteristics
/*
          IF NVL(FND_PROFILE.VALUE('ONT_PROCESS_INSTALLED_FLAG'),'Y')
							                      <> 'N' THEN
            IF INV_GMI_RSV_BRANCH.G_PROCESS_INV_INSTALLED = 'I' THEN
              OPEN c_opm_item( l_key2
                             , p_key1);
               FETCH c_opm_item
                INTO g_item_rec.opm_item_id
	               ,g_item_rec.opm_item_um
	               ,g_item_rec.opm_item_um2
	               ,g_item_rec.dualum_ind
	               ,g_item_rec.grade_ctl;

               IF c_opm_item%NOTFOUND THEN
	 -- 		OPM 30/JUN/00 Fully clear the process cache
                g_item_rec.opm_item_id  := NULL;
	           g_item_rec.opm_item_um  := NULL;
	           g_item_rec.opm_item_um2 := NULL;
                g_item_rec.dualum_ind   := NULL;
	           g_item_rec.grade_ctl    := NULL;
               END IF;

          -- Moved this code from here inside the if INV_GMI_RSV_BRANCH.Is_Org_Process_Org(p_key2) THEN, because it was overriding the
          -- value of ont_pricing_qty_source for catchweight item
             --  g_item_rec.ont_pricing_qty_source := GML_READ_IC_B.read_price_qty_source(p_key1, l_key2); -- 2044240
              -- OE_DEBUG_PUB.ADD('OPM ont_pricing_qty_source after read ic_item_mst_b = ' || g_item_rec.ont_pricing_qty_source, 5);


            END IF;    -- end of IF NVL(FND_PROFILE.VALUE('ONT_PROCESS_INSTALLED_FLAG'),'Y')
          END IF; -- IF INV_GMI_RSV_BRANCH.G_PROCESS_INV_INSTALLED = 'I


*/
-- INVCONV end


	     /* OPM 02/JUN/00 END */

		END IF;

	   /* When p_key2 is not null ie. ship_from_org_id is not null then
	   load the shippable_item_flag based on the ship_from_org. In future
	   please add the attributes here that needs to be loaded based on the
        ship_from_org_id */

         IF  (p_key2 IS NOT NULL)  AND
		   (p_key2 <> FND_API.G_MISS_NUM) --AND
--                   (p_key2 <> l_key2 )   --added for bug 4171642 removed for bug 	6666457
         THEN

		 IF (g_item_rec.organization_id   <> p_key2)
		 OR (l_inventory_changed = 'Y' ) THEN

			l_inventory_changed := 'N';

          if l_debug_level > 0 then
            OE_DEBUG_PUB.ADD('querying based on ship_from_org', 3);
          end if;
	     	SELECT shippable_item_flag
			      ,organization_id
                       , restrict_subinventories_code -- bug 4171642
			        ,ONT_PRICING_QTY_SOURCE -- INVCONV
			        ,TRACKING_QUANTITY_IND
                 ,SECONDARY_UOM_CODE
                 ,SECONDARY_DEFAULT_IND
                 ,LOT_DIVISIBLE_FLAG
                 ,GRADE_CONTROL_FLAG
                 ,LOT_CONTROL_CODE
                 , returnable_flag  --5608844
                 ,PRIMARY_UOM_CODE -- 5608585

               INTO  g_item_rec.shippable_item_flag
			      ,g_item_rec.organization_id
		              ,g_item_rec.restrict_subinventories_code
			      ,g_item_rec.ont_pricing_qty_source
			      ,g_item_rec.tracking_quantity_ind
			      ,g_item_rec.secondary_uom_code
                      -- INVCONV start
                 ,g_item_rec.secondary_default_ind
                 ,g_item_rec.lot_divisible_flag
                 ,g_item_rec.grade_control_flag
                 ,g_item_rec.lot_control_code
		 ,g_item_rec.returnable_flag  --5608844
                 ,g_item_rec.primary_uom_code -- 5608585


	    	     FROM   MTL_SYSTEM_ITEMS
	    	     WHERE  INVENTORY_ITEM_ID = p_key1
	    	     AND	    ORGANIZATION_ID = p_key2;
           -- Pack J catchweight
           --Find out whether the inventory org is WMS enabled from mtl_parameters
               IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
                   SELECT wms_enabled_flag
                   INTO g_item_rec.wms_enabled_flag
                   FROM mtl_parameters
                   WHERE organization_id = p_key2;
               END IF;

           END IF;
         END IF;
    END IF;

    /* OPM - check for process warehouse */
    IF INV_GMI_RSV_BRANCH.Is_Org_Process_Org(p_key2) THEN
      g_item_rec.process_warehouse_flag := 'Y';
      --g_item_rec.ont_pricing_qty_source := GML_READ_IC_B.read_price_qty_source(p_key1, l_key2); -- INVCONV 2044240
     --if l_debug_level > 0 then
      --OE_DEBUG_PUB.ADD('OPM ont_pricing_qty_source after read ic_item_mst_b = ' || g_item_rec.ont_pricing_qty_source, 5);
     --end if;
    ELSE
      g_item_rec.process_warehouse_flag := NULL;
    END IF;

  if l_debug_level > 0 then
    oe_debug_pub.add('in OE_ORDER_CACHE.LOAD_ITEM process warehouse flag is  ' || g_item_rec.process_warehouse_flag );
    /* OPM END */

    oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_ITEM', 1);
  end if;
EXCEPTION
-- this is temporary workaround

    WHEN NO_DATA_FOUND THEN

         SELECT  INVENTORY_ITEM_ID
	    ,       ORGANIZATION_ID
	    ,	    INVOICING_RULE_ID
	    ,	    ACCOUNTING_RULE_ID
	    ,	    DEFAULT_SHIPPING_ORG
        ,       SHIP_MODEL_COMPLETE_FLAG
        ,       BUILD_IN_WIP_FLAG
        ,       BOM_ITEM_TYPE
        ,       REPLENISH_TO_ORDER_FLAG
	    ,	    PRIMARY_UOM_CODE
        ,       PICK_COMPONENTS_FLAG
        ,       SHIPPABLE_ITEM_FLAG
        ,       SERVICE_ITEM_FLAG
                -- added for bug 4171642
                 ,ORGANIZATION_ID
                 ,CUSTOMER_ORDER_ENABLED_FLAG
                 ,INTERNAL_ORDER_ENABLED_FLAG
                 ,RETURNABLE_FLAG
                 ,RESTRICT_SUBINVENTORIES_CODE

	    INTO    g_item_rec.inventory_item_id
	    ,	    g_item_rec.organization_id
	    ,	    g_item_rec.invoicing_rule_id
	    ,	    g_item_rec.accounting_rule_id
	    ,	    g_item_rec.default_shipping_org
        ,       g_item_rec.ship_model_complete_flag
        ,       g_item_rec.build_in_wip_flag
	    ,	    g_item_rec.bom_item_type
        ,       g_item_rec.replenish_to_order_flag
	    ,	    g_item_rec.primary_uom_code
        ,       g_item_rec.pick_components_flag
        ,       g_item_rec.shippable_item_flag
        ,       g_item_rec.service_item_flag
	-- bug 4171642
                 ,g_item_rec.master_org_id
                 ,g_item_rec.customer_order_enabled_flag
                 ,g_item_rec.internal_order_enabled_flag
                 ,g_item_rec.returnable_flag
                 ,g_item_rec.restrict_subinventories_code

	    FROM    MTL_SYSTEM_ITEMS
	    WHERE   INVENTORY_ITEM_ID = p_key1
	    AND	    ORGANIZATION_ID = OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID',p_key3);

      if l_debug_level > 0 then
        oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_ITEM - item doesnt exist in ship_from', 2);
      end if;
    WHEN OTHERS THEN

      if l_debug_level > 0 then
        oe_debug_pub.add('exception in load item', 1);
      end if;
    	IF 	OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Load_Item'
	    );
    	END IF;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_Item;

FUNCTION Load_Set
(   p_set_id	IN NUMBER)
RETURN set_rec_type
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.LOAD_SET', 1);
  end if;

    IF  (p_set_id IS NOT NULL)
    THEN
         --IF (g_set_rec.set_id <> p_set_id)
       -- THEN
        BEGIN
           	SELECT	set_id
                   	,set_name
                   	,set_type
		   			,header_Id
		   			,ship_from_org_id
		   			,ship_to_org_id
		   			,schedule_ship_date
		   			,schedule_arrival_date
		   			,shipment_priority_code
		   			,freight_carrier_code
		   			,shipping_method_code
		   			,set_status

           INTO		g_set_rec.set_id
					,g_set_rec.set_name
					,g_set_rec.set_type
					,g_set_rec.Header_Id
					,g_set_rec.Ship_from_org_id
					,g_set_rec.Ship_to_org_id
					,g_set_rec.Schedule_Ship_Date
					,g_set_rec.Schedule_Arrival_Date
					,g_set_rec.Shipment_priority_code
					,g_set_rec.Freight_Carrier_Code
					,g_set_Rec.Shipping_Method_Code
					,g_set_rec.Set_Status

           FROM    oe_sets
           WHERE   oe_sets.set_id= p_set_id;

        EXCEPTION

        	WHEN NO_DATA_FOUND THEN
	  			g_set_rec.set_id   := NULL;
	  			g_set_rec.set_name := NULL;
				g_set_rec.set_type := NULL;
                g_set_rec.Header_Id := NULL;
                g_set_rec.Ship_from_org_id := NULL;
                g_set_rec.Ship_to_org_id := NULL;
                g_set_rec.shipment_priority_code := NULL;
                g_set_rec.Schedule_Ship_Date:= NULL;
                g_set_rec.Schedule_Arrival_Date := NULL;
                g_set_rec.Freight_Carrier_Code := NULL;
                g_set_Rec.Shipping_Method_Code := NULL;
                g_set_rec.Set_Status := NULL;

 	    	WHEN OTHERS THEN

	  			IF 	OE_MSG_PUB.Check_Msg_Level
	  				(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	  	    	THEN
					OE_MSG_PUB.Add_Exc_Msg
					(   G_PKG_NAME
					,   'Load_set '
					);
				END IF;

				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        	END;
        --END IF;

              if l_debug_level > 0 then
        	oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_SET', 1);
              end if;

        	RETURN g_set_rec;
    END IF;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_SET', 1);
  end if;

    RETURN g_set_rec;

EXCEPTION

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Load_Delivery_Set'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END;

-- added for bug 4200055

FUNCTION Load_Payment_Term
(   p_key	IN NUMBER )
RETURN Payment_Term_Rec_Type
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.LOAD_Payment_Term', 1);
  end if;

    IF 	p_key IS NOT NULL THEN
	IF 	g_Payment_Term_rec.term_id = FND_API.G_MISS_NUM OR
	  	g_Payment_Term_rec.term_id <> p_key THEN
	      oe_debug_pub.add('querying oe_ra_terms_v');
		SELECT term_id ,
		       name,
		       start_date_active,
		       end_date_active
		INTO
		       g_Payment_Term_rec.term_id,
		       g_Payment_Term_rec.name,
		       g_Payment_Term_rec.start_date_active,
		       g_Payment_Term_rec.end_date_active
		 FROM OE_RA_TERMS_V
		 WHERE term_id = p_key ;

	END IF ;
     END IF ;

       if l_debug_level > 0 then
         oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_Payment_Term', 1);
      end if;
    RETURN g_Payment_term_rec;
EXCEPTION
     WHEN NO_DATA_FOUND THEN
     oe_debug_pub.add('No Data Found in OE_Order_Cache.Load_Payment_Term');
	            RAISE NO_DATA_FOUND ;

-- Returning g_payment_rec could potentially pass the wrong result and
-- if processed could result to data corruption

	--return g_payment_term_rec ;
    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Load_Payment_Term'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_Payment_Term;

FUNCTION Load_Salesrep_rec
(   p_key	IN NUMBER )
RETURN Salesrep_Rec_Type
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.LOAD_Salesrep_rec', 1);
  end if;

    IF 	p_key IS NOT NULL THEN
	IF 	g_Salesrep_rec.salesrep_id = FND_API.G_MISS_NUM OR
	  	g_Salesrep_rec.salesrep_id <> p_key THEN
		oe_debug_pub.add('Load Salesrep cache');
		SELECT salesrep_id ,
		       name,
		       status,
		       start_date_active,
		       end_date_active
		INTO
		       g_Salesrep_rec.salesrep_id,
		       g_Salesrep_rec.name,
		       g_Salesrep_rec.status,
		       g_Salesrep_rec.start_date_active,
		       g_Salesrep_rec.end_date_active
		 FROM RA_SALESREPS
		 WHERE salesrep_id = p_key ;

	END IF ;
     END IF ;

       if l_debug_level > 0 then
         oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_Salesrep', 1);
      end if;
    RETURN g_Salesrep_rec;
EXCEPTION
     WHEN NO_DATA_FOUND THEN
     oe_debug_pub.add('No Data Found in OE_Order_Cache.Load_Salesrep_rec');
                RAISE NO_DATA_FOUND ;
-- Returing g_salesrep_rec could potentially pass the old information and if processed can result into corruption issue.

--	return g_salesrep_rec ;
    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Load_Salesrep_rec'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_Salesrep_rec;

--end bug 4200055

--  procedures that set the cached records.

PROCEDURE Set_Order_Header
(
  p_header_rec IN OE_ORDER_PUB.Header_Rec_Type
) IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.Set_Order_Header', 1);
  end if;

    IF (p_header_rec.header_id IS NOT NULL) THEN

		IF (p_header_rec.header_id = nvl(g_header_rec.header_id,0)) THEN

        	g_header_rec := p_header_rec;

      	END IF;

    END IF;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_ORDER_CACHE.Set_Order_Header', 1);
  end if;

END Set_Order_Header;


--  procedures that clear cached entities.

PROCEDURE Clear_Top_Model_Line(p_key   IN NUMBER)
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.Top_Model_Line', 1);
  end if;

    IF 	nvl(g_top_model_line_rec.line_id,0) = p_key THEN
      if l_debug_level > 0 then
      	oe_debug_pub.add('in ucchb, clearing top model cache: '|| p_key, 3);
      end if;
      	g_top_model_line_rec := OE_ORDER_PUB.G_MISS_LINE_REC;
    END IF;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_ORDER_CACHE.Top_Model_Line', 1);
  end if;

END Clear_Top_Model_Line;


PROCEDURE Clear_Order_Type
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.CLEAR_ORDER_TYPE', 1);
  end if;
    g_order_type_rec := G_MISS_ORDER_TYPE_REC;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_ORDER_CACHE.CLEAR_ORDER_TYPE', 1);
  end if;
END Clear_Order_Type;

PROCEDURE Clear_Agreement
IS
BEGIN

    oe_debug_pub.add('Entering OE_ORDER_CACHE.CLEAR_AGREEMENT', 1);

    g_agreement_rec := G_MISS_AGREEMENT_REC;

    oe_debug_pub.add('Exiting OE_ORDER_CACHE.CLEAR_AGREEMENT', 1);

END Clear_Agreement;

PROCEDURE Clear_Ship_To_Org
IS
BEGIN

    oe_debug_pub.add('Entering OE_ORDER_CACHE.CLEAR_SHIP_TO_ORG', 1);

    g_ship_to_rec := G_MISS_SHIP_TO_REC;

    oe_debug_pub.add('Exiting OE_ORDER_CACHE.CLEAR_SHIP_TO_ORG', 1);

END Clear_Ship_To_Org;

PROCEDURE Clear_Invoice_To_Org
IS
BEGIN

    oe_debug_pub.add('Entering OE_ORDER_CACHE.CLEAR_INVOICE_TO_ORG', 1);

    g_invoice_to_rec := G_MISS_INVOICE_TO_REC;

    oe_debug_pub.add('Exiting OE_ORDER_CACHE.CLEAR_INVOICE_TO_ORG', 1);

END Clear_Invoice_To_Org;

PROCEDURE Clear_Deliver_To_Org
IS
BEGIN

    oe_debug_pub.add('Entering OE_ORDER_CACHE.CLEAR_DELIVER_TO_ORG', 1);

    g_deliver_to_rec := G_MISS_DELIVER_TO_REC;

    oe_debug_pub.add('Exiting OE_ORDER_CACHE.CLEAR_DELIVER_TO_ORG', 1);

END Clear_Deliver_To_Org;

PROCEDURE Clear_Sold_To_Org
IS
BEGIN

    oe_debug_pub.add('Entering OE_ORDER_CACHE.CLEAR_SOLD_TO_ORG', 1);

    g_sold_to_rec := G_MISS_SOLD_TO_REC;

    oe_debug_pub.add('Exiting OE_ORDER_CACHE.CLEAR_SOLD_TO_ORG', 1);

END Clear_Sold_To_Org;

PROCEDURE Clear_Price_List
IS
BEGIN

    oe_debug_pub.add('Entering OE_ORDER_CACHE.CLEAR_PRICE_LIST', 1);

    g_price_list_rec := G_MISS_PRICE_LIST_REC;

    oe_debug_pub.add('Exiting OE_ORDER_CACHE.CLEAR_PRICE_LIST', 1);

END Clear_Price_List;

PROCEDURE Clear_Set_Of_Books
IS
BEGIN

    oe_debug_pub.add('Entering OE_ORDER_CACHE.CLEAR_SET_OF_BOOKS', 1);

    g_set_of_books_rec := G_MISS_SET_OF_BOOKS_REC;

    oe_debug_pub.add('Exiting OE_ORDER_CACHE.CLEAR_SET_OF_BOOKS', 1);

END Clear_Set_Of_Books;

PROCEDURE Clear_item
IS
BEGIN

    oe_debug_pub.add('Entering OE_ORDER_CACHE.CLEAR_ITEM', 1);

    g_item_rec := G_MISS_ITEM_REC;

    oe_debug_pub.add('Exiting OE_ORDER_CACHE.CLEAR_ITEM', 1);

END Clear_item;

PROCEDURE Clear_item_Cost
IS
BEGIN

    oe_debug_pub.add('Entering OE_ORDER_CACHE.CLEAR_ITEM_COST', 1);

    g_item_cost_rec := G_MISS_ITEM_COST_REC;

    oe_debug_pub.add('Exiting OE_ORDER_CACHE.CLEAR_ITEM_COST', 1);

END Clear_item_Cost;

PROCEDURE Clear_Order_Header
IS
BEGIN

    oe_debug_pub.add('Entering OE_ORDER_CACHE.CLEAR_ORDER_HEADER', 1);

    g_header_rec := OE_Order_PUB.G_MISS_HEADER_REC;

    oe_debug_pub.add('Exiting OE_ORDER_CACHE.CLEAR_ORDER_HEADER', 1);

END Clear_Order_Header;


PROCEDURE Clear_Discount
  IS
BEGIN

   oe_debug_pub.add('Entering OE_ORDER_CACHE.CLEAR_DISCOUNT', 1);

   g_hdr_discount_rec := oe_order_cache.g_miss_discount_rec;
   g_line_discount_rec := oe_order_cache.g_miss_discount_rec;

   oe_debug_pub.add('Exiting OE_ORDER_CACHE.CLEAR_DISCOUNT', 1);

END clear_discount;

--added for bug 4200055
PROCEDURE Clear_Salesrep
 IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
   IF l_debug_level > 0 THEN
       oe_debug_pub.add('Entering OE_ORDER_CACHE.CLEAR_SALESREP', 1);
   END IF;

   g_salesrep_rec := oe_order_cache.g_miss_salesrep_rec;

   IF l_debug_level > 0 THEN
       oe_debug_pub.add('Exiting OE_ORDER_CACHE.CLEAR_SALESREP', 1);
   END IF;

END clear_salesrep;


PROCEDURE Clear_Payment_Term
  IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Entering OE_ORDER_CACHE.CLEAR_payment_term', 1);
   END IF;

   g_payment_term_rec := oe_order_cache.g_miss_payment_term_rec;

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Exiting OE_ORDER_CACHE.CLEAR_payment_term', 1);
   END IF;

END clear_payment_term;
-- end bug 4200055

PROCEDURE Clear_All
IS
BEGIN

	oe_debug_pub.add('Entering OE_ORDER_CACHE.CLEAR_ALL', 1);

	Clear_Order_Type;
	Clear_Agreement;
	Clear_Ship_To_Org;
	Clear_Invoice_To_Org;
	Clear_Deliver_To_Org;
	Clear_Sold_To_Org;
	Clear_Price_List;
	Clear_Set_Of_Books;
	Clear_Item;
	Clear_Item_Cost;
	Clear_Order_Header;
	Clear_Discount;
        --added for bug 4200055
	Clear_Payment_Term ;
	Clear_Salesrep ;
	--end

	oe_debug_pub.add('Exiting OE_ORDER_CACHE.CLEAR_ALL', 1);

END Clear_All;

FUNCTION Get_Set_Of_Books
Return Number
IS
	l_set_of_books_id Number;
BEGIN
	l_set_of_books_id := OE_Sys_Parameters.VALUE('SET_OF_BOOKS_ID');

	RETURN l_set_of_books_id;
END Get_Set_Of_Books;


FUNCTION Load_List_Lines
(   p_key	IN NUMBER )
RETURN Modifiers_Rec_Type
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.LOAD_list_lines', 1);
  end if;

    IF 	p_key IS NOT NULL THEN

		IF 	g_Modifiers_Rec.list_line_id = FND_API.G_MISS_NUM OR
           	g_Modifiers_Rec.list_line_id <> p_key THEN

	    	SELECT 	arithmetic_operator
					,automatic_flag
					,base_qty
					,base_uom_code
					,inventory_item_id
					,list_header_id
					,list_line_id
					,list_line_type_code
					,modifier_level_code
					,operand
					,organization_id
					,override_flag
					,percent_price
					,price_break_type_code
					,price_by_formula_id
					,primary_uom_flag
					,print_on_invoice_flag
					,rebate_transaction_type_code
					,related_item_id
					,relationship_type_id
					,substitution_attribute
					,substitution_context
					,substitution_value
					,accrual_flag
					,pricing_group_sequence
					,incompatibility_grp_code
					,list_line_no
					,pricing_phase_id
					,product_precedence
					,expiration_date
					,charge_type_code
					,charge_subtype_code
					,benefit_qty
					,benefit_uom_code
					,accrual_conversion_rate
					,proration_type_code
					,include_on_returns_flag
                                        ,print_on_invoice_flag
                                        ,accrual_flag
			INTO
	    			g_Modifiers_Rec.arithmetic_operator
					,g_Modifiers_Rec.automatic_flag
					,g_Modifiers_Rec.base_qty
					,g_Modifiers_Rec.base_uom_code
					,g_Modifiers_Rec.inventory_item_id
					,g_Modifiers_Rec.list_header_id
					,g_Modifiers_Rec.list_line_id
					,g_Modifiers_Rec.list_line_type_code
					,g_Modifiers_Rec.modifier_level_code
					,g_Modifiers_Rec.operand
					,g_Modifiers_Rec.organization_id
					,g_Modifiers_Rec.override_flag
					,g_Modifiers_Rec.percent_price
					,g_Modifiers_Rec.price_break_type_code
					,g_Modifiers_Rec.price_by_formula_id
					,g_Modifiers_Rec.primary_uom_flag
					,g_Modifiers_Rec.print_on_invoice_flag
					,g_Modifiers_Rec.rebate_transaction_type_code
					,g_Modifiers_Rec.related_item_id
					,g_Modifiers_Rec.relationship_type_id
					,g_Modifiers_Rec.substitution_attribute
					,g_Modifiers_Rec.substitution_context
					,g_Modifiers_Rec.substitution_value
					,g_Modifiers_Rec.accrual_flag
					,g_Modifiers_Rec.pricing_group_sequence
					,g_Modifiers_Rec.incompatibility_grp_code
					,g_Modifiers_Rec.list_line_no
					,g_Modifiers_Rec.pricing_phase_id
					,g_Modifiers_Rec.product_precedence
					,g_Modifiers_Rec.expiration_date
					,g_Modifiers_Rec.charge_type_code
					,g_Modifiers_Rec.charge_subtype_code
					,g_Modifiers_Rec.benefit_qty
					,g_Modifiers_Rec.benefit_uom_code
					,g_Modifiers_Rec.accrual_conversion_rate
					,g_Modifiers_Rec.proration_type_code
					,g_Modifiers_Rec.include_on_returns_flag
                                        ,g_Modifiers_Rec.print_on_invoice_flag
                                        ,g_Modifiers_Rec.accrual_flag
			FROM 	qp_list_lines
			WHERE 	list_line_id= p_key;

		END IF;

    END IF;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_list_lines', 1);
  end if;

    RETURN g_Modifiers_Rec;

EXCEPTION

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Load_list_lines'||sqlerrm
	    	);
    	END IF;

		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_List_Lines;

Function Load_Cust_Trx_Type
(   p_key	IN NUMBER )
RETURN Cust_Trx_Rec_Type
IS
BEGIN

     Load_Cust_Trx_Type(p_key);

     RETURN g_cust_trx_rec;

END Load_Cust_Trx_Type;

Procedure Load_Cust_Trx_Type
(   p_key	IN NUMBER )
IS
l_calculate_tax_flag varchar2(1) := NULL;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_current_org_id NUMBER ;  -- MOAC Changes
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.LOAD_CUST_TRX_TYPE', 1);
  end if;

    l_current_org_id := MO_Global.Get_Current_Org_Id() ;  --MOAC changes

    -- New condition added for bug 2281054
    If p_key = 0 then
     if l_debug_level > 0 then
      oe_debug_pub.add('No Receivable Transaction Type assigned at any of the levels');
     end if;
      -- bug 2604421, need to initialize this value, otherwise the
      -- tax_calculation_flag cached from previous order will remain.
      g_cust_trx_rec.tax_calculation_flag := null;
      g_cust_trx_rec.cust_trx_type_id := null;
      g_cust_trx_rec.org_id := null ; -- MOAC changes

      goto THE_END;
    end if;

    IF 	p_key IS NOT NULL THEN
         /* Modified the If condition  for Bug-2113379 */
		IF Nvl(g_cust_trx_rec.cust_trx_type_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM OR
	   	  g_cust_trx_rec.cust_trx_type_id <> p_key OR
		  g_cust_trx_rec.org_id <> l_current_org_id THEN --MOAC changes

                  SELECT tax_calculation_flag
                        ,cust_trx_type_id
			,org_id
                  INTO   g_cust_trx_rec.tax_calculation_flag
                        ,g_cust_trx_rec.cust_trx_type_id
			,g_cust_trx_rec.org_id         -- MOAC Changes
                  FROM   RA_CUST_TRX_TYPES_ALL
                  WHERE  CUST_TRX_TYPE_ID = p_key
		    AND  ORG_ID = l_current_org_id ;

                END IF;

    END IF;
    <<THE_END>>

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_CUST_TRX_TYPE', 1);
  end if;

EXCEPTION

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Load_Cust_Trx_Type'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Load_Cust_Trx_Type;

FUNCTION get_tax_calculation_flag
(   p_key	IN NUMBER,
    p_line_rec  IN OE_ORDER_PUB.Line_Rec_Type )
RETURN Tax_Calc_Rec_Type
IS
l_calculate_tax_flag varchar2(1) := NULL;
l_tax_rec Tax_Calc_Rec_Type;
l_cust_trx_type_id number;
v_start number;
v_end number;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

   --v_start := DBMS_UTILITY.GET_TIME;

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_ORDER_CACHE.GET_TAX_CALCULATION_FLAG', 1);
  end if;

    IF 	p_key IS NOT NULL THEN

        IF g_tax_calc_tbl.Exists(p_key) THEN

         l_tax_rec.tax_calculation_flag := g_tax_calc_tbl(p_key).tax_calculation_flag;

         l_tax_rec.cust_trx_type_id := g_tax_calc_tbl(p_key).cust_trx_type_id;

         l_tax_rec.line_type_id := g_tax_calc_tbl(p_key).line_type_id;

  if l_debug_level > 0 then
   oe_debug_pub.add('ren: flag: cust_trx_type_id: line_type_id: ' || l_tax_rec.tax_calculation_flag ||': ' || l_tax_rec.cust_trx_type_id || ': ' || l_tax_rec.line_type_id || ' .' , 4);
  end if;

        ELSE


           Load_Line_Type(p_key);

           l_calculate_tax_flag := g_line_type_rec.calculate_tax_flag;
           l_cust_trx_type_id := g_line_type_rec.cust_trx_type_id;

           -- made code changes for bug 2604421.
           IF ( g_line_type_rec.cust_trx_type_id is null and
                g_line_type_rec.calculate_tax_flag is null )
           Then

              l_cust_trx_type_id :=
              OE_INVOICE_PUB.Get_Customer_Transaction_Type(p_line_rec);

              load_cust_trx_type(l_cust_trx_type_id);

              l_calculate_tax_flag := g_cust_trx_rec.tax_calculation_flag;

              l_tax_rec.line_type_id := p_key;
              l_tax_rec.tax_calculation_flag := l_calculate_tax_flag;
              l_tax_rec.cust_trx_type_id := l_cust_trx_type_id;

           ELSE

              l_tax_rec.line_type_id := p_key;
              l_tax_rec.tax_calculation_flag := l_calculate_tax_flag;
              l_tax_rec.cust_trx_type_id := l_cust_trx_type_id;

              g_tax_calc_tbl(p_key) := l_tax_rec;
            if l_debug_level > 0 then
              oe_debug_pub.add('g_tax_calc_tbl flag: cust_trx_type_id: line_type_id: ' || g_tax_calc_tbl(p_key).tax_calculation_flag ||': ' || g_tax_calc_tbl(p_key).cust_trx_type_id || ': ' || g_tax_calc_tbl(p_key).line_type_id || ' .' , 4);
            end if;

           END IF; /* if cust_trx_type_id is null and
                      calculate_tax_flag is null */

        END IF;  /* if g_tax_calc_tbl.Exists(p_key) */

    END IF;  /* IF p_key is not null */

    --v_end := DBMS_UTILITY.GET_TIME;

-- oe_debug_pub.add('ren: Time Of execution for get_tax_calculation_flag '||
--    to_char((v_end-v_start)/100),1);

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_ORDER_CACHE.GET_TAX_CALCULATION_FLAG', 1);
  end if;

    RETURN l_tax_rec;



EXCEPTION

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'get_tax_calculation_flag'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END get_tax_calculation_flag;

FUNCTION IS_FLEX_ENABLED(p_flex_name IN VARCHAR2)
RETURN VARCHAR2
IS
l_flex_name varchar2(240);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
  if l_debug_level > 0 then
	oe_debug_pub.add('Enter Is Flex Enabled' ,1);
  end if;
		IF p_flex_name = 'OE_HEADER_ATTRIBUTES' THEN
			IF g_hdr_desc_flex is null THEN
		 g_hdr_desc_flex := Load_flex_enabled_flag(p_flex_name);
			END IF;
			RETURN g_hdr_desc_flex;
		ELSIF p_flex_name = 'OE_HEADER_GLOBAL_ATTRIBUTE' THEN
			IF g_hdr_glb_flex is null THEN
		g_hdr_glb_flex :=  Load_flex_enabled_flag(p_flex_name);
			END IF;
			RETURN g_hdr_glb_flex;
		ELSIF p_flex_name = 'OE_HEADER_TP_ATTRIBUTES' THEN
			IF g_hdr_tp_flex is null THEN
		g_hdr_tp_flex	:= Load_flex_enabled_flag(p_flex_name);
			END IF;
			RETURN g_hdr_tp_flex;
		ELSIF p_flex_name = 'OE_LINE_ATTRIBUTES' THEN
			IF g_line_desc_flex is null THEN
			g_line_desc_flex := Load_flex_enabled_flag(p_flex_name);
			END IF;
			RETURN g_line_desc_flex;
		ELSIF p_flex_name = 'OE_LINE_GLOBAL_ATTRIBUTE' THEN
			IF g_line_glb_flex is null THEN
			g_line_glb_flex :=  Load_flex_enabled_flag(p_flex_name);
			END IF;
			RETURN g_line_glb_flex;
		ELSIF p_flex_name = 'OE_LINE_PRICING_ATTRIBUTE' THEN
			IF g_line_prc_flex is null THEN
		        g_line_prc_flex :=  Load_flex_enabled_flag(p_flex_name);
			END IF;
			RETURN g_line_prc_flex;
		ELSIF p_flex_name = 'OE_LINE_TP_ATTRIBUTES' THEN
			IF g_line_tp_flex is null THEN
			 g_line_tp_flex := Load_flex_enabled_flag(p_flex_name);
			END IF;
			RETURN g_line_tp_flex;
		ELSIF p_flex_name = 'OE_LINE_RETURN_ATTRIBUTE' THEN
			IF g_line_ret_flex is null THEN
			 g_line_ret_flex := Load_flex_enabled_flag(p_flex_name);
			END IF;
			RETURN g_line_ret_flex;
		ELSIF p_flex_name = 'OE_LINE_INDUSTRY_ATTRIBUTE' THEN

			IF g_line_ind_flex is null THEN
			IF OE_GLOBALS.G_RLM_INSTALLED = 'Y' THEN
			   l_flex_name := 'RLM_SCHEDULE_LINES';
			 ELSE    -- 2684403, 2511313
			   l_flex_name := p_flex_name;
			END IF;
			g_line_ind_flex :=  Load_flex_enabled_flag(l_flex_name);
			END IF;
			RETURN g_line_ind_flex;
		ELSIF p_flex_name = 'OE_BLKT_HEADER_ATTRIBUTES' THEN
			IF g_hdr_blkt_desc_flex is null THEN
		g_hdr_blkt_desc_flex :=  Load_flex_enabled_flag(p_flex_name);
			END IF;
			RETURN g_hdr_blkt_desc_flex;
		ELSIF p_flex_name = 'OE_BLKT_LINE_ATTRIBUTES' THEN
			IF g_line_blkt_desc_flex is null THEN
			g_line_blkt_desc_flex := Load_flex_enabled_flag(p_flex_name);
			END IF;
			RETURN g_line_blkt_desc_flex;
		END IF;
			NULL;
      if l_debug_level > 0 then
	oe_debug_pub.add('Exit Is Flex Enabled' ,1);
      end if;

END IS_FLEX_ENABLED;


FUNCTION LOAD_FLEX_ENABLED_FLAG(p_flex_name VARCHAR2)
RETURN VARCHAR2
IS
l_count number;
l_application_id number;  --For bug 2684403
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
  if l_debug_level > 0 then
	oe_debug_pub.add('Enter Load Flex Enabled Flag ' ,1);
  end if;

    l_application_id := 660;

    IF p_flex_name = 'RLM_SCHEDULE_LINES' THEN  --For bug 2684403
           l_application_id := 662;
    END IF;

    SELECT count(*)
    INTO l_count
    FROM fnd_descr_flex_column_usages
    WHERE APPLICATION_ID = l_application_id
    AND DESCRIPTIVE_FLEXFIELD_NAME = p_flex_name
    AND ENABLED_FLAG = 'Y'
    AND ROWNUM = 1;

    IF l_count = 1 THEN
        RETURN 'Y';
    ELSE
        RETURN 'N';
    END IF;
  if l_debug_level > 0 then
	oe_debug_pub.add('Exit Load Flex Enabled Flag ' ,1);
  end if;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'N';
END LOAD_FLEX_ENABLED_FLAG ;





END OE_Order_Cache;

/
