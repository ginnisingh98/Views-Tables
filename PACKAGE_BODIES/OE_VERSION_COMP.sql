--------------------------------------------------------
--  DDL for Package Body OE_VERSION_COMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VERSION_COMP" AS
/* $Header: OEXSCOMB.pls 120.11.12010000.8 2010/04/09 09:34:57 msundara ship $ */

PROCEDURE QUERY_HEADER_ROW
(p_header_id	                  NUMBER,
 p_version	                  NUMBER,
 p_phase_change_flag    	  VARCHAR2,
 x_header_rec                    IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type)
IS
l_org_id                NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
oe_debug_pub.add('l_debug_level'||l_debug_level );
IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering OE_VERSION_COMP.QUERY_HEADER_ROW'||p_version );
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
    ,       ACCOUNTING_RULE_DURATION
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
  --  ,       DEFAULT_FULFILLMENT_SET
  --  ,       FULFILLMENT_SET_NAME
  --  ,       LINE_SET_NAME
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
--    ,       XML_MESSAGE_ID
    ,       upgraded_flag
    ,       LOCK_CONTROL
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
    ,       INSTRUMENT_ID
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
    ,       x_header_rec.attribute16
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
    ,	    x_header_rec.sold_from_org_id
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
   -- ,       x_header_rec.default_fulfillment_set
   -- ,       x_header_rec.fulfillment_set_name
   -- ,       x_header_rec.line_set_name
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
--    ,       x_header_rec.xml_message_id
    ,       x_header_rec.upgraded_flag
    ,       x_header_rec.lock_control
    ,       x_header_rec.quote_date
    ,       x_header_rec.quote_number
    ,       x_header_rec.sales_document_name
    ,       x_header_rec.transaction_phase_code
    ,       x_header_rec.user_status_code
    ,       x_header_rec.draft_submitted_flag
    ,       x_header_rec.source_document_version_number
    ,       x_header_rec.sold_to_site_use_id
    ,       x_header_rec.MINISITE_ID
    ,       x_header_rec.IB_OWNER
    ,       x_header_rec.IB_INSTALLED_AT_LOCATION
    ,       x_header_rec.IB_CURRENT_LOCATION
    ,       x_header_rec.END_CUSTOMER_ID
    ,       x_header_rec.END_CUSTOMER_CONTACT_ID
    ,       x_header_rec.END_CUSTOMER_SITE_USE_ID
    ,       x_header_rec.SUPPLIER_SIGNATURE
    ,       x_header_rec.SUPPLIER_SIGNATURE_DATE
    ,       x_header_rec.CUSTOMER_SIGNATURE
    ,       x_header_rec.CUSTOMER_SIGNATURE_DATE
    ,       x_header_rec.CC_INSTRUMENT_ID
    FROM    OE_ORDER_HEADER_HISTORY
    WHERE   HEADER_ID = p_header_id
    AND VERSION_NUMBER = p_version
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
 x_header_rec                    IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type)
IS
l_org_id                NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering OE_VERSION_COMP.QUERY_HEADER_TRANS_ROW');
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('version' ||p_version);
END IF;

    l_org_id := OE_GLOBALS.G_ORG_ID;

    IF l_org_id IS NULL THEN
      OE_GLOBALS.Set_Context;
      l_org_id := OE_GLOBALS.G_ORG_ID;
    END IF;

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
    ,       ATTRIBUTE16
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
  --  ,       DEFAULT_FULFILLMENT_SET
  --  ,       FULFILLMENT_SET_NAME
  --  ,       LINE_SET_NAME
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
--    ,       XML_MESSAGE_ID
    ,       upgraded_flag
    ,       LOCK_CONTROL
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
    ,       x_header_rec.attribute16
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
    ,	    x_header_rec.sold_from_org_id
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
   -- ,       x_header_rec.default_fulfillment_set
   -- ,       x_header_rec.fulfillment_set_name
   -- ,       x_header_rec.line_set_name
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
--    ,       x_header_rec.xml_message_id
    ,       x_header_rec.upgraded_flag
    ,       x_header_rec.lock_control
    ,       x_header_rec.quote_date
    ,       x_header_rec.quote_number
    ,       x_header_rec.sales_document_name
    ,       x_header_rec.transaction_phase_code
    ,       x_header_rec.user_status_code
    ,       x_header_rec.draft_submitted_flag
    ,       x_header_rec.source_document_version_number
    ,       x_header_rec.sold_to_site_use_id
    ,       x_header_rec.MINISITE_ID
    ,       x_header_rec.IB_OWNER
    ,       x_header_rec.IB_INSTALLED_AT_LOCATION
    ,       x_header_rec.IB_CURRENT_LOCATION
    ,       x_header_rec.END_CUSTOMER_ID
    ,       x_header_rec.END_CUSTOMER_CONTACT_ID
    ,       x_header_rec.END_CUSTOMER_SITE_USE_ID
    ,       x_header_rec.SUPPLIER_SIGNATURE
    ,       x_header_rec.SUPPLIER_SIGNATURE_DATE
    ,       x_header_rec.CUSTOMER_SIGNATURE
    ,       x_header_rec.CUSTOMER_SIGNATURE_DATE
    FROM    OE_ORDER_HEADERS_ALL
    WHERE   HEADER_ID = p_header_id
            AND VERSION_NUMBER = p_version;

    IF x_header_rec.payment_type_code = 'CREDIT_CARD' THEN
      OE_HEADER_UTIL.Query_card_details
               ( p_header_id    => x_header_rec.header_id,
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

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	 null;
    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
               'Query_HEADER_Trans_Row'
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
 g_prior_phase_change_flag	  VARCHAR2,
 g_curr_phase_change_flag	  VARCHAR2,
 g_next_phase_change_flag	  VARCHAR2,
 x_header_changed_attr_tbl        IN OUT NOCOPY OE_VERSION_COMP.header_tbl_type)
IS
p_curr_rec                       OE_Order_PUB.Header_Rec_Type;
p_next_rec                       OE_Order_PUB.Header_Rec_Type;
p_prior_rec                      OE_Order_PUB.Header_Rec_Type;

v_totcol NUMBER := 10;
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
x_prior_sold_to_location           VARCHAR2(2000);
x_current_sold_to_location         VARCHAR2(2000);
x_next_sold_to_location            VARCHAR2(2000);

l_is_equal			VARCHAR2(1) := 'N';
l_curr_value			VARCHAR2(80);
l_prior_value			VARCHAR2(80);
l_next_value			VARCHAR2(80);

l_is_card_history1		VARCHAR2(1) := 'N';
l_is_card_history2		VARCHAR2(1) := 'N';
l_encrypted	VARCHAR2(30);  --PADSS
l_encrypted1	VARCHAR2(30);  --PADSS


l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  oe_debug_pub.add('Entering OE_VERSION_COMP'||l_debug_level);
IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering OE_VERSION_COMP.COMPARE_HEADER_VERSIONS');
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('prior_version' ||p_prior_version);
  oe_debug_pub.add('curr_version' ||p_current_version);
  oe_debug_pub.add('next_version' ||p_next_version);
  oe_debug_pub.add('max_version' ||g_max_version);
  oe_debug_pub.add('trans_version' ||g_trans_version);
  oe_debug_pub.add('prior phase chagne' ||g_prior_phase_change_flag);
  oe_debug_pub.add('curr phase chagne' ||g_curr_phase_change_flag);
  oe_debug_pub.add('next phase chagne' ||g_next_phase_change_flag);
END IF;

IF p_prior_version IS NOT NULL THEN
OE_VERSION_COMP.QUERY_HEADER_ROW(p_header_id       => p_header_id,
			  p_version                => p_prior_version,
                          p_phase_change_flag => g_prior_phase_change_flag,
			  x_header_rec             => p_prior_rec);
END IF;
IF p_current_version IS NOT NULL THEN
OE_VERSION_COMP.QUERY_HEADER_ROW(p_header_id       => p_header_id,
                          p_version                => p_current_version,
                          p_phase_change_flag => g_curr_phase_change_flag,
			  x_header_rec             => p_curr_rec);
END IF;
IF p_next_version = g_trans_version then
       IF g_trans_version is not null then
        --p_next_version := g_trans_version;
       OE_VERSION_COMP.QUERY_HEADER_TRANS_ROW(p_header_id       => p_header_id,
                          p_version                => g_trans_version,
			  x_header_rec             => p_next_rec);
        END IF;
ELSE
IF p_next_version IS NOT NULL THEN
OE_VERSION_COMP.QUERY_HEADER_ROW(p_header_id       => p_header_id,
                          p_version                => p_next_version,
                          p_phase_change_flag => g_next_phase_change_flag,
			  x_header_rec             => p_next_rec);
END IF;
END IF;

IF v_totcol > 0 THEN
ind:=0;
--dbms_output.put_line(' in cursor');
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
END IF; /*  NEXT */
END IF;
/* END ACCOUNTING_RULE_ID*/
/****************************/

/****************************/
/* START accounting_rule_duration*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.accounting_rule_duration,
       p_prior_rec.accounting_rule_duration) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'accounting_rule_duration';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.accounting_rule_duration;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.accounting_rule_duration;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.accounting_rule_duration,
       p_next_rec.accounting_rule_duration) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.accounting_rule_duration;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'accounting_rule_duration';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.accounting_rule_duration;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.accounting_rule_duration;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.accounting_rule_duration;
END IF; /*  NEXT */
END IF;
/* END accounting_rule_duration*/
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
END If;
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
END IF;
END IF; /*  NEXT */

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
END IF;
END IF; /*  NEXT */

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
 null;
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
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute10;
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
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute11;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute11;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.attribute11;
END IF;
END IF; /*  NEXT */

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
END IF; /*  NEXT */
END IF;

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
/* START attribute16*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute16,
       p_prior_rec.attribute16) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute16';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute16;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute16;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute16,
       p_next_rec.attribute16) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute16;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute16';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute16;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute16;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.attribute16;
END IF; /*  NEXT */
END IF;

/* END attribute16*/
/****************************/

/****************************/
/* START attribute17*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute17,
       p_prior_rec.attribute17) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute17';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute17;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute17;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute17,
       p_next_rec.attribute17) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute17;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute17';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute17;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute17;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.attribute17;
END IF; /*  NEXT */
END IF;

/* END attribute17*/
/****************************/

/****************************/
/* START attribute18*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute18,
       p_prior_rec.attribute18) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute18';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute18;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute18;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute18,
       p_next_rec.attribute18) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute18;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute18';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute18;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute18;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.attribute18;
END IF; /*  NEXT */

END IF;
/* END attribute18*/
/****************************/

/****************************/
/* START attribute19*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute19,
       p_prior_rec.attribute19) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute19';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute19;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute19;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute19,
       p_next_rec.attribute19) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute19;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute19';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute19;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute19;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.attribute19;
END IF; /*  NEXT */
END IF;

/* END attribute19*/
/****************************/

/****************************/
/* START attribute20*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute20,
       p_prior_rec.attribute20) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute20';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute20;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute20;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute20,
       p_next_rec.attribute20) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute20;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute20';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute20;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute20;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.attribute20;
END IF; /*  NEXT */
END IF;
/* END attribute20*/
/****************************/

/****************************/
/* START blanket_number*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.blanket_number,
       p_prior_rec.blanket_number) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'blanket_number';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.blanket_number;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.blanket_number;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.blanket_number,
       p_next_rec.blanket_number) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.blanket_number;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'blanket_number';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.blanket_number;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.blanket_number;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.blanket_number;
END IF; /*  NEXT */
END IF;
/* END blanket_number*/
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
END IF;
END IF; /*  NEXT */

/* END context*/
/****************************/

/****************************/
/* START conversion_rate*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.conversion_rate,
       p_prior_rec.conversion_rate) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'conversion_rate_dsp';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.conversion_rate;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.conversion_rate;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.conversion_rate,
       p_next_rec.conversion_rate) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.conversion_rate;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'conversion_rate_dsp';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.conversion_rate;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.conversion_rate;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.conversion_rate;
END IF; /*  NEXT */
END IF;

/* END conversion_rate*/
/****************************/

/****************************/
/* START conversion_rate_date*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.conversion_rate_date,
       p_prior_rec.conversion_rate_date) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'conversion_rate_date';
    --bug 4747202
   x_header_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.conversion_rate_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.conversion_rate_date,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.conversion_rate_date,
       p_next_rec.conversion_rate_date) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.conversion_rate_date,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'conversion_rate_date';
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.conversion_rate_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.conversion_rate_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.conversion_rate_date,'DD-MON-YYYY HH24:MI:SS');
    --bug 4747202
END IF; /*  NEXT */
END IF;

/* END conversion_rate_date*/
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
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Conversion_type(p_curr_rec.conversion_type_code);
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
/* START customer_preference_set_code*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.customer_preference_set_code,
       p_prior_rec.customer_preference_set_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'customer_preference_set_code';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.customer_preference_set_code;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.customer_preference_set_code;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.customer_preference_set_code,
       p_next_rec.customer_preference_set_code) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.customer_preference_set_code;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'customer_preference_set_code';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.customer_preference_set_code;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.customer_preference_set_code;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.customer_preference_set_code;
END IF; /*  NEXT */
END IF;

/* END customer_preference_set_code*/
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
/* START deliver_to_contact_id*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.deliver_to_contact_id,
       p_prior_rec.deliver_to_contact_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'deliver_to_contact';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.deliver_to_contact_id;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Deliver_To_Contact(p_curr_rec.deliver_to_contact_id);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.deliver_to_contact_id;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Deliver_To_Contact(p_prior_rec.deliver_to_contact_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.deliver_to_contact_id,
       p_next_rec.deliver_to_contact_id) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Deliver_To_Contact(p_curr_rec.deliver_to_contact_id);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'deliver_to_contact';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.deliver_to_contact_id;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Deliver_To_Contact(p_prior_rec.deliver_to_contact_id);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.deliver_to_contact_id;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Deliver_To_Contact(p_curr_rec.deliver_to_contact_id);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.deliver_to_contact_id;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Deliver_To_Contact(p_next_rec.deliver_to_contact_id);
END IF; /*  NEXT */
END IF;

/* END deliver_to_contact_id*/
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
   x_header_changed_attr_tbl(ind).attribute_name  := 'deliver_to_location';
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
    DECODE(x_deliver_to_country, NULL,x_deliver_to_country)
        into x_prior_deliver_to_address from dual;

   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.deliver_to_org_id;
   x_header_changed_attr_tbl(ind).current_value     := x_prior_deliver_to_address;
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
    DECODE(x_deliver_to_country, NULL,x_deliver_to_country)
        into x_current_deliver_to_address from dual;
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.deliver_to_org_id;
   x_header_changed_attr_tbl(ind).prior_value     := x_current_deliver_to_address;
       end if;
END IF;
END IF; /*  PRIOR */
/****************************/

IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.deliver_to_org_id,
       p_next_rec.deliver_to_org_id) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value     := x_current_deliver_to_address;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'deliver_to_location';

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
/* START first_ack_code*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.first_ack_code,
       p_prior_rec.first_ack_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'first_ack_code';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.first_ack_code;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.first_ack_code,
       p_next_rec.first_ack_code) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.first_ack_code;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'first_ack_code';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.first_ack_code;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.first_ack_code;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.first_ack_code;
END IF; /*  NEXT */
END IF;
/* END first_ack_code*/
/****************************/

/****************************/
/* START first_ack_date*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.first_ack_date,
       p_prior_rec.first_ack_date) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'first_ack_date';
   x_header_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.first_ack_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.first_ack_date,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.first_ack_date,
       p_next_rec.first_ack_date) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.first_ack_date,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'first_ack_date';
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.first_ack_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.first_ack_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.first_ack_date,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  NEXT */

/* END first_ack_date*/
/****************************/

/****************************/
/* START expiration_date*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.expiration_date,
       p_prior_rec.expiration_date) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'expiration_date';
   x_header_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.expiration_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.expiration_date,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.expiration_date,
       p_next_rec.expiration_date) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.expiration_date,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'expiration_date';
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.expiration_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.expiration_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.expiration_date,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  NEXT */

/* END expiration_date*/
/****************************/

/****************************/
/* START earliest_schedule_limit*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.earliest_schedule_limit,
       p_prior_rec.earliest_schedule_limit) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'earliest_schedule_limit';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.earliest_schedule_limit;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.earliest_schedule_limit;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.earliest_schedule_limit,
       p_next_rec.earliest_schedule_limit) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.earliest_schedule_limit;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'earliest_schedule_limit';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.earliest_schedule_limit;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.earliest_schedule_limit;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.earliest_schedule_limit;
END IF; /*  NEXT */
END IF;

/* END earliest_schedule_limit*/
/****************************/

/****************************/
/* START fob_point_code*/
prior_exists := 'N';
If p_prior_version is not null THEN
IF OE_Globals.Equal(
       p_curr_rec.fob_point_code,
       p_prior_rec.fob_point_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'fob';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.fob_point_code;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Fob_Point(p_curr_rec.fob_point_code);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.fob_point_code;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Fob_Point(p_prior_rec.fob_point_code);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.fob_point_code,
       p_next_rec.fob_point_code) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Fob_Point(p_curr_rec.fob_point_code);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'fob';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.fob_point_code;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Fob_Point(p_prior_rec.fob_point_code);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.fob_point_code;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Fob_Point(p_curr_rec.fob_point_code);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.fob_point_code;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Fob_Point(p_next_rec.fob_point_code);
END IF; /*  NEXT */
END IF;

/* END Fob_Point_code*/
/****************************/

/****************************/
/* START freight_carrier_code*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.freight_carrier_code,
       p_prior_rec.freight_carrier_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'freight_carrier';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.freight_carrier_code;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Freight_Carrier(p_curr_rec.freight_carrier_code,p_curr_rec.ship_from_org_id);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.freight_carrier_code;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Freight_Carrier(p_prior_rec.freight_carrier_code,p_prior_rec.ship_from_org_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.freight_carrier_code,
       p_next_rec.freight_carrier_code) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Freight_Carrier(p_curr_rec.freight_carrier_code,p_curr_rec.ship_from_org_id);
    END IF;
 null;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'freight_carrier';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.freight_carrier_code;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Freight_Carrier(p_prior_rec.freight_carrier_code,p_prior_rec.ship_from_org_id);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.freight_carrier_code;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Freight_Carrier(p_curr_rec.freight_carrier_code,p_curr_rec.ship_from_org_id);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.freight_carrier_code;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Freight_Carrier(p_next_rec.freight_carrier_code,p_next_rec.ship_from_org_id);
END IF;
END IF; /*  NEXT */

/* END freight_carrier_code*/
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
/* START global_attribute1*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute1,
       p_prior_rec.global_attribute1) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'global_attribute1';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute1;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute1;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute1,
       p_next_rec.global_attribute1) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute1;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'global_attribute1';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute1;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute1;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute1;
END IF;
END IF; /*  NEXT */

/* END global_attribute1*/
/****************************/

/****************************/
/* START global_attribute2*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute2,
       p_prior_rec.global_attribute2) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'global_attribute2';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute2;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute2;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute2,
       p_next_rec.global_attribute2) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute2;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'global_attribute2';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute2;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute2;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute2;
END IF; /*  NEXT */
END IF;
/* END global_attribute2*/
/****************************/
/****************************/
/* START global_attribute3*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute3,
       p_prior_rec.global_attribute3) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'global_attribute3';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute3;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute3;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute3,
       p_next_rec.global_attribute3) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute3;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'global_attribute3';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute3;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute3;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute3;
END IF; /*  NEXT */
END IF;
/* END global_attribute3*/
/****************************/

/****************************/
/* START global_attribute4*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute4,
       p_prior_rec.global_attribute4) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'global_attribute4';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute4;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute4;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute4,
       p_next_rec.global_attribute4) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute4;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'global_attribute4';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute4;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute4;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute4;
END IF; /*  NEXT */
END IF;
/* END global_attribute4*/
/****************************/
/****************************/
/* START global_attribute5*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute5,
       p_prior_rec.global_attribute5) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'global_attribute5';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute5;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute5;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute5,
       p_next_rec.global_attribute5) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute5;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'global_attribute5';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute5;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute5;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute5;
END IF; /*  NEXT */
END IF;
/* END global_attribute5*/
/****************************/

/****************************/
/* START global_attribute6*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute6,
       p_prior_rec.global_attribute6) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'global_attribute6';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute6;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute6;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute6,
       p_next_rec.global_attribute6) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute6;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'global_attribute6';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute6;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute6;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute6;
END IF; /*  NEXT */
END IF;

/* END global_attribute6*/
/****************************/
/****************************/
/* START global_attribute7*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute7,
       p_prior_rec.global_attribute7) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'global_attribute7';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute7;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute7;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute7,
       p_next_rec.global_attribute7) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute7;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute7;
   x_header_changed_attr_tbl(ind).attribute_name := 'global_attribute7';
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute7;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute7;
END IF; /*  NEXT */
END IF;

/* END global_attribute7*/
/****************************/

/****************************/
/* START global_attribute8*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute8,
       p_prior_rec.global_attribute8) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'global_attribute8';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute8;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute8;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute8,
       p_next_rec.global_attribute8) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute8;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'global_attribute8';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute8;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute8;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute8;
END IF; /*  NEXT */
END IF;

/* END global_attribute8*/
/****************************/
/****************************/
/* START global_attribute9*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute9,
       p_prior_rec.global_attribute9) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'global_attribute9';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute9;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute9;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute9,
       p_next_rec.global_attribute9) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute9;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'global_attribute9';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute9;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute9;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute9;
END IF; /*  NEXT */
END IF;

/* END global_attribute9*/
/****************************/

/****************************/
/* START global_attribute10*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute10,
       p_prior_rec.global_attribute10) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'global_attribute10';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute10;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute10;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute10,
       p_next_rec.global_attribute10) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute10;
    END IF;
 null;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'global_attribute10';
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute10;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute10;
END IF; /*  NEXT */
END IF;

/* END global_attribute10*/
/****************************/

/****************************/
/* START global_attribute11*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute11,
       p_prior_rec.global_attribute11) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'global_attribute11';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute11;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute11;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute11,
       p_next_rec.global_attribute11) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute11;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'global_attribute11';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute10;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute11;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute11;
END IF; /*  NEXT */
END IF;

/* END global_attribute11*/
/****************************/

/****************************/
/* START global_attribute12*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute12,
       p_prior_rec.global_attribute12) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'global_attribute12';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute12;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute12;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute12,
       p_next_rec.global_attribute12) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute12;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'global_attribute12';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute12;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute12;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute12;
END IF; /*  NEXT */
END IF;

/* END global_attribute12*/
/****************************/

/****************************/
/* START global_attribute13*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute13,
       p_prior_rec.global_attribute13) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'global_attribute13';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute13;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute13;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute13,
       p_next_rec.global_attribute13) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute13;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'global_attribute13';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute13;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute13;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute13;
END IF; /*  NEXT */
END IF;

/* END global_attribute13*/
/****************************/

/****************************/
/* START global_attribute14*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute14,
       p_prior_rec.global_attribute14) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'global_attribute14';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute14;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute14;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute14,
       p_next_rec.global_attribute14) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute14;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'global_attribute14';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute14;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute14;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute14;
END IF; /*  NEXT */
END IF;

/* END global_attribute14*/
/****************************/

/****************************/
/* START global_attribute15*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute15,
       p_prior_rec.global_attribute15) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'global_attribute15';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute15;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute15;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute15,
       p_next_rec.global_attribute15) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute15;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'global_attribute15';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute15;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute15;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute15;
END IF; /*  NEXT */
END IF;

/* END global_attribute15*/
/****************************/
/****************************/
/* START global_attribute16*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute16,
       p_prior_rec.global_attribute16) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.cust_po_number;
    END IF;
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'global_attribute16';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute16;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute16;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute16,
       p_next_rec.global_attribute16) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute16;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'global_attribute16';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute16;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute16;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute16;
END IF; /*  NEXT */
END IF;

/* END global_attribute16*/
/****************************/

/****************************/
/* START global_attribute17*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute17,
       p_prior_rec.global_attribute17) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'global_attribute17';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute17;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute17;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute17,
       p_next_rec.global_attribute17) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute17;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'global_attribute17';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute17;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute17;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute17;
END IF; /*  NEXT */
END IF;

/* END global_attribute17*/
/****************************/

/****************************/
/* START global_attribute18*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute18,
       p_prior_rec.global_attribute18) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'global_attribute18';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute18;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute18;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute18,
       p_next_rec.global_attribute18) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute18;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'global_attribute18';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute18;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute18;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute18;
END IF; /*  NEXT */
END IF;

/* END global_attribute18*/
/****************************/

/****************************/
/* START global_attribute19*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute19,
       p_prior_rec.global_attribute19) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'global_attribute19';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute19;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute19;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute19,
       p_next_rec.global_attribute19) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute19;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'global_attribute19';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute19;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute19;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute19;
END IF; /*  NEXT */
END IF;

/* END global_attribute19*/
/****************************/

/****************************/
/* START global_attribute20*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute20,
       p_prior_rec.global_attribute20) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'global_attribute20';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute20;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute20;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute20,
       p_next_rec.global_attribute20) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute20;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'global_attribute20';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute20;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute20;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute20;
END IF; /*  NEXT */
END IF;

/* END global_attribute20*/
/****************************/

/****************************/
/* START global_attribute_category*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute_category,
       p_prior_rec.global_attribute_category) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'global_attribute_category';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute_category;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute_category;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute_category,
       p_next_rec.global_attribute_category) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute_category;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'global_attribute_category';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute_category;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute_category;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute_category;
END IF; /*  NEXT */
END IF;

/* END global_attribute_category*/
/****************************/

/****************************/
/* START INVOICE_TO_CONTACT_ID*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.invoice_to_contact_id,
       p_prior_rec.invoice_to_contact_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'invoice_to_contact';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.invoice_to_contact_id;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.invoice_To_Contact(p_curr_rec.invoice_to_contact_id);
   x_header_changed_attr_tbl(ind).prior_id      := p_prior_rec.invoice_to_contact_id;
   x_header_changed_attr_tbl(ind).prior_value   := OE_ID_TO_VALUE.invoice_To_Contact(p_prior_rec.invoice_to_contact_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.invoice_to_contact_id,
       p_next_rec.invoice_to_contact_id) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.invoice_To_Contact(p_curr_rec.invoice_to_contact_id);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name   := 'invoice_to_contact';
   x_header_changed_attr_tbl(ind).prior_id      := p_prior_rec.invoice_to_contact_id;
   x_header_changed_attr_tbl(ind).prior_value   := OE_ID_TO_VALUE.invoice_To_Contact(p_prior_rec.invoice_to_contact_id);
   x_header_changed_attr_tbl(ind).current_id   := p_curr_rec.invoice_to_contact_id;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.invoice_To_Contact(p_curr_rec.invoice_to_contact_id);
   x_header_changed_attr_tbl(ind).next_id   := p_next_rec.invoice_to_contact_id;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.invoice_To_Contact(p_next_rec.invoice_to_contact_id);
END IF; /*  NEXT */
END IF;

/* END invoice_to_contact_id*/

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
   x_header_changed_attr_tbl(ind).attribute_name  := 'invoice_to_location';
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
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.invoice_to_org_id;
   x_header_changed_attr_tbl(ind).prior_value     := x_prior_invoice_to_address;
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
   x_header_changed_attr_tbl(ind).attribute_name := 'invoice_to_location';

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
END IF; /*  NEXT */
END IF;

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
/* START last_ack_code*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.last_ack_code,
       p_prior_rec.last_ack_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'last_ack_code';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.last_ack_code;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.last_ack_code;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.last_ack_code,
       p_next_rec.last_ack_code) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.last_ack_code;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'last_ack_code';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.last_ack_code;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.last_ack_code;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.last_ack_code;
END IF; /*  NEXT */
END IF;

/* END last_ack_code*/
/****************************/

/****************************/
/* START last_ack_date*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.last_ack_date,
       p_prior_rec.last_ack_date) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'last_ack_date';
   x_header_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.last_ack_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.last_ack_date,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.last_ack_date,
       p_next_rec.last_ack_date) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.last_ack_date,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'last_ack_date';
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.last_ack_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.last_ack_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.last_ack_date,'DD-MON-YYYY HH24:MI:SS');
END IF; /*  NEXT */
END IF;

/* END last_ack_date*/
/****************************/


/****************************/
/* START latest_schedule_limit*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.latest_schedule_limit,
       p_prior_rec.latest_schedule_limit) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'latest_schedule_limit';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.latest_schedule_limit;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.latest_schedule_limit;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.latest_schedule_limit,
       p_next_rec.latest_schedule_limit) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.latest_schedule_limit;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'latest_schedule_limit';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.latest_schedule_limit;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.latest_schedule_limit;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.latest_schedule_limit;
END IF; /*  NEXT */
END IF;

/* END latest_schedule_limit*/
/****************************/


/****************************/
/* START ordered_date*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.ordered_date,
       p_prior_rec.ordered_date) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'ordered_date';
   x_header_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.ordered_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.ordered_date,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.ordered_date,
       p_next_rec.ordered_date) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.ordered_date,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'ordered_date';
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.ordered_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.ordered_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.ordered_date,'DD-MON-YYYY HH24:MI:SS');
END IF; /*  NEXT */
END IF;

/* END ordered_date*/
/****************************/

/****************************/
/* START order_date_type_code*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.order_date_type_code,
       p_prior_rec.order_date_type_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'order_date_type';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.order_date_type_code;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Order_date_Type(p_curr_rec.order_date_type_code);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.order_date_type_code;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Order_date_Type(p_prior_rec.order_date_type_code);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.order_date_type_code,
       p_next_rec.order_date_type_code) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Order_date_Type(p_curr_rec.order_date_type_code);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'order_date_type';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.order_date_type_code;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Order_date_Type(p_prior_rec.order_date_type_code);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.order_date_type_code;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Order_date_Type(p_curr_rec.order_date_type_code);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.order_date_type_code;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Order_date_Type(p_next_rec.order_date_type_code);
END IF; /*  NEXT */
END IF;

/* END order_date_type_code*/

/****************************/

/****************************/
/* START order_source_id*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.order_source_id,
       p_prior_rec.order_source_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'order_source_dsp';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.order_source_id;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.order_source(p_curr_rec.order_source_id);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.order_source_id;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.order_source(p_prior_rec.order_source_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.order_source_id,
       p_next_rec.order_source_id) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.order_source(p_curr_rec.order_source_id);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'order_source_dsp';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.order_source_id;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.order_source(p_prior_rec.order_source_id);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.order_source_id;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.order_source(p_curr_rec.order_source_id);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.order_source_id;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.order_source(p_next_rec.order_source_id);
END IF; /*  NEXT */
END IF;

/* END order_source_id*/
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
END IF; /*  NEXT */
END IF;

/* END order_type_id*/
/****************************/


/****************************/
/* START PARTIAL_SHIPMENTS_ALLOWED*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.PARTIAL_SHIPMENTS_ALLOWED,
       p_prior_rec.PARTIAL_SHIPMENTS_ALLOWED) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'PARTIAL_SHIPMENTS_ALLOWED';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.PARTIAL_SHIPMENTS_ALLOWED;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.PARTIAL_SHIPMENTS_ALLOWED;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.PARTIAL_SHIPMENTS_ALLOWED,
       p_next_rec.PARTIAL_SHIPMENTS_ALLOWED) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.PARTIAL_SHIPMENTS_ALLOWED;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'PARTIAL_SHIPMENTS_ALLOWED';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.PARTIAL_SHIPMENTS_ALLOWED;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.PARTIAL_SHIPMENTS_ALLOWED;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.PARTIAL_SHIPMENTS_ALLOWED;
END IF; /*  NEXT */
END IF;

/* END PARTIAL_SHIPMENTS_ALLOWED*/
/****************************/

/****************************/
/* START payment_term_id*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.payment_term_id,
       p_prior_rec.payment_term_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'TERMS';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.payment_term_id;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.payment_term(p_curr_rec.payment_term_id);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.payment_term_id;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.payment_term(p_prior_rec.payment_term_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.payment_term_id,
       p_next_rec.payment_term_id) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.payment_term(p_curr_rec.payment_term_id);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'TERMS';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.payment_term_id;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.payment_term(p_prior_rec.payment_term_id);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.payment_term_id;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.payment_term(p_curr_rec.payment_term_id);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.payment_term_id;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.payment_term(p_next_rec.payment_term_id);
END IF; /*  NEXT */
END IF;

/* END payment_term_id*/
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
   x_header_changed_attr_tbl(ind).attribute_name  := 'PRICE_LIST';
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
   x_header_changed_attr_tbl(ind).attribute_name := 'PRICE_LIST';
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
/* START PRICING_DATE*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.PRICING_DATE,
       p_prior_rec.PRICING_DATE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'PRICING_DATE';
   x_header_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.PRICING_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.PRICING_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.PRICING_DATE,
       p_next_rec.PRICING_DATE) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.PRICING_DATE,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'PRICING_DATE';
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.PRICING_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.PRICING_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.PRICING_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF; /*  NEXT */
END IF;

/* END PRICING_DATE*/
/****************************/
/****************************/
/* START REQUEST_DATE*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.REQUEST_DATE,
       p_prior_rec.REQUEST_DATE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'REQUEST_DATE';
   x_header_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.REQUEST_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.REQUEST_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.REQUEST_DATE,
       p_next_rec.REQUEST_DATE) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.REQUEST_DATE,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'REQUEST_DATE';
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.REQUEST_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.REQUEST_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.REQUEST_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF; /*  NEXT */
END IF;

/* END REQUEST_DATE*/
/****************************/

/****************************/
/* START RETURN_REASON_CODE*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.RETURN_REASON_CODE,
       p_prior_rec.RETURN_REASON_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'RETURN_REASON';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.RETURN_REASON_CODE;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.RETURN_REASON(p_curr_rec.RETURN_REASON_CODE);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.RETURN_REASON_CODE;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.RETURN_REASON(p_prior_rec.RETURN_REASON_CODE);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.RETURN_REASON_CODE,
       p_next_rec.RETURN_REASON_CODE) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.RETURN_REASON(p_curr_rec.RETURN_REASON_CODE);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'RETURN_REASON';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.RETURN_REASON_CODE;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.RETURN_REASON(p_prior_rec.RETURN_REASON_CODE);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.RETURN_REASON_CODE;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.RETURN_REASON(p_curr_rec.RETURN_REASON_CODE);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.RETURN_REASON_CODE;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.RETURN_REASON(p_next_rec.RETURN_REASON_CODE);
END IF; /*  NEXT */
END IF;

/* END RETURN_REASON_CODE*/
/****************************/

-- Bug 5108195 START
/****************************/
/* START SALES_DOCUMENT_NAME*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.SALES_DOCUMENT_NAME,
       p_prior_rec.SALES_DOCUMENT_NAME) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'SALES_DOCUMENT_NAME';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.SALES_DOCUMENT_NAME;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.SALES_DOCUMENT_NAME;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.SALES_DOCUMENT_NAME,
       p_next_rec.SALES_DOCUMENT_NAME) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.SALES_DOCUMENT_NAME;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'SALES_DOCUMENT_NAME';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.SALES_DOCUMENT_NAME;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.SALES_DOCUMENT_NAME;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.SALES_DOCUMENT_NAME;
END IF; /*  NEXT */
END IF;
/* END SALES_DOCUMENT_NAME*/
/****************************/
-- Bug 5108195 END

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
/* START SALES_CHANNEL_CODe*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.SALES_CHANNEL_CODe,
       p_prior_rec.SALES_CHANNEL_CODe) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'SALES_CHANNEL';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.SALES_CHANNEL_CODe;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.SALES_CHANNEL(p_curr_rec.SALES_CHANNEL_CODe);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.SALES_CHANNEL_CODe;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.SALES_CHANNEL(p_prior_rec.SALES_CHANNEL_CODe);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.SALES_CHANNEL_CODe,
       p_next_rec.SALES_CHANNEL_CODe) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.SALES_CHANNEL(p_curr_rec.SALES_CHANNEL_CODe);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'SALES_CHANNEL';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.SALES_CHANNEL_CODe;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.SALES_CHANNEL(p_prior_rec.SALES_CHANNEL_CODe);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.SALES_CHANNEL_CODe;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.SALES_CHANNEL(p_curr_rec.SALES_CHANNEL_CODe);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.SALES_CHANNEL_CODe;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.SALES_CHANNEL(p_next_rec.SALES_CHANNEL_CODe);
END IF; /*  NEXT */
END IF;
/* END SALES_CHANNEL_CODe*/
/****************************/
/****************************/
/* START SHIPMENT_PRIORITY_CODE*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.SHIPMENT_PRIORITY_CODE,
       p_prior_rec.SHIPMENT_PRIORITY_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'SHIPMENT_PRIORITY';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.SHIPMENT_PRIORITY_CODE;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.SHIPMENT_PRIORITY(p_curr_rec.SHIPMENT_PRIORITY_CODE);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.SHIPMENT_PRIORITY_CODE;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.SHIPMENT_PRIORITY(p_prior_rec.SHIPMENT_PRIORITY_CODE);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.SHIPMENT_PRIORITY_CODE,
       p_next_rec.SHIPMENT_PRIORITY_CODE) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.SHIPMENT_PRIORITY(p_curr_rec.SHIPMENT_PRIORITY_CODE);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'SHIPMENT_PRIORITY';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.SHIPMENT_PRIORITY_CODE;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.SHIPMENT_PRIORITY(p_prior_rec.SHIPMENT_PRIORITY_CODE);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.SHIPMENT_PRIORITY_CODE;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.SHIPMENT_PRIORITY(p_curr_rec.SHIPMENT_PRIORITY_CODE);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.SHIPMENT_PRIORITY_CODE;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.SHIPMENT_PRIORITY(p_next_rec.SHIPMENT_PRIORITY_CODE);
END IF; /*  NEXT */
END IF;
/* END SHIPMENT_PRIORITY_CODE*/
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
   x_header_changed_attr_tbl(ind).attribute_name  := 'ship_from';
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
   x_header_changed_attr_tbl(ind).current_value     := x_current_ship_from_org;
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.ship_from_org_id;
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
   x_header_changed_attr_tbl(ind).attribute_name := 'ship_from';

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
/* START SHIP_TOLERANCE_ABOVE*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.SHIP_TOLERANCE_ABOVE,
       p_prior_rec.SHIP_TOLERANCE_ABOVE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'SHIP_TOLERANCE_ABOVE';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.SHIP_TOLERANCE_ABOVE;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.SHIP_TOLERANCE_ABOVE;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.SHIP_TOLERANCE_ABOVE,
       p_next_rec.SHIP_TOLERANCE_ABOVE) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.SHIP_TOLERANCE_ABOVE;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'SHIP_TOLERANCE_ABOVE';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.SHIP_TOLERANCE_ABOVE;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.SHIP_TOLERANCE_ABOVE;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.SHIP_TOLERANCE_ABOVE;
END IF;
END IF; /*  NEXT */

/* END SHIP_TOLERANCE_ABOVE*/
/****************************/
/****************************/
/* START SHIP_TOLERANCE_BELOW*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.SHIP_TOLERANCE_BELOW,
       p_prior_rec.SHIP_TOLERANCE_BELOW) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'SHIP_TOLERANCE_BELOW';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.SHIP_TOLERANCE_BELOW;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.SHIP_TOLERANCE_BELOW;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.SHIP_TOLERANCE_BELOW,
       p_next_rec.SHIP_TOLERANCE_BELOW) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.SHIP_TOLERANCE_BELOW;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'SHIP_TOLERANCE_BELOW';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.SHIP_TOLERANCE_BELOW;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.SHIP_TOLERANCE_BELOW;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.SHIP_TOLERANCE_BELOW;
END IF; /*  NEXT */
END IF;

/* END SHIP_TOLERANCE_BELOW*/
/****************************/

/****************************/
/* START ship_TO_CONTACT_ID*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.ship_to_contact_id,
       p_prior_rec.ship_to_contact_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'ship_to_contact';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.ship_to_contact_id;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.ship_To_Contact(p_curr_rec.ship_to_contact_id);
   x_header_changed_attr_tbl(ind).prior_id      := p_prior_rec.ship_to_contact_id;
   x_header_changed_attr_tbl(ind).prior_value   := OE_ID_TO_VALUE.ship_To_Contact(p_prior_rec.ship_to_contact_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.ship_to_contact_id,
       p_next_rec.ship_to_contact_id) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.ship_To_Contact(p_curr_rec.ship_to_contact_id);
    END IF;
 null;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name   := 'ship_to_contact';
   x_header_changed_attr_tbl(ind).prior_id      := p_prior_rec.ship_to_contact_id;
   x_header_changed_attr_tbl(ind).prior_value   := OE_ID_TO_VALUE.ship_To_Contact(p_prior_rec.ship_to_contact_id);
   x_header_changed_attr_tbl(ind).current_id   := p_curr_rec.ship_to_contact_id;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.ship_To_Contact(p_curr_rec.ship_to_contact_id);
   x_header_changed_attr_tbl(ind).next_id   := p_next_rec.ship_to_contact_id;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.ship_To_Contact(p_next_rec.ship_to_contact_id);
END IF; /*  NEXT */
END IF;

/* END ship_to_contact_id*/
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
   x_header_changed_attr_tbl(ind).attribute_name  := 'ship_to_location';
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
   x_header_changed_attr_tbl(ind).attribute_name := 'ship_to_location';

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
/* START TAX_EXEMPT_FLAG*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.TAX_EXEMPT_FLAG,
       p_prior_rec.TAX_EXEMPT_FLAG) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'TAX_EXEMPT';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.TAX_EXEMPT_FLAG;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Tax_Exempt(p_curr_rec.TAX_EXEMPT_FLAG);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.TAX_EXEMPT_FLAG;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Tax_Exempt(p_prior_rec.TAX_EXEMPT_FLAG);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.TAX_EXEMPT_FLAG,
       p_next_rec.TAX_EXEMPT_FLAG) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Tax_Exempt(p_curr_rec.TAX_EXEMPT_FLAG);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'TAX_EXEMPT';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.TAX_EXEMPT_FLAG;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Tax_Exempt(p_prior_rec.TAX_EXEMPT_FLAG);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.TAX_EXEMPT_FLAG;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Tax_Exempt(p_curr_rec.TAX_EXEMPT_FLAG);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.TAX_EXEMPT_FLAG;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Tax_Exempt(p_next_rec.TAX_EXEMPT_FLAG);
END IF; /*  NEXT */
END IF;

/* END TAX_EXEMPT_FLAG*/
/****************************/

/****************************/
/* START TAX_EXEMPT_NUMBER*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.TAX_EXEMPT_NUMBER,
       p_prior_rec.TAX_EXEMPT_NUMBER) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'TAX_EXEMPT_NUMBER';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.TAX_EXEMPT_NUMBER;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.TAX_EXEMPT_NUMBER;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.TAX_EXEMPT_NUMBER,
       p_next_rec.TAX_EXEMPT_NUMBER) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.TAX_EXEMPT_NUMBER;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'TAX_EXEMPT_NUMBER';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.TAX_EXEMPT_NUMBER;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.TAX_EXEMPT_NUMBER;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.TAX_EXEMPT_NUMBER;
END IF; /*  NEXT */
END IF;

/* END TAX_EXEMPT_NUMBER*/
/****************************/

/****************************/
/* START TAX_EXEMPT_REASON_CODE*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.TAX_EXEMPT_REASON_CODE,
       p_prior_rec.TAX_EXEMPT_REASON_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'TAX_EXEMPT_REASON';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.TAX_EXEMPT_REASON_CODE;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Tax_Exempt_Reason(p_curr_rec.TAX_EXEMPT_REASON_CODE);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.TAX_EXEMPT_REASON_CODE;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Tax_Exempt_Reason(p_prior_rec.TAX_EXEMPT_REASON_CODE);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.TAX_EXEMPT_REASON_CODE,
       p_next_rec.TAX_EXEMPT_REASON_CODE) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Tax_Exempt_Reason(p_curr_rec.TAX_EXEMPT_REASON_CODE);
    END IF;
 null;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'TAX_EXEMPT_REASON';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.TAX_EXEMPT_REASON_CODE;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Tax_Exempt_Reason(p_prior_rec.TAX_EXEMPT_REASON_CODE);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.TAX_EXEMPT_REASON_CODE;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Tax_Exempt_Reason(p_curr_rec.TAX_EXEMPT_REASON_CODE);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.TAX_EXEMPT_REASON_CODE;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Tax_Exempt_Reason(p_next_rec.TAX_EXEMPT_REASON_CODE);
END IF; /*  NEXT */
END IF;

/* END TAX_EXEMPT_REASON_CODE*/
/****************************/
/****************************/
/* START TAX_POINT_CODE*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.TAX_POINT_CODE,
       p_prior_rec.TAX_POINT_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'TAX_POINT_CODE';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.TAX_POINT_CODE;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Tax_Point(p_curr_rec.TAX_POINT_CODE);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.TAX_POINT_CODE;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Tax_Point(p_prior_rec.TAX_POINT_CODE);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.TAX_POINT_CODE,
       p_next_rec.TAX_POINT_CODE) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Tax_Point(p_curr_rec.TAX_POINT_CODE);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'TAX_POINT_CODE';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.TAX_POINT_CODE;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Tax_Point(p_prior_rec.TAX_POINT_CODE);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.TAX_POINT_CODE;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Tax_Point(p_curr_rec.TAX_POINT_CODE);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.TAX_POINT_CODE;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Tax_Point(p_next_rec.TAX_POINT_CODE);
END IF; /*  NEXT */
END IF;

/* END TAX_POINT_CODE*/
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
/* START PAYMENT_TYPE_CODE*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.PAYMENT_TYPE_CODE,
       p_prior_rec.PAYMENT_TYPE_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'PAYMENT_TYPE';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.PAYMENT_TYPE_CODE;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.PAYMENT_TYPE(p_curr_rec.PAYMENT_TYPE_CODE);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.PAYMENT_TYPE_CODE;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.PAYMENT_TYPE(p_prior_rec.PAYMENT_TYPE_CODE);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.PAYMENT_TYPE_CODE,
       p_next_rec.PAYMENT_TYPE_CODE) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := OE_ID_TO_VALUE.PAYMENT_TYPE(p_curr_rec.PAYMENT_TYPE_CODE);
    END IF;
 null;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'PAYMENT_TYPE';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.PAYMENT_TYPE_CODE;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.PAYMENT_TYPE(p_prior_rec.PAYMENT_TYPE_CODE);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.PAYMENT_TYPE_CODE;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.PAYMENT_TYPE(p_curr_rec.PAYMENT_TYPE_CODE);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.PAYMENT_TYPE_CODE;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.PAYMENT_TYPE(p_next_rec.PAYMENT_TYPE_CODE);
END IF; /*  NEXT */
END IF;

/* END PAYMENT_TYPE_CODE*/
/****************************/
/****************************/
/* START PAYMENT_AMOUNT*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.PAYMENT_AMOUNT,
       p_prior_rec.PAYMENT_AMOUNT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'PAYMENT_AMOUNT';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.PAYMENT_AMOUNT;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.PAYMENT_AMOUNT;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.PAYMENT_AMOUNT,
       p_next_rec.PAYMENT_AMOUNT) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.PAYMENT_AMOUNT;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'PAYMENT_AMOUNT';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.PAYMENT_AMOUNT;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.PAYMENT_AMOUNT;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.PAYMENT_AMOUNT;
END IF; /*  NEXT */
END IF;

/* END PAYMENT_AMOUNT*/
/****************************/

/****************************/
-- comment out the following credit card related code for R12
/***
--  START credit_card_code
prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.credit_card_code,
       p_prior_rec.credit_card_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'credit_card';
   x_header_changed_attr_tbl(ind).current_id      := p_curr_rec.credit_card_code;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.credit_card(p_curr_rec.credit_card_code);
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.credit_card_code;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.credit_card(p_prior_rec.credit_card_code);
END IF;
END IF;  -- PRIOR

IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.credit_card_code,
       p_next_rec.credit_card_code) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.credit_card(p_curr_rec.credit_card_code);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'credit_card';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.credit_card_code;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.credit_card(p_prior_rec.credit_card_code);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.credit_card_code;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.credit_card(p_curr_rec.credit_card_code);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.credit_card_code;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.credit_card(p_next_rec.credit_card_code);
END IF; --  NEXT
END IF;

-- END credit_card_code
---------------------------------------------
-- START credit_card_holder_name

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.credit_card_holder_name,
       p_prior_rec.credit_card_holder_name) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'credit_card_holder_name';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.credit_card_holder_name;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.credit_card_holder_name;
END IF;
END IF;
--   PRIOR

IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.credit_card_holder_name,
       p_next_rec.credit_card_holder_name) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.credit_card_holder_name;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'credit_card_holder_name';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.credit_card_holder_name;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.credit_card_holder_name;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.credit_card_holder_name;
END IF;   -- NEXT
END IF;

--  END credit_card_holder_name

-------------------------------------------
-- START credit_card_expiration_date

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.credit_card_expiration_date,
       p_prior_rec.credit_card_expiration_date) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'credit_card_expiration_date';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.credit_card_expiration_date;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.credit_card_expiration_date;
END IF;
END IF;  -- PRIOR

IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.credit_card_expiration_date,
       p_next_rec.credit_card_expiration_date) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.credit_card_expiration_date;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'credit_card_expiration_date';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.credit_card_expiration_date;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.credit_card_expiration_date;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.credit_card_expiration_date;
END IF;   --  NEXT
END IF;

--  END credit_card_expiration_date

--  START credit_card_approval_date
prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.credit_card_approval_date,
       p_prior_rec.credit_card_approval_date) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'credit_card_approval_date';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.credit_card_approval_date;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.credit_card_approval_date;
END IF;
END IF;    -- PRIOR

-----------------------------------------------
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.credit_card_approval_date,
       p_next_rec.credit_card_approval_date) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.credit_card_approval_date;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'credit_card_approval_date';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.credit_card_approval_date;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.credit_card_approval_date;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.credit_card_approval_date;
END IF;
END IF;
--  END credit_card_approval_date

-----------------------------------------------
--  START credit_card_approval_code

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.credit_card_approval_code,
       p_prior_rec.credit_card_approval_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'credit_card_approval_code_dsp';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.credit_card_approval_code;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.credit_card_approval_code;
END IF;
END IF;  -- PRIOR
----------------------------------
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.credit_card_approval_code,
       p_next_rec.credit_card_approval_code) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.credit_card_approval_code;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'credit_card_approval_code_dsp';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.credit_card_approval_code;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.credit_card_approval_code;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.credit_card_approval_code;
END IF;  --  NEXT
END IF;

--  END credit_card_approval_code
***/
-- end of commented out code for credit card.

-- start of R12 CC encryption related changes.
/****************************/
/* START credit_card_code*/
prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN

  -- initialze the value
  l_is_card_history1 := 'N';
  l_is_card_history2 := 'N';

  IF p_curr_rec.credit_card_number is null
    and p_curr_rec.credit_card_code is null
    -- and NOT (p_next_version = g_trans_version AND g_trans_version is not null) THEN
    THEN
    l_is_card_history1 := 'Y';
  END IF;

  IF p_prior_rec.credit_card_number is null
    and p_prior_rec.credit_card_code is null
   -- and NOT (p_next_version = g_trans_version AND g_trans_version is not null) THEN
    THEN
    l_is_card_history2 := 'Y';
  END IF;

  Card_Equal(
       p_curr_rec.cc_instrument_id,
       p_prior_rec.cc_instrument_id,
       'CREDIT_CARD_CODE',
       l_is_card_history1,
       l_is_card_history2,
       l_is_equal,
       l_curr_value,
       l_prior_value
       );

IF l_is_equal = 'Y' THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'credit_card';
   x_header_changed_attr_tbl(ind).current_id      := l_curr_value;
   x_header_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.credit_card(l_curr_value);
   x_header_changed_attr_tbl(ind).prior_id        := l_prior_value;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.credit_card(l_prior_value);
END IF;
END IF;  -- PRIOR

/****************************/
IF p_next_version IS NOT NULL THEN

  -- initialze the value
  l_is_card_history1 := 'N';
  l_is_card_history2 := 'N';

  IF p_curr_rec.credit_card_number is null
    and p_curr_rec.credit_card_code is null
    -- and NOT (p_next_version = g_trans_version AND g_trans_version is not null) THEN
    THEN
    l_is_card_history1 := 'Y';
  END IF;

  IF p_next_rec.credit_card_number is null
    and p_next_rec.credit_card_code is null
    THEN
    l_is_card_history2 := 'Y';
  END IF;

Card_Equal(
       p_curr_rec.cc_instrument_id,
       p_next_rec.cc_instrument_id,
       'CREDIT_CARD_CODE',
       l_is_card_history1,
       l_is_card_history2,
       l_is_equal,
       l_curr_value,
       l_next_value
       );

IF l_is_equal = 'Y' THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value   := l_curr_value;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'credit_card';
   x_header_changed_attr_tbl(ind).prior_id        := l_prior_value;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.credit_card(l_prior_value);
   x_header_changed_attr_tbl(ind).current_id     := l_curr_value;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.credit_card(l_curr_value);
   x_header_changed_attr_tbl(ind).next_id      := l_next_value;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.credit_card(l_next_value);
END IF;   /* NEXT */
END IF;

/* END credit_card_code */
/****************************/
/****************************/
/* START credit_card_holder_name */

-- initialze the value
l_is_card_history1 := 'N';
l_is_card_history2 := 'N';

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN

  IF p_curr_rec.credit_card_number is null
    and p_curr_rec.credit_card_code is null
    THEN
    l_is_card_history1 := 'Y';
  END IF;

  IF p_prior_rec.credit_card_number is null
    and p_prior_rec.credit_card_code is null
    THEN
    l_is_card_history2 := 'Y';
  END IF;

Card_Equal(
       p_curr_rec.cc_instrument_id,
       p_prior_rec.cc_instrument_id,
       'CREDIT_CARD_HOLDER_NAME',
       l_is_card_history1,
       l_is_card_history2,
       l_is_equal,
       l_curr_value,
       l_prior_value
       );

IF l_is_equal = 'Y' THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'credit_card_holder_name';
   x_header_changed_attr_tbl(ind).current_value      := l_curr_value;
   x_header_changed_attr_tbl(ind).prior_value        := l_prior_value;
END IF;
END IF;
/*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN

  -- initialze the value
  l_is_card_history1 := 'N';
  l_is_card_history2 := 'N';

  IF p_curr_rec.credit_card_number is null
    and p_curr_rec.credit_card_code is null
    -- and NOT (p_next_version = g_trans_version AND g_trans_version is not null) THEN
    THEN
    l_is_card_history1 := 'Y';
  END IF;

  IF p_next_rec.credit_card_number is null
    and p_next_rec.credit_card_code is null
    THEN
    l_is_card_history2 := 'Y';
  END IF;

Card_Equal(
       p_curr_rec.cc_instrument_id,
       p_next_rec.cc_instrument_id,
       'CREDIT_CARD_HOLDER_NAME',
       l_is_card_history1,
       l_is_card_history2,
       l_is_equal,
       l_curr_value,
       l_next_value
       );
IF l_is_equal = 'Y' THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := l_curr_value;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;

   x_header_changed_attr_tbl(ind).attribute_name := 'credit_card_holder_name';

   x_header_changed_attr_tbl(ind).prior_value        := l_prior_value;
   x_header_changed_attr_tbl(ind).current_value     := l_curr_value;
   x_header_changed_attr_tbl(ind).next_value      := l_next_value;
END IF;   -- NEXT
END IF;

/* END credit_card_holder_name*/
/****************************/

/****************************/
/* START credit_card_expiration_date*/

-- initialze the value
l_is_card_history1 := 'N';
l_is_card_history2 := 'N';
prior_exists := 'N';

IF p_prior_version IS NOT NULL THEN

  IF p_curr_rec.credit_card_number is null
    and p_curr_rec.credit_card_code is null THEN
    l_is_card_history1 := 'Y';
  END IF;

  IF p_prior_rec.credit_card_number is null
    and p_prior_rec.credit_card_code is null THEN
    l_is_card_history2 := 'Y';
  END IF;

Card_Equal(
       p_curr_rec.cc_instrument_id,
       p_prior_rec.cc_instrument_id,
       'CREDIT_CARD_EXPIRATION_DATE',
       l_is_card_history1,
       l_is_card_history2,
       l_is_equal,
       l_curr_value,
       l_prior_value
       );


IF l_is_equal = 'Y' THEN
 null;
ELSE
  -- PADSS Start
  begin
  select encrypted
  into l_encrypted
  from iby_creditcard
  where instrid=p_prior_rec.cc_instrument_id;
  exception
    when others then
      begin
        select encrypted
	into l_encrypted
	from iby_creditcard_h
        where card_history_change_id=p_prior_rec.cc_instrument_id;
      exception
       when others then
        null;
      end;
  end;

  begin
  select encrypted
  into l_encrypted1
  from iby_creditcard
  where instrid=p_curr_rec.cc_instrument_id;
  exception
   when others then
        --l_encrypted1:=null;
        begin
	 select encrypted
	 into l_encrypted1
	 from iby_creditcard_h
	 where card_history_change_id=p_curr_rec.cc_instrument_id;
	exception
	  when others then
	        null;
        end;
  end;

          --IF iby_cc_security_pub.encryption_enabled() THEN
          IF nvl(l_encrypted,'N')='A' or nvl(l_encrypted1,'N')='A'  THEN
            if l_curr_value is not null then
                l_curr_value:= 'xx/xx';
            end if;

            if l_prior_value is not null then
               l_prior_value:= 'xx/xx';
            end if;

          END IF;
 -- PADSS End
   ind := ind+1;
   prior_exists := 'Y';

   x_header_changed_attr_tbl(ind).attribute_name  := 'credit_card_expiration_date';
   x_header_changed_attr_tbl(ind).current_value      := l_curr_value;
   x_header_changed_attr_tbl(ind).prior_value        := l_prior_value;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN

  -- initialze the value
  l_is_card_history1 := 'N';
  l_is_card_history2 := 'N';

  IF p_curr_rec.credit_card_number is null
    and p_curr_rec.credit_card_code is null THEN

    l_is_card_history1 := 'Y';
  END IF;

  IF p_next_rec.credit_card_number is null
    and p_next_rec.credit_card_code is null THEN
    l_is_card_history2 := 'Y';
  END IF;

Card_Equal(
       p_curr_rec.cc_instrument_id,
       p_next_rec.cc_instrument_id,
       'CREDIT_CARD_EXPIRATION_DATE',
       l_is_card_history1,
       l_is_card_history2,
       l_is_equal,
       l_curr_value,
       l_next_value
       );

-- PADSS Start
  begin
  select encrypted
  into l_encrypted
  from iby_creditcard
  where instrid=p_next_rec.cc_instrument_id;
  exception
    when others then
      --l_encrypted:=null;
      begin
        select encrypted
	into l_encrypted
	from iby_creditcard_h
        where card_history_change_id=p_next_rec.cc_instrument_id;
      exception
       when others then
        null;
      end;
  end;

  begin
  select encrypted
  into l_encrypted1
  from iby_creditcard
  where instrid=p_curr_rec.cc_instrument_id;
  exception
   when others then
        --l_encrypted1:=null;
     begin
        select encrypted
	into l_encrypted1
	from iby_creditcard_h
        where card_history_change_id=p_curr_rec.cc_instrument_id;
      exception
       when others then
        null;
      end;
  end;
  --IF iby_cc_security_pub.encryption_enabled() THEN
  IF nvl(l_encrypted,'N')='A' or nvl(l_encrypted1,'N')='A'  THEN
   -- bug 8675691
    IF p_next_version=g_trans_version and g_trans_version<g_max_version and l_curr_value='-1' and l_next_value='-1'
    then
      l_is_equal:='N' ;
    END IF;
  END IF;
-- PADSS End
IF l_is_equal = 'Y' THEN
    IF prior_exists = 'Y' THEN
    -- PADSS Start
    --IF iby_cc_security_pub.encryption_enabled() THEN
    IF nvl(l_encrypted,'N')='A' or nvl(l_encrypted1,'N')='A'  THEN
            if l_curr_value is not null then
                l_curr_value:= 'xx/xx';
            end if;
     END IF;
     -- PADSS End
   x_header_changed_attr_tbl(ind).next_value      := l_curr_value;
    END IF;
ELSE
    -- PADSS Start
      --IF iby_cc_security_pub.encryption_enabled() THEN
      IF nvl(l_encrypted,'N')='A' or nvl(l_encrypted1,'N')='A'  THEN
        if l_curr_value is not null then
            l_curr_value:= 'xx/xx';
        end if;

        if l_next_value is not null then
           l_next_value:= 'xx/xx';
        end if;

        if l_prior_value is not null then
	    l_prior_value:= 'xx/xx';
        end if;

      END IF;
     -- PADSS End
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'credit_card_expiration_date';
   x_header_changed_attr_tbl(ind).prior_value        := l_prior_value;
   x_header_changed_attr_tbl(ind).current_value     := l_curr_value;
   x_header_changed_attr_tbl(ind).next_value      := l_next_value;
END IF; /*  NEXT */
END IF;

/* END credit_card_expiration_date*/
/****************************/
/****************************/
/* START credit_card_approval_date*/
/*
prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
Card_Equal(
       p_curr_rec.cc_instrument_id,
       p_prior_rec.cc_instrument_id,
       'CREDIT_CARD_APPROVAL_DATE',
       l_is_card_history1,
       l_is_card_history2,
       l_is_equal,
       l_curr_value,
       l_prior_value
       );
IF l_is_equal = 'Y' THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'credit_card_approval_date';
   x_header_changed_attr_tbl(ind).current_value      := l_curr_value;
   x_header_changed_attr_tbl(ind).prior_value        := l_prior_value;
END IF;
END IF;*/ /*  PRIOR */
/****************************/
/*
IF p_next_version IS NOT NULL THEN
Card_Equal(
       p_curr_rec.cc_instrument_id,
       p_next_rec.cc_instrument_id,
       'CREDIT_CARD_APPROVAL_DATE',
       l_is_card_history1,
       l_is_card_history2,
       l_is_equal,
       l_curr_value,
       l_next_value
       );
IF l_is_equal = 'Y' THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.credit_card_approval_date;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'credit_card_approval_date';
   x_header_changed_attr_tbl(ind).prior_value        := l_prior_value;
   x_header_changed_attr_tbl(ind).current_value     := l_curr_value;
   x_header_changed_attr_tbl(ind).next_value      := l_next_value;
END IF;
END IF;*/
/* END credit_card_approval_date*/

/****************************/
/****************************/
/* START credit_card_approval_code*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
Card_Equal(
       p_curr_rec.cc_instrument_id,
       p_prior_rec.cc_instrument_id,
       'CREDIT_CARD_APPROVAL_CODE',
       l_is_card_history1,
       l_is_card_history2,
       l_is_equal,
       l_curr_value,
       l_prior_value
       );
IF l_is_equal = 'Y' THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'credit_card_approval_code_dsp';
   x_header_changed_attr_tbl(ind).current_value      := l_curr_value;
   x_header_changed_attr_tbl(ind).prior_value        := l_prior_value;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
Card_Equal(
       p_curr_rec.cc_instrument_id,
       p_next_rec.cc_instrument_id,
       'CREDIT_CARD_APPROVAL_CODE',
       l_is_card_history1,
       l_is_card_history2,
       l_is_equal,
       l_curr_value,
       l_next_value
       );
IF l_is_equal = 'Y' THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := l_curr_value;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'credit_card_approval_code_dsp';
   x_header_changed_attr_tbl(ind).prior_value        := l_prior_value;
   x_header_changed_attr_tbl(ind).current_value     := l_curr_value;
   x_header_changed_attr_tbl(ind).next_value      := l_next_value;
END IF; /*  NEXT */
END IF;

/* END credit_card_approval_code*/

/****************************/

-------------------- END of Testing --------


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
   x_header_changed_attr_tbl(ind).attribute_name  := 'status';
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
   x_header_changed_attr_tbl(ind).next_value  := OE_ID_TO_VALUE.flow_status(p_curr_rec.flow_status_code);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'status';
   x_header_changed_attr_tbl(ind).prior_id        := p_prior_rec.flow_status_code;
   x_header_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.flow_status(p_prior_rec.flow_status_code);
   x_header_changed_attr_tbl(ind).current_id     := p_curr_rec.flow_status_code;
   x_header_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.flow_status(p_curr_rec.flow_status_code);
   x_header_changed_attr_tbl(ind).next_id      := p_next_rec.flow_status_code;
   x_header_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.flow_status(p_next_rec.flow_status_code);
END IF; /*  NEXT */
END IF;

/* END flow_status_code*/
/****************************/


/****************************/
/* START tp_attribute1*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute1,
       p_prior_rec.tp_attribute1) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute1';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute1;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute1;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute1,
       p_next_rec.tp_attribute1) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute1;
    END IF;
 null;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute1';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute1;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute1;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute1;
END IF; /*  NEXT */
END IF;

/* END tp_attribute1*/
/****************************/

/****************************/
/* START tp_attribute2*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute2,
       p_prior_rec.tp_attribute2) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute2';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute2;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute2;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute2,
       p_next_rec.tp_attribute2) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute2;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute2';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute2;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute2;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute2;
END IF; /*  NEXT */
END IF;

/* END tp_attribute2*/
/****************************/
/****************************/
/* START tp_attribute3*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute3,
       p_prior_rec.tp_attribute3) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute3';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute3;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute3;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute3,
       p_next_rec.tp_attribute3) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute3;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute3';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute3;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute3;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute3;
END IF; /*  NEXT */
END IF;

/* END tp_attribute3*/
/****************************/

/****************************/
/* START tp_attribute4*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute4,
       p_prior_rec.tp_attribute4) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute4';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute4;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute4;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute4,
       p_next_rec.tp_attribute4) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute4;
    END IF;
 null;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute4';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute4;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute4;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute4;
END IF; /*  NEXT */
END IF;

/* END tp_attribute4*/
/****************************/
/****************************/
/* START tp_attribute5*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute5,
       p_prior_rec.tp_attribute5) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute5';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute5;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute5;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute5,
       p_next_rec.tp_attribute5) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute5;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute5';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute5;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute5;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute5;
END IF; /*  NEXT */
END IF;

/* END tp_attribute5*/
/****************************/

/****************************/
/* START tp_attribute6*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute6,
       p_prior_rec.tp_attribute6) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute6';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute6;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute6;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute6,
       p_next_rec.tp_attribute6) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute6;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute6';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute6;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute6;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute6;
END IF; /*  NEXT */
END IF;

/* END tp_attribute6*/
/****************************/
/****************************/
/* START tp_attribute7*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute7,
       p_prior_rec.tp_attribute7) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute7';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute7;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute7;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute7,
       p_next_rec.tp_attribute7) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute7;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute7;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute7';
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute7;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute7;
END IF; /*  NEXT */
END IF;

/* END tp_attribute7*/
/****************************/

/****************************/
/* START tp_attribute8*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute8,
       p_prior_rec.tp_attribute8) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute8';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute8;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute8;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute8,
       p_next_rec.tp_attribute8) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute8;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute8';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute8;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute8;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute8;
END IF; /*  NEXT */
END IF;

/* END tp_attribute8*/
/****************************/
/****************************/
/* START tp_attribute9*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute9,
       p_prior_rec.tp_attribute9) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute9';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute9;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute9;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute9,
       p_next_rec.tp_attribute9) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute9;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute9';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute9;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute9;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute9;
END IF; /*  NEXT */
END IF;

/* END tp_attribute9*/
/****************************/

/****************************/
/* START tp_attribute10*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute10,
       p_prior_rec.tp_attribute10) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute10';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute10;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute10;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute10,
       p_next_rec.tp_attribute10) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute10;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute10';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute10;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute10;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute10;
END IF; /*  NEXT */
END IF;

/* END tp_attribute10*/
/****************************/

/****************************/
/* START tp_attribute11*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute11,
       p_prior_rec.tp_attribute11) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute11';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute11;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute11;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute11,
       p_next_rec.tp_attribute11) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute11;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute11';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute10;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute11;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute11;
END IF;
END IF; /*  NEXT */

/* END tp_attribute11*/
/****************************/

/****************************/
/* START tp_attribute12*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute12,
       p_prior_rec.tp_attribute12) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute12';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute12;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute12;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute12,
       p_next_rec.tp_attribute12) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute12;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute12';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute12;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute12;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute12;
END IF;
END IF; /*  NEXT */

/* END tp_attribute12*/
/****************************/

/****************************/
/* START tp_attribute13*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute13,
       p_prior_rec.tp_attribute13) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute13';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute13;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute13;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute13,
       p_next_rec.tp_attribute13) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute13;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute13';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute13;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute13;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute13;
END IF; /*  NEXT */
END IF;

/* END tp_attribute13*/
/****************************/

/****************************/
/* START tp_attribute14*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute14,
       p_prior_rec.tp_attribute14) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute14';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute14;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute14;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute14,
       p_next_rec.tp_attribute14) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute14;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute14';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute14;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute14;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute14;
END IF;
END IF; /*  NEXT */

/* END tp_attribute14*/
/****************************/

/****************************/
/* START tp_attribute15*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute15,
       p_prior_rec.tp_attribute15) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'attribute15';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute15;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute15;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute15,
       p_next_rec.tp_attribute15) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute15;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'attribute15';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute15;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute15;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute15;
END IF; /*  NEXT */
END IF;

/* END tp_attribute15*/
/****************************/

/****************************/
/* START tp_context*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_context,
       p_prior_rec.tp_context) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'tp_context';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_context;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_context;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_context,
       p_next_rec.tp_context) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_context;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'tp_context';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_context;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_context;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.tp_context;
END IF; /*  NEXT */
END IF;

/* END tp_context*/
/****************************/

/****************************/
/* START quote_date*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.quote_date,
       p_prior_rec.quote_date) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'quote_date';
   x_header_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.quote_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.quote_date,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.quote_date,
       p_next_rec.quote_date) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.quote_date,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'quote_date';
   x_header_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.quote_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.quote_date,'DD-MON-YYYY HH24:MI:SS');
   x_header_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.quote_date,'DD-MON-YYYY HH24:MI:SS');
END IF; /*  NEXT */
END IF;

/* END quote_date*/
/****************************/

/****************************/
/* START quote_number*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.quote_number,
       p_prior_rec.quote_number) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'quote_number';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.quote_number;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.quote_number;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.quote_number,
       p_next_rec.quote_number) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.quote_number;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'quote_number';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.quote_number;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.quote_number;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.quote_number;
END IF; /*  NEXT */
END IF;

/* END quote_number*/
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
   x_header_changed_attr_tbl(ind).attribute_name  := 'TRANSACTION_PHASE';
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
 null;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name  := 'TRANSACTION_PHASE';
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
/* START draft_submitted_flag*/

prior_exists := 'N';
IF p_prior_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.draft_submitted_flag,
       p_prior_rec.draft_submitted_flag) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_changed_attr_tbl(ind).attribute_name  := 'draft_submitted_flag';
   x_header_changed_attr_tbl(ind).current_value      := p_curr_rec.draft_submitted_flag;
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.draft_submitted_flag;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_next_version IS NOT NULL THEN
IF OE_Globals.Equal(
       p_curr_rec.draft_submitted_flag,
       p_next_rec.draft_submitted_flag) THEN
    IF prior_exists = 'Y' THEN
   x_header_changed_attr_tbl(ind).next_value      := p_curr_rec.draft_submitted_flag;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_changed_attr_tbl(ind).attribute_name := 'draft_submitted_flag';
   x_header_changed_attr_tbl(ind).prior_value        := p_prior_rec.draft_submitted_flag;
   x_header_changed_attr_tbl(ind).current_value     := p_curr_rec.draft_submitted_flag;
   x_header_changed_attr_tbl(ind).next_value      := p_next_rec.draft_submitted_flag;
END IF; /*  NEXT */
END IF;

/* END draft_submitted_flag*/
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
   x_header_changed_attr_tbl(ind).attribute_name  := 'sold_to_location';
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
   x_header_changed_attr_tbl(ind).attribute_name := 'sold_to_location';

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
ELSE
NULL;
END IF;
/*
j := 0;
--dbms_output.put_line('No of records'||x_header_changed_attr_tbl.count);
WHILE j < x_header_changed_attr_tbl.count
LOOP
j:=j+1;
dbms_output.put_line('attribute value '||x_header_changed_attr_tbl(j).attribute_name ||' Prior '||x_header_changed_attr_tbl(j).prior_value||' Current '||x_header_changed_attr_tbl(j).current_value || ' Next '||x_header_changed_attr_tbl(j).next_value);
END LOOP;
*/
END COMPARE_HEADER_VERSIONS;

PROCEDURE QUERY_LINE_ROW
(p_header_id	                  NUMBER,
 p_line_id	                  NUMBER,
 p_version	                  NUMBER,
 p_phase_change_flag	          VARCHAR2,
 x_line_rec	                  IN OUT NOCOPY OE_ORDER_PUB.line_rec_type)
IS
l_org_id                NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering OE_VERSION_COMP.QUERY_LINE_ROW');
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('version' ||p_version);
END IF;

    l_org_id := OE_GLOBALS.G_ORG_ID;

    IF l_org_id IS NULL THEN
      OE_GLOBALS.Set_Context;
      l_org_id := OE_GLOBALS.G_ORG_ID;
    END IF;

    SELECT ACCOUNTING_RULE_ID
    ,      ACCOUNTING_RULE_DURATION
    ,       ACTUAL_ARRIVAL_DATE
    ,       ACTUAL_SHIPMENT_DATE
    ,       AGREEMENT_ID
    ,       ARRIVAL_SET_ID
    ,       ATO_LINE_ID
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
    ,       ATTRIBUTE2
    ,       ATTRIBUTE20
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       AUTO_SELECTED_QUANTITY
    ,       AUTHORIZED_TO_SHIP_FLAG
    ,       BOOKED_FLAG
    ,       CANCELLED_FLAG
    ,       CANCELLED_QUANTITY
    ,       COMPONENT_CODE
    ,       COMPONENT_NUMBER
    ,       COMPONENT_SEQUENCE_ID
    ,       CONFIG_HEADER_ID
    ,       CONFIG_REV_NBR
    ,       CONFIG_DISPLAY_SEQUENCE
    ,       CONFIGURATION_ID
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CREDIT_INVOICE_LINE_ID
    ,       CUSTOMER_DOCK_CODE
    ,       CUSTOMER_JOB
    ,       CUSTOMER_PRODUCTION_LINE
    ,       CUST_PRODUCTION_SEQ_NUM
    ,       CUSTOMER_TRX_LINE_ID
    ,       CUST_MODEL_SERIAL_NUMBER
    ,       CUST_PO_NUMBER
    ,       CUSTOMER_LINE_NUMBER
    ,       DELIVERY_LEAD_TIME
    ,       DELIVER_TO_CONTACT_ID
    ,       DELIVER_TO_ORG_ID
    ,       DEMAND_BUCKET_TYPE_CODE
    ,       DEMAND_CLASS_CODE
    ,       DEP_PLAN_REQUIRED_FLAG
    ,       EARLIEST_ACCEPTABLE_DATE
    ,       END_ITEM_UNIT_NUMBER
    ,       EXPLOSION_DATE
    ,       FIRST_ACK_CODE
    ,       FIRST_ACK_DATE
    ,       FOB_POINT_CODE
    ,       FREIGHT_CARRIER_CODE
    ,       FREIGHT_TERMS_CODE
    ,       FULFILLED_QUANTITY
    ,       FULFILLED_FLAG
    ,       FULFILLMENT_METHOD_CODE
    ,       FULFILLMENT_DATE
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
    ,       INDUSTRY_ATTRIBUTE1
    ,       INDUSTRY_ATTRIBUTE10
    ,       INDUSTRY_ATTRIBUTE11
    ,       INDUSTRY_ATTRIBUTE12
    ,       INDUSTRY_ATTRIBUTE13
    ,       INDUSTRY_ATTRIBUTE14
    ,       INDUSTRY_ATTRIBUTE15
    ,       INDUSTRY_ATTRIBUTE16
    ,       INDUSTRY_ATTRIBUTE17
    ,       INDUSTRY_ATTRIBUTE18
    ,       INDUSTRY_ATTRIBUTE19
    ,       INDUSTRY_ATTRIBUTE20
    ,       INDUSTRY_ATTRIBUTE21
    ,       INDUSTRY_ATTRIBUTE22
    ,       INDUSTRY_ATTRIBUTE23
    ,       INDUSTRY_ATTRIBUTE24
    ,       INDUSTRY_ATTRIBUTE25
    ,       INDUSTRY_ATTRIBUTE26
    ,       INDUSTRY_ATTRIBUTE27
    ,       INDUSTRY_ATTRIBUTE28
    ,       INDUSTRY_ATTRIBUTE29
    ,       INDUSTRY_ATTRIBUTE30
    ,       INDUSTRY_ATTRIBUTE2
    ,       INDUSTRY_ATTRIBUTE3
    ,       INDUSTRY_ATTRIBUTE4
    ,       INDUSTRY_ATTRIBUTE5
    ,       INDUSTRY_ATTRIBUTE6
    ,       INDUSTRY_ATTRIBUTE7
    ,       INDUSTRY_ATTRIBUTE8
    ,       INDUSTRY_ATTRIBUTE9
    ,       INDUSTRY_CONTEXT
    ,       INTMED_SHIP_TO_CONTACT_ID
    ,       INTMED_SHIP_TO_ORG_ID
    ,       INVENTORY_ITEM_ID
    ,       INVOICE_INTERFACE_STATUS_CODE
    ,       INVOICE_TO_CONTACT_ID
    ,       INVOICE_TO_ORG_ID
    ,       INVOICED_QUANTITY
    ,       INVOICING_RULE_ID
    ,       ORDERED_ITEM_ID
    ,       ITEM_IDENTIFIER_TYPE
    ,       ORDERED_ITEM
    ,       ITEM_REVISION
    ,       ITEM_TYPE_CODE
    ,       LAST_ACK_CODE
    ,       LAST_ACK_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LATEST_ACCEPTABLE_DATE
    ,       LINE_CATEGORY_CODE
    ,       LINE_ID
    ,       LINE_NUMBER
    ,       LINE_TYPE_ID
    ,       LINK_TO_LINE_ID
    ,       MODEL_GROUP_NUMBER
  --  ,       MFG_COMPONENT_SEQUENCE_ID
  --  ,       MFG_LEAD_TIME
    ,       OPEN_FLAG
    ,       OPTION_FLAG
    ,       OPTION_NUMBER
    ,       ORDERED_QUANTITY
    ,       ORDERED_QUANTITY2
    ,       ORDER_QUANTITY_UOM
    ,       ORDERED_QUANTITY_UOM2
    ,       ORG_ID
    ,       ORIG_SYS_DOCUMENT_REF
    ,       ORIG_SYS_LINE_REF
    ,       ORIG_SYS_SHIPMENT_REF
    ,       OVER_SHIP_REASON_CODE
    ,       OVER_SHIP_RESOLVED_FLAG
    ,       PAYMENT_TERM_ID
    ,       PLANNING_PRIORITY
    ,       PREFERRED_GRADE
    ,       PRICE_LIST_ID
    ,       PRICE_REQUEST_CODE
    ,       PRICING_ATTRIBUTE1
    ,       PRICING_ATTRIBUTE10
    ,       PRICING_ATTRIBUTE2
    ,       PRICING_ATTRIBUTE3
    ,       PRICING_ATTRIBUTE4
    ,       PRICING_ATTRIBUTE5
    ,       PRICING_ATTRIBUTE6
    ,       PRICING_ATTRIBUTE7
    ,       PRICING_ATTRIBUTE8
    ,       PRICING_ATTRIBUTE9
    ,       PRICING_CONTEXT
    ,       PRICING_DATE
    ,       PRICING_QUANTITY
    ,       PRICING_QUANTITY_UOM
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       PROJECT_ID
    ,       PROMISE_DATE
    ,       RE_SOURCE_FLAG
    ,       REFERENCE_CUSTOMER_TRX_LINE_ID
    ,       REFERENCE_HEADER_ID
    ,       REFERENCE_LINE_ID
    ,       REFERENCE_TYPE
    ,       REQUEST_DATE
    ,       REQUEST_ID
    ,       RETURN_ATTRIBUTE1
    ,       RETURN_ATTRIBUTE10
    ,       RETURN_ATTRIBUTE11
    ,       RETURN_ATTRIBUTE12
    ,       RETURN_ATTRIBUTE13
    ,       RETURN_ATTRIBUTE14
    ,       RETURN_ATTRIBUTE15
    ,       RETURN_ATTRIBUTE2
    ,       RETURN_ATTRIBUTE3
    ,       RETURN_ATTRIBUTE4
    ,       RETURN_ATTRIBUTE5
    ,       RETURN_ATTRIBUTE6
    ,       RETURN_ATTRIBUTE7
    ,       RETURN_ATTRIBUTE8
    ,       RETURN_ATTRIBUTE9
    ,       RETURN_CONTEXT
    ,       RETURN_REASON_CODE
    ,       RLA_SCHEDULE_TYPE_CODE
    ,       SALESREP_ID
    ,       SCHEDULE_ARRIVAL_DATE
    ,       SCHEDULE_SHIP_DATE
    ,       SCHEDULE_STATUS_CODE
    ,       SHIPMENT_NUMBER
    ,       SHIPMENT_PRIORITY_CODE
    ,       SHIPPED_QUANTITY
    ,       SHIPPED_QUANTITY2
    ,       SHIPPING_METHOD_CODE
    ,       SHIPPING_QUANTITY
    ,       SHIPPING_QUANTITY2
    ,       SHIPPING_QUANTITY_UOM
    ,       SHIP_FROM_ORG_ID
    ,       SUBINVENTORY
    ,       SHIP_SET_ID
    ,       SHIP_TOLERANCE_ABOVE
    ,       SHIP_TOLERANCE_BELOW
    ,       SHIPPABLE_FLAG
    ,       SHIPPING_INTERFACED_FLAG
    ,       SHIP_TO_CONTACT_ID
    ,       SHIP_TO_ORG_ID
    ,       SHIP_MODEL_COMPLETE_FLAG
    ,       SOLD_TO_ORG_ID
    ,       SOLD_FROM_ORG_ID
    ,       SORT_ORDER
    ,       SOURCE_DOCUMENT_ID
    ,       SOURCE_DOCUMENT_LINE_ID
    ,       SOURCE_DOCUMENT_TYPE_ID
    ,       SOURCE_TYPE_CODE
    ,       SPLIT_FROM_LINE_ID
    ,       LINE_SET_ID
    ,       SPLIT_BY
    ,       MODEL_REMNANT_FLAG
    ,       TASK_ID
    ,       TAX_CODE
    ,       TAX_DATE
    ,       TAX_EXEMPT_FLAG
    ,       TAX_EXEMPT_NUMBER
    ,       TAX_EXEMPT_REASON_CODE
    ,       TAX_POINT_CODE
    ,       TAX_RATE
    ,       TAX_VALUE
    ,       TOP_MODEL_LINE_ID
    ,       UNIT_LIST_PRICE
    ,       UNIT_LIST_PRICE_PER_PQTY
    ,       UNIT_SELLING_PRICE
    ,       UNIT_SELLING_PRICE_PER_PQTY
    ,       VISIBLE_DEMAND_FLAG
    ,       VEH_CUS_ITEM_CUM_KEY_ID
    ,       SHIPPING_INSTRUCTIONS
    ,       PACKING_INSTRUCTIONS
    ,       SERVICE_TXN_REASON_CODE
    ,       SERVICE_TXN_COMMENTS
    ,       SERVICE_DURATION
    ,       SERVICE_PERIOD
    ,       SERVICE_START_DATE
    ,       SERVICE_END_DATE
    ,       SERVICE_COTERMINATE_FLAG
    ,       UNIT_LIST_PERCENT
    ,       UNIT_SELLING_PERCENT
    ,       UNIT_PERCENT_BASE_PRICE
    ,       SERVICE_NUMBER
    ,       SERVICE_REFERENCE_TYPE_CODE
    ,       SERVICE_REFERENCE_LINE_ID
    ,       SERVICE_REFERENCE_SYSTEM_ID
    ,       TP_CONTEXT
    ,       TP_ATTRIBUTE1
    ,       TP_ATTRIBUTE2
    ,       TP_ATTRIBUTE3
    ,       TP_ATTRIBUTE4
    ,       TP_ATTRIBUTE5
    ,       TP_ATTRIBUTE6
    ,       TP_ATTRIBUTE7
    ,       TP_ATTRIBUTE8
    ,       TP_ATTRIBUTE9
    ,       TP_ATTRIBUTE10
    ,       TP_ATTRIBUTE11
    ,       TP_ATTRIBUTE12
    ,       TP_ATTRIBUTE13
    ,       TP_ATTRIBUTE14
    ,       TP_ATTRIBUTE15
    ,       FLOW_STATUS_CODE
--    ,       MARKETING_SOURCE_CODE_ID
    ,       CALCULATE_PRICE_FLAG
    ,       COMMITMENT_ID
    ,       ORDER_SOURCE_ID
  --  ,       UPGRADED_FLAG
    ,       ORIGINAL_INVENTORY_ITEM_ID
    ,       ORIGINAL_ITEM_IDENTIFIER_TYPE
    ,       ORIGINAL_ORDERED_ITEM_ID
    ,       ORIGINAL_ORDERED_ITEM
    ,       ITEM_RELATIONSHIP_TYPE
    ,       ITEM_SUBSTITUTION_TYPE_CODE
    ,       LATE_DEMAND_PENALTY_FACTOR
    ,       OVERRIDE_ATP_DATE_CODE
 --   ,       FIRM_DEMAND_FLAG
--    ,       EARLIEST_SHIP_DATE
    ,       USER_ITEM_DESCRIPTION
    ,       BLANKET_NUMBER
    ,       BLANKET_LINE_NUMBER
    ,       BLANKET_VERSION_NUMBER
  --  ,       UNIT_COST
  --  ,       LOCK_CONTROL
    ,       NVL(OPTION_NUMBER, -1)
    ,       NVL(COMPONENT_NUMBER, -1)
    ,       NVL(SERVICE_NUMBER, -1)
    ,       CHANGE_SEQUENCE
    ,       transaction_phase_code
    ,      source_document_version_number
    INTO x_line_rec.ACCOUNTING_RULE_ID
    ,x_line_rec.ACCOUNTING_RULE_DURATION
    ,x_line_rec.ACTUAL_ARRIVAL_DATE
    ,x_line_rec.ACTUAL_SHIPMENT_DATE
    ,x_line_rec.AGREEMENT_ID
    ,x_line_rec.ARRIVAL_SET_ID
    ,x_line_rec.ATO_LINE_ID
    ,x_line_rec.ATTRIBUTE1
    ,x_line_rec.ATTRIBUTE10
    ,x_line_rec.ATTRIBUTE11
    ,x_line_rec.ATTRIBUTE12
    ,x_line_rec.ATTRIBUTE13
    ,x_line_rec.ATTRIBUTE14
    ,x_line_rec.ATTRIBUTE15
    ,x_line_rec.ATTRIBUTE16
    ,x_line_rec.ATTRIBUTE17
    ,x_line_rec.ATTRIBUTE18
    ,x_line_rec.ATTRIBUTE19
    ,x_line_rec.ATTRIBUTE2
    ,x_line_rec.ATTRIBUTE20
    ,x_line_rec.ATTRIBUTE3
    ,x_line_rec.ATTRIBUTE4
    ,x_line_rec.ATTRIBUTE5
    ,x_line_rec.ATTRIBUTE6
    ,x_line_rec.ATTRIBUTE7
    ,x_line_rec.ATTRIBUTE8
    ,x_line_rec.ATTRIBUTE9
    ,x_line_rec.AUTO_SELECTED_QUANTITY
    ,x_line_rec.AUTHORIZED_TO_SHIP_FLAG
    ,x_line_rec.BOOKED_FLAG
    ,x_line_rec.CANCELLED_FLAG
    ,x_line_rec.CANCELLED_QUANTITY
    ,x_line_rec.COMPONENT_CODE
    ,x_line_rec.COMPONENT_NUMBER
    ,x_line_rec.COMPONENT_SEQUENCE_ID
    ,x_line_rec.CONFIG_HEADER_ID
    ,x_line_rec.CONFIG_REV_NBR
    ,x_line_rec.CONFIG_DISPLAY_SEQUENCE
    ,x_line_rec.CONFIGURATION_ID
    ,x_line_rec.CONTEXT
    ,x_line_rec.CREATED_BY
    ,x_line_rec.CREATION_DATE
    ,x_line_rec.CREDIT_INVOICE_LINE_ID
    ,x_line_rec.CUSTOMER_DOCK_CODE
    ,x_line_rec.CUSTOMER_JOB
    ,x_line_rec.CUSTOMER_PRODUCTION_LINE
    ,x_line_rec.CUST_PRODUCTION_SEQ_NUM
    ,x_line_rec.CUSTOMER_TRX_LINE_ID
    ,x_line_rec.CUST_MODEL_SERIAL_NUMBER
    ,x_line_rec.CUST_PO_NUMBER
    ,x_line_rec.CUSTOMER_LINE_NUMBER
    ,x_line_rec.DELIVERY_LEAD_TIME
    ,x_line_rec.DELIVER_TO_CONTACT_ID
    ,x_line_rec.DELIVER_TO_ORG_ID
    ,x_line_rec.DEMAND_BUCKET_TYPE_CODE
    ,x_line_rec.DEMAND_CLASS_CODE
    ,x_line_rec.DEP_PLAN_REQUIRED_FLAG
    ,x_line_rec.EARLIEST_ACCEPTABLE_DATE
    ,x_line_rec.END_ITEM_UNIT_NUMBER
    ,x_line_rec.EXPLOSION_DATE
    ,x_line_rec.FIRST_ACK_CODE
    ,x_line_rec.FIRST_ACK_DATE
    ,x_line_rec.FOB_POINT_CODE
    ,x_line_rec.FREIGHT_CARRIER_CODE
    ,x_line_rec.FREIGHT_TERMS_CODE
    ,x_line_rec.FULFILLED_QUANTITY
    ,x_line_rec.FULFILLED_FLAG
    ,x_line_rec.FULFILLMENT_METHOD_CODE
    ,x_line_rec.FULFILLMENT_DATE
    ,x_line_rec.GLOBAL_ATTRIBUTE1
    ,x_line_rec.GLOBAL_ATTRIBUTE10
    ,x_line_rec.GLOBAL_ATTRIBUTE11
    ,x_line_rec.GLOBAL_ATTRIBUTE12
    ,x_line_rec.GLOBAL_ATTRIBUTE13
    ,x_line_rec.GLOBAL_ATTRIBUTE14
    ,x_line_rec.GLOBAL_ATTRIBUTE15
    ,x_line_rec.GLOBAL_ATTRIBUTE16
    ,x_line_rec.GLOBAL_ATTRIBUTE17
    ,x_line_rec.GLOBAL_ATTRIBUTE18
    ,x_line_rec.GLOBAL_ATTRIBUTE19
    ,x_line_rec.GLOBAL_ATTRIBUTE2
    ,x_line_rec.GLOBAL_ATTRIBUTE20
    ,x_line_rec.GLOBAL_ATTRIBUTE3
    ,x_line_rec.GLOBAL_ATTRIBUTE4
    ,x_line_rec.GLOBAL_ATTRIBUTE5
    ,x_line_rec.GLOBAL_ATTRIBUTE6
    ,x_line_rec.GLOBAL_ATTRIBUTE7
    ,x_line_rec.GLOBAL_ATTRIBUTE8
    ,x_line_rec.GLOBAL_ATTRIBUTE9
    ,x_line_rec.GLOBAL_ATTRIBUTE_CATEGORY
    ,x_line_rec.HEADER_ID
    ,x_line_rec.INDUSTRY_ATTRIBUTE1
    ,x_line_rec.INDUSTRY_ATTRIBUTE10
    ,x_line_rec.INDUSTRY_ATTRIBUTE11
    ,x_line_rec.INDUSTRY_ATTRIBUTE12
    ,x_line_rec.INDUSTRY_ATTRIBUTE13
    ,x_line_rec.INDUSTRY_ATTRIBUTE14
    ,x_line_rec.INDUSTRY_ATTRIBUTE15
    ,x_line_rec.INDUSTRY_ATTRIBUTE16
    ,x_line_rec.INDUSTRY_ATTRIBUTE17
    ,x_line_rec.INDUSTRY_ATTRIBUTE18
    ,x_line_rec.INDUSTRY_ATTRIBUTE19
    ,x_line_rec.INDUSTRY_ATTRIBUTE20
    ,x_line_rec.INDUSTRY_ATTRIBUTE21
    ,x_line_rec.INDUSTRY_ATTRIBUTE22
    ,x_line_rec.INDUSTRY_ATTRIBUTE23
    ,x_line_rec.INDUSTRY_ATTRIBUTE24
    ,x_line_rec.INDUSTRY_ATTRIBUTE25
    ,x_line_rec.INDUSTRY_ATTRIBUTE26
    ,x_line_rec.INDUSTRY_ATTRIBUTE27
    ,x_line_rec.INDUSTRY_ATTRIBUTE28
    ,x_line_rec.INDUSTRY_ATTRIBUTE29
    ,x_line_rec.INDUSTRY_ATTRIBUTE30
    ,x_line_rec.INDUSTRY_ATTRIBUTE2
    ,x_line_rec.INDUSTRY_ATTRIBUTE3
    ,x_line_rec.INDUSTRY_ATTRIBUTE4
    ,x_line_rec.INDUSTRY_ATTRIBUTE5
    ,x_line_rec.INDUSTRY_ATTRIBUTE6
    ,x_line_rec.INDUSTRY_ATTRIBUTE7
    ,x_line_rec.INDUSTRY_ATTRIBUTE8
    ,x_line_rec.INDUSTRY_ATTRIBUTE9
    ,x_line_rec.INDUSTRY_CONTEXT
    ,x_line_rec.INTerMED_SHIP_TO_CONTACT_ID
    ,x_line_rec.INTerMED_SHIP_TO_ORG_ID
    ,x_line_rec.INVENTORY_ITEM_ID
    ,x_line_rec.INVOICE_INTERFACE_STATUS_CODE
    ,x_line_rec.INVOICE_TO_CONTACT_ID
    ,x_line_rec.INVOICE_TO_ORG_ID
    ,x_line_rec.INVOICED_QUANTITY
    ,x_line_rec.INVOICING_RULE_ID
    ,x_line_rec.ORDERED_ITEM_ID
    ,x_line_rec.ITEM_IDENTIFIER_TYPE
    ,x_line_rec.ORDERED_ITEM
    ,x_line_rec.ITEM_REVISION
    ,x_line_rec.ITEM_TYPE_CODE
    ,x_line_rec.LAST_ACK_CODE
    ,x_line_rec.LAST_ACK_DATE
    ,x_line_rec.LAST_UPDATED_BY
    ,x_line_rec.LAST_UPDATE_DATE
    ,x_line_rec.LAST_UPDATE_LOGIN
    ,x_line_rec.LATEST_ACCEPTABLE_DATE
    ,x_line_rec.LINE_CATEGORY_CODE
    ,x_line_rec.LINE_ID
    ,x_line_rec.LINE_NUMBER
    ,x_line_rec.LINE_TYPE_ID
    ,x_line_rec.LINK_TO_LINE_ID
    ,x_line_rec.MODEL_GROUP_NUMBER
  --  ,x_line_rec.MFG_COMPONENT_SEQUENCE_ID
  --  ,x_line_rec.MFG_LEAD_TIME
    ,x_line_rec.OPEN_FLAG
    ,x_line_rec.OPTION_FLAG
    ,x_line_rec.OPTION_NUMBER
    ,x_line_rec.ORDERED_QUANTITY
    ,x_line_rec.ORDERED_QUANTITY2
    ,x_line_rec.ORDER_QUANTITY_UOM
    ,x_line_rec.ORDERED_QUANTITY_UOM2
    ,x_line_rec.ORG_ID
    ,x_line_rec.ORIG_SYS_DOCUMENT_REF
    ,x_line_rec.ORIG_SYS_LINE_REF
    ,x_line_rec.ORIG_SYS_SHIPMENT_REF
    ,x_line_rec.OVER_SHIP_REASON_CODE
    ,x_line_rec.OVER_SHIP_RESOLVED_FLAG
    ,x_line_rec.PAYMENT_TERM_ID
    ,x_line_rec.PLANNING_PRIORITY
    ,x_line_rec.PREFERRED_GRADE
    ,x_line_rec.PRICE_LIST_ID
    ,x_line_rec.PRICE_REQUEST_CODE
    ,x_line_rec.PRICING_ATTRIBUTE1
    ,x_line_rec.PRICING_ATTRIBUTE10
    ,x_line_rec.PRICING_ATTRIBUTE2
    ,x_line_rec.PRICING_ATTRIBUTE3
    ,x_line_rec.PRICING_ATTRIBUTE4
    ,x_line_rec.PRICING_ATTRIBUTE5
    ,x_line_rec.PRICING_ATTRIBUTE6
    ,x_line_rec.PRICING_ATTRIBUTE7
    ,x_line_rec.PRICING_ATTRIBUTE8
    ,x_line_rec.PRICING_ATTRIBUTE9
    ,x_line_rec.PRICING_CONTEXT
    ,x_line_rec.PRICING_DATE
    ,x_line_rec.PRICING_QUANTITY
    ,x_line_rec.PRICING_QUANTITY_UOM
    ,x_line_rec.PROGRAM_APPLICATION_ID
    ,x_line_rec.PROGRAM_ID
    ,x_line_rec.PROGRAM_UPDATE_DATE
    ,x_line_rec.PROJECT_ID
    ,x_line_rec.PROMISE_DATE
    ,x_line_rec.RE_SOURCE_FLAG
    ,x_line_rec.REFERENCE_CUSTOMER_TRX_LINE_ID
    ,x_line_rec.REFERENCE_HEADER_ID
    ,x_line_rec.REFERENCE_LINE_ID
    ,x_line_rec.REFERENCE_TYPE
    ,x_line_rec.REQUEST_DATE
    ,x_line_rec.REQUEST_ID
    ,x_line_rec.RETURN_ATTRIBUTE1
    ,x_line_rec.RETURN_ATTRIBUTE10
    ,x_line_rec.RETURN_ATTRIBUTE11
    ,x_line_rec.RETURN_ATTRIBUTE12
    ,x_line_rec.RETURN_ATTRIBUTE13
    ,x_line_rec.RETURN_ATTRIBUTE14
    ,x_line_rec.RETURN_ATTRIBUTE15
    ,x_line_rec.RETURN_ATTRIBUTE2
    ,x_line_rec.RETURN_ATTRIBUTE3
    ,x_line_rec.RETURN_ATTRIBUTE4
    ,x_line_rec.RETURN_ATTRIBUTE5
    ,x_line_rec.RETURN_ATTRIBUTE6
    ,x_line_rec.RETURN_ATTRIBUTE7
    ,x_line_rec.RETURN_ATTRIBUTE8
    ,x_line_rec.RETURN_ATTRIBUTE9
    ,x_line_rec.RETURN_CONTEXT
    ,x_line_rec.RETURN_REASON_CODE
    ,x_line_rec.RLA_SCHEDULE_TYPE_CODE
    ,x_line_rec.SALESREP_ID
    ,x_line_rec.SCHEDULE_ARRIVAL_DATE
    ,x_line_rec.SCHEDULE_SHIP_DATE
    ,x_line_rec.SCHEDULE_STATUS_CODE
    ,x_line_rec.SHIPMENT_NUMBER
    ,x_line_rec.SHIPMENT_PRIORITY_CODE
    ,x_line_rec.SHIPPED_QUANTITY
    ,x_line_rec.SHIPPED_QUANTITY2
    ,x_line_rec.SHIPPING_METHOD_CODE
    ,x_line_rec.SHIPPING_QUANTITY
    ,x_line_rec.SHIPPING_QUANTITY2
    ,x_line_rec.SHIPPING_QUANTITY_UOM
    ,x_line_rec.SHIP_FROM_ORG_ID
    ,x_line_rec.SUBINVENTORY
    ,x_line_rec.SHIP_SET_ID
    ,x_line_rec.SHIP_TOLERANCE_ABOVE
    ,x_line_rec.SHIP_TOLERANCE_BELOW
    ,x_line_rec.SHIPPABLE_FLAG
    ,x_line_rec.SHIPPING_INTERFACED_FLAG
    ,x_line_rec.SHIP_TO_CONTACT_ID
    ,x_line_rec.SHIP_TO_ORG_ID
    ,x_line_rec.SHIP_MODEL_COMPLETE_FLAG
    ,x_line_rec.SOLD_TO_ORG_ID
    ,x_line_rec.SOLD_FROM_ORG_ID
    ,x_line_rec.SORT_ORDER
    ,x_line_rec.SOURCE_DOCUMENT_ID
    ,x_line_rec.SOURCE_DOCUMENT_LINE_ID
    ,x_line_rec.SOURCE_DOCUMENT_TYPE_ID
    ,x_line_rec.SOURCE_TYPE_CODE
    ,x_line_rec.SPLIT_FROM_LINE_ID
    ,x_line_rec.LINE_SET_ID
    ,x_line_rec.SPLIT_BY
    ,x_line_rec.MODEL_REMNANT_FLAG
    ,x_line_rec.TASK_ID
    ,x_line_rec.TAX_CODE
    ,x_line_rec.TAX_DATE
    ,x_line_rec.TAX_EXEMPT_FLAG
    ,x_line_rec.TAX_EXEMPT_NUMBER
    ,x_line_rec.TAX_EXEMPT_REASON_CODE
    ,x_line_rec.TAX_POINT_CODE
    ,x_line_rec.TAX_RATE
    ,x_line_rec.TAX_VALUE
    ,x_line_rec.TOP_MODEL_LINE_ID
    ,x_line_rec.UNIT_LIST_PRICE
    ,x_line_rec.UNIT_LIST_PRICE_PER_PQTY
    ,x_line_rec.UNIT_SELLING_PRICE
    ,x_line_rec.UNIT_SELLING_PRICE_PER_PQTY
    ,x_line_rec.VISIBLE_DEMAND_FLAG
    ,x_line_rec.VEH_CUS_ITEM_CUM_KEY_ID
    ,x_line_rec.SHIPPING_INSTRUCTIONS
    ,x_line_rec.PACKING_INSTRUCTIONS
    ,x_line_rec.SERVICE_TXN_REASON_CODE
    ,x_line_rec.SERVICE_TXN_COMMENTS
    ,x_line_rec.SERVICE_DURATION
    ,x_line_rec.SERVICE_PERIOD
    ,x_line_rec.SERVICE_START_DATE
    ,x_line_rec.SERVICE_END_DATE
    ,x_line_rec.SERVICE_COTERMINATE_FLAG
    ,x_line_rec.UNIT_LIST_PERCENT
    ,x_line_rec.UNIT_SELLING_PERCENT
    ,x_line_rec.UNIT_PERCENT_BASE_PRICE
    ,x_line_rec.SERVICE_NUMBER
    ,x_line_rec.SERVICE_REFERENCE_TYPE_CODE
    ,x_line_rec.SERVICE_REFERENCE_LINE_ID
    ,x_line_rec.SERVICE_REFERENCE_SYSTEM_ID
    ,x_line_rec.TP_CONTEXT
    ,x_line_rec.TP_ATTRIBUTE1
    ,x_line_rec.TP_ATTRIBUTE2
    ,x_line_rec.TP_ATTRIBUTE3
    ,x_line_rec.TP_ATTRIBUTE4
    ,x_line_rec.TP_ATTRIBUTE5
    ,x_line_rec.TP_ATTRIBUTE6
    ,x_line_rec.TP_ATTRIBUTE7
    ,x_line_rec.TP_ATTRIBUTE8
    ,x_line_rec.TP_ATTRIBUTE9
    ,x_line_rec.TP_ATTRIBUTE10
    ,x_line_rec.TP_ATTRIBUTE11
    ,x_line_rec.TP_ATTRIBUTE12
    ,x_line_rec.TP_ATTRIBUTE13
    ,x_line_rec.TP_ATTRIBUTE14
    ,x_line_rec.TP_ATTRIBUTE15
    ,x_line_rec.FLOW_STATUS_CODE
--    ,x_line_rec.MARKETING_SOURCE_CODE_ID
    ,x_line_rec.CALCULATE_PRICE_FLAG
    ,x_line_rec.COMMITMENT_ID
    ,x_line_rec.ORDER_SOURCE_ID
    --,x_line_rec.UPGRADED_FLAG
    ,x_line_rec.ORIGINAL_INVENTORY_ITEM_ID
    ,x_line_rec.ORIGINAL_ITEM_IDENTIFIER_TYPE
    ,x_line_rec.ORIGINAL_ORDERED_ITEM_ID
    ,x_line_rec.ORIGINAL_ORDERED_ITEM
    ,x_line_rec.ITEM_RELATIONSHIP_TYPE
    ,x_line_rec.ITEM_SUBSTITUTION_TYPE_CODE
    ,x_line_rec.LATE_DEMAND_PENALTY_FACTOR
    ,x_line_rec.OVERRIDE_ATP_DATE_CODE
   -- ,x_line_rec.FIRM_DEMAND_FLAG
   -- ,x_line_rec.EARLIEST_SHIP_DATE
    ,x_line_rec.USER_ITEM_DESCRIPTION
    ,x_line_rec.BLANKET_NUMBER
    ,x_line_rec.BLANKET_LINE_NUMBER
    ,x_line_rec.BLANKET_VERSION_NUMBER
   -- ,x_line_rec.UNIT_COST
   -- ,x_line_rec.LOCK_CONTROL
    ,x_line_rec.OPTION_NUMBER
    ,x_line_rec.COMPONENT_NUMBER
    ,x_line_rec.SERVICE_NUMBER
    ,x_line_rec.CHANGE_SEQUENCE
    ,x_line_rec.transaction_phase_code
    ,x_line_rec.source_document_version_number
    FROM    OE_ORDER_LINES_HISTORY
    WHERE LINE_ID = p_line_id
    and version_number = p_version
    and header_id=p_header_id
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
 x_line_rec	                  IN OUT NOCOPY OE_ORDER_PUB.line_rec_type)
IS
l_org_id                NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering OE_VERSION_COMP.QUERY_LINE_TRANS_ROW', 1);
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('version' ||p_version);
END IF;

    l_org_id := OE_GLOBALS.G_ORG_ID;

    IF l_org_id IS NULL THEN
      OE_GLOBALS.Set_Context;
      l_org_id := OE_GLOBALS.G_ORG_ID;
    END IF;

    SELECT ACCOUNTING_RULE_ID
    ,      ACCOUNTING_RULE_DURATION
    ,       ACTUAL_ARRIVAL_DATE
    ,       ACTUAL_SHIPMENT_DATE
    ,       AGREEMENT_ID
    ,       ARRIVAL_SET_ID
    ,       ATO_LINE_ID
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
    ,       ATTRIBUTE2
    ,       ATTRIBUTE20
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       AUTO_SELECTED_QUANTITY
    ,       AUTHORIZED_TO_SHIP_FLAG
    ,       BOOKED_FLAG
    ,       CANCELLED_FLAG
    ,       CANCELLED_QUANTITY
    ,       COMPONENT_CODE
    ,       COMPONENT_NUMBER
    ,       COMPONENT_SEQUENCE_ID
    ,       CONFIG_HEADER_ID
    ,       CONFIG_REV_NBR
    ,       CONFIG_DISPLAY_SEQUENCE
    ,       CONFIGURATION_ID
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CREDIT_INVOICE_LINE_ID
    ,       CUSTOMER_DOCK_CODE
    ,       CUSTOMER_JOB
    ,       CUSTOMER_PRODUCTION_LINE
    ,       CUST_PRODUCTION_SEQ_NUM
    ,       CUSTOMER_TRX_LINE_ID
    ,       CUST_MODEL_SERIAL_NUMBER
    ,       CUST_PO_NUMBER
    ,       CUSTOMER_LINE_NUMBER
    ,       DELIVERY_LEAD_TIME
    ,       DELIVER_TO_CONTACT_ID
    ,       DELIVER_TO_ORG_ID
    ,       DEMAND_BUCKET_TYPE_CODE
    ,       DEMAND_CLASS_CODE
    ,       DEP_PLAN_REQUIRED_FLAG
    ,       EARLIEST_ACCEPTABLE_DATE
    ,       END_ITEM_UNIT_NUMBER
    ,       EXPLOSION_DATE
    ,       FIRST_ACK_CODE
    ,       FIRST_ACK_DATE
    ,       FOB_POINT_CODE
    ,       FREIGHT_CARRIER_CODE
    ,       FREIGHT_TERMS_CODE
    ,       FULFILLED_QUANTITY
    ,       FULFILLED_FLAG
    ,       FULFILLMENT_METHOD_CODE
    ,       FULFILLMENT_DATE
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
    ,       INDUSTRY_ATTRIBUTE1
    ,       INDUSTRY_ATTRIBUTE10
    ,       INDUSTRY_ATTRIBUTE11
    ,       INDUSTRY_ATTRIBUTE12
    ,       INDUSTRY_ATTRIBUTE13
    ,       INDUSTRY_ATTRIBUTE14
    ,       INDUSTRY_ATTRIBUTE15
    ,       INDUSTRY_ATTRIBUTE16
    ,       INDUSTRY_ATTRIBUTE17
    ,       INDUSTRY_ATTRIBUTE18
    ,       INDUSTRY_ATTRIBUTE19
    ,       INDUSTRY_ATTRIBUTE20
    ,       INDUSTRY_ATTRIBUTE21
    ,       INDUSTRY_ATTRIBUTE22
    ,       INDUSTRY_ATTRIBUTE23
    ,       INDUSTRY_ATTRIBUTE24
    ,       INDUSTRY_ATTRIBUTE25
    ,       INDUSTRY_ATTRIBUTE26
    ,       INDUSTRY_ATTRIBUTE27
    ,       INDUSTRY_ATTRIBUTE28
    ,       INDUSTRY_ATTRIBUTE29
    ,       INDUSTRY_ATTRIBUTE30
    ,       INDUSTRY_ATTRIBUTE2
    ,       INDUSTRY_ATTRIBUTE3
    ,       INDUSTRY_ATTRIBUTE4
    ,       INDUSTRY_ATTRIBUTE5
    ,       INDUSTRY_ATTRIBUTE6
    ,       INDUSTRY_ATTRIBUTE7
    ,       INDUSTRY_ATTRIBUTE8
    ,       INDUSTRY_ATTRIBUTE9
    ,       INDUSTRY_CONTEXT
    ,       INTMED_SHIP_TO_CONTACT_ID
    ,       INTMED_SHIP_TO_ORG_ID
    ,       INVENTORY_ITEM_ID
    ,       INVOICE_INTERFACE_STATUS_CODE
    ,       INVOICE_TO_CONTACT_ID
    ,       INVOICE_TO_ORG_ID
    ,       INVOICED_QUANTITY
    ,       INVOICING_RULE_ID
    ,       ORDERED_ITEM_ID
    ,       ITEM_IDENTIFIER_TYPE
    ,       ORDERED_ITEM
    ,       ITEM_REVISION
    ,       ITEM_TYPE_CODE
    ,       LAST_ACK_CODE
    ,       LAST_ACK_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LATEST_ACCEPTABLE_DATE
    ,       LINE_CATEGORY_CODE
    ,       LINE_ID
    ,       LINE_NUMBER
    ,       LINE_TYPE_ID
    ,       LINK_TO_LINE_ID
    ,       MODEL_GROUP_NUMBER
  --  ,       MFG_COMPONENT_SEQUENCE_ID
  --  ,       MFG_LEAD_TIME
    ,       OPEN_FLAG
    ,       OPTION_FLAG
    ,       OPTION_NUMBER
    ,       ORDERED_QUANTITY
    ,       ORDERED_QUANTITY2
    ,       ORDER_QUANTITY_UOM
    ,       ORDERED_QUANTITY_UOM2
    ,       ORG_ID
    ,       ORIG_SYS_DOCUMENT_REF
    ,       ORIG_SYS_LINE_REF
    ,       ORIG_SYS_SHIPMENT_REF
    ,       OVER_SHIP_REASON_CODE
    ,       OVER_SHIP_RESOLVED_FLAG
    ,       PAYMENT_TERM_ID
    ,       PLANNING_PRIORITY
    ,       PREFERRED_GRADE
    ,       PRICE_LIST_ID
    ,       PRICE_REQUEST_CODE
    ,       PRICING_ATTRIBUTE1
    ,       PRICING_ATTRIBUTE10
    ,       PRICING_ATTRIBUTE2
    ,       PRICING_ATTRIBUTE3
    ,       PRICING_ATTRIBUTE4
    ,       PRICING_ATTRIBUTE5
    ,       PRICING_ATTRIBUTE6
    ,       PRICING_ATTRIBUTE7
    ,       PRICING_ATTRIBUTE8
    ,       PRICING_ATTRIBUTE9
    ,       PRICING_CONTEXT
    ,       PRICING_DATE
    ,       PRICING_QUANTITY
    ,       PRICING_QUANTITY_UOM
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       PROJECT_ID
    ,       PROMISE_DATE
    ,       RE_SOURCE_FLAG
    ,       REFERENCE_CUSTOMER_TRX_LINE_ID
    ,       REFERENCE_HEADER_ID
    ,       REFERENCE_LINE_ID
    ,       REFERENCE_TYPE
    ,       REQUEST_DATE
    ,       REQUEST_ID
    ,       RETURN_ATTRIBUTE1
    ,       RETURN_ATTRIBUTE10
    ,       RETURN_ATTRIBUTE11
    ,       RETURN_ATTRIBUTE12
    ,       RETURN_ATTRIBUTE13
    ,       RETURN_ATTRIBUTE14
    ,       RETURN_ATTRIBUTE15
    ,       RETURN_ATTRIBUTE2
    ,       RETURN_ATTRIBUTE3
    ,       RETURN_ATTRIBUTE4
    ,       RETURN_ATTRIBUTE5
    ,       RETURN_ATTRIBUTE6
    ,       RETURN_ATTRIBUTE7
    ,       RETURN_ATTRIBUTE8
    ,       RETURN_ATTRIBUTE9
    ,       RETURN_CONTEXT
    ,       RETURN_REASON_CODE
    ,       RLA_SCHEDULE_TYPE_CODE
    ,       SALESREP_ID
    ,       SCHEDULE_ARRIVAL_DATE
    ,       SCHEDULE_SHIP_DATE
    ,       SCHEDULE_STATUS_CODE
    ,       SHIPMENT_NUMBER
    ,       SHIPMENT_PRIORITY_CODE
    ,       SHIPPED_QUANTITY
    ,       SHIPPED_QUANTITY2
    ,       SHIPPING_METHOD_CODE
    ,       SHIPPING_QUANTITY
    ,       SHIPPING_QUANTITY2
    ,       SHIPPING_QUANTITY_UOM
    ,       SHIP_FROM_ORG_ID
    ,       SUBINVENTORY
    ,       SHIP_SET_ID
    ,       SHIP_TOLERANCE_ABOVE
    ,       SHIP_TOLERANCE_BELOW
    ,       SHIPPABLE_FLAG
    ,       SHIPPING_INTERFACED_FLAG
    ,       SHIP_TO_CONTACT_ID
    ,       SHIP_TO_ORG_ID
    ,       SHIP_MODEL_COMPLETE_FLAG
    ,       SOLD_TO_ORG_ID
    ,       SOLD_FROM_ORG_ID
    ,       SORT_ORDER
    ,       SOURCE_DOCUMENT_ID
    ,       SOURCE_DOCUMENT_LINE_ID
    ,       SOURCE_DOCUMENT_TYPE_ID
    ,       SOURCE_TYPE_CODE
    ,       SPLIT_FROM_LINE_ID
    ,       LINE_SET_ID
    ,       SPLIT_BY
    ,       MODEL_REMNANT_FLAG
    ,       TASK_ID
    ,       TAX_CODE
    ,       TAX_DATE
    ,       TAX_EXEMPT_FLAG
    ,       TAX_EXEMPT_NUMBER
    ,       TAX_EXEMPT_REASON_CODE
    ,       TAX_POINT_CODE
    ,       TAX_RATE
    ,       TAX_VALUE
    ,       TOP_MODEL_LINE_ID
    ,       UNIT_LIST_PRICE
    ,       UNIT_LIST_PRICE_PER_PQTY
    ,       UNIT_SELLING_PRICE
    ,       UNIT_SELLING_PRICE_PER_PQTY
    ,       VISIBLE_DEMAND_FLAG
    ,       VEH_CUS_ITEM_CUM_KEY_ID
    ,       SHIPPING_INSTRUCTIONS
    ,       PACKING_INSTRUCTIONS
    ,       SERVICE_TXN_REASON_CODE
    ,       SERVICE_TXN_COMMENTS
    ,       SERVICE_DURATION
    ,       SERVICE_PERIOD
    ,       SERVICE_START_DATE
    ,       SERVICE_END_DATE
    ,       SERVICE_COTERMINATE_FLAG
    ,       UNIT_LIST_PERCENT
    ,       UNIT_SELLING_PERCENT
    ,       UNIT_PERCENT_BASE_PRICE
    ,       SERVICE_NUMBER
    ,       SERVICE_REFERENCE_TYPE_CODE
    ,       SERVICE_REFERENCE_LINE_ID
    ,       SERVICE_REFERENCE_SYSTEM_ID
    ,       TP_CONTEXT
    ,       TP_ATTRIBUTE1
    ,       TP_ATTRIBUTE2
    ,       TP_ATTRIBUTE3
    ,       TP_ATTRIBUTE4
    ,       TP_ATTRIBUTE5
    ,       TP_ATTRIBUTE6
    ,       TP_ATTRIBUTE7
    ,       TP_ATTRIBUTE8
    ,       TP_ATTRIBUTE9
    ,       TP_ATTRIBUTE10
    ,       TP_ATTRIBUTE11
    ,       TP_ATTRIBUTE12
    ,       TP_ATTRIBUTE13
    ,       TP_ATTRIBUTE14
    ,       TP_ATTRIBUTE15
    ,       FLOW_STATUS_CODE
--    ,       MARKETING_SOURCE_CODE_ID
    ,       CALCULATE_PRICE_FLAG
    ,       COMMITMENT_ID
    ,       ORDER_SOURCE_ID
  --  ,       UPGRADED_FLAG
    ,       ORIGINAL_INVENTORY_ITEM_ID
    ,       ORIGINAL_ITEM_IDENTIFIER_TYPE
    ,       ORIGINAL_ORDERED_ITEM_ID
    ,       ORIGINAL_ORDERED_ITEM
    ,       ITEM_RELATIONSHIP_TYPE
    ,       ITEM_SUBSTITUTION_TYPE_CODE
    ,       LATE_DEMAND_PENALTY_FACTOR
    ,       OVERRIDE_ATP_DATE_CODE
 --   ,       FIRM_DEMAND_FLAG
--    ,       EARLIEST_SHIP_DATE
    ,       USER_ITEM_DESCRIPTION
    ,       BLANKET_NUMBER
    ,       BLANKET_LINE_NUMBER
    ,       BLANKET_VERSION_NUMBER
  --  ,       UNIT_COST
  --  ,       LOCK_CONTROL
    ,       NVL(OPTION_NUMBER, -1)
    ,       NVL(COMPONENT_NUMBER, -1)
    ,       NVL(SERVICE_NUMBER, -1)
    ,       CHANGE_SEQUENCE
    ,       transaction_phase_code
    ,      source_document_version_number
    INTO x_line_rec.ACCOUNTING_RULE_ID
    ,x_line_rec.ACCOUNTING_RULE_DURATION
    ,x_line_rec.ACTUAL_ARRIVAL_DATE
    ,x_line_rec.ACTUAL_SHIPMENT_DATE
    ,x_line_rec.AGREEMENT_ID
    ,x_line_rec.ARRIVAL_SET_ID
    ,x_line_rec.ATO_LINE_ID
    ,x_line_rec.ATTRIBUTE1
    ,x_line_rec.ATTRIBUTE10
    ,x_line_rec.ATTRIBUTE11
    ,x_line_rec.ATTRIBUTE12
    ,x_line_rec.ATTRIBUTE13
    ,x_line_rec.ATTRIBUTE14
    ,x_line_rec.ATTRIBUTE15
    ,x_line_rec.ATTRIBUTE16
    ,x_line_rec.ATTRIBUTE17
    ,x_line_rec.ATTRIBUTE18
    ,x_line_rec.ATTRIBUTE19
    ,x_line_rec.ATTRIBUTE2
    ,x_line_rec.ATTRIBUTE20
    ,x_line_rec.ATTRIBUTE3
    ,x_line_rec.ATTRIBUTE4
    ,x_line_rec.ATTRIBUTE5
    ,x_line_rec.ATTRIBUTE6
    ,x_line_rec.ATTRIBUTE7
    ,x_line_rec.ATTRIBUTE8
    ,x_line_rec.ATTRIBUTE9
    ,x_line_rec.AUTO_SELECTED_QUANTITY
    ,x_line_rec.AUTHORIZED_TO_SHIP_FLAG
    ,x_line_rec.BOOKED_FLAG
    ,x_line_rec.CANCELLED_FLAG
    ,x_line_rec.CANCELLED_QUANTITY
    ,x_line_rec.COMPONENT_CODE
    ,x_line_rec.COMPONENT_NUMBER
    ,x_line_rec.COMPONENT_SEQUENCE_ID
    ,x_line_rec.CONFIG_HEADER_ID
    ,x_line_rec.CONFIG_REV_NBR
    ,x_line_rec.CONFIG_DISPLAY_SEQUENCE
    ,x_line_rec.CONFIGURATION_ID
    ,x_line_rec.CONTEXT
    ,x_line_rec.CREATED_BY
    ,x_line_rec.CREATION_DATE
    ,x_line_rec.CREDIT_INVOICE_LINE_ID
    ,x_line_rec.CUSTOMER_DOCK_CODE
    ,x_line_rec.CUSTOMER_JOB
    ,x_line_rec.CUSTOMER_PRODUCTION_LINE
    ,x_line_rec.CUST_PRODUCTION_SEQ_NUM
    ,x_line_rec.CUSTOMER_TRX_LINE_ID
    ,x_line_rec.CUST_MODEL_SERIAL_NUMBER
    ,x_line_rec.CUST_PO_NUMBER
    ,x_line_rec.CUSTOMER_LINE_NUMBER
    ,x_line_rec.DELIVERY_LEAD_TIME
    ,x_line_rec.DELIVER_TO_CONTACT_ID
    ,x_line_rec.DELIVER_TO_ORG_ID
    ,x_line_rec.DEMAND_BUCKET_TYPE_CODE
    ,x_line_rec.DEMAND_CLASS_CODE
    ,x_line_rec.DEP_PLAN_REQUIRED_FLAG
    ,x_line_rec.EARLIEST_ACCEPTABLE_DATE
    ,x_line_rec.END_ITEM_UNIT_NUMBER
    ,x_line_rec.EXPLOSION_DATE
    ,x_line_rec.FIRST_ACK_CODE
    ,x_line_rec.FIRST_ACK_DATE
    ,x_line_rec.FOB_POINT_CODE
    ,x_line_rec.FREIGHT_CARRIER_CODE
    ,x_line_rec.FREIGHT_TERMS_CODE
    ,x_line_rec.FULFILLED_QUANTITY
    ,x_line_rec.FULFILLED_FLAG
    ,x_line_rec.FULFILLMENT_METHOD_CODE
    ,x_line_rec.FULFILLMENT_DATE
    ,x_line_rec.GLOBAL_ATTRIBUTE1
    ,x_line_rec.GLOBAL_ATTRIBUTE10
    ,x_line_rec.GLOBAL_ATTRIBUTE11
    ,x_line_rec.GLOBAL_ATTRIBUTE12
    ,x_line_rec.GLOBAL_ATTRIBUTE13
    ,x_line_rec.GLOBAL_ATTRIBUTE14
    ,x_line_rec.GLOBAL_ATTRIBUTE15
    ,x_line_rec.GLOBAL_ATTRIBUTE16
    ,x_line_rec.GLOBAL_ATTRIBUTE17
    ,x_line_rec.GLOBAL_ATTRIBUTE18
    ,x_line_rec.GLOBAL_ATTRIBUTE19
    ,x_line_rec.GLOBAL_ATTRIBUTE2
    ,x_line_rec.GLOBAL_ATTRIBUTE20
    ,x_line_rec.GLOBAL_ATTRIBUTE3
    ,x_line_rec.GLOBAL_ATTRIBUTE4
    ,x_line_rec.GLOBAL_ATTRIBUTE5
    ,x_line_rec.GLOBAL_ATTRIBUTE6
    ,x_line_rec.GLOBAL_ATTRIBUTE7
    ,x_line_rec.GLOBAL_ATTRIBUTE8
    ,x_line_rec.GLOBAL_ATTRIBUTE9
    ,x_line_rec.GLOBAL_ATTRIBUTE_CATEGORY
    ,x_line_rec.HEADER_ID
    ,x_line_rec.INDUSTRY_ATTRIBUTE1
    ,x_line_rec.INDUSTRY_ATTRIBUTE10
    ,x_line_rec.INDUSTRY_ATTRIBUTE11
    ,x_line_rec.INDUSTRY_ATTRIBUTE12
    ,x_line_rec.INDUSTRY_ATTRIBUTE13
    ,x_line_rec.INDUSTRY_ATTRIBUTE14
    ,x_line_rec.INDUSTRY_ATTRIBUTE15
    ,x_line_rec.INDUSTRY_ATTRIBUTE16
    ,x_line_rec.INDUSTRY_ATTRIBUTE17
    ,x_line_rec.INDUSTRY_ATTRIBUTE18
    ,x_line_rec.INDUSTRY_ATTRIBUTE19
    ,x_line_rec.INDUSTRY_ATTRIBUTE20
    ,x_line_rec.INDUSTRY_ATTRIBUTE21
    ,x_line_rec.INDUSTRY_ATTRIBUTE22
    ,x_line_rec.INDUSTRY_ATTRIBUTE23
    ,x_line_rec.INDUSTRY_ATTRIBUTE24
    ,x_line_rec.INDUSTRY_ATTRIBUTE25
    ,x_line_rec.INDUSTRY_ATTRIBUTE26
    ,x_line_rec.INDUSTRY_ATTRIBUTE27
    ,x_line_rec.INDUSTRY_ATTRIBUTE28
    ,x_line_rec.INDUSTRY_ATTRIBUTE29
    ,x_line_rec.INDUSTRY_ATTRIBUTE30
    ,x_line_rec.INDUSTRY_ATTRIBUTE2
    ,x_line_rec.INDUSTRY_ATTRIBUTE3
    ,x_line_rec.INDUSTRY_ATTRIBUTE4
    ,x_line_rec.INDUSTRY_ATTRIBUTE5
    ,x_line_rec.INDUSTRY_ATTRIBUTE6
    ,x_line_rec.INDUSTRY_ATTRIBUTE7
    ,x_line_rec.INDUSTRY_ATTRIBUTE8
    ,x_line_rec.INDUSTRY_ATTRIBUTE9
    ,x_line_rec.INDUSTRY_CONTEXT
    ,x_line_rec.INTerMED_SHIP_TO_CONTACT_ID
    ,x_line_rec.INTerMED_SHIP_TO_ORG_ID
    ,x_line_rec.INVENTORY_ITEM_ID
    ,x_line_rec.INVOICE_INTERFACE_STATUS_CODE
    ,x_line_rec.INVOICE_TO_CONTACT_ID
    ,x_line_rec.INVOICE_TO_ORG_ID
    ,x_line_rec.INVOICED_QUANTITY
    ,x_line_rec.INVOICING_RULE_ID
    ,x_line_rec.ORDERED_ITEM_ID
    ,x_line_rec.ITEM_IDENTIFIER_TYPE
    ,x_line_rec.ORDERED_ITEM
    ,x_line_rec.ITEM_REVISION
    ,x_line_rec.ITEM_TYPE_CODE
    ,x_line_rec.LAST_ACK_CODE
    ,x_line_rec.LAST_ACK_DATE
    ,x_line_rec.LAST_UPDATED_BY
    ,x_line_rec.LAST_UPDATE_DATE
    ,x_line_rec.LAST_UPDATE_LOGIN
    ,x_line_rec.LATEST_ACCEPTABLE_DATE
    ,x_line_rec.LINE_CATEGORY_CODE
    ,x_line_rec.LINE_ID
    ,x_line_rec.LINE_NUMBER
    ,x_line_rec.LINE_TYPE_ID
    ,x_line_rec.LINK_TO_LINE_ID
    ,x_line_rec.MODEL_GROUP_NUMBER
  --  ,x_line_rec.MFG_COMPONENT_SEQUENCE_ID
  --  ,x_line_rec.MFG_LEAD_TIME
    ,x_line_rec.OPEN_FLAG
    ,x_line_rec.OPTION_FLAG
    ,x_line_rec.OPTION_NUMBER
    ,x_line_rec.ORDERED_QUANTITY
    ,x_line_rec.ORDERED_QUANTITY2
    ,x_line_rec.ORDER_QUANTITY_UOM
    ,x_line_rec.ORDERED_QUANTITY_UOM2
    ,x_line_rec.ORG_ID
    ,x_line_rec.ORIG_SYS_DOCUMENT_REF
    ,x_line_rec.ORIG_SYS_LINE_REF
    ,x_line_rec.ORIG_SYS_SHIPMENT_REF
    ,x_line_rec.OVER_SHIP_REASON_CODE
    ,x_line_rec.OVER_SHIP_RESOLVED_FLAG
    ,x_line_rec.PAYMENT_TERM_ID
    ,x_line_rec.PLANNING_PRIORITY
    ,x_line_rec.PREFERRED_GRADE
    ,x_line_rec.PRICE_LIST_ID
    ,x_line_rec.PRICE_REQUEST_CODE
    ,x_line_rec.PRICING_ATTRIBUTE1
    ,x_line_rec.PRICING_ATTRIBUTE10
    ,x_line_rec.PRICING_ATTRIBUTE2
    ,x_line_rec.PRICING_ATTRIBUTE3
    ,x_line_rec.PRICING_ATTRIBUTE4
    ,x_line_rec.PRICING_ATTRIBUTE5
    ,x_line_rec.PRICING_ATTRIBUTE6
    ,x_line_rec.PRICING_ATTRIBUTE7
    ,x_line_rec.PRICING_ATTRIBUTE8
    ,x_line_rec.PRICING_ATTRIBUTE9
    ,x_line_rec.PRICING_CONTEXT
    ,x_line_rec.PRICING_DATE
    ,x_line_rec.PRICING_QUANTITY
    ,x_line_rec.PRICING_QUANTITY_UOM
    ,x_line_rec.PROGRAM_APPLICATION_ID
    ,x_line_rec.PROGRAM_ID
    ,x_line_rec.PROGRAM_UPDATE_DATE
    ,x_line_rec.PROJECT_ID
    ,x_line_rec.PROMISE_DATE
    ,x_line_rec.RE_SOURCE_FLAG
    ,x_line_rec.REFERENCE_CUSTOMER_TRX_LINE_ID
    ,x_line_rec.REFERENCE_HEADER_ID
    ,x_line_rec.REFERENCE_LINE_ID
    ,x_line_rec.REFERENCE_TYPE
    ,x_line_rec.REQUEST_DATE
    ,x_line_rec.REQUEST_ID
    ,x_line_rec.RETURN_ATTRIBUTE1
    ,x_line_rec.RETURN_ATTRIBUTE10
    ,x_line_rec.RETURN_ATTRIBUTE11
    ,x_line_rec.RETURN_ATTRIBUTE12
    ,x_line_rec.RETURN_ATTRIBUTE13
    ,x_line_rec.RETURN_ATTRIBUTE14
    ,x_line_rec.RETURN_ATTRIBUTE15
    ,x_line_rec.RETURN_ATTRIBUTE2
    ,x_line_rec.RETURN_ATTRIBUTE3
    ,x_line_rec.RETURN_ATTRIBUTE4
    ,x_line_rec.RETURN_ATTRIBUTE5
    ,x_line_rec.RETURN_ATTRIBUTE6
    ,x_line_rec.RETURN_ATTRIBUTE7
    ,x_line_rec.RETURN_ATTRIBUTE8
    ,x_line_rec.RETURN_ATTRIBUTE9
    ,x_line_rec.RETURN_CONTEXT
    ,x_line_rec.RETURN_REASON_CODE
    ,x_line_rec.RLA_SCHEDULE_TYPE_CODE
    ,x_line_rec.SALESREP_ID
    ,x_line_rec.SCHEDULE_ARRIVAL_DATE
    ,x_line_rec.SCHEDULE_SHIP_DATE
    ,x_line_rec.SCHEDULE_STATUS_CODE
    ,x_line_rec.SHIPMENT_NUMBER
    ,x_line_rec.SHIPMENT_PRIORITY_CODE
    ,x_line_rec.SHIPPED_QUANTITY
    ,x_line_rec.SHIPPED_QUANTITY2
    ,x_line_rec.SHIPPING_METHOD_CODE
    ,x_line_rec.SHIPPING_QUANTITY
    ,x_line_rec.SHIPPING_QUANTITY2
    ,x_line_rec.SHIPPING_QUANTITY_UOM
    ,x_line_rec.SHIP_FROM_ORG_ID
    ,x_line_rec.SUBINVENTORY
    ,x_line_rec.SHIP_SET_ID
    ,x_line_rec.SHIP_TOLERANCE_ABOVE
    ,x_line_rec.SHIP_TOLERANCE_BELOW
    ,x_line_rec.SHIPPABLE_FLAG
    ,x_line_rec.SHIPPING_INTERFACED_FLAG
    ,x_line_rec.SHIP_TO_CONTACT_ID
    ,x_line_rec.SHIP_TO_ORG_ID
    ,x_line_rec.SHIP_MODEL_COMPLETE_FLAG
    ,x_line_rec.SOLD_TO_ORG_ID
    ,x_line_rec.SOLD_FROM_ORG_ID
    ,x_line_rec.SORT_ORDER
    ,x_line_rec.SOURCE_DOCUMENT_ID
    ,x_line_rec.SOURCE_DOCUMENT_LINE_ID
    ,x_line_rec.SOURCE_DOCUMENT_TYPE_ID
    ,x_line_rec.SOURCE_TYPE_CODE
    ,x_line_rec.SPLIT_FROM_LINE_ID
    ,x_line_rec.LINE_SET_ID
    ,x_line_rec.SPLIT_BY
    ,x_line_rec.MODEL_REMNANT_FLAG
    ,x_line_rec.TASK_ID
    ,x_line_rec.TAX_CODE
    ,x_line_rec.TAX_DATE
    ,x_line_rec.TAX_EXEMPT_FLAG
    ,x_line_rec.TAX_EXEMPT_NUMBER
    ,x_line_rec.TAX_EXEMPT_REASON_CODE
    ,x_line_rec.TAX_POINT_CODE
    ,x_line_rec.TAX_RATE
    ,x_line_rec.TAX_VALUE
    ,x_line_rec.TOP_MODEL_LINE_ID
    ,x_line_rec.UNIT_LIST_PRICE
    ,x_line_rec.UNIT_LIST_PRICE_PER_PQTY
    ,x_line_rec.UNIT_SELLING_PRICE
    ,x_line_rec.UNIT_SELLING_PRICE_PER_PQTY
    ,x_line_rec.VISIBLE_DEMAND_FLAG
    ,x_line_rec.VEH_CUS_ITEM_CUM_KEY_ID
    ,x_line_rec.SHIPPING_INSTRUCTIONS
    ,x_line_rec.PACKING_INSTRUCTIONS
    ,x_line_rec.SERVICE_TXN_REASON_CODE
    ,x_line_rec.SERVICE_TXN_COMMENTS
    ,x_line_rec.SERVICE_DURATION
    ,x_line_rec.SERVICE_PERIOD
    ,x_line_rec.SERVICE_START_DATE
    ,x_line_rec.SERVICE_END_DATE
    ,x_line_rec.SERVICE_COTERMINATE_FLAG
    ,x_line_rec.UNIT_LIST_PERCENT
    ,x_line_rec.UNIT_SELLING_PERCENT
    ,x_line_rec.UNIT_PERCENT_BASE_PRICE
    ,x_line_rec.SERVICE_NUMBER
    ,x_line_rec.SERVICE_REFERENCE_TYPE_CODE
    ,x_line_rec.SERVICE_REFERENCE_LINE_ID
    ,x_line_rec.SERVICE_REFERENCE_SYSTEM_ID
    ,x_line_rec.TP_CONTEXT
    ,x_line_rec.TP_ATTRIBUTE1
    ,x_line_rec.TP_ATTRIBUTE2
    ,x_line_rec.TP_ATTRIBUTE3
    ,x_line_rec.TP_ATTRIBUTE4
    ,x_line_rec.TP_ATTRIBUTE5
    ,x_line_rec.TP_ATTRIBUTE6
    ,x_line_rec.TP_ATTRIBUTE7
    ,x_line_rec.TP_ATTRIBUTE8
    ,x_line_rec.TP_ATTRIBUTE9
    ,x_line_rec.TP_ATTRIBUTE10
    ,x_line_rec.TP_ATTRIBUTE11
    ,x_line_rec.TP_ATTRIBUTE12
    ,x_line_rec.TP_ATTRIBUTE13
    ,x_line_rec.TP_ATTRIBUTE14
    ,x_line_rec.TP_ATTRIBUTE15
    ,x_line_rec.FLOW_STATUS_CODE
--    ,x_line_rec.MARKETING_SOURCE_CODE_ID
    ,x_line_rec.CALCULATE_PRICE_FLAG
    ,x_line_rec.COMMITMENT_ID
    ,x_line_rec.ORDER_SOURCE_ID
    --,x_line_rec.UPGRADED_FLAG
    ,x_line_rec.ORIGINAL_INVENTORY_ITEM_ID
    ,x_line_rec.ORIGINAL_ITEM_IDENTIFIER_TYPE
    ,x_line_rec.ORIGINAL_ORDERED_ITEM_ID
    ,x_line_rec.ORIGINAL_ORDERED_ITEM
    ,x_line_rec.ITEM_RELATIONSHIP_TYPE
    ,x_line_rec.ITEM_SUBSTITUTION_TYPE_CODE
    ,x_line_rec.LATE_DEMAND_PENALTY_FACTOR
    ,x_line_rec.OVERRIDE_ATP_DATE_CODE
   -- ,x_line_rec.FIRM_DEMAND_FLAG
   -- ,x_line_rec.EARLIEST_SHIP_DATE
    ,x_line_rec.USER_ITEM_DESCRIPTION
    ,x_line_rec.BLANKET_NUMBER
    ,x_line_rec.BLANKET_LINE_NUMBER
    ,x_line_rec.BLANKET_VERSION_NUMBER
   -- ,x_line_rec.UNIT_COST
   -- ,x_line_rec.LOCK_CONTROL
    ,x_line_rec.OPTION_NUMBER
    ,x_line_rec.COMPONENT_NUMBER
    ,x_line_rec.SERVICE_NUMBER
    ,x_line_rec.CHANGE_SEQUENCE
    ,x_line_rec.transaction_phase_code
    ,x_line_rec.source_document_version_number
    FROM    OE_ORDER_LINES
    WHERE LINE_ID = p_line_id
--    and version_number = p_version
    and header_id=p_header_id;
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

PROCEDURE COMPARE_LINE_ATTRIBUTES
(p_header_id                      NUMBER,
 p_line_id                        NUMBER,
 p_prior_version                  NUMBER,
 p_current_version                NUMBER,
 p_next_version                   NUMBER,
 g_max_version                    NUMBER,
 g_trans_version                  NUMBER,
 g_prior_phase_change_flag	  VARCHAR2,
 g_curr_phase_change_flag	  VARCHAR2,
 g_next_phase_change_flag	  VARCHAR2,
 x_line_changed_attr_tbl          IN OUT NOCOPY OE_VERSION_COMP.line_tbl_type,
 p_total_lines                    NUMBER,
 x_line_number                    VARCHAR2)
IS
p_curr_rec                      OE_Order_PUB.line_rec_type;
p_next_rec                      OE_Order_PUB.line_rec_type;
p_prior_rec                     OE_Order_PUB.line_rec_type;

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
x_prior_intermed_address           VARCHAR2(2000);
x_current_intermed_address           VARCHAR2(2000);
x_next_intermed_address           VARCHAR2(2000);
x_prior_item_rel_type             VARCHAR2(240);
x_current_item_rel_type             VARCHAR2(240);
x_next_item_rel_type             VARCHAR2(240);

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
p_prior_rec_exists VARCHAR2(1) := 'N';
p_curr_rec_exists VARCHAR2(1)  := 'N';
p_next_rec_exists VARCHAR2(1)  := 'N';
p_trans_rec_exists VARCHAR2(1)  := 'N';
ind NUMBER;
BEGIN

IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering  Compare_line_attributes');
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
/***************************************/
IF p_prior_version IS NOT NULL THEN
OE_VERSION_COMP.QUERY_LINE_ROW(p_header_id       => p_header_id,
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
OE_VERSION_COMP.QUERY_LINE_ROW(p_header_id       => p_header_id,
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
       OE_VERSION_COMP.QUERY_LINE_TRANS_ROW(p_header_id       => p_header_id,
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
OE_VERSION_COMP.QUERY_LINE_ROW(p_header_id       => p_header_id,
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


--select oe_order_misc_pub.get_concat_line_number(l_line_id) into x_line_number from dual;

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
   x_line_changed_attr_tbl(ind).line_number := '1.1';
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
/* START accounting_rule_duration*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.accounting_rule_duration,
       p_prior_rec.accounting_rule_duration) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'accounting_rule_duration';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.accounting_rule_duration;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.accounting_rule_duration;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.accounting_rule_duration,
       p_next_rec.accounting_rule_duration) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.accounting_rule_duration;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'accounting_rule_duration';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.accounting_rule_duration;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.accounting_rule_duration;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.accounting_rule_duration;
END IF;
END IF; /*  NEXT */

/* END accounting_rule_duration*/
/****************************/

/****************************/
/* START ACTUAL_ARRIVAL_DATE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ACTUAL_ARRIVAL_DATE,
       p_prior_rec.ACTUAL_ARRIVAL_DATE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'ACTUAL_ARRIVAL_DATE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.ACTUAL_ARRIVAL_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.ACTUAL_ARRIVAL_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ACTUAL_ARRIVAL_DATE,
       p_next_rec.ACTUAL_ARRIVAL_DATE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.ACTUAL_ARRIVAL_DATE,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'ACTUAL_ARRIVAL_DATE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.ACTUAL_ARRIVAL_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.ACTUAL_ARRIVAL_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.ACTUAL_ARRIVAL_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  NEXT */

/* END ACTUAL_ARRIVAL_DATE*/
/****************************/

/****************************/
/* START ACTUAL_SHIPMENT_DATE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ACTUAL_SHIPMENT_DATE,
       p_prior_rec.ACTUAL_SHIPMENT_DATE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'ACTUAL_SHIPMENT_DATE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.ACTUAL_SHIPMENT_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.ACTUAL_SHIPMENT_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ACTUAL_SHIPMENT_DATE,
       p_next_rec.ACTUAL_SHIPMENT_DATE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.ACTUAL_SHIPMENT_DATE,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'ACTUAL_SHIPMENT_DATE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.ACTUAL_SHIPMENT_DATE;
   x_line_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.ACTUAL_SHIPMENT_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.ACTUAL_SHIPMENT_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  NEXT */

/* END ACTUAL_SHIPMENT_DATE*/
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
/* START ARRIVAL_SET_ID*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ARRIVAL_SET_ID,
       p_prior_rec.ARRIVAL_SET_ID) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'ARRIVAL_SET';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.ARRIVAL_SET_ID;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.ARRIVAL_SET_ID;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ARRIVAL_SET_ID,
       p_next_rec.ARRIVAL_SET_ID) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.ARRIVAL_SET_ID;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'ARRIVAL_SET';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.ARRIVAL_SET_ID;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.ARRIVAL_SET_ID;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.ARRIVAL_SET_ID;
END IF;
END IF; /*  NEXT */

/* END ARRIVAL_SET_ID*/
/****************************/

/****************************/
/* START ATO_LINE_ID*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ATO_LINE_ID,
       p_prior_rec.ATO_LINE_ID) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'ATO';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.ATO_LINE_ID;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.ATO_LINE_ID;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ATO_LINE_ID,
       p_next_rec.ATO_LINE_ID) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.ATO_LINE_ID;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'ATO';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.ATO_LINE_ID;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.ATO_LINE_ID;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.ATO_LINE_ID;
END IF;
END IF; /*  NEXT */

/* END ATO_LINE_ID*/
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
/* START attribute16*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute16,
       p_prior_rec.attribute16) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute16';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute16;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute16;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute16,
       p_next_rec.attribute16) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute16;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute16';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute16;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute16;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.attribute16;
END IF;
END IF; /*  NEXT */

/* END attribute16*/
/****************************/

/****************************/
/* START attribute17*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute17,
       p_prior_rec.attribute17) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute17';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute17;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute17;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute17,
       p_next_rec.attribute17) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute17;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute17';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute17;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute17;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.attribute17;
END IF;
END IF; /*  NEXT */

/* END attribute17*/
/****************************/

/****************************/
/* START attribute18*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute18,
       p_prior_rec.attribute18) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute18';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute18;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute18;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute18,
       p_next_rec.attribute18) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute18;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute18';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute18;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute18;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.attribute18;
END IF;
END IF; /*  NEXT */

/* END attribute18*/
/****************************/

/****************************/
/* START attribute19*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute19,
       p_prior_rec.attribute19) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute19';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute19;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute19;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute19,
       p_next_rec.attribute19) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute19;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute19';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute19;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute19;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.attribute19;
END IF;
END IF; /*  NEXT */

/* END attribute19*/
/****************************/

/****************************/
/* START attribute20*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute20,
       p_prior_rec.attribute20) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute20';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute20;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute20;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute20,
       p_next_rec.attribute20) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.attribute20;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute20';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute20;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute20;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.attribute20;
END IF;
END IF; /*  NEXT */

/* END attribute20*/
/****************************/

/****************************/
/* START AUTO_SELECTED_QUANTITY*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.AUTO_SELECTED_QUANTITY,
       p_prior_rec.AUTO_SELECTED_QUANTITY) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'AUTO_SELECTED_QUANTITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.AUTO_SELECTED_QUANTITY;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.AUTO_SELECTED_QUANTITY;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.AUTO_SELECTED_QUANTITY,
       p_next_rec.AUTO_SELECTED_QUANTITY) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.AUTO_SELECTED_QUANTITY;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'AUTO_SELECTED_QUANTITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.AUTO_SELECTED_QUANTITY;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.AUTO_SELECTED_QUANTITY;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.AUTO_SELECTED_QUANTITY;
END IF;
END IF; /*  NEXT */

/* END AUTO_SELECTED_QUANTITY*/
/****************************/

/****************************/
/* START AUTHORIZED_TO_SHIP_FLAG*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.AUTHORIZED_TO_SHIP_FLAG,
       p_prior_rec.AUTHORIZED_TO_SHIP_FLAG) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'AUTHORIZED_TO_SHIP_FLAG';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.AUTHORIZED_TO_SHIP_FLAG;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.AUTHORIZED_TO_SHIP_FLAG;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.AUTHORIZED_TO_SHIP_FLAG,
       p_next_rec.AUTHORIZED_TO_SHIP_FLAG) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.AUTHORIZED_TO_SHIP_FLAG;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'AUTHORIZED_TO_SHIP_FLAG';
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.AUTHORIZED_TO_SHIP_FLAG;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.AUTHORIZED_TO_SHIP_FLAG;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.AUTHORIZED_TO_SHIP_FLAG;
END IF; /*  NEXT */
END IF;

/* END AUTHORIZED_TO_SHIP_FLAG*/
/****************************/
/****************************/
/* START blanket_number*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.blanket_number,
       p_prior_rec.blanket_number) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'blanket_number';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.blanket_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.blanket_number;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.blanket_number,
       p_next_rec.blanket_number) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.blanket_number;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'blanket_number';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.blanket_number;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.blanket_number;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.blanket_number;
END IF;
END IF; /*  NEXT */

/* END blanket_number*/
/****************************/


/****************************/
/* START CANCELLED_QUANTITY*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CANCELLED_QUANTITY,
       p_prior_rec.CANCELLED_QUANTITY) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'CANCELLED_QUANTITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.CANCELLED_QUANTITY;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.CANCELLED_QUANTITY;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CANCELLED_QUANTITY,
       p_next_rec.CANCELLED_QUANTITY) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.CANCELLED_QUANTITY;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'CANCELLED_QUANTITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.CANCELLED_QUANTITY;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.CANCELLED_QUANTITY;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.CANCELLED_QUANTITY;
END IF;
END IF; /*  NEXT */

/* END CANCELLED_QUANTITY*/
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
/* START CUSTOMER_DOCK_CODE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CUSTOMER_DOCK_CODE,
       p_prior_rec.CUSTOMER_DOCK_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'CUSTOMER_DOCK_CODE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.CUSTOMER_DOCK_CODE;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.CUSTOMER_DOCK_CODE;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CUSTOMER_DOCK_CODE,
       p_next_rec.CUSTOMER_DOCK_CODE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.CUSTOMER_DOCK_CODE;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'CUSTOMER_DOCK_CODE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.CUSTOMER_DOCK_CODE;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.CUSTOMER_DOCK_CODE;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.CUSTOMER_DOCK_CODE;
END IF;
END IF; /*  NEXT */

/* END CUSTOMER_DOCK_CODE*/
/****************************/

/****************************/
/* START CUSTOMER_JOB*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CUSTOMER_JOB,
       p_prior_rec.CUSTOMER_JOB) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'CUSTOMER_JOB';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.CUSTOMER_JOB;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.CUSTOMER_JOB;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CUSTOMER_JOB,
       p_next_rec.CUSTOMER_JOB) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.CUSTOMER_JOB;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'CUSTOMER_JOB';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.CUSTOMER_JOB;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.CUSTOMER_JOB;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.CUSTOMER_JOB;
END IF;
END IF; /*  NEXT */

/* END CUSTOMER_JOB*/
/****************************/

/****************************/
/* START CUSTOMER_PRODUCTION_LINE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CUSTOMER_PRODUCTION_LINE,
       p_prior_rec.CUSTOMER_PRODUCTION_LINE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'CUSTOMER_PRODUCTION_LINE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.CUSTOMER_PRODUCTION_LINE;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.CUSTOMER_PRODUCTION_LINE;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CUSTOMER_PRODUCTION_LINE,
       p_next_rec.CUSTOMER_PRODUCTION_LINE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.CUSTOMER_PRODUCTION_LINE;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'CUSTOMER_PRODUCTION_LINE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.CUSTOMER_PRODUCTION_LINE;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.CUSTOMER_PRODUCTION_LINE;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.CUSTOMER_PRODUCTION_LINE;
END IF;
END IF; /*  NEXT */

/* END custOMER_PRODUCTION_LINE*/
/****************************/
/****************************/
/* START CUST_PRODUCTION_SEQ_NUM*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CUST_PRODUCTION_SEQ_NUM,
       p_prior_rec.CUST_PRODUCTION_SEQ_NUM) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'CUST_PRODUCTION_SEQ_NUM';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.CUST_PRODUCTION_SEQ_NUM;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.CUST_PRODUCTION_SEQ_NUM;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CUST_PRODUCTION_SEQ_NUM,
       p_next_rec.CUST_PRODUCTION_SEQ_NUM) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.CUST_PRODUCTION_SEQ_NUM;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'CUST_PRODUCTION_SEQ_NUM';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.CUST_PRODUCTION_SEQ_NUM;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.CUST_PRODUCTION_SEQ_NUM;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.CUST_PRODUCTION_SEQ_NUM;
END IF;
END IF; /*  NEXT */

/* END CUST_PRODUCTION_SEQ_NUM*/
/****************************/

/****************************/
/* START CUST_MODEL_SERIAL_NUMBER*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CUST_MODEL_SERIAL_NUMBER,
       p_prior_rec.CUST_MODEL_SERIAL_NUMBER) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'CUST_MODEL_SERIAL_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.CUST_MODEL_SERIAL_NUMBER;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.CUST_MODEL_SERIAL_NUMBER;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CUST_MODEL_SERIAL_NUMBER,
       p_next_rec.CUST_MODEL_SERIAL_NUMBER) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.CUST_MODEL_SERIAL_NUMBER;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'CUST_MODEL_SERIAL_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.CUST_MODEL_SERIAL_NUMBER;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.CUST_MODEL_SERIAL_NUMBER;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.CUST_MODEL_SERIAL_NUMBER;
END IF;
END IF; /*  NEXT */

/* END CUST_MODEL_SERIAL_NUMBER*/
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
   x_line_changed_attr_tbl(ind).attribute_name := 'cust_po_number';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.cust_po_number;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.cust_po_number;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.cust_po_number;
END IF;
END IF; /*  NEXT */

/* END cust_po_number*/
/****************************/

/****************************/
/* START CUSTOMER_LINE_NUMBER*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CUSTOMER_LINE_NUMBER,
       p_prior_rec.CUSTOMER_LINE_NUMBER) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'CUSTOMER_LINE_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.CUSTOMER_LINE_NUMBER;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.CUSTOMER_LINE_NUMBER;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CUSTOMER_LINE_NUMBER,
       p_next_rec.CUSTOMER_LINE_NUMBER) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.CUSTOMER_LINE_NUMBER;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'CUSTOMER_LINE_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.CUSTOMER_LINE_NUMBER;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.CUSTOMER_LINE_NUMBER;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.CUSTOMER_LINE_NUMBER;
END IF;
END IF; /*  NEXT */

/* END CUSTOMER_LINE_NUMBER*/
/****************************/

/****************************/
/* START DELIVERY_LEAD_TIME*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.DELIVERY_LEAD_TIME,
       p_prior_rec.DELIVERY_LEAD_TIME) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'DELIVERY_LEAD_TIME';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.DELIVERY_LEAD_TIME;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.DELIVERY_LEAD_TIME;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.DELIVERY_LEAD_TIME,
       p_next_rec.DELIVERY_LEAD_TIME) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.DELIVERY_LEAD_TIME;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'DELIVERY_LEAD_TIME';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.DELIVERY_LEAD_TIME;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.DELIVERY_LEAD_TIME;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.DELIVERY_LEAD_TIME;
END IF;
END IF; /*  NEXT */

/* END DELIVERY_LEAD_TIME*/
/****************************/
/****************************/
/* START deliver_to_contact_id*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.deliver_to_contact_id,
       p_prior_rec.deliver_to_contact_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'deliver_to_contact';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.deliver_to_contact_id;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Deliver_To_Contact(p_curr_rec.deliver_to_contact_id);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.deliver_to_contact_id;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Deliver_To_Contact(p_prior_rec.deliver_to_contact_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.deliver_to_contact_id,
       p_next_rec.deliver_to_contact_id) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Deliver_To_Contact(p_curr_rec.deliver_to_contact_id);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'deliver_to_contact';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.deliver_to_contact_id;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Deliver_To_Contact(p_prior_rec.deliver_to_contact_id);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.deliver_to_contact_id;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Deliver_To_Contact(p_curr_rec.deliver_to_contact_id);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.deliver_to_contact_id;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Deliver_To_Contact(p_next_rec.deliver_to_contact_id);
END IF;
END IF; /*  NEXT */

/* END deliver_to_contact_id*/
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
   x_line_changed_attr_tbl(ind).attribute_name  := 'deliver_to_location';
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
    DECODE(x_deliver_to_country, NULL,x_deliver_to_country)
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
    DECODE(x_deliver_to_country, NULL,x_deliver_to_country)
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
   x_line_changed_attr_tbl(ind).attribute_name := 'deliver_to_location';
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
/* START DEMAND_BUCKET_TYPE_CODE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.DEMAND_BUCKET_TYPE_CODE,
       p_prior_rec.DEMAND_BUCKET_TYPE_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'DEMAND_BUCKET_TYPE_CODE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.DEMAND_BUCKET_TYPE_CODE;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Demand_Bucket_Type(p_curr_rec.DEMAND_BUCKET_TYPE_CODE);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.DEMAND_BUCKET_TYPE_CODE;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Demand_Bucket_Type(p_prior_rec.DEMAND_BUCKET_TYPE_CODE);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.DEMAND_BUCKET_TYPE_CODE,
       p_next_rec.DEMAND_BUCKET_TYPE_CODE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Demand_Bucket_Type(p_curr_rec.DEMAND_BUCKET_TYPE_CODE);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'DEMAND_BUCKET_TYPE_CODE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.DEMAND_BUCKET_TYPE_CODE;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Demand_Bucket_Type(p_prior_rec.DEMAND_BUCKET_TYPE_CODE);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.DEMAND_BUCKET_TYPE_CODE;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Demand_Bucket_Type(p_curr_rec.DEMAND_BUCKET_TYPE_CODE);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.DEMAND_BUCKET_TYPE_CODE;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Demand_Bucket_Type(p_next_rec.DEMAND_BUCKET_TYPE_CODE);
END IF; /*  NEXT */
END IF;

/* END DEMAND_BUCKET_TYPE_CODE*/
/****************************/
/****************************/
/* START DEMAND_CLASS_CODE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.DEMAND_CLASS_CODE,
       p_prior_rec.DEMAND_CLASS_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'DEMAND_CLASS';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.DEMAND_CLASS_CODE;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.DEMAND_CLASS_CODE;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.DEMAND_CLASS_CODE,
       p_next_rec.DEMAND_CLASS_CODE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.DEMAND_CLASS_CODE;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'DEMAND_CLASS';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.DEMAND_CLASS_CODE;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.DEMAND_CLASS_CODE;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.DEMAND_CLASS_CODE;
END IF;
END IF; /*  NEXT */

/* END DEMAND_CLASS_CODE*/
/****************************/

/****************************/
/* START DEP_PLAN_REQUIRED_FLAG*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.DEP_PLAN_REQUIRED_FLAG,
       p_prior_rec.DEP_PLAN_REQUIRED_FLAG) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'DEP_PLAN_REQUIRED_FLAG';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.DEP_PLAN_REQUIRED_FLAG;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.DEP_PLAN_REQUIRED_FLAG;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.DEP_PLAN_REQUIRED_FLAG,
       p_next_rec.DEP_PLAN_REQUIRED_FLAG) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.DEP_PLAN_REQUIRED_FLAG;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'DEP_PLAN_REQUIRED_FLAG';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.DEP_PLAN_REQUIRED_FLAG;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.DEP_PLAN_REQUIRED_FLAG;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.DEP_PLAN_REQUIRED_FLAG;
END IF; /*  NEXT */
END IF;

/* END DEP_PLAN_REQUIRED_FLAG*/
/****************************/

/****************************/
/* START EARLIEST_ACCEPTABLE_DATE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.EARLIEST_ACCEPTABLE_DATE,
       p_prior_rec.EARLIEST_ACCEPTABLE_DATE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'EARLIEST_ACCEPTABLE_DATE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.EARLIEST_ACCEPTABLE_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.EARLIEST_ACCEPTABLE_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.EARLIEST_ACCEPTABLE_DATE,
       p_next_rec.EARLIEST_ACCEPTABLE_DATE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.EARLIEST_ACCEPTABLE_DATE,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'EARLIEST_ACCEPTABLE_DATE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.EARLIEST_ACCEPTABLE_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.EARLIEST_ACCEPTABLE_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.EARLIEST_ACCEPTABLE_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  NEXT */

/* END EARLIEST_ACCEPTABLE_DATE*/
/****************************/

/****************************/
/* START END_ITEM_UNIT_NUMBER*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.END_ITEM_UNIT_NUMBER,
       p_prior_rec.END_ITEM_UNIT_NUMBER) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'END_ITEM_UNIT_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.END_ITEM_UNIT_NUMBER;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.END_ITEM_UNIT_NUMBER;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.END_ITEM_UNIT_NUMBER,
       p_next_rec.END_ITEM_UNIT_NUMBER) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.END_ITEM_UNIT_NUMBER;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'END_ITEM_UNIT_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.END_ITEM_UNIT_NUMBER;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.END_ITEM_UNIT_NUMBER;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.END_ITEM_UNIT_NUMBER;
END IF;
END IF; /*  NEXT */

/* END END_ITEM_UNIT_NUMBER*/
/****************************/
--bug 8920521 start
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
   x_line_changed_attr_tbl(ind).attribute_name  := 'ORDERED_ITEM_DSP';
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
   x_line_changed_attr_tbl(ind).attribute_name := 'ORDERED_ITEM_DSP';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.ORDERED_ITEM;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.ORDERED_ITEM;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.ORDERED_ITEM;
END IF;
END IF; /*  NEXT */

/* END ORDERED_ITEM*/
/****************************/
--bug 8920521 end
/****************************/
/* START EXPLOSION_DATE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.EXPLOSION_DATE,
       p_prior_rec.EXPLOSION_DATE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'EXPLOSION_DATE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.EXPLOSION_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.EXPLOSION_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.EXPLOSION_DATE,
       p_next_rec.EXPLOSION_DATE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.EXPLOSION_DATE,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'EXPLOSION_DATE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.EXPLOSION_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.EXPLOSION_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.EXPLOSION_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF; /*  NEXT */
END IF;

/* END EXPLOSION_DATE*/
/****************************/
/****************************/
/* START first_ack_code*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.first_ack_code,
       p_prior_rec.first_ack_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'first_ack_code';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.first_ack_code;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.first_ack_code,
       p_next_rec.first_ack_code) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.first_ack_code;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'first_ack_code';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.first_ack_code;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.first_ack_code;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.first_ack_code;
END IF;
END IF; /*  NEXT */

/* END first_ack_code*/
/****************************/

/****************************/
/* START first_ack_date*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.first_ack_date,
       p_prior_rec.first_ack_date) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'first_ack_date';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.first_ack_date,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.first_ack_date,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.first_ack_date,
       p_next_rec.first_ack_date) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.first_ack_date,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'first_ack_date';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.first_ack_date,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.first_ack_date,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.first_ack_date,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  NEXT */

/* END first_ack_date*/
/****************************/


/****************************/
/* START fob_point_code*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.fob_point_code,
       p_prior_rec.fob_point_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'fob';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.fob_point_code;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Fob_Point(p_curr_rec.fob_point_code);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.fob_point_code;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Fob_Point(p_prior_rec.fob_point_code);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.fob_point_code,
       p_next_rec.fob_point_code) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Fob_Point(p_curr_rec.fob_point_code);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'fob';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.fob_point_code;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Fob_Point(p_prior_rec.fob_point_code);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.fob_point_code;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Fob_Point(p_curr_rec.fob_point_code);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.fob_point_code;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Fob_Point(p_next_rec.fob_point_code);
END IF; /*  NEXT */

END IF;
/* END Fob_Point_code*/
/****************************/

/****************************/
/* START freight_carrier_code*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.freight_carrier_code,
       p_prior_rec.freight_carrier_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'freight_carrier';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.freight_carrier_code;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Freight_Carrier(p_curr_rec.freight_carrier_code,p_curr_rec.ship_from_org_id);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.freight_carrier_code;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Freight_Carrier(p_prior_rec.freight_carrier_code,p_prior_rec.ship_from_org_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.freight_carrier_code,
       p_next_rec.freight_carrier_code) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Freight_Carrier(p_curr_rec.freight_carrier_code,p_curr_rec.ship_from_org_id);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'freight_carrier';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.freight_carrier_code;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Freight_Carrier(p_prior_rec.freight_carrier_code,p_prior_rec.ship_from_org_id);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.freight_carrier_code;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Freight_Carrier(p_curr_rec.freight_carrier_code,p_curr_rec.ship_from_org_id);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.freight_carrier_code;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Freight_Carrier(p_next_rec.freight_carrier_code,p_next_rec.ship_from_org_id);
END IF;
END IF; /*  NEXT */

/* END freight_carrier_code*/
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
/* START global_attribute1*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute1,
       p_prior_rec.global_attribute1) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'global_attribute1';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute1;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute1;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute1,
       p_next_rec.global_attribute1) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute1;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'global_attribute1';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute1;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute1;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute1;
END IF;
END IF; /*  NEXT */

/* END global_attribute1*/
/****************************/

/****************************/
/* START global_attribute2*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute2,
       p_prior_rec.global_attribute2) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'global_attribute2';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute2;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute2;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute2,
       p_next_rec.global_attribute2) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute2;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'global_attribute2';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute2;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute2;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute2;
END IF;
END IF; /*  NEXT */

/* END global_attribute2*/
/****************************/
/****************************/
/* START global_attribute3*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute3,
       p_prior_rec.global_attribute3) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'global_attribute3';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute3;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute3;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute3,
       p_next_rec.global_attribute3) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute3;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'global_attribute3';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute3;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute3;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute3;
END IF;
END IF; /*  NEXT */

/* END global_attribute3*/
/****************************/

/****************************/
/* START global_attribute4*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute4,
       p_prior_rec.global_attribute4) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'global_attribute4';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute4;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute4;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute4,
       p_next_rec.global_attribute4) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute4;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'global_attribute4';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute4;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute4;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute4;
END IF;
END IF; /*  NEXT */

/* END global_attribute4*/
/****************************/
/****************************/
/* START global_attribute5*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute5,
       p_prior_rec.global_attribute5) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'global_attribute5';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute5;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute5;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute5,
       p_next_rec.global_attribute5) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute5;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'global_attribute5';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute5;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute5;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute5;
END IF;
END IF; /*  NEXT */

/* END global_attribute5*/
/****************************/

/****************************/
/* START global_attribute6*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute6,
       p_prior_rec.global_attribute6) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'global_attribute6';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute6;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute6;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute6,
       p_next_rec.global_attribute6) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute6;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'global_attribute6';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute6;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute6;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute6;
END IF;
END IF; /*  NEXT */

/* END global_attribute6*/
/****************************/
/****************************/
/* START global_attribute7*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute7,
       p_prior_rec.global_attribute7) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'global_attribute7';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute7;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute7;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute7,
       p_next_rec.global_attribute7) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute7;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute7;
   x_line_changed_attr_tbl(ind).attribute_name := 'global_attribute7';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute7;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute7;
END IF;
END IF; /*  NEXT */

/* END global_attribute7*/
/****************************/

/****************************/
/* START global_attribute8*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute8,
       p_prior_rec.global_attribute8) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'global_attribute8';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute8;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute8;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute8,
       p_next_rec.global_attribute8) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute8;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'global_attribute8';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute8;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute8;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute8;
END IF;
END IF; /*  NEXT */

/* END global_attribute8*/
/****************************/
/****************************/
/* START global_attribute9*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute9,
       p_prior_rec.global_attribute9) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'global_attribute9';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute9;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute9;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute9,
       p_next_rec.global_attribute9) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute9;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'global_attribute9';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute9;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute9;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute9;
END IF;
END IF; /*  NEXT */

/* END global_attribute9*/
/****************************/

/****************************/
/* START global_attribute10*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute10,
       p_prior_rec.global_attribute10) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'global_attribute10';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute10;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute10;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute10,
       p_next_rec.global_attribute10) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute10;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'global_attribute10';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute10;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute10;
END IF;
END IF; /*  NEXT */

/* END global_attribute10*/
/****************************/

/****************************/
/* START global_attribute11*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute11,
       p_prior_rec.global_attribute11) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'global_attribute11';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute11;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute11;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute11,
       p_next_rec.global_attribute11) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute11;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'global_attribute11';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute10;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute11;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute11;
END IF;
END IF; /*  NEXT */

/* END global_attribute11*/
/****************************/

/****************************/
/* START global_attribute12*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute12,
       p_prior_rec.global_attribute12) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'global_attribute12';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute12;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute12;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute12,
       p_next_rec.global_attribute12) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute12;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'global_attribute12';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute12;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute12;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute12;
END IF;
END IF; /*  NEXT */

/* END global_attribute12*/
/****************************/

/****************************/
/* START global_attribute13*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute13,
       p_prior_rec.global_attribute13) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'global_attribute13';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute13;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute13;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute13,
       p_next_rec.global_attribute13) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute13;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'global_attribute13';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute13;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute13;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute13;
END IF;
END IF; /*  NEXT */

/* END global_attribute13*/
/****************************/

/****************************/
/* START global_attribute14*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute14,
       p_prior_rec.global_attribute14) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'global_attribute14';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute14;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute14;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute14,
       p_next_rec.global_attribute14) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute14;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'global_attribute14';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute14;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute14;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute14;
END IF;
END IF; /*  NEXT */

/* END global_attribute14*/
/****************************/

/****************************/
/* START global_attribute15*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute15,
       p_prior_rec.global_attribute15) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'global_attribute15';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute15;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute15;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute15,
       p_next_rec.global_attribute15) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute15;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'global_attribute15';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute15;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute15;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute15;
END IF;
END IF; /*  NEXT */

/* END global_attribute15*/
/****************************/
/****************************/
/* START global_attribute16*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute16,
       p_prior_rec.global_attribute16) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'global_attribute16';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute16;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute16;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute16,
       p_next_rec.global_attribute16) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute16;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'global_attribute16';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute16;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute16;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute16;
END IF; /*  NEXT */
END IF;

/* END global_attribute16*/
/****************************/

/****************************/
/* START global_attribute17*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute17,
       p_prior_rec.global_attribute17) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'global_attribute17';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute17;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute17;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute17,
       p_next_rec.global_attribute17) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute17;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'global_attribute17';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute17;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute17;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute17;
END IF; /*  NEXT */
END IF;

/* END global_attribute17*/
/****************************/

/****************************/
/* START global_attribute18*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute18,
       p_prior_rec.global_attribute18) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'global_attribute18';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute18;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute18;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute18,
       p_next_rec.global_attribute18) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute18;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'global_attribute18';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute18;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute18;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute18;
END IF;
END IF; /*  NEXT */

/* END global_attribute18*/
/****************************/

/****************************/
/* START global_attribute19*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute19,
       p_prior_rec.global_attribute19) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'global_attribute19';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute19;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute19;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute19,
       p_next_rec.global_attribute19) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute19;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'global_attribute19';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute19;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute19;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute19;
END IF;
END IF; /*  NEXT */

/* END global_attribute19*/
/****************************/

/****************************/
/* START global_attribute20*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute20,
       p_prior_rec.global_attribute20) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'global_attribute20';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute20;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute20;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute20,
       p_next_rec.global_attribute20) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute20;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'global_attribute20';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute20;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute20;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute20;
END IF; /*  NEXT */
END IF;

/* END global_attribute20*/
/****************************/

/****************************/
/* START global_attribute_category*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute_category,
       p_prior_rec.global_attribute_category) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'global_attribute_category';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.global_attribute_category;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute_category;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.global_attribute_category,
       p_next_rec.global_attribute_category) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.global_attribute_category;
    END IF;
 null;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'global_attribute_category';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.global_attribute_category;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.global_attribute_category;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.global_attribute_category;
END IF;
END IF; /*  NEXT */

/* END global_attribute_category*/
/****************************/
/****************************/

/* START industry_attribute1*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute1,
       p_prior_rec.industry_attribute1) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute1';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.industry_attribute1;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute1;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute1,
       p_next_rec.industry_attribute1) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.industry_attribute1;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'industry_attribute1';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute1;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.industry_attribute1;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.industry_attribute1;
END IF;
END IF; /*  NEXT */

/* END industry_attribute1*/
/****************************/

/****************************/
/* START industry_attribute2*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute2,
       p_prior_rec.industry_attribute2) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'industry_attribute2';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.industry_attribute2;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute2;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute2,
       p_next_rec.industry_attribute2) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.industry_attribute2;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'industry_attribute2';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute2;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.industry_attribute2;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.industry_attribute2;
END IF;
END IF; /*  NEXT */

/* END industry_attribute2*/
/****************************/
/****************************/
/* START industry_attribute3*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute3,
       p_prior_rec.industry_attribute3) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'industry_attribute3';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.industry_attribute3;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute3;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute3,
       p_next_rec.industry_attribute3) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.industry_attribute3;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'industry_attribute3';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute3;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.industry_attribute3;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.industry_attribute3;
END IF;
END IF; /*  NEXT */

/* END industry_attribute3*/
/****************************/

/****************************/
/* START industry_attribute4*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute4,
       p_prior_rec.industry_attribute4) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'industry_attribute4';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.industry_attribute4;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute4;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute4,
       p_next_rec.industry_attribute4) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.industry_attribute4;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'industry_attribute4';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute4;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.industry_attribute4;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.industry_attribute4;
END IF;
END IF; /*  NEXT */

/* END industry_attribute4*/
/****************************/
/****************************/
/* START industry_attribute5*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute5,
       p_prior_rec.industry_attribute5) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'industry_attribute5';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.industry_attribute5;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute5;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute5,
       p_next_rec.industry_attribute5) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.industry_attribute5;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'industry_attribute5';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute5;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.industry_attribute5;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.industry_attribute5;
END IF;
END IF; /*  NEXT */

/* END industry_attribute5*/
/****************************/

/****************************/
/* START industry_attribute6*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute6,
       p_prior_rec.industry_attribute6) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'industry_attribute6';
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.industry_attribute6;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute6;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute6,
       p_next_rec.industry_attribute6) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.industry_attribute6;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'industry_attribute6';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute6;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.industry_attribute6;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.industry_attribute6;
END IF;
END IF; /*  NEXT */

/* END industry_attribute6*/
/****************************/
/****************************/
/* START industry_attribute7*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute7,
       p_prior_rec.industry_attribute7) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'industry_attribute7';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.industry_attribute7;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute7;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute7,
       p_next_rec.industry_attribute7) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.industry_attribute7;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'industry_attribute7';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute7;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.industry_attribute7;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.industry_attribute7;
END IF;
END IF; /*  NEXT */

/* END industry_attribute7*/
/****************************/

/****************************/
/* START industry_attribute8*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute8,
       p_prior_rec.industry_attribute8) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'industry_attribute8';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.industry_attribute8;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute8;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute8,
       p_next_rec.industry_attribute8) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.industry_attribute8;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'industry_attribute8';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute8;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.industry_attribute8;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.industry_attribute8;
END IF;
END IF; /*  NEXT */

/* END industry_attribute8*/
/****************************/
/****************************/
/* START industry_attribute9*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute9,
       p_prior_rec.industry_attribute9) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute9';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.industry_attribute9;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute9;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute9,
       p_next_rec.industry_attribute9) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.industry_attribute9;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'industry_attribute9';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute9;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.industry_attribute9;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.industry_attribute9;
END IF;
END IF; /*  NEXT */

/* END industry_attribute9*/
/****************************/

/****************************/
/* START industry_attribute10*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute10,
       p_prior_rec.industry_attribute10) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'industry_attribute10';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.industry_attribute10;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute10;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute10,
       p_next_rec.industry_attribute10) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.industry_attribute10;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute10';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.industry_attribute10;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.industry_attribute10;
END IF;
END IF; /*  NEXT */

/* END industry_attribute10*/
/****************************/

/****************************/
/* START industry_attribute11*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute11,
       p_prior_rec.industry_attribute11) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'industry_attribute11';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.industry_attribute11;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute11;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute11,
       p_next_rec.industry_attribute11) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.industry_attribute11;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'industry_attribute11';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute10;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.industry_attribute11;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.industry_attribute11;
END IF;
END IF; /*  NEXT */

/* END industry_attribute11*/
/****************************/

/****************************/
/* START industry_attribute12*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute12,
       p_prior_rec.industry_attribute12) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'industry_attribute12';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.industry_attribute12;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute12;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute12,
       p_next_rec.industry_attribute12) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.industry_attribute12;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'industry_attribute12';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute12;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.industry_attribute12;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.industry_attribute12;
END IF;
END IF; /*  NEXT */

/* END industry_attribute12*/
/****************************/

/****************************/
/* START industry_attribute13*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute13,
       p_prior_rec.industry_attribute13) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'industry_attribute13';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.industry_attribute13;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute13;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute13,
       p_next_rec.industry_attribute13) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.industry_attribute13;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'industry_attribute13';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute13;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.industry_attribute13;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.industry_attribute13;
END IF;
END IF; /*  NEXT */

/* END industry_attribute13*/
/****************************/

/****************************/
/* START industry_attribute14*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute14,
       p_prior_rec.industry_attribute14) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'industry_attribute14';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.industry_attribute14;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute14;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute14,
       p_next_rec.industry_attribute14) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.industry_attribute14;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'industry_attribute14';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute14;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.industry_attribute14;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.industry_attribute14;
END IF;
END IF; /*  NEXT */

/* END industry_attribute14*/
/****************************/

/****************************/
/* START industry_attribute15*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute15,
       p_prior_rec.industry_attribute15) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'industry_attribute15';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.industry_attribute15;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute15;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute15,
       p_next_rec.industry_attribute15) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.industry_attribute15;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'industry_attribute15';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute15;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.industry_attribute15;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.industry_attribute15;
END IF;
END IF; /*  NEXT */

/* END industry_attribute15*/
/****************************/
/****************************/
/* START industry_attribute16*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute16,
       p_prior_rec.industry_attribute16) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'industry_attribute16';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.industry_attribute16;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute16;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute16,
       p_next_rec.industry_attribute16) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.industry_attribute16;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'industry_attribute16';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute16;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.industry_attribute16;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.industry_attribute16;
END IF;
END IF; /*  NEXT */

/* END industry_attribute16*/
/****************************/

/****************************/
/* START industry_attribute17*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute17,
       p_prior_rec.industry_attribute17) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'industry_attribute17';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.industry_attribute17;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute17;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute17,
       p_next_rec.industry_attribute17) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.industry_attribute17;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'industry_attribute17';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute17;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.industry_attribute17;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.industry_attribute17;
END IF;
END IF; /*  NEXT */

/* END industry_attribute17*/
/****************************/

/****************************/
/* START industry_attribute18*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute18,
       p_prior_rec.industry_attribute18) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'industry_attribute18';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.industry_attribute18;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute18;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute18,
       p_next_rec.industry_attribute18) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.industry_attribute18;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'industry_attribute18';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute18;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.industry_attribute18;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.industry_attribute18;
END IF;
END IF; /*  NEXT */

/* END industry_attribute18*/
/****************************/

/****************************/
/* START industry_attribute19*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute19,
       p_prior_rec.industry_attribute19) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'industry_attribute19';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.industry_attribute19;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute19;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute19,
       p_next_rec.industry_attribute19) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.industry_attribute19;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'industry_attribute19';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute19;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.industry_attribute19;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.industry_attribute19;
END IF;
END IF; /*  NEXT */

/* END industry_attribute19*/
/****************************/

/****************************/
/* START industry_attribute20*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute20,
       p_prior_rec.industry_attribute20) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'industry_attribute20';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.industry_attribute20;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute20;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.industry_attribute20,
       p_next_rec.industry_attribute20) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.industry_attribute20;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'industry_attribute20';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.industry_attribute20;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.industry_attribute20;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.industry_attribute20;
END IF;
END IF; /*  NEXT */

/* END industry_attribute20*/
/****************************/

/****************************/
/* START INDUSTRY_CONTEXT*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.INDUSTRY_CONTEXT,
       p_prior_rec.INDUSTRY_CONTEXT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'INDUSTRY_CONTEXT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.INDUSTRY_CONTEXT;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.INDUSTRY_CONTEXT;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.INDUSTRY_CONTEXT,
       p_next_rec.INDUSTRY_CONTEXT) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.INDUSTRY_CONTEXT;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'INDUSTRY_CONTEXT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.INDUSTRY_CONTEXT;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.INDUSTRY_CONTEXT;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.INDUSTRY_CONTEXT;
END IF;
END IF; /*  NEXT */

/* END INDUSTRY_CONTEXT*/
/****************************/

/****************************/
/* START INTMED_SHIP_TO_CONTACT_ID*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.INTERMED_SHIP_TO_CONTACT_ID,
       p_prior_rec.INTERMED_SHIP_TO_CONTACT_ID) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'Intermed_Ship_To_Contact';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.INTERMED_SHIP_TO_CONTACT_ID;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Intermed_Ship_To_Contact(p_curr_rec.INTERMED_SHIP_TO_CONTACT_ID);
   x_line_changed_attr_tbl(ind).prior_id      := p_prior_rec.INTERMED_SHIP_TO_CONTACT_ID;
   x_line_changed_attr_tbl(ind).prior_value   := OE_ID_TO_VALUE.Intermed_Ship_To_Contact(p_prior_rec.INTERMED_SHIP_TO_CONTACT_ID);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.INTERMED_SHIP_TO_CONTACT_ID,
       p_next_rec.INTERMED_SHIP_TO_CONTACT_ID) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Intermed_Ship_To_Contact(p_curr_rec.INTERMED_SHIP_TO_CONTACT_ID);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name   := 'Intermed_Ship_To_Contact';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id      := p_prior_rec.INTERMED_SHIP_TO_CONTACT_ID;
   x_line_changed_attr_tbl(ind).prior_value   := OE_ID_TO_VALUE.Intermed_Ship_To_Contact(p_prior_rec.INTERMED_SHIP_TO_CONTACT_ID);
   x_line_changed_attr_tbl(ind).current_id   := p_curr_rec.INTERMED_SHIP_TO_CONTACT_ID;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Intermed_Ship_To_Contact(p_curr_rec.INTERMED_SHIP_TO_CONTACT_ID);
   x_line_changed_attr_tbl(ind).next_id   := p_next_rec.INTERMED_SHIP_TO_CONTACT_ID;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Intermed_Ship_To_Contact(p_next_rec.INTERMED_SHIP_TO_CONTACT_ID);
END IF;
END IF; /*  NEXT */

/* END INTMED_SHIP_TO_CONTACT_ID*/
/****************************/

/****************************/
/* START intermed_ship_to_org_id*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.intermed_ship_to_org_id,
       p_prior_rec.intermed_ship_to_org_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'intermed_ship_to_location';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   if p_curr_rec.intermed_ship_to_org_id is not null then

     OE_ID_TO_VALUE.intermed_ship_to_Org
         (   p_intermed_ship_to_org_id        => p_curr_rec.intermed_ship_to_org_id
        , x_intermed_ship_to_address1    => x_intermed_ship_to_address1
        , x_intermed_ship_to_address2    => x_intermed_ship_to_address2
	, x_intermed_ship_to_address3    => x_intermed_ship_to_address3
	, x_intermed_ship_to_address4    => x_intermed_ship_to_address4
	, x_intermed_ship_to_location    => x_intermed_ship_to_location
	, x_intermed_ship_to_org         => x_intermed_ship_to_org
	, x_intermed_ship_to_city        => x_intermed_ship_to_city
	, x_intermed_ship_to_state       => x_intermed_ship_to_state
	, x_intermed_ship_to_postal_code => x_intermed_ship_to_postal_code
	, x_intermed_ship_to_country     => x_intermed_ship_to_country
          );

  select
    DECODE(x_intermed_ship_to_location, NULL, NULL,x_intermed_ship_to_location|| ', ') ||
    DECODE(x_intermed_ship_to_address1, NULL, NULL,x_intermed_ship_to_address1 || ', ') ||
    DECODE(x_intermed_ship_to_address2, NULL, NULL,x_intermed_ship_to_address3 || ', ') ||
    DECODE(x_intermed_ship_to_address3, NULL, NULL,x_intermed_ship_to_address3 || ', ') ||
    DECODE(x_intermed_ship_to_address4, NULL, NULL,x_intermed_ship_to_address4 || ', ') ||
    DECODE(x_intermed_ship_to_city, NULL, NULL,x_intermed_ship_to_city || ', ') ||
    DECODE(x_intermed_ship_to_state, NULL, NULL,x_intermed_ship_to_state || ', ') ||
    DECODE(x_intermed_ship_to_postal_code, NULL, NULL,x_intermed_ship_to_postal_code || ', ') ||
    DECODE(x_intermed_ship_to_country, NULL,NULL,x_intermed_ship_to_country)
        into x_current_intermed_address from dual;

   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.intermed_ship_to_org_id;
   x_line_changed_attr_tbl(ind).current_value     := x_current_intermed_address;
       end if;

   if p_prior_rec.intermed_ship_to_org_id is not null then
     OE_ID_TO_VALUE.intermed_ship_to_Org
         (   p_intermed_ship_to_org_id        => p_prior_rec.intermed_ship_to_org_id
        , x_intermed_ship_to_address1    => x_intermed_ship_to_address1
        , x_intermed_ship_to_address2    => x_intermed_ship_to_address2
	, x_intermed_ship_to_address3    => x_intermed_ship_to_address3
	, x_intermed_ship_to_address4    => x_intermed_ship_to_address4
	, x_intermed_ship_to_location    => x_intermed_ship_to_location
	, x_intermed_ship_to_org         => x_intermed_ship_to_org
	, x_intermed_ship_to_city        => x_intermed_ship_to_city
	, x_intermed_ship_to_state       => x_intermed_ship_to_state
	, x_intermed_ship_to_postal_code => x_intermed_ship_to_postal_code
	, x_intermed_ship_to_country     => x_intermed_ship_to_country
          );

  select
    DECODE(x_intermed_ship_to_location, NULL, NULL,x_intermed_ship_to_location|| ', ') ||
    DECODE(x_intermed_ship_to_address1, NULL, NULL,x_intermed_ship_to_address1 || ', ') ||
    DECODE(x_intermed_ship_to_address2, NULL, NULL,x_intermed_ship_to_address3 || ', ') ||
    DECODE(x_intermed_ship_to_address3, NULL, NULL,x_intermed_ship_to_address3 || ', ') ||
    DECODE(x_intermed_ship_to_address4, NULL, NULL,x_intermed_ship_to_address4 || ', ') ||
    DECODE(x_intermed_ship_to_city, NULL, NULL,x_intermed_ship_to_city || ', ') ||
    DECODE(x_intermed_ship_to_state, NULL, NULL,x_intermed_ship_to_state || ', ') ||
    DECODE(x_intermed_ship_to_postal_code, NULL, NULL,x_intermed_ship_to_postal_code || ', ') ||
    DECODE(x_intermed_ship_to_country, NULL,NULL,x_intermed_ship_to_country)
        into x_prior_intermed_address from dual;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.intermed_ship_to_org_id;
   x_line_changed_attr_tbl(ind).prior_value     := x_prior_intermed_address;
       end if;
END IF;
END IF; /*  PRIOR */
/****************************/

IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.intermed_ship_to_org_id,
       p_next_rec.intermed_ship_to_org_id) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value     := x_current_intermed_address;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'intermed_ship_to_location';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;

   if p_prior_rec.intermed_ship_to_org_id is not null then
     OE_ID_TO_VALUE.intermed_ship_to_Org
         (   p_intermed_ship_to_org_id        => p_prior_rec.intermed_ship_to_org_id
        , x_intermed_ship_to_address1    => x_intermed_ship_to_address1
        , x_intermed_ship_to_address2    => x_intermed_ship_to_address2
	, x_intermed_ship_to_address3    => x_intermed_ship_to_address3
	, x_intermed_ship_to_address4    => x_intermed_ship_to_address4
	, x_intermed_ship_to_location    => x_intermed_ship_to_location
	, x_intermed_ship_to_org         => x_intermed_ship_to_org
	, x_intermed_ship_to_city        => x_intermed_ship_to_city
	, x_intermed_ship_to_state       => x_intermed_ship_to_state
	, x_intermed_ship_to_postal_code => x_intermed_ship_to_postal_code
	, x_intermed_ship_to_country     => x_intermed_ship_to_country
          );

  select
    DECODE(x_intermed_ship_to_location, NULL, NULL,x_intermed_ship_to_location|| ', ') ||
    DECODE(x_intermed_ship_to_address1, NULL, NULL,x_intermed_ship_to_address1 || ', ') ||
    DECODE(x_intermed_ship_to_address2, NULL, NULL,x_intermed_ship_to_address3 || ', ') ||
    DECODE(x_intermed_ship_to_address3, NULL, NULL,x_intermed_ship_to_address3 || ', ') ||
    DECODE(x_intermed_ship_to_address4, NULL, NULL,x_intermed_ship_to_address4 || ', ') ||
    DECODE(x_intermed_ship_to_city, NULL, NULL,x_intermed_ship_to_city || ', ') ||
    DECODE(x_intermed_ship_to_state, NULL, NULL,x_intermed_ship_to_state || ', ') ||
    DECODE(x_intermed_ship_to_postal_code, NULL, NULL,x_intermed_ship_to_postal_code || ', ') ||
    DECODE(x_intermed_ship_to_country, NULL,NULL,x_intermed_ship_to_country)
        into x_prior_intermed_address from dual;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.intermed_ship_to_org_id;
   x_line_changed_attr_tbl(ind).prior_value     := x_prior_intermed_address;
       end if;

   if p_curr_rec.intermed_ship_to_org_id is not null then
     OE_ID_TO_VALUE.intermed_ship_to_Org
         (   p_intermed_ship_to_org_id        => p_curr_rec.intermed_ship_to_org_id
        , x_intermed_ship_to_address1    => x_intermed_ship_to_address1
        , x_intermed_ship_to_address2    => x_intermed_ship_to_address2
	, x_intermed_ship_to_address3    => x_intermed_ship_to_address3
	, x_intermed_ship_to_address4    => x_intermed_ship_to_address4
	, x_intermed_ship_to_location    => x_intermed_ship_to_location
	, x_intermed_ship_to_org         => x_intermed_ship_to_org
	, x_intermed_ship_to_city        => x_intermed_ship_to_city
	, x_intermed_ship_to_state       => x_intermed_ship_to_state
	, x_intermed_ship_to_postal_code => x_intermed_ship_to_postal_code
	, x_intermed_ship_to_country     => x_intermed_ship_to_country
          );

  select
    DECODE(x_intermed_ship_to_location, NULL, NULL,x_intermed_ship_to_location|| ', ') ||
    DECODE(x_intermed_ship_to_address1, NULL, NULL,x_intermed_ship_to_address1 || ', ') ||
    DECODE(x_intermed_ship_to_address2, NULL, NULL,x_intermed_ship_to_address3 || ', ') ||
    DECODE(x_intermed_ship_to_address3, NULL, NULL,x_intermed_ship_to_address3 || ', ') ||
    DECODE(x_intermed_ship_to_address4, NULL, NULL,x_intermed_ship_to_address4 || ', ') ||
    DECODE(x_intermed_ship_to_city, NULL, NULL,x_intermed_ship_to_city || ', ') ||
    DECODE(x_intermed_ship_to_state, NULL, NULL,x_intermed_ship_to_state || ', ') ||
    DECODE(x_intermed_ship_to_postal_code, NULL, NULL,x_intermed_ship_to_postal_code || ', ') ||
    DECODE(x_intermed_ship_to_country, NULL,NULL,x_intermed_ship_to_country)
        into x_current_intermed_address from dual;
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.intermed_ship_to_org_id;
   x_line_changed_attr_tbl(ind).current_value     := x_current_intermed_address;
       end if;

   if p_next_rec.intermed_ship_to_org_id is not null then
     OE_ID_TO_VALUE.intermed_ship_to_Org
         (   p_intermed_ship_to_org_id        => p_next_rec.intermed_ship_to_org_id
        , x_intermed_ship_to_address1    => x_intermed_ship_to_address1
        , x_intermed_ship_to_address2    => x_intermed_ship_to_address2
	, x_intermed_ship_to_address3    => x_intermed_ship_to_address3
	, x_intermed_ship_to_address4    => x_intermed_ship_to_address4
	, x_intermed_ship_to_location    => x_intermed_ship_to_location
	, x_intermed_ship_to_org         => x_intermed_ship_to_org
	, x_intermed_ship_to_city        => x_intermed_ship_to_city
	, x_intermed_ship_to_state       => x_intermed_ship_to_state
	, x_intermed_ship_to_postal_code => x_intermed_ship_to_postal_code
	, x_intermed_ship_to_country     => x_intermed_ship_to_country
          );

  select
    DECODE(x_intermed_ship_to_location, NULL, NULL,x_intermed_ship_to_location|| ', ') ||
    DECODE(x_intermed_ship_to_address1, NULL, NULL,x_intermed_ship_to_address1 || ', ') ||
    DECODE(x_intermed_ship_to_address2, NULL, NULL,x_intermed_ship_to_address3 || ', ') ||
    DECODE(x_intermed_ship_to_address3, NULL, NULL,x_intermed_ship_to_address3 || ', ') ||
    DECODE(x_intermed_ship_to_address4, NULL, NULL,x_intermed_ship_to_address4 || ', ') ||
    DECODE(x_intermed_ship_to_city, NULL, NULL,x_intermed_ship_to_city || ', ') ||
    DECODE(x_intermed_ship_to_state, NULL, NULL,x_intermed_ship_to_state || ', ') ||
    DECODE(x_intermed_ship_to_postal_code, NULL, NULL,x_intermed_ship_to_postal_code || ', ') ||
    DECODE(x_intermed_ship_to_country, NULL,NULL,x_intermed_ship_to_country)
        into x_next_intermed_address from dual;
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.intermed_ship_to_org_id;
   x_line_changed_attr_tbl(ind).next_value     := x_next_intermed_address;
       end if;
END IF;
END IF; /*  NEXT */

/* END intermed_ship_to_org_id*/
/****************************/

/****************************/
/* START INVOICE_TO_CONTACT_ID*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.invoice_to_contact_id,
       p_prior_rec.invoice_to_contact_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'invoice_to_contact';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.invoice_to_contact_id;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.invoice_To_Contact(p_curr_rec.invoice_to_contact_id);
   x_line_changed_attr_tbl(ind).prior_id      := p_prior_rec.invoice_to_contact_id;
   x_line_changed_attr_tbl(ind).prior_value   := OE_ID_TO_VALUE.invoice_To_Contact(p_prior_rec.invoice_to_contact_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.invoice_to_contact_id,
       p_next_rec.invoice_to_contact_id) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.invoice_To_Contact(p_curr_rec.invoice_to_contact_id);
    END IF;
 null;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name   := 'invoice_to_contact';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id      := p_prior_rec.invoice_to_contact_id;
   x_line_changed_attr_tbl(ind).prior_value   := OE_ID_TO_VALUE.invoice_To_Contact(p_prior_rec.invoice_to_contact_id);
   x_line_changed_attr_tbl(ind).current_id   := p_curr_rec.invoice_to_contact_id;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.invoice_To_Contact(p_curr_rec.invoice_to_contact_id);
   x_line_changed_attr_tbl(ind).next_id   := p_next_rec.invoice_to_contact_id;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.invoice_To_Contact(p_next_rec.invoice_to_contact_id);
END IF;
END IF; /*  NEXT */

/* END invoice_to_contact_id*/

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
   x_line_changed_attr_tbl(ind).attribute_name  := 'invoice_to_location';
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
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.invoice_to_org_id;
   x_line_changed_attr_tbl(ind).prior_value     := x_prior_invoice_to_address;
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
   x_line_changed_attr_tbl(ind).attribute_name := 'invoice_to_location';
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
/* START INVOICED_QUANTITY*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.INVOICED_QUANTITY,
       p_prior_rec.INVOICED_QUANTITY) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'INVOICED_QUANTITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.INVOICED_QUANTITY;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.INVOICED_QUANTITY;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.INVOICED_QUANTITY,
       p_next_rec.INVOICED_QUANTITY) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.INVOICED_QUANTITY;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'INVOICED_QUANTITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.INVOICED_QUANTITY;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.INVOICED_QUANTITY;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.INVOICED_QUANTITY;
END IF;
END IF; /*  NEXT */

/* END INVOICED_QUANTITY*/
/****************************/
/****************************/
/* START invoicing_rule_id*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.INVOICED_QUANTITY,
       p_prior_rec.INVOICED_QUANTITY) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'INVOICED_QUANTITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.INVOICED_QUANTITY;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.INVOICED_QUANTITY;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.INVOICED_QUANTITY,
       p_next_rec.INVOICED_QUANTITY) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.INVOICED_QUANTITY;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'INVOICED_QUANTITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.INVOICED_QUANTITY;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.INVOICED_QUANTITY;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.INVOICED_QUANTITY;
END IF;
END IF; /*  NEXT */

/* END INVOICED_QUANTITY*/
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
 null;
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
/* START ITEM_REVISION*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ITEM_REVISION,
       p_prior_rec.ITEM_REVISION) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'ITEM_REVISION';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.ITEM_REVISION;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.ITEM_REVISION;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ITEM_REVISION,
       p_next_rec.ITEM_REVISION) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.ITEM_REVISION;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'ITEM_REVISION';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.ITEM_REVISION;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.ITEM_REVISION;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.ITEM_REVISION;
END IF;
END IF; /*  NEXT */

/* END ITEM_REVISION*/
/****************************/

/****************************/
/* START ITEM_TYPE_CODE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ITEM_TYPE_CODE,
       p_prior_rec.ITEM_TYPE_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'ITEM_TYPE_CODE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.ITEM_TYPE_CODE;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.item_type(p_curr_rec.ITEM_TYPE_CODE);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.ITEM_TYPE_CODE;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.item_type(p_prior_rec.ITEM_TYPE_CODE);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ITEM_TYPE_CODE,
       p_next_rec.ITEM_TYPE_CODE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.item_type(p_curr_rec.ITEM_TYPE_CODE);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'ITEM_TYPE_CODE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.ITEM_TYPE_CODE;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.item_type(p_prior_rec.ITEM_TYPE_CODE);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.ITEM_TYPE_CODE;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.item_type(p_curr_rec.ITEM_TYPE_CODE);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.ITEM_TYPE_CODE;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.item_type(p_next_rec.ITEM_TYPE_CODE);
END IF;
END IF; /*  NEXT */

/* END ITEM_TYPE_CODE*/
/****************************/
/****************************/
/* START last_ack_code*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.last_ack_code,
       p_prior_rec.last_ack_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'last_ack_code';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.last_ack_code;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.last_ack_code;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.last_ack_code,
       p_next_rec.last_ack_code) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.last_ack_code;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'last_ack_code';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.last_ack_code;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.last_ack_code;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.last_ack_code;
END IF;
END IF; /*  NEXT */

/* END last_ack_code*/
/****************************/

/****************************/
/* START last_ack_date*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.last_ack_date,
       p_prior_rec.last_ack_date) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'last_ack_date';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.last_ack_date,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.last_ack_date,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.last_ack_date,
       p_next_rec.last_ack_date) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.last_ack_date,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'last_ack_date';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.last_ack_date,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.last_ack_date,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.last_ack_date,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  NEXT */

/* END last_ack_date*/
/****************************/


/****************************/
/* START LATEST_ACCEPTABLE_DATE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.LATEST_ACCEPTABLE_DATE,
       p_prior_rec.LATEST_ACCEPTABLE_DATE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'LATEST_ACCEPTABLE_DATE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.LATEST_ACCEPTABLE_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.LATEST_ACCEPTABLE_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.LATEST_ACCEPTABLE_DATE,
       p_next_rec.LATEST_ACCEPTABLE_DATE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.LATEST_ACCEPTABLE_DATE,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'LATEST_ACCEPTABLE_DATE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.LATEST_ACCEPTABLE_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.LATEST_ACCEPTABLE_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.LATEST_ACCEPTABLE_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  NEXT */

/* END LATEST_ACCEPTABLE_DATE*/
/****************************/

/****************************/
/* START order_source_id*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.order_source_id,
       p_prior_rec.order_source_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'order_source_dsp';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.order_source_id;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.order_source(p_curr_rec.order_source_id);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.order_source_id;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.order_source(p_prior_rec.order_source_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.order_source_id,
       p_next_rec.order_source_id) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.order_source(p_curr_rec.order_source_id);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'order_source_dsp';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.order_source_id;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.order_source(p_prior_rec.order_source_id);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.order_source_id;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.order_source(p_curr_rec.order_source_id);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.order_source_id;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.order_source(p_next_rec.order_source_id);
END IF;
END IF; /*  NEXT */

/* END order_source_id*/
/****************************/

/****************************/
/* START LINE_NUMBER*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.LINE_NUMBER,
       p_prior_rec.LINE_NUMBER) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'LINE_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.LINE_NUMBER;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.LINE_NUMBER;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.LINE_NUMBER,
       p_next_rec.LINE_NUMBER) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.LINE_NUMBER;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'LINE_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.LINE_NUMBER;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.LINE_NUMBER;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.LINE_NUMBER;
END IF;
END IF; /*  NEXT */

/* END LINE_NUMBER*/
/****************************/

/****************************/
/* START LINE_TYPE_ID*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.LINE_TYPE_ID,
       p_prior_rec.LINE_TYPE_ID) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'LINE_TYPE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.LINE_TYPE_ID;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.line_type(p_curr_rec.LINE_TYPE_ID);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.LINE_TYPE_ID;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.line_type(p_prior_rec.LINE_TYPE_ID);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.LINE_TYPE_ID,
       p_next_rec.LINE_TYPE_ID) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.line_type(p_curr_rec.LINE_TYPE_ID);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'LINE_TYPE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.LINE_TYPE_ID;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.line_type(p_prior_rec.LINE_TYPE_ID);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.LINE_TYPE_ID;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.line_type(p_curr_rec.LINE_TYPE_ID);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.LINE_TYPE_ID;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.line_type(p_next_rec.LINE_TYPE_ID);
END IF;
END IF; /*  NEXT */

/* END LINE_TYPE_ID*/
/****************************/

/****************************/
/* START MODEL_GROUP_NUMBER*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.MODEL_GROUP_NUMBER,
       p_prior_rec.MODEL_GROUP_NUMBER) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'MODEL_GROUP_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.MODEL_GROUP_NUMBER;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.MODEL_GROUP_NUMBER;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.MODEL_GROUP_NUMBER,
       p_next_rec.MODEL_GROUP_NUMBER) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.MODEL_GROUP_NUMBER;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'MODEL_GROUP_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.MODEL_GROUP_NUMBER;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.MODEL_GROUP_NUMBER;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.MODEL_GROUP_NUMBER;
END IF;
END IF; /*  NEXT */

/* END MODEL_GROUP_NUMBER*/
/****************************/


/****************************/
/* START OPTION_NUMBER*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.OPTION_NUMBER,
       p_prior_rec.OPTION_NUMBER) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'OPTION_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.OPTION_NUMBER;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.OPTION_NUMBER;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.OPTION_NUMBER,
       p_next_rec.OPTION_NUMBER) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.OPTION_NUMBER;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'OPTION_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.OPTION_NUMBER;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.OPTION_NUMBER;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.OPTION_NUMBER;
END IF;
END IF; /*  NEXT */

/* END OPTION_NUMBER*/
/****************************/

/****************************/
/* START ORDERED_QUANTITY*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ORDERED_QUANTITY,
       p_prior_rec.ORDERED_QUANTITY) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'ORDERED_QUANTITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.ORDERED_QUANTITY;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.ORDERED_QUANTITY;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ORDERED_QUANTITY,
       p_next_rec.ORDERED_QUANTITY) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.ORDERED_QUANTITY;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'ORDERED_QUANTITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.ORDERED_QUANTITY;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.ORDERED_QUANTITY;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.ORDERED_QUANTITY;
END IF;
END IF; /*  NEXT */

/* END ORDERED_QUANTITY*/
/****************************/

/****************************/
/* START ORDERED_QUANTITY2*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ORDERED_QUANTITY2,
       p_prior_rec.ORDERED_QUANTITY2) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'ORDERED_QUANTITY2';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.ORDERED_QUANTITY2;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.ORDERED_QUANTITY2;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ORDERED_QUANTITY2,
       p_next_rec.ORDERED_QUANTITY2) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.ORDERED_QUANTITY2;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'ORDERED_QUANTITY2';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.ORDERED_QUANTITY2;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.ORDERED_QUANTITY2;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.ORDERED_QUANTITY2;
END IF;
END IF; /*  NEXT */

/* END ORDERED_QUANTITY2*/
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
/* START ORDERED_QUANTITY_UOM2*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ORDERED_QUANTITY_UOM2,
       p_prior_rec.ORDERED_QUANTITY_UOM2) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'ORDERED_QUANTITY_UOM2';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.ORDERED_QUANTITY_UOM2;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.ORDERED_QUANTITY_UOM2;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ORDERED_QUANTITY_UOM2,
       p_next_rec.ORDERED_QUANTITY_UOM2) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.ORDERED_QUANTITY_UOM2;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'ORDERED_QUANTITY_UOM2';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.ORDERED_QUANTITY_UOM2;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.ORDERED_QUANTITY_UOM2;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.ORDERED_QUANTITY_UOM2;
END IF;
END IF; /*  NEXT */

/* END ORDERED_QUANTITY_UOM2*/
/****************************/



/****************************/
/* START Over_Ship_Reason_code*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.Over_Ship_Reason_code,
       p_prior_rec.Over_Ship_Reason_code) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'Over_Ship_Reason';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.Over_Ship_Reason_code;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Over_Ship_Reason(p_curr_rec.Over_Ship_Reason_code);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.Over_Ship_Reason_code;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Over_Ship_Reason(p_prior_rec.Over_Ship_Reason_code);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.Over_Ship_Reason_code,
       p_next_rec.Over_Ship_Reason_code) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Over_Ship_Reason(p_curr_rec.Over_Ship_Reason_code);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'Over_Ship_Reason';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.Over_Ship_Reason_code;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Over_Ship_Reason(p_prior_rec.Over_Ship_Reason_code);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.Over_Ship_Reason_code;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Over_Ship_Reason(p_curr_rec.Over_Ship_Reason_code);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.Over_Ship_Reason_code;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Over_Ship_Reason(p_next_rec.Over_Ship_Reason_code);
END IF;
END IF; /*  NEXT */

/* END Over_Ship_Reason_code*/
/****************************/
/****************************/
/* START OVER_SHIP_RESOLVED_FLAG*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.OVER_SHIP_RESOLVED_FLAG,
       p_prior_rec.OVER_SHIP_RESOLVED_FLAG) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'OVER_SHIP_RESOLVED_FLAG';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.OVER_SHIP_RESOLVED_FLAG;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.OVER_SHIP_RESOLVED_FLAG;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.OVER_SHIP_RESOLVED_FLAG,
       p_next_rec.OVER_SHIP_RESOLVED_FLAG) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.OVER_SHIP_RESOLVED_FLAG;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'OVER_SHIP_RESOLVED_FLAG';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.OVER_SHIP_RESOLVED_FLAG;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.OVER_SHIP_RESOLVED_FLAG;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.OVER_SHIP_RESOLVED_FLAG;
END IF;
END IF; /*  NEXT */

/* END OVER_SHIP_RESOLVED_FLAG*/
/****************************/

/****************************/
/* START payment_term_id*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.payment_term_id,
       p_prior_rec.payment_term_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'TERMS';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.payment_term_id;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Payment_Term(p_curr_rec.payment_term_id);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.payment_term_id;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Payment_Term(p_prior_rec.payment_term_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.payment_term_id,
       p_next_rec.payment_term_id) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Payment_Term(p_curr_rec.payment_term_id);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'TERMS';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.payment_term_id;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Payment_Term(p_prior_rec.payment_term_id);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.payment_term_id;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Payment_Term(p_curr_rec.payment_term_id);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.payment_term_id;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Payment_Term(p_next_rec.payment_term_id);
END IF;
END IF; /*  NEXT */

/* END payment_term_id*/
/****************************/
/****************************/
/* START PLANNING_PRIORITY*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.PLANNING_PRIORITY,
       p_prior_rec.PLANNING_PRIORITY) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'PLANNING_PRIORITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.PLANNING_PRIORITY;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.PLANNING_PRIORITY;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.PLANNING_PRIORITY,
       p_next_rec.PLANNING_PRIORITY) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.PLANNING_PRIORITY;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'PLANNING_PRIORITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.PLANNING_PRIORITY;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.PLANNING_PRIORITY;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.PLANNING_PRIORITY;
END IF;
END IF; /*  NEXT */

/* END PLANNING_PRIORITY*/
/****************************/

/****************************/
/* START PREFERRED_GRADE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.PREFERRED_GRADE,
       p_prior_rec.PREFERRED_GRADE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'PREFERRED_GRADE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.PREFERRED_GRADE;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.PREFERRED_GRADE;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.PREFERRED_GRADE,
       p_next_rec.PREFERRED_GRADE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.PREFERRED_GRADE;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'PREFERRED_GRADE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.PREFERRED_GRADE;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.PREFERRED_GRADE;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.PREFERRED_GRADE;
END IF;
END IF; /*  NEXT */

/* END PREFERRED_GRADE*/
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
   x_line_changed_attr_tbl(ind).attribute_name  := 'PRICE_LIST';
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
   x_line_changed_attr_tbl(ind).attribute_name := 'PRICE_LIST';
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
/* START pricing_attribute1*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.pricing_attribute1,
       p_prior_rec.pricing_attribute1) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'pricing_attribute1';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.pricing_attribute1;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.pricing_attribute1;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.pricing_attribute1,
       p_next_rec.pricing_attribute1) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.pricing_attribute1;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'pricing_attribute1';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.pricing_attribute1;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.pricing_attribute1;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.pricing_attribute1;
END IF;
END IF; /*  NEXT */

/* END pricing_attribute1*/
/****************************/

/****************************/
/* START pricing_attribute2*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.pricing_attribute2,
       p_prior_rec.pricing_attribute2) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'pricing_attribute2';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.pricing_attribute2;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.pricing_attribute2;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.pricing_attribute2,
       p_next_rec.pricing_attribute2) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.pricing_attribute2;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'pricing_attribute2';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.pricing_attribute2;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.pricing_attribute2;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.pricing_attribute2;
END IF;
END IF; /*  NEXT */

/* END pricing_attribute2*/
/****************************/
/****************************/
/* START pricing_attribute3*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.pricing_attribute3,
       p_prior_rec.pricing_attribute3) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'pricing_attribute3';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.pricing_attribute3;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.pricing_attribute3;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.pricing_attribute3,
       p_next_rec.pricing_attribute3) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.pricing_attribute3;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'pricing_attribute3';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.pricing_attribute3;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.pricing_attribute3;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.pricing_attribute3;
END IF;
END IF; /*  NEXT */

/* END pricing_attribute3*/
/****************************/

/****************************/
/* START pricing_attribute4*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.pricing_attribute4,
       p_prior_rec.pricing_attribute4) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'pricing_attribute4';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.pricing_attribute4;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.pricing_attribute4;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.pricing_attribute4,
       p_next_rec.pricing_attribute4) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.pricing_attribute4;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'pricing_attribute4';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.pricing_attribute4;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.pricing_attribute4;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.pricing_attribute4;
END IF;
END IF; /*  NEXT */

/* END pricing_attribute4*/
/****************************/
/****************************/
/* START pricing_attribute5*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.pricing_attribute5,
       p_prior_rec.pricing_attribute5) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'pricing_attribute5';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.pricing_attribute5;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.pricing_attribute5;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.pricing_attribute5,
       p_next_rec.pricing_attribute5) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.pricing_attribute5;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'pricing_attribute5';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.pricing_attribute5;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.pricing_attribute5;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.pricing_attribute5;
END IF;
END IF; /*  NEXT */

/* END pricing_attribute5*/
/****************************/

/****************************/
/* START pricing_attribute6*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.pricing_attribute6,
       p_prior_rec.pricing_attribute6) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'pricing_attribute6';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.pricing_attribute6;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.pricing_attribute6;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.pricing_attribute6,
       p_next_rec.pricing_attribute6) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.pricing_attribute6;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'pricing_attribute6';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.pricing_attribute6;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.pricing_attribute6;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.pricing_attribute6;
END IF;
END IF; /*  NEXT */

/* END pricing_attribute6*/
/****************************/
/****************************/
/* START pricing_attribute7*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.pricing_attribute7,
       p_prior_rec.pricing_attribute7) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'pricing_attribute7';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.pricing_attribute7;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.pricing_attribute7;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.pricing_attribute7,
       p_next_rec.pricing_attribute7) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.pricing_attribute7;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.pricing_attribute7;
   x_line_changed_attr_tbl(ind).attribute_name := 'pricing_attribute7';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.pricing_attribute7;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.pricing_attribute7;
END IF;
END IF; /*  NEXT */

/* END pricing_attribute7*/
/****************************/

/****************************/
/* START pricing_attribute8*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.pricing_attribute8,
       p_prior_rec.pricing_attribute8) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'pricing_attribute8';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.pricing_attribute8;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.pricing_attribute8;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.pricing_attribute8,
       p_next_rec.pricing_attribute8) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.pricing_attribute8;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'pricing_attribute8';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.pricing_attribute8;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.pricing_attribute8;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.pricing_attribute8;
END IF;
END IF; /*  NEXT */

/* END pricing_attribute8*/
/****************************/
/****************************/
/* START pricing_attribute9*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.pricing_attribute9,
       p_prior_rec.pricing_attribute9) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'pricing_attribute9';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.pricing_attribute9;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.pricing_attribute9;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.pricing_attribute9,
       p_next_rec.pricing_attribute9) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.pricing_attribute9;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'pricing_attribute9';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.pricing_attribute9;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.pricing_attribute9;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.pricing_attribute9;
END IF;
END IF; /*  NEXT */

/* END pricing_attribute9*/
/****************************/

/****************************/
/* START pricing_attribute10*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.pricing_attribute10,
       p_prior_rec.pricing_attribute10) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'pricing_attribute10';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.pricing_attribute10;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.pricing_attribute10;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.pricing_attribute10,
       p_next_rec.pricing_attribute10) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.pricing_attribute10;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'pricing_attribute10';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.pricing_attribute10;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.pricing_attribute10;
END IF;
END IF; /*  NEXT */

/* END pricing_attribute10*/
/****************************/

/****************************/
/* START PRICING_CONTEXT*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.PRICING_CONTEXT,
       p_prior_rec.PRICING_CONTEXT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'PRICING_CONTEXT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.PRICING_CONTEXT;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.PRICING_CONTEXT;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.PRICING_CONTEXT,
       p_next_rec.PRICING_CONTEXT) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.PRICING_CONTEXT;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'PRICING_CONTEXT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.PRICING_CONTEXT;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.PRICING_CONTEXT;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.PRICING_CONTEXT;
END IF;
END IF; /*  NEXT */

/* END PRICING_CONTEXT*/
/****************************/
/****************************/
/* START PRICING_DATE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.PRICING_DATE,
       p_prior_rec.PRICING_DATE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'PRICING_DATE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.PRICING_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.PRICING_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.PRICING_DATE,
       p_next_rec.PRICING_DATE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.PRICING_DATE,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'PRICING_DATE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.PRICING_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.PRICING_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.PRICING_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  NEXT */

/* END PRICING_DATE*/
/****************************/


/****************************/
/* START PROJECT_NUMBER*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.PROJECT_ID,
       p_prior_rec.PROJECT_ID) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'PROJECT_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.PROJECT_ID;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Project(p_curr_rec.PROJECT_ID);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.PROJECT_ID;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Project(p_prior_rec.PROJECT_ID);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.PROJECT_ID,
       p_next_rec.PROJECT_ID) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Project(p_curr_rec.PROJECT_ID);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'PROJECT_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.PROJECT_ID;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Project(p_prior_rec.PROJECT_ID);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.PROJECT_ID;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Project(p_curr_rec.PROJECT_ID);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.PROJECT_ID;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Project(p_next_rec.PROJECT_ID);
END IF;
END IF; /*  NEXT */

/* END PROJECT_ID*/
/****************************/
/****************************/
/* START PROMISE_DATE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.PROMISE_DATE,
       p_prior_rec.PROMISE_DATE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'PROMISE_DATE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.PROMISE_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.PROMISE_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.PROMISE_DATE,
       p_next_rec.PROMISE_DATE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.PROMISE_DATE,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'PROMISE_DATE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.PROMISE_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.PROMISE_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.PROMISE_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  NEXT */

/* END PROMISE_DATE*/
/****************************/


/****************************/
/* START REFERENCE_TYPE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.REFERENCE_TYPE,
       p_prior_rec.REFERENCE_TYPE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'REFERENCE_TYPE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.REFERENCE_TYPE;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.REFERENCE_TYPE;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.REFERENCE_TYPE,
       p_next_rec.REFERENCE_TYPE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.REFERENCE_TYPE;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'REFERENCE_TYPE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.REFERENCE_TYPE;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.REFERENCE_TYPE;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.REFERENCE_TYPE;
END IF;
END IF; /*  NEXT */

/* END REFERENCE_TYPE*/
/****************************/
/****************************/
/* START REQUEST_DATE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.REQUEST_DATE,
       p_prior_rec.REQUEST_DATE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'REQUEST_DATE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.REQUEST_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.REQUEST_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.REQUEST_DATE,
       p_next_rec.REQUEST_DATE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.REQUEST_DATE,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'REQUEST_DATE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.REQUEST_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.REQUEST_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.REQUEST_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  NEXT */

/* END REQUEST_DATE*/
/****************************/


/****************************/
/* START return_attribute1*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute1,
       p_prior_rec.return_attribute1) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'return_attribute1';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.return_attribute1;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute1;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute1,
       p_next_rec.return_attribute1) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.return_attribute1;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'return_attribute1';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute1;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.return_attribute1;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.return_attribute1;
END IF;
END IF; /*  NEXT */

/* END return_attribute1*/
/****************************/

/****************************/
/* START return_attribute2*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute2,
       p_prior_rec.return_attribute2) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'return_attribute2';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.return_attribute2;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute2;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute2,
       p_next_rec.return_attribute2) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.return_attribute2;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'return_attribute2';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute2;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.return_attribute2;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.return_attribute2;
END IF;
END IF; /*  NEXT */

/* END return_attribute2*/
/****************************/
/****************************/
/* START return_attribute3*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute3,
       p_prior_rec.return_attribute3) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'return_attribute3';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.return_attribute3;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute3;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute3,
       p_next_rec.return_attribute3) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.return_attribute3;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'return_attribute3';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute3;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.return_attribute3;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.return_attribute3;
END IF;
END IF; /*  NEXT */

/* END return_attribute3*/
/****************************/

/****************************/
/* START return_attribute4*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute4,
       p_prior_rec.return_attribute4) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'return_attribute4';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.return_attribute4;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute4;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute4,
       p_next_rec.return_attribute4) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.return_attribute4;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'return_attribute4';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute4;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.return_attribute4;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.return_attribute4;
END IF;
END IF; /*  NEXT */

/* END return_attribute4*/
/****************************/
/****************************/
/* START return_attribute5*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute5,
       p_prior_rec.return_attribute5) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'return_attribute5';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.return_attribute5;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute5;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute5,
       p_next_rec.return_attribute5) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.return_attribute5;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'return_attribute5';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute5;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.return_attribute5;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.return_attribute5;
END IF;
END IF; /*  NEXT */

/* END return_attribute5*/
/****************************/

/****************************/
/* START return_attribute6*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute6,
       p_prior_rec.return_attribute6) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'return_attribute6';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.return_attribute6;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute6;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute6,
       p_next_rec.return_attribute6) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.return_attribute6;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'return_attribute6';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute6;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.return_attribute6;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.return_attribute6;
END IF;
END IF; /*  NEXT */

/* END return_attribute6*/
/****************************/
/****************************/
/* START return_attribute7*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute7,
       p_prior_rec.return_attribute7) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'return_attribute7';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.return_attribute7;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute7;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute7,
       p_next_rec.return_attribute7) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.return_attribute7;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute7;
   x_line_changed_attr_tbl(ind).attribute_name := 'return_attribute7';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.return_attribute7;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.return_attribute7;
END IF;
END IF; /*  NEXT */

/* END return_attribute7*/
/****************************/

/****************************/
/* START return_attribute8*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute8,
       p_prior_rec.return_attribute8) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'return_attribute8';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.return_attribute8;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute8;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute8,
       p_next_rec.return_attribute8) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.return_attribute8;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'return_attribute8';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute8;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.return_attribute8;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.return_attribute8;
END IF;
END IF; /*  NEXT */

/* END return_attribute8*/
/****************************/
/****************************/
/* START return_attribute9*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute9,
       p_prior_rec.return_attribute9) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'return_attribute9';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.return_attribute9;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute9;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute9,
       p_next_rec.return_attribute9) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.return_attribute9;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'return_attribute9';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute9;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.return_attribute9;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.return_attribute9;
END IF;
END IF; /*  NEXT */

/* END return_attribute9*/
/****************************/

/****************************/
/* START return_attribute10*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute10,
       p_prior_rec.return_attribute10) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'return_attribute10';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.return_attribute10;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute10;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute10,
       p_next_rec.return_attribute10) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.return_attribute10;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'return_attribute10';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.return_attribute10;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.return_attribute10;
END IF;
END IF; /*  NEXT */

/* END return_attribute10*/
/****************************/

/****************************/
/* START return_attribute11*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute11,
       p_prior_rec.return_attribute11) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'return_attribute11';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.return_attribute11;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute11;
END IF; /*  PRIOR */
END IF;
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute11,
       p_next_rec.return_attribute11) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.return_attribute11;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'return_attribute11';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute10;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.return_attribute11;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.return_attribute11;
END IF;
END IF; /*  NEXT */

/* END return_attribute11*/
/****************************/

/****************************/
/* START return_attribute12*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute12,
       p_prior_rec.return_attribute12) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'return_attribute12';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.return_attribute12;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute12;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute12,
       p_next_rec.return_attribute12) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.return_attribute12;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'return_attribute12';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute12;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.return_attribute12;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.return_attribute12;
END IF;
END IF; /*  NEXT */

/* END return_attribute12*/
/****************************/

/****************************/
/* START return_attribute13*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute13,
       p_prior_rec.return_attribute13) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'return_attribute13';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.return_attribute13;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute13;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute13,
       p_next_rec.return_attribute13) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.return_attribute13;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'return_attribute13';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute13;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.return_attribute13;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.return_attribute13;
END IF;
END IF; /*  NEXT */

/* END return_attribute13*/
/****************************/

/****************************/
/* START return_attribute14*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute14,
       p_prior_rec.return_attribute14) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'return_attribute14';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.return_attribute14;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute14;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute14,
       p_next_rec.return_attribute14) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.return_attribute14;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'return_attribute14';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute14;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.return_attribute14;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.return_attribute14;
END IF;
END IF; /*  NEXT */

/* END return_attribute14*/
/****************************/

/****************************/
/* START return_attribute15*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute15,
       p_prior_rec.return_attribute15) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'return_attribute15';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.return_attribute15;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute15;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.return_attribute15,
       p_next_rec.return_attribute15) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.return_attribute15;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'return_attribute15';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.return_attribute15;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.return_attribute15;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.return_attribute15;
END IF;
END IF; /*  NEXT */

/* END return_attribute15*/
/****************************/

/****************************/
/* START RETURN_CONTEXT*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.RETURN_CONTEXT,
       p_prior_rec.RETURN_CONTEXT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'RETURN_CONTEXT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.RETURN_CONTEXT;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.RETURN_CONTEXT;
END IF; /*  PRIOR */
END IF;
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.RETURN_CONTEXT,
       p_next_rec.RETURN_CONTEXT) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.RETURN_CONTEXT;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'RETURN_CONTEXT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.RETURN_CONTEXT;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.RETURN_CONTEXT;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.RETURN_CONTEXT;
END IF;
END IF; /*  NEXT */

/* END RETURN_CONTEXT*/
/****************************/
/****************************/
/* START RETURN_REASON_CODE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.RETURN_REASON_CODE,
       p_prior_rec.RETURN_REASON_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'RETURN_REASON';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.RETURN_REASON_CODE;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.RETURN_REASON(p_curr_rec.RETURN_REASON_CODE);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.RETURN_REASON_CODE;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.RETURN_REASON(p_prior_rec.RETURN_REASON_CODE);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.RETURN_REASON_CODE,
       p_next_rec.RETURN_REASON_CODE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.RETURN_REASON(p_curr_rec.RETURN_REASON_CODE);
    END IF;
 null;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'RETURN_REASON';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.RETURN_REASON_CODE;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.RETURN_REASON(p_prior_rec.RETURN_REASON_CODE);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.RETURN_REASON_CODE;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.RETURN_REASON(p_curr_rec.RETURN_REASON_CODE);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.RETURN_REASON_CODE;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.RETURN_REASON(p_next_rec.RETURN_REASON_CODE);
END IF;
END IF; /*  NEXT */

/* END RETURN_REASON_CODE*/
/****************************/

/****************************/
/* START RLA_SCHEDULE_TYPE_CODE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.RLA_SCHEDULE_TYPE_CODE,
       p_prior_rec.RLA_SCHEDULE_TYPE_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'RLA_SCHEDULE_TYPE_CODE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.RLA_SCHEDULE_TYPE_CODE;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.RLA_SCHEDULE_TYPE_CODE;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.RLA_SCHEDULE_TYPE_CODE,
       p_next_rec.RLA_SCHEDULE_TYPE_CODE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.RLA_SCHEDULE_TYPE_CODE;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'RLA_SCHEDULE_TYPE_CODE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.RLA_SCHEDULE_TYPE_CODE;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.RLA_SCHEDULE_TYPE_CODE;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.RLA_SCHEDULE_TYPE_CODE;
END IF;
END IF; /*  NEXT */

/* END RLA_SCHEDULE_TYPE_CODE*/
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
END IF;
END IF; /*  NEXT */

/* END SALESREP_ID*/
/****************************/

/****************************/
/* START SCHEDULE_ARRIVAL_DATE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SCHEDULE_ARRIVAL_DATE,
       p_prior_rec.SCHEDULE_ARRIVAL_DATE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'SCHEDULE_ARRIVAL_DATE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.SCHEDULE_ARRIVAL_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.SCHEDULE_ARRIVAL_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SCHEDULE_ARRIVAL_DATE,
       p_next_rec.SCHEDULE_ARRIVAL_DATE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.SCHEDULE_ARRIVAL_DATE,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'SCHEDULE_ARRIVAL_DATE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.SCHEDULE_ARRIVAL_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.SCHEDULE_ARRIVAL_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.SCHEDULE_ARRIVAL_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  NEXT */

/* END SCHEDULE_ARRIVAL_DATE*/
/****************************/

/****************************/
/* START SCHEDULE_SHIP_DATE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SCHEDULE_SHIP_DATE,
       p_prior_rec.SCHEDULE_SHIP_DATE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'SCHEDULE_SHIP_DATE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := to_char(p_curr_rec.SCHEDULE_SHIP_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.SCHEDULE_SHIP_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SCHEDULE_SHIP_DATE,
       p_next_rec.SCHEDULE_SHIP_DATE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_curr_rec.SCHEDULE_SHIP_DATE,'DD-MON-YYYY HH24:MI:SS');
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'SCHEDULE_SHIP_DATE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := to_char(p_prior_rec.SCHEDULE_SHIP_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).current_value     := to_char(p_curr_rec.SCHEDULE_SHIP_DATE,'DD-MON-YYYY HH24:MI:SS');
   x_line_changed_attr_tbl(ind).next_value      := to_char(p_next_rec.SCHEDULE_SHIP_DATE,'DD-MON-YYYY HH24:MI:SS');
END IF;
END IF; /*  NEXT */

/* END SCHEDULE_SHIP_DATE*/
/****************************/


/****************************/
/* START SHIPMENT_NUMBER*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SHIPMENT_NUMBER,
       p_prior_rec.SHIPMENT_NUMBER) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'SHIPMENT_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.SHIPMENT_NUMBER;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.SHIPMENT_NUMBER;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SHIPMENT_NUMBER,
       p_next_rec.SHIPMENT_NUMBER) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.SHIPMENT_NUMBER;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'SHIPMENT_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.SHIPMENT_NUMBER;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.SHIPMENT_NUMBER;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.SHIPMENT_NUMBER;
END IF;
END IF; /*  NEXT */

/* END SHIPMENT_NUMBER*/
/****************************/

/****************************/
/* START SHIPMENT_PRIORITY_CODE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SHIPMENT_PRIORITY_CODE,
       p_prior_rec.SHIPMENT_PRIORITY_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'SHIPMENT_PRIORITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.SHIPMENT_PRIORITY_CODE;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.SHIPMENT_PRIORITY(p_curr_rec.SHIPMENT_PRIORITY_CODE);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.SHIPMENT_PRIORITY_CODE;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.SHIPMENT_PRIORITY(p_prior_rec.SHIPMENT_PRIORITY_CODE);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SHIPMENT_PRIORITY_CODE,
       p_next_rec.SHIPMENT_PRIORITY_CODE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.SHIPMENT_PRIORITY(p_curr_rec.SHIPMENT_PRIORITY_CODE);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'SHIPMENT_PRIORITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.SHIPMENT_PRIORITY_CODE;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.SHIPMENT_PRIORITY(p_prior_rec.SHIPMENT_PRIORITY_CODE);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.SHIPMENT_PRIORITY_CODE;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.SHIPMENT_PRIORITY(p_curr_rec.SHIPMENT_PRIORITY_CODE);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.SHIPMENT_PRIORITY_CODE;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.SHIPMENT_PRIORITY(p_next_rec.SHIPMENT_PRIORITY_CODE);
END IF;
END IF; /*  NEXT */

/* END SHIPMENT_PRIORITY_CODE*/
/****************************/

/****************************/
/* START SHIPPED_QUANTITY*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SHIPPED_QUANTITY,
       p_prior_rec.SHIPPED_QUANTITY) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'SHIPPED_QUANTITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.SHIPPED_QUANTITY;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.SHIPPED_QUANTITY;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SHIPPED_QUANTITY,
       p_next_rec.SHIPPED_QUANTITY) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.SHIPPED_QUANTITY;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'SHIPPED_QUANTITY';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.SHIPPED_QUANTITY;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.SHIPPED_QUANTITY;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.SHIPPED_QUANTITY;
END IF;
END IF; /*  NEXT */

/* END SHIPPED_QUANTITY*/
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
   x_line_changed_attr_tbl(ind).attribute_name  := 'ship_from_location';
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
   x_line_changed_attr_tbl(ind).attribute_name := 'ship_from_Location';
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
/* START SHIP_TOLERANCE_ABOVE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SHIP_TOLERANCE_ABOVE,
       p_prior_rec.SHIP_TOLERANCE_ABOVE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'SHIP_TOLERANCE_ABOVE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.SHIP_TOLERANCE_ABOVE;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.SHIP_TOLERANCE_ABOVE;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SHIP_TOLERANCE_ABOVE,
       p_next_rec.SHIP_TOLERANCE_ABOVE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.SHIP_TOLERANCE_ABOVE;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'SHIP_TOLERANCE_ABOVE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.SHIP_TOLERANCE_ABOVE;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.SHIP_TOLERANCE_ABOVE;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.SHIP_TOLERANCE_ABOVE;
END IF;
END IF; /*  NEXT */

/* END SHIP_TOLERANCE_ABOVE*/
/****************************/
/****************************/
/* START SHIP_TOLERANCE_BELOW*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SHIP_TOLERANCE_BELOW,
       p_prior_rec.SHIP_TOLERANCE_BELOW) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'SHIP_TOLERANCE_BELOW';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.SHIP_TOLERANCE_BELOW;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.SHIP_TOLERANCE_BELOW;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SHIP_TOLERANCE_BELOW,
       p_next_rec.SHIP_TOLERANCE_BELOW) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.SHIP_TOLERANCE_BELOW;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'SHIP_TOLERANCE_BELOW';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.SHIP_TOLERANCE_BELOW;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.SHIP_TOLERANCE_BELOW;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.SHIP_TOLERANCE_BELOW;
END IF;
END IF; /*  NEXT */

/* END SHIP_TOLERANCE_BELOW*/
/****************************/

/****************************/
/* START ship_TO_CONTACT_ID*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ship_to_contact_id,
       p_prior_rec.ship_to_contact_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'ship_to_contact';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.ship_to_contact_id;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.ship_To_Contact(p_curr_rec.ship_to_contact_id);
   x_line_changed_attr_tbl(ind).prior_id      := p_prior_rec.ship_to_contact_id;
   x_line_changed_attr_tbl(ind).prior_value   := OE_ID_TO_VALUE.ship_To_Contact(p_prior_rec.ship_to_contact_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.ship_to_contact_id,
       p_next_rec.ship_to_contact_id) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.ship_To_Contact(p_curr_rec.ship_to_contact_id);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name   := 'ship_to_contact';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id      := p_prior_rec.ship_to_contact_id;
   x_line_changed_attr_tbl(ind).prior_value   := OE_ID_TO_VALUE.ship_To_Contact(p_prior_rec.ship_to_contact_id);
   x_line_changed_attr_tbl(ind).current_id   := p_curr_rec.ship_to_contact_id;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.ship_To_Contact(p_curr_rec.ship_to_contact_id);
   x_line_changed_attr_tbl(ind).next_id   := p_next_rec.ship_to_contact_id;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.ship_To_Contact(p_next_rec.ship_to_contact_id);
END IF; /*  NEXT */
END IF;

/* END ship_to_contact_id*/
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
   x_line_changed_attr_tbl(ind).attribute_name  := 'ship_to_location';
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
   x_line_changed_attr_tbl(ind).attribute_name := 'ship_to_location';
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
/* START TAX_EXEMPT_FLAG*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.TAX_EXEMPT_FLAG,
       p_prior_rec.TAX_EXEMPT_FLAG) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'TAX_EXEMPT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.TAX_EXEMPT_FLAG;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Tax_Exempt(p_curr_rec.TAX_EXEMPT_FLAG);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.TAX_EXEMPT_FLAG;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Tax_Exempt(p_prior_rec.TAX_EXEMPT_FLAG);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.TAX_EXEMPT_FLAG,
       p_next_rec.TAX_EXEMPT_FLAG) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Tax_Exempt(p_curr_rec.TAX_EXEMPT_FLAG);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'TAX_EXEMPT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.TAX_EXEMPT_FLAG;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Tax_Exempt(p_prior_rec.TAX_EXEMPT_FLAG);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.TAX_EXEMPT_FLAG;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Tax_Exempt(p_curr_rec.TAX_EXEMPT_FLAG);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.TAX_EXEMPT_FLAG;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Tax_Exempt(p_next_rec.TAX_EXEMPT_FLAG);
END IF;
END IF; /*  NEXT */

/* END TAX_EXEMPT_FLAG*/
/****************************/

/****************************/
/* START TAX_EXEMPT_NUMBER*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.TAX_EXEMPT_NUMBER,
       p_prior_rec.TAX_EXEMPT_NUMBER) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'TAX_EXEMPT_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.TAX_EXEMPT_NUMBER;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.TAX_EXEMPT_NUMBER;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.TAX_EXEMPT_NUMBER,
       p_next_rec.TAX_EXEMPT_NUMBER) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.TAX_EXEMPT_NUMBER;
    END IF;
 null;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'TAX_EXEMPT_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.TAX_EXEMPT_NUMBER;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.TAX_EXEMPT_NUMBER;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.TAX_EXEMPT_NUMBER;
END IF;
END IF; /*  NEXT */

/* END TAX_EXEMPT_NUMBER*/
/****************************/

/****************************/
/* START TAX_EXEMPT_REASON_CODE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.TAX_EXEMPT_REASON_CODE,
       p_prior_rec.TAX_EXEMPT_REASON_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'TAX_EXEMPT_REASON';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.TAX_EXEMPT_REASON_CODE;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Tax_Exempt_Reason(p_curr_rec.TAX_EXEMPT_REASON_CODE);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.TAX_EXEMPT_REASON_CODE;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Tax_Exempt_Reason(p_prior_rec.TAX_EXEMPT_REASON_CODE);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.TAX_EXEMPT_REASON_CODE,
       p_next_rec.TAX_EXEMPT_REASON_CODE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Tax_Exempt_Reason(p_curr_rec.TAX_EXEMPT_REASON_CODE);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'TAX_EXEMPT_REASON';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.TAX_EXEMPT_REASON_CODE;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Tax_Exempt_Reason(p_prior_rec.TAX_EXEMPT_REASON_CODE);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.TAX_EXEMPT_REASON_CODE;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Tax_Exempt_Reason(p_curr_rec.TAX_EXEMPT_REASON_CODE);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.TAX_EXEMPT_REASON_CODE;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Tax_Exempt_Reason(p_next_rec.TAX_EXEMPT_REASON_CODE);
END IF;
END IF; /*  NEXT */

/* END TAX_EXEMPT_REASON_CODE*/
/****************************/


/****************************/
/* START TAX_VALUE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.TAX_VALUE,
       p_prior_rec.TAX_VALUE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'TAX_VALUE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.TAX_VALUE;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.TAX_VALUE;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.TAX_VALUE,
       p_next_rec.TAX_VALUE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.TAX_VALUE;
    END IF;
 null;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'TAX_VALUE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.TAX_VALUE;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.TAX_VALUE;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.TAX_VALUE;
END IF;
END IF; /*  NEXT */

/* END TAX_VALUE*/
/****************************/

/****************************/
/* START UNIT_LIST_PRICE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.UNIT_LIST_PRICE,
       p_prior_rec.UNIT_LIST_PRICE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'UNIT_LIST_PRICE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.UNIT_LIST_PRICE;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.UNIT_LIST_PRICE;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.UNIT_LIST_PRICE,
       p_next_rec.UNIT_LIST_PRICE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.UNIT_LIST_PRICE;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'UNIT_LIST_PRICE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.UNIT_LIST_PRICE;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.UNIT_LIST_PRICE;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.UNIT_LIST_PRICE;
END IF;
END IF; /*  NEXT */

/* END UNIT_LIST_PRICE*/
/****************************/

/****************************/
/* START UNIT_LIST_PRICE_PER_PQTY*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.UNIT_LIST_PERCENT,
       p_prior_rec.UNIT_LIST_PERCENT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'UNIT_LIST_PERCENT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.UNIT_LIST_PERCENT;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.UNIT_LIST_PERCENT;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.UNIT_LIST_PERCENT,
       p_next_rec.UNIT_LIST_PERCENT) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.UNIT_LIST_PERCENT;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'UNIT_LIST_PERCENT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.UNIT_LIST_PERCENT;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.UNIT_LIST_PERCENT;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.UNIT_LIST_PERCENT;
END IF;
END IF; /*  NEXT */

/* END UNIT_LIST_PRICE_PER_PQTY*/
/****************************/

/****************************/
/* START UNIT_SELLING_PRICE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.UNIT_SELLING_PRICE,
       p_prior_rec.UNIT_SELLING_PRICE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'UNIT_SELLING_PRICE_DSP';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.UNIT_SELLING_PRICE;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.UNIT_SELLING_PRICE;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.UNIT_SELLING_PRICE,
       p_next_rec.UNIT_SELLING_PRICE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.UNIT_SELLING_PRICE;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'UNIT_SELLING_PRICE_DSP';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.UNIT_SELLING_PRICE;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.UNIT_SELLING_PRICE;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.UNIT_SELLING_PRICE;
END IF;
END IF; /*  NEXT */

/* END UNIT_SELLING_PRICE*/
/****************************/

/****************************/
/* START UNIT_SELLING_PRICE_PER_PQTY*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.UNIT_SELLING_PERCENT,
       p_prior_rec.UNIT_SELLING_PERCENT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'UNIT_SELLING_PERCENT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.UNIT_SELLING_PERCENT;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.UNIT_SELLING_PERCENT;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.UNIT_SELLING_PERCENT,
       p_next_rec.UNIT_SELLING_PERCENT) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.UNIT_SELLING_PERCENT;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'UNIT_SELLING_PERCENT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.UNIT_SELLING_PERCENT;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.UNIT_SELLING_PERCENT;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.UNIT_SELLING_PERCENT;
END IF;
END IF; /*  NEXT */

/* END UNIT_SELLING_PRICE_PER_PQTY*/
/****************************/

/****************************/
/* START VISIBLE_DEMAND_FLAG*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.VISIBLE_DEMAND_FLAG,
       p_prior_rec.VISIBLE_DEMAND_FLAG) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'VISIBLE_DEMAND_FLAG';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.VISIBLE_DEMAND_FLAG;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.VISIBLE_DEMAND_FLAG;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.VISIBLE_DEMAND_FLAG,
       p_next_rec.VISIBLE_DEMAND_FLAG) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.VISIBLE_DEMAND_FLAG;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'VISIBLE_DEMAND_FLAG';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.VISIBLE_DEMAND_FLAG;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.VISIBLE_DEMAND_FLAG;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.VISIBLE_DEMAND_FLAG;
END IF;
END IF; /*  NEXT */

/* END VISIBLE_DEMAND_FLAG*/
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
END IF; /*  NEXT */
END IF;

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
/* START SERVICE_NUMBER*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SERVICE_NUMBER,
       p_prior_rec.SERVICE_NUMBER) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'SERVICE_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.SERVICE_NUMBER;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.SERVICE_NUMBER;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SERVICE_NUMBER,
       p_next_rec.SERVICE_NUMBER) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.SERVICE_NUMBER;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'SERVICE_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.SERVICE_NUMBER;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.SERVICE_NUMBER;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.SERVICE_NUMBER;
END IF;
END IF; /*  NEXT */

/* END SERVICE_NUMBER*/
/****************************/

/****************************/
/* START SERVICE_REFERENCE_TYPE_CODE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SERVICE_REFERENCE_TYPE_CODE,
       p_prior_rec.SERVICE_REFERENCE_TYPE_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'SERVICE_REFERENCE_TYPE_CODE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.SERVICE_REFERENCE_TYPE_CODE;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.SERVICE_REFERENCE_TYPE_CODE;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SERVICE_REFERENCE_TYPE_CODE,
       p_next_rec.SERVICE_REFERENCE_TYPE_CODE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.SERVICE_REFERENCE_TYPE_CODE;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'SERVICE_REFERENCE_TYPE_CODE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.SERVICE_REFERENCE_TYPE_CODE;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.SERVICE_REFERENCE_TYPE_CODE;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.SERVICE_REFERENCE_TYPE_CODE;
END IF;
END IF; /*  NEXT */

/* END SERVICE_REFERENCE_TYPE_CODE*/
/****************************/

/****************************/
/* START tp_attribute1*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute1,
       p_prior_rec.tp_attribute1) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute1';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute1;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute1;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute1,
       p_next_rec.tp_attribute1) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute1;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute1';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute1;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute1;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute1;
END IF;
END IF; /*  NEXT */

/* END tp_attribute1*/
/****************************/

/****************************/
/* START tp_attribute2*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute2,
       p_prior_rec.tp_attribute2) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute2';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute2;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute2;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute2,
       p_next_rec.tp_attribute2) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute2;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute2';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute2;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute2;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute2;
END IF;
END IF; /*  NEXT */

/* END tp_attribute2*/
/****************************/
/****************************/
/* START tp_attribute3*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute3,
       p_prior_rec.tp_attribute3) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute3';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute3;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute3;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute3,
       p_next_rec.tp_attribute3) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute3;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute3';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute3;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute3;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute3;
END IF;
END IF; /*  NEXT */

/* END tp_attribute3*/
/****************************/

/****************************/
/* START tp_attribute4*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute4,
       p_prior_rec.tp_attribute4) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute4';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute4;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute4;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute4,
       p_next_rec.tp_attribute4) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute4;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute4';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute4;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute4;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute4;
END IF;
END IF; /*  NEXT */

/* END tp_attribute4*/
/****************************/
/****************************/
/* START tp_attribute5*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute5,
       p_prior_rec.tp_attribute5) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute5';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute5;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute5;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute5,
       p_next_rec.tp_attribute5) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute5;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute5';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute5;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute5;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute5;
END IF;
END IF; /*  NEXT */

/* END tp_attribute5*/
/****************************/

/****************************/
/* START tp_attribute6*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute6,
       p_prior_rec.tp_attribute6) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute6';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute6;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute6;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute6,
       p_next_rec.tp_attribute6) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute6;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute6';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute6;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute6;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute6;
END IF;
END IF; /*  NEXT */

/* END tp_attribute6*/
/****************************/
/****************************/
/* START tp_attribute7*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute7,
       p_prior_rec.tp_attribute7) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute7';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute7;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute7;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute7,
       p_next_rec.tp_attribute7) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute7;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute7;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute7';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute7;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute7;
END IF; /*  NEXT */
END IF;

/* END tp_attribute7*/
/****************************/

/****************************/
/* START tp_attribute8*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute8,
       p_prior_rec.tp_attribute8) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute8';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute8;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute8;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute8,
       p_next_rec.tp_attribute8) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute8;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute8';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute8;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute8;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute8;
END IF; /*  NEXT */
END IF;

/* END tp_attribute8*/
/****************************/
/****************************/
/* START tp_attribute9*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute9,
       p_prior_rec.tp_attribute9) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute9';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute9;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute9;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute9,
       p_next_rec.tp_attribute9) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute9;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute9';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute9;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute9;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute9;
END IF;
END IF; /*  NEXT */

/* END tp_attribute9*/
/****************************/

/****************************/
/* START tp_attribute10*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute10,
       p_prior_rec.tp_attribute10) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute10';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute10;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute10;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute10,
       p_next_rec.tp_attribute10) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute10;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute10';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute10;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute10;
END IF; /*  NEXT */
END IF;

/* END tp_attribute10*/
/****************************/

/****************************/
/* START tp_attribute11*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute11,
       p_prior_rec.tp_attribute11) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute11';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute11;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute11;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute11,
       p_next_rec.tp_attribute11) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute11;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute11';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute10;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute11;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute11;
END IF;
END IF; /*  NEXT */

/* END tp_attribute11*/
/****************************/

/****************************/
/* START tp_attribute12*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute12,
       p_prior_rec.tp_attribute12) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute12';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute12;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute12;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute12,
       p_next_rec.tp_attribute12) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute12;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute12';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute12;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute12;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute12;
END IF;
END IF; /*  NEXT */

/* END tp_attribute12*/
/****************************/

/****************************/
/* START tp_attribute13*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute13,
       p_prior_rec.tp_attribute13) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute13';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute13;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute13;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute13,
       p_next_rec.tp_attribute13) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute13;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute13';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute13;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute13;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute13;
END IF;
END IF; /*  NEXT */

/* END tp_attribute13*/
/****************************/

/****************************/
/* START tp_attribute14*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute14,
       p_prior_rec.tp_attribute14) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute14';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute14;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute14;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute14,
       p_next_rec.tp_attribute14) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute14;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute14';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute14;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute14;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute14;
END IF;
END IF; /*  NEXT */

/* END tp_attribute14*/
/****************************/

/****************************/
/* START tp_attribute15*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute15,
       p_prior_rec.tp_attribute15) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'attribute15';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_attribute15;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute15;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_attribute15,
       p_next_rec.tp_attribute15) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_attribute15;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'attribute15';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_attribute15;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_attribute15;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.tp_attribute15;
END IF; /*  NEXT */
END IF;

/* END tp_attribute15*/
/****************************/

/****************************/
/* START tp_context*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_context,
       p_prior_rec.tp_context) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'tp_context';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.tp_context;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_context;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.tp_context,
       p_next_rec.tp_context) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.tp_context;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'tp_context';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.tp_context;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.tp_context;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.tp_context;
END IF;
END IF; /*  NEXT */

/* END tp_context*/
/****************************/

/****************************/
/* START FLOW_STATUS_CODE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.FLOW_STATUS_CODE,
       p_prior_rec.FLOW_STATUS_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'STATUS';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.FLOW_STATUS_CODE;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Flow_Status(p_curr_rec.FLOW_STATUS_CODE);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.FLOW_STATUS_CODE;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Flow_Status(p_prior_rec.FLOW_STATUS_CODE);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.FLOW_STATUS_CODE,
       p_next_rec.FLOW_STATUS_CODE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Flow_Status(p_curr_rec.FLOW_STATUS_CODE);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'STATUS';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.FLOW_STATUS_CODE;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Flow_Status(p_prior_rec.FLOW_STATUS_CODE);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.FLOW_STATUS_CODE;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Flow_Status(p_curr_rec.FLOW_STATUS_CODE);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.FLOW_STATUS_CODE;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Flow_Status(p_next_rec.FLOW_STATUS_CODE);
END IF;
END IF; /*  NEXT */

/* END FLOW_STATUS_CODE*/
/****************************/

/****************************/
/* START CALCULATE_PRICE_FLAG*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CALCULATE_PRICE_FLAG,
       p_prior_rec.CALCULATE_PRICE_FLAG) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'CALCULATE_PRICE_DESCR'; -- 'CALCULATE_PRICE_FLAG'; Bug 7574224
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.CALCULATE_PRICE_FLAG;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.CALCULATE_PRICE_FLAG;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.CALCULATE_PRICE_FLAG,
       p_next_rec.CALCULATE_PRICE_FLAG) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.CALCULATE_PRICE_FLAG;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'CALCULATE_PRICE_DESCR'; --'CALCULATE_PRICE_FLAG'; Bug 7574224
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.CALCULATE_PRICE_FLAG;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.CALCULATE_PRICE_FLAG;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.CALCULATE_PRICE_FLAG;
END IF;
END IF; /*  NEXT */

/* END CALCULATE_PRICE_FLAG*/
/****************************/

/****************************/
/* START COMMITMENT_ID*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.COMMITMENT_ID,
       p_prior_rec.COMMITMENT_ID) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'COMMITMENT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.COMMITMENT_ID;
   x_line_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.Commitment(p_curr_rec.COMMITMENT_ID);
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.COMMITMENT_ID;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Commitment(p_prior_rec.COMMITMENT_ID);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.COMMITMENT_ID,
       p_next_rec.COMMITMENT_ID) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Commitment(p_curr_rec.COMMITMENT_ID);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'COMMITMENT';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.COMMITMENT_ID;
   x_line_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.Commitment(p_prior_rec.COMMITMENT_ID);
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.COMMITMENT_ID;
   x_line_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.Commitment(p_curr_rec.COMMITMENT_ID);
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.COMMITMENT_ID;
   x_line_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.Commitment(p_next_rec.COMMITMENT_ID);
END IF;
END IF; /*  NEXT */

/* END COMMITMENT_ID*/
/****************************/


/****************************/
/* START Item_Relationship_Type*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.Item_Relationship_Type,
       p_prior_rec.Item_Relationship_Type) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'Item_Relationship_Type_dsp';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   if p_curr_rec.Item_Relationship_Type is not null then
     OE_ID_TO_VALUE.Item_Relationship_Type
         (   p_Item_Relationship_Type        => p_curr_rec.item_relationship_type
	   , x_Item_Relationship_Type_Dsp    => x_current_item_rel_type
          );
   x_line_changed_attr_tbl(ind).current_id      := p_curr_rec.Item_Relationship_Type;
   x_line_changed_attr_tbl(ind).current_value     := x_current_item_rel_type;
   end if;

   if p_prior_rec.Item_Relationship_Type is not null then
     OE_ID_TO_VALUE.Item_Relationship_Type
         (   p_Item_Relationship_Type        => p_prior_rec.item_relationship_type
	   , x_Item_Relationship_Type_Dsp    => x_prior_item_rel_type
          );

   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.Item_Relationship_Type;
   x_line_changed_attr_tbl(ind).prior_value     := x_prior_item_rel_type;
   end if;
END IF;
END IF; /*  PRIOR */
/****************************/

IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.Item_Relationship_Type,
       p_next_rec.Item_Relationship_Type) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value     := x_current_item_rel_type;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'Item_Relationship_Type_dsp';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;

   if p_prior_rec.Item_Relationship_Type is not null then
     OE_ID_TO_VALUE.item_relationship_type
         (   p_Item_Relationship_Type        => p_prior_rec.item_relationship_type
	   , x_Item_Relationship_Type_Dsp    => x_prior_item_rel_type
          );
   x_line_changed_attr_tbl(ind).prior_id        := p_prior_rec.Item_Relationship_Type;
   x_line_changed_attr_tbl(ind).prior_value     := x_prior_item_rel_type;
   end if;

   if p_curr_rec.Item_Relationship_Type is not null then
     OE_ID_TO_VALUE.Item_Relationship_Type
         (   p_Item_Relationship_Type        => p_curr_Rec.item_relationship_type
	   , x_Item_Relationship_Type_Dsp    => x_current_item_rel_type
          );
   x_line_changed_attr_tbl(ind).current_id     := p_curr_rec.Item_Relationship_Type;
   x_line_changed_attr_tbl(ind).current_value     := x_current_item_rel_type;
   END IF;

   if p_next_rec.Item_Relationship_Type is not null then
     OE_ID_TO_VALUE.Item_Relationship_Type
         (   p_Item_Relationship_Type        => p_next_Rec.item_relationship_type
	   , x_Item_Relationship_Type_Dsp    => x_next_item_rel_type
          );
   x_line_changed_attr_tbl(ind).next_id      := p_next_rec.Item_Relationship_Type;
   x_line_changed_attr_tbl(ind).next_value     := x_next_item_rel_type;
   END IF;
END IF;
END IF; /*  NEXT */

/* END Item_Relationship_Type*/
/****************************/

/****************************/
/* START LATE_DEMAND_PENALTY_FACTOR*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.LATE_DEMAND_PENALTY_FACTOR,
       p_prior_rec.LATE_DEMAND_PENALTY_FACTOR) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'LATE_DEMAND_PENALTY_FACTOR';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.LATE_DEMAND_PENALTY_FACTOR;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.LATE_DEMAND_PENALTY_FACTOR;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.LATE_DEMAND_PENALTY_FACTOR,
       p_next_rec.LATE_DEMAND_PENALTY_FACTOR) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.LATE_DEMAND_PENALTY_FACTOR;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'LATE_DEMAND_PENALTY_FACTOR';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.LATE_DEMAND_PENALTY_FACTOR;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.LATE_DEMAND_PENALTY_FACTOR;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.LATE_DEMAND_PENALTY_FACTOR;
END IF;
END IF; /*  NEXT */

/* END LATE_DEMAND_PENALTY_FACTOR*/
/****************************/

/****************************/
/* START OVERRIDE_ATP_DATE_CODE*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.OVERRIDE_ATP_DATE_CODE,
       p_prior_rec.OVERRIDE_ATP_DATE_CODE) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'OVERRIDE_ATP_DATE_CODE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.OVERRIDE_ATP_DATE_CODE;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.OVERRIDE_ATP_DATE_CODE;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.OVERRIDE_ATP_DATE_CODE,
       p_next_rec.OVERRIDE_ATP_DATE_CODE) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.OVERRIDE_ATP_DATE_CODE;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'OVERRIDE_ATP_DATE_CODE';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.OVERRIDE_ATP_DATE_CODE;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.OVERRIDE_ATP_DATE_CODE;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.OVERRIDE_ATP_DATE_CODE;
END IF; /*  NEXT */
END IF;

/* END OVERRIDE_ATP_DATE_CODE*/
/****************************/



/****************************/
/* START USER_ITEM_DESCRIPTION*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.USER_ITEM_DESCRIPTION,
       p_prior_rec.USER_ITEM_DESCRIPTION) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'USER_ITEM_DESCRIPTION';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.USER_ITEM_DESCRIPTION;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.USER_ITEM_DESCRIPTION;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.USER_ITEM_DESCRIPTION,
       p_next_rec.USER_ITEM_DESCRIPTION) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.USER_ITEM_DESCRIPTION;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'USER_ITEM_DESCRIPTION';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.USER_ITEM_DESCRIPTION;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.USER_ITEM_DESCRIPTION;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.USER_ITEM_DESCRIPTION;
END IF;
END IF; /*  NEXT */

/* END USER_ITEM_DESCRIPTION*/
/****************************/


/****************************/
/* START BLANKET_LINE_NUMBER*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.BLANKET_LINE_NUMBER,
       p_prior_rec.BLANKET_LINE_NUMBER) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'BLANKET_LINE_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.BLANKET_LINE_NUMBER;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.BLANKET_LINE_NUMBER;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.BLANKET_LINE_NUMBER,
       p_next_rec.BLANKET_LINE_NUMBER) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.BLANKET_LINE_NUMBER;
    END IF;
 null;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'BLANKET_LINE_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.BLANKET_LINE_NUMBER;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.BLANKET_LINE_NUMBER;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.BLANKET_LINE_NUMBER;
END IF;
END IF; /*  NEXT */

/* END BLANKET_LINE_NUMBER*/
/****************************/

/****************************/
/* START BLANKET_VERSION_NUMBER*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.BLANKET_VERSION_NUMBER,
       p_prior_rec.BLANKET_VERSION_NUMBER) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'BLANKET_VERSION_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.BLANKET_VERSION_NUMBER;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.BLANKET_VERSION_NUMBER;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.BLANKET_VERSION_NUMBER,
       p_next_rec.BLANKET_VERSION_NUMBER) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.BLANKET_VERSION_NUMBER;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'BLANKET_VERSION_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.BLANKET_VERSION_NUMBER;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.BLANKET_VERSION_NUMBER;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.BLANKET_VERSION_NUMBER;
END IF;
END IF; /*  NEXT */

/* END BLANKET_VERSION_NUMBER*/
/****************************/


/****************************/
/* START COMPONENT_NUMBER*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.COMPONENT_NUMBER,
       p_prior_rec.COMPONENT_NUMBER) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'COMPONENT_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.COMPONENT_NUMBER;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.COMPONENT_NUMBER;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.COMPONENT_NUMBER,
       p_next_rec.COMPONENT_NUMBER) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.COMPONENT_NUMBER;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'COMPONENT_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.COMPONENT_NUMBER;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.COMPONENT_NUMBER;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.COMPONENT_NUMBER;
END IF; /*  NEXT */
END IF;

/* END COMPONENT_NUMBER*/
/****************************/

/****************************/
/* START SERVICE_NUMBER*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SERVICE_NUMBER,
       p_prior_rec.SERVICE_NUMBER) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_changed_attr_tbl(ind).attribute_name  := 'SERVICE_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).current_value      := p_curr_rec.SERVICE_NUMBER;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.SERVICE_NUMBER;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.SERVICE_NUMBER,
       p_next_rec.SERVICE_NUMBER) THEN
    IF prior_exists = 'Y' THEN
   x_line_changed_attr_tbl(ind).next_value      := p_curr_rec.SERVICE_NUMBER;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_changed_attr_tbl(ind).attribute_name := 'SERVICE_NUMBER';
   x_line_changed_attr_tbl(ind).line_number     := x_line_number;
   x_line_changed_attr_tbl(ind).prior_value        := p_prior_rec.SERVICE_NUMBER;
   x_line_changed_attr_tbl(ind).current_value     := p_curr_rec.SERVICE_NUMBER;
   x_line_changed_attr_tbl(ind).next_value      := p_next_rec.SERVICE_NUMBER;
END IF;
END IF; /*  NEXT */

/* END SERVICE_NUMBER*/
/****************************/


ELSE
NULL;
END IF;
END IF; /* line_id not null */
IF l_debug_level > 0 THEN
  oe_debug_pub.add('******AFTER COMPARING ATTRIBUTES*************');
  oe_debug_pub.add('current ind '|| ind);
END IF;
IF l_debug_level  > 0 THEN
   oe_debug_pub.add(' Exiting OE_VERSION_COMP.Compare_Line_Attributes ');
END IF;
/*
j := 0;
dbms_output.put_line('No of records'||x_line_changed_attr_tbl.count);
WHILE j < x_line_changed_attr_tbl.count
LOOP
j:=j+1;
dbms_output.put_line('attribute value '||x_line_changed_attr_tbl(j).attribute_name ||' Prior '||x_line_changed_attr_tbl(j).prior_value||' Current '||x_line_changed_attr_tbl(j).current_value || ' Next '||x_line_changed_attr_tbl(j).next_value);
END LOOP;
*/
END COMPARE_LINE_ATTRIBUTES;

PROCEDURE COMPARE_LINE_VERSIONS
(p_header_id	                  NUMBER,
 p_line_id	                  NUMBER,
 p_prior_version                  NUMBER,
 p_current_version                NUMBER,
 p_next_version                   NUMBER,
 g_max_version                    NUMBER,
 g_trans_version                  NUMBER,
 g_prior_phase_change_flag	  VARCHAR2,
 g_curr_phase_change_flag	  VARCHAR2,
 g_next_phase_change_flag	  VARCHAR2,
 x_line_changed_attr_tbl        IN OUT NOCOPY OE_VERSION_COMP.line_tbl_type)
IS

l_line_id NUMBER;
CURSOR C_get_lines(p_header_id IN NUMBER,p_prior_version IN NUMBER, p_current_version IN NUMBER, p_next_version IN NUMBER) IS
           SELECT distinct line_id
           from oe_order_lines_history
           where header_id = p_header_id
           --Bug 8478088
           and version_flag = 'Y'
           --and transaction_phase_code = p_transaction_phase_code
           and version_number in (p_prior_version,p_current_version,p_next_version)
           union
           SELECT line_id
           from oe_order_lines_all
           where header_id=p_header_id;

CURSOR C_get_hist_lines(p_header_id IN NUMBER,p_prior_version IN NUMBER, p_current_version IN NUMBER, p_next_version IN NUMBER) IS
           SELECT distinct line_id
           from oe_order_lines_history
           where header_id = p_header_id
           --Bug 8478088
           and version_flag = 'Y'
           --and transaction_phase_code = p_transaction_phase_code
           and version_number in (p_prior_version,p_current_version,p_next_version);
ind1 NUMBER;
total_lines NUMBER;
x_line_number VARCHAR2(30);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering Compare_Line_versions');
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
    FETCH C_GET_LINES INTO l_line_id;
    EXIT WHEN C_GET_LINES%NOTFOUND;
    IF l_debug_level  > 0 THEN
         oe_debug_pub.add('*************lines found(trans)******************'||l_line_id);
    END IF;

     IF l_line_id IS NOT NULL THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************before call total lines(trans) ******************'||ind1);
         END IF;
         select oe_order_misc_pub.get_concat_line_number(l_line_id) into x_line_number from dual;
         IF x_line_number IS NULL THEN
          -- bug 9299752
           begin
            select oe_order_misc_pub.get_concat_hist_line_number(l_line_id) into x_line_number from dual;
           exception
            when others then
             select oe_order_misc_pub.get_concat_hist_line_number(l_line_id,p_current_version) into x_line_number from dual;
           end;
           -- bug 9299752
         END IF;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************line_number ******************'||x_line_number);
         END IF;
         COMPARE_LINE_ATTRIBUTES(p_header_id                 => p_header_id,
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
        --      ind1 := ind1 + total_lines;
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
    FETCH C_GET_HIST_LINES INTO l_line_id;
    EXIT WHEN C_GET_HIST_LINES%NOTFOUND;
    IF l_debug_level  > 0 THEN
         oe_debug_pub.add('*************lines found******************'||l_line_id);
    END IF;

     IF l_line_id IS NOT NULL THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************before call total lines ******************'||ind1);
         END IF;
         -- bug 9299752
         begin
           select oe_order_misc_pub.get_concat_hist_line_number(l_line_id) into x_line_number from dual;
         exception
	  when others then
	   select oe_order_misc_pub.get_concat_hist_line_number(l_line_id,p_current_version) into x_line_number from dual;
	          end;
         -- bug 9299752
         COMPARE_LINE_ATTRIBUTES(p_header_id                 => p_header_id,
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
        --      ind1 := ind1 + total_lines;
         END IF;
     END IF; /* line_id is not null */
    END LOOP;
    CLOSE C_GET_HIST_LINES;
 END IF;/* next equals trans */
END IF;/*header_id is not null*/
END COMPARE_LINE_VERSIONS;
/***************************************/

PROCEDURE QUERY_HEADER_SC_ROW
(p_header_id	                  NUMBER,
 p_sales_credit_id                NUMBER,
 p_version	                  NUMBER,
 p_phase_change_flag	          VARCHAR2,
 x_header_scredit_rec                    IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Rec_Type)
IS
l_org_id                NUMBER;
l_phase_change_flag                VARCHAR2(1);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering OE_VERSION_COMP.QUERY_HEADER_SC_ROW', 1);
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('sales credit' ||p_sales_credit_id);
  oe_debug_pub.add('version' ||p_version);
END IF;

    l_org_id := OE_GLOBALS.G_ORG_ID;

    IF l_org_id IS NULL THEN
      OE_GLOBALS.Set_Context;
      l_org_id := OE_GLOBALS.G_ORG_ID;
    END IF;


   SELECT  ATTRIBUTE1
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
    ,       DW_UPDATE_ADVICE_FLAG
    ,       HEADER_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       PERCENT
    ,       SALESREP_ID
    ,       sales_credit_type_id
    ,       SALES_CREDIT_ID
    ,       WH_UPDATE_DATE
    ,      SALES_GROUP_ID
    ,       SALES_GROUP_UPDATED_FLAG
    ,       LOCK_CONTROL
INTO
     x_header_scredit_rec.ATTRIBUTE1
    ,x_header_scredit_rec.ATTRIBUTE10
    ,x_header_scredit_rec.ATTRIBUTE11
    ,x_header_scredit_rec.ATTRIBUTE12
    ,x_header_scredit_rec.ATTRIBUTE13
    ,x_header_scredit_rec.ATTRIBUTE14
    ,x_header_scredit_rec.ATTRIBUTE15
    ,x_header_scredit_rec.ATTRIBUTE2
    ,x_header_scredit_rec.ATTRIBUTE3
    ,x_header_scredit_rec.ATTRIBUTE4
    ,x_header_scredit_rec.ATTRIBUTE5
    ,x_header_scredit_rec.ATTRIBUTE6
    ,x_header_scredit_rec.ATTRIBUTE7
    ,x_header_scredit_rec.ATTRIBUTE8
    ,x_header_scredit_rec.ATTRIBUTE9
    ,x_header_scredit_rec.CONTEXT
    ,x_header_scredit_rec.CREATED_BY
    ,x_header_scredit_rec.CREATION_DATE
    ,x_header_scredit_rec.DW_UPDATE_ADVICE_FLAG
    ,x_header_scredit_rec.HEADER_ID
    ,x_header_scredit_rec.LAST_UPDATED_BY
    ,x_header_scredit_rec.LAST_UPDATE_DATE
    ,x_header_scredit_rec.LAST_UPDATE_LOGIN
    ,x_header_scredit_rec.LINE_ID
    ,x_header_scredit_rec.PERCENT
    ,x_header_scredit_rec.SALESREP_ID
    ,x_header_scredit_rec.sales_credit_type_id
    ,x_header_scredit_rec.SALES_CREDIT_ID
    ,x_header_scredit_rec.WH_UPDATE_DATE
    ,x_header_scredit_rec.SALES_GROUP_ID
    ,x_header_scredit_rec.SALES_GROUP_UPDATED_FLAG
    ,x_header_scredit_rec.LOCK_CONTROL
  FROM OE_SALES_CREDIT_HISTORY
  WHERE
         HEADER_ID              = p_header_id
	 AND sales_credit_id    = p_sales_credit_id
         AND LINE_ID IS NULL
         AND VERSION_NUMBER     =   p_version
         AND   (PHASE_CHANGE_FLAG = p_phase_change_flag
         OR    (nvl(p_phase_change_flag, 'NULL') <> 'Y'
         AND    VERSION_FLAG = 'Y'));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    --       RAISE NO_DATA_FOUND;
	 null;
    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
               'Query_HEADER_SC_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END QUERY_HEADER_SC_ROW;

PROCEDURE QUERY_HEADER_SC_TRANS_ROW
(p_header_id	                  NUMBER,
 p_sales_credit_id                NUMBER,
 p_version	                  NUMBER,
 x_header_scredit_rec             IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Rec_Type)
IS
l_org_id                NUMBER;
l_phase_change_flag                VARCHAR2(1);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering OE_VERSION_COMP.QUERY_HEADER_SC_TRANS_ROW');
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('version' ||p_version);
END IF;

    l_org_id := OE_GLOBALS.G_ORG_ID;

    IF l_org_id IS NULL THEN
      OE_GLOBALS.Set_Context;
      l_org_id := OE_GLOBALS.G_ORG_ID;
    END IF;

   SELECT  ATTRIBUTE1
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
    ,       DW_UPDATE_ADVICE_FLAG
    ,       HEADER_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       PERCENT
    ,       SALESREP_ID
    ,       sales_credit_type_id
    ,       SALES_CREDIT_ID
    ,       WH_UPDATE_DATE
    ,      SALES_GROUP_ID
    ,       SALES_GROUP_UPDATED_FLAG
    ,       LOCK_CONTROL
INTO
     x_header_scredit_rec.ATTRIBUTE1
    ,x_header_scredit_rec.ATTRIBUTE10
    ,x_header_scredit_rec.ATTRIBUTE11
    ,x_header_scredit_rec.ATTRIBUTE12
    ,x_header_scredit_rec.ATTRIBUTE13
    ,x_header_scredit_rec.ATTRIBUTE14
    ,x_header_scredit_rec.ATTRIBUTE15
    ,x_header_scredit_rec.ATTRIBUTE2
    ,x_header_scredit_rec.ATTRIBUTE3
    ,x_header_scredit_rec.ATTRIBUTE4
    ,x_header_scredit_rec.ATTRIBUTE5
    ,x_header_scredit_rec.ATTRIBUTE6
    ,x_header_scredit_rec.ATTRIBUTE7
    ,x_header_scredit_rec.ATTRIBUTE8
    ,x_header_scredit_rec.ATTRIBUTE9
    ,x_header_scredit_rec.CONTEXT
    ,x_header_scredit_rec.CREATED_BY
    ,x_header_scredit_rec.CREATION_DATE
    ,x_header_scredit_rec.DW_UPDATE_ADVICE_FLAG
    ,x_header_scredit_rec.HEADER_ID
    ,x_header_scredit_rec.LAST_UPDATED_BY
    ,x_header_scredit_rec.LAST_UPDATE_DATE
    ,x_header_scredit_rec.LAST_UPDATE_LOGIN
    ,x_header_scredit_rec.LINE_ID
    ,x_header_scredit_rec.PERCENT
    ,x_header_scredit_rec.SALESREP_ID
    ,x_header_scredit_rec.sales_credit_type_id
    ,x_header_scredit_rec.SALES_CREDIT_ID
    ,x_header_scredit_rec.WH_UPDATE_DATE
    ,x_header_scredit_rec.SALES_GROUP_ID
    ,x_header_scredit_rec.SALES_GROUP_UPDATED_FLAG
    ,x_header_scredit_rec.LOCK_CONTROL
  FROM OE_SALES_CREDITS
  WHERE
         HEADER_ID = p_header_id
         AND sales_credit_id = p_sales_credit_id
         AND LINE_ID IS NULL;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    --       RAISE NO_DATA_FOUND;
	 null;
    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
               'Query_HEADER_SC_Trans_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END QUERY_HEADER_SC_TRANS_ROW;

PROCEDURE COMPARE_HEADER_SC_ATTRIBUTES
(p_header_id	                  NUMBER,
 p_sales_credit_id	          NUMBER,
 p_prior_version                  NUMBER,
 p_current_version                NUMBER,
 p_next_version                   NUMBER,
 g_max_version                    NUMBER,
 g_trans_version                  NUMBER,
 g_prior_phase_change_flag	  VARCHAR2,
 g_curr_phase_change_flag	  VARCHAR2,
 g_next_phase_change_flag	  VARCHAR2,
 x_header_sc_changed_attr_tbl     IN OUT NOCOPY OE_VERSION_COMP.header_sc_tbl_type,
 p_total_lines                    NUMBER)
IS
p_curr_rec                       OE_Order_PUB.Header_scredit_Rec_Type;
p_next_rec                       OE_Order_PUB.Header_scredit_Rec_Type;
p_prior_rec                      OE_Order_PUB.Header_scredit_Rec_Type;


v_totcol NUMBER:=10;
v_header_col VARCHAR2(50);
ind NUMBER;
prior_exists VARCHAR2(1) := 'N';
j NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
p_prior_rec_exists VARCHAR2(1) := 'N';
p_curr_rec_exists VARCHAR2(1)  := 'N';
p_next_rec_exists VARCHAR2(1)  := 'N';
p_trans_rec_exists VARCHAR2(1)  := 'N';
BEGIN

IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering  comparing_header_sc_attributes');
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('Sales Credit' ||p_sales_credit_id);
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

IF p_sales_credit_id IS NOT NULL THEN

p_prior_rec := NULL;
p_curr_rec := NULL;
p_next_rec := NULL;

IF l_debug_level > 0 THEN
  oe_debug_pub.add(' Quering prior line version details');
  oe_debug_pub.add('prior version' ||p_prior_version);
END IF;

IF p_prior_version IS NOT NULL THEN
OE_VERSION_COMP.QUERY_HEADER_SC_ROW(p_header_id       => p_header_id,
                          p_sales_credit_id           => p_sales_credit_id,
                          p_version                   => p_prior_version,
                          p_phase_change_flag         => g_prior_phase_change_flag,
			  x_header_scredit_rec        => p_prior_rec);
     IF p_prior_rec.sales_credit_id is NULL THEN
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
OE_VERSION_COMP.QUERY_HEADER_SC_ROW(p_header_id       => p_header_id,
                          p_sales_credit_id           => p_sales_credit_id,
			  p_version                   => p_current_version,
                          p_phase_change_flag         => g_curr_phase_change_flag,
			  x_header_scredit_rec        => p_curr_rec);
     IF p_curr_rec.sales_credit_id is NULL THEN
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
OE_VERSION_COMP.QUERY_HEADER_SC_TRANS_ROW(p_header_id       => p_header_id,
                          p_sales_credit_id           => p_sales_credit_id,
                          p_version                   => p_next_version,
			  x_header_scredit_rec        => p_next_rec);
       END IF;
     IF p_next_rec.sales_credit_id is NULL THEN
          p_trans_rec_exists := 'N';
     ELSE
          p_trans_rec_exists := 'Y';
          p_next_rec_exists := 'Y';
     END IF;
ELSE
IF p_next_version IS NOT NULL THEN
OE_VERSION_COMP.QUERY_HEADER_SC_ROW(p_header_id       => p_header_id,
                          p_sales_credit_id           => p_sales_credit_id,
                          p_version                   => p_next_version,
                          p_phase_change_flag         => g_next_phase_change_flag,
			  x_header_scredit_rec        => p_next_rec);
     IF p_next_rec.sales_credit_id is NULL THEN
          p_next_rec_exists := 'N';
     ELSE
          p_next_rec_exists := 'Y';
     END IF;
END IF;
END IF;

IF l_debug_level > 0 THEN
oe_debug_pub.add(' p_prior_rec salesrep'||p_prior_rec.salesrep_id);
oe_debug_pub.add(' p_curr_rec '||p_curr_rec.salesrep_id);
oe_debug_pub.add(' p_next_rec '||p_next_rec.salesrep_id);
oe_debug_pub.add(' p_prior_rec sales group'||p_prior_rec.sales_group_id);
oe_debug_pub.add(' p_curr_rec '||p_curr_rec.sales_group_id);
oe_debug_pub.add(' p_next_rec '||p_next_rec.sales_group_id);
    oe_debug_pub.add(' checking whether salesreps are same or not');
    oe_debug_pub.add(' p_prior_rec_exists'||p_prior_rec_exists);
    oe_debug_pub.add(' p_curr_rec_exists'||p_curr_rec_exists);
    oe_debug_pub.add(' p_next_rec_exists'||p_next_rec_exists);
    oe_debug_pub.add(' p_trans_rec_exists'||p_trans_rec_exists);
END IF;
IF l_debug_level > 0 THEN
  oe_debug_pub.add('******AFTER COMPARING SC ATTRIBUTES*************');
  oe_debug_pub.add('current ind '|| ind);
END IF;
IF  (p_prior_rec_exists = 'Y' and p_curr_rec_exists ='Y') OR
    (p_curr_rec_exists = 'Y' and p_next_rec_exists ='Y') THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' both exists - checking if both are same');
         END IF;
       IF OE_Globals.Equal(p_prior_rec.salesrep_id,p_curr_rec.salesrep_id) OR
         OE_Globals.Equal( p_curr_rec.salesrep_id, p_next_rec.salesrep_id) THEN
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
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name  := 'attribute1';
   x_header_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute1;
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute1;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute1,
       p_next_rec.attribute1) THEN
    IF prior_exists = 'Y' THEN
   x_header_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute1;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name := 'attribute1';
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute1;
   x_header_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute1;
   x_header_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute1;
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
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name  := 'attribute2';
   x_header_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute2;
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute2;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute2,
       p_next_rec.attribute2) THEN
    IF prior_exists = 'Y' THEN
   x_header_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute2;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name := 'attribute2';
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute2;
   x_header_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute2;
   x_header_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute2;
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
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name  := 'attribute3';
   x_header_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute3;
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute3;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute3,
       p_next_rec.attribute3) THEN
    IF prior_exists = 'Y' THEN
   x_header_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute3;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name := 'attribute3';
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute3;
   x_header_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute3;
   x_header_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute3;
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
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name  := 'attribute4';
   x_header_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute4;
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute4;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute4,
       p_next_rec.attribute4) THEN
    IF prior_exists = 'Y' THEN
   x_header_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute4;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name := 'attribute4';
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute4;
   x_header_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute4;
   x_header_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute4;
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
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name  := 'attribute5';
   x_header_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute5;
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute5;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute5,
       p_next_rec.attribute5) THEN
    IF prior_exists = 'Y' THEN
   x_header_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute5;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name := 'attribute5';
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute5;
   x_header_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute5;
   x_header_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute5;
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
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name  := 'attribute6';
   x_header_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute6;
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute6;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute6,
       p_next_rec.attribute6) THEN
    IF prior_exists = 'Y' THEN
   x_header_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute6;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_sc_changed_attr_tbl(ind).attribute_name := 'attribute6';
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute6;
   x_header_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute6;
   x_header_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute6;
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
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name  := 'attribute7';
   x_header_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute7;
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute7;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute7,
       p_next_rec.attribute7) THEN
    IF prior_exists = 'Y' THEN
   x_header_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute7;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name := 'attribute7';
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute7;
   x_header_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute7;
   x_header_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute7;
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
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name  := 'attribute8';
   x_header_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute8;
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute8;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute8,
       p_next_rec.attribute8) THEN
    IF prior_exists = 'Y' THEN
   x_header_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute8;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name := 'attribute8';
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute8;
   x_header_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute8;
   x_header_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute8;
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
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name  := 'attribute9';
   x_header_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute9;
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute9;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute9,
       p_next_rec.attribute9) THEN
    IF prior_exists = 'Y' THEN
   x_header_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute9;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name := 'attribute9';
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute9;
   x_header_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute9;
   x_header_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute9;
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
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name  := 'attribute10';
   x_header_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute10;
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute10;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute10,
       p_next_rec.attribute10) THEN
    IF prior_exists = 'Y' THEN
   x_header_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute10;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name := 'attribute10';
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute10;
   x_header_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute10;
   x_header_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute10;
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
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name  := 'attribute11';
   x_header_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute11;
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute11;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute11,
       p_next_rec.attribute11) THEN
    IF prior_exists = 'Y' THEN
   x_header_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute11;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name := 'attribute11';
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute11;
   x_header_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute11;
   x_header_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute11;
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
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name  := 'attribute12';
   x_header_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute12;
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute12;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute12,
       p_next_rec.attribute12) THEN
    IF prior_exists = 'Y' THEN
   x_header_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute12;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name := 'attribute12';
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute12;
   x_header_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute12;
   x_header_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute12;
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
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name  := 'attribute13';
   x_header_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute13;
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute13;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute13,
       p_next_rec.attribute13) THEN
    IF prior_exists = 'Y' THEN
   x_header_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute13;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name := 'attribute13';
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute13;
   x_header_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute13;
   x_header_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute13;
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
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name  := 'attribute14';
   x_header_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute14;
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute14;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute14,
       p_next_rec.attribute14) THEN
    IF prior_exists = 'Y' THEN
   x_header_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute14;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name := 'attribute14';
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute14;
   x_header_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute14;
   x_header_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute14;
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
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name  := 'attribute15';
   x_header_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute15;
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute15;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute15,
       p_next_rec.attribute15) THEN
    IF prior_exists = 'Y' THEN
   x_header_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute15;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name := 'attribute15';
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute15;
   x_header_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute15;
   x_header_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute15;
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
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name  := 'context';
   x_header_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.context;
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.context;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.context,
       p_next_rec.context) THEN
    IF prior_exists = 'Y' THEN
   x_header_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.context;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name := 'context';
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.context;
   x_header_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.context;
   x_header_sc_changed_attr_tbl(ind).next_value      := p_next_rec.context;
END IF;
END IF; /*  NEXT */

/* END context*/

/****************************/

/****************************/
/* START PERCENT*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.PERCENT,
       p_prior_rec.PERCENT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name  := 'PERCENT';
   x_header_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.PERCENT;
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.PERCENT;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.PERCENT,
       p_next_rec.PERCENT) THEN
    IF prior_exists = 'Y' THEN
   x_header_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.PERCENT;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name := 'PERCENT';
   x_header_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.PERCENT;
   x_header_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.PERCENT;
   x_header_sc_changed_attr_tbl(ind).next_value      := p_next_rec.PERCENT;
END IF;
END IF; /*  NEXT */

/* END PERCENT*/
/****************************/
/****************************/
/* START sales_credit_type_id*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.sales_credit_type_id,
       p_prior_rec.sales_credit_type_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name  := 'sales_credit_type';
   x_header_sc_changed_attr_tbl(ind).current_id      := p_curr_rec.sales_credit_type_id;
   x_header_sc_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.sales_credit_type(p_curr_rec.sales_credit_type_id);
   x_header_sc_changed_attr_tbl(ind).prior_id        := p_prior_rec.sales_credit_type_id;
   x_header_sc_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.sales_credit_type(p_prior_rec.sales_credit_type_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.sales_credit_type_id,
       p_next_rec.sales_credit_type_id) THEN
    IF prior_exists = 'Y' THEN
   x_header_sc_changed_attr_tbl(ind).next_value  := OE_ID_TO_VALUE.sales_credit_type(p_curr_rec.sales_credit_type_id);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name := 'sales_credit_type';
   x_header_sc_changed_attr_tbl(ind).prior_id        := p_prior_rec.sales_credit_type_id;
   x_header_sc_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.sales_credit_type(p_prior_rec.sales_credit_type_id);
   x_header_sc_changed_attr_tbl(ind).current_id     := p_curr_rec.sales_credit_type_id;
   x_header_sc_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.sales_credit_type(p_curr_rec.sales_credit_type_id);
   x_header_sc_changed_attr_tbl(ind).next_id      := p_next_rec.sales_credit_type_id;
   x_header_sc_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.sales_credit_type(p_next_rec.sales_credit_type_id);
END IF;
END IF; /*  NEXT */

/* END sales_credit_type_id*/
/****************************/

/****************************/
/* START sales_group_updated_flag*/
-- no prompt for sales_group_updated_flag in sales_credits block
/* END sales_group_updated_flag*/
/****************************/
/****************************/
/* START sales_group_id*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.sales_group_id,
       p_prior_rec.sales_group_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name  := 'SALES_GROUP';
   x_header_sc_changed_attr_tbl(ind).current_id      := p_curr_rec.sales_group_id;
   x_header_sc_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.get_sales_group_name(p_curr_rec.sales_group_id);
   x_header_sc_changed_attr_tbl(ind).prior_id        := p_prior_rec.sales_group_id;
   x_header_sc_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.get_sales_group_name(p_prior_rec.sales_group_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.sales_group_id,
       p_next_rec.sales_group_id) THEN
    IF prior_exists = 'Y' THEN
   x_header_sc_changed_attr_tbl(ind).next_value  := OE_ID_TO_VALUE.get_sales_group_name(p_curr_rec.sales_group_id);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_header_sc_changed_attr_tbl(ind).attribute_name := 'SALES_GROUP';
   x_header_sc_changed_attr_tbl(ind).prior_id        := p_prior_rec.sales_group_id;
   x_header_sc_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.get_sales_group_name(p_prior_rec.sales_group_id);
   x_header_sc_changed_attr_tbl(ind).current_id     := p_curr_rec.sales_group_id;
   x_header_sc_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.get_sales_group_name(p_curr_rec.sales_group_id);
   x_header_sc_changed_attr_tbl(ind).next_id      := p_next_rec.sales_group_id;
   x_header_sc_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.get_sales_group_name(p_next_rec.sales_group_id);
END IF;
END IF; /*  NEXT */

/* END sales_group_id*/
/****************************/
/****************************/
       ELSE

       IF NOT OE_Globals.Equal(
       p_prior_rec.salesrep_id,
       p_curr_rec.salesrep_id) THEN
       If p_prior_version IS NOT NULL THEN
       ind := ind+1;
       x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_prior_rec.salesrep_id);
       x_header_sc_changed_attr_tbl(ind).prior_value        :=  null;
       x_header_sc_changed_attr_tbl(ind).current_value      :=  null;
       x_header_sc_changed_attr_tbl(ind).next_value         :=  'DELETE';
       ind := ind+1;
       x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
       x_header_sc_changed_attr_tbl(ind).prior_value        :=  null;
       x_header_sc_changed_attr_tbl(ind).current_value      :=  null;
       x_header_sc_changed_attr_tbl(ind).next_value         :=  'ADD';
       END IF; /* prior version is not null */
       END IF;

       IF NOT OE_Globals.Equal(
       p_curr_rec.salesrep_id,
       p_next_rec.salesrep_id) THEN
       IF p_next_version IS NOT NULL THEN
       ind := ind+1;
       x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
       x_header_sc_changed_attr_tbl(ind).prior_value        :=  null;
       x_header_sc_changed_attr_tbl(ind).current_value      :=  null;
       x_header_sc_changed_attr_tbl(ind).next_value         :=  'DELETE';
       ind := ind+1;
       x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_next_rec.salesrep_id);
       x_header_sc_changed_attr_tbl(ind).prior_value        :=  null;
       x_header_sc_changed_attr_tbl(ind).current_value      :=  null;
       x_header_sc_changed_attr_tbl(ind).next_value         :=  'ADD';
       END IF; /* next version is not null */
       END IF;

      END IF;
END IF;	/* p and c = Y or c and n=y */

IF l_debug_level > 0 THEN
    oe_debug_pub.add(' before finding new sales credits  ');
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
       x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
       x_header_sc_changed_attr_tbl(ind).prior_value        :=  null;
       x_header_sc_changed_attr_tbl(ind).current_value      :=  'ADD';
       x_header_sc_changed_attr_tbl(ind).next_value         :=  null;
   ELSIF (p_curr_rec_exists = 'N' and p_next_rec_exists = 'Y') THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' Current is not there - next is there');
         END IF;
       ind := ind+1;
       x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_next_rec.salesrep_id);
       x_header_sc_changed_attr_tbl(ind).prior_value        :=  null;
       x_header_sc_changed_attr_tbl(ind).current_value      :=  null;
       x_header_sc_changed_attr_tbl(ind).next_value         :=  'ADD';
  end if;
END IF;

IF l_debug_level > 0 THEN
    oe_debug_pub.add(' before finding deleted salesreps');
    oe_debug_pub.add(' p_prior_rec_exists'||p_prior_rec_exists);
    oe_debug_pub.add(' p_curr_rec_exists'||p_curr_rec_exists);
    oe_debug_pub.add(' p_next_rec_exists'||p_next_rec_exists);
    oe_debug_pub.add(' p_trans_rec_exists'||p_trans_rec_exists);
END IF;
IF (p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'N') OR
    (p_curr_rec_exists = 'Y' and p_next_rec_exists ='N') THEN
   IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'N' THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' Prior is there - current is not there');
         END IF;
       ind := ind+1;
       x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_prior_rec.salesrep_id);
       x_header_sc_changed_attr_tbl(ind).prior_value        :=  null;
       x_header_sc_changed_attr_tbl(ind).current_value      :=  'DELETE';
       x_header_sc_changed_attr_tbl(ind).next_value         :=  null;
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
       x_header_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
       x_header_sc_changed_attr_tbl(ind).prior_value        :=  null;
       x_header_sc_changed_attr_tbl(ind).current_value      :=  null;
       x_header_sc_changed_attr_tbl(ind).next_value         :=  'DELETE';
     --end if;
  end if;
END IF;
IF l_debug_level > 0 THEN
  oe_debug_pub.add('******BEFORE COMPARING ATTRIBUTES*************');
  oe_debug_pub.add('current ind '|| ind);
END IF;

END IF; /* line_id not null */
IF l_debug_level  > 0 THEN
   oe_debug_pub.add(' Exiting OE_VERSION_COMP.Compare_header_sc_Attributes ');
END IF;
/*
j := 0;
dbms_output.put_line('No of resales dreditcords'||x_header_sc_changed_attr_tbl.count);
WHILE j < x_header_sc_changed_attr_tbl.count
LOOP
j:=j+1;
dbms_output.put_line('attribute value '||x_header_sc_changed_attr_tbl(j).attribute_name ||
||' Prior '||x_header_sc_changed_attr_tbl(j).prior_value||
||' Current '||x_header_sc_changed_attr_tbl(j).current_value ||
||' Next '||x_header_sc_changed_attr_tbl(j).next_value);
END LOOP;
*/
END COMPARE_HEADER_SC_ATTRIBUTES;

PROCEDURE COMPARE_HEADER_SC_VERSIONS
(p_header_id	                  NUMBER,
 p_prior_version                  NUMBER,
 p_current_version                NUMBER,
 p_next_version                   NUMBER,
 g_max_version                    NUMBER,
 g_trans_version                  NUMBER,
 g_prior_phase_change_flag	  VARCHAR2,
 g_curr_phase_change_flag	  VARCHAR2,
 g_next_phase_change_flag	  VARCHAR2,
 x_header_sc_changed_attr_tbl        IN OUT NOCOPY OE_VERSION_COMP.header_sc_tbl_type)
IS

CURSOR C_get_sales_credits(p_header_id IN NUMBER,p_prior_version IN NUMBER, p_current_version IN NUMBER, p_next_version IN NUMBER) IS
           SELECT distinct sales_credit_id
           from oe_sales_credit_history
           where header_id = p_header_id
           and line_id is null
           --Bug 8478088
           and version_flag = 'Y'
           --and phase_change_flag = p_transaction_phase_code
           and version_number in (p_prior_version,p_current_version,p_next_version)
           union
           SELECT sales_credit_id
           from oe_sales_credits
           where header_id=p_header_id
           and line_id is null;
           --and transaction_phase_code = p_transaction_phase_code;

CURSOR C_get_hist_sales_credits(p_header_id IN NUMBER,p_prior_version IN NUMBER, p_current_version IN NUMBER, p_next_version IN NUMBER) IS
           SELECT distinct sales_credit_id
           from oe_sales_credit_history
           where header_id = p_header_id
           and line_id is null
           --Bug 8478088
           and version_flag = 'Y'
           --and phase_change_flag = p_transaction_phase_code
           and version_number in (p_prior_version,p_current_version,p_next_version);
ind1 NUMBER;
l_sales_credit_id NUMBER;
total_lines NUMBER;
x_sales_rep VARCHAR2(200);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering Compare_header_sc_versions');
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
    OPEN C_GET_sales_credits(p_header_id,p_prior_version,p_current_version,p_next_version);
    LOOP
    FETCH C_GET_sales_credits INTO l_sales_credit_id;
    EXIT WHEN C_GET_sales_credits%NOTFOUND;
    IF l_debug_level  > 0 THEN
         oe_debug_pub.add('*************sales_credits found(trans)******************'||l_sales_credit_id);    END IF;

     IF l_sales_credit_id IS NOT NULL THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************before call total sales_credits(trans) ******************'||ind1);
         END IF;
         COMPARE_HEADER_SC_ATTRIBUTES(p_header_id                 => p_header_id,
                          p_sales_credit_id                     => l_sales_credit_id,
                          p_prior_version               => p_prior_version,
                          p_current_version             => p_current_version,
                          p_next_version                => p_next_version,
                          g_max_version                 => g_max_version,
                          g_trans_version               => g_trans_version,
                          g_prior_phase_change_flag     => g_prior_phase_change_flag,
                          g_curr_phase_change_flag      => g_curr_phase_change_flag,
                          g_next_phase_change_flag      => g_next_phase_change_flag,
                          x_header_sc_changed_attr_tbl  => x_header_sc_changed_attr_tbl,
                          p_total_lines                 => ind1);
         IF x_header_sc_changed_attr_tbl.count > 0 THEN
                ind1 := x_header_sc_changed_attr_tbl.count;
        --      ind1 := ind1 + total_lines;
         END IF;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************after call total sales_credits(trans) ******************'||ind1);
         END IF;
     END IF; /* sales_Credit_id is not null */
  END LOOP;
  CLOSE C_GET_sales_credits;
  ELSE
    OPEN C_GET_HIST_sales_credits(p_header_id,p_prior_version,p_current_version,p_next_version);
    LOOP
    FETCH C_GET_HIST_sales_credits INTO l_sales_credit_id;
    EXIT WHEN C_GET_HIST_sales_credits%NOTFOUND;
    IF l_debug_level  > 0 THEN
         oe_debug_pub.add('*************sales_credits found******************'||l_sales_credit_id);
    END IF;

     IF l_sales_credit_id IS NOT NULL THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************before call total sales_credits ******************'||ind1);
         END IF;
         COMPARE_HEADER_SC_ATTRIBUTES(p_header_id               => p_header_id,
                          p_sales_credit_id                     => l_sales_credit_id,
                          p_prior_version               => p_prior_version,
                          p_current_version             => p_current_version,
                          p_next_version                => p_next_version,
                          g_max_version                 => g_max_version,
                          g_trans_version               => g_trans_version,
                          g_prior_phase_change_flag     => g_prior_phase_change_flag,
                          g_curr_phase_change_flag      => g_curr_phase_change_flag,
                          g_next_phase_change_flag      => g_next_phase_change_flag,
                          x_header_sc_changed_attr_tbl       => x_header_sc_changed_attr_tbl,
                          p_total_lines                 => ind1);
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************after call total sales credits ******************'||ind1);
         END IF;
         IF x_header_sc_changed_attr_tbl.count > 0 THEN
                ind1 := x_header_sc_changed_attr_tbl.count;
        --      ind1 := ind1 + total_lines;
         END IF;
     END IF; /* sales_credit is not null */
    END LOOP;
    CLOSE C_GET_HIST_sales_credits;
 END IF;/* next equals trans */
END IF;/*header_id is not null*/
END COMPARE_HEADER_SC_VERSIONS;
/***************************************/
PROCEDURE QUERY_line_SC_ROW
(p_header_id	                  NUMBER,
 p_sales_credit_id                NUMBER,
 p_version	                  NUMBER,
 p_phase_change_flag     	  VARCHAR2,
 x_line_scredit_rec               IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type)
IS
l_org_id                NUMBER;
l_phase_change_flag     VARCHAR2(1);
BEGIN

oe_debug_pub.add('Entering OE_VERSION_COMP.QUERY_line_SC_ROW', 1);

    l_org_id := OE_GLOBALS.G_ORG_ID;

    IF l_org_id IS NULL THEN
      OE_GLOBALS.Set_Context;
      l_org_id := OE_GLOBALS.G_ORG_ID;
    END IF;


   SELECT  ATTRIBUTE1
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
    ,       DW_UPDATE_ADVICE_FLAG
    ,       line_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       PERCENT
    ,       SALESREP_ID
    ,       sales_credit_type_id
    ,       SALES_CREDIT_ID
    ,       WH_UPDATE_DATE
    ,       SALES_GROUP_ID
    ,       SALES_GROUP_UPDATED_FLAG
    ,       LOCK_CONTROL
INTO
     x_line_scredit_rec.ATTRIBUTE1
    ,x_line_scredit_rec.ATTRIBUTE10
    ,x_line_scredit_rec.ATTRIBUTE11
    ,x_line_scredit_rec.ATTRIBUTE12
    ,x_line_scredit_rec.ATTRIBUTE13
    ,x_line_scredit_rec.ATTRIBUTE14
    ,x_line_scredit_rec.ATTRIBUTE15
    ,x_line_scredit_rec.ATTRIBUTE2
    ,x_line_scredit_rec.ATTRIBUTE3
    ,x_line_scredit_rec.ATTRIBUTE4
    ,x_line_scredit_rec.ATTRIBUTE5
    ,x_line_scredit_rec.ATTRIBUTE6
    ,x_line_scredit_rec.ATTRIBUTE7
    ,x_line_scredit_rec.ATTRIBUTE8
    ,x_line_scredit_rec.ATTRIBUTE9
    ,x_line_scredit_rec.CONTEXT
    ,x_line_scredit_rec.CREATED_BY
    ,x_line_scredit_rec.CREATION_DATE
    ,x_line_scredit_rec.DW_UPDATE_ADVICE_FLAG
    ,x_line_scredit_rec.HEADER_ID
    ,x_line_scredit_rec.LAST_UPDATED_BY
    ,x_line_scredit_rec.LAST_UPDATE_DATE
    ,x_line_scredit_rec.LAST_UPDATE_LOGIN
    ,x_line_scredit_rec.LINE_ID
    ,x_line_scredit_rec.PERCENT
    ,x_line_scredit_rec.SALESREP_ID
    ,x_line_scredit_rec.sales_credit_type_id
    ,x_line_scredit_rec.SALES_CREDIT_ID
    ,x_line_scredit_rec.WH_UPDATE_DATE
    ,x_line_scredit_rec.SALES_GROUP_ID
    ,x_line_scredit_rec.SALES_GROUP_UPDATED_FLAG
    ,x_line_scredit_rec.LOCK_CONTROL
  FROM OE_SALES_CREDIT_HISTORY
  WHERE
         HEADER_ID = p_header_id
         AND sales_credit_id = p_sales_credit_id
         AND VERSION_NUMBER=p_version
         --Bug 8478088
         AND version_flag = 'Y'
  --       AND phase_change_flag = l_phase_change_flag
         AND LINE_ID IS NOT NULL;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    --       RAISE NO_DATA_FOUND;
	 null;
    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
               'Query_line_SC_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END QUERY_line_SC_ROW;

PROCEDURE QUERY_line_SC_TRANS_ROW
(p_header_id	                  NUMBER,
 p_sales_credit_id                NUMBER,
 p_version	                  NUMBER,
 x_line_scredit_rec             IN OUT NOCOPY OE_Order_PUB.line_Scredit_Rec_Type)
IS
l_org_id                NUMBER;
l_phase_change_flag                VARCHAR2(1);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering OE_VERSION_COMP.QUERY_line_SC_TRANS_ROW');
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('version' ||p_version);
END IF;

    l_org_id := OE_GLOBALS.G_ORG_ID;

    IF l_org_id IS NULL THEN
      OE_GLOBALS.Set_Context;
      l_org_id := OE_GLOBALS.G_ORG_ID;
    END IF;

   SELECT  ATTRIBUTE1
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
    ,       DW_UPDATE_ADVICE_FLAG
    ,       HEADER_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_ID
    ,       PERCENT
    ,       SALESREP_ID
    ,       sales_credit_type_id
    ,       SALES_CREDIT_ID
    ,       WH_UPDATE_DATE
    ,       SALES_GROUP_ID
    ,       SALES_GROUP_UPDATED_FLAG
    ,       LOCK_CONTROL
INTO
     x_line_scredit_rec.ATTRIBUTE1
    ,x_line_scredit_rec.ATTRIBUTE10
    ,x_line_scredit_rec.ATTRIBUTE11
    ,x_line_scredit_rec.ATTRIBUTE12
    ,x_line_scredit_rec.ATTRIBUTE13
    ,x_line_scredit_rec.ATTRIBUTE14
    ,x_line_scredit_rec.ATTRIBUTE15
    ,x_line_scredit_rec.ATTRIBUTE2
    ,x_line_scredit_rec.ATTRIBUTE3
    ,x_line_scredit_rec.ATTRIBUTE4
    ,x_line_scredit_rec.ATTRIBUTE5
    ,x_line_scredit_rec.ATTRIBUTE6
    ,x_line_scredit_rec.ATTRIBUTE7
    ,x_line_scredit_rec.ATTRIBUTE8
    ,x_line_scredit_rec.ATTRIBUTE9
    ,x_line_scredit_rec.CONTEXT
    ,x_line_scredit_rec.CREATED_BY
    ,x_line_scredit_rec.CREATION_DATE
    ,x_line_scredit_rec.DW_UPDATE_ADVICE_FLAG
    ,x_line_scredit_rec.HEADER_ID
    ,x_line_scredit_rec.LAST_UPDATED_BY
    ,x_line_scredit_rec.LAST_UPDATE_DATE
    ,x_line_scredit_rec.LAST_UPDATE_LOGIN
    ,x_line_scredit_rec.LINE_ID
    ,x_line_scredit_rec.PERCENT
    ,x_line_scredit_rec.SALESREP_ID
    ,x_line_scredit_rec.sales_credit_type_id
    ,x_line_scredit_rec.SALES_CREDIT_ID
    ,x_line_scredit_rec.WH_UPDATE_DATE
    ,x_line_scredit_rec.SALES_GROUP_ID
    ,x_line_scredit_rec.SALES_GROUP_UPDATED_FLAG
    ,x_line_scredit_rec.LOCK_CONTROL
  FROM OE_SALES_CREDITS
  WHERE
         HEADER_ID = p_header_id
         AND sales_credit_id = p_sales_credit_id
         AND LINE_ID IS NOT NULL;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    --       RAISE NO_DATA_FOUND;
	 null;
    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
               'Query_line_SC_Trans_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END QUERY_line_SC_TRANS_ROW;


PROCEDURE COMPARE_line_SC_ATTRIBUTES
(p_header_id	                  NUMBER,
 p_sales_credit_id	          NUMBER,
 p_prior_version                  NUMBER,
 p_current_version                NUMBER,
 p_next_version                   NUMBER,
 g_max_version                    NUMBER,
 g_trans_version                  NUMBER,
 g_prior_phase_change_flag	  VARCHAR2,
 g_curr_phase_change_flag	  VARCHAR2,
 g_next_phase_change_flag	  VARCHAR2,
 x_line_sc_changed_attr_tbl       IN OUT NOCOPY OE_VERSION_COMP.line_sc_tbl_type,
 p_total_lines                    NUMBER,
 x_line_number                    VARCHAR2)
IS
p_curr_rec                       OE_Order_PUB.line_scredit_Rec_Type;
p_next_rec                       OE_Order_PUB.line_scredit_Rec_Type;
p_prior_rec                      OE_Order_PUB.line_scredit_Rec_Type;


v_totcol NUMBER:=10;
v_line_col VARCHAR2(50);
ind NUMBER;
prior_exists VARCHAR2(1) := 'N';
j NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
p_prior_rec_exists VARCHAR2(1) := 'N';
p_curr_rec_exists VARCHAR2(1)  := 'N';
p_next_rec_exists VARCHAR2(1)  := 'N';
p_trans_rec_exists VARCHAR2(1)  := 'N';
BEGIN

IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering  comparing_line_sc_attributes');
  oe_debug_pub.add('header' ||p_header_id);
  oe_debug_pub.add('Sales Credit' ||p_sales_credit_id);
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

IF p_sales_credit_id IS NOT NULL THEN

p_prior_rec := NULL;
p_curr_rec := NULL;
p_next_rec := NULL;

IF l_debug_level > 0 THEN
  oe_debug_pub.add(' Quering prior line version details');
  oe_debug_pub.add('prior version' ||p_prior_version);
END IF;

IF p_prior_version IS NOT NULL THEN
OE_VERSION_COMP.QUERY_line_SC_ROW(p_header_id         => p_header_id,
                          p_sales_credit_id           => p_sales_credit_id,
                          p_version                   => p_prior_version,
                          p_phase_change_flag         => g_prior_phase_change_flag,
			  x_line_scredit_rec          => p_prior_rec);
     IF p_prior_rec.sales_credit_id is NULL THEN
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
OE_VERSION_COMP.QUERY_line_SC_ROW(p_header_id         => p_header_id,
                          p_sales_credit_id           => p_sales_credit_id,
			  p_version                   => p_current_version,
                          p_phase_change_flag         => g_curr_phase_change_flag,
			  x_line_scredit_rec          => p_curr_rec);
     IF p_curr_rec.sales_credit_id is NULL THEN
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
OE_VERSION_COMP.QUERY_line_SC_TRANS_ROW(p_header_id   => p_header_id,
                          p_sales_credit_id           => p_sales_credit_id,
                          p_version                   => p_next_version,
			  x_line_scredit_rec          => p_next_rec);
       END IF;
     IF p_next_rec.sales_credit_id is NULL THEN
          p_trans_rec_exists := 'N';
     ELSE
          p_trans_rec_exists := 'Y';
          p_next_rec_exists := 'Y';
     END IF;
ELSE
IF p_next_version IS NOT NULL THEN
OE_VERSION_COMP.QUERY_line_SC_ROW(p_header_id       => p_header_id,
                          p_sales_credit_id         => p_sales_credit_id,
                          p_version                 => p_next_version,
                          p_phase_change_flag       => g_prior_phase_change_flag,
			  x_line_scredit_rec        => p_next_rec);
     IF p_next_rec.sales_credit_id is NULL THEN
          p_next_rec_exists := 'N';
     ELSE
          p_next_rec_exists := 'Y';
     END IF;
END IF;
END IF;

IF l_debug_level > 0 THEN
oe_debug_pub.add(' p_prior_rec salesrep'||p_prior_rec.salesrep_id);
oe_debug_pub.add(' p_curr_rec '||p_curr_rec.salesrep_id);
oe_debug_pub.add(' p_next_rec '||p_next_rec.salesrep_id);
oe_debug_pub.add(' p_prior_rec sales group'||p_prior_rec.sales_group_id);
oe_debug_pub.add(' p_curr_rec '||p_curr_rec.sales_group_id);
oe_debug_pub.add(' p_next_rec '||p_next_rec.sales_group_id);
    oe_debug_pub.add(' checking whether salesreps are same or not');
    oe_debug_pub.add(' p_prior_rec_exists'||p_prior_rec_exists);
    oe_debug_pub.add(' p_curr_rec_exists'||p_curr_rec_exists);
    oe_debug_pub.add(' p_next_rec_exists'||p_next_rec_exists);
    oe_debug_pub.add(' p_trans_rec_exists'||p_trans_rec_exists);
END IF;
IF  (p_prior_rec_exists = 'Y' and p_curr_rec_exists ='Y') OR
    (p_curr_rec_exists = 'Y' and p_next_rec_exists ='Y') THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' both exists - checking if both are same');
         END IF;
       IF OE_Globals.Equal(p_prior_rec.salesrep_id,p_curr_rec.salesrep_id) OR
         OE_Globals.Equal( p_curr_rec.salesrep_id, p_next_rec.salesrep_id) THEN
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
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name  := 'attribute1';
   x_line_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute1;
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute1;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute1,
       p_next_rec.attribute1) THEN
    IF prior_exists = 'Y' THEN
   x_line_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute1;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name := 'attribute1';
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute1;
   x_line_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute1;
   x_line_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute1;
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
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name  := 'attribute2';
   x_line_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute2;
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute2;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute2,
       p_next_rec.attribute2) THEN
    IF prior_exists = 'Y' THEN
   x_line_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute2;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name := 'attribute2';
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute2;
   x_line_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute2;
   x_line_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute2;
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
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name  := 'attribute3';
   x_line_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute3;
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute3;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute3,
       p_next_rec.attribute3) THEN
    IF prior_exists = 'Y' THEN
   x_line_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute3;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name := 'attribute3';
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute3;
   x_line_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute3;
   x_line_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute3;
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
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name  := 'attribute4';
   x_line_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute4;
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute4;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute4,
       p_next_rec.attribute4) THEN
    IF prior_exists = 'Y' THEN
   x_line_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute4;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name := 'attribute4';
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute4;
   x_line_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute4;
   x_line_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute4;
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
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name  := 'attribute5';
   x_line_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute5;
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute5;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute5,
       p_next_rec.attribute5) THEN
    IF prior_exists = 'Y' THEN
   x_line_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute5;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name := 'attribute5';
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute5;
   x_line_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute5;
   x_line_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute5;
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
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name  := 'attribute6';
   x_line_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute6;
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute6;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute6,
       p_next_rec.attribute6) THEN
    IF prior_exists = 'Y' THEN
   x_line_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute6;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_name := 'attribute6';
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute6;
   x_line_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute6;
   x_line_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute6;
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
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name  := 'attribute7';
   x_line_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute7;
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute7;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute7,
       p_next_rec.attribute7) THEN
    IF prior_exists = 'Y' THEN
   x_line_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute7;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name := 'attribute7';
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute7;
   x_line_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute7;
   x_line_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute7;
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
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name  := 'attribute8';
   x_line_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute8;
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute8;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute8,
       p_next_rec.attribute8) THEN
    IF prior_exists = 'Y' THEN
   x_line_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute8;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name := 'attribute8';
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute8;
   x_line_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute8;
   x_line_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute8;
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
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name  := 'attribute9';
   x_line_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute9;
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute9;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute9,
       p_next_rec.attribute9) THEN
    IF prior_exists = 'Y' THEN
   x_line_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute9;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name := 'attribute9';
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute9;
   x_line_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute9;
   x_line_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute9;
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
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name  := 'attribute10';
   x_line_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute10;
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute10;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute10,
       p_next_rec.attribute10) THEN
    IF prior_exists = 'Y' THEN
   x_line_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute10;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name := 'attribute10';
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute10;
   x_line_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute10;
   x_line_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute10;
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
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name  := 'attribute11';
   x_line_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute11;
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute11;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute11,
       p_next_rec.attribute11) THEN
    IF prior_exists = 'Y' THEN
   x_line_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute11;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name := 'attribute11';
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute11;
   x_line_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute11;
   x_line_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute11;
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
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name  := 'attribute12';
   x_line_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute12;
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute12;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute12,
       p_next_rec.attribute12) THEN
    IF prior_exists = 'Y' THEN
   x_line_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute12;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name := 'attribute12';
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute12;
   x_line_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute12;
   x_line_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute12;
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
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name  := 'attribute13';
   x_line_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute13;
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute13;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute13,
       p_next_rec.attribute13) THEN
    IF prior_exists = 'Y' THEN
   x_line_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute13;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name := 'attribute13';
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute13;
   x_line_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute13;
   x_line_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute13;
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
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name  := 'attribute14';
   x_line_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute14;
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute14;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute14,
       p_next_rec.attribute14) THEN
    IF prior_exists = 'Y' THEN
   x_line_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute14;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name := 'attribute14';
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute14;
   x_line_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute14;
   x_line_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute14;
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
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name  := 'attribute15';
   x_line_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.attribute15;
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute15;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.attribute15,
       p_next_rec.attribute15) THEN
    IF prior_exists = 'Y' THEN
   x_line_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.attribute15;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name := 'attribute15';
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.attribute15;
   x_line_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.attribute15;
   x_line_sc_changed_attr_tbl(ind).next_value      := p_next_rec.attribute15;
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
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name  := 'context';
   x_line_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.context;
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.context;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.context,
       p_next_rec.context) THEN
    IF prior_exists = 'Y' THEN
   x_line_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.context;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name := 'context';
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.context;
   x_line_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.context;
   x_line_sc_changed_attr_tbl(ind).next_value      := p_next_rec.context;
END IF;
END IF; /*  NEXT */

/* END context*/

/****************************/

/****************************/
/* START PERCENT*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.PERCENT,
       p_prior_rec.PERCENT) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name  := 'PERCENT';
   x_line_sc_changed_attr_tbl(ind).current_value      := p_curr_rec.PERCENT;
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.PERCENT;
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.PERCENT,
       p_next_rec.PERCENT) THEN
    IF prior_exists = 'Y' THEN
   x_line_sc_changed_attr_tbl(ind).next_value     := p_curr_rec.PERCENT;
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name := 'PERCENT';
   x_line_sc_changed_attr_tbl(ind).prior_value        := p_prior_rec.PERCENT;
   x_line_sc_changed_attr_tbl(ind).current_value     := p_curr_rec.PERCENT;
   x_line_sc_changed_attr_tbl(ind).next_value      := p_next_rec.PERCENT;
END IF;
END IF; /*  NEXT */

/* END PERCENT*/
/****************************/
/****************************/
/* START sales_credit_type_id*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.sales_credit_type_id,
       p_prior_rec.sales_credit_type_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name  := 'sales_credit_type';
   x_line_sc_changed_attr_tbl(ind).current_id      := p_curr_rec.sales_credit_type_id;
   x_line_sc_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.sales_credit_type(p_curr_rec.sales_credit_type_id);
   x_line_sc_changed_attr_tbl(ind).prior_id        := p_prior_rec.sales_credit_type_id;
   x_line_sc_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.sales_credit_type(p_prior_rec.sales_credit_type_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.sales_credit_type_id,
       p_next_rec.sales_credit_type_id) THEN
    IF prior_exists = 'Y' THEN
   x_line_sc_changed_attr_tbl(ind).next_value  := OE_ID_TO_VALUE.sales_credit_type(p_curr_rec.sales_credit_type_id);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name := 'sales_credit_type';
   x_line_sc_changed_attr_tbl(ind).prior_id        := p_prior_rec.sales_credit_type_id;
   x_line_sc_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.sales_credit_type(p_prior_rec.sales_credit_type_id);
   x_line_sc_changed_attr_tbl(ind).current_id     := p_curr_rec.sales_credit_type_id;
   x_line_sc_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.sales_credit_type(p_curr_rec.sales_credit_type_id);
   x_line_sc_changed_attr_tbl(ind).next_id      := p_next_rec.sales_credit_type_id;
   x_line_sc_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.sales_credit_type(p_next_rec.sales_credit_type_id);
END IF;
END IF; /*  NEXT */

/* END sales_credit_type_id*/
/****************************/

/****************************/
/* START sales_group_id*/

prior_exists := 'N';
IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.sales_group_id,
       p_prior_rec.sales_group_id) THEN
 null;
ELSE
   ind := ind+1;
   prior_exists := 'Y';
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name  := 'SALES_GROUP';
   x_line_sc_changed_attr_tbl(ind).current_id      := p_curr_rec.sales_group_id;
   x_line_sc_changed_attr_tbl(ind).current_value   := OE_ID_TO_VALUE.get_sales_group_name(p_curr_rec.sales_group_id);
   x_line_sc_changed_attr_tbl(ind).prior_id        := p_prior_rec.sales_group_id;
   x_line_sc_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.get_sales_group_name(p_prior_rec.sales_group_id);
END IF;
END IF; /*  PRIOR */
/****************************/
IF p_curr_rec_exists = 'Y' and p_next_rec_exists = 'Y' THEN
IF OE_Globals.Equal(
       p_curr_rec.sales_group_id,
       p_next_rec.sales_group_id) THEN
    IF prior_exists = 'Y' THEN
   x_line_sc_changed_attr_tbl(ind).next_value  := OE_ID_TO_VALUE.get_sales_group_name(p_curr_rec.sales_group_id);
    END IF;
ELSE
    IF prior_exists = 'N' THEN
        ind := ind+1;
    END IF;
   x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
   x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
   x_line_sc_changed_attr_tbl(ind).attribute_name := 'SALES_GROUP';
   x_line_sc_changed_attr_tbl(ind).prior_id        := p_prior_rec.sales_group_id;
   x_line_sc_changed_attr_tbl(ind).prior_value     := OE_ID_TO_VALUE.get_sales_group_name(p_prior_rec.sales_group_id);
   x_line_sc_changed_attr_tbl(ind).current_id     := p_curr_rec.sales_group_id;
   x_line_sc_changed_attr_tbl(ind).current_value  := OE_ID_TO_VALUE.get_sales_group_name(p_curr_rec.sales_group_id);
   x_line_sc_changed_attr_tbl(ind).next_id      := p_next_rec.sales_group_id;
   x_line_sc_changed_attr_tbl(ind).next_value   := OE_ID_TO_VALUE.get_sales_group_name(p_next_rec.sales_group_id);
END IF;
END IF; /*  NEXT */

/* END sales_group_id*/
/****************************/

/****************************/
       ELSE

       IF NOT OE_Globals.Equal(
       p_prior_rec.salesrep_id,
       p_curr_rec.salesrep_id) THEN
       IF p_prior_version IS NOT NULL THEN
       ind := ind+1;
       x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
       x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_prior_rec.salesrep_id);
       x_line_sc_changed_attr_tbl(ind).prior_value        :=  null;
       x_line_sc_changed_attr_tbl(ind).current_value      :=  null;
       x_line_sc_changed_attr_tbl(ind).next_value         :=  'DELETE';
       ind := ind+1;
       x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
       x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
       x_line_sc_changed_attr_tbl(ind).prior_value        :=  null;
       x_line_sc_changed_attr_tbl(ind).current_value      :=  null;
       x_line_sc_changed_attr_tbl(ind).next_value         :=  'ADD';
       END IF; /*prior version is not null */
       END IF;

       IF NOT OE_Globals.Equal(
       p_curr_rec.salesrep_id,
       p_next_rec.salesrep_id) THEN
       IF p_next_version IS NOT NULL THEN
       ind := ind+1;
       x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
       x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
       x_line_sc_changed_attr_tbl(ind).prior_value        :=  null;
       x_line_sc_changed_attr_tbl(ind).current_value      :=  null;
       x_line_sc_changed_attr_tbl(ind).next_value         :=  'DELETE';
       ind := ind+1;
       x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
       x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_next_rec.salesrep_id);
       x_line_sc_changed_attr_tbl(ind).prior_value        :=  null;
       x_line_sc_changed_attr_tbl(ind).current_value      :=  null;
       x_line_sc_changed_attr_tbl(ind).next_value         :=  'ADD';
       END IF; /*next version is not null */
       END IF;

      END IF;
END IF;	/* p and c = Y or c and n=y */

IF l_debug_level > 0 THEN
    oe_debug_pub.add(' before finding new sales credits  ');
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
       x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
       x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
       x_line_sc_changed_attr_tbl(ind).prior_value        :=  null;
       x_line_sc_changed_attr_tbl(ind).current_value      :=  'ADD';
       x_line_sc_changed_attr_tbl(ind).next_value         :=  null;
   ELSIF (p_curr_rec_exists = 'N' and p_next_rec_exists = 'Y') THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' Current is not there - next is there');
         END IF;
       ind := ind+1;
       x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
       x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_next_rec.salesrep_id);
       x_line_sc_changed_attr_tbl(ind).prior_value        :=  null;
       x_line_sc_changed_attr_tbl(ind).current_value      :=  null;
       x_line_sc_changed_attr_tbl(ind).next_value         :=  'ADD';
  end if;
END IF;

IF l_debug_level > 0 THEN
    oe_debug_pub.add(' before finding deleted salesreps');
    oe_debug_pub.add(' p_prior_rec_exists'||p_prior_rec_exists);
    oe_debug_pub.add(' p_curr_rec_exists'||p_curr_rec_exists);
    oe_debug_pub.add(' p_next_rec_exists'||p_next_rec_exists);
    oe_debug_pub.add(' p_trans_rec_exists'||p_trans_rec_exists);
END IF;
IF (p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'N') OR
    (p_curr_rec_exists = 'Y' and p_next_rec_exists ='N') THEN
   IF p_prior_rec_exists = 'Y' and p_curr_rec_exists = 'N' THEN
         IF l_debug_level > 0 THEN
               oe_debug_pub.add(' Prior is there - current is not there');
         END IF;
       ind := ind+1;
       x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
       x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_prior_rec.salesrep_id);
       x_line_sc_changed_attr_tbl(ind).prior_value        :=  null;
       x_line_sc_changed_attr_tbl(ind).current_value      :=  'DELETE';
       x_line_sc_changed_attr_tbl(ind).next_value         :=  null;
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
       x_line_sc_changed_attr_tbl(ind).line_number        := x_line_number;
       x_line_sc_changed_attr_tbl(ind).attribute_value    := OE_ID_TO_VALUE.Salesrep(p_curr_rec.salesrep_id);
       x_line_sc_changed_attr_tbl(ind).prior_value        :=  null;
       x_line_sc_changed_attr_tbl(ind).current_value      :=  null;
       x_line_sc_changed_attr_tbl(ind).next_value         :=  'DELETE';
     --end if;
  end if;
END IF;
IF l_debug_level > 0 THEN
  oe_debug_pub.add('******BEFORE COMPARING ATTRIBUTES*************');
  oe_debug_pub.add('current ind '|| ind);
END IF;

IF (p_prior_version IS NOT NULL and p_prior_rec_exists ='Y') OR
   (p_current_version IS NOT NULL and p_curr_rec_exists ='Y') OR
   (p_next_version IS NOT NULL and p_next_rec_exists ='Y') OR
   (g_trans_version IS NOT NULL and p_trans_rec_exists ='Y') THEN

null;
ELSE
NULL;
END IF;
END IF; /* line_id not null */
IF l_debug_level > 0 THEN
  oe_debug_pub.add('******AFTER COMPARING ATTRIBUTES*************');
  oe_debug_pub.add('current ind '|| ind);
END IF;
IF l_debug_level  > 0 THEN
   oe_debug_pub.add(' Exiting OE_VERSION_COMP.Compare_line_sc_Attributes ');
END IF;
/*
j := 0;
dbms_output.put_line('No of resales dreditcords'||x_line_sc_changed_attr_tbl.count);
WHILE j < x_line_sc_changed_attr_tbl.count
LOOP
j:=j+1;
dbms_output.put_line('attribute value '||x_line_sc_changed_attr_tbl(j).attribute_name ||
||' Prior '||x_line_sc_changed_attr_tbl(j).prior_value||
||' Current '||x_line_sc_changed_attr_tbl(j).current_value ||
||' Next '||x_line_sc_changed_attr_tbl(j).next_value);
END LOOP;
*/
END COMPARE_line_SC_ATTRIBUTES;

PROCEDURE COMPARE_line_SC_VERSIONS
(p_header_id	                  NUMBER,
 p_prior_version                  NUMBER,
 p_current_version                NUMBER,
 p_next_version                   NUMBER,
 g_max_version                    NUMBER,
 g_trans_version                  NUMBER,
 g_prior_phase_change_flag	  VARCHAR2,
 g_curr_phase_change_flag	  VARCHAR2,
 g_next_phase_change_flag	  VARCHAR2,
 x_line_sc_changed_attr_tbl        IN OUT NOCOPY OE_VERSION_COMP.line_sc_tbl_type)
IS

CURSOR C_get_sales_credits(p_header_id IN NUMBER,p_prior_version IN NUMBER, p_current_version IN NUMBER, p_next_version IN NUMBER) IS
           SELECT distinct sales_credit_id,line_id
           from oe_sales_credit_history
           where header_id = p_header_id
           and line_id is  not null
           --Bug 8478088
           and version_flag = 'Y'
           --and phase_change_flag = p_transaction_phase_code
           and version_number in (p_prior_version,p_current_version,p_next_version)
           union
           SELECT sales_credit_id,line_id
           from oe_sales_credits
           where header_id=p_header_id
           and line_id is not null;
           --and transaction_phase_code = p_transaction_phase_code;

CURSOR C_get_hist_sales_credits(p_header_id IN NUMBER,p_prior_version IN NUMBER, p_current_version IN NUMBER, p_next_version IN NUMBER) IS
           SELECT distinct sales_credit_id,line_id
           from oe_sales_credit_history
           where header_id = p_header_id
           and line_id is not null
           --Bug 8478088
           and version_flag = 'Y'
           --and phase_change_flag = p_transaction_phase_code
           and version_number in (p_prior_version,p_current_version,p_next_version);
ind1 NUMBER;
l_sales_credit_id NUMBER;
total_lines NUMBER;
l_line_id   NUMBER;
x_sales_rep VARCHAR2(200);
x_line_number VARCHAR2(30);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
IF l_debug_level > 0 THEN
  oe_debug_pub.add('Entering Compare_line_sc_versions');
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
    OPEN C_GET_sales_credits(p_header_id,p_prior_version,p_current_version,p_next_version);
    LOOP
    FETCH C_GET_sales_credits INTO l_sales_credit_id,l_line_id;
    EXIT WHEN C_GET_sales_credits%NOTFOUND;
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('*************sales_credits found(trans)******************'||l_sales_credit_id);
      oe_debug_pub.add('*************sales_credits found(line_id)******************'||l_line_id);
    END IF;

     IF l_sales_credit_id IS NOT NULL THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************before call total sales_credits(trans) ******************'||ind1);
         END IF;

         IF l_line_id IS NOT NULL THEN
         -- bug 9299752
         begin
          select oe_order_misc_pub.get_concat_hist_line_number(l_line_id) into x_line_number from dual;
         exception
	  when others then
	    select oe_order_misc_pub.get_concat_hist_line_number(l_line_id,p_current_version) into x_line_number from dual;
	 end;
         -- bug 9299752
         END IF;
         IF x_line_number IS NULL THEN
         select oe_order_misc_pub.get_concat_line_number(l_line_id) into x_line_number from dual;
         END IF;

         COMPARE_line_SC_ATTRIBUTES(p_header_id         => p_header_id,
                          p_sales_credit_id             => l_sales_credit_id,
                          p_prior_version               => p_prior_version,
                          p_current_version             => p_current_version,
                          p_next_version                => p_next_version,
                          g_max_version                 => g_max_version,
                          g_trans_version               => g_trans_version,
                          g_prior_phase_change_flag     => g_prior_phase_change_flag,
                          g_curr_phase_change_flag      => g_curr_phase_change_flag,
                          g_next_phase_change_flag      => g_next_phase_change_flag,
                          x_line_sc_changed_attr_tbl    => x_line_sc_changed_attr_tbl,
                          p_total_lines                 => ind1,
                          x_line_number                 => x_line_number);
         IF x_line_sc_changed_attr_tbl.count > 0 THEN
                ind1 := x_line_sc_changed_attr_tbl.count;
        --      ind1 := ind1 + total_lines;
         END IF;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************after call total sales_credits(trans) ******************'||ind1);
         END IF;
     END IF; /* sales_Credit_id is not null */
  END LOOP;
  CLOSE C_GET_sales_credits;
  ELSE
    OPEN C_GET_HIST_sales_credits(p_header_id,p_prior_version,p_current_version,p_next_version);
    LOOP
    FETCH C_GET_HIST_sales_credits INTO l_sales_credit_id,l_line_id;
    EXIT WHEN C_GET_HIST_sales_credits%NOTFOUND;
    IF l_debug_level  > 0 THEN
         oe_debug_pub.add('*************sales_credits found******************'||l_sales_credit_id);
    END IF;

     IF l_sales_credit_id IS NOT NULL THEN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************before call total sales_credits ******************'||ind1);
         END IF;
         -- bug 9299752
         begin
            select oe_order_misc_pub.get_concat_hist_line_number(l_line_id) into x_line_number from dual;
         exception
	  when others then
	    select oe_order_misc_pub.get_concat_hist_line_number(l_line_id,p_current_version) into x_line_number from dual;
         end;
         -- bug 9299752
         COMPARE_line_SC_ATTRIBUTES(p_header_id         => p_header_id,
                          p_sales_credit_id             => l_sales_credit_id,
                          p_prior_version               => p_prior_version,
                          p_current_version             => p_current_version,
                          p_next_version                => p_next_version,
                          g_max_version                 => g_max_version,
                          g_trans_version               => g_trans_version,
                          g_prior_phase_change_flag     => g_prior_phase_change_flag,
                          g_curr_phase_change_flag      => g_curr_phase_change_flag,
                          g_next_phase_change_flag      => g_next_phase_change_flag,
                          x_line_sc_changed_attr_tbl    => x_line_sc_changed_attr_tbl,
                          p_total_lines                 => ind1,
                          x_line_number                 => x_line_number);
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('*************after call total sales credits ******************'||ind1);
         END IF;
         IF x_line_sc_changed_attr_tbl.count > 0 THEN
                ind1 := x_line_sc_changed_attr_tbl.count;
        --      ind1 := ind1 + total_lines;
         END IF;
     END IF; /* sales_credit is not null */
    END LOOP;
    CLOSE C_GET_HIST_sales_credits;
 END IF;/* next equals trans */
END IF;/*header_id is not null*/
END COMPARE_line_SC_VERSIONS;

FUNCTION line_status
(   p_line_status_code            IN  VARCHAR2
) RETURN VARCHAR2
IS
l_line_status               VARCHAR2(80) := NULL;
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

PROCEDURE Card_Equal
( p_instrument_id1     	IN NUMBER
, p_instrument_id2     	IN NUMBER
, p_attribute_name     	IN VARCHAR2
, p_is_card_history1	IN VARCHAR2
, p_is_card_history2	IN VARCHAR2
, x_is_equal	    	OUT NOCOPY VARCHAR2
, x_value1	    	OUT NOCOPY VARCHAR2
, x_value2	    	OUT NOCOPY VARCHAR2
)
IS

l_attribute_value1	VARCHAR2(80);
l_attribute_value2	VARCHAR2(80);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_encrypted	VARCHAR2(30);  --PADSS

BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Entering OE_VERSION_COMP.Card_Equal. ', 3);
  END IF;

  IF p_attribute_name = 'CREDIT_CARD_HOLDER_NAME' THEN
    -- instrument_id stores the card_history_change_id

    IF p_is_card_history1 = 'Y' THEN
    BEGIN
      SELECT CHNAME
      INTO   l_attribute_value1
      FROM   iby_creditcard_h
      WHERE  card_history_change_id = p_instrument_id1;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
    END;
    ELSE
    BEGIN
      SELECT CHNAME
      INTO   l_attribute_value1
      FROM   iby_creditcard
      WHERE  instrid = p_instrument_id1;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
    END;
    END IF;


    IF p_is_card_history2 = 'Y' THEN
    BEGIN
      SELECT CHNAME
      INTO   l_attribute_value2
      FROM   iby_creditcard_h
      WHERE  card_history_change_id = p_instrument_id2;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
    END;
    ELSE
    BEGIN
      SELECT CHNAME
      INTO   l_attribute_value2
      FROM   iby_creditcard
      WHERE  instrid = p_instrument_id2;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
    END;
    END IF;

  ELSIF  p_attribute_name = 'CREDIT_CARD_CODE' THEN
    -- instrument_id stores the instrument_id
    IF p_is_card_history1 = 'Y' THEN
    BEGIN
      SELECT card_issuer_code
      INTO   l_attribute_value1
      FROM   iby_creditcard_h
      WHERE  card_history_change_id = p_instrument_id1;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
    END;
    ELSE
    BEGIN
      SELECT card_issuer_code
      INTO   l_attribute_value1
      FROM   iby_creditcard
      WHERE  instrid = p_instrument_id1;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
    END;
    END IF;

    IF p_is_card_history2 = 'Y' THEN
    BEGIN
      SELECT card_issuer_code
      INTO   l_attribute_value2
      FROM   iby_creditcard_h
      WHERE  card_history_change_id = p_instrument_id2;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
    END;
    ELSE
    BEGIN
      SELECT card_issuer_code
      INTO   l_attribute_value2
      FROM   iby_creditcard
      WHERE  instrid = p_instrument_id2;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
    END;
    END IF;
  ELSIF p_attribute_name = 'CREDIT_CARD_EXPIRATION_DATE' THEN
    -- instrument_id stores the card_history_change_id
    --PADSS start
    begin
    select encrypted
    into l_encrypted
    from iby_creditcard
    where instrid=p_instrument_id1;
    exception
     when others then
       --l_encrypted:=null;
       begin
        select encrypted
       	into l_encrypted
       	from iby_creditcard_h
        where card_history_change_id=p_instrument_id1;
       exception
              when others then
               null;
       end;
    end;

    IF p_is_card_history1 = 'Y' THEN
    BEGIN
     --IF NOT iby_cc_security_pub.encryption_enabled() THEN
     IF nvl(l_encrypted,'N') <> 'A' THEN
      SELECT expirydate
      INTO   l_attribute_value1
      FROM   iby_creditcard_h
      WHERE  card_history_change_id = p_instrument_id1;
     ELSE
      select credit_card_expiration_date
      INTO   l_attribute_value1
      FROM   oe_order_header_history
      WHERE  instrument_id = p_instrument_id1
        and rownum=1;
     END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
    END;

    ELSE
    BEGIN
     --IF NOT iby_cc_security_pub.encryption_enabled() THEN
     IF nvl(l_encrypted,'N') <> 'A' THEN
      SELECT expirydate
      INTO   l_attribute_value1
      FROM   iby_creditcard
      WHERE  instrid = p_instrument_id1;
     ELSE
      l_attribute_value1:='-1';
     END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
    END;
    END IF;

    begin
    select encrypted
    into l_encrypted
    from iby_creditcard
    where instrid=p_instrument_id2;
    exception
     when others then
       --l_encrypted:=null;
       begin
        select encrypted
        into l_encrypted
        from iby_creditcard_h
        where card_history_change_id=p_instrument_id2;
       exception
        when others then
           null;
       end;
    end;

    IF p_is_card_history2 = 'Y' THEN
    BEGIN
     --IF NOT iby_cc_security_pub.encryption_enabled() THEN
     IF nvl(l_encrypted,'N') <> 'A' THEN
      SELECT expirydate
      INTO   l_attribute_value2
      FROM   iby_creditcard_h
      WHERE  card_history_change_id = p_instrument_id2;
     ELSE
      select credit_card_expiration_date
      INTO   l_attribute_value2
      FROM   oe_order_header_history
      WHERE  instrument_id = p_instrument_id2
         and rownum=1;
     END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
    END;
    ELSE
    BEGIN
     --IF NOT iby_cc_security_pub.encryption_enabled() THEN
     IF nvl(l_encrypted,'N') <> 'A' THEN
      SELECT expirydate
      INTO   l_attribute_value2
      FROM   iby_creditcard
      WHERE  instrid = p_instrument_id2;
     ELSE
      l_attribute_value2:='-1';
     END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
    END;
    END IF;
 --PADSS END
 -- comment out the following code as version comparison is not enabled
 -- for credit_card_approval_code and credit_card_approval_date
 /*
  ELSIF p_attribute_name = 'CREDIT_CARD_APPROVAL_CODE' THEN
    -- instrument_id stores the authorization_id
    BEGIN
      SELECT authorization_code
      INTO   l_attribute_value1
      FROM   iby_trxn_ext_auths_v
      WHERE  authorization_id = p_instrument_id1;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
    END;

    BEGIN
      SELECT authorization_code
      INTO   l_attribute_value2
      FROM   iby_trxn_ext_auths_v
      WHERE  authorization_id = p_instrument_id2;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
    END;
  ELSIF p_attribute_name = 'CREDIT_CARD_APPROVAL_DATE' THEN
    -- instrument_id stores the authorization_id
    BEGIN
      SELECT authorization_date
      INTO   l_attribute_value1
      FROM   iby_trxn_ext_auths_v
      WHERE  authorization_id = p_instrument_id1;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
    END;

    BEGIN
      SELECT authorization_date
      INTO   l_attribute_value2
      FROM   iby_trxn_ext_auths_v
      WHERE  authorization_id = p_instrument_id2;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
    END;
    */
  END IF;


    IF (l_attribute_value1 IS NULL AND l_attribute_value2 IS NULL)
       OR (l_attribute_value1 IS NOT NULL AND
           l_attribute_value2 IS NOT NULL AND
           l_attribute_value1 = l_attribute_value2) THEN
      x_is_equal := 'Y';
    ELSE
      x_is_equal := 'N';
    END IF;

    x_value1 := l_attribute_value1;
    x_value2 := l_attribute_value2;

END Card_Equal;

--{added for bug 4302049
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
   slash varchar2(20);
   CURSOR c1 Is select form_left_prompt from fnd_descr_flex_col_usage_vl
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
	   OPEN C1;
	   LOOP
	        FETCH C1 into l_prompt;
                exit When C1%NOTFOUND;
                oe_debug_pub.add('lPrompt='||l_prompt);
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
--bug 4302049}

END OE_VERSION_COMP;

/
