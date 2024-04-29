--------------------------------------------------------
--  DDL for Package Body OE_VERSION_BLANKET_COMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VERSION_BLANKET_COMP" AS
/* $Header: OEXBCOMB.pls 120.3 2006/04/07 00:15:10 mbhoumik noship $ */

PROCEDURE QUERY_HEADER_ROW
(p_header_id	                  NUMBER,
 p_version	                  NUMBER,
 p_phase_change_flag              VARCHAR2,
 x_header_rec                     IN OUT NOCOPY OE_Blanket_PUB.Header_Rec_Type)
IS
l_org_id                NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
 oe_debug_pub.add('l_debug_level'||l_debug_level );
IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering OE_VERSION_BLANKET_COMP.QUERY_HEADER_ROW'||p_version );
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('version' ||p_version);
  oe_debug_pub.add('phase_change_flag' ||p_phase_change_flag);
END IF;
    l_org_id := OE_GLOBALS.G_ORG_ID;

    IF l_org_id IS NULL THEN
      OE_GLOBALS.Set_Context;
      l_org_id := OE_GLOBALS.G_ORG_ID;
    END IF;

    SELECT  ACCOUNTING_RULE_ID
    ,       AGREEMENT_ID
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE16
    ,       ATTRIBUTE17
    ,       ATTRIBUTE18
    ,       ATTRIBUTE19
    ,       ATTRIBUTE20
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CUST_PO_NUMBER
    ,       DELIVER_TO_ORG_ID
    ,       FREIGHT_TERMS_CODE
    ,       header_id
    ,       INVOICE_TO_ORG_ID
    ,       INVOICING_RULE_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       bh.ORDER_NUMBER
    ,       ORDER_TYPE_ID
    ,       ORG_ID
    ,       PAYMENT_TERM_ID
    ,       PRICE_LIST_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       SALESREP_ID
    ,       SHIPPING_METHOD_CODE
    ,       ship_from_org_id
    ,       SHIP_TO_ORG_ID
    ,       SOLD_TO_CONTACT_ID
    ,       SOLD_TO_ORG_ID
    ,       TRANSACTIONAL_CURR_CODE
    ,       conversion_type_code
    ,       LOCK_CONTROL
    ,       VERSION_NUMBER
    ,       SHIPPING_INSTRUCTIONS
    ,       PACKING_INSTRUCTIONS
    ,       START_DATE_ACTIVE
    ,       END_DATE_ACTIVE
    ,       on_hold_flag
    ,       ENFORCE_PRICE_LIST_FLAG
    ,       enforce_ship_to_flag
    ,       enforce_invoice_to_flag
    ,       enforce_freight_term_flag
    ,       enforce_shipping_method_flag
    ,       enforce_payment_term_flag
    ,       enforce_accounting_rule_flag
    ,       enforce_invoicing_rule_flag
    ,       OVERRIDE_AMOUNT_FLAG
    ,       BLANKET_MAX_AMOUNT
    ,       BLANKET_MIN_AMOUNT
    ,       RELEASED_AMOUNT
    ,       FULFILLED_AMOUNT
    ,       RETURNED_AMOUNT
    ,       source_document_id
    ,       source_document_type_id
    ,       SALES_DOCUMENT_NAME
    ,       TRANSACTION_PHASE_CODE
    ,       USER_STATUS_CODE
    ,       FLOW_STATUS_CODE
    ,	    SUPPLIER_SIGNATURE
    ,	    SUPPLIER_SIGNATURE_DATE
    ,	    CUSTOMER_SIGNATURE
    ,	    CUSTOMER_SIGNATURE_DATE
    ,       sold_to_site_use_id
    ,       draft_submitted_flag
    ,       source_document_version_number
    ,       new_price_list_id
    ,       new_modifier_list_id
    ,       default_discount_percent
    ,       default_discount_amount
    INTO x_header_rec.ACCOUNTING_RULE_ID
    ,x_header_rec.AGREEMENT_ID
    ,x_header_rec.ATTRIBUTE1
    ,x_header_rec.ATTRIBUTE10
    ,x_header_rec.ATTRIBUTE11
    ,x_header_rec.ATTRIBUTE12
    ,x_header_rec.ATTRIBUTE13
    ,x_header_rec.ATTRIBUTE14
    ,x_header_rec.ATTRIBUTE15
    ,x_header_rec.ATTRIBUTE16
    ,x_header_rec.ATTRIBUTE17
    ,x_header_rec.ATTRIBUTE18
    ,x_header_rec.ATTRIBUTE19
    ,x_header_rec.ATTRIBUTE20
    ,x_header_rec.ATTRIBUTE2
    ,x_header_rec.ATTRIBUTE3
    ,x_header_rec.ATTRIBUTE4
    ,x_header_rec.ATTRIBUTE5
    ,x_header_rec.ATTRIBUTE6
    ,x_header_rec.ATTRIBUTE7
    ,x_header_rec.ATTRIBUTE8
    ,x_header_rec.ATTRIBUTE9
    ,x_header_rec.CONTEXT
    ,x_header_rec.CREATED_BY
    ,x_header_rec.CREATION_DATE
    ,x_header_rec.CUST_PO_NUMBER
    ,x_header_rec.DELIVER_TO_ORG_ID
    ,x_header_rec.FREIGHT_TERMS_CODE
    ,x_header_rec.header_id
    ,x_header_rec.INVOICE_TO_ORG_ID
    ,x_header_rec.INVOICING_RULE_ID
    ,x_header_rec.LAST_UPDATED_BY
    ,x_header_rec.LAST_UPDATE_DATE
    ,x_header_rec.LAST_UPDATE_LOGIN
    ,x_header_rec.ORDER_NUMBER
    ,x_header_rec.ORDER_TYPE_ID
    ,x_header_rec.ORG_ID
    ,x_header_rec.PAYMENT_TERM_ID
    ,x_header_rec.PRICE_LIST_ID
    ,x_header_rec.PROGRAM_APPLICATION_ID
    ,x_header_rec.PROGRAM_ID
    ,x_header_rec.PROGRAM_UPDATE_DATE
    ,x_header_rec.REQUEST_ID
    ,x_header_rec.SALESREP_ID
    ,x_header_rec.SHIPPING_METHOD_CODE
    ,x_header_rec.ship_from_org_id
    ,x_header_rec.SHIP_TO_ORG_ID
    ,x_header_rec.SOLD_TO_CONTACT_ID
    ,x_header_rec.SOLD_TO_ORG_ID
    ,x_header_rec.TRANSACTIONAL_CURR_CODE
    ,x_header_rec.conversion_type_code
    ,x_header_rec.LOCK_CONTROL
    ,x_header_rec.VERSION_NUMBER
    ,x_header_rec.SHIPPING_INSTRUCTIONS
    ,x_header_rec.PACKING_INSTRUCTIONS
    ,x_header_rec.START_DATE_ACTIVE
    ,x_header_rec.END_DATE_ACTIVE
    ,x_header_rec.on_hold_flag
    ,x_header_rec.ENFORCE_PRICE_LIST_FLAG
    ,x_header_rec.enforce_ship_to_flag
    ,x_header_rec.enforce_invoice_to_flag
    ,x_header_rec.enforce_freight_term_flag
    ,x_header_rec.enforce_shipping_method_flag
    ,x_header_rec.enforce_payment_term_flag
    ,x_header_rec.enforce_accounting_rule_flag
    ,x_header_rec.enforce_invoicing_rule_flag
    ,x_header_rec.OVERRIDE_AMOUNT_FLAG
    ,x_header_rec.BLANKET_MAX_AMOUNT
    ,x_header_rec.BLANKET_MIN_AMOUNT
    ,x_header_rec.RELEASED_AMOUNT
    ,x_header_rec.FULFILLED_AMOUNT
    ,x_header_rec.RETURNED_AMOUNT
    ,x_header_rec.source_document_id
    ,x_header_rec.source_document_type_id
    ,x_header_rec.SALES_DOCUMENT_NAME
    ,x_header_rec.TRANSACTION_PHASE_CODE
    ,x_header_rec.USER_STATUS_CODE
    ,x_header_rec.FLOW_STATUS_CODE
    ,x_header_rec.SUPPLIER_SIGNATURE
    ,x_header_rec.SUPPLIER_SIGNATURE_DATE
    ,x_header_rec.CUSTOMER_SIGNATURE
    ,x_header_rec.CUSTOMER_SIGNATURE_DATE
    ,x_header_rec.sold_to_site_use_id
    ,x_header_rec.draft_submitted_flag
    ,x_header_rec.source_document_version_number
    ,x_header_rec.new_price_list_id
    ,x_header_rec.new_modifier_list_id
    ,x_header_rec.default_discount_percent
    ,x_header_rec.default_discount_amount
    FROM    OE_BLANKET_HEADERS_HIST bh
    WHERE   bh.header_id                = p_header_id
      AND   bh.sales_document_type_code = 'B'
      AND   bh.version_number           = p_version
     AND    (PHASE_CHANGE_FLAG = p_phase_change_flag
     OR     (nvl(p_phase_change_flag, 'NULL') <> 'Y'
     AND     VERSION_FLAG = 'Y'));

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	 null;
    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
               'Query_HEADER_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END QUERY_HEADER_ROW;

PROCEDURE QUERY_HEADER_TRANS_ROW
(p_header_id	                  NUMBER,
 p_version	                  NUMBER,
 x_header_rec                     IN OUT NOCOPY OE_Blanket_PUB.Header_Rec_Type)
IS
l_org_id                NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering OE_BLKT_VERSION_COMPARISION.QUERY_HEADER_TRANS_ROW');
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('version' ||p_version);
END IF;
    l_org_id := OE_GLOBALS.G_ORG_ID;

    IF l_org_id IS NULL THEN
      OE_GLOBALS.Set_Context;
      l_org_id := OE_GLOBALS.G_ORG_ID;
    END IF;


    SELECT  ACCOUNTING_RULE_ID
    ,       AGREEMENT_ID
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE16
    ,       ATTRIBUTE17
    ,       ATTRIBUTE18
    ,       ATTRIBUTE19
    ,       ATTRIBUTE20
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CUST_PO_NUMBER
    ,       DELIVER_TO_ORG_ID
    ,       FREIGHT_TERMS_CODE
    ,       header_id
    ,       INVOICE_TO_ORG_ID
    ,       INVOICING_RULE_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       bh.ORDER_NUMBER
    ,       ORDER_TYPE_ID
    ,       ORG_ID
    ,       PAYMENT_TERM_ID
    ,       PRICE_LIST_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       SALESREP_ID
    ,       SHIPPING_METHOD_CODE
    ,       ship_from_org_id
    ,       SHIP_TO_ORG_ID
    ,       SOLD_TO_CONTACT_ID
    ,       SOLD_TO_ORG_ID
    ,       TRANSACTIONAL_CURR_CODE
    ,       conversion_type_code
    ,       LOCK_CONTROL
    ,       VERSION_NUMBER
    ,       SHIPPING_INSTRUCTIONS
    ,       PACKING_INSTRUCTIONS
    ,       START_DATE_ACTIVE
    ,       END_DATE_ACTIVE
    ,       on_hold_flag
    ,       ENFORCE_PRICE_LIST_FLAG
    ,       enforce_ship_to_flag
    ,       enforce_invoice_to_flag
    ,       enforce_freight_term_flag
    ,       enforce_shipping_method_flag
    ,       enforce_payment_term_flag
    ,       enforce_accounting_rule_flag
    ,       enforce_invoicing_rule_flag
    ,       OVERRIDE_AMOUNT_FLAG
    ,       BLANKET_MAX_AMOUNT
    ,       BLANKET_MIN_AMOUNT
    ,       RELEASED_AMOUNT
    ,       FULFILLED_AMOUNT
    ,       RETURNED_AMOUNT
    ,       source_document_id
    ,       source_document_type_id
    ,       SALES_DOCUMENT_NAME
    ,       TRANSACTION_PHASE_CODE
    ,       USER_STATUS_CODE
    ,       FLOW_STATUS_CODE
    ,	    SUPPLIER_SIGNATURE
    ,	    SUPPLIER_SIGNATURE_DATE
    ,	    CUSTOMER_SIGNATURE
    ,	    CUSTOMER_SIGNATURE_DATE
    ,       sold_to_site_use_id
    ,       draft_submitted_flag
    ,       source_document_version_number
    ,       new_price_list_id
    ,       new_modifier_list_id
    ,       default_discount_percent
    ,       default_discount_amount
    INTO
    x_header_rec.ACCOUNTING_RULE_ID
    ,x_header_rec.AGREEMENT_ID
    ,x_header_rec.ATTRIBUTE1
    ,x_header_rec.ATTRIBUTE10
    ,x_header_rec.ATTRIBUTE11
    ,x_header_rec.ATTRIBUTE12
    ,x_header_rec.ATTRIBUTE13
    ,x_header_rec.ATTRIBUTE14
    ,x_header_rec.ATTRIBUTE15
    ,x_header_rec.ATTRIBUTE16
    ,x_header_rec.ATTRIBUTE17
    ,x_header_rec.ATTRIBUTE18
    ,x_header_rec.ATTRIBUTE19
    ,x_header_rec.ATTRIBUTE20
    ,x_header_rec.ATTRIBUTE2
    ,x_header_rec.ATTRIBUTE3
    ,x_header_rec.ATTRIBUTE4
    ,x_header_rec.ATTRIBUTE5
    ,x_header_rec.ATTRIBUTE6
    ,x_header_rec.ATTRIBUTE7
    ,x_header_rec.ATTRIBUTE8
    ,x_header_rec.ATTRIBUTE9
    ,x_header_rec.CONTEXT
    ,x_header_rec.CREATED_BY
    ,x_header_rec.CREATION_DATE
    ,x_header_rec.CUST_PO_NUMBER
    ,x_header_rec.DELIVER_TO_ORG_ID
    ,x_header_rec.FREIGHT_TERMS_CODE
    ,x_header_rec.header_id
    ,x_header_rec.INVOICE_TO_ORG_ID
    ,x_header_rec.INVOICING_RULE_ID
    ,x_header_rec.LAST_UPDATED_BY
    ,x_header_rec.LAST_UPDATE_DATE
    ,x_header_rec.LAST_UPDATE_LOGIN
    ,x_header_rec.ORDER_NUMBER
    ,x_header_rec.ORDER_TYPE_ID
    ,x_header_rec.ORG_ID
    ,x_header_rec.PAYMENT_TERM_ID
    ,x_header_rec.PRICE_LIST_ID
    ,x_header_rec.PROGRAM_APPLICATION_ID
    ,x_header_rec.PROGRAM_ID
    ,x_header_rec.PROGRAM_UPDATE_DATE
    ,x_header_rec.REQUEST_ID
    ,x_header_rec.SALESREP_ID
    ,x_header_rec.SHIPPING_METHOD_CODE
    ,x_header_rec.ship_from_org_id
    ,x_header_rec.SHIP_TO_ORG_ID
    ,x_header_rec.SOLD_TO_CONTACT_ID
    ,x_header_rec.SOLD_TO_ORG_ID
    ,x_header_rec.TRANSACTIONAL_CURR_CODE
    ,x_header_rec.conversion_type_code
    ,x_header_rec.LOCK_CONTROL
    ,x_header_rec.VERSION_NUMBER
    ,x_header_rec.SHIPPING_INSTRUCTIONS
    ,x_header_rec.PACKING_INSTRUCTIONS
    ,x_header_rec.START_DATE_ACTIVE
    ,x_header_rec.END_DATE_ACTIVE
    ,x_header_rec.on_hold_flag
    ,x_header_rec.ENFORCE_PRICE_LIST_FLAG
    ,x_header_rec.enforce_ship_to_flag
    ,x_header_rec.enforce_invoice_to_flag
    ,x_header_rec.enforce_freight_term_flag
    ,x_header_rec.enforce_shipping_method_flag
    ,x_header_rec.enforce_payment_term_flag
    ,x_header_rec.enforce_accounting_rule_flag
    ,x_header_rec.enforce_invoicing_rule_flag
    ,x_header_rec.OVERRIDE_AMOUNT_FLAG
    ,x_header_rec.BLANKET_MAX_AMOUNT
    ,x_header_rec.BLANKET_MIN_AMOUNT
    ,x_header_rec.RELEASED_AMOUNT
    ,x_header_rec.FULFILLED_AMOUNT
    ,x_header_rec.RETURNED_AMOUNT
    ,x_header_rec.source_document_id
    ,x_header_rec.source_document_type_id
    ,x_header_rec.SALES_DOCUMENT_NAME
    ,x_header_rec.TRANSACTION_PHASE_CODE
    ,x_header_rec.USER_STATUS_CODE
    ,x_header_rec.FLOW_STATUS_CODE
    ,x_header_rec. SUPPLIER_SIGNATURE
    ,x_header_rec.SUPPLIER_SIGNATURE_DATE
    ,x_header_rec.CUSTOMER_SIGNATURE
    ,x_header_rec.CUSTOMER_SIGNATURE_DATE
    ,x_header_rec.sold_to_site_use_id
    ,x_header_rec.draft_submitted_flag
    ,x_header_rec.source_document_version_number
    ,x_header_rec.new_price_list_id
    ,x_header_rec.new_modifier_list_id
    ,x_header_rec.default_discount_percent
    ,x_header_rec.default_discount_amount
    FROM    OE_BLANKET_HEADERS bh, OE_BLANKET_HEADERS_EXT bhx
    WHERE   bh.order_number             = bhx.order_number
    AND     bh.sales_document_type_code = 'B'
    AND     bh.HEADER_ID                = p_header_id
    AND     bh.VERSION_NUMBER           = p_version;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	 null;
    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
               'Query_HEADER_TRANS_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END QUERY_HEADER_TRANS_ROW;

PROCEDURE COMPARE_HEADER_VERSIONS
(p_header_id	                  NUMBER,
 p_prior_version                  NUMBER,
 p_current_version                NUMBER,
 p_next_version                   NUMBER,
 g_max_version                    NUMBER,
 g_trans_version                  NUMBER,
 g_prior_phase_change_flag        VARCHAR2,
 g_curr_phase_change_flag         VARCHAR2,
 g_next_phase_change_flag         VARCHAR2,
 x_header_changed_attr_tbl        IN OUT NOCOPY OE_VERSION_BLANKET_COMP.header_tbl_type)
IS
p_curr_rec                       OE_Blanket_PUB.Header_Rec_Type;
p_next_rec                       OE_Blanket_PUB.Header_Rec_Type;
p_prior_rec                      OE_Blanket_PUB.Header_Rec_Type;


v_totcol NUMBER:=10;
v_header_col VARCHAR2(50);
ind NUMBER;
prior_exists VARCHAR2(1) := 'N';
j NUMBER;

x_deliver_to_address1          VARCHAR2(240);
x_deliver_to_address2          VARCHAR2(240);
x_deliver_to_address3          VARCHAR2(240);
x_deliver_to_address4          VARCHAR2(240);
x_deliver_to_location          VARCHAR2(240);
x_deliver_to_org               VARCHAR2(240);
x_deliver_to_city              VARCHAR2(240);
x_deliver_to_state             VARCHAR2(240);
x_deliver_to_postal_code       VARCHAR2(240);
x_deliver_to_country           VARCHAR2(240);
x_prior_deliver_to_address           VARCHAR2(2000);
x_current_deliver_to_address           VARCHAR2(2000);
x_next_deliver_to_address           VARCHAR2(2000);
x_invoice_to_address1          VARCHAR2(240);
x_invoice_to_address2          VARCHAR2(240);
x_invoice_to_address3          VARCHAR2(240);
x_invoice_to_address4          VARCHAR2(240);
x_invoice_to_location          VARCHAR2(240);
x_invoice_to_org               VARCHAR2(240);
x_invoice_to_city              VARCHAR2(240);
x_invoice_to_state             VARCHAR2(240);
x_invoice_to_postal_code       VARCHAR2(240);
x_invoice_to_country           VARCHAR2(240);
x_prior_invoice_to_address           VARCHAR2(2000);
x_current_invoice_to_address           VARCHAR2(2000);
x_next_invoice_to_address           VARCHAR2(2000);
x_ship_to_address1          VARCHAR2(240);
x_ship_to_address2          VARCHAR2(240);
x_ship_to_address3          VARCHAR2(240);
x_ship_to_address4          VARCHAR2(240);
x_ship_to_location          VARCHAR2(240);
x_ship_to_org               VARCHAR2(240);
x_ship_to_city              VARCHAR2(240);
x_ship_to_state             VARCHAR2(240);
x_ship_to_postal_code       VARCHAR2(240);
x_ship_to_country           VARCHAR2(240);
x_prior_ship_to_address           VARCHAR2(2000);
x_current_ship_to_address           VARCHAR2(2000);
x_next_ship_to_address           VARCHAR2(2000);
x_ship_from_address1          VARCHAR2(240);
x_ship_from_address2          VARCHAR2(240);
x_ship_from_address3          VARCHAR2(240);
x_ship_from_address4          VARCHAR2(240);
x_ship_from_location          VARCHAR2(240);
x_prior_ship_from_org               VARCHAR2(240);
x_current_ship_from_org               VARCHAR2(240);
x_next_ship_from_org               VARCHAR2(240);
x_ship_from_address           VARCHAR2(2000);
x_ship_from_address           VARCHAR2(2000);
x_ship_from_address           VARCHAR2(2000);
x_prior_customer_name               VARCHAR2(360);
x_current_customer_name               VARCHAR2(360);
x_next_customer_name               VARCHAR2(360);
x_customer_number             VARCHAR2(100);
x_sold_to_location_address1          VARCHAR2(240);
x_sold_to_location_address2          VARCHAR2(240);
x_sold_to_location_address3          VARCHAR2(240);
x_sold_to_location_address4          VARCHAR2(240);
x_sold_to_location                   VARCHAR2(240);
x_sold_to_location_city              VARCHAR2(240);
x_sold_to_location_state             VARCHAR2(240);
x_sold_to_location_postal_code       VARCHAR2(240);
x_sold_to_location_country           VARCHAR2(240);
x_prior_sold_to_location             VARCHAR2(2000);
x_current_sold_to_location           VARCHAR2(2000);
x_next_sold_to_location              VARCHAR2(2000);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering  COMPARE_HEADER_VERSIONS');
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('prior version' ||p_prior_version);
  oe_debug_pub.add('current version' ||p_current_version);
  oe_debug_pub.add('next version' ||p_next_version);
  oe_debug_pub.add('max version' ||g_max_version);
  oe_debug_pub.add('trans version' ||g_trans_version);
  oe_debug_pub.add('prior phase chagne' ||g_prior_phase_change_flag);
  oe_debug_pub.add('curr phase chagne' ||g_curr_phase_change_flag);
  oe_debug_pub.add('next phase chagne' ||g_next_phase_change_flag);
END IF;

IF l_debug_level > 0 THEN
  oe_debug_pub.add(' Querying prior version details');
  oe_debug_pub.add('prior_versio' ||p_prior_version);
END IF;
IF p_prior_version IS NOT NULL THEN
OE_VERSION_BLANKET_COMP.QUERY_HEADER_ROW(p_header_id       => p_header_id,
			  p_version                        => p_prior_version,
                          p_phase_change_flag              => g_prior_phase_change_flag,
			  x_header_rec                     => p_prior_rec);
END IF;
IF l_debug_level > 0 THEN
  oe_debug_pub.add(' Querying current version details');
  oe_debug_pub.add('current_versio' ||p_current_version);
END IF;
IF p_current_version IS NOT NULL THEN
OE_VERSION_BLANKET_COMP.QUERY_HEADER_ROW(p_header_id       => p_header_id,
                          p_version                        => p_current_version,
                          p_phase_change_flag              => g_curr_phase_change_flag,
                          x_header_rec                     => p_curr_rec);
END IF;
IF l_debug_level > 0 THEN
  oe_debug_pub.add(' Querying next/trans version details');
  oe_debug_pub.add('next_version' ||p_next_version);
  oe_debug_pub.add('trans_version' ||g_trans_version);
END IF;
IF p_next_version = g_trans_version then
       IF g_trans_version is not null then
       OE_VERSION_BLANKET_COMP.QUERY_HEADER_TRANS_ROW(p_header_id       => p_header_id,
                          p_version                                     => g_trans_version,
                          x_header_rec                                  => p_next_rec);
        END IF;
ELSE
      IF p_next_version IS NOT NULL THEN
OE_VERSION_BLANKET_COMP.QUERY_HEADER_ROW(p_header_id       => p_header_id,
                          p_version                        => p_next_version,
                          p_phase_change_flag              => g_next_phase_change_flag,
                          x_header_rec                     => p_next_rec);
     END IF;
END IF;
/*
dbms_output.put_line(' prior' ||p_prior_rec.ship_from_org_id);
dbms_output.put_line(' curr' ||p_curr_rec.ship_from_org_id);
dbms_output.put_line(' next' ||p_next_rec.ship_from_org_id);
*/
IF v_totcol > 0 THEN
ind:=0;
IF l_debug_level > 0 THEN
  oe_debug_pub.add('******BEFORE COMPARING HEADER ATTRIBUTES*************');
  oe_debug_pub.add('current ind '|| ind);
END IF;

/****************************/
/* START ACCOUNTING_RULE_ID*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.accounting_rule_id,
       p_prior_rec.accounting_rule_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'accounting_rule';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.accounting_rule_id;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Accounting_Rule(p_curr_rec.accounting_rule_id);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.accounting_rule_id;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Accounting_rule(p_prior_rec.accounting_rule_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.accounting_rule_id,
       p_next_rec.accounting_rule_id) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Accounting_Rule(p_curr_rec.accounting_rule_id);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'accounting_rule';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.accounting_rule_id;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Accounting_rule(p_prior_rec.accounting_rule_id);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.accounting_rule_id;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Accounting_Rule(p_curr_rec.accounting_rule_id);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.accounting_rule_id;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Accounting_Rule(p_next_rec.accounting_rule_id);
END IF;
END IF; /*  NEXT */

/* END ACCOUNTING_RULE_ID*/
/****************************/

/****************************/
/* START PAYMENT_TERM_ID*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.PAYMENT_TERM_ID,
       p_prior_rec.PAYMENT_TERM_ID) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'terms';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.PAYMENT_TERM_ID;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.PAYMENT_TERM(p_curr_rec.PAYMENT_TERM_ID);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.PAYMENT_TERM_ID;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.PAYMENT_TERM(p_prior_rec.PAYMENT_TERM_ID);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.PAYMENT_TERM_ID,
       p_next_rec.PAYMENT_TERM_ID) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.PAYMENT_TERM(p_curr_rec.PAYMENT_TERM_ID);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'terms';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.PAYMENT_TERM_ID;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.PAYMENT_TERM(p_prior_rec.PAYMENT_TERM_ID);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.PAYMENT_TERM_ID;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.PAYMENT_TERM(p_curr_rec.PAYMENT_TERM_ID);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.PAYMENT_TERM_ID;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.PAYMENT_TERM(p_next_rec.PAYMENT_TERM_ID);
END IF;
END IF; /*  NEXT */

/* END PAYMENT_TERM_ID*/
/****************************/

