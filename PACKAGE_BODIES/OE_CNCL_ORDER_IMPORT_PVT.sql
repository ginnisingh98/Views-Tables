--------------------------------------------------------
--  DDL for Package Body OE_CNCL_ORDER_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CNCL_ORDER_IMPORT_PVT" AS
/* $Header: OEXVCIMB.pls 120.3.12010000.2 2009/06/19 14:26:32 ramising ship $ */

/* ---------------------------------------------------------------
--  Start of Comments
--  API name    OE_CNCL_ORDER_IMPORT_PVT
--  Type        Private
--  Function
--  Pre-reqs
--  Parameters
--  Version     Current version = 1.0
--              Initial version = 1.0
--  Notes
--
--  End of Comments
------------------------------------------------------------------
*/


--G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_CNCL_Order_Import';



/* -----------------------------------------------------------
   Procedure: Import_Order
   -----------------------------------------------------------
*/
PROCEDURE IMPORT_ORDER(
   p_request_id			IN  NUMBER   DEFAULT FND_API.G_MISS_NUM
  ,p_order_source_id		IN  NUMBER
  ,p_orig_sys_document_ref      IN  VARCHAR2
  ,p_sold_to_org_id             IN  NUMBER
  ,p_sold_to_org                IN  VARCHAR2
  ,p_change_sequence      	IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
  ,p_validate_only		IN  VARCHAR2 DEFAULT FND_API.G_FALSE
  ,p_init_msg_list		IN  VARCHAR2 DEFAULT FND_API.G_TRUE
  ,p_org_id                     IN  NUMBER
,p_msg_count OUT NOCOPY NUMBER

,p_msg_data OUT NOCOPY VARCHAR2

,p_return_status OUT NOCOPY VARCHAR2


) IS

  l_control_rec                 OE_Globals.Control_Rec_Type;

  l_header_adj_rec  		OE_Order_Pub.Header_Adj_Rec_Type;
  l_header_scredit_rec      	OE_Order_Pub.Header_Scredit_Rec_Type;
  l_line_rec                    OE_Order_Pub.Line_Rec_Type;
  l_line_adj_rec                OE_Order_Pub.Line_Adj_Rec_Type;
  l_line_scredit_rec            OE_Order_Pub.Line_Scredit_Rec_Type;
  l_lot_serial_rec         	OE_Order_Pub.Lot_Serial_Rec_Type;
  l_reservation_rec         	OE_Order_Pub.Reservation_Rec_Type;
  l_action_request_rec          OE_Order_Pub.Request_Rec_Type;

  l_header_rec                  OE_Order_Pub.Header_Rec_Type;
  l_header_adj_tbl  		OE_Order_Pub.Header_Adj_Tbl_Type;
  l_header_price_att_tbl  	OE_Order_Pub.Header_Price_Att_Tbl_Type;
  l_header_adj_att_tbl  	OE_Order_Pub.Header_Adj_Att_Tbl_Type;
  l_header_adj_assoc_tbl  	OE_Order_Pub.Header_Adj_Assoc_Tbl_Type;
  l_header_scredit_tbl      	OE_Order_Pub.Header_Scredit_Tbl_Type;
  l_line_tbl                    OE_Order_Pub.Line_Tbl_Type;
  l_line_adj_tbl                OE_Order_Pub.Line_Adj_Tbl_Type;
  l_line_price_att_tbl  	OE_Order_Pub.Line_Price_Att_Tbl_Type;
  l_line_adj_att_tbl  		OE_Order_Pub.Line_Adj_Att_Tbl_Type;
  l_line_adj_assoc_tbl  	OE_Order_Pub.Line_Adj_Assoc_Tbl_Type;
  l_line_scredit_tbl            OE_Order_Pub.Line_Scredit_Tbl_Type;
  l_lot_serial_tbl         	OE_Order_Pub.Lot_Serial_Tbl_Type;
  l_reservation_tbl         	OE_Order_Pub.Reservation_Tbl_Type;
  l_action_request_tbl	        OE_Order_Pub.Request_Tbl_Type;

  l_header_rec_old              OE_Order_Pub.Header_Rec_Type;
  l_header_adj_tbl_old  	OE_Order_Pub.Header_Adj_Tbl_Type;
  l_header_price_att_tbl_old  	OE_Order_Pub.Header_Price_Att_Tbl_Type;
  l_header_adj_att_tbl_old  	OE_Order_Pub.Header_Adj_Att_Tbl_Type;
  l_header_adj_assoc_tbl_old  	OE_Order_Pub.Header_Adj_Assoc_Tbl_Type;
  l_header_scredit_tbl_old      OE_Order_Pub.Header_Scredit_Tbl_Type;
  l_line_tbl_old                OE_Order_Pub.Line_Tbl_Type;
  l_line_adj_tbl_old            OE_Order_Pub.Line_Adj_Tbl_Type;
  l_line_price_att_tbl_old  	OE_Order_Pub.Line_Price_Att_Tbl_Type;
  l_line_adj_att_tbl_old 	OE_Order_Pub.Line_Adj_Att_Tbl_Type;
  l_line_adj_assoc_tbl_old  	OE_Order_Pub.Line_Adj_Assoc_Tbl_Type;
  l_line_scredit_tbl_old        OE_Order_Pub.Line_Scredit_Tbl_Type;
  l_lot_serial_tbl_old     	OE_Order_Pub.Lot_Serial_Tbl_Type;
  l_action_request_tbl_old      OE_Order_Pub.Request_Tbl_Type;

  l_header_rec_new              OE_Order_Pub.Header_Rec_Type;
  l_header_adj_tbl_new  	OE_Order_Pub.Header_Adj_Tbl_Type;
  l_header_price_att_tbl_new  	OE_Order_Pub.Header_Price_Att_Tbl_Type;
  l_header_adj_att_tbl_new  	OE_Order_Pub.Header_Adj_Att_Tbl_Type;
  l_header_adj_assoc_tbl_new  	OE_Order_Pub.Header_Adj_Assoc_Tbl_Type;
  l_header_scredit_tbl_new      OE_Order_Pub.Header_Scredit_Tbl_Type;
  l_line_tbl_new                OE_Order_Pub.Line_Tbl_Type;
  l_line_adj_tbl_new            OE_Order_Pub.Line_Adj_Tbl_Type;
  l_line_price_att_tbl_new  	OE_Order_Pub.Line_Price_Att_Tbl_Type;
  l_line_adj_att_tbl_new 	OE_Order_Pub.Line_Adj_Att_Tbl_Type;
  l_line_adj_assoc_tbl_new  	OE_Order_Pub.Line_Adj_Assoc_Tbl_Type;
  l_line_scredit_tbl_new        OE_Order_Pub.Line_Scredit_Tbl_Type;
  l_lot_serial_tbl_new     	OE_Order_Pub.Lot_Serial_Tbl_Type;
  l_action_request_tbl_new      OE_Order_Pub.Request_Tbl_Type;

  l_header_adj_val_rec  	OE_Order_Pub.Header_Adj_Val_Rec_Type;
  l_header_scredit_val_rec      OE_Order_Pub.Header_Scredit_Val_Rec_Type;
  l_line_val_rec              	OE_Order_Pub.Line_Val_Rec_Type;
  l_line_adj_val_rec  		OE_Order_Pub.Line_Adj_Val_Rec_Type;
  l_line_scredit_val_rec      	OE_Order_Pub.Line_Scredit_Val_Rec_Type;
  l_lot_serial_val_rec         	OE_Order_Pub.Lot_Serial_Val_Rec_Type;
  l_reservation_val_rec         OE_Order_Pub.Reservation_Val_Rec_Type;

  l_header_val_rec              OE_Order_Pub.Header_Val_Rec_Type;
  l_header_adj_val_tbl  	OE_Order_Pub.Header_Adj_Val_Tbl_Type;
  l_header_scredit_val_tbl      OE_Order_Pub.Header_Scredit_Val_Tbl_Type;
  l_line_val_tbl              	OE_Order_Pub.Line_Val_Tbl_Type;
  l_line_adj_val_tbl  		OE_Order_Pub.Line_Adj_Val_Tbl_Type;
  l_line_scredit_val_tbl      	OE_Order_Pub.Line_Scredit_Val_Tbl_Type;
  l_lot_serial_val_tbl         	OE_Order_Pub.Lot_Serial_Val_Tbl_Type;
  l_reservation_val_tbl         OE_Order_Pub.Reservation_Val_Tbl_Type;

  l_header_val_rec_old          OE_Order_Pub.Header_Val_Rec_Type;
  l_header_adj_val_tbl_old  	OE_Order_Pub.Header_Adj_Val_Tbl_Type;
  l_header_scredit_val_tbl_old  OE_Order_Pub.Header_Scredit_Val_Tbl_Type;
  l_line_val_tbl_old          	OE_Order_Pub.Line_Val_Tbl_Type;
  l_line_adj_val_tbl_old  	OE_Order_Pub.Line_Adj_Val_Tbl_Type;
  l_line_scredit_val_tbl_old  	OE_Order_Pub.Line_Scredit_Val_Tbl_Type;
  l_lot_serial_val_tbl_old     	OE_Order_Pub.Lot_Serial_Val_Tbl_Type;

  l_header_val_rec_new          OE_Order_Pub.Header_Val_Rec_Type;
  l_header_adj_val_tbl_new  	OE_Order_Pub.Header_Adj_Val_Tbl_Type;
  l_header_scredit_val_tbl_new  OE_Order_Pub.Header_Scredit_Val_Tbl_Type;
  l_line_val_tbl_new          	OE_Order_Pub.Line_Val_Tbl_Type;
  l_line_adj_val_tbl_new  	OE_Order_Pub.Line_Adj_Val_Tbl_Type;
  l_line_scredit_val_tbl_new  	OE_Order_Pub.Line_Scredit_Val_Tbl_Type;
  l_lot_serial_val_tbl_new     	OE_Order_Pub.Lot_Serial_Val_Tbl_Type;

  l_action_rec          	OE_Order_Import_Pvt.Action_Rec_Type;

  l_request_id			NUMBER 		:= p_request_id;
  l_order_source_id		NUMBER 		:= p_order_source_id;
  l_orig_sys_document_ref	VARCHAR2(50) 	:= p_orig_sys_document_ref;
  l_sold_to_org_id              NUMBER          := p_sold_to_org_id;
  l_sold_to_org                 VARCHAR2(360)   := p_sold_to_org;
  l_change_sequence		VARCHAR2(50)	:= p_change_sequence;
  l_org_id                      NUMBER          := p_org_id;
  l_orig_sys_line_ref		VARCHAR2(50);
  l_orig_sys_shipment_ref	VARCHAR2(50);

  l_order_type_id		NUMBER;
  l_order_number		NUMBER;
  l_line_number			NUMBER;
  l_shipment_number		NUMBER;
  l_header_id			NUMBER;
  l_line_id			NUMBER;

  l_validate_only		VARCHAR2(1);
  l_init_msg_list		VARCHAR2(1)	:= p_init_msg_list;
  l_validation_level 		NUMBER		:= FND_API.G_VALID_LEVEL_FULL;
  l_return_values 		VARCHAR2(1)     := FND_API.G_FALSE;
  l_commit 			VARCHAR2(1)     := FND_API.G_FALSE;
  l_api_service_level 		VARCHAR2(30)    := OE_GLOBALS.G_ALL_SERVICE;

  l_return_status              	VARCHAR2(1) 	:= FND_API.G_RET_STS_SUCCESS;
  l_return_status_oi_pre        VARCHAR2(1) 	:= FND_API.G_RET_STS_SUCCESS;
  l_return_status_oi_pst        VARCHAR2(1) 	:= FND_API.G_RET_STS_SUCCESS;
  l_return_status_po          	VARCHAR2(1) 	:= FND_API.G_RET_STS_SUCCESS;
  l_return_status_del_ord       VARCHAR2(1) 	:= FND_API.G_RET_STS_SUCCESS;
  l_return_status_del_msg       VARCHAR2(1) 	:= FND_API.G_RET_STS_SUCCESS;
  l_return_status_sav_msg       VARCHAR2(1) 	:= FND_API.G_RET_STS_SUCCESS;
  l_return_status_upd_err       VARCHAR2(1) 	:= FND_API.G_RET_STS_SUCCESS;
  l_return_status_book          VARCHAR2(1) 	:= FND_API.G_RET_STS_SUCCESS;
  l_error_index_flag            VARCHAR2(1)  := 'N';
  l_validation_org  NUMBER := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');

  l_header_count		NUMBER 		:= 0;
  l_header_adj_count		NUMBER 		:= 0;
  l_header_scredit_count	NUMBER 		:= 0;
  l_line_count		        NUMBER 		:= 0;
  l_line_adj_count		NUMBER 		:= 0;
  l_line_scredit_count		NUMBER 		:= 0;
  l_lot_serial_count		NUMBER 		:= 0;
  l_reservation_count		NUMBER 		:= 0;
  l_action_request_count        NUMBER 		:= 0;

  l_msg_index              	NUMBER := 0;
  l_msg_context              	VARCHAR2(2000);
  l_msg_data              	VARCHAR2(2000);

  l_msg_entity_code             VARCHAR2(30);
  l_msg_entity_ref		VARCHAR2(50);
  l_msg_entity_id               NUMBER;
  l_msg_header_id               NUMBER;
  l_msg_line_id                 NUMBER;
  l_msg_order_source_id         NUMBER;
  l_msg_orig_sys_document_ref   VARCHAR2(50);
  l_msg_sold_to_org_id          NUMBER;
  l_msg_sold_to_org                VARCHAR2(360);
  l_msg_change_sequence   	VARCHAR2(50);
  l_msg_orig_sys_line_ref  	VARCHAR2(50);
  l_msg_orig_sys_shipment_ref  	VARCHAR2(50);
  l_msg_source_document_type_id NUMBER;
  l_msg_source_document_id      NUMBER;
  l_msg_source_document_line_id NUMBER;
  l_msg_attribute_code          VARCHAR2(50);
  l_msg_constraint_id           NUMBER;
  l_msg_process_activity        NUMBER;
  l_msg_notification_flag       VARCHAR2(1);
  l_msg_type                 	VARCHAR2(30);

  l_commit_flag              	VARCHAR2(1) := 'Y';
  l_delete_flag              	VARCHAR2(1) := 'Y';

  l_api_name                    CONSTANT VARCHAR2(30) := 'Import_Order';

  l_structure  fnd_flex_key_api.structure_type;
  l_flexfield  fnd_flex_key_api.flexfield_type;
  l_segment_array  fnd_flex_ext.segmentarray;
  l_n_segments  NUMBER;
  l_segments  FND_FLEX_KEY_API.SEGMENT_LIST;
  l_id  NUMBER;
  failure_message      varchar2(2000);

  TYPE t_adj_line_ref_type IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
  TYPE t_scredit_line_ref_type IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
  l_adj_line_ref_tbl     t_adj_line_ref_type;
  l_scredit_line_ref_tbl t_scredit_line_ref_type;
  l_adj_line_ref         VARCHAR2(50);
  l_scredit_line_ref     VARCHAR2(50);

/* -----------------------------------------------------------
   Headers cursor
   -----------------------------------------------------------
*/
    CURSOR l_header_cursor IS
    SELECT order_source_id
    	 , orig_sys_document_ref
    	 , change_sequence
	 , nvl(change_request_code,		FND_API.G_MISS_CHAR)
	 , nvl(order_source,			FND_API.G_MISS_CHAR)
	 , nvl(org_id,				FND_API.G_MISS_NUM)
	 , nvl(header_id,			FND_API.G_MISS_NUM)
	 , nvl(order_number,			FND_API.G_MISS_NUM)
	 , nvl(version_number,			FND_API.G_MISS_NUM)
	 , nvl(ordered_date,			FND_API.G_MISS_DATE)
	 , nvl(order_type_id,			FND_API.G_MISS_NUM)
	 , nvl(order_type,			FND_API.G_MISS_CHAR)
	 , nvl(price_list_id,			FND_API.G_MISS_NUM)
	 , nvl(price_list,			FND_API.G_MISS_CHAR)
	 , nvl(conversion_rate,			FND_API.G_MISS_NUM)
	 , nvl(conversion_rate_date,		FND_API.G_MISS_DATE)
	 , nvl(conversion_type_code,		FND_API.G_MISS_CHAR)
	 , nvl(conversion_type,			FND_API.G_MISS_CHAR)
	 , nvl(transactional_curr_code,		FND_API.G_MISS_CHAR)
	 , nvl(return_reason_code,		FND_API.G_MISS_CHAR)
	 , nvl(salesrep_id,			FND_API.G_MISS_NUM)
	 , nvl(salesrep,			FND_API.G_MISS_CHAR)
	 , nvl(sales_channel_code,		FND_API.G_MISS_CHAR)
	 , nvl(sales_channel,     		FND_API.G_MISS_CHAR)
	 , nvl(tax_point_code,			FND_API.G_MISS_CHAR)
	 , nvl(tax_point,			FND_API.G_MISS_CHAR)
	 , nvl(tax_exempt_flag,			FND_API.G_MISS_CHAR)
	 , nvl(tax_exempt_number,		FND_API.G_MISS_CHAR)
	 , nvl(tax_exempt_reason_code,		FND_API.G_MISS_CHAR)
	 , nvl(tax_exempt_reason,		FND_API.G_MISS_CHAR)
	 , nvl(agreement_id,			FND_API.G_MISS_NUM)
	 , nvl(agreement,			FND_API.G_MISS_CHAR)
	 , nvl(invoicing_rule_id,		FND_API.G_MISS_NUM)
	 , nvl(invoicing_rule,			FND_API.G_MISS_CHAR)
	 , nvl(accounting_rule_id,		FND_API.G_MISS_NUM)
	 , nvl(accounting_rule,			FND_API.G_MISS_CHAR)
	 , nvl(payment_term_id,			FND_API.G_MISS_NUM)
	 , nvl(payment_term,			FND_API.G_MISS_CHAR)
	 , nvl(demand_class_code,		FND_API.G_MISS_CHAR)
	 , nvl(shipment_priority_code,		FND_API.G_MISS_CHAR)
	 , nvl(shipment_priority,		FND_API.G_MISS_CHAR)
	 , nvl(shipping_method_code,		FND_API.G_MISS_CHAR)
	 , nvl(freight_carrier_code,		FND_API.G_MISS_CHAR)
	 , nvl(freight_terms_code,		FND_API.G_MISS_CHAR)
	 , nvl(freight_terms,			FND_API.G_MISS_CHAR)
	 , nvl(fob_point_code,			FND_API.G_MISS_CHAR)
	 , nvl(fob_point,			FND_API.G_MISS_CHAR)
	 , nvl(partial_shipments_allowed,	FND_API.G_MISS_CHAR)
	 , nvl(ship_tolerance_above,		FND_API.G_MISS_NUM)
	 , nvl(ship_tolerance_below,		FND_API.G_MISS_NUM)
	 , nvl(shipping_instructions,		FND_API.G_MISS_CHAR)
	 , nvl(packing_instructions,		FND_API.G_MISS_CHAR)
	 , nvl(order_date_type_code,		FND_API.G_MISS_CHAR)
	 , nvl(earliest_schedule_limit,		FND_API.G_MISS_NUM)
	 , nvl(latest_schedule_limit,		FND_API.G_MISS_NUM)
	 , nvl(customer_po_number,		FND_API.G_MISS_CHAR)
	 , nvl(customer_payment_term_id,	FND_API.G_MISS_NUM)
	 , nvl(customer_payment_term,		FND_API.G_MISS_CHAR)
	 , nvl(payment_type_code,		FND_API.G_MISS_CHAR)
	 , nvl(payment_amount,			FND_API.G_MISS_NUM)
	 , nvl(check_number,			FND_API.G_MISS_CHAR)
	 , nvl(credit_card_code,		FND_API.G_MISS_CHAR)
	 , nvl(credit_card_holder_name,		FND_API.G_MISS_CHAR)
	 , nvl(credit_card_number,		FND_API.G_MISS_CHAR)
	 , nvl(credit_card_expiration_date,	FND_API.G_MISS_DATE)
	 , nvl(credit_card_approval_code,	FND_API.G_MISS_CHAR)
	 , nvl(credit_card_approval_date,	FND_API.G_MISS_DATE)
	 , nvl(sold_from_org_id,		FND_API.G_MISS_NUM)
	 , nvl(sold_from_org,			FND_API.G_MISS_CHAR)
	 , nvl(sold_to_org_id,			FND_API.G_MISS_NUM)
	 , nvl(sold_to_org,			FND_API.G_MISS_CHAR)
	 , nvl(customer_number,       		FND_API.G_MISS_CHAR)
	 , nvl(ship_from_org_id,		FND_API.G_MISS_NUM)
	 , nvl(ship_from_org,			FND_API.G_MISS_CHAR)
	 , nvl(ship_to_org_id,			FND_API.G_MISS_NUM)
	 , nvl(ship_to_org,			FND_API.G_MISS_CHAR)
	 , nvl(invoice_to_org_id,		FND_API.G_MISS_NUM)
	 , nvl(invoice_to_org,			FND_API.G_MISS_CHAR)
	 , nvl(deliver_to_org_id,		FND_API.G_MISS_NUM)
	 , nvl(deliver_to_org,			FND_API.G_MISS_CHAR)
	 , nvl(sold_to_contact_id,		FND_API.G_MISS_NUM)
	 , nvl(sold_to_contact,			FND_API.G_MISS_CHAR)
	 , nvl(ship_to_contact_id,		FND_API.G_MISS_NUM)
	 , nvl(ship_to_contact,			FND_API.G_MISS_CHAR)
	 , nvl(invoice_to_contact_id,		FND_API.G_MISS_NUM)
	 , nvl(invoice_to_contact,		FND_API.G_MISS_CHAR)
	 , nvl(deliver_to_contact_id,		FND_API.G_MISS_NUM)
	 , nvl(deliver_to_contact,		FND_API.G_MISS_CHAR)
	 , nvl(ship_to_address1,		FND_API.G_MISS_CHAR)
	 , nvl(ship_to_address2,		FND_API.G_MISS_CHAR)
	 , nvl(ship_to_address3,		FND_API.G_MISS_CHAR)
	 , nvl(ship_to_address4,		FND_API.G_MISS_CHAR)
	 , nvl(ship_to_city,		        FND_API.G_MISS_CHAR)
	 , nvl(ship_to_state,		        FND_API.G_MISS_CHAR)
	 , nvl(ship_to_postal_code,	        FND_API.G_MISS_CHAR)
	 , nvl(ship_to_country,	                FND_API.G_MISS_CHAR)
	 , nvl(invoice_address1,		FND_API.G_MISS_CHAR)
	 , nvl(invoice_address2,		FND_API.G_MISS_CHAR)
	 , nvl(invoice_address3,		FND_API.G_MISS_CHAR)
	 , nvl(invoice_address4,		FND_API.G_MISS_CHAR)
	 , nvl(invoice_city,		        FND_API.G_MISS_CHAR)
	 , nvl(invoice_state,		        FND_API.G_MISS_CHAR)
	 , nvl(invoice_postal_code,	        FND_API.G_MISS_CHAR)
	 , nvl(invoice_country,	                FND_API.G_MISS_CHAR)
	 , nvl(drop_ship_flag,			FND_API.G_MISS_CHAR)
	 , nvl(booked_flag,			'Y')
