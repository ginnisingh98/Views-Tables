--------------------------------------------------------
--  DDL for Package Body OE_DEPENDENCIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEPENDENCIES" AS
/* $Header: OEXUDEPB.pls 120.5.12010000.2 2008/10/30 16:43:22 cpati ship $ */

--  Global constant holding the package name

G_PKG_NAME      	CONSTANT    VARCHAR2(30):='OE_Dependencies';

PROCEDURE Merge_Dependencies_Extn
(   p_entity_code       IN  VARCHAR2
)
IS
l_index                  NUMBER;
l_extn_dep_tbl           OE_Dependencies_Extn.Dep_Tbl_Type;
l_dep_index              NUMBER;
l_found                  BOOLEAN;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTER OE_DEPENDENCIES.MERGE_DEPENDENCIES_EXTN' , 1 ) ;
    END IF;

    OE_Dependencies_Extn.Load_Entity_Attributes
       (p_entity_code       => p_entity_code
       ,x_extn_dep_tbl      => l_extn_dep_tbl
       );

    l_index := l_extn_dep_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

      -- Ignore if dependent attribute is one of the internal fields.
      IF p_entity_code = OE_GLOBALS.G_ENTITY_HEADER THEN
         IF l_extn_dep_tbl(l_index).dependent_attribute IN
              ( OE_HEADER_UTIL.G_ORDER_CATEGORY
         ) THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'INTERNAL FIELD DEPENDENCY' ) ;
           END IF;
           GOTO END_OF_LOOP;
         END IF;
      ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_LINE THEN
         IF l_extn_dep_tbl(l_index).dependent_attribute IN
              ( OE_LINE_UTIL.G_LINE_CATEGORY
              , OE_LINE_UTIL.G_SHIPMENT_NUMBER
              , OE_LINE_UTIL.G_OPTION_NUMBER
              , OE_LINE_UTIL.G_COMPONENT_NUMBER
              , OE_LINE_UTIL.G_ITEM_TYPE
              , OE_LINE_UTIL.G_TOP_MODEL_LINE
              , OE_LINE_UTIL.G_SHIPPABLE
              , OE_LINE_UTIL.G_ATO_LINE
              , OE_LINE_UTIL.G_INVOICE_INTERFACE_STATUS
              , OE_LINE_UTIL.G_COMPONENT
              , OE_LINE_UTIL.G_COMPONENT_SEQUENCE
              , OE_LINE_UTIL.G_SORT_ORDER
              , OE_LINE_UTIL.G_SHIPPABLE
         ) THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'INTERNAL FIELD DEPENDENCY' ) ;
           END IF;
           GOTO END_OF_LOOP;
         END IF;
--serla begin
      ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_HEADER_PAYMENT THEN
         IF l_extn_dep_tbl(l_index).dependent_attribute IN
              ( OE_HEADER_PAYMENT_UTIL.G_PAYMENT_TYPE_CODE
         ) THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'INTERNAL FIELD DEPENDENCY' ) ;
           END IF;
           GOTO END_OF_LOOP;
         END IF;
      ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_LINE_PAYMENT THEN
         IF l_extn_dep_tbl(l_index).dependent_attribute IN
              ( OE_LINE_PAYMENT_UTIL.G_PAYMENT_TYPE_CODE
         ) THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'INTERNAL FIELD DEPENDENCY' ) ;
           END IF;
           GOTO END_OF_LOOP;
         END IF;
--serla end
      END IF;

      l_dep_index := l_extn_dep_tbl(l_index).source_attribute * G_MAX;
      l_found := FALSE;

      WHILE (NOT l_found) AND g_dep_tbl.EXISTS(l_dep_index) LOOP
         IF g_dep_tbl(l_dep_index).attribute = l_extn_dep_tbl(l_index).dependent_attribute THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'DEPENDENCY UPDATED' ) ;
            END IF;
            l_found := TRUE;
            g_dep_tbl(l_dep_index).enabled_flag := l_extn_dep_tbl(l_index).enabled_flag;
         END IF;
         l_dep_index := l_dep_index+1;
      END LOOP;

      IF (NOT l_found) AND l_extn_dep_tbl(l_index).enabled_flag = 'Y' THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NEW DEPENDENCY ENABLED' ) ;
         END IF;
         g_dep_tbl(l_dep_index).attribute := l_extn_dep_tbl(l_index).dependent_attribute;
      END IF;

      <<END_OF_LOOP>>
      l_index := l_extn_dep_tbl.NEXT(l_index);

    END LOOP;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXIT OE_DEPENDENCIES.MERGE_DEPENDENCIES_EXTN' , 1 ) ;
    END IF;
EXCEPTION
        WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Merge_Dependencies_Extn'
                );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Merge_Dependencies_Extn;