/****************************/
/* START agreement_id*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.agreement_id,
       p_prior_rec.agreement_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'agreement';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.agreement_id;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Agreement(p_curr_rec.agreement_id);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.agreement_id;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Agreement(p_prior_rec.agreement_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.agreement_id,
       p_next_rec.agreement_id) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Agreement(p_curr_rec.agreement_id);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'agreement';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.agreement_id;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Agreement(p_prior_rec.agreement_id);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.agreement_id;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Agreement(p_curr_rec.agreement_id);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.agreement_id;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Agreement(p_next_rec.agreement_id);
END IF; /*  NEXT */
END IF;

/* END agreement_id*/
/****************************/

/****************************/
/* START attribute1*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute1,
       p_prior_rec.attribute1) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute1';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute1;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute1;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute1,
       p_next_rec.attribute1) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute1;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute1';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute1;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute1;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.attribute1;
END IF; /*  NEXT */
END IF;

/* END attribute1*/
/****************************/

/****************************/
/* START attribute2*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute2,
       p_prior_rec.attribute2) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute2';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute2;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute2;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute2,
       p_next_rec.attribute2) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute2;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute2';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute2;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute2;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.attribute2;
END IF; /*  NEXT */
END IF;

/* END attribute2*/
/****************************/
/****************************/
/* START attribute3*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute3,
       p_prior_rec.attribute3) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute3';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute3;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute3;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute3,
       p_next_rec.attribute3) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute3;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute3';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute3;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute3;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.attribute3;
END IF; /*  NEXT */
END IF;

/* END attribute3*/
/****************************/

/****************************/
/* START attribute4*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute4,
       p_prior_rec.attribute4) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute4';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute4;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute4;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute4,
       p_next_rec.attribute4) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute4;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute4';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute4;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute4;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.attribute4;
END IF; /*  NEXT */
END IF;

/* END attribute4*/
/****************************/
/****************************/
/* START attribute5*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute5,
       p_prior_rec.attribute5) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute5';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute5;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute5;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute5,
       p_next_rec.attribute5) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute5;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute5';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute5;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute5;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.attribute5;
END IF; /*  NEXT */
END IF;

/* END attribute5*/
/****************************/

/****************************/
/* START attribute6*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute6,
       p_prior_rec.attribute6) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute6';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute6;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute6;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute6,
       p_next_rec.attribute6) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute6;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute6';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute6;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute6;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.attribute6;
END IF; /*  NEXT */
END IF;

/* END attribute6*/
/****************************/
/****************************/
/* START attribute7*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute7,
       p_prior_rec.attribute7) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute7';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute7;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute7;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute7,
       p_next_rec.attribute7) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute7;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute7;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute7';
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute7;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.attribute7;
END IF; /*  NEXT */
END IF;

/* END attribute7*/
/****************************/

/****************************/
/* START attribute8*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute8,
       p_prior_rec.attribute8) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute8';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute8;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute8;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute8,
       p_next_rec.attribute8) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute8;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute8';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute8;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute8;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.attribute8;
END IF; /*  NEXT */
END IF;

/* END attribute8*/
/****************************/
/****************************/
/* START attribute9*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute9,
       p_prior_rec.attribute9) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute9';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute9;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute9;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute9,
       p_next_rec.attribute9) THEN
    IF prior_exists = 'Y' THEN
     x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute9;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute9';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute9;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute9;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.attribute9;
END IF; /*  NEXT */
END IF;

/* END attribute9*/
/****************************/

/****************************/
/* START attribute10*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute10,
       p_prior_rec.attribute10) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute10';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute10;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute10;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute10,
       p_next_rec.attribute10) THEN
    IF prior_exists = 'Y' THEN
     x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute10;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute10';
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute10;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.attribute10;
END IF; /*  NEXT */
END IF;

/* END attribute10*/
/****************************/

/****************************/
/* START attribute11*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute11,
       p_prior_rec.attribute11) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute11';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute11;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute11;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute11,
       p_next_rec.attribute11) THEN
    IF prior_exists = 'Y' THEN
     x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute11;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute11';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute10;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute11;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.attribute11;
END IF; /*  NEXT */
END IF;

/* END attribute11*/
/****************************/

/****************************/
/* START attribute12*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute12,
       p_prior_rec.attribute12) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute12';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute12;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute12;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute12,
       p_next_rec.attribute12) THEN
    IF prior_exists = 'Y' THEN
     x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute12;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute12';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute12;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute12;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.attribute12;
END IF; /*  NEXT */
END IF;

/* END attribute12*/
/****************************/

/****************************/
/* START attribute13*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute13,
       p_prior_rec.attribute13) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute13';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute13;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute13;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute13,
       p_next_rec.attribute13) THEN
    IF prior_exists = 'Y' THEN
     x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute13;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute13';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute13;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute13;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.attribute13;
END IF;
END IF; /*  NEXT */

/* END attribute13*/
/****************************/

/****************************/
/* START attribute14*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute14,
       p_prior_rec.attribute14) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute14';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute14;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute14;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute14,
       p_next_rec.attribute14) THEN
    IF prior_exists = 'Y' THEN
     x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute14;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute14';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute14;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute14;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.attribute14;
END IF; /*  NEXT */
END IF;

/* END attribute14*/
/****************************/

/****************************/
/* START attribute15*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute15,
       p_prior_rec.attribute15) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute15';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute15;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute15;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute15,
       p_next_rec.attribute15) THEN
    IF prior_exists = 'Y' THEN
     x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute15;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute15';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute15;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute15;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.attribute15;
END IF; /*  NEXT */
END IF;

/* END attribute15*/
/****************************/
/****************************/
/* START context*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.context,
       p_prior_rec.context) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'context';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.context;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.context;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.context,
       p_next_rec.context) THEN
    IF prior_exists = 'Y' THEN
      x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.context;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'context';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.context;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.context;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.context;
END IF; /*  NEXT */
END IF;

/* END context*/
/****************************/


/****************************/
/* START conversion_type_code*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.conversion_type_code,
       p_prior_rec.conversion_type_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'conversion_type';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.conversion_type_code;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Conversion_Type(p_curr_rec.conversion_type_code);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.conversion_type_code;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Conversion_Type(p_prior_rec.conversion_type_code);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.conversion_type_code,
       p_next_rec.conversion_type_code) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Conversion_Type(p_curr_rec.conversion_type_code);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'conversion_type';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.conversion_type_code;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Conversion_Type(p_prior_rec.conversion_type_code);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.conversion_type_code;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Conversion_Type(p_curr_rec.conversion_type_code);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.conversion_type_code;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Conversion_type(p_next_rec.conversion_type_code);
END IF; /*  NEXT */
END IF;

/* END Conversion_Type_code*/
/****************************/

/****************************/
/* START cust_po_number*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.cust_po_number,
       p_prior_rec.cust_po_number) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'cust_po_number';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.cust_po_number;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.cust_po_number;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.cust_po_number,
       p_next_rec.cust_po_number) THEN
    IF prior_exists = 'Y' THEN
     x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.cust_po_number;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'cust_po_number';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.cust_po_number;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.cust_po_number;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.cust_po_number;
END IF; /*  NEXT */
END IF;

/* END cust_po_number*/
/****************************/

/****************************/
/* START deliver_to_org_id*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.deliver_to_org_id,
       p_prior_rec.deliver_to_org_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'deliver_to';
   if p_curr_rec.deliver_to_org_id is not null then
     OE_ID_TO_VALUE.deliver_To_Org
         (   p_deliver_to_org_id        => p_curr_rec.deliver_To_org_id
        , x_deliver_to_address1    => x_deliver_to_address1
        , x_deliver_to_address2    => x_deliver_to_address2
	, x_deliver_to_address3    => x_deliver_to_address3
	, x_deliver_to_address4    => x_deliver_to_address4
	, x_deliver_to_location    => x_deliver_to_location
	, x_deliver_to_org         => x_deliver_to_org
	, x_deliver_to_city        => x_deliver_to_city
	, x_deliver_to_state       => x_deliver_to_state
	, x_deliver_to_postal_code => x_deliver_to_postal_code
	, x_deliver_to_country     => x_deliver_to_country
          );

  select
    DECODE(x_deliver_to_location, NULL, NULL,x_deliver_to_location|| ', ') ||
    DECODE(x_deliver_to_address1, NULL, NULL,x_deliver_to_address1 || ', ') ||
    DECODE(x_deliver_to_address2, NULL, NULL,x_deliver_to_address3 || ', ') ||
    DECODE(x_deliver_to_address3, NULL, NULL,x_deliver_to_address3 || ', ') ||
    DECODE(x_deliver_to_address4, NULL, NULL,x_deliver_to_address4 || ', ') ||
    DECODE(x_deliver_to_city, NULL, NULL,x_deliver_to_city || ', ') ||
    DECODE(x_deliver_to_state, NULL, NULL,x_deliver_to_state || ', ') ||
    DECODE(x_deliver_to_postal_code, NULL, NULL,x_deliver_to_postal_code || ', ') ||
    DECODE(x_deliver_to_country, NULL,NULL,x_deliver_to_country)
        into x_current_deliver_to_address from dual;

   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.deliver_to_org_id;
   x_header_changed_attr_tbl(ind).current_value     := x_current_deliver_to_address;

       end if;
   if p_prior_rec.deliver_to_org_id is not null then
     OE_ID_TO_VALUE.deliver_To_Org
         (   p_deliver_to_org_id        => p_prior_rec.deliver_To_org_id
        , x_deliver_to_address1    => x_deliver_to_address1
        , x_deliver_to_address2    => x_deliver_to_address2
	, x_deliver_to_address3    => x_deliver_to_address3
	, x_deliver_to_address4    => x_deliver_to_address4
	, x_deliver_to_location    => x_deliver_to_location
	, x_deliver_to_org         => x_deliver_to_org
	, x_deliver_to_city        => x_deliver_to_city
	, x_deliver_to_state       => x_deliver_to_state
	, x_deliver_to_postal_code => x_deliver_to_postal_code
	, x_deliver_to_country     => x_deliver_to_country
          );

  select
    DECODE(x_deliver_to_location, NULL, NULL,x_deliver_to_location|| ', ') ||
    DECODE(x_deliver_to_address1, NULL, NULL,x_deliver_to_address1 || ', ') ||
    DECODE(x_deliver_to_address2, NULL, NULL,x_deliver_to_address3 || ', ') ||
    DECODE(x_deliver_to_address3, NULL, NULL,x_deliver_to_address3 || ', ') ||
    DECODE(x_deliver_to_address4, NULL, NULL,x_deliver_to_address4 || ', ') ||
    DECODE(x_deliver_to_city, NULL, NULL,x_deliver_to_city || ', ') ||
    DECODE(x_deliver_to_state, NULL, NULL,x_deliver_to_state || ', ') ||
    DECODE(x_deliver_to_postal_code, NULL, NULL,x_deliver_to_postal_code || ', ') ||
    DECODE(x_deliver_to_country, NULL,NULL,x_deliver_to_country)
        into x_prior_deliver_to_address from dual;
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.deliver_to_org_id;
   x_header_changed_attr_tbl(ind).prior_value     := x_prior_deliver_to_address;
       end if;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.deliver_to_org_id,
       p_next_rec.deliver_to_org_id) THEN
    IF prior_exists = 'Y' THEN
      x_header_changed_attr_tbl(ind).next_value     := x_prior_deliver_to_address;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'deliver_to';

   if p_prior_rec.deliver_to_org_id is not null then
     OE_ID_TO_VALUE.deliver_To_Org
         (   p_deliver_to_org_id        => p_prior_rec.deliver_To_org_id
        , x_deliver_to_address1    => x_deliver_to_address1
        , x_deliver_to_address2    => x_deliver_to_address2
	, x_deliver_to_address3    => x_deliver_to_address3
	, x_deliver_to_address4    => x_deliver_to_address4
	, x_deliver_to_location    => x_deliver_to_location
	, x_deliver_to_org         => x_deliver_to_org
	, x_deliver_to_city        => x_deliver_to_city
	, x_deliver_to_state       => x_deliver_to_state
	, x_deliver_to_postal_code => x_deliver_to_postal_code
	, x_deliver_to_country     => x_deliver_to_country
          );

  select
    DECODE(x_deliver_to_location, NULL, NULL,x_deliver_to_location|| ', ') ||
    DECODE(x_deliver_to_address1, NULL, NULL,x_deliver_to_address1 || ', ') ||
    DECODE(x_deliver_to_address2, NULL, NULL,x_deliver_to_address3 || ', ') ||
    DECODE(x_deliver_to_address3, NULL, NULL,x_deliver_to_address3 || ', ') ||
    DECODE(x_deliver_to_address4, NULL, NULL,x_deliver_to_address4 || ', ') ||
    DECODE(x_deliver_to_city, NULL, NULL,x_deliver_to_city || ', ') ||
    DECODE(x_deliver_to_state, NULL, NULL,x_deliver_to_state || ', ') ||
    DECODE(x_deliver_to_postal_code, NULL, NULL,x_deliver_to_postal_code || ', ') ||
    DECODE(x_deliver_to_country, NULL,NULL,x_deliver_to_country)
        into x_prior_deliver_to_address from dual;
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.deliver_to_org_id;
   x_header_changed_attr_tbl(ind).prior_value     := x_prior_deliver_to_address;

       end if;
   if p_curr_rec.deliver_to_org_id is not null then
     OE_ID_TO_VALUE.deliver_To_Org
         (   p_deliver_to_org_id        => p_curr_rec.deliver_To_org_id
        , x_deliver_to_address1    => x_deliver_to_address1
        , x_deliver_to_address2    => x_deliver_to_address2
	, x_deliver_to_address3    => x_deliver_to_address3
	, x_deliver_to_address4    => x_deliver_to_address4
	, x_deliver_to_location    => x_deliver_to_location
	, x_deliver_to_org         => x_deliver_to_org
	, x_deliver_to_city        => x_deliver_to_city
	, x_deliver_to_state       => x_deliver_to_state
	, x_deliver_to_postal_code => x_deliver_to_postal_code
	, x_deliver_to_country     => x_deliver_to_country
          );

  select
    DECODE(x_deliver_to_location, NULL, NULL,x_deliver_to_location|| ', ') ||
    DECODE(x_deliver_to_address1, NULL, NULL,x_deliver_to_address1 || ', ') ||
    DECODE(x_deliver_to_address2, NULL, NULL,x_deliver_to_address3 || ', ') ||
    DECODE(x_deliver_to_address3, NULL, NULL,x_deliver_to_address3 || ', ') ||
    DECODE(x_deliver_to_address4, NULL, NULL,x_deliver_to_address4 || ', ') ||
    DECODE(x_deliver_to_city, NULL, NULL,x_deliver_to_city || ', ') ||
    DECODE(x_deliver_to_state, NULL, NULL,x_deliver_to_state || ', ') ||
    DECODE(x_deliver_to_postal_code, NULL, NULL,x_deliver_to_postal_code || ', ') ||
    DECODE(x_deliver_to_country, NULL,NULL,x_deliver_to_country)
        into x_current_deliver_to_address from dual;
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.deliver_to_org_id;
   x_header_changed_attr_tbl(ind).current_value     := x_current_deliver_to_address;
       end if;

   if p_next_rec.deliver_to_org_id is not null then
     OE_ID_TO_VALUE.deliver_To_Org
         (   p_deliver_to_org_id        => p_next_rec.deliver_To_org_id
        , x_deliver_to_address1    => x_deliver_to_address1
        , x_deliver_to_address2    => x_deliver_to_address2
	, x_deliver_to_address3    => x_deliver_to_address3
	, x_deliver_to_address4    => x_deliver_to_address4
	, x_deliver_to_location    => x_deliver_to_location
	, x_deliver_to_org         => x_deliver_to_org
	, x_deliver_to_city        => x_deliver_to_city
	, x_deliver_to_state       => x_deliver_to_state
	, x_deliver_to_postal_code => x_deliver_to_postal_code
	, x_deliver_to_country     => x_deliver_to_country
          );

  select
    DECODE(x_deliver_to_location, NULL, NULL,x_deliver_to_location|| ', ') ||
    DECODE(x_deliver_to_address1, NULL, NULL,x_deliver_to_address1 || ', ') ||
    DECODE(x_deliver_to_address2, NULL, NULL,x_deliver_to_address3 || ', ') ||
    DECODE(x_deliver_to_address3, NULL, NULL,x_deliver_to_address3 || ', ') ||
    DECODE(x_deliver_to_address4, NULL, NULL,x_deliver_to_address4 || ', ') ||
    DECODE(x_deliver_to_city, NULL, NULL,x_deliver_to_city || ', ') ||
    DECODE(x_deliver_to_state, NULL, NULL,x_deliver_to_state || ', ') ||
    DECODE(x_deliver_to_postal_code, NULL, NULL,x_deliver_to_postal_code || ', ') ||
    DECODE(x_deliver_to_country, NULL,NULL,x_deliver_to_country)
        into x_next_deliver_to_address from dual;
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.deliver_to_org_id;
   x_header_changed_attr_tbl(ind).next_value     := x_next_deliver_to_address;
       end if;
END IF; /*  NEXT */
END IF;

/* END deliver_to_org_id*/
/****************************/


/****************************/
/* START freight_terms_code*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.freight_terms_code,
       p_prior_rec.freight_terms_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'freight_terms';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.freight_terms_code;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Freight_terms(p_curr_rec.freight_terms_code);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.freight_terms_code;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Freight_terms(p_prior_rec.freight_terms_code);
END IF;
END IF; /*  PRIOR */
/****************************/

IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.freight_terms_code,
       p_next_rec.freight_terms_code) THEN
    IF prior_exists = 'Y' THEN
      x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Freight_terms(p_curr_rec.freight_terms_code);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'freight_terms';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.freight_terms_code;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Freight_terms(p_prior_rec.freight_terms_code);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.freight_terms_code;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Freight_terms(p_curr_rec.freight_terms_code);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.freight_terms_code;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Freight_terms(p_next_rec.freight_terms_code);
END IF; /*  NEXT */
END IF;

/* END freight_terms_code*/
/****************************/
/****************************/
/* START invoice_to_org_id*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.invoice_to_org_id,
       p_prior_rec.invoice_to_org_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'invoice_to';
   if p_curr_rec.invoice_to_org_id is not null then

     OE_ID_TO_VALUE.invoice_to_Org
         (   p_invoice_to_org_id        => p_curr_rec.invoice_to_org_id
        , x_invoice_to_address1    => x_invoice_to_address1
        , x_invoice_to_address2    => x_invoice_to_address2
	, x_invoice_to_address3    => x_invoice_to_address3
	, x_invoice_to_address4    => x_invoice_to_address4
	, x_invoice_to_location    => x_invoice_to_location
	, x_invoice_to_org         => x_invoice_to_org
	, x_invoice_to_city        => x_invoice_to_city
	, x_invoice_to_state       => x_invoice_to_state
	, x_invoice_to_postal_code => x_invoice_to_postal_code
	, x_invoice_to_country     => x_invoice_to_country
          );

  select
    DECODE(x_invoice_to_location, NULL, NULL,x_invoice_to_location|| ', ') ||
    DECODE(x_invoice_to_address1, NULL, NULL,x_invoice_to_address1 || ', ') ||
    DECODE(x_invoice_to_address2, NULL, NULL,x_invoice_to_address3 || ', ') ||
    DECODE(x_invoice_to_address3, NULL, NULL,x_invoice_to_address3 || ', ') ||
    DECODE(x_invoice_to_address4, NULL, NULL,x_invoice_to_address4 || ', ') ||
    DECODE(x_invoice_to_city, NULL, NULL,x_invoice_to_city || ', ') ||
    DECODE(x_invoice_to_state, NULL, NULL,x_invoice_to_state || ', ') ||
    DECODE(x_invoice_to_postal_code, NULL, NULL,x_invoice_to_postal_code || ', ') ||
    DECODE(x_invoice_to_country, NULL,NULL,x_invoice_to_country)
        into x_current_invoice_to_address from dual;
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.invoice_to_org_id;

   x_header_changed_attr_tbl(ind).current_value     := x_current_invoice_to_address;
       end if;

   if p_prior_rec.invoice_to_org_id is not null then
     OE_ID_TO_VALUE.invoice_to_Org
         (   p_invoice_to_org_id        => p_prior_rec.invoice_to_org_id
        , x_invoice_to_address1    => x_invoice_to_address1
        , x_invoice_to_address2    => x_invoice_to_address2
	, x_invoice_to_address3    => x_invoice_to_address3
	, x_invoice_to_address4    => x_invoice_to_address4
	, x_invoice_to_location    => x_invoice_to_location
	, x_invoice_to_org         => x_invoice_to_org
	, x_invoice_to_city        => x_invoice_to_city
	, x_invoice_to_state       => x_invoice_to_state
	, x_invoice_to_postal_code => x_invoice_to_postal_code
	, x_invoice_to_country     => x_invoice_to_country
          );

  select
    DECODE(x_invoice_to_location, NULL, NULL,x_invoice_to_location|| ', ') ||
    DECODE(x_invoice_to_address1, NULL, NULL,x_invoice_to_address1 || ', ') ||
    DECODE(x_invoice_to_address2, NULL, NULL,x_invoice_to_address3 || ', ') ||
    DECODE(x_invoice_to_address3, NULL, NULL,x_invoice_to_address3 || ', ') ||
    DECODE(x_invoice_to_address4, NULL, NULL,x_invoice_to_address4 || ', ') ||
    DECODE(x_invoice_to_city, NULL, NULL,x_invoice_to_city || ', ') ||
    DECODE(x_invoice_to_state, NULL, NULL,x_invoice_to_state || ', ') ||
    DECODE(x_invoice_to_postal_code, NULL, NULL,x_invoice_to_postal_code || ', ') ||
    DECODE(x_invoice_to_country, NULL,NULL,x_invoice_to_country)
        into x_prior_invoice_to_address from dual;
   x_header_changed_attr_tbl(ind).prior_value     := x_prior_invoice_to_address;
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.invoice_to_org_id;
       end if;
END IF;
END IF; /*  PRIOR */
/****************************/

IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.invoice_to_org_id,
       p_next_rec.invoice_to_org_id) THEN
    IF prior_exists = 'Y' THEN
     x_header_changed_attr_tbl(ind).next_value     := x_current_invoice_to_address;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'invoice_to';

   if p_prior_rec.invoice_to_org_id is not null then
     OE_ID_TO_VALUE.invoice_to_Org
         (   p_invoice_to_org_id        => p_prior_rec.invoice_to_org_id
        , x_invoice_to_address1    => x_invoice_to_address1
        , x_invoice_to_address2    => x_invoice_to_address2
	, x_invoice_to_address3    => x_invoice_to_address3
	, x_invoice_to_address4    => x_invoice_to_address4
	, x_invoice_to_location    => x_invoice_to_location
	, x_invoice_to_org         => x_invoice_to_org
	, x_invoice_to_city        => x_invoice_to_city
	, x_invoice_to_state       => x_invoice_to_state
	, x_invoice_to_postal_code => x_invoice_to_postal_code
	, x_invoice_to_country     => x_invoice_to_country
          );

  select
    DECODE(x_invoice_to_location, NULL, NULL,x_invoice_to_location|| ', ') ||
    DECODE(x_invoice_to_address1, NULL, NULL,x_invoice_to_address1 || ', ') ||
    DECODE(x_invoice_to_address2, NULL, NULL,x_invoice_to_address3 || ', ') ||
    DECODE(x_invoice_to_address3, NULL, NULL,x_invoice_to_address3 || ', ') ||
    DECODE(x_invoice_to_address4, NULL, NULL,x_invoice_to_address4 || ', ') ||
    DECODE(x_invoice_to_city, NULL, NULL,x_invoice_to_city || ', ') ||
    DECODE(x_invoice_to_state, NULL, NULL,x_invoice_to_state || ', ') ||
    DECODE(x_invoice_to_postal_code, NULL, NULL,x_invoice_to_postal_code || ', ') ||
    DECODE(x_invoice_to_country, NULL,NULL,x_invoice_to_country)
        into x_prior_invoice_to_address from dual;
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.invoice_to_org_id;
   x_header_changed_attr_tbl(ind).prior_value     := x_prior_invoice_to_address;
       end if;

   if p_curr_rec.invoice_to_org_id is not null then
     OE_ID_TO_VALUE.invoice_to_Org
         (   p_invoice_to_org_id        => p_curr_rec.invoice_to_org_id
        , x_invoice_to_address1    => x_invoice_to_address1
        , x_invoice_to_address2    => x_invoice_to_address2
	, x_invoice_to_address3    => x_invoice_to_address3
	, x_invoice_to_address4    => x_invoice_to_address4
	, x_invoice_to_location    => x_invoice_to_location
	, x_invoice_to_org         => x_invoice_to_org
	, x_invoice_to_city        => x_invoice_to_city
	, x_invoice_to_state       => x_invoice_to_state
	, x_invoice_to_postal_code => x_invoice_to_postal_code
	, x_invoice_to_country     => x_invoice_to_country
          );

  select
    DECODE(x_invoice_to_location, NULL, NULL,x_invoice_to_location|| ', ') ||
    DECODE(x_invoice_to_address1, NULL, NULL,x_invoice_to_address1 || ', ') ||
    DECODE(x_invoice_to_address2, NULL, NULL,x_invoice_to_address3 || ', ') ||
    DECODE(x_invoice_to_address3, NULL, NULL,x_invoice_to_address3 || ', ') ||
    DECODE(x_invoice_to_address4, NULL, NULL,x_invoice_to_address4 || ', ') ||
    DECODE(x_invoice_to_city, NULL, NULL,x_invoice_to_city || ', ') ||
    DECODE(x_invoice_to_state, NULL, NULL,x_invoice_to_state || ', ') ||
    DECODE(x_invoice_to_postal_code, NULL, NULL,x_invoice_to_postal_code || ', ') ||
    DECODE(x_invoice_to_country, NULL,NULL,x_invoice_to_country)
        into x_current_invoice_to_address from dual;
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.invoice_to_org_id;
   x_header_changed_attr_tbl(ind).current_value     := x_current_invoice_to_address;
       end if;

   if p_next_rec.invoice_to_org_id is not null then
     OE_ID_TO_VALUE.invoice_to_Org
         (   p_invoice_to_org_id        => p_next_rec.invoice_to_org_id
        , x_invoice_to_address1    => x_invoice_to_address1
        , x_invoice_to_address2    => x_invoice_to_address2
	, x_invoice_to_address3    => x_invoice_to_address3
	, x_invoice_to_address4    => x_invoice_to_address4
	, x_invoice_to_location    => x_invoice_to_location
	, x_invoice_to_org         => x_invoice_to_org
	, x_invoice_to_city        => x_invoice_to_city
	, x_invoice_to_state       => x_invoice_to_state
	, x_invoice_to_postal_code => x_invoice_to_postal_code
	, x_invoice_to_country     => x_invoice_to_country
          );

  select
    DECODE(x_invoice_to_location, NULL, NULL,x_invoice_to_location|| ', ') ||
    DECODE(x_invoice_to_address1, NULL, NULL,x_invoice_to_address1 || ', ') ||
    DECODE(x_invoice_to_address2, NULL, NULL,x_invoice_to_address3 || ', ') ||
    DECODE(x_invoice_to_address3, NULL, NULL,x_invoice_to_address3 || ', ') ||
    DECODE(x_invoice_to_address4, NULL, NULL,x_invoice_to_address4 || ', ') ||
    DECODE(x_invoice_to_city, NULL, NULL,x_invoice_to_city || ', ') ||
    DECODE(x_invoice_to_state, NULL, NULL,x_invoice_to_state || ', ') ||
    DECODE(x_invoice_to_postal_code, NULL, NULL,x_invoice_to_postal_code || ', ') ||
    DECODE(x_invoice_to_country, NULL,NULL,x_invoice_to_country)
        into x_next_invoice_to_address from dual;
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.invoice_to_org_id;
   x_header_changed_attr_tbl(ind).next_value     := x_next_invoice_to_address;
       end if;
