--------------------------------------------------------
--  DDL for Package Body OE_BULK_HEADER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BULK_HEADER_UTIL" AS
/* $Header: OEBUHDRB.pls 120.3.12010000.2 2008/12/28 23:15:31 smusanna ship $ */

G_PKG_NAME         CONSTANT     VARCHAR2(30):='OE_BULK_HEADER_UTIL';


---------------------------------------------------------------------
-- PROCEDURE Load_Headers
--
-- Loads order headers in the batch from interface tables to
-- the record - p_header_rec
---------------------------------------------------------------------

PROCEDURE Load_Headers
( p_batch_id                   IN NUMBER
 ,p_header_rec                 IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE
)
IS

CURSOR c_headers IS
  SELECT
       accounting_rule_id
      ,accounting_rule_duration
      ,agreement_id
      ,h.attribute1
      ,h.attribute10
      ,h.attribute11
      ,h.attribute12
      ,h.attribute13
      ,h.attribute14
      ,h.attribute15
      ,h.attribute16   --For bug 2184255
      ,h.attribute17
      ,h.attribute18
      ,h.attribute19
      ,h.attribute2
      ,h.attribute20
      ,h.attribute3
      ,h.attribute4
      ,h.attribute5
      ,h.attribute6
      ,h.attribute7
      ,h.attribute8
      ,h.attribute9
      -- This will select booked_flag from headers interface table
      -- But if null on headers interface, set booked_flag to 'Y'
      -- if there is an action request with operation code: 'BOOK_ORDER'
      ,nvl(h.booked_flag,decode(a.order_source_id,NULL,'N','Y'))
      ,h.context
      ,conversion_rate
      ,conversion_rate_date
      ,conversion_type_code
      ,customer_preference_set_code
      ,customer_po_number
      ,deliver_to_contact_id
      ,deliver_to_org_id
      ,demand_class_code
      ,earliest_schedule_limit
      ,NULL                       -- first_ack_code
      ,fob_point_code
      ,NULL                       --freight_carrier_code for bug 3610475
      ,freight_terms_code
      ,global_attribute1
      ,global_attribute10
      ,global_attribute11
      ,global_attribute12
      ,global_attribute13
      ,global_attribute14
      ,global_attribute15
      ,global_attribute16
      ,global_attribute17
      ,global_attribute18
      ,global_attribute19
      ,global_attribute2
      ,global_attribute20
      ,global_attribute3
      ,global_attribute4
      ,global_attribute5
      ,global_attribute6
      ,global_attribute7
      ,global_attribute8
      ,global_attribute9
      ,global_attribute_category
      ,TP_CONTEXT
      ,TP_ATTRIBUTE1
      ,TP_ATTRIBUTE2
      ,TP_ATTRIBUTE3
      ,TP_ATTRIBUTE4
      ,TP_ATTRIBUTE5
      ,TP_ATTRIBUTE6
      ,TP_ATTRIBUTE7
      ,TP_ATTRIBUTE8
      ,TP_ATTRIBUTE9
      ,TP_ATTRIBUTE10
      ,TP_ATTRIBUTE11
      ,TP_ATTRIBUTE12
      ,TP_ATTRIBUTE13
      ,TP_ATTRIBUTE14
      ,TP_ATTRIBUTE15
      -- Use pre-generated header_id value from interface tables
      ,HEADER_ID                        -- OE_ORDER_HEADERS_S.NEXTVAL
      ,invoice_to_contact_id
      ,invoice_to_org_id
      ,invoicing_rule_id
      ,latest_schedule_limit
      ,nvl(ordered_date, SYSDATE)
      ,order_date_type_code
      ,order_number
      ,h.order_source_id
      ,order_type_id
      ,NULL   -- order_category_code
      ,h.org_id
      ,h.orig_sys_document_ref
      ,partial_shipments_allowed
      ,payment_term_id
      ,price_list_id
      ,sysdate
      ,request_date
      ,h.request_id
--      ,return_reason_code
      ,salesrep_id
      ,sales_channel_code
      ,shipment_priority_code
      ,shipping_method_code
      ,ship_from_org_id
      ,ship_tolerance_above
      ,ship_tolerance_below
      ,ship_to_contact_id
      ,ship_to_org_id
      ,sold_from_org_id
      ,sold_to_contact_id
      ,h.sold_to_org_id
--      ,source_document_id
--      ,source_document_type_id
      ,tax_exempt_flag
      ,tax_exempt_number
      ,tax_exempt_reason_code
      ,tax_point_code
      ,transactional_curr_code
      -- QUOTING changes - remove nvl on version number
      ,version_number
--      ,change_reason
--      ,change_comments
      ,h.change_sequence
--      ,change_request_code
--      ,ready_flag
--      ,status_flag
--      ,force_apply_flag
--      ,drop_ship_flag
--      ,customer_payment_term_id
      ,payment_type_code
      ,payment_amount
      ,check_number
      ,credit_card_code
      ,credit_card_holder_name
      ,credit_card_number
      ,credit_card_expiration_date
      ,credit_card_approval_code
      ,credit_card_approval_date
      ,shipping_instructions
      ,packing_instructions
      , 1                    --     lock_control
      ,NULL                  --     order_type_name
      ,NULL                  --     wf_process_name
      ,xml_message_id