--	 , nvl(closed_flag,			FND_API.G_MISS_CHAR)
	 , nvl(cancelled_flag,			'N')
	 , nvl(context,				FND_API.G_MISS_CHAR)
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
/* Added Attribute 16 to 20 for bug 3471009 */
         , nvl(attribute16,                     FND_API.G_MISS_CHAR)
         , nvl(attribute17,                     FND_API.G_MISS_CHAR)
         , nvl(attribute18,                     FND_API.G_MISS_CHAR)
         , nvl(attribute19,                     FND_API.G_MISS_CHAR)
         , nvl(attribute20,                     FND_API.G_MISS_CHAR)
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
      , request_id
	 , NVL(request_date,               FND_API.G_MISS_DATE)
	 , nvl(operation_code,			OE_GLOBALS.G_OPR_CREATE)
	 , nvl(ready_flag,			'Y')
	 , nvl(status_flag,			'0')
	 , nvl(force_apply_flag,		'N')
	 , nvl(change_reason,			FND_API.G_MISS_CHAR)
	 , nvl(change_comments,			FND_API.G_MISS_CHAR)
         , 'N'
         , nvl(customer_preference_set_code,    FND_API.G_MISS_CHAR)
	 , nvl(sold_to_site_use_id,             FND_API.G_MISS_NUM)
	 , nvl(sold_to_location_address1, FND_API.G_MISS_CHAR)
	 , nvl(sold_to_location_address2, FND_API.G_MISS_CHAR)
	 , nvl(sold_to_location_address3, FND_API.G_MISS_CHAR)
	 , nvl(sold_to_location_address4, FND_API.G_MISS_CHAR)
	 , nvl(sold_to_location_city, FND_API.G_MISS_CHAR)
	 , nvl(sold_to_location_postal_code, FND_API.G_MISS_CHAR)
	 , nvl(sold_to_location_country, FND_API.G_MISS_CHAR)
	 , nvl(sold_to_location_state, FND_API.G_MISS_CHAR)
	 , nvl(sold_to_location_county, FND_API.G_MISS_CHAR)
	 , nvl(sold_to_location_province, FND_API.G_MISS_CHAR)
     -- start if additional quoting columns
         , nvl(transaction_phase_code, FND_API.G_MISS_CHAR)
         , nvl(expiration_date, FND_API.G_MISS_DATE)
         , nvl(quote_number, FND_API.G_MISS_NUM)
         , nvl(quote_date, FND_API.G_MISS_DATE)
         , nvl(sales_document_name, FND_API.G_MISS_CHAR)
         , nvl(user_status_code, FND_API.G_MISS_CHAR)
     -- end of additional quoting columns
     -- { Distributer Order related change
         , nvl(end_customer_id,                 FND_API.G_MISS_NUM)
         , nvl(end_customer_contact_id,         FND_API.G_MISS_NUM)
         , nvl(end_customer_site_use_id,        FND_API.G_MISS_NUM)
     --{added for bug 4240715
         , nvl(end_customer_name,		FND_API.G_MISS_CHAR)
	 , nvl(end_customer_address1,		FND_API.G_MISS_CHAR)
	 , nvl(end_customer_address2,		FND_API.G_MISS_CHAR)
	 , nvl(end_customer_address3,		FND_API.G_MISS_CHAR)
	 , nvl(end_customer_address4,		FND_API.G_MISS_CHAR)
	 -- , nvl(end_customer_location,		FND_API.G_MISS_CHAR)
	 , nvl(end_customer_city,		        FND_API.G_MISS_CHAR)
	 , nvl(end_customer_state,		        FND_API.G_MISS_CHAR)
	 , nvl(end_customer_postal_code,	        FND_API.G_MISS_CHAR)
	 , nvl(end_customer_country,	                FND_API.G_MISS_CHAR)
	 , nvl(end_customer_contact,			FND_API.G_MISS_CHAR)
         , nvl(end_customer_number,		FND_API.G_MISS_CHAR)
     -- bug 4240715}
	 , nvl(ib_owner_code,                   FND_API.G_MISS_CHAR)
         , nvl(ib_current_location_code,        FND_API.G_MISS_CHAR)
         , nvl(ib_installed_at_location_code,   FND_API.G_MISS_CHAR)
         , nvl(ib_owner,                        FND_API.G_MISS_CHAR)
         , nvl(ib_current_location,             FND_API.G_MISS_CHAR)
         , nvl(ib_installed_at_location,        FND_API.G_MISS_CHAR)
     -- Distributer Order related change }
      FROM oe_headers_iface_all
     WHERE order_source_id 			= l_order_source_id
       AND orig_sys_document_ref 		= l_orig_sys_document_ref
       AND nvl(sold_to_org_id,                  FND_API.G_MISS_NUM)
         = nvl(l_sold_to_org_id,                FND_API.G_MISS_NUM)
       AND nvl(sold_to_org,                  FND_API.G_MISS_CHAR)
         = nvl(l_sold_to_org,                FND_API.G_MISS_CHAR)
       AND nvl(  change_sequence,		FND_API.G_MISS_CHAR)
	 = nvl(l_change_sequence,		FND_API.G_MISS_CHAR)
       AND nvl(org_id,                          FND_API.G_MISS_NUM)
         = nvl(l_org_id,                        FND_API.G_MISS_NUM)
       AND nvl(  request_id,			FND_API.G_MISS_NUM)
	 = nvl(l_request_id,			FND_API.G_MISS_NUM)
       AND nvl(error_flag,'N')			= 'N'
       AND nvl(ready_flag,'Y')			= 'Y'
       AND nvl(rejected_flag,'N')		= 'N'
       AND nvl(force_apply_flag,'Y')		= 'Y'
       AND closed_flag = 'Y'
  FOR UPDATE NOWAIT
  ORDER BY org_id,order_source_id, orig_sys_document_ref, change_sequence
;


/* -----------------------------------------------------------
   Header Discounts/Price adjustments cursor
   -----------------------------------------------------------
*/
    CURSOR l_header_adj_cursor IS
    SELECT nvl(orig_sys_discount_ref,	FND_API.G_MISS_CHAR)
	 , nvl(change_request_code,	FND_API.G_MISS_CHAR)
	 , nvl(list_header_id,        FND_API.G_MISS_NUM)
	 , nvl(list_line_id,          FND_API.G_MISS_NUM)
	 , nvl(discount_name,		FND_API.G_MISS_CHAR)
	 , nvl(percent,			FND_API.G_MISS_NUM)
	 , nvl(automatic_flag,		FND_API.G_MISS_CHAR)
	 , nvl(applied_flag,		FND_API.G_MISS_CHAR)
	 , nvl(operand,			FND_API.G_MISS_NUM)
	 , nvl(arithmetic_operator,	FND_API.G_MISS_CHAR)
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
         , request_id
	 , nvl(operation_code,		OE_GLOBALS.G_OPR_CREATE)
	 , nvl(status_flag,		FND_API.G_MISS_CHAR)
-- Price Adjustment related changes bug# 1220921 (Start)
      , nvl( AC_CONTEXT,                 FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE1,              FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE2,              FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE3,              FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE4,              FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE5,              FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE6,              FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE7,              FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE8,              FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE9,              FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE10,             FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE11,             FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE12,             FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE13,             FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE14,             FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE15,             FND_API.G_MISS_CHAR)
      , nvl( LIST_NAME,                  FND_API.G_MISS_CHAR)
      , nvl( LIST_LINE_TYPE_CODE,        FND_API.G_MISS_CHAR)
      , nvl( LIST_LINE_NUMBER,           FND_API.G_MISS_CHAR)
      , nvl( VERSION_NUMBER,             FND_API.G_MISS_CHAR)
      , nvl( INVOICED_FLAG,              FND_API.G_MISS_CHAR)
      , nvl( ESTIMATED_FLAG,             FND_API.G_MISS_CHAR)
      , nvl( INC_IN_SALES_PERFORMANCE,   FND_API.G_MISS_CHAR)
      , nvl( CHARGE_TYPE_CODE,           FND_API.G_MISS_CHAR)
      , nvl( CHARGE_SUBTYPE_CODE,        FND_API.G_MISS_CHAR)
      , nvl( CREDIT_OR_CHARGE_FLAG,      FND_API.G_MISS_CHAR)
      , nvl( INCLUDE_ON_RETURNS_FLAG,    FND_API.G_MISS_CHAR)
      , nvl( COST_ID,                    FND_API.G_MISS_NUM)
      , nvl( TAX_CODE,                   FND_API.G_MISS_CHAR)
      , nvl( PARENT_ADJUSTMENT_ID,       FND_API.G_MISS_NUM)
      , nvl(MODIFIER_MECHANISM_TYPE_CODE,FND_API.G_MISS_CHAR)
      , nvl( MODIFIED_FROM,              FND_API.G_MISS_CHAR)
      , nvl( MODIFIED_TO,                FND_API.G_MISS_CHAR)
      , nvl( UPDATED_FLAG,               FND_API.G_MISS_CHAR)
      , nvl( UPDATE_ALLOWED,             FND_API.G_MISS_CHAR)
      , nvl( CHANGE_REASON_CODE,         FND_API.G_MISS_CHAR)
      , nvl( CHANGE_REASON_TEXT,         FND_API.G_MISS_CHAR)
      , nvl( PRICING_PHASE_ID,           FND_API.G_MISS_NUM)
      , nvl( ADJUSTED_AMOUNT,            FND_API.G_MISS_NUM)
-- Price Adjustment related changes bug# 1220921 (End)
      FROM oe_price_adjs_iface_all
     WHERE order_source_id		= l_order_source_id
       AND orig_sys_document_ref 	= l_orig_sys_document_ref
       AND nvl(sold_to_org_id,                  FND_API.G_MISS_NUM)
         = nvl(l_sold_to_org_id,                FND_API.G_MISS_NUM)
       AND nvl(sold_to_org,                  FND_API.G_MISS_CHAR)
         = nvl(l_sold_to_org,                FND_API.G_MISS_CHAR)
       AND nvl(  change_sequence,	FND_API.G_MISS_CHAR)
	 = nvl(l_change_sequence,	FND_API.G_MISS_CHAR)
       AND nvl(org_id,                          FND_API.G_MISS_NUM)
         = nvl(l_org_id,                        FND_API.G_MISS_NUM)
       AND nvl(orig_sys_line_ref,	FND_API.G_MISS_CHAR)
	 = 				FND_API.G_MISS_CHAR
       AND nvl(orig_sys_shipment_ref,	FND_API.G_MISS_CHAR)
	 = 				FND_API.G_MISS_CHAR
       AND nvl(  request_id,		FND_API.G_MISS_NUM)
	 = nvl(l_request_id,		FND_API.G_MISS_NUM)
  FOR UPDATE NOWAIT
  ORDER BY orig_sys_discount_ref
;


/* -----------------------------------------------------------
   Header Sales Credits cursor
   -----------------------------------------------------------
*/
    CURSOR l_header_scredit_cursor IS
    SELECT nvl(orig_sys_credit_ref,	FND_API.G_MISS_CHAR)
	 , nvl(change_request_code,	FND_API.G_MISS_CHAR)
	 , nvl(salesrep_id,		FND_API.G_MISS_NUM)
	 , nvl(salesrep	,		FND_API.G_MISS_CHAR)
	 , nvl(sales_credit_type_id,	FND_API.G_MISS_NUM)
	 , nvl(sales_credit_type,	FND_API.G_MISS_CHAR)
	 , nvl(percent,			FND_API.G_MISS_NUM)
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
	 , nvl(status_flag,		FND_API.G_MISS_CHAR)
      FROM oe_credits_iface_all
     WHERE order_source_id 		= l_order_source_id
       AND orig_sys_document_ref 	= l_orig_sys_document_ref
       AND nvl(sold_to_org_id,                  FND_API.G_MISS_NUM)
         = nvl(l_sold_to_org_id,                FND_API.G_MISS_NUM)
       AND nvl(sold_to_org,                  FND_API.G_MISS_CHAR)
         = nvl(l_sold_to_org,                FND_API.G_MISS_CHAR)
       AND nvl(  change_sequence,	FND_API.G_MISS_CHAR)
	 = nvl(l_change_sequence,	FND_API.G_MISS_CHAR)
       AND nvl(org_id,                          FND_API.G_MISS_NUM)
         = nvl(l_org_id,                        FND_API.G_MISS_NUM)
       AND nvl(orig_sys_line_ref,	FND_API.G_MISS_CHAR)
	 = 				FND_API.G_MISS_CHAR
       AND nvl(orig_sys_shipment_ref,	FND_API.G_MISS_CHAR)
	 = 				FND_API.G_MISS_CHAR
       AND nvl(  request_id,		FND_API.G_MISS_NUM)
	 = nvl(l_request_id,		FND_API.G_MISS_NUM)
  FOR UPDATE NOWAIT
  ORDER BY orig_sys_credit_ref
;


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
	 , nvl(line_type,			FND_API.G_MISS_CHAR)
	 , nvl(item_type_code,			FND_API.G_MISS_CHAR)
	 , nvl(inventory_item_id,		FND_API.G_MISS_NUM)
	 , nvl(inventory_item,			FND_API.G_MISS_CHAR)
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
	 , nvl(schedule_arrival_date,		FND_API.G_MISS_DATE)
	 , nvl(actual_arrival_date,		FND_API.G_MISS_DATE)
-- bug 3220711 - start
	 , nvl(actual_shipment_date,		FND_API.G_MISS_DATE)
