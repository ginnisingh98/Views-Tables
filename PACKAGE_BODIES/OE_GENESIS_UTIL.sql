--------------------------------------------------------
--  DDL for Package Body OE_GENESIS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_GENESIS_UTIL" AS
/* $Header: OEXUGNIB.pls 120.1.12010000.17 2011/02/24 02:03:48 snimmaga ship $ */

-- Funtion source_aia_enabled

FUNCTION source_aia_enabled(p_source_id VARCHAR2)
  RETURN BOOLEAN
IS
  CURSOR l_enabled_sources_cur IS
    SELECT  order_source_id
    FROM  oe_order_sources
    WHERE aia_enabled_flag = 'Y';
BEGIN
  -- Bug 8647864
  IF Nvl(p_source_id, Fnd_Api.G_Miss_Num) = Fnd_Api.G_Miss_Num
  THEN
    RETURN FALSE;
  END IF;

  --  If the enabled sources global table is not yet initialized,
  --  load the same.
  IF NOT g_sources_loaded THEN
    FOR enabled_source IN l_enabled_sources_cur
    LOOP
       g_enabled_sources_tab(enabled_source.order_source_id).enabled := 'Y';
    END LOOP;
    g_sources_loaded  :=  TRUE;
  END IF;

   --  If the order source is enabled for AIA, it will be found in the
   --  cached order sources table.
   RETURN g_enabled_sources_tab.EXISTS(p_source_id);

END source_aia_enabled;


----- O2C25
FUNCTION Inventory_Org
(
  p_inventory_org_id         IN  NUMBER
) RETURN VARCHAR2
IS
  l_inventory_org          VARCHAR2(240) := NULL;
  l_dbg_level              NUMBER        := oe_debug_pub.g_debug_level;
BEGIN
    IF l_dbg_level > 0 THEN
      oe_debug_pub.ADD('In Oe_Genesis_Util.Inventory_Org: '
                                            || p_inventory_org_id);
    END IF;

    IF p_inventory_org_id IS NOT NULL THEN
        SELECT  organization_name
          INTO    l_inventory_org
        FROM    org_organization_definitions
        WHERE   organization_id = p_inventory_org_id;
    END IF;

    IF l_dbg_level > 0  THEN
      oe_debug_pub.ADD('  Inventory Org Name: ' || l_inventory_org);
    END IF;

    RETURN l_inventory_org;
EXCEPTION
  WHEN OTHERS THEN
    l_inventory_org :=  NULL;
    RETURN l_inventory_org;
END Inventory_Org;


FUNCTION status_needs_sync(
                            p_flow_status_code  VARCHAR2,
                            p_object_level      VARCHAR2 DEFAULT NULL
                          )
  RETURN BOOLEAN
IS
  CURSOR status_sync_info_cur IS
    SELECT  flow_status_code, object_level, sync_reqd_flag
      FROM    oe_flow_status_aia_sync
      WHERE   sync_reqd_flag  = 'Y'
    ;
  l_sync_reqd   BOOLEAN :=  FALSE;
  l_debug_level NUMBER  :=  oe_debug_pub.g_debug_level;
BEGIN
  IF l_debug_level > 0 THEN
    oe_debug_pub.ADD('Entering status_needs_sync...', 1);
    oe_debug_pub.ADD(' p_flow_status_code = ' || p_flow_status_code, 1);
  END IF;

  -- If the passed in flow status code is null, return immediately.
  IF p_flow_status_code IS NULL THEN

    IF l_debug_level > 0 THEN
      oe_debug_pub.ADD('  Returning from location 0...', 1);
    END IF;

    RETURN l_sync_reqd;
  END IF;

  -- If the status data is not yet loaded into memory, load it.
  IF NOT g_status_setup_loaded THEN

    IF l_debug_level > 0 THEN
      oe_debug_pub.ADD('  Loading status setup information from DB...', 1);
    END IF;

    FOR status_sync_rec IN status_sync_info_cur
    LOOP
      g_status_setup_tab(status_sync_rec.flow_status_code).flow_status_code  :=
                            status_sync_rec.flow_status_code;
      g_status_setup_tab(status_sync_rec.flow_status_code).object_level      :=
                            status_sync_rec.object_level;
    END LOOP;
    g_status_setup_loaded :=  TRUE;
  END IF;

  -- Return to the caller, whether the sync is required or not.
  l_sync_reqd :=  g_status_setup_tab.EXISTS(p_flow_status_code);

  IF l_debug_level > 0 THEN
    IF l_sync_reqd = TRUE THEN
      oe_debug_pub.ADD(' l_sync_reqd is true. Returning...', 1);
    ELSE
      oe_debug_pub.ADD(' l_sync_reqd is false.  Returning...', 1);
    END IF;
  END IF;

  RETURN l_sync_reqd;

END;


PROCEDURE header_rec_to_hdr_rec25(
    p_header_rec IN         oe_order_pub_header_rec_type,
    x_hdr_rec25  OUT NOCOPY oe_order_pub_hdr_rec25
)
IS
BEGIN
  x_hdr_rec25 := oe_order_pub_hdr_rec25(
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                );

  x_hdr_rec25.ACCOUNTING_RULE_ID:= p_header_rec.ACCOUNTING_RULE_ID;
  x_hdr_rec25.AGREEMENT_ID:= p_header_rec.AGREEMENT_ID;
  x_hdr_rec25.ATTRIBUTE1:= p_header_rec.ATTRIBUTE1;
  x_hdr_rec25.ATTRIBUTE10:= p_header_rec.ATTRIBUTE10;
  x_hdr_rec25.ATTRIBUTE11:= p_header_rec.ATTRIBUTE11;
  x_hdr_rec25.ATTRIBUTE12:= p_header_rec.ATTRIBUTE12;
  x_hdr_rec25.ATTRIBUTE13:= p_header_rec.ATTRIBUTE13;
  x_hdr_rec25.ATTRIBUTE14:= p_header_rec.ATTRIBUTE14;
  x_hdr_rec25.ATTRIBUTE15:= p_header_rec.ATTRIBUTE15;
  x_hdr_rec25.ATTRIBUTE16:= p_header_rec.ATTRIBUTE16;
  x_hdr_rec25.ATTRIBUTE17:= p_header_rec.ATTRIBUTE17;
  x_hdr_rec25.ATTRIBUTE18:= p_header_rec.ATTRIBUTE18;
  x_hdr_rec25.ATTRIBUTE19:= p_header_rec.ATTRIBUTE19;
  x_hdr_rec25.ATTRIBUTE2:= p_header_rec.ATTRIBUTE2;
  x_hdr_rec25.ATTRIBUTE20:= p_header_rec.ATTRIBUTE20;
  x_hdr_rec25.ATTRIBUTE3:= p_header_rec.ATTRIBUTE3;
  x_hdr_rec25.ATTRIBUTE4:= p_header_rec.ATTRIBUTE4;
  x_hdr_rec25.ATTRIBUTE5:= p_header_rec.ATTRIBUTE5;
  x_hdr_rec25.ATTRIBUTE6:= p_header_rec.ATTRIBUTE6;
  x_hdr_rec25.ATTRIBUTE7:= p_header_rec.ATTRIBUTE7;
  x_hdr_rec25.ATTRIBUTE8:= p_header_rec.ATTRIBUTE8;
  x_hdr_rec25.ATTRIBUTE9:= p_header_rec.ATTRIBUTE9;
  x_hdr_rec25.BOOKED_FLAG:= p_header_rec.BOOKED_FLAG;
  x_hdr_rec25.CANCELLED_FLAG:= p_header_rec.CANCELLED_FLAG;
  x_hdr_rec25.CONTEXT:= p_header_rec.CONTEXT;
  x_hdr_rec25.CONVERSION_RATE:= p_header_rec.CONVERSION_RATE;
  x_hdr_rec25.CONVERSION_RATE_DATE:= p_header_rec.CONVERSION_RATE_DATE;
  x_hdr_rec25.CONVERSION_TYPE_CODE:= p_header_rec.CONVERSION_TYPE_CODE;
  x_hdr_rec25.CUSTOMER_PREFERENCE_SET_CODE:= p_header_rec.CUSTOMER_PREFERENCE_SET_CODE;
  x_hdr_rec25.CREATED_BY:= p_header_rec.CREATED_BY;
  x_hdr_rec25.CREATION_DATE:= p_header_rec.CREATION_DATE;
  x_hdr_rec25.CUST_PO_NUMBER:= p_header_rec.CUST_PO_NUMBER;
  x_hdr_rec25.DELIVER_TO_CONTACT_ID:= p_header_rec.DELIVER_TO_CONTACT_ID;
  x_hdr_rec25.DELIVER_TO_ORG_ID:= p_header_rec.DELIVER_TO_ORG_ID;
  x_hdr_rec25.DEMAND_CLASS_CODE:= p_header_rec.DEMAND_CLASS_CODE;
  x_hdr_rec25.EARLIEST_SCHEDULE_LIMIT:= p_header_rec.EARLIEST_SCHEDULE_LIMIT;
  x_hdr_rec25.EXPIRATION_DATE:= p_header_rec.EXPIRATION_DATE;
  x_hdr_rec25.FOB_POINT_CODE:= p_header_rec.FOB_POINT_CODE;
  x_hdr_rec25.FREIGHT_CARRIER_CODE:= p_header_rec.FREIGHT_CARRIER_CODE;
  x_hdr_rec25.FREIGHT_TERMS_CODE:= p_header_rec.FREIGHT_TERMS_CODE;
  x_hdr_rec25.GLOBAL_ATTRIBUTE1:= p_header_rec.GLOBAL_ATTRIBUTE1;
  x_hdr_rec25.GLOBAL_ATTRIBUTE10:= p_header_rec.GLOBAL_ATTRIBUTE10;
  x_hdr_rec25.GLOBAL_ATTRIBUTE11:= p_header_rec.GLOBAL_ATTRIBUTE11;
  x_hdr_rec25.GLOBAL_ATTRIBUTE12:= p_header_rec.GLOBAL_ATTRIBUTE12;
  x_hdr_rec25.GLOBAL_ATTRIBUTE13:= p_header_rec.GLOBAL_ATTRIBUTE13;
  x_hdr_rec25.GLOBAL_ATTRIBUTE14:= p_header_rec.GLOBAL_ATTRIBUTE14;
  x_hdr_rec25.GLOBAL_ATTRIBUTE15:= p_header_rec.GLOBAL_ATTRIBUTE15;
  x_hdr_rec25.GLOBAL_ATTRIBUTE16:= p_header_rec.GLOBAL_ATTRIBUTE16;
  x_hdr_rec25.GLOBAL_ATTRIBUTE17:= p_header_rec.GLOBAL_ATTRIBUTE17;
  x_hdr_rec25.GLOBAL_ATTRIBUTE18:= p_header_rec.GLOBAL_ATTRIBUTE18;
  x_hdr_rec25.GLOBAL_ATTRIBUTE19:= p_header_rec.GLOBAL_ATTRIBUTE19;
  x_hdr_rec25.GLOBAL_ATTRIBUTE2:= p_header_rec.GLOBAL_ATTRIBUTE2;
  x_hdr_rec25.GLOBAL_ATTRIBUTE20:= p_header_rec.GLOBAL_ATTRIBUTE20;
  x_hdr_rec25.GLOBAL_ATTRIBUTE3:= p_header_rec.GLOBAL_ATTRIBUTE3;
  x_hdr_rec25.GLOBAL_ATTRIBUTE4:= p_header_rec.GLOBAL_ATTRIBUTE4;
  x_hdr_rec25.GLOBAL_ATTRIBUTE5:= p_header_rec.GLOBAL_ATTRIBUTE5;
  x_hdr_rec25.GLOBAL_ATTRIBUTE6:= p_header_rec.GLOBAL_ATTRIBUTE6;
  x_hdr_rec25.GLOBAL_ATTRIBUTE7:= p_header_rec.GLOBAL_ATTRIBUTE7;
  x_hdr_rec25.GLOBAL_ATTRIBUTE8:= p_header_rec.GLOBAL_ATTRIBUTE8;
  x_hdr_rec25.GLOBAL_ATTRIBUTE9:= p_header_rec.GLOBAL_ATTRIBUTE9;
  x_hdr_rec25.GLOBAL_ATTRIBUTE_CATEGORY:= p_header_rec.GLOBAL_ATTRIBUTE_CATEGORY;
  x_hdr_rec25.TP_CONTEXT:= p_header_rec.TP_CONTEXT;
  x_hdr_rec25.TP_ATTRIBUTE1:= p_header_rec.TP_ATTRIBUTE1;
  x_hdr_rec25.TP_ATTRIBUTE2:= p_header_rec.TP_ATTRIBUTE2;
  x_hdr_rec25.TP_ATTRIBUTE3:= p_header_rec.TP_ATTRIBUTE3;
  x_hdr_rec25.TP_ATTRIBUTE4:= p_header_rec.TP_ATTRIBUTE4;
  x_hdr_rec25.TP_ATTRIBUTE5:= p_header_rec.TP_ATTRIBUTE5;
  x_hdr_rec25.TP_ATTRIBUTE6:= p_header_rec.TP_ATTRIBUTE6;
  x_hdr_rec25.TP_ATTRIBUTE7:= p_header_rec.TP_ATTRIBUTE7;
  x_hdr_rec25.TP_ATTRIBUTE8:= p_header_rec.TP_ATTRIBUTE8;
  x_hdr_rec25.TP_ATTRIBUTE9:= p_header_rec.TP_ATTRIBUTE9;
  x_hdr_rec25.TP_ATTRIBUTE10:= p_header_rec.TP_ATTRIBUTE10;
  x_hdr_rec25.TP_ATTRIBUTE11:= p_header_rec.TP_ATTRIBUTE11;
  x_hdr_rec25.TP_ATTRIBUTE12:= p_header_rec.TP_ATTRIBUTE12;
  x_hdr_rec25.TP_ATTRIBUTE13:= p_header_rec.TP_ATTRIBUTE13;
  x_hdr_rec25.TP_ATTRIBUTE14:= p_header_rec.TP_ATTRIBUTE14;
  x_hdr_rec25.TP_ATTRIBUTE15:= p_header_rec.TP_ATTRIBUTE15;
  x_hdr_rec25.HEADER_ID:= p_header_rec.HEADER_ID;
  x_hdr_rec25.INVOICE_TO_CONTACT_ID:= p_header_rec.INVOICE_TO_CONTACT_ID;
  x_hdr_rec25.INVOICE_TO_ORG_ID:= p_header_rec.INVOICE_TO_ORG_ID;
  x_hdr_rec25.INVOICING_RULE_ID:= p_header_rec.INVOICING_RULE_ID;
  x_hdr_rec25.LAST_UPDATED_BY:= p_header_rec.LAST_UPDATED_BY;
  x_hdr_rec25.LAST_UPDATE_DATE:= p_header_rec.LAST_UPDATE_DATE;
  x_hdr_rec25.LAST_UPDATE_LOGIN:= p_header_rec.LAST_UPDATE_LOGIN;
  x_hdr_rec25.LATEST_SCHEDULE_LIMIT:= p_header_rec.LATEST_SCHEDULE_LIMIT;
  x_hdr_rec25.OPEN_FLAG:= p_header_rec.OPEN_FLAG;
  x_hdr_rec25.ORDER_CATEGORY_CODE:= p_header_rec.ORDER_CATEGORY_CODE;
  x_hdr_rec25.ORDERED_DATE:= p_header_rec.ORDERED_DATE;
  x_hdr_rec25.ORDER_DATE_TYPE_CODE:= p_header_rec.ORDER_DATE_TYPE_CODE;
  x_hdr_rec25.ORDER_NUMBER:= p_header_rec.ORDER_NUMBER;
  x_hdr_rec25.ORDER_SOURCE_ID:= p_header_rec.ORDER_SOURCE_ID;
  x_hdr_rec25.ORDER_TYPE_ID:= p_header_rec.ORDER_TYPE_ID;
  x_hdr_rec25.ORG_ID:= p_header_rec.ORG_ID;
  x_hdr_rec25.ORIG_SYS_DOCUMENT_REF:= p_header_rec.ORIG_SYS_DOCUMENT_REF;
  x_hdr_rec25.PARTIAL_SHIPMENTS_ALLOWED:= p_header_rec.PARTIAL_SHIPMENTS_ALLOWED;
  x_hdr_rec25.PAYMENT_TERM_ID:= p_header_rec.PAYMENT_TERM_ID;
  x_hdr_rec25.PRICE_LIST_ID:= p_header_rec.PRICE_LIST_ID;
  x_hdr_rec25.PRICE_REQUEST_CODE:= p_header_rec.PRICE_REQUEST_CODE;
  x_hdr_rec25.PRICING_DATE:= p_header_rec.PRICING_DATE;
  x_hdr_rec25.PROGRAM_APPLICATION_ID:= p_header_rec.PROGRAM_APPLICATION_ID;
  x_hdr_rec25.PROGRAM_ID:= p_header_rec.PROGRAM_ID;
  x_hdr_rec25.PROGRAM_UPDATE_DATE:= p_header_rec.PROGRAM_UPDATE_DATE;
  x_hdr_rec25.REQUEST_DATE:= p_header_rec.REQUEST_DATE;
  x_hdr_rec25.REQUEST_ID:= p_header_rec.REQUEST_ID;
  x_hdr_rec25.RETURN_REASON_CODE:= p_header_rec.RETURN_REASON_CODE;
  x_hdr_rec25.SALESREP_ID:= p_header_rec.SALESREP_ID;
  x_hdr_rec25.SALES_CHANNEL_CODE:= p_header_rec.SALES_CHANNEL_CODE;
  x_hdr_rec25.SHIPMENT_PRIORITY_CODE:= p_header_rec.SHIPMENT_PRIORITY_CODE;
  x_hdr_rec25.SHIPPING_METHOD_CODE:= p_header_rec.SHIPPING_METHOD_CODE;
  x_hdr_rec25.SHIP_FROM_ORG_ID:= p_header_rec.SHIP_FROM_ORG_ID;
  x_hdr_rec25.SHIP_TOLERANCE_ABOVE:= p_header_rec.SHIP_TOLERANCE_ABOVE;
  x_hdr_rec25.SHIP_TOLERANCE_BELOW:= p_header_rec.SHIP_TOLERANCE_BELOW;
  x_hdr_rec25.SHIP_TO_CONTACT_ID:= p_header_rec.SHIP_TO_CONTACT_ID;
  x_hdr_rec25.SHIP_TO_ORG_ID:= p_header_rec.SHIP_TO_ORG_ID;
  x_hdr_rec25.SOLD_FROM_ORG_ID:= p_header_rec.SOLD_FROM_ORG_ID;
  x_hdr_rec25.SOLD_TO_CONTACT_ID:= p_header_rec.SOLD_TO_CONTACT_ID;
  x_hdr_rec25.SOLD_TO_ORG_ID:= p_header_rec.SOLD_TO_ORG_ID;
  x_hdr_rec25.SOLD_TO_PHONE_ID:= p_header_rec.SOLD_TO_PHONE_ID;
  x_hdr_rec25.SOURCE_DOCUMENT_ID:= p_header_rec.SOURCE_DOCUMENT_ID;
  x_hdr_rec25.SOURCE_DOCUMENT_TYPE_ID:= p_header_rec.SOURCE_DOCUMENT_TYPE_ID;
  x_hdr_rec25.TAX_EXEMPT_FLAG:= p_header_rec.TAX_EXEMPT_FLAG;
  x_hdr_rec25.TAX_EXEMPT_NUMBER:= p_header_rec.TAX_EXEMPT_NUMBER;
  x_hdr_rec25.TAX_EXEMPT_REASON_CODE:= p_header_rec.TAX_EXEMPT_REASON_CODE;
  x_hdr_rec25.TAX_POINT_CODE:= p_header_rec.TAX_POINT_CODE;
  x_hdr_rec25.TRANSACTIONAL_CURR_CODE:= p_header_rec.TRANSACTIONAL_CURR_CODE;
  x_hdr_rec25.VERSION_NUMBER:= p_header_rec.VERSION_NUMBER;
  x_hdr_rec25.RETURN_STATUS:= p_header_rec.RETURN_STATUS;
  x_hdr_rec25.DB_FLAG:= p_header_rec.DB_FLAG;
  x_hdr_rec25.OPERATION:= p_header_rec.OPERATION;
  x_hdr_rec25.FIRST_ACK_CODE:= p_header_rec.FIRST_ACK_CODE;
  x_hdr_rec25.FIRST_ACK_DATE:= p_header_rec.FIRST_ACK_DATE;
  x_hdr_rec25.LAST_ACK_CODE:= p_header_rec.LAST_ACK_CODE;
  x_hdr_rec25.LAST_ACK_DATE:= p_header_rec.LAST_ACK_DATE;
  x_hdr_rec25.CHANGE_REASON:= p_header_rec.CHANGE_REASON;
  x_hdr_rec25.CHANGE_COMMENTS:= p_header_rec.CHANGE_COMMENTS;
  x_hdr_rec25.CHANGE_SEQUENCE:= p_header_rec.CHANGE_SEQUENCE;
  x_hdr_rec25.CHANGE_REQUEST_CODE:= p_header_rec.CHANGE_REQUEST_CODE;
  x_hdr_rec25.READY_FLAG:= p_header_rec.READY_FLAG;
  x_hdr_rec25.STATUS_FLAG:= p_header_rec.STATUS_FLAG;
  x_hdr_rec25.FORCE_APPLY_FLAG:= p_header_rec.FORCE_APPLY_FLAG;
  x_hdr_rec25.DROP_SHIP_FLAG:= p_header_rec.DROP_SHIP_FLAG;
  x_hdr_rec25.CUSTOMER_PAYMENT_TERM_ID:= p_header_rec.CUSTOMER_PAYMENT_TERM_ID;
  x_hdr_rec25.PAYMENT_TYPE_CODE:= p_header_rec.PAYMENT_TYPE_CODE;
  x_hdr_rec25.PAYMENT_AMOUNT:= p_header_rec.PAYMENT_AMOUNT;
  x_hdr_rec25.CHECK_NUMBER:= p_header_rec.CHECK_NUMBER;
  x_hdr_rec25.CREDIT_CARD_CODE:= p_header_rec.CREDIT_CARD_CODE;
  x_hdr_rec25.CREDIT_CARD_HOLDER_NAME:= p_header_rec.CREDIT_CARD_HOLDER_NAME;
  x_hdr_rec25.CREDIT_CARD_NUMBER:= p_header_rec.CREDIT_CARD_NUMBER;
  x_hdr_rec25.CREDIT_CARD_EXPIRATION_DATE:= p_header_rec.CREDIT_CARD_EXPIRATION_DATE;
  x_hdr_rec25.CREDIT_CARD_APPROVAL_CODE:= p_header_rec.CREDIT_CARD_APPROVAL_CODE;
  x_hdr_rec25.CREDIT_CARD_APPROVAL_DATE:= p_header_rec.CREDIT_CARD_APPROVAL_DATE;
  x_hdr_rec25.SHIPPING_INSTRUCTIONS:= p_header_rec.SHIPPING_INSTRUCTIONS;
  x_hdr_rec25.PACKING_INSTRUCTIONS:= p_header_rec.PACKING_INSTRUCTIONS;
  x_hdr_rec25.FLOW_STATUS_CODE:= p_header_rec.FLOW_STATUS_CODE;
  x_hdr_rec25.BOOKED_DATE:= p_header_rec.BOOKED_DATE;
  x_hdr_rec25.MARKETING_SOURCE_CODE_ID:= p_header_rec.MARKETING_SOURCE_CODE_ID;
  x_hdr_rec25.UPGRADED_FLAG:= p_header_rec.UPGRADED_FLAG;
  x_hdr_rec25.LOCK_CONTROL:= p_header_rec.LOCK_CONTROL;
  x_hdr_rec25.SHIP_TO_EDI_LOCATION_CODE:= p_header_rec.SHIP_TO_EDI_LOCATION_CODE;
  x_hdr_rec25.SOLD_TO_EDI_LOCATION_CODE:= p_header_rec.SOLD_TO_EDI_LOCATION_CODE;
  x_hdr_rec25.BILL_TO_EDI_LOCATION_CODE:= p_header_rec.BILL_TO_EDI_LOCATION_CODE;
  x_hdr_rec25.SHIP_FROM_EDI_LOCATION_CODE:= p_header_rec.SHIP_FROM_EDI_LOCATION_CODE;
  x_hdr_rec25.SHIP_FROM_ADDRESS_ID:= p_header_rec.SHIP_FROM_ADDRESS_ID;
  x_hdr_rec25.SOLD_TO_ADDRESS_ID:= p_header_rec.SOLD_TO_ADDRESS_ID;
  x_hdr_rec25.SHIP_TO_ADDRESS_ID:= p_header_rec.SHIP_TO_ADDRESS_ID;
  x_hdr_rec25.INVOICE_ADDRESS_ID:= p_header_rec.INVOICE_ADDRESS_ID;
  x_hdr_rec25.SHIP_TO_ADDRESS_CODE:= p_header_rec.SHIP_TO_ADDRESS_CODE;
  x_hdr_rec25.XML_MESSAGE_ID:= p_header_rec.XML_MESSAGE_ID;
  x_hdr_rec25.SHIP_TO_CUSTOMER_ID:= p_header_rec.SHIP_TO_CUSTOMER_ID;
  x_hdr_rec25.INVOICE_TO_CUSTOMER_ID:= p_header_rec.INVOICE_TO_CUSTOMER_ID;
  x_hdr_rec25.DELIVER_TO_CUSTOMER_ID:= p_header_rec.DELIVER_TO_CUSTOMER_ID;
  x_hdr_rec25.ACCOUNTING_RULE_DURATION:= p_header_rec.ACCOUNTING_RULE_DURATION;
  x_hdr_rec25.XML_TRANSACTION_TYPE_CODE:= p_header_rec.XML_TRANSACTION_TYPE_CODE;
  x_hdr_rec25.BLANKET_NUMBER:= p_header_rec.BLANKET_NUMBER;
  x_hdr_rec25.LINE_SET_NAME:= p_header_rec.LINE_SET_NAME;
  x_hdr_rec25.FULFILLMENT_SET_NAME:= p_header_rec.FULFILLMENT_SET_NAME;
  x_hdr_rec25.DEFAULT_FULFILLMENT_SET:= p_header_rec.DEFAULT_FULFILLMENT_SET;
  x_hdr_rec25.QUOTE_DATE:= p_header_rec.QUOTE_DATE;
  x_hdr_rec25.QUOTE_NUMBER:= p_header_rec.QUOTE_NUMBER;
  x_hdr_rec25.SALES_DOCUMENT_NAME:= p_header_rec.SALES_DOCUMENT_NAME;
  x_hdr_rec25.TRANSACTION_PHASE_CODE:= p_header_rec.TRANSACTION_PHASE_CODE;
  x_hdr_rec25.USER_STATUS_CODE:= p_header_rec.USER_STATUS_CODE;
  x_hdr_rec25.DRAFT_SUBMITTED_FLAG:= p_header_rec.DRAFT_SUBMITTED_FLAG;
  x_hdr_rec25.SOURCE_DOCUMENT_VERSION_NUMBER:= p_header_rec.SOURCE_DOCUMENT_VERSION_NUMBER;
  x_hdr_rec25.SOLD_TO_SITE_USE_ID:= p_header_rec.SOLD_TO_SITE_USE_ID;
  x_hdr_rec25.MINISITE_ID:= p_header_rec.MINISITE_ID;
  x_hdr_rec25.IB_OWNER:= p_header_rec.IB_OWNER;
  x_hdr_rec25.IB_INSTALLED_AT_LOCATION:= p_header_rec.IB_INSTALLED_AT_LOCATION;
  x_hdr_rec25.IB_CURRENT_LOCATION:= p_header_rec.IB_CURRENT_LOCATION;
  x_hdr_rec25.END_CUSTOMER_ID:= p_header_rec.END_CUSTOMER_ID;
  x_hdr_rec25.END_CUSTOMER_CONTACT_ID:= p_header_rec.END_CUSTOMER_CONTACT_ID;
  x_hdr_rec25.END_CUSTOMER_SITE_USE_ID:= p_header_rec.END_CUSTOMER_SITE_USE_ID;
  x_hdr_rec25.SUPPLIER_SIGNATURE:= p_header_rec.SUPPLIER_SIGNATURE;
  x_hdr_rec25.SUPPLIER_SIGNATURE_DATE:= p_header_rec.SUPPLIER_SIGNATURE_DATE;
  x_hdr_rec25.CUSTOMER_SIGNATURE:= p_header_rec.CUSTOMER_SIGNATURE;
  x_hdr_rec25.CUSTOMER_SIGNATURE_DATE:= p_header_rec.CUSTOMER_SIGNATURE_DATE;
  x_hdr_rec25.SOLD_TO_PARTY_ID:= p_header_rec.SOLD_TO_PARTY_ID;
  x_hdr_rec25.SOLD_TO_ORG_CONTACT_ID:= p_header_rec.SOLD_TO_ORG_CONTACT_ID;
  x_hdr_rec25.SHIP_TO_PARTY_ID:= p_header_rec.SHIP_TO_PARTY_ID;
  x_hdr_rec25.SHIP_TO_PARTY_SITE_ID:= p_header_rec.SHIP_TO_PARTY_SITE_ID;
  x_hdr_rec25.SHIP_TO_PARTY_SITE_USE_ID:= p_header_rec.SHIP_TO_PARTY_SITE_USE_ID;
  x_hdr_rec25.DELIVER_TO_PARTY_ID:= p_header_rec.DELIVER_TO_PARTY_ID;
  x_hdr_rec25.DELIVER_TO_PARTY_SITE_ID:= p_header_rec.DELIVER_TO_PARTY_SITE_ID;
  x_hdr_rec25.DELIVER_TO_PARTY_SITE_USE_ID:= p_header_rec.DELIVER_TO_PARTY_SITE_USE_ID;
  x_hdr_rec25.INVOICE_TO_PARTY_ID:= p_header_rec.INVOICE_TO_PARTY_ID;
  x_hdr_rec25.INVOICE_TO_PARTY_SITE_ID:= p_header_rec.INVOICE_TO_PARTY_SITE_ID;
  x_hdr_rec25.INVOICE_TO_PARTY_SITE_USE_ID:= p_header_rec.INVOICE_TO_PARTY_SITE_USE_ID;
  x_hdr_rec25.END_CUSTOMER_PARTY_ID:= p_header_rec.END_CUSTOMER_PARTY_ID;
  x_hdr_rec25.END_CUSTOMER_PARTY_SITE_ID:= p_header_rec.END_CUSTOMER_PARTY_SITE_ID;
  x_hdr_rec25.END_CUSTOMER_PARTY_SITE_USE_ID:= p_header_rec.END_CUSTOMER_PARTY_SITE_USE_ID;
  x_hdr_rec25.END_CUSTOMER_PARTY_NUMBER:= p_header_rec.END_CUSTOMER_PARTY_NUMBER;
  x_hdr_rec25.END_CUSTOMER_ORG_CONTACT_ID:= p_header_rec.END_CUSTOMER_ORG_CONTACT_ID;
  x_hdr_rec25.SHIP_TO_CUSTOMER_PARTY_ID:= p_header_rec.SHIP_TO_CUSTOMER_PARTY_ID;
  x_hdr_rec25.DELIVER_TO_CUSTOMER_PARTY_ID:= p_header_rec.DELIVER_TO_CUSTOMER_PARTY_ID;
  x_hdr_rec25.INVOICE_TO_CUSTOMER_PARTY_ID:= p_header_rec.INVOICE_TO_CUSTOMER_PARTY_ID;
  x_hdr_rec25.SHIP_TO_ORG_CONTACT_ID:= p_header_rec.SHIP_TO_ORG_CONTACT_ID;
  x_hdr_rec25.DELIVER_TO_ORG_CONTACT_ID:= p_header_rec.DELIVER_TO_ORG_CONTACT_ID;
  x_hdr_rec25.INVOICE_TO_ORG_CONTACT_ID:= p_header_rec.INVOICE_TO_ORG_CONTACT_ID;
  x_hdr_rec25.CONTRACT_TEMPLATE_ID:= p_header_rec.CONTRACT_TEMPLATE_ID;
  x_hdr_rec25.CONTRACT_SOURCE_DOC_TYPE_CODE:= p_header_rec.CONTRACT_SOURCE_DOC_TYPE_CODE;
  x_hdr_rec25.CONTRACT_SOURCE_DOCUMENT_ID:= p_header_rec.CONTRACT_SOURCE_DOCUMENT_ID;
  x_hdr_rec25.SOLD_TO_PARTY_NUMBER:= p_header_rec.SOLD_TO_PARTY_NUMBER;
  x_hdr_rec25.SHIP_TO_PARTY_NUMBER:= p_header_rec.SHIP_TO_PARTY_NUMBER;
  x_hdr_rec25.INVOICE_TO_PARTY_NUMBER:= p_header_rec.INVOICE_TO_PARTY_NUMBER;
  x_hdr_rec25.DELIVER_TO_PARTY_NUMBER:= p_header_rec.DELIVER_TO_PARTY_NUMBER;
  x_hdr_rec25.ORDER_FIRMED_DATE:= p_header_rec.ORDER_FIRMED_DATE;

  x_hdr_rec25.freight_charge  :=  NULL;
  x_hdr_rec25.tax_value       :=  NULL;
END header_rec_to_hdr_rec25;