PROCEDURE   Load_Entity_Attributes
(   p_entity_code	IN  VARCHAR2	)
IS
l_index		NUMBER :=0;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_DEPENDENCIES.LOAD_ENTITY_ATTRIBUTES' , 1 ) ;
    END IF;

    IF g_entity_code <> p_entity_code OR
	g_entity_code IS NULL
    THEN

	--  Load entity Attributes

       -- Need to delete table because it
       -- could have been set by a previous
       -- entity
       IF (g_dep_tbl.COUNT >= 1) THEN
	  g_dep_tbl.DELETE;
       END IF;

	g_entity_code := p_entity_code;

	IF p_entity_code = OE_GLOBALS.G_ENTITY_HEADER THEN

	    --  Populate dependent attributes for one source at a time.

	    l_index := OE_HEADER_UTIL.G_ORDER_TYPE * G_MAX ;
	    g_dep_tbl(l_index  ).attribute  := OE_HEADER_UTIL.G_INVOICING_RULE;
	    g_dep_tbl(l_index +1 ).attribute  := OE_HEADER_UTIL.G_ACCOUNTING_RULE;
	    g_dep_tbl(l_index +2 ).attribute  := OE_HEADER_UTIL.G_PRICE_LIST;
	    g_dep_tbl(l_index +3 ).attribute  := OE_HEADER_UTIL.G_SHIPMENT_PRIORITY;
	    g_dep_tbl(l_index +4 ).attribute  := OE_HEADER_UTIL.G_SHIPPING_METHOD;
	    g_dep_tbl(l_index +5 ).attribute  := OE_HEADER_UTIL.G_FOB_POINT;
	    g_dep_tbl(l_index +6 ).attribute  := OE_HEADER_UTIL.G_FREIGHT_TERMS;
	    g_dep_tbl(l_index +7 ).attribute  := OE_HEADER_UTIL.G_SHIP_FROM_ORG;
	    g_dep_tbl(l_index + 8).attribute	    := OE_HEADER_UTIL.G_ORDER_CATEGORY;
	    g_dep_tbl(l_index + 9).attribute	    := OE_HEADER_UTIL.G_DEMAND_CLASS;
	    g_dep_tbl(l_index + 10).attribute	    := OE_HEADER_UTIL.G_REQUEST_DATE;
	    g_dep_tbl(l_index + 11).attribute  := OE_HEADER_UTIL.G_TRANSACTIONAL_CURR;
	    g_dep_tbl(l_index +12 ).attribute := OE_HEADER_UTIL.G_SHIP_TOLERANCE_BELOW;
	    g_dep_tbl(l_index +13 ).attribute := OE_HEADER_UTIL.G_SHIP_TOLERANCE_ABOVE;
            g_dep_tbl(l_index +14 ).attribute := OE_HEADER_UTIL.G_DEFAULT_FULFILLMENT_SET;
            g_dep_tbl(l_index +15).attribute  := OE_HEADER_UTIL.G_CUSTOMER_PREFERENCE_SET;
            -- QUOTING changes
            g_dep_tbl(l_index +16).attribute  := OE_HEADER_UTIL.G_TRANSACTION_PHASE;

	    l_index := OE_HEADER_UTIL.G_AGREEMENT * G_MAX ;
	    g_dep_tbl(l_index ).attribute	    := OE_HEADER_UTIL.G_CUST_PO_NUMBER;
	    g_dep_tbl(l_index +1 ).attribute  := OE_HEADER_UTIL.G_INVOICING_RULE;
	    g_dep_tbl(l_index +2 ).attribute  := OE_HEADER_UTIL.G_ACCOUNTING_RULE;
	    g_dep_tbl(l_index +3 ).attribute  := OE_HEADER_UTIL.G_PAYMENT_TERM;
	    g_dep_tbl(l_index +4 ).attribute  := OE_HEADER_UTIL.G_INVOICE_TO_ORG;
	    g_dep_tbl(l_index +5 ).attribute  := OE_HEADER_UTIL.G_INVOICE_TO_CONTACT;
	    g_dep_tbl(l_index +6 ).attribute  := OE_HEADER_UTIL.G_PRICE_LIST;
	    g_dep_tbl(l_index +7 ).attribute  := OE_HEADER_UTIL.G_SALESREP;


	    l_index := OE_HEADER_UTIL.G_INVOICE_TO_ORG * G_MAX ;
	    g_dep_tbl(l_index ).attribute	    := OE_HEADER_UTIL.G_PAYMENT_TERM;
	    g_dep_tbl(l_index +1 ).attribute  := OE_HEADER_UTIL.G_INVOICE_TO_CONTACT;
	    g_dep_tbl(l_index +2 ).attribute  := OE_HEADER_UTIL.G_PRICE_LIST;
	    g_dep_tbl(l_index +3 ).attribute  := OE_HEADER_UTIL.G_FOB_POINT;
	    g_dep_tbl(l_index +4 ).attribute  := OE_HEADER_UTIL.G_FREIGHT_TERMS;
	    -- Added by Manish
	    g_dep_tbl(l_index +5 ).attribute  := OE_HEADER_UTIL.G_TAX_EXEMPT_NUMBER;
	    g_dep_tbl(l_index +6 ).attribute  := OE_HEADER_UTIL.G_TAX_EXEMPT_REASON;
	    -- Added by Manish
	    g_dep_tbl(l_index +7 ).attribute  := OE_HEADER_UTIL.G_SALESREP;
	    g_dep_tbl(l_index +8 ).attribute  := OE_HEADER_UTIL.G_SHIPPING_METHOD;
	    -- Adding for OM-iPayment - Raju
	    g_dep_tbl(l_index +9 ).attribute  := OE_HEADER_UTIL.G_CREDIT_CARD_NUMBER;
	    g_dep_tbl(l_index +10 ).attribute  := OE_HEADER_UTIL.G_CREDIT_CARD_HOLDER_NAME;
	    g_dep_tbl(l_index +11 ).attribute  := OE_HEADER_UTIL.G_CREDIT_CARD_EXPIRATION_DATE;
	    g_dep_tbl(l_index +12 ).attribute := OE_HEADER_UTIL.G_SHIP_TOLERANCE_BELOW;
	    g_dep_tbl(l_index +13 ).attribute := OE_HEADER_UTIL.G_SHIP_TOLERANCE_ABOVE;
	    g_dep_tbl(l_index +14 ).attribute := OE_HEADER_UTIL.G_ORDER_TYPE;
            /* Fix Bug # 2297053: Added to clear Credit Card Type */
	    g_dep_tbl(l_index +15 ).attribute  := OE_HEADER_UTIL.G_CREDIT_CARD;
            g_dep_tbl(l_index +16).attribute  := OE_HEADER_UTIL.G_CUSTOMER_PREFERENCE_SET;

	    l_index := OE_HEADER_UTIL.G_SHIP_TO_ORG * G_MAX ;
	    g_dep_tbl(l_index  ).attribute  := OE_HEADER_UTIL.G_TAX_EXEMPT_NUMBER;
	    g_dep_tbl(l_index +1 ).attribute  := OE_HEADER_UTIL.G_TAX_EXEMPT_REASON;
	    g_dep_tbl(l_index +2 ).attribute  := OE_HEADER_UTIL.G_PRICE_LIST;
	    g_dep_tbl(l_index +3 ).attribute  := OE_HEADER_UTIL.G_FOB_POINT;
	    g_dep_tbl(l_index +4 ).attribute  := OE_HEADER_UTIL.G_FREIGHT_TERMS;
	    g_dep_tbl(l_index +5 ).attribute  := OE_HEADER_UTIL.G_SHIPPING_METHOD;
	    g_dep_tbl(l_index +6 ).attribute  := OE_HEADER_UTIL.G_DEMAND_CLASS;
	    g_dep_tbl(l_index +7 ).attribute  := OE_HEADER_UTIL.G_INVOICE_TO_ORG;
	    g_dep_tbl(l_index +8 ).attribute  := OE_HEADER_UTIL.G_SALESREP;
	    g_dep_tbl(l_index +9 ).attribute  := OE_HEADER_UTIL.G_PAYMENT_TERM;
	    g_dep_tbl(l_index +10 ).attribute  := OE_HEADER_UTIL.G_SHIP_FROM_ORG;
	    g_dep_tbl(l_index +11 ).attribute := OE_HEADER_UTIL.G_SHIP_TOLERANCE_BELOW;
	    g_dep_tbl(l_index +12 ).attribute := OE_HEADER_UTIL.G_SHIP_TOLERANCE_ABOVE;
	    g_dep_tbl(l_index +13 ).attribute := OE_HEADER_UTIL.G_ORDER_TYPE;
	    g_dep_tbl(l_index +14 ).attribute := OE_HEADER_UTIL.G_SHIP_TO_CONTACT;
	    g_dep_tbl(l_index +15 ).attribute := OE_HEADER_UTIL.G_ORDER_DATE_TYPE_CODE;
	    g_dep_tbl(l_index +16 ).attribute := OE_HEADER_UTIL.G_LATEST_SCHEDULE_LIMIT;
            g_dep_tbl(l_index +17).attribute   := OE_HEADER_UTIL.G_CUSTOMER_PREFERENCE_SET;

	    l_index := OE_HEADER_UTIL.G_REQUEST_DATE * G_MAX ;
	    g_dep_tbl(l_index  ).attribute  := OE_HEADER_UTIL.G_TAX_EXEMPT_NUMBER;
	    g_dep_tbl(l_index +1 ).attribute  := OE_HEADER_UTIL.G_TAX_EXEMPT_REASON;

	    l_index := OE_HEADER_UTIL.G_TAX_EXEMPT * G_MAX ;
	    g_dep_tbl(l_index  ).attribute  := OE_HEADER_UTIL.G_TAX_EXEMPT_NUMBER;
	    g_dep_tbl(l_index +1 ).attribute  := OE_HEADER_UTIL.G_TAX_EXEMPT_REASON;
	    -- Added by Manish

	    l_index := OE_HEADER_UTIL.G_SOLD_TO_ORG * G_MAX ;
	    g_dep_tbl(l_index ).attribute	    := OE_HEADER_UTIL.G_PAYMENT_TERM;
	    g_dep_tbl(l_index +1 ).attribute  := OE_HEADER_UTIL.G_INVOICE_TO_ORG;
	    g_dep_tbl(l_index +2 ).attribute  := OE_HEADER_UTIL.G_PRICE_LIST;
	    g_dep_tbl(l_index +3 ).attribute  := OE_HEADER_UTIL.G_FOB_POINT;
	    g_dep_tbl(l_index +4 ).attribute  := OE_HEADER_UTIL.G_FREIGHT_TERMS;
	    g_dep_tbl(l_index +5 ).attribute  := OE_HEADER_UTIL.G_DELIVER_TO_ORG;
	    g_dep_tbl(l_index +6 ).attribute  := OE_HEADER_UTIL.G_SHIP_TO_ORG;
	    g_dep_tbl(l_index +7 ).attribute  := OE_HEADER_UTIL.G_ORDER_TYPE;
	    -- Added by Manish
	    g_dep_tbl(l_index +8 ).attribute  := OE_HEADER_UTIL.G_TAX_EXEMPT_NUMBER;
	    g_dep_tbl(l_index +9 ).attribute  := OE_HEADER_UTIL.G_TAX_EXEMPT_REASON;
	    -- Added by Manish
	    g_dep_tbl(l_index +10 ).attribute  := OE_HEADER_UTIL.G_SALESREP;
	    g_dep_tbl(l_index +11 ).attribute  := OE_HEADER_UTIL.G_SHIPPING_METHOD;
	    g_dep_tbl(l_index +12 ).attribute  := OE_HEADER_UTIL.G_SHIP_FROM_ORG;
	    -- Adding for OM-iPayment - Raju
	    g_dep_tbl(l_index +13 ).attribute  := OE_HEADER_UTIL.G_CREDIT_CARD_NUMBER;
	    g_dep_tbl(l_index +14 ).attribute  := OE_HEADER_UTIL.G_CREDIT_CARD_HOLDER_NAME;
	    g_dep_tbl(l_index +15 ).attribute  := OE_HEADER_UTIL.G_CREDIT_CARD_EXPIRATION_DATE;
	    g_dep_tbl(l_index +16 ).attribute := OE_HEADER_UTIL.G_SHIP_TOLERANCE_BELOW;
	    g_dep_tbl(l_index +17 ).attribute := OE_HEADER_UTIL.G_SHIP_TOLERANCE_ABOVE;
	    g_dep_tbl(l_index +18 ).attribute := OE_HEADER_UTIL.G_SALES_CHANNEL;
	    g_dep_tbl(l_index +19 ).attribute := OE_HEADER_UTIL.G_ORDER_DATE_TYPE_CODE;
	    g_dep_tbl(l_index +20 ).attribute := OE_HEADER_UTIL.G_LATEST_SCHEDULE_LIMIT;
            g_dep_tbl(l_index +21 ).attribute := OE_HEADER_UTIL.G_AGREEMENT;
            /* Fix Bug # 2297053: Added to clear Credit Card Type */
	    g_dep_tbl(l_index +22 ).attribute  := OE_HEADER_UTIL.G_CREDIT_CARD;
            g_dep_tbl(l_index +23 ).attribute  := OE_HEADER_UTIL.G_SOLD_TO_PHONE;
            g_dep_tbl(l_index +24).attribute   := OE_HEADER_UTIL.G_CUSTOMER_PREFERENCE_SET;
            -- QUOTING changes
            g_dep_tbl(l_index +25).attribute   := OE_HEADER_UTIL.G_SOLD_TO_SITE_USE;
	    --distributed orders
	    g_dep_tbl(l_index +26).attribute   := OE_HEADER_UTIL.G_END_CUSTOMER;

	    l_index := OE_HEADER_UTIL.G_PRICE_LIST * G_MAX ;
	    g_dep_tbl(l_index ).attribute	    := OE_HEADER_UTIL.G_PAYMENT_TERM;
	    g_dep_tbl(l_index +1 ).attribute  := OE_HEADER_UTIL.G_FREIGHT_TERMS;
	    g_dep_tbl(l_index +2 ).attribute  := OE_HEADER_UTIL.G_SHIPPING_METHOD;
            /* Added the following if condition to fix the bug 2478334 */
            IF  UPPER(fnd_profile.value('QP_MULTI_CURRENCY_INSTALLED'))  IN ('Y', 'YES') THEN
               null;
         ELSE
	    g_dep_tbl(l_index +3 ).attribute  := OE_HEADER_UTIL.G_TRANSACTIONAL_CURR;
            END IF;

	    -- Adding for OM-iPayment - Raju
	    l_index := OE_HEADER_UTIL.G_PAYMENT_TYPE * G_MAX ;
	    g_dep_tbl(l_index).attribute     := OE_HEADER_UTIL.G_CREDIT_CARD_NUMBER;
	    g_dep_tbl(l_index +1 ).attribute := OE_HEADER_UTIL.G_CREDIT_CARD_HOLDER_NAME;
	    g_dep_tbl(l_index +2 ).attribute := OE_HEADER_UTIL.G_CREDIT_CARD_EXPIRATION_DATE;
	    g_dep_tbl(l_index +3 ).attribute := OE_HEADER_UTIL.G_CREDIT_CARD_APPROVAL_DATE;
	    g_dep_tbl(l_index +4 ).attribute := OE_HEADER_UTIL.G_CREDIT_CARD_APPROVAL;
	    g_dep_tbl(l_index +5 ).attribute := OE_HEADER_UTIL.G_CHECK_NUMBER;
	    g_dep_tbl(l_index +6 ).attribute := OE_HEADER_UTIL.G_PAYMENT_AMOUNT;
	    g_dep_tbl(l_index +7 ).attribute := OE_HEADER_UTIL.G_CREDIT_CARD;

            /* Fix Bug # 2297053: Added to make attributes depended on CC Number */
	    l_index := OE_HEADER_UTIL.G_CREDIT_CARD_NUMBER * G_MAX ;
            /*
            ** Fix Bug # 2867744: Commented the clearing of Credit Card Type
	    g_dep_tbl(l_index).attribute     := OE_HEADER_UTIL.G_CREDIT_CARD;
            */
	    g_dep_tbl(l_index).attribute := OE_HEADER_UTIL.G_CREDIT_CARD_HOLDER_NAME;
	    g_dep_tbl(l_index +1 ).attribute := OE_HEADER_UTIL.G_CREDIT_CARD_EXPIRATION_DATE;
	    g_dep_tbl(l_index +2 ).attribute := OE_HEADER_UTIL.G_CREDIT_CARD_APPROVAL_DATE;
	    g_dep_tbl(l_index +3 ).attribute := OE_HEADER_UTIL.G_CREDIT_CARD_APPROVAL;
	    --7337623 g_dep_tbl(l_index +4 ).attribute := OE_HEADER_UTIL.G_PAYMENT_AMOUNT;

	    -- Adding for Currency conversion. -- Added by Aswin.
	    l_index := OE_HEADER_UTIL.G_TRANSACTIONAL_CURR * G_MAX ;
	    g_dep_tbl(l_index).attribute     := OE_HEADER_UTIL.G_CONVERSION_TYPE;
	    g_dep_tbl(l_index +1 ).attribute := OE_HEADER_UTIL.G_CONVERSION_RATE_DATE;
	    g_dep_tbl(l_index +2 ).attribute := OE_HEADER_UTIL.G_CONVERSION_RATE;

	    -- Adding for deliver to org . -- Added by Shashi.
	    l_index := OE_HEADER_UTIL.G_DELIVER_TO_ORG * G_MAX ;
	    g_dep_tbl(l_index).attribute     := OE_HEADER_UTIL.G_DELIVER_TO_CONTACT;


	    -- Begin Fix bug 1282800: added dependencies for contact fields

	    l_index := OE_HEADER_UTIL.G_INVOICE_TO_CONTACT * G_MAX ;
	    g_dep_tbl(l_index).attribute     := OE_HEADER_UTIL.G_SOLD_TO_CONTACT;

	    l_index := OE_HEADER_UTIL.G_SHIP_TO_CONTACT * G_MAX ;
	    g_dep_tbl(l_index).attribute    := OE_HEADER_UTIL.G_SOLD_TO_CONTACT;

	    -- End Fix bug 1282800

            -- bug 5127922 : added dependency for cusotmer_location
	    l_index := OE_HEADER_UTIL.G_SOLD_TO_SITE_USE * G_MAX ;
	    g_dep_tbl(l_index).attribute     := OE_HEADER_UTIL.G_PAYMENT_TERM;

            -- BLANKETS: Add dependencies on blanket number for order header
            IF OE_CODE_CONTROL.Code_Release_Level >= '110509' THEN

	    l_index := OE_HEADER_UTIL.G_BLANKET_NUMBER * G_MAX ;
            -- Bug 3279125 -
            -- Remove dependency of sold to (customer) on blanket number
