--------------------------------------------------------
--  DDL for Package Body OE_REJECTED_LINES_ACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_REJECTED_LINES_ACK" AS
/* $Header: OEXVRAKB.pls 115.13 2003/10/31 01:56:50 jjmcfarl ship $ */

PROCEDURE Get_Rejected_Lines(
   p_request_id			IN  NUMBER
  ,p_order_source_id		IN  NUMBER
  ,p_orig_sys_document_ref      IN  VARCHAR2
  ,p_change_sequence            IN  VARCHAR2
  ,x_rejected_line_tbl          IN OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
  ,x_rejected_line_val_tbl     OUT NOCOPY OE_Order_Pub.Line_Val_Tbl_Type
  ,x_rejected_lot_serial_tbl    IN OUT NOCOPY OE_Order_Pub.Lot_Serial_Tbl_Type
  ,x_return_status             OUT NOCOPY VARCHAR2
  ,p_header_id                  IN NUMBER
  ,p_sold_to_org                IN VARCHAR2
  ,p_sold_to_org_id             IN NUMBER
) is

  l_line_rec                    OE_Order_Pub.Line_Rec_Type;
  l_line_tbl                    OE_Order_Pub.Line_Tbl_Type;
  l_line_val_rec                OE_Order_Pub.Line_Val_Rec_Type;
  l_line_val_tbl                OE_Order_Pub.Line_Val_Tbl_Type;
  l_lot_serial_rec         	OE_Order_Pub.Lot_Serial_Rec_Type;
  l_lot_serial_tbl         	OE_Order_Pub.Lot_Serial_Tbl_Type;

  l_request_id			NUMBER		:= p_request_id;
  l_order_source_id		NUMBER		:= p_order_source_id;
  l_orig_sys_document_ref	VARCHAR2(50) 	:= p_orig_sys_document_ref;
  l_change_sequence		VARCHAR2(50) 	:= p_change_sequence;
  l_orig_sys_line_ref		VARCHAR2(50);
  l_orig_sys_shipment_ref	VARCHAR2(50);

  l_line_count                  NUMBER := 0;
  l_lot_serial_count            NUMBER;

  -- Declared as part of fix 2922709
  l_header_id                   NUMBER          := p_header_id;
  l_segment_array  fnd_flex_ext.segmentarray;

  l_api_name           CONSTANT VARCHAR2(30) := 'Get_Rejected_Lines';
  l_customer_key_profile        VARCHAR2(1) := 'N';