-- bug 3220711 - end
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
/* OPM variables */ -- INVCONV
         , nvl(ordered_quantity2,               FND_API.G_MISS_NUM)
         , nvl(ordered_quantity_uom2 ,          FND_API.G_MISS_CHAR)
         , nvl(shipping_quantity2,              FND_API.G_MISS_NUM)
         , nvl(shipping_quantity_uom2,          FND_API.G_MISS_CHAR)
         , nvl(shipped_quantity2,               FND_API.G_MISS_NUM)
         , nvl(cancelled_quantity2,             FND_API.G_MISS_NUM)
         , nvl(fulfilled_quantity2,             FND_API.G_MISS_NUM)
         , nvl(preferred_grade,                 FND_API.G_MISS_CHAR)
	 , nvl(pricing_quantity,		FND_API.G_MISS_NUM)
	 , nvl(pricing_quantity_uom,		FND_API.G_MISS_CHAR)
	 , nvl(sold_from_org_id,		FND_API.G_MISS_NUM)
	 , nvl(sold_from_org,			FND_API.G_MISS_CHAR)
	 , nvl(sold_to_org_id ,			FND_API.G_MISS_NUM)
	 , nvl(sold_to_org,			FND_API.G_MISS_CHAR)
	 , nvl(ship_from_org_id,		FND_API.G_MISS_NUM)
	 , nvl(ship_from_org,			FND_API.G_MISS_CHAR)
	 , nvl(ship_to_org_id ,			FND_API.G_MISS_NUM)
	 , nvl(ship_to_org,			FND_API.G_MISS_CHAR)
	 , nvl(deliver_to_org_id,		FND_API.G_MISS_NUM)
	 , nvl(deliver_to_org,			FND_API.G_MISS_CHAR)
	 , nvl(invoice_to_org_id,		FND_API.G_MISS_NUM)
	 , nvl(invoice_to_org,			FND_API.G_MISS_CHAR)
	 , nvl(ship_to_address1,		FND_API.G_MISS_CHAR)
	 , nvl(ship_to_address2,		FND_API.G_MISS_CHAR)
	 , nvl(ship_to_address3,		FND_API.G_MISS_CHAR)
	 , nvl(ship_to_address4,		FND_API.G_MISS_CHAR)
	 , nvl(ship_to_city,		        FND_API.G_MISS_CHAR)
	 , nvl(ship_to_state,		        FND_API.G_MISS_CHAR)
	 , nvl(ship_to_postal_code,	        FND_API.G_MISS_CHAR)
	 , nvl(ship_to_country,	                FND_API.G_MISS_CHAR)
	 , nvl(ship_to_contact_id,		FND_API.G_MISS_NUM)
	 , nvl(ship_to_contact,			FND_API.G_MISS_CHAR)
	 , nvl(deliver_to_contact_id,		FND_API.G_MISS_NUM)
	 , nvl(deliver_to_contact,		FND_API.G_MISS_CHAR)
	 , nvl(invoice_to_contact_id,		FND_API.G_MISS_NUM)
	 , nvl(invoice_to_contact,		FND_API.G_MISS_CHAR)
	 , nvl(invoice_to_contact,		FND_API.G_MISS_CHAR)
	 , nvl(ship_tolerance_above,		FND_API.G_MISS_NUM)
	 , nvl(drop_ship_flag,			FND_API.G_MISS_NUM)
	 , nvl(price_list_id,			FND_API.G_MISS_NUM)
	 , nvl(price_list,			FND_API.G_MISS_CHAR)
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
	 , nvl(tax_point,			FND_API.G_MISS_CHAR)
	 , nvl(tax_exempt_flag,			FND_API.G_MISS_CHAR)
	 , nvl(tax_exempt_number,		FND_API.G_MISS_CHAR)
	 , nvl(tax_exempt_reason_code,		FND_API.G_MISS_CHAR)
	 , nvl(tax_exempt_reason,		FND_API.G_MISS_CHAR)
	 , nvl(agreement_id,			FND_API.G_MISS_NUM)
	 , nvl(agreement,			FND_API.G_MISS_CHAR)
	 , nvl(invoicing_rule_id,		FND_API.G_MISS_NUM)
	 , nvl(invoicing_rule,			FND_API.G_MISS_CHAR)
	 , nvl(accounting_rule_id,		FND_API.G_MISS_NUM)
	 , nvl(accounting_rule,			FND_API.G_MISS_CHAR)
	 , nvl(payment_term_id,			FND_API.G_MISS_NUM)
	 , nvl(payment_term,			FND_API.G_MISS_CHAR)
	 , nvl(demand_class_code,		FND_API.G_MISS_CHAR)
	 , nvl(shipment_priority_code,		FND_API.G_MISS_CHAR)
	 , nvl(shipment_priority,		FND_API.G_MISS_CHAR)
	 , nvl(shipping_method_code,		FND_API.G_MISS_CHAR)
	 , nvl(shipping_instructions,		FND_API.G_MISS_CHAR)
	 , nvl(packing_instructions,		FND_API.G_MISS_CHAR)
	 , nvl(freight_carrier_code,		FND_API.G_MISS_CHAR)
	 , nvl(freight_terms_code,		FND_API.G_MISS_CHAR)
	 , nvl(freight_terms,			FND_API.G_MISS_CHAR)
	 , nvl(fob_point_code,			FND_API.G_MISS_CHAR)
	 , nvl(fob_point,			FND_API.G_MISS_CHAR)
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
	 , nvl(customer_payment_term,		FND_API.G_MISS_NUM)
	 , nvl(demand_bucket_type_code,		FND_API.G_MISS_CHAR)
	 , nvl(demand_bucket_type,		FND_API.G_MISS_CHAR)
	 , nvl(customer_dock_code,		FND_API.G_MISS_CHAR)
	 , nvl(customer_job,			FND_API.G_MISS_CHAR)
	 , nvl(customer_production_line,	FND_API.G_MISS_CHAR)
	 , nvl(cust_model_serial_number,	FND_API.G_MISS_CHAR)
	 , nvl(project_id,			FND_API.G_MISS_NUM)
	 , nvl(project,				FND_API.G_MISS_CHAR)
	 , nvl(task_id,				FND_API.G_MISS_NUM)
	 , nvl(task,				FND_API.G_MISS_CHAR)
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
	 , nvl(cancelled_flag,			'N')
	 , nvl(context,               FND_API.G_MISS_CHAR)
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
/* Added Attribute 16 to 20 for the bug 3513248 */
         , nvl(attribute16,                     FND_API.G_MISS_CHAR)
         , nvl(attribute17,                     FND_API.G_MISS_CHAR)
         , nvl(attribute18,                     FND_API.G_MISS_CHAR)
         , nvl(attribute19,                     FND_API.G_MISS_CHAR)
         , nvl(attribute20,                     FND_API.G_MISS_CHAR)
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
	 , nvl(return_context,             FND_API.G_MISS_CHAR)
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
	 , nvl(status_flag,			     FND_API.G_MISS_CHAR)
	 , nvl(change_reason,			FND_API.G_MISS_CHAR)
	 , nvl(change_comments,			FND_API.G_MISS_CHAR)
	 , nvl(service_txn_reason_code,	FND_API.G_MISS_CHAR)
	 , nvl(service_txn_comments,		FND_API.G_MISS_CHAR)
	 , nvl(service_reference_type_code,FND_API.G_MISS_CHAR)
	 , nvl(service_reference_order,	FND_API.G_MISS_CHAR)
	 , nvl(service_reference_line,	FND_API.G_MISS_CHAR)
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
	 , nvl(commitment,		     FND_API.G_MISS_CHAR)
	 , nvl(commitment_id,		FND_API.G_MISS_NUM)
-- aksingh subinventory
         , nvl(subinventory,          FND_API.G_MISS_CHAR)
         ,nvl(salesrep,               FND_API.G_MISS_CHAR)
         ,nvl(salesrep_id,            FND_API.G_MISS_NUM)
         , nvl(earliest_acceptable_date, FND_API.G_MISS_DATE)
         , nvl(latest_acceptable_date,FND_API.G_MISS_DATE)
         , nvl(invoice_to_address1,             FND_API.G_MISS_CHAR)
         , nvl(invoice_to_address2,             FND_API.G_MISS_CHAR)
         , nvl(invoice_to_address3,             FND_API.G_MISS_CHAR)
	 , nvl(invoice_to_address4,		FND_API.G_MISS_CHAR)
	 , nvl(invoice_to_city,		        FND_API.G_MISS_CHAR)
	 , nvl(invoice_to_state,	        FND_API.G_MISS_CHAR)
	 , nvl(invoice_to_postal_code,	        FND_API.G_MISS_CHAR)
	 , nvl(invoice_to_country,	        FND_API.G_MISS_CHAR)
	 , nvl(user_item_description,	        FND_API.G_MISS_CHAR)
         , nvl(change_sequence,                 FND_API.G_MISS_CHAR)
     -- { Distributer Order related change
         , nvl(end_customer_id,                 FND_API.G_MISS_NUM)
         , nvl(end_customer_contact_id,         FND_API.G_MISS_NUM)
         , nvl(end_customer_site_use_id,        FND_API.G_MISS_NUM)
     --{added for bug 4240715
	 , nvl(end_customer_name,		FND_API.G_MISS_CHAR)
	 , nvl(end_customer_address1,		FND_API.G_MISS_CHAR)
	 , nvl(end_customer_address2,		FND_API.G_MISS_CHAR)
	 , nvl(end_customer_address3,		FND_API.G_MISS_CHAR)
	 , nvl(end_customer_address4,		FND_API.G_MISS_CHAR)
	-- , nvl(end_customer_location,		FND_API.G_MISS_CHAR)
	 , nvl(end_customer_city,		        FND_API.G_MISS_CHAR)
	 , nvl(end_customer_state,		        FND_API.G_MISS_CHAR)
	 , nvl(end_customer_postal_code,	        FND_API.G_MISS_CHAR)
	 , nvl(end_customer_country,	                FND_API.G_MISS_CHAR)
	 , nvl(end_customer_contact,			FND_API.G_MISS_CHAR)
         , nvl(end_customer_number,		FND_API.G_MISS_CHAR)
     --bug 4240715}
	 , nvl(ib_owner_code,                   FND_API.G_MISS_CHAR)
         , nvl(ib_current_location_code,        FND_API.G_MISS_CHAR)
         , nvl(ib_installed_at_location_code,   FND_API.G_MISS_CHAR)
         , nvl(ib_owner,                        FND_API.G_MISS_CHAR)
         , nvl(ib_current_location,             FND_API.G_MISS_CHAR)
         , nvl(ib_installed_at_location,        FND_API.G_MISS_CHAR)
     -- Distributer Order related change }
      FROM oe_lines_iface_all
     WHERE order_source_id			= l_order_source_id
       AND orig_sys_document_ref 		= l_orig_sys_document_ref
       AND nvl(sold_to_org_id,                  FND_API.G_MISS_NUM)
         = nvl(l_sold_to_org_id,                FND_API.G_MISS_NUM)
       AND nvl(sold_to_org,                  FND_API.G_MISS_CHAR)
         = nvl(l_sold_to_org,                FND_API.G_MISS_CHAR)
       AND nvl(  change_sequence,		FND_API.G_MISS_CHAR)
	 = nvl(l_change_sequence,		FND_API.G_MISS_CHAR)
       AND nvl(org_id,                          FND_API.G_MISS_NUM)
         = nvl(l_org_id,                        FND_API.G_MISS_NUM)
       AND nvl(  request_id,			FND_API.G_MISS_NUM)
	 = nvl(l_request_id,			FND_API.G_MISS_NUM)
       AND nvl(rejected_flag,'N')		= 'N'
  FOR UPDATE NOWAIT
  ORDER BY orig_sys_line_ref, orig_sys_shipment_ref
;


/* -----------------------------------------------------------
   Line Discounts/Price adjustments cursor
   -----------------------------------------------------------
*/
    CURSOR l_line_adj_cursor IS
    SELECT nvl(orig_sys_discount_ref,	FND_API.G_MISS_CHAR)
	 , nvl(change_request_code,	FND_API.G_MISS_CHAR)
	 , nvl(list_header_id,        FND_API.G_MISS_NUM)
	 , nvl(list_line_id,          FND_API.G_MISS_NUM)
	 , nvl(discount_name,		FND_API.G_MISS_CHAR)
	 , nvl(percent,			FND_API.G_MISS_NUM)
	 , nvl(automatic_flag,		FND_API.G_MISS_CHAR)
	 , nvl(applied_flag,		FND_API.G_MISS_CHAR)
	 , nvl(operand,			FND_API.G_MISS_NUM)
	 , nvl(arithmetic_operator,	FND_API.G_MISS_CHAR)
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
         , request_id
	 , nvl(operation_code,		OE_GLOBALS.G_OPR_CREATE)
	 , nvl(status_flag,		FND_API.G_MISS_CHAR)
-- Price Adjustment related changes bug# 1220921 (Start)
      , nvl( AC_CONTEXT,                 FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE1,              FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE2,              FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE3,              FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE4,              FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE5,              FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE6,              FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE7,              FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE8,              FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE9,              FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE10,             FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE11,             FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE12,             FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE13,             FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE14,             FND_API.G_MISS_CHAR)
      , nvl( AC_ATTRIBUTE15,             FND_API.G_MISS_CHAR)
      , nvl( LIST_NAME,                  FND_API.G_MISS_CHAR)
      , nvl( LIST_LINE_TYPE_CODE,        FND_API.G_MISS_CHAR)
      , nvl( LIST_LINE_NUMBER,           FND_API.G_MISS_CHAR)
      , nvl( VERSION_NUMBER,             FND_API.G_MISS_CHAR)
      , nvl( INVOICED_FLAG,              FND_API.G_MISS_CHAR)
      , nvl( ESTIMATED_FLAG,             FND_API.G_MISS_CHAR)
      , nvl( INC_IN_SALES_PERFORMANCE,   FND_API.G_MISS_CHAR)
      , nvl( CHARGE_TYPE_CODE,           FND_API.G_MISS_CHAR)
      , nvl( CHARGE_SUBTYPE_CODE,        FND_API.G_MISS_CHAR)
      , nvl( CREDIT_OR_CHARGE_FLAG,      FND_API.G_MISS_CHAR)
      , nvl( INCLUDE_ON_RETURNS_FLAG,    FND_API.G_MISS_CHAR)
      , nvl( COST_ID,                    FND_API.G_MISS_NUM)
      , nvl( TAX_CODE,                   FND_API.G_MISS_CHAR)
      , nvl( PARENT_ADJUSTMENT_ID,       FND_API.G_MISS_NUM)
      , nvl(MODIFIER_MECHANISM_TYPE_CODE,FND_API.G_MISS_CHAR)
      , nvl( MODIFIED_FROM,              FND_API.G_MISS_CHAR)
      , nvl( MODIFIED_TO,                FND_API.G_MISS_CHAR)
      , nvl( UPDATED_FLAG,               FND_API.G_MISS_CHAR)
      , nvl( UPDATE_ALLOWED,             FND_API.G_MISS_CHAR)
      , nvl( CHANGE_REASON_CODE,         FND_API.G_MISS_CHAR)
      , nvl( CHANGE_REASON_TEXT,         FND_API.G_MISS_CHAR)
      , nvl( PRICING_PHASE_ID,           FND_API.G_MISS_NUM)
      , nvl( ADJUSTED_AMOUNT,            FND_API.G_MISS_NUM)
      , nvl( ORIG_SYS_LINE_REF,          FND_API.G_MISS_CHAR)
-- Price Adjustment related changes bug# 1220921 (End)
      FROM oe_price_adjs_iface_all
     WHERE order_source_id		= l_order_source_id
       AND orig_sys_document_ref 	= l_orig_sys_document_ref
       AND nvl(sold_to_org_id,                  FND_API.G_MISS_NUM)
         = nvl(l_sold_to_org_id,                FND_API.G_MISS_NUM)
       AND nvl(sold_to_org,                  FND_API.G_MISS_CHAR)
         = nvl(l_sold_to_org,                FND_API.G_MISS_CHAR)
       AND nvl(  change_sequence,	FND_API.G_MISS_CHAR)
	 = nvl(l_change_sequence,	FND_API.G_MISS_CHAR)
       AND nvl(org_id,                          FND_API.G_MISS_NUM)
         = nvl(l_org_id,                        FND_API.G_MISS_NUM)
       AND orig_sys_line_ref 		= l_orig_sys_line_ref
       AND nvl(  orig_sys_shipment_ref,	FND_API.G_MISS_CHAR)
	 = nvl(l_orig_sys_shipment_ref,	FND_API.G_MISS_CHAR)
       AND nvl(  request_id,		FND_API.G_MISS_NUM)
	 = nvl(l_request_id,		FND_API.G_MISS_NUM)
  FOR UPDATE NOWAIT
  ORDER BY orig_sys_discount_ref
;


/* -----------------------------------------------------------
   Line Sales Credits cursor
   -----------------------------------------------------------
*/
    CURSOR l_line_scredit_cursor IS
    SELECT nvl(orig_sys_credit_ref,	FND_API.G_MISS_CHAR)
	 , nvl(change_request_code,	FND_API.G_MISS_CHAR)
	 , nvl(salesrep_id,		FND_API.G_MISS_NUM)
	 , nvl(salesrep	,		FND_API.G_MISS_CHAR)
	 , nvl(sales_credit_type_id,	FND_API.G_MISS_NUM)
	 , nvl(sales_credit_type,	FND_API.G_MISS_CHAR)
	 , nvl(percent,			FND_API.G_MISS_NUM)
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
	 , nvl(status_flag,		FND_API.G_MISS_CHAR)
         , nvl(ORIG_SYS_LINE_REF,       FND_API.G_MISS_CHAR)
      FROM oe_credits_iface_all
     WHERE order_source_id		= l_order_source_id
       AND orig_sys_document_ref 	= l_orig_sys_document_ref
       AND nvl(sold_to_org_id,                  FND_API.G_MISS_NUM)
         = nvl(l_sold_to_org_id,                FND_API.G_MISS_NUM)
       AND nvl(sold_to_org,                  FND_API.G_MISS_CHAR)
         = nvl(l_sold_to_org,                FND_API.G_MISS_CHAR)
       AND nvl(  change_sequence,	FND_API.G_MISS_CHAR)
	 = nvl(l_change_sequence,	FND_API.G_MISS_CHAR)
       AND nvl(org_id,                          FND_API.G_MISS_NUM)
         = nvl(l_org_id,                        FND_API.G_MISS_NUM)
       AND orig_sys_line_ref 		= l_orig_sys_line_ref
       AND nvl(  orig_sys_shipment_ref,	FND_API.G_MISS_CHAR)
	 = nvl(l_orig_sys_shipment_ref,	FND_API.G_MISS_CHAR)
       AND nvl(  request_id,		FND_API.G_MISS_NUM)
	 = nvl(l_request_id,		FND_API.G_MISS_NUM)
  FOR UPDATE NOWAIT
  ORDER BY orig_sys_credit_ref
;




/* -----------------------------------------------------------
   Line Reservations cursor
   -----------------------------------------------------------
*/
    CURSOR l_reservation_cursor IS
    SELECT orig_sys_reservation_ref
	 , revision
	 , lot_number_id
	 , lot_number
	 , subinventory_id
	 , subinventory_code
	 , locator_id
	 , quantity
	 , attribute_category
	 , attribute1
	 , attribute2
	 , attribute3
	 , attribute4
	 , attribute5
	 , attribute6
	 , attribute7
	 , attribute8
	 , attribute9
	 , attribute10
	 , attribute11
	 , attribute12
	 , attribute13
	 , attribute14
	 , attribute15
	 , nvl(operation_code,		OE_GLOBALS.G_OPR_CREATE)
      FROM oe_reservtns_iface_all
     WHERE order_source_id 		= l_order_source_id
       AND orig_sys_document_ref 	= l_orig_sys_document_ref
       AND nvl(sold_to_org_id,                  FND_API.G_MISS_NUM)
         = nvl(l_sold_to_org_id,                FND_API.G_MISS_NUM)
       AND nvl(sold_to_org,                  FND_API.G_MISS_CHAR)
         = nvl(l_sold_to_org,                FND_API.G_MISS_CHAR)
       AND nvl(  change_sequence,	FND_API.G_MISS_CHAR)
	 = nvl(l_change_sequence,	FND_API.G_MISS_CHAR)
       AND nvl(org_id,                          FND_API.G_MISS_NUM)
         = nvl(l_org_id,                        FND_API.G_MISS_NUM)
       AND orig_sys_line_ref 		= l_orig_sys_line_ref
       AND nvl(  orig_sys_shipment_ref,	FND_API.G_MISS_CHAR)
	 = nvl(l_orig_sys_shipment_ref,	FND_API.G_MISS_CHAR)
       AND nvl(  request_id,		FND_API.G_MISS_NUM)
	 = nvl(l_request_id,		FND_API.G_MISS_NUM)
  FOR UPDATE NOWAIT
  ORDER BY orig_sys_reservation_ref
;



--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

/* -----------------------------------------------------------
   Initialize messages
   -----------------------------------------------------------
*/
   IF p_init_msg_list = FND_API.G_TRUE THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE INITIALIZING MESSAGES LIST' ) ;
      END IF;
      OE_MSG_PUB.Initialize;
   END IF;

/* -----------------------------------------------------------
   Set message context
   -----------------------------------------------------------
*/
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'BEFORE SETTING MESSAGE CONTEXT' ) ;
  END IF;

  OE_MSG_PUB.set_msg_context(
		p_entity_code                => 'HEADER'
         ,p_entity_ref                 => null
	    ,p_entity_id                  => null
	    ,p_header_id                  => null
	    ,p_line_id                    => null
	    ,p_order_source_id            => l_order_source_id
	    ,p_orig_sys_document_ref      => l_orig_sys_document_ref
	    ,p_change_sequence            => l_change_sequence
	    ,p_orig_sys_document_line_ref => null
	    ,p_orig_sys_shipment_ref      => null
	    ,p_source_document_type_id    => null
	    ,p_source_document_id         => null
	    ,p_source_document_line_id    => null
	    ,p_attribute_code             => null
	    ,p_constraint_id              => null
	    );