--	    g_dep_tbl(l_index).attribute := OE_HEADER_UTIL.G_SOLD_TO_ORG;
	    g_dep_tbl(l_index).attribute := OE_HEADER_UTIL.G_ACCOUNTING_RULE;
	    g_dep_tbl(l_index+1).attribute := OE_HEADER_UTIL.G_INVOICING_RULE;
	    g_dep_tbl(l_index+2).attribute := OE_HEADER_UTIL.G_TRANSACTIONAL_CURR;
	    g_dep_tbl(l_index+3).attribute := OE_HEADER_UTIL.G_SHIP_TO_ORG;
	    g_dep_tbl(l_index+4).attribute := OE_HEADER_UTIL.G_INVOICE_TO_ORG;
	    g_dep_tbl(l_index+5).attribute := OE_HEADER_UTIL.G_DELIVER_TO_ORG;
	    g_dep_tbl(l_index+6).attribute := OE_HEADER_UTIL.G_SOLD_TO_CONTACT;
	    g_dep_tbl(l_index+7).attribute := OE_HEADER_UTIL.G_SHIP_FROM_ORG;
	    g_dep_tbl(l_index+8).attribute := OE_HEADER_UTIL.G_PAYMENT_TERM;
	    g_dep_tbl(l_index+9).attribute := OE_HEADER_UTIL.G_PRICE_LIST;
	    g_dep_tbl(l_index+10).attribute := OE_HEADER_UTIL.G_SHIPPING_METHOD;
	    g_dep_tbl(l_index+11).attribute := OE_HEADER_UTIL.G_FREIGHT_TERMS;
	    g_dep_tbl(l_index+12).attribute := OE_HEADER_UTIL.G_SALESREP;
	    g_dep_tbl(l_index+13).attribute := OE_HEADER_UTIL.G_SHIPPING_INSTRUCTIONS;
	    g_dep_tbl(l_index+14).attribute := OE_HEADER_UTIL.G_PACKING_INSTRUCTIONS;

            END IF;

            -- QUOTING changes
            -- Add dependency of quote date/ordered date on transaction phase
            IF OE_CODE_CONTROL.Code_Release_Level >= '110510' THEN

	    l_index := OE_HEADER_UTIL.G_TRANSACTION_PHASE * G_MAX ;
	    g_dep_tbl(l_index).attribute := OE_HEADER_UTIL.G_QUOTE_DATE;
	    g_dep_tbl(l_index+1).attribute := OE_HEADER_UTIL.G_ORDERED_DATE;

            END IF;
            -- END QUOTING changes

	    --distributed orders
	    IF OE_CODE_CONTROL.Code_Release_Level >= '110510' THEN
	       l_index := OE_HEADER_UTIL.G_END_CUSTOMER * G_MAX ;
	       g_dep_tbl(l_index).attribute   := OE_HEADER_UTIL.G_END_CUSTOMER_CONTACT;
	       g_dep_tbl(l_index+1).attribute := OE_HEADER_UTIL.G_END_CUSTOMER_SITE_USE;
            END IF;

            --key transaction dates
	    IF OE_CODE_CONTROL.Code_Release_Level >= '110509' THEN
		l_index := OE_HEADER_UTIL.G_ORDERED_DATE * G_MAX ;
		g_dep_tbl(l_index).attribute := OE_HEADER_UTIL.G_ORDER_FIRMED_DATE;
	    END IF;

	ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_LINE THEN

	    l_index := OE_LINE_UTIL.G_LINE_NUMBER * G_MAX ;
	    g_dep_tbl(l_index ).attribute	    := OE_LINE_UTIL.G_SHIPMENT_NUMBER;
	    g_dep_tbl(l_index+1 ).attribute   := OE_LINE_UTIL.G_OPTION_NUMBER;
	    g_dep_tbl(l_index+2 ).attribute    := OE_LINE_UTIL.G_COMPONENT_NUMBER;
            -- component_number and not component above.

	    l_index := OE_LINE_UTIL.G_LINE_TYPE * G_MAX ;
	    g_dep_tbl(l_index ).attribute	    := OE_LINE_UTIL.G_LINE_CATEGORY;
	    /* Added by Manish */
	    g_dep_tbl(l_index +1 ).attribute   := OE_LINE_UTIL.G_TAX;
	    /* Added by Manish */
	    g_dep_tbl(l_index +2 ).attribute  := OE_LINE_UTIL.G_ACCOUNTING_RULE;
	    g_dep_tbl(l_index +3 ).attribute  := OE_LINE_UTIL.G_PRICE_LIST;
	    g_dep_tbl(l_index +4 ).attribute  := OE_LINE_UTIL.G_SHIPMENT_PRIORITY;
	    g_dep_tbl(l_index +5 ).attribute  := OE_LINE_UTIL.G_SHIPPING_METHOD;
	    g_dep_tbl(l_index +6 ).attribute  := OE_LINE_UTIL.G_FOB_POINT;
	    g_dep_tbl(l_index +7 ).attribute  := OE_LINE_UTIL.G_FREIGHT_TERMS;
	    g_dep_tbl(l_index +8 ).attribute  := OE_LINE_UTIL.G_SHIP_FROM_ORG;
	    g_dep_tbl(l_index +9).attribute   := OE_LINE_UTIL.G_DEMAND_CLASS;
	    g_dep_tbl(l_index +10 ).attribute  := OE_LINE_UTIL.G_INVOICING_RULE;
	    g_dep_tbl(l_index +11 ).attribute := OE_LINE_UTIL.G_SHIP_TOLERANCE_BELOW;
	    g_dep_tbl(l_index +12 ).attribute := OE_LINE_UTIL.G_SHIP_TOLERANCE_ABOVE;
	    g_dep_tbl(l_index +13 ).attribute := OE_LINE_UTIL.G_SOURCE_TYPE;

	    l_index := OE_LINE_UTIL.G_INVENTORY_ITEM * G_MAX ;
	    g_dep_tbl(l_index ).attribute	    := OE_LINE_UTIL.G_ORDER_QUANTITY_UOM;
	    g_dep_tbl(l_index +1 ).attribute  := OE_LINE_UTIL.G_PRICING_QUANTITY_UOM;
	    g_dep_tbl(l_index +2 ).attribute  := OE_LINE_UTIL.G_SHIP_FROM_ORG;
	    g_dep_tbl(l_index +3 ).attribute  := OE_LINE_UTIL.G_INVOICING_RULE;
	    g_dep_tbl(l_index +4 ).attribute  := OE_LINE_UTIL.G_ACCOUNTING_RULE;
	    g_dep_tbl(l_index +5 ).attribute  := OE_LINE_UTIL.G_TAX_VALUE;
	    g_dep_tbl(l_index +6 ).attribute  := OE_LINE_UTIL.G_ITEM_TYPE;
	    g_dep_tbl(l_index +7 ).attribute  := OE_LINE_UTIL.G_TOP_MODEL_LINE;
	    g_dep_tbl(l_index +8 ).attribute  := OE_LINE_UTIL.G_SHIPPABLE;
	    g_dep_tbl(l_index +9 ).attribute  := OE_LINE_UTIL.G_ATO_LINE;
	    g_dep_tbl(l_index +10 ).attribute := OE_LINE_UTIL.G_INVOICE_INTERFACE_STATUS;
	    /* Added by Manish */
	    g_dep_tbl(l_index +11 ).attribute := OE_LINE_UTIL.G_TAX;
	    /* Added by Manish */
	    g_dep_tbl(l_index +12 ).attribute := OE_LINE_UTIL.G_SHIP_TOLERANCE_BELOW;
	    g_dep_tbl(l_index +13 ).attribute := OE_LINE_UTIL.G_SHIP_TOLERANCE_ABOVE;
	    g_dep_tbl(l_index +14 ).attribute := OE_LINE_UTIL.G_PAYMENT_TERM;
	    g_dep_tbl(l_index +15 ).attribute := OE_LINE_UTIL.G_SHIP_FROM_ORG;
	    g_dep_tbl(l_index +16 ).attribute := OE_LINE_UTIL.G_END_ITEM_UNIT_NUMBER;
           /* OPM 02/JUN/00 - add dependencies for process attribs */
         -- commented out for bug 1618229.
         -- g_dep_tbl(l_index +17 ).attribute := OE_LINE_UTIL.G_COMMITMENT;
            g_dep_tbl(l_index +17 ).attribute := OE_LINE_UTIL.G_ORDERED_QUANTITY_UOM2;
            g_dep_tbl(l_index +18 ).attribute := OE_LINE_UTIL.G_PREFERRED_GRADE;

           /* OPM END */
	    g_dep_tbl(l_index +19 ).attribute := OE_LINE_UTIL.G_SERVICE_START_DATE;
	    g_dep_tbl(l_index +20 ).attribute := OE_LINE_UTIL.G_SERVICE_PERIOD;
	    g_dep_tbl(l_index +21 ).attribute := OE_LINE_UTIL.G_SERVICE_REFERENCE_TYPE_CODE;
	    g_dep_tbl(l_index +22 ).attribute := OE_LINE_UTIL.G_COMPONENT;
         /* Added for Returns processing */
         g_dep_tbl(l_index +23 ).attribute := OE_LINE_UTIL.G_RETURN_CONTEXT;
         g_dep_tbl(l_index +24 ).attribute := OE_LINE_UTIL.G_COMPONENT_SEQUENCE;
         g_dep_tbl(l_index +25 ).attribute := OE_LINE_UTIL.G_SORT_ORDER;
         -- ER: 1840556
         g_dep_tbl(l_index +26 ).attribute := OE_LINE_UTIL.G_SOURCE_TYPE;
         g_dep_tbl(l_index +27).attribute := OE_LINE_UTIL.G_ORDERED_QUANTITY2; -- 3016136
	 --recurring charges
	     g_dep_tbl(l_index+28).attribute := OE_LINE_UTIL.G_CHARGE_PERIODICITY;
         g_dep_tbl(l_index +29 ).attribute := OE_LINE_UTIL.G_ITEM_REVISION;
         -- bug 4283037
         g_dep_tbl(l_index +30 ).attribute := OE_LINE_UTIL.G_SERVICE_DURATION;


	    l_index := OE_LINE_UTIL.G_AGREEMENT * G_MAX ;
	    g_dep_tbl(l_index).attribute  := OE_LINE_UTIL.G_INVOICING_RULE;
	    g_dep_tbl(l_index +1 ).attribute  := OE_LINE_UTIL.G_ACCOUNTING_RULE;
	    g_dep_tbl(l_index +2 ).attribute  := OE_LINE_UTIL.G_PAYMENT_TERM;
	    g_dep_tbl(l_index +3 ).attribute  := OE_LINE_UTIL.G_PRICE_LIST;