/* -----------------------------------------------------------
   Lines cursor
   -----------------------------------------------------------
*/
    CURSOR l_line_cursor IS
    SELECT nvl(order_source_id,			FND_API.G_MISS_NUM)
    	 , nvl(orig_sys_document_ref,		FND_API.G_MISS_CHAR)
    	 , nvl(orig_sys_line_ref,		FND_API.G_MISS_CHAR)
	 , nvl(orig_sys_shipment_ref,		FND_API.G_MISS_CHAR)
	 , nvl(change_request_code,		FND_API.G_MISS_CHAR)
	 , nvl(org_id,				FND_API.G_MISS_NUM)
	 , nvl(line_number,			FND_API.G_MISS_NUM)
	 , nvl(shipment_number,			FND_API.G_MISS_NUM)
	 , nvl(line_id,				FND_API.G_MISS_NUM)
	 , nvl(line_type_id,			FND_API.G_MISS_NUM)
	 , line_type
	 , nvl(item_type_code,			FND_API.G_MISS_CHAR)
	 , nvl(inventory_item_id,		FND_API.G_MISS_NUM)
	 , inventory_item
	 , nvl(top_model_line_ref,		FND_API.G_MISS_CHAR)
	 , nvl(link_to_line_ref,		FND_API.G_MISS_CHAR)
	 , nvl(explosion_date,			FND_API.G_MISS_DATE)
	 , nvl(ato_line_id,			FND_API.G_MISS_NUM)
	 , nvl(component_sequence_id,		FND_API.G_MISS_NUM)
	 , nvl(component_code,			FND_API.G_MISS_CHAR)
	 , nvl(sort_order,			FND_API.G_MISS_CHAR)
	 , nvl(model_group_number,		FND_API.G_MISS_NUM)
	 , nvl(option_number,			FND_API.G_MISS_NUM)
	 , nvl(option_flag,			'N')
	 , nvl(ship_model_complete_flag,	FND_API.G_MISS_CHAR)
	 , nvl(source_type_code,		FND_API.G_MISS_CHAR)
	 , nvl(schedule_status_code,		FND_API.G_MISS_CHAR)
	 , nvl(schedule_ship_date,		FND_API.G_MISS_DATE)
         , nvl(late_demand_penalty_factor,      FND_API.G_MISS_NUM)
	 , nvl(schedule_arrival_date,		FND_API.G_MISS_DATE)
	 , nvl(actual_arrival_date,		FND_API.G_MISS_DATE)
  	 , nvl(request_date,			FND_API.G_MISS_DATE)
	 , nvl(promise_date,			FND_API.G_MISS_DATE)
	 , nvl(delivery_lead_time,		FND_API.G_MISS_NUM)
	 , nvl(ordered_quantity,		FND_API.G_MISS_NUM)
	 , nvl(order_quantity_uom ,		FND_API.G_MISS_CHAR)
	 , nvl(shipping_quantity,		FND_API.G_MISS_NUM)
	 , nvl(shipping_quantity_uom,		FND_API.G_MISS_CHAR)
	 , nvl(shipped_quantity,		FND_API.G_MISS_NUM)
	 , nvl(cancelled_quantity,		FND_API.G_MISS_NUM)
	 , nvl(fulfilled_quantity,		FND_API.G_MISS_NUM)
   /* OPM variables */
         , nvl(ordered_quantity2,               FND_API.G_MISS_NUM)
         , nvl(ordered_quantity_uom2 ,          FND_API.G_MISS_CHAR)
         , nvl(shipping_quantity2,              FND_API.G_MISS_NUM)
         , nvl(shipping_quantity_uom2,          FND_API.G_MISS_CHAR)
         , nvl(shipped_quantity2,               FND_API.G_MISS_NUM)
         , nvl(cancelled_quantity2,             FND_API.G_MISS_NUM)
         , nvl(fulfilled_quantity2,             FND_API.G_MISS_NUM)
         , nvl(preferred_grade,                 FND_API.G_MISS_CHAR)
   /* end of OPM variables */
	 , nvl(pricing_quantity,		FND_API.G_MISS_NUM)
	 , nvl(pricing_quantity_uom,		FND_API.G_MISS_CHAR)
	 , nvl(sold_from_org_id,		FND_API.G_MISS_NUM)
	 , sold_from_org
	 , nvl(sold_to_org_id ,			FND_API.G_MISS_NUM)
	 , sold_to_org
	 , nvl(ship_from_org_id,		FND_API.G_MISS_NUM)
	 , ship_from_org
	 , nvl(ship_to_org_id ,			FND_API.G_MISS_NUM)
	 , ship_to_org
	 , nvl(deliver_to_org_id,		FND_API.G_MISS_NUM)
	 , deliver_to_org
	 , nvl(invoice_to_org_id,		FND_API.G_MISS_NUM)
	 , invoice_to_org
	 , ship_to_address1
	 , ship_to_address2
	 , ship_to_address3
	 , ship_to_address4
	 , ship_to_city
	 , ship_to_state
	 , ship_to_postal_code
	 , ship_to_country
	 , nvl(ship_to_contact_id,		FND_API.G_MISS_NUM)
	 , ship_to_contact
	 , nvl(deliver_to_contact_id,		FND_API.G_MISS_NUM)
	 , deliver_to_contact
	 , nvl(invoice_to_contact_id,		FND_API.G_MISS_NUM)
	 , invoice_to_contact
	 , nvl(drop_ship_flag,			FND_API.G_MISS_CHAR)
	 , nvl(ship_tolerance_above,		FND_API.G_MISS_NUM)
	 , nvl(ship_tolerance_below,		FND_API.G_MISS_NUM)
	 , nvl(price_list_id,			FND_API.G_MISS_NUM)
	 , price_list
	 , nvl(pricing_date,			FND_API.G_MISS_DATE)
	 , nvl(unit_list_price,			FND_API.G_MISS_NUM)
	 , nvl(unit_selling_price,		FND_API.G_MISS_NUM)
	 , nvl(calculate_price_flag,		'Y')
	 , nvl(ship_set_id,			FND_API.G_MISS_NUM)
	 , nvl(ship_set_name,			FND_API.G_MISS_CHAR)
	 , nvl(arrival_set_id,			FND_API.G_MISS_NUM)
	 , nvl(arrival_set_name,		FND_API.G_MISS_CHAR)
	 , nvl(fulfillment_set_id,		FND_API.G_MISS_NUM)
	 , nvl(fulfillment_set_name,		FND_API.G_MISS_CHAR)
	 , nvl(tax_code,			FND_API.G_MISS_CHAR)
	 , nvl(tax_value,			FND_API.G_MISS_NUM)
	 , nvl(tax_date,			FND_API.G_MISS_DATE)
	 , nvl(tax_point_code,			FND_API.G_MISS_CHAR)
	 , tax_point
	 , nvl(tax_exempt_flag,			FND_API.G_MISS_CHAR)
	 , nvl(tax_exempt_number,		FND_API.G_MISS_CHAR)
	 , nvl(tax_exempt_reason_code,		FND_API.G_MISS_CHAR)
	 , tax_exempt_reason
	 , nvl(agreement_id,			FND_API.G_MISS_NUM)
	 , agreement
	 , nvl(invoicing_rule_id,		FND_API.G_MISS_NUM)
	 , invoicing_rule
	 , nvl(accounting_rule_id,		FND_API.G_MISS_NUM)
	 , nvl(accounting_rule_duration,	FND_API.G_MISS_NUM)
	 , accounting_rule
	 , nvl(payment_term_id,			FND_API.G_MISS_NUM)
	 , payment_term
	 , nvl(demand_class_code,		FND_API.G_MISS_CHAR)
	 , nvl(shipment_priority_code,		FND_API.G_MISS_CHAR)
	 , shipment_priority
	 , nvl(shipping_method_code,		FND_API.G_MISS_CHAR)
	 , nvl(shipping_instructions,		FND_API.G_MISS_CHAR)
	 , nvl(packing_instructions,		FND_API.G_MISS_CHAR)
	 , nvl(freight_carrier_code,		FND_API.G_MISS_CHAR)
	 , nvl(freight_terms_code,		FND_API.G_MISS_CHAR)
	 , freight_terms
	 , nvl(fob_point_code,			FND_API.G_MISS_CHAR)
	 , fob_point
	 , nvl(return_reason_code,		FND_API.G_MISS_CHAR)
	 , nvl(reference_type,			FND_API.G_MISS_CHAR)
	 , nvl(reference_header_id,		FND_API.G_MISS_NUM)
	 , nvl(reference_line_id,		FND_API.G_MISS_NUM)
	 , nvl(credit_invoice_line_id,		FND_API.G_MISS_NUM)
	 , nvl(customer_po_number,		FND_API.G_MISS_CHAR)
	 , nvl(customer_line_number,		FND_API.G_MISS_CHAR)
	 , nvl(customer_shipment_number,	FND_API.G_MISS_CHAR)
	 , nvl(customer_item_id,		FND_API.G_MISS_NUM)
	 , nvl(customer_item_id_type,		FND_API.G_MISS_CHAR)
	 , nvl(customer_item_name,		FND_API.G_MISS_CHAR)
--	 , nvl(customer_item_revision,		FND_API.G_MISS_CHAR)
	 , nvl(customer_item_net_price,		FND_API.G_MISS_NUM)
	 , nvl(customer_payment_term_id,	FND_API.G_MISS_NUM)
	 , customer_payment_term
	 , nvl(demand_bucket_type_code,		FND_API.G_MISS_CHAR)
	 , demand_bucket_type
	 , nvl(customer_dock_code,		FND_API.G_MISS_CHAR)
	 , nvl(customer_job,			FND_API.G_MISS_CHAR)
	 , nvl(customer_production_line,	FND_API.G_MISS_CHAR)
	 , nvl(cust_model_serial_number,	FND_API.G_MISS_CHAR)
	 , nvl(project_id,			FND_API.G_MISS_NUM)
	 , project
	 , nvl(task_id,				FND_API.G_MISS_NUM)
	 , task
	 , nvl(end_item_unit_number,		FND_API.G_MISS_CHAR)
	 , nvl(item_revision,			FND_API.G_MISS_CHAR)
	 , nvl(service_duration,		FND_API.G_MISS_NUM)
	 , nvl(service_period,			FND_API.G_MISS_CHAR)
	 , nvl(service_start_date,		FND_API.G_MISS_DATE)
	 , nvl(service_end_date,		FND_API.G_MISS_DATE)
	 , nvl(service_coterminate_flag,	FND_API.G_MISS_CHAR)
	 , nvl(unit_selling_percent,		FND_API.G_MISS_NUM)
	 , nvl(unit_list_percent,		FND_API.G_MISS_NUM)
	 , nvl(unit_percent_base_price,		FND_API.G_MISS_NUM)
	 , nvl(service_number,			FND_API.G_MISS_NUM)
