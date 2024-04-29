--------------------------------------------------------
--  DDL for Package Body OE_BULK_LINE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BULK_LINE_UTIL" AS
/* $Header: OEBULINB.pls 120.5.12010000.5 2008/11/30 21:44:21 smusanna ship $ */

G_PKG_NAME         CONSTANT     VARCHAR2(30):='OE_BULK_LINE_UTIL';


TYPE Kit_Item_Rec_Type IS RECORD
  ( ii_count                  NUMBER
  , ii_start_index            NUMBER
  );

TYPE Kit_Item_Tbl_Type IS TABLE OF Kit_Item_Rec_Type
INDEX BY BINARY_INTEGER;

TYPE Inc_Item_Rec_Type IS RECORD
   ( component_code           VARCHAR2(30)
   , component_sequence_id    NUMBER
   , component_item_id        NUMBER
   , extended_quantity        NUMBER
   , primary_uom_code         VARCHAR2(3)
   , ordered_item             VARCHAR2(30)
   , sort_order               VARCHAR2(2000) -- 4336446
   , shippable_flag           VARCHAR2(1)
   );
TYPE Inc_Item_Tbl_Type IS TABLE OF Inc_Item_Rec_Type
INDEX BY BINARY_INTEGER;

G_KIT_ITEM_TBL              Kit_Item_Tbl_Type;
G_INC_ITEM_TBL              Inc_Item_Tbl_Type;

---------------------------------------------------------------------
-- PROCEDURE Load_Lines
--
-- Loads order lines in the batch from interface tables to
-- the record - p_line_rec
---------------------------------------------------------------------

PROCEDURE Load_Lines
( p_batch_id                   IN  NUMBER
 ,p_process_configurations IN VARCHAR2
 ,p_line_rec                   IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
)
IS

CURSOR c_lines IS
    SELECT /*+ ORDERED USE_NL(H L) USE_INDEX(H OE_HEADERS_IFACE_ALL_N2) */
            L.ACCOUNTING_RULE_ID
    ,       L.ACCOUNTING_RULE_DURATION
    ,       L.ACTUAL_ARRIVAL_DATE
     -- ,       L.ACTUAL_SHIPMENT_DATE
    ,       L.AGREEMENT_ID
    ,       L.ARRIVAL_SET_ID
    ,       L.ATO_LINE_ID
    ,       L.ATTRIBUTE1
    ,       L.ATTRIBUTE10
    ,       L.ATTRIBUTE11
    ,       L.ATTRIBUTE12
    ,       L.ATTRIBUTE13
    ,       L.ATTRIBUTE14
    ,       L.ATTRIBUTE15
    ,       L.ATTRIBUTE16   --For bug 2184255
    ,       L.ATTRIBUTE17
    ,       L.ATTRIBUTE18
    ,       L.ATTRIBUTE19
    ,       L.ATTRIBUTE2
    ,       L.ATTRIBUTE20
    ,       L.ATTRIBUTE3
    ,       L.ATTRIBUTE4
    ,       L.ATTRIBUTE5
    ,       L.ATTRIBUTE6
    ,       L.ATTRIBUTE7
    ,       L.ATTRIBUTE8
    ,       L.ATTRIBUTE9
     -- ,       L.AUTO_SELECTED_QUANTITY
    ,       L.AUTHORIZED_TO_SHIP_FLAG
    ,       NULL                          -- L.BOOKED_FLAG
    ,       'N'                           -- L.CANCELLED_FLAG
    ,       L.CANCELLED_QUANTITY
    ,       L.COMPONENT_CODE
    ,       NULL                          -- L.COMPONENT_NUMBER
    ,       L.COMPONENT_SEQUENCE_ID
    ,       L.CONFIG_HEADER_ID
    ,       L.CONFIG_REV_NBR
    ,null   -- ,       L.CONFIG_DISPLAY_SEQUENCE
    ,       L.CONFIGURATION_ID
    ,       L.CONTEXT
     -- ,       L.CREATED_BY
     -- ,       L.CREATION_DATE
    ,       L.CREDIT_INVOICE_LINE_ID
    ,       L.CUSTOMER_DOCK_CODE
    ,       L.CUSTOMER_JOB
    ,       L.CUSTOMER_PRODUCTION_LINE
    ,       L.CUST_PRODUCTION_SEQ_NUM
     -- ,       L.CUSTOMER_TRX_LINE_ID
    ,       L.CUST_MODEL_SERIAL_NUMBER
    ,       L.CUSTOMER_PO_NUMBER
    ,       L.CUSTOMER_LINE_NUMBER
    ,       L.DELIVERY_LEAD_TIME
    ,       L.DELIVER_TO_CONTACT_ID
    ,       L.DELIVER_TO_ORG_ID
    ,       L.DEMAND_BUCKET_TYPE_CODE
    ,       L.DEMAND_CLASS_CODE
     -- ,       L.DEP_PLAN_REQUIRED_FLAG
    ,       L.EARLIEST_ACCEPTABLE_DATE
    ,       L.END_ITEM_UNIT_NUMBER
    ,       L.EXPLOSION_DATE
     -- ,       L.FIRST_ACK_CODE
     -- ,       L.FIRST_ACK_DATE
    ,       L.FOB_POINT_CODE
    ,       NULL                                --L.FREIGHT_CARRIER_CODE for bug 3610475
    ,       L.FREIGHT_TERMS_CODE
     -- ,       L.FULFILLED_QUANTITY
     -- ,       L.FULFILLED_FLAG
     -- ,       L.FULFILLMENT_METHOD_CODE
     -- ,       L.FULFILLMENT_DATE
    ,       L.GLOBAL_ATTRIBUTE1
    ,       L.GLOBAL_ATTRIBUTE10
    ,       L.GLOBAL_ATTRIBUTE11
    ,       L.GLOBAL_ATTRIBUTE12
    ,       L.GLOBAL_ATTRIBUTE13
    ,       L.GLOBAL_ATTRIBUTE14
    ,       L.GLOBAL_ATTRIBUTE15
    ,       L.GLOBAL_ATTRIBUTE16
    ,       L.GLOBAL_ATTRIBUTE17
    ,       L.GLOBAL_ATTRIBUTE18
    ,       L.GLOBAL_ATTRIBUTE19
    ,       L.GLOBAL_ATTRIBUTE2
    ,       L.GLOBAL_ATTRIBUTE20
    ,       L.GLOBAL_ATTRIBUTE3
    ,       L.GLOBAL_ATTRIBUTE4
    ,       L.GLOBAL_ATTRIBUTE5
    ,       L.GLOBAL_ATTRIBUTE6
    ,       L.GLOBAL_ATTRIBUTE7
    ,       L.GLOBAL_ATTRIBUTE8
    ,       L.GLOBAL_ATTRIBUTE9
    ,       L.GLOBAL_ATTRIBUTE_CATEGORY
    ,       NULL                           -- L.HEADER_ID
    ,       L.INDUSTRY_ATTRIBUTE1
    ,       L.INDUSTRY_ATTRIBUTE10
    ,       L.INDUSTRY_ATTRIBUTE11
    ,       L.INDUSTRY_ATTRIBUTE12
    ,       L.INDUSTRY_ATTRIBUTE13
    ,       L.INDUSTRY_ATTRIBUTE14
    ,       L.INDUSTRY_ATTRIBUTE15
    ,       L.INDUSTRY_ATTRIBUTE16
    ,       L.INDUSTRY_ATTRIBUTE17
    ,       L.INDUSTRY_ATTRIBUTE18
    ,       L.INDUSTRY_ATTRIBUTE19
    ,       L.INDUSTRY_ATTRIBUTE20
    ,       L.INDUSTRY_ATTRIBUTE21
    ,       L.INDUSTRY_ATTRIBUTE22
    ,       L.INDUSTRY_ATTRIBUTE23
    ,       L.INDUSTRY_ATTRIBUTE24
    ,       L.INDUSTRY_ATTRIBUTE25
    ,       L.INDUSTRY_ATTRIBUTE26
    ,       L.INDUSTRY_ATTRIBUTE27
    ,       L.INDUSTRY_ATTRIBUTE28
    ,       L.INDUSTRY_ATTRIBUTE29
    ,       L.INDUSTRY_ATTRIBUTE30
    ,       L.INDUSTRY_ATTRIBUTE2
    ,       L.INDUSTRY_ATTRIBUTE3
    ,       L.INDUSTRY_ATTRIBUTE4
    ,       L.INDUSTRY_ATTRIBUTE5
    ,       L.INDUSTRY_ATTRIBUTE6
    ,       L.INDUSTRY_ATTRIBUTE7
    ,       L.INDUSTRY_ATTRIBUTE8
    ,       L.INDUSTRY_ATTRIBUTE9
    ,       L.INDUSTRY_CONTEXT
     -- ,       L.INTERMED_SHIP_TO_CONTACT_ID
     -- ,       L.INTERMED_SHIP_TO_ORG_ID
    ,       L.INVENTORY_ITEM_ID
     -- ,       L.INVOICE_INTERFACE_STATUS_CODE
    ,       L.INVOICE_TO_CONTACT_ID
    ,       L.INVOICE_TO_ORG_ID
     -- ,       L.INVOICED_QUANTITY
    ,       L.INVOICING_RULE_ID
    ,       L.CUSTOMER_ITEM_ID           -- L.ORDERED_ITEM_ID
    ,       L.CUSTOMER_ITEM_ID_TYPE      -- L.ITEM_IDENTIFIER_TYPE
    ,       L.CUSTOMER_ITEM_NAME         -- L.ORDERED_ITEM
    ,       L.CUSTOMER_ITEM_NET_PRICE
    ,       L.CUSTOMER_PAYMENT_TERM_ID
    ,       L.ITEM_REVISION
    ,       L.ITEM_TYPE_CODE
     -- ,       L.LAST_ACK_CODE
     -- ,       L.LAST_ACK_DATE
     -- ,       L.LAST_UPDATED_BY
     -- ,       L.LAST_UPDATE_DATE
     -- ,       L.LAST_UPDATE_LOGIN
    ,       L.LATEST_ACCEPTABLE_DATE
    ,       NULL                         -- L.LINE_CATEGORY_CODE
    -- Use pre-generated line_id value from interface tables
    ,       L.LINE_ID
    ,       L.LINE_NUMBER
    ,       L.LINE_TYPE_ID
    ,       NULL                         -- L.LINK_TO_LINE_ID
    ,       L.MODEL_GROUP_NUMBER
    ,       NULL                         -- L.MFG_LEAD_TIME
     -- ,       L.OPEN_FLAG
    ,       L.OPTION_FLAG
    ,       L.OPTION_NUMBER
    ,       L.ORDERED_QUANTITY
    ,       L.ORDERED_QUANTITY2              --OPM 02/JUN/00
    ,       L.ORDER_QUANTITY_UOM
    ,       L.ORDERED_QUANTITY_UOM2          --OPM 02/JUN/00
    ,       L.ORG_ID
    ,       L.ORIG_SYS_DOCUMENT_REF
    ,       L.ORIG_SYS_LINE_REF
    ,       L.ORIG_SYS_SHIPMENT_REF
    ,       L.CHANGE_SEQUENCE
    ,       L.OVER_SHIP_REASON_CODE
    ,       L.OVER_SHIP_RESOLVED_FLAG
    ,       L.PAYMENT_TERM_ID
     -- ,       L.PLANNING_PRIORITY
    ,       L.PREFERRED_GRADE                --OPM HVOP
    ,       L.PRICE_LIST_ID
     -- ,       L.PRICE_REQUEST_CODE             --PROMOTIONS MAY/01
    ,       L.PRICING_ATTRIBUTE1
    ,       L.PRICING_ATTRIBUTE10
    ,       L.PRICING_ATTRIBUTE2
    ,       L.PRICING_ATTRIBUTE3
    ,       L.PRICING_ATTRIBUTE4
    ,       L.PRICING_ATTRIBUTE5
    ,       L.PRICING_ATTRIBUTE6
    ,       L.PRICING_ATTRIBUTE7
    ,       L.PRICING_ATTRIBUTE8
    ,       L.PRICING_ATTRIBUTE9
    ,       L.PRICING_CONTEXT
    ,       L.PRICING_DATE
    ,       L.PRICING_QUANTITY
    ,       L.PRICING_QUANTITY_UOM
     -- ,       L.PROGRAM_APPLICATION_ID
     -- ,       L.PROGRAM_ID
     -- ,       L.PROGRAM_UPDATE_DATE
    ,       L.PROJECT_ID
    ,       L.PROMISE_DATE
    ,       NULL                           --  L.RE_SOURCE_FLAG
     -- ,       L.REFERENCE_CUSTOMER_TRX_LINE_ID
    ,       L.REFERENCE_HEADER_ID
    ,       L.REFERENCE_LINE_ID
    ,       L.REFERENCE_TYPE
    ,       L.REQUEST_DATE
    ,       L.REQUEST_ID
    ,       L.RETURN_ATTRIBUTE1
    ,       L.RETURN_ATTRIBUTE10
    ,       L.RETURN_ATTRIBUTE11
    ,       L.RETURN_ATTRIBUTE12
    ,       L.RETURN_ATTRIBUTE13
    ,       L.RETURN_ATTRIBUTE14
    ,       L.RETURN_ATTRIBUTE15
    ,       L.RETURN_ATTRIBUTE2
    ,       L.RETURN_ATTRIBUTE3
    ,       L.RETURN_ATTRIBUTE4
    ,       L.RETURN_ATTRIBUTE5
    ,       L.RETURN_ATTRIBUTE6
    ,       L.RETURN_ATTRIBUTE7
    ,       L.RETURN_ATTRIBUTE8
    ,       L.RETURN_ATTRIBUTE9
    ,       L.RETURN_CONTEXT
    ,       L.RETURN_REASON_CODE
     -- ,       L.RLA_SCHEDULE_TYPE_CODE
    ,       L.SALESREP_ID
    ,       L.SCHEDULE_ARRIVAL_DATE
    ,       L.SCHEDULE_SHIP_DATE
    ,       L.SCHEDULE_STATUS_CODE
    ,       L.SHIPMENT_NUMBER
    ,       L.SHIPMENT_PRIORITY_CODE
    ,       L.SHIPPED_QUANTITY
    ,       L.SHIPPED_QUANTITY2 -- OPM B1661023 04/02/01
    ,       L.SHIPPING_METHOD_CODE
    ,       L.SHIPPING_QUANTITY
    ,       L.SHIPPING_QUANTITY2 -- OPM B1661023 04/02/01
    ,       L.SHIPPING_QUANTITY_UOM
    ,       L.SHIP_FROM_ORG_ID
    ,       L.SUBINVENTORY
    ,       L.SHIP_SET_ID
    ,       L.SHIP_TOLERANCE_ABOVE
    ,       L.SHIP_TOLERANCE_BELOW
    ,       NULL                           -- L.SHIPPABLE_FLAG
     -- ,       L.SHIPPING_INTERFACED_FLAG
    ,       L.SHIP_TO_CONTACT_ID
    ,       L.SHIP_TO_ORG_ID
    ,       L.SHIP_MODEL_COMPLETE_FLAG
    ,       L.SOLD_TO_ORG_ID
    ,       L.SOLD_FROM_ORG_ID
    ,       L.SORT_ORDER
    ,       NULL                           -- L.SOURCE_DOCUMENT_ID
     -- ,       L.SOURCE_DOCUMENT_LINE_ID
     -- ,       L.SOURCE_DOCUMENT_TYPE_ID
    ,       L.SOURCE_TYPE_CODE
    ,       L.SPLIT_FROM_LINE_ID
     -- ,       L.LINE_SET_ID
     -- ,       L.SPLIT_BY
    ,'N'  --    L.MODEL_REMNANT_FLAG
    ,       L.TASK_ID
    ,       L.TAX_CODE
    ,       L.TAX_DATE
    ,       L.TAX_EXEMPT_FLAG
    ,       L.TAX_EXEMPT_NUMBER
    ,       L.TAX_EXEMPT_REASON_CODE
    ,       L.TAX_POINT_CODE
     -- ,       L.TAX_RATE
    ,       L.TAX_VALUE
    ,       NULL                           -- L.TOP_MODEL_LINE_ID
    ,       L.UNIT_LIST_PRICE
    ,       L.UNIT_LIST_PRICE_PER_PQTY
    ,       L.UNIT_SELLING_PRICE
    ,       L.UNIT_SELLING_PRICE_PER_PQTY
    ,       NULL                           -- L.VISIBLE_DEMAND_FLAG
    ,       L.VEH_CUS_ITEM_CUM_KEY_ID
    ,       L.SHIPPING_INSTRUCTIONS
    ,       L.PACKING_INSTRUCTIONS
    ,       L.SERVICE_TXN_REASON_CODE
    ,       L.SERVICE_TXN_COMMENTS
    ,       L.SERVICE_DURATION
    ,       L.SERVICE_PERIOD
    ,       L.SERVICE_START_DATE
    ,       L.SERVICE_END_DATE
    ,       L.SERVICE_COTERMINATE_FLAG
    ,       L.UNIT_LIST_PERCENT
    ,       L.UNIT_SELLING_PERCENT
    ,       L.UNIT_PERCENT_BASE_PRICE
    ,       L.SERVICE_NUMBER
    ,       L.SERVICE_REFERENCE_TYPE_CODE
     -- ,       L.SERVICE_REFERENCE_LINE_ID
     -- ,       L.SERVICE_REFERENCE_SYSTEM_ID
    ,       L.TP_CONTEXT
    ,       L.TP_ATTRIBUTE1
    ,       L.TP_ATTRIBUTE2
    ,       L.TP_ATTRIBUTE3
    ,       L.TP_ATTRIBUTE4
    ,       L.TP_ATTRIBUTE5
    ,       L.TP_ATTRIBUTE6
    ,       L.TP_ATTRIBUTE7
    ,       L.TP_ATTRIBUTE8
    ,       L.TP_ATTRIBUTE9
    ,       L.TP_ATTRIBUTE10
    ,       L.TP_ATTRIBUTE11
    ,       L.TP_ATTRIBUTE12
    ,       L.TP_ATTRIBUTE13
    ,       L.TP_ATTRIBUTE14
    ,       L.TP_ATTRIBUTE15
     -- ,       L.FLOW_STATUS_CODE
     -- ,       L.MARKETING_SOURCE_CODE_ID
    ,       L.CALCULATE_PRICE_FLAG
    ,       L.COMMITMENT_ID
    ,       L.ORDER_SOURCE_ID      -- aksingh
     -- ,    L.upgraded_flag
    ,       1                      -- L.LOCK_CONTROL
    ,       NULL                   -- wf_process_name
    ,       NULL                   --- ii_start_index
    ,       NULL                   -- ii_count
    ,       L.user_item_description
    ,       NULL                   -- parent_line_index
    ,       NULL                   -- Firm Demand flag
    -- end customer (Bug 5054618)
				,L.End_customer_contact_id
				,L.End_customer_id
				,L.End_customer_site_use_id
				,L.IB_owner_code
				,L.IB_current_location_code
				,L.IB_Installed_at_Location_code
    ,       NULL                   -- cust_trx_type_id
    ,       NULL                   -- tax_calculation_flag
    ,       NULL                   -- ato_line_index
    ,       NULL                   -- top_model_line_index
    FROM    OE_HEADERS_IFACE_ALL H, OE_LINES_IFACE_ALL L
    WHERE   h.batch_id = p_batch_id
      AND   h.order_source_id = l.order_source_id
      AND   h.orig_sys_document_ref = l.orig_sys_document_ref
      AND   nvl(h.error_flag,'N') = 'N'
      AND   nvl(l.error_flag,'N') = 'N'
      AND   nvl(l.rejected_flag,'N') = 'N'
      AND NVL(h.Ineligible_for_hvop,'N')<>'Y'
    ORDER BY l.order_source_id
            ,l.orig_sys_document_ref
	    , l.orig_sys_line_ref
	    ,l.orig_sys_shipment_ref;

