--------------------------------------------------------
--  DDL for Package Body OE_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VALIDATE" AS
/* $Header: OEXSVATB.pls 120.11.12010000.2 2009/12/08 13:17:15 msundara ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Validate';

G_RLM_INSTALLED_FLAG          VARCHAR2(1) := 'N';

--  Procedure Get_Attr_Tbl.
--
--  Used by generator to avoid overriding or duplicating existing
--  validation functions.
--
--  DO NOT REMOVE

PROCEDURE Get_Attr_Tbl
IS
I                             NUMBER:=0;
BEGIN

    FND_API.g_attr_tbl.DELETE;

--  START GEN attributes

--  Generator will append new attributes before end generate comment.

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'Desc_Flex';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'accounting_rule';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'agreement';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'conversion_rate';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'conversion_rate_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'conversion_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'CUSTOMER_PREFERENCE_SET';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'created_by';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'creation_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'cust_po_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'deliver_to_contact';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'deliver_to_org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'demand_class';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'expiration_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'earliest_schedule_limit';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'fob_point';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'freight_carrier';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'freight_terms';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'header';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'invoice_to_contact';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'invoice_to_org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'invoicing_rule';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_updated_by';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_update_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_update_login';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'latest_schedule_limit';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ordered_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'order_date_type_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'order_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'order_source';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'order_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'orig_sys_document_ref';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'partial_shipments_allowed';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'payment_term';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_list';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'program_application';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'program';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'program_update_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'request_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'request';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reserved_quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'shipment_priority';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'shipping_method';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ship_from_org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ship_tolerance_above';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ship_tolerance_below';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ship_to_contact';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ship_to_org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'intermed_ship_to_contact';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'intermed_ship_to_org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'sold_to_contact';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'sold_to_org';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'source_document';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'source_document_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'tax_exempt';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'tax_exempt_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'tax_exempt_reason';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'tax_point';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'transactional_curr';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'version_number';

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'applied_flag';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'automatic';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'change_reason_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'change_reason_text';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'discount';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'discount_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'list_header_id';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'list_line_id';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'list_line_type_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'modified_from';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'modified_to';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'modified_mechanism_type_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'percent';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'price_adjustment';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'updated_flag';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'update_allowed';

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'dw_update_advice';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'quota';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'salesrep';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'Sales_credit_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'sales_credit';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'wh_update_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'actual_shipment_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'cancelled_quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'component';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'component_sequence';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'config_display_sequence';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'top_model_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'customer_dock';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'customer_job';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'customer_production_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'customer_trx_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'credit_invoice_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'cust_model_serial_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'delivery_lead_time';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'demand_bucket_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'dep_plan_required';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'fulfilled_quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'inventory_item';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'invoice_interface_status';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ordered_item_id';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'item_identifier_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ordered_item';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'item_revision';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'item_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'line_category';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'line_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'line_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'link_to_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'option_flag';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'option_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ordered_quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'order_quantity_uom';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'orig_sys_line_ref';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'pricing_quantity_uom';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'project';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'promise_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reference_header';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reference_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'reference_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'rla_schedule_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'schedule_ship_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'shipment_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'shipped_quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'shipping_quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'shipping_quantity_uom';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'sort_order';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'source_document_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'task';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'tax';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'tax_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'tax_rate';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'tax_value';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'unit_list_price';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'unit_list_price_per_pqty';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'unit_selling_price';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'unit_selling_price_per_pqty';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'visible_demand';

    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'from_serial_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'lot_number';
 --   I := I + 1; -- INVCONV
 --   FND_API.g_attr_tbl(I).name     := 'sublot_number'; --OPM 2380194
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'lot_serial';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'quantity';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'quantity2';  --OPM 2380194
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'to_serial_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'return_reason';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'split_from_line';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'cust_production_seq_num';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'authorized_to_ship';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'veh_cus_item_cum_key';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'arrival_set';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'ship_set';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'over_ship_reason';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'over_ship_resolved';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'payment_type';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'payment_amount';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'check_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'credit_card';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'credit_card_holder_name';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'credit_card_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'credit_card_expiration_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'credit_card_approval_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'credit_card_approval_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'commitment';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'shippable';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'shipping_interfaced';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'first_ack_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'first_ack_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_ack_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'last_ack_date';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'end_item_unit_number';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'shipping_instructions';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'packing_instructions';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'estimated_flag';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'inc_in_sales_performance';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'split_action';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'cost_id';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'charge_type_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'charge_subtype_code';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'credit_or_charge_flag';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'include_on_returns_flag';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'minisite';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'IB_OWNER';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'IB_INSTALLED_AT_LOCATION';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'IB_CURRENT_LOCATION';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'END_CUSTOMER_ID';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'END_CUSTOMER_CONTACT_ID';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'SUPPLIER_SIGNATURE';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'SUPPLIER_SIGNATURE_DATE';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'CUSTOMER_SIGNATURE';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'CUSTOMER_SIGNATURE_DATE';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'CONTRACT_TEMPLATE_ID';
    I := I + 1;
-- INVCONV
    FND_API.g_attr_tbl(I).name     := 'fulfilled_quantity2';
     I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'shipped_quantity2';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'shipping_quantity2';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'shipping_quantity_uom2';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'cancelled_quantity2';
    I := I + 1;
    FND_API.g_attr_tbl(I).name     := 'Payment_Trxn_Extension';  --R12 Process order api changes
    I := I + 1;

--
--  END GEN attributes

END Get_Attr_Tbl;

--  Prototypes for validate functions.

--  START GEN validate

--  Generator will append new prototypes before end generate comment.

--/old/

FUNCTION Desc_Flex ( p_flex_name IN VARCHAR2 )
RETURN BOOLEAN
IS
   l_appl_short_name VARCHAR2(30);
   l_count NUMBER := 0;
BEGIN


    -- Initialize the global variables to NULL, for bug 2511313
    g_context     := NULL;
    g_attribute1  := NULL;
    g_attribute2  := NULL;
    g_attribute3  := NULL;
    g_attribute4  := NULL;
    g_attribute5  := NULL;
    g_attribute6  := NULL;
    g_attribute7  := NULL;
    g_attribute8  := NULL;
    g_attribute9  := NULL;
    g_attribute10 := NULL;
    g_attribute11 := NULL;
    g_attribute12 := NULL;
    g_attribute13 := NULL;
    g_attribute14 := NULL;
    g_attribute15 := NULL;
    g_attribute16 := NULL;
    g_attribute17 := NULL;
    g_attribute18 := NULL;
    g_attribute19 := NULL;
    g_attribute20 := NULL;
    g_attribute21 := NULL;
    g_attribute22 := NULL;
    g_attribute23 := NULL;
    g_attribute24 := NULL;
    g_attribute25 := NULL;
    g_attribute26 := NULL;
    g_attribute27 := NULL;
    g_attribute28 := NULL;
    g_attribute29 := NULL;
    g_attribute30 := NULL;

    --  Call FND validate API.

    --  This call is temporarily commented out
    IF (p_flex_name = 'RLM_SCHEDULE_LINES') THEN
       l_appl_short_name := 'RLM';
    ELSE
       l_appl_short_name := 'ONT';
    END IF;

    -- Modified the following call to pass th value 'D' to values_or_ids
    -- to validate as well as to default the segment values.

    IF FND_FLEX_DESCVAL.Validate_Desccols( appl_short_name    => l_appl_short_name,
					   desc_flex_name     => p_flex_name,
					   values_or_ids      => 'D'    -- for bug 2511313
					   ) THEN


       -- Copying values into global variables
       l_count := fnd_flex_descval.segment_count;
       FOR i IN 1..l_count LOOP
	  IF FND_FLEX_DESCVAL.segment_column_name(i) = g_context_name THEN
	     g_context :=  FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute1_name THEN
	     g_attribute1 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute2_name THEN
	     g_attribute2 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute3_name THEN
	     g_attribute3 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute4_name THEN
	     g_attribute4 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute5_name THEN
	     g_attribute5 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute6_name THEN
	     g_attribute6 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute7_name THEN
	     g_attribute7 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute8_name THEN
	     g_attribute8 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute9_name THEN
	     g_attribute9 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute10_name THEN
	     g_attribute10 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute11_name THEN
	     g_attribute11 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute12_name THEN
	     g_attribute12 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute13_name THEN
	     g_attribute13 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute14_name THEN
	     g_attribute14 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute15_name THEN
	     g_attribute15 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute16_name THEN
	     g_attribute16 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute17_name THEN
	     g_attribute17 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute18_name THEN
	     g_attribute18 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute19_name THEN
	     g_attribute19 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute20_name THEN
	     g_attribute20 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute21_name THEN
	     g_attribute21 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute22_name THEN
	     g_attribute22 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute23_name THEN
	     g_attribute23 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute24_name THEN
	     g_attribute24 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute25_name THEN
	     g_attribute25 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute26_name THEN
	     g_attribute26 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute27_name THEN
	     g_attribute27 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute28_name THEN
	     g_attribute28 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute29_name THEN
	     g_attribute29 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = g_attribute30_name THEN
	     g_attribute30 := FND_FLEX_DESCVAL.segment_id(i);
	  END IF;
       END LOOP;

       RETURN TRUE;

     ELSE

        --  Prepare the encoded message by setting it on the message
        --  dictionary stack. Then, add it to the API message list.

        FND_MESSAGE.Set_Encoded(FND_FLEX_DESCVAL.Encoded_Error_Message);

        OE_MSG_PUB.Add;

        --  Derive return status.

        IF FND_FLEX_DESCVAL.unsupported_error
        THEN
           -- unsupport error,supress the validation and hard error and
           -- throw a warning intead

           RETURN TRUE;

        ELSIF FND_FLEX_DESCVAL.value_error
        THEN

            --  In case of an expected error return FALSE

            RETURN FALSE;

        ELSE

            --  In case of an unexpected error raise an exception.

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;

    END IF;


    RETURN TRUE;

END Desc_Flex;

FUNCTION Header ( p_header_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_header_id IS NULL OR
        p_header_id = FND_API.G_MISS_NUM
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_header_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'HEADER_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('HEADER_ID'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Header'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Header;

FUNCTION Org ( p_org_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_org_id IS NULL OR
        p_org_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_org_id;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ORG_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('ORG_ID'));
            OE_MSG_PUB.Add;

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Org;

FUNCTION Order_Type ( p_order_type_id IN NUMBER )
RETURN BOOLEAN
IS
x_doc_sequence_value     NUMBER;
x_doc_category_code      VARCHAR(30);
X_doc_sequence_id       NUMBER;
X_db_sequence_name      VARCHAR2(50);
X_set_Of_Books_id       NUMBER;
seqassid                integer;
x_Trx_Date		DATE;
l_order_type_rec    OE_Order_Cache.Order_Type_Rec_Type;
l_set_of_books_rec    OE_Order_Cache.Set_Of_Books_Rec_Type;

l_dummy                       VARCHAR2(80);
BEGIN

    IF p_order_type_id IS NULL OR
        p_order_type_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --changes for bug 4200055
     l_order_type_rec := OE_ORDER_CACHE.Load_Order_Type(p_order_type_id);
     IF l_order_type_rec.order_type_id <> FND_API.G_MISS_NUM
        and l_order_type_rec.order_type_id IS NOT NULL
        and l_order_type_rec.order_type_id = p_order_type_id
     THEN
           if ( trunc(nvl(l_order_type_rec.Start_Date_Active,sysdate)) <= trunc(sysdate)
                and trunc(nvl(l_order_type_rec.End_Date_Active,sysdate)) >= trunc(sysdate)
                )
           then
                 RETURN TRUE ;
           else
                RAISE NO_DATA_FOUND ;
           end if ;
     ELSE
             RAISE NO_DATA_FOUND  ;

     END IF ;

 /*   SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_ORDER_TYPES_V
    WHERE   ORDER_TYPE_ID = p_order_type_id
    AND     SYSDATE BETWEEN NVL( START_DATE_ACTIVE, SYSDATE  )
                    AND     NVL( END_DATE_ACTIVE, SYSDATE );

                  RETURN TRUE;
*/
 --end bug 4200055



EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ORDER_TYPE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('ORDER_TYPE_ID'));
            OE_MSG_PUB.Add;

            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);


        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Order_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Order_Type;

FUNCTION Order_Number ( p_order_number IN NUMBER)
RETURN BOOLEAN
IS
x_doc_sequence_value     NUMBER;
x_doc_category_code      VARCHAR(30);
X_doc_sequence_id       NUMBER;
X_db_sequence_name      VARCHAR2(50);
X_set_Of_Books_id       NUMBER;
seqassid                integer;
x_Trx_Date		DATE;
l_set_of_books_rec    OE_Order_Cache.Set_Of_Books_Rec_Type;
l_dummy                       VARCHAR2(10);
t				VARCHAR2(1);
BEGIN

    IF p_order_number IS NULL OR
        p_order_number = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;
/*    l_set_of_books_rec :=
    OE_Order_Cache.Load_Set_Of_Books;
	x_Set_Of_Books_Id := l_set_of_books_rec.set_of_books_id;
        X_Doc_Category_Code := to_char(p_order_type_id);
        IF (p_order_type_id = 1000) OR
	   (p_order_type_id = 1026) THEN
                   fnd_seqnum.get_seq_name(
                                                        300,
                                                        X_doc_category_code,
                                                        X_Set_Of_Books_Id,
                                                        null,
                                                        sysdate,
                                                        X_db_sequence_name,
                                                        X_doc_sequence_id,
                                                        seqassid);
   			IF x_doc_sequence_id IS NOT NULL THEN
    				select type into t
      				from FND_DOCUMENT_SEQUENCES
     				where DOC_SEQUENCE_ID = x_doc_sequence_id;
   			END IF;

       				if ( t = 'M')  then
					-- Check the Uniqueness here
 					--RETURN NULL;
					NULL;
				end if;
	END IF;*/

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_order_number;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

           OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ORDER_NUMBER');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('ORDER_NUMBER'));

            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Order_Number'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Order_Number;