--	 , nvl(fulfilled_flag,			FND_API.G_MISS_CHAR)--ToBeAdded
--	 , nvl(closed_flag,			FND_API.G_MISS_CHAR)
	 , nvl(cancelled_flag,			FND_API.G_MISS_CHAR)
	 , nvl(context,                         FND_API.G_MISS_CHAR)
	 , nvl(attribute1,			FND_API.G_MISS_CHAR)
	 , nvl(attribute2,			FND_API.G_MISS_CHAR)
	 , nvl(attribute3,			FND_API.G_MISS_CHAR)
	 , nvl(attribute4,			FND_API.G_MISS_CHAR)
	 , nvl(attribute5,			FND_API.G_MISS_CHAR)
	 , nvl(attribute6,			FND_API.G_MISS_CHAR)
	 , nvl(attribute7,			FND_API.G_MISS_CHAR)
	 , nvl(attribute8,			FND_API.G_MISS_CHAR)
	 , nvl(attribute9,			FND_API.G_MISS_CHAR)
	 , nvl(attribute10,			FND_API.G_MISS_CHAR)
	 , nvl(attribute11,			FND_API.G_MISS_CHAR)
	 , nvl(attribute12,			FND_API.G_MISS_CHAR)
	 , nvl(attribute13,			FND_API.G_MISS_CHAR)
	 , nvl(attribute14,			FND_API.G_MISS_CHAR)
	 , nvl(attribute15,			FND_API.G_MISS_CHAR)
	 , nvl(attribute16,			FND_API.G_MISS_CHAR)  -- for bug 2184255
	 , nvl(attribute17,			FND_API.G_MISS_CHAR)
	 , nvl(attribute18,			FND_API.G_MISS_CHAR)
	 , nvl(attribute19,			FND_API.G_MISS_CHAR)
	 , nvl(attribute20,			FND_API.G_MISS_CHAR)
	 , nvl(tp_context,			FND_API.G_MISS_CHAR)
	 , nvl(tp_attribute1,			FND_API.G_MISS_CHAR)
	 , nvl(tp_attribute2,			FND_API.G_MISS_CHAR)
	 , nvl(tp_attribute3,			FND_API.G_MISS_CHAR)
	 , nvl(tp_attribute4,			FND_API.G_MISS_CHAR)
	 , nvl(tp_attribute5,			FND_API.G_MISS_CHAR)
	 , nvl(tp_attribute6,			FND_API.G_MISS_CHAR)
	 , nvl(tp_attribute7,			FND_API.G_MISS_CHAR)
	 , nvl(tp_attribute8,			FND_API.G_MISS_CHAR)
	 , nvl(tp_attribute9,			FND_API.G_MISS_CHAR)
	 , nvl(tp_attribute10,			FND_API.G_MISS_CHAR)
	 , nvl(tp_attribute11,			FND_API.G_MISS_CHAR)
	 , nvl(tp_attribute12,			FND_API.G_MISS_CHAR)
	 , nvl(tp_attribute13,			FND_API.G_MISS_CHAR)
	 , nvl(tp_attribute14,			FND_API.G_MISS_CHAR)
	 , nvl(tp_attribute15,			FND_API.G_MISS_CHAR)
	 , nvl(industry_context,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute1,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute2,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute3,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute4,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute5,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute6,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute7,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute8,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute9,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute10,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute11,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute12,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute13,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute14,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute15,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute16,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute17,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute18,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute19,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute20,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute21,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute22,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute23,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute24,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute25,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute26,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute27,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute28,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute29,		FND_API.G_MISS_CHAR)
	 , nvl(industry_attribute30,		FND_API.G_MISS_CHAR)
	 , nvl(pricing_context,			FND_API.G_MISS_CHAR)
	 , nvl(pricing_attribute1,		FND_API.G_MISS_CHAR)
	 , nvl(pricing_attribute2,		FND_API.G_MISS_CHAR)
	 , nvl(pricing_attribute3,		FND_API.G_MISS_CHAR)
	 , nvl(pricing_attribute4,		FND_API.G_MISS_CHAR)
	 , nvl(pricing_attribute5,		FND_API.G_MISS_CHAR)
	 , nvl(pricing_attribute6,		FND_API.G_MISS_CHAR)
	 , nvl(pricing_attribute7,		FND_API.G_MISS_CHAR)
	 , nvl(pricing_attribute8,		FND_API.G_MISS_CHAR)
	 , nvl(pricing_attribute9,		FND_API.G_MISS_CHAR)
	 , nvl(pricing_attribute10,		FND_API.G_MISS_CHAR)
	 , nvl(global_attribute_category,	FND_API.G_MISS_CHAR)
	 , nvl(global_attribute1,		FND_API.G_MISS_CHAR)
	 , nvl(global_attribute2,		FND_API.G_MISS_CHAR)
	 , nvl(global_attribute3,		FND_API.G_MISS_CHAR)
	 , nvl(global_attribute4,		FND_API.G_MISS_CHAR)
	 , nvl(global_attribute5,		FND_API.G_MISS_CHAR)
	 , nvl(global_attribute6,		FND_API.G_MISS_CHAR)
	 , nvl(global_attribute7,		FND_API.G_MISS_CHAR)
	 , nvl(global_attribute8,		FND_API.G_MISS_CHAR)
	 , nvl(global_attribute9,		FND_API.G_MISS_CHAR)
	 , nvl(global_attribute10,		FND_API.G_MISS_CHAR)
	 , nvl(global_attribute11,		FND_API.G_MISS_CHAR)
	 , nvl(global_attribute12,		FND_API.G_MISS_CHAR)
	 , nvl(global_attribute13,		FND_API.G_MISS_CHAR)
	 , nvl(global_attribute14,		FND_API.G_MISS_CHAR)
	 , nvl(global_attribute15,		FND_API.G_MISS_CHAR)
	 , nvl(global_attribute16,		FND_API.G_MISS_CHAR)
	 , nvl(global_attribute17,		FND_API.G_MISS_CHAR)
	 , nvl(global_attribute18,		FND_API.G_MISS_CHAR)
	 , nvl(global_attribute19,		FND_API.G_MISS_CHAR)
	 , nvl(global_attribute20,		FND_API.G_MISS_CHAR)
	 , nvl(return_context,                  FND_API.G_MISS_CHAR)
	 , nvl(return_attribute1,		FND_API.G_MISS_CHAR)
	 , nvl(return_attribute2,		FND_API.G_MISS_CHAR)
	 , nvl(return_attribute3,		FND_API.G_MISS_CHAR)
	 , nvl(return_attribute4,		FND_API.G_MISS_CHAR)
	 , nvl(return_attribute5,		FND_API.G_MISS_CHAR)
	 , nvl(return_attribute6,		FND_API.G_MISS_CHAR)
	 , nvl(return_attribute7,		FND_API.G_MISS_CHAR)
	 , nvl(return_attribute8,		FND_API.G_MISS_CHAR)
	 , nvl(return_attribute9,		FND_API.G_MISS_CHAR)
	 , nvl(return_attribute10,		FND_API.G_MISS_CHAR)
	 , nvl(return_attribute11,		FND_API.G_MISS_CHAR)
	 , nvl(return_attribute12,		FND_API.G_MISS_CHAR)
	 , nvl(return_attribute13,		FND_API.G_MISS_CHAR)
	 , nvl(return_attribute14,		FND_API.G_MISS_CHAR)
	 , nvl(return_attribute15,		FND_API.G_MISS_CHAR)
         , request_id
	 , nvl(operation_code,			OE_GLOBALS.G_OPR_CREATE)
	 , nvl(status_flag,		        FND_API.G_MISS_CHAR)
	 , nvl(change_reason,			FND_API.G_MISS_CHAR)
	 , nvl(change_comments,			FND_API.G_MISS_CHAR)
	 , nvl(service_txn_reason_code,	        FND_API.G_MISS_CHAR)
	 , nvl(service_txn_comments,		FND_API.G_MISS_CHAR)
	 , nvl(service_reference_type_code,     FND_API.G_MISS_CHAR)
	 , nvl(service_reference_order,	        FND_API.G_MISS_CHAR)
	 , nvl(service_reference_line,	        FND_API.G_MISS_CHAR)
	 , nvl(service_reference_system,	FND_API.G_MISS_CHAR)
	 , INVENTORY_ITEM_SEGMENT_1
	 , INVENTORY_ITEM_SEGMENT_2
	 , INVENTORY_ITEM_SEGMENT_3
	 , INVENTORY_ITEM_SEGMENT_4
	 , INVENTORY_ITEM_SEGMENT_5
	 , INVENTORY_ITEM_SEGMENT_6
	 , INVENTORY_ITEM_SEGMENT_7
	 , INVENTORY_ITEM_SEGMENT_8
	 , INVENTORY_ITEM_SEGMENT_9
	 , INVENTORY_ITEM_SEGMENT_10
	 , INVENTORY_ITEM_SEGMENT_11
	 , INVENTORY_ITEM_SEGMENT_12
	 , INVENTORY_ITEM_SEGMENT_13
	 , INVENTORY_ITEM_SEGMENT_14
	 , INVENTORY_ITEM_SEGMENT_15
	 , INVENTORY_ITEM_SEGMENT_16
	 , INVENTORY_ITEM_SEGMENT_17
	 , INVENTORY_ITEM_SEGMENT_18
	 , INVENTORY_ITEM_SEGMENT_19
	 , INVENTORY_ITEM_SEGMENT_20
	 , commitment
	 , nvl(commitment_id,   		  FND_API.G_MISS_NUM)