/* -----------------------------------------------------------
   Initialization
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE INITIALIZATION' ) ;
   END IF;
  begin
    select DECODE(p_validate_only,'Y','T','N','F',p_validate_only)
    into   l_validate_only
    from   dual;
  exception
    when others then
      l_validate_only := 'T';
  end;
  l_header_rec 	     := OE_Order_Pub.G_MISS_HEADER_REC;
  l_header_rec_old 		:= OE_Order_Pub.G_MISS_HEADER_REC;
  l_header_rec_new 		:= OE_Order_Pub.G_MISS_HEADER_REC;
  l_header_adj_rec 		:= OE_Order_Pub.G_MISS_HEADER_ADJ_REC;
  l_header_adj_tbl 		:= OE_Order_Pub.G_MISS_HEADER_ADJ_TBL;
  l_header_adj_tbl_old 		:= OE_Order_Pub.G_MISS_HEADER_ADJ_TBL;
  l_header_adj_tbl_new 		:= OE_Order_Pub.G_MISS_HEADER_ADJ_TBL;
  l_header_scredit_rec 		:= OE_Order_Pub.G_MISS_HEADER_SCREDIT_REC;

  l_header_scredit_tbl 		:= OE_Order_Pub.G_MISS_HEADER_SCREDIT_TBL;
  l_header_scredit_tbl_old 	:= OE_Order_Pub.G_MISS_HEADER_SCREDIT_TBL;
  l_header_scredit_tbl_new 	:= OE_Order_Pub.G_MISS_HEADER_SCREDIT_TBL;

  l_header_val_rec 		:= OE_Order_Pub.G_MISS_HEADER_VAL_REC;
  l_header_val_rec_old 		:= OE_Order_Pub.G_MISS_HEADER_VAL_REC;
  l_header_val_rec_new 		:= OE_Order_Pub.G_MISS_HEADER_VAL_REC;
  l_header_adj_val_rec 		:= OE_Order_Pub.G_MISS_HEADER_ADJ_VAL_REC;
  l_header_adj_val_tbl 		:= OE_Order_Pub.G_MISS_HEADER_ADJ_VAL_TBL;
  l_header_adj_val_tbl_old 	:= OE_Order_Pub.G_MISS_HEADER_ADJ_VAL_TBL;
  l_header_adj_val_tbl_new 	:= OE_Order_Pub.G_MISS_HEADER_ADJ_VAL_TBL;
  l_header_scredit_val_rec 	:= OE_Order_Pub.G_MISS_HEADER_SCREDIT_VAL_REC;
  l_header_scredit_val_tbl 	:= OE_Order_Pub.G_MISS_HEADER_SCREDIT_VAL_TBL;
  l_header_scredit_val_tbl_old 	:= OE_Order_Pub.G_MISS_HEADER_SCREDIT_VAL_TBL;
  l_header_scredit_val_tbl_new 	:= OE_Order_Pub.G_MISS_HEADER_SCREDIT_VAL_TBL;

  l_line_rec 			:= OE_Order_Pub.G_MISS_LINE_REC;
  l_line_tbl 			:= OE_Order_Pub.G_MISS_LINE_TBL;
  l_line_tbl_old 		:= OE_Order_Pub.G_MISS_LINE_TBL;
  l_line_tbl_new 		:= OE_Order_Pub.G_MISS_LINE_TBL;
  l_line_adj_rec 		:= OE_Order_Pub.G_MISS_LINE_ADJ_REC;
  l_line_adj_tbl 		:= OE_Order_Pub.G_MISS_LINE_ADJ_TBL;
  l_line_adj_tbl_old 		:= OE_Order_Pub.G_MISS_LINE_ADJ_TBL;
  l_line_adj_tbl_new 		:= OE_Order_Pub.G_MISS_LINE_ADJ_TBL;
  l_line_scredit_rec 		:= OE_Order_Pub.G_MISS_LINE_SCREDIT_REC;
  l_line_scredit_tbl 		:= OE_Order_Pub.G_MISS_LINE_SCREDIT_TBL;
  l_line_scredit_tbl_old 	:= OE_Order_Pub.G_MISS_LINE_SCREDIT_TBL;
  l_line_scredit_tbl_new 	:= OE_Order_Pub.G_MISS_LINE_SCREDIT_TBL;
  l_reservation_rec 		:= OE_Order_Pub.G_MISS_RESERVATION_REC;
  l_reservation_tbl 		:= OE_Order_Pub.G_MISS_RESERVATION_TBL;

  l_line_val_rec 		:= OE_Order_Pub.G_MISS_LINE_VAL_REC;
  l_line_val_tbl 		:= OE_Order_Pub.G_MISS_LINE_VAL_TBL;
  l_line_val_tbl_old 		:= OE_Order_Pub.G_MISS_LINE_VAL_TBL;
  l_line_val_tbl_new 		:= OE_Order_Pub.G_MISS_LINE_VAL_TBL;
  l_line_adj_val_rec 		:= OE_Order_Pub.G_MISS_LINE_ADJ_VAL_REC;
  l_line_adj_val_tbl 		:= OE_Order_Pub.G_MISS_LINE_ADJ_VAL_TBL;
  l_line_adj_val_tbl_old 	:= OE_Order_Pub.G_MISS_LINE_ADJ_VAL_TBL;
  l_line_adj_val_tbl_new 	:= OE_Order_Pub.G_MISS_LINE_ADJ_VAL_TBL;
  l_line_scredit_val_rec 	:= OE_Order_Pub.G_MISS_LINE_SCREDIT_VAL_REC;
  l_line_scredit_val_tbl 	:= OE_Order_Pub.G_MISS_LINE_SCREDIT_VAL_TBL;
  l_line_scredit_val_tbl_old 	:= OE_Order_Pub.G_MISS_LINE_SCREDIT_VAL_TBL;
  l_line_scredit_val_tbl_new 	:= OE_Order_Pub.G_MISS_LINE_SCREDIT_VAL_TBL;
  l_reservation_val_rec 	:= OE_Order_Pub.G_MISS_RESERVATION_VAL_REC;
  l_reservation_val_tbl 	:= OE_Order_Pub.G_MISS_RESERVATION_VAL_TBL;

  l_lot_serial_rec 		:= OE_Order_Pub.G_MISS_LOT_SERIAL_REC;
  l_lot_serial_tbl 		:= OE_Order_Pub.G_MISS_LOT_SERIAL_TBL;
  l_lot_serial_tbl_old 		:= OE_Order_Pub.G_MISS_LOT_SERIAL_TBL;
  l_lot_serial_tbl_new 		:= OE_Order_Pub.G_MISS_LOT_SERIAL_TBL;

  l_action_request_rec 		:= OE_Order_Pub.G_MISS_REQUEST_REC;
  l_action_request_tbl 		:= OE_Order_Pub.G_MISS_REQUEST_TBL;
  l_action_request_tbl_old 	:= OE_Order_Pub.G_MISS_REQUEST_TBL;
  l_action_request_tbl_new 	:= OE_Order_Pub.G_MISS_REQUEST_TBL;

  p_return_status		:= FND_API.G_RET_STS_SUCCESS; -- Success




/* -----------------------------------------------------------
   Headers
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE HEADERS LOOP' ) ;
   END IF;

  l_header_count := 0;

  OPEN l_header_cursor;
  --LOOP
  BEGIN
     FETCH l_header_cursor
      INTO l_header_rec.order_source_id
	 , l_header_rec.orig_sys_document_ref
	 , l_header_rec.change_sequence
	 , l_header_rec.change_request_code
	 , l_header_val_rec.order_source
	 , l_header_rec.org_id
	 , l_header_rec.header_id
	 , l_header_rec.order_number
	 , l_header_rec.version_number
	 , l_header_rec.ordered_date
	 , l_header_rec.order_type_id
	 , l_header_val_rec.order_type
	 , l_header_rec.price_list_id
	 , l_header_val_rec.price_list
	 , l_header_rec.conversion_rate
	 , l_header_rec.conversion_rate_date
	 , l_header_rec.conversion_type_code
	 , l_header_val_rec.conversion_type
	 , l_header_rec.transactional_curr_code
	 , l_header_rec.return_reason_code
	 , l_header_rec.salesrep_id
	 , l_header_val_rec.salesrep
	 , l_header_rec.sales_channel_code
	 , l_header_val_rec.sales_channel
	 , l_header_rec.tax_point_code
	 , l_header_val_rec.tax_point
	 , l_header_rec.tax_exempt_flag
	 , l_header_rec.tax_exempt_number
	 , l_header_rec.tax_exempt_reason_code
	 , l_header_val_rec.tax_exempt_reason
	 , l_header_rec.agreement_id
	 , l_header_val_rec.agreement
	 , l_header_rec.invoicing_rule_id
	 , l_header_val_rec.invoicing_rule
	 , l_header_rec.accounting_rule_id
	 , l_header_val_rec.accounting_rule
	 , l_header_rec.payment_term_id
	 , l_header_val_rec.payment_term
	 , l_header_rec.demand_class_code
	 , l_header_rec.shipment_priority_code
	 , l_header_val_rec.shipment_priority
	 , l_header_rec.shipping_method_code
	 , l_header_rec.freight_carrier_code
	 , l_header_rec.freight_terms_code
	 , l_header_val_rec.freight_terms
	 , l_header_rec.fob_point_code
	 , l_header_val_rec.fob_point
	 , l_header_rec.partial_shipments_allowed
	 , l_header_rec.ship_tolerance_above
	 , l_header_rec.ship_tolerance_below
	 , l_header_rec.shipping_instructions
	 , l_header_rec.packing_instructions
  	 , l_header_rec.order_date_type_code
  	 , l_header_rec.earliest_schedule_limit
  	 , l_header_rec.latest_schedule_limit
	 , l_header_rec.cust_po_number
	 , l_header_rec.customer_payment_term_id
	 , l_header_val_rec.customer_payment_term
	 , l_header_rec.payment_type_code
	 , l_header_rec.payment_amount
	 , l_header_rec.check_number
	 , l_header_rec.credit_card_code
	 , l_header_rec.credit_card_holder_name
	 , l_header_rec.credit_card_number
	 , l_header_rec.credit_card_expiration_date
	 , l_header_rec.credit_card_approval_code
	 , l_header_rec.credit_card_approval_date
	 , l_header_rec.sold_from_org_id
	 , l_header_val_rec.sold_from_org
	 , l_header_rec.sold_to_org_id
	 , l_header_val_rec.sold_to_org
	 , l_header_val_rec.customer_number
	 , l_header_rec.ship_from_org_id
	 , l_header_val_rec.ship_from_org
	 , l_header_rec.ship_to_org_id
	 , l_header_val_rec.ship_to_org
	 , l_header_rec.invoice_to_org_id
	 , l_header_val_rec.invoice_to_org
	 , l_header_rec.deliver_to_org_id
	 , l_header_val_rec.deliver_to_org
	 , l_header_rec.sold_to_contact_id
	 , l_header_val_rec.sold_to_contact
	 , l_header_rec.ship_to_contact_id
	 , l_header_val_rec.ship_to_contact
	 , l_header_rec.invoice_to_contact_id
	 , l_header_val_rec.invoice_to_contact
	 , l_header_rec.deliver_to_contact_id
	 , l_header_val_rec.deliver_to_contact
	 , l_header_val_rec.ship_to_address1
	 , l_header_val_rec.ship_to_address2
	 , l_header_val_rec.ship_to_address3
	 , l_header_val_rec.ship_to_address4
	 , l_header_val_rec.ship_to_city
	 , l_header_val_rec.ship_to_state
	 , l_header_val_rec.ship_to_zip
	 , l_header_val_rec.ship_to_country
	 , l_header_val_rec.invoice_to_address1
	 , l_header_val_rec.invoice_to_address2
	 , l_header_val_rec.invoice_to_address3
	 , l_header_val_rec.invoice_to_address4
	 , l_header_val_rec.invoice_to_city
	 , l_header_val_rec.invoice_to_state
	 , l_header_val_rec.invoice_to_zip
	 , l_header_val_rec.invoice_to_country
	 , l_header_rec.drop_ship_flag
	 , l_header_rec.booked_flag
--	 , l_header_rec.closed_flag
	 , l_header_rec.cancelled_flag
	 , l_header_rec.context
	 , l_header_rec.attribute1
	 , l_header_rec.attribute2
	 , l_header_rec.attribute3
	 , l_header_rec.attribute4
	 , l_header_rec.attribute5
	 , l_header_rec.attribute6
	 , l_header_rec.attribute7
	 , l_header_rec.attribute8
	 , l_header_rec.attribute9
	 , l_header_rec.attribute10
	 , l_header_rec.attribute11
	 , l_header_rec.attribute12
	 , l_header_rec.attribute13
	 , l_header_rec.attribute14
	 , l_header_rec.attribute15
/* Added attribute 16 to 20 for the bug 3471009 */
         , l_header_rec.attribute16
         , l_header_rec.attribute17
         , l_header_rec.attribute18
         , l_header_rec.attribute19
         , l_header_rec.attribute20
	 , l_header_rec.tp_context
	 , l_header_rec.tp_attribute1
	 , l_header_rec.tp_attribute2
	 , l_header_rec.tp_attribute3
	 , l_header_rec.tp_attribute4
	 , l_header_rec.tp_attribute5
	 , l_header_rec.tp_attribute6
	 , l_header_rec.tp_attribute7
	 , l_header_rec.tp_attribute8
	 , l_header_rec.tp_attribute9
	 , l_header_rec.tp_attribute10
	 , l_header_rec.tp_attribute11
	 , l_header_rec.tp_attribute12
	 , l_header_rec.tp_attribute13
	 , l_header_rec.tp_attribute14
	 , l_header_rec.tp_attribute15
	 , l_header_rec.global_attribute_category
	 , l_header_rec.global_attribute1
	 , l_header_rec.global_attribute2
	 , l_header_rec.global_attribute3
	 , l_header_rec.global_attribute4
	 , l_header_rec.global_attribute5
	 , l_header_rec.global_attribute6
	 , l_header_rec.global_attribute7
	 , l_header_rec.global_attribute8
	 , l_header_rec.global_attribute9
	 , l_header_rec.global_attribute10
	 , l_header_rec.global_attribute11
	 , l_header_rec.global_attribute12
	 , l_header_rec.global_attribute13
	 , l_header_rec.global_attribute14
	 , l_header_rec.global_attribute15
	 , l_header_rec.global_attribute16
	 , l_header_rec.global_attribute17
	 , l_header_rec.global_attribute18
	 , l_header_rec.global_attribute19
	 , l_header_rec.global_attribute20
      , l_header_rec.request_id
	 , l_header_rec.request_date
	 , l_header_rec.operation
	 , l_header_rec.ready_flag
	 , l_header_rec.status_flag
	 , l_header_rec.force_apply_flag
	 , l_header_rec.change_reason
	 , l_header_rec.change_comments
         , l_header_rec.open_flag
         , l_header_rec.customer_preference_set_code
	 , l_header_rec.sold_to_site_use_id
	 , l_header_val_rec.sold_to_location_address1
	 , l_header_val_rec.sold_to_location_address2
	 , l_header_val_rec.sold_to_location_address3
	 , l_header_val_rec.sold_to_location_address4
	 , l_header_val_rec.sold_to_location_city
	 , l_header_val_rec.sold_to_location_postal
	 , l_header_val_rec.sold_to_location_country
	 , l_header_val_rec.sold_to_location_state
	 , l_header_val_rec.sold_to_location_county
	 , l_header_val_rec.sold_to_location_province
         -- start of additional quoting columns
        , l_header_rec.transaction_phase_code
        , l_header_rec.expiration_date
        , l_header_rec.quote_number
        , l_header_rec.quote_date
        , l_header_rec.sales_document_name
        , l_header_rec.user_status_code
         -- end of additional quoting columns
     -- { Distributer Order related change
        , l_header_rec.end_customer_id
        , l_header_rec.end_customer_contact_id
        , l_header_rec.end_customer_site_use_id
    --{added for bug 4240715
	,l_header_val_rec.end_customer_name
	 , l_header_val_rec.end_customer_site_address1
	 , l_header_val_rec.end_customer_site_address2
	 , l_header_val_rec.end_customer_site_address3
	 , l_header_val_rec.end_customer_site_address4
--	   , l_header_val_rec.end_customer_site_location
	 , l_header_val_rec.end_customer_site_city
	 , l_header_val_rec.end_customer_site_state
	 , l_header_val_rec.end_customer_site_postal_code
	 , l_header_val_rec.end_customer_site_country
	 , l_header_val_rec.end_customer_contact
         , l_header_val_rec.end_customer_number
    --bug 4240715}
	 , l_header_rec.ib_owner
        , l_header_rec.ib_current_location
        , l_header_rec.ib_installed_at_location
        , l_header_val_rec.ib_owner_dsp
        , l_header_val_rec.ib_current_location_dsp
        , l_header_val_rec.ib_installed_at_location_dsp
     -- Distributer Order related change }
;
      --EXIT WHEN l_header_cursor%NOTFOUND;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER FETCH HEADER CURSOR' ) ;
      END IF;

      l_header_count := l_header_count + 1;

      l_order_source_id 	:= l_header_rec.order_source_id;
      l_orig_sys_document_ref 	:= l_header_rec.orig_sys_document_ref;
      l_sold_to_org_id          := l_header_rec.sold_to_org_id;
      l_sold_to_org             := l_header_val_rec.sold_to_org;
      l_change_sequence 	:= l_header_rec.change_sequence;

      /*
      IF l_header_rec.operation  = 'INSERT' THEN
         l_header_rec.operation := 'CREATE';
      END IF;
      */


      oe_debug_pub.add('Order Source Id: '   || l_order_source_id);
      oe_debug_pub.add('Orig Sys Reference: '|| l_orig_sys_document_ref);
      oe_debug_pub.add('Sold to Org Id: '    || l_sold_to_org_id);
      oe_debug_pub.add('Sold to Org: '    || l_sold_to_org);
      oe_debug_pub.add('Change Sequence: '   || l_change_sequence);


--Default unpopulated transaction_phase_code to 'F' for bug 3576009
IF l_header_rec.transaction_phase_code = FND_API.G_MISS_CHAR THEN
   l_header_rec.transaction_phase_code := 'F';
END IF;


 IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' THEN


/*****    If l_sold_to_org_id is null attempt to populate it based on
          l_sold_to_org.

******/
     if l_sold_to_org_id = FND_API.G_MISS_NUM then
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'header level sold to org id is g_miss_num, so it was not populated' ) ;
        END IF;

        if l_sold_to_org is not null then

           l_header_rec.sold_to_org_id := OE_VALUE_TO_ID.sold_to_org(
				  p_sold_to_org => l_sold_to_org,
	         		  p_customer_number => null);


/* if oe_value_to_id returned g_miss_num, reassign sold_to_org_id back to null */

           if l_header_rec.sold_to_org_id = FND_API.G_MISS_NUM then
        	IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'returned value for sold_to_org_id was g_miss_num') ;
                END IF;
                l_header_rec.sold_to_org_id := null;
           end if;

       else
	     IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'sold to org is NULL') ;
             END IF;
       end if;

     end if;