--abghosh
      ,sold_to_site_use_id
     -- end customer(Bug 5054618)
	,h.End_customer_contact_id
	,h.End_customer_id
	,h.End_customer_site_use_id
	,h.IB_owner_code
	,h.IB_current_location_code
	,h.IB_Installed_at_Location_code
        ,null                  --     start_line_index
        ,null                  --     end_line_index
  FROM OE_HEADERS_IFACE_ALL h
       ,OE_ACTIONS_INTERFACE a
  WHERE h.batch_id = p_batch_id
    AND NVL(h.error_flag ,'N') = 'N'
    AND a.order_source_id(+) = h.order_source_id
    AND a.orig_sys_document_ref(+) = h.orig_sys_document_ref
    AND a.operation_code(+) = 'BOOK_ORDER'
  ORDER BY h.order_source_id, h.orig_sys_document_ref;

--For bug 3390458
CURSOR c_headers_rtrim IS
  SELECT
       accounting_rule_id
      ,accounting_rule_duration
      ,agreement_id
      ,h.attribute1
      ,h.attribute10
      ,h.attribute11
      ,h.attribute12
      ,h.attribute13
      ,h.attribute14
      ,h.attribute15
      ,h.attribute16   --For bug 2184255
      ,h.attribute17
      ,h.attribute18
      ,h.attribute19
      ,h.attribute2
      ,h.attribute20
      ,h.attribute3
      ,h.attribute4
      ,h.attribute5
      ,h.attribute6
      ,h.attribute7
      ,h.attribute8
      ,h.attribute9
      -- This will select booked_flag from headers interface table
      -- But if null on headers interface, set booked_flag to 'Y'
      -- if there is an action request with operation code: 'BOOK_ORDER'
      ,nvl(h.booked_flag,decode(a.order_source_id,NULL,'N','Y'))
      ,h.context
      ,conversion_rate
      ,conversion_rate_date
      ,conversion_type_code
      ,customer_preference_set_code
      ,RTRIM(customer_po_number,' ')--for bug 3390458
      ,deliver_to_contact_id
      ,deliver_to_org_id
      ,demand_class_code
      ,earliest_schedule_limit
      ,NULL                       -- first_ack_code
      ,fob_point_code
      ,NULL                       --freight_carrier_code for bug 3610475
      ,freight_terms_code
      ,global_attribute1
      ,global_attribute10
      ,global_attribute11
      ,global_attribute12
      ,global_attribute13
      ,global_attribute14
      ,global_attribute15
      ,global_attribute16
      ,global_attribute17
      ,global_attribute18
      ,global_attribute19
      ,global_attribute2
      ,global_attribute20
      ,global_attribute3
      ,global_attribute4
      ,global_attribute5
      ,global_attribute6
      ,global_attribute7
      ,global_attribute8
      ,global_attribute9
      ,global_attribute_category
      ,RTRIM(TP_CONTEXT,' ') -- 3390458
      ,RTRIM(TP_ATTRIBUTE1,' ') -- 3390458
      ,RTRIM(TP_ATTRIBUTE2,' ') -- 3390458
      ,RTRIM(TP_ATTRIBUTE3,' ') -- 3390458
      ,RTRIM(TP_ATTRIBUTE4,' ') -- 3390458
      ,RTRIM(TP_ATTRIBUTE5,' ') -- 3390458
      ,RTRIM(TP_ATTRIBUTE6,' ') -- 3390458
      ,RTRIM(TP_ATTRIBUTE7,' ') -- 3390458
      ,RTRIM(TP_ATTRIBUTE8,' ') -- 3390458
      ,RTRIM(TP_ATTRIBUTE9,' ') -- 3390458
      ,RTRIM(TP_ATTRIBUTE10,' ') -- 3390458
      ,RTRIM(TP_ATTRIBUTE11,' ') -- 3390458
      ,RTRIM(TP_ATTRIBUTE12,' ') -- 3390458
      ,RTRIM(TP_ATTRIBUTE13,' ') -- 3390458
      ,RTRIM(TP_ATTRIBUTE14,' ') -- 3390458
      ,RTRIM(TP_ATTRIBUTE15,' ') -- 3390458
      -- Use pre-generated header_id value from interface tables
      ,HEADER_ID                        -- OE_ORDER_HEADERS_S.NEXTVAL
      ,invoice_to_contact_id
      ,invoice_to_org_id
      ,invoicing_rule_id
      ,latest_schedule_limit
      ,nvl(ordered_date, SYSDATE)
      ,order_date_type_code
      ,order_number
      ,h.order_source_id
      ,order_type_id
      ,NULL   -- order_category_code
      ,h.org_id
      ,h.orig_sys_document_ref
      ,partial_shipments_allowed
      ,payment_term_id
      ,price_list_id
      ,sysdate
      ,request_date
      ,h.request_id
--      ,return_reason_code
      ,salesrep_id
      ,sales_channel_code
      ,shipment_priority_code
      ,shipping_method_code
      ,ship_from_org_id
      ,ship_tolerance_above
      ,ship_tolerance_below
      ,ship_to_contact_id
      ,ship_to_org_id
      ,sold_from_org_id
      ,sold_to_contact_id
      ,h.sold_to_org_id
--      ,source_document_id
--      ,source_document_type_id
      ,tax_exempt_flag
      ,tax_exempt_number
      ,tax_exempt_reason_code
      ,tax_point_code
      ,RTRIM(transactional_curr_code,' ') --for bug 3390458
      -- QUOTING changes - remove nvl on version number
      ,version_number
--      ,change_reason
--      ,change_comments
      ,h.change_sequence
--      ,change_request_code
--      ,ready_flag
--      ,status_flag
--      ,force_apply_flag
--      ,drop_ship_flag
--      ,customer_payment_term_id
      ,payment_type_code
      ,payment_amount
      ,check_number
      ,credit_card_code
      ,credit_card_holder_name
      ,credit_card_number
      ,credit_card_expiration_date
      ,credit_card_approval_code
      ,credit_card_approval_date
      ,RTRIM(shipping_instructions,' ')--for bug 3390458
      ,RTRIM(packing_instructions,' ')
      , 1                    --     lock_control
      ,NULL                  --     order_type_name
      ,NULL                  --     wf_process_name
      ,xml_message_id