-- aksingh subinventory
         , nvl(subinventory,                      FND_API.G_MISS_CHAR)
         , salesrep
         , nvl(salesrep_id,                       FND_API.G_MISS_NUM)
         , nvl(earliest_acceptable_date,          FND_API.G_MISS_DATE)
         , nvl(latest_acceptable_date,            FND_API.G_MISS_DATE)
         , split_from_line_ref --bsadri
         , split_from_shipment_ref
	 , invoice_to_address1
	 , invoice_to_address2
	 , invoice_to_address3
	 , invoice_to_address4
	 , invoice_to_city
	 , invoice_to_state
	 , invoice_to_postal_code
	 , invoice_to_country
      -- { Start add new columns to select for the Add Customer
      -- , Orig_Ship_Address_Ref
      -- , Orig_Bill_Address_Ref
      -- , Orig_Deliver_Address_Ref
      -- , Ship_to_Contact_Ref
      -- , Bill_to_Contact_Ref
      -- , Deliver_to_Contact_Ref
      -- End add new columns to select for the Add Customer}
         , nvl(Config_Header_Id,               FND_API.G_MISS_NUM)
         , nvl(Config_Rev_Nbr,                 FND_API.G_MISS_NUM)
         , nvl(Configuration_ID,               FND_API.G_MISS_NUM)
         , ship_to_customer_name
         , ship_to_customer_number
         , nvl(ship_to_customer_id,	       FND_API.G_MISS_NUM)
         , invoice_to_customer_name
         , invoice_to_customer_number
         , nvl(invoice_to_customer_id,	       FND_API.G_MISS_NUM)
         , deliver_to_customer_name
         , deliver_to_customer_number
         , nvl(deliver_to_customer_id,	       FND_API.G_MISS_NUM)
         , nvl(user_item_description,	       FND_API.G_MISS_CHAR)
         , override_atp_date_code
         , xml_transaction_type_code
         , nvl(blanket_number,	               FND_API.G_MISS_NUM)
         , nvl(blanket_line_number,	       FND_API.G_MISS_NUM)
         , shipping_method
      FROM oe_lines_interface
     WHERE order_source_id              = l_order_source_id
       AND orig_sys_document_ref 	= l_orig_sys_document_ref
       AND  (decode(l_customer_key_profile, 'Y',
             nvl(sold_to_org_id,                  -999), 1)
             = decode(l_customer_key_profile, 'Y',
             nvl(p_sold_to_org_id,                -999), 1)
          OR decode(l_customer_key_profile, 'Y',
             nvl(sold_to_org,                  ' '), '')
             = decode(l_customer_key_profile, 'Y',
             nvl(p_sold_to_org,                ' '), ''))
       AND nvl(change_sequence,      	FND_API.G_MISS_CHAR)
	 = nvl(l_change_sequence,       FND_API.G_MISS_CHAR)
       AND request_id		 	= l_request_id
       AND nvl(rejected_flag, 'N')      = 'Y'