CURSOR c_lines_rtrim IS
    SELECT /*+ ORDERED USE_NL(H L) USE_INDEX(H OE_HEADERS_IFACE_ALL_N2) */
            L.ACCOUNTING_RULE_ID
    ,       L.ACCOUNTING_RULE_DURATION
    ,       L.ACTUAL_ARRIVAL_DATE
     -- ,       L.ACTUAL_SHIPMENT_DATE
    ,       L.AGREEMENT_ID
    ,       L.ARRIVAL_SET_ID
    ,       L.ATO_LINE_ID
    ,       L.ATTRIBUTE1
    ,       L.ATTRIBUTE10
    ,       L.ATTRIBUTE11
    ,       L.ATTRIBUTE12
    ,       L.ATTRIBUTE13
    ,       L.ATTRIBUTE14
    ,       L.ATTRIBUTE15
    ,       L.ATTRIBUTE16   --For bug 2184255
    ,       L.ATTRIBUTE17
    ,       L.ATTRIBUTE18
    ,       L.ATTRIBUTE19
    ,       L.ATTRIBUTE2
    ,       L.ATTRIBUTE20
    ,       L.ATTRIBUTE3
    ,       L.ATTRIBUTE4
    ,       L.ATTRIBUTE5
    ,       L.ATTRIBUTE6
    ,       L.ATTRIBUTE7
    ,       L.ATTRIBUTE8
    ,       L.ATTRIBUTE9
     -- ,       L.AUTO_SELECTED_QUANTITY
    ,       L.AUTHORIZED_TO_SHIP_FLAG
    ,       NULL                          -- L.BOOKED_FLAG
    ,       'N'                           -- L.CANCELLED_FLAG
    ,       L.CANCELLED_QUANTITY
    ,       L.COMPONENT_CODE
    ,       NULL                          -- L.COMPONENT_NUMBER
    ,       L.COMPONENT_SEQUENCE_ID
     -- ,       L.CONFIG_HEADER_ID
     -- ,       L.CONFIG_REV_NBR
     -- ,       L.CONFIG_DISPLAY_SEQUENCE
     -- ,       L.CONFIGURATION_ID
    ,       L.CONTEXT
     -- ,       L.CREATED_BY
     -- ,       L.CREATION_DATE
    ,       L.CREDIT_INVOICE_LINE_ID
    ,       RTRIM(L.CUSTOMER_DOCK_CODE,' ') -- 3390458
    ,       RTRIM(L.CUSTOMER_JOB, ' ') -- 3390458
    ,       RTRIM(L.CUSTOMER_PRODUCTION_LINE, ' ') -- 3390458
    ,       RTRIM(L.CUST_PRODUCTION_SEQ_NUM, ' ') -- 3390458
     -- ,       L.CUSTOMER_TRX_LINE_ID
    ,       RTRIM(L.CUST_MODEL_SERIAL_NUMBER,' ') -- 3390458
    ,       RTRIM(L.CUSTOMER_PO_NUMBER,' ') -- 3390458
    ,       L.CUSTOMER_LINE_NUMBER
    ,       L.DELIVERY_LEAD_TIME
    ,       L.DELIVER_TO_CONTACT_ID
    ,       L.DELIVER_TO_ORG_ID
    ,       L.DEMAND_BUCKET_TYPE_CODE
    ,       L.DEMAND_CLASS_CODE
     -- ,       L.DEP_PLAN_REQUIRED_FLAG
    ,       L.EARLIEST_ACCEPTABLE_DATE
    ,       RTRIM(L.END_ITEM_UNIT_NUMBER,' ') -- 3390458
    ,       L.EXPLOSION_DATE
     -- ,       L.FIRST_ACK_CODE
     -- ,       L.FIRST_ACK_DATE
    ,       L.FOB_POINT_CODE
    ,       NULL                          --L.FREIGHT_CARRIER_CODE for bug 3610475
    ,       L.FREIGHT_TERMS_CODE
     -- ,       L.FULFILLED_QUANTITY
     -- ,       L.FULFILLED_FLAG
     -- ,       L.FULFILLMENT_METHOD_CODE
     -- ,       L.FULFILLMENT_DATE
    ,       L.GLOBAL_ATTRIBUTE1
    ,       L.GLOBAL_ATTRIBUTE10
    ,       L.GLOBAL_ATTRIBUTE11
    ,       L.GLOBAL_ATTRIBUTE12
    ,       L.GLOBAL_ATTRIBUTE13
    ,       L.GLOBAL_ATTRIBUTE14
    ,       L.GLOBAL_ATTRIBUTE15
    ,       L.GLOBAL_ATTRIBUTE16
    ,       L.GLOBAL_ATTRIBUTE17
    ,       L.GLOBAL_ATTRIBUTE18
    ,       L.GLOBAL_ATTRIBUTE19
    ,       L.GLOBAL_ATTRIBUTE2
    ,       L.GLOBAL_ATTRIBUTE20
    ,       L.GLOBAL_ATTRIBUTE3
    ,       L.GLOBAL_ATTRIBUTE4
    ,       L.GLOBAL_ATTRIBUTE5
    ,       L.GLOBAL_ATTRIBUTE6
    ,       L.GLOBAL_ATTRIBUTE7
    ,       L.GLOBAL_ATTRIBUTE8
    ,       L.GLOBAL_ATTRIBUTE9
    ,       L.GLOBAL_ATTRIBUTE_CATEGORY
    ,       NULL                           -- L.HEADER_ID
    ,       L.INDUSTRY_ATTRIBUTE1
    ,       L.INDUSTRY_ATTRIBUTE10
    ,       L.INDUSTRY_ATTRIBUTE11
    ,       L.INDUSTRY_ATTRIBUTE12
    ,       L.INDUSTRY_ATTRIBUTE13
    ,       L.INDUSTRY_ATTRIBUTE14
    ,       L.INDUSTRY_ATTRIBUTE15
    ,       L.INDUSTRY_ATTRIBUTE16
    ,       L.INDUSTRY_ATTRIBUTE17
    ,       L.INDUSTRY_ATTRIBUTE18
    ,       L.INDUSTRY_ATTRIBUTE19
    ,       L.INDUSTRY_ATTRIBUTE20
    ,       L.INDUSTRY_ATTRIBUTE21
    ,       L.INDUSTRY_ATTRIBUTE22
    ,       L.INDUSTRY_ATTRIBUTE23
    ,       L.INDUSTRY_ATTRIBUTE24
    ,       L.INDUSTRY_ATTRIBUTE25
    ,       L.INDUSTRY_ATTRIBUTE26
    ,       L.INDUSTRY_ATTRIBUTE27
    ,       L.INDUSTRY_ATTRIBUTE28
    ,       L.INDUSTRY_ATTRIBUTE29
    ,       L.INDUSTRY_ATTRIBUTE30
    ,       L.INDUSTRY_ATTRIBUTE2
    ,       L.INDUSTRY_ATTRIBUTE3
    ,       L.INDUSTRY_ATTRIBUTE4
    ,       L.INDUSTRY_ATTRIBUTE5
    ,       L.INDUSTRY_ATTRIBUTE6
    ,       L.INDUSTRY_ATTRIBUTE7
    ,       L.INDUSTRY_ATTRIBUTE8
    ,       L.INDUSTRY_ATTRIBUTE9
    ,       L.INDUSTRY_CONTEXT
     -- ,       L.INTERMED_SHIP_TO_CONTACT_ID
     -- ,       L.INTERMED_SHIP_TO_ORG_ID
    ,       L.INVENTORY_ITEM_ID
     -- ,       L.INVOICE_INTERFACE_STATUS_CODE
    ,       L.INVOICE_TO_CONTACT_ID
    ,       L.INVOICE_TO_ORG_ID
     -- ,       L.INVOICED_QUANTITY
    ,       L.INVOICING_RULE_ID
    ,       L.CUSTOMER_ITEM_ID           -- L.ORDERED_ITEM_ID
    ,       L.CUSTOMER_ITEM_ID_TYPE      -- L.ITEM_IDENTIFIER_TYPE
    ,       L.CUSTOMER_ITEM_NAME         -- L.ORDERED_ITEM
    ,       L.CUSTOMER_ITEM_NET_PRICE
    ,       L.CUSTOMER_PAYMENT_TERM_ID
    ,       L.ITEM_REVISION
    ,       L.ITEM_TYPE_CODE
     -- ,       L.LAST_ACK_CODE
     -- ,       L.LAST_ACK_DATE
     -- ,       L.LAST_UPDATED_BY
     -- ,       L.LAST_UPDATE_DATE
     -- ,       L.LAST_UPDATE_LOGIN
    ,       L.LATEST_ACCEPTABLE_DATE
    ,       NULL                         -- L.LINE_CATEGORY_CODE
    -- Use pre-generated line_id value from interface tables
    ,       L.LINE_ID
    ,       L.LINE_NUMBER
    ,       L.LINE_TYPE_ID
    ,       NULL                         -- L.LINK_TO_LINE_ID
    ,       L.MODEL_GROUP_NUMBER
    ,       NULL                         -- L.MFG_LEAD_TIME
     -- ,       L.OPEN_FLAG
    ,       L.OPTION_FLAG
    ,       L.OPTION_NUMBER
    ,       L.ORDERED_QUANTITY
    ,       L.ORDERED_QUANTITY2              --OPM 02/JUN/00
    ,       L.ORDER_QUANTITY_UOM
    ,       L.ORDERED_QUANTITY_UOM2          --OPM 02/JUN/00
    ,       L.ORG_ID
    ,       L.ORIG_SYS_DOCUMENT_REF
    ,       L.ORIG_SYS_LINE_REF
    ,       L.ORIG_SYS_SHIPMENT_REF
    ,       L.CHANGE_SEQUENCE
    ,       L.OVER_SHIP_REASON_CODE
    ,       L.OVER_SHIP_RESOLVED_FLAG
    ,       L.PAYMENT_TERM_ID
     -- ,       L.PLANNING_PRIORITY
    ,       L.PREFERRED_GRADE                --OPM HVOP
    ,       L.PRICE_LIST_ID
     -- ,       L.PRICE_REQUEST_CODE             --PROMOTIONS MAY/01
    ,       L.PRICING_ATTRIBUTE1
    ,       L.PRICING_ATTRIBUTE10
    ,       L.PRICING_ATTRIBUTE2
    ,       L.PRICING_ATTRIBUTE3
    ,       L.PRICING_ATTRIBUTE4
    ,       L.PRICING_ATTRIBUTE5
    ,       L.PRICING_ATTRIBUTE6
    ,       L.PRICING_ATTRIBUTE7
    ,       L.PRICING_ATTRIBUTE8
    ,       L.PRICING_ATTRIBUTE9
    ,       L.PRICING_CONTEXT
    ,       L.PRICING_DATE
    ,       L.PRICING_QUANTITY
    ,       L.PRICING_QUANTITY_UOM
     -- ,       L.PROGRAM_APPLICATION_ID
     -- ,       L.PROGRAM_ID
     -- ,       L.PROGRAM_UPDATE_DATE
    ,       L.PROJECT_ID
    ,       L.PROMISE_DATE
    ,       NULL                           --  L.RE_SOURCE_FLAG
     -- ,       L.REFERENCE_CUSTOMER_TRX_LINE_ID
    ,       L.REFERENCE_HEADER_ID
    ,       L.REFERENCE_LINE_ID
    ,       L.REFERENCE_TYPE
    ,       L.REQUEST_DATE
    ,       L.REQUEST_ID
    ,       L.RETURN_ATTRIBUTE1
    ,       L.RETURN_ATTRIBUTE10
    ,       L.RETURN_ATTRIBUTE11
    ,       L.RETURN_ATTRIBUTE12
    ,       L.RETURN_ATTRIBUTE13
    ,       L.RETURN_ATTRIBUTE14
    ,       L.RETURN_ATTRIBUTE15
    ,       L.RETURN_ATTRIBUTE2
    ,       L.RETURN_ATTRIBUTE3
    ,       L.RETURN_ATTRIBUTE4
    ,       L.RETURN_ATTRIBUTE5
    ,       L.RETURN_ATTRIBUTE6
    ,       L.RETURN_ATTRIBUTE7
    ,       L.RETURN_ATTRIBUTE8
    ,       L.RETURN_ATTRIBUTE9
    ,       L.RETURN_CONTEXT
    ,       L.RETURN_REASON_CODE
     -- ,       L.RLA_SCHEDULE_TYPE_CODE
    ,       L.SALESREP_ID
    ,       L.SCHEDULE_ARRIVAL_DATE
    ,       L.SCHEDULE_SHIP_DATE
    ,       L.SCHEDULE_STATUS_CODE
    ,       L.SHIPMENT_NUMBER
    ,       L.SHIPMENT_PRIORITY_CODE
    ,       L.SHIPPED_QUANTITY
    ,       L.SHIPPED_QUANTITY2 -- OPM B1661023 04/02/01
    ,       L.SHIPPING_METHOD_CODE
    ,       L.SHIPPING_QUANTITY
    ,       L.SHIPPING_QUANTITY2 -- OPM B1661023 04/02/01
    ,       L.SHIPPING_QUANTITY_UOM
    ,       L.SHIP_FROM_ORG_ID
    ,       L.SUBINVENTORY
    ,       L.SHIP_SET_ID
    ,       L.SHIP_TOLERANCE_ABOVE
    ,       L.SHIP_TOLERANCE_BELOW
    ,       NULL                           -- L.SHIPPABLE_FLAG
     -- ,       L.SHIPPING_INTERFACED_FLAG
    ,       L.SHIP_TO_CONTACT_ID
    ,       L.SHIP_TO_ORG_ID
    ,       L.SHIP_MODEL_COMPLETE_FLAG
    ,       L.SOLD_TO_ORG_ID
    ,       L.SOLD_FROM_ORG_ID
    ,       L.SORT_ORDER
    ,       NULL                           -- L.SOURCE_DOCUMENT_ID
     -- ,       L.SOURCE_DOCUMENT_LINE_ID
     -- ,       L.SOURCE_DOCUMENT_TYPE_ID
    ,       L.SOURCE_TYPE_CODE
    ,       L.SPLIT_FROM_LINE_ID
     -- ,       L.LINE_SET_ID
     -- ,       L.SPLIT_BY
    , 'N' --      L.MODEL_REMNANT_FLAG
    ,       L.TASK_ID
    ,       L.TAX_CODE
    ,       L.TAX_DATE
    ,       L.TAX_EXEMPT_FLAG
    ,       L.TAX_EXEMPT_NUMBER
    ,       L.TAX_EXEMPT_REASON_CODE
    ,       L.TAX_POINT_CODE
     -- ,       L.TAX_RATE
    ,       L.TAX_VALUE
    ,       NULL                           -- L.TOP_MODEL_LINE_ID
    ,       L.UNIT_LIST_PRICE
    ,       L.UNIT_LIST_PRICE_PER_PQTY
    ,       L.UNIT_SELLING_PRICE
    ,       L.UNIT_SELLING_PRICE_PER_PQTY
    ,       NULL                           -- L.VISIBLE_DEMAND_FLAG
    ,       L.VEH_CUS_ITEM_CUM_KEY_ID
    ,       RTRIM(L.SHIPPING_INSTRUCTIONS,' ') -- 33090458
    ,       RTRIM(L.PACKING_INSTRUCTIONS,' ') -- 33090458
    ,       L.SERVICE_TXN_REASON_CODE
    ,       L.SERVICE_TXN_COMMENTS
    ,       L.SERVICE_DURATION
    ,       L.SERVICE_PERIOD
    ,       L.SERVICE_START_DATE
    ,       L.SERVICE_END_DATE
    ,       L.SERVICE_COTERMINATE_FLAG
    ,       L.UNIT_LIST_PERCENT
    ,       L.UNIT_SELLING_PERCENT
    ,       L.UNIT_PERCENT_BASE_PRICE
    ,       L.SERVICE_NUMBER
    ,       L.SERVICE_REFERENCE_TYPE_CODE
     -- ,       L.SERVICE_REFERENCE_LINE_ID
     -- ,       L.SERVICE_REFERENCE_SYSTEM_ID
    ,       RTRIM(L.TP_CONTEXT,' ') -- 3390458
    ,       RTRIM(L.TP_ATTRIBUTE1,' ') -- 3390458
    ,       RTRIM(L.TP_ATTRIBUTE2,' ') -- 3390458
    ,       RTRIM(L.TP_ATTRIBUTE3,' ') -- 3390458
    ,       RTRIM(L.TP_ATTRIBUTE4,' ') -- 3390458
    ,       RTRIM(L.TP_ATTRIBUTE5,' ') -- 3390458
    ,       RTRIM(L.TP_ATTRIBUTE6,' ') -- 3390458
    ,       RTRIM(L.TP_ATTRIBUTE7,' ') -- 3390458
    ,       RTRIM(L.TP_ATTRIBUTE8,' ') -- 3390458
    ,       RTRIM(L.TP_ATTRIBUTE9,' ') -- 3390458
    ,       RTRIM(L.TP_ATTRIBUTE10,' ') -- 3390458
    ,       RTRIM(L.TP_ATTRIBUTE11,' ') -- 3390458
    ,       RTRIM(L.TP_ATTRIBUTE12,' ') -- 3390458
    ,       RTRIM(L.TP_ATTRIBUTE13,' ') -- 3390458
    ,       RTRIM(L.TP_ATTRIBUTE14,' ') -- 3390458
    ,       RTRIM(L.TP_ATTRIBUTE15,' ') -- 3390458
     -- ,       L.FLOW_STATUS_CODE
     -- ,       L.MARKETING_SOURCE_CODE_ID
    ,       L.CALCULATE_PRICE_FLAG
    ,       L.COMMITMENT_ID
    ,       L.ORDER_SOURCE_ID      -- aksingh
     -- ,    L.upgraded_flag
    ,       1                      -- L.LOCK_CONTROL
    ,       NULL                   -- wf_process_name
    ,       NULL                   -- ii_start_index
    ,       NULL                   -- ii_count
    ,       RTRIM(L.user_item_description,' ') -- 3390458
    ,       NULL                   -- parent_line_index
    ,       NULL                   -- Firm Demand flag
    -- end customer (Bug 5054618)
				,L.End_customer_contact_id
				,L.End_customer_id
				,L.End_customer_site_use_id
				,L.IB_owner_code
				,L.IB_current_location_code
				,L.IB_Installed_at_Location_code
    FROM    OE_HEADERS_IFACE_ALL H, OE_LINES_IFACE_ALL L
    WHERE   h.batch_id = p_batch_id
      AND   h.order_source_id = l.order_source_id
      AND   h.orig_sys_document_ref = l.orig_sys_document_ref
      AND   nvl(h.error_flag,'N') = 'N'
      AND   nvl(h.ineligible_for_hvop, 'N') <> 'Y'
      AND   nvl(l.error_flag,'N') = 'N'
      AND   nvl(l.rejected_flag,'N') = 'N'
    ORDER BY l.order_source_id, l.orig_sys_document_ref
	    , l.orig_sys_line_ref,
            l.orig_sys_shipment_ref;


     ----------------
     --- Addind a new cursor c_lines1. this will be loaded if p_process_configurator=y and OE_BULK_ORDER_IMPORT_PVT.G_RTRIM_IFACE_DATA = 'N'
     ----------------
     CURSOR c_lines1 IS
     SELECT * FROM (
         -- records from the line interface tables ( include standard items and config items)
         SELECT /*+ ORDERED USE_NL(H L) USE_INDEX(H OE_HEADERS_IFACE_ALL_N2) */
                 L.ACCOUNTING_RULE_ID
         ,       L.ACCOUNTING_RULE_DURATION
         ,       L.ACTUAL_ARRIVAL_DATE
          -- ,       L.ACTUAL_SHIPMENT_DATE
         ,       L.AGREEMENT_ID
         ,       L.ARRIVAL_SET_ID
         ,       nvl(T.ATO_LINE_ID, L.ATO_LINE_ID) 	ATO_LINE_ID
         ,       L.ATTRIBUTE1
         ,       L.ATTRIBUTE10
         ,       L.ATTRIBUTE11
         ,       L.ATTRIBUTE12
         ,       L.ATTRIBUTE13
         ,       L.ATTRIBUTE14
         ,       L.ATTRIBUTE15
         ,       L.ATTRIBUTE16   --For bug 2184255
         ,       L.ATTRIBUTE17
         ,       L.ATTRIBUTE18
         ,       L.ATTRIBUTE19
         ,       L.ATTRIBUTE2
         ,       L.ATTRIBUTE20
         ,       L.ATTRIBUTE3
         ,       L.ATTRIBUTE4
         ,       L.ATTRIBUTE5
         ,       L.ATTRIBUTE6
         ,       L.ATTRIBUTE7
         ,       L.ATTRIBUTE8
         ,       L.ATTRIBUTE9
          -- ,       L.AUTO_SELECTED_QUANTITY
         ,       L.AUTHORIZED_TO_SHIP_FLAG
         ,       NULL                       BOOKED_FLAG
         ,       'N'                        CANCELLED_FLAG
         ,       L.CANCELLED_QUANTITY
         ,       nvl(T.COMPONENT_CODE, L.COMPONENT_CODE) 		COMPONENT_CODE
         ,       NULL                          			COMPONENT_NUMBER
         ,       nvl(T.COMPONENT_SEQUENCE_ID, L.COMPONENT_SEQUENCE_ID) COMPONENT_SEQUENCE_ID
         ,       nvl(T.CONFIG_HEADER_ID, L.CONFIG_HEADER_ID) 	CONFIG_HEADER_ID
         ,       nvl(T.CONFIG_REV_NBR, L.CONFIG_REV_NBR) 		CONFIG_REV_NBR
         ,       null 						CONFIG_DISPLAY_SEQUENCE
         ,       nvl(T.CONFIGURATION_ID, L.CONFIGURATION_ID)		CONFIGURATION_ID
         ,       L.CONTEXT
          -- ,       L.CREATED_BY
          -- ,       L.CREATION_DATE
         ,       L.CREDIT_INVOICE_LINE_ID
         ,       L.CUSTOMER_DOCK_CODE
         ,       L.CUSTOMER_JOB
         ,       L.CUSTOMER_PRODUCTION_LINE
         ,       L.CUST_PRODUCTION_SEQ_NUM
          -- ,       L.CUSTOMER_TRX_LINE_ID
         ,       L.CUST_MODEL_SERIAL_NUMBER
         ,       L.CUSTOMER_PO_NUMBER
         ,       L.CUSTOMER_LINE_NUMBER
         ,       L.DELIVERY_LEAD_TIME
         ,       L.DELIVER_TO_CONTACT_ID
         ,       L.DELIVER_TO_ORG_ID
         ,       L.DEMAND_BUCKET_TYPE_CODE
         ,       L.DEMAND_CLASS_CODE
          -- ,       L.DEP_PLAN_REQUIRED_FLAG
         ,       L.EARLIEST_ACCEPTABLE_DATE
         ,       L.END_ITEM_UNIT_NUMBER
         ,       L.EXPLOSION_DATE
         -- ,       L.FIRST_ACK_CODE
         -- ,       L.FIRST_ACK_DATE
         ,       L.FOB_POINT_CODE
         ,       NULL  FREIGHT_CARRIER_CODE
         ,       L.FREIGHT_TERMS_CODE
          -- ,       L.FULFILLED_QUANTITY
          -- ,       L.FULFILLED_FLAG
          -- ,       L.FULFILLMENT_METHOD_CODE
          -- ,       L.FULFILLMENT_DATE
         ,       L.GLOBAL_ATTRIBUTE1
         ,       L.GLOBAL_ATTRIBUTE10
         ,       L.GLOBAL_ATTRIBUTE11
         ,       L.GLOBAL_ATTRIBUTE12
         ,       L.GLOBAL_ATTRIBUTE13
         ,       L.GLOBAL_ATTRIBUTE14
         ,       L.GLOBAL_ATTRIBUTE15
         ,       L.GLOBAL_ATTRIBUTE16
         ,       L.GLOBAL_ATTRIBUTE17
         ,       L.GLOBAL_ATTRIBUTE18
         ,       L.GLOBAL_ATTRIBUTE19
         ,       L.GLOBAL_ATTRIBUTE2
         ,       L.GLOBAL_ATTRIBUTE20
         ,       L.GLOBAL_ATTRIBUTE3
         ,       L.GLOBAL_ATTRIBUTE4
         ,       L.GLOBAL_ATTRIBUTE5
         ,       L.GLOBAL_ATTRIBUTE6
         ,       L.GLOBAL_ATTRIBUTE7
         ,       L.GLOBAL_ATTRIBUTE8
         ,       L.GLOBAL_ATTRIBUTE9
         ,       L.GLOBAL_ATTRIBUTE_CATEGORY
         ,       NULL HEADER_ID
         ,       L.INDUSTRY_ATTRIBUTE1
         ,       L.INDUSTRY_ATTRIBUTE10
         ,       L.INDUSTRY_ATTRIBUTE11
         ,       L.INDUSTRY_ATTRIBUTE12
         ,       L.INDUSTRY_ATTRIBUTE13
         ,       L.INDUSTRY_ATTRIBUTE14
         ,       L.INDUSTRY_ATTRIBUTE15
         ,       L.INDUSTRY_ATTRIBUTE16
         ,       L.INDUSTRY_ATTRIBUTE17
         ,       L.INDUSTRY_ATTRIBUTE18
         ,       L.INDUSTRY_ATTRIBUTE19
         ,       L.INDUSTRY_ATTRIBUTE20
         ,       L.INDUSTRY_ATTRIBUTE21
         ,       L.INDUSTRY_ATTRIBUTE22
         ,       L.INDUSTRY_ATTRIBUTE23
         ,       L.INDUSTRY_ATTRIBUTE24
         ,       L.INDUSTRY_ATTRIBUTE25
         ,       L.INDUSTRY_ATTRIBUTE26
         ,       L.INDUSTRY_ATTRIBUTE27
         ,       L.INDUSTRY_ATTRIBUTE28
         ,       L.INDUSTRY_ATTRIBUTE29
         ,       L.INDUSTRY_ATTRIBUTE30
         ,       L.INDUSTRY_ATTRIBUTE2
         ,       L.INDUSTRY_ATTRIBUTE3
         ,       L.INDUSTRY_ATTRIBUTE4
         ,       L.INDUSTRY_ATTRIBUTE5
         ,       L.INDUSTRY_ATTRIBUTE6
         ,       L.INDUSTRY_ATTRIBUTE7
         ,       L.INDUSTRY_ATTRIBUTE8
         ,       L.INDUSTRY_ATTRIBUTE9
         ,       L.INDUSTRY_CONTEXT
          -- ,       L.INTERMED_SHIP_TO_CONTACT_ID
          -- ,       L.INTERMED_SHIP_TO_ORG_ID
         ,       nvl(T.INVENTORY_ITEM_ID, L.INVENTORY_ITEM_ID) INVENTORY_ITEM_ID
          -- ,       L.INVOICE_INTERFACE_STATUS_CODE
         ,       L.INVOICE_TO_CONTACT_ID
         ,       L.INVOICE_TO_ORG_ID
          -- ,       L.INVOICED_QUANTITY
         ,       L.INVOICING_RULE_ID
         ,       L.CUSTOMER_ITEM_ID           -- L.ORDERED_ITEM_ID
         ,       L.CUSTOMER_ITEM_ID_TYPE      -- L.ITEM_IDENTIFIER_TYPE
         ,       L.CUSTOMER_ITEM_NAME         -- L.ORDERED_ITEM
         ,       L.CUSTOMER_ITEM_NET_PRICE
         ,       L.CUSTOMER_PAYMENT_TERM_ID
         ,       L.ITEM_REVISION
         ,       nvl(T.ITEM_TYPE_CODE, L.ITEM_TYPE_CODE) ITEM_TYPE_CODE
         -- ,       L.LAST_ACK_CODE
         -- ,       L.LAST_ACK_DATE
          -- ,       L.LAST_UPDATED_BY
          -- ,       L.LAST_UPDATE_DATE
          -- ,       L.LAST_UPDATE_LOGIN
         ,       L.LATEST_ACCEPTABLE_DATE
         ,       NULL                         LINE_CATEGORY_CODE
         -- Use pre-generated line_id value from interface tables
         ,       L.LINE_ID
         ,       L.LINE_NUMBER
         ,       nvl(T.LINE_TYPE, L.LINE_TYPE_ID) LINE_TYPE
         ,       T.LINK_TO_LINE_ID
         ,       L.MODEL_GROUP_NUMBER
         ,       NULL                         MFG_LEAD_TIME
          -- ,       L.OPEN_FLAG
         ,       L.OPTION_FLAG
         ,       L.OPTION_NUMBER
         ,       nvl(T.ORDERED_QUANTITY, L.ORDERED_QUANTITY) ORDERED_QUANTITY
         ,       L.ORDERED_QUANTITY2              --OPM 02/JUN/00
         ,       nvl(T.UOM_CODE, L.ORDER_QUANTITY_UOM) UOM_CODE
         ,       L.ORDERED_QUANTITY_UOM2          --OPM 02/JUN/00
         ,       L.ORG_ID
         ,       L.ORIG_SYS_DOCUMENT_REF		ORIG_SYS_DOCUMENT_REF
         ,       L.ORIG_SYS_LINE_REF			ORIG_SYS_LINE_REF
         ,       L.ORIG_SYS_SHIPMENT_REF		ORIG_SYS_SHIPMENT_REF
         ,       L.CHANGE_SEQUENCE
         ,       L.OVER_SHIP_REASON_CODE
         ,       L.OVER_SHIP_RESOLVED_FLAG
         ,       L.PAYMENT_TERM_ID
          -- ,       L.PLANNING_PRIORITY
         ,       L.PREFERRED_GRADE                --OPM HVOP
         ,       L.PRICE_LIST_ID
          -- ,       L.PRICE_REQUEST_CODE             --PROMOTIONS MAY/01
         ,       L.PRICING_ATTRIBUTE1
         ,       L.PRICING_ATTRIBUTE10
         ,       L.PRICING_ATTRIBUTE2
         ,       L.PRICING_ATTRIBUTE3
         ,       L.PRICING_ATTRIBUTE4
         ,       L.PRICING_ATTRIBUTE5
         ,       L.PRICING_ATTRIBUTE6
         ,       L.PRICING_ATTRIBUTE7
         ,       L.PRICING_ATTRIBUTE8
         ,       L.PRICING_ATTRIBUTE9
         ,       L.PRICING_CONTEXT
         ,       L.PRICING_DATE
         ,       L.PRICING_QUANTITY
         ,       L.PRICING_QUANTITY_UOM
          -- ,       L.PROGRAM_APPLICATION_ID
          -- ,       L.PROGRAM_ID
          -- ,       L.PROGRAM_UPDATE_DATE
         ,       L.PROJECT_ID
         ,       L.PROMISE_DATE
         ,       NULL                           RE_SOURCE_FLAG
          -- ,       L.REFERENCE_CUSTOMER_TRX_LINE_ID
         ,       L.REFERENCE_HEADER_ID
         ,       L.REFERENCE_LINE_ID
         ,       L.REFERENCE_TYPE
         ,       L.REQUEST_DATE
         ,       L.REQUEST_ID
         ,       L.RETURN_ATTRIBUTE1
         ,       L.RETURN_ATTRIBUTE10
         ,       L.RETURN_ATTRIBUTE11
         ,       L.RETURN_ATTRIBUTE12
         ,       L.RETURN_ATTRIBUTE13
         ,       L.RETURN_ATTRIBUTE14
         ,       L.RETURN_ATTRIBUTE15
         ,       L.RETURN_ATTRIBUTE2
         ,       L.RETURN_ATTRIBUTE3
         ,       L.RETURN_ATTRIBUTE4
         ,       L.RETURN_ATTRIBUTE5
         ,       L.RETURN_ATTRIBUTE6
         ,       L.RETURN_ATTRIBUTE7
         ,       L.RETURN_ATTRIBUTE8
         ,       L.RETURN_ATTRIBUTE9
         ,       L.RETURN_CONTEXT
         ,       L.RETURN_REASON_CODE
          -- ,       L.RLA_SCHEDULE_TYPE_CODE
         ,       L.SALESREP_ID
         ,       L.SCHEDULE_ARRIVAL_DATE
         ,       L.SCHEDULE_SHIP_DATE
         ,       L.SCHEDULE_STATUS_CODE
         ,       L.SHIPMENT_NUMBER
         ,       L.SHIPMENT_PRIORITY_CODE
         ,       L.SHIPPED_QUANTITY
         ,       L.SHIPPED_QUANTITY2 -- OPM B1661023 04/02/01
         ,       L.SHIPPING_METHOD_CODE
         ,       L.SHIPPING_QUANTITY
         ,       L.SHIPPING_QUANTITY2 -- OPM B1661023 04/02/01
         ,       L.SHIPPING_QUANTITY_UOM
         ,       L.SHIP_FROM_ORG_ID
         ,       L.SUBINVENTORY
         ,       L.SHIP_SET_ID
         ,       L.SHIP_TOLERANCE_ABOVE
         ,       L.SHIP_TOLERANCE_BELOW
         ,       NULL                           SHIPPABLE_FLAG
          -- ,       L.SHIPPING_INTERFACED_FLAG
         ,       L.SHIP_TO_CONTACT_ID
         ,       L.SHIP_TO_ORG_ID
         ,       L.SHIP_MODEL_COMPLETE_FLAG
         ,       L.SOLD_TO_ORG_ID
         ,       L.SOLD_FROM_ORG_ID
         ,       nvl(T.SORT_ORDER, L.SORT_ORDER) SORT_ORDER
         ,       NULL                           SOURCE_DOCUMENT_ID
          -- ,       L.SOURCE_DOCUMENT_LINE_ID
          -- ,       L.SOURCE_DOCUMENT_TYPE_ID
         ,       L.SOURCE_TYPE_CODE
         ,       L.SPLIT_FROM_LINE_ID
          -- ,       L.LINE_SET_ID
          -- ,       L.SPLIT_BY
         ,       'N'   MODEL_REMNANT_FLAG
         ,       L.TASK_ID
         ,       L.TAX_CODE
         ,       L.TAX_DATE
         ,       L.TAX_EXEMPT_FLAG
         ,       L.TAX_EXEMPT_NUMBER
         ,       L.TAX_EXEMPT_REASON_CODE
         ,       L.TAX_POINT_CODE
          -- ,       L.TAX_RATE
         ,       L.TAX_VALUE
         ,       T.TOP_MODEL_LINE_ID
         ,       T.TOP_MODEL_LINE_REF		TOP_MODEL_LINE_REF
         ,       L.UNIT_LIST_PRICE
         ,       L.UNIT_LIST_PRICE_PER_PQTY
         ,       L.UNIT_SELLING_PRICE
         ,       L.UNIT_SELLING_PRICE_PER_PQTY
         ,       NULL                           VISIBLE_DEMAND_FLAG
         ,       L.VEH_CUS_ITEM_CUM_KEY_ID
         ,       L.SHIPPING_INSTRUCTIONS
         ,       L.PACKING_INSTRUCTIONS
         ,       L.SERVICE_TXN_REASON_CODE
         ,       L.SERVICE_TXN_COMMENTS
         ,       L.SERVICE_DURATION
         ,       L.SERVICE_PERIOD
         ,       L.SERVICE_START_DATE
         ,       L.SERVICE_END_DATE
         ,       L.SERVICE_COTERMINATE_FLAG
         ,       L.UNIT_LIST_PERCENT
         ,       L.UNIT_SELLING_PERCENT
         ,       L.UNIT_PERCENT_BASE_PRICE
         ,       L.SERVICE_NUMBER
         ,       L.SERVICE_REFERENCE_TYPE_CODE
          -- ,       L.SERVICE_REFERENCE_LINE_ID
          -- ,       L.SERVICE_REFERENCE_SYSTEM_ID
         ,       L.TP_CONTEXT
         ,       L.TP_ATTRIBUTE1
         ,       L.TP_ATTRIBUTE2
         ,       L.TP_ATTRIBUTE3
         ,       L.TP_ATTRIBUTE4
         ,       L.TP_ATTRIBUTE5
         ,       L.TP_ATTRIBUTE6
         ,       L.TP_ATTRIBUTE7
         ,       L.TP_ATTRIBUTE8
         ,       L.TP_ATTRIBUTE9
         ,       L.TP_ATTRIBUTE10
         ,       L.TP_ATTRIBUTE11
         ,       L.TP_ATTRIBUTE12
         ,       L.TP_ATTRIBUTE13
         ,       L.TP_ATTRIBUTE14
         ,       L.TP_ATTRIBUTE15
          -- ,       L.FLOW_STATUS_CODE
          -- ,       L.MARKETING_SOURCE_CODE_ID
         ,       L.CALCULATE_PRICE_FLAG
         ,       L.COMMITMENT_ID
         ,       L.ORDER_SOURCE_ID      ORDER_SOURCE_ID
          -- ,    L.upgraded_flag
         ,       1                      LOCK_CONTROL
         ,       NULL                   wf_process_name
         ,       NULL                   ii_start_index
         ,       NULL                   ii_count
         ,       L.user_item_description
         ,       NULL                   parent_line_index
         ,       NULL                   Firm_Demand_flag
        -- end customer
     				,L.End_customer_contact_id
     				,L.End_customer_id
     				,L.End_customer_site_use_id
     				,L.IB_owner_code
     				,L.IB_current_location_code
     				,L.IB_Installed_at_Location_code
         ,       NULL                   cust_trx_type_id
         ,       NULL                   tax_calculation_flag
         ,       NULL                   ato_line_index
         ,       NULL                   top_model_line_index
         FROM    OE_HEADERS_IFACE_ALL H, OE_LINES_IFACE_ALL L
     	    , OE_CONFIG_DETAILS_TMP T
         WHERE   h.batch_id = p_batch_id
           AND   h.order_source_id = l.order_source_id
           AND   h.orig_sys_document_ref = l.orig_sys_document_ref
           AND   nvl(h.error_flag,'N') = 'N'
           AND   nvl(h.ineligible_for_hvop, 'N') <> 'Y'
           AND   nvl(l.error_flag,'N') = 'N'
           AND   nvl(l.rejected_flag,'N') = 'N'
           AND   l.line_id = t.line_id(+)
         UNION ALL
         -- records from oe_config_details_tmp and not in line interface table
         SELECT /*+ ORDERED USE_NL(H L) USE_INDEX(H OE_HEADERS_IFACE_ALL_N2) */
                 NULL ACCOUNTING_RULE_ID
         ,       NULL ACCOUNTING_RULE_DURATION
         ,       NULL ACTUAL_ARRIVAL_DATE
          -- ,       L.ACTUAL_SHIPMENT_DATE
         ,       NULL AGREEMENT_ID
         ,       NULL ARRIVAL_SET_ID
         ,       T.ATO_LINE_ID 	ATO_LINE_ID
         ,       NULL ATTRIBUTE1
         ,       NULL ATTRIBUTE10
         ,       NULL ATTRIBUTE11
         ,       NULL ATTRIBUTE12
         ,       NULL ATTRIBUTE13
         ,       NULL ATTRIBUTE14
         ,       NULL ATTRIBUTE15
         ,       NULL ATTRIBUTE16   --For bug 2184255
         ,       NULL ATTRIBUTE17
         ,       NULL ATTRIBUTE18
         ,       NULL ATTRIBUTE19
         ,       NULL ATTRIBUTE2
         ,       NULL ATTRIBUTE20
         ,       NULL ATTRIBUTE3
         ,       NULL ATTRIBUTE4
         ,       NULL ATTRIBUTE5
         ,       NULL ATTRIBUTE6
         ,       NULL ATTRIBUTE7
         ,       NULL ATTRIBUTE8
         ,       NULL ATTRIBUTE9
          -- ,       L.AUTO_SELECTED_QUANTITY
         ,       NULL AUTHORIZED_TO_SHIP_FLAG
         ,       NULL BOOKED_FLAG
         ,       'N'  CANCELLED_FLAG
         ,       NULL CANCELLED_QUANTITY
         ,       T.COMPONENT_CODE 		  	COMPONENT_CODE
         ,       NULL                        	COMPONENT_NUMBER
         ,       T.COMPONENT_SEQUENCE_ID		COMPONENT_SEQUENCE_ID
         ,       T.CONFIG_HEADER_ID			CONFIG_HEADER_ID
         ,       T.CONFIG_REV_NBR			CONFIG_REV_NBR
         ,       null 				CONFIG_DISPLAY_SEQUENCE
         ,       T.CONFIGURATION_ID			CONFIGURATION_ID
         ,       NULL CONTEXT
          -- ,       L.CREATED_BY
          -- ,       L.CREATION_DATE
         ,       NULL CREDIT_INVOICE_LINE_ID
         ,       NULL CUSTOMER_DOCK_CODE
         ,       NULL CUSTOMER_JOB
         ,       NULL CUSTOMER_PRODUCTION_LINE
         ,       NULL CUST_PRODUCTION_SEQ_NUM
          -- ,       L.CUSTOMER_TRX_LINE_ID
         ,       NULL CUST_MODEL_SERIAL_NUMBER
         ,       NULL CUSTOMER_PO_NUMBER
         ,       NULL CUSTOMER_LINE_NUMBER
         ,       NULL DELIVERY_LEAD_TIME
         ,       NULL DELIVER_TO_CONTACT_ID
         ,       NULL DELIVER_TO_ORG_ID
         ,       NULL DEMAND_BUCKET_TYPE_CODE
         ,       NULL DEMAND_CLASS_CODE
          -- ,       L.DEP_PLAN_REQUIRED_FLAG
         ,       NULL EARLIEST_ACCEPTABLE_DATE
         ,       NULL END_ITEM_UNIT_NUMBER
         ,       NULL EXPLOSION_DATE
         -- ,       L.FIRST_ACK_CODE
         -- ,       L.FIRST_ACK_DATE
         ,       NULL FOB_POINT_CODE
         ,       NULL FREIGHT_CARRIER_CODE
         ,       NULL FREIGHT_TERMS_CODE
          -- ,       L.FULFILLED_QUANTITY
          -- ,       L.FULFILLED_FLAG
          -- ,       L.FULFILLMENT_METHOD_CODE
          -- ,       L.FULFILLMENT_DATE
         ,       NULL GLOBAL_ATTRIBUTE1
         ,       NULL GLOBAL_ATTRIBUTE10
         ,       NULL GLOBAL_ATTRIBUTE11
         ,       NULL GLOBAL_ATTRIBUTE12
         ,       NULL GLOBAL_ATTRIBUTE13
         ,       NULL GLOBAL_ATTRIBUTE14
         ,       NULL GLOBAL_ATTRIBUTE15
         ,       NULL GLOBAL_ATTRIBUTE16
         ,       NULL GLOBAL_ATTRIBUTE17
         ,       NULL GLOBAL_ATTRIBUTE18
         ,       NULL GLOBAL_ATTRIBUTE19
         ,       NULL GLOBAL_ATTRIBUTE2
         ,       NULL GLOBAL_ATTRIBUTE20
         ,       NULL GLOBAL_ATTRIBUTE3
         ,       NULL GLOBAL_ATTRIBUTE4
         ,       NULL GLOBAL_ATTRIBUTE5
         ,       NULL GLOBAL_ATTRIBUTE6
         ,       NULL GLOBAL_ATTRIBUTE7
         ,       NULL GLOBAL_ATTRIBUTE8
         ,       NULL GLOBAL_ATTRIBUTE9
         ,       NULL GLOBAL_ATTRIBUTE_CATEGORY
         ,       NULL HEADER_ID
         ,       NULL INDUSTRY_ATTRIBUTE1
         ,       NULL INDUSTRY_ATTRIBUTE10
         ,       NULL INDUSTRY_ATTRIBUTE11
         ,       NULL INDUSTRY_ATTRIBUTE12
         ,       NULL INDUSTRY_ATTRIBUTE13
         ,       NULL INDUSTRY_ATTRIBUTE14
         ,       NULL INDUSTRY_ATTRIBUTE15
         ,       NULL INDUSTRY_ATTRIBUTE16
         ,       NULL INDUSTRY_ATTRIBUTE17
         ,       NULL INDUSTRY_ATTRIBUTE18
         ,       NULL INDUSTRY_ATTRIBUTE19
         ,       NULL INDUSTRY_ATTRIBUTE20
         ,       NULL INDUSTRY_ATTRIBUTE21
         ,       NULL INDUSTRY_ATTRIBUTE22
         ,       NULL INDUSTRY_ATTRIBUTE23
         ,       NULL INDUSTRY_ATTRIBUTE24
         ,       NULL INDUSTRY_ATTRIBUTE25
         ,       NULL INDUSTRY_ATTRIBUTE26
         ,       NULL INDUSTRY_ATTRIBUTE27
         ,       NULL INDUSTRY_ATTRIBUTE28
         ,       NULL INDUSTRY_ATTRIBUTE29
         ,       NULL INDUSTRY_ATTRIBUTE30
         ,       NULL INDUSTRY_ATTRIBUTE2
         ,       NULL INDUSTRY_ATTRIBUTE3
         ,       NULL INDUSTRY_ATTRIBUTE4
         ,       NULL INDUSTRY_ATTRIBUTE5
         ,       NULL INDUSTRY_ATTRIBUTE6
         ,       NULL INDUSTRY_ATTRIBUTE7
         ,       NULL INDUSTRY_ATTRIBUTE8
         ,       NULL INDUSTRY_ATTRIBUTE9
         ,       NULL INDUSTRY_CONTEXT
          -- ,       L.INTERMED_SHIP_TO_CONTACT_ID
          -- ,       L.INTERMED_SHIP_TO_ORG_ID
         ,       T.INVENTORY_ITEM_ID		INVENTORY_ITEM_ID
          -- ,       L.INVOICE_INTERFACE_STATUS_CODE
         ,       NULL INVOICE_TO_CONTACT_ID
         ,       NULL INVOICE_TO_ORG_ID
          -- ,       L.INVOICED_QUANTITY
         ,       NULL INVOICING_RULE_ID
         ,       NULL CUSTOMER_ITEM_ID           -- L.ORDERED_ITEM_ID
         ,       NULL CUSTOMER_ITEM_ID_TYPE      -- L.ITEM_IDENTIFIER_TYPE
         ,       NULL CUSTOMER_ITEM_NAME         -- NULL ORDERED_ITEM
         ,       NULL CUSTOMER_ITEM_NET_PRICE
         ,       NULL CUSTOMER_PAYMENT_TERM_ID
         ,       NULL ITEM_REVISION
         ,       T.ITEM_TYPE_CODE		ITEM_TYPE_CODE
         -- ,       L.LAST_ACK_CODE
         -- ,       L.LAST_ACK_DATE
          -- ,       L.LAST_UPDATED_BY
          -- ,       L.LAST_UPDATE_DATE
          -- ,       L.LAST_UPDATE_LOGIN
         ,       NULL LATEST_ACCEPTABLE_DATE
         ,       NULL LINE_CATEGORY_CODE
         -- Use pre-generated line_id value from interface tables
         ,       T.LINE_ID			LINE_ID
         ,       NULL LINE_NUMBER
         ,       T.LINE_TYPE			LINE_TYPE
         ,       T.LINK_TO_LINE_ID		LINK_TO_LINE_ID
         ,       NULL MODEL_GROUP_NUMBER
         ,       NULL                        MFG_LEAD_TIME
          -- ,       L.OPEN_FLAG
         ,       NULL OPTION_FLAG
         ,       NULL OPTION_NUMBER
         ,       T.ORDERED_QUANTITY		ORDERED_QUANTITY
         ,       NULL ORDERED_QUANTITY2              --OPM 02/JUN/00
         ,       T.UOM_CODE			UOM_CODE
         ,       NULL ORDERED_QUANTITY_UOM2          --OPM 02/JUN/00
         ,       L.ORG_ID
         ,       T.ORIG_SYS_DOCUMENT_REF  	ORIG_SYS_DOCUMENT_REF
         ,       T.ORIG_SYS_LINE_REF		ORIG_SYS_LINE_REF
         ,       T.ORIG_SYS_SHIPMENT_REF	ORIG_SYS_SHIPMENT_REF
         ,       NULL CHANGE_SEQUENCE
         ,       NULL OVER_SHIP_REASON_CODE
         ,       NULL OVER_SHIP_RESOLVED_FLAG
         ,       NULL PAYMENT_TERM_ID
          -- ,       L.PLANNING_PRIORITY
         ,       NULL PREFERRED_GRADE                --OPM HVOP
         ,       NULL PRICE_LIST_ID
          -- ,       L.PRICE_REQUEST_CODE             --PROMOTIONS MAY/01
         ,       NULL PRICING_ATTRIBUTE1
         ,       NULL PRICING_ATTRIBUTE10
         ,       NULL PRICING_ATTRIBUTE2
         ,       NULL PRICING_ATTRIBUTE3
         ,       NULL PRICING_ATTRIBUTE4
         ,       NULL PRICING_ATTRIBUTE5
         ,       NULL PRICING_ATTRIBUTE6
         ,       NULL PRICING_ATTRIBUTE7
         ,       NULL PRICING_ATTRIBUTE8
         ,       NULL PRICING_ATTRIBUTE9
         ,       NULL PRICING_CONTEXT
         ,       NULL PRICING_DATE
         ,       NULL PRICING_QUANTITY
         ,       NULL PRICING_QUANTITY_UOM
          -- ,       L.PROGRAM_APPLICATION_ID
          -- ,       L.PROGRAM_ID
          -- ,       L.PROGRAM_UPDATE_DATE
         ,       NULL PROJECT_ID
         ,       NULL PROMISE_DATE
         ,       NULL RE_SOURCE_FLAG
          -- ,       L.REFERENCE_CUSTOMER_TRX_LINE_ID
         ,       NULL REFERENCE_HEADER_ID
         ,       NULL REFERENCE_LINE_ID
         ,       NULL REFERENCE_TYPE
         ,       NULL REQUEST_DATE
         ,       NULL REQUEST_ID
         ,       NULL RETURN_ATTRIBUTE1
         ,       NULL RETURN_ATTRIBUTE10
         ,       NULL RETURN_ATTRIBUTE11
         ,       NULL RETURN_ATTRIBUTE12
         ,       NULL RETURN_ATTRIBUTE13
         ,       NULL RETURN_ATTRIBUTE14
         ,       NULL RETURN_ATTRIBUTE15
         ,       NULL RETURN_ATTRIBUTE2
         ,       NULL RETURN_ATTRIBUTE3
         ,       NULL RETURN_ATTRIBUTE4
         ,       NULL RETURN_ATTRIBUTE5
         ,       NULL RETURN_ATTRIBUTE6
         ,       NULL RETURN_ATTRIBUTE7
         ,       NULL RETURN_ATTRIBUTE8
         ,       NULL RETURN_ATTRIBUTE9
         ,       NULL RETURN_CONTEXT
         ,       NULL RETURN_REASON_CODE
          -- ,       L.RLA_SCHEDULE_TYPE_CODE
         ,       NULL SALESREP_ID
         ,       NULL SCHEDULE_ARRIVAL_DATE
         ,       NULL SCHEDULE_SHIP_DATE
         ,       NULL SCHEDULE_STATUS_CODE
         ,       NULL SHIPMENT_NUMBER
         ,       NULL SHIPMENT_PRIORITY_CODE
         ,       NULL SHIPPED_QUANTITY
         ,       NULL SHIPPED_QUANTITY2 -- OPM B1661023 04/02/01
         ,       NULL SHIPPING_METHOD_CODE
         ,       NULL SHIPPING_QUANTITY
         ,       NULL SHIPPING_QUANTITY2 -- OPM B1661023 04/02/01
         ,       NULL SHIPPING_QUANTITY_UOM
         ,       NULL SHIP_FROM_ORG_ID
         ,       NULL SUBINVENTORY
         ,       NULL SHIP_SET_ID
         ,       NULL SHIP_TOLERANCE_ABOVE
         ,       NULL SHIP_TOLERANCE_BELOW
         ,       NULL SHIPPABLE_FLAG
          -- ,       L.SHIPPING_INTERFACED_FLAG
         ,       NULL SHIP_TO_CONTACT_ID
         ,       NULL SHIP_TO_ORG_ID
         ,       NULL SHIP_MODEL_COMPLETE_FLAG
         ,       NULL SOLD_TO_ORG_ID
         ,       NULL SOLD_FROM_ORG_ID
         ,       T.SORT_ORDER		SORT_ORDER
         ,       NULL SOURCE_DOCUMENT_ID
          -- ,       L.SOURCE_DOCUMENT_LINE_ID
          -- ,       L.SOURCE_DOCUMENT_TYPE_ID
         ,       NULL SOURCE_TYPE_CODE
         ,       NULL SPLIT_FROM_LINE_ID
          -- ,       L.LINE_SET_ID
          -- ,       L.SPLIT_BY
         ,       'N'  MODEL_REMNANT_FLAG
         ,       NULL TASK_ID
         ,       NULL TAX_CODE
         ,       NULL TAX_DATE
         ,       NULL TAX_EXEMPT_FLAG
         ,       NULL TAX_EXEMPT_NUMBER
         ,       NULL TAX_EXEMPT_REASON_CODE
         ,       NULL TAX_POINT_CODE
          -- ,       L.TAX_RATE
         ,       NULL TAX_VALUE
         ,       T.TOP_MODEL_LINE_ID			TOP_MODEL_LINE_ID
         ,       T.TOP_MODEL_LINE_REF		TOP_MODEL_LINE_REF
         ,       NULL UNIT_LIST_PRICE
         ,       NULL UNIT_LIST_PRICE_PER_PQTY
         ,       NULL UNIT_SELLING_PRICE
         ,       NULL UNIT_SELLING_PRICE_PER_PQTY
         ,       NULL VISIBLE_DEMAND_FLAG
         ,       NULL VEH_CUS_ITEM_CUM_KEY_ID
         ,       NULL SHIPPING_INSTRUCTIONS
         ,       NULL PACKING_INSTRUCTIONS
         ,       NULL SERVICE_TXN_REASON_CODE
         ,       NULL SERVICE_TXN_COMMENTS
         ,       NULL SERVICE_DURATION
         ,       NULL SERVICE_PERIOD
         ,       NULL SERVICE_START_DATE
         ,       NULL SERVICE_END_DATE
         ,       NULL SERVICE_COTERMINATE_FLAG
         ,       NULL UNIT_LIST_PERCENT
         ,       NULL UNIT_SELLING_PERCENT
         ,       NULL UNIT_PERCENT_BASE_PRICE
         ,       NULL SERVICE_NUMBER
         ,       NULL SERVICE_REFERENCE_TYPE_CODE
          -- ,       L.SERVICE_REFERENCE_LINE_ID
          -- ,       L.SERVICE_REFERENCE_SYSTEM_ID
         ,       NULL TP_CONTEXT
         ,       NULL TP_ATTRIBUTE1
         ,       NULL TP_ATTRIBUTE2
         ,       NULL TP_ATTRIBUTE3
         ,       NULL TP_ATTRIBUTE4
         ,       NULL TP_ATTRIBUTE5
         ,       NULL TP_ATTRIBUTE6
         ,       NULL TP_ATTRIBUTE7
         ,       NULL TP_ATTRIBUTE8
         ,       NULL TP_ATTRIBUTE9
         ,       NULL TP_ATTRIBUTE10
         ,       NULL TP_ATTRIBUTE11
         ,       NULL TP_ATTRIBUTE12
         ,       NULL TP_ATTRIBUTE13
         ,       NULL TP_ATTRIBUTE14
         ,       NULL TP_ATTRIBUTE15
          -- ,       L.FLOW_STATUS_CODE
          -- ,       L.MARKETING_SOURCE_CODE_ID
         ,       NULL CALCULATE_PRICE_FLAG
         ,       NULL COMMITMENT_ID
         ,       T.ORDER_SOURCE_ID      ORDER_SOURCE_ID
          -- ,    L.upgraded_flag
         ,       1                      LOCK_CONTROL
         ,       NULL                   wf_process_name
         ,       NULL                   ii_start_index
         ,       NULL                   ii_count
         ,       NULL 		        user_item_description
         ,       NULL                   parent_line_index
         ,       NULL                   Firm_Demand_flag
        -- end customer
     				,NULL End_customer_contact_id
     				,NULL End_customer_id
     				,NULL End_customer_site_use_id
     				,NULL IB_owner_code
     				,NULL IB_current_location_code
     				,NULL IB_Installed_at_Location_code
         ,       NULL                   cust_trx_type_id
         ,       NULL                   tax_calculation_flag
         ,       NULL                   ato_line_index
         ,       NULL                   top_model_line_index
         FROM    OE_HEADERS_IFACE_ALL H, OE_LINES_IFACE_ALL L
     	    , OE_CONFIG_DETAILS_TMP T
         WHERE   h.batch_id = p_batch_id
           AND   h.order_source_id = l.order_source_id
           AND   h.orig_sys_document_ref = l.orig_sys_document_ref
           AND   nvl(h.error_flag,'N') = 'N'
           AND   nvl(h.ineligible_for_hvop, 'N') <> 'Y'
           AND   nvl(l.error_flag,'N') = 'N'
           AND   nvl(l.rejected_flag,'N') = 'N'
           AND   l.order_source_id = t.order_source_id
           AND   l.orig_sys_document_ref = t.orig_sys_document_ref
           AND   l.top_model_line_ref = t.top_model_line_ref
           AND   l.item_type_code = 'MODEL'
           AND   NOT EXISTS ( select 1
     			 from OE_LINES_IFACE_ALL L1
     			 where l1.line_id = t.line_id) )  LINES
 ORDER BY order_source_id,
     	     orig_sys_document_ref,
     	     decode(top_model_line_ref, null, orig_sys_line_ref, top_model_line_ref),
     	     orig_sys_shipment_ref,
	     sort_order;


           ----------------
          --- Addind a new cursor c_lines1_rtrim. this will be loaded if p_process_configurator=y and OE_BULK_ORDER_IMPORT_PVT.G_RTRIM_IFACE_DATA = 'N'
     ----------------

     CURSOR c_lines1_rtrim IS
     SELECT * FROM (
         SELECT /*+ ORDERED USE_NL(H L) USE_INDEX(H OE_HEADERS_IFACE_ALL_N2) */
                 L.ACCOUNTING_RULE_ID
         ,       L.ACCOUNTING_RULE_DURATION
         ,       L.ACTUAL_ARRIVAL_DATE
         ,       L.AGREEMENT_ID
         ,       L.ARRIVAL_SET_ID
         ,       nvl(T.ATO_LINE_ID, L.ATO_LINE_ID)  ATO_LINE_ID
         ,       L.ATTRIBUTE1
         ,       L.ATTRIBUTE10
         ,       L.ATTRIBUTE11
         ,       L.ATTRIBUTE12
         ,       L.ATTRIBUTE13
         ,       L.ATTRIBUTE14
         ,       L.ATTRIBUTE15
         ,       L.ATTRIBUTE16   --For bug 2184255
         ,       L.ATTRIBUTE17
         ,       L.ATTRIBUTE18
         ,       L.ATTRIBUTE19
         ,       L.ATTRIBUTE2
         ,       L.ATTRIBUTE20
         ,       L.ATTRIBUTE3
         ,       L.ATTRIBUTE4
         ,       L.ATTRIBUTE5
         ,       L.ATTRIBUTE6
         ,       L.ATTRIBUTE7
         ,       L.ATTRIBUTE8
         ,       L.ATTRIBUTE9
         ,       L.AUTHORIZED_TO_SHIP_FLAG
         ,       NULL   	BOOKED_FLAG
         ,       'N'         CANCELLED_FLAG
         ,       L.CANCELLED_QUANTITY
         ,       nvl(T.COMPONENT_CODE, L.COMPONENT_CODE) COMPONENT_CODE
         ,       NULL                        COMPONENT_NUMBER
         ,       nvl(T.COMPONENT_SEQUENCE_ID, L.COMPONENT_SEQUENCE_ID) COMPONENT_SEQUENCE_ID
         ,       nvl(T.CONFIG_HEADER_ID, L.CONFIG_HEADER_ID) CONFIG_HEADER_ID
         ,       nvl(T.CONFIG_REV_NBR, L.CONFIG_REV_NBR) CONFIG_REV_NBR
         ,       null CONFIG_DISPLAY_SEQUENCE
         ,       nvl(T.CONFIGURATION_ID, L.CONFIGURATION_ID) CONFIGURATION_ID
         ,       L.CONTEXT
          -- ,       L.CREATED_BY
          -- ,       L.CREATION_DATE
         ,       L.CREDIT_INVOICE_LINE_ID
         ,       RTRIM(L.CUSTOMER_DOCK_CODE,' ') -- 3390458
         ,       RTRIM(L.CUSTOMER_JOB, ' ') -- 3390458
         ,       RTRIM(L.CUSTOMER_PRODUCTION_LINE, ' ') -- 3390458
         ,       RTRIM(L.CUST_PRODUCTION_SEQ_NUM, ' ') -- 3390458
          -- ,       L.CUSTOMER_TRX_LINE_ID
         ,       RTRIM(L.CUST_MODEL_SERIAL_NUMBER,' ') -- 3390458
         ,       RTRIM(L.CUSTOMER_PO_NUMBER,' ') -- 3390458
         ,       L.CUSTOMER_LINE_NUMBER
         ,       L.DELIVERY_LEAD_TIME
         ,       L.DELIVER_TO_CONTACT_ID
         ,       L.DELIVER_TO_ORG_ID
         ,       L.DEMAND_BUCKET_TYPE_CODE
         ,       L.DEMAND_CLASS_CODE
          -- ,       L.DEP_PLAN_REQUIRED_FLAG
         ,       L.EARLIEST_ACCEPTABLE_DATE
         ,       RTRIM(L.END_ITEM_UNIT_NUMBER,' ') -- 3390458
         ,       L.EXPLOSION_DATE
         -- ,       L.FIRST_ACK_CODE
         -- ,       L.FIRST_ACK_DATE
         ,       L.FOB_POINT_CODE
         ,       NULL   FREIGHT_CARRIER_CODE
         ,       L.FREIGHT_TERMS_CODE
          -- ,       L.FULFILLED_QUANTITY
          -- ,       L.FULFILLED_FLAG
          -- ,       L.FULFILLMENT_METHOD_CODE
          -- ,       L.FULFILLMENT_DATE
         ,       L.GLOBAL_ATTRIBUTE1
         ,       L.GLOBAL_ATTRIBUTE10
         ,       L.GLOBAL_ATTRIBUTE11
         ,       L.GLOBAL_ATTRIBUTE12
         ,       L.GLOBAL_ATTRIBUTE13
         ,       L.GLOBAL_ATTRIBUTE14
         ,       L.GLOBAL_ATTRIBUTE15
         ,       L.GLOBAL_ATTRIBUTE16
         ,       L.GLOBAL_ATTRIBUTE17
         ,       L.GLOBAL_ATTRIBUTE18
         ,       L.GLOBAL_ATTRIBUTE19
         ,       L.GLOBAL_ATTRIBUTE2
         ,       L.GLOBAL_ATTRIBUTE20
         ,       L.GLOBAL_ATTRIBUTE3
         ,       L.GLOBAL_ATTRIBUTE4
         ,       L.GLOBAL_ATTRIBUTE5
         ,       L.GLOBAL_ATTRIBUTE6
         ,       L.GLOBAL_ATTRIBUTE7
         ,       L.GLOBAL_ATTRIBUTE8
         ,       L.GLOBAL_ATTRIBUTE9
         ,       L.GLOBAL_ATTRIBUTE_CATEGORY
         ,       NULL   HEADER_ID
         ,       L.INDUSTRY_ATTRIBUTE1
         ,       L.INDUSTRY_ATTRIBUTE10
         ,       L.INDUSTRY_ATTRIBUTE11
         ,       L.INDUSTRY_ATTRIBUTE12
         ,       L.INDUSTRY_ATTRIBUTE13
         ,       L.INDUSTRY_ATTRIBUTE14
         ,       L.INDUSTRY_ATTRIBUTE15
         ,       L.INDUSTRY_ATTRIBUTE16
         ,       L.INDUSTRY_ATTRIBUTE17
         ,       L.INDUSTRY_ATTRIBUTE18
         ,       L.INDUSTRY_ATTRIBUTE19
         ,       L.INDUSTRY_ATTRIBUTE20
         ,       L.INDUSTRY_ATTRIBUTE21
         ,       L.INDUSTRY_ATTRIBUTE22
         ,       L.INDUSTRY_ATTRIBUTE23
         ,       L.INDUSTRY_ATTRIBUTE24
         ,       L.INDUSTRY_ATTRIBUTE25
         ,       L.INDUSTRY_ATTRIBUTE26
         ,       L.INDUSTRY_ATTRIBUTE27
         ,       L.INDUSTRY_ATTRIBUTE28
         ,       L.INDUSTRY_ATTRIBUTE29
         ,       L.INDUSTRY_ATTRIBUTE30
         ,       L.INDUSTRY_ATTRIBUTE2
         ,       L.INDUSTRY_ATTRIBUTE3
         ,       L.INDUSTRY_ATTRIBUTE4
         ,       L.INDUSTRY_ATTRIBUTE5
         ,       L.INDUSTRY_ATTRIBUTE6
         ,       L.INDUSTRY_ATTRIBUTE7
         ,       L.INDUSTRY_ATTRIBUTE8
         ,       L.INDUSTRY_ATTRIBUTE9
         ,       L.INDUSTRY_CONTEXT
          -- ,       L.INTERMED_SHIP_TO_CONTACT_ID
          -- ,       L.INTERMED_SHIP_TO_ORG_ID
         ,       nvl(T.INVENTORY_ITEM_ID, L.INVENTORY_ITEM_ID)	INVENTORY_ITEM_ID
          -- ,       L.INVOICE_INTERFACE_STATUS_CODE
         ,       L.INVOICE_TO_CONTACT_ID
         ,       L.INVOICE_TO_ORG_ID
          -- ,       L.INVOICED_QUANTITY
         ,       L.INVOICING_RULE_ID
         ,       L.CUSTOMER_ITEM_ID           -- L.ORDERED_ITEM_ID
         ,       L.CUSTOMER_ITEM_ID_TYPE      -- L.ITEM_IDENTIFIER_TYPE
         ,       L.CUSTOMER_ITEM_NAME         -- L.ORDERED_ITEM
         ,       L.CUSTOMER_ITEM_NET_PRICE
         ,       L.CUSTOMER_PAYMENT_TERM_ID
         ,       L.ITEM_REVISION
         ,       nvl(T.ITEM_TYPE_CODE, L.ITEM_TYPE_CODE)	ITEM_TYPE_CODE
         -- ,       L.LAST_ACK_CODE
         -- ,       L.LAST_ACK_DATE
          -- ,       L.LAST_UPDATED_BY
          -- ,       L.LAST_UPDATE_DATE
          -- ,       L.LAST_UPDATE_LOGIN
         ,       L.LATEST_ACCEPTABLE_DATE
         ,       NULL  	LINE_CATEGORY_CODE
         -- Use pre-generated line_id value from interface tables
         ,       L.LINE_ID
         ,       L.LINE_NUMBER
         ,       nvl(T.LINE_TYPE, L.LINE_TYPE_ID) 	LINE_TYPE
         ,       T.LINK_TO_LINE_ID
         ,       L.MODEL_GROUP_NUMBER
         ,       NULL  	MFG_LEAD_TIME
          -- ,       L.OPEN_FLAG
         ,       L.OPTION_FLAG
         ,       L.OPTION_NUMBER
         ,       nvl(T.ORDERED_QUANTITY, L.ORDERED_QUANTITY)	ORDERED_QUANTITY
         ,       L.ORDERED_QUANTITY2              --OPM 02/JUN/00
         ,       nvl(T.UOM_CODE, L.ORDER_QUANTITY_UOM)	UOM_CODE
         ,       L.ORDERED_QUANTITY_UOM2          --OPM 02/JUN/00
         ,       L.ORG_ID
         ,       L.ORIG_SYS_DOCUMENT_REF	ORIG_SYS_DOCUMENT_REF
         ,       L.ORIG_SYS_LINE_REF		ORIG_SYS_LINE_REF
         ,       L.ORIG_SYS_SHIPMENT_REF	ORIG_SYS_SHIPMENT_REF
         ,       L.CHANGE_SEQUENCE
         ,       L.OVER_SHIP_REASON_CODE
         ,       L.OVER_SHIP_RESOLVED_FLAG
         ,       L.PAYMENT_TERM_ID
          -- ,       L.PLANNING_PRIORITY
         ,       L.PREFERRED_GRADE                --OPM HVOP
         ,       L.PRICE_LIST_ID
          -- ,       L.PRICE_REQUEST_CODE             --PROMOTIONS MAY/01
         ,       L.PRICING_ATTRIBUTE1
         ,       L.PRICING_ATTRIBUTE10
         ,       L.PRICING_ATTRIBUTE2
         ,       L.PRICING_ATTRIBUTE3
         ,       L.PRICING_ATTRIBUTE4
         ,       L.PRICING_ATTRIBUTE5
         ,       L.PRICING_ATTRIBUTE6
         ,       L.PRICING_ATTRIBUTE7
         ,       L.PRICING_ATTRIBUTE8
         ,       L.PRICING_ATTRIBUTE9
         ,       L.PRICING_CONTEXT
         ,       L.PRICING_DATE
         ,       L.PRICING_QUANTITY
         ,       L.PRICING_QUANTITY_UOM
          -- ,       L.PROGRAM_APPLICATION_ID
          -- ,       L.PROGRAM_ID
          -- ,       L.PROGRAM_UPDATE_DATE
         ,       L.PROJECT_ID
         ,       L.PROMISE_DATE
         ,       NULL 	RE_SOURCE_FLAG
          -- ,       L.REFERENCE_CUSTOMER_TRX_LINE_ID
         ,       L.REFERENCE_HEADER_ID
         ,       L.REFERENCE_LINE_ID
         ,       L.REFERENCE_TYPE
         ,       L.REQUEST_DATE
         ,       L.REQUEST_ID
         ,       L.RETURN_ATTRIBUTE1
         ,       L.RETURN_ATTRIBUTE10
         ,       L.RETURN_ATTRIBUTE11
         ,       L.RETURN_ATTRIBUTE12
         ,       L.RETURN_ATTRIBUTE13
         ,       L.RETURN_ATTRIBUTE14
         ,       L.RETURN_ATTRIBUTE15
         ,       L.RETURN_ATTRIBUTE2
         ,       L.RETURN_ATTRIBUTE3
         ,       L.RETURN_ATTRIBUTE4
         ,       L.RETURN_ATTRIBUTE5
         ,       L.RETURN_ATTRIBUTE6
         ,       L.RETURN_ATTRIBUTE7
         ,       L.RETURN_ATTRIBUTE8
         ,       L.RETURN_ATTRIBUTE9
         ,       L.RETURN_CONTEXT
         ,       L.RETURN_REASON_CODE
          -- ,       L.RLA_SCHEDULE_TYPE_CODE
         ,       L.SALESREP_ID
         ,       L.SCHEDULE_ARRIVAL_DATE
         ,       L.SCHEDULE_SHIP_DATE
         ,       L.SCHEDULE_STATUS_CODE
         ,       L.SHIPMENT_NUMBER
         ,       L.SHIPMENT_PRIORITY_CODE
         ,       L.SHIPPED_QUANTITY
         ,       L.SHIPPED_QUANTITY2 -- OPM B1661023 04/02/01
         ,       L.SHIPPING_METHOD_CODE
         ,       L.SHIPPING_QUANTITY
         ,       L.SHIPPING_QUANTITY2 -- OPM B1661023 04/02/01
         ,       L.SHIPPING_QUANTITY_UOM
         ,       L.SHIP_FROM_ORG_ID
         ,       L.SUBINVENTORY
         ,       L.SHIP_SET_ID
         ,       L.SHIP_TOLERANCE_ABOVE
         ,       L.SHIP_TOLERANCE_BELOW
         ,       NULL    SHIPPABLE_FLAG
          -- ,       L.SHIPPING_INTERFACED_FLAG
         ,       L.SHIP_TO_CONTACT_ID
         ,       L.SHIP_TO_ORG_ID
         ,       L.SHIP_MODEL_COMPLETE_FLAG
         ,       L.SOLD_TO_ORG_ID
         ,       L.SOLD_FROM_ORG_ID
         ,       T.SORT_ORDER  	SORT_ORDER
         ,       NULL	SOURCE_DOCUMENT_ID
          -- ,       L.SOURCE_DOCUMENT_LINE_ID
          -- ,       L.SOURCE_DOCUMENT_TYPE_ID
         ,       L.SOURCE_TYPE_CODE
         ,       L.SPLIT_FROM_LINE_ID
          -- ,       L.LINE_SET_ID
          -- ,       L.SPLIT_BY
         ,       'N' MODEL_REMNANT_FLAG
         ,       L.TASK_ID
         ,       L.TAX_CODE
         ,       L.TAX_DATE
         ,       L.TAX_EXEMPT_FLAG
         ,       L.TAX_EXEMPT_NUMBER
         ,       L.TAX_EXEMPT_REASON_CODE
         ,       L.TAX_POINT_CODE
          -- ,       L.TAX_RATE
         ,       L.TAX_VALUE
         ,       T.TOP_MODEL_LINE_ID
         ,       T.TOP_MODEL_LINE_REF  	TOP_MODEL_LINE_REF
         ,       L.UNIT_LIST_PRICE
         ,       L.UNIT_LIST_PRICE_PER_PQTY
         ,       L.UNIT_SELLING_PRICE
         ,       L.UNIT_SELLING_PRICE_PER_PQTY
         ,       NULL  	VISIBLE_DEMAND_FLAG
         ,       L.VEH_CUS_ITEM_CUM_KEY_ID
         ,       RTRIM(L.SHIPPING_INSTRUCTIONS,' ') -- 33090458
         ,       RTRIM(L.PACKING_INSTRUCTIONS,' ') -- 33090458
         ,       L.SERVICE_TXN_REASON_CODE
         ,       L.SERVICE_TXN_COMMENTS
         ,       L.SERVICE_DURATION
         ,       L.SERVICE_PERIOD
         ,       L.SERVICE_START_DATE
         ,       L.SERVICE_END_DATE
         ,       L.SERVICE_COTERMINATE_FLAG
         ,       L.UNIT_LIST_PERCENT
         ,       L.UNIT_SELLING_PERCENT
         ,       L.UNIT_PERCENT_BASE_PRICE
         ,       L.SERVICE_NUMBER
         ,       L.SERVICE_REFERENCE_TYPE_CODE
          -- ,       L.SERVICE_REFERENCE_LINE_ID
          -- ,       L.SERVICE_REFERENCE_SYSTEM_ID
         ,       RTRIM(L.TP_CONTEXT,' ') -- 3390458
         ,       RTRIM(L.TP_ATTRIBUTE1,' ') -- 3390458
         ,       RTRIM(L.TP_ATTRIBUTE2,' ') -- 3390458
         ,       RTRIM(L.TP_ATTRIBUTE3,' ') -- 3390458
         ,       RTRIM(L.TP_ATTRIBUTE4,' ') -- 3390458
         ,       RTRIM(L.TP_ATTRIBUTE5,' ') -- 3390458
         ,       RTRIM(L.TP_ATTRIBUTE6,' ') -- 3390458
         ,       RTRIM(L.TP_ATTRIBUTE7,' ') -- 3390458
         ,       RTRIM(L.TP_ATTRIBUTE8,' ') -- 3390458
         ,       RTRIM(L.TP_ATTRIBUTE9,' ') -- 3390458
         ,       RTRIM(L.TP_ATTRIBUTE10,' ') -- 3390458
         ,       RTRIM(L.TP_ATTRIBUTE11,' ') -- 3390458
         ,       RTRIM(L.TP_ATTRIBUTE12,' ') -- 3390458
         ,       RTRIM(L.TP_ATTRIBUTE13,' ') -- 3390458
         ,       RTRIM(L.TP_ATTRIBUTE14,' ') -- 3390458
         ,       RTRIM(L.TP_ATTRIBUTE15,' ') -- 3390458
          -- ,       L.FLOW_STATUS_CODE
          -- ,       L.MARKETING_SOURCE_CODE_ID
         ,       L.CALCULATE_PRICE_FLAG
         ,       L.COMMITMENT_ID
         ,       L.ORDER_SOURCE_ID      ORDER_SOURCE_ID
          -- ,    L.upgraded_flag
         ,       1                      LOCK_CONTROL
         ,       NULL                   wf_process_name
         ,       NULL                   ii_start_index
         ,       NULL                   ii_count
         ,       RTRIM(L.user_item_description,' ') user_item_description
         ,       NULL                   parent_line_index
         ,       NULL                   Firm_Demand_flag
     -- end customer
     				,L.End_customer_contact_id
     				,L.End_customer_id
     				,L.End_customer_site_use_id
     				,L.IB_owner_code
     				,L.IB_current_location_code
     				,L.IB_Installed_at_Location_code
         ,       NULL                   cust_trx_type_id
         ,       NULL                   tax_calculation_flag
         ,       NULL                   ato_line_index
         ,       NULL                   top_model_line_index
         FROM    OE_HEADERS_IFACE_ALL H, OE_LINES_IFACE_ALL L
     	    , OE_CONFIG_DETAILS_TMP T
         WHERE   h.batch_id = p_batch_id
           AND   h.order_source_id = l.order_source_id
           AND   h.orig_sys_document_ref = l.orig_sys_document_ref
           AND   nvl(h.error_flag,'N') = 'N'
           AND   nvl(h.ineligible_for_hvop, 'N') <> 'Y'
           AND   nvl(l.error_flag,'N') = 'N'
           AND   nvl(l.rejected_flag,'N') = 'N'
           AND   l.line_id = t.line_id(+)
         UNION ALL
         SELECT /*+ ORDERED USE_NL(H L) USE_INDEX(H OE_HEADERS_IFACE_ALL_N2) */
                 NULL ACCOUNTING_RULE_ID
         ,       NULL ACCOUNTING_RULE_DURATION
         ,       NULL ACTUAL_ARRIVAL_DATE
          -- ,       NULL ACTUAL_SHIPMENT_DATE
         ,       NULL AGREEMENT_ID
         ,       NULL ARRIVAL_SET_ID
         ,       T.ATO_LINE_ID	ATO_LINE_ID
         ,       NULL ATTRIBUTE1
         ,       NULL ATTRIBUTE10
         ,       NULL ATTRIBUTE11
         ,       NULL ATTRIBUTE12
         ,       NULL ATTRIBUTE13
         ,       NULL ATTRIBUTE14
         ,       NULL ATTRIBUTE15
         ,       NULL ATTRIBUTE16   --For bug 2184255
         ,       NULL ATTRIBUTE17
         ,       NULL ATTRIBUTE18
         ,       NULL ATTRIBUTE19
         ,       NULL ATTRIBUTE2
         ,       NULL ATTRIBUTE20
         ,       NULL ATTRIBUTE3
         ,       NULL ATTRIBUTE4
         ,       NULL ATTRIBUTE5
         ,       NULL ATTRIBUTE6
         ,       NULL ATTRIBUTE7
         ,       NULL ATTRIBUTE8
         ,       NULL ATTRIBUTE9
          -- ,       L.AUTO_SELECTED_QUANTITY
         ,       NULL AUTHORIZED_TO_SHIP_FLAG
         ,       NULL BOOKED_FLAG
         ,       'N'	  CANCELLED_FLAG
         ,       NULL  CANCELLED_QUANTITY
         ,       T.COMPONENT_CODE		COMPONENT_CODE
         ,       NULL                       	COMPONENT_NUMBER
         ,       T.COMPONENT_SEQUENCE_ID	COMPONENT_SEQUENCE_ID
         ,       T.CONFIG_HEADER_ID		CONFIG_HEADER_ID
         ,       T.CONFIG_REV_NBR		CONFIG_REV_NBR
         ,       null 			CONFIG_DISPLAY_SEQUENCE
         ,       T.CONFIGURATION_ID		CONFIGURATION_ID
         ,       NULL CONTEXT
          -- ,       L.CREATED_BY
          -- ,       L.CREATION_DATE
         ,       NULL CREDIT_INVOICE_LINE_ID
         ,       NULL CUSTOMER_DOCK_CODE
         ,       NULL CUSTOMER_JOB
         ,       NULL CUSTOMER_PRODUCTION_LINE
         ,       NULL CUST_PRODUCTION_SEQ_NUM
          -- ,       L.CUSTOMER_TRX_LINE_ID
         ,       NULL CUST_MODEL_SERIAL_NUMBER
         ,       NULL CUSTOMER_PO_NUMBER
         ,       NULL CUSTOMER_LINE_NUMBER
         ,       NULL DELIVERY_LEAD_TIME
         ,       NULL DELIVER_TO_CONTACT_ID
         ,       NULL DELIVER_TO_ORG_ID
         ,       NULL DEMAND_BUCKET_TYPE_CODE
         ,       NULL DEMAND_CLASS_CODE
          -- ,       L.DEP_PLAN_REQUIRED_FLAG
         ,       NULL EARLIEST_ACCEPTABLE_DATE
         ,       NULL END_ITEM_UNIT_NUMBER
         ,       NULL EXPLOSION_DATE
         -- ,       L.FIRST_ACK_CODE
         -- ,       L.FIRST_ACK_DATE
         ,       NULL FOB_POINT_CODE
         ,       NULL FREIGHT_CARRIER_CODE
         ,       NULL FREIGHT_TERMS_CODE
          -- ,       L.FULFILLED_QUANTITY
          -- ,       L.FULFILLED_FLAG
          -- ,       L.FULFILLMENT_METHOD_CODE
          -- ,       L.FULFILLMENT_DATE
         ,       NULL GLOBAL_ATTRIBUTE1
         ,       NULL GLOBAL_ATTRIBUTE10
         ,       NULL GLOBAL_ATTRIBUTE11
         ,       NULL GLOBAL_ATTRIBUTE12
         ,       NULL GLOBAL_ATTRIBUTE13
         ,       NULL GLOBAL_ATTRIBUTE14
         ,       NULL GLOBAL_ATTRIBUTE15
         ,       NULL GLOBAL_ATTRIBUTE16
         ,       NULL GLOBAL_ATTRIBUTE17
         ,       NULL GLOBAL_ATTRIBUTE18
         ,       NULL GLOBAL_ATTRIBUTE19
         ,       NULL GLOBAL_ATTRIBUTE2
         ,       NULL GLOBAL_ATTRIBUTE20
         ,       NULL GLOBAL_ATTRIBUTE3
         ,       NULL GLOBAL_ATTRIBUTE4
         ,       NULL GLOBAL_ATTRIBUTE5
         ,       NULL GLOBAL_ATTRIBUTE6
         ,       NULL GLOBAL_ATTRIBUTE7
         ,       NULL GLOBAL_ATTRIBUTE8
         ,       NULL GLOBAL_ATTRIBUTE9
         ,       NULL GLOBAL_ATTRIBUTE_CATEGORY
         ,       NULL HEADER_ID
         ,       NULL INDUSTRY_ATTRIBUTE1
         ,       NULL INDUSTRY_ATTRIBUTE10
         ,       NULL INDUSTRY_ATTRIBUTE11
         ,       NULL INDUSTRY_ATTRIBUTE12
         ,       NULL INDUSTRY_ATTRIBUTE13
         ,       NULL INDUSTRY_ATTRIBUTE14
         ,       NULL INDUSTRY_ATTRIBUTE15
         ,       NULL INDUSTRY_ATTRIBUTE16
         ,       NULL INDUSTRY_ATTRIBUTE17
         ,       NULL INDUSTRY_ATTRIBUTE18
         ,       NULL INDUSTRY_ATTRIBUTE19
         ,       NULL INDUSTRY_ATTRIBUTE20
         ,       NULL INDUSTRY_ATTRIBUTE21
         ,       NULL INDUSTRY_ATTRIBUTE22
         ,       NULL INDUSTRY_ATTRIBUTE23
         ,       NULL INDUSTRY_ATTRIBUTE24
         ,       NULL INDUSTRY_ATTRIBUTE25
         ,       NULL INDUSTRY_ATTRIBUTE26
         ,       NULL INDUSTRY_ATTRIBUTE27
         ,       NULL INDUSTRY_ATTRIBUTE28
         ,       NULL INDUSTRY_ATTRIBUTE29
         ,       NULL INDUSTRY_ATTRIBUTE30
         ,       NULL INDUSTRY_ATTRIBUTE2
         ,       NULL INDUSTRY_ATTRIBUTE3
         ,       NULL INDUSTRY_ATTRIBUTE4
         ,       NULL INDUSTRY_ATTRIBUTE5
         ,       NULL INDUSTRY_ATTRIBUTE6
         ,       NULL INDUSTRY_ATTRIBUTE7
         ,       NULL INDUSTRY_ATTRIBUTE8
         ,       NULL INDUSTRY_ATTRIBUTE9
         ,       NULL INDUSTRY_CONTEXT
          -- ,       L.INTERMED_SHIP_TO_CONTACT_ID
          -- ,       L.INTERMED_SHIP_TO_ORG_ID
         ,       T.INVENTORY_ITEM_ID		INVENTORY_ITEM_ID
          -- ,       NULL INVOICE_INTERFACE_STATUS_CODE
         ,       NULL INVOICE_TO_CONTACT_ID
         ,       NULL INVOICE_TO_ORG_ID
          -- ,       NULL INVOICED_QUANTITY
         ,       NULL INVOICING_RULE_ID
         ,       NULL CUSTOMER_ITEM_ID           -- L.ORDERED_ITEM_ID
         ,       NULL CUSTOMER_ITEM_ID_TYPE      -- L.ITEM_IDENTIFIER_TYPE
         ,       NULL CUSTOMER_ITEM_NAME         -- L.ORDERED_ITEM
         ,       NULL CUSTOMER_ITEM_NET_PRICE
         ,       NULL CUSTOMER_PAYMENT_TERM_ID
         ,       NULL ITEM_REVISION
         ,       T.ITEM_TYPE_CODE		ITEM_TYPE_CODE
         -- ,       L.LAST_ACK_CODE
         -- ,       L.LAST_ACK_DATE
          -- ,       L.LAST_UPDATED_BY
          -- ,       L.LAST_UPDATE_DATE
          -- ,       L.LAST_UPDATE_LOGIN
         ,       NULL LATEST_ACCEPTABLE_DATE
         ,       NULL LINE_CATEGORY_CODE
         -- Use pre-generated line_id value from interface tables
         ,       T.LINE_ID 			LINE_ID
         ,       NULL 			LINE_NUMBER
         ,       T.LINE_TYPE			LINE_TYPE
         ,       T.LINK_TO_LINE_ID   	LINK_TO_LINE_ID
         ,       NULL 			MODEL_GROUP_NUMBER
         ,       NULL                	MFG_LEAD_TIME
          -- ,       L.OPEN_FLAG
         ,       NULL OPTION_FLAG
         ,       NULL OPTION_NUMBER
         ,       T.ORDERED_QUANTITY		ORDERED_QUANTITY
         ,       NULL ORDERED_QUANTITY2              --OPM 02/JUN/00
         ,       T.UOM_CODE 			UOM_CODE
         ,       NULL ORDERED_QUANTITY_UOM2          --OPM 02/JUN/00
         ,       L.ORG_ID
         ,       T.ORIG_SYS_DOCUMENT_REF  	ORIG_SYS_DOCUMENT_REF
         ,       T.ORIG_SYS_LINE_REF		ORIG_SYS_LINE_REF
         ,       T.ORIG_SYS_SHIPMENT_REF	ORIG_SYS_SHIPMENT_REF
         ,       NULL CHANGE_SEQUENCE
         ,       NULL OVER_SHIP_REASON_CODE
         ,       NULL OVER_SHIP_RESOLVED_FLAG
         ,       NULL PAYMENT_TERM_ID
          -- ,       NULL PLANNING_PRIORITY
         ,       NULL PREFERRED_GRADE                --OPM HVOP
         ,       NULL PRICE_LIST_ID
          -- ,       NULL PRICE_REQUEST_CODE             --PROMOTIONS MAY/01
         ,       NULL PRICING_ATTRIBUTE1
         ,       NULL PRICING_ATTRIBUTE10
         ,       NULL PRICING_ATTRIBUTE2
         ,       NULL PRICING_ATTRIBUTE3
         ,       NULL PRICING_ATTRIBUTE4
         ,       NULL PRICING_ATTRIBUTE5
         ,       NULL PRICING_ATTRIBUTE6
         ,       NULL PRICING_ATTRIBUTE7
         ,       NULL PRICING_ATTRIBUTE8
         ,       NULL PRICING_ATTRIBUTE9
         ,       NULL PRICING_CONTEXT
         ,       NULL PRICING_DATE
         ,       NULL PRICING_QUANTITY
         ,       NULL PRICING_QUANTITY_UOM
          -- ,       L.PROGRAM_APPLICATION_ID
          -- ,       L.PROGRAM_ID
          -- ,       L.PROGRAM_UPDATE_DATE
         ,       NULL PROJECT_ID
         ,       NULL PROMISE_DATE
         ,       NULL RE_SOURCE_FLAG
          -- ,       L.REFERENCE_CUSTOMER_TRX_LINE_ID
         ,       L.REFERENCE_HEADER_ID
         ,       NULL REFERENCE_LINE_ID
         ,       NULL REFERENCE_TYPE
         ,       NULL REQUEST_DATE
         ,       NULL REQUEST_ID
         ,       NULL RETURN_ATTRIBUTE1
         ,       NULL RETURN_ATTRIBUTE10
         ,       NULL RETURN_ATTRIBUTE11
         ,       NULL RETURN_ATTRIBUTE12
         ,       NULL RETURN_ATTRIBUTE13
         ,       NULL RETURN_ATTRIBUTE14
         ,       NULL RETURN_ATTRIBUTE15
         ,       NULL RETURN_ATTRIBUTE2
         ,       NULL RETURN_ATTRIBUTE3
         ,       NULL RETURN_ATTRIBUTE4
         ,       NULL RETURN_ATTRIBUTE5
         ,       NULL RETURN_ATTRIBUTE6
         ,       NULL RETURN_ATTRIBUTE7
         ,       NULL RETURN_ATTRIBUTE8
         ,       NULL RETURN_ATTRIBUTE9
         ,       NULL RETURN_CONTEXT
         ,       NULL RETURN_REASON_CODE
          -- ,       L.RLA_SCHEDULE_TYPE_CODE
         ,       NULL SALESREP_ID
         ,       NULL SCHEDULE_ARRIVAL_DATE
         ,       NULL SCHEDULE_SHIP_DATE
         ,       NULL SCHEDULE_STATUS_CODE
         ,       NULL SHIPMENT_NUMBER
         ,       NULL SHIPMENT_PRIORITY_CODE
         ,       NULL SHIPPED_QUANTITY
         ,       NULL SHIPPED_QUANTITY2 -- OPM B1661023 04/02/01
         ,       NULL SHIPPING_METHOD_CODE
         ,       NULL SHIPPING_QUANTITY
         ,       NULL SHIPPING_QUANTITY2 -- OPM B1661023 04/02/01
         ,       NULL SHIPPING_QUANTITY_UOM
         ,       NULL SHIP_FROM_ORG_ID
         ,       NULL SUBINVENTORY
         ,       NULL SHIP_SET_ID
         ,       NULL SHIP_TOLERANCE_ABOVE
         ,       NULL SHIP_TOLERANCE_BELOW
         ,       NULL SHIPPABLE_FLAG
          -- ,       L.SHIPPING_INTERFACED_FLAG
         ,       NULL SHIP_TO_CONTACT_ID
         ,       NULL SHIP_TO_ORG_ID
         ,       NULL SHIP_MODEL_COMPLETE_FLAG
         ,       NULL SOLD_TO_ORG_ID
         ,       NULL SOLD_FROM_ORG_ID
         ,       T.SORT_ORDER		SORT_ORDER
         ,       NULL  SOURCE_DOCUMENT_ID
          -- ,       L.SOURCE_DOCUMENT_LINE_ID
          -- ,       L.SOURCE_DOCUMENT_TYPE_ID
         ,       NULL SOURCE_TYPE_CODE
         ,       NULL SPLIT_FROM_LINE_ID
          -- ,       NULL LINE_SET_ID
          -- ,       NULL SPLIT_BY
         ,       'N' MODEL_REMNANT_FLAG
         ,       NULL TASK_ID
         ,       NULL TAX_CODE
         ,       NULL TAX_DATE
         ,       NULL TAX_EXEMPT_FLAG
         ,       NULL TAX_EXEMPT_NUMBER
         ,       NULL TAX_EXEMPT_REASON_CODE
         ,       NULL TAX_POINT_CODE
          -- ,       NULL TAX_RATE
         ,       NULL TAX_VALUE
         ,       T.TOP_MODEL_LINE_ID
         ,       T.TOP_MODEL_LINE_REF	TOP_MODEL_LINE_REF
         ,       NULL UNIT_LIST_PRICE
         ,       NULL UNIT_LIST_PRICE_PER_PQTY
         ,       NULL UNIT_SELLING_PRICE
         ,       NULL UNIT_SELLING_PRICE_PER_PQTY
         ,       NULL VISIBLE_DEMAND_FLAG
         ,       NULL VEH_CUS_ITEM_CUM_KEY_ID
         ,       NULL SHIPPING_INSTRUCTIONS
         ,       NULL PACKING_INSTRUCTIONS
         ,       NULL SERVICE_TXN_REASON_CODE
         ,       NULL SERVICE_TXN_COMMENTS
         ,       NULL SERVICE_DURATION
         ,       NULL SERVICE_PERIOD
         ,       NULL SERVICE_START_DATE
         ,       NULL SERVICE_END_DATE
         ,       NULL SERVICE_COTERMINATE_FLAG
         ,       NULL UNIT_LIST_PERCENT
         ,       NULL UNIT_SELLING_PERCENT
         ,       NULL UNIT_PERCENT_BASE_PRICE
         ,       NULL SERVICE_NUMBER
         ,       NULL SERVICE_REFERENCE_TYPE_CODE
          -- ,       NULL SERVICE_REFERENCE_LINE_ID
          -- ,       NULL SERVICE_REFERENCE_SYSTEM_ID
         ,       NULL TP_CONTEXT
         ,       NULL TP_ATTRIBUTE1
         ,       NULL TP_ATTRIBUTE2
         ,       NULL TP_ATTRIBUTE3
         ,       NULL TP_ATTRIBUTE4
         ,       NULL TP_ATTRIBUTE5
         ,       NULL TP_ATTRIBUTE6
         ,       NULL TP_ATTRIBUTE7
         ,       NULL TP_ATTRIBUTE8
         ,       NULL TP_ATTRIBUTE9
         ,       NULL TP_ATTRIBUTE10
         ,       NULL TP_ATTRIBUTE11
         ,       NULL TP_ATTRIBUTE12
         ,       NULL TP_ATTRIBUTE13
         ,       NULL TP_ATTRIBUTE14
         ,       NULL TP_ATTRIBUTE15
          -- ,       NULL FLOW_STATUS_CODE
          -- ,       NULL MARKETING_SOURCE_CODE_ID
         ,       NULL CALCULATE_PRICE_FLAG
         ,       NULL COMMITMENT_ID
         ,       T.ORDER_SOURCE_ID    	ORDER_SOURCE_ID
          -- ,    NULL upgraded_flag
         ,       1                      LOCK_CONTROL
         ,       NULL                   wf_process_name
         ,       NULL                   ii_start_index
         ,       NULL                   ii_count
         ,       NULL 		   user_item_description
         ,       NULL                   parent_line_index
         ,       NULL                   Firm_Demand_flag
     -- end customer
     				,NULL End_customer_contact_id
     				,NULL End_customer_id
     				,NULL End_customer_site_use_id
     				,NULL IB_owner_code
     				,NULL IB_current_location_code
     				,NULL IB_Installed_at_Location_code
         ,       NULL                   cust_trx_type_id
         ,       NULL                   tax_calculation_flag
         ,       NULL                   ato_line_index
         ,       NULL                   top_model_line_index
         FROM    OE_HEADERS_IFACE_ALL H, OE_LINES_IFACE_ALL L
     	    , OE_CONFIG_DETAILS_TMP T
         WHERE   h.batch_id = p_batch_id
           AND   h.order_source_id = l.order_source_id
           AND   h.orig_sys_document_ref = l.orig_sys_document_ref
           AND   nvl(h.error_flag,'N') = 'N'
           AND   nvl(h.ineligible_for_hvop, 'N') <> 'Y'
           AND   nvl(l.error_flag,'N') = 'N'
           AND   nvl(l.rejected_flag,'N') = 'N'
           AND   l.order_source_id = t.order_source_id
           AND   l.orig_sys_document_ref = t.orig_sys_document_ref
           AND   l.top_model_line_ref = t.top_model_line_ref
           AND   l.item_type_code = 'MODEL'
           AND   NOT EXISTS ( select 1
     			 from OE_LINES_IFACE_ALL L1
     			 where l1.line_id = t.line_id)) LINES
	 ORDER BY order_source_id,
	                 orig_sys_document_ref,
	                 decode(top_model_line_ref, NULL, orig_sys_line_ref, top_model_line_ref),
	                 orig_sys_shipment_ref,
                         sort_order;


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