-- added the following lines to fix bug 1766836   Begin
            g_dep_tbl(l_index +4 ).attribute  := OE_LINE_UTIL.G_CUST_PO_NUMBER;
	    g_dep_tbl(l_index +5 ).attribute  := OE_LINE_UTIL.G_INVOICE_TO_ORG;
	    g_dep_tbl(l_index +6 ).attribute  := OE_LINE_UTIL.G_INVOICE_TO_CONTACT;
	    g_dep_tbl(l_index +7 ).attribute  := OE_LINE_UTIL.G_SALESREP;
            g_dep_tbl(l_index +8 ).attribute  := OE_LINE_UTIL.G_COMMITMENT;
-- added the following lines to fix bug 1766836   End

            --g_dep_tbl(l_index ).attribute     := OE_LINE_UTIL.G_CUST_PO_NUMBER;
	    --g_dep_tbl(l_index +3 ).attribute  := OE_LINE_UTIL.G_INVOICE_TO_ORG;
	    --g_dep_tbl(l_index +4 ).attribute  := OE_LINE_UTIL.G_INVOICE_TO_CONTACT;
	    --g_dep_tbl(l_index +4 ).attribute  := OE_LINE_UTIL.G_SOLD_TO_ORG;
	    --g_dep_tbl(l_index +5 ).attribute  := OE_LINE_UTIL.G_SALESREP;

            /* Added dependency for Bug 2245073 */
              l_index := OE_LINE_UTIL.G_PRICING_DATE * G_MAX;
              g_dep_tbl(l_index).attribute := OE_LINE_UTIL.G_AGREEMENT;
             /* End of 2245073 */

              l_index := OE_LINE_UTIL.G_ACCOUNTING_RULE * G_MAX;
              g_dep_tbl(l_index).attribute := OE_LINE_UTIL.G_ACCOUNTING_RULE_DURATION;


	    l_index := OE_LINE_UTIL.G_INVOICE_TO_ORG * G_MAX ;
	    g_dep_tbl(l_index ).attribute	    := OE_LINE_UTIL.G_PAYMENT_TERM;
	    g_dep_tbl(l_index +1 ).attribute  := OE_LINE_UTIL.G_INVOICE_TO_CONTACT;
	    g_dep_tbl(l_index +2 ).attribute  := OE_LINE_UTIL.G_PRICE_LIST;
	    g_dep_tbl(l_index +3 ).attribute  := OE_LINE_UTIL.G_FOB_POINT;
	    g_dep_tbl(l_index +4 ).attribute  := OE_LINE_UTIL.G_FREIGHT_TERMS;
	    /* Added by Manish */
	    g_dep_tbl(l_index +5 ).attribute   := OE_LINE_UTIL.G_TAX;
	    g_dep_tbl(l_index +6 ).attribute   := OE_LINE_UTIL.G_TAX_EXEMPT_NUMBER;
	    g_dep_tbl(l_index +7 ).attribute   := OE_LINE_UTIL.G_TAX_EXEMPT_REASON;
	    /* Added by Manish */
	    g_dep_tbl(l_index +8).attribute    := OE_LINE_UTIL.G_SHIP_TOLERANCE_BELOW;
	    g_dep_tbl(l_index +9).attribute    := OE_LINE_UTIL.G_SHIP_TOLERANCE_ABOVE;
	    g_dep_tbl(l_index +10).attribute    := OE_LINE_UTIL.G_SALESREP;

	    l_index := OE_LINE_UTIL.G_SOLD_TO_ORG * G_MAX ;
	    g_dep_tbl(l_index ).attribute	    := OE_LINE_UTIL.G_PAYMENT_TERM;
	    g_dep_tbl(l_index +1 ).attribute  := OE_LINE_UTIL.G_INVOICE_TO_ORG;
	    g_dep_tbl(l_index +2 ).attribute  := OE_LINE_UTIL.G_PRICE_LIST;
	    g_dep_tbl(l_index +3 ).attribute  := OE_LINE_UTIL.G_FOB_POINT;
	    g_dep_tbl(l_index +4 ).attribute  := OE_LINE_UTIL.G_FREIGHT_TERMS;
	    g_dep_tbl(l_index +5 ).attribute  := OE_LINE_UTIL.G_DELIVER_TO_ORG;
	    g_dep_tbl(l_index +6 ).attribute  := OE_LINE_UTIL.G_SHIP_TO_ORG;
	    -- Added by Manish
	    g_dep_tbl(l_index +7 ).attribute  := OE_LINE_UTIL.G_TAX_EXEMPT_NUMBER;
	    g_dep_tbl(l_index +8 ).attribute  := OE_LINE_UTIL.G_TAX_EXEMPT_REASON;
	    -- Added by Manish
	    g_dep_tbl(l_index +9 ).attribute  := OE_LINE_UTIL.G_SHIP_FROM_ORG;
	    g_dep_tbl(l_index +10 ).attribute  := OE_LINE_UTIL.G_SALESREP;
	    g_dep_tbl(l_index +11 ).attribute  := OE_LINE_UTIL.G_SHIPPING_METHOD;
	  --g_dep_tbl(l_index +12 ).attribute  := OE_LINE_UTIL.G_COMMITMENT;
	    g_dep_tbl(l_index +12 ).attribute := OE_LINE_UTIL.G_SHIP_TOLERANCE_BELOW;
	    g_dep_tbl(l_index +13 ).attribute := OE_LINE_UTIL.G_SHIP_TOLERANCE_ABOVE;
	    g_dep_tbl(l_index +14 ).attribute := OE_LINE_UTIL.G_ITEM_IDENTIFIER_TYPE;

	    l_index := OE_LINE_UTIL.G_PRICE_LIST * G_MAX ;
	    g_dep_tbl(l_index ).attribute	    := OE_LINE_UTIL.G_PAYMENT_TERM;
	    g_dep_tbl(l_index +1 ).attribute  := OE_LINE_UTIL.G_FREIGHT_TERMS;
	    --g_dep_tbl(l_index +2 ).attribute  := OE_LINE_UTIL.G_UNIT_LIST_PRICE;

	    --l_index := OE_LINE_UTIL.G_ORDERED_QUANTITY * G_MAX ;