PROCEDURE line_rec_to_line_rec25(
    p_line_rec    IN          oe_order_pub_line_rec_type,
    x_line_rec25  OUT NOCOPY  oe_order_pub_line_rec25
)
IS
BEGIN
  x_line_rec25  :=  oe_order_pub_line_rec25(
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                      NULL, NULL, NULL, NULL);

  x_line_rec25.ACCOUNTING_RULE_ID := p_line_rec.ACCOUNTING_RULE_ID ;
  x_line_rec25.ACTUAL_ARRIVAL_DATE := p_line_rec.ACTUAL_ARRIVAL_DATE ;
  x_line_rec25.ACTUAL_SHIPMENT_DATE := p_line_rec.ACTUAL_SHIPMENT_DATE ;
  x_line_rec25.AGREEMENT_ID := p_line_rec.AGREEMENT_ID ;
  x_line_rec25.ARRIVAL_SET_ID := p_line_rec.ARRIVAL_SET_ID ;
  x_line_rec25.ATO_LINE_ID := p_line_rec.ATO_LINE_ID ;
  x_line_rec25.ATTRIBUTE1 := p_line_rec.ATTRIBUTE1 ;
  x_line_rec25.ATTRIBUTE10 := p_line_rec.ATTRIBUTE10 ;
  x_line_rec25.ATTRIBUTE11 := p_line_rec.ATTRIBUTE11 ;
  x_line_rec25.ATTRIBUTE12 := p_line_rec.ATTRIBUTE12 ;
  x_line_rec25.ATTRIBUTE13 := p_line_rec.ATTRIBUTE13 ;
  x_line_rec25.ATTRIBUTE14 := p_line_rec.ATTRIBUTE14 ;
  x_line_rec25.ATTRIBUTE15 := p_line_rec.ATTRIBUTE15 ;
  x_line_rec25.ATTRIBUTE16 := p_line_rec.ATTRIBUTE16 ;
  x_line_rec25.ATTRIBUTE17 := p_line_rec.ATTRIBUTE17 ;
  x_line_rec25.ATTRIBUTE18 := p_line_rec.ATTRIBUTE18 ;
  x_line_rec25.ATTRIBUTE19 := p_line_rec.ATTRIBUTE19 ;
  x_line_rec25.ATTRIBUTE2 := p_line_rec.ATTRIBUTE2 ;
  x_line_rec25.ATTRIBUTE20 := p_line_rec.ATTRIBUTE20 ;
  x_line_rec25.ATTRIBUTE3 := p_line_rec.ATTRIBUTE3 ;
  x_line_rec25.ATTRIBUTE4 := p_line_rec.ATTRIBUTE4 ;
  x_line_rec25.ATTRIBUTE5 := p_line_rec.ATTRIBUTE5 ;
  x_line_rec25.ATTRIBUTE6 := p_line_rec.ATTRIBUTE6 ;
  x_line_rec25.ATTRIBUTE7 := p_line_rec.ATTRIBUTE7 ;
  x_line_rec25.ATTRIBUTE8 := p_line_rec.ATTRIBUTE8 ;
  x_line_rec25.ATTRIBUTE9 := p_line_rec.ATTRIBUTE9 ;
  x_line_rec25.AUTHORIZED_TO_SHIP_FLAG := p_line_rec.AUTHORIZED_TO_SHIP_FLAG ;
  x_line_rec25.AUTO_SELECTED_QUANTITY := p_line_rec.AUTO_SELECTED_QUANTITY ;
  x_line_rec25.BOOKED_FLAG := p_line_rec.BOOKED_FLAG ;
  x_line_rec25.CANCELLED_FLAG := p_line_rec.CANCELLED_FLAG ;
  x_line_rec25.CANCELLED_QUANTITY := p_line_rec.CANCELLED_QUANTITY ;
  x_line_rec25.CANCELLED_QUANTITY2 := p_line_rec.CANCELLED_QUANTITY2 ;
  x_line_rec25.COMMITMENT_ID := p_line_rec.COMMITMENT_ID ;
  x_line_rec25.COMPONENT_CODE := p_line_rec.COMPONENT_CODE ;
  x_line_rec25.COMPONENT_NUMBER := p_line_rec.COMPONENT_NUMBER ;
  x_line_rec25.COMPONENT_SEQUENCE_ID := p_line_rec.COMPONENT_SEQUENCE_ID ;
  x_line_rec25.CONFIG_HEADER_ID := p_line_rec.CONFIG_HEADER_ID ;
  x_line_rec25.CONFIG_REV_NBR := p_line_rec.CONFIG_REV_NBR ;
  x_line_rec25.CONFIG_DISPLAY_SEQUENCE := p_line_rec.CONFIG_DISPLAY_SEQUENCE ;
  x_line_rec25.CONFIGURATION_ID := p_line_rec.CONFIGURATION_ID ;
  x_line_rec25.CONTEXT := p_line_rec.CONTEXT ;
  x_line_rec25.CREATED_BY := p_line_rec.CREATED_BY ;
  x_line_rec25.CREATION_DATE := p_line_rec.CREATION_DATE ;
  x_line_rec25.CREDIT_INVOICE_LINE_ID := p_line_rec.CREDIT_INVOICE_LINE_ID ;
  x_line_rec25.CUSTOMER_DOCK_CODE := p_line_rec.CUSTOMER_DOCK_CODE ;
  x_line_rec25.CUSTOMER_JOB := p_line_rec.CUSTOMER_JOB ;
  x_line_rec25.CUSTOMER_PRODUCTION_LINE := p_line_rec.CUSTOMER_PRODUCTION_LINE ;
  x_line_rec25.CUSTOMER_TRX_LINE_ID := p_line_rec.CUSTOMER_TRX_LINE_ID ;
  x_line_rec25.CUST_MODEL_SERIAL_NUMBER := p_line_rec.CUST_MODEL_SERIAL_NUMBER ;
  x_line_rec25.CUST_PO_NUMBER := p_line_rec.CUST_PO_NUMBER ;
  x_line_rec25.CUST_PRODUCTION_SEQ_NUM := p_line_rec.CUST_PRODUCTION_SEQ_NUM ;
  x_line_rec25.DELIVERY_LEAD_TIME := p_line_rec.DELIVERY_LEAD_TIME ;
  x_line_rec25.DELIVER_TO_CONTACT_ID := p_line_rec.DELIVER_TO_CONTACT_ID ;
  x_line_rec25.DELIVER_TO_ORG_ID := p_line_rec.DELIVER_TO_ORG_ID ;
  x_line_rec25.DEMAND_BUCKET_TYPE_CODE := p_line_rec.DEMAND_BUCKET_TYPE_CODE ;
  x_line_rec25.DEMAND_CLASS_CODE := p_line_rec.DEMAND_CLASS_CODE ;
  x_line_rec25.DEP_PLAN_REQUIRED_FLAG := p_line_rec.DEP_PLAN_REQUIRED_FLAG ;
  x_line_rec25.EARLIEST_ACCEPTABLE_DATE := p_line_rec.EARLIEST_ACCEPTABLE_DATE ;
  x_line_rec25.END_ITEM_UNIT_NUMBER := p_line_rec.END_ITEM_UNIT_NUMBER ;
  x_line_rec25.EXPLOSION_DATE := p_line_rec.EXPLOSION_DATE ;
  x_line_rec25.FOB_POINT_CODE := p_line_rec.FOB_POINT_CODE ;
  x_line_rec25.FREIGHT_CARRIER_CODE := p_line_rec.FREIGHT_CARRIER_CODE ;
  x_line_rec25.FREIGHT_TERMS_CODE := p_line_rec.FREIGHT_TERMS_CODE ;
  x_line_rec25.FULFILLED_QUANTITY := p_line_rec.FULFILLED_QUANTITY ;
  x_line_rec25.FULFILLED_QUANTITY2 := p_line_rec.FULFILLED_QUANTITY2 ;
  x_line_rec25.GLOBAL_ATTRIBUTE1 := p_line_rec.GLOBAL_ATTRIBUTE1 ;
  x_line_rec25.GLOBAL_ATTRIBUTE10 := p_line_rec.GLOBAL_ATTRIBUTE10 ;
  x_line_rec25.GLOBAL_ATTRIBUTE11 := p_line_rec.GLOBAL_ATTRIBUTE11 ;
  x_line_rec25.GLOBAL_ATTRIBUTE12 := p_line_rec.GLOBAL_ATTRIBUTE12 ;
  x_line_rec25.GLOBAL_ATTRIBUTE13 := p_line_rec.GLOBAL_ATTRIBUTE13 ;
  x_line_rec25.GLOBAL_ATTRIBUTE14 := p_line_rec.GLOBAL_ATTRIBUTE14 ;
  x_line_rec25.GLOBAL_ATTRIBUTE15 := p_line_rec.GLOBAL_ATTRIBUTE15 ;
  x_line_rec25.GLOBAL_ATTRIBUTE16 := p_line_rec.GLOBAL_ATTRIBUTE16 ;
  x_line_rec25.GLOBAL_ATTRIBUTE17 := p_line_rec.GLOBAL_ATTRIBUTE17 ;
  x_line_rec25.GLOBAL_ATTRIBUTE18 := p_line_rec.GLOBAL_ATTRIBUTE18 ;
  x_line_rec25.GLOBAL_ATTRIBUTE19 := p_line_rec.GLOBAL_ATTRIBUTE19 ;
  x_line_rec25.GLOBAL_ATTRIBUTE2 := p_line_rec.GLOBAL_ATTRIBUTE2 ;
  x_line_rec25.GLOBAL_ATTRIBUTE20 := p_line_rec.GLOBAL_ATTRIBUTE20 ;
  x_line_rec25.GLOBAL_ATTRIBUTE3 := p_line_rec.GLOBAL_ATTRIBUTE3 ;
  x_line_rec25.GLOBAL_ATTRIBUTE4 := p_line_rec.GLOBAL_ATTRIBUTE4 ;
  x_line_rec25.GLOBAL_ATTRIBUTE5 := p_line_rec.GLOBAL_ATTRIBUTE5 ;
  x_line_rec25.GLOBAL_ATTRIBUTE6 := p_line_rec.GLOBAL_ATTRIBUTE6 ;
  x_line_rec25.GLOBAL_ATTRIBUTE7 := p_line_rec.GLOBAL_ATTRIBUTE7 ;
  x_line_rec25.GLOBAL_ATTRIBUTE8 := p_line_rec.GLOBAL_ATTRIBUTE8 ;
  x_line_rec25.GLOBAL_ATTRIBUTE9 := p_line_rec.GLOBAL_ATTRIBUTE9 ;
  x_line_rec25.GLOBAL_ATTRIBUTE_CATEGORY := p_line_rec.GLOBAL_ATTRIBUTE_CATEGORY ;
  x_line_rec25.HEADER_ID := p_line_rec.HEADER_ID ;
  x_line_rec25.INDUSTRY_ATTRIBUTE1 := p_line_rec.INDUSTRY_ATTRIBUTE1 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE10 := p_line_rec.INDUSTRY_ATTRIBUTE10 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE11 := p_line_rec.INDUSTRY_ATTRIBUTE11 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE12 := p_line_rec.INDUSTRY_ATTRIBUTE12 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE13 := p_line_rec.INDUSTRY_ATTRIBUTE13 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE14 := p_line_rec.INDUSTRY_ATTRIBUTE14 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE15 := p_line_rec.INDUSTRY_ATTRIBUTE15 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE16 := p_line_rec.INDUSTRY_ATTRIBUTE16 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE17 := p_line_rec.INDUSTRY_ATTRIBUTE17 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE18 := p_line_rec.INDUSTRY_ATTRIBUTE18 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE19 := p_line_rec.INDUSTRY_ATTRIBUTE19 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE20 := p_line_rec.INDUSTRY_ATTRIBUTE20 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE21 := p_line_rec.INDUSTRY_ATTRIBUTE21 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE22 := p_line_rec.INDUSTRY_ATTRIBUTE22 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE23 := p_line_rec.INDUSTRY_ATTRIBUTE23 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE24 := p_line_rec.INDUSTRY_ATTRIBUTE24 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE25 := p_line_rec.INDUSTRY_ATTRIBUTE25 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE26 := p_line_rec.INDUSTRY_ATTRIBUTE26 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE27 := p_line_rec.INDUSTRY_ATTRIBUTE27 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE28 := p_line_rec.INDUSTRY_ATTRIBUTE28 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE29 := p_line_rec.INDUSTRY_ATTRIBUTE29 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE30 := p_line_rec.INDUSTRY_ATTRIBUTE30 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE2 := p_line_rec.INDUSTRY_ATTRIBUTE2 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE3 := p_line_rec.INDUSTRY_ATTRIBUTE3 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE4 := p_line_rec.INDUSTRY_ATTRIBUTE4 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE5 := p_line_rec.INDUSTRY_ATTRIBUTE5 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE6 := p_line_rec.INDUSTRY_ATTRIBUTE6 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE7 := p_line_rec.INDUSTRY_ATTRIBUTE7 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE8 := p_line_rec.INDUSTRY_ATTRIBUTE8 ;
  x_line_rec25.INDUSTRY_ATTRIBUTE9 := p_line_rec.INDUSTRY_ATTRIBUTE9 ;
  x_line_rec25.INDUSTRY_CONTEXT := p_line_rec.INDUSTRY_CONTEXT ;
  x_line_rec25.TP_CONTEXT := p_line_rec.TP_CONTEXT ;
  x_line_rec25.TP_ATTRIBUTE1 := p_line_rec.TP_ATTRIBUTE1 ;
  x_line_rec25.TP_ATTRIBUTE2 := p_line_rec.TP_ATTRIBUTE2 ;
  x_line_rec25.TP_ATTRIBUTE3 := p_line_rec.TP_ATTRIBUTE3 ;
  x_line_rec25.TP_ATTRIBUTE4 := p_line_rec.TP_ATTRIBUTE4 ;
  x_line_rec25.TP_ATTRIBUTE5 := p_line_rec.TP_ATTRIBUTE5 ;
  x_line_rec25.TP_ATTRIBUTE6 := p_line_rec.TP_ATTRIBUTE6 ;
  x_line_rec25.TP_ATTRIBUTE7 := p_line_rec.TP_ATTRIBUTE7 ;
  x_line_rec25.TP_ATTRIBUTE8 := p_line_rec.TP_ATTRIBUTE8 ;
  x_line_rec25.TP_ATTRIBUTE9 := p_line_rec.TP_ATTRIBUTE9 ;
  x_line_rec25.TP_ATTRIBUTE10 := p_line_rec.TP_ATTRIBUTE10 ;
  x_line_rec25.TP_ATTRIBUTE11 := p_line_rec.TP_ATTRIBUTE11 ;
  x_line_rec25.TP_ATTRIBUTE12 := p_line_rec.TP_ATTRIBUTE12 ;
  x_line_rec25.TP_ATTRIBUTE13 := p_line_rec.TP_ATTRIBUTE13 ;
  x_line_rec25.TP_ATTRIBUTE14 := p_line_rec.TP_ATTRIBUTE14 ;
  x_line_rec25.TP_ATTRIBUTE15 := p_line_rec.TP_ATTRIBUTE15 ;
  x_line_rec25.INTERMED_SHIP_TO_ORG_ID := p_line_rec.INTERMED_SHIP_TO_ORG_ID ;
  x_line_rec25.INTERMED_SHIP_TO_CONTACT_ID := p_line_rec.INTERMED_SHIP_TO_CONTACT_ID ;
  x_line_rec25.INVENTORY_ITEM_ID := p_line_rec.INVENTORY_ITEM_ID ;
  x_line_rec25.INVOICE_INTERFACE_STATUS_CODE := p_line_rec.INVOICE_INTERFACE_STATUS_CODE ;
  x_line_rec25.INVOICE_TO_CONTACT_ID := p_line_rec.INVOICE_TO_CONTACT_ID ;
  x_line_rec25.INVOICE_TO_ORG_ID := p_line_rec.INVOICE_TO_ORG_ID ;
  x_line_rec25.INVOICING_RULE_ID := p_line_rec.INVOICING_RULE_ID ;
  x_line_rec25.ORDERED_ITEM := p_line_rec.ORDERED_ITEM ;
  x_line_rec25.ITEM_REVISION := p_line_rec.ITEM_REVISION ;
  x_line_rec25.ITEM_TYPE_CODE := p_line_rec.ITEM_TYPE_CODE ;
  x_line_rec25.LAST_UPDATED_BY := p_line_rec.LAST_UPDATED_BY ;
  x_line_rec25.LAST_UPDATE_DATE := p_line_rec.LAST_UPDATE_DATE ;
  x_line_rec25.LAST_UPDATE_LOGIN := p_line_rec.LAST_UPDATE_LOGIN ;
  x_line_rec25.LATEST_ACCEPTABLE_DATE := p_line_rec.LATEST_ACCEPTABLE_DATE ;
  x_line_rec25.LINE_CATEGORY_CODE := p_line_rec.LINE_CATEGORY_CODE ;
  x_line_rec25.LINE_ID := p_line_rec.LINE_ID ;
  x_line_rec25.LINE_NUMBER := p_line_rec.LINE_NUMBER ;
  x_line_rec25.LINE_TYPE_ID := p_line_rec.LINE_TYPE_ID ;
  x_line_rec25.LINK_TO_LINE_REF := p_line_rec.LINK_TO_LINE_REF ;
  x_line_rec25.LINK_TO_LINE_ID := p_line_rec.LINK_TO_LINE_ID ;
  x_line_rec25.LINK_TO_LINE_INDEX := p_line_rec.LINK_TO_LINE_INDEX ;
  x_line_rec25.MODEL_GROUP_NUMBER := p_line_rec.MODEL_GROUP_NUMBER ;
  x_line_rec25.MFG_COMPONENT_SEQUENCE_ID := p_line_rec.MFG_COMPONENT_SEQUENCE_ID ;
  x_line_rec25.MFG_LEAD_TIME := p_line_rec.MFG_LEAD_TIME ;
  x_line_rec25.OPEN_FLAG := p_line_rec.OPEN_FLAG ;
  x_line_rec25.OPTION_FLAG := p_line_rec.OPTION_FLAG ;
  x_line_rec25.OPTION_NUMBER := p_line_rec.OPTION_NUMBER ;

  --
  -- Bug 9151484
  --
  IF p_line_rec.line_category_code = 'RETURN' THEN
    x_line_rec25.ORDERED_QUANTITY := -p_line_rec.ORDERED_QUANTITY ;
    x_line_rec25.TAX_VALUE        := -p_line_rec.TAX_VALUE;
  ELSE
    x_line_rec25.ORDERED_QUANTITY := p_line_rec.ORDERED_QUANTITY ;
    x_line_rec25.TAX_VALUE        := p_line_rec.TAX_VALUE;
  END IF;
  --
  -- Bug 9151484
  --

  x_line_rec25.ORDERED_QUANTITY2 := p_line_rec.ORDERED_QUANTITY2 ;
  x_line_rec25.ORDER_QUANTITY_UOM := p_line_rec.ORDER_QUANTITY_UOM ;
  x_line_rec25.ORDERED_QUANTITY_UOM2 := p_line_rec.ORDERED_QUANTITY_UOM2 ;
  x_line_rec25.ORG_ID := p_line_rec.ORG_ID ;
  x_line_rec25.ORIG_SYS_DOCUMENT_REF := p_line_rec.ORIG_SYS_DOCUMENT_REF ;
  x_line_rec25.ORIG_SYS_LINE_REF := p_line_rec.ORIG_SYS_LINE_REF ;
  x_line_rec25.OVER_SHIP_REASON_CODE := p_line_rec.OVER_SHIP_REASON_CODE ;
  x_line_rec25.OVER_SHIP_RESOLVED_FLAG := p_line_rec.OVER_SHIP_RESOLVED_FLAG ;
  x_line_rec25.PAYMENT_TERM_ID := p_line_rec.PAYMENT_TERM_ID ;
  x_line_rec25.PLANNING_PRIORITY := p_line_rec.PLANNING_PRIORITY ;
  x_line_rec25.PREFERRED_GRADE := p_line_rec.PREFERRED_GRADE ;
  x_line_rec25.PRICE_LIST_ID := p_line_rec.PRICE_LIST_ID ;
  x_line_rec25.PRICE_REQUEST_CODE := p_line_rec.PRICE_REQUEST_CODE ;
  x_line_rec25.PRICING_ATTRIBUTE1 := p_line_rec.PRICING_ATTRIBUTE1 ;
  x_line_rec25.PRICING_ATTRIBUTE10 := p_line_rec.PRICING_ATTRIBUTE10 ;
  x_line_rec25.PRICING_ATTRIBUTE2 := p_line_rec.PRICING_ATTRIBUTE2 ;
  x_line_rec25.PRICING_ATTRIBUTE3 := p_line_rec.PRICING_ATTRIBUTE3 ;
  x_line_rec25.PRICING_ATTRIBUTE4 := p_line_rec.PRICING_ATTRIBUTE4 ;
  x_line_rec25.PRICING_ATTRIBUTE5 := p_line_rec.PRICING_ATTRIBUTE5 ;
  x_line_rec25.PRICING_ATTRIBUTE6 := p_line_rec.PRICING_ATTRIBUTE6 ;
  x_line_rec25.PRICING_ATTRIBUTE7 := p_line_rec.PRICING_ATTRIBUTE7 ;
  x_line_rec25.PRICING_ATTRIBUTE8 := p_line_rec.PRICING_ATTRIBUTE8 ;
  x_line_rec25.PRICING_ATTRIBUTE9 := p_line_rec.PRICING_ATTRIBUTE9 ;
  x_line_rec25.PRICING_CONTEXT := p_line_rec.PRICING_CONTEXT ;
  x_line_rec25.PRICING_DATE := p_line_rec.PRICING_DATE ;
  x_line_rec25.PRICING_QUANTITY := p_line_rec.PRICING_QUANTITY ;
  x_line_rec25.PRICING_QUANTITY_UOM := p_line_rec.PRICING_QUANTITY_UOM ;
  x_line_rec25.PROGRAM_APPLICATION_ID := p_line_rec.PROGRAM_APPLICATION_ID ;
  x_line_rec25.PROGRAM_ID := p_line_rec.PROGRAM_ID ;
  x_line_rec25.PROGRAM_UPDATE_DATE := p_line_rec.PROGRAM_UPDATE_DATE ;
  x_line_rec25.PROJECT_ID := p_line_rec.PROJECT_ID ;
  x_line_rec25.PROMISE_DATE := p_line_rec.PROMISE_DATE ;
  x_line_rec25.RE_SOURCE_FLAG := p_line_rec.RE_SOURCE_FLAG ;
  x_line_rec25.REFERENCE_CUSTOMER_TRX_LINE_ID := p_line_rec.REFERENCE_CUSTOMER_TRX_LINE_ID ;
  x_line_rec25.REFERENCE_HEADER_ID := p_line_rec.REFERENCE_HEADER_ID ;
  x_line_rec25.REFERENCE_LINE_ID := p_line_rec.REFERENCE_LINE_ID ;
  x_line_rec25.REFERENCE_TYPE := p_line_rec.REFERENCE_TYPE ;
  x_line_rec25.REQUEST_DATE := p_line_rec.REQUEST_DATE ;
  x_line_rec25.REQUEST_ID := p_line_rec.REQUEST_ID ;
  x_line_rec25.RESERVED_QUANTITY := p_line_rec.RESERVED_QUANTITY ;
  x_line_rec25.RETURN_ATTRIBUTE1 := p_line_rec.RETURN_ATTRIBUTE1 ;
  x_line_rec25.RETURN_ATTRIBUTE10 := p_line_rec.RETURN_ATTRIBUTE10 ;
  x_line_rec25.RETURN_ATTRIBUTE11 := p_line_rec.RETURN_ATTRIBUTE11 ;
  x_line_rec25.RETURN_ATTRIBUTE12 := p_line_rec.RETURN_ATTRIBUTE12 ;
  x_line_rec25.RETURN_ATTRIBUTE13 := p_line_rec.RETURN_ATTRIBUTE13 ;
  x_line_rec25.RETURN_ATTRIBUTE14 := p_line_rec.RETURN_ATTRIBUTE14 ;
  x_line_rec25.RETURN_ATTRIBUTE15 := p_line_rec.RETURN_ATTRIBUTE15 ;
  x_line_rec25.RETURN_ATTRIBUTE2 := p_line_rec.RETURN_ATTRIBUTE2 ;
  x_line_rec25.RETURN_ATTRIBUTE3 := p_line_rec.RETURN_ATTRIBUTE3 ;
  x_line_rec25.RETURN_ATTRIBUTE4 := p_line_rec.RETURN_ATTRIBUTE4 ;
  x_line_rec25.RETURN_ATTRIBUTE5 := p_line_rec.RETURN_ATTRIBUTE5 ;
  x_line_rec25.RETURN_ATTRIBUTE6 := p_line_rec.RETURN_ATTRIBUTE6 ;
  x_line_rec25.RETURN_ATTRIBUTE7 := p_line_rec.RETURN_ATTRIBUTE7 ;
  x_line_rec25.RETURN_ATTRIBUTE8 := p_line_rec.RETURN_ATTRIBUTE8 ;
  x_line_rec25.RETURN_ATTRIBUTE9 := p_line_rec.RETURN_ATTRIBUTE9 ;
  x_line_rec25.RETURN_CONTEXT := p_line_rec.RETURN_CONTEXT ;
  x_line_rec25.RETURN_REASON_CODE := p_line_rec.RETURN_REASON_CODE ;
  x_line_rec25.RLA_SCHEDULE_TYPE_CODE := p_line_rec.RLA_SCHEDULE_TYPE_CODE ;
  x_line_rec25.SALESREP_ID := p_line_rec.SALESREP_ID ;
  x_line_rec25.SCHEDULE_ARRIVAL_DATE := p_line_rec.SCHEDULE_ARRIVAL_DATE ;
  x_line_rec25.SCHEDULE_SHIP_DATE := p_line_rec.SCHEDULE_SHIP_DATE ;
  x_line_rec25.SCHEDULE_ACTION_CODE := p_line_rec.SCHEDULE_ACTION_CODE ;
  x_line_rec25.SCHEDULE_STATUS_CODE := p_line_rec.SCHEDULE_STATUS_CODE ;
  x_line_rec25.SHIPMENT_NUMBER := p_line_rec.SHIPMENT_NUMBER ;
  x_line_rec25.SHIPMENT_PRIORITY_CODE := p_line_rec.SHIPMENT_PRIORITY_CODE ;
  x_line_rec25.SHIPPED_QUANTITY := p_line_rec.SHIPPED_QUANTITY ;
  x_line_rec25.SHIPPED_QUANTITY2 := p_line_rec.SHIPPED_QUANTITY2 ;
  x_line_rec25.SHIPPING_INTERFACED_FLAG := p_line_rec.SHIPPING_INTERFACED_FLAG ;
  x_line_rec25.SHIPPING_METHOD_CODE := p_line_rec.SHIPPING_METHOD_CODE ;
  x_line_rec25.SHIPPING_QUANTITY := p_line_rec.SHIPPING_QUANTITY ;
  x_line_rec25.SHIPPING_QUANTITY2 := p_line_rec.SHIPPING_QUANTITY2 ;
  x_line_rec25.SHIPPING_QUANTITY_UOM := p_line_rec.SHIPPING_QUANTITY_UOM ;
  x_line_rec25.SHIPPING_QUANTITY_UOM2 := p_line_rec.SHIPPING_QUANTITY_UOM2 ;
  x_line_rec25.SHIP_FROM_ORG_ID := p_line_rec.SHIP_FROM_ORG_ID ;
  x_line_rec25.SHIP_MODEL_COMPLETE_FLAG := p_line_rec.SHIP_MODEL_COMPLETE_FLAG ;
  x_line_rec25.SHIP_SET_ID := p_line_rec.SHIP_SET_ID ;
  x_line_rec25.FULFILLMENT_SET_ID := p_line_rec.FULFILLMENT_SET_ID ;
  x_line_rec25.SHIP_TOLERANCE_ABOVE := p_line_rec.SHIP_TOLERANCE_ABOVE ;
  x_line_rec25.SHIP_TOLERANCE_BELOW := p_line_rec.SHIP_TOLERANCE_BELOW ;
  x_line_rec25.SHIP_TO_CONTACT_ID := p_line_rec.SHIP_TO_CONTACT_ID ;
  x_line_rec25.SHIP_TO_ORG_ID := p_line_rec.SHIP_TO_ORG_ID ;
  x_line_rec25.SOLD_TO_ORG_ID := p_line_rec.SOLD_TO_ORG_ID ;
  x_line_rec25.SOLD_FROM_ORG_ID := p_line_rec.SOLD_FROM_ORG_ID ;
  x_line_rec25.SORT_ORDER := p_line_rec.SORT_ORDER ;
  x_line_rec25.SOURCE_DOCUMENT_ID := p_line_rec.SOURCE_DOCUMENT_ID ;
  x_line_rec25.SOURCE_DOCUMENT_LINE_ID := p_line_rec.SOURCE_DOCUMENT_LINE_ID ;
  x_line_rec25.SOURCE_DOCUMENT_TYPE_ID := p_line_rec.SOURCE_DOCUMENT_TYPE_ID ;
  x_line_rec25.SOURCE_TYPE_CODE := p_line_rec.SOURCE_TYPE_CODE ;
  x_line_rec25.SPLIT_FROM_LINE_ID := p_line_rec.SPLIT_FROM_LINE_ID ;
  x_line_rec25.TASK_ID := p_line_rec.TASK_ID ;
  x_line_rec25.TAX_CODE := p_line_rec.TAX_CODE ;
  x_line_rec25.TAX_DATE := p_line_rec.TAX_DATE ;
  x_line_rec25.TAX_EXEMPT_FLAG := p_line_rec.TAX_EXEMPT_FLAG ;
  x_line_rec25.TAX_EXEMPT_NUMBER := p_line_rec.TAX_EXEMPT_NUMBER ;
  x_line_rec25.TAX_EXEMPT_REASON_CODE := p_line_rec.TAX_EXEMPT_REASON_CODE ;
  x_line_rec25.TAX_POINT_CODE := p_line_rec.TAX_POINT_CODE ;
  x_line_rec25.TAX_RATE := p_line_rec.TAX_RATE ;
  -- x_line_rec25.TAX_VALUE := p_line_rec.TAX_VALUE ; -- Bug 9151484
  x_line_rec25.TOP_MODEL_LINE_REF := p_line_rec.TOP_MODEL_LINE_REF ;
  x_line_rec25.TOP_MODEL_LINE_ID := p_line_rec.TOP_MODEL_LINE_ID ;
  x_line_rec25.TOP_MODEL_LINE_INDEX := p_line_rec.TOP_MODEL_LINE_INDEX ;
  x_line_rec25.UNIT_LIST_PRICE := p_line_rec.UNIT_LIST_PRICE ;
  x_line_rec25.UNIT_LIST_PRICE_PER_PQTY := p_line_rec.UNIT_LIST_PRICE_PER_PQTY ;
  x_line_rec25.UNIT_SELLING_PRICE := p_line_rec.UNIT_SELLING_PRICE ;
  x_line_rec25.UNIT_SELLING_PRICE_PER_PQTY := p_line_rec.UNIT_SELLING_PRICE_PER_PQTY ;
  x_line_rec25.VEH_CUS_ITEM_CUM_KEY_ID := p_line_rec.VEH_CUS_ITEM_CUM_KEY_ID ;
  x_line_rec25.VISIBLE_DEMAND_FLAG := p_line_rec.VISIBLE_DEMAND_FLAG ;
  x_line_rec25.RETURN_STATUS := p_line_rec.RETURN_STATUS ;
  x_line_rec25.DB_FLAG := p_line_rec.DB_FLAG ;
  x_line_rec25.OPERATION := p_line_rec.OPERATION ;
  x_line_rec25.FIRST_ACK_CODE := p_line_rec.FIRST_ACK_CODE ;
  x_line_rec25.FIRST_ACK_DATE := p_line_rec.FIRST_ACK_DATE ;
  x_line_rec25.LAST_ACK_CODE := p_line_rec.LAST_ACK_CODE ;
  x_line_rec25.LAST_ACK_DATE := p_line_rec.LAST_ACK_DATE ;
  x_line_rec25.CHANGE_REASON := p_line_rec.CHANGE_REASON ;
  x_line_rec25.CHANGE_COMMENTS := p_line_rec.CHANGE_COMMENTS ;
  x_line_rec25.ARRIVAL_SET := p_line_rec.ARRIVAL_SET ;
  x_line_rec25.SHIP_SET := p_line_rec.SHIP_SET ;
  x_line_rec25.FULFILLMENT_SET := p_line_rec.FULFILLMENT_SET ;
  x_line_rec25.ORDER_SOURCE_ID := p_line_rec.ORDER_SOURCE_ID ;
  x_line_rec25.ORIG_SYS_SHIPMENT_REF := p_line_rec.ORIG_SYS_SHIPMENT_REF ;
  x_line_rec25.CHANGE_SEQUENCE := p_line_rec.CHANGE_SEQUENCE ;
  x_line_rec25.CHANGE_REQUEST_CODE := p_line_rec.CHANGE_REQUEST_CODE ;
  x_line_rec25.STATUS_FLAG := p_line_rec.STATUS_FLAG ;
  x_line_rec25.DROP_SHIP_FLAG := p_line_rec.DROP_SHIP_FLAG ;
  x_line_rec25.CUSTOMER_LINE_NUMBER := p_line_rec.CUSTOMER_LINE_NUMBER ;
  x_line_rec25.CUSTOMER_SHIPMENT_NUMBER := p_line_rec.CUSTOMER_SHIPMENT_NUMBER ;
  x_line_rec25.CUSTOMER_ITEM_NET_PRICE := p_line_rec.CUSTOMER_ITEM_NET_PRICE ;
  x_line_rec25.CUSTOMER_PAYMENT_TERM_ID := p_line_rec.CUSTOMER_PAYMENT_TERM_ID ;
  x_line_rec25.ORDERED_ITEM_ID := p_line_rec.ORDERED_ITEM_ID ;
  x_line_rec25.ITEM_IDENTIFIER_TYPE := p_line_rec.ITEM_IDENTIFIER_TYPE ;
  x_line_rec25.SHIPPING_INSTRUCTIONS := p_line_rec.SHIPPING_INSTRUCTIONS ;
  x_line_rec25.PACKING_INSTRUCTIONS := p_line_rec.PACKING_INSTRUCTIONS ;
  x_line_rec25.CALCULATE_PRICE_FLAG := p_line_rec.CALCULATE_PRICE_FLAG ;
  x_line_rec25.INVOICED_QUANTITY := p_line_rec.INVOICED_QUANTITY ;
  x_line_rec25.SERVICE_TXN_REASON_CODE := p_line_rec.SERVICE_TXN_REASON_CODE ;
  x_line_rec25.SERVICE_TXN_COMMENTS := p_line_rec.SERVICE_TXN_COMMENTS ;
  x_line_rec25.SERVICE_DURATION := p_line_rec.SERVICE_DURATION ;
  x_line_rec25.SERVICE_PERIOD := p_line_rec.SERVICE_PERIOD ;
  x_line_rec25.SERVICE_START_DATE := p_line_rec.SERVICE_START_DATE ;
  x_line_rec25.SERVICE_END_DATE := p_line_rec.SERVICE_END_DATE ;
  x_line_rec25.SERVICE_COTERMINATE_FLAG := p_line_rec.SERVICE_COTERMINATE_FLAG ;
  x_line_rec25.UNIT_LIST_PERCENT := p_line_rec.UNIT_LIST_PERCENT ;
  x_line_rec25.UNIT_SELLING_PERCENT := p_line_rec.UNIT_SELLING_PERCENT ;
  x_line_rec25.UNIT_PERCENT_BASE_PRICE := p_line_rec.UNIT_PERCENT_BASE_PRICE ;
  x_line_rec25.SERVICE_NUMBER := p_line_rec.SERVICE_NUMBER ;
  x_line_rec25.SERVICE_REFERENCE_TYPE_CODE := p_line_rec.SERVICE_REFERENCE_TYPE_CODE ;
  x_line_rec25.SERVICE_REFERENCE_LINE_ID := p_line_rec.SERVICE_REFERENCE_LINE_ID ;
  x_line_rec25.SERVICE_REFERENCE_SYSTEM_ID := p_line_rec.SERVICE_REFERENCE_SYSTEM_ID ;
  x_line_rec25.SERVICE_REF_ORDER_NUMBER := p_line_rec.SERVICE_REF_ORDER_NUMBER ;
  x_line_rec25.SERVICE_REF_LINE_NUMBER := p_line_rec.SERVICE_REF_LINE_NUMBER ;
  x_line_rec25.SERVICE_REFERENCE_ORDER := p_line_rec.SERVICE_REFERENCE_ORDER ;
  x_line_rec25.SERVICE_REFERENCE_LINE := p_line_rec.SERVICE_REFERENCE_LINE ;
  x_line_rec25.SERVICE_REFERENCE_SYSTEM := p_line_rec.SERVICE_REFERENCE_SYSTEM ;
  x_line_rec25.SERVICE_REF_SHIPMENT_NUMBER := p_line_rec.SERVICE_REF_SHIPMENT_NUMBER ;
  x_line_rec25.SERVICE_REF_OPTION_NUMBER := p_line_rec.SERVICE_REF_OPTION_NUMBER ;
  x_line_rec25.SERVICE_LINE_INDEX := p_line_rec.SERVICE_LINE_INDEX ;
  x_line_rec25.LINE_SET_ID := p_line_rec.LINE_SET_ID ;
  x_line_rec25.SPLIT_BY := p_line_rec.SPLIT_BY ;
  x_line_rec25.SPLIT_ACTION_CODE := p_line_rec.SPLIT_ACTION_CODE ;
  x_line_rec25.SHIPPABLE_FLAG := p_line_rec.SHIPPABLE_FLAG ;
  x_line_rec25.MODEL_REMNANT_FLAG := p_line_rec.MODEL_REMNANT_FLAG ;
  x_line_rec25.FLOW_STATUS_CODE := p_line_rec.FLOW_STATUS_CODE ;
  x_line_rec25.FULFILLED_FLAG := p_line_rec.FULFILLED_FLAG ;
  x_line_rec25.FULFILLMENT_METHOD_CODE := p_line_rec.FULFILLMENT_METHOD_CODE ;
  x_line_rec25.REVENUE_AMOUNT := p_line_rec.REVENUE_AMOUNT ;
  x_line_rec25.MARKETING_SOURCE_CODE_ID := p_line_rec.MARKETING_SOURCE_CODE_ID ;
  x_line_rec25.FULFILLMENT_DATE := p_line_rec.FULFILLMENT_DATE ;
  x_line_rec25.SEMI_PROCESSED_FLAG := p_line_rec.SEMI_PROCESSED_FLAG ;
  x_line_rec25.UPGRADED_FLAG := p_line_rec.UPGRADED_FLAG ;
  x_line_rec25.LOCK_CONTROL := p_line_rec.LOCK_CONTROL ;
  x_line_rec25.SUBINVENTORY := p_line_rec.SUBINVENTORY ;
  x_line_rec25.SPLIT_FROM_LINE_REF := p_line_rec.SPLIT_FROM_LINE_REF ;
  x_line_rec25.SPLIT_FROM_SHIPMENT_REF := p_line_rec.SPLIT_FROM_SHIPMENT_REF ;
  x_line_rec25.SHIP_TO_EDI_LOCATION_CODE := p_line_rec.SHIP_TO_EDI_LOCATION_CODE ;
  x_line_rec25.BILL_TO_EDI_LOCATION_CODE := p_line_rec.BILL_TO_EDI_LOCATION_CODE ;
  x_line_rec25.SHIP_FROM_EDI_LOCATION_CODE := p_line_rec.SHIP_FROM_EDI_LOCATION_CODE ;
  x_line_rec25.SHIP_FROM_ADDRESS_ID := p_line_rec.SHIP_FROM_ADDRESS_ID ;
  x_line_rec25.SOLD_TO_ADDRESS_ID := p_line_rec.SOLD_TO_ADDRESS_ID ;
  x_line_rec25.SHIP_TO_ADDRESS_ID := p_line_rec.SHIP_TO_ADDRESS_ID ;
  x_line_rec25.INVOICE_ADDRESS_ID := p_line_rec.INVOICE_ADDRESS_ID ;
  x_line_rec25.SHIP_TO_ADDRESS_CODE := p_line_rec.SHIP_TO_ADDRESS_CODE ;
  x_line_rec25.ORIGINAL_INVENTORY_ITEM_ID := p_line_rec.ORIGINAL_INVENTORY_ITEM_ID ;
  x_line_rec25.ORIGINAL_ITEM_IDENTIFIER_TYPE := p_line_rec.ORIGINAL_ITEM_IDENTIFIER_TYPE ;
  x_line_rec25.ORIGINAL_ORDERED_ITEM_ID := p_line_rec.ORIGINAL_ORDERED_ITEM_ID ;
  x_line_rec25.ORIGINAL_ORDERED_ITEM := p_line_rec.ORIGINAL_ORDERED_ITEM ;
  x_line_rec25.ITEM_SUBSTITUTION_TYPE_CODE := p_line_rec.ITEM_SUBSTITUTION_TYPE_CODE ;
  x_line_rec25.LATE_DEMAND_PENALTY_FACTOR := p_line_rec.LATE_DEMAND_PENALTY_FACTOR ;
  x_line_rec25.OVERRIDE_ATP_DATE_CODE := p_line_rec.OVERRIDE_ATP_DATE_CODE ;
  x_line_rec25.SHIP_TO_CUSTOMER_ID := p_line_rec.SHIP_TO_CUSTOMER_ID ;
  x_line_rec25.INVOICE_TO_CUSTOMER_ID := p_line_rec.INVOICE_TO_CUSTOMER_ID ;
  x_line_rec25.DELIVER_TO_CUSTOMER_ID := p_line_rec.DELIVER_TO_CUSTOMER_ID ;
  x_line_rec25.ACCOUNTING_RULE_DURATION := p_line_rec.ACCOUNTING_RULE_DURATION ;
  x_line_rec25.UNIT_COST := p_line_rec.UNIT_COST ;
  x_line_rec25.USER_ITEM_DESCRIPTION := p_line_rec.USER_ITEM_DESCRIPTION ;
  x_line_rec25.XML_TRANSACTION_TYPE_CODE := p_line_rec.XML_TRANSACTION_TYPE_CODE ;
  x_line_rec25.ITEM_RELATIONSHIP_TYPE := p_line_rec.ITEM_RELATIONSHIP_TYPE ;
  x_line_rec25.BLANKET_NUMBER := p_line_rec.BLANKET_NUMBER ;
  x_line_rec25.BLANKET_LINE_NUMBER := p_line_rec.BLANKET_LINE_NUMBER ;
  x_line_rec25.BLANKET_VERSION_NUMBER := p_line_rec.BLANKET_VERSION_NUMBER ;
  x_line_rec25.CSO_RESPONSE_FLAG := p_line_rec.CSO_RESPONSE_FLAG ;
  x_line_rec25.FIRM_DEMAND_FLAG := p_line_rec.FIRM_DEMAND_FLAG ;
  x_line_rec25.EARLIEST_SHIP_DATE := p_line_rec.EARLIEST_SHIP_DATE ;
  x_line_rec25.TRANSACTION_PHASE_CODE := p_line_rec.TRANSACTION_PHASE_CODE ;
  x_line_rec25.SOURCE_DOCUMENT_VERSION_NUMBER := p_line_rec.SOURCE_DOCUMENT_VERSION_NUMBER ;
  x_line_rec25.MINISITE_ID := p_line_rec.MINISITE_ID ;
  x_line_rec25.IB_OWNER := p_line_rec.IB_OWNER ;
  x_line_rec25.IB_INSTALLED_AT_LOCATION := p_line_rec.IB_INSTALLED_AT_LOCATION ;
  x_line_rec25.IB_CURRENT_LOCATION := p_line_rec.IB_CURRENT_LOCATION ;
  x_line_rec25.END_CUSTOMER_ID := p_line_rec.END_CUSTOMER_ID ;
  x_line_rec25.END_CUSTOMER_CONTACT_ID := p_line_rec.END_CUSTOMER_CONTACT_ID ;
  x_line_rec25.END_CUSTOMER_SITE_USE_ID := p_line_rec.END_CUSTOMER_SITE_USE_ID ;
  x_line_rec25.SUPPLIER_SIGNATURE := p_line_rec.SUPPLIER_SIGNATURE ;
  x_line_rec25.SUPPLIER_SIGNATURE_DATE := p_line_rec.SUPPLIER_SIGNATURE_DATE ;
  x_line_rec25.CUSTOMER_SIGNATURE := p_line_rec.CUSTOMER_SIGNATURE ;
  x_line_rec25.CUSTOMER_SIGNATURE_DATE := p_line_rec.CUSTOMER_SIGNATURE_DATE ;
  x_line_rec25.SHIP_TO_PARTY_ID := p_line_rec.SHIP_TO_PARTY_ID ;
  x_line_rec25.SHIP_TO_PARTY_SITE_ID := p_line_rec.SHIP_TO_PARTY_SITE_ID ;
  x_line_rec25.SHIP_TO_PARTY_SITE_USE_ID := p_line_rec.SHIP_TO_PARTY_SITE_USE_ID ;
  x_line_rec25.DELIVER_TO_PARTY_ID := p_line_rec.DELIVER_TO_PARTY_ID ;
  x_line_rec25.DELIVER_TO_PARTY_SITE_ID := p_line_rec.DELIVER_TO_PARTY_SITE_ID ;
  x_line_rec25.DELIVER_TO_PARTY_SITE_USE_ID := p_line_rec.DELIVER_TO_PARTY_SITE_USE_ID ;
  x_line_rec25.INVOICE_TO_PARTY_ID := p_line_rec.INVOICE_TO_PARTY_ID ;
  x_line_rec25.INVOICE_TO_PARTY_SITE_ID := p_line_rec.INVOICE_TO_PARTY_SITE_ID ;
  x_line_rec25.INVOICE_TO_PARTY_SITE_USE_ID := p_line_rec.INVOICE_TO_PARTY_SITE_USE_ID ;
  x_line_rec25.END_CUSTOMER_PARTY_ID := p_line_rec.END_CUSTOMER_PARTY_ID ;
  x_line_rec25.END_CUSTOMER_PARTY_SITE_ID := p_line_rec.END_CUSTOMER_PARTY_SITE_ID ;
  x_line_rec25.END_CUSTOMER_PARTY_SITE_USE_ID := p_line_rec.END_CUSTOMER_PARTY_SITE_USE_ID ;
  x_line_rec25.END_CUSTOMER_PARTY_NUMBER := p_line_rec.END_CUSTOMER_PARTY_NUMBER ;
  x_line_rec25.END_CUSTOMER_ORG_CONTACT_ID := p_line_rec.END_CUSTOMER_ORG_CONTACT_ID ;
  x_line_rec25.SHIP_TO_CUSTOMER_PARTY_ID := p_line_rec.SHIP_TO_CUSTOMER_PARTY_ID ;
  x_line_rec25.DELIVER_TO_CUSTOMER_PARTY_ID := p_line_rec.DELIVER_TO_CUSTOMER_PARTY_ID ;
  x_line_rec25.INVOICE_TO_CUSTOMER_PARTY_ID := p_line_rec.INVOICE_TO_CUSTOMER_PARTY_ID ;
  x_line_rec25.SHIP_TO_ORG_CONTACT_ID := p_line_rec.SHIP_TO_ORG_CONTACT_ID ;
  x_line_rec25.DELIVER_TO_ORG_CONTACT_ID := p_line_rec.DELIVER_TO_ORG_CONTACT_ID ;
  x_line_rec25.INVOICE_TO_ORG_CONTACT_ID := p_line_rec.INVOICE_TO_ORG_CONTACT_ID ;
  x_line_rec25.RETROBILL_REQUEST_ID := p_line_rec.RETROBILL_REQUEST_ID ;
  x_line_rec25.ORIGINAL_LIST_PRICE := p_line_rec.ORIGINAL_LIST_PRICE ;
  x_line_rec25.COMMITMENT_APPLIED_AMOUNT := p_line_rec.COMMITMENT_APPLIED_AMOUNT ;
  x_line_rec25.SHIP_TO_PARTY_NUMBER := p_line_rec.SHIP_TO_PARTY_NUMBER ;
  x_line_rec25.INVOICE_TO_PARTY_NUMBER := p_line_rec.INVOICE_TO_PARTY_NUMBER ;
  x_line_rec25.DELIVER_TO_PARTY_NUMBER := p_line_rec.DELIVER_TO_PARTY_NUMBER ;
  x_line_rec25.ORDER_FIRMED_DATE := p_line_rec.ORDER_FIRMED_DATE ;
  x_line_rec25.ACTUAL_FULFILLMENT_DATE := p_line_rec.ACTUAL_FULFILLMENT_DATE ;
  x_line_rec25.CHANGED_LINES_POCAO := p_line_rec.CHANGED_LINES_POCAO ;
  x_line_rec25.CHARGE_PERIODICITY_CODE := p_line_rec.CHARGE_PERIODICITY_CODE ;

  x_line_rec25.freight_charge :=  NULL;