;

/* -----------------------------------------------------------
   Line Lot Serials cursor
   -----------------------------------------------------------
*/
    CURSOR l_lot_serial_cursor IS
    SELECT nvl(orig_sys_lotserial_ref,	FND_API.G_MISS_CHAR)
	 , nvl(change_request_code,	FND_API.G_MISS_CHAR)
	 , nvl(lot_number,		FND_API.G_MISS_CHAR)
	 , nvl(from_serial_number,	FND_API.G_MISS_CHAR)
	 , nvl(to_serial_number,	FND_API.G_MISS_CHAR)
	 , nvl(quantity,		FND_API.G_MISS_NUM)
	 , nvl(context,			FND_API.G_MISS_CHAR)
	 , nvl(attribute1,		FND_API.G_MISS_CHAR)
	 , nvl(attribute2,		FND_API.G_MISS_CHAR)
	 , nvl(attribute3,		FND_API.G_MISS_CHAR)
	 , nvl(attribute4,		FND_API.G_MISS_CHAR)
	 , nvl(attribute5,		FND_API.G_MISS_CHAR)
	 , nvl(attribute6,		FND_API.G_MISS_CHAR)
	 , nvl(attribute7,		FND_API.G_MISS_CHAR)
	 , nvl(attribute8,		FND_API.G_MISS_CHAR)
	 , nvl(attribute9,		FND_API.G_MISS_CHAR)
	 , nvl(attribute10,		FND_API.G_MISS_CHAR)
	 , nvl(attribute11,		FND_API.G_MISS_CHAR)
	 , nvl(attribute12,		FND_API.G_MISS_CHAR)
	 , nvl(attribute13,		FND_API.G_MISS_CHAR)
	 , nvl(attribute14,		FND_API.G_MISS_CHAR)
	 , nvl(attribute15,		FND_API.G_MISS_CHAR)
	 , nvl(operation_code,		OE_GLOBALS.G_OPR_CREATE)
      FROM oe_lotserials_interface
     WHERE order_source_id         	= l_order_source_id
       AND orig_sys_document_ref 	= l_orig_sys_document_ref
       AND  (decode(l_customer_key_profile, 'Y',
             nvl(sold_to_org_id,                  -999), 1)
             = decode(l_customer_key_profile, 'Y',
             nvl(p_sold_to_org_id,                -999), 1)
          OR decode(l_customer_key_profile, 'Y',
             nvl(sold_to_org,                  ' '), '')
             = decode(l_customer_key_profile, 'Y',
             nvl(p_sold_to_org,                ' '), ''))
       AND nvl(change_sequence,      	FND_API.G_MISS_CHAR)
	 = nvl(l_change_sequence,       FND_API.G_MISS_CHAR)
       AND orig_sys_line_ref 		= l_orig_sys_line_ref
       AND nvl(orig_sys_shipment_ref,	FND_API.G_MISS_CHAR)
	 = nvl(l_orig_sys_shipment_ref,	FND_API.G_MISS_CHAR)
       AND request_id		 	= p_request_id
;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE INITIALIZATION' ) ;
      END IF;

      l_line_rec 		:= OE_Order_Pub.G_MISS_LINE_REC;
      l_line_tbl 		:= OE_Order_Pub.G_MISS_LINE_TBL;
      l_line_val_rec 		:= OE_Order_Pub.G_MISS_LINE_VAL_REC;
      l_line_val_tbl 		:= OE_Order_Pub.G_MISS_LINE_VAL_TBL;
      l_lot_serial_rec 		:= OE_Order_Pub.G_MISS_LOT_SERIAL_REC;
      l_lot_serial_tbl 		:= OE_Order_Pub.G_MISS_LOT_SERIAL_TBL;


 If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
  fnd_profile.get('ONT_INCLUDE_CUST_IN_OI_KEY', l_customer_key_profile);
  l_customer_key_profile := nvl(l_customer_key_profile, 'N');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CUSTOMER KEY PROFILE SETTING = '||l_customer_key_profile ) ;
  END IF;
 End If;