END IF;
END IF; /*  NEXT */

/* END invoice_to_org_id*/
/****************************/

/****************************/
/* START invoicing_rule_id*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.invoicing_rule_id,
       p_prior_rec.invoicing_rule_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'invoicing_rule';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.invoicing_rule_id;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Invoicing_Rule(p_curr_rec.invoicing_rule_id);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.invoicing_rule_id;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Invoicing_Rule(p_prior_rec.invoicing_rule_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.invoicing_rule_id,
       p_next_rec.invoicing_rule_id) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Invoicing_Rule(p_curr_rec.invoicing_rule_id);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'invoicing_rule';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.invoicing_rule_id;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Invoicing_Rule(p_prior_rec.invoicing_rule_id);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.invoicing_rule_id;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Invoicing_Rule(p_curr_rec.invoicing_rule_id);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.invoicing_rule_id;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Invoicing_Rule(p_next_rec.invoicing_rule_id);
END IF; /*  NEXT */
END IF;

/* END invoicing_rule_id*/
/****************************/

/****************************/
/* START order_number*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.order_number,
       p_prior_rec.order_number) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'order_number';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.order_number;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.order_number;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.order_number,
       p_next_rec.order_number) THEN
    IF prior_exists = 'Y' THEN
     x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.order_number;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'order_number';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.order_number;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.order_number;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.order_number;
END IF; /*  NEXT */
END IF;

/* END order_number*/
/****************************/
/****************************/
/* START order_type_id*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.order_type_id,
       p_prior_rec.order_type_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'order_type';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.order_type_id;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.order_Type(p_curr_rec.order_type_id);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.order_type_id;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.order_Type(p_prior_rec.order_type_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.order_type_id,
       p_next_rec.order_type_id) THEN
    IF prior_exists = 'Y' THEN
     x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.order_Type(p_curr_rec.order_type_id);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'order_type';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.order_type_id;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.order_Type(p_prior_rec.order_type_id);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.order_type_id;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.order_Type(p_curr_rec.order_type_id);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.order_type_id;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.order_Type(p_next_rec.order_type_id);
END IF;
END IF; /*  NEXT */

/* END order_type_id*/
/****************************/
/****************************/
/* START PRICE_LIST_ID*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.PRICE_LIST_ID,
       p_prior_rec.PRICE_LIST_ID) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'PRICE_LIST_NAME';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.PRICE_LIST_ID;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.PRICE_LIST(p_curr_rec.PRICE_LIST_ID);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.PRICE_LIST_ID;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.PRICE_LIST(p_prior_rec.PRICE_LIST_ID);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.PRICE_LIST_ID,
       p_next_rec.PRICE_LIST_ID) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.PRICE_LIST(p_curr_rec.PRICE_LIST_ID);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'PRICE_LIST_NAME';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.PRICE_LIST_ID;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.PRICE_LIST(p_prior_rec.PRICE_LIST_ID);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.PRICE_LIST_ID;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.PRICE_LIST(p_curr_rec.PRICE_LIST_ID);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.PRICE_LIST_ID;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.PRICE_LIST(p_next_rec.PRICE_LIST_ID);
END IF; /*  NEXT */
END IF;

/* END PRICE_LIST_ID*/
/****************************/

/****************************/
/* START SALESREP_ID*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.SALESREP_ID,
       p_prior_rec.SALESREP_ID) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'SALESREP';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.SALESREP_ID;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.SALESREP(p_curr_rec.SALESREP_ID);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.SALESREP_ID;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.SALESREP(p_prior_rec.SALESREP_ID);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.SALESREP_ID,
       p_next_rec.SALESREP_ID) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.SALESREP(p_curr_rec.SALESREP_ID);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'SALESREP';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.SALESREP_ID;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.SALESREP(p_prior_rec.SALESREP_ID);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.SALESREP_ID;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.SALESREP(p_curr_rec.SALESREP_ID);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.SALESREP_ID;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.SALESREP(p_next_rec.SALESREP_ID);
END IF; /*  NEXT */
END IF;

/* END SALESREP_ID*/
/****************************/
/****************************/
/* START SHIPPING_METHOD_CODE*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.SHIPPING_METHOD_CODE,
       p_prior_rec.SHIPPING_METHOD_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'SHIPPING_METHOD';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.SHIPPING_METHOD_CODE;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.ship_method(p_curr_rec.SHIPPING_METHOD_CODE);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.SHIPPING_METHOD_CODE;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.ship_method(p_prior_rec.SHIPPING_METHOD_CODE);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.SHIPPING_METHOD_CODE,
       p_next_rec.SHIPPING_METHOD_CODE) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.ship_method(p_curr_rec.SHIPPING_METHOD_CODE);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'SHIPPING_METHOD';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.SHIPPING_METHOD_CODE;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.ship_method(p_prior_rec.SHIPPING_METHOD_CODE);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.SHIPPING_METHOD_CODE;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.ship_method(p_curr_rec.SHIPPING_METHOD_CODE);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.SHIPPING_METHOD_CODE;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.ship_method(p_next_rec.SHIPPING_METHOD_CODE);
END IF; /*  NEXT */
END IF;

/* END SHIPPING_METHOD_CODE*/
/****************************/

/****************************/
/* START ship_from_org_id*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.ship_from_org_id,
       p_prior_rec.ship_from_org_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'Warehouse';
   if p_curr_rec.ship_from_org_id is not null then
     OE_ID_TO_VALUE.ship_from_Org
         (   p_ship_from_org_id        => p_curr_rec.ship_from_org_id
        , x_ship_from_address1    => x_ship_from_address1
        , x_ship_from_address2    => x_ship_from_address2
	, x_ship_from_address3    => x_ship_from_address3
	, x_ship_from_address4    => x_ship_from_address4
	, x_ship_from_location    => x_ship_from_location
	, x_ship_from_org         => x_current_ship_from_org
          );
/*
  select
    DECODE(x_ship_from_location, NULL, NULL,x_ship_from_location|| ', ') ||
    DECODE(x_ship_from_address1, NULL, NULL,x_ship_from_address1 || ', ') ||
    DECODE(x_ship_from_address2, NULL, NULL,x_ship_from_address3 || ', ') ||
    DECODE(x_ship_from_address3, NULL, NULL,x_ship_from_address3 || ', ') ||
    DECODE(x_ship_from_address4, NULL, NULL,x_ship_from_address4 || ', ')
        into x_current_ship_from_address from dual;
*/
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.ship_from_org_id;
   x_header_changed_attr_tbl(ind).current_value     := x_current_ship_from_org;

       end if;
   if p_prior_rec.ship_from_org_id is not null then
     OE_ID_TO_VALUE.ship_from_Org
         (   p_ship_from_org_id        => p_prior_rec.ship_from_org_id
        , x_ship_from_address1    => x_ship_from_address1
        , x_ship_from_address2    => x_ship_from_address2
	, x_ship_from_address3    => x_ship_from_address3
	, x_ship_from_address4    => x_ship_from_address4
	, x_ship_from_location    => x_ship_from_location
	, x_ship_from_org         => x_prior_ship_from_org
          );
/*
  select
    DECODE(x_ship_from_location, NULL, NULL,x_ship_from_location|| ', ') ||
    DECODE(x_ship_from_address1, NULL, NULL,x_ship_from_address1 || ', ') ||
    DECODE(x_ship_from_address2, NULL, NULL,x_ship_from_address3 || ', ') ||
    DECODE(x_ship_from_address3, NULL, NULL,x_ship_from_address3 || ', ') ||
    DECODE(x_ship_from_address4, NULL, NULL,x_ship_from_address4 || ', ')
        into x_prior_ship_from_address from dual;
*/
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.ship_from_org_id;
   x_header_changed_attr_tbl(ind).prior_value     := x_prior_ship_from_org;
       end if;
END IF;
END IF; /*  PRIOR */
/****************************/

IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.ship_from_org_id,
       p_next_rec.ship_from_org_id) THEN
    IF prior_exists = 'Y' THEN
     x_header_changed_attr_tbl(ind).next_value     := x_current_ship_from_org;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'Warehouse';

   if p_prior_rec.ship_from_org_id is not null then
     OE_ID_TO_VALUE.ship_from_Org
         (   p_ship_from_org_id        => p_prior_rec.ship_from_org_id
        , x_ship_from_address1    => x_ship_from_address1
        , x_ship_from_address2    => x_ship_from_address2
	, x_ship_from_address3    => x_ship_from_address3
	, x_ship_from_address4    => x_ship_from_address4
	, x_ship_from_location    => x_ship_from_location
	, x_ship_from_org         => x_prior_ship_from_org
          );
/*
  select
    DECODE(x_ship_from_location, NULL, NULL,x_ship_from_location|| ', ') ||
    DECODE(x_ship_from_address1, NULL, NULL,x_ship_from_address1 || ', ') ||
    DECODE(x_ship_from_address2, NULL, NULL,x_ship_from_address3 || ', ') ||
    DECODE(x_ship_from_address3, NULL, NULL,x_ship_from_address3 || ', ') ||
    DECODE(x_ship_from_address4, NULL, NULL,x_ship_from_address4 || ', ')
        into x_prior_ship_from_address from dual;
*/
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.ship_from_org_id;
   x_header_changed_attr_tbl(ind).prior_value     := x_prior_ship_from_org;
       end if;
   if p_curr_rec.ship_from_org_id is not null then
     OE_ID_TO_VALUE.ship_from_Org
         (   p_ship_from_org_id        => p_curr_rec.ship_from_org_id
        , x_ship_from_address1    => x_ship_from_address1
        , x_ship_from_address2    => x_ship_from_address2
	, x_ship_from_address3    => x_ship_from_address3
	, x_ship_from_address4    => x_ship_from_address4
	, x_ship_from_location    => x_ship_from_location
	, x_ship_from_org         => x_current_ship_from_org
          );
/*
  select
    DECODE(x_ship_from_location, NULL, NULL,x_ship_from_location|| ', ') ||
    DECODE(x_ship_from_address1, NULL, NULL,x_ship_from_address1 || ', ') ||
    DECODE(x_ship_from_address2, NULL, NULL,x_ship_from_address3 || ', ') ||
    DECODE(x_ship_from_address3, NULL, NULL,x_ship_from_address3 || ', ') ||
    DECODE(x_ship_from_address4, NULL, NULL,x_ship_from_address4 || ', ')
        into x_current_ship_from_address from dual;
*/
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.ship_from_org_id;
   x_header_changed_attr_tbl(ind).current_value     := x_current_ship_from_org;
       end if;

   if p_next_rec.ship_from_org_id is not null then
     OE_ID_TO_VALUE.ship_from_Org
         (   p_ship_from_org_id        => p_next_rec.ship_from_org_id
        , x_ship_from_address1    => x_ship_from_address1
        , x_ship_from_address2    => x_ship_from_address2
	, x_ship_from_address3    => x_ship_from_address3
	, x_ship_from_address4    => x_ship_from_address4
	, x_ship_from_location    => x_ship_from_location
	, x_ship_from_org         => x_next_ship_from_org
          );
/*
  select
    DECODE(x_ship_from_location, NULL, NULL,x_ship_from_location|| ', ') ||
    DECODE(x_ship_from_address1, NULL, NULL,x_ship_from_address1 || ', ') ||
    DECODE(x_ship_from_address2, NULL, NULL,x_ship_from_address3 || ', ') ||
    DECODE(x_ship_from_address3, NULL, NULL,x_ship_from_address3 || ', ') ||
    DECODE(x_ship_from_address4, NULL, NULL,x_ship_from_address4 || ', ')
        into x_next_ship_from_address from dual;
*/
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.ship_from_org_id;
   x_header_changed_attr_tbl(ind).next_value     := x_next_ship_from_org;
       end if;
END IF; /*  NEXT */
END IF;

/* END ship_from_org_id*/
/****************************/

/****************************/
/* START ship_to_org_id*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.ship_to_org_id,
       p_prior_rec.ship_to_org_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'ship_to';
   if p_curr_rec.ship_to_org_id is not null then
     OE_ID_TO_VALUE.ship_to_Org
         (   p_ship_to_org_id        => p_curr_rec.ship_to_org_id
        , x_ship_to_address1    => x_ship_to_address1
        , x_ship_to_address2    => x_ship_to_address2
	, x_ship_to_address3    => x_ship_to_address3
	, x_ship_to_address4    => x_ship_to_address4
	, x_ship_to_location    => x_ship_to_location
	, x_ship_to_org         => x_ship_to_org
	, x_ship_to_city        => x_ship_to_city
	, x_ship_to_state       => x_ship_to_state
	, x_ship_to_postal_code => x_ship_to_postal_code
	, x_ship_to_country     => x_ship_to_country
          );

  select
    DECODE(x_ship_to_location, NULL, NULL,x_ship_to_location|| ', ') ||
    DECODE(x_ship_to_address1, NULL, NULL,x_ship_to_address1 || ', ') ||
    DECODE(x_ship_to_address2, NULL, NULL,x_ship_to_address3 || ', ') ||
    DECODE(x_ship_to_address3, NULL, NULL,x_ship_to_address3 || ', ') ||
    DECODE(x_ship_to_address4, NULL, NULL,x_ship_to_address4 || ', ') ||
    DECODE(x_ship_to_city, NULL, NULL,x_ship_to_city || ', ') ||
    DECODE(x_ship_to_state, NULL, NULL,x_ship_to_state || ', ') ||
    DECODE(x_ship_to_postal_code, NULL, NULL,x_ship_to_postal_code || ', ') ||
    DECODE(x_ship_to_country, NULL,NULL,x_ship_to_country)
        into x_current_ship_to_address from dual;

   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.ship_to_org_id;
   x_header_changed_attr_tbl(ind).current_value     := x_current_ship_to_address;
       end if;

   if p_prior_rec.ship_to_org_id is not null then
     OE_ID_TO_VALUE.ship_to_Org
         (   p_ship_to_org_id        => p_prior_rec.ship_to_org_id
        , x_ship_to_address1    => x_ship_to_address1
        , x_ship_to_address2    => x_ship_to_address2
	, x_ship_to_address3    => x_ship_to_address3
	, x_ship_to_address4    => x_ship_to_address4
	, x_ship_to_location    => x_ship_to_location
	, x_ship_to_org         => x_ship_to_org
	, x_ship_to_city        => x_ship_to_city
	, x_ship_to_state       => x_ship_to_state
	, x_ship_to_postal_code => x_ship_to_postal_code
	, x_ship_to_country     => x_ship_to_country
          );

  select
    DECODE(x_ship_to_location, NULL, NULL,x_ship_to_location|| ', ') ||
    DECODE(x_ship_to_address1, NULL, NULL,x_ship_to_address1 || ', ') ||
    DECODE(x_ship_to_address2, NULL, NULL,x_ship_to_address3 || ', ') ||
    DECODE(x_ship_to_address3, NULL, NULL,x_ship_to_address3 || ', ') ||
    DECODE(x_ship_to_address4, NULL, NULL,x_ship_to_address4 || ', ') ||
    DECODE(x_ship_to_city, NULL, NULL,x_ship_to_city || ', ') ||
    DECODE(x_ship_to_state, NULL, NULL,x_ship_to_state || ', ') ||
    DECODE(x_ship_to_postal_code, NULL, NULL,x_ship_to_postal_code || ', ') ||
    DECODE(x_ship_to_country, NULL,NULL,x_ship_to_country)
        into x_prior_ship_to_address from dual;
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.ship_to_org_id;
   x_header_changed_attr_tbl(ind).prior_value     := x_prior_ship_to_address;
       end if;
END IF;
END IF; /*  PRIOR */
/****************************/

IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.ship_to_org_id,
       p_next_rec.ship_to_org_id) THEN
    IF prior_exists = 'Y' THEN
      x_header_changed_attr_tbl(ind).next_value     := x_current_ship_to_address;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'ship_to';

   if p_prior_rec.ship_to_org_id is not null then
     OE_ID_TO_VALUE.ship_to_Org
         (   p_ship_to_org_id        => p_prior_rec.ship_to_org_id
        , x_ship_to_address1    => x_ship_to_address1
        , x_ship_to_address2    => x_ship_to_address2
	, x_ship_to_address3    => x_ship_to_address3
	, x_ship_to_address4    => x_ship_to_address4
	, x_ship_to_location    => x_ship_to_location
	, x_ship_to_org         => x_ship_to_org
	, x_ship_to_city        => x_ship_to_city
	, x_ship_to_state       => x_ship_to_state
	, x_ship_to_postal_code => x_ship_to_postal_code
	, x_ship_to_country     => x_ship_to_country
          );

  select
    DECODE(x_ship_to_location, NULL, NULL,x_ship_to_location|| ', ') ||
    DECODE(x_ship_to_address1, NULL, NULL,x_ship_to_address1 || ', ') ||
    DECODE(x_ship_to_address2, NULL, NULL,x_ship_to_address3 || ', ') ||
    DECODE(x_ship_to_address3, NULL, NULL,x_ship_to_address3 || ', ') ||
    DECODE(x_ship_to_address4, NULL, NULL,x_ship_to_address4 || ', ') ||
    DECODE(x_ship_to_city, NULL, NULL,x_ship_to_city || ', ') ||
    DECODE(x_ship_to_state, NULL, NULL,x_ship_to_state || ', ') ||
    DECODE(x_ship_to_postal_code, NULL, NULL,x_ship_to_postal_code || ', ') ||
    DECODE(x_ship_to_country, NULL,NULL,x_ship_to_country)
        into x_prior_ship_to_address from dual;
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.ship_to_org_id;
   x_header_changed_attr_tbl(ind).prior_value     := x_prior_ship_to_address;
       end if;

   if p_curr_rec.ship_to_org_id is not null then
     OE_ID_TO_VALUE.ship_to_Org
         (   p_ship_to_org_id        => p_curr_rec.ship_to_org_id
        , x_ship_to_address1    => x_ship_to_address1
        , x_ship_to_address2    => x_ship_to_address2
	, x_ship_to_address3    => x_ship_to_address3
	, x_ship_to_address4    => x_ship_to_address4
	, x_ship_to_location    => x_ship_to_location
	, x_ship_to_org         => x_ship_to_org
	, x_ship_to_city        => x_ship_to_city
	, x_ship_to_state       => x_ship_to_state
	, x_ship_to_postal_code => x_ship_to_postal_code
	, x_ship_to_country     => x_ship_to_country
          );

  select
    DECODE(x_ship_to_location, NULL, NULL,x_ship_to_location|| ', ') ||
    DECODE(x_ship_to_address1, NULL, NULL,x_ship_to_address1 || ', ') ||
    DECODE(x_ship_to_address2, NULL, NULL,x_ship_to_address3 || ', ') ||
    DECODE(x_ship_to_address3, NULL, NULL,x_ship_to_address3 || ', ') ||
    DECODE(x_ship_to_address4, NULL, NULL,x_ship_to_address4 || ', ') ||
    DECODE(x_ship_to_city, NULL, NULL,x_ship_to_city || ', ') ||
    DECODE(x_ship_to_state, NULL, NULL,x_ship_to_state || ', ') ||
    DECODE(x_ship_to_postal_code, NULL, NULL,x_ship_to_postal_code || ', ') ||
    DECODE(x_ship_to_country, NULL,NULL,x_ship_to_country)
        into x_current_ship_to_address from dual;
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.ship_to_org_id;
   x_header_changed_attr_tbl(ind).current_value     := x_current_ship_to_address;
       end if;

   if p_next_rec.ship_to_org_id is not null then
     OE_ID_TO_VALUE.ship_to_Org
         (   p_ship_to_org_id        => p_next_rec.ship_to_org_id
        , x_ship_to_address1    => x_ship_to_address1
        , x_ship_to_address2    => x_ship_to_address2
	, x_ship_to_address3    => x_ship_to_address3
	, x_ship_to_address4    => x_ship_to_address4
	, x_ship_to_location    => x_ship_to_location
	, x_ship_to_org         => x_ship_to_org
	, x_ship_to_city        => x_ship_to_city
	, x_ship_to_state       => x_ship_to_state
	, x_ship_to_postal_code => x_ship_to_postal_code
	, x_ship_to_country     => x_ship_to_country
          );

  select
    DECODE(x_ship_to_location, NULL, NULL,x_ship_to_location|| ', ') ||
    DECODE(x_ship_to_address1, NULL, NULL,x_ship_to_address1 || ', ') ||
    DECODE(x_ship_to_address2, NULL, NULL,x_ship_to_address3 || ', ') ||
    DECODE(x_ship_to_address3, NULL, NULL,x_ship_to_address3 || ', ') ||
    DECODE(x_ship_to_address4, NULL, NULL,x_ship_to_address4 || ', ') ||
    DECODE(x_ship_to_city, NULL, NULL,x_ship_to_city || ', ') ||
    DECODE(x_ship_to_state, NULL, NULL,x_ship_to_state || ', ') ||
    DECODE(x_ship_to_postal_code, NULL, NULL,x_ship_to_postal_code || ', ') ||
    DECODE(x_ship_to_country, NULL,NULL,x_ship_to_country)
        into x_next_ship_to_address from dual;
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.ship_to_org_id;
   x_header_changed_attr_tbl(ind).next_value     := x_next_ship_to_address;
       end if;
END IF; /*  NEXT */
END IF;

/* END ship_to_org_id*/
/****************************/

/****************************/
/* START sold_TO_CONTACT_ID*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.sold_to_contact_id,
       p_prior_rec.sold_to_contact_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'sold_to_contact';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.sold_to_contact_id;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.sold_To_Contact(p_curr_rec.sold_to_contact_id);
   x_header_changed_attr_tbl(ind).prior_id      := p_prior_rec.sold_to_contact_id;
   x_header_changed_attr_tbl(ind).prior_value   := OE_ID_TO_VALUE.sold_To_Contact(p_prior_rec.sold_to_contact_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.sold_to_contact_id,
       p_next_rec.sold_to_contact_id) THEN
    IF prior_exists = 'Y' THEN
     x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.sold_To_Contact(p_curr_rec.sold_to_contact_id);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name   := 'sold_to_contact';
   x_header_changed_attr_tbl(ind).prior_id      := p_prior_rec.sold_to_contact_id;
   x_header_changed_attr_tbl(ind).prior_value   := OE_ID_TO_VALUE.sold_To_Contact(p_prior_rec.sold_to_contact_id);
   x_header_changed_attr_tbl(ind).current_id   := p_curr_rec.sold_to_contact_id;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.sold_To_Contact(p_curr_rec.sold_to_contact_id);
   x_header_changed_attr_tbl(ind).next_id   := p_next_rec.sold_to_contact_id;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.sold_To_Contact(p_next_rec.sold_to_contact_id);
END IF; /*  NEXT */
END IF;

/* END sold_to_contact_id*/
/****************************/

/****************************/
/* START SOLD_TO_ORG_ID*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.SOLD_TO_ORG_ID,
       p_prior_rec.SOLD_TO_ORG_ID) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'SOLD_TO';
   If p_curr_rec.sold_to_org_id is not NULL THEN
   OE_ID_TO_VALUE.Sold_To_Org(p_sold_to_org_id => p_curr_rec.SOLD_TO_ORG_ID,
		              x_org            => x_current_customer_name,
			      x_customer_number=> x_customer_number);
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.SOLD_TO_ORG_ID;
   x_header_changed_attr_tbl(ind).current_value   := x_current_customer_name;
   END IF;
   If p_prior_rec.sold_to_org_id is not NULL THEN
   OE_ID_TO_VALUE.Sold_To_Org(p_sold_to_org_id => p_prior_rec.SOLD_TO_ORG_ID,
		              x_org            => x_prior_customer_name,
			      x_customer_number=> x_customer_number);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.SOLD_TO_ORG_ID;
   x_header_changed_attr_tbl(ind).prior_value   := x_prior_customer_name;
   END IF;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.SOLD_TO_ORG_ID,
       p_next_rec.SOLD_TO_ORG_ID) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := x_current_customer_name;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'SOLD_TO';
   If p_prior_rec.sold_to_org_id is not NULL THEN
   OE_ID_TO_VALUE.Sold_To_Org(p_sold_to_org_id => p_prior_rec.SOLD_TO_ORG_ID,
		              x_org            => x_prior_customer_name,
			      x_customer_number=> x_customer_number);
   x_header_changed_attr_tbl(ind).prior_id     := p_prior_rec.SOLD_TO_ORG_ID;
   x_header_changed_attr_tbl(ind).prior_value  := x_prior_customer_name;
   END IF;
   If p_curr_rec.sold_to_org_id is not NULL THEN
   OE_ID_TO_VALUE.Sold_To_Org(p_sold_to_org_id => p_curr_rec.SOLD_TO_ORG_ID,
		              x_org            => x_current_customer_name,
			      x_customer_number=> x_customer_number);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.SOLD_TO_ORG_ID;
   x_header_changed_attr_tbl(ind).current_value  := x_current_customer_name;
   END IF;
   If p_next_rec.sold_to_org_id is not NULL THEN
   OE_ID_TO_VALUE.Sold_To_Org(p_sold_to_org_id => p_next_rec.SOLD_TO_ORG_ID,
		              x_org            => x_next_customer_name,
			      x_customer_number=> x_customer_number);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.SOLD_TO_ORG_ID;
   x_header_changed_attr_tbl(ind).next_value   := x_next_customer_name;
   END IF;
END IF; /*  NEXT */
END IF;

/* END SOLD_TO_ORG_ID*/
/****************************/

/****************************/
/* START TRANSACTIONAL_CURR_CODE*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.TRANSACTIONAL_CURR_CODE,
       p_prior_rec.TRANSACTIONAL_CURR_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'TRANSACTIONAL_CURR_CODE';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.TRANSACTIONAL_CURR_CODE;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.TRANSACTIONAL_CURR_CODE;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.TRANSACTIONAL_CURR_CODE,
       p_next_rec.TRANSACTIONAL_CURR_CODE) THEN
    IF prior_exists = 'Y' THEN
     x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.TRANSACTIONAL_CURR_CODE;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'TRANSACTIONAL_CURR_CODE';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.TRANSACTIONAL_CURR_CODE;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.TRANSACTIONAL_CURR_CODE;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.TRANSACTIONAL_CURR_CODE;
END IF; /*  NEXT */
END IF;

/* END TRANSACTIONAL_CURR_CODE*/
/****************************/

/****************************/
/* START shipping_instructions*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.shipping_instructions,
       p_prior_rec.shipping_instructions) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'shipping_instructions';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.shipping_instructions;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.shipping_instructions;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.shipping_instructions,
       p_next_rec.shipping_instructions) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.shipping_instructions;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'shipping_instructions';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.shipping_instructions;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.shipping_instructions;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.shipping_instructions;
END IF; /*  NEXT */
END IF;