--	    g_dep_tbl(l_index ).attribute	    := OE_LINE_UTIL.G_QUANTITY_OPEN;
	    --g_dep_tbl(l_index +1 ).attribute  := OE_LINE_UTIL.G_UNIT_LIST_PRICE;
	    --g_dep_tbl(l_index +2 ).attribute  := OE_LINE_UTIL.G_PRICING_QUANTITY;

--       l_index := OE_LINE_UTIL.G_ORDER_QUANTITY_UOM * G_MAX ;
--	    g_dep_tbl(l_index ).attribute	    := OE_LINE_UTIL.G_QUANTITY_OPEN;
	    --g_dep_tbl(l_index  ).attribute  := OE_LINE_UTIL.G_UNIT_LIST_PRICE;
	    --g_dep_tbl(l_index +1 ).attribute  := OE_LINE_UTIL.G_PRICING_QUANTITY_UOM;

--	    l_index := OE_LINE_UTIL.G_SHIPPING_QUANTITY_UOM * G_MAX ;
--	    g_dep_tbl(l_index ).attribute     := OE_LINE_UTIL.G_SHIPPING_QUANTITY;

	    --l_index := OE_LINE_UTIL.G_PRICING_QUANTITY_UOM * G_MAX ;
	    --g_dep_tbl(l_index ).attribute     := OE_LINE_UTIL.G_PRICING_QUANTITY;

	    /* Added by Manish */
	    l_index := OE_LINE_UTIL.G_SCHEDULE_SHIP_DATE * G_MAX ;
	    g_dep_tbl(l_index  ).attribute     := OE_LINE_UTIL.G_TAX_DATE;
	   -- g_dep_tbl(l_index +1).attribute    := OE_LINE_UTIL.G_PROMISE_DATE;

	    l_index := OE_LINE_UTIL.G_PROMISE_DATE * G_MAX ;
	    g_dep_tbl(l_index  ).attribute     := OE_LINE_UTIL.G_TAX_DATE;

	    l_index := OE_LINE_UTIL.G_REQUEST_DATE * G_MAX ;
	    g_dep_tbl(l_index  ).attribute     := OE_LINE_UTIL.G_TAX_DATE;

	    l_index := OE_LINE_UTIL.G_TAX_DATE * G_MAX ;
	    g_dep_tbl(l_index  ).attribute     := OE_LINE_UTIL.G_TAX;
	    g_dep_tbl(l_index +1 ).attribute   := OE_LINE_UTIL.G_TAX_EXEMPT_NUMBER;
	    g_dep_tbl(l_index +2 ).attribute   := OE_LINE_UTIL.G_TAX_EXEMPT_REASON;

           -- commented out by lkxu
	   -- l_index := OE_LINE_UTIL.G_INVOICED_FLAG * G_MAX ;
	   -- g_dep_tbl(l_index  ).attribute     := OE_LINE_UTIL.G_CALCULATE_PRICE_FLAG;

	    l_index := OE_LINE_UTIL.G_SHIP_TO_ORG * G_MAX ;
	    g_dep_tbl(l_index  ).attribute     := OE_LINE_UTIL.G_TAX;
	    g_dep_tbl(l_index +1 ).attribute   := OE_LINE_UTIL.G_TAX_EXEMPT_NUMBER;
	    g_dep_tbl(l_index +2 ).attribute   := OE_LINE_UTIL.G_TAX_EXEMPT_REASON;
	    g_dep_tbl(l_index +3).attribute    := OE_LINE_UTIL.G_SHIP_TOLERANCE_ABOVE;
	    g_dep_tbl(l_index +4).attribute    := OE_LINE_UTIL.G_SHIP_TOLERANCE_BELOW;
	    g_dep_tbl(l_index +5).attribute    := OE_LINE_UTIL.G_SALESREP;
	    g_dep_tbl(l_index +6).attribute    := OE_LINE_UTIL.G_DEMAND_CLASS;
	    g_dep_tbl(l_index +7).attribute    := OE_LINE_UTIL.G_SHIP_FROM_ORG;
	    g_dep_tbl(l_index +8 ).attribute  := OE_LINE_UTIL.G_PAYMENT_TERM;
	    g_dep_tbl(l_index +9 ).attribute  := OE_LINE_UTIL.G_PRICE_LIST;
	    g_dep_tbl(l_index +10 ).attribute  := OE_LINE_UTIL.G_INVOICE_TO_ORG;
	    g_dep_tbl(l_index +11 ).attribute  := OE_LINE_UTIL.G_FOB_POINT;
	    g_dep_tbl(l_index +12 ).attribute  := OE_LINE_UTIL.G_FREIGHT_TERMS;
	    g_dep_tbl(l_index +13 ).attribute  := OE_LINE_UTIL.G_SHIPPING_METHOD;
	    g_dep_tbl(l_index +14 ).attribute := OE_LINE_UTIL.G_ITEM_IDENTIFIER_TYPE;
	    g_dep_tbl(l_index +15 ).attribute := OE_LINE_UTIL.G_SHIP_TO_CONTACT;

	    /* Added by Manish */
	    l_index := OE_LINE_UTIL.G_TAX_EXEMPT * G_MAX ;
	    g_dep_tbl(l_index    ).attribute   := OE_LINE_UTIL.G_TAX_EXEMPT_NUMBER;
	    g_dep_tbl(l_index +1 ).attribute   := OE_LINE_UTIL.G_TAX_EXEMPT_REASON;
            -- added by linda
	    g_dep_tbl(l_index +2 ).attribute   := OE_LINE_UTIL.G_TAX;

	    l_index := OE_LINE_UTIL.G_TAX * G_MAX ;
	    g_dep_tbl(l_index    ).attribute   := OE_LINE_UTIL.G_TAX_EXEMPT_NUMBER;
	    g_dep_tbl(l_index +1 ).attribute   := OE_LINE_UTIL.G_TAX_EXEMPT_REASON;

	    l_index := OE_LINE_UTIL.G_ORDERED_ITEM_ID * G_MAX ;
	    g_dep_tbl(l_index  ).attribute     := OE_LINE_UTIL.G_DEP_PLAN_REQUIRED;
            -- OPM bug3016136
            g_dep_tbl(l_index +1 ).attribute := OE_LINE_UTIL.G_ORDERED_QUANTITY2;
            g_dep_tbl(l_index +2 ).attribute := OE_LINE_UTIL.G_ORDERED_QUANTITY_UOM2;
            g_dep_tbl(l_index +3).attribute := OE_LINE_UTIL.G_PREFERRED_GRADE;
            -- OPM bug3016136

	    -- Adding for deliver to org . -- Added by Shashi.
	    l_index := OE_LINE_UTIL.G_DELIVER_TO_ORG * G_MAX ;
	    g_dep_tbl(l_index).attribute     := OE_LINE_UTIL.G_DELIVER_TO_CONTACT;

         /* OPM 02/JUN/00 - add process dependencies on whse */
	    l_index := OE_LINE_UTIL.G_SHIP_FROM_ORG * G_MAX ;

	    -- fix for bug 1773985 - comment out line below and re-order indexes.