/* -----------------------------------------------------------
   Lines
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE LINES LOOP' ) ;
      END IF;

  OPEN l_line_cursor;
  LOOP
     FETCH l_line_cursor
      INTO l_line_rec.order_source_id
         , l_line_rec.orig_sys_document_ref
         , l_line_rec.orig_sys_line_ref
	 , l_line_rec.orig_sys_shipment_ref
	 , l_line_rec.change_request_code
	 , l_line_rec.org_id
	 , l_line_rec.line_number
	 , l_line_rec.shipment_number
	 , l_line_rec.line_id
	 , l_line_rec.line_type_id
	 , l_line_val_rec.line_type
	 , l_line_rec.item_type_code
	 , l_line_rec.inventory_item_id
	 , l_line_val_rec.inventory_item
	 , l_line_rec.top_model_line_ref
	 , l_line_rec.link_to_line_ref
	 , l_line_rec.explosion_date
	 , l_line_rec.ato_line_id
	 , l_line_rec.component_sequence_id
	 , l_line_rec.component_code
	 , l_line_rec.sort_order
	 , l_line_rec.model_group_number
	 , l_line_rec.option_number
	 , l_line_rec.option_flag
	 , l_line_rec.ship_model_complete_flag
	 , l_line_rec.source_type_code
	 , l_line_rec.schedule_status_code
	 , l_line_rec.schedule_ship_date
         , l_line_rec.late_demand_penalty_factor
	 , l_line_rec.schedule_arrival_date
	 , l_line_rec.actual_arrival_date
  	 , l_line_rec.request_date
	 , l_line_rec.promise_date
	 , l_line_rec.delivery_lead_time
	 , l_line_rec.ordered_quantity
	 , l_line_rec.order_quantity_uom
	 , l_line_rec.shipping_quantity
	 , l_line_rec.shipping_quantity_uom
	 , l_line_rec.shipped_quantity
	 , l_line_rec.cancelled_quantity
	 , l_line_rec.fulfilled_quantity
   /* OPM variables */
         , l_line_rec.ordered_quantity2
         , l_line_rec.ordered_quantity_uom2
         , l_line_rec.shipping_quantity2
         , l_line_rec.shipping_quantity_uom2
         , l_line_rec.shipped_quantity2
         , l_line_rec.cancelled_quantity2
         , l_line_rec.fulfilled_quantity2
         , l_line_rec.preferred_grade
   /* end OPM vairables */
	 , l_line_rec.pricing_quantity
	 , l_line_rec.pricing_quantity_uom
	 , l_line_rec.sold_from_org_id
	 , l_line_val_rec.sold_from_org
	 , l_line_rec.sold_to_org_id
	 , l_line_val_rec.sold_to_org
	 , l_line_rec.ship_from_org_id
	 , l_line_val_rec.ship_from_org
	 , l_line_rec.ship_to_org_id
	 , l_line_val_rec.ship_to_org
	 , l_line_rec.deliver_to_org_id
	 , l_line_val_rec.deliver_to_org
	 , l_line_rec.invoice_to_org_id
	 , l_line_val_rec.invoice_to_org
	 , l_line_val_rec.ship_to_address1
	 , l_line_val_rec.ship_to_address2
	 , l_line_val_rec.ship_to_address3
	 , l_line_val_rec.ship_to_address4
	 , l_line_val_rec.ship_to_city
	 , l_line_val_rec.ship_to_state
	 , l_line_val_rec.ship_to_zip
	 , l_line_val_rec.ship_to_country
	 , l_line_rec.ship_to_contact_id
	 , l_line_val_rec.ship_to_contact
	 , l_line_rec.deliver_to_contact_id
	 , l_line_val_rec.deliver_to_contact
	 , l_line_rec.invoice_to_contact_id
	 , l_line_val_rec.invoice_to_contact
	 , l_line_rec.drop_ship_flag
	 , l_line_rec.ship_tolerance_above
	 , l_line_rec.ship_tolerance_below
	 , l_line_rec.price_list_id
	 , l_line_val_rec.price_list
	 , l_line_rec.pricing_date
	 , l_line_rec.unit_list_price
	 , l_line_rec.unit_selling_price
	 , l_line_rec.calculate_price_flag
	 , l_line_rec.ship_set_id
	 , l_line_rec.ship_set
	 , l_line_rec.arrival_set_id
	 , l_line_rec.arrival_set
	 , l_line_rec.fulfillment_set_id
	 , l_line_rec.fulfillment_set
	 , l_line_rec.tax_code
	 , l_line_rec.tax_value
	 , l_line_rec.tax_date
	 , l_line_rec.tax_point_code
	 , l_line_val_rec.tax_point
	 , l_line_rec.tax_exempt_flag
	 , l_line_rec.tax_exempt_number
	 , l_line_rec.tax_exempt_reason_code
	 , l_line_val_rec.tax_exempt_reason
	 , l_line_rec.agreement_id
	 , l_line_val_rec.agreement
	 , l_line_rec.invoicing_rule_id
	 , l_line_val_rec.invoicing_rule
	 , l_line_rec.accounting_rule_id
	 , l_line_rec.accounting_rule_duration
	 , l_line_val_rec.accounting_rule
	 , l_line_rec.payment_term_id
	 , l_line_val_rec.payment_term
	 , l_line_rec.demand_class_code
	 , l_line_rec.shipment_priority_code
	 , l_line_val_rec.shipment_priority
	 , l_line_rec.shipping_method_code
	 , l_line_rec.shipping_instructions
	 , l_line_rec.packing_instructions
	 , l_line_rec.freight_carrier_code
	 , l_line_rec.freight_terms_code
	 , l_line_val_rec.freight_terms
	 , l_line_rec.fob_point_code
	 , l_line_val_rec.fob_point
	 , l_line_rec.return_reason_code
	 , l_line_rec.reference_type
	 , l_line_rec.reference_header_id
	 , l_line_rec.reference_line_id
	 , l_line_rec.credit_invoice_line_id
	 , l_line_rec.cust_po_number
	 , l_line_rec.customer_line_number
	 , l_line_rec.customer_shipment_number
	 , l_line_rec.ordered_item_id
	 , l_line_rec.item_identifier_type
	 , l_line_rec.ordered_item
--	 , l_line_rec.customer_item_revision
	 , l_line_rec.customer_item_net_price
	 , l_line_rec.customer_payment_term_id
	 , l_line_val_rec.customer_payment_term
	 , l_line_rec.demand_bucket_type_code
	 , l_line_val_rec.demand_bucket_type
	 , l_line_rec.customer_dock_code
	 , l_line_rec.customer_job
	 , l_line_rec.customer_production_line
	 , l_line_rec.cust_model_serial_number
	 , l_line_rec.project_id
	 , l_line_val_rec.project
	 , l_line_rec.task_id
	 , l_line_val_rec.task
	 , l_line_rec.end_item_unit_number
	 , l_line_rec.item_revision
	 , l_line_rec.service_duration
	 , l_line_rec.service_period
	 , l_line_rec.service_start_date
	 , l_line_rec.service_end_date
	 , l_line_rec.service_coterminate_flag
	 , l_line_rec.unit_selling_percent
	 , l_line_rec.unit_list_percent
	 , l_line_rec.unit_percent_base_price
	 , l_line_rec.service_number