END line_rec_to_line_rec25;


PROCEDURE line_tab_to_line_tab25(
    p_line_tab    IN          oe_order_pub_line_tbl_type,
    x_line_tab25  OUT NOCOPY  oe_order_pub_line_tab25
)
IS
  l_line_rec    oe_order_pub_line_rec_type;
  l_line_rec25  oe_order_pub_line_rec25;

  l_count NUMBER;
BEGIN

  --  Guard this whole assignment within an anonymous pl/sql block so that
  --  "Reference to Uninitialized Collection." error can be ignored.
  BEGIN
    l_count :=  p_line_tab.Count;

    IF l_count > 0 THEN
      x_line_tab25 := oe_order_pub_line_tab25();

      FOR i IN 1..l_count
      LOOP
        l_line_rec    :=  p_line_tab(i);
        line_rec_to_line_rec25(l_line_rec, l_line_rec25);

        x_line_tab25.extend;
        x_line_tab25(i) :=  l_line_rec25;
      END LOOP;
    END IF;
  EXCEPTION
    WHEN Others THEN
      NULL;
  END;

END line_tab_to_line_tab25;

PROCEDURE hdr_ack_rec_to_hdr_ack_rec25(
    p_hdr_ack_rec   IN            oe_acknowledgment_pub_header_,
    x_hdr_ack_rec25 OUT NOCOPY    oe_ack_pub_hdr_rec25
)
IS
BEGIN
    x_hdr_ack_rec25 :=  oe_ack_pub_hdr_rec25 (
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL );

    x_hdr_ack_rec25.IB_OWNER_CODE := p_hdr_ack_rec.IB_OWNER_CODE ;
    x_hdr_ack_rec25.IB_CURRENT_LOCATION_CODE := p_hdr_ack_rec.IB_CURRENT_LOCATION_CODE ;
    x_hdr_ack_rec25.IB_INSTALLED_AT_LOCATION_CODE := p_hdr_ack_rec.IB_INSTALLED_AT_LOCATION_CODE ;
    x_hdr_ack_rec25.INVOICE_CUSTOMER_ID := p_hdr_ack_rec.INVOICE_CUSTOMER_ID ;
    x_hdr_ack_rec25.DELIVER_TO_CUSTOMER_ID := p_hdr_ack_rec.DELIVER_TO_CUSTOMER_ID ;
    x_hdr_ack_rec25.ACCOUNTING_RULE_DURATION := p_hdr_ack_rec.ACCOUNTING_RULE_DURATION ;
    x_hdr_ack_rec25.ATTRIBUTE16 := p_hdr_ack_rec.ATTRIBUTE16 ;
    x_hdr_ack_rec25.ATTRIBUTE17 := p_hdr_ack_rec.ATTRIBUTE17 ;
    x_hdr_ack_rec25.ATTRIBUTE18 := p_hdr_ack_rec.ATTRIBUTE18 ;
    x_hdr_ack_rec25.ATTRIBUTE19 := p_hdr_ack_rec.ATTRIBUTE19 ;
    x_hdr_ack_rec25.ATTRIBUTE20 := p_hdr_ack_rec.ATTRIBUTE20 ;
    x_hdr_ack_rec25.ACKNOWLEDGMENT_TYPE := p_hdr_ack_rec.ACKNOWLEDGMENT_TYPE ;
    x_hdr_ack_rec25.BLANKET_NUMBER := p_hdr_ack_rec.BLANKET_NUMBER ;
    x_hdr_ack_rec25.BOOKED_DATE := p_hdr_ack_rec.BOOKED_DATE ;
    x_hdr_ack_rec25.FLOW_STATUS_CODE := p_hdr_ack_rec.FLOW_STATUS_CODE ;
    x_hdr_ack_rec25.CREDIT_CARD_APPROVAL_DATE := p_hdr_ack_rec.CREDIT_CARD_APPROVAL_DATE ;
    x_hdr_ack_rec25.PAYMENT_TYPE_CODE := p_hdr_ack_rec.PAYMENT_TYPE_CODE ;
    x_hdr_ack_rec25.PAYMENT_AMOUNT := p_hdr_ack_rec.PAYMENT_AMOUNT ;
    x_hdr_ack_rec25.CHECK_NUMBER := p_hdr_ack_rec.CHECK_NUMBER ;
    x_hdr_ack_rec25.CREDIT_CARD_CODE := p_hdr_ack_rec.CREDIT_CARD_CODE ;
    x_hdr_ack_rec25.CREDIT_CARD_HOLDER_NAME := p_hdr_ack_rec.CREDIT_CARD_HOLDER_NAME ;
    x_hdr_ack_rec25.CREDIT_CARD_NUMBER := p_hdr_ack_rec.CREDIT_CARD_NUMBER ;
    x_hdr_ack_rec25.CREDIT_CARD_EXPIRATION_DATE := p_hdr_ack_rec.CREDIT_CARD_EXPIRATION_DATE ;
    x_hdr_ack_rec25.CREDIT_CARD_APPROVAL_CODE := p_hdr_ack_rec.CREDIT_CARD_APPROVAL_CODE ;
    x_hdr_ack_rec25.CUSTOMER_PREFERENCE_SET_CODE := p_hdr_ack_rec.CUSTOMER_PREFERENCE_SET_CODE ;
    x_hdr_ack_rec25.SALES_CHANNEL_CODE := p_hdr_ack_rec.SALES_CHANNEL_CODE ;
    x_hdr_ack_rec25.SOLD_TO_PHONE_ID := p_hdr_ack_rec.SOLD_TO_PHONE_ID ;
    x_hdr_ack_rec25.SHIP_TO_PROVINCE := p_hdr_ack_rec.SHIP_TO_PROVINCE ;
    x_hdr_ack_rec25.SHIP_TO_SITE_INT := p_hdr_ack_rec.SHIP_TO_SITE_INT ;
    x_hdr_ack_rec25.SHIP_TO_STATE := p_hdr_ack_rec.SHIP_TO_STATE ;
    x_hdr_ack_rec25.SHIP_TOLERANCE_ABOVE := p_hdr_ack_rec.SHIP_TOLERANCE_ABOVE ;
    x_hdr_ack_rec25.SHIP_TOLERANCE_BELOW := p_hdr_ack_rec.SHIP_TOLERANCE_BELOW ;
    x_hdr_ack_rec25.SHIPMENT_PRIORITY := p_hdr_ack_rec.SHIPMENT_PRIORITY ;
    x_hdr_ack_rec25.SHIPMENT_PRIORITY_CODE := p_hdr_ack_rec.SHIPMENT_PRIORITY_CODE ;
    x_hdr_ack_rec25.SHIPMENT_PRIORITY_CODE_INT := p_hdr_ack_rec.SHIPMENT_PRIORITY_CODE_INT ;
    x_hdr_ack_rec25.SHIPPING_INSTRUCTIONS := p_hdr_ack_rec.SHIPPING_INSTRUCTIONS ;
    x_hdr_ack_rec25.SHIPPING_METHOD := p_hdr_ack_rec.SHIPPING_METHOD ;
    x_hdr_ack_rec25.SHIPPING_METHOD_CODE := p_hdr_ack_rec.SHIPPING_METHOD_CODE ;
    x_hdr_ack_rec25.SOLD_TO_CONTACT := p_hdr_ack_rec.SOLD_TO_CONTACT ;
    x_hdr_ack_rec25.SOLD_TO_CONTACT_ID := p_hdr_ack_rec.SOLD_TO_CONTACT_ID ;
    x_hdr_ack_rec25.SOURCE_DOCUMENT_ID := p_hdr_ack_rec.SOURCE_DOCUMENT_ID ;
    x_hdr_ack_rec25.SOURCE_DOCUMENT_TYPE_ID := p_hdr_ack_rec.SOURCE_DOCUMENT_TYPE_ID ;
    x_hdr_ack_rec25.SUBMISSION_DATETIME := p_hdr_ack_rec.SUBMISSION_DATETIME ;
    x_hdr_ack_rec25.TAX_EXEMPT_FLAG := p_hdr_ack_rec.TAX_EXEMPT_FLAG ;
    x_hdr_ack_rec25.TAX_EXEMPT_NUMBER := p_hdr_ack_rec.TAX_EXEMPT_NUMBER ;
    x_hdr_ack_rec25.TAX_EXEMPT_REASON := p_hdr_ack_rec.TAX_EXEMPT_REASON ;
    x_hdr_ack_rec25.TAX_EXEMPT_REASON_CODE := p_hdr_ack_rec.TAX_EXEMPT_REASON_CODE ;
    x_hdr_ack_rec25.TAX_POINT := p_hdr_ack_rec.TAX_POINT ;
    x_hdr_ack_rec25.TAX_POINT_CODE := p_hdr_ack_rec.TAX_POINT_CODE ;
    x_hdr_ack_rec25.TRANSACTIONAL_CURR := p_hdr_ack_rec.TRANSACTIONAL_CURR ;
    x_hdr_ack_rec25.TRANSACTIONAL_CURR_CODE := p_hdr_ack_rec.TRANSACTIONAL_CURR_CODE ;
    x_hdr_ack_rec25.VERSION_NUMBER := p_hdr_ack_rec.VERSION_NUMBER ;
    x_hdr_ack_rec25.CUSTOMER_PAYMENT_TERM_ID := p_hdr_ack_rec.CUSTOMER_PAYMENT_TERM_ID ;
    x_hdr_ack_rec25.DROP_SHIP_FLAG := p_hdr_ack_rec.DROP_SHIP_FLAG ;
    x_hdr_ack_rec25.ORDER_CATEGORY_CODE := p_hdr_ack_rec.ORDER_CATEGORY_CODE ;
    x_hdr_ack_rec25.SOLD_TO_ADDRESS1 := p_hdr_ack_rec.SOLD_TO_ADDRESS1 ;
    x_hdr_ack_rec25.SOLD_TO_ADDRESS2 := p_hdr_ack_rec.SOLD_TO_ADDRESS2 ;
    x_hdr_ack_rec25.SOLD_TO_ADDRESS3 := p_hdr_ack_rec.SOLD_TO_ADDRESS3 ;
    x_hdr_ack_rec25.SOLD_TO_ADDRESS4 := p_hdr_ack_rec.SOLD_TO_ADDRESS4 ;
    x_hdr_ack_rec25.SOLD_TO_CITY := p_hdr_ack_rec.SOLD_TO_CITY ;
    x_hdr_ack_rec25.SOLD_TO_POSTAL_CODE := p_hdr_ack_rec.SOLD_TO_POSTAL_CODE ;
    x_hdr_ack_rec25.SOLD_TO_COUNTRY := p_hdr_ack_rec.SOLD_TO_COUNTRY ;
    x_hdr_ack_rec25.SOLD_TO_STATE := p_hdr_ack_rec.SOLD_TO_STATE ;
    x_hdr_ack_rec25.SOLD_TO_COUNTY := p_hdr_ack_rec.SOLD_TO_COUNTY ;
    x_hdr_ack_rec25.SOLD_TO_PROVINCE := p_hdr_ack_rec.SOLD_TO_PROVINCE ;
    x_hdr_ack_rec25.SOLD_TO_CONTACT_LAST_NAME := p_hdr_ack_rec.SOLD_TO_CONTACT_LAST_NAME ;
    x_hdr_ack_rec25.SOLD_TO_CONTACT_FIRST_NAME := p_hdr_ack_rec.SOLD_TO_CONTACT_FIRST_NAME ;
    x_hdr_ack_rec25.SHIP_TO_EDI_LOCATION_CODE := p_hdr_ack_rec.SHIP_TO_EDI_LOCATION_CODE ;
    x_hdr_ack_rec25.SOLD_TO_EDI_LOCATION_CODE := p_hdr_ack_rec.SOLD_TO_EDI_LOCATION_CODE ;
    x_hdr_ack_rec25.BILL_TO_EDI_LOCATION_CODE := p_hdr_ack_rec.BILL_TO_EDI_LOCATION_CODE ;
    x_hdr_ack_rec25.CUSTOMER_PAYMENT_TERM := p_hdr_ack_rec.CUSTOMER_PAYMENT_TERM ;
    x_hdr_ack_rec25.SHIP_FROM_ADDRESS_1 := p_hdr_ack_rec.SHIP_FROM_ADDRESS_1 ;
    x_hdr_ack_rec25.SHIP_FROM_ADDRESS_2 := p_hdr_ack_rec.SHIP_FROM_ADDRESS_2 ;
    x_hdr_ack_rec25.SHIP_FROM_ADDRESS_3 := p_hdr_ack_rec.SHIP_FROM_ADDRESS_3 ;
    x_hdr_ack_rec25.SHIP_FROM_CITY := p_hdr_ack_rec.SHIP_FROM_CITY ;
    x_hdr_ack_rec25.SHIP_FROM_POSTAL_CODE := p_hdr_ack_rec.SHIP_FROM_POSTAL_CODE ;
    x_hdr_ack_rec25.SHIP_FROM_COUNTRY := p_hdr_ack_rec.SHIP_FROM_COUNTRY ;
    x_hdr_ack_rec25.SHIP_FROM_EDI_LOCATION_CODE := p_hdr_ack_rec.SHIP_FROM_EDI_LOCATION_CODE ;
    x_hdr_ack_rec25.SHIP_FROM_REGION1 := p_hdr_ack_rec.SHIP_FROM_REGION1 ;
    x_hdr_ack_rec25.SHIP_FROM_REGION2 := p_hdr_ack_rec.SHIP_FROM_REGION2 ;
    x_hdr_ack_rec25.SHIP_FROM_REGION3 := p_hdr_ack_rec.SHIP_FROM_REGION3 ;
    x_hdr_ack_rec25.SHIP_FROM_ADDRESS_ID := p_hdr_ack_rec.SHIP_FROM_ADDRESS_ID ;
    x_hdr_ack_rec25.SOLD_TO_ADDRESS_ID := p_hdr_ack_rec.SOLD_TO_ADDRESS_ID ;
    x_hdr_ack_rec25.SHIP_TO_ADDRESS_ID := p_hdr_ack_rec.SHIP_TO_ADDRESS_ID ;
    x_hdr_ack_rec25.INVOICE_ADDRESS_ID := p_hdr_ack_rec.INVOICE_ADDRESS_ID ;
    x_hdr_ack_rec25.SHIP_TO_ADDRESS_CODE := p_hdr_ack_rec.SHIP_TO_ADDRESS_CODE ;
    x_hdr_ack_rec25.TP_CONTEXT := p_hdr_ack_rec.TP_CONTEXT ;
    x_hdr_ack_rec25.TP_ATTRIBUTE1 := p_hdr_ack_rec.TP_ATTRIBUTE1 ;
    x_hdr_ack_rec25.TP_ATTRIBUTE2 := p_hdr_ack_rec.TP_ATTRIBUTE2 ;
    x_hdr_ack_rec25.TP_ATTRIBUTE3 := p_hdr_ack_rec.TP_ATTRIBUTE3 ;
    x_hdr_ack_rec25.TP_ATTRIBUTE4 := p_hdr_ack_rec.TP_ATTRIBUTE4 ;
    x_hdr_ack_rec25.TP_ATTRIBUTE5 := p_hdr_ack_rec.TP_ATTRIBUTE5 ;
    x_hdr_ack_rec25.TP_ATTRIBUTE6 := p_hdr_ack_rec.TP_ATTRIBUTE6 ;
    x_hdr_ack_rec25.TP_ATTRIBUTE7 := p_hdr_ack_rec.TP_ATTRIBUTE7 ;
    x_hdr_ack_rec25.TP_ATTRIBUTE8 := p_hdr_ack_rec.TP_ATTRIBUTE8 ;
    x_hdr_ack_rec25.TP_ATTRIBUTE9 := p_hdr_ack_rec.TP_ATTRIBUTE9 ;
    x_hdr_ack_rec25.TP_ATTRIBUTE10 := p_hdr_ack_rec.TP_ATTRIBUTE10 ;
    x_hdr_ack_rec25.TP_ATTRIBUTE11 := p_hdr_ack_rec.TP_ATTRIBUTE11 ;
    x_hdr_ack_rec25.TP_ATTRIBUTE12 := p_hdr_ack_rec.TP_ATTRIBUTE12 ;
    x_hdr_ack_rec25.TP_ATTRIBUTE13 := p_hdr_ack_rec.TP_ATTRIBUTE13 ;
    x_hdr_ack_rec25.TP_ATTRIBUTE14 := p_hdr_ack_rec.TP_ATTRIBUTE14 ;
    x_hdr_ack_rec25.TP_ATTRIBUTE15 := p_hdr_ack_rec.TP_ATTRIBUTE15 ;
    x_hdr_ack_rec25.XML_MESSAGE_ID := p_hdr_ack_rec.XML_MESSAGE_ID ;
    x_hdr_ack_rec25.SHIP_TO_CUSTOMER_ID := p_hdr_ack_rec.SHIP_TO_CUSTOMER_ID ;
    x_hdr_ack_rec25.ORDER_FIRMED_DATE := p_hdr_ack_rec.ORDER_FIRMED_DATE ;
    x_hdr_ack_rec25.DELIVER_TO_ADDRESS1 := p_hdr_ack_rec.DELIVER_TO_ADDRESS1 ;
    x_hdr_ack_rec25.DELIVER_TO_ADDRESS2 := p_hdr_ack_rec.DELIVER_TO_ADDRESS2 ;
    x_hdr_ack_rec25.DELIVER_TO_ADDRESS3 := p_hdr_ack_rec.DELIVER_TO_ADDRESS3 ;
    x_hdr_ack_rec25.DELIVER_TO_ADDRESS4 := p_hdr_ack_rec.DELIVER_TO_ADDRESS4 ;
    x_hdr_ack_rec25.DELIVER_TO_CITY := p_hdr_ack_rec.DELIVER_TO_CITY ;
    x_hdr_ack_rec25.DELIVER_TO_COUNTRY := p_hdr_ack_rec.DELIVER_TO_COUNTRY ;
    x_hdr_ack_rec25.DELIVER_TO_COUNTY := p_hdr_ack_rec.DELIVER_TO_COUNTY ;
    x_hdr_ack_rec25.DELIVER_TO_POSTAL_CODE := p_hdr_ack_rec.DELIVER_TO_POSTAL_CODE ;
    x_hdr_ack_rec25.DELIVER_TO_PROVINCE := p_hdr_ack_rec.DELIVER_TO_PROVINCE ;
    x_hdr_ack_rec25.TRANSACTION_PHASE_CODE := p_hdr_ack_rec.TRANSACTION_PHASE_CODE ;
    x_hdr_ack_rec25.SALES_DOCUMENT_NAME := p_hdr_ack_rec.SALES_DOCUMENT_NAME ;
    x_hdr_ack_rec25.QUOTE_NUMBER := p_hdr_ack_rec.QUOTE_NUMBER ;
    x_hdr_ack_rec25.QUOTE_DATE := p_hdr_ack_rec.QUOTE_DATE ;
    x_hdr_ack_rec25.USER_STATUS_CODE := p_hdr_ack_rec.USER_STATUS_CODE ;
    x_hdr_ack_rec25.SOLD_TO_SITE_USE_ID := p_hdr_ack_rec.SOLD_TO_SITE_USE_ID ;
    x_hdr_ack_rec25.SUPPLIER_SIGNATURE := p_hdr_ack_rec.SUPPLIER_SIGNATURE ;
    x_hdr_ack_rec25.SUPPLIER_SIGNATURE_DATE := p_hdr_ack_rec.SUPPLIER_SIGNATURE_DATE ;
    x_hdr_ack_rec25.CUSTOMER_SIGNATURE := p_hdr_ack_rec.CUSTOMER_SIGNATURE ;
    x_hdr_ack_rec25.CUSTOMER_SIGNATURE_DATE := p_hdr_ack_rec.CUSTOMER_SIGNATURE_DATE ;
    x_hdr_ack_rec25.SOLD_TO_PARTY_NUMBER := p_hdr_ack_rec.SOLD_TO_PARTY_NUMBER ;
    x_hdr_ack_rec25.SHIP_TO_PARTY_NUMBER := p_hdr_ack_rec.SHIP_TO_PARTY_NUMBER ;
    x_hdr_ack_rec25.INVOICE_TO_PARTY_NUMBER := p_hdr_ack_rec.INVOICE_TO_PARTY_NUMBER ;
    x_hdr_ack_rec25.DELIVER_TO_PARTY_NUMBER := p_hdr_ack_rec.DELIVER_TO_PARTY_NUMBER ;
    x_hdr_ack_rec25.END_CUSTOMER_NUMBER := p_hdr_ack_rec.END_CUSTOMER_NUMBER ;
    x_hdr_ack_rec25.END_CUSTOMER_PARTY_NUMBER := p_hdr_ack_rec.END_CUSTOMER_PARTY_NUMBER ;
    x_hdr_ack_rec25.END_CUSTOMER_ID := p_hdr_ack_rec.END_CUSTOMER_ID ;
    x_hdr_ack_rec25.END_CUSTOMER_CONTACT_ID := p_hdr_ack_rec.END_CUSTOMER_CONTACT_ID ;
    x_hdr_ack_rec25.END_CUSTOMER_SITE_USE_ID := p_hdr_ack_rec.END_CUSTOMER_SITE_USE_ID ;
    x_hdr_ack_rec25.END_CUSTOMER_ADDRESS1 := p_hdr_ack_rec.END_CUSTOMER_ADDRESS1 ;
    x_hdr_ack_rec25.END_CUSTOMER_ADDRESS2 := p_hdr_ack_rec.END_CUSTOMER_ADDRESS2 ;
    x_hdr_ack_rec25.END_CUSTOMER_ADDRESS3 := p_hdr_ack_rec.END_CUSTOMER_ADDRESS3 ;
    x_hdr_ack_rec25.END_CUSTOMER_ADDRESS4 := p_hdr_ack_rec.END_CUSTOMER_ADDRESS4 ;
    x_hdr_ack_rec25.END_CUSTOMER_CITY := p_hdr_ack_rec.END_CUSTOMER_CITY ;
    x_hdr_ack_rec25.END_CUSTOMER_POSTAL_CODE := p_hdr_ack_rec.END_CUSTOMER_POSTAL_CODE ;
    x_hdr_ack_rec25.END_CUSTOMER_COUNTRY := p_hdr_ack_rec.END_CUSTOMER_COUNTRY ;
    x_hdr_ack_rec25.END_CUSTOMER_STATE := p_hdr_ack_rec.END_CUSTOMER_STATE ;
    x_hdr_ack_rec25.END_CUSTOMER_COUNTY := p_hdr_ack_rec.END_CUSTOMER_COUNTY ;
    x_hdr_ack_rec25.END_CUSTOMER_PROVINCE := p_hdr_ack_rec.END_CUSTOMER_PROVINCE ;
    x_hdr_ack_rec25.END_CUSTOMER_CONTACT := p_hdr_ack_rec.END_CUSTOMER_CONTACT ;
    x_hdr_ack_rec25.END_CUSTOMER_CONTACT_LAST_NAME := p_hdr_ack_rec.END_CUSTOMER_CONTACT_LAST_NAME ;
    x_hdr_ack_rec25.END_CUSTOMER_CONTACT_FIRST_NAM := p_hdr_ack_rec.END_CUSTOMER_CONTACT_FIRST_NAM ;
    x_hdr_ack_rec25.END_CUSTOMER_NAME := p_hdr_ack_rec.END_CUSTOMER_NAME ;
    x_hdr_ack_rec25.IB_OWNER := p_hdr_ack_rec.IB_OWNER ;
    x_hdr_ack_rec25.IB_CURRENT_LOCATION := p_hdr_ack_rec.IB_CURRENT_LOCATION ;
    x_hdr_ack_rec25.IB_INSTALLED_AT_LOCATION := p_hdr_ack_rec.IB_INSTALLED_AT_LOCATION ;
    x_hdr_ack_rec25.SOLD_TO_LOCATION_ADDRESS1 := p_hdr_ack_rec.SOLD_TO_LOCATION_ADDRESS1 ;
    x_hdr_ack_rec25.SOLD_TO_LOCATION_ADDRESS2 := p_hdr_ack_rec.SOLD_TO_LOCATION_ADDRESS2 ;
    x_hdr_ack_rec25.SOLD_TO_LOCATION_ADDRESS3 := p_hdr_ack_rec.SOLD_TO_LOCATION_ADDRESS3 ;
    x_hdr_ack_rec25.SOLD_TO_LOCATION_ADDRESS4 := p_hdr_ack_rec.SOLD_TO_LOCATION_ADDRESS4 ;
    x_hdr_ack_rec25.SOLD_TO_LOCATION_CITY := p_hdr_ack_rec.SOLD_TO_LOCATION_CITY ;
    x_hdr_ack_rec25.SOLD_TO_LOCATION_POSTAL_CODE := p_hdr_ack_rec.SOLD_TO_LOCATION_POSTAL_CODE ;
    x_hdr_ack_rec25.SOLD_TO_LOCATION_COUNTRY := p_hdr_ack_rec.SOLD_TO_LOCATION_COUNTRY ;
    x_hdr_ack_rec25.GLOBAL_ATTRIBUTE12 := p_hdr_ack_rec.GLOBAL_ATTRIBUTE12 ;
    x_hdr_ack_rec25.GLOBAL_ATTRIBUTE13 := p_hdr_ack_rec.GLOBAL_ATTRIBUTE13 ;
    x_hdr_ack_rec25.GLOBAL_ATTRIBUTE14 := p_hdr_ack_rec.GLOBAL_ATTRIBUTE14 ;
    x_hdr_ack_rec25.GLOBAL_ATTRIBUTE15 := p_hdr_ack_rec.GLOBAL_ATTRIBUTE15 ;
    x_hdr_ack_rec25.GLOBAL_ATTRIBUTE16 := p_hdr_ack_rec.GLOBAL_ATTRIBUTE16 ;
    x_hdr_ack_rec25.GLOBAL_ATTRIBUTE17 := p_hdr_ack_rec.GLOBAL_ATTRIBUTE17 ;
    x_hdr_ack_rec25.GLOBAL_ATTRIBUTE18 := p_hdr_ack_rec.GLOBAL_ATTRIBUTE18 ;
    x_hdr_ack_rec25.GLOBAL_ATTRIBUTE19 := p_hdr_ack_rec.GLOBAL_ATTRIBUTE19 ;
    x_hdr_ack_rec25.GLOBAL_ATTRIBUTE20 := p_hdr_ack_rec.GLOBAL_ATTRIBUTE20 ;
    x_hdr_ack_rec25.HEADER_PO_CONTEXT := p_hdr_ack_rec.HEADER_PO_CONTEXT ;
    x_hdr_ack_rec25.INTERFACE_STATUS := p_hdr_ack_rec.INTERFACE_STATUS ;
    x_hdr_ack_rec25.INVOICE_ADDRESS_1 := p_hdr_ack_rec.INVOICE_ADDRESS_1 ;
    x_hdr_ack_rec25.INVOICE_ADDRESS_2 := p_hdr_ack_rec.INVOICE_ADDRESS_2 ;
    x_hdr_ack_rec25.INVOICE_ADDRESS_3 := p_hdr_ack_rec.INVOICE_ADDRESS_3 ;
    x_hdr_ack_rec25.INVOICE_ADDRESS_4 := p_hdr_ack_rec.INVOICE_ADDRESS_4 ;
    x_hdr_ack_rec25.INVOICE_CITY := p_hdr_ack_rec.INVOICE_CITY ;
    x_hdr_ack_rec25.INVOICE_COUNTRY := p_hdr_ack_rec.INVOICE_COUNTRY ;
    x_hdr_ack_rec25.INVOICE_COUNTY := p_hdr_ack_rec.INVOICE_COUNTY ;
    x_hdr_ack_rec25.INVOICE_CUSTOMER := p_hdr_ack_rec.INVOICE_CUSTOMER ;
    x_hdr_ack_rec25.INVOICE_CUSTOMER_NUMBER := p_hdr_ack_rec.INVOICE_CUSTOMER_NUMBER ;
    x_hdr_ack_rec25.INVOICE_POSTAL_CODE := p_hdr_ack_rec.INVOICE_POSTAL_CODE ;
    x_hdr_ack_rec25.INVOICE_PROVINCE_INT := p_hdr_ack_rec.INVOICE_PROVINCE_INT ;
    x_hdr_ack_rec25.INVOICE_SITE := p_hdr_ack_rec.INVOICE_SITE ;
    x_hdr_ack_rec25.INVOICE_SITE_CODE := p_hdr_ack_rec.INVOICE_SITE_CODE ;
    x_hdr_ack_rec25.INVOICE_STATE := p_hdr_ack_rec.INVOICE_STATE ;
    x_hdr_ack_rec25.INVOICE_TO_CONTACT := p_hdr_ack_rec.INVOICE_TO_CONTACT ;
    x_hdr_ack_rec25.INVOICE_TO_CONTACT_FIRST_NAME := p_hdr_ack_rec.INVOICE_TO_CONTACT_FIRST_NAME ;
    x_hdr_ack_rec25.INVOICE_TO_CONTACT_ID := p_hdr_ack_rec.INVOICE_TO_CONTACT_ID ;
    x_hdr_ack_rec25.INVOICE_TO_CONTACT_LAST_NAME := p_hdr_ack_rec.INVOICE_TO_CONTACT_LAST_NAME ;
    x_hdr_ack_rec25.INVOICE_TO_ORG := p_hdr_ack_rec.INVOICE_TO_ORG ;
    x_hdr_ack_rec25.INVOICE_TO_ORG_ID := p_hdr_ack_rec.INVOICE_TO_ORG_ID ;
    x_hdr_ack_rec25.INVOICE_TOLERANCE_ABOVE := p_hdr_ack_rec.INVOICE_TOLERANCE_ABOVE ;
    x_hdr_ack_rec25.INVOICE_TOLERANCE_BELOW := p_hdr_ack_rec.INVOICE_TOLERANCE_BELOW ;
    x_hdr_ack_rec25.INVOICING_RULE := p_hdr_ack_rec.INVOICING_RULE ;
    x_hdr_ack_rec25.INVOICING_RULE_ID := p_hdr_ack_rec.INVOICING_RULE_ID ;
    x_hdr_ack_rec25.OPEN_FLAG := p_hdr_ack_rec.OPEN_FLAG ;
    x_hdr_ack_rec25.OPERATION_CODE := p_hdr_ack_rec.OPERATION_CODE ;
    x_hdr_ack_rec25.ORDER_DATE_TYPE_CODE := p_hdr_ack_rec.ORDER_DATE_TYPE_CODE ;
    x_hdr_ack_rec25.ORDER_SOURCE := p_hdr_ack_rec.ORDER_SOURCE ;
    x_hdr_ack_rec25.ORDER_SOURCE_ID := p_hdr_ack_rec.ORDER_SOURCE_ID ;
    x_hdr_ack_rec25.ORDER_TYPE := p_hdr_ack_rec.ORDER_TYPE ;
    x_hdr_ack_rec25.ORDER_TYPE_ID := p_hdr_ack_rec.ORDER_TYPE_ID ;
    x_hdr_ack_rec25.ORDERED_BY_CONTACT_FIRST_NAME := p_hdr_ack_rec.ORDERED_BY_CONTACT_FIRST_NAME ;
    x_hdr_ack_rec25.ORDERED_BY_CONTACT_LAST_NAME := p_hdr_ack_rec.ORDERED_BY_CONTACT_LAST_NAME ;
    x_hdr_ack_rec25.PACKING_INSTRUCTIONS := p_hdr_ack_rec.PACKING_INSTRUCTIONS ;
    x_hdr_ack_rec25.PARTIAL_SHIPMENTS_ALLOWED := p_hdr_ack_rec.PARTIAL_SHIPMENTS_ALLOWED ;
    x_hdr_ack_rec25.PAYMENT_TERM_ID := p_hdr_ack_rec.PAYMENT_TERM_ID ;
    x_hdr_ack_rec25.PAYMENT_TERM := p_hdr_ack_rec.PAYMENT_TERM ;
    x_hdr_ack_rec25.PO_ATTRIBUTE_1 := p_hdr_ack_rec.PO_ATTRIBUTE_1 ;
    x_hdr_ack_rec25.PO_ATTRIBUTE_2 := p_hdr_ack_rec.PO_ATTRIBUTE_2 ;
    x_hdr_ack_rec25.PO_ATTRIBUTE_3 := p_hdr_ack_rec.PO_ATTRIBUTE_3 ;
    x_hdr_ack_rec25.PO_ATTRIBUTE_4 := p_hdr_ack_rec.PO_ATTRIBUTE_4 ;
    x_hdr_ack_rec25.PO_ATTRIBUTE_5 := p_hdr_ack_rec.PO_ATTRIBUTE_5 ;
    x_hdr_ack_rec25.PO_ATTRIBUTE_6 := p_hdr_ack_rec.PO_ATTRIBUTE_6 ;
    x_hdr_ack_rec25.PO_ATTRIBUTE_7 := p_hdr_ack_rec.PO_ATTRIBUTE_7 ;
    x_hdr_ack_rec25.PO_ATTRIBUTE_8 := p_hdr_ack_rec.PO_ATTRIBUTE_8 ;
    x_hdr_ack_rec25.PO_ATTRIBUTE_9 := p_hdr_ack_rec.PO_ATTRIBUTE_9 ;
    x_hdr_ack_rec25.PO_ATTRIBUTE_10 := p_hdr_ack_rec.PO_ATTRIBUTE_10 ;
    x_hdr_ack_rec25.PO_ATTRIBUTE_11 := p_hdr_ack_rec.PO_ATTRIBUTE_11 ;
    x_hdr_ack_rec25.PO_ATTRIBUTE_12 := p_hdr_ack_rec.PO_ATTRIBUTE_12 ;
    x_hdr_ack_rec25.PO_ATTRIBUTE_13 := p_hdr_ack_rec.PO_ATTRIBUTE_13 ;
    x_hdr_ack_rec25.PO_ATTRIBUTE_14 := p_hdr_ack_rec.PO_ATTRIBUTE_14 ;
    x_hdr_ack_rec25.PO_ATTRIBUTE_15 := p_hdr_ack_rec.PO_ATTRIBUTE_15 ;
    x_hdr_ack_rec25.PO_REVISION_DATE := p_hdr_ack_rec.PO_REVISION_DATE ;
    x_hdr_ack_rec25.PROGRAM := p_hdr_ack_rec.PROGRAM ;
    x_hdr_ack_rec25.PROGRAM_APPLICATION := p_hdr_ack_rec.PROGRAM_APPLICATION ;
    x_hdr_ack_rec25.PROGRAM_APPLICATION_ID := p_hdr_ack_rec.PROGRAM_APPLICATION_ID ;
    x_hdr_ack_rec25.PROGRAM_ID := p_hdr_ack_rec.PROGRAM_ID ;
    x_hdr_ack_rec25.PROGRAM_UPDATE_DATE := p_hdr_ack_rec.PROGRAM_UPDATE_DATE ;
    x_hdr_ack_rec25.RELATED_PO_NUMBER := p_hdr_ack_rec.RELATED_PO_NUMBER ;
    x_hdr_ack_rec25.REMAINDER_ORDERS_ALLOWED := p_hdr_ack_rec.REMAINDER_ORDERS_ALLOWED ;
    x_hdr_ack_rec25.REQUEST_DATE := p_hdr_ack_rec.REQUEST_DATE ;
    x_hdr_ack_rec25.REQUEST_ID := p_hdr_ack_rec.REQUEST_ID ;
    x_hdr_ack_rec25.RETURN_REASON_CODE := p_hdr_ack_rec.RETURN_REASON_CODE ;
    x_hdr_ack_rec25.SALESREP_ID := p_hdr_ack_rec.SALESREP_ID ;
    x_hdr_ack_rec25.SALESREP := p_hdr_ack_rec.SALESREP ;
    x_hdr_ack_rec25.SHIP_TO_ADDRESS_1 := p_hdr_ack_rec.SHIP_TO_ADDRESS_1 ;
    x_hdr_ack_rec25.SHIP_TO_ADDRESS_2 := p_hdr_ack_rec.SHIP_TO_ADDRESS_2 ;
    x_hdr_ack_rec25.SHIP_TO_ADDRESS_3 := p_hdr_ack_rec.SHIP_TO_ADDRESS_3 ;
    x_hdr_ack_rec25.SHIP_TO_ADDRESS_4 := p_hdr_ack_rec.SHIP_TO_ADDRESS_4 ;
    x_hdr_ack_rec25.SHIP_TO_CITY := p_hdr_ack_rec.SHIP_TO_CITY ;
    x_hdr_ack_rec25.SHIP_TO_CONTACT := p_hdr_ack_rec.SHIP_TO_CONTACT ;
    x_hdr_ack_rec25.SHIP_TO_CONTACT_FIRST_NAME := p_hdr_ack_rec.SHIP_TO_CONTACT_FIRST_NAME ;
    x_hdr_ack_rec25.SHIP_TO_CONTACT_ID := p_hdr_ack_rec.SHIP_TO_CONTACT_ID ;
    x_hdr_ack_rec25.SHIP_TO_CONTACT_LAST_NAME := p_hdr_ack_rec.SHIP_TO_CONTACT_LAST_NAME ;
    x_hdr_ack_rec25.SHIP_TO_COUNTRY := p_hdr_ack_rec.SHIP_TO_COUNTRY ;
    x_hdr_ack_rec25.SHIP_TO_COUNTY := p_hdr_ack_rec.SHIP_TO_COUNTY ;
    x_hdr_ack_rec25.SHIP_TO_CUSTOMER := p_hdr_ack_rec.SHIP_TO_CUSTOMER ;
    x_hdr_ack_rec25.SHIP_TO_CUSTOMER_NUMBER := p_hdr_ack_rec.SHIP_TO_CUSTOMER_NUMBER ;
    x_hdr_ack_rec25.SHIP_TO_POSTAL_CODE := p_hdr_ack_rec.SHIP_TO_POSTAL_CODE ;
    x_hdr_ack_rec25.FIRST_ACK_CODE := p_hdr_ack_rec.FIRST_ACK_CODE ;
    x_hdr_ack_rec25.LAST_ACK_CODE := p_hdr_ack_rec.LAST_ACK_CODE ;
    x_hdr_ack_rec25.FIRST_ACK_DATE := p_hdr_ack_rec.FIRST_ACK_DATE ;
    x_hdr_ack_rec25.LAST_ACK_DATE := p_hdr_ack_rec.LAST_ACK_DATE ;
    x_hdr_ack_rec25.BUYER_SELLER_FLAG := p_hdr_ack_rec.BUYER_SELLER_FLAG ;
    x_hdr_ack_rec25.CREATED_BY := p_hdr_ack_rec.CREATED_BY ;
    x_hdr_ack_rec25.CREATION_DATE := p_hdr_ack_rec.CREATION_DATE ;
    x_hdr_ack_rec25.LAST_UPDATE_DATE := p_hdr_ack_rec.LAST_UPDATE_DATE ;
    x_hdr_ack_rec25.LAST_UPDATE_LOGIN := p_hdr_ack_rec.LAST_UPDATE_LOGIN ;
    x_hdr_ack_rec25.LAST_UPDATED_BY := p_hdr_ack_rec.LAST_UPDATED_BY ;
    x_hdr_ack_rec25.BOOKED_FLAG := p_hdr_ack_rec.BOOKED_FLAG ;
    x_hdr_ack_rec25.AGREEMENT_ID := p_hdr_ack_rec.AGREEMENT_ID ;
    x_hdr_ack_rec25.AGREEMENT := p_hdr_ack_rec.AGREEMENT ;
    x_hdr_ack_rec25.AGREEMENT_NAME := p_hdr_ack_rec.AGREEMENT_NAME ;
    x_hdr_ack_rec25.CONTEXT := p_hdr_ack_rec.CONTEXT ;
    x_hdr_ack_rec25.PRICE_LIST := p_hdr_ack_rec.PRICE_LIST ;
    x_hdr_ack_rec25.PRICE_LIST_ID := p_hdr_ack_rec.PRICE_LIST_ID ;
    x_hdr_ack_rec25.PRICING_DATE := p_hdr_ack_rec.PRICING_DATE ;
    x_hdr_ack_rec25.SHIP_FROM_ORG_ID := p_hdr_ack_rec.SHIP_FROM_ORG_ID ;
    x_hdr_ack_rec25.SHIP_FROM_ORG := p_hdr_ack_rec.SHIP_FROM_ORG ;
    x_hdr_ack_rec25.SHIP_TO_ORG_ID := p_hdr_ack_rec.SHIP_TO_ORG_ID ;
    x_hdr_ack_rec25.SHIP_TO_ORG := p_hdr_ack_rec.SHIP_TO_ORG ;
    x_hdr_ack_rec25.SOLD_FROM_ORG := p_hdr_ack_rec.SOLD_FROM_ORG ;
    x_hdr_ack_rec25.SOLD_FROM_ORG_ID := p_hdr_ack_rec.SOLD_FROM_ORG_ID ;
    x_hdr_ack_rec25.SOLD_TO_ORG := p_hdr_ack_rec.SOLD_TO_ORG ;
    x_hdr_ack_rec25.SOLD_TO_ORG_ID := p_hdr_ack_rec.SOLD_TO_ORG_ID ;
    x_hdr_ack_rec25.ATTRIBUTE1 := p_hdr_ack_rec.ATTRIBUTE1 ;
    x_hdr_ack_rec25.ATTRIBUTE2 := p_hdr_ack_rec.ATTRIBUTE2 ;
    x_hdr_ack_rec25.ATTRIBUTE3 := p_hdr_ack_rec.ATTRIBUTE3 ;
    x_hdr_ack_rec25.ATTRIBUTE4 := p_hdr_ack_rec.ATTRIBUTE4 ;
    x_hdr_ack_rec25.ATTRIBUTE5 := p_hdr_ack_rec.ATTRIBUTE5 ;
    x_hdr_ack_rec25.ATTRIBUTE6 := p_hdr_ack_rec.ATTRIBUTE6 ;
    x_hdr_ack_rec25.ATTRIBUTE7 := p_hdr_ack_rec.ATTRIBUTE7 ;
    x_hdr_ack_rec25.ATTRIBUTE8 := p_hdr_ack_rec.ATTRIBUTE8 ;
    x_hdr_ack_rec25.ATTRIBUTE9 := p_hdr_ack_rec.ATTRIBUTE9 ;
    x_hdr_ack_rec25.ATTRIBUTE10 := p_hdr_ack_rec.ATTRIBUTE10 ;
    x_hdr_ack_rec25.ATTRIBUTE11 := p_hdr_ack_rec.ATTRIBUTE11 ;
    x_hdr_ack_rec25.ATTRIBUTE12 := p_hdr_ack_rec.ATTRIBUTE12 ;
    x_hdr_ack_rec25.ATTRIBUTE13 := p_hdr_ack_rec.ATTRIBUTE13 ;
    x_hdr_ack_rec25.ATTRIBUTE14 := p_hdr_ack_rec.ATTRIBUTE14 ;
    x_hdr_ack_rec25.ATTRIBUTE15 := p_hdr_ack_rec.ATTRIBUTE15 ;
    x_hdr_ack_rec25.CANCELLED_FLAG := p_hdr_ack_rec.CANCELLED_FLAG ;
    x_hdr_ack_rec25.CLOSED_FLAG := p_hdr_ack_rec.CLOSED_FLAG ;
    x_hdr_ack_rec25.CONVERSION_RATE := p_hdr_ack_rec.CONVERSION_RATE ;
    x_hdr_ack_rec25.CONVERSION_RATE_DATE := p_hdr_ack_rec.CONVERSION_RATE_DATE ;
    x_hdr_ack_rec25.CONVERSION_TYPE := p_hdr_ack_rec.CONVERSION_TYPE ;
    x_hdr_ack_rec25.CONVERSION_TYPE_CODE := p_hdr_ack_rec.CONVERSION_TYPE_CODE ;
    x_hdr_ack_rec25.CUST_PO_NUMBER := p_hdr_ack_rec.CUST_PO_NUMBER ;
    x_hdr_ack_rec25.CUSTOMER_ID := p_hdr_ack_rec.CUSTOMER_ID ;
    x_hdr_ack_rec25.CUSTOMER_NAME := p_hdr_ack_rec.CUSTOMER_NAME ;
    x_hdr_ack_rec25.CUSTOMER_NUMBER := p_hdr_ack_rec.CUSTOMER_NUMBER ;
    x_hdr_ack_rec25.DELIVER_TO_CONTACT := p_hdr_ack_rec.DELIVER_TO_CONTACT ;
    x_hdr_ack_rec25.DELIVER_TO_CONTACT_ID := p_hdr_ack_rec.DELIVER_TO_CONTACT_ID ;
    x_hdr_ack_rec25.DELIVER_TO_CUSTOMER := p_hdr_ack_rec.DELIVER_TO_CUSTOMER ;
    x_hdr_ack_rec25.DELIVER_TO_CUSTOMER_NUMBER := p_hdr_ack_rec.DELIVER_TO_CUSTOMER_NUMBER ;
    x_hdr_ack_rec25.DELIVER_TO_ORG := p_hdr_ack_rec.DELIVER_TO_ORG ;
    x_hdr_ack_rec25.DELIVER_TO_ORG_ID := p_hdr_ack_rec.DELIVER_TO_ORG_ID ;
    x_hdr_ack_rec25.DEMAND_CLASS := p_hdr_ack_rec.DEMAND_CLASS ;
    x_hdr_ack_rec25.DEMAND_CLASS_CODE := p_hdr_ack_rec.DEMAND_CLASS_CODE ;
    x_hdr_ack_rec25.EARLIEST_SCHEDULE_LIMIT := p_hdr_ack_rec.EARLIEST_SCHEDULE_LIMIT ;
    x_hdr_ack_rec25.LATEST_SCHEDULE_LIMIT := p_hdr_ack_rec.LATEST_SCHEDULE_LIMIT ;
    x_hdr_ack_rec25.ERROR_FLAG := p_hdr_ack_rec.ERROR_FLAG ;
    x_hdr_ack_rec25.EXPIRATION_DATE := p_hdr_ack_rec.EXPIRATION_DATE ;
    x_hdr_ack_rec25.FOB_POINT := p_hdr_ack_rec.FOB_POINT ;
    x_hdr_ack_rec25.FOB_POINT_CODE := p_hdr_ack_rec.FOB_POINT_CODE ;
    x_hdr_ack_rec25.FREIGHT_CARRIER_CODE := p_hdr_ack_rec.FREIGHT_CARRIER_CODE ;
    x_hdr_ack_rec25.FREIGHT_TERMS := p_hdr_ack_rec.FREIGHT_TERMS ;
    x_hdr_ack_rec25.FREIGHT_TERMS_CODE := p_hdr_ack_rec.FREIGHT_TERMS_CODE ;
    x_hdr_ack_rec25.GLOBAL_ATTRIBUTE_CATEGORY := p_hdr_ack_rec.GLOBAL_ATTRIBUTE_CATEGORY ;
    x_hdr_ack_rec25.GLOBAL_ATTRIBUTE1 := p_hdr_ack_rec.GLOBAL_ATTRIBUTE1 ;
    x_hdr_ack_rec25.GLOBAL_ATTRIBUTE2 := p_hdr_ack_rec.GLOBAL_ATTRIBUTE2 ;
    x_hdr_ack_rec25.GLOBAL_ATTRIBUTE3 := p_hdr_ack_rec.GLOBAL_ATTRIBUTE3 ;
    x_hdr_ack_rec25.GLOBAL_ATTRIBUTE4 := p_hdr_ack_rec.GLOBAL_ATTRIBUTE4 ;
    x_hdr_ack_rec25.GLOBAL_ATTRIBUTE5 := p_hdr_ack_rec.GLOBAL_ATTRIBUTE5 ;
    x_hdr_ack_rec25.GLOBAL_ATTRIBUTE6 := p_hdr_ack_rec.GLOBAL_ATTRIBUTE6 ;
    x_hdr_ack_rec25.GLOBAL_ATTRIBUTE7 := p_hdr_ack_rec.GLOBAL_ATTRIBUTE7 ;
    x_hdr_ack_rec25.GLOBAL_ATTRIBUTE8 := p_hdr_ack_rec.GLOBAL_ATTRIBUTE8 ;
    x_hdr_ack_rec25.GLOBAL_ATTRIBUTE9 := p_hdr_ack_rec.GLOBAL_ATTRIBUTE9 ;
    x_hdr_ack_rec25.GLOBAL_ATTRIBUTE10 := p_hdr_ack_rec.GLOBAL_ATTRIBUTE10 ;
    x_hdr_ack_rec25.GLOBAL_ATTRIBUTE11 := p_hdr_ack_rec.GLOBAL_ATTRIBUTE11 ;
    x_hdr_ack_rec25.DELIVER_TO_STATE := p_hdr_ack_rec.DELIVER_TO_STATE ;
    x_hdr_ack_rec25.SOLD_TO_LOCATION_STATE := p_hdr_ack_rec.SOLD_TO_LOCATION_STATE ;
    x_hdr_ack_rec25.SOLD_TO_LOCATION_COUNTY := p_hdr_ack_rec.SOLD_TO_LOCATION_COUNTY ;
    x_hdr_ack_rec25.SOLD_TO_LOCATION_PROVINCE := p_hdr_ack_rec.SOLD_TO_LOCATION_PROVINCE ;
    x_hdr_ack_rec25.HEADER_ID := p_hdr_ack_rec.HEADER_ID ;
    x_hdr_ack_rec25.ORIG_SYS_DOCUMENT_REF := p_hdr_ack_rec.ORIG_SYS_DOCUMENT_REF ;
    x_hdr_ack_rec25.ORDER_NUMBER := p_hdr_ack_rec.ORDER_NUMBER ;
    x_hdr_ack_rec25.ORDERED_DATE := p_hdr_ack_rec.ORDERED_DATE ;
    x_hdr_ack_rec25.ORG_ID := p_hdr_ack_rec.ORG_ID ;
    x_hdr_ack_rec25.CHANGE_DATE := p_hdr_ack_rec.CHANGE_DATE ;
    x_hdr_ack_rec25.CHANGE_SEQUENCE := p_hdr_ack_rec.CHANGE_SEQUENCE ;
    x_hdr_ack_rec25.ACCOUNTING_RULE_ID := p_hdr_ack_rec.ACCOUNTING_RULE_ID ;
    x_hdr_ack_rec25.ACCOUNTING_RULE := p_hdr_ack_rec.ACCOUNTING_RULE ;
    x_hdr_ack_rec25.ACKNOWLEDGMENT_FLAG := p_hdr_ack_rec.ACKNOWLEDGMENT_FLAG ;

    x_hdr_ack_rec25.freight_charge  :=  NULL;
    x_hdr_ack_rec25.tax_value       :=  NULL;
