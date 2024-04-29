--------------------------------------------------------
--  DDL for Package OE_CNCL_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CNCL_VALIDATE" AUTHID CURRENT_USER AS
/* $Header: OEXVCATS.pls 120.1 2006/02/20 22:05:18 mbhoumik noship $ */

--  =======================================================================
FUNCTION Accounting_Rule(p_accounting_rule_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Actual_Arrival_Date(p_actual_arrival_date IN DATE)RETURN BOOLEAN;
FUNCTION Actual_Shipment_Date(p_actual_shipment_date IN DATE)RETURN BOOLEAN;
FUNCTION Agreement(p_agreement_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Ato_Line(p_ato_line_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Auto_selected_Quantity(p_auto_selected_quantity IN NUMBER)RETURN BOOLEAN;
FUNCTION Booked(p_booked_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Cancelled(p_cancelled_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Cancelled_Quantity(p_cancelled_quantity IN NUMBER)RETURN BOOLEAN;
FUNCTION Component(p_component_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Component_Number(p_component_number IN NUMBER)RETURN BOOLEAN;
FUNCTION Component_Sequence(p_component_sequence_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Config_Header(p_config_header_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Config_Rev_Nbr(p_config_rev_nbr IN NUMBER)RETURN BOOLEAN;
FUNCTION Config_Display_Sequence(p_config_display_sequence IN NUMBER)RETURN BOOLEAN;
FUNCTION Configuration(p_configuration_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Conversion_Rate(p_conversion_rate IN NUMBER)RETURN BOOLEAN;
FUNCTION Conversion_Rate_Date ( p_conversion_rate_date IN DATE ) RETURN BOOLEAN;
FUNCTION Conversion_Type(p_conversion_type_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION CUSTOMER_PREFERENCE_SET(p_CUSTOMER_PREFERENCE_SET_CODE IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Created_By(p_created_by IN NUMBER)RETURN BOOLEAN;
FUNCTION Creation_Date(p_creation_date IN DATE)RETURN BOOLEAN;
FUNCTION Credit_Invoice_Line(p_credit_invoice_line_id IN NUMBER) RETURN BOOLEAN;
FUNCTION Cust_Dock(p_cust_dock_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Cust_Job(p_cust_job IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Cust_Model_Serial_Number(p_cust_model_serial_number IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Cust_Po_Number(p_cust_po_number IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Cust_Production_Line(p_cust_production_line IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Customer_Dock(p_customer_dock_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Customer_Job(p_customer_job IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Customer_Production_Line(p_customer_production_line IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Customer_Trx_Line(p_customer_trx_line_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Date_And_Time_Promised(p_date_and_time_promised IN DATE)RETURN BOOLEAN;
FUNCTION Date_And_Time_Requested(p_date_and_time_requested IN DATE)RETURN BOOLEAN;
FUNCTION Date_And_Time_Scheduled(p_date_and_time_scheduled IN DATE)RETURN BOOLEAN;
FUNCTION Date_Ordered(p_date_ordered IN DATE)RETURN BOOLEAN;
FUNCTION Date_Requested(p_date_requested IN DATE)RETURN BOOLEAN;
FUNCTION Deliver_To_Contact(p_deliver_to_contact_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Deliver_To_Org(p_deliver_to_org_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Delivery_Lead_Time(p_delivery_lead_time IN NUMBER)RETURN BOOLEAN;
FUNCTION Demand_Bucket_Type(p_demand_bucket_type IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Demand_Class(p_demand_class_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Demand_Stream(p_demand_stream_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Dep_Plan_Required(p_dep_plan_required_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Desc_Flex ( p_flex_name IN VARCHAR2 )RETURN BOOLEAN;
FUNCTION Description(p_description IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Dw_Update_Advice(p_dw_update_advice_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Earliest_Acceptable_Date(p_earliest_acceptable_date IN DATE)RETURN BOOLEAN;
FUNCTION Earliest_Schedule_Limit(p_earliest_schedule_limit IN NUMBER)RETURN BOOLEAN;
FUNCTION End_Date_Active(p_end_date_active IN DATE)RETURN BOOLEAN;
FUNCTION End_Item_Unit_Number(p_end_item_unit_number IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Expiration_Date(p_expiration_date IN DATE)RETURN BOOLEAN;
FUNCTION Explosion_Date(p_explosion_date IN DATE)RETURN BOOLEAN;
FUNCTION First_Ack(p_first_ack_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION First_Ack_Date(p_first_ack_date IN DATE)RETURN BOOLEAN;
FUNCTION Fob_Point(p_fob_point_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Freight_Carrier(p_freight_carrier_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Freight_Terms(p_freight_terms_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Fulfilled_Quantity(p_fulfilled_quantity IN NUMBER)RETURN BOOLEAN;
FUNCTION Fulfilled(p_fulfilled_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION fulfillment_method(p_fulfillment_method_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION fulfillment_date(p_fulfillment_date IN DATE)RETURN BOOLEAN;
FUNCTION Global_Attribute1(p_global_attribute1 IN VARCHAR2)RETURN BOOLEAN;

FUNCTION Calculate_Price_Flag(p_calculate_price_flag IN VARCHAR2)RETURN BOOLEAN;

FUNCTION Header(p_header_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Inventory_Item(p_inventory_item_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Internal_Item(p_internal_item_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Cust_Item_Setting(p_cust_item_setting_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Invoice_Interface_Status(p_invoice_interface_status IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Invoice_To_Contact(p_invoice_to_contact_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Invoice_To_Org(p_invoice_to_org_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Invoicing_Rule(p_invoicing_rule_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Ordered_Item_Id(p_ordered_item_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Item_Identifier_Type(p_item_identifier_type IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Ordered_Item(p_ordered_item IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Item_Revision(p_item_revision IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Item_Type(p_item_type_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Last_Ack(p_last_ack_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Last_Ack_Date(p_last_ack_date IN DATE)RETURN BOOLEAN;
FUNCTION Last_Update_Date(p_last_update_date IN DATE)RETURN BOOLEAN;
FUNCTION Last_Update_Login(p_last_update_login IN NUMBER)RETURN BOOLEAN;
FUNCTION Last_Updated_By(p_last_updated_by IN NUMBER)RETURN BOOLEAN;
FUNCTION Latest_Acceptable_Date(p_latest_acceptable_date IN DATE)RETURN BOOLEAN;
FUNCTION Latest_Schedule_Limit(p_latest_schedule_limit IN NUMBER)RETURN BOOLEAN;
FUNCTION Line(p_line_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Line_Category(p_line_category_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Line_Category_Code(line_category_code IN VARCHAR2) RETURN BOOLEAN;
FUNCTION Line_Number(p_line_number IN NUMBER)RETURN BOOLEAN;
FUNCTION Line_Type(p_line_type_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Link_To_Line(p_link_to_line_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Model_Group_Number(p_model_group_number IN NUMBER)RETURN BOOLEAN;
FUNCTION Mfg_Component_Sequence(p_mfg_component_sequence_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Name(p_name IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Oe_Item_Type(p_oe_item_type IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Open(p_open_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Option_Flag(p_option_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Option_Number(p_option_number IN NUMBER)RETURN BOOLEAN;
FUNCTION Order_Number(p_order_number IN NUMBER)
	  RETURN BOOLEAN;
FUNCTION Order_Quantity_Uom(p_order_quantity_uom IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Ordered_Quantity_Uom2(p_ordered_quantity_uom2 IN VARCHAR2)RETURN BOOLEAN; -- OPM
FUNCTION Order_Source(p_order_source_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Order_Type(p_order_type_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Ordered_Date(p_ordered_date IN DATE)RETURN BOOLEAN;
FUNCTION Order_Date_Type_Code(p_order_date_type_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Ordered_Quantity(p_ordered_quantity IN NUMBER)RETURN BOOLEAN;
FUNCTION Ordered_Quantity2(p_ordered_quantity2 IN NUMBER)RETURN BOOLEAN; -- OPM
FUNCTION Org(p_org_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Orig_Sys_Document_Ref(p_orig_sys_document_ref IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Orig_Sys_Line_Ref(p_orig_sys_line_ref IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Partial_Shipments_Allowed(p_partial_shipments_allowed IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Payment_Term(p_payment_term_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Planning_Priority(p_planning_priority IN NUMBER)RETURN BOOLEAN;
FUNCTION Percent(p_percent IN NUMBER)RETURN BOOLEAN;
FUNCTION Planning_Prod_Seq_No(p_planning_prod_seq_no IN NUMBER)RETURN BOOLEAN;
FUNCTION Preferred_Grade(p_preferred_grade IN VARCHAR2)RETURN BOOLEAN;  -- OPM
FUNCTION Price_List(p_price_list_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Pricing_Date(p_pricing_date IN DATE)RETURN BOOLEAN;
FUNCTION Pricing_Quantity(p_pricing_quantity IN NUMBER)RETURN BOOLEAN;
FUNCTION Pricing_Quantity_Uom(p_pricing_quantity_uom IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Program(p_program_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Program_Application(p_program_application_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Program_Update_Date(p_program_update_date IN DATE)RETURN BOOLEAN;
FUNCTION Project(p_project_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Promise_Date(p_promise_date IN DATE)RETURN BOOLEAN;
FUNCTION Re_Source(p_re_source_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Quantity_Cancelled(p_quantity_cancelled IN NUMBER)RETURN BOOLEAN;
FUNCTION Quantity_Fulfilled(p_quantity_fulfilled IN NUMBER)RETURN BOOLEAN;
FUNCTION Quantity_Ordered(p_quantity_ordered IN NUMBER)RETURN BOOLEAN;
FUNCTION Quantity_Shipped(p_quantity_shipped IN NUMBER)RETURN BOOLEAN;
FUNCTION RMA_ATTRIBUTE1(rma_attribute1 IN VARCHAR2) RETURN BOOLEAN;
FUNCTION RMA_ATTRIBUTE10(rma_attribute10 IN VARCHAR2) RETURN BOOLEAN;
FUNCTION RMA_ATTRIBUTE2(rma_attribute2 IN VARCHAR2) RETURN BOOLEAN;
FUNCTION RMA_ATTRIBUTE3(rma_attribute3 IN VARCHAR2) RETURN BOOLEAN;
FUNCTION RMA_ATTRIBUTE4(rma_attribute4 IN VARCHAR2) RETURN BOOLEAN;
FUNCTION RMA_ATTRIBUTE5(rma_attribute5 IN VARCHAR2) RETURN BOOLEAN;
FUNCTION RMA_ATTRIBUTE6(rma_attribute6 IN VARCHAR2) RETURN BOOLEAN;
FUNCTION RMA_ATTRIBUTE7(rma_attribute7 IN VARCHAR2) RETURN BOOLEAN;
FUNCTION RMA_ATTRIBUTE8(rma_attribute8 IN VARCHAR2) RETURN BOOLEAN;
FUNCTION RMA_ATTRIBUTE9(rma_attribute9 IN VARCHAR2) RETURN BOOLEAN;
FUNCTION RMA_CONTEXT(rma_context IN VARCHAR2) RETURN BOOLEAN;
FUNCTION Reference_Cust_Trx_Line_Id(reference_cust_trx_line_id IN NUMBER) RETURN BOOLEAN;
FUNCTION Reference_Header(p_reference_header_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Reference_Line(p_reference_line_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Reference_Type(p_reference_type IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Request(p_request_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Request_Date(p_request_date IN DATE)RETURN BOOLEAN;
FUNCTION Reserved_Quantity(p_reserved_quantity IN NUMBER)RETURN BOOLEAN;
FUNCTION Revision(p_revision IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Rla_Schedule_Type(p_rla_schedule_type_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Sales_Credit(p_sales_credit_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Salesrep(p_salesrep_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Sales_credit_type(p_sales_credit_type_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Schedule_Arrival_Date(p_schedule_arrival_date IN DATE)RETURN BOOLEAN;
FUNCTION Schedule_Ship_Date(p_schedule_ship_date IN DATE)RETURN BOOLEAN;
FUNCTION Schedule_Status(p_schedule_status_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Schedule_Item_Detail(p_schedule_item_detail_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Sequence_Starting_Point(p_sequence_starting_point IN NUMBER)RETURN BOOLEAN;
FUNCTION Ship_From_Org(p_ship_from_org_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Inventory_Org(p_inventory_org_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Ship_Model_Complete(p_ship_model_complete_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Ship_To_Contact(p_ship_to_contact_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Ship_To_Org(p_ship_to_org_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Site_Use(p_site_use_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Ship_Tolerance_Above(p_ship_tolerance_above IN NUMBER)RETURN BOOLEAN;
FUNCTION Ship_Tolerance_Below(p_ship_tolerance_below IN NUMBER)RETURN BOOLEAN;
FUNCTION Shippable(p_shippable_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Shipping_Interfaced(p_shipping_interfaced_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Shipping_Instructions(p_shipping_instructions IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Packing_Instructions(p_packing_instructions IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Under_Shipment_Tolerance(p_under_shipment_tolerance IN NUMBER)RETURN BOOLEAN;
FUNCTION Over_Shipment_Tolerance(p_over_shipment_tolerance IN NUMBER)RETURN BOOLEAN;
FUNCTION Under_Return_Tolerance(p_under_return_tolerance IN NUMBER)RETURN BOOLEAN;
FUNCTION Over_Return_Tolerance(p_over_return_tolerance IN NUMBER)RETURN BOOLEAN;
FUNCTION Shipment_Number(p_shipment_number IN NUMBER)RETURN BOOLEAN;
FUNCTION Shipment_Priority(p_shipment_priority_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Shipped_Quantity(p_shipped_quantity IN NUMBER)RETURN BOOLEAN;
FUNCTION Shipping_Method(p_shipping_method_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Shipping_Quantity(p_shipping_quantity IN NUMBER)RETURN BOOLEAN;
FUNCTION Shipping_Quantity_Uom(p_shipping_quantity_uom IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Sold_To_Contact(p_sold_to_contact_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Sold_To_Org(p_sold_to_org_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Subinventory(p_subinventory IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Customer(p_customer_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Intermed_Ship_To_Contact(p_intermed_ship_to_contact_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Intermed_Ship_To_Org(p_intermed_ship_to_org_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Sort_Order(p_sort_order IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Source_Document(p_source_document_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Source_Document_Line(p_source_document_line_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Source_Document_Type(p_source_document_type_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Source_Type(p_source_type_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Task(p_task_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Tax(p_tax_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Tax_Date(p_tax_date IN DATE)RETURN BOOLEAN;
FUNCTION Tax_Exempt(p_tax_exempt_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Tax_Exempt_Number(p_tax_exempt_number IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Tax_Exempt_Reason(p_tax_exempt_reason_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Tax_Point(p_tax_point_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Tax_Rate(p_tax_rate IN NUMBER)RETURN BOOLEAN;
FUNCTION Tax_Value(p_tax_value IN NUMBER)RETURN BOOLEAN;
FUNCTION Top_Model_Line(p_top_model_line_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Transactional_Curr(p_transactional_curr_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Unit_List_Price(p_unit_list_price IN NUMBER)RETURN BOOLEAN;
FUNCTION Unit_Selling_Price(p_unit_selling_price IN NUMBER)RETURN BOOLEAN;
FUNCTION Version_Number(p_version_number IN NUMBER)RETURN BOOLEAN;
FUNCTION Visible_Demand(p_visible_demand_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Wh_Update_Date(p_wh_update_date IN DATE)RETURN BOOLEAN;
Function SALES_CREDIT_PERCENT( p_percent IN Number) Return Boolean;

FUNCTION Applied_Flag(p_Applied_Flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Automatic(p_automatic_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Change_Reason_Code(p_Change_Reason_Code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Change_Reason_Text(p_Change_Reason_Text IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Discount(p_discount_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Discount_Line(p_discount_line_id IN NUMBER)RETURN BOOLEAN;
FUNCTION List_Header_id(p_List_Header_id IN NUMBER)RETURN BOOLEAN;
FUNCTION List_Line_id(p_List_Line_id IN NUMBER)RETURN BOOLEAN;
FUNCTION List_Line_Type_code(p_List_Line_Type_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Modified_From(p_Modified_From IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Modified_To(p_Modified_To IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Modifier_mechanism_type_code(p_Modifier_mechanism_type_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Price_Adjustment(p_price_adjustment_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Updated_Flag(p_Updated_Flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Update_Allowed(p_Update_Allowed IN VARCHAR2)RETURN BOOLEAN;

FUNCTION From_Serial_Number(p_from_serial_number IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Lot_Number(p_lot_number IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Lot_Serial(p_lot_serial_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Quantity(p_quantity IN NUMBER)RETURN BOOLEAN;
FUNCTION To_Serial_Number(p_to_serial_number IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Line_Set(p_line_set_id IN NUMBER) RETURN BOOLEAN;

FUNCTION Amount(p_amount IN NUMBER)RETURN BOOLEAN;
FUNCTION Appear_On_Ack(p_appear_on_ack_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Appear_On_Invoice(p_appear_on_invoice_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Charge(p_charge_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Conversion_Date(p_conversion_date IN DATE)RETURN BOOLEAN;
FUNCTION Cost_Or_Charge(p_cost_or_charge_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Currency(p_currency_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Departure(p_departure_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Estimated(p_estimated_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Inc_In_Sales_Performance(p_inc_in_sales_performance IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Invoiced(p_invoiced_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Lpn(p_lpn IN NUMBER)RETURN BOOLEAN;
FUNCTION Parent_Charge(p_parent_charge_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Returnable(p_returnable_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Tax_Group(p_tax_group_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Flow_Status(p_flow_status_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Line_Flow_Status(p_flow_status_code IN VARCHAR2)RETURN BOOLEAN;
-- added for bug 4240715
FUNCTION IB_OWNER(p_ib_owner IN VARCHAR2)RETURN BOOLEAN;
FUNCTION IB_INSTALLED_AT_LOCATION(p_ib_installed_at_location IN VARCHAR2)RETURN BOOLEAN;
FUNCTION IB_CURRENT_LOCATION(p_ib_current_location IN VARCHAR2)RETURN BOOLEAN;
FUNCTION END_CUSTOMER(p_end_customer_id IN NUMBER)RETURN BOOLEAN;
FUNCTION END_CUSTOMER_CONTACT(p_end_customer_contact_id IN NUMBER)RETURN BOOLEAN;
FUNCTION END_CUSTOMER_SITE_USE(p_end_customer_site_use_id IN NUMBER)RETURN BOOLEAN;
--  END GEN validate

FUNCTION Header_desc_flex (p_context IN VARCHAR2,
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
                           p_attribute20 IN VARCHAR2)
RETURN BOOLEAN;
FUNCTION G_Header_desc_flex (p_context IN VARCHAR2,
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
RETURN BOOLEAN;

FUNCTION TP_Header_desc_flex (p_context IN VARCHAR2,
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
RETURN BOOLEAN;

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
                           p_attribute20 IN VARCHAR2)

RETURN BOOLEAN;
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
RETURN BOOLEAN;
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
RETURN BOOLEAN ;
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
RETURN BOOLEAN;

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
RETURN BOOLEAN;

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

RETURN BOOLEAN;


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

RETURN BOOLEAN;
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

RETURN BOOLEAN;
FUNCTION Return_Reason(p_return_reason_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Split_From_Line(p_split_from_line_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Cust_Production_Seq_Num(p_cust_production_seq_num IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Authorized_To_Ship(p_authorized_to_ship_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Veh_Cus_Item_Cum_key(p_veh_cus_item_cum_key_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Arrival_Set(p_arrival_set_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Ship_Set(p_ship_set_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Over_Ship_Reason(p_over_ship_reason_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Over_Ship_Resolved(p_over_ship_resolved_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Payment_Type(p_payment_type_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Payment_Amount(p_payment_amount IN NUMBER)RETURN BOOLEAN;
FUNCTION Check_Number(p_check_number IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Credit_Card(p_credit_card_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Credit_Card_Holder_Name(p_credit_card_holder_name IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Credit_Card_Number(p_credit_card_number IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Credit_Card_Expiration_Date(p_credit_card_expiration_date IN DATE)RETURN BOOLEAN;
FUNCTION Credit_Card_Approval_Date(p_credit_card_approval_date IN DATE)RETURN BOOLEAN;
FUNCTION Credit_Card_Approval(p_credit_card_approval_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION Invoiced_Quantity(p_invoiced_quantity IN NUMBER)RETURN BOOLEAN;
FUNCTION Service_Txn_Reason(p_service_txn_reason IN VARCHAR2) RETURN BOOLEAN;
FUNCTION Service_Txn_Comments(p_service_txn_comments IN VARCHAR2) RETURN BOOLEAN;
FUNCTION Service_Duration(p_service_duration IN NUMBER) RETURN BOOLEAN;
FUNCTION Service_Period(p_service_period IN VARCHAR2) RETURN BOOLEAN;
FUNCTION Service_Start_Date(p_service_start_date IN DATE) RETURN BOOLEAN;
FUNCTION Service_End_Date(p_service_end_date IN DATE) RETURN BOOLEAN;
FUNCTION Service_Coterminate(p_service_coterminate_flag IN VARCHAR2) RETURN BOOLEAN;
FUNCTION Unit_List_Percent(p_unit_list_percent IN NUMBER) RETURN BOOLEAN;
FUNCTION Unit_Selling_Percent(p_unit_selling_percent IN NUMBER) RETURN BOOLEAN;
FUNCTION Unit_Percent_Base_Price(p_unit_percent_base_price IN NUMBER) RETURN BOOLEAN;
FUNCTION Service_Number(p_service_number IN NUMBER) RETURN BOOLEAN;
FUNCTION Service_Reference_Type(p_service_reference_type_code IN VARCHAR2) RETURN BOOLEAN;
FUNCTION Service_Reference_Line(p_service_reference_line_id IN NUMBER) RETURN BOOLEAN;
FUNCTION Service_Reference_System(p_service_reference_system_id IN NUMBER) RETURN BOOLEAN;
/* For new attributes in OE_PRICE_ADJUSTMENTS */
FUNCTION Split_action(p_split_action_code IN VARCHAR2) RETURN BOOLEAN;
FUNCTION Marketing_Source_Code(p_marketing_source_code_id IN NUMBER) RETURN BOOLEAN;
FUNCTION CHARGE_TYPE_CODE(p_charge_type_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION CHARGE_SUBTYPE_CODE(p_charge_subtype_code IN VARCHAR2)RETURN BOOLEAN;
FUNCTION COST_ID(p_cost_id IN NUMBER)RETURN BOOLEAN;
FUNCTION Commitment(p_commitment_id IN NUMBER) RETURN BOOLEAN;
FUNCTION CREDIT_OR_CHARGE_FLAG(p_credit_or_charge_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION INCLUDE_ON_RETURNS_FLAG(p_include_on_returns_flag IN VARCHAR2)RETURN BOOLEAN;
FUNCTION IS_AUDIT_REASON_RQD RETURN BOOLEAN;
FUNCTION IS_AUDIT_HISTORY_RQD RETURN BOOLEAN;
FUNCTION Sales_Channel(p_sales_channel_code IN VARCHAR2) RETURN BOOLEAN;
FUNCTION Customer_Location(p_sold_to_site_use_id IN NUMBER)RETURN BOOLEAN;
-- FUNCTION Sublot_Number(p_sublot_number IN VARCHAR2)RETURN BOOLEAN; -- INVCONV
FUNCTION Quantity2(p_quantity2 IN NUMBER)RETURN BOOLEAN; -- OPM 3322359



-- INVCONV for OPM inventory convergence
FUNCTION Fulfilled_Quantity2(p_fulfilled_quantity2 IN NUMBER)RETURN BOOLEAN;
FUNCTION Shipping_Quantity2(p_shipping_quantity2 IN NUMBER)RETURN BOOLEAN;
FUNCTION Shipped_Quantity2(p_shipped_quantity2 IN NUMBER)RETURN BOOLEAN;
FUNCTION Shipping_Quantity_Uom2(p_shipping_quantity_uom2 IN VARCHAR2)RETURN BOOLEAN;

END OE_CNCL_Validate;

 

/