--abghosh
      ,sold_to_site_use_id
     -- end customer (Bug 5054618)
     ,h.End_customer_contact_id
    ,h.End_customer_id
    ,h.End_customer_site_use_id
    ,h.IB_owner_code
    ,h.IB_current_location_code
    ,h.IB_Installed_at_Location_code
    ,null                  --     start_line_index
    ,null                  --     end_line_index
  FROM OE_HEADERS_IFACE_ALL h
       ,OE_ACTIONS_INTERFACE a
  WHERE h.batch_id = p_batch_id
    AND NVL(h.error_flag ,'N') = 'N'
    AND a.order_source_id(+) = h.order_source_id
    AND a.orig_sys_document_ref(+) = h.orig_sys_document_ref
    AND a.operation_code(+) = 'BOOK_ORDER'
  ORDER BY h.order_source_id, h.orig_sys_document_ref;

BEGIN

--for bug 3390458
IF OE_BULK_ORDER_IMPORT_PVT.G_RTRIM_IFACE_DATA = 'N'
THEN
  oe_debug_pub.add('before OPEN c_header');

  OPEN c_headers;
  FETCH c_headers BULK COLLECT
  INTO
      p_header_rec.accounting_rule_id
     ,p_header_rec.accounting_rule_duration
     ,p_header_rec.agreement_id
     ,p_header_rec.attribute1
     ,p_header_rec.attribute10
     ,p_header_rec.attribute11
     ,p_header_rec.attribute12
     ,p_header_rec.attribute13
     ,p_header_rec.attribute14
     ,p_header_rec.attribute15
     ,p_header_rec.attribute16   --For bug 2184255
     ,p_header_rec.attribute17
     ,p_header_rec.attribute18
     ,p_header_rec.attribute19
     ,p_header_rec.attribute2
     ,p_header_rec.attribute20
     ,p_header_rec.attribute3
     ,p_header_rec.attribute4
     ,p_header_rec.attribute5
     ,p_header_rec.attribute6
     ,p_header_rec.attribute7
     ,p_header_rec.attribute8
     ,p_header_rec.attribute9
     ,p_header_rec.booked_flag
     ,p_header_rec.context
     ,p_header_rec.conversion_rate
     ,p_header_rec.conversion_rate_date
     ,p_header_rec.conversion_type_code
     ,p_header_rec.customer_preference_set_code
     ,p_header_rec.cust_po_number
     ,p_header_rec.deliver_to_contact_id
     ,p_header_rec.deliver_to_org_id
     ,p_header_rec.demand_class_code
     ,p_header_rec.earliest_schedule_limit
     ,p_header_rec.first_ack_code
     ,p_header_rec.fob_point_code
     ,p_header_rec.freight_carrier_code
     ,p_header_rec.freight_terms_code
     ,p_header_rec.global_attribute1
     ,p_header_rec.global_attribute10
     ,p_header_rec.global_attribute11
     ,p_header_rec.global_attribute12
     ,p_header_rec.global_attribute13
     ,p_header_rec.global_attribute14
     ,p_header_rec.global_attribute15
     ,p_header_rec.global_attribute16
     ,p_header_rec.global_attribute17
     ,p_header_rec.global_attribute18
     ,p_header_rec.global_attribute19
     ,p_header_rec.global_attribute2
     ,p_header_rec.global_attribute20
     ,p_header_rec.global_attribute3
     ,p_header_rec.global_attribute4
     ,p_header_rec.global_attribute5
     ,p_header_rec.global_attribute6
     ,p_header_rec.global_attribute7
     ,p_header_rec.global_attribute8
     ,p_header_rec.global_attribute9
     ,p_header_rec.global_attribute_category
     ,p_header_rec.TP_CONTEXT
     ,p_header_rec.TP_ATTRIBUTE1
     ,p_header_rec.TP_ATTRIBUTE2
     ,p_header_rec.TP_ATTRIBUTE3
     ,p_header_rec.TP_ATTRIBUTE4
     ,p_header_rec.TP_ATTRIBUTE5
     ,p_header_rec.TP_ATTRIBUTE6
     ,p_header_rec.TP_ATTRIBUTE7
     ,p_header_rec.TP_ATTRIBUTE8
     ,p_header_rec.TP_ATTRIBUTE9
     ,p_header_rec.TP_ATTRIBUTE10
     ,p_header_rec.TP_ATTRIBUTE11
     ,p_header_rec.TP_ATTRIBUTE12
     ,p_header_rec.TP_ATTRIBUTE13
     ,p_header_rec.TP_ATTRIBUTE14
     ,p_header_rec.TP_ATTRIBUTE15
     ,p_header_rec.header_id
     ,p_header_rec.invoice_to_contact_id
     ,p_header_rec.invoice_to_org_id
     ,p_header_rec.invoicing_rule_id
     ,p_header_rec.latest_schedule_limit
     ,p_header_rec.ordered_date
     ,p_header_rec.order_date_type_code
     ,p_header_rec.order_number
     ,p_header_rec.order_source_id
     ,p_header_rec.order_type_id
     ,p_header_rec.order_category_code
     ,p_header_rec.org_id
     ,p_header_rec.orig_sys_document_ref
     ,p_header_rec.partial_shipments_allowed
     ,p_header_rec.payment_term_id
     ,p_header_rec.price_list_id
     ,p_header_rec.pricing_date
     ,p_header_rec.request_date
     ,p_header_rec.request_id