/* END shipping_instructions*/
/****************************/

/****************************/
/* START packing_instructions*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.packing_instructions,
       p_prior_rec.packing_instructions) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'packing_instructions';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.packing_instructions;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.packing_instructions;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.packing_instructions,
       p_next_rec.packing_instructions) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.packing_instructions;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'packing_instructions';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.packing_instructions;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.packing_instructions;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.packing_instructions;
END IF; /*  NEXT */
END IF;

/* END packing_instructions*/
/****************************/

/****************************/
/* START flow_status_code*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.flow_status_code,
       p_prior_rec.flow_status_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'flow_status';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.flow_status_code;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.flow_status(p_curr_rec.flow_status_code);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.flow_status_code;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.flow_status(p_prior_rec.flow_status_code);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.flow_status_code,
       p_next_rec.flow_status_code) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.flow_status(p_curr_rec.flow_status_code);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'flow_status';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.flow_status_code;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.flow_status(p_prior_rec.flow_status_code);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.flow_status_code;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.flow_status(p_curr_rec.flow_status_code);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.flow_status_code;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.flow_status(p_next_rec.flow_status_code);
END IF;
END IF; /*  NEXT */

/* END flow_status_code*/
/****************************/

/****************************/
/* START sales_document_name*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.sales_document_name,
       p_prior_rec.sales_document_name) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'sales_document_name';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.sales_document_name;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.sales_document_name;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.sales_document_name,
       p_next_rec.sales_document_name) THEN
    IF prior_exists = 'Y' THEN
     x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.sales_document_name;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'sales_document_name';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.sales_document_name;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.sales_document_name;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.sales_document_name;
END IF; /*  NEXT */
END IF;

/* END sales_document_name*/
/****************************/
/****************************/
/* START transaction_phase_code*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.transaction_phase_code,
       p_prior_rec.transaction_phase_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'transaction_phase';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.transaction_phase_code;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Transaction_Phase(p_curr_rec.transaction_phase_code);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.transaction_phase_code;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Transaction_Phase(p_prior_rec.transaction_phase_code);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.transaction_phase_code,
       p_next_rec.transaction_phase_code) THEN
    IF prior_exists = 'Y' THEN
    x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Transaction_Phase(p_curr_rec.transaction_phase_code);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'transaction_phase';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.transaction_phase_code;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Transaction_Phase(p_prior_rec.transaction_phase_code);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.transaction_phase_code;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Transaction_Phase(p_curr_rec.transaction_phase_code);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.transaction_phase_code;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Transaction_Phase(p_next_rec.transaction_phase_code);
END IF; /*  NEXT */
END IF;

/* END transaction_phase_code*/
/****************************/
/****************************/
/* START user_status_code*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.user_status_code,
       p_prior_rec.user_status_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'user_status';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.user_status_code;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.User_Status(p_curr_rec.user_status_code);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.user_status_code;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.User_Status(p_prior_rec.user_status_code);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.user_status_code,
       p_next_rec.user_status_code) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.User_Status(p_curr_rec.user_status_code);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'user_status';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.user_status_code;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.User_Status(p_prior_rec.user_status_code);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.user_status_code;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.User_Status(p_curr_rec.user_status_code);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.user_status_code;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.User_Status(p_next_rec.user_status_code);
END IF; /*  NEXT */
END IF;

/* END user_status_code*/
/****************************/



/****************************/
/* START sold_to_site_use_id*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.sold_to_site_use_id,
       p_prior_rec.sold_to_site_use_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'Customer_Location';
   if p_curr_rec.sold_to_site_use_id is not null then
     OE_ID_TO_VALUE.Customer_Location
         (   p_sold_to_site_use_id        => p_curr_rec.sold_to_site_use_id
        , x_sold_to_location_address1    => x_sold_to_location_address1
        , x_sold_to_location_address2    => x_sold_to_location_address2
	, x_sold_to_location_address3    => x_sold_to_location_address3
	, x_sold_to_location_address4    => x_sold_to_location_address4
	, x_sold_to_location             => x_sold_to_location
	, x_sold_to_location_city        => x_sold_to_location_city
	, x_sold_to_location_state       => x_sold_to_location_state
	, x_sold_to_location_postal      => x_sold_to_location_postal_code
	, x_sold_to_location_country     => x_sold_to_location_country
          );

  select
    DECODE(x_sold_to_location, NULL, NULL,x_sold_to_location|| ', ') ||
    DECODE(x_sold_to_location_address1, NULL, NULL,x_sold_to_location_address1 || ', ') ||
    DECODE(x_sold_to_location_address2, NULL, NULL,x_sold_to_location_address3 || ', ') ||
    DECODE(x_sold_to_location_address3, NULL, NULL,x_sold_to_location_address3 || ', ') ||
    DECODE(x_sold_to_location_address4, NULL, NULL,x_sold_to_location_address4 || ', ') ||
    DECODE(x_sold_to_location_city, NULL, NULL,x_sold_to_location_city || ', ') ||
    DECODE(x_sold_to_location_state, NULL, NULL,x_sold_to_location_state || ', ') ||
    DECODE(x_sold_to_location_postal_code, NULL, NULL,x_sold_to_location_postal_code || ', ') ||
    DECODE(x_sold_to_location_country, NULL,NULL,x_sold_to_location_country)
        into x_current_sold_to_location from dual;
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.sold_to_site_use_id;

   x_header_changed_attr_tbl(ind).current_value     := x_current_sold_to_location;

       end if;
   if p_prior_rec.sold_to_site_use_id is not null then
     OE_ID_TO_VALUE.Customer_Location
         (   p_sold_to_site_use_id        => p_prior_rec.sold_to_site_use_id
        , x_sold_to_location_address1    => x_sold_to_location_address1
        , x_sold_to_location_address2    => x_sold_to_location_address2
	, x_sold_to_location_address3    => x_sold_to_location_address3
	, x_sold_to_location_address4    => x_sold_to_location_address4
	, x_sold_to_location             => x_sold_to_location
	, x_sold_to_location_city        => x_sold_to_location_city
	, x_sold_to_location_state       => x_sold_to_location_state
	, x_sold_to_location_postal      => x_sold_to_location_postal_code
	, x_sold_to_location_country     => x_sold_to_location_country
          );

  select
    DECODE(x_sold_to_location, NULL, NULL,x_sold_to_location|| ', ') ||
    DECODE(x_sold_to_location_address1, NULL, NULL,x_sold_to_location_address1 || ', ') ||
    DECODE(x_sold_to_location_address2, NULL, NULL,x_sold_to_location_address3 || ', ') ||
    DECODE(x_sold_to_location_address3, NULL, NULL,x_sold_to_location_address3 || ', ') ||
    DECODE(x_sold_to_location_address4, NULL, NULL,x_sold_to_location_address4 || ', ') ||
    DECODE(x_sold_to_location_city, NULL, NULL,x_sold_to_location_city || ', ') ||
    DECODE(x_sold_to_location_state, NULL, NULL,x_sold_to_location_state || ', ') ||
    DECODE(x_sold_to_location_postal_code, NULL, NULL,x_sold_to_location_postal_code || ', ') ||
    DECODE(x_sold_to_location_country, NULL,NULL,x_sold_to_location_country)
        into x_prior_sold_to_location from dual;
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.sold_to_site_use_id;
   x_header_changed_attr_tbl(ind).prior_value     := x_prior_sold_to_location;
       end if;
END IF;
END IF; /*  PRIOR */
/****************************/

IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.sold_to_site_use_id,
       p_next_rec.sold_to_site_use_id) THEN
    IF prior_exists = 'Y' THEN
     x_header_changed_attr_tbl(ind).next_value     := x_current_sold_to_location;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'customer_location';

   if p_prior_rec.sold_to_site_use_id is not null then
     OE_ID_TO_VALUE.customer_location
         (   p_sold_to_site_use_id        => p_prior_rec.sold_to_site_use_id
        , x_sold_to_location_address1    => x_sold_to_location_address1
        , x_sold_to_location_address2    => x_sold_to_location_address2
	, x_sold_to_location_address3    => x_sold_to_location_address3
	, x_sold_to_location_address4    => x_sold_to_location_address4
	, x_sold_to_location             => x_sold_to_location
	, x_sold_to_location_city        => x_sold_to_location_city
	, x_sold_to_location_state       => x_sold_to_location_state
	, x_sold_to_location_postal      => x_sold_to_location_postal_code
	, x_sold_to_location_country     => x_sold_to_location_country
          );

  select
    DECODE(x_sold_to_location, NULL, NULL,x_sold_to_location|| ', ') ||
    DECODE(x_sold_to_location_address1, NULL, NULL,x_sold_to_location_address1 || ', ') ||
    DECODE(x_sold_to_location_address2, NULL, NULL,x_sold_to_location_address3 || ', ') ||
    DECODE(x_sold_to_location_address3, NULL, NULL,x_sold_to_location_address3 || ', ') ||
    DECODE(x_sold_to_location_address4, NULL, NULL,x_sold_to_location_address4 || ', ') ||
    DECODE(x_sold_to_location_city, NULL, NULL,x_sold_to_location_city || ', ') ||
    DECODE(x_sold_to_location_state, NULL, NULL,x_sold_to_location_state || ', ') ||
    DECODE(x_sold_to_location_postal_code, NULL, NULL,x_sold_to_location_postal_code || ', ') ||
    DECODE(x_sold_to_location_country, NULL,NULL,x_sold_to_location_country)
        into x_prior_sold_to_location from dual;
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.sold_to_site_use_id;
   x_header_changed_attr_tbl(ind).prior_value     := x_prior_sold_to_location;
       end if;

   if p_curr_rec.sold_to_site_use_id is not null then
     OE_ID_TO_VALUE.customer_location
         (   p_sold_to_site_use_id        => p_curr_rec.sold_to_site_use_id
        , x_sold_to_location_address1    => x_sold_to_location_address1
        , x_sold_to_location_address2    => x_sold_to_location_address2
	, x_sold_to_location_address3    => x_sold_to_location_address3
	, x_sold_to_location_address4    => x_sold_to_location_address4
	, x_sold_to_location             => x_sold_to_location
	, x_sold_to_location_city        => x_sold_to_location_city
	, x_sold_to_location_state       => x_sold_to_location_state
	, x_sold_to_location_postal      => x_sold_to_location_postal_code
	, x_sold_to_location_country     => x_sold_to_location_country
          );

  select
    DECODE(x_sold_to_location, NULL, NULL,x_sold_to_location|| ', ') ||
    DECODE(x_sold_to_location_address1, NULL, NULL,x_sold_to_location_address1 || ', ') ||
    DECODE(x_sold_to_location_address2, NULL, NULL,x_sold_to_location_address3 || ', ') ||
    DECODE(x_sold_to_location_address3, NULL, NULL,x_sold_to_location_address3 || ', ') ||
    DECODE(x_sold_to_location_address4, NULL, NULL,x_sold_to_location_address4 || ', ') ||
    DECODE(x_sold_to_location_city, NULL, NULL,x_sold_to_location_city || ', ') ||
    DECODE(x_sold_to_location_state, NULL, NULL,x_sold_to_location_state || ', ') ||
    DECODE(x_sold_to_location_postal_code, NULL, NULL,x_sold_to_location_postal_code || ', ') ||
    DECODE(x_sold_to_location_country, NULL,NULL,x_sold_to_location_country)
        into x_current_sold_to_location from dual;
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.sold_to_site_use_id;
   x_header_changed_attr_tbl(ind).current_value     := x_current_sold_to_location;
       end if;

   if p_next_rec.sold_to_site_use_id is not null then
     OE_ID_TO_VALUE.customer_location
         (   p_sold_to_site_use_id        => p_next_rec.sold_to_site_use_id
        , x_sold_to_location_address1    => x_sold_to_location_address1
        , x_sold_to_location_address2    => x_sold_to_location_address2
	, x_sold_to_location_address3    => x_sold_to_location_address3
	, x_sold_to_location_address4    => x_sold_to_location_address4
	, x_sold_to_location             => x_sold_to_location
	, x_sold_to_location_city        => x_sold_to_location_city
	, x_sold_to_location_state       => x_sold_to_location_state
	, x_sold_to_location_postal      => x_sold_to_location_postal_code
	, x_sold_to_location_country     => x_sold_to_location_country
          );

  select
    DECODE(x_sold_to_location, NULL, NULL,x_sold_to_location|| ', ') ||
    DECODE(x_sold_to_location_address1, NULL, NULL,x_sold_to_location_address1 || ', ') ||
    DECODE(x_sold_to_location_address2, NULL, NULL,x_sold_to_location_address3 || ', ') ||
    DECODE(x_sold_to_location_address3, NULL, NULL,x_sold_to_location_address3 || ', ') ||
    DECODE(x_sold_to_location_address4, NULL, NULL,x_sold_to_location_address4 || ', ') ||
    DECODE(x_sold_to_location_city, NULL, NULL,x_sold_to_location_city || ', ') ||
    DECODE(x_sold_to_location_state, NULL, NULL,x_sold_to_location_state || ', ') ||
    DECODE(x_sold_to_location_postal_code, NULL, NULL,x_sold_to_location_postal_code || ', ') ||
    DECODE(x_sold_to_location_country, NULL,NULL,x_sold_to_location_country)
        into x_next_sold_to_location from dual;
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.sold_to_site_use_id;
   x_header_changed_attr_tbl(ind).next_value     := x_next_sold_to_location;
       end if;
END IF; /*  NEXT */
END IF;

/* END sold_to_site_use_id*/
/****************************/

/****************************/
/* START SUPPLIER_SIGNATURE*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.SUPPLIER_SIGNATURE,
       p_prior_rec.SUPPLIER_SIGNATURE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'SUPPLIER_SIGNATURE';
   x_header_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.SUPPLIER_SIGNATURE,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.SUPPLIER_SIGNATURE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.SUPPLIER_SIGNATURE,
       p_next_rec.SUPPLIER_SIGNATURE) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.SUPPLIER_SIGNATURE,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'SUPPLIER_SIGNATURE';
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.SUPPLIER_SIGNATURE,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.SUPPLIER_SIGNATURE,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.SUPPLIER_SIGNATURE,'DD-MON-YYYY HH24:MI:SS');
END IF; /*  NEXT */
END IF;

/* END SUPPLIER_SIGNATURE*/
/****************************/
/****************************/
/* START SUPPLIER_SIGNATURE_DATE*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.SUPPLIER_SIGNATURE_DATE,
       p_prior_rec.SUPPLIER_SIGNATURE_DATE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'SUPPLIER_SIGNATURE_DATE';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.SUPPLIER_SIGNATURE_DATE;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.SUPPLIER_SIGNATURE_DATE;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.SUPPLIER_SIGNATURE_DATE,
       p_next_rec.SUPPLIER_SIGNATURE_DATE) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.SUPPLIER_SIGNATURE_DATE;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'SUPPLIER_SIGNATURE_DATE';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.SUPPLIER_SIGNATURE_DATE;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.SUPPLIER_SIGNATURE_DATE;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.SUPPLIER_SIGNATURE_DATE;
END IF; /*  NEXT */
END IF;

/* END SUPPLIER_SIGNATURE_DATE*/
/****************************/
/****************************/
/* START CUSTOMER_SIGNATURE*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.CUSTOMER_SIGNATURE,
       p_prior_rec.CUSTOMER_SIGNATURE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'CUSTOMER_SIGNATURE';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.CUSTOMER_SIGNATURE;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.CUSTOMER_SIGNATURE;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.CUSTOMER_SIGNATURE,
       p_next_rec.CUSTOMER_SIGNATURE) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.CUSTOMER_SIGNATURE;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'CUSTOMER_SIGNATURE';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.CUSTOMER_SIGNATURE;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.CUSTOMER_SIGNATURE;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.CUSTOMER_SIGNATURE;
END IF; /*  NEXT */
END IF;

/* END CUSTOMER_SIGNATURE*/
/****************************/
/****************************/
/* START CUSTOMER_SIGNATURE_DATE*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.CUSTOMER_SIGNATURE_DATE,
       p_prior_rec.CUSTOMER_SIGNATURE_DATE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'CUSTOMER_SIGNATURE_DATE';
   x_header_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.CUSTOMER_SIGNATURE_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.CUSTOMER_SIGNATURE_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.CUSTOMER_SIGNATURE_DATE,
       p_next_rec.CUSTOMER_SIGNATURE_DATE) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.CUSTOMER_SIGNATURE_DATE,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'CUSTOMER_SIGNATURE_DATE';
   x_header_changed_attr_tbl(ind).prior_value        :=to_char( p_prior_rec.CUSTOMER_SIGNATURE_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.CUSTOMER_SIGNATURE_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.CUSTOMER_SIGNATURE_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF; /*  NEXT */
END IF;

/* END CUSTOMER_SIGNATURE_DATE*/
/****************************/

/****************************/
/* START START_DATE_ACTIVE*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.START_DATE_ACTIVE,
       p_prior_rec.START_DATE_ACTIVE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'START_DATE_ACTIVE';
   x_header_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.START_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.START_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.START_DATE_ACTIVE,
       p_next_rec.START_DATE_ACTIVE) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.START_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'START_DATE_ACTIVE';
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.START_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.START_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.START_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
END IF; /*  NEXT */
END IF;

/* END START_DATE_ACTIVE*/
/****************************/

/****************************/
/* START END_DATE_ACTIVE*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.END_DATE_ACTIVE,
       p_prior_rec.END_DATE_ACTIVE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'END_DATE_ACTIVE';
   x_header_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.END_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.END_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.END_DATE_ACTIVE,
       p_next_rec.END_DATE_ACTIVE) THEN
    IF prior_exists = 'Y' THEN
     x_header_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.END_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'END_DATE_ACTIVE';
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.END_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.END_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.END_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
END IF; /*  NEXT */
END IF;

/* END END_DATE_ACTIVE*/
/****************************/

/****************************/
/* START on_hold_flag*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.on_hold_flag,
       p_prior_rec.on_hold_flag) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'on_hold_flag';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.on_hold_flag;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.on_hold_flag;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.on_hold_flag,
       p_next_rec.on_hold_flag) THEN
    IF prior_exists = 'Y' THEN
    x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.on_hold_flag;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'on_hold_flag';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.on_hold_flag;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.on_hold_flag;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.on_hold_flag;
END IF; /*  NEXT */
END IF;

/* END on_hold_flag*/
/****************************/

/****************************/
/* START ENFORCE_PRICE_LIST_FLAG*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.ENFORCE_PRICE_LIST_FLAG,
       p_prior_rec.ENFORCE_PRICE_LIST_FLAG) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'ENFORCE_PRICE_LIST_FLAG';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.ENFORCE_PRICE_LIST_FLAG;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.ENFORCE_PRICE_LIST_FLAG;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.ENFORCE_PRICE_LIST_FLAG,
       p_next_rec.ENFORCE_PRICE_LIST_FLAG) THEN
    IF prior_exists = 'Y' THEN
     x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.ENFORCE_PRICE_LIST_FLAG;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'ENFORCE_PRICE_LIST_FLAG';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.ENFORCE_PRICE_LIST_FLAG;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.ENFORCE_PRICE_LIST_FLAG;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.ENFORCE_PRICE_LIST_FLAG;
END IF; /*  NEXT */
END IF;

/* END ENFORCE_PRICE_LIST_FLAG*/
/****************************/

/****************************/
/* START enforce_ship_to_flag*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_ship_to_flag,
       p_prior_rec.enforce_ship_to_flag) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'enforce_ship_to_flag';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.enforce_ship_to_flag;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_ship_to_flag;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_ship_to_flag,
       p_next_rec.enforce_ship_to_flag) THEN
    IF prior_exists = 'Y' THEN
    x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.enforce_ship_to_flag;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'enforce_ship_to_flag';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_ship_to_flag;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.enforce_ship_to_flag;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.enforce_ship_to_flag;
END IF; /*  NEXT */
END IF;

/* END enforce_ship_to_flag*/
/****************************/

/****************************/
/* START enforce_invoice_to_flag*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_invoice_to_flag,
       p_prior_rec.enforce_invoice_to_flag) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'enforce_invoice_to_flag';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.enforce_invoice_to_flag;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_invoice_to_flag;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_invoice_to_flag,
       p_next_rec.enforce_invoice_to_flag) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.enforce_invoice_to_flag;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'enforce_invoice_to_flag';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_invoice_to_flag;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.enforce_invoice_to_flag;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.enforce_invoice_to_flag;
END IF; /*  NEXT */
END IF;

/* END enforce_invoice_to_flag*/
/****************************/

/****************************/
/* START enforce_freight_term_flag*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_freight_term_flag,
       p_prior_rec.enforce_freight_term_flag) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'enforce_freight_term_flag';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.enforce_freight_term_flag;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_freight_term_flag;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_freight_term_flag,
       p_next_rec.enforce_freight_term_flag) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.enforce_freight_term_flag;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'enforce_freight_term_flag';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_freight_term_flag;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.enforce_freight_term_flag;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.enforce_freight_term_flag;
END IF; /*  NEXT */
END IF;

/* END enforce_freight_term_flag*/
/****************************/

/****************************/
/* START enforce_shipping_method_flag*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_shipping_method_flag,
       p_prior_rec.enforce_shipping_method_flag) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'enforce_shipping_method_flag';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.enforce_shipping_method_flag;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_shipping_method_flag;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_shipping_method_flag,
       p_next_rec.enforce_shipping_method_flag) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.enforce_shipping_method_flag;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'enforce_shipping_method_flag';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_shipping_method_flag;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.enforce_shipping_method_flag;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.enforce_shipping_method_flag;
END IF; /*  NEXT */
END IF;

/* END enforce_shipping_method_flag*/
/****************************/

/****************************/
/* START enforce_payment_term_flag*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_payment_term_flag,
       p_prior_rec.enforce_payment_term_flag) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'enforce_payment_term_flag';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.enforce_payment_term_flag;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_payment_term_flag;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_payment_term_flag,
       p_next_rec.enforce_payment_term_flag) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.enforce_payment_term_flag;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'enforce_payment_term_flag';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_payment_term_flag;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.enforce_payment_term_flag;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.enforce_payment_term_flag;
END IF; /*  NEXT */
END IF;

/* END enforce_payment_term_flag*/
/****************************/

/****************************/
/* START enforce_accounting_rule_flag*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_accounting_rule_flag,
       p_prior_rec.enforce_accounting_rule_flag) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'enforce_accounting_rule_flag';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.enforce_accounting_rule_flag;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_accounting_rule_flag;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_accounting_rule_flag,
       p_next_rec.enforce_accounting_rule_flag) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.enforce_accounting_rule_flag;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'enforce_accounting_rule_flag';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_accounting_rule_flag;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.enforce_accounting_rule_flag;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.enforce_accounting_rule_flag;
END IF; /*  NEXT */
END IF;

/* END enforce_accounting_rule_flag*/
/****************************/

/****************************/
/* START enforce_invoicing_rule_flag*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_invoicing_rule_flag,
       p_prior_rec.enforce_invoicing_rule_flag) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'enforce_invoicing_rule_flag';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.enforce_invoicing_rule_flag;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_invoicing_rule_flag;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_invoicing_rule_flag,
       p_next_rec.enforce_invoicing_rule_flag) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.enforce_invoicing_rule_flag;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'enforce_invoicing_rule_flag';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_invoicing_rule_flag;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.enforce_invoicing_rule_flag;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.enforce_invoicing_rule_flag;
END IF; /*  NEXT */
END IF;

/* END enforce_invoicing_rule_flag*/
/****************************/

/****************************/
/* START OVERRIDE_AMOUNT_FLAG*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.OVERRIDE_AMOUNT_FLAG,
       p_prior_rec.OVERRIDE_AMOUNT_FLAG) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'OVERRIDE_AMOUNT_FLAG';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.OVERRIDE_AMOUNT_FLAG;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.OVERRIDE_AMOUNT_FLAG;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.OVERRIDE_AMOUNT_FLAG,
       p_next_rec.OVERRIDE_AMOUNT_FLAG) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.OVERRIDE_AMOUNT_FLAG;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'OVERRIDE_AMOUNT_FLAG';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.OVERRIDE_AMOUNT_FLAG;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.OVERRIDE_AMOUNT_FLAG;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.OVERRIDE_AMOUNT_FLAG;
END IF; /*  NEXT */
END IF;

/* END OVERRIDE_AMOUNT_FLAG*/
/****************************/

/****************************/
/* START BLANKET_MAX_AMOUNT*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.BLANKET_MAX_AMOUNT,
       p_prior_rec.BLANKET_MAX_AMOUNT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'BLANKET_MAX_AMOUNT';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.BLANKET_MAX_AMOUNT;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.BLANKET_MAX_AMOUNT;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.BLANKET_MAX_AMOUNT,
       p_next_rec.BLANKET_MAX_AMOUNT) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.BLANKET_MAX_AMOUNT;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'BLANKET_MAX_AMOUNT';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.BLANKET_MAX_AMOUNT;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.BLANKET_MAX_AMOUNT;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.BLANKET_MAX_AMOUNT;
END IF; /*  NEXT */
END IF;

/* END BLANKET_MAX_AMOUNT*/
/****************************/

/****************************/
/* START BLANKET_MIN_AMOUNT*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.BLANKET_MIN_AMOUNT,
       p_prior_rec.BLANKET_MIN_AMOUNT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'BLANKET_MIN_AMOUNT';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.BLANKET_MIN_AMOUNT;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.BLANKET_MIN_AMOUNT;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.BLANKET_MIN_AMOUNT,
       p_next_rec.BLANKET_MIN_AMOUNT) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.BLANKET_MIN_AMOUNT;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'BLANKET_MIN_AMOUNT';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.BLANKET_MIN_AMOUNT;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.BLANKET_MIN_AMOUNT;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.BLANKET_MIN_AMOUNT;
END IF; /*  NEXT */
END IF;

/* END BLANKET_MIN_AMOUNT*/
/****************************/

/****************************/
/* START RELEASED_AMOUNT*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.RELEASED_AMOUNT,
       p_prior_rec.RELEASED_AMOUNT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'RELEASED_AMOUNT';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.RELEASED_AMOUNT;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.RELEASED_AMOUNT;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.RELEASED_AMOUNT,
       p_next_rec.RELEASED_AMOUNT) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.RELEASED_AMOUNT;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'RELEASED_AMOUNT';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.RELEASED_AMOUNT;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.RELEASED_AMOUNT;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.RELEASED_AMOUNT;
END IF; /*  NEXT */
END IF;

/* END RELEASED_AMOUNT*/
/****************************/

/****************************/
/* START FULFILLED_AMOUNT*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.FULFILLED_AMOUNT,
       p_prior_rec.FULFILLED_AMOUNT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'FULFILLED_AMOUNT';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.FULFILLED_AMOUNT;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.FULFILLED_AMOUNT;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.FULFILLED_AMOUNT,
       p_next_rec.FULFILLED_AMOUNT) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.FULFILLED_AMOUNT;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'FULFILLED_AMOUNT';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.FULFILLED_AMOUNT;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.FULFILLED_AMOUNT;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.FULFILLED_AMOUNT;
END IF; /*  NEXT */
END IF;

/* END FULFILLED_AMOUNT*/
/****************************/