END;

PROCEDURE hdr_ack_tab_to_hdr_ack_tab25(
  p_hdr_ack_tab     IN            oe_sync_order_pvt_header_ack_,
  x_hdr_ack_tab25   OUT NOCOPY    oe_ack_pub_hdr_tab25
)
IS
  l_count NUMBER;

  l_hdr_ack_rec     oe_acknowledgment_pub_header_;
  l_hdr_ack_rec25   oe_ack_pub_hdr_rec25;
BEGIN
  --  Guard within an anonymous pl/sql block to avoid "Reference to Un-Initialized
  --  Collection" error.
  BEGIN
    l_count :=  p_hdr_ack_tab.Count;

    IF l_count > 0 THEN
      x_hdr_ack_tab25 := oe_ack_pub_hdr_tab25();
      FOR i IN 1..l_count
      LOOP
        l_hdr_ack_rec     :=  p_hdr_ack_tab(i);
        hdr_ack_rec_to_hdr_ack_rec25(l_hdr_ack_rec, l_hdr_ack_rec25);

        x_hdr_ack_tab25.extend;
        x_hdr_ack_tab25(i)  :=  l_hdr_ack_rec25;
      END LOOP;
    END IF;
  EXCEPTION
    WHEN Others THEN
      NULL;
  END;

END hdr_ack_tab_to_hdr_ack_tab25;