--     ,p_header_rec.return_reason_code
     ,p_header_rec.salesrep_id
     ,p_header_rec.sales_channel_code
     ,p_header_rec.shipment_priority_code
     ,p_header_rec.shipping_method_code
     ,p_header_rec.ship_from_org_id
     ,p_header_rec.ship_tolerance_above
     ,p_header_rec.ship_tolerance_below
     ,p_header_rec.ship_to_contact_id
     ,p_header_rec.ship_to_org_id
     ,p_header_rec.sold_from_org_id
     ,p_header_rec.sold_to_contact_id
     ,p_header_rec.sold_to_org_id
--     ,p_header_rec.source_document_id
--     ,p_header_rec.source_document_type_id
     ,p_header_rec.tax_exempt_flag
     ,p_header_rec.tax_exempt_number
     ,p_header_rec.tax_exempt_reason_code
     ,p_header_rec.tax_point_code
     ,p_header_rec.transactional_curr_code
     ,p_header_rec.version_number
--     ,p_header_rec.change_reason
--     ,p_header_rec.change_comments
     ,p_header_rec.change_sequence
--     ,p_header_rec.change_request_code
--     ,p_header_rec.ready_flag
--     ,p_header_rec.status_flag
--     ,p_header_rec.force_apply_flag
--     ,p_header_rec.drop_ship_flag
--     ,p_header_rec.customer_payment_term_id
     ,p_header_rec.payment_type_code
     ,p_header_rec.payment_amount
     ,p_header_rec.check_number
     ,p_header_rec.credit_card_code
     ,p_header_rec.credit_card_holder_name
     ,p_header_rec.credit_card_number
     ,p_header_rec.credit_card_expiration_date
     ,p_header_rec.credit_card_approval_code
     ,p_header_rec.credit_card_approval_date
     ,p_header_rec.shipping_instructions
     ,p_header_rec.packing_instructions
     ,p_header_rec.lock_control
     ,p_header_rec.order_type_name
     ,p_header_rec.wf_process_name
     ,p_header_rec.xml_message_id
--abghosh
     ,p_header_rec.sold_to_site_use_id
     -- end customer (Bug 5054618)
,p_header_rec.End_customer_contact_id
,p_header_rec.End_customer_id
,p_header_rec.End_customer_site_use_id
,p_header_rec.IB_owner
,p_header_rec.IB_current_location
,p_header_rec.IB_Installed_at_Location
,p_header_rec.start_line_index
,p_header_rec.end_line_index
;
ELSE
  --for bug 3390458
  oe_debug_pub.add('before OPEN c_header_rtrim');

  -- This code is added to rtrim text columns. It is controlled by the
  -- input parameter to HVOP order import program.

  OPEN c_headers_rtrim;
  FETCH c_headers_rtrim BULK COLLECT
  INTO
      p_header_rec.accounting_rule_id
     ,p_header_rec.accounting_rule_duration
     ,p_header_rec.agreement_id
     ,p_header_rec.attribute1
     ,p_header_rec.attribute10
     ,p_header_rec.attribute11
     ,p_header_rec.attribute12
     ,p_header_rec.attribute13
     ,p_header_rec.attribute14
     ,p_header_rec.attribute15
     ,p_header_rec.attribute16   --For bug 2184255
     ,p_header_rec.attribute17
     ,p_header_rec.attribute18
     ,p_header_rec.attribute19
     ,p_header_rec.attribute2
     ,p_header_rec.attribute20
     ,p_header_rec.attribute3
     ,p_header_rec.attribute4
     ,p_header_rec.attribute5
     ,p_header_rec.attribute6
     ,p_header_rec.attribute7
     ,p_header_rec.attribute8
     ,p_header_rec.attribute9
     ,p_header_rec.booked_flag
     ,p_header_rec.context
     ,p_header_rec.conversion_rate
     ,p_header_rec.conversion_rate_date
     ,p_header_rec.conversion_type_code
     ,p_header_rec.customer_preference_set_code
     ,p_header_rec.cust_po_number
     ,p_header_rec.deliver_to_contact_id
     ,p_header_rec.deliver_to_org_id
     ,p_header_rec.demand_class_code
     ,p_header_rec.earliest_schedule_limit
     ,p_header_rec.first_ack_code
     ,p_header_rec.fob_point_code
     ,p_header_rec.freight_carrier_code
     ,p_header_rec.freight_terms_code
     ,p_header_rec.global_attribute1
     ,p_header_rec.global_attribute10
     ,p_header_rec.global_attribute11
     ,p_header_rec.global_attribute12
     ,p_header_rec.global_attribute13
     ,p_header_rec.global_attribute14
     ,p_header_rec.global_attribute15
     ,p_header_rec.global_attribute16
     ,p_header_rec.global_attribute17
     ,p_header_rec.global_attribute18
     ,p_header_rec.global_attribute19
     ,p_header_rec.global_attribute2
     ,p_header_rec.global_attribute20
     ,p_header_rec.global_attribute3
     ,p_header_rec.global_attribute4
     ,p_header_rec.global_attribute5
     ,p_header_rec.global_attribute6
     ,p_header_rec.global_attribute7
     ,p_header_rec.global_attribute8
     ,p_header_rec.global_attribute9
     ,p_header_rec.global_attribute_category
     ,p_header_rec.TP_CONTEXT
     ,p_header_rec.TP_ATTRIBUTE1
     ,p_header_rec.TP_ATTRIBUTE2
     ,p_header_rec.TP_ATTRIBUTE3
     ,p_header_rec.TP_ATTRIBUTE4
     ,p_header_rec.TP_ATTRIBUTE5
     ,p_header_rec.TP_ATTRIBUTE6
     ,p_header_rec.TP_ATTRIBUTE7
     ,p_header_rec.TP_ATTRIBUTE8
     ,p_header_rec.TP_ATTRIBUTE9
     ,p_header_rec.TP_ATTRIBUTE10
     ,p_header_rec.TP_ATTRIBUTE11
     ,p_header_rec.TP_ATTRIBUTE12
     ,p_header_rec.TP_ATTRIBUTE13
     ,p_header_rec.TP_ATTRIBUTE14
     ,p_header_rec.TP_ATTRIBUTE15
     ,p_header_rec.header_id
     ,p_header_rec.invoice_to_contact_id
     ,p_header_rec.invoice_to_org_id
     ,p_header_rec.invoicing_rule_id
     ,p_header_rec.latest_schedule_limit
     ,p_header_rec.ordered_date
     ,p_header_rec.order_date_type_code
     ,p_header_rec.order_number
     ,p_header_rec.order_source_id
     ,p_header_rec.order_type_id
     ,p_header_rec.order_category_code
     ,p_header_rec.org_id
     ,p_header_rec.orig_sys_document_ref
     ,p_header_rec.partial_shipments_allowed
     ,p_header_rec.payment_term_id
     ,p_header_rec.price_list_id
     ,p_header_rec.pricing_date
     ,p_header_rec.request_date
     ,p_header_rec.request_id