END IF;  -- code control check

      BEGIN
        --call value to id
        --
        OE_CNCL_UTIL.get_header_ids(l_header_rec,l_header_val_rec);
        --
        IF l_header_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          --
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          --
        ELSIF l_header_rec.return_status = FND_API.G_RET_STS_ERROR THEN
          --
          RAISE FND_API.G_EXC_ERROR;
          --
        END IF;
        --
        --
        OE_CNCL_Util.Convert_Miss_To_Null(l_header_rec);
        --

        OE_CNCL_validate_header.attributes(x_return_status    =>l_return_status
                                       ,   p_x_header_rec     =>l_header_rec);
                                       --,   p_validation_level =>FND_API.G_VALID_LEVEL_NONE
        --
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          --
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          --
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          --
          RAISE FND_API.G_EXC_ERROR;
          --
        END IF;
        --
        --
        OE_CNCL_validate_header.entity(x_return_status =>l_return_status
                                     , p_header_rec =>l_header_rec);
        --
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          --
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          --
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          --
          RAISE FND_API.G_EXC_ERROR;
          --
        END IF;
        --
      EXCEPTION
        --
        WHEN FND_API.G_EXC_ERROR THEN
          --
          OE_Header_Security.g_check_all_cols_constraint := 'Y';
          OE_MSG_PUB.reset_msg_context('HEADER');
          --
          RAISE;
          --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          --
          OE_Header_Security.g_check_all_cols_constraint := 'Y';
          OE_MSG_PUB.reset_msg_context('HEADER');
          --
          RAISE;
          --
        WHEN OTHERS THEN
          --
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            --
            OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Header');
            --
          END IF;
          --
	  OE_Header_Security.g_check_all_cols_constraint := 'Y';
          OE_MSG_PUB.reset_msg_context('HEADER');
          --
          RAISE;
          --
      END;


/* -----------------------------------------------------------
   Header Discounts/Price adjustments
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE HEADER ADJUSTMENTS LOOP' ) ;
   END IF;

  l_header_adj_count := 0;

  OPEN l_header_adj_cursor;
  LOOP
     FETCH l_header_adj_cursor
      INTO l_header_adj_rec.orig_sys_discount_ref
	 , l_header_adj_rec.change_request_code
	 , l_header_adj_rec.list_header_id	-- changed from discount_id
	 , l_header_adj_rec.list_line_id	-- changed from discount_line_id
	 , l_header_adj_val_rec.discount
	 , l_header_adj_rec.percent
	 , l_header_adj_rec.automatic_flag
	 , l_header_adj_rec.applied_flag
	 , l_header_adj_rec.operand
	 , l_header_adj_rec.arithmetic_operator
	 , l_header_adj_rec.context
	 , l_header_adj_rec.attribute1
	 , l_header_adj_rec.attribute2
	 , l_header_adj_rec.attribute3
	 , l_header_adj_rec.attribute4
	 , l_header_adj_rec.attribute5
	 , l_header_adj_rec.attribute6
	 , l_header_adj_rec.attribute7
	 , l_header_adj_rec.attribute8
	 , l_header_adj_rec.attribute9
	 , l_header_adj_rec.attribute10
	 , l_header_adj_rec.attribute11
	 , l_header_adj_rec.attribute12
	 , l_header_adj_rec.attribute13
	 , l_header_adj_rec.attribute14
	 , l_header_adj_rec.attribute15
         , l_header_adj_rec.request_id
	 , l_header_adj_rec.operation
	 , l_header_adj_rec.status_flag
-- Price Adjustment related changes bug# 1220921 (Start)
      , l_header_adj_rec.AC_CONTEXT
      , l_header_adj_rec.AC_ATTRIBUTE1
      , l_header_adj_rec.AC_ATTRIBUTE2
      , l_header_adj_rec.AC_ATTRIBUTE3
      , l_header_adj_rec.AC_ATTRIBUTE4
      , l_header_adj_rec.AC_ATTRIBUTE5
      , l_header_adj_rec.AC_ATTRIBUTE6
      , l_header_adj_rec.AC_ATTRIBUTE7
      , l_header_adj_rec.AC_ATTRIBUTE8
      , l_header_adj_rec.AC_ATTRIBUTE9
      , l_header_adj_rec.AC_ATTRIBUTE10
      , l_header_adj_rec.AC_ATTRIBUTE11
      , l_header_adj_rec.AC_ATTRIBUTE12
      , l_header_adj_rec.AC_ATTRIBUTE13
      , l_header_adj_rec.AC_ATTRIBUTE14
      , l_header_adj_rec.AC_ATTRIBUTE15
      , l_header_adj_val_rec.LIST_NAME
      , l_header_adj_rec.LIST_LINE_TYPE_CODE
      , l_header_adj_rec.LIST_LINE_NO
      , l_header_adj_val_rec.VERSION_NO
      , l_header_adj_rec.INVOICED_FLAG
      , l_header_adj_rec.ESTIMATED_FLAG
      , l_header_adj_rec.INC_IN_SALES_PERFORMANCE
      , l_header_adj_rec.CHARGE_TYPE_CODE
      , l_header_adj_rec.CHARGE_SUBTYPE_CODE
      , l_header_adj_rec.CREDIT_OR_CHARGE_FLAG
      , l_header_adj_rec.INCLUDE_ON_RETURNS_FLAG
      , l_header_adj_rec.COST_ID
      , l_header_adj_rec.TAX_CODE
      , l_header_adj_rec.PARENT_ADJUSTMENT_ID
      , l_header_adj_rec.MODIFIER_MECHANISM_TYPE_CODE
      , l_header_adj_rec.MODIFIED_FROM
      , l_header_adj_rec.MODIFIED_TO
      , l_header_adj_rec.UPDATED_FLAG
      , l_header_adj_rec.UPDATE_ALLOWED
      , l_header_adj_rec.CHANGE_REASON_CODE
      , l_header_adj_rec.CHANGE_REASON_TEXT
      , l_header_adj_rec.PRICING_PHASE_ID
      , l_header_adj_rec.ADJUSTED_AMOUNT
-- Price Adjustment related changes bug# 1220921 (End)
;
      EXIT WHEN l_header_adj_cursor%NOTFOUND;

      /*
      IF l_header_adj_rec.operation  = 'INSERT' THEN
         l_header_adj_rec.operation := 'CREATE';
      END IF;
      */

      l_header_adj_count := l_header_adj_count + 1;
      l_header_adj_tbl     (l_header_adj_count) := l_header_adj_rec;
      l_header_adj_val_tbl (l_header_adj_count) := l_header_adj_val_rec;

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'HEADER ADJ REF ( '||L_HEADER_ADJ_COUNT||' ) : '|| L_HEADER_ADJ_TBL ( L_HEADER_ADJ_COUNT ) .ORIG_SYS_DISCOUNT_REF ) ;
		END IF;


      BEGIN
        --
        OE_CNCL_UTIL.get_header_adj_ids(l_header_adj_rec,l_header_adj_val_rec);
        --
        IF l_header_adj_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          --
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          --
        ELSIF l_header_adj_rec.return_status = FND_API.G_RET_STS_ERROR THEN
          --
          RAISE FND_API.G_EXC_ERROR;
          --
        END IF;
        --
        --
        OE_CNCL_Util.Convert_Miss_To_Null(l_header_adj_rec);
        --

        OE_CNCL_Validate_Header_Adj.Attributes( x_return_status =>l_return_status
                                            ,   p_Header_Adj_rec =>l_header_adj_rec);
        --
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          --
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          --
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          --
          RAISE FND_API.G_EXC_ERROR;
          --
        END IF;
        --
        OE_CNCL_Validate_Header_Adj.Entity(     x_return_status =>l_return_status
                                             ,   p_Header_Adj_rec =>l_header_adj_rec);
        --
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          --
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          --
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          --
          RAISE FND_API.G_EXC_ERROR;
          --
        END IF;
        --

      EXCEPTION
        --
        WHEN FND_API.G_EXC_ERROR THEN
          --
          OE_Header_Security.g_check_all_cols_constraint := 'Y';
          OE_MSG_PUB.reset_msg_context('HEADER_ADJ');
          --
          RAISE;
          --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          --
          OE_Header_Security.g_check_all_cols_constraint := 'Y';
          OE_MSG_PUB.reset_msg_context('HEADER_ADJ');
          --
          RAISE;
          --
        WHEN OTHERS THEN
          --
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            --
            OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Header_Adjs');
            --
          END IF;
          --
	  OE_Header_Security.g_check_all_cols_constraint := 'Y';
          OE_MSG_PUB.reset_msg_context('HEADER_ADJ');
          --
          RAISE;
          --
      END;

  END LOOP;
  CLOSE l_header_adj_cursor;





/* -----------------------------------------------------------
   Header Sales Credits
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE HEADER SALES CREDITS LOOP' ) ;
   END IF;

  l_header_scredit_count := 0;

  OPEN l_header_scredit_cursor;
  LOOP
     FETCH l_header_scredit_cursor
      INTO l_header_scredit_rec.orig_sys_credit_ref
	 , l_header_scredit_rec.change_request_code
	 , l_header_scredit_rec.salesrep_id
	 , l_header_scredit_val_rec.salesrep
	 , l_header_scredit_rec.sales_credit_type_id
	 , l_header_scredit_val_rec.sales_credit_type
	 , l_header_scredit_rec.percent
	 , l_header_scredit_rec.context
	 , l_header_scredit_rec.attribute1
	 , l_header_scredit_rec.attribute2
	 , l_header_scredit_rec.attribute3
	 , l_header_scredit_rec.attribute4
	 , l_header_scredit_rec.attribute5
	 , l_header_scredit_rec.attribute6
	 , l_header_scredit_rec.attribute7
	 , l_header_scredit_rec.attribute8
	 , l_header_scredit_rec.attribute9
	 , l_header_scredit_rec.attribute10
	 , l_header_scredit_rec.attribute11
	 , l_header_scredit_rec.attribute12
	 , l_header_scredit_rec.attribute13
	 , l_header_scredit_rec.attribute14
	 , l_header_scredit_rec.attribute15
	 , l_header_scredit_rec.operation
	 , l_header_scredit_rec.status_flag
;
      EXIT WHEN l_header_scredit_cursor%NOTFOUND;

      /*
      IF l_header_scredit_rec.operation  = 'INSERT' THEN
         l_header_scredit_rec.operation := 'CREATE';
      END IF;
      */

      l_header_scredit_count := l_header_scredit_count + 1;
      l_header_scredit_tbl     (l_header_scredit_count) := l_header_scredit_rec;
      l_header_scredit_val_tbl (l_header_scredit_count) := l_header_scredit_val_rec;

      	IF l_debug_level  > 0 THEN
      	    oe_debug_pub.add(  'HEADER SALESCREDIT ( '|| L_HEADER_SCREDIT_COUNT||' ) : '|| L_HEADER_SCREDIT_TBL ( L_HEADER_SCREDIT_COUNT ) .ORIG_SYS_CREDIT_REF ) ;
      	END IF;

      BEGIN
        --
        OE_CNCL_UTIL.get_header_scredit_ids(l_header_scredit_rec,l_header_scredit_val_rec);
        --
        IF l_header_scredit_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          --
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          --
        ELSIF l_header_scredit_rec.return_status = FND_API.G_RET_STS_ERROR THEN
          --
          RAISE FND_API.G_EXC_ERROR;
          --
        END IF;
        --

        --
        OE_CNCL_Util.Convert_Miss_To_Null(l_header_scredit_rec);
        --

        OE_CNCL_Val_Header_Scredit.Attributes (x_return_status => l_return_status
                                           ,   p_Header_Scredit_rec => l_header_scredit_rec);
        --
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          --
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          --
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          --
          RAISE FND_API.G_EXC_ERROR;
          --
        END IF;
        --

        OE_CNCL_Val_Header_Scredit.Entity (x_return_status => l_return_status
                                       ,   p_Header_Scredit_rec => l_header_scredit_rec);
        --
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          --
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          --
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          --
          RAISE FND_API.G_EXC_ERROR;
          --
        END IF;
        --
      EXCEPTION
        --
        WHEN FND_API.G_EXC_ERROR THEN
          --
          OE_Header_Security.g_check_all_cols_constraint := 'Y';
          OE_MSG_PUB.reset_msg_context('HEADER_SCREDIT');
          --
          RAISE;
          --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          --
          OE_Header_Security.g_check_all_cols_constraint := 'Y';
          OE_MSG_PUB.reset_msg_context('HEADER_SCREDIT');
          --
          RAISE;
          --
        WHEN OTHERS THEN
          --
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            --
            OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Header_Scredits');
            --
          END IF;
          --
          OE_Header_Security.g_check_all_cols_constraint := 'Y';
          OE_MSG_PUB.reset_msg_context('HEADER_ADJ');
          --
          RAISE;
          --
      END;
      --
  END LOOP;
  CLOSE l_header_scredit_cursor;


/* -----------------------------------------------------------
   Lines
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE LINES LOOP' ) ;
   END IF;

  l_line_count := 0;

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
	 , l_line_rec.schedule_arrival_date
	 , l_line_rec.actual_arrival_date
-- bug 3220711 - start
	 , l_line_rec.actual_shipment_date
-- bug 3220711 - end
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
/* OPM variables */ -- INVCONV
         , l_line_rec.ordered_quantity2
         , l_line_rec.ordered_quantity_uom2
         , l_line_rec.shipping_quantity2
         , l_line_rec.shipping_quantity_uom2
         , l_line_rec.shipped_quantity2
         , l_line_rec.cancelled_quantity2
         , l_line_rec.fulfilled_quantity2
         , l_line_rec.preferred_grade
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
/* Added attribute 16 to 20 for bug 3513248 */
         , l_line_rec.attribute16
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
      ,l_line_val_rec.invoice_to_address1
      ,l_line_val_rec.invoice_to_address2
      ,l_line_val_rec.invoice_to_address3
      ,l_line_val_rec.invoice_to_address4
      ,l_line_val_rec.invoice_to_city
      ,l_line_val_rec.invoice_to_state
      ,l_line_val_rec.invoice_to_zip
      ,l_line_val_rec.invoice_to_country
      ,l_line_rec.user_item_description
      ,l_line_rec.change_sequence
     -- { Distributer Order related change
      ,l_line_rec.end_customer_id
      ,l_line_rec.end_customer_contact_id
      ,l_line_rec.end_customer_site_use_id
      --{added for bug 4240715
	,l_line_val_rec.end_customer_name
	, l_line_val_rec.end_customer_site_address1
	, l_line_val_rec.end_customer_site_address2
	, l_line_val_rec.end_customer_site_address3
	, l_line_val_rec.end_customer_site_address4
--	, l_line_val_rec.end_customer_site_location
	, l_line_val_rec.end_customer_site_city
	, l_line_val_rec.end_customer_site_state
	, l_line_val_rec.end_customer_site_postal_code
	, l_line_val_rec.end_customer_site_country
	, l_line_val_rec.end_customer_contact
        , l_line_val_rec.end_customer_number
       -- bug 4240715}
      ,l_line_rec.ib_owner
      ,l_line_rec.ib_current_location
      ,l_line_rec.ib_installed_at_location
      ,l_line_val_rec.ib_owner_dsp
      ,l_line_val_rec.ib_current_location_dsp
      ,l_line_val_rec.ib_installed_at_location_dsp
     -- Distributer Order related change }
      ;
      IF l_debug_level  > 0 THEN
      oe_debug_pub.add('value inserted'||l_line_rec.end_customer_id);	-- added for bug 4240715
      END IF;
      EXIT WHEN l_line_cursor%NOTFOUND;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER LINE FETCH ' ) ;
      END IF;
    /*
    IF l_line_rec.operation  = 'INSERT' THEN
       l_line_rec.operation := 'CREATE';
    END IF;
    */

   --Assigning line level transaction phase value to header value for bug 3576009
   l_line_rec.transaction_phase_code := l_header_rec.transaction_phase_code;