/****************************/
/* START RETURNED_AMOUNT*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.RETURNED_AMOUNT,
       p_prior_rec.RETURNED_AMOUNT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'RETURNED_AMOUNT';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.RETURNED_AMOUNT;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.RETURNED_AMOUNT;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.RETURNED_AMOUNT,
       p_next_rec.RETURNED_AMOUNT) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.RETURNED_AMOUNT;
    END IF;
 null;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'RETURNED_AMOUNT';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.RETURNED_AMOUNT;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.RETURNED_AMOUNT;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.RETURNED_AMOUNT;
END IF; /*  NEXT */
END IF;

/* END RETURNED_AMOUNT*/
/****************************/
/****************************/
/* START NEW_PRICE_LIST_ID*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.NEW_PRICE_LIST_ID,
       p_prior_rec.NEW_PRICE_LIST_ID) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'NEW_PRICE_LIST_NAME';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.NEW_PRICE_LIST_ID;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.PRICE_LIST(p_curr_rec.NEW_PRICE_LIST_ID);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.NEW_PRICE_LIST_ID;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.PRICE_LIST(p_prior_rec.NEW_PRICE_LIST_ID);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.NEW_PRICE_LIST_ID,
       p_next_rec.NEW_PRICE_LIST_ID) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.PRICE_LIST(p_curr_rec.NEW_PRICE_LIST_ID);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'NEW_PRICE_LIST_NAME';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.NEW_PRICE_LIST_ID;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.PRICE_LIST(p_prior_rec.NEW_PRICE_LIST_ID);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.NEW_PRICE_LIST_ID;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.PRICE_LIST(p_curr_rec.NEW_PRICE_LIST_ID);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.NEW_PRICE_LIST_ID;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.PRICE_LIST(p_next_rec.NEW_PRICE_LIST_ID);
END IF; /*  NEXT */
END IF;

/* END NEW_PRICE_LIST_ID*/
/****************************/

/****************************/
/* START NEW_MODIFIER_LIST_ID*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.NEW_MODIFIER_LIST_ID,
       p_prior_rec.NEW_MODIFIER_LIST_ID) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'NEW_MODIFIER_LIST_NAME';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.NEW_MODIFIER_LIST_ID;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.NEW_MODIFIER_LIST(p_curr_rec.NEW_MODIFIER_LIST_ID);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.NEW_MODIFIER_LIST_ID;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.NEW_MODIFIER_LIST(p_prior_rec.NEW_MODIFIER_LIST_ID);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.NEW_MODIFIER_LIST_ID,
       p_next_rec.NEW_MODIFIER_LIST_ID) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.NEW_MODIFIER_LIST(p_curr_rec.NEW_MODIFIER_LIST_ID);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'NEW_MODIFIER_LIST_NAME';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.NEW_MODIFIER_LIST_ID;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.NEW_MODIFIER_LIST(p_prior_rec.NEW_MODIFIER_LIST_ID);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.NEW_MODIFIER_LIST_ID;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.NEW_MODIFIER_LIST(p_curr_rec.NEW_MODIFIER_LIST_ID);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.NEW_MODIFIER_LIST_ID;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.NEW_MODIFIER_LIST(p_next_rec.NEW_MODIFIER_LIST_ID);
END IF; /*  NEXT */
END IF;

/* END NEW_MODIFIER_LIST_ID*/
/****************************/

/****************************/
/* START default_discount_percent*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.default_discount_percent,
       p_prior_rec.default_discount_percent) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'default_discount_percent';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.default_discount_percent;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.default_discount_percent;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.default_discount_percent,
       p_next_rec.default_discount_percent) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.default_discount_percent;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'default_discount_percent';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.default_discount_percent;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.default_discount_percent;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.default_discount_percent;
END IF; /*  NEXT */
END IF;

/* END default_discount_percent*/
/****************************/

/****************************/
/* START default_discount_amount*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.default_discount_amount,
       p_prior_rec.default_discount_amount) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'default_discount_amount';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.default_discount_amount;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.default_discount_amount;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.default_discount_amount,
       p_next_rec.default_discount_amount) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.default_discount_amount;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'default_discount_amount';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.default_discount_amount;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.default_discount_amount;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.default_discount_amount;
END IF; /*  NEXT */
END IF;

/* END default_discount_amount*/
/****************************/
ELSE
NULL;
END IF;
/*
j := 0;
dbms_output.put_line('No of records'||x_header_changed_attr_tbl.count);
WHILE j < x_header_changed_attr_tbl.count
LOOP
j:=j+1;
dbms_output.put_line('attribute value '||x_header_changed_attr_tbl(j).attribute_name ||
||' Prior '||x_header_changed_attr_tbl(j).prior_value||
||' Current '||x_header_changed_attr_tbl(j).current_value ||
|| ' Next '||x_header_changed_attr_tbl(j).next_value);
END LOOP;
*/
IF l_debug_level > 0 THEN
  oe_debug_pub.add('******AFTER COMPARING HEADER ATTRIBUTES*************');
  oe_debug_pub.add('current ind '|| ind);
END IF;
END COMPARE_HEADER_VERSIONS;

PROCEDURE QUERY_LINE_ROW
(p_header_id	                  NUMBER,
 p_line_id	                  NUMBER,
 p_version	                  NUMBER,
 p_phase_change_flag              VARCHAR2,
 x_line_rec	                  IN OUT NOCOPY OE_Blanket_PUB.line_rec_type)
IS
l_org_id                NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering OE_VERSION_BLANKET_COMP.QUERY_LINE_ROW');
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('version' ||p_version);
  oe_debug_pub.add('phase_change_lfag' ||p_phase_change_flag);
END IF;

    l_org_id := OE_GLOBALS.G_ORG_ID;

    IF l_org_id IS NULL THEN
      OE_GLOBALS.Set_Context;
      l_org_id := OE_GLOBALS.G_ORG_ID;
    END IF;

    SELECT  ACCOUNTING_RULE_ID
    ,       AGREEMENT_ID
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CUST_PO_NUMBER
    ,       DELIVER_TO_ORG_ID
    ,       FREIGHT_TERMS_CODE
    ,       header_id
    ,       min_release_quantity
    ,       max_release_quantity
    ,       inventory_item_id
    ,       INVOICE_TO_ORG_ID
    ,       INVOICING_RULE_ID
    ,       ORDERED_ITEM_ID
    ,       item_identifier_type
    ,       ORDERED_ITEM
    ,       ITEM_TYPE_CODE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       line_id
    ,       line_number
    ,       PAYMENT_TERM_ID
    ,       PREFERRED_GRADE
    ,       PRICE_LIST_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       SALESREP_ID
    ,       SHIPPING_METHOD_CODE
    ,       ship_from_org_id
    ,       SHIP_TO_ORG_ID
    ,       SHIPPING_INSTRUCTIONS
    ,       PACKING_INSTRUCTIONS
    ,       START_DATE_ACTIVE
    ,       END_DATE_ACTIVE
    ,       MAX_RELEASE_AMOUNT
    ,       MIN_RELEASE_AMOUNT
    ,       BLANKET_LINE_MAX_AMOUNT
    ,       BLANKET_LINE_MIN_AMOUNT
    ,       BLANKET_MAX_QUANTITY
    ,       BLANKET_MIN_QUANTITY
    ,       OVERRIDE_BLANKET_CONTROLS_FLAG
    ,       OVERRIDE_RELEASE_CONTROLS_FLAG
    ,       ENFORCE_PRICE_LIST_FLAG
    ,       enforce_ship_to_flag
    ,       enforce_invoice_to_flag
    ,       enforce_freight_term_flag
    ,       enforce_shipping_method_flag
    ,       enforce_payment_term_flag
    ,       enforce_accounting_rule_flag
    ,       enforce_invoicing_rule_flag
    ,       ORDER_QUANTITY_UOM
    ,       RELEASED_QUANTITY
    ,       FULFILLED_QUANTITY
    ,       RETURNED_QUANTITY
    ,       ORDER_NUMBER
    ,       RELEASED_AMOUNT
    ,       FULFILLED_AMOUNT
    ,       RETURNED_AMOUNT
    ,       TRANSACTION_PHASE_CODE
    ,       source_document_version_number
    ,       modifier_list_line_id
   INTO
    x_line_rec.ACCOUNTING_RULE_ID
    ,x_line_rec.AGREEMENT_ID
    ,x_line_rec.ATTRIBUTE1
    ,x_line_rec.ATTRIBUTE10
    ,x_line_rec.ATTRIBUTE11
    ,x_line_rec.ATTRIBUTE12
    ,x_line_rec.ATTRIBUTE13
    ,x_line_rec.ATTRIBUTE14
    ,x_line_rec.ATTRIBUTE15
    ,x_line_rec.ATTRIBUTE2
    ,x_line_rec.ATTRIBUTE3
    ,x_line_rec.ATTRIBUTE4
    ,x_line_rec.ATTRIBUTE5
    ,x_line_rec.ATTRIBUTE6
    ,x_line_rec.ATTRIBUTE7
    ,x_line_rec.ATTRIBUTE8
    ,x_line_rec.ATTRIBUTE9
    ,x_line_rec.CONTEXT
    ,x_line_rec.CREATED_BY
    ,x_line_rec.CREATION_DATE
    ,x_line_rec.CUST_PO_NUMBER
    ,x_line_rec.DELIVER_TO_ORG_ID
    ,x_line_rec.FREIGHT_TERMS_CODE
    ,x_line_rec.header_id
    ,x_line_rec.min_release_quantity
    ,x_line_rec.max_release_quantity
    ,x_line_rec.inventory_item_id
    ,x_line_rec.INVOICE_TO_ORG_ID
    ,x_line_rec.INVOICING_RULE_ID
    ,x_line_rec.ORDERED_ITEM_ID
    ,x_line_rec.item_identifier_type
    ,x_line_rec.ORDERED_ITEM
    ,x_line_rec.ITEM_TYPE_CODE
    ,x_line_rec.LAST_UPDATED_BY
    ,x_line_rec.LAST_UPDATE_DATE
    ,x_line_rec.LAST_UPDATE_LOGIN
    ,x_line_rec.line_id
    ,x_line_rec.line_number
    ,x_line_rec.PAYMENT_TERM_ID
    ,x_line_rec.PREFERRED_GRADE
    ,x_line_rec.PRICE_LIST_ID
    ,x_line_rec.PROGRAM_APPLICATION_ID
    ,x_line_rec.PROGRAM_ID
    ,x_line_rec.PROGRAM_UPDATE_DATE
    ,x_line_rec.REQUEST_ID
    ,x_line_rec.SALESREP_ID
    ,x_line_rec.SHIPPING_METHOD_CODE
    ,x_line_rec.ship_from_org_id
    ,x_line_rec.SHIP_TO_ORG_ID
    ,x_line_rec.SHIPPING_INSTRUCTIONS
    ,x_line_rec.PACKING_INSTRUCTIONS
    ,x_line_rec.START_DATE_ACTIVE
    ,x_line_rec.END_DATE_ACTIVE
    ,x_line_rec.MAX_RELEASE_AMOUNT
    ,x_line_rec.MIN_RELEASE_AMOUNT
    ,x_line_rec.BLANKET_MAX_AMOUNT
    ,x_line_rec.BLANKET_MIN_AMOUNT
    ,x_line_rec.BLANKET_MAX_QUANTITY
    ,x_line_rec.BLANKET_MIN_QUANTITY
    ,x_line_rec.OVERRIDE_BLANKET_CONTROLS_FLAG
    ,x_line_rec.OVERRIDE_RELEASE_CONTROLS_FLAG
    ,x_line_rec.ENFORCE_PRICE_LIST_FLAG
    ,x_line_rec.enforce_ship_to_flag
    ,x_line_rec.enforce_invoice_to_flag
    ,x_line_rec.enforce_freight_term_flag
    ,x_line_rec.enforce_shipping_method_flag
    ,x_line_rec.enforce_payment_term_flag
    ,x_line_rec.enforce_accounting_rule_flag
    ,x_line_rec.enforce_invoicing_rule_flag
    ,x_line_rec.ORDER_QUANTITY_UOM
    ,x_line_rec.RELEASED_QUANTITY
    ,x_line_rec.FULFILLED_QUANTITY
    ,x_line_rec.RETURNED_QUANTITY
    ,x_line_rec.ORDER_NUMBER
    ,x_line_rec.RELEASED_AMOUNT
    ,x_line_rec.FULFILLED_AMOUNT
    ,x_line_rec.RETURNED_AMOUNT
    ,x_line_rec.TRANSACTION_PHASE_CODE
    ,x_line_rec.source_document_version_number
   ,x_line_rec.modifier_list_line_id
    FROM    OE_BLANKET_LINES_HIST
    WHERE
            line_id = p_line_id
      AND   header_id = p_header_id
      AND   version_number = p_version
      AND   sales_document_type_code = 'B'
     AND    (PHASE_CHANGE_FLAG = p_phase_change_flag
     OR     (nvl(p_phase_change_flag, 'NULL') <> 'Y'
     AND     VERSION_FLAG = 'Y'));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
	NULL;
    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
               'Query_Line_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END QUERY_LINE_ROW;

PROCEDURE QUERY_LINE_TRANS_ROW
(p_header_id	                  NUMBER,
 p_line_id	                  NUMBER,
 p_version	                  NUMBER,
 x_line_rec	                  IN OUT NOCOPY OE_Blanket_PUB.line_rec_type)
IS
l_org_id                NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering OE_VERSION_BLANKET_COMP.QUERY_LINE_TRANS_ROW', 1);
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('version' ||p_version);
END IF;

    l_org_id := OE_GLOBALS.G_ORG_ID;

    IF l_org_id IS NULL THEN
      OE_GLOBALS.Set_Context;
      l_org_id := OE_GLOBALS.G_ORG_ID;
    END IF;

    SELECT  ACCOUNTING_RULE_ID
    ,       AGREEMENT_ID
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CUST_PO_NUMBER
    ,       DELIVER_TO_ORG_ID
    ,       FREIGHT_TERMS_CODE
    ,       header_id
    ,       min_release_quantity
    ,       max_release_quantity
    ,       inventory_item_id
    ,       INVOICE_TO_ORG_ID
    ,       INVOICING_RULE_ID
    ,       ORDERED_ITEM_ID
    ,       item_identifier_type
    ,       ORDERED_ITEM
    ,       ITEM_TYPE_CODE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       bl.line_id
    ,       bl.line_number
    ,       PAYMENT_TERM_ID
    ,       PREFERRED_GRADE
    ,       PRICE_LIST_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       SALESREP_ID
    ,       SHIPPING_METHOD_CODE
    ,       ship_from_org_id
    ,       SHIP_TO_ORG_ID
    ,       SHIPPING_INSTRUCTIONS
    ,       PACKING_INSTRUCTIONS
    ,       START_DATE_ACTIVE
    ,       END_DATE_ACTIVE
    ,       MAX_RELEASE_AMOUNT
    ,       MIN_RELEASE_AMOUNT
    ,       BLANKET_LINE_MAX_AMOUNT
    ,       BLANKET_LINE_MIN_AMOUNT
    ,       BLANKET_MAX_QUANTITY
    ,       BLANKET_MIN_QUANTITY
    ,       OVERRIDE_BLANKET_CONTROLS_FLAG
    ,       OVERRIDE_RELEASE_CONTROLS_FLAG
    ,       ENFORCE_PRICE_LIST_FLAG
    ,       enforce_ship_to_flag
    ,       enforce_invoice_to_flag
    ,       enforce_freight_term_flag
    ,       enforce_shipping_method_flag
    ,       enforce_payment_term_flag
    ,       enforce_accounting_rule_flag
    ,       enforce_invoicing_rule_flag
    ,       ORDER_QUANTITY_UOM
    ,       RELEASED_QUANTITY
    ,       blx.FULFILLED_QUANTITY
    ,       RETURNED_QUANTITY
    ,       ORDER_NUMBER
    ,       RELEASED_AMOUNT
    ,       FULFILLED_AMOUNT
    ,       RETURNED_AMOUNT
    ,       TRANSACTION_PHASE_CODE
    ,       source_document_version_number
    ,       modifier_list_line_id
   INTO
    x_line_rec.ACCOUNTING_RULE_ID
    ,x_line_rec.AGREEMENT_ID
    ,x_line_rec.ATTRIBUTE1
    ,x_line_rec.ATTRIBUTE10
    ,x_line_rec.ATTRIBUTE11
    ,x_line_rec.ATTRIBUTE12
    ,x_line_rec.ATTRIBUTE13
    ,x_line_rec.ATTRIBUTE14
    ,x_line_rec.ATTRIBUTE15
    ,x_line_rec.ATTRIBUTE2
    ,x_line_rec.ATTRIBUTE3
    ,x_line_rec.ATTRIBUTE4
    ,x_line_rec.ATTRIBUTE5
    ,x_line_rec.ATTRIBUTE6
    ,x_line_rec.ATTRIBUTE7
    ,x_line_rec.ATTRIBUTE8
    ,x_line_rec.ATTRIBUTE9
    ,x_line_rec.CONTEXT
    ,x_line_rec.CREATED_BY
    ,x_line_rec.CREATION_DATE
    ,x_line_rec.CUST_PO_NUMBER
    ,x_line_rec.DELIVER_TO_ORG_ID
    ,x_line_rec.FREIGHT_TERMS_CODE
    ,x_line_rec.header_id
    ,x_line_rec.min_release_quantity
    ,x_line_rec.max_release_quantity
    ,x_line_rec.inventory_item_id
    ,x_line_rec.INVOICE_TO_ORG_ID
    ,x_line_rec.INVOICING_RULE_ID
    ,x_line_rec.ORDERED_ITEM_ID
    ,x_line_rec.item_identifier_type
    ,x_line_rec.ORDERED_ITEM
    ,x_line_rec.ITEM_TYPE_CODE
    ,x_line_rec.LAST_UPDATED_BY
    ,x_line_rec.LAST_UPDATE_DATE
    ,x_line_rec.LAST_UPDATE_LOGIN
    ,x_line_rec.line_id
    ,x_line_rec.line_number
    ,x_line_rec.PAYMENT_TERM_ID
    ,x_line_rec.PREFERRED_GRADE
    ,x_line_rec.PRICE_LIST_ID
    ,x_line_rec.PROGRAM_APPLICATION_ID
    ,x_line_rec.PROGRAM_ID
    ,x_line_rec.PROGRAM_UPDATE_DATE
    ,x_line_rec.REQUEST_ID
    ,x_line_rec.SALESREP_ID
    ,x_line_rec.SHIPPING_METHOD_CODE
    ,x_line_rec.ship_from_org_id
    ,x_line_rec.SHIP_TO_ORG_ID
    ,x_line_rec.SHIPPING_INSTRUCTIONS
    ,x_line_rec.PACKING_INSTRUCTIONS
    ,x_line_rec.START_DATE_ACTIVE
    ,x_line_rec.END_DATE_ACTIVE
    ,x_line_rec.MAX_RELEASE_AMOUNT
    ,x_line_rec.MIN_RELEASE_AMOUNT
    ,x_line_rec.BLANKET_MAX_AMOUNT
    ,x_line_rec.BLANKET_MIN_AMOUNT
    ,x_line_rec.BLANKET_MAX_QUANTITY
    ,x_line_rec.BLANKET_MIN_QUANTITY
    ,x_line_rec.OVERRIDE_BLANKET_CONTROLS_FLAG
    ,x_line_rec.OVERRIDE_RELEASE_CONTROLS_FLAG
    ,x_line_rec.ENFORCE_PRICE_LIST_FLAG
    ,x_line_rec.enforce_ship_to_flag
    ,x_line_rec.enforce_invoice_to_flag
    ,x_line_rec.enforce_freight_term_flag
    ,x_line_rec.enforce_shipping_method_flag
    ,x_line_rec.enforce_payment_term_flag
    ,x_line_rec.enforce_accounting_rule_flag
    ,x_line_rec.enforce_invoicing_rule_flag
    ,x_line_rec.ORDER_QUANTITY_UOM
    ,x_line_rec.RELEASED_QUANTITY
    ,x_line_rec.FULFILLED_QUANTITY
    ,x_line_rec.RETURNED_QUANTITY
    ,x_line_rec.ORDER_NUMBER
    ,x_line_rec.RELEASED_AMOUNT
    ,x_line_rec.FULFILLED_AMOUNT
    ,x_line_rec.RETURNED_AMOUNT
    ,x_line_rec.TRANSACTION_PHASE_CODE
    ,x_line_rec.source_document_version_number
    ,x_line_rec.modifier_list_line_id
    FROM    OE_BLANKET_LINES bl , OE_BLANKET_LINES_EXT blx
    WHERE
            bl.line_id = p_line_id
      AND   header_id = p_header_id
      AND   bl.line_id = blx.line_id
      AND   bl.sales_document_type_code = 'B';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
	NULL;
    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
               'Query_Line_TRANS_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END QUERY_LINE_TRANS_ROW;

PROCEDURE COMPARE_ATTRIBUTES
(p_header_id	                  NUMBER,
 p_line_id	                  NUMBER,
 p_prior_version                  NUMBER,
 p_current_version                NUMBER,
 p_next_version                   NUMBER,
 g_max_version                    NUMBER,
 g_trans_version                  NUMBER,
 g_prior_phase_change_flag        VARCHAR2,
 g_curr_phase_change_flag         VARCHAR2,
 g_next_phase_change_flag         VARCHAR2,
 x_line_changed_attr_tbl        IN OUT NOCOPY OE_VERSION_BLANKET_COMP.line_tbl_type,
 p_total_lines                    NUMBER,
 x_line_number                    NUMBER)
IS
p_curr_rec                      OE_Blanket_PUB.line_rec_type;
p_next_rec                      OE_Blanket_PUB.line_rec_type;
p_prior_rec                     OE_Blanket_PUB.line_rec_type;


prior_exists VARCHAR2(1) := 'N';
j NUMBER;
l_line_id NUMBER;
x_deliver_to_address1          VARCHAR2(240);
x_deliver_to_address2          VARCHAR2(240);
x_deliver_to_address3          VARCHAR2(240);
x_deliver_to_address4          VARCHAR2(240);
x_deliver_to_location          VARCHAR2(240);
x_deliver_to_org               VARCHAR2(240);
x_deliver_to_city              VARCHAR2(240);
x_deliver_to_state             VARCHAR2(240);
x_deliver_to_postal_code       VARCHAR2(240);
x_deliver_to_country           VARCHAR2(240);
x_prior_deliver_to_address           VARCHAR2(2000);
x_current_deliver_to_address           VARCHAR2(2000);
x_next_deliver_to_address           VARCHAR2(2000);
x_invoice_to_address1          VARCHAR2(240);
x_invoice_to_address2          VARCHAR2(240);
x_invoice_to_address3          VARCHAR2(240);
x_invoice_to_address4          VARCHAR2(240);
x_invoice_to_location          VARCHAR2(240);
x_invoice_to_org               VARCHAR2(240);
x_invoice_to_city              VARCHAR2(240);
x_invoice_to_state             VARCHAR2(240);
x_invoice_to_postal_code       VARCHAR2(240);
x_invoice_to_country           VARCHAR2(240);
x_prior_invoice_to_address           VARCHAR2(2000);
x_current_invoice_to_address           VARCHAR2(2000);
x_next_invoice_to_address           VARCHAR2(2000);
x_ship_to_address1          VARCHAR2(240);
x_ship_to_address2          VARCHAR2(240);
x_ship_to_address3          VARCHAR2(240);
x_ship_to_address4          VARCHAR2(240);
x_ship_to_location          VARCHAR2(240);
x_ship_to_org               VARCHAR2(240);
x_ship_to_city              VARCHAR2(240);
x_ship_to_state             VARCHAR2(240);
x_ship_to_postal_code       VARCHAR2(240);
x_ship_to_country           VARCHAR2(240);
x_prior_ship_to_address           VARCHAR2(2000);
x_current_ship_to_address           VARCHAR2(2000);
x_next_ship_to_address           VARCHAR2(2000);
x_ship_from_address1          VARCHAR2(240);
x_ship_from_address2          VARCHAR2(240);
x_ship_from_address3          VARCHAR2(240);
x_ship_from_address4          VARCHAR2(240);
x_ship_from_location          VARCHAR2(240);
x_prior_ship_from_org               VARCHAR2(240);
x_current_ship_from_org               VARCHAR2(240);
x_next_ship_from_org               VARCHAR2(240);
x_ship_from_address           VARCHAR2(2000);
x_customer_name               VARCHAR2(360);
x_customer_number             VARCHAR2(100);
x_intermed_ship_to_address1          VARCHAR2(240);
x_intermed_ship_to_address2          VARCHAR2(240);
x_intermed_ship_to_address3          VARCHAR2(240);
x_intermed_ship_to_address4          VARCHAR2(240);
x_intermed_ship_to_location          VARCHAR2(240);
x_intermed_ship_to_org               VARCHAR2(240);
x_intermed_ship_to_city              VARCHAR2(240);
x_intermed_ship_to_state             VARCHAR2(240);
x_intermed_ship_to_postal_code       VARCHAR2(240);
x_intermed_ship_to_country           VARCHAR2(240);
x_item_relationship_type             VARCHAR2(240);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
p_prior_rec_exists VARCHAR2(1) := 'N';
p_curr_rec_exists VARCHAR2(1)  := 'N';
p_next_rec_exists VARCHAR2(1)  := 'N';
p_trans_rec_exists VARCHAR2(1)  := 'N';
ind NUMBER;
BEGIN

IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering  COMPARE_ATTRIBUTES');
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('line' ||p_line_id);
  oe_debug_pub.add('line number' ||x_line_number);
  oe_debug_pub.add('prior version' ||p_prior_version);
  oe_debug_pub.add('current version' ||p_current_version);
  oe_debug_pub.add('next version' ||p_next_version);
  oe_debug_pub.add('max version' ||g_max_version);
  oe_debug_pub.add('trans version' ||g_trans_version);
END IF;

if p_total_lines > 0 THEN
IF l_debug_level > 0 THEN
  oe_debug_pub.add(' p_total_lines '||p_total_lines);
end if;
ind := p_total_lines;
ELSE
ind := 0;
end if;

IF p_line_id IS NOT NULL THEN

p_prior_rec := NULL;
p_curr_rec := NULL;
p_next_rec := NULL;

IF l_debug_level > 0 THEN
  oe_debug_pub.add(' Quering prior line version details');
  oe_debug_pub.add('prior version' ||p_prior_version);
END IF;

IF p_prior_version IS NOT NULL THEN
OE_VERSION_BLANKET_COMP.QUERY_LINE_ROW(p_header_id       => p_header_id,
                          p_line_id         => p_line_id,
			  p_version         => p_prior_version,
                          p_phase_change_flag         => g_prior_phase_change_flag,
			  x_line_rec        => p_prior_rec);
     IF p_prior_rec.line_id is NULL THEN
          p_prior_rec_exists := 'N';
     ELSE
          p_prior_rec_exists := 'Y';
     END IF;
END IF;
IF l_debug_level > 0 THEN
  oe_debug_pub.add(' Quering current line version details');
  oe_debug_pub.add('current version' ||p_current_version);
END IF;

IF p_current_version IS NOT NULL THEN
OE_VERSION_BLANKET_COMP.QUERY_LINE_ROW(p_header_id       => p_header_id,
                          p_line_id         => p_line_id,
                          p_version         => p_current_version,
                          p_phase_change_flag         => g_curr_phase_change_flag,
			  x_line_rec        => p_curr_rec);
     IF p_curr_rec.line_id is NULL THEN
          p_curr_rec_exists := 'N';
     ELSE
          p_curr_rec_exists := 'Y';
     END IF;