FUNCTION Version_Number ( p_version_number IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_version_number IS NULL OR
        p_version_number = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    -- Version number cannot be negative or in decimals
    IF p_version_number < 0 OR mod(p_version_number,1) <> 0
    THEN
       RAISE NO_DATA_FOUND;
    END IF;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'VERSION_NUMBER');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('VERSION_NUMBER'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Version_Number'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Version_Number;

FUNCTION Expiration_Date ( p_expiration_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN
    IF p_expiration_date IS NULL OR
        p_expiration_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    -- Expiration date cannot be less than current date
    IF trunc(p_expiration_date) < trunc(sysdate) THEN
       RAISE NO_DATA_FOUND;
    END IF;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'EXPIRATION_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('EXPIRATION_DATE'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Expiration_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Expiration_Date;

FUNCTION Order_Source ( p_order_source_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_order_source_id IS NULL OR
        p_order_source_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_ORDER_SOURCES
    WHERE   ORDER_SOURCE_ID = p_order_source_id
    AND     ENABLED_FLAG = 'Y';



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ORDER_SOURCE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('order_source'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Order_Source'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Order_Source;

FUNCTION Source_Document_Type ( p_source_document_type_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_source_document_type_id IS NULL OR
        p_source_document_type_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_ORDER_SOURCES
    WHERE   ORDER_SOURCE_ID = p_source_document_type_id
    AND     ENABLED_FLAG = 'Y';


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SOURCE_DOCUMENT_TYPE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('SOURCE_DOCUMENT_TYPE_ID'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Source_Document_Type'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Source_Document_Type;

FUNCTION Source_Type ( p_source_type_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type      	      VARCHAR2(80) :='SOURCE_TYPE';
BEGIN

    IF p_source_type_code IS NULL OR
        p_source_type_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_LOOKUPS
    WHERE   LOOKUP_CODE = p_source_type_code
    AND     LOOKUP_TYPE = l_lookup_type
    AND     ENABLED_FLAG = 'Y'
    AND     SYSDATE     BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                        AND NVL(END_DATE_ACTIVE, SYSDATE);


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SOURCE_TYPE_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('SOURCE_TYPE_CODE'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Source_Type'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Source_Type;


FUNCTION Source_Document ( p_source_document_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN
    IF p_source_document_id IS NULL OR
        p_source_document_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_source_document_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SOURCE_DOCUMENT_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('SOURCE_DOCUMENT_ID'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Source_Document'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Source_Document;

FUNCTION Orig_Sys_Document_Ref ( p_orig_sys_document_ref IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_orig_sys_document_ref IS NULL OR
        p_orig_sys_document_ref = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_orig_sys_document_ref;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ORIG_SYS_DOCUMENT_REF');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('orig_sys_document_ref'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Orig_Sys_Document_Ref'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Orig_Sys_Document_Ref;

FUNCTION Date_Ordered ( p_date_ordered IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN
    IF p_date_ordered IS NULL OR
        p_date_ordered = FND_API.G_MISS_DATE
    THEN


        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_date_ordered;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'DATE_ORDERED');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('date_ordered'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Date_Ordered'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Date_Ordered;

FUNCTION Date_Requested ( p_date_requested IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN
    IF p_date_requested IS NULL OR
        p_date_requested = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_date_requested;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'DATE_REQUESTED');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('date_requested'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Date_Requested'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Date_Requested;

FUNCTION Shipment_Priority ( p_shipment_priority_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type      	      VARCHAR2(80) :='SHIPMENT_PRIORITY';
BEGIN

    IF p_shipment_priority_code IS NULL OR
        p_shipment_priority_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;


    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_LOOKUPS
    WHERE   LOOKUP_CODE = p_shipment_priority_code
    AND     LOOKUP_TYPE = l_lookup_type
    AND     ENABLED_FLAG = 'Y'
    AND     SYSDATE     BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                        AND NVL(END_DATE_ACTIVE, SYSDATE);



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SHIPMENT_PRIORITY_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('shipment_priority_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Shipment_Priority'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Shipment_Priority;

FUNCTION Demand_Class ( p_demand_class_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type      	      VARCHAR2(80) :='DEMAND_CLASS';
BEGIN
    IF p_demand_class_code IS NULL OR
        p_demand_class_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_FND_COMMON_LOOKUPS_V
    WHERE   LOOKUP_CODE = p_demand_class_code
    AND     LOOKUP_TYPE = l_lookup_type
    AND     APPLICATION_ID = 700
    AND     ENABLED_FLAG = 'Y'
    AND     SYSDATE     BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                        AND NVL(END_DATE_ACTIVE, SYSDATE);



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'DEMAND_CLASS_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('demand_class_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Demand_Class'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Demand_Class;

FUNCTION Price_List ( p_price_list_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_price_list_rec    OE_ORDER_CACHE.Price_List_Rec_Type := OE_ORDER_CACHE.g_price_list_rec ; -- add for bug 4200055
BEGIN
    IF p_price_list_id IS NULL OR
        p_price_list_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    -- added for bug 4200055
    IF ( OE_ORDER_CACHE.g_price_list_rec.price_list_id = FND_API.G_MISS_NUM
        OR OE_ORDER_CACHE.g_price_list_rec.price_list_id <> p_price_list_id ) THEN
                l_price_list_rec :=  OE_ORDER_CACHE.Load_Price_List(p_price_list_id) ;
    END IF ;

    IF ( l_price_list_rec.price_list_id <> FND_API.G_MISS_NUM
      AND l_price_list_rec.price_list_id IS NOT NULL
      AND l_price_list_rec.price_list_id = p_price_list_id ) THEN
          if nvl(l_price_list_rec.active_flag , 'Y') = 'Y' then
                --  Valid price list
                RETURN TRUE ;
          else
                RAISE NO_DATA_FOUND ;
          end if ;
     ELSE
        RAISE NO_DATA_FOUND ;
     END IF ;

    /*SELECT  'VALID'
    INTO    l_dummy
    FROM    qp_list_headers_vl
    WHERE   list_header_id = p_price_list_id
    and list_type_code in ('PRL', 'AGR') and
	nvl(active_flag,'Y') ='Y';

    --  Valid price list

    RETURN TRUE;

   */
    -- end bug 4200055

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PRICE_LIST_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('price_list_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_List'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_List;


FUNCTION Tax_Exempt ( p_tax_exempt_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
-- EBTax Changes
l_lookup_type      	      VARCHAR2(80) :='ZX_EXEMPTION_CONTROL';
BEGIN

    IF p_tax_exempt_flag IS NULL OR
        p_tax_exempt_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    fnd_lookups
    WHERE   LOOKUP_CODE = p_tax_exempt_flag
    AND     LOOKUP_TYPE = l_lookup_type
    AND     ENABLED_FLAG = 'Y'
    AND     SYSDATE     BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                        AND NVL(END_DATE_ACTIVE, SYSDATE);


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'TAX_EXEMPT_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('tax_exempt_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Tax_Exempt'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Tax_Exempt;


FUNCTION Tax_Exempt_Number ( p_tax_exempt_number IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_tax_exempt_number IS NULL OR
        p_tax_exempt_number = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  Valid Tax Exempt Number



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'TAX_EXEMPT_NUMBER');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('tax_exempt_number'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Tax_Exempt_Number'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Tax_Exempt_Number;

FUNCTION Tax_Exempt_Reason ( p_tax_exempt_reason_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
-- EBTax Changes
l_lookup_type      	      VARCHAR2(80) :='ZX_EXEMPTION_REASON_CODE';
BEGIN

    IF p_tax_exempt_reason_code IS NULL OR
        p_tax_exempt_reason_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    fnd_lookups
    WHERE   LOOKUP_CODE = p_tax_exempt_reason_code
    AND     LOOKUP_TYPE = l_lookup_type
    AND     ENABLED_FLAG = 'Y'
    AND     SYSDATE     BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                        AND NVL(END_DATE_ACTIVE, SYSDATE);


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'TAX_EXEMPT_REASON_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('tax_exempt_reason_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;



        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Tax_Exempt_Reason'
            );
        END IF;



        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Tax_Exempt_Reason;

FUNCTION Conversion_Rate ( p_conversion_rate IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_conversion_rate IS NULL OR
        p_conversion_rate = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_conversion_rate;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CONVERSION_RATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('conversion_rate'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Conversion_Rate'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Conversion_Rate;

FUNCTION CUSTOMER_PREFERENCE_SET ( p_CUSTOMER_PREFERENCE_SET_CODE IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_CUSTOMER_PREFERENCE_SET_CODE IS NULL OR
        p_CUSTOMER_PREFERENCE_SET_CODE = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CUSTOMER_PREFERENCE_SET_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('CUSTOMER_PREFERENCE_SET_CODE'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'CUSTOMER_PREFERENCE_SET'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END CUSTOMER_PREFERENCE_SET;

FUNCTION Conversion_Type ( p_conversion_type_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_conversion_type_code IS NULL OR
        p_conversion_type_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_GL_DAILY_CONVERSION_TYPES_V
    WHERE   CONVERSION_TYPE = p_conversion_type_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CONVERSION_TYPE_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('conversion_type_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Conversion_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Conversion_Type;

FUNCTION Conversion_Rate_Date ( p_conversion_rate_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN
    IF p_conversion_rate_date IS NULL OR
        p_conversion_rate_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_conversion_rate_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CONVERSION_RATE_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('conversion_rate_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Conversion_Rate_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Conversion_Rate_Date;

FUNCTION Partial_Shipments_Allowed ( p_partial_shipments_allowed IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type      	      VARCHAR2(80) :='YES_NO';
BEGIN

    IF p_partial_shipments_allowed IS NULL OR
        p_partial_shipments_allowed = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     OE_FND_COMMON_LOOKUPS_V
    WHERE    LOOKUP_CODE = p_partial_shipments_allowed
    AND      LOOKUP_TYPE = l_lookup_type
    AND      SYSDATE BETWEEN NVL(START_DATE_ACTIVE,SYSDATE)
                     AND     NVL(END_DATE_ACTIVE, SYSDATE );



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PARTIAL_SHIPMENTS_ALLOWED');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('partial_shipments_allowed'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Partial_Shipments_Allowed'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Partial_Shipments_Allowed;


FUNCTION Ship_Tolerance_Above ( p_ship_tolerance_above IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN
    IF p_ship_tolerance_above IS NULL OR
        p_ship_tolerance_above = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_ship_tolerance_above;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SHIP_TOLERANCE_ABOVE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('ship_tolerance_above'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ship_Tolerance_Above'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ship_Tolerance_Above;

FUNCTION Ship_Tolerance_Below ( p_ship_tolerance_below IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_ship_tolerance_below IS NULL OR
        p_ship_tolerance_below = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_ship_tolerance_below;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SHIP_TOLERANCE_BELOW');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('ship_tolerance_below'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ship_Tolerance_Below'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ship_Tolerance_Below;

FUNCTION Shippable ( p_shippable_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_shippable_flag IS NULL OR
        p_shippable_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    IF p_shippable_flag NOT IN ('Y','N') THEN
		RAISE NO_DATA_FOUND;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_shippable_flag;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SHIPPABLE_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('shippable_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Shippable'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Shippable;

FUNCTION Shipping_Interfaced ( p_shipping_interfaced_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_shipping_interfaced_flag IS NULL OR
        p_shipping_interfaced_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    IF p_shipping_interfaced_flag NOT IN ('Y','N') THEN
		RAISE NO_DATA_FOUND;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_shipping_interfaced_flag;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SHIPPING_INTERFACED_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('shipping_interfaced_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Shipping_Interfaced'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Shipping_Interfaced;

FUNCTION Shipping_Instructions ( p_shipping_instructions IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_shipping_instructions IS NULL OR
        p_shipping_instructions = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_shipping_instructions;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SHIPPING_INSTRUCTIONS');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('shipping_instructions'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Shipping_Instructions'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Shipping_Instructions;


FUNCTION Packing_Instructions ( p_packing_instructions IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_packing_instructions IS NULL OR
        p_packing_instructions = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_packing_instructions;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PAQCKING_INSTRUCTIONS');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('packing_instructions'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Packing_Instructions'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Packing_Instructions;



FUNCTION Under_Shipment_Tolerance ( p_under_shipment_tolerance IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN
    IF p_under_shipment_tolerance IS NULL OR
        p_under_shipment_tolerance = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_ship_tolerance_above;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'UNDER_SHIPMENT_TOLERANCE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('under_shipment_tolerance'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'under_shipment_tolerance'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Under_Shipment_Tolerance;

FUNCTION Over_Shipment_Tolerance ( p_over_shipment_tolerance IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN
    IF p_over_shipment_tolerance IS NULL OR
        p_over_shipment_tolerance = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_ship_tolerance_above;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'OVER_SHIPMENT_TOLERANCE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('over_shipment_tolerance'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'over_shipment_tolerance'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Over_Shipment_Tolerance;

FUNCTION Over_Return_Tolerance ( p_over_return_tolerance IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN
    IF p_over_return_tolerance IS NULL OR
        p_over_return_tolerance = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_ship_tolerance_above;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'OVER_RETURN_TOLERANCE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('over_return_tolerance'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'over_return_tolerance'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Over_Return_Tolerance;

FUNCTION Under_Return_Tolerance ( p_under_return_tolerance IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN
    IF p_under_return_tolerance IS NULL OR
        p_under_return_tolerance = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_ship_tolerance_above;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	    OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'UNDER_RETURN_TOLERANCE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('under_return_tolerance'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'under_return_tolerance'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Under_Return_Tolerance;

FUNCTION Transactional_Curr ( p_transactional_curr_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_transactional_curr_code IS NULL OR
        p_transactional_curr_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_FND_CURRENCIES_V
    WHERE   CURRENCY_CODE = p_transactional_curr_code
    AND     CURRENCY_FLAG = 'Y'
    AND     ENABLED_FLAG = 'Y'
    AND     SYSDATE     BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                        AND NVL(END_DATE_ACTIVE, SYSDATE);

    --  Valid Currency.



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'TRANSACTIONAL_CURR_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('transactional_curr_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transactional_Curr'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transactional_Curr;


FUNCTION Agreement ( p_agreement_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_agreement_id IS NULL OR
        p_agreement_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_AGREEMENTS_B  A
    WHERE   A.AGREEMENT_ID = p_agreement_id;

/*    AND     SYSDATE     BETWEEN NVL(A.START_DATE_ACTIVE, SYSDATE)
                        AND NVL(A.END_DATE_ACTIVE, SYSDATE); */


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'AGREEMENT_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('agreement_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;



        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Agreement'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Agreement;

FUNCTION Tax_Point ( p_tax_point_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type      	      VARCHAR2(80) :='TAX_POINT';
BEGIN


    IF p_tax_point_code IS NULL OR
        p_tax_point_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_LOOKUPS
    WHERE   LOOKUP_CODE = p_tax_point_code
    AND     LOOKUP_TYPE = l_lookup_type
    AND     ENABLED_FLAG = 'Y'
    AND     SYSDATE     BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                        AND NVL(END_DATE_ACTIVE, SYSDATE);


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'TAX_POINT_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('tax_point_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Tax_Point'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Tax_Point;

FUNCTION Cust_Po_Number ( p_cust_po_number IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_cust_po_number IS NULL OR
        p_cust_po_number = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_cust_po_number;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CUST_PO_NUMBER');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('cust_po_number'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Cust_Po_Number'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Cust_Po_Number;

FUNCTION Invoicing_Rule ( p_invoicing_rule_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_invoicing_rule_id IS NULL OR
        p_invoicing_rule_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_RA_RULES_V
    WHERE   RULE_ID = p_invoicing_rule_id
    AND     STATUS = 'A'
    AND     TYPE = 'I';



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'INVOICING_RULE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('invoicing_rule_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoicing_Rule'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoicing_Rule;


FUNCTION Payment_Term ( p_payment_term_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_payment_term_rec            OE_ORDER_CACHE.Payment_Term_Rec_Type ; -- add for bug 4200055
BEGIN


    IF p_payment_term_id IS NULL OR
        p_payment_term_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    -- added for bug 4200055
    l_payment_term_rec := OE_Order_Cache.Load_Payment_Term(p_payment_term_id);
    IF ( l_payment_term_rec.term_id <> FND_API.G_MISS_NUM AND
       l_payment_term_rec.term_id is not null AND
       l_payment_term_rec.term_id = p_payment_term_id ) THEN

         if ( trunc(nvl(l_payment_term_rec.start_date_active,sysdate)) <= trunc(sysdate)
          and trunc(nvl(l_payment_term_rec.end_date_active,sysdate)) >= trunc(sysdate))
         then
                RETURN TRUE ;
         else
                RAISE NO_DATA_FOUND ;
         end if ;
    ELSE
                RAISE NO_DATA_FOUND ;
    END IF ;

    /*SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_RA_TERMS_V
    WHERE   TERM_ID = p_payment_term_id
    AND     SYSDATE     BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                        AND NVL(END_DATE_ACTIVE, SYSDATE);

    RETURN TRUE;
    */
    --end bug 4200055

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PAYMENT_TERM_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('payment_term_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Payment_Term'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Payment_Term;

FUNCTION Planning_Priority ( p_planning_priority IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_planning_priority IS NULL OR
        p_planning_priority = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    -- Planning_Priority  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_planning_priority;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context
				 (p_attribute_code => 'PLANNING_PRIORITY');
           fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('planning_priority'));
           OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Planning_Priority'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Planning_Priority;

FUNCTION Shipping_Method ( p_shipping_method_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_shipping_method_code IS NULL OR
        p_shipping_method_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

/* this validation is being moved to entity level validation */
    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_SHIP_METHODS_V
    WHERE   lookup_code = p_shipping_method_code
    AND     ENABLED_FLAG = 'Y'
    AND     SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
    AND     NVL(END_DATE_ACTIVE, SYSDATE)
    AND     ROWNUM = 1;



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SHIPPING_METHOD_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('shipping_method_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Shipping_Method'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Shipping_Method;

FUNCTION Freight_Carrier ( p_freight_carrier_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_freight_carrier_code IS NULL OR
        p_freight_carrier_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_freight_carrier_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'FREIGHT_CARRIER_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('freight_carrier_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Freight_Carrier'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Freight_Carrier;

FUNCTION Fob_Point ( p_fob_point_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type      	      VARCHAR2(80) :='FOB';
BEGIN


    IF p_fob_point_code IS NULL OR
        p_fob_point_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_AR_LOOKUPS_V
    WHERE   LOOKUP_CODE = p_fob_point_code
    AND     LOOKUP_TYPE = l_lookup_type
    AND     ENABLED_FLAG = 'Y'
    AND     SYSDATE     BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                        AND NVL(END_DATE_ACTIVE, SYSDATE);




    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'FOB_POINT_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('fob_point_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Fob_Point'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Fob_Point;

FUNCTION Freight_Terms ( p_freight_terms_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type      	      VARCHAR2(80) :='FREIGHT_TERMS';
BEGIN


    IF p_freight_terms_code IS NULL OR
        p_freight_terms_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_LOOKUPS
    WHERE   LOOKUP_CODE = p_freight_terms_code
    AND     LOOKUP_TYPE = l_lookup_type
    AND     ENABLED_FLAG = 'Y'
    AND     SYSDATE     BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                        AND NVL(END_DATE_ACTIVE, SYSDATE);

    --  Valid Tax Exempt Reason




    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'FREIGHT_TERMS_CODE');


            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('freight_terms_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Freight_Terms'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Freight_Terms;


FUNCTION Sold_To_Org ( p_sold_to_org_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_sold_to_org_id IS NULL OR
        p_sold_to_org_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_SOLD_TO_ORGS_V
    WHERE   ORGANIZATION_ID =p_sold_to_org_id
    AND     STATUS = 'A'
    AND     SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                    AND     NVL(END_DATE_ACTIVE, SYSDATE);



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SOLD_TO_ORG_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('sold_to_org_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sold_To_Org'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sold_To_Org;

FUNCTION Sold_To_Phone ( p_sold_to_phone_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_sold_to_phone_id IS NULL OR
        p_sold_to_phone_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    HZ_CONTACT_POINTS
    WHERE   CONTACT_POINT_ID =p_sold_to_phone_id
    AND     STATUS = 'A';


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SOLD_TO_PHONE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('sold_to_phone_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sold_To_Org'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sold_To_Phone;

FUNCTION Customer ( p_customer_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_customer_id IS NULL OR
        p_customer_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_SOLD_TO_ORGS_V
    WHERE   ORGANIZATION_ID =p_customer_id
    AND     STATUS = 'A'
    AND     SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                    AND     NVL(END_DATE_ACTIVE, SYSDATE);



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CUSTOMER_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Customer_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Customer'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Customer;

FUNCTION Internal_Item ( p_internal_item_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_internal_item_id IS NULL OR
        p_internal_item_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_inventory_item_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'INTERNAL_ITEM_ID');


            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('internal_item_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'internal_item'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Internal_Item;

FUNCTION Cust_Item_Setting ( p_cust_item_setting_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_cust_item_setting_id IS NULL OR
        p_cust_item_setting_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_inventory_item_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CUST_ITEM_SETTING_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('cust_item_setting_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'cust_item_setting'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Cust_Item_Setting;

FUNCTION Ship_From_Org ( p_ship_from_org_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_ship_from_org_id IS NULL OR
        p_ship_from_org_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_ship_from_org_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SHIP_FROM_ORG_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('ship_from_org_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ship_From_Org'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ship_From_Org;

FUNCTION Subinventory ( p_subinventory IN VARCHAR2 )
RETURN BOOLEAN
IS
BEGIN


    IF p_subinventory IS NULL OR
        p_subinventory = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_ship_from_org_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SUBINVENTORY');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('subinventory'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Subinventory'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Subinventory;

FUNCTION Inventory_Org ( p_inventory_org_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_inventory_org_id IS NULL OR
        p_inventory_org_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_inventory_item_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'INVENTORY_ORG_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('inventory_org_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'inventory_org'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Inventory_Org;

FUNCTION Ship_To_Org ( p_ship_to_org_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


-- the validation should be done in record validation.


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SHIP_TO_ORG_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('ship_to_org_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ship_To_Org'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ship_To_Org;

FUNCTION Site_Use ( p_site_use_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_site_use_id IS NULL OR
        p_site_use_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_inventory_item_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SITE_USE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('site_use_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Site_Use'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Site_Use;

FUNCTION Intermed_Ship_To_Org ( p_intermed_ship_to_org_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

-- the validation should be done in record validation.


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'INTERMED_SHIP_TO_ORG_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('intermed_ship_to_org_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Intermed_Ship_To_Org'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Intermed_Ship_To_Org;

FUNCTION Invoice_To_Org ( p_invoice_to_org_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_invoice_to_rec   OE_ORDER_CACHE.Invoice_to_Org_Rec_Type ; -- add for bug 4200055
BEGIN


    IF p_invoice_to_org_id IS NULL OR
        p_invoice_to_org_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --added for bug 4200055
    l_invoice_to_rec := OE_ORDER_CACHE.Load_Invoice_To_Org(p_invoice_to_org_id);
    IF ( l_invoice_to_rec.org_id <> FND_API.G_MISS_NUM
        AND l_invoice_to_rec.org_id IS NOT NULL
        AND l_invoice_to_rec.org_id = p_invoice_to_org_id ) THEN
         if ( l_invoice_to_rec.status = 'A'
              AND l_invoice_to_rec.address_status='A'
              AND trunc(nvl(l_invoice_to_rec.start_date_active,sysdate)) <= trunc(sysdate )
              AND trunc(nvl(l_invoice_to_rec.end_date_active,sysdate)) >= trunc(sysdate)
            ) then
                RETURN TRUE ;
        else
                RAISE NO_DATA_FOUND ;
        end if ;
    ELSE
                RAISE NO_DATA_FOUND ;
    END IF ;

    /*SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_INVOICE_TO_ORGS_V   INV
    WHERE   INV.ORGANIZATION_ID =p_invoice_to_org_id
    AND     INV.STATUS = 'A'
    AND     INV.ADDRESS_STATUS ='A' --bug 2752321
    AND     SYSDATE BETWEEN NVL(INV.START_DATE_ACTIVE, SYSDATE)
                    AND     NVL(INV.END_DATE_ACTIVE, SYSDATE);

    RETURN TRUE;
    */
    --end bug 4200055


EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'INVOICE_TO_ORG_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('invoice_to_org_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoice_To_Org'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoice_To_Org;

FUNCTION Deliver_To_Org ( p_deliver_to_org_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_deliver_to_org_id IS NULL OR
        p_deliver_to_org_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_DELIVER_TO_ORGS_V   DEL
    WHERE   DEL.ORGANIZATION_ID =p_deliver_to_org_id
    AND     DEL.STATUS = 'A'
    AND     DEL.ADDRESS_STATUS ='A' --bug 2752321
    AND     SYSDATE BETWEEN NVL(DEL.START_DATE_ACTIVE, SYSDATE)
                    AND     NVL(DEL.END_DATE_ACTIVE, SYSDATE);


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'DELIVER_TO_ORG_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('deliver_to_org_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Deliver_To_Org'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Deliver_To_Org;

FUNCTION Sold_To_Contact ( p_sold_to_contact_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_sold_to_contact_id IS NULL OR
        p_sold_to_contact_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    HZ_CUST_ACCOUNT_ROLES
    WHERE   CUST_ACCOUNT_ROLE_ID = p_sold_to_contact_id
    AND     ROLE_TYPE = 'CONTACT'
    AND     STATUS = 'A';



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SOLD_TO_CONTACT_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('sold_to_contact_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sold_To_Contact'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sold_To_Contact;

FUNCTION Ship_To_Contact ( p_ship_to_contact_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_resp_type                   VARCHAR2(30);
BEGIN


    IF p_ship_to_contact_id IS NULL OR
        p_ship_to_contact_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    l_resp_type := 'SHIP_TO';

    SELECT  'VALID'
    INTO    l_dummy
    FROM    HZ_CUST_ACCOUNT_ROLES    ACCT_ROLE
    ,       HZ_ROLE_RESPONSIBILITY   ROL
    WHERE   ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_ship_to_contact_id
    AND     ACCT_ROLE.STATUS = 'A'
    AND     ACCT_ROLE.ROLE_TYPE = 'CONTACT'
    AND     ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = ROL.CUST_ACCOUNT_ROLE_ID (+)
    AND     NVL( ROL.RESPONSIBILITY_TYPE,l_resp_type)=l_resp_type;

    --  Valid ship to Contact



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SHIP_TO_CONTACT_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('ship_to_contact_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ship_To_Contact'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ship_To_Contact;

FUNCTION Intermed_Ship_To_Contact ( p_intermed_ship_to_contact_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_resp_type                   VARCHAR2(30);
BEGIN


    IF p_intermed_ship_to_contact_id IS NULL OR
        p_intermed_ship_to_contact_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    l_resp_type := 'SHIP_TO';

    SELECT  'VALID'
    INTO    l_dummy
    FROM    HZ_CUST_ACCOUNT_ROLES    ACCT_ROLE
    ,       HZ_ROLE_RESPONSIBILITY   ROL
    WHERE   ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_intermed_ship_to_contact_id
    AND     ACCT_ROLE.STATUS = 'A'
    AND     ACCT_ROLE.ROLE_TYPE = 'CONTACT'
    AND     ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = ROL.CUST_ACCOUNT_ROLE_ID (+)
    AND     NVL( ROL.RESPONSIBILITY_TYPE,l_resp_type)=l_resp_type;

    --  Valid ship to Contact



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'INTERMED_SHIP_TO_CONTACT_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('intermed_ship_to_contact_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)

        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Intermed_Ship_To_Contact'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Intermed_Ship_To_Contact;

FUNCTION Invoice_To_Contact ( p_invoice_to_contact_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_resp_type                   VARCHAR2(30);
BEGIN


    IF p_invoice_to_contact_id IS NULL OR
        p_invoice_to_contact_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    l_resp_type := 'BILL_TO';

    SELECT  'VALID'
    INTO    l_dummy
    FROM    HZ_CUST_ACCOUNT_ROLES    ACCT_ROLE
    ,       HZ_ROLE_RESPONSIBILITY   ROL
    WHERE   ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_invoice_to_contact_id
    AND     ACCT_ROLE.STATUS = 'A'
    AND     ACCT_ROLE.ROLE_TYPE = 'CONTACT'
    AND     ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = ROL.CUST_ACCOUNT_ROLE_ID (+)
    AND     NVL( ROL.RESPONSIBILITY_TYPE,l_resp_type)=l_resp_type;

    RETURN TRUE;

EXCEPTION
    WHEN TOO_MANY_ROWS THEN
        RETURN TRUE;

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'INVOICE_TO_CONTACT_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('invoice_to_contact_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoice_To_Contact'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoice_To_Contact;

FUNCTION Deliver_To_Contact ( p_deliver_to_contact_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_deliver_to_contact_id IS NULL OR
        p_deliver_to_contact_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    HZ_CUST_ACCOUNT_ROLES                ACCT_ROLE
    ,       HZ_ROLE_RESPONSIBILITY           ROL
    WHERE   ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_deliver_to_contact_id
    AND     ACCT_ROLE.STATUS = 'A'
    AND     ACCT_ROLE.ROLE_TYPE = 'CONTACT'
    AND     ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = ROL.CUST_ACCOUNT_ROLE_ID (+)
    AND     NVL( ROL.RESPONSIBILITY_TYPE,'DELIVER_TO') in ('DELIVER_TO','SHIP_TO');

    --  Valid deliver to Contact


    RETURN TRUE;

EXCEPTION
    WHEN TOO_MANY_ROWS THEN
        RETURN TRUE;
    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'DELIVER_TO_CONTACT_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('deliver_to_contact_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Deliver_To_Contact'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Deliver_To_Contact;



FUNCTION Last_Updated_By ( p_last_updated_by IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_last_updated_by IS NULL OR
        p_last_updated_by = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_last_updated_by;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LAST_UPDATED_BY');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('last_updated_by'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Last_Updated_By'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Last_Updated_By;

FUNCTION Last_Update_Date ( p_last_update_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_last_update_date IS NULL OR
        p_last_update_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_last_update_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LAST_UPDATE_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('last_update_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Last_Update_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Last_Update_Date;

FUNCTION Last_Update_Login ( p_last_update_login IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_last_update_login IS NULL OR
        p_last_update_login = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_last_update_login;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LAST_UPDATE_LOGIN');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('last_update_login'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Last_Update_Login'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Last_Update_Login;

FUNCTION Program_Application ( p_program_application_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_program_application_id IS NULL OR
        p_program_application_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_program_application_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PROGRAM_APPLICATION_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('program_application_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Program_Application'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Program_Application;

FUNCTION Program ( p_program_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_program_id IS NULL OR
        p_program_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_program_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PROGRAM_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('program_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Program'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Program;

FUNCTION Program_Update_Date ( p_program_update_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_program_update_date IS NULL OR
        p_program_update_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_program_update_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PROGRAM_UPDATE_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('program_update_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Program_Update_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Program_Update_Date;

FUNCTION Request ( p_request_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_request_id IS NULL OR
        p_request_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_request_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'REQUEST_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('request_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Request'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Request;

FUNCTION Global_Attribute1 ( p_global_attribute1 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_global_attribute1 IS NULL OR
        p_global_attribute1 = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_global_attribute1;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'GLOBAL_ATTRIBUTE1');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('global_attribute1'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Global_Attribute1'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Global_Attribute1;


FUNCTION Price_Adjustment ( p_price_adjustment_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_price_adjustment_id IS NULL OR
        p_price_adjustment_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_adjustment_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PRICE_ADJUSTMENT_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('price_adjustment_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_Adjustment'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_Adjustment;

FUNCTION Discount ( p_discount_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_discount_id IS NULL OR
        p_discount_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_discount_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'DISCOUNT_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('discount_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Discount'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Discount;

FUNCTION Discount_Line ( p_discount_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_discount_line_id <> -1 OR
        p_discount_line_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;


    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_discount_line_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'DISCOUNT_LINE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('discount_line_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Discount_Line'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Discount_Line;

FUNCTION Automatic ( p_automatic_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_automatic_flag IS NULL OR
        p_automatic_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_automatic_flag;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'AUTOMATIC_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('automatic_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Automatic'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Automatic;

FUNCTION Percent ( p_percent IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


   -- All attribute validation being turned on
--   IF p_percent IS NULL OR
--     p_percent = FND_API.g_miss_num
--     THEN
--      RETURN TRUE;
--    ELSIF p_percent = 0
--      THEN
--      RETURN FALSE;
--   END IF;


   RETURN TRUE;

/*
    IF p_percent IS NULL OR
        p_percent = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_percent;

    RETURN TRUE;
*/
EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PERCENT');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('percent'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Percent'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Percent;

FUNCTION Line ( p_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_line_id IS NULL OR
        p_line_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_line_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LINE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('line_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Line;


FUNCTION Applied_Flag ( p_Applied_Flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_Applied_Flag IS NULL OR
        p_Applied_Flag = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

	   if p_applied_flag not in ('Y','N') then

        RAISE NO_DATA_FOUND;
     End if;

        RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'APPLIED_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Applied_Flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Applied_Flag'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Applied_Flag;



FUNCTION Change_Reason_Code(p_Change_Reason_Code IN VARCHAR2) RETURN BOOLEAN
IS
l_dummy  VARCHAR2(10);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_lookup_type      	      VARCHAR2(80) :='CANCEL_CODE';
BEGIN

    IF  p_Change_Reason_Code IS NULL OR
        p_Change_Reason_Code = FND_API.G_MISS_CHAR OR
        upper(p_Change_Reason_Code)='SYSTEM' OR
        upper(p_Change_Reason_Code)='CONFIGURATOR' THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_LOOKUPS
    WHERE   LOOKUP_CODE = p_change_reason_code
    AND     LOOKUP_TYPE = l_lookup_type
    AND     ENABLED_FLAG = 'Y'
    AND     SYSDATE  BETWEEN NVL(START_DATE_ACTIVE, SYSDATE) AND NVL(END_DATE_ACTIVE, SYSDATE);

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.add('Change/Cancel Reason Code is invalid ',1);
            OE_DEBUG_PUB.add('Error Message at 1 : '||sqlerrm,1);
         END IF;
         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CHANGE_REASON_CODE');
            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE', OE_Order_Util.Get_Attribute_Name('Change_Reason_Code'));
            OE_MSG_PUB.Add;
	    OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);
         END IF;
         RETURN FALSE;
    WHEN OTHERS THEN
         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.add('Change/Cancel Reason Code is invalid ',1);
            OE_DEBUG_PUB.add('Error Message at 2 : '||sqlerrm,1);
         END IF;
         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME ,   'Change_Reason_Code');
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Change_Reason_Code;


FUNCTION Change_Reason_Text(p_Change_Reason_Text IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_Change_Reason_Text IS NULL OR
        p_Change_Reason_Text = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CHANGE_REASON_TEXT');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Change_Reason_Text'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Reason_Text'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Change_Reason_Text;


FUNCTION List_Header_id(p_List_Header_id IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_List_Header_id IS NULL OR
        p_List_Header_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_adjustment_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LIST_HEADER_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('List_Header_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'List_Header_id'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END List_Header_id;


FUNCTION List_Line_id(p_List_Line_id IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_List_Line_id IS NULL OR
        p_List_Line_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_adjustment_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LIST_LINE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('List_Line_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'List_Line_id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END List_Line_id;


FUNCTION  List_Line_Type_code(p_List_Line_Type_code IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_List_Line_Type_code IS NULL OR
        p_List_Line_Type_code = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_adjustment_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LIST_LINE_TYPE_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('List_Line_Type_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'List_Line_Type_code'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END List_Line_Type_code;


FUNCTION Modified_From(p_Modified_From IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_Modified_From IS NULL OR
        p_Modified_From = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_adjustment_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'MODIFIED_FROM');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Modified_From'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Modified_From'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Modified_From;

FUNCTION Modified_To(p_Modified_To IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_Modified_To IS NULL OR
        p_Modified_To = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_adjustment_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'MODIFIED_TO');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Modified_To'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Modified_To'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Modified_To;


FUNCTION  Modifier_mechanism_type_code(p_Modifier_mechanism_type_code IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_Modifier_mechanism_type_code IS NULL OR
        p_Modifier_mechanism_type_code = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_adjustment_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'MODIFIER_MECHANISM_TYPE_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Modifier_mechanism_type_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Modifier_mechanism_type_code'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Modifier_mechanism_type_code;



FUNCTION Updated_Flag(p_Updated_Flag IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_Updated_Flag IS NULL OR
        p_Updated_Flag = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_adjustment_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'UPDATED_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Updated_Flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Updated_Flag'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Updated_Flag;


FUNCTION Update_Allowed(p_Update_Allowed IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_Update_Allowed IS NULL OR
        p_Update_Allowed = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_price_adjustment_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'UPDATE_ALLOWED');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Update_Allowed'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Allowed'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Allowed;

FUNCTION Sales_Credit ( p_sales_credit_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_sales_credit_id IS NULL OR
        p_sales_credit_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_sales_credit_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SALES_CREDIT_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('sales_credit_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sales_Credit'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sales_Credit;

FUNCTION Sales_credit_type ( p_Sales_credit_type_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
cursor c_Sales_credit_type( p_Sales_credit_type_id IN number) is
       select 'VALID'
       from oe_sales_credit_types
       where Sales_credit_type_id = p_Sales_credit_type_id;
BEGIN


    IF p_Sales_credit_type_id IS NULL OR
        p_Sales_credit_type_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    OPEN c_Sales_credit_type(p_Sales_credit_type_id);
    FETCH c_Sales_credit_type into l_dummy;
    CLOSE c_Sales_credit_type;
    IF l_dummy = 'VALID' then

       RETURN TRUE;
    ELSE
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Sales_credit_type_id');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Sales_credit_type_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;

       RETURN FALSE;
    END IF;
EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sales_credit_type'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sales_credit_type;

FUNCTION Salesrep ( p_salesrep_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_is_salesrep_active          VARCHAR2(10);
l_org_id  NUMBER;
l_salesrep_rec_type    OE_Order_Cache.Salesrep_Rec_type ; -- add for bug 4200055

-- comment out for bug 4200055
/*cursor c_salesrep( p_salesrep_id IN number) is
       select  'VALID'
       from ra_salesreps --Bug 3358986.Changed ra_salesreps_all to ra_salesreps
       where salesrep_id = p_salesrep_id
       and sysdate between NVL(start_date_active,sysdate)
       and NVL(end_date_active,sysdate);
*/

cursor c_jtf_salesrep(p_salesrep_id IN number) is
       select /* MOAC_SQL_CHANGE */ 'VALID'
       from jtf_rs_salesreps jrs,
            jtf_rs_resource_extns b
       where jrs.salesrep_id = p_salesrep_id
       and jrs.resource_id = b.resource_id
       and b.category in ('EMPLOYEE','OTHER','PARTY','PARTNER','SUPPLIER_CONTACT')
       and jrs.org_id =l_org_id
       and sysdate between nvl(jrs.start_date_active,sysdate)
                   and nvl(jrs.end_date_active,sysdate);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
   l_org_id :=mo_global.get_current_org_id ; --for MOAC SQL Changes
   IF p_salesrep_id IS NULL OR
        p_salesrep_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    Begin

      --added for bug 4200055
      l_salesrep_rec_type := OE_Order_Cache.Load_Salesrep_Rec(p_salesrep_id);
      IF (l_salesrep_rec_type.salesrep_id is not null
      AND l_salesrep_rec_type.salesrep_id = p_salesrep_id ) THEN
           if nvl(l_salesrep_rec_type.start_date_active,sysdate) <= sysdate
            and nvl(l_salesrep_rec_type.end_date_active,sysdate) >= sysdate
           then
                l_is_salesrep_active := 'VALID' ;
           end if ;
      END IF ;

      /*OPEN c_salesrep(p_salesrep_id);
      FETCH c_salesrep into l_dummy;
      CLOSE c_salesrep;
      */
      --end bug 4200055


      -- bug 5022615
      IF l_is_salesrep_active = 'VALID' THEN
        --Now check for RTF salesrep table
        IF l_debug_level > 0 THEN
            oe_debug_pub.add(' Checking rtf 1');
        END IF;
        OPEN  c_jtf_salesrep(p_salesrep_id);
        FETCH c_jtf_salesrep into l_dummy;
        CLOSE c_jtf_salesrep;


        IF l_dummy = 'VALID' then

          RETURN TRUE;
        ELSE
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
           THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SALESREP_ID');

              fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('salesrep_id'));
              OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

           END IF;
           IF l_debug_level > 0 THEN
              oe_debug_pub.add(' rtf failed 1');
           END IF;
           RETURN FALSE;
         END IF;
    ELSE  -- if salesrep is inactive
       RETURN FALSE;
     END IF;

  Exception
    When no_data_found then
      IF l_debug_level > 0 THEN
          oe_debug_pub.add('checking rtf 2');
      END IF;
      OPEN  c_jtf_salesrep(p_salesrep_id);
      FETCH c_jtf_salesrep into l_dummy;
      CLOSE c_jtf_salesrep;

        IF l_dummy = 'VALID' then
          RETURN TRUE;
        ELSE
          IF l_debug_level > 0 THEN
              oe_debug_pub.add(' rtf failed 2');
          END IF;
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
           THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SALESREP_ID');

              fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('salesrep_id'));
              OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

           END IF;
         END IF;

       RETURN FALSE;

  End;
EXCEPTION

    WHEN no_data_found Then
        OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SALESREP_ID');
        fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('salesrep_id'));
        OE_MSG_PUB.Add;
        OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);
        Return FALSE;
    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Salesrep'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Salesrep;

FUNCTION Dw_Update_Advice ( p_dw_update_advice_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_dw_update_advice_flag IS NULL OR
        p_dw_update_advice_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_dw_update_advice_flag;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'DW_UPDATE_ADVICE_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('dw_update_advice_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Dw_Update_Advice'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Dw_Update_Advice;

FUNCTION Wh_Update_Date ( p_wh_update_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_wh_update_date IS NULL OR
        p_wh_update_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_wh_update_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'WH_UPDATE_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('wh_update_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Wh_Update_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Wh_Update_Date;


FUNCTION Line_Type ( p_line_type_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_line_type_id IS NULL OR
        p_line_type_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --changes for bug 4200055
    IF (OE_Order_Cache.g_line_type_rec.line_type_id =  FND_API.G_MISS_NUM)
       OR (OE_Order_Cache.g_line_type_rec.line_type_id <> p_line_type_id) THEN
          OE_Order_Cache.Load_Line_type(p_line_type_id) ;
    END IF ;

    IF (OE_Order_Cache.g_line_type_rec.line_type_id <> FND_API.G_MISS_NUM)
          AND (OE_Order_Cache.g_line_type_rec.line_type_id IS NOT NULL )
          AND (OE_Order_Cache.g_line_type_rec.line_type_id = p_line_type_id) THEN
             if ( (nvl(OE_Order_Cache.g_line_type_rec.Start_Date_Active,trunc(sysdate)) <= trunc(sysdate))
                and (nvl(OE_Order_Cache.g_line_type_rec.End_Date_Active,trunc(sysdate)) >= trunc(sysdate))
                ) then
                       RETURN TRUE ;
            else
                       RAISE NO_DATA_FOUND ;
            end if ;
    ELSE
                       RAISE NO_DATA_FOUND ;

    END IF ;

    /* SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_LINE_TYPES_V
    WHERE   LINE_TYPE_ID = p_line_type_id
    AND     SYSDATE BETWEEN NVL( START_DATE_ACTIVE, SYSDATE  )
                     AND     NVL( END_DATE_ACTIVE, SYSDATE );

    RETURN TRUE;
     */
    --end bug 4200055


EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LINE_TYPE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('line_type_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line_Type'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Line_Type;

FUNCTION Line_Number ( p_line_number IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_line_number IS NULL OR
        p_line_number = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_line_number;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LINE_NUMBER');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('line_number'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line_Number'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Line_Number;

FUNCTION Ordered_Item_id ( p_ordered_item_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_ordered_item_id IS NULL OR
        p_ordered_item_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_ordered_item_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ORDERED_ITEM_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('ordered_item_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ordered_Item_Id'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ordered_Item_Id;

FUNCTION Item_Identifier_Type ( p_item_identifier_type IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_item_identifier_type IS NULL OR
        p_item_identifier_type = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_item_identifier_type;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ITEM_IDENTIFIER_TYPE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('item_identifier_type'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Item_Identifier_Type'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Item_Identifier_Type;

FUNCTION Ordered_Item ( p_ordered_item IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_ordered_item IS NULL OR
        p_ordered_item = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_ordered_item;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ORDERED_ITEM');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('ordered_item'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ordered_Item'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ordered_Item;

FUNCTION Date_And_Time_Requested ( p_date_and_time_requested IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_date_and_time_requested IS NULL OR
        p_date_and_time_requested = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_date_and_time_requested;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'DATE_AND_TIME_REQUESTED');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('date_and_time_requested'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Date_And_Time_Requested'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Date_And_Time_Requested;

FUNCTION Date_And_Time_Promised ( p_date_and_time_promised IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_date_and_time_promised IS NULL OR
        p_date_and_time_promised = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_date_and_time_promised;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'DATE_AND_TIME_PROMISED');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('date_and_time_promised'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Date_And_Time_Promised'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Date_And_Time_Promised;

FUNCTION Date_And_Time_Scheduled ( p_date_and_time_scheduled IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_date_and_time_scheduled IS NULL OR
        p_date_and_time_scheduled = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_date_and_time_scheduled;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'DATE_AND_TIME_SCHEDULED');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('date_and_time_scheduled'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Date_And_Time_Scheduled'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Date_And_Time_Scheduled;

FUNCTION Order_Quantity_Uom ( p_order_quantity_uom IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_order_quantity_uom IS NULL OR
        p_order_quantity_uom = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_order_quantity_uom;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ORDER_QUANTITY_UOM');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('order_quantity_uom'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Order_Quantity_Uom'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Order_Quantity_Uom;

-- OPM 02/JUN/00 - add functions to support new process attributes
-- ===============================================================
FUNCTION Ordered_Quantity_Uom2 ( p_ordered_quantity_uom2 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_ordered_quantity_uom2 IS NULL OR
        p_ordered_quantity_uom2 = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ORDERED_QUANTITY_UOM2');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('ordered_quantity_uom2'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ordered_Quantity_Uom2'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ordered_Quantity_Uom2;

FUNCTION Preferred_Grade ( p_preferred_grade IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

    IF l_debug_level > 0 THEN
        oe_debug_pub.add('OPM preferred_grade val in OEXSVATB', 1);
    END IF;
    IF p_preferred_grade IS NULL OR
        p_preferred_grade = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

-- INVCONV

    SELECT  'VALID'
    INTO    l_dummy
    FROM    MTL_GRADES_B
    WHERE   grade_code  = p_preferred_grade -- INVCONV
    AND     DISABLE_FLAG <> 'Y'; -- INVCONV

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PREFERRED_GRADE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('preferred_grade'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            IF l_debug_level > 0 THEN
                oe_debug_pub.add('OPM preferred_grade exception in VATB', 1);
            END IF;
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Preferred_Grade'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Preferred_Grade;

-- OPM 02/JUN/00 END
-- =================

-- PROMOTIONS SEP/01 BEGIN
-- =======================
FUNCTION Price_Request_Code (p_price_request_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_price_request_code IS NULL OR
        p_price_request_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PRICE_REQUEST_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('price_request_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_Request_Code'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_Request_Code;

-- PROMOTIONS SEP/01 END
-- =====================
FUNCTION Pricing_Quantity ( p_pricing_quantity IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_pricing_quantity IS NULL OR
        p_pricing_quantity = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_quantity;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PRICING_QUANTITY');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('pricing_quantity'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Quantity'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Quantity;

FUNCTION Pricing_Quantity_Uom ( p_pricing_quantity_uom IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_pricing_quantity_uom IS NULL OR
        p_pricing_quantity_uom = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_quantity_uom;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PRICING_QUANTITY_UOM');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('pricing_quantity_uom'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Quantity_Uom'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Quantity_Uom;

FUNCTION Quantity_Cancelled ( p_quantity_cancelled IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_quantity_cancelled IS NULL OR
        p_quantity_cancelled = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_quantity_cancelled;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'QUANTITY_CANCELLED');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('quantity_cancelled'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Quantity_Cancelled'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Quantity_Cancelled;

FUNCTION Quantity_Shipped ( p_quantity_shipped IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_quantity_shipped IS NULL OR
        p_quantity_shipped = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_quantity_shipped;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'QUANTITY_SHIPPED');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('quantity_shipped'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Quantity_Shipped'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Quantity_Shipped;

FUNCTION Quantity_Ordered ( p_quantity_ordered IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_quantity_ordered IS NULL OR
        p_quantity_ordered = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_quantity_ordered;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'QUANTITY_ORDERED');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('quantity_ordered'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Quantity_Ordered'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Quantity_Ordered;

FUNCTION Quantity_Fulfilled ( p_quantity_fulfilled IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_quantity_fulfilled IS NULL OR
        p_quantity_fulfilled = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_quantity_fulfilled;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'QUANTITY_FULFILLED');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('quantity_fulfilled'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Quantity_Fulfilled'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Quantity_Fulfilled;

FUNCTION fulfilled ( p_fulfilled_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_fulfilled_flag IS NULL OR
        p_fulfilled_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    IF p_fulfilled_flag NOT IN ('Y','N') THEN
		RAISE NO_DATA_FOUND;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_fulfilled_flag;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'FULFILLED_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('fulfilled_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Fulfilled'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Fulfilled;

----
FUNCTION Calculate_Price_Flag ( p_calculate_price_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_calculate_price_flag IS NULL OR
        p_calculate_price_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    If p_calculate_price_flag not in ('P','Y','N') then

	Raise no_data_found;

    End If;
    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_fulfillment_method_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CALCULATE_PRICE_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('calculate_price_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Calculate_Price_Flag'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Calculate_Price_Flag;

-----
FUNCTION Fulfillment_Method ( p_fulfillment_method_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_fulfillment_method_code IS NULL OR
        p_fulfillment_method_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_fulfillment_method_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'FULFILLMENT_METHOD_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('fulfillment_method_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Fulfillment_Method'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Fulfillment_Method;

FUNCTION Fulfillment_Date ( p_fulfillment_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_fulfillment_date IS NULL OR
        p_fulfillment_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_fulfillment_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'FULFILLMENT_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('fulfillment_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Fulfillment_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Fulfillment_Date;

FUNCTION Shipping_Quantity ( p_shipping_quantity IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_shipping_quantity IS NULL OR
        p_shipping_quantity = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_shipping_quantity;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SHIPPING_QUANTITY');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('shipping_quantity'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Shipping_Quantity'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Shipping_Quantity;

FUNCTION Shipping_Quantity_Uom ( p_shipping_quantity_uom IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_shipping_quantity_uom IS NULL OR
        p_shipping_quantity_uom = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_shipping_quantity_uom;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SHIPPING_QUANTITY_UOM');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('shipping_quantity_uom'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Shipping_Quantity_Uom'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Shipping_Quantity_Uom;

FUNCTION Delivery_Lead_Time ( p_delivery_lead_time IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_delivery_lead_time IS NULL OR
        p_delivery_lead_time = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_delivery_lead_time;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'DELIVERY_LEAD_TIME');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('delivery_lead_time'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delivery_Lead_Time'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delivery_Lead_Time;

FUNCTION Demand_Bucket_Type ( p_demand_bucket_type IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_demand_bucket_type IS NULL OR
        p_demand_bucket_type = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_demand_bucket_type;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'DEMAND_BUCKET_TYPE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('demand_bucket_type'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Demand_Bucket_Type'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Demand_Bucket_Type;

FUNCTION Schedule_Item_Detail ( p_schedule_item_detail_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_schedule_item_detail_id IS NULL OR
        p_schedule_item_detail_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_schedule_item_detail_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SCHEDULE_ITEM_DETAIL_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('schedule_item_detail_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule_Item_Detail'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Schedule_Item_Detail;

FUNCTION Demand_Stream ( p_demand_stream_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_demand_stream_id IS NULL OR
        p_demand_stream_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_demand_stream_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'DEMAND_STREAM_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('demand_stream_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Demand_Stream'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Demand_Stream;

FUNCTION Cust_Dock ( p_cust_dock_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_cust_dock_code IS NULL OR
        p_cust_dock_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_cust_dock_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CUST_DOCK_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('cust_dock_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Cust_Dock'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Cust_Dock;

FUNCTION Cust_Job ( p_cust_job IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_cust_job IS NULL OR
        p_cust_job = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_cust_job;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CUST_JOB');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('cust_job'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Cust_Job'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Cust_Job;

FUNCTION Cust_Production_Line ( p_cust_production_line IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_cust_production_line IS NULL OR
        p_cust_production_line = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_cust_production_line;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CUST_PRODUCTION_LINE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('cust_production_line'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Cust_Production_Line'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Cust_Production_Line;

FUNCTION Cust_Model_Serial_Number ( p_cust_model_serial_number IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_cust_model_serial_number IS NULL OR
        p_cust_model_serial_number = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_cust_model_serial_number;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CUST_MODEL_SERIAL_NUMBER');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('cust_model_serial_number'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Cust_Model_Serial_Number'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Cust_Model_Serial_Number;

FUNCTION Planning_Prod_Seq_No ( p_planning_prod_seq_no IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_planning_prod_seq_no IS NULL OR
        p_planning_prod_seq_no = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_planning_prod_seq_no;


   RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PLANNING_PROD_SEQ_NO');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('planning_prod_seq_no'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


       RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Planning_Prod_Seq_No'
            );
        END IF;


      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Planning_Prod_Seq_No;

FUNCTION Project ( p_project_id IN NUMBER )
RETURN BOOLEAN
IS
l_project         VARCHAR2(30) := NULL;
BEGIN

    IF p_project_id IS NULL OR
        p_project_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;
/*
      SELECT  'VALID'
      INTO     l_dummy
      FROM     pjm_projects_org_v
      WHERE    project_id = p_project_id
	 AND      rownum = 1;
*/

    l_project := pjm_project.val_proj_idtonum(p_project_id);

    IF l_project IS NOT NULL THEN

       RETURN TRUE;

    ELSE

	  RAISE NO_DATA_FOUND;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PROJECT_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('project_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Project'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Project;

FUNCTION Task ( p_task_id IN NUMBER )
RETURN BOOLEAN
IS
l_task          VARCHAR2(30);
BEGIN

-- Validation will be done at Entity level.

    IF p_task_id IS NULL OR
        p_task_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

--      SELECT  'VALID'
--      INTO     l_dummy
--      FROM     mtl_task_v
--      WHERE    task_id = p_task_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'TASK_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('task_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Task'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Task;

FUNCTION Inventory_Item ( p_inventory_item_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_inventory_item_id IS NULL OR
        p_inventory_item_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_inventory_item_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'INVENTORY_ITEM_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('inventory_item_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Inventory_Item'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Inventory_Item;


FUNCTION Tax_Date ( p_tax_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_tax_date IS NULL OR
        p_tax_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_tax_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'TAX_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('tax_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Tax_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Tax_Date;


FUNCTION Pricing_Date ( p_pricing_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_pricing_date IS NULL OR
        p_pricing_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_pricing_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PRICING_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('pricing_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pricing_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Pricing_Date;

FUNCTION Shipment_Number ( p_shipment_number IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_shipment_number IS NULL OR
        p_shipment_number = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_shipment_number;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SHIPMENT_NUMBER');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('shipment_number'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Shipment_Number'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Shipment_Number;

FUNCTION Orig_Sys_Line_Ref ( p_orig_sys_line_ref IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_orig_sys_line_ref IS NULL OR
        p_orig_sys_line_ref = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_orig_sys_line_ref;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ORIG_SYS_LINE_REF');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('orig_sys_line_ref'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Orig_Sys_Line_ref'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Orig_Sys_Line_Ref;

FUNCTION Source_Document_Line ( p_source_document_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_source_document_line_id IS NULL OR
        p_source_document_line_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_source_document_line_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SOURCE_DOCUMENT_LINE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('source_document_line_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Source_Document_Line'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Source_Document_Line;

FUNCTION Reference_Line ( p_reference_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_reference_line_id IS NULL OR
        p_reference_line_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_reference_line_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'REFERENCE_LINE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('reference_line_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Reference_Line'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Reference_Line;

FUNCTION Reference_Type ( p_reference_type IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN



    IF p_reference_type IS NULL OR
        p_reference_type = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_reference_type;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'REFERENCE_TYPE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('reference_type'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Reference_Type'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Reference_Type;

FUNCTION Reference_Header ( p_reference_header_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_reference_header_id IS NULL OR
        p_reference_header_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_reference_header_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'REFERENCE_HEADER_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('reference_header_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Reference_Header'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Reference_Header;



FUNCTION Revision ( p_revision IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_revision IS NULL OR
        p_revision = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_revision;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'REVISION');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('revision'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Revision'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Revision;

FUNCTION Unit_Selling_Price ( p_unit_selling_price IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_unit_selling_price IS NULL OR
        p_unit_selling_price = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_unit_selling_price;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'UNIT_SELLING_PRICE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('unit_selling_price'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Unit_Selling_Price'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Unit_Selling_Price;


FUNCTION Unit_Selling_Price_Per_Pqty ( p_unit_selling_price_per_pqty IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_unit_selling_price_per_pqty IS NULL OR
        p_unit_selling_price_per_pqty = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_unit_selling_price_per_pqty;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'UNIT_SELLING_PRICE_PER_PQTY');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('unit_selling_price_per_pqty'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Unit_Selling_Price_Per_Pqty'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Unit_Selling_Price_Per_Pqty;


FUNCTION Unit_List_Price ( p_unit_list_price IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_unit_list_price IS NULL OR
        p_unit_list_price = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_unit_list_price;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'UNIT_LIST_PRICE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('unit_list_price'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Unit_List_Price'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Unit_List_Price;

FUNCTION Unit_List_Price_Per_Pqty ( p_unit_list_price_per_pqty IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_unit_list_price_per_pqty IS NULL OR
        p_unit_list_price_per_pqty = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_unit_list_price_per_pqty;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'UNIT_LIST_PRICE_PER_PQTY');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('unit_list_price_per_pqty'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Unit_List_Price_Per_Pqty'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Unit_List_Price_Per_Pqty;

FUNCTION Tax_Value ( p_tax_value IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_tax_value IS NULL OR
        p_tax_value = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_tax_value;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'TAX_VALUE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('tax_value'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Tax_Value'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Tax_Value;




FUNCTION Order_Number_Source ( p_order_number_source_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_order_number_source_id IS NULL OR
        p_order_number_source_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_order_number_source_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ORDER_NUMBER_SOURCE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('order_number_source_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Order_Number_Source'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Order_Number_Source;

FUNCTION Name ( p_name IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_name IS NULL OR
        p_name = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_name;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'NAME');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('name'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Name'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Name;

FUNCTION Sequence_Starting_Point ( p_sequence_starting_point IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_sequence_starting_point IS NULL OR
        p_sequence_starting_point = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_sequence_starting_point;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SEQUENCE_STARTING_POINT');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('sequence_starting_point'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sequence_Starting_Point'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sequence_Starting_Point;

FUNCTION Description ( p_description IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_description IS NULL OR
        p_description = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_description;



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'DESCRIPTION');


            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('description'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Description'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Description;

/* FUNCTION Start_Date_Active ( p_start_date_active IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_start_date_active IS NULL OR
        p_start_date_active = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_start_date_active;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'START_DATE_ACTIVE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('start_date_active'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Start_Date_Active'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Start_Date_Active; */

FUNCTION End_Date_Active ( p_end_date_active IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_end_date_active IS NULL OR
        p_end_date_active = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_end_date_active;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'END_DATE_ACTIVE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('end_date_active'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'End_Date_Active'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END End_Date_Active;

Function SALES_CREDIT_PERCENT( p_percent IN Number) Return Boolean
IS
BEGIN


  OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PERCENT');


  IF p_percent = FND_API.G_MISS_NUM THEN

     RETURN TRUE;
  END IF;

  IF P_Percent < 0 OR P_Percent > 100 THEN
       fnd_message.set_name('ONT','OE_INVALID_CREDIT_PERCENT');
       OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

       RETURN FALSE;
  ELSE

     RETURN TRUE;
  END IF;


END SALES_CREDIT_PERCENT;

FUNCTION Configuration ( p_configuration_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_configuration_id IS NULL OR
        p_configuration_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_configuration_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CONFIGURATION_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('configuration_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Configuration'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Configuration;

FUNCTION Top_Model_Line ( p_top_model_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_top_model_line_id IS NULL OR
        p_top_model_line_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_top_model_line_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'TOP_MODEL_LINE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('top_model_line_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Top_Model_Line'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Top_Model_Line;

FUNCTION Link_To_Line ( p_link_to_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_link_to_line_id IS NULL OR
        p_link_to_line_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_link_to_line_id;


   RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LINK_TO_LINE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('LINK_TO_LINE_ID'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Link_To_Line'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Link_To_Line;

FUNCTION Component_Sequence ( p_component_sequence_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_component_sequence_id IS NULL OR
        p_component_sequence_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_component_sequence_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'COMPONENT_SEQUENCE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('COMPONENT_SEQUENCE_ID'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Component_Sequence'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Component_Sequence;

FUNCTION Config_Header ( p_config_header_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_config_header_id IS NULL OR
        p_config_header_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_config_header_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CONFIG_HEADER');

           fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('CONFIG_HEADER_ID'));
           OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Config_Header'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Config_Header;

FUNCTION Config_Rev_Nbr ( p_config_rev_nbr IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_config_rev_nbr IS NULL OR
        p_config_rev_nbr = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_config_rev_nbr;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CONFIG_REV_NBR');

           fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('CONFIG_REV_NBR'));
           OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Config_Rev_Nbr'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Config_Rev_Nbr;

FUNCTION Component ( p_component_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_component_code IS NULL OR
        p_component_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_component_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'COMPONENT_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Component_Code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Component'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Component;

FUNCTION Config_Display_Sequence ( p_config_display_sequence IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_config_display_sequence IS NULL OR
        p_config_display_sequence = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_config_display_sequence;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CONFIG_DISPLAY_SEQUENCE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('CONFIG_DISPLAY_SEQUENCE'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Config_Display_Sequence'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Config_Display_Sequence;

FUNCTION Sort_Order ( p_sort_order IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_sort_order IS NULL OR
        p_sort_order = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_sort_order;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SORT_ORDER');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Sort_Order'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sort_Order'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sort_Order;

FUNCTION Oe_Item_Type ( p_oe_item_type IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_oe_item_type IS NULL OR
        p_oe_item_type = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_oe_item_type;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'OE_ITEM_TYPE');
            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Oe_Item_Type'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Item_Type'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Oe_Item_Type;

FUNCTION Option_Number ( p_option_number IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN



    IF p_option_number IS NULL OR
        p_option_number = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_option_number;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'OPTION_NUMBER');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Option_Number'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Option_Number'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Option_Number;

FUNCTION Component_Number ( p_component_number IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_component_number IS NULL OR
        p_component_number = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_component_number;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'COMPONENT_NUMBER');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Component_Number'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);


        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Component_Number'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Component_Number;


FUNCTION Explosion_Date ( p_explosion_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'EXPLOSION_DATE');

    IF p_explosion_date IS NULL OR
        p_explosion_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_explosion_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'EXPLOSION_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('explosion_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Explosion_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Explosion_Date;


FUNCTION Line_Category_Code(line_category_code IN VARCHAR2)
RETURN BOOLEAN
IS
BEGIN
    RETURN TRUE;
END Line_Category_Code;

FUNCTION Reference_Cust_Trx_Line_Id(reference_cust_trx_line_id IN NUMBER)
RETURN BOOLEAN
IS
BEGIN
    RETURN TRUE;
END Reference_Cust_Trx_Line_Id;

FUNCTION RMA_CONTEXT(rma_context IN VARCHAR2)
RETURN BOOLEAN
IS
BEGIN
    RETURN TRUE;
END RMA_CONTEXT;

FUNCTION RMA_ATTRIBUTE1(rma_attribute1 IN VARCHAR2)
RETURN BOOLEAN
IS
BEGIN
    RETURN TRUE;
END RMA_ATTRIBUTE1;

FUNCTION RMA_ATTRIBUTE2(rma_attribute2 IN VARCHAR2)
RETURN BOOLEAN
IS
BEGIN
    RETURN TRUE;
END RMA_ATTRIBUTE2;

FUNCTION RMA_ATTRIBUTE3(rma_attribute3 IN VARCHAR2)
RETURN BOOLEAN
IS
BEGIN
    RETURN TRUE;
END RMA_ATTRIBUTE3;

FUNCTION RMA_ATTRIBUTE4(rma_attribute4 IN VARCHAR2)
RETURN BOOLEAN
IS
BEGIN
    RETURN TRUE;
END RMA_ATTRIBUTE4;

FUNCTION RMA_ATTRIBUTE5(rma_attribute5 IN VARCHAR2)
RETURN BOOLEAN
IS
BEGIN
    RETURN TRUE;
END RMA_ATTRIBUTE5;

FUNCTION RMA_ATTRIBUTE6(rma_attribute6 IN VARCHAR2)
RETURN BOOLEAN
IS
BEGIN
    RETURN TRUE;
END RMA_ATTRIBUTE6;

FUNCTION RMA_ATTRIBUTE7(rma_attribute7 IN VARCHAR2)
RETURN BOOLEAN
IS
BEGIN
    RETURN TRUE;
END RMA_ATTRIBUTE7;

FUNCTION RMA_ATTRIBUTE8(rma_attribute8 IN VARCHAR2)
RETURN BOOLEAN
IS
BEGIN
    RETURN TRUE;
END RMA_ATTRIBUTE8;

FUNCTION RMA_ATTRIBUTE9(rma_attribute9 IN VARCHAR2)
RETURN BOOLEAN
IS
BEGIN
    RETURN TRUE;
END RMA_ATTRIBUTE9;

FUNCTION RMA_ATTRIBUTE10(rma_attribute10 IN VARCHAR2)
RETURN BOOLEAN
IS
BEGIN
    RETURN TRUE;
END RMA_ATTRIBUTE10;


FUNCTION Accounting_Rule ( p_accounting_rule_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_accounting_rule_id IS NULL OR
        p_accounting_rule_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_accounting_rule_id;
    --PP Revenue Recognition
    --bug 4893057
    --The query has been modified to include the accounting
    --rules for the partial revenue recognition
    SELECT 'VALID'
    INTO l_dummy
    FROM    OE_RA_RULES_V
    WHERE   RULE_ID = p_accounting_rule_id
    AND     STATUS = 'A'
    AND     TYPE IN ('A', 'ACC_DUR','PP_DR_ALL','PP_DR_PP');

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ACCOUNTING_RULE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('accounting_rule_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Accounting_Rule'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Accounting_Rule;


FUNCTION Accounting_Rule_Duration ( p_accounting_rule_duration IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_accounting_rule_duration IS NULL OR
        p_accounting_rule_duration = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_accounting_rule_duration;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ACCOUNTING_RULE_DURATION');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('accounting_rule_duration'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Accounting_Rule_Duration'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Accounting_Rule_Duration;


FUNCTION Created_By ( p_created_by IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_created_by IS NULL OR
        p_created_by = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_created_by;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CREATED_BY');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('created_by'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Created_By'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Created_By;

FUNCTION Creation_Date ( p_creation_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_creation_date IS NULL OR
        p_creation_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_creation_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CREATION_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('creation_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Creation_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Creation_Date;


FUNCTION Ordered_Date ( p_ordered_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_ordered_date IS NULL OR
        p_ordered_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_ordered_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ORDERED_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('ordered_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ordered_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ordered_Date;

FUNCTION Order_Date_Type_Code ( p_order_date_type_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type      	      VARCHAR2(80) :='REQUEST_DATE_TYPE';
BEGIN


    IF p_order_date_type_code IS NULL OR
        p_order_date_type_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_LOOKUPS
    WHERE   LOOKUP_CODE = p_order_date_type_code
    AND     LOOKUP_TYPE = l_lookup_type
    AND     ENABLED_FLAG = 'Y'
    AND     SYSDATE     BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                        AND NVL(END_DATE_ACTIVE, SYSDATE);


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ORDER_DATE_TYPE_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('order_date_type_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);


        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Order_Date_Type_Code'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Order_Date_Type_Code;



FUNCTION Request_Date ( p_request_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_request_date IS NULL OR
        p_request_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_request_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'REQUEST_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('request_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Request_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Request_Date;

FUNCTION Reserved_Quantity ( p_reserved_quantity IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_reserved_quantity IS NULL OR
        p_reserved_quantity = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_ato_line_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'RESERVED_QUANTITY');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('reserved_quantity'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Reserved_Quantity'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Reserved_Quantity;

FUNCTION Actual_Arrival_Date ( p_actual_arrival_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_actual_arrival_date IS NULL OR
        p_actual_arrival_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_actual_arrival_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ACTUAL_ARRIVAL_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('actual_arrival_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Actual_Arrival_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Actual_Arrival_Date;


FUNCTION Actual_Shipment_Date ( p_actual_shipment_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_actual_shipment_date IS NULL OR
        p_actual_shipment_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_actual_shipment_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ACTUAL_SHIPMENT_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('actual_shipment_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Actual_Shipment_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Actual_Shipment_Date;


FUNCTION Ato_Line ( p_ato_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_ato_line_id IS NULL OR
        p_ato_line_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_ato_line_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ATO_LINE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('ato_line_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ato_Line_Id'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ato_Line;


FUNCTION Auto_Selected_Quantity ( p_auto_selected_quantity IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_auto_selected_quantity IS NULL OR
        p_auto_selected_quantity = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_auto_selected_quantity;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'AUTO_SELECTED_QUANTITY');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('auto_selected_quantity'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Auto_Selected_Quantity'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Auto_Selected_Quantity;

FUNCTION Blanket_Number( p_blanket_number IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_blanket_number IS NULL OR
        p_blanket_number = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

/*
   Blanket Number validation is done in procedure Entity for
   oe_validate_header/oe_validate_line.
   On Hold and Expired blankets are allowed for return/mixed
   orders.
    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_BLANKET_HEADERS BH,OE_BLANKET_HEADERS_EXT BHE
    WHERE   BH.ORDER_NUMBER = p_blanket_number
    AND     TRUNC(SYSDATE) BETWEEN TRUNC(BHE.START_DATE_ACTIVE )
                    AND     TRUNC(NVL( BHE.END_DATE_ACTIVE, SYSDATE )) AND
            BHE.ON_HOLD_FLAG = 'N'
    AND     BH.ORDER_NUMBER = BHE.ORDER_NUMBER
    AND     BH.SALES_DOCUMENT_TYPE_CODE = 'B';
*/

    RETURN TRUE;
EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'BLANKET_NUMBER');

            FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                         'BLANKET NUMBER');
            OE_MSG_PUB.Add;

                OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Blanket_Number'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Blanket_Number;


FUNCTION Booked ( p_booked_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_booked_flag IS NULL OR
        p_booked_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    IF p_booked_flag NOT IN ('Y','N') THEN
		RAISE NO_DATA_FOUND;
    END IF;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'BOOKED_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('booked_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Booked'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Booked;


FUNCTION Cancelled( p_cancelled_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_cancelled_flag IS NULL OR
        p_cancelled_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    IF p_cancelled_flag NOT IN ('Y','N') THEN
		RAISE NO_DATA_FOUND;
    END IF;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CANCELLED_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('cancelled_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Cancelled'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Cancelled;


FUNCTION Cancelled_Quantity ( p_cancelled_quantity IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_cancelled_quantity IS NULL OR
        p_cancelled_quantity = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_cancelled_quantity;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CANCELLED_QUANTITY');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('cancelled_quantity'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Cancelled_Quantity'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Cancelled_Quantity;



FUNCTION Credit_Invoice_Line ( p_credit_invoice_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_credit_invoice_line_id IS NULL OR
        p_credit_invoice_line_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_credit_invoice_line_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CREDIT_INVOICE_LINE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('credit_invoice_line'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Credit_Invoice_Line'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Credit_Invoice_Line;


FUNCTION Customer_Dock ( p_customer_dock_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_customer_dock_code IS NULL OR
        p_customer_dock_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_customer_dock_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CUSTOMER_DOCK_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('customer_dock_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);


        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Customer_Dock'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Customer_Dock;



FUNCTION Customer_Job ( p_customer_job IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_customer_job IS NULL OR
        p_customer_job = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_customer_job;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CUSTOMER_JOB');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('customer_job'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;

        RETURN FALSE;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Customer_Job'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Customer_Job;

FUNCTION Customer_Production_Line ( p_customer_production_line IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_customer_production_line IS NULL OR
        p_customer_production_line = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_customer_production_line;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CUSTOMER_PRODUCTION_LINE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('customer_production_line'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Customer_Production_Line'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Customer_Production_Line;

FUNCTION Customer_Trx_Line ( p_customer_trx_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_customer_trx_line_id IS NULL OR
        p_customer_trx_line_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_customer_trx_line_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CUSTOMER_TRX_LINE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('customer_trx_line_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Customer_Trx_Line'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Customer_Trx_Line;



FUNCTION Dep_Plan_Required ( p_dep_plan_required_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_dep_plan_required_flag IS NULL OR
        p_dep_plan_required_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_dep_plan_required_flag;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'DEP_PLAN_REQUIRED_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('dep_plan_required_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Dep_Plan_Required'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Dep_Plan_Required;


FUNCTION Fulfilled_Quantity ( p_fulfilled_quantity IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_fulfilled_quantity IS NULL OR
        p_fulfilled_quantity = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_fulfilled_quantity;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'FULFILLED_QUANTITY');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('fulfilled_quantity'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Fulfilled_Quantity'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Fulfilled_Quantity;


FUNCTION Invoice_Interface_Status ( p_invoice_interface_status IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_invoice_interface_status IS NULL OR
        p_invoice_interface_status = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_invoice_interface_status;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'INVOICE_INTERFACE_STATUS_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('invoice_interface_status_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoice_Interface_Status'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoice_Interface_Status;



FUNCTION Item_Revision ( p_item_revision IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_item_revision IS NULL OR
        p_item_revision = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_item_revision;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ITEM_REVISION');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('item_revision'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Item_Revision'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Item_Revision;

FUNCTION Item_Type ( p_item_type_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_item_type_code IS NULL OR
        p_item_type_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_item_type_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ITEM_TYPE_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('item_type_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Item_Type'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Item_Type;

FUNCTION Line_Category ( p_line_category_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_line_category_code IS NULL OR
        p_line_category_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_line_category_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LINE_CATEGORY_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('line_category_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line_Category'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Line_Category;


FUNCTION Open(p_open_flag IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_open_flag IS NULL OR
        p_open_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    IF p_open_flag NOT IN ('Y','N') THEN
		RAISE NO_DATA_FOUND;
    END IF;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'OPEN_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('open_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Open'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Open;


FUNCTION Option_Flag ( p_option_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_option_flag IS NULL OR
        p_option_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_option_flag;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'OPTION_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('option_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Option_Flag'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Option_Flag;


FUNCTION Ordered_Quantity ( p_ordered_quantity IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_ordered_quantity IS NULL OR
        p_ordered_quantity = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_ordered_quantity;
    IF p_ordered_quantity < 0 THEN
	RAISE NO_DATA_FOUND;
    END IF;



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ORDERED_QUANTITY');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('ordered_quantity'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ordered_Quantity'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ordered_Quantity;

-- OPM 02/JUN/00 - add function to support new process attribute
-- =============================================================

FUNCTION Ordered_Quantity2 ( p_ordered_quantity2 IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_ordered_quantity2 IS NULL OR
        p_ordered_quantity2 = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	     OE_MSG_PUB.Update_Msg_Context(p_attribute_code =>'ORDERED_QUANTITY2');
          fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('ordered_quantity2'));
            OE_MSG_PUB.Add;
	       OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ordered_Quantity2'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ordered_Quantity2;

-- OPM 02/JUN/00 END
-- =================


FUNCTION Promise_Date ( p_promise_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_promise_date IS NULL OR
        p_promise_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_promise_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PROMISE_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('promise_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Promise_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Promise_Date;



FUNCTION Re_Source ( p_re_source_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_re_source_flag IS NULL OR
        p_re_source_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_re_source_flag;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'RE_SOURCE_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('re_source_flag'));
            OE_MSG_PUB.Add;
            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Re_Source_Flag'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Re_Source;


FUNCTION Rla_Schedule_Type ( p_rla_schedule_type_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_rla_schedule_type_code IS NULL OR
        p_rla_schedule_type_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_rla_schedule_type_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'RLA_SCHEDULE_TYPE_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('rla_schedule_type_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Rla_Schedule_Type'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Rla_Schedule_Type;

FUNCTION Schedule_Ship_Date ( p_schedule_ship_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_schedule_ship_date IS NULL OR
        p_schedule_ship_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_Schedule_Ship_Date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SCHEDULE_SHIP_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('schedule_ship_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'schedule_ship_date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Schedule_Ship_Date;



FUNCTION Late_Demand_Penalty_Factor( p_late_demand_penalty_factor IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_late_demand_penalty_factor IS NULL OR
        p_late_demand_penalty_factor = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;

    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_late_demand_penalty_factor;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LATE_DEMAND_PENALTY_FACTOR');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                OE_Order_Util.Get_Attribute_Name('late_demand_penalty_factor'));
            OE_MSG_PUB.Add;
              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'late_demand_penalty_factor'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Late_Demand_Penalty_Factor;

FUNCTION Schedule_Status ( p_schedule_status_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_schedule_status_code IS NULL OR
        p_schedule_status_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_schedule_ship_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SCHEDULE_STATUS_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('schedule_status_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule_Status'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Schedule_Status;


FUNCTION Tax ( p_tax_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_tax_code IS NULL OR
        p_tax_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;
   /*
   ** Since Tax_Code depands on tax_date, the validation should be done at
   ** Entity Level.
   */
--    SELECT 'VALID'
--    INTO   l_dummy
--    FROM   AR_VAT_TAX V,
--		 AR_SYSTEM_PARAMETERS P
--    WHERE  V.TAX_CODE = p_tax_code
--    AND V.SET_OF_BOOKS_ID = P.SET_OF_BOOKS_ID
--    AND NVL(V.ENABLED_FLAG,'Y')='Y'
--    AND NVL(V.TAX_CLASS,'O')='O'
--    AND NVL(V.DISPLAYED_FLAG,'Y')='Y'
--    AND TRUNC(SYSDATE) BETWEEN TRUNC(V.START_DATE) AND
--	   TRUNC(NVL(V.END_DATE, SYSDATE))
--    AND ROWNUM = 1;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'TAX_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('tax_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Tax'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Tax;


FUNCTION Tax_Rate ( p_tax_rate IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_tax_rate IS NULL OR
        p_tax_rate = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_tax_rate;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'TAX_RATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('tax_rate'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Tax_Rate'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Tax_Rate;




FUNCTION Visible_Demand ( p_visible_demand_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_visible_demand_flag IS NULL OR
        p_visible_demand_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_visible_demand_flag;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'VISIBLE_DEMAND_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('visible_demand_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Visible_Demand'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Visible_Demand;



FUNCTION Shipped_Quantity ( p_shipped_quantity IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_shipped_quantity IS NULL OR
        p_shipped_quantity = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_shipped_quantity;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SHIPPED_QUANTITY');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('shipped_quantity'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Shipped_Quantity'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Shipped_Quantity;

FUNCTION Earliest_Acceptable_Date ( p_earliest_acceptable_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_earliest_acceptable_date IS NULL OR
        p_earliest_acceptable_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_earliest_acceptable_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'EARLIEST_ACCEPTABLE_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('earliest_acceptable_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Earliest_Acceptable_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Earliest_Acceptable_Date;

FUNCTION Earliest_Schedule_limit ( p_earliest_schedule_limit IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_earliest_schedule_limit IS NULL OR
        p_earliest_schedule_limit = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_earliest_schedule_limit;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'EARLIEST_SCHEDULE_LIMIT');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('earliest_schedule_limit'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Earliest_Schedule_Limit'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Earliest_Schedule_Limit;


FUNCTION Latest_Acceptable_Date ( p_latest_acceptable_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_latest_acceptable_date IS NULL OR
        p_latest_acceptable_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_latest_acceptable_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LATEST_ACCEPTABLE_DATE');


            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('latest_acceptable_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Latest_Acceptable_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Latest_Acceptable_Date;

FUNCTION Latest_Schedule_limit (p_latest_schedule_limit IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_latest_schedule_limit IS NULL OR
        p_latest_schedule_limit = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_latest_schedule_limit;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LATEST_SCHEDULE_LIMIT');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('latest_schedule_limit'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Latest_Schedule_Limit'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Latest_Schedule_Limit;

FUNCTION Model_Group_Number ( p_model_group_number IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_model_group_number IS NULL OR
        p_model_group_number = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_model_group_number;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'MODEL_GROUP_NUMBER');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('model_group_number'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Model_Group_Number'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Model_Group_Number;


FUNCTION Mfg_Component_Sequence ( p_mfg_component_sequence_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_mfg_component_sequence_id IS NULL OR
        p_mfg_component_sequence_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_mfg_component_sequence_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context
			    (p_attribute_code => 'MFG_COMPONENT_SEQUENCE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name
						('mfg_component_sequence_id'));
            OE_MSG_PUB.Add;
	       OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Mfg_Component_Sequence_Id'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Mfg_Component_Sequence;

FUNCTION Schedule_Arrival_Date ( p_schedule_arrival_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_schedule_arrival_date IS NULL OR
        p_schedule_arrival_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_schedule_arrival_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SCHEDULE_ARRIVAL_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('schedule_arrival_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule_Arrival_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Schedule_Arrival_Date;



FUNCTION Ship_Model_Complete ( p_ship_model_complete_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_ship_model_complete_flag IS NULL OR
        p_ship_model_complete_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_visible_demand_flag;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SHIP_MODEL_COMPLETE_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('ship_model_complete_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Ship_Model_Complete_Flag'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ship_Model_Complete;

FUNCTION From_Serial_Number ( p_from_serial_number IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_from_serial_number IS NULL OR
        p_from_serial_number = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_from_serial_number;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'FROM_SERIAL_NUMBER');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('from_serial_number'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'From_Serial_Number'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END From_Serial_Number;

FUNCTION Lot_Number ( p_lot_number IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_lot_number IS NULL OR
        p_lot_number = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_lot_number;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LOT_NUMBER');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('lot_number'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lot_Number'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Lot_Number;

/* FUNCTION Sublot_Number ( p_sublot_number IN VARCHAR2 ) --OPM 2380194  -- remove for INVCONV
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_sublot_number IS NULL OR
        p_sublot_number = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_sublot_number;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SUBLOT_NUMBER');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('sublot_number'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sublot_Number'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sublot_Number;    */

FUNCTION Lot_Serial ( p_lot_serial_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_lot_serial_id IS NULL OR
        p_lot_serial_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_lot_serial_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LOT_SERIAL_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('lot_serial_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lot_Serial'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Lot_Serial;

FUNCTION Quantity ( p_quantity IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_quantity IS NULL OR
        p_quantity = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_quantity;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'QUANTITY');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('quantity'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Quantity'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Quantity;

FUNCTION Quantity2 ( p_quantity2 IN NUMBER ) --OPM 2380194
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_quantity2 IS NULL OR
        p_quantity2 = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_quantity2;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'QUANTITY2');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('quantity2'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Quantity2'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Quantity2;

FUNCTION To_Serial_Number ( p_to_serial_number IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_to_serial_number IS NULL OR
        p_to_serial_number = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_to_serial_number;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'TO_SERIAL_NUMBER');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('to_serial_number'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'To_Serial_Number'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END To_Serial_Number;

FUNCTION Line_Set ( p_line_set_id IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_line_set_id IS NULL OR
        p_line_set_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_line_set_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Line_Set_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Line_Set_ID'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line_Set'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Line_Set;

FUNCTION Amount ( p_amount IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_amount IS NULL OR
        p_amount = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_amount;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'AMOUNT');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('amount'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Amount'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Amount;

FUNCTION Appear_On_Ack ( p_appear_on_ack_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_appear_on_ack_flag IS NULL OR
        p_appear_on_ack_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_appear_on_ack_flag;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'APPEAR_ON_ACK_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('appear_on_ack_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


       RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Appear_On_Ack'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Appear_On_Ack;

FUNCTION Appear_On_Invoice ( p_appear_on_invoice_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_appear_on_invoice_flag IS NULL OR
        p_appear_on_invoice_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_appear_on_invoice_flag;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'APPEAR_ON_INVOICE_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('appear_on_invoice_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Appear_On_Invoice'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Appear_On_Invoice;

FUNCTION Charge ( p_charge_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_charge_id IS NULL OR
        p_charge_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_charge_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CHARGE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('charge_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);


        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Charge'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Charge;

FUNCTION Charge_Type ( p_charge_type_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_charge_type_id IS NULL OR
        p_charge_type_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_charge_type_id;


   RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CHARGE_TYPE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('charge_type_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Charge_Type'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Charge_Type;

FUNCTION Conversion_Date ( p_conversion_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_conversion_date IS NULL OR
        p_conversion_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_conversion_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CONVERSION_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('conversion_date'));

	      OE_MSG_PUB.Add;
		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);


        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Conversion_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Conversion_Date;

FUNCTION Cost_Or_Charge ( p_cost_or_charge_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_cost_or_charge_flag IS NULL OR
        p_cost_or_charge_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_cost_or_charge_flag;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'COST_OR_CHARGE_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('cost_or_charge_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Cost_Or_Charge'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Cost_Or_Charge;

FUNCTION Currency ( p_currency_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_currency_code IS NULL OR
        p_currency_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_currency_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CURRENCY_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('currency_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Currency'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Currency;

FUNCTION Departure ( p_departure_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_departure_id IS NULL OR
        p_departure_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_departure_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'DEPARTURE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('departure_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Departure'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Departure;

FUNCTION Estimated ( p_estimated_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_estimated_flag IS NULL OR
        p_estimated_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_estimated_flag;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ESTIMATED_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('estimated_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Estimated'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Estimated;

FUNCTION Inc_In_Sales_Performance ( p_inc_in_sales_performance IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_inc_in_sales_performance IS NULL OR
        p_inc_in_sales_performance = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_inc_in_sales_performance;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'INC_IN_SALES_PERFORMANCE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('inc_in_sales_performance'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);


        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Inc_In_Sales_Performance'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Inc_In_Sales_Performance;

FUNCTION Invoiced ( p_invoiced_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_invoiced_flag IS NULL OR
        p_invoiced_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_invoiced_flag;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'INVOICED_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('invoiced_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoiced'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoiced;

FUNCTION Lpn ( p_lpn IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_lpn IS NULL OR
        p_lpn = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_lpn;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LPN');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('lpn'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lpn'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Lpn;

FUNCTION Parent_Charge ( p_parent_charge_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_parent_charge_id IS NULL OR
        p_parent_charge_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_parent_charge_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PARENT_CHARGE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('parent_charge_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Parent_Charge'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Parent_Charge;

FUNCTION Returnable ( p_returnable_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_returnable_flag IS NULL OR
        p_returnable_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_returnable_flag;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'RETURNABLE_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('returnable_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Returnable'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Returnable;

FUNCTION Tax_Group ( p_tax_group_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_tax_group_code IS NULL OR
        p_tax_group_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_tax_group_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'TAX_GROUP_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('tax_group_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Tax_Group'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Tax_Group;

--  END GEN validate

--- function header_desc_flex
-- if all attrs. are missing, then return valid.
-- if some are missing, set_column_value for these missing attrs., pass null
-- and  for others pass the actual value
-- call validate.desccols
-- return valid/invalid

FUNCTION Header_Desc_Flex (p_context IN VARCHAR2,
 			   p_attribute1 IN VARCHAR2,
                           p_attribute2 IN VARCHAR2,
                           p_attribute3 IN VARCHAR2,
                           p_attribute4 IN VARCHAR2,
                           p_attribute5 IN VARCHAR2,
                           p_attribute6 IN VARCHAR2,
                           p_attribute7 IN VARCHAR2,
                           p_attribute8 IN VARCHAR2,
                           p_attribute9 IN VARCHAR2,
                           p_attribute10 IN VARCHAR2,
                           p_attribute11 IN VARCHAR2,
                           p_attribute12 IN VARCHAR2,
                           p_attribute13 IN VARCHAR2,
                           p_attribute14 IN VARCHAR2,
                           p_attribute15 IN VARCHAR2,
                           p_attribute16 IN VARCHAR2,  -- for bug 2184255
                           p_attribute17 IN VARCHAR2,
                           p_attribute18 IN VARCHAR2,
                           p_attribute19 IN VARCHAR2,
                           p_attribute20 IN VARCHAR2,
                           p_document_type IN VARCHAR2 := 'ORDER')

RETURN BOOLEAN
IS
l_column_value VARCHAR2(240) := null;
BEGIN

   --        OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CONTEXT');
   --  Assiging the segment names so as to map the values after the FND call.
                g_context_name := 'CONTEXT';
		g_attribute1_name := 'ATTRIBUTE1';
		g_attribute2_name := 'ATTRIBUTE2';
		g_attribute3_name := 'ATTRIBUTE3';
		g_attribute4_name := 'ATTRIBUTE4';
		g_attribute5_name := 'ATTRIBUTE5';
		g_attribute6_name := 'ATTRIBUTE6';
		g_attribute7_name := 'ATTRIBUTE7';
		g_attribute8_name := 'ATTRIBUTE8';
		g_attribute9_name := 'ATTRIBUTE9';
		g_attribute10_name := 'ATTRIBUTE10';
		g_attribute11_name := 'ATTRIBUTE11';
		g_attribute12_name := 'ATTRIBUTE12';
		g_attribute13_name := 'ATTRIBUTE13';
		g_attribute14_name := 'ATTRIBUTE14';
		g_attribute15_name := 'ATTRIBUTE15';
		g_attribute16_name := 'ATTRIBUTE16';  -- for bug 2184255
		g_attribute17_name := 'ATTRIBUTE17';
		g_attribute18_name := 'ATTRIBUTE18';
		g_attribute19_name := 'ATTRIBUTE19';
		g_attribute20_name := 'ATTRIBUTE20';

                /* commented out for 2056666

		IF   (p_attribute1 = FND_API.G_MISS_CHAR)
                AND  (p_attribute2 = FND_API.G_MISS_CHAR)
		    AND  (p_attribute3 = FND_API.G_MISS_CHAR)
                AND  (p_attribute4 = FND_API.G_MISS_CHAR)
                AND  (p_attribute5 = FND_API.G_MISS_CHAR)
                AND  (p_attribute6 = FND_API.G_MISS_CHAR)
                AND  (p_attribute7 = FND_API.G_MISS_CHAR)
                AND  (p_attribute8 = FND_API.G_MISS_CHAR)
                AND  (p_attribute9 = FND_API.G_MISS_CHAR)
                AND  (p_attribute10 = FND_API.G_MISS_CHAR)
                AND  (p_attribute11 = FND_API.G_MISS_CHAR)
                AND  (p_attribute12 = FND_API.G_MISS_CHAR)
                AND  (p_attribute13 = FND_API.G_MISS_CHAR)
                AND  (p_attribute14 = FND_API.G_MISS_CHAR)
                AND  (p_attribute15 = FND_API.G_MISS_CHAR)
                AND  (p_context     = FND_API.G_MISS_CHAR) THEN


		     RETURN TRUE;

                ELSE

                2056666 */


		  IF p_attribute1 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute1;

                  END IF;

                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE1'
                   ,  column_value  => l_column_value);


		  IF p_attribute2 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute2;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE2'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute3 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute3;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE3'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute4 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute4;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE4'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute5 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute5;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE5'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute6 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute6;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE6'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute7 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute7;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE7'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute8 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute8;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE8'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute9 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute9;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE9'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute10 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute10;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE10'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute11 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute11;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE11'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute12 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute12;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE12'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute13 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute13;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE13'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute14 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute14;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE14'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute15 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute15;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE15'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute16 = FND_API.G_MISS_CHAR THEN  -- For bug 2184255

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute16;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE16'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute17 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute17;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE17'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute18 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute18;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE18'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute19 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute19;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE19'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute20 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute20;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE20'
                   ,  column_value  =>  l_column_value);  -- End bug 2184255

		  IF p_context = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_context;

                  END IF;
		  FND_FLEX_DESCVAL.Set_Context_Value
		   ( context_value   => l_column_value);

                  IF p_document_type = 'ORDER' THEN
                   IF NOT OE_Validate.Desc_Flex('OE_HEADER_ATTRIBUTES') THEN
			RETURN FALSE;
                   END IF;
                  ELSIF p_document_type = 'BLANKET' THEN
                   IF NOT OE_Validate.Desc_Flex('OE_BLKT_HEADER_ATTRIBUTES') THEN
			RETURN FALSE;
                   END IF;
                  END IF;

                /* commented out for 2056666
                END IF;
                */

    RETURN TRUE;

EXCEPTION

   WHEN OTHERS THEN


     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN

        OE_MSG_PUB.Add_Exc_Msg
	( G_PKG_NAME
          , 'Header_Desc_Flex');
     END IF;


     RETURN FALSE;

END Header_Desc_Flex;


FUNCTION G_Header_Desc_Flex (p_context IN VARCHAR2,
			   p_attribute1 IN VARCHAR2,
                           p_attribute2 IN VARCHAR2,
                           p_attribute3 IN VARCHAR2,
                           p_attribute4 IN VARCHAR2,
                           p_attribute5 IN VARCHAR2,
                           p_attribute6 IN VARCHAR2,
                           p_attribute7 IN VARCHAR2,
                           p_attribute8 IN VARCHAR2,
                           p_attribute9 IN VARCHAR2,
                           p_attribute10 IN VARCHAR2,
                           p_attribute11 IN VARCHAR2,
                           p_attribute12 IN VARCHAR2,
                           p_attribute13 IN VARCHAR2,
                           p_attribute14 IN VARCHAR2,
                           p_attribute15 IN VARCHAR2,
                           p_attribute16 IN VARCHAR2,
                           p_attribute17 IN VARCHAR2,
                           p_attribute18 IN VARCHAR2,
                           p_attribute19 IN VARCHAR2,
                           p_attribute20 IN VARCHAR2)
RETURN BOOLEAN
IS
l_column_value VARCHAR2(240) := null;
BEGIN

--        OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'GLOBAL_ATTRIBUTE_CATEGORY');

                g_context_name := 'GLOBAL_ATTRIBUTE_CATEGORY';
		g_attribute1_name := 'GLOBAL_ATTRIBUTE1';
		g_attribute2_name := 'GLOBAL_ATTRIBUTE2';
		g_attribute3_name := 'GLOBAL_ATTRIBUTE3';
		g_attribute4_name := 'GLOBAL_ATTRIBUTE4';
		g_attribute5_name := 'GLOBAL_ATTRIBUTE5';
		g_attribute6_name := 'GLOBAL_ATTRIBUTE6';
		g_attribute7_name := 'GLOBAL_ATTRIBUTE7';
		g_attribute8_name := 'GLOBAL_ATTRIBUTE8';
		g_attribute9_name := 'GLOBAL_ATTRIBUTE9';
		g_attribute10_name := 'GLOBAL_ATTRIBUTE10';
		g_attribute11_name := 'GLOBAL_ATTRIBUTE11';
		g_attribute12_name := 'GLOBAL_ATTRIBUTE12';
		g_attribute13_name := 'GLOBAL_ATTRIBUTE13';
		g_attribute14_name := 'GLOBAL_ATTRIBUTE14';
		g_attribute15_name := 'GLOBAL_ATTRIBUTE15';
		g_attribute16_name := 'GLOBAL_ATTRIBUTE16';
		g_attribute17_name := 'GLOBAL_ATTRIBUTE17';
		g_attribute18_name := 'GLOBAL_ATTRIBUTE18';
		g_attribute19_name := 'GLOBAL_ATTRIBUTE19';
		g_attribute20_name := 'GLOBAL_ATTRIBUTE20';

		/*IF   (p_attribute1 = FND_API.G_MISS_CHAR)
                AND  (p_attribute2 = FND_API.G_MISS_CHAR)
		    AND  (p_attribute3 = FND_API.G_MISS_CHAR)
                AND  (p_attribute4 = FND_API.G_MISS_CHAR)
                AND  (p_attribute5 = FND_API.G_MISS_CHAR)
                AND  (p_attribute6 = FND_API.G_MISS_CHAR)
                AND  (p_attribute7 = FND_API.G_MISS_CHAR)
                AND  (p_attribute8 = FND_API.G_MISS_CHAR)
                AND  (p_attribute9 = FND_API.G_MISS_CHAR)
                AND  (p_attribute10 = FND_API.G_MISS_CHAR)
                AND  (p_attribute11 = FND_API.G_MISS_CHAR)
                AND  (p_attribute12 = FND_API.G_MISS_CHAR)
                AND  (p_attribute13 = FND_API.G_MISS_CHAR)
                AND  (p_attribute14 = FND_API.G_MISS_CHAR)
                AND  (p_attribute15 = FND_API.G_MISS_CHAR)
                AND  (p_attribute16 = FND_API.G_MISS_CHAR)
                AND  (p_attribute17 = FND_API.G_MISS_CHAR)
                AND  (p_attribute18 = FND_API.G_MISS_CHAR)
                AND  (p_attribute19 = FND_API.G_MISS_CHAR)
                AND  (p_attribute20 = FND_API.G_MISS_CHAR)
                AND  (p_context     = FND_API.G_MISS_CHAR) THEN


		     RETURN TRUE;

                ELSE */

		  IF p_attribute1 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute1;

                  END IF;

                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE1'
                   ,  column_value  => l_column_value);


		  IF p_attribute2 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute2;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE2'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute3 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute3;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE3'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute4 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute4;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE4'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute5 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute5;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE5'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute6 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute6;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE6'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute7 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute7;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE7'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute8 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute8;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE8'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute9 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute9;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE9'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute10 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute10;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE10'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute11 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute11;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE11'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute12 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute12;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE12'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute13 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute13;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE13'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute14 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute14;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE14'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute15 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute15;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE15'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute16 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute16;

                  END IF;

                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE16'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute17 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute17;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE17'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute18 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute18;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE18'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute19 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute19;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE19'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute20 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute20;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE20'
                   ,  column_value  =>  l_column_value);

		  IF p_context = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_context;

                  END IF;
		  FND_FLEX_DESCVAL.Set_Context_Value
		   ( context_value   => l_column_value);

                   IF NOT OE_Validate.Desc_Flex('OE_HEADER_GLOBAL_ATTRIBUTE') THEN
			RETURN FALSE;
                   END IF;

                --END IF;

    RETURN TRUE;

EXCEPTION

   WHEN OTHERS THEN


     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN

        OE_MSG_PUB.Add_Exc_Msg
	( G_PKG_NAME
          , 'G_Header_Desc_Flex');
     END IF;

     RETURN FALSE;
END G_Header_Desc_Flex;

FUNCTION TP_Header_Desc_Flex (p_context IN VARCHAR2,
			   p_attribute1 IN VARCHAR2,
                           p_attribute2 IN VARCHAR2,
                           p_attribute3 IN VARCHAR2,
                           p_attribute4 IN VARCHAR2,
                           p_attribute5 IN VARCHAR2,
                           p_attribute6 IN VARCHAR2,
                           p_attribute7 IN VARCHAR2,
                           p_attribute8 IN VARCHAR2,
                           p_attribute9 IN VARCHAR2,
                           p_attribute10 IN VARCHAR2,
                           p_attribute11 IN VARCHAR2,
                           p_attribute12 IN VARCHAR2,
                           p_attribute13 IN VARCHAR2,
                           p_attribute14 IN VARCHAR2,
                           p_attribute15 IN VARCHAR2)
RETURN BOOLEAN
IS
l_column_value VARCHAR2(240) := null;
BEGIN

   --OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'GLOBAL_ATTRIBUTE_CATEGORY');

                g_context_name := 'TP_CONTEXT';
		g_attribute1_name := 'TP_ATTRIBUTE1';
		g_attribute2_name := 'TP_ATTRIBUTE2';
		g_attribute3_name := 'TP_ATTRIBUTE3';
		g_attribute4_name := 'TP_ATTRIBUTE4';
		g_attribute5_name := 'TP_ATTRIBUTE5';
		g_attribute6_name := 'TP_ATTRIBUTE6';
		g_attribute7_name := 'TP_ATTRIBUTE7';
		g_attribute8_name := 'TP_ATTRIBUTE8';
		g_attribute9_name := 'TP_ATTRIBUTE9';
		g_attribute10_name := 'TP_ATTRIBUTE10';
		g_attribute11_name := 'TP_ATTRIBUTE11';
		g_attribute12_name := 'TP_ATTRIBUTE12';
		g_attribute13_name := 'TP_ATTRIBUTE13';
		g_attribute14_name := 'TP_ATTRIBUTE14';
		g_attribute15_name := 'TP_ATTRIBUTE15';

		/*IF   (p_attribute1 = FND_API.G_MISS_CHAR)
                AND  (p_attribute2 = FND_API.G_MISS_CHAR)
		      AND  (p_attribute3 = FND_API.G_MISS_CHAR)
                AND  (p_attribute4 = FND_API.G_MISS_CHAR)
                AND  (p_attribute5 = FND_API.G_MISS_CHAR)
                AND  (p_attribute6 = FND_API.G_MISS_CHAR)
                AND  (p_attribute7 = FND_API.G_MISS_CHAR)
                AND  (p_attribute8 = FND_API.G_MISS_CHAR)
                AND  (p_attribute9 = FND_API.G_MISS_CHAR)
                AND  (p_attribute10 = FND_API.G_MISS_CHAR)
                AND  (p_attribute11 = FND_API.G_MISS_CHAR)
                AND  (p_attribute12 = FND_API.G_MISS_CHAR)
                AND  (p_attribute13 = FND_API.G_MISS_CHAR)
                AND  (p_attribute14 = FND_API.G_MISS_CHAR)
                AND  (p_attribute15 = FND_API.G_MISS_CHAR)
                AND  (p_context     = FND_API.G_MISS_CHAR) THEN


		     RETURN TRUE;

                ELSE */

		  IF p_attribute1 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute1;

                  END IF;

                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE1'
                   ,  column_value  => l_column_value);


		  IF p_attribute2 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute2;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE2'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute3 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute3;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE3'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute4 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute4;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE4'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute5 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute5;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE5'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute6 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute6;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE6'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute7 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute7;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE7'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute8 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute8;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE8'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute9 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute9;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE9'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute10 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute10;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE10'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute11 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute11;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE11'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute12 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute12;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE12'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute13 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute13;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE13'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute14 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute14;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE14'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute15 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute15;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE15'
                   ,  column_value  =>  l_column_value);


		  IF p_context = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	       ELSE

		     l_column_value := p_context;

            END IF;
		  FND_FLEX_DESCVAL.Set_Context_Value
		   ( context_value   => l_column_value);

             IF NOT OE_Validate.Desc_Flex('OE_HEADER_TP_ATTRIBUTES') THEN
			RETURN FALSE;
             END IF;

          --END IF;

    RETURN TRUE;

EXCEPTION

   WHEN OTHERS THEN


     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN

        OE_MSG_PUB.Add_Exc_Msg
	( G_PKG_NAME
          , 'TP_Header_Desc_Flex');
     END IF;

     RETURN FALSE;
END TP_Header_Desc_Flex;



FUNCTION Line_Desc_Flex (p_context IN VARCHAR2,
			         p_attribute1 IN VARCHAR2,
                           p_attribute2 IN VARCHAR2,
                           p_attribute3 IN VARCHAR2,
                           p_attribute4 IN VARCHAR2,
                           p_attribute5 IN VARCHAR2,
                           p_attribute6 IN VARCHAR2,
                           p_attribute7 IN VARCHAR2,
                           p_attribute8 IN VARCHAR2,
                           p_attribute9 IN VARCHAR2,
                           p_attribute10 IN VARCHAR2,
                           p_attribute11 IN VARCHAR2,
                           p_attribute12 IN VARCHAR2,
                           p_attribute13 IN VARCHAR2,
                           p_attribute14 IN VARCHAR2,
                           p_attribute15 IN VARCHAR2,
                           p_attribute16 IN VARCHAR2,  -- for bug 2184255
                           p_attribute17 IN VARCHAR2,
                           p_attribute18 IN VARCHAR2,
                           p_attribute19 IN VARCHAR2,
                           p_attribute20 IN VARCHAR2,
                           p_document_type IN VARCHAR2 := 'ORDER')

RETURN BOOLEAN
IS
l_column_value VARCHAR2(240) := null;
BEGIN

--        OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CONTEXT');
                g_context_name := 'CONTEXT';
		g_attribute1_name := 'ATTRIBUTE1';
		g_attribute2_name := 'ATTRIBUTE2';
		g_attribute3_name := 'ATTRIBUTE3';
		g_attribute4_name := 'ATTRIBUTE4';
		g_attribute5_name := 'ATTRIBUTE5';
		g_attribute6_name := 'ATTRIBUTE6';
		g_attribute7_name := 'ATTRIBUTE7';
		g_attribute8_name := 'ATTRIBUTE8';
		g_attribute9_name := 'ATTRIBUTE9';
		g_attribute10_name := 'ATTRIBUTE10';
		g_attribute11_name := 'ATTRIBUTE11';
		g_attribute12_name := 'ATTRIBUTE12';
		g_attribute13_name := 'ATTRIBUTE13';
		g_attribute14_name := 'ATTRIBUTE14';
		g_attribute15_name := 'ATTRIBUTE15';
		g_attribute16_name := 'ATTRIBUTE16';  -- for bug 2184255
		g_attribute17_name := 'ATTRIBUTE17';
		g_attribute18_name := 'ATTRIBUTE18';
		g_attribute19_name := 'ATTRIBUTE19';
		g_attribute20_name := 'ATTRIBUTE20';

                /* commented out for 2056666

		IF   (p_attribute1 = FND_API.G_MISS_CHAR)
                 AND  (p_attribute2 = FND_API.G_MISS_CHAR)
		     AND  (p_attribute3 = FND_API.G_MISS_CHAR)
                AND  (p_attribute4 = FND_API.G_MISS_CHAR)
                AND  (p_attribute5 = FND_API.G_MISS_CHAR)
                AND  (p_attribute6 = FND_API.G_MISS_CHAR)
                AND  (p_attribute7 = FND_API.G_MISS_CHAR)
                AND  (p_attribute8 = FND_API.G_MISS_CHAR)
                AND  (p_attribute9 = FND_API.G_MISS_CHAR)
                AND  (p_attribute10 = FND_API.G_MISS_CHAR)
                AND  (p_attribute11 = FND_API.G_MISS_CHAR)
                AND  (p_attribute12 = FND_API.G_MISS_CHAR)
                AND  (p_attribute13 = FND_API.G_MISS_CHAR)
                AND  (p_attribute14 = FND_API.G_MISS_CHAR)
                AND  (p_attribute15 = FND_API.G_MISS_CHAR)
                AND  (p_context     = FND_API.G_MISS_CHAR) THEN


		     RETURN TRUE;

                ELSE

                2056666 */


		  IF p_attribute1 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute1;

                  END IF;

                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE1'
                   ,  column_value  => l_column_value);


		  IF p_attribute2 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute2;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE2'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute3 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute3;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE3'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute4 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute4;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE4'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute5 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute5;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE5'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute6 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute6;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE6'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute7 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute7;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE7'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute8 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute8;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE8'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute9 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute9;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE9'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute10 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute10;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE10'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute11 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute11;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE11'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute12 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute12;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE12'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute13 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute13;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE13'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute14 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute14;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE14'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute15 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute15;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE15'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute16 = FND_API.G_MISS_CHAR THEN -- For bug 2184255

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute16;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE16'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute17 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute17;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE17'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute18 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute18;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE18'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute19 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute19;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE19'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute20 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute20;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE20'
                   ,  column_value  =>  l_column_value);  --End bug 2184255


		  IF p_context = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_context;

                  END IF;
		  FND_FLEX_DESCVAL.Set_Context_Value
		   ( context_value   => l_column_value);

                  IF p_document_type = 'ORDER' THEN
                   IF NOT OE_Validate.Desc_Flex('OE_LINE_ATTRIBUTES') THEN
			RETURN FALSE;
                   END IF;
                  ELSIF p_document_type = 'BLANKET' THEN
                   IF NOT OE_Validate.Desc_Flex('OE_BLKT_LINE_ATTRIBUTES') THEN
			RETURN FALSE;
                   END IF;
                  END IF;

                /* commented out for 2056666
                END IF;
                */

    RETURN TRUE;

EXCEPTION

   WHEN OTHERS THEN


     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN

        OE_MSG_PUB.Add_Exc_Msg
	( G_PKG_NAME
          , 'Line_Desc_Flex');
     END IF;


     RETURN FALSE;

END Line_Desc_Flex;

FUNCTION G_Line_Desc_Flex (p_context IN VARCHAR2,
			   p_attribute1 IN VARCHAR2,
                           p_attribute2 IN VARCHAR2,
                           p_attribute3 IN VARCHAR2,
                           p_attribute4 IN VARCHAR2,
                           p_attribute5 IN VARCHAR2,
                           p_attribute6 IN VARCHAR2,
                           p_attribute7 IN VARCHAR2,
                           p_attribute8 IN VARCHAR2,
                           p_attribute9 IN VARCHAR2,
                           p_attribute10 IN VARCHAR2,
                           p_attribute11 IN VARCHAR2,
                           p_attribute12 IN VARCHAR2,
                           p_attribute13 IN VARCHAR2,
                           p_attribute14 IN VARCHAR2,
                           p_attribute15 IN VARCHAR2,
                           p_attribute16 IN VARCHAR2,
                           p_attribute17 IN VARCHAR2,
                           p_attribute18 IN VARCHAR2,
                           p_attribute19 IN VARCHAR2,
                           p_attribute20 IN VARCHAR2)
RETURN BOOLEAN
IS
l_column_value VARCHAR2(240) := null;
BEGIN

--        OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'GLOBAL_ATTRIBUTE_CATEGORY');


                g_context_name := 'GLOBAL_ATTRIBUTE_CATEGORY';
		g_attribute1_name := 'GLOBAL_ATTRIBUTE1';
		g_attribute2_name := 'GLOBAL_ATTRIBUTE2';
		g_attribute3_name := 'GLOBAL_ATTRIBUTE3';
		g_attribute4_name := 'GLOBAL_ATTRIBUTE4';
		g_attribute5_name := 'GLOBAL_ATTRIBUTE5';
		g_attribute6_name := 'GLOBAL_ATTRIBUTE6';
		g_attribute7_name := 'GLOBAL_ATTRIBUTE7';
		g_attribute8_name := 'GLOBAL_ATTRIBUTE8';
		g_attribute9_name := 'GLOBAL_ATTRIBUTE9';
		g_attribute10_name := 'GLOBAL_ATTRIBUTE10';
		g_attribute11_name := 'GLOBAL_ATTRIBUTE11';
		g_attribute12_name := 'GLOBAL_ATTRIBUTE12';
		g_attribute13_name := 'GLOBAL_ATTRIBUTE13';
		g_attribute14_name := 'GLOBAL_ATTRIBUTE14';
		g_attribute15_name := 'GLOBAL_ATTRIBUTE15';
		g_attribute16_name := 'GLOBAL_ATTRIBUTE16';
		g_attribute17_name := 'GLOBAL_ATTRIBUTE17';
		g_attribute18_name := 'GLOBAL_ATTRIBUTE18';
		g_attribute19_name := 'GLOBAL_ATTRIBUTE19';
		g_attribute20_name := 'GLOBAL_ATTRIBUTE20';

		/*IF   (p_attribute1 = FND_API.G_MISS_CHAR)
                AND  (p_attribute2 = FND_API.G_MISS_CHAR)
		AND  (p_attribute3 = FND_API.G_MISS_CHAR)
                AND  (p_attribute4 = FND_API.G_MISS_CHAR)
                AND  (p_attribute5 = FND_API.G_MISS_CHAR)
                AND  (p_attribute6 = FND_API.G_MISS_CHAR)
                AND  (p_attribute7 = FND_API.G_MISS_CHAR)
                AND  (p_attribute8 = FND_API.G_MISS_CHAR)
                AND  (p_attribute9 = FND_API.G_MISS_CHAR)
                AND  (p_attribute10 = FND_API.G_MISS_CHAR)
                AND  (p_attribute11 = FND_API.G_MISS_CHAR)
                AND  (p_attribute12 = FND_API.G_MISS_CHAR)
                AND  (p_attribute13 = FND_API.G_MISS_CHAR)
                AND  (p_attribute14 = FND_API.G_MISS_CHAR)
                AND  (p_attribute15 = FND_API.G_MISS_CHAR)
                AND  (p_attribute16 = FND_API.G_MISS_CHAR)
                AND  (p_attribute17 = FND_API.G_MISS_CHAR)
                AND  (p_attribute18 = FND_API.G_MISS_CHAR)
                AND  (p_attribute19 = FND_API.G_MISS_CHAR)
                AND  (p_attribute20 = FND_API.G_MISS_CHAR)
                AND  (p_context     = FND_API.G_MISS_CHAR) THEN


		     RETURN TRUE;

                ELSE */

		  IF p_attribute1 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute1;

                  END IF;

                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE1'
                   ,  column_value  => l_column_value);


		  IF p_attribute2 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute2;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE2'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute3 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute3;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE3'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute4 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute4;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE4'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute5 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute5;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE5'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute6 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute6;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE6'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute7 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute7;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE7'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute8 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute8;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE8'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute9 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute9;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE9'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute10 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute10;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE10'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute11 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute11;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE11'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute12 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute12;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE12'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute13 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute13;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE13'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute14 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute14;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE14'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute15 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute15;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE15'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute16 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute16;

                  END IF;

                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE16'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute17 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute17;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE17'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute18 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute18;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE18'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute19 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute19;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE19'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute20 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute20;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'GLOBAL_ATTRIBUTE20'
                   ,  column_value  =>  l_column_value);

		  IF p_context = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_context;

                  END IF;
		  FND_FLEX_DESCVAL.Set_Context_Value
		   ( context_value   => l_column_value);
/*commenting this code due to bug# 993103
                   IF NOT OE_Validate.Desc_Flex('OE_LINE_GLOBAL_ATTRIBUTE') THEN

			RETURN FALSE;
                   END IF;  */

                --END IF;

    RETURN TRUE;

EXCEPTION

   WHEN OTHERS THEN


     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN

        OE_MSG_PUB.Add_Exc_Msg
	( G_PKG_NAME
          , 'G_Line_Desc_Flex');
     END IF;

     RETURN FALSE;
END G_Line_Desc_Flex;

FUNCTION P_Line_Desc_Flex (p_context IN VARCHAR2,
			   p_attribute1 IN VARCHAR2,
                           p_attribute2 IN VARCHAR2,
                           p_attribute3 IN VARCHAR2,
                           p_attribute4 IN VARCHAR2,
                           p_attribute5 IN VARCHAR2,
                           p_attribute6 IN VARCHAR2,
                           p_attribute7 IN VARCHAR2,
                           p_attribute8 IN VARCHAR2,
                           p_attribute9 IN VARCHAR2,
                           p_attribute10 IN VARCHAR2)

RETURN BOOLEAN
IS
l_column_value VARCHAR2(240) := null;
BEGIN

   --        OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PRICING_CONTEXT');

                g_context_name := 'PRICING_CONTEXT';
		g_attribute1_name := 'PRICING_ATTRIBUTE1';
		g_attribute2_name := 'PRICING_ATTRIBUTE2';
		g_attribute3_name := 'PRICING_ATTRIBUTE3';
		g_attribute4_name := 'PRICING_ATTRIBUTE4';
		g_attribute5_name := 'PRICING_ATTRIBUTE5';
		g_attribute6_name := 'PRICING_ATTRIBUTE6';
		g_attribute7_name := 'PRICING_ATTRIBUTE7';
		g_attribute8_name := 'PRICING_ATTRIBUTE8';
		g_attribute9_name := 'PRICING_ATTRIBUTE9';
		g_attribute10_name := 'PRICING_ATTRIBUTE10';

		/*IF   (p_attribute1 = FND_API.G_MISS_CHAR)
                 AND  (p_attribute2 = FND_API.G_MISS_CHAR)
	        AND  (p_attribute3 = FND_API.G_MISS_CHAR)
                AND  (p_attribute4 = FND_API.G_MISS_CHAR)
                AND  (p_attribute5 = FND_API.G_MISS_CHAR)
                AND  (p_attribute6 = FND_API.G_MISS_CHAR)
                AND  (p_attribute7 = FND_API.G_MISS_CHAR)
                AND  (p_attribute8 = FND_API.G_MISS_CHAR)
                AND  (p_attribute9 = FND_API.G_MISS_CHAR)
                AND  (p_attribute10 = FND_API.G_MISS_CHAR)
                AND  (p_context     = FND_API.G_MISS_CHAR) THEN


		     RETURN TRUE;

                ELSE*/


		  IF p_attribute1 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute1;

                  END IF;

                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'PRICING_ATTRIBUTE1'
                   ,  column_value  => l_column_value);


		  IF p_attribute2 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute2;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'PRICING_ATTRIBUTE2'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute3 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute3;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'PRICING_ATTRIBUTE3'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute4 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute4;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'PRICING_ATTRIBUTE4'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute5 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute5;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'PRICING_ATTRIBUTE5'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute6 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute6;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'PRICING_ATTRIBUTE6'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute7 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute7;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'PRICING_ATTRIBUTE7'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute8 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute8;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'PRICING_ATTRIBUTE8'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute9 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute9;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'PRICING_ATTRIBUTE9'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute10 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute10;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'PRICING_ATTRIBUTE10'
                   ,  column_value  =>  l_column_value);


		  IF p_context = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_context;

                  END IF;
		  FND_FLEX_DESCVAL.Set_Context_Value
		   ( context_value   => l_column_value);

                   IF NOT OE_Validate.Desc_Flex('OE_LINE_PRICING_ATTRIBUTE') THEN
			RETURN FALSE;
                   END IF;


               -- END IF;

    RETURN TRUE;

EXCEPTION

   WHEN OTHERS THEN


     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN

        OE_MSG_PUB.Add_Exc_Msg
	( G_PKG_NAME
          , 'P_Line_Desc_Flex');
     END IF;


     RETURN FALSE;

END P_Line_Desc_Flex;


FUNCTION I_Line_Desc_Flex (p_context IN VARCHAR2,
			         p_attribute1 IN VARCHAR2,
                           p_attribute2 IN VARCHAR2,
                           p_attribute3 IN VARCHAR2,
                           p_attribute4 IN VARCHAR2,
                           p_attribute5 IN VARCHAR2,
                           p_attribute6 IN VARCHAR2,
                           p_attribute7 IN VARCHAR2,
                           p_attribute8 IN VARCHAR2,
                           p_attribute9 IN VARCHAR2,
                           p_attribute10 IN VARCHAR2,
                           p_attribute11 IN VARCHAR2,
                           p_attribute12 IN VARCHAR2,
                           p_attribute13 IN VARCHAR2,
                           p_attribute14 IN VARCHAR2,
                           p_attribute15 IN VARCHAR2,
			         p_attribute16 IN VARCHAR2,
                           p_attribute17 IN VARCHAR2,
                           p_attribute18 IN VARCHAR2,
                           p_attribute19 IN VARCHAR2,
                           p_attribute20 IN VARCHAR2,
                           p_attribute21 IN VARCHAR2,
                           p_attribute22 IN VARCHAR2,
                           p_attribute23 IN VARCHAR2,
                           p_attribute24 IN VARCHAR2,
                           p_attribute25 IN VARCHAR2,
                           p_attribute26 IN VARCHAR2,
                           p_attribute27 IN VARCHAR2,
                           p_attribute28 IN VARCHAR2,
                           p_attribute29 IN VARCHAR2,
                           p_attribute30 IN VARCHAR2)


RETURN BOOLEAN
IS
l_column_value VARCHAR2(240) := null;

 l_status    VARCHAR2(1) := NULL;
 l_industry  VARCHAR2(30) := NULL;
 l_rlm_product_id NUMBER := 662;

BEGIN

--        OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'INDUSTRY_CONTEXT');

   /*** commented out for bug 1701377
   -- Check if RLM is installed
   if (FND_INSTALLATION.Get(l_rlm_product_id,l_rlm_product_id,
                                                l_status, l_industry )) then

        if (l_status = 'I') then
           G_RLM_INSTALLED_FLAG := 'Y';
        else
           G_RLM_INSTALLED_FLAG := 'N';
        end if;

   else
        G_RLM_INSTALLED_FLAG := 'N';
   end if;
   OE_DEBUG_PUB.ADD('OEXSVATB:G_RLM_INSTALLED_FLAG:' || G_RLM_INSTALLED_FLAG);
     ***/

                g_context_name := 'INDUSTRY_CONTEXT';
		g_attribute1_name := 'INDUSTRY_ATTRIBUTE1';
		g_attribute2_name := 'INDUSTRY_ATTRIBUTE2';
		g_attribute3_name := 'INDUSTRY_ATTRIBUTE3';
		g_attribute4_name := 'INDUSTRY_ATTRIBUTE4';
		g_attribute5_name := 'INDUSTRY_ATTRIBUTE5';
		g_attribute6_name := 'INDUSTRY_ATTRIBUTE6';
		g_attribute7_name := 'INDUSTRY_ATTRIBUTE7';
		g_attribute8_name := 'INDUSTRY_ATTRIBUTE8';
		g_attribute9_name := 'INDUSTRY_ATTRIBUTE9';
		g_attribute10_name := 'INDUSTRY_ATTRIBUTE10';
		g_attribute11_name := 'INDUSTRY_ATTRIBUTE11';
		g_attribute12_name := 'INDUSTRY_ATTRIBUTE12';
		g_attribute13_name := 'INDUSTRY_ATTRIBUTE13';
		g_attribute14_name := 'INDUSTRY_ATTRIBUTE14';
		g_attribute15_name := 'INDUSTRY_ATTRIBUTE15';
		g_attribute16_name := 'INDUSTRY_ATTRIBUTE16';
		g_attribute17_name := 'INDUSTRY_ATTRIBUTE17';
		g_attribute18_name := 'INDUSTRY_ATTRIBUTE18';
		g_attribute19_name := 'INDUSTRY_ATTRIBUTE19';
		g_attribute20_name := 'INDUSTRY_ATTRIBUTE20';
		g_attribute21_name := 'INDUSTRY_ATTRIBUTE21';
		g_attribute22_name := 'INDUSTRY_ATTRIBUTE22';
		g_attribute23_name := 'INDUSTRY_ATTRIBUTE23';
		g_attribute24_name := 'INDUSTRY_ATTRIBUTE24';
		g_attribute25_name := 'INDUSTRY_ATTRIBUTE25';
		g_attribute26_name := 'INDUSTRY_ATTRIBUTE26';
		g_attribute27_name := 'INDUSTRY_ATTRIBUTE27';
		g_attribute28_name := 'INDUSTRY_ATTRIBUTE28';
		g_attribute29_name := 'INDUSTRY_ATTRIBUTE29';
		g_attribute30_name := 'INDUSTRY_ATTRIBUTE30';

		/*IF  (p_attribute1 = FND_API.G_MISS_CHAR)
                AND  (p_attribute2 = FND_API.G_MISS_CHAR)
		    AND  (p_attribute3 = FND_API.G_MISS_CHAR)
                AND  (p_attribute4 = FND_API.G_MISS_CHAR)
                AND  (p_attribute5 = FND_API.G_MISS_CHAR)
                AND  (p_attribute6 = FND_API.G_MISS_CHAR)
                AND  (p_attribute7 = FND_API.G_MISS_CHAR)
                AND  (p_attribute8 = FND_API.G_MISS_CHAR)
                AND  (p_attribute9 = FND_API.G_MISS_CHAR)
                AND  (p_attribute10 = FND_API.G_MISS_CHAR)
                AND  (p_attribute11 = FND_API.G_MISS_CHAR)
                AND  (p_attribute12 = FND_API.G_MISS_CHAR)
                AND  (p_attribute13 = FND_API.G_MISS_CHAR)
                AND  (p_attribute14 = FND_API.G_MISS_CHAR)
                AND  (p_attribute15 = FND_API.G_MISS_CHAR)
                AND  (p_attribute16 = FND_API.G_MISS_CHAR)
		    AND  (p_attribute17 = FND_API.G_MISS_CHAR)
                AND  (p_attribute18 = FND_API.G_MISS_CHAR)
                AND  (p_attribute19 = FND_API.G_MISS_CHAR)
                AND  (p_attribute20 = FND_API.G_MISS_CHAR)
                AND  (p_attribute21 = FND_API.G_MISS_CHAR)
                AND  (p_attribute22 = FND_API.G_MISS_CHAR)
                AND  (p_attribute23 = FND_API.G_MISS_CHAR)
                AND  (p_attribute24 = FND_API.G_MISS_CHAR)
                AND  (p_attribute25 = FND_API.G_MISS_CHAR)
                AND  (p_attribute26 = FND_API.G_MISS_CHAR)
                AND  (p_attribute27 = FND_API.G_MISS_CHAR)
                AND  (p_attribute28 = FND_API.G_MISS_CHAR)
                AND  (p_attribute29 = FND_API.G_MISS_CHAR)
                AND  (p_attribute30 = FND_API.G_MISS_CHAR)
                AND  (p_context     = FND_API.G_MISS_CHAR) THEN


		     RETURN TRUE;

                ELSE */


		  IF p_attribute1 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute1;

                  END IF;

                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE1'
                   ,  column_value  => l_column_value);


		  IF p_attribute2 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute2;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE2'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute3 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute3;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE3'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute4 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute4;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE4'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute5 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute5;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE5'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute6 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute6;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE6'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute7 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute7;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE7'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute8 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute8;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE8'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute9 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute9;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE9'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute10 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute10;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE10'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute11 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute11;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE11'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute12 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute12;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE12'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute13 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute13;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE13'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute14 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute14;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE14'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute15 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute15;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE15'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute16 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute16;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE16'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute17 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute17;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE17'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute18 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute18;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE18'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute19 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute19;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE19'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute20 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute20;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE20'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute21 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute21;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE21'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute22 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute22;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE22'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute23 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute23;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE23'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute24 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute24;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE24'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute25 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute25;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE25'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute26 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute26;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE26'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute27 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute27;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE27'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute28 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute28;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE28'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute29 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute29;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE29'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute30 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute30;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'INDUSTRY_ATTRIBUTE30'
                   ,  column_value  =>  l_column_value);



		  IF p_context = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_context;

                  END IF;
		  FND_FLEX_DESCVAL.Set_Context_Value
		   ( context_value   => l_column_value);

           -- bug 1701377
		 -- check if RLM is installed
	      IF OE_GLOBALS.G_RLM_INSTALLED IS NULL THEN
		   OE_GLOBALS.G_RLM_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(662);
           END IF;
		 -- end of 1701377

	      IF OE_GLOBALS.G_RLM_INSTALLED = 'Y' THEN

           -- IF (G_RLM_INSTALLED_FLAG = 'Y') THEN
              IF NOT OE_Validate.Desc_Flex('RLM_SCHEDULE_LINES') THEN
			RETURN FALSE;
              END IF;
           ELSE
              IF NOT OE_Validate.Desc_Flex('OE_LINE_INDUSTRY_ATTRIBUTE') THEN
			RETURN FALSE;
              END IF;
           END IF;

                --END IF;

    RETURN TRUE;

EXCEPTION

   WHEN OTHERS THEN


     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN

        OE_MSG_PUB.Add_Exc_Msg
	( G_PKG_NAME
          , 'I_Line_Desc_Flex');
     END IF;


     RETURN FALSE;

END I_Line_Desc_Flex;


FUNCTION TP_Line_Desc_Flex (p_context IN VARCHAR2,
			         p_attribute1 IN VARCHAR2,
                           p_attribute2 IN VARCHAR2,
                           p_attribute3 IN VARCHAR2,
                           p_attribute4 IN VARCHAR2,
                           p_attribute5 IN VARCHAR2,
                           p_attribute6 IN VARCHAR2,
                           p_attribute7 IN VARCHAR2,
                           p_attribute8 IN VARCHAR2,
                           p_attribute9 IN VARCHAR2,
                           p_attribute10 IN VARCHAR2,
                           p_attribute11 IN VARCHAR2,
                           p_attribute12 IN VARCHAR2,
                           p_attribute13 IN VARCHAR2,
                           p_attribute14 IN VARCHAR2,
                           p_attribute15 IN VARCHAR2)


RETURN BOOLEAN
IS
l_column_value VARCHAR2(240) := null;
BEGIN

--        OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'TP_CONTEXT');

                g_context_name := 'TP_CONTEXT';
		g_attribute1_name := 'TP_ATTRIBUTE1';
		g_attribute2_name := 'TP_ATTRIBUTE2';
		g_attribute3_name := 'TP_ATTRIBUTE3';
		g_attribute4_name := 'TP_ATTRIBUTE4';
		g_attribute5_name := 'TP_ATTRIBUTE5';
		g_attribute6_name := 'TP_ATTRIBUTE6';
		g_attribute7_name := 'TP_ATTRIBUTE7';
		g_attribute8_name := 'TP_ATTRIBUTE8';
		g_attribute9_name := 'TP_ATTRIBUTE9';
		g_attribute10_name := 'TP_ATTRIBUTE10';
		g_attribute11_name := 'TP_ATTRIBUTE11';
		g_attribute12_name := 'TP_ATTRIBUTE12';
		g_attribute13_name := 'TP_ATTRIBUTE13';
		g_attribute14_name := 'TP_ATTRIBUTE14';
		g_attribute15_name := 'TP_ATTRIBUTE15';

		/*IF  (p_attribute1 = FND_API.G_MISS_CHAR)
                AND  (p_attribute2 = FND_API.G_MISS_CHAR)
		      AND  (p_attribute3 = FND_API.G_MISS_CHAR)
                AND  (p_attribute4 = FND_API.G_MISS_CHAR)
                AND  (p_attribute5 = FND_API.G_MISS_CHAR)
                AND  (p_attribute6 = FND_API.G_MISS_CHAR)
                AND  (p_attribute7 = FND_API.G_MISS_CHAR)
                AND  (p_attribute8 = FND_API.G_MISS_CHAR)
                AND  (p_attribute9 = FND_API.G_MISS_CHAR)
                AND  (p_attribute10 = FND_API.G_MISS_CHAR)
                AND  (p_attribute11 = FND_API.G_MISS_CHAR)
                AND  (p_attribute12 = FND_API.G_MISS_CHAR)
                AND  (p_attribute13 = FND_API.G_MISS_CHAR)
                AND  (p_attribute14 = FND_API.G_MISS_CHAR)
                AND  (p_attribute15 = FND_API.G_MISS_CHAR)
                AND  (p_context     = FND_API.G_MISS_CHAR) THEN


		     RETURN TRUE;

                ELSE */


		  IF p_attribute1 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute1;

                  END IF;

                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE1'
                   ,  column_value  => l_column_value);


		  IF p_attribute2 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute2;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE2'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute3 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute3;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE3'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute4 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute4;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE4'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute5 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute5;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE5'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute6 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute6;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE6'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute7 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute7;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE7'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute8 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute8;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE8'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute9 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute9;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE9'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute10 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute10;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE10'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute11 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute11;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE11'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute12 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute12;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE12'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute13 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute13;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE13'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute14 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute14;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE14'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute15 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute15;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'TP_ATTRIBUTE15'
                   ,  column_value  =>  l_column_value);



		  IF p_context = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_context;

                  END IF;
		  FND_FLEX_DESCVAL.Set_Context_Value
		   ( context_value   => l_column_value);

                   IF NOT OE_Validate.Desc_Flex('OE_LINE_TP_ATTRIBUTES') THEN
			RETURN FALSE;
                   END IF;


                --END IF;

    RETURN TRUE;

EXCEPTION

   WHEN OTHERS THEN


     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN

        OE_MSG_PUB.Add_Exc_Msg
	( G_PKG_NAME
          , 'TP_Line_Desc_Flex');
     END IF;


     RETURN FALSE;

END TP_Line_Desc_Flex;


FUNCTION R_Line_Desc_Flex (p_context IN VARCHAR2,
			   p_attribute1 IN VARCHAR2,
                           p_attribute2 IN VARCHAR2,
                           p_attribute3 IN VARCHAR2,
                           p_attribute4 IN VARCHAR2,
                           p_attribute5 IN VARCHAR2,
                           p_attribute6 IN VARCHAR2,
                           p_attribute7 IN VARCHAR2,
                           p_attribute8 IN VARCHAR2,
                           p_attribute9 IN VARCHAR2,
                           p_attribute10 IN VARCHAR2,
                           p_attribute11 IN VARCHAR2,
                           p_attribute12 IN VARCHAR2,
                           p_attribute13 IN VARCHAR2,
                           p_attribute14 IN VARCHAR2,
                           p_attribute15 IN VARCHAR2)

RETURN BOOLEAN
IS
l_column_value VARCHAR2(240) := null;
BEGIN

   --        OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'RETURN_CONTEXT');

   /* Following assignments have been added for bug 2755607, since the call
      to oe_validate.desc_flex is commented for Return Flex field, the global
      variables holding the flex values  need to be assigned with NULL, this
      can commented when call to oe_validate.desc_flex is uncommented below */

    		g_context     := NULL;
    		g_attribute1  := NULL;
    		g_attribute2  := NULL;
    		g_attribute3  := NULL;
    		g_attribute4  := NULL;
    		g_attribute5  := NULL;
    		g_attribute6  := NULL;
    		g_attribute7  := NULL;
    		g_attribute8  := NULL;
    		g_attribute9  := NULL;
    		g_attribute10 := NULL;
    		g_attribute11 := NULL;
    		g_attribute12 := NULL;
    		g_attribute13 := NULL;
    		g_attribute14 := NULL;
    		g_attribute15 := NULL;

                g_context_name := 'RETURN_CONTEXT';
		g_attribute1_name := 'RETURN_ATTRIBUTE1';
		g_attribute2_name := 'RETURN_ATTRIBUTE2';
		g_attribute3_name := 'RETURN_ATTRIBUTE3';
		g_attribute4_name := 'RETURN_ATTRIBUTE4';
		g_attribute5_name := 'RETURN_ATTRIBUTE5';
		g_attribute6_name := 'RETURN_ATTRIBUTE6';
		g_attribute7_name := 'RETURN_ATTRIBUTE7';
		g_attribute8_name := 'RETURN_ATTRIBUTE8';
		g_attribute9_name := 'RETURN_ATTRIBUTE9';
		g_attribute10_name := 'RETURN_ATTRIBUTE10';
		g_attribute11_name := 'RETURN_ATTRIBUTE11';
		g_attribute12_name := 'RETURN_ATTRIBUTE12';
		g_attribute13_name := 'RETURN_ATTRIBUTE13';
		g_attribute14_name := 'RETURN_ATTRIBUTE14';
		g_attribute15_name := 'RETURN_ATTRIBUTE15';

		/*IF   (p_attribute1 = FND_API.G_MISS_CHAR)
                AND  (p_attribute2 = FND_API.G_MISS_CHAR)
		AND  (p_attribute3 = FND_API.G_MISS_CHAR)
                AND  (p_attribute4 = FND_API.G_MISS_CHAR)
                AND  (p_attribute5 = FND_API.G_MISS_CHAR)
                AND  (p_attribute6 = FND_API.G_MISS_CHAR)
                AND  (p_attribute7 = FND_API.G_MISS_CHAR)
                AND  (p_attribute8 = FND_API.G_MISS_CHAR)
                AND  (p_attribute9 = FND_API.G_MISS_CHAR)
                AND  (p_attribute10 = FND_API.G_MISS_CHAR)
                AND  (p_attribute11 = FND_API.G_MISS_CHAR)
                AND  (p_attribute12 = FND_API.G_MISS_CHAR)
                AND  (p_attribute13 = FND_API.G_MISS_CHAR)
                AND  (p_attribute14 = FND_API.G_MISS_CHAR)
                AND  (p_attribute15 = FND_API.G_MISS_CHAR)
                AND  (p_context     = FND_API.G_MISS_CHAR) THEN


		     RETURN TRUE;

                ELSE */


		  IF p_attribute1 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute1;

                  END IF;

                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'RETURN_ATTRIBUTE1'
                   ,  column_value  => l_column_value);


		  IF p_attribute2 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute2;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'RETURN_ATTRIBUTE2'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute3 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute3;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'RETURN_ATTRIBUTE3'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute4 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute4;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'RETURN_ATTRIBUTE4'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute5 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute5;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'RETURN_ATTRIBUTE5'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute6 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute6;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'RETURN_ATTRIBUTE6'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute7 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute7;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'RETURN_ATTRIBUTE7'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute8 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute8;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'RETURN_ATTRIBUTE8'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute9 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute9;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'RETURN_ATTRIBUTE9'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute10 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute10;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'RETURN_ATTRIBUTE10'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute11 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute11;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'RETURN_ATTRIBUTE11'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute12 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute12;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'RETURN_ATTRIBUTE12'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute13 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute13;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'RETURN_ATTRIBUTE13'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute14 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute14;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'RETURN_ATTRIBUTE14'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute15 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute15;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'RETURN_ATTRIBUTE15'
                   ,  column_value  =>  l_column_value);

		  IF p_context = FND_API.G_MISS_CHAR THEN

		    l_column_value := null;

	       ELSE

		    l_column_value := p_context;

            END IF;

		  FND_FLEX_DESCVAL.Set_Context_Value
		   ( context_value   => l_column_value);


	-- Remove after fixing :block.field_name stuff

        --    IF NOT OE_Validate.Desc_Flex('OE_LINE_RETURN_ATTRIBUTE') THEN
        --					RETURN FALSE;
        --    END IF;

--         END IF;

    RETURN TRUE;

EXCEPTION

   WHEN OTHERS THEN


     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN

        OE_MSG_PUB.Add_Exc_Msg
	( G_PKG_NAME
          , 'R_Line_Desc_Flex');
     END IF;


     RETURN FALSE;

END R_Line_Desc_Flex;


FUNCTION Price_Adj_Desc_Flex (p_context IN VARCHAR2,
			   p_attribute1 IN VARCHAR2,
                           p_attribute2 IN VARCHAR2,
                           p_attribute3 IN VARCHAR2,
                           p_attribute4 IN VARCHAR2,
                           p_attribute5 IN VARCHAR2,
                           p_attribute6 IN VARCHAR2,
                           p_attribute7 IN VARCHAR2,
                           p_attribute8 IN VARCHAR2,
                           p_attribute9 IN VARCHAR2,
                           p_attribute10 IN VARCHAR2,
                           p_attribute11 IN VARCHAR2,
                           p_attribute12 IN VARCHAR2,
                           p_attribute13 IN VARCHAR2,
                           p_attribute14 IN VARCHAR2,
                           p_attribute15 IN VARCHAR2)

RETURN BOOLEAN
IS
l_column_value VARCHAR2(240) := null;
BEGIN

--        OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CONTEXT');

		IF   (p_attribute1 = FND_API.G_MISS_CHAR)
                AND  (p_attribute2 = FND_API.G_MISS_CHAR)
	        AND  (p_attribute3 = FND_API.G_MISS_CHAR)
                AND  (p_attribute4 = FND_API.G_MISS_CHAR)
                AND  (p_attribute5 = FND_API.G_MISS_CHAR)
                AND  (p_attribute6 = FND_API.G_MISS_CHAR)
                AND  (p_attribute7 = FND_API.G_MISS_CHAR)
                AND  (p_attribute8 = FND_API.G_MISS_CHAR)
                AND  (p_attribute9 = FND_API.G_MISS_CHAR)
                AND  (p_attribute10 = FND_API.G_MISS_CHAR)
                AND  (p_attribute11 = FND_API.G_MISS_CHAR)
                AND  (p_attribute12 = FND_API.G_MISS_CHAR)
                AND  (p_attribute13 = FND_API.G_MISS_CHAR)
                AND  (p_attribute14 = FND_API.G_MISS_CHAR)
                AND  (p_attribute15 = FND_API.G_MISS_CHAR)
                AND  (p_context     = FND_API.G_MISS_CHAR) THEN


		     RETURN TRUE;

                ELSE


		  IF p_attribute1 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute1;

                  END IF;

                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE1'
                   ,  column_value  => l_column_value);


		  IF p_attribute2 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute2;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE2'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute3 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute3;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE3'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute4 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute4;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE4'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute5 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute5;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE5'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute6 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute6;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE6'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute7 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute7;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE7'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute8 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute8;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE8'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute9 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute9;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE9'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute10 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute10;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE10'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute11 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute11;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE11'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute12 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute12;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE12'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute13 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute13;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE13'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute14 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute14;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE14'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute15 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute15;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE15'
                   ,  column_value  =>  l_column_value);

		  IF p_context = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_context;

                  END IF;
		  FND_FLEX_DESCVAL.Set_Context_Value
		   ( context_value   => l_column_value);

                   IF NOT OE_Validate.Desc_Flex('OE_PRICE_ADJUSTMENT') THEN
			RETURN FALSE;
                   END IF;


                END IF;

    RETURN TRUE;

EXCEPTION

   WHEN OTHERS THEN


     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN

        OE_MSG_PUB.Add_Exc_Msg
	( G_PKG_NAME
          , 'Price_Adj_Desc_Flex');
     END IF;


     RETURN FALSE;


END Price_Adj_Desc_Flex;

FUNCTION Sales_Credits_Desc_Flex (p_context IN VARCHAR2,
			   p_attribute1 IN VARCHAR2,
                           p_attribute2 IN VARCHAR2,
                           p_attribute3 IN VARCHAR2,
                           p_attribute4 IN VARCHAR2,
                           p_attribute5 IN VARCHAR2,
                           p_attribute6 IN VARCHAR2,
                           p_attribute7 IN VARCHAR2,
                           p_attribute8 IN VARCHAR2,
                           p_attribute9 IN VARCHAR2,
                           p_attribute10 IN VARCHAR2,
                           p_attribute11 IN VARCHAR2,
                           p_attribute12 IN VARCHAR2,
                           p_attribute13 IN VARCHAR2,
                           p_attribute14 IN VARCHAR2,
                           p_attribute15 IN VARCHAR2)

RETURN BOOLEAN
IS
l_column_value VARCHAR2(240) := null;
BEGIN

--        OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CONTEXT');
-- Added the following lines to fix the bug 3006018 */
   --  Assiging the segment names so as to map the values after the FND call.
                g_context_name := 'CONTEXT';
                g_attribute1_name := 'ATTRIBUTE1';
                g_attribute2_name := 'ATTRIBUTE2';
                g_attribute3_name := 'ATTRIBUTE3';
                g_attribute4_name := 'ATTRIBUTE4';
                g_attribute5_name := 'ATTRIBUTE5';
                g_attribute6_name := 'ATTRIBUTE6';
                g_attribute7_name := 'ATTRIBUTE7';
                g_attribute8_name := 'ATTRIBUTE8';
                g_attribute9_name := 'ATTRIBUTE9';
                g_attribute10_name := 'ATTRIBUTE10';
                g_attribute11_name := 'ATTRIBUTE11';
                g_attribute12_name := 'ATTRIBUTE12';
                g_attribute13_name := 'ATTRIBUTE13';
                g_attribute14_name := 'ATTRIBUTE14';
                g_attribute15_name := 'ATTRIBUTE15';

/* Commented the following lines to fix the bug 3006018 */
/*


		IF   (p_attribute1 = FND_API.G_MISS_CHAR)
                AND  (p_attribute2 = FND_API.G_MISS_CHAR)
	        AND  (p_attribute3 = FND_API.G_MISS_CHAR)
                AND  (p_attribute4 = FND_API.G_MISS_CHAR)
                AND  (p_attribute5 = FND_API.G_MISS_CHAR)
                AND  (p_attribute6 = FND_API.G_MISS_CHAR)
                AND  (p_attribute7 = FND_API.G_MISS_CHAR)
                AND  (p_attribute8 = FND_API.G_MISS_CHAR)
                AND  (p_attribute9 = FND_API.G_MISS_CHAR)
                AND  (p_attribute10 = FND_API.G_MISS_CHAR)
                AND  (p_attribute11 = FND_API.G_MISS_CHAR)
                AND  (p_attribute12 = FND_API.G_MISS_CHAR)
                AND  (p_attribute13 = FND_API.G_MISS_CHAR)
                AND  (p_attribute14 = FND_API.G_MISS_CHAR)
                AND  (p_attribute15 = FND_API.G_MISS_CHAR)
                AND  (p_context     = FND_API.G_MISS_CHAR) THEN


		     RETURN TRUE;

                ELSE


*/
		  IF p_attribute1 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute1;

                  END IF;

                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE1'
                   ,  column_value  => l_column_value);


		  IF p_attribute2 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute2;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE2'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute3 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute3;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE3'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute4 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute4;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE4'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute5 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute5;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE5'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute6 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute6;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE6'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute7 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute7;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE7'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute8 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute8;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE8'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute9 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute9;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE9'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute10 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute10;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE10'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute11 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute11;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE11'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute12 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute12;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE12'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute13 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute13;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE13'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute14 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute14;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE14'
                   ,  column_value  =>  l_column_value);

		  IF p_attribute15 = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_attribute15;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE15'
                   ,  column_value  =>  l_column_value);

		  IF p_context = FND_API.G_MISS_CHAR THEN

		     l_column_value := null;

	          ELSE

		     l_column_value := p_context;

                  END IF;
		  FND_FLEX_DESCVAL.Set_Context_Value
		   ( context_value   => l_column_value);

                   IF NOT OE_Validate.Desc_Flex('OE_SALES_CREDITS_ATTRIBUTES') THEN
                        OE_DEBUG_PUB.add('Error at validation of OE_SALES_CREDITS_ATTRIBUTES ',1);
			RETURN FALSE;
                   END IF;


/* Commented the following line to fix the bug 3006018
                END IF;
*/


    RETURN TRUE;

EXCEPTION

   WHEN OTHERS THEN


     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN

        OE_MSG_PUB.Add_Exc_Msg
	( G_PKG_NAME
          , 'Sales_Credits_Desc_Flex');
     END IF;


    RETURN FALSE;

END Sales_Credits_Desc_Flex;


FUNCTION Return_reason ( p_return_reason_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type      	      VARCHAR2(80) :='CREDIT_MEMO_REASON';
BEGIN


    IF p_return_reason_code IS NULL OR
        p_return_reason_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_AR_LOOKUPS_V
    WHERE   LOOKUP_CODE = p_return_reason_code
    AND     LOOKUP_TYPE = l_lookup_type
    AND     ENABLED_FLAG = 'Y'
    AND     SYSDATE     BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                        AND NVL(END_DATE_ACTIVE, SYSDATE);


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'RETURN_REASON_CODE');


            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('return_reason_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;




        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'return_reason'
            );
        END IF;



        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Return_reason;

FUNCTION Split_from_line ( p_split_from_line_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_split_from_line_id IS NULL OR
        p_split_from_line_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_split_from_line_id;



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SPLIT_FROM_LINE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('split_from_line_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;



        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'split_from_line'
            );
        END IF;



        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Split_from_line;

FUNCTION Cust_production_seq_num ( p_cust_production_seq_num IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_cust_production_seq_num IS NULL OR
        p_cust_production_seq_num = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_cust_production_seq_num;



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CUST_PRODUCTION_SEQ_NUM');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('cust_production_seq_num'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;



        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'cust_production_seq_num'
            );
        END IF;



        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Cust_production_seq_num;


FUNCTION Authorized_to_ship ( p_authorized_to_ship_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_authorized_to_ship_flag IS NULL OR
        p_authorized_to_ship_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_authorized_to_ship_flag;



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'AUTHORIZED_TO_SHIP_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('authorized_to_ship_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;



        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'authorized_to_ship'
            );
        END IF;



        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Authorized_to_ship;

FUNCTION Veh_cus_item_cum_key ( p_veh_cus_item_cum_key_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_veh_cus_item_cum_key_id IS NULL OR
        p_veh_cus_item_cum_key_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_veh_cus_item_cum_key_id;



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'VEH_CUS_ITEM_CUM_KEY_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('veh_cus_item_cum_key_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;



        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'veh_cus_item_cum_key'
            );
        END IF;



        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Veh_cus_item_cum_key;

FUNCTION Arrival_set ( p_arrival_set_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_arrival_set_id IS NULL OR
        p_arrival_set_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_arrival_set_id;



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ARRIVAL_SET_ID');


            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('arrival_set_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;



        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'arrival_set'
            );
        END IF;



        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Arrival_set;

FUNCTION Ship_set ( p_ship_set_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_ship_set_id IS NULL OR
        p_ship_set_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_ship_set_id;



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SHIP_SET_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('ship_set_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;



        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'ship_set'
            );
        END IF;



        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Ship_set;

FUNCTION Over_ship_reason ( p_over_ship_reason_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_over_ship_reason_code IS NULL OR
        p_over_ship_reason_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_over_ship_reason_code;



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'OVER_SHIP_REASON_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('over_ship_reason_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;



        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'over_ship_reason'
            );
        END IF;



        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Over_ship_reason;

FUNCTION Over_ship_resolved ( p_over_ship_resolved_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_over_ship_resolved_flag IS NULL OR
        p_over_ship_resolved_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;


    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_over_ship_resolved_flag;



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'OVER_SHIP_RESOLVED_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('over_ship_resolved_flag'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;



        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'over_ship_resolved'
            );
        END IF;



        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Over_ship_resolved;

FUNCTION Payment_Type ( p_payment_type_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type      	      VARCHAR2(80) :='PAYMENT TYPE';
BEGIN


    IF p_payment_type_code IS NULL OR
        p_payment_type_code = FND_API.G_MISS_CHAR OR
          p_payment_type_code = 'COMMITMENT'  /* Bug #3536642 */
    THEN
        oe_Debug_Pub.add('Returning True .. ');
        RETURN TRUE;
    END IF;

    IF OE_PrePayment_UTIL.IS_MULTIPLE_PAYMENTS_ENABLED THEN
       SELECT  'VALID'
       INTO    l_dummy
       FROM    oe_payment_types_vl
       WHERE   payment_type_code = p_payment_type_code
       AND     ENABLED_FLAG = 'Y';
    ELSE
       SELECT  'VALID'
       INTO    l_dummy
       FROM    OE_LOOKUPS
       WHERE   LOOKUP_CODE = p_payment_type_code
       AND     LOOKUP_TYPE = l_lookup_type
       AND     ENABLED_FLAG = 'Y'
       AND     SYSDATE     BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                           AND NVL(END_DATE_ACTIVE, SYSDATE);
    END IF;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PAYMENT_TYPE_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('payment_type_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Payment_Type'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Payment_Type;

FUNCTION Payment_Amount ( p_payment_amount IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_payment_amount IS NULL OR
        p_payment_amount = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_payment_amount;



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PAYMENT_AMOUNT');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('payment_amount'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;



        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'payment_amount'
            );
        END IF;



        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Payment_Amount;

FUNCTION Check_Number ( p_check_number IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_check_number IS NULL OR
        p_check_number = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_check_number;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CHECK_NUMBER');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('check_number'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_Number'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Check_Number;

FUNCTION Credit_Card ( p_credit_card_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type      	      VARCHAR2(80) :='CREDIT_CARD';
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN


    IF p_credit_card_code IS NULL OR
        p_credit_card_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;
    --IF l_debug_level > 0 THEN
	    --oe_debug_pub.add('Credit card code in oe_validate...'||p_Credit_card_code);
    --END IF;
    /*SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_LOOKUPS
    WHERE   LOOKUP_CODE = p_credit_card_code
    AND     LOOKUP_TYPE = l_lookup_type
    AND     ENABLED_FLAG = 'Y'
    AND     SYSDATE     BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                        AND NVL(END_DATE_ACTIVE, SYSDATE);*/
    --bug 5070961
    select 'VALID'
    into l_dummy
    from iby_creditcard_issuers_v
    where card_issuer_code = p_credit_card_code
    and rownum=1;

    IF l_debug_level > 0 THEN
	    oe_debug_pub.add('Value returned from iby table...'||l_dummy);
    END IF;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CREDIT_CARD_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('credit_card_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;

        --IF l_debug_level > 0 THEN
	    --oe_debug_pub.add('No data found in Credit card code in oe_validate...'||p_Credit_card_code);
        --END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Credit_Card'
            );
        END IF;

        --IF l_debug_level > 0 THEN
	    --oe_debug_pub.add('Others error in Credit card code in oe_validate...'||p_Credit_card_code);
        --END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Credit_Card;

FUNCTION Credit_Card_Holder_Name ( p_credit_card_holder_name IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_credit_card_holder_name IS NULL OR
        p_credit_card_holder_name = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_credit_card_holder_name;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CREDIT_CARD_HOLDER_NAME');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('credit_card_holder_name'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Credit_Card_Holder_Name'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Credit_Card_Holder_Name;

FUNCTION Credit_Card_Number ( p_credit_card_number IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_credit_card_number IS NULL OR
        p_credit_card_number = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_credit_card_number;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CREDIT_CARD_NUMBER');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('credit_card_number'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Credit_Card_Number'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Credit_Card_Number;

FUNCTION Credit_Card_Approval_Date ( p_credit_card_approval_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN
    IF p_credit_card_approval_date IS NULL OR
        p_credit_card_approval_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;
    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_credit_card_approval_date;
    RETURN TRUE;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CREDIT_CARD_APPROVAL_DATE');
           fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('credit_card_approval_date'));
           OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);
        END IF;
        RETURN FALSE;
    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Credit_Card_Approval_Date'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Credit_Card_Approval_Date;

FUNCTION Credit_Card_Expiration_Date ( p_credit_card_expiration_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN
    IF p_credit_card_expiration_date IS NULL OR
        p_credit_card_expiration_date = FND_API.G_MISS_DATE
    THEN
        RETURN TRUE;
    END IF;
    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_credit_card_expiration_date;
    RETURN TRUE;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CREDIT_CARD_EXPIRATION_DATE');
            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('credit_card_expiration_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);
        END IF;
        RETURN FALSE;
    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Credit_Card_Expiration_Date'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Credit_Card_Expiration_Date;

FUNCTION Credit_Card_Approval ( p_credit_card_approval_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_credit_card_approval_code IS NULL OR
        p_credit_card_approval_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_credit_card_approval_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CREDIT_CARD_APPROVAL_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('credit_card_approval_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Credit_Card_Approval'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Credit_Card_Approval;


FUNCTION First_Ack ( p_first_ack_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_first_ack_code IS NULL OR
        p_first_ack_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_first_ack_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	     OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'FIRST_ACK_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('first_ack_code'));
            OE_MSG_PUB.Add;

            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'First_Ack'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END First_Ack;


FUNCTION First_Ack_DATE ( p_first_ack_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_first_ack_date IS NULL OR
        p_first_ack_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_first_ack_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'FIRST_ACK_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('first_ack_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'First_Ack_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END First_Ack_Date;

FUNCTION Last_Ack ( p_last_ack_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_last_ack_code IS NULL OR
        p_last_ack_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_last_ack_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LAST_ACK_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('last_ack_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Last_Ack'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Last_Ack;


FUNCTION Last_Ack_DATE ( p_last_ack_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_last_ack_date IS NULL OR
        p_last_ack_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_last_ack_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'LAST_ACK_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('last_ack_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Last_Ack_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Last_Ack_Date;

FUNCTION End_Item_Unit_Number ( p_end_item_unit_number IN Varchar2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_end_item_unit_number IS NULL OR
        p_end_item_unit_number = FND_API.G_MISS_CHAR
    THEN
        RETURN TRUE;
    END IF;

      SELECT  'VALID'
      INTO     l_dummy
      FROM     pjm_unit_numbers_lov_v
      WHERE    unit_number = p_end_item_unit_number;

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'END_ITEM_UNIT_NUMBER');


            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('end_item_unit_number'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'end_item_unit_number'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END End_Item_Unit_Number;

FUNCTION Invoiced_Quantity ( p_invoiced_quantity IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_invoiced_quantity IS NULL OR
        p_invoiced_quantity = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_invoiced_quantity;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'INVOICED_QUANTITY');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('invoiced_quantity'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Invoiced_Quantity'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Invoiced_Quantity;


FUNCTION Service_Txn_Reason ( p_service_txn_reason IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_service_txn_reason IS NULL OR
        p_service_txn_reason = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_service_txn_reason;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SERVICE_TXN_TYPE_REASON');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Service_Txn_Reason'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Service_Txn_Reason'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Service_Txn_Reason;


FUNCTION Service_Txn_Comments ( p_service_txn_comments IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_service_txn_comments IS NULL OR
        p_service_txn_comments = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_service_txn_comments;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SERVICE_TXN_TYPE_COMMENTS');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Service_Txn_Comments'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Service_Txn_Comments'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Service_Txn_Comments;


FUNCTION Service_Duration ( p_service_duration IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_service_duration IS NULL OR
        p_service_duration = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_service_duration;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Serviced_Duration');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Service_Duration'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Serviced_Duration'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Service_Duration;

FUNCTION Service_Period ( p_service_period IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_service_period IS NULL OR
        p_service_period = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_service_period;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Service_Period');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Service_Period'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Service_Period'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Service_Period;


FUNCTION Service_Start_Date ( p_service_start_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_service_start_date IS NULL OR
        p_service_start_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_service_start_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Service_Start_Date');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Service_Start_Date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Serviced_Start_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Service_Start_Date;

FUNCTION Service_End_Date ( p_service_end_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_service_end_date IS NULL OR
        p_service_end_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_service_end_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Service_End_Date');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Service_End_Date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Service_End_Date'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Service_End_Date;

FUNCTION Service_Coterminate ( p_service_coterminate_flag IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_service_coterminate_flag IS NULL OR
        p_service_coterminate_flag = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_service_coterminate_flag;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Service_Coterminate');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Service_Coterminate'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Service_Coterminate'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Service_Coterminate;

FUNCTION Unit_List_Percent ( p_unit_list_percent IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_unit_list_percent IS NULL OR
        p_unit_list_percent = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_unit_list_percent;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Unit_List_Percent');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Unit_List_Percent'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Unit_List_Percent'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Unit_List_Percent;

FUNCTION Unit_Selling_Percent ( p_unit_selling_percent IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_unit_selling_percent IS NULL OR
        p_unit_selling_percent = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_unit_selling_percent;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Unit_Selling_Percent');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Unit_Selling_Percent'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Unit_Selling_Percent'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Unit_Selling_Percent;

FUNCTION Unit_Percent_Base_Price ( p_unit_percent_base_price IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_unit_percent_base_price IS NULL OR
        p_unit_percent_base_price = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_unit_percent_base_price;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Unit_Percent_base_Price');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Unit_Percent_Base_Price'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Unit_Percent_Base_Price'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Unit_Percent_Base_Price;

FUNCTION Service_Number ( p_service_number IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_service_number IS NULL OR
        p_service_number = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_service_number;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Service_Number');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Service_Number'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Service_Number'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Service_Number;

FUNCTION Service_Reference_Type ( p_service_reference_type_code IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_service_reference_Type_code IS NULL OR
        p_service_reference_Type_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_service_reference_type_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Service_Reference_Type_Code');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Service_Reference_Type_Code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Service_Reference_Type_Code'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Service_Reference_Type;

FUNCTION Service_Reference_Line ( p_service_reference_line_id IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_service_reference_line_id IS NULL OR
        p_service_reference_line_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_service_reference_line_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Service_Reference_Line_id');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Service_Reference_Line_Id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Service_Reference_Line'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Service_Reference_Line;

FUNCTION Service_Reference_System ( p_service_reference_system_id IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_service_reference_system_id IS NULL OR
        p_service_reference_system_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_service_reference_system_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Service_Reference_System_id');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Service_Reference_System_Id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Service_Reference_System'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Service_Reference_System;

FUNCTION Line_Flow_Status ( p_flow_status_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type      	      VARCHAR2(80) :='LINE_FLOW_STATUS';
BEGIN


    IF p_flow_status_code IS NULL OR
        p_flow_status_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_LOOKUPS
    WHERE   LOOKUP_CODE = p_flow_status_code
    AND     LOOKUP_TYPE = l_lookup_type
    AND     ENABLED_FLAG = 'Y'
    AND     SYSDATE     BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                        AND NVL(END_DATE_ACTIVE, SYSDATE);



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'FLOW_STATUS_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('flow_status_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line_Flow_Status'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Line_Flow_Status;

FUNCTION Flow_Status ( p_flow_status_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type      	      VARCHAR2(80) :='FLOW_STATUS';
BEGIN


    IF p_flow_status_code IS NULL OR
        p_flow_status_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_LOOKUPS
    WHERE   LOOKUP_CODE = p_flow_status_code
    AND     LOOKUP_TYPE = l_lookup_type
    AND     ENABLED_FLAG = 'Y'
    AND     SYSDATE     BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                        AND NVL(END_DATE_ACTIVE, SYSDATE);



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'FLOW_STATUS_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('flow_status_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Flow_Status'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Flow_Status;

FUNCTION Split_Action ( p_split_action_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_split_action_code IS NULL OR
        p_split_action_code = FND_API.G_MISS_CHAR
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_split_action_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SPLIT_ACTION_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('split_action_code'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Split Action'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Split_Action;

/* JPN: Marketing source code related */

FUNCTION Marketing_Source_Code ( p_marketing_source_code_id IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_marketing_source_code_id IS NULL OR
        p_marketing_source_code_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_marketing_source_code_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Marketing_Source_Code_id');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('Marketing_Source_Code_Id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Marketing_Source_Code'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Marketing_Source_Code;

/* End of Marketing source code */

FUNCTION cost_id ( p_cost_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_cost_id IS NULL OR
        p_cost_id = FND_API.G_MISS_NUM
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_cost_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'COST_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('COST_ID'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Cost Id '
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Cost_Id;

FUNCTION Charge_Type_Code ( p_Charge_Type_Code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_Charge_Type_Code IS NULL OR
        p_Charge_Type_Code = FND_API.G_MISS_CHAR
    THEN
            RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     QP_CHARGE_LOOKUP
    WHERE    LOOKUP_CODE = p_charge_type_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CHARGE_TYPE_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('CHARGE_TYPE_CODE'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Charge Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Charge_Type_Code;

FUNCTION Charge_Subtype_Code ( p_Charge_Subtype_Code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_Charge_Subtype_Code IS NULL OR
        p_Charge_Subtype_Code = FND_API.G_MISS_CHAR
    THEN
            RETURN TRUE;
    END IF;

    -- SELECT  'VALID'
    -- INTO     l_dummy
    -- FROM     DB_TABLE
    -- WHERE    DB_COLUMN = p_charge_Subtype_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CHARGE_SUBTYPE_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('CHARGE_SUBTYPE_CODE'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Charge Sub Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Charge_Subtype_Code;

FUNCTION Commitment ( p_commitment_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_commitment_id IS NULL OR
        p_commitment_id = FND_API.G_MISS_NUM
    THEN
            RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_charge_Subtype_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

                OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'COMMITMENT_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                OE_Order_Util.Get_Attribute_Name('COMMITMENT_ID'));
            OE_MSG_PUB.Add;
              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Commitment'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Commitment;

FUNCTION credit_or_charge_flag( p_credit_or_charge_flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type      	      VARCHAR2(80) :='CREDIT_OR_CHARGE_FLAG';
BEGIN

    IF p_credit_or_charge_flag IS NULL OR
        p_credit_or_charge_flag = FND_API.G_MISS_CHAR
    THEN
            RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     OE_LOOKUPS
    WHERE    LOOKUP_CODE = p_credit_or_charge_flag
    AND      LOOKUP_TYPE = l_lookup_type
    AND      SYSDATE BETWEEN NVL(START_DATE_ACTIVE,SYSDATE)
                     AND     NVL(END_DATE_ACTIVE, SYSDATE );


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CREDIT_OR_CHARGE_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('CREDIT_OR_CHARGE_FLAG'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Credit Or Charge Flag '
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Credit_Or_Charge_Flag;

FUNCTION Include_On_Returns_Flag( p_Include_On_Returns_Flag IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type      	      VARCHAR2(80) :='YES_NO';
BEGIN

    IF p_Include_On_Returns_Flag IS NULL OR
        p_Include_On_Returns_Flag = FND_API.G_MISS_CHAR
    THEN
            RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     OE_FND_COMMON_LOOKUPS_V
    WHERE    LOOKUP_CODE = p_Include_On_Returns_Flag
    AND      LOOKUP_TYPE = l_lookup_type
    AND      SYSDATE BETWEEN NVL(START_DATE_ACTIVE,SYSDATE)
                     AND     NVL(END_DATE_ACTIVE, SYSDATE );


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'INCLUDE_ON_RETURNS_FLAG');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('INCLUDE_ON_RETURNS_FLAG'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Include On Returns Flag'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Include_On_Returns_Flag;

FUNCTION IS_AUDIT_REASON_RQD RETURN BOOLEAN IS
BEGIN
   IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG = 'Y' THEN
	 RETURN TRUE;
   ELSE
	 RETURN FALSE;
   END IF;
END;

FUNCTION IS_AUDIT_HISTORY_RQD RETURN BOOLEAN IS
BEGIN
   IF OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG = 'Y' THEN
	 RETURN TRUE;
   ELSE
	 RETURN FALSE;
   END IF;
END;

PROCEDURE RESET_AUDIT_REASON_FLAGS IS
BEGIN
   OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG := 'N';
   OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
END;
FUNCTION Sales_Channel( p_sales_channel_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type      	      VARCHAR2(80) :='SALES_CHANNEL';
BEGIN

    IF p_sales_channel_code IS NULL OR
        p_sales_channel_code = FND_API.G_MISS_CHAR
    THEN
            RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO     l_dummy
    FROM     OE_LOOKUPS
    WHERE    LOOKUP_CODE = p_sales_channel_code
    AND      LOOKUP_TYPE = l_lookup_type
    AND      ENABLED_FLAG = 'Y'
    AND      SYSDATE BETWEEN NVL(START_DATE_ACTIVE,SYSDATE)
                     AND     NVL(END_DATE_ACTIVE, SYSDATE );


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

		OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SALES_CHANNEL_CODE');

          FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('SALES_CHANNEL_CODE'));
          OE_MSG_PUB.Add;

	     OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sales_Channel'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sales_Channel;

FUNCTION User_Item_Description ( p_user_item_description IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_user_item_description IS NULL OR
        p_user_item_description = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_user_item_description;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'USER_ITEM_DESCRIPTION');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('user_item_description'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'User_Item_Description'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END User_Item_Description;


FUNCTION Item_Relationship_Type ( p_Item_Relationship_Type IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type      	      VARCHAR2(80) :='MTL_RELATIONSHIP_TYPES';
BEGIN
    IF p_Item_Relationship_Type IS NULL OR
        p_Item_Relationship_Type = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    MFG_LOOKUPS
    WHERE   LOOKUP_CODE = p_Item_Relationship_Type
    AND     LOOKUP_TYPE = l_lookup_type
    AND     ENABLED_FLAG = 'Y'
    AND     SYSDATE     BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                        AND NVL(END_DATE_ACTIVE, SYSDATE);
RETURN TRUE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'ITEM_RELATIONSHIP_TYPE');
            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                OE_Order_Util.Get_Attribute_Name('ITEM_RELATIONSHIP_TYPE'));
            OE_MSG_PUB.Add;
              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);
       END IF;
        RETURN FALSE;

    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg(g_pkg_name,'Item_Relationship_Type');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Item_Relationship_Type;


 -- Changes for Line Set Enhancements

FUNCTION Default_Fulfillment_set (p_default_fulfillment_set IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
 BEGIN
       IF p_default_fulfillment_set IS NULL OR
          p_default_fulfillment_set = FND_API.G_MISS_CHAR
       THEN
          RETURN TRUE;
       END IF;

      --  SELECT  'VALID'
      --  INTO     l_dummy
      --  FROM     DB_TABLE
      --  WHERE    DB_COLUMN = p_default_fulfillment_set;

      RETURN TRUE;

EXCEPTION

      WHEN NO_DATA_FOUND THEN

          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
          THEN

                OE_MSG_PUB.Update_Msg_Context(p_attribute_code =>  'Default_Fulfillment_Set');

              FND_MESSAGE.Set_Name('ONT','OE_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                  OE_Order_Util.Get_Attribute_Name('Default_Fulfillment_Set'));
              OE_MSG_PUB.Add;
                OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

          END IF;


          RETURN FALSE;

      WHEN OTHERS THEN

          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              OE_MSG_PUB.Add_Exc_Msg
              (   G_PKG_NAME
              ,   'Default_Fulfillment_Set'
              );
          END IF;


          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Default_Fulfillment_Set;

FUNCTION Fulfillment_Set_Name (p_fulfillment_set_name IN VARCHAR2)
RETURN BOOLEAN
IS
  l_dummy                       VARCHAR2(10);
  BEGIN
       IF p_fulfillment_set_name IS NULL OR
          p_fulfillment_set_name= FND_API.G_MISS_CHAR    THEN
            RETURN TRUE;
       END IF;

      --  SELECT  'VALID'
      --  INTO    l_dummy
      --  FROM    DB_TABLE
      --  WHERE   DB_COLUMN = p_fulfillment_set_name;

      RETURN TRUE;
  EXCEPTION

      WHEN NO_DATA_FOUND THEN

          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
          THEN

                OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Fulfillment_Set_Name');

              fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                  OE_Order_Util.Get_Attribute_Name('Fulfillment_Set_Name'));
              OE_MSG_PUB.Add;
                OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

          END IF;


          RETURN FALSE;

      WHEN OTHERS THEN

          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              OE_MSG_PUB.Add_Exc_Msg
              (   G_PKG_NAME
              ,   'Fulfillment_Set_Name'
              );
          END IF;


          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Fulfillment_Set_Name;

FUNCTION Line_Set_Name (p_line_set_name IN VARCHAR2)
RETURN BOOLEAN
IS
  l_dummy                       VARCHAR2(10);
BEGIN
      IF p_line_set_name IS NULL OR
         p_line_set_name= FND_API.G_MISS_CHAR    THEN
             RETURN TRUE;
      END IF;

      --  SELECT  'VALID'
      --  INTO    l_dummy
      --  FROM    DB_TABLE
      --  WHERE   DB_COLUMN = p_line_set_name;

      RETURN TRUE;
  EXCEPTION

      WHEN NO_DATA_FOUND THEN

          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
          THEN

                OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Line_Set_Name');

             fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                 OE_Order_Util.Get_Attribute_Name('Line_Set_Name'));
             OE_MSG_PUB.Add;
               OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

         END IF;


         RETURN FALSE;

     WHEN OTHERS THEN

          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              OE_MSG_PUB.Add_Exc_Msg
              (   G_PKG_NAME
              ,   'Line_Set_Name'
              );
          END IF;


          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Line_Set_Name;


FUNCTION Customer_Shipment_Number (p_customer_shipment_number IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
 BEGIN
       IF p_customer_shipment_number IS NULL OR
          p_customer_shipment_number = FND_API.G_MISS_CHAR
       THEN
          RETURN TRUE;
       END IF;

      --  SELECT  'VALID'
      --  INTO     l_dummy
      --  FROM     DB_TABLE
      --  WHERE    DB_COLUMN = p_customer_shipment_number;

      RETURN TRUE;

EXCEPTION

      WHEN NO_DATA_FOUND THEN

          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
          THEN

                OE_MSG_PUB.Update_Msg_Context(p_attribute_code =>  'Customer_Shipment_Number');

              FND_MESSAGE.Set_Name('ONT','OE_INVALID_ATTRIBUTE');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                  OE_Order_Util.Get_Attribute_Name('Customer_Shipment_Number'));
              OE_MSG_PUB.Add;
                OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

          END IF;


          RETURN FALSE;

      WHEN OTHERS THEN

          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              OE_MSG_PUB.Add_Exc_Msg
              (   G_PKG_NAME
              ,   'Customer_Shipment_Number'
              );
          END IF;


          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Customer_Shipment_Number;

-- QUOTING changes

FUNCTION Transaction_Phase ( p_transaction_phase_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type      	      VARCHAR2(80) :='TRANSACTION_PHASE';
BEGIN

    IF p_transaction_phase_code IS NULL OR
        p_transaction_phase_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_LOOKUPS
    WHERE   LOOKUP_CODE = p_transaction_phase_code
    AND     LOOKUP_TYPE = l_lookup_type
    AND     ENABLED_FLAG = 'Y'
    AND     SYSDATE     BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                        AND NVL(END_DATE_ACTIVE, SYSDATE);


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'TRANSACTION_PHASE_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('TRANSACTION_PHASE_CODE'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Transaction_Phase'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transaction_Phase;

FUNCTION User_Status ( p_user_status_code IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type      	      VARCHAR2(80) :='USER_STATUS';
BEGIN

    IF p_user_status_code IS NULL OR
        p_user_status_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_LOOKUPS
    WHERE   LOOKUP_CODE = p_user_status_code
    AND     LOOKUP_TYPE = l_lookup_type
    AND     ENABLED_FLAG = 'Y'
    AND     SYSDATE     BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                        AND NVL(END_DATE_ACTIVE, SYSDATE);


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'USER_STATUS_CODE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('USER_STATUS_CODE'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'User_Status'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END User_Status;

FUNCTION Customer_Location ( p_sold_to_site_use_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_sold_to_site_use_id IS NULL OR
        p_sold_to_site_use_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    HZ_CUST_SITE_USES   SITE
    WHERE   SITE.SITE_USE_ID =p_sold_to_site_use_id
    AND     SITE.SITE_USE_CODE = 'SOLD_TO'
    AND     SITE.STATUS = 'A';


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SOLD_TO_SITE_USE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('sold_to_site_use_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Customer_Location'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Customer_Location;
-- QUOTING changes END
FUNCTION Minisite( p_minisite_id IN NUMBER)
RETURN BOOLEAN
IS
l_sql_stat                      VARCHAR2(500);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
x_return_status                 VARCHAR2(80);
l_dummy                         NUMBER;
BEGIN

    IF p_minisite_id IS NULL
            OR
       p_minisite_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;

    ELSE

 IF  OE_GLOBALS.CHECK_PRODUCT_INSTALLED(671) = 'Y' THEN

    -- SQL Literal Change
    l_sql_stat := 'select 1 from IBE_MSITES_B where msite_id= :bind_minisite_id';

    -- SQL Literal Change
     Execute immediate l_sql_stat into l_dummy using p_minisite_id;

    RETURN TRUE;

/* ELSE
         IF l_debug_level  > 0 THEN
       oe_debug_pub.add('profuct is not installed');
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           RETURN FALSE;
         END IF; */


END IF;
END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'MINISITE_ID');

            FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                         'MINISITE_ID');
            OE_MSG_PUB.Add;

                OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;

        RETURN FALSE;

/*  WHEN OTHERS THEN
         IF l_debug_level  > 0 THEN
       oe_debug_pub.add('error in calling');
       oe_debug_pub.add(sqlerrm);
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           RETURN FALSE;
         END IF;  */

    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Minisite'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Minisite;

FUNCTION IB_OWNER ( p_ib_owner IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type1      	      VARCHAR2(80) :='ITEM_OWNER';
l_lookup_type2      	      VARCHAR2(80) :='ONT_INSTALL_BASE';
BEGIN


    IF p_ib_owner IS NULL OR
        p_ib_owner = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

      SELECT  'VALID'
      INTO     l_dummy
      FROM     OE_LOOKUPS
      WHERE    lookup_code = p_ib_owner AND
              ( lookup_type = l_lookup_type1 OR lookup_type=l_lookup_type2);


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

           OE_DEBUG_PUB.ADD('Validation failed for IB_OWNER in OEXSVATB.pls');
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'IB_OWNER');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('ib_owner'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'IB_OWNER'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END IB_OWNER;

FUNCTION IB_INSTALLED_AT_LOCATION ( p_ib_installed_at_location IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type1      	      VARCHAR2(80) :='ITEM_INSTALL_LOCATION';
l_lookup_type2      	      VARCHAR2(80) :='ONT_INSTALL_BASE';
BEGIN


    IF p_ib_installed_at_location IS NULL OR
        p_ib_installed_at_location = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

      SELECT  'VALID'
      INTO     l_dummy
      FROM     OE_LOOKUPS
      WHERE    lookup_code = p_ib_installed_at_location AND
               (lookup_type = l_lookup_type1 OR lookup_type= l_lookup_type2);


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

           OE_DEBUG_PUB.ADD('Validation failed for IB_INSTALLED_AT_LOCATION in OEXSVATB.pls');
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'IB_INSTALLED_AT_LOCATION');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('ib_installed_at_location'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'IB_INSTALLED_AT_LOCATION'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END IB_INSTALLED_AT_LOCATION;

FUNCTION IB_CURRENT_LOCATION ( p_ib_current_location IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type1      	      VARCHAR2(80) :='ITEM_CURRENT_LOCATION';
l_lookup_type2      	      VARCHAR2(80) :='ONT_INSTALL_BASE';
BEGIN


    IF p_ib_current_location IS NULL OR
        p_ib_current_location = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

      SELECT  'VALID'
      INTO     l_dummy
      FROM     OE_LOOKUPS
      WHERE    lookup_code = p_ib_current_location AND
               (lookup_type = l_lookup_type1 OR lookup_type=l_lookup_type2);


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

           OE_DEBUG_PUB.ADD('Validation failed for IB_CURRENT_LOCATION in OEXSVATB.pls');
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'IB_CURRENT_LOCATION');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('ib_current_location'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'IB_CURRENT_LOCATION'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END IB_CURRENT_LOCATION;

-- distributed orders

FUNCTION end_customer(p_end_customer_id IN NUMBER) RETURN BOOLEAN
IS
   l_dummy                       VARCHAR2(10);
BEGIN

   IF p_end_customer_id IS NULL OR
        p_end_customer_id = FND_API.G_MISS_NUM
    THEN
        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_SOLD_TO_ORGS_V
    WHERE   ORGANIZATION_ID =p_end_customer_id
    AND     STATUS = 'A'
    AND     SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                    AND     NVL(END_DATE_ACTIVE, SYSDATE);



    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'END_CUSTOMER_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('END_CUSTOMER_ID')||':validation:'||to_char(p_end_customer_id));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'END_CUSOTMER'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   null;
END end_customer;


FUNCTION end_customer_contact(p_end_customer_contact_id IN NUMBER) RETURN BOOLEAN
IS
   l_dummy                       VARCHAR2(10);
BEGIN

   IF p_end_customer_contact_id IS NULL OR
        p_end_customer_contact_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    SELECT  'VALID'
    INTO    l_dummy
    FROM    HZ_CUST_ACCOUNT_ROLES
    WHERE   CUST_ACCOUNT_ROLE_ID = p_end_customer_contact_id
    AND     ROLE_TYPE = 'CONTACT'
    AND     STATUS = 'A';

    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'END_CUSTOMER_CONTACT_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('end_customer_contact_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'End_Customer_Contact'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   null;
END end_customer_contact;

FUNCTION END_CUSTOMER_SITE_USE ( p_end_customer_site_use_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_end_customer_site_use_id IS NULL OR
        p_end_customer_site_use_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_end_customer_site_use_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'END_CUSTOMER_SITE_USE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('end_customer_site_use_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'END_CUSTOMER_SITE_USE_ID'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END END_CUSTOMER_SITE_USE;

FUNCTION SUPPLIER_SIGNATURE ( p_supplier_signature IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_supplier_signature IS NULL OR
        p_supplier_signature = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_supplier_signature;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SUPPLIER_SIGNATURE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('supplier_signature'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'SUPPLIER_SIGNATURE'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END SUPPLIER_SIGNATURE;

FUNCTION SUPPLIER_SIGNATURE_DATE ( p_supplier_signature_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_supplier_signature_date IS NULL OR
        p_supplier_signature_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_supplier_signature_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SUPPLIER_SIGNATURE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('supplier_signature_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'SUPPLIER_SIGNATURE_DATE'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END SUPPLIER_SIGNATURE_DATE;

FUNCTION CUSTOMER_SIGNATURE ( p_customer_signature IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_customer_signature IS NULL OR
        p_customer_signature = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_customer_signature;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CUSTOMER_SIGNATURE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('customer_signature'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'CUSTOMER_SIGNATURE'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END CUSTOMER_SIGNATURE;

FUNCTION CUSTOMER_SIGNATURE_DATE ( p_customer_signature_date IN DATE )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_customer_signature_date IS NULL OR
        p_customer_signature_date = FND_API.G_MISS_DATE
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_customer_signature_date;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CUSTOMER_SIGNATURE_DATE');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('customer_signature_date'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'CUSTOMER_SIGNATURE_DATE'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END CUSTOMER_SIGNATURE_DATE;

FUNCTION CONTRACT_TEMPLATE_ID ( p_contract_template_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_contract_template_id IS NULL OR
        p_contract_template_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_contract_template_id;

 RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CONTRACT_TEMPLATE_ID
');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                OE_Order_Util.Get_Attribute_Name('contract_template_id'));
            OE_MSG_PUB.Add;
              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END CONTRACT_TEMPLATE_ID;

FUNCTION CONTRACT_SOURCE_DOC_TYPE_CODE ( p_contract_source_doc_type IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_contract_source_doc_type IS NULL OR
        p_contract_source_doc_type = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_contract_source_doc_type;

 RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CONTRACT_SOURCE_DOC_TYPE_CODE
');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                OE_Order_Util.Get_Attribute_Name('contract_source_doc_type_code'));
            OE_MSG_PUB.Add;
              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END CONTRACT_SOURCE_DOC_TYPE_CODE;


FUNCTION CONTRACT_SOURCE_DOCUMENT_ID ( p_contract_source_document_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_contract_source_document_id IS NULL OR
        p_contract_source_document_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_contract_source_document_id;

 RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CONTRACT_SOURCE_DOCUMENT_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                OE_Order_Util.Get_Attribute_Name('contract_source_document_id'));
            OE_MSG_PUB.Add;
              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END CONTRACT_SOURCE_DOCUMENT_ID;


FUNCTION Payments_Desc_Flex (p_context IN VARCHAR2,
                           p_attribute1 IN VARCHAR2,
                           p_attribute2 IN VARCHAR2,
                           p_attribute3 IN VARCHAR2,
                           p_attribute4 IN VARCHAR2,
                           p_attribute5 IN VARCHAR2,
                           p_attribute6 IN VARCHAR2,
                           p_attribute7 IN VARCHAR2,
                           p_attribute8 IN VARCHAR2,
                           p_attribute9 IN VARCHAR2,
                           p_attribute10 IN VARCHAR2,
                           p_attribute11 IN VARCHAR2,
                           p_attribute12 IN VARCHAR2,
                           p_attribute13 IN VARCHAR2,
                           p_attribute14 IN VARCHAR2,
                           p_attribute15 IN VARCHAR2)

RETURN BOOLEAN
IS
l_column_value VARCHAR2(240) := null;
BEGIN

   --  Assiging the segment names so as to map the values after the FND call.
                g_context_name := 'CONTEXT';
                g_attribute1_name := 'ATTRIBUTE1';
                g_attribute2_name := 'ATTRIBUTE2';
                g_attribute3_name := 'ATTRIBUTE3';
                g_attribute4_name := 'ATTRIBUTE4';
                g_attribute5_name := 'ATTRIBUTE5';
                g_attribute6_name := 'ATTRIBUTE6';
                g_attribute7_name := 'ATTRIBUTE7';
                g_attribute8_name := 'ATTRIBUTE8';
                g_attribute9_name := 'ATTRIBUTE9';
                g_attribute10_name := 'ATTRIBUTE10';
                g_attribute11_name := 'ATTRIBUTE11';
                g_attribute12_name := 'ATTRIBUTE12';
                g_attribute13_name := 'ATTRIBUTE13';
                g_attribute14_name := 'ATTRIBUTE14';
                g_attribute15_name := 'ATTRIBUTE15';

                  IF p_attribute1 = FND_API.G_MISS_CHAR THEN

                     l_column_value := null;

                  ELSE

                     l_column_value := p_attribute1;

                  END IF;

                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE1'
                   ,  column_value  => l_column_value);


                  IF p_attribute2 = FND_API.G_MISS_CHAR THEN

                     l_column_value := null;

                  ELSE

                     l_column_value := p_attribute2;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE2'
                   ,  column_value  =>  l_column_value);

                  IF p_attribute3 = FND_API.G_MISS_CHAR THEN

                     l_column_value := null;

                  ELSE

                     l_column_value := p_attribute3;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE3'
                   ,  column_value  =>  l_column_value);

                  IF p_attribute4 = FND_API.G_MISS_CHAR THEN

                     l_column_value := null;

                  ELSE

                     l_column_value := p_attribute4;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE4'
                   ,  column_value  =>  l_column_value);

                  IF p_attribute5 = FND_API.G_MISS_CHAR THEN

                     l_column_value := null;

                  ELSE

                     l_column_value := p_attribute5;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE5'
                   ,  column_value  =>  l_column_value);

                  IF p_attribute6 = FND_API.G_MISS_CHAR THEN

                     l_column_value := null;

                  ELSE

                     l_column_value := p_attribute6;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE6'
                   ,  column_value  =>  l_column_value);

                  IF p_attribute7 = FND_API.G_MISS_CHAR THEN

                     l_column_value := null;

                  ELSE

                     l_column_value := p_attribute7;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE7'
                   ,  column_value  =>  l_column_value);

                  IF p_attribute8 = FND_API.G_MISS_CHAR THEN

                     l_column_value := null;

                  ELSE

                     l_column_value := p_attribute8;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE8'
                   ,  column_value  =>  l_column_value);

                  IF p_attribute9 = FND_API.G_MISS_CHAR THEN

                     l_column_value := null;

                  ELSE

                     l_column_value := p_attribute9;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE9'
                   ,  column_value  =>  l_column_value);

                  IF p_attribute10 = FND_API.G_MISS_CHAR THEN

                     l_column_value := null;

                  ELSE

                     l_column_value := p_attribute10;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE10'
                   ,  column_value  =>  l_column_value);

                  IF p_attribute11 = FND_API.G_MISS_CHAR THEN

                     l_column_value := null;

                  ELSE

                     l_column_value := p_attribute11;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE11'
                   ,  column_value  =>  l_column_value);

                  IF p_attribute12 = FND_API.G_MISS_CHAR THEN

                     l_column_value := null;

                  ELSE

                     l_column_value := p_attribute12;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE12'
                   ,  column_value  =>  l_column_value);

                  IF p_attribute13 = FND_API.G_MISS_CHAR THEN

                     l_column_value := null;

                  ELSE

                     l_column_value := p_attribute13;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE13'
                   ,  column_value  =>  l_column_value);

                  IF p_attribute14 = FND_API.G_MISS_CHAR THEN

                     l_column_value := null;

                  ELSE

                     l_column_value := p_attribute14;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE14'
                   ,  column_value  =>  l_column_value);

                  IF p_attribute15 = FND_API.G_MISS_CHAR THEN

                     l_column_value := null;

                  ELSE

                     l_column_value := p_attribute15;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE15'
                   ,  column_value  =>  l_column_value);

                  IF p_context = FND_API.G_MISS_CHAR THEN

                     l_column_value := null;

                  ELSE

                     l_column_value := p_context;

                  END IF;
                  FND_FLEX_DESCVAL.Set_Context_Value
                   ( context_value   => l_column_value);
-- Suppressing the validation as payments flexfield is not registered
/*
                   IF NOT OE_Validate.Desc_Flex('OE_PAYMENTS_ATTRIBUTES') THEN
                        OE_DEBUG_PUB.add('Error at validation of OE_PAYMENTS_ATTRIBUTES ',1);
                        RETURN FALSE;
                   END IF;
*/
    RETURN TRUE;

EXCEPTION

   WHEN OTHERS THEN


     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN

        OE_MSG_PUB.Add_Exc_Msg
        ( G_PKG_NAME
          , 'Payments_Desc_Flex');
     END IF;


    RETURN FALSE;

END Payments_Desc_Flex;

FUNCTION Payment_Level(p_payment_level_code IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_payment_level_code IS NULL OR
        p_payment_level_code = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_payment_level_code;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'Payment_Level_Code');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                OE_Order_Util.Get_Attribute_Name('Payment_Level_Code'));
            OE_MSG_PUB.Add;
              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Payment_Level'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Payment_Level;

FUNCTION commitment_applied_amount(p_commitment_applied_amount IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_commitment_applied_amount IS NULL OR
        p_commitment_applied_amount = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_commitment_applied_amount;


    RETURN TRUE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'COMMITMENT_APPLIED_AMOUNT');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                OE_Order_Util.Get_Attribute_Name('commitment_applied_amount'));
            OE_MSG_PUB.Add;
              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Commitment_Applied_Amount'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Commitment_Applied_Amount;

FUNCTION commitment_interfaced_amount(p_commitment_interfaced_amount IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_commitment_interfaced_amount IS NULL OR
        p_commitment_interfaced_amount = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_commitment_interfaced_amount;


    RETURN TRUE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'COMMITMENT_INTERFACED_AMOUNT');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                OE_Order_Util.Get_Attribute_Name('commitment_interfaced_amount'));
            OE_MSG_PUB.Add;
              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Commitment_Interfaced_Amount'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Commitment_Interfaced_Amount;

FUNCTION Payment_Collection_Event(p_payment_collection_event IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
l_lookup_type      	      VARCHAR2(80) :='OE_PAYMENT_COLLECTION_TYPE';
BEGIN

    IF p_payment_collection_event IS NULL OR
        p_payment_collection_event = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

      SELECT  'VALID'
      INTO     l_dummy
      FROM     OE_LOOKUPS
      WHERE    lookup_type = l_lookup_type
      AND      lookup_code = p_payment_collection_event;


    RETURN TRUE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PAYMENT_COLLECTION_EVENT');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                OE_Order_Util.Get_Attribute_Name('payment_collection_event'));
            OE_MSG_PUB.Add;
              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Payment_Collection_Event'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Payment_Collection_Event;

FUNCTION Payment_Trx(p_payment_trx_id IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_payment_trx_id IS NULL OR
        p_payment_trx_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_payment_trx_id;


    RETURN TRUE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PAYMENT_TRX_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                OE_Order_Util.Get_Attribute_Name('payment_trx_id'));
            OE_MSG_PUB.Add;
              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Payment_Trx'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Payment_Trx;

FUNCTION Payment_Set(p_payment_set_id IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_payment_set_id IS NULL OR
        p_payment_set_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_payment_set_id;


    RETURN TRUE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PAYMENT_SET_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                OE_Order_Util.Get_Attribute_Name('payment_set_id'));
            OE_MSG_PUB.Add;
              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Payment_Set'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Payment_Set;

FUNCTION Prepaid_Amount(p_prepaid_amount IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_prepaid_amount IS NULL OR
        p_prepaid_amount = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_prepaid_amount;


    RETURN TRUE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PREPAID_AMOUNT');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                OE_Order_Util.Get_Attribute_Name('prepaid_amoun'));
            OE_MSG_PUB.Add;
              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Prepaid_Amount'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Prepaid_Amount;

FUNCTION Receipt_Method(p_receipt_method_id IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_receipt_method_id IS NULL OR
        p_receipt_method_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

      SELECT  'VALID'
      INTO     l_dummy
      FROM    ar_receipt_methods rm,
              ar_receipt_classes rc
      Where   nvl(rc.bill_of_exchange_flag, 'N') = 'N'
      and     rc.receipt_class_id = rm.receipt_class_id
      and     rm.receipt_method_id = p_receipt_method_id;


    RETURN TRUE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'RECEIPT_METHOD');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                OE_Order_Util.Get_Attribute_Name('receipt_method_id'));
            OE_MSG_PUB.Add;
              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;

        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Receipt_Method'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Receipt_Method;

FUNCTION Tangible(p_tangible_id IN VARCHAR2)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_tangible_id IS NULL OR
        p_tangible_id = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_tangible_id;


    RETURN TRUE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'TANGIBLE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                OE_Order_Util.Get_Attribute_Name('tangible_id'));
            OE_MSG_PUB.Add;
              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Tangible'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Tangible;


FUNCTION Payment_Number(p_payment_number IN NUMBER)
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN

    IF p_payment_number IS NULL OR
        p_payment_number = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_payment_number;


    RETURN TRUE;

EXCEPTION
    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'PAYMENT_NUMBER');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                                OE_Order_Util.Get_Attribute_Name('payment_number'));
            OE_MSG_PUB.Add;
              OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Payment_Number'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Payment_Number;

--recurring charges
FUNCTION Charge_Periodicity
(  p_charge_periodicity  IN VARCHAR2  )
RETURN BOOLEAN
IS
  l_uom_class   VARCHAR2(10);
  l_debug_level CONSTANT NUMBER := OE_DEBUG_PUB.G_DEBUG_LEVEL;
BEGIN

  SELECT uom_class
  INTO   l_uom_class
  FROM   MTL_UNITS_OF_MEASURE_VL
  WHERE  uom_code = p_charge_periodicity
  AND    uom_class = FND_PROFILE.Value('ONT_UOM_CLASS_CHARGE_PERIODICITY');

  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add ('Entering OE_VALIDATE.Charge_Periodicity',1);
     OE_DEBUG_PUB.Add ('Charge Periodicity:'||p_charge_periodicity,3);
     OE_DEBUG_PUB.Add ('UOM Class:'||
                        FND_PROFILE.Value('ONT_UOM_CLASS_CHARGE_PERIODICITY'));
     OE_DEBUG_PUB.Add ('Uom class:'||l_uom_class||',returning TRUE',3);
     OE_DEBUG_PUB.Add ('Exiting OE_VALIDATE.Charge_Periodicity',1);
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF l_debug_level > 0 THEN
       OE_DEBUG_PUB.Add ('Charge Periodicity: NO_DATA_FOUND!!',1);
    END IF;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
       OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'CHARGE_PERIODICITY');
       FND_MESSAGE.Set_Name('ONT','OE_INVALID_ATTRIBUTE');
       FND_MESSAGE.Set_Token('ATTRIBUTE',
                       OE_ORDER_UTIL.Get_Attribute_Name('Charge_Periodicity'));
       OE_MSG_PUB.Add;
       OE_MSG_PUB.Update_Msg_Context(p_attribute_code => NULL);
    END IF;
    RETURN FALSE;

  WHEN OTHERS THEN
    IF l_debug_level > 0 THEN
       OE_DEBUG_PUB.Add ('Charge_Periodicity: OTHERS Exception',1);
    END IF;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg
       (  G_PKG_NAME
         ,'Charge_Periodicity');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Charge_Periodicity;

--
FUNCTION Shipped_Quantity2 ( p_shipped_quantity2 IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_shipped_quantity2 IS NULL OR
        p_shipped_quantity2 = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_shipped_quantity2;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SHIPPED_QUANTITY2');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('shipped_quantity2'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Shipped_Quantity2'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Shipped_Quantity2;

FUNCTION Fulfilled_Quantity2 ( p_fulfilled_quantity2 IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_fulfilled_quantity2 IS NULL OR
        p_fulfilled_quantity2 = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_fulfilled_quantity2;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'FULFILLED_QUANTITY2');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('fulfilled_quantity2'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Fulfilled_Quantity2'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Fulfilled_Quantity2;

FUNCTION Shipping_Quantity2 ( p_shipping_quantity2 IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_shipping_quantity2 IS NULL OR
        p_shipping_quantity2 = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_shipping_quantity2;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SHIPPING_QUANTITY2');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('shipping_quantity2'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Shipping_Quantity2'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Shipping_Quantity2;

FUNCTION Shipping_Quantity_Uom2 ( p_shipping_quantity_uom2 IN VARCHAR2 )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_shipping_quantity_uom2 IS NULL OR
        p_shipping_quantity_uom2 = FND_API.G_MISS_CHAR
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_shipping_quantity_uom2;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'SHIPPING_QUANTITY_UOM2');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('shipping_quantity_uom2'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Shipping_Quantity_Uom2'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Shipping_Quantity_Uom2;

FUNCTION Payment_Trxn_Extension ( p_trxn_extension_id IN NUMBER ) --R12 Process order api changes
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN
--need to make this code active (i.e. remove the comment) once the Oracle payments are
--done with their case changes
    IF p_trxn_extension_id IS NULL OR
        p_trxn_extension_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

   SELECT  'VALID'
    INTO    l_dummy
    FROM    IBY_FNDCPT_TX_EXTENSIONS
    Where trxn_extension_id = p_trxn_extension_id;

    --  Valid extension id


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'TRXN_EXTENSION_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('trxn_extension_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Payment_Trxn_Extension'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Payment_Trxn_Extension; --R12 Process order api changes


-- eBtax changes
FUNCTION Tax_Rate_ID ( p_tax_rate_id IN NUMBER )
RETURN BOOLEAN
IS
l_dummy                       VARCHAR2(10);
BEGIN


    IF p_tax_rate_id IS NULL OR
        p_tax_rate_id = FND_API.G_MISS_NUM
    THEN

        RETURN TRUE;
    END IF;

    --  SELECT  'VALID'
    --  INTO     l_dummy
    --  FROM     DB_TABLE
    --  WHERE    DB_COLUMN = p_tax_rate_id;


    RETURN TRUE;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => 'TAX_RATE_ID');

            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
				OE_Order_Util.Get_Attribute_Name('tax_rate_id'));
            OE_MSG_PUB.Add;
	      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);

        END IF;


        RETURN FALSE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Tax_Rate_ID'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Tax_Rate_ID;

--
--
--
--

END OE_Validate;

/