--         g_dep_tbl(l_index  ).attribute     := OE_LINE_UTIL.G_PREFERRED_GRADE;
         g_dep_tbl(l_index).attribute   := OE_LINE_UTIL.G_ORDERED_QUANTITY_UOM2;
         g_dep_tbl(l_index +1 ).attribute   := OE_LINE_UTIL.G_SUBINVENTORY;
         -- ## bug fix 1609895
         g_dep_tbl(l_index +2 ).attribute   := OE_LINE_UTIL.G_SHIPPABLE;
         g_dep_tbl(l_index +3 ).attribute   := OE_LINE_UTIL.G_TAX;


         -- BLANKETS: Add dependencies on blanket fields for order line
         IF OE_CODE_CONTROL.Code_Release_Level >= '110509' THEN

	    l_index := OE_LINE_UTIL.G_BLANKET_NUMBER * G_MAX;
	    g_dep_tbl(l_index).attribute := OE_LINE_UTIL.G_SHIPPING_INSTRUCTIONS;
	    g_dep_tbl(l_index+1).attribute := OE_LINE_UTIL.G_PACKING_INSTRUCTIONS;
	    g_dep_tbl(l_index+2).attribute := OE_LINE_UTIL.G_ACCOUNTING_RULE;
	    g_dep_tbl(l_index+3).attribute := OE_LINE_UTIL.G_INVOICING_RULE;
	    g_dep_tbl(l_index+4).attribute := OE_LINE_UTIL.G_SHIP_TO_ORG;
	    g_dep_tbl(l_index+5).attribute := OE_LINE_UTIL.G_INVOICE_TO_ORG;
	    g_dep_tbl(l_index+6).attribute := OE_LINE_UTIL.G_DELIVER_TO_ORG;
	    g_dep_tbl(l_index+7).attribute := OE_LINE_UTIL.G_SHIP_FROM_ORG;
	    g_dep_tbl(l_index+8).attribute := OE_LINE_UTIL.G_PAYMENT_TERM;
	    g_dep_tbl(l_index+9).attribute := OE_LINE_UTIL.G_PRICE_LIST;
	    g_dep_tbl(l_index+10).attribute := OE_LINE_UTIL.G_SHIPPING_METHOD;
	    g_dep_tbl(l_index+11).attribute := OE_LINE_UTIL.G_FREIGHT_TERMS;
	    g_dep_tbl(l_index+12).attribute := OE_LINE_UTIL.G_SALESREP;
            -- bug 2766005, enabled grade defaulting from blanket line
	    g_dep_tbl(l_index+13).attribute := OE_LINE_UTIL.G_PREFERRED_GRADE;
	    g_dep_tbl(l_index+14).attribute := OE_LINE_UTIL.G_BLANKET_VERSION_NUMBER;

	    l_index := OE_LINE_UTIL.G_BLANKET_LINE_NUMBER * G_MAX;
	    g_dep_tbl(l_index).attribute := OE_LINE_UTIL.G_ACCOUNTING_RULE;
	    g_dep_tbl(l_index+1).attribute := OE_LINE_UTIL.G_INVOICING_RULE;
	    g_dep_tbl(l_index+2).attribute := OE_LINE_UTIL.G_SHIP_TO_ORG;
	    g_dep_tbl(l_index+3).attribute := OE_LINE_UTIL.G_INVOICE_TO_ORG;
	    g_dep_tbl(l_index+4).attribute := OE_LINE_UTIL.G_DELIVER_TO_ORG;
	    g_dep_tbl(l_index+5).attribute := OE_LINE_UTIL.G_SHIP_FROM_ORG;
	    g_dep_tbl(l_index+6).attribute := OE_LINE_UTIL.G_PAYMENT_TERM;
	    g_dep_tbl(l_index+7).attribute := OE_LINE_UTIL.G_PRICE_LIST;
	    g_dep_tbl(l_index+8).attribute := OE_LINE_UTIL.G_SHIPPING_METHOD;
	    g_dep_tbl(l_index+9).attribute := OE_LINE_UTIL.G_FREIGHT_TERMS;
	    g_dep_tbl(l_index+10).attribute := OE_LINE_UTIL.G_SALESREP;
	    g_dep_tbl(l_index+11).attribute := OE_LINE_UTIL.G_SHIPPING_INSTRUCTIONS;
	    g_dep_tbl(l_index+12).attribute := OE_LINE_UTIL.G_PACKING_INSTRUCTIONS;
            -- bug 2766005, enabled grade defaulting from blanket line
	    g_dep_tbl(l_index+13).attribute := OE_LINE_UTIL.G_PREFERRED_GRADE;

         END IF; -- end of check of code level for blankets

	 IF OE_CODE_CONTROL.Code_Release_Level >= '110510' THEN
	    --distributed orders
	    l_index := OE_LINE_UTIL.G_END_CUSTOMER * G_MAX ;
	    g_dep_tbl(l_index).attribute   := OE_LINE_UTIL.G_END_CUSTOMER_CONTACT;
	    g_dep_tbl(l_index+1).attribute := OE_LINE_UTIL.G_END_CUSTOMER_SITE_USE;
	 END IF;

	 ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_HEADER_ADJ THEN

	   null;
	   /*
	   l_index	:= OE_HEADER_ADJ_UTIL.G_DISCOUNT * G_MAX;
	   --g_dep_tbl(l_index).attribute := OE_HEADER_ADJ_UTIL.g_discount_line;
	   g_dep_tbl(l_index).attribute := OE_HEADER_ADJ_UTIL.g_percent;


	   l_index	:= OE_HEADER_ADJ_UTIL.G_DISCOUNT_line * g_max;
	   --g_dep_tbl(l_index).attribute := OE_HEADER_ADJ_UTIL.g_discount;
	   g_dep_tbl(l_index+1).attribute := OE_HEADER_ADJ_UTIL.g_percent;

		*/

	 ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_LINE_ADJ THEN
		null;

	   /*
	   l_index	:= OE_LINE_ADJ_UTIL.G_DISCOUNT * G_MAX;
	   --g_dep_tbl(l_index).attribute := OE_LINE_ADJ_UTIL.G_DISCOUNT_LINE;
	   g_dep_tbl(l_index).attribute := OE_LINE_ADJ_UTIL.G_PERCENT;


	   l_index	:= OE_LINE_ADJ_UTIL.G_DISCOUNT_line * g_max;
	   --g_dep_tbl(l_index).attribute := OE_LINE_ADJ_UTIL.g_discount;
	   g_dep_tbl(l_index+1).attribute := OE_LINE_ADJ_UTIL.g_percent;

		*/