PROCEDURE line_ack_rec_to_line_ack_rec25(
    p_line_ack_rec    IN          oe_acknowledgment_pub_line_ac,
    x_line_ack_rec25  OUT NOCOPY  oe_ack_pub_line_rec25
)
IS
BEGIN
    x_line_ack_rec25  :=  oe_ack_pub_line_rec25(  NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL);

    x_line_ack_rec25.END_CUSTOMER_CONTACT_LAST_NAME := p_line_ack_rec.END_CUSTOMER_CONTACT_LAST_NAME ;
    x_line_ack_rec25.END_CUSTOMER_CONTACT_FIRST_NAM := p_line_ack_rec.END_CUSTOMER_CONTACT_FIRST_NAM ;
    x_line_ack_rec25.END_CUSTOMER_NAME := p_line_ack_rec.END_CUSTOMER_NAME ;
    x_line_ack_rec25.IB_OWNER := p_line_ack_rec.IB_OWNER ;
    x_line_ack_rec25.IB_CURRENT_LOCATION := p_line_ack_rec.IB_CURRENT_LOCATION ;
    x_line_ack_rec25.IB_INSTALLED_AT_LOCATION := p_line_ack_rec.IB_INSTALLED_AT_LOCATION ;
    x_line_ack_rec25.ORDER_FIRMED_DATE := p_line_ack_rec.ORDER_FIRMED_DATE ;
    x_line_ack_rec25.ACTUAL_FULFILLMENT_DATE := p_line_ack_rec.ACTUAL_FULFILLMENT_DATE ;
    x_line_ack_rec25.COMMITMENT := p_line_ack_rec.COMMITMENT ;
    x_line_ack_rec25.CUSTOMER_PAYMENT_TERM := p_line_ack_rec.CUSTOMER_PAYMENT_TERM ;
    x_line_ack_rec25.DELIVER_TO_ADDRESS1 := p_line_ack_rec.DELIVER_TO_ADDRESS1 ;
    x_line_ack_rec25.DELIVER_TO_ADDRESS2 := p_line_ack_rec.DELIVER_TO_ADDRESS2 ;
    x_line_ack_rec25.DELIVER_TO_ADDRESS3 := p_line_ack_rec.DELIVER_TO_ADDRESS3 ;
    x_line_ack_rec25.DELIVER_TO_ADDRESS4 := p_line_ack_rec.DELIVER_TO_ADDRESS4 ;
    x_line_ack_rec25.DELIVER_TO_CITY := p_line_ack_rec.DELIVER_TO_CITY ;
    x_line_ack_rec25.DELIVER_TO_COUNTRY := p_line_ack_rec.DELIVER_TO_COUNTRY ;
    x_line_ack_rec25.DELIVER_TO_COUNTY := p_line_ack_rec.DELIVER_TO_COUNTY ;
    x_line_ack_rec25.DELIVER_TO_POSTAL_CODE := p_line_ack_rec.DELIVER_TO_POSTAL_CODE ;
    x_line_ack_rec25.DELIVER_TO_PROVINCE := p_line_ack_rec.DELIVER_TO_PROVINCE ;
    x_line_ack_rec25.DELIVER_TO_STATE := p_line_ack_rec.DELIVER_TO_STATE ;
    x_line_ack_rec25.INVOICE_ADDRESS_1 := p_line_ack_rec.INVOICE_ADDRESS_1 ;
    x_line_ack_rec25.INVOICE_ADDRESS_2 := p_line_ack_rec.INVOICE_ADDRESS_2 ;
    x_line_ack_rec25.INVOICE_ADDRESS_3 := p_line_ack_rec.INVOICE_ADDRESS_3 ;
    x_line_ack_rec25.INVOICE_ADDRESS_4 := p_line_ack_rec.INVOICE_ADDRESS_4 ;
    x_line_ack_rec25.INVOICE_COUNTRY := p_line_ack_rec.INVOICE_COUNTRY ;
    x_line_ack_rec25.INVOICE_COUNTY := p_line_ack_rec.INVOICE_COUNTY ;
    x_line_ack_rec25.INVOICE_POSTAL_CODE := p_line_ack_rec.INVOICE_POSTAL_CODE ;
    x_line_ack_rec25.INVOICE_STATE := p_line_ack_rec.INVOICE_STATE ;
    x_line_ack_rec25.IB_OWNER_CODE := p_line_ack_rec.IB_OWNER_CODE ;
    x_line_ack_rec25.IB_CURRENT_LOCATION_CODE := p_line_ack_rec.IB_CURRENT_LOCATION_CODE ;
    x_line_ack_rec25.IB_INSTALLED_AT_LOCATION_CODE := p_line_ack_rec.IB_INSTALLED_AT_LOCATION_CODE ;
    x_line_ack_rec25.CONFIG_REV_NBR := p_line_ack_rec.CONFIG_REV_NBR ;
    x_line_ack_rec25.CONFIG_HEADER_ID := p_line_ack_rec.CONFIG_HEADER_ID ;
    x_line_ack_rec25.SHIP_FROM_ADDRESS_1 := p_line_ack_rec.SHIP_FROM_ADDRESS_1 ;
    x_line_ack_rec25.SHIP_FROM_ADDRESS_2 := p_line_ack_rec.SHIP_FROM_ADDRESS_2 ;
    x_line_ack_rec25.SHIP_FROM_ADDRESS_3 := p_line_ack_rec.SHIP_FROM_ADDRESS_3 ;
    x_line_ack_rec25.SHIP_FROM_CITY := p_line_ack_rec.SHIP_FROM_CITY ;
    x_line_ack_rec25.SHIP_FROM_POSTAL_CODE := p_line_ack_rec.SHIP_FROM_POSTAL_CODE ;
    x_line_ack_rec25.SHIP_FROM_COUNTRY := p_line_ack_rec.SHIP_FROM_COUNTRY ;
    x_line_ack_rec25.SHIP_FROM_EDI_LOCATION_CODE := p_line_ack_rec.SHIP_FROM_EDI_LOCATION_CODE ;
    x_line_ack_rec25.SHIP_FROM_REGION1 := p_line_ack_rec.SHIP_FROM_REGION1 ;
    x_line_ack_rec25.SHIP_FROM_REGION2 := p_line_ack_rec.SHIP_FROM_REGION2 ;
    x_line_ack_rec25.SHIP_FROM_REGION3 := p_line_ack_rec.SHIP_FROM_REGION3 ;
    x_line_ack_rec25.SHIP_FROM_ADDRESS_ID := p_line_ack_rec.SHIP_FROM_ADDRESS_ID ;
    x_line_ack_rec25.SHIP_TO_ADDRESS_CODE := p_line_ack_rec.SHIP_TO_ADDRESS_CODE ;
    x_line_ack_rec25.SHIP_TO_ADDRESS_NAME := p_line_ack_rec.SHIP_TO_ADDRESS_NAME ;
    x_line_ack_rec25.SHIP_TO_ADDRESS_ID := p_line_ack_rec.SHIP_TO_ADDRESS_ID ;
    x_line_ack_rec25.INVOICE_ADDRESS_CODE := p_line_ack_rec.INVOICE_ADDRESS_CODE ;
    x_line_ack_rec25.INVOICE_ADDRESS_NAME := p_line_ack_rec.INVOICE_ADDRESS_NAME ;
    x_line_ack_rec25.DELIVER_TO_CUSTOMER := p_line_ack_rec.DELIVER_TO_CUSTOMER ;
    x_line_ack_rec25.SERVICED_LINE_ID := p_line_ack_rec.SERVICED_LINE_ID ;
    x_line_ack_rec25.SERVICE_REFERENCE_ORDER := p_line_ack_rec.SERVICE_REFERENCE_ORDER ;
    x_line_ack_rec25.SERVICE_REFERENCE_LINE := p_line_ack_rec.SERVICE_REFERENCE_LINE ;
    x_line_ack_rec25.SERVICE_REFERENCE_SYSTEM := p_line_ack_rec.SERVICE_REFERENCE_SYSTEM ;
    x_line_ack_rec25.TP_CONTEXT := p_line_ack_rec.TP_CONTEXT ;
    x_line_ack_rec25.TP_ATTRIBUTE1 := p_line_ack_rec.TP_ATTRIBUTE1 ;
    x_line_ack_rec25.TP_ATTRIBUTE2 := p_line_ack_rec.TP_ATTRIBUTE2 ;
    x_line_ack_rec25.TP_ATTRIBUTE3 := p_line_ack_rec.TP_ATTRIBUTE3 ;
    x_line_ack_rec25.TP_ATTRIBUTE4 := p_line_ack_rec.TP_ATTRIBUTE4 ;
    x_line_ack_rec25.TP_ATTRIBUTE5 := p_line_ack_rec.TP_ATTRIBUTE5 ;
    x_line_ack_rec25.TP_ATTRIBUTE6 := p_line_ack_rec.TP_ATTRIBUTE6 ;
    x_line_ack_rec25.TP_ATTRIBUTE7 := p_line_ack_rec.TP_ATTRIBUTE7 ;
    x_line_ack_rec25.TP_ATTRIBUTE8 := p_line_ack_rec.TP_ATTRIBUTE8 ;
    x_line_ack_rec25.TP_ATTRIBUTE9 := p_line_ack_rec.TP_ATTRIBUTE9 ;
    x_line_ack_rec25.TP_ATTRIBUTE10 := p_line_ack_rec.TP_ATTRIBUTE10 ;
    x_line_ack_rec25.TP_ATTRIBUTE11 := p_line_ack_rec.TP_ATTRIBUTE11 ;
    x_line_ack_rec25.TP_ATTRIBUTE12 := p_line_ack_rec.TP_ATTRIBUTE12 ;
    x_line_ack_rec25.TP_ATTRIBUTE13 := p_line_ack_rec.TP_ATTRIBUTE13 ;
    x_line_ack_rec25.TP_ATTRIBUTE14 := p_line_ack_rec.TP_ATTRIBUTE14 ;
    x_line_ack_rec25.TP_ATTRIBUTE15 := p_line_ack_rec.TP_ATTRIBUTE15 ;
    x_line_ack_rec25.SPLIT_FROM_SHIPMENT_REF := p_line_ack_rec.SPLIT_FROM_SHIPMENT_REF ;
    x_line_ack_rec25.SHIP_TO_CUSTOMER_ID := p_line_ack_rec.SHIP_TO_CUSTOMER_ID ;
    x_line_ack_rec25.INVOICE_TO_CUSTOMER_ID := p_line_ack_rec.INVOICE_TO_CUSTOMER_ID ;
    x_line_ack_rec25.UNIT_SELLING_PRICE_PER_PQTY := p_line_ack_rec.UNIT_SELLING_PRICE_PER_PQTY ;
    x_line_ack_rec25.DELIVER_TO_CUSTOMER_ID := p_line_ack_rec.DELIVER_TO_CUSTOMER_ID ;
    x_line_ack_rec25.SHIP_TO_CUSTOMER_NAME := p_line_ack_rec.SHIP_TO_CUSTOMER_NAME ;
    x_line_ack_rec25.SHIP_TO_CUSTOMER_NUMBER := p_line_ack_rec.SHIP_TO_CUSTOMER_NUMBER ;
    x_line_ack_rec25.INVOICE_TO_CUSTOMER_NAME := p_line_ack_rec.INVOICE_TO_CUSTOMER_NAME ;
    x_line_ack_rec25.INVOICE_TO_CUSTOMER_NUMBER := p_line_ack_rec.INVOICE_TO_CUSTOMER_NUMBER ;
    x_line_ack_rec25.DELIVER_TO_CUSTOMER_NAME := p_line_ack_rec.DELIVER_TO_CUSTOMER_NAME ;
    x_line_ack_rec25.DELIVER_TO_CUSTOMER_NUMBER := p_line_ack_rec.DELIVER_TO_CUSTOMER_NUMBER ;
    x_line_ack_rec25.ACCOUNTING_RULE_DURATION := p_line_ack_rec.ACCOUNTING_RULE_DURATION ;
    x_line_ack_rec25.ATTRIBUTE16 := p_line_ack_rec.ATTRIBUTE16 ;
    x_line_ack_rec25.ATTRIBUTE17 := p_line_ack_rec.ATTRIBUTE17 ;
    x_line_ack_rec25.ATTRIBUTE18 := p_line_ack_rec.ATTRIBUTE18 ;
    x_line_ack_rec25.ATTRIBUTE19 := p_line_ack_rec.ATTRIBUTE19 ;
    x_line_ack_rec25.ATTRIBUTE20 := p_line_ack_rec.ATTRIBUTE20 ;
    x_line_ack_rec25.ACKNOWLEDGMENT_TYPE := p_line_ack_rec.ACKNOWLEDGMENT_TYPE ;
    x_line_ack_rec25.USER_ITEM_DESCRIPTION := p_line_ack_rec.USER_ITEM_DESCRIPTION ;
    x_line_ack_rec25.BLANKET_NUMBER := p_line_ack_rec.BLANKET_NUMBER ;
    x_line_ack_rec25.BLANKET_LINE_NUMBER := p_line_ack_rec.BLANKET_LINE_NUMBER ;
    x_line_ack_rec25.ORIGINAL_INVENTORY_ITEM_ID := p_line_ack_rec.ORIGINAL_INVENTORY_ITEM_ID ;
    x_line_ack_rec25.ORIGINAL_ORDERED_ITEM_ID := p_line_ack_rec.ORIGINAL_ORDERED_ITEM_ID ;
    x_line_ack_rec25.ORIGINAL_ORDERED_ITEM := p_line_ack_rec.ORIGINAL_ORDERED_ITEM ;
    x_line_ack_rec25.ORDERED_ITEM := p_line_ack_rec.ORDERED_ITEM ;
    x_line_ack_rec25.INVOICE_INTERFACE_STATUS_CODE := p_line_ack_rec.INVOICE_INTERFACE_STATUS_CODE ;
    x_line_ack_rec25.PREFERRED_GRADE := p_line_ack_rec.PREFERRED_GRADE ;
    x_line_ack_rec25.ORDERED_QUANTITY2 := p_line_ack_rec.ORDERED_QUANTITY2 ;
    x_line_ack_rec25.ORDERED_QUANTITY_UOM2 := p_line_ack_rec.ORDERED_QUANTITY_UOM2 ;
    x_line_ack_rec25.SHIPPING_QUANTITY2 := p_line_ack_rec.SHIPPING_QUANTITY2 ;
    x_line_ack_rec25.CANCELLED_QUANTITY2 := p_line_ack_rec.CANCELLED_QUANTITY2 ;
    x_line_ack_rec25.SHIPPED_QUANTITY2 := p_line_ack_rec.SHIPPED_QUANTITY2 ;
    x_line_ack_rec25.SHIPPING_QUANTITY_UOM2 := p_line_ack_rec.SHIPPING_QUANTITY_UOM2 ;
    x_line_ack_rec25.FULFILLED_QUANTITY2 := p_line_ack_rec.FULFILLED_QUANTITY2 ;
    x_line_ack_rec25.REVENUE_AMOUNT := p_line_ack_rec.REVENUE_AMOUNT ;
    x_line_ack_rec25.FULFILLMENT_DATE := p_line_ack_rec.FULFILLMENT_DATE ;
    x_line_ack_rec25.ORIGINAL_ITEM_IDENTIFIER_TYPE := p_line_ack_rec.ORIGINAL_ITEM_IDENTIFIER_TYPE ;
    x_line_ack_rec25.ITEM_SUBSTITUTION_TYPE_CODE := p_line_ack_rec.ITEM_SUBSTITUTION_TYPE_CODE ;
    x_line_ack_rec25.AUTO_SELECTED_QUANTITY := p_line_ack_rec.AUTO_SELECTED_QUANTITY ;
    x_line_ack_rec25.ORDERED_ITEM_ID := p_line_ack_rec.ORDERED_ITEM_ID ;
    x_line_ack_rec25.ITEM_IDENTIFIER_TYPE := p_line_ack_rec.ITEM_IDENTIFIER_TYPE ;
    x_line_ack_rec25.END_ITEM_UNIT_NUMBER := p_line_ack_rec.END_ITEM_UNIT_NUMBER ;
    x_line_ack_rec25.RETURN_ATTRIBUTE13 := p_line_ack_rec.RETURN_ATTRIBUTE13 ;
    x_line_ack_rec25.RETURN_ATTRIBUTE14 := p_line_ack_rec.RETURN_ATTRIBUTE14 ;
    x_line_ack_rec25.RETURN_ATTRIBUTE15 := p_line_ack_rec.RETURN_ATTRIBUTE15 ;
    x_line_ack_rec25.RETURN_ATTRIBUTE2 := p_line_ack_rec.RETURN_ATTRIBUTE2 ;
    x_line_ack_rec25.RETURN_ATTRIBUTE3 := p_line_ack_rec.RETURN_ATTRIBUTE3 ;
    x_line_ack_rec25.RETURN_ATTRIBUTE4 := p_line_ack_rec.RETURN_ATTRIBUTE4 ;
    x_line_ack_rec25.RETURN_ATTRIBUTE5 := p_line_ack_rec.RETURN_ATTRIBUTE5 ;
    x_line_ack_rec25.RETURN_ATTRIBUTE6 := p_line_ack_rec.RETURN_ATTRIBUTE6 ;
    x_line_ack_rec25.RETURN_ATTRIBUTE7 := p_line_ack_rec.RETURN_ATTRIBUTE7 ;
    x_line_ack_rec25.RETURN_ATTRIBUTE8 := p_line_ack_rec.RETURN_ATTRIBUTE8 ;
    x_line_ack_rec25.RETURN_ATTRIBUTE9 := p_line_ack_rec.RETURN_ATTRIBUTE9 ;
    x_line_ack_rec25.RETURN_CONTEXT := p_line_ack_rec.RETURN_CONTEXT ;
    x_line_ack_rec25.RETURN_REASON_CODE := p_line_ack_rec.RETURN_REASON_CODE ;
    x_line_ack_rec25.RLA_SCHEDULE_TYPE_CODE := p_line_ack_rec.RLA_SCHEDULE_TYPE_CODE ;
    x_line_ack_rec25.SALESREP_ID := p_line_ack_rec.SALESREP_ID ;
    x_line_ack_rec25.SALESREP := p_line_ack_rec.SALESREP ;
    x_line_ack_rec25.SCHEDULE_ARRIVAL_DATE := p_line_ack_rec.SCHEDULE_ARRIVAL_DATE ;
    x_line_ack_rec25.SCHEDULE_SHIP_DATE := p_line_ack_rec.SCHEDULE_SHIP_DATE ;
    x_line_ack_rec25.SCHEDULE_ITEM_DETAIL := p_line_ack_rec.SCHEDULE_ITEM_DETAIL ;
    x_line_ack_rec25.SCHEDULE_STATUS_CODE := p_line_ack_rec.SCHEDULE_STATUS_CODE ;
    x_line_ack_rec25.SHIP_MODEL_COMPLETE_FLAG := p_line_ack_rec.SHIP_MODEL_COMPLETE_FLAG ;
    x_line_ack_rec25.SHIP_SET_ID := p_line_ack_rec.SHIP_SET_ID ;
    x_line_ack_rec25.SHIP_SET_NAME := p_line_ack_rec.SHIP_SET_NAME ;
    x_line_ack_rec25.SHIP_TO_ADDRESS1 := p_line_ack_rec.SHIP_TO_ADDRESS1 ;
    x_line_ack_rec25.SHIP_TO_ADDRESS2 := p_line_ack_rec.SHIP_TO_ADDRESS2 ;
    x_line_ack_rec25.SHIP_TO_ADDRESS3 := p_line_ack_rec.SHIP_TO_ADDRESS3 ;
    x_line_ack_rec25.SHIP_TO_ADDRESS4 := p_line_ack_rec.SHIP_TO_ADDRESS4 ;
    x_line_ack_rec25.SHIP_TO_CITY := p_line_ack_rec.SHIP_TO_CITY ;
    x_line_ack_rec25.SHIP_TO_CONTACT := p_line_ack_rec.SHIP_TO_CONTACT ;
    x_line_ack_rec25.SHIP_TO_CONTACT_AREA_CODE1 := p_line_ack_rec.SHIP_TO_CONTACT_AREA_CODE1 ;
    x_line_ack_rec25.SHIP_TO_CONTACT_AREA_CODE2 := p_line_ack_rec.SHIP_TO_CONTACT_AREA_CODE2 ;
    x_line_ack_rec25.SHIP_TO_CONTACT_AREA_CODE3 := p_line_ack_rec.SHIP_TO_CONTACT_AREA_CODE3 ;
    x_line_ack_rec25.SHIP_TO_CONTACT_FIRST_NAME := p_line_ack_rec.SHIP_TO_CONTACT_FIRST_NAME ;
    x_line_ack_rec25.SHIP_TO_CONTACT_ID := p_line_ack_rec.SHIP_TO_CONTACT_ID ;
    x_line_ack_rec25.SHIP_TO_CONTACT_JOB_TITLE := p_line_ack_rec.SHIP_TO_CONTACT_JOB_TITLE ;
    x_line_ack_rec25.SHIP_TO_CONTACT_LAST_NAME := p_line_ack_rec.SHIP_TO_CONTACT_LAST_NAME ;
    x_line_ack_rec25.SHIP_TO_COUNTRY := p_line_ack_rec.SHIP_TO_COUNTRY ;
    x_line_ack_rec25.SHIP_TO_COUNTY := p_line_ack_rec.SHIP_TO_COUNTY ;
    x_line_ack_rec25.SHIP_TO_POSTAL_CODE := p_line_ack_rec.SHIP_TO_POSTAL_CODE ;
    x_line_ack_rec25.SHIP_TO_STATE := p_line_ack_rec.SHIP_TO_STATE ;
    x_line_ack_rec25.SHIP_TOLERANCE_ABOVE := p_line_ack_rec.SHIP_TOLERANCE_ABOVE ;
    x_line_ack_rec25.SHIP_TOLERANCE_BELOW := p_line_ack_rec.SHIP_TOLERANCE_BELOW ;
    x_line_ack_rec25.SHIPMENT_NUMBER := p_line_ack_rec.SHIPMENT_NUMBER ;
    x_line_ack_rec25.SHIPMENT_PRIORITY := p_line_ack_rec.SHIPMENT_PRIORITY ;
    x_line_ack_rec25.SHIPMENT_PRIORITY_CODE := p_line_ack_rec.SHIPMENT_PRIORITY_CODE ;
    x_line_ack_rec25.SHIPPED_QUANTITY := p_line_ack_rec.SHIPPED_QUANTITY ;
    x_line_ack_rec25.SHIPPING_METHOD := p_line_ack_rec.SHIPPING_METHOD ;
    x_line_ack_rec25.SHIPPING_METHOD_CODE := p_line_ack_rec.SHIPPING_METHOD_CODE ;
    x_line_ack_rec25.SHIPPING_QUANTITY := p_line_ack_rec.SHIPPING_QUANTITY ;
    x_line_ack_rec25.SHIPPING_QUANTITY_UOM := p_line_ack_rec.SHIPPING_QUANTITY_UOM ;
    x_line_ack_rec25.SORT_ORDER := p_line_ack_rec.SORT_ORDER ;
    x_line_ack_rec25.SOURCE_DOCUMENT_ID := p_line_ack_rec.SOURCE_DOCUMENT_ID ;
    x_line_ack_rec25.SOURCE_DOCUMENT_LINE_ID := p_line_ack_rec.SOURCE_DOCUMENT_LINE_ID ;
    x_line_ack_rec25.SOURCE_DOCUMENT_TYPE_ID := p_line_ack_rec.SOURCE_DOCUMENT_TYPE_ID ;
    x_line_ack_rec25.SOURCE_TYPE_CODE := p_line_ack_rec.SOURCE_TYPE_CODE ;
    x_line_ack_rec25.SPLIT_FROM_LINE_ID := p_line_ack_rec.SPLIT_FROM_LINE_ID ;
    x_line_ack_rec25.SUBINVENTORY := p_line_ack_rec.SUBINVENTORY ;
    x_line_ack_rec25.SUBMISSION_DATETIME := p_line_ack_rec.SUBMISSION_DATETIME ;
    x_line_ack_rec25.TASK := p_line_ack_rec.TASK ;
    x_line_ack_rec25.TASK_ID := p_line_ack_rec.TASK_ID ;
    x_line_ack_rec25.TAX := p_line_ack_rec.TAX ;
    x_line_ack_rec25.TAX_CODE := p_line_ack_rec.TAX_CODE ;
    x_line_ack_rec25.TAX_DATE := p_line_ack_rec.TAX_DATE ;
    x_line_ack_rec25.TAX_EXEMPT_FLAG := p_line_ack_rec.TAX_EXEMPT_FLAG ;
    x_line_ack_rec25.TAX_EXEMPT_NUMBER := p_line_ack_rec.TAX_EXEMPT_NUMBER ;
    x_line_ack_rec25.TAX_EXEMPT_REASON := p_line_ack_rec.TAX_EXEMPT_REASON ;
    x_line_ack_rec25.TAX_EXEMPT_REASON_CODE := p_line_ack_rec.TAX_EXEMPT_REASON_CODE ;
    x_line_ack_rec25.TAX_POINT := p_line_ack_rec.TAX_POINT ;
    x_line_ack_rec25.TAX_POINT_CODE := p_line_ack_rec.TAX_POINT_CODE ;
    x_line_ack_rec25.TAX_RATE := p_line_ack_rec.TAX_RATE ;

    --
    -- Bug 9151484
    --
    IF p_line_ack_rec.LINE_CATEGORY_CODE = 'RETURN' THEN
      x_line_ack_rec25.TAX_VALUE := -p_line_ack_rec.TAX_VALUE ;
      x_line_ack_rec25.ORDERED_QUANTITY := -p_line_ack_rec.ORDERED_QUANTITY;
    ELSE
      x_line_ack_rec25.TAX_VALUE := p_line_ack_rec.TAX_VALUE ;
      x_line_ack_rec25.ORDERED_QUANTITY := p_line_ack_rec.ORDERED_QUANTITY;
    END IF;
    --
    -- Bug 9151484
    --

    x_line_ack_rec25.UNIT_LIST_PRICE := p_line_ack_rec.UNIT_LIST_PRICE ;
    x_line_ack_rec25.UNIT_SELLING_PRICE := p_line_ack_rec.UNIT_SELLING_PRICE ;
    x_line_ack_rec25.VEH_CUS_ITEM_CUM_KEY_ID := p_line_ack_rec.VEH_CUS_ITEM_CUM_KEY_ID ;
    x_line_ack_rec25.VISIBLE_DEMAND_FLAG := p_line_ack_rec.VISIBLE_DEMAND_FLAG ;
    x_line_ack_rec25.CUSTOMER_LINE_NUMBER := p_line_ack_rec.CUSTOMER_LINE_NUMBER ;
    x_line_ack_rec25.CUSTOMER_SHIPMENT_NUMBER := p_line_ack_rec.CUSTOMER_SHIPMENT_NUMBER ;
    x_line_ack_rec25.CUSTOMER_ITEM_NET_PRICE := p_line_ack_rec.CUSTOMER_ITEM_NET_PRICE ;
    x_line_ack_rec25.CUSTOMER_PAYMENT_TERM_ID := p_line_ack_rec.CUSTOMER_PAYMENT_TERM_ID ;
    x_line_ack_rec25.DROP_SHIP_FLAG := p_line_ack_rec.DROP_SHIP_FLAG ;
    x_line_ack_rec25.SPLIT_FROM_LINE_REF := p_line_ack_rec.SPLIT_FROM_LINE_REF ;
    x_line_ack_rec25.SHIP_TO_EDI_LOCATION_CODE := p_line_ack_rec.SHIP_TO_EDI_LOCATION_CODE ;
    x_line_ack_rec25.SERVICE_TXN_REASON_CODE := p_line_ack_rec.SERVICE_TXN_REASON_CODE ;
    x_line_ack_rec25.SERVICE_TXN_COMMENTS := p_line_ack_rec.SERVICE_TXN_COMMENTS ;
    x_line_ack_rec25.SERVICE_DURATION := p_line_ack_rec.SERVICE_DURATION ;
    x_line_ack_rec25.SERVICE_START_DATE := p_line_ack_rec.SERVICE_START_DATE ;
    x_line_ack_rec25.SERVICE_END_DATE := p_line_ack_rec.SERVICE_END_DATE ;
    x_line_ack_rec25.SERVICE_COTERMINATE_FLAG := p_line_ack_rec.SERVICE_COTERMINATE_FLAG ;
    x_line_ack_rec25.SERVICE_NUMBER := p_line_ack_rec.SERVICE_NUMBER ;
    x_line_ack_rec25.SERVICE_PERIOD := p_line_ack_rec.SERVICE_PERIOD ;
    x_line_ack_rec25.SERVICE_REFERENCE_TYPE_CODE := p_line_ack_rec.SERVICE_REFERENCE_TYPE_CODE ;
    x_line_ack_rec25.SERVICE_REFERENCE_LINE_ID := p_line_ack_rec.SERVICE_REFERENCE_LINE_ID ;
    x_line_ack_rec25.SERVICE_REFERENCE_SYSTEM_ID := p_line_ack_rec.SERVICE_REFERENCE_SYSTEM_ID ;
    x_line_ack_rec25.CREDIT_INVOICE_LINE_ID := p_line_ack_rec.CREDIT_INVOICE_LINE_ID ;
    x_line_ack_rec25.SHIP_TO_PROVINCE := p_line_ack_rec.SHIP_TO_PROVINCE ;
    x_line_ack_rec25.INVOICE_PROVINCE := p_line_ack_rec.INVOICE_PROVINCE ;
    x_line_ack_rec25.BILL_TO_EDI_LOCATION_CODE := p_line_ack_rec.BILL_TO_EDI_LOCATION_CODE ;
    x_line_ack_rec25.INVOICE_CITY := p_line_ack_rec.INVOICE_CITY ;
    x_line_ack_rec25.INVENTORY_ITEM_SEGMENT_17 := p_line_ack_rec.INVENTORY_ITEM_SEGMENT_17 ;
    x_line_ack_rec25.INVENTORY_ITEM_SEGMENT_18 := p_line_ack_rec.INVENTORY_ITEM_SEGMENT_18 ;
    x_line_ack_rec25.INVENTORY_ITEM_SEGMENT_19 := p_line_ack_rec.INVENTORY_ITEM_SEGMENT_19 ;
    x_line_ack_rec25.INVENTORY_ITEM_SEGMENT_2 := p_line_ack_rec.INVENTORY_ITEM_SEGMENT_2 ;
    x_line_ack_rec25.INVENTORY_ITEM_SEGMENT_20 := p_line_ack_rec.INVENTORY_ITEM_SEGMENT_20 ;
    x_line_ack_rec25.INVENTORY_ITEM_SEGMENT_3 := p_line_ack_rec.INVENTORY_ITEM_SEGMENT_3 ;
    x_line_ack_rec25.INVENTORY_ITEM_SEGMENT_4 := p_line_ack_rec.INVENTORY_ITEM_SEGMENT_4 ;
    x_line_ack_rec25.INVENTORY_ITEM_SEGMENT_5 := p_line_ack_rec.INVENTORY_ITEM_SEGMENT_5 ;
    x_line_ack_rec25.INVENTORY_ITEM_SEGMENT_6 := p_line_ack_rec.INVENTORY_ITEM_SEGMENT_6 ;
    x_line_ack_rec25.INVENTORY_ITEM_SEGMENT_7 := p_line_ack_rec.INVENTORY_ITEM_SEGMENT_7 ;
    x_line_ack_rec25.INVENTORY_ITEM_SEGMENT_8 := p_line_ack_rec.INVENTORY_ITEM_SEGMENT_8 ;
    x_line_ack_rec25.INVENTORY_ITEM_SEGMENT_9 := p_line_ack_rec.INVENTORY_ITEM_SEGMENT_9 ;
    x_line_ack_rec25.INVOICE_COMPLETE_FLAG := p_line_ack_rec.INVOICE_COMPLETE_FLAG ;
    x_line_ack_rec25.INVOICE_SET_ID := p_line_ack_rec.INVOICE_SET_ID ;
    x_line_ack_rec25.INVOICE_SET_NAME := p_line_ack_rec.INVOICE_SET_NAME ;
    x_line_ack_rec25.INVOICE_NUMBER := p_line_ack_rec.INVOICE_NUMBER ;
    x_line_ack_rec25.INVOICE_TO_CONTACT := p_line_ack_rec.INVOICE_TO_CONTACT ;
    x_line_ack_rec25.INVOICE_TO_CONTACT_ID := p_line_ack_rec.INVOICE_TO_CONTACT_ID ;
    x_line_ack_rec25.INVOICE_TO_ORG := p_line_ack_rec.INVOICE_TO_ORG ;
    x_line_ack_rec25.INVOICE_TO_ORG_ID := p_line_ack_rec.INVOICE_TO_ORG_ID ;
    x_line_ack_rec25.INVOICE_TOLERANCE_ABOVE := p_line_ack_rec.INVOICE_TOLERANCE_ABOVE ;
    x_line_ack_rec25.INVOICE_TOLERANCE_BELOW := p_line_ack_rec.INVOICE_TOLERANCE_BELOW ;
    x_line_ack_rec25.INVOICING_RULE := p_line_ack_rec.INVOICING_RULE ;
    x_line_ack_rec25.INVOICING_RULE_ID := p_line_ack_rec.INVOICING_RULE_ID ;
    x_line_ack_rec25.ITEM_INPUT := p_line_ack_rec.ITEM_INPUT ;
    x_line_ack_rec25.ITEM_REVISION := p_line_ack_rec.ITEM_REVISION ;
    x_line_ack_rec25.ITEM_TYPE_CODE := p_line_ack_rec.ITEM_TYPE_CODE ;
    x_line_ack_rec25.LATEST_ACCEPTABLE_DATE := p_line_ack_rec.LATEST_ACCEPTABLE_DATE ;
    x_line_ack_rec25.LINE_CATEGORY_CODE := p_line_ack_rec.LINE_CATEGORY_CODE ;
    x_line_ack_rec25.LINE_ID := p_line_ack_rec.LINE_ID ;
    x_line_ack_rec25.LINE_NUMBER := p_line_ack_rec.LINE_NUMBER ;
    x_line_ack_rec25.LINE_PO_CONTEXT := p_line_ack_rec.LINE_PO_CONTEXT ;
    x_line_ack_rec25.LINE_TYPE := p_line_ack_rec.LINE_TYPE ;
    x_line_ack_rec25.LINE_TYPE_ID := p_line_ack_rec.LINE_TYPE_ID ;
    x_line_ack_rec25.LINK_TO_LINE_ID := p_line_ack_rec.LINK_TO_LINE_ID ;
    x_line_ack_rec25.LINK_TO_LINE_REF := p_line_ack_rec.LINK_TO_LINE_REF ;
    x_line_ack_rec25.LOAD_SEQ_NUMBER := p_line_ack_rec.LOAD_SEQ_NUMBER ;
    x_line_ack_rec25.LOT := p_line_ack_rec.LOT ;
    x_line_ack_rec25.MATERIAL_COST := p_line_ack_rec.MATERIAL_COST ;
    x_line_ack_rec25.MATERIAL_OVERHEAD_COST := p_line_ack_rec.MATERIAL_OVERHEAD_COST ;
    x_line_ack_rec25.MODEL_GROUP_NUMBER := p_line_ack_rec.MODEL_GROUP_NUMBER ;
    x_line_ack_rec25.OPEN_FLAG := p_line_ack_rec.OPEN_FLAG ;
    x_line_ack_rec25.OPERATION_CODE := p_line_ack_rec.OPERATION_CODE ;
    x_line_ack_rec25.OPTION_FLAG := p_line_ack_rec.OPTION_FLAG ;
    x_line_ack_rec25.OPTION_NUMBER := p_line_ack_rec.OPTION_NUMBER ;
    x_line_ack_rec25.ORDER_QUANTITY_UOM := p_line_ack_rec.ORDER_QUANTITY_UOM ;
    x_line_ack_rec25.ORDER_SOURCE := p_line_ack_rec.ORDER_SOURCE ;
    x_line_ack_rec25.ORDER_SOURCE_ID := p_line_ack_rec.ORDER_SOURCE_ID ;
    -- x_line_ack_rec25.ORDERED_QUANTITY := p_line_ack_rec.ORDERED_QUANTITY ; Bug 9151484
    x_line_ack_rec25.ORG_ID := p_line_ack_rec.ORG_ID ;
    x_line_ack_rec25.OUTSIDE_PROCESSING_COST := p_line_ack_rec.OUTSIDE_PROCESSING_COST ;
    x_line_ack_rec25.ORIG_SYS_SHIPMENT_REF := p_line_ack_rec.ORIG_SYS_SHIPMENT_REF ;
    x_line_ack_rec25.OVER_SHIP_REASON_CODE := p_line_ack_rec.OVER_SHIP_REASON_CODE ;
    x_line_ack_rec25.OVER_SHIP_RESOLVED_FLAG := p_line_ack_rec.OVER_SHIP_RESOLVED_FLAG ;
    x_line_ack_rec25.OVERHEAD_COST := p_line_ack_rec.OVERHEAD_COST ;
    x_line_ack_rec25.PAYMENT_TERM := p_line_ack_rec.PAYMENT_TERM ;
    x_line_ack_rec25.PAYMENT_TERM_ID := p_line_ack_rec.PAYMENT_TERM_ID ;
    x_line_ack_rec25.PAYMENT_TRX := p_line_ack_rec.PAYMENT_TRX ;
    x_line_ack_rec25.PAYMENT_TRX_ID := p_line_ack_rec.PAYMENT_TRX_ID ;
    x_line_ack_rec25.PLANNING_PROD_SEQ_NUM := p_line_ack_rec.PLANNING_PROD_SEQ_NUM ;
    x_line_ack_rec25.PRICING_ATTRIBUTE1 := p_line_ack_rec.PRICING_ATTRIBUTE1 ;
    x_line_ack_rec25.PRICING_ATTRIBUTE10 := p_line_ack_rec.PRICING_ATTRIBUTE10 ;
    x_line_ack_rec25.PRICING_ATTRIBUTE2 := p_line_ack_rec.PRICING_ATTRIBUTE2 ;
    x_line_ack_rec25.PRICING_ATTRIBUTE3 := p_line_ack_rec.PRICING_ATTRIBUTE3 ;
    x_line_ack_rec25.PRICING_ATTRIBUTE4 := p_line_ack_rec.PRICING_ATTRIBUTE4 ;
    x_line_ack_rec25.PRICING_ATTRIBUTE5 := p_line_ack_rec.PRICING_ATTRIBUTE5 ;
    x_line_ack_rec25.PRICING_ATTRIBUTE6 := p_line_ack_rec.PRICING_ATTRIBUTE6 ;
    x_line_ack_rec25.PRICING_ATTRIBUTE7 := p_line_ack_rec.PRICING_ATTRIBUTE7 ;
    x_line_ack_rec25.PRICING_ATTRIBUTE8 := p_line_ack_rec.PRICING_ATTRIBUTE8 ;
    x_line_ack_rec25.PRICING_ATTRIBUTE9 := p_line_ack_rec.PRICING_ATTRIBUTE9 ;
    x_line_ack_rec25.PRICING_CONTEXT := p_line_ack_rec.PRICING_CONTEXT ;
    x_line_ack_rec25.PRICING_DATE := p_line_ack_rec.PRICING_DATE ;
    x_line_ack_rec25.PRICING_QUANTITY := p_line_ack_rec.PRICING_QUANTITY ;
    x_line_ack_rec25.PRICING_QUANTITY_UOM := p_line_ack_rec.PRICING_QUANTITY_UOM ;
    x_line_ack_rec25.PROGRAM := p_line_ack_rec.PROGRAM ;
    x_line_ack_rec25.PROGRAM_APPLICATION := p_line_ack_rec.PROGRAM_APPLICATION ;
    x_line_ack_rec25.PROGRAM_APPLICATION_ID := p_line_ack_rec.PROGRAM_APPLICATION_ID ;
    x_line_ack_rec25.PROGRAM_ID := p_line_ack_rec.PROGRAM_ID ;
    x_line_ack_rec25.PROGRAM_UPDATE_DATE := p_line_ack_rec.PROGRAM_UPDATE_DATE ;
    x_line_ack_rec25.PROJECT := p_line_ack_rec.PROJECT ;
    x_line_ack_rec25.PROJECT_ID := p_line_ack_rec.PROJECT_ID ;
    x_line_ack_rec25.PROMISE_DATE := p_line_ack_rec.PROMISE_DATE ;
    x_line_ack_rec25.REFERENCE_HEADER := p_line_ack_rec.REFERENCE_HEADER ;
    x_line_ack_rec25.REFERENCE_HEADER_ID := p_line_ack_rec.REFERENCE_HEADER_ID ;
    x_line_ack_rec25.REFERENCE_LINE := p_line_ack_rec.REFERENCE_LINE ;
    x_line_ack_rec25.REFERENCE_LINE_ID := p_line_ack_rec.REFERENCE_LINE_ID ;
    x_line_ack_rec25.REFERENCE_TYPE := p_line_ack_rec.REFERENCE_TYPE ;
    x_line_ack_rec25.RELATED_PO_NUMBER := p_line_ack_rec.RELATED_PO_NUMBER ;
    x_line_ack_rec25.REQUEST_DATE := p_line_ack_rec.REQUEST_DATE ;
    x_line_ack_rec25.REQUEST_ID := p_line_ack_rec.REQUEST_ID ;
    x_line_ack_rec25.RESERVED_QUANTITY := p_line_ack_rec.RESERVED_QUANTITY ;
    x_line_ack_rec25.RESOURCE_COST := p_line_ack_rec.RESOURCE_COST ;
    x_line_ack_rec25.RETURN_ATTRIBUTE1 := p_line_ack_rec.RETURN_ATTRIBUTE1 ;
    x_line_ack_rec25.RETURN_ATTRIBUTE10 := p_line_ack_rec.RETURN_ATTRIBUTE10 ;
    x_line_ack_rec25.RETURN_ATTRIBUTE11 := p_line_ack_rec.RETURN_ATTRIBUTE11 ;
    x_line_ack_rec25.RETURN_ATTRIBUTE12 := p_line_ack_rec.RETURN_ATTRIBUTE12 ;
    x_line_ack_rec25.DELIVER_TO_CONTACT_ID := p_line_ack_rec.DELIVER_TO_CONTACT_ID ;
    x_line_ack_rec25.DELIVER_TO_ORG := p_line_ack_rec.DELIVER_TO_ORG ;
    x_line_ack_rec25.DELIVER_TO_ORG_ID := p_line_ack_rec.DELIVER_TO_ORG_ID ;
    x_line_ack_rec25.DELIVERY_LEAD_TIME := p_line_ack_rec.DELIVERY_LEAD_TIME ;
    x_line_ack_rec25.DEMAND_BUCKET_TYPE := p_line_ack_rec.DEMAND_BUCKET_TYPE ;
    x_line_ack_rec25.DEMAND_BUCKET_TYPE_CODE := p_line_ack_rec.DEMAND_BUCKET_TYPE_CODE ;
    x_line_ack_rec25.DEMAND_CLASS := p_line_ack_rec.DEMAND_CLASS ;
    x_line_ack_rec25.DEMAND_CLASS_CODE := p_line_ack_rec.DEMAND_CLASS_CODE ;
    x_line_ack_rec25.DEMAND_STREAM := p_line_ack_rec.DEMAND_STREAM ;
    x_line_ack_rec25.DEP_PLAN_REQUIRED_FLAG := p_line_ack_rec.DEP_PLAN_REQUIRED_FLAG ;
    x_line_ack_rec25.DPW_ASSIGNED_FLAG := p_line_ack_rec.DPW_ASSIGNED_FLAG ;
    x_line_ack_rec25.EARLIEST_ACCEPTABLE_DATE := p_line_ack_rec.EARLIEST_ACCEPTABLE_DATE ;
    x_line_ack_rec25.ERROR_FLAG := p_line_ack_rec.ERROR_FLAG ;
    x_line_ack_rec25.EXPLOSION_DATE := p_line_ack_rec.EXPLOSION_DATE ;
    x_line_ack_rec25.FOB_POINT := p_line_ack_rec.FOB_POINT ;
    x_line_ack_rec25.FOB_POINT_CODE := p_line_ack_rec.FOB_POINT_CODE ;
    x_line_ack_rec25.FREIGHT_CARRIER_CODE := p_line_ack_rec.FREIGHT_CARRIER_CODE ;
    x_line_ack_rec25.FREIGHT_TERMS := p_line_ack_rec.FREIGHT_TERMS ;
    x_line_ack_rec25.FREIGHT_TERMS_CODE := p_line_ack_rec.FREIGHT_TERMS_CODE ;
    x_line_ack_rec25.FULFILLED_QUANTITY := p_line_ack_rec.FULFILLED_QUANTITY ;
    x_line_ack_rec25.FULFILLMENT_SET_ID := p_line_ack_rec.FULFILLMENT_SET_ID ;
    x_line_ack_rec25.FULFILLMENT_SET_NAME := p_line_ack_rec.FULFILLMENT_SET_NAME ;
    x_line_ack_rec25.GLOBAL_ATTRIBUTE_CATEGORY := p_line_ack_rec.GLOBAL_ATTRIBUTE_CATEGORY ;
    x_line_ack_rec25.GLOBAL_ATTRIBUTE1 := p_line_ack_rec.GLOBAL_ATTRIBUTE1 ;
    x_line_ack_rec25.GLOBAL_ATTRIBUTE10 := p_line_ack_rec.GLOBAL_ATTRIBUTE10 ;
    x_line_ack_rec25.GLOBAL_ATTRIBUTE11 := p_line_ack_rec.GLOBAL_ATTRIBUTE11 ;
    x_line_ack_rec25.GLOBAL_ATTRIBUTE12 := p_line_ack_rec.GLOBAL_ATTRIBUTE12 ;
    x_line_ack_rec25.GLOBAL_ATTRIBUTE13 := p_line_ack_rec.GLOBAL_ATTRIBUTE13 ;
    x_line_ack_rec25.GLOBAL_ATTRIBUTE14 := p_line_ack_rec.GLOBAL_ATTRIBUTE14 ;
    x_line_ack_rec25.GLOBAL_ATTRIBUTE15 := p_line_ack_rec.GLOBAL_ATTRIBUTE15 ;
    x_line_ack_rec25.GLOBAL_ATTRIBUTE16 := p_line_ack_rec.GLOBAL_ATTRIBUTE16 ;
    x_line_ack_rec25.GLOBAL_ATTRIBUTE17 := p_line_ack_rec.GLOBAL_ATTRIBUTE17 ;
    x_line_ack_rec25.GLOBAL_ATTRIBUTE18 := p_line_ack_rec.GLOBAL_ATTRIBUTE18 ;
    x_line_ack_rec25.GLOBAL_ATTRIBUTE19 := p_line_ack_rec.GLOBAL_ATTRIBUTE19 ;
    x_line_ack_rec25.GLOBAL_ATTRIBUTE2 := p_line_ack_rec.GLOBAL_ATTRIBUTE2 ;
    x_line_ack_rec25.GLOBAL_ATTRIBUTE20 := p_line_ack_rec.GLOBAL_ATTRIBUTE20 ;
    x_line_ack_rec25.GLOBAL_ATTRIBUTE3 := p_line_ack_rec.GLOBAL_ATTRIBUTE3 ;
    x_line_ack_rec25.GLOBAL_ATTRIBUTE4 := p_line_ack_rec.GLOBAL_ATTRIBUTE4 ;
    x_line_ack_rec25.GLOBAL_ATTRIBUTE5 := p_line_ack_rec.GLOBAL_ATTRIBUTE5 ;
    x_line_ack_rec25.GLOBAL_ATTRIBUTE6 := p_line_ack_rec.GLOBAL_ATTRIBUTE6 ;
    x_line_ack_rec25.GLOBAL_ATTRIBUTE7 := p_line_ack_rec.GLOBAL_ATTRIBUTE7 ;
    x_line_ack_rec25.GLOBAL_ATTRIBUTE8 := p_line_ack_rec.GLOBAL_ATTRIBUTE8 ;
    x_line_ack_rec25.GLOBAL_ATTRIBUTE9 := p_line_ack_rec.GLOBAL_ATTRIBUTE9 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE1 := p_line_ack_rec.INDUSTRY_ATTRIBUTE1 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE10 := p_line_ack_rec.INDUSTRY_ATTRIBUTE10 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE11 := p_line_ack_rec.INDUSTRY_ATTRIBUTE11 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE12 := p_line_ack_rec.INDUSTRY_ATTRIBUTE12 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE13 := p_line_ack_rec.INDUSTRY_ATTRIBUTE13 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE14 := p_line_ack_rec.INDUSTRY_ATTRIBUTE14 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE15 := p_line_ack_rec.INDUSTRY_ATTRIBUTE15 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE16 := p_line_ack_rec.INDUSTRY_ATTRIBUTE16 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE17 := p_line_ack_rec.INDUSTRY_ATTRIBUTE17 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE18 := p_line_ack_rec.INDUSTRY_ATTRIBUTE18 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE19 := p_line_ack_rec.INDUSTRY_ATTRIBUTE19 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE2 := p_line_ack_rec.INDUSTRY_ATTRIBUTE2 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE20 := p_line_ack_rec.INDUSTRY_ATTRIBUTE20 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE21 := p_line_ack_rec.INDUSTRY_ATTRIBUTE21 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE22 := p_line_ack_rec.INDUSTRY_ATTRIBUTE22 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE23 := p_line_ack_rec.INDUSTRY_ATTRIBUTE23 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE24 := p_line_ack_rec.INDUSTRY_ATTRIBUTE24 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE25 := p_line_ack_rec.INDUSTRY_ATTRIBUTE25 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE26 := p_line_ack_rec.INDUSTRY_ATTRIBUTE26 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE27 := p_line_ack_rec.INDUSTRY_ATTRIBUTE27 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE28 := p_line_ack_rec.INDUSTRY_ATTRIBUTE28 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE29 := p_line_ack_rec.INDUSTRY_ATTRIBUTE29 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE3 := p_line_ack_rec.INDUSTRY_ATTRIBUTE3 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE30 := p_line_ack_rec.INDUSTRY_ATTRIBUTE30 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE4 := p_line_ack_rec.INDUSTRY_ATTRIBUTE4 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE5 := p_line_ack_rec.INDUSTRY_ATTRIBUTE5 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE6 := p_line_ack_rec.INDUSTRY_ATTRIBUTE6 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE7 := p_line_ack_rec.INDUSTRY_ATTRIBUTE7 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE8 := p_line_ack_rec.INDUSTRY_ATTRIBUTE8 ;
    x_line_ack_rec25.INDUSTRY_ATTRIBUTE9 := p_line_ack_rec.INDUSTRY_ATTRIBUTE9 ;
    x_line_ack_rec25.INDUSTRY_CONTEXT := p_line_ack_rec.INDUSTRY_CONTEXT ;
    x_line_ack_rec25.INTMED_SHIP_TO_CONTACT_ID := p_line_ack_rec.INTMED_SHIP_TO_CONTACT_ID ;
    x_line_ack_rec25.INTMED_SHIP_TO_ORG_ID := p_line_ack_rec.INTMED_SHIP_TO_ORG_ID ;
    x_line_ack_rec25.INTERFACE_STATUS := p_line_ack_rec.INTERFACE_STATUS ;
    x_line_ack_rec25.INVENTORY_ITEM := p_line_ack_rec.INVENTORY_ITEM ;
    x_line_ack_rec25.INVENTORY_ITEM_ID := p_line_ack_rec.INVENTORY_ITEM_ID ;
    x_line_ack_rec25.INVENTORY_ITEM_SEGMENT_1 := p_line_ack_rec.INVENTORY_ITEM_SEGMENT_1 ;
    x_line_ack_rec25.INVENTORY_ITEM_SEGMENT_10 := p_line_ack_rec.INVENTORY_ITEM_SEGMENT_10 ;
    x_line_ack_rec25.INVENTORY_ITEM_SEGMENT_11 := p_line_ack_rec.INVENTORY_ITEM_SEGMENT_11 ;
    x_line_ack_rec25.INVENTORY_ITEM_SEGMENT_12 := p_line_ack_rec.INVENTORY_ITEM_SEGMENT_12 ;
    x_line_ack_rec25.INVENTORY_ITEM_SEGMENT_13 := p_line_ack_rec.INVENTORY_ITEM_SEGMENT_13 ;
    x_line_ack_rec25.INVENTORY_ITEM_SEGMENT_14 := p_line_ack_rec.INVENTORY_ITEM_SEGMENT_14 ;
    x_line_ack_rec25.INVENTORY_ITEM_SEGMENT_15 := p_line_ack_rec.INVENTORY_ITEM_SEGMENT_15 ;
    x_line_ack_rec25.INVENTORY_ITEM_SEGMENT_16 := p_line_ack_rec.INVENTORY_ITEM_SEGMENT_16 ;
    x_line_ack_rec25.SHIP_TO_PARTY_NUMBER := p_line_ack_rec.SHIP_TO_PARTY_NUMBER ;
    x_line_ack_rec25.INVOICE_TO_PARTY_NUMBER := p_line_ack_rec.INVOICE_TO_PARTY_NUMBER ;
    x_line_ack_rec25.DELIVER_TO_PARTY_NUMBER := p_line_ack_rec.DELIVER_TO_PARTY_NUMBER ;
    x_line_ack_rec25.END_CUSTOMER_NUMBER := p_line_ack_rec.END_CUSTOMER_NUMBER ;
    x_line_ack_rec25.END_CUSTOMER_PARTY_NUMBER := p_line_ack_rec.END_CUSTOMER_PARTY_NUMBER ;
    x_line_ack_rec25.END_CUSTOMER_ID := p_line_ack_rec.END_CUSTOMER_ID ;
    x_line_ack_rec25.END_CUSTOMER_CONTACT_ID := p_line_ack_rec.END_CUSTOMER_CONTACT_ID ;
    x_line_ack_rec25.END_CUSTOMER_SITE_USE_ID := p_line_ack_rec.END_CUSTOMER_SITE_USE_ID ;
    x_line_ack_rec25.END_CUSTOMER_ADDRESS1 := p_line_ack_rec.END_CUSTOMER_ADDRESS1 ;
    x_line_ack_rec25.END_CUSTOMER_ADDRESS2 := p_line_ack_rec.END_CUSTOMER_ADDRESS2 ;
    x_line_ack_rec25.END_CUSTOMER_ADDRESS3 := p_line_ack_rec.END_CUSTOMER_ADDRESS3 ;
    x_line_ack_rec25.END_CUSTOMER_ADDRESS4 := p_line_ack_rec.END_CUSTOMER_ADDRESS4 ;
    x_line_ack_rec25.END_CUSTOMER_CITY := p_line_ack_rec.END_CUSTOMER_CITY ;
    x_line_ack_rec25.END_CUSTOMER_POSTAL_CODE := p_line_ack_rec.END_CUSTOMER_POSTAL_CODE ;
    x_line_ack_rec25.END_CUSTOMER_COUNTRY := p_line_ack_rec.END_CUSTOMER_COUNTRY ;
    x_line_ack_rec25.END_CUSTOMER_STATE := p_line_ack_rec.END_CUSTOMER_STATE ;
    x_line_ack_rec25.END_CUSTOMER_COUNTY := p_line_ack_rec.END_CUSTOMER_COUNTY ;
    x_line_ack_rec25.END_CUSTOMER_PROVINCE := p_line_ack_rec.END_CUSTOMER_PROVINCE ;
    x_line_ack_rec25.END_CUSTOMER_CONTACT := p_line_ack_rec.END_CUSTOMER_CONTACT ;
    x_line_ack_rec25.SHIPPING_INSTRUCTIONS := p_line_ack_rec.SHIPPING_INSTRUCTIONS ;
    x_line_ack_rec25.PACKING_INSTRUCTIONS := p_line_ack_rec.PACKING_INSTRUCTIONS ;
    x_line_ack_rec25.INVOICED_QUANTITY := p_line_ack_rec.INVOICED_QUANTITY ;
    x_line_ack_rec25.REFERENCE_CUSTOMER_TRX_LINE_ID := p_line_ack_rec.REFERENCE_CUSTOMER_TRX_LINE_ID ;
    x_line_ack_rec25.SPLIT_BY := p_line_ack_rec.SPLIT_BY ;
    x_line_ack_rec25.LINE_SET_ID := p_line_ack_rec.LINE_SET_ID ;
    x_line_ack_rec25.UNIT_LIST_PERCENT := p_line_ack_rec.UNIT_LIST_PERCENT ;
    x_line_ack_rec25.UNIT_SELLING_PERCENT := p_line_ack_rec.UNIT_SELLING_PERCENT ;
    x_line_ack_rec25.UNIT_PERCENT_BASE_PRICE := p_line_ack_rec.UNIT_PERCENT_BASE_PRICE ;
    x_line_ack_rec25.RE_SOURCE_FLAG := p_line_ack_rec.RE_SOURCE_FLAG ;
    x_line_ack_rec25.FLOW_STATUS_CODE := p_line_ack_rec.FLOW_STATUS_CODE ;
    x_line_ack_rec25.UNIT_LIST_PRICE_PER_PQTY := p_line_ack_rec.UNIT_LIST_PRICE_PER_PQTY ;
    x_line_ack_rec25.UNIT_SELLING_PRICE_PQTY := p_line_ack_rec.UNIT_SELLING_PRICE_PQTY ;
    x_line_ack_rec25.ITEM_RELATIONSHIP_TYPE := p_line_ack_rec.ITEM_RELATIONSHIP_TYPE ;
    x_line_ack_rec25.HEADER_ID := p_line_ack_rec.HEADER_ID ;
    x_line_ack_rec25.ORIG_SYS_DOCUMENT_REF := p_line_ack_rec.ORIG_SYS_DOCUMENT_REF ;
    x_line_ack_rec25.ORIG_SYS_LINE_REF := p_line_ack_rec.ORIG_SYS_LINE_REF ;
    x_line_ack_rec25.CHANGE_DATE := p_line_ack_rec.CHANGE_DATE ;
    x_line_ack_rec25.CHANGE_SEQUENCE := p_line_ack_rec.CHANGE_SEQUENCE ;
    x_line_ack_rec25.ACCOUNTING_RULE := p_line_ack_rec.ACCOUNTING_RULE ;
    x_line_ack_rec25.ORDER_NUMBER := p_line_ack_rec.ORDER_NUMBER ;
    x_line_ack_rec25.ACCOUNTING_RULE_ID := p_line_ack_rec.ACCOUNTING_RULE_ID ;
    x_line_ack_rec25.ACKNOWLEDGMENT_FLAG := p_line_ack_rec.ACKNOWLEDGMENT_FLAG ;
    x_line_ack_rec25.FIRST_ACK_CODE := p_line_ack_rec.FIRST_ACK_CODE ;
    x_line_ack_rec25.LAST_ACK_CODE := p_line_ack_rec.LAST_ACK_CODE ;
    x_line_ack_rec25.FIRST_ACK_DATE := p_line_ack_rec.FIRST_ACK_DATE ;
    x_line_ack_rec25.LAST_ACK_DATE := p_line_ack_rec.LAST_ACK_DATE ;
    x_line_ack_rec25.BUYER_SELLER_FLAG := p_line_ack_rec.BUYER_SELLER_FLAG ;
    x_line_ack_rec25.CREATED_BY := p_line_ack_rec.CREATED_BY ;
    x_line_ack_rec25.CREATION_DATE := p_line_ack_rec.CREATION_DATE ;
    x_line_ack_rec25.LAST_UPDATE_DATE := p_line_ack_rec.LAST_UPDATE_DATE ;
    x_line_ack_rec25.LAST_UPDATE_LOGIN := p_line_ack_rec.LAST_UPDATE_LOGIN ;
    x_line_ack_rec25.LAST_UPDATED_BY := p_line_ack_rec.LAST_UPDATED_BY ;
    x_line_ack_rec25.ACTUAL_ARRIVAL_DATE := p_line_ack_rec.ACTUAL_ARRIVAL_DATE ;
    x_line_ack_rec25.ACTUAL_SHIPMENT_DATE := p_line_ack_rec.ACTUAL_SHIPMENT_DATE ;
    x_line_ack_rec25.AGREEMENT := p_line_ack_rec.AGREEMENT ;
    x_line_ack_rec25.AGREEMENT_ID := p_line_ack_rec.AGREEMENT_ID ;
    x_line_ack_rec25.ARRIVAL_SET_ID := p_line_ack_rec.ARRIVAL_SET_ID ;
    x_line_ack_rec25.ARRIVAL_SET_NAME := p_line_ack_rec.ARRIVAL_SET_NAME ;
    x_line_ack_rec25.PRICE_LIST := p_line_ack_rec.PRICE_LIST ;
    x_line_ack_rec25.PRICE_LIST_ID := p_line_ack_rec.PRICE_LIST_ID ;
    x_line_ack_rec25.SHIP_FROM_ORG := p_line_ack_rec.SHIP_FROM_ORG ;
    x_line_ack_rec25.SHIP_FROM_ORG_ID := p_line_ack_rec.SHIP_FROM_ORG_ID ;
    x_line_ack_rec25.SHIP_TO_ORG := p_line_ack_rec.SHIP_TO_ORG ;
    x_line_ack_rec25.SHIP_TO_ORG_ID := p_line_ack_rec.SHIP_TO_ORG_ID ;
    x_line_ack_rec25.SOLD_FROM_ORG := p_line_ack_rec.SOLD_FROM_ORG ;
    x_line_ack_rec25.SOLD_FROM_ORG_ID := p_line_ack_rec.SOLD_FROM_ORG_ID ;
    x_line_ack_rec25.SOLD_TO_ORG := p_line_ack_rec.SOLD_TO_ORG ;
    x_line_ack_rec25.SOLD_TO_ORG_ID := p_line_ack_rec.SOLD_TO_ORG_ID ;
    x_line_ack_rec25.ATO_LINE_ID := p_line_ack_rec.ATO_LINE_ID ;
    x_line_ack_rec25.ATTRIBUTE1 := p_line_ack_rec.ATTRIBUTE1 ;
    x_line_ack_rec25.ATTRIBUTE10 := p_line_ack_rec.ATTRIBUTE10 ;
    x_line_ack_rec25.ATTRIBUTE11 := p_line_ack_rec.ATTRIBUTE11 ;
    x_line_ack_rec25.ATTRIBUTE12 := p_line_ack_rec.ATTRIBUTE12 ;
    x_line_ack_rec25.ATTRIBUTE13 := p_line_ack_rec.ATTRIBUTE13 ;
    x_line_ack_rec25.ATTRIBUTE14 := p_line_ack_rec.ATTRIBUTE14 ;
    x_line_ack_rec25.ATTRIBUTE15 := p_line_ack_rec.ATTRIBUTE15 ;
    x_line_ack_rec25.ATTRIBUTE2 := p_line_ack_rec.ATTRIBUTE2 ;
    x_line_ack_rec25.ATTRIBUTE3 := p_line_ack_rec.ATTRIBUTE3 ;
    x_line_ack_rec25.ATTRIBUTE4 := p_line_ack_rec.ATTRIBUTE4 ;
    x_line_ack_rec25.ATTRIBUTE5 := p_line_ack_rec.ATTRIBUTE5 ;
    x_line_ack_rec25.ATTRIBUTE6 := p_line_ack_rec.ATTRIBUTE6 ;
    x_line_ack_rec25.ATTRIBUTE7 := p_line_ack_rec.ATTRIBUTE7 ;
    x_line_ack_rec25.ATTRIBUTE8 := p_line_ack_rec.ATTRIBUTE8 ;
    x_line_ack_rec25.ATTRIBUTE9 := p_line_ack_rec.ATTRIBUTE9 ;
    x_line_ack_rec25.AUTHORIZED_TO_SHIP_FLAG := p_line_ack_rec.AUTHORIZED_TO_SHIP_FLAG ;
    x_line_ack_rec25.BOOKED_FLAG := p_line_ack_rec.BOOKED_FLAG ;
    x_line_ack_rec25.CALCULATE_PRICE_FLAG := p_line_ack_rec.CALCULATE_PRICE_FLAG ;
    x_line_ack_rec25.CANCELLED_FLAG := p_line_ack_rec.CANCELLED_FLAG ;
    x_line_ack_rec25.CANCELLED_QUANTITY := p_line_ack_rec.CANCELLED_QUANTITY ;
    x_line_ack_rec25.CLOSED_FLAG := p_line_ack_rec.CLOSED_FLAG ;
    x_line_ack_rec25.COMMITMENT_ID := p_line_ack_rec.COMMITMENT_ID ;
    x_line_ack_rec25.COMPONENT_CODE := p_line_ack_rec.COMPONENT_CODE ;
    x_line_ack_rec25.COMPONENT_NUMBER := p_line_ack_rec.COMPONENT_NUMBER ;
    x_line_ack_rec25.COMPONENT_SEQUENCE_ID := p_line_ack_rec.COMPONENT_SEQUENCE_ID ;
    x_line_ack_rec25.CONFIG_DISPLAY_SEQUENCE := p_line_ack_rec.CONFIG_DISPLAY_SEQUENCE ;
    x_line_ack_rec25.CONFIGURATION_ID := p_line_ack_rec.CONFIGURATION_ID ;
    x_line_ack_rec25.CONFIG_LINE_REF := p_line_ack_rec.CONFIG_LINE_REF ;
    x_line_ack_rec25.TOP_MODEL_LINE_ID := p_line_ack_rec.TOP_MODEL_LINE_ID ;
    x_line_ack_rec25.CONTEXT := p_line_ack_rec.CONTEXT ;
    x_line_ack_rec25.CONTRACT_PO_NUMBER := p_line_ack_rec.CONTRACT_PO_NUMBER ;
    x_line_ack_rec25.COST_TYPE := p_line_ack_rec.COST_TYPE ;
    x_line_ack_rec25.COST_TYPE_ID := p_line_ack_rec.COST_TYPE_ID ;
    x_line_ack_rec25.COSTING_DATE := p_line_ack_rec.COSTING_DATE ;
    x_line_ack_rec25.CUST_MODEL_SERIAL_NUMBER := p_line_ack_rec.CUST_MODEL_SERIAL_NUMBER ;
    x_line_ack_rec25.CUST_PO_NUMBER := p_line_ack_rec.CUST_PO_NUMBER ;
    x_line_ack_rec25.CUST_PRODUCTION_SEQ_NUM := p_line_ack_rec.CUST_PRODUCTION_SEQ_NUM ;
    x_line_ack_rec25.CUSTOMER_DOCK := p_line_ack_rec.CUSTOMER_DOCK ;
    x_line_ack_rec25.CUSTOMER_DOCK_CODE := p_line_ack_rec.CUSTOMER_DOCK_CODE ;
    x_line_ack_rec25.CUSTOMER_ITEM := p_line_ack_rec.CUSTOMER_ITEM ;
    x_line_ack_rec25.CUSTOMER_ITEM_ID := p_line_ack_rec.CUSTOMER_ITEM_ID ;
    x_line_ack_rec25.CUSTOMER_ITEM_REVISION := p_line_ack_rec.CUSTOMER_ITEM_REVISION ;
    x_line_ack_rec25.CUSTOMER_JOB := p_line_ack_rec.CUSTOMER_JOB ;
    x_line_ack_rec25.CUSTOMER_PRODUCTION_LINE := p_line_ack_rec.CUSTOMER_PRODUCTION_LINE ;
    x_line_ack_rec25.CUSTOMER_TRX_LINE_ID := p_line_ack_rec.CUSTOMER_TRX_LINE_ID ;
    x_line_ack_rec25.DELIVERY_ID := p_line_ack_rec.DELIVERY_ID ;
    x_line_ack_rec25.DELIVER_TO_CONTACT := p_line_ack_rec.DELIVER_TO_CONTACT ;

    x_line_ack_rec25.freight_charge :=  NULL;