/* if missing, get line level sold to org id from header
 this is necessary for the case where the sold_to_org
 was populated and the header-level sold_to_org_id was derived
 */


     if l_line_rec.sold_to_org_id = FND_API.G_MISS_NUM then
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'line level sold to org id is g_miss_num, so it was not populated.  defaulting to header level sold to org id' ) ;
        END IF;
        l_line_rec.sold_to_org_id := l_header_rec.sold_to_org_id;
     end if;



    l_line_count := l_line_count + 1;
    if l_line_rec.service_reference_order = FND_API.G_MISS_CHAR then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'L_LINE_REC.SERVICE_REFERENCE_ORDER ' || ASCII ( L_LINE_REC.SERVICE_REFERENCE_ORDER ) ) ;
    END IF;
    end if;
    if l_line_val_rec.sold_to_org = FND_API.G_MISS_CHAR then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'L_LINE_VAL_REC.SOLD_TO_ORG ' || ASCII ( L_LINE_VAL_REC.SOLD_TO_ORG ) ) ;
    END IF;
    end if;

    --populate l_line_rec.inventory_item_id with ccid if any of the
    --segments are passed instead of inventory_item_id
    IF l_line_rec.inventory_item_id = FND_API.G_MISS_NUM AND
	 ((l_segment_array(1) IS NOT NULL) OR
	  (l_segment_array(2) IS NOT NULL) OR
	  (l_segment_array(3) IS NOT NULL) OR
	  (l_segment_array(4) IS NOT NULL) OR
	  (l_segment_array(5) IS NOT NULL) OR
	  (l_segment_array(6) IS NOT NULL) OR
	  (l_segment_array(7) IS NOT NULL) OR
	  (l_segment_array(8) IS NOT NULL) OR
	  (l_segment_array(9) IS NOT NULL) OR
	  (l_segment_array(10) IS NOT NULL) OR
	  (l_segment_array(11) IS NOT NULL) OR
	  (l_segment_array(12) IS NOT NULL) OR
	  (l_segment_array(13) IS NOT NULL) OR
	  (l_segment_array(14) IS NOT NULL) OR
	  (l_segment_array(15) IS NOT NULL) OR
	  (l_segment_array(16) IS NOT NULL) OR
	  (l_segment_array(17) IS NOT NULL) OR
	  (l_segment_array(18) IS NOT NULL) OR
	  (l_segment_array(19) IS NOT NULL) OR
	  (l_segment_array(20) IS NOT NULL)) THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INSIDE GET CCID ROUTINE' ) ;
      END IF;
	 FND_FLEX_KEY_API.SET_SESSION_MODE('customer_data');
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'AFTER CALL TO SET SESSION' ) ;
	 END IF;
	 l_flexfield := FND_FLEX_KEY_API.FIND_FLEXFIELD('INV', 'MSTK');
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'AFTER FIND FLEXFIELD' ) ;
	 END IF;
	 l_structure.structure_number := 101;
	 FND_FLEX_KEY_API.GET_SEGMENTS(l_flexfield, l_structure, TRUE, l_n_segments, l_segments);
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SEGMENTS ENABLED = '||L_N_SEGMENTS ) ;
      END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'ORG_ID = '||L_LINE_REC.ORG_ID ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'VALIDATION_ORG_ID = '||L_VALIDATION_ORG ) ;
	 END IF;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'ARRAY1 = '||L_SEGMENT_ARRAY ( 1 ) ) ;
	 END IF;
	 IF FND_FLEX_EXT.GET_COMBINATION_ID('INV', 'MSTK', 101, SYSDATE, l_n_segments, l_segment_array, l_id, l_validation_org) THEN
	   l_line_rec.inventory_item_id := l_id;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'GET CCID = '||L_LINE_REC.INVENTORY_ITEM_ID ) ;
      END IF;
	 ELSE
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'ERROR IN GETTING CCID' ) ;
	   END IF;
	   failure_message := fnd_flex_ext.get_message;
	   OE_MSG_PUB.Add_TEXT(failure_message);
        p_return_status :=         FND_API.G_RET_STS_ERROR;
	   l_validate_only := FND_API.G_TRUE;
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'FAILURE MESSAGE = ' || SUBSTR ( FAILURE_MESSAGE , 1 , 50 ) ) ;
	   END IF;
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'FAILURE MESSAGE = ' || SUBSTR ( FAILURE_MESSAGE , 51 , 50 ) ) ;
	   END IF;
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'FAILURE MESSAGE = ' || SUBSTR ( FAILURE_MESSAGE , 101 , 50 ) ) ;
	   END IF;
      END IF;

  ELSIF l_line_rec.inventory_item_id <> FND_API.G_MISS_NUM AND
	 ((l_segment_array(1) IS NOT NULL) OR
	  (l_segment_array(2) IS NOT NULL) OR
	  (l_segment_array(3) IS NOT NULL) OR
	  (l_segment_array(4) IS NOT NULL) OR
	  (l_segment_array(5) IS NOT NULL) OR
	  (l_segment_array(6) IS NOT NULL) OR
	  (l_segment_array(7) IS NOT NULL) OR
	  (l_segment_array(8) IS NOT NULL) OR
	  (l_segment_array(9) IS NOT NULL) OR
	  (l_segment_array(10) IS NOT NULL) OR
	  (l_segment_array(11) IS NOT NULL) OR
	  (l_segment_array(12) IS NOT NULL) OR
	  (l_segment_array(13) IS NOT NULL) OR
	  (l_segment_array(14) IS NOT NULL) OR
	  (l_segment_array(15) IS NOT NULL) OR
	  (l_segment_array(16) IS NOT NULL) OR
	  (l_segment_array(17) IS NOT NULL) OR
	  (l_segment_array(18) IS NOT NULL) OR
	  (l_segment_array(19) IS NOT NULL) OR
	  (l_segment_array(20) IS NOT NULL)) THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'INSIDE ROUTINE WHERE BOTH ID AND SEG ARE POPULATED' ) ;
     END IF;
     l_line_rec.inventory_item_id := FND_API.G_MISS_NUM;
  	FND_MESSAGE.SET_NAME('ONT','OE_OIM_INVALID_ITEM_ID');
  	FND_MESSAGE.SET_TOKEN('ORDER_NO', l_orig_sys_document_ref);
  	FND_MESSAGE.SET_TOKEN('ORDER_SOURCE', l_order_source_id);
     OE_MSG_PUB.Add;
  	p_return_status :=         FND_API.G_RET_STS_ERROR;
	l_validate_only := FND_API.G_TRUE;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'CANNOT IMPORT ORDER AS BOTH INVENTORY_ITEM_ID AND INVENTORY_ITEM_SEGMENTS ARE POPULATED' ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ORDER NO: '||L_ORIG_SYS_DOCUMENT_REF ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ORDER SOURCE: '||L_ORDER_SOURCE_ID ) ;
	END IF;

  END IF;

    l_line_rec.service_reference_order :=
      nvl(l_line_rec.service_reference_order, FND_API.G_MISS_CHAR);
    l_line_rec.service_reference_line :=
      nvl(l_line_rec.service_reference_line, FND_API.G_MISS_CHAR);
    l_line_tbl    (l_line_count) := l_line_rec;
    l_line_val_tbl(l_line_count) := l_line_val_rec;
    if l_line_val_tbl(l_line_count).sold_to_org = FND_API.G_MISS_CHAR then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'L_LINE_TBL.SERVICE_REFERENCE_ORDER ' || ASCII ( L_LINE_TBL ( L_LINE_COUNT ) .SERVICE_REFERENCE_ORDER ) ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'L_LINE_VAL_TBL.SOLD_TO_ORG ' || ASCII ( L_LINE_VAL_TBL ( L_LINE_COUNT ) .SOLD_TO_ORG ) ) ;
    END IF;
    end if;

    l_orig_sys_line_ref     := l_line_rec.orig_sys_line_ref;
    l_orig_sys_shipment_ref := l_line_rec.orig_sys_shipment_ref;

	                 IF l_debug_level  > 0 THEN
	                     oe_debug_pub.add(  'ORIG SYS LINE REF ( '||L_LINE_COUNT||' ) : '|| L_LINE_TBL ( L_LINE_COUNT ) .ORIG_SYS_LINE_REF ) ;
	                 END IF;

			 IF l_debug_level  > 0 THEN
			     oe_debug_pub.add(  'ORIG SYS SHIPMENT REF ( '||L_LINE_COUNT||' ) : '|| L_LINE_TBL ( L_LINE_COUNT ) .ORIG_SYS_SHIPMENT_REF ) ;
			 END IF;

    BEGIN
	oe_Debug_pub.add('calling get line ids');	--bug 4240715
      OE_CNCL_UTIL.get_line_ids(l_line_rec,l_line_val_rec);
      oe_debug_pub.add('after calling get line ids'||l_line_rec.end_customer_id);	--bug 4240715
      --
      IF l_line_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        --
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        --
      ELSIF l_line_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        --
        RAISE FND_API.G_EXC_ERROR;
        --
      END IF;
      --
      --
      OE_CNCL_Util.Convert_Miss_To_Null(l_line_rec);
      oe_debug_pub.add('after calling convert miss to null'||l_line_rec.end_customer_id); --bug 4240715
      --

      OE_CNCL_Validate_Line.Attributes( x_return_status => l_return_status
                                    ,   p_x_line_rec => l_line_rec);
	oe_debug_pub.add('after calling validate line'||l_line_rec.end_customer_id);	--bug 4240715
      --
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        --
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        --
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        --
        RAISE FND_API.G_EXC_ERROR;
        --
      END IF;
      --

      OE_CNCL_Validate_Line.Entity( x_return_status => l_return_status
                                    ,   p_line_rec => l_line_rec);
	oe_debug_pub.add('after calling entity'||l_line_rec.end_customer_id);	--bug 4240715
      --
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        --
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        --
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        --
        RAISE FND_API.G_EXC_ERROR;
        --
      END IF;
      --
    --{ added for bug 4240715
      l_line_tbl    (l_line_count) := l_line_rec;
      l_line_val_tbl(l_line_count) := l_line_val_rec;
    -- bug 4240715}

    EXCEPTION
      --
      WHEN FND_API.G_EXC_ERROR THEN
        --
        OE_MSG_PUB.reset_msg_context('LINE');
        --
        RAISE;
        --
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --
        OE_MSG_PUB.reset_msg_context('LINE');
        --
        RAISE;
        --
      WHEN OTHERS THEN
        --
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          --
          OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Lines');
          --
        END IF;
        --
        OE_MSG_PUB.reset_msg_context('LINE');
        --
        RAISE;
        --
    END;

/* -----------------------------------------------------------
   Line Discounts/Price adjustments
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE LINE ADJUSTMENTS LOOP' ) ;
   END IF;

  OPEN l_line_adj_cursor;
  LOOP
     FETCH l_line_adj_cursor
      INTO l_line_adj_rec.orig_sys_discount_ref
	 , l_line_adj_rec.change_request_code
	 , l_line_adj_rec.list_header_id	-- changed from discount_id
	 , l_line_adj_rec.list_line_id		-- changed from discount_line_id
	 , l_line_adj_val_rec.discount
	 , l_line_adj_rec.percent
	 , l_line_adj_rec.automatic_flag
	 , l_line_adj_rec.applied_flag
	 , l_line_adj_rec.operand
	 , l_line_adj_rec.arithmetic_operator
	 , l_line_adj_rec.context
	 , l_line_adj_rec.attribute1
	 , l_line_adj_rec.attribute2
	 , l_line_adj_rec.attribute3
	 , l_line_adj_rec.attribute4
	 , l_line_adj_rec.attribute5
	 , l_line_adj_rec.attribute6
	 , l_line_adj_rec.attribute7
	 , l_line_adj_rec.attribute8
	 , l_line_adj_rec.attribute9
	 , l_line_adj_rec.attribute10
	 , l_line_adj_rec.attribute11
	 , l_line_adj_rec.attribute12
	 , l_line_adj_rec.attribute13
	 , l_line_adj_rec.attribute14
	 , l_line_adj_rec.attribute15
	 , l_line_adj_rec.request_id
	 , l_line_adj_rec.operation
	 , l_line_adj_rec.status_flag
-- Price Adjustment related changes bug# 1220921 (Start)
      , l_line_adj_rec.AC_CONTEXT
      , l_line_adj_rec.AC_ATTRIBUTE1
      , l_line_adj_rec.AC_ATTRIBUTE2
      , l_line_adj_rec.AC_ATTRIBUTE3
      , l_line_adj_rec.AC_ATTRIBUTE4
      , l_line_adj_rec.AC_ATTRIBUTE5
      , l_line_adj_rec.AC_ATTRIBUTE6
      , l_line_adj_rec.AC_ATTRIBUTE7
      , l_line_adj_rec.AC_ATTRIBUTE8
      , l_line_adj_rec.AC_ATTRIBUTE9
      , l_line_adj_rec.AC_ATTRIBUTE10
      , l_line_adj_rec.AC_ATTRIBUTE11
      , l_line_adj_rec.AC_ATTRIBUTE12
      , l_line_adj_rec.AC_ATTRIBUTE13
      , l_line_adj_rec.AC_ATTRIBUTE14
      , l_line_adj_rec.AC_ATTRIBUTE15
      , l_line_adj_val_rec.LIST_NAME
      , l_line_adj_rec.LIST_LINE_TYPE_CODE
      , l_line_adj_rec.LIST_LINE_NO
      , l_line_adj_val_rec.VERSION_NO
      , l_line_adj_rec.INVOICED_FLAG
      , l_line_adj_rec.ESTIMATED_FLAG
      , l_line_adj_rec.INC_IN_SALES_PERFORMANCE
      , l_line_adj_rec.CHARGE_TYPE_CODE
      , l_line_adj_rec.CHARGE_SUBTYPE_CODE
      , l_line_adj_rec.CREDIT_OR_CHARGE_FLAG
      , l_line_adj_rec.INCLUDE_ON_RETURNS_FLAG
      , l_line_adj_rec.COST_ID
      , l_line_adj_rec.TAX_CODE
      , l_line_adj_rec.PARENT_ADJUSTMENT_ID
      , l_line_adj_rec.MODIFIER_MECHANISM_TYPE_CODE
      , l_line_adj_rec.MODIFIED_FROM
      , l_line_adj_rec.MODIFIED_TO
      , l_line_adj_rec.UPDATED_FLAG
      , l_line_adj_rec.UPDATE_ALLOWED
      , l_line_adj_rec.CHANGE_REASON_CODE
      , l_line_adj_rec.CHANGE_REASON_TEXT
      , l_line_adj_rec.PRICING_PHASE_ID
      , l_line_adj_rec.ADJUSTED_AMOUNT
      , l_adj_line_ref
-- Price Adjustment related changes bug# 1220921 (End)
;
      EXIT WHEN l_line_adj_cursor%NOTFOUND;

      l_line_adj_rec.line_index := l_line_count;

      /*
      IF l_line_adj_rec.operation  = 'INSERT' THEN
         l_line_adj_rec.operation := 'CREATE';
      END IF;
      */

      l_line_adj_count := l_line_adj_count + 1;
      l_line_adj_tbl     (l_line_adj_count) := l_line_adj_rec;
      l_line_adj_val_tbl (l_line_adj_count) := l_line_adj_val_rec;

      l_adj_line_ref_tbl(l_line_adj_count) := l_adj_line_ref;

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'LINE ADJUSTMENT REF ( '||L_LINE_ADJ_COUNT||' ) : '|| L_LINE_ADJ_TBL ( L_LINE_ADJ_COUNT ) .ORIG_SYS_DISCOUNT_REF ) ;
		END IF;


      BEGIN
        --
        OE_CNCL_UTIL.get_line_adj_ids(l_line_adj_rec,l_line_adj_val_rec);
        --
        IF l_line_adj_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          --
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          --
        ELSIF l_line_adj_rec.return_status = FND_API.G_RET_STS_ERROR THEN
          --
          RAISE FND_API.G_EXC_ERROR;
          --
        END IF;
        --

        --
        OE_CNCL_Util.Convert_Miss_To_Null(l_line_adj_rec);
        --

        OE_CNCL_Validate_Line_Adj.Attributes(   x_return_status => l_return_status
                                            ,   p_Line_Adj_rec => l_line_adj_rec);

        --
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          --
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          --
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          --
          RAISE FND_API.G_EXC_ERROR;
          --
        END IF;
        --

        OE_CNCL_Validate_Line_Adj.Entity(  x_return_status => l_return_status
                                       ,   p_Line_Adj_rec => l_line_adj_rec);
        --
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          --
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          --
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          --
          RAISE FND_API.G_EXC_ERROR;
          --
        END IF;
        --

      EXCEPTION
        --
        WHEN FND_API.G_EXC_ERROR THEN
          --
          OE_MSG_PUB.reset_msg_context('LINE_ADJ');
          --
          RAISE;
          --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          --
          OE_MSG_PUB.reset_msg_context('LINE_ADJ');
          --
          RAISE;
          --
        WHEN OTHERS THEN
          --
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            --
            OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Line_Adjs');
            --
          END IF;
          --
          OE_MSG_PUB.reset_msg_context('LINE_ADJ');
          --
          RAISE;
          --
      END;
      --
  END LOOP;

  CLOSE l_line_adj_cursor;