IF OE_BULK_ORDER_IMPORT_PVT.G_RTRIM_IFACE_DATA = 'N' THEN
   IF p_process_configurations = 'N'
    THEN
      oe_debug_pub.add('before OPEN c_lines');

      OPEN c_lines;
      oe_debug_pub.add('after OPEN c_lines');
      FETCH c_lines BULK COLLECT INTO
        p_line_rec.ACCOUNTING_RULE_ID
       ,p_line_rec.ACCOUNTING_RULE_DURATION
       ,p_line_rec.ACTUAL_ARRIVAL_DATE
       --,p_line_rec.ACTUAL_SHIPMENT_DATE
       ,p_line_rec.AGREEMENT_ID
       ,p_line_rec.ARRIVAL_SET_ID
       ,p_line_rec.ATO_LINE_ID
       ,p_line_rec.ATTRIBUTE1
       ,p_line_rec.ATTRIBUTE10
       ,p_line_rec.ATTRIBUTE11
       ,p_line_rec.ATTRIBUTE12
       ,p_line_rec.ATTRIBUTE13
       ,p_line_rec.ATTRIBUTE14
       ,p_line_rec.ATTRIBUTE15
       ,p_line_rec.ATTRIBUTE16   --For bug 2184255
       ,p_line_rec.ATTRIBUTE17
       ,p_line_rec.ATTRIBUTE18
       ,p_line_rec.ATTRIBUTE19
       ,p_line_rec.ATTRIBUTE2
       ,p_line_rec.ATTRIBUTE20
       ,p_line_rec.ATTRIBUTE3
       ,p_line_rec.ATTRIBUTE4
       ,p_line_rec.ATTRIBUTE5
       ,p_line_rec.ATTRIBUTE6
       ,p_line_rec.ATTRIBUTE7
       ,p_line_rec.ATTRIBUTE8
       ,p_line_rec.ATTRIBUTE9
       --,p_line_rec.AUTO_SELECTED_QUANTITY
       ,p_line_rec.AUTHORIZED_TO_SHIP_FLAG
       ,p_line_rec.BOOKED_FLAG
       ,p_line_rec.CANCELLED_FLAG
       ,p_line_rec.CANCELLED_QUANTITY
       ,p_line_rec.COMPONENT_CODE
       ,p_line_rec.COMPONENT_NUMBER
       ,p_line_rec.COMPONENT_SEQUENCE_ID
       ,p_line_rec.CONFIG_HEADER_ID
       ,p_line_rec.CONFIG_REV_NBR
       ,p_line_rec.CONFIG_DISPLAY_SEQUENCE
       ,p_line_rec.CONFIGURATION_ID
       ,p_line_rec.CONTEXT
       --,p_line_rec.CREATED_BY
       --,p_line_rec.CREATION_DATE
       ,p_line_rec.CREDIT_INVOICE_LINE_ID
       ,p_line_rec.CUSTOMER_DOCK_CODE
       ,p_line_rec.CUSTOMER_JOB
       ,p_line_rec.CUSTOMER_PRODUCTION_LINE
       ,p_line_rec.CUST_PRODUCTION_SEQ_NUM
       --,p_line_rec.CUSTOMER_TRX_LINE_ID
       ,p_line_rec.CUST_MODEL_SERIAL_NUMBER
       ,p_line_rec.CUST_PO_NUMBER
       ,p_line_rec.CUSTOMER_LINE_NUMBER
       ,p_line_rec.DELIVERY_LEAD_TIME
       ,p_line_rec.DELIVER_TO_CONTACT_ID
       ,p_line_rec.DELIVER_TO_ORG_ID
       ,p_line_rec.DEMAND_BUCKET_TYPE_CODE
       ,p_line_rec.DEMAND_CLASS_CODE
       --,p_line_rec.DEP_PLAN_REQUIRED_FLAG
       ,p_line_rec.EARLIEST_ACCEPTABLE_DATE
       ,p_line_rec.END_ITEM_UNIT_NUMBER
       ,p_line_rec.EXPLOSION_DATE
       --,p_line_rec.FIRST_ACK_CODE
       --,p_line_rec.FIRST_ACK_DATE
       ,p_line_rec.FOB_POINT_CODE
       ,p_line_rec.FREIGHT_CARRIER_CODE
       ,p_line_rec.FREIGHT_TERMS_CODE
       --,p_line_rec.FULFILLED_QUANTITY
       --,p_line_rec.FULFILLED_FLAG
       --,p_line_rec.FULFILLMENT_METHOD_CODE
       --,p_line_rec.FULFILLMENT_DATE
       ,p_line_rec.GLOBAL_ATTRIBUTE1
       ,p_line_rec.GLOBAL_ATTRIBUTE10
       ,p_line_rec.GLOBAL_ATTRIBUTE11
       ,p_line_rec.GLOBAL_ATTRIBUTE12
       ,p_line_rec.GLOBAL_ATTRIBUTE13
       ,p_line_rec.GLOBAL_ATTRIBUTE14
       ,p_line_rec.GLOBAL_ATTRIBUTE15
       ,p_line_rec.GLOBAL_ATTRIBUTE16
       ,p_line_rec.GLOBAL_ATTRIBUTE17
       ,p_line_rec.GLOBAL_ATTRIBUTE18
       ,p_line_rec.GLOBAL_ATTRIBUTE19
       ,p_line_rec.GLOBAL_ATTRIBUTE2
       ,p_line_rec.GLOBAL_ATTRIBUTE20
       ,p_line_rec.GLOBAL_ATTRIBUTE3
       ,p_line_rec.GLOBAL_ATTRIBUTE4
       ,p_line_rec.GLOBAL_ATTRIBUTE5
       ,p_line_rec.GLOBAL_ATTRIBUTE6
       ,p_line_rec.GLOBAL_ATTRIBUTE7
       ,p_line_rec.GLOBAL_ATTRIBUTE8
       ,p_line_rec.GLOBAL_ATTRIBUTE9
       ,p_line_rec.GLOBAL_ATTRIBUTE_CATEGORY
       ,p_line_rec.HEADER_ID
       ,p_line_rec.INDUSTRY_ATTRIBUTE1
       ,p_line_rec.INDUSTRY_ATTRIBUTE10
       ,p_line_rec.INDUSTRY_ATTRIBUTE11
       ,p_line_rec.INDUSTRY_ATTRIBUTE12
       ,p_line_rec.INDUSTRY_ATTRIBUTE13
       ,p_line_rec.INDUSTRY_ATTRIBUTE14
       ,p_line_rec.INDUSTRY_ATTRIBUTE15
       ,p_line_rec.INDUSTRY_ATTRIBUTE16
       ,p_line_rec.INDUSTRY_ATTRIBUTE17
       ,p_line_rec.INDUSTRY_ATTRIBUTE18
       ,p_line_rec.INDUSTRY_ATTRIBUTE19
       ,p_line_rec.INDUSTRY_ATTRIBUTE20
       ,p_line_rec.INDUSTRY_ATTRIBUTE21
       ,p_line_rec.INDUSTRY_ATTRIBUTE22
       ,p_line_rec.INDUSTRY_ATTRIBUTE23
       ,p_line_rec.INDUSTRY_ATTRIBUTE24
       ,p_line_rec.INDUSTRY_ATTRIBUTE25
       ,p_line_rec.INDUSTRY_ATTRIBUTE26
       ,p_line_rec.INDUSTRY_ATTRIBUTE27
       ,p_line_rec.INDUSTRY_ATTRIBUTE28
       ,p_line_rec.INDUSTRY_ATTRIBUTE29
       ,p_line_rec.INDUSTRY_ATTRIBUTE30
       ,p_line_rec.INDUSTRY_ATTRIBUTE2
       ,p_line_rec.INDUSTRY_ATTRIBUTE3
       ,p_line_rec.INDUSTRY_ATTRIBUTE4
       ,p_line_rec.INDUSTRY_ATTRIBUTE5
       ,p_line_rec.INDUSTRY_ATTRIBUTE6
       ,p_line_rec.INDUSTRY_ATTRIBUTE7
       ,p_line_rec.INDUSTRY_ATTRIBUTE8
       ,p_line_rec.INDUSTRY_ATTRIBUTE9
       ,p_line_rec.INDUSTRY_CONTEXT
       --,p_line_rec.INTERMED_SHIP_TO_CONTACT_ID
       --,p_line_rec.INTERMED_SHIP_TO_ORG_ID
       ,p_line_rec.INVENTORY_ITEM_ID
       --,p_line_rec.INVOICE_INTERFACE_STATUS_CODE
       ,p_line_rec.INVOICE_TO_CONTACT_ID
       ,p_line_rec.INVOICE_TO_ORG_ID
       --,p_line_rec.INVOICED_QUANTITY
       ,p_line_rec.INVOICING_RULE_ID
       ,p_line_rec.ORDERED_ITEM_ID
       ,p_line_rec.ITEM_IDENTIFIER_TYPE
       ,p_line_rec.ORDERED_ITEM
       ,p_line_rec.CUSTOMER_ITEM_NET_PRICE
       ,p_line_rec.CUSTOMER_PAYMENT_TERM_ID
       ,p_line_rec.ITEM_REVISION
       ,p_line_rec.ITEM_TYPE_CODE
       --,p_line_rec.LAST_ACK_CODE
       --,p_line_rec.LAST_ACK_DATE
       --,p_line_rec.LAST_UPDATED_BY
       --,p_line_rec.LAST_UPDATE_DATE
       --,p_line_rec.LAST_UPDATE_LOGIN
       ,p_line_rec.LATEST_ACCEPTABLE_DATE
       ,p_line_rec.LINE_CATEGORY_CODE
       ,p_line_rec.LINE_ID
       ,p_line_rec.LINE_NUMBER
       ,p_line_rec.LINE_TYPE_ID
       ,p_line_rec.LINK_TO_LINE_ID
       ,p_line_rec.MODEL_GROUP_NUMBER
       ,p_line_rec.MFG_LEAD_TIME
       --,p_line_rec.OPEN_FLAG
       ,p_line_rec.OPTION_FLAG
       ,p_line_rec.OPTION_NUMBER
       ,p_line_rec.ORDERED_QUANTITY
       ,p_line_rec.ORDERED_QUANTITY2              --OPM 02/JUN/00
       ,p_line_rec.ORDER_QUANTITY_UOM
       ,p_line_rec.ORDERED_QUANTITY_UOM2          --OPM 02/JUN/00
       ,p_line_rec.ORG_ID
       ,p_line_rec.ORIG_SYS_DOCUMENT_REF
       ,p_line_rec.ORIG_SYS_LINE_REF
       ,p_line_rec.ORIG_SYS_SHIPMENT_REF
       ,p_line_rec.CHANGE_SEQUENCE
       ,p_line_rec.OVER_SHIP_REASON_CODE
       ,p_line_rec.OVER_SHIP_RESOLVED_FLAG
       ,p_line_rec.PAYMENT_TERM_ID
       --,p_line_rec.PLANNING_PRIORITY
       ,p_line_rec.PREFERRED_GRADE                --OPM HVOP
       ,p_line_rec.PRICE_LIST_ID
       --,p_line_rec.PRICE_REQUEST_CODE             --PROMOTIONS MAY/01
       ,p_line_rec.PRICING_ATTRIBUTE1
       ,p_line_rec.PRICING_ATTRIBUTE10
       ,p_line_rec.PRICING_ATTRIBUTE2
       ,p_line_rec.PRICING_ATTRIBUTE3
       ,p_line_rec.PRICING_ATTRIBUTE4
       ,p_line_rec.PRICING_ATTRIBUTE5
       ,p_line_rec.PRICING_ATTRIBUTE6
       ,p_line_rec.PRICING_ATTRIBUTE7
       ,p_line_rec.PRICING_ATTRIBUTE8
       ,p_line_rec.PRICING_ATTRIBUTE9
       ,p_line_rec.PRICING_CONTEXT
       ,p_line_rec.PRICING_DATE
       ,p_line_rec.PRICING_QUANTITY
       ,p_line_rec.PRICING_QUANTITY_UOM
       --,p_line_rec.PROGRAM_APPLICATION_ID
       --,p_line_rec.PROGRAM_ID
       --,p_line_rec.PROGRAM_UPDATE_DATE
       ,p_line_rec.PROJECT_ID
       ,p_line_rec.PROMISE_DATE
       ,p_line_rec.RE_SOURCE_FLAG
       --,p_line_rec.REFERENCE_CUSTOMER_TRX_LINE_ID
       ,p_line_rec.REFERENCE_HEADER_ID
       ,p_line_rec.REFERENCE_LINE_ID
       ,p_line_rec.REFERENCE_TYPE
       ,p_line_rec.REQUEST_DATE
       ,p_line_rec.REQUEST_ID
       ,p_line_rec.RETURN_ATTRIBUTE1
       ,p_line_rec.RETURN_ATTRIBUTE10
       ,p_line_rec.RETURN_ATTRIBUTE11
       ,p_line_rec.RETURN_ATTRIBUTE12
       ,p_line_rec.RETURN_ATTRIBUTE13
       ,p_line_rec.RETURN_ATTRIBUTE14
       ,p_line_rec.RETURN_ATTRIBUTE15
       ,p_line_rec.RETURN_ATTRIBUTE2
       ,p_line_rec.RETURN_ATTRIBUTE3
       ,p_line_rec.RETURN_ATTRIBUTE4
       ,p_line_rec.RETURN_ATTRIBUTE5
       ,p_line_rec.RETURN_ATTRIBUTE6
       ,p_line_rec.RETURN_ATTRIBUTE7
       ,p_line_rec.RETURN_ATTRIBUTE8
       ,p_line_rec.RETURN_ATTRIBUTE9
       ,p_line_rec.RETURN_CONTEXT
       ,p_line_rec.RETURN_REASON_CODE
       --,p_line_rec.RLA_SCHEDULE_TYPE_CODE
       ,p_line_rec.SALESREP_ID
       ,p_line_rec.SCHEDULE_ARRIVAL_DATE
       ,p_line_rec.SCHEDULE_SHIP_DATE
       ,p_line_rec.SCHEDULE_STATUS_CODE
       ,p_line_rec.SHIPMENT_NUMBER
       ,p_line_rec.SHIPMENT_PRIORITY_CODE
       ,p_line_rec.SHIPPED_QUANTITY
       ,p_line_rec.SHIPPED_QUANTITY2 -- OPM B1661023 04/02/01
       ,p_line_rec.SHIPPING_METHOD_CODE
       ,p_line_rec.SHIPPING_QUANTITY
       ,p_line_rec.SHIPPING_QUANTITY2 -- OPM B1661023 04/02/01
       ,p_line_rec.SHIPPING_QUANTITY_UOM
       ,p_line_rec.SHIP_FROM_ORG_ID
       ,p_line_rec.SUBINVENTORY
       ,p_line_rec.SHIP_SET_ID
       ,p_line_rec.SHIP_TOLERANCE_ABOVE
       ,p_line_rec.SHIP_TOLERANCE_BELOW
       ,p_line_rec.SHIPPABLE_FLAG
       --,p_line_rec.SHIPPING_INTERFACED_FLAG
       ,p_line_rec.SHIP_TO_CONTACT_ID
       ,p_line_rec.SHIP_TO_ORG_ID
       ,p_line_rec.SHIP_MODEL_COMPLETE_FLAG
       ,p_line_rec.SOLD_TO_ORG_ID
       ,p_line_rec.SOLD_FROM_ORG_ID
       ,p_line_rec.SORT_ORDER
       ,p_line_rec.SOURCE_DOCUMENT_ID
       --,p_line_rec.SOURCE_DOCUMENT_LINE_ID
       --,p_line_rec.SOURCE_DOCUMENT_TYPE_ID
       ,p_line_rec.SOURCE_TYPE_CODE
       ,p_line_rec.SPLIT_FROM_LINE_ID
       --,p_line_rec.LINE_SET_ID
       --,p_line_rec.SPLIT_BY
       ,p_line_rec.MODEL_REMNANT_FLAG
       ,p_line_rec.TASK_ID
       ,p_line_rec.TAX_CODE
       ,p_line_rec.TAX_DATE
       ,p_line_rec.TAX_EXEMPT_FLAG
       ,p_line_rec.TAX_EXEMPT_NUMBER
       ,p_line_rec.TAX_EXEMPT_REASON_CODE
       ,p_line_rec.TAX_POINT_CODE
       --,p_line_rec.TAX_RATE
       ,p_line_rec.TAX_VALUE
       ,p_line_rec.TOP_MODEL_LINE_ID
       ,p_line_rec.UNIT_LIST_PRICE
       ,p_line_rec.UNIT_LIST_PRICE_PER_PQTY
       ,p_line_rec.UNIT_SELLING_PRICE
       ,p_line_rec.UNIT_SELLING_PRICE_PER_PQTY
       ,p_line_rec.VISIBLE_DEMAND_FLAG
       ,p_line_rec.VEH_CUS_ITEM_CUM_KEY_ID
       ,p_line_rec.SHIPPING_INSTRUCTIONS
       ,p_line_rec.PACKING_INSTRUCTIONS
       ,p_line_rec.SERVICE_TXN_REASON_CODE
       ,p_line_rec.SERVICE_TXN_COMMENTS
       ,p_line_rec.SERVICE_DURATION
       ,p_line_rec.SERVICE_PERIOD
       ,p_line_rec.SERVICE_START_DATE
       ,p_line_rec.SERVICE_END_DATE
       ,p_line_rec.SERVICE_COTERMINATE_FLAG
       ,p_line_rec.UNIT_LIST_PERCENT
       ,p_line_rec.UNIT_SELLING_PERCENT
       ,p_line_rec.UNIT_PERCENT_BASE_PRICE
       ,p_line_rec.SERVICE_NUMBER
       ,p_line_rec.SERVICE_REFERENCE_TYPE_CODE
       --,p_line_rec.SERVICE_REFERENCE_LINE_ID
       --,p_line_rec.SERVICE_REFERENCE_SYSTEM_ID
       ,p_line_rec.TP_CONTEXT
       ,p_line_rec.TP_ATTRIBUTE1
       ,p_line_rec.TP_ATTRIBUTE2
       ,p_line_rec.TP_ATTRIBUTE3
       ,p_line_rec.TP_ATTRIBUTE4
       ,p_line_rec.TP_ATTRIBUTE5
       ,p_line_rec.TP_ATTRIBUTE6
       ,p_line_rec.TP_ATTRIBUTE7
       ,p_line_rec.TP_ATTRIBUTE8
       ,p_line_rec.TP_ATTRIBUTE9
       ,p_line_rec.TP_ATTRIBUTE10
       ,p_line_rec.TP_ATTRIBUTE11
       ,p_line_rec.TP_ATTRIBUTE12
       ,p_line_rec.TP_ATTRIBUTE13
       ,p_line_rec.TP_ATTRIBUTE14
       ,p_line_rec.TP_ATTRIBUTE15
       --,p_line_rec.FLOW_STATUS_CODE
       --,p_line_rec.MARKETING_SOURCE_CODE_ID
       ,p_line_rec.CALCULATE_PRICE_FLAG
       ,p_line_rec.COMMITMENT_ID
       ,p_line_rec.ORDER_SOURCE_ID
       --,p_line_rec.upgraded_flag
       ,p_line_rec.LOCK_CONTROL
       ,p_line_rec.WF_PROCESS_NAME
       ,p_line_rec.II_START_INDEX
       ,p_line_rec.II_COUNT
       ,p_line_rec.user_item_description
       ,p_line_rec.parent_line_index
       ,p_line_rec.firm_demand_flag
       -- end customer(Bug 5054618)
				,p_line_rec.End_customer_contact_id
				,p_line_rec.End_customer_id
				,p_line_rec.End_customer_site_use_id
				,p_line_rec.IB_owner
				,p_line_rec.IB_current_location
				,p_line_rec.IB_Installed_at_Location
       ,p_line_rec.cust_trx_type_id
       ,p_line_rec.tax_calculation_flag
       ,p_line_rec.ato_line_index
       ,p_line_rec.top_model_line_index ;

     else  -- when p_process_configurations in Y

          IF l_debug_level > 0 THEN
	          oe_debug_pub.add('before OPEN c_lines1');
	        END IF;

	        OPEN c_lines1;

	        IF l_debug_level > 0 THEN
	          oe_debug_pub.add('after OPEN c_lines1');
	        END IF;

	        FETCH c_lines1 BULK COLLECT INTO
	          p_line_rec.ACCOUNTING_RULE_ID
	         ,p_line_rec.ACCOUNTING_RULE_DURATION
	         ,p_line_rec.ACTUAL_ARRIVAL_DATE
	         --,p_line_rec.ACTUAL_SHIPMENT_DATE
	         ,p_line_rec.AGREEMENT_ID
	         ,p_line_rec.ARRIVAL_SET_ID
	         ,p_line_rec.ATO_LINE_ID
	         ,p_line_rec.ATTRIBUTE1
	         ,p_line_rec.ATTRIBUTE10
	         ,p_line_rec.ATTRIBUTE11
	         ,p_line_rec.ATTRIBUTE12
	         ,p_line_rec.ATTRIBUTE13
	         ,p_line_rec.ATTRIBUTE14
	         ,p_line_rec.ATTRIBUTE15
	         ,p_line_rec.ATTRIBUTE16   --For bug 2184255
	         ,p_line_rec.ATTRIBUTE17
	         ,p_line_rec.ATTRIBUTE18
	         ,p_line_rec.ATTRIBUTE19
	         ,p_line_rec.ATTRIBUTE2
	         ,p_line_rec.ATTRIBUTE20
	         ,p_line_rec.ATTRIBUTE3
	         ,p_line_rec.ATTRIBUTE4
	         ,p_line_rec.ATTRIBUTE5
	         ,p_line_rec.ATTRIBUTE6
	         ,p_line_rec.ATTRIBUTE7
	         ,p_line_rec.ATTRIBUTE8
	         ,p_line_rec.ATTRIBUTE9
	         --,p_line_rec.AUTO_SELECTED_QUANTITY
	         ,p_line_rec.AUTHORIZED_TO_SHIP_FLAG
	         ,p_line_rec.BOOKED_FLAG
	         ,p_line_rec.CANCELLED_FLAG
	         ,p_line_rec.CANCELLED_QUANTITY
	         ,p_line_rec.COMPONENT_CODE
	         ,p_line_rec.COMPONENT_NUMBER
	         ,p_line_rec.COMPONENT_SEQUENCE_ID
	         ,p_line_rec.CONFIG_HEADER_ID
	         ,p_line_rec.CONFIG_REV_NBR
	         ,p_line_rec.CONFIG_DISPLAY_SEQUENCE
	         ,p_line_rec.CONFIGURATION_ID
	         ,p_line_rec.CONTEXT
	         --,p_line_rec.CREATED_BY
	         --,p_line_rec.CREATION_DATE
	         ,p_line_rec.CREDIT_INVOICE_LINE_ID
	         ,p_line_rec.CUSTOMER_DOCK_CODE
	         ,p_line_rec.CUSTOMER_JOB
	         ,p_line_rec.CUSTOMER_PRODUCTION_LINE
	         ,p_line_rec.CUST_PRODUCTION_SEQ_NUM
	         --,p_line_rec.CUSTOMER_TRX_LINE_ID
	         ,p_line_rec.CUST_MODEL_SERIAL_NUMBER
	         ,p_line_rec.CUST_PO_NUMBER
	         ,p_line_rec.CUSTOMER_LINE_NUMBER
	         ,p_line_rec.DELIVERY_LEAD_TIME
	         ,p_line_rec.DELIVER_TO_CONTACT_ID
	         ,p_line_rec.DELIVER_TO_ORG_ID
	         ,p_line_rec.DEMAND_BUCKET_TYPE_CODE
	         ,p_line_rec.DEMAND_CLASS_CODE
	         --,p_line_rec.DEP_PLAN_REQUIRED_FLAG
	         ,p_line_rec.EARLIEST_ACCEPTABLE_DATE
	         ,p_line_rec.END_ITEM_UNIT_NUMBER
	         ,p_line_rec.EXPLOSION_DATE
	         -- ,p_line_rec.FIRST_ACK_CODE
	         -- ,p_line_rec.FIRST_ACK_DATE
	         ,p_line_rec.FOB_POINT_CODE
	         ,p_line_rec.FREIGHT_CARRIER_CODE
	         ,p_line_rec.FREIGHT_TERMS_CODE
	         --,p_line_rec.FULFILLED_QUANTITY
	         --,p_line_rec.FULFILLED_FLAG
	         --,p_line_rec.FULFILLMENT_METHOD_CODE
	         --,p_line_rec.FULFILLMENT_DATE
	         ,p_line_rec.GLOBAL_ATTRIBUTE1
	         ,p_line_rec.GLOBAL_ATTRIBUTE10
	         ,p_line_rec.GLOBAL_ATTRIBUTE11
	         ,p_line_rec.GLOBAL_ATTRIBUTE12
	         ,p_line_rec.GLOBAL_ATTRIBUTE13
	         ,p_line_rec.GLOBAL_ATTRIBUTE14
	         ,p_line_rec.GLOBAL_ATTRIBUTE15
	         ,p_line_rec.GLOBAL_ATTRIBUTE16
	         ,p_line_rec.GLOBAL_ATTRIBUTE17
	         ,p_line_rec.GLOBAL_ATTRIBUTE18
	         ,p_line_rec.GLOBAL_ATTRIBUTE19
	         ,p_line_rec.GLOBAL_ATTRIBUTE2
	         ,p_line_rec.GLOBAL_ATTRIBUTE20
	         ,p_line_rec.GLOBAL_ATTRIBUTE3
	         ,p_line_rec.GLOBAL_ATTRIBUTE4
	         ,p_line_rec.GLOBAL_ATTRIBUTE5
	         ,p_line_rec.GLOBAL_ATTRIBUTE6
	         ,p_line_rec.GLOBAL_ATTRIBUTE7
	         ,p_line_rec.GLOBAL_ATTRIBUTE8
	         ,p_line_rec.GLOBAL_ATTRIBUTE9
	         ,p_line_rec.GLOBAL_ATTRIBUTE_CATEGORY
	         ,p_line_rec.HEADER_ID
	         ,p_line_rec.INDUSTRY_ATTRIBUTE1
	         ,p_line_rec.INDUSTRY_ATTRIBUTE10
	         ,p_line_rec.INDUSTRY_ATTRIBUTE11
	         ,p_line_rec.INDUSTRY_ATTRIBUTE12
	         ,p_line_rec.INDUSTRY_ATTRIBUTE13
	         ,p_line_rec.INDUSTRY_ATTRIBUTE14
	         ,p_line_rec.INDUSTRY_ATTRIBUTE15
	         ,p_line_rec.INDUSTRY_ATTRIBUTE16
	         ,p_line_rec.INDUSTRY_ATTRIBUTE17
	         ,p_line_rec.INDUSTRY_ATTRIBUTE18
	         ,p_line_rec.INDUSTRY_ATTRIBUTE19
	         ,p_line_rec.INDUSTRY_ATTRIBUTE20
	         ,p_line_rec.INDUSTRY_ATTRIBUTE21
	         ,p_line_rec.INDUSTRY_ATTRIBUTE22
	         ,p_line_rec.INDUSTRY_ATTRIBUTE23
	         ,p_line_rec.INDUSTRY_ATTRIBUTE24
	         ,p_line_rec.INDUSTRY_ATTRIBUTE25
	         ,p_line_rec.INDUSTRY_ATTRIBUTE26
	         ,p_line_rec.INDUSTRY_ATTRIBUTE27
	         ,p_line_rec.INDUSTRY_ATTRIBUTE28
	         ,p_line_rec.INDUSTRY_ATTRIBUTE29
	         ,p_line_rec.INDUSTRY_ATTRIBUTE30
	         ,p_line_rec.INDUSTRY_ATTRIBUTE2
	         ,p_line_rec.INDUSTRY_ATTRIBUTE3
	         ,p_line_rec.INDUSTRY_ATTRIBUTE4
	         ,p_line_rec.INDUSTRY_ATTRIBUTE5
	         ,p_line_rec.INDUSTRY_ATTRIBUTE6
	         ,p_line_rec.INDUSTRY_ATTRIBUTE7
	         ,p_line_rec.INDUSTRY_ATTRIBUTE8
	         ,p_line_rec.INDUSTRY_ATTRIBUTE9
	         ,p_line_rec.INDUSTRY_CONTEXT
	         --,p_line_rec.INTERMED_SHIP_TO_CONTACT_ID
	         --,p_line_rec.INTERMED_SHIP_TO_ORG_ID
	         ,p_line_rec.INVENTORY_ITEM_ID
	         --,p_line_rec.INVOICE_INTERFACE_STATUS_CODE
	         ,p_line_rec.INVOICE_TO_CONTACT_ID
	         ,p_line_rec.INVOICE_TO_ORG_ID
	         --,p_line_rec.INVOICED_QUANTITY
	         ,p_line_rec.INVOICING_RULE_ID
	         ,p_line_rec.ORDERED_ITEM_ID
	         ,p_line_rec.ITEM_IDENTIFIER_TYPE
	         ,p_line_rec.ORDERED_ITEM
	         ,p_line_rec.CUSTOMER_ITEM_NET_PRICE
	         ,p_line_rec.CUSTOMER_PAYMENT_TERM_ID
	         ,p_line_rec.ITEM_REVISION
	         ,p_line_rec.ITEM_TYPE_CODE
	         -- ,p_line_rec.LAST_ACK_CODE
	         -- ,p_line_rec.LAST_ACK_DATE
	         --,p_line_rec.LAST_UPDATED_BY
	         --,p_line_rec.LAST_UPDATE_DATE
	         --,p_line_rec.LAST_UPDATE_LOGIN
	         ,p_line_rec.LATEST_ACCEPTABLE_DATE
	         ,p_line_rec.LINE_CATEGORY_CODE
	         ,p_line_rec.LINE_ID
	         ,p_line_rec.LINE_NUMBER
	         ,p_line_rec.LINE_TYPE_ID
	         ,p_line_rec.LINK_TO_LINE_ID
	         ,p_line_rec.MODEL_GROUP_NUMBER
	         ,p_line_rec.MFG_LEAD_TIME
	         --,p_line_rec.OPEN_FLAG
	         ,p_line_rec.OPTION_FLAG
	         ,p_line_rec.OPTION_NUMBER
	         ,p_line_rec.ORDERED_QUANTITY
	         ,p_line_rec.ORDERED_QUANTITY2              --OPM 02/JUN/00
	         ,p_line_rec.ORDER_QUANTITY_UOM
	         ,p_line_rec.ORDERED_QUANTITY_UOM2          --OPM 02/JUN/00
	         ,p_line_rec.ORG_ID
	         ,p_line_rec.ORIG_SYS_DOCUMENT_REF
	         ,p_line_rec.ORIG_SYS_LINE_REF
	         ,p_line_rec.ORIG_SYS_SHIPMENT_REF
	         ,p_line_rec.CHANGE_SEQUENCE
	         ,p_line_rec.OVER_SHIP_REASON_CODE
	         ,p_line_rec.OVER_SHIP_RESOLVED_FLAG
	         ,p_line_rec.PAYMENT_TERM_ID
	         --,p_line_rec.PLANNING_PRIORITY
	         ,p_line_rec.PREFERRED_GRADE                --OPM HVOP
	         ,p_line_rec.PRICE_LIST_ID
	         --,p_line_rec.PRICE_REQUEST_CODE             --PROMOTIONS MAY/01
	         ,p_line_rec.PRICING_ATTRIBUTE1
	         ,p_line_rec.PRICING_ATTRIBUTE10
	         ,p_line_rec.PRICING_ATTRIBUTE2
	         ,p_line_rec.PRICING_ATTRIBUTE3
	         ,p_line_rec.PRICING_ATTRIBUTE4
	         ,p_line_rec.PRICING_ATTRIBUTE5
	         ,p_line_rec.PRICING_ATTRIBUTE6
	         ,p_line_rec.PRICING_ATTRIBUTE7
	         ,p_line_rec.PRICING_ATTRIBUTE8
	         ,p_line_rec.PRICING_ATTRIBUTE9
	         ,p_line_rec.PRICING_CONTEXT
	         ,p_line_rec.PRICING_DATE
	         ,p_line_rec.PRICING_QUANTITY
	         ,p_line_rec.PRICING_QUANTITY_UOM
	         --,p_line_rec.PROGRAM_APPLICATION_ID
	         --,p_line_rec.PROGRAM_ID
	         --,p_line_rec.PROGRAM_UPDATE_DATE
	         ,p_line_rec.PROJECT_ID
	         ,p_line_rec.PROMISE_DATE
	         ,p_line_rec.RE_SOURCE_FLAG
	         --,p_line_rec.REFERENCE_CUSTOMER_TRX_LINE_ID
	         ,p_line_rec.REFERENCE_HEADER_ID
	         ,p_line_rec.REFERENCE_LINE_ID
	         ,p_line_rec.REFERENCE_TYPE
	         ,p_line_rec.REQUEST_DATE
	         ,p_line_rec.REQUEST_ID
	         ,p_line_rec.RETURN_ATTRIBUTE1
	         ,p_line_rec.RETURN_ATTRIBUTE10
	         ,p_line_rec.RETURN_ATTRIBUTE11
	         ,p_line_rec.RETURN_ATTRIBUTE12
	         ,p_line_rec.RETURN_ATTRIBUTE13
	         ,p_line_rec.RETURN_ATTRIBUTE14
	         ,p_line_rec.RETURN_ATTRIBUTE15
	         ,p_line_rec.RETURN_ATTRIBUTE2
	         ,p_line_rec.RETURN_ATTRIBUTE3
	         ,p_line_rec.RETURN_ATTRIBUTE4
	         ,p_line_rec.RETURN_ATTRIBUTE5
	         ,p_line_rec.RETURN_ATTRIBUTE6
	         ,p_line_rec.RETURN_ATTRIBUTE7
	         ,p_line_rec.RETURN_ATTRIBUTE8
	         ,p_line_rec.RETURN_ATTRIBUTE9
	         ,p_line_rec.RETURN_CONTEXT
	         ,p_line_rec.RETURN_REASON_CODE
	         --,p_line_rec.RLA_SCHEDULE_TYPE_CODE
	         ,p_line_rec.SALESREP_ID
	         ,p_line_rec.SCHEDULE_ARRIVAL_DATE
	         ,p_line_rec.SCHEDULE_SHIP_DATE
	         ,p_line_rec.SCHEDULE_STATUS_CODE
	         ,p_line_rec.SHIPMENT_NUMBER
	         ,p_line_rec.SHIPMENT_PRIORITY_CODE
	         ,p_line_rec.SHIPPED_QUANTITY
	         ,p_line_rec.SHIPPED_QUANTITY2 -- OPM B1661023 04/02/01
	         ,p_line_rec.SHIPPING_METHOD_CODE
	         ,p_line_rec.SHIPPING_QUANTITY
	         ,p_line_rec.SHIPPING_QUANTITY2 -- OPM B1661023 04/02/01
	         ,p_line_rec.SHIPPING_QUANTITY_UOM
	         ,p_line_rec.SHIP_FROM_ORG_ID
	         ,p_line_rec.SUBINVENTORY
	         ,p_line_rec.SHIP_SET_ID
	         ,p_line_rec.SHIP_TOLERANCE_ABOVE
	         ,p_line_rec.SHIP_TOLERANCE_BELOW
	         ,p_line_rec.SHIPPABLE_FLAG
	         --,p_line_rec.SHIPPING_INTERFACED_FLAG
	         ,p_line_rec.SHIP_TO_CONTACT_ID
	         ,p_line_rec.SHIP_TO_ORG_ID
	         ,p_line_rec.SHIP_MODEL_COMPLETE_FLAG
	         ,p_line_rec.SOLD_TO_ORG_ID
	         ,p_line_rec.SOLD_FROM_ORG_ID
	         ,p_line_rec.SORT_ORDER
	         ,p_line_rec.SOURCE_DOCUMENT_ID
	         --,p_line_rec.SOURCE_DOCUMENT_LINE_ID
	         --,p_line_rec.SOURCE_DOCUMENT_TYPE_ID
	         ,p_line_rec.SOURCE_TYPE_CODE
	         ,p_line_rec.SPLIT_FROM_LINE_ID
	         --,p_line_rec.LINE_SET_ID
	         --,p_line_rec.SPLIT_BY
	         ,p_line_rec.MODEL_REMNANT_FLAG
	         ,p_line_rec.TASK_ID
	         ,p_line_rec.TAX_CODE
	         ,p_line_rec.TAX_DATE
	         ,p_line_rec.TAX_EXEMPT_FLAG
	         ,p_line_rec.TAX_EXEMPT_NUMBER
	         ,p_line_rec.TAX_EXEMPT_REASON_CODE
	         ,p_line_rec.TAX_POINT_CODE
	         --,p_line_rec.TAX_RATE
	         ,p_line_rec.TAX_VALUE
	         ,p_line_rec.TOP_MODEL_LINE_ID
	         ,p_line_rec.TOP_MODEL_LINE_REF
	         ,p_line_rec.UNIT_LIST_PRICE
	         ,p_line_rec.UNIT_LIST_PRICE_PER_PQTY
	         ,p_line_rec.UNIT_SELLING_PRICE
	         ,p_line_rec.UNIT_SELLING_PRICE_PER_PQTY
	         ,p_line_rec.VISIBLE_DEMAND_FLAG
	         ,p_line_rec.VEH_CUS_ITEM_CUM_KEY_ID
	         ,p_line_rec.SHIPPING_INSTRUCTIONS
	         ,p_line_rec.PACKING_INSTRUCTIONS
	         ,p_line_rec.SERVICE_TXN_REASON_CODE
	         ,p_line_rec.SERVICE_TXN_COMMENTS
	         ,p_line_rec.SERVICE_DURATION
	         ,p_line_rec.SERVICE_PERIOD
	         ,p_line_rec.SERVICE_START_DATE
	         ,p_line_rec.SERVICE_END_DATE
	         ,p_line_rec.SERVICE_COTERMINATE_FLAG
	         ,p_line_rec.UNIT_LIST_PERCENT
	         ,p_line_rec.UNIT_SELLING_PERCENT
	         ,p_line_rec.UNIT_PERCENT_BASE_PRICE
	         ,p_line_rec.SERVICE_NUMBER
	         ,p_line_rec.SERVICE_REFERENCE_TYPE_CODE
	         --,p_line_rec.SERVICE_REFERENCE_LINE_ID
	         --,p_line_rec.SERVICE_REFERENCE_SYSTEM_ID
	         ,p_line_rec.TP_CONTEXT
	         ,p_line_rec.TP_ATTRIBUTE1
	         ,p_line_rec.TP_ATTRIBUTE2
	         ,p_line_rec.TP_ATTRIBUTE3
	         ,p_line_rec.TP_ATTRIBUTE4
	         ,p_line_rec.TP_ATTRIBUTE5
	         ,p_line_rec.TP_ATTRIBUTE6
	         ,p_line_rec.TP_ATTRIBUTE7
	         ,p_line_rec.TP_ATTRIBUTE8
	         ,p_line_rec.TP_ATTRIBUTE9
	         ,p_line_rec.TP_ATTRIBUTE10
	         ,p_line_rec.TP_ATTRIBUTE11
	         ,p_line_rec.TP_ATTRIBUTE12
	         ,p_line_rec.TP_ATTRIBUTE13
	         ,p_line_rec.TP_ATTRIBUTE14
	         ,p_line_rec.TP_ATTRIBUTE15
	         --,p_line_rec.FLOW_STATUS_CODE
	         --,p_line_rec.MARKETING_SOURCE_CODE_ID
	         ,p_line_rec.CALCULATE_PRICE_FLAG
	         ,p_line_rec.COMMITMENT_ID
	         ,p_line_rec.ORDER_SOURCE_ID
	         --,p_line_rec.upgraded_flag
	         ,p_line_rec.LOCK_CONTROL
	         ,p_line_rec.WF_PROCESS_NAME
	         ,p_line_rec.II_START_INDEX
	         ,p_line_rec.II_COUNT
	         ,p_line_rec.user_item_description
	         ,p_line_rec.parent_line_index
	         ,p_line_rec.firm_demand_flag
	         -- end customer
	  				,p_line_rec.End_customer_contact_id
	  				,p_line_rec.End_customer_id
	  				,p_line_rec.End_customer_site_use_id
	  				,p_line_rec.IB_owner
	  				,p_line_rec.IB_current_location
	  				,p_line_rec.IB_Installed_at_Location
	         ,p_line_rec.cust_trx_type_id
	         ,p_line_rec.tax_calculation_flag
	         ,p_line_rec.ato_line_index
	         ,p_line_rec.top_model_line_index
	         ;
     END IF; -- p_process_configuration
   ELSE -- added for bug 3390458

      -- This code is added to rtrim text columns. It is controlled by the
      -- input parameter to HVOP order import program.
	IF p_process_configurations = 'N'
         THEN
      oe_debug_pub.add('before OPEN c_lines_rtrim');
      OPEN c_lines_rtrim;
      oe_debug_pub.add('after OPEN c_lines_rtrim');
      ------------------------------------------------------------------------------

      FETCH c_lines_rtrim BULK COLLECT INTO
              p_line_rec.ACCOUNTING_RULE_ID
             ,p_line_rec.ACCOUNTING_RULE_DURATION
             ,p_line_rec.ACTUAL_ARRIVAL_DATE
             --,p_line_rec.ACTUAL_SHIPMENT_DATE
             ,p_line_rec.AGREEMENT_ID
             ,p_line_rec.ARRIVAL_SET_ID
             ,p_line_rec.ATO_LINE_ID
             ,p_line_rec.ATTRIBUTE1
             ,p_line_rec.ATTRIBUTE10
             ,p_line_rec.ATTRIBUTE11
             ,p_line_rec.ATTRIBUTE12
             ,p_line_rec.ATTRIBUTE13
             ,p_line_rec.ATTRIBUTE14
             ,p_line_rec.ATTRIBUTE15
             ,p_line_rec.ATTRIBUTE16   --For bug 2184255
             ,p_line_rec.ATTRIBUTE17
             ,p_line_rec.ATTRIBUTE18
             ,p_line_rec.ATTRIBUTE19
             ,p_line_rec.ATTRIBUTE2
             ,p_line_rec.ATTRIBUTE20
             ,p_line_rec.ATTRIBUTE3
             ,p_line_rec.ATTRIBUTE4
             ,p_line_rec.ATTRIBUTE5
             ,p_line_rec.ATTRIBUTE6
             ,p_line_rec.ATTRIBUTE7
             ,p_line_rec.ATTRIBUTE8
             ,p_line_rec.ATTRIBUTE9
             --,p_line_rec.AUTO_SELECTED_QUANTITY
             ,p_line_rec.AUTHORIZED_TO_SHIP_FLAG
             ,p_line_rec.BOOKED_FLAG
             ,p_line_rec.CANCELLED_FLAG
             ,p_line_rec.CANCELLED_QUANTITY
             ,p_line_rec.COMPONENT_CODE
             ,p_line_rec.COMPONENT_NUMBER
             ,p_line_rec.COMPONENT_SEQUENCE_ID
             --,p_line_rec.CONFIG_HEADER_ID
             --,p_line_rec.CONFIG_REV_NBR
             --,p_line_rec.CONFIG_DISPLAY_SEQUENCE
             --,p_line_rec.CONFIGURATION_ID
             ,p_line_rec.CONTEXT
             --,p_line_rec.CREATED_BY
             --,p_line_rec.CREATION_DATE
             ,p_line_rec.CREDIT_INVOICE_LINE_ID
             ,p_line_rec.CUSTOMER_DOCK_CODE
             ,p_line_rec.CUSTOMER_JOB
             ,p_line_rec.CUSTOMER_PRODUCTION_LINE
             ,p_line_rec.CUST_PRODUCTION_SEQ_NUM
             --,p_line_rec.CUSTOMER_TRX_LINE_ID
             ,p_line_rec.CUST_MODEL_SERIAL_NUMBER
             ,p_line_rec.CUST_PO_NUMBER
             ,p_line_rec.CUSTOMER_LINE_NUMBER
             ,p_line_rec.DELIVERY_LEAD_TIME
             ,p_line_rec.DELIVER_TO_CONTACT_ID
             ,p_line_rec.DELIVER_TO_ORG_ID
             ,p_line_rec.DEMAND_BUCKET_TYPE_CODE
             ,p_line_rec.DEMAND_CLASS_CODE
             --,p_line_rec.DEP_PLAN_REQUIRED_FLAG
             ,p_line_rec.EARLIEST_ACCEPTABLE_DATE
             ,p_line_rec.END_ITEM_UNIT_NUMBER
             ,p_line_rec.EXPLOSION_DATE
             --,p_line_rec.FIRST_ACK_CODE
             --,p_line_rec.FIRST_ACK_DATE
             ,p_line_rec.FOB_POINT_CODE
             ,p_line_rec.FREIGHT_CARRIER_CODE
             ,p_line_rec.FREIGHT_TERMS_CODE
             --,p_line_rec.FULFILLED_QUANTITY
             --,p_line_rec.FULFILLED_FLAG
             --,p_line_rec.FULFILLMENT_METHOD_CODE
             --,p_line_rec.FULFILLMENT_DATE
             ,p_line_rec.GLOBAL_ATTRIBUTE1
             ,p_line_rec.GLOBAL_ATTRIBUTE10
             ,p_line_rec.GLOBAL_ATTRIBUTE11
             ,p_line_rec.GLOBAL_ATTRIBUTE12
             ,p_line_rec.GLOBAL_ATTRIBUTE13
             ,p_line_rec.GLOBAL_ATTRIBUTE14
             ,p_line_rec.GLOBAL_ATTRIBUTE15
             ,p_line_rec.GLOBAL_ATTRIBUTE16
             ,p_line_rec.GLOBAL_ATTRIBUTE17
             ,p_line_rec.GLOBAL_ATTRIBUTE18
             ,p_line_rec.GLOBAL_ATTRIBUTE19
             ,p_line_rec.GLOBAL_ATTRIBUTE2
             ,p_line_rec.GLOBAL_ATTRIBUTE20
             ,p_line_rec.GLOBAL_ATTRIBUTE3
             ,p_line_rec.GLOBAL_ATTRIBUTE4
             ,p_line_rec.GLOBAL_ATTRIBUTE5
             ,p_line_rec.GLOBAL_ATTRIBUTE6
             ,p_line_rec.GLOBAL_ATTRIBUTE7
             ,p_line_rec.GLOBAL_ATTRIBUTE8
             ,p_line_rec.GLOBAL_ATTRIBUTE9
             ,p_line_rec.GLOBAL_ATTRIBUTE_CATEGORY
             ,p_line_rec.HEADER_ID
             ,p_line_rec.INDUSTRY_ATTRIBUTE1
             ,p_line_rec.INDUSTRY_ATTRIBUTE10
             ,p_line_rec.INDUSTRY_ATTRIBUTE11
             ,p_line_rec.INDUSTRY_ATTRIBUTE12
             ,p_line_rec.INDUSTRY_ATTRIBUTE13
             ,p_line_rec.INDUSTRY_ATTRIBUTE14
             ,p_line_rec.INDUSTRY_ATTRIBUTE15
             ,p_line_rec.INDUSTRY_ATTRIBUTE16
             ,p_line_rec.INDUSTRY_ATTRIBUTE17
             ,p_line_rec.INDUSTRY_ATTRIBUTE18
             ,p_line_rec.INDUSTRY_ATTRIBUTE19
             ,p_line_rec.INDUSTRY_ATTRIBUTE20
             ,p_line_rec.INDUSTRY_ATTRIBUTE21
             ,p_line_rec.INDUSTRY_ATTRIBUTE22
             ,p_line_rec.INDUSTRY_ATTRIBUTE23
             ,p_line_rec.INDUSTRY_ATTRIBUTE24
             ,p_line_rec.INDUSTRY_ATTRIBUTE25
             ,p_line_rec.INDUSTRY_ATTRIBUTE26
             ,p_line_rec.INDUSTRY_ATTRIBUTE27
             ,p_line_rec.INDUSTRY_ATTRIBUTE28
             ,p_line_rec.INDUSTRY_ATTRIBUTE29
             ,p_line_rec.INDUSTRY_ATTRIBUTE30
             ,p_line_rec.INDUSTRY_ATTRIBUTE2
             ,p_line_rec.INDUSTRY_ATTRIBUTE3
             ,p_line_rec.INDUSTRY_ATTRIBUTE4
             ,p_line_rec.INDUSTRY_ATTRIBUTE5
             ,p_line_rec.INDUSTRY_ATTRIBUTE6
             ,p_line_rec.INDUSTRY_ATTRIBUTE7
             ,p_line_rec.INDUSTRY_ATTRIBUTE8
             ,p_line_rec.INDUSTRY_ATTRIBUTE9
             ,p_line_rec.INDUSTRY_CONTEXT
             --,p_line_rec.INTERMED_SHIP_TO_CONTACT_ID
             --,p_line_rec.INTERMED_SHIP_TO_ORG_ID
             ,p_line_rec.INVENTORY_ITEM_ID
             --,p_line_rec.INVOICE_INTERFACE_STATUS_CODE
             ,p_line_rec.INVOICE_TO_CONTACT_ID
             ,p_line_rec.INVOICE_TO_ORG_ID
             --,p_line_rec.INVOICED_QUANTITY
             ,p_line_rec.INVOICING_RULE_ID
             ,p_line_rec.ORDERED_ITEM_ID
             ,p_line_rec.ITEM_IDENTIFIER_TYPE
             ,p_line_rec.ORDERED_ITEM
             ,p_line_rec.CUSTOMER_ITEM_NET_PRICE
             ,p_line_rec.CUSTOMER_PAYMENT_TERM_ID
             ,p_line_rec.ITEM_REVISION
             ,p_line_rec.ITEM_TYPE_CODE
             --,p_line_rec.LAST_ACK_CODE
             --,p_line_rec.LAST_ACK_DATE
             --,p_line_rec.LAST_UPDATED_BY
             --,p_line_rec.LAST_UPDATE_DATE
             --,p_line_rec.LAST_UPDATE_LOGIN
             ,p_line_rec.LATEST_ACCEPTABLE_DATE
             ,p_line_rec.LINE_CATEGORY_CODE
             ,p_line_rec.LINE_ID
             ,p_line_rec.LINE_NUMBER
             ,p_line_rec.LINE_TYPE_ID
             ,p_line_rec.LINK_TO_LINE_ID
             ,p_line_rec.MODEL_GROUP_NUMBER
             ,p_line_rec.MFG_LEAD_TIME
             --,p_line_rec.OPEN_FLAG
             ,p_line_rec.OPTION_FLAG
             ,p_line_rec.OPTION_NUMBER
             ,p_line_rec.ORDERED_QUANTITY
             ,p_line_rec.ORDERED_QUANTITY2              --OPM 02/JUN/00
             ,p_line_rec.ORDER_QUANTITY_UOM
             ,p_line_rec.ORDERED_QUANTITY_UOM2          --OPM 02/JUN/00
             ,p_line_rec.ORG_ID
             ,p_line_rec.ORIG_SYS_DOCUMENT_REF
             ,p_line_rec.ORIG_SYS_LINE_REF
             ,p_line_rec.ORIG_SYS_SHIPMENT_REF
             ,p_line_rec.CHANGE_SEQUENCE
             ,p_line_rec.OVER_SHIP_REASON_CODE
             ,p_line_rec.OVER_SHIP_RESOLVED_FLAG
             ,p_line_rec.PAYMENT_TERM_ID
             --,p_line_rec.PLANNING_PRIORITY
             ,p_line_rec.PREFERRED_GRADE                --OPM HVOP
             ,p_line_rec.PRICE_LIST_ID
             --,p_line_rec.PRICE_REQUEST_CODE             --PROMOTIONS MAY/01
             ,p_line_rec.PRICING_ATTRIBUTE1
             ,p_line_rec.PRICING_ATTRIBUTE10
             ,p_line_rec.PRICING_ATTRIBUTE2
             ,p_line_rec.PRICING_ATTRIBUTE3
             ,p_line_rec.PRICING_ATTRIBUTE4
             ,p_line_rec.PRICING_ATTRIBUTE5
             ,p_line_rec.PRICING_ATTRIBUTE6
             ,p_line_rec.PRICING_ATTRIBUTE7
             ,p_line_rec.PRICING_ATTRIBUTE8
             ,p_line_rec.PRICING_ATTRIBUTE9
             ,p_line_rec.PRICING_CONTEXT
             ,p_line_rec.PRICING_DATE
             ,p_line_rec.PRICING_QUANTITY
             ,p_line_rec.PRICING_QUANTITY_UOM
             --,p_line_rec.PROGRAM_APPLICATION_ID
             --,p_line_rec.PROGRAM_ID
             --,p_line_rec.PROGRAM_UPDATE_DATE
             ,p_line_rec.PROJECT_ID
             ,p_line_rec.PROMISE_DATE
             ,p_line_rec.RE_SOURCE_FLAG
             --,p_line_rec.REFERENCE_CUSTOMER_TRX_LINE_ID
             ,p_line_rec.REFERENCE_HEADER_ID
             ,p_line_rec.REFERENCE_LINE_ID
             ,p_line_rec.REFERENCE_TYPE
             ,p_line_rec.REQUEST_DATE
             ,p_line_rec.REQUEST_ID
             ,p_line_rec.RETURN_ATTRIBUTE1
             ,p_line_rec.RETURN_ATTRIBUTE10
             ,p_line_rec.RETURN_ATTRIBUTE11
             ,p_line_rec.RETURN_ATTRIBUTE12
             ,p_line_rec.RETURN_ATTRIBUTE13
             ,p_line_rec.RETURN_ATTRIBUTE14
             ,p_line_rec.RETURN_ATTRIBUTE15
             ,p_line_rec.RETURN_ATTRIBUTE2
             ,p_line_rec.RETURN_ATTRIBUTE3
             ,p_line_rec.RETURN_ATTRIBUTE4
             ,p_line_rec.RETURN_ATTRIBUTE5
             ,p_line_rec.RETURN_ATTRIBUTE6
             ,p_line_rec.RETURN_ATTRIBUTE7
             ,p_line_rec.RETURN_ATTRIBUTE8
             ,p_line_rec.RETURN_ATTRIBUTE9
             ,p_line_rec.RETURN_CONTEXT
             ,p_line_rec.RETURN_REASON_CODE
             --,p_line_rec.RLA_SCHEDULE_TYPE_CODE
             ,p_line_rec.SALESREP_ID
             ,p_line_rec.SCHEDULE_ARRIVAL_DATE
             ,p_line_rec.SCHEDULE_SHIP_DATE
             ,p_line_rec.SCHEDULE_STATUS_CODE
             ,p_line_rec.SHIPMENT_NUMBER
             ,p_line_rec.SHIPMENT_PRIORITY_CODE
             ,p_line_rec.SHIPPED_QUANTITY
             ,p_line_rec.SHIPPED_QUANTITY2 -- OPM B1661023 04/02/01
             ,p_line_rec.SHIPPING_METHOD_CODE
             ,p_line_rec.SHIPPING_QUANTITY
             ,p_line_rec.SHIPPING_QUANTITY2 -- OPM B1661023 04/02/01
             ,p_line_rec.SHIPPING_QUANTITY_UOM
             ,p_line_rec.SHIP_FROM_ORG_ID
             ,p_line_rec.SUBINVENTORY
             ,p_line_rec.SHIP_SET_ID
             ,p_line_rec.SHIP_TOLERANCE_ABOVE
             ,p_line_rec.SHIP_TOLERANCE_BELOW
             ,p_line_rec.SHIPPABLE_FLAG
             --,p_line_rec.SHIPPING_INTERFACED_FLAG
             ,p_line_rec.SHIP_TO_CONTACT_ID
             ,p_line_rec.SHIP_TO_ORG_ID
             ,p_line_rec.SHIP_MODEL_COMPLETE_FLAG
             ,p_line_rec.SOLD_TO_ORG_ID
             ,p_line_rec.SOLD_FROM_ORG_ID
             ,p_line_rec.SORT_ORDER
             ,p_line_rec.SOURCE_DOCUMENT_ID
             --,p_line_rec.SOURCE_DOCUMENT_LINE_ID
             --,p_line_rec.SOURCE_DOCUMENT_TYPE_ID
             ,p_line_rec.SOURCE_TYPE_CODE
             ,p_line_rec.SPLIT_FROM_LINE_ID
             --,p_line_rec.LINE_SET_ID
             --,p_line_rec.SPLIT_BY
             ,p_line_rec.MODEL_REMNANT_FLAG
             ,p_line_rec.TASK_ID
             ,p_line_rec.TAX_CODE
             ,p_line_rec.TAX_DATE
             ,p_line_rec.TAX_EXEMPT_FLAG
             ,p_line_rec.TAX_EXEMPT_NUMBER
             ,p_line_rec.TAX_EXEMPT_REASON_CODE
             ,p_line_rec.TAX_POINT_CODE
             --,p_line_rec.TAX_RATE
             ,p_line_rec.TAX_VALUE
             ,p_line_rec.TOP_MODEL_LINE_ID
             ,p_line_rec.UNIT_LIST_PRICE
             ,p_line_rec.UNIT_LIST_PRICE_PER_PQTY
             ,p_line_rec.UNIT_SELLING_PRICE
             ,p_line_rec.UNIT_SELLING_PRICE_PER_PQTY
             ,p_line_rec.VISIBLE_DEMAND_FLAG
             ,p_line_rec.VEH_CUS_ITEM_CUM_KEY_ID
             ,p_line_rec.SHIPPING_INSTRUCTIONS
             ,p_line_rec.PACKING_INSTRUCTIONS
             ,p_line_rec.SERVICE_TXN_REASON_CODE
             ,p_line_rec.SERVICE_TXN_COMMENTS
             ,p_line_rec.SERVICE_DURATION
             ,p_line_rec.SERVICE_PERIOD
             ,p_line_rec.SERVICE_START_DATE
             ,p_line_rec.SERVICE_END_DATE
             ,p_line_rec.SERVICE_COTERMINATE_FLAG
             ,p_line_rec.UNIT_LIST_PERCENT
             ,p_line_rec.UNIT_SELLING_PERCENT
             ,p_line_rec.UNIT_PERCENT_BASE_PRICE
             ,p_line_rec.SERVICE_NUMBER
             ,p_line_rec.SERVICE_REFERENCE_TYPE_CODE
             --,p_line_rec.SERVICE_REFERENCE_LINE_ID
             --,p_line_rec.SERVICE_REFERENCE_SYSTEM_ID
             ,p_line_rec.TP_CONTEXT
             ,p_line_rec.TP_ATTRIBUTE1
             ,p_line_rec.TP_ATTRIBUTE2
             ,p_line_rec.TP_ATTRIBUTE3
             ,p_line_rec.TP_ATTRIBUTE4
             ,p_line_rec.TP_ATTRIBUTE5
             ,p_line_rec.TP_ATTRIBUTE6
             ,p_line_rec.TP_ATTRIBUTE7
             ,p_line_rec.TP_ATTRIBUTE8
             ,p_line_rec.TP_ATTRIBUTE9
             ,p_line_rec.TP_ATTRIBUTE10
             ,p_line_rec.TP_ATTRIBUTE11
             ,p_line_rec.TP_ATTRIBUTE12
             ,p_line_rec.TP_ATTRIBUTE13
             ,p_line_rec.TP_ATTRIBUTE14
             ,p_line_rec.TP_ATTRIBUTE15
             --,p_line_rec.FLOW_STATUS_CODE
             --,p_line_rec.MARKETING_SOURCE_CODE_ID
             ,p_line_rec.CALCULATE_PRICE_FLAG
             ,p_line_rec.COMMITMENT_ID
             ,p_line_rec.ORDER_SOURCE_ID
             --,p_line_rec.upgraded_flag
             ,p_line_rec.LOCK_CONTROL
             ,p_line_rec.WF_PROCESS_NAME
             ,p_line_rec.II_START_INDEX
             ,p_line_rec.II_COUNT
             ,p_line_rec.user_item_description
             ,p_line_rec.parent_line_index
             ,p_line_rec.firm_demand_flag
             -- end customer (Bug 5054618)
      				,p_line_rec.End_customer_contact_id
      				,p_line_rec.End_customer_id
      				,p_line_rec.End_customer_site_use_id
      				,p_line_rec.IB_owner
      				,p_line_rec.IB_current_location
      				,p_line_rec.IB_Installed_at_Location
       ;
       else  -- p_process_configuration=y
        IF l_debug_level > 0 THEN
               oe_debug_pub.add('before OPEN c_lines1_rtrim');
             END IF;

             OPEN c_lines1_rtrim;

             IF l_debug_level > 0 THEN
               oe_debug_pub.add('after OPEN c_lines1_rtrim');
             END IF;

             FETCH c_lines1_rtrim BULK COLLECT INTO
               p_line_rec.ACCOUNTING_RULE_ID
              ,p_line_rec.ACCOUNTING_RULE_DURATION
              ,p_line_rec.ACTUAL_ARRIVAL_DATE
              --,p_line_rec.ACTUAL_SHIPMENT_DATE
              ,p_line_rec.AGREEMENT_ID
              ,p_line_rec.ARRIVAL_SET_ID
              ,p_line_rec.ATO_LINE_ID
              ,p_line_rec.ATTRIBUTE1
              ,p_line_rec.ATTRIBUTE10
              ,p_line_rec.ATTRIBUTE11
              ,p_line_rec.ATTRIBUTE12
              ,p_line_rec.ATTRIBUTE13
              ,p_line_rec.ATTRIBUTE14
              ,p_line_rec.ATTRIBUTE15
              ,p_line_rec.ATTRIBUTE16   --For bug 2184255
              ,p_line_rec.ATTRIBUTE17
              ,p_line_rec.ATTRIBUTE18
              ,p_line_rec.ATTRIBUTE19
              ,p_line_rec.ATTRIBUTE2
              ,p_line_rec.ATTRIBUTE20
              ,p_line_rec.ATTRIBUTE3
              ,p_line_rec.ATTRIBUTE4
              ,p_line_rec.ATTRIBUTE5
              ,p_line_rec.ATTRIBUTE6
              ,p_line_rec.ATTRIBUTE7
              ,p_line_rec.ATTRIBUTE8
              ,p_line_rec.ATTRIBUTE9
              --,p_line_rec.AUTO_SELECTED_QUANTITY
              ,p_line_rec.AUTHORIZED_TO_SHIP_FLAG
              ,p_line_rec.BOOKED_FLAG
              ,p_line_rec.CANCELLED_FLAG
              ,p_line_rec.CANCELLED_QUANTITY
              ,p_line_rec.COMPONENT_CODE
              ,p_line_rec.COMPONENT_NUMBER
              ,p_line_rec.COMPONENT_SEQUENCE_ID
              ,p_line_rec.CONFIG_HEADER_ID
              ,p_line_rec.CONFIG_REV_NBR
              ,p_line_rec.CONFIG_DISPLAY_SEQUENCE
              ,p_line_rec.CONFIGURATION_ID
              ,p_line_rec.CONTEXT
              --,p_line_rec.CREATED_BY
              --,p_line_rec.CREATION_DATE
              ,p_line_rec.CREDIT_INVOICE_LINE_ID
              ,p_line_rec.CUSTOMER_DOCK_CODE
              ,p_line_rec.CUSTOMER_JOB
              ,p_line_rec.CUSTOMER_PRODUCTION_LINE
              ,p_line_rec.CUST_PRODUCTION_SEQ_NUM
              --,p_line_rec.CUSTOMER_TRX_LINE_ID
              ,p_line_rec.CUST_MODEL_SERIAL_NUMBER
              ,p_line_rec.CUST_PO_NUMBER
              ,p_line_rec.CUSTOMER_LINE_NUMBER
              ,p_line_rec.DELIVERY_LEAD_TIME
              ,p_line_rec.DELIVER_TO_CONTACT_ID
              ,p_line_rec.DELIVER_TO_ORG_ID
              ,p_line_rec.DEMAND_BUCKET_TYPE_CODE
              ,p_line_rec.DEMAND_CLASS_CODE
              --,p_line_rec.DEP_PLAN_REQUIRED_FLAG
              ,p_line_rec.EARLIEST_ACCEPTABLE_DATE
              ,p_line_rec.END_ITEM_UNIT_NUMBER
              ,p_line_rec.EXPLOSION_DATE
              -- ,p_line_rec.FIRST_ACK_CODE
              -- ,p_line_rec.FIRST_ACK_DATE
              ,p_line_rec.FOB_POINT_CODE
              ,p_line_rec.FREIGHT_CARRIER_CODE
              ,p_line_rec.FREIGHT_TERMS_CODE
              --,p_line_rec.FULFILLED_QUANTITY
              --,p_line_rec.FULFILLED_FLAG
              --,p_line_rec.FULFILLMENT_METHOD_CODE
              --,p_line_rec.FULFILLMENT_DATE
              ,p_line_rec.GLOBAL_ATTRIBUTE1
              ,p_line_rec.GLOBAL_ATTRIBUTE10
              ,p_line_rec.GLOBAL_ATTRIBUTE11
              ,p_line_rec.GLOBAL_ATTRIBUTE12
              ,p_line_rec.GLOBAL_ATTRIBUTE13
              ,p_line_rec.GLOBAL_ATTRIBUTE14
              ,p_line_rec.GLOBAL_ATTRIBUTE15
              ,p_line_rec.GLOBAL_ATTRIBUTE16
              ,p_line_rec.GLOBAL_ATTRIBUTE17
              ,p_line_rec.GLOBAL_ATTRIBUTE18
              ,p_line_rec.GLOBAL_ATTRIBUTE19
              ,p_line_rec.GLOBAL_ATTRIBUTE2
              ,p_line_rec.GLOBAL_ATTRIBUTE20
              ,p_line_rec.GLOBAL_ATTRIBUTE3
              ,p_line_rec.GLOBAL_ATTRIBUTE4
              ,p_line_rec.GLOBAL_ATTRIBUTE5
              ,p_line_rec.GLOBAL_ATTRIBUTE6
              ,p_line_rec.GLOBAL_ATTRIBUTE7
              ,p_line_rec.GLOBAL_ATTRIBUTE8
              ,p_line_rec.GLOBAL_ATTRIBUTE9
              ,p_line_rec.GLOBAL_ATTRIBUTE_CATEGORY
              ,p_line_rec.HEADER_ID
              ,p_line_rec.INDUSTRY_ATTRIBUTE1
              ,p_line_rec.INDUSTRY_ATTRIBUTE10
              ,p_line_rec.INDUSTRY_ATTRIBUTE11
              ,p_line_rec.INDUSTRY_ATTRIBUTE12
              ,p_line_rec.INDUSTRY_ATTRIBUTE13
              ,p_line_rec.INDUSTRY_ATTRIBUTE14
              ,p_line_rec.INDUSTRY_ATTRIBUTE15
              ,p_line_rec.INDUSTRY_ATTRIBUTE16
              ,p_line_rec.INDUSTRY_ATTRIBUTE17
              ,p_line_rec.INDUSTRY_ATTRIBUTE18
              ,p_line_rec.INDUSTRY_ATTRIBUTE19
              ,p_line_rec.INDUSTRY_ATTRIBUTE20
              ,p_line_rec.INDUSTRY_ATTRIBUTE21
              ,p_line_rec.INDUSTRY_ATTRIBUTE22
              ,p_line_rec.INDUSTRY_ATTRIBUTE23
              ,p_line_rec.INDUSTRY_ATTRIBUTE24
              ,p_line_rec.INDUSTRY_ATTRIBUTE25
              ,p_line_rec.INDUSTRY_ATTRIBUTE26
              ,p_line_rec.INDUSTRY_ATTRIBUTE27
              ,p_line_rec.INDUSTRY_ATTRIBUTE28
              ,p_line_rec.INDUSTRY_ATTRIBUTE29
              ,p_line_rec.INDUSTRY_ATTRIBUTE30
              ,p_line_rec.INDUSTRY_ATTRIBUTE2
              ,p_line_rec.INDUSTRY_ATTRIBUTE3
              ,p_line_rec.INDUSTRY_ATTRIBUTE4
              ,p_line_rec.INDUSTRY_ATTRIBUTE5
              ,p_line_rec.INDUSTRY_ATTRIBUTE6
              ,p_line_rec.INDUSTRY_ATTRIBUTE7
              ,p_line_rec.INDUSTRY_ATTRIBUTE8
              ,p_line_rec.INDUSTRY_ATTRIBUTE9
              ,p_line_rec.INDUSTRY_CONTEXT
              --,p_line_rec.INTERMED_SHIP_TO_CONTACT_ID
              --,p_line_rec.INTERMED_SHIP_TO_ORG_ID
              ,p_line_rec.INVENTORY_ITEM_ID
              --,p_line_rec.INVOICE_INTERFACE_STATUS_CODE
              ,p_line_rec.INVOICE_TO_CONTACT_ID
              ,p_line_rec.INVOICE_TO_ORG_ID
              --,p_line_rec.INVOICED_QUANTITY
              ,p_line_rec.INVOICING_RULE_ID
              ,p_line_rec.ORDERED_ITEM_ID
              ,p_line_rec.ITEM_IDENTIFIER_TYPE
              ,p_line_rec.ORDERED_ITEM
              ,p_line_rec.CUSTOMER_ITEM_NET_PRICE
              ,p_line_rec.CUSTOMER_PAYMENT_TERM_ID
              ,p_line_rec.ITEM_REVISION
              ,p_line_rec.ITEM_TYPE_CODE
              -- ,p_line_rec.LAST_ACK_CODE
              -- ,p_line_rec.LAST_ACK_DATE
              --,p_line_rec.LAST_UPDATED_BY
              --,p_line_rec.LAST_UPDATE_DATE
              --,p_line_rec.LAST_UPDATE_LOGIN
              ,p_line_rec.LATEST_ACCEPTABLE_DATE
              ,p_line_rec.LINE_CATEGORY_CODE
              ,p_line_rec.LINE_ID
              ,p_line_rec.LINE_NUMBER
              ,p_line_rec.LINE_TYPE_ID
              ,p_line_rec.LINK_TO_LINE_ID
              ,p_line_rec.MODEL_GROUP_NUMBER
              ,p_line_rec.MFG_LEAD_TIME
              --,p_line_rec.OPEN_FLAG
              ,p_line_rec.OPTION_FLAG
              ,p_line_rec.OPTION_NUMBER
              ,p_line_rec.ORDERED_QUANTITY
              ,p_line_rec.ORDERED_QUANTITY2              --OPM 02/JUN/00
              ,p_line_rec.ORDER_QUANTITY_UOM
              ,p_line_rec.ORDERED_QUANTITY_UOM2          --OPM 02/JUN/00
              ,p_line_rec.ORG_ID
              ,p_line_rec.ORIG_SYS_DOCUMENT_REF
              ,p_line_rec.ORIG_SYS_LINE_REF
              ,p_line_rec.ORIG_SYS_SHIPMENT_REF
              ,p_line_rec.CHANGE_SEQUENCE
              ,p_line_rec.OVER_SHIP_REASON_CODE
              ,p_line_rec.OVER_SHIP_RESOLVED_FLAG
              ,p_line_rec.PAYMENT_TERM_ID
              --,p_line_rec.PLANNING_PRIORITY
              ,p_line_rec.PREFERRED_GRADE                --OPM HVOP
              ,p_line_rec.PRICE_LIST_ID
              --,p_line_rec.PRICE_REQUEST_CODE             --PROMOTIONS MAY/01
              ,p_line_rec.PRICING_ATTRIBUTE1
              ,p_line_rec.PRICING_ATTRIBUTE10
              ,p_line_rec.PRICING_ATTRIBUTE2
              ,p_line_rec.PRICING_ATTRIBUTE3
              ,p_line_rec.PRICING_ATTRIBUTE4
              ,p_line_rec.PRICING_ATTRIBUTE5
              ,p_line_rec.PRICING_ATTRIBUTE6
              ,p_line_rec.PRICING_ATTRIBUTE7
              ,p_line_rec.PRICING_ATTRIBUTE8
              ,p_line_rec.PRICING_ATTRIBUTE9
              ,p_line_rec.PRICING_CONTEXT
              ,p_line_rec.PRICING_DATE
              ,p_line_rec.PRICING_QUANTITY
              ,p_line_rec.PRICING_QUANTITY_UOM
              --,p_line_rec.PROGRAM_APPLICATION_ID
              --,p_line_rec.PROGRAM_ID
              --,p_line_rec.PROGRAM_UPDATE_DATE
              ,p_line_rec.PROJECT_ID
              ,p_line_rec.PROMISE_DATE
              ,p_line_rec.RE_SOURCE_FLAG
              --,p_line_rec.REFERENCE_CUSTOMER_TRX_LINE_ID
              ,p_line_rec.REFERENCE_HEADER_ID
              ,p_line_rec.REFERENCE_LINE_ID
              ,p_line_rec.REFERENCE_TYPE
              ,p_line_rec.REQUEST_DATE
              ,p_line_rec.REQUEST_ID
              ,p_line_rec.RETURN_ATTRIBUTE1
              ,p_line_rec.RETURN_ATTRIBUTE10
              ,p_line_rec.RETURN_ATTRIBUTE11
              ,p_line_rec.RETURN_ATTRIBUTE12
              ,p_line_rec.RETURN_ATTRIBUTE13
              ,p_line_rec.RETURN_ATTRIBUTE14
              ,p_line_rec.RETURN_ATTRIBUTE15
              ,p_line_rec.RETURN_ATTRIBUTE2
              ,p_line_rec.RETURN_ATTRIBUTE3
              ,p_line_rec.RETURN_ATTRIBUTE4
              ,p_line_rec.RETURN_ATTRIBUTE5
              ,p_line_rec.RETURN_ATTRIBUTE6
              ,p_line_rec.RETURN_ATTRIBUTE7
              ,p_line_rec.RETURN_ATTRIBUTE8
              ,p_line_rec.RETURN_ATTRIBUTE9
              ,p_line_rec.RETURN_CONTEXT
              ,p_line_rec.RETURN_REASON_CODE
              --,p_line_rec.RLA_SCHEDULE_TYPE_CODE
              ,p_line_rec.SALESREP_ID
              ,p_line_rec.SCHEDULE_ARRIVAL_DATE
              ,p_line_rec.SCHEDULE_SHIP_DATE
              ,p_line_rec.SCHEDULE_STATUS_CODE
              ,p_line_rec.SHIPMENT_NUMBER
              ,p_line_rec.SHIPMENT_PRIORITY_CODE
              ,p_line_rec.SHIPPED_QUANTITY
              ,p_line_rec.SHIPPED_QUANTITY2 -- OPM B1661023 04/02/01
              ,p_line_rec.SHIPPING_METHOD_CODE
              ,p_line_rec.SHIPPING_QUANTITY
              ,p_line_rec.SHIPPING_QUANTITY2 -- OPM B1661023 04/02/01
              ,p_line_rec.SHIPPING_QUANTITY_UOM
              ,p_line_rec.SHIP_FROM_ORG_ID
              ,p_line_rec.SUBINVENTORY
              ,p_line_rec.SHIP_SET_ID
              ,p_line_rec.SHIP_TOLERANCE_ABOVE
              ,p_line_rec.SHIP_TOLERANCE_BELOW
              ,p_line_rec.SHIPPABLE_FLAG
              --,p_line_rec.SHIPPING_INTERFACED_FLAG
              ,p_line_rec.SHIP_TO_CONTACT_ID
              ,p_line_rec.SHIP_TO_ORG_ID
              ,p_line_rec.SHIP_MODEL_COMPLETE_FLAG
              ,p_line_rec.SOLD_TO_ORG_ID
              ,p_line_rec.SOLD_FROM_ORG_ID
              ,p_line_rec.SORT_ORDER
              ,p_line_rec.SOURCE_DOCUMENT_ID
              --,p_line_rec.SOURCE_DOCUMENT_LINE_ID
              --,p_line_rec.SOURCE_DOCUMENT_TYPE_ID
              ,p_line_rec.SOURCE_TYPE_CODE
              ,p_line_rec.SPLIT_FROM_LINE_ID
              --,p_line_rec.LINE_SET_ID
              --,p_line_rec.SPLIT_BY
              ,p_line_rec.MODEL_REMNANT_FLAG
              ,p_line_rec.TASK_ID
              ,p_line_rec.TAX_CODE
              ,p_line_rec.TAX_DATE
              ,p_line_rec.TAX_EXEMPT_FLAG
              ,p_line_rec.TAX_EXEMPT_NUMBER
              ,p_line_rec.TAX_EXEMPT_REASON_CODE
              ,p_line_rec.TAX_POINT_CODE
              --,p_line_rec.TAX_RATE
              ,p_line_rec.TAX_VALUE
              ,p_line_rec.TOP_MODEL_LINE_ID
              ,p_line_rec.TOP_MODEL_LINE_REF
              ,p_line_rec.UNIT_LIST_PRICE
              ,p_line_rec.UNIT_LIST_PRICE_PER_PQTY
              ,p_line_rec.UNIT_SELLING_PRICE
              ,p_line_rec.UNIT_SELLING_PRICE_PER_PQTY
              ,p_line_rec.VISIBLE_DEMAND_FLAG
              ,p_line_rec.VEH_CUS_ITEM_CUM_KEY_ID
              ,p_line_rec.SHIPPING_INSTRUCTIONS
              ,p_line_rec.PACKING_INSTRUCTIONS
              ,p_line_rec.SERVICE_TXN_REASON_CODE
              ,p_line_rec.SERVICE_TXN_COMMENTS
              ,p_line_rec.SERVICE_DURATION
              ,p_line_rec.SERVICE_PERIOD
              ,p_line_rec.SERVICE_START_DATE
              ,p_line_rec.SERVICE_END_DATE
              ,p_line_rec.SERVICE_COTERMINATE_FLAG
              ,p_line_rec.UNIT_LIST_PERCENT
              ,p_line_rec.UNIT_SELLING_PERCENT
              ,p_line_rec.UNIT_PERCENT_BASE_PRICE
              ,p_line_rec.SERVICE_NUMBER
              ,p_line_rec.SERVICE_REFERENCE_TYPE_CODE
              --,p_line_rec.SERVICE_REFERENCE_LINE_ID
              --,p_line_rec.SERVICE_REFERENCE_SYSTEM_ID
              ,p_line_rec.TP_CONTEXT
              ,p_line_rec.TP_ATTRIBUTE1
              ,p_line_rec.TP_ATTRIBUTE2
              ,p_line_rec.TP_ATTRIBUTE3
              ,p_line_rec.TP_ATTRIBUTE4
              ,p_line_rec.TP_ATTRIBUTE5
              ,p_line_rec.TP_ATTRIBUTE6
              ,p_line_rec.TP_ATTRIBUTE7
              ,p_line_rec.TP_ATTRIBUTE8
              ,p_line_rec.TP_ATTRIBUTE9
              ,p_line_rec.TP_ATTRIBUTE10
              ,p_line_rec.TP_ATTRIBUTE11
              ,p_line_rec.TP_ATTRIBUTE12
              ,p_line_rec.TP_ATTRIBUTE13
              ,p_line_rec.TP_ATTRIBUTE14
              ,p_line_rec.TP_ATTRIBUTE15
              --,p_line_rec.FLOW_STATUS_CODE
              --,p_line_rec.MARKETING_SOURCE_CODE_ID
              ,p_line_rec.CALCULATE_PRICE_FLAG
              ,p_line_rec.COMMITMENT_ID
              ,p_line_rec.ORDER_SOURCE_ID
              --,p_line_rec.upgraded_flag
              ,p_line_rec.LOCK_CONTROL
              ,p_line_rec.WF_PROCESS_NAME
              ,p_line_rec.II_START_INDEX
              ,p_line_rec.II_COUNT
              ,p_line_rec.user_item_description
              ,p_line_rec.parent_line_index
              ,p_line_rec.firm_demand_flag
              -- end customer
       				,p_line_rec.End_customer_contact_id
       				,p_line_rec.End_customer_id
       				,p_line_rec.End_customer_site_use_id
       				,p_line_rec.IB_owner
       				,p_line_rec.IB_current_location
       				,p_line_rec.IB_Installed_at_Location
              ,p_line_rec.cust_trx_type_id
              ,p_line_rec.tax_calculation_flag
              ,p_line_rec.ato_line_index
              ,p_line_rec.top_model_line_index
              ;
     END IF; -- p_process_configuration
   END IF;

   if (p_line_rec.line_index.count < p_line_rec.line_id.count)
   then
      p_line_rec.line_index.extend(p_line_rec.line_id.count - p_line_rec.line_index.count);
   end if;

   if (p_line_rec.header_index.count < p_line_rec.line_id.count)
   then
      p_line_rec.header_index.extend(p_line_rec.line_id.count - p_line_rec.header_index.count);
   end if;
   oe_debug_pub.add('after bulk collect');
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , LOAD_LINES' ) ;
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Load_Lines'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Load_Lines;