--	 , l_line_rec.fulfilled_flag	 -- To be added in Process Order
--	 , l_line_rec.closed_flag
	 , l_line_rec.cancelled_flag
	 , l_line_rec.context
	 , l_line_rec.attribute1
	 , l_line_rec.attribute2
	 , l_line_rec.attribute3
	 , l_line_rec.attribute4
	 , l_line_rec.attribute5
	 , l_line_rec.attribute6
	 , l_line_rec.attribute7
	 , l_line_rec.attribute8
	 , l_line_rec.attribute9
	 , l_line_rec.attribute10
	 , l_line_rec.attribute11
	 , l_line_rec.attribute12
	 , l_line_rec.attribute13
	 , l_line_rec.attribute14
	 , l_line_rec.attribute15
	 , l_line_rec.attribute16  -- For bug 2184255
	 , l_line_rec.attribute17
	 , l_line_rec.attribute18
	 , l_line_rec.attribute19
	 , l_line_rec.attribute20
	 , l_line_rec.tp_context
	 , l_line_rec.tp_attribute1
	 , l_line_rec.tp_attribute2
	 , l_line_rec.tp_attribute3
	 , l_line_rec.tp_attribute4
	 , l_line_rec.tp_attribute5
	 , l_line_rec.tp_attribute6
	 , l_line_rec.tp_attribute7
	 , l_line_rec.tp_attribute8
	 , l_line_rec.tp_attribute9
	 , l_line_rec.tp_attribute10
	 , l_line_rec.tp_attribute11
	 , l_line_rec.tp_attribute12
	 , l_line_rec.tp_attribute13
	 , l_line_rec.tp_attribute14
	 , l_line_rec.tp_attribute15
	 , l_line_rec.industry_context
	 , l_line_rec.industry_attribute1
	 , l_line_rec.industry_attribute2
	 , l_line_rec.industry_attribute3
	 , l_line_rec.industry_attribute4
	 , l_line_rec.industry_attribute5
	 , l_line_rec.industry_attribute6
	 , l_line_rec.industry_attribute7
	 , l_line_rec.industry_attribute8
	 , l_line_rec.industry_attribute9
	 , l_line_rec.industry_attribute10
	 , l_line_rec.industry_attribute11
	 , l_line_rec.industry_attribute12
	 , l_line_rec.industry_attribute13
	 , l_line_rec.industry_attribute14
	 , l_line_rec.industry_attribute15
	 , l_line_rec.industry_attribute16
	 , l_line_rec.industry_attribute17
	 , l_line_rec.industry_attribute18
	 , l_line_rec.industry_attribute19
	 , l_line_rec.industry_attribute20
	 , l_line_rec.industry_attribute21
	 , l_line_rec.industry_attribute22
	 , l_line_rec.industry_attribute23
	 , l_line_rec.industry_attribute24
	 , l_line_rec.industry_attribute25
	 , l_line_rec.industry_attribute26
	 , l_line_rec.industry_attribute27
	 , l_line_rec.industry_attribute28
	 , l_line_rec.industry_attribute29
	 , l_line_rec.industry_attribute30
	 , l_line_rec.pricing_context
	 , l_line_rec.pricing_attribute1
	 , l_line_rec.pricing_attribute2
	 , l_line_rec.pricing_attribute3
	 , l_line_rec.pricing_attribute4
	 , l_line_rec.pricing_attribute5
	 , l_line_rec.pricing_attribute6
	 , l_line_rec.pricing_attribute7
	 , l_line_rec.pricing_attribute8
	 , l_line_rec.pricing_attribute9
	 , l_line_rec.pricing_attribute10
	 , l_line_rec.global_attribute_category
	 , l_line_rec.global_attribute1
	 , l_line_rec.global_attribute2
	 , l_line_rec.global_attribute3
	 , l_line_rec.global_attribute4
	 , l_line_rec.global_attribute5
	 , l_line_rec.global_attribute6
	 , l_line_rec.global_attribute7
	 , l_line_rec.global_attribute8
	 , l_line_rec.global_attribute9
	 , l_line_rec.global_attribute10
	 , l_line_rec.global_attribute11
	 , l_line_rec.global_attribute12
	 , l_line_rec.global_attribute13
	 , l_line_rec.global_attribute14
	 , l_line_rec.global_attribute15
	 , l_line_rec.global_attribute16
	 , l_line_rec.global_attribute17
	 , l_line_rec.global_attribute18
	 , l_line_rec.global_attribute19
	 , l_line_rec.global_attribute20
	 , l_line_rec.return_context
	 , l_line_rec.return_attribute1
	 , l_line_rec.return_attribute2
	 , l_line_rec.return_attribute3
	 , l_line_rec.return_attribute4
	 , l_line_rec.return_attribute5
	 , l_line_rec.return_attribute6
	 , l_line_rec.return_attribute7
	 , l_line_rec.return_attribute8
	 , l_line_rec.return_attribute9
	 , l_line_rec.return_attribute10
	 , l_line_rec.return_attribute11
	 , l_line_rec.return_attribute12
	 , l_line_rec.return_attribute13
	 , l_line_rec.return_attribute14
	 , l_line_rec.return_attribute15
      , l_line_rec.request_id
	 , l_line_rec.operation
	 , l_line_rec.status_flag
	 , l_line_rec.change_reason
	 , l_line_rec.change_comments
	 , l_line_rec.service_txn_reason_code
	 , l_line_rec.service_txn_comments
	 , l_line_rec.service_reference_type_code
	 , l_line_rec.service_reference_order
	 , l_line_rec.service_reference_line
	 , l_line_rec.service_reference_system
	 , l_segment_array(1)
	 , l_segment_array(2)
	 , l_segment_array(3)
	 , l_segment_array(4)
	 , l_segment_array(5)
	 , l_segment_array(6)
	 , l_segment_array(7)
	 , l_segment_array(8)
	 , l_segment_array(9)
	 , l_segment_array(10)
	 , l_segment_array(11)
	 , l_segment_array(12)
	 , l_segment_array(13)
	 , l_segment_array(14)
	 , l_segment_array(15)
	 , l_segment_array(16)
	 , l_segment_array(17)
	 , l_segment_array(18)
	 , l_segment_array(19)
	 , l_segment_array(20)
         , l_line_val_rec.commitment
         , l_line_rec.commitment_id