END line_ack_rec_to_line_ack_rec25;

PROCEDURE line_ack_tab_to_line_ack_tab25(
    p_line_ack_tab    IN          oe_sync_order_pvt_line_ack_tb,
    x_line_ack_tab25  OUT NOCOPY  oe_ack_pub_line_tab25
)
IS
  l_count   NUMBER;

  l_line_ack_rec    oe_acknowledgment_pub_line_ac;
  l_line_ack_rec25  oe_ack_pub_line_rec25;
BEGIN
  --  Guard within a PL/SQL block to avoid "Reference to Un-Initialized
  --  Collection" exception.
  BEGIN
    l_count :=  p_line_ack_tab.Count;

    IF l_count > 0  THEN
      x_line_ack_tab25  := oe_ack_pub_line_tab25();
      FOR i IN 1..l_count
      LOOP
        l_line_ack_rec      :=  p_line_ack_tab(i);
        line_ack_rec_to_line_ack_rec25(l_line_ack_rec, l_line_ack_rec25);

        x_line_ack_tab25.extend;
        x_line_ack_tab25(i) :=  l_line_ack_rec25;
      END LOOP;
    END IF;
  EXCEPTION
    WHEN Others THEN
      NULL;
  END;

END line_ack_tab_to_line_ack_tab25;

----- O2C25


--  Procedure Convert_hdr_null_to_miss

PROCEDURE Convert_hdr_null_to_miss
(   p_x_header_rec        IN OUT NOCOPY  OE_Order_PUB.Header_Rec_Type
)
IS
--p_x_header_rec                  OE_Order_PUB.Header_Rec_Type := p_header_rec;
BEGIN

    oe_debug_pub.add('Entering OE_GENESIS_UTIL.Convert_hdr_null_to_miss', 1);

    IF p_x_header_rec.accounting_rule_id IS NULL THEN
        p_x_header_rec.accounting_rule_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.accounting_rule_duration IS NULL THEN
        p_x_header_rec.accounting_rule_duration :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.agreement_id IS NULL THEN
        p_x_header_rec.agreement_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.blanket_number IS NULL THEN
       p_x_header_rec.blanket_number :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.booked_flag IS NULL THEN
        p_x_header_rec.booked_flag := FND_API.G_MISS_CHAR ;
    END IF;

    IF p_x_header_rec.upgraded_flag IS NULL THEN
        p_x_header_rec.upgraded_flag := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.booked_date IS NULL THEN
        p_x_header_rec.booked_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_header_rec.cancelled_flag IS NULL THEN
        p_x_header_rec.cancelled_flag := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.attribute1 IS NULL THEN
        p_x_header_rec.attribute1 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.attribute10 IS NULL THEN
        p_x_header_rec.attribute10 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.attribute11 IS NULL THEN
        p_x_header_rec.attribute11 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.attribute12 IS NULL THEN
        p_x_header_rec.attribute12 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.attribute13 IS NULL THEN
        p_x_header_rec.attribute13 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.attribute14 IS NULL THEN
        p_x_header_rec.attribute14 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.attribute15 IS NULL THEN
        p_x_header_rec.attribute15 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.attribute16 IS NULL THEN    --For bug 2184255
        p_x_header_rec.attribute16 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.attribute17 IS NULL THEN
        p_x_header_rec.attribute17 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.attribute18 IS NULL THEN
        p_x_header_rec.attribute18 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.attribute19 IS NULL THEN
        p_x_header_rec.attribute19 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.attribute2 IS NULL THEN
        p_x_header_rec.attribute2 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.attribute20 IS NULL THEN    --For bug 2184255
        p_x_header_rec.attribute20 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.attribute3 IS NULL THEN
        p_x_header_rec.attribute3 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.attribute4 IS NULL THEN
        p_x_header_rec.attribute4 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.attribute5 IS NULL THEN
        p_x_header_rec.attribute5 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.attribute6 IS NULL THEN
        p_x_header_rec.attribute6 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.attribute7 IS NULL THEN
        p_x_header_rec.attribute7 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.attribute8 IS NULL THEN
        p_x_header_rec.attribute8 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.attribute9 IS NULL THEN
        p_x_header_rec.attribute9 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.context IS NULL THEN
        p_x_header_rec.context := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.conversion_rate IS NULL THEN
        p_x_header_rec.conversion_rate :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.conversion_rate_date IS NULL THEN
        p_x_header_rec.conversion_rate_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_header_rec.conversion_type_code IS NULL THEN
        p_x_header_rec.conversion_type_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.CUSTOMER_PREFERENCE_SET_CODE IS NULL THEN
        p_x_header_rec.CUSTOMER_PREFERENCE_SET_CODE := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.created_by IS NULL THEN
        p_x_header_rec.created_by :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.creation_date IS NULL THEN
        p_x_header_rec.creation_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_header_rec.cust_po_number IS NULL THEN
        p_x_header_rec.cust_po_number := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.default_fulfillment_set IS NULL THEN
        p_x_header_rec.default_fulfillment_set := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.deliver_to_contact_id IS NULL THEN
        p_x_header_rec.deliver_to_contact_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.deliver_to_org_id IS NULL THEN
        p_x_header_rec.deliver_to_org_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.demand_class_code IS NULL THEN
        p_x_header_rec.demand_class_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.expiration_date IS NULL THEN
        p_x_header_rec.expiration_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_header_rec.earliest_schedule_limit IS NULL THEN
        p_x_header_rec.earliest_schedule_limit :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.fob_point_code IS NULL THEN
        p_x_header_rec.fob_point_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.freight_carrier_code IS NULL THEN
        p_x_header_rec.freight_carrier_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.freight_terms_code IS NULL THEN
        p_x_header_rec.freight_terms_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.fulfillment_set_name IS NULL THEN
        p_x_header_rec.fulfillment_set_name := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.global_attribute1 IS NULL THEN
        p_x_header_rec.global_attribute1 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.global_attribute10 IS NULL THEN
        p_x_header_rec.global_attribute10 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.global_attribute11 IS NULL THEN
        p_x_header_rec.global_attribute11 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.global_attribute12 IS NULL THEN
        p_x_header_rec.global_attribute12 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.global_attribute13 IS NULL THEN
        p_x_header_rec.global_attribute13 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.global_attribute14 IS NULL THEN
        p_x_header_rec.global_attribute14 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.global_attribute15 IS NULL THEN
        p_x_header_rec.global_attribute15 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.global_attribute16 IS NULL THEN
        p_x_header_rec.global_attribute16 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.global_attribute17 IS NULL THEN
        p_x_header_rec.global_attribute17 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.global_attribute18 IS NULL THEN
        p_x_header_rec.global_attribute18 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.global_attribute19 IS NULL THEN
        p_x_header_rec.global_attribute19 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.global_attribute2 IS NULL THEN
        p_x_header_rec.global_attribute2 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.global_attribute20 IS NULL THEN
        p_x_header_rec.global_attribute20 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.global_attribute3 IS NULL THEN
        p_x_header_rec.global_attribute3 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.global_attribute4 IS NULL THEN
        p_x_header_rec.global_attribute4 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.global_attribute5 IS NULL THEN
        p_x_header_rec.global_attribute5 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.global_attribute6 IS NULL THEN
        p_x_header_rec.global_attribute6 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.global_attribute7 IS NULL THEN
        p_x_header_rec.global_attribute7 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.global_attribute8 IS NULL THEN
        p_x_header_rec.global_attribute8 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.global_attribute9 IS NULL THEN
        p_x_header_rec.global_attribute9 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.global_attribute_category IS NULL THEN
        p_x_header_rec.global_attribute_category := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.header_id IS NULL THEN
        p_x_header_rec.header_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.invoice_to_contact_id IS NULL THEN
        p_x_header_rec.invoice_to_contact_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.invoice_to_org_id IS NULL THEN
        p_x_header_rec.invoice_to_org_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.invoicing_rule_id IS NULL THEN
        p_x_header_rec.invoicing_rule_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.last_updated_by IS NULL THEN
        p_x_header_rec.last_updated_by :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.last_update_date IS NULL THEN
        p_x_header_rec.last_update_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_header_rec.last_update_login IS NULL THEN
        p_x_header_rec.last_update_login :=  FND_API.G_MISS_NUM;
    END IF;


    IF p_x_header_rec.latest_schedule_limit IS NULL THEN
        p_x_header_rec.latest_schedule_limit :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.line_set_name IS NULL THEN
        p_x_header_rec.line_set_name := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.open_flag IS NULL THEN
        p_x_header_rec.open_flag := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.ordered_date IS NULL THEN
        p_x_header_rec.ordered_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_header_rec.order_date_type_code IS NULL THEN
        p_x_header_rec.order_date_type_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.order_number IS NULL THEN
        p_x_header_rec.order_number :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.order_source_id IS NULL THEN
        p_x_header_rec.order_source_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.order_type_id IS NULL THEN
        p_x_header_rec.order_type_id :=  FND_API.G_MISS_NUM;
    END IF;
    IF p_x_header_rec.order_category_code IS NULL THEN
        p_x_header_rec.order_category_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.org_id IS NULL THEN
        p_x_header_rec.org_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.orig_sys_document_ref IS NULL THEN
        p_x_header_rec.orig_sys_document_ref := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.partial_shipments_allowed IS NULL THEN
        p_x_header_rec.partial_shipments_allowed := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.payment_term_id IS NULL THEN
        p_x_header_rec.payment_term_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.price_list_id IS NULL THEN
        p_x_header_rec.price_list_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.price_request_code IS NULL THEN  -- PROMOTIONS SEP/01
        p_x_header_rec.price_request_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.pricing_date IS NULL THEN
        p_x_header_rec.pricing_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_header_rec.program_application_id IS NULL THEN
        p_x_header_rec.program_application_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.program_id IS NULL THEN
        p_x_header_rec.program_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.program_update_date IS NULL THEN
        p_x_header_rec.program_update_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_header_rec.request_date IS NULL THEN
        p_x_header_rec.request_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_header_rec.request_id IS NULL THEN
        p_x_header_rec.request_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.return_reason_code IS NULL THEN
        p_x_header_rec.return_reason_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.salesrep_id IS NULL THEN
        p_x_header_rec.salesrep_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.sales_channel_code IS NULL THEN
        p_x_header_rec.sales_channel_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.shipment_priority_code IS NULL THEN
        p_x_header_rec.shipment_priority_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.shipping_method_code IS NULL THEN
        p_x_header_rec.shipping_method_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.ship_from_org_id IS NULL THEN
        p_x_header_rec.ship_from_org_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.ship_tolerance_above IS NULL THEN
        p_x_header_rec.ship_tolerance_above :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.ship_tolerance_below IS NULL THEN
        p_x_header_rec.ship_tolerance_below :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.ship_to_contact_id IS NULL THEN
        p_x_header_rec.ship_to_contact_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.ship_to_org_id IS NULL THEN
        p_x_header_rec.ship_to_org_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.sold_from_org_id IS NULL THEN
        p_x_header_rec.sold_from_org_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.sold_to_contact_id IS NULL THEN
        p_x_header_rec.sold_to_contact_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.sold_to_org_id IS NULL THEN
        p_x_header_rec.sold_to_org_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.sold_to_phone_id IS NULL THEN
        p_x_header_rec.sold_to_phone_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.source_document_id IS NULL THEN
        p_x_header_rec.source_document_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.source_document_type_id IS NULL THEN
        p_x_header_rec.source_document_type_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.tax_exempt_flag IS NULL THEN
        p_x_header_rec.tax_exempt_flag := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.tax_exempt_number IS NULL THEN
        p_x_header_rec.tax_exempt_number := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.tax_exempt_reason_code IS NULL THEN
        p_x_header_rec.tax_exempt_reason_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.tax_point_code IS NULL THEN
        p_x_header_rec.tax_point_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.transactional_curr_code IS NULL THEN
        p_x_header_rec.transactional_curr_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.version_number IS NULL THEN
        p_x_header_rec.version_number :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.payment_type_code IS NULL THEN
        p_x_header_rec.payment_type_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.payment_amount IS NULL THEN
        p_x_header_rec.payment_amount :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.check_number IS NULL THEN
        p_x_header_rec.check_number := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.credit_card_code IS NULL THEN
        p_x_header_rec.credit_card_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.credit_card_holder_name IS NULL THEN
        p_x_header_rec.credit_card_holder_name := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.credit_card_number IS NULL THEN
        p_x_header_rec.credit_card_number := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.credit_card_expiration_date IS NULL THEN
        p_x_header_rec.credit_card_expiration_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_header_rec.credit_card_approval_date IS NULL THEN
        p_x_header_rec.credit_card_approval_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_header_rec.credit_card_approval_code IS NULL THEN
        p_x_header_rec.credit_card_approval_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.first_ack_code IS NULL THEN
        p_x_header_rec.first_ack_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.first_ack_date IS NULL THEN
        p_x_header_rec.first_ack_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_header_rec.last_ack_code IS NULL THEN
        p_x_header_rec.last_ack_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.last_ack_date IS NULL THEN
        p_x_header_rec.last_ack_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_header_rec.shipping_instructions IS NULL THEN
        p_x_header_rec.shipping_instructions := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.packing_instructions IS NULL THEN
        p_x_header_rec.packing_instructions := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.flow_status_code IS NULL THEN
        p_x_header_rec.flow_status_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.marketing_source_code_id IS NULL THEN
        p_x_header_rec.marketing_source_code_id :=  FND_API.G_MISS_NUM;
    END IF;

     IF p_x_header_rec.change_sequence IS NULL THEN --2416561
        p_x_header_rec.change_sequence := FND_API.G_MISS_CHAR;
    END IF;

    -- QUOTING changes

    IF p_x_header_rec.quote_date IS NULL THEN
        p_x_header_rec.quote_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_header_rec.quote_number IS NULL THEN
        p_x_header_rec.quote_number :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.sales_document_name IS NULL THEN
        p_x_header_rec.sales_document_name := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.transaction_phase_code IS NULL THEN
        p_x_header_rec.transaction_phase_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.user_status_code IS NULL THEN
        p_x_header_rec.user_status_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.draft_submitted_flag IS NULL THEN
        p_x_header_rec.draft_submitted_flag := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.source_document_version_number IS NULL THEN
        p_x_header_rec.source_document_version_number :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.sold_to_site_use_id IS NULL THEN
        p_x_header_rec.sold_to_site_use_id :=  FND_API.G_MISS_NUM;
    END IF;

    -- QUOTING changes END

    IF p_x_header_rec.Minisite_id IS NULL THEN
        p_x_header_rec.Minisite_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.End_customer_id IS NULL THEN
        p_x_header_rec.End_customer_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.End_customer_contact_id IS NULL THEN
        p_x_header_rec.End_customer_contact_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.End_customer_site_use_id IS NULL THEN
        p_x_header_rec.End_customer_site_use_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.Ib_owner IS NULL THEN
        p_x_header_rec.Ib_owner := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.Ib_installed_at_location IS NULL THEN
        p_x_header_rec.Ib_installed_at_location := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.Ib_current_location IS NULL THEN
        p_x_header_rec.Ib_current_location := FND_API.G_MISS_CHAR;
    END IF;

   IF p_x_header_rec.supplier_signature IS NULL THEN
        p_x_header_rec.supplier_signature := FND_API.G_MISS_CHAR;
    END IF;

   IF p_x_header_rec.supplier_signature_date IS NULL THEN
        p_x_header_rec.supplier_signature_date := FND_API.G_MISS_DATE;
    END IF;

   IF p_x_header_rec.customer_signature IS NULL THEN
        p_x_header_rec.customer_signature := FND_API.G_MISS_CHAR;
    END IF;

  IF p_x_header_rec.customer_signature_date IS NULL THEN
        p_x_header_rec.customer_signature_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_header_rec.contract_template_id IS NULL THEN
        p_x_header_rec.contract_template_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_header_rec.contract_source_doc_type_code IS NULL THEN
        p_x_header_rec.contract_source_doc_type_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_header_rec.contract_source_document_id IS NULL THEN
        p_x_header_rec.contract_source_document_id :=  FND_API.G_MISS_NUM;
    END IF;