--     ,p_header_rec.return_reason_code
     ,p_header_rec.salesrep_id
     ,p_header_rec.sales_channel_code
     ,p_header_rec.shipment_priority_code
     ,p_header_rec.shipping_method_code
     ,p_header_rec.ship_from_org_id
     ,p_header_rec.ship_tolerance_above
     ,p_header_rec.ship_tolerance_below
     ,p_header_rec.ship_to_contact_id
     ,p_header_rec.ship_to_org_id
     ,p_header_rec.sold_from_org_id
     ,p_header_rec.sold_to_contact_id
     ,p_header_rec.sold_to_org_id
--     ,p_header_rec.source_document_id
--     ,p_header_rec.source_document_type_id
     ,p_header_rec.tax_exempt_flag
     ,p_header_rec.tax_exempt_number
     ,p_header_rec.tax_exempt_reason_code
     ,p_header_rec.tax_point_code
     ,p_header_rec.transactional_curr_code
     ,p_header_rec.version_number
--     ,p_header_rec.change_reason
--     ,p_header_rec.change_comments
     ,p_header_rec.change_sequence
--     ,p_header_rec.change_request_code
--     ,p_header_rec.ready_flag
--     ,p_header_rec.status_flag
--     ,p_header_rec.force_apply_flag
--     ,p_header_rec.drop_ship_flag
--     ,p_header_rec.customer_payment_term_id
     ,p_header_rec.payment_type_code
     ,p_header_rec.payment_amount
     ,p_header_rec.check_number
     ,p_header_rec.credit_card_code
     ,p_header_rec.credit_card_holder_name
     ,p_header_rec.credit_card_number
     ,p_header_rec.credit_card_expiration_date
     ,p_header_rec.credit_card_approval_code
     ,p_header_rec.credit_card_approval_date
     ,p_header_rec.shipping_instructions
     ,p_header_rec.packing_instructions
     ,p_header_rec.lock_control
     ,p_header_rec.order_type_name
     ,p_header_rec.wf_process_name
     ,p_header_rec.xml_message_id
--abghosh
     ,p_header_rec.sold_to_site_use_id
      -- end customer (Bug 5054618)
 ,p_header_rec.End_customer_contact_id
 ,p_header_rec.End_customer_id
 ,p_header_rec.End_customer_site_use_id
 ,p_header_rec.IB_owner
 ,p_header_rec.IB_current_location
 ,p_header_rec.IB_Installed_at_Location
 ,p_header_rec.start_line_index
 ,p_header_rec.end_line_index
   ;
END IF;

EXCEPTION
  WHEN OTHERS THEN
    oe_debug_pub.add('Others Error, Load_Headers');
    oe_debug_pub.add(substr(sqlerrm,1,240));
    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Load_Headers'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Load_Headers;


---------------------------------------------------------------------
-- PROCEDURE Insert_Headers
--
-- BULK Inserts order headers into the OM tables from p_header_rec
---------------------------------------------------------------------

PROCEDURE Insert_Headers
( p_header_rec               IN OE_BULK_ORDER_PVT.HEADER_REC_TYPE
, p_batch_id                 IN NUMBER
)
IS

ctr NUMBER;
l_realtime_cc VARCHAR2(1);

BEGIN
l_realtime_cc := OE_BULK_ORDER_PVT.G_REALTIME_CC_REQUIRED;
ctr := p_header_rec.header_id.count;