-- aksingh subinventory
         , l_line_rec.subinventory
         ,l_line_val_rec.salesrep
         ,l_line_rec.salesrep_id
         ,l_line_rec.earliest_acceptable_date
         ,l_line_rec.latest_acceptable_date
         , l_line_rec.split_from_line_ref
         , l_line_rec.split_from_shipment_ref
         ,l_line_val_rec.invoice_to_address1
         ,l_line_val_rec.invoice_to_address2
         ,l_line_val_rec.invoice_to_address3
         ,l_line_val_rec.invoice_to_address4
	 ,l_line_val_rec.invoice_to_city
	 ,l_line_val_rec.invoice_to_state
	 ,l_line_val_rec.invoice_to_zip
	 ,l_line_val_rec.invoice_to_country
      -- Not enabling these columns for the fix 2922709, will do it later
      -- { Start add new columns to select for the Add Customer
      -- , l_line_customer_rec.Orig_Ship_Address_Ref
      -- , l_line_customer_rec.Orig_Bill_Address_Ref
      -- , l_line_customer_rec.Orig_Deliver_Address_Ref
      -- , l_line_customer_rec.Ship_to_Contact_Ref
      -- , l_line_customer_rec.Bill_to_Contact_Ref
      -- , l_line_customer_rec.Deliver_to_Contact_Ref
      -- End add new columns to select for the Add Customer}
         , l_line_rec.Config_Header_Id
         , l_line_rec.Config_Rev_Nbr
         , l_line_rec.Configuration_Id
         , l_line_val_rec.ship_to_customer_name_oi
         , l_line_val_rec.ship_to_customer_number_oi
         , l_line_rec.ship_to_customer_id
         , l_line_val_rec.invoice_to_customer_name_oi
         , l_line_val_rec.invoice_to_customer_number_oi
         , l_line_rec.invoice_to_customer_id
         , l_line_val_rec.deliver_to_customer_name_oi
         , l_line_val_rec.deliver_to_customer_number_oi
         , l_line_rec.deliver_to_customer_id
         , l_line_rec.user_item_description
         , l_line_rec.override_atp_date_code
         , l_line_rec.xml_transaction_type_code
         , l_line_rec.blanket_number
         , l_line_rec.blanket_line_number
         , l_line_val_rec.shipping_method
;
      EXIT WHEN l_line_cursor%NOTFOUND;

      l_line_count := l_line_count + 1;
      -- added part of bug 2922709
      l_line_rec.header_id := l_header_id;
      l_line_rec.reserved_quantity := NULL;
      OE_Line_Util.Convert_Miss_To_Null (l_line_rec);
    --OE_Line_Util.Convert_Miss_To_Null (l_line_val_rec);
      l_line_tbl(l_line_count) := l_line_rec;
      l_line_val_tbl(l_line_count) := l_line_val_rec;

      l_orig_sys_line_ref     := l_line_rec.orig_sys_line_ref;
      l_orig_sys_shipment_ref := l_line_rec.orig_sys_shipment_ref;

      IF l_debug_level  > 0 THEN
	 oe_debug_pub.add('origsysline_ref ('||l_line_count||'):'|| l_line_tbl(l_line_count).orig_sys_line_ref ) ;
         oe_debug_pub.add('origsysshipment_ref ('||l_line_count||'):'|| l_line_tbl(l_line_count).orig_sys_shipment_ref ) ;
         oe_debug_pub.add('val table Sold_To_Org ('||l_line_count||'):'|| l_line_val_tbl(l_line_count).sold_to_org) ;
      END IF;


/* -----------------------------------------------------------
   Line Lot Serials
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE LINE LOT SERIALS LOOP' ) ;
   END IF;

  l_lot_serial_count := 0;
  OPEN l_lot_serial_cursor;
  LOOP
     FETCH l_lot_serial_cursor
      INTO l_lot_serial_rec.orig_sys_lotserial_ref
	 , l_lot_serial_rec.change_request_code
	 , l_lot_serial_rec.lot_number
	 , l_lot_serial_rec.from_serial_number
	 , l_lot_serial_rec.to_serial_number
	 , l_lot_serial_rec.quantity
	 , l_lot_serial_rec.context
	 , l_lot_serial_rec.attribute1
	 , l_lot_serial_rec.attribute2
	 , l_lot_serial_rec.attribute3
	 , l_lot_serial_rec.attribute4
	 , l_lot_serial_rec.attribute5
	 , l_lot_serial_rec.attribute6
	 , l_lot_serial_rec.attribute7
	 , l_lot_serial_rec.attribute8
	 , l_lot_serial_rec.attribute9
	 , l_lot_serial_rec.attribute10
	 , l_lot_serial_rec.attribute11
	 , l_lot_serial_rec.attribute12
	 , l_lot_serial_rec.attribute13
	 , l_lot_serial_rec.attribute14
	 , l_lot_serial_rec.attribute15
	 , l_lot_serial_rec.operation
;
      EXIT WHEN l_lot_serial_cursor%NOTFOUND;

       l_lot_serial_rec.line_index := l_line_count;

       l_lot_serial_count := l_lot_serial_count + 1;
       l_lot_serial_tbl (l_lot_serial_count) := l_lot_serial_rec;

	        IF l_debug_level  > 0 THEN
	            oe_debug_pub.add(  'LINE LOT SERIAL REF ( '||L_LOT_SERIAL_COUNT||' ) : '|| L_LOT_SERIAL_TBL ( L_LOT_SERIAL_COUNT ) .LOT_NUMBER ) ;
	        END IF;

  END LOOP;
  CLOSE l_lot_serial_cursor;

  END LOOP;			/* Lines cursor */
  CLOSE l_line_cursor;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER GETTING REJECTED RECORDS' ) ;
  END IF;

/* -----------------------------------------------------------
   Return line and lot serial tables
   -----------------------------------------------------------
*/

  IF l_line_tbl.COUNT > 0 THEN
     x_rejected_line_tbl :=  l_line_tbl;
     x_rejected_line_val_tbl :=  l_line_val_tbl;

     IF l_lot_serial_tbl.COUNT > 0 THEN
        x_rejected_lot_serial_tbl := l_lot_serial_tbl;
     END IF;
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;


EXCEPTION
  WHEN OTHERS THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ENCOUNTERED OTHERS ERROR EXCEPTION IN OE_REJECTED_LINES_ACK.GET_REJECTED_LINES: '||SQLERRM ) ;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;

END Get_Rejected_Lines;

END OE_Rejected_Lines_Ack;

/
