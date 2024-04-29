--------------------------------------------------------
--  DDL for Package Body OE_HEADER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_HEADER_UTIL" AS
/* $Header: OEXUHDRB.pls 120.36.12010000.23 2010/03/24 11:34:54 ramising ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Header_Util';

-- LOCAL Procedures

-- Added 09-DEC-2002
-- Forward declaration of LOCAL PROCEDURE Blkt_Req_For_Curr_Upd_And_Del
PROCEDURE Blkt_Req_For_Curr_Upd_And_Del
  (p_header_rec          IN OE_Order_PUB.Header_Rec_Type
   ,p_old_header_rec     IN OE_Order_PUB.Header_Rec_Type
  );

--bug 5083663
PROCEDURE Set_CC_Selected_From_Lov (p_CC_selected_from_LOV IN VARCHAR2)
IS
BEGIN
     g_is_cc_selected_from_LOV := p_CC_selected_from_LOV;
EXCEPTION
WHEN OTHERS THEN
       NULL;
END Set_CC_Selected_From_Lov;

-- Clear_Dependents

PROCEDURE Clear_Dependents
	(p_src_attr_tbl				IN  OE_GLOBALS.NUMBER_Tbl_Type
     ,p_initial_header_rec		IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
     ,p_old_header_rec			IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
	,p_x_header_rec				IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
	,p_x_instrument_id		IN NUMBER DEFAULT NULL
	,p_old_instrument_id		IN NUMBER DEFAULT NULL)
IS
	l_dep_attr_tbl          OE_GLOBALS.NUMBER_Tbl_Type;

	PROCEDURE ACCOUNTING_RULE
	IS
	BEGIN
		IF (p_initial_header_rec.accounting_rule_id = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.accounting_rule_id, p_old_header_rec.accounting_rule_id)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.accounting_rule_id IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.accounting_rule_id := FND_API.G_MISS_NUM;
		END IF;
	END ACCOUNTING_RULE;

	PROCEDURE ACCOUNTING_RULE_DURATION
	IS
	BEGIN
		IF (p_initial_header_rec.accounting_rule_duration = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.accounting_rule_duration, p_old_header_rec.accounting_rule_duration)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.accounting_rule_duration IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.accounting_rule_duration := FND_API.G_MISS_NUM;
		END IF;
	END ACCOUNTING_RULE_DURATION;

	PROCEDURE AGREEMENT IS
	BEGIN
		IF (p_initial_header_rec.agreement_id = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.agreement_id, p_old_header_rec.agreement_id)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.agreement_id IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.agreement_id := FND_API.G_MISS_NUM;
		END IF;
	END AGREEMENT;

	PROCEDURE CONVERSION_RATE IS
	BEGIN
		IF (p_initial_header_rec.conversion_rate = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.conversion_rate, p_old_header_rec.conversion_rate)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.conversion_rate IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.conversion_rate := FND_API.G_MISS_NUM;
		END IF;
	END CONVERSION_RATE;

	PROCEDURE CONVERSION_RATE_DATE IS
	BEGIN
		IF (p_initial_header_rec.conversion_rate_date = FND_API.G_MISS_DATE
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.conversion_rate_date, p_old_header_rec.conversion_rate_date)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.conversion_rate_date IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.conversion_rate_date := FND_API.G_MISS_DATE;
		END IF;
	END CONVERSION_RATE_DATE;

	PROCEDURE CONVERSION_TYPE IS
	BEGIN
		IF (p_initial_header_rec.conversion_type_code = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.conversion_type_code, p_old_header_rec.conversion_type_code)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.conversion_type_code IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.conversion_type_code := FND_API.G_MISS_CHAR;
		END IF;
	END CONVERSION_TYPE;

	PROCEDURE CREDIT_CARD_EXPIRATION_DATE IS
	BEGIN
		IF (p_initial_header_rec.credit_card_expiration_date = FND_API.G_MISS_DATE
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.credit_card_expiration_date, p_old_header_rec.credit_card_expiration_date)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.credit_card_expiration_date IS NOT NULL)
		      AND nvl(g_is_cc_selected_from_LOV,'N') <> 'Y') --bug 5083663
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.credit_card_expiration_date := FND_API.G_MISS_DATE;
		END IF;
	END CREDIT_CARD_EXPIRATION_DATE;

	PROCEDURE CREDIT_CARD_HOLDER_NAME IS
	BEGIN
		IF (p_initial_header_rec.credit_card_holder_name = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.credit_card_holder_name, p_old_header_rec.credit_card_holder_name)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.credit_card_holder_name IS NOT NULL)
		      AND nvl(g_is_cc_selected_from_LOV,'N') <> 'Y') --bug 5083663
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.credit_card_holder_name := FND_API.G_MISS_CHAR;
		END IF;
	END CREDIT_CARD_HOLDER_NAME;

	PROCEDURE CREDIT_CARD_NUMBER IS
	BEGIN
		IF (p_initial_header_rec.credit_card_number = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Is_Same_Credit_Card(p_old_header_rec.credit_card_number,p_initial_header_rec.credit_card_number,
		  p_old_instrument_id,p_x_instrument_id)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.credit_card_number IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			--oe_debug_pub.add('In credit card number clear ....'||p_x_header_rec.credit_card_number);
			p_x_header_rec.credit_card_number := FND_API.G_MISS_CHAR;

		END IF;
	END CREDIT_CARD_NUMBER;

        /* Fix Bug # 2297053: Added to clear Credit Card Type */
	PROCEDURE CREDIT_CARD IS
	BEGIN
		IF (p_initial_header_rec.credit_card_code = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.credit_card_code, p_old_header_rec.credit_card_code)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.credit_card_code IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.credit_card_code := FND_API.G_MISS_CHAR;
		END IF;
	END CREDIT_CARD;

	PROCEDURE CHECK_NUMBER IS    --For bug 2692314
	BEGIN
		IF (p_initial_header_rec.check_number = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.check_number, p_old_header_rec.check_number)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.check_number IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.check_number := FND_API.G_MISS_CHAR;
		END IF;
	END CHECK_NUMBER;

	PROCEDURE CUST_PO_NUMBER IS
	BEGIN
		IF (p_initial_header_rec.cust_po_number = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.cust_po_number, p_old_header_rec.cust_po_number)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.cust_po_number IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.cust_po_number := FND_API.G_MISS_CHAR;
		END IF;
	END CUST_PO_NUMBER;

        PROCEDURE CUSTOMER_PREFERENCE_SET_CODE IS
        BEGIN
		IF (p_initial_header_rec.Customer_Preference_Set_Code = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.Customer_Preference_Set_Code, p_old_header_rec.Customer_Preference_Set_Code)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.Customer_Preference_Set_Code IS NOT NULL))
                   ) -- AND condition added to fix 3098878
                THEN
                        p_x_header_rec.Customer_Preference_Set_Code := FND_API.G_MISS_CHAR;
                END IF;
        END CUSTOMER_PREFERENCE_SET_CODE ;

        PROCEDURE DEFAULT_FULFILLMENT_SET IS
        BEGIN
		IF (p_initial_header_rec.Default_Fulfillment_Set = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.Default_Fulfillment_Set, p_old_header_rec.Default_Fulfillment_Set)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.Default_Fulfillment_Set IS NOT NULL))
                   ) -- AND condition added to fix 3098878
                THEN
                        p_x_header_rec.Default_Fulfillment_Set := FND_API.G_MISS_CHAR;
                END IF;
        END DEFAULT_FULFILLMENT_SET;

	PROCEDURE DELIVER_TO_CONTACT IS
	BEGIN
		IF (p_initial_header_rec.deliver_to_contact_id = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.deliver_to_contact_id, p_old_header_rec.deliver_to_contact_id)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.deliver_to_contact_id IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.deliver_to_contact_id := FND_API.G_MISS_NUM;
		END IF;
	END DELIVER_TO_CONTACT;

	PROCEDURE DELIVER_TO_ORG IS
	BEGIN
		IF (p_initial_header_rec.deliver_to_org_id = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.deliver_to_org_id, p_old_header_rec.deliver_to_org_id)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.deliver_to_org_id IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.deliver_to_org_id := FND_API.G_MISS_NUM;
		END IF;
	END DELIVER_TO_ORG;

	PROCEDURE DEMAND_CLASS IS
	BEGIN
		IF (p_initial_header_rec.demand_class_code = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.demand_class_code, p_old_header_rec.demand_class_code)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.demand_class_code IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.demand_class_code := FND_API.G_MISS_CHAR;
		END IF;
	END DEMAND_CLASS;

	PROCEDURE FOB_POINT IS
	BEGIN
		IF (p_initial_header_rec.fob_point_code = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.fob_point_code, p_old_header_rec.fob_point_code)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.fob_point_code IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.fob_point_code := FND_API.G_MISS_CHAR;
		END IF;
	END FOB_POINT;

	PROCEDURE FREIGHT_TERMS IS
	BEGIN
		IF (p_initial_header_rec.freight_terms_code = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.freight_terms_code, p_old_header_rec.freight_terms_code)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.freight_terms_code IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.freight_terms_code := FND_API.G_MISS_CHAR;
		END IF;
	END FREIGHT_TERMS;

        PROCEDURE FULFILLMENT_SET_NAME IS
        BEGIN
		IF (p_initial_header_rec.Fulfillment_Set_name = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.Fulfillment_Set_name, p_old_header_rec.Fulfillment_Set_name)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.Fulfillment_Set_name IS NOT NULL))
                   ) -- AND condition added to fix 3098878
                THEN
                        p_x_header_rec.Fulfillment_Set_Name := FND_API.G_MISS_CHAR;
                END IF;
        END FULFILLMENT_SET_NAME;

	PROCEDURE INVOICE_TO_CONTACT IS
	BEGIN
		IF (p_initial_header_rec.invoice_to_contact_id = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.invoice_to_contact_id, p_old_header_rec.invoice_to_contact_id)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.invoice_to_contact_id IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.invoice_to_contact_id := FND_API.G_MISS_NUM;
		END IF;
	END INVOICE_TO_CONTACT;

	PROCEDURE INVOICE_TO_ORG IS
	BEGIN
		IF (p_initial_header_rec.invoice_to_org_id = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.invoice_to_org_id, p_old_header_rec.invoice_to_org_id)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.invoice_to_org_id IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.invoice_to_org_id := FND_API.G_MISS_NUM;
		END IF;
	END INVOICE_TO_ORG;

	PROCEDURE INVOICING_RULE IS
	BEGIN
		IF (p_initial_header_rec.invoicing_rule_id = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.invoicing_rule_id, p_old_header_rec.invoicing_rule_id)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.invoicing_rule_id IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.invoicing_rule_id := FND_API.G_MISS_NUM;
		END IF;
	END INVOICING_RULE;

        PROCEDURE LINE_SET_NAME IS
        BEGIN
		IF (p_initial_header_rec.Line_Set_name = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.Line_Set_name, p_old_header_rec.Line_Set_name)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.Line_Set_name IS NOT NULL))
                   ) -- AND condition added to fix 3098878
                THEN
                        p_x_header_rec.Line_Set_Name := FND_API.G_MISS_CHAR;
                END IF;
        END LINE_SET_NAME;

	PROCEDURE ORDER_CATEGORY IS
	BEGIN
		IF (p_initial_header_rec.order_category_code = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.order_category_code, p_old_header_rec.order_category_code)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.order_category_code IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.order_category_code := FND_API.G_MISS_CHAR;
		END IF;
	END ORDER_CATEGORY;

	PROCEDURE ORDER_DATE_TYPE IS
	BEGIN

		IF (p_initial_header_rec.order_date_type_code = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.order_date_type_code, p_old_header_rec.order_date_type_code)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.order_date_type_code IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.order_date_type_code := FND_API.G_MISS_CHAR;
		END IF;
	END ORDER_DATE_TYPE;

	PROCEDURE ORDER_TYPE IS
	BEGIN
		IF (p_initial_header_rec.order_type_id = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.order_type_id, p_old_header_rec.order_type_id)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.order_type_id IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.order_type_id := FND_API.G_MISS_NUM;
		END IF;
	END ORDER_TYPE;

	--Bug 4360599 Added this method to clear the payment Amount
	PROCEDURE PAYMENT_AMOUNT IS
	BEGIN
		IF (p_initial_header_rec.PAYMENT_AMOUNT = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.PAYMENT_AMOUNT, p_old_header_rec.PAYMENT_AMOUNT)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.PAYMENT_AMOUNT IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.PAYMENT_AMOUNT := FND_API.G_MISS_NUM;
		END IF;
	END PAYMENT_AMOUNT;

	PROCEDURE PAYMENT_TERM IS
	BEGIN
		IF (p_initial_header_rec.payment_term_id = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.payment_term_id, p_old_header_rec.payment_term_id)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.payment_term_id IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.payment_term_id := FND_API.G_MISS_NUM;
		END IF;
	END PAYMENT_TERM;

	PROCEDURE PRICE_LIST IS
	BEGIN
		IF (p_initial_header_rec.price_list_id = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.price_list_id, p_old_header_rec.price_list_id)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.price_list_id IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.price_list_id := FND_API.G_MISS_NUM;
		END IF;
	END PRICE_LIST;

	PROCEDURE PRICE_REQUEST_CODE IS  -- PROMOTIONS SEP/01 BEGIN
	BEGIN
		IF (p_initial_header_rec.price_request_code = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.price_request_code, p_old_header_rec.price_request_code)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.price_request_code IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.price_request_code := FND_API.G_MISS_CHAR;
		END IF;
	END PRICE_REQUEST_CODE;          -- PROMOTIONS SEP/01 END

	PROCEDURE REQUEST_DATE IS
	BEGIN
		IF (p_initial_header_rec.request_date = FND_API.G_MISS_DATE
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.request_date, p_old_header_rec.request_date)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.request_date IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.request_date := FND_API.G_MISS_DATE;
		END IF;
	END REQUEST_DATE;

	PROCEDURE SALESREP IS
	BEGIN
		IF (p_initial_header_rec.salesrep_id = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.salesrep_id, p_old_header_rec.salesrep_id)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.salesrep_id IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.salesrep_id := FND_API.G_MISS_NUM;
		END IF;
	END SALESREP;

	PROCEDURE SALES_CHANNEL IS
	BEGIN
		IF (p_initial_header_rec.sales_channel_code = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.sales_channel_code, p_old_header_rec.sales_channel_code)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.sales_channel_code IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.sales_channel_code := FND_API.G_MISS_CHAR;
		END IF;
	END SALES_CHANNEL;

	PROCEDURE SHIPMENT_PRIORITY IS
	BEGIN
		IF (p_initial_header_rec.shipment_priority_code = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.shipment_priority_code, p_old_header_rec.shipment_priority_code)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.shipment_priority_code IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.shipment_priority_code := FND_API.G_MISS_CHAR;
		END IF;
	END SHIPMENT_PRIORITY;

	PROCEDURE SHIPPING_METHOD IS
	BEGIN
		IF (p_initial_header_rec.shipping_method_code = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.shipping_method_code, p_old_header_rec.shipping_method_code)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.shipping_method_code IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.shipping_method_code := FND_API.G_MISS_CHAR;
		END IF;
	END SHIPPING_METHOD;

	PROCEDURE SHIP_FROM_ORG IS
	BEGIN
		IF (p_initial_header_rec.ship_from_org_id = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.ship_from_org_id, p_old_header_rec.ship_from_org_id)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.ship_from_org_id IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.ship_from_org_id := FND_API.G_MISS_NUM;
		END IF;
	END SHIP_FROM_ORG;

	PROCEDURE SHIP_TOLERANCE_ABOVE IS
	BEGIN
		IF (p_initial_header_rec.ship_tolerance_above = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.ship_tolerance_above, p_old_header_rec.ship_tolerance_above)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.ship_tolerance_above IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.ship_tolerance_above := FND_API.G_MISS_NUM;
		END IF;
	END SHIP_TOLERANCE_ABOVE;

	PROCEDURE SHIP_TOLERANCE_BELOW IS
	BEGIN
		IF (p_initial_header_rec.ship_tolerance_below = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.ship_tolerance_below, p_old_header_rec.ship_tolerance_below)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.ship_tolerance_below IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.ship_tolerance_below := FND_API.G_MISS_NUM;
		END IF;
	END SHIP_TOLERANCE_BELOW;

	PROCEDURE SHIP_TO_CONTACT IS
	BEGIN
		IF (p_initial_header_rec.ship_to_contact_id = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.ship_to_contact_id, p_old_header_rec.ship_to_contact_id)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.ship_to_contact_id IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.ship_to_contact_id := FND_API.G_MISS_NUM;
		END IF;
	END SHIP_TO_CONTACT;

	PROCEDURE SHIP_TO_ORG IS
	BEGIN
		IF (p_initial_header_rec.ship_to_org_id = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.ship_to_org_id, p_old_header_rec.ship_to_org_id)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.ship_to_org_id IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.ship_to_org_id := FND_API.G_MISS_NUM;
		END IF;
	END SHIP_TO_ORG;

        -- Fix bug 1753101: sold to contact dependency code added
	PROCEDURE SOLD_TO_CONTACT IS
	BEGIN
		IF (p_initial_header_rec.sold_to_contact_id = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.sold_to_contact_id, p_old_header_rec.sold_to_contact_id)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.sold_to_contact_id IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.sold_to_contact_id := FND_API.G_MISS_NUM;
		END IF;
	END SOLD_TO_CONTACT;

	PROCEDURE SOLD_TO_ORG IS
	BEGIN
		IF (p_initial_header_rec.sold_to_org_id = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.sold_to_org_id, p_old_header_rec.sold_to_org_id)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.sold_to_org_id IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.sold_to_org_id := FND_API.G_MISS_NUM;
		END IF;
	END SOLD_TO_ORG;

        PROCEDURE SOLD_TO_PHONE IS
        BEGIN
		IF (p_initial_header_rec.sold_to_phone_id = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.sold_to_phone_id, p_old_header_rec.sold_to_phone_id)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.sold_to_phone_id IS NOT NULL))
                   ) -- AND condition added to fix 3098878
                THEN
                        p_x_header_rec.sold_to_phone_id := FND_API.G_MISS_NUM;
                END IF;
        END SOLD_TO_PHONE;


	PROCEDURE TAX_EXEMPT_NUMBER IS
	BEGIN
		IF (p_initial_header_rec.tax_exempt_number = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.tax_exempt_number, p_old_header_rec.tax_exempt_number)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.tax_exempt_number IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.tax_exempt_number := FND_API.G_MISS_CHAR;
		END IF;
	END TAX_EXEMPT_NUMBER;

	PROCEDURE TAX_EXEMPT_REASON IS
	BEGIN
		IF (p_initial_header_rec.tax_exempt_reason_code = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.tax_exempt_reason_code, p_old_header_rec.tax_exempt_reason_code)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.tax_exempt_reason_code IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
                   -- If condition for bug #2892094
                   IF OE_GLOBALS.G_UI_FLAG THEN
			p_x_header_rec.tax_exempt_reason_code := FND_API.G_MISS_CHAR;
                   END IF;
		END IF;
	END TAX_EXEMPT_REASON;

	PROCEDURE TRANSACTIONAL_CURR IS
	BEGIN
		IF (p_initial_header_rec.transactional_curr_code = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.transactional_curr_code, p_old_header_rec.transactional_curr_code)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.transactional_curr_code IS NOT NULL))
                   ) -- AND condition added to fix 3098878
		THEN
			p_x_header_rec.transactional_curr_code := FND_API.G_MISS_CHAR;
		END IF;
	END TRANSACTIONAL_CURR;

     PROCEDURE LATEST_SCHEDULE_LIMIT IS
     BEGIN
		IF (p_initial_header_rec.latest_schedule_limit = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.latest_schedule_limit, p_old_header_rec.latest_schedule_limit)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.latest_schedule_limit IS NOT NULL))
                   ) -- AND condition added to fix 3098878
          THEN
               p_x_header_rec.latest_schedule_limit := FND_API.G_MISS_NUM;
          END IF;
     END LATEST_SCHEDULE_LIMIT;

     PROCEDURE PACKING_INSTRUCTIONS IS -- added for 2665264
     BEGIN
		IF (p_initial_header_rec.packing_instructions = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.packing_instructions, p_old_header_rec.packing_instructions)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.packing_instructions IS NOT NULL))
                   ) -- AND condition added to fix 3098878
          THEN
               p_x_header_rec.packing_instructions := FND_API.G_MISS_CHAR;
          END IF;
     END PACKING_INSTRUCTIONS;

     PROCEDURE SHIPPING_INSTRUCTIONS IS -- added for 2766005
     BEGIN
	  IF (p_initial_header_rec.shipping_instructions = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.shipping_instructions, p_old_header_rec.shipping_instructions)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.shipping_instructions IS NOT NULL))
                   ) -- AND condition added to fix 3098878
          THEN
               p_x_header_rec.shipping_instructions := FND_API.G_MISS_CHAR;
          END IF;
     END SHIPPING_INSTRUCTIONS;

     -- QUOTING changes

     PROCEDURE TRANSACTION_PHASE IS
     BEGIN
          -- Transaction phase can only be cleared during CREATE operation
          IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
		AND (p_initial_header_rec.transaction_phase_code = FND_API.G_MISS_CHAR
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.transaction_phase_code, p_old_header_rec.transaction_phase_code)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.transaction_phase_code IS NOT NULL))
                   ) -- 2nd AND condition added to fix 3098878
          THEN
               p_x_header_rec.transaction_phase_code := FND_API.G_MISS_CHAR;
          END IF;
     END TRANSACTION_PHASE;

     PROCEDURE SOLD_TO_SITE_USE IS
     BEGIN
	  IF (p_initial_header_rec.sold_to_site_use_id = FND_API.G_MISS_NUM
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.sold_to_site_use_id, p_old_header_rec.sold_to_site_use_id)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.sold_to_site_use_id IS NOT NULL))
                   ) -- AND condition added to fix 3098878
          THEN
               p_x_header_rec.sold_to_site_use_id := FND_API.G_MISS_NUM;
          END IF;
     END SOLD_TO_SITE_USE;

     PROCEDURE QUOTE_DATE IS
     BEGIN
	  IF (p_initial_header_rec.quote_date = FND_API.G_MISS_DATE
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.quote_date, p_old_header_rec.quote_date)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.quote_date IS NOT NULL))
                   ) -- AND condition added to fix 3098878
                   AND OE_Quote_Util.G_COMPLETE_NEG = 'N'
-- bug 3854887
		   AND  p_x_header_rec.transaction_phase_code = 'N'
          THEN
               p_x_header_rec.quote_date := FND_API.G_MISS_DATE;
          END IF;
     END QUOTE_DATE;

     PROCEDURE ORDERED_DATE IS
     BEGIN
	  IF (p_initial_header_rec.ordered_date = FND_API.G_MISS_DATE
		  OR (OE_GLOBALS.Equal(p_initial_header_rec.ordered_date, p_old_header_rec.ordered_date)
                      AND (p_old_header_rec.header_id IS NOT NULL OR
                           p_initial_header_rec.ordered_date IS NOT NULL))
-- bug 3854887
		      AND (p_x_header_rec.transaction_phase_code IS NULL OR
			     p_x_header_rec.transaction_phase_code = 'F' OR
			     p_x_header_rec.transaction_phase_code =  FND_API.G_MISS_CHAR)
                   ) -- AND condition added to fix 3098878
          THEN
               p_x_header_rec.ordered_date := FND_API.G_MISS_DATE;
          END IF;
     END ORDERED_DATE;

     -- QUOTING changes END

     --distributed orders
     PROCEDURE end_customer IS
     BEGIN
	IF (p_initial_header_rec.end_customer_id = FND_API.G_MISS_NUM
	    OR OE_GLOBALS.Equal(p_initial_header_rec.end_customer_id
				, p_old_header_rec.end_customer_id ))
	THEN
	 p_x_header_rec.end_customer_id := FND_API.G_MISS_NUM;
      END IF;
   END end_customer;

     PROCEDURE end_customer_contact IS
     BEGIN
	IF (p_initial_header_rec.end_customer_contact_id = FND_API.G_MISS_NUM
	    OR OE_GLOBALS.Equal(p_initial_header_rec.end_customer_contact_id
				, p_old_header_rec.end_customer_contact_id ))
	THEN
	 p_x_header_rec.end_customer_contact_id := FND_API.G_MISS_NUM;
      END IF;
   END end_customer_contact;

   PROCEDURE end_customer_site_use IS
   BEGIN
      IF (p_initial_header_rec.end_customer_site_use_id = FND_API.G_MISS_NUM
	  OR OE_GLOBALS.Equal(p_initial_header_rec.end_customer_site_use_id ,
			      p_old_header_rec.end_customer_site_use_id ))
      THEN
	 p_x_header_rec.end_customer_site_use_id := FND_API.G_MISS_NUM;
      END IF;
   END end_customer_site_use;

--key Transaction dates
   PROCEDURE order_firmed_date IS
   BEGIN
     IF (p_initial_header_rec.order_firmed_date = FND_API.G_MISS_DATE
			       OR
        (OE_GLOBALS.equal(p_initial_header_rec.order_firmed_date  ,p_old_header_rec.order_firmed_date)
		AND (p_initial_header_rec.order_firmed_date IS NOT NULL OR p_old_header_rec.order_firmed_date IS NOT NULL))
           )   THEN
          p_x_header_rec.order_firmed_date := FND_API.G_MISS_DATE;
     END IF ;
   END order_firmed_date;
 -- end
       -----START bug 8517526
 PROCEDURE BLANKET_NUMBER IS
   BEGIN
   IF (p_initial_header_rec.blanket_number = FND_API.G_MISS_NUM OR
        (OE_GLOBAlS.Equal(p_initial_header_rec.blanket_number, p_old_header_rec.blanket_number)
          AND
        (p_old_header_rec.header_id IS NOT NULL OR p_initial_header_rec.blanket_number IS NOT NULL))
       )
   THEN
       p_x_header_rec.blanket_number := FND_API.G_MISS_NUM;

   END IF;
   END BLANKET_NUMBER;
 ---END BUG 8517526



BEGIN

	oe_debug_pub.add('Entering OE_HEADER_UTIL.Clear_Dependent',1);
	IF	p_src_attr_tbl.COUNT <> 0 THEN

		OE_Dependencies.Mark_Dependent
		(p_entity_code     => OE_GLOBALS.G_ENTITY_HEADER,
		p_source_attr_tbl => p_src_attr_tbl,
		p_dep_attr_tbl    => l_dep_attr_tbl);

		FOR I IN 1..l_dep_attr_tbl.COUNT LOOP
			IF l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_ACCOUNTING_RULE THEN
				ACCOUNTING_RULE;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_ACCOUNTING_RULE_DURATION THEN
					ACCOUNTING_RULE_DURATION;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_AGREEMENT THEN
					AGREEMENT;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_CONVERSION_RATE THEN
					CONVERSION_RATE;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_CONVERSION_RATE_DATE THEN
					CONVERSION_RATE_DATE;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_CONVERSION_TYPE THEN
					CONVERSION_TYPE;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_CREDIT_CARD_EXPIRATION_DATE THEN
					CREDIT_CARD_EXPIRATION_DATE;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_CREDIT_CARD_HOLDER_NAME THEN
					CREDIT_CARD_HOLDER_NAME;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_CREDIT_CARD_NUMBER THEN
					CREDIT_CARD_NUMBER;
                        /* Fix Bug # 2297053: Added to clear Credit Card Type */
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_CREDIT_CARD THEN
					CREDIT_CARD;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_CHECK_NUMBER THEN  --For bug 2692314
					CHECK_NUMBER;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_CUST_PO_NUMBER THEN
					CUST_PO_NUMBER;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_CUSTOMER_PREFERENCE_SET THEN
					CUSTOMER_PREFERENCE_SET_CODE;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_DEFAULT_FULFILLMENT_SET THEN
					DEFAULT_FULFILLMENT_SET;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_DELIVER_TO_CONTACT THEN
					DELIVER_TO_CONTACT;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_DELIVER_TO_ORG THEN
					DELIVER_TO_ORG;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_DEMAND_CLASS THEN
					DEMAND_CLASS;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_FOB_POINT THEN
					FOB_POINT;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_FREIGHT_TERMS THEN
					FREIGHT_TERMS;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_INVOICE_TO_CONTACT THEN
					INVOICE_TO_CONTACT;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_INVOICE_TO_ORG THEN
					INVOICE_TO_ORG;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_INVOICING_RULE THEN
					INVOICING_RULE;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_ORDER_CATEGORY THEN
					ORDER_CATEGORY;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_ORDER_DATE_TYPE_CODE THEN
					ORDER_DATE_TYPE;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_ORDER_TYPE THEN
					ORDER_TYPE;
			-- Added the call to the method to clear the payment amount bug 4360599
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_PAYMENT_AMOUNT THEN
					PAYMENT_AMOUNT;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_PAYMENT_TERM THEN
					PAYMENT_TERM;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_PRICE_LIST THEN
					PRICE_LIST;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_PRICE_REQUEST_CODE THEN -- PROMOTIONS SEP/01
					PRICE_REQUEST_CODE;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_REQUEST_DATE THEN
					REQUEST_DATE;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_SALESREP THEN
					SALESREP;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_SALES_CHANNEL THEN
					SALES_CHANNEL;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_SHIPMENT_PRIORITY THEN
					SHIPMENT_PRIORITY;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_SHIPPING_METHOD THEN
					SHIPPING_METHOD;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_SHIP_FROM_ORG THEN
					SHIP_FROM_ORG;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_SHIP_TOLERANCE_ABOVE THEN
					SHIP_TOLERANCE_ABOVE;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_SHIP_TOLERANCE_BELOW THEN
					SHIP_TOLERANCE_BELOW;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_SHIP_TO_CONTACT THEN
					SHIP_TO_CONTACT;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_SHIP_TO_ORG THEN
					SHIP_TO_ORG;
                        -- Fix bug 1753101: sold to contact dependency code added
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_SOLD_TO_CONTACT THEN
					SOLD_TO_CONTACT;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_SOLD_TO_ORG THEN
					SOLD_TO_ORG;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_SOLD_TO_PHONE THEN
					SOLD_TO_PHONE;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_TAX_EXEMPT_NUMBER THEN
					TAX_EXEMPT_NUMBER;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_TAX_EXEMPT_REASON THEN
					TAX_EXEMPT_REASON;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_TRANSACTIONAL_CURR THEN
					TRANSACTIONAL_CURR;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_LATEST_SCHEDULE_LIMIT THEN
					LATEST_SCHEDULE_LIMIT;
                        ELSIF   l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_PACKING_INSTRUCTIONS THEN
                                        PACKING_INSTRUCTIONS;  -- added for 2665264
                        ELSIF   l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_SHIPPING_INSTRUCTIONS THEN
                                        SHIPPING_INSTRUCTIONS;  -- added for 2766005

           -- QUOTING changes
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_TRANSACTION_PHASE THEN
                           IF OE_Code_Control.Code_Release_Level >= '110510' THEN
					TRANSACTION_PHASE;
                           END IF;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_SOLD_TO_SITE_USE THEN
                           IF OE_Code_Control.Code_Release_Level >= '110510' THEN
					SOLD_TO_SITE_USE;
                           END IF;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_QUOTE_DATE THEN
                           IF OE_Code_Control.Code_Release_Level >= '110510' THEN
					QUOTE_DATE;
                           END IF;
			ELSIF 	l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_ORDERED_DATE THEN
                           IF OE_Code_Control.Code_Release_Level >= '110510' THEN
					ORDERED_DATE;
                           END IF;
                        -- QUOTING changes END
			-- Distributed orders @
			ELSIF l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_END_CUSTOMER THEN
			   END_CUSTOMER;
			ELSIF l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_END_CUSTOMER_CONTACT THEN
			   END_CUSTOMER_CONTACT;
			ELSIF l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_END_CUSTOMER_SITE_USE THEN
			   END_CUSTOMER_SITE_USE;
                 	ELSIF l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_ORDER_FIRMED_DATE THEN     --Key Transaction Dates
                           IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110509' THEN
			      order_firmed_date;
			   END IF;
                        ELSIF l_dep_attr_tbl(I) = OE_HEADER_UTIL.G_BLANKET_NUMBER THEN   ---bug 8517526
                               BLANKET_NUMBER;      ---bug 8517526
		END IF;
	END LOOP;
   END IF;

	oe_debug_pub.add('Exiting OE_HEADER_UTIL.Clear_Dependent',1);

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	WHEN OTHERS THEN
		IF 	OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			OE_MSG_PUB.Add_Exc_Msg
			(   G_PKG_NAME
			,   'Clear_Dependents'
			);
		END IF;

		oe_debug_pub.add('Error : '||substr(sqlerrm,1,200),1);
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Clear_Dependents;

FUNCTION G_MISS_OE_AK_HEADER_REC
RETURN OE_AK_ORDER_HEADERS_V%ROWTYPE IS
	l_rowtype_rec					OE_AK_ORDER_HEADERS_V%ROWTYPE;
BEGIN

	l_rowtype_rec.ACCOUNTING_RULE_ID			:= FND_API.G_MISS_NUM;
	l_rowtype_rec.ACCOUNTING_RULE_DURATION			:= FND_API.G_MISS_NUM;
	l_rowtype_rec.AGREEMENT_ID					:= FND_API.G_MISS_NUM;
	l_rowtype_rec.ATTRIBUTE1					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.ATTRIBUTE10					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.ATTRIBUTE11					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.ATTRIBUTE12					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.ATTRIBUTE13					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.ATTRIBUTE14					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.ATTRIBUTE15					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.ATTRIBUTE16			  := FND_API.G_MISS_CHAR;   --For bug 2184255
	l_rowtype_rec.ATTRIBUTE17					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.ATTRIBUTE18					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.ATTRIBUTE19					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.ATTRIBUTE2					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.ATTRIBUTE20					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.ATTRIBUTE3					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.ATTRIBUTE4					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.ATTRIBUTE5					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.ATTRIBUTE6					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.ATTRIBUTE7					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.ATTRIBUTE8					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.ATTRIBUTE9					:= FND_API.G_MISS_CHAR;
        l_rowtype_rec.BLANKET_NUMBER                                    := FND_API.G_MISS_NUM;
	l_rowtype_rec.BOOKED_FLAG					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.BOOKED_DATE					:= FND_API.G_MISS_DATE;
	l_rowtype_rec.CANCELLED_FLAG				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.CHANGE_COMMENTS				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.CHANGE_REASON					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.CHECK_NUMBER					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.CONTEXT						:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.CONVERSION_RATE				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.CONVERSION_RATE_DATE			:= FND_API.G_MISS_DATE;
	l_rowtype_rec.CONVERSION_TYPE_CODE			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.CUSTOMER_PREFERENCE_SET_CODE	:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.CREATED_BY					:= FND_API.G_MISS_NUM;
	l_rowtype_rec.CREATION_DATE					:= FND_API.G_MISS_DATE;
	l_rowtype_rec.CREDIT_CARD_APPROVAL_CODE		:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.CREDIT_CARD_CODE				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.CREDIT_CARD_EXPIRATION_DATE	:= FND_API.G_MISS_DATE;
	l_rowtype_rec.CREDIT_CARD_APPROVAL_DATE		:= FND_API.G_MISS_DATE;
	l_rowtype_rec.CREDIT_CARD_HOLDER_NAME		:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.CREDIT_CARD_NUMBER			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.CUST_PO_NUMBER				:= FND_API.G_MISS_CHAR;
        l_rowtype_rec.DEFAULT_FULFILLMENT_SET                   := FND_API.G_MISS_CHAR;
	l_rowtype_rec.DB_FLAG					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.DELIVER_TO_CONTACT_ID			:= FND_API.G_MISS_NUM;
	l_rowtype_rec.DELIVER_TO_ORG_ID				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.DEMAND_CLASS_CODE				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.EARLIEST_SCHEDULE_LIMIT		:= FND_API.G_MISS_NUM;
	l_rowtype_rec.EXPIRATION_DATE				:= FND_API.G_MISS_DATE;
	l_rowtype_rec.FIRST_ACK_CODE				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.FIRST_ACK_DATE				:= FND_API.G_MISS_DATE;
	l_rowtype_rec.FOB_POINT_CODE				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.FREIGHT_CARRIER_CODE			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.FREIGHT_TERMS_CODE			:= FND_API.G_MISS_CHAR;
        l_rowtype_rec.FULFILLMENT_SET_NAME                      := FND_API.G_MISS_CHAR;
	l_rowtype_rec.GLOBAL_ATTRIBUTE1				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.GLOBAL_ATTRIBUTE10			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.GLOBAL_ATTRIBUTE11			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.GLOBAL_ATTRIBUTE12			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.GLOBAL_ATTRIBUTE13			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.GLOBAL_ATTRIBUTE14			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.GLOBAL_ATTRIBUTE15			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.GLOBAL_ATTRIBUTE16			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.GLOBAL_ATTRIBUTE17			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.GLOBAL_ATTRIBUTE18			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.GLOBAL_ATTRIBUTE19			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.GLOBAL_ATTRIBUTE2				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.GLOBAL_ATTRIBUTE20			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.GLOBAL_ATTRIBUTE3				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.GLOBAL_ATTRIBUTE4				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.GLOBAL_ATTRIBUTE5				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.GLOBAL_ATTRIBUTE6				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.GLOBAL_ATTRIBUTE7				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.GLOBAL_ATTRIBUTE8				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.GLOBAL_ATTRIBUTE9				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.GLOBAL_ATTRIBUTE_CATEGORY		:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.HEADER_ID						:= FND_API.G_MISS_NUM;
	l_rowtype_rec.INVOICE_TO_CONTACT_ID			:= FND_API.G_MISS_NUM;
	l_rowtype_rec.INVOICE_TO_ORG_ID				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.INVOICING_RULE_ID				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.LAST_ACK_CODE					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.LAST_ACK_DATE					:= FND_API.G_MISS_DATE;
	l_rowtype_rec.LAST_UPDATED_BY				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.LAST_UPDATE_DATE				:= FND_API.G_MISS_DATE;
	l_rowtype_rec.LAST_UPDATE_LOGIN				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.LATEST_SCHEDULE_LIMIT			:= FND_API.G_MISS_NUM;
        l_rowtype_rec.LINE_SET_NAME                             := FND_API.G_MISS_CHAR;
	l_rowtype_rec.OPEN_FLAG						:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.OPERATION						:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.ORDERED_DATE					:= FND_API.G_MISS_DATE;
	l_rowtype_rec.ORDER_DATE_TYPE_CODE			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.ORDER_NUMBER					:= FND_API.G_MISS_NUM;
	l_rowtype_rec.ORDER_SOURCE_ID				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.ORDER_TYPE_ID					:= FND_API.G_MISS_NUM;
	l_rowtype_rec.ORDER_CATEGORY_CODE 			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.ORG_ID						:= FND_API.G_MISS_NUM;
	l_rowtype_rec.ORIG_SYS_DOCUMENT_REF			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.PACKING_INSTRUCTIONS			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.PARTIAL_SHIPMENTS_ALLOWED		:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.PAYMENT_AMOUNT				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.PAYMENT_TERM_ID				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.PAYMENT_TYPE_CODE				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.PRICE_LIST_ID					:= FND_API.G_MISS_NUM;
	l_rowtype_rec.PRICE_REQUEST_CODE			:= FND_API.G_MISS_CHAR; -- PROMOTIONS SEP/01
	l_rowtype_rec.PRICING_DATE					:= FND_API.G_MISS_DATE;
	l_rowtype_rec.PROGRAM_APPLICATION_ID		:= FND_API.G_MISS_NUM;
	l_rowtype_rec.PROGRAM_ID					:= FND_API.G_MISS_NUM;
	l_rowtype_rec.PROGRAM_UPDATE_DATE			:= FND_API.G_MISS_DATE;
	l_rowtype_rec.REQUEST_DATE					:= FND_API.G_MISS_DATE;
	l_rowtype_rec.REQUEST_ID					:= FND_API.G_MISS_NUM;
	l_rowtype_rec.RETURN_REASON_CODE			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.upgraded_flag		          := FND_API.G_MISS_CHAR;
	l_rowtype_rec.RETURN_STATUS					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.SALESREP_ID					:= FND_API.G_MISS_NUM;
	l_rowtype_rec.SALES_CHANNEL_CODE				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.SHIPMENT_PRIORITY_CODE		:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.SHIPPING_INSTRUCTIONS			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.SHIPPING_METHOD_CODE			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.SHIP_FROM_ORG_ID				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.SHIP_TOLERANCE_ABOVE			:= FND_API.G_MISS_NUM;
	l_rowtype_rec.SHIP_TOLERANCE_BELOW			:= FND_API.G_MISS_NUM;
	l_rowtype_rec.SHIP_TO_CONTACT_ID			:= FND_API.G_MISS_NUM;
	l_rowtype_rec.SHIP_TO_ORG_ID				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.SOLD_FROM_ORG_ID				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.SOLD_TO_CONTACT_ID			:= FND_API.G_MISS_NUM;
	l_rowtype_rec.SOLD_TO_ORG_ID				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.SOURCE_DOCUMENT_ID			:= FND_API.G_MISS_NUM;
	l_rowtype_rec.SOURCE_DOCUMENT_TYPE_ID		:= FND_API.G_MISS_NUM;
	l_rowtype_rec.TAX_EXEMPT_FLAG				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.TAX_EXEMPT_NUMBER				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.TAX_EXEMPT_REASON_CODE		:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.TAX_POINT_CODE				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.TRANSACTIONAL_CURR_CODE		:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.VERSION_NUMBER				:= FND_API.G_MISS_NUM;
	l_rowtype_rec.TP_ATTRIBUTE1					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.TP_ATTRIBUTE10				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.TP_ATTRIBUTE11				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.TP_ATTRIBUTE12				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.TP_ATTRIBUTE13				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.TP_ATTRIBUTE14				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.TP_ATTRIBUTE15				:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.TP_ATTRIBUTE2					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.TP_ATTRIBUTE3					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.TP_ATTRIBUTE4					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.TP_ATTRIBUTE5					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.TP_ATTRIBUTE6					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.TP_ATTRIBUTE7					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.TP_ATTRIBUTE8					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.TP_ATTRIBUTE9					:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.TP_CONTEXT       				:= FND_API.G_MISS_CHAR;

    --QUOTING changes
	l_rowtype_rec.TRANSACTION_PHASE_CODE       		:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.USER_STATUS_CODE       			:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.QUOTE_NUMBER       			:= FND_API.G_MISS_NUM;
	l_rowtype_rec.QUOTE_DATE     				:= FND_API.G_MISS_DATE;
	l_rowtype_rec.SALES_DOCUMENT_NAME       		:= FND_API.G_MISS_CHAR;
	l_rowtype_rec.SOLD_TO_SITE_USE_ID       		:= FND_API.G_MISS_NUM;
	l_rowtype_rec.SOURCE_DOCUMENT_VERSION_NUMBER   		:= FND_API.G_MISS_NUM;
	l_rowtype_rec.DRAFT_SUBMITTED_FLAG       		:= FND_API.G_MISS_CHAR;
        -- QUOTING changes END
        --Key Transaction Dates
        l_rowtype_rec.order_firmed_date                         := FND_API.G_MISS_DATE;

	RETURN l_rowtype_rec;

EXCEPTION

	WHEN OTHERS THEN
		IF 	OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			OE_MSG_PUB.Add_Exc_Msg
			(   G_PKG_NAME
			,   'G_MISS_OE_AK_HEADER_REC'
			);
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END G_MISS_OE_AK_HEADER_REC;

PROCEDURE API_Rec_To_Rowtype_Rec
(   p_HEADER_rec                    IN  OE_Order_PUB.HEADER_Rec_Type
,   x_rowtype_rec                   IN OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
) IS
BEGIN

	x_rowtype_rec.ACCOUNTING_RULE_ID       := p_header_rec.ACCOUNTING_RULE_ID;
	x_rowtype_rec.ACCOUNTING_RULE_DURATION := p_header_rec.ACCOUNTING_RULE_DURATION;
	x_rowtype_rec.AGREEMENT_ID             := p_header_rec.AGREEMENT_ID;
	x_rowtype_rec.ATTRIBUTE1               := p_header_rec.ATTRIBUTE1;
	x_rowtype_rec.ATTRIBUTE10              := p_header_rec.ATTRIBUTE10;
	x_rowtype_rec.ATTRIBUTE11              := p_header_rec.ATTRIBUTE11;
	x_rowtype_rec.ATTRIBUTE12              := p_header_rec.ATTRIBUTE12;
	x_rowtype_rec.ATTRIBUTE13              := p_header_rec.ATTRIBUTE13;
	x_rowtype_rec.ATTRIBUTE14              := p_header_rec.ATTRIBUTE14;
	x_rowtype_rec.ATTRIBUTE15              := p_header_rec.ATTRIBUTE15;
	x_rowtype_rec.ATTRIBUTE16              := p_header_rec.ATTRIBUTE16;   --For bug 2184255
	x_rowtype_rec.ATTRIBUTE17              := p_header_rec.ATTRIBUTE17;
	x_rowtype_rec.ATTRIBUTE18              := p_header_rec.ATTRIBUTE18;
	x_rowtype_rec.ATTRIBUTE19              := p_header_rec.ATTRIBUTE19;
	x_rowtype_rec.ATTRIBUTE2               := p_header_rec.ATTRIBUTE2;
	x_rowtype_rec.ATTRIBUTE20              := p_header_rec.ATTRIBUTE20;
	x_rowtype_rec.ATTRIBUTE3               := p_header_rec.ATTRIBUTE3;
	x_rowtype_rec.ATTRIBUTE4               := p_header_rec.ATTRIBUTE4;
	x_rowtype_rec.ATTRIBUTE5               := p_header_rec.ATTRIBUTE5;
	x_rowtype_rec.ATTRIBUTE6               := p_header_rec.ATTRIBUTE6;
	x_rowtype_rec.ATTRIBUTE7               := p_header_rec.ATTRIBUTE7;
	x_rowtype_rec.ATTRIBUTE8               := p_header_rec.ATTRIBUTE8;
	x_rowtype_rec.ATTRIBUTE9               := p_header_rec.ATTRIBUTE9;
	x_rowtype_rec.upgraded_flag            := p_header_rec.upgraded_flag;
        x_rowtype_rec.BLANKET_NUMBER           := p_header_rec.BLANKET_NUMBER;
	x_rowtype_rec.BOOKED_FLAG              := p_header_rec.BOOKED_FLAG;
	x_rowtype_rec.BOOKED_DATE              := p_header_rec.BOOKED_DATE;
	x_rowtype_rec.CANCELLED_FLAG           := p_header_rec.CANCELLED_FLAG;
	x_rowtype_rec.CHANGE_COMMENTS          := p_header_rec.CHANGE_COMMENTS;
	x_rowtype_rec.CHANGE_REASON            := p_header_rec.CHANGE_REASON;
	x_rowtype_rec.CHECK_NUMBER             := p_header_rec.CHECK_NUMBER;
	x_rowtype_rec.CONTEXT                  := p_header_rec.CONTEXT;
	x_rowtype_rec.CONVERSION_RATE          := p_header_rec.CONVERSION_RATE;
	x_rowtype_rec.CONVERSION_RATE_DATE     := p_header_rec.CONVERSION_RATE_DATE;
	x_rowtype_rec.CONVERSION_TYPE_CODE     := p_header_rec.CONVERSION_TYPE_CODE;
	x_rowtype_rec.CUSTOMER_PREFERENCE_SET_CODE := p_header_rec.CUSTOMER_PREFERENCE_SET_CODE;
	x_rowtype_rec.CREATED_BY               := p_header_rec.CREATED_BY;
	x_rowtype_rec.CREATION_DATE            := p_header_rec.CREATION_DATE;
	x_rowtype_rec.CREDIT_CARD_APPROVAL_CODE := p_header_rec.CREDIT_CARD_APPROVAL_CODE;
	x_rowtype_rec.CREDIT_CARD_CODE         := p_header_rec.CREDIT_CARD_CODE;
	x_rowtype_rec.CREDIT_CARD_EXPIRATION_DATE := p_header_rec.CREDIT_CARD_EXPIRATION_DATE;
	x_rowtype_rec.CREDIT_CARD_APPROVAL_DATE := p_header_rec.CREDIT_CARD_APPROVAL_DATE;
	x_rowtype_rec.CREDIT_CARD_HOLDER_NAME  := p_header_rec.CREDIT_CARD_HOLDER_NAME;
	x_rowtype_rec.CREDIT_CARD_NUMBER       := p_header_rec.CREDIT_CARD_NUMBER;
	x_rowtype_rec.CUST_PO_NUMBER           := p_header_rec.CUST_PO_NUMBER;
        x_rowtype_rec.DEFAULT_FULFILLMENT_SET := p_header_rec.DEFAULT_FULFILLMENT_SET;
	x_rowtype_rec.DB_FLAG                  := p_header_rec.DB_FLAG;
	x_rowtype_rec.DELIVER_TO_CONTACT_ID    := p_header_rec.DELIVER_TO_CONTACT_ID;
	x_rowtype_rec.DELIVER_TO_ORG_ID        := p_header_rec.DELIVER_TO_ORG_ID;
	x_rowtype_rec.DEMAND_CLASS_CODE        := p_header_rec.DEMAND_CLASS_CODE;
	x_rowtype_rec.EARLIEST_SCHEDULE_LIMIT  := p_header_rec.EARLIEST_SCHEDULE_LIMIT;
	x_rowtype_rec.EXPIRATION_DATE          := p_header_rec.EXPIRATION_DATE;
	x_rowtype_rec.FIRST_ACK_CODE           := p_header_rec.FIRST_ACK_CODE;
	x_rowtype_rec.FIRST_ACK_DATE           := p_header_rec.FIRST_ACK_DATE;
	x_rowtype_rec.FOB_POINT_CODE           := p_header_rec.FOB_POINT_CODE;
	x_rowtype_rec.FREIGHT_CARRIER_CODE     := p_header_rec.FREIGHT_CARRIER_CODE;
	x_rowtype_rec.FREIGHT_TERMS_CODE       := p_header_rec.FREIGHT_TERMS_CODE;
        x_rowtype_rec.FULFILLMENT_SET_NAME     := p_header_rec.FULFILLMENT_SET_NAME;
	x_rowtype_rec.GLOBAL_ATTRIBUTE1        := p_header_rec.GLOBAL_ATTRIBUTE1;
	x_rowtype_rec.GLOBAL_ATTRIBUTE10       := p_header_rec.GLOBAL_ATTRIBUTE10;
	x_rowtype_rec.GLOBAL_ATTRIBUTE11       := p_header_rec.GLOBAL_ATTRIBUTE11;
	x_rowtype_rec.GLOBAL_ATTRIBUTE12       := p_header_rec.GLOBAL_ATTRIBUTE12;
	x_rowtype_rec.GLOBAL_ATTRIBUTE13       := p_header_rec.GLOBAL_ATTRIBUTE13;
	x_rowtype_rec.GLOBAL_ATTRIBUTE14       := p_header_rec.GLOBAL_ATTRIBUTE14;
	x_rowtype_rec.GLOBAL_ATTRIBUTE15       := p_header_rec.GLOBAL_ATTRIBUTE15;
	x_rowtype_rec.GLOBAL_ATTRIBUTE16       := p_header_rec.GLOBAL_ATTRIBUTE16;
	x_rowtype_rec.GLOBAL_ATTRIBUTE17       := p_header_rec.GLOBAL_ATTRIBUTE17;
	x_rowtype_rec.GLOBAL_ATTRIBUTE18       := p_header_rec.GLOBAL_ATTRIBUTE18;
	x_rowtype_rec.GLOBAL_ATTRIBUTE19       := p_header_rec.GLOBAL_ATTRIBUTE19;
	x_rowtype_rec.GLOBAL_ATTRIBUTE2        := p_header_rec.GLOBAL_ATTRIBUTE2;
	x_rowtype_rec.GLOBAL_ATTRIBUTE20       := p_header_rec.GLOBAL_ATTRIBUTE20;
	x_rowtype_rec.GLOBAL_ATTRIBUTE3        := p_header_rec.GLOBAL_ATTRIBUTE3;
	x_rowtype_rec.GLOBAL_ATTRIBUTE4        := p_header_rec.GLOBAL_ATTRIBUTE4;
	x_rowtype_rec.GLOBAL_ATTRIBUTE5        := p_header_rec.GLOBAL_ATTRIBUTE5;
	x_rowtype_rec.GLOBAL_ATTRIBUTE6        := p_header_rec.GLOBAL_ATTRIBUTE6;
	x_rowtype_rec.GLOBAL_ATTRIBUTE7        := p_header_rec.GLOBAL_ATTRIBUTE7;
	x_rowtype_rec.GLOBAL_ATTRIBUTE8        := p_header_rec.GLOBAL_ATTRIBUTE8;
	x_rowtype_rec.GLOBAL_ATTRIBUTE9        := p_header_rec.GLOBAL_ATTRIBUTE9;
	x_rowtype_rec.GLOBAL_ATTRIBUTE_CATEGORY := p_header_rec.GLOBAL_ATTRIBUTE_CATEGORY;
	x_rowtype_rec.HEADER_ID                := p_header_rec.HEADER_ID;
	x_rowtype_rec.INVOICE_TO_CONTACT_ID    := p_header_rec.INVOICE_TO_CONTACT_ID;
	x_rowtype_rec.INVOICE_TO_ORG_ID        := p_header_rec.INVOICE_TO_ORG_ID;
	x_rowtype_rec.INVOICING_RULE_ID        := p_header_rec.INVOICING_RULE_ID;
	x_rowtype_rec.LAST_ACK_CODE            := p_header_rec.LAST_ACK_CODE;
	x_rowtype_rec.LAST_ACK_DATE            := p_header_rec.LAST_ACK_DATE;
	x_rowtype_rec.LAST_UPDATED_BY          := p_header_rec.LAST_UPDATED_BY;
	x_rowtype_rec.LAST_UPDATE_DATE         := p_header_rec.LAST_UPDATE_DATE;
	x_rowtype_rec.LAST_UPDATE_LOGIN        := p_header_rec.LAST_UPDATE_LOGIN;
	x_rowtype_rec.LATEST_SCHEDULE_LIMIT    := p_header_rec.LATEST_SCHEDULE_LIMIT;
        x_rowtype_rec.LINE_SET_NAME            := p_header_rec.LINE_SET_NAME;
	x_rowtype_rec.OPEN_FLAG                := p_header_rec.OPEN_FLAG;
	x_rowtype_rec.OPERATION                := p_header_rec.OPERATION;
	x_rowtype_rec.ORDERED_DATE             := p_header_rec.ORDERED_DATE;
	x_rowtype_rec.ORDER_DATE_TYPE_CODE     := p_header_rec.ORDER_DATE_TYPE_CODE;
	x_rowtype_rec.ORDER_NUMBER             := p_header_rec.ORDER_NUMBER;
	x_rowtype_rec.ORDER_SOURCE_ID          := p_header_rec.ORDER_SOURCE_ID;
	x_rowtype_rec.ORDER_TYPE_ID            := p_header_rec.ORDER_TYPE_ID;
	x_rowtype_rec.ORDER_CATEGORY_CODE      := p_header_rec.ORDER_CATEGORY_CODE;
	x_rowtype_rec.ORG_ID                   := p_header_rec.ORG_ID;
	x_rowtype_rec.ORIG_SYS_DOCUMENT_REF    := p_header_rec.ORIG_SYS_DOCUMENT_REF;
	x_rowtype_rec.PACKING_INSTRUCTIONS     := p_header_rec.PACKING_INSTRUCTIONS;
	x_rowtype_rec.PARTIAL_SHIPMENTS_ALLOWED := p_header_rec.PARTIAL_SHIPMENTS_ALLOWED;
	x_rowtype_rec.PAYMENT_AMOUNT           := p_header_rec.PAYMENT_AMOUNT;
	x_rowtype_rec.PAYMENT_TERM_ID          := p_header_rec.PAYMENT_TERM_ID;
	x_rowtype_rec.PAYMENT_TYPE_CODE        := p_header_rec.PAYMENT_TYPE_CODE;
	x_rowtype_rec.PRICE_LIST_ID            := p_header_rec.PRICE_LIST_ID;
	x_rowtype_rec.PRICE_REQUEST_CODE       := p_header_rec.PRICE_REQUEST_CODE; -- PROMOTIONS SEP/01
	x_rowtype_rec.PRICING_DATE             := p_header_rec.PRICING_DATE;
	x_rowtype_rec.PROGRAM_APPLICATION_ID   := p_header_rec.PROGRAM_APPLICATION_ID;
	x_rowtype_rec.PROGRAM_ID               := p_header_rec.PROGRAM_ID;
	x_rowtype_rec.PROGRAM_UPDATE_DATE      := p_header_rec.PROGRAM_UPDATE_DATE;
	x_rowtype_rec.REQUEST_DATE             := p_header_rec.REQUEST_DATE;
	x_rowtype_rec.REQUEST_ID               := p_header_rec.REQUEST_ID;
	x_rowtype_rec.RETURN_REASON_CODE       := p_header_rec.RETURN_REASON_CODE;
	x_rowtype_rec.RETURN_STATUS            := p_header_rec.RETURN_STATUS;
	x_rowtype_rec.SALESREP_ID              := p_header_rec.SALESREP_ID;
	x_rowtype_rec.SALES_CHANNEL_CODE       := p_header_rec.SALES_CHANNEL_CODE;
	x_rowtype_rec.SHIPMENT_PRIORITY_CODE   := p_header_rec.SHIPMENT_PRIORITY_CODE;
	x_rowtype_rec.SHIPPING_INSTRUCTIONS    := p_header_rec.SHIPPING_INSTRUCTIONS;
	x_rowtype_rec.SHIPPING_METHOD_CODE     := p_header_rec.SHIPPING_METHOD_CODE;
	x_rowtype_rec.SHIP_FROM_ORG_ID         := p_header_rec.SHIP_FROM_ORG_ID;
	x_rowtype_rec.SHIP_TOLERANCE_ABOVE     := p_header_rec.SHIP_TOLERANCE_ABOVE;
	x_rowtype_rec.SHIP_TOLERANCE_BELOW     := p_header_rec.SHIP_TOLERANCE_BELOW;
	x_rowtype_rec.SHIP_TO_CONTACT_ID       := p_header_rec.SHIP_TO_CONTACT_ID;
	x_rowtype_rec.SHIP_TO_ORG_ID           := p_header_rec.SHIP_TO_ORG_ID;
	x_rowtype_rec.SOLD_FROM_ORG_ID         := p_header_rec.SOLD_FROM_ORG_ID;
	x_rowtype_rec.SOLD_TO_CONTACT_ID       := p_header_rec.SOLD_TO_CONTACT_ID;
	x_rowtype_rec.SOLD_TO_ORG_ID           := p_header_rec.SOLD_TO_ORG_ID;
	x_rowtype_rec.SOURCE_DOCUMENT_ID       := p_header_rec.SOURCE_DOCUMENT_ID;
	x_rowtype_rec.SOURCE_DOCUMENT_TYPE_ID  := p_header_rec.SOURCE_DOCUMENT_TYPE_ID;
	x_rowtype_rec.TAX_EXEMPT_FLAG          := p_header_rec.TAX_EXEMPT_FLAG;
	x_rowtype_rec.TAX_EXEMPT_NUMBER        := p_header_rec.TAX_EXEMPT_NUMBER;
	x_rowtype_rec.TAX_EXEMPT_REASON_CODE   := p_header_rec.TAX_EXEMPT_REASON_CODE;
	x_rowtype_rec.TAX_POINT_CODE           := p_header_rec.TAX_POINT_CODE;
	x_rowtype_rec.TRANSACTIONAL_CURR_CODE  := p_header_rec.TRANSACTIONAL_CURR_CODE;
	x_rowtype_rec.VERSION_NUMBER           := p_header_rec.VERSION_NUMBER;
	x_rowtype_rec.FLOW_STATUS_CODE         := p_header_rec.FLOW_STATUS_CODE;
	x_rowtype_rec.TP_ATTRIBUTE1            := p_header_rec.TP_ATTRIBUTE1;
	x_rowtype_rec.TP_ATTRIBUTE10           := p_header_rec.TP_ATTRIBUTE10;
	x_rowtype_rec.TP_ATTRIBUTE11           := p_header_rec.TP_ATTRIBUTE11;
	x_rowtype_rec.TP_ATTRIBUTE12           := p_header_rec.TP_ATTRIBUTE12;
	x_rowtype_rec.TP_ATTRIBUTE13           := p_header_rec.TP_ATTRIBUTE13;
	x_rowtype_rec.TP_ATTRIBUTE14           := p_header_rec.TP_ATTRIBUTE14;
	x_rowtype_rec.TP_ATTRIBUTE15           := p_header_rec.TP_ATTRIBUTE15;
	x_rowtype_rec.TP_ATTRIBUTE2            := p_header_rec.TP_ATTRIBUTE2;
	x_rowtype_rec.TP_ATTRIBUTE3            := p_header_rec.TP_ATTRIBUTE3;
	x_rowtype_rec.TP_ATTRIBUTE4            := p_header_rec.TP_ATTRIBUTE4;
	x_rowtype_rec.TP_ATTRIBUTE5            := p_header_rec.TP_ATTRIBUTE5;
	x_rowtype_rec.TP_ATTRIBUTE6            := p_header_rec.TP_ATTRIBUTE6;
	x_rowtype_rec.TP_ATTRIBUTE7            := p_header_rec.TP_ATTRIBUTE7;
	x_rowtype_rec.TP_ATTRIBUTE8            := p_header_rec.TP_ATTRIBUTE8;
	x_rowtype_rec.TP_ATTRIBUTE9            := p_header_rec.TP_ATTRIBUTE9;
	x_rowtype_rec.TP_CONTEXT               := p_header_rec.TP_CONTEXT;

     -- QUOTING changes
        x_rowtype_rec.quote_date               := p_header_rec.quote_date;
        x_rowtype_rec.quote_number             := p_header_rec.quote_number;
        x_rowtype_rec.sales_document_name      := p_header_rec.sales_document_name;
        x_rowtype_rec.transaction_phase_code   := p_header_rec.transaction_phase_code;
        x_rowtype_rec.user_status_code         := p_header_rec.user_status_code;
        x_rowtype_rec.draft_submitted_flag     := p_header_rec.draft_submitted_flag;
        x_rowtype_rec.source_document_version_number := p_header_rec.source_document_version_number;
        x_rowtype_rec.sold_to_site_use_id      := p_header_rec.sold_to_site_use_id;
        -- QUOTING changes END
       x_rowtype_rec.IB_OWNER                 := p_header_rec.IB_OWNER;
        x_rowtype_rec.IB_INSTALLED_AT_LOCATION := p_header_rec.IB_INSTALLED_AT_LOCATION;
        x_rowtype_rec.IB_CURRENT_LOCATION      := p_header_rec.IB_CURRENT_LOCATION;
        x_rowtype_rec.END_CUSTOMER_ID          := p_header_rec.END_CUSTOMER_ID;
        x_rowtype_rec.END_CUSTOMER_CONTACT_ID  := p_header_rec.END_CUSTOMER_CONTACT_ID;
        x_rowtype_rec.END_CUSTOMER_SITE_USE_ID := p_header_rec.END_CUSTOMER_SITE_USE_ID;
        x_rowtype_rec.CUSTOMER_SIGNATURE := p_header_rec.CUSTOMER_SIGNATURE;
        x_rowtype_rec.CUSTOMER_SIGNATURE_DATE := p_header_rec.CUSTOMER_SIGNATURE_DATE;
        x_rowtype_rec.SUPPLIER_SIGNATURE := p_header_rec.SUPPLIER_SIGNATURE;
        x_rowtype_rec.SUPPLIER_SIGNATURE_DATE := p_header_rec.SUPPLIER_SIGNATURE_DATE;
        --key Transaction Dates
        x_rowtype_rec.order_firmed_date       := p_header_rec.order_firmed_date;

EXCEPTION

	WHEN OTHERS THEN
 		IF 	OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
   			OE_MSG_PUB.Add_Exc_Msg
         	(   G_PKG_NAME
         	,   'API_Rec_To_RowType_Rec'
         	);
     	END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END API_Rec_To_RowType_Rec;

PROCEDURE Rowtype_Rec_To_API_Rec
(   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
,   x_api_rec                       IN OUT NOCOPY OE_Order_PUB.HEADER_Rec_Type
) IS
BEGIN

	x_api_rec.ACCOUNTING_RULE_ID       := p_record.ACCOUNTING_RULE_ID;
	x_api_rec.ACCOUNTING_RULE_DURATION := p_record.ACCOUNTING_RULE_DURATION;
	x_api_rec.AGREEMENT_ID             := p_record.AGREEMENT_ID;
	x_api_rec.ATTRIBUTE1               := p_record.ATTRIBUTE1;
	x_api_rec.ATTRIBUTE10              := p_record.ATTRIBUTE10;
	x_api_rec.ATTRIBUTE11              := p_record.ATTRIBUTE11;
	x_api_rec.ATTRIBUTE12              := p_record.ATTRIBUTE12;
	x_api_rec.ATTRIBUTE13              := p_record.ATTRIBUTE13;
	x_api_rec.ATTRIBUTE14              := p_record.ATTRIBUTE14;
	x_api_rec.ATTRIBUTE15              := p_record.ATTRIBUTE15;
	x_api_rec.ATTRIBUTE16              := p_record.ATTRIBUTE16;   --For bug 2184255
	x_api_rec.ATTRIBUTE17              := p_record.ATTRIBUTE17;
	x_api_rec.ATTRIBUTE18              := p_record.ATTRIBUTE18;
	x_api_rec.ATTRIBUTE19              := p_record.ATTRIBUTE19;
	x_api_rec.ATTRIBUTE2               := p_record.ATTRIBUTE2;
	x_api_rec.ATTRIBUTE20              := p_record.ATTRIBUTE20;
	x_api_rec.ATTRIBUTE3               := p_record.ATTRIBUTE3;
	x_api_rec.ATTRIBUTE4               := p_record.ATTRIBUTE4;
	x_api_rec.ATTRIBUTE5               := p_record.ATTRIBUTE5;
	x_api_rec.ATTRIBUTE6               := p_record.ATTRIBUTE6;
	x_api_rec.ATTRIBUTE7               := p_record.ATTRIBUTE7;
	x_api_rec.ATTRIBUTE8               := p_record.ATTRIBUTE8;
	x_api_rec.ATTRIBUTE9               := p_record.ATTRIBUTE9;
        x_api_rec.BLANKET_NUMBER           := p_record.BLANKET_NUMBER;
	x_api_rec.BOOKED_FLAG              := p_record.BOOKED_FLAG;
	x_api_rec.BOOKED_DATE              := p_record.BOOKED_DATE;
	x_api_rec.CANCELLED_FLAG           := p_record.CANCELLED_FLAG;
	x_api_rec.CHANGE_COMMENTS          := p_record.CHANGE_COMMENTS;
	x_api_rec.CHANGE_REASON            := p_record.CHANGE_REASON;
	x_api_rec.CHECK_NUMBER             := p_record.CHECK_NUMBER;
	x_api_rec.CONTEXT                  := p_record.CONTEXT;
	x_api_rec.CONVERSION_RATE          := p_record.CONVERSION_RATE;
	x_api_rec.CONVERSION_RATE_DATE     := p_record.CONVERSION_RATE_DATE;
	x_api_rec.CONVERSION_TYPE_CODE     := p_record.CONVERSION_TYPE_CODE;
	x_api_rec.upgraded_flag            := p_record.upgraded_flag;
	x_api_rec.CUSTOMER_PREFERENCE_SET_CODE  := p_record.CUSTOMER_PREFERENCE_SET_CODE;
	x_api_rec.CREATED_BY               := p_record.CREATED_BY;
	x_api_rec.CREATION_DATE            := p_record.CREATION_DATE;
	x_api_rec.CREDIT_CARD_APPROVAL_CODE := p_record.CREDIT_CARD_APPROVAL_CODE;
	x_api_rec.CREDIT_CARD_CODE         := p_record.CREDIT_CARD_CODE;
	x_api_rec.CREDIT_CARD_EXPIRATION_DATE := p_record.CREDIT_CARD_EXPIRATION_DATE;
	x_api_rec.CREDIT_CARD_APPROVAL_DATE := p_record.CREDIT_CARD_APPROVAL_DATE;
	x_api_rec.CREDIT_CARD_HOLDER_NAME  := p_record.CREDIT_CARD_HOLDER_NAME;
	x_api_rec.CREDIT_CARD_NUMBER       := p_record.CREDIT_CARD_NUMBER;
	x_api_rec.CUST_PO_NUMBER           := p_record.CUST_PO_NUMBER;
	x_api_rec.DB_FLAG                  := p_record.DB_FLAG;
        x_api_rec.DEFAULT_FULFILLMENT_SET  := p_record.DEFAULT_FULFILLMENT_SET;
	x_api_rec.DELIVER_TO_CONTACT_ID    := p_record.DELIVER_TO_CONTACT_ID;
	x_api_rec.DELIVER_TO_ORG_ID        := p_record.DELIVER_TO_ORG_ID;
	x_api_rec.DEMAND_CLASS_CODE        := p_record.DEMAND_CLASS_CODE;
	x_api_rec.EARLIEST_SCHEDULE_LIMIT  := p_record.EARLIEST_SCHEDULE_LIMIT;
	x_api_rec.EXPIRATION_DATE          := p_record.EXPIRATION_DATE;
	x_api_rec.FIRST_ACK_CODE           := p_record.FIRST_ACK_CODE;
	x_api_rec.FIRST_ACK_DATE           := p_record.FIRST_ACK_DATE;
	x_api_rec.FOB_POINT_CODE           := p_record.FOB_POINT_CODE;
	x_api_rec.FREIGHT_CARRIER_CODE     := p_record.FREIGHT_CARRIER_CODE;
	x_api_rec.FREIGHT_TERMS_CODE       := p_record.FREIGHT_TERMS_CODE;
        x_api_rec.FULFILLMENT_SET_NAME     := p_record.FULFILLMENT_SET_NAME;
	x_api_rec.GLOBAL_ATTRIBUTE1        := p_record.GLOBAL_ATTRIBUTE1;
	x_api_rec.GLOBAL_ATTRIBUTE10       := p_record.GLOBAL_ATTRIBUTE10;
	x_api_rec.GLOBAL_ATTRIBUTE11       := p_record.GLOBAL_ATTRIBUTE11;
	x_api_rec.GLOBAL_ATTRIBUTE12       := p_record.GLOBAL_ATTRIBUTE12;
	x_api_rec.GLOBAL_ATTRIBUTE13       := p_record.GLOBAL_ATTRIBUTE13;
	x_api_rec.GLOBAL_ATTRIBUTE14       := p_record.GLOBAL_ATTRIBUTE14;
	x_api_rec.GLOBAL_ATTRIBUTE15       := p_record.GLOBAL_ATTRIBUTE15;
	x_api_rec.GLOBAL_ATTRIBUTE16       := p_record.GLOBAL_ATTRIBUTE16;
	x_api_rec.GLOBAL_ATTRIBUTE17       := p_record.GLOBAL_ATTRIBUTE17;
	x_api_rec.GLOBAL_ATTRIBUTE18       := p_record.GLOBAL_ATTRIBUTE18;
	x_api_rec.GLOBAL_ATTRIBUTE19       := p_record.GLOBAL_ATTRIBUTE19;
	x_api_rec.GLOBAL_ATTRIBUTE2        := p_record.GLOBAL_ATTRIBUTE2;
	x_api_rec.GLOBAL_ATTRIBUTE20       := p_record.GLOBAL_ATTRIBUTE20;
	x_api_rec.GLOBAL_ATTRIBUTE3        := p_record.GLOBAL_ATTRIBUTE3;
	x_api_rec.GLOBAL_ATTRIBUTE4        := p_record.GLOBAL_ATTRIBUTE4;
	x_api_rec.GLOBAL_ATTRIBUTE5        := p_record.GLOBAL_ATTRIBUTE5;
	x_api_rec.GLOBAL_ATTRIBUTE6        := p_record.GLOBAL_ATTRIBUTE6;
	x_api_rec.GLOBAL_ATTRIBUTE7        := p_record.GLOBAL_ATTRIBUTE7;
	x_api_rec.GLOBAL_ATTRIBUTE8        := p_record.GLOBAL_ATTRIBUTE8;
	x_api_rec.GLOBAL_ATTRIBUTE9        := p_record.GLOBAL_ATTRIBUTE9;
	x_api_rec.GLOBAL_ATTRIBUTE_CATEGORY := p_record.GLOBAL_ATTRIBUTE_CATEGORY;
	x_api_rec.HEADER_ID                := p_record.HEADER_ID;
	x_api_rec.INVOICE_TO_CONTACT_ID    := p_record.INVOICE_TO_CONTACT_ID;
	x_api_rec.INVOICE_TO_ORG_ID        := p_record.INVOICE_TO_ORG_ID;
	x_api_rec.INVOICING_RULE_ID        := p_record.INVOICING_RULE_ID;
	x_api_rec.LAST_ACK_CODE            := p_record.LAST_ACK_CODE;
	x_api_rec.LAST_ACK_DATE            := p_record.LAST_ACK_DATE;
	x_api_rec.LAST_UPDATED_BY          := p_record.LAST_UPDATED_BY;
	x_api_rec.LAST_UPDATE_DATE         := p_record.LAST_UPDATE_DATE;
	x_api_rec.LAST_UPDATE_LOGIN        := p_record.LAST_UPDATE_LOGIN;
	x_api_rec.LATEST_SCHEDULE_LIMIT    := p_record.LATEST_SCHEDULE_LIMIT;
        x_api_rec.LINE_SET_NAME            := p_record.LINE_SET_NAME;
	x_api_rec.OPEN_FLAG                := p_record.OPEN_FLAG;
	x_api_rec.OPERATION                := p_record.OPERATION;
	x_api_rec.ORDERED_DATE             := p_record.ORDERED_DATE;
	x_api_rec.ORDER_DATE_TYPE_CODE     := p_record.ORDER_DATE_TYPE_CODE;
	x_api_rec.ORDER_NUMBER             := p_record.ORDER_NUMBER;
	x_api_rec.ORDER_SOURCE_ID          := p_record.ORDER_SOURCE_ID;
	x_api_rec.ORDER_TYPE_ID            := p_record.ORDER_TYPE_ID;
	x_api_rec.ORDER_CATEGORY_CODE      := p_record.ORDER_CATEGORY_CODE;
	x_api_rec.ORG_ID                   := p_record.ORG_ID;
	x_api_rec.ORIG_SYS_DOCUMENT_REF    := p_record.ORIG_SYS_DOCUMENT_REF;
	x_api_rec.PACKING_INSTRUCTIONS     := p_record.PACKING_INSTRUCTIONS;
	x_api_rec.PARTIAL_SHIPMENTS_ALLOWED := p_record.PARTIAL_SHIPMENTS_ALLOWED;
	x_api_rec.PAYMENT_AMOUNT           := p_record.PAYMENT_AMOUNT;
	x_api_rec.PAYMENT_TERM_ID          := p_record.PAYMENT_TERM_ID;
	x_api_rec.PAYMENT_TYPE_CODE        := p_record.PAYMENT_TYPE_CODE;
	x_api_rec.PRICE_LIST_ID            := p_record.PRICE_LIST_ID;
	x_api_rec.PRICE_REQUEST_CODE       := p_record.PRICE_REQUEST_CODE; -- PROMOTIONS SEP/01
	x_api_rec.PRICING_DATE             := p_record.PRICING_DATE;
	x_api_rec.PROGRAM_APPLICATION_ID   := p_record.PROGRAM_APPLICATION_ID;
	x_api_rec.PROGRAM_ID               := p_record.PROGRAM_ID;
	x_api_rec.PROGRAM_UPDATE_DATE      := p_record.PROGRAM_UPDATE_DATE;
	x_api_rec.REQUEST_DATE             := p_record.REQUEST_DATE;
	x_api_rec.REQUEST_ID               := p_record.REQUEST_ID;
	x_api_rec.RETURN_REASON_CODE       := p_record.RETURN_REASON_CODE;
	x_api_rec.RETURN_STATUS            := p_record.RETURN_STATUS;
	x_api_rec.SALESREP_ID              := p_record.SALESREP_ID;
	x_api_rec.SALES_CHANNEL_CODE       := p_record.SALES_CHANNEL_CODE;
	x_api_rec.SHIPMENT_PRIORITY_CODE   := p_record.SHIPMENT_PRIORITY_CODE;
	x_api_rec.SHIPPING_INSTRUCTIONS    := p_record.SHIPPING_INSTRUCTIONS;
	x_api_rec.SHIPPING_METHOD_CODE     := p_record.SHIPPING_METHOD_CODE;
	x_api_rec.SHIP_FROM_ORG_ID         := p_record.SHIP_FROM_ORG_ID;
	x_api_rec.SHIP_TOLERANCE_ABOVE     := p_record.SHIP_TOLERANCE_ABOVE;
	x_api_rec.SHIP_TOLERANCE_BELOW     := p_record.SHIP_TOLERANCE_BELOW;
	x_api_rec.SHIP_TO_CONTACT_ID       := p_record.SHIP_TO_CONTACT_ID;
	x_api_rec.SHIP_TO_ORG_ID           := p_record.SHIP_TO_ORG_ID;
	x_api_rec.SOLD_FROM_ORG_ID         := p_record.SOLD_FROM_ORG_ID;
	x_api_rec.SOLD_TO_CONTACT_ID       := p_record.SOLD_TO_CONTACT_ID;
	x_api_rec.SOLD_TO_ORG_ID           := p_record.SOLD_TO_ORG_ID;
	x_api_rec.SOURCE_DOCUMENT_ID       := p_record.SOURCE_DOCUMENT_ID;
	x_api_rec.SOURCE_DOCUMENT_TYPE_ID  := p_record.SOURCE_DOCUMENT_TYPE_ID;
	x_api_rec.TAX_EXEMPT_FLAG          := p_record.TAX_EXEMPT_FLAG;
	x_api_rec.TAX_EXEMPT_NUMBER        := p_record.TAX_EXEMPT_NUMBER;
	x_api_rec.TAX_EXEMPT_REASON_CODE   := p_record.TAX_EXEMPT_REASON_CODE;
	x_api_rec.TAX_POINT_CODE           := p_record.TAX_POINT_CODE;
	x_api_rec.TRANSACTIONAL_CURR_CODE  := p_record.TRANSACTIONAL_CURR_CODE;
	x_api_rec.VERSION_NUMBER           := p_record.VERSION_NUMBER;
	x_api_rec.FLOW_STATUS_CODE         := p_record.FLOW_STATUS_CODE;
	x_api_rec.TP_ATTRIBUTE1            := p_record.TP_ATTRIBUTE1;
	x_api_rec.TP_ATTRIBUTE10           := p_record.TP_ATTRIBUTE10;
	x_api_rec.TP_ATTRIBUTE11           := p_record.TP_ATTRIBUTE11;
	x_api_rec.TP_ATTRIBUTE12           := p_record.TP_ATTRIBUTE12;
	x_api_rec.TP_ATTRIBUTE13           := p_record.TP_ATTRIBUTE13;
	x_api_rec.TP_ATTRIBUTE14           := p_record.TP_ATTRIBUTE14;
	x_api_rec.TP_ATTRIBUTE15           := p_record.TP_ATTRIBUTE15;
	x_api_rec.TP_ATTRIBUTE2            := p_record.TP_ATTRIBUTE2;
	x_api_rec.TP_ATTRIBUTE3            := p_record.TP_ATTRIBUTE3;
	x_api_rec.TP_ATTRIBUTE4            := p_record.TP_ATTRIBUTE4;
	x_api_rec.TP_ATTRIBUTE5            := p_record.TP_ATTRIBUTE5;
	x_api_rec.TP_ATTRIBUTE6            := p_record.TP_ATTRIBUTE6;
	x_api_rec.TP_ATTRIBUTE7            := p_record.TP_ATTRIBUTE7;
	x_api_rec.TP_ATTRIBUTE8            := p_record.TP_ATTRIBUTE8;
	x_api_rec.TP_ATTRIBUTE9            := p_record.TP_ATTRIBUTE9;
	x_api_rec.TP_CONTEXT               := p_record.TP_CONTEXT;

        -- QUOTING changes
	x_api_rec.quote_number             := p_record.quote_number;
	x_api_rec.quote_date               := p_record.quote_date;
	x_api_rec.sales_document_name      := p_record.sales_document_name;
	x_api_rec.transaction_phase_code   := p_record.transaction_phase_code;
	x_api_rec.user_status_code         := p_record.user_status_code;
	x_api_rec.draft_submitted_flag     := p_record.draft_submitted_flag;
	x_api_rec.source_document_version_number := p_record.source_document_version_number;
	x_api_rec.sold_to_site_use_id      := p_record.sold_to_site_use_id;
        -- QUOTING changes END
	x_api_rec.IB_OWNER                 := p_record.IB_OWNER;
	x_api_rec.IB_INSTALLED_AT_LOCATION := p_record.IB_INSTALLED_AT_LOCATION;
	x_api_rec.IB_CURRENT_LOCATION      := p_record.IB_CURRENT_LOCATION;
	x_api_rec.END_CUSTOMER_ID          := p_record.END_CUSTOMER_ID;
	x_api_rec.END_CUSTOMER_CONTACT_ID  := p_record.END_CUSTOMER_CONTACT_ID;
	x_api_rec.END_CUSTOMER_SITE_USE_ID := p_record.END_CUSTOMER_SITE_USE_ID;
	x_api_rec.CUSTOMER_SIGNATURE       := p_record.CUSTOMER_SIGNATURE;
	x_api_rec.CUSTOMER_SIGNATURE_DATE       := p_record.CUSTOMER_SIGNATURE_DATE;
	x_api_rec.SUPPLIER_SIGNATURE       := p_record.SUPPLIER_SIGNATURE;
	x_api_rec.SUPPLIER_SIGNATURE_DATE       := p_record.SUPPLIER_SIGNATURE_DATE;
        --key Transaction dates
        x_api_rec.order_firmed_date        := p_record.order_firmed_date;

EXCEPTION

	WHEN OTHERS THEN
	IF	OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
		OE_MSG_PUB.Add_Exc_Msg
         	(   G_PKG_NAME
         	,   'Rowtype_Rec_To_API_Rec'
         	);
	END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Rowtype_Rec_To_API_Rec;

--  Procedure Clear_Dependent_Attr: Overloaded for view%rowtype PARAMETERS

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_initial_header_rec            IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
,   p_old_header_rec                IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
,   p_x_header_rec                  IN  OUT NOCOPY OE_AK_ORDER_HEADERS_V%ROWTYPE
,   p_x_instrument_id		    IN NUMBER DEFAULT NULL --R12 CC Encryption
,   p_old_instrument_id		    IN NUMBER DEFAULT NULL
)
IS
	l_index			NUMBER :=0;
	l_src_attr_tbl	OE_GLOBALS.NUMBER_Tbl_Type;
BEGIN

	oe_debug_pub.add('Entering OE_HEADER_UTIL.CLEAR_DEPENDENT_ATTR', 1);

	IF 	p_attr_id <> FND_API.G_MISS_NUM THEN

		l_index := l_index + 1.0;
		l_src_attr_tbl(l_index) := p_attr_id;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

	ELSE

		IF NOT OE_GLOBALS.Equal(p_x_header_rec.agreement_id,p_old_header_rec.agreement_id)
		THEN
			l_index := l_index + 1.0;
			l_src_attr_tbl(l_index) := OE_HEADER_UTIL.G_AGREEMENT;
		END IF;

		IF NOT OE_GLOBALS.Equal(p_x_header_rec.deliver_to_org_id,p_old_header_rec.deliver_to_org_id)
		THEN
			l_index := l_index + 1.0;
			l_src_attr_tbl(l_index) := OE_HEADER_UTIL.G_DELIVER_TO_ORG;
		END IF;

		IF NOT OE_GLOBALS.Equal(p_x_header_rec.invoice_to_contact_id,p_old_header_rec.invoice_to_contact_id)
		THEN
			l_index := l_index + 1.0;
			l_src_attr_tbl(l_index) := OE_HEADER_UTIL.G_INVOICE_TO_CONTACT;
		END IF;

		IF NOT OE_GLOBALS.Equal(p_x_header_rec.invoice_to_org_id,p_old_header_rec.invoice_to_org_id)
		THEN
			l_index := l_index + 1.0;
			l_src_attr_tbl(l_index) := OE_HEADER_UTIL.G_INVOICE_TO_ORG;
		END IF;

		IF NOT OE_GLOBALS.Equal(p_x_header_rec.ordered_date,p_old_header_rec.ordered_date)
		THEN
			l_index := l_index + 1.0;
			l_src_attr_tbl(l_index) := OE_HEADER_UTIL.G_ORDERED_DATE;
		END IF;

		IF NOT OE_GLOBALS.Equal(p_x_header_rec.order_type_id,p_old_header_rec.order_type_id)
		THEN
			l_index := l_index + 1.0;
			l_src_attr_tbl(l_index) := OE_HEADER_UTIL.G_ORDER_TYPE;
		END IF;

		IF NOT OE_GLOBALS.Equal(p_x_header_rec.payment_type_code,p_old_header_rec.payment_type_code)
		THEN
			l_index := l_index + 1.0;
			l_src_attr_tbl(l_index) := OE_HEADER_UTIL.G_PAYMENT_TYPE;
		END IF;

               /* Fix Bug # 2297053: Clear attributes dependent on Credit Card Number */
               IF NOT OE_GLOBALS.Is_Same_Credit_Card(p_old_header_rec.credit_card_number,p_x_header_rec.credit_card_number,
	       p_old_instrument_id,p_x_instrument_id)
               THEN
                        l_index := l_index + 1.0;
                        l_src_attr_tbl(l_index) := OE_HEADER_UTIL.G_CREDIT_CARD_NUMBER;
                END IF;

		IF NOT OE_GLOBALS.Equal(p_x_header_rec.price_list_id,p_old_header_rec.price_list_id)
		THEN
			l_index := l_index + 1.0;
			l_src_attr_tbl(l_index) := OE_HEADER_UTIL.G_PRICE_LIST;
		END IF;

		IF NOT OE_GLOBALS.Equal(p_x_header_rec.request_date,p_old_header_rec.request_date)
		THEN
			l_index := l_index + 1.0;
			l_src_attr_tbl(l_index) := OE_HEADER_UTIL.G_REQUEST_DATE;
		END IF;

		IF NOT OE_GLOBALS.Equal(p_x_header_rec.ship_from_org_id,p_old_header_rec.ship_from_org_id)
		THEN
			l_index := l_index + 1.0;
			l_src_attr_tbl(l_index) := OE_HEADER_UTIL.G_SHIP_FROM_ORG;
		END IF;

		IF NOT OE_GLOBALS.Equal(p_x_header_rec.ship_to_contact_id,p_old_header_rec.ship_to_contact_id)
		THEN
			l_index := l_index + 1.0;
			l_src_attr_tbl(l_index) := OE_HEADER_UTIL.G_SHIP_TO_CONTACT;
		END IF;

		IF NOT OE_GLOBALS.Equal(p_x_header_rec.ship_to_org_id,p_old_header_rec.ship_to_org_id)
		THEN
			l_index := l_index + 1.0;
			l_src_attr_tbl(l_index) := OE_HEADER_UTIL.G_SHIP_TO_ORG;
		END IF;

		IF NOT OE_GLOBALS.Equal(p_x_header_rec.sold_to_org_id,p_old_header_rec.sold_to_org_id)
		THEN
			l_index := l_index + 1.0;
			l_src_attr_tbl(l_index) := OE_HEADER_UTIL.G_SOLD_TO_ORG;
		END IF;

		IF NOT OE_GLOBALS.Equal(p_x_header_rec.sold_to_phone_id,p_old_header_rec.sold_to_phone_id)
		THEN
			l_index := l_index + 1.0;
			l_src_attr_tbl(l_index) := OE_HEADER_UTIL.G_SOLD_TO_PHONE;
		END IF;

		IF NOT OE_GLOBALS.Equal(p_x_header_rec.tax_exempt_flag,p_old_header_rec.tax_exempt_flag)
		THEN
			l_index := l_index + 1.0;
			l_src_attr_tbl(l_index) := OE_HEADER_UTIL.G_TAX_EXEMPT;
		END IF;

		IF NOT OE_GLOBALS.Equal(p_x_header_rec.transactional_curr_code,p_old_header_rec.transactional_curr_code)
		THEN
			l_index := l_index + 1.0;
			l_src_attr_tbl(l_index) := OE_HEADER_UTIL.G_TRANSACTIONAL_CURR;
		END IF;

                IF NOT OE_GLOBALS.Equal(p_x_header_rec.blanket_number,p_old_header_rec.blanket_number)
                THEN
                       l_index := l_index + 1.0;
                       l_src_attr_tbl(l_index) := OE_HEADER_UTIL.G_BLANKET_NUMBER;
                END IF;

             -- QUOTING changes
                IF NOT OE_GLOBALS.Equal(p_x_header_rec.transaction_phase_code,p_old_header_rec.transaction_phase_code)
                THEN
                       l_index := l_index + 1.0;
                       l_src_attr_tbl(l_index) := OE_HEADER_UTIL.G_TRANSACTION_PHASE;
                END IF;
                -- QUOTING changes END

		--distributed order @
		IF NOT OE_GLOBALS.Equal(p_x_header_rec.end_customer_id,p_old_header_rec.end_customer_id)
                THEN
                       l_index := l_index + 1.0;
                       l_src_attr_tbl(l_index) := OE_HEADER_UTIL.G_END_CUSTOMER;
                END IF;

                -- bug 5127922
                IF NOT OE_GLOBALS.Equal(p_x_header_rec.sold_to_site_use_id,p_old_header_rec.sold_to_site_use_id)
                THEN
                       l_index := l_index + 1.0;
                       l_src_attr_tbl(l_index) := OE_HEADER_UTIL.G_SOLD_TO_SITE_USE;
                END IF;

	END IF;

	Clear_Dependents
	(p_src_attr_tbl 	=> l_src_attr_tbl
	,p_initial_header_rec	=> p_initial_header_rec
	,p_old_header_rec	=> p_old_header_rec
	,p_x_header_rec		=> p_x_header_rec
	,p_x_instrument_id	=> p_x_instrument_id
	,p_old_instrument_id    => p_old_instrument_id);
        --bug 5083663
	--Need to reset the global flag for cc dependent attributes, so that they
	--can be cleared during the future calls when the cc is not selected
	--from the LOV.
	g_is_cc_selected_from_LOV := 'N';

	oe_debug_pub.add('Exiting OE_HEADER_UTIL.CLEAR_DEPENDENT_ATTR', 1);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	WHEN OTHERS THEN
		IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			OE_MSG_PUB.Add_Exc_Msg
			(   G_PKG_NAME
			,   'Clear_Dependent_Attr'
			);
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Clear_Dependent_Attr;

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_header_rec                    IN  OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
)
IS
	l_header_rec			OE_AK_ORDER_HEADERS_V%ROWTYPE;
	l_old_header_rec		OE_AK_ORDER_HEADERS_V%ROWTYPE;
	l_initial_header_rec	OE_AK_ORDER_HEADERS_V%ROWTYPE;
BEGIN
	oe_debug_pub.add('Security code in Clear_dep_attr....'||p_x_header_rec.instrument_security_code);
	API_Rec_To_Rowtype_Rec(p_x_header_rec, l_header_rec);
	API_Rec_To_Rowtype_Rec(p_old_header_rec, l_old_header_rec);

	l_initial_header_rec := l_header_rec;

	Clear_Dependent_Attr
		(p_attr_id			=> p_attr_id
		,p_initial_header_rec	=> l_initial_header_rec
		,p_old_header_rec		=> l_old_header_rec
		,p_x_header_rec			=> l_header_rec
		,p_x_instrument_id	=> p_x_header_rec.cc_instrument_id
		,p_old_instrument_id    => p_old_header_rec.cc_instrument_id
		);

	Rowtype_Rec_To_API_Rec(l_header_rec, p_x_header_rec);

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_x_header_rec                  IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
)
IS
	l_return_status			VARCHAR2(1):=  FND_API.G_RET_STS_SUCCESS;

	l_verify_payment_flag	VARCHAR2(30) := 'N';
        l_level                 VARCHAR2(10) ;
        l_copy_orig_price       VARCHAR2(1):='Y';
-- added by Renga for multiple payments

cursor payment_count_cur is
select count(payment_type_code)
from oe_payments
where header_id = p_x_header_rec.header_id
and line_id is null;

cursor delete_payment_count_cur is
select count(payment_type_code)
from oe_payments
where header_id = p_x_header_rec.header_id
and line_id is null
and payment_type_code in ('CREDIT_CARD','ACH','DIRECT_DEBIT');

l_payments_upd_flag     VARCHAR2(1) := 'N';
l_delete_payment_count NUMBER :=0;
l_payment_count number := 0;
l_log_delete_payment_req VARCHAR2(1) := 'N';

BEGIN

	oe_debug_pub.add('Entering OE_HEADER_UTIL.APPLY_ATTRIBUTE_CHANGES', 1);

    --  Load out record

	IF NOT OE_GLOBALS.Equal(p_x_header_rec.booked_flag,p_old_header_rec.booked_flag)
	THEN
		IF 	p_x_header_rec.booked_flag = 'Y' THEN
			p_x_header_rec.flow_status_code := 'BOOKED';
		END IF;
	END IF;

	IF NOT OE_GLOBALS.Equal(p_x_header_rec.cancelled_flag,p_old_header_rec.cancelled_flag)
	THEN
		IF 	p_x_header_rec.cancelled_flag = 'Y' THEN

			Oe_Sales_Can_Util.Check_Constraints(p_x_header_rec,
												p_old_header_rec,
												l_return_status);
			IF 	l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				IF 	l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
					oe_debug_pub.ADD('Update Line Process Order return UNEXP_ERROR');
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				ELSIF	l_return_status = FND_API.G_RET_STS_ERROR THEN
						oe_debug_pub.ADD('Update Line Process Order return RET_STS_ERROR');
						RAISE FND_API.G_EXC_ERROR;
				END IF;
			END IF;

			--p_x_header_rec.flow_status_code := 'CANCELLED';

		END IF; -- cancelled flag

	END IF;
	oe_debug_pub.add('Raj1', 1);
	oe_debug_pub.add('Operation--'||p_x_header_rec.operation);
	oe_debug_pub.add('payment type--'||nvl(p_x_header_rec.payment_type_code,'xxx'));
	oe_debug_pub.add('Old inv to ...'||p_x_header_rec.invoice_to_org_id);
	oe_debug_pub.add('New inv to...'||p_old_header_rec.invoice_to_org_id);

	IF NOT OE_GLOBALS.Equal(p_x_header_rec.invoice_to_org_id,p_old_header_rec.invoice_to_org_id)
	THEN
		IF  p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
		 --R12 CC Encryption
		 --Delayed request for deleting the payments when
		 --invoice to changes
	         IF p_x_header_rec.payment_type_code in ('ACH','DIRECT_DEBIT','CREDIT_CARD') OR
	         p_x_header_rec.payment_type_code IS NULL THEN --null for prepayments
			OPEN delete_payment_count_cur;
			FETCH delete_payment_count_cur into l_delete_payment_count;
			close delete_payment_count_cur;
			IF l_delete_payment_count > 0  THEN
				l_log_delete_payment_req := 'Y';
			END IF;

			oe_debug_pub.add('Payment_type code in invoice to '||p_x_header_rec.payment_type_code);
			oe_debug_pub.add('Delete Payment Count count'||l_delete_payment_count);
			oe_debug_pub.add('Log delete payment req Flag'||l_log_delete_payment_req);
			IF l_log_delete_payment_req = 'Y' THEN
				OE_delayed_requests_Pvt.log_request
				    (p_entity_code            	=> OE_GLOBALS.G_ENTITY_HEADER_PAYMENT,
				     p_entity_id              	=> p_x_Header_rec.header_id,
				     p_requesting_entity_code	=> OE_GLOBALS.G_ENTITY_HEADER,
				     p_requesting_entity_id  	=> p_x_Header_rec.header_id,
				     p_request_type           	=> OE_GLOBALS.G_DELETE_PAYMENTS,
				     p_param1			=> to_char(p_old_header_rec.invoice_to_org_id),
				     x_return_status         	=> l_return_status);

			END IF;--Log delayed req.
		  END IF;--Payment type code check for deleting payments
	          --R12 CC Encryption
		  IF p_x_header_rec.payment_type_code = 'CREDIT_CARD' THEN
			oe_debug_pub.add('Log Verify Payment Delayed Request in Invoice To');
			-- Set Flag to Log a request for Verify Payment
			l_verify_payment_flag := 'Y';
                  ELSE
                 -- BUG 2114156
                      oe_debug_pub.add('Call OE_CREDIT_CHECK_UTIL.GET_credit_check_level ');
                    l_level := NULL ;

                    l_level :=
                    OE_CREDIT_CHECK_UTIL.GET_credit_check_level
                    ( p_calling_action     => 'UPDATE'
                     , p_order_type_id     =>
                           p_x_header_rec.order_type_id
                     )  ;
		oe_debug_pub.add('l_level = '|| l_level );

                     IF l_level = 'ORDER'
                     THEN


                     -- Set Flag to Log a request for Verify Payment
                      oe_debug_pub.add('Log Verify Payment Delayed Request in Invoice To - Credit Check');
                      --
                      l_verify_payment_flag := 'Y';
                    END IF;
                  END IF;
		END IF;--Operation - Update
	END IF;
	oe_debug_pub.add('Raj2', 1);
        oe_debug_pub.add('p_x_header_rec.open_flag:'||p_x_header_rec.open_flag);
        oe_debug_pub.add('p_old_header_rec.open_flag:'||p_old_header_rec.open_flag);


	IF (NOT OE_GLOBALS.Equal(p_x_header_rec.open_flag,
                                 p_old_header_rec.open_flag)) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
            p_x_header_rec.open_flag IS NOT NULL)
            --OR cnd for bug 5060064
	THEN
		IF 	p_x_header_rec.open_flag = 'N' THEN
			p_x_header_rec.flow_status_code := 'CLOSED';
			IF 	p_x_header_rec.cancelled_flag = 'Y' THEN
				--p_x_header_rec.flow_status_code := 'CANCELLED';
				null;
			END IF;
		END IF;

	END IF;

	IF NOT OE_GLOBALS.Equal(p_x_header_rec.order_type_id,p_old_header_rec.order_type_id)
	THEN

       -- If the Order Type has changed, we need to sync up the
       -- MTL_SALES_ORDERS table.
		IF 	p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN


			IF p_x_header_rec.payment_type_code = 'CREDIT_CARD' THEN

	     -- Set Flag to Log a request for Verify Payment
				oe_debug_pub.add('Log Verify Payment Delayed Request in Order Type');
				l_verify_payment_flag := 'Y';
			ELSE

			/* Additional Task - If the payment type is not CREDIT CARD ,
			then also log the delayed request for Verify payment if the
			Order is booked */

				IF p_x_header_rec.booked_flag ='Y'
				THEN

					oe_debug_pub.add('Log Verify Payment Delayed Request in Order Type',3);
					l_verify_payment_flag := 'Y';

				END IF;

			END IF;
		END IF;
	END IF;

	IF (NOT OE_GLOBALS.Equal(p_x_header_rec.salesrep_id,
                                 p_old_header_rec.salesrep_id)) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
            p_x_header_rec.salesrep_id IS NOT NULL )
            --OR condition added for bug 5060064
	THEN

		IF NOT (nvl(p_x_header_rec.source_document_type_id,-99) = 2 AND
			p_x_header_rec.operation = oe_globals.g_opr_create)THEN
		       IF p_x_header_rec.salesrep_id IS NOT NULL THEN
	                  IF OE_Validate_Header_Scredit.G_Create_Auto_Sales_Credit = 'Y' THEN
				OE_delayed_requests_Pvt.log_request
				(p_entity_code				=> OE_GLOBALS.G_ENTITY_HEADER,
				p_entity_id				=> p_x_header_rec.header_id,
				p_requesting_entity_code	=> OE_GLOBALS.G_ENTITY_HEADER,
				p_requesting_entity_id		=> p_x_header_rec.header_id,
				p_request_type      		=> OE_GLOBALS.G_DFLT_HSCREDIT_FOR_SREP,
				p_param1					=>  p_x_header_rec.header_id,
				p_param2					=> p_x_header_rec.salesrep_id,
				x_return_status				=> l_return_status);
			  END IF;

			 /* Else added for bug 4139105 */
		       ELSE
			 IF OE_Validate_Header_Scredit.G_Create_Auto_Sales_Credit = 'Y' THEN
			    OE_DELAYED_REQUESTS_PVT.Delete_Request
                               (
				p_entity_code   => OE_GLOBALS.G_ENTITY_HEADER,
				p_entity_id     => p_x_header_rec.header_id,
				p_request_type  => OE_GLOBALS.G_DFLT_HSCREDIT_FOR_SREP,
				x_return_status => l_return_status
                               );
			 END IF;
                         /* End of bug 4139105 */

		      END IF;

		END IF;

		NULL;
	END IF;
	oe_debug_pub.add('Raj3', 1);

    IF NOT OE_GLOBALS.Equal(p_x_header_rec.sold_to_org_id,p_old_header_rec.sold_to_org_id)
    THEN
       IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
	 AND p_x_header_rec.payment_type_code = 'CREDIT_CARD' THEN

	   -- Set Flag to Log a request for Verify Payment
	   oe_debug_pub.add('Log Verify Payment Delayed Request in Sold To',3);
	   --
	   l_verify_payment_flag := 'Y';

       END IF;

       IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
          -- Log request to evaluate Holds.
          oe_debug_pub.ADD('Customer update: logging request for eval_hold_source',1);
          oe_debug_pub.ADD('Header ID:' || to_char(p_x_header_rec.header_id) ||
                           'Entity ID:' || to_char(p_x_header_rec.sold_to_org_id),1);
          OE_delayed_requests_Pvt.log_request
                 (p_entity_code            => OE_GLOBALS.G_ENTITY_HEADER,
                  p_entity_id              => p_x_header_rec.header_id,
                  p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER,
                  p_requesting_entity_id   => p_x_header_rec.header_id,
                  p_request_type           => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                  p_request_unique_key1    => 'CUSTOMER',
                  p_param1                 => 'C',
                  p_param2                 => p_x_header_rec.sold_to_org_id,
                  x_return_status          => l_return_status);
          oe_debug_pub.ADD('after call to log_request: l_return_status: '||l_return_status , 1);
       END IF;


    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_header_rec.tax_point_code,p_old_header_rec.tax_point_code)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_header_rec.transactional_curr_code,p_old_header_rec.transactional_curr_code)
    THEN
      IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
	 THEN

	 	IF  p_x_header_rec.payment_type_code = 'CREDIT_CARD' THEN

	   	-- Set Flag to Log a request for Verify Payment
	   	oe_debug_pub.add('Log Verify Payment Delayed Request in Curr Code',3);
	   	l_verify_payment_flag := 'Y';

		ELSE
			 /*  Additional Task - If the payment type is not CREDIT CARD,
			 then also log delayed req for verify payment if the
			 order is booked */

			 if p_x_header_rec.booked_flag ='Y' then
				 oe_debug_pub.add('Log Verify Payment Delayed Request in Currency Code',3);
				 l_verify_payment_flag := 'Y';
			 end if;
	     END IF;
	 END IF;
    END IF;

	IF 	NOT OE_GLOBALS.Equal(p_x_header_rec.payment_type_code,p_old_header_rec.payment_type_code)
	THEN
		IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
		   --R12 CC Encryption
		   --Credit card processing would
		   --now be handled in pre_write_process procedure
		   IF p_x_header_rec.payment_type_code IS NOT NULL
		   AND p_x_header_rec.payment_type_code <> 'CREDIT_CARD' THEN
			-- Set Flag Log a request for Verify Payment
			oe_debug_pub.add('Log Verify Payment Delayed Request in Payment Type',3);
			l_verify_payment_flag := 'Y';
                        l_payments_upd_flag := 'Y';
		   END IF;

		   --R12 CC Encryption
		END IF;
	END IF;
     IF 	NOT OE_GLOBALS.Equal(p_x_header_rec.payment_amount,p_old_header_rec.payment_amount)
	THEN
		IF 		p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
		AND 	p_x_header_rec.payment_type_code in ('CASH', 'CHECK')
THEN

	   -- Set Flag to Log a request for Verify Payment
			oe_debug_pub.add('Log Update Payments Delayed',3);
	   --
			--l_verify_payment_flag := 'Y';

                        l_payments_upd_flag := 'Y';

		END IF;
       END IF;

       IF NOT OE_GLOBALS.Equal(p_x_header_rec.check_number,p_old_header_rec.check_number)
	THEN
		IF 		p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
		AND 	p_x_header_rec.payment_type_code = 'CHECK'
THEN

	   -- Set Flag to Log a request for Verify Payment
			oe_debug_pub.add('Log Update Payments Delayed',3);
	   --
			--l_verify_payment_flag := 'Y';

                        l_payments_upd_flag := 'Y';

		END IF;
       END IF;


	IF 	NOT OE_GLOBALS.Equal(p_x_header_rec.credit_card_holder_name,p_old_header_rec.credit_card_holder_name)
	THEN
		IF 		p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
		AND 	p_x_header_rec.payment_type_code = 'CREDIT_CARD' THEN

	   -- Set Flag to Log a request for Verify Payment
			oe_debug_pub.add('Log Verify Payment Delayed Request in CC Holder',3);
	   --
			l_verify_payment_flag := 'Y';
    		        --R12 CC Encryption
		        --Credit card processing would now be handled in pre_write_process procedure
				--l_payments_upd_flag := 'Y';
			--R12 CC Encryption

		END IF;
	END IF;

    IF NOT OE_GLOBALS.Is_Same_Credit_Card(p_old_header_rec.credit_card_number,
	    p_x_header_rec.credit_card_number,
	    p_old_header_rec.cc_instrument_id,
	    p_x_header_rec.cc_instrument_id)
    THEN
		IF	p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
		AND	p_x_header_rec.payment_type_code = 'CREDIT_CARD' THEN

	   -- Set Flag to Log a request for Verify Payment
			oe_debug_pub.add('Log Verify Payment Delayed Request in CC Number',3);
	   --
			l_verify_payment_flag := 'Y';
     		        --R12 CC Encryption
		        --Credit card processing would now be handled in pre_write_process procedure
				--l_payments_upd_flag := 'Y';

			--R12 CC Encryption
		END IF;
	END IF;
	oe_debug_pub.add('Raj4', 1);

	IF 	NOT OE_GLOBALS.Equal(p_x_header_rec.credit_card_expiration_date,p_old_header_rec.credit_card_expiration_date)
	THEN
	       /* Fix Bug # 3686048(FP 3659342): Set the Exp Date as the Last Day of the Month */
                select last_day(p_x_header_rec.credit_card_expiration_date)
                into   p_x_header_rec.credit_card_expiration_date from dual;

         	IF  p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
		AND p_x_header_rec.payment_type_code = 'CREDIT_CARD' THEN

	   -- Set Flag to Log a request for Verify Payment
			oe_debug_pub.add('Log Verify Payment Delayed Request in CC Exp Date',3);
	   --
			l_verify_payment_flag := 'Y';
     		        --R12 CC Encryption
		        --Credit card processing would now be handled in pre_write_process procedure
				--l_payments_upd_flag := 'Y';
			--R12 CC Encryption

		END IF;
	END IF;

	IF 	NOT OE_GLOBALS.Equal(p_x_header_rec.credit_card_approval_code,p_old_header_rec.credit_card_approval_code)
	THEN
		IF  p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
		AND p_x_header_rec.payment_type_code = 'CREDIT_CARD' THEN

	   -- Set Flag to Log a request for Verify Payment
			oe_debug_pub.add('Log Verify Payment Delayed Request in CC Approval',3);
	   --
			l_verify_payment_flag := 'Y';
     		        --R12 CC Encryption
		        --Credit card processing would now be handled in pre_write_process procedure
				--l_payments_upd_flag := 'Y';
			--R12 CC Encryption

		END IF;
	END IF;


     /* Fix for 1559906: New Procedure to Copy Freight Charges */

     IF   (NOT OE_GLOBALS.Equal(p_x_header_rec.source_document_type_id,
                                p_old_header_rec.source_document_type_id)) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
            AND p_x_header_rec.source_document_type_id = 2)
            --OR condition added for bug 5060064
     THEN
          IF  p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
          AND p_x_header_rec.source_document_type_id = 2 THEN

               -- Added IF condition for bug 6697401
	       IF OE_ORDER_COPY_UTIL.G_COPY_REC.line_price_mode =
	          OE_ORDER_COPY_UTIL.G_CPY_ORIG_PRICE THEN

	   	       oe_debug_pub.add(' Copy as original price');
	               -- bug 6697401
	      	       -- Log a request to copy Freight Charges to the copied order.
	               oe_debug_pub.add('Log Delayed Request To Copy Charges in SRC Doc Type Id',3);

	       	       OE_delayed_requests_Pvt.log_request(
	       	       p_entity_code            => OE_GLOBALS.G_ENTITY_HEADER,
	       	       p_entity_id              => p_x_header_rec.header_id,
	       	       p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER,
	       	       p_requesting_entity_id   => p_x_header_rec.header_id,
	      	       p_param1                 => p_x_header_rec.order_category_code,
	       	       p_param2                 => p_x_header_rec.source_document_id,
	       	       p_request_type           => OE_GLOBALS.G_COPY_FREIGHT_CHARGES,
	      	       x_return_status          => l_return_status);
               END IF;  -- bug 6697401
          END IF;
     END IF;

/* Added the following code to fix the bug 2170086 */
     IF   NOT OE_GLOBALS.Equal(p_x_header_rec.source_document_type_id,p_old_header_rec.source_document_type_id) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
            AND p_x_header_rec.source_document_type_id = 2 )
            --OR condition added for bug 5060064
     THEN
          IF  p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
          AND p_x_header_rec.source_document_type_id = 2 THEN

            -- Log a request to copy header adjustments to the copied order.
            oe_debug_pub.add('Log Delayed Request To Copy header adjustments ',3);
            --

            IF OE_ORDER_COPY_UTIL.G_COPY_REC.line_price_mode IN (OE_ORDER_COPY_UTIL.G_CPY_ORIG_PRICE,OE_ORDER_COPY_UTIL.G_CPY_REPRICE_PARTIAL) THEN
              oe_debug_pub.add(' Copy as original price');
              OE_delayed_requests_Pvt.log_request(
              p_entity_code            => OE_GLOBALS.G_ENTITY_HEADER,
              p_entity_id              => p_x_header_rec.header_id,
              p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER,
              p_requesting_entity_id   => p_x_header_rec.header_id,
              p_param1                 => p_x_header_rec.order_category_code,
              p_param2                 => p_x_header_rec.source_document_id,
              p_request_type           => OE_GLOBALS.G_COPY_HEADER_ADJUSTMENTS ,
              x_return_status          => l_return_status);
            END IF;
          END IF;
     END IF;

/* End of the code added to fix the bug 2170086 */
   -- Bug 2619506
     IF (NOT OE_GLOBALS.Equal(p_x_header_rec.transactional_curr_code,p_old_header_rec.transactional_curr_code)) OR
        (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
         p_x_header_rec.transactional_curr_code IS NOT NULL)
         -- OR condition added for bug 5060064
        THEN
         IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
          THEN
           If  nvl(p_x_header_rec.booked_flag, 'N')  <> 'Y'  Then
            OE_delayed_requests_Pvt.log_request(
            p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
            p_entity_id              => p_x_header_rec.header_id,
            p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
            p_requesting_entity_id   => p_x_header_rec.header_id,
            p_param1                 => p_x_header_rec.header_id,
            p_param2                 => 'BATCH',
            p_request_unique_key1    => 'BATCH',
            p_param3                 =>  'PRICE_ORDER',
            p_request_type           =>  OE_GLOBALS.G_PRICE_ORDER,
            x_return_status          => l_return_status);
           Else
            OE_delayed_requests_Pvt.log_request(
            p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
            p_entity_id              => p_x_header_rec.header_id,
            p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
            p_requesting_entity_id   => p_x_header_rec.header_id,
            p_param1                 => p_x_header_rec.header_id,
            p_param2                 => 'BATCH,BOOK',
            p_request_unique_key1    => 'BATCH,BOOK',
            p_param3                 =>  'PRICE_ORDER',
            p_request_type           =>  OE_GLOBALS.G_PRICE_ORDER,
            x_return_status          => l_return_status);
         End If;
       End If;
     End If;

--ER#7479609 start
	IF  NOT OE_GLOBALS.Equal(p_x_header_rec.payment_type_code,p_old_header_rec.payment_type_code)
	AND p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
	THEN
	  OE_Holds_PUB.G_PAYMENT_HOLD_APPLIED := 'N';
	  OE_Holds_PUB.G_HDR_PAYMENT := 'Y';
          oe_debug_pub.ADD('payment type update: logging request for eval_hold_source',1);
          oe_debug_pub.ADD('Header ID:' || to_char(p_x_header_rec.header_id) ||
                           'Entity ID:' || to_char(p_x_header_rec.payment_type_code),1);
          OE_delayed_requests_Pvt.log_request
                 (p_entity_code            => OE_GLOBALS.G_ENTITY_HEADER,
                  p_entity_id              => p_x_header_rec.header_id,
                  p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER,
                  p_requesting_entity_id   => p_x_header_rec.header_id,
                  p_request_type           => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                  p_request_unique_key1    => 'PAYMENT_TYPE',
                  p_param1                 => 'P',
                  p_param2                 => p_x_header_rec.payment_type_code,
                  x_return_status          => l_return_status);
          oe_debug_pub.ADD('after call to log_request: l_return_status: '||l_return_status , 1);

	END IF;

	IF  NOT OE_GLOBALS.Equal(p_x_header_rec.transactional_curr_code,p_old_header_rec.transactional_curr_code)
	AND p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
	THEN
          oe_debug_pub.ADD('Currency update: logging request for eval_hold_source',1);
          oe_debug_pub.ADD('Header ID:' || to_char(p_x_header_rec.header_id) ||
                           'Entity ID:' || to_char(p_x_header_rec.transactional_curr_code),1);
          OE_delayed_requests_Pvt.log_request
                 (p_entity_code            => OE_GLOBALS.G_ENTITY_HEADER,
                  p_entity_id              => p_x_header_rec.header_id,
                  p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER,
                  p_requesting_entity_id   => p_x_header_rec.header_id,
                  p_request_type           => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                  p_request_unique_key1    => 'CURRENCY',
                  p_param1                 => 'TC',
                  p_param2                 => p_x_header_rec.transactional_curr_code,
                  x_return_status          => l_return_status);
          oe_debug_pub.ADD('after call to log_request: l_return_status: '||l_return_status , 1);

	END IF;

	IF  NOT OE_GLOBALS.Equal(p_x_header_rec.sales_channel_code,p_old_header_rec.sales_channel_code)
	AND p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
	THEN
          oe_debug_pub.ADD('sales channel update: logging request for eval_hold_source',1);
          oe_debug_pub.ADD('Header ID:' || to_char(p_x_header_rec.header_id) ||
                           'Entity ID:' || to_char(p_x_header_rec.sales_channel_code),1);
          OE_delayed_requests_Pvt.log_request
                 (p_entity_code            => OE_GLOBALS.G_ENTITY_HEADER,
                  p_entity_id              => p_x_header_rec.header_id,
                  p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER,
                  p_requesting_entity_id   => p_x_header_rec.header_id,
                  p_request_type           => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                  p_request_unique_key1    => 'SALES_CHANNEL',
                  p_param1                 => 'SC',
                  p_param2                 => p_x_header_rec.sales_channel_code,
                  x_return_status          => l_return_status);
          oe_debug_pub.ADD('after call to log_request: l_return_status: '||l_return_status , 1);

	END IF;

	IF  NOT OE_GLOBALS.Equal(p_x_header_rec.price_list_id,p_old_header_rec.price_list_id)
	AND p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
	THEN
          oe_debug_pub.ADD('price list update: logging request for eval_hold_source',1);
          oe_debug_pub.ADD('Header ID:' || to_char(p_x_header_rec.header_id) ||
                           'Entity ID:' || to_char(p_x_header_rec.price_list_id),1);
          OE_delayed_requests_Pvt.log_request
                 (p_entity_code            => OE_GLOBALS.G_ENTITY_HEADER,
                  p_entity_id              => p_x_header_rec.header_id,
                  p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER,
                  p_requesting_entity_id   => p_x_header_rec.header_id,
                  p_request_type           => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                  p_request_unique_key1    => 'PRICE_LIST',
                  p_param1                 => 'PL',
                  p_param2                 => p_x_header_rec.price_list_id,
                  x_return_status          => l_return_status);
          oe_debug_pub.ADD('after call to log_request: l_return_status: '||l_return_status , 1);

	END IF;

	IF  NOT OE_GLOBALS.Equal(p_x_header_rec.order_type_id,p_old_header_rec.order_type_id)
	AND p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
	THEN
          oe_debug_pub.ADD('Order type update: logging request for eval_hold_source',1);
          oe_debug_pub.ADD('Header ID:' || to_char(p_x_header_rec.header_id) ||
                           'Entity ID:' || to_char(p_x_header_rec.order_type_id),1);
          OE_delayed_requests_Pvt.log_request
                 (p_entity_code            => OE_GLOBALS.G_ENTITY_HEADER,
                  p_entity_id              => p_x_header_rec.header_id,
                  p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER,
                  p_requesting_entity_id   => p_x_header_rec.header_id,
                  p_request_type           => OE_GLOBALS.G_EVAL_HOLD_SOURCE,
                  p_request_unique_key1    => 'ORDER_TYPE',
                  p_param1                 => 'OT',
                  p_param2                 => p_x_header_rec.order_type_id,
                  x_return_status          => l_return_status);
          oe_debug_pub.ADD('after call to log_request: l_return_status: '||l_return_status , 1);

	END IF;
--ER#7479609 end

	IF	(l_verify_payment_flag = 'Y') THEN

	 -- Log a request for Verify Payment
		oe_debug_pub.add('Logging Delayed Request for Verify Payment',3);
	 --
		OE_delayed_requests_Pvt.log_request
		(p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
		p_entity_id              => p_x_header_rec.header_id,
		p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER,
		p_requesting_entity_id   => p_x_header_rec.header_id,
		p_request_type           => OE_GLOBALS.G_VERIFY_PAYMENT,
		x_return_status          => l_return_status);

	END IF;

    /* code added by Renga for multiple payments */
     l_payment_count := 0;
     Begin

      oe_debug_pub.add('before getting payment count ', 1);
      open payment_count_cur;
      fetch payment_count_cur into l_payment_count;
      close payment_count_cur;

     Exception

       when others then
         l_payment_count := 0;

     End;

      IF OE_PrePayment_UTIL.IS_MULTIPLE_PAYMENTS_ENABLED = TRUE
         and l_payments_upd_flag = 'Y'
         and l_payment_count > 0 then --modified for bug 3733877

	oe_debug_pub.add('logging synch payment delayed request', 1);

       OE_delayed_requests_Pvt.log_request
		(p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
		p_entity_id              => p_x_header_rec.header_id,
		p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER,
		p_requesting_entity_id   => p_x_header_rec.header_id,
		p_request_type           => OE_GLOBALS.G_UPDATE_HDR_PAYMENT,
                p_param1                 => 'UPDATE_PAYMENT',
		x_return_status          => l_return_status);

      END IF; -- if multiple payments enabled and l_payments_upd_flag = 'Y'
              -- and l_payment_count = 1
     /*-- 3288805
      Store the new order_date_type_code--*/
      IF (NOT OE_GLOBALS.Equal(p_x_header_rec.order_date_type_code, p_old_header_rec.order_date_type_code)) OR
         (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
           p_x_header_rec.order_date_type_code IS NOT NULL)
       --OR cnd added for bug 5060064
      THEN
         IF ( nvl(OE_Schedule_Util.G_HEADER_ID, 0) = p_x_header_rec.header_id )
THEN
            OE_Schedule_Util.G_DATE_TYPE := p_x_header_rec.order_date_type_code;         END IF;
      END IF;
     /*-- 3288805 --*/
	oe_debug_pub.add('Exiting OE_HEADER_UTIL.APPLY_ATTRIBUTE_CHANGES', 1);

END Apply_Attribute_Changes;

--  Procedure Complete_Record

PROCEDURE Complete_Record
(   p_x_header_rec                    IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type
)
IS

BEGIN

	oe_debug_pub.add('Entering OE_HEADER_UTIL.COMPLETE_RECORD', 1);

	IF 	p_x_header_rec.accounting_rule_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.accounting_rule_id := p_old_header_rec.accounting_rule_id;
	END IF;

	IF 	p_x_header_rec.accounting_rule_duration = FND_API.G_MISS_NUM THEN
		p_x_header_rec.accounting_rule_duration := p_old_header_rec.accounting_rule_duration;
	END IF;

	IF 	p_x_header_rec.agreement_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.agreement_id := p_old_header_rec.agreement_id;
	END IF;

	IF 	p_x_header_rec.upgraded_flag = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.upgraded_flag := p_old_header_rec.upgraded_flag;
	END IF;

        IF      p_x_header_rec.blanket_number = FND_API.G_MISS_NUM THEN
                p_x_header_rec.blanket_number := p_old_header_rec.blanket_number;
        END IF;

	IF 	p_x_header_rec.booked_flag = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.booked_flag := p_old_header_rec.booked_flag;
	END IF;

	IF 	p_x_header_rec.booked_date = FND_API.G_MISS_DATE THEN
		p_x_header_rec.booked_date := p_old_header_rec.booked_date;
	END IF;

	IF 	p_x_header_rec.cancelled_flag = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.cancelled_flag := p_old_header_rec.cancelled_flag;
	END IF;

	IF 	p_x_header_rec.attribute1 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.attribute1 := p_old_header_rec.attribute1;
	END IF;

	IF 	p_x_header_rec.attribute10 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.attribute10 := p_old_header_rec.attribute10;
	END IF;

	IF 	p_x_header_rec.attribute11 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.attribute11 := p_old_header_rec.attribute11;
	END IF;

	IF 	p_x_header_rec.attribute12 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.attribute12 := p_old_header_rec.attribute12;
	END IF;

	IF 	p_x_header_rec.attribute13 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.attribute13 := p_old_header_rec.attribute13;
	END IF;

	IF 	p_x_header_rec.attribute14 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.attribute14 := p_old_header_rec.attribute14;
	END IF;

	IF 	p_x_header_rec.attribute15 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.attribute15 := p_old_header_rec.attribute15;
	END IF;

	IF 	p_x_header_rec.attribute16 = FND_API.G_MISS_CHAR THEN --bug 2184255
		p_x_header_rec.attribute16 := p_old_header_rec.attribute16;
	END IF;

	IF 	p_x_header_rec.attribute17 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.attribute17 := p_old_header_rec.attribute17;
	END IF;

	IF 	p_x_header_rec.attribute18 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.attribute18 := p_old_header_rec.attribute18;
	END IF;

	IF 	p_x_header_rec.attribute19 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.attribute19 := p_old_header_rec.attribute19;
	END IF;

	IF 	p_x_header_rec.attribute2 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.attribute2 := p_old_header_rec.attribute2;
	END IF;

	IF 	p_x_header_rec.attribute20 = FND_API.G_MISS_CHAR THEN --bug2184255
		p_x_header_rec.attribute20:= p_old_header_rec.attribute20;
	END IF;

	IF 	p_x_header_rec.attribute3 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.attribute3 := p_old_header_rec.attribute3;
	END IF;

	IF 	p_x_header_rec.attribute4 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.attribute4 := p_old_header_rec.attribute4;
	END IF;

	IF 	p_x_header_rec.attribute5 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.attribute5 := p_old_header_rec.attribute5;
	END IF;

	IF 	p_x_header_rec.attribute6 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.attribute6 := p_old_header_rec.attribute6;
	END IF;

	IF 	p_x_header_rec.attribute7 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.attribute7 := p_old_header_rec.attribute7;
	END IF;

	IF 	p_x_header_rec.attribute8 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.attribute8 := p_old_header_rec.attribute8;
	END IF;

	IF 	p_x_header_rec.attribute9 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.attribute9 := p_old_header_rec.attribute9;
	END IF;

	IF 	p_x_header_rec.context = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.context := p_old_header_rec.context;
	END IF;

	IF 	p_x_header_rec.conversion_rate = FND_API.G_MISS_NUM THEN
		p_x_header_rec.conversion_rate := p_old_header_rec.conversion_rate;
	END IF;

	IF 	p_x_header_rec.conversion_rate_date = FND_API.G_MISS_DATE THEN
		p_x_header_rec.conversion_rate_date := p_old_header_rec.conversion_rate_date;
	END IF;

	IF 	p_x_header_rec.conversion_type_code = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.conversion_type_code := p_old_header_rec.conversion_type_code;
	END IF;
	IF 	p_x_header_rec.CUSTOMER_PREFERENCE_SET_CODE = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.CUSTOMER_PREFERENCE_SET_CODE := p_old_header_rec.CUSTOMER_PREFERENCE_SET_CODE;
	END IF;

	IF 	p_x_header_rec.created_by = FND_API.G_MISS_NUM THEN
		p_x_header_rec.created_by := p_old_header_rec.created_by;
	END IF;

	IF 	p_x_header_rec.creation_date = FND_API.G_MISS_DATE THEN
		p_x_header_rec.creation_date := p_old_header_rec.creation_date;
	END IF;

	IF 	p_x_header_rec.cust_po_number = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.cust_po_number := p_old_header_rec.cust_po_number;
	END IF;

	IF 	p_x_header_rec.default_fulfillment_set = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.default_fulfillment_set := p_old_header_rec.default_fulfillment_set;
	END IF;


	IF 	p_x_header_rec.deliver_to_contact_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.deliver_to_contact_id := p_old_header_rec.deliver_to_contact_id;
	END IF;

	IF 	p_x_header_rec.deliver_to_org_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.deliver_to_org_id := p_old_header_rec.deliver_to_org_id;
	END IF;

	IF 	p_x_header_rec.demand_class_code = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.demand_class_code := p_old_header_rec.demand_class_code;
	END IF;

	IF 	p_x_header_rec.expiration_date = FND_API.G_MISS_DATE THEN
		p_x_header_rec.expiration_date := p_old_header_rec.expiration_date;
	END IF;

	IF 	p_x_header_rec.earliest_schedule_limit = FND_API.G_MISS_NUM THEN
		p_x_header_rec.earliest_schedule_limit := p_old_header_rec.earliest_schedule_limit;
	END IF;

	IF 	p_x_header_rec.fob_point_code = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.fob_point_code := p_old_header_rec.fob_point_code;
	END IF;

	IF 	p_x_header_rec.freight_carrier_code = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.freight_carrier_code := p_old_header_rec.freight_carrier_code;
	END IF;

	IF 	p_x_header_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.freight_terms_code := p_old_header_rec.freight_terms_code;
	END IF;

	IF 	p_x_header_rec.fulfillment_set_name = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.fulfillment_set_name := p_old_header_rec.fulfillment_set_name;
	END IF;

	IF 	p_x_header_rec.global_attribute1 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.global_attribute1 := p_old_header_rec.global_attribute1;
	END IF;

	IF 	p_x_header_rec.global_attribute10 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.global_attribute10 := p_old_header_rec.global_attribute10;
	END IF;

	IF 	p_x_header_rec.global_attribute11 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.global_attribute11 := p_old_header_rec.global_attribute11;
	END IF;

	IF 	p_x_header_rec.global_attribute12 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.global_attribute12 := p_old_header_rec.global_attribute12;
	END IF;

	IF 	p_x_header_rec.global_attribute13 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.global_attribute13 := p_old_header_rec.global_attribute13;
	END IF;

	IF 	p_x_header_rec.global_attribute14 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.global_attribute14 := p_old_header_rec.global_attribute14;
	END IF;

	IF 	p_x_header_rec.global_attribute15 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.global_attribute15 := p_old_header_rec.global_attribute15;
	END IF;

	IF 	p_x_header_rec.global_attribute16 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.global_attribute16 := p_old_header_rec.global_attribute16;
	END IF;

	IF 	p_x_header_rec.global_attribute17 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.global_attribute17 := p_old_header_rec.global_attribute17;
	END IF;

	IF 	p_x_header_rec.global_attribute18 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.global_attribute18 := p_old_header_rec.global_attribute18;
	END IF;

	IF 	p_x_header_rec.global_attribute19 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.global_attribute19 := p_old_header_rec.global_attribute19;
	END IF;

	IF 	p_x_header_rec.global_attribute2 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.global_attribute2 := p_old_header_rec.global_attribute2;
	END IF;

	IF 	p_x_header_rec.global_attribute20 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.global_attribute20 := p_old_header_rec.global_attribute20;
	END IF;

	IF 	p_x_header_rec.global_attribute3 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.global_attribute3 := p_old_header_rec.global_attribute3;
	END IF;

	IF 	p_x_header_rec.global_attribute4 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.global_attribute4 := p_old_header_rec.global_attribute4;
	END IF;

	IF 	p_x_header_rec.global_attribute5 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.global_attribute5 := p_old_header_rec.global_attribute5;
	END IF;

	IF 	p_x_header_rec.global_attribute6 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.global_attribute6 := p_old_header_rec.global_attribute6;
	END IF;

	IF 	p_x_header_rec.global_attribute7 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.global_attribute7 := p_old_header_rec.global_attribute7;
	END IF;

	IF 	p_x_header_rec.global_attribute8 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.global_attribute8 := p_old_header_rec.global_attribute8;
	END IF;

	IF 	p_x_header_rec.global_attribute9 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.global_attribute9 := p_old_header_rec.global_attribute9;
	END IF;

	IF 	p_x_header_rec.global_attribute_category = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.global_attribute_category := p_old_header_rec.global_attribute_category;
	END IF;

	IF 	p_x_header_rec.header_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.header_id := p_old_header_rec.header_id;
	END IF;

	IF 	p_x_header_rec.invoice_to_contact_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.invoice_to_contact_id := p_old_header_rec.invoice_to_contact_id;
	END IF;

	IF 	p_x_header_rec.invoice_to_org_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.invoice_to_org_id := p_old_header_rec.invoice_to_org_id;
	END IF;

	IF 	p_x_header_rec.invoicing_rule_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.invoicing_rule_id := p_old_header_rec.invoicing_rule_id;
	END IF;

	IF 	p_x_header_rec.last_updated_by = FND_API.G_MISS_NUM THEN
		p_x_header_rec.last_updated_by := p_old_header_rec.last_updated_by;
	END IF;

	IF 	p_x_header_rec.last_update_date = FND_API.G_MISS_DATE THEN
		p_x_header_rec.last_update_date := p_old_header_rec.last_update_date;
	END IF;

	IF 	p_x_header_rec.last_update_login = FND_API.G_MISS_NUM THEN
		p_x_header_rec.last_update_login := p_old_header_rec.last_update_login;
	END IF;

	IF 	p_x_header_rec.latest_schedule_limit = FND_API.G_MISS_NUM THEN
		p_x_header_rec.latest_schedule_limit := p_old_header_rec.latest_schedule_limit;
	END IF;

	IF 	p_x_header_rec.open_flag = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.open_flag := p_old_header_rec.open_flag;
	END IF;

	IF 	p_x_header_rec.ordered_date = FND_API.G_MISS_DATE THEN
		p_x_header_rec.ordered_date := p_old_header_rec.ordered_date;
	END IF;

	IF 	p_x_header_rec.order_number = FND_API.G_MISS_NUM THEN
		p_x_header_rec.order_number := p_old_header_rec.order_number;
	END IF;

	IF 	p_x_header_rec.order_date_type_code = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.order_date_type_code := p_old_header_rec.order_date_type_code;
	END IF;

	IF 	p_x_header_rec.order_source_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.order_source_id := p_old_header_rec.order_source_id;
	END IF;

	IF 	p_x_header_rec.order_type_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.order_type_id := p_old_header_rec.order_type_id;
	END IF;

	IF 	p_x_header_rec.order_category_code = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.order_category_code := p_old_header_rec.order_category_code;
	END IF;

	IF 	p_x_header_rec.org_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.org_id := p_old_header_rec.org_id;
	END IF;

	IF 	p_x_header_rec.orig_sys_document_ref = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.orig_sys_document_ref := p_old_header_rec.orig_sys_document_ref;
	END IF;

	IF 	p_x_header_rec.partial_shipments_allowed = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.partial_shipments_allowed := p_old_header_rec.partial_shipments_allowed;
	END IF;

	IF 	p_x_header_rec.payment_term_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.payment_term_id := p_old_header_rec.payment_term_id;
	END IF;

	IF 	p_x_header_rec.price_list_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.price_list_id := p_old_header_rec.price_list_id;
	END IF;

	IF 	p_x_header_rec.price_request_code = FND_API.G_MISS_CHAR THEN  -- PROMOTIONS SEP/01
		p_x_header_rec.price_request_code := p_old_header_rec.price_request_code;
	END IF;

	IF 	p_x_header_rec.pricing_date = FND_API.G_MISS_DATE THEN
		p_x_header_rec.pricing_date := p_old_header_rec.pricing_date;
	END IF;

	IF 	p_x_header_rec.program_application_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.program_application_id := p_old_header_rec.program_application_id;
	END IF;

	IF 	p_x_header_rec.program_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.program_id := p_old_header_rec.program_id;
	END IF;

	IF 	p_x_header_rec.program_update_date = FND_API.G_MISS_DATE THEN
		p_x_header_rec.program_update_date := p_old_header_rec.program_update_date;
	END IF;

	IF 	p_x_header_rec.request_date = FND_API.G_MISS_DATE THEN
		p_x_header_rec.request_date := p_old_header_rec.request_date;
	END IF;

	IF 	p_x_header_rec.request_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.request_id := p_old_header_rec.request_id;
	END IF;

	IF 	p_x_header_rec.return_reason_code = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.return_reason_code := p_old_header_rec.return_reason_code;
	END IF;

	IF 	p_x_header_rec.salesrep_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.salesrep_id := p_old_header_rec.salesrep_id;
	END IF;

	IF 	p_x_header_rec.sales_channel_code = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.sales_channel_code := p_old_header_rec.sales_channel_code;
	END IF;

	IF 	p_x_header_rec.shipment_priority_code = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.shipment_priority_code := p_old_header_rec.shipment_priority_code;
	END IF;

	IF 	p_x_header_rec.shipping_method_code = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.shipping_method_code := p_old_header_rec.shipping_method_code;
	END IF;

	IF 	p_x_header_rec.ship_from_org_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.ship_from_org_id := p_old_header_rec.ship_from_org_id;
	END IF;

	IF 	p_x_header_rec.ship_tolerance_above = FND_API.G_MISS_NUM THEN
		p_x_header_rec.ship_tolerance_above := p_old_header_rec.ship_tolerance_above;
	END IF;

	IF 	p_x_header_rec.ship_tolerance_below = FND_API.G_MISS_NUM THEN
		p_x_header_rec.ship_tolerance_below := p_old_header_rec.ship_tolerance_below;
	END IF;

	IF 	p_x_header_rec.ship_to_contact_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.ship_to_contact_id := p_old_header_rec.ship_to_contact_id;
	END IF;

	IF 	p_x_header_rec.ship_to_org_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.ship_to_org_id := p_old_header_rec.ship_to_org_id;
	END IF;

	IF 	p_x_header_rec.sold_from_org_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.sold_from_org_id := p_old_header_rec.sold_from_org_id;
	END IF;

	IF 	p_x_header_rec.sold_to_contact_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.sold_to_contact_id := p_old_header_rec.sold_to_contact_id;
	END IF;

	IF 	p_x_header_rec.sold_to_org_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.sold_to_org_id := p_old_header_rec.sold_to_org_id;
	END IF;

	IF 	p_x_header_rec.sold_to_phone_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.sold_to_phone_id := p_old_header_rec.sold_to_phone_id;
	END IF;

	IF 	p_x_header_rec.source_document_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.source_document_id := p_old_header_rec.source_document_id;
	END IF;

	IF 	p_x_header_rec.source_document_type_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.source_document_type_id := p_old_header_rec.source_document_type_id;
	END IF;

	IF 	p_x_header_rec.tax_exempt_flag = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.tax_exempt_flag := p_old_header_rec.tax_exempt_flag;
	END IF;

	IF 	p_x_header_rec.tax_exempt_number = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.tax_exempt_number := p_old_header_rec.tax_exempt_number;
	END IF;

	IF 	p_x_header_rec.tax_exempt_reason_code = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.tax_exempt_reason_code := p_old_header_rec.tax_exempt_reason_code;
	END IF;

	IF 	p_x_header_rec.tax_point_code = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.tax_point_code := p_old_header_rec.tax_point_code;
	END IF;

	IF 	p_x_header_rec.transactional_curr_code = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.transactional_curr_code := p_old_header_rec.transactional_curr_code;
	END IF;

	-- For bug 2916613
	IF 	p_x_header_rec.tp_attribute1 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.tp_attribute1 := p_old_header_rec.tp_attribute1;
	END IF;

	IF 	p_x_header_rec.tp_attribute10 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.tp_attribute10 := p_old_header_rec.tp_attribute10;
	END IF;

	IF 	p_x_header_rec.tp_attribute11 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.tp_attribute11 := p_old_header_rec.tp_attribute11;
	END IF;

	IF 	p_x_header_rec.tp_attribute12 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.tp_attribute12 := p_old_header_rec.tp_attribute12;
	END IF;

	IF 	p_x_header_rec.tp_attribute13 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.tp_attribute13 := p_old_header_rec.tp_attribute13;
	END IF;

	IF 	p_x_header_rec.tp_attribute14 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.tp_attribute14 := p_old_header_rec.tp_attribute14;
	END IF;

	IF 	p_x_header_rec.tp_attribute15 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.tp_attribute15 := p_old_header_rec.tp_attribute15;
	END IF;

	IF 	p_x_header_rec.tp_attribute2 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.tp_attribute2 := p_old_header_rec.tp_attribute2;
	END IF;

	IF 	p_x_header_rec.tp_attribute3 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.tp_attribute3 := p_old_header_rec.tp_attribute3;
	END IF;

	IF 	p_x_header_rec.tp_attribute4 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.tp_attribute4 := p_old_header_rec.tp_attribute4;
	END IF;

	IF 	p_x_header_rec.tp_attribute5 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.tp_attribute5 := p_old_header_rec.tp_attribute5;
	END IF;

	IF 	p_x_header_rec.tp_attribute6 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.tp_attribute6 := p_old_header_rec.tp_attribute6;
	END IF;

	IF 	p_x_header_rec.tp_attribute7 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.tp_attribute7 := p_old_header_rec.tp_attribute7;
	END IF;

	IF 	p_x_header_rec.tp_attribute8 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.tp_attribute8 := p_old_header_rec.tp_attribute8;
	END IF;

	IF 	p_x_header_rec.tp_attribute9 = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.tp_attribute9 := p_old_header_rec.tp_attribute9;
	END IF;

	IF 	p_x_header_rec.tp_context = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.tp_context := p_old_header_rec.tp_context;
	END IF;
	--End bug 2916613

	IF 	p_x_header_rec.version_number = FND_API.G_MISS_NUM THEN
		p_x_header_rec.version_number := p_old_header_rec.version_number;
	END IF;

	IF 	p_x_header_rec.payment_type_code = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.payment_type_code := p_old_header_rec.payment_type_code;
	END IF;

	IF 	p_x_header_rec.payment_amount = FND_API.G_MISS_NUM THEN
		p_x_header_rec.payment_amount := p_old_header_rec.payment_amount;
	END IF;

	IF 	p_x_header_rec.check_number = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.check_number := p_old_header_rec.check_number;
	END IF;
	--R12 CC Encryption
	--These details not stored in oe_payments table now and centrally stored in payments tables
	/*
	IF 	p_x_header_rec.credit_card_code = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.credit_card_code := p_old_header_rec.credit_card_code;
	END IF;

	IF 	p_x_header_rec.credit_card_holder_name = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.credit_card_holder_name := p_old_header_rec.credit_card_holder_name;
	END IF;

	IF 	p_x_header_rec.credit_card_number = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.credit_card_number := p_old_header_rec.credit_card_number;
	END IF;

	IF 	p_x_header_rec.credit_card_expiration_date = FND_API.G_MISS_DATE THEN
		p_x_header_rec.credit_card_expiration_date := p_old_header_rec.credit_card_expiration_date;
	END IF;

	IF 	p_x_header_rec.credit_card_approval_date = FND_API.G_MISS_DATE THEN
		p_x_header_rec.credit_card_approval_date := p_old_header_rec.credit_card_approval_date;
	END IF;

	IF 	p_x_header_rec.credit_card_approval_code = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.credit_card_approval_code := p_old_header_rec.credit_card_approval_code;
	END IF;*/
	--R12 CC Encryption

	IF 	p_x_header_rec.first_ack_code = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.first_ack_code := p_old_header_rec.first_ack_code;
	END IF;

	IF 	p_x_header_rec.first_ack_date = FND_API.G_MISS_DATE THEN
		p_x_header_rec.first_ack_date := p_old_header_rec.first_ack_date;
	END IF;

	IF 	p_x_header_rec.last_ack_code = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.last_ack_code := p_old_header_rec.last_ack_code;
	END IF;

	IF 	p_x_header_rec.last_ack_date = FND_API.G_MISS_DATE THEN
		p_x_header_rec.last_ack_date := p_old_header_rec.last_ack_date;
	END IF;

	IF 	p_x_header_rec.line_set_name = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.line_set_name := p_old_header_rec.line_set_name;
	END IF;

	IF 	p_x_header_rec.shipping_instructions = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.shipping_instructions := p_old_header_rec.shipping_instructions;
	END IF;

	IF 	p_x_header_rec.packing_instructions = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.packing_instructions := p_old_header_rec.packing_instructions;
	END IF;

	IF 	p_x_header_rec.marketing_source_code_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.marketing_source_code_id := p_old_header_rec.marketing_source_code_id;
	END IF;

	IF 	p_x_header_rec.flow_status_code = 'ENTERED' THEN
            -- QUOTING change - do not override 'ENTERED' status with old
            -- value as status should be set to entered during complete
            -- negotiation call
            IF OE_Quote_Util.G_COMPLETE_NEG = 'N' THEN
	-- flow_status_code is initilized to ENTERED
		p_x_header_rec.flow_status_code := p_old_header_rec.flow_status_code;
            END IF;
	END IF;

        -- QUOTING changes

	IF 	p_x_header_rec.quote_date = FND_API.G_MISS_DATE THEN
		p_x_header_rec.quote_date := p_old_header_rec.quote_date;
	END IF;

	IF 	p_x_header_rec.quote_number = FND_API.G_MISS_NUM THEN
		p_x_header_rec.quote_number := p_old_header_rec.quote_number;
	END IF;

	IF 	p_x_header_rec.sales_document_name = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.sales_document_name := p_old_header_rec.sales_document_name;
	END IF;

	IF 	p_x_header_rec.transaction_phase_code = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.transaction_phase_code := p_old_header_rec.transaction_phase_code;
	END IF;

	IF 	p_x_header_rec.user_status_code = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.user_status_code := p_old_header_rec.user_status_code;
	END IF;

	IF 	p_x_header_rec.draft_submitted_flag = FND_API.G_MISS_CHAR THEN
		p_x_header_rec.draft_submitted_flag := p_old_header_rec.draft_submitted_flag;
	END IF;

	IF 	p_x_header_rec.source_document_version_number = FND_API.G_MISS_NUM THEN
		p_x_header_rec.source_document_version_number := p_old_header_rec.source_document_version_number;
	END IF;

	IF 	p_x_header_rec.sold_to_site_use_id = FND_API.G_MISS_NUM THEN
		p_x_header_rec.sold_to_site_use_id := p_old_header_rec.sold_to_site_use_id;
	END IF;

        -- QUOTING changes END


        IF      p_x_header_rec.Minisite_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.Minisite_id := p_old_header_rec.Minisite_id;
        END IF;

        IF      p_x_header_rec.End_customer_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.End_customer_id := p_old_header_rec.End_customer_id;
        END IF;

        IF      p_x_header_rec.End_customer_contact_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.End_customer_contact_id := p_old_header_rec.End_customer_contact_id;
        END IF;

        IF      p_x_header_rec.End_customer_site_use_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.End_customer_site_use_id := p_old_header_rec.End_customer_site_use_id;
        END IF;

        IF      p_x_header_rec.Ib_owner = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.Ib_owner := p_old_header_rec.Ib_owner;
        END IF;

        IF      p_x_header_rec.Ib_installed_at_location = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.Ib_installed_at_location := p_old_header_rec.Ib_installed_at_location;
        END IF;

        IF      p_x_header_rec.Ib_current_location= FND_API.G_MISS_CHAR THEN
                p_x_header_rec.Ib_current_location := p_old_header_rec.Ib_current_location;
        END IF;

        IF      p_x_header_rec.supplier_signature= FND_API.G_MISS_CHAR THEN
                p_x_header_rec.supplier_signature := p_old_header_rec.supplier_signature;
        END IF;

        IF      p_x_header_rec.supplier_signature_date= FND_API.G_MISS_DATE THEN
                p_x_header_rec.supplier_signature_date := p_old_header_rec.supplier_signature_date;
        END IF;

        IF      p_x_header_rec.customer_signature= FND_API.G_MISS_CHAR THEN
                p_x_header_rec.customer_signature := p_old_header_rec.customer_signature;
        END IF;

        IF      p_x_header_rec.customer_signature_date= FND_API.G_MISS_DATE THEN
                p_x_header_rec.customer_signature_date := p_old_header_rec.customer_signature_date;
        END IF;

      /* Contract related changes */

        IF      p_x_header_rec.contract_template_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.contract_template_id := p_old_header_rec.contract_template_id;
        END IF;

        IF      p_x_header_rec.contract_source_doc_type_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.contract_source_doc_type_code := p_old_header_rec.contract_source_doc_type_code;
        END IF;

        IF      p_x_header_rec.contract_source_document_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.contract_source_document_id := p_old_header_rec.contract_source_document_id;
        END IF;

     --key Transaction Dates
        IF      p_x_header_rec.order_firmed_date = FND_API.G_MISS_DATE THEN
		p_x_header_rec.order_firmed_date := p_old_header_rec.order_firmed_date;
	END IF;

	--8219019 start

        IF      p_x_header_rec.CC_INSTRUMENT_ID = FND_API.G_MISS_NUM THEN
        	p_x_header_rec.CC_INSTRUMENT_ID := p_old_header_rec.CC_INSTRUMENT_ID;
	END IF;

        IF      p_x_header_rec.CC_INSTRUMENT_ASSIGNMENT_ID = FND_API.G_MISS_NUM THEN
        	p_x_header_rec.CC_INSTRUMENT_ASSIGNMENT_ID := p_old_header_rec.CC_INSTRUMENT_ASSIGNMENT_ID;
	END IF;

	--8219019 end


	oe_debug_pub.add('Exiting OE_HEADER_UTIL.COMPLETE_RECORD', 1);


END Complete_Record;

--  Procedure Convert_Miss_To_Null

PROCEDURE Convert_Miss_To_Null
(   p_x_header_rec        IN OUT NOCOPY  OE_Order_PUB.Header_Rec_Type
)
IS
--p_x_header_rec                  OE_Order_PUB.Header_Rec_Type := p_header_rec;
BEGIN

    oe_debug_pub.add('Entering OE_HEADER_UTIL.CONVERT_MISS_TO_NULL', 1);

    IF p_x_header_rec.accounting_rule_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.accounting_rule_id := NULL;
    END IF;

    IF p_x_header_rec.accounting_rule_duration = FND_API.G_MISS_NUM THEN
        p_x_header_rec.accounting_rule_duration := NULL;
    END IF;

    IF p_x_header_rec.agreement_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.agreement_id := NULL;
    END IF;

    IF p_x_header_rec.blanket_number = FND_API.G_MISS_NUM THEN
       p_x_header_rec.blanket_number := NULL;
    END IF;

    IF p_x_header_rec.booked_flag = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.booked_flag := NULL;
    END IF;

    IF p_x_header_rec.upgraded_flag = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.upgraded_flag := NULL;
    END IF;

    IF p_x_header_rec.booked_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.booked_date := NULL;
    END IF;

    IF p_x_header_rec.cancelled_flag = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.cancelled_flag := NULL;
    END IF;

    IF p_x_header_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute1 := NULL;
    END IF;

    IF p_x_header_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute10 := NULL;
    END IF;

    IF p_x_header_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute11 := NULL;
    END IF;

    IF p_x_header_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute12 := NULL;
    END IF;

    IF p_x_header_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute13 := NULL;
    END IF;

    IF p_x_header_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute14 := NULL;
    END IF;

    IF p_x_header_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute15 := NULL;
    END IF;

    IF p_x_header_rec.attribute16 = FND_API.G_MISS_CHAR THEN    --For bug 2184255
        p_x_header_rec.attribute16 := NULL;
    END IF;

    IF p_x_header_rec.attribute17 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute17 := NULL;
    END IF;

    IF p_x_header_rec.attribute18 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute18 := NULL;
    END IF;

    IF p_x_header_rec.attribute19 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute19 := NULL;
    END IF;

    IF p_x_header_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute2 := NULL;
    END IF;

    IF p_x_header_rec.attribute20 = FND_API.G_MISS_CHAR THEN    --For bug 2184255
        p_x_header_rec.attribute20 := NULL;
    END IF;

    IF p_x_header_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute3 := NULL;
    END IF;

    IF p_x_header_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute4 := NULL;
    END IF;

    IF p_x_header_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute5 := NULL;
    END IF;

    IF p_x_header_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute6 := NULL;
    END IF;

    IF p_x_header_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute7 := NULL;
    END IF;

    IF p_x_header_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute8 := NULL;
    END IF;

    IF p_x_header_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute9 := NULL;
    END IF;

    IF p_x_header_rec.context = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.context := NULL;
    END IF;

    IF p_x_header_rec.conversion_rate = FND_API.G_MISS_NUM THEN
        p_x_header_rec.conversion_rate := NULL;
    END IF;

    IF p_x_header_rec.conversion_rate_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.conversion_rate_date := NULL;
    END IF;

    IF p_x_header_rec.conversion_type_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.conversion_type_code := NULL;
    END IF;

    IF p_x_header_rec.CUSTOMER_PREFERENCE_SET_CODE = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.CUSTOMER_PREFERENCE_SET_CODE := NULL;
    END IF;

    IF p_x_header_rec.created_by = FND_API.G_MISS_NUM THEN
        p_x_header_rec.created_by := NULL;
    END IF;

    IF p_x_header_rec.creation_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.creation_date := NULL;
    END IF;

    IF p_x_header_rec.cust_po_number = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.cust_po_number := NULL;
    END IF;

    IF p_x_header_rec.default_fulfillment_set = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.default_fulfillment_set := NULL;
    END IF;

    IF p_x_header_rec.deliver_to_contact_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.deliver_to_contact_id := NULL;
    END IF;

    IF p_x_header_rec.deliver_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.deliver_to_org_id := NULL;
    END IF;

    IF p_x_header_rec.demand_class_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.demand_class_code := NULL;
    END IF;

    IF p_x_header_rec.expiration_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.expiration_date := NULL;
    END IF;

    IF p_x_header_rec.earliest_schedule_limit = FND_API.G_MISS_NUM THEN
        p_x_header_rec.earliest_schedule_limit := NULL;
    END IF;

    IF p_x_header_rec.fob_point_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.fob_point_code := NULL;
    END IF;

    IF p_x_header_rec.freight_carrier_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.freight_carrier_code := NULL;
    END IF;

    IF p_x_header_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.freight_terms_code := NULL;
    END IF;

    IF p_x_header_rec.fulfillment_set_name = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.fulfillment_set_name := NULL;
    END IF;

    IF p_x_header_rec.global_attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute1 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute10 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute11 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute12 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute13 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute14 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute15 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute16 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute16 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute17 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute17 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute18 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute18 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute19 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute19 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute2 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute20 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute20 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute3 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute4 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute5 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute6 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute7 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute8 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute9 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute_category = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute_category := NULL;
    END IF;

    IF p_x_header_rec.header_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.header_id := NULL;
    END IF;

    IF p_x_header_rec.invoice_to_contact_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.invoice_to_contact_id := NULL;
    END IF;

    IF p_x_header_rec.invoice_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.invoice_to_org_id := NULL;
    END IF;

    IF p_x_header_rec.invoicing_rule_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.invoicing_rule_id := NULL;
    END IF;

    IF p_x_header_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        p_x_header_rec.last_updated_by := NULL;
    END IF;

    IF p_x_header_rec.last_update_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.last_update_date := NULL;
    END IF;

    IF p_x_header_rec.last_update_login = FND_API.G_MISS_NUM THEN
        p_x_header_rec.last_update_login := NULL;
    END IF;


    IF p_x_header_rec.latest_schedule_limit = FND_API.G_MISS_NUM THEN
        p_x_header_rec.latest_schedule_limit := NULL;
    END IF;

    IF p_x_header_rec.line_set_name = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.line_set_name := NULL;
    END IF;

    IF p_x_header_rec.open_flag = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.open_flag := NULL;
    END IF;

    IF p_x_header_rec.ordered_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.ordered_date := NULL;
    END IF;

    IF p_x_header_rec.order_date_type_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.order_date_type_code := NULL;
    END IF;

    IF p_x_header_rec.order_number = FND_API.G_MISS_NUM THEN
        p_x_header_rec.order_number := NULL;
    END IF;

    IF p_x_header_rec.order_source_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.order_source_id := NULL;
    END IF;

    IF p_x_header_rec.order_type_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.order_type_id := NULL;
    END IF;
    IF p_x_header_rec.order_category_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.order_category_code := NULL;
    END IF;

    IF p_x_header_rec.org_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.org_id := NULL;
    END IF;

    IF p_x_header_rec.orig_sys_document_ref = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.orig_sys_document_ref := NULL;
    END IF;

    IF p_x_header_rec.partial_shipments_allowed = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.partial_shipments_allowed := NULL;
    END IF;

    IF p_x_header_rec.payment_term_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.payment_term_id := NULL;
    END IF;

    IF p_x_header_rec.price_list_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.price_list_id := NULL;
    END IF;

    IF p_x_header_rec.price_request_code = FND_API.G_MISS_CHAR THEN  -- PROMOTIONS SEP/01
        p_x_header_rec.price_request_code := NULL;
    END IF;

    IF p_x_header_rec.pricing_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.pricing_date := NULL;
    END IF;

    IF p_x_header_rec.program_application_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.program_application_id := NULL;
    END IF;

    IF p_x_header_rec.program_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.program_id := NULL;
    END IF;

    IF p_x_header_rec.program_update_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.program_update_date := NULL;
    END IF;

    IF p_x_header_rec.request_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.request_date := NULL;
    END IF;

    IF p_x_header_rec.request_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.request_id := NULL;
    END IF;

    IF p_x_header_rec.return_reason_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.return_reason_code := NULL;
    END IF;

    IF p_x_header_rec.salesrep_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.salesrep_id := NULL;
    END IF;

    IF p_x_header_rec.sales_channel_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.sales_channel_code := NULL;
    END IF;

    IF p_x_header_rec.shipment_priority_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.shipment_priority_code := NULL;
    END IF;

    IF p_x_header_rec.shipping_method_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.shipping_method_code := NULL;
    END IF;

    IF p_x_header_rec.ship_from_org_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.ship_from_org_id := NULL;
    END IF;

    IF p_x_header_rec.ship_tolerance_above = FND_API.G_MISS_NUM THEN
        p_x_header_rec.ship_tolerance_above := NULL;
    END IF;

    IF p_x_header_rec.ship_tolerance_below = FND_API.G_MISS_NUM THEN
        p_x_header_rec.ship_tolerance_below := NULL;
    END IF;

    IF p_x_header_rec.ship_to_contact_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.ship_to_contact_id := NULL;
    END IF;

    IF p_x_header_rec.ship_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.ship_to_org_id := NULL;
    END IF;

    IF p_x_header_rec.sold_from_org_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.sold_from_org_id := NULL;
    END IF;

    IF p_x_header_rec.sold_to_contact_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.sold_to_contact_id := NULL;
    END IF;

    IF p_x_header_rec.sold_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.sold_to_org_id := NULL;
    END IF;

    IF p_x_header_rec.sold_to_phone_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.sold_to_phone_id := NULL;
    END IF;

    IF p_x_header_rec.source_document_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.source_document_id := NULL;
    END IF;

    IF p_x_header_rec.source_document_type_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.source_document_type_id := NULL;
    END IF;

    IF p_x_header_rec.tax_exempt_flag = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.tax_exempt_flag := NULL;
    END IF;

    IF p_x_header_rec.tax_exempt_number = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.tax_exempt_number := NULL;
    END IF;

    IF p_x_header_rec.tax_exempt_reason_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.tax_exempt_reason_code := NULL;
    END IF;

    IF p_x_header_rec.tax_point_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.tax_point_code := NULL;
    END IF;

    IF p_x_header_rec.transactional_curr_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.transactional_curr_code := NULL;
    END IF;

    IF p_x_header_rec.version_number = FND_API.G_MISS_NUM THEN
        p_x_header_rec.version_number := NULL;
    END IF;

    IF p_x_header_rec.payment_type_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.payment_type_code := NULL;
    END IF;

    IF p_x_header_rec.payment_amount = FND_API.G_MISS_NUM THEN
        p_x_header_rec.payment_amount := NULL;
    END IF;

    IF p_x_header_rec.check_number = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.check_number := NULL;
    END IF;
    --R12 CC Encryption
    --These details not stored in oe_payments table now and centrally stored in payments tables
    /*
    IF p_x_header_rec.credit_card_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.credit_card_code := NULL;
    END IF;

    IF p_x_header_rec.credit_card_holder_name = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.credit_card_holder_name := NULL;
    END IF;

    IF p_x_header_rec.credit_card_number = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.credit_card_number := NULL;
    END IF;

    IF p_x_header_rec.credit_card_expiration_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.credit_card_expiration_date := NULL;
    END IF;

    IF p_x_header_rec.credit_card_approval_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.credit_card_approval_date := NULL;
    END IF;

    IF p_x_header_rec.credit_card_approval_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.credit_card_approval_code := NULL;
    END IF;*/
    --R12 CC Encryption

    IF p_x_header_rec.first_ack_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.first_ack_code := NULL;
    END IF;

    IF p_x_header_rec.first_ack_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.first_ack_date := NULL;
    END IF;

    IF p_x_header_rec.last_ack_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.last_ack_code := NULL;
    END IF;

    IF p_x_header_rec.last_ack_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.last_ack_date := NULL;
    END IF;

    IF p_x_header_rec.shipping_instructions = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.shipping_instructions := NULL;
    END IF;

    IF p_x_header_rec.packing_instructions = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.packing_instructions := NULL;
    END IF;

    IF p_x_header_rec.flow_status_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.flow_status_code := NULL;
    END IF;

    IF p_x_header_rec.marketing_source_code_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.marketing_source_code_id := NULL;
    END IF;

     IF p_x_header_rec.change_sequence = FND_API.G_MISS_CHAR THEN --2416561
        p_x_header_rec.change_sequence := NULL;
    END IF;

    -- QUOTING changes

    IF p_x_header_rec.quote_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.quote_date := NULL;
    END IF;

    IF p_x_header_rec.quote_number = FND_API.G_MISS_NUM THEN
        p_x_header_rec.quote_number := NULL;
    END IF;

    IF p_x_header_rec.sales_document_name = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.sales_document_name := NULL;
    END IF;

    IF p_x_header_rec.transaction_phase_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.transaction_phase_code := NULL;
    END IF;

    IF p_x_header_rec.user_status_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.user_status_code := NULL;
    END IF;

    IF p_x_header_rec.draft_submitted_flag = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.draft_submitted_flag := NULL;
    END IF;

    IF p_x_header_rec.source_document_version_number = FND_API.G_MISS_NUM THEN
        p_x_header_rec.source_document_version_number := NULL;
    END IF;

    IF p_x_header_rec.sold_to_site_use_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.sold_to_site_use_id := NULL;
    END IF;

    -- QUOTING changes END

    IF p_x_header_rec.Minisite_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.Minisite_id := NULL;
    END IF;

    IF p_x_header_rec.End_customer_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.End_customer_id := NULL;
    END IF;

    IF p_x_header_rec.End_customer_contact_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.End_customer_contact_id := NULL;
    END IF;

    IF p_x_header_rec.End_customer_site_use_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.End_customer_site_use_id := NULL;
    END IF;

    IF p_x_header_rec.Ib_owner = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.Ib_owner := NULL;
    END IF;

    IF p_x_header_rec.Ib_installed_at_location = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.Ib_installed_at_location := NULL;
    END IF;

    IF p_x_header_rec.Ib_current_location = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.Ib_current_location := NULL;
    END IF;

   IF p_x_header_rec.supplier_signature = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.supplier_signature := NULL;
    END IF;

   IF p_x_header_rec.supplier_signature_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.supplier_signature_date := NULL;
    END IF;

   IF p_x_header_rec.customer_signature = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.customer_signature := NULL;
    END IF;

  IF p_x_header_rec.customer_signature_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.customer_signature_date := NULL;
    END IF;

    IF p_x_header_rec.contract_template_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.contract_template_id := NULL;
    END IF;

    IF p_x_header_rec.contract_source_doc_type_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.contract_source_doc_type_code := NULL;
    END IF;

    IF p_x_header_rec.contract_source_document_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.contract_source_document_id := NULL;
    END IF;

--key Transaction dates
    IF p_x_header_rec.order_firmed_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.order_firmed_date := NULL;
    END IF;

   --8219019 start

    IF p_x_header_rec.CC_INSTRUMENT_ID = FND_API.G_MISS_NUM THEN
       p_x_header_rec.CC_INSTRUMENT_ID := NULL;
    END IF;

    IF p_x_header_rec.CC_INSTRUMENT_ASSIGNMENT_ID = FND_API.G_MISS_NUM THEN
    	p_x_header_rec.CC_INSTRUMENT_ASSIGNMENT_ID := NULL;
    END IF;

   --8219019 end

    oe_debug_pub.add('Exiting OE_HEADER_UTIL.CONVERT_MISS_TO_NULL', 1);


END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_header_rec                    IN  OUT  NOCOPY OE_Order_PUB.Header_Rec_Type
)
IS
	l_org_id		NUMBER;
        l_lock_control          NUMBER;
-- added for notification framework
      l_index                  NUMBER;
      l_return_status          VARCHAR2(1);
BEGIN

    oe_debug_pub.add('Entering OE_HEADER_UTIL.UPDATE_ROW', 1);
    --Commented for MOAC start
    /*l_org_id := OE_GLOBALS.G_ORG_ID;

    IF l_org_id IS NULL THEN
      OE_GLOBALS.Set_Context;
      l_org_id := OE_GLOBALS.G_ORG_ID;
    END IF;*/
    --Commented for MOAC end
    -- we need to increment lock_control by 1,
    -- everytime there is an update on the record.

    SELECT lock_control
    INTO   l_lock_control
    FROM   OE_ORDER_HEADERS
    WHERE  header_id = p_header_rec.header_id;

    l_lock_control := l_lock_control + 1;

  -- calling notification framework to update global picture
  -- check code release level first. Notification framework is at Pack H level
   IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
      OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_Header_rec =>p_header_rec,
                    p_header_id => p_header_rec.header_id,
                    x_index => l_index,
                    x_return_status => l_return_status);

      OE_DEBUG_PUB.ADD('Update_Global Return Status from OE_HEADER_UTIL.update_row is: ' || l_return_status);
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        OE_DEBUG_PUB.ADD('EVENT NOTIFY - Unexpected Error');
        OE_DEBUG_PUB.ADD('Exiting OE_HEADER_UTIL.Update_ROW', 1);
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        OE_DEBUG_PUB.ADD('Update_Global_Picture Error in OE_HEADER_UTIL.Update_row');
        OE_DEBUG_PUB.ADD('Exiting OE_HEADER_UTIL.Update_ROW', 1);
	RAISE FND_API.G_EXC_ERROR;
      END IF;
  END IF; /*code_release_level*/
  -- notification framework end

    UPDATE  OE_ORDER_HEADERS
    SET     ACCOUNTING_RULE_ID             = p_header_rec.accounting_rule_id
    ,       ACCOUNTING_RULE_DURATION       = p_header_rec.accounting_rule_duration
    ,       AGREEMENT_ID                   = p_header_rec.agreement_id
    ,       ATTRIBUTE1                     = p_header_rec.attribute1
    ,       ATTRIBUTE10                    = p_header_rec.attribute10
    ,       ATTRIBUTE11                    = p_header_rec.attribute11
    ,       ATTRIBUTE12                    = p_header_rec.attribute12
    ,       ATTRIBUTE13                    = p_header_rec.attribute13
    ,       ATTRIBUTE14                    = p_header_rec.attribute14
    ,       ATTRIBUTE15                    = p_header_rec.attribute15
    ,       ATTRIBUTE16                    = p_header_rec.attribute16   --For bug 2184255
    ,       ATTRIBUTE17                    = p_header_rec.attribute17
    ,       ATTRIBUTE18                    = p_header_rec.attribute18
    ,       ATTRIBUTE19                    = p_header_rec.attribute19
    ,       ATTRIBUTE2                     = p_header_rec.attribute2
    ,       ATTRIBUTE20                    = p_header_rec.attribute20
    ,       ATTRIBUTE3                     = p_header_rec.attribute3
    ,       ATTRIBUTE4                     = p_header_rec.attribute4
    ,       ATTRIBUTE5                     = p_header_rec.attribute5
    ,       ATTRIBUTE6                     = p_header_rec.attribute6
    ,       ATTRIBUTE7                     = p_header_rec.attribute7
    ,       ATTRIBUTE8                     = p_header_rec.attribute8
    ,       ATTRIBUTE9                     = p_header_rec.attribute9
    ,       BLANKET_NUMBER                 = p_header_rec.Blanket_Number
    ,       BOOKED_FLAG                    = p_header_rec.booked_flag
    ,       BOOKED_DATE				       = p_header_rec.booked_date
    ,       CANCELLED_FLAG                 = p_header_rec.cancelled_flag
    ,       CONTEXT                        = p_header_rec.context
    ,       CONVERSION_RATE                = p_header_rec.conversion_rate
    ,       CONVERSION_RATE_DATE           = p_header_rec.conversion_rate_date
    ,       CONVERSION_TYPE_CODE           = p_header_rec.conversion_type_code
    ,       CUSTOMER_PREFERENCE_SET_CODE   = p_header_rec.CUSTOMER_PREFERENCE_SET_CODE
    ,       CREATED_BY                     = p_header_rec.created_by
    ,       CREATION_DATE                  = p_header_rec.creation_date
    ,       CUST_PO_NUMBER                 = p_header_rec.cust_po_number
    ,       DELIVER_TO_CONTACT_ID          = p_header_rec.deliver_to_contact_id
    ,       DELIVER_TO_ORG_ID              = p_header_rec.deliver_to_org_id
    ,       DEMAND_CLASS_CODE              = p_header_rec.demand_class_code
    ,       EXPIRATION_DATE                = p_header_rec.expiration_date
    ,       EARLIEST_SCHEDULE_LIMIT        = p_header_rec.earliest_schedule_limit
    ,       FIRST_ACK_CODE                 = p_header_rec.first_ack_code
    ,       FIRST_ACK_DATE                 = p_header_rec.first_ack_date
    ,       FOB_POINT_CODE                 = p_header_rec.fob_point_code
    ,       FREIGHT_CARRIER_CODE           = p_header_rec.freight_carrier_code
    ,       FREIGHT_TERMS_CODE             = p_header_rec.freight_terms_code
    ,       GLOBAL_ATTRIBUTE1              = p_header_rec.global_attribute1
    ,       GLOBAL_ATTRIBUTE10             = p_header_rec.global_attribute10
    ,       GLOBAL_ATTRIBUTE11             = p_header_rec.global_attribute11
    ,       GLOBAL_ATTRIBUTE12             = p_header_rec.global_attribute12
    ,       GLOBAL_ATTRIBUTE13             = p_header_rec.global_attribute13
    ,       GLOBAL_ATTRIBUTE14             = p_header_rec.global_attribute14
    ,       GLOBAL_ATTRIBUTE15             = p_header_rec.global_attribute15
    ,       GLOBAL_ATTRIBUTE16             = p_header_rec.global_attribute16
    ,       GLOBAL_ATTRIBUTE17             = p_header_rec.global_attribute17
    ,       GLOBAL_ATTRIBUTE18             = p_header_rec.global_attribute18
    ,       GLOBAL_ATTRIBUTE19             = p_header_rec.global_attribute19
    ,       GLOBAL_ATTRIBUTE2              = p_header_rec.global_attribute2
    ,       GLOBAL_ATTRIBUTE20             = p_header_rec.global_attribute20
    ,       GLOBAL_ATTRIBUTE3              = p_header_rec.global_attribute3
    ,       GLOBAL_ATTRIBUTE4              = p_header_rec.global_attribute4
    ,       GLOBAL_ATTRIBUTE5              = p_header_rec.global_attribute5
    ,       GLOBAL_ATTRIBUTE6              = p_header_rec.global_attribute6
    ,       GLOBAL_ATTRIBUTE7              = p_header_rec.global_attribute7
    ,       GLOBAL_ATTRIBUTE8              = p_header_rec.global_attribute8
    ,       GLOBAL_ATTRIBUTE9              = p_header_rec.global_attribute9
    ,       GLOBAL_ATTRIBUTE_CATEGORY      = p_header_rec.global_attribute_category
    --,       HEADER_ID                      = p_header_rec.header_id

    ,       INVOICE_TO_CONTACT_ID          = p_header_rec.invoice_to_contact_id
    ,       INVOICE_TO_ORG_ID              = p_header_rec.invoice_to_org_id
    ,       INVOICING_RULE_ID              = p_header_rec.invoicing_rule_id
    ,       LAST_ACK_CODE                  = p_header_rec.last_ack_code
    ,       LAST_ACK_DATE                  = p_header_rec.last_ack_date
    ,       LAST_UPDATED_BY                = p_header_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_header_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_header_rec.last_update_login
    ,	    LATEST_SCHEDULE_LIMIT	   = p_header_rec.latest_schedule_limit
    ,       OPEN_FLAG                      = p_header_rec.open_flag
    ,       ORDERED_DATE                   = p_header_rec.ordered_date
    ,       ORDER_DATE_TYPE_CODE	   = p_header_rec.order_date_type_code
    ,       ORDER_NUMBER                   = p_header_rec.order_number
    ,       ORDER_SOURCE_ID                = p_header_rec.order_source_id
    ,       ORDER_TYPE_ID                  = p_header_rec.order_type_id
    ,       ORDER_CATEGORY_CODE            = p_header_rec.order_category_code
-- Org_id should not allowed to update
--    ,       ORG_ID                         = p_header_rec.org_id
    ,       ORIG_SYS_DOCUMENT_REF          = p_header_rec.orig_sys_document_ref
    ,       SOURCE_DOCUMENT_ID             = p_header_rec.source_document_id
    ,       SOURCE_DOCUMENT_TYPE_ID        = p_header_rec.source_document_type_id
    ,       PARTIAL_SHIPMENTS_ALLOWED      = p_header_rec.partial_shipments_allowed
    ,       PAYMENT_TERM_ID                = p_header_rec.payment_term_id
    ,       PRICE_LIST_ID                  = p_header_rec.price_list_id
    ,       PRICE_REQUEST_CODE             = p_header_rec.price_request_code  -- PROMOTIONS SEP/01
    ,       PRICING_DATE                   = p_header_rec.pricing_date
    ,       PROGRAM_APPLICATION_ID         = p_header_rec.program_application_id
    ,       PROGRAM_ID                     = p_header_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_header_rec.program_update_date


    ,       REQUEST_DATE                   = p_header_rec.request_date
    ,       REQUEST_ID                     = p_header_rec.request_id
    ,       RETURN_REASON_CODE             = p_header_rec.return_reason_code
    ,       salesrep_id                    = p_header_rec.salesrep_id
    ,       SALES_CHANNEL_CODE             = p_header_rec.sales_channel_code
    ,       SHIPMENT_PRIORITY_CODE         = p_header_rec.shipment_priority_code
    ,       SHIPPING_METHOD_CODE           = p_header_rec.shipping_method_code
    ,       SHIP_FROM_ORG_ID               = p_header_rec.ship_from_org_id
    ,       SHIP_TOLERANCE_ABOVE           = p_header_rec.ship_tolerance_above
    ,       SHIP_TOLERANCE_BELOW           = p_header_rec.ship_tolerance_below
    ,       SHIP_TO_CONTACT_ID             = p_header_rec.ship_to_contact_id
    ,       SHIP_TO_ORG_ID                 = p_header_rec.ship_to_org_id
    --,       SOLD_FROM_ORG_ID			   = p_header_rec.sold_from_org_id
    ,       SOLD_TO_CONTACT_ID             = p_header_rec.sold_to_contact_id
    ,       SOLD_TO_ORG_ID                 = p_header_rec.sold_to_org_id
    ,       SOLD_TO_PHONE_ID               = p_header_rec.sold_to_phone_id
    ,       TAX_EXEMPT_FLAG                = p_header_rec.tax_exempt_flag
    ,       TAX_EXEMPT_NUMBER              = p_header_rec.tax_exempt_number
    ,       TAX_EXEMPT_REASON_CODE         = p_header_rec.tax_exempt_reason_code
    ,       TAX_POINT_CODE                 = p_header_rec.tax_point_code
    ,       TRANSACTIONAL_CURR_CODE        = p_header_rec.transactional_curr_code
    ,       VERSION_NUMBER                 = p_header_rec.version_number
    ,       PAYMENT_TYPE_CODE              = p_header_rec.payment_type_code
    ,       PAYMENT_AMOUNT                 = p_header_rec.payment_amount
    ,       CHECK_NUMBER                   = p_header_rec.check_number
    /*,       CREDIT_CARD_CODE               = p_header_rec.credit_card_code --R12 CC Encryption
    ,       CREDIT_CARD_HOLDER_NAME        = p_header_rec.credit_card_holder_name
    ,       CREDIT_CARD_NUMBER             = p_header_rec.credit_card_number
    ,       CREDIT_CARD_EXPIRATION_DATE    = p_header_rec.credit_card_expiration_date
    ,       CREDIT_CARD_APPROVAL_DATE      = p_header_rec.credit_card_approval_date
    ,       CREDIT_CARD_APPROVAL_CODE      = p_header_rec.credit_card_approval_code*/ --R12 CC Encryption
    ,       CHANGE_SEQUENCE      	   = p_header_rec.change_sequence
    --,       DROP_SHIP_FLAG      	   = p_header_rec.drop_ship_flag
    --,       CUSTOMER_PAYMENT_TERM_ID       = p_header_rec.customer_payment_term_id
    ,       SHIPPING_INSTRUCTIONS       = p_header_rec.shipping_instructions
    ,       PACKING_INSTRUCTIONS        = p_header_rec.packing_instructions
    ,       FLOW_STATUS_CODE 		= p_header_rec.flow_status_code
    ,       MARKETING_SOURCE_CODE_ID = p_header_rec.marketing_source_code_id
    ,       DEFAULT_FULFILLMENT_SET        = p_header_rec.default_fulfillment_set
    ,       FULFILLMENT_SET_NAME           = p_header_rec.fulfillment_set_name
    ,       LINE_SET_NAME                  = p_header_rec.line_set_name
    ,       LOCK_CONTROL                = l_lock_control
    ,       TP_CONTEXT                        = p_header_rec.TP_context  --added for bug 3977624
    ,       TP_ATTRIBUTE1                     = p_header_rec.TP_attribute1
    ,       TP_ATTRIBUTE10                    = p_header_rec.TP_attribute10
    ,       TP_ATTRIBUTE11                    = p_header_rec.TP_attribute11
    ,       TP_ATTRIBUTE12                    = p_header_rec.TP_attribute12
    ,       TP_ATTRIBUTE13                    = p_header_rec.TP_attribute13
    ,       TP_ATTRIBUTE14                    = p_header_rec.TP_attribute14
    ,       TP_ATTRIBUTE15                    = p_header_rec.TP_attribute15
    ,       TP_ATTRIBUTE2                     = p_header_rec.TP_attribute2
    ,       TP_ATTRIBUTE3                     = p_header_rec.TP_attribute3
    ,       TP_ATTRIBUTE4                     = p_header_rec.TP_attribute4
    ,       TP_ATTRIBUTE5                     = p_header_rec.TP_attribute5
    ,       TP_ATTRIBUTE6                     = p_header_rec.TP_attribute6
    ,       TP_ATTRIBUTE7                     = p_header_rec.TP_attribute7
    ,       TP_ATTRIBUTE8                     = p_header_rec.TP_attribute8
    ,       TP_ATTRIBUTE9                     = p_header_rec.TP_attribute9
    ,       XML_MESSAGE_ID                    = p_header_rec.xml_message_id

    -- QUOTING changes
    ,       quote_date      	           = p_header_rec.quote_date
    ,       quote_number      	           = p_header_rec.quote_number
    ,       sales_document_name            = p_header_rec.sales_document_name
    ,       transaction_phase_code         = p_header_rec.transaction_phase_code
    ,       user_status_code               = p_header_rec.user_status_code
    ,       draft_submitted_flag           = p_header_rec.draft_submitted_flag
    ,       source_document_version_number = p_header_rec.source_document_version_number
    ,       sold_to_site_use_id            = p_header_rec.sold_to_site_use_id
    -- QUOTING changes END

    ,       Minisite_Id                       = p_header_rec.minisite_id
    ,       End_customer_Id                   = p_header_rec.End_customer_id
    ,       End_customer_contact_Id           = p_header_rec.End_customer_contact_id
    ,       End_customer_site_use_Id          = p_header_rec.End_customer_site_use_id
    ,       Ib_owner                          = p_header_rec.Ib_owner
    ,       Ib_installed_at_location          = p_header_rec.Ib_installed_at_location
    ,       Ib_current_location               = p_header_rec.Ib_current_location
    ,       supplier_signature                = p_header_rec.supplier_signature
    ,       supplier_signature_date           = p_header_rec.supplier_signature_date
    ,       customer_signature                = p_header_rec.customer_signature
    ,       customer_signature_date           = p_header_rec.customer_signature_date
    ,       order_firmed_date                 = p_header_rec.order_firmed_date   --key transaction dates
    WHERE   HEADER_ID = p_header_rec.header_id;
   /* AND
   (NVL(ORG_ID,NVL(l_org_id,0))= NVL(l_org_id,0))
    ;*/

    p_header_rec.lock_control := l_lock_control;

    -- aksingh update the operation to NULL and update the cache with
    -- record
    oe_order_cache.g_header_rec := p_header_rec;
    oe_order_cache.g_header_rec.operation := null;

    -- Below line commented because as g_header_rec is now global, no need
    -- to call below procedure to update, updated directly above

    -- OE_Order_Cache.Set_Order_Header(p_header_rec);

    oe_debug_pub.add('Exiting OE_HEADER_UTIL.UPDATE_ROW', 1);

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row;

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_header_rec                    IN  OUT  NOCOPY OE_Order_PUB.Header_Rec_Type
)
IS
	l_org_id	NUMBER;
	l_upgraded_flag varchar2(1) ;
        l_lock_control  NUMBER := 1;
        l_index    NUMBER;
        l_return_status VARCHAR2(1);
        l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

    oe_debug_pub.add('Entering OE_HEADER_UTIL.INSERT_ROW', 1);

    --MOAC change
    OE_GLOBALS.Set_Context;
    l_org_id := OE_GLOBALS.G_ORG_ID;
    IF l_org_id IS NULL THEN
         -- org_id is null, don't do insert. raise an error
         If l_debug_level > 0 Then
           oe_debug_pub.add('Org_Id is NULL',1);
         End If;
         FND_MESSAGE.SET_NAME('FND','MO_ORG_REQUIRED');
     	 FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
    END IF;


    INSERT  INTO OE_ORDER_HEADERS
    (       ACCOUNTING_RULE_ID
    ,       ACCOUNTING_RULE_DURATION
    ,       AGREEMENT_ID
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE16   --For bug 2184255
    ,       ATTRIBUTE17
    ,       ATTRIBUTE18
    ,       ATTRIBUTE19
    ,       ATTRIBUTE2
    ,       ATTRIBUTE20
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       BLANKET_NUMBER
    ,       BOOKED_FLAG
    ,       BOOKED_DATE
    ,       CANCELLED_FLAG
    ,       CONTEXT
    ,       CONVERSION_RATE
    ,       CONVERSION_RATE_DATE
    ,       CONVERSION_TYPE_CODE
    ,       CUSTOMER_PREFERENCE_SET_CODE
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CUST_PO_NUMBER
    ,       DELIVER_TO_CONTACT_ID
    ,       DELIVER_TO_ORG_ID
    ,       DEMAND_CLASS_CODE
    ,       FIRST_ACK_CODE
    ,       FIRST_ACK_DATE
    ,       EXPIRATION_DATE
    ,	    EARLIEST_SCHEDULE_LIMIT
    ,       FOB_POINT_CODE
    ,       FREIGHT_CARRIER_CODE
    ,       FREIGHT_TERMS_CODE
    ,       GLOBAL_ATTRIBUTE1
    ,       GLOBAL_ATTRIBUTE10
    ,       GLOBAL_ATTRIBUTE11
    ,       GLOBAL_ATTRIBUTE12
    ,       GLOBAL_ATTRIBUTE13
    ,       GLOBAL_ATTRIBUTE14
    ,       GLOBAL_ATTRIBUTE15
    ,       GLOBAL_ATTRIBUTE16
    ,       GLOBAL_ATTRIBUTE17
    ,       GLOBAL_ATTRIBUTE18
    ,       GLOBAL_ATTRIBUTE19
    ,       GLOBAL_ATTRIBUTE2
    ,       GLOBAL_ATTRIBUTE20
    ,       GLOBAL_ATTRIBUTE3
    ,       GLOBAL_ATTRIBUTE4
    ,       GLOBAL_ATTRIBUTE5
    ,       GLOBAL_ATTRIBUTE6
    ,       GLOBAL_ATTRIBUTE7
    ,       GLOBAL_ATTRIBUTE8
    ,       GLOBAL_ATTRIBUTE9
    ,       GLOBAL_ATTRIBUTE_CATEGORY
    ,       HEADER_ID

    ,       INVOICE_TO_CONTACT_ID
    ,       INVOICE_TO_ORG_ID
    ,       INVOICING_RULE_ID
    ,       LAST_ACK_CODE
    ,       LAST_ACK_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LATEST_SCHEDULE_LIMIT
    ,       OPEN_FLAG
    ,       ORDERED_DATE
    ,       ORDER_DATE_TYPE_CODE
    ,       ORDER_NUMBER
    ,       ORDER_SOURCE_ID
    ,       ORDER_TYPE_ID
    ,       ORDER_CATEGORY_CODE
    ,       ORG_ID                    --MOAC change. Remove the comment out
    ,       ORIG_SYS_DOCUMENT_REF
    ,       PARTIAL_SHIPMENTS_ALLOWED
    ,       PAYMENT_TERM_ID
    ,       PRICE_LIST_ID
    ,       PRICE_REQUEST_CODE -- PROMOTIONS SEP/01
    ,       PRICING_DATE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_DATE
    ,       REQUEST_ID
    ,       RETURN_REASON_CODE
    ,       SALESREP_ID
    ,       SALES_CHANNEL_CODE
    ,       SHIPMENT_PRIORITY_CODE
    ,       SHIPPING_METHOD_CODE
    ,       SHIP_FROM_ORG_ID
    ,       SHIP_TOLERANCE_ABOVE
    ,       SHIP_TOLERANCE_BELOW
    ,       SHIP_TO_CONTACT_ID
    ,       SHIP_TO_ORG_ID
    ,	  SOLD_FROM_ORG_ID
    ,       SOLD_TO_CONTACT_ID
    ,       SOLD_TO_ORG_ID
    ,       SOLD_TO_PHONE_ID
    ,       SOURCE_DOCUMENT_ID
    ,       SOURCE_DOCUMENT_TYPE_ID
    ,       TAX_EXEMPT_FLAG
    ,       TAX_EXEMPT_NUMBER
    ,       TAX_EXEMPT_REASON_CODE
    ,       TAX_POINT_CODE
    ,       TRANSACTIONAL_CURR_CODE
    ,       VERSION_NUMBER
    ,       PAYMENT_TYPE_CODE
    ,       PAYMENT_AMOUNT
    ,       CHECK_NUMBER
    /*,       CREDIT_CARD_CODE --R12 CC Encryption
    ,       CREDIT_CARD_HOLDER_NAME
    ,       CREDIT_CARD_NUMBER
    ,       CREDIT_CARD_EXPIRATION_DATE
    ,       CREDIT_CARD_APPROVAL_DATE
    ,       CREDIT_CARD_APPROVAL_CODE*/ --R12 CC Encryption
    ,       CHANGE_SEQUENCE
   -- ,       DROP_SHIP_FLAG
  --  ,       CUSTOMER_PAYMENT_TERM_ID
    ,       SHIPPING_INSTRUCTIONS
    ,       PACKING_INSTRUCTIONS
    ,       FLOW_STATUS_CODE
    ,       MARKETING_SOURCE_CODE_ID
    ,       DEFAULT_FULFILLMENT_SET
    ,       FULFILLMENT_SET_NAME
    ,       LINE_SET_NAME
    ,       TP_ATTRIBUTE1
    ,       TP_ATTRIBUTE10
    ,       TP_ATTRIBUTE11
    ,       TP_ATTRIBUTE12
    ,       TP_ATTRIBUTE13
    ,       TP_ATTRIBUTE14
    ,       TP_ATTRIBUTE15
    ,       TP_ATTRIBUTE2
    ,       TP_ATTRIBUTE3
    ,       TP_ATTRIBUTE4
    ,       TP_ATTRIBUTE5
    ,       TP_ATTRIBUTE6
    ,       TP_ATTRIBUTE7
    ,       TP_ATTRIBUTE8
    ,       TP_ATTRIBUTE9
    ,       TP_CONTEXT
    ,       XML_MESSAGE_ID
    ,       upgraded_flag
    ,       LOCK_CONTROL

   -- QUOTING changes
    ,       quote_date
    ,       quote_number
    ,       sales_document_name
    ,       transaction_phase_code
    ,       user_status_code
    ,       draft_submitted_flag
    ,       source_document_version_number
    ,       sold_to_site_use_id
    -- QUOTING changes END

    ,       Minisite_Id
    ,       Ib_owner
    ,       Ib_installed_at_location
    ,       Ib_current_location
    ,       End_customer_id
    ,       End_customer_contact_id
    ,       End_customer_site_use_id
    ,       Supplier_signature
    ,       Supplier_signature_date
    ,       customer_signature
    ,       customer_signature_date
   --key transaction dates
    ,       order_firmed_date
    )
    VALUES
    (       p_header_rec.accounting_rule_id
    ,       p_header_rec.accounting_rule_duration
    ,       p_header_rec.agreement_id
    ,       p_header_rec.attribute1
    ,       p_header_rec.attribute10
    ,       p_header_rec.attribute11
    ,       p_header_rec.attribute12
    ,       p_header_rec.attribute13
    ,       p_header_rec.attribute14
    ,       p_header_rec.attribute15
    ,       p_header_rec.attribute16   --For bug 2184255
    ,       p_header_rec.attribute17
    ,       p_header_rec.attribute18
    ,       p_header_rec.attribute19
    ,       p_header_rec.attribute2
    ,       p_header_rec.attribute20
    ,       p_header_rec.attribute3
    ,       p_header_rec.attribute4
    ,       p_header_rec.attribute5
    ,       p_header_rec.attribute6
    ,       p_header_rec.attribute7
    ,       p_header_rec.attribute8
    ,       p_header_rec.attribute9
    ,       p_header_rec.Blanket_Number
    ,       p_header_rec.booked_flag
    ,       p_header_rec.booked_date
    ,       p_header_rec.cancelled_flag
    ,       p_header_rec.context
    ,       p_header_rec.conversion_rate
    ,       p_header_rec.conversion_rate_date
    ,       p_header_rec.conversion_type_code
    ,       p_header_rec.CUSTOMER_PREFERENCE_SET_CODE
    ,       p_header_rec.created_by
    ,       p_header_rec.creation_date
    ,       p_header_rec.cust_po_number
    ,       p_header_rec.deliver_to_contact_id
    ,       p_header_rec.deliver_to_org_id
    ,       p_header_rec.demand_class_code
    ,       p_header_rec.first_ack_code
    ,       p_header_rec.first_ack_date
    ,       p_header_rec.expiration_date
    ,       p_header_rec.earliest_schedule_limit
    ,       p_header_rec.fob_point_code
    ,       p_header_rec.freight_carrier_code
    ,       p_header_rec.freight_terms_code
    ,       p_header_rec.global_attribute1
    ,       p_header_rec.global_attribute10
    ,       p_header_rec.global_attribute11
    ,       p_header_rec.global_attribute12
    ,       p_header_rec.global_attribute13
    ,       p_header_rec.global_attribute14
    ,       p_header_rec.global_attribute15
    ,       p_header_rec.global_attribute16
    ,       p_header_rec.global_attribute17
    ,       p_header_rec.global_attribute18
    ,       p_header_rec.global_attribute19
    ,       p_header_rec.global_attribute2
    ,       p_header_rec.global_attribute20
    ,       p_header_rec.global_attribute3
    ,       p_header_rec.global_attribute4
    ,       p_header_rec.global_attribute5
    ,       p_header_rec.global_attribute6
    ,       p_header_rec.global_attribute7
    ,       p_header_rec.global_attribute8
    ,       p_header_rec.global_attribute9
    ,       p_header_rec.global_attribute_category
    ,       p_header_rec.header_id
    ,       p_header_rec.invoice_to_contact_id
    ,       p_header_rec.invoice_to_org_id
    ,       p_header_rec.invoicing_rule_id
    ,       p_header_rec.last_ack_code
    ,       p_header_rec.last_ack_date
    ,       p_header_rec.last_updated_by
    ,       p_header_rec.last_update_date
    ,       p_header_rec.last_update_login
    ,       p_header_rec.latest_schedule_limit
    ,       p_header_rec.open_flag
    ,       p_header_rec.ordered_date
    ,       p_header_rec.order_date_type_code
    ,       p_header_rec.order_number
    ,       p_header_rec.order_source_id
    ,       p_header_rec.order_type_id
    ,       p_header_rec.order_category_code
    ,       l_org_id                            --MOAC change. Remove the comment
    ,       p_header_rec.orig_sys_document_ref
    ,       p_header_rec.partial_shipments_allowed
    ,       p_header_rec.payment_term_id
    ,       p_header_rec.price_list_id
    ,       p_header_rec.price_request_code -- PROMOTIONS SEP/01
    ,       p_header_rec.pricing_date
    ,       p_header_rec.program_application_id
    ,       p_header_rec.program_id
    ,       p_header_rec.program_update_date
    ,       p_header_rec.request_date
    ,       p_header_rec.request_id
    ,       p_header_rec.return_reason_code
    ,       p_header_rec.salesrep_id
    ,       p_header_rec.sales_channel_code
    ,       p_header_rec.shipment_priority_code
    ,       p_header_rec.shipping_method_code
    ,       p_header_rec.ship_from_org_id
    ,       p_header_rec.ship_tolerance_above
    ,       p_header_rec.ship_tolerance_below
    ,       p_header_rec.ship_to_contact_id
    ,       p_header_rec.ship_to_org_id
    ,       l_org_id
    ,       p_header_rec.sold_to_contact_id
    ,       p_header_rec.sold_to_org_id
    ,       p_header_rec.sold_to_phone_id
    ,       p_header_rec.source_document_id
    ,       p_header_rec.source_document_type_id
    ,       p_header_rec.tax_exempt_flag
    ,       p_header_rec.tax_exempt_number
    ,       p_header_rec.tax_exempt_reason_code
    ,       p_header_rec.tax_point_code
    ,       p_header_rec.transactional_curr_code
    ,       p_header_rec.version_number
    ,       p_header_rec.payment_type_code
    ,       p_header_rec.payment_amount
    ,       p_header_rec.check_number
    /*,       p_header_rec.credit_card_code --R12 CC Encryption
    ,       p_header_rec.credit_card_holder_name
    ,       p_header_rec.credit_card_number
    ,       p_header_rec.credit_card_expiration_date
    ,       p_header_rec.credit_card_approval_date
    ,       p_header_rec.credit_card_approval_code*/ --R12 CC Encryption
    ,       p_header_rec.change_sequence
 --   ,       p_header_rec.drop_ship_flag
 --   ,       p_header_rec.customer_payment_term_id
    ,	  p_header_rec.shipping_instructions
    ,	  p_header_rec.packing_instructions
    ,       p_header_rec.flow_status_code
    ,       p_header_rec.marketing_source_code_id
    ,       p_header_rec.default_fulfillment_set
    ,       p_header_rec.fulfillment_set_name
    ,       p_header_rec.line_set_name
    ,       p_header_rec.tp_attribute1
    ,       p_header_rec.tp_attribute10
    ,       p_header_rec.tp_attribute11
    ,       p_header_rec.tp_attribute12
    ,       p_header_rec.tp_attribute13
    ,       p_header_rec.tp_attribute14
    ,       p_header_rec.tp_attribute15
    ,       p_header_rec.tp_attribute2
    ,       p_header_rec.tp_attribute3
    ,       p_header_rec.tp_attribute4
    ,       p_header_rec.tp_attribute5
    ,       p_header_rec.tp_attribute6
    ,       p_header_rec.tp_attribute7
    ,       p_header_rec.tp_attribute8
    ,       p_header_rec.tp_attribute9
    ,       p_header_rec.tp_context
    ,       p_header_rec.xml_message_id
    ,       l_upgraded_flag
    ,       l_lock_control

   -- QUOTING changes
    ,       p_header_rec.quote_date
    ,       p_header_rec.quote_number
    ,       p_header_rec.sales_document_name
    ,       p_header_rec.transaction_phase_code
    ,       p_header_rec.user_status_code
    ,       p_header_rec.draft_submitted_flag
    ,       p_header_rec.source_document_version_number
    ,       p_header_rec.sold_to_site_use_id
    -- QUOTING changes END

    ,       p_header_rec.minisite_id
    ,       p_header_rec.Ib_owner
    ,       p_header_rec.Ib_installed_at_location
    ,       p_header_rec.Ib_current_location
    ,       p_header_rec.end_customer_id
    ,       p_header_rec.end_customer_contact_id
    ,       p_header_rec.end_customer_site_use_id
    ,       p_header_rec.supplier_signature
    ,       p_header_rec.supplier_signature_date
    ,       p_header_rec.customer_signature
    ,       p_header_rec.customer_signature_date
    --key transaction dates
    ,       p_header_rec.order_firmed_date
    );

    p_header_rec.lock_control := l_lock_control;

    -- aksingh update the operation to NULL and update the cache with
    -- record
    oe_order_cache.g_header_rec := p_header_rec;
    oe_order_cache.g_header_rec.operation := null;
    OE_GLOBALS.G_HEADER_CREATED := TRUE;

    -- calling notification framework to update global picture
  -- check code release level first. Notification framework is at Pack H level
   IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
      OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_old_header_rec => NULL,
                    p_Header_rec =>p_header_rec,
                    p_header_id => p_header_rec.header_id,
                    x_index => l_index,
                    x_return_status => l_return_status);
     OE_DEBUG_PUB.ADD('Update_Global Return Status from OE_HEADER_UTIL.insert_row is: ' || l_return_status);
    OE_DEBUG_PUB.ADD('returned index is: ' || l_index ,1);
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        OE_DEBUG_PUB.ADD('EVENT NOTIFY - Unexpected Error');
        OE_DEBUG_PUB.ADD('Exiting OE_HEADER_UTIL.INSERT_ROW', 1);
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        OE_DEBUG_PUB.ADD('Update_Global_Picture Error in OE_HEADER_UTIL.Insert_row');
        OE_DEBUG_PUB.ADD('Exiting OE_HEADER_UTIL.INSERT_ROW', 1);
	RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF; /*code_release_level*/
  -- notification framework end

    oe_debug_pub.add('Exiting OE_HEADER_UTIL.INSERT_ROW', 1);

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

--  Procedure Delete_row

PROCEDURE Delete_Row
(   p_header_id                     IN  NUMBER
)
IS
	l_return_status				VARCHAR2(30);
	l_org_id                	NUMBER;
     -- added for notification framework
        l_new_header_rec     OE_Order_PUB.Header_Rec_Type;
        l_index              NUMBER;
        l_price_request_code VARCHAR2(240);     -- BUG 2670775
        l_transaction_phase_code VARCHAR2(30);

   --takintoy added for delete articles
   l_msg_count NUMBER;
   l_msg_data VARCHAR2(2000);
BEGIN

    oe_debug_pub.add('Entering OE_HEADER_UTIL.DELETE_ROW', 1);
      --Commented for MOAC start
	/*l_org_id := OE_GLOBALS.G_ORG_ID;
	IF l_org_id IS NULL THEN
  	   OE_GLOBALS.Set_Context;
	   l_org_id := OE_GLOBALS.G_ORG_ID;
	END IF;*/
      --Commented for MOAC end
   -- added for notification framework
   --check code release level first. Notification framework is at Pack H level
   IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
    /* Set the operation on the record so that globals are updated as well */
     l_new_header_rec.operation := OE_GLOBALS.G_OPR_DELETE;
     l_new_header_rec.header_id := p_header_id;
     OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_Header_rec =>l_new_header_rec,
                    p_header_id => p_header_id,
                    x_index => l_index,
                    x_return_status => l_return_status);
     OE_DEBUG_PUB.ADD('Update_Global Return Status from OE_HEADER_UTIL.delete_row is: ' || l_return_status);

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        OE_DEBUG_PUB.ADD('EVENT NOTIFY - Unexpected Error');
        OE_DEBUG_PUB.ADD('Exiting OE_HEADER_UTIL.DELETE_ROW', 1);
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        OE_DEBUG_PUB.ADD('Update_Global_Picture Error in OE_HEADER_UTIL.Delete_row');
        OE_DEBUG_PUB.ADD('Exiting OE_HEADER_UTIL.DELETE_ROW', 1);
	RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF; /* code_release_level*/
    -- notification framework end

   -- BUG 2670775 Reverse Limits Begin
   oe_debug_pub.add('log request to Reverse_Limits for HEADER level DELETE',1);
   OE_Order_Cache.Load_Order_Header(p_header_id);
   l_price_request_code := OE_ORDER_CACHE.g_header_rec.price_request_code;
   l_transaction_phase_code := OE_ORDER_CACHE.g_header_rec.transaction_phase_code;

   -- If price_request_code is not cached, retrieve it
   IF l_price_request_code = FND_API.G_MISS_CHAR
     OR l_price_request_code is NULL THEN
     oe_debug_pub.add('Select price_request_code from HEADER',1);
     SELECT price_request_code
	  INTO l_price_request_code
	  FROM OE_ORDER_HEADERS
	  WHERE HEADER_ID = p_header_id;
   END IF;

   OE_DELAYED_REQUESTS_UTIL.REVERSE_LIMITS
              ( x_return_status           => l_return_status
              , p_action_code             => 'CANCEL'
              , p_cons_price_request_code => l_price_request_code
              , p_orig_ordered_qty        => NULL
              , p_amended_qty             => NULL
              , p_ret_price_request_code  => NULL
              , p_returned_qty            => NULL
              , p_line_id                 => NULL
              );
    oe_debug_pub.add('Request to Reverse_Limits in OE_HEADER_UTIL.Delete_Row is done',1);
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- BUG 2670775 Reverse Limits End
    OE_Atchmt_Util.Delete_Attachments
               ( p_entity_code	=> OE_GLOBALS.G_ENTITY_HEADER
               , p_entity_id      	=> p_header_id
               , x_return_status   => l_return_status
               );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    OE_Header_Adj_Util.delete_row(p_header_id => p_header_id);
    OE_Header_Scredit_Util.delete_row(p_header_id => p_header_id);
    OE_Line_Util.delete_row(p_header_id => p_header_id);
    -- Bug 3315531
    -- Pass appropriate value for p_type depending on transaction phase
    IF nvl(l_transaction_phase_code,'F') = 'F' THEN
       OE_Order_WF_Util.delete_row(p_type=>'HEADER', p_id => p_header_id);
    ELSIF l_transaction_phase_code = 'N' THEN
       OE_Order_WF_Util.delete_row(p_type=>'NEGOTIATE', p_id => p_header_id);
    END IF;
    OE_Holds_PUB.Delete_Holds(p_header_id => p_header_id);

    OE_Delayed_Requests_Pvt.Delete_Reqs_for_deleted_entity(
        p_entity_code  => OE_GLOBALS.G_ENTITY_HEADER,
        p_entity_id     => p_header_id,
        x_return_status => l_return_status
        );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    /* Start Audit Trail */
    DELETE  FROM OE_ORDER_HEADER_HISTORY
    WHERE   HEADER_ID = p_header_id;
    /* End Audit Trail */

	/* takintoy delete Contracts*/
    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
	 OE_CONTRACTS_UTIL.delete_articles
        (
        p_api_version    =>1,
        p_doc_type       => OE_CONTRACTS_UTIL.G_SO_DOC_TYPE,
        p_doc_id         =>p_header_id,
        x_return_status  =>l_return_status,
        x_msg_count      =>l_msg_count,
        x_msg_data       =>l_msg_data);
     END IF;
    /*End contract deletion*/

    DELETE  FROM OE_ORDER_HEADERS
    WHERE   HEADER_ID = p_header_id;
   /* AND
      (NVL(ORG_ID,NVL(l_org_id,0))= NVL(l_org_id,0))
    ;*/

    oe_debug_pub.add('Exiting OE_HEADER_UTIL.DELETE_ROW', 1);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    --takintoy, added for delete articles
    OE_MSG_PUB.Count_And_Get
     (
       p_count       => l_msg_count,
       p_data        => l_msg_data
      );
		RAISE FND_API.G_EXC_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --takintoy, added for delete articles
    OE_MSG_PUB.Count_And_Get
     (
       p_count       => l_msg_count,
       p_data        => l_msg_data
     );
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Delete_Row;

--R12 CC Encryption
PROCEDURE Query_card_Details
(    p_header_id IN NUMBER,
     p_credit_card_code OUT NOCOPY VARCHAR2,
     p_credit_card_holder_name OUT NOCOPY VARCHAR2,
     p_credit_card_number OUT NOCOPY VARCHAR2,
     p_credit_Card_expiration_date OUT NOCOPY VARCHAR2,
     p_credit_card_approval_code OUT NOCOPY VARCHAR2,
     p_credit_card_approval_Date OUT NOCOPY VARCHAR2,
     p_instrument_security_code OUT NOCOPY VARCHAR2,
     p_instrument_id	OUT NOCOPY NUMBER,
     p_instrument_assignment_id OUT NOCOPY NUMBER
)
IS
l_exists VARCHAR2(1);
l_trxn_extension_id NUMBER;
x_bank_account_number number;
x_check_number        varchar2(100);
l_payment_type_code VARCHAR2(40) := 'CREDIT_CARD';
l_return_status      VARCHAR2(30) := NULL ;
l_msg_count          NUMBER := 0 ;
l_msg_data           VARCHAR2(2000) := NULL ;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
	IF l_debug_level >0 THEN
		oe_debug_pub.add('Entering Query Card Details....');
		l_return_status := FND_API.G_RET_STS_SUCCESS;
	END IF;

	BEGIN
		SELECT 'Y',trxn_extension_id
		into l_exists,l_trxn_extension_id
		FROM OE_PAYMENTS
		WHERE header_id = p_header_id
		and line_id is null and
		nvl(payment_collection_event,'PREPAY') = 'INVOICE';
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			l_exists := 'N';
			IF l_debug_level >0 THEN
				oe_debug_pub.add('No record in oe_payments ...in query card details');
				oe_debug_pub.add('Header id passed...'||p_header_id);
			END IF;
	END;

	IF l_exists = 'Y' and l_trxn_extension_id is not null then
		BEGIN
			OE_Payment_Trxn_Util.Get_Payment_Trxn_Info(p_header_id => p_header_id,
			 P_trxn_extension_id => l_trxn_extension_id,
			 P_payment_type_code =>  l_payment_type_code,
			 X_credit_card_number => p_credit_card_number,
			 X_credit_card_holder_name => p_credit_card_holder_name,
			 X_credit_card_expiration_date => p_credit_card_expiration_date,
			 X_credit_card_code => p_credit_card_code,
			 X_credit_card_approval_code => p_credit_card_approval_code,
			 X_credit_card_approval_date => p_credit_card_approval_date,
			 X_bank_account_number => X_bank_account_number,
			 --X_check_number => X_check_number	,
			 X_instrument_security_code => p_instrument_security_code,
			 X_instrument_id	=> p_instrument_id,
			 X_instrument_assignment_id => p_instrument_assignment_id,
			 X_return_status => l_return_status,
			 X_msg_count => l_msg_count,
			 X_msg_data => l_msg_data);

			 IF l_return_status = FND_API.G_RET_STS_ERROR OR
			 l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				OE_DEBUG_PUB.add('Error in get payment trxn info...');
			 ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
				OE_DEBUG_PUB.add('Success in get payment trxn info...');
				--oe_debug_pub.add('Card holder name...'||p_credit_card_holder_name);
			 END IF;

		EXCEPTION
		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
			l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			IF l_debug_level>0 THEN
				oe_debug_pub.add('Exception in Query card details....'||sqlerrm);
				oe_debug_pub.add('Return status'||l_return_status);
				oe_debug_pub.add('Msg data'||l_msg_data);
			END IF;
		WHEN OTHERS THEN
			l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			IF l_debug_level>0 THEN
				oe_debug_pub.add('Exception in Query card details....'||sqlerrm);
				oe_debug_pub.add('Return status'||l_return_status);
				oe_debug_pub.add('Msg data'||l_msg_data);
			END IF;
		END;
	ELSIF l_exists = 'Y' and l_trxn_extension_id is null then
		BEGIN
			select credit_card_number,
			credit_card_holder_name,
			credit_card_expiration_date,
			credit_card_code,
			credit_card_approval_code,
			credit_card_approval_date
			into p_credit_card_number,
			p_credit_card_holder_name,
			p_credit_card_expiration_date,
			p_credit_card_code,
			p_credit_card_approval_code,
			p_credit_card_approval_date
			from oe_payments where
			header_id = p_header_id and line_id is null
			and nvl(payment_collection_event,'PREPAY') = 'INVOICE';
			--Set the new attributes value to null as this record was created before R12
			p_instrument_security_code := NULL;
			p_instrument_id := null;
			p_instrument_assignment_id := null;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			null;
		END;
	ELSIF l_exists = 'N' THEN
		p_credit_card_number := null;
		p_credit_card_holder_name := null;
		p_credit_card_expiration_date := null;
		p_credit_card_code := null;
		p_credit_card_approval_code := null;
		p_credit_card_approval_date  := null;
		p_instrument_security_code := NULL;
		p_instrument_id := null;
		p_instrument_assignment_id := null;
	END IF;


EXCEPTION
WHEN OTHERS THEN
	IF l_debug_level>0 THEN
		oe_debug_pub.add('Exception in Query card details....'||sqlerrm);
		oe_debug_pub.add('Return status'||l_return_status);
		oe_debug_pub.add('Msg data'||l_msg_data);
	END IF;
END Query_card_Details;
--R12 CC Encryption

-- FUNCTION Query_Row
-- IMPORTANT: DO NOT CHANGE THE SPEC OF THIS FUNCTION
-- IT IS PUBLIC AND BEING CALLED BY OTHER PRODUCTS
-- Private OM callers should call the procedure query_row instead
-- as it has the nocopy option which would improve the performance

FUNCTION Query_Row
(   p_header_id                       IN  NUMBER
) RETURN OE_Order_PUB.Header_Rec_Type
IS
l_header_rec               OE_Order_PUB.Header_Rec_Type;
BEGIN

    Query_Row
        (   p_header_id                   => p_header_id
        ,   x_header_rec                  => l_header_rec
        );

    RETURN l_header_rec;

END Query_Row;

--  Function Query_Row

PROCEDURE Query_Row
(   p_header_id                     IN  NUMBER,
    x_header_rec                    IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
)
IS
l_org_id		NUMBER;
l_x_header_rec_oper  	VARCHAR2(30);
l_trxn_extension_id	NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_return_status               VARCHAR2(1);
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_HEADER_UTIL.QUERY_ROW', 1);
  end if;
      --Commented for MOAC start
       /*l_org_id := OE_GLOBALS.G_ORG_ID;
     IF l_org_id IS NULL THEN
  	   OE_GLOBALS.Set_Context;
	   l_org_id := OE_GLOBALS.G_ORG_ID;
	END IF;*/
      --Commented for MOAC end
     -- aksingh use global record if exists for header_id
     IF oe_order_cache.g_header_rec.header_id = p_header_id
    -- { Start of the fix 2436046
        AND x_header_rec.lock_control <> -1
    -- End of the fix 2436046 }
     THEN
        l_x_header_rec_oper := x_header_rec.operation;
        x_header_rec := oe_order_cache.g_header_rec;
        x_header_rec.operation := l_x_header_rec_oper;
        return;
     END IF;

   -- bug 3588660
/*
   IF  OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
      OE_ORDER_UTIL.Clear_Global_Picture(l_return_status);
   END IF;
*/
    SELECT  ACCOUNTING_RULE_ID
    ,       ACCOUNTING_RULE_DURATION
    ,       AGREEMENT_ID
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE16   --For bug 2184255
    ,       ATTRIBUTE17
    ,       ATTRIBUTE18
    ,       ATTRIBUTE19
    ,       ATTRIBUTE2
    ,       ATTRIBUTE20
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       BLANKET_NUMBER
    ,       BOOKED_FLAG
    ,       BOOKED_DATE
    ,       CANCELLED_FLAG
    ,       CONTEXT
    ,       CONVERSION_RATE
    ,       CONVERSION_RATE_DATE
    ,       CONVERSION_TYPE_CODE
    ,       CUSTOMER_PREFERENCE_SET_CODE
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CUST_PO_NUMBER
    ,       DELIVER_TO_CONTACT_ID
    ,       DELIVER_TO_ORG_ID
    ,       DEMAND_CLASS_CODE
    ,       FIRST_ACK_CODE
    ,       FIRST_ACK_DATE
    ,       EXPIRATION_DATE
    ,       EARLIEST_SCHEDULE_LIMIT
    ,       FOB_POINT_CODE
    ,       FREIGHT_CARRIER_CODE
    ,       FREIGHT_TERMS_CODE
    ,       GLOBAL_ATTRIBUTE1
    ,       GLOBAL_ATTRIBUTE10
    ,       GLOBAL_ATTRIBUTE11
    ,       GLOBAL_ATTRIBUTE12
    ,       GLOBAL_ATTRIBUTE13
    ,       GLOBAL_ATTRIBUTE14
    ,       GLOBAL_ATTRIBUTE15
    ,       GLOBAL_ATTRIBUTE16
    ,       GLOBAL_ATTRIBUTE17
    ,       GLOBAL_ATTRIBUTE18
    ,       GLOBAL_ATTRIBUTE19
    ,       GLOBAL_ATTRIBUTE2
    ,       GLOBAL_ATTRIBUTE20
    ,       GLOBAL_ATTRIBUTE3
    ,       GLOBAL_ATTRIBUTE4
    ,       GLOBAL_ATTRIBUTE5
    ,       GLOBAL_ATTRIBUTE6
    ,       GLOBAL_ATTRIBUTE7
    ,       GLOBAL_ATTRIBUTE8
    ,       GLOBAL_ATTRIBUTE9
    ,       GLOBAL_ATTRIBUTE_CATEGORY
    ,       HEADER_ID
    ,       INVOICE_TO_CONTACT_ID
    ,       INVOICE_TO_ORG_ID
    ,       INVOICING_RULE_ID
    ,       LAST_ACK_CODE
    ,       LAST_ACK_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LATEST_SCHEDULE_LIMIT
    ,       OPEN_FLAG
    ,       ORDERED_DATE
    ,       ORDER_DATE_TYPE_CODE
    ,       ORDER_NUMBER
    ,       ORDER_SOURCE_ID
    ,       ORDER_TYPE_ID
    ,       ORDER_CATEGORY_CODE
    ,       ORG_ID
    ,       ORIG_SYS_DOCUMENT_REF
    ,       PARTIAL_SHIPMENTS_ALLOWED
    ,       PAYMENT_TERM_ID
    ,       PRICE_LIST_ID
    ,       PRICE_REQUEST_CODE                    -- PROMOTIONS SEP/01
    ,       PRICING_DATE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_DATE
    ,       REQUEST_ID
    ,       RETURN_REASON_CODE
    ,       SALESREP_ID
    ,       SALES_CHANNEL_CODe
    ,       SHIPMENT_PRIORITY_CODE
    ,       SHIPPING_METHOD_CODE
    ,       SHIP_FROM_ORG_ID
    ,       SHIP_TOLERANCE_ABOVE
    ,       SHIP_TOLERANCE_BELOW
    ,       SHIP_TO_CONTACT_ID
    ,       SHIP_TO_ORG_ID
    ,	    SOLD_FROM_ORG_ID
    ,       SOLD_TO_CONTACT_ID
    ,       SOLD_TO_ORG_ID
    ,       SOLD_TO_PHONE_ID
    ,       SOURCE_DOCUMENT_ID
    ,       SOURCE_DOCUMENT_TYPE_ID
    ,       TAX_EXEMPT_FLAG
    ,       TAX_EXEMPT_NUMBER
    ,       TAX_EXEMPT_REASON_CODE
    ,       TAX_POINT_CODE
    ,       TRANSACTIONAL_CURR_CODE
    ,       VERSION_NUMBER
    ,       PAYMENT_TYPE_CODE
    ,       PAYMENT_AMOUNT
    ,       CHECK_NUMBER
    ,       CREDIT_CARD_CODE
    ,       CREDIT_CARD_HOLDER_NAME
    ,       CREDIT_CARD_NUMBER
    ,       CREDIT_CARD_EXPIRATION_DATE
    ,       CREDIT_CARD_APPROVAL_DATE
    ,       CREDIT_CARD_APPROVAL_CODE
    ,       SHIPPING_INSTRUCTIONS
    ,       PACKING_INSTRUCTIONS
    ,       FLOW_STATUS_CODE
    ,       MARKETING_SOURCE_CODE_ID
    ,       DEFAULT_FULFILLMENT_SET
    ,       FULFILLMENT_SET_NAME
    ,       LINE_SET_NAME
    ,       TP_ATTRIBUTE1
    ,       TP_ATTRIBUTE10
    ,       TP_ATTRIBUTE11
    ,       TP_ATTRIBUTE12
    ,       TP_ATTRIBUTE13
    ,       TP_ATTRIBUTE14
    ,       TP_ATTRIBUTE15
    ,       TP_ATTRIBUTE2
    ,       TP_ATTRIBUTE3
    ,       TP_ATTRIBUTE4
    ,       TP_ATTRIBUTE5
    ,       TP_ATTRIBUTE6
    ,       TP_ATTRIBUTE7
    ,       TP_ATTRIBUTE8
    ,       TP_ATTRIBUTE9
    ,       TP_CONTEXT
    ,       XML_MESSAGE_ID
    ,       upgraded_flag
    ,       LOCK_CONTROL
    ,       CHANGE_SEQUENCE
    ,	    quote_date
    ,       quote_number
    ,       sales_document_name
    ,       transaction_phase_code
    ,       user_status_code
    ,       draft_submitted_flag
    ,       source_document_version_number
    ,       sold_to_site_use_id
    ,       MINISITE_ID
    ,       IB_OWNER
    ,       IB_INSTALLED_AT_LOCATION
    ,       IB_CURRENT_LOCATION
    ,       END_CUSTOMER_ID
    ,       END_CUSTOMER_CONTACT_ID
    ,       END_CUSTOMER_SITE_USE_ID
    ,       SUPPLIER_SIGNATURE
    ,       SUPPLIER_SIGNATURE_DATE
    ,       CUSTOMER_SIGNATURE
    ,       CUSTOMER_SIGNATURE_DATE
--key Transaction Dates
    ,       order_firmed_date
    INTO    x_header_rec.accounting_rule_id
    ,       x_header_rec.accounting_rule_duration
    ,       x_header_rec.agreement_id
    ,       x_header_rec.attribute1
    ,       x_header_rec.attribute10
    ,       x_header_rec.attribute11
    ,       x_header_rec.attribute12
    ,       x_header_rec.attribute13
    ,       x_header_rec.attribute14
    ,       x_header_rec.attribute15
    ,       x_header_rec.attribute16   --For bug 2184255
    ,       x_header_rec.attribute17
    ,       x_header_rec.attribute18
    ,       x_header_rec.attribute19
    ,       x_header_rec.attribute2
    ,       x_header_rec.attribute20
    ,       x_header_rec.attribute3
    ,       x_header_rec.attribute4
    ,       x_header_rec.attribute5
    ,       x_header_rec.attribute6
    ,       x_header_rec.attribute7
    ,       x_header_rec.attribute8
    ,       x_header_rec.attribute9
    ,       x_header_rec.Blanket_Number
    ,       x_header_rec.booked_flag
    ,       x_header_rec.booked_date
    ,       x_header_rec.cancelled_flag
    ,       x_header_rec.context
    ,       x_header_rec.conversion_rate
    ,       x_header_rec.conversion_rate_date
    ,       x_header_rec.conversion_type_code
    ,       x_header_rec.CUSTOMER_PREFERENCE_SET_CODE
    ,       x_header_rec.created_by
    ,       x_header_rec.creation_date
    ,       x_header_rec.cust_po_number
    ,       x_header_rec.deliver_to_contact_id
    ,       x_header_rec.deliver_to_org_id
    ,       x_header_rec.demand_class_code
    ,       x_header_rec.first_ack_code
    ,       x_header_rec.first_ack_date
    ,       x_header_rec.expiration_date
    ,       x_header_rec.earliest_schedule_limit
    ,       x_header_rec.fob_point_code
    ,       x_header_rec.freight_carrier_code
    ,       x_header_rec.freight_terms_code
    ,       x_header_rec.global_attribute1
    ,       x_header_rec.global_attribute10
    ,       x_header_rec.global_attribute11
    ,       x_header_rec.global_attribute12
    ,       x_header_rec.global_attribute13
    ,       x_header_rec.global_attribute14
    ,       x_header_rec.global_attribute15
    ,       x_header_rec.global_attribute16
    ,       x_header_rec.global_attribute17
    ,       x_header_rec.global_attribute18
    ,       x_header_rec.global_attribute19
    ,       x_header_rec.global_attribute2
    ,       x_header_rec.global_attribute20
    ,       x_header_rec.global_attribute3
    ,       x_header_rec.global_attribute4
    ,       x_header_rec.global_attribute5
    ,       x_header_rec.global_attribute6
    ,       x_header_rec.global_attribute7
    ,       x_header_rec.global_attribute8
    ,       x_header_rec.global_attribute9
    ,       x_header_rec.global_attribute_category
    ,       x_header_rec.header_id
    ,       x_header_rec.invoice_to_contact_id
    ,       x_header_rec.invoice_to_org_id
    ,       x_header_rec.invoicing_rule_id
    ,       x_header_rec.last_ack_code
    ,       x_header_rec.last_ack_date
    ,       x_header_rec.last_updated_by
    ,       x_header_rec.last_update_date
    ,       x_header_rec.last_update_login
    ,       x_header_rec.latest_schedule_limit
    ,       x_header_rec.open_flag
    ,       x_header_rec.ordered_date
    ,       x_header_rec.order_date_type_code
    ,       x_header_rec.order_number
    ,       x_header_rec.order_source_id
    ,       x_header_rec.order_type_id
    ,       x_header_rec.order_category_code
    ,       x_header_rec.org_id
    ,       x_header_rec.orig_sys_document_ref
    ,       x_header_rec.partial_shipments_allowed
    ,       x_header_rec.payment_term_id
    ,       x_header_rec.price_list_id
    ,       x_header_rec.price_request_code           -- PROMOTIONS SEP/01
    ,       x_header_rec.pricing_date
    ,       x_header_rec.program_application_id
    ,       x_header_rec.program_id
    ,       x_header_rec.program_update_date
    ,       x_header_rec.request_date
    ,       x_header_rec.request_id
    ,       x_header_rec.return_reason_code
    ,       x_header_rec.salesrep_id
    ,       x_header_rec.sales_channel_code
    ,       x_header_rec.shipment_priority_code
    ,       x_header_rec.shipping_method_code
    ,       x_header_rec.ship_from_org_id
    ,       x_header_rec.ship_tolerance_above
    ,       x_header_rec.ship_tolerance_below
    ,       x_header_rec.ship_to_contact_id
    ,       x_header_rec.ship_to_org_id
    ,	  x_header_rec.sold_from_org_id
    ,       x_header_rec.sold_to_contact_id
    ,       x_header_rec.sold_to_org_id
    ,       x_header_rec.sold_to_phone_id
    ,       x_header_rec.source_document_id
    ,       x_header_rec.source_document_type_id
    ,       x_header_rec.tax_exempt_flag
    ,       x_header_rec.tax_exempt_number
    ,       x_header_rec.tax_exempt_reason_code
    ,       x_header_rec.tax_point_code
    ,       x_header_rec.transactional_curr_code
    ,       x_header_rec.version_number
    ,       x_header_rec.payment_type_code
    ,       x_header_rec.payment_amount
    ,       x_header_rec.check_number
    ,       x_header_rec.credit_card_code
    ,       x_header_rec.credit_card_holder_name
    ,       x_header_rec.credit_card_number
    ,       x_header_rec.credit_card_expiration_date
    ,       x_header_rec.credit_card_approval_date
    ,       x_header_rec.credit_card_approval_code
    ,       x_header_rec.shipping_instructions
    ,       x_header_rec.packing_instructions
    ,       x_header_rec.flow_status_code
    ,       x_header_rec.marketing_source_code_id
    ,       x_header_rec.default_fulfillment_set
    ,       x_header_rec.fulfillment_set_name
    ,       x_header_rec.line_set_name
    ,       x_header_rec.tp_attribute1
    ,       x_header_rec.tp_attribute10
    ,       x_header_rec.tp_attribute11
    ,       x_header_rec.tp_attribute12
    ,       x_header_rec.tp_attribute13
    ,       x_header_rec.tp_attribute14
    ,       x_header_rec.tp_attribute15
    ,       x_header_rec.tp_attribute2
    ,       x_header_rec.tp_attribute3
    ,       x_header_rec.tp_attribute4
    ,       x_header_rec.tp_attribute5
    ,       x_header_rec.tp_attribute6
    ,       x_header_rec.tp_attribute7
    ,       x_header_rec.tp_attribute8
    ,       x_header_rec.tp_attribute9
    ,       x_header_rec.tp_context
    ,       x_header_rec.xml_message_id
    ,       x_header_rec.upgraded_flag
    ,       x_header_rec.lock_control
    ,       x_header_rec.change_sequence
    ,       x_header_rec.quote_date
    ,       x_header_rec.quote_number
    ,       x_header_rec.sales_document_name
    ,       x_header_rec.transaction_phase_code
    ,       x_header_rec.user_status_code
    ,       x_header_rec.draft_submitted_flag
    ,       x_header_rec.source_document_version_number
    ,       x_header_rec.sold_to_site_use_id
    ,       x_header_rec.minisite_id
    ,       x_header_rec.ib_owner
    ,       x_header_rec.ib_installed_at_location
    ,       x_header_rec.ib_current_location
    ,       x_header_rec.end_customer_id
    ,       x_header_rec.end_customer_contact_id
    ,       x_header_rec.end_customer_site_use_id
    ,       x_header_rec.supplier_signature
    ,       x_header_rec.supplier_signature_date
    ,       x_header_rec.customer_signature
    ,       x_header_rec.customer_signature_date
  --key Transaction Dates
    ,       x_header_rec.order_firmed_date
    FROM    OE_ORDER_HEADERS_ALL
    WHERE   HEADER_ID = p_header_id;
   /* AND
   (NVL(ORG_ID,NVL(l_org_id,0))= NVL(l_org_id,0))
    ;*/

    --R12 CC Encryption

    --Need to call query card details procedure to get the credit card
    --details as the OM tables would not have these values in R12
    IF x_header_rec.payment_type_code IS NOT NULL AND
       x_header_rec.payment_type_code = 'CREDIT_CARD' THEN

       BEGIN
         SELECT trxn_extension_id
         INTO   l_trxn_extension_id
         FROM   oe_payments
         WHERE  header_id = p_header_id
         AND    nvl(payment_collection_event,'PREPAY') = 'INVOICE'
         AND    payment_type_code = 'CREDIT_CARD'
         AND    line_id is null;
       EXCEPTION WHEN NO_DATA_FOUND THEN
         null;
       END;

       IF l_trxn_extension_id is not null THEN
 	 if l_debug_level > 0 then
		oe_debug_pub.add('Calling query card details...');
	 end if;
		Query_card_details
	       ( p_header_id	=> x_header_rec.header_id,
		 p_credit_card_code => x_header_rec.credit_card_code,
		 p_credit_card_holder_name => x_header_rec.credit_card_holder_name,
		 p_credit_card_number => x_header_rec.credit_card_number,
		 p_credit_Card_expiration_date => x_header_rec.credit_card_expiration_date,
		 p_credit_card_approval_code => x_header_rec.credit_card_approval_code,
		 p_credit_card_approval_Date => x_header_rec.credit_card_approval_date,
		 p_instrument_security_code => x_header_rec.instrument_security_code,
		 p_instrument_id => x_header_rec.cc_instrument_id,
		 p_instrument_assignment_id => x_header_rec.cc_instrument_assignment_id
		);
       END IF;
     END IF;
     --R12 CC Encryption

    -- aksingh assigning the global record, so later the cached record
    -- will be used instead of querying again
  if l_debug_level > 0 then
    oe_debug_pub.add('Before caching OE_HEADER_UTIL.QUERY_ROW', 1);
  end if;

    oe_order_cache.g_header_rec := x_header_rec;
    oe_order_cache.g_header_rec.operation := null;

  if l_debug_level > 0 then
    oe_debug_pub.add('Exiting OE_HEADER_UTIL.QUERY_ROW', 1);
  end if;


EXCEPTION

    WHEN NO_DATA_FOUND THEN

	   RAISE NO_DATA_FOUND;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Row;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_x_header_rec                  IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   p_header_id			    IN  NUMBER
					:= FND_API.G_MISS_NUM
)
IS
     l_header_id		      NUMBER;
     l_lock_control                   NUMBER;
     l_db_lock_control                NUMBER;
BEGIN

    oe_debug_pub.add('Entering OE_HEADER_UTIL.LOCK_ROW', 1);

    SAVEPOINT Lock_Row;

    l_lock_control := NULL;

    -- Retrieve the primary key.
    IF 	p_header_id <> FND_API.G_MISS_NUM THEN
		l_header_id := p_header_id;
    ELSE
		l_header_id    := p_x_header_rec.header_id;
          l_lock_control := p_x_header_rec.lock_control;
    END IF;

    SELECT header_id, lock_control
    INTO l_header_id, l_db_lock_control
    FROM OE_ORDER_HEADERS_ALL
    WHERE HEADER_ID = l_header_id
      FOR UPDATE NOWAIT;

    -- { Start of the fix 2436046, query part is old
    IF l_db_lock_control is not null and
       nvl(l_lock_control, FND_API.G_MISS_NUM) <> l_db_lock_control
    THEN
       p_x_header_rec.lock_control := -1;
    END IF;
    -- End of the fix 2436046 }

    OE_Header_Util.Query_Row(p_header_id  => l_header_id,
                            x_header_rec => p_x_header_rec);

    oe_debug_pub.add('selected for update, now compare', 3);


    -- If lock_control is not passed(is null or missing), then return the locked record.

    IF l_lock_control is null OR
       l_lock_control = FND_API.G_MISS_NUM
    THEN

        --  Set out parameter, out rec is already set by query row.

        --  Set return status
        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        p_x_header_rec.return_status       := FND_API.G_RET_STS_SUCCESS;

	RETURN;

    END IF;

    --  Row locked. If the whole record is passed, then
    --  Compare the value of lock_control column to DB value.

-- following constants are used to debug lock_order,
-- please do not use them for any other purpose.
-- set G_LOCK_TEST := 'Y', for debugging.

    OE_GLOBALS.G_LOCK_CONST  := 0;
    --OE_GLOBALS.G_LOCK_TEST := 'Y';
    OE_GLOBALS.G_LOCK_TEST   := 'N';

    IF OE_GLOBALS.Equal(p_x_header_rec.lock_control,
                        l_lock_control)
      THEN

        oe_debug_pub.add('done comparison, success', 1);
        --  Row has not changed. Set out parameter.

        --  Set return status

        x_return_status                  := FND_API.G_RET_STS_SUCCESS;
        p_x_header_rec.return_status     := FND_API.G_RET_STS_SUCCESS;

    ELSE

        oe_debug_pub.add('row changed by other user', 1);

        --  Row has changed by another user.

        x_return_status                  := FND_API.G_RET_STS_ERROR;
        p_x_header_rec.return_status     := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	    -- Release the lock
            ROLLBACK TO Lock_Row;

            fnd_message.set_name('ONT','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    oe_debug_pub.add('Exiting OE_HEADER_UTIL.LOCK_ROW', 1);

    OE_GLOBALS.G_LOCK_TEST := 'N';
EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_header_rec.return_status     := FND_API.G_RET_STS_ERROR;

        oe_debug_pub.add('no data found in lock_header', 1);

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;

        OE_GLOBALS.G_LOCK_TEST := 'N';

    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_header_rec.return_status     := FND_API.G_RET_STS_ERROR;

        oe_debug_pub.add('record_lock in lock_header', 1);

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
        OE_GLOBALS.G_LOCK_TEST := 'N';
    WHEN OTHERS THEN

        oe_debug_pub.add('others in lock_header', 1);
        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        p_x_header_rec.return_status     := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;
        OE_GLOBALS.G_LOCK_TEST := 'N';
END Lock_Row;

--  Function Get_Values

FUNCTION Get_Values
(   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
) RETURN OE_Order_PUB.Header_Val_Rec_Type
IS
	l_header_val_rec          OE_Order_PUB.Header_Val_Rec_Type;
-- FP contracts word integration
	l_return_status                VARCHAR2(30);
        l_msg_count        NUMBER;
        l_msg_data         VARCHAR2(2000);
BEGIN

    oe_debug_pub.add('Entering OE_HEADER_UTIL.GET_VALUES', 1);

    l_header_val_rec := OE_Order_PUB.G_MISS_HEADER_VAL_REC;

    IF (p_header_rec.accounting_rule_id IS NULL OR
        p_header_rec.accounting_rule_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_header_rec.accounting_rule_id,
        p_old_header_rec.accounting_rule_id)
    THEN
        l_header_val_rec.accounting_rule := OE_Id_To_Value.Accounting_Rule
        (   p_accounting_rule_id          => p_header_rec.accounting_rule_id
        );
    END IF;

    IF (p_header_rec.agreement_id IS NULL OR
        p_header_rec.agreement_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_header_rec.agreement_id,
        p_old_header_rec.agreement_id)
    THEN
        l_header_val_rec.agreement := OE_Id_To_Value.Agreement
        (   p_agreement_id                => p_header_rec.agreement_id
        );
    END IF;

    IF (p_header_rec.conversion_type_code IS NULL OR
        p_header_rec.conversion_type_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_header_rec.conversion_type_code,
        p_old_header_rec.conversion_type_code)
    THEN
        l_header_val_rec.conversion_type := OE_Id_To_Value.Conversion_Type
        (   p_conversion_type_code        => p_header_rec.conversion_type_code
        );
    END IF;

    IF (p_header_rec.deliver_to_contact_id IS NULL OR
        p_header_rec.deliver_to_contact_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_header_rec.deliver_to_contact_id,
        p_old_header_rec.deliver_to_contact_id)
    THEN
        l_header_val_rec.deliver_to_contact := OE_Id_To_Value.Deliver_To_Contact
        (   p_deliver_to_contact_id       => p_header_rec.deliver_to_contact_id
        );
    END IF;

    IF (p_header_rec.deliver_to_org_id IS NULL OR
        p_header_rec.deliver_to_org_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_header_rec.deliver_to_org_id,
        p_old_header_rec.deliver_to_org_id)
    THEN
        get_customer_details
        (   p_org_id             => p_header_rec.deliver_to_org_id
        ,   p_site_use_code      =>'DELIVER_TO'
        ,   x_customer_name      => l_header_val_rec.deliver_to_customer_name
        ,   x_customer_number    => l_header_val_rec.deliver_to_customer_number
        ,   x_customer_id        => l_header_val_rec.deliver_to_customer_id
        ,   x_location        => l_header_val_rec.deliver_to_location
        ,   x_address1        => l_header_val_rec.deliver_to_address1
        ,   x_address2        => l_header_val_rec.deliver_to_address2
        ,   x_address3        => l_header_val_rec.deliver_to_address3
        ,   x_address4        => l_header_val_rec.deliver_to_address4
        ,   x_city        => l_header_val_rec.deliver_to_city
        ,   x_state        => l_header_val_rec.deliver_to_state
        ,   x_zip        => l_header_val_rec.deliver_to_zip
        ,   x_country        => l_header_val_rec.deliver_to_country
        );
        l_header_val_rec.deliver_to_org :=l_header_val_rec.deliver_to_location;

    END IF;

    IF (p_header_rec.fob_point_code IS NULL OR
        p_header_rec.fob_point_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_header_rec.fob_point_code,
        p_old_header_rec.fob_point_code)
    THEN
        l_header_val_rec.fob_point := OE_Id_To_Value.Fob_Point
        (   p_fob_point_code              => p_header_rec.fob_point_code
        );
    END IF;

    IF (p_header_rec.freight_terms_code IS NULL OR
        p_header_rec.freight_terms_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_header_rec.freight_terms_code,
        p_old_header_rec.freight_terms_code)
    THEN
        l_header_val_rec.freight_terms := OE_Id_To_Value.Freight_Terms
        (   p_freight_terms_code          => p_header_rec.freight_terms_code
        );
    END IF;

    IF (p_header_rec.freight_carrier_code IS NULL OR
        p_header_rec.freight_carrier_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_header_rec.freight_carrier_code,
        p_old_header_rec.freight_carrier_code)
    THEN
        l_header_val_rec.freight_carrier := OE_Id_To_Value.Freight_Carrier
        (   p_freight_carrier_code          => p_header_rec.freight_carrier_code
	   ,   p_ship_from_org_id		    => p_header_rec.ship_from_org_id
        );
    END IF;
    IF (p_header_rec.shipping_method_code IS NULL OR
        p_header_rec.shipping_method_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_header_rec.shipping_method_code,
        p_old_header_rec.shipping_method_code)
    THEN
        l_header_val_rec.shipping_method := OE_Id_To_Value.ship_method
        (   p_ship_method_code   => p_header_rec.shipping_method_code
        );
    END IF;

    IF (p_header_rec.invoice_to_contact_id IS NULL OR
        p_header_rec.invoice_to_contact_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_header_rec.invoice_to_contact_id,
        p_old_header_rec.invoice_to_contact_id)
    THEN
        l_header_val_rec.invoice_to_contact := OE_Id_To_Value.Invoice_To_Contact
        (   p_invoice_to_contact_id       => p_header_rec.invoice_to_contact_id
        );
    END IF;

    IF (p_header_rec.invoice_to_org_id IS NULL OR
        p_header_rec.invoice_to_org_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_header_rec.invoice_to_org_id,
        p_old_header_rec.invoice_to_org_id)
    THEN

        get_customer_details
        (   p_org_id             => p_header_rec.invoice_to_org_id
        ,   p_site_use_code      =>'BILL_TO'
        ,   x_customer_name      => l_header_val_rec.invoice_to_customer_name
        ,   x_customer_number    => l_header_val_rec.invoice_to_customer_number
        ,   x_customer_id        => l_header_val_rec.invoice_to_customer_id
        ,   x_location        => l_header_val_rec.invoice_to_location
        ,   x_address1        => l_header_val_rec.invoice_to_address1
        ,   x_address2        => l_header_val_rec.invoice_to_address2
        ,   x_address3        => l_header_val_rec.invoice_to_address3
        ,   x_address4        => l_header_val_rec.invoice_to_address4
        ,   x_city        => l_header_val_rec.invoice_to_city
        ,   x_state        => l_header_val_rec.invoice_to_state
        ,   x_zip        => l_header_val_rec.invoice_to_zip
        ,   x_country        => l_header_val_rec.invoice_to_country
        );
        l_header_val_rec.invoice_to_org :=l_header_val_rec.invoice_to_location;

    END IF;

    IF (p_header_rec.invoicing_rule_id IS NULL OR
        p_header_rec.invoicing_rule_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_header_rec.invoicing_rule_id,
        p_old_header_rec.invoicing_rule_id)
    THEN
        l_header_val_rec.invoicing_rule := OE_Id_To_Value.Invoicing_Rule
        (   p_invoicing_rule_id           => p_header_rec.invoicing_rule_id
        );
    END IF;

    IF (p_header_rec.order_source_id IS NULL OR
        p_header_rec.order_source_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_header_rec.order_source_id,
        p_old_header_rec.order_source_id)
    THEN
        l_header_val_rec.order_source := OE_Id_To_Value.Order_Source
        (   p_order_source_id             => p_header_rec.order_source_id
        );
    END IF;

    IF (p_header_rec.order_date_type_code IS NULL OR
        p_header_rec.order_date_type_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_header_rec.order_date_type_code,
        p_old_header_rec.order_date_type_code)
    THEN
        l_header_val_rec.order_date_type := OE_Id_To_Value.Order_Date_Type
        (   p_order_date_type_code        => p_header_rec.order_date_type_code
        );
    END IF;

    IF (p_header_rec.order_type_id IS NULL OR
        p_header_rec.order_type_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_header_rec.order_type_id,
        p_old_header_rec.order_type_id)
    THEN
        l_header_val_rec.order_type := OE_Id_To_Value.Order_Type
        (   p_order_type_id               => p_header_rec.order_type_id
        );
    END IF;

    IF (p_header_rec.payment_term_id IS NULL OR
        p_header_rec.payment_term_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_header_rec.payment_term_id,
        p_old_header_rec.payment_term_id)
    THEN
        l_header_val_rec.payment_term := OE_Id_To_Value.Payment_Term
        (   p_payment_term_id             => p_header_rec.payment_term_id
        );
    END IF;

    IF (p_header_rec.price_list_id IS NULL OR
        p_header_rec.price_list_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_header_rec.price_list_id,
        p_old_header_rec.price_list_id)
    THEN
        l_header_val_rec.price_list := OE_Id_To_Value.Price_List
        (   p_price_list_id               => p_header_rec.price_list_id
        );
    END IF;

    IF (p_header_rec.return_reason_code IS NULL OR
        p_header_rec.return_reason_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_header_rec.return_reason_code,
        p_old_header_rec.return_reason_code)
    THEN
        l_header_val_rec.return_reason := OE_Id_To_Value.return_reason
        (   p_return_reason_code  => p_header_rec.return_reason_code
        );
    END IF;

    IF (p_header_rec.salesrep_id IS NULL OR
        p_header_rec.salesrep_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_header_rec.salesrep_id,
        p_old_header_rec.salesrep_id)
    THEN
        l_header_val_rec.salesrep := OE_Id_To_Value.salesrep
        (   p_salesrep_id          => p_header_rec.salesrep_id
        );
    END IF;

    IF (p_header_rec.sales_channel_code IS NULL OR
        p_header_rec.sales_channel_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_header_rec.sales_channel_code,
        p_old_header_rec.sales_channel_code)
    THEN
        l_header_val_rec.sales_channel:= OE_Id_To_Value.sales_channel
        (   p_sales_channel_code          => p_header_rec.sales_channel_code
        );
    END IF;

    IF (p_header_rec.shipment_priority_code IS NULL OR
        p_header_rec.shipment_priority_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_header_rec.shipment_priority_code,
        p_old_header_rec.shipment_priority_code)
    THEN
        l_header_val_rec.shipment_priority := OE_Id_To_Value.Shipment_Priority
        (   p_shipment_priority_code      => p_header_rec.shipment_priority_code
        );
    END IF;

    IF (p_header_rec.demand_class_code IS NULL OR
        p_header_rec.demand_class_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_header_rec.demand_class_code,
        p_old_header_rec.demand_class_code)
    THEN
        l_header_val_rec.Demand_Class := OE_Id_To_Value.Demand_Class
        (   p_demand_class_code      => p_header_rec.demand_class_code
        );
    END IF;

    IF (p_header_rec.ship_from_org_id IS NULL OR
        p_header_rec.ship_from_org_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_header_rec.ship_from_org_id,
        p_old_header_rec.ship_from_org_id)
    THEN
        OE_Id_To_Value.Ship_From_Org
        (   p_ship_from_org_id            => p_header_rec.ship_from_org_id
        ,   x_ship_from_address1          => l_header_val_rec.ship_from_address1
        ,   x_ship_from_address2          => l_header_val_rec.ship_from_address2
        ,   x_ship_from_address3          => l_header_val_rec.ship_from_address3
        ,   x_ship_from_address4          => l_header_val_rec.ship_from_address4
        ,   x_ship_from_location          => l_header_val_rec.ship_from_location
        ,   x_ship_from_org               => l_header_val_rec.ship_from_org
        );
    END IF;

    IF (p_header_rec.ship_to_contact_id IS NULL OR
        p_header_rec.ship_to_contact_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_header_rec.ship_to_contact_id,
        p_old_header_rec.ship_to_contact_id)
    THEN
        l_header_val_rec.ship_to_contact := OE_Id_To_Value.Ship_To_Contact
        (   p_ship_to_contact_id          => p_header_rec.ship_to_contact_id
        );
    END IF;

    IF (p_header_rec.ship_to_org_id IS NULL OR
        p_header_rec.ship_to_org_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_header_rec.ship_to_org_id,
        p_old_header_rec.ship_to_org_id)
    THEN
        get_customer_details
        (   p_org_id             => p_header_rec.ship_to_org_id
        ,   p_site_use_code      =>'SHIP_TO'
        ,   x_customer_name      => l_header_val_rec.ship_to_customer_name
        ,   x_customer_number    => l_header_val_rec.ship_to_customer_number
        ,   x_customer_id        => l_header_val_rec.ship_to_customer_id
        ,   x_location        => l_header_val_rec.ship_to_location
        ,   x_address1        => l_header_val_rec.ship_to_address1
        ,   x_address2        => l_header_val_rec.ship_to_address2
        ,   x_address3        => l_header_val_rec.ship_to_address3
        ,   x_address4        => l_header_val_rec.ship_to_address4
        ,   x_city        => l_header_val_rec.ship_to_city
        ,   x_state        => l_header_val_rec.ship_to_state
        ,   x_zip        => l_header_val_rec.ship_to_zip
        ,   x_country        => l_header_val_rec.ship_to_country
        );
        l_header_val_rec.ship_to_org :=l_header_val_rec.ship_to_location;

    END IF;


    IF (p_header_rec.sold_to_contact_id IS NULL OR
        p_header_rec.sold_to_contact_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_header_rec.sold_to_contact_id,
        p_old_header_rec.sold_to_contact_id)
    THEN
        l_header_val_rec.sold_to_contact := OE_Id_To_Value.Sold_To_Contact
        (   p_sold_to_contact_id          => p_header_rec.sold_to_contact_id
        );
    END IF;

    IF (p_header_rec.sold_to_org_id IS NULL OR
        p_header_rec.sold_to_org_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_header_rec.sold_to_org_id,
        p_old_header_rec.sold_to_org_id)
    THEN
        OE_Id_To_Value.Sold_To_Org
        (   p_sold_to_org_id              => p_header_rec.sold_to_org_id
        ,   x_org                         => l_header_val_rec.sold_to_org
        ,   x_customer_number             => l_header_val_rec.customer_number
	--added for Ac. Desc, Registry ID Project
	,   x_account_description	  => l_header_val_rec.account_description
	,   x_registry_id		  => l_header_val_rec.registry_id
        );
    END IF;

    IF (p_header_rec.tax_exempt_flag IS NULL OR
        p_header_rec.tax_exempt_flag <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_header_rec.tax_exempt_flag,
        p_old_header_rec.tax_exempt_flag)
    THEN
        l_header_val_rec.tax_exempt := OE_Id_To_Value.Tax_Exempt
        (   p_tax_exempt_flag             => p_header_rec.tax_exempt_flag
        );
    END IF;

    IF (p_header_rec.tax_exempt_reason_code IS NULL OR
        p_header_rec.tax_exempt_reason_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_header_rec.tax_exempt_reason_code,
        p_old_header_rec.tax_exempt_reason_code)
    THEN
        l_header_val_rec.tax_exempt_reason := OE_Id_To_Value.Tax_Exempt_Reason
        (   p_tax_exempt_reason_code      => p_header_rec.tax_exempt_reason_code
        );
    END IF;

    IF (p_header_rec.tax_point_code IS NULL OR
        p_header_rec.tax_point_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_header_rec.tax_point_code,
        p_old_header_rec.tax_point_code)
    THEN
        l_header_val_rec.tax_point := OE_Id_To_Value.Tax_Point
        (   p_tax_point_code              => p_header_rec.tax_point_code
        );
    END IF;

    IF (p_header_rec.payment_type_code IS NULL OR
        p_header_rec.payment_type_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_header_rec.payment_type_code,
        p_old_header_rec.payment_type_code)
    THEN
        l_header_val_rec.payment_type := OE_Id_To_Value.Payment_Type
        (   p_payment_type_code              => p_header_rec.payment_type_code
        );
    END IF;
    --R12 CC Encryption
    IF (p_header_rec.credit_card_code IS NULL OR
        p_header_rec.credit_card_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_header_rec.credit_card_code,
        p_old_header_rec.credit_card_code)
    THEN
        l_header_val_rec.credit_card := OE_Id_To_Value.Credit_Card
        (   p_credit_card_code              => p_header_rec.credit_card_code
        );
    END IF;
    -- QUOTING changes

   IF (p_header_rec.sold_to_site_use_id IS NULL OR
        p_header_rec.sold_to_site_use_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_header_rec.sold_to_site_use_id,
        p_old_header_rec.sold_to_site_use_id)
    THEN

        OE_ID_TO_VALUE.CUSTOMER_LOCATION
        (   p_sold_to_site_use_id           => p_header_rec.sold_to_site_use_id
        ,   x_sold_to_location_address1     => l_header_val_rec.sold_to_location_address1
        ,   x_sold_to_location_address2     => l_header_val_rec.sold_to_location_address2
        ,   x_sold_to_location_address3     => l_header_val_rec.sold_to_location_address3
        ,   x_sold_to_location_address4     => l_header_val_rec.sold_to_location_address4
        ,   x_sold_to_location              => l_header_val_rec.sold_to_location
        ,   x_sold_to_location_city         => l_header_val_rec.sold_to_location_city
        ,   x_sold_to_location_state        => l_header_val_rec.sold_to_location_state
        ,   x_sold_to_location_postal       => l_header_val_rec.sold_to_location_postal
        ,   x_sold_to_location_country      => l_header_val_rec.sold_to_location_country
        );

    END IF;

    IF (p_header_rec.transaction_phase_code IS NULL OR
        p_header_rec.transaction_phase_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_header_rec.transaction_phase_code,
        p_old_header_rec.transaction_phase_code)
    THEN
        l_header_val_rec.transaction_phase := OE_Id_To_Value.Transaction_Phase
        (   p_transaction_phase_code    => p_header_rec.transaction_phase_code
        );
    END IF;

    IF (p_header_rec.user_status_code IS NULL OR
        p_header_rec.user_status_code <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_header_rec.user_status_code,
        p_old_header_rec.user_status_code)
    THEN
        l_header_val_rec.user_status := OE_Id_To_Value.User_Status
        (   p_user_status_code          => p_header_rec.user_status_code
        );
    END IF;

    -- END QUOTING changes

    --distributed orders
    IF (p_header_rec.end_customer_id IS NOT NULL  AND
        p_header_rec.end_customer_id <> FND_API.G_MISS_NUM)
    THEN
       OE_ID_TO_VALUE.End_Customer(
				   p_end_customer_id     => p_header_rec.end_customer_id
				   ,x_end_customer_name   => l_header_val_rec.end_customer_name
				   ,x_end_customer_number => l_header_val_rec.end_customer_number);
    END IF;

    IF (p_header_rec.end_customer_contact_id IS NOT NULL  AND
        p_header_rec.end_customer_contact_id <> FND_API.G_MISS_NUM)
    THEN
    l_header_val_rec.end_customer_contact :=
	 OE_ID_TO_VALUE.end_customer_Contact(p_end_customer_contact_id => p_header_rec.end_customer_contact_id);
    END IF;

    IF (p_header_rec.end_customer_site_use_id IS NOT NULL  AND
        p_header_rec.end_customer_site_use_id <> FND_API.G_MISS_NUM)
    THEN
       OE_ID_TO_VALUE.end_customer_site_use(
					 p_end_customer_site_use_id => p_header_rec.end_customer_site_use_id
					 ,x_end_customer_address1    => l_header_val_rec.end_customer_site_address1
					 ,x_end_customer_address2    => l_header_val_rec.end_customer_site_address2
					 ,x_end_customer_address3    => l_header_val_rec.end_customer_site_address3
					 ,x_end_customer_address4    => l_header_val_rec.end_customer_site_address4
					 ,x_end_customer_location    => l_header_val_rec.end_customer_site_location
					 ,x_end_customer_city        => l_header_val_rec.end_customer_site_city
					 ,x_end_customer_state       => l_header_val_rec.end_customer_site_state
					 ,x_end_customer_postal_code => l_header_val_rec.end_customer_site_postal_code
					 ,x_end_customer_country     => l_header_val_rec.end_customer_site_country    );
    END IF;

  -- Start BSA pricing
    IF (p_header_rec.blanket_number IS NOT NULL  OR
        p_header_rec.blanket_number <> FND_API.G_MISS_NUM)
    THEN
                oe_blanket_util_misc.get_blanketAgrName
                              (p_blanket_number   => p_header_rec.blanket_number,
                               x_blanket_agr_name => l_header_val_rec.blanket_agreement_name);
    END if;
  -- END BSA pricing

    IF (p_header_rec.ib_owner IS NULL OR
        p_header_rec.ib_owner <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_header_rec.ib_owner,
        p_old_header_rec.ib_owner)
    THEN
        l_header_val_rec.ib_owner_dsp := OE_Id_To_Value.ib_owner
        (   p_ib_owner    => p_header_rec.ib_owner
        );
    END IF;

    IF (p_header_rec.ib_current_location IS NULL OR
        p_header_rec.ib_current_location <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_header_rec.ib_current_location,
        p_old_header_rec.ib_current_location)
    THEN
        l_header_val_rec.ib_current_location_dsp := OE_Id_To_Value.ib_current_location(
        p_ib_current_location=>p_header_rec.ib_current_location
        );
    END IF;

    IF (p_header_rec.ib_installed_at_location IS NULL OR
        p_header_rec.ib_installed_at_location <> FND_API.G_MISS_CHAR) AND
        NOT OE_GLOBALS.Equal(p_header_rec.ib_installed_at_location,
        p_old_header_rec.ib_installed_at_location)
    THEN
        l_header_val_rec.ib_installed_at_location_dsp := OE_Id_To_Value.ib_installed_at_location(
        p_ib_installed_at_location=>p_header_rec.ib_installed_at_location
        );
    END IF;

-- FP contracts word integration
    IF p_header_rec.order_type_id IS NOT NULL
       AND p_header_rec.order_type_id  <> FND_API.G_MISS_NUM
       AND OE_Contracts_util.check_license = 'Y'
    THEN

	OE_CONTRACTS_UTIL.GET_CONTRACT_DEFAULTS(
       		p_api_version  		=> 1.0,
      		p_init_msg_list 	=> FND_API.G_FALSE,
  		p_doc_type 		=> 'O',
               	p_template_id 		=> p_header_rec.contract_template_id,
	   	x_authoring_party       => l_header_val_rec.authoring_party,
   		x_contract_source  	=> l_header_val_rec.contract_source,
   		x_template_name   	=> l_header_val_rec.contract_template,
                x_return_status	 	=> l_return_status,
                x_msg_count     	=> l_msg_count,
                x_msg_data      	=> l_msg_data
		);

    END IF;

    oe_debug_pub.add('Exiting OE_HEADER_UTIL.GET_VALUES', 1);

    RETURN l_header_val_rec;

END Get_Values;

--  Function Get_Ids

PROCEDURE Get_Ids
(   p_x_header_rec                  IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   p_header_val_rec                IN  OE_Order_PUB.Header_Val_Rec_Type
)
IS
l_sold_to_org_id               NUMBER;
l_ship_to_org_id               NUMBER;
l_invoice_to_org_id            NUMBER;
l_deliver_to_org_id            NUMBER;
BEGIN

    oe_debug_pub.add('Entering OE_HEADER_UTIL.GET_IDS', 1);


    IF  p_header_val_rec.accounting_rule <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.accounting_rule_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','accounting_rule');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.accounting_rule_id := OE_Value_To_Id.accounting_rule
            (   p_accounting_rule             => p_header_val_rec.accounting_rule
            );

            IF p_x_header_rec.accounting_rule_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.agreement <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.agreement_id <> FND_API.G_MISS_NUM THEN



            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','agreement');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.agreement_id := OE_Value_To_Id.agreement
            (   p_agreement                   => p_header_val_rec.agreement
            );

            IF p_x_header_rec.agreement_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.conversion_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.conversion_type_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','conversion_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.conversion_type_code := OE_Value_To_Id.conversion_type
            (   p_conversion_type             => p_header_val_rec.conversion_type
            );

            IF p_x_header_rec.conversion_type_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.fob_point <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.fob_point_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','fob_point');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.fob_point_code := OE_Value_To_Id.fob_point
            (   p_fob_point                   => p_header_val_rec.fob_point
            );

            IF p_x_header_rec.fob_point_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.freight_terms <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.freight_terms_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','freight_terms');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.freight_terms_code := OE_Value_To_Id.freight_terms
            (   p_freight_terms               => p_header_val_rec.freight_terms
            );

            IF p_x_header_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;
    IF  p_header_val_rec.shipping_method <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.shipping_method_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','shipping_method');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.shipping_method_code := OE_Value_To_Id.ship_method
            (   p_ship_method           => p_header_val_rec.shipping_method
            );

            IF p_x_header_rec.shipping_method_code = FND_API.G_MISS_CHAR THEN
            oe_debug_pub.add('Ship Method Conversion Error');
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    IF  p_header_val_rec.freight_carrier <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.freight_carrier_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','freight_carrier');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.freight_carrier_code := OE_Value_To_Id.freight_carrier
            (   p_freight_carrier               => p_header_val_rec.freight_carrier
		  ,   p_ship_from_org_id			   => p_x_header_rec.ship_from_org_id
            );

            IF p_x_header_rec.freight_carrier_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.invoicing_rule <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.invoicing_rule_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoicing_rule');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.invoicing_rule_id := OE_Value_To_Id.invoicing_rule
            (   p_invoicing_rule              => p_header_val_rec.invoicing_rule
            );

            IF p_x_header_rec.invoicing_rule_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.order_source <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.order_source_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','order_source');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.order_source_id := OE_Value_To_Id.order_source
            (   p_order_source                => p_header_val_rec.order_source
            );

            IF p_x_header_rec.order_source_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.order_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.order_type_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','order_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.order_type_id := OE_Value_To_Id.order_type
            (   p_order_type                  => p_header_val_rec.order_type
            );

            IF p_x_header_rec.order_type_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.payment_term <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.payment_term_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','payment_term');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.payment_term_id := OE_Value_To_Id.payment_term
            (   p_payment_term                => p_header_val_rec.payment_term
            );

            IF p_x_header_rec.payment_term_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.price_list <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.price_list_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_list');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.price_list_id := OE_Value_To_Id.price_list
            (   p_price_list                  => p_header_val_rec.price_list
            );

            IF p_x_header_rec.price_list_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.return_reason <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.return_reason_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','return_reason');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.return_reason_code := OE_Value_To_Id.return_reason
            (   p_return_reason  => p_header_val_rec.return_reason
            );

	 IF p_x_header_rec.return_reason_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.salesrep <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.salesrep_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','salesrep');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.salesrep_id := OE_Value_To_Id.salesrep
            (   p_salesrep  => p_header_val_rec.salesrep
            );
            IF p_x_header_rec.salesrep_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    IF  p_header_val_rec.sales_channel <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.sales_channel_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sales_channel');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.sales_channel_code := OE_Value_To_Id.sales_channel
            (   p_sales_channel  => p_header_val_rec.sales_channel
            );
            IF p_x_header_rec.sales_channel_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    IF  p_header_val_rec.shipment_priority <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.shipment_priority_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','shipment_priority');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.shipment_priority_code := OE_Value_To_Id.shipment_priority
            (   p_shipment_priority           => p_header_val_rec.shipment_priority
            );

            IF p_x_header_rec.shipment_priority_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.ship_from_address1 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.ship_from_address2 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.ship_from_address3 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.ship_from_address4 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.ship_from_location <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.ship_from_org <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.ship_from_org_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_from_org');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.ship_from_org_id := OE_Value_To_Id.ship_from_org
            (   p_ship_from_address1          => p_header_val_rec.ship_from_address1
            ,   p_ship_from_address2          => p_header_val_rec.ship_from_address2
            ,   p_ship_from_address3          => p_header_val_rec.ship_from_address3
            ,   p_ship_from_address4          => p_header_val_rec.ship_from_address4
            ,   p_ship_from_location          => p_header_val_rec.ship_from_location
            ,   p_ship_from_org               => p_header_val_rec.ship_from_org
            );

            IF p_x_header_rec.ship_from_org_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.tax_exempt <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.tax_exempt_flag <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','tax_exempt');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.tax_exempt_flag := OE_Value_To_Id.tax_exempt
            (   p_tax_exempt                  => p_header_val_rec.tax_exempt
            );

            IF p_x_header_rec.tax_exempt_flag = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.tax_exempt_reason <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.tax_exempt_reason_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','tax_exempt_reason');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.tax_exempt_reason_code := OE_Value_To_Id.tax_exempt_reason
            (   p_tax_exempt_reason           => p_header_val_rec.tax_exempt_reason
            );

            IF p_x_header_rec.tax_exempt_reason_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.tax_point <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.tax_point_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','tax_point');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.tax_point_code := OE_Value_To_Id.tax_point
            (   p_tax_point                   => p_header_val_rec.tax_point
            );

            IF p_x_header_rec.tax_point_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.payment_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.payment_type_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','payment_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.payment_type_code := OE_Value_To_Id.payment_type
            (   p_payment_type                   => p_header_val_rec.payment_type
            );

            IF p_x_header_rec.payment_type_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.credit_card <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.credit_card_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','credit_card');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.credit_card_code := OE_Value_To_Id.credit_card
            (   p_credit_card                   => p_header_val_rec.credit_card
            );

            IF p_x_header_rec.credit_card_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    ----------------------------------------------------------------------
    -- Retreiving ids for invoice_to_customer
    ----------------------------------------------------------------------

    oe_debug_pub.add('hdr Invoice_to_cust_id='||p_x_header_rec.invoice_to_customer_id);
    IF  p_header_val_rec.invoice_to_customer_name_oi <> FND_API.G_MISS_CHAR
    OR  p_header_val_rec.invoice_to_customer_number_oi <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.invoice_to_customer_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_to_customer');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
           IF p_x_header_rec.invoice_to_org_id = FND_API.G_MISS_NUM then -- 4231603
            p_x_header_rec.invoice_to_customer_id:=OE_Value_To_Id.site_customer
            ( p_site_customer       => p_header_val_rec.invoice_to_customer_name_oi
             ,p_site_customer_number=> p_header_val_rec.invoice_to_customer_number_oi
             ,p_type =>'INVOICE_TO'
            );

            IF p_x_header_rec.invoice_to_customer_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;
           END IF;
        END IF;

    END IF;

    ----------------------------------------------------------------------
    -- Retreiving ids for ship_to_customer
    ----------------------------------------------------------------------

    IF  p_header_val_rec.ship_to_customer_name_oi <> FND_API.G_MISS_CHAR
    OR  p_header_val_rec.ship_to_customer_number_oi <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.ship_to_customer_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_to_customer');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
            IF p_x_header_rec.ship_to_org_id = FND_API.G_MISS_NUM then  -- 4231603
            p_x_header_rec.ship_to_customer_id:=OE_Value_To_Id.site_customer
            ( p_site_customer       => p_header_val_rec.ship_to_customer_name_oi
             ,p_site_customer_number=> p_header_val_rec.ship_to_customer_number_oi
             ,p_type =>'SHIP_TO'
            );

            IF p_x_header_rec.ship_to_customer_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;
           END IF;
        END IF;

    END IF;


    ----------------------------------------------------------------------
    -- Retreiving ids for deliver_to_customer
    ----------------------------------------------------------------------

    IF  p_header_val_rec.deliver_to_customer_name_oi <> FND_API.G_MISS_CHAR
    OR  p_header_val_rec.deliver_to_customer_number_oi <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.deliver_to_customer_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','deliver_to_customer');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
           IF p_x_header_rec.deliver_to_org_id = FND_API.G_MISS_NUM then  -- 4231603
            p_x_header_rec.deliver_to_customer_id:=OE_Value_To_Id.site_customer
            ( p_site_customer       => p_header_val_rec.ship_to_customer_name_oi
             ,p_site_customer_number=> p_header_val_rec.ship_to_customer_number_oi
             ,p_type =>'DELIVER_TO'
            );

            IF p_x_header_rec.deliver_to_customer_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;
           END IF;
        END IF;

    END IF;

    ----------------------------------------------------------------------
    -- For customer related fields, IDs should be retrieved in the
    -- following order.
    ----------------------------------------------------------------------

    IF  p_header_val_rec.sold_to_org <> FND_API.G_MISS_CHAR
    OR  p_header_val_rec.customer_number <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.sold_to_org_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sold_to_org');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.sold_to_org_id := OE_Value_To_Id.sold_to_org
            (   p_sold_to_org                 => p_header_val_rec.sold_to_org
		  ,   p_customer_number             => p_header_val_rec.customer_number
            );

            IF p_x_header_rec.sold_to_org_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    -- Retrieve the sold_to_org_id if not passed on the header record. This
    -- will be needed by the value_to_id functions for related fields.
    -- For e.g. oe_value_to_id.ship_to_org_id requires sold_to_org_id

    IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
	  AND  p_x_header_rec.sold_to_org_id = FND_API.G_MISS_NUM
    THEN

	  SELECT SOLD_TO_ORG_ID
	  INTO l_sold_to_org_id
	  FROM OE_ORDER_HEADERS
	  WHERE HEADER_ID = p_x_header_rec.header_id;

    ELSE

	  l_sold_to_org_id := p_x_header_rec.sold_to_org_id;

    END IF;

    IF  p_header_val_rec.sold_to_contact <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.sold_to_contact_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sold_to_contact');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.sold_to_contact_id := OE_Value_To_Id.sold_to_contact
            (   p_sold_to_contact             => p_header_val_rec.sold_to_contact
		  ,   p_sold_to_org_id              => l_sold_to_org_id
            );

            IF p_x_header_rec.sold_to_contact_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.deliver_to_address1 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.deliver_to_address2 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.deliver_to_address3 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.deliver_to_address4 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.deliver_to_location <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.deliver_to_org <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.deliver_to_org_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','deliver_to_org');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
/*1621182*/
            p_x_header_rec.deliver_to_org_id := OE_Value_To_Id.deliver_to_org
            (   p_deliver_to_address1         => p_header_val_rec.deliver_to_address1
            ,   p_deliver_to_address2         => p_header_val_rec.deliver_to_address2
            ,   p_deliver_to_address3         => p_header_val_rec.deliver_to_address3
            ,   p_deliver_to_address4         => p_header_val_rec.deliver_to_address4
            ,   p_deliver_to_location         => p_header_val_rec.deliver_to_location
            ,   p_deliver_to_org              => p_header_val_rec.deliver_to_org
            ,   p_deliver_to_city             => p_header_val_rec.deliver_to_city
            ,   p_deliver_to_state            => p_header_val_rec.deliver_to_state
            ,   p_deliver_to_postal_code      => p_header_val_rec.deliver_to_zip
            ,   p_deliver_to_country          => p_header_val_rec.deliver_to_country
		  ,   p_sold_to_org_id        => l_sold_to_org_id
            , p_deliver_to_customer_id => p_x_header_rec.deliver_to_customer_id
            );
/*1621182*/

            IF p_x_header_rec.deliver_to_org_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.invoice_to_address1 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.invoice_to_address2 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.invoice_to_address3 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.invoice_to_address4 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.invoice_to_location <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.invoice_to_org <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.invoice_to_org_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_to_org');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
/*1621182*/
            p_x_header_rec.invoice_to_org_id := OE_Value_To_Id.invoice_to_org
            (   p_invoice_to_address1         => p_header_val_rec.invoice_to_address1
            ,   p_invoice_to_address2         => p_header_val_rec.invoice_to_address2
            ,   p_invoice_to_address3         => p_header_val_rec.invoice_to_address3
            ,   p_invoice_to_address4         => p_header_val_rec.invoice_to_address4
            ,   p_invoice_to_location         => p_header_val_rec.invoice_to_location
            ,   p_invoice_to_org              => p_header_val_rec.invoice_to_org
            ,   p_invoice_to_city             => p_header_val_rec.invoice_to_city
            ,   p_invoice_to_state            => p_header_val_rec.invoice_to_state
            ,   p_invoice_to_postal_code      => p_header_val_rec.invoice_to_zip
            ,   p_invoice_to_country          => p_header_val_rec.invoice_to_country
		  ,   p_sold_to_org_id        => l_sold_to_org_id
            , p_invoice_to_customer_id => p_x_header_rec.invoice_to_customer_id
            );
/*1621182*/

            IF p_x_header_rec.invoice_to_org_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.ship_to_address1 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.ship_to_address2 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.ship_to_address3 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.ship_to_address4 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.ship_to_location <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.ship_to_org <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.ship_to_org_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_to_org');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
/*1621182*/
            p_x_header_rec.ship_to_org_id := OE_Value_To_Id.ship_to_org
            (   p_ship_to_address1            => p_header_val_rec.ship_to_address1
            ,   p_ship_to_address2            => p_header_val_rec.ship_to_address2
            ,   p_ship_to_address3            => p_header_val_rec.ship_to_address3
            ,   p_ship_to_address4            => p_header_val_rec.ship_to_address4
            ,   p_ship_to_location            => p_header_val_rec.ship_to_location
            ,   p_ship_to_city                => p_header_val_rec.ship_to_city
            ,   p_ship_to_state               => p_header_val_rec.ship_to_state
            ,   p_ship_to_postal_code         => p_header_val_rec.ship_to_zip
            ,   p_ship_to_country             => p_header_val_rec.ship_to_country
            ,   p_ship_to_org                 => p_header_val_rec.ship_to_org
		  ,   p_sold_to_org_id        => l_sold_to_org_id
            , p_ship_to_customer_id => p_x_header_rec.ship_to_customer_id
            );
/*1621182*/

            IF p_x_header_rec.ship_to_org_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

-- QUOTING changes
    IF  p_header_val_rec.sold_to_location_address1 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.sold_to_location_address2 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.sold_to_location_address3 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.sold_to_location_address4 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.sold_to_location          <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.sold_to_location <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.sold_to_site_use_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Customer_Location');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
            p_x_header_rec.sold_to_site_use_id := OE_Value_To_Id.Customer_Location
            (   p_sold_to_location_address1            => p_header_val_rec.sold_to_location_address1
            ,   p_sold_to_location_address2            => p_header_val_rec.sold_to_location_address2
            ,   p_sold_to_location_address3            => p_header_val_rec.sold_to_location_address3
            ,   p_sold_to_location_address4            => p_header_val_rec.sold_to_location_address4
            ,   p_sold_to_location                     => p_header_val_rec.sold_to_location
	    ,   p_sold_to_org_id                       => l_sold_to_org_id
            ,   p_sold_to_location_city                => p_header_val_rec.sold_to_location_city
            ,   p_sold_to_location_state               => p_header_val_rec.sold_to_location_state
            ,   p_sold_to_location_postal_code         => p_header_val_rec.sold_to_location_postal
            ,   p_sold_to_location_country             => p_header_val_rec.sold_to_location_country
            );


    oe_debug_pub.add('after hdr sold_to_site_use_id='||p_x_header_rec.sold_to_site_use_id);

            IF p_x_header_rec.sold_to_site_use_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;
-- QUOTING changes

    -- Retrieve the org_ids if not passed on the header record. These
    -- IDs will be needed by the value_to_id functions for CONTACT fields.
    -- For e.g. oe_value_to_id.ship_to_contact_id requires ship_to_org_id

    IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
	  AND (  p_x_header_rec.ship_to_org_id = FND_API.G_MISS_NUM
	       OR p_x_header_rec.invoice_to_org_id = FND_API.G_MISS_NUM
	       OR p_x_header_rec.deliver_to_org_id = FND_API.G_MISS_NUM )
    THEN

	  SELECT SHIP_TO_ORG_ID, INVOICE_TO_ORG_ID, DELIVER_TO_ORG_ID
	 -- bug 8340976 INTO l_sold_to_org_id, l_invoice_to_org_id, l_deliver_to_org_id
          INTO l_ship_to_org_id, l_invoice_to_org_id, l_deliver_to_org_id
	  FROM OE_ORDER_HEADERS
	  WHERE HEADER_ID = p_x_header_rec.header_id;

	  IF p_x_header_rec.ship_to_org_id <> FND_API.G_MISS_NUM THEN
		l_ship_to_org_id := p_x_header_rec.ship_to_org_id;
       END IF;

	  IF p_x_header_rec.invoice_to_org_id <> FND_API.G_MISS_NUM THEN
		l_invoice_to_org_id := p_x_header_rec.invoice_to_org_id;
       END IF;

	  IF p_x_header_rec.deliver_to_org_id <> FND_API.G_MISS_NUM THEN
		l_deliver_to_org_id := p_x_header_rec.deliver_to_org_id;
       END IF;

    ELSE

	  -- bug 8340976 l_sold_to_org_id := p_x_header_rec.sold_to_org_id;
          l_ship_to_org_id := p_x_header_rec.sold_to_org_id;  -- bug 8340976
	  l_invoice_to_org_id := p_x_header_rec.invoice_to_org_id;
	  l_deliver_to_org_id := p_x_header_rec.deliver_to_org_id;

    END IF;

    IF  p_header_val_rec.deliver_to_contact <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.deliver_to_contact_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','deliver_to_contact');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.deliver_to_contact_id := OE_Value_To_Id.deliver_to_contact
            (   p_deliver_to_contact          => p_header_val_rec.deliver_to_contact
		  ,   p_deliver_to_org_id           => l_deliver_to_org_id
            );

            IF p_x_header_rec.deliver_to_contact_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.invoice_to_contact <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.invoice_to_contact_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_to_contact');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.invoice_to_contact_id := OE_Value_To_Id.invoice_to_contact
            (   p_invoice_to_contact          => p_header_val_rec.invoice_to_contact
		  ,   p_invoice_to_org_id           => l_invoice_to_org_id
            );

            IF p_x_header_rec.invoice_to_contact_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.ship_to_contact <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.ship_to_contact_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_to_contact');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.ship_to_contact_id := OE_Value_To_Id.ship_to_contact
            (   p_ship_to_contact             => p_header_val_rec.ship_to_contact
		  ,   p_ship_to_org_id              => l_ship_to_org_id
            );

            IF p_x_header_rec.ship_to_contact_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

/* mvijayku */
    IF  p_header_val_rec.end_customer_name <> FND_API.G_MISS_CHAR
    OR  p_header_val_rec.end_customer_number <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.end_customer_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_customer');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
           IF p_x_header_rec.end_customer_site_use_id = FND_API.G_MISS_NUM THEN -- 4231603
            p_x_header_rec.end_customer_id:=OE_Value_To_Id.end_customer
            ( p_end_customer       => p_header_val_rec.end_customer_name
             ,p_end_customer_number=> p_header_val_rec.end_customer_number
              );

            IF p_x_header_rec.end_customer_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;
          END IF;
        END IF;

    END IF;

    IF  p_header_val_rec.end_customer_contact <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.end_customer_id <>FND_API.G_MISS_NUM and
                p_x_header_rec.end_customer_contact_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_customer__contact');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
                oe_debug_pub.add('before calling aend customer contact value to id');
            p_x_header_rec.end_customer_contact_id := OE_Value_To_Id.end_customer_contact
            (   p_end_customer_contact             => p_header_val_rec.end_customer_contact
		  ,p_end_customer_id              =>p_x_header_rec.end_customer_id
            );
	    oe_debug_pub.add('End customer contact id is '||p_x_header_rec.end_customer_contact_id);

            IF p_x_header_rec.end_customer_contact_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

  IF (p_header_val_rec.end_customer_name <> FND_API.G_MISS_CHAR
      OR p_header_val_rec.end_customer_number <> FND_API.G_MISS_CHAR
      OR p_x_header_rec.end_customer_id <> FND_API.G_MISS_NUM)
	 AND
     (p_header_val_rec.end_customer_site_address1 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.end_customer_site_address2 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.end_customer_site_address3 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.end_customer_site_address4 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.end_customer_site_location          <> FND_API.G_MISS_CHAR)

    THEN

        IF p_x_header_rec.end_customer_site_use_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_Customer_Location');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
	   oe_debug_pub.add('Before calling End custoemr site use value to id');
            p_x_header_rec.end_customer_site_use_id := OE_Value_To_Id.end_customer_site
            (   p_end_customer_site_address1            => p_header_val_rec.end_customer_site_address1
            ,   p_end_customer_site_address2            => p_header_val_rec.end_customer_site_address2
            ,   p_end_customer_site_address3            => p_header_val_rec.end_customer_site_address3
            ,   p_end_customer_site_address4            => p_header_val_rec.end_customer_site_address4
            ,   p_end_customer_site_location                     => p_header_val_rec.end_customer_site_location
	    ,   p_end_customer_site_org                       => NULL
		,   p_end_customer_id                         => p_x_header_rec.end_customer_id
            ,   p_end_customer_site_city                => p_header_val_rec.end_customer_site_city
            ,   p_end_customer_site_state               => p_header_val_rec.end_customer_site_state
            ,   p_end_customer_site_postalcode         => p_header_val_rec.end_customer_site_postal_code
            ,   p_end_customer_site_country             => p_header_val_rec.end_customer_site_country
            ,   p_end_customer_site_use_code           => NULL
            );


    oe_debug_pub.add('after hdr sold_to_site_use_id='||p_x_header_rec.end_customer_site_use_id);

            IF p_x_header_rec.end_customer_site_use_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    -- {added for bug 4240715
    IF  p_header_val_rec.ib_owner_dsp <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.ib_owner <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','IB_Owner');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.ib_owner:=OE_Value_To_Id.ib_owner
            ( p_ib_owner       => p_header_val_rec.ib_owner_dsp
              );

	     oe_Debug_pub.add('ib owner id is '||p_x_header_rec.ib_owner);
            IF p_x_header_rec.ib_owner = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.ib_installed_at_location_dsp <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.ib_installed_at_location <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','IB_Installed_at_location');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.ib_installed_at_location:=OE_Value_To_Id.ib_installed_at_location
            ( p_ib_installed_at_location       => p_header_val_rec.ib_installed_at_location_dsp
              );
              oe_Debug_pub.add('installed at location'||p_x_header_rec.ib_installed_at_location);

            IF p_x_header_rec.ib_installed_at_location = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

     IF  p_header_val_rec.ib_current_location_dsp <> FND_API.G_MISS_CHAR
    THEN
        IF p_x_header_rec.ib_current_location <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','IB_current_location');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.ib_current_location:=OE_Value_To_Id.ib_current_location
            ( p_ib_current_location       => p_header_val_rec.ib_current_location_dsp
              );

            IF p_x_header_rec.ib_current_location = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    --bug 4240715}

    ----------------------------------------------------------------------
    -- End of get IDs for customer related fields
    ----------------------------------------------------------------------

    oe_debug_pub.add('Exiting OE_HEADER_UTIL.GET_IDS', 1);

END Get_Ids;


FUNCTION Get_ord_seq_type
(   p_order_type_id                 IN  NUMBER
 ,  p_transaction_phase_code        IN  VARCHAR2 DEFAULT 'F'
) RETURN VARCHAR2 IS
	x_doc_sequence_value    NUMBER;
	x_doc_category_code     VARCHAR(30);
	X_doc_sequence_id       NUMBER;
	X_set_Of_Books_id       NUMBER;
	seqassid                INTEGER;
	x_Trx_Date          	DATE;
	l_set_of_books_rec    	OE_Order_Cache.Set_Of_Books_Rec_Type;
	l_dummy                 VARCHAR2(10);
	t                   	VARCHAR2(1);
	X_db_sequence_name     	VARCHAR2(50);
	x_doc_sequence_type 	CHAR(1);
	X_doc_sequence_name 	VARCHAR2(240);
	X_Prd_Tbl_Name 			VARCHAR2(240) ;
	X_Aud_Tbl_Name 			VARCHAR2(240);
	X_Msg_Flag 				VARCHAR2(240);
	x_result 				NUMBER;

BEGIN

	oe_debug_pub.add('Entering OE_HEADER_UTIL.Get_Ord_Seq_Type',1);

    IF p_order_type_id IS NULL OR
        p_order_type_id = FND_API.G_MISS_NUM
    THEN
       OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);
        RETURN NULL;
    END IF;

    l_set_of_books_rec :=
    OE_Order_Cache.Load_Set_Of_Books;

	x_Set_Of_Books_Id := l_set_of_books_rec.set_of_books_id;

    -- X_Doc_Category_Code := to_char(p_order_type_id);

    -- QUOTING changes
    IF nvl(p_transaction_phase_code,'F') = 'F' THEN
        X_Doc_Category_Code := to_char(p_order_type_id);
    ELSIF p_transaction_phase_code = 'N' THEN
        X_Doc_Category_Code := to_char(p_order_type_id)||'-Quote';
    END IF;

    x_result :=   fnd_seqnum.get_seq_info(
                                          660,
                                          x_doc_category_code,
                                          x_set_of_books_id,
                                          null,
                                          sysdate,
                                          X_doc_sequence_id,
										  x_doc_sequence_type,
										  x_doc_sequence_name,
                                          X_db_sequence_name,
			        				      seqassid,
										  X_Prd_Tbl_Name,
										  X_Aud_Tbl_Name,
										  X_Msg_Flag
										  );
	IF x_result <> 0 THEN
    	RAISE FND_API.G_EXC_ERROR;
	END IF;

	oe_debug_pub.add('Exiting OE_HEADER_UTIL.Get_Ord_Seq_Type',1);

	RETURN x_doc_sequence_type;

EXCEPTION

WHEN OTHERS THEN
		RETURN NULL;

END Get_ord_seq_type ;

FUNCTION Get_Mtl_Sales_Order_Id(p_header_id    IN NUMBER
						 ,p_order_number IN NUMBER := FND_API.G_MISS_NUM)
RETURN NUMBER
IS
BEGIN
    return inv_salesorder.get_salesorder_for_oeheader
                             (p_oe_header_id => p_header_id);
END Get_Mtl_Sales_Order_Id;

PROCEDURE Get_Order_Info(p_header_id    IN  NUMBER,
                         x_order_number OUT NOCOPY /* file.sql.39 change */ NUMBER,
                         x_order_type   OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                         x_order_source OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
	l_order_number  NUMBER;
	l_order_type_id NUMBER := 0;
BEGIN

    --Commenting the oe_debug_pub call to fix bug 2105266.

--	oe_debug_pub.add('Entering OE_HEADER_UTIL.Get_Order_Info',1);

    BEGIN
       SELECT order_number,order_type_id
       INTO l_order_number,l_order_type_id
       FROM oe_order_headers_all
       WHERE header_id = p_header_id;

       x_order_source := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
       x_order_number := l_order_number;
    EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_order_number := NULL;
    END;

    BEGIN
       -- Fix for bug#1078323: the order type name should be selected in
       -- the base language
       SELECT name
       INTO x_order_type
       FROM OE_TRANSACTION_TYPES_TL
       WHERE TRANSACTION_TYPE_ID = l_order_type_id
       AND language = (select language_code from
					fnd_languages
					where installed_flag = 'B');
    EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_order_type := NULL;
    END;

--	oe_debug_pub.add('Exiting OE_HEADER_UTIL.Get_Order_Info',1);

END Get_Order_Info;

FUNCTION Get_Header_Id (p_order_number    IN  NUMBER,
                        p_order_type      IN  VARCHAR2,
                        p_order_source    IN  VARCHAR2)
RETURN NUMBER
IS
	l_order_type_id          NUMBER;
	l_order_type             VARCHAR2(240);
	l_header_id              NUMBER;
BEGIN

    Select header_id
    into l_header_id
    from oe_order_headers
    where order_number = p_order_number AND
          order_type_id = (select tl.transaction_type_id
                           from oe_transaction_types_tl tl,
						  oe_transaction_types_all ta
                           where ta.transaction_type_id =
					  tl.transaction_type_id and
					  tl.name = p_order_type and
					  ta.transaction_type_code = 'ORDER'
 					 and LANGUAGE = (
 					select language_code
                      	from fnd_languages
                      	where installed_flag = 'B'));

    RETURN l_header_id;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RETURN -1;
   WHEN OTHERS THEN
     RETURN -1;

END Get_Header_Id;

FUNCTION Get_Order_Type
(   p_order_type_id        IN  NUMBER)
RETURN VARCHAR2
IS
	l_order_type_id          NUMBER;
	l_order_type             VARCHAR2(240);
BEGIN

	oe_debug_pub.add('Entering OR_HEADER_UTIL.Get_Order_Type',1);

    Select order_category_code --name --commented for BUG#7671483
    into l_order_type
    from oe_order_types_v
    where transaction_type_id = p_order_type_id;

	oe_debug_pub.add('Exiting OR_HEADER_UTIL.Get_Order_Type',1);

    RETURN l_order_type;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RETURN null;
   WHEN OTHERS THEN
     RETURN null;

END Get_Order_Type;

PROCEDURE Get_Order_Number
         ( p_x_header_rec 	IN OUT NOCOPY oe_order_pub.header_rec_type,
           p_old_header_rec    IN oe_order_pub.header_rec_type )
IS
	l_order_number	    		VARCHAR2(30):= NULL;
	x_doc_sequence_value     	NUMBER;
	x_doc_category_code      	VARCHAR(30);
	X_doc_sequence_id       	NUMBER;
	X_db_sequence_name      	VARCHAR2(50);
	x_doc_sequence_type 		CHAR(1);
	X_doc_sequence_name 		VARCHAR2(240);
	X_Prd_Tbl_Name 			VARCHAR2(240) ;
	X_Aud_Tbl_Name 			VARCHAR2(240);
	X_Msg_Flag 			VARCHAR2(240);
	X_set_Of_Books_id       	NUMBER;
	seqassid                	INTEGER;
	l_ord_num_src_id    		NUMBER	:= NULL;
	l_order_type_rec    		OE_Order_Cache.Order_Type_Rec_Type;
	l_set_of_books_rec    		OE_Order_Cache.Set_Of_Books_Rec_Type;
	l_order_number_csr  		INTEGER;
	l_result	    		INTEGER;
	l_select_stmt	   		VARCHAR2(240);
	l_column_name	   	 	VARCHAR2(80);
	l_doc_seq_type                  VARCHAR2(240);
	l_return_status	    		VARCHAR2(30);
	X_trx_date         		DATE;
	lcount 				NUMBER;
	x_result 			NUMBER;

BEGIN
        oe_debug_pub.add('Entering OE_HEADER_UTIL.Get_Order_Number',1);
        oe_debug_pub.add('Entering OE_HEADER_UTIL.Get_Order_Number',1);
        -- Check if Order Number can be updated or not???? bug 4146258
        -- Fixed by Srini
        IF NOT OE_GLOBALS.EQUAL(p_x_header_rec.order_number,
                                p_old_header_rec.order_number)
           AND p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
           AND p_old_header_rec.order_number is not null
           AND p_old_header_rec.order_number <> FND_API.G_MISS_NUM
        THEN
           if p_x_header_rec.booked_flag = 'Y' and
              nvl(p_x_header_rec.open_flag,'Y') = 'Y' then
              FND_MESSAGE.SET_NAME('ONT','ONT_INVALID_ORD_NUM_BOOKING');
              OE_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
           end if;
           l_set_of_books_rec := OE_Order_Cache.Load_Set_Of_Books;
           x_Set_Of_Books_Id := l_set_of_books_rec.set_of_books_id;
           l_order_type_rec := OE_Order_Cache.Load_Order_Type (p_x_header_rec.order_type_id);
           oe_debug_pub.add('When Order Number has been changed :'||p_x_header_rec.transaction_phase_code);
           IF nvl(p_x_header_rec.transaction_phase_code,'F') = 'F' THEN
              X_Doc_Category_Code := to_char(p_x_header_rec.order_type_id);
           ELSIF p_x_header_rec.transaction_phase_code = 'N' THEN
              X_Doc_Category_Code := to_char(p_x_header_rec.order_type_id)||'-Quote';
           END IF;
           x_result :=   fnd_seqnum.get_seq_info(
                                             660,
                                             x_doc_category_code,
                                             x_set_of_books_id,
                                             null,
                                             sysdate,
                                             X_doc_sequence_id,
                                             x_doc_sequence_type,
                                             x_doc_sequence_name,
                                             X_db_sequence_name,
                                             seqassid,
                                             X_Prd_Tbl_Name,
                                             X_Aud_Tbl_Name,
                                             X_Msg_Flag);

           if p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE and
              x_doc_sequence_type = 'A'
           then
              FND_MESSAGE.SET_NAME('ONT','ONT_ORD_NUM_MISMATCH');
              OE_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
           end if;

        END IF;

        -- QUOTING changes
	IF NOT OE_GLOBALS.EQUAL(p_x_header_rec.order_type_id,
					 p_old_header_rec.order_type_id)
           OR (OE_Quote_Util.G_COMPLETE_NEG = 'Y'
	       AND NOT OE_GLOBALS.EQUAL(p_x_header_rec.transaction_phase_code,
				 p_old_header_rec.transaction_phase_code)
               )
        THEN

    	   oe_debug_pub.ADD('Ordertype is :' || to_char(p_x_header_rec.order_type_id),3);

    	   l_set_of_books_rec := OE_Order_Cache.Load_Set_Of_Books;
	   x_Set_Of_Books_Id := l_set_of_books_rec.set_of_books_id;

    	   IF p_x_header_rec.order_type_id IS NOT NULL AND
			p_x_header_rec.order_type_id <> FND_API.G_MISS_NUM
    	   THEN

              l_order_type_rec := OE_Order_Cache.Load_Order_Type (p_x_header_rec.order_type_id);

              oe_debug_pub.add('transaction phase :'||p_x_header_rec.transaction_phase_code);
              -- Quoting Changes
              IF nvl(p_x_header_rec.transaction_phase_code,'F') = 'F' THEN
                 X_Doc_Category_Code := to_char(p_x_header_rec.order_type_id);
              ELSIF p_x_header_rec.transaction_phase_code = 'N' THEN
                 X_Doc_Category_Code := to_char(p_x_header_rec.order_type_id)||'-Quote';
              END IF;
    	   ELSE
	      RAISE FND_API.G_EXC_ERROR ;
    	   END IF;

           -- QUOTING changes
           IF OE_Quote_Util.G_COMPLETE_NEG = 'Y'
              AND nvl(l_order_type_rec.quote_num_as_ord_num_flag,'Y') = 'Y' --added nvl for bug4474915
           THEN
              oe_debug_pub.ADD('retain document number is Yes');
              GOTO End_Of_Procedure;
           END IF;

    	   oe_debug_pub.ADD('before calling get_seq_info ', 2);
 	   oe_debug_pub.ADD('Category Code'||x_doc_category_code, 3);
    	   oe_debug_pub.ADD('Set of Books'||x_set_of_books_id, 3);
           x_result :=   fnd_seqnum.get_seq_info(
                                             660,
                                             x_doc_category_code,
                                             x_set_of_books_id,
                                             null,
                                             sysdate,
                                             X_doc_sequence_id,
					     x_doc_sequence_type,
					     x_doc_sequence_name,
                                             X_db_sequence_name,
			        	     seqassid,
					     X_Prd_Tbl_Name,
					     X_Aud_Tbl_Name,
					     X_Msg_Flag
											 );

    	   oe_debug_pub.ADD('after calling get_seq_info ', 2);

           IF x_result <>  FND_SEQNUM.SEQSUCC   THEN
    	      IF x_result = FND_SEQNUM.NOTUSED THEN
    		 fnd_message.set_name('ONT','OE_MISS_DOC_SEQ');
    		 OE_MSG_PUB.Add;
    		 RAISE FND_API.G_EXC_ERROR;
    	      END IF;
           END IF;
	   l_doc_seq_type := x_doc_sequence_type;

    	   IF ( l_doc_seq_type <> 'M')  THEN

                X_result := fnd_seqnum.get_seq_val(
                                                660,
                                                x_doc_category_code,
                                                x_set_of_books_id,
                                                null,
                                                sysdate,
						x_doc_sequence_value,
                                                X_doc_sequence_id,
						'Y',
						'Y');
   		IF x_result <>  0   THEN
    		   RAISE FND_API.G_EXC_ERROR;
   		END IF;

    		oe_debug_pub.ADD('fndseqresult'||to_char(x_result), 2);
    		oe_debug_pub.ADD('fndseqtype'||x_doc_sequence_value, 2);

                -- Quoting Changes
                IF nvl(p_x_header_rec.transaction_phase_code,'F') = 'F' THEN
    		   p_x_header_rec.order_number :=  x_doc_sequence_value;
                ELSIF p_x_header_rec.transaction_phase_code = 'N' THEN
    		   p_x_header_rec.quote_number :=  x_doc_sequence_value;
    		   p_x_header_rec.order_number :=  x_doc_sequence_value;
                END IF;


           ELSIF (l_doc_seq_type = 'M') THEN
                oe_debug_pub.add('manual sequence');

                   -- Quoting Changes
                   -- Fix for bug 3204076
                   -- Raise error if manual sequence and quote/order number is
                   -- not provided.
                   IF nvl(p_x_header_rec.transaction_phase_code,'F') = 'F' THEN
                      IF p_x_header_rec.order_number IS NULL THEN
                         fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
                         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                             OE_Order_UTIL.Get_Attribute_Name('ORDER_NUMBER'));
                         OE_MSG_PUB.Add;
                         RAISE FND_API.G_EXC_ERROR;
                      ELSE
                      x_doc_sequence_value := p_x_header_rec.order_number;
                      END IF;
                   ELSIF p_x_header_rec.transaction_phase_code = 'N' THEN
                      IF p_x_header_rec.quote_number IS NULL THEN
                         fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
                         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                             OE_Order_UTIL.Get_Attribute_Name('QUOTE_NUMBER'));
                         OE_MSG_PUB.Add;
                         RAISE FND_API.G_EXC_ERROR;
                      ELSE
                      x_doc_sequence_value := p_x_header_rec.quote_number;
    		      p_x_header_rec.order_number :=  x_doc_sequence_value;
                      END IF;
                   END IF;

           END IF;

           -- QUOTING changes - unique key checks and set WF user keys
           -- based on transaction phase
           IF nvl(p_x_header_rec.transaction_phase_code,'F') = 'F' THEN

                 Select Count(Header_id) into
                        lcount
                 From   OE_ORDER_HEADERS_ALL
                 WHERE  order_type_id = p_x_header_rec.order_type_id
                 and    order_number = p_x_header_rec.order_number
                 -- We need to remove the check condition around the version number.
                 --Bug #3357896.
                 --and version_number = p_x_header_rec.version_number
                 and    header_id <> p_x_header_rec.header_id;

                 IF  lcount > 0 THEN
                   fnd_message.set_name('ONT','OE_ORDER_NUM_EXISTS');
                   OE_MSG_PUB.Add;
                   RAISE FND_API.G_EXC_ERROR;
	         END IF;

                 -- Fix for bug# 3526149. Also see bug 3485680
                 oe_debug_pub.add('p_old_header_rec.order_number:' || p_old_header_rec.order_number,1);
                 oe_debug_pub.add('p_old_header_rec.transaction_phase_code:' ||
                                                            p_old_header_rec.transaction_phase_code,1);
                 IF (p_x_header_rec.order_number <> p_old_header_rec.order_number AND
                     p_old_header_rec.order_number is not null AND
                     p_old_header_rec.order_number <> FND_API.G_MISS_NUM) AND
                     OE_Quote_Util.G_COMPLETE_NEG = 'N' THEN
                       oe_debug_pub.add('Ord_Num Changed, Calling Set_Header_User_Key and WF_ENGINE.SetItemUserKey',1);
                       OE_Order_WF_Util.Set_Header_User_Key(p_x_header_rec);
                       WF_ENGINE.SetItemUserKey(OE_Globals.G_WFI_HDR, to_char(p_x_header_rec.header_id),
                                substrb(fnd_message.get, 1, 240));

                       WF_ENGINE.SetItemAttrNumber(OE_Globals.G_WFI_HDR, to_char(p_x_header_rec.header_id),
                                        'ORDER_NUMBER', p_x_header_rec.order_number);  -- Bug 3589688
                 END IF;

           ELSIF p_x_header_rec.transaction_phase_code = 'N' THEN

                 Select Count(Header_id) into
                        lcount
                 From   OE_ORDER_HEADERS_ALL
                 WHERE  order_type_id = p_x_header_rec.order_type_id
                 and    quote_number = p_x_header_rec.quote_number
                 -- We need to remove the check condition around the version number.
                 --Bug #3357896.
                 --and version_number = p_x_header_rec.version_number
                 and header_id <> p_x_header_rec.header_id;

                 IF  lcount > 0 THEN
                     fnd_message.set_name('ONT','OE_QUOTE_NUM_EXISTS');
                     OE_MSG_PUB.Add;
                     RAISE FND_API.G_EXC_ERROR;
	         END IF;

                 -- Fix for bug# 3526149. Also see bug 3485680
                 oe_debug_pub.add('p_old_header_rec.quote_number:' || p_old_header_rec.quote_number,1);
                 IF (p_x_header_rec.quote_number <> p_old_header_rec.quote_number AND
                     p_old_header_rec.quote_number is not null AND
                     p_old_header_rec.quote_number <> FND_API.G_MISS_NUM) THEN
                        oe_debug_pub.add('Calling OE_Order_WF_Util.Set_Negotiate_Hdr_User_Key for HeaderID:'
                                              || to_char(p_x_header_rec.header_id), 1);
                        OE_Order_WF_Util.Set_Negotiate_Hdr_User_Key
                                (p_header_id => p_x_header_rec.header_id
                                ,p_sales_document_type_code => 'O'
                                ,p_transaction_number => p_x_header_rec.quote_number
                                );
                        WF_ENGINE.SetItemAttrNumber(OE_GLOBALS.G_WFI_NGO, to_char(p_x_header_rec.header_id),
                                        'TRANSACTION_NUMBER', p_x_header_rec.quote_number);  -- Bug 3589688
                 END IF;


           END IF; -- end if transaction phase check

	END IF;  -- Global equal

        <<End_Of_Procedure>>

	oe_debug_pub.add('Exiting OR_HEADER_UTIL.Get_Order_Number',1);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    oe_debug_pub.ADD('Get Order Number-Exp exception ', 1);
     RAISE FND_API.G_EXC_ERROR;


    WHEN OTHERS THEN
    oe_debug_pub.ADD('Get Order Number-exception ', 1);


    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'Get_Order_Number'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Order_Number;

FUNCTION Get_Base_Order_Type
(   p_order_type_id        IN  NUMBER)
RETURN VARCHAR2
IS
   l_order_type_id          NUMBER;
   l_order_type             VARCHAR2(240);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Entering OR_HEADER_UTIL.Get_Base_Order_Type ' || p_order_type_id,1);
   END IF;

     SELECT NAME
     INTO l_order_type
     FROM OE_TRANSACTION_TYPES_TL
     WHERE TRANSACTION_TYPE_ID = p_order_type_id
     AND language = (select language_code
                     from fnd_languages
                     where installed_flag = 'B');

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Exiting OR_HEADER_UTIL.Get_Base_Order_Type ' || l_order_type,1);
   END IF;

    RETURN l_order_type;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RETURN null;
   WHEN OTHERS THEN
     RETURN null;

END Get_Base_Order_Type;

--7688372 start
PROCEDURE Load_attachment_rules
IS
   CURSOR header_attributes IS
   SELECT oare.ATTRIBUTE_CODE  attribute_code,Count(1) attachment_count
   FROM   oe_attachment_rule_elements oare, oe_attachment_rules  oar
   WHERE  oare.rule_id=oar.rule_id
   AND    oar.DATABASE_OBJECT_NAME='OE_AK_ORDER_HEADERS_V'
   GROUP BY oare.ATTRIBUTE_CODE;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
 IF l_debug_level > 0 then
  oe_debug_pub.add('Entering Load_attachment_rules');
 End IF;

 IF g_attachment_rule_count_tab.count = 0 THEN
   FOR header_attributes_rec IN header_attributes LOOP
      g_attachment_rule_count_tab(header_attributes_rec.attribute_code) := header_attributes_rec.attachment_count;
   END LOOP;
 END IF;

 IF l_debug_level > 0 then
  oe_debug_pub.add('Exiting Load_attachment_rules');
 End IF;

END Load_attachment_rules;
--7688372 end


PROCEDURE Pre_Write_Process
         ( p_x_header_rec 	IN OUT NOCOPY  oe_order_pub.header_rec_type,
           p_old_header_rec    IN oe_order_pub.header_rec_type )
IS
-- included to fix bug 1589196   Begin
   CURSOR C_HSC_COUNT(t_header_id Number) IS
   SELECT count(sales_credit_id), max(sales_credit_id)
   FROM oe_sales_credits sc,
	   oe_sales_credit_types sct
   WHERE header_id = t_header_id
   AND   sct.sales_credit_type_id = sc.sales_credit_type_id
   AND   sct.quota_flag = 'Y'
   AND   line_id is null;
-- included to fix bug 1589196  End

	l_return_status 			VARCHAR2(30);
	l_count						NUMBER;
/* Variables to call process order */
	l_control_rec	OE_GLOBALS.Control_Rec_Type;
	p_x_old_header_rec OE_ORDER_PUB.Header_Rec_Type:=  p_old_header_rec ;
	l_msg_count NUMBER;
	l_msg_data VARCHAR2(2000);
	l_new_order_type  varchar2(80);
	l_order_type varchar2(80);
	l_return_value number;
	l_source_code VARCHAR2(40);
-- included to fix bug 1589196   Begin
        l_sales_crd_cnt number;
        l_sales_crd_id  number;
-- included to fix bug 1589196   end
        l_reason_code VARCHAR2(30);
        l_reason_comments VARCHAR2(2000);
        --bug 4190357
        v_count                     NUMBER;
        l_meaning               VARCHAR2(80);
        l_old_line_tbl              OE_Order_PUB.Line_Tbl_Type;
        l_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
        i                           Number;
        j                           Number := 0;
        lx_line_rec                 OE_Order_PUB.Line_Rec_Type;
        l_apply_automatic_atchmt    VARCHAR2(1) :=
NVL(FND_PROFILE.VALUE('OE_APPLY_AUTOMATIC_ATCHMT'),'Y') ; --5893276

        cursor line_ids(p_header_id IN NUMBER) is
        select line_id from oe_order_lines_all
        where header_id = p_header_id;
        --bug 4190357
-- R12 CC encryption
        l_changed_attribute VARCHAR2(200);
        l_modified_from     VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_attr_attach_change         boolean := FALSE;  --6896311
BEGIN
	oe_debug_pub.add('Entering OR_HEADER_UTIL.Pre_Write_Process',1);

        OE_SALES_CAN_UTIL.G_IR_ISO_HDR_CANCEL := FALSE;
        -- Setting the global for IR ISO Tracking bug 7667702

     /* Start AuditTrail */

     IF (p_x_header_rec.operation  = OE_GLOBALS.G_OPR_UPDATE) THEN

        IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG = 'Y' THEN
           OE_DEBUG_PUB.add('OEXUHDRB: Audit check requires reason', 5);

           IF (p_x_header_rec.change_reason IS NULL
                OR p_x_header_rec.change_reason = FND_API.G_MISS_CHAR
                OR NOT OE_Validate.Change_Reason_Code(p_x_header_rec.change_reason)) then

                 IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
                   IF OE_Versioning_Util.Captured_Reason IS NULL THEN
                      OE_Versioning_Util.Get_Reason_Info(l_reason_code, l_reason_comments);
                      IF l_reason_code IS NULL THEN
                       -- bug 3636884, defaulting reason from group API
                       IF OE_GLOBALS.G_DEFAULT_REASON THEN
                         oe_debug_pub.add('Defaulting Audit Reason for Order Header', 1);
                         p_x_header_rec.change_reason := 'SYSTEM';
                       ELSE
                         OE_DEBUG_PUB.add('Reason code for change is missing or invalid', 1);
                         fnd_message.set_name('ONT','OE_AUDIT_REASON_RQD');
                         fnd_message.set_token('OBJECT','ORDER');
                         oe_msg_pub.add;
                         RAISE FND_API.G_EXC_ERROR;
                       END IF;
                      END IF;
                   END IF;
                 ELSE
                   OE_DEBUG_PUB.add('Reason code for change is missing or invalid', 1);
                   fnd_message.set_name('ONT','OE_AUDIT_REASON_RQD');
                   fnd_message.set_token('OBJECT','ORDER');
                   oe_msg_pub.add;
                   RAISE FND_API.G_EXC_ERROR;
                 END IF;
           END IF;
        END IF;
     END IF;

/* START PREPAYMENT */
     IF  (p_x_header_rec.payment_term_id IS NOT NULL AND --Bug 4207730
        NOT OE_GLOBALS.Equal(p_x_header_rec.payment_term_id,p_old_header_rec.payment_term_id))
     THEN
        IF OE_PREPAYMENT_UTIL.Is_Prepaid_Order(p_x_header_rec) = 'Y' THEN
           FND_MESSAGE.SET_NAME('ONT', 'ONT_USE_HDR_TERMS_FOR_INVOICE');
           OE_MSG_PUB.Add;
        END IF;
     END IF;
/* END PREPAYMENT */
-- Included to fix bug 1589196 Begin

IF NOT OE_GLOBALS.Equal(p_x_header_rec.salesrep_id,p_old_header_rec.salesrep_id)
then
   IF p_x_header_rec.operation <> OE_GLOBALS.G_OPR_CREATE THEN
     OPEN C_HSC_COUNT(p_x_header_rec.header_id);
     FETCH C_HSC_COUNT INTO l_sales_crd_cnt, l_sales_crd_id;
     CLOSE C_HSC_COUNT;
     if l_sales_crd_cnt > 1 then
       fnd_message.set_name('ONT','OE_TOO_MANY_HSCREDIT');
       OE_MSG_PUB.Add;
       RAISE  FND_API.G_EXC_ERROR;
     end if;
  END IF;
END IF;
-- Included to fix bug 1589196   End

	Oe_Header_Util.get_order_number(p_x_header_rec => p_x_header_rec,
							 p_old_header_rec => p_old_header_rec);


		-- Call Cancellation Related Code


    IF (p_x_header_rec.cancelled_flag = 'Y')AND
       (p_x_header_rec.cancelled_flag <> NVL(p_old_header_rec.cancelled_flag,'N')) THEN -- Bug 9241924

      /* Fix Bug # 3241831: Set Global before Order Cancellation Starts */
      IF OE_GLOBALS.G_UI_FLAG = FALSE THEN
        oe_debug_pub.add('SET G_ORD_LVL_CAN TO TRUE FOR NON UI ORDER CANCEL');
        OE_OE_FORM_CANCEL_LINE.g_ord_lvl_can := TRUE;
      END IF;

/* 7576948: IR ISO Change Management project Start */
--
-- When the order header level cancellation is triggered, and all the
-- order lines are successfully cancelled, we should log a delayed request
-- G_UPDATE_REQUISITION to call the Purchasing API so as to trigger the
-- requisition header cancellation. For this, we need to log the delayed
-- requests from Pre_Write_Process procedure of OE_Header_Util package.
-- In this procedure, we need to raise this delayed request only after
-- successful execution of OE_Sales_Can_Util.Perform_Cancel_Order API,
-- which is responsible for canceling both order header and all order
-- lines. This code will be triggered in the event of Full Order
-- Cancellation only.
--
-- If it is a partial order cancellation, i.e. cancellation of internal
-- sales order lines, which are eligible for cancellation and there exists
-- atleast one line in non-cancellation status, then purchasing product
-- will be called only with the cancelled internal sales order lines
-- information, such that corresponding requisition lines can be cancelled/
-- updated.  However, in such a case, it may happen that due to system split,
-- fulfillment organization user may cancel a specific line shipment, which
-- may request for requisition line cancellation, but requesting org may
-- have not yet received the partial shipment done so far. In that event,
-- requestion line should be cancelled only after validating that there
-- exists no open quantity for receiving. If there exists open quantity
-- for receiving for requesting org, then inspite of fulfillment org requested
-- for requestion line cancellation, it should be suppressed by the
-- requesting org for update operation.
--
-- Additionally, while logging the delated request, system will ensure that
-- global OE_Internal_Requisition_Pvt.G_Update_ISO_From_Req should be set to
-- FALSE. If this global is TRUE then it signifies that the full header
-- cancellation is triggered from Requesting Organization user.
--
-- Please refer to following delayed request params with their meaning
-- useful while logging the delayed request -
--
-- P_entity_code        Entity for which delayed request has to be logged.
--                      In this project it can be OE_Globals.G_Entity_Line
--                      or OE_Globals.G_Entity_Header
-- P_entity_id          Primary key of the entity record. In this project,
--                      it can be Order Line_id or Header_id
-- P_requesting_entity_code Which entity has requested this delayed request to
--                          be logged! In this project it will be OE_Globals.
--                          G_Entity_Line or OE_Globals.G_Entity_Header
-- P_requesting_entity_id       Primary key of the requesting entity. In this
--                              project, it is Line_id or Header_id
-- P_request_type       Indicates which business logic (or which procedure)
--                      should be executed. In this project, it is OE_Global
--                      s.G_UPDATE_REQUISITION
-- P_request_unique_key1        Additional argument in form of parameters.
--                              In this project, it will denote the Sales Order
--                              Header id
-- P_request_unique_key2        Additional argument in form of parameters.
--                              In this project, it will denote the Requisition
--                              Header id
-- P_request_unique_key3        Additional argument in form of parameters. In
--                              this project, it will denote the Requistion Line
--                              id
-- P_param1     Additional argument in form of parameters. In this project, it
--              will denote net change in order quantity with respective single
--              requisition line. If it is greater than 0 then it is an increment
--              in the quantity, while if it is less than 0 then it is a decrement
--              in the ordered quantity. If it is 0 then it indicates there is no
--              change in ordered quantity value
-- P_param2     Additional argument in form of parameters. In this project, it
--              will denote whether internal sales order is cancelled or not. If
--              it is cancelled then respective Purchasing api will be called to
--              trigger the requisition header cancellation. It accepts a value of
--              Y indicating requisition header has to be cancelled.
-- P_param3     Additional argument in form of parameters. In this project, it
--              will denote the number of sales order lines cancelled while order
--              header is (Full/Partial) cancelled.
-- p_date_param1        Additional date argument in form of parameters. In this
--                      project, it will denote the change in Schedule Ship Date
--                      with to respect to single requisition line.
-- P_Long_param1        Additional argument in form of parameters. In this project,
--                      it will store all the sales order line_ids, which are getting
--                      cancelled while order header gets cancelled (Full/Partial).
--                      These Line_ids will be separated by a delimiter comma ','
--
-- For details on IR ISO CMS project, please refer to FOL >
-- OM Development > OM GM > 12.1.1 > TDD > IR_ISO_CMS_TDD.doc
--

      IF (p_x_header_rec.order_source_id = 10) THEN
        OE_SALES_CAN_UTIL.G_IR_ISO_HDR_CANCEL := TRUE;
        IF l_debug_level > 0 THEN
          oe_debug_pub.add(' Setting global Header Cancel for IR ISO to TRUE',5);
        END IF;
      END IF;
      -- Setting this global to TRUE confirming it to be
      -- Order header level full cancellation

        OE_SALES_CAN_UTIL.Perform_cancel_order(p_x_header_rec,
                                               p_old_header_rec,
                                               l_return_status);

      IF (p_x_header_rec.order_source_id = 10) THEN
        OE_SALES_CAN_UTIL.G_IR_ISO_HDR_CANCEL := FALSE;
        IF l_debug_level > 0 THEN
          oe_debug_pub.add(' Setting global Header Cancel for IR ISO to FALSE',5);
        END IF;
      END IF;
      -- Resetting the global to FALSE

    	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        		RAISE FND_API.G_EXC_ERROR;
     		ELSE
     			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     		END IF;


  ELSE -- If return status is SUCCESS
    IF (p_x_header_rec.order_source_id = 10) THEN
      IF NOT OE_Internal_Requisition_Pvt.G_Update_ISO_From_Req THEN
        IF l_debug_level > 0 THEN
          oe_debug_pub.add(' Header level cancellation. Log the IR ISO update delayed request',5);
        END IF;

        OE_delayed_requests_Pvt.log_request
        ( p_entity_code            => OE_GLOBALS.G_ENTITY_HEADER
        , p_entity_id              => p_x_header_rec.header_id
        , p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER
        , p_requesting_entity_id   => p_x_header_rec.header_id
        , p_request_unique_key2    => p_x_header_rec.source_document_id -- Req Hdr_id
        , p_param2                 => 'Y'
        , p_request_type           => OE_GLOBALS.G_UPDATE_REQUISITION
        , x_return_status          => l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END IF; -- Order_Source_id


/* ============================= */
/* IR ISO Change Management Ends */


   		END IF;
   END IF;

	-- If ship from org has been changed validate the freight carrier. If
	-- freight carrier is not a valid one for the ship from org clear the
	-- freight carrier field.

	IF (p_x_header_rec.order_category_code <> 'RETURN') THEN

    IF (NOT OE_GLOBALS.Equal(p_x_header_rec.ship_from_org_id,
              p_old_header_rec.ship_from_org_id) OR
     NOT OE_GLOBALS.Equal(p_x_header_rec.shipping_method_code,
         p_old_header_rec.shipping_method_code))  THEN

	    IF p_x_header_rec.shipping_method_code IS NOT NULL AND
           p_x_header_rec.ship_from_org_id IS NOT NULL THEN

              IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110509' THEN
                 SELECT count(*)
                 INTO   l_count
                 FROM   wsh_carrier_services wsh,
                        wsh_org_carrier_services wsh_org
                 WHERE  wsh_org.organization_id      = p_x_header_rec.ship_from_org_id
                   AND  wsh.carrier_service_id       = wsh_org.carrier_service_id
                   AND  wsh.ship_method_code         = p_x_header_rec.shipping_method_code
                   AND  wsh_org.enabled_flag         = 'Y';
              ELSE
          	SELECT  count(CARRIER_SHIP_METHOD_ID)
          	INTO    l_count
     		FROM    wsh_carrier_ship_methods
       		WHERE   ship_method_code = p_x_header_rec.shipping_method_code
                  AND   organization_id = p_x_header_rec.ship_from_org_id
                  AND   enabled_flag = 'Y'; -- added for bug 3886064
              END IF;

	   	--  Valid shipping method.

               IF l_debug_level > 0 THEN
                  oe_debug_pub.add('l_count : ' || l_count);
                  oe_debug_pub.add('shipping_method_code : ' || p_x_header_rec.shipping_method_code);
               END IF;

	   		IF	l_count  = 0 THEN

                          --bug 4190357
                          select count(*) into v_count from oe_price_adjustments
                          where header_id = p_x_header_rec.header_id
                          and line_id is null
                          and substitution_attribute = 'QUALIFIER_ATTRIBUTE11'
                          and list_line_type_code = 'TSN'
                          and modified_to = p_x_header_rec.shipping_method_code;
                          IF v_count > 0 THEN
                             IF l_debug_level > 0 THEN
                                oe_debug_pub.add('Deleting the header tsn adjustments');
                             END IF;
                             DELETE FROM OE_PRICE_ADJUSTMENTS
                             WHERE HEADER_ID = p_x_header_rec.header_id
                             AND LIST_LINE_TYPE_CODE = 'TSN'
                             AND SUBSTITUTION_ATTRIBUTE = 'QUALIFIER_ATTRIBUTE11'
                             AND MODIFIED_TO = p_x_header_rec.shipping_method_code
                             RETURNING MODIFIED_FROM INTO l_modified_from;
                          END IF;
                          select meaning into l_meaning from oe_ship_methods_v where lookup_type = 'SHIP_METHOD' and lookup_code = p_x_header_rec.shipping_method_code;
                          --bug 4190357

       			l_control_rec.write_to_DB          := FALSE;
       			l_control_rec.controlled_operation  := TRUE;
       			l_control_rec.process  := FALSE;
                         --bug 3941272
	 		p_x_old_header_rec := p_x_header_rec ;
                        IF v_count = 0 THEN
        	        --end bug 3941272
				p_x_header_rec.freight_carrier_code := NULL;
				p_x_header_rec.shipping_method_code := NULL;
                        ELSE
                           p_x_header_rec.shipping_method_code := l_modified_from;
                        END IF;

		Oe_Order_Pvt.Header
			(   p_validation_level    => FND_API.G_VALID_LEVEL_NONE
			,   p_control_rec         => l_control_rec
			,   p_x_header_rec    => p_x_header_rec
			,   p_x_old_header_rec =>  p_x_old_header_rec
                        ,   x_return_status     => l_return_status );

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
                END IF;


       	OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SHIPPING_METHOD');
		    	fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                          --bug 4190357 added l_meaning to the token
				FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('shipping_method_code') || ' ' || l_meaning);
				OE_MSG_PUB.Add;
				OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

		oe_debug_pub.add('Value of shipping Method:'
          ||p_x_header_rec.shipping_method_code,2);

          --bug 4190357
          for i in line_ids(p_x_header_rec.header_id) loop
            v_count := 0;
            select count(*) into v_count from oe_price_Adjustments
            where header_id = p_x_header_rec.header_id
              and line_id = i.line_id
              and substitution_attribute = 'QUALIFIER_ATTRIBUTE11'
              and list_line_type_code = 'TSN';
            If v_count = 0 Then
               j := j + 1;
               Oe_Line_Util.Query_Row(i.line_id, lx_line_rec);
               l_old_line_tbl(j) := lx_line_rec;
               l_line_tbl(j) := lx_line_rec;
               IF l_modified_from is NULL Then
                  l_line_tbl(j).freight_carrier_code := NULL;
                  l_line_tbl(j).shipping_method_code := NULL;
               ELSE
                  l_line_tbl(j).shipping_method_code := l_modified_from;
               END IF;
               l_line_tbl(j).operation := OE_GLOBALS.G_OPR_UPDATE;
            End If;
          end loop;
          IF l_line_tbl.count > 0 THEN
             OE_GLOBALS.G_PRICING_RECURSION := 'Y';
             l_control_rec.controlled_operation := TRUE;
             l_control_rec.check_security            := TRUE;
             l_control_rec.clear_dependents  := FALSE;
             l_control_rec.default_attributes        := FALSE;
             l_control_rec.change_attributes := TRUE;
             l_control_rec.validate_entity           := FALSE;
             l_control_rec.write_to_DB          := TRUE;
             l_control_rec.process := FALSE;

             Oe_Order_Pvt.Lines
             ( p_validation_level              => FND_API.G_VALID_LEVEL_NONE
              ,p_control_rec                   => l_control_rec
              ,p_x_line_tbl                    => l_line_tbl
              ,p_x_old_line_tbl                => l_old_line_tbl
              ,x_return_status                 => l_return_status
             );

             IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
             OE_GLOBALS.G_PRICING_RECURSION := 'N';
          END IF;
          --bug 4190357

			END IF;

		END IF;
     END IF;

     END IF;

	-- Log delayed request to create automatic attachments
/*6896311
        IF (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE OR
            p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE) AND   --5893276
6896311*/
         IF (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE )  AND --6896311
            l_apply_automatic_atchmt  = 'Y' THEN
		oe_debug_pub.add('log request to apply atcmt');
        OE_DELAYED_REQUESTS_PVT.Log_Request
	(p_entity_code 	 => OE_GLOBALS.G_ENTITY_HEADER,
	 p_entity_id         => p_x_header_rec.header_id,
	 p_request_type      => OE_GLOBALS.G_APPLY_AUTOMATIC_ATCHMT,
	 p_requesting_entity_code 	=> OE_GLOBALS.G_ENTITY_HEADER,
	 p_requesting_entity_id		=> p_x_header_rec.header_id,
	 x_return_status			=> l_return_status
	 );
	END IF;

--6896311
        IF (p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE )  AND
            l_apply_automatic_atchmt  = 'Y'
THEN
        oe_debug_pub.add('log request to update atcmt');

--7688372 start
            Load_attachment_rules;
--7688372 end

            IF (NOT OE_GLOBALS.Equal(p_x_header_rec.CUST_PO_NUMBER
                                    ,p_old_header_rec.CUST_PO_NUMBER) AND g_attachment_rule_count_tab.exists('CUST_PO_NUMBER'))  --7688372
            OR (NOT OE_GLOBALS.Equal(p_x_header_rec.INVOICE_TO_ORG_ID
                                    ,p_old_header_rec.INVOICE_TO_ORG_ID)  AND g_attachment_rule_count_tab.exists('INVOICE_TO_ORG_ID'))  --7688372
            OR (NOT OE_GLOBALS.Equal(p_x_header_rec.ORDER_TYPE_ID
                                    ,p_old_header_rec.ORDER_TYPE_ID) AND g_attachment_rule_count_tab.exists('ORDER_TYPE_ID'))  --7688372
            OR (NOT OE_GLOBALS.Equal(p_x_header_rec.SHIP_TO_ORG_ID
                                    ,p_old_header_rec.SHIP_TO_ORG_ID)  AND g_attachment_rule_count_tab.exists('SHIP_TO_ORG_ID'))  --7688372
            OR (NOT OE_GLOBALS.Equal(p_x_header_rec.SOLD_TO_ORG_ID
                                    ,p_old_header_rec.SOLD_TO_ORG_ID)   AND g_attachment_rule_count_tab.exists('SOLD_TO_ORG_ID'))  --7688372
            OR (NOT OE_GLOBALS.Equal(p_x_header_rec.ORDER_CATEGORY_CODE
                                    ,p_old_header_rec.ORDER_CATEGORY_CODE)  AND g_attachment_rule_count_tab.exists('ORDER_CATEGORY_CODE'))  --7688372
            THEN

                l_attr_attach_change := TRUE;

            END IF;

          IF l_attr_attach_change THEN
           OE_delayed_requests_Pvt.Log_Request
                 (p_entity_code   => OE_GLOBALS.G_ENTITY_HEADER,
                 p_entity_id         => p_x_header_rec.header_id,
                 p_request_type      => OE_GLOBALS.G_APPLY_AUTOMATIC_ATCHMT,
                 p_requesting_entity_code       => OE_GLOBALS.G_ENTITY_HEADER,
                 p_requesting_entity_id         => p_x_header_rec.header_id,
                 x_return_status                        => l_return_status
                 );
          END IF;
        END IF;
--6896311


        -- QUOTING changes
	IF nvl(p_x_header_rec.transaction_phase_code,'F') = 'F'
           AND NOT OE_GLOBALS.Equal(p_x_header_rec.order_type_id
				    ,p_old_header_rec.order_type_id)
	THEN

       -- If the Order Type has changed, we need to sync up the
       -- MTL_SALES_ORDERS table.
		IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

		   l_source_code := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
                   -- 3817802 : New api Get_Base_Order_Type is used to get order type based on base lang
		   l_new_order_type := Get_Base_Order_Type(p_x_header_rec.order_type_id);
		   l_order_type     := Get_Base_Order_Type(p_old_header_rec.order_type_id);
                   IF l_debug_level  > 0 THEN
                      oe_debug_pub.add('l_source_code ' || l_source_code,2);
                      oe_debug_pub.add('l_new_order_type ' || l_new_order_type,2);
                      oe_debug_pub.add('l_order_type ' || l_order_type,2);
                   END IF;
			l_return_value :=
						inv_salesorder.synch_salesorders_with_om(
						p_original_order_number  =>
						to_char(p_old_header_rec.order_number),
						p_original_order_type    => l_order_type,
						p_original_source_code   => l_source_code,
						p_new_order_number       =>
						to_char(p_x_header_rec.order_number),
						p_new_order_type         => l_new_order_type,
						p_new_order_source       => l_source_code,
						p_multiple_rows          => 'N');
		     oe_debug_pub.add(' Return Value ' || l_return_value,1);
	    END IF;

	 END IF;
	--included for the create internal  requisition Spares Management (Ikon) project mshenoy
        -- For all Internal Sales Orders (Source Document Type ID = 10 ) and Create ISO Operations
        -- log a Delayed Request for the create Internal Requisition
        IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
           p_x_header_rec.Source_Document_Type_id = 10   AND
           p_x_header_rec.Source_Document_id is null AND
           p_x_header_rec.Orig_sys_document_ref is null THEN
		oe_debug_pub.add('log request to create internal Req for ISO');
            OE_delayed_requests_Pvt.Log_Request
		        (p_entity_code 	 => OE_GLOBALS.G_ENTITY_ALL,
                 p_entity_id         => p_x_header_rec.header_id,
                 p_request_type      => OE_GLOBALS.G_CREATE_INTERNAL_REQ,
              	 p_requesting_entity_code 	=> OE_GLOBALS.G_ENTITY_HEADER,
               	 p_requesting_entity_id		=> p_x_header_rec.header_id,
		         x_return_status			=> l_return_status );
		oe_debug_pub.add(' Return Status log_request Delayed Requests for Int req ' || l_return_status);

        END IF;

     -- Fix for bug1167537
     -- Clear the header record cached by defaulting APIs so that the
     -- default values on the line record are obtained from the
     -- updated header record
     IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
           ONT_HEADER_Def_Util.Clear_HEADER_Cache;
     END IF;

     -- R12 CC encryption
     IF	p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
	AND	(p_x_header_rec.payment_type_code = 'CREDIT_CARD'
                OR p_old_header_rec.payment_type_code = 'CREDIT_CARD') THEN

        IF (NOT OE_GLOBALS.Is_Same_Credit_Card(p_old_header_rec.credit_card_number,
	    p_x_header_rec.credit_card_number,
	    p_old_header_rec.cc_instrument_id,
	    p_x_header_rec.cc_instrument_id))
            OR
            (p_x_header_rec.payment_type_code IS NULL AND NOT OE_GLOBALS.Is_Same_Credit_Card(p_old_header_rec.credit_card_number,p_x_header_rec.credit_card_number,p_old_header_rec.cc_instrument_id, NULL))
    	THEN

          l_changed_attribute := l_changed_attribute||',' ||'CREDIT_CARD_NUMBER';

                /**
                IF l_changed_attribute = 'CREDIT_CARD_CODE' THEN
                   l_changed_attribute := l_changed_attribute||',' ||'CREDIT_CARD_NUMBER';
                ELSE
                   l_changed_attribute := 'CREDIT_CARD_NUMBER';
                END IF;
                **/

	END IF;

	IF 	NOT OE_GLOBALS.Equal(p_x_header_rec.credit_card_code,p_old_header_rec.credit_card_code)
	THEN

          l_changed_attribute := l_changed_attribute||',' ||'CREDIT_CARD_CODE';

                /**
               	IF l_changed_attribute = 'CREDIT_CARD_NUMBER' THEN
                   l_changed_attribute := l_changed_attribute||',' ||'CREDIT_CARD_CODE';
                ELSE
                   l_changed_attribute := 'CREDIT_CARD_CODE';
                END IF;
                 **/

	END IF;

	IF 	NOT OE_GLOBALS.Equal(p_x_header_rec.credit_card_holder_name,p_old_header_rec.credit_card_holder_name)
	THEN
          l_changed_attribute := l_changed_attribute||',' ||'CREDIT_CARD_HOLDER_NAME';

	END IF;

	IF 	NOT OE_GLOBALS.Equal(p_x_header_rec.credit_card_expiration_date,p_old_header_rec.credit_card_expiration_date)
	THEN
          l_changed_attribute := l_changed_attribute||',' ||'CREDIT_CARD_EXPIRATION_DATE';

	END IF;
		oe_debug_pub.add('changed attr is: '||l_changed_attribute, 3);
      END IF;

     -- Bug 1755817: clear the cached constraint results for header entity
     -- when order header is updated.
     OE_PC_Constraints_Admin_Pvt.Clear_Cached_Results
          (p_validation_entity_id => OE_PC_GLOBALS.G_ENTITY_HEADER);

       --11.5.10 Versioning/Audit Trail updates
     IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' AND
         OE_GLOBALS.G_ROLL_VERSION <> 'N' THEN
       IF OE_GLOBALS.G_REASON_CODE IS NULL AND
           OE_GLOBALS.G_CAPTURED_REASON IN ('V','A') THEN
          IF p_x_header_rec.change_reason <> FND_API.G_MISS_CHAR THEN
              OE_GLOBALS.G_REASON_CODE := p_x_header_rec.change_reason;
              OE_GLOBALS.G_REASON_COMMENTS := p_x_header_rec.change_comments;
              OE_GLOBALS.G_CAPTURED_REASON := 'Y';
          ELSE
              OE_DEBUG_PUB.add('Reason code for versioning is missing', 1);
              if OE_GLOBALS.G_UI_FLAG THEN
                 raise FND_API.G_EXC_ERROR;
              end if;
          END IF;
       END IF;

       --log delayed request
        oe_debug_pub.add('log versioning request',1);
          OE_Delayed_Requests_Pvt.Log_Request(p_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                                   p_entity_id => p_x_header_rec.header_id,
                                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER,
                                   p_requesting_entity_id => p_x_header_rec.header_id,
                                   p_request_type => OE_GLOBALS.G_VERSION_AUDIT,
                                   p_param1	  => l_changed_attribute,
                                   x_return_status => l_return_status);
     END IF;

     IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG = 'Y' OR
	   OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG = 'Y' THEN
          OE_DEBUG_PUB.add('Call oe_order_chg_pvt to record Header Audit History',5);

       --11.5.10 Versioning/Audit Trail updates
       IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
          OE_Versioning_Util.Capture_Audit_Info(p_entity_code => OE_GLOBALS.G_ENTITY_HEADER,
                                           p_entity_id => p_x_header_rec.header_id,
                                           p_hist_type_code =>  'UPDATE');
           --log delayed request
             OE_Delayed_Requests_Pvt.Log_Request(p_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                                   p_entity_id => p_x_header_rec.header_id,
                                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER,
                                   p_requesting_entity_id => p_x_header_rec.header_id,
                                   p_request_type => OE_GLOBALS.G_VERSION_AUDIT,
                                   p_param1	  => l_changed_attribute,
                                   x_return_status => l_return_status);
          OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
       ELSE
          OE_CHG_ORDER_PVT.RecordHeaderHist
              ( p_header_id => p_x_header_rec.header_id,
                p_header_rec => null,
                p_hist_type_code => 'UPDATE',
                p_reason_code => p_x_header_rec.change_reason,
                p_comments => p_x_header_rec.change_comments,
                p_wf_activity_code => null,
                p_wf_result_code => null,
                x_return_status => l_return_status
              );

          if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	        oe_debug_pub.add('Inserting Header History Caused Error ',1);
             if l_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
             else
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
             end if;
          end if;
       END IF;
     END IF;

     -- QUOTING changes
     -- Initialize flow status to DRAFT or ENTERED dependening on transaction phase
     IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

        IF nvl(p_x_header_rec.transaction_phase_code,'F') = 'F' THEN
           /*
           ** Fix Bug # 3484862: iStore will be sending flow status as WORKING
           ** for RMAs created with Return for Submission with Approval Flow.
           */
           IF p_x_header_rec.flow_status_code = 'WORKING' THEN
             null;
           ELSE
             p_x_header_rec.flow_status_code := 'ENTERED';
           END IF;
        ELSIF p_x_header_rec.transaction_phase_code = 'N' THEN
           p_x_header_rec.flow_status_code := 'DRAFT';
        END IF;

     END IF; -- if operation CREATE

     --For bug 3563983. Logging REquest for updaet of Blanekt fields.
     --Moved this logic from post-write process.
     --Log request for deletes AND for update of currency

      IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509'
      AND NVL(p_x_header_rec.transaction_phase_code,'F') = 'F'
      AND (p_x_header_rec.operation = OE_GLOBALS.G_OPR_DELETE OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
           AND NOT OE_GLOBALS.EQUAL(p_x_header_rec.transactional_curr_code
                                 ,p_old_header_rec.transactional_curr_code)))
      THEN
          Blkt_Req_For_Curr_Upd_And_Del(p_x_header_rec,p_old_header_rec);
      END IF;


      oe_debug_pub.add('Exiting OR_HEADER_UTIL.Pre_Write_Process',1);

EXCEPTION
-- included to fix bug 1589196    Begin
    WHEN FND_API.G_EXC_ERROR THEN

     OE_SALES_CAN_UTIL.G_IR_ISO_HDR_CANCEL := FALSE;
     -- Adding this for IR ISO Tracking bug 7667702

     RAISE FND_API.G_EXC_ERROR;
-- included to fix bug 1589196    End

    WHEN OTHERS THEN

        OE_SALES_CAN_UTIL.G_IR_ISO_HDR_CANCEL := FALSE;
        -- Adding this for IR ISO Tracking bug 7667702

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pre_Write_Process'
            );
        END IF;
		p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


End Pre_Write_Process;

PROCEDURE Post_Write_Process
         ( p_x_header_rec 	IN OUT NOCOPY  oe_order_pub.header_rec_type,
           p_old_header_rec    IN oe_order_pub.header_rec_type )
IS
	l_return_status                VARCHAR2(30);
        l_msg_count        NUMBER;
        l_msg_data         VARCHAR2(2000);

	l_control_rec                  OE_GLOBALS.Control_Rec_Type;
	l_old_line_tbl                 OE_Order_PUB.Line_Tbl_Type;
	l_line_tbl                     OE_Order_PUB.Line_Tbl_Type;
        l_recursion_mode               VARCHAR2(1);
        l_operation                    VARCHAR2(30);
	--R12 CC Encryption
	l_x_Header_Payment_tbl		OE_ORDER_PUB.Header_Payment_tbl_type;
	l_x_old_Header_Payment_tbl	OE_ORDER_PUB.Header_Payment_tbl_type;
	l_payment_exists		VARCHAR2(1) := 'N';
	l_payment_number                NUMBER;
	l_old_payment_type_code		VARCHAR2(30) := NULL;
	--R12 CC Encryption
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--bug 5258767
	l_payment_term_id	        NUMBER;
	l_prepayment_flag		VARCHAR2(1) := NULL;
	l_prepay_count			NUMBER := 0;
	l_currency_code			VARCHAR2(30) := NULL;
	l_subtotal number;
	l_discount number;
	l_charges number;
	l_tax number;
	L_ORDER_TOTAL number;
	L_DOWNPAYMENT number;
	l_line_payment_count NUMBER;
	--bug 5258767
BEGIN
	oe_debug_pub.add('Entering OE_HEADER_UTIL.Post_Write_Process',1);

     -- Added call to new procedure eval_post_write_header for performance
     -- and to be consistent with evalualte_post_write for lines.
     -- See bug#1777317
     -- QUOTING changes - moved this call within another create loop
     -- later as holds should be applied only to orders in fulfillment phase.

     --Fix bug 1649402
     OE_DELAYED_REQUESTS_PVT.Process_Request_for_ReqType
                               (p_request_type => OE_GLOBALS.G_DFLT_HSCREDIT_FOR_SREP
                               ,p_delete       => FND_API.G_TRUE
                               ,x_return_status=> l_return_status
                               );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- QUOTING changes - moved this call within another create loop
     -- later as mtl_sales_order records should be created only for
     -- orders in fulfillment phase.

     -- QUOTING changes
     IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        OR (OE_Quote_Util.G_COMPLETE_NEG = 'Y'
	    AND NOT OE_GLOBALS.EQUAL(p_x_header_rec.transaction_phase_code,
				 p_old_header_rec.transaction_phase_code)
            )
     THEN

       -- Fulfillment phase specific actions - holds,
       -- MTL entry and fulfillment WF start
       IF nvl(p_x_header_rec.transaction_phase_code,'F') = 'F' THEN

        -- Added call to new procedure eval_post_write_header for performance
        -- and to be consistent with evalualte_post_write for lines.
        -- See bug#1777317

/*ER#7479609
        oe_debug_pub.add('Before calling eval_post_write_header in HEADER Post Write',1);

        OE_HOLDS_PUB.eval_post_write_header
                       ( p_entity_code      => OE_GLOBALS.G_ENTITY_HEADER
                        ,p_entity_id        => p_x_header_rec.header_id
                        ,p_hold_entity_code => 'C'
                        ,p_hold_entity_id   => p_x_header_rec.sold_to_org_id
                        ,x_return_status    => l_return_status
                        ,x_msg_count        => l_msg_count
                        ,x_msg_data         => l_msg_data );



        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        oe_debug_pub.add('After calling eval_post_write_header in HEADER Post Write',1);
ER#7479609*/

--ER#7479609 start
    if l_debug_level > 0 then
     oe_debug_pub.add('Call evaluate_holds_post_write for CREATE');
    end if;
     OE_Holds_PUB.evaluate_holds_post_write
      (p_entity_code => OE_GLOBALS.G_ENTITY_HEADER
      ,p_entity_id => p_x_header_rec.header_id
      ,x_msg_count => l_msg_count
      ,x_msg_data => l_msg_data
      ,x_return_status => l_return_status
      );

         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

    if l_debug_level > 0 then
      oe_debug_pub.add('After evaluate_holds_post_write in Header Post Write');
    end if;
--ER#7479609 end

         --  Create record in the MTL_SALES_ORDERS table

           oe_debug_pub.add('Before calling OE_SCHEDULE_UTIL',3);
           OE_SCHEDULE_UTIL.Insert_into_mtl_sales_orders(p_x_header_rec);

         -- Create and Start the Header level Workflow

          OE_Order_WF_Util.CreateStart_HdrProcess(p_x_header_rec);

       -- Negotiation phase specific actions - negotiation WF start
       ELSE

          -- Sam to provide this API
          OE_Order_WF_Util.CreateStart_HdrInternal
                  (p_item_type => 'OENH'
                  ,p_header_id => p_x_header_rec.header_id
                  ,p_transaction_number => p_x_header_rec.quote_number
                  ,p_sales_document_type_code => 'O'
                  );
          NULL;

       END IF;

       -- Check if the lock_control has changed, it would if there
       -- were updates due to synchronous activities like booking in
       -- the header flow. If yes, refresh the header record

       OE_Order_Cache.Load_Order_Header(p_x_header_rec.header_id);
       oe_debug_pub.add('DB lock control :'||
                         OE_Order_Cache.g_header_rec.lock_control);

       IF OE_Order_Cache.g_header_rec.lock_control
         <> p_x_header_rec.lock_control
       THEN
          l_operation := p_x_header_rec.operation;
          p_x_header_rec := OE_Order_Cache.g_header_rec;
          p_x_header_rec.operation := l_operation;
          OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
       END IF;

     END IF; -- END for check if CREATE operation
     -- QUOTING changes END

     -- Close the order if its a complet cancellation at the line and
     -- is indeed a cancellation (by constraints)
      IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
          IF oe_sales_can_util.g_order_cancel AND
              p_x_header_rec.cancelled_flag = 'Y' AND -- (p_old_header_rec.cancelled_flag <> 'Y') --7142748
	      p_x_header_rec.cancelled_flag <> NVL(p_old_header_rec.cancelled_flag,'N') THEN -- Bug 9241924
          -- Bug 1895144: set recursion mode so that close does
          -- not execute any delayed requests
          BEGIN
          l_recursion_mode := OE_GLOBALS.G_RECURSION_MODE;
          -- OE_GLOBALS.G_RECURSION_MODE := 'Y';

-- Log a request to cancel the workflow.
/*
-- commented to take care of P1 issues in configuration

	OE_delayed_requests_Pvt.log_request
	(p_entity_code				=> OE_GLOBALS.G_ENTITY_ALL,
	p_entity_id				=> p_x_header_rec.header_id,
	p_requesting_entity_code	=> OE_GLOBALS.G_ENTITY_ALL,
	p_requesting_entity_id		=> p_x_header_rec.header_id,
	p_request_type      		=> OE_GLOBALS.G_CANCEL_WF,
	p_param1                 => OE_GLOBALS.G_ENTITY_HEADER,
	x_return_status				=> l_return_status);
*/

-- Commented the code to move the logic to delayed request
-- Uncommented to take care of P1 configuration issues
          wf_engine.handleerror(OE_Globals.G_WFI_HDR
                    ,to_char(p_x_header_rec.header_id)
                    ,'CLOSE_HEADER',
                    'RETRY','CANCEL');

          -- OE_GLOBALS.G_RECURSION_MODE := l_recursion_mode;
          -- BUG 2013611 - Increment promotional balance in response to cancellation
          oe_debug_pub.add('log request to Reverse_Limits for CANCEL in HEADER Post Write',1);
          OE_delayed_requests_Pvt.log_request(
			p_entity_code 		 => OE_GLOBALS.G_ENTITY_HEADER,
			p_entity_id              => p_x_header_rec.header_id,
			p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER,
			p_requesting_entity_id   => p_x_header_rec.header_id,
			p_request_unique_key1  	 => 'HEADER',
		 	p_param1                 => 'CANCEL',
	 		p_param2                 => p_x_header_rec.price_request_code,
		 	p_param3                 => NULL,
		 	p_param4                 => NULL,
		 	p_param5                 => NULL,
		 	p_param6                 => NULL,
	 		p_request_type           => OE_GLOBALS.G_REVERSE_LIMITS,
	 		x_return_status          => l_return_status);
          oe_debug_pub.add('Request to Reverse_Limits in HEADER Post Write is done',1);
          -- BUG 2013611 End
          EXCEPTION
            WHEN OTHERS THEN
                 -- OE_GLOBALS.G_RECURSION_MODE := l_recursion_mode;
                 RAISE;
          END;
          END IF;
      END IF;
          oe_sales_can_util.g_order_cancel := FALSE;


     ----------------------------------------------------------------
	-- Update the customer on the order lines if changed on the
	-- order header
     ----------------------------------------------------------------
     IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
	   AND NOT OE_GLOBALS.EQUAL( p_x_header_rec.sold_to_org_id,
						    p_old_header_rec.sold_to_org_id )
     THEN

       OE_Line_Util.Query_Rows
		( p_header_id => p_x_header_rec.header_id
	     , x_line_tbl  => l_old_line_tbl );

       IF l_old_line_tbl.COUNT = 0 THEN
		RETURN;
       END IF;

       l_line_tbl := l_old_line_tbl;
       FOR I IN 1..l_line_tbl.COUNT LOOP
        -- IF condition added for bug 5471580
          IF nvl(l_line_tbl(I).cancelled_flag, 'N') = 'N' THEN
		l_line_tbl(I).sold_to_org_id   := p_x_header_rec.sold_to_org_id;
		l_line_tbl(I).operation        := OE_GLOBALS.G_OPR_UPDATE;
	  ELSE
                l_line_tbl(I).operation        := OE_GLOBALS.G_OPR_NONE;
          END IF;
       END LOOP;

       l_control_rec.controlled_operation := TRUE;
	  l_control_rec.clear_dependents := TRUE;
	  l_control_rec.default_attributes := TRUE;
	  l_control_rec.check_security := TRUE;
	  l_control_rec.change_attributes := TRUE;
	  l_control_rec.validate_entity := TRUE;
	  l_control_rec.write_to_db := TRUE;
	  l_control_rec.process := FALSE;

       -- OE_GLOBALS.G_RECURSION_MODE := 'Y';

	  OE_Order_PVT.Lines
	     ( p_validation_level      => FND_API.G_VALID_LEVEL_NONE
	     , p_control_rec           => l_control_rec
          , p_x_line_tbl            => l_line_tbl
		, p_x_old_line_tbl        => l_old_line_tbl
		, x_return_status         => l_return_status
		);

       -- OE_GLOBALS.G_RECURSION_MODE := 'N';

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

  -- commented out for notification framework
     /*  OE_Order_PVT.Process_Requests_And_Notify
		( p_process_requests       => FALSE
		, p_notify                 => TRUE
		, p_line_tbl               => l_line_tbl
		, p_old_line_tbl           => l_old_line_tbl
		, x_return_status          => l_return_status
		);

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     */
       OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;

     END IF;

     --For bug 3563983. Commented this code and moved this logic to pre-write process.
     --Line data will not be available for delete operation and this stage.
/*     IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509'
        AND p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
        AND NOT OE_GLOBALS.EQUAL(p_x_header_rec.transactional_curr_code
                                 ,p_old_header_rec.transactional_curr_code)
        -- QUOTING changes
        AND NVL(p_x_header_rec.transaction_phase_code,'F') = 'F'
     THEN

        Blanket_Req_For_Curr_Update(p_x_header_rec,p_old_header_rec);

     END IF;*/

     -- QUOTING changes
     IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
        AND p_x_header_rec.transaction_phase_code = 'N'
        AND NOT OE_GLOBALS.EQUAL(p_x_header_rec.expiration_date
                                 ,p_old_header_rec.expiration_date)
     THEN

         -- Call WF API to re-set expiration date timer
         OE_Negotiate_WF.Offer_Date_Changed
                 (p_header_id => p_x_header_rec.header_id
                 ,x_return_status => l_return_status
                 );

         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

     END IF;

    -- Sales Contract changes.
    -- Instantiate the contract template for the sales order for create
    -- operation.

     IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
        OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' AND
        -- Do not instantiate for copied orders
        nvl(p_x_header_rec.source_document_type_id,-1) <> 2 AND
        (p_x_header_rec.contract_template_id IS NOT NULL OR
	p_x_header_rec.contract_source_doc_type_code IS NOT NULL OR
	p_x_header_rec.contract_source_document_id IS NOT NULL)
        THEN

	IF  p_x_header_rec.contract_source_doc_type_code IS NOT NULL AND
	    p_x_header_rec.Contract_Template_Id IS NULL AND
	    p_x_header_rec.contract_source_document_id IS NULL THEN
            fnd_message.set_name('ONT','OE_INVALID_CONTRACT_ATTR_COMB');
            OE_MSG_PUB.Add;
	END IF;

	OE_CONTRACTS_UTIL.Copy_Doc(
       		p_api_version  		=> 1.0,
      		p_init_msg_list 	=> FND_API.G_FALSE,
  		p_commit      		=> FND_API.G_FALSE,
  		p_source_doc_type 	=> p_x_header_rec.contract_source_doc_type_code,
               	p_source_doc_id 	=> p_x_header_rec.contract_source_document_id,
                p_target_doc_type 	=> 'O',
                p_target_doc_id 	=> p_x_header_rec.header_id,
          	p_contract_template_id  => p_x_header_rec.contract_template_id,
                x_return_status	 	=> l_return_status,
                x_msg_count     	=> l_msg_count,
                x_msg_data      	=> l_msg_data
		);

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              if l_debug_level > 0 then
                 oe_debug_pub.ADD('OE_Header_Util.Post_Write unexp error in instantiate doc terms',1);
              end if;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              if l_debug_level > 0 then
                 oe_debug_pub.ADD('OE_Header_Util.Post_Write exp error in instantiate doc terms',1);
              end if;
              RAISE FND_API.G_EXC_ERROR;
         END IF;

      END IF;
      oe_debug_pub.add('Post Write Process R12 CCE changes...'||p_x_header_rec.header_id);
      oe_debug_pub.add('Old header id'||p_old_header_rec.header_id);
      oe_debug_pub.add('payment type'||p_x_header_rec.payment_type_code);
      --oe_debug_pub.add('card number'||p_x_header_rec.credit_Card_number);
      --If Bill to site is changed, then the payment record would
      --be deleted through the delayed request. So not calling
      --the process order if bill to site has changed.
      --bug 4885313
      IF NOT OE_GLOBALS.Equal(p_x_header_rec.invoice_to_org_id,p_old_header_rec.invoice_to_org_id)
      THEN
	    --If the user has modified the bill to site and has entered a new
	    --credit card before saving the record, then the global flag need
	    --to be set to Y so that the current trxn extension id would be
	    --deleted and a new one created (as the context has changed).
	    oe_debug_pub.add('Old invoice to'||p_x_header_rec.invoice_to_org_id);
	    oe_debug_pub.add('New invoice to'||p_old_header_rec.invoice_to_org_id);
	    IF NOT OE_GLOBALS.Equal(p_old_header_rec.invoice_to_org_id,FND_API.G_MISS_NUM)
	    AND p_old_header_rec.invoice_to_org_id IS NOT NULL AND
	    p_x_header_rec.payment_type_code = 'CREDIT_CARD' THEN
		    OE_Payment_Trxn_Util.g_old_bill_to_site := p_old_header_rec.invoice_to_org_id;
	    END IF;
	    oe_debug_pub.add('Bill to site changed in post_write_process'||OE_Payment_Trxn_Util.g_old_bill_to_site);
      END IF;

	oe_debug_pub.add('Operatoin in post write...in header rec..'||p_x_header_rec.operation);

        --R12 CC Encryption
	--As ACH and Direct Debit are not supported in Order Header Others tab
	--only Credit card payment type code is checked here.
	--Moreover, when  the old payment type code is credit card, then need
	--to delete the trxn extension id created for this creditcard
	--When the old payment type is not null and the new one is null then
	--need to delete the payment record from oe_payments.
	IF(  ( OE_GLOBALS.Equal(p_x_header_rec.payment_type_code, 'CREDIT_CARD') AND
	       p_x_header_rec.credit_card_number is not null
	      )
	   OR (
	        OE_GLOBALS.Equal(p_old_header_rec.payment_type_code,'CREDIT_CARD')
	      )
	   OR ( p_old_header_rec.payment_type_code IS NOT NULL AND
	        p_x_header_rec.payment_type_code IS NULL
	      ))
	 AND --For copy orders, the CREATE operation need not call process order here
	 (   --as the payment record would be inserted from oe_header_payment_util package.
	     nvl(p_x_header_rec.source_document_type_id,-99) <> 2  OR
	       ( --To create or update credit cards on copied orders
	         nvl(p_x_header_rec.source_document_type_id,-99)=2 AND
		 p_x_header_rec.operation=OE_GLOBALS.G_OPR_UPDATE
	       )
	  )

	THEN
	BEGIN
		--For update operation, payment number needs to be set in
		--the payment record type as otherwise the process order
		--call was failing in Query_row procedure during update operation
		SELECT 'Y',payment_number,payment_type_code
		INTO l_payment_exists,l_payment_number,l_old_payment_type_code
		FROM oe_payments
		WHERE header_id = p_x_header_rec.header_id
		and line_id is null
		AND nvl(PAYMENT_COLLECTION_EVENT,'PREPAY') = 'INVOICE';

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		l_payment_exists := 'N';
	END;

		l_control_rec.controlled_operation := TRUE;
		l_control_rec.check_security       := TRUE;
		l_control_rec.default_attributes   := TRUE;
		l_control_rec.change_attributes    := TRUE;
	    	--l_control_rec.clear_dependents     := FALSE;
	    	l_control_rec.clear_dependents     := TRUE; -- bug 9200306
		l_control_rec.validate_entity      := FALSE;
		l_control_rec.write_to_DB          := TRUE;   --Verify
		l_control_rec.process              := FALSE;
	        l_control_rec.clear_api_cache      := FALSE;
	   	l_control_rec.clear_api_requests   := FALSE;

		l_x_Header_Payment_tbl(1):=OE_ORDER_PUB.G_MISS_HEADER_PAYMENT_REC;
	    	l_x_old_Header_Payment_Tbl(1):=OE_ORDER_PUB.G_MISS_HEADER_PAYMENT_REC;

	    	l_x_Header_Payment_tbl(1).header_id := p_x_header_rec.header_id;
	    	l_x_Header_Payment_tbl(1).payment_collection_event := 'INVOICE';
	    	l_x_Header_Payment_tbl(1).payment_level_code := 'ORDER';
		l_x_Header_Payment_tbl(1).credit_card_number := p_x_header_rec.credit_card_number;
		l_x_Header_Payment_tbl(1).credit_card_code := p_x_header_rec.credit_card_code;
		l_x_Header_Payment_tbl(1).credit_card_holder_name := p_x_header_rec.credit_card_holder_name;
		l_x_Header_Payment_tbl(1).credit_card_expiration_date := p_x_header_rec.credit_card_expiration_date;
		l_x_Header_Payment_tbl(1).credit_card_approval_code := p_x_header_rec.credit_card_approval_code;
		l_x_Header_Payment_tbl(1).credit_card_approval_date := p_x_header_rec.credit_card_approval_date;
		l_x_Header_Payment_tbl(1).payment_type_code := p_x_header_rec.payment_type_code;
		l_x_Header_Payment_tbl(1).CC_INSTRUMENT_ID := p_x_header_rec.CC_INSTRUMENT_ID;
		l_x_Header_Payment_tbl(1).CC_INSTRUMENT_ASSIGNMENT_ID := p_x_header_rec.CC_INSTRUMENT_ASSIGNMENT_ID;
		l_x_Header_Payment_tbl(1).instrument_security_code := p_x_header_rec.instrument_security_code;
		l_x_Header_Payment_tbl(1).payment_number := l_payment_number;
		l_x_Header_Payment_tbl(1).check_number := p_x_header_rec.check_number;
	        oe_debug_pub.add('Old payment type'||l_old_payment_type_code);
	        oe_debug_pub.add('New payment type'||p_x_header_rec.payment_type_code);
		oe_debug_pub.add('Header_id'||p_x_header_rec.header_id);
	        /*IF NOT OE_GLOBALS.Equal(l_old_payment_type_code,p_x_header_rec.payment_type_code) THEN
			oe_debug_pub.add('ksurendr: Receipt method id in uhdrb post write'||l_x_Header_Payment_tbl(1).receipt_method_id);
			l_x_Header_Payment_tbl(1).receipt_method_id := FND_API.G_MISS_NUM;
	        END IF;*/

		--Verify
		IF l_payment_exists = 'Y' THEN
			--If the old payment type code is not null and the new payment type code
			--is null, then the payment record has been cleared by the user from the
			--Others tab and hence it is required to delete this record from oe_payments.
			IF l_old_payment_type_code IS NOT NULL
			AND p_x_header_rec.payment_type_code IS NULL THEN
				l_x_Header_Payment_tbl(1).operation := OE_GLOBALS.G_OPR_DELETE;
                        -- bug 5035651
			ELSIF nvl(p_x_header_rec.cancelled_flag, 'N') <> 'Y' THEN
				l_x_Header_Payment_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
			ELSE
				l_x_Header_Payment_tbl(1).operation := NULL;
			END IF;

                        /*
			ELSE
				l_x_Header_Payment_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
			END IF;
                        */
		ELSE
			l_x_Header_Payment_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;

			--bug 5258767
			--Only credit card payment types have the pre-payment records inserted
			--from this procedure. The other payment types are taken care by the
			--procedure Update_Hdr_Payment in Oe_Prepayment_Pvt.
			IF OE_GLOBALS.Equal(p_x_header_rec.payment_type_code, 'CREDIT_CARD') THEN
				--Need to check if the payment term present in the header
				--has the prepayment check box checked so as to insert the
				--prepayment record as well if the other conditions are
				--satisfied.
				BEGIN
					SELECT PAYMENT_TERM_ID,TRANSACTIONAL_CURR_CODE
					INTO l_payment_term_id,l_currency_code
					FROM OE_ORDER_HEADERS_ALL
					WHERE HEADER_ID = p_x_header_rec.header_id;
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
					l_payment_term_id := NULL;
				END;
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('OEXUHDRB post write: term id : ' || l_payment_term_id);
				END IF;

				if l_payment_term_id is not null then
					l_prepayment_flag := AR_PUBLIC_UTILS.Check_Prepay_Payment_Term(l_payment_term_id);
					IF l_debug_level > 0 THEN
						oe_debug_pub.add('prepayment_flag is : ' || l_prepayment_flag );
					END IF;
				end if;

				IF nvl(l_prepayment_flag,'N') = 'Y' THEN
					--Checking the count for prepayments and not inserting
					--the prepayment record if there is an existing prepayment
					--for this header.
					BEGIN
						SELECT count(*) INTO l_prepay_count
						FROM OE_PAYMENTS
						WHERE HEADER_ID = p_x_header_rec.header_id
						AND LINE_ID IS NULL AND
						NVL(PAYMENT_COLLECTION_EVENT,'PREPAY') = 'PREPAY';
					EXCEPTION
					WHEN NO_DATA_FOUND THEN
						l_prepay_count := 0;
					END;

					IF l_debug_level > 0 THEN
						oe_debug_pub.add('OEXUHDRB post write: prepayment count...'||l_prepay_count);
					END IF;

					--Since prepayments should not be allowed when there are line
					--payments, checking the line payments count before calling the
					--process order for inserting the prepayments.
					BEGIN
						SELECT COUNT(PAYMENT_TYPE_CODE) INTO l_line_payment_count
						FROM OE_PAYMENTS
						WHERE HEADER_ID = p_x_header_rec.header_id
						AND LINE_ID IS NOT NULL
						AND PAYMENT_TYPE_CODE <> 'COMMITMENT';
					EXCEPTION
					WHEN NO_DATA_FOUND THEN
						l_line_payment_count := 0;
					END;

					IF l_debug_level > 0 THEN
						oe_debug_pub.add('OEXUHDRB post write: line payment count...'||l_line_payment_count);
					END IF;

					--If prepayment count is zero, then need to insert an
					--additional prepayment record in Oe_Payments as the payment
					--term used has the prepayment check box checked
					IF nvl(l_prepay_count,0) = 0  and nvl(l_line_payment_count,0) = 0 THEN
						IF l_debug_level > 0 THEN
							oe_debug_pub.add('OEXUHDRB: Inside prepayment record insertion....'||l_prepay_count);
							oe_debug_pub.add('Payment number value...'||l_payment_number);
							oe_debug_pub.add('Header id ----> '||p_x_header_rec.header_id);
						END IF;

						l_x_Header_Payment_tbl(2):=OE_ORDER_PUB.G_MISS_HEADER_PAYMENT_REC;
						l_x_old_Header_Payment_Tbl(2):=OE_ORDER_PUB.G_MISS_HEADER_PAYMENT_REC;

						l_x_Header_Payment_tbl(2).header_id := p_x_header_rec.header_id;
						l_x_Header_Payment_tbl(2).payment_collection_event := 'PREPAY';
						l_x_Header_Payment_tbl(2).payment_level_code := 'ORDER';
						l_x_Header_Payment_tbl(2).credit_card_number := p_x_header_rec.credit_card_number;
						l_x_Header_Payment_tbl(2).credit_card_code := p_x_header_rec.credit_card_code;
						l_x_Header_Payment_tbl(2).credit_card_holder_name := p_x_header_rec.credit_card_holder_name;
						l_x_Header_Payment_tbl(2).credit_card_expiration_date := p_x_header_rec.credit_card_expiration_date;
						l_x_Header_Payment_tbl(2).credit_card_approval_code := p_x_header_rec.credit_card_approval_code;
						l_x_Header_Payment_tbl(2).credit_card_approval_date := p_x_header_rec.credit_card_approval_date;
						l_x_Header_Payment_tbl(2).payment_type_code := p_x_header_rec.payment_type_code;
						l_x_Header_Payment_tbl(2).CC_INSTRUMENT_ID := p_x_header_rec.CC_INSTRUMENT_ID;
						l_x_Header_Payment_tbl(2).CC_INSTRUMENT_ASSIGNMENT_ID := p_x_header_rec.CC_INSTRUMENT_ASSIGNMENT_ID;
						l_x_Header_Payment_tbl(2).instrument_security_code := p_x_header_rec.instrument_security_code;
						l_x_Header_Payment_tbl(2).payment_number := l_payment_number+1;


					       OE_OE_TOTALS_SUMMARY.Order_Totals
							       (
							       p_header_id=>p_x_header_rec.header_id,
							       p_subtotal =>l_subtotal,
							       p_discount =>l_discount,
							       p_charges  =>l_charges,
							       p_tax      =>l_tax
							       );

					       l_order_total := nvl(l_subtotal,0) + nvl(l_charges,0) + nvl(l_tax,0);

					        l_downpayment := oe_prepayment_util.get_downpayment_amount(
						p_header_id => p_x_header_rec.header_id,
						p_term_id => l_payment_term_id,
						p_curr_code => l_currency_code,
						p_order_total => l_order_total);

						l_x_Header_Payment_tbl(2).payment_amount := l_downpayment;

						IF l_debug_level > 0 THEN
							oe_debug_pub.add('Inside prepayment type'||l_old_payment_type_code);
							oe_debug_pub.add('New prepayment type'||p_x_header_rec.payment_type_code);
							oe_debug_pub.add('Header_id'||p_x_header_rec.header_id);
						END IF;
						l_x_Header_Payment_tbl(2).operation := OE_GLOBALS.G_OPR_CREATE;
					END IF;
				END IF;
			END IF;
			--bug 5258767
		END IF;
		oe_debug_pub.add('Operation to be performed....frm post write proces...'||l_x_Header_Payment_tbl(1).operation);

		OE_Order_PVT.Header_Payments
		(   p_validation_level            	=> FND_API.G_VALID_LEVEL_NONE
		,   p_init_msg_list               	=> FND_API.G_FALSE
		,   p_control_rec                 	=> l_control_rec
		,   p_x_Header_Payment_tbl        	=> l_x_Header_Payment_tbl
		,   p_x_old_Header_Payment_tbl		=> l_x_old_Header_Payment_tbl
		,   x_return_Status               	=> l_return_status
		);
		IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_return_Status = FND_API.G_RET_STS_SUCCESS THEN
			oe_debug_pub.add('Success in Header Payments call...');
		END IF;
        END IF;
	--R12 CC Encryption
	oe_debug_pub.add('Exiting OE_HEADER_UTIL.Post_Write_Process',1);
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	WHEN OTHERS THEN
		IF 	OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			OE_MSG_PUB.Add_Exc_Msg
			(   G_PKG_NAME
			,   'Post_Write_Process'
			);
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Post_Write_Process;


Procedure Validate_gapless_seq( p_application_id IN NUMBER,
                         p_entity_short_name in VARCHAR2,
                         p_validation_entity_short_name in VARCHAR2,
                         p_validation_tmplt_short_name in VARCHAR2,
                         p_record_set_tmplt_short_name in VARCHAR2,
                         p_scope in VARCHAR2,
                         p_result OUT NOCOPY /* file.sql.39 change */ NUMBER )
IS
	ltype 			VARCHAR2(1);
	l_header_id 	NUMBER := oe_header_security.g_record.header_id;
	l_order_type_id NUMBER;
        l_transaction_phase_code VARCHAR2(1)
                       := oe_header_security.g_record.transaction_phase_code;
BEGIN

	oe_debug_pub.add('Entering OR_HEADER_UTIL.Validate_Gapless_Seq',1);

	select order_type_id into
	l_order_type_id
	from oe_order_headers_all
	where header_id = l_header_id;

	ltype := Get_ord_seq_type(l_order_type_id,l_transaction_phase_code);

	IF ltype = 'G' THEN
		p_result := 1;
	ELSE
		p_result := 0;
	END IF;

EXCEPTION

     when no_data_found then
               p_result := 1;

End Validate_gapless_seq;

PROCEDURE get_customer_details
(   p_org_id                IN  NUMBER
,   p_site_use_code         IN  VARCHAR2
,   x_customer_name         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_customer_number       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_customer_id           OUT NOCOPY /* file.sql.39 change */ number
,   x_location              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_address1              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_address2              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_address3              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_address4              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_city              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_state              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_zip              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_country              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)

IS
BEGIN

    IF p_org_id is NOT NULL THEN

        SELECT /*MOAC_SQL_CHANGE*/  cust.cust_account_id,
                party.party_name,
                cust.account_number,
                site.location,
                loc.address1,
                loc.address2,
                loc.address3,
                loc.address4,
                loc.city,
                nvl(loc.state,loc.province), --3603600
                loc.postal_code,
                loc.country
        INTO    x_customer_id,
                x_customer_name,
                x_customer_number,
                x_location,
                x_address1,
                x_address2,
                x_address3,
                x_address4,
                x_city,
                x_state,
                x_zip,
                x_country
        FROM    HZ_CUST_SITE_USES_ALL site,
                HZ_CUST_ACCT_SITES cas,
                hz_cust_accounts cust,
                hz_parties party,
                hz_party_sites ps,
                hz_locations loc
        WHERE   site.cust_acct_site_id=cas.cust_acct_site_id
        AND     site.site_use_code=p_site_use_code
        AND     site.site_use_id=p_org_id
        AND     cust.cust_account_id = cas.cust_account_id
        AND     cas.party_site_id = ps.party_site_id
        AND     ps.location_id = loc.location_id
        AND     party.party_id = cust.party_id;

    ELSE

        x_customer_name    :=  NULL    ;
        x_customer_number  :=  NULL    ;
        x_customer_id      :=  NULL    ;
        x_location         :=  NULL;
        x_address1         := nULL;
        x_address2         := nULL;
        x_address3         := nULL;
        x_address4         := nULL;
        x_city         := nULL;
        x_state         := nULL;
        x_zip         := nULL;
        x_country         := nULL;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','get_customer_details');
            OE_MSG_PUB.Add;

        END IF;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'get_customer_details'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_customer_details;

 -- This procedure deletes all the header level charges when the order/all the lines are cancelled

PROCEDURE cancel_header_charges
( p_header_id IN number ,
--  p_x_line_id IN number,
  x_return_status OUT NOCOPY varchar2
)
IS
l_total_quantity NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
    oe_debug_pub.add(' Entering Cancel_Header_Charges() ');

--  SELECT sum(ordered_quantity) into l_total_quantity from OE_ORDER_LINES where header_id = p_header_id; --commented for bug#9434723
    --bug#9434723: Outer NVL() if the it is last line to be deleted. Inner NVL() if line is in ENTERED status w/out qty.
    SELECT Nvl(sum( Nvl(ordered_quantity,0) ),0) into l_total_quantity FROM OE_ORDER_LINES where header_id = p_header_id; --bug#9434723
    oe_debug_pub.add('   l_total_quantity = ' ||l_total_quantity, 1 ) ;

    IF l_total_quantity = 0 THEN
        OE_Header_Adj_Util.Delete_Header_Charges( p_header_id  => p_header_id );
    END IF;
    oe_debug_pub.add(' Exiting Cancel_Header_Charges() ');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UNEXPECTED ERROR IN ' || G_PKG_NAME || ':' || 'PERFORM_LINE_CANCEL' ) ;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
END;

--For bug 3563983
--Changed the Function name from Blanket_Req_For_Curr_Update
--Added code to mask logging Validate shipment and Incrementing amounts for delete

PROCEDURE Blkt_Req_For_Curr_Upd_And_Del
  (p_header_rec          IN OE_Order_PUB.Header_Rec_Type
   ,p_old_header_rec     IN OE_Order_PUB.Header_Rec_Type
  )
IS

  CURSOR lines IS
    SELECT  line_id
           ,blanket_number
           ,blanket_line_number
           ,ordered_quantity
           ,order_quantity_uom
           ,inventory_item_id
           ,unit_selling_price
           ,fulfilled_flag
           ,line_set_id
      FROM OE_ORDER_LINES
     WHERE HEADER_ID = p_header_rec.header_id
       AND BLANKET_NUMBER IS NOT NULL;

  l_return_status        VARCHAR2(1);

BEGIN

    -- BUG 2746595, send currency code as request_unique_key1 parameter to
    -- process release request. This is required as 2 distinct requests need to
    -- be logged for currency updates.

    -- For all release lines i.e. lines with a blanket reference
    -- , log delayed requests to update amounts based on the new currency
    FOR c IN lines LOOP

         -- Request to decrement amounts based on old currency code
         OE_Delayed_Requests_Pvt.Log_Request
           (p_entity_code               => OE_GLOBALS.G_ENTITY_ALL
           ,p_entity_id                 => c.line_id
           ,p_requesting_entity_code    => OE_GLOBALS.G_ENTITY_HEADER
           ,p_requesting_entity_id      => p_header_rec.header_id
           ,p_request_type              => OE_GLOBALS.G_PROCESS_RELEASE
           -- Old values
           ,p_param1                    => c.blanket_number
           ,p_param2                    => c.blanket_line_number
           ,p_param3                    => c.ordered_quantity
           ,p_param4                    => c.order_quantity_uom
           ,p_param5                    => c.unit_selling_price
           ,p_param6                    => c.inventory_item_id
           -- New values
           ,p_param11                   => null
           ,p_param12                   => null
           ,p_param13                   => 0
           ,p_param14                   => null
           ,p_param15                   => 0
           ,p_param16                   => null
           -- Other parameters - old currency code here
           ,p_param8                    => c.fulfilled_flag
           ,p_param9                    => c.line_set_id
           ,p_request_unique_key1       => p_old_header_rec.transactional_curr_code
           ,x_return_status             => l_return_status
          );
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         --For bug 3563983
         IF p_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
         THEN
            -- Request to increment amounts based on new currency code
            OE_Delayed_Requests_Pvt.Log_Request
               (p_entity_code               => OE_GLOBALS.G_ENTITY_ALL
	       ,p_entity_id                 => c.line_id
               ,p_requesting_entity_code    => OE_GLOBALS.G_ENTITY_HEADER
               ,p_requesting_entity_id      => p_header_rec.header_id
               ,p_request_type              => OE_GLOBALS.G_PROCESS_RELEASE
               -- Old values
               ,p_param1                    => null
               ,p_param2                    => null
               ,p_param3                    => 0
               ,p_param4                    => null
               ,p_param5                    => 0
               ,p_param6                    => null
               -- New values
               ,p_param11                   => c.blanket_number
               ,p_param12                   => c.blanket_line_number
               ,p_param13                   => c.ordered_quantity
               ,p_param14                   => c.order_quantity_uom
               ,p_param15                   => c.unit_selling_price
               ,p_param16                   => c.inventory_item_id
               -- Other parameters - new currency code here
               ,p_param8                    => c.fulfilled_flag
               ,p_param9                    => c.line_set_id
               ,p_request_unique_key1       => p_header_rec.transactional_curr_code
               ,x_return_status             => l_return_status
               );


           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

	   -- For shipment lines, also log requests to validate that
           -- sum of amounts across all shipments in the line set are
           -- within release min/max limits set on blanket line
           IF c.line_set_id IS NOT NULL THEN

             OE_Delayed_Requests_Pvt.Log_Request
               (p_entity_code               => OE_GLOBALS.G_ENTITY_ALL
                ,p_entity_id                 => c.line_set_id
                ,p_requesting_entity_code    => OE_GLOBALS.G_ENTITY_LINE
                ,p_requesting_entity_id      => c.line_id
                ,p_request_type              => OE_GLOBALS.G_VALIDATE_RELEASE_SHIPMENTS
                ,p_request_unique_key1       => c.blanket_number
                ,p_request_unique_key2       => c.blanket_line_number
                ,p_param1                    =>
                        p_header_rec.transactional_curr_code
                ,x_return_status             => l_return_status
                );
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

           END IF;

       END IF;

   END LOOP;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Blkt_Req_For_Curr_Upd_And_Del'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Blkt_Req_For_Curr_Upd_And_Del;


--ER7675548
Procedure Get_customer_info_ids
( p_header_customer_info_tbl IN OUT NOCOPY OE_Order_Pub.CUSTOMER_INFO_TABLE_TYPE,
  p_x_header_rec             IN OUT NOCOPY OE_Order_Pub.Header_Rec_Type,
  x_return_status            OUT NOCOPY VARCHAR2,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2
)IS

x_sold_to_customer_id   NUMBER;
x_ship_to_customer_id   NUMBER;
x_bill_to_customer_id   NUMBER;
x_deliver_to_customer_id  NUMBER;

x_ship_to_org_id NUMBER;
x_invoice_to_org_id NUMBER;
x_deliver_to_org_id NUMBER;
x_sold_to_site_use_id NUMBER;

x_sold_to_contact_id  NUMBER;
x_ship_to_contact_id  NUMBER;
x_invoice_to_contact_id   NUMBER;
x_deliver_to_contact_id   NUMBER;


l_order_source_id           NUMBER := p_x_header_rec.order_source_id;
l_orig_sys_document_ref     VARCHAR2(50) :=  p_x_header_rec.orig_sys_document_ref;
l_orig_sys_line_ref     VARCHAR2(50);
l_orig_sys_shipment_ref     VARCHAR2(50);
l_change_sequence           VARCHAR2(50) := p_x_header_rec.change_sequence;
l_source_document_type_id   NUMBER := p_x_header_rec.source_document_type_id;
l_source_document_id        NUMBER := p_x_header_rec.source_document_id;
l_source_document_line_id        NUMBER;


l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
x_party_id NUMBER;
x_cust_account_id NUMBER;
begin

x_return_status := FND_API.G_RET_STS_SUCCESS;

IF l_debug_level >0 then
	oe_debug_pub.add('Entering OE_HEADER_UTIL.Get_customer_info_ids :'||p_header_customer_info_tbl.count);
End IF;

OE_CUSTOMER_INFO_PVT.G_SOLD_TO_CUSTOMER_ID := NULL;

IF p_header_customer_info_tbl.count = 0 THEN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	RETURN;
END IF;
 --Get  nesessary attributes to set the message context in case of UPDATE operation
 IF p_x_header_rec.header_Id IS NOT NULL AND
           p_x_header_rec.header_Id <> FND_API.G_MISS_NUM THEN
           BEGIN
               SELECT order_source_id, orig_sys_document_ref, change_sequence,
               source_document_type_id, source_document_id
               INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence,
               l_source_document_type_id, l_source_document_id
               FROM   OE_ORDER_HEADERS_ALL
               WHERE  header_id = p_x_header_rec.header_Id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
               WHEN OTHERS THEN
                   l_order_source_id := null;
                   l_orig_sys_document_ref := null;
                   l_change_sequence := null;
                   l_source_document_type_id := null;
                   l_source_document_id := null;
            END;
  END IF;


    OE_MSG_PUB.set_msg_context(
	 p_entity_code			=> 'HEADER'
  	,p_entity_id         		=> p_x_header_rec.header_id
    	,p_header_id         		=> p_x_header_rec.header_id
    	,p_line_id           		=> null
    	,p_orig_sys_document_ref	=> l_orig_sys_document_ref
    	,p_orig_sys_document_line_ref	=> null
        ,p_change_sequence              => l_change_sequence
    	,p_source_document_id		=> l_source_document_id
    	,p_source_document_line_id	=> null
	,p_order_source_id            => l_order_source_id
	,p_source_document_type_id    => l_source_document_type_id);

	IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
	   p_x_header_rec.sold_to_org_id = FND_API.G_MISS_NUM THEN

		IF l_debug_level  > 0 THEN
		     oe_debug_pub.add('Selecting sold_to_org_id in case of update');
		END IF;

		BEGIN
				SELECT NVL(SOLD_TO_ORG_ID,p_x_header_rec.sold_to_org_id)
				INTO p_x_header_rec.sold_to_org_id
				FROM OE_ORDER_HEADERS_ALL
				WHERE HEADER_ID = p_x_header_rec.header_id;
                EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
        END IF;




	OE_CUSTOMER_INFO_PVT.get_customer_info_ids (
                          p_customer_info_tbl  => p_header_customer_info_tbl,
		          p_operation_code     => p_x_header_rec.operation,
			  p_sold_to_customer_ref => p_x_header_rec.sold_to_customer_ref,
			  p_ship_to_customer_ref => p_x_header_rec.ship_to_customer_ref,
			  p_bill_to_customer_ref => p_x_header_rec.invoice_to_customer_ref,
			  p_deliver_to_customer_ref => p_x_header_rec.deliver_to_customer_ref,

			  p_ship_to_address_ref => p_x_header_rec.ship_to_address_ref,
			  p_bill_to_address_ref => p_x_header_rec.invoice_to_address_ref,
			  p_deliver_to_address_ref => p_x_header_rec.deliver_to_address_ref,
 		          p_sold_to_address_ref => p_x_header_rec.sold_to_address_ref,

			  p_sold_to_contact_ref => p_x_header_rec.sold_to_contact_ref,
			  p_ship_to_contact_ref => p_x_header_rec.ship_to_contact_ref,
			  p_bill_to_contact_ref => p_x_header_rec.invoice_to_contact_ref,
			  p_deliver_to_contact_ref => p_x_header_rec.deliver_to_contact_ref,

			  p_sold_to_customer_id => p_x_header_rec.sold_to_org_id,
			  p_ship_to_customer_id => p_x_header_rec.ship_to_customer_id,
			  p_bill_to_customer_id  => p_x_header_rec.invoice_to_customer_id,
			  p_deliver_to_customer_id  => p_x_header_rec.deliver_to_customer_id,

			  p_ship_to_org_id     => p_x_header_rec.ship_to_org_id,
			  p_invoice_to_org_id  => p_x_header_rec.invoice_to_org_id,
			  p_deliver_to_org_id  => p_x_header_rec.deliver_to_org_id,
			  p_sold_to_site_use_id => p_x_header_rec.sold_to_site_use_id,

			  p_sold_to_contact_id  => p_x_header_rec.sold_to_contact_id,
			  p_ship_to_contact_id  => p_x_header_rec.ship_to_contact_id,
			  p_invoice_to_contact_id => p_x_header_rec.invoice_to_contact_id,
			  p_deliver_to_contact_id => p_x_header_rec.deliver_to_contact_id,


			  x_sold_to_customer_id => x_sold_to_customer_id,
			  x_ship_to_customer_id => x_ship_to_customer_id,
			  x_bill_to_customer_id => x_bill_to_customer_id,
			  x_deliver_to_customer_id => x_deliver_to_customer_id,

			  x_ship_to_org_id => x_ship_to_org_id,
			  x_invoice_to_org_id => x_invoice_to_org_id,
			  x_deliver_to_org_id => x_deliver_to_org_id,
			  x_sold_to_site_use_id => x_sold_to_site_use_id,

			  x_sold_to_contact_id => x_sold_to_contact_id,
			  x_ship_to_contact_id => x_ship_to_contact_id,
			  x_invoice_to_contact_id => x_invoice_to_contact_id,
			  x_deliver_to_contact_id => x_deliver_to_contact_id ,


			  x_return_status   => x_return_status,
			  x_msg_count       => x_msg_count,
			  x_msg_data        => x_msg_data

			 );


p_x_header_rec.sold_to_org_id := x_sold_to_customer_id;
p_x_header_rec.ship_to_customer_id := x_ship_to_customer_id;
p_x_header_rec.invoice_to_customer_id := x_bill_to_customer_id;
p_x_header_rec.deliver_to_customer_id := x_deliver_to_customer_id;

p_x_header_rec.ship_to_org_id := x_ship_to_org_id;
p_x_header_rec.invoice_to_org_id := x_invoice_to_org_id;
p_x_header_rec.deliver_to_org_id := x_deliver_to_org_id;
p_x_header_rec.sold_to_site_use_id := x_sold_to_site_use_id;

p_x_header_rec.sold_to_contact_id := x_sold_to_contact_id;
p_x_header_rec.ship_to_contact_id := x_ship_to_contact_id;
p_x_header_rec.invoice_to_contact_id := x_invoice_to_contact_id;
p_x_header_rec.deliver_to_contact_id := x_deliver_to_contact_id;

OE_CUSTOMER_INFO_PVT.G_SOLD_TO_CUSTOMER_ID := x_sold_to_customer_id;
OE_CUSTOMER_INFO_PVT.G_SOLD_TO_CONTACT_ID := x_sold_to_contact_id;

OE_MSG_PUB.reset_msg_context('HEADER');


IF l_debug_level >0 then


	oe_debug_pub.add('x_return_status :' ||x_return_status);

	oe_debug_pub.add('p_x_header_rec.sold_to_org_id :' ||p_x_header_rec.sold_to_org_id);
	oe_debug_pub.add('p_x_header_rec.ship_to_customer_id :' ||p_x_header_rec.ship_to_customer_id);
	oe_debug_pub.add('p_x_header_rec.bill_to_customer_id :' ||p_x_header_rec.invoice_to_customer_id);
	oe_debug_pub.add('p_x_header_rec.deliver_to_customer_id :' ||p_x_header_rec.deliver_to_customer_id);

	oe_debug_pub.add('p_x_header_rec.ship_to_org_id :' ||p_x_header_rec.ship_to_org_id);
	oe_debug_pub.add('p_x_header_rec.bill_to_org_id :' ||p_x_header_rec.invoice_to_org_id);
	oe_debug_pub.add('p_x_header_rec.deliver_to_org_id :' ||p_x_header_rec.deliver_to_org_id);
	oe_debug_pub.add('p_x_header_rec.sold_to_site_use_id :' ||p_x_header_rec.sold_to_site_use_id);

	oe_debug_pub.add('p_x_header_rec.sold_to_contact_id :' ||p_x_header_rec.sold_to_contact_id);
	oe_debug_pub.add('p_x_header_rec.ship_to_contact_id :' ||p_x_header_rec.ship_to_contact_id);
	oe_debug_pub.add('p_x_header_rec.invoice_to_contact_id :' ||p_x_header_rec.invoice_to_contact_id);
	oe_debug_pub.add('p_x_header_rec.deliver_to_contact_id :' ||p_x_header_rec.deliver_to_contact_id);

	oe_debug_pub.add('Exiting OE_HEADER_UTIL.Get_customer_info_ids');
End IF;


EXCEPTION

	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_customer_info_ids'
            );
        END IF;

End Get_customer_info_ids;

 --Added for bug 8489881
 	 FUNCTION Get_Primary_Site_Use_Id
 	 (   p_site_use          IN VARCHAR2,
 	     p_cust_acct_id      IN NUMBER,
 	     p_org_id            IN NUMBER)
 	 RETURN NUMBER IS
 	    p_site_use_id NUMBER;
 	   BEGIN
 	   IF p_site_use = 'SHIP_TO' THEN
 	    SELECT site_use.SITE_USE_ID
 	      INTO p_site_use_id
 	      FROM HZ_CUST_SITE_USES_ALL site_use,
 	           HZ_CUST_ACCT_SITES site
 	     WHERE site_use.SITE_USE_CODE   = p_site_use
 	     AND site.CUST_ACCT_SITE_ID     = site_use.CUST_ACCT_SITE_ID
 	     AND site.CUST_ACCOUNT_ID       = p_cust_acct_id
 	     AND SITE_USE.PRIMARY_FLAG      = 'Y'
 	     AND SITE_USE.STATUS            = 'A'
 	     AND SITE.STATUS                = 'A'
 	     and SITE.ship_to_flag          = 'P'
 	     AND SITE.ORG_ID                = p_org_id;
 	   ELSE
 	     SELECT site_use.SITE_USE_ID
 	      INTO p_site_use_id
 	      FROM HZ_CUST_SITE_USES_ALL site_use,
 	           HZ_CUST_ACCT_SITES site
 	     WHERE site_use.SITE_USE_CODE   = p_site_use
 	     AND site.CUST_ACCT_SITE_ID     = site_use.CUST_ACCT_SITE_ID
 	     AND site.CUST_ACCOUNT_ID       = p_cust_acct_id
 	     AND SITE_USE.PRIMARY_FLAG      = 'Y'
 	     AND SITE_USE.STATUS            = 'A'
 	     AND SITE.STATUS                = 'A'
 	     and SITE.bill_to_flag          = 'P'
 	     AND SITE.ORG_ID                = p_org_id;
 	     END IF;
 	     RETURN p_site_use_id;
 	 EXCEPTION
 	 WHEN NO_DATA_FOUND THEN
 	   RETURN NULL;
 	 WHEN TOO_MANY_ROWS THEN
 	   RETURN NULL;
 	 END;

END OE_Header_Util;

/