FORALL i IN 1..ctr
     INSERT INTO OE_ORDER_HEADERS_ALL
       (ACCOUNTING_RULE_ID
       ,ACCOUNTING_RULE_DURATION
       ,AGREEMENT_ID
       ,ATTRIBUTE1
       ,ATTRIBUTE10
       ,ATTRIBUTE11
       ,ATTRIBUTE12
       ,ATTRIBUTE13
       ,ATTRIBUTE14
       ,ATTRIBUTE15
       ,ATTRIBUTE16   --For bug 2184255
       ,ATTRIBUTE17
       ,ATTRIBUTE18
       ,ATTRIBUTE19
       ,ATTRIBUTE2
       ,ATTRIBUTE20
       ,ATTRIBUTE3
       ,ATTRIBUTE4
       ,ATTRIBUTE5
       ,ATTRIBUTE6
       ,ATTRIBUTE7
       ,ATTRIBUTE8
       ,ATTRIBUTE9
       ,BOOKED_FLAG
       ,BOOKED_DATE
       ,CANCELLED_FLAG
       ,CONTEXT
       ,CONVERSION_RATE
       ,CONVERSION_RATE_DATE
       ,CONVERSION_TYPE_CODE
       --,CUSTOMER_PREFERENCE_SET_CODE
       ,CREATED_BY
       ,CREATION_DATE
       ,CUST_PO_NUMBER
       ,DELIVER_TO_CONTACT_ID
       ,DELIVER_TO_ORG_ID
       ,DEMAND_CLASS_CODE
       --,FIRST_ACK_CODE
       --,FIRST_ACK_DATE
       --,EXPIRATION_DATE
       ,EARLIEST_SCHEDULE_LIMIT
       ,FOB_POINT_CODE
       ,FREIGHT_CARRIER_CODE
       ,FREIGHT_TERMS_CODE
       ,GLOBAL_ATTRIBUTE1
       ,GLOBAL_ATTRIBUTE10
       ,GLOBAL_ATTRIBUTE11
       ,GLOBAL_ATTRIBUTE12
       ,GLOBAL_ATTRIBUTE13
       ,GLOBAL_ATTRIBUTE14
       ,GLOBAL_ATTRIBUTE15
       ,GLOBAL_ATTRIBUTE16
       ,GLOBAL_ATTRIBUTE17
       ,GLOBAL_ATTRIBUTE18
       ,GLOBAL_ATTRIBUTE19
       ,GLOBAL_ATTRIBUTE2
       ,GLOBAL_ATTRIBUTE20
       ,GLOBAL_ATTRIBUTE3
       ,GLOBAL_ATTRIBUTE4
       ,GLOBAL_ATTRIBUTE5
       ,GLOBAL_ATTRIBUTE6
       ,GLOBAL_ATTRIBUTE7
       ,GLOBAL_ATTRIBUTE8
       ,GLOBAL_ATTRIBUTE9
       ,GLOBAL_ATTRIBUTE_CATEGORY
       ,HEADER_ID
       ,INVOICE_TO_CONTACT_ID
       ,INVOICE_TO_ORG_ID
       ,INVOICING_RULE_ID
       --,LAST_ACK_CODE
       --,LAST_ACK_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_DATE
       --,LAST_UPDATE_LOGIN
       ,LATEST_SCHEDULE_LIMIT
       ,OPEN_FLAG
       ,ORDERED_DATE
       ,ORDER_DATE_TYPE_CODE
       ,ORDER_NUMBER
       ,ORDER_SOURCE_ID
       ,ORDER_TYPE_ID
       ,ORDER_CATEGORY_CODE
       ,ORG_ID
       ,ORIG_SYS_DOCUMENT_REF
       ,PARTIAL_SHIPMENTS_ALLOWED
       ,PAYMENT_TERM_ID
       ,PRICE_LIST_ID
       --,PRICE_REQUEST_CODE -- PROMOTIONS SEP/01
       ,PRICING_DATE
       --,PROGRAM_APPLICATION_ID
       --,PROGRAM_ID
       --,PROGRAM_UPDATE_DATE
       ,REQUEST_DATE
       ,REQUEST_ID
       --,RETURN_REASON_CODE
       ,SALESREP_ID
       ,SALES_CHANNEL_CODE
       ,SHIPMENT_PRIORITY_CODE
       ,SHIPPING_METHOD_CODE
       ,SHIP_FROM_ORG_ID
       ,SHIP_TOLERANCE_ABOVE
       ,SHIP_TOLERANCE_BELOW
       ,SHIP_TO_CONTACT_ID
       ,SHIP_TO_ORG_ID
       ,SOLD_FROM_ORG_ID
       ,SOLD_TO_CONTACT_ID
       ,SOLD_TO_ORG_ID
       --,SOURCE_DOCUMENT_ID
       --,SOURCE_DOCUMENT_TYPE_ID
       ,TAX_EXEMPT_FLAG
       ,TAX_EXEMPT_NUMBER
       ,TAX_EXEMPT_REASON_CODE
       ,TAX_POINT_CODE
       ,TRANSACTIONAL_CURR_CODE
       ,VERSION_NUMBER
       ,PAYMENT_TYPE_CODE
       ,PAYMENT_AMOUNT
       ,CHECK_NUMBER
       ,CREDIT_CARD_CODE
       ,CREDIT_CARD_HOLDER_NAME
       ,CREDIT_CARD_NUMBER
       ,CREDIT_CARD_EXPIRATION_DATE
       ,CREDIT_CARD_APPROVAL_DATE
       ,CREDIT_CARD_APPROVAL_CODE
       ,CHANGE_SEQUENCE
       --,DROP_SHIP_FLAG
       --,CUSTOMER_PAYMENT_TERM_ID
       ,SHIPPING_INSTRUCTIONS
       ,PACKING_INSTRUCTIONS
       ,FLOW_STATUS_CODE
       --,MARKETING_SOURCE_CODE_ID
       ,TP_ATTRIBUTE1
       ,TP_ATTRIBUTE10
       ,TP_ATTRIBUTE11
       ,TP_ATTRIBUTE12
       ,TP_ATTRIBUTE13
       ,TP_ATTRIBUTE14
       ,TP_ATTRIBUTE15
       ,TP_ATTRIBUTE2
       ,TP_ATTRIBUTE3
       ,TP_ATTRIBUTE4
       ,TP_ATTRIBUTE5
       ,TP_ATTRIBUTE6
       ,TP_ATTRIBUTE7
       ,TP_ATTRIBUTE8
       ,TP_ATTRIBUTE9
       ,TP_CONTEXT
       --,upgraded_flag
       ,LOCK_CONTROL
       ,XML_MESSAGE_ID
       ,BATCH_ID
       -- QUOTING changes
       ,TRANSACTION_PHASE_CODE
  -- abghosh
       ,sold_to_site_use_id
       --End Customer changes (Bug 5054618)
       ,End_customer_contact_id
	,End_customer_id
	,End_customer_site_use_id
	,IB_owner
	,IB_current_location
	,IB_Installed_at_Location
       )
     VALUES
       (p_header_rec.accounting_rule_id(i)
       ,p_header_rec.accounting_rule_duration(i)
       ,p_header_rec.agreement_id(i)
       ,p_header_rec.attribute1(i)
       ,p_header_rec.attribute10(i)
       ,p_header_rec.attribute11(i)
       ,p_header_rec.attribute12(i)
       ,p_header_rec.attribute13(i)
       ,p_header_rec.attribute14(i)
       ,p_header_rec.attribute15(i)
       ,p_header_rec.attribute16(i)   --For bug 2184255
       ,p_header_rec.attribute17(i)
       ,p_header_rec.attribute18(i)
       ,p_header_rec.attribute19(i)
       ,p_header_rec.attribute2(i)
       ,p_header_rec.attribute20(i)
       ,p_header_rec.attribute3(i)
       ,p_header_rec.attribute4(i)
       ,p_header_rec.attribute5(i)
       ,p_header_rec.attribute6(i)
       ,p_header_rec.attribute7(i)
       ,p_header_rec.attribute8(i)
       ,p_header_rec.attribute9(i)
       ,DECODE(l_realtime_cc,'Y','N',p_header_rec.booked_flag(i)) -- added for HVOP CC support
       ,decode(p_header_rec.booked_flag(i),'Y',sysdate,null) -- p_header_rec.booked_date(i)
       ,'N'                                   -- p_header_rec.cancelled_flag(i)
       ,p_header_rec.context(i)
       ,p_header_rec.conversion_rate(i)
       ,p_header_rec.conversion_rate_date(i)
       ,p_header_rec.conversion_type_code(i)
       --,p_header_rec.CUSTOMER_PREFERENCE_SET_CODE(i)
       ,FND_GLOBAL.USER_ID                    -- p_header_rec.created_by(i)
       ,sysdate                               -- p_header_rec.creation_date(i)
       ,p_header_rec.cust_po_number(i)
       ,p_header_rec.deliver_to_contact_id(i)
       ,p_header_rec.deliver_to_org_id(i)
       ,p_header_rec.demand_class_code(i)
       -- p_header_rec.first_ack_code(i)
       --,p_header_rec.first_ack_date(i)
       --,p_header_rec.expiration_date(i)
       ,p_header_rec.earliest_schedule_limit(i)
       ,p_header_rec.fob_point_code(i)
       ,p_header_rec.freight_carrier_code(i)
       ,p_header_rec.freight_terms_code(i)
       ,p_header_rec.global_attribute1(i)
       ,p_header_rec.global_attribute10(i)
       ,p_header_rec.global_attribute11(i)
       ,p_header_rec.global_attribute12(i)
       ,p_header_rec.global_attribute13(i)
       ,p_header_rec.global_attribute14(i)
       ,p_header_rec.global_attribute15(i)
       ,p_header_rec.global_attribute16(i)
       ,p_header_rec.global_attribute17(i)
       ,p_header_rec.global_attribute18(i)
       ,p_header_rec.global_attribute19(i)
       ,p_header_rec.global_attribute2(i)
       ,p_header_rec.global_attribute20(i)
       ,p_header_rec.global_attribute3(i)
       ,p_header_rec.global_attribute4(i)
       ,p_header_rec.global_attribute5(i)
       ,p_header_rec.global_attribute6(i)
       ,p_header_rec.global_attribute7(i)
       ,p_header_rec.global_attribute8(i)
       ,p_header_rec.global_attribute9(i)
       ,p_header_rec.global_attribute_category(i)
       ,p_header_rec.header_id(i)
       ,p_header_rec.invoice_to_contact_id(i)
       ,p_header_rec.invoice_to_org_id(i)
       ,p_header_rec.invoicing_rule_id(i)
       --,p_header_rec.last_ack_code(i)
       --,p_header_rec.last_ack_date(i)
       ,FND_GLOBAL.USER_ID                  -- p_header_rec.last_updated_by(i)
       ,sysdate                             -- p_header_rec.last_update_date(i)
       --,p_header_rec.last_update_login(i)
       ,p_header_rec.latest_schedule_limit(i)
       ,'Y'                                 -- p_header_rec.open_flag(i)
       ,p_header_rec.ordered_date(i)
       ,p_header_rec.order_date_type_code(i)
       ,p_header_rec.order_number(i)
       ,p_header_rec.order_source_id(i)
       ,p_header_rec.order_type_id(i)
       ,p_header_rec.order_category_code(i)
       ,p_header_rec.org_id(i)
       ,p_header_rec.orig_sys_document_ref(i)
       ,p_header_rec.partial_shipments_allowed(i)
       ,p_header_rec.payment_term_id(i)
       ,p_header_rec.price_list_id(i)
       --,p_header_rec.price_request_code(i) -- PROMOTIONS SEP/01
       ,p_header_rec.pricing_date(i)
       --,p_header_rec.program_application_id(i)
       --,p_header_rec.program_id(i)
       --,p_header_rec.program_update_date(i)
       ,p_header_rec.request_date(i)
       ,OE_BULK_ORDER_PVT.G_REQUEST_ID           -- p_header_rec.request_id(i)
       --,p_header_rec.return_reason_code(i)
       ,p_header_rec.salesrep_id(i)
       ,p_header_rec.sales_channel_code(i)
       ,p_header_rec.shipment_priority_code(i)
       ,p_header_rec.shipping_method_code(i)
       ,p_header_rec.ship_from_org_id(i)
       ,p_header_rec.ship_tolerance_above(i)
       ,p_header_rec.ship_tolerance_below(i)
       ,p_header_rec.ship_to_contact_id(i)
       ,p_header_rec.ship_to_org_id(i)
       ,OE_GLOBALS.G_ORG_ID
       ,p_header_rec.sold_to_contact_id(i)
       ,p_header_rec.sold_to_org_id(i)
       --,p_header_rec.source_document_id(i)
       --,p_header_rec.source_document_type_id(i)
       ,p_header_rec.tax_exempt_flag(i)
       ,p_header_rec.tax_exempt_number(i)
       ,p_header_rec.tax_exempt_reason_code(i)
       ,p_header_rec.tax_point_code(i)
       ,p_header_rec.transactional_curr_code(i)
       ,p_header_rec.version_number(i)
       ,p_header_rec.payment_type_code(i)
       ,p_header_rec.payment_amount(i)
       ,p_header_rec.check_number(i)
       ,p_header_rec.credit_card_code(i)
       ,p_header_rec.credit_card_holder_name(i)
       ,p_header_rec.credit_card_number(i)
       ,p_header_rec.credit_card_expiration_date(i)
       ,p_header_rec.credit_card_approval_date(i)
       ,p_header_rec.credit_card_approval_code(i)
       ,p_header_rec.change_sequence(i)
       --,p_header_rec.drop_ship_flag(i)
       --,p_header_rec.customer_payment_term_id(i)
       ,p_header_rec.shipping_instructions(i)
       ,p_header_rec.packing_instructions(i)
       ,decode(p_header_rec.booked_flag(i)
               ,'Y','BOOKED','ENTERED') -- ,p_header_rec.FLOW_STATUS_CODE(i)
       --,p_header_rec.marketing_source_code_id(i)
       ,p_header_rec.tp_attribute1(i)
       ,p_header_rec.tp_attribute10(i)
       ,p_header_rec.tp_attribute11(i)
       ,p_header_rec.tp_attribute12(i)
       ,p_header_rec.tp_attribute13(i)
       ,p_header_rec.tp_attribute14(i)
       ,p_header_rec.tp_attribute15(i)
       ,p_header_rec.tp_attribute2(i)
       ,p_header_rec.tp_attribute3(i)
       ,p_header_rec.tp_attribute4(i)
       ,p_header_rec.tp_attribute5(i)
       ,p_header_rec.tp_attribute6(i)
       ,p_header_rec.tp_attribute7(i)
       ,p_header_rec.tp_attribute8(i)
       ,p_header_rec.tp_attribute9(i)
       ,p_header_rec.tp_context(i)
       -- ,l_upgraded_flag(i)
       ,p_header_rec.lock_control(i)
       ,p_header_rec.xml_message_id(i)
       ,p_batch_id
       -- QUOTING changes
       -- Negotiation orders not supported with HVOP
       -- insert fulfillment (F) for transaction phase
       ,'F'
   --abghosh
       ,p_header_rec.sold_to_site_use_id(i)
-- end customer (Bug 5054618)
 ,p_header_rec.End_customer_contact_id(i)
 ,p_header_rec.End_customer_id(i)
 ,p_header_rec.End_customer_site_use_id(i)
 ,p_header_rec.IB_owner(i)
 ,p_header_rec.IB_current_location(i)
 ,p_header_rec.IB_Installed_at_Location(i)
       );