--key Transaction dates
    IF p_x_header_rec.order_firmed_date IS NULL THEN
        p_x_header_rec.order_firmed_date := FND_API.G_MISS_DATE;
    END IF;

    oe_debug_pub.add('Exiting Convert_hdr_null_to_miss', 1);


END Convert_hdr_null_to_miss;



--  Procedure Convert_hdr_payment_null_to_miss

PROCEDURE Convert_hdr_pymnt_null_to_miss
(   p_x_Header_Payment_rec  IN OUT NOCOPY  OE_Order_PUB.Header_Payment_Rec_Type
)
IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    oe_debug_pub.add('Entering OE_GENESIS_UTIL.Convert_hdr_pymnt_null_to_miss', 1);

    IF p_x_Header_Payment_rec.attribute1 IS NULL THEN
        p_x_Header_Payment_rec.attribute1 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.attribute2 IS NULL THEN
        p_x_Header_Payment_rec.attribute2 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.attribute3 IS NULL THEN
        p_x_Header_Payment_rec.attribute3 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.attribute4 IS NULL THEN
        p_x_Header_Payment_rec.attribute4 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.attribute5 IS NULL THEN
        p_x_Header_Payment_rec.attribute5 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.attribute6 IS NULL THEN
        p_x_Header_Payment_rec.attribute6 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.attribute7 IS NULL THEN
        p_x_Header_Payment_rec.attribute7 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.attribute8 IS NULL THEN
        p_x_Header_Payment_rec.attribute8 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.attribute9 IS NULL THEN
        p_x_Header_Payment_rec.attribute9 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.attribute10 IS NULL THEN
        p_x_Header_Payment_rec.attribute10 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.attribute11 IS NULL THEN
        p_x_Header_Payment_rec.attribute11 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.attribute12 IS NULL THEN
        p_x_Header_Payment_rec.attribute12 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.attribute13 IS NULL THEN
        p_x_Header_Payment_rec.attribute13 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.attribute14 IS NULL THEN
        p_x_Header_Payment_rec.attribute14 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.attribute15 IS NULL THEN
        p_x_Header_Payment_rec.attribute15 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.context IS NULL THEN
        p_x_Header_Payment_rec.context := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.created_by IS NULL THEN
        p_x_Header_Payment_rec.created_by :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_Header_Payment_rec.creation_date IS NULL THEN
        p_x_Header_Payment_rec.creation_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_Header_Payment_rec.last_updated_by IS NULL THEN
        p_x_Header_Payment_rec.last_updated_by :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_Header_Payment_rec.last_update_date IS NULL THEN
        p_x_Header_Payment_rec.last_update_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_Header_Payment_rec.last_update_login IS NULL THEN
        p_x_Header_Payment_rec.last_update_login :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_Header_Payment_rec.check_number IS NULL THEN
        p_x_Header_Payment_rec.check_number := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.credit_card_approval_code IS NULL THEN
        p_x_Header_Payment_rec.credit_card_approval_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.credit_card_approval_date IS NULL THEN
        p_x_Header_Payment_rec.credit_card_approval_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_Header_Payment_rec.credit_card_code IS NULL THEN
        p_x_Header_Payment_rec.credit_card_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.credit_card_expiration_date IS NULL THEN
        p_x_Header_Payment_rec.credit_card_expiration_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_Header_Payment_rec.credit_card_holder_name IS NULL THEN
        p_x_Header_Payment_rec.credit_card_holder_name := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.credit_card_number IS NULL THEN
        p_x_Header_Payment_rec.credit_card_number := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.payment_level_code IS NULL THEN
        p_x_Header_Payment_rec.payment_level_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.commitment_applied_amount IS NULL THEN
        p_x_Header_Payment_rec.commitment_applied_amount :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_Header_Payment_rec.commitment_interfaced_amount IS NULL THEN
        p_x_Header_Payment_rec.commitment_interfaced_amount :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_Header_Payment_rec.payment_number IS NULL THEN
        p_x_Header_Payment_rec.payment_number :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_Header_Payment_rec.header_id IS NULL THEN
        p_x_Header_Payment_rec.header_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_Header_Payment_rec.line_id IS NULL THEN
        p_x_Header_Payment_rec.line_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_Header_Payment_rec.payment_amount IS NULL THEN
        p_x_Header_Payment_rec.payment_amount :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_Header_Payment_rec.payment_collection_event IS NULL THEN
        p_x_Header_Payment_rec.payment_collection_event := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.defer_payment_processing_flag IS NULL THEN
        p_x_Header_Payment_rec.defer_payment_processing_flag := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.payment_trx_id IS NULL THEN
        p_x_Header_Payment_rec.payment_trx_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_Header_Payment_rec.payment_type_code IS NULL THEN
        p_x_Header_Payment_rec.payment_type_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_Header_Payment_rec.payment_set_id IS NULL THEN
        p_x_Header_Payment_rec.payment_set_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_Header_Payment_rec.prepaid_amount IS NULL THEN
        p_x_Header_Payment_rec.prepaid_amount :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_Header_Payment_rec.program_application_id IS NULL THEN
        p_x_Header_Payment_rec.program_application_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_Header_Payment_rec.program_id IS NULL THEN
        p_x_Header_Payment_rec.program_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_Header_Payment_rec.program_update_date IS NULL THEN
        p_x_Header_Payment_rec.program_update_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_Header_Payment_rec.receipt_method_id IS NULL THEN
        p_x_Header_Payment_rec.receipt_method_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_Header_Payment_rec.request_id IS NULL THEN
        p_x_Header_Payment_rec.request_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_Header_Payment_rec.tangible_id IS NULL THEN
        p_x_Header_Payment_rec.tangible_id := FND_API.G_MISS_CHAR;
    END IF;

    oe_debug_pub.add('Exiting OE_GENESIS_UTIL.Convert_hdr_pymnt_null_to_miss', 1);

END Convert_hdr_pymnt_null_to_miss;





/*-----------------------------------------------------------
PROCEDURE Convert_Line_null_to_miss
-----------------------------------------------------------*/

PROCEDURE Convert_Line_null_to_miss
(   p_x_line_rec                    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
)
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_GENESIS_UTIL.Convert_Line_null_to_miss', 1);
  end if;

    IF p_x_line_rec.unit_cost IS NULL THEN
        p_x_line_rec.unit_cost :=  FND_API.G_MISS_NUM;
    END IF;

   -- Bug 8841055
   IF p_x_line_rec.split_action_code IS NULL THEN
     p_x_line_rec.split_action_code := Fnd_Api.G_Miss_Char;
   END IF;


    IF p_x_line_rec.accounting_rule_id IS NULL THEN
        p_x_line_rec.accounting_rule_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.accounting_rule_duration IS NULL THEN
        p_x_line_rec.accounting_rule_duration :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.actual_arrival_date IS NULL THEN
        p_x_line_rec.actual_arrival_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_line_rec.actual_shipment_date IS NULL THEN
        p_x_line_rec.actual_shipment_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_line_rec.agreement_id IS NULL THEN
        p_x_line_rec.agreement_id :=  FND_API.G_MISS_NUM;
    END IF;

--Added for 10182413...
    IF p_x_line_rec.reserved_quantity IS NULL THEN
	p_x_line_rec.reserved_quantity :=  FND_API.G_MISS_NUM;
    END IF;
 -- End  of 10182413


    IF p_x_line_rec.arrival_set_id IS NULL THEN
        p_x_line_rec.arrival_set_id :=  FND_API.G_MISS_NUM;
    END IF;

-- Start: Fix 8530507
    -------------------
    IF p_x_line_rec.operation = Oe_Globals.G_Opr_Update THEN
      oe_debug_pub.ADD(' cnv line null to miss: Operation is.... UPDATE on line: '
                           || p_x_line_rec.line_id);
      DECLARE
        l_old_arrival_set_id oe_order_lines_all.arrival_set_id%TYPE;
      BEGIN
        oe_debug_pub.ADD(' cnv line null to miss: Location 11...');
        SELECT  l.arrival_set_id
            INTO  l_old_arrival_set_id
        FROM    oe_order_lines_all l
        WHERE   l.line_id = p_x_line_rec.line_id;
        oe_debug_pub.ADD(' cnv line null to miss: l_old_arrival_set = ' || l_old_arrival_set_id);

        IF Nvl(l_old_arrival_set_id, Fnd_Api.G_Miss_Num) <> Fnd_Api.G_Miss_Num
        THEN
          --  The line has already been a part of shipset.  The user really
          --  intended to remove it from the arrival set, if at all they had set
          --  p_x_line_rec.arrival_set to a NULL.  Explicitly check for this case
          --  and assign a NULL to arrival_set_id.
          oe_debug_pub.ADD(' cnv line null to miss: Location 12...');
          IF p_x_line_rec.arrival_set IS NULL THEN
            oe_debug_pub.ADD(' cnv line null to miss: Location 13...');
            p_x_line_rec.arrival_set_id  :=  NULL;
          END IF;
        ELSE
          -- This line is being put afresh into an existing arrival set.
          -- In this case, we:
          --    check whether p_x_line_rec.arrival_set is not-null;
          IF p_x_line_rec.arrival_set IS NOT NULL THEN

            --  derive its arrival_set_id from table: oe_sets;
            SELECT  DISTINCT set_id INTO l_old_arrival_set_id
            FROM    oe_sets
            WHERE   set_type  = 'ARRIVAL_SET'
            AND     header_id = p_x_line_rec.header_id
            AND     set_name  = p_x_line_rec.arrival_set;

            --   stamp the derived arrival_set_id on p_x_line_rec.arrival_set_id
            p_x_line_rec.arrival_set_id  :=  l_old_arrival_set_id;
          -- 10171747
          ELSE -- that is, when p_x_line_rec.arrival_set is null in update mode.
            p_x_line_rec.arrival_set := Fnd_Api.G_Miss_Char;
          -- 10171747
          END IF;
        END IF; -- Check on l_old_arrival_set_id
      EXCEPTION
        WHEN Others THEN
          IF p_x_line_rec.arrival_set_id IS NULL THEN
            p_x_line_rec.arrival_set_id := fnd_api.g_miss_num;
          END IF;

          -- 10171747
          IF p_x_line_rec.arrival_set IS NULL THEN
            p_x_line_rec.arrival_set := Fnd_Api.G_Miss_Char;
          END IF;
          -- 10171747
          oe_debug_pub.ADD('Exception occurred at OEXUGNIB Loc 14: ' || SQLERRM);
      END;
    ELSE  -- For entity operations other than UPDATE.
      oe_debug_pub.ADD(' cnv line null to miss: Location 15...');
      IF p_x_line_rec.arrival_set_id IS NULL THEN
        p_x_line_rec.arrival_set_id  :=  Fnd_Api.G_Miss_Num;
      END IF;

      -- 10171747
      IF p_x_line_rec.arrival_set IS NULL THEN
        p_x_line_rec.arrival_set := Fnd_Api.G_Miss_Char;
      END IF;
      -- 10171747

    END IF; -- Operation code check for UPDATE.
    -------------------
-- End: Fix 8530507

-- Start: Fix 9874630
-- This is commented out in favour of the efficient solution
-- implemented during 10171747.
/*
    IF p_x_line_rec.operation = Oe_Globals.G_Opr_Update THEN
      DECLARE
        l_old_arrival_set oe_sets.set_name%TYPE := null;
      BEGIN
        -- Get existing arrival set.
        SELECT  set_name
        INTO    l_old_arrival_set
        FROM    oe_sets s,
                oe_order_lines_all l
        WHERE   s.set_type  = 'ARRIVAL_SET'
        AND     l.arrival_set_id = s.set_id
        AND     l.line_id = p_x_line_rec.line_id;

        -- If existing value and incoming value are same, set it to miss char
        IF l_old_arrival_set = p_x_line_rec.arrival_set THEN
              p_x_line_rec.arrival_set  := Fnd_Api.G_Miss_Char;
        END IF;

      EXCEPTION
        -- If there is no ship set before and incoming value is also null
        -- set it to miss Char
        WHEN Others THEN  -- including NO_DATA_FOUND
          IF p_x_line_rec.arrival_set IS NULL THEN
            p_x_line_rec.arrival_set := fnd_api.g_miss_Char;
          END IF;
      END;
    END IF; -- Additional operation code check for UPDATE.
*/
-- End: Fix 9874630


    IF p_x_line_rec.ato_line_id IS NULL THEN
        p_x_line_rec.ato_line_id :=  FND_API.G_MISS_NUM;
    END IF;
    IF p_x_line_rec.upgraded_flag IS NULL THEN
        p_x_line_rec.upgraded_flag := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.attribute1 IS NULL THEN
        p_x_line_rec.attribute1 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.attribute10 IS NULL THEN
        p_x_line_rec.attribute10 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.attribute11 IS NULL THEN
        p_x_line_rec.attribute11 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.attribute12 IS NULL THEN
        p_x_line_rec.attribute12 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.attribute13 IS NULL THEN
        p_x_line_rec.attribute13 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.attribute14 IS NULL THEN
        p_x_line_rec.attribute14 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.attribute15 IS NULL THEN
        p_x_line_rec.attribute15 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.attribute16 IS NULL THEN    --For bug 2184255
        p_x_line_rec.attribute16 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.attribute17 IS NULL THEN
        p_x_line_rec.attribute17 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.attribute18 IS NULL THEN
        p_x_line_rec.attribute18 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.attribute19 IS NULL THEN
        p_x_line_rec.attribute19 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.attribute2 IS NULL THEN
        p_x_line_rec.attribute2 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.attribute20 IS NULL THEN
        p_x_line_rec.attribute20 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.attribute3 IS NULL THEN
        p_x_line_rec.attribute3 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.attribute4 IS NULL THEN
        p_x_line_rec.attribute4 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.attribute5 IS NULL THEN
        p_x_line_rec.attribute5 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.attribute6 IS NULL THEN
        p_x_line_rec.attribute6 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.attribute7 IS NULL THEN
        p_x_line_rec.attribute7 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.attribute8 IS NULL THEN
        p_x_line_rec.attribute8 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.attribute9 IS NULL THEN
        p_x_line_rec.attribute9 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.auto_selected_quantity IS NULL THEN
        p_x_line_rec.auto_selected_quantity :=  FND_API.G_MISS_NUM;
    END IF;
     IF p_x_line_rec.authorized_to_ship_flag IS NULL THEN
        p_x_line_rec.authorized_to_ship_flag := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.booked_flag IS NULL THEN
        p_x_line_rec.booked_flag := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.cancelled_flag IS NULL THEN
        p_x_line_rec.cancelled_flag := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.cancelled_quantity IS NULL THEN
        p_x_line_rec.cancelled_quantity :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.component_code IS NULL THEN
        p_x_line_rec.component_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.component_number IS NULL THEN
        p_x_line_rec.component_number :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.component_sequence_id IS NULL THEN
        p_x_line_rec.component_sequence_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.config_header_id IS NULL THEN
        p_x_line_rec.config_header_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.config_rev_nbr IS NULL THEN
        p_x_line_rec.config_rev_nbr :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.config_display_sequence IS NULL THEN
        p_x_line_rec.config_display_sequence :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.configuration_id IS NULL THEN
        p_x_line_rec.configuration_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.context IS NULL THEN
        p_x_line_rec.context := FND_API.G_MISS_CHAR;
    END IF;





    IF p_x_line_rec.created_by IS NULL THEN
        p_x_line_rec.created_by :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.creation_date IS NULL THEN
        p_x_line_rec.creation_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_line_rec.credit_invoice_line_id IS NULL THEN
        p_x_line_rec.credit_invoice_line_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.customer_dock_code IS NULL THEN
        p_x_line_rec.customer_dock_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.customer_job IS NULL THEN
        p_x_line_rec.customer_job := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.customer_production_line IS NULL THEN
        p_x_line_rec.customer_production_line := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.cust_production_seq_num IS NULL THEN
        p_x_line_rec.cust_production_seq_num := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.customer_trx_line_id IS NULL THEN
        p_x_line_rec.customer_trx_line_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.cust_model_serial_number IS NULL THEN
        p_x_line_rec.cust_model_serial_number := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.cust_po_number IS NULL THEN
        p_x_line_rec.cust_po_number := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.customer_line_number IS NULL THEN
        p_x_line_rec.customer_line_number := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.customer_shipment_number IS NULL THEN
        p_x_line_rec.customer_shipment_number := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.delivery_lead_time IS NULL THEN
        p_x_line_rec.delivery_lead_time :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.deliver_to_contact_id IS NULL THEN
        p_x_line_rec.deliver_to_contact_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.deliver_to_org_id IS NULL THEN
        p_x_line_rec.deliver_to_org_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.demand_bucket_type_code IS NULL THEN
        p_x_line_rec.demand_bucket_type_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.demand_class_code IS NULL THEN
        p_x_line_rec.demand_class_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.dep_plan_required_flag IS NULL THEN
        p_x_line_rec.dep_plan_required_flag := FND_API.G_MISS_CHAR;
    END IF;


    IF p_x_line_rec.earliest_acceptable_date IS NULL THEN
        p_x_line_rec.earliest_acceptable_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_line_rec.explosion_date IS NULL THEN
        p_x_line_rec.explosion_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_line_rec.fob_point_code IS NULL THEN
        p_x_line_rec.fob_point_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.freight_carrier_code IS NULL THEN
        p_x_line_rec.freight_carrier_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.freight_terms_code IS NULL THEN
        p_x_line_rec.freight_terms_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.fulfilled_quantity IS NULL THEN
        p_x_line_rec.fulfilled_quantity :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.fulfilled_flag IS NULL THEN
        p_x_line_rec.fulfilled_flag := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.fulfillment_method_code IS NULL THEN
        p_x_line_rec.fulfillment_method_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.fulfillment_date IS NULL THEN
        p_x_line_rec.fulfillment_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_line_rec.global_attribute1 IS NULL THEN
        p_x_line_rec.global_attribute1 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.global_attribute10 IS NULL THEN
        p_x_line_rec.global_attribute10 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.global_attribute11 IS NULL THEN
        p_x_line_rec.global_attribute11 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.global_attribute12 IS NULL THEN
        p_x_line_rec.global_attribute12 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.global_attribute13 IS NULL THEN
        p_x_line_rec.global_attribute13 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.global_attribute14 IS NULL THEN
        p_x_line_rec.global_attribute14 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.global_attribute15 IS NULL THEN
        p_x_line_rec.global_attribute15 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.global_attribute16 IS NULL THEN
        p_x_line_rec.global_attribute16 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.global_attribute17 IS NULL THEN
        p_x_line_rec.global_attribute17 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.global_attribute18 IS NULL THEN
        p_x_line_rec.global_attribute18 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.global_attribute19 IS NULL THEN
        p_x_line_rec.global_attribute19 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.global_attribute2 IS NULL THEN
        p_x_line_rec.global_attribute2 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.global_attribute20 IS NULL THEN
        p_x_line_rec.global_attribute20 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.global_attribute3 IS NULL THEN
        p_x_line_rec.global_attribute3 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.global_attribute4 IS NULL THEN
        p_x_line_rec.global_attribute4 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.global_attribute5 IS NULL THEN
        p_x_line_rec.global_attribute5 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.global_attribute6 IS NULL THEN
        p_x_line_rec.global_attribute6 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.global_attribute7 IS NULL THEN
        p_x_line_rec.global_attribute7 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.global_attribute8 IS NULL THEN
        p_x_line_rec.global_attribute8 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.global_attribute9 IS NULL THEN
        p_x_line_rec.global_attribute9 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.global_attribute_category IS NULL THEN
        p_x_line_rec.global_attribute_category := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.header_id IS NULL THEN
        p_x_line_rec.header_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.industry_attribute1 IS NULL THEN
        p_x_line_rec.industry_attribute1 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.industry_attribute10 IS NULL THEN
        p_x_line_rec.industry_attribute10 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.industry_attribute11 IS NULL THEN
        p_x_line_rec.industry_attribute11 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.industry_attribute12 IS NULL THEN
        p_x_line_rec.industry_attribute12 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.industry_attribute13 IS NULL THEN
        p_x_line_rec.industry_attribute13 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.industry_attribute14 IS NULL THEN
        p_x_line_rec.industry_attribute14 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.industry_attribute15 IS NULL THEN
        p_x_line_rec.industry_attribute15 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.industry_attribute16 IS NULL THEN
        p_x_line_rec.industry_attribute16 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.industry_attribute17 IS NULL THEN
        p_x_line_rec.industry_attribute17 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.industry_attribute18 IS NULL THEN
        p_x_line_rec.industry_attribute18 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.industry_attribute19 IS NULL THEN
        p_x_line_rec.industry_attribute19 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.industry_attribute20 IS NULL THEN
        p_x_line_rec.industry_attribute20 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.industry_attribute21 IS NULL THEN
        p_x_line_rec.industry_attribute21 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.industry_attribute22 IS NULL THEN
        p_x_line_rec.industry_attribute22 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.industry_attribute23 IS NULL THEN
        p_x_line_rec.industry_attribute23 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.industry_attribute24 IS NULL THEN
        p_x_line_rec.industry_attribute24 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.industry_attribute25 IS NULL THEN
        p_x_line_rec.industry_attribute25 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.industry_attribute26 IS NULL THEN
        p_x_line_rec.industry_attribute26 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.industry_attribute27 IS NULL THEN
        p_x_line_rec.industry_attribute27 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.industry_attribute28 IS NULL THEN
        p_x_line_rec.industry_attribute28 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.industry_attribute29 IS NULL THEN
        p_x_line_rec.industry_attribute29 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.industry_attribute30 IS NULL THEN
        p_x_line_rec.industry_attribute30 := FND_API.G_MISS_CHAR;
    END IF;


    IF p_x_line_rec.industry_attribute2 IS NULL THEN
        p_x_line_rec.industry_attribute2 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.industry_attribute3 IS NULL THEN
        p_x_line_rec.industry_attribute3 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.industry_attribute4 IS NULL THEN
        p_x_line_rec.industry_attribute4 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.industry_attribute5 IS NULL THEN
        p_x_line_rec.industry_attribute5 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.industry_attribute6 IS NULL THEN
        p_x_line_rec.industry_attribute6 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.industry_attribute7 IS NULL THEN
        p_x_line_rec.industry_attribute7 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.industry_attribute8 IS NULL THEN
        p_x_line_rec.industry_attribute8 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.industry_attribute9 IS NULL THEN
        p_x_line_rec.industry_attribute9 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.industry_context IS NULL THEN
        p_x_line_rec.industry_context := FND_API.G_MISS_CHAR;
    END IF;

    /* TP_ATTRIBUTE */
    IF p_x_line_rec.tp_context IS NULL THEN
        p_x_line_rec.tp_context := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.tp_attribute1 IS NULL THEN
        p_x_line_rec.tp_attribute1 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.tp_attribute2 IS NULL THEN
        p_x_line_rec.tp_attribute2 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.tp_attribute3 IS NULL THEN
        p_x_line_rec.tp_attribute3 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.tp_attribute4 IS NULL THEN
        p_x_line_rec.tp_attribute4 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.tp_attribute5 IS NULL THEN
        p_x_line_rec.tp_attribute5 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.tp_attribute6 IS NULL THEN
        p_x_line_rec.tp_attribute6 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.tp_attribute7 IS NULL THEN
        p_x_line_rec.tp_attribute7 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.tp_attribute8 IS NULL THEN
        p_x_line_rec.tp_attribute8 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.tp_attribute9 IS NULL THEN
        p_x_line_rec.tp_attribute9 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.tp_attribute10 IS NULL THEN
        p_x_line_rec.tp_attribute10 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.tp_attribute11 IS NULL THEN
        p_x_line_rec.tp_attribute11 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.tp_attribute12 IS NULL THEN
        p_x_line_rec.tp_attribute12 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.tp_attribute13 IS NULL THEN
        p_x_line_rec.tp_attribute13 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.tp_attribute14 IS NULL THEN
        p_x_line_rec.tp_attribute14 := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.tp_attribute15 IS NULL THEN
        p_x_line_rec.tp_attribute15 := FND_API.G_MISS_CHAR;
    END IF;


    IF p_x_line_rec.intermed_ship_to_contact_id IS NULL THEN
        p_x_line_rec.intermed_ship_to_contact_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.intermed_ship_to_org_id IS NULL THEN
        p_x_line_rec.intermed_ship_to_org_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.inventory_item_id IS NULL THEN
        p_x_line_rec.inventory_item_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.invoice_interface_status_code IS NULL THEN
        p_x_line_rec.invoice_interface_status_code := FND_API.G_MISS_CHAR;
    END IF;



    IF p_x_line_rec.invoice_to_contact_id IS NULL THEN
        p_x_line_rec.invoice_to_contact_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.invoiced_quantity IS NULL THEN
        p_x_line_rec.invoiced_quantity :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.invoice_to_org_id IS NULL THEN
        p_x_line_rec.invoice_to_org_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.invoicing_rule_id IS NULL THEN
        p_x_line_rec.invoicing_rule_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.ordered_item_id IS NULL THEN
        p_x_line_rec.ordered_item_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.item_identifier_type IS NULL THEN
        p_x_line_rec.item_identifier_type := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.ordered_item IS NULL THEN
        p_x_line_rec.ordered_item := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.item_revision IS NULL THEN
        p_x_line_rec.item_revision := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.item_type_code IS NULL THEN
        p_x_line_rec.item_type_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.last_updated_by IS NULL THEN
        p_x_line_rec.last_updated_by :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.last_update_date IS NULL THEN
        p_x_line_rec.last_update_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_line_rec.last_update_login IS NULL THEN
        p_x_line_rec.last_update_login :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.latest_acceptable_date IS NULL THEN
        p_x_line_rec.latest_acceptable_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_line_rec.line_category_code IS NULL THEN
        p_x_line_rec.line_category_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.line_id IS NULL THEN
        p_x_line_rec.line_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.line_number IS NULL THEN
        p_x_line_rec.line_number :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.line_type_id IS NULL THEN
        p_x_line_rec.line_type_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.link_to_line_id IS NULL THEN
        p_x_line_rec.link_to_line_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.model_group_number IS NULL THEN
        p_x_line_rec.model_group_number :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.mfg_component_sequence_id IS NULL THEN
        p_x_line_rec.mfg_component_sequence_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.mfg_lead_time IS NULL THEN
        p_x_line_rec.mfg_lead_time :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.open_flag IS NULL THEN
        p_x_line_rec.open_flag := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.option_flag IS NULL THEN
        p_x_line_rec.option_flag := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.option_number IS NULL THEN
        p_x_line_rec.option_number :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.ordered_quantity IS NULL THEN
        p_x_line_rec.ordered_quantity :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.order_quantity_uom IS NULL THEN
        p_x_line_rec.order_quantity_uom := FND_API.G_MISS_CHAR;
    END IF;

    -- OPM 02/JUN/00 - Deal with process attributes
    -- IS===========================================
    IF p_x_line_rec.ordered_quantity2 IS NULL THEN
        p_x_line_rec.ordered_quantity2 :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.ordered_quantity_uom2 IS NULL THEN
        p_x_line_rec.ordered_quantity_uom2 := FND_API.G_MISS_CHAR;
    END IF;
    -- OPM 02/JUN/00 - END
    -- IS==================

    IF p_x_line_rec.org_id IS NULL THEN
        p_x_line_rec.org_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.orig_sys_document_ref IS NULL THEN
        p_x_line_rec.orig_sys_document_ref := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.orig_sys_line_ref IS NULL THEN
        p_x_line_rec.orig_sys_line_ref := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.orig_sys_shipment_ref IS NULL THEN
        p_x_line_rec.orig_sys_shipment_ref := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.original_list_price IS NULL THEN
          p_x_line_rec.original_list_price:=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.over_ship_reason_code IS NULL THEN
        p_x_line_rec.over_ship_reason_code := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.over_ship_resolved_flag IS NULL THEN
        p_x_line_rec.over_ship_resolved_flag := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.payment_term_id IS NULL THEN
        p_x_line_rec.payment_term_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.planning_priority IS NULL THEN
        p_x_line_rec.planning_priority :=  FND_API.G_MISS_NUM;
    END IF;

    -- OPM 02/JUN/00 - Deal with process attributes
    -- IS===========================================
    IF p_x_line_rec.preferred_grade IS NULL THEN
        p_x_line_rec.preferred_grade := FND_API.G_MISS_CHAR;
    END IF;
    -- OPM 02/JUN/00 - END
    -- IS==================

    IF p_x_line_rec.price_list_id IS NULL THEN
        p_x_line_rec.price_list_id :=  FND_API.G_MISS_NUM;
    END IF;

     IF p_x_line_rec.price_request_code IS NULL THEN -- PROMOTIONS SEP/01
        p_x_line_rec.price_request_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.pricing_attribute1 IS NULL THEN
        p_x_line_rec.pricing_attribute1 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.pricing_attribute10 IS NULL THEN
        p_x_line_rec.pricing_attribute10 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.pricing_attribute2 IS NULL THEN
        p_x_line_rec.pricing_attribute2 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.pricing_attribute3 IS NULL THEN
        p_x_line_rec.pricing_attribute3 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.pricing_attribute4 IS NULL THEN
        p_x_line_rec.pricing_attribute4 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.pricing_attribute5 IS NULL THEN
        p_x_line_rec.pricing_attribute5 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.pricing_attribute6 IS NULL THEN
        p_x_line_rec.pricing_attribute6 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.pricing_attribute7 IS NULL THEN
        p_x_line_rec.pricing_attribute7 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.pricing_attribute8 IS NULL THEN
        p_x_line_rec.pricing_attribute8 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.pricing_attribute9 IS NULL THEN
        p_x_line_rec.pricing_attribute9 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.pricing_context IS NULL THEN
        p_x_line_rec.pricing_context := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.pricing_date IS NULL THEN
        p_x_line_rec.pricing_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_line_rec.pricing_quantity IS NULL THEN
        p_x_line_rec.pricing_quantity :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.pricing_quantity_uom IS NULL THEN
        p_x_line_rec.pricing_quantity_uom := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.program_application_id IS NULL THEN
        p_x_line_rec.program_application_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.program_id IS NULL THEN
        p_x_line_rec.program_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.program_update_date IS NULL THEN
        p_x_line_rec.program_update_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_line_rec.project_id IS NULL THEN
        p_x_line_rec.project_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.promise_date IS NULL THEN
        p_x_line_rec.promise_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_line_rec.re_source_flag IS NULL THEN
        p_x_line_rec.re_source_flag := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.reference_customer_trx_line_id IS NULL THEN
        p_x_line_rec.reference_customer_trx_line_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.reference_header_id IS NULL THEN
        p_x_line_rec.reference_header_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.reference_line_id IS NULL THEN
        p_x_line_rec.reference_line_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.reference_type IS NULL THEN
        p_x_line_rec.reference_type := FND_API.G_MISS_CHAR;
    END IF;



    IF p_x_line_rec.request_date IS NULL THEN
        p_x_line_rec.request_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_line_rec.request_id IS NULL THEN
        p_x_line_rec.request_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.return_attribute1 IS NULL THEN
        p_x_line_rec.return_attribute1 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.return_attribute10 IS NULL THEN
        p_x_line_rec.return_attribute10 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.return_attribute11 IS NULL THEN
        p_x_line_rec.return_attribute11 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.return_attribute12 IS NULL THEN
        p_x_line_rec.return_attribute12 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.return_attribute13 IS NULL THEN
        p_x_line_rec.return_attribute13 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.return_attribute14 IS NULL THEN
        p_x_line_rec.return_attribute14 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.return_attribute15 IS NULL THEN
        p_x_line_rec.return_attribute15 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.return_attribute2 IS NULL THEN
        p_x_line_rec.return_attribute2 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.return_attribute3 IS NULL THEN
        p_x_line_rec.return_attribute3 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.return_attribute4 IS NULL THEN
        p_x_line_rec.return_attribute4 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.return_attribute5 IS NULL THEN
        p_x_line_rec.return_attribute5 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.return_attribute6 IS NULL THEN
        p_x_line_rec.return_attribute6 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.return_attribute7 IS NULL THEN
        p_x_line_rec.return_attribute7 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.return_attribute8 IS NULL THEN
        p_x_line_rec.return_attribute8 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.return_attribute9 IS NULL THEN
        p_x_line_rec.return_attribute9 := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.return_context IS NULL THEN
        p_x_line_rec.return_context := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.return_reason_code IS NULL THEN
        p_x_line_rec.return_reason_code := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.salesrep_id IS NULL THEN
        p_x_line_rec.salesrep_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.rla_schedule_type_code IS NULL THEN
        p_x_line_rec.rla_schedule_type_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.schedule_arrival_date IS NULL THEN
        p_x_line_rec.schedule_arrival_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_line_rec.schedule_ship_date IS NULL THEN
        p_x_line_rec.schedule_ship_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_line_rec.schedule_action_code IS NULL THEN
        p_x_line_rec.schedule_action_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.schedule_status_code IS NULL THEN
        p_x_line_rec.schedule_status_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.shipment_number IS NULL THEN
        p_x_line_rec.shipment_number :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.shipment_priority_code IS NULL THEN
        p_x_line_rec.shipment_priority_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.shipped_quantity IS NULL THEN
        p_x_line_rec.shipped_quantity :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.shipped_quantity2 IS NULL THEN -- OPM B1661023 04/02/01
        p_x_line_rec.shipped_quantity2 :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.shipping_method_code IS NULL THEN
        p_x_line_rec.shipping_method_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.shipping_quantity IS NULL THEN
        p_x_line_rec.shipping_quantity :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.shipping_quantity2 IS NULL THEN -- OPM B1661023 04/02/01
        p_x_line_rec.shipping_quantity2 :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.shipping_quantity_uom IS NULL THEN
        p_x_line_rec.shipping_quantity_uom := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.ship_from_org_id IS NULL THEN
        p_x_line_rec.ship_from_org_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.subinventory IS NULL THEN
        p_x_line_rec.subinventory := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.ship_model_complete_flag IS NULL THEN
        p_x_line_rec.ship_model_complete_flag := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.ship_set_id IS NULL THEN
        p_x_line_rec.ship_set_id :=  FND_API.G_MISS_NUM;
    END IF;