END IF;

IF l_debug_level > 0 THEN
  oe_debug_pub.add(' Quering next/trans line version details');
  oe_debug_pub.add('next version' ||p_next_version);
  oe_debug_pub.add('trans version' ||g_trans_version);
END IF;

IF p_next_version = g_trans_version then
       IF g_trans_version is not null then
        --p_next_version := g_trans_version;
       OE_VERSION_BLANKET_COMP.QUERY_LINE_TRANS_ROW(p_header_id       => p_header_id,
                          p_line_id         => p_line_id,
                          p_version                => g_trans_version,
                          x_line_rec               => p_next_rec);
        END IF;
     IF p_next_rec.line_id is NULL THEN
          p_trans_rec_exists := 'N';
     ELSE
          p_trans_rec_exists := 'Y';
          p_next_rec_exists := 'Y';
     END IF;
ELSE
     IF p_next_version IS NOT NULL THEN
       OE_VERSION_BLANKET_COMP.QUERY_LINE_ROW(p_header_id       => p_header_id,
                          p_line_id         => p_line_id,
                          p_version         => p_next_version,
                          p_phase_change_flag         => g_next_phase_change_flag,
			  x_line_rec        => p_next_rec);
     IF p_next_rec.line_id is NULL THEN
          p_next_rec_exists := 'N';
     ELSE
          p_next_rec_exists := 'Y';
     END IF;
    END IF;
END IF;
IF l_debug_level > 0 THEN
    oe_debug_pub.add(' before finding new lines  ');
    oe_debug_pub.add(' p_prior_rec_exists'||p_prior_rec_exists);
    oe_debug_pub.add(' p_curr_rec_exists'||p_curr_rec_exists);
    oe_debug_pub.add(' p_next_rec_exists'||p_next_rec_exists);
    oe_debug_pub.add(' p_trans_rec_exists'||p_trans_rec_exists);
END IF;
IF (p_prior_rec_exists = 'N' and p_curr_rec_exists = 'Y') OR
    (p_curr_rec_exists = 'N' and p_next_rec_exists ='Y') THEN
   IF p_prior_version IS NOT NULL and p_curr_rec_exists = 'Y' THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' Prior is not there - current is there');
         END IF;
       ind := ind+1;
       x_line_changed_attr_tbl(ind).line_number        := x_line_number;
       x_line_changed_attr_tbl(ind).prior_value        :=  null;
       x_line_changed_attr_tbl(ind).current_value      :=  'ADD';
       x_line_changed_attr_tbl(ind).next_value         :=  null;
   ELSIF (p_curr_rec_exists = 'N' and p_next_rec_exists = 'Y') THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' Current is not there - next is there');
         END IF;
       ind := ind+1;
       x_line_changed_attr_tbl(ind).line_number        := x_line_number;
       x_line_changed_attr_tbl(ind).prior_value        :=  null;
       x_line_changed_attr_tbl(ind).current_value      :=  null;
       x_line_changed_attr_tbl(ind).next_value         :=  'ADD';
  end if;
END IF;

IF l_debug_level > 0 THEN
    oe_debug_pub.add(' before finding deleted lines');
    oe_debug_pub.add(' p_prior_rec_exists'||p_prior_rec_exists);
    oe_debug_pub.add(' p_curr_rec_exists'||p_curr_rec_exists);
    oe_debug_pub.add(' p_next_rec_exists'||p_next_rec_exists);
    oe_debug_pub.add(' p_trans_rec_exists'||p_trans_rec_exists);
    oe_debug_pub.add(' x_line_numer '||x_line_number);
END IF;
IF (p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'N') OR
    (p_curr_rec_exists = 'Y' and p_next_rec_exists ='N') THEN
   IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'N' THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' Prior is there - current is not there');
         END IF;
       ind := ind+1;
       x_line_changed_attr_tbl(ind).line_number        := x_line_number;
       x_line_changed_attr_tbl(ind).prior_value        :=  null;
       x_line_changed_attr_tbl(ind).current_value      :=  'DELETE';
       x_line_changed_attr_tbl(ind).next_value         :=  null;
   ELSIF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'N' THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' p_next_version'||p_next_version);
               oe_debug_pub.add(' g_trans_version'||g_trans_version);
         END IF;
      --if p_next_version != g_trans_version THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' Current is there - next is not there');
         END IF;
       ind := ind+1;
       x_line_changed_attr_tbl(ind).line_number        := x_line_number;
       x_line_changed_attr_tbl(ind).prior_value        :=  null;
       x_line_changed_attr_tbl(ind).current_value      :=  null;
       x_line_changed_attr_tbl(ind).next_value         :=  'DELETE';
     --end if;
  end if;
END IF;
--dbms_output.put_line(' No line number'||x_line_number);
IF l_debug_level > 0 THEN
  oe_debug_pub.add('******BEFORE COMPARING ATTRIBUTES*************');
  oe_debug_pub.add('current ind '|| ind);
END IF;

IF (p_prior_version IS NOT NULL and p_prior_rec_exists ='Y') OR
   (p_current_version IS NOT NULL and p_curr_rec_exists ='Y') OR
   (p_next_version IS NOT NULL and p_next_rec_exists ='Y') OR
   (g_trans_version IS NOT NULL and p_trans_rec_exists ='Y') THEN
/****************************/

/****************************/
/* START ACCOUNTING_RULE_ID*/
prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.accounting_rule_id,
       p_prior_rec.accounting_rule_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'accounting_rule';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.accounting_rule_id;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Accounting_Rule(p_curr_rec.accounting_rule_id);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.accounting_rule_id;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Accounting_rule(p_prior_rec.accounting_rule_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.accounting_rule_id,
       p_next_rec.accounting_rule_id) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Accounting_Rule(p_curr_rec.accounting_rule_id);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'accounting_rule';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.accounting_rule_id;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Accounting_rule(p_prior_rec.accounting_rule_id);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.accounting_rule_id;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Accounting_Rule(p_curr_rec.accounting_rule_id);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.accounting_rule_id;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Accounting_Rule(p_next_rec.accounting_rule_id);
END IF;
END IF; /*  NEXT */

/* END ACCOUNTING_RULE_ID*/
/****************************/

/****************************/
/* START agreement_id*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.agreement_id,
       p_prior_rec.agreement_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'agreement';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.agreement_id;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Agreement(p_curr_rec.agreement_id);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.agreement_id;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Agreement(p_prior_rec.agreement_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.agreement_id,
       p_next_rec.agreement_id) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Agreement(p_curr_rec.agreement_id);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'agreement';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.agreement_id;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Agreement(p_prior_rec.agreement_id);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.agreement_id;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Agreement(p_curr_rec.agreement_id);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.agreement_id;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Agreement(p_next_rec.agreement_id);
END IF;
END IF; /*  NEXT */

/* END agreement_id*/
/****************************/

/****************************/
/* START attribute1*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute1,
       p_prior_rec.attribute1) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute1';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute1;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute1;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute1,
       p_next_rec.attribute1) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute1;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute1';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute1;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute1;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.attribute1;
END IF;
END IF; /*  NEXT */

/* END attribute1*/
/****************************/

/****************************/
/* START attribute2*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute2,
       p_prior_rec.attribute2) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute2';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute2;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute2;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute2,
       p_next_rec.attribute2) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute2;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute2';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute2;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute2;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.attribute2;
END IF;
END IF; /*  NEXT */

/* END attribute2*/
/****************************/
/****************************/
/* START attribute3*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute3,
       p_prior_rec.attribute3) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute3';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute3;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute3;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute3,
       p_next_rec.attribute3) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute3;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute3';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute3;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute3;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.attribute3;
END IF;
END IF; /*  NEXT */

/* END attribute3*/
/****************************/

/****************************/
/* START attribute4*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute4,
       p_prior_rec.attribute4) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute4';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute4;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute4;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute4,
       p_next_rec.attribute4) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute4;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute4';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute4;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute4;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.attribute4;
END IF;
END IF; /*  NEXT */

/* END attribute4*/
/****************************/
/****************************/
/* START attribute5*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute5,
       p_prior_rec.attribute5) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute5';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute5;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute5;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute5,
       p_next_rec.attribute5) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute5;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute5';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute5;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute5;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.attribute5;
END IF;
END IF; /*  NEXT */

/* END attribute5*/
/****************************/

/****************************/
/* START attribute6*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute6,
       p_prior_rec.attribute6) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute6';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute6;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute6;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute6,
       p_next_rec.attribute6) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute6;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute6';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute6;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute6;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.attribute6;
END IF;
END IF; /*  NEXT */

/* END attribute6*/
/****************************/
/****************************/
/* START attribute7*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute7,
       p_prior_rec.attribute7) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute7';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute7;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute7;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute7,
       p_next_rec.attribute7) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute7;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute7;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute7';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute7;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.attribute7;
END IF;
END IF; /*  NEXT */

/* END attribute7*/
/****************************/

/****************************/
/* START attribute8*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute8,
       p_prior_rec.attribute8) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute8';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute8;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute8;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute8,
       p_next_rec.attribute8) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute8;
    END IF;
 null;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute8';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute8;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute8;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.attribute8;
END IF;
END IF; /*  NEXT */

/* END attribute8*/
/****************************/
/****************************/
/* START attribute9*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute9,
       p_prior_rec.attribute9) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute9';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute9;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute9;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute9,
       p_next_rec.attribute9) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute9;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute9';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute9;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute9;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.attribute9;
END IF;
END IF; /*  NEXT */

/* END attribute9*/
/****************************/

/****************************/
/* START attribute10*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute10,
       p_prior_rec.attribute10) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute10';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute10;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute10;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute10,
       p_next_rec.attribute10) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute10;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute10';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute10;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.attribute10;
END IF;
END IF; /*  NEXT */

/* END attribute10*/
/****************************/

/****************************/
/* START attribute11*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute11,
       p_prior_rec.attribute11) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute11';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute11;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute11;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute11,
       p_next_rec.attribute11) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute11;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute11';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute10;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute11;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.attribute11;
END IF;
END IF; /*  NEXT */

/* END attribute11*/
/****************************/

/****************************/
/* START attribute12*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute12,
       p_prior_rec.attribute12) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute12';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute12;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute12;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute12,
       p_next_rec.attribute12) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute12;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute12';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute12;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute12;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.attribute12;
END IF;
END IF; /*  NEXT */

/* END attribute12*/
/****************************/

/****************************/
/* START attribute13*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute13,
       p_prior_rec.attribute13) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute13';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute13;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute13;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute13,
       p_next_rec.attribute13) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute13;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute13';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute13;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute13;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.attribute13;
END IF;
END IF; /*  NEXT */

/* END attribute13*/
/****************************/

/****************************/
/* START attribute14*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute14,
       p_prior_rec.attribute14) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute14';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute14;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute14;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute14,
       p_next_rec.attribute14) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute14;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute14';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute14;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute14;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.attribute14;
END IF;
END IF; /*  NEXT */

/* END attribute14*/
/****************************/

/****************************/
/* START attribute15*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute15,
       p_prior_rec.attribute15) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute15';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute15;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute15;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute15,
       p_next_rec.attribute15) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute15;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute15';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute15;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute15;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.attribute15;
END IF;
END IF; /*  NEXT */

/* END attribute15*/
/****************************/
/****************************/
/* START context*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.context,
       p_prior_rec.context) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'context';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.context;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.context;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.context,
       p_next_rec.context) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.context;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'context';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.context;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.context;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.context;
END IF;
END IF; /*  NEXT */

/* END context*/
/****************************/
/****************************/
/* START cust_po_number*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.cust_po_number,
       p_prior_rec.cust_po_number) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'cust_po_number';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.cust_po_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.cust_po_number;
END IF;
END IF; /*  PRIOR */
/****************************/

IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.cust_po_number,
       p_next_rec.cust_po_number) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.cust_po_number;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name  := 'cust_po_number';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.cust_po_number;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.cust_po_number;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.cust_po_number;
END IF;
END IF; /*  NEXT */

/* END cust_po_number*/
/****************************/

/****************************/
/* START deliver_to_org_id*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.deliver_to_org_id,
       p_prior_rec.deliver_to_org_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'deliver_to';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   if p_curr_rec.deliver_to_org_id is not null then
     OE_ID_TO_VALUE.deliver_To_Org
         (   p_deliver_to_org_id        => p_curr_rec.deliver_To_org_id
        , x_deliver_to_address1    => x_deliver_to_address1
        , x_deliver_to_address2    => x_deliver_to_address2
	, x_deliver_to_address3    => x_deliver_to_address3
	, x_deliver_to_address4    => x_deliver_to_address4
	, x_deliver_to_location    => x_deliver_to_location
	, x_deliver_to_org         => x_deliver_to_org
	, x_deliver_to_city        => x_deliver_to_city
	, x_deliver_to_state       => x_deliver_to_state
	, x_deliver_to_postal_code => x_deliver_to_postal_code
	, x_deliver_to_country     => x_deliver_to_country
          );

  select
    DECODE(x_deliver_to_location, NULL, NULL,x_deliver_to_location|| ', ') ||
    DECODE(x_deliver_to_address1, NULL, NULL,x_deliver_to_address1 || ', ') ||
    DECODE(x_deliver_to_address2, NULL, NULL,x_deliver_to_address3 || ', ') ||
    DECODE(x_deliver_to_address3, NULL, NULL,x_deliver_to_address3 || ', ') ||
    DECODE(x_deliver_to_address4, NULL, NULL,x_deliver_to_address4 || ', ') ||
    DECODE(x_deliver_to_city, NULL, NULL,x_deliver_to_city || ', ') ||
    DECODE(x_deliver_to_state, NULL, NULL,x_deliver_to_state || ', ') ||
    DECODE(x_deliver_to_postal_code, NULL, NULL,x_deliver_to_postal_code || ', ') ||
    DECODE(x_deliver_to_country, NULL,NULL,x_deliver_to_country)
        into x_current_deliver_to_address from dual;

   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.deliver_to_org_id;
   x_line_changed_attr_tbl(ind).current_value     := x_current_deliver_to_address;

       end if;
   if p_prior_rec.deliver_to_org_id is not null then
     OE_ID_TO_VALUE.deliver_To_Org
         (   p_deliver_to_org_id        => p_prior_rec.deliver_To_org_id
        , x_deliver_to_address1    => x_deliver_to_address1
        , x_deliver_to_address2    => x_deliver_to_address2
	, x_deliver_to_address3    => x_deliver_to_address3
	, x_deliver_to_address4    => x_deliver_to_address4
	, x_deliver_to_location    => x_deliver_to_location
	, x_deliver_to_org         => x_deliver_to_org
	, x_deliver_to_city        => x_deliver_to_city
	, x_deliver_to_state       => x_deliver_to_state
	, x_deliver_to_postal_code => x_deliver_to_postal_code
	, x_deliver_to_country     => x_deliver_to_country
          );

  select
    DECODE(x_deliver_to_location, NULL, NULL,x_deliver_to_location|| ', ') ||
    DECODE(x_deliver_to_address1, NULL, NULL,x_deliver_to_address1 || ', ') ||
    DECODE(x_deliver_to_address2, NULL, NULL,x_deliver_to_address3 || ', ') ||
    DECODE(x_deliver_to_address3, NULL, NULL,x_deliver_to_address3 || ', ') ||
    DECODE(x_deliver_to_address4, NULL, NULL,x_deliver_to_address4 || ', ') ||
    DECODE(x_deliver_to_city, NULL, NULL,x_deliver_to_city || ', ') ||
    DECODE(x_deliver_to_state, NULL, NULL,x_deliver_to_state || ', ') ||
    DECODE(x_deliver_to_postal_code, NULL, NULL,x_deliver_to_postal_code || ', ') ||
    DECODE(x_deliver_to_country, NULL,NULL,x_deliver_to_country)
        into x_prior_deliver_to_address from dual;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.deliver_to_org_id;
   x_line_changed_attr_tbl(ind).prior_value     := x_prior_deliver_to_address;
       end if;
END IF;
END IF; /*  PRIOR */
/****************************/

IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.deliver_to_org_id,
       p_next_rec.deliver_to_org_id) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value     := x_current_deliver_to_address;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'deliver_to';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;

   if p_prior_rec.deliver_to_org_id is not null then
     OE_ID_TO_VALUE.deliver_To_Org
         (   p_deliver_to_org_id        => p_prior_rec.deliver_To_org_id
        , x_deliver_to_address1    => x_deliver_to_address1
        , x_deliver_to_address2    => x_deliver_to_address2
	, x_deliver_to_address3    => x_deliver_to_address3
	, x_deliver_to_address4    => x_deliver_to_address4
	, x_deliver_to_location    => x_deliver_to_location
	, x_deliver_to_org         => x_deliver_to_org
	, x_deliver_to_city        => x_deliver_to_city
	, x_deliver_to_state       => x_deliver_to_state
	, x_deliver_to_postal_code => x_deliver_to_postal_code
	, x_deliver_to_country     => x_deliver_to_country
          );

  select
    DECODE(x_deliver_to_location, NULL, NULL,x_deliver_to_location|| ', ') ||
    DECODE(x_deliver_to_address1, NULL, NULL,x_deliver_to_address1 || ', ') ||
    DECODE(x_deliver_to_address2, NULL, NULL,x_deliver_to_address3 || ', ') ||
    DECODE(x_deliver_to_address3, NULL, NULL,x_deliver_to_address3 || ', ') ||
    DECODE(x_deliver_to_address4, NULL, NULL,x_deliver_to_address4 || ', ') ||
    DECODE(x_deliver_to_city, NULL, NULL,x_deliver_to_city || ', ') ||
    DECODE(x_deliver_to_state, NULL, NULL,x_deliver_to_state || ', ') ||
    DECODE(x_deliver_to_postal_code, NULL, NULL,x_deliver_to_postal_code || ', ') ||
    DECODE(x_deliver_to_country, NULL,NULL,x_deliver_to_country)
        into x_prior_deliver_to_address from dual;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.deliver_to_org_id;
   x_line_changed_attr_tbl(ind).prior_value     := x_prior_deliver_to_address;

       end if;
   if p_curr_rec.deliver_to_org_id is not null then
     OE_ID_TO_VALUE.deliver_To_Org
         (   p_deliver_to_org_id        => p_curr_rec.deliver_To_org_id
        , x_deliver_to_address1    => x_deliver_to_address1
        , x_deliver_to_address2    => x_deliver_to_address2
	, x_deliver_to_address3    => x_deliver_to_address3
	, x_deliver_to_address4    => x_deliver_to_address4
	, x_deliver_to_location    => x_deliver_to_location
	, x_deliver_to_org         => x_deliver_to_org
	, x_deliver_to_city        => x_deliver_to_city
	, x_deliver_to_state       => x_deliver_to_state
	, x_deliver_to_postal_code => x_deliver_to_postal_code
	, x_deliver_to_country     => x_deliver_to_country
          );

  select
    DECODE(x_deliver_to_location, NULL, NULL,x_deliver_to_location|| ', ') ||
    DECODE(x_deliver_to_address1, NULL, NULL,x_deliver_to_address1 || ', ') ||
    DECODE(x_deliver_to_address2, NULL, NULL,x_deliver_to_address3 || ', ') ||
    DECODE(x_deliver_to_address3, NULL, NULL,x_deliver_to_address3 || ', ') ||
    DECODE(x_deliver_to_address4, NULL, NULL,x_deliver_to_address4 || ', ') ||
    DECODE(x_deliver_to_city, NULL, NULL,x_deliver_to_city || ', ') ||
    DECODE(x_deliver_to_state, NULL, NULL,x_deliver_to_state || ', ') ||
    DECODE(x_deliver_to_postal_code, NULL, NULL,x_deliver_to_postal_code || ', ') ||
    DECODE(x_deliver_to_country, NULL,NULL,x_deliver_to_country)
        into x_current_deliver_to_address from dual;
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.deliver_to_org_id;
   x_line_changed_attr_tbl(ind).current_value     := x_current_deliver_to_address;
       end if;

   if p_next_rec.deliver_to_org_id is not null then
     OE_ID_TO_VALUE.deliver_To_Org
         (   p_deliver_to_org_id        => p_next_rec.deliver_To_org_id
        , x_deliver_to_address1    => x_deliver_to_address1
        , x_deliver_to_address2    => x_deliver_to_address2
	, x_deliver_to_address3    => x_deliver_to_address3
	, x_deliver_to_address4    => x_deliver_to_address4
	, x_deliver_to_location    => x_deliver_to_location
	, x_deliver_to_org         => x_deliver_to_org
	, x_deliver_to_city        => x_deliver_to_city
	, x_deliver_to_state       => x_deliver_to_state
	, x_deliver_to_postal_code => x_deliver_to_postal_code
	, x_deliver_to_country     => x_deliver_to_country
          );

  select
    DECODE(x_deliver_to_location, NULL, NULL,x_deliver_to_location|| ', ') ||
    DECODE(x_deliver_to_address1, NULL, NULL,x_deliver_to_address1 || ', ') ||
    DECODE(x_deliver_to_address2, NULL, NULL,x_deliver_to_address3 || ', ') ||
    DECODE(x_deliver_to_address3, NULL, NULL,x_deliver_to_address3 || ', ') ||
    DECODE(x_deliver_to_address4, NULL, NULL,x_deliver_to_address4 || ', ') ||
    DECODE(x_deliver_to_city, NULL, NULL,x_deliver_to_city || ', ') ||
    DECODE(x_deliver_to_state, NULL, NULL,x_deliver_to_state || ', ') ||
    DECODE(x_deliver_to_postal_code, NULL, NULL,x_deliver_to_postal_code || ', ') ||
    DECODE(x_deliver_to_country, NULL,NULL,x_deliver_to_country)
        into x_next_deliver_to_address from dual;
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.deliver_to_org_id;
   x_line_changed_attr_tbl(ind).next_value     := x_next_deliver_to_address;
       end if;
END IF;
END IF; /*  NEXT */

/* END deliver_to_org_id*/
/****************************/


/****************************/
/* START freight_terms_code*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.freight_terms_code,
       p_prior_rec.freight_terms_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'freight_terms';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.freight_terms_code;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Freight_terms(p_curr_rec.freight_terms_code);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.freight_terms_code;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Freight_terms(p_prior_rec.freight_terms_code);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.freight_terms_code,
       p_next_rec.freight_terms_code) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Freight_terms(p_curr_rec.freight_terms_code);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'freight_terms';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.freight_terms_code;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Freight_terms(p_prior_rec.freight_terms_code);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.freight_terms_code;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Freight_terms(p_curr_rec.freight_terms_code);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.freight_terms_code;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Freight_terms(p_next_rec.freight_terms_code);
END IF;
END IF; /*  NEXT */

/* END freight_terms_code*/
/****************************/

/****************************/
/* START min_release_quantity*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.min_release_quantity,
       p_prior_rec.min_release_quantity) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'min_release_quantity';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.min_release_quantity;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.min_release_quantity;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.min_release_quantity,
       p_next_rec.min_release_quantity) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.min_release_quantity;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'min_release_quantity';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.min_release_quantity;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.min_release_quantity;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.min_release_quantity;
END IF;
END IF; /*  NEXT */

/* END min_release_quantity*/
/****************************/

/****************************/
/* START max_release_quantity*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.max_release_quantity,
       p_prior_rec.max_release_quantity) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'max_release_quantity';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.max_release_quantity;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.max_release_quantity;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.max_release_quantity,
       p_next_rec.max_release_quantity) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.max_release_quantity;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'max_release_quantity';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.max_release_quantity;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.max_release_quantity;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.max_release_quantity;
END IF;
END IF; /*  NEXT */

/* END max_release_quantity*/
/****************************/

/****************************/
/* START invoice_to_org_id*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.invoice_to_org_id,
       p_prior_rec.invoice_to_org_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'invoice_to';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   if p_curr_rec.invoice_to_org_id is not null then

     OE_ID_TO_VALUE.invoice_to_Org
         (   p_invoice_to_org_id        => p_curr_rec.invoice_to_org_id
        , x_invoice_to_address1    => x_invoice_to_address1
        , x_invoice_to_address2    => x_invoice_to_address2
	, x_invoice_to_address3    => x_invoice_to_address3
	, x_invoice_to_address4    => x_invoice_to_address4
	, x_invoice_to_location    => x_invoice_to_location
	, x_invoice_to_org         => x_invoice_to_org
	, x_invoice_to_city        => x_invoice_to_city
	, x_invoice_to_state       => x_invoice_to_state
	, x_invoice_to_postal_code => x_invoice_to_postal_code
	, x_invoice_to_country     => x_invoice_to_country
          );

  select
    DECODE(x_invoice_to_location, NULL, NULL,x_invoice_to_location|| ', ') ||
    DECODE(x_invoice_to_address1, NULL, NULL,x_invoice_to_address1 || ', ') ||
    DECODE(x_invoice_to_address2, NULL, NULL,x_invoice_to_address3 || ', ') ||
    DECODE(x_invoice_to_address3, NULL, NULL,x_invoice_to_address3 || ', ') ||
    DECODE(x_invoice_to_address4, NULL, NULL,x_invoice_to_address4 || ', ') ||
    DECODE(x_invoice_to_city, NULL, NULL,x_invoice_to_city || ', ') ||
    DECODE(x_invoice_to_state, NULL, NULL,x_invoice_to_state || ', ') ||
    DECODE(x_invoice_to_postal_code, NULL, NULL,x_invoice_to_postal_code || ', ') ||
    DECODE(x_invoice_to_country, NULL,NULL,x_invoice_to_country)
        into x_current_invoice_to_address from dual;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.invoice_to_org_id;

   x_line_changed_attr_tbl(ind).current_value     := x_current_invoice_to_address;
       end if;

   if p_prior_rec.invoice_to_org_id is not null then
     OE_ID_TO_VALUE.invoice_to_Org
         (   p_invoice_to_org_id        => p_prior_rec.invoice_to_org_id
        , x_invoice_to_address1    => x_invoice_to_address1
        , x_invoice_to_address2    => x_invoice_to_address2
	, x_invoice_to_address3    => x_invoice_to_address3
	, x_invoice_to_address4    => x_invoice_to_address4
	, x_invoice_to_location    => x_invoice_to_location
	, x_invoice_to_org         => x_invoice_to_org
	, x_invoice_to_city        => x_invoice_to_city
	, x_invoice_to_state       => x_invoice_to_state
	, x_invoice_to_postal_code => x_invoice_to_postal_code
	, x_invoice_to_country     => x_invoice_to_country
          );

  select
    DECODE(x_invoice_to_location, NULL, NULL,x_invoice_to_location|| ', ') ||
    DECODE(x_invoice_to_address1, NULL, NULL,x_invoice_to_address1 || ', ') ||
    DECODE(x_invoice_to_address2, NULL, NULL,x_invoice_to_address3 || ', ') ||
    DECODE(x_invoice_to_address3, NULL, NULL,x_invoice_to_address3 || ', ') ||
    DECODE(x_invoice_to_address4, NULL, NULL,x_invoice_to_address4 || ', ') ||
    DECODE(x_invoice_to_city, NULL, NULL,x_invoice_to_city || ', ') ||
    DECODE(x_invoice_to_state, NULL, NULL,x_invoice_to_state || ', ') ||
    DECODE(x_invoice_to_postal_code, NULL, NULL,x_invoice_to_postal_code || ', ') ||
    DECODE(x_invoice_to_country, NULL,NULL,x_invoice_to_country)
        into x_prior_invoice_to_address from dual;
   x_line_changed_attr_tbl(ind).prior_value     := x_prior_invoice_to_address;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.invoice_to_org_id;
       end if;
END IF;
END IF; /*  PRIOR */
/****************************/

IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.invoice_to_org_id,
       p_next_rec.invoice_to_org_id) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value     := x_current_invoice_to_address;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'invoice_to';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;

   if p_prior_rec.invoice_to_org_id is not null then
     OE_ID_TO_VALUE.invoice_to_Org
         (   p_invoice_to_org_id        => p_prior_rec.invoice_to_org_id
        , x_invoice_to_address1    => x_invoice_to_address1
        , x_invoice_to_address2    => x_invoice_to_address2
	, x_invoice_to_address3    => x_invoice_to_address3
	, x_invoice_to_address4    => x_invoice_to_address4
	, x_invoice_to_location    => x_invoice_to_location
	, x_invoice_to_org         => x_invoice_to_org
	, x_invoice_to_city        => x_invoice_to_city
	, x_invoice_to_state       => x_invoice_to_state
	, x_invoice_to_postal_code => x_invoice_to_postal_code
	, x_invoice_to_country     => x_invoice_to_country
          );

  select
    DECODE(x_invoice_to_location, NULL, NULL,x_invoice_to_location|| ', ') ||
    DECODE(x_invoice_to_address1, NULL, NULL,x_invoice_to_address1 || ', ') ||
    DECODE(x_invoice_to_address2, NULL, NULL,x_invoice_to_address3 || ', ') ||
    DECODE(x_invoice_to_address3, NULL, NULL,x_invoice_to_address3 || ', ') ||
    DECODE(x_invoice_to_address4, NULL, NULL,x_invoice_to_address4 || ', ') ||
    DECODE(x_invoice_to_city, NULL, NULL,x_invoice_to_city || ', ') ||
    DECODE(x_invoice_to_state, NULL, NULL,x_invoice_to_state || ', ') ||
    DECODE(x_invoice_to_postal_code, NULL, NULL,x_invoice_to_postal_code || ', ') ||
    DECODE(x_invoice_to_country, NULL,NULL,x_invoice_to_country)
        into x_prior_invoice_to_address from dual;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.invoice_to_org_id;
   x_line_changed_attr_tbl(ind).prior_value     := x_prior_invoice_to_address;
       end if;

   if p_curr_rec.invoice_to_org_id is not null then
     OE_ID_TO_VALUE.invoice_to_Org
         (   p_invoice_to_org_id        => p_curr_rec.invoice_to_org_id
        , x_invoice_to_address1    => x_invoice_to_address1
        , x_invoice_to_address2    => x_invoice_to_address2
	, x_invoice_to_address3    => x_invoice_to_address3
	, x_invoice_to_address4    => x_invoice_to_address4
	, x_invoice_to_location    => x_invoice_to_location
	, x_invoice_to_org         => x_invoice_to_org
	, x_invoice_to_city        => x_invoice_to_city
	, x_invoice_to_state       => x_invoice_to_state
	, x_invoice_to_postal_code => x_invoice_to_postal_code
	, x_invoice_to_country     => x_invoice_to_country
          );

  select
    DECODE(x_invoice_to_location, NULL, NULL,x_invoice_to_location|| ', ') ||
    DECODE(x_invoice_to_address1, NULL, NULL,x_invoice_to_address1 || ', ') ||
    DECODE(x_invoice_to_address2, NULL, NULL,x_invoice_to_address3 || ', ') ||
    DECODE(x_invoice_to_address3, NULL, NULL,x_invoice_to_address3 || ', ') ||
    DECODE(x_invoice_to_address4, NULL, NULL,x_invoice_to_address4 || ', ') ||
    DECODE(x_invoice_to_city, NULL, NULL,x_invoice_to_city || ', ') ||
    DECODE(x_invoice_to_state, NULL, NULL,x_invoice_to_state || ', ') ||
    DECODE(x_invoice_to_postal_code, NULL, NULL,x_invoice_to_postal_code || ', ') ||
    DECODE(x_invoice_to_country, NULL,NULL,x_invoice_to_country)
        into x_current_invoice_to_address from dual;
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.invoice_to_org_id;
   x_line_changed_attr_tbl(ind).current_value     := x_current_invoice_to_address;
       end if;

   if p_next_rec.invoice_to_org_id is not null then
     OE_ID_TO_VALUE.invoice_to_Org
         (   p_invoice_to_org_id        => p_next_rec.invoice_to_org_id
        , x_invoice_to_address1    => x_invoice_to_address1
        , x_invoice_to_address2    => x_invoice_to_address2
	, x_invoice_to_address3    => x_invoice_to_address3
	, x_invoice_to_address4    => x_invoice_to_address4
	, x_invoice_to_location    => x_invoice_to_location
	, x_invoice_to_org         => x_invoice_to_org
	, x_invoice_to_city        => x_invoice_to_city
	, x_invoice_to_state       => x_invoice_to_state
	, x_invoice_to_postal_code => x_invoice_to_postal_code
	, x_invoice_to_country     => x_invoice_to_country
          );

  select
    DECODE(x_invoice_to_location, NULL, NULL,x_invoice_to_location|| ', ') ||
    DECODE(x_invoice_to_address1, NULL, NULL,x_invoice_to_address1 || ', ') ||
    DECODE(x_invoice_to_address2, NULL, NULL,x_invoice_to_address3 || ', ') ||
    DECODE(x_invoice_to_address3, NULL, NULL,x_invoice_to_address3 || ', ') ||
    DECODE(x_invoice_to_address4, NULL, NULL,x_invoice_to_address4 || ', ') ||
    DECODE(x_invoice_to_city, NULL, NULL,x_invoice_to_city || ', ') ||
    DECODE(x_invoice_to_state, NULL, NULL,x_invoice_to_state || ', ') ||
    DECODE(x_invoice_to_postal_code, NULL, NULL,x_invoice_to_postal_code || ', ') ||
    DECODE(x_invoice_to_country, NULL,NULL,x_invoice_to_country)
        into x_next_invoice_to_address from dual;
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.invoice_to_org_id;
   x_line_changed_attr_tbl(ind).next_value     := x_next_invoice_to_address;
       end if;
END IF;
END IF; /*  NEXT */

/* END invoice_to_org_id*/
/****************************/

/****************************/
/* START invoicing_rule_id*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.invoicing_rule_id,
       p_prior_rec.invoicing_rule_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'invoicing_rule';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.invoicing_rule_id;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Invoicing_Rule(p_curr_rec.invoicing_rule_id);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.invoicing_rule_id;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Invoicing_Rule(p_prior_rec.invoicing_rule_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.invoicing_rule_id,
       p_next_rec.invoicing_rule_id) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Invoicing_Rule(p_curr_rec.invoicing_rule_id);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'invoicing_rule';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.invoicing_rule_id;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Invoicing_Rule(p_prior_rec.invoicing_rule_id);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.invoicing_rule_id;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Invoicing_Rule(p_curr_rec.invoicing_rule_id);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.invoicing_rule_id;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Invoicing_Rule(p_next_rec.invoicing_rule_id);
END IF;
END IF; /*  NEXT */

/* END invoicing_rule_id*/
/****************************/


/****************************/
/* START ORDERED_ITEM*/
prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ORDERED_ITEM,
       p_prior_rec.ORDERED_ITEM) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'ORDERED_ITEM';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.ORDERED_ITEM;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.ORDERED_ITEM;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ORDERED_ITEM,
       p_next_rec.ORDERED_ITEM) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.ORDERED_ITEM;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'ORDERED_ITEM';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.ORDERED_ITEM;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.ORDERED_ITEM;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.ORDERED_ITEM;
END IF;
END IF; /*  NEXT */

/* END ORDERED_ITEM*/
/****************************/

/****************************/
/* START ORDER_QUANTITY_UOM*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ORDER_QUANTITY_UOM,
       p_prior_rec.ORDER_QUANTITY_UOM) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'ORDER_QUANTITY_UOM';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.ORDER_QUANTITY_UOM;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.ORDER_QUANTITY_UOM;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ORDER_QUANTITY_UOM,
       p_next_rec.ORDER_QUANTITY_UOM) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.ORDER_QUANTITY_UOM;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'ORDER_QUANTITY_UOM';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.ORDER_QUANTITY_UOM;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.ORDER_QUANTITY_UOM;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.ORDER_QUANTITY_UOM;
END IF;
END IF; /*  NEXT */

/* END ORDER_QUANTITY_UOM*/
/****************************/
/****************************/
/* START PRICE_LIST_ID*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.PRICE_LIST_ID,
       p_prior_rec.PRICE_LIST_ID) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'PRICE_LIST_NAME_DUP';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.PRICE_LIST_ID;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.PRICE_LIST(p_curr_rec.PRICE_LIST_ID);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.PRICE_LIST_ID;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.PRICE_LIST(p_prior_rec.PRICE_LIST_ID);
END IF;
END IF; /*  PRIOR */
/****************************/

IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.PRICE_LIST_ID,
       p_next_rec.PRICE_LIST_ID) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.PRICE_LIST(p_curr_rec.PRICE_LIST_ID);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'PRICE_LIST_NAME_DUP';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.PRICE_LIST_ID;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.PRICE_LIST(p_prior_rec.PRICE_LIST_ID);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.PRICE_LIST_ID;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.PRICE_LIST(p_curr_rec.PRICE_LIST_ID);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.PRICE_LIST_ID;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.PRICE_LIST(p_next_rec.PRICE_LIST_ID);
END IF;
END IF; /*  NEXT */

/* END PRICE_LIST_ID*/
/****************************/

/****************************/
/* START SALESREP_ID*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SALESREP_ID,
       p_prior_rec.SALESREP_ID) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'SALESREP';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.SALESREP_ID;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.SALESREP(p_curr_rec.SALESREP_ID);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.SALESREP_ID;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.SALESREP(p_prior_rec.SALESREP_ID);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SALESREP_ID,
       p_next_rec.SALESREP_ID) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.SALESREP(p_curr_rec.SALESREP_ID);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'SALESREP';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.SALESREP_ID;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.SALESREP(p_prior_rec.SALESREP_ID);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.SALESREP_ID;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.SALESREP(p_curr_rec.SALESREP_ID);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.SALESREP_ID;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.SALESREP(p_next_rec.SALESREP_ID);
END IF; /*  NEXT */
END IF;

/* END SALESREP_ID*/
/****************************/
/****************************/
/* START SHIPPING_METHOD_CODE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SHIPPING_METHOD_CODE,
       p_prior_rec.SHIPPING_METHOD_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'SHIPPING_METHOD';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.SHIPPING_METHOD_CODE;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.ship_method(p_curr_rec.SHIPPING_METHOD_CODE);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.SHIPPING_METHOD_CODE;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.ship_method(p_prior_rec.SHIPPING_METHOD_CODE);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SHIPPING_METHOD_CODE,
       p_next_rec.SHIPPING_METHOD_CODE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.ship_method(p_curr_rec.SHIPPING_METHOD_CODE);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'SHIPPING_METHOD';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.SHIPPING_METHOD_CODE;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.ship_method(p_prior_rec.SHIPPING_METHOD_CODE);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.SHIPPING_METHOD_CODE;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.ship_method(p_curr_rec.SHIPPING_METHOD_CODE);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.SHIPPING_METHOD_CODE;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.ship_method(p_next_rec.SHIPPING_METHOD_CODE);
END IF;
END IF; /*  NEXT */

/* END SHIPPING_METHOD_CODE*/
/****************************/

/****************************/
/* START ship_from_org_id*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ship_from_org_id,
       p_prior_rec.ship_from_org_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'Warehouse';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   if p_curr_rec.ship_from_org_id is not null then
     OE_ID_TO_VALUE.ship_from_Org
         (   p_ship_from_org_id        => p_curr_rec.ship_from_org_id
        , x_ship_from_address1    => x_ship_from_address1
        , x_ship_from_address2    => x_ship_from_address2
	, x_ship_from_address3    => x_ship_from_address3
	, x_ship_from_address4    => x_ship_from_address4
	, x_ship_from_location    => x_ship_from_location
	, x_ship_from_org         => x_current_ship_from_org
          );
/*
  select
    DECODE(x_ship_from_location, NULL, NULL,x_ship_from_location|| ', ') ||
    DECODE(x_ship_from_address1, NULL, NULL,x_ship_from_address1 || ', ') ||
    DECODE(x_ship_from_address2, NULL, NULL,x_ship_from_address3 || ', ') ||
    DECODE(x_ship_from_address3, NULL, NULL,x_ship_from_address3 || ', ') ||
    DECODE(x_ship_from_address4, NULL, NULL,x_ship_from_address4 || ', ')
        into x_ship_from_address from dual;
*/
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.ship_from_org_id;
   x_line_changed_attr_tbl(ind).current_value     := x_current_ship_from_org;

       end if;
   if p_prior_rec.ship_from_org_id is not null then
     OE_ID_TO_VALUE.ship_from_Org
         (   p_ship_from_org_id        => p_prior_rec.ship_from_org_id
        , x_ship_from_address1    => x_ship_from_address1
        , x_ship_from_address2    => x_ship_from_address2
	, x_ship_from_address3    => x_ship_from_address3
	, x_ship_from_address4    => x_ship_from_address4
	, x_ship_from_location    => x_ship_from_location
	, x_ship_from_org         => x_prior_ship_from_org
          );
/*
  select
    DECODE(x_ship_from_location, NULL, NULL,x_ship_from_location|| ', ') ||
    DECODE(x_ship_from_address1, NULL, NULL,x_ship_from_address1 || ', ') ||
    DECODE(x_ship_from_address2, NULL, NULL,x_ship_from_address3 || ', ') ||
    DECODE(x_ship_from_address3, NULL, NULL,x_ship_from_address3 || ', ') ||
    DECODE(x_ship_from_address4, NULL, NULL,x_ship_from_address4 || ', ')
        into x_ship_from_address from dual;
*/
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.ship_from_org_id;
   x_line_changed_attr_tbl(ind).prior_value     := x_prior_ship_from_org;
       end if;
END IF;
END IF; /*  PRIOR */
/****************************/

IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ship_from_org_id,
       p_next_rec.ship_from_org_id) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value     := x_current_ship_from_org;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'Warehouse';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;

   if p_prior_rec.ship_from_org_id is not null then
     OE_ID_TO_VALUE.ship_from_Org
         (   p_ship_from_org_id        => p_prior_rec.ship_from_org_id
        , x_ship_from_address1    => x_ship_from_address1
        , x_ship_from_address2    => x_ship_from_address2
	, x_ship_from_address3    => x_ship_from_address3
	, x_ship_from_address4    => x_ship_from_address4
	, x_ship_from_location    => x_ship_from_location
	, x_ship_from_org         => x_prior_ship_from_org
          );
/*
  select
    DECODE(x_ship_from_location, NULL, NULL,x_ship_from_location|| ', ') ||
    DECODE(x_ship_from_address1, NULL, NULL,x_ship_from_address1 || ', ') ||
    DECODE(x_ship_from_address2, NULL, NULL,x_ship_from_address3 || ', ') ||
    DECODE(x_ship_from_address3, NULL, NULL,x_ship_from_address3 || ', ') ||
    DECODE(x_ship_from_address4, NULL, NULL,x_ship_from_address4 || ', ')
        into x_ship_from_address from dual;
*/
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.ship_from_org_id;
   x_line_changed_attr_tbl(ind).prior_value     := x_prior_ship_from_org;

       end if;
   if p_curr_rec.ship_from_org_id is not null then
     OE_ID_TO_VALUE.ship_from_Org
         (   p_ship_from_org_id        => p_curr_rec.ship_from_org_id
        , x_ship_from_address1    => x_ship_from_address1
        , x_ship_from_address2    => x_ship_from_address2
	, x_ship_from_address3    => x_ship_from_address3
	, x_ship_from_address4    => x_ship_from_address4
	, x_ship_from_location    => x_ship_from_location
	, x_ship_from_org         => x_current_ship_from_org
          );
/*
  select
    DECODE(x_ship_from_location, NULL, NULL,x_ship_from_location|| ', ') ||
    DECODE(x_ship_from_address1, NULL, NULL,x_ship_from_address1 || ', ') ||
    DECODE(x_ship_from_address2, NULL, NULL,x_ship_from_address3 || ', ') ||
    DECODE(x_ship_from_address3, NULL, NULL,x_ship_from_address3 || ', ') ||
    DECODE(x_ship_from_address4, NULL, NULL,x_ship_from_address4 || ', ')
        into x_ship_from_address from dual;
*/
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.ship_from_org_id;
   x_line_changed_attr_tbl(ind).current_value     := x_current_ship_from_org;
       end if;

   if p_next_rec.ship_from_org_id is not null then
     OE_ID_TO_VALUE.ship_from_Org
         (   p_ship_from_org_id        => p_next_rec.ship_from_org_id
        , x_ship_from_address1    => x_ship_from_address1
        , x_ship_from_address2    => x_ship_from_address2
	, x_ship_from_address3    => x_ship_from_address3
	, x_ship_from_address4    => x_ship_from_address4
	, x_ship_from_location    => x_ship_from_location
	, x_ship_from_org         => x_next_ship_from_org
          );
/*
  select
    DECODE(x_ship_from_location, NULL, NULL,x_ship_from_location|| ', ') ||
    DECODE(x_ship_from_address1, NULL, NULL,x_ship_from_address1 || ', ') ||
    DECODE(x_ship_from_address2, NULL, NULL,x_ship_from_address3 || ', ') ||
    DECODE(x_ship_from_address3, NULL, NULL,x_ship_from_address3 || ', ') ||
    DECODE(x_ship_from_address4, NULL, NULL,x_ship_from_address4 || ', ')
        into x_ship_from_address from dual;
*/
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.ship_from_org_id;
   x_line_changed_attr_tbl(ind).next_value     := x_next_ship_from_org;
       end if;
END IF;
END IF; /*  NEXT */

/* END ship_from_org_id*/
/****************************/

/****************************/
/* START ship_to_org_id*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ship_to_org_id,
       p_prior_rec.ship_to_org_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'ship_to';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   if p_curr_rec.ship_to_org_id is not null then
     OE_ID_TO_VALUE.ship_to_Org
         (   p_ship_to_org_id        => p_curr_rec.ship_to_org_id
        , x_ship_to_address1    => x_ship_to_address1
        , x_ship_to_address2    => x_ship_to_address2
	, x_ship_to_address3    => x_ship_to_address3
	, x_ship_to_address4    => x_ship_to_address4
	, x_ship_to_location    => x_ship_to_location
	, x_ship_to_org         => x_ship_to_org
	, x_ship_to_city        => x_ship_to_city
	, x_ship_to_state       => x_ship_to_state
	, x_ship_to_postal_code => x_ship_to_postal_code
	, x_ship_to_country     => x_ship_to_country
          );

  select
    DECODE(x_ship_to_location, NULL, NULL,x_ship_to_location|| ', ') ||
    DECODE(x_ship_to_address1, NULL, NULL,x_ship_to_address1 || ', ') ||
    DECODE(x_ship_to_address2, NULL, NULL,x_ship_to_address3 || ', ') ||
    DECODE(x_ship_to_address3, NULL, NULL,x_ship_to_address3 || ', ') ||
    DECODE(x_ship_to_address4, NULL, NULL,x_ship_to_address4 || ', ') ||
    DECODE(x_ship_to_city, NULL, NULL,x_ship_to_city || ', ') ||
    DECODE(x_ship_to_state, NULL, NULL,x_ship_to_state || ', ') ||
    DECODE(x_ship_to_postal_code, NULL, NULL,x_ship_to_postal_code || ', ') ||
    DECODE(x_ship_to_country, NULL,NULL,x_ship_to_country)
        into x_current_ship_to_address from dual;

   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.ship_to_org_id;
   x_line_changed_attr_tbl(ind).current_value     := x_current_ship_to_address;
       end if;

   if p_prior_rec.ship_to_org_id is not null then
     OE_ID_TO_VALUE.ship_to_Org
         (   p_ship_to_org_id        => p_prior_rec.ship_to_org_id
        , x_ship_to_address1    => x_ship_to_address1
        , x_ship_to_address2    => x_ship_to_address2
	, x_ship_to_address3    => x_ship_to_address3
	, x_ship_to_address4    => x_ship_to_address4
	, x_ship_to_location    => x_ship_to_location
	, x_ship_to_org         => x_ship_to_org
	, x_ship_to_city        => x_ship_to_city
	, x_ship_to_state       => x_ship_to_state
	, x_ship_to_postal_code => x_ship_to_postal_code
	, x_ship_to_country     => x_ship_to_country
          );

  select
    DECODE(x_ship_to_location, NULL, NULL,x_ship_to_location|| ', ') ||
    DECODE(x_ship_to_address1, NULL, NULL,x_ship_to_address1 || ', ') ||
    DECODE(x_ship_to_address2, NULL, NULL,x_ship_to_address3 || ', ') ||
    DECODE(x_ship_to_address3, NULL, NULL,x_ship_to_address3 || ', ') ||
    DECODE(x_ship_to_address4, NULL, NULL,x_ship_to_address4 || ', ') ||
    DECODE(x_ship_to_city, NULL, NULL,x_ship_to_city || ', ') ||
    DECODE(x_ship_to_state, NULL, NULL,x_ship_to_state || ', ') ||
    DECODE(x_ship_to_postal_code, NULL, NULL,x_ship_to_postal_code || ', ') ||
    DECODE(x_ship_to_country, NULL,NULL,x_ship_to_country)
        into x_prior_ship_to_address from dual;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.ship_to_org_id;
   x_line_changed_attr_tbl(ind).prior_value     := x_prior_ship_to_address;
       end if;
END IF;
END IF; /*  PRIOR */
/****************************/

IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ship_to_org_id,
       p_next_rec.ship_to_org_id) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value     := x_current_ship_to_address;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'ship_to';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;

   if p_prior_rec.ship_to_org_id is not null then
     OE_ID_TO_VALUE.ship_to_Org
         (   p_ship_to_org_id        => p_prior_rec.ship_to_org_id
        , x_ship_to_address1    => x_ship_to_address1
        , x_ship_to_address2    => x_ship_to_address2
	, x_ship_to_address3    => x_ship_to_address3
	, x_ship_to_address4    => x_ship_to_address4
	, x_ship_to_location    => x_ship_to_location
	, x_ship_to_org         => x_ship_to_org
	, x_ship_to_city        => x_ship_to_city
	, x_ship_to_state       => x_ship_to_state
	, x_ship_to_postal_code => x_ship_to_postal_code
	, x_ship_to_country     => x_ship_to_country
          );

  select
    DECODE(x_ship_to_location, NULL, NULL,x_ship_to_location|| ', ') ||
    DECODE(x_ship_to_address1, NULL, NULL,x_ship_to_address1 || ', ') ||
    DECODE(x_ship_to_address2, NULL, NULL,x_ship_to_address3 || ', ') ||
    DECODE(x_ship_to_address3, NULL, NULL,x_ship_to_address3 || ', ') ||
    DECODE(x_ship_to_address4, NULL, NULL,x_ship_to_address4 || ', ') ||
    DECODE(x_ship_to_city, NULL, NULL,x_ship_to_city || ', ') ||
    DECODE(x_ship_to_state, NULL, NULL,x_ship_to_state || ', ') ||
    DECODE(x_ship_to_postal_code, NULL, NULL,x_ship_to_postal_code || ', ') ||
    DECODE(x_ship_to_country, NULL,NULL,x_ship_to_country)
        into x_prior_ship_to_address from dual;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.ship_to_org_id;
   x_line_changed_attr_tbl(ind).prior_value     := x_prior_ship_to_address;
       end if;

   if p_curr_rec.ship_to_org_id is not null then
     OE_ID_TO_VALUE.ship_to_Org
         (   p_ship_to_org_id        => p_curr_rec.ship_to_org_id
        , x_ship_to_address1    => x_ship_to_address1
        , x_ship_to_address2    => x_ship_to_address2
	, x_ship_to_address3    => x_ship_to_address3
	, x_ship_to_address4    => x_ship_to_address4
	, x_ship_to_location    => x_ship_to_location
	, x_ship_to_org         => x_ship_to_org
	, x_ship_to_city        => x_ship_to_city
	, x_ship_to_state       => x_ship_to_state
	, x_ship_to_postal_code => x_ship_to_postal_code
	, x_ship_to_country     => x_ship_to_country
          );

  select
    DECODE(x_ship_to_location, NULL, NULL,x_ship_to_location|| ', ') ||
    DECODE(x_ship_to_address1, NULL, NULL,x_ship_to_address1 || ', ') ||
    DECODE(x_ship_to_address2, NULL, NULL,x_ship_to_address3 || ', ') ||
    DECODE(x_ship_to_address3, NULL, NULL,x_ship_to_address3 || ', ') ||
    DECODE(x_ship_to_address4, NULL, NULL,x_ship_to_address4 || ', ') ||
    DECODE(x_ship_to_city, NULL, NULL,x_ship_to_city || ', ') ||
    DECODE(x_ship_to_state, NULL, NULL,x_ship_to_state || ', ') ||
    DECODE(x_ship_to_postal_code, NULL, NULL,x_ship_to_postal_code || ', ') ||
    DECODE(x_ship_to_country, NULL,NULL,x_ship_to_country)
        into x_current_ship_to_address from dual;
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.ship_to_org_id;
   x_line_changed_attr_tbl(ind).current_value     := x_current_ship_to_address;
       end if;

   if p_next_rec.ship_to_org_id is not null then
     OE_ID_TO_VALUE.ship_to_Org
         (   p_ship_to_org_id        => p_next_rec.ship_to_org_id
        , x_ship_to_address1    => x_ship_to_address1
        , x_ship_to_address2    => x_ship_to_address2
	, x_ship_to_address3    => x_ship_to_address3
	, x_ship_to_address4    => x_ship_to_address4
	, x_ship_to_location    => x_ship_to_location
	, x_ship_to_org         => x_ship_to_org
	, x_ship_to_city        => x_ship_to_city
	, x_ship_to_state       => x_ship_to_state
	, x_ship_to_postal_code => x_ship_to_postal_code
	, x_ship_to_country     => x_ship_to_country
          );

  select
    DECODE(x_ship_to_location, NULL, NULL,x_ship_to_location|| ', ') ||
    DECODE(x_ship_to_address1, NULL, NULL,x_ship_to_address1 || ', ') ||
    DECODE(x_ship_to_address2, NULL, NULL,x_ship_to_address3 || ', ') ||
    DECODE(x_ship_to_address3, NULL, NULL,x_ship_to_address3 || ', ') ||
    DECODE(x_ship_to_address4, NULL, NULL,x_ship_to_address4 || ', ') ||
    DECODE(x_ship_to_city, NULL, NULL,x_ship_to_city || ', ') ||
    DECODE(x_ship_to_state, NULL, NULL,x_ship_to_state || ', ') ||
    DECODE(x_ship_to_postal_code, NULL, NULL,x_ship_to_postal_code || ', ') ||
    DECODE(x_ship_to_country, NULL,NULL,x_ship_to_country)
        into x_next_ship_to_address from dual;
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.ship_to_org_id;
   x_line_changed_attr_tbl(ind).next_value     := x_next_ship_to_address;
       end if;