--serla begin
         ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_HEADER_PAYMENT THEN

            l_index := OE_HEADER_PAYMENT_UTIL.G_PAYMENT_TYPE_CODE * G_MAX ;
            g_dep_tbl(l_index ).attribute    := OE_HEADER_PAYMENT_UTIL.G_PAYMENT_TRX_ID;
            g_dep_tbl(l_index+1 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_RECEIPT_METHOD_ID;
            g_dep_tbl(l_index+2 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CHECK_NUMBER;
            g_dep_tbl(l_index+3 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_NUMBER;
            g_dep_tbl(l_index+4 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_CODE;
            g_dep_tbl(l_index+5 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_CODE;
            g_dep_tbl(l_index+6 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_DATE;
            g_dep_tbl(l_index+7 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_HOLDER_NAME;
            g_dep_tbl(l_index+8 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_EXPIRATION_DATE;
            g_dep_tbl(l_index+9 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_TANGIBLE_ID;
/*
            l_index := OE_HEADER_PAYMENT_UTIL.G_PAYMENT_TRX_ID * G_MAX ;
            --g_dep_tbl(l_index ).attribute    := OE_HEADER_PAYMENT_UTIL.G_PAYMENT_TYPE_CODE;
            g_dep_tbl(l_index ).attribute  := OE_HEADER_PAYMENT_UTIL.G_RECEIPT_METHOD_ID;
            g_dep_tbl(l_index+1 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CHECK_NUMBER;
            g_dep_tbl(l_index+2 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_NUMBER;
            g_dep_tbl(l_index+3 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_CODE;
            g_dep_tbl(l_index+4 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_CODE;
            g_dep_tbl(l_index+5 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_DATE;
            g_dep_tbl(l_index+6 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_HOLDER_NAME;
            g_dep_tbl(l_index+7 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_EXPIRATION_DATE;
            g_dep_tbl(l_index+8 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_TANGIBLE_ID;
*/
            l_index := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_NUMBER * G_MAX ;
            g_dep_tbl(l_index ).attribute    := OE_HEADER_PAYMENT_UTIL.G_PAYMENT_TRX_ID;
            g_dep_tbl(l_index+1 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_HOLDER_NAME;
            g_dep_tbl(l_index+2 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_EXPIRATION_DATE;
            g_dep_tbl(l_index+3 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_CODE;
            g_dep_tbl(l_index+4 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_DATE;
            g_dep_tbl(l_index+5 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_TANGIBLE_ID;
	    --R12 CC Encryption
	    --The dependent attributes based on credit card code is not required
            /*l_index := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_CODE * G_MAX ;
            g_dep_tbl(l_index ).attribute    := OE_HEADER_PAYMENT_UTIL.G_PAYMENT_TRX_ID;
            g_dep_tbl(l_index+1 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_NUMBER;
            g_dep_tbl(l_index+2 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_CODE;
            g_dep_tbl(l_index+3 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_DATE;
            g_dep_tbl(l_index+4 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_HOLDER_NAME;
            g_dep_tbl(l_index+5 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_EXPIRATION_DATE;
            g_dep_tbl(l_index+6 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_TANGIBLE_ID;*/
	    --R12 CC Encryption
            l_index := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_CODE * G_MAX ;
            g_dep_tbl(l_index ).attribute    := OE_HEADER_PAYMENT_UTIL.G_CHECK_NUMBER;
            g_dep_tbl(l_index+1 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_TANGIBLE_ID;

            l_index := OE_HEADER_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_DATE * G_MAX ;
            g_dep_tbl(l_index ).attribute    := OE_HEADER_PAYMENT_UTIL.G_CHECK_NUMBER;
            g_dep_tbl(l_index+1 ).attribute  := OE_HEADER_PAYMENT_UTIL.G_TANGIBLE_ID;

         ELSIF p_entity_code = OE_GLOBALS.G_ENTITY_LINE_PAYMENT THEN

            l_index := OE_LINE_PAYMENT_UTIL.G_PAYMENT_TYPE_CODE * G_MAX ;
            g_dep_tbl(l_index ).attribute    := OE_LINE_PAYMENT_UTIL.G_PAYMENT_TRX_ID;
            g_dep_tbl(l_index+1 ).attribute  := OE_LINE_PAYMENT_UTIL.G_RECEIPT_METHOD_ID;
            g_dep_tbl(l_index+2 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CHECK_NUMBER;
            g_dep_tbl(l_index+3 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_NUMBER;
            g_dep_tbl(l_index+4 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_CODE;
            g_dep_tbl(l_index+5 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_CODE;
            g_dep_tbl(l_index+6 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_DATE;
            g_dep_tbl(l_index+7 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_HOLDER_NAME;
            g_dep_tbl(l_index+8 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_EXPIRATION_DATE;
            g_dep_tbl(l_index+9 ).attribute  := OE_LINE_PAYMENT_UTIL.G_TANGIBLE_ID;

 /*           l_index := OE_LINE_PAYMENT_UTIL.G_PAYMENT_TRX_ID * G_MAX ;
            --g_dep_tbl(l_index ).attribute    := OE_LINE_PAYMENT_UTIL.G_PAYMENT_TYPE_CODE;
            g_dep_tbl(l_index ).attribute  := OE_LINE_PAYMENT_UTIL.G_RECEIPT_METHOD_ID;
            g_dep_tbl(l_index+1 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CHECK_NUMBER;
            g_dep_tbl(l_index+2 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_NUMBER;
            g_dep_tbl(l_index+3 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_CODE;
            g_dep_tbl(l_index+4 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_CODE;
            g_dep_tbl(l_index+5 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_DATE;
            g_dep_tbl(l_index+6 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_HOLDER_NAME;
            g_dep_tbl(l_index+7 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_EXPIRATION_DATE;
            g_dep_tbl(l_index+8 ).attribute  := OE_LINE_PAYMENT_UTIL.G_TANGIBLE_ID;
*/
            l_index := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_NUMBER * G_MAX ;
            g_dep_tbl(l_index ).attribute    := OE_LINE_PAYMENT_UTIL.G_PAYMENT_TRX_ID;
            g_dep_tbl(l_index+1 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_HOLDER_NAME;
            g_dep_tbl(l_index+2 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_EXPIRATION_DATE;
            g_dep_tbl(l_index+3 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_CODE;
            g_dep_tbl(l_index+4 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_DATE;
            g_dep_tbl(l_index+5 ).attribute  := OE_LINE_PAYMENT_UTIL.G_TANGIBLE_ID;
	    --R12 CC Encryption
	    /*
            l_index := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_CODE * G_MAX ;
            g_dep_tbl(l_index ).attribute    := OE_LINE_PAYMENT_UTIL.G_PAYMENT_TRX_ID;
            g_dep_tbl(l_index+1 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_NUMBER;
            g_dep_tbl(l_index+2 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_CODE;
            g_dep_tbl(l_index+3 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_DATE;
            g_dep_tbl(l_index+4 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_HOLDER_NAME;
            g_dep_tbl(l_index+5 ).attribute  := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_EXPIRATION_DATE;
            g_dep_tbl(l_index+6 ).attribute  := OE_LINE_PAYMENT_UTIL.G_TANGIBLE_ID;*/

            l_index := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_CODE * G_MAX ;
            g_dep_tbl(l_index ).attribute    := OE_LINE_PAYMENT_UTIL.G_CHECK_NUMBER;
            g_dep_tbl(l_index+1 ).attribute  := OE_LINE_PAYMENT_UTIL.G_TANGIBLE_ID;

            l_index := OE_LINE_PAYMENT_UTIL.G_CREDIT_CARD_APPROVAL_DATE * G_MAX ;
            g_dep_tbl(l_index ).attribute    := OE_LINE_PAYMENT_UTIL.G_CHECK_NUMBER;
            g_dep_tbl(l_index+1 ).attribute  := OE_LINE_PAYMENT_UTIL.G_TANGIBLE_ID;

--serla end
	END IF;

        -- Merge any dependencies that user wants to enable/disable via call
        -- to the new extension api - OE_Dependencies_Extn (OEXEDEPS/B.pls)
        Merge_Dependencies_Extn(p_entity_code);

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_DEPENDENCIES.LOAD_ENTITY_ATTRIBUTES' , 1 ) ;
    END IF;

END Load_Entity_Attributes;

--  This procedure should be modified to call itself recursively in
--  order to clear fields dependent on dependent fields.
--  kris - ask Amr why he didn't put the call in
--  is there something he knows that makes it not as easy as it seems?


PROCEDURE   Mark_Dependent
(   p_entity_code	IN  VARCHAR2				,
    p_source_attr_tbl	IN  OE_GLOBALS.Number_Tbl_Type :=
				OE_GLOBALS.G_MISS_NUMBER_TBL	,
p_dep_attr_tbl OUT NOCOPY OE_GLOBALS.Number_Tbl_Type

)
IS
l_index		    NUMBER;
l_out_index	    NUMBER;
l_dep_attr_tbl	    OE_GLOBALS.Number_Tbl_Type;
l_src_attr_tbl	    OE_GLOBALS.Number_Tbl_Type;
l_examined_attr_tbl OE_GLOBALS.Boolean_Tbl_Type;
l_out_attr_tbl	    OE_GLOBALS.Boolean_Tbl_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_DEPENDENCIES.MARK_DEPENDENT' , 1 ) ;
   END IF;

    --	Init l_src_attr_tbl

    l_src_attr_tbl := p_source_attr_tbl;

    --	Load Entity Attributes.

    Load_Entity_Attributes ( p_entity_code );

    --  Loop throughout all attributes and mark dependent
    --  attributes for those requested.

    WHILE l_src_attr_tbl.COUNT <> 0 LOOP

	FOR I IN 1..l_src_attr_tbl.COUNT LOOP

	    l_index := l_src_attr_tbl(I) * G_MAX;

            -- Bug 2318145: If a certain dependency was disabled via extn API
            -- all subsequent dependencies were not being picked up either.
            -- This was because the check for enabled_flag was included in
            -- the WHILE condition and loop did not progress beyond the
            -- disabled dependency.
            -- With this fix, check for enabled is in a separate IF so it
            -- should loop over all dependencies now.

	    WHILE g_dep_tbl.EXISTS(l_index) LOOP

              IF g_dep_tbl(l_index).enabled_flag = 'Y' THEN
               l_dep_attr_tbl(l_dep_attr_tbl.COUNT+1) :=g_dep_tbl(l_index).attribute;
              END IF;

              l_index := l_index +1;

	    END LOOP;

	END LOOP;

	--  Mark attributes that have been examined.

	FOR I IN 1..l_src_attr_tbl.COUNT LOOP
	    l_examined_attr_tbl(l_src_attr_tbl(I)) := TRUE;
	END LOOP;

	--  Clear source attributes table.

	l_src_attr_tbl.DELETE;

	--  Check dependent attributes. If they have been already
	--  examined then no need to re-check them.

	FOR I IN 1..l_dep_attr_tbl.COUNT LOOP

	    l_out_attr_tbl(l_dep_attr_tbl(I)) := TRUE;

	    IF NOT l_examined_attr_tbl.EXISTS(l_dep_attr_tbl(I)) THEN
		l_src_attr_tbl(l_src_attr_tbl.COUNT+1) := l_dep_attr_tbl(I);
	    END IF;

	END LOOP;

    END LOOP;

    --	Load OUT attr table.

    l_index := l_out_attr_tbl.FIRST;
    l_out_index := 1;

    WHILE l_index IS NOT NULL LOOP

	p_dep_attr_tbl(l_out_index) := l_index;
	l_index := l_out_attr_tbl.NEXT(l_index);
	l_out_index := l_out_index + 1;

    END LOOP;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_DEPENDENCIES.MARK_DEPENDENT' , 1 ) ;
    END IF;

END Mark_Dependent;


PROCEDURE   clear_dependent_table
  IS
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_DEPENDENCIES.CLEAR_DEPENDENT_TABLE' , 1 ) ;
   END IF;

   g_dep_tbl.DELETE;
   g_entity_code := NULL;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING OE_DEPENDENCIES.CLEAR_DEPENDENT_TABLE' , 1 ) ;
   END IF;

END clear_dependent_table;


END OE_Dependencies;

/