-- Start: Fix of 8530507
    -------------------
    IF p_x_line_rec.operation = Oe_Globals.G_Opr_Update THEN
      oe_debug_pub.ADD(' cnv line null to miss: Operation is.... UPDATE on line: '
                           || p_x_line_rec.line_id);
      DECLARE
        l_old_ship_set_id oe_order_lines_all.ship_set_id%TYPE;
      BEGIN
        oe_debug_pub.ADD(' cnv line null to miss: Location 1...');
        SELECT  l.ship_set_id
            INTO  l_old_ship_set_id
        FROM    oe_order_lines_all l
        WHERE   l.line_id = p_x_line_rec.line_id;
        oe_debug_pub.ADD(' cnv line null to miss: l_old_ship_set = ' || l_old_ship_set_id);

        IF Nvl(l_old_ship_set_id, Fnd_Api.G_Miss_Num) <> Fnd_Api.G_Miss_Num
        THEN
          --  The line has already been a part of shipset.  The user really
          --  intended to remove it from the shipset, if at all they had set
          --  p_x_line_rec.ship_set to a NULL.  Explicitly check for this case
          --  and assign a NULL to ship_set_id.
          oe_debug_pub.ADD(' cnv line null to miss: Location 2...');
          IF p_x_line_rec.ship_set IS NULL THEN
            oe_debug_pub.ADD(' cnv line null to miss: Location 3...');
            p_x_line_rec.ship_set_id  :=  NULL;
          END IF;
        ELSE
          -- Check whether p_x_line_rec.ship_set is not-null;
          IF p_x_line_rec.ship_set IS NOT NULL THEN

            -- In case it is non-null, derive its ship_set_id from table: oe_sets;
            SELECT  DISTINCT set_id INTO l_old_ship_set_id
            FROM    oe_sets
            WHERE   set_type  = 'SHIP_SET'
            AND     header_id = p_x_line_rec.header_id
            AND     set_name  = p_x_line_rec.ship_set;

            -- Stamp the derived ship_set_id on p_x_line_rec.ship_set_id
            p_x_line_rec.ship_set_id  :=  l_old_ship_set_id;
          -- 10171747
          ELSE -- that is, when p_x_line_rec.ship_set is null.
            p_x_line_rec.ship_set := Fnd_Api.G_Miss_Char;
          -- 10171747
          END IF;
        END IF; -- Check on l_old_ship_set_id
      EXCEPTION
        WHEN Others THEN
          IF p_x_line_rec.ship_set_id IS NULL THEN
            p_x_line_rec.ship_set_id := fnd_api.g_miss_num;
          END IF;
          -- 10171747
          IF p_x_line_rec.ship_set IS NULL THEN
            p_x_line_rec.ship_set := Fnd_Api.G_Miss_Char;
          END IF;
          -- 10171747
          oe_debug_pub.ADD('Exception occurred at OEXUGNIB Loc 4: ' || SQLERRM);
      END;
    ELSE  -- For entity operations other than UPDATE.
      oe_debug_pub.ADD(' cnv line null to miss: Location 5...');
      IF p_x_line_rec.ship_set_id IS NULL THEN
        p_x_line_rec.ship_set_id  :=  Fnd_Api.G_Miss_Num;
      END IF;
      -- 10171747
      IF p_x_line_rec.ship_set IS NULL THEN
        p_x_line_rec.ship_set := Fnd_Api.G_Miss_Char;
      END IF;
      -- 10171747
    END IF; -- Operation code check for UPDATE.
    -------------------
-- End: Fix of 8530507

-- Start: 9874630 Fix
-- This has been commented out during the implementation of efficient
-- solution for 10171747.
    -------------------
/*
    IF p_x_line_rec.operation = Oe_Globals.G_Opr_Update THEN
      DECLARE
        l_old_ship_set oe_sets.set_name%TYPE := null;
      BEGIN
        -- Get existing ship set.
        SELECT  set_name
        INTO    l_old_ship_set
        FROM    oe_sets s,
                oe_order_lines_all l
        WHERE   s.set_type  = 'SHIP_SET'
        AND     l.ship_set_id = s.set_id
        AND     l.line_id = p_x_line_rec.line_id;

        -- If existing value and incoming value are same, set it to miss char
        IF l_old_ship_set = p_x_line_rec.ship_set THEN
              p_x_line_rec.ship_set  := Fnd_Api.G_Miss_Char;
        END IF;

      EXCEPTION
        -- If there is no ship set before and incoming value is also null
        -- set it to miss Char
        WHEN Others THEN  -- including NO_DATA_FOUND
          IF p_x_line_rec.ship_set IS NULL THEN
            p_x_line_rec.ship_set := fnd_api.g_miss_Char;
          END IF;
      END;
    END IF; -- Additional operation code check for UPDATE.
*/
    -------------------
-- End: 9874630 Fix


    IF p_x_line_rec.ship_tolerance_above IS NULL THEN
        p_x_line_rec.ship_tolerance_above :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.ship_tolerance_below IS NULL THEN
        p_x_line_rec.ship_tolerance_below :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.shippable_flag IS NULL THEN
        p_x_line_rec.shippable_flag := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.shipping_interfaced_flag IS NULL THEN
        p_x_line_rec.shipping_interfaced_flag := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.ship_to_contact_id IS NULL THEN
        p_x_line_rec.ship_to_contact_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.ship_to_org_id IS NULL THEN
        p_x_line_rec.ship_to_org_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.sold_from_org_id IS NULL THEN
        p_x_line_rec.sold_from_org_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.sold_to_org_id IS NULL THEN
        p_x_line_rec.sold_to_org_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.sort_order IS NULL THEN
        p_x_line_rec.sort_order := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.source_document_id IS NULL THEN
        p_x_line_rec.source_document_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.source_document_line_id IS NULL THEN
        p_x_line_rec.source_document_line_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.source_document_type_id IS NULL THEN
        p_x_line_rec.source_document_type_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.source_type_code IS NULL THEN
        p_x_line_rec.source_type_code := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.split_from_line_id IS NULL THEN
        p_x_line_rec.split_from_line_id :=  FND_API.G_MISS_NUM;
    END IF;
    IF p_x_line_rec.line_set_id IS NULL THEN
        p_x_line_rec.line_set_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.split_by IS NULL THEN
        p_x_line_rec.split_by := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.model_remnant_flag IS NULL THEN
        p_x_line_rec.model_remnant_flag := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.task_id IS NULL THEN
        p_x_line_rec.task_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.tax_code IS NULL THEN
        p_x_line_rec.tax_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.tax_date IS NULL THEN
        p_x_line_rec.tax_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_line_rec.tax_exempt_flag IS NULL THEN
        p_x_line_rec.tax_exempt_flag := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.tax_exempt_number IS NULL THEN
        p_x_line_rec.tax_exempt_number := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.tax_exempt_reason_code IS NULL THEN
        p_x_line_rec.tax_exempt_reason_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.tax_point_code IS NULL THEN
        p_x_line_rec.tax_point_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.tax_rate IS NULL THEN
        p_x_line_rec.tax_rate :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.tax_value IS NULL THEN
        p_x_line_rec.tax_value :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.top_model_line_id IS NULL THEN
        p_x_line_rec.top_model_line_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.unit_list_price IS NULL THEN
        p_x_line_rec.unit_list_price :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.unit_list_price_per_pqty IS NULL THEN
        p_x_line_rec.unit_list_price_per_pqty :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.unit_selling_price IS NULL THEN
        p_x_line_rec.unit_selling_price :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.unit_selling_price_per_pqty IS NULL THEN
        p_x_line_rec.unit_selling_price_per_pqty :=  FND_API.G_MISS_NUM;
    END IF;


    IF p_x_line_rec.visible_demand_flag IS NULL THEN
        p_x_line_rec.visible_demand_flag := FND_API.G_MISS_CHAR;
    END IF;
    IF p_x_line_rec.veh_cus_item_cum_key_id IS NULL THEN
        p_x_line_rec.veh_cus_item_cum_key_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.first_ack_code IS NULL THEN
        p_x_line_rec.first_ack_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.first_ack_date IS NULL THEN
        p_x_line_rec.first_ack_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_line_rec.last_ack_code IS NULL THEN
        p_x_line_rec.last_ack_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.last_ack_date IS NULL THEN
        p_x_line_rec.last_ack_date := FND_API.G_MISS_DATE;
    END IF;


    IF p_x_line_rec.end_item_unit_number IS NULL THEN
        p_x_line_rec.end_item_unit_number := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.shipping_instructions IS NULL THEN
        p_x_line_rec.shipping_instructions := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.packing_instructions IS NULL THEN
        p_x_line_rec.packing_instructions := FND_API.G_MISS_CHAR;
    END IF;

    -- Service related columns

    IF p_x_line_rec.service_txn_reason_code IS NULL THEN
        p_x_line_rec.service_txn_reason_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.service_txn_comments IS NULL THEN
        p_x_line_rec.service_txn_comments := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.service_duration IS NULL THEN
        p_x_line_rec.service_duration :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.service_period IS NULL THEN
        p_x_line_rec.service_period := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.service_start_date IS NULL THEN
        p_x_line_rec.service_start_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_line_rec.service_end_date IS NULL THEN
        p_x_line_rec.service_end_date := FND_API.G_MISS_DATE;
    END IF;

    IF p_x_line_rec.service_coterminate_flag IS NULL THEN
        p_x_line_rec.service_coterminate_flag := FND_API.G_MISS_CHAR;
    END IF;


    IF p_x_line_rec.unit_list_percent IS NULL THEN
        p_x_line_rec.unit_list_percent :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.unit_selling_percent IS NULL THEN
        p_x_line_rec.unit_selling_percent :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.unit_percent_base_price IS NULL THEN
        p_x_line_rec.unit_percent_base_price :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.service_number IS NULL THEN
        p_x_line_rec.service_number :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.service_reference_type_code IS NULL THEN
        p_x_line_rec.service_reference_type_code := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.service_reference_line_id IS NULL THEN
        p_x_line_rec.service_reference_line_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.service_reference_system_id IS NULL THEN
        p_x_line_rec.service_reference_system_id :=  FND_API.G_MISS_NUM;
    END IF;

    /* Marketing source code related */

    IF p_x_line_rec.marketing_source_code_id IS NULL THEN
        p_x_line_rec.marketing_source_code_id :=  FND_API.G_MISS_NUM;
    END IF;

    /* End of Marketing source code related */

    IF p_x_line_rec.order_source_id IS NULL THEN
        p_x_line_rec.order_source_id := FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.flow_status_code IS NULL THEN
        p_x_line_rec.flow_status_code := FND_API.G_MISS_CHAR;
    END IF;

    -- Commitment related
    IF p_x_line_rec.commitment_id IS NULL THEN
       p_x_line_rec.commitment_id :=  FND_API.G_MISS_NUM;
    END IF;


   -- Item Substitution changes.
   IF p_x_line_rec.Original_Inventory_Item_Id IS NULL THEN
       p_x_line_rec.Original_Inventory_Item_Id :=  FND_API.G_MISS_NUM;
   END IF;

   IF p_x_line_rec.Original_item_identifier_Type IS NULL THEN
       p_x_line_rec.Original_item_identifier_Type := FND_API.G_MISS_CHAR;
   END IF;

   IF p_x_line_rec.Original_ordered_item_id IS NULL THEN
       p_x_line_rec.Original_ordered_item_id :=  FND_API.G_MISS_NUM;
   END IF;

   IF p_x_line_rec.Original_ordered_item IS NULL THEN
       p_x_line_rec.Original_ordered_item := FND_API.G_MISS_CHAR;
   END IF;

   IF p_x_line_rec.item_relationship_type IS NULL THEN
       p_x_line_rec.item_relationship_type :=  FND_API.G_MISS_NUM;
   END IF;

   IF p_x_line_rec.Item_substitution_type_code IS NULL THEN
       p_x_line_rec.Item_substitution_type_code := FND_API.G_MISS_CHAR;
   END IF;

   IF p_x_line_rec.Late_Demand_Penalty_Factor IS NULL THEN
       p_x_line_rec.Late_Demand_Penalty_Factor :=  FND_API.G_MISS_NUM;
   END IF;

   IF p_x_line_rec.Override_atp_date_code IS NULL THEN
       p_x_line_rec.Override_atp_date_code := FND_API.G_MISS_CHAR;
   END IF;

   -- Changes for Blanket Orders

   IF p_x_line_rec.Blanket_Number IS NULL THEN
      p_x_line_rec.Blanket_Number :=  FND_API.G_MISS_NUM;
   END IF;

   IF p_x_line_rec.Blanket_Line_Number IS NULL THEN
      p_x_line_rec.Blanket_Line_Number :=  FND_API.G_MISS_NUM;
   END IF;

   IF p_x_line_rec.Blanket_Version_Number IS NULL THEN
      p_x_line_rec.Blanket_Version_Number :=  FND_API.G_MISS_NUM;
   END IF;

   -- QUOTING changes
   IF p_x_line_rec.transaction_phase_code IS NULL THEN
      p_x_line_rec.transaction_phase_code := FND_API.G_MISS_CHAR;
   END IF;

   IF p_x_line_rec.source_document_version_number IS NULL THEN
      p_x_line_rec.source_document_version_number :=  FND_API.G_MISS_NUM;
   END IF;
   -- END QUOTING changes
    IF p_x_line_rec.Minisite_id IS NULL THEN
        p_x_line_rec.Minisite_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.End_customer_id IS NULL THEN
        p_x_line_rec.End_customer_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.End_customer_contact_id IS NULL THEN
        p_x_line_rec.End_customer_contact_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.End_customer_site_use_id IS NULL THEN
        p_x_line_rec.End_customer_site_use_id :=  FND_API.G_MISS_NUM;
    END IF;

    IF p_x_line_rec.ib_owner IS NULL THEN
        p_x_line_rec.ib_owner := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.ib_installed_at_location IS NULL THEN
        p_x_line_rec.ib_installed_at_location := FND_API.G_MISS_CHAR;
    END IF;

    IF p_x_line_rec.ib_current_location IS NULL THEN
        p_x_line_rec.ib_current_location := FND_API.G_MISS_CHAR;
    END IF;

    --retro{
    IF p_x_line_rec.retrobill_request_id IS NULL THEN
       p_x_line_rec.retrobill_request_id :=  FND_API.G_MISS_NUM;
    END IF;
    --retro}

    IF p_x_line_rec.firm_demand_flag IS NULL THEN
        p_x_line_rec.firm_demand_flag := FND_API.G_MISS_CHAR;
    END IF;

--key Transaction Dates
    IF p_x_line_rec.order_firmed_date IS NULL THEN
      	p_x_line_rec.order_firmed_date := FND_API.G_MISS_DATE;
    END IF;

   IF p_x_line_rec.actual_fulfillment_date IS NULL THEN
	p_x_line_rec.actual_fulfillment_date := FND_API.G_MISS_DATE;
    END IF;
--end

/*   IF p_x_line_rec.supplier_signature IS NULL THEN
        p_x_line_rec.supplier_signature := FND_API.G_MISS_CHAR;
    END IF;

   IF p_x_line_rec.supplier_signature_date IS NULL THEN
        p_x_line_rec.supplier_signature_date := FND_API.G_MISS_DATE;
    END IF;

   IF p_x_line_rec.customer_signature IS NULL THEN
        p_x_line_rec.customer_signature := FND_API.G_MISS_CHAR;
    END IF;

   IF p_x_line_rec.customer_signature_date IS NULL THEN
        p_x_line_rec.customer_signature_date := FND_API.G_MISS_CHAR;
    END IF;
*/

  --
  -- Bug 9660047
  --
  -- Customer Acceptance Related Fields
  --
  IF p_x_line_rec.CONTINGENCY_ID IS NULL THEN
    p_x_line_rec.CONTINGENCY_ID := Fnd_Api.G_Miss_Num;
  END IF;

  IF p_x_line_rec.REVREC_EVENT_CODE IS NULL THEN
    p_x_line_rec.REVREC_EVENT_CODE := Fnd_Api.G_Miss_Char;
  END IF;

  IF p_x_line_rec.REVREC_EXPIRATION_DAYS IS NULL THEN
    p_x_line_rec.REVREC_EXPIRATION_DAYS := Fnd_Api.G_Miss_Num;
  END IF;

  IF p_x_line_rec.ACCEPTED_QUANTITY IS NULL THEN
    p_x_line_rec.ACCEPTED_QUANTITY := Fnd_Api.G_Miss_Num;
  END IF;

  IF p_x_line_rec.ACCEPTED_BY IS NULL THEN
    p_x_line_rec.ACCEPTED_BY := Fnd_Api.G_Miss_Num;
  END IF;

  IF p_x_line_rec.REVREC_COMMENTS IS NULL THEN
    p_x_line_rec.REVREC_COMMENTS := Fnd_Api.G_Miss_Char;
  END IF;

  IF p_x_line_rec.REVREC_REFERENCE_DOCUMENT IS NULL THEN
    p_x_line_rec.REVREC_REFERENCE_DOCUMENT := Fnd_Api.G_Miss_Char;
  END IF;

  IF p_x_line_rec.REVREC_SIGNATURE IS NULL THEN
    p_x_line_rec.REVREC_SIGNATURE := Fnd_Api.G_Miss_Char;
  END IF;

  IF p_x_line_rec.REVREC_SIGNATURE_DATE IS NULL THEN
    p_x_line_rec.REVREC_SIGNATURE_DATE := Fnd_Api.G_Miss_Date;
  END IF;

  IF p_x_line_rec.REVREC_IMPLICIT_FLAG IS NULL THEN
    p_x_line_rec.REVREC_IMPLICIT_FLAG := Fnd_Api.G_Miss_Char;
  END IF;
  --
  -- Customer Acceptance Related Fields
  --

  -- New attributes added for DOO Integration
  IF p_x_line_rec.bypass_sch_flag IS NULL THEN
    p_x_line_rec.bypass_sch_flag := Fnd_Api.G_Miss_Char;
  END IF;

  IF p_x_line_rec. pre_exploded_flag IS NULL THEN
    p_x_line_rec. pre_exploded_flag := Fnd_Api.G_Miss_Char;
  END IF;

  if l_debug_level > 0 then
   oe_debug_pub.add('Exiting OE_GENESIS_UTIL.Convert_Line_null_to_miss', 1);
  end if;
END Convert_Line_null_to_miss;



procedure print_po_payload (
      P_HEADER_REC APPS.OE_ORDER_PUB.HEADER_REC_TYPE,
      P_HEADER_VAL_REC APPS.OE_ORDER_PUB.HEADER_VAL_REC_TYPE,
      P_HEADER_PAYMENT_TBL APPS.OE_ORDER_PUB.HEADER_PAYMENT_TBL_TYPE,
      P_LINE_TBL APPS.OE_ORDER_PUB.LINE_TBL_TYPE
      )
 IS

 BEGIN
      --oe_debug_pub.initialize;
      --l_temp_var := oe_debug_pub.set_debug_mode('FILE');
      --oe_debug_pub.debug_on;
      --oe_debug_pub.add('Inside the cover API');
      --oe_debug_pub.add('Line table count is '||p_line_tbl.COUNT);


      -- All the parameters that are being passed in
      oe_debug_pub.add('P_HEADER_REC.BOOKED_FLAG:' || P_HEADER_REC.BOOKED_FLAG);
      oe_debug_pub.add('P_HEADER_REC.CUST_PO_NUMBER:' || P_HEADER_REC.CUST_PO_NUMBER);
      oe_debug_pub.add('P_HEADER_REC.FREIGHT_CARRIER_CODE:' || P_HEADER_REC.FREIGHT_CARRIER_CODE);
      oe_debug_pub.add('P_HEADER_REC.FREIGHT_TERMS_CODE:' || P_HEADER_REC.FREIGHT_TERMS_CODE);
      oe_debug_pub.add('P_HEADER_REC.ORDERED_DATE:' || P_HEADER_REC.ORDERED_DATE);
      oe_debug_pub.add('P_HEADER_REC.ORDER_TYPE_ID:' || P_HEADER_REC.ORDER_TYPE_ID);
      oe_debug_pub.add('P_HEADER_REC.ORG_ID:' || P_HEADER_REC.ORG_ID);
      oe_debug_pub.add('P_HEADER_REC.ORIG_SYS_DOCUMENT_REF:' || P_HEADER_REC.ORIG_SYS_DOCUMENT_REF);
      oe_debug_pub.add('P_HEADER_REC.order_source_id:' || P_HEADER_REC.order_source_id);
      oe_debug_pub.add('P_HEADER_REC.PAYMENT_TERM_I:' || P_HEADER_REC.PAYMENT_TERM_ID);
      oe_debug_pub.add('P_HEADER_REC.PRICE_LIST_ID:' || P_HEADER_REC.PRICE_LIST_ID);
      oe_debug_pub.add('P_HEADER_REC.PRICING_DATE:' || P_HEADER_REC.PRICING_DATE);
      oe_debug_pub.add('P_HEADER_REC.REQUEST_DATE:' || P_HEADER_REC.REQUEST_DATE);
      oe_debug_pub.add('P_HEADER_REC.SHIPPING_METHOD_CODE:' || P_HEADER_REC.SHIPPING_METHOD_CODE);
      oe_debug_pub.add('P_HEADER_REC.SHIP_FROM_ORG_ID:' || P_HEADER_REC.SHIP_FROM_ORG_ID);
      oe_debug_pub.add('P_HEADER_REC.SHIP_TO_ORG_ID:' || P_HEADER_REC.SHIP_TO_ORG_ID);
      oe_debug_pub.add('P_HEADER_REC.SOLD_TO_ORG_ID:' || P_HEADER_REC.SOLD_TO_ORG_ID);
      oe_debug_pub.add('P_HEADER_REC.TRANSACTIONAL_CURR_CODE:' || P_HEADER_REC.TRANSACTIONAL_CURR_CODE);
      oe_debug_pub.add('P_HEADER_REC.VERSION_NUMBER:' || P_HEADER_REC.VERSION_NUMBER);
      oe_debug_pub.add('P_HEADER_REC.OPERATION:' || P_HEADER_REC.OPERATION);

      oe_debug_pub.add('P_HEADER_VAL_REC.FREIGHT_TERMS:' || P_HEADER_VAL_REC.FREIGHT_TERMS);
      oe_debug_pub.add('P_HEADER_VAL_REC.INVOICE_TO_ADDRESS1:' || P_HEADER_VAL_REC.INVOICE_TO_ADDRESS1);
      oe_debug_pub.add('P_HEADER_VAL_REC.INVOICE_TO_ADDRESS2:' || P_HEADER_VAL_REC.INVOICE_TO_ADDRESS2);
      oe_debug_pub.add('P_HEADER_VAL_REC.INVOICE_TO_ADDRESS3:' || P_HEADER_VAL_REC.INVOICE_TO_ADDRESS3);
      oe_debug_pub.add('P_HEADER_VAL_REC.INVOICE_TO_ADDRESS4:' || P_HEADER_VAL_REC.INVOICE_TO_ADDRESS4);
      oe_debug_pub.add('P_HEADER_VAL_REC.INVOICE_TO_STATE:' || P_HEADER_VAL_REC.INVOICE_TO_STATE);
      oe_debug_pub.add('P_HEADER_VAL_REC.INVOICE_TO_CITY:' || P_HEADER_VAL_REC.INVOICE_TO_CITY);
      oe_debug_pub.add('P_HEADER_VAL_REC.INVOICE_TO_ZIP:' || P_HEADER_VAL_REC.INVOICE_TO_ZIP);
      oe_debug_pub.add('P_HEADER_VAL_REC.INVOICE_TO_COUNTRY:' || P_HEADER_VAL_REC.INVOICE_TO_COUNTRY);
      oe_debug_pub.add('P_HEADER_VAL_REC.INVOICE_TO_COUNTY:' || P_HEADER_VAL_REC.INVOICE_TO_COUNTY);
      oe_debug_pub.add('P_HEADER_VAL_REC.INVOICE_TO_PROVINCE:' || P_HEADER_VAL_REC.INVOICE_TO_PROVINCE);
      oe_debug_pub.add('P_HEADER_VAL_REC.INVOICE_TO_CONTACT:' || P_HEADER_VAL_REC.INVOICE_TO_CONTACT);
      oe_debug_pub.add('P_HEADER_VAL_REC.SHIP_TO_ADDRESS1:' || P_HEADER_VAL_REC.SHIP_TO_ADDRESS1);
      oe_debug_pub.add('P_HEADER_VAL_REC.SHIP_TO_ADDRESS2:' || P_HEADER_VAL_REC.SHIP_TO_ADDRESS2);
      oe_debug_pub.add('P_HEADER_VAL_REC.SHIP_TO_ADDRESS3:' || P_HEADER_VAL_REC.SHIP_TO_ADDRESS3);
      oe_debug_pub.add('P_HEADER_VAL_REC.SHIP_TO_ADDRESS4:' || P_HEADER_VAL_REC.SHIP_TO_ADDRESS4);
      oe_debug_pub.add('P_HEADER_VAL_REC.SHIP_TO_STATE:' || P_HEADER_VAL_REC.SHIP_TO_STATE);
      oe_debug_pub.add('P_HEADER_VAL_REC.SHIP_TO_COUNTRY:' || P_HEADER_VAL_REC.SHIP_TO_COUNTRY);
      oe_debug_pub.add('P_HEADER_VAL_REC.SHIP_TO_ZIP:' || P_HEADER_VAL_REC.SHIP_TO_ZIP);
      oe_debug_pub.add('P_HEADER_VAL_REC.SHIP_TO_CITY:' || P_HEADER_VAL_REC.SHIP_TO_CITY);
      oe_debug_pub.add('P_HEADER_VAL_REC.SHIP_TO_CONTACT:' || P_HEADER_VAL_REC.SHIP_TO_CONTACT);
      oe_debug_pub.add('P_HEADER_VAL_REC.SHIP_TO_CONTACT_LAST_NAME:' || P_HEADER_VAL_REC.SHIP_TO_CONTACT_LAST_NAME);
      oe_debug_pub.add('P_HEADER_VAL_REC.SHIP_TO_CONTACT_FIRST_NAME:' || P_HEADER_VAL_REC.SHIP_TO_CONTACT_FIRST_NAME);

    if P_LINE_TBL.COUNT > 0 THEN
      for i in P_LINE_TBL.FIRST .. P_LINE_TBL.LAST LOOP
         oe_debug_pub.add('P_LINE_TBL(i).CANCELLED_QUANTITY:' || P_LINE_TBL(i).CANCELLED_QUANTITY);
         oe_debug_pub.add('P_LINE_TBL(i).CONFIG_HEADER_ID:' || P_LINE_TBL(i).CONFIG_HEADER_ID);
         oe_debug_pub.add('P_LINE_TBL(i).CONFIG_REV_NBR:' || P_LINE_TBL(i).CONFIG_REV_NBR);
         oe_debug_pub.add('P_LINE_TBL(i).CONFIGURATION_ID:' || P_LINE_TBL(i).CONFIGURATION_ID);
         oe_debug_pub.add('P_LINE_TBL(i).item_type_code:' || P_LINE_TBL(i).item_type_code);
         oe_debug_pub.add('P_LINE_TBL(i).FREIGHT_CARRIER_CODE:' || P_LINE_TBL(i).FREIGHT_CARRIER_CODE);
         oe_debug_pub.add('P_LINE_TBL(i).FREIGHT_TERMS_CODE:' || P_LINE_TBL(i).FREIGHT_TERMS_CODE);
         oe_debug_pub.add('P_LINE_TBL(i).INVENTORY_ITEM_ID:' || P_LINE_TBL(i).INVENTORY_ITEM_ID);
         oe_debug_pub.add('P_LINE_TBL(i).ORDERED_QUANTITY:' || P_LINE_TBL(i).ORDERED_QUANTITY);
         oe_debug_pub.add('P_LINE_TBL(i).ORDER_QUANTITY_UOM:' || P_LINE_TBL(i).ORDER_QUANTITY_UOM);
         oe_debug_pub.add('P_LINE_TBL(i).ORIG_SYS_LINE_REF:' || P_LINE_TBL(i).ORIG_SYS_LINE_REF);
         oe_debug_pub.add('P_LINE_TBL(i).order_source_id:' || P_LINE_TBL(i).order_source_id);
         oe_debug_pub.add('P_LINE_TBL(i).PRICING_DATE:' || P_LINE_TBL(i).PRICING_DATE);
         oe_debug_pub.add('P_LINE_TBL(i).REQUEST_DATE:' || P_LINE_TBL(i).REQUEST_DATE);
         oe_debug_pub.add('P_LINE_TBL(i).RETURN_REASON_CODE:' || P_LINE_TBL(i).RETURN_REASON_CODE);
         oe_debug_pub.add('P_LINE_TBL(i).SHIPPING_METHOD_CODE:' || P_LINE_TBL(i).SHIPPING_METHOD_CODE);
         oe_debug_pub.add('P_LINE_TBL(i).SHIP_TO_ORG_ID:' || P_LINE_TBL(i).SHIP_TO_ORG_ID);
         oe_debug_pub.add('P_LINE_TBL(i).UNIT_LIST_PRICE:' || P_LINE_TBL(i).UNIT_LIST_PRICE);
         oe_debug_pub.add('P_LINE_TBL(i).UNIT_SELLING_PRICE:' || P_LINE_TBL(i).UNIT_SELLING_PRICE);
         oe_debug_pub.add('P_LINE_TBL(i).OPERATION:' || P_LINE_TBL(i).OPERATION);

        -- oe_debug_pub.add('P_LINE_VAL_TBL(i).SHIP_TO_ADDRESS1:' || P_LINE_VAL_TBL(i).SHIP_TO_ADDRESS1);
       --  oe_debug_pub.add('P_LINE_VAL_TBL(i).SHIP_TO_STATE:' || P_LINE_VAL_TBL(i).SHIP_TO_STATE);
        -- oe_debug_pub.add('P_LINE_VAL_TBL(i).SHIP_TO_CONTACT:' || P_LINE_VAL_TBL(i).SHIP_TO_CONTACT);

      end loop;
   END IF;



end print_po_payload;



END OE_GENESIS_UTIL;

/