END IF;
END IF; /*  NEXT */

/* END ship_to_org_id*/
/****************************/

/****************************/
/* START shipping_instructions*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.shipping_instructions,
       p_prior_rec.shipping_instructions) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'shipping_instructions';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.shipping_instructions;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.shipping_instructions;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.shipping_instructions,
       p_next_rec.shipping_instructions) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.shipping_instructions;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'shipping_instructions';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.shipping_instructions;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.shipping_instructions;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.shipping_instructions;
END IF;
END IF; /*  NEXT */

/* END shipping_instructions*/
/****************************/

/****************************/
/* START packing_instructions*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.packing_instructions,
       p_prior_rec.packing_instructions) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'packing_instructions';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.packing_instructions;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.packing_instructions;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.packing_instructions,
       p_next_rec.packing_instructions) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.packing_instructions;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'packing_instructions';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.packing_instructions;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.packing_instructions;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.packing_instructions;
END IF;
END IF; /*  NEXT */

/* END packing_instructions*/
/****************************/

/****************************/
/* START MAX_RELEASE_AMOUNT*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.MAX_RELEASE_AMOUNT,
       p_prior_rec.MAX_RELEASE_AMOUNT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'MAX_RELEASE_AMOUNT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.MAX_RELEASE_AMOUNT;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.MAX_RELEASE_AMOUNT;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.MAX_RELEASE_AMOUNT,
       p_next_rec.MAX_RELEASE_AMOUNT) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.MAX_RELEASE_AMOUNT;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'MAX_RELEASE_AMOUNT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.MAX_RELEASE_AMOUNT;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.MAX_RELEASE_AMOUNT;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.MAX_RELEASE_AMOUNT;
END IF;
END IF; /*  NEXT */

/* END MAX_RELEASE_AMOUNT*/
/****************************/

/****************************/
/* START MIN_RELEASE_AMOUNT*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.MIN_RELEASE_AMOUNT,
       p_prior_rec.MIN_RELEASE_AMOUNT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'MIN_RELEASE_AMOUNT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.MIN_RELEASE_AMOUNT;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.MIN_RELEASE_AMOUNT;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.MIN_RELEASE_AMOUNT,
       p_next_rec.MIN_RELEASE_AMOUNT) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.MIN_RELEASE_AMOUNT;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'MIN_RELEASE_AMOUNT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.MIN_RELEASE_AMOUNT;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.MIN_RELEASE_AMOUNT;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.MIN_RELEASE_AMOUNT;
END IF;
END IF; /*  NEXT */

/* END MIN_RELEASE_AMOUNT*/
/****************************/
/****************************/
/* START START_DATE_ACTIVE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.START_DATE_ACTIVE,
       p_prior_rec.START_DATE_ACTIVE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'START_DATE_ACTIVE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.START_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.START_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.START_DATE_ACTIVE,
       p_next_rec.START_DATE_ACTIVE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.START_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'START_DATE_ACTIVE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.START_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.START_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.START_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  NEXT */

/* END START_DATE_ACTIVE*/
/****************************/

/****************************/
/* START END_DATE_ACTIVE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.END_DATE_ACTIVE,
       p_prior_rec.END_DATE_ACTIVE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'END_DATE_ACTIVE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.END_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.END_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.END_DATE_ACTIVE,
       p_next_rec.END_DATE_ACTIVE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.END_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'END_DATE_ACTIVE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.END_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.END_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.END_DATE_ACTIVE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  NEXT */

/* END END_DATE_ACTIVE*/
/****************************/

/****************************/
/* START BLANKET_MAX_QUANTITY*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.BLANKET_MAX_QUANTITY,
       p_prior_rec.BLANKET_MAX_QUANTITY) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'BLANKET_MAX_QUANTITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.BLANKET_MAX_QUANTITY;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.BLANKET_MAX_QUANTITY;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.BLANKET_MAX_QUANTITY,
       p_next_rec.BLANKET_MAX_QUANTITY) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.BLANKET_MAX_QUANTITY;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'BLANKET_MAX_QUANTITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.BLANKET_MAX_QUANTITY;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.BLANKET_MAX_QUANTITY;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.BLANKET_MAX_QUANTITY;
END IF;
END IF; /*  NEXT */

/* END BLANKET_MAX_QUANTITY*/
/****************************/
/****************************/
/* START BLANKET_MIN_QUANTITY*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.BLANKET_MIN_QUANTITY,
       p_prior_rec.BLANKET_MIN_QUANTITY) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'BLANKET_MIN_QUANTITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.BLANKET_MIN_QUANTITY;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.BLANKET_MIN_QUANTITY;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.BLANKET_MIN_QUANTITY,
       p_next_rec.BLANKET_MIN_QUANTITY) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.BLANKET_MIN_QUANTITY;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'BLANKET_MIN_QUANTITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.BLANKET_MIN_QUANTITY;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.BLANKET_MIN_QUANTITY;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.BLANKET_MIN_QUANTITY;
END IF;
END IF; /*  NEXT */

/* END BLANKET_MIN_QUANTITY*/
/****************************/

/****************************/
/* START OVERRIDE_BLANKET_CONTROLS_FLAG*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.OVERRIDE_BLANKET_CONTROLS_FLAG,
       p_prior_rec.OVERRIDE_BLANKET_CONTROLS_FLAG) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'OVERRIDE_BLANKET_CONTROLS_FLAG';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.OVERRIDE_BLANKET_CONTROLS_FLAG;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.OVERRIDE_BLANKET_CONTROLS_FLAG;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.OVERRIDE_BLANKET_CONTROLS_FLAG,
       p_next_rec.OVERRIDE_BLANKET_CONTROLS_FLAG) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.OVERRIDE_BLANKET_CONTROLS_FLAG;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'OVERRIDE_BLANKET_CONTROLS_FLAG';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.OVERRIDE_BLANKET_CONTROLS_FLAG;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.OVERRIDE_BLANKET_CONTROLS_FLAG;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.OVERRIDE_BLANKET_CONTROLS_FLAG;
END IF;
END IF; /*  NEXT */

/* END OVERRIDE_BLANKET_CONTROLS_FLAG*/
/****************************/

/****************************/
/* START OVERRIDE_RELEASE_CONTROLS_FLAG*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.OVERRIDE_RELEASE_CONTROLS_FLAG,
       p_prior_rec.OVERRIDE_RELEASE_CONTROLS_FLAG) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'OVERRIDE_RELEASE_CONTROLS_FLAG';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.OVERRIDE_RELEASE_CONTROLS_FLAG;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.OVERRIDE_RELEASE_CONTROLS_FLAG;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.OVERRIDE_RELEASE_CONTROLS_FLAG,
       p_next_rec.OVERRIDE_RELEASE_CONTROLS_FLAG) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.OVERRIDE_RELEASE_CONTROLS_FLAG;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'OVERRIDE_RELEASE_CONTROLS_FLAG';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.OVERRIDE_RELEASE_CONTROLS_FLAG;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.OVERRIDE_RELEASE_CONTROLS_FLAG;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.OVERRIDE_RELEASE_CONTROLS_FLAG;
END IF;
END IF; /*  NEXT */

/* END OVERRIDE_RELEASE_CONTROLS_FLAG*/
/****************************/
/****************************/
/* START ENFORCE_PRICE_LIST_FLAG*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ENFORCE_PRICE_LIST_FLAG,
       p_prior_rec.ENFORCE_PRICE_LIST_FLAG) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'ENFORCE_PRICE_LIST_FLAG_DUP';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.ENFORCE_PRICE_LIST_FLAG;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.ENFORCE_PRICE_LIST_FLAG;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ENFORCE_PRICE_LIST_FLAG,
       p_next_rec.ENFORCE_PRICE_LIST_FLAG) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.ENFORCE_PRICE_LIST_FLAG;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'ENFORCE_PRICE_LIST_FLAG_DUP';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.ENFORCE_PRICE_LIST_FLAG;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.ENFORCE_PRICE_LIST_FLAG;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.ENFORCE_PRICE_LIST_FLAG;
END IF;
END IF; /*  NEXT */

/* END ENFORCE_PRICE_LIST_FLAG*/
/****************************/

/****************************/
/* START enforce_ship_to_flag*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_ship_to_flag,
       p_prior_rec.enforce_ship_to_flag) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'enforce_ship_to_flag';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.enforce_ship_to_flag;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_ship_to_flag;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_ship_to_flag,
       p_next_rec.enforce_ship_to_flag) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.enforce_ship_to_flag;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'enforce_ship_to_flag';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_ship_to_flag;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.enforce_ship_to_flag;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.enforce_ship_to_flag;
END IF;
END IF; /*  NEXT */

/* END enforce_ship_to_flag*/
/****************************/

/****************************/
/* START enforce_invoice_to_flag*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_invoice_to_flag,
       p_prior_rec.enforce_invoice_to_flag) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'enforce_invoice_to_flag';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.enforce_invoice_to_flag;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_invoice_to_flag;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_invoice_to_flag,
       p_next_rec.enforce_invoice_to_flag) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.enforce_invoice_to_flag;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'enforce_invoice_to_flag';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_invoice_to_flag;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.enforce_invoice_to_flag;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.enforce_invoice_to_flag;
END IF;
END IF; /*  NEXT */

/* END enforce_invoice_to_flag*/
/****************************/

/****************************/
/* START enforce_freight_term_flag*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_freight_term_flag,
       p_prior_rec.enforce_freight_term_flag) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'enforce_freight_term_flag';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.enforce_freight_term_flag;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_freight_term_flag;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_freight_term_flag,
       p_next_rec.enforce_freight_term_flag) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.enforce_freight_term_flag;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'enforce_freight_term_flag';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_freight_term_flag;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.enforce_freight_term_flag;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.enforce_freight_term_flag;
END IF;
END IF; /*  NEXT */

/* END enforce_freight_term_flag*/
/****************************/

/****************************/
/* START enforce_shipping_method_flag*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_shipping_method_flag,
       p_prior_rec.enforce_shipping_method_flag) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'enforce_shipping_method_flag';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.enforce_shipping_method_flag;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_shipping_method_flag;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_shipping_method_flag,
       p_next_rec.enforce_shipping_method_flag) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.enforce_shipping_method_flag;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'enforce_shipping_method_flag';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_shipping_method_flag;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.enforce_shipping_method_flag;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.enforce_shipping_method_flag;
END IF;
END IF; /*  NEXT */

/* END enforce_shipping_method_flag*/
/****************************/

/****************************/
/* START enforce_payment_term_flag*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_payment_term_flag,
       p_prior_rec.enforce_payment_term_flag) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'enforce_payment_term_flag';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.enforce_payment_term_flag;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_payment_term_flag;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_payment_term_flag,
       p_next_rec.enforce_payment_term_flag) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.enforce_payment_term_flag;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'enforce_payment_term_flag';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_payment_term_flag;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.enforce_payment_term_flag;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.enforce_payment_term_flag;
END IF;
END IF; /*  NEXT */

/* END enforce_payment_term_flag*/
/****************************/

/****************************/
/* START enforce_accounting_rule_flag*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_accounting_rule_flag,
       p_prior_rec.enforce_accounting_rule_flag) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'enforce_accounting_rule_flag';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.enforce_accounting_rule_flag;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_accounting_rule_flag;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.enforce_accounting_rule_flag,
       p_next_rec.enforce_accounting_rule_flag) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.enforce_accounting_rule_flag;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'enforce_accounting_rule_flag';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.enforce_accounting_rule_flag;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.enforce_accounting_rule_flag;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.enforce_accounting_rule_flag;
END IF;
END IF; /*  NEXT */

/* END enforce_accounting_rule_flag*/
/****************************/

/****************************/
/* START BLANKET_MAX_AMOUNT*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.BLANKET_MAX_AMOUNT,
       p_prior_rec.BLANKET_MAX_AMOUNT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'BLANKET_LINE_MAX_AMOUNT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.BLANKET_MAX_AMOUNT;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.BLANKET_MAX_AMOUNT;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.BLANKET_MAX_AMOUNT,
       p_next_rec.BLANKET_MAX_AMOUNT) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.BLANKET_MAX_AMOUNT;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'BLANKET_LINE_MAX_AMOUNT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.BLANKET_MAX_AMOUNT;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.BLANKET_MAX_AMOUNT;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.BLANKET_MAX_AMOUNT;
END IF; /*  NEXT */
END IF;

/* END BLANKET_MAX_AMOUNT*/
/****************************/

/****************************/
/* START BLANKET_MIN_AMOUNT*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.BLANKET_MIN_AMOUNT,
       p_prior_rec.BLANKET_MIN_AMOUNT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'BLANKET_LINE_MIN_AMOUNT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.BLANKET_MIN_AMOUNT;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.BLANKET_MIN_AMOUNT;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.BLANKET_MIN_AMOUNT,
       p_next_rec.BLANKET_MIN_AMOUNT) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.BLANKET_MIN_AMOUNT;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'BLANKET_LINE_MIN_AMOUNT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.BLANKET_MIN_AMOUNT;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.BLANKET_MIN_AMOUNT;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.BLANKET_MIN_AMOUNT;
END IF;
END IF; /*  NEXT */

/* END BLANKET_MIN_AMOUNT*/
/****************************/

/****************************/
/* START FULFILLED_QUANTITY*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.FULFILLED_QUANTITY,
       p_prior_rec.FULFILLED_QUANTITY) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'FULFILLED_QUANTITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.FULFILLED_QUANTITY;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.FULFILLED_QUANTITY;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.FULFILLED_QUANTITY,
       p_next_rec.FULFILLED_QUANTITY) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.FULFILLED_QUANTITY;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'FULFILLED_QUANTITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.FULFILLED_QUANTITY;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.FULFILLED_QUANTITY;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.FULFILLED_QUANTITY;
END IF;
END IF; /*  NEXT */

/* END FULFILLED_QUANTITY*/
/****************************/

/****************************/
/* START RELEASED_QUANTITY*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.RELEASED_QUANTITY,
       p_prior_rec.RELEASED_QUANTITY) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'RELEASED_QUANTITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.RELEASED_QUANTITY;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.RELEASED_QUANTITY;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.RELEASED_QUANTITY,
       p_next_rec.RELEASED_QUANTITY) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.RELEASED_QUANTITY;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'RELEASED_QUANTITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.RELEASED_QUANTITY;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.RELEASED_QUANTITY;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.RELEASED_QUANTITY;
END IF;
END IF; /*  NEXT */

/* END RELEASED_QUANTITY*/
/****************************/

/****************************/
/* START RETURNED_QUANTITY*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.RETURNED_QUANTITY,
       p_prior_rec.RETURNED_QUANTITY) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'RETURNED_QUANTITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.RETURNED_QUANTITY;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.RETURNED_QUANTITY;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.RETURNED_QUANTITY,
       p_next_rec.RETURNED_QUANTITY) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.RETURNED_QUANTITY;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'RETURNED_QUANTITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.RETURNED_QUANTITY;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.RETURNED_QUANTITY;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.RETURNED_QUANTITY;
END IF;
END IF; /*  NEXT */

/* END RETURNED_QUANTITY*/
/****************************/

/****************************/
/* START ORDER_NUMBER*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ORDER_NUMBER,
       p_prior_rec.ORDER_NUMBER) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'ORDER_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.ORDER_NUMBER;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.ORDER_NUMBER;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ORDER_NUMBER,
       p_next_rec.ORDER_NUMBER) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.ORDER_NUMBER;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'ORDER_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.ORDER_NUMBER;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.ORDER_NUMBER;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.ORDER_NUMBER;
END IF;
END IF; /*  NEXT */

/* END ORDER_NUMBER*/
/****************************/

/****************************/
/* START RELEASED_AMOUNT*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.RELEASED_AMOUNT,
       p_prior_rec.RELEASED_AMOUNT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'RELEASED_AMOUNT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.RELEASED_AMOUNT;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.RELEASED_AMOUNT;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.RELEASED_AMOUNT,
       p_next_rec.RELEASED_AMOUNT) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.RELEASED_AMOUNT;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'RELEASED_AMOUNT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.RELEASED_AMOUNT;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.RELEASED_AMOUNT;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.RELEASED_AMOUNT;
END IF;
END IF; /*  NEXT */

/* END RELEASED_AMOUNT*/
/****************************/

/****************************/
/* START FULFILLED_AMOUNT*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.FULFILLED_AMOUNT,
       p_prior_rec.FULFILLED_AMOUNT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'FULFILLED_AMOUNT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.FULFILLED_AMOUNT;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.FULFILLED_AMOUNT;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.FULFILLED_AMOUNT,
       p_next_rec.FULFILLED_AMOUNT) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.FULFILLED_AMOUNT;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'FULFILLED_AMOUNT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.FULFILLED_AMOUNT;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.FULFILLED_AMOUNT;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.FULFILLED_AMOUNT;
END IF;
END IF; /*  NEXT */

/* END FULFILLED_AMOUNT*/
/****************************/

/****************************/
/* START RETURNED_AMOUNT*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.RETURNED_AMOUNT,
       p_prior_rec.RETURNED_AMOUNT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'RETURNED_AMOUNT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.RETURNED_AMOUNT;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.RETURNED_AMOUNT;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.RETURNED_AMOUNT,
       p_next_rec.RETURNED_AMOUNT) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.RETURNED_AMOUNT;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'RETURNED_AMOUNT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.RETURNED_AMOUNT;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.RETURNED_AMOUNT;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.RETURNED_AMOUNT;
END IF;
END IF; /*  NEXT */

/* END RETURNED_AMOUNT*/
/****************************/
ELSE
NULL;
END IF; /* if prior or next exists*/
/*
END LOOP;
CLOSE C_GET_LINES;
*/
END IF; /* line_id not null */
IF l_debug_level > 0 THEN
  oe_debug_pub.add('******AFTER COMPARING ATTRIBUTES*************');
  oe_debug_pub.add('current ind '|| ind);
END IF;
END COMPARE_ATTRIBUTES;

/***************************************************/

PROCEDURE COMPARE_LINE_VERSIONS
(p_header_id	                  NUMBER,
 p_line_id	                  NUMBER,
 p_prior_version                  NUMBER,
 p_current_version                NUMBER,
 p_next_version                   NUMBER,
 g_max_version                    NUMBER,
 g_trans_version                  NUMBER,
 g_prior_phase_change_flag        VARCHAR2,
 g_curr_phase_change_flag         VARCHAR2,
 g_next_phase_change_flag         VARCHAR2,
 x_line_changed_attr_tbl        IN OUT NOCOPY OE_VERSION_BLANKET_COMP.line_tbl_type)
IS

l_line_id NUMBER;

CURSOR C_get_lines(p_header_id IN NUMBER,p_prior_version IN NUMBER, p_current_version IN NUMBER, p_next_version IN NUMBER) IS
           SELECT distinct line_id,line_number
	   from oe_blanket_lines_hist
	   where header_id = p_header_id
           --and transaction_phase_code = p_transaction_phase_code
           and version_number in (p_prior_version,p_current_version,p_next_version)
	   union
           SELECT line_id,line_number
           from oe_blanket_lines_all
           where header_id=p_header_id;
           --and transaction_phase_code = p_transaction_phase_code;

CURSOR C_get_hist_lines(p_header_id IN NUMBER,p_prior_version IN NUMBER, p_current_version IN NUMBER, p_next_version IN NUMBER) IS
           SELECT distinct line_id,line_number
	   from oe_blanket_lines_hist
	   where header_id = p_header_id
          -- and transaction_phase_code = p_transaction_phase_code
           and version_number in (p_prior_version,p_current_version,p_next_version);

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
ind1 NUMBER;
total_lines NUMBER;
x_line_number NUMBER;
BEGIN

IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering  COMPARE_LINE_VERSIONS');
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('prior version' ||p_prior_version);
  oe_debug_pub.add('current version' ||p_current_version);
  oe_debug_pub.add('next version' ||p_next_version);
  oe_debug_pub.add('max version' ||g_max_version);
  oe_debug_pub.add('trans version' ||g_trans_version);
END IF;

ind1:=0;
total_lines:=0;
IF p_header_id IS NOT NULL THEN
  IF p_next_version = g_trans_version THEN
    OPEN C_GET_LINES(p_header_id,p_prior_version,p_current_version,p_next_version);
    LOOP
    FETCH C_GET_LINES INTO l_line_id,x_line_number;
    EXIT WHEN C_GET_LINES%NOTFOUND;
    IF l_debug_level  > 0 THEN
         oe_debug_pub.add('*************lines found(trans)******************'||l_line_id);
    END IF;

     IF l_line_id IS NOT NULL THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************before call total lines(trans) ******************'||ind1);
         END IF;
         COMPARE_ATTRIBUTES(p_header_id                 => p_header_id,
                          p_line_id                     => l_line_id,
                          p_prior_version               => p_prior_version,
                          p_current_version             => p_current_version,
                          p_next_version                => p_next_version,
                          g_max_version                 => g_max_version,
                          g_trans_version               => g_trans_version,
                          g_prior_phase_change_flag     => g_prior_phase_change_flag,
                          g_curr_phase_change_flag      => g_curr_phase_change_flag,
                          g_next_phase_change_flag      => g_next_phase_change_flag,
                          x_line_changed_attr_tbl       => x_line_changed_attr_tbl,
                          p_total_lines                 => ind1,
                          x_line_number                 => x_line_number);
         IF x_line_changed_attr_tbl.count > 0 THEN
		ind1 := x_line_changed_attr_tbl.count;
	--	ind1 := ind1 + total_lines;
         END IF;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************after call total lines(trans) ******************'||ind1);
         END IF;
     END IF; /* line_id is not null */
    END LOOP;
    CLOSE C_GET_LINES;
  ELSE
    OPEN C_GET_HIST_LINES(p_header_id,p_prior_version,p_current_version,p_next_version);
    LOOP
    FETCH C_GET_HIST_LINES INTO l_line_id,x_line_number;
    EXIT WHEN C_GET_HIST_LINES%NOTFOUND;
    IF l_debug_level  > 0 THEN
         oe_debug_pub.add('*************lines found******************'||l_line_id);
    END IF;

     IF l_line_id IS NOT NULL THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************before call total lines ******************'||ind1);
         END IF;
         COMPARE_ATTRIBUTES(p_header_id                 => p_header_id,
                          p_line_id                     => l_line_id,
                          p_prior_version               => p_prior_version,
                          p_current_version             => p_current_version,
                          p_next_version                => p_next_version,
                          g_max_version                 => g_max_version,
                          g_trans_version               => g_trans_version,
                          g_prior_phase_change_flag     => g_prior_phase_change_flag,
                          g_curr_phase_change_flag      => g_curr_phase_change_flag,
                          g_next_phase_change_flag      => g_next_phase_change_flag,
                          x_line_changed_attr_tbl       => x_line_changed_attr_tbl,
                          p_total_lines                 => ind1,
                          x_line_number                 => x_line_number);
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************after call total lines ******************'||ind1);
         END IF;
         IF x_line_changed_attr_tbl.count > 0 THEN
		ind1 := x_line_changed_attr_tbl.count;
	--	ind1 := ind1 + total_lines;
         END IF;
     END IF; /* line_id is not null */
    END LOOP;
    CLOSE C_GET_HIST_LINES;
  END IF;/* next equals trans */
END IF;/*header_id is not null*/
END COMPARE_LINE_VERSIONS;

FUNCTION line_status
(   p_line_status_code            IN  VARCHAR2
) RETURN VARCHAR2
IS
l_line_status               VARCHAR2(240) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_line_status_code IS NOT NULL THEN

        SELECT  MEANING
        INTO    l_line_status
        FROM    OE_LOOKUPS
        WHERE   LOOKUP_CODE = p_line_status_code
        AND     LOOKUP_TYPE = 'VERSION_COMP_LINE_STATUS';

    END IF;

    RETURN l_line_status;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('could not find line_status meaning');
         END IF;
        RETURN NULL;
    WHEN OTHERS THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('others exception - line_status meaning');
         END IF;
        RETURN NULL;
END line_status;
/***************************************************/
--added for bug 4302049
/* Function to get segment prompt */

 FUNCTION get_dff_seg_prompt(p_application_id               IN NUMBER,
		     p_descriptive_flexfield_name   IN VARCHAR2,
		     p_descriptive_flex_context_cod IN VARCHAR2,
		     p_desc_flex_context_cod_prior IN VARCHAR2,
		     p_desc_flex_context_cod_next IN VARCHAR2,
		     p_application_column_name      IN VARCHAR2)
   RETURN VARCHAR2
 IS
   l_prompt varchar2(2000);
   x_prompt varchar2(2000);
   slash    varchar2(20);
   CURSOR c1 IS select form_left_prompt from fnd_descr_flex_col_usage_vl
	   where application_id=660
	   and descriptive_flexfield_name= p_descriptive_flexfield_name
	   and application_column_name =p_application_column_name
	   and DESCRIPTIVE_FLEX_CONTEXT_CODE in (p_descriptive_flex_context_cod, p_desc_flex_context_cod_prior, p_desc_flex_context_cod_next, 'Global Data Elements');
   BEGIN
	 oe_debug_pub.add('Entering get_dff_seg_prompt');
	fnd_message.set_name('ONT','ONT_SLASH_SEPARATOR');
	slash:=FND_MESSAGE.GET;

	IF p_application_column_name = 'CONTEXT' THEN		--Context Prompt
		select FORM_CONTEXT_PROMPT into l_prompt from FND_DESCRIPTIVE_FLEXS_VL
		where APPLICATION_ID = p_application_id
		and DESCRIPTIVE_FLEXFIELD_NAME = p_descriptive_flexfield_name;

		oe_debug_pub.add('Context Prompt='||l_prompt);
	ELSE						--Attribute Prompt
	IF p_descriptive_flex_context_cod IS NULL
	 AND p_desc_flex_context_cod_prior IS NULL
	  AND p_desc_flex_context_cod_next IS NULL THEN
	  select form_left_prompt into l_prompt from fnd_descr_flex_col_usage_vl where application_id=660
	   and descriptive_flexfield_name= p_descriptive_flexfield_name
	   and application_column_name =p_application_column_name;

           oe_debug_pub.add('Prompt='||l_prompt);

	ELSE						--Context has been passed
  	   OPEN c1;
	   LOOP
	       FETCH c1 into l_prompt;
	       EXIT WHEN c1%NOTFOUND;
	       if x_prompt IS NULL THEN
			x_prompt:=l_prompt;
		ELSIF x_prompt <> l_prompt   THEN
			x_prompt:=x_prompt||slash||l_prompt;
		END IF;
           END LOOP;
           CLOSE C1;
           oe_debug_pub.add('Prompt='||x_prompt);
	   RETURN(x_prompt);
       END IF;				--Context been passed
       END IF;				--Context/Attribute Prompt

      RETURN(l_prompt);
EXCEPTION
   WHEN no_data_found THEN
	Return null;
   WHEN OTHERS THEN
	oe_debug_pub.add('error is'||SQLCODE||'message'||SQLERRM);
	Return Null;
END get_dff_seg_prompt;
--bug 4302049

END OE_VERSION_BLANKET_COMP;

/