/* -----------------------------------------------------------
   Line Sales Credits
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE LINE SALES CREDITS LOOP' ) ;
   END IF;

  OPEN l_line_scredit_cursor;
  LOOP
     FETCH l_line_scredit_cursor
      INTO l_line_scredit_rec.orig_sys_credit_ref
	 , l_line_scredit_rec.change_request_code
	 , l_line_scredit_rec.salesrep_id
	 , l_line_scredit_val_rec.salesrep
	 , l_line_scredit_rec.sales_credit_type_id
	 , l_line_scredit_val_rec.sales_credit_type
	 , l_line_scredit_rec.percent
	 , l_line_scredit_rec.context
	 , l_line_scredit_rec.attribute1
	 , l_line_scredit_rec.attribute2
	 , l_line_scredit_rec.attribute3
	 , l_line_scredit_rec.attribute4
	 , l_line_scredit_rec.attribute5
	 , l_line_scredit_rec.attribute6
	 , l_line_scredit_rec.attribute7
	 , l_line_scredit_rec.attribute8
	 , l_line_scredit_rec.attribute9
	 , l_line_scredit_rec.attribute10
	 , l_line_scredit_rec.attribute11
	 , l_line_scredit_rec.attribute12
	 , l_line_scredit_rec.attribute13
	 , l_line_scredit_rec.attribute14
	 , l_line_scredit_rec.attribute15
	 , l_line_scredit_rec.operation
	 , l_line_scredit_rec.status_flag
         , l_scredit_line_ref
;
      EXIT WHEN l_line_scredit_cursor%NOTFOUND;

      l_line_scredit_rec.line_index := l_line_count;

      /*
      IF l_line_scredit_rec.operation  = 'INSERT' THEN
         l_line_scredit_rec.operation := 'CREATE';
      END IF;
      */

      l_line_scredit_count := l_line_scredit_count + 1;
      l_line_scredit_tbl     (l_line_scredit_count) := l_line_scredit_rec;
      l_line_scredit_val_tbl (l_line_scredit_count) := l_line_scredit_val_rec;

      l_scredit_line_ref_tbl(l_line_scredit_count) := l_scredit_line_ref;

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'LINE SALESCREDITS REF ( '||L_LINE_SCREDIT_COUNT||' ) : '|| L_LINE_SCREDIT_TBL ( L_LINE_SCREDIT_COUNT ) .ORIG_SYS_CREDIT_REF ) ;
		END IF;


      BEGIN
        --
        OE_CNCL_UTIL.get_line_scredit_ids(l_line_scredit_rec,l_line_scredit_val_rec);
        --
        IF l_line_scredit_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          --
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          --
        ELSIF l_line_scredit_rec.return_status = FND_API.G_RET_STS_ERROR THEN
          --
          RAISE FND_API.G_EXC_ERROR;
          --
        END IF;
        --

        --
        OE_CNCL_Util.Convert_Miss_To_Null(l_line_scredit_rec);
        --


        OE_CNCL_Validate_Line_Scredit.Attributes(   x_return_status => l_return_status
                                                ,   p_Line_Scredit_rec => l_line_scredit_rec);
        --
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          --
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          --
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          --
          RAISE FND_API.G_EXC_ERROR;
          --
        END IF;
        --

        OE_CNCL_Validate_Line_Scredit.Entity(   x_return_status => l_return_status
                                            ,   p_Line_Scredit_rec => l_line_scredit_rec);

        --
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          --
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          --
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          --
          RAISE FND_API.G_EXC_ERROR;
          --
        END IF;
        --

      EXCEPTION
        --
        WHEN FND_API.G_EXC_ERROR THEN
          --
          OE_MSG_PUB.reset_msg_context('LINE_SCREDIT');
          --
          RAISE;
          --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          --
          OE_MSG_PUB.reset_msg_context('LINE_SCREDIT');
          --
          RAISE;
          --
        WHEN OTHERS THEN
          --
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            --
            OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Line_Scredits');
            --
          END IF;
          --
          OE_MSG_PUB.reset_msg_context('LINE_SCREDIT');
          --
          RAISE;
          --
      END;


  END LOOP;
  CLOSE l_line_scredit_cursor;

  END LOOP;			/* Lines cursor */
  CLOSE l_line_cursor;




  /*------------------------+
   |                        |
   | INSERTION BEGINS HERE  |
   |                        |
   +------------------------*/

    --
    --Header Insert
    --
   BEGIN
    --
    OE_Header_Util.get_order_number(l_header_rec,l_header_rec_old);


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ORDER NUMBER'|| L_HEADER_REC.ORDER_NUMBER , 2 ) ;
    END IF;
    --
    SELECT OE_ORDER_HEADERS_S.NEXTVAL
    INTO   l_header_rec.header_id
    FROM   DUAL;
    --
    OE_CNCL_Util.Convert_Miss_To_Null(l_header_rec);
    --
    l_header_rec.creation_date := SYSDATE;
    l_header_rec.created_by    := FND_GLOBAL.USER_ID;
    -- bug 4002850, removed quotes around 1.0 below
    l_header_rec.version_number := nvl(l_header_rec.version_number,1.0);
    l_header_rec.last_updated_by := FND_GLOBAL.USER_ID;
    l_header_rec.last_update_date := sysdate;
    l_header_rec.booked_flag := nvl(l_header_rec.booked_flag, 'Y');
    l_header_rec.order_category_code :=
        nvl(l_header_rec.order_category_code, 'MIXED');
    l_header_rec.open_flag := 'N';
    l_header_rec.flow_status_code := 'CLOSED';
    --
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'USER ID IS '|| FND_GLOBAL.USER_ID ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RESP ID IS '|| FND_GLOBAL.RESP_ID ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'APPL ID IS '|| FND_GLOBAL.RESP_APPL_ID ) ;
    END IF;

    --
    OE_Header_Util.Insert_Row(l_header_rec);
    --
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'HEADER ID : ' || L_HEADER_REC.HEADER_ID , 2 ) ;
    END IF;


   EXCEPTION
    --
    WHEN FND_API.G_EXC_ERROR THEN
      --
      l_header_rec.return_status := FND_API.G_RET_STS_ERROR;
      --
      OE_Header_Security.g_check_all_cols_constraint := 'Y';
      OE_MSG_PUB.reset_msg_context('HEADER');
      --
      RAISE;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --
      l_header_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --
      OE_Header_Security.g_check_all_cols_constraint := 'Y';
      OE_MSG_PUB.reset_msg_context('HEADER');
      --
      RAISE;
      --
    WHEN OTHERS THEN
      --
      l_header_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        --
        OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                               'Header');
        --
      END IF;
      --
      OE_Header_Security.g_check_all_cols_constraint := 'Y';
      OE_MSG_PUB.reset_msg_context('HEADER');
      --
      RAISE;
      --
   END;
    --
    --
    -- Loop for Sales Credits
    --
    --
    FOR I in 1..l_header_scredit_tbl.count
    --
    LOOP
     --
     BEGIN
      --
      SELECT OE_SALES_CREDITS_S.NEXTVAL
      INTO   l_header_scredit_tbl(I).sales_credit_id
      FROM   DUAL;
      --
      l_header_scredit_tbl(I).header_id := l_header_rec.header_id;
      --
      OE_CNCL_Util.Convert_Miss_To_Null(l_header_scredit_tbl(I));
      --
      l_header_scredit_tbl(I).creation_date := SYSDATE;
      l_header_scredit_tbl(I).created_by    := FND_GLOBAL.USER_ID;
      l_header_scredit_tbl(I).last_updated_by := FND_GLOBAL.USER_ID;
      l_header_scredit_tbl(I).last_update_date := sysdate;
      --
      OE_Header_Scredit_Util.Insert_Row(l_header_scredit_tbl(I));
      --
     EXCEPTION
       --
       WHEN FND_API.G_EXC_ERROR THEN
         --
         l_header_scredit_tbl(I).return_status := FND_API.G_RET_STS_ERROR;
         --
         OE_Header_Security.g_check_all_cols_constraint := 'Y';
         OE_MSG_PUB.reset_msg_context('HEADER_SCREDIT');
         --
         RAISE;
         --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --
         l_header_scredit_tbl(I).return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         --
         OE_Header_Security.g_check_all_cols_constraint := 'Y';
         OE_MSG_PUB.reset_msg_context('HEADER_SCREDIT');
         --
         RAISE;
         --
       WHEN OTHERS THEN
         --
         l_header_scredit_tbl(I).return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         --
         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           --
           OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                  'Header_Scredits');
           --
         END IF;
         --
         OE_Header_Security.g_check_all_cols_constraint := 'Y';
         OE_MSG_PUB.reset_msg_context('HEADER_SCREDIT');
         --
         RAISE;
         --
       END;
       --
    END LOOP;
    --
    --
    -- Loop for Header Price Adjustment
    --
    --
    --
    FOR I in 1..l_header_adj_tbl.COUNT
    --
    LOOP
     --
     BEGIN
      --
      SELECT OE_PRICE_ADJUSTMENTS_S.NEXTVAL
      INTO   l_header_adj_tbl(I).price_adjustment_id
      FROM   DUAL;
      --
      l_header_adj_tbl(I).header_id := l_header_rec.header_id;
      --
      OE_CNCL_Util.Convert_Miss_To_Null(l_header_adj_tbl(I));
      --
      l_header_adj_tbl(I).creation_date := SYSDATE;
      l_header_adj_tbl(I).created_by    := FND_GLOBAL.USER_ID;
      l_header_adj_tbl(I).last_updated_by := FND_GLOBAL.USER_ID;
      l_header_adj_tbl(I).last_update_date := sysdate;
      --
      OE_Header_Adj_Util.Insert_Row(l_header_adj_tbl(I));
      --
     EXCEPTION
       --
       WHEN FND_API.G_EXC_ERROR THEN
         --
         l_header_adj_tbl(I).return_status := FND_API.G_RET_STS_ERROR;
         --
         OE_Header_Security.g_check_all_cols_constraint := 'Y';
         OE_MSG_PUB.reset_msg_context('HEADER_ADJ');
         --
         RAISE;
         --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --
         l_header_adj_tbl(I).return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         --
         OE_Header_Security.g_check_all_cols_constraint := 'Y';
         OE_MSG_PUB.reset_msg_context('HEADER_ADJ');
         --
         RAISE;
         --
       WHEN OTHERS THEN
         --
         l_header_adj_tbl(I).return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         --
         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           --
           OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                  'Header_Adjs');
           --
         END IF;
         --
         OE_Header_Security.g_check_all_cols_constraint := 'Y';
         OE_MSG_PUB.reset_msg_context('HEADER_ADJ');
         --
         RAISE;
         --
     END;
     --
    END LOOP;
    --
    --
    --
    -- Line insert
    --
    --
    --
    FOR I in 1..l_line_tbl.COUNT
    --
    LOOP
    --
      --
      SELECT OE_ORDER_LINES_S.NEXTVAL
      INTO   l_line_tbl(I).line_id
      FROM   DUAL;
      --
      -- { Start Before insert check is the item_type_code is
      --   present. Call get_item_type_code function
      --   bug 1949855


      l_line_rec                   :=  l_line_tbl(I);
      l_line_tbl(I).item_type_code :=  OE_CNCL_Validate_Line.get_item_type
                                       (l_line_rec);

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ITEM TYPE CODE => ' || L_LINE_TBL ( I ) .ITEM_TYPE_CODE ) ;
      END IF;
      -- End Before insert check is the item_type_code}

      --
      IF ((l_line_tbl(I).item_type_code = 'MODEL') AND
          (l_line_tbl(I).orig_sys_line_ref = l_line_tbl(I).top_model_line_ref)) THEN

         l_line_tbl(I).top_model_line_id := l_line_tbl(I).line_id;

      ELSIF l_line_tbl(I).item_type_code = 'SERVICE' THEN
        --
        IF l_line_tbl(I).service_reference_type_code <> 'ORDER' THEN
          --
          l_line_tbl(I).service_reference_system_id := TO_NUMBER(l_line_tbl(I).service_reference_system);
          --
        END IF;
        --
      END IF;
      --

      l_line_tbl(I).header_id := l_header_rec.header_id;
      --
      OE_CNCL_Util.Convert_Miss_To_Null(l_line_tbl(I));
      --

      l_line_tbl(I).flow_status_code := 'CLOSED';

      l_line_tbl(I).creation_date       := SYSDATE;
      l_line_tbl(I).created_by          := FND_GLOBAL.USER_ID;
      l_line_tbl(I).last_updated_by     := FND_GLOBAL.USER_ID;
      l_line_tbl(I).last_update_date    := SYSDATE;

      --

      --l_line_tbl(I).line_category_code := 'ORDER';
      --bug 1857305

      IF(nvl(l_line_val_tbl(I).line_type,FND_API.G_MISS_CHAR)  = FND_API.G_MISS_CHAR) THEN

        BEGIN

          SELECT  order_category_code
          INTO    l_line_val_tbl(I).line_type
          FROM    OE_LINE_TYPES_V
          WHERE   line_type_id = l_line_tbl(I).line_type_id ;

        EXCEPTION

          WHEN NO_DATA_FOUND THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
              THEN

              fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE','line_type_id');
              OE_MSG_PUB.Add;

            END IF;

          WHEN OTHERS THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
              OE_MSG_PUB.Add_Exc_Msg
              (   G_PKG_NAME
              ,   'Order_Import'
              );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END;

      END IF;

      IF (nvl(l_line_val_tbl(I).line_type, 'ORDER') = 'ORDER' OR  l_line_val_tbl(I).line_type = FND_API.G_MISS_CHAR) THEN

        l_line_tbl(I).line_category_code := 'ORDER';

      ELSIF (nvl(l_line_val_tbl(I).line_type, 'ORDER') = 'RETURN') THEN

        l_line_tbl(I).line_category_code := 'RETURN';

      ELSE

        l_line_tbl(I).line_category_code := 'ORDER';

      END IF;

      l_line_tbl(I).open_flag := 'N';
      l_line_tbl(I).shipment_number := nvl(l_line_tbl(I).shipment_number,1);
      l_line_tbl(I).booked_flag := 'Y';
      If l_line_tbl(I).cancelled_flag = 'N' Then
         l_line_tbl(I).cancelled_quantity := 0;
         l_line_tbl(I).cancelled_quantity2 := 0; -- INVCONV
      End If;

      --
      --
      -- Loop for Line Sales Credit
      --
      --
    /*  FOR J in 1..l_line_scredit_tbl.COUNT
      --
      LOOP
       --
       IF l_scredit_line_ref_tbl(J) = l_line_tbl(I).orig_sys_line_ref THEN
         --
         SELECT OE_SALES_CREDITS_S.NEXTVAL
         INTO   l_line_scredit_tbl(J).sales_credit_id
         FROM DUAL;
         --
         l_line_scredit_tbl(J).header_id := l_header_rec.header_id;
         --
         l_line_scredit_tbl(J).line_id := l_line_tbl(I).line_id;
         --
         OE_CNCL_Util.Convert_Miss_To_Null(l_line_scredit_tbl(J));
         --
         l_line_scredit_tbl(J).creation_date       := SYSDATE;
         l_line_scredit_tbl(J).created_by          := FND_GLOBAL.USER_ID;
         l_line_scredit_tbl(J).last_updated_by := FND_GLOBAL.USER_ID;
         l_line_scredit_tbl(J).last_update_date := sysdate;
       --
       END IF;
       --
      END LOOP;*/
      --
      --
      -- Loop for Line Price Adjustment
      --
      --
    /*  FOR K in 1..l_line_adj_tbl.COUNT
      --
      LOOP
       --
       IF l_adj_line_ref_tbl(K) = l_line_tbl(I).orig_sys_line_ref THEN
         --
         SELECT OE_PRICE_ADJUSTMENTS_S.NEXTVAL
         INTO l_line_adj_tbl(K).price_adjustment_id
         FROM DUAL;
         --
         l_line_adj_tbl(K).header_id := l_header_rec.header_id;
         l_line_adj_tbl(K).line_id := l_line_tbl(I).line_id;
         --
         OE_CNCL_Util.Convert_Miss_To_Null(l_line_adj_tbl(K));
         --
         l_line_adj_tbl(K).creation_date   := SYSDATE;
         l_line_adj_tbl(K).created_by      := FND_GLOBAL.USER_ID;
         l_line_adj_tbl(K).last_updated_by := FND_GLOBAL.USER_ID;
         l_line_adj_tbl(K).last_update_date := sysdate;
         --
       END IF;
       --
      END LOOP;--line adj*/
      --
    END LOOP; --end line
    --


    /*-------------------------+
    |                          |
    | NON-MODEL HANDLING CODE  |
    |                          |
    +--------------------------*/



    FOR L in 1..l_line_tbl.COUNT
    --
    LOOP
    --

     BEGIN

    --check for non models


      IF ((l_line_tbl(L).item_type_code <> 'MODEL' AND l_line_tbl(L).item_type_code <> 'STANDARD' ) AND
          (l_line_tbl(L).orig_sys_line_ref <> l_line_tbl(L).top_model_line_ref)) THEN

           FOR M in 1..l_line_tbl.COUNT
           LOOP

             IF(l_line_tbl(L).top_model_line_ref = l_line_tbl(M).orig_sys_line_ref) THEN
               l_line_tbl(L).top_model_line_id := l_line_tbl(M).line_id;
               EXIT;
             END IF;

           END LOOP;
            ---- bug# 8613185 : Start
           FOR N in 1..l_line_tbl.COUNT
           LOOP

             IF(l_line_tbl(L).link_to_line_ref = l_line_tbl(N).orig_sys_line_ref) THEN

               l_line_tbl(L).link_to_line_id := l_line_tbl(N).line_id;
               EXIT;

             END IF;
           END LOOP;
            ---- bug# 8613185 : End

      ELSIF l_line_tbl(L).item_type_code = 'SERVICE' THEN
        --
        IF l_line_tbl(L).service_reference_type_code = 'ORDER' THEN
          --
          FOR N IN 1..l_line_tbl.COUNT
            --
            LOOP
              --
              IF (l_line_tbl(L).orig_sys_document_ref = l_line_tbl(N).service_reference_order AND l_line_tbl(L).orig_sys_line_ref = l_line_tbl(N).service_reference_line) THEN
                 --
                 l_line_tbl(L).service_reference_line_id := l_line_tbl(N).line_id;
                 --
              END IF;
              --
            END LOOP;
          --
        END IF;
        --
      END IF;
      --

        oe_debug_pub.add(  ' ORIG SYS LINE REF ( '|| L ||' ) : '|| L_LINE_TBL ( L ) .ORIG_SYS_LINE_REF ) ;
        oe_debug_pub.add(  ' top_model_line_ref ( '|| L ||' ) : '|| L_LINE_TBL ( L ) .top_model_line_ref ) ;
        oe_debug_pub.add(  ' top_model_line_id ( '|| L ||' ) : '|| L_LINE_TBL ( L ) .top_model_line_id ) ;
        oe_debug_pub.add(  ' link_to_line_ref ( '|| L ||' ) : '|| L_LINE_TBL ( L ) .link_to_line_ref ) ;
        oe_debug_pub.add(  ' link_to_line_id ( '|| L ||' ) : '|| L_LINE_TBL ( L ) .link_to_line_id ) ;

      OE_Line_Util.Insert_Row(l_line_tbl(L));

      FOR J in 1..l_line_scredit_tbl.COUNT
      --
      LOOP
       --
       BEGIN
        --
        --
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  TO_CHAR ( J ) , 2 ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'L_SCREDIT_LINE_REF_TBL ' || L_SCREDIT_LINE_REF_TBL ( J ) , 2 ) ;
        END IF;
        IF l_scredit_line_ref_tbl(J) = l_line_tbl(L).orig_sys_line_ref THEN
          --
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'INSIDE IF STATEMENT**********************' , 2 ) ;
          END IF;
          SELECT OE_SALES_CREDITS_S.NEXTVAL
          INTO   l_line_scredit_tbl(J).sales_credit_id
          FROM DUAL;
          --
          l_line_scredit_tbl(J).header_id := l_header_rec.header_id;
          --
          l_line_scredit_tbl(J).line_id := l_line_tbl(L).line_id;
          --
          OE_CNCL_Util.Convert_Miss_To_Null(l_line_scredit_tbl(J));
          --
          l_line_scredit_tbl(J).creation_date       := SYSDATE;
          l_line_scredit_tbl(J).created_by          := FND_GLOBAL.USER_ID;
          l_line_scredit_tbl(J).last_updated_by := FND_GLOBAL.USER_ID;
          l_line_scredit_tbl(J).last_update_date := sysdate;

          OE_Line_Scredit_Util.Insert_Row(l_line_scredit_tbl(J));
        --
        END IF;
        --

        --
       EXCEPTION
         --
         WHEN FND_API.G_EXC_ERROR THEN
           --
           l_line_scredit_tbl(J).return_status := FND_API.G_RET_STS_ERROR;
           --
           OE_Header_Security.g_check_all_cols_constraint := 'Y';
           OE_MSG_PUB.reset_msg_context('LINE_SCREDIT');
           --
           RAISE;
           --
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           --
           l_line_scredit_tbl(J).return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           --
           OE_Header_Security.g_check_all_cols_constraint := 'Y';
           OE_MSG_PUB.reset_msg_context('LINE_SCREDIT');
           --
           RAISE;
           --
         WHEN OTHERS THEN
           --
           l_line_scredit_tbl(J).return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           --
           IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             --
             OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                    'Line_Scredits');
             --
           END IF;
           --
           OE_Header_Security.g_check_all_cols_constraint := 'Y';
           OE_MSG_PUB.reset_msg_context('LINE_SCREDIT');
           --
           RAISE;
           --
       END;
       --
      END LOOP; --scredit line


      FOR K in 1..l_line_adj_tbl.COUNT
      --
      LOOP
       --
       BEGIN
        --
        IF l_adj_line_ref_tbl(K) = l_line_tbl(L).orig_sys_line_ref THEN
          --
          SELECT OE_PRICE_ADJUSTMENTS_S.NEXTVAL
          INTO l_line_adj_tbl(K).price_adjustment_id
          FROM DUAL;
          --
          l_line_adj_tbl(K).header_id := l_header_rec.header_id;
          l_line_adj_tbl(K).line_id := l_line_tbl(L).line_id;
          --
          OE_CNCL_Util.Convert_Miss_To_Null(l_line_adj_tbl(K));
          --
          l_line_adj_tbl(K).creation_date   := SYSDATE;
          l_line_adj_tbl(K).created_by      := FND_GLOBAL.USER_ID;
          l_line_adj_tbl(K).last_updated_by := FND_GLOBAL.USER_ID;
          l_line_adj_tbl(K).last_update_date := SYSDATE;
          --
          -- JAUTOMO: TO DO
          -- l_line_adj_tbl(K).update_flag := 'N';

          OE_Line_Adj_Util.Insert_Row(l_line_adj_tbl(K));
          --
        END IF;
        --

        --
       EXCEPTION
         --
         WHEN FND_API.G_EXC_ERROR THEN
           --
           l_line_adj_tbl(K).return_status   := FND_API.G_RET_STS_ERROR;
           --
           OE_Header_Security.g_check_all_cols_constraint := 'Y';
           OE_MSG_PUB.reset_msg_context('LINE_ADJ');
           --
           RAISE;
           --
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           --
           l_line_adj_tbl(K).return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
           --
           OE_Header_Security.g_check_all_cols_constraint := 'Y';
           OE_MSG_PUB.reset_msg_context('LINE_ADJ');
           --
           RAISE;
           --
         WHEN OTHERS THEN
           --
           l_line_adj_tbl(K).return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
           --
           IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             --
             OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                    'Line_Adjs');
             --
           END IF;
           --
           OE_Header_Security.g_check_all_cols_constraint := 'Y';
           OE_MSG_PUB.reset_msg_context('LINE_ADJ');
           --
           RAISE;
           --
       END;
       --
      END LOOP;--line adj


  EXCEPTION
      --
      WHEN FND_API.G_EXC_ERROR THEN
        --
        l_line_tbl(L).return_status := FND_API.G_RET_STS_ERROR;
        --
        OE_Header_Security.g_check_all_cols_constraint := 'Y';
        OE_MSG_PUB.reset_msg_context('LINE');
        --
        RAISE;
        --
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --
        l_line_tbl(L).return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --
        OE_Header_Security.g_check_all_cols_constraint := 'Y';
        OE_MSG_PUB.reset_msg_context('LINE');
        --
        RAISE;
        --
      WHEN OTHERS THEN
        --
        l_line_tbl(L).return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          --
          OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 'Lines');
          --
        END IF;
        --
        OE_Header_Security.g_check_all_cols_constraint := 'Y';
        OE_MSG_PUB.reset_msg_context('LINE');
        --
        RAISE;
        --
     END;
      --


    END LOOP;  --non-model and service
    --






 EXCEPTION
   --
   WHEN FND_API.G_EXC_ERROR THEN
     --
     p_return_status                   := FND_API.G_RET_STS_ERROR;
     --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     p_return_status                   := FND_API.G_RET_STS_UNEXP_ERROR;
     --
   WHEN OTHERS THEN
     --
     p_return_status                   := FND_API.G_RET_STS_UNEXP_ERROR;
     --
 END;

 --END LOOP;
 CLOSE l_header_cursor;
----------------------------------------

/* -----------------------------------------------------------
   Delete order from interface tables
   -----------------------------------------------------------
*/
   -- aksingh
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'L_VALIDATE_ONLY '||L_VALIDATE_ONLY ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_RETURN_STATUS '||P_RETURN_STATUS ) ;
   END IF;

-- aksingh   IF p_validate_only = FND_API.G_FALSE AND
   IF l_validate_only = FND_API.G_FALSE AND
      p_return_status = FND_API.G_RET_STS_SUCCESS	/* S=Success */
   THEN
      l_delete_flag := 'Y';
   ELSE
      l_delete_flag := 'N';
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'DELETE FLAG '||L_DELETE_FLAG ) ;
   END IF;

   IF l_delete_flag = 'Y' THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'BEFORE DELETING ORDER FROM INTERFACE TABLES' ) ;
      END IF;

      OE_ORDER_IMPORT_UTIL_PVT.Delete_Order (
	    p_request_id		=> l_request_id,
      	    p_order_source_id		=> l_order_source_id,
	    p_orig_sys_document_ref	=> l_orig_sys_document_ref,
            p_sold_to_org_id            => l_sold_to_org_id,
	    p_sold_to_org               => l_sold_to_org,
	    p_change_sequence		=> l_change_sequence,
	    p_return_status		=> l_return_status_del_ord
	   );