EXCEPTION
  WHEN OTHERS THEN
    oe_debug_pub.add('Others Error, Insert_Headers');
    oe_debug_pub.add(substr(sqlerrm,1,240));
    OE_BULK_MSG_PUB.Add_Exc_Msg
      (G_PKG_NAME
      ,'Insert_Headers'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Insert_Headers;


---------------------------------------------------------------------
-- PROCEDURE Create_Header_Scredits
--
-- BULK Inserts header sales credits into the OM tables from
-- p_header_scredit_rec
---------------------------------------------------------------------

PROCEDURE Create_Header_Scredits
(p_header_scredit_rec             IN OE_BULK_ORDER_PVT.SCREDIT_REC_TYPE
)
IS
BEGIN

  IF p_header_scredit_rec.header_id.COUNT = 0 THEN
     RETURN;
  END IF;

  FORALL I IN p_header_scredit_rec.header_id.FIRST..p_header_scredit_rec.header_id.LAST
    INSERT  INTO OE_SALES_CREDITS
    (
            CREATED_BY
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
    ,       ORIG_SYS_CREDIT_REF
    ,       LOCK_CONTROL
    )
    VALUES
    (
            FND_GLOBAL.USER_ID
    ,       sysdate
    ,       NULL
    ,       p_header_scredit_rec.header_id(i)
    ,       FND_GLOBAL.USER_ID
    ,       sysdate
    ,       FND_GLOBAL.USER_ID
    ,       NULL
    ,       100
    ,       p_header_scredit_rec.salesrep_id(i)
    ,       nvl(p_header_scredit_rec.Sales_Credit_Type_id(i),1)
    ,       OE_SALES_CREDITS_S.nextval
    ,       NULL
    ,       NULL
    ,       1
    );

EXCEPTION
  WHEN OTHERS THEN
    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Create_Header_Scredits'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Create_Header_Scredits;

END OE_BULK_HEADER_UTIL;

/