---------------------------------------------------------------------
-- PROCEDURE Insert_Lines
--
-- BULK Inserts order lines into the OM tables from p_line_rec
---------------------------------------------------------------------

PROCEDURE Insert_Lines
(p_line_rec IN OE_WSH_BULK_GRP.LINE_REC_TYPE)
IS
ctr NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

ctr := p_line_rec.line_id.count;

FORALL i IN 1..ctr
     INSERT INTO OE_ORDER_LINES
       (ACCOUNTING_RULE_ID
       ,ACCOUNTING_RULE_DURATION
       ,ACTUAL_ARRIVAL_DATE
       -- ,ACTUAL_SHIPMENT_DATE
       ,AGREEMENT_ID
       ,ARRIVAL_SET_ID
       ,ATO_LINE_ID
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
       -- ,AUTO_SELECTED_QUANTITY
       ,AUTHORIZED_TO_SHIP_FLAG
       ,BOOKED_FLAG
       ,CANCELLED_FLAG
       ,CANCELLED_QUANTITY
       ,COMPONENT_CODE
       ,COMPONENT_NUMBER
       ,COMPONENT_SEQUENCE_ID
        ,CONFIG_HEADER_ID
        ,CONFIG_REV_NBR
        ,CONFIG_DISPLAY_SEQUENCE
        ,CONFIGURATION_ID
       ,CONTEXT
       ,CREATED_BY
       ,CREATION_DATE
       ,CREDIT_INVOICE_LINE_ID
       ,CUSTOMER_DOCK_CODE
       ,CUSTOMER_JOB
       ,CUSTOMER_PRODUCTION_LINE
       ,CUST_PRODUCTION_SEQ_NUM
       -- ,CUSTOMER_TRX_LINE_ID
       ,CUST_MODEL_SERIAL_NUMBER
       ,CUST_PO_NUMBER
       ,CUSTOMER_LINE_NUMBER
       ,DELIVERY_LEAD_TIME
       ,DELIVER_TO_CONTACT_ID
       ,DELIVER_TO_ORG_ID
       ,DEMAND_BUCKET_TYPE_CODE
       ,DEMAND_CLASS_CODE
       -- ,DEP_PLAN_REQUIRED_FLAG
       ,EARLIEST_ACCEPTABLE_DATE
       ,END_ITEM_UNIT_NUMBER
       ,EXPLOSION_DATE
       -- ,FIRST_ACK_CODE
       -- ,FIRST_ACK_DATE
       ,FOB_POINT_CODE
       ,FREIGHT_CARRIER_CODE
       ,FREIGHT_TERMS_CODE
       -- ,FULFILLED_QUANTITY
       -- ,FULFILLED_FLAG
       -- ,FULFILLMENT_METHOD_CODE
       -- ,FULFILLMENT_DATE
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
       ,INDUSTRY_ATTRIBUTE1
       ,INDUSTRY_ATTRIBUTE10
       ,INDUSTRY_ATTRIBUTE11
       ,INDUSTRY_ATTRIBUTE12
       ,INDUSTRY_ATTRIBUTE13
       ,INDUSTRY_ATTRIBUTE14
       ,INDUSTRY_ATTRIBUTE15
       ,INDUSTRY_ATTRIBUTE16
       ,INDUSTRY_ATTRIBUTE17
       ,INDUSTRY_ATTRIBUTE18
       ,INDUSTRY_ATTRIBUTE19
       ,INDUSTRY_ATTRIBUTE20
       ,INDUSTRY_ATTRIBUTE21
       ,INDUSTRY_ATTRIBUTE22
       ,INDUSTRY_ATTRIBUTE23
       ,INDUSTRY_ATTRIBUTE24
       ,INDUSTRY_ATTRIBUTE25
       ,INDUSTRY_ATTRIBUTE26
       ,INDUSTRY_ATTRIBUTE27
       ,INDUSTRY_ATTRIBUTE28
       ,INDUSTRY_ATTRIBUTE29
       ,INDUSTRY_ATTRIBUTE30
       ,INDUSTRY_ATTRIBUTE2
       ,INDUSTRY_ATTRIBUTE3
       ,INDUSTRY_ATTRIBUTE4
       ,INDUSTRY_ATTRIBUTE5
       ,INDUSTRY_ATTRIBUTE6
       ,INDUSTRY_ATTRIBUTE7
       ,INDUSTRY_ATTRIBUTE8
       ,INDUSTRY_ATTRIBUTE9
       ,INDUSTRY_CONTEXT
       -- ,INTERMED_SHIP_TO_CONTACT_ID
       -- ,INTERMED_SHIP_TO_ORG_ID
       ,INVENTORY_ITEM_ID
       -- ,INVOICE_INTERFACE_STATUS_CODE
       ,INVOICE_TO_CONTACT_ID
       ,INVOICE_TO_ORG_ID
       -- ,INVOICED_QUANTITY
       ,INVOICING_RULE_ID
       ,ORDERED_ITEM_ID
       ,ITEM_IDENTIFIER_TYPE
       ,ORDERED_ITEM
       ,CUSTOMER_ITEM_NET_PRICE
       ,ITEM_REVISION
       ,ITEM_TYPE_CODE
       -- ,LAST_ACK_CODE
       -- ,LAST_ACK_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_DATE
       -- ,LAST_UPDATE_LOGIN
       ,LATEST_ACCEPTABLE_DATE
       ,LINE_CATEGORY_CODE
       ,LINE_ID
       ,LINE_NUMBER
       ,LINE_TYPE_ID
       ,LINK_TO_LINE_ID
       ,MODEL_GROUP_NUMBER
       ,MFG_LEAD_TIME
       ,OPEN_FLAG
       ,OPTION_FLAG
       ,OPTION_NUMBER
       ,ORDERED_QUANTITY
       ,ORDERED_QUANTITY2              --OPM 02/JUN/00
       ,ORDER_QUANTITY_UOM
       ,ORDERED_QUANTITY_UOM2          --OPM 02/JUN/00
       ,ORG_ID                         --moac
       ,ORIG_SYS_DOCUMENT_REF
       ,ORIG_SYS_LINE_REF
       ,ORIG_SYS_SHIPMENT_REF
       ,CHANGE_SEQUENCE
       ,OVER_SHIP_REASON_CODE
       ,OVER_SHIP_RESOLVED_FLAG
       ,PAYMENT_TERM_ID
       -- ,PLANNING_PRIORITY
       ,PREFERRED_GRADE                --OPM HVOP
       ,PRICE_LIST_ID
       -- ,PRICE_REQUEST_CODE             --PROMOTIONS MAY/01
       ,PRICING_ATTRIBUTE1
       ,PRICING_ATTRIBUTE10
       ,PRICING_ATTRIBUTE2
       ,PRICING_ATTRIBUTE3
       ,PRICING_ATTRIBUTE4
       ,PRICING_ATTRIBUTE5
       ,PRICING_ATTRIBUTE6
       ,PRICING_ATTRIBUTE7
       ,PRICING_ATTRIBUTE8
       ,PRICING_ATTRIBUTE9
       ,PRICING_CONTEXT
       ,PRICING_DATE
       ,PRICING_QUANTITY
       ,PRICING_QUANTITY_UOM
       -- ,PROGRAM_APPLICATION_ID
       -- ,PROGRAM_ID
       -- ,PROGRAM_UPDATE_DATE
       ,PROJECT_ID
       ,PROMISE_DATE
       ,RE_SOURCE_FLAG
       -- ,REFERENCE_CUSTOMER_TRX_LINE_ID
       ,REFERENCE_HEADER_ID
       ,REFERENCE_LINE_ID
       ,REFERENCE_TYPE
       ,REQUEST_DATE
       ,REQUEST_ID
       ,RETURN_ATTRIBUTE1
       ,RETURN_ATTRIBUTE10
       ,RETURN_ATTRIBUTE11
       ,RETURN_ATTRIBUTE12
       ,RETURN_ATTRIBUTE13
       ,RETURN_ATTRIBUTE14
       ,RETURN_ATTRIBUTE15
       ,RETURN_ATTRIBUTE2
       ,RETURN_ATTRIBUTE3
       ,RETURN_ATTRIBUTE4
       ,RETURN_ATTRIBUTE5
       ,RETURN_ATTRIBUTE6
       ,RETURN_ATTRIBUTE7
       ,RETURN_ATTRIBUTE8
       ,RETURN_ATTRIBUTE9
       ,RETURN_CONTEXT
       ,RETURN_REASON_CODE
       -- ,RLA_SCHEDULE_TYPE_CODE
       ,SALESREP_ID
       ,SCHEDULE_ARRIVAL_DATE
       ,SCHEDULE_SHIP_DATE
       ,SCHEDULE_STATUS_CODE
       ,SHIPMENT_NUMBER
       ,SHIPMENT_PRIORITY_CODE
       ,SHIPPED_QUANTITY
       ,SHIPPED_QUANTITY2 -- OPM B1661023 04/02/01
       ,SHIPPING_METHOD_CODE
       ,SHIPPING_QUANTITY
       ,SHIPPING_QUANTITY2 -- OPM B1661023 04/02/01
       ,SHIPPING_QUANTITY_UOM
       ,SHIP_FROM_ORG_ID
       ,SUBINVENTORY
       ,SHIP_SET_ID
       ,SHIP_TOLERANCE_ABOVE
       ,SHIP_TOLERANCE_BELOW
       ,SHIPPABLE_FLAG
       ,SHIPPING_INTERFACED_FLAG
       ,SHIP_TO_CONTACT_ID
       ,SHIP_TO_ORG_ID
       ,SHIP_MODEL_COMPLETE_FLAG
       ,SOLD_TO_ORG_ID
       ,SOLD_FROM_ORG_ID
       ,SORT_ORDER
       ,SOURCE_DOCUMENT_ID
       -- ,SOURCE_DOCUMENT_LINE_ID
       -- ,SOURCE_DOCUMENT_TYPE_ID
       ,SOURCE_TYPE_CODE
       ,SPLIT_FROM_LINE_ID
       -- ,LINE_SET_ID
       -- ,SPLIT_BY
        ,MODEL_REMNANT_FLAG
       ,TASK_ID
       ,TAX_CODE
       ,TAX_DATE
       ,TAX_EXEMPT_FLAG
       ,TAX_EXEMPT_NUMBER
       ,TAX_EXEMPT_REASON_CODE
       ,TAX_POINT_CODE
       -- ,TAX_RATE
       ,TAX_VALUE
       ,TOP_MODEL_LINE_ID
       ,UNIT_LIST_PRICE
       ,UNIT_LIST_PRICE_PER_PQTY
       ,UNIT_SELLING_PRICE
       ,UNIT_SELLING_PRICE_PER_PQTY
       ,VISIBLE_DEMAND_FLAG
       ,VEH_CUS_ITEM_CUM_KEY_ID
       ,SHIPPING_INSTRUCTIONS
       ,PACKING_INSTRUCTIONS
       ,SERVICE_TXN_REASON_CODE
       ,SERVICE_TXN_COMMENTS
       ,SERVICE_DURATION
       ,SERVICE_PERIOD
       ,SERVICE_START_DATE
       ,SERVICE_END_DATE
       ,SERVICE_COTERMINATE_FLAG
       ,UNIT_LIST_PERCENT
       ,UNIT_SELLING_PERCENT
       ,UNIT_PERCENT_BASE_PRICE
       ,SERVICE_NUMBER
       ,SERVICE_REFERENCE_TYPE_CODE
       -- ,SERVICE_REFERENCE_LINE_ID
       -- ,SERVICE_REFERENCE_SYSTEM_ID
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
       ,FLOW_STATUS_CODE
       -- ,MARKETING_SOURCE_CODE_ID
       ,CALCULATE_PRICE_FLAG
       ,COMMITMENT_ID
       ,ORDER_SOURCE_ID
       -- ,upgraded_flag
       ,user_item_description
       ,LOCK_CONTROL
       ,FIRM_DEMAND_FLAG
       -- QUOTING change
       ,transaction_phase_code
       -- end customer (Bug 5054618)
        ,End_customer_contact_id
	,End_customer_id
	,End_customer_site_use_id
	,IB_owner
        ,IB_current_location
	,IB_Installed_at_Location
       )
     VALUES
       (p_line_rec.ACCOUNTING_RULE_ID(i)
       ,p_line_rec.ACCOUNTING_RULE_DURATION(i)
       ,p_line_rec.ACTUAL_ARRIVAL_DATE(i)
       --,p_line_rec.ACTUAL_SHIPMENT_DATE(i)
       ,p_line_rec.AGREEMENT_ID(i)
       ,p_line_rec.ARRIVAL_SET_ID(i)
       ,p_line_rec.ATO_LINE_ID(i)
       ,p_line_rec.ATTRIBUTE1(i)
       ,p_line_rec.ATTRIBUTE10(i)
       ,p_line_rec.ATTRIBUTE11(i)
       ,p_line_rec.ATTRIBUTE12(i)
       ,p_line_rec.ATTRIBUTE13(i)
       ,p_line_rec.ATTRIBUTE14(i)
       ,p_line_rec.ATTRIBUTE15(i)
       ,p_line_rec.ATTRIBUTE16(i)   --For bug 2184255
       ,p_line_rec.ATTRIBUTE17(i)
       ,p_line_rec.ATTRIBUTE18(i)
       ,p_line_rec.ATTRIBUTE19(i)
       ,p_line_rec.ATTRIBUTE2(i)
       ,p_line_rec.ATTRIBUTE20(i)
       ,p_line_rec.ATTRIBUTE3(i)
       ,p_line_rec.ATTRIBUTE4(i)
       ,p_line_rec.ATTRIBUTE5(i)
       ,p_line_rec.ATTRIBUTE6(i)
       ,p_line_rec.ATTRIBUTE7(i)
       ,p_line_rec.ATTRIBUTE8(i)
       ,p_line_rec.ATTRIBUTE9(i)
       --,p_line_rec.AUTO_SELECTED_QUANTITY(i)
       ,p_line_rec.AUTHORIZED_TO_SHIP_FLAG(i)
       ,p_line_rec.BOOKED_FLAG (i)
       ,p_line_rec.CANCELLED_FLAG(i)
       ,p_line_rec.CANCELLED_QUANTITY(i)
       ,p_line_rec.COMPONENT_CODE(i)
       ,p_line_rec.COMPONENT_NUMBER(i)
       ,p_line_rec.COMPONENT_SEQUENCE_ID(i)
       ,p_line_rec.CONFIG_HEADER_ID(i)
       ,p_line_rec.CONFIG_REV_NBR(i)
       ,p_line_rec.CONFIG_DISPLAY_SEQUENCE(i)
       ,p_line_rec.CONFIGURATION_ID(i)
       ,p_line_rec.CONTEXT(i)
       ,FND_GLOBAL.USER_ID           -- p_line_rec.CREATED_BY(i)
       ,sysdate                      -- p_line_rec.CREATION_DATE(i)
       ,p_line_rec.CREDIT_INVOICE_LINE_ID(i)
       ,p_line_rec.CUSTOMER_DOCK_CODE(i)
       ,p_line_rec.CUSTOMER_JOB(i)
       ,p_line_rec.CUSTOMER_PRODUCTION_LINE(i)
       ,p_line_rec.CUST_PRODUCTION_SEQ_NUM(i)
       --,p_line_rec.CUSTOMER_TRX_LINE_ID(i)
       ,p_line_rec.CUST_MODEL_SERIAL_NUMBER(i)
       ,p_line_rec.CUST_PO_NUMBER(i)
       ,p_line_rec.CUSTOMER_LINE_NUMBER(i)
       ,p_line_rec.DELIVERY_LEAD_TIME(i)
       ,p_line_rec.DELIVER_TO_CONTACT_ID(i)
       ,p_line_rec.DELIVER_TO_ORG_ID(i)
       ,p_line_rec.DEMAND_BUCKET_TYPE_CODE(i)
       ,p_line_rec.DEMAND_CLASS_CODE(i)
       --,p_line_rec.DEP_PLAN_REQUIRED_FLAG(i)
       ,p_line_rec.EARLIEST_ACCEPTABLE_DATE(i)
       ,p_line_rec.END_ITEM_UNIT_NUMBER(i)
       ,p_line_rec.EXPLOSION_DATE(i)
       --,p_line_rec.FIRST_ACK_CODE(i)
       --,p_line_rec.FIRST_ACK_DATE(i)
       ,p_line_rec.FOB_POINT_CODE(i)
       ,p_line_rec.FREIGHT_CARRIER_CODE(i)
       ,p_line_rec.FREIGHT_TERMS_CODE(i)
       --,p_line_rec.FULFILLED_QUANTITY(i)
       --,p_line_rec.FULFILLED_FLAG(i)
       --,p_line_rec.FULFILLMENT_METHOD_CODE(i)
       --,p_line_rec.FULFILLMENT_DATE(i)
       ,p_line_rec.GLOBAL_ATTRIBUTE1(i)
       ,p_line_rec.GLOBAL_ATTRIBUTE10(i)
       ,p_line_rec.GLOBAL_ATTRIBUTE11(i)
       ,p_line_rec.GLOBAL_ATTRIBUTE12(i)
       ,p_line_rec.GLOBAL_ATTRIBUTE13(i)
       ,p_line_rec.GLOBAL_ATTRIBUTE14(i)
       ,p_line_rec.GLOBAL_ATTRIBUTE15(i)
       ,p_line_rec.GLOBAL_ATTRIBUTE16(i)
       ,p_line_rec.GLOBAL_ATTRIBUTE17(i)
       ,p_line_rec.GLOBAL_ATTRIBUTE18(i)
       ,p_line_rec.GLOBAL_ATTRIBUTE19(i)
       ,p_line_rec.GLOBAL_ATTRIBUTE2(i)
       ,p_line_rec.GLOBAL_ATTRIBUTE20(i)
       ,p_line_rec.GLOBAL_ATTRIBUTE3(i)
       ,p_line_rec.GLOBAL_ATTRIBUTE4(i)
       ,p_line_rec.GLOBAL_ATTRIBUTE5(i)
       ,p_line_rec.GLOBAL_ATTRIBUTE6(i)
       ,p_line_rec.GLOBAL_ATTRIBUTE7(i)
       ,p_line_rec.GLOBAL_ATTRIBUTE8(i)
       ,p_line_rec.GLOBAL_ATTRIBUTE9(i)
       ,p_line_rec.GLOBAL_ATTRIBUTE_CATEGORY(i)
       ,p_line_rec.HEADER_ID(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE1(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE10(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE11(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE12(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE13(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE14(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE15(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE16(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE17(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE18(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE19(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE20(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE21(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE22(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE23(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE24(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE25(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE26(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE27(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE28(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE29(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE30(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE2(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE3(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE4(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE5(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE6(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE7(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE8(i)
       ,p_line_rec.INDUSTRY_ATTRIBUTE9(i)
       ,p_line_rec.INDUSTRY_CONTEXT(i)
       --,p_line_rec.INTERMED_SHIP_TO_CONTACT_ID(i)
       --,p_line_rec.INTERMED_SHIP_TO_ORG_ID(i)
       ,p_line_rec.INVENTORY_ITEM_ID(i)
       --,p_line_rec.INVOICE_INTERFACE_STATUS_CODE(i)
       ,p_line_rec.INVOICE_TO_CONTACT_ID(i)
       ,p_line_rec.INVOICE_TO_ORG_ID(i)
       --,p_line_rec.INVOICED_QUANTITY(i)
       ,p_line_rec.INVOICING_RULE_ID(i)
       ,p_line_rec.ORDERED_ITEM_ID(i)
       ,p_line_rec.ITEM_IDENTIFIER_TYPE(i)
       ,p_line_rec.ORDERED_ITEM(i)
       ,p_line_rec.CUSTOMER_ITEM_NET_PRICE(i)
       ,p_line_rec.ITEM_REVISION(i)
       ,p_line_rec.ITEM_TYPE_CODE(i)
       --,p_line_rec.LAST_ACK_CODE(i)
       --,p_line_rec.LAST_ACK_DATE(i)
       ,FND_GLOBAL.USER_ID              -- p_line_rec.LAST_UPDATED_BY(i)
       ,sysdate                         -- p_line_rec.LAST_UPDATE_DATE(i)
       --,p_line_rec.LAST_UPDATE_LOGIN(i)
       ,p_line_rec.LATEST_ACCEPTABLE_DATE(i)
       ,p_line_rec.LINE_CATEGORY_CODE(i)
       ,p_line_rec.LINE_ID(i)
       ,p_line_rec.LINE_NUMBER(i)
       ,p_line_rec.LINE_TYPE_ID(i)
       ,p_line_rec.LINK_TO_LINE_ID(i)
       ,p_line_rec.MODEL_GROUP_NUMBER(i)
       ,p_line_rec.MFG_LEAD_TIME(i)
       ,'Y'                         -- p_line_rec.OPEN_FLAG(i)
       ,p_line_rec.OPTION_FLAG(i)
       ,p_line_rec.OPTION_NUMBER(i)
       ,p_line_rec.ORDERED_QUANTITY(i)
       ,p_line_rec.ORDERED_QUANTITY2(i)           --OPM 02/JUN/00
       ,p_line_rec.ORDER_QUANTITY_UOM(i)
       ,p_line_rec.ORDERED_QUANTITY_UOM2(i)       --OPM 02/JUN/00
       ,p_line_rec.ORG_ID(i)                      --moac
       ,p_line_rec.ORIG_SYS_DOCUMENT_REF(i)
       ,p_line_rec.ORIG_SYS_LINE_REF(i)
       ,p_line_rec.ORIG_SYS_SHIPMENT_REF(i)
       ,p_line_rec.CHANGE_SEQUENCE(i)
       ,p_line_rec.OVER_SHIP_REASON_CODE(i)
       ,p_line_rec.OVER_SHIP_RESOLVED_FLAG(i)
       ,p_line_rec.PAYMENT_TERM_ID(i)
       --,p_line_rec.PLANNING_PRIORITY(i)
       ,p_line_rec.PREFERRED_GRADE(i)          --OPM HVOP
       ,p_line_rec.PRICE_LIST_ID(i)
       --,p_line_rec.PRICE_REQUEST_CODE(i)       --PROMOTIONS MAY/01
       ,p_line_rec.PRICING_ATTRIBUTE1(i)
       ,p_line_rec.PRICING_ATTRIBUTE10(i)
       ,p_line_rec.PRICING_ATTRIBUTE2(i)
       ,p_line_rec.PRICING_ATTRIBUTE3(i)
       ,p_line_rec.PRICING_ATTRIBUTE4(i)
       ,p_line_rec.PRICING_ATTRIBUTE5(i)
       ,p_line_rec.PRICING_ATTRIBUTE6(i)
       ,p_line_rec.PRICING_ATTRIBUTE7(i)
       ,p_line_rec.PRICING_ATTRIBUTE8(i)
       ,p_line_rec.PRICING_ATTRIBUTE9(i)
       ,p_line_rec.PRICING_CONTEXT(i)
       ,p_line_rec.PRICING_DATE(i)
       ,p_line_rec.PRICING_QUANTITY(i)
       ,p_line_rec.PRICING_QUANTITY_UOM(i)
       --,p_line_rec.PROGRAM_APPLICATION_ID(i)
       --,p_line_rec.PROGRAM_ID(i)
       --,p_line_rec.PROGRAM_UPDATE_DATE(i)
       ,p_line_rec.PROJECT_ID(i)
       ,p_line_rec.PROMISE_DATE(i)
       ,p_line_rec.RE_SOURCE_FLAG(i)
       --,p_line_rec.REFERENCE_CUSTOMER_TRX_LINE_ID(i)
       ,p_line_rec.REFERENCE_HEADER_ID(i)
       ,p_line_rec.REFERENCE_LINE_ID(i)
       ,p_line_rec.REFERENCE_TYPE(i)
       ,p_line_rec.REQUEST_DATE(i)
       ,OE_BULK_ORDER_PVT.G_REQUEST_ID
       ,p_line_rec.RETURN_ATTRIBUTE1(i)
       ,p_line_rec.RETURN_ATTRIBUTE10(i)
       ,p_line_rec.RETURN_ATTRIBUTE11(i)
       ,p_line_rec.RETURN_ATTRIBUTE12(i)
       ,p_line_rec.RETURN_ATTRIBUTE13(i)
       ,p_line_rec.RETURN_ATTRIBUTE14(i)
       ,p_line_rec.RETURN_ATTRIBUTE15(i)
       ,p_line_rec.RETURN_ATTRIBUTE2(i)
       ,p_line_rec.RETURN_ATTRIBUTE3(i)
       ,p_line_rec.RETURN_ATTRIBUTE4(i)
       ,p_line_rec.RETURN_ATTRIBUTE5(i)
       ,p_line_rec.RETURN_ATTRIBUTE6(i)
       ,p_line_rec.RETURN_ATTRIBUTE7(i)
       ,p_line_rec.RETURN_ATTRIBUTE8(i)
       ,p_line_rec.RETURN_ATTRIBUTE9(i)
       ,p_line_rec.RETURN_CONTEXT(i)
       ,p_line_rec.RETURN_REASON_CODE(i)
       --,p_line_rec.RLA_SCHEDULE_TYPE_CODE(i)
       ,p_line_rec.SALESREP_ID(i)
       ,p_line_rec.SCHEDULE_ARRIVAL_DATE(i)
       ,p_line_rec.SCHEDULE_SHIP_DATE(i)
       ,p_line_rec.SCHEDULE_STATUS_CODE(i)
       ,1                                   -- p_line_rec.SHIPMENT_NUMBER(i)
       ,p_line_rec.SHIPMENT_PRIORITY_CODE(i)
       ,p_line_rec.SHIPPED_QUANTITY(i)
       ,p_line_rec.SHIPPED_QUANTITY2(i)     -- OPM B1661023 04/02/01
       ,p_line_rec.SHIPPING_METHOD_CODE(i)
       ,p_line_rec.SHIPPING_QUANTITY(i)
       ,p_line_rec.SHIPPING_QUANTITY2(i)    -- OPM B1661023 04/02/01
       ,p_line_rec.SHIPPING_QUANTITY_UOM(i)
       ,p_line_rec.SHIP_FROM_ORG_ID(i)
       ,p_line_rec.SUBINVENTORY(i)
       ,p_line_rec.SHIP_SET_ID(i)
       ,p_line_rec.SHIP_TOLERANCE_ABOVE(i)
       ,p_line_rec.SHIP_TOLERANCE_BELOW(i)
       ,p_line_rec.SHIPPABLE_FLAG(i)
       ,'N'                             -- p_line_rec.SHIPPING_INTERFACED_FLAG(i)
       ,p_line_rec.SHIP_TO_CONTACT_ID(i)
       ,p_line_rec.SHIP_TO_ORG_ID(i)
       ,p_line_rec.SHIP_MODEL_COMPLETE_FLAG(i)
       ,p_line_rec.SOLD_TO_ORG_ID(i)
       ,OE_GLOBALS.G_ORG_ID
       ,p_line_rec.SORT_ORDER(i)
       ,p_line_rec.SOURCE_DOCUMENT_ID(i)
       --,p_line_rec.SOURCE_DOCUMENT_LINE_ID (i)
       --,p_line_rec.SOURCE_DOCUMENT_TYPE_ID(i)
       ,p_line_rec.SOURCE_TYPE_CODE(i)
       ,p_line_rec.SPLIT_FROM_LINE_ID(i)
       --,p_line_rec.LINE_SET_ID(i)
       --,p_line_rec.SPLIT_BY(i)
       ,p_line_rec.MODEL_REMNANT_FLAG(i)
       ,p_line_rec.TASK_ID(i)
       ,p_line_rec.TAX_CODE(i)
       ,p_line_rec.TAX_DATE(i)
       ,p_line_rec.TAX_EXEMPT_FLAG(i)
       ,p_line_rec.TAX_EXEMPT_NUMBER(i)
       ,p_line_rec.TAX_EXEMPT_REASON_CODE(i)
       ,p_line_rec.TAX_POINT_CODE(i)
       --,p_line_rec.TAX_RATE(i)
       ,p_line_rec.TAX_VALUE(i)
       ,p_line_rec.TOP_MODEL_LINE_ID(i)
       ,p_line_rec.UNIT_LIST_PRICE(i)
       ,p_line_rec.UNIT_LIST_PRICE_PER_PQTY(i)
       ,p_line_rec.UNIT_SELLING_PRICE(i)
       ,p_line_rec.UNIT_SELLING_PRICE_PER_PQTY(i)
       ,p_line_rec.VISIBLE_DEMAND_FLAG(i)
       ,p_line_rec.VEH_CUS_ITEM_CUM_KEY_ID(i)
       ,p_line_rec.SHIPPING_INSTRUCTIONS(i)
       ,p_line_rec.PACKING_INSTRUCTIONS(i)
       ,p_line_rec.SERVICE_TXN_REASON_CODE(i)
       ,p_line_rec.SERVICE_TXN_COMMENTS(i)
       ,p_line_rec.SERVICE_DURATION(i)
       ,p_line_rec.SERVICE_PERIOD(i)
       ,p_line_rec.SERVICE_START_DATE(i)
       ,p_line_rec.SERVICE_END_DATE(i)
       ,p_line_rec.SERVICE_COTERMINATE_FLAG(i)
       ,p_line_rec.UNIT_LIST_PERCENT(i)
       ,p_line_rec.UNIT_SELLING_PERCENT(i)
       ,p_line_rec.UNIT_PERCENT_BASE_PRICE(i)
       ,p_line_rec.SERVICE_NUMBER(i)
       ,p_line_rec.SERVICE_REFERENCE_TYPE_CODE(i)
       --,p_line_rec.SERVICE_REFERENCE_LINE_ID(i)
       --,p_line_rec.SERVICE_REFERENCE_SYSTEM_ID(i)
       ,p_line_rec.TP_CONTEXT(i)
       ,p_line_rec.TP_ATTRIBUTE1(i)
       ,p_line_rec.TP_ATTRIBUTE2(i)
       ,p_line_rec.TP_ATTRIBUTE3(i)
       ,p_line_rec.TP_ATTRIBUTE4(i)
       ,p_line_rec.TP_ATTRIBUTE5(i)
       ,p_line_rec.TP_ATTRIBUTE6(i)
       ,p_line_rec.TP_ATTRIBUTE7(i)
       ,p_line_rec.TP_ATTRIBUTE8(i)
       ,p_line_rec.TP_ATTRIBUTE9(i)
       ,p_line_rec.TP_ATTRIBUTE10(i)
       ,p_line_rec.TP_ATTRIBUTE11(i)
       ,p_line_rec.TP_ATTRIBUTE12(i)
       ,p_line_rec.TP_ATTRIBUTE13(i)
       ,p_line_rec.TP_ATTRIBUTE14(i)
       ,p_line_rec.TP_ATTRIBUTE15(i)
       ,decode(p_line_rec.booked_flag(i)
               ,'Y','BOOKED','ENTERED') --,p_line_rec.FLOW_STATUS_CODE(i)
       --,p_line_rec.MARKETING_SOURCE_CODE_ID(i)
       ,p_line_rec.CALCULATE_PRICE_FLAG(i)
       ,p_line_rec.COMMITMENT_ID(i)
       ,p_line_rec.ORDER_SOURCE_ID(i)
       --,p_line_rec.upgraded_flag(i)
       ,p_line_rec.user_item_description(i)
       ,p_line_rec.LOCK_CONTROL(i)
       ,p_line_rec.FIRM_DEMAND_FLAG(i)
       -- QUOTING change
       -- Negotiation orders not supported with HVOP
       -- insert fulfillment (F) for transaction phase
       ,'F'
       -- end customer (Bug 5054618)
				,p_line_rec.End_customer_contact_id(i)
				,p_line_rec.End_customer_id(i)
				,p_line_rec.End_customer_site_use_id(i)
				,p_line_rec.IB_owner(i)
				,p_line_rec.IB_current_location(i)
				,p_line_rec.IB_Installed_at_Location(i)
       );

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , INSERT_LINES' ) ;
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Insert_Lines'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Insert_Lines;


PROCEDURE Extend_Line_Rec
        (p_count               IN NUMBER
        ,p_line_rec            IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
        )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  p_line_rec.ACCOUNTING_RULE_ID.extend(p_count);
  p_line_rec.ACCOUNTING_RULE_DURATION.extend(p_count);
  p_line_rec.ACTUAL_ARRIVAL_DATE.extend(p_count);
  --p_line_rec.ACTUAL_SHIPMENT_DATE.extend(p_count);
  p_line_rec.AGREEMENT_ID.extend(p_count);
  p_line_rec.ARRIVAL_SET_ID.extend(p_count);
  p_line_rec.ATO_LINE_ID.extend(p_count);
  p_line_rec.ATTRIBUTE1.extend(p_count);
  p_line_rec.ATTRIBUTE10.extend(p_count);
  p_line_rec.ATTRIBUTE11.extend(p_count);
  p_line_rec.ATTRIBUTE12.extend(p_count);
  p_line_rec.ATTRIBUTE13.extend(p_count);
  p_line_rec.ATTRIBUTE14.extend(p_count);
  p_line_rec.ATTRIBUTE15.extend(p_count);
  p_line_rec.ATTRIBUTE16.extend(p_count);   --For bug 2184255
  p_line_rec.ATTRIBUTE17.extend(p_count);
  p_line_rec.ATTRIBUTE18.extend(p_count);
  p_line_rec.ATTRIBUTE19.extend(p_count);
  p_line_rec.ATTRIBUTE2.extend(p_count);
  p_line_rec.ATTRIBUTE20.extend(p_count);
  p_line_rec.ATTRIBUTE3.extend(p_count);
  p_line_rec.ATTRIBUTE4.extend(p_count);
  p_line_rec.ATTRIBUTE5.extend(p_count);
  p_line_rec.ATTRIBUTE6.extend(p_count);
  p_line_rec.ATTRIBUTE7.extend(p_count);
  p_line_rec.ATTRIBUTE8.extend(p_count);
  p_line_rec.ATTRIBUTE9.extend(p_count);
  --p_line_rec.AUTO_SELECTED_QUANTITY.extend(p_count);
  p_line_rec.AUTHORIZED_TO_SHIP_FLAG.extend(p_count);
  p_line_rec.BOOKED_FLAG .extend(p_count);
  p_line_rec.CANCELLED_FLAG.extend(p_count);
  p_line_rec.CANCELLED_QUANTITY.extend(p_count);
  p_line_rec.COMPONENT_CODE.extend(p_count);
  p_line_rec.COMPONENT_NUMBER.extend(p_count);
  p_line_rec.COMPONENT_SEQUENCE_ID.extend(p_count);
  p_line_rec.CONFIG_HEADER_ID.extend(p_count);
  p_line_rec.CONFIG_REV_NBR.extend(p_count);
  p_line_rec.CONFIG_DISPLAY_SEQUENCE.extend(p_count);
  p_line_rec.CONFIGURATION_ID.extend(p_count);
  p_line_rec.CONTEXT.extend(p_count);
  --p_line_rec.CREATED_BY.extend(p_count);
  --p_line_rec.CREATION_DATE.extend(p_count);
  p_line_rec.CREDIT_INVOICE_LINE_ID.extend(p_count);
  p_line_rec.CUSTOMER_DOCK_CODE.extend(p_count);
  p_line_rec.CUSTOMER_JOB.extend(p_count);
  p_line_rec.CUSTOMER_PRODUCTION_LINE.extend(p_count);
  p_line_rec.CUST_PRODUCTION_SEQ_NUM.extend(p_count);
  --p_line_rec.CUSTOMER_TRX_LINE_ID.extend(p_count);
  p_line_rec.CUST_MODEL_SERIAL_NUMBER.extend(p_count);
  p_line_rec.CUST_PO_NUMBER.extend(p_count);
  p_line_rec.CUSTOMER_LINE_NUMBER.extend(p_count);
  p_line_rec.DELIVERY_LEAD_TIME.extend(p_count);
  p_line_rec.DELIVER_TO_CONTACT_ID.extend(p_count);
  p_line_rec.DELIVER_TO_ORG_ID.extend(p_count);
  p_line_rec.DEMAND_BUCKET_TYPE_CODE.extend(p_count);
  p_line_rec.DEMAND_CLASS_CODE.extend(p_count);
  --p_line_rec.DEP_PLAN_REQUIRED_FLAG.extend(p_count);
  p_line_rec.EARLIEST_ACCEPTABLE_DATE.extend(p_count);
  p_line_rec.END_ITEM_UNIT_NUMBER.extend(p_count);
  p_line_rec.EXPLOSION_DATE.extend(p_count);
  --p_line_rec.FIRST_ACK_CODE.extend(p_count);
  --p_line_rec.FIRST_ACK_DATE.extend(p_count);
  p_line_rec.FOB_POINT_CODE.extend(p_count);
  p_line_rec.FREIGHT_CARRIER_CODE.extend(p_count);
  p_line_rec.FREIGHT_TERMS_CODE.extend(p_count);
  --p_line_rec.FULFILLED_QUANTITY.extend(p_count);
  --p_line_rec.FULFILLED_FLAG.extend(p_count);
  --p_line_rec.FULFILLMENT_METHOD_CODE.extend(p_count);
  --p_line_rec.FULFILLMENT_DATE.extend(p_count);
  p_line_rec.GLOBAL_ATTRIBUTE1.extend(p_count);
  p_line_rec.GLOBAL_ATTRIBUTE10.extend(p_count);
  p_line_rec.GLOBAL_ATTRIBUTE11.extend(p_count);
  p_line_rec.GLOBAL_ATTRIBUTE12.extend(p_count);
  p_line_rec.GLOBAL_ATTRIBUTE13.extend(p_count);
  p_line_rec.GLOBAL_ATTRIBUTE14.extend(p_count);
  p_line_rec.GLOBAL_ATTRIBUTE15.extend(p_count);
  p_line_rec.GLOBAL_ATTRIBUTE16.extend(p_count);
  p_line_rec.GLOBAL_ATTRIBUTE17.extend(p_count);
  p_line_rec.GLOBAL_ATTRIBUTE18.extend(p_count);
  p_line_rec.GLOBAL_ATTRIBUTE19.extend(p_count);
  p_line_rec.GLOBAL_ATTRIBUTE2.extend(p_count);
  p_line_rec.GLOBAL_ATTRIBUTE20.extend(p_count);
  p_line_rec.GLOBAL_ATTRIBUTE3.extend(p_count);
  p_line_rec.GLOBAL_ATTRIBUTE4.extend(p_count);
  p_line_rec.GLOBAL_ATTRIBUTE5.extend(p_count);
  p_line_rec.GLOBAL_ATTRIBUTE6.extend(p_count);
  p_line_rec.GLOBAL_ATTRIBUTE7.extend(p_count);
  p_line_rec.GLOBAL_ATTRIBUTE8.extend(p_count);
  p_line_rec.GLOBAL_ATTRIBUTE9.extend(p_count);
  p_line_rec.GLOBAL_ATTRIBUTE_CATEGORY.extend(p_count);
  p_line_rec.HEADER_ID.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE1.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE10.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE11.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE12.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE13.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE14.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE15.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE16.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE17.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE18.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE19.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE20.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE21.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE22.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE23.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE24.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE25.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE26.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE27.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE28.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE29.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE30.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE2.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE3.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE4.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE5.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE6.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE7.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE8.extend(p_count);
  p_line_rec.INDUSTRY_ATTRIBUTE9.extend(p_count);
  p_line_rec.INDUSTRY_CONTEXT.extend(p_count);
  --p_line_rec.INTERMED_SHIP_TO_CONTACT_ID.extend(p_count);
  --p_line_rec.INTERMED_SHIP_TO_ORG_ID.extend(p_count);
  p_line_rec.INVENTORY_ITEM_ID.extend(p_count);
  --p_line_rec.INVOICE_INTERFACE_STATUS_CODE.extend(p_count);
  p_line_rec.INVOICE_TO_CONTACT_ID.extend(p_count);
  p_line_rec.INVOICE_TO_ORG_ID.extend(p_count);
  --p_line_rec.INVOICED_QUANTITY.extend(p_count);
  p_line_rec.INVOICING_RULE_ID.extend(p_count);
  p_line_rec.ORDERED_ITEM_ID.extend(p_count);
  p_line_rec.ITEM_IDENTIFIER_TYPE.extend(p_count);
  p_line_rec.ORDERED_ITEM.extend(p_count);
  p_line_rec.CUSTOMER_ITEM_NET_PRICE.extend(p_count);
  p_line_rec.ITEM_REVISION.extend(p_count);
  p_line_rec.ITEM_TYPE_CODE.extend(p_count);
  --p_line_rec.LAST_ACK_CODE.extend(p_count);
  --p_line_rec.LAST_ACK_DATE.extend(p_count);
  --p_line_rec.LAST_UPDATED_BY.extend(p_count);
  --p_line_rec.LAST_UPDATE_DATE.extend(p_count);
  --p_line_rec.LAST_UPDATE_LOGIN.extend(p_count);
  p_line_rec.LATEST_ACCEPTABLE_DATE.extend(p_count);
  p_line_rec.LINE_CATEGORY_CODE.extend(p_count);
  p_line_rec.LINE_ID.extend(p_count);
  p_line_rec.LINE_NUMBER.extend(p_count);
  p_line_rec.LINE_TYPE_ID.extend(p_count);
  p_line_rec.LINK_TO_LINE_ID.extend(p_count);
  p_line_rec.MODEL_GROUP_NUMBER.extend(p_count);
  p_line_rec.MFG_LEAD_TIME.extend(p_count);
  --p_line_rec.OPEN_FLAG.extend(p_count);
  p_line_rec.OPTION_FLAG.extend(p_count);
  p_line_rec.OPTION_NUMBER.extend(p_count);
  p_line_rec.ORDERED_QUANTITY.extend(p_count);
  p_line_rec.ORDERED_QUANTITY2.extend(p_count);
  p_line_rec.ORDER_QUANTITY_UOM.extend(p_count);
  p_line_rec.ORDERED_QUANTITY_UOM2.extend(p_count);
  p_line_rec.ORG_ID.extend(p_count);
  p_line_rec.ORIG_SYS_DOCUMENT_REF.extend(p_count);
  p_line_rec.ORIG_SYS_LINE_REF.extend(p_count);
  p_line_rec.ORIG_SYS_SHIPMENT_REF.extend(p_count);
  p_line_rec.CHANGE_SEQUENCE.extend(p_count);
  p_line_rec.OVER_SHIP_REASON_CODE.extend(p_count);
  p_line_rec.OVER_SHIP_RESOLVED_FLAG.extend(p_count);
  p_line_rec.PAYMENT_TERM_ID.extend(p_count);
  --p_line_rec.PLANNING_PRIORITY.extend(p_count);
  p_line_rec.PREFERRED_GRADE.extend(p_count); -- OPM HVOP
  p_line_rec.PRICE_LIST_ID.extend(p_count);
  --p_line_rec.PRICE_REQUEST_CODE             --PROMOTIONS MAY/01.extend(p_count);
  p_line_rec.PRICING_ATTRIBUTE1.extend(p_count);
  p_line_rec.PRICING_ATTRIBUTE10.extend(p_count);
  p_line_rec.PRICING_ATTRIBUTE2.extend(p_count);
  p_line_rec.PRICING_ATTRIBUTE3.extend(p_count);
  p_line_rec.PRICING_ATTRIBUTE4.extend(p_count);
  p_line_rec.PRICING_ATTRIBUTE5.extend(p_count);
  p_line_rec.PRICING_ATTRIBUTE6.extend(p_count);
  p_line_rec.PRICING_ATTRIBUTE7.extend(p_count);
  p_line_rec.PRICING_ATTRIBUTE8.extend(p_count);
  p_line_rec.PRICING_ATTRIBUTE9.extend(p_count);
  p_line_rec.PRICING_CONTEXT.extend(p_count);
  p_line_rec.PRICING_DATE.extend(p_count);
  p_line_rec.PRICING_QUANTITY.extend(p_count);
  p_line_rec.PRICING_QUANTITY_UOM.extend(p_count);
  --p_line_rec.PROGRAM_APPLICATION_ID.extend(p_count);
  --p_line_rec.PROGRAM_ID.extend(p_count);
  --p_line_rec.PROGRAM_UPDATE_DATE.extend(p_count);
  p_line_rec.PROJECT_ID.extend(p_count);
  p_line_rec.PROMISE_DATE.extend(p_count);
  p_line_rec.RE_SOURCE_FLAG.extend(p_count);
  --p_line_rec.REFERENCE_CUSTOMER_TRX_LINE_ID.extend(p_count);
  p_line_rec.REFERENCE_HEADER_ID.extend(p_count);
  p_line_rec.REFERENCE_LINE_ID.extend(p_count);
  p_line_rec.REFERENCE_TYPE.extend(p_count);
  p_line_rec.REQUEST_DATE.extend(p_count);
  p_line_rec.REQUEST_ID.extend(p_count);
  p_line_rec.RETURN_ATTRIBUTE1.extend(p_count);
  p_line_rec.RETURN_ATTRIBUTE10.extend(p_count);
  p_line_rec.RETURN_ATTRIBUTE11.extend(p_count);
  p_line_rec.RETURN_ATTRIBUTE12.extend(p_count);
  p_line_rec.RETURN_ATTRIBUTE13.extend(p_count);
  p_line_rec.RETURN_ATTRIBUTE14.extend(p_count);
  p_line_rec.RETURN_ATTRIBUTE15.extend(p_count);
  p_line_rec.RETURN_ATTRIBUTE2.extend(p_count);
  p_line_rec.RETURN_ATTRIBUTE3.extend(p_count);
  p_line_rec.RETURN_ATTRIBUTE4.extend(p_count);
  p_line_rec.RETURN_ATTRIBUTE5.extend(p_count);
  p_line_rec.RETURN_ATTRIBUTE6.extend(p_count);
  p_line_rec.RETURN_ATTRIBUTE7.extend(p_count);
  p_line_rec.RETURN_ATTRIBUTE8.extend(p_count);
  p_line_rec.RETURN_ATTRIBUTE9.extend(p_count);
  p_line_rec.RETURN_CONTEXT.extend(p_count);
  p_line_rec.RETURN_REASON_CODE.extend(p_count);
  --p_line_rec.RLA_SCHEDULE_TYPE_CODE.extend(p_count);
  p_line_rec.SALESREP_ID.extend(p_count);
  p_line_rec.SCHEDULE_ARRIVAL_DATE.extend(p_count);
  p_line_rec.SCHEDULE_SHIP_DATE.extend(p_count);
  p_line_rec.SCHEDULE_STATUS_CODE.extend(p_count);
  p_line_rec.SHIPMENT_NUMBER.extend(p_count);
  p_line_rec.SHIPMENT_PRIORITY_CODE.extend(p_count);
  p_line_rec.SHIPPED_QUANTITY.extend(p_count);
  p_line_rec.SHIPPED_QUANTITY2.extend(p_count);
  p_line_rec.SHIPPING_METHOD_CODE.extend(p_count);
  p_line_rec.SHIPPING_QUANTITY.extend(p_count);
  p_line_rec.SHIPPING_QUANTITY2.extend(p_count);
  p_line_rec.SHIPPING_QUANTITY_UOM.extend(p_count);
  p_line_rec.SHIP_FROM_ORG_ID.extend(p_count);
  p_line_rec.SUBINVENTORY.extend(p_count);
  p_line_rec.SHIP_SET_ID.extend(p_count);
  p_line_rec.SHIP_TOLERANCE_ABOVE.extend(p_count);
  p_line_rec.SHIP_TOLERANCE_BELOW.extend(p_count);
  p_line_rec.SHIPPABLE_FLAG.extend(p_count);
  --p_line_rec.SHIPPING_INTERFACED_FLAG.extend(p_count);
  p_line_rec.SHIP_TO_CONTACT_ID.extend(p_count);
  p_line_rec.SHIP_TO_ORG_ID.extend(p_count);
  p_line_rec.SHIP_MODEL_COMPLETE_FLAG.extend(p_count);
  p_line_rec.SOLD_TO_ORG_ID.extend(p_count);
  p_line_rec.SOLD_FROM_ORG_ID.extend(p_count);
  p_line_rec.SORT_ORDER.extend(p_count);
  p_line_rec.SOURCE_DOCUMENT_ID.extend(p_count);
  --p_line_rec.SOURCE_DOCUMENT_LINE_ID .extend(p_count);
  --p_line_rec.SOURCE_DOCUMENT_TYPE_ID.extend(p_count);
  p_line_rec.SOURCE_TYPE_CODE.extend(p_count);
  p_line_rec.SPLIT_FROM_LINE_ID.extend(p_count);
  --p_line_rec.LINE_SET_ID.extend(p_count);
  --p_line_rec.SPLIT_BY.extend(p_count);
  p_line_rec.MODEL_REMNANT_FLAG.extend(p_count);
  p_line_rec.TASK_ID.extend(p_count);
  p_line_rec.TAX_CODE.extend(p_count);
  p_line_rec.TAX_DATE.extend(p_count);
  p_line_rec.TAX_EXEMPT_FLAG.extend(p_count);
  p_line_rec.TAX_EXEMPT_NUMBER.extend(p_count);
  p_line_rec.TAX_EXEMPT_REASON_CODE.extend(p_count);
  p_line_rec.TAX_POINT_CODE.extend(p_count);
  --p_line_rec.TAX_RATE.extend(p_count);
  p_line_rec.TAX_VALUE.extend(p_count);
  p_line_rec.TOP_MODEL_LINE_ID.extend(p_count);
  p_line_rec.UNIT_LIST_PRICE.extend(p_count);
  p_line_rec.UNIT_LIST_PRICE_PER_PQTY.extend(p_count);
  p_line_rec.UNIT_SELLING_PRICE.extend(p_count);
  p_line_rec.UNIT_SELLING_PRICE_PER_PQTY.extend(p_count);
  p_line_rec.VISIBLE_DEMAND_FLAG.extend(p_count);
  p_line_rec.VEH_CUS_ITEM_CUM_KEY_ID.extend(p_count);
  p_line_rec.SHIPPING_INSTRUCTIONS.extend(p_count);
  p_line_rec.PACKING_INSTRUCTIONS.extend(p_count);
  p_line_rec.SERVICE_TXN_REASON_CODE.extend(p_count);
  p_line_rec.SERVICE_TXN_COMMENTS.extend(p_count);
  p_line_rec.SERVICE_DURATION.extend(p_count);
  p_line_rec.SERVICE_PERIOD.extend(p_count);
  p_line_rec.SERVICE_START_DATE.extend(p_count);
  p_line_rec.SERVICE_END_DATE.extend(p_count);
  p_line_rec.SERVICE_COTERMINATE_FLAG.extend(p_count);
  p_line_rec.UNIT_LIST_PERCENT.extend(p_count);
  p_line_rec.UNIT_SELLING_PERCENT.extend(p_count);
  p_line_rec.UNIT_PERCENT_BASE_PRICE.extend(p_count);
  p_line_rec.SERVICE_NUMBER.extend(p_count);
  p_line_rec.SERVICE_REFERENCE_TYPE_CODE.extend(p_count);
  --p_line_rec.SERVICE_REFERENCE_LINE_ID.extend(p_count);
  --p_line_rec.SERVICE_REFERENCE_SYSTEM_ID.extend(p_count);
  p_line_rec.TP_CONTEXT.extend(p_count);
  p_line_rec.TP_ATTRIBUTE1.extend(p_count);
  p_line_rec.TP_ATTRIBUTE2.extend(p_count);
  p_line_rec.TP_ATTRIBUTE3.extend(p_count);
  p_line_rec.TP_ATTRIBUTE4.extend(p_count);
  p_line_rec.TP_ATTRIBUTE5.extend(p_count);
  p_line_rec.TP_ATTRIBUTE6.extend(p_count);
  p_line_rec.TP_ATTRIBUTE7.extend(p_count);
  p_line_rec.TP_ATTRIBUTE8.extend(p_count);
  p_line_rec.TP_ATTRIBUTE9.extend(p_count);
  p_line_rec.TP_ATTRIBUTE10.extend(p_count);
  p_line_rec.TP_ATTRIBUTE11.extend(p_count);
  p_line_rec.TP_ATTRIBUTE12.extend(p_count);
  p_line_rec.TP_ATTRIBUTE13.extend(p_count);
  p_line_rec.TP_ATTRIBUTE14.extend(p_count);
  p_line_rec.TP_ATTRIBUTE15.extend(p_count);
  --p_line_rec.FLOW_STATUS_CODE.extend(p_count);
  --p_line_rec.MARKETING_SOURCE_CODE_ID.extend(p_count);
  p_line_rec.CALCULATE_PRICE_FLAG.extend(p_count);
  p_line_rec.COMMITMENT_ID.extend(p_count);
  p_line_rec.ORDER_SOURCE_ID.extend(p_count);
  --p_line_rec.upgraded_flag.extend(p_count);
  p_line_rec.LOCK_CONTROL.extend(p_count);
  p_line_rec.WF_PROCESS_NAME.extend(p_count);
  p_line_rec.user_item_description.extend(p_count);
  p_line_rec.parent_line_index.extend(p_count);
  p_line_rec.firm_demand_flag.extend(p_count);
  p_line_rec.line_index.extend(p_count);
  p_line_rec.header_index.extend(p_count);

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , EXTEND_LINE_REC' ) ;
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Extend_Line_Rec'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Extend_Line_Rec;

PROCEDURE Extend_Inc_Item_Rec
        (p_count               IN NUMBER
        ,p_parent_index        IN NUMBER
        ,p_line_rec            IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
        )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  p_line_rec.ACCOUNTING_RULE_ID.extend(p_count,p_parent_index);
  p_line_rec.ACCOUNTING_RULE_DURATION.extend(p_count,p_parent_index);
  p_line_rec.ACTUAL_ARRIVAL_DATE.extend(p_count,p_parent_index);
  --p_line_rec.ACTUAL_SHIPMENT_DATE.extend(p_count,p_parent_index);
  p_line_rec.AGREEMENT_ID.extend(p_count,p_parent_index);
  p_line_rec.ARRIVAL_SET_ID.extend(p_count,p_parent_index);
  p_line_rec.ATO_LINE_ID.extend(p_count,p_parent_index);
  p_line_rec.ATTRIBUTE1.extend(p_count,p_parent_index);
  p_line_rec.ATTRIBUTE10.extend(p_count,p_parent_index);
  p_line_rec.ATTRIBUTE11.extend(p_count,p_parent_index);
  p_line_rec.ATTRIBUTE12.extend(p_count,p_parent_index);
  p_line_rec.ATTRIBUTE13.extend(p_count,p_parent_index);
  p_line_rec.ATTRIBUTE14.extend(p_count,p_parent_index);
  p_line_rec.ATTRIBUTE15.extend(p_count,p_parent_index);
  p_line_rec.ATTRIBUTE16.extend(p_count,p_parent_index);   --For bug 2184255
  p_line_rec.ATTRIBUTE17.extend(p_count,p_parent_index);
  p_line_rec.ATTRIBUTE18.extend(p_count,p_parent_index);
  p_line_rec.ATTRIBUTE19.extend(p_count,p_parent_index);
  p_line_rec.ATTRIBUTE2.extend(p_count,p_parent_index);
  p_line_rec.ATTRIBUTE20.extend(p_count,p_parent_index);
  p_line_rec.ATTRIBUTE3.extend(p_count,p_parent_index);
  p_line_rec.ATTRIBUTE4.extend(p_count,p_parent_index);
  p_line_rec.ATTRIBUTE5.extend(p_count,p_parent_index);
  p_line_rec.ATTRIBUTE6.extend(p_count,p_parent_index);
  p_line_rec.ATTRIBUTE7.extend(p_count,p_parent_index);
  p_line_rec.ATTRIBUTE8.extend(p_count,p_parent_index);
  p_line_rec.ATTRIBUTE9.extend(p_count,p_parent_index);
  --p_line_rec.AUTO_SELECTED_QUANTITY.extend(p_count,p_parent_index);
  p_line_rec.AUTHORIZED_TO_SHIP_FLAG.extend(p_count,p_parent_index);
  p_line_rec.BOOKED_FLAG .extend(p_count,p_parent_index);
  p_line_rec.CANCELLED_FLAG.extend(p_count,p_parent_index);
  p_line_rec.CANCELLED_QUANTITY.extend(p_count,p_parent_index);
  p_line_rec.COMPONENT_CODE.extend(p_count,p_parent_index);
  p_line_rec.COMPONENT_NUMBER.extend(p_count,p_parent_index);
  p_line_rec.COMPONENT_SEQUENCE_ID.extend(p_count,p_parent_index);
  p_line_rec.CONFIG_HEADER_ID.extend(p_count,p_parent_index);
  p_line_rec.CONFIG_REV_NBR.extend(p_count,p_parent_index);
  p_line_rec.CONFIG_DISPLAY_SEQUENCE.extend(p_count,p_parent_index);
  p_line_rec.CONFIGURATION_ID.extend(p_count,p_parent_index);
  p_line_rec.CONTEXT.extend(p_count,p_parent_index);
  --p_line_rec.CREATED_BY.extend(p_count,p_parent_index);
  --p_line_rec.CREATION_DATE.extend(p_count,p_parent_index);
  p_line_rec.CREDIT_INVOICE_LINE_ID.extend(p_count,p_parent_index);
  p_line_rec.CUSTOMER_DOCK_CODE.extend(p_count,p_parent_index);
  p_line_rec.CUSTOMER_JOB.extend(p_count,p_parent_index);
  p_line_rec.CUSTOMER_PRODUCTION_LINE.extend(p_count,p_parent_index);
  p_line_rec.CUST_PRODUCTION_SEQ_NUM.extend(p_count,p_parent_index);
  --p_line_rec.CUSTOMER_TRX_LINE_ID.extend(p_count,p_parent_index);
  p_line_rec.CUST_MODEL_SERIAL_NUMBER.extend(p_count,p_parent_index);
  p_line_rec.CUST_PO_NUMBER.extend(p_count,p_parent_index);
  p_line_rec.CUSTOMER_LINE_NUMBER.extend(p_count,p_parent_index);
  p_line_rec.DELIVERY_LEAD_TIME.extend(p_count,p_parent_index);
  p_line_rec.DELIVER_TO_CONTACT_ID.extend(p_count,p_parent_index);
  p_line_rec.DELIVER_TO_ORG_ID.extend(p_count,p_parent_index);
  p_line_rec.DEMAND_BUCKET_TYPE_CODE.extend(p_count,p_parent_index);
  p_line_rec.DEMAND_CLASS_CODE.extend(p_count,p_parent_index);
  --p_line_rec.DEP_PLAN_REQUIRED_FLAG.extend(p_count,p_parent_index);
  p_line_rec.EARLIEST_ACCEPTABLE_DATE.extend(p_count,p_parent_index);
  p_line_rec.END_ITEM_UNIT_NUMBER.extend(p_count,p_parent_index);
  p_line_rec.EXPLOSION_DATE.extend(p_count,p_parent_index);
  --p_line_rec.FIRST_ACK_CODE.extend(p_count,p_parent_index);
  --p_line_rec.FIRST_ACK_DATE.extend(p_count,p_parent_index);
  p_line_rec.FOB_POINT_CODE.extend(p_count,p_parent_index);
  p_line_rec.FREIGHT_CARRIER_CODE.extend(p_count,p_parent_index);
  p_line_rec.FREIGHT_TERMS_CODE.extend(p_count,p_parent_index);
  --p_line_rec.FULFILLED_QUANTITY.extend(p_count,p_parent_index);
  --p_line_rec.FULFILLED_FLAG.extend(p_count,p_parent_index);
  --p_line_rec.FULFILLMENT_METHOD_CODE.extend(p_count,p_parent_index);
  --p_line_rec.FULFILLMENT_DATE.extend(p_count,p_parent_index);
  p_line_rec.GLOBAL_ATTRIBUTE1.extend(p_count,p_parent_index);
  p_line_rec.GLOBAL_ATTRIBUTE10.extend(p_count,p_parent_index);
  p_line_rec.GLOBAL_ATTRIBUTE11.extend(p_count,p_parent_index);
  p_line_rec.GLOBAL_ATTRIBUTE12.extend(p_count,p_parent_index);
  p_line_rec.GLOBAL_ATTRIBUTE13.extend(p_count,p_parent_index);
  p_line_rec.GLOBAL_ATTRIBUTE14.extend(p_count,p_parent_index);
  p_line_rec.GLOBAL_ATTRIBUTE15.extend(p_count,p_parent_index);
  p_line_rec.GLOBAL_ATTRIBUTE16.extend(p_count,p_parent_index);
  p_line_rec.GLOBAL_ATTRIBUTE17.extend(p_count,p_parent_index);
  p_line_rec.GLOBAL_ATTRIBUTE18.extend(p_count,p_parent_index);
  p_line_rec.GLOBAL_ATTRIBUTE19.extend(p_count,p_parent_index);
  p_line_rec.GLOBAL_ATTRIBUTE2.extend(p_count,p_parent_index);
  p_line_rec.GLOBAL_ATTRIBUTE20.extend(p_count,p_parent_index);
  p_line_rec.GLOBAL_ATTRIBUTE3.extend(p_count,p_parent_index);
  p_line_rec.GLOBAL_ATTRIBUTE4.extend(p_count,p_parent_index);
  p_line_rec.GLOBAL_ATTRIBUTE5.extend(p_count,p_parent_index);
  p_line_rec.GLOBAL_ATTRIBUTE6.extend(p_count,p_parent_index);
  p_line_rec.GLOBAL_ATTRIBUTE7.extend(p_count,p_parent_index);
  p_line_rec.GLOBAL_ATTRIBUTE8.extend(p_count,p_parent_index);
  p_line_rec.GLOBAL_ATTRIBUTE9.extend(p_count,p_parent_index);
  p_line_rec.GLOBAL_ATTRIBUTE_CATEGORY.extend(p_count,p_parent_index);
  p_line_rec.HEADER_ID.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE1.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE10.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE11.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE12.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE13.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE14.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE15.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE16.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE17.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE18.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE19.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE20.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE21.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE22.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE23.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE24.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE25.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE26.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE27.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE28.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE29.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE30.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE2.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE3.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE4.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE5.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE6.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE7.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE8.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_ATTRIBUTE9.extend(p_count,p_parent_index);
  p_line_rec.INDUSTRY_CONTEXT.extend(p_count,p_parent_index);
  --p_line_rec.INTERMED_SHIP_TO_CONTACT_ID.extend(p_count,p_parent_index);
  --p_line_rec.INTERMED_SHIP_TO_ORG_ID.extend(p_count,p_parent_index);
  p_line_rec.INVENTORY_ITEM_ID.extend(p_count,p_parent_index);
  --p_line_rec.INVOICE_INTERFACE_STATUS_CODE.extend(p_count,p_parent_index);
  p_line_rec.INVOICE_TO_CONTACT_ID.extend(p_count,p_parent_index);
  p_line_rec.INVOICE_TO_ORG_ID.extend(p_count,p_parent_index);
  --p_line_rec.INVOICED_QUANTITY.extend(p_count,p_parent_index);
  p_line_rec.INVOICING_RULE_ID.extend(p_count,p_parent_index);
  p_line_rec.ORDERED_ITEM_ID.extend(p_count,p_parent_index);
  p_line_rec.ITEM_IDENTIFIER_TYPE.extend(p_count,p_parent_index);
  p_line_rec.ORDERED_ITEM.extend(p_count,p_parent_index);
  p_line_rec.CUSTOMER_ITEM_NET_PRICE.extend(p_count,p_parent_index);
  p_line_rec.ITEM_REVISION.extend(p_count,p_parent_index);
  p_line_rec.ITEM_TYPE_CODE.extend(p_count,p_parent_index);
  --p_line_rec.LAST_ACK_CODE.extend(p_count,p_parent_index);
  --p_line_rec.LAST_ACK_DATE.extend(p_count,p_parent_index);
  --p_line_rec.LAST_UPDATED_BY.extend(p_count,p_parent_index);
  --p_line_rec.LAST_UPDATE_DATE.extend(p_count,p_parent_index);
  --p_line_rec.LAST_UPDATE_LOGIN.extend(p_count,p_parent_index);
  p_line_rec.LATEST_ACCEPTABLE_DATE.extend(p_count,p_parent_index);
  p_line_rec.LINE_CATEGORY_CODE.extend(p_count,p_parent_index);
  p_line_rec.LINE_ID.extend(p_count,p_parent_index);
  p_line_rec.LINE_NUMBER.extend(p_count,p_parent_index);
  p_line_rec.LINE_TYPE_ID.extend(p_count,p_parent_index);
  p_line_rec.LINK_TO_LINE_ID.extend(p_count,p_parent_index);
  p_line_rec.MODEL_GROUP_NUMBER.extend(p_count,p_parent_index);
  p_line_rec.MFG_LEAD_TIME.extend(p_count,p_parent_index);
  --p_line_rec.OPEN_FLAG.extend(p_count,p_parent_index);
  p_line_rec.OPTION_FLAG.extend(p_count,p_parent_index);
  p_line_rec.OPTION_NUMBER.extend(p_count,p_parent_index);
  p_line_rec.ORDERED_QUANTITY.extend(p_count,p_parent_index);
  p_line_rec.ORDERED_QUANTITY2.extend(p_count,p_parent_index);
  p_line_rec.ORDER_QUANTITY_UOM.extend(p_count,p_parent_index);
  p_line_rec.ORDERED_QUANTITY_UOM2.extend(p_count,p_parent_index);
  p_line_rec.ORG_ID.extend(p_count,p_parent_index);
  p_line_rec.ORIG_SYS_DOCUMENT_REF.extend(p_count,p_parent_index);
  p_line_rec.ORIG_SYS_LINE_REF.extend(p_count,p_parent_index);
  p_line_rec.ORIG_SYS_SHIPMENT_REF.extend(p_count,p_parent_index);
  p_line_rec.CHANGE_SEQUENCE.extend(p_count,p_parent_index);
  p_line_rec.OVER_SHIP_REASON_CODE.extend(p_count,p_parent_index);
  p_line_rec.OVER_SHIP_RESOLVED_FLAG.extend(p_count,p_parent_index);
  p_line_rec.PAYMENT_TERM_ID.extend(p_count,p_parent_index);
  --p_line_rec.PLANNING_PRIORITY.extend(p_count,p_parent_index);
  p_line_rec.PREFERRED_GRADE.extend(p_count,p_parent_index); -- OPM HVOP
  p_line_rec.PRICE_LIST_ID.extend(p_count,p_parent_index);
  --p_line_rec.PRICE_REQUEST_CODE             --PROMOTIONS MAY/01.extend(p_count,p_parent_index);
  p_line_rec.PRICING_ATTRIBUTE1.extend(p_count,p_parent_index);
  p_line_rec.PRICING_ATTRIBUTE10.extend(p_count,p_parent_index);
  p_line_rec.PRICING_ATTRIBUTE2.extend(p_count,p_parent_index);
  p_line_rec.PRICING_ATTRIBUTE3.extend(p_count,p_parent_index);
  p_line_rec.PRICING_ATTRIBUTE4.extend(p_count,p_parent_index);
  p_line_rec.PRICING_ATTRIBUTE5.extend(p_count,p_parent_index);
  p_line_rec.PRICING_ATTRIBUTE6.extend(p_count,p_parent_index);
  p_line_rec.PRICING_ATTRIBUTE7.extend(p_count,p_parent_index);
  p_line_rec.PRICING_ATTRIBUTE8.extend(p_count,p_parent_index);
  p_line_rec.PRICING_ATTRIBUTE9.extend(p_count,p_parent_index);
  p_line_rec.PRICING_CONTEXT.extend(p_count,p_parent_index);
  p_line_rec.PRICING_DATE.extend(p_count,p_parent_index);
  p_line_rec.PRICING_QUANTITY.extend(p_count,p_parent_index);
  p_line_rec.PRICING_QUANTITY_UOM.extend(p_count,p_parent_index);
  --p_line_rec.PROGRAM_APPLICATION_ID.extend(p_count,p_parent_index);
  --p_line_rec.PROGRAM_ID.extend(p_count,p_parent_index);
  --p_line_rec.PROGRAM_UPDATE_DATE.extend(p_count,p_parent_index);
  p_line_rec.PROJECT_ID.extend(p_count,p_parent_index);
  p_line_rec.PROMISE_DATE.extend(p_count,p_parent_index);
  p_line_rec.RE_SOURCE_FLAG.extend(p_count,p_parent_index);
  --p_line_rec.REFERENCE_CUSTOMER_TRX_LINE_ID.extend(p_count,p_parent_index);
  p_line_rec.REFERENCE_HEADER_ID.extend(p_count,p_parent_index);
  p_line_rec.REFERENCE_LINE_ID.extend(p_count,p_parent_index);
  p_line_rec.REFERENCE_TYPE.extend(p_count,p_parent_index);
  p_line_rec.REQUEST_DATE.extend(p_count,p_parent_index);
  p_line_rec.REQUEST_ID.extend(p_count,p_parent_index);
  p_line_rec.RETURN_ATTRIBUTE1.extend(p_count,p_parent_index);
  p_line_rec.RETURN_ATTRIBUTE10.extend(p_count,p_parent_index);
  p_line_rec.RETURN_ATTRIBUTE11.extend(p_count,p_parent_index);
  p_line_rec.RETURN_ATTRIBUTE12.extend(p_count,p_parent_index);
  p_line_rec.RETURN_ATTRIBUTE13.extend(p_count,p_parent_index);
  p_line_rec.RETURN_ATTRIBUTE14.extend(p_count,p_parent_index);
  p_line_rec.RETURN_ATTRIBUTE15.extend(p_count,p_parent_index);
  p_line_rec.RETURN_ATTRIBUTE2.extend(p_count,p_parent_index);
  p_line_rec.RETURN_ATTRIBUTE3.extend(p_count,p_parent_index);
  p_line_rec.RETURN_ATTRIBUTE4.extend(p_count,p_parent_index);
  p_line_rec.RETURN_ATTRIBUTE5.extend(p_count,p_parent_index);
  p_line_rec.RETURN_ATTRIBUTE6.extend(p_count,p_parent_index);
  p_line_rec.RETURN_ATTRIBUTE7.extend(p_count,p_parent_index);
  p_line_rec.RETURN_ATTRIBUTE8.extend(p_count,p_parent_index);
  p_line_rec.RETURN_ATTRIBUTE9.extend(p_count,p_parent_index);
  p_line_rec.RETURN_CONTEXT.extend(p_count,p_parent_index);
  p_line_rec.RETURN_REASON_CODE.extend(p_count,p_parent_index);
  --p_line_rec.RLA_SCHEDULE_TYPE_CODE.extend(p_count,p_parent_index);
  p_line_rec.SALESREP_ID.extend(p_count,p_parent_index);
  p_line_rec.SCHEDULE_ARRIVAL_DATE.extend(p_count,p_parent_index);
  p_line_rec.SCHEDULE_SHIP_DATE.extend(p_count,p_parent_index);
  p_line_rec.SCHEDULE_STATUS_CODE.extend(p_count,p_parent_index);
  p_line_rec.SHIPMENT_NUMBER.extend(p_count,p_parent_index);
  p_line_rec.SHIPMENT_PRIORITY_CODE.extend(p_count,p_parent_index);
  p_line_rec.SHIPPED_QUANTITY.extend(p_count,p_parent_index);
  p_line_rec.SHIPPED_QUANTITY2.extend(p_count,p_parent_index);
  p_line_rec.SHIPPING_METHOD_CODE.extend(p_count,p_parent_index);
  p_line_rec.SHIPPING_QUANTITY.extend(p_count,p_parent_index);
  p_line_rec.SHIPPING_QUANTITY2.extend(p_count,p_parent_index);
  p_line_rec.SHIPPING_QUANTITY_UOM.extend(p_count,p_parent_index);
  p_line_rec.SHIP_FROM_ORG_ID.extend(p_count,p_parent_index);
  p_line_rec.SUBINVENTORY.extend(p_count,p_parent_index);
  p_line_rec.SHIP_SET_ID.extend(p_count,p_parent_index);
  p_line_rec.SHIP_TOLERANCE_ABOVE.extend(p_count,p_parent_index);
  p_line_rec.SHIP_TOLERANCE_BELOW.extend(p_count,p_parent_index);
  p_line_rec.SHIPPABLE_FLAG.extend(p_count,p_parent_index);
  --p_line_rec.SHIPPING_INTERFACED_FLAG.extend(p_count,p_parent_index);
  p_line_rec.SHIP_TO_CONTACT_ID.extend(p_count,p_parent_index);
  p_line_rec.SHIP_TO_ORG_ID.extend(p_count,p_parent_index);
  p_line_rec.SHIP_MODEL_COMPLETE_FLAG.extend(p_count,p_parent_index);
  p_line_rec.SOLD_TO_ORG_ID.extend(p_count,p_parent_index);
  p_line_rec.SOLD_FROM_ORG_ID.extend(p_count,p_parent_index);
  p_line_rec.SORT_ORDER.extend(p_count,p_parent_index);
  p_line_rec.SOURCE_DOCUMENT_ID.extend(p_count,p_parent_index);
  --p_line_rec.SOURCE_DOCUMENT_LINE_ID .extend(p_count,p_parent_index);
  --p_line_rec.SOURCE_DOCUMENT_TYPE_ID.extend(p_count,p_parent_index);
  p_line_rec.SOURCE_TYPE_CODE.extend(p_count,p_parent_index);
  p_line_rec.SPLIT_FROM_LINE_ID.extend(p_count,p_parent_index);
  --p_line_rec.LINE_SET_ID.extend(p_count,p_parent_index);
  --p_line_rec.SPLIT_BY.extend(p_count,p_parent_index);
  p_line_rec.MODEL_REMNANT_FLAG.extend(p_count,p_parent_index);
  p_line_rec.TASK_ID.extend(p_count,p_parent_index);
  p_line_rec.TAX_CODE.extend(p_count,p_parent_index);
  p_line_rec.TAX_DATE.extend(p_count,p_parent_index);
  p_line_rec.TAX_EXEMPT_FLAG.extend(p_count,p_parent_index);
  p_line_rec.TAX_EXEMPT_NUMBER.extend(p_count,p_parent_index);
  p_line_rec.TAX_EXEMPT_REASON_CODE.extend(p_count,p_parent_index);
  p_line_rec.TAX_POINT_CODE.extend(p_count,p_parent_index);
  --p_line_rec.TAX_RATE.extend(p_count,p_parent_index);
  p_line_rec.TAX_VALUE.extend(p_count,p_parent_index);
  p_line_rec.TOP_MODEL_LINE_ID.extend(p_count,p_parent_index);
  p_line_rec.UNIT_LIST_PRICE.extend(p_count,p_parent_index);
  p_line_rec.UNIT_LIST_PRICE_PER_PQTY.extend(p_count,p_parent_index);
  p_line_rec.UNIT_SELLING_PRICE.extend(p_count,p_parent_index);
  p_line_rec.UNIT_SELLING_PRICE_PER_PQTY.extend(p_count,p_parent_index);
  p_line_rec.VISIBLE_DEMAND_FLAG.extend(p_count,p_parent_index);
  p_line_rec.VEH_CUS_ITEM_CUM_KEY_ID.extend(p_count,p_parent_index);
  p_line_rec.SHIPPING_INSTRUCTIONS.extend(p_count,p_parent_index);
  p_line_rec.PACKING_INSTRUCTIONS.extend(p_count,p_parent_index);
  p_line_rec.SERVICE_TXN_REASON_CODE.extend(p_count,p_parent_index);
  p_line_rec.SERVICE_TXN_COMMENTS.extend(p_count,p_parent_index);
  p_line_rec.SERVICE_DURATION.extend(p_count,p_parent_index);
  p_line_rec.SERVICE_PERIOD.extend(p_count,p_parent_index);
  p_line_rec.SERVICE_START_DATE.extend(p_count,p_parent_index);
  p_line_rec.SERVICE_END_DATE.extend(p_count,p_parent_index);
  p_line_rec.SERVICE_COTERMINATE_FLAG.extend(p_count,p_parent_index);
  p_line_rec.UNIT_LIST_PERCENT.extend(p_count,p_parent_index);
  p_line_rec.UNIT_SELLING_PERCENT.extend(p_count,p_parent_index);
  p_line_rec.UNIT_PERCENT_BASE_PRICE.extend(p_count,p_parent_index);
  p_line_rec.SERVICE_NUMBER.extend(p_count,p_parent_index);
  p_line_rec.SERVICE_REFERENCE_TYPE_CODE.extend(p_count,p_parent_index);
  --p_line_rec.SERVICE_REFERENCE_LINE_ID.extend(p_count,p_parent_index);
  --p_line_rec.SERVICE_REFERENCE_SYSTEM_ID.extend(p_count,p_parent_index);
  p_line_rec.TP_CONTEXT.extend(p_count,p_parent_index);
  p_line_rec.TP_ATTRIBUTE1.extend(p_count,p_parent_index);
  p_line_rec.TP_ATTRIBUTE2.extend(p_count,p_parent_index);
  p_line_rec.TP_ATTRIBUTE3.extend(p_count,p_parent_index);
  p_line_rec.TP_ATTRIBUTE4.extend(p_count,p_parent_index);
  p_line_rec.TP_ATTRIBUTE5.extend(p_count,p_parent_index);
  p_line_rec.TP_ATTRIBUTE6.extend(p_count,p_parent_index);
  p_line_rec.TP_ATTRIBUTE7.extend(p_count,p_parent_index);
  p_line_rec.TP_ATTRIBUTE8.extend(p_count,p_parent_index);
  p_line_rec.TP_ATTRIBUTE9.extend(p_count,p_parent_index);
  p_line_rec.TP_ATTRIBUTE10.extend(p_count,p_parent_index);
  p_line_rec.TP_ATTRIBUTE11.extend(p_count,p_parent_index);
  p_line_rec.TP_ATTRIBUTE12.extend(p_count,p_parent_index);
  p_line_rec.TP_ATTRIBUTE13.extend(p_count,p_parent_index);
  p_line_rec.TP_ATTRIBUTE14.extend(p_count,p_parent_index);
  p_line_rec.TP_ATTRIBUTE15.extend(p_count,p_parent_index);
  --p_line_rec.FLOW_STATUS_CODE.extend(p_count,p_parent_index);
  --p_line_rec.MARKETING_SOURCE_CODE_ID.extend(p_count,p_parent_index);
  p_line_rec.CALCULATE_PRICE_FLAG.extend(p_count,p_parent_index);
  p_line_rec.COMMITMENT_ID.extend(p_count,p_parent_index);
  p_line_rec.ORDER_SOURCE_ID.extend(p_count,p_parent_index);
  --p_line_rec.upgraded_flag.extend(p_count,p_parent_index);
  p_line_rec.LOCK_CONTROL.extend(p_count,p_parent_index);
  p_line_rec.WF_PROCESS_NAME.extend(p_count,p_parent_index);
  p_line_rec.user_item_description.extend(p_count,p_parent_index);
  p_line_rec.parent_line_index.extend(p_count,p_parent_index);
  p_line_rec.firm_demand_flag.extend(p_count,p_parent_index);
--  p_line_rec.line_index.extend(p_count, p_parent_index);
--  p_line_rec.header_index.extend(p_count, p_parent_index);
-- end customer (Bug 5054618)
p_line_rec.End_customer_contact_id.extend(p_count,p_parent_index);
p_line_rec.End_customer_id.extend(p_count,p_parent_index);
p_line_rec.End_customer_site_use_id.extend(p_count,p_parent_index);
p_line_rec.IB_owner.extend(p_count,p_parent_index);
p_line_rec.IB_current_location.extend(p_count,p_parent_index);
p_line_rec.IB_Installed_at_Location.extend(p_count,p_parent_index);
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , EXTEND_INC_ITEM_REC' ) ;
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Extend_Inc_Item_Rec'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Extend_Inc_Item_Rec;

PROCEDURE Assign_Included_Items
        (p_ii_count            IN NUMBER
        ,p_ii_start_index      IN NUMBER
        ,p_parent_index        IN NUMBER
        ,p_line_rec            IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
        ,p_header_index        IN NUMBER
        ,p_header_rec          IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE
        ,x_ii_on_generic_hold  OUT NOCOPY BOOLEAN
        )
IS
 l_process_name         VARCHAR2(30);
 l_index                NUMBER;
 l_component_number     NUMBER := 1;
 l_ii_index             NUMBER := p_ii_start_index;
 l_on_generic_hold      BOOLEAN := FALSE;
 l_on_booking_hold      BOOLEAN := FALSE;
 l_on_scheduling_hold   BOOLEAN := FALSE;
 l_ii_on_hold_count     NUMBER := 0;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
 l_line_rec_for_hold	  OE_Order_PUB.Line_Rec_Type;  --ER#7479609
 l_header_rec_for_hold    OE_Order_PUB.Header_Rec_Type;  --ER#7479609
BEGIN

 x_ii_on_generic_hold := FALSE;
 l_index := (p_line_rec.line_id.COUNT - p_ii_count) + 1;

 FOR I IN 1..p_ii_count LOOP

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INDEX :'||L_INDEX ) ;
    END IF;

    p_line_rec.COMPONENT_CODE(l_index) := G_INC_ITEM_TBL(l_ii_index).COMPONENT_CODE;
    p_line_rec.COMPONENT_NUMBER(l_index) := l_component_number;
    p_line_rec.COMPONENT_SEQUENCE_ID(l_index) := G_INC_ITEM_TBL(l_ii_index).COMPONENT_SEQUENCE_ID;
    p_line_rec.INVENTORY_ITEM_ID(l_index) := G_INC_ITEM_TBL(l_ii_index).COMPONENT_ITEM_ID;
    p_line_rec.ORDERED_ITEM_ID(l_index) := G_INC_ITEM_TBL(l_ii_index).COMPONENT_ITEM_ID;
    p_line_rec.ORDERED_ITEM(l_index) := G_INC_ITEM_TBL(l_ii_index).ORDERED_ITEM;
    p_line_rec.ITEM_TYPE_CODE(l_index) := 'INCLUDED';
    p_line_rec.ORDERED_QUANTITY(l_index) := G_INC_ITEM_TBL(l_ii_index).extended_quantity
                         * p_line_rec.ORDERED_QUANTITY(p_parent_index);
    p_line_rec.ORDERED_QUANTITY2(l_index) := p_line_rec.ORDERED_QUANTITY2(p_parent_index);
    p_line_rec.ORDER_QUANTITY_UOM(l_index) := G_INC_ITEM_TBL(l_ii_index).primary_uom_code;
    p_line_rec.ORDERED_QUANTITY_UOM2(l_index) := p_line_rec.ORDERED_QUANTITY_UOM2(p_parent_index);
    p_line_rec.PRICING_QUANTITY(l_index) := G_INC_ITEM_TBL(l_ii_index).extended_quantity
                         * p_line_rec.ORDERED_QUANTITY(p_parent_index);
    p_line_rec.PRICING_QUANTITY_UOM(l_index) := G_INC_ITEM_TBL(l_ii_index).PRIMARY_UOM_CODE;
    p_line_rec.SHIPPABLE_FLAG(l_index) := G_INC_ITEM_TBL(l_ii_index).SHIPPABLE_FLAG;
    p_line_rec.SORT_ORDER(l_index) := G_INC_ITEM_TBL(l_ii_index).SORT_ORDER;
    p_line_rec.unit_list_price(l_index) := 0;
    p_line_rec.unit_list_price_per_pqty(l_index) := 0;
    p_line_rec.unit_selling_price(l_index) := 0;
    p_line_rec.unit_selling_price_per_pqty(l_index) := 0;
    -- Bug 2670420: query_included_items did not retrieve any items as
    -- link_to_line_id was not being populated earlier
    -- Set link_to_line_id to be same as top_model_line_id
    p_line_rec.link_to_line_id(l_index) := p_line_rec.line_id(p_parent_index);
    p_line_rec.parent_line_index(l_index) := p_parent_index;
    if (NOT p_line_rec.line_index.exists(l_index))
    THEN
       p_line_rec.line_index.extend(l_index - p_line_rec.line_index.count);
    end if;
    p_line_rec.line_index(l_index) := l_index;
    if (NOT p_line_rec.header_index.exists(l_index))
    THEN
       p_line_rec.header_index.extend(l_index - p_line_rec.header_index.count);
    end if;
    p_line_rec.header_index(l_index) := p_header_index;

    SELECT OE_ORDER_LINES_S.NEXTVAL
    INTO p_line_rec.line_id(l_index)
    FROM DUAL;

    -- Assign Workflow Process for Included Item Type
    IF NOT OE_BULK_WF_UTIL.Validate_LT_WF_Assignment(
                 p_header_rec.order_type_id(p_header_index)
                 ,l_index
                 ,p_line_rec
                 ,l_process_name)
    THEN
        p_line_rec.lock_control(l_index) := -99 ;
        fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
               OE_Order_UTIL.Get_Attribute_Name('LINE_TYPE_ID'));
        OE_BULK_MSG_PUB.Add('Y','ERROR');
        RAISE FND_API.G_EXC_ERROR;
    ELSE
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Worflow Process for ii :'||l_process_name);
       END IF;

        p_line_rec.wf_process_name(l_index) := l_process_name;
    END IF;
  --PIB
    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
       OE_BULK_PRICEORDER_PVT.set_calc_flag_incl_item(p_line_rec,l_index);
    END IF;
  --PIB

    -- Evaluate Holds for inc item
    /*ER#7479609 start
    OE_Bulk_Holds_PVT.Evaluate_Holds(
           p_header_id          => p_line_rec.header_id(l_index),
           p_line_id            => p_line_rec.line_id(l_index),
           p_line_number        => p_line_rec.line_number(l_index),
           p_sold_to_org_id     => p_line_rec.sold_to_org_id(l_index),
           p_inventory_item_id  => p_line_rec.inventory_item_id(l_index),
           p_ship_from_org_id   => p_line_rec.ship_from_org_id(l_index),
           p_invoice_to_org_id  => p_line_rec.invoice_to_org_id(l_index),
           p_ship_to_org_id     => p_line_rec.ship_to_org_id(l_index),
           p_top_model_line_id  => p_line_rec.top_model_line_id(l_index),
           p_ship_set_name      => NULL,
           p_arrival_set_name   => NULL,
           p_on_generic_hold    => l_on_generic_hold,
           p_on_booking_hold    => l_on_booking_hold,
           p_on_scheduling_hold => l_on_scheduling_hold
           );
      ER#7479609 end*/

            --ER#7479609 start
            BEGIN
            SELECT order_type_id
            INTO l_header_rec_for_hold.order_type_id
            FROM OE_ORDER_HEADERS_ALL
            WHERE header_id=p_line_rec.header_id(l_index);
            EXCEPTION
            WHEN OTHERS THEN
              l_header_rec_for_hold.order_type_id := NULL;
            END;


            l_line_rec_for_hold.header_id := p_line_rec.header_id(l_index);
            l_line_rec_for_hold.line_id := p_line_rec.line_id(l_index);
            l_line_rec_for_hold.line_number := p_line_rec.line_number(l_index);
            l_line_rec_for_hold.sold_to_org_id := p_line_rec.sold_to_org_id(l_index);
            l_line_rec_for_hold.inventory_item_id := p_line_rec.inventory_item_id(l_index);
            l_line_rec_for_hold.ship_from_org_id := p_line_rec.ship_from_org_id(l_index);
            l_line_rec_for_hold.invoice_to_org_id := p_line_rec.invoice_to_org_id(l_index);
            l_line_rec_for_hold.ship_to_org_id := p_line_rec.ship_to_org_id(l_index);
            l_line_rec_for_hold.top_model_line_id := p_line_rec.top_model_line_id(l_index);
            l_line_rec_for_hold.price_list_id := p_line_rec.price_list_id(l_index);
            l_line_rec_for_hold.creation_date := to_char(sysdate,'DD-MON-RRRR');
            l_line_rec_for_hold.shipping_method_code := p_line_rec.shipping_method_code(l_index);
            l_line_rec_for_hold.deliver_to_org_id := p_line_rec.deliver_to_org_id(l_index);
            l_line_rec_for_hold.source_type_code := p_line_rec.source_type_code(l_index);
            l_line_rec_for_hold.line_type_id := p_line_rec.line_type_id(l_index);
            l_line_rec_for_hold.payment_term_id := p_line_rec.payment_term_id(l_index);
            l_line_rec_for_hold.created_by := NVL(FND_GLOBAL.USER_ID, -1);


             OE_Bulk_Holds_PVT.Evaluate_Holds(
		p_header_rec  => l_header_rec_for_hold,
		p_line_rec    => l_line_rec_for_hold,
		p_on_generic_hold  => l_on_generic_hold,
		p_on_booking_hold  => l_on_booking_hold,
		p_on_scheduling_hold => l_on_scheduling_hold
		);
            --ER#7479609 end

    IF l_on_generic_hold THEN
       x_ii_on_generic_hold := TRUE;
       l_ii_on_hold_count := l_ii_on_hold_count + 1;
       -- If line is to be scheduled AND lines on hold should NOT be
       -- scheduled, populate error message and clear scheduling
       -- fields on this included item.
       IF  p_line_rec.schedule_status_code(l_index) IS NOT NULL
           AND OE_BULK_ORDER_PVT.G_SCHEDULE_LINE_ON_HOLD = 'N'
       THEN
          -- Add scheduling on hold message
          FND_MESSAGE.SET_NAME('ONT','OE_SCH_LINE_ON_HOLD');
          OE_BULK_MSG_PUB.Add;
          p_line_rec.schedule_status_code(l_index) := NULL;
          p_line_rec.schedule_ship_date(l_index) := NULL;
          p_line_rec.schedule_arrival_date(l_index) := NULL;
       END IF;
    END IF;

    l_index := l_index + 1;
    l_ii_index := l_ii_index + 1;
    l_component_number := l_component_number + 1;

  END LOOP;

  IF p_line_rec.schedule_status_code(p_parent_index) IS NOT NULL THEN

     IF x_ii_on_generic_hold
        AND OE_BULK_ORDER_PVT.G_SCHEDULE_LINE_ON_HOLD = 'N'
     THEN

       -- Decrement the kit item from scheduling count
       -- For SMC and non-SMC, kit should not be scheduled if
       -- any included item is on generic hold
       OE_BULK_ORDER_PVT.G_SCH_COUNT :=
            OE_BULK_ORDER_PVT.G_SCH_COUNT - 1;

       -- If Non-SMC, increment the scheduling count by lines
       -- that need to be scheduled.
       IF p_line_rec.ship_model_complete_flag(p_parent_index) = 'N' THEN

          OE_BULK_ORDER_PVT.G_SCH_COUNT :=
            OE_BULK_ORDER_PVT.G_SCH_COUNT + (p_ii_count - l_ii_on_hold_count);
          -- Mark parent line status as ON HOLD so that scheduling ignores
          -- the parent line BUT still schedules the included items that
          -- are not on hold. If the status is nulled out, none of the
          -- included items will be scheduled !
          p_line_rec.schedule_status_code(p_parent_index) := 'II_ON_HOLD';
          p_line_rec.schedule_ship_date(p_parent_index) := NULL;
          p_line_rec.schedule_arrival_date(p_parent_index) := NULL;

       ELSIF p_line_rec.ship_model_complete_flag(p_parent_index) = 'Y' THEN

          -- For SMCs, all included items should not be scheduled if one is on hold
          FOR l_index IN (p_line_rec.line_id.COUNT - p_ii_count) + 1..p_line_rec.line_id.COUNT LOOP
             p_line_rec.schedule_status_code(l_index) := NULL;
             p_line_rec.schedule_ship_date(l_index) := NULL;
             p_line_rec.schedule_arrival_date(l_index) := NULL;
          END LOOP;
          -- Kit line should not be scheduled either for SMCs
          p_line_rec.schedule_status_code(p_parent_index) := NULL;
          p_line_rec.schedule_ship_date(p_parent_index) := NULL;
          p_line_rec.schedule_arrival_date(p_parent_index) := NULL;

       END IF;

     -- NO Holds, increment the scheduling count by number of
     -- included items
     ELSE
       OE_BULK_ORDER_PVT.G_SCH_COUNT :=
            OE_BULK_ORDER_PVT.G_SCH_COUNT + p_ii_count;
     END IF;

   END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , ASSIGN_INCLUDED_ITEMS' ) ;
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Assign_Included_Items'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Assign_Included_Items;

---------------------------------------------------------------------
-- PROCEDURE Create_Line_Scredits
--
-- BULK Inserts line sales credits into the OM tables from
-- p_line_scredit_rec
---------------------------------------------------------------------

PROCEDURE Create_Line_Scredits
(p_line_scredit_rec             IN OE_BULK_ORDER_PVT.SCREDIT_REC_TYPE
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF p_line_scredit_rec.header_id.COUNT = 0 THEN
     RETURN;
  END IF;

  FORALL I IN p_line_scredit_rec.header_id.FIRST..p_line_scredit_rec.header_id.LAST
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
    ,       p_line_scredit_rec.header_id(i)
    ,       FND_GLOBAL.USER_ID
    ,       sysdate
    ,       FND_GLOBAL.USER_ID
    ,       p_line_scredit_rec.line_id(i)
    ,       100
    ,       p_line_scredit_rec.salesrep_id(i)
    ,       nvl(p_line_scredit_rec.Sales_Credit_Type_id(i),1)
    ,       OE_SALES_CREDITS_S.nextval
    ,       NULL
    ,       NULL
    ,       1
    );

EXCEPTION
  WHEN OTHERS THEN
    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Create_Line_Scredits'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Create_Line_Scredits;

---------------------------------------------------------------------
-- PROCEDURE Append_Included_Items
--
-- This procedure is called for each KIT line being processed.
-- It appends the exploded included item order lines for this kit
-- to the end of p_line_rec.
-- IN/IN OUT Parameters -
-- p_parent_index : index of the KIT line in p_line_rec
-- p_line_rec: order lines in this batch
-- p_header_index : index of the order header for the kit line in
--                  p_header_rec
-- p_header_rec: order headers in this batch
-- OUT Parameters -
-- x_ii_count : number of included item lines for this KIT line
-- x_ii_start_index : starting index from where the included items
--      for this KIT line are appended in p_line_rec
-- x_ii_on_generic_hold : TRUE if any one included item for this
--      KIT is applicable for a generic hold
---------------------------------------------------------------------

PROCEDURE Append_Included_Items
        (p_parent_index        IN NUMBER
        ,p_line_rec            IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
        ,p_header_index        IN NUMBER
        ,p_header_rec          IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE
        ,x_ii_count            OUT NOCOPY NUMBER
        ,x_ii_start_index      OUT NOCOPY NUMBER
        ,x_ii_on_generic_hold  OUT NOCOPY BOOLEAN
       )
IS
   l_kit_item_id           NUMBER;
   l_ship_from_org_id      NUMBER;
   l_index                 NUMBER;
   l_msg_data              VARCHAR2(2000);
   l_error_code            VARCHAR2(2000);
   l_return_status         VARCHAR2(30);
   l_freeze                BOOLEAN := FALSE;
   CURSOR c_inc_items IS
    SELECT be.component_code
           ,be.component_sequence_id
           ,be.component_item_id
           ,be.extended_quantity
           ,be.primary_uom_code
           ,be.sort_order
           ,i.concatenated_segments ordered_item
           ,wi.shippable_item_flag
    FROM BOM_BILL_OF_MATERIALS bom
        , BOM_EXPLOSIONS be
        , MTL_SYSTEM_ITEMS_KFV i -- item in item validation org
        , MTL_SYSTEM_ITEMS wi    -- item in ship from org
    WHERE bom.assembly_item_id = l_kit_item_id
      AND bom.organization_id = OE_BULK_ORDER_PVT.G_ITEM_ORG
      AND be.top_bill_sequence_id = bom.bill_sequence_id
      AND be.explosion_type = 'INCLUDED'
      AND be.plan_level >= 0
      AND be.effectivity_date <= sysdate
      AND be.disable_date > sysdate
      AND be.component_item_id <> be.top_item_id
      AND i.inventory_item_id = be.component_item_id
      AND i.organization_id = OE_BULK_ORDER_PVT.G_ITEM_ORG
      AND wi.inventory_item_id = be.component_item_id
      AND wi.organization_id = nvl(l_ship_from_org_id,OE_BULK_ORDER_PVT.G_ITEM_ORG)
      ORDER BY be.sort_order;
      --
      l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
      --
BEGIN

   ------------------------------------------------------------------
   -- Check if this kit line should be exploded/frozen
   ------------------------------------------------------------------

   -- 1. If freeze method is 'Entry', explode and freeze included items
   IF OE_BULK_ORDER_PVT.G_IIFM = 'ENTRY' THEN
     l_freeze := TRUE;

   -- 2. If freeze method is 'Booked', freeze if parent line is booked.
   --    If not booked, explode if parent line is to be scheduled
   --    but do not freeze.
   ELSIF OE_BULK_ORDER_PVT.G_IIFM = 'BOOKING' THEN
     IF p_line_rec.booked_flag(p_parent_index) = 'Y' THEN
       l_freeze := TRUE;
     ELSIF p_line_rec.schedule_status_code(p_parent_index) IS NULL THEN
       RETURN;
     END IF;

   -- 3. For other freeze methods (e.g. Pick Release), explode if
   --    parent line is to be scheduled but do not freeze.
   ELSIF p_line_rec.schedule_status_code(p_parent_index) IS NULL THEN
     RETURN;
   END IF;

   ------------------------------------------------------------------
   -- Cache included item info in globals - G_KIT_ITEM_TBL and
   -- G_INC_ITEM_TBL - for this kit item
   ------------------------------------------------------------------

   l_kit_item_id := p_line_rec.inventory_item_id(p_parent_index);

   IF NOT G_KIT_ITEM_TBL.EXISTS(l_kit_item_id) THEN

      OE_Config_UTIL.Explode
         (p_validation_org => OE_BULK_ORDER_PVT.G_ITEM_ORG,
          p_levels         => 6, --??
          p_stdcompflag    => 'INCLUDED',
          p_top_item_id    => l_kit_item_id,
          p_revdate        => sysdate,
          x_msg_data       => l_msg_data,
          x_error_code     => l_error_code,
          x_return_status  => l_return_status
          );

      -- When does BOM return expected error during Explode?
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_index := G_INC_ITEM_TBL.COUNT + 1;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'START INDEX :'||L_INDEX ) ;
      END IF;
      G_KIT_ITEM_TBL(l_kit_item_id).ii_start_index := l_index;

      l_ship_from_org_id := p_line_rec.ship_from_org_id(p_parent_index);

      OPEN c_inc_items;

      LOOP
      FETCH c_inc_items INTO
            G_INC_ITEM_TBL(l_index).component_code
           ,G_INC_ITEM_TBL(l_index).component_sequence_id
           ,G_INC_ITEM_TBL(l_index).component_item_id
           ,G_INC_ITEM_TBL(l_index).extended_quantity
           ,G_INC_ITEM_TBL(l_index).primary_uom_code
           ,G_INC_ITEM_TBL(l_index).sort_order
           ,G_INC_ITEM_TBL(l_index).ordered_item
           ,G_INC_ITEM_TBL(l_index).shippable_flag
           ;

     IF c_inc_items%NOTFOUND THEN
        EXIT;
     END IF;

     l_index := l_index + 1;

     END LOOP;

     CLOSE c_inc_items;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'END INDEX :'||L_INDEX ) ;
     END IF;
     G_KIT_ITEM_TBL(l_kit_item_id).ii_count :=
                     l_index - G_KIT_ITEM_TBL(l_kit_item_id).ii_start_index;

   END IF; -- End caching included item info

   ------------------------------------------------------------------
   -- Use the cached records to append included item order lines
   -- to lines global: p_line_rec
   ------------------------------------------------------------------

   x_ii_count := G_KIT_ITEM_TBL(l_kit_item_id).ii_count;
   x_ii_start_index := p_line_rec.line_id.count + 1;

   Extend_Inc_Item_Rec
          (p_count         => G_KIT_ITEM_TBL(l_kit_item_id).ii_count
          ,p_parent_index  => p_parent_index
          ,p_line_rec      => p_line_rec
          );

   Assign_Included_Items
          (p_ii_count   => G_KIT_ITEM_TBL(l_kit_item_id).ii_count
          ,p_ii_start_index => G_KIT_ITEM_TBL(l_kit_item_id).ii_start_index
          ,p_parent_index  => p_parent_index
          ,p_line_rec      => p_line_rec
          ,p_header_index  => p_header_index
          ,p_header_rec    => p_header_rec
          ,x_ii_on_generic_hold => x_ii_on_generic_hold
          );

   IF (l_freeze) THEN
       p_line_rec.explosion_date(p_parent_index) := sysdate;
   END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , APPEND_INCLUDED_ITEMS' ) ;
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    OE_BULK_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Append_Included_Items'
       );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Append_Included_Items;
END OE_BULK_LINE_UTIL;

/