/* -----------------------------------------------------------
      Set Return Status
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'DELETE ORDER RETURN STATUS: '||L_RETURN_STATUS_DEL_ORD ) ;
      END IF;

      IF    l_return_status_del_ord IN (FND_API.G_RET_STS_ERROR)
      AND   p_return_status     NOT IN (FND_API.G_RET_STS_ERROR)
      THEN  p_return_status :=          FND_API.G_RET_STS_ERROR;
      ELSIF l_return_status_del_ord IN (FND_API.G_RET_STS_UNEXP_ERROR)
      AND   p_return_status     NOT IN (FND_API.G_RET_STS_ERROR,
				        FND_API.G_RET_STS_UNEXP_ERROR)
      THEN  p_return_status :=          FND_API.G_RET_STS_UNEXP_ERROR;
      END IF;

   END IF;	/* l_delete_flag = 'Y' */


/* -----------------------------------------------------------
   Commit or rollback the transaction
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE COMMIT OR ROLLBACK' ) ;
   END IF;

   IF l_validate_only =   FND_API.G_TRUE
   OR p_return_status in (FND_API.G_RET_STS_ERROR,	 -- E:Expected error
			  FND_API.G_RET_STS_UNEXP_ERROR) -- U:Unexpected error
   THEN
      l_commit_flag := 'N';
   ELSE
      l_commit_flag := 'Y';
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'COMMIT FLAG '||L_COMMIT_FLAG ) ;
   END IF;

   IF l_commit_flag = 'Y' THEN
      COMMIT;
   ELSE
      ROLLBACK;
   END IF;

/* -----------------------------------------------------------
   Update error_flag in interface tables
   -----------------------------------------------------------
*/
   IF p_return_status IN (FND_API.G_RET_STS_ERROR,
			  FND_API.G_RET_STS_UNEXP_ERROR)
   THEN
   BEGIN
      BEGIN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'BEFORE UPDATING ERROR FLAG FOR HEADER' ) ;
         END IF;

	 UPDATE oe_headers_interface
            SET error_flag = 'Y'
          WHERE order_source_id		= l_order_source_id
            AND orig_sys_document_ref 	= l_orig_sys_document_ref
            AND nvl(sold_to_org_id,                  FND_API.G_MISS_NUM)
              = nvl(l_sold_to_org_id,                FND_API.G_MISS_NUM)
            AND nvl(sold_to_org,                  FND_API.G_MISS_CHAR)
              = nvl(l_sold_to_org,                FND_API.G_MISS_CHAR)
       	    AND nvl(  change_sequence,	FND_API.G_MISS_CHAR)
	      = nvl(l_change_sequence,	FND_API.G_MISS_CHAR)
            AND nvl(  request_id,	FND_API.G_MISS_NUM)
	      = nvl(l_request_id,	FND_API.G_MISS_NUM);
      EXCEPTION
        WHEN OTHERS THEN
	  IF l_debug_level  > 0 THEN
	      oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
	  END IF;
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	     l_return_status_upd_err := FND_API.G_RET_STS_UNEXP_ERROR;
             OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Import_Order');
          END IF;
      END;

      BEGIN
         FOR I in 1..l_header_adj_tbl.count
         LOOP
  	   IF l_debug_level  > 0 THEN
  	       oe_debug_pub.add(  'BEFORE UPDATING ERROR FLAG FOR HEADER PRICE ADJUSTMENTS' ) ;
  	   END IF;
   	   IF l_header_adj_tbl(I).return_status IN (
				  	FND_API.G_RET_STS_ERROR,
		  	          	FND_API.G_RET_STS_UNEXP_ERROR)
   	   THEN
           BEGIN
	     UPDATE oe_price_adjs_interface
                SET error_flag = 'Y'
              WHERE order_source_id		= l_order_source_id
                AND orig_sys_document_ref 	= l_orig_sys_document_ref
                AND nvl(sold_to_org_id,                  FND_API.G_MISS_NUM)
                  = nvl(l_sold_to_org_id,                FND_API.G_MISS_NUM)
                AND nvl(sold_to_org,                  FND_API.G_MISS_CHAR)
                  = nvl(l_sold_to_org,                FND_API.G_MISS_CHAR)
       	        AND nvl(  change_sequence,	FND_API.G_MISS_CHAR)
	          = nvl(l_change_sequence,	FND_API.G_MISS_CHAR)
                AND nvl(  request_id,		FND_API.G_MISS_NUM)
	          = nvl(l_request_id,		FND_API.G_MISS_NUM)
                AND nvl(orig_sys_discount_ref, 	FND_API.G_MISS_CHAR)
	          = nvl(l_header_adj_tbl(I).orig_sys_discount_ref,
					       	FND_API.G_MISS_CHAR);
           EXCEPTION
            WHEN OTHERS THEN
	      IF l_debug_level  > 0 THEN
	          oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
	      END IF;
              IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
              THEN
	         l_return_status_upd_err := FND_API.G_RET_STS_UNEXP_ERROR;
                 OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Import_Order');
              END IF;
           END;
	   END IF;
         END LOOP;
      END;

      BEGIN
         FOR I in 1..l_header_scredit_tbl.count
         LOOP
  	   IF l_debug_level  > 0 THEN
  	       oe_debug_pub.add(  'BEFORE UPDATING ERROR FLAG FOR HEADER SALES CREDITS' ) ;
  	   END IF;
   	   IF l_header_scredit_tbl(I).return_status IN (
					FND_API.G_RET_STS_ERROR,
		  	          	FND_API.G_RET_STS_UNEXP_ERROR)
   	   THEN
           BEGIN
	     UPDATE oe_credits_interface
                SET error_flag = 'Y'
              WHERE order_source_id		= l_order_source_id
                AND orig_sys_document_ref 	= l_orig_sys_document_ref
                AND nvl(sold_to_org_id,                  FND_API.G_MISS_NUM)
                  = nvl(l_sold_to_org_id,                FND_API.G_MISS_NUM)
                AND nvl(sold_to_org,                  FND_API.G_MISS_CHAR)
                  = nvl(l_sold_to_org,                FND_API.G_MISS_CHAR)
       	        AND nvl(  change_sequence,	FND_API.G_MISS_CHAR)
	          = nvl(l_change_sequence,	FND_API.G_MISS_CHAR)
                AND nvl(  request_id,		FND_API.G_MISS_NUM)
	          = nvl(l_request_id,		FND_API.G_MISS_NUM)
                AND nvl(orig_sys_credit_ref,	FND_API.G_MISS_CHAR)
	          = nvl(l_header_scredit_tbl(I).orig_sys_credit_ref,
						FND_API.G_MISS_CHAR);
           EXCEPTION
            WHEN OTHERS THEN
	      IF l_debug_level  > 0 THEN
	          oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
	      END IF;
              IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
              THEN
	         l_return_status_upd_err := FND_API.G_RET_STS_UNEXP_ERROR;
                 OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Import_Order');
              END IF;
           END;
	   END IF;
         END LOOP;
      END;

      BEGIN
         FOR I in 1..l_line_tbl.count
         LOOP
  	   IF l_debug_level  > 0 THEN
  	       oe_debug_pub.add(  'BEFORE UPDATING ERROR FLAG FOR LINES' ) ;
  	   END IF;
   	   IF l_line_tbl(I).return_status IN (
					FND_API.G_RET_STS_ERROR,
		  	                FND_API.G_RET_STS_UNEXP_ERROR)
   	   THEN
           BEGIN
	    UPDATE oe_lines_interface
               SET error_flag = 'Y'
             WHERE order_source_id		= l_order_source_id
               AND orig_sys_document_ref 	= l_orig_sys_document_ref
               AND nvl(sold_to_org_id,                  FND_API.G_MISS_NUM)
                 = nvl(l_sold_to_org_id,                FND_API.G_MISS_NUM)
               AND nvl(sold_to_org,                  FND_API.G_MISS_CHAR)
                 = nvl(l_sold_to_org,                FND_API.G_MISS_CHAR)
       	       AND nvl(  change_sequence,	  FND_API.G_MISS_CHAR)
	         = nvl(l_change_sequence,	  FND_API.G_MISS_CHAR)
               AND nvl(  request_id,		  FND_API.G_MISS_NUM)
	         = nvl(l_request_id,		  FND_API.G_MISS_NUM)
               AND nvl(orig_sys_line_ref,      	    	   FND_API.G_MISS_CHAR)
	         = nvl(l_line_tbl(I).orig_sys_line_ref,    FND_API.G_MISS_CHAR)
               AND nvl(orig_sys_shipment_ref,              FND_API.G_MISS_CHAR)
	         = nvl(l_line_tbl(I).orig_sys_shipment_ref,FND_API.G_MISS_CHAR);
           EXCEPTION
            WHEN OTHERS THEN
	      IF l_debug_level  > 0 THEN
	          oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
	      END IF;
              IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
              THEN
	         l_return_status_upd_err := FND_API.G_RET_STS_UNEXP_ERROR;
                 OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Import_Order');
              END IF;
           END;
	   END IF;
         END LOOP;
      END;

/* -----------------------------------------------------------
      Set Return Status
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UPDATE ERROR_FLAG RETURN STATUS: '||L_RETURN_STATUS_UPD_ERR ) ;
      END IF;

      IF    l_return_status_upd_err IN (FND_API.G_RET_STS_ERROR)
      AND   p_return_status     NOT IN (FND_API.G_RET_STS_ERROR)
      THEN  p_return_status :=          FND_API.G_RET_STS_ERROR;
      ELSIF l_return_status_upd_err IN (FND_API.G_RET_STS_UNEXP_ERROR)
      AND   p_return_status     NOT IN (FND_API.G_RET_STS_ERROR,
				        FND_API.G_RET_STS_UNEXP_ERROR)
      THEN  p_return_status :=          FND_API.G_RET_STS_UNEXP_ERROR;
      END IF;

/* -----------------------------------------------------------
      Commit or rollback the error_flag
   -----------------------------------------------------------
*/
      IF  l_return_status_upd_err NOT IN (FND_API.G_RET_STS_ERROR,
                                          FND_API.G_RET_STS_UNEXP_ERROR)
      THEN
         COMMIT;	/* commit the error_flag updated */
      ELSE
         ROLLBACK; 	/* rollback the error_flag updated */
      END IF;

   END;
   END IF;	/* IF p_return_status IN ... */


/* -----------------------------------------------------------
   Update the processing messages table
   -----------------------------------------------------------
*/
   OE_MSG_PUB.Count_And_Get (p_count => p_msg_count
        		    ,p_data  => p_msg_data);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'MESSAGES RETURNED: '|| TO_CHAR ( P_MSG_COUNT ) ) ;
   END IF;

   IF p_msg_count > 0 THEN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE UPDATING THE PROCESSING MESSAGES TABLE' ) ;
     END IF;

     FOR k IN 1 .. p_msg_count
     LOOP
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE CALLING GET' ) ;
     END IF;
  	oe_msg_pub.get (
		 p_msg_index     => -2
		,p_encoded       => 'F'
		,p_data          => p_msg_data
		,p_msg_index_out => l_msg_index);

	l_msg_order_source_id 		:= '';
	l_msg_orig_sys_document_ref 	:= '';
	l_msg_orig_sys_line_ref     	:= '';
	l_msg_orig_sys_shipment_ref 	:= '';
	l_msg_sold_to_org_id            := '';
	l_msg_sold_to_org               := '';
	l_msg_change_sequence       	:= '';
	l_msg_entity_code	        := '';
	l_msg_entity_ref 	        := '';

   begin
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE CALLING GET_MSG_CONTEXT' ) ;
     END IF;
	oe_msg_pub.get_msg_context (
     		 p_msg_index                    => l_msg_index
    		,x_entity_code                  => l_msg_entity_code
    		,x_entity_ref                   => l_msg_entity_ref
    		,x_entity_id                    => l_msg_entity_id
    		,x_header_id                    => l_msg_header_id
    		,x_line_id                      => l_msg_line_id
    		,x_order_source_id              => l_msg_order_source_id
    		,x_orig_sys_document_ref        => l_msg_orig_sys_document_ref
    		,x_orig_sys_line_ref   		=> l_msg_orig_sys_line_ref
    		,x_orig_sys_shipment_ref   	=> l_msg_orig_sys_shipment_ref
    		,x_change_sequence	        => l_msg_change_sequence
    		,x_source_document_type_id      => l_msg_source_document_type_id
    		,x_source_document_id           => l_msg_source_document_id
    		,x_source_document_line_id      => l_msg_source_document_line_id
    		,x_attribute_code               => l_msg_attribute_code
    		,x_constraint_id                => l_msg_constraint_id
    		,x_process_activity             => l_msg_process_activity
    		,x_notification_flag            => l_msg_notification_flag
    		,x_type                 	=> l_msg_type
		);

      exception
        when others then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UNEXPECTED ERROR IN GET MSG : '||SQLERRM ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'IGNORING ABOVE MESSAGE' ) ;
        END IF;
        l_error_index_flag := 'Y';
   end;
   -- bug 4195533 - changed the condition below from <> to =
   if l_error_index_flag = 'Y' then
     goto out_error;
   end if;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTER CALLING GET_MSG_CONTEXT' ) ;
     END IF;
	IF oe_msg_pub.g_msg_tbl(l_msg_index).message_text IS NULL THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'IN INDEX.MESSAGE_TEXT IS NULL' ) ;
        END IF;
    	   p_msg_data := oe_msg_pub.get(l_msg_index, 'F');
	END IF;

	l_msg_context := '';
        IF l_msg_order_source_id IS NOT NULL THEN
           l_msg_context := 'Src: ' || l_msg_order_source_id;
        END IF;
        IF l_msg_orig_sys_document_ref IS NOT NULL THEN
	   l_msg_context := l_msg_context ||
                         ', ' || 'Hdr: '||rtrim(l_msg_orig_sys_document_ref);
	END IF;
	IF l_msg_orig_sys_line_ref IS NOT NULL THEN
	   l_msg_context := l_msg_context ||
			 ', ' || 'Line: '||rtrim(l_msg_orig_sys_line_ref);
	END IF;
	IF l_msg_orig_sys_shipment_ref IS NOT NULL THEN
	   l_msg_context := l_msg_context ||
			 ', ' || 'Ship: '||rtrim(l_msg_orig_sys_shipment_ref);
	END IF;
	IF l_msg_sold_to_org_id IS NOT NULL THEN
	   l_msg_context := l_msg_context ||
			 ', ' || 'Customer ID: '|| l_msg_sold_to_org_id;
	END IF;
	IF l_msg_sold_to_org IS NOT NULL THEN
	   l_msg_context := l_msg_context ||
			 ', ' || 'Customer Name: '||rtrim(l_msg_sold_to_org);
	END IF;
	IF l_msg_change_sequence IS NOT NULL THEN
	   l_msg_context := l_msg_context ||
			 ', ' || 'Chg: '||rtrim(l_msg_change_sequence);
        END IF;

	IF l_msg_entity_code IS NOT NULL AND
	   l_msg_entity_ref  IS NOT NULL
	THEN
	   IF    l_msg_entity_code IN ('HEADER_ADJ', 'LINE_ADJ') THEN
	         l_msg_context := l_msg_context || ', ' || 'Adj: ';
	   ELSIF l_msg_entity_code IN ('HEADER_SCREDIT', 'LINE_SCREDIT') THEN
	         l_msg_context := l_msg_context || ', ' || 'SCredit: ';
	   ELSIF l_msg_entity_code IN ('LOT_SERIAL') THEN
	         l_msg_context := l_msg_context || ', ' || 'Lot: ';
	   ELSIF l_msg_entity_code IN ('RESERVATION') THEN
	         l_msg_context := l_msg_context || ', ' || 'Rsrvtn: ';
	   END IF;
	         l_msg_context := l_msg_context || rtrim(l_msg_entity_ref);
	END IF;
	l_msg_data := 'Msg-'||k||' for '||l_msg_context||': '||p_msg_data;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  L_MSG_DATA ) ;
        END IF;
        -- start bug 4195533
        IF p_return_status = FND_API.G_RET_STS_SUCCESS
           AND l_header_rec.header_id <> FND_API.G_MISS_NUM THEN
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'Header id updated in msg stack:' || l_header_rec.header_id ) ;
           END IF;
           oe_msg_pub.g_msg_tbl(l_msg_index).header_id := l_header_rec.header_id;
        END IF;
        -- end bug 4195533
     END LOOP;
     <<out_error>>
       null;
   END IF;

/* -----------------------------------------------------------
   Delete messages from the database table
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE DELETING OLD MESSAGES FROM THE DATABASE TABLE' ) ;
   END IF;

/*
   OE_ORDER_IMPORT_UTIL_PVT.Delete_Messages (
	    p_request_id		=> l_request_id,
	    p_order_source_id		=> l_order_source_id,
	    p_orig_sys_document_ref	=> l_orig_sys_document_ref,
	    p_change_sequence		=> l_change_sequence,
	    p_return_status		=> l_return_status_del_msg
	   );
*/


/* -----------------------------------------------------------
   Set Return Status
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'DELETE MESSAGES RETURN STATUS: '||L_RETURN_STATUS_DEL_MSG ) ;
   END IF;

   IF    l_return_status_del_msg IN (FND_API.G_RET_STS_ERROR)
   AND   p_return_status     NOT IN (FND_API.G_RET_STS_ERROR)
   THEN  p_return_status :=          FND_API.G_RET_STS_ERROR;
   ELSIF l_return_status_del_msg IN (FND_API.G_RET_STS_UNEXP_ERROR)
   AND   p_return_status     NOT IN (FND_API.G_RET_STS_ERROR,
			             FND_API.G_RET_STS_UNEXP_ERROR)
   THEN  p_return_status :=          FND_API.G_RET_STS_UNEXP_ERROR;
   END IF;


/* -----------------------------------------------------------
   Save messages in the database table
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE SAVING MESSAGES IN THE DATABASE TABLE' ) ;
   END IF;

   IF p_msg_count > 0 THEN
        OE_MSG_PUB.save_messages (l_request_id);
   END IF;
   COMMIT;	/* commit again to commit the error messages */


/* -----------------------------------------------------------
   Commit or rollback the messages
   -----------------------------------------------------------
*/
   IF  l_return_status_del_msg = FND_API.G_RET_STS_SUCCESS
-- AND l_return_status_sav_msg = FND_API.G_RET_STS_SUCCESS -- Currently not set
   THEN
      COMMIT;	/* commit again to commit the error messages */
   ELSE
      ROLLBACK; /* rollback the error messages deleted */
   END IF;


/* -----------------------------------------------------------
   Report final order processing results
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'RETURN_STATUS: '||P_RETURN_STATUS ) ;
   END IF;

   IF    p_return_status = FND_API.G_RET_STS_ERROR THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ORDER FAILED WITH ERROR ( S ) ' ) ;
      END IF;
   ELSIF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ORDER FAILED WITH UNEXPECTED ERROR ( S ) ' ) ;
      END IF;
   ELSE
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ORDER PROCESSED SUCCESSFULLY' ) ;
      END IF;
   END IF;

  --END LOOP;			/* Headers cursor */
  --CLOSE l_header_cursor;


/*-----------------------------------------------------------
  End of Order Import
  -----------------------------------------------------------
*/
--oe_debug_pub.add('End of Order Import');


 EXCEPTION
    --
    WHEN OTHERS THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'UNEXPECTED ERROR: '||SQLERRM ) ;
       END IF;
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Import_Order');
       END IF;
       p_msg_count := p_msg_count + 1;
       p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END IMPORT_ORDER;

END OE_CNCL_ORDER_IMPORT_PVT;

/
